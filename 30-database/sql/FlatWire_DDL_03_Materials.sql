-- ============================================================
-- Flat Wire Mill — DDL Script 03: Material Tables
-- Run order : 03 of 09
-- Tables    : Rod, FlatWireRun (header — placed here so SpoolProcessing
--             can reference it), SpoolProcessing, SpoolTraceability,
--             SpoolOrder, RodOrderAllocation   (6)
-- Dependencies: 01_Lookup (Spool), 02_Schedule (PassSchedule)
-- Note      : [Rod] is kept as a FlatWireDB-local master (Hybrid
--             foundation decision) so rod-alpha FKs are enforced
--             in-database; it mirrors the shared legacy `coils`
--             record populated by the Receiving module.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- Rod
-- Wire rod receiving and lifecycle tracking. Every processed
-- rod carries an alpha identifier used across all event tables.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Rod]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Rod] (
        [Id]           INT           NOT NULL IDENTITY(1,1),
        [Alpha]        VARCHAR(20)   NOT NULL,              -- e.g. R00041; unique scan key
        [Alloy]        VARCHAR(10)   NOT NULL,              -- e.g. 1100, 3003
        [Temper]       VARCHAR(10)   NOT NULL,              -- e.g. O, H14
        [DiameterIn]   DECIMAL(8,4)  NOT NULL,              -- rod wire diameter (in)
        [GrossWeightLb] DECIMAL(8,2) NOT NULL,              -- gross weight including packaging (lb)
        [NetWeightLb]  DECIMAL(8,2)  NOT NULL,              -- net aluminum weight (lb)
        [TareWeightLb] AS ([GrossWeightLb] - [NetWeightLb]) PERSISTED,  -- computed: gross − net (lb)
        [SupplierHeat] VARCHAR(50)   NULL,                  -- supplier heat/cast number for certification
        [InventoryType] VARCHAR(20)  NULL,                  -- planning/cost inventory classification (OI-49 PROVISIONAL)
        [Status]       VARCHAR(20)   NOT NULL,              -- RECEIVED|STAGED|INFLAT|COMPLETE|HOLD|SCRAP
        [Location]     VARCHAR(50)   NULL,                  -- physical floor location
        -- NOTE: [StagedPayoffPosition] and [IsWelded] were removed here. Pre-check-in
        -- staging now lives in [dbo].[RodStaging] (04_Runs), which can enforce the
        -- one-rod-per-payoff-bay invariant that a nullable column on Rod cannot.
        -- See 10-requirements/screens/RodPreCheckin.md and SRS §4.2 PCI001-PCI008 / WLD010.
        [FootageRunToDate] DECIMAL(10,2) NULL,              -- cumulative footage produced across partial runs (Phase 7 / OQ-12)
        [RemainingWeightEstimateLb] DECIMAL(8,2) NULL,      -- estimated remaining weight after a partial run (lb)
        [ReceivedAt]   DATETIMEOFFSET NOT NULL CONSTRAINT [DF_Rod_ReceivedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [CreatedBy]    VARCHAR(50)   NULL,                  -- audit: receiving/creating operator
        [ModifiedBy]   VARCHAR(50)   NULL,
        [ModifiedAt]   DATETIMEOFFSET NULL,
        [RowVersion]   ROWVERSION    NOT NULL,              -- optimistic-concurrency token

        CONSTRAINT [PK_Rod]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Rod_Alpha]   UNIQUE ([Alpha]),
        CONSTRAINT [CK_Rod_Status]  CHECK ([Status] IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')),
        CONSTRAINT [CK_Rod_DiamPos] CHECK ([DiameterIn] > 0)
    );
    PRINT 'Created table: Rod';
END
ELSE
    PRINT 'Table already exists: Rod';
GO

-- ------------------------------------------------------------
-- FlatWireRun
-- Core run header — one row per check-in event (rod or spool
-- on a line). All event tables join back to this via RunId.
-- Placed in this script so SpoolProcessing can reference SourceRunId.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlatWireRun]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[FlatWireRun] (
        [Id]             INT           NOT NULL IDENTITY(1,1),
        [RunId]          VARCHAR(20)   NOT NULL,            -- e.g. RUN-0042; referenced by all child tables
        [MachineName]         VARCHAR(5)    NOT NULL,            -- FL1 | FL2 | FL3
        [OrderId]        VARCHAR(20)   NOT NULL,            -- manufacturing order number
        [PassScheduleId] VARCHAR(30)   NOT NULL,            -- FK → PassSchedule.ScheduleId
        [Alloy]          VARCHAR(10)   NOT NULL,            -- denormalized from PassSchedule.Alloy
        [RouteMode]      VARCHAR(15)   NOT NULL,            -- Standalone | Hybrid
        [Status]         VARCHAR(20)   NOT NULL,            -- Running | Paused | Complete | Aborted
        [StartedAt]      DATETIMEOFFSET NOT NULL,
        [PausedAt]       DATETIMEOFFSET NULL,               -- current active pause start; NULL if not paused
        [CompletedAt]    DATETIMEOFFSET NULL,               -- NULL while run is still active
        [FootageFt]      DECIMAL(10,2) NOT NULL CONSTRAINT [DF_FlatWireRun_FootageFt] DEFAULT (0),  -- standardized to DECIMAL(10,2)
        [OperatorId]     VARCHAR(50)   NOT NULL,

        -- ── SpoolProcessing-completion prompt state (gap G38, 15 Aug 2026) ──
        -- FR-144 requires the SpoolCompletionPromptDue prompt to be
        -- SERVER-OWNED STATE, PERSISTED AGAINST THE RUN, so it survives a
        -- browser refresh and is re-delivered on hub group re-join (TC-173,
        -- P1).  It is the ONE event in the FlatWireHub contract that is not
        -- fire-and-forget -- SignalR.md 5.2.  Before these columns existed
        -- there was nowhere to hold it and the requirement was unbuildable.
        --
        -- ⚠ Columns, not a new table, deliberately: "persisted against the
        --   run" is literal, so the state belongs on the run row. (This note
        --   used to justify itself by "keeps the table count at 28" -- the
        --   count is not a design constraint and is now [DBD 6.2]'s to state.)
        [PromptDueAt]            DATETIMEOFFSET NULL,       -- set on the RUNNING->STOPPED edge; NULL = no prompt outstanding
        [PromptPlcStopTs]        DATETIMEOFFSET NULL,       -- the PLC stop instant the weight is latched at
        [PromptLatchedWeightLb]  DECIMAL(8,2)   NULL,       -- weight AT that instant -- never a later drifted value
        [PromptResolvedAt]       DATETIMEOFFSET NULL,       -- NULL while the prompt is still outstanding
        [PromptAnswer]           VARCHAR(15)    NULL,       -- Yes | No | AutoDismissed  (SignalR.md 5.2)

        [CreatedBy]      VARCHAR(50)   NULL,                -- audit (StartedAt serves as created timestamp)
        [ModifiedBy]     VARCHAR(50)   NULL,
        [ModifiedAt]     DATETIMEOFFSET NULL,
        [RowVersion]     ROWVERSION    NOT NULL,            -- optimistic-concurrency token (FootageFt/Status updated live)

        CONSTRAINT [PK_FlatWireRun]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_FlatWireRun_RunId]     UNIQUE ([RunId]),
        CONSTRAINT [CK_FlatWireRun_MachineName]    CHECK ([MachineName]    IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_FlatWireRun_RouteMode] CHECK ([RouteMode] IN ('Standalone','Hybrid')),
        CONSTRAINT [CK_FlatWireRun_Status]    CHECK ([Status]    IN ('Running','Paused','Complete','Aborted')),
        CONSTRAINT [CK_FlatWireRun_Footage]   CHECK ([FootageFt] >= 0),
        CONSTRAINT [CK_FlatWireRun_PromptAnswer] CHECK ([PromptAnswer] IN ('Yes','No','AutoDismissed') OR [PromptAnswer] IS NULL)
    );
    PRINT 'Created table: FlatWireRun';
