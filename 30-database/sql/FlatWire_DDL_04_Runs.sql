-- ============================================================
-- Flat Wire Mill — DDL Script 04: Run Tracking Tables
-- Run order : 04 of 09
-- Tables    : FlatWireRunDetail, RodStaging, RodCheckin, SpoolCheckin, SpoolStaging,
--             RunPauseEvent, WeldEvent, RollOverride, DieChangeEvent,
--             RunReading, RodOrderConsumption   (11)
-- Dependencies: 03_Materials (FlatWireRun, Rod, SpoolProcessing), 02_Schedule (PassSchedule)
-- Note      : FlatWireRun itself is in 03_Materials so SpoolProcessing can
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
        -- G21. The PHYSICAL payoff station, written at staging time from the WIP-station
        -- map (CommonDB..WIPStations). FL1 and FL3 SHARE ONE physical VPS -- Dashboard 2A
        -- maps STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"} and only FL1PO is seeded; the
        -- client confirmed rods are never stacked, two maximum, one per payoff (Q71).
        --
        -- This column exists because UX_RodStaging_Bay CANNOT be keyed on LineId:
        -- CK_RodStaging_LineId admits BOTH FL1 and FL3, so (FL1,1) and (FL3,1) are distinct
        -- index entries for what is ONE bay -- two rods Staged on one physical position with
        -- every constraint satisfied. Worse, Q24 makes the station SWITCH LINE BY ITSELF
        -- when an order is booked on the other rod line (no message, no override), so LineId
        -- is a uniqueness key the application rewrites underneath itself.
        --
        -- LineId is RETAINED -- the queue projection, the off-schedule check and reporting
        -- all need it. It simply stops being the uniqueness key. See 07_Indexes.
        [Station]                 VARCHAR(10)   NOT NULL,   -- e.g. FL1PO; G21 uniqueness key
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
        -- FW-220 / FW-221 (19 Aug 2026). Did united_db.dbo.FlatWire_CheckInRod CREATE the
        -- proddb..wip_coil_orders row for this check-in, or find one already there?
        -- FlatWire_ReverseReqsum must know: a row that predates flat wire is not ours to delete
        -- at pre-check-out, and deleting it would remove an order claim we never made. The
        -- procedure returns this as an OUTPUT parameter and the caller persists it here.
        -- Defaults to 0 - the SAFE direction - so a missing value never authorises a delete.
        [WipCoilOrdersWritten]    BIT           NOT NULL CONSTRAINT [DF_RodCheckin_WipCoilOrdersWritten] DEFAULT (0),
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
-- RodCheckin.WipCoilOrdersWritten -- retro-fit for an EXISTING database.
--
-- ⚠ THE TABLE GUARD ABOVE IS `IF NOT EXISTS (... CREATE TABLE ...)`, SO A
--   COLUMN ADDED TO THE CREATE TABLE BODY NEVER REACHES A DATABASE THAT
--   ALREADY EXISTS. Tables and indexes are genuinely idempotent in this
--   runner; COLUMNS ARE NOT, and that gap is silent -- the deploy prints
--   "Table already exists" and moves on, and the missing column is only
--   discovered when something reads it.
--
--   Found by deploying, 19 Aug 2026: WipCoilOrdersWritten was absent from a
--   live FlatWireDB after a clean RunAll, while UX_FlatWireRun_ActiveLine
--   (added the same day, in 07_Indexes, which guards per index) was present.
--
--   FlatWire_ReverseReqsum reads this column to decide whether check-in
--   created the wip_coil_orders row it is being asked to delete. A missing
--   column there is not cosmetic.
--
--   The established repo answer is teardown-and-redeploy, which is correct
--   for a pre-production schema but leaves every intermediate database wrong.
--   This guarded ALTER costs nothing and makes the runner's own promise --
--   "every included script guards its objects" -- true for columns too.
-- ------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodCheckin]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[RodCheckin]') AND name = N'WipCoilOrdersWritten')
BEGIN
    ALTER TABLE [dbo].[RodCheckin]
        ADD [WipCoilOrdersWritten] BIT NOT NULL
            CONSTRAINT [DF_RodCheckin_WipCoilOrdersWritten] DEFAULT (0);
    PRINT 'Added column: RodCheckin.WipCoilOrdersWritten';
