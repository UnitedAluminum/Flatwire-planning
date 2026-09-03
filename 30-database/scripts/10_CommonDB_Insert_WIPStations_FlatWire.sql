/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 10_CommonDB_Insert_WIPStations_FlatWire.sql
  Target DBs   : united_db (dbo.machines)
                 CommonDB  (dbo.WIPStations, dbo.MachineStationsConfiguration)
  Last Updated : 2026-07-28
  Status       : Draft - machine_type, station set and StationType pending sign-off (see DECISIONS)
  Story        : FW-003 (Register FL1, FL2, FL3 in the Machines application)

  PURPOSE
  -------
  Registers the three new Flattening Lines as machines, seeds the shop-floor WIP station rows
  for them plus the shared flat wire packing station, then binds each station to its machine.
  All three parts live in one script because each depends on keys the previous one creates,
  so the order is fixed:

      1. united_db.dbo.machines                     <- FL1, FL2, FL3            (4a)

  G21 (15 Aug 2026): the ABSENCE of an FL3PO station is DELIBERATE, not an omission.
  FL1 and FL3 SHARE ONE physical payoff station, FL1PO -- Dashboard 2A maps
  STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"}, and the client confirmed rods are
  never stacked, two maximum, one per payoff (Q71).  RodStaging.Station carries that
  value and UX_RodStaging_Bay is keyed on it.  DO NOT "fix" this by seeding FL3PO --
  doing so would let two rods occupy one physical bay with every constraint satisfied,
  which is exactly the defect G21 recorded.
      2. resolve MachineIdx from what 4a created                                (4b)
      3. CommonDB.dbo.WIPStations                   <- FL1, FL2, FL3, FWPACK    (4c, 4d)
      4. CommonDB.dbo.MachineStationsConfiguration  <- one row per station      (4e)
         (needs the WIPStationId IDENTITY values minted in 4c)

  WIPStations is the shared shop-floor station registry: it gives each physical station its
  short code, its owning machine, and its label printer, and it is surfaced through:

      united_db..wip_stations          (view over CommonDB..WIPStations)
      proddb..wip_stations             (view over CommonDB..WIPStations)
      SlitterDB..WIPStations           (view over CommonDB..WIPStations)
      CommonDB.dbo.GetStationDetails   (TVF - INNER JOINs Machines on MachineIdx)
      CommonDB.dbo.Common_GetMachineStationsConfiguration

  MachineStationsConfiguration is what turns a station into something a shop-floor client can
  actually open: the client passes its config row Id and gets back machine + station identity via
  CommonDB.dbo.Common_GetMachineStationsConfiguration and
  united_db.dbo.GetMachineIdAndStationFromMachineConfig.

  Two switches:
      @SeedMachines      = 0  skips 4a - use if FL1/FL2/FL3 will be created through the Machines
                              application UI instead; 4b then resolves whatever is already there.
      @SeedStationConfig = 0  skips 4e - use if the station/PC bindings will be configured by hand.

  IDEMPOTENCY
  -----------
  Safe to re-run.
    - machines:    INSERT-only. An existing FL1/FL2/FL3 row is reported and left completely
                   alone (see D10) - capability data is maintained in the Machines application
                   and a seed script must not overwrite it.
    - WIPStations: existing rows are matched on WIPStation and have only their *configuration*
                   columns refreshed (MachineIdx, StationType, ZeroPassFlag, FirstBuildupFlag,
                   PrinterName). Runtime state columns (CoilNo, StationNoCutsSetUp, the five
                   weight columns) are written on INSERT only and never overwritten, so
                   re-running against a live line cannot clobber a coil that is checked in.
    - MachineStationsConfiguration: rows are matched on WindowsUserName (the station code) and
                   have MachineId, WipStationId, StationType and LinkURL refreshed. Id is an
                   IDENTITY and is never touched, so a client already pointed at a config Id
                   keeps working across re-runs.
  Everything runs in one transaction, so a failure anywhere leaves no table half-seeded.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  united_db.dbo.machines
    - machine_idx is INT NOT NULL, PK, and is NOT an IDENTITY column: the value must be
      assigned explicitly (see D9). Max in use as of 2026-07-28 is 124.
    - machine_name is nullable with NO unique index, so duplicate names are possible. Section 2
      aborts on a duplicate rather than letting the MachineIdx lookup match two rows.
    - Only machine_idx and oil_reduction_procedure_capable are NOT NULL; everything else may be
      left NULL.
    - status must be 1 or the machine is invisible to CommonDB.dbo.Machines, whose definition
      ends `WHERE m.STATUS = 1`. That view is what section 4 reads, and what
      Common_GetMachineStationsConfiguration joins - so status = 1 is mandatory, not cosmetic.

  CommonDB.dbo.WIPStations carries two UNIQUE indexes and no declared primary key:
      wip_stations_k0  UNIQUE CLUSTERED    on WIPStation
      wip_stations_k1  UNIQUE NONCLUSTERED on CoilNo   <-- the non-obvious one
  The index on CoilNo enforces "a coil is checked in at no more than one station at a time".
  Because it is a plain UNIQUE index, only ONE row may hold CoilNo = NULL, so an idle station
  cannot be seeded with NULL. The established convention is that an idle station parks its own
  station name in CoilNo as a guaranteed-unique placeholder - see the checkout path in
  SlitterDB.dbo.SlitterInterface_CheckoutCoil:

      UPDATE proddb..wip_stations
         SET coil_no = wip_station, station_no_cuts_set_up = 0, ...

  All 78 pre-existing rows follow this (verified 2026-07-28: every CoilNo equals its own
  WIPStation). This script seeds CoilNo the same way.

  CommonDB.dbo.MachineStationsConfiguration has NO indexes at all - it is a heap with an
  IDENTITY Id and not even a declared primary key, so nothing stops duplicate rows for the same
  station. 4e guards that itself by matching on WindowsUserName before inserting.
  Both of its joins in Common_GetMachineStationsConfiguration are INNER JOINs:
      mc.MachineId    -> Machines.MachineIdx   (the view, so the machine needs status = 1)
      mc.WipStationId -> WipStations.WipStationId
  A row with either side unresolvable returns nothing from that SP - which is why 4e refuses to
  write a row it cannot fully resolve rather than leaving a silently dead config Id behind.

  DECISIONS / ASSUMPTIONS  (confirm before running outside DEV)
  ------------------------------------------------------------
  D1. Station granularity. One WIP station per line (FL1 / FL2 / FL3), NOT one per mill
      component. The pass-schedule components (DB1, DB2, FM1, FM2_S1/S2/S3, EdgeSet)
      are not material check-in points - they are modelled in FlatWireDB (Stand / Drawer / Edger /
      PassScheduleComponent) and do not belong in the shared shop-floor station registry.
      See the optional block at the foot of this file if component-level stations are wanted.

  D2. FL1 payoff station IS created; FL2's is not.  [REVISED Jul 29 2026]
      Flat wire does NOT use the legacy precheckin flow (PreCheckIn_PreCheckInCheckIn_Transaction),
      and Architecture/Architecture.md Sec 0.2 rules the `checkin-precheckin` Angular library
      explicitly out as a reference. Both of those remain true.
      BUT that is a statement about the legacy *implementation*, not about the feature: SRS 4.2
      PCI003 requires a dedicated Pre-Check-In station for FL1, where the next rod is registered
      against a VPS payoff bay while the current coil is still running (PCI001). FL1PO is therefore
      created below, backed by FlatWireDB.RodStaging and Dashboard 2A - a flat-wire-native flow,
      not the legacy one.
      FL2PO is deliberately NOT created: PCI002 excludes FL2 from pre-check-in (no staging space).
      Legacy equivalents for reference: N36PRE, UA36PRE, D72PRE, R48PRE, ZR23PO, ZR24PO.
      See MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md.

  D3. WIPStations.StationType = 'R' for the three lines. 'R' is the existing letter for rolling
      mills (ZR23, ZR24); the flattening mills are rolling mills. Blast-radius check performed
      against every StationType filter in CommonDB / united_db / proddb / SlitterDB - each one is
      also scoped by machine_idx or is invoked from a machine-specific context
      (e.g. SlitterInterface_GetHeadLossDetails: `station_type IN ('F','S','T') AND machine_idx = @machineId`),
      so no legacy slitter/mill query picks up flat wire stations. 'F' was rejected: it is a
      legacy grab-bag on this column (N36, PDCTRL, REPORT, TRAIN, OFFSYT) despite 'F' being the
      correct *operation* letter for flattening.
      FWPACK uses 'P', matching the existing PACKNG / PKLINE packing stations.

  D4. ZeroPassFlag / FirstBuildupFlag = 'N'. Zero pass and coil buildup are rolling-mill/coil
      concepts with no flat wire equivalent (flat wire feeds from rod). Note the legacy checkout
      path resets these to 'Y' (see SlitterInterface_CheckoutCoil above), which is why 62 of the
      78 existing rows are 'Y'/'Y'. 'N' is chosen deliberately as the fail-safe: if any generic
      shop-floor query reads these flags for a flat wire station, 'N' answers "not a zero pass /
      not a first buildup", whereas 'Y' would invite a zero-pass or buildup decision that has no
      meaning on a flattening line. Flat wire never invokes the legacy check-in/checkout SPs, so
      nothing will rewrite them.

  D5. FWPACK is left with MachineIdx NULL by design, matching the existing PACKNG and PKLINE
      rows. The packing station serves all three lines (MVP-1/ProjectPlan/Frontend/Mockups/dashboard_7b_packing_station.html
      shows FL1/FL2/FL3 tiles), so it maps to no single machine.

  D6. Column padding. Existing rows store WIPStation space-padded to exactly 6 characters and
      PrinterName space-padded to exactly 12 (verified with DATALENGTH). The literals below
      preserve that convention; the verification step at the end asserts it.

  D7. CoilNo is seeded to the station's own name, padded to 9 characters - required by the unique
      index on CoilNo (see TABLE CONSTRAINTS above), and matching how all 78 existing rows sit.
      A legacy checkout would rewrite it to the 6-character form ('FL1   '); that is harmless
      because SQL Server ignores trailing spaces when comparing strings.

  D8. *** machine_type = 1 (rolling mill) - THE OPEN ITEM ON THIS SCRIPT. ***
      There is no documented decision for flat wire, and it is not a cosmetic choice: type 1 is
      what every existing mill query, report and dropdown filters on, so FL1/FL2/FL3 will start
      appearing alongside ZR23/ZR24 wherever machine_type = 1 is used. Reasoning for 1: the
      flattening lines are rolling mills, FW-003 puts the Speed and Material Loss tabs on the
      Mill template, and type 1 gives the lines working behaviour on day one. Against: FW-003
      also describes the machine template as a Slitter+Mill hybrid (most tabs come from the
      Slitter template), which could argue for a brand-new type instead.

      NEW EVIDENCE, 31 Aug 2026 - it points AGAINST type 1. The client returned the field
      sets for four flat wire tabs, and they are disjoint from both parents: Material Loss
      drops ~36 Mill sleeve/pass scenarios for 7-10 flat-wire fields; Tooling Inventory
      carries three tool types where the Slitter has five; the Flattening Line Schedule grid
      is component-sequenced where the Mill's is pass-numbered. The instruction was "all
      others will be removed". That is only safe to execute if the flat wire screens are
      INDEPENDENT of ZR23/ZR24's - under a shared machine type driving shared tab
      configuration, executing it would strip columns from the mills too.

      STRENGTHENED, 3 Sep 2026 (D-42). The "three tool types" above is now FOUR - the
      client added roll sets (mill rolls and the DB1/DB2 capstan rolls) and excluded
      dancers, entry guides, payoffs and spools by name. The 31 Aug figure is kept as
      written because it is the dated evidence; the point it was making only gets
      stronger. Four types against the Slitter's five, with no overlap in the field
      sets, is harder still to express as one inherited machine type. D8 STAYS OPEN -
      this is more evidence for it, not a decision. The client also
      said, of three separate tabs, "this will be different for FL1 & FL2/FL3 as each machine
      has its own capabilities" - so the configuration is not uniform even across the three
      flattening lines, which no single inherited mill type expresses.

      NOT A DECISION, AND THIS SCRIPT IS UNCHANGED. Whether tab configuration is actually
      keyed on machine_type in the Machines Application has NOT been verified - ual-dot-net
      was not read. Confirm against that code before choosing. @FlatWireMachineType is
      deliberately left at 1. See 95-archive/source-documents/
      ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md section 4.7.
      RELATED GAP, not fixed here: AccountingDB.dbo.GetMachineTypeFromOpLetter maps op letters
      to machine types ('R'->1, 'T'/'X'/'S'->2, 'I'->3, 'P'->4, 'A'->5) and has NO case for the
      flattening letter 'F', so it returns NULL for flat wire today. That function needs a 'F'
      case whichever machine_type is chosen. Also note united_db.dbo.c_machine_type - the
      nominal lookup for these values - is EMPTY on DEV, so the numbers are convention only.
      To change: edit @FlatWireMachineType (and @TypeSpecificProp) in section 1.

  D9. machine_idx 125 / 126 / 127, assigned explicitly (the column is not an IDENTITY). Fixed
      values rather than MAX+1 so that DEV, TEST and PROD end up with the same ids - machine ids
      are referenced from config, reports and PLC mappings, and divergence between environments
      is expensive. Section 2 aborts if any of the three is already taken by a different machine.

  D10. machines rows are INSERT-only; an existing FL1/FL2/FL3 is left untouched. The capability
      columns are owned by the Machines application, and silently resetting a value an engineer
      tuned there would be worse than doing nothing. Re-running reports "already exists" and
      moves on to the station seed.

  D11. Machine capability values are PROVISIONAL. They are derived from this repo's own design
      data - Schema/SQL/FlatWire_SampleData_Lookup.sql: Stand gauge/width ranges (FM1
      0.0700-0.2000 in gauge, FM2 0.0700-0.1600, both 0.4000-0.9000 in width) and the TKUP-1
      Spool article rows (max 3500 lb, max OD 40 in, core 8-12 in) -- these limits were
      SpoolConfiguration's until it merged into Spool on 23 Aug 2026 (Q60). FW-003 records the
      Naj/Bob/Tim standards spreadsheet as an unfinished external dependency, so these must be
      reviewed against it before production. Columns with no documented source are left NULL
      rather than guessed: cost_center_idx (needs Accounting), account_idx, ast_idx,
      sched_sort_seq, max_flatnesss, max_edge, max_surface, and the rod-side input OD/weight.
      max_number_cuts and mim_knife_width stay NULL on purpose - FW-003 removes "Max # of Cuts"
      for flat wire.

  D12. MachineStationsConfiguration.StationType = 0. Beware: this is an INT and a completely
      different vocabulary from the CHAR(1) StationType on WIPStations. The values are
      united_db.dbo.lookups ids in lookup_category 4198 ("Station Type"):
          21710 = PREP        21711 = HEAD SETUP        21712 = SLIT        0 = none
      The app resolves the id to its display_name and passes that string on - see
      Common_GetHamburgerMenuItems(@stationName, @stationType, @sectionName), documented with the
      example call `Common_GetHamburgerMenuItems 'U36','SLIT','Traveler'`.
      0 is right for flat wire on two counts: none of PREP / HEAD SETUP / SLIT is a phase a
      flattening line has, and 'SLIT' would be actively wrong under this project's terminology
      rule (always "flat wire", never "strip"/slit). 0 is also the majority value - 24 of the 34
      existing rows use it, including every conveyor, rewind, inspection and the three most
      recently added rows. It keeps flat wire out of a shared hamburger-menu lookup that has no
      CommonMenuOptions rows for it anyway; the flat wire UI ships its own chrome (see
      MVP-1/ProjectPlan/Frontend/Mockups/flat-wire-topbar.js).
      If a flat wire phase is ever wanted in the shared menu, add a row to lookups in category
      4198 (e.g. display_name 'FLATTEN') and put its lookup_id here - do not reuse 21712.

  D13. WindowsUserName = the station code ('FL1', 'FL2', 'FL3', 'FWPACK', 'FL1PO'), NOT a Windows account.
      The column name is a legacy misnomer: united_db.dbo.GetMachineIdAndStationFromMachineConfig
      selects `WindowsUserName AS [Station]`, and all 34 existing rows hold station codes
      ('D72', 'N36HD1', 'ZR23PO'). So it matches the WIPStation name, which is what 4e writes.

  D14. FWPACK gets a config row only if @PackingMachineIdx is set. Every existing config row has
      a real MachineId, and Common_GetMachineStationsConfiguration INNER JOINs machines, so a row
      with MachineId NULL would be unreadable. Flat wire has no packing machine registered, so
      the id is a client decision: point it at the existing PACKNG machine (machine_idx 85) or at
      a new flat wire packing machine. Left NULL, 4e skips FWPACK and says so - the other three
      stations are unaffected.

  D15. AssociatedMachineId = NULL. It is NULL on all 34 existing rows and no stored procedure
      reads it (Common_GetMachineStationsConfiguration only passes it through to the client), so
      there is no precedent to copy. Worth revisiting for FL3, where it could legitimately link
      the hybrid route back to FL1/FL2 - but that is a design decision, not a seed value.
      LinkURL = '' likewise matches all 34 existing rows (empty string, not NULL).
