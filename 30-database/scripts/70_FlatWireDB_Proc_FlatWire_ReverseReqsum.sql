/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 70_FlatWireDB_Proc_FlatWire_ReverseReqsum.sql
  Object       : FlatWireDB.dbo.FlatWire_ReverseReqsum
  Target DBs   : FlatWireDB (procedure home - MOVED from united_db 26 Aug 2026, change [H];
                             the procedure is the ONLY thing that moved - every table below is
                             read and written exactly where it always was)
                 united_db  (dbo.routings, dbo.planning_routings, dbo.users,
                             dbo.EventErrorLog, dbo.reassign_order_info - via trigger)
                 proddb     (dbo.wip_coil_orders, dbo.wip_coil_orders_hist - via trigger)
                 CommonDB   (del_or_upd_wip_orders, Logging_Information_In_Table)
  Last Updated : 2026-08-26
  Status       : Draft - the DELETE needs sign-off before a shared environment (Q40).
                 Everything else is a reset to a value the column already held.
  Story        : FW-221 (station release and reqsum reversal)
  Specification: MVP-1/ProjectPlan/Architecture/Architecture.md Sec 10 (closing line)
                 MVP-1/ProjectPlan/Architecture/Integration.md Sec 8.0, OI-01

  PURPOSE
  -------
  Undoes the shared half of a rod check-in when the rod is taken back off the line WITHOUT
  having run - pre-check-out (Mode P) and pre-run checkout (Mode A).

  ARC Sec 10 requires it in one line and nothing implemented it:

      "The same reasoning applies to pre-check-in ... and to pre-check-out
       (must REVERSE the wip_coil_orders insert)."

  OI-01's surviving residual after D-32 is exactly this. Without it, a rod checked out before
  any footage ran leaves behind:
    - a wip_coil_orders row claiming the rod against an order it never served, which distorts
      the order's planned weight and its material status; and
    - an actual_start_date on planning_routings and routings claiming a step that never started,
      which distorts every schedule-adherence and cycle-time report that reads it.

  It performs, in this order:

      1.  validate, including the "has it actually run" guard                   (D3)
      2.  proddb..wip_coil_orders   <- DELETE the row check-in created          (D2, C1, C2)
      3.  wip_orders (via del_or_upd_wip_orders)  <- order material status
      4.  routings.actual_start_date          -> back to the 1800 sentinel      (C3)
      5.  planning_routings.actual_start_date -> back to the 1800 sentinel      (C3)
      6.  FlatWire_ReleaseStation                                               (D5)

  WHAT THIS PROCEDURE DELIBERATELY DOES NOT DO
  --------------------------------------------
    - It does not delete the routings row. A planned step that exists but has not started is a
      normal, correct state - it is what planning_routings looked like before check-in copied it
      forward. Deleting it would destroy the machine_idx, program and tolerance values, and the
      next check-in would simply copy them again. Only actual_start_date claims the step ran, so
      only actual_start_date is reset.
    - It does not delete mfg_sales_order_ref or routings_orders. Those record that the order IS
      associated with this rod, which remains true after a checkout - the rod is still planned
      against the order, it just is not on the line.
    - It does not touch proddb..coils. The rod's wip_station stamp is history (FlatWire_CheckInRod
      D5); the rod's onward disposition is RodCheckout's business, in FlatWireDB.
    - It does not reverse a run that PRODUCED something. See D3 - that is Mode B, and its reqsum
      is real.

  THE TRANSACTION BOUNDARY
  ------------------------
  *** THIS PROCEDURE DOES NOT OPEN A TRANSACTION. THE CALLER OWNS IT. ***

  Same contract as FlatWire_CheckInRod, and for the same reason: pre-check-out writes
  FlatWireDB (RodCheckout, RodStaging -> Unstaged, Rod.Status) and the shared schema in one act,
  and the two halves must commit together or not at all. FlatWireDB and the shared databases are
  on ONE instance (confirmed 18 Aug 2026), so one SqlConnection with one SqlTransaction spans
  both under the local transaction manager - no MSDTC.

  A THROW from here dooms the caller's transaction, which is what we want. There is no savepoint.

  IDEMPOTENCY
  -----------
  Fully idempotent. Every step is guarded on the state it removes:
    - no wip_coil_orders row -> step 2 does nothing;
    - actual_start_date already at the sentinel -> steps 4 and 5 do nothing;
    - station already idle -> step 6 returns 0.
  So a retry after a doomed transaction is safe, and calling it twice is harmless.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  C1. *** proddb..wip_coil_orders HAS A DELETE TRIGGER AND IT DOES MORE THAN YOU EXPECT. ***
      wip_coil_orders_d_tg fires FOR DELETE, UPDATE and on a delete it:
        - archives the deleted row to proddb..wip_coil_orders_hist with a timestamp; and
        - sets united_db..reassign_order_info.status = 2 for that order / release / coil.
      The archive is why the DELETE at step 2 is auditable rather than destructive - and note it
      closes a loop: wip_coil_orders_hist is the FOURTH fallback in FlatWire_CheckInRod's order
      cascade (D13), so a rod checked out and later re-checked-in recovers its planned weight
      from the row this procedure deleted.
      The reassign_order_info write is a real side effect on a table about order reassignment.
      It is correct - the order genuinely is no longer assigned to this coil - but it is not
      obvious from the trigger's name, and it is not something this procedure can suppress.

  C2. *** THE SAME TRIGGER IS SINGLE-ROW-SCALAR. *** It uses
      SELECT @Old_order_no = order_no, ... FROM deleted, so a multi-row DELETE archives every row
      but resolves reassign_order_info against an ARBITRARY one. Exactly the same trap as
      coils_iud_tg (FlatWire_CompleteCoilOnSkid C4). Delete ONE row per call, always, and never
      "optimise" this into a set operation.

  C3. planning_routings and routings treat '1800-01-01' as "unset" for actual_start_date - NOT
      NULL. Resetting to NULL would not restore the pre-check-in state: every legacy reader
      guards with ISNULL(actual_start_date,'1800-01-01') = '1800-01-01', which NULL satisfies,
      but the columns are populated with the literal sentinel everywhere else and a NULL would be
      the only one of its kind in the table. Write the sentinel.

  C4. wip_coil_orders' effective key wip_coil_orders_k0 is UNIQUE CLUSTERED on
      (coil_no, order_no, rel_letter), and rel_letter is NULLABLE yet part of that key. Every
      comparison uses ISNULL on BOTH sides.

  DECISIONS / ASSUMPTIONS  (confirm before running outside DEV)
  ------------------------------------------------------------
  D1. Scope is FL1/FL3 rod check-out, mirroring FlatWire_CheckInRod D1. FL2 is not handled here
      because it is not handled there (OI-115).

  D2. The row is DELETED, not left as an orphan.  [Q40 - CLIENT/IT INPUT REQUIRED]
      *** THIS IS THE HEAVIEST ACT IN THE FLAT WIRE SHARED WRITE SET *** - every other write in
      FlatWire_CheckInRod and FlatWire_CompleteCoilOnSkid adds or updates; this one removes.
      The case for deleting: ARC Sec 10 says "reverse", the legacy reqsum path itself deletes
      (PreCheckIn_Reqsum_Transaction opens with DELETE wco FROM wip_coil_orders WHERE
      coil_no = @CoilNo), and the trigger archives to _hist so nothing is actually lost.
      The case against: a downstream report may already have read it.
      Confirm with IT. If the answer is "leave it", @deleteOrphan = 0 makes this a no-op on step
      2 and the rest of the procedure still does useful work.

  D3. @onlyIfUnworked = 1 REFUSES when footage is non-zero, and this is the important guard.
      Mode P (pre-check-out) and Mode A (checked in, acknowledged, footage still 0) never
      produced anything, so their reqsum is a claim about work that did not happen.
      *** MODE B IS DIFFERENT AND MUST NOT BE REVERSED. *** It is a mid-run emergency removal
      with footage > 0: material was consumed, the order was genuinely served, and the reqsum is
      real. Deleting it would make produced material vanish from the order. The caller passes
      @footageAtCheckout and this procedure enforces the rule rather than trusting the mode.

  D4. del_or_upd_wip_orders is called AFTER the delete, symmetric with FlatWire_CheckInRod step
      6. The order's material status is derived from its coil rows, so removing one without
      recomputing leaves the order claiming material it no longer has.

  D5. The station release is called from HERE rather than left to the caller, because a checkout
      that reverses the reqsum but leaves the station claimed reproduces OI-112 by a different
      route. It is called last, so a failure in the reversal never releases a station whose rod
      is still recorded as running.

  D6. @wipCoilOrdersWasWritten lets the caller say whether CHECK-IN created the row. When
      check-in found an existing row and left it alone, that row predates flat wire and is not
      ours to delete. FlatWire_CheckInRod returns this as an OUTPUT parameter and the caller
      persists it on RodCheckin for exactly this purpose. Defaulting it to 1 would make the
      common case right and the uncommon case destructive, so it defaults to 0 - the safe
      direction - and the caller must be explicit.

  ERROR NUMBERS
  -------------
      54001         called outside a transaction    -> 500
      54002 - 54019 validation                      -> 422
      54020 - 54029 state conflict                  -> 409