END
ELSE
    PRINT 'Table already exists: FlatWireRun';
GO

-- ------------------------------------------------------------
-- SpoolProcessing
-- Pre-drawn wire spools produced on FL1 (Hybrid mode) and
-- fed into FL2/FL3. Identified by alpha code; validated
-- against the Spool article's dimensional limits at check-in
-- (merged out of SpoolConfiguration, 23 Aug 2026 -- see 01_Lookup).
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolProcessing] (
        [Id]             INT           NOT NULL IDENTITY(1,1),
        [Alpha]          VARCHAR(20)   NOT NULL,            -- e.g. SP-00021; scan key at FL2/FL3
        [OrderNo]        VARCHAR(50)   NULL,                -- manufacturing order number
        [RelLetter]      VARCHAR(10)   NULL,                -- release letter
        [ParentRodAlpha] VARCHAR(20)   NULL,                -- FK → Rod.Alpha (rod drawn into this spool)
        [SourceRodAlpha] VARCHAR(20)   NULL,                -- FK → Rod.Alpha (partial-run source rod; Phase 7 / OQ-12)
        [SourceRunId]    VARCHAR(20)   NULL,                -- FK → FlatWireRun.RunId (FL1 run that produced it)
        [MachineName]         VARCHAR(5)    NULL,                -- line that produced or is processing this spool
        [OriginRouteMode] VARCHAR(15)  NULL,               -- Standalone | Hybrid — origin route; FL2 rejects a Standalone schedule on a Hybrid-origin spool (OQ-15)
        [Status]         VARCHAR(20)   NOT NULL,            -- RECEIVED|STAGED|INFLAT|COMPLETE|HOLD|SCRAP
        [GaugeIn]        DECIMAL(8,4)  NULL,                -- wire gauge (in); set at FL2/FL3 check-in
        [WidthIn]        DECIMAL(8,4)  NULL,                -- wire width (in); set at FL2/FL3 check-in
        [GrossWeightLb]  DECIMAL(8,2)  NULL,                -- gross weight (lb)
        [NetWeightLb]    DECIMAL(8,2)  NULL,                -- net material weight (lb)
        [Location]       VARCHAR(50)   NULL,                -- physical floor location
        [ReceivedAt]     DATETIMEOFFSET NULL,               -- timestamp received at FL2/FL3
        [StagedAt]       DATETIMEOFFSET NULL,               -- timestamp staged at payoff position
        [CreatedBy]      VARCHAR(50)   NULL,                -- audit
        [ModifiedBy]     VARCHAR(50)   NULL,
        [ModifiedAt]     DATETIMEOFFSET NULL,
        [RowVersion]     ROWVERSION    NOT NULL,            -- optimistic-concurrency token

        CONSTRAINT [PK_SpoolProcessing]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SpoolProcessing_Alpha]  UNIQUE ([Alpha]),
        CONSTRAINT [CK_SpoolProcessing_Status] CHECK ([Status] IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')),
        CONSTRAINT [CK_SpoolProcessing_MachineName] CHECK ([MachineName] IN ('FL1','FL2','FL3') OR [MachineName] IS NULL),
        CONSTRAINT [CK_SpoolProcessing_OriginRoute] CHECK ([OriginRouteMode] IN ('Standalone','Hybrid') OR [OriginRouteMode] IS NULL)
    );
    PRINT 'Created table: SpoolProcessing';
