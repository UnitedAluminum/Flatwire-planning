-- ============================================================
-- Flat Wire Mill — DDL Script 05: Quality Control & Output Tables
-- Run order : 05 of 09
-- Tables    : SpcCheckpoint, SpcMeasurement, WipRejection,
--             CoilOutput, CoilTraceability, RodCheckout
-- Dependencies: 02_Schedule (PassSchedule), 03_Materials (FlatWireRun, Rod), 04_Runs (RollOverride)
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- SpcCheckpoint
-- Header for each SPC measurement session. Groups individual
-- SpcMeasurement rows by run, footage position, and trigger type.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpcCheckpoint]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpcCheckpoint] (
        [Id]                 INT           NOT NULL IDENTITY(1,1),
        [CheckpointId]       VARCHAR(20)   NOT NULL,        -- e.g. SPC-0041
        [RunId]              VARCHAR(20)   NOT NULL,        -- FK → FlatWireRun.RunId
        [LineId]             VARCHAR(5)    NOT NULL,
        [CheckpointType]     VARCHAR(30)   NOT NULL,        -- PreRun|PostDieChange|ManualSpotCheck|PostRun|RollAdjustTrigger
        [FootagePosition]    INT           NOT NULL,        -- footage counter at checkpoint initiation
        [OperatorId]         VARCHAR(50)   NOT NULL,
        [TriggerDescription] VARCHAR(200)  NULL,            -- e.g. "DB2 die changed from 0.310 → 0.308"
        [AllInSpec]          BIT           NULL,            -- 1=all pass; 0=any fail; NULL=not yet evaluated
        [Timestamp]          DATETIMEOFFSET NOT NULL CONSTRAINT [DF_SpcCheckpoint_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_SpcCheckpoint]             PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SpcCheckpoint_Id]          UNIQUE ([CheckpointId]),
        CONSTRAINT [CK_SpcCheckpoint_LineId]      CHECK ([LineId] IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_SpcCheckpoint_Type]        CHECK ([CheckpointType] IN ('PreRun','PostDieChange','ManualSpotCheck','PostRun','RollAdjustTrigger')),
        CONSTRAINT [CK_SpcCheckpoint_FootagePos]  CHECK ([FootagePosition] >= 0)
    );
    PRINT 'Created table: SpcCheckpoint';
END
ELSE
    PRINT 'Table already exists: SpcCheckpoint';
GO

-- ------------------------------------------------------------
-- SpcMeasurement
-- Individual measurement readings belonging to one checkpoint.
-- InSpec and Deviation are computed from TargetValue vs ActualValue.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpcMeasurement]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpcMeasurement] (
        [Id]             INT          NOT NULL IDENTITY(1,1),
        [CheckpointId]   VARCHAR(20)  NOT NULL,             -- FK → SpcCheckpoint.CheckpointId
        [Name]           VARCHAR(50)  NOT NULL,             -- e.g. FM1Gauge, FM1Width, WireDiameterPostDraw
        [TargetValue]    DECIMAL(8,4) NOT NULL,             -- specification target
        [ToleranceValue] DECIMAL(8,4) NOT NULL,             -- ± tolerance band for this measurement
        [ActualValue]    DECIMAL(8,4) NOT NULL,             -- operator-measured actual
        [Deviation]      AS ([ActualValue] - [TargetValue]) PERSISTED,  -- computed signed deviation
        [InSpec]         AS (CASE WHEN ABS([ActualValue] - [TargetValue]) <= [ToleranceValue] THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END) PERSISTED,  -- computed in/out of spec

        CONSTRAINT [PK_SpcMeasurement]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_SpcMeasurement_TolPos] CHECK ([ToleranceValue] >= 0)
    );
    PRINT 'Created table: SpcMeasurement';
END
ELSE
    PRINT 'Table already exists: SpcMeasurement';
GO

