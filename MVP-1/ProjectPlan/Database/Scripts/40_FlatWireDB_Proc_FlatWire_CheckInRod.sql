/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 40_FlatWireDB_Proc_FlatWire_CheckInRod.sql
  Object       : FlatWireDB.dbo.FlatWire_CheckInRod
  Target DBs   : FlatWireDB (procedure home - MOVED from united_db 26 Aug 2026, change [H];
                             the procedure is the ONLY thing that moved - every table below is
                             read and written exactly where it always was)
                 united_db  (dbo.routings, dbo.planning_routings,
                             dbo.mfg_sales_order_ref, dbo.planning_mfg_sales_order_ref,
                             dbo.routings_orders, dbo.order_remaining_operations, dbo.users)
                 proddb     (dbo.coils, dbo.wip_coil_orders, dbo.wip_coil_orders_hist,
                             dbo.wip_log_view)
                 CommonDB   (dbo.WIPStations, del_or_upd_wip_orders,
                             Logging_Information_In_Table)
                 wiplogdb   (dbo.wip_log, reached through proddb..wip_log_view)
  Last Updated : 2026-08-26
  Status       : Draft - transaction_name, coil_skid_status and the coils rod-row stamp
                 pending sign-off (see DECISIONS D3, D4, D5 and Q37-Q39)
  Story        : FW-220 (the shared half of FL1/FL3 rod check-in)
  Specification: MVP-1/ProjectPlan/Architecture/Integration.md Sec 8.0
                 MVP-1/ProjectPlan/Backend/tasks/FW-220.md
                 FR-077, FR-519 - FR-528

  PURPOSE
  -------
  Writes the SHARED half of one FL1/FL3 rod check-in, so that planning, scheduling, reporting,
  cost and yield keep working without regression.

  It is the opening bracket of the run. FlatWire_CompleteCoilOnSkid is the closing one, and the
  two are deliberately written to the same standard - read that header first if you have not.
  Most of what looks arbitrary in both is load-bearing.

  Called once per check-in by FlatWire.API's CheckInService, INSIDE the caller's transaction,
  AFTER the FlatWireDB entity writes and BEFORE the PLC push. See THE TRANSACTION BOUNDARY.

  It performs, in this order and for the reasons given in DECISIONS:

      1.  validate, and refuse before writing anything                          (C1-C9)
      2.  the retry short-circuit                                               (IDEMPOTENCY)
      3.  united_db..routings          <- copied from planning_routings         (D7, D8, C8)
      4.  mfg_sales_order_ref / routings_orders     <- the order references     (D12, D13)
      5.  proddb..wip_coil_orders      <- the reqsum entry                      (D12, C6)
      6.  wip_orders (via del_or_upd_wip_orders)    <- order material status
      7.  planning_routings.actual_start_date                                   (C7)
      8.  routings.actual_start_date / machine_idx / actual_weight_on           (C7)
      9.  CommonDB..WIPStations        <- claim the station                     (C1, C2)
      10. proddb..coils rod row        <- wip_station / badge / txn / rev_time  (D5)
      11. proddb..wip_log_view -> wiplogdb..wip_log   <- the WIP transaction    (D4, D6, C5)

  THE STEP ORDER IS ALSO THE LOCK ORDER, and it is not arbitrary - see CONCURRENCY.

  WHAT THIS PROCEDURE DELIBERATELY DOES NOT DO
  --------------------------------------------
    - It does not write coils.coil_status. D-32 (18 Aug 2026) cancelled FW-001/FW-002: the
      shared status vocabulary never gains 'INFLAT'. In-process flat wire state is
      FlatWireDB-local (Rod.Status / Spool.Status). Every write below lands in a column that
      already exists. D5 stamps the rod's OTHER columns, which is a different thing, and is what
      recovers most of what OI-111 lost.
    - It does not release CommonDB..WIPStations.CoilNo. That is FlatWire_ReleaseStation, and it
      belongs to RUN completion rather than check-in. Setting a station and never releasing it is
      the live defect OI-112 describes; the release is a sibling script, not an omission here.
    - It does not reverse itself. Pre-check-out reverses the reqsum, and that is
      FlatWire_ReverseReqsum (ARC Sec 10's closing line, OI-01's residual).
    - It does not touch traveler_rpts. The legacy check-in sets tr_prt_status = 'T' to mark a
      QUEUED PAPER traveler as taken. The flat wire traveler is fully digital and never prints
      (BR Sec 3), so there is nothing to mark. Coil and skid labels still print; the traveler
      does not.
    - It does not write coil_planned_rolls_queue, coil_process_queue, slit_process_queue,
      location_unit or spc_coils. Those are mill and slitter machine queues with no flat wire
      counterpart: flat wire's queue is FlatWireDB..RodStaging and its SPC is
      FlatWireDB..SpcCheckpoint.
    - It does not push PLC tags, broadcast, print or call anything slow. See CONCURRENCY.

  THE TRANSACTION BOUNDARY - read this before changing the error handling
  ----------------------------------------------------------------------
  *** THIS PROCEDURE DOES NOT OPEN A TRANSACTION. THE CALLER OWNS IT. ***

  That is the single structural difference from FlatWire_CompleteCoilOnSkid, and a reader who
  knows that procedure will look for BEGIN TRANSACTION here and not find it. It is deliberate.

  FlatWireDB is to be deployed on the SAME SQL Server instance as united_db / proddb / SlitterDB
  / CommonDB / wiplogdb (decision taken 18 Aug 2026). A single SqlConnection with a single
  SqlTransaction then spans FlatWireDB and the shared schema under the LOCAL transaction manager
  - no MSDTC, no distributed transaction, no linked server. So CheckInService does this:

  *** DEPLOYMENT PREREQUISITE, AND IT IS NOT YET MET. *** As of 19 Aug 2026 FlatWireDB exists
  only on (localdb)\MSSQLLocalDB, while the shared five are on DEVUAL-UADEV001\TEST1 - two
  different instances, verified by query. In THAT topology this procedure still runs, but the
  caller cannot hold one transaction across both halves and the design silently degrades to the
  two-transaction shape it exists to replace. Deploy FlatWireDB to the shared instance FIRST and
  prove it with the co-location query in 20_FlatWire_Grants.sql. The (localdb) target in CLAUDE.md's
  deploy snippet is a developer convenience and is not this topology.

      one SqlConnection, one SqlTransaction
        EF Core : Rod mirror upsert, FlatWireRun (Running), RodCheckin (PlcTagsPushed = 0),
                  SpcCheckpoint(PreRun) + SpcMeasurement, Rod.Status = 'INFLAT',
                  RodStaging -> CheckedIn
        Dapper  : EXEC FlatWireDB.dbo.FlatWire_CheckInRod   <-- THIS, called LAST
      COMMIT                        <- everything above, or nothing
      ---------------- the only real boundary ----------------
      PLCTagService.PushPassSchedule(...)

  Consequences, and all three matter:

    - The DATABASE half of check-in IS one ACID transaction. ARC Sec 10 is right that the whole
      operation is not, but the part that cannot be atomic is ONLY the OPC write. Do not describe
      the database half as compensating writes - it is a transaction, and saying otherwise costs
      the reader the one guarantee they actually have.
    - The PLC half is still compensation and must never be called a rollback (G16). On a failed
      push the caller issues ClearPayoffTags, then a SECOND small transaction marking the run
      Aborted, PlcTagsPushed = 0, and the staged row back to 'Staged'.
    - A THROW from here dooms the caller's transaction, which is what we want. There is no
      savepoint and no partial-success path. XACT_ABORT is ON and stays ON.

  IDEMPOTENCY
  -----------
  Check-in is NOT idempotent by contract - a second call for a line is 409 RUN_ALREADY_ACTIVE
  (API Sec 4.6), and that refusal belongs to the caller, not here. But this procedure CAN be
  re-entered by a caller retry after a doomed transaction, so it short-circuits on the state it
  would otherwise create: the station already holding this rod AND the routing step already
  started. Both are its own outputs, so no caller-held token is needed.

  *** Note the asymmetry with FlatWire_CompleteCoilOnSkid, which DOES need one. *** There, the
  minted coil alpha is unrecoverable from the shared schema, so the caller must hand it back
  through @expectedCoilNo. Here the evidence is in the shared schema already. The
  asymmetry is a consequence of what each procedure creates, not an oversight in either.

  CONCURRENCY - the cost of the atomicity, and how it is paid
  -----------------------------------------------------------
  Holding one transaction across both halves means write locks on routings, wip_coil_orders,
  WIPStations, coils and wip_log are held for the whole transaction instead of being released
  per statement - and the mills and slitters use those same tables. Four rules follow:

    1. CheckInService does every EF write FIRST and calls this procedure LAST, so the shared
       locks are held for the shortest possible window.
    2. Nothing slow runs inside the transaction. No PLC call, no HTTP, no SignalR broadcast, no
       label render. The PLC push is after COMMIT by design; keep everything else there too.
    3. ONE lock order, so this procedure can never deadlock against itself:
           routings -> wip_coil_orders -> planning_routings -> WIPStations -> coils -> wip_log
       That is the step order above. Do not reorder the steps for readability.
    4. UPDLOCK on the read that precedes each conditional write, so the check and the write take
       one lock rather than upgrading a shared lock to exclusive - the classic deadlock in this
       shape.

  Deadlock against LEGACY writers remains possible: PreCheckIn_PreCheckInCheckIn_Transaction
  touches coils, wip_stations, wip_log and routings in a DIFFERENT order and takes no meaningful
  locks. Flat wire and the mills do not contend for the same rows, but they do contend for the
  same pages on wip_log. Mitigation is rule 1 plus a caller-side retry on error 1205. Do not
  attempt to reorder legacy code.

  ISOLATION - MEASURED, not assumed  (DEVUAL-UADEV001\TEST1, 19 Aug 2026)
  -----------------------------------------------------------------------
  FlatWireDB runs READ_COMMITTED_SNAPSHOT ON and ALLOW_SNAPSHOT_ISOLATION ON
  (FlatWire_DDL_00_Database.sql:28-30). The shared databases are MIXED, and the split does NOT
  fall where the WITH (NOLOCK) hints scattered through the legacy code would lead you to guess:

      database      RCSI    ALLOW_SNAPSHOT_ISOLATION
      FlatWireDB     ON        ON
      united_db      ON        ON
      proddb         ON        ON
      wiplogdb       ON        ON
      CommonDB      OFF        ON      <-- the WIPStations claim, step 9
      SlitterDB     OFF       OFF      <-- coil_slit_cuts, at the other end of the run

  So one transaction gets SNAPSHOT reads for steps 3-8 and 10-11, and LOCKING reads for step 9.
  *** Step 9 is therefore the only step here that can block, or be blocked by, a legacy reader ***
  - which is a narrower and far more useful statement than "the shared half locks". It is also a
  single UPDATE of a single row whose lock was already taken at step 2b, so that window is
  already as small as it can be made.

  Re-measure per environment before trusting this. It is a DATABASE SETTING, not a schema fact,
  and nothing prevents it differing on uanet05. The query is in 20_FlatWire_Grants.sql.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  Every one verified against the scripted DDL. Each is load-bearing: get it wrong and the write
  fails at run time, or worse, silently does half the work.

  C1. CommonDB..WIPStations is the ONE physical station table. united_db..wip_stations and
      proddb..wip_stations are BOTH VIEWS OVER IT (10_CommonDB_Insert_WIPStations_FlatWire.sql:34-35)
      - one row, three names. The scripted united_db\Tables\wip_stations\CreateTable.sql in the
      database repo is a stale base-table definition that has since become a view; do not write
      through it and do not trust its column types.
      It carries two UNIQUE indexes and no declared primary key:
          wip_stations_k0  UNIQUE CLUSTERED    on WIPStation
          wip_stations_k1  UNIQUE NONCLUSTERED on CoilNo   <-- the non-obvious one
      Because k1 is a plain UNIQUE index, only ONE row may hold CoilNo = NULL, so an idle station
      cannot be parked as NULL. The established convention is that an idle station parks ITS OWN
      STATION NAME in CoilNo as a guaranteed-unique placeholder - verified 2026-07-28, all 78
      pre-existing rows have CoilNo = WIPStation. That is what FlatWire_ReleaseStation restores
      and what step 9 overwrites.

  C2. WIPStations weight columns are SMALLINT - max 32,767 lb. A rod is ~8,500 lb net /
      ~8,840 lb gross so it fits, but the bound is CHECKED below rather than left to wrap
      silently. AccumlatedScrapWeight = (gross - net) * -1 is NEGATIVE by design; that is the
      legacy convention, not a sign error.

  C3. proddb..coils.coil_no is char(9) and the rod alpha 'R#####' fits comfortably. Note this is
      the OPPOSITE of the problem at the other end of the run, where 'FW-#####-C##' is twelve
      characters and needs GenerateCoilAlpha (FlatWire_CompleteCoilOnSkid, C1/D5). Check-in has
      no alpha to mint - the rod already exists in the shared schema.

  C4. proddb..coils has a trigger, coils_iud_tg. It is SINGLE-ROW ONLY (@ins_count = 1, scalar
      SELECT @var = col FROM inserted) and it writes wip_log_view ONLY for
      transaction_name = 'STORCOIL' (insert) or 'UPD_COIL' with mill_order_no = 0 (update).
      Step 10 is an UPDATE of one row carrying NEITHER token, so the trigger writes no WIP log
      and step 11 must write it explicitly. Choosing 'CHECK IN' or 'UPD_COIL' here would either
      produce a duplicate log row or none at all - see D3.

  C5. proddb..wip_log_view is a pass-through VIEW: SELECT * FROM wiplogdb..wip_log WITH (NOLOCK).
      ALL 44 COLUMNS OF wip_log ARE NOT NULL AND NONE HAS A DEFAULT, so every insert supplies all
      44. There is no PK; the effective key is wip_log_k0, a UNIQUE CLUSTERED index on
      (wip_log_rev_time, seq_no) at SECOND granularity. The established way to avoid a collision
      is the spin loop in coils_iud_tg - bump rev_time by one second until the key is free - and
      this script uses it, correctly scoped to include seq_no. (The legacy original omits seq_no
      from the probe because it always writes 0.)

  C6. proddb..wip_coil_orders effective key is wip_coil_orders_k0, UNIQUE CLUSTERED on
      (coil_no, order_no, rel_letter). rel_letter is NULLABLE yet part of that key, so every
      comparison against it uses ISNULL on BOTH sides. coil_planned_wgt and smp_no are smallint.

  C7. planning_routings and routings treat '1800-01-01' as "unset" for actual_start_date -
      NOT NULL. Every legacy writer guards with
          ISNULL(actual_start_date,'1800-01-01 00:00:00:000') = '1800-01-01 00:00:00:000'
      and this script copies that predicate exactly.
      *** This is also what makes a PARTIAL-ROD RE-CHECK-IN (carry-forward, PRC007) a no-op on
      steps 7 and 8 rather than a false restart. *** That is correct behaviour: the step started
      when the rod first ran, and the second check-in does not restart it. It will look like a
      missing write if you do not know that.

  C8. routings has 94 columns and none of them has a useful default. The copy at step 3
      enumerates all 94 explicitly, in the same order as CommonDB.dbo.PreCheckIn_CopyPlanningData,
      with every override commented in place. Do not convert it to SELECT * - planning_routings
      and routings do not have identical column sets.

  C9. None of the target objects has a FOREIGN KEY, CHECK constraint or column DEFAULT. All
      integrity is in triggers and procedures. Nothing below can rely on the database refusing
      bad data, which is why step 1 is as long as it is.

  DECISIONS / ASSUMPTIONS  (confirm before running outside DEV)
  ------------------------------------------------------------
  D1. Scope is FL1 and FL3 - ROD check-in only. @lineId is validated against ('FL1','FL3').
      *** FL2 SPOOL CHECK-IN IS NOT HANDLED, AND THAT IS AN OPEN ITEM, NOT A CLOSED ONE. ***
      API Sec 4.6a says FL2 spool check-in has "the same shape as Sec 4.6" but then lists ONLY
      FlatWireDB writes. A spool has no proddb..coils row, so what FL2 owes to the reqsum,
      actual_start_date and the station claim is genuinely unspecified - and parking 'SP-00021'
      in WIPStations.CoilNo, a column every legacy reader treats as a coil number with no FK to
      stop it, needs an explicit answer rather than an inference. Registered as OI-115.

  D2. The caller owns the transaction. See THE TRANSACTION BOUNDARY. Asserted at step 0, not
      assumed, because a caller that forgets leaves the shared half committed and the local half
      not - the exact split-brain this design exists to remove.

  D3. coils.transaction_name / wip_log.transaction_name = 'FWCHKIN'.  [Q37 - CLIENT/IT INPUT REQUIRED]
      Seven characters, inside the varchar(8)/char(8) width of every column that carries a
      transaction token, and the SAME token in each, which is what makes the transaction
      traceable end to end.
      A NEW token, not a reused one, because the alternatives are worse: 'CHECK IN' would make
      flat wire indistinguishable from mill and slitter check-in in the WIP log - the same
      reasoning that made the other end of the run mint 'FWCOMPLT' rather than reuse 'CREATSKD'
      (FlatWire_CompleteCoilOnSkid, D4) - and 'UPD_COIL' would trip the coils_iud_tg branch at
      C4 and produce a SECOND, duplicate wip_log row.
      *** MUST be confirmed against every stored procedure and report that switches on
      transaction_name before this runs outside DEV. *** Change it in ONE place (@TransactionName).

  D4. wip_log.coil_skid_status = 'INROLL'.  [Q38 - CLIENT/IT INPUT REQUIRED]
      An EXISTING value, reused deliberately. The legacy check-in writes 'INROLL' for a mill and
      'INSLIT' for a slitter; 'INFLAT' would be a NEW entry in the shared status vocabulary,
      which is precisely what D-32 forbids. 'INROLL' is also the closest true statement - flat
      wire is rolled. The cost is that the WIP log cannot distinguish flat wire by STATUS; it
      distinguishes it by transaction_name (D3) and wip_station instead. Same trade the other end
      of the run makes with 'ONSKID' (Q35).

  D5. The rod's proddb..coils row is stamped - wip_station, wip_badge_no, transaction_name,
      coil_rev_time - and coil_status is LEFT ALONE.  [Q39 - CLIENT/IT INPUT REQUIRED]
      All four are columns that already exist carrying values of a kind they already carry, so
      D-32 holds: this is writing the shared schema as it stands, which INT Sec 8's opening
      sentence has always required.
      *** THIS RECOVERS MOST OF WHAT OI-111 LOST. *** When FW-002 was cancelled, nothing was left
      in the shared schema to show that a rod is on a flattening line. wip_station = 'FL1' says
      exactly that, without touching the status vocabulary. The residual is that an availability
      check keying on coil_status still cannot tell, and that residual is what OI-111 keeps.
      Confirm with IT that no report or availability check breaks on a coils row whose
      wip_station is a flat wire station.

  D6. The WIP log IS written at check-in. Neither FR-077 nor INT Sec 8 lists it, and this is
      therefore an ADDITION to the specified write set - the same class of absence FW-219 found
      at the other end, where eight shared objects were unwritten and none of them was named
      anywhere in the repository. Every legacy check-in writes one, and without it the shop floor
      transaction history has no record that a flat wire check-in ever happened.

  D7. Only planning_routings -> routings is copied. coil_mill_processing, coil_slitter_processing
      and slitter_head_setup are NOT.
      PreCheckIn_CopyPlanningData writes all four because a mill or slitter coil needs its
      processing rows. Whether flat wire owes coil_mill_processing a row is genuinely open - that
      table is the ROLLING processing record and flattening is rolling-like - and it affects mill
      reporting. Registered as OI-116. Copying it speculatively is the worse error: adding rows
      later is additive, removing wrong ones is not.

  D8. machine_idx comes from the CALLER (@machineIdx), validated against @lineId, and is NOT
      derived by the legacy op-letter CASE.
      PreCheckIn_CopyPlanningData picks machine_idx with a CASE over IsOtherOpLetter /
      IsRollingOpLetter and coil_width. *** THAT CASE RETURNS THE ELSE BRANCH FOR FLAT WIRE. ***
      IsRollingOpLetter matches only 'R', IsSlittingOpLetter only slitting letters and
      IsOtherOpLetter only the rest - the flattening letter 'F' matches NONE of them. Rather than
      add a fourth function to CommonDB that the mills and slitters would also load, the
      line-to-machine map is passed in and asserted: FL1 -> 125, FL3 -> 127 (INT Sec 8, fixed so
      DEV/TEST/PROD agree).

  D9. program_no is copied from planning_routings AS-IS, not resolved through
      Common_GetProgramNo. That helper exists to handle program_no = 171 (back anneal), and
      *** THE FLAT WIRE ROUTE HAS NO ANNEAL *** - FlatWire_CompleteCoilOnSkid writes
      furnace_operation = '' for the same reason. Calling an anneal resolver on a route with no
      furnace is how a wrong program number gets onto a routing step nobody is watching.

  D10. create_inits = 'adm', matching every other writer of this table, even though @badgeNo is
      available. The column is three characters and the legacy convention is uniform; a flat wire
      row carrying operator initials where all its neighbours carry 'adm' reads as data
      corruption to anyone querying the table. The operator IS recorded - on wip_badge_no
      (step 10), on the wip_log row (step 11) and on Logging_Information_In_Table.

  D11. @isSimulated = 1 is REFUSED, not written.
      FW-203's OPC feed simulator and FW-218's control surface can drive a complete run. If those
      runs reached wip_coil_orders, routings and wip_log, simulated production would be
      indistinguishable from real production in cost, yield and WIP history - and nothing
      downstream would ever know. The simulator exercises the FlatWireDB half only. If the
      trial's acceptance run genuinely needs the shared half, that is a TOPOLOGY answer (a DEV
      copy of the shared databases), not a flag in this procedure.

  D12. ONE order per call, and this is a known limitation rather than a settled requirement.
      PreCheckIn_Reqsum_Transaction builds a #Temp_Orders set and writes one wip_log row PER
      ORDER, because a mill coil routinely serves several. The flat wire contract does not:
      API Sec 4.6 sends a single orderId and FlatWireRun.OrderId is one column. So this takes one
      @orderNo/@relLetter and writes one wip_log row.
      *** G22 already records that the multi-order rod refusal is "knowingly wrong", pending
      OQ-73. *** The signature is shaped so the fix is additive: the two parameters become a
      table-valued parameter and steps 4, 5 and 11 loop. Do not assume single-order is settled.

  D13. The order-resolution CASCADE is preserved from PreCheckIn_Reqsum_Transaction, because a
      rod's order can legitimately live in any of four places depending on how planning got
      there: planning_mfg_sales_order_ref -> mfg_sales_order_ref -> routings_orders ->
      wip_coil_orders_hist. Dropping the fallbacks would work in DEV, where planning always
      writes the first, and fail on the shop floor.

  D14. Weights are INT parameters, bounds-checked, not silently truncated - the same treatment
      FlatWire_CompleteCoilOnSkid D14 gives them, and for the same reason: the legacy code
      declares SMALLINT locals and assigns into them.

  D15. smp_no defaults to 0, not 888. PreCheckIn_Reqsum_Transaction writes 0 on a fresh reqsum;
      888 is FlatWire_CompleteCoilOnSkid's fallback for an OUTPUT coil with no rod order row
      (Q36), which is a different situation. The two defaults are deliberately different and
      neither should be copied onto the other.

  ERROR NUMBERS - allocated in ranges so the caller can map them without string matching
  --------------------------------------------------------------------------------------
      52001         called outside a transaction   -> 500 (a programming error)
      52002 - 52019 validation                     -> 422 with the specific code
      52020 - 52029 state conflict                 -> 409
