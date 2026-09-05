/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 11_CommonDB_Insert_OPCRegistration_FlatWire.sql
  Target DBs   : CommonDB - WRITES dbo.OPCModules, dbo.OPCServerApplicationMapping,
                            dbo.OPCTags, dbo.OPCTagApplicationMapping
                          - READS  dbo.OPCServers (a LOOKUP table - D12 / D-48; this script
                            never inserts or updates a row in it)
                 united_db (dbo.machines - READ ONLY, to verify the lines are registered)
  Last Updated : 2026-09-05 (fifth pass - G100's blocking half is CLOSED on DEV00164-001, and
                 the D11 guard moved to section 0 because where it sat it could not fire)
  Status       : Draft - MUST NOT BE RUN YET, but only ONE reason is left and it is not a
                 database one:
                   (1) G100 - CLEARED on DEV00164-001. dbo.OPCModules now carries all six
                       columns and section 4a binds clean (measured 5 Sep 2026). The fix is
                       recorded as 08_CommonDB_OPCModules_ColumnDrift.sql; run that first on
                       any instance whose state you have not measured. G100 stays OPEN for
                       its other half - the deployed GetOPCServerAndTagDetails is still
                       behind source control - which does NOT block this script.
                   (2) it MUST NOT BE ACTIVATED before FW-236 / G94 merges - see D2. This is
                       now the ONLY thing between this script and a clean run, and FW-236 is
                       still not-started.
                 G97 IS CLOSED (D7). There is no placeholder left in this script.
                 Section 5's verification block was NOT run; nothing has been written anywhere.
  Story        : FW-238 (Register flat wire with OPCConnection)

  PURPOSE
  -------
  Registers the flat wire lines with the OPCConnection microservice so that GetOPCInfo can
  answer for them and WriteTag can be called at all. Closes G60. Five tables, in dependency
  order, because each depends on keys the previous one creates - but only FOUR are written:

      1. CommonDB.dbo.OPCModules                  <- one row, OPCModulesIdx 6        (4a)
      2. CommonDB.dbo.OPCServers                  <- READ ONLY. Resolve an EXISTING
                                                     endpoint's OPCServersIdx        (4b)
      3. CommonDB.dbo.OPCServerApplicationMapping <- 4 rows: each line -> BOTH        (4c)
      4. CommonDB.dbo.OPCTags                     <- 41 rows: 39 data + 2 system     (4d)
      5. CommonDB.dbo.OPCTagApplicationMapping    <- 41 rows, tag -> line + module   (4e)

  OPCServers IS A LOOKUP TABLE - NOTHING IS INSERTED OR UPDATED IN IT (D12 / D-48)
  --------------------------------------------------------------------------------
  The endpoints are site infrastructure, not per-module data: CommonDB.dbo.OPCServers already
  holds four rows, all of class SWToolbox.TOPServer.V6, shared by every module that connects.
  Flat wire JOINS two of them through OPCServerApplicationMapping (4c) and writes nothing to
  the lookup itself. So the @OPCServersIdx variables below are SELECTORS, not values to seed:
  section 3 aborts if either id is not already a row, and there is no @OPCServerName and no
  @OPCServerClass at all - both belong to whoever owns the endpoint. Do NOT "fix" a missing
  endpoint by adding an INSERT here; a new endpoint is a request to whoever owns CommonDB's
  OPC estate.

  FL3 IS DELIBERATELY NOT REGISTERED (G99 / D-47)
  -----------------------------------------------
  FL3 has no controller of its own: it reaches FM1 through FL1 and FM2 through FL2. So only
  machines 125 (FL1) and 126 (FL2) appear here, and machine 127 gets no OPC registration.
  GetOPCInfo answering an EMPTY list for FL3 is the CORRECT behaviour and is FW-151's
  tripwire, not a defect - an FL3 push must keep failing by name until G99 designs the
  two-controller write. Do NOT "fix" this by adding 127; that decision is not this script's
  to make. FL3's tags ARE FL1's and FL2's tags, already registered below.

  IDEMPOTENCY
  -----------
  Safe to re-run.
    - OPCModules:  matched on OPCModulesIdx. An existing flat wire row is left completely
                   alone; only a MISSING row is inserted, under SET IDENTITY_INSERT so the id
                   is the one we chose and not whatever the IDENTITY seed is next (D3, G96).
    - OPCServers:  nothing to be idempotent about - the row is READ, never written (D12).
    - OPCTags:     matched on TagName. Flat wire tag names are globally unique (every one
                   begins FL1.PLC. or FL2.PLC.), so TagName alone is a safe natural key here
                   even though the table carries no unique index on it.
    - OPCServerApplicationMapping: matched on (machine, module, server), so a re-run adds
                   nothing. NOTE it does NOT match on ConnectionSequence - deliberately: a row
                   whose sequence someone changed by hand is left as they left it rather than
                   silently duplicated at the sequence this script would have used.
    - OPCTagApplicationMapping: matched on its full natural key, so a re-run adds nothing.
  Everything runs in one transaction, so a failure anywhere leaves no table half-seeded.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  CommonDB.dbo.OPCModules
    - OPCModulesIdx is an IDENTITY column, so the value cannot simply be asserted the way
      machines.machine_idx is in script 10. SET IDENTITY_INSERT is required (D3).
    - IsReadOnly, ConnectionType, OPCEventType and EventDurationSeconds are all NULLable in
      the table but are NON-NULLABLE on the UA.APIDTO OPCInfo DTO that Dapper maps them into.
      A NULL in any of the four throws at GetOPCInfo. ALL FOUR ARE SET EXPLICITLY BELOW.
  CommonDB.dbo.OPCTags
    - No primary key and no unique index of any kind exists on this table in source control.
      Idempotency is therefore enforced by this script's own guards, not by the schema.
    - RequestedUpdateRate is NOT NULL and is cast unchecked to int at the subscribe call site,
      so every row must carry a real value. 1000 ms throughout - the default publication
      interval of [PLC section 5.3] and of FlatWireOpc:PublishIntervalMs.
    - TagName holds the BARE path. The ns=2;s= node-id form is applied by OPCConnection at the
      QuickOPC boundary. G94 measured 0 of 496 existing rows carrying a prefix; add none here.
  CommonDB.dbo.Machines - the view GetOPCServerAndTagDetails joins - filters STATUS = 1, so a
      machines row with any other status vanishes from result set 1 with no error at all.

  DECISIONS / ASSUMPTIONS (confirm before running outside DEV)
  ------------------------------------------------------------
  D1. OPCModuleId = 6. NOT 5. UAL.Constants.GlobalConstants.OPCModules stops at
      FurnaceScheduling = 4 so 5 looks free, but UnifiedSlitterService runs all six slitters
      on OpcModuleId 5 and does not consume that package. The live table is the register; the
      enum is documentation. G96. The guard in section 3 aborts if 6 is occupied.
  D2. ConnectionType = 21317 (GlobalConstants.Lookups.OPCUA). The lines are OPC UA.
      WARNING: this makes flat wire the FIRST module to select ual-api's OPCUAManager - G94
      measured all four existing OPCModules rows as 21316 (OPCDA). FW-236 / G94 must be
      MERGED before this registration is activated, or ReadTag and WriteTag address namespace
      0 and every push writes nowhere.
  D3. SET IDENTITY_INSERT is used on OPCModules. It requires ALTER permission on the table.
  D4. ModuleName = 'FlatWire'. No naming convention is documented for this column.
      CORRECTED 5 Sep 2026 - this note claimed the four existing rows "are single words matching
      their GlobalConstants member". MEASURED on DEV00164-001, three of the four contain SPACES:
      'Hole Detection', 'CoilReceiving', 'Handheld Service', 'Furnace Scheduling'. So there is no
      convention to match and the column is free-text. 'FlatWire' stands - it is what
      FlatWireOpc:OpcModuleId's comment and the guards below key on - but not for the stated reason.
  D5. IsReadOnly = 0. Flat wire writes tags at check-in, so the module must not be read-only -
      OPCConnection's WriteTag silently echoes the tags back unwritten when it is 1.
  D6. OPCEventType = 0 and EventDurationSeconds = 1 are placeholders chosen only to satisfy
      the non-nullable DTO (see TABLE CONSTRAINTS). They drive the SignalR timed-event flush,
      which flat wire does not use. Revisit if flat wire ever takes the SignalR path.
  D7. ANSWERED 5 Sep 2026 - G97 IS CLOSED. The flat wire lines use the OPC UA endpoint pair
      at OPCServersIdx 1 AND 2. Client direction; see D13 and D14 for the two things that
      answer turned out to mean, neither of which was the shape the question assumed.
      History, because it explains why the variables look nothing like they did: G97 asked for
      an opc.tcp:// endpoint and a security class. Measurement on DEV00164-001 (5 Sep 2026)
      narrowed it - four rows already existed, all of class 'SWToolbox.TOPServer.V6', so
      OPCTag.cs's "TOP Server v6" hint is CONFIRMED as what this site runs. D-48 narrowed it
      again - the table is a LOOKUP, so the answer had to be among rows that already exist.
      The answer then arrived as two IDS. The varchar(56) sub-risk went with D-48; there is
      nothing left of G97 to gate this script.
      D8's namespace-index question is UNAFFECTED AND STILL OPEN - it was always a separate
      question that merely travelled with G97, and it is NOT answered by this.
  D8. OPEN - the UA namespace index is the compile-time constant 2
      (OPCTag.DefaultNamespaceIndex) and nothing proves the flat wire PLCs publish there.
      FW-236's final acceptance criterion defers this as a follow-up. Ask it with D7 - one
      conversation with one engineer.
  D9. ANSWERED, and the question was the wrong shape. It asked whether FL1 and FL2 sit behind
      ONE endpoint or TWO, as though the lines had to be split between them. Neither: BOTH
      lines sit behind BOTH endpoints, as a primary/failover PAIR. See D14.
  D11. AMENDED 5 Sep 2026 - G100. A sixth pre-flight guard asserts this CommonDB MATCHES
      SOURCE CONTROL before anything is written, because "the database exists" and "the
      database is current" turned out to be different things. DEV00164-001 - the instance
      [DEP section 2] names as the test1 database server - was missing OPCModules.OPCEventType
      and .EventDurationSeconds, which ual-database declares. Section 4a inserts both, so the
      run died mid-transaction on Msg 207, which reads as a typo in THIS script.
      TWO CORRECTIONS, both from measuring rather than reading:
      (a) THE GUARD AS FIRST WRITTEN COULD NOT FIRE. It sat among the section 3 guards, in the
          same batch as section 4a, and SQL Server binds column names for an existing table at
          BATCH COMPILE time - so Msg 207 killed the batch, guard included, before a line of it
          ran. It is now SECTION 0, in a batch of its own, and proven to abort ahead of the
          seed batch. The reasoning and the two non-fixes that were tried are recorded there.
      (b) The instance is FIXED - the columns were added by hand on 5 Sep 2026 and the change
          is captured as 08_CommonDB_OPCModules_ColumnDrift.sql. The guard stays because
          [DEP section 2] still has staging and production as *fill*.
      The guard is deliberately narrow: it checks the two columns this script actually writes,
      not the whole schema. A general drift check belongs to whatever owns CommonDB, not here.
      *** It does NOT check dbo.GetOPCServerAndTagDetails, which on DEV00164-001 is STILL
      behind source control - G100's remaining half. That does not block this script (flat
      wire writes tags through WriteTag, not the SignalR hub), but read 08_ before refreshing
      that procedure: it selects both columns into a non-nullable DTO and the four
      pre-existing module rows are NULL. ***
  D12. NEW - D-48. dbo.OPCServers IS A LOOKUP TABLE: this script performs NO INSERT and NO
      UPDATE against it. Section 4b resolves an OPCServersIdx from a row that already exists
      and a pre-flight guard aborts, listing the endpoints that DO exist, if the name supplied
      is not one of them. Three things follow. (1) The registration now writes FOUR tables,
      not five, and OPCServers moves to the read side of the header. (2) @OPCServerClass is
      DELETED - nothing this script does needs it, and carrying it invited exactly the insert
      this decision forbids. (3) 16_ deletes NOTHING from OPCServers; its "only if no other
      module maps it" conservatism is not merely unnecessary now, it is wrong, because the row
      was never ours to remove.
  D13. THE IDS DO NOT MATCH THE NAMES, AND THE ENDPOINTS ARE ADDRESSED BY ID.
      MEASURED on DEV00164-001, 5 Sep 2026:
          OPCServersIdx 1 = UAOPC3        OPCServersIdx 3 = UAOPC1
          OPCServersIdx 2 = UAOPC4        OPCServersIdx 4 = UAOPC2
      So "OPCServersIdx 1 and 2" is the UAOPC3/UAOPC4 pair - NOT UAOPC1/UAOPC2, which is what
      the names invite you to assume and which is a DIFFERENT pair serving three other modules.
      That is why section 1 carries ids and not a name: the instruction was given as ids, the
      ids are the key OPCServerApplicationMapping actually stores, and translating them into
      names on the way in would have introduced exactly one opportunity to get it backwards.
      4b prints the names anyway so a reader can see which endpoints 1 and 2 are HERE.
      RE-CHECK PER ENVIRONMENT, exactly as for the module id (G96). Nothing guarantees that
      test1, staging and production number these rows the same way - the IDENTITY order is an
      artefact of insertion order, not a convention - and the guard in section 3 only proves
      the ids EXIST, which on another instance could be the wrong pair with the right numbers.
  D14. BOTH LINES MAP TO BOTH ENDPOINTS: FOUR mapping rows, not two.
      MEASURED on DEV00164-001, 5 Sep 2026: ALL 37 (module, machine) pairs in
      OPCServerApplicationMapping have EXACTLY TWO rows, ConnectionSequence 1 and 2. There is
      no single-endpoint machine anywhere in the table. And the sequence is CONSUMED, not
      decorative: GetOPCServerAndTagDetails' second result set is
          ORDER BY MachineId, ConnectionSequence
      so it hands the client an ORDERED server list per machine - primary first, failover
      second. A one-row mapping would make flat wire the only machine in CommonDB with no
      failover, and would look like a working registration right up until the primary dropped.
      ASSUMPTION, and the ONE thing here that measurement does NOT settle: this script makes
      idx 1 the primary (ConnectionSequence 1) and idx 2 the failover, taking "1 and 2" in the
      order it was given. NOTE THE PRECEDENT POINTS THE OTHER WAY - Hole Detection, the only
      other module on this same pair, uses idx 2 as its primary and idx 1 as its failover on
      all three of its machines. Flipping the two DECLAREs in section 1 is the whole change if
      that is wanted; nothing else in this script depends on which is which.
  D10. The 39 data tag paths are the FlatWireOpc:Lines:{FL1,FL2}:Tags values from
      FlatWire.API/appsettings.json, in the .PLC. form settled by G98 / D-46. They are
      DUPLICATED between that file and these rows by decision - see [DEP section 5] for the
      config-vs-rows diff that keeps the two in step.
