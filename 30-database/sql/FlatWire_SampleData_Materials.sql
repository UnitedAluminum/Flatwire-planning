-- ============================================================
-- Flat Wire Mill — Sample Data: Material Tables
-- Run order : after DDL 06, and after Lookup + Schedule seeds
-- Tables    : Rod, FlatWireRun, SpoolProcessing, SpoolTraceability,
--             SpoolOrder, RodOrderAllocation
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

/*==============================================================================================
  PRECONDITION -- fail fast on a HALF-seeded database.

  ⚠ EVERY BLOCK BELOW IS GUARDED ON ITS OWN TABLE BEING EMPTY, which makes a full re-run a
  clean no-op but does NOT make a PARTIAL one safe. sp_IngestRodFromCoils creates Rod rows from
  proddb..coils, and FlatWire_SampleData_RunAll.sql's header warns about exactly that. What
  happened next was silent and then fatal: "IF NOT EXISTS (SELECT 1 FROM Rod)" saw those rows,
  skipped ALL EIGHT fixture rods, and then FlatWireRun and RodCheckin inserted anyway -- so the
  chain died mid-file on FK_RodCheckin_Rod with :on error exit, leaving a PARTIALLY seeded
  database that no guard can now repair.

  The check is on the fixture rods specifically, not on the table being empty: a database that
  already holds ingested rod is a legitimate state, it just is not one this seed can extend.
==============================================================================================*/
IF EXISTS (SELECT 1 FROM [dbo].[Rod])
   AND NOT EXISTS (SELECT 1 FROM [dbo].[Rod] WHERE [Alpha] = 'R00041')
    THROW 60001, 'FlatWire_SampleData_Materials: dbo.Rod holds rows but not the fixture rods (R00041..R00048) - most likely sp_IngestRodFromCoils has run. This seed cannot extend that state: the runs and check-ins below would insert against rods that are not there and fail on FK_RodCheckin_Rod, half way through. Tear down and redeploy, or seed into an empty FlatWireDB.', 1;
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
    ([RunId],[MachineName],[OrderId],[PassScheduleId],[Alloy],[RouteMode],[Status],[StartedAt],[PausedAt],[CompletedAt],[FootageFt],[OperatorId],[CreatedBy])
VALUES
    ('RUN-0001','FL1','FW-00421','PS-1100-FL1-001','1100','Standalone','Complete','2026-07-20 06:30:00 -05:00',NULL,               '2026-07-20 09:45:00 -05:00',4200.00,'Dave M.','Dave M.'),
    ('RUN-0002','FL3','FW-00600','PS-1100-FL3-001','1100','Hybrid',    'Complete','2026-07-20 10:00:00 -05:00',NULL,               '2026-07-20 12:30:00 -05:00',3800.00,'Linda K.','Linda K.'),
    ('RUN-0003','FL1','FW-00500','PS-3003-FL1-001','3003','Hybrid',    'Complete','2026-07-21 06:30:00 -05:00',NULL,               '2026-07-21 09:00:00 -05:00',3200.00,'Dave M.','Dave M.'),
    -- ⛔ THE INACTIVE PASS SCHEDULE HERE IS CORRECT -- do not "fix" it. RUN-0004 is the only
    --   non-terminal run and it names PS-1100-FL2-001, which is Inactive, so it reads at first
    --   glance like a live run pointing at a dead schedule. It is not:
    --     - PS-1100-FL2-001 targets 0.0900", and RUN-0004's RunReading rows are 0.0900-0.0902;
    --     - its replacement PS-1100-FL2-002 targets 0.1000" and was CREATED 15 Aug 2026, three
    --       weeks AFTER this run started on 21 Jul, so the run could not have used it; and
    --     - UX_PassSchedule_OneActivePerLineAlloy admits one Active row per (line, alloy), so
    --       FL2-001 could not stay Active once FL2-002 arrived.
    --   A run keeps naming the schedule it STARTED under after that schedule is superseded.
    --   Re-pointing this row would give the run readings that contradict its own schedule.
    ('RUN-0004','FL2','FW-00500','PS-1100-FL2-001','1100','Hybrid',    'Paused',  '2026-07-21 10:00:00 -05:00','2026-07-21 11:20:00 -05:00',NULL,       1850.00,'Linda K.','Linda K.'),
    ('RUN-0005','FL1','FW-00700','PS-5052-FL1-001','5052','Standalone','Aborted', '2026-07-22 06:30:00 -05:00',NULL,               '2026-07-22 07:15:00 -05:00', 900.00,'Marcus T.','Marcus T.');
GO

