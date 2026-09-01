-- ============================================================
-- Flat Wire Mill — Sample Data: Run Tracking Tables
-- Run order : after Materials seed (needs Rod, FlatWireRun, Spool)
-- Tables    : RodCheckin, RodStaging, SpoolCheckin, FlatWireRunDetail,
--             RunPauseEvent, WeldEvent, RollOverride,
--             DieChangeEvent, RunReading
-- ============================================================
-- Computed columns (SpcOvalityIn, Delta, PauseDurationSeconds)
-- are NOT inserted. Idempotent: each block guarded by IF NOT EXISTS.
-- ============================================================

USE [FlatWireDB]
GO

-- Required when writing tables that carry PERSISTED computed columns.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- RodCheckin  (SpcOvalityIn is computed from M1/M2 — omitted)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RodCheckin])
INSERT INTO [dbo].[RodCheckin]
    ([RunId],[LineId],[RodAlpha],[PayoffPosition],[DiameterMeasuredIn],[GrossWeightLb],[NetWeightLb],
     [PassScheduleId],[OrderId],[ScrapBoxRef],[MmsId],[MmsStatus],[OperatorId],[CheckedInAt],[PlcTagsPushed],
     [InspectionOxidation],[InspectionSurfaceDefects],[InspectionWaterStains],[InspectionConnectorTag],[InspectionNotes],[SpcM1In],[SpcM2In])
VALUES
    ('RUN-0001','FL1','R00041',1,0.3752,9000.00,8950.00,'PS-1100-FL1-001','FW-00421','SB-1100-A','MMS-0001',  'Closed','Dave M.', '2026-07-20 06:30:00 -05:00',1,'Pass','Pass','Pass','Pass','Clean rod',        0.3752,0.3748),
    ('RUN-0001','FL1','R00042',2,0.3751,9000.00,8955.00,'PS-1100-FL1-001','FW-00421','SB-1100-A','MMS-0001-2','Closed','Dave M.', '2026-07-20 06:34:00 -05:00',1,'Pass','Pass','Pass','Pass','Weld partner',      0.3751,0.3749),
    ('RUN-0002','FL3','R00045',1,0.3753,9000.00,8970.00,'PS-1100-FL3-001','FW-00600','SB-1100-A','MMS-0002',  'Closed','Linda K.','2026-07-20 10:00:00 -05:00',1,'Pass','Pass','Pass','Pass',NULL,              0.3753,0.3750),
    ('RUN-0003','FL1','R00043',1,0.3750,8800.00,8760.00,'PS-3003-FL1-001','FW-00500','SB-3003-A','MMS-0003',  'Closed','Dave M.', '2026-07-21 06:30:00 -05:00',1,'Pass','Pass','Pass','Pass',NULL,              0.3750,0.3749),
    ('RUN-0005','FL1','R00046',1,0.3749,8600.00,8560.00,'PS-5052-FL1-001','FW-00700','SB-5052-A','MMS-0005',  'Active','Marcus T.','2026-07-22 06:30:00 -05:00',1,'Pass','Pass','Pass','Pass','Strain-hardened',0.3749,0.3747);
GO

-- ============================================================
-- RodStaging  (pre-check-in — seeded after RodCheckin because the
-- CheckedIn row links back to a RodCheckin.Id)
-- Exercises all three statuses, the welded stamp (WLD010) and the
-- carry-forward field (PRC007). Only ONE row may be 'Staged' per
-- (Station, PayoffPosition) — enforced by UX_RodStaging_Bay.  FL1 and FL3 share
-- one physical station (FL1PO), which is why the key is Station and not LineId (G21).
--
-- Also exercises the two sequences. Planned order is NOT enforced, so
-- RodSeqno (actual staging order) and PlannedSeqno (what planning
-- intended) are free to differ — and here they deliberately do:
--   R00041  run 1, plan 1  — in planned order
--   R00044  run 4, plan 2  — run late, deviation
--   R00048  run 5, plan 3  — run late, then un-staged (pre-check-out)
--   R00047  run 6, plan 4  — failed inspection: the derived BLOCKED bay
-- A row with PlannedSeqno NULL would represent a substitution with no
-- planned position; none is seeded, but the column allows it.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RodStaging])
INSERT INTO [dbo].[RodStaging]
    ([LineId],[Station],[PayoffPosition],[RodAlpha],[RodSeqno],[PlannedSeqno],[IsWelded],[Status],[OrderId],[ScrapBoxRef],
     [DiameterIn],[GrossWeightLb],[NetWeightLb],[FootageRunToDateAtStaging],
     [InspectionOxidation],[InspectionSurfaceDefects],[InspectionWaterStains],[InspectionNotes],
     [StagedAt],[StagedBy],[WeldedAt],[WeldedBy],[CheckedInAt],[RodCheckinId],
     [UnstagedAt],[UnstagedBy],[UnstageReasonCode],[UnstageKind],[WipRejectionId])