==============================================================================================*/

USE [FlatWireDB];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[FlatWire_CheckInRod]
      @rodAlpha              VARCHAR(9)                     -- proddb..coils.coil_no, e.g. R00041
    , @runId                 VARCHAR(20)                    -- FlatWireDB FlatWireRun.RunId, audit correlation
    , @lineId                VARCHAR(5)                     -- FL1 | FL3            (D1)
    , @station               VARCHAR(6)                     -- FL1 | FL3            (C1)
    , @machineIdx            INT                            -- 125 | 127            (D8)
    , @orderNo               INT
    , @relLetter             CHAR(1)
    , @mfgOrderNo            INT                            -- resolved routing step
    , @seqNo                 SMALLINT
    , @payoffPosition        INT                            -- 1 | 2
    , @badgeNo               INT
    , @netWeightLb           INT                            -- bounds-checked, never truncated (D14)
    , @grossWeightLb         INT
    , @opLetter              CHAR(1)    = 'F'               -- flattening           (D8)
    , @fallbackSmpNo         SMALLINT   = 0                 -- D15 - NOT 888
    , @isSimulated           BIT        = 0                 -- D11 - refused, not written
    , @routingsRowCopied     BIT        = NULL OUTPUT
    , @wipCoilOrdersWritten  BIT        = NULL OUTPUT       -- persisted on RodCheckin for the reversal
    , @priorStationCoilNo    CHAR(9)    = NULL OUTPUT       -- what the station held before
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;                                      -- stays ON; see THE TRANSACTION BOUNDARY

    /*------------------------------------------------------------------------------------------
      0. Constants, locals and the audit-trail entry
    ------------------------------------------------------------------------------------------*/
    DECLARE @TransactionName  CHAR(8)     = 'FWCHKIN'       -- D3 / Q37 - change here and nowhere else
          , @CoilSkidStatus   CHAR(6)     = 'INROLL'        -- D4 / Q38
          , @OpLetterFlat     CHAR(1)     = 'F'             -- D8; OI-27 notes GetMachineTypeFromOpLetter has no case for it
          , @UnsetDate        DATETIME    = '1800-01-01 00:00:00.000'   -- C7
          , @FarFutureDate    DATETIME    = '9999-12-31 00:00:00.000'   -- the other planning sentinel
          , @CreateInits      CHAR(3)     = 'adm'           -- D10
          , @SmallIntMax      INT         = 32767;          -- C2

    DECLARE @userId           INT
          , @logInfo          VARCHAR(8000)
          , @logTime          DATETIME
          , @logSeqNo         SMALLINT    = 0
          , @idleSentinel     CHAR(9)
          , @remainingOps     VARCHAR(20)
          , @issuedWeight     SMALLINT
          , @backToStock      BIT         = 0
          , @maxRoutingsOrderIdx INT
          , @resolvedRelLetter CHAR(1)
          , @errMessage       NVARCHAR(MAX)
          , @errNo            INT
          , @errSev           INT
          , @errState         INT
          , @spObjectName     SYSNAME;

    SET @routingsRowCopied    = 0;
    SET @wipCoilOrdersWritten = 0;

    SELECT @userId = userid
    FROM   [united_db].[dbo].[users] WITH (NOLOCK)
    WHERE  BadgeNo = @badgeNo;

    SET @logInfo = 'EXEC FlatWire_CheckInRod '
                 + ISNULL(@rodAlpha, 'NULL')             + ', '
                 + ISNULL(@runId, 'NULL')                + ', '
                 + ISNULL(@lineId, 'NULL')               + ', station='
                 + ISNULL(@station, 'NULL')              + ', payoff='
                 + ISNULL(CAST(@payoffPosition AS VARCHAR(2)), 'NULL') + ', order='
                 + ISNULL(CAST(@orderNo AS VARCHAR(10)), 'NULL')
                 + ISNULL(@relLetter, ' ')               + ', mfgOrder='
                 + ISNULL(CAST(@mfgOrderNo AS VARCHAR(10)), 'NULL') + '/'
                 + ISNULL(CAST(@seqNo AS VARCHAR(6)), 'NULL')       + ', net='
                 + ISNULL(CAST(@netWeightLb AS VARCHAR(10)), 'NULL');

    EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                            , @sp_name             = 'FlatWire_CheckInRod'
                                            , @table_name          = 'Entered into sp'
                                            , @log_info            = @logInfo
                                            , @operation_performed = 'Execute'
                                            , @user_id             = @userId;

    BEGIN TRY
        /*--------------------------------------------------------------------------------------
          1. Validate. Fail before writing anything, not half way through.
             C9: none of the target tables has a CHECK or FK, so every rule lives here.
        --------------------------------------------------------------------------------------*/

        -- 1a. The transaction assertion, FIRST, because everything after it assumes the caller
        --     is holding a transaction that a THROW will doom. See THE TRANSACTION BOUNDARY.
        IF @@TRANCOUNT = 0
            THROW 52001, 'FlatWire_CheckInRod must be called inside the caller''s transaction: the FlatWireDB and shared writes commit together. See THE TRANSACTION BOUNDARY (D2).', 1;

        SET @rodAlpha = LTRIM(RTRIM(ISNULL(@rodAlpha, '')));
        SET @lineId   = LTRIM(RTRIM(ISNULL(@lineId, '')));
        SET @station  = LTRIM(RTRIM(ISNULL(@station, '')));
        SET @idleSentinel = LEFT(@station + SPACE(9), 9);

        IF @isSimulated = 1
            THROW 52002, 'FlatWire_CheckInRod: refusing a simulated run. Simulated production must not reach wip_coil_orders, routings or wip_log - it would be indistinguishable from real production in cost and yield (D11).', 1;

        IF @lineId NOT IN ('FL1', 'FL3')
            THROW 52003, 'FlatWire_CheckInRod: @lineId must be FL1 or FL3. FL2 spool check-in is not handled here and its shared write set is undefined (D1, OI-115).', 1;

        IF (@lineId = 'FL1' AND @machineIdx <> 125)
        OR (@lineId = 'FL3' AND @machineIdx <> 127)
            THROW 52004, 'FlatWire_CheckInRod: @machineIdx does not match @lineId. FL1 is 125 and FL3 is 127, fixed so DEV/TEST/PROD agree (D8).', 1;

        IF @station <> @lineId
            THROW 52005, 'FlatWire_CheckInRod: @station must equal @lineId - there is one WIP station per line (10_CommonDB_Insert_WIPStations_FlatWire.sql D1). FL1PO is the PRE-check-in station and is not this one.', 1;

        IF @payoffPosition NOT IN (1, 2)
            THROW 52006, 'FlatWire_CheckInRod: @payoffPosition must be 1 or 2.', 1;

        IF @opLetter <> @OpLetterFlat
            THROW 52007, 'FlatWire_CheckInRod: @opLetter must be F. No legacy op-letter function matches it, which is why the machine index is passed in rather than derived (D8).', 1;

        IF @rodAlpha = ''
            THROW 52008, 'FlatWire_CheckInRod: @rodAlpha is required.', 1;

        IF ISNULL(@orderNo, 0) <= 0
            THROW 52009, 'FlatWire_CheckInRod: @orderNo is required - the reqsum entry and the WIP log row both key on it.', 1;

        IF ISNULL(@mfgOrderNo, 0) <= 0
            THROW 52010, 'FlatWire_CheckInRod: @mfgOrderNo is required - it identifies the routing step being started.', 1;

        IF ISNULL(@netWeightLb, 0) <= 0 OR ISNULL(@grossWeightLb, 0) <= 0
            THROW 52011, 'FlatWire_CheckInRod: net and gross weight must both be greater than zero.', 1;

        IF @grossWeightLb < @netWeightLb
            THROW 52012, 'FlatWire_CheckInRod: gross weight is below net weight, which would make the scrap accumulator positive (C2).', 1;

        -- C2: the WIPStations weight columns are smallint. Refuse rather than wrap (D14).
        IF @netWeightLb > @SmallIntMax OR @grossWeightLb > @SmallIntMax
            THROW 52013, 'FlatWire_CheckInRod: weight exceeds the smallint bound on CommonDB..WIPStations (C2). Refusing rather than truncating.', 1;

        -- The rod must exist in the shared coils table: step 10 stamps it and step 11 reads it.
        IF NOT EXISTS (SELECT 1 FROM [proddb].[dbo].[coils] WITH (NOLOCK) WHERE coil_no = @rodAlpha)
            THROW 52014, 'FlatWire_CheckInRod: the rod has no proddb..coils row. Rod receipt is upstream of check-in and must have happened first.', 1;

        -- The station must have been seeded. 10_CommonDB_Insert_WIPStations_FlatWire.sql creates
        -- FL1/FL2/FL3/FL1PO/FWPACK; without it step 9 updates zero rows and says nothing.
        IF NOT EXISTS (SELECT 1 FROM [CommonDB].[dbo].[WIPStations] WITH (NOLOCK)
                       WHERE LTRIM(RTRIM(WIPStation)) = @station)
            THROW 52015, 'FlatWire_CheckInRod: the WIP station does not exist. Run 10_CommonDB_Insert_WIPStations_FlatWire.sql before this procedure.', 1;

        -- The planning step must exist somewhere, or there is nothing to copy and nothing to start.
        IF NOT EXISTS (SELECT 1 FROM [united_db].[dbo].[planning_routings] WITH (NOLOCK)
                       WHERE coil_no = @rodAlpha AND mfg_order_no = @mfgOrderNo AND seq_no = @seqNo)
           AND NOT EXISTS (SELECT 1 FROM [united_db].[dbo].[routings] WITH (NOLOCK)
                           WHERE coil_no = @rodAlpha AND mfg_order_no = @mfgOrderNo AND seq_no = @seqNo)
            THROW 52016, 'FlatWire_CheckInRod: no planning_routings or routings row for this rod, order and sequence. The step must be planned before it can be started.', 1;

        /*--------------------------------------------------------------------------------------
          2. The retry short-circuit. See IDEMPOTENCY.
             Both tests are this procedure''s own outputs, which is why no caller token is needed.
        --------------------------------------------------------------------------------------*/
        IF EXISTS (SELECT 1 FROM [CommonDB].[dbo].[WIPStations] WITH (NOLOCK)
                   WHERE LTRIM(RTRIM(WIPStation)) = @station
                     AND LTRIM(RTRIM(ISNULL(CoilNo, ''))) = @rodAlpha)
           AND EXISTS (SELECT 1 FROM [united_db].[dbo].[routings] WITH (NOLOCK)
                       WHERE coil_no = @rodAlpha
                         AND mfg_order_no = @mfgOrderNo
                         AND seq_no = @seqNo
                         AND ISNULL(actual_start_date, @UnsetDate) <> @UnsetDate)
        BEGIN
            SELECT @priorStationCoilNo = @rodAlpha;

            PRINT 'FlatWire_CheckInRod: ' + @rodAlpha
                + ' is already checked in at ' + @station + ' - nothing written (idempotent retry).';

            EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                    , @sp_name             = 'FlatWire_CheckInRod'
                                                    , @table_name          = 'Idempotent retry - no write'
                                                    , @log_info            = @logInfo
                                                    , @operation_performed = 'Skip'
                                                    , @user_id             = @userId;
            RETURN 0;
        END

        /*--------------------------------------------------------------------------------------
          2b. State conflict: the station is held by a DIFFERENT rod.
              wip_stations_k1 is UNIQUE on CoilNo (C1), so this would not corrupt anything - but
              silently displacing another rod''s claim is worse than refusing. OI-112 is exactly
              the case where the previous rod was never released.
        --------------------------------------------------------------------------------------*/
        SELECT @priorStationCoilNo = LTRIM(RTRIM(ISNULL(CoilNo, '')))
        FROM   [CommonDB].[dbo].[WIPStations] WITH (UPDLOCK, HOLDLOCK)
        WHERE  LTRIM(RTRIM(WIPStation)) = @station;

        IF @priorStationCoilNo NOT IN ('', @station, @rodAlpha)
            THROW 52020, 'FlatWire_CheckInRod: the station is still claimed by another rod. Release it with FlatWire_ReleaseStation first (OI-112).', 1;

        -- The same rod may not be checked in at a different station: k1 would refuse it, but a
        -- named error beats a constraint violation the caller has to parse.
        IF EXISTS (SELECT 1 FROM [CommonDB].[dbo].[WIPStations] WITH (NOLOCK)
                   WHERE LTRIM(RTRIM(ISNULL(CoilNo, ''))) = @rodAlpha
                     AND LTRIM(RTRIM(WIPStation)) <> @station)
            THROW 52021, 'FlatWire_CheckInRod: this rod is already checked in at another station (wip_stations_k1 is UNIQUE on CoilNo - C1).', 1;

        /*--------------------------------------------------------------------------------------
          3. planning_routings -> routings.  (C8, D7, D8, D9)
             All 94 columns, in PreCheckIn_CopyPlanningData order, overrides commented in place.
             Only when the shopfloor row does not already exist - a re-check-in must not duplicate
             the step.
        --------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1 FROM [united_db].[dbo].[routings] WITH (UPDLOCK, HOLDLOCK)
                       WHERE coil_no = @rodAlpha AND mfg_order_no = @mfgOrderNo AND seq_no = @seqNo)
        BEGIN
            INSERT INTO [united_db].[dbo].[routings]
                    ( mfg_order_no,          coil_no,               seq_no
                    , op_letter,             machine_idx,           machine_group
                    , item_template_idx,     item_version,          nominal_gauge
                    , gauge_pos_tol,         gauge_neg_tol,         actual_gauge_rolled
                    , target_temper,         actual_temper,         schedule_start_date
                    , actual_start_date,     actual_completed,      std_run_time
                    , actual_run_time,       setup_time_std,        actual_setup_time
                    , actual_labor_cost,     std_labor_cost,        std_material_loss
                    , actual_material_loss,  price_lb_std,          price_lb_hybrid
                    , conver_lb_std,         conver_ld_hybrid,      std_value
                    , hybrid_value,          conv_std_value,        conv_hybrid
                    , weight_on,             weight_off,            tail_loss
                    , wip_rej_no,            side_scrap,            mo_arbor
                    , enter_queue,           delay_reason,          total_delay_time
                    , rejected,              spc_slit_seq_no,       special_instruct
                    , op_comment,            stop_processing,       produced_coil
                    , machine_manning,       plate_no,              coil_surface_finish
                    , create_time,           create_inits,          rev_time
                    , rev_inits,             number_of_stops,       number_of_cuts
                    , coil_start_gauge,      coil_width,            remaining_operations
                    , std_handling_time,     actual_handling_time,  delay_run_time
                    , delay_setup_time,      delay_handling_time,   late_start_date
                    , nonprod_setup_time,    nonprod_handling_time, core_id
                    , plastic_id,            monitor_id,            sample_type
                    , slitter_setup_no,      arbor_id,              spc_doc_id
                    , spc_id,                operational_doc,       trim_loss_inch
                    , planned_scrap,         periodicity,           program_no
                    , unwind,                camber,                paint_code_in
                    , paint_code_out,        level_idx,             cleaning_idx
                    , trim_needed,           reported_machine_idx,  back_to_stock
                    , batch_no,              no_of_cuts,            schedule_end_date
                    , cooling_room )
            SELECT    pr.mfg_order_no                                  -- mfg_order_no
                    , pr.coil_no                                       -- coil_no
                    , pr.seq_no                                        -- seq_no
                    , pr.op_letter                                     -- op_letter
                    , @machineIdx                                      -- machine_idx        OVERRIDE (D8)
                    , pr.machine_group                                 -- machine_group
                    , pr.item_template_idx                             -- item_template_idx
                    , pr.item_version                                  -- item_version
                    , pr.nominal_gauge                                 -- nominal_gauge
                    , pr.gauge_pos_tol                                 -- gauge_pos_tol
                    , pr.gauge_neg_tol                                 -- gauge_neg_tol
                    , ''                                               -- actual_gauge_rolled  not yet rolled
                    , pr.target_temper                                 -- target_temper
                    , ''                                               -- actual_temper        not yet achieved
                    , CASE pr.schedule_start_date                      -- schedule_start_date  sentinels -> NULL
                          WHEN @FarFutureDate THEN NULL
                          WHEN @UnsetDate     THEN NULL
                          ELSE pr.schedule_start_date
                      END
                    , NULL                                             -- actual_start_date    set at step 8 (C7)
                    , NULL                                             -- actual_completed
                    , pr.std_run_time                                  -- std_run_time
                    , '0'                                              -- actual_run_time
                    , pr.setup_time_std                                -- setup_time_std
                    , '0'                                              -- actual_setup_time
                    , '0'                                              -- actual_labor_cost
                    , '0'                                              -- std_labor_cost
                    , pr.std_material_loss                             -- std_material_loss
                    , NULL                                             -- actual_material_loss
                    , NULL                                             -- price_lb_std
                    , NULL                                             -- price_lb_hybrid
                    , NULL                                             -- conver_lb_std
                    , NULL                                             -- conver_ld_hybrid
                    , NULL                                             -- std_value
                    , NULL                                             -- hybrid_value
                    , NULL                                             -- conv_std_value
                    , NULL                                             -- conv_hybrid
                    , pr.weight_on                                     -- weight_on
                    , pr.weight_off                                    -- weight_off
                    , pr.tail_loss                                     -- tail_loss
                    , NULL                                             -- wip_rej_no
                    , pr.side_scrap                                    -- side_scrap
                    , pr.mo_arbor                                      -- mo_arbor
                    , NULL                                             -- enter_queue
                    , NULL                                             -- delay_reason
                    , NULL                                             -- total_delay_time
                    , pr.rejected                                      -- rejected
                    , '0'                                              -- spc_slit_seq_no
                    , ''                                               -- special_instruct
                    , NULL                                             -- op_comment
                    , pr.stop_processing                               -- stop_processing
                    , NULL                                             -- produced_coil
                    , NULL                                             -- machine_manning
                    , NULL                                             -- plate_no             flat wire has no plates
                    , NULL                                             -- coil_surface_finish
                    , GETDATE()                                        -- create_time
                    , @CreateInits                                     -- create_inits         (D10)
                    , NULL                                             -- rev_time
                    , NULL                                             -- rev_inits
                    , pr.number_of_stops                               -- number_of_stops
                    , pr.number_of_cuts                                -- number_of_cuts
                    , pr.coil_start_gauge                              -- coil_start_gauge
                    , pr.coil_width                                    -- coil_width
                    , pr.remaining_operations                          -- remaining_operations
                    , NULL                                             -- std_handling_time
                    , NULL                                             -- actual_handling_time
                    , NULL                                             -- delay_run_time
                    , NULL                                             -- delay_setup_time
                    , NULL                                             -- delay_handling_time
                    , pr.late_start_date                               -- late_start_date
                    , NULL                                             -- nonprod_setup_time
                    , NULL                                             -- nonprod_handling_time
                    , ISNULL(pr.core_id, 19)                           -- core_id              steel-core default, per legacy
                    , CASE pr.plastic_id                               -- plastic_id
                          WHEN 1052 THEN NULL
                          WHEN   -1 THEN NULL
                          ELSE 1
                      END
                    , NULL                                             -- monitor_id
                    , NULL                                             -- sample_type
                    , pr.slitter_setup_no                              -- slitter_setup_no     NULL for flat wire
                    , pr.arbor_id                                      -- arbor_id
                    , NULL                                             -- spc_doc_id
                    , NULL                                             -- spc_id
                    , NULL                                             -- operational_doc
                    , pr.trim_loss_inch                                -- trim_loss_inch
                    , pr.planned_scrap                                 -- planned_scrap
                    , pr.periodicity                                   -- periodicity
                    , pr.program_no                                    -- program_no           AS-IS (D9) - no anneal
                    , pr.unwind                                        -- unwind
                    , pr.camber                                        -- camber
                    , pr.paint_code_in                                 -- paint_code_in
                    , pr.paint_code_out                                -- paint_code_out
                    , pr.level_idx                                     -- level_idx
                    , pr.cleaning_idx                                  -- cleaning_idx
                    , pr.trim_needed                                   -- trim_needed
                    , pr.reported_machine_idx                          -- reported_machine_idx
                    , pr.back_to_stock                                 -- back_to_stock
                    , pr.batch_no                                      -- batch_no
                    , pr.no_of_cuts                                    -- no_of_cuts
                    , CASE pr.schedule_end_date                        -- schedule_end_date    sentinels -> NULL
                          WHEN @FarFutureDate THEN NULL
                          WHEN @UnsetDate     THEN NULL
                          ELSE pr.schedule_end_date
                      END
                    , pr.cooling_room                                  -- cooling_room
            FROM      [united_db].[dbo].[planning_routings] AS pr WITH (NOLOCK)
            WHERE     pr.coil_no      = @rodAlpha
              AND     pr.mfg_order_no = @mfgOrderNo
              AND     pr.seq_no       = @seqNo;

            IF @@ROWCOUNT <> 1
                THROW 52017, 'FlatWire_CheckInRod: expected exactly one routings row to be copied from planning_routings.', 1;

            SET @routingsRowCopied = 1;

            SET @logInfo = 'Copied planning_routings -> routings for ' + @rodAlpha
                         + ' mfgOrder ' + CAST(@mfgOrderNo AS VARCHAR(10))
                         + ' seq ' + CAST(@seqNo AS VARCHAR(6))
                         + ' machine_idx ' + CAST(@machineIdx AS VARCHAR(6));
            EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                    , @sp_name             = 'FlatWire_CheckInRod'
                                                    , @table_name          = 'routings'
                                                    , @log_info            = @logInfo
                                                    , @operation_performed = 'Insert'
                                                    , @user_id             = @userId;
        END

        -- back_to_stock drives the planned-operations suffix at step 5; read it once, here,
        -- from the row that now certainly exists.
        SELECT @backToStock = ISNULL(back_to_stock, 0)
        FROM   [united_db].[dbo].[routings] WITH (NOLOCK)
        WHERE  coil_no = @rodAlpha AND mfg_order_no = @mfgOrderNo AND seq_no = @seqNo;

        /*--------------------------------------------------------------------------------------
          4. The order references.  (D12, D13)
             mfg_sales_order_ref is copied from its planning mirror; routings_orders links the
             order to this routing step. Both are guarded, so a re-check-in is a no-op.
        --------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1 FROM [united_db].[dbo].[mfg_sales_order_ref] WITH (UPDLOCK, HOLDLOCK)
                       WHERE coil_no = @rodAlpha AND mfg_order_no = @mfgOrderNo
                         AND order_no = @orderNo
                         AND ISNULL(rel_letter, '') = ISNULL(@relLetter, ''))
        BEGIN
            INSERT INTO [united_db].[dbo].[mfg_sales_order_ref]
                    ( mfg_order_no, order_no, rel_letter, item_template_idx, coil_no
                    , reqsum_coil_no, item_version, mfg_order_status, issued_weight )
            SELECT    pmsor.mfg_order_no
                    , pmsor.order_no
                    , pmsor.rel_letter
                    , pmsor.item_template_idx
                    , pmsor.coil_no
                    , pmsor.reqsum_coil_no
                    , pmsor.item_version
                    , pmsor.mfg_order_status
                    , pmsor.issued_weight
            FROM      [united_db].[dbo].[planning_mfg_sales_order_ref] AS pmsor WITH (NOLOCK)
            WHERE     pmsor.coil_no      = @rodAlpha
              AND     pmsor.mfg_order_no = @mfgOrderNo
              AND     pmsor.order_no     = @orderNo
              AND     ISNULL(pmsor.rel_letter, '') = ISNULL(@relLetter, '');
        END

        IF NOT EXISTS (SELECT 1 FROM [united_db].[dbo].[routings_orders] WITH (UPDLOCK, HOLDLOCK)
                       WHERE mfg_order_no = @mfgOrderNo AND coil_no = @rodAlpha
                         AND seq_no = @seqNo AND order_no = @orderNo
                         AND ISNULL(rel_letter, '') = ISNULL(@relLetter, ''))
        BEGIN
            -- routings_orders_idx is not an IDENTITY; the legacy proc allocates MAX+1 the same way.
            SELECT @maxRoutingsOrderIdx = ISNULL(MAX(routings_orders_idx), 0) + 1
            FROM   [united_db].[dbo].[routings_orders] WITH (UPDLOCK, HOLDLOCK);

            INSERT INTO [united_db].[dbo].[routings_orders]
                    ( routings_orders_idx, mfg_order_no, coil_no, seq_no, order_no, rel_letter
                    , created_by, created_on, updated_by, update_on )
            VALUES  ( @maxRoutingsOrderIdx, @mfgOrderNo, @rodAlpha, @seqNo, @orderNo, @relLetter
                    , @badgeNo, GETDATE(), NULL, NULL );
        END

        /*--------------------------------------------------------------------------------------
          5. proddb..wip_coil_orders - the reqsum entry.  (C6, D12, D13, D15)
             planned_operations follows PreCheckIn_Reqsum_Transaction''s suffix rules exactly;
             they encode what still has to happen to the material and downstream reads them.
        --------------------------------------------------------------------------------------*/
        SELECT @remainingOps = remaining_operations
        FROM   [united_db].[dbo].[order_remaining_operations] WITH (NOLOCK)
        WHERE  coil_no = @rodAlpha AND order_no = @orderNo AND release = @relLetter;

        SET @remainingOps = LTRIM(RTRIM(ISNULL(@remainingOps, '')));

        IF @remainingOps <> ''
        BEGIN
            IF RIGHT(@remainingOps, 1) = 'A' AND @backToStock = 0
                SET @remainingOps = @remainingOps + 'IP';
            ELSE IF RIGHT(@remainingOps, 1) IN ('S', 'A') AND @backToStock = 1
                SET @remainingOps = @remainingOps + 'W';
            ELSE IF RIGHT(@remainingOps, 1) = 'S' AND @backToStock = 0
                SET @remainingOps = @remainingOps + 'P';
        END
        ELSE
            SET @remainingOps = 'P';                        -- the legacy fallback shape

        -- The issued weight cascade (D13). Four sources, in the legacy order.
        SELECT TOP (1) @issuedWeight = issued_weight
        FROM   [united_db].[dbo].[planning_mfg_sales_order_ref] WITH (NOLOCK)
        WHERE  mfg_order_no = @mfgOrderNo AND coil_no = @rodAlpha
          AND  order_no = @orderNo AND ISNULL(rel_letter, '') = ISNULL(@relLetter, '');

        IF @issuedWeight IS NULL
            SELECT TOP (1) @issuedWeight = issued_weight
            FROM   [united_db].[dbo].[mfg_sales_order_ref] WITH (NOLOCK)
            WHERE  mfg_order_no = @mfgOrderNo AND coil_no = @rodAlpha
              AND  order_no = @orderNo AND ISNULL(rel_letter, '') = ISNULL(@relLetter, '');

        IF @issuedWeight IS NULL
            SELECT TOP (1) @issuedWeight = coil_planned_wgt
            FROM   [proddb].[dbo].[wip_coil_orders_hist] WITH (NOLOCK)
            WHERE  coil_no = @rodAlpha AND order_no = @orderNo
              AND  ISNULL(rel_letter, '') = ISNULL(@relLetter, '')
            ORDER BY date_deleted DESC;

        SET @issuedWeight = ISNULL(@issuedWeight, 0);

        IF NOT EXISTS (SELECT 1 FROM [proddb].[dbo].[wip_coil_orders] WITH (UPDLOCK, HOLDLOCK)
                       WHERE coil_no = @rodAlpha AND order_no = @orderNo
                         AND ISNULL(rel_letter, '') = ISNULL(@relLetter, ''))
        BEGIN
            INSERT INTO [proddb].[dbo].[wip_coil_orders]
                    ( coil_no, order_no, rel_letter, coil_planned_wgt, smp_no, planned_operations )
            VALUES  ( @rodAlpha, @orderNo, @relLetter, @issuedWeight, @fallbackSmpNo, @remainingOps );

            SET @wipCoilOrdersWritten = 1;                  -- the caller persists this on RodCheckin
        END

        /*--------------------------------------------------------------------------------------
          6. wip_orders - the order''s material status.
             Returns a result set, so it is captured rather than emitted to the caller: this
             procedure''s only result set is its OUTPUT parameters.
        --------------------------------------------------------------------------------------*/
        CREATE TABLE #FlatWireWipOrderResult ( Result VARCHAR(10) );

        INSERT INTO #FlatWireWipOrderResult ( Result )
        EXEC [CommonDB].[dbo].[del_or_upd_wip_orders] @orderNo, @relLetter;

        DROP TABLE #FlatWireWipOrderResult;

        /*--------------------------------------------------------------------------------------
          7. planning_routings.actual_start_date.  (C7)
             The '1800-01-01' guard means a partial-rod re-check-in is a NO-OP here, not a false
             restart. That is correct - see C7.
        --------------------------------------------------------------------------------------*/
        UPDATE  [united_db].[dbo].[planning_routings] WITH (ROWLOCK)
        SET     actual_start_date = GETDATE()
        WHERE   LTRIM(RTRIM(coil_no)) = @rodAlpha
          AND   mfg_order_no = @mfgOrderNo
          AND   seq_no = @seqNo
          AND   ISNULL(actual_start_date, @UnsetDate) = @UnsetDate;

        /*--------------------------------------------------------------------------------------
          8. routings.actual_start_date, machine_idx and actual_weight_on.  (C7, D8)
             actual_weight_on is the CHECK-IN gross weight, matching
             PreCheckIn_PreCheckInCheckIn_Transaction.
        --------------------------------------------------------------------------------------*/
        UPDATE  [united_db].[dbo].[routings] WITH (ROWLOCK)
        SET     actual_start_date = GETDATE()
              , machine_idx       = @machineIdx
              , actual_weight_on  = @grossWeightLb
        WHERE   LTRIM(RTRIM(coil_no)) = @rodAlpha
          AND   mfg_order_no = @mfgOrderNo
          AND   seq_no = @seqNo
          AND   ISNULL(actual_start_date, @UnsetDate) = @UnsetDate;

        /*--------------------------------------------------------------------------------------
          9. CommonDB..WIPStations - claim the station.  (C1, C2)
             The row was locked at step 2b, so this cannot race.
             AccumlatedScrapWeight is NEGATIVE by legacy convention (C2).
        --------------------------------------------------------------------------------------*/
        UPDATE  [CommonDB].[dbo].[WIPStations]
        SET     CoilNo                  = @rodAlpha
              , ZeroPassFlag            = 'Y'
              , FirstBuildupFlag        = 'Y'
              , CoilCheckinNetWeight    = @netWeightLb
              , CoilCheckinGrossWeight  = @grossWeightLb
              , CoilGrossMinusTagWeight = @netWeightLb
              , AccumlatedScrapWeight   = ((@grossWeightLb - @netWeightLb) * -1)
              , AccumlatedTrimWeight    = 0
        WHERE   LTRIM(RTRIM(WIPStation)) = @station;

        IF @@ROWCOUNT <> 1
            THROW 52018, 'FlatWire_CheckInRod: expected exactly one CommonDB..WIPStations row to be claimed (C1).', 1;

        /*--------------------------------------------------------------------------------------
          10. proddb..coils - stamp the ROD row.  (C4, D5)
              coil_status is NOT touched: D-32. Every column here already exists and already
              carries values of this kind, which is what makes wip_station = 'FL1' legal and what
              recovers most of what OI-111 lost.
        --------------------------------------------------------------------------------------*/
        UPDATE  [proddb].[dbo].[coils] WITH (ROWLOCK)
        SET     wip_station      = @station
              , wip_badge_no     = @badgeNo
              , transaction_name = @TransactionName          -- D3 / Q37
              , coil_rev_time    = GETDATE()
        WHERE   coil_no = @rodAlpha;

        IF @@ROWCOUNT <> 1
            THROW 52019, 'FlatWire_CheckInRod: expected exactly one proddb..coils row to be stamped (C4 - the trigger is single-row only).', 1;

        /*--------------------------------------------------------------------------------------
          11. The WIP log.  (C5, D4, D6, D12)
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
                ( wip_log_rev_time,   seq_no,              order_no
                , rel_letter,         coil_no,             skid_no
                , plate_no,           wip_rej_no,          wip_badge_no
                , transaction_name,   wip_station,         coil_skid_status
                , coil_alloy,         coil_temper,         coil_gauge
                , coil_width,         coil_net_width,      coil_id_insert
                , coil_id,            coil_net_id,         coil_od
                , coil_net_od,        coil_skid_net_wgt,   pallet_wgt
                , coil_skid_gross_wgt, coil_cond_code,     coil_q_code
                , coil_surface_finish, storage_section,    storage_loc_col
                , storage_loc_row,    storage_loc_height,  smp_no
                , planned_wgt,        furnace_operation,   furnace_no
                , furnace_program_no, furnace_temperature, start_coil_temper
                , start_coil_gauge,   no_of_passes,        no_of_cuts_setup
                , no_of_cuts,         partial_complete_code )
        SELECT    @logTime
                , @logSeqNo
                , @orderNo
                , @relLetter
                , @rodAlpha
                , '         '                               -- skid_no: no skid at check-in
                , '  '                                      -- plate_no char(2): flat wire has no plates
                , 0                                         -- wip_rej_no
                , @badgeNo
                , @TransactionName                          -- D3 / Q37
                , @station
                , @CoilSkidStatus                           -- D4 / Q38 - existing value, reused
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
                , 0                                         -- pallet_wgt: no pallet at check-in
                , @grossWeightLb
                , ISNULL(c.coil_surface_finish_cond_code, 0)
                , ISNULL(c.coil_q_code, '')
                , ISNULL(c.coil_surface_finish, '')
                , ''                                        -- storage_section: on the line, not in storage
                , 0
                , 0
                , 0
                , ISNULL(wco.smp_no, 0)
                , ISNULL(wco.coil_planned_wgt, 0)
                , ''                                        -- furnace_operation: no anneal on this route (D9)
                , 0
                , 0
                , 0
                , ''                                        -- start_coil_temper
                , 0                                         -- start_coil_gauge
                , 1                                         -- no_of_passes
                , 0                                         -- no_of_cuts_setup
                , 1                                         -- no_of_cuts
                , ''                                        -- partial_complete_code
        FROM      [proddb].[dbo].[coils] AS c WITH (NOLOCK)
                  LEFT JOIN [proddb].[dbo].[wip_coil_orders] AS wco WITH (NOLOCK)
                         ON wco.coil_no  = c.coil_no
                        AND wco.order_no = @orderNo
                        AND ISNULL(wco.rel_letter, '') = ISNULL(@relLetter, '')
        WHERE     c.coil_no = @rodAlpha;

        /*--------------------------------------------------------------------------------------
          12. Done. NO COMMIT - the caller owns the transaction (D2).
        --------------------------------------------------------------------------------------*/
        SET @logInfo = 'FlatWire_CheckInRod applied: ' + @rodAlpha
                     + ' -> station ' + @station
                     + ', run ' + ISNULL(@runId, 'NULL')
                     + ', routingsCopied ' + CAST(@routingsRowCopied AS VARCHAR(1))
                     + ', reqsumWritten ' + CAST(@wipCoilOrdersWritten AS VARCHAR(1))
                     + ' (caller still to commit)';

        EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_CheckInRod'
                                                , @table_name          = 'Applied - caller to commit'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Insert'
                                                , @user_id             = @userId;

        PRINT @logInfo;
        RETURN 0;
    END TRY
    BEGIN CATCH
        /*--------------------------------------------------------------------------------------
          *** NO ROLLBACK HERE. THE CALLER OWNS THE TRANSACTION. ***
          XACT_ABORT is ON, so the caller''s transaction is already doomed and the THROW below
          carries the reason out. Rolling back here would discard the caller''s FlatWireDB writes
          without the caller ever knowing why - the exact failure this design removes.
          FlatWire_CompleteCoilOnSkid DOES roll back, because it owns its transaction. That
          difference is the whole point; do not make the two procedures look alike.
        --------------------------------------------------------------------------------------*/
        SELECT   @errNo        = ERROR_NUMBER()
               , @errSev       = ERROR_SEVERITY()
               , @errState     = ERROR_STATE()
               , @spObjectName = ISNULL(ERROR_PROCEDURE(), 'FlatWire_CheckInRod')
               , @errMessage   = 'FlatWire_CheckInRod failed for ' + ISNULL(@rodAlpha, 'NULL')
                               + ' (run ' + ISNULL(@runId, 'NULL') + '). Error: ' + ERROR_MESSAGE();

        INSERT INTO [united_db].[dbo].[EventErrorLog]
                ( [ObjectName], [ErrNumber], [ErrSeverity], [ErrState]
                , [EventDescription], [StartTime], [UserName] )
        VALUES  ( @spObjectName, @errNo, @errSev, @errState
                , @errMessage, GETDATE(), SUSER_NAME() );

        EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_CheckInRod'
                                                , @table_name          = 'Failed - caller transaction doomed'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Error'
                                                , @user_id             = @userId;

        -- The caller must surface this for operator retry and must NOT swallow it.
        THROW;
    END CATCH
