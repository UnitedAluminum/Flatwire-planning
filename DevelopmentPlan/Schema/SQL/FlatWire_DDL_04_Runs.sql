-- ============================================================
-- Flat Wire Mill — DDL Script 04: Run Tracking Tables
-- Run order : 04 of 09
-- Tables    : FlatWireRunDetail, RodCheckin, SpoolCheckin,
--             RunPauseEvent, WeldEvent, RollOverride, DieChangeEvent,
--             RunReading
-- Dependencies: 03_Materials (FlatWireRun, Rod, Spool), 02_Schedule (PassSchedule)
-- Note      : FlatWireRun itself is in 03_Materials so Spool can
--             reference it as SourceRunId.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- FlatWireRunDetail
-- Renamed from FlatLineProcessing. Per-stop detail rows for a
-- run. Captures footage, gauge readings, and output dimensions
-- at each stop point. Child of FlatWireRun.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlatWireRunDetail]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[FlatWireRunDetail] (
        [Id]               INT          NOT NULL IDENTITY(1,1),
        [RunId]            VARCHAR(20)  NOT NULL,           -- FK → FlatWireRun.RunId
        [SetupNo]          VARCHAR(20)  NULL,               -- legacy traceability from FlatLineProcessing
        [StopNo]           INT          NOT NULL,           -- sequential stop number within the run
        [SequenceNo]       INT          NOT NULL,           -- sub-sequence within the stop
        [PlanId]           INT          NULL,               -- FK to production planning table
        [CoilOrderPlanId]  INT          NULL,               -- FK to coil-level order plan
        [HomeMfgOrderNo]   VARCHAR(50)  NULL,               -- home/parent manufacturing order number
        [PayoffPositionId] INT          NOT NULL,           -- FK to payoff position reference
        [FootageFt]        DECIMAL(10,2) NOT NULL,          -- footage at which this stop occurred
        [OnGaugeWeight]    DECIMAL(8,2)  NULL,              -- on-gauge material weight to this stop (lb)
        [TargetGauge]      DECIMAL(8,4)  NULL,              -- target gauge at this stop (in)
        [GaugeTolerance]   DECIMAL(8,4)  NULL,              -- gauge tolerance (±) at this stop (in)
        [TargetWidth]      DECIMAL(8,4)  NULL,              -- target width at this stop (in)
        [WidthTolerance]   DECIMAL(8,4)  NULL,              -- width tolerance (±) at this stop (in)
        [StartGauge]       DECIMAL(8,4)  NULL,              -- actual gauge at start of stop (in)
        [ExitGauge]        DECIMAL(8,4)  NULL,              -- actual gauge at exit of stop (in)
        [OutputOD]         DECIMAL(8,4)  NULL,              -- output coil/spool outer diameter (in)
        [OutputID]         DECIMAL(8,4)  NULL,              -- output coil/spool inner diameter/core (in)

        CONSTRAINT [PK_FlatWireRunDetail] PRIMARY KEY CLUSTERED ([Id] ASC)
    );
    PRINT 'Created table: FlatWireRunDetail';
END
ELSE
    PRINT 'Table already exists: FlatWireRunDetail';
GO