VALUES
    -- Consumed by check-in: staged, then acknowledged on Dashboard 2.
    ('FL1','FL1PO',1,'R00041',1,1,0,'CheckedIn','FW-00421','SB-1100-A',
     0.3750,9000.00,8950.00,0.00,
     'Pass','Pass','Pass','Staged from floor storage',
     '2026-07-20 06:18:00 -05:00','Dave M.',NULL,NULL,
     '2026-07-20 06:30:00 -05:00',
     (SELECT [Id] FROM [dbo].[RodCheckin] WHERE [RunId] = 'RUN-0001' AND [RodAlpha] = 'R00041'),
     NULL,NULL,NULL,NULL,NULL),

    -- Welded to the running rod IN ERROR, then released by a Mode P pre-check-out.
    -- This is the UnstageKind='PreCheckOut' path, and it is the one fixture that
    -- exercises it. It pairs with RodCheckout CO-0003 (same rod, same bay, same
    -- 07:55 instant) and with Rod.Status='HOLD' in the Materials seed -- all three
    -- used to disagree: this row said Staged while CO-0003 said the rod had been
    -- removed and put on HOLD.
    -- FootageRunToDateAtStaging > 0 means this was a forced carry-forward scan.
    ('FL1','FL1PO',2,'R00044',4,2,1,'Unstaged','FW-00500','SB-3003-A',
     0.3750,8800.00,8765.00,1600.00,
     'Pass','Pass','Pass','Partial rod returned from RUN-0003; carry-forward acknowledged',
     '2026-07-22 07:05:00 -05:00','Marcus T.',
     '2026-07-22 07:41:00 -05:00','Marcus T.',
     NULL,NULL,
     '2026-07-22 07:55:00 -05:00','Marcus T.','WrongRodWelded','PreCheckOut',NULL),

    -- BLOCKED bay: staged, inspection FAILED, still physically on the payoff.
    -- Blocked is DERIVED (Status='Staged' + any inspection column='Fail'), not a fourth
    -- Status value (Q23 items 1-2). The bundle is not unbanded until it is positioned at
    -- the payoff, so a rod that fails inspection is already in the bay and must keep it
    -- occupied -- which is why the row is committed BEFORE the inspection gate.
    -- It is released by a WIP rejection, which captures the reason and puts the rod on
    -- HOLD (Q23 item 3, decided 30 Jul 2026): Status->'Unstaged', UnstageKind->
    -- 'WipRejection', WipRejectionId->the rejection. Left blocked here on purpose so the
    -- BLOCKED bay state is reachable in seeded data; REJ-0001 in the QualityOutput sample
    -- is that rod's rejection, and applying it is what frees the bay.
    ('FL1','FL1PO',1,'R00047',6,4,0,'Staged','FW-00421',NULL,
     0.3750,9000.00,8952.00,0.00,
     'Fail','Pass','Pass','Heavy oxidation on OD -- routed to WIP Rejection, no bypass (CHK010)',
     '2026-07-22 09:10:00 -05:00','Marcus T.',NULL,NULL,
     NULL,NULL,NULL,NULL,NULL,NULL,NULL),

    -- Pre-checked-in in error, then un-staged (Mode P) and returned to the warehouse.
    ('FL3','FL1PO',2,'R00048',5,3,0,'Unstaged','FW-00600',NULL,
     0.3750,8500.00,8470.00,0.00,
     'Pass','Pass','Pass','Wrong bundle brought to the payoff',
     '2026-07-22 08:02:00 -05:00','Linda K.',NULL,NULL,
     NULL,NULL,
     '2026-07-22 08:19:00 -05:00','Linda K.','WrongRodMisScan','PreCheckOut',NULL);