END
ELSE
    PRINT 'Table already exists: SpoolProcessing';
GO

-- ============================================================
-- SPOOL GENEALOGY AND ORDER SET  (added 22 Aug 2026)
--
-- A spool created at FL1 is formed from ONE OR MORE incoming rods:
-- 1..N, minimum one, and single-rod is the majority -- 14 of 23 in the
-- client's own planner, with 9 spanning an induction weld. SpoolProcessing
-- carried two single-rod columns (ParentRodAlpha, SourceRodAlpha, the
-- second being the PARTIAL-RUN source per Q12, not a second
-- contributor) and NO child table, so a welded spool lost its parents.
-- That is gap G42, against FR-172 -- a Must requiring "multi-parent
-- genealogy so one output spool identifier references all contributing
-- parents", which the welding-wire certificates are built from
-- (NFR012).
--
-- SpoolTraceability's four core fields ARE the client's own working
-- data structure, confirmed 21 Aug 2026 -- SegmentType(Rod, Alpha,
-- Weight, SpoolID) in BaseDocuments/FL Alphas Plus - Module1.bas.
-- Analysed in BaseDocuments/FL Alphas Plus - Analysis.md.
-- ============================================================

-- ------------------------------------------------------------
-- SpoolTraceability
-- One row per contiguous run of one rod's material on one spool.
-- Mirrors CoilTraceability's shape deliberately, so the rod -> spool
-- -> coil chain reads the same at both hops.
--
-- WEIGHT IS PRIMARY, FOOTAGE IS OURS. The client's planner allocates
-- purely in pounds -- there is not one footage variable in 561 lines --
-- so SegmentWeightLb is populated from the planned allocation at spool
-- creation and is NOT derived from footage. Q10's dimensional basis is
-- therefore NOT on this table's critical path (it still gates the
-- printed label and the certificate, which state a MEASURED weight).
-- Footage is our addition, carried because CoilTraceability is already
-- footage-ranged.
--
-- FOOTAGE FRAME AND SEMANTICS, stated because nothing else states it:
--   * FootageFrom/FootageTo are SPOOL-LOCAL -- feet measured from this
--     spool's own first foot, NOT the producing run's counter.
--   * Ranges are HALF-OPEN [FootageFrom, FootageTo), matching
--     CoilTraceability and TC-617's coverage assertion.
--   * SpoolProcessing.RunStartFootageFt converts spool-local -> run-cumulative
--     for the producing FL1 run.
--
-- NO NON-OVERLAP TRIGGER, deliberately. CoilTraceability's DM010 rule
-- is enforced by a trigger because its footage columns are NOT NULL.
-- Here footage is NULLABLE (a weight-only row is legitimate before a
-- run supplies footage), and a trigger joining on NULLs SILENTLY
-- PASSES -- the worst failure shape, because it looks enforced. The
-- non-overlap rule therefore lives in the domain model (FW-207)
-- alongside the "every spool has at least one row" invariant, which
-- SQL cannot express either.
--
-- ChildAlpha EXISTS. It is added by the guarded ALTER further down this
-- file, and this comment used to say the opposite -- it was the holding
-- note written while the cardinality question was open, and it should
-- have been REPLACED rather than left standing beside the ALTER.
--
-- The cardinality is decided (22 Aug 2026, Q57): FL1 segment alphas and
-- FL2 coil identities share ONE namespace, minted through
-- CommonDB.dbo.GenerateCoilAlpha. So the planner naming a segment
-- (R00001C) rather than the spool (SP-00021) is exactly what ChildAlpha
-- records: one alpha per segment.
--
-- *** HOW the namespace is kept separate changed on 26 Aug 2026 ([N]). ***
-- This read "... with every prior segment alpha for the rod passed in
-- @CoilNoToIgnore -- read from this table, because FlatWireDB is outside
-- that function's sweep." The list is GONE: every alpha is registered in
-- proddb..coils, so the sweep finds prior segments unaided. Registration
-- fixes the cause instead of compensating for it -- but the writer does
-- not exist yet, OI-138 / G54.
--
-- BusinessRules.md 3.3's two-way SP-#####/TS###### conflict is still
-- four-way and still open; that is a FORMAT question, not the
-- cardinality one this column was waiting on.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolTraceability]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolTraceability] (
        [Id]              INT           NOT NULL IDENTITY(1,1),
        [SpoolAlpha]      VARCHAR(20)   NOT NULL,      -- FK -> SpoolProcessing.Alpha
        [RodAlpha]        VARCHAR(20)   NOT NULL,      -- FK -> Rod.Alpha (this segment's source rod)
        [SeqNo]           SMALLINT      NOT NULL,      -- order the material went ON. 1 = first on.
                                                       -- Under last-on-first-off MAX(SeqNo) is the lead
                                                       -- alpha at FL2 -- but Q45 is open, so derive that
                                                       -- in a query, never as a constraint.
        [SegmentWeightLb] DECIMAL(8,2)  NULL,          -- pounds THIS rod contributed. The client's field.
        [FootageFrom]     INT           NULL,          -- spool-local, INCLUSIVE bound. NULL until a run supplies it.
        [FootageTo]       INT           NULL,          -- spool-local, EXCLUSIVE bound
        [WeldEventId]     VARCHAR(20)   NULL,          -- FK -> WeldEvent.WeldEventId; NULL on the first segment
        [CreatedBy]       VARCHAR(50)   NULL,
        [CreatedAt]       DATETIMEOFFSET NOT NULL CONSTRAINT [DF_SpoolTraceability_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_SpoolTraceability]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SpoolTraceability_Seq]    UNIQUE ([SpoolAlpha], [SeqNo]),
        CONSTRAINT [CK_SpoolTraceability_Seq]    CHECK ([SeqNo] >= 1),
        -- Half-open, so From < To. Both NULL or both set; never one of each.
        CONSTRAINT [CK_SpoolTraceability_Range]  CHECK (([FootageFrom] IS NULL AND [FootageTo] IS NULL)
                                                     OR ([FootageFrom] IS NOT NULL AND [FootageTo] IS NOT NULL
                                                         AND [FootageFrom] < [FootageTo])),
        CONSTRAINT [CK_SpoolTraceability_Weight] CHECK ([SegmentWeightLb] IS NULL OR [SegmentWeightLb] > 0)
    );
    PRINT 'Created table: SpoolTraceability';