END
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
        [SpoolAlpha]       VARCHAR(20)   NOT NULL,           -- FK → SpoolProcessing.Alpha
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

-- ============================================================
-- FL2 PRE-CHECK-IN QUEUE  (added 22 Aug 2026)
--
-- FL2 now HAS pre-check-in (client, 20 Aug 2026): "to validate the next
-- spool and to eliminate the potential for downtime due to the fact
-- that they grabbed the wrong spool and then would find out at check-in
-- and then have to go and locate the correct one."
--
-- This REVERSES FR-031 ("shall not support pre-check-in on FL2"), a rule
-- asserted across eighteen documents including CK_RodStaging_LineId
-- below. The PHYSICAL premise of PCI002 is UNCHANGED -- FL2 still has
-- one traversing payoff and no floor space. What was asked for is
-- VALIDATION, not staging. A queued spool is validated, not staged.
-- ============================================================

-- ------------------------------------------------------------
-- SpoolStaging
-- The FL2 pre-check-in queue: what the operator has already validated,
-- in the order they intend to run it (client, 21 Aug 2026 -- drag and
-- drop to reorder, top of queue checked in by default).
--
-- WHY NOT RodStaging. That table is rod-shaped throughout: oxidation /
-- surface-defect / water-stain inspection columns that RocCheckin.md
-- 4.3 says are NOT PERFORMED on a spool ("the material was inspected at
-- FL1 before it was drawn and flattened"), plus IsWelded, UnstageKind,
-- two alternating bay states and PayoffPosition NOT NULL. Widening
-- CK_RodStaging_LineId to admit FL2 would add rows that cannot populate
-- half the table.
--
-- ONE ROW PER SPOOL, not per rod alpha. FL2 mounts a spool on a single
-- payoff, so one row is one physical fetch. A queue keyed on rod alphas
-- would put two rows against one welded spool, and reordering them
-- against each other is meaningless under last-on-first-off unwind.
--
-- NO PAYOFF POSITION -- FL2 has ONE payoff (client, 21 Aug 2026).
-- NO INSPECTION COLUMNS -- already inspected as rod at FL1.
-- NO STATION CLAIM -- the WIP station is claimed at CHECK-IN only
--   (client, 21 Aug 2026), consistent with FL1, where staging has been
--   barred from writing shared state since the 30 Jul "check-in only"
--   decision. So this table is entirely FlatWireDB-local: nothing in
--   CommonDB, proddb or united_db. That is what keeps the queue's
--   length unbounded -- had pre-check-in claimed the station,
--   WIPStations' UNIQUE index on CoilNo would permit exactly ONE
--   queued spool, and a queue of one is not a queue.
--
-- QueuePosition IS DELIBERATELY NOT UNIQUE. Drag-and-drop reorder swaps
-- positions, and a UNIQUE index rejects the transient duplicate
-- mid-swap -- a trap that does not surface until the SECOND reorder.
-- DECIMAL so a row can be inserted BETWEEN two others (position 1.5)
-- with no renumber at all.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolStaging]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolStaging] (
        [Id]              INT           NOT NULL IDENTITY(1,1),
        [SpoolAlpha]      VARCHAR(20)   NOT NULL,      -- FK -> SpoolProcessing.Alpha; the row's identity
        [LineId]          VARCHAR(5)    NOT NULL,      -- FL2 (FL3 permitted should it ever queue)
        [QueuePosition]   DECIMAL(9,3)  NOT NULL,      -- operator-ordered; lowest is checked in by default.
                                                       -- NOT unique, and fractional on purpose -- see above.
        [Status]          VARCHAR(20)   NOT NULL CONSTRAINT [DF_SpoolStaging_Status] DEFAULT ('Queued'),
        [PreCheckedInBy]  VARCHAR(50)   NOT NULL,      -- who validated it -- the audit the queue exists to provide
        [PreCheckedInAt]  DATETIMEOFFSET NOT NULL CONSTRAINT [DF_SpoolStaging_At] DEFAULT (SYSDATETIMEOFFSET()),
        [RemovedAt]       DATETIMEOFFSET NULL,         -- set when checked in, or withdrawn from the queue
        [RemovedReason]   VARCHAR(200)  NULL,
        [RowVersion]      ROWVERSION    NOT NULL,      -- optimistic concurrency: two terminals may reorder at once

        CONSTRAINT [PK_SpoolStaging]         PRIMARY KEY CLUSTERED ([Id] ASC),
        -- FL2 only today. FL3 is permitted because it shares FM2, but it
        -- creates no spool, so in practice it will not queue one.
        CONSTRAINT [CK_SpoolStaging_LineId]  CHECK ([LineId] IN ('FL2','FL3')),
        CONSTRAINT [CK_SpoolStaging_Status]  CHECK ([Status] IN ('Queued','CheckedIn','Withdrawn')),
        CONSTRAINT [CK_SpoolStaging_Pos]     CHECK ([QueuePosition] > 0),
        CONSTRAINT [CK_SpoolStaging_Removed] CHECK (([Status] = 'Queued' AND [RemovedAt] IS NULL)
                                                 OR ([Status] <> 'Queued' AND [RemovedAt] IS NOT NULL))
    );
    PRINT 'Created table: SpoolStaging';