-- ------------------------------------------------------------
-- WipRejection
-- Material rejection events during a run or at incoming
-- inspection. RunId is nullable to support pre-run rejections.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WipRejection]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[WipRejection] (
        [Id]                 INT           NOT NULL IDENTITY(1,1),
        [RejectionId]        VARCHAR(20)   NOT NULL,        -- e.g. REJ-0041
        [RunId]              VARCHAR(20)   NULL,            -- FK → FlatWireRun.RunId; NULL for pre-run rejections
        [LineId]             VARCHAR(5)    NOT NULL,
        [MaterialAlpha]      VARCHAR(20)   NOT NULL,        -- rod alpha or spool alpha
        [Stage]              VARCHAR(30)   NOT NULL,        -- e.g. FL1ActiveRun, FL2Incoming
        [FootagePosition]    INT           NULL,            -- NULL for pre-run rejections
        [RejectionGroup]     VARCHAR(30)   NOT NULL,        -- SurfaceQuality|Dimensional|WeldQuality|Material|Process
        [RejectionReason]    VARCHAR(50)   NOT NULL,        -- e.g. GaugeOutOfSpec, WeldBreak
        [MeasuredValue]      DECIMAL(10,4) NULL,
        [TargetMin]          DECIMAL(10,4) NULL,
        [TargetMax]          DECIMAL(10,4) NULL,
        [Disposition]        VARCHAR(20)   NOT NULL,        -- Suspend | Scrap | Rework
        [ObservationNotes]   VARCHAR(500)  NULL,
        [NewMaterialStatus]  VARCHAR(20)   NOT NULL,        -- HOLD | SCRAP
        [OperatorId]         VARCHAR(50)   NOT NULL,
        [Timestamp]          DATETIMEOFFSET NOT NULL CONSTRAINT [DF_WipRejection_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_WipRejection]              PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_WipRejection_Id]           UNIQUE ([RejectionId]),
        CONSTRAINT [CK_WipRejection_LineId]       CHECK ([LineId]           IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_WipRejection_Group]        CHECK ([RejectionGroup]   IN ('SurfaceQuality','Dimensional','WeldQuality','Material','Process')),
        CONSTRAINT [CK_WipRejection_Disposition]  CHECK ([Disposition]      IN ('Suspend','Scrap','Rework')),
        CONSTRAINT [CK_WipRejection_MatStatus]    CHECK ([NewMaterialStatus] IN ('HOLD','SCRAP'))
    );
    PRINT 'Created table: WipRejection';
END
ELSE
    PRINT 'Table already exists: WipRejection';
GO

