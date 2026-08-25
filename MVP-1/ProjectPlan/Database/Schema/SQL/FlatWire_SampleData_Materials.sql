-- ============================================================
-- Flat Wire Mill — Sample Data: Material Tables
-- Run order : after DDL 06, and after Lookup + Schedule seeds
-- Tables    : Rod, FlatWireRun, SpoolProcessing
-- ============================================================
-- Coherent demo dataset (8 rods, 5 runs, 3 spools):
--   RUN-0001  FL1 Standalone 1100  -> coil FW-00421-C01   (R00041 + welded R00042)
--   RUN-0002  FL3 Hybrid     1100  -> coil FW-00600-C01   (R00045; continuous, no spool)
--   RUN-0003  FL1 Hybrid     3003  -> spool SP-00031/32   (R00043 + R00044)
--   RUN-0004  FL2            1100  -> finisher, consumes SP-00031  (Paused)
--   RUN-0005  FL1 Standalone 5052  -> aborted; R00046 checked out mid-run -> partial SP-00033
--
-- Computed columns (Rod.TareWeightLb) and ROWVERSION are NOT inserted.
-- Idempotent: each block guarded by IF NOT EXISTS.
-- ============================================================

USE [FlatWireDB]
GO

-- Required when writing tables that carry PERSISTED computed columns.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- Rod
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rod])
INSERT INTO [dbo].[Rod]
    ([Alpha],[Alloy],[Temper],[DiameterIn],[GrossWeightLb],[NetWeightLb],[SupplierHeat],[InventoryType],
     [Status],[Location],[FootageRunToDate],[RemainingWeightEstimateLb],[ReceivedAt],[CreatedBy])
VALUES
    ('R00041','1100','H19',0.3750,9000.00,8950.00,'HT-1100-2451','RawRod','COMPLETE','FL1 Payoff 1',2100.00,   0.00,'2026-07-15 07:10:00 -05:00','recv-op'),
    ('R00042','1100','H19',0.3750,9000.00,8955.00,'HT-1100-2452','RawRod','COMPLETE','FL1 Payoff 2',2100.00,4700.00,'2026-07-15 07:20:00 -05:00','recv-op'),
    ('R00043','3003','H18',0.3750,8800.00,8760.00,'HT-3003-3310','RawRod','COMPLETE','FL1 Payoff 1',1600.00,   0.00,'2026-07-16 06:40:00 -05:00','recv-op'),
    -- HOLD, not STAGED: CO-0003 is a Mode P pre-check-out of this rod at 07:55 on
    -- 22 Jul (welded in error, cut back, held for disposition), and RodStaging
    -- releases the bay at the same instant. The three fixtures now agree.
    ('R00044','3003','H18',0.3750,8800.00,8765.00,'HT-3003-3311','RawRod','HOLD',   'QA Hold',     1600.00,4300.00,'2026-07-16 06:50:00 -05:00','recv-op'),
    ('R00045','1100','H19',0.3750,9000.00,8970.00,'HT-1100-2461','RawRod','COMPLETE','FL3 Payoff 1',3800.00,   0.00,'2026-07-16 07:05:00 -05:00','recv-op'),
    ('R00046','5052','H34',0.3750,8600.00,8560.00,'HT-5052-2201','RawRod','HOLD',   'QA Hold',      900.00,4200.00,'2026-07-17 08:00:00 -05:00','recv-op'),
    ('R00047','1100','H19',0.3750,9000.00,8952.00,'HT-1100-2470','RawRod','HOLD',   'QA Hold',        NULL,   NULL,'2026-07-18 09:15:00 -05:00','recv-op'),
    ('R00048','6061','T8', 0.3750,8500.00,8470.00,'HT-6061-6101','RawRod','RECEIVED','Warehouse',     NULL,   NULL,'2026-07-18 10:00:00 -05:00','recv-op');
GO

-- ============================================================
-- FlatWireRun  (references seeded PassSchedule rows)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[FlatWireRun])
INSERT INTO [dbo].[FlatWireRun]
    ([RunId],[LineId],[OrderId],[PassScheduleId],[Alloy],[RouteMode],[Status],[StartedAt],[PausedAt],[CompletedAt],[FootageFt],[OperatorId],[CreatedBy])