-- ------------------------------------------------------------
-- RodCheckin
-- Captures every rod check-in event with inspection results
-- and pre-run SPC measurements. One row per rod loaded.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodCheckin]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodCheckin] (
        [Id]                      INT           NOT NULL IDENTITY(1,1),
        [RunId]                   VARCHAR(20)   NOT NULL,   -- FK → FlatWireRun.RunId
        [LineId]                  VARCHAR(5)    NOT NULL,   -- FL1 | FL2 | FL3
        [RodAlpha]                VARCHAR(20)   NOT NULL,   -- FK → Rod.Alpha
        [PayoffPosition]          INT           NOT NULL,   -- 1 or 2
        [DiameterMeasuredIn]      DECIMAL(8,4)  NOT NULL,   -- operator-measured rod diameter (in)
        [GrossWeightLb]           DECIMAL(8,2)  NOT NULL,   -- gross weight verified at check-in (lb)
        [NetWeightLb]             DECIMAL(8,2)  NOT NULL,   -- net weight verified at check-in (lb)
        [PassScheduleId]          VARCHAR(30)   NOT NULL,   -- FK → PassSchedule.ScheduleId
        [OrderId]                 VARCHAR(20)   NOT NULL,   -- manufacturing order confirmed at check-in
        [ScrapBoxRef]             VARCHAR(20)   NULL,        -- optional scrap-box reference (reuses slitter scrap-box source; OQ scrap-box PROVISIONAL)
        [MmsId]                   VARCHAR(30)   NULL,        -- material-tracking identity for this input coil (generated at check-in)
        [MmsStatus]               VARCHAR(15)   NULL,        -- Open | Active | Closed (closed on consumption, remaining ft = 0)
        [OperatorId]              VARCHAR(50)   NOT NULL,
        [CheckedInAt]             DATETIMEOFFSET NOT NULL CONSTRAINT [DF_RodCheckin_CheckedInAt] DEFAULT (SYSDATETIMEOFFSET()),
        [PlcTagsPushed]           BIT           NOT NULL,   -- 1 = PLC tags written successfully
        [InspectionOxidation]     VARCHAR(10)   NOT NULL,   -- Pass | Fail
        [InspectionSurfaceDefects] VARCHAR(10)  NOT NULL,   -- Pass | Fail
        [InspectionWaterStains]   VARCHAR(10)   NOT NULL,   -- Pass | Fail
        [InspectionConnectorTag]  VARCHAR(10)   NOT NULL,   -- Pass | Fail
        [InspectionNotes]         VARCHAR(500)  NULL,
        [SpcM1In]                 DECIMAL(8,4)  NOT NULL,   -- pre-run SPC: primary rod diameter (in)
        [SpcM2In]                 DECIMAL(8,4)  NOT NULL,   -- pre-run SPC: secondary diameter at 90° (in)
        [SpcOvalityIn]            AS (ABS([SpcM1In] - [SpcM2In])) PERSISTED,  -- computed ovality |M1 − M2| (in)

        CONSTRAINT [PK_RodCheckin]               PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_RodCheckin_PayoffPos]     CHECK ([PayoffPosition] IN (1, 2)),
        CONSTRAINT [CK_RodCheckin_LineId]        CHECK ([LineId] IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_RodCheckin_Oxidation]     CHECK ([InspectionOxidation]     IN ('Pass','Fail')),
        CONSTRAINT [CK_RodCheckin_Surface]       CHECK ([InspectionSurfaceDefects] IN ('Pass','Fail')),
        CONSTRAINT [CK_RodCheckin_WaterStains]   CHECK ([InspectionWaterStains]   IN ('Pass','Fail')),
        CONSTRAINT [CK_RodCheckin_ConnTag]       CHECK ([InspectionConnectorTag]  IN ('Pass','Fail')),
        CONSTRAINT [CK_RodCheckin_MmsStatus]     CHECK ([MmsStatus] IN ('Open','Active','Closed') OR [MmsStatus] IS NULL)
    );
    PRINT 'Created table: RodCheckin';
END
ELSE
    PRINT 'Table already exists: RodCheckin';
GO

-- ------------------------------------------------------------
-- SpoolCheckin
-- Captures every spool check-in event at FL2/FL3. Mirrors
-- RodCheckin for the Hybrid route mode spool-feed workflow.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolCheckin]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolCheckin] (
        [Id]               INT           NOT NULL IDENTITY(1,1),
        [RunId]            VARCHAR(20)   NOT NULL,           -- FK → FlatWireRun.RunId
        [LineId]           VARCHAR(5)    NOT NULL,           -- FL2 | FL3
        [SpoolAlpha]       VARCHAR(20)   NOT NULL,           -- FK → Spool.Alpha
        [PayoffPosition]   INT           NOT NULL,           -- 1 or 2
        [GaugeIn]          DECIMAL(8,4)  NOT NULL,           -- operator-measured gauge (in)
        [WidthIn]          DECIMAL(8,4)  NOT NULL,           -- operator-measured width (in)
        [GrossWeightLb]    DECIMAL(8,2)  NOT NULL,           -- gross weight verified (lb)
        [NetWeightLb]      DECIMAL(8,2)  NOT NULL,           -- net weight verified (lb)
        [PassScheduleId]   VARCHAR(30)   NOT NULL,           -- FK → PassSchedule.ScheduleId
        [OrderId]          VARCHAR(20)   NOT NULL,
        [MmsId]            VARCHAR(30)   NULL,               -- material-tracking identity for this input spool (generated at check-in)
        [MmsStatus]        VARCHAR(15)   NULL,               -- Open | Active | Closed
        [OperatorId]       VARCHAR(50)   NOT NULL,
        [CheckedInAt]      DATETIMEOFFSET NOT NULL CONSTRAINT [DF_SpoolCheckin_CheckedInAt] DEFAULT (SYSDATETIMEOFFSET()),
        [PlcTagsPushed]    BIT           NOT NULL,
        [InspectionSurface] VARCHAR(10)  NOT NULL,           -- Pass | Fail
        [InspectionNotes]  VARCHAR(500)  NULL,

        CONSTRAINT [PK_SpoolCheckin]              PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_SpoolCheckin_LineId]       CHECK ([LineId]           IN ('FL2','FL3')),
        CONSTRAINT [CK_SpoolCheckin_PayoffPos]    CHECK ([PayoffPosition]   IN (1, 2)),
        CONSTRAINT [CK_SpoolCheckin_Inspection]   CHECK ([InspectionSurface] IN ('Pass','Fail')),
        CONSTRAINT [CK_SpoolCheckin_MmsStatus]    CHECK ([MmsStatus] IN ('Open','Active','Closed') OR [MmsStatus] IS NULL)
    );
    PRINT 'Created table: SpoolCheckin';