END
ELSE
    PRINT 'Table already exists: SpoolTraceability';
GO

-- ------------------------------------------------------------
-- SpoolOrder
-- The orders a spool's material is consumed against, ONE ROW PER
-- (SEGMENT, ORDER). A spool coming off FL1 may carry TWO OR MORE orders
-- (client, 20 Aug 2026) while FL2 makes ONE order at a time -- so the SET
-- lives here and the SELECTION lives on SpoolCheckin.OrderId, which is why
-- that column is nullable rather than removed.
--
-- *** RE-PARENTED FROM THE SPOOL TO THE SEGMENT, 8 Sep 2026 (D-57). ***
-- This table was keyed (SpoolAlpha, OrderNo, RelLetter) and referenced the
-- rod NOWHERE, so it could say THAT a spool crossed an order boundary and
-- where the boundary sat on the spool -- but not WHICH ROD'S MATERIAL went
-- to which order. Reaching the rod meant joining SpoolTraceability, and the
-- two tables' ranges were in DIFFERENT UNITS: this one in pounds, that one
-- in feet and nullable. They could not be joined at all. That was the
-- defect. The parent is now SpoolTraceability.Id -- one segment, one rod --
-- so the rod is reachable in one hop.
--
-- SpoolTraceability IS DELIBERATELY UNTOUCHED. Merging the two, which was
-- the first proposal, breaks two load-bearing things: UQ_SpoolTraceability_Seq
-- (an order split inside one physical segment would share a SeqNo) and
-- UX_SpoolTraceability_ChildAlpha, which is UNIQUE because ONE PHYSICAL
-- SEGMENT HAS ONE CHILD ALPHA (Q57). A merged grain lands that alpha on two
-- rows, and demoting the index leaves no uniqueness guard at all while
-- FW-231 is blocked (G54). Keeping the segment grain and hanging the orders
-- off it costs nothing and keeps all three.
--
-- TWO RANGES, TWO FRAMES, AND THAT IS THE POINT.
--   * SegmentWeightFrom/To are SEGMENT-LOCAL POUNDS. Pounds because weight
--     is conserved through drawing and rolling and footage is not (the same
--     reasoning RodOrderAllocation states); segment-local because that makes
--     CK_SpoolOrder_WeightRange an EXACT single-row check against
--     AllocatedWeightLb, so the range and the allocation cannot disagree.
--   * SpoolFootageFrom/To are SPOOL-LOCAL FEET, the frame FL2 actually cuts
--     in -- the line has a footage counter, not a scale. One order spread
--     over two segments reads as two unrelated pound intervals and as ONE
--     CONTIGUOUS FOOTAGE RUN. Contiguity is visible only in the spool frame,
--     which is why the pair is stored rather than derived (the same call
--     SpoolProcessing.RunStartFootageFt makes: store the anchor).
--
-- *** POUNDS ARE AUTHORITATIVE; FEET ARE A RECORDED CONVENIENCE. *** No
-- constraint can tie the two frames to each other -- SQL cannot express it
-- across a nullable parent -- so IF THEY EVER DISAGREE, THE POUNDS ARE RIGHT.
--
-- DERIVED vs PLANNED, and the honest line between them (G110).
-- Derived = the union of the orders on the rods in SpoolTraceability,
-- resolved LOCALLY from RodOrderAllocation (G48). That holds when a WHOLE
-- SEGMENT maps to a WHOLE ORDER. It does NOT hold for a segment SPLIT across
-- two orders: deriving the split point needs the ROD-LOCAL weight at which
-- this spool started taking that rod, and NO TABLE HOLDS THAT ANCHOR. A
-- straddle is therefore Planned -- an allocation decision, not a derivation.
-- Do not write a query that tries to derive one; see G110.
--
-- RE-PLANNING IS ADDITIVE, mirroring RodOrderAllocation exactly: the old row
-- is superseded and never updated, which is what UX_SpoolOrder_Active's
-- IsActive filter exists for.
--
-- NO FK ON OrderNo. Orders live in the shared schema and D-32 forbids
-- altering it, so this is an unenforced external reference -- the same
-- basis D-31 sets for PlanId / CoilOrderPlanId / SkidId.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolOrder]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolOrder] (
        [Id]                  INT            NOT NULL IDENTITY(1,1),   -- surrogate PK, repo convention
        [SpoolTraceabilityId] INT            NOT NULL,      -- FK -> SpoolTraceability.Id; ONE SEGMENT, ONE ROD
        [OrderNo]             VARCHAR(50)    NOT NULL,      -- shared-schema manufacturing order; NO FK by design (D-32)
        [RelLetter]           VARCHAR(10)    NULL,          -- release letter, mirroring SpoolProcessing.RelLetter
        [SeqNo]               SMALLINT       NULL,          -- planned consumption order, if planning supplies one
        [AllocatedWeightLb]   DECIMAL(8,2)   NOT NULL,      -- pounds of THIS SEGMENT allocated to this order
        [SegmentWeightFrom]   DECIMAL(8,2)   NOT NULL,      -- segment-local cumulative lb, INCLUSIVE
        [SegmentWeightTo]     DECIMAL(8,2)   NOT NULL,      -- segment-local cumulative lb, EXCLUSIVE
        -- SPOOL-local feet, the frame FL2 cuts in. NULLABLE for the PARENT'S reason and not out of
        -- caution: SpoolTraceability.FootageFrom/To are nullable because a weight-only row is
        -- legitimate before a run supplies footage, and a child cannot be NOT NULL where its parent
        -- is null. A row with weights and no feet is a legitimate state, not an incomplete one.
        [SpoolFootageFrom]    INT            NULL,          -- spool-local feet, INCLUSIVE
        [SpoolFootageTo]      INT            NULL,          -- spool-local feet, EXCLUSIVE
        [Source]              VARCHAR(15)    NOT NULL CONSTRAINT [DF_SpoolOrder_Source] DEFAULT ('Derived'),
        [SupersededByOrderId] INT            NULL,          -- re-planning is ADDITIVE; the old row is never updated
        [IsActive]            BIT            NOT NULL CONSTRAINT [DF_SpoolOrder_IsActive] DEFAULT (1),
        [CreatedBy]           VARCHAR(50)    NULL,          -- audit
        [CreatedAt]           DATETIMEOFFSET NOT NULL CONSTRAINT [DF_SpoolOrder_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_SpoolOrder]        PRIMARY KEY CLUSTERED ([Id] ASC),
        -- *** UNIQUENESS IS A FILTERED INDEX IN 07, NOT A CONSTRAINT HERE. ***
        -- UQ_SpoolOrder_Key (SpoolAlpha, OrderNo, RelLetter) is GONE with the spool grain, and its
        -- replacement CANNOT be an inline UNIQUE: re-planning is additive, so a superseded row and
        -- its replacement share (SpoolTraceabilityId, OrderNo, RelLetter) and a plain UNIQUE would
        -- refuse the very write the additive model exists to make. UX_SpoolOrder_Active filters on
        -- IsActive = 1, exactly as UX_RodOrderAllocation_Active does.
        -- Derived     = whole segment -> whole order, read off the rod's plan (G48)
        -- Planned     = an explicit allocation, incl. EVERY straddle -- see the header and G110
        -- Substituted = a re-plan that replaced an earlier row
        CONSTRAINT [CK_SpoolOrder_Source] CHECK ([Source] IN ('Planned','Derived','Substituted')),
        CONSTRAINT [CK_SpoolOrder_Weight] CHECK ([AllocatedWeightLb] > 0),
        -- Half-open, so From < To. AND the range must EQUAL the allocation: exact DECIMAL arithmetic
        -- makes that a single-row check, so the two can never disagree. Copied from
        -- CK_RodOrderAllocation_WeightRange, which states the same rule one hop up the chain.
        CONSTRAINT [CK_SpoolOrder_WeightRange] CHECK ([SegmentWeightFrom] < [SegmentWeightTo]
                                                  AND [SegmentWeightTo] - [SegmentWeightFrom] = [AllocatedWeightLb]),
        -- Both NULL or both set, never one of each -- the same shape as CK_SpoolTraceability_Range,
        -- because it is the same frame and the same convention. CONTAINMENT WITHIN THE PARENT'S
        -- WINDOW IS *NOT* HERE: it is cross-row, the parent's footage is nullable, and a trigger
        -- joining on NULL PASSES SILENTLY. It lives in the domain (FW-207), for the identical reason
        -- SpoolTraceability has no non-overlap trigger.
        CONSTRAINT [CK_SpoolOrder_FootageRange] CHECK (([SpoolFootageFrom] IS NULL AND [SpoolFootageTo] IS NULL)
                                                    OR ([SpoolFootageFrom] IS NOT NULL AND [SpoolFootageTo] IS NOT NULL
                                                        AND [SpoolFootageFrom] < [SpoolFootageTo]))
    );
    PRINT 'Created table: SpoolOrder';