-- ------------------------------------------------------------
-- CoilOutput
-- Finished output coil records generated at run completion.
-- One row per coil produced by a run.
--
-- FINISHED-COIL DIMENSIONAL LIMITS -- RE-HOMED HERE 23 Aug 2026, as a comment
-- and not yet as data, which is the honest state.
--
-- SpoolConfiguration was merged into Spool (01_Lookup) on 23 Aug 2026. It held
-- TWO seeded rows and only ONE of them was a spool: Id 1 'TKUP-1 Intermediate
-- Spool' (the article, merged) and Id 2 'Coreless Finish Coil' -- which is the
-- FL2 OUTPUT and is CORELESS, so it has no article to merge into. Id 2 was
-- referenced by NOTHING (every seeded Spool and SpoolProcessing row used
-- SpoolTypeId = 1), so nothing broke when it went; but it carried the only
-- recorded dimensional bounds for a finished coil, and deleting them silently
-- would have lost them:
--
--     weight  100.00 .. 1100.00 lb
--     core     8.0000 .. 16.0000 in   (nominal even though the coil is coreless
--                                      -- the band described the wound package)
--     OD      20.0000 .. 36.0000 in
--
-- NOT ADDED AS COLUMNS OR CONSTRAINTS, deliberately. Nothing validated against
-- Id 2, so making these enforceable now would be new behaviour introduced under
-- cover of a rename. They are recorded here so the next person to specify coil
-- completion limits starts from the client's numbers rather than inventing them.
-- Read with OI-66 (the OD -> weight conversion) and the ~1,800 lb spool / two
-- ~900 lb coils working target.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[CoilOutput] (
        [Id]            INT           NOT NULL IDENTITY(1,1),
        [CoilAlpha]     VARCHAR(30)   NOT NULL,             -- e.g. FW-00421-C01
        [RunId]         VARCHAR(20)   NOT NULL,             -- FK → FlatWireRun.RunId
        [LineId]        VARCHAR(5)    NOT NULL,
        [OrderId]       VARCHAR(20)   NOT NULL,             -- manufacturing order this coil fulfills
        [GrossWeightLb] DECIMAL(8,2)  NOT NULL,             -- gross weight (lb)
        [NetWeightLb]   DECIMAL(8,2)  NOT NULL,             -- net material weight (lb); footage × AlloyProperty.LbPerFtFactor (OQ-10)
        [NetWeightOverrideLb] DECIMAL(8,2) NULL,            -- manual override when derived weight is disputed (OQ-10 fallback)
        [ScaleWeightLb] DECIMAL(8,2)  NULL,                 -- physical scale weight captured at packing (DB7b)
        [FinalGaugeIn]  DECIMAL(8,4)  NOT NULL,             -- final measured gauge (in)
        [FinalWidthIn]  DECIMAL(8,4)  NOT NULL,             -- final measured width (in)
        [FootageFt]     DECIMAL(10,2) NOT NULL,             -- total footage on this coil (ft); standardized to DECIMAL(10,2)
        [PassScheduleId] VARCHAR(30)  NULL,                 -- FK → PassSchedule.ScheduleId (schedule effective at creation, OQ-64)
        [PassScheduleSnapshot] NVARCHAR(MAX) NULL,          -- JSON snapshot of the schedule config at coil creation (NFR013)
        -- FR-509 / [INT §8.1]: the shared-schema identity of this coil. coils.coil_no is
        -- char(9) and 'FW-#####-C##' is twelve characters, so the customer-facing alpha above
        -- CANNOT be the shared key. CoilNo (renamed from SharedCoilNo, 22 Aug 2026 --
-- Q58) holds what CommonDB.dbo.GenerateCoilAlpha
        -- minted off the source rod ('R00421' -> 'R00421A'), which is what proddb..coils
        -- receives. Both columns are FlatWireDB-local, so D-32 is untouched.
        -- It is also the RETRY CONTRACT for FlatWire_CompleteCoilOnSkid: persist it the moment
        -- that procedure returns, and pass it back on any retry or the retry mints a second coil.
        [CoilNo]  VARCHAR(9)    NULL,                 -- -> proddb..coils.coil_no (FR-509)
        [SharedSkidNo]  VARCHAR(9)    NULL,                 -- -> united_db..wip_skids.skid_no (FR-514, OI-104 closed)
        [SkidId]        VARCHAR(20)   NULL,                 -- external skid reference; SharedSkidNo is the resolved legacy skid
        [SkidStatus]    VARCHAR(20)   NULL,                 -- Open | Closing | Staged | Closed
        [StagingLocation] VARCHAR(20) NULL,                 -- packing staging bay (e.g. A-3, A-4, A-5)
        [Status]        VARCHAR(20)   NOT NULL,             -- COMPLETE | HOLD | SCRAP
        [GaugeInSpec]   BIT           NULL,                 -- from PostRun SPC checkpoint; NULL until evaluated
        [WidthInSpec]   BIT           NULL,                 -- from PostRun SPC checkpoint; NULL until evaluated
        [CompletedAt]   DATETIMEOFFSET NOT NULL CONSTRAINT [DF_CoilOutput_CompletedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [OperatorId]    VARCHAR(50)   NOT NULL,
        [CreatedBy]     VARCHAR(50)   NULL,                 -- audit (CompletedAt serves as created timestamp)
        [ModifiedBy]    VARCHAR(50)   NULL,
        [ModifiedAt]    DATETIMEOFFSET NULL,
        [RowVersion]    ROWVERSION    NOT NULL,             -- optimistic-concurrency token

        CONSTRAINT [PK_CoilOutput]            PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_CoilOutput_CoilAlpha]  UNIQUE ([CoilAlpha]),
        CONSTRAINT [CK_CoilOutput_LineId]     CHECK ([LineId]     IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_CoilOutput_Status]     CHECK ([Status]     IN ('COMPLETE','HOLD','SCRAP')),
        CONSTRAINT [CK_CoilOutput_SkidStatus] CHECK ([SkidStatus] IN ('Open','Closing','Staged','Closed') OR [SkidStatus] IS NULL),
        CONSTRAINT [CK_CoilOutput_Footage]    CHECK ([FootageFt]  > 0)
    );
    PRINT 'Created table: CoilOutput';