==============================================================================================*/

USE [CommonDB];
GO

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*----------------------------------------------------------------------------------------------
  1. Configuration - the only things you should normally need to edit
----------------------------------------------------------------------------------------------*/
DECLARE @SeedMachines        BIT = 1;    -- 0 = skip 4a, resolve existing machines only
DECLARE @SeedStationConfig   BIT = 1;    -- 0 = skip 4e (MachineStationsConfiguration)
DECLARE @FlatWireMachineType INT = 1;    -- see D8
DECLARE @TypeSpecificProp    INT = 50;   -- mill property set, matching ZR23 / ZR24 (60 = slitter)
DECLARE @CreatedBy           INT = NULL; -- set to the deploying user's id if you want it recorded

DECLARE @ConfigStationType   INT = 0;    -- lookups id in category 4198; see D12
DECLARE @PackingMachineIdx   INT = NULL; -- machine for FWPACK's config row; NULL = skip it (D14)

DECLARE @FL1Idx INT = 125;               -- see D9
DECLARE @FL2Idx INT = 126;
DECLARE @FL3Idx INT = 127;

/*----------------------------------------------------------------------------------------------
  2. Desired machine set + pre-flight guards
     Capability values are provisional - see D11.
----------------------------------------------------------------------------------------------*/
DECLARE @FlatWireMachines TABLE
(
      [MachineIdx]       INT         NOT NULL PRIMARY KEY
    , [MachineName]      VARCHAR(31) NOT NULL UNIQUE
    , [MaxCoilOdIn]      FLOAT       NULL     -- incoming max OD (in)
    , [MaxCoilOdOut]     FLOAT       NULL     -- outgoing max OD (in)
    , [MaxCoilWeightIn]  FLOAT       NULL     -- incoming max weight (lb)
    , [MaxCoilWeightOut] FLOAT       NULL     -- outgoing max weight (lb)
    , [MinCoilWidth]     FLOAT       NULL     -- min flat width (in)
    , [MaxCoilWidth]     FLOAT       NULL     -- max flat width (in)
    , [MinCoilGauge]     FLOAT       NULL     -- min gauge (in)
    , [MaxCoilGauge]     FLOAT       NULL     -- max gauge (in)
    , [MinIdIn]          FLOAT       NULL     -- min core / arbor diameter (in)
    , [MaxIdIn]          FLOAT       NULL     -- max core / arbor diameter (in)
    , [Descr]            VARCHAR(200) NOT NULL
);