END
ELSE
    PRINT 'Table already exists: SpoolOrder';
GO

-- ------------------------------------------------------------
-- SpoolProcessing -- retro-fit columns for an EXISTING database.
--
-- The table guard above is IF NOT EXISTS (... CREATE TABLE ...), so a
-- column added to the CREATE TABLE body NEVER reaches a database that
-- already exists: the deploy prints "Table already exists" and moves
-- on. Tables and indexes are genuinely idempotent in this runner;
-- COLUMNS ARE NOT, and the gap is silent. Same reasoning and same
-- shape as RodCheckin.WipCoilOrdersWritten in 04_Runs.
-- ------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND name = N'SpoolId')
BEGIN
    ALTER TABLE [dbo].[SpoolProcessing] ADD [SpoolId] INT NULL;   -- FK -> Spool.Id; the article this wire is wound on
    PRINT 'Added column: SpoolProcessing.SpoolId';
END
GO

-- Where this spool's first foot sits on the PRODUCING FL1 run's counter.
-- Converts SpoolTraceability's spool-local footage to run-cumulative.
-- Same pattern as Rod.FootageRunToDate: store the anchor, never derive it.
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND name = N'RunStartFootageFt')
BEGIN
    ALTER TABLE [dbo].[SpoolProcessing] ADD [RunStartFootageFt] DECIMAL(10,2) NULL;
    PRINT 'Added column: SpoolProcessing.RunStartFootageFt';