GO

-- ============================================================
-- SpoolCheckin  (FL2 finisher consuming SP-00031)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolCheckin])
INSERT INTO [dbo].[SpoolCheckin]
    ([RunId],[LineId],[SpoolAlpha],[PayoffPosition],[GaugeIn],[WidthIn],[GrossWeightLb],[NetWeightLb],
     [PassScheduleId],[OrderId],[MmsId],[MmsStatus],[OperatorId],[CheckedInAt],[PlcTagsPushed],[InspectionSurface],[InspectionNotes])
VALUES
    ('RUN-0004','FL2','SP-00031',1,0.0970,0.7500,3400.00,3385.00,'PS-1100-FL2-001','FW-00500','MMS-0004','Active','Linda K.','2026-07-21 10:00:00 -05:00',1,'Pass','Scanned FL1 spool label; specs verified');
GO

-- ============================================================
-- FlatWireRunDetail  (per-stop detail)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[FlatWireRunDetail])
INSERT INTO [dbo].[FlatWireRunDetail]
    ([RunId],[SetupNo],[StopNo],[SequenceNo],[PlanId],[CoilOrderPlanId],[HomeMfgOrderNo],[PayoffPositionId],[FootageFt],
     [OnGaugeWeight],[TargetGauge],[GaugeTolerance],[TargetWidth],[WidthTolerance],[StartGauge],[ExitGauge],[OutputOD],[OutputID])
VALUES
    ('RUN-0001','FLS-2024-001',1,1,NULL,NULL,'FW-00421',1,4200.00,289.80,0.1100,0.0020,0.5000,0.0050,0.1105,0.1100,36.0000,8.0000),
    ('RUN-0003','FLS-2024-028',1,1,NULL,NULL,'FW-00500',1,3200.00,3385.00,0.0950,0.0030,0.7500,0.0080,0.0970,0.0950,30.0000,10.0000);
GO

-- ============================================================
-- RunPauseEvent  (PauseDurationSeconds is computed — omitted)
--   RUN-0001 = closed (ResumeRun) · RUN-0004 = OPEN · RUN-0005 = Other+Notes (CheckOutRod)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RunPauseEvent])
INSERT INTO [dbo].[RunPauseEvent]
    ([RunId],[PausedAt],[FootageAtPause],[ReasonCode],[ReasonCategory],[Notes],[ResumedAt],[Outcome],[ActivityCompleted],[OperatorId],[ResumedBy])
VALUES
    ('RUN-0001','2026-07-20 07:45:00 -05:00',2100,'GaugeWidthInvestigation','QualityMeasurement',NULL,                              '2026-07-20 07:58:00 -05:00','ResumeRun', 'Verified gauge within tolerance','Dave M.', 'Dave M.'),
    ('RUN-0004','2026-07-21 11:20:00 -05:00',1850,'DieChange',             'Maintenance',        NULL,                              NULL,                        NULL,        NULL,                            'Linda K.',NULL),
    ('RUN-0005','2026-07-22 07:00:00 -05:00', 900,'EquipmentFailure',      'Other',              'Bearing fault on FM1 drive gearbox','2026-07-22 07:10:00 -05:00','CheckOutRod','Rod checked out; run aborted',   'Marcus T.','Marcus T.');
GO

-- ============================================================
-- WeldEvent  (fail row carries a required fail reason)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[WeldEvent])
INSERT INTO [dbo].[WeldEvent]
    ([WeldEventId],[RunId],[LineId],[OutgoingRodAlpha],[IncomingRodAlpha],[FootagePosition],[WeldType],[WeldQuality],[WeldQualityFailReason],[OperatorId],[Timestamp])
