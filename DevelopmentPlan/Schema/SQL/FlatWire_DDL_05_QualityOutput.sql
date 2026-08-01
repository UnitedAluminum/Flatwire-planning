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
        [NetWeightLb]   DECIMAL(8,2)  NOT NULL,             -- net material weight (lb); footage × AlloyProperty.LbPerFtFactor (OQ-36)
        [NetWeightOverrideLb] DECIMAL(8,2) NULL,            -- manual override when derived weight is disputed (OQ-36 fallback)
        [ScaleWeightLb] DECIMAL(8,2)  NULL,                 -- physical scale weight captured at packing (DB7b)
        [FinalGaugeIn]  DECIMAL(8,4)  NOT NULL,             -- final measured gauge (in)
        [FinalWidthIn]  DECIMAL(8,4)  NOT NULL,             -- final measured width (in)
        [FootageFt]     DECIMAL(10,2) NOT NULL,             -- total footage on this coil (ft); standardized to DECIMAL(10,2)
        [PassScheduleId] VARCHAR(30)  NULL,                 -- FK → PassSchedule.ScheduleId (schedule effective at creation, OQ-54)
        [PassScheduleSnapshot] NVARCHAR(MAX) NULL,          -- JSON snapshot of the schedule config at coil creation (NFR013)
        [SkidId]        VARCHAR(20)   NULL,                 -- external skid reference (existing skid table; no local FK)
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
-- rod alpha. Enables full genealogy: coil → rod → supplier heat.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoilTraceability]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[CoilTraceability] (
        [Id]          INT         NOT NULL IDENTITY(1,1),
        [CoilAlpha]   VARCHAR(30) NOT NULL,                 -- FK → CoilOutput.CoilAlpha
        [RodAlpha]    VARCHAR(20) NOT NULL,                 -- FK → Rod.Alpha (source rod for this range)
        [FootageFrom] INT         NOT NULL,                 -- start footage (inclusive)
        [FootageTo]   INT         NOT NULL,                 -- end footage (inclusive)

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
        -- long before any column existed to record them: OQ-48 (mid-run checkout), OQ-50
        -- (partial-run disposition, both 4 May 2026) and OQ-68 (welded pre-check-out,
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
        -- OQ-68: removing a WELDED staged rod means cutting the material, so it is a
        -- rejection — supervisor approval, a documented reason, and the rod goes to HOLD.
        CONSTRAINT [CK_RodCheckout_ModePWelded]    CHECK ([WasWelded] = 0
                                                       OR ([ApprovedBy] IS NOT NULL
                                                           AND [ApprovedAt] IS NOT NULL
                                                           AND [OverrideReason] IS NOT NULL
                                                           AND [NewRodStatus] = 'HOLD')),
        -- OQ-48: a mid-run checkout requires supervisor approval. Decided 4 May 2026 and
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
