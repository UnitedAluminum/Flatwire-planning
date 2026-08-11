-- ============================================================
-- Flat Wire Mill — Sample Data: Quality Control & Output Tables
-- Run order : after Runs seed (needs FlatWireRun, Rod)
-- Tables    : SpcCheckpoint, SpcMeasurement, WipRejection,
--             CoilOutput, CoilTraceability, RodCheckout
-- ============================================================
-- Computed columns (SpcMeasurement.Deviation/InSpec) and
-- ROWVERSION (CoilOutput.RowVersion) are NOT inserted.
-- CoilTraceability ranges are non-overlapping per coil (trigger).
-- Idempotent: each block guarded by IF NOT EXISTS.
-- ============================================================

USE [FlatWireDB]
GO

-- Required when writing tables that carry PERSISTED computed columns.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- SpcCheckpoint
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpcCheckpoint])
INSERT INTO [dbo].[SpcCheckpoint]
    ([CheckpointId],[RunId],[LineId],[CheckpointType],[FootagePosition],[OperatorId],[TriggerDescription],[AllInSpec],[Timestamp])
VALUES
    ('SPC-0001','RUN-0001','FL1','PreRun',           0,'Dave M.','Pre-run rod diameter check',              1,'2026-07-20 06:31:00 -05:00'),
    ('SPC-0002','RUN-0001','FL1','PostRun',       4200,'Dave M.','Final QC at run completion',              1,'2026-07-20 09:44:00 -05:00'),
    ('SPC-0003','RUN-0003','FL1','PostDieChange', 1200,'Dave M.','DB2 die changed 0.300 -> 0.298',          0,'2026-07-21 07:18:00 -05:00');
GO

-- ============================================================
-- SpcMeasurement  (Deviation + InSpec are computed — omitted)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpcMeasurement])
INSERT INTO [dbo].[SpcMeasurement]
    ([CheckpointId],[Name],[TargetValue],[ToleranceValue],[ActualValue])
VALUES
    ('SPC-0001','WireDiameter',        0.3750,0.0100,0.3752),   -- in spec
    ('SPC-0002','FinalGauge',          0.1100,0.0020,0.1108),   -- in spec
    ('SPC-0002','FinalWidth',          0.5000,0.0050,0.5010),   -- in spec
    ('SPC-0003','WireDiameterPostDraw',0.2980,0.0020,0.3005),   -- OUT of spec (dev 0.0025 > 0.0020)
    ('SPC-0003','FM1Gauge',            0.0950,0.0030,0.0952);   -- in spec
GO

-- ============================================================
-- WipRejection  (pre-run hold + mid-run process hold)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[WipRejection])
INSERT INTO [dbo].[WipRejection]
    ([RejectionId],[RunId],[LineId],[MaterialAlpha],[Stage],[FootagePosition],[RejectionGroup],[RejectionReason],
     [MeasuredValue],[TargetMin],[TargetMax],[Disposition],[ObservationNotes],[NewMaterialStatus],[OperatorId],[Timestamp])
VALUES
    ('REJ-0001',NULL,      'FL1','R00047','FL1Incoming',  NULL,'SurfaceQuality','Oxidation',    NULL,  NULL,  NULL,  'Suspend','Heavy oxidation on OD',            'HOLD','QA-Ann',  '2026-07-18 09:30:00 -05:00'),
    ('REJ-0002','RUN-0005','FL1','R00046','FL1ActiveRun',  900,'Process',       'ComponentFault',NULL,  NULL,  NULL,  'Suspend','FM1 bearing fault; material held','HOLD','Marcus T.','2026-07-22 07:05:00 -05:00');
GO

-- ============================================================
-- CoilOutput  (ROWVERSION omitted; two coils on skid SK-00201)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[CoilOutput])
INSERT INTO [dbo].[CoilOutput]
    ([CoilAlpha],[RunId],[LineId],[OrderId],[GrossWeightLb],[NetWeightLb],[NetWeightOverrideLb],[ScaleWeightLb],
     [FinalGaugeIn],[FinalWidthIn],[FootageFt],[PassScheduleId],[PassScheduleSnapshot],[SkidId],[SkidStatus],[StagingLocation],
     [Status],[GaugeInSpec],[WidthInSpec],[CompletedAt],[OperatorId],[CreatedBy])