VALUES
    ('WLD-001','RUN-0001','FL1','R00041','R00042',2100,'InductionWeld','Pass',NULL,                   'Dave M.', '2026-07-20 08:05:00 -05:00'),
    ('WLD-002','RUN-0003','FL1','R00043','R00044',1600,'InductionWeld','Pass',NULL,                   'Dave M.', '2026-07-21 07:40:00 -05:00'),
    ('WLD-003','RUN-0002','FL3','R00045','R00042',1900,'InductionWeld','Fail','Weld not fully fused',  'Linda K.','2026-07-20 11:05:00 -05:00');
GO

-- ============================================================
-- RollOverride  (Delta is computed — omitted)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RollOverride])
INSERT INTO [dbo].[RollOverride]
    ([OverrideId],[RunId],[LineId],[RodAlpha],[FootagePosition],[ComponentName],[OldValue],[NewValue],[ReasonCode],[Notes],[MeasuredGaugeIn],[MeasuredWidthIn],[PlcTagWritten],[OperatorId],[Timestamp])
VALUES
    ('OVR-0001','RUN-0001','FL1','R00041',1500,'FM1',0.1080,0.1085,'GaugeDriftLow','Nudged FM1 gap up',       0.1094,0.5010,1,'Dave M.','2026-07-20 07:20:00 -05:00'),
    ('OVR-0002','RUN-0003','FL1','R00043',1200,'DB2',0.3000,0.2980,'SpcFlag',      'Die wear correction',     0.2996,NULL,  1,'Dave M.','2026-07-21 07:15:00 -05:00');
GO

-- ============================================================
-- DieChangeEvent  (links the auto-created RollOverride)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[DieChangeEvent])
INSERT INTO [dbo].[DieChangeEvent]
    ([DieChangeId],[RunId],[LineId],[RodAlpha],[FootagePosition],[DiePosition],[OldDieSizeIn],[NewDieSizeIn],[ReasonCode],[LinkedOverrideId],[SpcCheckpointRequired],[OperatorId],[Timestamp])
VALUES
    ('DC-0001','RUN-0003','FL1','R00043',1200,'DB2',0.3000,0.2980,'GaugeDrift','OVR-0002',1,'Dave M.','2026-07-21 07:16:00 -05:00');
GO

-- ============================================================
-- RunReading  (sampled gauge/width/speed profile per run)
--   One row intentionally out-of-spec on RUN-0001 (footage 1800).
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RunReading])
INSERT INTO [dbo].[RunReading]
    ([RunId],[FootageFt],[GaugeIn],[WidthIn],[SpeedFpm],[InSpec],[ReadingTs])
VALUES
    ('RUN-0001',   0.00,0.1101,0.5002,1180.0,1,'2026-07-20 06:36:00'),
    ('RUN-0001', 600.00,0.1103,0.5005,1210.0,1,'2026-07-20 06:52:00'),
    ('RUN-0001',1200.00,0.1108,0.4998,1225.0,1,'2026-07-20 07:08:00'),
    ('RUN-0001',1800.00,0.1135,0.5006,1230.0,0,'2026-07-20 07:24:00'),
    ('RUN-0001',2400.00,0.1104,0.5001,1220.0,1,'2026-07-20 08:12:00'),
    ('RUN-0001',3000.00,0.1099,0.4997,1215.0,1,'2026-07-20 08:34:00'),
    ('RUN-0001',3600.00,0.1102,0.5003,1218.0,1,'2026-07-20 09:05:00'),
    ('RUN-0001',4200.00,0.1100,0.5000,1200.0,1,'2026-07-20 09:44:00'),
    ('RUN-0002',   0.00,0.0852,0.7998,1400.0,1,'2026-07-20 10:06:00'),
    ('RUN-0002',1000.00,0.0851,0.8003,1440.0,1,'2026-07-20 10:44:00'),
    ('RUN-0002',2000.00,0.0849,0.7996,1455.0,1,'2026-07-20 11:22:00'),
    ('RUN-0002',3800.00,0.0850,0.8000,1420.0,1,'2026-07-20 12:29:00'),
    ('RUN-0004',   0.00,0.0902,0.6498,1600.0,1,'2026-07-21 10:06:00'),
    ('RUN-0004', 900.00,0.0901,0.6503,1640.0,1,'2026-07-21 10:52:00'),
    ('RUN-0004',1850.00,0.0900,0.6500,1610.0,1,'2026-07-21 11:19:00');