==============================================================================================*/

USE [CommonDB];
GO

SET NOCOUNT ON;
GO

/*----------------------------------------------------------------------------------------------
  0. PRE-FLIGHT - this CommonDB must MATCH SOURCE CONTROL, not merely exist (D11 / G100)

  *** THIS IS A SEPARATE BATCH ON PURPOSE. DO NOT FOLD IT BACK INTO SECTION 3. ***

  It used to sit with the other guards in section 3, and there it could never fire. SQL Server
  binds column names for an EXISTING table when the BATCH is compiled, not when the statement
  runs, so section 4a's INSERT of OPCEventType / EventDurationSeconds failed the entire batch -
  this guard included - before its first line executed. MEASURED on DEV00164-001 while the two
  columns were still missing: Msg 207 and nothing else, the PRINT below never appeared. Moving
  it above the seed batch is the whole fix, and it is what makes the message reachable at all.

  Two things that do NOT work, both measured the same day. SET NOEXEC ON does not help - a
  NOEXEC'd batch is still compiled and still raises Msg 207. And `:on error exit` is deliberately
  NOT used: it is a SQLCMD-mode-only directive, and this script is run BY HAND, which means SSMS
  at least as often as sqlcmd, where it would be a syntax error.

  So, concretely: under sqlcmd pass -b and the run stops here with no Msg 207 at all. Under SSMS
  without SQLCMD mode the seed batch is still sent and still reports Msg 207 - but BELOW the
  message this guard prints, which names a stale database instead of looking like a typo here.

  STATUS 5 Sep 2026: DEV00164-001 is the instance this caught, and it has since been levelled by
  08_CommonDB_OPCModules_ColumnDrift.sql - the columns are present and this guard now passes.
  It stays because [DEP section 2] still carries staging and production as *fill*, and G100 asks
  for the drift to be re-checked per environment. Deliberately narrow: it checks the two columns
  this script actually writes, not the whole schema. The other four OPC tables were compared
  column by column on the same date and match exactly, so OPCModules is the only one worth
  checking. A general drift check belongs to whoever owns CommonDB.
----------------------------------------------------------------------------------------------*/
IF COL_LENGTH('dbo.OPCModules', 'OPCEventType') IS NULL
   OR COL_LENGTH('dbo.OPCModules', 'EventDurationSeconds') IS NULL
