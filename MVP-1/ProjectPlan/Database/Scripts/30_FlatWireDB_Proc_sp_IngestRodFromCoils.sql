/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql
  Object       : FlatWireDB.dbo.sp_IngestRodFromCoils
  Target DBs   : FlatWireDB  (procedure home; dbo.Rod)
                 proddb      (dbo.coils            - READ ONLY)
                 united_db   (dbo.alloys           - READ ONLY)
  Last Updated : 2026-08-19
  Status       : Ready to build - no sign-off items. Shares FW-220's deployment prerequisite.
  Story        : FW-223 (rod ingestion - populating the FlatWire tables)
  Specification: MVP-1/ProjectPlan/Architecture/Integration.md Sec 7.9
                 MVP-1/ProjectPlan/Backend/TaskBreakdownPlans/FW-223-Rod-Ingestion.md
                 FR-529 - FR-532

  *** THIS IS THE ANSWER TO OI-42. ***

  PURPOSE
  -------
  Projects ONE rod from the shared schema into the FlatWireDB mirror.

  It is the INBOUND bracket of the run. The three united_db procedures in this folder are the
  outbound ones:

      FlatWireDB_Proc_sp_IngestRodFromCoils   <- THIS: coils -> Rod, at first use
      united_db_Proc_FlatWire_CheckInRod         Rod on the line -> the shared schema
      united_db_Proc_FlatWire_ReverseReqsum      undoes the above when the rod never ran
      united_db_Proc_FlatWire_CompleteCoilOnSkid finished coil -> the shared schema
      united_db_Proc_FlatWire_ReleaseStation     the station, at run end

  WHY IT EXISTS
  -------------
  [Rod] is a FlatWireDB-local mirror of proddb..coils (D-04), and until 19 Aug 2026 NOTHING
  POPULATED IT IN PRODUCTION. Rod receiving (FW-020..FW-022) is upstream, was removed from this
  backlog on 13 Aug 2026 as another team's work, and writes proddb..coils - not FlatWireDB. The
  only thing that had ever put a row in [Rod] was FlatWire_SampleData_Materials.sql, which seeds
  eight fake rods.

  FK_RodCheckin_Rod and FK_RodStaging_Rod are ENFORCED (06_ForeignKeys.sql:138 and :102), so on
  a clean production database THE FIRST STAGING OR CHECK-IN FAILS ON A FOREIGN KEY. Not a latent
  risk - the first real operation.

  OI-42 has been open since D-04 retained the mirror, and [DBD] calls it "a real design hole,
  not a documentation nit: it creates two sources of truth for rod material with no
  reconciliation". It has two halves, and this procedure answers both - WHEN below, and WHICH
  SIDE IS MASTER further down.

  WHY IT IS IN Scripts/ AND NOT IN THE SCHEMA RUNNER
  --------------------------------------------------
  It is a FlatWireDB object, so FlatWire_DDL_08_Programmability.sql beside sp_GetGaugeTrace
  looks like its natural home, and it was there briefly. It is here instead for two reasons:

    - it READS proddb..coils AND united_db..alloys, so unlike every other object in the schema
      runner it cannot be verified by a FlatWireDB-only deploy. Shipping it with the schema
      would mean the runner claims to have produced something it cannot test;
    - it belongs to the same deployment step as the four united_db procedures, which are also
      cross-database and also need 20_FlatWire_Grants.sql to have run first.

  *** CONSEQUENCE FOR THE OBJECT BASELINE: FlatWire_DDL_RunAll.sql still produces ONE procedure
  (sp_GetGaugeTrace). A DEPLOYED FlatWireDB carries TWO once this folder's scripts have run. ***
  If you are reconciling a count, that is the difference.

  WHEN IT RUNS
  ------------
  On the first WRITE that names the rod, inside the caller's transaction, BEFORE any other
  FlatWireDB write:

      POST /staging/rod   (FL1/FL3, when pre-check-in is used)   FK_RodStaging_Rod
      POST /checkin/rod   (always)                               FK_RodCheckin_Rod

  It is idempotent, so whichever arrives first creates the row and the second refreshes it.
  Check-in cannot assume staging ran: a direct scan into Dashboard 2 is a supported path.

  *** NOT ON GET /rod/{alpha}. *** That endpoint is documented Idempotent and any authenticated
  role may call it, so a supervisor scanning a rod merely to look at it must not create records.
  FR-530 states this as a requirement rather than leaving it to convention.

  WHY A PROCEDURE AND NOT AN EF WRITE
  -----------------------------------
  [SVC 3.3] puts entity writes in EF Core, and this looks like an exception. It is not.
  [SVC 3.2a] lists [Rod] under "Not aggregates, each for a reason": a FlatWireDB-local mirror of
  coils, where coils owns the lifecycle - a READ MODEL. A read model with no aggregate has no EF
  write path, by exactly the reasoning P-13 used to keep PassSchedule Dapper-only. A projection
  from another database is also [SVC 3.3]'s "cross-DB reads" row rather than its entity-writes
  row. This is the convention, not an exception to it.

  THE TRANSACTION BOUNDARY
  ------------------------
  *** THE CALLER OWNS THE TRANSACTION. *** Same contract as united_db.dbo.FlatWire_CheckInRod,
  and for the same reason: this runs inside the one transaction that also writes FlatWireRun and
  RodCheckin, and calls FlatWire_CheckInRod at the end of it. Asserted (55001) rather than
  assumed, because a caller that forgets leaves a mirror row with no run attached to it.

  A THROW here dooms the caller's transaction, which is what we want. There is no savepoint and
  no partial-success path.

  WHICH SIDE IS MASTER FOR EACH COLUMN
  ------------------------------------
  This is the second half of OI-42, and it existed nowhere in the repository.

    Rod column                  Source                          Master
    --------------------------  ------------------------------  ------
    Alpha                       coils.coil_no                   shared
    Alloy                       coil_alloy -> alloys.alloy      shared
    Temper                      coils.coil_temper               shared
    DiameterIn                  the CALLER's measurement        local
    GrossWeightLb               coils.coil_gross_wgt            shared
    NetWeightLb                 coils.coil_net_wgt              shared
    SupplierHeat                *** NOTHING ***                 --
    InventoryType               coils.inventory_type            shared
    Location                    coils.storage_section           shared
    ReceivedAt                  coils.coil_recvd_date           shared
    Status                      --                              LOCAL
    FootageRunToDate            --                              LOCAL
    RemainingWeightEstimateLb   --                              LOCAL

  *** THE REFRESH TOUCHES SHARED-MASTERED COLUMNS ONLY, AND THAT IS WHY THIS IS NOT A MERGE. ***
  The three LOCAL rows are the reason:
    Status carries INFLAT, FlatWireDB-local since D-32 - resetting it would un-mark a rod that
      is running, and FR-044's availability test reads it;
    FootageRunToDate is the carry-forward evidence PRC007 depends on - clearing it would
      silently offer a fresh-start check-in for a rod that has already run footage, which
      FR-043 forbids;
    RemainingWeightEstimateLb is the starting weight for that carry-forward run.
  DiameterIn and Location are also left alone on refresh: the per-event measurements live on
  RodStaging.DiameterIn and RodCheckin.DiameterMeasuredIn, and staging overwrites Location with
  the payoff position.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  C1. THERE IS NO ROD-DIAMETER COLUMN IN proddb..coils. The nearest is coil_gauge, which is a
      STRIP GAUGE; reading it as a wire diameter would be a convention dressed as a fact.
      Rod.DiameterIn is NOT NULL with CHECK > 0, and it does not need one: the operator measures
      the rod at staging (PCI004) and again at check-in, so both write paths already carry the
      value. *** THIS IS ITSELF THE ARGUMENT FOR INGESTING AT FIRST WRITE RATHER THAN AT
      RECEIPT *** - at receipt there is no measurement to use.

  C2. THERE IS NO SUPPLIER-HEAT COLUMN EITHER, and this one is NOT solved.
      FlatWireSchema_Materials.md says the rod record "links material certification data
      (supplier heat) to the finished output coil via CoilTraceability" - the welding-wire
      customer certificate chain, an MVP-1 obligation. coils has no heat column, no payload
      carries one, and coil_origin_code is a one-character origin flag, not a heat number.
      [INT 8] lists "Lots / chemistry - the far end of the cert chain - Read", which is the
      likely source and is unmapped.
      *** OI-117. The column is left NULL DELIBERATELY, not by oversight. Do not invent a value
      and do not reuse coil_origin_code for it. ***

  C3. coils.coil_alloy is SMALLINT and Rod.Alloy is VARCHAR(10) holding '1100'. That is a LOOKUP
      through united_db..alloys (alloy_idx -> alloy), NOT A CAST. Getting it wrong does not
      fail - it stores the numeric code as text and every alloy comparison downstream silently
      stops matching, which is the worst failure mode available.
      (It reads the table AlloyProperty shadows - OI-93.)

  C4. coils weight columns are SMALLINT and NULLABLE; Rod weights are DECIMAL(8,2) NOT NULL.
      Nulls become 0 rather than raising: the OPERATIONAL weights are the operator's, verified
      at check-in and stored on RodCheckin, so an as-received blank is not worth blocking a run
      over. A rod is ~9,000 lb, well inside the smallint bound, so there is no overflow path.

  C5. coils.coil_temper is NULLABLE and Rod.Temper is NOT NULL. An absent temper defaults to
      'O' (annealed), which is the rod condition flat wire receives.

  IDEMPOTENCY
  -----------
  Fully idempotent. Called twice in one transaction it creates once and refreshes once, and
  @rodExisted reports which happened. That is what lets staging and check-in both call it
  unconditionally without either needing to know whether the other ran.

  ERROR NUMBERS - allocated in a block so the caller can map without string matching
  ---------------------------------------------------------------------------------
      55001         called outside a transaction    -> 500 (a programming error)
      55002 - 55003 validation                      -> 422
      55004         rod absent from proddb..coils   -> 404 ROD_NOT_FOUND
      55005         alloy code does not resolve     -> 422

  DEPLOYMENT
  ----------
  Run AFTER FlatWire_DDL_RunAll.sql (which creates [Rod]) and AFTER 20_FlatWire_Grants.sql (which
  gives the account its read on proddb and united_db). Deploy it in the same step as the four
  united_db procedures.

  *** FlatWireDB MUST BE ON THE SAME INSTANCE as proddb and united_db. *** The projection reads
  both inside the caller's transaction. The procedure CREATES on any instance - SQL Server
  defers name resolution - so a successful deploy proves nothing about this. Verify with the
  co-location query in 20_FlatWire_Grants.sql.