-- ============================================================
-- SpoolProcessing  (intermediate FL1 output + one partial-run spool)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolProcessing])
INSERT INTO [dbo].[SpoolProcessing]
    ([Alpha],[OrderNo],[RelLetter],[ParentRodAlpha],[SourceRodAlpha],[SourceRunId],[MachineName],[OriginRouteMode],
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
    ('R00043','FW-00700','A',2,1,3760.00,5000.00,8760.00,'PinnedLast', 'Full','Planned',1,'planner'),
    -- R00044, added 8 Sep 2026 (D-57). It had NO allocation at all, while TWO SpoolOrder rows
    -- claimed Source='Derived' against it -- and Derived means "the union of the orders on the rods",
    -- so the union was EMPTY and those rows were asserted, not derived. A second two-order rod, so
    -- the spool seed derives for real. 1,485 + 3,335 = 4,820 lb, which is what SP-00031 segment 2
    -- and SP-00032 segment 1 take between them.
    ('R00044','FW-00700','A',1,2,1485.00,   0.00,1485.00,'PinnedFirst','Full','Planned',1,'planner'),
    ('R00044','FW-00500','B',2,1,3335.00,1485.00,4820.00,'PinnedLast', 'Full','Planned',1,'planner');
GO
PRINT 'Seeded: RodOrderAllocation (5 rows -- one Sole, two two-order splits)';
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
-- SpoolOrder -- one row per (SEGMENT, ORDER), re-grained 8 Sep 2026 (D-57)
-- ============================================================
-- THE FIXTURE'S STORY CHANGED, DELIBERATELY. The previous three rows put the
-- order boundary EXACTLY ON THE ROD BOUNDARY -- FW-00500 took R00043's whole
-- 1,900 lb segment and FW-00700 took R00044's whole 1,485 lb -- while the
-- comment above them claimed "R00043 is split across FW-00500 and FW-00700".
-- The numbers and the prose disagreed, and nothing was actually split. A
-- STRADDLE is the case the re-grain exists for, so the fixture now shows one.
--
-- Three cases, on purpose:
--   Case B  rows 1-2: ONE SEGMENT, TWO ORDERS -- inexpressible before D-57
--   Case C  rows 2-3: ONE ORDER over TWO SEGMENTS -> two rows for FW-00700
--   Case A  row 4   : the ordinary one-segment-one-order case
--
-- TWO FRAMES PER ROW, and this is what row 3 demonstrates. In SEGMENT-LOCAL
-- POUNDS, FW-00700's two rows read [1000,1900) and [0,1485) -- two unrelated
-- intervals. In SPOOL-LOCAL FEET they read [4368,8300) and [8300,14800) --
-- one contiguous run of 10,432 ft. FL2 cuts against a footage counter, not a
-- scale, so contiguity has to be visible in the spool frame. That is why the
-- footage pair is stored.
--
-- Source IS PER ROW, and the split is not cosmetic (G110):
--   Derived  = whole segment -> whole order, read off the rod's plan (rows 3-4)
--   Planned  = a STRADDLE (rows 1-2). Deriving a split point needs the
--              ROD-LOCAL weight at which this spool started taking that rod,
--              and NO TABLE HOLDS THAT ANCHOR. So it is an allocation
--              decision, not a derivation. Seeding these as Derived would
--              assert a derivation nobody can reproduce.
--
-- Footage is STATED here, not computed, so a wrong conversion formula cannot
-- hide behind a seed that agrees with itself. Row 1's 4368 is the only derived
-- figure: 1000 / 1900 * 8300 = 4368.42. Row 2 then STARTS at 4368 and SNAPS
-- its To to the parent's 8300 -- without that snap, integer rounding leaves a
-- one-foot hole between two adjacent orders, silently.
--
-- !! SpoolTraceabilityId is IDENTITY, so this is an INSERT...SELECT that looks
--    the parent up by (SpoolAlpha, SeqNo). C5 requires the marker below.
-- ============================================================
-- C5-OK: SpoolOrder.SpoolTraceabilityId
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolOrder])
INSERT INTO [dbo].[SpoolOrder]
    ([SpoolTraceabilityId],[OrderNo],[RelLetter],[SeqNo],
     [AllocatedWeightLb],[SegmentWeightFrom],[SegmentWeightTo],
     [SpoolFootageFrom],[SpoolFootageTo],[Source],[IsActive],[CreatedBy])
SELECT st.[Id], v.[OrderNo], v.[RelLetter], v.[SeqNo],
       v.[Alloc], v.[WFrom], v.[WTo], v.[FtFrom], v.[FtTo], v.[Source], 1, 'planner'
FROM   (VALUES
           -- SP-00031 seg 1 = R00043, 1,900 lb, spool ft [0,8300): STRADDLES FW-00500 -> FW-00700
           ('SP-00031',1,'FW-00500','A',1,1000.00,   0.00,1000.00,    0, 4368,'Planned'),
           ('SP-00031',1,'FW-00700','A',2, 900.00,1000.00,1900.00, 4368, 8300,'Planned'),
           -- SP-00031 seg 2 = R00044, 1,485 lb, spool ft [8300,14800): continues FW-00700
           ('SP-00031',2,'FW-00700','A',1,1485.00,   0.00,1485.00, 8300,14800,'Derived'),
           -- SP-00032 seg 1 = R00044, 3,335 lb, spool ft [0,16400): single order
           ('SP-00032',1,'FW-00500','B',1,3335.00,   0.00,3335.00,    0,16400,'Derived')
       ) AS v([SpoolAlpha],[SegSeqNo],[OrderNo],[RelLetter],[SeqNo],
              [Alloc],[WFrom],[WTo],[FtFrom],[FtTo],[Source])
JOIN   [dbo].[SpoolTraceability] st
       ON st.[SpoolAlpha] = v.[SpoolAlpha] AND st.[SeqNo] = v.[SegSeqNo];
GO
PRINT 'Seeded: SpoolOrder (4 rows -- SP-00031 seg 1 straddles two orders)';
GO