BEGIN
    PRINT 'dbo.OPCModules as it stands on this instance:';
    SELECT    c.[column_id], c.[name], t.[name] AS [type], c.[is_nullable]
    FROM      sys.columns AS c
              INNER JOIN sys.types AS t ON t.[user_type_id] = c.[user_type_id]
    WHERE     c.[object_id] = OBJECT_ID('dbo.OPCModules')
    ORDER BY  c.[column_id];

    RAISERROR('ABORT: this CommonDB is BEHIND source control - dbo.OPCModules is missing OPCEventType and/or EventDurationSeconds, which ual-database/Databases/CommonDB/Tables/OPCModules/CreateTable.sql declares. This is NOT a defect in this script (G100). Run 08_CommonDB_OPCModules_ColumnDrift.sql against this instance, then re-run this one. Do NOT refresh dbo.GetOPCServerAndTagDetails without reading 08_ first - it selects both columns into a non-nullable DTO and the pre-existing module rows are NULL.', 16, 1);
    RETURN;
END
GO

/*----------------------------------------------------------------------------------------------
  1. Configuration
----------------------------------------------------------------------------------------------*/
DECLARE @ModuleName        VARCHAR(128) = 'FlatWire';
DECLARE @OPCModuleId       INT          = 6;          -- D1 / G96
DECLARE @ConnectionType    INT          = 21317;      -- D2 - Lookups.OPCUA
DECLARE @IsReadOnly        BIT          = 0;          -- D5
DECLARE @OPCEventType      INT          = 0;          -- D6
DECLARE @EventDurationSecs INT          = 1;          -- D6