END
ELSE
    PRINT 'Table already exists: SpoolCheckin';
GO

-- ------------------------------------------------------------
-- RunPauseEvent
-- One row per pause/resume cycle. Created on pause; updated
-- on resume. Rows with NULL ResumedAt are active (open) pauses.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RunPauseEvent]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RunPauseEvent] (
        [Id]                   INT           NOT NULL IDENTITY(1,1),
        [RunId]                VARCHAR(20)   NOT NULL,       -- FK → FlatWireRun.RunId
        [PausedAt]             DATETIMEOFFSET NOT NULL,      -- timestamp of pause
        [FootageAtPause]       INT           NOT NULL,       -- footage counter at moment of pause
        [ReasonCode]           VARCHAR(50)   NOT NULL,       -- e.g. GaugeWidthInvestigation, DieChange
        [ReasonCategory]       VARCHAR(50)   NOT NULL,       -- e.g. QualityMeasurement, Maintenance, Other
        [Notes]                VARCHAR(500)  NULL,           -- required when ReasonCategory = Other
        [ResumedAt]            DATETIMEOFFSET NULL,          -- NULL = pause still active
        [PauseDurationSeconds] AS (DATEDIFF(SECOND, [PausedAt], [ResumedAt])),  -- computed on resume; NULL while open
        [Outcome]              VARCHAR(30)   NULL,           -- ResumeRun|LogWipRejection|CheckOutRod|ContinuePause
        [ActivityCompleted]    VARCHAR(500)  NULL,           -- operator description of activity during pause
        [OperatorId]           VARCHAR(50)   NOT NULL,       -- operator who paused the run
        [ResumedBy]            VARCHAR(50)   NULL,           -- operator who resumed the run

        CONSTRAINT [PK_RunPauseEvent]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_RunPauseEvent_Outcome] CHECK ([Outcome] IN ('ResumeRun','LogWipRejection','CheckOutRod','ContinuePause') OR [Outcome] IS NULL),
        CONSTRAINT [CK_RunPauseEvent_Footage] CHECK ([FootageAtPause] >= 0),
        CONSTRAINT [CK_RunPauseEvent_NotesOther] CHECK ([ReasonCategory] <> 'Other' OR [Notes] IS NOT NULL)
    );
    PRINT 'Created table: RunPauseEvent';
END
ELSE
    PRINT 'Table already exists: RunPauseEvent';
GO