INSERT INTO @FlatWireMachines
        ( [MachineIdx], [MachineName]
        , [MaxCoilOdIn], [MaxCoilOdOut], [MaxCoilWeightIn], [MaxCoilWeightOut]
        , [MinCoilWidth], [MaxCoilWidth], [MinCoilGauge], [MaxCoilGauge]
        , [MinIdIn], [MaxIdIn], [Descr] )
VALUES
      -- FL1: rod in (no documented rod-bundle OD/weight yet), TKUP-1 spool out.
      ( @FL1Idx, 'FL1'
      , NULL, 40.0, NULL, 3500.0
      , 0.40, 0.90, 0.07, 0.20
      , 8.0, 12.0
      , 'FL1 standalone flattening line: rod -> DB1/DB2 draw -> FM1 12in mill -> TKUP-1 intermediate spool' )

      -- FL2: TKUP-1 spool in, coreless oscillated coil out (coreless, so no core ID).
    , ( @FL2Idx, 'FL2'
      , 40.0, NULL, 3500.0, NULL
      , 0.40, 0.90, 0.07, 0.16
      , NULL, NULL
      , 'FL2 standalone finishing line: spool -> FM2 stands (S1 8in, S2 6in, S3 6in) -> coreless oscillated coil' )

      -- FL3: rod in, coreless coil out, continuous - inherits FL1 input and FL2 output limits.
    , ( @FL3Idx, 'FL3'
      , NULL, NULL, NULL, NULL
      , 0.40, 0.90, 0.07, 0.16
      , NULL, NULL
      , 'FL3 hybrid continuous route: FL1 feeding FL2, no intermediate anneal and no intermediate spool' );

