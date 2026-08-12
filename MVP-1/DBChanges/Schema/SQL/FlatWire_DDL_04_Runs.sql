-- ============================================================
-- Flat Wire Mill — DDL Script 04: Run Tracking Tables
-- Run order : 04 of 09
-- Tables    : FlatWireRunDetail, RodStaging, RodCheckin, SpoolCheckin,
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
-- RodStaging
-- Pre-check-in: the next rod is registered against a VPS payoff
-- bay while the current coil is still running, so the line can
-- run continuously through an induction weld.
--   SRS §4.2 PCI001-PCI008 (station, payoff capture, weld surfacing)
--   SRS WLD003/WLD010      ("Mark as Welded" + operator/timestamp; weld columns are written
--                           by POST /weldevent on a PASS result only -- see IsWelded below)
--   SRS TRV004/TRV009      (Traveler Queue section)
--   SRS §4.18 PRC007       (carry-forward evidence at the staging scan)
-- FL1 and FL3 only — PCI002 excludes FL2, which has no staging space.
-- Supersedes the retired Rod.StagedPayoffPosition / Rod.IsWelded columns:
-- only a dedicated row can enforce one-rod-per-bay (see filtered indexes
-- in 07_Indexes).
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodStaging]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodStaging] (
        [Id]                      INT           NOT NULL IDENTITY(1,1),
        [LineId]                  VARCHAR(5)    NOT NULL,   -- FL1 | FL3 (PCI002 excludes FL2)
        [PayoffPosition]          INT           NOT NULL,   -- 1 or 2 (PCI006)
        [RodAlpha]                VARCHAR(20)   NOT NULL,   -- FK → Rod.Alpha
        -- TWO sequences, deliberately. Planning sets an order (R00043→R00044→R00045) and
        -- departing from it is PERMITTED BUT AUTHORISED: the operator is notified that the
        -- rod is not the one expected next, and a supervisor signs off
        -- (OutOfSequenceOverride below). It is never a hard refusal, and the deviation is
        -- recorded as well as authorised.
        --   RodSeqno    = ACTUAL processing order, assigned here at pre-check-in.
        --                 This is the SRS FlatwireQueue sequence (Rodno/RodSeqno/Welded),
        --                 which that model inserts at pre-check-in. Monotonic per line.
        --   PlannedSeqno = SNAPSHOT of the planned position at staging time. Snapshot, not
        --                 a join back to planning: same pattern as the pass schedule
        --                 id/version/effective-date already copied onto the run record.
        --                 NULL when the rod has no planned position (e.g. a substitution).
        -- Variance = RodSeqno vs PlannedSeqno, reportable without reconstructing history.
        [RodSeqno]                INT           NOT NULL,   -- actual processing sequence
        [PlannedSeqno]            INT           NULL,       -- planned sequence, snapshotted
        -- WLD010. Set by POST /weldevent, in the same transaction as the WeldEvent row, and
        -- ONLY when WeldQuality='Pass'. A failed weld writes the event and leaves this 0 --
        -- the join did not hold, so the rod is not joined to the running rod. (Aug 1 2026)
        [IsWelded]                BIT           NOT NULL CONSTRAINT [DF_RodStaging_IsWelded] DEFAULT (0),
        [Status]                  VARCHAR(12)   NOT NULL,   -- Staged | CheckedIn | Unstaged
        -- Resolved from planning_routings at the scan, never typed. On a cold line this is
        -- what the first rod REVEALS, which is why even the first rod is validatable.
        [OrderId]                 VARCHAR(20)   NULL,       -- order this rod is staged against
        -- Supervisor authorisation. ONE deviation, and it is not a refusal: the operator is
        -- notified and a supervisor signs off. Same shape as the OI-56 spool-weight override —
        -- reason + supervisor badge/ID + PIN — with the deviation, the authorising supervisor
        -- and the reason recorded. The PIN is NEVER stored.
        --   OutOfSequenceOverride  the rod is not the one planning expects next
        --
        -- OffScheduleOverride / ScheduledLineId DROPPED 1 Aug 2026 (client decision, 30 Jul).
        -- A rod whose order is booked on the OTHER rod line is no longer a deviation at all:
        -- the station SWITCHES to the correct line automatically, with no message and no
        -- override, at both pre-check-in and check-in (Q24). If Q25 — an order scheduled on
        -- NEITHER rod line — later needs an authorisation, it re-adds its own columns; the
        -- three credential columns below are shared and survive for reuse.
        [OutOfSequenceOverride]   BIT           NOT NULL CONSTRAINT [DF_RodStaging_OutOfSeq] DEFAULT (0),
        [ExpectedRodAlpha]        VARCHAR(20)   NULL,       -- rod planning expected next, at the moment of deviation
        [OverrideBy]              VARCHAR(50)   NULL,       -- authorising supervisor badge/ID
        [OverrideAt]              DATETIMEOFFSET NULL,
        [OverrideReason]          VARCHAR(200)  NULL,
        [ScrapBoxRef]             VARCHAR(20)   NULL,       -- optional scrap box (PCI005)
        [DiameterIn]              DECIMAL(8,4)  NOT NULL,   -- measured at staging (PCI004)
        [GrossWeightLb]           DECIMAL(8,2)  NOT NULL,
        [NetWeightLb]             DECIMAL(8,2)  NOT NULL,
        [FootageRunToDateAtStaging] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_RodStaging_Footage] DEFAULT (0),  -- >0 forces carry-forward (PRC007)
        [InspectionOxidation]     VARCHAR(10)   NOT NULL,   -- Pass | Fail
        [InspectionSurfaceDefects] VARCHAR(10)  NOT NULL,   -- Pass | Fail
        [InspectionWaterStains]   VARCHAR(10)   NOT NULL,   -- Pass | Fail
                                                            -- 3 items, not 4: the connector-tag item is a
                                                            -- check-in concern (gap G14 — do not add it here)
        [InspectionNotes]         VARCHAR(500)  NULL,
        [StagedAt]                DATETIMEOFFSET NOT NULL CONSTRAINT [DF_RodStaging_StagedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [StagedBy]                VARCHAR(50)   NOT NULL,
        [WeldedAt]                DATETIMEOFFSET NULL,      -- WLD003 operator + timestamp of the PASSING weld
        [WeldedBy]                VARCHAR(50)   NULL,       -- from the signed-in session, not re-keyed
        [CheckedInAt]             DATETIMEOFFSET NULL,      -- set when check-in consumes this row
        [RodCheckinId]            INT           NULL,       -- FK → RodCheckin.Id (see 06_ForeignKeys)
        -- TWO routes out of a staged bay, not one (Q69 + Q23 item 3, decided 30 Jul 2026):
        --   PreCheckOut   the operator un-stages the rod. Operator-only when unwelded; a
        --                 WELDED rod needs a supervisor override and goes to HOLD, because
        --                 removal means cutting the material — that is a rejection, and the
        --                 approval evidence lives on RodCheckout (Mode P).
        --   WipRejection  the rod failed the staging inspection. The rejection captures the
        --                 reason and puts the rod on HOLD; THAT is what releases this row and
        --                 frees the bay. Chosen over a fourth 'Rejected' Status value, which
        --                 would have forced the vocabulary, CK_RodStaging_Unstaged and the
        --                 UX_RodStaging_Bay filter to change together for no operational gain.
        [UnstagedAt]              DATETIMEOFFSET NULL,      -- pre-check-out or rejection release
        [UnstagedBy]              VARCHAR(50)   NULL,
        [UnstageReasonCode]       VARCHAR(40)   NULL,
        [UnstageKind]             VARCHAR(20)   NULL,       -- PreCheckOut | WipRejection
        [WipRejectionId]          INT           NULL,       -- FK → WipRejection.Id (see 06_ForeignKeys)
        [RowVersion]              ROWVERSION    NOT NULL,   -- optimistic-concurrency token

        CONSTRAINT [PK_RodStaging]              PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_RodStaging_LineId]       CHECK ([LineId] IN ('FL1','FL3')),
        CONSTRAINT [CK_RodStaging_PayoffPos]    CHECK ([PayoffPosition] IN (1, 2)),
        CONSTRAINT [CK_RodStaging_Status]       CHECK ([Status] IN ('Staged','CheckedIn','Unstaged')),
        CONSTRAINT [CK_RodStaging_Oxidation]    CHECK ([InspectionOxidation]      IN ('Pass','Fail')),
        CONSTRAINT [CK_RodStaging_Surface]      CHECK ([InspectionSurfaceDefects] IN ('Pass','Fail')),
        CONSTRAINT [CK_RodStaging_WaterStains]  CHECK ([InspectionWaterStains]    IN ('Pass','Fail')),
        CONSTRAINT [CK_RodStaging_DiamPos]      CHECK ([DiameterIn] > 0),
        CONSTRAINT [CK_RodStaging_SeqPos]       CHECK ([RodSeqno] > 0),
        -- Positive when present. Deliberately NO constraint tying PlannedSeqno to RodSeqno:
        -- they are free to differ, and a difference is the normal case, not an error.
        CONSTRAINT [CK_RodStaging_PlannedSeqPos] CHECK ([PlannedSeqno] IS NULL OR [PlannedSeqno] > 0),
        -- The credential stamp is all-or-nothing and required by EITHER deviation. An
        -- override with no supervisor or no reason is unauditable, which defeats the point
        -- of permitting the deviation at all.
        CONSTRAINT [CK_RodStaging_Override]      CHECK (
                                                    ([OutOfSequenceOverride] = 1
                                                        AND [OverrideBy] IS NOT NULL
                                                        AND [OverrideAt] IS NOT NULL
                                                        AND [OverrideReason] IS NOT NULL)
                                                 OR ([OutOfSequenceOverride] = 0
                                                        AND [OverrideBy] IS NULL
                                                        AND [OverrideAt] IS NULL
                                                        AND [OverrideReason] IS NULL)
                                                ),
        -- The deviation's evidence is present exactly when the deviation is claimed.
        CONSTRAINT [CK_RodStaging_OutOfSeq]      CHECK (
                                                    ([OutOfSequenceOverride] = 1 AND [ExpectedRodAlpha] IS NOT NULL)
                                                 OR ([OutOfSequenceOverride] = 0 AND [ExpectedRodAlpha] IS NULL)
                                                ),
        -- "Out of sequence" means the rod staged is not the one expected.
        CONSTRAINT [CK_RodStaging_OutOfSeqRod]   CHECK ([ExpectedRodAlpha] IS NULL OR [ExpectedRodAlpha] <> [RodAlpha]),
        -- Welded stamp is all-or-nothing, and only meaningful once IsWelded is set.
        -- Unaffected by the Aug 1 2026 quality decision: a FAILED weld sets none of the three,
        -- so the group still holds. Weld quality itself lives on WeldEvent, never mirrored
        -- here -- one join must not have two quality answers that can disagree.
        CONSTRAINT [CK_RodStaging_Welded]       CHECK (
                                                    ([IsWelded] = 0 AND [WeldedAt] IS NULL AND [WeldedBy] IS NULL)
                                                 OR ([IsWelded] = 1 AND [WeldedAt] IS NOT NULL AND [WeldedBy] IS NOT NULL)
                                                ),
        -- Unstage stamp is all-or-nothing, and present exactly when Status = 'Unstaged'.
        CONSTRAINT [CK_RodStaging_Unstaged]     CHECK (
                                                    ([Status] = 'Unstaged'
                                                        AND [UnstagedAt] IS NOT NULL
                                                        AND [UnstagedBy] IS NOT NULL
                                                        AND [UnstageReasonCode] IS NOT NULL
                                                        AND [UnstageKind] IS NOT NULL)
                                                 OR ([Status] <> 'Unstaged'
                                                        AND [UnstagedAt] IS NULL
                                                        AND [UnstagedBy] IS NULL
                                                        AND [UnstageReasonCode] IS NULL
                                                        AND [UnstageKind] IS NULL)
                                                ),
        CONSTRAINT [CK_RodStaging_UnstageKind]  CHECK ([UnstageKind] IS NULL
                                                    OR [UnstageKind] IN ('PreCheckOut','WipRejection')),
        -- The rejection link is present exactly when the release was a rejection.
        -- ISNULL, not a bare comparison: `[UnstageKind] = 'WipRejection'` evaluates to
        -- UNKNOWN while UnstageKind is NULL, and a CHECK constraint accepts UNKNOWN — which
        -- would have let a still-Staged row carry a rejection link.
        CONSTRAINT [CK_RodStaging_RejectLink]   CHECK (
                                                    (ISNULL([UnstageKind],'') =  'WipRejection' AND [WipRejectionId] IS NOT NULL)
                                                 OR (ISNULL([UnstageKind],'') <> 'WipRejection' AND [WipRejectionId] IS NULL)
                                                ),
        -- Check-in stamp is all-or-nothing, and present exactly when Status = 'CheckedIn'.
        CONSTRAINT [CK_RodStaging_CheckedIn]    CHECK (
                                                    ([Status] = 'CheckedIn'
                                                        AND [CheckedInAt] IS NOT NULL
                                                        AND [RodCheckinId] IS NOT NULL)
                                                 OR ([Status] <> 'CheckedIn'
                                                        AND [CheckedInAt] IS NULL
                                                        AND [RodCheckinId] IS NULL)
                                                )
    );
    PRINT 'Created table: RodStaging';