-- D7 / G97 - ANSWERED 5 Sep 2026. The flat wire lines use the OPC UA endpoint PAIR at
-- OPCServersIdx 1 and 2. BOTH lines map to BOTH, as ConnectionSequence 1 and 2 - that is what
-- every other module does and what GetOPCServerAndTagDetails orders by (D13, D14).
-- ADDRESSED BY ID, NOT BY NAME (D13): on DEV00164-001, idx 1 is UAOPC3 and idx 2 is UAOPC4.
-- There is deliberately no @OPCServerName and no @OPCServerClass - both belong to rows this
-- script only ever reads (D12 / D-48).
DECLARE @OPCServersIdxPrimary   INT = 1;   -- ConnectionSequence 1 - tried first
DECLARE @OPCServersIdxSecondary INT = 2;   -- ConnectionSequence 2 - the failover

DECLARE @FL1Idx INT = 125;
DECLARE @FL2Idx INT = 126;
-- There is no @FL3Idx. FL3 (127) is not registered - see the FL3 note in the header (G99).

/*----------------------------------------------------------------------------------------------
  2. The tag surface - 39 data rows plus the two system-error rows
----------------------------------------------------------------------------------------------*/
DECLARE @Tags TABLE
(
      [MachineIdx]       INT          NOT NULL
    , [TagName]          VARCHAR(128) NOT NULL
    , [UpdateRate]       INT          NOT NULL
    , [IsSystemErrorTag] BIT          NOT NULL
);

INSERT INTO @Tags ([MachineIdx], [TagName], [UpdateRate], [IsSystemErrorTag])
VALUES
    -- FL1 (machine 125) - 17 data tags
        (125, 'FL1.PLC.DB1.Diameter',                  1000, 0)   -- Db1Diameter
      , (125, 'FL1.PLC.DB2.Diameter',                  1000, 0)   -- Db2Diameter
      , (125, 'FL1.PLC.DB1.Status.IsActive',           1000, 0)   -- Db1Active
      , (125, 'FL1.PLC.DB2.Status.IsActive',           1000, 0)   -- Db2Active
      , (125, 'FL1.PLC.FM1.RollGap',                   1000, 0)   -- Fm1RollGap
      , (125, 'FL1.PLC.FM1.Status.IsActive',           1000, 0)   -- Fm1Active
      , (125, 'FL1.PLC.FM1.Status.IsFaulted',          1000, 0)   -- Fm1Faulted
      , (125, 'FL1.PLC.AGC.Gauge',                     1000, 0)   -- Gauge
      , (125, 'FL1.PLC.AGC.Width',                     1000, 0)   -- Width
      , (125, 'FL1.PLC.Speed',                         1000, 0)   -- Speed
      , (125, 'FL1.PLC.Payoff1.Weight',                1000, 0)   -- Payoff1Weight
      , (125, 'FL1.PLC.Payoff2.Weight',                1000, 0)   -- Payoff2Weight
      , (125, 'FL1.PLC.TKUP1.Footage',                 1000, 0)   -- Tkup1Footage
      , (125, 'FL1.PLC.FM1.Dancer.Status.IsActive',    1000, 0)   -- DancerActive
      , (125, 'FL1.PLC.FM1.Dancer.Position',           1000, 0)   -- DancerPosition
      , (125, 'FL1.PLC.LineState',                     1000, 0)   -- LineState
      , (125, 'FL1.PLC.ITInhibit',                     1000, 0)   -- ITInhibit
    -- FL2 (machine 126) - 22 data tags
      , (126, 'FL2.PLC.FM2.S1.RollGap',                1000, 0)   -- Fm2S1RollGap
      , (126, 'FL2.PLC.FM2.S1.Status.IsActive',        1000, 0)   -- Fm2S1Active
      , (126, 'FL2.PLC.FM2.S2.RollGap',                1000, 0)   -- Fm2S2RollGap
      , (126, 'FL2.PLC.FM2.S2.Status.IsActive',        1000, 0)   -- Fm2S2Active
      , (126, 'FL2.PLC.FM2.S3.RollGap',                1000, 0)   -- Fm2S3RollGap
      , (126, 'FL2.PLC.FM2.S3.Status.IsActive',        1000, 0)   -- Fm2S3Active
      , (126, 'FL2.PLC.FM2.S3.Status.IsFaulted',       1000, 0)   -- Fm2S3Faulted
      , (126, 'FL2.PLC.FM2.S2.Edger.Status.IsActive',  1000, 0)   -- Fm2S2EdgerActive
      , (126, 'FL2.PLC.FM2.S3.Edger.Status.IsActive',  1000, 0)   -- Fm2S3EdgerActive
      , (126, 'FL2.PLC.FM2.Dancer1.Status.IsActive',   1000, 0)   -- Dancer1Active
      , (126, 'FL2.PLC.FM2.Dancer1.Position',          1000, 0)   -- Dancer1Position
      , (126, 'FL2.PLC.FM2.Dancer1.Mode',              1000, 0)   -- Dancer1Mode
      , (126, 'FL2.PLC.FM2.Dancer1.Tension',           1000, 0)   -- Dancer1Tension
      , (126, 'FL2.PLC.FM2.Dancer2.Status.IsActive',   1000, 0)   -- Dancer2Active
      , (126, 'FL2.PLC.FM2.Dancer2.Position',          1000, 0)   -- Dancer2Position
      , (126, 'FL2.PLC.FM2.Dancer2.Mode',              1000, 0)   -- Dancer2Mode
      , (126, 'FL2.PLC.FM2.Dancer2.Tension',           1000, 0)   -- Dancer2Tension
      , (126, 'FL2.PLC.Speed',                         1000, 0)   -- Speed
      , (126, 'FL2.PLC.Payoff1.Weight',                1000, 0)   -- Payoff1Weight
      , (126, 'FL2.PLC.TKUP2.Footage',                 1000, 0)   -- Tkup2Footage
      , (126, 'FL2.PLC.LineState',                     1000, 0)   -- LineState
      , (126, 'FL2.PLC.ITInhibit',                     1000, 0)   -- ITInhibit
    -- The two SYSTEM ERROR tags. G95: GetOPCServerAndTagDetails result set 1 INNER JOINs
    -- OPCTags filtered IsSystemErrorTag = 1, so WITHOUT these two rows GetOPCInfo returns an
    -- EMPTY LIST for the line and every data tag above is unreachable. They are not optional,
    -- and their absence looks exactly like G60 itself.
      , (125, 'FL1.PLC._System._Error',                1000, 1)
      , (126, 'FL2.PLC._System._Error',                1000, 1);