-- ------------------------------------------------------------
-- WeldEvent
-- Rod-to-rod weld join events during a run. Joins the tail of
-- the depleting rod to the lead of the incoming rod.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WeldEvent]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[WeldEvent] (
        [Id]                    INT           NOT NULL IDENTITY(1,1),
        [WeldEventId]           VARCHAR(20)   NOT NULL,     -- e.g. WLD-002
        [RunId]                 VARCHAR(20)   NOT NULL,     -- FK → FlatWireRun.RunId
        [LineId]                VARCHAR(5)    NOT NULL,
        [OutgoingRodAlpha]      VARCHAR(20)   NOT NULL,     -- FK → Rod.Alpha (depleting tail rod)
        [IncomingRodAlpha]      VARCHAR(20)   NOT NULL,     -- FK → Rod.Alpha (joining lead rod)
        [FootagePosition]       INT           NOT NULL,     -- footage at moment of weld
        [WeldType]              VARCHAR(20)   NOT NULL,     -- InductionWeld | LaserWeld
        [WeldQuality]           VARCHAR(10)   NOT NULL,     -- Pass | Fail
        [WeldQualityFailReason] VARCHAR(200)  NULL,         -- required when WeldQuality = Fail
        [OperatorId]            VARCHAR(50)   NOT NULL,
        [Timestamp]             DATETIMEOFFSET NOT NULL CONSTRAINT [DF_WeldEvent_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_WeldEvent]              PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_WeldEvent_Id]           UNIQUE ([WeldEventId]),
        CONSTRAINT [CK_WeldEvent_LineId]       CHECK ([LineId]      IN ('FL1','FL2','FL3')),
        -- Induction is the only weld type in the May-21-2026 revision; LaserWeld retained for historical genealogy only.
        CONSTRAINT [CK_WeldEvent_WeldType]     CHECK ([WeldType]    IN ('InductionWeld','LaserWeld')),
        CONSTRAINT [CK_WeldEvent_Quality]      CHECK ([WeldQuality] IN ('Pass','Fail')),
        CONSTRAINT [CK_WeldEvent_FootagePos]   CHECK ([FootagePosition] >= 0),
        -- Fail reason is mandatory when the weld quality result is Fail (WLD013)
        CONSTRAINT [CK_WeldEvent_FailReason]   CHECK ([WeldQuality] <> 'Fail' OR [WeldQualityFailReason] IS NOT NULL)
    );
    PRINT 'Created table: WeldEvent';
END
ELSE
    PRINT 'Table already exists: WeldEvent';
GO

-- ------------------------------------------------------------
-- RollOverride
-- Run-level roll gap / die parameter adjustments. Does NOT
-- modify the pass schedule — run-specific deviations only.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RollOverride]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RollOverride] (
        [Id]               INT           NOT NULL IDENTITY(1,1),
        [OverrideId]       VARCHAR(20)   NOT NULL,          -- e.g. OVR-0042
        [RunId]            VARCHAR(20)   NOT NULL,          -- FK → FlatWireRun.RunId
        [LineId]           VARCHAR(5)    NOT NULL,
        [RodAlpha]         VARCHAR(20)   NOT NULL,          -- FK → Rod.Alpha (material in-process)
        [FootagePosition]  INT           NOT NULL,          -- footage at time of override
        [ComponentName]    VARCHAR(20)   NOT NULL,          -- e.g. DB1, FM1
        [OldValue]         DECIMAL(8,4)  NOT NULL,          -- scheduled or previous value
        [NewValue]         DECIMAL(8,4)  NOT NULL,          -- override value applied
        [Delta]            AS ([NewValue] - [OldValue]) PERSISTED,  -- computed: NewValue − OldValue
        [ReasonCode]       VARCHAR(50)   NOT NULL,          -- see CK below
        [Notes]            VARCHAR(500)  NULL,
        [MeasuredGaugeIn]  DECIMAL(8,4)  NULL,              -- gauge reading that prompted override (in)
        [MeasuredWidthIn]  DECIMAL(8,4)  NULL,              -- width reading that prompted override (in)
        [PlcTagWritten]    BIT           NOT NULL,          -- 1 = PLC tag updated successfully
        [OperatorId]       VARCHAR(50)   NOT NULL,
        [Timestamp]        DATETIMEOFFSET NOT NULL CONSTRAINT [DF_RollOverride_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_RollOverride]              PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_RollOverride_OverrideId]   UNIQUE ([OverrideId]),
        CONSTRAINT [CK_RollOverride_LineId]       CHECK ([LineId] IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_RollOverride_Component]    CHECK ([ComponentName] IN ('DB1','DB2','FM1','EdgeSet','FM2_8in','FM2_6inS1','FM2_6inS2','FM2_6inS3')),
        CONSTRAINT [CK_RollOverride_ReasonCode]   CHECK ([ReasonCode] IN ('GaugeDriftHigh','GaugeDriftLow','WidthDrift','SpcFlag','RollWear','PostWeldCorrection','OperatorDiscretion','Other')),
        CONSTRAINT [CK_RollOverride_FootagePos]   CHECK ([FootagePosition] >= 0)
    );
    PRINT 'Created table: RollOverride';
