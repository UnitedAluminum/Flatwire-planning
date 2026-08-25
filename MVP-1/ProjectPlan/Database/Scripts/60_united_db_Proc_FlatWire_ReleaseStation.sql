/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 60_united_db_Proc_FlatWire_ReleaseStation.sql
  Object       : united_db.dbo.FlatWire_ReleaseStation
  Target DBs   : united_db  (procedure home; dbo.users, dbo.EventErrorLog)
                 CommonDB   (dbo.WIPStations, Logging_Information_In_Table)
  Last Updated : 2026-08-19
  Status       : Draft - ready to deploy to DEV. No open sign-off items: this procedure
                 introduces no new value into the shared vocabulary.
  Story        : FW-221 (station release and reqsum reversal)
  Specification: MVP-1/ProjectPlan/Architecture/Integration.md Sec 8.0
                 FR-077 (which SETS the station and never clears it), OI-112

  PURPOSE
  -------
  Returns one flat wire WIP station to its idle state at RUN completion.

  *** THIS CLOSES OI-112, AND WITHOUT IT FlatWire_CheckInRod IS A ONE-SHOT. ***

  FR-077 requires check-in to set CommonDB..WIPStations.CoilNo and NO requirement anywhere
  clears it. FW-219 correctly refused to bolt the release onto COIL completion, on the grounds
  that it belongs to RUN completion - which was right, and left it owned by nobody. It is the
  direct counterpart of FlatWire_CheckInRod step 9, so it lands beside it.

  Leaving a station claimed has two consequences, and the second is the one that bites:
    - the station registry says a consumed rod is still on the line, permanently;
    - wip_stations_k1 is UNIQUE on CoilNo, so that rod can never be checked in anywhere else.

  Called from THREE places, all of them run-end rather than coil-end:
      FL1 spool completion                             FW-202
      FL2/FL3 run completion, after the last coil      FW-185 / FW-219's caller
      Rod checkout modes A and B                       FW-174

  THE TRANSACTION BOUNDARY
  ------------------------
  *** TRANSACTION-AGNOSTIC, and deliberately unlike its two siblings. ***

      FlatWire_CheckInRod          the CALLER owns the transaction (asserts @@TRANCOUNT > 0)
      FlatWire_CompleteCoilOnSkid  the PROCEDURE owns its transaction
      FlatWire_ReleaseStation      EITHER - it is one idempotent statement

  It is called from three different places with three different transaction contexts: inside the
  caller's transaction at rod checkout, and standalone after FlatWire_CompleteCoilOnSkid has
  already committed its own. A single UPDATE needs no transaction of its own and joins the
  caller's if there is one, so neither assertion is appropriate. Do not add one.

  IDEMPOTENCY
  -----------
  Fully idempotent, in both directions:
    - a station already holding its own name is left alone and returns 0;
    - a station holding a DIFFERENT rod than @expectedCoilNo is REFUSED, not overwritten.
  So a retry after a failed run completion is safe, and a release that arrives late - after the
  next rod has already claimed the station - cannot silently un-claim it.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  C1. CommonDB..WIPStations is the ONE physical station table. united_db..wip_stations and
      proddb..wip_stations are BOTH VIEWS OVER IT
      (10_CommonDB_Insert_WIPStations_FlatWire.sql:34-35) - one row, three names.

  C2. wip_stations_k1 is a UNIQUE NONCLUSTERED index on CoilNo. Because it is a plain UNIQUE
      index, ONLY ONE ROW MAY HOLD NULL, so an idle station cannot be released to NULL. The
      established convention - all 78 pre-existing rows, verified 2026-07-28 - is that an idle
      station parks ITS OWN STATION NAME in CoilNo as a guaranteed-unique placeholder. This is
      quoted verbatim from SlitterDB.dbo.SlitterInterface_CheckoutCoil:

          UPDATE proddb..wip_stations
             SET coil_no = wip_station, station_no_cuts_set_up = 0, ...

      *** Releasing to NULL or to an empty string WILL eventually collide *** - the first is
      unique only once, the second is unique only once. Both look like they work in DEV with one
      idle station and fail on a shop floor with several.

  C3. CoilNo is VARCHAR(9) and WIPStation is VARCHAR(6). The seeding script space-pads
      WIPStation to exactly 6 and the sentinel to 9, so this procedure pads the same way rather
      than relying on the column to do it.

  C4. The weight columns are SMALLINT. Zeroing them cannot overflow, but AccumlatedScrapWeight
      is NEGATIVE while a rod is running (gross - net, negated) so "reset" means 0, not "leave".

  DECISIONS / ASSUMPTIONS
  -----------------------
  D1. The release is a RUN-completion act, not a coil-completion act. One run may produce many
      coils; the station is claimed once at check-in and released once at the end. Calling this
      after each coil would free the station while the line is still running.

  D2. @expectedCoilNo is optional but strongly recommended. Without it the procedure releases
      whatever is there; with it, it refuses to release a station that has since been claimed by
      a different rod. A run-completion caller always knows which rod it checked in, so it should
      always pass it. The parameter is optional only so that an operator recovery path can force
      a release of a station stranded by an earlier defect.

  D3. StationNoCutsSetUp is zeroed alongside the weights, matching
      SlitterInterface_CheckoutCoil. Flat wire never sets it, but leaving a stale value on a
      station the slitters may later use is a needless difference between our idle rows and the
      other 78.

  D4. It does NOT touch proddb..coils. The rod's wip_station stamp (FlatWire_CheckInRod D5) is
      history - it records where the rod WAS processed - and checkout writes the rod's onward
      disposition through its own path. Clearing it here would erase the only shared-schema
      evidence that the rod was ever on a flattening line, which is the thing OI-111 is about.

  D5. It writes no WIP log row. The WIP transaction for the run end belongs to the completion
      path (FlatWire_CompleteCoilOnSkid step 12) or to checkout; a station release is
      housekeeping on a registry, not a material movement, and the legacy checkout does not log
      one either.
