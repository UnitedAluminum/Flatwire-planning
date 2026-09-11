-- ============================================================
-- Flat Wire Mill — DDL Script 01: Lookup / Reference Tables
-- Run order : 01 of 09
-- Tables    : Stand, Drawer, ToolingInventoryDie, ToolingInventoryRollSet,
--             ToolingInventoryEdger, ToolingInventoryEdgerGauge,
--             Dancer, AlloyProperty, PayoffPosition,
--             SpoolConfiguration, Spool,
--             DowntimeReason, WipRejectionReason, ItInhibitReason,
--             SetupHandlingTimeGroup, SetupHandlingTimeElement,
--             SetupHandlingTimeStandard, MaterialLossElement,
--             MaterialLossStandard   (19)
--
-- Sep-8-2026: SpoolConfiguration RETURNS, splitting back out of Spool (D-58).
--             Q60 merged it in on 23 Aug 2026; that merge is superseded, not
--             deleted -- see the Spool header below for what changed and why.  (+1)
--
-- Sep-6-2026: ToolingInventoryEdger and ToolingInventoryEdgerGauge added, and
-- [dbo].[Edger] REMOVED -- ABSORBED, not extended (D-53). Edger held five
-- columns against the client's fourteen-column Tooling Inventory grid of
-- 31 Aug 2026, and 02_Schedule already said "EdgerId identifies the fitted
-- TOOL, not the STATION" -- so it was meant to be the physical tool register
-- and was simply too thin to be one. PassScheduleComponent.EdgerId re-points
-- at ToolingInventoryEdger and FK_PSC_Edger keeps its name. Gauge Range is a
-- CHILD TABLE, not a delimited string, because the grid's cell holds three
-- grooves (".045, .040, .035") and a pass schedule must be able to select ONE.
-- This CLOSES G77's edger half; the STRAIGHTENER half stays open, along with
-- the .134/.184 range discrepancy. See the table comment blocks below, G104
-- and Q95. NOTE the table count is 18 and not 19: two added, one removed.
--
-- Sep-4-2026: the five MACHINE SETUP tables added -- the Setup/Handling
-- Times and Material Loss tabs of the Machines Application, from Tim
-- O'Brien's per-line field sets of 31 Aug 2026. Three catalogues (seeded
-- inline here, 144 rows) plus two value tables created EMPTY, because the
-- numbers are the Naj/Bob/Tim standards spreadsheet and it is not
-- finished. See the section header before SetupHandlingTimeGroup below --
-- it carries the why-not-the-legacy-shape argument and the three costs of
-- putting these in FlatWireDB rather than united_db. OI-110 STAYS OPEN.
--
-- Sep-3-2026: ToolingInventoryRollSet added. The client's Tooling Inventory
-- tab carries FOUR tool types, not three -- Die, Edger, Straightener and now
-- Roll Set (mill rolls and DB1/DB2 capstan rolls), per Tim O'Brien's mail of
-- 3 Sep 2026. Dancer, PayoffPosition and Spool are explicitly NOT tooling and
-- stay where they are. Its columns are OUR reading of one sentence, not a
-- client field set -- see G87 and Q92, and the table's own comment block.
--
-- Sep-2-2026: the three reason-code tables added from the client's
-- "Reason Codes.xlsx" (Tim O'Brien, 1 Sep 2026), which closes actions
-- A4/A5/A6 of the 23 Jul 2026 call. THEY ARE SEEDED HERE, INLINE, not in
-- FlatWire_SampleData_Lookup.sql -- see the seed block comments and the
-- PayoffPosition precedent below: these are PRODUCTION reference data, and
-- a deploy that runs only RunAll must end up with a usable pause dialog.
-- Dependencies: 00_Database (FlatWireDB)
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- Stand
-- Rolling mill finishing stands. Referenced by PassScheduleComponent
-- for FM-type component slots.
--
-- Aug-4-2026 correction: FM2 has THREE stands — S1 (8"), S2 (6"),
-- S3 (6", final) — not a separate 8" roller plus three 6" stands.
-- Roll diameter is now DATA (RollDiameterIn), not part of the name:
--   FM2_8in -> FM2_S1 (8.000)   FM2_6inS1 -> FM2_S2 (6.000)
--   FM2_6inS2 -> FM2_S3 (6.000, final)   FM2_6inS3 -> withdrawn
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stand]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Stand] (
        [Id]             INT          NOT NULL IDENTITY(1,1),
        [Name]           VARCHAR(30)  NOT NULL,               -- position only: FM1, FM2_S1, FM2_S2, FM2_S3
        [MachineName]         VARCHAR(5)   NULL,                   -- FL1 / FL2 / FL3; NULL = shared across lines
        [RollDiameterIn] DECIMAL(5,3) NOT NULL,               -- working roll diameter in inches (FM1 12.000; FM2 S1 8.000, S2/S3 6.000)
        [MinGaugeIn]     DECIMAL(8,4) NOT NULL,               -- minimum input gauge in inches
        [MaxGaugeIn]     DECIMAL(8,4) NOT NULL,               -- maximum input gauge in inches
        [MinWidthIn]     DECIMAL(8,4) NOT NULL,               -- minimum flat wire width in inches
        [MaxWidthIn]     DECIMAL(8,4) NOT NULL,               -- maximum flat wire width in inches
        [IsActive]       BIT          NOT NULL CONSTRAINT [DF_Stand_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Stand]                  PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Stand_Name]             UNIQUE ([Name]),
        CONSTRAINT [CK_Stand_Gauge]            CHECK ([MinGaugeIn] < [MaxGaugeIn]),
        CONSTRAINT [CK_Stand_Width]            CHECK ([MinWidthIn] < [MaxWidthIn]),
        CONSTRAINT [CK_Stand_RollDiameterIn]   CHECK ([RollDiameterIn] > 0)
    );
    PRINT 'Created table: Stand';
END
ELSE
    PRINT 'Table already exists: Stand';
GO

-- ------------------------------------------------------------
-- Drawer
-- The two DRAW BOXES -- DB1 and DB2. A draw box (die block) is the
-- machine that pulls rod through a die to reduce its diameter. The
-- die is the TOOLING fitted in it, and lives in ToolingInventoryDie.
--
-- THE DIE SPLIT (Sep-2-2026). Until now this table held 13 rows, one per
-- die hole diameter, plus the two die-life counters -- so it was named
-- after the machine and populated with the tooling. Two rows is the whole
-- table now: there are exactly two physical draw boxes.
--
--   Moved to ToolingInventoryDie: DiameterIn (now HoleSizeIn),
--   MinDiameterIn / MaxDiameterIn (feed range -- a die property),
--   LastGrindingFeet and TotalFeetAllowed (die life -- a die property).
--
-- phase-13-mvp2-die-management.md called this split impossible ("a table
-- cannot be split") because a SCOPE SEAM ran through it: die inventory was
-- MVP-2 while the die change was MVP-1, so the counters were bolted on here
-- on Aug-6-2026 as a workaround. The seam is gone -- the whole die domain is
-- MVP-1 -- so the split is now available. OI-41 CLOSES with it.
--
-- MAX TWO ROWS IS STRUCTURAL, not policed: CK_Drawer_Name admits only DB1
-- and DB2 and UQ_Drawer_Name makes each unique, so a third row is impossible
-- without a schema change. No trigger, no row-counting rule.
--
-- NAMING: the client's Line Schedule tab calls these D1/D2 and its
-- Setup/Handling tab calls them DB1/DB2 -- four spellings across four
-- surfaces. DB1/DB2 is retained deliberately; see the 31-Aug-2026 client
-- mail analysis 4.8, which says do NOT reconcile until the Speed tab lands
-- (action A12, still open).
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Drawer]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Drawer] (
        [Id]       INT         NOT NULL IDENTITY(1,1),
        [Name]     VARCHAR(50) NOT NULL,             -- DB1 | DB2 -- the draw box, not the die
        -- FL1 owns both boxes; FL3 runs through them, as it shares FL1's VPS payoff.
        -- Client-confirmed 31 Aug 2026: the Tooling Inventory grid attributes dies to
        -- Machine Name = FL1, and NO FL3 row appears in any of the three tool grids.
        -- (Three is right for that date: the client had sent three grids. The fourth
        -- type, roll sets, arrived 3 Sep 2026 with no grid at all -- G87.)
        -- CK_Drawer_MachineName KEEPS FL3 while the TOOLING registers drop it, and that is
        -- deliberate: this table is EQUIPMENT and FL3 genuinely runs through DB1/DB2.
        -- The client's 3 Sep rule -- inventory maintained for FL1/FL2 only, FL3 using a
        -- combination of the two (D-42) -- binds the tooling, not the machine. Do not
        -- "align" this CHECK with CK_ToolingInventoryDie_MachineName.
        [MachineName]   VARCHAR(5)  NOT NULL,
        [IsActive] BIT         NOT NULL CONSTRAINT [DF_Drawer_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Drawer]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Drawer_Name]   UNIQUE ([Name]),
        CONSTRAINT [CK_Drawer_Name]   CHECK ([Name]   IN ('DB1','DB2')),
        CONSTRAINT [CK_Drawer_MachineName] CHECK ([MachineName] IN ('FL1','FL3'))
    );
    PRINT 'Created table: Drawer';
END
ELSE
    PRINT 'Table already exists: Drawer';
GO

-- ------------------------------------------------------------
-- ToolingInventoryDie
-- The register of PHYSICAL dies -- one row per tool, not per size. A die is
-- a tungsten carbide tool with a specific hole diameter; the hole diameter
-- is the output wire size after drawing.
--
-- WHY IT IS IN 01_Lookup: [DBD 6.2a] puts "reusable articles and reference
-- data" here -- the same rule that homes Spool, the reusable stencilled
-- article. A die is a reusable article. Note the tension honestly: its
-- footage counter mutates every run, which no other row in this file does.
--
-- WHY THE NAME IS A COMPOUND: it is the client's own term. The 31-Aug-2026
-- mail returns a Machines Application "Tooling Inventory" tab carrying THREE
-- tool types -- Die, Edger, Straightener. THAT COUNT IS FOUR as of 3 Sep 2026
-- (D-42): Roll Set is the fourth. This table is the first of the four; edgers
-- became ToolingInventoryEdger on 6 Sep 2026 (D-53). Only the STRAIGHTENER is
-- still uncovered, and that is what remains of G77.
--
-- THE COLUMN SET IS THE UNION OF TWO FIELD SETS, and OI-141 is why:
--   Ours    FR-247 registration, FR-254 (what Die Change reads at runtime):
--           DieAlpha, DieType, LastGrindingFeet, TotalFeetAllowed, condition.
--   Client  the 31-Aug Tooling Inventory grid: S/N, P/N, Location, ID("),
--           Max Imput Dia., Pitch, Max ID("), Lubrication Type, In Use.
-- They overlap on three fields and the client's grid carries NONE of the four
-- values FR-254 says Die Change reads. OI-141 asks whether that means ONE
-- register or TWO. This is the FlatWireDB one. If OI-141 resolves to two,
-- FR-254's source-of-truth claim needs restating -- that would not invalidate
-- this table, only its exclusivity.
--
-- ID(MM) IS NOT STORED. It is a derived display value: 0.343 * 25.4 = 8.712,
-- shown on the client grid as "8,700". Compute it in the UI.
--
-- STATUS: two vocabularies, resolved by derivation rather than by picking a
-- winner. LifecycleStatus stores the client's three values verbatim (plus
-- Retired, from FR-250). FR-253's Nearing / Overdue / Spare are PERCENTAGE
-- BANDS -- they are computed from LastGrindingFeet against TotalFeetAllowed,
-- with Spare as (InUse = 0 AND LastGrindingFeet = 0), and are NOT stored.
-- WARNING: both vocabularies contain the word "Active" meaning different
-- things -- a lifecycle state here, and a life band under 65% in FR-253. The
-- client's value is quoted, not edited; the two distinct names are what
-- disambiguate. Never store a derived band in LifecycleStatus.
--
-- LastGrindingFeet IS DENORMALISED against SUM(DieHistory.FootageAddedFt),
-- deliberately: FR-254 makes the running total what the Die Change screen
-- reads, so it must be one cheap column and not an aggregate over a growing
-- log, while FR-252 needs the per-run rows. The total is authoritative for
-- the screens; the log explains it. They can drift and nothing here prevents
-- it -- the invariant lives in the application beside FR-255's increment, NOT
-- in a trigger (G41: a trigger joining on a nullable column passes silently,
-- and DieHistory.RunId is nullable). Do not "fix" this by deriving the total.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ToolingInventoryDie]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[ToolingInventoryDie] (
        [Id]                 INT           NOT NULL IDENTITY(1,1),
        -- D-{size*1000}-{seq}, e.g. D-310-034 for a 0.310" die. FR-247 / [SP 192].
        -- Not present on the client's grid at all -- see OI-141.
        [DieAlpha]           VARCHAR(20)   NOT NULL,
        [SerialNo]           VARCHAR(50)   NULL,           -- client grid "S/N". NULL until the client supplies serials
        [PartNo]             VARCHAR(50)   NULL,           -- client grid "P/N"
        [Location]           VARCHAR(50)   NULL,           -- client grid "Location" -- die room / crib position
        -- Client grid "Machine Name". FL1 owns the draw boxes; FL3 runs through them.
        -- NULL for a die not assigned to a line (FR-241 / FR-244 spare).
        [MachineName]             VARCHAR(5)    NULL,
        [HoleSizeIn]         DECIMAL(8,4)  NOT NULL,       -- client grid 'ID(")' -- the hole diameter = output wire size
        [MinFeedDiameterIn]  DECIMAL(8,4)  NULL,           -- minimum acceptable feed diameter (was Drawer.MinDiameterIn)
        [MaxFeedDiameterIn]  DECIMAL(8,4)  NULL,           -- client grid "Max Imput Dia." (was Drawer.MaxDiameterIn)
        [PitchIn]            DECIMAL(8,4)  NULL,           -- client grid "Pitch"
        [MaxIdIn]            DECIMAL(8,4)  NULL,           -- client grid 'Max ID(")'
        [LubricationType]    VARCHAR(50)   NULL,           -- client grid "Lubrication Type"
        -- FR-247 die type/material. Also DieChangeAndManagement.md 2.4:
        -- the incoming die "must match the outgoing die type".
        [DieType]            VARCHAR(20)   NULL,
        -- Feet run SINCE the last grinding/reconditioning -- a resettable counter,
        -- not the odometer value at that grind. Reset to 0 when the die returns
        -- from the die room (DieChangeAndManagement.md 4.4 "Footage resets to zero").
        [LastGrindingFeet]   DECIMAL(10,2) NOT NULL CONSTRAINT [DF_ToolingInventoryDie_LastGrindingFeet] DEFAULT (0),
        -- Scheduled life: the engineering/supplier maximum footage this die may run
        -- before it is pulled. Configurable, and set LOWER on a reconditioned die.
        -- NULL until the client supplies thresholds (OQ-83 -- tracking decided,
        -- threshold TBD). Do not seed an invented limit.
        [TotalFeetAllowed]   DECIMAL(10,2) NULL,
        -- The client's three lifecycle values plus Inactive. A BIT cannot express
        -- "In Grinding" -- which was G77's point about the old Edger.IsActive, a
        -- table absorbed on 6 Sep 2026 (D-53). The three tooling registers now
        -- carry LifecycleStatus identically.
        --
        -- 'Inactive' WAS 'Retired' UNTIL 10 Sep 2026. The client named the value:
        -- "a set that has worn out after its last available grind shall be taken
        -- out of service and marked as 'In Active'". Read as Inactive, which is
        -- also how PassSchedule.Status already glosses it -- see 02_Schedule's
        -- [CONFIRMED] status block, "Inactive  Retired." So this is ONE vocabulary
        -- across two domains, not a new word.
        --
        -- STORED TOKEN ONLY. FR-250 names the ACTION "Retire Die" and requires a
        -- retire reason code, and FR-253's display band is still "Retired": those
        -- are UNCHANGED. DieChangeAndManagement.md section 5 remains the single
        -- copy of the five display bands. Do not rename a label to match this.
        [LifecycleStatus]    VARCHAR(20)   NOT NULL CONSTRAINT [DF_ToolingInventoryDie_LifecycleStatus] DEFAULT ('In Service'),
        [InUse]              BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryDie_InUse] DEFAULT (0),  -- client grid "In Use". Feeds the derived Spare band
        [Source]             VARCHAR(100)  NULL,           -- FR-247 supplier / die room source
        [Condition]          VARCHAR(50)   NULL,           -- FR-247 condition at registration
        [InspectionDate]     DATE          NULL,           -- FR-247 pre-use inspection
        [LastResetBy]        VARCHAR(50)   NULL,           -- FR-245 "last reset by"
        [LastResetAt]        DATETIMEOFFSET NULL,          -- FR-245 / FR-248
        [Notes]              VARCHAR(500)  NULL,
        [IsActive]           BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryDie_IsActive] DEFAULT (1),

        CONSTRAINT [PK_ToolingInventoryDie]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_ToolingInventoryDie_DieAlpha]  UNIQUE ([DieAlpha]),
        CONSTRAINT [CK_ToolingInventoryDie_HoleSize]  CHECK ([HoleSizeIn] > 0),
        CONSTRAINT [CK_ToolingInventoryDie_FeedRange] CHECK ([MinFeedDiameterIn] IS NULL OR [MaxFeedDiameterIn] IS NULL OR [MinFeedDiameterIn] < [MaxFeedDiameterIn]),
        CONSTRAINT [CK_ToolingInventoryDie_LastGrindingFeet] CHECK ([LastGrindingFeet] >= 0),
        CONSTRAINT [CK_ToolingInventoryDie_TotalFeetAllowed] CHECK ([TotalFeetAllowed] IS NULL OR [TotalFeetAllowed] > 0),
        CONSTRAINT [CK_ToolingInventoryDie_LifecycleStatus]  CHECK ([LifecycleStatus] IN ('Active','In Service','In Grinding','Inactive')),
        -- FL3 REMOVED Sep-3-2026. Asked whether tooling is maintained per line or for
        -- FL1/FL2 with FL3 combining, the client answered: "We should maintain them for
        -- FL1/FL2 and FL3 should use a combination of the two." So no tooling row is
        -- ever attributed to FL3, and the 31-Aug observation that no FL3 row appears in
        -- any tool grid is now confirmed as INTENDED rather than an omission in the
        -- sample. Safe against the seed: all 14 rows carry MachineName NULL.
        -- NOTE this does NOT apply to Drawer, which is EQUIPMENT -- FL3 genuinely runs
        -- through DB1/DB2 and keeps FL3 in its own CHECK. Do not "align" the two.
        CONSTRAINT [CK_ToolingInventoryDie_MachineName]    CHECK ([MachineName] IS NULL OR [MachineName] IN ('FL1')),
        CONSTRAINT [CK_ToolingInventoryDie_DieType]   CHECK ([DieType] IS NULL OR [DieType] IN ('TC Mono','TC Poly','Natural diamond'))
        -- Deliberately NO check that LastGrindingFeet <= TotalFeetAllowed. "Overdue"
        -- is a real operating state the Die Management screen must display
        -- (DieChangeAndManagement.md 5), not a data error to refuse at the database.
        --
        -- Deliberately NO uniqueness on HoleSizeIn. The old one-row-per-diameter
        -- premise is gone: many physical dies share a size, which is the point of
        -- the split. SerialNo uniqueness is a FILTERED index in script 07, because
        -- a plain UNIQUE would admit only one NULL and the seed leaves them all NULL.
    );
    PRINT 'Created table: ToolingInventoryDie';