VALUES
    ('RUN-0001','FL1','FW-00421','PS-1100-FL1-001','1100','Standalone','Complete','2026-07-20 06:30:00 -05:00',NULL,               '2026-07-20 09:45:00 -05:00',4200.00,'Dave M.','Dave M.'),
    ('RUN-0002','FL3','FW-00600','PS-1100-FL3-001','1100','Hybrid',    'Complete','2026-07-20 10:00:00 -05:00',NULL,               '2026-07-20 12:30:00 -05:00',3800.00,'Linda K.','Linda K.'),
    ('RUN-0003','FL1','FW-00500','PS-3003-FL1-001','3003','Hybrid',    'Complete','2026-07-21 06:30:00 -05:00',NULL,               '2026-07-21 09:00:00 -05:00',3200.00,'Dave M.','Dave M.'),
    ('RUN-0004','FL2','FW-00500','PS-1100-FL2-001','1100','Hybrid',    'Paused',  '2026-07-21 10:00:00 -05:00','2026-07-21 11:20:00 -05:00',NULL,       1850.00,'Linda K.','Linda K.'),
    ('RUN-0005','FL1','FW-00700','PS-5052-FL1-001','5052','Standalone','Aborted', '2026-07-22 06:30:00 -05:00',NULL,               '2026-07-22 07:15:00 -05:00', 900.00,'Marcus T.','Marcus T.');
GO

-- ============================================================
-- SpoolProcessing  (intermediate FL1 output + one partial-run spool)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolProcessing])
INSERT INTO [dbo].[SpoolProcessing]
    ([Alpha],[OrderNo],[RelLetter],[ParentRodAlpha],[SourceRodAlpha],[SourceRunId],[LineId],[OriginRouteMode],
     [Status],[GaugeIn],[WidthIn],[GrossWeightLb],[NetWeightLb],[Location],[ReceivedAt],[StagedAt],[CreatedBy])
VALUES
    ('SP-00031','FW-00500','A','R00043',NULL,     'RUN-0003','FL1','Hybrid',    'INFLAT', 0.0970,0.7500,3400.00,3385.00,'FL2 TPO',    '2026-07-21 09:05:00 -05:00','2026-07-21 09:40:00 -05:00','Dave M.'),
    ('SP-00032','FW-00500','B','R00044',NULL,     'RUN-0003','FL1','Hybrid',    'STAGED', 0.0970,0.7500,3350.00,3335.00,'Anneal Rack','2026-07-21 09:10:00 -05:00',NULL,                        'Dave M.'),
    ('SP-00033','FW-00700','A',NULL,    'R00046','RUN-0005','FL1','Standalone', 'STAGED', NULL,  NULL,   1500.00,1490.00,'WIP Rack',   '2026-07-22 07:12:00 -05:00',NULL,                        'Marcus T.');
GO

-- ============================================================
-- SpoolProcessing.SpoolId -- point the demo spools at their carriers
-- ============================================================
-- Done as an UPDATE rather than in the INSERT above, because SpoolId is
-- itself added to SpoolProcessing by a guarded ALTER in 03_Materials, so a database built
-- before 20 Aug 2026 and refreshed rather than rebuilt would not have the column
-- in the INSERT's column list.
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND name = N'SpoolId')
BEGIN
    UPDATE s SET s.[SpoolId] = c.[Id]
    FROM [dbo].[SpoolProcessing] s
    -- SpoolNos are SP-0001..SP-0045 (FOUR digits) since 23 Aug 2026; these were
    -- S02 / S03 while the article registry was four placeholder rows. Note the
    -- asymmetry and do not "tidy" it: the left value is a MATERIAL alpha
    -- (SP-##### , five digits) and the right an ARTICLE number (four). OQ-K.
    JOIN (VALUES ('SP-00031','SP-0002'),('SP-00032','SP-0003')) AS v([Alpha],[SpoolNo])
         ON v.[Alpha] = s.[Alpha]
    JOIN [dbo].[Spool] c
         ON c.[SpoolNo] = v.[SpoolNo]
    WHERE s.[SpoolId] IS NULL;
    PRINT 'Seeded: SpoolProcessing.SpoolId for SP-00031, SP-00032';
END
GO

-- ============================================================
-- RodOrderAllocation -- the PLAN
-- ============================================================
-- Two shapes, deliberately:
--   * R00041 is Sole on FW-00421 -- the ordinary one-rod-one-order case.
--   * R00043 is split across FW-00500 and FW-00700 -- the case the table
--     exists for. The split point is NOT a column: row 1's RodWeightTo (5000)
--     IS row 2's RodWeightFrom, and CK_RodOrderAllocation_WeightRange asserts
--     RodWeightTo - RodWeightFrom = AllocatedWeightLb on each row.
--     PinnedFirst / PinnedLast mark the crossing for the sequence validator.
-- Weights are in POUNDS throughout -- footage is not conserved through drawing.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[RodOrderAllocation])
INSERT INTO [dbo].[RodOrderAllocation]
    ([RodAlpha],[OrderNo],[RelLetter],[OrderSeqNo],[RodSeqNoInOrder],[AllocatedWeightLb],
     [RodWeightFrom],[RodWeightTo],[PinRole],[RodKind],[Source],[IsActive],[CreatedBy])