-- Guard: a target machine_idx must be free, or already hold the machine we mean.
IF EXISTS ( SELECT 1
            FROM   [united_db].[dbo].[machines] AS m
                   INNER JOIN @FlatWireMachines AS fwm
                       ON m.[machine_idx] = fwm.[MachineIdx]
            WHERE  ISNULL(RTRIM(m.[machine_name]), '') <> fwm.[MachineName] )
BEGIN
    PRINT 'Conflicting machine_idx values already in use:';
    SELECT    fwm.[MachineName]        AS [WantedName]
            , fwm.[MachineIdx]         AS [WantedIdx]
            , RTRIM(m.[machine_name])  AS [OccupiedBy]
    FROM      [united_db].[dbo].[machines] AS m
              INNER JOIN @FlatWireMachines AS fwm
                  ON m.[machine_idx] = fwm.[MachineIdx]
    WHERE     ISNULL(RTRIM(m.[machine_name]), '') <> fwm.[MachineName];

    RAISERROR('ABORT: a target machine_idx is already used by a different machine. Pick free ids in section 1 (see D9).', 16, 1);
    RETURN;
END

-- Guard: machine_name has no unique index, so a duplicate would make the MachineIdx lookup
-- in section 4 ambiguous.
IF EXISTS ( SELECT 1
            FROM   [united_db].[dbo].[machines] AS m
                   INNER JOIN @FlatWireMachines AS fwm
                       ON RTRIM(m.[machine_name]) = fwm.[MachineName]
            GROUP BY fwm.[MachineName]
            HAVING COUNT(*) > 1 )
BEGIN
    RAISERROR('ABORT: more than one machines row already carries a flat wire machine name. Resolve the duplicate first.', 16, 1);
    RETURN;
END

/*----------------------------------------------------------------------------------------------
  3. Desired station set
     MachineName is the machines lookup key; NULL means "intentionally unmapped" (see D5).
     Note the deliberate trailing spaces: WIPStation is 6 chars, IdleCoilNo 9, PrinterName 12.
----------------------------------------------------------------------------------------------*/
DECLARE @FlatWireStations TABLE
(
      [WIPStation]       VARCHAR(6)  NOT NULL PRIMARY KEY
    , [IdleCoilNo]       VARCHAR(9)  NOT NULL UNIQUE
    , [MachineName]      VARCHAR(31) NULL
    , [StationType]      CHAR(1)     NOT NULL
    , [ZeroPassFlag]     CHAR(1)     NOT NULL
    , [FirstBuildupFlag] CHAR(1)     NOT NULL
    , [PrinterName]      VARCHAR(16) NOT NULL
    , [Purpose]          VARCHAR(200) NOT NULL
);