END
ELSE
    PRINT 'Table already exists: ToolingInventoryDie';
GO

-- ------------------------------------------------------------
-- ToolingInventoryRollSet
-- The register of PHYSICAL ROLL SETS -- the fourth Tooling Inventory tool type.
--
-- WHY IT EXISTS. Client mail of 3-Sep-2026 (Tim O'Brien), answering whether stands,
-- dancers and spools belong on the Tooling Inventory tab:
--
--   "Good point! We should include mill rolls for traceability, 12" (FL1-S1) 2 roll
--    set, DB1/DB2 Capstans (rolls) current inventory = 2, will be adding a spare and
--    they can be refurbished, 8", 6", 6" rolls for (FL2-S1, FL2-S2, FL2-S3) 2 roll
--    sets. We will NOT need to include dancers, entry guides, payoffs, spools, etc.
--    in the tooling table."
--
-- So the tab carries FOUR types, not three: Die, Edger, Straightener, Roll Set.
-- Dancer, PayoffPosition and Spool stay what they are -- equipment and article
-- registers -- and are explicitly NOT tooling. Do not migrate them here.
--
-- THE SAME SPLIT AS THE DIE. Stand and Drawer are the POSITIONS a roll set is fitted
-- to; this table is the physical TOOL, exactly as ToolingInventoryDie is to Drawer
-- (Q91, 2 Sep 2026). Roll diameter already existed as Stand.RollDiameterIn and that
-- is MACHINE data -- D-26 and [PLC 5.4] both rest on it. NominalDiameterIn here is
-- the TOOL's own size and is deliberately a second, differently-owned column:
-- Stand.RollDiameterIn stays authoritative for the machine. They are not duplicates
-- and neither is stale.
--
-- ONE TABLE, NOT TWO, and the discriminator is why. Mill rolls fit a Stand; capstan
-- rolls fit a Drawer. That is two parents, which normally argues for two tables --
-- but the client named both in one breath as one answer about one tab option, and
-- DieHistory already set the precedent in this schema of one discriminated table
-- serving two shapes. RollType plus the mount CHECK keeps it honest: exactly one of
-- StandId / DrawerId is populated, and it must agree with RollType.
--
-- THIS IS THE FIRST FOREIGN KEY EVER TAKEN ON Drawer. FlatWireSchema_Lookup.md
-- recorded that Drawer was "an equipment register, not a join target" and named
-- G77's tooling work as its likely first referrer. This is that referrer.
--
-- THE LIFE MODEL IS GRIND, NOT FOOTAGE. A die is consumed by footage
-- (LastGrindingFeet / TotalFeetAllowed); a roll is reground until it reaches a
-- minimum OD. So this table carries OdIn / MinOdIn / DateOfLastGrind and NO footage
-- counter, matching the client's Edger grid rather than the Die grid. G77 already
-- called out that the two life models differ. ToolingInventoryEdger (6 Sep 2026,
-- D-53) is built on the same grind model, from that grid directly.
--
-- WHAT IS NOT KNOWN -- G87, and Q92 is the send-back. Die, Edger and Straightener
-- each arrived as a screenshot grid with an ordered column list. Roll sets arrived as
-- ONE SENTENCE. The columns below are OUR reading of that sentence against the shape
-- of the other three grids, not a client field set. Four things are open: the column
-- list itself; whether capstan rolls are the same tab option as mill rolls or a
-- fifth; whether "refurbished" is the same lifecycle as the edger's "In Grinding";
-- and what Machine Name a capstan roll carries, given DB1/DB2 sit on FL1.
-- Treat every column here as PROPOSED until Q92 comes back.
--
-- QUANTITIES FROM THE MAIL, recorded as data not as constraints: sets are 2 rolls
-- (RollQty), capstan inventory is 2 "will be adding a spare" -- so 3 is the target
-- and 2 is today's truth, which is why nothing caps the row count.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ToolingInventoryRollSet]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[ToolingInventoryRollSet] (
        [Id]                 INT           NOT NULL IDENTITY(1,1),
        -- RS-{position}-{seq}, e.g. RS-FL1S1-001. Our format, not the client's --
        -- no alpha appears on any tooling grid the client has sent (see OI-141).
        [RollSetAlpha]       VARCHAR(20)   NOT NULL,
        [RollType]           VARCHAR(10)   NOT NULL,       -- Mill | Capstan
        -- Exactly one of these two is populated; see CK_TIRS_Mount.
        [StandId]            INT           NULL,           -- mill rolls: FM1, FM2_S1, FM2_S2, FM2_S3
        [DrawerId]           INT           NULL,           -- capstan rolls: DB1, DB2
        -- Client grid "Machine Name". FL1 | FL2 only -- FL3 uses a combination of the
        -- two and holds no tooling of its own (client, 3 Sep 2026).
        [MachineName]             VARCHAR(5)    NULL,
        [SetNumber]          VARCHAR(20)   NULL,           -- client grid "Set Number" -- lettered A / B / C on the edger and straightener grids
        [RollQty]            INT           NOT NULL CONSTRAINT [DF_ToolingInventoryRollSet_RollQty] DEFAULT (2),  -- client grid "Roll Qty". Every set the client named is 2
        -- The TOOL's own nominal size: 12.000 for FL1-S1; 8.000 / 6.000 / 6.000 for
        -- FL2-S1/S2/S3. Stand.RollDiameterIn is the MACHINE's and stays authoritative.
        [NominalDiameterIn]  DECIMAL(5,3)  NULL,
        [OdIn]               DECIMAL(8,4)  NULL,           -- client grid 'OD(")' -- current outside diameter, falls with each grind
        [MinOdIn]            DECIMAL(8,4)  NULL,           -- client grid 'Min OD(")' -- scrap threshold
        [IdIn]               DECIMAL(8,4)  NULL,           -- client grid 'ID(")'
        [SerialNo]           VARCHAR(50)   NULL,           -- client grid "S/N"
        [PartNo]             VARCHAR(50)   NULL,           -- client grid "P/N"
        [Location]           VARCHAR(50)   NULL,           -- client grid "Location" -- roll shop / crib position
        -- The client's three lifecycle values plus Inactive, identical to
        -- ToolingInventoryDie. A BIT cannot express "In Grinding" -- G77's point.
        -- 'Inactive' was 'Retired' until 10 Sep 2026; see the note on the die.
        [LifecycleStatus]    VARCHAR(20)   NOT NULL CONSTRAINT [DF_ToolingInventoryRollSet_LifecycleStatus] DEFAULT ('In Service'),
        -- "they can be refurbished" -- the client's word for the capstan rolls, and
        -- NOT known to be the same operation as the edger's regrind. Q92 asks.
        [IsRefurbishable]    BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryRollSet_IsRefurbishable] DEFAULT (0),
        [DateOfChange]       DATE          NULL,           -- client grid "Date of Change"
        [DateOfLastGrind]    DATE          NULL,           -- client grid "Date of Last Grind"
        [InUse]              BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryRollSet_InUse] DEFAULT (0),   -- client grid "In Use"
        [Notes]              VARCHAR(500)  NULL,
        [IsActive]           BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryRollSet_IsActive] DEFAULT (1),

        CONSTRAINT [PK_ToolingInventoryRollSet]          PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_ToolingInventoryRollSet_Alpha]    UNIQUE ([RollSetAlpha]),
        CONSTRAINT [CK_TIRS_RollType]        CHECK ([RollType] IN ('Mill','Capstan')),
        -- A mill roll set hangs off a Stand and a capstan roll set off a Drawer.
        -- Exactly one mount, and it must agree with the discriminator.
        CONSTRAINT [CK_TIRS_Mount]           CHECK (
                                                 ([RollType] = 'Mill'    AND [StandId] IS NOT NULL AND [DrawerId] IS NULL)
                                              OR ([RollType] = 'Capstan' AND [DrawerId] IS NOT NULL AND [StandId] IS NULL)),
        CONSTRAINT [CK_TIRS_MachineName]          CHECK ([MachineName] IS NULL OR [MachineName] IN ('FL1','FL2')),
        CONSTRAINT [CK_TIRS_RollQty]         CHECK ([RollQty] > 0),
        CONSTRAINT [CK_TIRS_NominalDiameter] CHECK ([NominalDiameterIn] IS NULL OR [NominalDiameterIn] > 0),
        CONSTRAINT [CK_TIRS_Od]              CHECK ([OdIn] IS NULL OR [MinOdIn] IS NULL OR [MinOdIn] < [OdIn]),
        CONSTRAINT [CK_TIRS_LifecycleStatus] CHECK ([LifecycleStatus] IN ('Active','In Service','In Grinding','Inactive'))
        -- Deliberately NO footage columns. See the life-model note above: a roll is
        -- reground to a minimum OD, not consumed by feet. Do not add die-life columns
        -- here by analogy with ToolingInventoryDie -- that analogy is the thing G77
        -- warns about.
        --
        -- SerialNo uniqueness is a FILTERED index in script 07, on the same reasoning
        -- as the die: a plain UNIQUE admits only one NULL and the seed leaves them all
        -- NULL until the client supplies serials.
    );
    PRINT 'Created table: ToolingInventoryRollSet';
END
ELSE
    PRINT 'Table already exists: ToolingInventoryRollSet';
GO