END
GO

GRANT EXECUTE ON [dbo].[FlatWire_CheckInRod] TO [public] AS [dbo];
GO

/*==============================================================================================
  VERIFICATION - what a checked-in rod should look like in the shared schema
  ---------------------------------------------------------------------------------------------
  Replace the variables and run after a test call. Every object must show a row; the WIPStations
  claim and the coils stamp are the two most likely to be silently missing.

  DECLARE @rod CHAR(9) = 'R00041', @station VARCHAR(6) = 'FL1',
          @mfgOrder INT = 90001,   @seq SMALLINT = 0,  @order INT = 421;

  SELECT 'routings'          AS [object], COUNT(*) AS [rows] FROM united_db..routings          WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq
  UNION ALL SELECT 'planning_routings',   COUNT(*) FROM united_db..planning_routings            WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq
  UNION ALL SELECT 'mfg_sales_order_ref', COUNT(*) FROM united_db..mfg_sales_order_ref          WHERE coil_no = @rod AND mfg_order_no = @mfgOrder
  UNION ALL SELECT 'routings_orders',     COUNT(*) FROM united_db..routings_orders              WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq
  UNION ALL SELECT 'wip_coil_orders',     COUNT(*) FROM proddb..wip_coil_orders                 WHERE coil_no = @rod AND order_no = @order
  UNION ALL SELECT 'WIPStations claim',   COUNT(*) FROM CommonDB..WIPStations                   WHERE LTRIM(RTRIM(CoilNo)) = @rod
  UNION ALL SELECT 'wip_log',             COUNT(*) FROM proddb..wip_log_view                    WHERE coil_no = @rod AND transaction_name = 'FWCHKIN';

  -- Both actual_start_date values must be set, and NEITHER may still be the 1800 sentinel (C7).
  SELECT 'routings' AS src, actual_start_date, machine_idx, actual_weight_on
  FROM   united_db..routings          WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq
  UNION ALL
  SELECT 'planning_routings', actual_start_date, machine_idx, NULL
  FROM   united_db..planning_routings WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq;

  -- The station claim. AccumlatedScrapWeight is NEGATIVE by convention (C2), not a sign error.
  SELECT WIPStation, CoilNo, CoilCheckinNetWeight, CoilCheckinGrossWeight,
         CoilGrossMinusTagWeight, AccumlatedScrapWeight, AccumlatedTrimWeight
  FROM   CommonDB..WIPStations WHERE LTRIM(RTRIM(WIPStation)) = @station;

  -- The rod stamp (D5). coil_status MUST be unchanged from before the call - D-32.
  SELECT coil_no, coil_status, wip_station, wip_badge_no, transaction_name, coil_rev_time
  FROM   proddb..coils WHERE coil_no = @rod;

  -- Idempotent re-entry: run the procedure a second time inside one transaction and confirm
  -- nothing above changes and no duplicate wip_log row appears.
  --
  -- Station release, once the run is over:
  --   EXEC FlatWireDB.dbo.FlatWire_ReleaseStation @station = 'FL1', @expectedCoilNo = 'R00041', @badgeNo = 1234;
  -- CoilNo must return to the station''s own name, padded to 9 (C1).
==============================================================================================*/