END
GO

-- A spool consumed by TWO FL2 runs (two orders) comes back to the payoff
-- part-used. These mirror the DELIVERED rod pair -- Rod.FootageRunToDate
-- and Rod.RemainingWeightEstimateLb -- so the second check-in can tell
-- what is left. Reuse the rod rules; do not invent new ones.
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND name = N'FootageRunToDate')
BEGIN
    ALTER TABLE [dbo].[SpoolProcessing] ADD [FootageRunToDate] DECIMAL(10,2) NULL;
    PRINT 'Added column: SpoolProcessing.FootageRunToDate';
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND name = N'RemainingWeightEstimateLb')
BEGIN
    ALTER TABLE [dbo].[SpoolProcessing] ADD [RemainingWeightEstimateLb] DECIMAL(8,2) NULL;
    PRINT 'Added column: SpoolProcessing.RemainingWeightEstimateLb';
END
GO

------------------------------------------------------------
-- ROD <-> ORDER ALLOCATION  (added 22 Aug 2026)
-- The rod <-> order many-to-many. Design: LatestDocument/RodOrderAllocation.md
------------------------------------------------------------

-- ------------------------------------------------------------
-- RodOrderAllocation
-- The rod <-> order many-to-many, with per-pairing allocated weight
-- and the rod-local weight range that pairing occupies.
--
-- NO FK ON OrderNo. Orders live in the shared schema and D-32 forbids
-- altering it, so this is an unenforced external reference -- the same
-- basis D-31 sets for PlanId / CoilOrderPlanId / SkidId, and the same
-- choice SpoolOrder made on 22 Aug.
--
-- THE SPLIT IS IN POUNDS, NOT FEET, and that is deliberate. Weight is
-- conserved through drawing and rolling; footage is not -- the same
-- 900 lb is ~11,100 ft at FL1 gauge and ~76,300 ft at FL2, a 7x
-- cross-section difference (DBD 6.6). A rod-local footage figure could
-- not be compared with the line's counter without re-deriving through
-- weight, so it would invite the error it looks like it prevents.
-- Pounds are also the client's own unit: there is not one footage
-- variable in the 561 lines of their planner.
--
-- THE SPLIT POINT IS NOT A COLUMN. It is the outgoing row's
-- RodWeightTo, which equals the incoming row's RodWeightFrom. A
-- separate SplitWeightLb would be a second copy of one number and it
-- would not survive a rod shared by three orders. This shape does.
--
-- RANGES ARE HALF-OPEN [From, To), matching SpoolTraceability and
-- CoilTraceability so the chain reads the same at every hop.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderAllocation]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodOrderAllocation] (
        [Id]                       INT            NOT NULL IDENTITY(1,1),   -- surrogate PK, repo convention
        [RodAlpha]                 VARCHAR(20)    NOT NULL,                 -- FK -> Rod.Alpha; the left side of the pairing
        [OrderNo]                  VARCHAR(50)    NOT NULL,                 -- shared-schema order; NO FK by design (D-32)
        [RelLetter]                VARCHAR(10)    NULL,                     -- release letter, mirroring SpoolOrder.RelLetter
        [OrderSeqNo]               SMALLINT       NOT NULL,                 -- this order's position in the station's queue; a shared rod's two rows differ by 1 here
        [RodSeqNoInOrder]          SMALLINT       NOT NULL,                 -- planning's rod sequence WITHIN this order
        [AllocatedWeightLb]        DECIMAL(8,2)   NOT NULL,                 -- pounds of this rod allocated to this order -- planning's number, never derived
        [RodWeightFrom]            DECIMAL(8,2)   NOT NULL,                 -- rod-local cumulative pounds, INCLUSIVE bound
        [RodWeightTo]              DECIMAL(8,2)   NOT NULL,                 -- rod-local cumulative pounds, EXCLUSIVE bound; the split point when a successor row exists
        [PinRole]                  VARCHAR(12)    NOT NULL,                 -- Sole|PinnedFirst|Free|PinnedLast|PinnedBoth -- stored, not derived: the validator reads it on every scan
        [RodKind]                  VARCHAR(10)    NOT NULL,                 -- Full|Partial -- Q73's tier-2 discriminator; Partial is a back-to-stock remainder
        [Source]                   VARCHAR(15)    NOT NULL
            CONSTRAINT [DF_RodOrderAllocation_Source] DEFAULT ('Planned'),  -- Planned|Derived|Substituted
        [SupersededByAllocationId] INT            NULL,                     -- re-planning is ADDITIVE: the old row is superseded, never updated
        [IsActive]                 BIT            NOT NULL
            CONSTRAINT [DF_RodOrderAllocation_IsActive] DEFAULT (1),        -- 0 once superseded; the filtered indexes key on it
        [CreatedBy]                VARCHAR(50)    NULL,                     -- audit
        [CreatedAt]                DATETIMEOFFSET NOT NULL
            CONSTRAINT [DF_RodOrderAllocation_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_RodOrderAllocation]          PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_RodOrderAllocation_PinRole]  CHECK ([PinRole] IN ('Sole','PinnedFirst','Free','PinnedLast','PinnedBoth')),
        CONSTRAINT [CK_RodOrderAllocation_RodKind]  CHECK ([RodKind] IN ('Full','Partial')),
        CONSTRAINT [CK_RodOrderAllocation_Source]   CHECK ([Source]  IN ('Planned','Derived','Substituted')),
        CONSTRAINT [CK_RodOrderAllocation_Weight]   CHECK ([AllocatedWeightLb] > 0),
        CONSTRAINT [CK_RodOrderAllocation_Seq]      CHECK ([OrderSeqNo] >= 1 AND [RodSeqNoInOrder] >= 1),
        -- Half-open, so From < To. AND the range must equal the allocation: exact
        -- DECIMAL arithmetic makes that a single-row check, so the two can never
        -- disagree. The footage version of this column pair could not express it.
        CONSTRAINT [CK_RodOrderAllocation_WeightRange] CHECK ([RodWeightFrom] < [RodWeightTo]
                                                          AND [RodWeightTo] - [RodWeightFrom] = [AllocatedWeightLb])
    );
    PRINT 'Created table: RodOrderAllocation';