-- ------------------------------------------------------------
-- ToolingInventoryEdger
-- The register of PHYSICAL EDGER ROLL SETS -- the second of the four Tooling
-- Inventory tool types (D-42), and the one that CLOSES G77's edger half.
--
-- THIS TABLE ABSORBS [dbo].[Edger]. IT IS NOT A NEW SIBLING. Edger held five
-- columns -- Id, Name, EdgeType, ToolingSetNo, IsActive -- against the client's
-- FOURTEEN-column Tooling Inventory grid of 31 Aug 2026:
--
--   Machine Name, Type, Location, Set Number, P/N, Roll Qty,
--   STD Removal From OD("), Gauge Range("), OD("), ID("), Min OD("),
--   Date of Change, Date of Last Grind, Status
--
-- WHY ABSORB RATHER THAN SIT BESIDE IT. 02_Schedule already says outright that
-- "EdgerId identifies the fitted TOOL, not the STATION" -- so Edger was ALREADY
-- meant to be the physical tool register and was simply too thin to be one. Two
-- registers both meaning "edger" is exactly the grain ambiguity G77 raised:
-- Edger's seed (EDGE-ROUND-A) named a PROFILE while its ToolingSetNo named a
-- PHYSICAL SET. One table resolves it. PassScheduleComponent.EdgerId re-points
-- here and FK_PSC_Edger KEEPS ITS NAME -- renaming it would churn [API],
-- FW-147's enum-mirror inventory and TC-020 for no gain.
--
-- NOT the die split's shape, and that is deliberate. The die split kept Drawer
-- as the two draw BOXES and moved the tooling out. There is no edger equivalent
-- of Drawer to keep: E1/E2 exist nowhere as rows, only as setup-step text, and
-- CK_PSC_ComponentName still offers a single 'EdgeSet' value for two physical
-- stations. THAT STATION GAP IS NOT ADDRESSED HERE and stays open.
--
-- EdgeType is CARRIED OVER from Edger and it is OURS -- it does not appear on the
-- client's grid. EdgerType, beside it, IS the grid's "Type" cell and is a separate
-- column: whether the two are actually the same field for an edger is OPEN, and Q95
-- asks. (ToolingInventoryDie reads the same grid heading as the die MATERIAL and
-- calls it DieType, so the heading demonstrably does not mean one thing across the
-- grids -- which is why they are not merged here on our own reading.)
--   EdgeType IS NOT NULL AGAIN, restored 10 Sep 2026, and it is no longer OURS.
--   It was relaxed to NULL on 6 Sep because the client's fourteen columns did not
--   classify a set by edge profile, and requiring it would have invented a
--   mandatory classification the client had never supplied -- the G87 mistake.
--   D-53 named Q95 as the send-back that would decide it, and Q95 leg 5 has
--   returned: "edger sets are distinguished from one another by gauge band and
--   profile (edge type)" and "a set will NOT share different profiles", profile
--   being defined "per set". So the classification is the client's, it is
--   definitional, and NULL is no longer a legitimate state.
--
--   THE VOCABULARY IS THREE VALUES HERE AND FOUR ON THE SCHEDULE, and that is
--   deliberate. The client's product edge profiles are Natural Round Edge (no
--   edging), Full Round Edge, Square Edge and Broken Edge. 'Natural Round Edge'
--   means NO EDGING, so no physical set is ever ground for it -- and the client's
--   own 10 Sep roll table carries no such row, only -S, -R and -B suffixes. A
--   schedule that specifies it leaves the EdgeSet component Bypass or Skip, which
--   CK_PSC_State already expresses. Do NOT add it here, and do NOT relax
--   CK_PSC_EdgeTypeReq to accommodate it.
--
-- THE NATURAL KEY IS (MachineName, SetNumber), taken 10 Sep 2026. G104's recorded
-- state -- "TWO IDENTICAL ROWS ARE CURRENTLY POSSIBLE" -- is closed. Both earlier
-- candidates stay removed, and the reasoning for each still holds: they were OURS,
-- and nothing read them.
--
--   Name was inherited from [dbo].[Edger], where it was NOT NULL and UNIQUE. It
--   was removed on 6 Sep 2026 once it was verified that NOTHING read it: no
--   procedure, no view, no join, and no seed row -- FlatWire_SampleData_Schedule
--   resolves EdgerId by Id, never by name. The client's fourteen-column grid has
--   no Name field at all. Keeping it NOT NULL meant the Tooling Inventory form
--   had to demand a name for every new tool, for a field the client never asked for.
--
--   EdgerToolAlpha (ED-{seq}) followed on 7 Sep 2026, for the same reason. No
--   client tooling grid has ever shown an alpha (OI-141), and the client
--   identifies a set by Machine Name + Set Number + P/N. ToolingInventoryDie and
--   ToolingInventoryRollSet KEEP theirs, and that is NOT an inconsistency to fix:
--   DieAlpha is load-bearing because FR-254 has the Die Change screen read it AT
--   RUNTIME. This table has no such caller.
--
-- (MachineName, SetNumber) IS NOW TAKEN, as UQ_ToolingInventoryEdger_Set. Q95 leg 2
-- asked whether Set Number is unique per LINE or per SHOP; the client answered on
-- 10 Sep 2026 with an encoded scheme -- 400-S / 401-S / 402-S / 400-R / 400-B,
-- where the stem carries the gauge band and the suffix the profile -- so a set
-- number is meaningful and shop-unique. Both key columns are therefore NOT NULL.
-- Do not reinstate Name or the alpha.
--
--   ROLL-LEVEL TRACKING IS NOT BUILT, and that is on purpose. The same answer
--   floated it -- "we may need to track as individual rolls, and have assigned set
--   numbers, with profile and gauge range identifiers. I am open to suggestions and
--   alternatives, lets discuss." That is a discussion, not a specification, and
--   building a ToolingInventoryEdgerRoll on one sentence is precisely the G87
--   mistake. The proposal has gone back with the send-back instead.
--
--   AND THE CLIENT'S OWN SAMPLE CONTRADICTS THE SCHEME: two rows read 400-B with
--   roll prefix R2 and gauge .015-.025, where the stem should read 401. Either
--   they are 401-B or the stem encodes nothing. Settle that before any roll table.
--
-- THE LIFE MODEL IS GRIND, NOT FOOTAGE -- the same distinction
-- ToolingInventoryRollSet carries. So there is NO footage counter here. Do not add
-- LastGrindingFeet / TotalFeetAllowed by analogy with ToolingInventoryDie -- that
-- analogy is the thing G77 warns about.
--
--   BUT THE ARITHMETIC HAS NO BASIS YET. This block used to read "STD Removal From
--   OD .100 against OD 6.00 and Min OD 4.75 is about twelve grinds". Q95 leg 4
--   asked whether .100 means per grind, warning that it was "the one that silently
--   produces wrong numbers rather than an obviously empty field". The client
--   answered on 10 Sep 2026: "this was an arbitrary number that I entered. I will
--   need to verify with engineering what the actual standard would be. This could
--   also be variable depending on the groove width range."
--
--   So the twelve-grind figure is WITHDRAWN as fact. NO SCREEN MAY DISPLAY A
--   REMAINING-GRINDS OR REMAINING-LIFE FIGURE until engineering confirms the
--   standard. The column keeps its seeded .100 as shape, not as a specification.
--   Whether StdRemovalFromOdIn belongs on the GROOVE rather than the set depends
--   on an answer the client does not have -- do not move it speculatively.
--
-- GAUGE RANGE IS A CHILD TABLE, NOT A DELIMITED STRING. The grid's cell reads
-- ".045, .040, .035" -- three grooves cut into one roll at specific gauges, in
-- the client's own words. G77 called for a child table in terms, and the reason
-- is that a pass schedule must eventually be able to select A GROOVE, which a
-- VARCHAR forbids. See ToolingInventoryEdgerGauge below.
--
-- ID(MM) IS NOT STORED, on the ToolingInventoryDie precedent: it is a derived
-- display value. Compute it in the UI.
--
-- MachineName is 'FL2' ONLY. The client's grid attributes edgers to FL2, and D-42
-- bars any tooling row from FL3 ("maintain them for FL1/FL2 and FL3 should use
-- a combination of the two"). NOTE this does NOT apply to Drawer, which is
-- EQUIPMENT and keeps FL3 in its own CHECK. Do not "align" the two.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ToolingInventoryEdger]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[ToolingInventoryEdger] (
        [Id]                 INT           NOT NULL IDENTITY(1,1),
        [EdgeType]           VARCHAR(20)   NOT NULL,       -- Full Round Edge | Square Edge | Broken Edge. NOT NULL again -- see the block above
        [MachineName]             VARCHAR(5)    NOT NULL,       -- client grid "Machine Name". FL2 only. NOT NULL: half the natural key
        [EdgerType]          VARCHAR(20)   NULL,           -- client grid "Type"
        [Location]           VARCHAR(50)   NULL,           -- client grid "Location" -- roll shop / crib position. NOT the line position: see AllocatedPosition
        [AllocatedPosition]  VARCHAR(2)    NULL,           -- E1 | E2 -- the line position this set is allocated to, client 10 Sep 2026. NULL while off the line
        [SetNumber]          VARCHAR(20)   NOT NULL,       -- client grid "Set Number" -- 400-S / 401-S / 402-R style. REPLACES Edger.ToolingSetNo
        [PartNo]             VARCHAR(50)   NULL,           -- client grid "P/N"
        [SerialNo]           VARCHAR(50)   NULL,           -- [PROPOSED] ours: the edger grid carries NO S/N column (G104, Q95)
        [RollQty]            INT           NOT NULL CONSTRAINT [DF_ToolingInventoryEdger_RollQty] DEFAULT (2),  -- client grid "Roll Qty" -- the sample reads 2
        [StdRemovalFromOdIn] DECIMAL(8,4)  NULL,           -- client grid 'STD Removal From OD(")' -- .100 per grind
        [OdIn]               DECIMAL(8,4)  NULL,           -- client grid 'OD(")' -- 6.00, falls with each grind
        [IdIn]               DECIMAL(8,4)  NULL,           -- client grid 'ID(")'
        [MinOdIn]            DECIMAL(8,4)  NULL,           -- client grid 'Min OD(")' -- 4.75, the scrap threshold
        [DateOfChange]       DATE          NULL,           -- client grid "Date of Change"
        [DateOfLastGrind]    DATE          NULL,           -- client grid "Date of Last Grind"
        -- The client's three Status values plus Inactive, identical to
        -- ToolingInventoryDie and ToolingInventoryRollSet. A BIT cannot express
        -- "In Grinding" -- that was G77's point about the old Edger.IsActive.
        -- The client defined all four on 10 Sep 2026: "In Grinding" = being
        -- resurfaced, either roll grinding or outsourced (so 'refurbished' is the
        -- same operation, not a second vocabulary); "In Service" = installed at
        -- FL2.E1 or FL2.E2; "Active" = available to allocate; "In Active" = worn
        -- out after its last available grind. 'Inactive' was 'Retired' until then.
        [LifecycleStatus]    VARCHAR(20)   NOT NULL CONSTRAINT [DF_ToolingInventoryEdger_LifecycleStatus] DEFAULT ('In Service'),
        [InUse]              BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryEdger_InUse] DEFAULT (0),
        [Notes]              VARCHAR(500)  NULL,
        [IsActive]           BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryEdger_IsActive] DEFAULT (1),

        CONSTRAINT [PK_ToolingInventoryEdger]        PRIMARY KEY CLUSTERED ([Id] ASC),
        -- THE NATURAL KEY, taken 10 Sep 2026 once Q95 leg 2 answered. Both columns
        -- are NOT NULL so a plain UNIQUE behaves: SQL Server treats NULLs as equal,
        -- which is why SerialNo uses a FILTERED index in script 07 instead.
        -- DO NOT also create a UNIQUE INDEX on these two columns -- that duplicate
        -- is exactly what moved the index figure 91 -> 90 on 8 Sep 2026.
        CONSTRAINT [UQ_ToolingInventoryEdger_Set]    UNIQUE ([MachineName], [SetNumber]),
        -- The surviving half of CK_Edger_EdgeType. CK_PSC_EdgeType stays where it
        -- is: it constrains the SCHEDULE's chosen profile, which is a different
        -- assertion from the tool's capability. Do not merge them -- and note they
        -- now differ in CARDINALITY too, which makes the separation load-bearing:
        -- the schedule takes all FOUR profiles, this table takes THREE, because
        -- 'Natural Round Edge' means NO EDGING and no set is ground for it. The
        -- client's own 10 Sep roll table carries no such row (only -S, -R, -B).
        CONSTRAINT [CK_TIE_EdgeType]        CHECK ([EdgeType] IN ('Full Round Edge','Square Edge','Broken Edge')),
        CONSTRAINT [CK_TIE_MachineName]          CHECK ([MachineName] IN ('FL2')),
        -- E1 = edger between S1 and S2, E2 = between S2 and S3 (client, 10 Sep
        -- 2026). NULL is legitimate: a set in the crib or out for grinding has no
        -- line position, which is why this is NOT a redefinition of Location.
        CONSTRAINT [CK_TIE_AllocatedPosition] CHECK ([AllocatedPosition] IS NULL OR [AllocatedPosition] IN ('E1','E2')),
        CONSTRAINT [CK_TIE_RollQty]         CHECK ([RollQty] > 0),
        CONSTRAINT [CK_TIE_StdRemoval]      CHECK ([StdRemovalFromOdIn] IS NULL OR [StdRemovalFromOdIn] > 0),
        CONSTRAINT [CK_TIE_Od]              CHECK ([OdIn] IS NULL OR [MinOdIn] IS NULL OR [MinOdIn] < [OdIn]),
        CONSTRAINT [CK_TIE_LifecycleStatus] CHECK ([LifecycleStatus] IN ('Active','In Service','In Grinding','Inactive'))
        -- Deliberately NO footage columns. See the life-model note above.
        --
        -- SerialNo uniqueness is a FILTERED index in script 07, on the same
        -- reasoning as the die and the roll set: a plain UNIQUE admits only one
        -- NULL and the seed leaves them all NULL until the client supplies serials.
    );
    PRINT 'Created table: ToolingInventoryEdger';
END
ELSE
    PRINT 'Table already exists: ToolingInventoryEdger';
GO

-- ------------------------------------------------------------
-- ToolingInventoryEdgerGauge
-- One row per GROOVE cut into an edger roll set.
--
-- The client's Tooling Inventory grid holds the whole set in ONE CELL --
-- 'Gauge Range(") = .045, .040, .035' -- because, in Tim O'Brien's words of
-- 24 Aug 2026, edgers "have multiple grooves cut into them at specific gauges".
-- That is a repeating group, and G77 asked for a child table in terms rather
-- than a delimited string. The failure mode a VARCHAR causes is specific: a
-- pass schedule can never select A GROOVE, only a whole tool.
--
-- GrooveNo IS GONE, and Q95 leg 3 is why. It was [PROPOSED] because the grid did
-- not number or order the grooves; the client answered on 10 Sep 2026 that rolls
-- are identified "by groove gauge range and profile", not by position, so the
-- column asserted a fact that does not exist. Q95 leg 3 said in terms that the
-- answer "decides whether GrooveNo is real data or should be dropped".
--
-- A GROOVE IS IDENTIFIED BY ITS GAUGE, and (EdgerToolId, GaugeIn) already says
-- so. The client: "depending on groove height, there could be 1-5+ grooves cut
-- into a roll. All groves would have the same profile, just different grove
-- heights" -- so height varies per groove and profile does not, which is why
-- profile lives on the PARENT and GaugeIn is the per-groove discriminator.
-- CONFIRM whether "groove height" is exactly this GaugeIn before adding a column
-- for it; on the present reading they are the same measure under two names.
--
-- THE SEEDED GAUGE VALUES ARE ARBITRARY, by the client's own admission on
-- 10 Sep 2026: "the gauge ranges I gave are again arbitrary, given that rolls
-- would be cut based upon a tight range of finished gauge products". Treat the
-- three seeded rows as shape, never as inventory.
--
-- Uniqueness is (EdgerToolId, GaugeIn): one tool cannot carry the same gauge
-- twice. That UNIQUE leads on EdgerToolId, so NO separate index on the FK
-- column is created in script 07 -- see 07's trailing block.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ToolingInventoryEdgerGauge]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[ToolingInventoryEdgerGauge] (
        [Id]          INT           NOT NULL IDENTITY(1,1),
        [EdgerToolId] INT           NOT NULL,              -- FK to ToolingInventoryEdger.Id, added by script 06
        [GaugeIn]     DECIMAL(8,4)  NOT NULL,              -- one groove: .0450 | .0400 | .0350
        [IsActive]    BIT           NOT NULL CONSTRAINT [DF_ToolingInventoryEdgerGauge_IsActive] DEFAULT (1),

        CONSTRAINT [PK_ToolingInventoryEdgerGauge] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_TIEG_ToolGauge]             UNIQUE ([EdgerToolId], [GaugeIn]),
        CONSTRAINT [CK_TIEG_GaugeIn]               CHECK ([GaugeIn] > 0)
    );
    PRINT 'Created table: ToolingInventoryEdgerGauge';
END
ELSE
    PRINT 'Table already exists: ToolingInventoryEdgerGauge';
GO

-- ---------------------------------------------------------------------------
-- Dancer — tension-management rollers.
--
-- FM1 carries ONE dancer; FM2 carries TWO, sitting BETWEEN stands (S1/S2 and
-- S2/S3) rather than at them (client decision D-28, 6 Aug 2026).
--
-- Mode is unresolved (OQ-32): the 6 Aug call described two selectable modes,
-- while the 23 Jul meeting recorded tension control as machine-driven. The
-- columns below carry the equipment capability only — no pass schedule column
-- is added, because that is contingent on the answer and PassScheduleComponent
-- is MVP-2. See [PLC 5.5] and ClientCall_2026-07-23_SyncPlan.md 3.1.
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Dancer]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Dancer] (
        [Id]                  INT         NOT NULL IDENTITY(1,1),
        [Name]                VARCHAR(30) NOT NULL,               -- position-only: FM1_Dancer, FM2_Dancer1, FM2_Dancer2
        [MachineName]              VARCHAR(5)  NULL,                   -- FL1 / FL2 / FL3; NULL = shared across lines
        [Position]            VARCHAR(20) NOT NULL,               -- FM1 | FM2_S1_S2 | FM2_S2_S3
        [Ordinal]             INT         NULL,                   -- 1 = upstream, 2 = downstream; NULL when single (FM1)
        [SupportsTensionMode] BIT         NOT NULL CONSTRAINT [DF_Dancer_SupportsTension] DEFAULT (0),
        [DefaultMode]         VARCHAR(10) NOT NULL CONSTRAINT [DF_Dancer_DefaultMode]     DEFAULT ('Dancer'),
        [IsActive]            BIT         NOT NULL CONSTRAINT [DF_Dancer_IsActive]        DEFAULT (1),

        CONSTRAINT [PK_Dancer]             PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Dancer_Name]        UNIQUE ([Name]),
        CONSTRAINT [CK_Dancer_Position]    CHECK ([Position] IN ('FM1', 'FM2_S1_S2', 'FM2_S2_S3')),
        CONSTRAINT [CK_Dancer_DefaultMode] CHECK ([DefaultMode] IN ('Dancer', 'Tension')),
        CONSTRAINT [CK_Dancer_Ordinal]     CHECK ([Ordinal] IS NULL OR [Ordinal] IN (1, 2)),
        -- Tension may only be the default on a dancer that supports it.
        CONSTRAINT [CK_Dancer_ModeSupport] CHECK ([DefaultMode] <> 'Tension' OR [SupportsTensionMode] = 1)
    );
    PRINT 'Created table: Dancer';
END
ELSE
    PRINT 'Table already exists: Dancer';
GO