END
ELSE
    PRINT 'Table already exists: SpoolStaging';
GO

-- ------------------------------------------------------------
-- SpoolCheckin -- retro-fit corrections for an EXISTING database.
-- Guarded ALTERs for the reason documented above RodCheckin's.
-- ------------------------------------------------------------

-- (1) OrderId -> NULLABLE.
-- A spool may carry SEVERAL orders (client, 20 Aug 2026) and FL2 makes
-- ONE at a time, so this column means "the order being made NOW",
-- selected from the spool's SpoolOrder set. It must also be nullable
-- because SpoolQueue.md rule SQ-6 states an UNALLOCATED spool "may
-- still be checked in" -- a planning remainder or a supervisor-accepted
-- partial legitimately has no order -- which the NOT NULL forbade.
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolCheckin]') AND type = N'U')
   AND EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[dbo].[SpoolCheckin]') AND name = N'OrderId' AND is_nullable = 0)
BEGIN
    ALTER TABLE [dbo].[SpoolCheckin] ALTER COLUMN [OrderId] VARCHAR(20) NULL;
    PRINT 'Altered column: SpoolCheckin.OrderId -> NULL (SQ-6, multi-order spool)';
END
GO

-- (2) Where THIS run began consuming the spool, in SPOOL-LOCAL feet.
-- Two FL2 runs (two orders) consume ONE spool from two DIFFERENT
-- starting points, so the offset is PER CHECK-IN, not per spool.
-- SpoolProcessing.RunStartFootageFt serves the rod->spool hop; this serves
-- spool->coil. With only the former, run 2's genealogy composes from
-- run 1's origin and every rod attribution in the second coil is wrong.
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolCheckin]') AND type = N'U')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID(N'[dbo].[SpoolCheckin]') AND name = N'SpoolStartFootageFt')
BEGIN
    ALTER TABLE [dbo].[SpoolCheckin] ADD [SpoolStartFootageFt] DECIMAL(10,2) NULL;
    PRINT 'Added column: SpoolCheckin.SpoolStartFootageFt';
END
GO

-- (3) PayoffPosition -- FL2 has ONE payoff (client, 21 Aug 2026).
-- CK_SpoolCheckin_PayoffPos permitted (1,2), copied from RodCheckin,
-- where the VPS genuinely has two bays. FL2's single traversing payoff
-- is what SpoolQueue.md rules SQ-8..SQ-10 (exclusive check-in) and the
-- filtered index UX_FlatWireRun_ActiveLine both rest on. The column is
-- kept -- one reference in the repository -- and constrained to 1.
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = N'CK_SpoolCheckin_PayoffPos')
   AND EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = N'CK_SpoolCheckin_PayoffPos' AND definition LIKE '%(2)%')
BEGIN
    ALTER TABLE [dbo].[SpoolCheckin] DROP CONSTRAINT [CK_SpoolCheckin_PayoffPos];
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [CK_SpoolCheckin_PayoffPos] CHECK ([PayoffPosition] = 1);
    PRINT 'Replaced constraint: CK_SpoolCheckin_PayoffPos -> = 1 (FL2 has one payoff)';
END
GO

------------------------------------------------------------
-- ROD <-> ORDER CONSUMPTION  (added 22 Aug 2026)
-- What was actually consumed per (rod, order) pairing, and the handoff
-- state machine that carries the order boundary.
------------------------------------------------------------