END
ELSE
    PRINT 'Table already exists: CoilOutput';
GO

-- ------------------------------------------------------------
-- CoilTraceability
-- Maps footage ranges within an output coil back to the source
-- rod alpha, and on a spool-fed line to the source spool.
-- Enables full genealogy: coil -> spool -> rod -> supplier heat,
-- which is the chain FR-333 asks for ("rod -> spool -> coil").
--
-- SpoolAlpha added Aug-6-2026. Rationale, because the obvious
-- alternatives are both wrong:
--   * RunId cannot stand in for it. SpoolCheckin.RunId is NOT unique
--     (many spools may be checked in against one run) and CoilOutput.RunId
--     is many coils per run, so CoilOutput -> SpoolCheckin returns a SET of
--     spools, never "the" spool.
--   * CoilOutput.SpoolAlpha is wrong for a DIFFERENT reason than this
--     comment used to give. It said "a spool runs out mid-coil and the next
--     is mounted" -- THAT CANNOT HAPPEN. Welding is an FL1 operation (client,
--     20 Aug 2026: "we're welding at the FL1 side, but we're cutting and
--     re-going again at the FL2 side") and Q17 fixed FL2 check-in as
--     EXCLUSIVE -- one spool on the line at a time. With no weld and no
--     second spool there is nothing to join the material to, which is why
--     the client's own planner breaks its loop when SpoolID changes
--     (ORD016). The real reason the rows are row-level is RODS, not spools:
--     a coil has ONE spool and MANY rods, and the footage range says which
--     feet came from which ROD -- which is what the welding-wire
--     certificate needs. Corrected 22 Aug 2026 (G-1).
-- One spool routinely yields ~2 coils (client 6 Aug 2026: FL1 spools
-- ~1,800 lb, FL2 coils 800/900 lb), so this is the normal case.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilTraceability]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[CoilTraceability] (
        [Id]          INT         NOT NULL IDENTITY(1,1),
        [CoilAlpha]   VARCHAR(30) NOT NULL,                 -- FK → CoilOutput.CoilAlpha
        [RodAlpha]    VARCHAR(20) NOT NULL,                 -- FK → Rod.Alpha (source rod for this range)
        -- FK → SpoolProcessing.Alpha. NULL on a rod-fed run (FL1 standalone, and FL3 when
        -- fed directly from rod) -- there is no input spool to name. NOT NULL is
        -- therefore wrong here: absence is a real, common state, not missing data.
        [SpoolAlpha]  VARCHAR(20) NULL,                     -- FK → SpoolProcessing.Alpha (source spool for this range; NULL when rod-fed)
        -- Ranges are HALF-OPEN [FootageFrom, FootageTo) -- the semantics
        -- trg_CoilTraceability_NoOverlap actually enforces (08_Programmability),
        -- and what TC-617 asserts (100% coverage, zero overlap, half-open).
        -- The earlier "(inclusive)" comments contradicted the trigger; corrected 22 Aug 2026.
        [FootageFrom] INT         NOT NULL,                 -- start footage, INCLUSIVE bound
        [FootageTo]   INT         NOT NULL,                 -- end footage, EXCLUSIVE bound

        CONSTRAINT [PK_CoilTraceability]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_CoilTraceability_Range]  CHECK ([FootageFrom] < [FootageTo])
    );
    PRINT 'Created table: CoilTraceability';
END
ELSE
    PRINT 'Table already exists: CoilTraceability';
GO