==============================================================================================*/

USE [FlatWireDB];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_IngestRodFromCoils]
      @rodAlpha            VARCHAR(20)
    , @diameterMeasuredIn  DECIMAL(8,4)                  -- operator-measured (C1)
    , @createdBy           VARCHAR(50)
    , @rodExisted          BIT = NULL OUTPUT             -- 0 = created, 1 = refreshed
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @alloy      VARCHAR(10)
          , @temper     VARCHAR(10)
          , @gross      DECIMAL(8,2)
          , @net        DECIMAL(8,2)
          , @invType    VARCHAR(20)
          , @location   VARCHAR(50)
          , @receivedAt DATETIMEOFFSET
          , @found      BIT = 0;

    SET @rodExisted = 0;

    -- The caller owns the transaction. See THE TRANSACTION BOUNDARY.
    IF @@TRANCOUNT = 0
        THROW 55001, 'sp_IngestRodFromCoils must be called inside the caller''s transaction: the mirror row and the run records commit together.', 1;

    SET @rodAlpha  = LTRIM(RTRIM(ISNULL(@rodAlpha, '')));
    SET @createdBy = LTRIM(RTRIM(ISNULL(@createdBy, '')));

    IF @rodAlpha = ''
        THROW 55002, 'sp_IngestRodFromCoils: @rodAlpha is required.', 1;

    -- C1: Rod.DiameterIn is NOT NULL with CHECK > 0 and coils cannot supply it.
    IF ISNULL(@diameterMeasuredIn, 0) <= 0
        THROW 55003, 'sp_IngestRodFromCoils: @diameterMeasuredIn must be greater than zero. proddb..coils has no rod-diameter column, so the operator measurement is the only source (C1).', 1;

    /*------------------------------------------------------------------------------------------
      1. Project from the shared schema.
         LEFT JOIN on alloys so a missing lookup row is reported as itself (55005) rather than
         as a missing rod - the two failures have different causes and different fixes.
    ------------------------------------------------------------------------------------------*/
    SELECT   @found      = 1
           , @alloy      = LTRIM(RTRIM(ISNULL(a.[alloy], '')))                     -- C3: lookup, not cast
           , @temper     = LTRIM(RTRIM(ISNULL(c.[coil_temper], '')))
           , @gross      = CAST(ISNULL(c.[coil_gross_wgt], 0) AS DECIMAL(8,2))     -- C4
           , @net        = CAST(ISNULL(c.[coil_net_wgt],   0) AS DECIMAL(8,2))     -- C4
           , @invType    = NULLIF(LTRIM(RTRIM(ISNULL(c.[inventory_type],  ''))), '')
           , @location   = NULLIF(LTRIM(RTRIM(ISNULL(c.[storage_section], ''))), '')
           , @receivedAt = ISNULL(CAST(c.[coil_recvd_date] AS DATETIMEOFFSET), SYSDATETIMEOFFSET())
    FROM     [proddb].[dbo].[coils] AS c WITH (NOLOCK)
             LEFT JOIN [united_db].[dbo].[alloys] AS a WITH (NOLOCK)
                    ON a.[alloy_idx] = c.[coil_alloy]
    WHERE    c.[coil_no] = @rodAlpha;

    IF @found = 0
        THROW 55004, 'sp_IngestRodFromCoils: ROD_NOT_FOUND - the rod has no proddb..coils row. Rod receipt is upstream of flat wire and must have happened first.', 1;

    -- C3. Rod.Alloy is NOT NULL, and storing the numeric code as text would silently break every
    -- alloy comparison downstream rather than failing here.
    IF @alloy = ''
        THROW 55005, 'sp_IngestRodFromCoils: the rod alloy code does not resolve in united_db..alloys, so Rod.Alloy cannot be set (C3).', 1;

    IF @temper = ''
        SET @temper = 'O';                                                          -- C5

    /*------------------------------------------------------------------------------------------
      2. Insert or refresh, under UPDLOCK/HOLDLOCK so the existence test and the write are one
         act - two payoff bays on one line can stage two rods concurrently.
    ------------------------------------------------------------------------------------------*/
    IF EXISTS (SELECT 1 FROM [dbo].[Rod] WITH (UPDLOCK, HOLDLOCK) WHERE [Alpha] = @rodAlpha)
    BEGIN
        SET @rodExisted = 1;

        -- *** SHARED-MASTERED COLUMNS ONLY. *** Status, FootageRunToDate,
        -- RemainingWeightEstimateLb, DiameterIn and Location are NOT touched - see
        -- WHICH SIDE IS MASTER FOR EACH COLUMN. This is why it is not a MERGE.
        UPDATE  [dbo].[Rod]
        SET     [Alloy]         = @alloy
              , [Temper]        = @temper
              , [GrossWeightLb] = @gross
              , [NetWeightLb]   = @net
              , [InventoryType] = @invType
              , [ModifiedBy]    = NULLIF(@createdBy, '')
              , [ModifiedAt]    = SYSDATETIMEOFFSET()
        WHERE   [Alpha] = @rodAlpha;
    END
    ELSE
    BEGIN
        SET @rodExisted = 0;

        INSERT INTO [dbo].[Rod]
                ( [Alpha], [Alloy], [Temper], [DiameterIn]
                , [GrossWeightLb], [NetWeightLb], [SupplierHeat], [InventoryType]
                , [Status], [Location], [ReceivedAt], [CreatedBy] )
        VALUES  ( @rodAlpha
                , @alloy
                , @temper
                , @diameterMeasuredIn                    -- C1: the operator's measurement
                , @gross
                , @net
                , NULL                                   -- C2: OI-117 - deliberately NULL
                , @invType
                , 'RECEIVED'                             -- staging / check-in move it on from here
                , @location
                , @receivedAt
                , NULLIF(@createdBy, '') );
    END

    RETURN 0;