-- ------------------------------------------------------------
-- AlloyProperty
-- Per-alloy process properties consumed by the pass-schedule
-- generator (max reduction, springback) and by output-weight
-- derivation (LbPerFtFactor — footage → weight, OQ-10 default).
-- The authoritative alloy list referenced by PassSchedule.Alloy.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlloyProperty]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[AlloyProperty] (
        [Id]                    INT          NOT NULL IDENTITY(1,1),
        [Alloy]                 VARCHAR(10)  NOT NULL,       -- e.g. 1100, 1350, 3003, 5052, 6061
        [MaxReductionPerPass]   DECIMAL(5,3) NOT NULL,       -- fractional max area reduction per pass (e.g. 0.220 = 22%)
        [SpringbackFactor]      DECIMAL(5,3) NOT NULL,       -- roll-gap springback multiplier (e.g. 0.970)
        -- DIMENSIONAL TOLERANCES — min/max pairs, not a single ± (client, 30 Jul 2026, Q22).
        -- Tim confirmed upper and lower limits for gauge (height), width and diameter, plus
        -- ovality, held here in the lookup and applied at BOTH pre-check-in and check-in.
        -- Modelled as OFFSETS about nominal, matching CHK007 / FR-065 ("0.30 with ±0.01 gives
        -- 0.29–0.31"), so an asymmetric band is expressible: nominal − Minus .. nominal + Plus.
        -- Gauge and width carry forward the previously seeded symmetric value in BOTH columns
        -- (interim, not new data). Diameter and ovality are NULL: the values are OWED BY
        -- E-MAIL and nothing is to be seeded until they arrive — "I want to say it's plus or
        -- minus 10" is not a specification.
        [GaugeToleranceMinusIn]     DECIMAL(8,4) NOT NULL,   -- lower gauge limit, as an offset below nominal (in)
        [GaugeTolerancePlusIn]      DECIMAL(8,4) NOT NULL,   -- upper gauge limit, as an offset above nominal (in)
        [WidthToleranceMinusIn]     DECIMAL(8,4) NOT NULL,   -- lower width limit (in)
        [WidthTolerancePlusIn]      DECIMAL(8,4) NOT NULL,   -- upper width limit (in)
        [RodDiameterToleranceMinusIn] DECIMAL(8,4) NULL,     -- lower incoming-rod diameter limit (in); CHK007
        [RodDiameterTolerancePlusIn]  DECIMAL(8,4) NULL,     -- upper incoming-rod diameter limit (in); CHK007
        [RodOvalityMaxIn]           DECIMAL(8,4) NULL,       -- max |M1 − M2| out-of-round; per-alloy reference
                                                             -- data, NOT a constant. Supersedes the hard-coded
                                                             -- 0.003" the April check-in plan carried (deleted)
        [SpeedRangeMinFpm]      INT          NOT NULL,       -- default minimum line speed (ft/min)
        [SpeedRangeMaxFpm]      INT          NOT NULL,       -- default maximum line speed (ft/min)
        [LbPerFtFactor]         DECIMAL(10,6) NULL,          -- footage → weight factor (lb per ft); OQ-10 PROVISIONAL — confirm per cross-section
        [DensityLbPerIn3]       DECIMAL(10,6) NULL,          -- alloy density (lb/in^3) for area×density fallback
        [IsWeldingWire]         BIT          NOT NULL CONSTRAINT [DF_AlloyProperty_IsWeldingWire] DEFAULT (0),  -- welding-wire grade flag (extra traceability)
        [IsActive]              BIT          NOT NULL CONSTRAINT [DF_AlloyProperty_IsActive] DEFAULT (1),

        CONSTRAINT [PK_AlloyProperty]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_AlloyProperty_Alloy]     UNIQUE ([Alloy]),
        CONSTRAINT [CK_AlloyProperty_Reduction] CHECK ([MaxReductionPerPass] > 0 AND [MaxReductionPerPass] < 1),
        CONSTRAINT [CK_AlloyProperty_Speed]     CHECK ([SpeedRangeMinFpm] < [SpeedRangeMaxFpm]),
        CONSTRAINT [CK_AlloyProperty_GaugeTol]  CHECK ([GaugeToleranceMinusIn] > 0 AND [GaugeTolerancePlusIn] > 0),
        CONSTRAINT [CK_AlloyProperty_WidthTol]  CHECK ([WidthToleranceMinusIn] > 0 AND [WidthTolerancePlusIn] > 0),
        -- Rod diameter is all-or-nothing: half a band cannot validate anything.
        -- Note the explicit IS NOT NULL pair: `Minus > 0 AND Plus > 0` alone evaluates to
        -- UNKNOWN when one side is NULL, and a CHECK constraint accepts UNKNOWN — so half a
        -- band would have been admitted.
        CONSTRAINT [CK_AlloyProperty_RodDiaTol] CHECK (
                                                    ([RodDiameterToleranceMinusIn] IS NULL AND [RodDiameterTolerancePlusIn] IS NULL)
                                                 OR ([RodDiameterToleranceMinusIn] IS NOT NULL AND [RodDiameterTolerancePlusIn] IS NOT NULL
                                                        AND [RodDiameterToleranceMinusIn] > 0 AND [RodDiameterTolerancePlusIn] > 0)
                                                ),
        -- Ovality is |M1 − M2|, so only an upper limit is meaningful.
        CONSTRAINT [CK_AlloyProperty_Ovality]   CHECK ([RodOvalityMaxIn] IS NULL OR [RodOvalityMaxIn] > 0)
    );
    PRINT 'Created table: AlloyProperty';
END
ELSE
    PRINT 'Table already exists: AlloyProperty';
GO

-- ------------------------------------------------------------
-- PayoffPosition
-- Reference table for material input/output positions. Gives
-- FlatWireRunDetail.PayoffPositionId a real parent — previously it
-- was an FK-style INT pointing at a table that did not exist
-- (REVIEW.md #15).
--
-- Three positions are modelled, not two: FL1/FL3 draw rod from the
-- dual-position VPS (1 and 2), while FL2 uses a traversing take-up.
-- Rod-fed tables (RodStaging, RodCheckin, RodCheckout, SpoolCheckin)
-- deliberately narrow to CHECK (1,2) — that is intentional, not an
-- oversight: a rod bundle is only ever mounted on a VPS bay.
--
-- Id is explicit (no IDENTITY) so the values are pinned and match the
-- API enum PayoffPosition { Payoff1 = 1, Payoff2 = 2 }.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PayoffPosition]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PayoffPosition] (
        [Id]          INT         NOT NULL,               -- 1 | 2 | 3 — pinned, not generated
        [Code]        VARCHAR(20) NOT NULL,               -- Payoff1 | Payoff2 | TraversingTakeup
        [DisplayName] VARCHAR(40) NOT NULL,               -- operator-facing label
        [Equipment]   VARCHAR(20) NOT NULL,               -- VPS | TraversingTakeup
        [MaxWeightLb] DECIMAL(8,2) NULL,                  -- position capacity (lb)
        [IsRodFed]    BIT         NOT NULL,               -- 1 = accepts a rod bundle (FL1/FL3)
        [IsActive]    BIT         NOT NULL CONSTRAINT [DF_PayoffPosition_IsActive] DEFAULT (1),

        CONSTRAINT [PK_PayoffPosition]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_PayoffPosition_Code]   UNIQUE ([Code]),
        CONSTRAINT [CK_PayoffPosition_Id]     CHECK ([Id] IN (1, 2, 3)),
        CONSTRAINT [CK_PayoffPosition_Code]   CHECK ([Code] IN ('Payoff1','Payoff2','TraversingTakeup')),
        CONSTRAINT [CK_PayoffPosition_Equip]  CHECK ([Equipment] IN ('VPS','TraversingTakeup'))
    );
    PRINT 'Created table: PayoffPosition';
END
ELSE
    PRINT 'Table already exists: PayoffPosition';
GO

-- Seed the three fixed positions. Idempotent.
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayoffPosition] WHERE [Id] = 1)
    INSERT INTO [dbo].[PayoffPosition] ([Id],[Code],[DisplayName],[Equipment],[MaxWeightLb],[IsRodFed])
    VALUES (1, 'Payoff1', 'Payoff 1', 'VPS', 9000.00, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayoffPosition] WHERE [Id] = 2)
    INSERT INTO [dbo].[PayoffPosition] ([Id],[Code],[DisplayName],[Equipment],[MaxWeightLb],[IsRodFed])
    VALUES (2, 'Payoff2', 'Payoff 2', 'VPS', 9000.00, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayoffPosition] WHERE [Id] = 3)
    INSERT INTO [dbo].[PayoffPosition] ([Id],[Code],[DisplayName],[Equipment],[MaxWeightLb],[IsRodFed])
    VALUES (3, 'TraversingTakeup', 'Traversing take-up (FL2)', 'TraversingTakeup', NULL, 0);
GO

-- ------------------------------------------------------------
-- SpoolConfiguration
-- The SIZE CLASS a spool article belongs to -- the acceptable loaded weight
-- band and the core / outer diameter bands, validated at FL2/FL3 check-in
-- against the material being wound on the article.
--
-- *** SPLIT BACK OUT OF Spool, 8 Sep 2026 (D-58). SUPERSEDES Q60'S MERGE. ***
--
-- Q60 merged this table into Spool on 23 Aug 2026, on the grounds that it was
-- a size class holding exactly ONE meaningful row against 30-45 articles. That
-- reasoning was sound and the merge is not being called a mistake. What it
-- bought was one fewer table; what it cost is stated in the merge's own
-- comment, which named its reversal condition:
--
--     "It is worth it only while 'every article is one size' holds. IF THE
--      CLIENT CONFIRMS A SECOND SIZE, revisit the merge."
--
-- ⚠ THAT CONDITION HAS *NOT* FIRED, AND THIS SPLIT DOES NOT CLAIM IT HAS.
-- The client's statement of 20 Aug 2026 -- "30 purchased with 15 more under
-- consideration, ALL ONE STANDARD SIZE" -- still stands unsuperseded. TKUP-1's
-- 3,500 lb and TKUP-2's 1,100 lb are MACHINE POSITIONS, not article sizes, and
-- FL2's output is a CORELESS coil wound on no reusable article at all. So the
-- split is made on NORMALISATION grounds and on direction: eight values
-- repeated across 45 rows, a second size costing an UPDATE of many rows where
-- this shape needs one INSERT, and a size-class name that lost its uniqueness
-- constraint in the merge. See D-58. Do not record it as a client change.
--
-- THE COLUMNS ARE NOT NULL AGAIN, AND THAT IS A REAL GAIN. On Spool the six
-- limits had to be nullable, so each CHECK carried an all-or-nothing IS NULL
-- clause -- the merge's own comment: "a CHECK accepts UNKNOWN, so a
-- half-populated band would be admitted". Here they are NOT NULL and the three
-- constraints reduce to Min < Max, which is what they were always meant to say.
--
-- IsDefault REPLACES A FALLBACK THE SPLIT BREAKS. SpoolProcessing.SpoolId is
-- nullable (Q42 open), so a material row may have no article and no limits to
-- validate against. Q60's answer was "any active Spool row's limits",
-- well-defined ONLY because all articles were one size. Splitting the size
-- class out is precisely what stops that being true, so exactly one row is
-- flagged default and UX_SpoolConfiguration_Default in 07 enforces it.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolConfiguration]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolConfiguration] (
        [Id]                 INT          NOT NULL IDENTITY(1,1),
        [Name]               VARCHAR(50)  NOT NULL,       -- e.g. 'TKUP-1 Intermediate Spool'
        [MinWeightLb]        DECIMAL(8,2) NOT NULL,        -- minimum acceptable loaded weight (lb)
        [MaxWeightLb]        DECIMAL(8,2) NOT NULL,        -- maximum acceptable loaded weight (lb)
        [MinCoreDiameterIn]  DECIMAL(8,4) NOT NULL,        -- minimum core (inside arbor) diameter (in)
        [MaxCoreDiameterIn]  DECIMAL(8,4) NOT NULL,        -- maximum core diameter (in)
        [MinOuterDiameterIn] DECIMAL(8,4) NOT NULL,        -- minimum outer diameter of the loaded article (in)
        [MaxOuterDiameterIn] DECIMAL(8,4) NOT NULL,        -- maximum outer diameter of the loaded article (in)
        -- The limits to apply when a material row names no article. See the header.
        [IsDefault]          BIT          NOT NULL CONSTRAINT [DF_SpoolConfig_IsDefault] DEFAULT (0),
        [IsActive]           BIT          NOT NULL CONSTRAINT [DF_SpoolConfig_IsActive]  DEFAULT (1),

        CONSTRAINT [PK_SpoolConfiguration]  PRIMARY KEY CLUSTERED ([Id] ASC),
        -- RESTORED with the table. The merge could not keep it: every article shares one size name,
        -- so the name stopped being unique the moment it moved onto Spool.
        CONSTRAINT [UQ_SpoolConfig_Name]    UNIQUE ([Name]),
        -- No IS NULL clauses -- the columns are NOT NULL here. See the header.
        CONSTRAINT [CK_SpoolConfig_Weight]     CHECK ([MinWeightLb]        < [MaxWeightLb]),
        CONSTRAINT [CK_SpoolConfig_CoreDiam]   CHECK ([MinCoreDiameterIn]  < [MaxCoreDiameterIn]),
        CONSTRAINT [CK_SpoolConfig_OuterDiam]  CHECK ([MinOuterDiameterIn] < [MaxOuterDiameterIn])
    );
    PRINT 'Created table: SpoolConfiguration';
END
ELSE
    PRINT 'Table already exists: SpoolConfiguration';
GO

-- ------------------------------------------------------------
-- Spool
-- The REUSABLE PHYSICAL ARTICLE a spool of wire is wound onto --
-- stencilled like a furnace plate, 30 purchased with 15 more under
-- consideration, all one standard size (client, 20 Aug 2026).
--
-- *** THE SIZE CLASS LIVES IN SpoolConfiguration AGAIN, 8 Sep 2026 (D-58). ***
-- SizeClass and the six Min/Max limit columns are GONE from this table, along
-- with CK_Spool_Weight / CK_Spool_CoreDiam / CK_Spool_OuterDiam, which return
-- to their original CK_SpoolConfig_* names. This table is an article register
-- again: which spools exist, what is stencilled on them, and which are in
-- service. SpoolTypeId names the size class.
--
-- HISTORY, kept because a reader will otherwise ask: those columns arrived here
-- on 23 Aug 2026 when Q60 merged SpoolConfiguration in, on the grounds that a
-- one-row size class against 30-45 articles was not worth a table. The merge's
-- own comment named the condition for undoing it and D-58 records that the
-- condition has NOT fired -- the split is on normalisation grounds, not on a
-- client change. Read SpoolConfiguration's header above for the full statement.
--
-- Nothing in the schema was a carrier before 22 Aug 2026 (OI-120).
--
-- WHY THE STENCIL IS THE KEY. The operator types what is painted on
-- the steel and the screen validates it against this list -- NOT a
-- drop-down, because 30-45 rows is too long to scroll on a shopfloor
-- panel (client, 20 Aug 2026). Matched case-insensitively by the
-- database's default collation: the operator is reading paint.
--
-- The carrier OUTLIVES the material on it. SpoolProcessing.Alpha is
-- the material identity; this is the article. Do not conflate them --
-- that is the distinction SpoolQueue.md open item 1 was raised to force.
--
-- RENAMED 23 Aug 2026: this table was SpoolCarrier, and the material
-- table was Spool. The names are SWAPPED -- physically a spool IS the
-- reusable article, so it belongs here in Lookup beside Stand / Drawer /
-- Edger / Dancer, and the material record is now SpoolProcessing in
-- 03_Materials. CarrierNo became SpoolNo, matching the "Spool number"
-- label SpoolQueue.md already shows the operator.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Spool]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Spool] (
        [Id]                 INT          NOT NULL IDENTITY(1,1),
        [SpoolNo]            VARCHAR(20)  NOT NULL,         -- the stencilled string; the seed builds SP-0001 .. SP-0045
                                                          -- (FOUR digits, so it cannot collide with a SpoolProcessing.Alpha;
                                                          --  format still open, Q42). This comment said 'S1 .. S45' until 8 Sep 2026.
        [SpoolTypeId]        INT          NOT NULL,         -- FK -> SpoolConfiguration.Id; RESTORED by D-58
        [IsActive]           BIT          NOT NULL CONSTRAINT [DF_Spool_IsActive] DEFAULT (1),  -- soft delete, per the other lookups
        [Notes]              VARCHAR(200) NULL,             -- e.g. "re-stencilled 08/2026", "withdrawn - damaged flange"

        CONSTRAINT [PK_Spool]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Spool_No]     UNIQUE ([SpoolNo])
        -- The three band CHECKs moved to SpoolConfiguration with the columns they guarded, and
        -- reverted to their original CK_SpoolConfig_* names. They are SIMPLER there: the columns
        -- are NOT NULL again, so the all-or-nothing IS NULL clauses the merge forced are gone.
    );
    PRINT 'Created table: Spool';