-- ------------------------------------------------------------
-- RodOrderConsumption
-- What was actually consumed against each (rod, order) pairing, and
-- the handoff state machine that carries the order boundary.
--
-- ONE CHECK-IN, N CONSUMPTION ROWS -- and that cardinality IS the
-- client's rule 7. A rod planned for two orders is checked in ONCE and
-- stays on the payoff across the boundary: the operator marks order 1
-- complete and starts order 2 on the same mount. No dismount, no
-- remount, no second check-in -- so RodCheckin is the parent and this
-- table is the child.
--
-- THE STATION IS THE EXCLUSIVITY KEY, NOT LineId. FL1 and FL3 share
-- ONE physical VPS (STATION_BY_LINE maps both to FL1PO), so keying on
-- LineId would admit (FL1,...) and (FL3,...) as distinct entries for
-- what is one payoff. Exactly the correction G21 forced on RodStaging;
-- LineId is retained for projection and reporting only.
--
-- TWO WEIGHT LATCHES, NOT ONE. LatchedWeightAtThresholdLb is captured
-- at the crossing instant and never re-read;
-- WeightAtAcknowledgementLb is captured when the operator confirms.
-- The OVERRUN is the difference, and the client requires it be
-- captured rather than discarded. Same rule as
-- FlatWireRun.PromptLatchedWeightLb: the weight AT that instant, never
-- a later drifted value.
--
-- THE ROW STATES ITS OWN CONVERSION. LbPerFtUsed + ConversionBasis +
-- ConverterVersion are persisted per row so a change to the
-- footage->weight formula NEVER retro-changes a historical record.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodOrderConsumption] (
        [Id]                          INT            NOT NULL IDENTITY(1,1),
        [ConsumptionId]               VARCHAR(20)    NOT NULL,   -- e.g. RC-0041; human key, as CheckoutId / RejectionId / CheckpointId
        [RunId]                       VARCHAR(20)    NOT NULL,   -- FK -> FlatWireRun.RunId
        [RodCheckinId]                INT            NOT NULL,   -- FK -> RodCheckin.Id; the mount this pairing runs on
        [Station]                     VARCHAR(10)    NOT NULL,   -- e.g. FL1PO; the exclusivity key (G21)
        [LineId]                      VARCHAR(5)     NOT NULL,   -- FL1|FL3; projection and reporting only
        [RodAlpha]                    VARCHAR(20)    NOT NULL,   -- FK -> Rod.Alpha
        [OrderNo]                     VARCHAR(50)    NOT NULL,   -- shared-schema order; NO FK by design
        [RelLetter]                   VARCHAR(10)    NULL,
        [AllocationId]                INT            NULL,       -- FK -> RodOrderAllocation.Id; NULL for a substitution made before the allocation row exists
        [AllocatedWeightLbSnapshot]   DECIMAL(8,2)   NULL,       -- SNAPSHOT, not a join -- re-planning must not retro-change what the floor was told
        [PlannedRodSeqNoSnapshot]     SMALLINT       NULL,       -- ditto; same pattern as RodStaging.PlannedSeqno
        [ActualRodSeqNo]              SMALLINT       NOT NULL,   -- the position this rod actually took in this order
        [State]                       VARCHAR(20)    NOT NULL,   -- Pending|InProgress|ThresholdReached|Closed|Voided
        [StartFootageFt]              DECIMAL(10,2)  NOT NULL,   -- RUN-CUMULATIVE anchor, captured live from the counter
        [EndFootageFt]                DECIMAL(10,2)  NULL,       -- run-cumulative at close
        [ConsumedFootageFt]           AS ([EndFootageFt] - [StartFootageFt]) PERSISTED,  -- the only footage arithmetic in the table
        [ThresholdFootageFt]          DECIMAL(10,2)  NULL,       -- computed ONCE at pairing start: remaining allocated weight -> feet at the running gauge, plus StartFootageFt
        [ThresholdReachedAt]          DATETIMEOFFSET NULL,       -- the crossing instant
        [LatchedWeightAtThresholdLb]  DECIMAL(8,2)   NULL,       -- latched AT the crossing; never a fresher tick
        [NotificationRaisedAt]        DATETIMEOFFSET NULL,       -- when OrderAllocationReached went out
        [AcknowledgedAt]              DATETIMEOFFSET NULL,       -- rule 9: the operator closes the order, not the system
        [AcknowledgedBy]              VARCHAR(50)    NULL,
        [WeightAtAcknowledgementLb]   DECIMAL(8,2)   NULL,       -- the SECOND latch
        [OverrunWeightLb]             AS ([WeightAtAcknowledgementLb] - [LatchedWeightAtThresholdLb]) PERSISTED,  -- + = overrun, - = early ack
        [VarianceVsAllocationLb]      AS ([WeightAtAcknowledgementLb] - [AllocatedWeightLbSnapshot]) PERSISTED,
        [ConsumedWeightLb]            DECIMAL(8,2)   NULL,       -- written at close, NOT computed -- the basis may be integration over RunReading
        [ConversionBasis]             VARCHAR(20)    NULL,       -- Nominal|Measured|IntegratedRunReading|Override (OI-45)
        [LbPerFtUsed]                 DECIMAL(10,6)  NULL,       -- the factor actually applied; a historical row is never recomputed
        [ConverterVersion]            VARCHAR(20)    NULL,       -- for a change of formula SHAPE rather than factor
        [ClosureReason]               VARCHAR(25)    NULL,       -- Acknowledged|AcknowledgedEarly|RodExhausted|RodAbandoned|Superseded
        [RodCheckoutId]               VARCHAR(20)    NULL,       -- FK -> RodCheckout.CheckoutId when closure is RodAbandoned (Mode B)
        [ShortfallWeightLb]           DECIMAL(8,2)   NULL,       -- set when the pairing closed below allocation because material ran out
        [OperatorId]                  VARCHAR(50)    NOT NULL,
        [CreatedAt]                   DATETIMEOFFSET NOT NULL
            CONSTRAINT [DF_RodOrderConsumption_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [ModifiedBy]                  VARCHAR(50)    NULL,
        [ModifiedAt]                  DATETIMEOFFSET NULL,
        [RowVersion]                  ROWVERSION     NOT NULL,   -- State and footage move live, as on FlatWireRun

        CONSTRAINT [PK_RodOrderConsumption]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_RodOrderConsumption_CId]     UNIQUE ([ConsumptionId]),
        -- One mount, one pairing per order.
        CONSTRAINT [UQ_RodOrderConsumption_Pair]    UNIQUE ([RodCheckinId], [OrderNo], [RelLetter]),
        CONSTRAINT [CK_RodOrderConsumption_State]   CHECK ([State] IN ('Pending','InProgress','ThresholdReached','Closed','Voided')),
        CONSTRAINT [CK_RodOrderConsumption_LineId]  CHECK ([LineId] IN ('FL1','FL3')),
        CONSTRAINT [CK_RodOrderConsumption_Closure] CHECK ([ClosureReason] IS NULL OR [ClosureReason] IN
                                                     ('Acknowledged','AcknowledgedEarly','RodExhausted','RodAbandoned','Superseded')),
        CONSTRAINT [CK_RodOrderConsumption_Footage] CHECK ([EndFootageFt] IS NULL OR [EndFootageFt] >= [StartFootageFt]),
        CONSTRAINT [CK_RodOrderConsumption_Seq]     CHECK ([ActualRodSeqNo] >= 1),
        -- The three acknowledgement stamps are all-or-nothing. Written with explicit
        -- IS NULL pairs, because "A IS NOT NULL AND B IS NOT NULL" evaluates to UNKNOWN
        -- when one side is NULL and a CHECK constraint ACCEPTS UNKNOWN -- the trap
        -- CK_AlloyProperty_RodDiaTol was fixed for.
        CONSTRAINT [CK_RodOrderConsumption_AckStamps] CHECK (
              ([AcknowledgedAt] IS NULL     AND [AcknowledgedBy] IS NULL     AND [WeightAtAcknowledgementLb] IS NULL)
           OR ([AcknowledgedAt] IS NOT NULL AND [AcknowledgedBy] IS NOT NULL AND [WeightAtAcknowledgementLb] IS NOT NULL)),
        -- An abandoned pairing must name the checkout that abandoned it. Same per-mode
        -- shape as CK_RodCheckout_ModeB.
        CONSTRAINT [CK_RodOrderConsumption_Abandon]  CHECK (
              [ClosureReason] <> 'RodAbandoned' OR [RodCheckoutId] IS NOT NULL)
    );
    PRINT 'Created table: RodOrderConsumption';
END
ELSE
    PRINT 'Table already exists: RodOrderConsumption';
GO