==============================================================================================*/

USE [FlatWireDB];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[FlatWire_ReverseReqsum]
      @rodAlpha                 VARCHAR(9)
    , @orderNo                  INT
    , @relLetter                CHAR(1)
    , @mfgOrderNo               INT
    , @seqNo                    SMALLINT
    , @station                  VARCHAR(6)                  -- released at step 6 (D5)
    , @badgeNo                  INT
    , @footageAtCheckout        INT        = 0              -- D3 - the guard, not the mode
    , @onlyIfUnworked           BIT        = 1              -- D3
    , @wipCoilOrdersWasWritten  BIT        = 0              -- D6 - safe direction by default
    , @deleteOrphan             BIT        = 1              -- D2 / Q40 - 0 makes step 2 a no-op
    , @checkoutMode             VARCHAR(10) = NULL          -- ModeP | ModeA, for the audit line only
    , @wipCoilOrdersDeleted     BIT        = NULL OUTPUT
    , @routingsReset            BIT        = NULL OUTPUT
    , @stationReleased          BIT        = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*------------------------------------------------------------------------------------------
      0. Constants, locals and the audit-trail entry
    ------------------------------------------------------------------------------------------*/
    DECLARE @UnsetDate  DATETIME = '1800-01-01 00:00:00.000';       -- C3

    DECLARE @userId       INT
          , @logInfo      VARCHAR(8000)
          , @releasedCoil VARCHAR(9)
          , @errMessage   NVARCHAR(MAX)
          , @errNo        INT
          , @errSev       INT
          , @errState     INT
          , @spObjectName SYSNAME;

    SET @wipCoilOrdersDeleted = 0;
    SET @routingsReset        = 0;
    SET @stationReleased      = 0;

    SELECT @userId = userid
    FROM   [united_db].[dbo].[users] WITH (NOLOCK)
    WHERE  BadgeNo = @badgeNo;

    SET @logInfo = 'EXEC FlatWire_ReverseReqsum '
                 + ISNULL(@rodAlpha, 'NULL')             + ', order='
                 + ISNULL(CAST(@orderNo AS VARCHAR(10)), 'NULL')
                 + ISNULL(@relLetter, ' ')               + ', mfgOrder='
                 + ISNULL(CAST(@mfgOrderNo AS VARCHAR(10)), 'NULL') + '/'
                 + ISNULL(CAST(@seqNo AS VARCHAR(6)), 'NULL')       + ', station='
                 + ISNULL(@station, 'NULL')              + ', mode='
                 + ISNULL(@checkoutMode, 'NULL')         + ', footage='
                 + ISNULL(CAST(@footageAtCheckout AS VARCHAR(10)), 'NULL');

    EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                            , @sp_name             = 'FlatWire_ReverseReqsum'
                                            , @table_name          = 'Entered into sp'
                                            , @log_info            = @logInfo
                                            , @operation_performed = 'Execute'
                                            , @user_id             = @userId;

    BEGIN TRY
        /*--------------------------------------------------------------------------------------
          1. Validate.
        --------------------------------------------------------------------------------------*/
        IF @@TRANCOUNT = 0
            THROW 54001, 'FlatWire_ReverseReqsum must be called inside the caller''s transaction: the FlatWireDB checkout record and the shared reversal commit together. See THE TRANSACTION BOUNDARY.', 1;

        SET @rodAlpha = LTRIM(RTRIM(ISNULL(@rodAlpha, '')));
        SET @station  = LTRIM(RTRIM(ISNULL(@station, '')));

        IF @rodAlpha = ''
            THROW 54002, 'FlatWire_ReverseReqsum: @rodAlpha is required.', 1;

        IF ISNULL(@orderNo, 0) <= 0
            THROW 54003, 'FlatWire_ReverseReqsum: @orderNo is required - it identifies the reqsum row being reversed.', 1;

        IF ISNULL(@mfgOrderNo, 0) <= 0
            THROW 54004, 'FlatWire_ReverseReqsum: @mfgOrderNo is required - it identifies the routing step being un-started.', 1;

        IF @station = ''
            THROW 54005, 'FlatWire_ReverseReqsum: @station is required - the release at step 6 is part of the reversal (D5).', 1;

        /*--------------------------------------------------------------------------------------
          1b. The guard that matters.  (D3)
              Mode B produced material. Its reqsum is real and must survive.
        --------------------------------------------------------------------------------------*/
        IF @onlyIfUnworked = 1 AND ISNULL(@footageAtCheckout, 0) > 0
            THROW 54020, 'FlatWire_ReverseReqsum: the rod ran (footage > 0), so its reqsum records material the order genuinely received. This is a Mode B checkout and must not be reversed (D3).', 1;

        /*--------------------------------------------------------------------------------------
          2. proddb..wip_coil_orders - remove the claim check-in created.  (C1, C2, C4, D2, D6)
             ONE row. The trigger archives it to wip_coil_orders_hist and updates
             reassign_order_info - see C1, both are intended.
        --------------------------------------------------------------------------------------*/
        IF @deleteOrphan = 1 AND @wipCoilOrdersWasWritten = 1
        BEGIN
            IF EXISTS (SELECT 1 FROM [proddb].[dbo].[wip_coil_orders] WITH (UPDLOCK, HOLDLOCK)
                       WHERE coil_no = @rodAlpha
                         AND order_no = @orderNo
                         AND ISNULL(rel_letter, '') = ISNULL(@relLetter, ''))
            BEGIN
                DELETE FROM [proddb].[dbo].[wip_coil_orders]
                WHERE  coil_no = @rodAlpha
                  AND  order_no = @orderNo
                  AND  ISNULL(rel_letter, '') = ISNULL(@relLetter, '');

                IF @@ROWCOUNT <> 1
                    THROW 54006, 'FlatWire_ReverseReqsum: expected exactly one wip_coil_orders row to be deleted - the delete trigger is single-row-scalar (C2).', 1;

                SET @wipCoilOrdersDeleted = 1;

                /*------------------------------------------------------------------------------
                  3. Recompute the order's material status.  (D4)
                --------------------------------------------------------------------------------*/
                CREATE TABLE #FlatWireReverseWipOrder ( Result VARCHAR(10) );

                INSERT INTO #FlatWireReverseWipOrder ( Result )
                EXEC [CommonDB].[dbo].[del_or_upd_wip_orders] @orderNo, @relLetter;

                DROP TABLE #FlatWireReverseWipOrder;
            END
        END

        /*--------------------------------------------------------------------------------------
          4. routings.actual_start_date -> the sentinel.  (C3)
             machine_idx and actual_weight_on are LEFT AS THEY ARE: the step is still planned on
             that machine, and the weight recorded is what was physically on the payoff. Only the
             start claim is untrue.
        --------------------------------------------------------------------------------------*/
        UPDATE  [united_db].[dbo].[routings] WITH (ROWLOCK)
        SET     actual_start_date = @UnsetDate
        WHERE   LTRIM(RTRIM(coil_no)) = @rodAlpha
          AND   mfg_order_no = @mfgOrderNo
          AND   seq_no = @seqNo
          AND   ISNULL(actual_start_date, @UnsetDate) <> @UnsetDate;

        IF @@ROWCOUNT > 0
            SET @routingsReset = 1;

        /*--------------------------------------------------------------------------------------
          5. planning_routings.actual_start_date -> the sentinel.  (C3)
        --------------------------------------------------------------------------------------*/
        UPDATE  [united_db].[dbo].[planning_routings] WITH (ROWLOCK)
        SET     actual_start_date = @UnsetDate
        WHERE   LTRIM(RTRIM(coil_no)) = @rodAlpha
          AND   mfg_order_no = @mfgOrderNo
          AND   seq_no = @seqNo
          AND   ISNULL(actual_start_date, @UnsetDate) <> @UnsetDate;

        IF @@ROWCOUNT > 0
            SET @routingsReset = 1;

        /*--------------------------------------------------------------------------------------
          6. Release the station.  (D5)
             LAST, so a failure above never frees a station whose rod is still recorded as
             running. Transaction-agnostic, so it joins this transaction.
        --------------------------------------------------------------------------------------*/
        EXEC [dbo].[FlatWire_ReleaseStation] @station        = @station
                                           , @expectedCoilNo = @rodAlpha
                                           , @badgeNo        = @badgeNo
                                           , @wasReleased    = @stationReleased OUTPUT
                                           , @releasedCoilNo = @releasedCoil    OUTPUT;

        /*--------------------------------------------------------------------------------------
          7. Done. NO COMMIT - the caller owns the transaction.
        --------------------------------------------------------------------------------------*/
        SET @logInfo = 'FlatWire_ReverseReqsum applied: ' + @rodAlpha
                     + ', reqsumDeleted ' + CAST(@wipCoilOrdersDeleted AS VARCHAR(1))
                     + ', startDateReset ' + CAST(@routingsReset AS VARCHAR(1))
                     + ', stationReleased ' + CAST(@stationReleased AS VARCHAR(1))
                     + ' (caller still to commit)';

        EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_ReverseReqsum'
                                                , @table_name          = 'Applied - caller to commit'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Delete'
                                                , @user_id             = @userId;

        PRINT @logInfo;
        RETURN 0;
    END TRY
    BEGIN CATCH
        /*--------------------------------------------------------------------------------------
          No ROLLBACK - the caller owns the transaction. Same contract as FlatWire_CheckInRod,
          and the opposite of FlatWire_CompleteCoilOnSkid, which owns its own.
        --------------------------------------------------------------------------------------*/
        SELECT   @errNo        = ERROR_NUMBER()
               , @errSev       = ERROR_SEVERITY()
               , @errState     = ERROR_STATE()
               , @spObjectName = ISNULL(ERROR_PROCEDURE(), 'FlatWire_ReverseReqsum')
               , @errMessage   = 'FlatWire_ReverseReqsum failed for ' + ISNULL(@rodAlpha, 'NULL')
                               + ' (order ' + ISNULL(CAST(@orderNo AS VARCHAR(10)), 'NULL') + '). Error: '
                               + ERROR_MESSAGE();

        INSERT INTO [united_db].[dbo].[EventErrorLog]
                ( [ObjectName], [ErrNumber], [ErrSeverity], [ErrState]
                , [EventDescription], [StartTime], [UserName] )
        VALUES  ( @spObjectName, @errNo, @errSev, @errState
                , @errMessage, GETDATE(), SUSER_NAME() );

        EXEC [CommonDB].[dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_ReverseReqsum'
                                                , @table_name          = 'Failed - caller transaction doomed'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Error'
                                                , @user_id             = @userId;

        THROW;
    END CATCH
END
GO

GRANT EXECUTE ON [dbo].[FlatWire_ReverseReqsum] TO [public] AS [dbo];
GO

/*==============================================================================================
  VERIFICATION
  ---------------------------------------------------------------------------------------------
  DECLARE @rod VARCHAR(9) = 'R00041', @order INT = 421, @rel CHAR(1) = 'A',
          @mfgOrder INT = 90001, @seq SMALLINT = 0, @station VARCHAR(6) = 'FL1';
  DECLARE @del BIT, @reset BIT, @rel2 BIT;

  -- Check in, then reverse, inside one transaction.
  BEGIN TRAN;
    EXEC FlatWireDB.dbo.FlatWire_ReverseReqsum
           @rodAlpha = @rod, @orderNo = @order, @relLetter = @rel,
           @mfgOrderNo = @mfgOrder, @seqNo = @seq, @station = @station, @badgeNo = 1234,
           @footageAtCheckout = 0, @wipCoilOrdersWasWritten = 1, @checkoutMode = 'ModeA',
           @wipCoilOrdersDeleted = @del OUTPUT, @routingsReset = @reset OUTPUT,
           @stationReleased = @rel2 OUTPUT;
    SELECT @del AS reqsumDeleted, @reset AS startDateReset, @rel2 AS stationReleased;  -- 1,1,1
  COMMIT;

  -- The reqsum row is gone from the live table and PRESENT in history (C1) - not lost.
  SELECT 'live' AS src, * FROM proddb..wip_coil_orders      WHERE coil_no = @rod AND order_no = @order;
  SELECT 'hist' AS src, * FROM proddb..wip_coil_orders_hist WHERE coil_no = @rod AND order_no = @order;

  -- Both start dates are back at the sentinel - NOT NULL (C3).
  SELECT 'routings' AS src, actual_start_date, machine_idx, actual_weight_on
  FROM   united_db..routings          WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq
  UNION ALL
  SELECT 'planning_routings', actual_start_date, machine_idx, NULL
  FROM   united_db..planning_routings WHERE coil_no = @rod AND mfg_order_no = @mfgOrder AND seq_no = @seq;

  -- The trigger's other side effect (C1) - correct, but not obvious from its name.
  SELECT * FROM united_db..reassign_order_info
  WHERE  coil_no = @rod AND new_order_no = @order AND new_rel_letter = @rel;

  -- The station is idle again.
  SELECT WIPStation, CoilNo FROM CommonDB..WIPStations WHERE LTRIM(RTRIM(WIPStation)) = @station;

  -- Mode B must be REFUSED. Expect 54020.
  -- EXEC FlatWireDB.dbo.FlatWire_ReverseReqsum @rodAlpha=@rod, @orderNo=@order, @relLetter=@rel,
  --      @mfgOrderNo=@mfgOrder, @seqNo=@seq, @station=@station, @badgeNo=1234,
  --      @footageAtCheckout = 4200, @wipCoilOrdersWasWritten = 1, @checkoutMode = 'ModeB';

  -- Idempotent: a second reversal writes nothing and returns 0,0,0.
==============================================================================================*/