/*----------------------------------------------------------------------------------------------
  3. Pre-flight guards - every one of these runs BEFORE the transaction opens
----------------------------------------------------------------------------------------------*/

-- Guard: BOTH endpoints of the pair must already exist. OPCServers is a LOOKUP table and this
-- script never inserts into it (D12 / D-48), so a missing id is a question for whoever owns
-- CommonDB's OPC estate - NOT a reason to add an INSERT here.
IF ( SELECT COUNT(*)
     FROM   [dbo].[OPCServers]
     WHERE  [OPCServersIdx] IN (@OPCServersIdxPrimary, @OPCServersIdxSecondary) ) < 2
BEGIN
    PRINT 'The endpoints this instance actually has:';
    SELECT    [OPCServersIdx], RTRIM([OPCServerName]) AS [OPCServerName]
            , RTRIM([OPCServerClass]) AS [OPCServerClass]
    FROM      [dbo].[OPCServers]
    ORDER BY  [OPCServersIdx];

    RAISERROR('ABORT: OPCServersIdx 1 and/or 2 is not a row in dbo.OPCServers on this instance. That table is a LOOKUP and this script only ever SELECTS from it (D12 / D-48). Re-check the ids against the list printed above - per environment, exactly as for the module id (G96) - or have the endpoints registered by whoever owns CommonDB. Do NOT add an INSERT to this script.', 16, 1);
    RETURN;
END

-- Guard: the pair must be two DIFFERENT endpoints, or the failover is a failover onto itself
-- and both ConnectionSequence rows point at the same server.
IF @OPCServersIdxPrimary = @OPCServersIdxSecondary
BEGIN
    RAISERROR('ABORT: @OPCServersIdxPrimary and @OPCServersIdxSecondary are the same endpoint, so ConnectionSequence 1 and 2 would both resolve to one server and the pair buys nothing (D14).', 16, 1);
    RETURN;
END

-- The SIXTH guard - this CommonDB must MATCH source control, not merely exist (D11 / G100) -
-- is NOT here. It is section 0, above, in a batch of its own, and it cannot be moved back:
-- section 4a's INSERT binds OPCEventType at BATCH COMPILE time, so a guard sharing this batch
-- is dead code. See the comment there.

-- Guard: the target OPCModulesIdx must be free, or already hold the flat wire module (D1/G96).
IF EXISTS ( SELECT 1
            FROM   [dbo].[OPCModules]
            WHERE  [OPCModulesIdx] = @OPCModuleId
                   AND ISNULL(RTRIM([ModuleName]), '') <> @ModuleName )
BEGIN
    PRINT 'The target OPCModulesIdx is already in use by another module:';
    SELECT    [OPCModulesIdx], RTRIM([ModuleName]) AS [OccupiedBy], [ConnectionType]
    FROM      [dbo].[OPCModules]
    WHERE     [OPCModulesIdx] = @OPCModuleId;

    RAISERROR('ABORT: the target OPCModulesIdx is already used by a different module. The UAL.Constants enum is NOT the register of module ids - read the live table and pick a free id (G96).', 16, 1);
    RETURN;
END

-- Guard: ModuleName has no unique index, so a duplicate would make the id lookup ambiguous.
IF ( SELECT COUNT(*) FROM [dbo].[OPCModules] WHERE RTRIM([ModuleName]) = @ModuleName ) > 1
BEGIN
    RAISERROR('ABORT: more than one OPCModules row already carries the flat wire module name. Resolve the duplicate first.', 16, 1);
    RETURN;
END

-- Guard: an existing flat wire module must not be sitting on a different id.
IF EXISTS ( SELECT 1
            FROM   [dbo].[OPCModules]
            WHERE  RTRIM([ModuleName]) = @ModuleName
                   AND [OPCModulesIdx] <> @OPCModuleId )