END
ELSE
    PRINT 'Table already exists: RodStaging';
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
        -- The weld IS the payoff handover. Recording both positions makes it directly
        -- queryable instead of inferred by joining RodCheckin/RodStaging per rod alpha.
        [OutgoingPayoffPosition] INT          NULL,         -- bay the depleting rod is drawing from (1|2)
        [IncomingPayoffPosition] INT          NULL,         -- bay the staged rod occupies (1|2)
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
        CONSTRAINT [CK_WeldEvent_OutPayoff]    CHECK ([OutgoingPayoffPosition] IN (1,2) OR [OutgoingPayoffPosition] IS NULL),
        CONSTRAINT [CK_WeldEvent_InPayoff]     CHECK ([IncomingPayoffPosition] IN (1,2) OR [IncomingPayoffPosition] IS NULL),
        -- A weld joins two different bays; it cannot be a bay welded to itself.
        CONSTRAINT [CK_WeldEvent_PayoffDiff]   CHECK ([OutgoingPayoffPosition] IS NULL
                                                   OR [IncomingPayoffPosition] IS NULL
                                                   OR [OutgoingPayoffPosition] <> [IncomingPayoffPosition]),
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
        -- Aug-4-2026: FM2 is three stands — S1 (8"), S2 (6"), S3 (6", final). See CK_PSC_ComponentName.
        CONSTRAINT [CK_RollOverride_Component]    CHECK ([ComponentName] IN ('DB1','DB2','FM1','EdgeSet','FM2_S1','FM2_S2','FM2_S3')),
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