GO

-- ============================================================
-- SpoolTraceability.WeldEventId -- deferred from the Materials seed
-- ============================================================
-- The row exists already (Materials seed); only the weld link is applied here,
-- because FK_SpoolTraceability_WeldEvent needs WeldEvent, which is seeded above
-- in THIS file. WLD-002 is the induction weld that joined R00044 to R00043 on
-- RUN-0003, which is exactly the join SP-00031's second segment records.
-- ============================================================
IF EXISTS (SELECT 1 FROM [dbo].[WeldEvent] WHERE [WeldEventId] = 'WLD-002')
BEGIN
    UPDATE [dbo].[SpoolTraceability]
       SET [WeldEventId] = 'WLD-002'
     WHERE [SpoolAlpha] = 'SP-00031' AND [SeqNo] = 2 AND [WeldEventId] IS NULL;
    PRINT 'Seeded: SpoolTraceability.WeldEventId for SP-00031 segment 2 (WLD-002)';
END
GO

-- ============================================================
-- SpoolStaging -- the FL2 pre-check-in queue
-- ============================================================
-- QueuePosition is DECIMAL(9,3) and NOT unique on purpose: 20.500 sits between
-- 10 and 30 without renumbering, which is what a drag-and-drop reorder needs.
-- SP-00031 is already CheckedIn, so its RemovedAt is set -- CK_SpoolStaging_Removed
-- requires that pairing. UX_SpoolStaging_LiveSpool is filtered on Status='Queued',
-- which is what lets a spool re-enter the queue after check-in.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolStaging])
INSERT INTO [dbo].[SpoolStaging]
    ([SpoolAlpha],[LineId],[QueuePosition],[Status],[PreCheckedInBy],[PreCheckedInAt],[RemovedAt],[RemovedReason])
VALUES
    ('SP-00031','FL2',10.000,'CheckedIn','Linda K.','2026-07-21 09:20:00 -05:00','2026-07-21 09:40:00 -05:00','Checked in to RUN-0004'),
    ('SP-00032','FL2',20.500,'Queued',   'Linda K.','2026-07-21 09:25:00 -05:00',NULL,NULL),
    ('SP-00033','FL2',30.000,'Queued',   'Marcus T.','2026-07-22 07:20:00 -05:00',NULL,NULL);
GO
PRINT 'Seeded: SpoolStaging (3 rows -- fractional QueuePosition exercised)';
GO