END
ELSE
    PRINT 'Table already exists: Spool';
GO


-- ===========================================================================
-- THE THREE REASON-CODE TABLES
--
-- Source: "Reason Codes.xlsx", Tim O'Brien -> Jaspreet Singh, 1 Sep 2026.
-- Closes actions A4 / A5 / A6 of the 23 Jul 2026 call and unblocks that
-- ledger's propagation wave W3.  Audit record, with the full transcription:
--   95-archive/source-documents/ClientEmail_2026-09-01_ReasonCodes_SyncPlan.md
--
-- HOW THE WORKBOOK ENCODES ITS ANSWER -- read this before editing any seed
-- row. The three sheets are NOT lists of new codes. They are the EXISTING UA
-- code lists with a three-way classification applied IN CELL FILL COLOUR:
--     yellow FFFFFF00  = existing code that APPLIES to wire flattening
--     green   theme 9  = NEW code to be added for wire flattening
--     no fill          = existing code that DOES NOT APPLY   <- unlabelled,
--                        and the largest of the three groups
-- Flattened to text the sheets are unusable. Counts by fill:
--     Down Time  36 apply + 36 new + 59 not applicable  -> 72 seeded here
--     WIPREJ     64 apply +  8 new + 24 not applicable  -> 72 seeded here
--     IT Inhibit  6 apply +  2 new +  0 not applicable  ->  8 (+4, see below)
-- The 83 not-applicable rows are DELIBERATELY NOT SEEDED. Do not "complete"
-- these lists from the workbook without re-reading the fill colours.
--
-- WHY THE SEEDS ARE HERE AND NOT IN FlatWire_SampleData_Lookup.sql. These are
-- PRODUCTION reference data. PayoffPosition above sets the precedent: its
-- fixed rows are seeded inline so that RunAll ALONE yields a working
-- database. If these rows lived only in the sample-data file, a production
-- deploy that skips sample data would come up with empty reason tables and a
-- pause dialog with nothing in it -- the same failure shape as empty pass
-- schedule tables, which the trial would not catch either.
--   (Noted, not fixed here: the Dancer seed comment in the sample-data file
--    says "three rows, and they are equipment, not sample data" while sitting
--    in the sample-data file. Same class of problem, separate change.)
--
-- CLIENT VOCABULARY vs SCHEMA VOCABULARY -- the descriptions are seeded
-- VERBATIM because they are operator-facing labels, and they use the
-- operator's words, not ours:
--     "Bundle" = the incoming rod           -> Rod,             alpha R#####
--     "Spool"  = the material in process    -> SpoolProcessing, alpha SP-#####
--     and NEVER the Spool table above, which since Q60 is the reusable
--     stencilled ARTICLE and carries no Alpha at all.
-- A reader who takes "Wrong Bundle / Spool" at schema face value lands
-- straight on the Q60 swap, which is silently wrong rather than obviously
-- stale. Do not "correct" these strings to schema names.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- DowntimeReason
-- The delay-code vocabulary for the flattening lines.
--
-- THIS REPLACES THE PREVIOUS PAUSE TAXONOMY, IT DOES NOT EXTEND IT. The repo
-- carried 15 reasons in 5 SEMANTIC categories (EquipmentMechanical /
-- MaterialHandling / QualityMeasurement / Operational / Safety) with codes
-- like DieChangeMidRun. The client's model is UA's existing delay-code system:
-- four TIME buckets keyed to the standard-time model, with per-code Nonprod /
-- Delay Buffer / Supervisor Override attributes. Literal overlap between the
-- two vocabularies is ZERO. The 23 Jul ledger's C1 warned exactly this:
-- "Tim's list either ratifies or replaces them -- do not assume it extends
-- them."
--
-- ONE MODEL WITH THE THROUGHPUT STANDARD TIMES. The buckets hold the standard
-- time and the delay codes consume it, mapping onto the Setup/Handling Times
-- tab of the 31 Aug 2026 client mail:
--     Setup    -> S1, S2            Handling -> H1A, H1AA, H1B, H2
--     RunTime  -> R                 Downtime -> nonproductive, outside the standard
--
-- WHICH TABLE CONSUMES WHICH BUCKET. Setup / RunTime / Handling codes (47) are
-- RunPauseEvent.ReasonCode -- a pause of a live run. Downtime codes (25) are
-- LineDowntimeEvent.DelayCode in 04_Runs, because every one of them is
-- line-down time (Power Outage, Fire Drill, Scheduled Maintenance, Waiting for
-- Spool From Previous Operation) and RunPauseEvent requires an active run.
-- See 04_Runs and sync-plan section 4.3.
--
-- FOUR CODES ARE STRANDED, and this table is where that is visible: the SRS
-- reasons OperatorBreak, ShiftChangeover, AwaitingSupervisor and
-- SafetyObservation have NO equivalent in the client's list. SET11 "Prior
-- Shift unaccountable" is not shift changeover and DWN07 "Fire Drill" is not a
-- safety observation. Owed back to the client; do not invent codes for them.
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DowntimeReason]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[DowntimeReason] (
        [Id]                  INT          NOT NULL IDENTITY(1,1),
        [DelayBucket]         VARCHAR(10)  NOT NULL,        -- Setup | RunTime | Handling | Downtime
        [DelayCode]           VARCHAR(10)  NOT NULL,        -- SET## | RUN## | HDL## | DWN##
        [Description]         VARCHAR(120) NOT NULL,        -- client wording, VERBATIM (see header note on Bundle/Spool)
        -- NULLABLE ON PURPOSE. Every Downtime row on the sheet says Yes except
        -- DWN29 "Other", whose cell is BLANK. A NOT NULL column fails on
        -- exactly one row out of 72, which is the worst kind of seed bug.
        [IsNonprodTime]       BIT          NULL,            -- does this code consume non-productive time?
        [Status]              VARCHAR(10)  NOT NULL CONSTRAINT [DF_DowntimeReason_Status] DEFAULT ('Active'),
        [DelayBufferMin]      INT          NOT NULL CONSTRAINT [DF_DowntimeReason_Buffer] DEFAULT (0),
        -- Only the Downtime bucket carries this column on the sheet; NULL
        -- elsewhere records "the client did not state one", not "no override".
        [SupervisorOverride]  BIT          NULL,
        -- 1 = the code string is OURS. The sheet leaves code, Status and Delay
        -- Buffer BLANK on all 36 new rows, so those three values are minted
        -- here and owed back to the client for confirmation.
        [IsProposedCode]      BIT          NOT NULL CONSTRAINT [DF_DowntimeReason_Proposed] DEFAULT (0),
        [IsActive]            BIT          NOT NULL CONSTRAINT [DF_DowntimeReason_IsActive] DEFAULT (1),

        CONSTRAINT [PK_DowntimeReason]          PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_DowntimeReason_Code]     UNIQUE ([DelayCode]),
        -- Redundant given UQ_..._Code, and deliberately so: it is the FK target
        -- that lets RunPauseEvent constrain (ReasonCode, ReasonCategory) as a
        -- PAIR, so a Setup code cannot be stored under the Handling bucket.
        CONSTRAINT [UQ_DowntimeReason_CodeBucket] UNIQUE ([DelayCode],[DelayBucket]),
        CONSTRAINT [CK_DowntimeReason_Bucket]   CHECK ([DelayBucket] IN ('Setup','RunTime','Handling','Downtime')),
        CONSTRAINT [CK_DowntimeReason_Status]   CHECK ([Status] IN ('Active','Inactive')),
        CONSTRAINT [CK_DowntimeReason_Buffer]   CHECK ([DelayBufferMin] >= 0),
        -- The code prefix and the bucket must agree, or a Setup code can be
        -- filed under Downtime and silently reach the wrong event table.
        CONSTRAINT [CK_DowntimeReason_Prefix]   CHECK (
                 ([DelayBucket] = 'Setup'    AND [DelayCode] LIKE 'SET[0-9][0-9]')
              OR ([DelayBucket] = 'RunTime'  AND [DelayCode] LIKE 'RUN[0-9][0-9]')
              OR ([DelayBucket] = 'Handling' AND [DelayCode] LIKE 'HDL[0-9][0-9]')
              OR ([DelayBucket] = 'Downtime' AND [DelayCode] LIKE 'DWN[0-9][0-9]')),
        -- SupervisorOverride is a Downtime-only column on the sheet.
        CONSTRAINT [CK_DowntimeReason_Override] CHECK ([DelayBucket] = 'Downtime' OR [SupervisorOverride] IS NULL)
    );
    PRINT 'Created table: DowntimeReason';
END
ELSE
    PRINT 'Table already exists: DowntimeReason';
GO

-- Seed: 72 rows. 36 existing codes the client marked as applying (yellow),
-- then 36 new ones (green) with codes minted from the next free number in each
-- bucket -- SET29+, RUN15+, HDL18+, DWN37+ -- and IsProposedCode = 1.
IF NOT EXISTS (SELECT 1 FROM [dbo].[DowntimeReason])
BEGIN
    INSERT INTO [dbo].[DowntimeReason]
        ([DelayBucket],[DelayCode],[Description],[IsNonprodTime],[Status],[DelayBufferMin],[SupervisorOverride],[IsProposedCode])
    VALUES
    -- ---- EXISTING, APPLIES (yellow) : Setup, 8 -------------------------------
      ('Setup','SET10','QC / Process Monitor Quality',                       0,'Active',  0,NULL,0)
    , ('Setup','SET11','Prior Shift unaccountable',                          0,'Active',  0,NULL,0)
    , ('Setup','SET12','Operator Training',                                  0,'Active',  0,NULL,0)
    , ('Setup','SET19','Computer problems',                                  0,'Inactive',0,NULL,0)
    , ('Setup','SET21','Replace Banding Material',                           0,'Active',  0,NULL,0)
    , ('Setup','SET23','Other',                                              0,'Inactive',0,NULL,0)
    , ('Setup','SET24','Machine Demonstration',                              0,'Active',  0,NULL,0)
    , ('Setup','SET28','Active Inspection',                                  0,'Active',  0,NULL,0)
    -- ---- EXISTING, APPLIES (yellow) : Run Time, 6 ----------------------------
    , ('RunTime','RUN04','Rough or Cracked Edges',                           0,'Active',  0,NULL,0)
    , ('RunTime','RUN05','Shape Problems',                                   0,'Active',  0,NULL,0)
    , ('RunTime','RUN06','Operator Training',                                0,'Active',  0,NULL,0)
    , ('RunTime','RUN12','Other',                                            0,'Inactive',0,NULL,0)
    , ('RunTime','RUN13','Active Inspection',                                0,'Active',  0,NULL,0)
    , ('RunTime','RUN14','Machine Demonstration',                            0,'Active',  0,NULL,0)
    -- ---- EXISTING, APPLIES (yellow) : Handling, 6 ----------------------------
    , ('Handling','HDL07','Operator Training',                               0,'Active',  0,NULL,0)
    , ('Handling','HDL11','Replace Banding Material',                        0,'Active',  0,NULL,0)
    , ('Handling','HDL14','Edge Damage from Width Changes',                   0,'Active',  0,NULL,0)
    , ('Handling','HDL15','Other',                                           0,'Inactive',0,NULL,0)
    , ('Handling','HDL16','Machine Demonstration',                           0,'Active',  0,NULL,0)
    , ('Handling','HDL17','Active Inspection',                               0,'Active',  0,NULL,0)
    -- ---- EXISTING, APPLIES (yellow) : Downtime, 16 ---------------------------
    -- DWN29 is the blank-Nonprod row the nullable column exists for.
    , ('Downtime','DWN01','unscheduled maintenance',                         1,'Active',  0,1,0)
    , ('Downtime','DWN06','Scheduled w/o Man Power',                          1,'Active',  0,1,0)
    , ('Downtime','DWN07','Fire Drill',                                       1,'Active',  0,1,0)
    , ('Downtime','DWN08','Schedule/Unschedule Meeting',                      1,'Active',  0,1,0)
    , ('Downtime','DWN09','Weather Storm',                                    1,'Active',  0,1,0)
    , ('Downtime','DWN10','Computer Problem',                                 1,'Active',  0,1,0)
    , ('Downtime','DWN13','Technical Monitoring',                             1,'Active',  0,1,0)
    , ('Downtime','DWN14','Process Monitoring',                               1,'Active',  0,1,0)
    , ('Downtime','DWN15','Power Outage',                                     1,'Active',  0,1,0)
    , ('Downtime','DWN17','Scheduled Maintenance',                            1,'Active',  0,1,0)
    , ('Downtime','DWN18','Maintenance Dept PM',                              1,'Active',  0,1,0)
    , ('Downtime','DWN24','Toolbox\Shapeup',                                  1,'Active',  0,1,0)
    , ('Downtime','DWN25','IT Maintenance',                                   1,'Active',  0,1,0)
    , ('Downtime','DWN29','Other',                                         NULL,'Active',  0,0,0)
    , ('Downtime','DWN32','Machine Demonstration',                            1,'Active',  0,1,0)
    , ('Downtime','DWN33','Operators Transferred To Conveyor',                1,'Active',  0,1,0)
    -- ---- NEW (green) : Setup, 13 --------------------------------------------
    , ('Setup','SET29','Wire Break',                                          0,'Active',  0,NULL,1)
    , ('Setup','SET30','Trouble Threading The Line',                          0,'Active',  0,NULL,1)
    , ('Setup','SET31','Change Straightener Rolls',                           0,'Active',  0,NULL,1)
    , ('Setup','SET32','Change Dies',                                         0,'Active',  0,NULL,1)
    , ('Setup','SET33','Change Edger Rolls',                                  0,'Active',  0,NULL,1)
    , ('Setup','SET34','Rewind Bundle',                                       1,'Active',  0,NULL,1)
    , ('Setup','SET35','Cannot Find Bundle/Spool, Not Correct Bundle/Spool, Searching For Bundle/Spool',
                                                                             0,'Active',  0,NULL,1)
    , ('Setup','SET36','Searching For Next bundle/Spool',                     1,'Active',  0,NULL,1)
    , ('Setup','SET37','Digging Out Next Bundle/Spool',                       1,'Active',  0,NULL,1)
    , ('Setup','SET38','Refill Draw Lube',                                    0,'Active',  0,NULL,1)
    , ('Setup','SET39','Cobble',                                              0,'Active',  0,NULL,1)
    , ('Setup','SET40','Tangle',                                              0,'Active',  0,NULL,1)
    , ('Setup','SET41','Wire Break Due to Bad Weld',                          0,'Active',  0,NULL,1)
    -- ---- NEW (green) : Run Time, 6 ------------------------------------------
    , ('RunTime','RUN15','Wire Break',                                        0,'Active',  0,NULL,1)
    , ('RunTime','RUN16','Traverse Problems',                                 0,'Active',  0,NULL,1)
    , ('RunTime','RUN17','Cobble',                                            0,'Active',  0,NULL,1)
    , ('RunTime','RUN18','Tangle',                                            0,'Active',  0,NULL,1)
    , ('RunTime','RUN19','Refill Draw Lube',                                  0,'Active',  0,NULL,1)
    , ('RunTime','RUN20','Wire Break Due to Bad Weld',                        0,'Active',  0,NULL,1)
    -- ---- NEW (green) : Handling, 8 ------------------------------------------
    -- HDL24 "Rewind Bundle" is Nonprod = No while SET34, the same words under
    -- Setup, is Yes. The attribute is per (bucket, reason), never per reason.
    , ('Handling','HDL18','Wire Break',                                       0,'Active',  0,NULL,1)
    , ('Handling','HDL19','Trouble Threading The Line',                       0,'Active',  0,NULL,1)
    , ('Handling','HDL20','Change Straightener Rolls',                        0,'Active',  0,NULL,1)
    , ('Handling','HDL21','Change Dies',                                      0,'Active',  0,NULL,1)
    , ('Handling','HDL22','Change Edger Rolls',                               0,'Active',  0,NULL,1)
    , ('Handling','HDL23','Wire Break Due to Bad Weld',                       0,'Active',  0,NULL,1)
    , ('Handling','HDL24','Rewind Bundle',                                    0,'Active',  0,NULL,1)
    , ('Handling','HDL25','Cleaning Scrap From Line',                         0,'Active',  0,NULL,1)
    -- ---- NEW (green) : Downtime, 9 ------------------------------------------
    , ('Downtime','DWN37','Wire Break',                                       0,'Active',  0,0,1)
    , ('Downtime','DWN38','Trouble Threading The Line',                       0,'Active',  0,0,1)
    , ('Downtime','DWN39','Change Straightener Rolls',                        0,'Active',  0,1,1)
    , ('Downtime','DWN40','Change Dies',                                      0,'Active',  0,1,1)
    , ('Downtime','DWN41','Change Edger Rolls',                               0,'Active',  0,1,1)
    , ('Downtime','DWN42','Waiting for Spool From Previous Operation',        1,'Active',  0,0,1)
    , ('Downtime','DWN43','Searching For Next bundle/Spool',                  1,'Active',  0,0,1)
    , ('Downtime','DWN44','Refill Draw Lube',                                 0,'Active',  0,0,1)
    , ('Downtime','DWN45','Digging Out Next Bundle/Spool',                    1,'Active',  0,0,1);

    PRINT 'Seeded: DowntimeReason (72 rows -- 36 existing/applies, 36 new/proposed)';