BEGIN
    PRINT 'The flat wire module is already registered under a different id:';
    SELECT    [OPCModulesIdx], RTRIM([ModuleName]) AS [ModuleName]
    FROM      [dbo].[OPCModules]
    WHERE     RTRIM([ModuleName]) = @ModuleName;

    RAISERROR('ABORT: the flat wire module exists under a different OPCModulesIdx. Reconcile it with FlatWireOpc:OpcModuleId in appsettings before re-running.', 16, 1);
    RETURN;
END

-- Guard: both machines rows must exist AND be status 1, or result set 1 drops them silently.
IF ( SELECT COUNT(*)
     FROM   [united_db].[dbo].[machines]
     WHERE  [machine_idx] IN (@FL1Idx, @FL2Idx) AND [status] = 1 ) < 2
BEGIN
    PRINT 'Flat wire machines rows as they stand:';
    SELECT    [machine_idx], RTRIM([machine_name]) AS [machine_name], [status]
    FROM      [united_db].[dbo].[machines]
    WHERE     [machine_idx] IN (@FL1Idx, @FL2Idx, 127);

    RAISERROR('ABORT: FL1 (125) and FL2 (126) must both exist in united_db.dbo.machines with status = 1. Run 10_CommonDB_Insert_WIPStations_FlatWire.sql first. CommonDB.Machines filters STATUS = 1, so a row with any other status disappears from GetOPCInfo with no error at all.', 16, 1);
    RETURN;
END

-- Guard: no flat wire tag path may already be registered against a different machine or module.
IF EXISTS ( SELECT 1
            FROM   [dbo].[OPCTags] AS ot
                   INNER JOIN [dbo].[OPCTagApplicationMapping] AS otam
                       ON otam.[OPCTagsIdx] = ot.[OPCTagsIdx]
                   INNER JOIN @Tags AS t
                       ON RTRIM(ot.[TagName]) = t.[TagName]
            WHERE  otam.[Machineidx] <> t.[MachineIdx]
                   OR otam.[OPCModuleId] <> @OPCModuleId )
BEGIN
    PRINT 'Flat wire tag paths already mapped elsewhere:';
    SELECT    RTRIM(ot.[TagName]) AS [TagName], otam.[Machineidx], otam.[OPCModuleId]
    FROM      [dbo].[OPCTags] AS ot
              INNER JOIN [dbo].[OPCTagApplicationMapping] AS otam ON otam.[OPCTagsIdx] = ot.[OPCTagsIdx]
              INNER JOIN @Tags AS t ON RTRIM(ot.[TagName]) = t.[TagName]
    WHERE     otam.[Machineidx] <> t.[MachineIdx] OR otam.[OPCModuleId] <> @OPCModuleId;

    RAISERROR('ABORT: a flat wire tag path is already registered against a different machine or module. Resolve before re-running.', 16, 1);
    RETURN;
END

/*----------------------------------------------------------------------------------------------
  4. Seed
----------------------------------------------------------------------------------------------*/
BEGIN TRY
    BEGIN TRANSACTION;

    /*------------------------------------------------------------------------------------------
      4a. OPCModules - one row, at the id we chose rather than the next IDENTITY value (D3).
    ------------------------------------------------------------------------------------------*/
    IF NOT EXISTS ( SELECT 1 FROM [dbo].[OPCModules] WHERE [OPCModulesIdx] = @OPCModuleId )
    BEGIN
        SET IDENTITY_INSERT [dbo].[OPCModules] ON;

        INSERT INTO [dbo].[OPCModules]
                  ( [OPCModulesIdx], [ModuleName], [IsReadOnly], [ConnectionType], [OPCEventType], [EventDurationSeconds] )
        VALUES    ( @OPCModuleId, @ModuleName, @IsReadOnly, @ConnectionType, @OPCEventType, @EventDurationSecs );

        SET IDENTITY_INSERT [dbo].[OPCModules] OFF;

        PRINT 'OPCModules: inserted the flat wire module.';
    END
    ELSE
        PRINT 'OPCModules: the flat wire module already exists - left alone.';

    /*------------------------------------------------------------------------------------------
      4b. OPCServers - READ ONLY. Report the pair we were told to use (D7 / D12 / D13).

      There is no INSERT here and there must never be one: OPCServers is a LOOKUP table
      (D-48), the rows are site infrastructure shared by every module, and the guards in
      section 3 have already proved both ids exist and differ. This prints the NAMES because
      the ids do not match them (D13) and a reader checking the run needs to see which
      endpoints 1 and 2 actually are on THIS instance.
    ------------------------------------------------------------------------------------------*/
    PRINT 'OPCServers: using the existing endpoint pair below - nothing written.';
    SELECT    [OPCServersIdx]
            , RTRIM([OPCServerName])  AS [OPCServerName]
            , RTRIM([OPCServerClass]) AS [OPCServerClass]
            , CASE [OPCServersIdx] WHEN @OPCServersIdxPrimary THEN 1 ELSE 2 END AS [WillBeConnectionSequence]
    FROM      [dbo].[OPCServers]
    WHERE     [OPCServersIdx] IN (@OPCServersIdxPrimary, @OPCServersIdxSecondary)
    ORDER BY  [WillBeConnectionSequence];

    /*------------------------------------------------------------------------------------------
      4c. OPCServerApplicationMapping - FOUR rows: each line onto BOTH endpoints (D14).

      Not two. Every one of the 37 (module, machine) pairs already in this table has exactly
      TWO endpoint rows, ConnectionSequence 1 and 2, and GetOPCServerAndTagDetails' second
      result set is ORDER BY MachineId, ConnectionSequence - so the sequence is consumed, and
      a single-endpoint line would make flat wire the only machine in CommonDB without a
      failover. FL1 -> (primary, 1) + (secondary, 2); FL2 -> the same.
    ------------------------------------------------------------------------------------------*/
    INSERT INTO [dbo].[OPCServerApplicationMapping]
              ( [Machineidx], [OPCModuleId], [OPCServersIdx], [ConnectionSequence] )
    SELECT    m.[MachineIdx], @OPCModuleId, s.[OPCServersIdx], s.[ConnectionSequence]
    FROM      ( VALUES (@FL1Idx), (@FL2Idx) ) AS m ( [MachineIdx] )
              CROSS JOIN ( VALUES (@OPCServersIdxPrimary, 1), (@OPCServersIdxSecondary, 2) )
                         AS s ( [OPCServersIdx], [ConnectionSequence] )
    WHERE     NOT EXISTS ( SELECT 1
                           FROM   [dbo].[OPCServerApplicationMapping] AS x
                           WHERE  x.[Machineidx]     = m.[MachineIdx]
                                  AND x.[OPCModuleId]   = @OPCModuleId
                                  AND x.[OPCServersIdx] = s.[OPCServersIdx] );

    PRINT 'OPCServerApplicationMapping: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) inserted (expect 4).';

    /*------------------------------------------------------------------------------------------
      4d. OPCTags - 41 rows. Matched on TagName (see IDEMPOTENCY).
    ------------------------------------------------------------------------------------------*/
    INSERT INTO [dbo].[OPCTags] ( [TagName], [RequestedUpdateRate], [IsSystemErrorTag], [IsActive] )
    SELECT    t.[TagName], t.[UpdateRate], t.[IsSystemErrorTag], 1
    FROM      @Tags AS t
    WHERE     NOT EXISTS ( SELECT 1 FROM [dbo].[OPCTags] AS ot WHERE RTRIM(ot.[TagName]) = t.[TagName] );

    PRINT 'OPCTags: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) inserted.';

    /*------------------------------------------------------------------------------------------
      4e. OPCTagApplicationMapping - bind every tag to its line and to this module.
    ------------------------------------------------------------------------------------------*/
    INSERT INTO [dbo].[OPCTagApplicationMapping] ( [Machineidx], [OPCModuleId], [OPCTagsIdx] )
    SELECT    t.[MachineIdx], @OPCModuleId, ot.[OPCTagsIdx]
    FROM      @Tags AS t
              INNER JOIN [dbo].[OPCTags] AS ot ON RTRIM(ot.[TagName]) = t.[TagName]
    WHERE     NOT EXISTS ( SELECT 1
                           FROM   [dbo].[OPCTagApplicationMapping] AS x
                           WHERE  x.[Machineidx]  = t.[MachineIdx]
                                  AND x.[OPCModuleId] = @OPCModuleId
                                  AND x.[OPCTagsIdx]  = ot.[OPCTagsIdx] );

    PRINT 'OPCTagApplicationMapping: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) inserted.';

    COMMIT TRANSACTION;
    PRINT 'Flat wire OPC registration committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR: flat wire OPC registration rolled back; no table was changed.';
    THROW;