-- ============================================================
-- RodOrderConsumption -- the ACTUAL
-- ============================================================
-- One check-in, N consumption rows -- the client's rule 7. R00043's mount on
-- RUN-0003 ran BOTH its allocated orders without a second check-in, which is
-- why FlatWireRun.OrderId narrows to "the order at check-in" (OI-123 / G47).
--
-- !! RodCheckoutId IS NULL ON EVERY ROW HERE, AND IT MUST BE.
--    FK_RodOrderConsumption_Checkout points at RodCheckout, which is created in
--    05_QualityOutput and seeded in FlatWire_SampleData_QualityOutput.sql -- and
--    that seed runs AFTER this one. Setting it here fails the FK. A Mode B
--    abandonment fixture therefore has to be an UPDATE in the QualityOutput
--    seed, not an INSERT here. The column is nullable, so this is legal, and
--    C5-OK: RodOrderConsumption.RodCheckoutId -- asserted NULL at insert; see above.
--    ClosureReason is not 'RodAbandoned' on any of these rows, so
--    CK_RodOrderConsumption_Abandon is satisfied.
--
-- The two weight latches differ on RC-0002 by design: 5050 - 5000 = 50 lb of
-- overrun between threshold and acknowledgement. That is real production to be
-- attributed, not an error -- OverrunWeightLb computes it.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RodOrderConsumption])
INSERT INTO [dbo].[RodOrderConsumption]
    ([ConsumptionId],[RunId],[RodCheckinId],[Station],[LineId],[RodAlpha],[OrderNo],[RelLetter],
     [AllocationId],[AllocatedWeightLbSnapshot],[PlannedRodSeqNoSnapshot],[ActualRodSeqNo],[State],
     [StartFootageFt],[EndFootageFt],[ThresholdFootageFt],[ThresholdReachedAt],
     [LatchedWeightAtThresholdLb],[NotificationRaisedAt],[AcknowledgedAt],[AcknowledgedBy],
     [WeightAtAcknowledgementLb],[ConsumedWeightLb],[ConversionBasis],[LbPerFtUsed],[ConverterVersion],
     [ClosureReason],[RodCheckoutId],[ShortfallWeightLb],[OperatorId])
SELECT
    v.[ConsumptionId],v.[RunId],rc.[Id],v.[Station],v.[LineId],v.[RodAlpha],v.[OrderNo],v.[RelLetter],
    ra.[Id],v.[AllocSnap],v.[PlannedSeq],v.[ActualSeq],v.[State],
    v.[StartFt],v.[EndFt],v.[ThreshFt],v.[ThreshAt],
    v.[LatchLb],v.[NotifAt],v.[AckAt],v.[AckBy],
    v.[AckLb],v.[ConsumedLb],v.[Basis],v.[LbPerFt],v.[ConvVer],
    v.[Closure],NULL,v.[Shortfall],v.[OperatorId]
FROM (VALUES
    ('RC-0001','RUN-0001','FL1PO','FL1','R00041','FW-00421','A',8950.00,1,1,'Closed',
        0.00,2100.00,2100.00,'2026-07-20 09:40:00 -05:00',
        8950.00,'2026-07-20 09:40:00 -05:00','2026-07-20 09:45:00 -05:00','Dave M.',
        8950.00,8950.00,'Nominal',4.261905,'v1','Acknowledged',NULL,'Dave M.'),
    ('RC-0002','RUN-0003','FL1PO','FL1','R00043','FW-00500','A',5000.00,1,1,'Closed',
        0.00,1150.00,1140.00,'2026-07-21 07:20:00 -05:00',
        5000.00,'2026-07-21 07:20:00 -05:00','2026-07-21 07:26:00 -05:00','Dave M.',
        5050.00,5050.00,'Measured',4.385965,'v1','Acknowledged',NULL,'Dave M.'),
    ('RC-0003','RUN-0003','FL1PO','FL1','R00043','FW-00700','A',3760.00,1,1,'InProgress',
        1150.00,NULL,2010.00,NULL,
        NULL,NULL,NULL,NULL,
        NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Dave M.')
) AS v([ConsumptionId],[RunId],[Station],[LineId],[RodAlpha],[OrderNo],[RelLetter],[AllocSnap],
       [PlannedSeq],[ActualSeq],[State],[StartFt],[EndFt],[ThreshFt],[ThreshAt],[LatchLb],[NotifAt],
       [AckAt],[AckBy],[AckLb],[ConsumedLb],[Basis],[LbPerFt],[ConvVer],[Closure],[Shortfall],[OperatorId])
JOIN [dbo].[RodCheckin] rc
  ON rc.[RunId] = v.[RunId] AND rc.[RodAlpha] = v.[RodAlpha]
LEFT JOIN [dbo].[RodOrderAllocation] ra
  ON ra.[RodAlpha] = v.[RodAlpha] AND ra.[OrderNo] = v.[OrderNo] AND ra.[IsActive] = 1;
GO
PRINT 'Seeded: RodOrderConsumption (3 rows -- R00043 runs two orders on one mount)';
GO
