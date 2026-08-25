/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql
  Object       : united_db.dbo.FlatWire_CompleteCoilOnSkid
  Target DBs   : united_db  (procedure home; dbo.wip_skids, dbo.coil_gen_history)
                 proddb     (dbo.coils, dbo.wip_coil_orders, dbo.wip_skid_coils, dbo.wip_log_view)
                 SlitterDB  (dbo.coil_slit_cuts)
                 CommonDB   (GenerateCoilAlpha, ins_coil_gen_history, CoilCost_UpdateInsert,
                             Common_CopyPeriodicityCoilConditionFromParentCoil,
                             upd_or_ins_wip_orders, Logging_Information_In_Table)
                 wiplogdb   (dbo.wip_log, reached through proddb..wip_log_view)
  Last Updated : 2026-08-18
  Status       : Draft - transaction_name, coil_status, smp_no and the coil_slit_cuts sentinels
                 pending sign-off (see DECISIONS D3, D4, D8, D9 and Q34-Q36)
  Story        : FW-219 (FL2/FL3 run-end write-back into the shared schema)
  Specification: MVP-1/ProjectPlan/Architecture/Integration.md Sec 8.1
                 MVP-1/ProjectPlan/Backend/TaskBreakdownPlans/FW-219-FlatWire-CompleteCoilOnSkid.md
                 FR-509 - FR-518

  PURPOSE
  -------
  Writes ONE completed FL2/FL3 coreless flat wire coil into the shared schema, and places it on a
  skid, so that packing, shipping, certification, cost and yield keep working without regression.

  Called once per coil by FlatWire.API's CoilCompletionService, AFTER the FlatWireDB writes
  (CoilOutput / CoilTraceability / FlatWireRun) have committed. See "THE TRANSACTION BOUNDARY".

  It performs, in this order and for the reasons given in DECISIONS:

      1.  mint the shared 9-char coil alpha           CommonDB.dbo.GenerateCoilAlpha
      2.  proddb..coils                               <- the finished-goods row      (D3, D4)
      3.  proddb..wip_coil_orders                     <- the order link              (D8)
      4.  united_db..coil_gen_history                 <- genealogy, one parent       (D6)
      5.  coil_cost (via CoilCost_UpdateInsert)       <- cost record                 (D7)
      6.  wip_orders (via upd_or_ins_wip_orders)      <- order material status
      7.  SlitterDB..coil_slit_cuts                   <- exactly one cut row         (D9)
      8.  united_db..wip_skids                        <- open or update the skid     (D10, D11)
      9.  proddb..wip_skid_coils                      <- link coil to skid
      10. proddb..wip_log_view -> wiplogdb..wip_log    <- the WIP transaction         (D12)
      11. the hold path, when the final SPC failed                                   (D13)

  WHAT THIS PROCEDURE DELIBERATELY DOES NOT DO
  --------------------------------------------
    - It does not release wip_stations.coilno back to its idle sentinel. FR-077 SETS coilno at
      check-in and NO requirement clears it; wip_stations_k1 is UNIQUE on CoilNo, so an unreleased
      station collides with the next coil. That is a live defect in its own right, tracked as
      OI-112, and it belongs to run completion rather than coil completion. Do not bolt it on here.
    - It does not touch coils.coil_status on the ROD row, and it never writes 'INFLAT' to the
      shared vocabulary. D-32 (18 Aug 2026) cancelled FW-001/FW-002: the shared schema is used
      exactly as it stands. In-process flat wire state is FlatWireDB-local (Rod.Status,
      Spool.Status). Every write below lands in a column that already exists.
    - It does not decrement a parent coil. A flat wire output coil is a NEW unit produced by
      rolling, not a slice carved off an existing coil, so none of CreateSkid_MoveCutsOnSkid's
      parent-weight/cut arithmetic applies.
    - It does not print. Labels are the API's job (GET /coil/{alpha}/label).

  THE TRANSACTION BOUNDARY - read this before changing the error handling
  ----------------------------------------------------------------------
  Everything in this procedure is ONE transaction, and that transaction covers the SHARED half
  only. It is NOT in the same transaction as the FlatWireDB writes - those are in a different
  database and the design treats the two halves as compensating writes, the same boundary
  [ARC Sec 10] draws for check-in. So:

      - if this procedure throws, no shared row survives, and the caller must mark the run for
        operator retry (it must NOT silently swallow the error);
      - if this procedure succeeds and the caller then fails, the shared rows are already
        committed. The caller stores @sharedCoilNo on CoilOutput.CoilNo, and a retry passes
        it back through @expectedCoilNo, at which point this procedure is a no-op. That
        round trip is the whole idempotency contract - see IDEMPOTENCY.

  Note that this DIFFERS from CreateSkid_MoveCutsOnSkid, which has NO transaction at all: about
  forty DML statements across three databases, with a CATCH block that logs and rethrows but never
  rolls back. That is a defect, not a pattern, and it is not reproduced here.

  IDEMPOTENCY
  -----------
  Safe to re-run ONLY through @expectedCoilNo.

    - Called with @expectedCoilNo = '' (the normal first call), the procedure MINTS a new
      alpha. Calling it twice this way produces TWO coils, because GenerateCoilAlpha returns the
      next free suffix each time. There is no shared column holding 'FW-#####-C##', so the
      procedure cannot detect the duplicate for you.
    - Called with @expectedCoilNo set to an alpha that already exists in proddb..coils, the
      procedure returns that coil's current skid state and writes nothing.

  So the caller owns retry safety: persist CoilNo the moment this returns, and always pass
  it back on a retry.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  Every one of these was verified against the scripted DDL. Each is load-bearing: get it wrong and
  the insert fails at run time, or worse, silently does half the work.

  C1. proddb..coils.coil_no is char(9). The flat wire alpha 'FW-#####-C##' is TWELVE characters
      (fourteen with the mid-run child suffix) and DOES NOT FIT. Widening the column is a
      shared-schema migration and is exactly what D-32 cancelled. Hence the two-alpha rule (D5).

  C2. proddb..coils has NO primary key and NO identity. Uniqueness rests on coils_k1, a UNIQUE
      NONCLUSTERED index on coil_no. The CLUSTERED index coils_k0 is NON-unique, on
      (coil_alloy, inventory_type, coil_gauge, coil_width).

  C3. proddb..coils.coil_net_wgt and coil_gross_wgt are SMALLINT - max 32,767 lb. A finished flat
      wire coil is ~800-900 lb (client, 30 Jul 2026) so it fits, but the bound is checked below
      rather than left to wrap silently.

  C4. proddb..coils has a trigger, coils_iud_tg, and it does a great deal of the work for you:
        - on INSERT it writes united_db..coil_link_master_coil (coil_no, SUBSTRING(coil_no,1,6)).
          This is the master-coil grouping, and it is the second reason the shared alpha must keep
          a meaningful 6-character root (D5).
        - it writes wip_log_view ONLY for transaction_name = 'STORCOIL' (insert) or 'UPD_COIL' with
          mill_order_no = 0 (update). Ours is neither, so step 10 writes the WIP log explicitly.
        - on DELETE it archives to coils_hist and copies united_db..coil_cost to coil_cost_hist.
      *** IT IS SINGLE-ROW ONLY. *** Both this trigger and wip_skids_iud_tg gate their logic on
      @ins_count = 1 and use scalar SELECT @var = col FROM inserted. A set-based insert into
      proddb..coils SILENTLY SKIPS coil_link_master_coil altogether. Hence one coil per call, and
      hence this procedure must never be "optimised" into a batch.

  C5. united_db..coil_gen_history.parent_coil_no and child_coil_no are char(9); in_xaction is
      varchar(8). proddb..coil_gen_history is a VIEW exposing only 4 of the 16 columns and cannot
      be used to write mfg_order_no, parent_coil_gen_idx, coil_break or the split_* columns.

  C6. SlitterDB..coil_slit_cuts is the OWNER of that table. It was migrated out of united_db
      (UADEV-19354); united_db\Tables\coil_slit_cuts\ is an empty stub folder. Two traps:
        - skid_no is char(10) here, while wip_skids.skid_no and wip_skid_coils.skid_no are char(9);
        - cutMovementCount (smallint) and under_review (bit) are NOT NULL WITH NO DEFAULT in the
          scripted DDL, so every insert must supply them. Note that the 2020 template proc
          CoilReceiving_InsertCoilSlitCutDataOnSkid does NOT supply them - it predates the columns.
          Treat that proc as a SHAPE precedent, not as runnable code.
      It also carries 12 nonclustered indexes, one of which INCLUDEs every remaining column, so
      writes are expensive. One row per coil keeps that cost at its floor.

  C7. united_db..wip_skids.IsComplete is bit NOT NULL WITH NO DEFAULT, and it is ABSENT from
      proddb..wip_skids, which exposes only 23 of the 34 columns. *** YOU THEREFORE CANNOT INSERT
      THROUGH THE proddb VIEW. *** Write united_db..wip_skids directly. (Reads and weight updates
      through the view are fine and CreateSkid_MoveCutsOnSkid does both; this script writes the
      base table throughout so there is one rule to remember instead of two.)

  C8. wip_skids also has a second trigger, WIP_SKIDS_AFTER_UPD, which fires AFTER UPDATE **AND
      INSERT** and resets Certs_Documents.Processed = 0 for the order/release. Opening a skid
      therefore has a certification side effect. That is correct and intended - it is how certs
      know to regenerate - but it is not obvious from the name.

  C9. wip_skids.skid_net_wgt and skid_gross_wgt are SMALLINT. Two ~900 lb coils = ~1,800 lb, well
      inside the bound, but the running total is checked below (see C3).

  C10. proddb..wip_log_view is a pass-through VIEW: SELECT * FROM wiplogdb..wip_log WITH (NOLOCK).
       ALL 44 COLUMNS OF wip_log ARE NOT NULL AND NONE HAS A DEFAULT, so every insert supplies all
       44. There is no PK; the effective key is wip_log_k0, a UNIQUE CLUSTERED index on
       (wip_log_rev_time, seq_no) at SECOND granularity. The established way to avoid a collision
       is the spin loop in coils_iud_tg - bump rev_time by one second until the key is free - and
       this script uses it, correctly scoped to include seq_no.

  C11. proddb..wip_coil_orders effective key is wip_coil_orders_k0, UNIQUE CLUSTERED on
       (coil_no, order_no, rel_letter). rel_letter is NULLABLE yet part of that key.
       coil_planned_wgt and smp_no are smallint.

  C12. None of the seven target objects has a single FOREIGN KEY, CHECK constraint or column
       DEFAULT. All integrity is in triggers and procedures. Nothing below can rely on the
       database refusing bad data.

  DECISIONS / ASSUMPTIONS  (confirm before running outside DEV)
  ------------------------------------------------------------
  D1. Scope is FL2 and FL3 only. FL1 produces an intermediate SPOOL, not a finished coil, and a
      spool is not a saleable unit that goes on a skid. FL1 run completion writes FlatWireDB.Spool
      and stops there (FW-202). @lineId is validated against ('FL2','FL3') for that reason.

  D2. One coil per call. Forced by C4 - the coils trigger is single-row only. The two coils that
      share a skid are two calls, distinguished by @skidAssignment.

  D3. coils.coil_status = 'ONSKID'.  [Q35 - CLIENT/IT INPUT REQUIRED]
      Reusing the existing value rather than minting a flat-wire one is deliberate: a new value in
      the shared status vocabulary IS the change D-32 cancelled, and 'ONSKID' is literally true -
      the coil is complete and on a skid. CreateSkid_MoveCutsOnSkid writes exactly this value in
      the same situation. Confirm with IT that no report or availability check needs finished flat
      wire to be distinguishable by status; that is the same question OI-111 asks.

  D4. coils.transaction_name = 'FWCOMPLT'.  [Q34 - CLIENT/IT INPUT REQUIRED]
      Eight characters exactly, which is the full width of coils.transaction_name (varchar(8)),
      wip_log.transaction_name (char(8)) and coil_gen_history.in_xaction (varchar(8)) - so it fits
      all three without truncation and the same token is used in all three, which is what makes
      the transaction traceable end to end.
      A NEW token, not a reused one, because the alternatives are all worse: 'CREATSKD' would make
      flat wire indistinguishable from slitter skid creation in the WIP log, and 'STORCOIL' would
      trip the coils_iud_tg branch at C4 and produce a SECOND, duplicate wip_log row.
      *** MUST be confirmed against every stored procedure and report that switches on
      transaction_name before this runs outside DEV. *** Change it in ONE place (@TransactionName).

  D5. Two coil alphas, deliberately, and they are not interchangeable.
        CoilOutput.CoilAlpha    'FW-00421-C01'  customer-facing, on the label, FlatWireDB
        CoilOutput.CoilNo 'R00421A'       shared schema, char(9), THIS procedure
      The shared alpha is minted by CommonDB.dbo.GenerateCoilAlpha(rodAlpha, ''), which appends
      'A'..'Z' to the six-character root and sweeps 14 selects over 12 objects for uniqueness (coils,
      wip_log_view, mfg_sales_order_ref, coil_mill_processing, coil_slitter_processing, the
      planning_* mirrors, Slitting_UnPlannedCoils, CRM_Coils_Weight_Info and more).
      Three things fall out and all three are wanted:
        - it FITS char(9), which 'FW-#####-C##' does not (C1);
        - the output coils become CHILDREN OF THE ROD in the legacy tree, so coil_link_master_coil
          maps them to master 'R00421' (C4) and the genealogy reads naturally;
        - no shared column changes, so D-32 holds.
      Rejected: compressing the flat wire alpha into 9 chars (breaks the SUBSTRING(coil_no,1,6)
      master grouping and the GenerateCoilAlpha sweep), and widening coils.coil_no (a migration).

  D6. coil_gen_history records the PRIMARY parent rod ONLY, and this is a real loss of fidelity.
      A welded flat wire coil has MANY source rods - that is the point of induction welding - but
      ins_coil_gen_history is guarded by IF NOT EXISTS (... WHERE child_coil_no = @ChildCoil): one
      row, one parent. The primary parent is the rod with the lowest CoilTraceability.FootageFrom,
      resolved by the caller and passed as @primaryRodAlpha.
      *** FlatWireDB.CoilTraceability REMAINS THE AUTHORITATIVE MULTI-ROD GENEALOGY *** and is what
      the welding-wire customer certificates are built from. Anyone reading the shared tree alone
      will see one rod and believe it is the whole story. Tracked as OI-113. Do not "fix" this by
      inserting several coil_gen_history rows for one child - the table's own guard forbids it and
      downstream readers assume one row per child.
      A mid-run coil break sets coil_break / Coil_Break_Reason, which the table already supports.
      ins_coil_gen_history has no parameter for them, so they are applied as a follow-up UPDATE
      inside the same transaction. (SlitterInterface_RewindScrap_UpdatesOnStopTransaction does it
      as a direct single-statement insert instead; that is the alternative, but it forfeits the
      idempotency guard and the parent_coil_gen_idx resolution, which are worth more than the
      extra statement.)

  D7. CoilCost_UpdateInsert IS called, and forgetting it is the easiest mistake to make here.
      Without a coil_cost row the finished coil is invisible to cost and yield - which is precisely
      the regression [INT Sec 8] exists to prevent ("so scheduling, planning, reporting, cost and
      yield keep working without regression"). CreateSkid_MoveCutsOnSkid calls it immediately after
      the genealogy row, and coils_iud_tg archives coil_cost to coil_cost_hist on delete, so the
      table is live. @opLetter = 'F', the flattening operation letter.

  D8. wip_coil_orders is copied from the ROD's row when one exists, else seeded.  [Q36]
      coil_planned_wgt / smp_no / planned_operations are carried across, matching
      CreateSkid_MoveCutsOnSkid variant (a). When the rod has no row for this order/release the
      fallback writes @fallbackSmpNo / 'P', matching that proc's variant (b) - but what a flat wire
      output coil SHOULD carry for smp_no and planned_operations is unconfirmed (Q36).

  D9. coil_slit_cuts gets EXACTLY ONE ROW: a flat wire coil is one cut.
      There is no slitting, so there are no cuts in the slitter sense; the row exists because the
      packing and shipping chain joins through this table. cut_no = 1, coil_no_cuts = 1.
      *** THE SENTINEL VALUES ARE AN OPEN QUESTION (OI-114) AND CANNOT BE SETTLED BY COPYING ONE
      TEMPLATE, BECAUSE THE FIVE LEGACY NON-SLIT WRITERS DISAGREE WITH EACH OTHER: ***
          stop_no        1 in CoilReceiving_InsertCoilSlitCutDataOnSkid
                         0 in ConveyorInterface_PrepareDataForCreateSkid,
                              TollingManager_InsertIntoCoilSlitCuts,
                              DirectShipment_CreateSkidDataTransaction
          mfg_order_no   99999 in three of them, 0 in the fourth
          skid_coil_seq_no  HARD-CODED 1 in every single one
      The last of those flat wire CANNOT copy: two coils share a skid and need 1 and 2. So
      skid_coil_seq_no is DERIVED below (MAX+1 over the skid, under UPDLOCK), and stop_no /
      mfg_order_no are parameters with the majority defaults, changeable in one place.
      incoming_coil_no is resolved from the genealogy parent, following
      ConveyorInterface_PrepareDataForCreateSkid, so the cut row agrees with step 5.

  D10. Skid numbering reuses proddb..generate_new_skid_no - FR-339 requires exactly that
      ("skid numbering and logic shall follow the existing skid rules"). It yields a 9-character
      str(order_no,6) + rel_letter + str(seq,2), taking MAX over BOTH wip_skids and
      wip_skids_hist, and it also bumps wip_orders.next_skid_no for legacy Reflections.
      It takes NO locks, so two concurrent callers can generate the same number. This script
      allocates inside the transaction under UPDLOCK/HOLDLOCK and retries - the bare
      NOT EXISTS + WHILE loop in CreateSkid_MoveCutsOnSkid is a weak guard, not a solution.
      *** This is the resolution of OI-104. *** The "existing skid table" that CoilOutput.SkidId
      has always pointed at, and which no document named, created or verified, is
      united_db..wip_skids + proddb..wip_skid_coils.

  D11. skid_status = 'PACK' with NO trailing space.
      CreateSkid_MoveCutsOnSkid writes 'PACK ' (trailing space) on a new skid and 'PACK' on an
      existing one, against a char(6) column where both pad to the same stored value. Picking one
      deliberately avoids inheriting that inconsistency into new code.
      Exactly two coils per skid (FR-335, decision D2 of OutputCoilCompletion.md): Coil1Of2 opens
      the skid with IsComplete = 0, Coil2Of2 closes it with IsComplete = 1.
      An order producing an ODD number of coils leaves a skid holding one coil, and what happens
      then is UNANSWERED (OI-98) - so this procedure never closes a skid on its own initiative.
      IsComplete is driven solely by @skidAssignment, which the operator supplies on DB7.

  D12. The WIP log row is written EXPLICITLY, not left to the trigger. See C4: coils_iud_tg only
      logs 'STORCOIL' and 'UPD_COIL'. coil_skid_status = 'ONSKID' matches D3, and the
      (wip_log_rev_time, seq_no) key is resolved with the legacy second-granularity spin (C10).

  D13. The hold path reuses the EXISTING skid-hold vocabulary rather than inventing one.
      When the final SPC is out of spec and the operator takes DB7's Submit-Suspend route, the
      shared system already has the right shape: CreateSkid_MoveCutsOnSkid sets
      wip_skids.skid_status = 'HOLDP' and writes a WIP log row with transaction_name = 'SKIDHOLD'
      and coil_skid_status = 'PRHOLD' whenever a cut is under_review. That is the shared
      counterpart of CoilOutput.Status = 'HOLD', so @isSuspended takes it.
      The cut row also carries under_review = 1 in that case, which is what the legacy hold
      detection actually keys on.

  D14. Weights are INT parameters, bounds-checked, not silently truncated.
      CreateSkid_MoveCutsOnSkid declares @SkidWeight SMALLINT and assigns skid_net_wgt into it,
      and passes a FLOAT @skid_wgt into an INT @pallet_wgt. Both are latent overflow/truncation
      defects. Here the smallint bounds at C3 and C9 are tested and raised on explicitly.

  D15. No dynamic SQL anywhere. CreateSkid_MoveCutsOnSkid concatenates @SelectedCutNos VARCHAR(200)
      into @sql VARCHAR(1000) whose static text alone is ~700-800 characters - an injection surface
      AND a silent-truncation bug. One coil and one cut need neither.
==============================================================================================*/

USE [united_db];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[FlatWire_CompleteCoilOnSkid]
      @coilAlpha             VARCHAR(30)                    -- FlatWireDB CoilOutput.CoilAlpha, e.g. FW-00421-C01
    , @runId                 VARCHAR(20)                    -- FlatWireDB FlatWireRun.RunId, e.g. RUN-0042
    , @lineId                VARCHAR(5)                     -- FL2 | FL3            (D1)
    , @primaryRodAlpha       VARCHAR(9)                     -- lowest CoilTraceability.FootageFrom  (D6)
    , @orderNo               INT
    , @relLetter             CHAR(1)
    , @netWeightLb           INT                            -- the GOVERNING weight; OI-105 decides which of three
    , @grossWeightLb         INT
    , @finalGaugeIn          FLOAT
    , @finalWidthIn          FLOAT
    , @coilOd                FLOAT
    , @coilId                FLOAT
    , @footageFt             INT
    , @skidAssignment        VARCHAR(10)                    -- Coil1Of2 | Coil2Of2   (D11)
    , @badgeNo               INT
    , @existingSkidNo        CHAR(9)      = ''              -- required for Coil2Of2
    , @wipStation            VARCHAR(6)   = 'FWPACK'        -- seeded by 10_CommonDB_Insert_WIPStations_FlatWire.sql
    , @palletWeightLb        INT          = 0
    , @isCoilBreak           BIT          = 0               -- mid-run break -> coil_break     (D6)
    , @coilBreakReason       VARCHAR(255) = NULL
    , @isSuspended           BIT          = 0               -- out-of-spec final SPC -> hold   (D13)
    , @stopNo                SMALLINT     = 1               -- coil_slit_cuts sentinel, OI-114 (D9)
    , @mfgOrderNo            INT          = 99999           -- coil_slit_cuts sentinel, OI-114 (D9)
    , @fallbackSmpNo         SMALLINT     = 888             -- only when the rod has no order row (D8, Q36)
    , @expectedCoilNo  CHAR(9)      = ''              -- retry contract; see IDEMPOTENCY
    , @sharedCoilNo          CHAR(9)      = NULL OUTPUT     -- the minted shared alpha        (D5)
    , @skidNo                CHAR(9)      = NULL OUTPUT     -- the skid it landed on          (D10)
    , @skidIsComplete        BIT          = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;                                      -- absent from CreateSkid_MoveCutsOnSkid

    /*------------------------------------------------------------------------------------------
      0. Constants, locals and the audit-trail entry
    ------------------------------------------------------------------------------------------*/
    DECLARE @TransactionName  CHAR(8)     = 'FWCOMPLT'      -- D4 / Q34 - change here and nowhere else
          , @CoilStatus       CHAR(6)     = 'ONSKID'        -- D3 / Q35
          , @HoldTransaction  CHAR(8)     = 'SKIDHOLD'      -- D13
          , @HoldSkidStatus   CHAR(6)     = 'PRHOLD'        -- D13
          , @SkidStatusPack   CHAR(6)     = 'PACK'          -- D11
          , @SkidStatusHold   CHAR(6)     = 'HOLDP'         -- D13
          , @OpLetter         VARCHAR(1)  = 'F'             -- flattening; OI-27 notes GetMachineTypeFromOpLetter has no case for it
          , @DefaultGroupNo   SMALLINT    = 1               -- every non-slit template uses 1 (D9)
          , @SmallIntMax      INT         = 32767;          -- C3 / C9

    DECLARE @userId           INT
          , @skidCoilSeqNo    INT
          , @logInfo          VARCHAR(8000)
          , @logTime          DATETIME
          , @logSeqNo         SMALLINT    = 0
          , @rodOrderRowFound BIT         = 0
          , @genealogyParent  CHAR(9)
          , @attempts         INT         = 0
          , @errMessage       NVARCHAR(MAX)
          , @errNo            INT
          , @errSev           INT
          , @errState         INT
          , @spObjectName     SYSNAME;

    SELECT @userId = userid
    FROM   [dbo].[users] WITH (NOLOCK)
    WHERE  BadgeNo = @badgeNo;

    SET @logInfo = 'EXEC FlatWire_CompleteCoilOnSkid '
                 + ISNULL(@coilAlpha, 'NULL')            + ', '
                 + ISNULL(@runId, 'NULL')                + ', '
                 + ISNULL(@lineId, 'NULL')               + ', '
                 + ISNULL(@primaryRodAlpha, 'NULL')      + ', '
                 + ISNULL(CAST(@orderNo AS VARCHAR(10)), 'NULL')
                 + ISNULL(@relLetter, ' ')               + ', '
                 + ISNULL(@skidAssignment, 'NULL')       + ', skid='
                 + ISNULL(@existingSkidNo, '')           + ', net='
                 + ISNULL(CAST(@netWeightLb AS VARCHAR(10)), 'NULL') + ', ft='
                 + ISNULL(CAST(@footageFt AS VARCHAR(10)), 'NULL')
                 + CASE WHEN @isSuspended  = 1 THEN ', SUSPENDED'  ELSE '' END
                 + CASE WHEN @isCoilBreak  = 1 THEN ', COILBREAK'  ELSE '' END;

    EXEC [dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                            , @sp_name             = 'FlatWire_CompleteCoilOnSkid'
                                            , @table_name          = 'Entered into sp'
                                            , @log_info            = @logInfo
                                            , @operation_performed = 'Execute'
                                            , @user_id             = @userId;

    BEGIN TRY
        /*--------------------------------------------------------------------------------------
          1. Validate. Fail before writing anything, not half way through.
             C12: none of the target tables has a CHECK or FK, so every rule lives here.
        --------------------------------------------------------------------------------------*/
        SET @lineId          = LTRIM(RTRIM(ISNULL(@lineId, '')));
        SET @skidAssignment  = LTRIM(RTRIM(ISNULL(@skidAssignment, '')));
        SET @primaryRodAlpha = LTRIM(RTRIM(ISNULL(@primaryRodAlpha, '')));
        SET @existingSkidNo  = LTRIM(RTRIM(ISNULL(@existingSkidNo, '')));
        SET @wipStation      = LTRIM(RTRIM(ISNULL(@wipStation, 'FWPACK')));

        IF @lineId NOT IN ('FL2', 'FL3')
            THROW 51001, 'FlatWire_CompleteCoilOnSkid: @lineId must be FL2 or FL3. FL1 produces a spool, not a finished coil (D1).', 1;

        IF @skidAssignment NOT IN ('Coil1Of2', 'Coil2Of2')
            THROW 51002, 'FlatWire_CompleteCoilOnSkid: @skidAssignment must be Coil1Of2 or Coil2Of2 (D11).', 1;

        IF @skidAssignment = 'Coil2Of2' AND @existingSkidNo = ''
            THROW 51003, 'FlatWire_CompleteCoilOnSkid: Coil2Of2 requires @existingSkidNo - it closes an open skid.', 1;

        IF @primaryRodAlpha = ''
            THROW 51004, 'FlatWire_CompleteCoilOnSkid: @primaryRodAlpha is required - it is the genealogy parent and the alpha root (D5, D6).', 1;

        IF ISNULL(@footageFt, 0) <= 0
            THROW 51005, 'FlatWire_CompleteCoilOnSkid: @footageFt must be greater than zero (CK_CoilOutput_Footage).', 1;

        IF ISNULL(@netWeightLb, 0) <= 0 OR ISNULL(@grossWeightLb, 0) <= 0
            THROW 51006, 'FlatWire_CompleteCoilOnSkid: net and gross weight must both be greater than zero.', 1;

        -- C3: coils.coil_net_wgt / coil_gross_wgt are smallint. Refuse rather than wrap (D14).
        IF @netWeightLb > @SmallIntMax OR @grossWeightLb > @SmallIntMax
            THROW 51007, 'FlatWire_CompleteCoilOnSkid: weight exceeds the smallint bound on proddb..coils (C3). Refusing rather than truncating.', 1;

        IF @isCoilBreak = 1 AND LTRIM(RTRIM(ISNULL(@coilBreakReason, ''))) = ''
            THROW 51008, 'FlatWire_CompleteCoilOnSkid: @coilBreakReason is required when @isCoilBreak = 1 (D6).', 1;

        -- The rod must exist in the shared coils table: step 3 copies its attributes forward.
        IF NOT EXISTS (SELECT 1 FROM [proddb].[dbo].[coils] WITH (NOLOCK) WHERE coil_no = @primaryRodAlpha)
            THROW 51009, 'FlatWire_CompleteCoilOnSkid: the primary rod has no proddb..coils row, so its attributes cannot be carried to the output coil.', 1;

        /*--------------------------------------------------------------------------------------
          2. The retry short-circuit. See IDEMPOTENCY - this is the whole contract.
        --------------------------------------------------------------------------------------*/
        SET @expectedCoilNo = LTRIM(RTRIM(ISNULL(@expectedCoilNo, '')));

        IF @expectedCoilNo <> ''
           AND EXISTS (SELECT 1 FROM [proddb].[dbo].[coils] WITH (NOLOCK) WHERE coil_no = @expectedCoilNo)
        BEGIN
            SET @sharedCoilNo = @expectedCoilNo;

            SELECT @skidNo = wsc.skid_no
            FROM   [proddb].[dbo].[wip_skid_coils] AS wsc WITH (NOLOCK)
            WHERE  wsc.coil_no = @expectedCoilNo;

            SELECT @skidIsComplete = ws.IsComplete
            FROM   [dbo].[wip_skids] AS ws WITH (NOLOCK)
            WHERE  ws.skid_no = @skidNo;

            PRINT 'FlatWire_CompleteCoilOnSkid: ' + @expectedCoilNo
                + ' already exists in proddb..coils - nothing written (idempotent retry).';

            EXEC [dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                    , @sp_name             = 'FlatWire_CompleteCoilOnSkid'
                                                    , @table_name          = 'Idempotent retry - no write'
                                                    , @log_info            = @logInfo
                                                    , @operation_performed = 'Skip'
                                                    , @user_id             = @userId;
            RETURN 0;
        END

        BEGIN TRANSACTION;

        /*--------------------------------------------------------------------------------------
          3. Mint the shared 9-character coil alpha.  (D5, C1)
             GenerateCoilAlpha sweeps 14 selects over 12 objects but takes no locks, so the uniqueness
             re-check below is inside the transaction and under a held key lock.
        --------------------------------------------------------------------------------------*/
        IF @expectedCoilNo <> ''
            SET @sharedCoilNo = @expectedCoilNo;      -- minted by an earlier attempt that did not commit
        ELSE
            SET @sharedCoilNo = [CommonDB].[dbo].[GenerateCoilAlpha](@primaryRodAlpha, '');

        SET @sharedCoilNo = LTRIM(RTRIM(ISNULL(@sharedCoilNo, '')));

        IF @sharedCoilNo = ''
            THROW 51010, 'FlatWire_CompleteCoilOnSkid: GenerateCoilAlpha returned no alpha for the primary rod.', 1;

        IF EXISTS (SELECT 1 FROM [proddb].[dbo].[coils] WITH (UPDLOCK, HOLDLOCK) WHERE coil_no = @sharedCoilNo)
            THROW 51011, 'FlatWire_CompleteCoilOnSkid: the generated shared coil alpha is already taken. Retry.', 1;

        /*--------------------------------------------------------------------------------------
          4. proddb..coils - the finished-goods row.  (C1-C4, D3, D4)
             Explicit 43-column list, SELECT-from-rod so the inherited attributes travel, with the
             flat wire values overridden. ONE ROW - see C4, the trigger is single-row only.

             NOTE the deliberate difference from CreateSkid_MoveCutsOnSkid: that proc's column list
             has storage_section in position 22 receiving the literal '' while the source column is
             silently dropped. Here storage_section is set to ' ' ON PURPOSE - the coil has no
             storage location until packing assigns one (OI-106) - and it is documented as such.
        --------------------------------------------------------------------------------------*/
        INSERT INTO [proddb].[dbo].[coils]
                ( coil_no
                , vendor_no
                , inventory_type
                , coil_status
                , coil_alloy
                , coil_temper
                , coil_gauge
                , coil_width
                , coil_net_width
                , coil_net_wgt
                , coil_gross_wgt
                , coil_id_insert
                , coil_id
                , coil_net_id
                , coil_od
                , coil_net_od
                , coil_no_cuts
                , coil_surface_finish
                , coil_surface_finish_cond_code
                , coil_q_code
                , coil_finished_spec_flag
                , storage_section
                , storage_loc_col
                , storage_loc_row
                , storage_loc_height
                , coil_recvd_date
                , coil_origin_code
                , mill_order_no
                , mo_coil_smp_no
                , rej_no
                , wip_station
                , transaction_name
                , wip_badge_no
                , completed_operations
                , coil_f_temper_gauge
                , coil_first_roll_gauge
                , coil_last_anneal_gauge
                , coil_pct_reduction_hist
                , coil_anneal_temper_hist
                , coil_min_pct_reduction
                , coil_max_pct_reduction
                , reduction_hist_status_code
                , coil_rev_time )
        SELECT    @sharedCoilNo                                  -- coil_no            (D5)
                , rod.vendor_no
                , rod.inventory_type
                , @CoilStatus                                    -- coil_status        (D3)
                , rod.coil_alloy
                , rod.coil_temper
                , @finalGaugeIn                                  -- the flattened gauge, not the rod's
                , @finalWidthIn                                  -- flat wire width. NEVER call this "strip"
                , @finalWidthIn
                , @netWeightLb                                   -- smallint-bounded, checked above (C3)
                , @grossWeightLb
                , rod.coil_id_insert
                , @coilId
                , @coilId
                , @coilOd
                , @coilOd
                , 1                                              -- coil_no_cuts: one coreless coil = one cut (D9)
                , rod.coil_surface_finish
                , rod.coil_surface_finish_cond_code
                , rod.coil_q_code
                , 'Y'                                            -- finished to spec
                , ' '                                            -- storage_section: none until packing (OI-106)
                , 0
                , 0
                , 0
                , rod.coil_recvd_date
                , rod.coil_origin_code
                , rod.mill_order_no
                , rod.mo_coil_smp_no
                , rod.rej_no
                , @wipStation
                , @TransactionName                               -- D4 / Q34
                , @badgeNo
                , ISNULL(RTRIM(rod.completed_operations), '') + @OpLetter   -- append 'F' for flattening
                , rod.coil_f_temper_gauge
                , rod.coil_first_roll_gauge
                , rod.coil_last_anneal_gauge
                , rod.coil_pct_reduction_hist
                , rod.coil_anneal_temper_hist
                , rod.coil_min_pct_reduction
                , rod.coil_max_pct_reduction
                , rod.reduction_hist_status_code
                , GETDATE()
        FROM      [proddb].[dbo].[coils] AS rod WITH (NOLOCK)
        WHERE     rod.coil_no = @primaryRodAlpha;

        IF @@ROWCOUNT <> 1
            THROW 51012, 'FlatWire_CompleteCoilOnSkid: expected exactly one proddb..coils row to be inserted (C4 - the trigger is single-row only).', 1;

        /*--------------------------------------------------------------------------------------
          5. proddb..wip_coil_orders - the order link.  (C11, D8)
        --------------------------------------------------------------------------------------*/
        IF EXISTS (SELECT 1
                   FROM   [proddb].[dbo].[wip_coil_orders] WITH (NOLOCK)
                   WHERE  coil_no    = @primaryRodAlpha
                     AND  order_no   = @orderNo
                     AND  ISNULL(rel_letter, '') = ISNULL(@relLetter, ''))
            SET @rodOrderRowFound = 1;

        IF @rodOrderRowFound = 1
        BEGIN
            INSERT INTO [proddb].[dbo].[wip_coil_orders]
                    ( coil_no, order_no, rel_letter, coil_planned_wgt, smp_no, planned_operations )
            SELECT    @sharedCoilNo
                    , @orderNo
                    , @relLetter
                    , wco.coil_planned_wgt
                    , wco.smp_no
                    , wco.planned_operations
            FROM      [proddb].[dbo].[wip_coil_orders] AS wco WITH (NOLOCK)
            WHERE     wco.coil_no  = @primaryRodAlpha
              AND     wco.order_no = @orderNo
              AND     ISNULL(wco.rel_letter, '') = ISNULL(@relLetter, '');
        END
        ELSE
        BEGIN
            -- Fallback shape, matching CreateSkid_MoveCutsOnSkid variant (b). Q36 is open on
            -- what smp_no / planned_operations a flat wire output coil should really carry.
            INSERT INTO [proddb].[dbo].[wip_coil_orders]
                    ( coil_no, order_no, rel_letter, coil_planned_wgt, smp_no, planned_operations )
            VALUES  ( @sharedCoilNo, @orderNo, @relLetter, 0, @fallbackSmpNo, 'P' );
        END

        /*--------------------------------------------------------------------------------------
          6. united_db..coil_gen_history - genealogy.  (C5, D6)
             ONE PARENT ONLY. CoilTraceability in FlatWireDB is the authoritative multi-rod chain.
        --------------------------------------------------------------------------------------*/
        EXEC [CommonDB].[dbo].[ins_coil_gen_history] @ParentCoilNo   = @primaryRodAlpha
                                                   , @ChildCoil      = @sharedCoilNo
                                                   , @action         = @TransactionName
                                                   , @MfgOrderNo     = NULL
                                                   , @SeqNo          = NULL
                                                   , @HomeMfgOrderNo = NULL
                                                   , @OpLetter       = @OpLetter;

        IF NOT EXISTS (SELECT 1 FROM [dbo].[coil_gen_history] WITH (NOLOCK) WHERE child_coil_no = @sharedCoilNo)
            THROW 51013, 'FlatWire_CompleteCoilOnSkid: ins_coil_gen_history wrote no row for the new coil.', 1;

        -- The helper has no parameters for the break columns, so apply them here (D6).
        IF @isCoilBreak = 1
        BEGIN
            UPDATE  [dbo].[coil_gen_history] WITH (ROWLOCK)
            SET     coil_break        = 1
                  , Coil_Break_Reason = LEFT(@coilBreakReason, 255)
            WHERE   child_coil_no = @sharedCoilNo;
        END

        /*--------------------------------------------------------------------------------------
          7. coil_cost, the periodicity conditions, then the order's material status.  (D7)
             Skipping CoilCost_UpdateInsert is the easiest mistake here, and the coil then silently
             disappears from cost and yield. It is not optional.
        --------------------------------------------------------------------------------------*/
        EXEC [CommonDB].[dbo].[CoilCost_UpdateInsert] @parentCoilNo    = @primaryRodAlpha
                                                    , @childCoilNo     = @sharedCoilNo
                                                    , @childCoilWeight = @netWeightLb
                                                    , @mfgOrderNo      = NULL
                                                    , @seqNo           = NULL
                                                    , @opLetter        = @OpLetter;

        EXEC [CommonDB].[dbo].[Common_CopyPeriodicityCoilConditionFromParentCoil] @primaryRodAlpha
                                                                               , @sharedCoilNo;

        EXEC [CommonDB].[dbo].[upd_or_ins_wip_orders] @order_no   = @orderNo
                                                    , @rel_letter = @relLetter;

        /*--------------------------------------------------------------------------------------
          8. Allocate or adopt the skid.  (C7-C9, D10, D11)
             united_db..wip_skids is written DIRECTLY: IsComplete is NOT NULL with no default and
             is absent from proddb..wip_skids, so the view cannot be inserted through (C7).
        --------------------------------------------------------------------------------------*/
        IF @skidAssignment = 'Coil2Of2'
        BEGIN
            SET @skidNo = @existingSkidNo;

            IF NOT EXISTS (SELECT 1 FROM [dbo].[wip_skids] WITH (UPDLOCK, HOLDLOCK) WHERE skid_no = @skidNo)
                THROW 51014, 'FlatWire_CompleteCoilOnSkid: @existingSkidNo does not exist in wip_skids.', 1;

            IF EXISTS (SELECT 1 FROM [dbo].[wip_skids] WITH (NOLOCK) WHERE skid_no = @skidNo AND IsComplete = 1)
                THROW 51015, 'FlatWire_CompleteCoilOnSkid: @existingSkidNo is already complete - a skid holds exactly two coils (FR-335).', 1;

            IF (SELECT COUNT(*) FROM [proddb].[dbo].[wip_skid_coils] WITH (NOLOCK) WHERE skid_no = @skidNo) >= 2
                THROW 51016, 'FlatWire_CompleteCoilOnSkid: @existingSkidNo already carries two coils (FR-335).', 1;
        END
        ELSE
        BEGIN
            -- D10: generate_new_skid_no takes no locks, so retry under a held range lock.
            DECLARE @generated TABLE ( skid_no VARCHAR(9) );

            WHILE ISNULL(@skidNo, '') = '' AND @attempts < 10
            BEGIN
                SET @attempts = @attempts + 1;

                DELETE FROM @generated;

                INSERT INTO @generated ( skid_no )
                EXEC [proddb].[dbo].[generate_new_skid_no] @order_no   = @orderNo
                                                         , @rel_letter = @relLetter;

                SELECT TOP (1) @skidNo = LTRIM(RTRIM(skid_no)) FROM @generated;

                IF EXISTS (SELECT 1 FROM [dbo].[wip_skids] WITH (UPDLOCK, HOLDLOCK) WHERE skid_no = @skidNo)
                    SET @skidNo = '';                       -- taken between generation and here; go round again
            END

            IF ISNULL(@skidNo, '') = ''
                THROW 51017, 'FlatWire_CompleteCoilOnSkid: could not allocate a free skid number in 10 attempts.', 1;

            -- Skeleton row, matching CreateSkid_MoveCutsOnSkid's 26 columns. Weights and material
            -- attributes are set in the update at step 9, once the coil is known.
            -- C8: this INSERT fires WIP_SKIDS_AFTER_UPD and resets Certs_Documents.Processed.
            INSERT INTO [dbo].[wip_skids]
                    ( order_no
                    , rel_letter
                    , skid_no
                    , skid_status
                    , skid_gross_wgt
                    , skid_net_wgt
                    , skid_rev_time
                    , skid_alloy
                    , skid_temper
                    , skid_gauge
                    , skid_width
                    , storage_section
                    , storage_loc_col
                    , storage_loc_row
                    , storage_loc_height
                    , clockwise_flag
                    , contoured_flag
                    , eye_to_side_flag
                    , skid_create_time
                    , skid_capturwt_time
                    , skid_dstock_time
                    , pallet_wgt
                    , cores_wgt
                    , pkg_matl_wgt
                    , HT_ISPM_stamped
                    , IsComplete )
            VALUES  ( @orderNo
                    , @relLetter
                    , @skidNo
                    , ''
                    , 0
                    , 0
                    , GETDATE()
                    , 0
                    , ''
                    , 0.0
                    , 0.0
                    , ''
                    , 0
                    , 0
                    , 0
                    , ''
                    , 'N'
                    , 'N'
                    , GETDATE()
                    , NULL
                    , NULL
                    , ISNULL(@palletWeightLb, 0)
                    , 0
                    , 0
                    , 'N'
                    , 0 );                                  -- C7: NOT NULL, no default
        END

        /*--------------------------------------------------------------------------------------
          9. SlitterDB..coil_slit_cuts - exactly one row.  (C6, D9)
             skid_coil_seq_no is DERIVED, not hard-coded 1 as every legacy template does: two coils
             share a skid and need 1 and 2.
        --------------------------------------------------------------------------------------*/
        SELECT  @skidCoilSeqNo = ISNULL(MAX(ISNULL(csc.skid_coil_seq_no, 0)), 0) + 1
        FROM    [SlitterDB].[dbo].[coil_slit_cuts] AS csc WITH (UPDLOCK, HOLDLOCK)
        WHERE   LTRIM(RTRIM(ISNULL(csc.skid_no, ''))) = @skidNo
          AND   ISNULL(csc.plate_no, '') = '';

        IF @skidCoilSeqNo > 2
            THROW 51018, 'FlatWire_CompleteCoilOnSkid: the skid already carries two coils - exactly two per skid (FR-335).', 1;

        -- incoming_coil_no from the genealogy parent, following
        -- ConveyorInterface_PrepareDataForCreateSkid, so this row agrees with step 6.
        SELECT TOP (1) @genealogyParent = cgh.parent_coil_no
        FROM   [dbo].[coil_gen_history] AS cgh WITH (NOLOCK)
        WHERE  cgh.child_coil_no = @sharedCoilNo
        ORDER BY cgh.Coil_gen_idx DESC;

        SET @genealogyParent = ISNULL(@genealogyParent, @primaryRodAlpha);

        INSERT INTO [SlitterDB].[dbo].[coil_slit_cuts]
                ( incoming_coil_no
                , coil_no
                , mfg_order_no
                , seq_no
                , stop_no
                , order_no
                , rel_letter
                , cut_no
                , scrap_status
                , scrap_reason
                , scrap_wgt
                , setup_width
                , skid_no
                , skid_coil_no
                , skid_cut_no
                , skid_coil_seq_no
                , wip_rej_no
                , plate_no
                , plate_coil_no
                , plate_coil_cut_no
                , plate_coil_seq_no
                , IsCopied
                , IsStock
                , IsHold
                , is_edited
                , group_no
                , edited_wgt
                , edited_od
                , edited_id
                , cutMovementCount
                , under_review )
        VALUES  ( @genealogyParent                          -- incoming_coil_no  varchar(9)
                , @sharedCoilNo                             -- coil_no           varchar(9)
                , @mfgOrderNo                               -- OI-114 sentinel   (D9)
                , 0                                         -- seq_no
                , @stopNo                                   -- OI-114 sentinel   (D9)
                , @orderNo
                , @relLetter
                , 1                                         -- cut_no: one coil = one cut
                , 0                                         -- scrap_status
                , ''                                        -- scrap_reason
                , @netWeightLb                              -- scrap_wgt: the per-cut weight, per every template
                , @finalWidthIn                             -- setup_width  decimal(9,6)
                , @skidNo                                   -- C6: char(10) here, char(9) everywhere else
                , @sharedCoilNo                             -- skid_coil_no char(9)
                , 1                                         -- skid_cut_no
                , @skidCoilSeqNo                            -- DERIVED, 1 or 2  (D9)
                , NULL                                      -- wip_rej_no
                , NULL                                      -- plate_no: flat wire has no plates
                , NULL                                      -- plate_coil_no
                , NULL                                      -- plate_coil_cut_no
                , NULL                                      -- plate_coil_seq_no
                , 0                                         -- IsCopied
                , 0                                         -- IsStock
                , 0                                         -- IsHold
                , 0                                         -- is_edited
                , @DefaultGroupNo
                , @netWeightLb                              -- edited_wgt
                , @coilOd
                , @coilId
                , 0                                         -- C6: NOT NULL, no default
                , @isSuspended );                           -- C6: NOT NULL, no default. D13 keys the hold off this

        /*--------------------------------------------------------------------------------------
          10. Bring the skid up to date.  (C9, D11, D13)
        --------------------------------------------------------------------------------------*/
        IF (SELECT ISNULL(skid_net_wgt, 0) FROM [dbo].[wip_skids] WITH (NOLOCK) WHERE skid_no = @skidNo)
           + @netWeightLb > @SmallIntMax
            THROW 51019, 'FlatWire_CompleteCoilOnSkid: skid net weight would exceed the smallint bound on wip_skids (C9).', 1;

        SET @skidIsComplete = CASE WHEN @skidAssignment = 'Coil2Of2' THEN 1 ELSE 0 END;

        UPDATE  ws
        SET     skid_status    = CASE WHEN @isSuspended = 1 THEN @SkidStatusHold ELSE @SkidStatusPack END
              , skid_net_wgt   = ISNULL(ws.skid_net_wgt, 0) + @netWeightLb
              , skid_gross_wgt = ISNULL(ws.skid_gross_wgt, 0) + @grossWeightLb
              , skid_rev_time  = GETDATE()
              , skid_alloy     = ISNULL(c.coil_alloy, 0)
              , skid_temper    = ISNULL(c.coil_temper, '')
              , skid_gauge     = ISNULL(c.coil_gauge, 0)
              , skid_width     = ISNULL(c.coil_width, 0)
              , pallet_wgt     = CASE WHEN ISNULL(ws.pallet_wgt, 0) = 0 THEN ISNULL(@palletWeightLb, 0) ELSE ws.pallet_wgt END
              , IsComplete     = @skidIsComplete            -- D11: driven only by @skidAssignment; OI-98 is open
        FROM    [dbo].[wip_skids] AS ws
                CROSS APPLY ( SELECT TOP (1) coil_alloy, coil_temper, coil_gauge, coil_width
                              FROM   [proddb].[dbo].[coils] WITH (NOLOCK)
                              WHERE  coil_no = @sharedCoilNo ) AS c
        WHERE   ws.skid_no = @skidNo;

        /*--------------------------------------------------------------------------------------
          11. proddb..wip_skid_coils - link the coil to the skid.
        --------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1
                       FROM   [proddb].[dbo].[wip_skid_coils] WITH (NOLOCK)
                       WHERE  skid_no = @skidNo AND coil_no = @sharedCoilNo)
        BEGIN
            INSERT INTO [proddb].[dbo].[wip_skid_coils] ( skid_no, coil_no )
            VALUES ( @skidNo, @sharedCoilNo );
        END

        /*--------------------------------------------------------------------------------------
          12. The WIP log.  (C10, D12)
              All 44 columns, and the (wip_log_rev_time, seq_no) key resolved with the legacy
              second-granularity spin from coils_iud_tg - scoped to include seq_no, which the
              original omits because it always writes seq_no = 0.
        --------------------------------------------------------------------------------------*/
        SET @logTime = CONVERT(CHAR(9), GETDATE(), 1) + CONVERT(CHAR(8), GETDATE(), 108);

        WHILE EXISTS (SELECT 1
                      FROM   [proddb].[dbo].[wip_log_view] WITH (NOLOCK)
                      WHERE  wip_log_rev_time = @logTime AND seq_no = @logSeqNo)
            SET @logTime = DATEADD(SECOND, 1, @logTime);

        INSERT INTO [proddb].[dbo].[wip_log_view]
                ( wip_log_rev_time
                , seq_no
                , order_no
                , rel_letter
                , coil_no
                , skid_no
                , plate_no
                , wip_rej_no
                , wip_badge_no
                , transaction_name
                , wip_station
                , coil_skid_status
                , coil_alloy
                , coil_temper
                , coil_gauge
                , coil_width
                , coil_net_width
                , coil_id_insert
                , coil_id
                , coil_net_id
                , coil_od
                , coil_net_od
                , coil_skid_net_wgt
                , pallet_wgt
                , coil_skid_gross_wgt
                , coil_cond_code
                , coil_q_code
                , coil_surface_finish
                , storage_section
                , storage_loc_col
                , storage_loc_row
                , storage_loc_height
                , smp_no
                , planned_wgt
                , furnace_operation
                , furnace_no
                , furnace_program_no
                , furnace_temperature
                , start_coil_temper
                , start_coil_gauge
                , no_of_passes
                , no_of_cuts_setup
                , no_of_cuts
                , partial_complete_code )
        SELECT    @logTime
                , @logSeqNo
                , @orderNo
                , @relLetter
                , @sharedCoilNo
                , @skidNo
                , '  '                                      -- plate_no char(2): flat wire has no plates
                , 0                                         -- wip_rej_no
                , @badgeNo
                , @TransactionName                           -- D4 / Q34
                , @wipStation
                , @CoilStatus                                -- D3 / D12
                , ISNULL(c.coil_alloy, 0)
                , ISNULL(c.coil_temper, '')
                , ISNULL(c.coil_gauge, 0)
                , ISNULL(c.coil_width, 0)
                , ISNULL(c.coil_net_width, 0)
                , ISNULL(c.coil_id_insert, '')
                , ISNULL(c.coil_id, 0)
                , ISNULL(c.coil_net_id, 0)
                , ROUND(ISNULL(c.coil_od, 0), 3)
                , ROUND(ISNULL(c.coil_net_od, 0), 3)
                , @netWeightLb
                , ISNULL(@palletWeightLb, 0)
                , @grossWeightLb
                , 0                                         -- coil_cond_code
                , ISNULL(c.coil_q_code, '')
                , ISNULL(c.coil_surface_finish, '')
                , ''                                        -- storage_section
                , 0
                , 0
                , 0
                , ISNULL(wco.smp_no, 0)
                , ISNULL(wco.coil_planned_wgt, 0)
                , ''                                        -- furnace_operation: no anneal on this route
                , 0
                , 0
                , 0
                , ''                                        -- start_coil_temper
                , 0                                         -- start_coil_gauge
                , 1                                         -- no_of_passes
                , 0                                         -- no_of_cuts_setup
                , 1                                         -- no_of_cuts (D9)
                , ''                                        -- partial_complete_code
        FROM      [proddb].[dbo].[coils] AS c WITH (NOLOCK)
                  LEFT JOIN [proddb].[dbo].[wip_coil_orders] AS wco WITH (NOLOCK)
                         ON wco.coil_no  = c.coil_no
                        AND wco.order_no = @orderNo
                        AND ISNULL(wco.rel_letter, '') = ISNULL(@relLetter, '')
        WHERE     c.coil_no = @sharedCoilNo;

        /*--------------------------------------------------------------------------------------
          13. The hold path.  (D13)
              Reuses the existing SKIDHOLD / PRHOLD vocabulary rather than inventing a flat-wire
              status. skid_status was already set to HOLDP at step 10; this is its log row.
        --------------------------------------------------------------------------------------*/
        IF @isSuspended = 1
        BEGIN
            SET @logTime = CONVERT(CHAR(9), GETDATE(), 1) + CONVERT(CHAR(8), GETDATE(), 108);

            WHILE EXISTS (SELECT 1
                          FROM   [proddb].[dbo].[wip_log_view] WITH (NOLOCK)
                          WHERE  wip_log_rev_time = @logTime AND seq_no = @logSeqNo)
                SET @logTime = DATEADD(SECOND, 1, @logTime);

            INSERT INTO [proddb].[dbo].[wip_log_view]
                    ( wip_log_rev_time, seq_no, order_no, rel_letter, coil_no, skid_no, plate_no
                    , wip_rej_no, wip_badge_no, transaction_name, wip_station, coil_skid_status
                    , coil_alloy, coil_temper, coil_gauge, coil_width, coil_net_width
                    , coil_id_insert, coil_id, coil_net_id, coil_od, coil_net_od
                    , coil_skid_net_wgt, pallet_wgt, coil_skid_gross_wgt, coil_cond_code
                    , coil_q_code, coil_surface_finish, storage_section, storage_loc_col
                    , storage_loc_row, storage_loc_height, smp_no, planned_wgt
                    , furnace_operation, furnace_no, furnace_program_no, furnace_temperature
                    , start_coil_temper, start_coil_gauge, no_of_passes, no_of_cuts_setup
                    , no_of_cuts, partial_complete_code )
            SELECT    @logTime
                    , @logSeqNo
                    , @orderNo
                    , @relLetter
                    , @sharedCoilNo
                    , @skidNo
                    , '  '
                    , 0
                    , @badgeNo
                    , @HoldTransaction                       -- SKIDHOLD  (D13)
                    , @wipStation
                    , @HoldSkidStatus                        -- PRHOLD    (D13)
                    , ISNULL(c.coil_alloy, 0)
                    , ISNULL(c.coil_temper, '')
                    , ISNULL(c.coil_gauge, 0)
                    , ISNULL(c.coil_width, 0)
                    , ISNULL(c.coil_net_width, 0)
                    , ISNULL(c.coil_id_insert, '')
                    , ISNULL(c.coil_id, 0)
                    , ISNULL(c.coil_net_id, 0)
                    , ROUND(ISNULL(c.coil_od, 0), 3)
                    , ROUND(ISNULL(c.coil_net_od, 0), 3)
                    , @netWeightLb
                    , ISNULL(@palletWeightLb, 0)
                    , @grossWeightLb
                    , 0
                    , ISNULL(c.coil_q_code, '')
                    , ISNULL(c.coil_surface_finish, '')
                    , ''
                    , 0
                    , 0
                    , 0
                    , 0
                    , 0
                    , ''
                    , 0
                    , 0
                    , 0
                    , ''
                    , 0
                    , 1
                    , 0
                    , 1
                    , ''
            FROM      [proddb].[dbo].[coils] AS c WITH (NOLOCK)
            WHERE     c.coil_no = @sharedCoilNo;
        END

        COMMIT TRANSACTION;

        SET @logInfo = 'FlatWire_CompleteCoilOnSkid committed: ' + @coilAlpha
                     + ' -> shared ' + @sharedCoilNo
                     + ' on skid ' + @skidNo
                     + ', seq ' + CAST(@skidCoilSeqNo AS VARCHAR(3))
                     + ', IsComplete ' + CAST(@skidIsComplete AS VARCHAR(1));

        EXEC [dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_CompleteCoilOnSkid'
                                                , @table_name          = 'Committed'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Insert'
                                                , @user_id             = @userId;

        PRINT @logInfo;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;                            -- CreateSkid_MoveCutsOnSkid does NOT do this

        SELECT   @errNo        = ERROR_NUMBER()
               , @errSev       = ERROR_SEVERITY()
               , @errState     = ERROR_STATE()
               , @spObjectName = ISNULL(ERROR_PROCEDURE(), 'FlatWire_CompleteCoilOnSkid')
               , @errMessage   = 'FlatWire_CompleteCoilOnSkid rolled back for ' + ISNULL(@coilAlpha, 'NULL')
                               + ' (run ' + ISNULL(@runId, 'NULL') + '). Error: ' + ERROR_MESSAGE();

        INSERT INTO [dbo].[EventErrorLog]
                ( [ObjectName], [ErrNumber], [ErrSeverity], [ErrState]
                , [EventDescription], [StartTime], [UserName] )
        VALUES  ( @spObjectName, @errNo, @errSev, @errState
                , @errMessage, GETDATE(), SUSER_NAME() );

        EXEC [dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_CompleteCoilOnSkid'
                                                , @table_name          = 'Rolled back'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Error'
                                                , @user_id             = @userId;

        -- No shared row survives. The caller must surface this for operator retry and must NOT
        -- swallow it - see THE TRANSACTION BOUNDARY.
        THROW;
    END CATCH
END
GO

GRANT EXECUTE ON [dbo].[FlatWire_CompleteCoilOnSkid] TO [public] AS [dbo];
GO

/*==============================================================================================
  VERIFICATION - what a completed coil should look like in the shared schema
  ---------------------------------------------------------------------------------------------
  Replace the two variables and run after a test call. Every one of the nine objects must show a
  row; a missing coil_cost row is the failure most likely to go unnoticed (D7).

  DECLARE @shared CHAR(9) = 'R00421A', @skid CHAR(9) = '100421A01';

  SELECT 'coils'            AS [object], COUNT(*) AS [rows] FROM proddb..coils            WHERE coil_no       = @shared
  UNION ALL SELECT 'wip_coil_orders',    COUNT(*) FROM proddb..wip_coil_orders             WHERE coil_no       = @shared
  UNION ALL SELECT 'coil_gen_history',   COUNT(*) FROM united_db..coil_gen_history         WHERE child_coil_no = @shared
  UNION ALL SELECT 'coil_cost',          COUNT(*) FROM united_db..coil_cost                WHERE coil_no       = @shared
  UNION ALL SELECT 'coil_link_master',   COUNT(*) FROM united_db..coil_link_master_coil    WHERE coil_no       = @shared
  UNION ALL SELECT 'coil_slit_cuts',     COUNT(*) FROM SlitterDB..coil_slit_cuts           WHERE coil_no       = @shared
  UNION ALL SELECT 'wip_skid_coils',     COUNT(*) FROM proddb..wip_skid_coils              WHERE coil_no       = @shared
  UNION ALL SELECT 'wip_log',            COUNT(*) FROM proddb..wip_log_view                WHERE coil_no       = @shared
  UNION ALL SELECT 'wip_skids',          COUNT(*) FROM united_db..wip_skids                WHERE skid_no       = @skid;

  -- coil_link_master_coil proves the trigger fired single-row (C4) and that the 6-char root is
  -- meaningful (D5): master_coil_no should be the rod root, e.g. 'R00421'.
  SELECT * FROM united_db..coil_link_master_coil WHERE coil_no = @shared;

  -- Two coils, sequence 1 and 2, and the skid closed by the second.
  SELECT csc.coil_no, csc.skid_coil_seq_no, csc.cut_no, csc.under_review, ws.IsComplete, ws.skid_status
  FROM   SlitterDB..coil_slit_cuts AS csc
         JOIN united_db..wip_skids AS ws ON LTRIM(RTRIM(csc.skid_no)) = ws.skid_no
  WHERE  ws.skid_no = @skid
  ORDER BY csc.skid_coil_seq_no;
==============================================================================================*/