-- ------------------------------------------------------------
-- RodCheckout
-- Records rod removal from a payoff position.
--   Mode P = pre-check-out — un-stages a pre-checked-in rod that was
--            never checked in (RunId NULL, footage 0, no tags to clear)
--   Mode A = pre-run — checked in and acknowledged, footage still 0
--   Mode B = mid-run emergency removal, footage > 0, supervisor approval
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodCheckout]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodCheckout] (
        [Id]                           INT           NOT NULL IDENTITY(1,1),
        [CheckoutId]                   VARCHAR(20)   NOT NULL,  -- e.g. CO-0041
        [RunId]                        VARCHAR(20)   NULL,      -- FK → FlatWireRun.RunId; NULL for Mode A
        [LineId]                       VARCHAR(5)    NOT NULL,
        [RodAlpha]                     VARCHAR(20)   NOT NULL,  -- FK → Rod.Alpha
        [PayoffPosition]               INT           NOT NULL,  -- 1 or 2
        [Mode]                         VARCHAR(10)   NOT NULL,  -- ModeP | ModeA | ModeB
        [FootageAtCheckout]            INT           NOT NULL CONSTRAINT [DF_RodCheckout_Footage] DEFAULT (0),
        [ReasonCode]                   VARCHAR(50)   NOT NULL,
        [RodDisposition]               VARCHAR(30)   NOT NULL,  -- see CK below
        [RemainingWeightLbEstimate]    DECIMAL(8,2)  NULL,      -- Mode B only
        [InProcessMaterialDisposition] VARCHAR(30)   NULL,      -- Mode B only
        [PartialSpoolAlpha]            VARCHAR(20)   NULL,      -- set when AcceptAsPartialRun
        [NewRodStatus]                 VARCHAR(20)   NOT NULL,  -- RECEIVED|HOLD|SCRAP etc.
        [PlcTagsCleared]               BIT           NOT NULL,  -- 1 = PLC tags cleared successfully
        -- SUPERVISOR AUTHORISATION (added 1 Aug 2026, gap G24). Three approvals were decided
        -- long before any column existed to record them: OQ-74 (mid-run checkout), OQ-75
        -- (partial-run disposition, both 4 May 2026) and OQ-69 (welded pre-check-out,
        -- 30 Jul 2026). Until now this table had NO approval columns at all, so every
        -- supervisor-gated checkout was enforced at the UI and stored no evidence.
        [WasWelded]                    BIT           NOT NULL CONSTRAINT [DF_RodCheckout_WasWelded] DEFAULT (0),  -- Mode P: rod was induction-welded when removed
        [ApprovedBy]                   VARCHAR(50)   NULL,      -- authorising supervisor badge/ID; PIN is NEVER stored
        [ApprovedAt]                   DATETIMEOFFSET NULL,
        [OverrideReason]               VARCHAR(200)  NULL,
        [OperatorId]                   VARCHAR(50)   NOT NULL,
        [Timestamp]                    DATETIMEOFFSET NOT NULL CONSTRAINT [DF_RodCheckout_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_RodCheckout]                PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_RodCheckout_CheckoutId]     UNIQUE ([CheckoutId]),
        CONSTRAINT [CK_RodCheckout_LineId]         CHECK ([LineId]          IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_RodCheckout_PayoffPos]      CHECK ([PayoffPosition]  IN (1, 2)),
        CONSTRAINT [CK_RodCheckout_Mode]           CHECK ([Mode]            IN ('ModeP','ModeA','ModeB')),
        CONSTRAINT [CK_RodCheckout_RodDisposition] CHECK ([RodDisposition]  IN ('ReturnToFloorStorage','ReturnToWarehouse','HoldReturnToStorage','Scrap','DeferContinueLater')),
        CONSTRAINT [CK_RodCheckout_IPDisposition]  CHECK ([InProcessMaterialDisposition] IN ('HoldPendingSupervisor','Scrap','AcceptAsPartialRun') OR [InProcessMaterialDisposition] IS NULL),
        CONSTRAINT [CK_RodCheckout_NewRodStatus]   CHECK ([NewRodStatus] IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')),
        CONSTRAINT [CK_RodCheckout_Footage]        CHECK ([FootageAtCheckout] >= 0),
        -- Mode P (pre-check-out) un-stages a rod that was never checked in: no run exists,
        -- no footage was produced, no pass-schedule acknowledgement to void, and no PLC
        -- tags were ever pushed — so there are none to clear.
        CONSTRAINT [CK_RodCheckout_ModeP]          CHECK ([Mode] <> 'ModeP'
                                                       OR ([RunId] IS NULL
                                                           AND [FootageAtCheckout] = 0
                                                           AND [PlcTagsCleared] = 0
                                                           AND [InProcessMaterialDisposition] IS NULL
                                                           AND [PartialSpoolAlpha] IS NULL)),
        -- Mode B is the only mode that can produce in-process material to dispose of.
        CONSTRAINT [CK_RodCheckout_ModeB]          CHECK ([Mode] = 'ModeB'
                                                       OR [InProcessMaterialDisposition] IS NULL),
        -- Only a Mode P removal can be of a welded rod: Modes A and B follow a check-in, by
        -- which point the weld is upstream history rather than a property of this removal.
        CONSTRAINT [CK_RodCheckout_WasWelded]      CHECK ([WasWelded] = 0 OR [Mode] = 'ModeP'),
        -- The approval stamp is all-or-nothing. An approval with no supervisor or no reason
        -- is unauditable, which defeats the point of gating on it.
        CONSTRAINT [CK_RodCheckout_Approval]       CHECK (
                                                    ([ApprovedBy] IS NOT NULL AND [ApprovedAt] IS NOT NULL AND [OverrideReason] IS NOT NULL)
                                                 OR ([ApprovedBy] IS NULL AND [ApprovedAt] IS NULL AND [OverrideReason] IS NULL)
                                                ),
        -- OQ-69: removing a WELDED staged rod means cutting the material, so it is a
        -- rejection — supervisor approval, a documented reason, and the rod goes to HOLD.
        CONSTRAINT [CK_RodCheckout_ModePWelded]    CHECK ([WasWelded] = 0
                                                       OR ([ApprovedBy] IS NOT NULL
                                                           AND [ApprovedAt] IS NOT NULL
                                                           AND [OverrideReason] IS NOT NULL
                                                           AND [NewRodStatus] = 'HOLD')),
        -- OQ-74: a mid-run checkout requires supervisor approval. Decided 4 May 2026 and
        -- unenforced until now.
        CONSTRAINT [CK_RodCheckout_ModeBApproved]  CHECK ([Mode] <> 'ModeB'
                                                       OR ([ApprovedBy] IS NOT NULL
                                                           AND [ApprovedAt] IS NOT NULL
                                                           AND [OverrideReason] IS NOT NULL))
    );
    PRINT 'Created table: RodCheckout';