VALUES
    ('FW-00421-C01','RUN-0001','FL1','FW-00421',300.00,289.80,NULL,301.50,0.1100,0.5000,4200.00,'PS-1100-FL1-001',
     '{"scheduleId":"PS-1100-FL1-001","targetGauge":0.110,"targetWidth":0.500,"route":"Standalone"}','SK-00201','Closed','A-3','COMPLETE',1,1,'2026-07-20 09:45:00 -05:00','Dave M.','Dave M.'),
    ('FW-00600-C01','RUN-0002','FL3','FW-00600',262.00,253.50,NULL,264.00,0.0850,0.8000,3800.00,'PS-1100-FL3-001',
     '{"scheduleId":"PS-1100-FL3-001","targetGauge":0.085,"targetWidth":0.800,"route":"Hybrid"}','SK-00201','Closed','A-3','COMPLETE',1,1,'2026-07-20 12:30:00 -05:00','Linda K.','Linda K.');
GO

-- ============================================================
-- CoilTraceability  (footage genealogy; non-overlapping per coil)
--
-- SpoolAlpha is NULL on every row here, and that is correct rather than a
-- gap in the fixture: both seeded coils come from ROD-FED runs. RUN-0001 is
-- FL1 Standalone, and RUN-0002 is FL3 fed directly from rod R00045 (see the
-- RodCheckin seed) -- neither has an input spool to name.
--
-- KNOWN FIXTURE LIMITATION: the spool-fed case is therefore not exercised.
-- The only run that consumes a spool, RUN-0004 (FL2, SP-00031), is still
-- 'Paused' and has produced no coil. Completing it to demonstrate the column
-- would mean rewriting the run/pause fixtures, so it is left alone -- add a
-- spool-fed coil here when RUN-0004 gains a completed output.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[CoilTraceability])
INSERT INTO [dbo].[CoilTraceability]
    ([CoilAlpha],[RodAlpha],[SpoolAlpha],[FootageFrom],[FootageTo])
VALUES
    ('FW-00421-C01','R00041',NULL,   0,2100),
    ('FW-00421-C01','R00042',NULL,2100,4200),
    ('FW-00600-C01','R00045',NULL,   0,3800);
GO

-- ============================================================
-- RodCheckout  (Mode A pre-run return + Mode B mid-run partial
--               + Mode P welded pre-check-out)
-- Supervisor approval is now PERSISTED (gap G24, columns added 1 Aug 2026).
-- Mode B requires it per OQ-48 and Mode P requires it when the rod was welded
-- per OQ-68; Mode A does not. The PIN is never stored -- only the badge/ID.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RodCheckout])
INSERT INTO [dbo].[RodCheckout]
    ([CheckoutId],[RunId],[LineId],[RodAlpha],[PayoffPosition],[Mode],[FootageAtCheckout],[ReasonCode],[RodDisposition],
     [RemainingWeightLbEstimate],[InProcessMaterialDisposition],[PartialSpoolAlpha],[NewRodStatus],[PlcTagsCleared],
     [WasWelded],[ApprovedBy],[ApprovedAt],[OverrideReason],[OperatorId],[Timestamp])
VALUES
    -- Mode A: post-acknowledgement, zero footage. No approval required.
    ('CO-0001',NULL,      'FL1','R00048',1,'ModeA',  0,'WrongRod',        'ReturnToWarehouse',  NULL,   NULL,               NULL,      'RECEIVED',1,
     0,NULL,NULL,NULL,'Marcus T.','2026-07-19 08:20:00 -05:00'),
    -- Mode B: mid-run, footage produced. Supervisor approval required (OQ-48).
    ('CO-0002','RUN-0005','FL1','R00046',1,'ModeB',900,'EquipmentFailure','HoldReturnToStorage',4200.00,'AcceptAsPartialRun','SP-00033','HOLD',    1,
     0,'S. Kowalski','2026-07-22 07:10:00 -05:00','FM1 bearing fault; partial run accepted as SP-00033','Marcus T.','2026-07-22 07:12:00 -05:00'),
    -- Mode P: pre-check-out of a WELDED staged rod. Removal means cutting the material, so
    -- this is a rejection, not a return -- supervisor approval, documented reason, HOLD
    -- (OQ-68 / OQ-77, decided 30 Jul 2026). An UNWELDED pre-check-out needs none of that.
    ('CO-0003',NULL,      'FL1','R00044',2,'ModeP',  0,'WrongRodWelded',  'HoldReturnToStorage',4300.00,NULL,               NULL,      'HOLD',    0,
     1,'S. Kowalski','2026-07-22 07:52:00 -05:00','Welded to the running rod in error; cut back and held for disposition','Marcus T.','2026-07-22 07:55:00 -05:00');
GO