INSERT INTO @FlatWireStations
        ( [WIPStation], [IdleCoilNo], [MachineName], [StationType], [ZeroPassFlag], [FirstBuildupFlag], [PrinterName], [Purpose] )
VALUES
      ( 'FL1   ', 'FL1      ', 'FL1', 'R', 'N', 'N', 'FL1$PRINT   '
      , 'FL1 standalone flattening line: rod check-in, DB1/DB2 draw, FM1 12" mill, TKUP-1 intermediate spool output' )
    , ( 'FL2   ', 'FL2      ', 'FL2', 'R', 'N', 'N', 'FL2$PRINT   '
      , 'FL2 standalone finishing line: spool check-in, FM2 stands (S1 8in, S2 6in, S3 6in), coreless oscillated coil output' )
    , ( 'FL3   ', 'FL3      ', 'FL3', 'R', 'N', 'N', 'FL3$PRINT   '
      , 'FL3 hybrid continuous route: FL1 feeding FL2 with no intermediate anneal and no intermediate spool' )
    , ( 'FWPACK', 'FWPACK   ', NULL , 'P', 'N', 'N', 'FWPACK$PRINT'
      , 'Shared flat wire packing / skid build station serving FL1, FL2 and FL3 (coil + skid label printing)' )
      -- FL1 Pre-Check-In station (SRS 4.2 PCI003). Registers the next rod against a VPS payoff
      -- bay while the current coil is still running (PCI001). Backed by FlatWireDB.RodStaging and
      -- Dashboard 2A - NOT the legacy PreCheckIn_PreCheckInCheckIn_Transaction flow. See D2.
      -- MachineName is FL1: the station belongs to the FL1 machine, it is not a machine itself.
      -- No FL2PO row - PCI002 excludes FL2 from pre-check-in (no staging space).
    , ( 'FL1PO ', 'FL1PO    ', 'FL1', 'R', 'N', 'N', 'FL1$PRINT   '
      , 'FL1 rod pre-check-in / VPS payoff staging: stages the next rod on the idle payoff bay while the current coil runs, enabling continuous feed through an induction weld (SRS PCI001-PCI008)' );

-- Guard: the CoilNo sentinel must not collide with a coil that is genuinely checked in
-- elsewhere, or with another station's sentinel (unique index wip_stations_k1).
IF EXISTS ( SELECT 1
            FROM   dbo.[WIPStations] AS ws
                   INNER JOIN @FlatWireStations AS fws
                       ON ws.[CoilNo] = fws.[IdleCoilNo]
            WHERE  ws.[WIPStation] <> fws.[WIPStation] )
BEGIN
    RAISERROR('ABORT: a flat wire CoilNo sentinel is already in use by another station. Resolve before seeding.', 16, 1);
    RETURN;
END

/*----------------------------------------------------------------------------------------------
  4. Apply - machines first, then resolve MachineIdx, then the stations. One transaction.
----------------------------------------------------------------------------------------------*/
DECLARE @Resolved TABLE
(
      [WIPStation]       VARCHAR(6)  NOT NULL PRIMARY KEY
    , [IdleCoilNo]       VARCHAR(9)  NOT NULL
    , [MachineName]      VARCHAR(31) NULL
    , [MachineIdx]       SMALLINT    NULL
    , [StationType]      CHAR(1)     NOT NULL
    , [ZeroPassFlag]     CHAR(1)     NOT NULL
    , [FirstBuildupFlag] CHAR(1)     NOT NULL
    , [PrinterName]      VARCHAR(16) NOT NULL
);

DECLARE @Config TABLE
(
      [WIPStation]      VARCHAR(6)   NOT NULL PRIMARY KEY
    , [WindowsUserName] VARCHAR(56)  NOT NULL
    , [MachineId]       SMALLINT     NULL
    , [WipStationId]    SMALLINT     NOT NULL
);

DECLARE @missing VARCHAR(200);
DECLARE @skipped VARCHAR(200);