END
ELSE
    PRINT 'Table already exists: RodCheckout';
GO

-- ============================================================
-- OI-25 -- THE TWO FOOTAGE FRAMES, AND THE COIL-START ANCHOR
-- (added 22 Aug 2026)
--
-- THE FRAMES, declared here because [BR 3.6]'s "Footage counter | the
-- PLC-sourced cumulative feet produced on a run" was the ONLY normative
-- frame statement in the repository, and it covers one of the two:
--
--   RUN FRAME (cumulative feet on the run's counter):
--     FlatWireRun.FootageFt, RunReading.FootageFt,
--     WeldEvent.FootagePosition, SpcCheckpoint.FootagePosition,
--     RunPauseEvent / RodCheckout footage, FlatWireRunDetail.FootageFt
--   COIL-LOCAL FRAME (feet from THIS coil's own first foot):
--     CoilTraceability.FootageFrom / FootageTo
--   SPOOL-LOCAL FRAME (feet from THIS spool's own first foot):
--     SpoolTraceability.FootageFrom / FootageTo
--
-- Conversion, stated once:
--     coilLocalFt = FLOOR(runFt - CoilOutput.RunFootageAtStartFt)
-- valid only where the result lies in [0, CoilOutput.FootageFt). A run
-- event outside every coil's window belongs to NO coil.
--
-- WHY THE ANCHOR IS STORED AND NOT DERIVED. It cannot be obtained by
-- summing prior CoilOutput.FootageFt, because FR-130d (client-confirmed
-- 30 Jul 2026) says a mid-run coil break "shall remove the stop and
-- start a new stop from zero" and the leftover is welded forward or
-- scrapped. Threading scrap and a mid-run WipRejection do the same. So
-- RUN FOOTAGE != SUM OF COIL FOOTAGES, and any derivation silently
-- absorbs the loss into the next coil. The repo already solved this one
-- level up by storing the anchor: Rod.FootageRunToDate and
-- RodStaging.FootageRunToDateAtStaging. Follow that precedent.
--
-- WHY BOTH ENDPOINTS ARE STORED, AND NEITHER IS COMPUTED. A computed
-- RunFootageAtEndFt = RunFootageAtStartFt + FootageFt forces
-- start(n) = end(n-1) identically -- which is exactly the contiguity
-- FR-130d denies. The two are SEPARATE RECORDINGS. Do not add a
-- computed column here; it re-introduces the defect it appears to fix.
--
-- AnchorBasis makes an assumption VISIBLE. Where no coil-start
-- observation exists the handler seeds the anchor from the previous
-- coil's end and stamps 'AssumedContiguous', so a report can tell a
-- measured chain from an inferred one. This does NOT close FR-130d:
-- the material removed at a break still has no persistence target
-- (OI-13, gap G34), so an AssumedContiguous row absorbs that loss.
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND name = N'RunFootageAtEndFt')
BEGIN
    -- The run-frame counter READ AND LOCKED at completion -- the one
    -- footage fact the POST /coil/complete handler actually observes.
    ALTER TABLE [dbo].[CoilOutput] ADD [RunFootageAtEndFt] DECIMAL(10,2) NULL;
    PRINT 'Added column: CoilOutput.RunFootageAtEndFt';
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND name = N'RunFootageAtStartFt')
BEGIN
    -- The run-frame counter at this coil's FIRST foot. A SECOND
    -- recording, not a function of RunFootageAtEndFt.
    ALTER TABLE [dbo].[CoilOutput] ADD [RunFootageAtStartFt] DECIMAL(10,2) NULL;
    PRINT 'Added column: CoilOutput.RunFootageAtStartFt';
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND name = N'AnchorBasis')
BEGIN
    ALTER TABLE [dbo].[CoilOutput] ADD [AnchorBasis] VARCHAR(20) NOT NULL
        CONSTRAINT [DF_CoilOutput_AnchorBasis] DEFAULT ('AssumedContiguous');
    PRINT 'Added column: CoilOutput.AnchorBasis';