END
ELSE
    PRINT 'DowntimeReason already seeded -- skipped';
GO


-- ---------------------------------------------------------------------------
-- WipRejectionReason
-- The WIP rejection vocabulary for the flattening lines.
--
-- THE CLIENT'S SHEET HAS NO GROUPING AT ALL -- it is a flat list of 96 rows,
-- 72 of them in scope. But WipRejection.RejectionGroup is NOT NULL under
-- CK_WipRejection_Group (SurfaceQuality | Dimensional | WeldQuality | Material
-- | Process). So EVERY RejectionGroup value below is OURS, not the client's,
-- and every one is [PROPOSED]. That CHECK is dropped from WipRejection in
-- 05_QualityOutput; the group now lives here and the FK enforces the pair.
--
-- ReasonCode IS A MINTED SHORT CODE, not the client's prose, for two reasons:
-- WipRejection.RejectionReason is VARCHAR(50) and the longest client string is
-- 56 characters ("Wire Brk Due To Holes, Laminations, Blisters, Inclusions"),
-- and a stable code survives the client rewording a label. Description holds
-- the prose verbatim. WREJ001-008 are the 8 new reasons, in sheet order;
-- WREJ009-072 are the 64 existing reasons the client marked as applying, in
-- the sheet's alphabetical order.
--
-- NO THREADING REASON EXISTS, and answer 4 of the mail requires threading to
-- be recorded as a WIPREJ/scrap. Owed back to the client -- do not invent one.
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WipRejectionReason]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[WipRejectionReason] (
        [Id]              INT          NOT NULL IDENTITY(1,1),
        [ReasonCode]      VARCHAR(20)  NOT NULL,            -- WREJ###, ours -- see header note
        [Description]     VARCHAR(120) NOT NULL,            -- client wording, VERBATIM (typos included)
        [RejectionGroup]  VARCHAR(30)  NOT NULL,            -- OURS, [PROPOSED] -- the sheet supplies no groups
        [IsProposedGroup] BIT          NOT NULL CONSTRAINT [DF_WipRejReason_PropGroup] DEFAULT (1),
        [IsNewForFlatWire] BIT         NOT NULL CONSTRAINT [DF_WipRejReason_New]       DEFAULT (0),
        [IsActive]        BIT          NOT NULL CONSTRAINT [DF_WipRejReason_IsActive]  DEFAULT (1),

        CONSTRAINT [PK_WipRejectionReason]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_WipRejectionReason_Code]   UNIQUE ([ReasonCode]),
        -- Redundant given UQ_..._Code, and deliberately so: it is the FK target
        -- that lets WipRejection constrain (RejectionReason, RejectionGroup) as
        -- a PAIR. WipRejection denormalises the group onto the event row, and
        -- without this the two copies drift the first time a group is
        -- reassigned here.
        CONSTRAINT [UQ_WipRejectionReason_CodeGroup] UNIQUE ([ReasonCode],[RejectionGroup]),
        CONSTRAINT [CK_WipRejectionReason_Group]  CHECK ([RejectionGroup] IN ('SurfaceQuality','Dimensional','WeldQuality','Material','Process'))
    );
    PRINT 'Created table: WipRejectionReason';
END
ELSE
    PRINT 'Table already exists: WipRejectionReason';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[WipRejectionReason])
BEGIN
    INSERT INTO [dbo].[WipRejectionReason]
        ([ReasonCode],[Description],[RejectionGroup],[IsNewForFlatWire])
    VALUES
    -- ---- NEW (green), 8 -----------------------------------------------------
      ('WREJ001','Cobble',                                              'Process',       1)
    , ('WREJ002','Tangle',                                              'Process',       1)
    , ('WREJ003','Underproduced / Under Weight',                        'Dimensional',   1)
    , ('WREJ004','Wire Brk / Pull Apart',                               'Process',       1)
    , ('WREJ005','Wire Brk Due To Tangle',                              'Process',       1)
    , ('WREJ006','Wrong Bundle / Spool',                                'Material',      1)
    , ('WREJ007','Wrong Incoming Diameter',                             'Dimensional',   1)
    , ('WREJ008','Wrong Temper',                                        'Material',      1)
    -- ---- EXISTING, APPLIES (yellow), 64 ------------------------------------
    -- "wavy ege" is the client's typo and is preserved.
    , ('WREJ009','Bad Shape (wavy ege or buckle)',                       'Dimensional',   0)
    , ('WREJ010','Broken Bands',                                        'Process',       0)
    , ('WREJ011','Broken Welds',                                        'WeldQuality',   0)
    , ('WREJ012','Burr, Rolled Edges',                                  'SurfaceQuality',0)
    , ('WREJ013','Camber',                                              'Dimensional',   0)
    , ('WREJ014','Chatter',                                             'SurfaceQuality',0)
    , ('WREJ015','Collapsed ID',                                        'Dimensional',   0)
    , ('WREJ016','Crossbreaks',                                         'SurfaceQuality',0)
    , ('WREJ017','Cutter Mark',                                         'SurfaceQuality',0)
    , ('WREJ018','Damaged Edges',                                       'SurfaceQuality',0)
    , ('WREJ019','Damaged Packing',                                     'Process',       0)
    , ('WREJ020','Dents',                                               'SurfaceQuality',0)
    , ('WREJ021','Forced Recalculation (No Reason Assigned)',            'Process',       0)
    , ('WREJ022','Gauge Varies',                                        'Dimensional',   0)
    , ('WREJ023','Grain',                                               'Material',      0)
    , ('WREJ024','Heads and Tails',                                     'Process',       0)
    , ('WREJ025','Herringbone',                                         'SurfaceQuality',0)
    , ('WREJ026','ID Damage',                                           'SurfaceQuality',0)
    , ('WREJ027','Incorrect Buildup / Plan Not Followed',               'Process',       0)
    , ('WREJ028','Live Scratches',                                      'SurfaceQuality',0)
    , ('WREJ029','Loaded Wrong',                                        'Process',       0)
    , ('WREJ030','Loose Bands',                                         'Process',       0)
    , ('WREJ031','Loosewound Coil',                                     'Process',       0)
    , ('WREJ032','Machine / IT Problem',                                'Process',       0)
    , ('WREJ033','No Appointment',                                      'Process',       0)
    , ('WREJ034','No Bands',                                            'Process',       0)
    , ('WREJ035','No Packing',                                          'Process',       0)
    , ('WREJ036','No Paperwork',                                        'Process',       0)
    , ('WREJ037','OD Damage',                                           'SurfaceQuality',0)
    , ('WREJ038','Off Weight',                                          'Dimensional',   0)
    , ('WREJ039','Oil Stain, Smut',                                     'SurfaceQuality',0)
    , ('WREJ040','Order Cancelation / For acct. Purposes',              'Process',       0)
    , ('WREJ041','Other',                                               'Process',       0)
    , ('WREJ042','OVERPRODUCED ORDER',                                  'Process',       0)
    , ('WREJ043','Oxidation, Magnesium Stain',                          'SurfaceQuality',0)
    , ('WREJ044','Plan Required Head Scrap',                            'Process',       0)
    , ('WREJ045','Plan Required Tail Scrap',                            'Process',       0)
    , ('WREJ046','Planned Excess Tail Scrap',                           'Process',       0)
    , ('WREJ047','Roll Mark',                                           'SurfaceQuality',0)
    , ('WREJ048','Rolled-in Scratches',                                 'SurfaceQuality',0)
    , ('WREJ049','Rough or Cracked Edges',                              'SurfaceQuality',0)
    , ('WREJ050','SCRAP BALANCE',                                       'Process',       0)
    , ('WREJ051','Shipping Delay',                                      'Process',       0)
    , ('WREJ052','Sliver, Holes, Inclusion',                            'Material',      0)
    , ('WREJ053','Telescoped',                                          'Dimensional',   0)
    , ('WREJ054','Telescoped, Oscillated Coil',                         'Dimensional',   0)
    , ('WREJ055','Too Many Welds',                                      'WeldQuality',   0)
    , ('WREJ056','Traffic Marks',                                       'SurfaceQuality',0)
    , ('WREJ057','Twist',                                               'Dimensional',   0)
    , ('WREJ058','Water Stain',                                         'SurfaceQuality',0)
    , ('WREJ059','Water Stain in Warranty / Vendor Issue',              'SurfaceQuality',0)
    , ('WREJ060','Wet At Receiving',                                    'Process',       0)
    , ('WREJ061','Width Varies',                                        'Dimensional',   0)
    , ('WREJ062','Wire Brk Due To Edge Cracks',                         'Material',      0)
    , ('WREJ063','Wire Brk Due To Holes, Laminations, Blisters, Inclusions','Material',   0)
    , ('WREJ064','Wire Brk Due To Machine Problem',                     'Process',       0)
    , ('WREJ065','Wire Brk Due To Shape',                               'Dimensional',   0)
    , ('WREJ066','Wrong Alloy',                                         'Material',      0)
    , ('WREJ067','Wrong Banding',                                       'Process',       0)
    , ('WREJ068','Wrong Gauge',                                         'Dimensional',   0)
    , ('WREJ069','Wrong ID',                                            'Dimensional',   0)
    , ('WREJ070','Wrong OD',                                            'Dimensional',   0)
    , ('WREJ071','Wrong Skid Size',                                     'Process',       0)
    , ('WREJ072','Wrong Width',                                         'Dimensional',   0);

    PRINT 'Seeded: WipRejectionReason (72 rows -- 64 existing/applies, 8 new; ALL groups proposed)';
END
ELSE
    PRINT 'WipRejectionReason already seeded -- skipped';
GO


-- ---------------------------------------------------------------------------
-- ItInhibitReason
-- Why the ITInhibit tag is set. See [PLC 8.0] for the mechanism.
--
-- THE CLIENT'S EIGHT AND THE SPECIFICATION'S FIVE SHARE EXACTLY ONE, and that
-- is why the Source column exists. [PLC 8.2] lists five set conditions; the
-- client's sheet lists eight; the only overlap is "no coil or rod is checked
-- in". The specification's other four are NOT loose prose -- they are FR-008 /
-- FR-009 with alternate flows ALT002-ALT005 / DAT009 and FIVE P1 test cases,
-- TC-011 to TC-015. Nobody has said they are superseded.
--
-- So all twelve are seeded, and the four spec-only conditions are seeded
-- IsActive = 0: present and traceable, evaluated by nothing, pending a client
-- answer. That keeps the union visible without deciding it either way.
-- Dropping them would silently orphan two FRs and five P1 test cases;
-- activating them would decide a question the client has not been asked.
--
-- ALSO NOT MODELLED, and on BOTH real screenshots the client attached: a
-- "Call Supervisor" action on the inhibit dialog. It is in no requirement.
--
-- ITINH004 "No Qualified Operators Are Logged In" CANNOT BE EVALUATED BY
-- ANYTHING THAT EXISTS. It presumes the Leadman / Operator / Helper roles and
-- the qualification matrix of the 23 Jul call's C10; Security section 8 has six
-- roles, neither Leadman nor Helper, and no matrix at all.
--
-- ITINH007 "Supervisor Monitor" SURVIVES AN ANSWER THAT REMOVES IT. Answer 9
-- of this mail is a flat "No" to a dedicated Supervisor Monitor, superseding
-- C13's softer "desired but not required". The client's sheet still marks this
-- reason as applying, and one screenshot shows "Supervisor monitoring" live.
-- A screen and "a supervisor is presently monitoring" are different things;
-- which one sets this is owed back.
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItInhibitReason]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[ItInhibitReason] (
        [Id]               INT          NOT NULL IDENTITY(1,1),
        [ReasonCode]       VARCHAR(20)  NOT NULL,           -- ITINH###, ours
        [Description]      VARCHAR(200) NOT NULL,           -- client / specification wording, verbatim
        [Source]           VARCHAR(10)  NOT NULL,           -- Client | PLC-8.2
        [IsNewForFlatWire] BIT          NOT NULL CONSTRAINT [DF_ItInhibitReason_New]      DEFAULT (0),
        -- 0 on the four PLC-8.2-only conditions: seeded for traceability,
        -- evaluated by nothing until the client confirms them.
        [IsActive]         BIT          NOT NULL CONSTRAINT [DF_ItInhibitReason_IsActive] DEFAULT (1),

        CONSTRAINT [PK_ItInhibitReason]       PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_ItInhibitReason_Code]  UNIQUE ([ReasonCode]),
        CONSTRAINT [CK_ItInhibitReason_Source] CHECK ([Source] IN ('Client','PLC-8.2'))
    );
    PRINT 'Created table: ItInhibitReason';
END
ELSE
    PRINT 'Table already exists: ItInhibitReason';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[ItInhibitReason])
BEGIN
    INSERT INTO [dbo].[ItInhibitReason]
        ([ReasonCode],[Description],[Source],[IsNewForFlatWire],[IsActive])
    VALUES
    -- ---- CLIENT SHEET, 8 (sheet order; 002 and 003 are the green/new rows) --
      ('ITINH001','Correct Pass Schedule Not Loaded. Mismatched OPC and Pass Schedule Values','Client',0,1)
    , ('ITINH002','Next Bundle Not Welded',                                  'Client', 1,1)
    , ('ITINH003','No Bundle/Spool is Checked In',                           'Client', 1,1)
    , ('ITINH004','No Qualified Operators Are Logged In',                    'Client', 0,1)
    , ('ITINH005','Pass Schedule is Not Accepted',                           'Client', 0,1)
    , ('ITINH006','SPC is Not Done',                                         'Client', 0,1)
    , ('ITINH007','Supervisor Monitor',                                      'Client', 0,1)
    , ('ITINH008','System Air Pressure Low',                                 'Client', 0,1)
    -- ---- [PLC 8.2] ONLY, 4 : INACTIVE pending a client answer --------------
    -- Condition 1 of the five is covered by ITINH003 above. These are the
    -- other four, and they carry TC-012 to TC-015.
    , ('ITINH009','No active material-tracking identifier exists',           'PLC-8.2',0,0)
    , ('ITINH010','Feet data from the machine is unavailable',               'PLC-8.2',0,0)
    , ('ITINH011','Feet data from the machine is invalid',                   'PLC-8.2',0,0)
    , ('ITINH012','Two or more consecutive data recordings are missing',     'PLC-8.2',0,0);

    PRINT 'Seeded: ItInhibitReason (12 rows -- 8 client/active, 4 PLC-8.2-only/inactive)';
END
ELSE
    PRINT 'ItInhibitReason already seeded -- skipped';
GO