BEGIN TRY
    BEGIN TRANSACTION;

    /*------------------------------------------------------------------------------------------
      4a. united_db.dbo.machines - insert the three lines if they are not registered yet.
          INSERT-only by design (D10). status = 1 is mandatory (see TABLE CONSTRAINTS).
    ------------------------------------------------------------------------------------------*/
    IF @SeedMachines = 1
    BEGIN
        INSERT INTO [united_db].[dbo].[machines]
                ( [machine_idx]
                , [machine_name]
                , [machine_type]
                , [max_coil_od_in]
                , [max_coil_od_out]
                , [max_coil_weight_in]
                , [max_coil_weight_out]
                , [max_coil_width]
                , [min_coil_width]
                , [max_coil_gauge]
                , [min_coil_gauge]
                , [max_id_in]
                , [min_id_in]
                , [created_by]
                , [created_on]
                , [Isactive]
                , [status]
                , [scheduled]
                , [outside_service]
                , [smut]
                , [type_specific_prop]
                , [qualified]
                , [oil_reduction_procedure_capable] )
        SELECT    fwm.[MachineIdx]
                , fwm.[MachineName]
                , @FlatWireMachineType
                , fwm.[MaxCoilOdIn]
                , fwm.[MaxCoilOdOut]
                , fwm.[MaxCoilWeightIn]
                , fwm.[MaxCoilWeightOut]
                , fwm.[MaxCoilWidth]
                , fwm.[MinCoilWidth]
                , fwm.[MaxCoilGauge]
                , fwm.[MinCoilGauge]
                , fwm.[MaxIdIn]
                , fwm.[MinIdIn]
                , @CreatedBy
                , GETDATE()
                , 1              -- Isactive
                , 1              -- status: REQUIRED, CommonDB.dbo.Machines filters WHERE STATUS = 1
                , NULL           -- scheduled: NULL on every existing machines row
                , 0              -- outside_service: internal machine
                , 0              -- smut
                , @TypeSpecificProp
                , 'N'            -- qualified: matches ZR23 / ZR24
                , 0              -- oil_reduction_procedure_capable
        FROM      @FlatWireMachines AS fwm
        WHERE     NOT EXISTS ( SELECT 1
                               FROM   [united_db].[dbo].[machines] AS m
                               WHERE  RTRIM(m.[machine_name]) = fwm.[MachineName] );

        PRINT 'machines: inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' flat wire row(s).';

        IF EXISTS ( SELECT 1
                    FROM   [united_db].[dbo].[machines] AS m
                           INNER JOIN @FlatWireMachines AS fwm
                               ON RTRIM(m.[machine_name]) = fwm.[MachineName]
                    WHERE  m.[status] <> 1 OR m.[status] IS NULL )
        BEGIN
            PRINT 'WARNING: a flat wire machines row has status <> 1 and will be invisible to';
            PRINT '         CommonDB.dbo.Machines (its definition ends WHERE m.STATUS = 1).';
        END
    END
    ELSE
    BEGIN
        PRINT 'machines: skipped (@SeedMachines = 0), resolving existing rows only.';
    END

    /*------------------------------------------------------------------------------------------
      4b. Resolve MachineIdx for the station rows (int on machines -> smallint on WIPStations).
          Read through CommonDB.dbo.Machines so that the status = 1 filter is exercised here
          rather than surfacing later as a mystery in GetStationDetails.
    ------------------------------------------------------------------------------------------*/
    INSERT INTO @Resolved
            ( [WIPStation], [IdleCoilNo], [MachineName], [MachineIdx], [StationType], [ZeroPassFlag], [FirstBuildupFlag], [PrinterName] )
    SELECT    fws.[WIPStation]
            , fws.[IdleCoilNo]
            , fws.[MachineName]
            , CAST(m.[MachineIdx] AS SMALLINT)
            , fws.[StationType]
            , fws.[ZeroPassFlag]
            , fws.[FirstBuildupFlag]
            , fws.[PrinterName]
    FROM      @FlatWireStations AS fws
              LEFT JOIN dbo.[Machines] AS m
                  ON  fws.[MachineName] IS NOT NULL
                  AND RTRIM(m.[MachineName]) = fws.[MachineName];

    SELECT  @missing = STUFF(( SELECT ', ' + r.[MachineName]
                               FROM   @Resolved AS r
                               WHERE  r.[MachineName] IS NOT NULL
                                      AND r.[MachineIdx] IS NULL
                               ORDER BY r.[MachineName]
                               FOR XML PATH(''), TYPE ).value('.', 'VARCHAR(200)'), 1, 2, '');

    IF @missing IS NOT NULL
    BEGIN
        PRINT 'WARNING: MachineIdx did not resolve for: ' + @missing;
        PRINT '         Those stations get MachineIdx = NULL and stay invisible to';
        PRINT '         CommonDB.dbo.GetStationDetails until the machines rows exist with status = 1.';
    END
    ELSE
    BEGIN
        PRINT 'MachineIdx resolved for all mapped stations.';
    END

    /*------------------------------------------------------------------------------------------
      4c. Insert stations that do not exist yet. Runtime state columns are seeded to the
          established idle defaults (CoilNo = own station name, cuts and all weights 0).
    ------------------------------------------------------------------------------------------*/
    INSERT INTO dbo.[WIPStations]
            ( [MachineIdx]
            , [WIPStation]
            , [CoilNo]
            , [StationNoCutsSetUp]
            , [StationType]
            , [ZeroPassFlag]
            , [FirstBuildupFlag]
            , [CoilCheckinNetWeight]
            , [CoilCheckinGrossWeight]
            , [CoilGrossMinusTagWeight]
            , [AccumlatedScrapWeight]
            , [AccumlatedTrimWeight]
            , [PrinterName] )
    SELECT    r.[MachineIdx]
            , r.[WIPStation]
            , r.[IdleCoilNo] -- idle sentinel = own station name (unique index wip_stations_k1)
            , 0             -- StationNoCutsSetUp - flat wire has no cuts
            , r.[StationType]
            , r.[ZeroPassFlag]
            , r.[FirstBuildupFlag]
            , 0, 0, 0, 0, 0 -- weight accumulators
            , r.[PrinterName]
    FROM      @Resolved AS r
    WHERE     NOT EXISTS ( SELECT 1
                           FROM   dbo.[WIPStations] AS ws
                           WHERE  ws.[WIPStation] = r.[WIPStation] );

    PRINT 'WIPStations: inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' flat wire row(s).';

    /*------------------------------------------------------------------------------------------
      4d. Refresh configuration on station rows that already exist. Runtime state untouched.
    ------------------------------------------------------------------------------------------*/
    UPDATE    ws
    SET       ws.[MachineIdx]       = COALESCE(r.[MachineIdx], ws.[MachineIdx])
            , ws.[StationType]      = r.[StationType]
            , ws.[ZeroPassFlag]     = r.[ZeroPassFlag]
            , ws.[FirstBuildupFlag] = r.[FirstBuildupFlag]
            , ws.[PrinterName]      = r.[PrinterName]
    FROM      dbo.[WIPStations] AS ws
              INNER JOIN @Resolved AS r
                  ON ws.[WIPStation] = r.[WIPStation]
    WHERE     ISNULL(ws.[MachineIdx], -1)      <> ISNULL(COALESCE(r.[MachineIdx], ws.[MachineIdx]), -1)
              OR ISNULL(ws.[StationType], '')      <> r.[StationType]
              OR ISNULL(ws.[ZeroPassFlag], '')     <> r.[ZeroPassFlag]
              OR ISNULL(ws.[FirstBuildupFlag], '') <> r.[FirstBuildupFlag]
              OR ISNULL(ws.[PrinterName], '')      <> r.[PrinterName];

    PRINT 'WIPStations: updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' existing flat wire row(s).';

    /*------------------------------------------------------------------------------------------
      4e. CommonDB.dbo.MachineStationsConfiguration - bind each station to its machine.
          Reads WipStationId back out of WIPStations because it is an IDENTITY minted in 4c.
    ------------------------------------------------------------------------------------------*/
    IF @SeedStationConfig = 1
    BEGIN
        INSERT INTO @Config ( [WIPStation], [WindowsUserName], [MachineId], [WipStationId] )
        SELECT    ws.[WIPStation]
                , RTRIM(ws.[WIPStation])        -- WindowsUserName IS the station code (D13)
                , CASE WHEN RTRIM(ws.[WIPStation]) = 'FWPACK'
                       THEN CAST(@PackingMachineIdx AS SMALLINT)   -- D14
                       ELSE ws.[MachineIdx]
                  END
                , ws.[WIPStationId]
        FROM      dbo.[WIPStations] AS ws
        WHERE     ws.[WIPStation] IN ( 'FL1', 'FL2', 'FL3', 'FWPACK', 'FL1PO' );

        -- A row whose MachineId will not resolve is unreadable through
        -- Common_GetMachineStationsConfiguration (INNER JOIN), so skip it rather than leave a
        -- dead config Id behind.
        SELECT  @skipped = STUFF(( SELECT ', ' + RTRIM(c.[WIPStation])
                                   FROM   @Config AS c
                                   WHERE  c.[MachineId] IS NULL
                                          OR NOT EXISTS ( SELECT 1
                                                          FROM   dbo.[Machines] AS m
                                                          WHERE  m.[MachineIdx] = c.[MachineId] )
                                   ORDER BY c.[WIPStation]
                                   FOR XML PATH(''), TYPE ).value('.', 'VARCHAR(200)'), 1, 2, '');

        IF @skipped IS NOT NULL
        BEGIN
            PRINT 'MachineStationsConfiguration: skipping (no resolvable machine): ' + @skipped;
            PRINT '         For FWPACK set @PackingMachineIdx in section 1 (see D14).';

            DELETE    c
            FROM      @Config AS c
            WHERE     c.[MachineId] IS NULL
                      OR NOT EXISTS ( SELECT 1
                                      FROM   dbo.[Machines] AS m
                                      WHERE  m.[MachineIdx] = c.[MachineId] );
        END

        INSERT INTO dbo.[MachineStationsConfiguration]
                ( [MachineId]
                , [WipStationId]
                , [AssociatedMachineId]
                , [WindowsUserName]
                , [StationType]
                , [LinkURL] )
        SELECT    c.[MachineId]
                , c.[WipStationId]
                , NULL                  -- AssociatedMachineId: NULL on all existing rows (D15)
                , c.[WindowsUserName]
                , @ConfigStationType    -- 0 = none; NOT the CHAR(1) vocabulary (D12)
                , ''                    -- LinkURL: '' on all existing rows, not NULL
        FROM      @Config AS c
        WHERE     NOT EXISTS ( SELECT 1
                               FROM   dbo.[MachineStationsConfiguration] AS msc
                               WHERE  RTRIM(ISNULL(msc.[WindowsUserName], '')) = c.[WindowsUserName] );

        PRINT 'MachineStationsConfiguration: inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s).';

        UPDATE    msc
        SET       msc.[MachineId]    = c.[MachineId]
                , msc.[WipStationId] = c.[WipStationId]
                , msc.[StationType]  = @ConfigStationType
                , msc.[LinkURL]      = ''
        FROM      dbo.[MachineStationsConfiguration] AS msc
                  INNER JOIN @Config AS c
                      ON RTRIM(ISNULL(msc.[WindowsUserName], '')) = c.[WindowsUserName]
        WHERE     ISNULL(msc.[MachineId], -1)    <> c.[MachineId]
                  OR ISNULL(msc.[WipStationId], -1) <> c.[WipStationId]
                  OR ISNULL(msc.[StationType], -1) <> @ConfigStationType
                  OR ISNULL(msc.[LinkURL], '~')    <> '';

        PRINT 'MachineStationsConfiguration: updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' existing row(s).';
    END
    ELSE
    BEGIN
        PRINT 'MachineStationsConfiguration: skipped (@SeedStationConfig = 0).';
    END

    COMMIT TRANSACTION;
    PRINT 'Flat wire machines + WIPStations + station config seed committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR: flat wire seed rolled back; no table was changed.';
    THROW;