END
GO

GRANT EXECUTE ON [dbo].[sp_IngestRodFromCoils] TO [public] AS [dbo];
GO

PRINT 'Created procedure: FlatWireDB.dbo.sp_IngestRodFromCoils';
GO

/*==============================================================================================
  VERIFICATION
  ---------------------------------------------------------------------------------------------
  Requires FlatWireDB co-located with proddb and united_db. The procedure CREATES anywhere -
  deferred name resolution - so a clean deploy proves nothing; these do.

  DECLARE @existed BIT, @rod VARCHAR(20) = 'R00041';

  -- 1. THE CONTRACT: it refuses outside a transaction.
  EXEC dbo.sp_IngestRodFromCoils @rodAlpha=@rod, @diameterMeasuredIn=0.375,
       @createdBy='qa', @rodExisted=@existed OUTPUT;              -- expect 55001

  -- 2. CREATE, then REFRESH. @rodExisted reports which happened.
  BEGIN TRAN;
    EXEC dbo.sp_IngestRodFromCoils @rodAlpha=@rod, @diameterMeasuredIn=0.375,
         @createdBy='qa', @rodExisted=@existed OUTPUT;
    SELECT @existed AS firstCall;                                  -- 0
    EXEC dbo.sp_IngestRodFromCoils @rodAlpha=@rod, @diameterMeasuredIn=0.375,
         @createdBy='qa', @rodExisted=@existed OUTPUT;
    SELECT @existed AS secondCall;                                 -- 1
    SELECT COUNT(*) AS rowsForRod FROM dbo.Rod WHERE Alpha = @rod; -- 1
  COMMIT;

  -- 3. THE ALLOY IS A LOOKUP, NOT A CAST (C3). Expect '1100', never '1'.
  SELECT r.Alpha, r.Alloy, r.Temper, r.DiameterIn, r.SupplierHeat, r.Status
  FROM   dbo.Rod AS r WHERE r.Alpha = @rod;
  SELECT c.coil_no, c.coil_alloy AS code, a.alloy AS resolved
  FROM   proddb..coils AS c LEFT JOIN united_db..alloys AS a ON a.alloy_idx = c.coil_alloy
  WHERE  c.coil_no = @rod;

  -- 4. *** THE ONE THAT MATTERS: a refresh must not clobber local state. ***
  UPDATE dbo.Rod SET Status='INFLAT', FootageRunToDate=6400, RemainingWeightEstimateLb=4200
  WHERE  Alpha = @rod;
  BEGIN TRAN;
    EXEC dbo.sp_IngestRodFromCoils @rodAlpha=@rod, @diameterMeasuredIn=0.999,
         @createdBy='qa', @rodExisted=@existed OUTPUT;
  COMMIT;
  SELECT Status, FootageRunToDate, RemainingWeightEstimateLb, DiameterIn, GrossWeightLb
  FROM   dbo.Rod WHERE Alpha = @rod;
  -- Status still INFLAT, footage still 6400, estimate still 4200, DiameterIn still 0.375
  -- (NOT 0.999), and the weights refreshed from coils. Anything else means the refresh has
  -- become a MERGE and carry-forward is broken.

  -- 5. Unknown rod: refused, and nothing written.
  BEGIN TRAN;
    EXEC dbo.sp_IngestRodFromCoils @rodAlpha='R99999', @diameterMeasuredIn=0.375,
         @createdBy='qa', @rodExisted=@existed OUTPUT;             -- expect 55004
  ROLLBACK;
  SELECT COUNT(*) AS shouldBeZero FROM dbo.Rod WHERE Alpha = 'R99999';

  -- 6. Both procedures present on a deployed database (the schema runner creates only one).
  SELECT name FROM sys.procedures ORDER BY name;
  -- sp_GetGaugeTrace, sp_IngestRodFromCoils.  sp_ShiftSummary must NOT appear - it is MVP-2's.
==============================================================================================*/