-- ============================================================
-- MACHINE SETUP APPLICATION -- Setup/Handling Times and Material Loss
-- Added Sep-4-2026.  Five tables, from Tim O'Brien's field sets of
-- 31 Aug 2026 (delivered as screenshot grids; see the 31 Aug client
-- mail analysis sections 3.2 and 3.4).
--
-- THE CLIENT'S INSTRUCTION IS THE DESIGN: "Please include the fields
-- pictured below, in the order pictured, all others will be removed",
-- said of each tab SEPARATELY FOR FL1, FL2 AND FL3 -- "this will be
-- different for FL1 & FL2/FL3 as each machine has its own capabilities."
--
-- WHY NOT THE LEGACY SHAPE.  united_db.dbo.Slitters_Standards (32 float
-- columns) and united_db.dbo.machine_mill_material_loss (36 float columns)
-- are FORM-SHAPED: one column per field, order encoded in COLUMN ORDER.
-- Flat Wire needs 56 setup elements and 16 loss elements across three
-- lines, the client has already revised both lists twice, and two of the
-- FL3 rows are still disputed -- so membership AND order are DATA here,
-- not DDL.  united_db.dbo.MaterialLossStandardMapping is UA's own move in
-- the same direction (StandardComponent varchar + MaterialLoss decimal).
--
-- CATALOGUE vs VALUES, and why they are separate tables.  The three
-- catalogues are CLIENT-SUPPLIED PRODUCTION REFERENCE DATA and are seeded
-- inline below, like DowntimeReason.  The two *Standard tables hold the
-- NUMBERS, which do not exist yet: they are the Naj/Bob/Tim standards
-- spreadsheet, FW-003's open external dependency.  Keeping them apart is
-- what makes "the DDL seeds the catalogue and never the values" true
-- STRUCTURALLY -- share one table and RunAll would insert rows that get
-- UPDATEd with real standards, after which the IF NOT EXISTS seed guard
-- stops firing and a teardown/rebuild silently destroys them.
--
-- OI-110 IS NOT CLOSED BY THIS.  Which database the Machine Setup tabs
-- write to is still unanswered, and the evidence actually points at
-- united_db: every other tab persists to a united_db satellite FK'd to
-- united_db.dbo.machines, and the withdrawn WIP-station seed (FW-241)
-- says the template tabs "live in satellite tables ... and are separate
-- work".  FlatWireDB is the D-02/D-31 decision, and it costs three things:
--   1. NO FK to machines is possible (cross-database).  The app must map
--      machines.machine_idx 125/126/127 -> FL1/FL2/FL3 ITSELF, and nothing
--      here enforces it -- a wrong mapping writes one line's standards
--      onto another and no constraint will catch it.
--   2. The legacy app must reach cross-database to read and write these.
--   3. The History tab reads united_db.dbo.AuditTrail, NOT these tables,
--      so the app must keep writing AuditTrail or that tab shows nothing.
-- ============================================================

-- ------------------------------------------------------------
-- SetupHandlingTimeGroup
-- The seven column headings of the STANDARD SPECIFICATIONS page, in the
-- client's left-to-right order.  Four are RENAMED from the Slitter
-- template this tab was copied from:
--   S1  "Setup Before 1st SPC"  -> "Setup Before Run"
--   H1A "Handling Before SPC"   -> "Handling Before Reduction"
--   R   "Slitter Run"           -> "Flattening Line Run"
--   H2  "...From Rewind"        -> "...From Takeup"
-- H1AA, H1B and S2 keep their wording.
--
-- SEVEN IS STRUCTURAL, not policed: CK_..._GroupCode admits only these
-- codes and UQ_..._GroupCode makes each unique, so an eighth group is
-- impossible without a schema change.  Same idiom as CK_Drawer_Name.
--
-- Sequence is NOT cosmetic.  The Slitter template lays these out in a
-- 3-column block; the client's Flat Wire grids lay them out in ONE row,
-- S1 H1A H1AA R H1B S2 H2.  That is "the order pictured".
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupHandlingTimeGroup]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SetupHandlingTimeGroup] (
        [Id]         INT         NOT NULL IDENTITY(1,1),
        [GroupCode]  VARCHAR(5)  NOT NULL,               -- S1 | H1A | H1AA | R | H1B | S2 | H2
        [GroupLabel] VARCHAR(60) NOT NULL,               -- longest is H1AA's at 52 chars
        [Sequence]   INT         NOT NULL,               -- 1..7, left to right as pictured
        [IsActive]   BIT         NOT NULL CONSTRAINT [DF_SetupHandlingTimeGroup_IsActive] DEFAULT (1),

        CONSTRAINT [PK_SetupHandlingTimeGroup]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SetupHandlingTimeGroup_GroupCode] UNIQUE ([GroupCode]),
        CONSTRAINT [UQ_SetupHandlingTimeGroup_Sequence]  UNIQUE ([Sequence]),
        CONSTRAINT [CK_SetupHandlingTimeGroup_GroupCode] CHECK ([GroupCode] IN ('S1','H1A','H1AA','R','H1B','S2','H2'))
    );
    PRINT 'Created table: SetupHandlingTimeGroup';
END
ELSE
    PRINT 'Table already exists: SetupHandlingTimeGroup';
GO

-- ------------------------------------------------------------
-- SetupHandlingTimeElement
-- One row per (line, group, element label) -- the client's grid, as data.
-- FL1 33 elements, FL2 29, FL3 47.
--
-- KEYED ON GROUP + LABEL, NEVER LABEL ALONE.  Three labels legitimately
-- appear in TWO groups each and are therefore two rows, not one:
--   'Load Spool: Takeup-1'  in S1 and S2
--   'Thread: Takeup-1'      in H1AA and H1B
-- A label-only unique key would reject the client's own field set.
--
-- THAT LIST WAS THREE UNTIL 10 Sep 2026. 'SPC: Takeup-2' sat in both H1AA and
-- H1B; the H1B occurrence became 'SPC: FL2-Stand 3' on the client's correction
-- below, so it now appears in H1AA only. The composite key still stands on the
-- surviving two -- do NOT narrow it to label alone.
--
-- FL3 IS NOT THE UNION OF FL1 AND FL2 and must not be generated as one.
-- It drops, per group: S1 'Rotate Payoff: TPO' and 'Load Spool: Takeup-1';
-- H1A both TPO rows; H1AA 'Thread: Takeup-1'; H1B 'Remove Spool: Takeup-1'
-- AND 'SPC: FL1-Stand 1'; S2 'Load Spool: Takeup-1'.  It adds nothing.
--
-- THE TWO DISPUTED ROWS ARE SETTLED -- Q94 legs 2 and 3, client 10 Sep 2026.
-- This block used to say they were seeded as pictured and that "a send-back is
-- what changes them". The send-back has returned, and the two turned out to have
-- ONE root cause: FL3's H1AA SPC row named FL1's TAKEUP where it should have
-- named FL1's MILL.
--
--   FL3/H1AA seq 8: 'SPC: Takeup-1' -> 'SPC: FL1-Stand 1'
--     "This is my mistake, it should have contained SPC FL1.FM1 not Takeup1."
--
--   FL3/H1B: the ABSENCE of 'SPC: FL1-Stand 1' was CORRECT all along.
--     "SPC for FL3 at FL1.FM1 under H1B is not necessary as the stop is has been
--     completed and these dimensions would not represent final gauge/width."
--     Which is also why FL1 legitimately KEEPS it in its own H1B: FL1's output
--     IS final gauge. Do not add it to FL3.
--
--   FL2/H1B and FL3/H1B seq 2: 'SPC: Takeup-2' -> 'SPC: FL2-Stand 3'
--     "FL2 and FL3 should have SPC at FL2.FM2 for H1B."
--
-- WE CHOSE THE STAND, AND IT IS OUR READING NOT HIS WORDS. "FL2.FM2" does not
-- name a stand; S3 is the final non-bypassable one and CLAUDE.md's canonical
-- checkpoint is "FM2 S3 output", so FL2-Stand 3 is applied and sent back for
-- confirmation. His labels 'SPC: FL1.FM1' / 'SPC: FL2.FM2' are NOT adopted --
-- they occur nowhere in this repository, FL1.FM1 is a PLC TAG PATH, and A12 says
-- do not reconcile component identifiers until the Speed tab lands. This table's
-- own vocabulary is FL1-Stand 1 / FL2-Stand 1..3.
--
-- REPLACE, NOT ADD, and that is the one part still open. Both H1B blocks already
-- carried an SPC at Takeup-2, so "should have SPC at FL2.FM2" could have meant
-- relocate or supplement. Relocate is applied, which keeps the FL3 counts at
-- H1AA 15 / H1B 5 and the seed total at 109. Adding instead would make FL2 30 and
-- FL3 48. Confirm before changing.
--
-- The FL3 counts (H1AA 15, H1B 5) remain the guard -- see FW-262's verification,
-- whose positive assertions were re-pointed with this change.
--
-- CK_..._MachineName admits ALL THREE LINES.  Do NOT align it with
-- CK_ToolingInventoryDie_MachineName ('FL1') or CK_TIRS_MachineName ('FL1','FL2'):
-- those drop FL3 because TOOLING is maintained for FL1/FL2 only (D-42),
-- whereas these tabs are configured per line INCLUDING FL3 -- the client
-- supplied a distinct FL3 grid.  Same equipment-vs-tooling distinction
-- CK_Drawer_MachineName already carries a warning about.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupHandlingTimeElement]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SetupHandlingTimeElement] (
        [Id]           INT         NOT NULL IDENTITY(1,1),
        [MachineName]       VARCHAR(5)  NOT NULL,             -- FL1 / FL2 / FL3
        [GroupId]      INT         NOT NULL,             -- FK -> SetupHandlingTimeGroup.Id
        [ElementLabel] VARCHAR(60) NOT NULL,             -- longest today is 27 chars; generous against revision
        [Sequence]     INT         NOT NULL,             -- order within (MachineName, GroupId), as pictured
        [IsActive]     BIT         NOT NULL CONSTRAINT [DF_SetupHandlingTimeElement_IsActive] DEFAULT (1),

        CONSTRAINT [PK_SetupHandlingTimeElement]                PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SetupHandlingTimeElement_LineGroupLabel] UNIQUE ([MachineName], [GroupId], [ElementLabel]),
        CONSTRAINT [UQ_SetupHandlingTimeElement_LineGroupSeq]   UNIQUE ([MachineName], [GroupId], [Sequence]),
        CONSTRAINT [CK_SetupHandlingTimeElement_MachineName]         CHECK ([MachineName] IN ('FL1','FL2','FL3'))
    );
    PRINT 'Created table: SetupHandlingTimeElement';
END
ELSE
    PRINT 'Table already exists: SetupHandlingTimeElement';
GO

-- ------------------------------------------------------------
-- MaterialLossElement
-- One row per (line, element label) for the MATERIAL LOSS tab.
-- FL1 7 elements, FL2 9, FL3 12.
--
-- THE UNIT IS FEET, not minutes and not weight -- the FL1 grid's own
-- footer reads "(Values in footage (')", and FW-003's acceptance criteria
-- have carried "scrap in footage, not weight" since the Mill template was
-- chosen as the source.
--
-- NO CREW SIZE HERE.  The STANDARD SPECIFICATIONS page has a Crew Size
-- selector; the MATERIAL LOSS page has none, on the Mill template and on
-- all three client grids.  Scrap footage is a property of the event.
--
-- 16 DISTINCT LABELS ACROSS 28 ROWS, and the two Pass Change wordings are
-- deliberately BOTH kept: FL1 reads "(Alloy, Rod Dia., Mech Properties,
-- Output Size)" where FL2 and FL3 read "(Alloy, Input Ga/Width, ...)".
-- FL1 is rod-fed and FL2 is spool-fed, so the difference is real.
--
-- KNOWN CLIENT INCONSISTENCY, seeded verbatim: the same FL1 grid says
-- "Threading Drawblock #1" but "Die Change Drawingblock #1".  The repo's
-- canonical term is DB1/DB2.  Drawer's own comment block records four
-- spellings across four surfaces and says DO NOT reconcile them until the
-- Speed tab lands (action A12, still open) -- so this is not reconciled.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialLossElement]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[MaterialLossElement] (
        [Id]           INT         NOT NULL IDENTITY(1,1),
        [MachineName]       VARCHAR(5)  NOT NULL,             -- FL1 / FL2 / FL3
        [ElementLabel] VARCHAR(80) NOT NULL,             -- 80, not 60: the Pass Change label is 65 chars
        [Sequence]     INT         NOT NULL,             -- order within MachineName, as pictured
        [IsActive]     BIT         NOT NULL CONSTRAINT [DF_MaterialLossElement_IsActive] DEFAULT (1),

        CONSTRAINT [PK_MaterialLossElement]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_MaterialLossElement_LineLabel] UNIQUE ([MachineName], [ElementLabel]),
        CONSTRAINT [UQ_MaterialLossElement_LineSeq]   UNIQUE ([MachineName], [Sequence]),
        CONSTRAINT [CK_MaterialLossElement_MachineName]    CHECK ([MachineName] IN ('FL1','FL2','FL3'))
    );
    PRINT 'Created table: MaterialLossElement';
END
ELSE
    PRINT 'Table already exists: MaterialLossElement';
GO

-- ------------------------------------------------------------
-- SetupHandlingTimeStandard
-- The standard time for one element at one crew size, IN MINUTES -- the
-- page's own note is "All Standard time should be entered in minutes".
--
-- CREATED EMPTY, DELIBERATELY.  These numbers are the Naj/Bob/Tim
-- standards spreadsheet, recorded on FW-003 as an unfinished EXTERNAL
-- dependency.  Do not seed placeholder zeros: the client's grids show 0 in
-- every cell because they are blank templates, and a zero here is
-- indistinguishable from a real measured standard of zero.
--
-- CREW SIZE IS A ROW DIMENSION, verified against the legacy app rather
-- than assumed: united_db.dbo.Slitters_Standards holds one row per
-- (Machine_Idx, Crew_Size), Machine_GetSetupHandlingTimeForSlitter filters
-- on BOTH, and the dropdown AutoPostBacks to re-read a different row.
--
-- WHY A RANGE CHECK AND NOT A LIST.  The crew-size vocabulary is DATA in
-- the legacy system, not an enumeration: it comes from
-- united_db.dbo.lookups where lookup_category_id = 4061
-- (eLookUpcategory.CrewSizeForMachineStandards), and the app PARSES THE
-- INTEGER OUT OF the description varchar column.  Those rows are NOT in
-- source control -- they exist only in the live database.
--
-- MEASURED on DEV00164-001, 4 Sep 2026: the category holds exactly THREE
-- active rows -- 'Crew Size 1' / '2' / '3', descriptions '1' / '2' / '3'
-- -- and Slitters_Standards carries exactly those three across six
-- machines (18 rows, 6 per crew size).  So the vocabulary today is 1..3.
--
-- The CHECK stays a RANGE anyway, and that is deliberate: 1..9 admits
-- 1..3 now and survives an administrator adding a fourth row to that
-- lookup, which a hardcoded IN (1,2,3) would reject at save time.
--
-- [PROPOSED] -- what is measured is what the SLITTERS use; whether a
-- flattening line crew is sized the same way is Q94, still open.  Note
-- also the legacy trap: int.TryParse with a fallback of 1 means a blank
-- or non-numeric description SILENTLY becomes crew size 1.  All three
-- rows parse cleanly today.
--
-- DECIMAL, NOT THE LEGACY FLOAT.  No FLOAT or REAL column exists anywhere
-- in FlatWireDB, and a binary float cannot hold a standard time exactly --
-- which matters when 47 of them are summed into one FL3 setup total.
-- DECIMAL(8,3) matches legacy slitter_standard_setup_time_S1.modified_s1
-- and the tab's own MaxLength="8" input.
--
-- ROWVERSION is the fix for a real legacy defect: Slitters_Standards has
-- NO primary key and NO index, and its save proc guards uniqueness with a
-- racy IF NOT EXISTS, so two supervisors saving at once can duplicate a
-- row or silently overwrite each other.  Do not port that.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupHandlingTimeStandard]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SetupHandlingTimeStandard] (
        [Id]              INT            NOT NULL IDENTITY(1,1),
        [ElementId]       INT            NOT NULL,       -- FK -> SetupHandlingTimeElement.Id
        [CrewSize]        TINYINT        NOT NULL,       -- [PROPOSED] vocabulary: united_db.dbo.lookups category 4061
        [StandardMinutes] DECIMAL(8,3)   NOT NULL,       -- minutes, per the page's own note

        -- ---- audit ---------------------------------------------------------
        [CreatedBy]       VARCHAR(50)    NOT NULL,
        [CreatedAt]       DATETIMEOFFSET NOT NULL CONSTRAINT [DF_SetupHandlingTimeStandard_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [ModifiedBy]      VARCHAR(50)    NULL,
        [ModifiedAt]      DATETIMEOFFSET NULL,
        [RowVersion]      ROWVERSION     NOT NULL,       -- concurrency token; the legacy table has none

        CONSTRAINT [PK_SetupHandlingTimeStandard]             PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SetupHandlingTimeStandard_ElementCrew] UNIQUE ([ElementId], [CrewSize]),
        CONSTRAINT [CK_SetupHandlingTimeStandard_CrewSize]    CHECK ([CrewSize] BETWEEN 1 AND 9),
        CONSTRAINT [CK_SetupHandlingTimeStandard_Minutes]     CHECK ([StandardMinutes] >= 0)
    );
    PRINT 'Created table: SetupHandlingTimeStandard';