END CATCH
GO

/*----------------------------------------------------------------------------------------------
  5. Verification
----------------------------------------------------------------------------------------------*/
PRINT '--- machines ---';

SELECT    m.[machine_idx]
        , RTRIM(m.[machine_name])   AS [machine_name]
        , m.[machine_type]
        , m.[type_specific_prop]
        , m.[Isactive]
        , m.[status]
        , m.[min_coil_gauge]
        , m.[max_coil_gauge]
        , m.[min_coil_width]
        , m.[max_coil_width]
        , m.[max_coil_weight_in]
        , m.[max_coil_weight_out]
        , m.[created_on]
        , CASE WHEN ISNULL(m.[status], 0) = 1 THEN 'visible to CommonDB.dbo.Machines'
               ELSE 'HIDDEN - status must be 1'
          END                       AS [Note]
FROM      [united_db].[dbo].[machines] AS m
WHERE     RTRIM(m.[machine_name]) IN ( 'FL1', 'FL2', 'FL3' )
ORDER BY  m.[machine_idx];

PRINT '--- WIPStations ---';

SELECT    ws.[WIPStationId]
        , ws.[WIPStation]
        , ws.[MachineIdx]
        , RTRIM(m.[MachineName])            AS [MachineName]
        , ws.[StationType]
        , ws.[ZeroPassFlag]
        , ws.[FirstBuildupFlag]
        , ws.[CoilNo]
        , ws.[StationNoCutsSetUp]
        , ws.[PrinterName]
        , DATALENGTH(ws.[WIPStation])       AS [WIPStationLen]   -- must be 6  (see D6)
        , DATALENGTH(ws.[PrinterName])      AS [PrinterNameLen]  -- must be 12 (see D6)
        , CASE WHEN RTRIM(ws.[CoilNo]) <> RTRIM(ws.[WIPStation])
               THEN 'IN USE - coil ' + RTRIM(ws.[CoilNo]) + ' checked in'
               ELSE 'idle'
          END                               AS [StationState]
        , CASE WHEN ws.[MachineIdx] IS NULL AND RTRIM(ws.[WIPStation]) <> 'FWPACK'
               THEN 'MachineIdx unresolved'
               ELSE 'OK'
          END                               AS [Note]