END
ELSE
    PRINT 'Table already exists: RodOrderAllocation';
GO

-- ------------------------------------------------------------
-- SpoolTraceability.ChildAlpha -- retro-fit for an EXISTING database.
--
-- ChildAlpha -- ONE ALPHA PER SEGMENT. Cardinality decided 22 Aug 2026
-- (Q57), which is what the superseded comment on this table was waiting
-- for. That comment said "until cardinality is decided the column would
-- be a guess. Do not add it speculatively." It is decided; this is the
-- column.
--
-- It names the SEGMENT (R00001C), not the spool (SP-00021). That is a
-- CARDINALITY difference and not a naming one: one alpha per segment
-- against one per spool, so it can never be SpoolProcessing.Alpha and the two must
-- not be conflated. SpoolProcessing.Alpha stays the spool MATERIAL identity.
--
-- MINTED BY CommonDB.dbo.GenerateCoilAlpha(rodAlpha, ''), NOT by a local
-- per-rod counter. A BLANK ignore list -- see the precondition below.
--
-- *** THE @ignoreList ARGUMENT WENT ON 26 AUG 2026 (change [N]). *** It read:
-- "@ignoreList carries EVERY alpha already recorded for this rod HERE, not
--  just this transaction's: the sweep covers the shared schema and finds
--  those unaided, but FlatWireDB is outside it. Cap 500 chars."
-- That was correct while segment alphas stayed FlatWireDB-local.
--
-- PRECONDITION: EVERY SEGMENT ALPHA IS REGISTERED IN proddb..coils. That is
-- what lets the list go -- the sweep then finds prior segments the same way
-- it finds prior coils, and F11's 500-char cap stops applying to flat wire.
-- *** NOTHING WRITES IT YET. WITHOUT THAT WRITER A BLANK LIST REISSUES
--     R00001A ON EVERY SPOOL. See OI-138 / G54 / FW-231. ***
--
-- WHY A LOCAL COUNTER IS STILL WRONG (unchanged, and the reason is the same):
-- FL1 segment alphas and FL2 coil identities are drawn from ONE namespace off
-- the same six-character root, so a local counter would hand the same R00001A
-- to a spool segment and to a finished coil.
--
-- COIL PARTS DO NOT ROOT HERE. They root on the SEGMENT alpha this column
-- holds -- GenerateCoilAlpha('R00001A','') -> R00001AA -- so a segment takes a
-- single trailing letter and a coil off it takes a double. Rod-fed coils (no
-- segment) fall back to the rod. See RodOrderAllocation.md 2.5 and 2.8.
--
-- LIMIT OF THE GUARANTEE, Q59: other callers of GenerateCoilAlpha pass
-- their own ignore list, not ours. The scrap-weight path was confirmed on
-- 22 Aug to call the same function, so a mint against a rod FL1 is
-- actively segmenting can still be issued an alpha held here. Accepted
-- and monitored; the UNIQUE index below is what makes it loud.
--
-- OPAQUE. Never parse it and never rebuild it. R00001A + 'A' and
-- R00001 + AlphaLetter(27) both render R00001AA, so the string does not
-- decompose. There is deliberately NO stored letter index: the generator
-- may skip a suffix already taken by a coil, so an index would drift
-- from the letter it claims to explain. SeqNo carries the ordering.
-- ------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolTraceability]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[SpoolTraceability]') AND name = N'ChildAlpha')
BEGIN
    ALTER TABLE [dbo].[SpoolTraceability] ADD [ChildAlpha] VARCHAR(20) NULL;
    PRINT 'Added column: SpoolTraceability.ChildAlpha';
END
GO

-- ------------------------------------------------------------
-- SpoolOrder -- the retro-fit ALTER block was REMOVED, 8 Sep 2026 (D-57).
--
-- It added SpoolWeightFrom/SpoolWeightTo, G48's fix, to an existing database.
-- The re-grain replaces that pair with SegmentWeightFrom/To (segment-local,
-- NOT NULL) plus SpoolFootageFrom/To, all in the CREATE TABLE body above.
--
-- *** IT COULD NOT BE LEFT IN PLACE. *** Its guard is "the column is absent",
-- and after the re-grain SpoolWeightFrom IS absent -- by design. So on a fresh
-- teardown-and-deploy the block would have fired and bolted two stray nullable
-- columns onto the new table, in a script whose whole purpose is to be
-- idempotent. Removing it is not tidying; leaving it was a defect.
--
-- The deploy path for this change is TEARDOWN-AND-DEPLOY, per D-53's precedent
-- ("a table cannot be removed by an incremental re-run"), so no ALTER path is
-- owed here. There is no in-repo precedent for DROP COLUMN or for dropping an
-- inline UNIQUE, and a half-applied re-grain is worse than either end state.
-- ------------------------------------------------------------