END
ELSE
    PRINT 'Table already exists: SetupHandlingTimeStandard';
GO

-- ------------------------------------------------------------
-- MaterialLossStandard
-- The standard scrap footage for one material-loss element.  One row per
-- element -- no crew size, see MaterialLossElement.
--
-- CREATED EMPTY, and this one has a second reason beyond the standards
-- spreadsheet: G82 records that the threading footage specifically is
-- pending "the actual footage for these events through testing", and the
-- client's grids arrived with EVERY value blank.  Do not invent a quantity.
--
-- 1:1 WITH MaterialLossElement AND STILL A SEPARATE TABLE -- see the
-- catalogue-vs-values note in this section's header.  The short version:
-- the catalogue is DDL-seeded, these values are typed by a human, and
-- mixing the two would let a teardown/rebuild destroy real standards.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialLossStandard]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[MaterialLossStandard] (
        [Id]             INT            NOT NULL IDENTITY(1,1),
        [ElementId]      INT            NOT NULL,        -- FK -> MaterialLossElement.Id
        [StandardLossFt] DECIMAL(10,2)  NOT NULL,        -- FEET, per the FL1 grid footer

        -- ---- audit ---------------------------------------------------------
        [CreatedBy]      VARCHAR(50)    NOT NULL,
        [CreatedAt]      DATETIMEOFFSET NOT NULL CONSTRAINT [DF_MaterialLossStandard_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [ModifiedBy]     VARCHAR(50)    NULL,
        [ModifiedAt]     DATETIMEOFFSET NULL,
        [RowVersion]     ROWVERSION     NOT NULL,

        CONSTRAINT [PK_MaterialLossStandard]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_MaterialLossStandard_Element] UNIQUE ([ElementId]),
        CONSTRAINT [CK_MaterialLossStandard_LossFt]  CHECK ([StandardLossFt] >= 0)
    );
    PRINT 'Created table: MaterialLossStandard';
END
ELSE
    PRINT 'Table already exists: MaterialLossStandard';
GO

-- ------------------------------------------------------------
-- SEED: SetupHandlingTimeGroup, SetupHandlingTimeElement,
--       MaterialLossElement
--
-- SEEDED HERE, INLINE, not in FlatWire_SampleData_Lookup.sql -- these are
-- PRODUCTION REFERENCE DATA (the client's own field sets), and a
-- production deploy runs RunAll WITHOUT the sample data.  Seeded there
-- instead, both Machine Setup tabs would come up EMPTY in production while
-- looking perfectly healthy anywhere the fixtures had been loaded.  Same
-- reasoning as DowntimeReason / WipRejectionReason / ItInhibitReason.
--
-- NO IDENTITY_INSERT and NO PINNED IDS.  Ids are irrelevant here; the
-- codes and labels are the keys.  IDENTITY_INSERT with a pinned-Id map is
-- the SAMPLE-DATA idiom (Stand.Id 1-4), needed only when another seed file
-- references the values.  The element seed below resolves GroupId by
-- JOINING ON GroupCode, so nothing depends on IDENTITY allocation.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [dbo].[SetupHandlingTimeGroup])
BEGIN
    INSERT INTO [dbo].[SetupHandlingTimeGroup] ([GroupCode],[GroupLabel],[Sequence],[IsActive])
    VALUES
      ('S1',    'Setup Before Run',                                      1, 1)
    , ('H1A',   'Handling Before Reduction',                             2, 1)
    , ('H1AA',  'Handling After Loading Payoff/Before Running Machine',  3, 1)
    , ('R',     'Flattening Line Run',                                   4, 1)
    , ('H1B',   'Handling After Running Stop',                           5, 1)
    , ('S2',    'Setup Time Between Stops',                              6, 1)
    , ('H2',    'Handling After Removing Stop From Takeup',              7, 1)
    ;

    PRINT 'Seeded: SetupHandlingTimeGroup (7 rows)';
END
ELSE
    PRINT 'SetupHandlingTimeGroup already seeded -- skipped';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[SetupHandlingTimeElement])
BEGIN
    -- C5-OK: SetupHandlingTimeElement.GroupId
    -- Resolved by joining the VALUES list on GroupCode against the
    -- SetupHandlingTimeGroup seed above, which runs in this same script.
    -- Not positional and not a pinned IDENTITY value, so the C5 seed-order
    -- check cannot verify it positionally -- hence this explicit marker.
    INSERT INTO [dbo].[SetupHandlingTimeElement] ([MachineName],[GroupId],[ElementLabel],[Sequence],[IsActive])
    SELECT v.[MachineName], g.[Id], v.[ElementLabel], v.[Sequence], 1
    FROM (VALUES
        -- ---- FL1 : 33 elements ----------------------------
          ('FL1', 'S1',    'Lower Payoff: VPS',            1)
        , ('FL1', 'S1',    'Raise Payoff: VPS',            2)
        , ('FL1', 'S1',    'Die Change: DB1/DB2',          3)
        , ('FL1', 'S1',    'Fill Die Lubricant: DB1/DB2',  4)
        , ('FL1', 'S1',    'Set Wire Straightener',        5)
        , ('FL1', 'S1',    'Straightener Roll Change',     6)
        , ('FL1', 'S1',    'Open Stand Rolls',             7)
        , ('FL1', 'S1',    'Close Stand Rolls',            8)
        , ('FL1', 'S1',    'Jog Capstan: DB1',             9)
        , ('FL1', 'S1',    'Jog Capstan: DB2',            10)
        , ('FL1', 'S1',    'Jog: FL1-Stand 1',            11)
        , ('FL1', 'S1',    'Load Spool: Takeup-1',        12)
        , ('FL1', 'H1A',   'Load & Prep Bundle: VPS',      1)
        , ('FL1', 'H1A',   'SPC - Payoff: VPS',            2)
        , ('FL1', 'H1A',   'Weld/Anneal Rod Ends: VPS',    3)
        , ('FL1', 'H1A',   'Thread Payoff: VPS',           4)
        , ('FL1', 'H1AA',  'Pull Point wire Rod: DB1',     1)
        , ('FL1', 'H1AA',  'Thread Capstan: DB1',          2)
        , ('FL1', 'H1AA',  'SPC: DB1',                     3)
        , ('FL1', 'H1AA',  'Pull Point wire Rod: DB2',     4)
        , ('FL1', 'H1AA',  'Thread Capstan: DB2',          5)
        , ('FL1', 'H1AA',  'SPC: DB2',                     6)
        , ('FL1', 'H1AA',  'Thread: FL1-Stand 1',          7)
        , ('FL1', 'H1AA',  'Thread: Takeup-1',             8)
        , ('FL1', 'H1AA',  'SPC: Takeup-1',                9)
        , ('FL1', 'H1AA',  'Torch Test',                  10)
        , ('FL1', 'H1AA',  'Conductivity',                11)
        , ('FL1', 'R',     'Run',                          1)
        , ('FL1', 'H1B',   'Cut and secure coil end',      1)
        , ('FL1', 'H1B',   'SPC: FL1-Stand 1',             2)
        , ('FL1', 'H1B',   'Remove Spool: Takeup-1',       3)
        , ('FL1', 'H1B',   'Thread: Takeup-1',             4)
        , ('FL1', 'S2',    'Load Spool: Takeup-1',         1)

        -- ---- FL2 : 29 elements ----------------------------
        , ('FL2', 'S1',    'Rotate Payoff: TPO',           1)
        , ('FL2', 'S1',    'Open Stand Rolls',             2)
        , ('FL2', 'S1',    'Close Stand Rolls',            3)
        , ('FL2', 'S1',    'Jog: FL2-Stand 1',             4)
        , ('FL2', 'S1',    'Jog: FL2-Stand 2',             5)
        , ('FL2', 'S1',    'Jog: FL2-Stand 3',             6)
        , ('FL2', 'S1',    'Set: Edger-1',                 7)
        , ('FL2', 'S1',    'Set: Edger-2',                 8)
        , ('FL2', 'S1',    'Open Edgers',                  9)
        , ('FL2', 'S1',    'Close Edgers',                10)
        , ('FL2', 'S1',    'Edger Roll Change',           11)
        , ('FL2', 'H1A',   'Load & Prep Spool: TPO',       1)
        , ('FL2', 'H1A',   'SPC - Payoff: TPO',            2)
        , ('FL2', 'H1AA',  'Thread: FL2-Stand 1',          1)
        , ('FL2', 'H1AA',  'Thread: FL2-Stand 2',          2)
        , ('FL2', 'H1AA',  'Thread: FL2-Stand 3',          3)
        , ('FL2', 'H1AA',  'Thread Takeup: Takeup-2',      4)
        , ('FL2', 'H1AA',  'SPC: Takeup-2',                5)
        , ('FL2', 'H1AA',  'Torch Test',                   6)
        , ('FL2', 'H1AA',  'Conductivity',                 7)
        , ('FL2', 'R',     'Run',                          1)
        , ('FL2', 'H1B',   'Cut and secure coil end',      1)
        , ('FL2', 'H1B',   'SPC: FL2-Stand 3',             2)
        , ('FL2', 'H1B',   'Band ID/OD x 4',               3)
        , ('FL2', 'H1B',   'Collapse Mandrel',             4)
        , ('FL2', 'H1B',   'Push Off Stop',                5)
        , ('FL2', 'S2',    'Expand Mandrel',               1)
        , ('FL2', 'H2',    'Stop to Skid',                 1)
        , ('FL2', 'H2',    'Band Skid',                    2)

        -- ---- FL3 : 47 elements ----------------------------
        , ('FL3', 'S1',    'Lower Payoff: VPS',            1)
        , ('FL3', 'S1',    'Raise Payoff: VPS',            2)
        , ('FL3', 'S1',    'Die Change: DB1/DB2',          3)
        , ('FL3', 'S1',    'Fill Die Lubricant: DB1/DB2',  4)
        , ('FL3', 'S1',    'Set Wire Straightener',        5)
        , ('FL3', 'S1',    'Straightener Roll Change',     6)
        , ('FL3', 'S1',    'Open Stand Rolls',             7)
        , ('FL3', 'S1',    'Close Stand Rolls',            8)
        , ('FL3', 'S1',    'Jog Capstan: DB1',             9)
        , ('FL3', 'S1',    'Jog Capstan: DB2',            10)
        , ('FL3', 'S1',    'Jog: FL1-Stand 1',            11)
        , ('FL3', 'S1',    'Jog: FL2-Stand 1',            12)
        , ('FL3', 'S1',    'Jog: FL2-Stand 2',            13)
        , ('FL3', 'S1',    'Jog: FL2-Stand 3',            14)
        , ('FL3', 'S1',    'Set: Edger-1',                15)
        , ('FL3', 'S1',    'Set: Edger-2',                16)
        , ('FL3', 'S1',    'Open Edgers',                 17)
        , ('FL3', 'S1',    'Close Edgers',                18)
        , ('FL3', 'S1',    'Edger Roll Change',           19)
        , ('FL3', 'H1A',   'Load & Prep Bundle: VPS',      1)
        , ('FL3', 'H1A',   'SPC - Payoff: VPS',            2)
        , ('FL3', 'H1A',   'Weld/Anneal Rod Ends: VPS',    3)
        , ('FL3', 'H1A',   'Thread Payoff: VPS',           4)
        , ('FL3', 'H1AA',  'Pull Point wire Rod: DB1',     1)
        , ('FL3', 'H1AA',  'Thread Capstan: DB1',          2)
        , ('FL3', 'H1AA',  'SPC: DB1',                     3)
        , ('FL3', 'H1AA',  'Pull Point wire Rod: DB2',     4)
        , ('FL3', 'H1AA',  'Thread Capstan: DB2',          5)
        , ('FL3', 'H1AA',  'SPC: DB2',                     6)
        , ('FL3', 'H1AA',  'Thread: FL1-Stand 1',          7)
        , ('FL3', 'H1AA',  'SPC: FL1-Stand 1',             8)
        , ('FL3', 'H1AA',  'Thread: FL2-Stand 1',          9)
        , ('FL3', 'H1AA',  'Thread: FL2-Stand 2',         10)
        , ('FL3', 'H1AA',  'Thread: FL2-Stand 3',         11)
        , ('FL3', 'H1AA',  'Thread Takeup: Takeup-2',     12)
        , ('FL3', 'H1AA',  'SPC: Takeup-2',               13)
        , ('FL3', 'H1AA',  'Torch Test',                  14)
        , ('FL3', 'H1AA',  'Conductivity',                15)
        , ('FL3', 'R',     'Run',                          1)
        , ('FL3', 'H1B',   'Cut and secure coil end',      1)
        , ('FL3', 'H1B',   'SPC: FL2-Stand 3',             2)
        , ('FL3', 'H1B',   'Band ID/OD x 4',               3)
        , ('FL3', 'H1B',   'Collapse Mandrel',             4)
        , ('FL3', 'H1B',   'Push Off Stop',                5)
        , ('FL3', 'S2',    'Expand Mandrel',               1)
        , ('FL3', 'H2',    'Stop to Skid',                 1)
        , ('FL3', 'H2',    'Band Skid',                    2)
    ) AS v([MachineName], [GroupCode], [ElementLabel], [Sequence])
    JOIN [dbo].[SetupHandlingTimeGroup] g ON g.[GroupCode] = v.[GroupCode];

    PRINT 'Seeded: SetupHandlingTimeElement (109 rows -- FL1 33, FL2 29, FL3 47)';
END
ELSE
    PRINT 'SetupHandlingTimeElement already seeded -- skipped';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[MaterialLossElement])
BEGIN
    INSERT INTO [dbo].[MaterialLossElement] ([MachineName],[ElementLabel],[Sequence],[IsActive])
    VALUES
      -- ---- FL1 : 7 elements ----------------------------
      ('FL1', 'Threading Drawblock #1',                                             1, 1)
    , ('FL1', 'Threading Drawblock #2',                                             2, 1)
    , ('FL1', 'Threading FL1-Stand #1',                                             3, 1)
    , ('FL1', 'Die Change Drawingblock #1',                                         4, 1)
    , ('FL1', 'Die Change Drawingblock #2',                                         5, 1)
    , ('FL1', 'Straightener Roll Change',                                           6, 1)
    , ('FL1', 'Pass Change (Alloy, Rod Dia., Mech Properties, Output Size)',        7, 1)

      -- ---- FL2 : 9 elements ----------------------------
    , ('FL2', 'OD Buildup Loss Previous Oper Furnace',                              1, 1)
    , ('FL2', 'OD Buildup Loss Previous Oper Flatten',                              2, 1)
    , ('FL2', 'OD Buildup Loss Previous Oper Other',                                3, 1)
    , ('FL2', 'Edger #1 Roll Change',                                               4, 1)
    , ('FL2', 'Edger #2 Roll Change',                                               5, 1)
    , ('FL2', 'Pass Change (Alloy, Input Ga/Width, Mech Properties, Output Size)',  6, 1)
    , ('FL2', 'Threading FL2-Stand #1',                                             7, 1)
    , ('FL2', 'Threading FL2-Stand #2',                                             8, 1)
    , ('FL2', 'Threading FL2-Stand #3',                                             9, 1)

      -- ---- FL3 : 12 elements ----------------------------
    , ('FL3', 'Threading Drawblock #1',                                             1, 1)
    , ('FL3', 'Threading Drawblock #2',                                             2, 1)
    , ('FL3', 'Threading FL1-Stand #1',                                             3, 1)
    , ('FL3', 'Die Change Drawingblock #1',                                         4, 1)
    , ('FL3', 'Die Change Drawingblock #2',                                         5, 1)
    , ('FL3', 'Straightener Roll Change',                                           6, 1)
    , ('FL3', 'Edger #1 Roll Change',                                               7, 1)
    , ('FL3', 'Edger #2 Roll Change',                                               8, 1)
    , ('FL3', 'Threading FL2-Stand #1',                                             9, 1)
    , ('FL3', 'Threading FL2-Stand #2',                                            10, 1)
    , ('FL3', 'Threading FL2-Stand #3',                                            11, 1)
    , ('FL3', 'Pass Change (Alloy, Input Ga/Width, Mech Properties, Output Size)', 12, 1)
    ;

    PRINT 'Seeded: MaterialLossElement (28 rows -- FL1 7, FL2 9, FL3 12)';
END
ELSE
    PRINT 'MaterialLossElement already seeded -- skipped';
GO