FROM      dbo.[WIPStations] AS ws
          LEFT JOIN dbo.[Machines] AS m
              ON m.[MachineIdx] = ws.[MachineIdx]
WHERE     ws.[WIPStation] IN ( 'FL1', 'FL2', 'FL3', 'FWPACK', 'FL1PO' )
ORDER BY  ws.[WIPStation];

PRINT '--- MachineStationsConfiguration ---';

-- Mirrors the two INNER JOINs in Common_GetMachineStationsConfiguration, so anything that would
-- come back empty from that SP shows up here as a NULL in ResolvedMachine / ResolvedStation.
SELECT    msc.[Id]                          AS [ConfigId]
        , msc.[WindowsUserName]             AS [Station]
        , msc.[MachineId]
        , RTRIM(m.[MachineName])            AS [ResolvedMachine]
        , msc.[WipStationId]
        , RTRIM(ws.[WIPStation])            AS [ResolvedStation]
        , msc.[StationType]
        , RTRIM(ISNULL(lk.[display_name], '(none)')) AS [StationTypeName]
        , msc.[AssociatedMachineId]
        , '[' + ISNULL(msc.[LinkURL], '<null>') + ']' AS [LinkURL]
        , CASE WHEN m.[MachineIdx] IS NULL OR ws.[WIPStationId] IS NULL
               THEN 'BROKEN - Common_GetMachineStationsConfiguration will return nothing'
               WHEN RTRIM(ISNULL(msc.[WindowsUserName], '')) <> RTRIM(ws.[WIPStation])
               THEN 'MISMATCH - WindowsUserName and WipStationId name disagree'
               ELSE 'OK'
          END                               AS [Note]
FROM      dbo.[MachineStationsConfiguration] AS msc
          LEFT JOIN dbo.[Machines] AS m
              ON m.[MachineIdx] = msc.[MachineId]
          LEFT JOIN dbo.[WIPStations] AS ws
              ON ws.[WIPStationId] = msc.[WipStationId]
          LEFT JOIN [united_db].[dbo].[lookups] AS lk
              ON lk.[lookup_id] = msc.[StationType]
WHERE     RTRIM(ISNULL(msc.[WindowsUserName], '')) IN ( 'FL1', 'FL2', 'FL3', 'FWPACK', 'FL1PO' )
ORDER BY  msc.[WindowsUserName];
GO

/*==============================================================================================
  ROLLBACK  (dev only - never run against a line with material checked in)
----------------------------------------------------------------------------------------------
  DELETE FROM CommonDB.dbo.MachineStationsConfiguration
  WHERE  RTRIM(ISNULL(WindowsUserName, '')) IN ( 'FL1', 'FL2', 'FL3', 'FWPACK', 'FL1PO' );

  DELETE FROM CommonDB.dbo.WIPStations
  WHERE  WIPStation IN ( 'FL1', 'FL2', 'FL3', 'FWPACK', 'FL1PO' );

  DELETE FROM united_db.dbo.machines
  WHERE  RTRIM(machine_name) IN ( 'FL1', 'FL2', 'FL3' );

  Keep this order - config rows reference both of the others. Note any shop-floor client pinned
  to one of the deleted config Ids will break; Id is an IDENTITY and re-running this script mints
  new ones rather than restoring the old values.

  Delete the stations before the machines: six tables carry FKs to machines (machines_speed,
  machine_mill_material_loss, Machine_Slitter_material_Loss_Migrated, furn_derived_standards,
  AlarmSnoozeLogging, AlarmTurnOnHistory) and the machines DELETE will fail if the Machines
  application has written child rows in the meantime.
==============================================================================================*/

/*==============================================================================================
  FOLLOW-ON, NOT DONE HERE
----------------------------------------------------------------------------------------------
  1. Machine template tabs. FW-003 requires ten-plus configured tabs per machine (Main, Roll
     Finish, Pass Schedule, Coating, KSI/Gauge Max Cuts, Rewind Capabilities, ID Width Max Cuts,
     Setup/Handling Times, Tooling Inventory, Speed, Material Loss, History). Those live in
     satellite tables (machines_speed, machine_mill_material_loss, ...) and are separate work.

  2. AccountingDB.dbo.GetMachineTypeFromOpLetter needs a case for the flattening op letter 'F'
     (see D8). It returns NULL for 'F' today.

  3. Each shop-floor client has to be pointed at its MachineStationsConfiguration.Id - the value
     4e mints. Run the third verification query to read the Ids back and configure the FL1 / FL2 /
     FL3 clients with them. Because Id is an IDENTITY, the numbers differ per environment.

  4. LinkURL is seeded '' to match every existing row. If the flat wire shopfloor screens are
     meant to be reachable from the shared machine-config launcher, the flat-wire route
     goes here once the Angular library has one.

  5. CommonMenuOptions / CommonButtons hold the shared hamburger-menu items, keyed by
     (StationName, StationType, SectionName). There are no rows for FL1/FL2/FL3, which is
     consistent with @ConfigStationType = 0 (see D12) and with the flat wire UI shipping its own
     chrome. Only needed if flat wire is ever folded into the shared menu.

  OPTIONAL - component-level stations (see D1). Only add these if the client wants material
  tracked at each mill component rather than at the line. Names fit the VARCHAR(6) column:
      FL1DB1 / FL1DB2  draw boxes 1 and 2          FL1FM1  12" flattening mill
      FL2S1            FM2 stand S1 (8" roller)    FL2S2 / FL2S3  FM2 stands S2 and S3 (6" rollers)
      (FM2 has three stands only; edgers sit at S2 and S3; FL1 has no edger)

  FL1PO is now seeded above (see D2) - SRS PCI003 requires it. FL2PO remains deliberately absent
  per PCI002 (FL2 has no staging space); add it only if the business later reverses that.
==============================================================================================*/