VALUES
    ('R00041','FW-00421','A',1,1,8950.00,   0.00,8950.00,'Sole',       'Full','Planned',1,'planner'),
    ('R00043','FW-00500','A',1,1,5000.00,   0.00,5000.00,'PinnedFirst','Full','Planned',1,'planner'),
    ('R00043','FW-00700','A',2,1,3760.00,5000.00,8760.00,'PinnedLast', 'Full','Planned',1,'planner');
GO
PRINT 'Seeded: RodOrderAllocation (3 rows -- one Sole, one two-order split)';
GO

-- ============================================================
-- SpoolTraceability -- the spool-side genealogy (FR-333, G42)
-- ============================================================
-- SP-00031 carries TWO source rods, which is the whole point of the table:
-- a coil has one spool and many rods, and the range says which feet came from
-- which rod. Footage is SPOOL-LOCAL and half-open [From, To).
-- ChildAlpha follows Q57: one namespace, minted off the rod root.
--
-- !! WeldEventId IS NULL ON EVERY ROW HERE, AND IT MUST BE.
--    FK_SpoolTraceability_WeldEvent points at WeldEvent, which is seeded in
--    FlatWire_SampleData_Runs.sql -- the NEXT file in the runner. Naming WLD-002
--    here fails the FK. The weld link is applied by an UPDATE in that file,
--    once the parent row exists. Same constraint as
--    RodOrderConsumption.RodCheckoutId, and as RodStaging.WipRejectionId before
--    it: a nullable FK whose parent is seeded later is populated by a later
--    UPDATE, never by this INSERT.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolTraceability])
INSERT INTO [dbo].[SpoolTraceability]
    ([SpoolAlpha],[RodAlpha],[SeqNo],[SegmentWeightLb],[FootageFrom],[FootageTo],[ChildAlpha],[WeldEventId],[CreatedBy])
VALUES
    ('SP-00031','R00043',1,1900.00,    0, 8300,'R00043A',NULL,'Dave M.'),
    ('SP-00031','R00044',2,1485.00, 8300,14800,'R00044A',NULL,'Dave M.'),
    ('SP-00032','R00044',1,3335.00,    0,16400,'R00044B',NULL,'Dave M.');
GO
PRINT 'Seeded: SpoolTraceability (3 rows -- SP-00031 is multi-rod)';
GO

-- ============================================================
-- SpoolOrder -- DERIVED from RodOrderAllocation, not allocated
-- ============================================================
-- SP-00031's material came from R00043, which is split across FW-00500 and
-- FW-00700 -- so the spool inherits BOTH orders, and SpoolWeightFrom/To carry
-- the boundary FL2 has to cut at (G48). SP-00032 is single-order.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolOrder])
INSERT INTO [dbo].[SpoolOrder]
    ([SpoolAlpha],[OrderNo],[RelLetter],[SeqNo],[PlannedWeightLb],[SpoolWeightFrom],[SpoolWeightTo],[Source])
VALUES
    ('SP-00031','FW-00500','A',1,1900.00,   0.00,1900.00,'Derived'),
    ('SP-00031','FW-00700','A',2,1485.00,1900.00,3385.00,'Derived'),
    ('SP-00032','FW-00500','B',1,3335.00,   0.00,3335.00,'Derived');
GO
PRINT 'Seeded: SpoolOrder (3 rows -- SP-00031 crosses an order boundary)';
GO