END CATCH
GO

/*----------------------------------------------------------------------------------------------
  5. Verification

  Part D of the plan. Everything below is read-only; run it after the seed and read the four
  results. The row counts are the point: 41 tags and 41 mappings, split 39 data + 2 system.
----------------------------------------------------------------------------------------------*/
USE [CommonDB];
GO

DECLARE @OPCModuleId INT = 6;
DECLARE @FL1Idx      INT = 125;
DECLARE @FL2Idx      INT = 126;
DECLARE @ExpectedEndpointsPerLine INT = 2;   -- D14 - primary + failover, never one

PRINT '--- 5a. The module row. ConnectionType must be 21317 and none of the four may be NULL. ---';
SELECT    [OPCModulesIdx], RTRIM([ModuleName]) AS [ModuleName], [IsReadOnly]
        , [ConnectionType], [OPCEventType], [EventDurationSeconds]
FROM      [dbo].[OPCModules]
WHERE     [OPCModulesIdx] = @OPCModuleId;

PRINT '--- 5a2. The server mapping. Expect FOUR rows - each line on BOTH endpoints, ---';
PRINT '---       sequences 1 and 2, every endpoint one that PRE-EXISTED the run (D14). ---';
SELECT    osam.[Machineidx], osam.[OPCServersIdx], osam.[ConnectionSequence]
        , RTRIM(os.[OPCServerName])  AS [OPCServerName]
        , RTRIM(os.[OPCServerClass]) AS [OPCServerClass]
FROM      [dbo].[OPCServerApplicationMapping] AS osam
          INNER JOIN [dbo].[OPCServers] AS os ON os.[OPCServersIdx] = osam.[OPCServersIdx]
WHERE     osam.[OPCModuleId] = @OPCModuleId
ORDER BY  osam.[Machineidx];

PRINT '--- 5b. Row counts. Expect Data 39, SystemError 2, Total 41, and Mappings 41. ---';
SELECT    SUM(CASE WHEN ot.[IsSystemErrorTag] = 0 THEN 1 ELSE 0 END) AS [DataTags]
        , SUM(CASE WHEN ot.[IsSystemErrorTag] = 1 THEN 1 ELSE 0 END) AS [SystemErrorTags]
        , COUNT(*)                                                   AS [TotalTags]
FROM      [dbo].[OPCTags] AS ot
          INNER JOIN [dbo].[OPCTagApplicationMapping] AS otam ON otam.[OPCTagsIdx] = ot.[OPCTagsIdx]
WHERE     otam.[OPCModuleId] = @OPCModuleId;

SELECT    otam.[Machineidx]
        , COUNT(*) AS [Mappings]
FROM      [dbo].[OPCTagApplicationMapping] AS otam
WHERE     otam.[OPCModuleId] = @OPCModuleId
GROUP BY  otam.[Machineidx];   -- expect 125 -> 18, 126 -> 23 (data + its system-error row)

PRINT '--- 5c. Every registered path, for the config-vs-rows diff against appsettings. ---';
SELECT    otam.[Machineidx], RTRIM(ot.[TagName]) AS [TagName]
        , ot.[RequestedUpdateRate], ot.[IsSystemErrorTag], ot.[IsActive]