==============================================================================================*/

USE [united_db];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[FlatWire_ReleaseStation]
      @station          VARCHAR(6)                          -- FL1 | FL2 | FL3 | FL1PO | FWPACK
    , @expectedCoilNo   VARCHAR(9)  = ''                    -- the rod this caller checked in (D2)
    , @badgeNo          INT         = 0
    , @wasReleased      BIT         = NULL OUTPUT           -- 0 = already idle, nothing done
    , @releasedCoilNo   VARCHAR(9)  = NULL OUTPUT           -- what it was holding
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @userId       INT
          , @logInfo      VARCHAR(8000)
          , @idleSentinel VARCHAR(9)
          , @currentCoil  VARCHAR(9)
          , @errMessage   NVARCHAR(MAX)
          , @errNo        INT
          , @errSev       INT
          , @errState     INT
          , @spObjectName SYSNAME;

    SET @wasReleased = 0;

    SELECT @userId = userid
    FROM   [dbo].[users] WITH (NOLOCK)
    WHERE  BadgeNo = @badgeNo;

    BEGIN TRY
        /*--------------------------------------------------------------------------------------
          1. Normalise and validate.
        --------------------------------------------------------------------------------------*/
        SET @station        = LTRIM(RTRIM(ISNULL(@station, '')));
        SET @expectedCoilNo = LTRIM(RTRIM(ISNULL(@expectedCoilNo, '')));

        IF @station = ''
            THROW 53001, 'FlatWire_ReleaseStation: @station is required.', 1;

        -- C3: the sentinel is the station name padded to the full width of CoilNo.
        SET @idleSentinel = LEFT(@station + SPACE(9), 9);

        /*--------------------------------------------------------------------------------------
          2. Read the current claim under a held lock, so the decision and the write are one act.
        --------------------------------------------------------------------------------------*/
        SELECT @currentCoil = LTRIM(RTRIM(ISNULL(CoilNo, '')))
        FROM   [CommonDB].[dbo].[WIPStations] WITH (UPDLOCK, HOLDLOCK)
        WHERE  LTRIM(RTRIM(WIPStation)) = @station;

        IF @@ROWCOUNT = 0
            THROW 53002, 'FlatWire_ReleaseStation: the WIP station does not exist. Run 10_CommonDB_Insert_WIPStations_FlatWire.sql before this procedure.', 1;

        SET @releasedCoilNo = @currentCoil;

        /*--------------------------------------------------------------------------------------
          3. Already idle - nothing to do. See IDEMPOTENCY.
        --------------------------------------------------------------------------------------*/
        IF @currentCoil IN ('', @station)
        BEGIN
            PRINT 'FlatWire_ReleaseStation: ' + @station + ' is already idle - nothing written.';
            RETURN 0;
        END

        /*--------------------------------------------------------------------------------------
          4. Held by a different rod than the caller expects - REFUSE.  (D2)
             This is the late-release case: the run ended, the release was lost, the next rod
             claimed the station, and the retry arrived afterwards. Un-claiming it would strand
             a rod that is physically on the line.
        --------------------------------------------------------------------------------------*/
        IF @expectedCoilNo <> '' AND @currentCoil <> @expectedCoilNo
            THROW 53003, 'FlatWire_ReleaseStation: the station is held by a different rod than expected. It has already been re-claimed; refusing to release it.', 1;

        /*--------------------------------------------------------------------------------------
          5. Release.  (C2, C4, D3)
             CoilNo returns to the station's own name - NOT NULL, NOT '' (C2).
        --------------------------------------------------------------------------------------*/
        UPDATE  [CommonDB].[dbo].[WIPStations]
        SET     CoilNo                  = @idleSentinel
              , StationNoCutsSetUp      = 0
              , CoilCheckinNetWeight    = 0
              , CoilCheckinGrossWeight  = 0
              , CoilGrossMinusTagWeight = 0
              , AccumlatedScrapWeight   = 0
              , AccumlatedTrimWeight    = 0
        WHERE   LTRIM(RTRIM(WIPStation)) = @station;

        IF @@ROWCOUNT <> 1
            THROW 53004, 'FlatWire_ReleaseStation: expected exactly one CommonDB..WIPStations row to be released (C1).', 1;

        SET @wasReleased = 1;

        SET @logInfo = 'FlatWire_ReleaseStation: ' + @station
                     + ' released from ' + @currentCoil
                     + ' back to idle sentinel ' + LTRIM(RTRIM(@idleSentinel));

        EXEC [dbo].[Logging_Information_In_Table] @module_name         = 'FlatWire'
                                                , @sp_name             = 'FlatWire_ReleaseStation'
                                                , @table_name          = 'CommonDB..WIPStations'
                                                , @log_info            = @logInfo
                                                , @operation_performed = 'Update'
                                                , @user_id             = @userId;

        PRINT @logInfo;
        RETURN 0;
    END TRY
    BEGIN CATCH
        /*--------------------------------------------------------------------------------------
          No ROLLBACK. This procedure is transaction-agnostic (THE TRANSACTION BOUNDARY): it may
          be running inside the caller's transaction, and rolling that back from here would
          discard writes it knows nothing about. XACT_ABORT dooms an enclosing transaction on its
          own; standalone, the single UPDATE is atomic anyway.
        --------------------------------------------------------------------------------------*/
        SELECT   @errNo        = ERROR_NUMBER()
               , @errSev       = ERROR_SEVERITY()
               , @errState     = ERROR_STATE()
               , @spObjectName = ISNULL(ERROR_PROCEDURE(), 'FlatWire_ReleaseStation')
               , @errMessage   = 'FlatWire_ReleaseStation failed for station ' + ISNULL(@station, 'NULL')
                               + '. Error: ' + ERROR_MESSAGE();

        INSERT INTO [dbo].[EventErrorLog]
                ( [ObjectName], [ErrNumber], [ErrSeverity], [ErrState]
                , [EventDescription], [StartTime], [UserName] )
        VALUES  ( @spObjectName, @errNo, @errSev, @errState
                , @errMessage, GETDATE(), SUSER_NAME() );

        THROW;
    END CATCH