END
ELSE
    PRINT 'Table already exists: RollOverride';
GO

-- ------------------------------------------------------------
-- DieChangeEvent
-- Die replacement events during a run. Automatically triggers
-- a PostDieChange SPC checkpoint.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DieChangeEvent]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[DieChangeEvent] (
        [Id]                   INT           NOT NULL IDENTITY(1,1),
        [DieChangeId]          VARCHAR(20)   NOT NULL,      -- e.g. DC-0041
        [RunId]                VARCHAR(20)   NOT NULL,      -- FK → FlatWireRun.RunId
        [LineId]               VARCHAR(5)    NOT NULL,
        [RodAlpha]             VARCHAR(20)   NOT NULL,      -- FK → Rod.Alpha (material in-process)
        [FootagePosition]      INT           NOT NULL,      -- footage at time of die change
        [DiePosition]          VARCHAR(5)    NOT NULL,      -- DB1 | DB2
        [OldDieSizeIn]         DECIMAL(8,4)  NOT NULL,      -- replaced die hole diameter (in)
        [NewDieSizeIn]         DECIMAL(8,4)  NOT NULL,      -- replacement die hole diameter (in)
        [ReasonCode]           VARCHAR(50)   NOT NULL,      -- DieWear | GaugeDrift | Breakage | ScheduledChange
        [LinkedOverrideId]     VARCHAR(20)   NULL,          -- FK → RollOverride.OverrideId (auto-created)
        [SpcCheckpointRequired] BIT          NOT NULL CONSTRAINT [DF_DieChangeEvent_SpcReq] DEFAULT (1),
        [OperatorId]           VARCHAR(50)   NOT NULL,
        [Timestamp]            DATETIMEOFFSET NOT NULL CONSTRAINT [DF_DieChangeEvent_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_DieChangeEvent]            PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_DieChangeEvent_Id]         UNIQUE ([DieChangeId]),
        CONSTRAINT [CK_DieChangeEvent_LineId]     CHECK ([LineId]      IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_DieChangeEvent_DiePos]     CHECK ([DiePosition] IN ('DB1','DB2')),
        CONSTRAINT [CK_DieChangeEvent_ReasonCode] CHECK ([ReasonCode] IN ('PlannedLife','GaugeDrift','DieFailure','SizeChange','DieWear','Breakage','ScheduledChange','Other')),
        CONSTRAINT [CK_DieChangeEvent_FootagePos] CHECK ([FootagePosition] >= 0)
    );
    PRINT 'Created table: DieChangeEvent';
END
ELSE
    PRINT 'Table already exists: DieChangeEvent';
GO

-- ------------------------------------------------------------
-- RunReading
-- Decimated / sampled gauge-width-speed profile persisted per
-- run. Live telemetry stays in-memory (SignalR) in Phase 1;
-- this table holds the historical profile that feeds the FL2
-- gauge trace and the Gauge-Trace / Gauge-CPK / Cut-Traceability
-- reports. NOT a per-tick historian — writes are sampled.
-- Retention/rollup policy: TBD (G3 open item).
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RunReading]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RunReading] (
        [Id]        INT           NOT NULL IDENTITY(1,1),
        [RunId]     VARCHAR(20)   NOT NULL,                 -- FK → FlatWireRun.RunId
        [FootageFt] DECIMAL(10,2) NOT NULL,                 -- footage position of this reading (ft)
        [GaugeIn]   DECIMAL(8,4)  NULL,                     -- gauge reading (in); NULL for FL2 standalone live feed
        [WidthIn]   DECIMAL(8,4)  NULL,                     -- width reading (in)
        [SpeedFpm]  DECIMAL(8,2)  NULL,                     -- line speed at this position (ft/min)
        [InSpec]    BIT           NOT NULL CONSTRAINT [DF_RunReading_InSpec] DEFAULT (1),  -- within gauge tolerance at capture
        [ReadingTs] DATETIME2     NOT NULL CONSTRAINT [DF_RunReading_ReadingTs] DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT [PK_RunReading]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_RunReading_Footage] CHECK ([FootageFt] >= 0)
    );
    PRINT 'Created table: RunReading';
END
ELSE
    PRINT 'Table already exists: RunReading';
GO