FROM      [dbo].[OPCTags] AS ot
          INNER JOIN [dbo].[OPCTagApplicationMapping] AS otam ON otam.[OPCTagsIdx] = ot.[OPCTagsIdx]
WHERE     otam.[OPCModuleId] = @OPCModuleId
ORDER BY  otam.[Machineidx], ot.[TagName];

PRINT '--- 5d. Faults. Every one of these must return ZERO rows. ---';

-- A duplicate (machine, module, tag) mapping. The table has no unique index to prevent it.
SELECT    otam.[Machineidx], RTRIM(ot.[TagName]) AS [TagName], COUNT(*) AS [Duplicates]
FROM      [dbo].[OPCTagApplicationMapping] AS otam
          INNER JOIN [dbo].[OPCTags] AS ot ON ot.[OPCTagsIdx] = otam.[OPCTagsIdx]
WHERE     otam.[OPCModuleId] = @OPCModuleId
GROUP BY  otam.[Machineidx], RTRIM(ot.[TagName])
HAVING    COUNT(*) > 1;

-- A path carrying an ns= prefix. The bare path is the stored form; OPCConnection adds ns=2;s=.
SELECT    RTRIM(ot.[TagName]) AS [PrefixedTagName]
FROM      [dbo].[OPCTags] AS ot
          INNER JOIN [dbo].[OPCTagApplicationMapping] AS otam ON otam.[OPCTagsIdx] = ot.[OPCTagsIdx]
WHERE     otam.[OPCModuleId] = @OPCModuleId
          AND ot.[TagName] LIKE 'ns=%';

-- A path missing the .PLC. segment settled by G98 / D-46.
SELECT    RTRIM(ot.[TagName]) AS [TagNameWithoutPlcSegment]
FROM      [dbo].[OPCTags] AS ot
          INNER JOIN [dbo].[OPCTagApplicationMapping] AS otam ON otam.[OPCTagsIdx] = ot.[OPCTagsIdx]
WHERE     otam.[OPCModuleId] = @OPCModuleId
          AND ot.[TagName] NOT LIKE 'FL_.PLC.%';

-- A line with no system-error tag. G95 - GetOPCInfo returns an EMPTY LIST for such a line.
SELECT    m.[MachineIdx] AS [MachineWithNoSystemErrorTag]
FROM      ( VALUES (@FL1Idx), (@FL2Idx) ) AS m ( [MachineIdx] )
WHERE     NOT EXISTS ( SELECT 1
                       FROM   [dbo].[OPCTagApplicationMapping] AS otam
                              INNER JOIN [dbo].[OPCTags] AS ot ON ot.[OPCTagsIdx] = otam.[OPCTagsIdx]
                       WHERE  otam.[Machineidx]  = m.[MachineIdx]
                              AND otam.[OPCModuleId] = @OPCModuleId
                              AND ot.[IsSystemErrorTag] = 1
                              AND ot.[IsActive] = 1 );

-- Machine 127 must NOT be registered. G99 - this returning a row means FL3 was seeded by
-- mistake, and an FL3 push would then reach a controller nobody designed the write for.
SELECT    otam.[Machineidx] AS [FL3ShouldNotBeRegistered]
FROM      [dbo].[OPCTagApplicationMapping] AS otam
WHERE     otam.[OPCModuleId] = @OPCModuleId AND otam.[Machineidx] = 127;

-- A server mapping pointing at an endpoint that does not exist. D12 - this script never
-- creates one, so a dangling OPCServersIdx means the row was written by something else, or
-- the endpoint was removed underneath us. OPCServersIdx carries no foreign key.
SELECT    osam.[Machineidx], osam.[OPCServersIdx] AS [DanglingOPCServersIdx]
FROM      [dbo].[OPCServerApplicationMapping] AS osam
WHERE     osam.[OPCModuleId] = @OPCModuleId
          AND NOT EXISTS ( SELECT 1 FROM [dbo].[OPCServers] AS os
                           WHERE os.[OPCServersIdx] = osam.[OPCServersIdx] );

-- A line that did NOT end up with a full primary/failover pair. D14 - all 37 (module,machine)
-- pairs already in this table have exactly two, and GetOPCServerAndTagDetails orders the list
-- by ConnectionSequence, so a line with one endpoint looks healthy until the primary drops.
SELECT    m.[MachineIdx] AS [LineWithoutAnEndpointPair]
        , ( SELECT COUNT(*) FROM [dbo].[OPCServerApplicationMapping] AS x
            WHERE x.[Machineidx] = m.[MachineIdx] AND x.[OPCModuleId] = @OPCModuleId ) AS [Endpoints]
FROM      ( VALUES (@FL1Idx), (@FL2Idx) ) AS m ( [MachineIdx] )
WHERE     ( SELECT COUNT(*) FROM [dbo].[OPCServerApplicationMapping] AS x
            WHERE x.[Machineidx] = m.[MachineIdx] AND x.[OPCModuleId] = @OPCModuleId )
          <> @ExpectedEndpointsPerLine;

-- A duplicated ConnectionSequence on one line - two "primaries", so the ordered server list
-- GetOPCServerAndTagDetails returns is arbitrary between them. No unique index prevents it.
SELECT    osam.[Machineidx], osam.[ConnectionSequence], COUNT(*) AS [DuplicateSequences]
FROM      [dbo].[OPCServerApplicationMapping] AS osam
WHERE     osam.[OPCModuleId] = @OPCModuleId
GROUP BY  osam.[Machineidx], osam.[ConnectionSequence]
HAVING    COUNT(*) > 1;
GO

/*----------------------------------------------------------------------------------------------
  Rollback (dev only)

  There is a reverse script - 16_CommonDB_Delete_OPCRegistration_FlatWire.sql. Use it rather
  than hand-deleting, because the delete order matters: mappings before the rows they point at,
  or the OPCTags rows are orphaned and the natural key this script matches on stops working.
  It removes NOTHING from dbo.OPCServers, because this script put nothing there (D12 / D-48).
----------------------------------------------------------------------------------------------*/