END
GO

GRANT EXECUTE ON [dbo].[FlatWire_ReleaseStation] TO [public] AS [dbo];
GO

/*==============================================================================================
  VERIFICATION
  ---------------------------------------------------------------------------------------------
  DECLARE @wasReleased BIT, @released VARCHAR(9);

  -- Before: the station holds the rod.
  SELECT WIPStation, CoilNo, CoilCheckinNetWeight, AccumlatedScrapWeight
  FROM   CommonDB..WIPStations WHERE LTRIM(RTRIM(WIPStation)) = 'FL1';

  EXEC united_db.dbo.FlatWire_ReleaseStation
         @station = 'FL1', @expectedCoilNo = 'R00041', @badgeNo = 1234,
         @wasReleased = @wasReleased OUTPUT, @releasedCoilNo = @released OUTPUT;
  SELECT @wasReleased AS wasReleased, @released AS releasedCoilNo;   -- 1, R00041

  -- After: CoilNo is the station's own name, padded to 9, and the weights are zero.
  SELECT WIPStation, CoilNo, LEN(CoilNo) AS coilNoLen, CoilCheckinNetWeight,
         CoilCheckinGrossWeight, AccumlatedScrapWeight, StationNoCutsSetUp
  FROM   CommonDB..WIPStations WHERE LTRIM(RTRIM(WIPStation)) = 'FL1';

  -- Idempotent: a second call writes nothing and returns wasReleased = 0.
  EXEC united_db.dbo.FlatWire_ReleaseStation @station = 'FL1', @badgeNo = 1234,
       @wasReleased = @wasReleased OUTPUT;
  SELECT @wasReleased AS secondCall;                                  -- 0

  -- Late release: claim the station with another rod, then retry the old release. Expect 53003.
  -- EXEC united_db.dbo.FlatWire_ReleaseStation @station='FL1', @expectedCoilNo='R00041', @badgeNo=1234;

  -- The sentinel convention holds across the whole registry - every idle row should satisfy this.
  SELECT WIPStation, CoilNo
  FROM   CommonDB..WIPStations
  WHERE  LTRIM(RTRIM(CoilNo)) = LTRIM(RTRIM(WIPStation))
  ORDER BY WIPStation;
==============================================================================================*/