END
GO

-- The two CHECKs go in SEPARATE BATCHES from the ADD COLUMN above.
-- SQL Server compiles a whole batch before executing any of it, so a
-- constraint referencing a column added earlier in the SAME batch fails
-- with "Invalid column name" -- caught on a live deploy, 22 Aug 2026.
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND name = N'AnchorBasis')
   AND NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = N'CK_CoilOutput_AnchorBasis')
BEGIN
    ALTER TABLE [dbo].[CoilOutput]
        ADD CONSTRAINT [CK_CoilOutput_AnchorBasis]
            CHECK ([AnchorBasis] IN ('Observed','AssumedContiguous'));
    PRINT 'Added constraint: CK_CoilOutput_AnchorBasis';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'[dbo].[CoilOutput]') AND name = N'RunFootageAtStartFt')
   AND NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = N'CK_CoilOutput_RunFrame')
BEGIN
    ALTER TABLE [dbo].[CoilOutput]
        ADD CONSTRAINT [CK_CoilOutput_RunFrame]
            CHECK ([RunFootageAtStartFt] IS NULL OR [RunFootageAtEndFt] IS NULL
                OR [RunFootageAtStartFt] < [RunFootageAtEndFt]);
    PRINT 'Added constraint: CK_CoilOutput_RunFrame';
END
GO

-- ------------------------------------------------------------
-- CoilTraceability -- weight beside footage, and an explicit sequence.
--
-- SegmentWeightLb is Tim's "how many pounds for each alpha" (20 Aug
-- 2026) and gives CoilTraceability the same shape as SpoolTraceability,
-- so the two genealogy tables agree on FRAME and on UNIT. Footage
-- ranges remain the NFR012-contractual chain, verified by TC-616 /
-- TC-617 and enforced by trg_CoilTraceability_NoOverlap.
-- ------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilTraceability]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[CoilTraceability]') AND name = N'SegmentWeightLb')
BEGIN
    ALTER TABLE [dbo].[CoilTraceability] ADD [SegmentWeightLb] DECIMAL(8,2) NULL;
    PRINT 'Added column: CoilTraceability.SegmentWeightLb';
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilTraceability]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[CoilTraceability]') AND name = N'SeqNo')
BEGIN
    ALTER TABLE [dbo].[CoilTraceability] ADD [SeqNo] SMALLINT NOT NULL
        CONSTRAINT [DF_CoilTraceability_SeqNo] DEFAULT (1);
    PRINT 'Added column: CoilTraceability.SeqNo';
END
GO
