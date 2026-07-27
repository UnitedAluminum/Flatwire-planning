-- ============================================================
-- Flat Wire Mill — Sample Data: Material Tables
-- Run order : after DDL 06, and after Lookup + Schedule seeds
-- Tables    : Rod, FlatWireRun, Spool
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
     [Status],[Location],[StagedPayoffPosition],[IsWelded],[FootageRunToDate],[RemainingWeightEstimateLb],[ReceivedAt],[CreatedBy])
VALUES
    ('R00041','1100','H19',0.3750,9000.00,8950.00,'HT-1100-2451','RawRod','COMPLETE','FL1 Payoff 1',NULL,1,2100.00,   0.00,'2026-07-15 07:10:00 -05:00','recv-op'),
    ('R00042','1100','H19',0.3750,9000.00,8955.00,'HT-1100-2452','RawRod','COMPLETE','FL1 Payoff 2',NULL,1,2100.00,4700.00,'2026-07-15 07:20:00 -05:00','recv-op'),
    ('R00043','3003','H18',0.3750,8800.00,8760.00,'HT-3003-3310','RawRod','COMPLETE','FL1 Payoff 1',NULL,1,1600.00,   0.00,'2026-07-16 06:40:00 -05:00','recv-op'),
    ('R00044','3003','H18',0.3750,8800.00,8765.00,'HT-3003-3311','RawRod','STAGED', 'FL1 Payoff 2',   2,0,1600.00,4300.00,'2026-07-16 06:50:00 -05:00','recv-op'),
    ('R00045','1100','H19',0.3750,9000.00,8970.00,'HT-1100-2461','RawRod','COMPLETE','FL3 Payoff 1',NULL,0,3800.00,   0.00,'2026-07-16 07:05:00 -05:00','recv-op'),
    ('R00046','5052','H34',0.3750,8600.00,8560.00,'HT-5052-2201','RawRod','HOLD',   'QA Hold',    NULL,0, 900.00,4200.00,'2026-07-17 08:00:00 -05:00','recv-op'),
    ('R00047','1100','H19',0.3750,9000.00,8952.00,'HT-1100-2470','RawRod','HOLD',   'QA Hold',    NULL,0,   NULL,   NULL,'2026-07-18 09:15:00 -05:00','recv-op'),
    ('R00048','6061','T8', 0.3750,8500.00,8470.00,'HT-6061-6101','RawRod','RECEIVED','Warehouse',  NULL,0,   NULL,   NULL,'2026-07-18 10:00:00 -05:00','recv-op');
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
-- Spool  (intermediate FL1 output + one partial-run spool)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Spool])
INSERT INTO [dbo].[Spool]
    ([Alpha],[SpoolTypeId],[OrderNo],[RelLetter],[ParentRodAlpha],[SourceRodAlpha],[SourceRunId],[LineId],[OriginRouteMode],
     [Status],[GaugeIn],[WidthIn],[GrossWeightLb],[NetWeightLb],[Location],[ReceivedAt],[StagedAt],[CreatedBy])
VALUES
    ('SP-00031',1,'FW-00500','A','R00043',NULL,     'RUN-0003','FL1','Hybrid',    'INFLAT', 0.0970,0.7500,3400.00,3385.00,'FL2 TPO',    '2026-07-21 09:05:00 -05:00','2026-07-21 09:40:00 -05:00','Dave M.'),
    ('SP-00032',1,'FW-00500','B','R00044',NULL,     'RUN-0003','FL1','Hybrid',    'STAGED', 0.0970,0.7500,3350.00,3335.00,'Anneal Rack','2026-07-21 09:10:00 -05:00',NULL,                        'Dave M.'),
    ('SP-00033',1,'FW-00700','A',NULL,    'R00046','RUN-0005','FL1','Standalone', 'STAGED', NULL,  NULL,   1500.00,1490.00,'WIP Rack',   '2026-07-22 07:12:00 -05:00',NULL,                        'Marcus T.');
GO
