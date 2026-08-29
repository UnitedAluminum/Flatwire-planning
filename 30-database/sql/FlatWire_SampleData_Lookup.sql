-- ============================================================
-- Flat Wire Mill — Sample Data: Lookup / Reference Tables
-- Run order : after DDL 06 (FKs), BEFORE FlatWire_SampleData_Schedule
-- Tables    : Stand, Drawer, Edger, Dancer, AlloyProperty, Spool
-- ============================================================
-- These fixed IDENTITY values are the FK targets the schedule
-- sample data (FlatWire_SampleData_Schedule.sql) references:
--   Stand.Id  1=FM1  2=FM2_S1  3=FM2_S2  4=FM2_S3
--   Drawer.Id 1..13 (die hole diameter = output wire size)
--   Edger.Id  1=Round  2=Square
-- AlloyProperty seeds the 5 alloys referenced by PassSchedule
-- (FK PassSchedule.Alloy → AlloyProperty.Alloy).
--
-- Idempotent: each block is guarded so re-runs are no-ops.
-- ============================================================

USE [FlatWireDB]
GO

-- Required when writing tables that carry PERSISTED computed columns.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- Stand  (IDENTITY_INSERT for stable FK IDs)
-- FM1 has no edger (May-21-2026).
-- Aug-4-2026 correction: FM2 has THREE stands — S1 (8"), S2 (6"),
-- S3 (6", final) — with edgers at S2 and S3 only. The former
-- FM2_6inS3 row never corresponded to real equipment and is removed;
-- roll diameter is now data, not part of the name.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Stand])
BEGIN
    SET IDENTITY_INSERT [dbo].[Stand] ON;
    INSERT INTO [dbo].[Stand] ([Id], [Name], [LineId], [RollDiameterIn], [MinGaugeIn], [MaxGaugeIn], [MinWidthIn], [MaxWidthIn], [IsActive]) VALUES
        (1, 'FM1',     'FL1', 12.000, 0.0700, 0.2000, 0.4000, 0.9000, 1),
        (2, 'FM2_S1',  'FL2',  8.000, 0.0700, 0.1600, 0.4000, 0.9000, 1),
        (3, 'FM2_S2',  'FL2',  6.000, 0.0700, 0.1600, 0.4000, 0.9000, 1),
        (4, 'FM2_S3',  'FL2',  6.000, 0.0700, 0.1600, 0.4000, 0.9000, 1);
    SET IDENTITY_INSERT [dbo].[Stand] OFF;
    PRINT 'Seeded: Stand (4 rows)';
END
ELSE
    PRINT 'Stand already seeded — skipped';
GO

-- ============================================================
-- Drawer  (die hole diameter = output wire size after drawing)
--
-- Die life: LastGrindingFeet seeds at 0 -- a fresh counter, which is a
-- fact rather than an assumption. TotalFeetAllowed seeds NULL: OQ-83
-- records die-life tracking as decided but the THRESHOLD as TBD, and an
-- invented engineering limit is worse than no limit. Same discipline as
-- AlloyProperty's rod-diameter tolerances.
--
-- A database created before Aug-6-2026 needs a teardown + rebuild to pick
-- these columns up -- the die-life columns are in the CREATE TABLE only,
-- and 01_Lookup's CREATE is skipped whenever Drawer already exists.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Drawer])
BEGIN
    SET IDENTITY_INSERT [dbo].[Drawer] ON;
    INSERT INTO [dbo].[Drawer] ([Id], [Name], [DiameterIn], [MinDiameterIn], [MaxDiameterIn], [LastGrindingFeet], [TotalFeetAllowed], [IsActive]) VALUES
        ( 1, 'DIE-0210', 0.2100, NULL, NULL, 0, NULL, 1),
        ( 2, 'DIE-0240', 0.2400, NULL, NULL, 0, NULL, 1),
        ( 3, 'DIE-0250', 0.2500, NULL, NULL, 0, NULL, 1),
        ( 4, 'DIE-0265', 0.2650, NULL, NULL, 0, NULL, 1),
        ( 5, 'DIE-0315', 0.3150, NULL, NULL, 0, NULL, 1),
        ( 6, 'DIE-0330', 0.3300, NULL, NULL, 0, NULL, 1),
        ( 7, 'DIE-0270', 0.2700, NULL, NULL, 0, NULL, 1),
        ( 8, 'DIE-0275', 0.2750, NULL, NULL, 0, NULL, 1),
        ( 9, 'DIE-0300', 0.3000, NULL, NULL, 0, NULL, 1),
        (10, 'DIE-0310', 0.3100, NULL, NULL, 0, NULL, 1),
        (11, 'DIE-0320', 0.3200, NULL, NULL, 0, NULL, 1),
        (12, 'DIE-0335', 0.3350, NULL, NULL, 0, NULL, 1),
        (13, 'DIE-0340', 0.3400, NULL, NULL, 0, NULL, 1);
    SET IDENTITY_INSERT [dbo].[Drawer] OFF;
    PRINT 'Seeded: Drawer (13 rows)';
END
ELSE
    PRINT 'Drawer already seeded — skipped';
GO

-- ============================================================
-- Edger
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Edger])
BEGIN
    SET IDENTITY_INSERT [dbo].[Edger] ON;
    INSERT INTO [dbo].[Edger] ([Id], [Name], [EdgeType], [ToolingSetNo], [IsActive]) VALUES
        (1, 'EDGE-ROUND-A',  'Round',  'TS-RND-01', 1),
        (2, 'EDGE-SQUARE-B', 'Square', 'TS-SQR-01', 1);
    SET IDENTITY_INSERT [dbo].[Edger] OFF;
    PRINT 'Seeded: Edger (2 rows)';
END
ELSE
    PRINT 'Edger already seeded — skipped';
GO

-- ---------------------------------------------------------------------------
-- Dancer — three rows, and they are equipment, not sample data.
-- FM1 has one; FM2 has two, between S1/S2 and S2/S3 (D-28).
-- SupportsTensionMode is set only on FM2's pair: the two selectable modes were
-- attributed to FM2 on the 6 Aug call. Whether FM1's dancer also has modes is
-- explicitly unanswered (PLC-Q18) — 0 here records "not stated", not "no".
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [dbo].[Dancer])
BEGIN
    SET IDENTITY_INSERT [dbo].[Dancer] ON;
    INSERT INTO [dbo].[Dancer] ([Id], [Name], [LineId], [Position], [Ordinal], [SupportsTensionMode], [DefaultMode], [IsActive]) VALUES
        (1, 'FM1_Dancer',   NULL, 'FM1',       NULL, 0, 'Dancer', 1),
        (2, 'FM2_Dancer1',  NULL, 'FM2_S1_S2', 1,    1, 'Dancer', 1),
        (3, 'FM2_Dancer2',  NULL, 'FM2_S2_S3', 2,    1, 'Dancer', 1);
    SET IDENTITY_INSERT [dbo].[Dancer] OFF;
    PRINT 'Seeded: Dancer (3 rows)';
END
ELSE
    PRINT 'Dancer already seeded — skipped';
GO


-- ============================================================
-- AlloyProperty  (authoritative alloy list for PassSchedule.Alloy)
-- LbPerFtFactor left NULL — OQ-10 (footage→weight factor) PENDING.
-- DensityLbPerIn3 provided as the area×density fallback basis.
-- Max-reduction and welding-wire flags per SRS / mockup analysis.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[AlloyProperty])
BEGIN
    -- Gauge/width tolerances carry the previously seeded SYMMETRIC value into both the
    -- Minus and Plus columns — same numbers as before, no new data invented.
    -- Rod diameter and ovality are deliberately NULL: those values are OWED BY E-MAIL
    -- (Q22 / OI-07). Do NOT seed them from the mockup's mock per-alloy map.
    INSERT INTO [dbo].[AlloyProperty]
        ([Alloy], [MaxReductionPerPass], [SpringbackFactor],
         [GaugeToleranceMinusIn], [GaugeTolerancePlusIn], [WidthToleranceMinusIn], [WidthTolerancePlusIn],
         [RodDiameterToleranceMinusIn], [RodDiameterTolerancePlusIn], [RodOvalityMaxIn],
         [SpeedRangeMinFpm], [SpeedRangeMaxFpm], [LbPerFtFactor], [DensityLbPerIn3], [IsWeldingWire], [IsActive]) VALUES
        ('1100', 0.250, 0.980, 0.0020, 0.0020, 0.0050, 0.0050, NULL, NULL, NULL,  800, 1600, NULL, 0.098000, 0, 1),
        ('1350', 0.220, 0.970, 0.0020, 0.0020, 0.0060, 0.0060, NULL, NULL, NULL,  600, 1200, NULL, 0.097400, 1, 1),  -- welding-wire grade
        ('3003', 0.240, 0.975, 0.0030, 0.0030, 0.0080, 0.0080, NULL, NULL, NULL,  700, 1400, NULL, 0.099000, 0, 1),
        ('5052', 0.200, 0.965, 0.0030, 0.0030, 0.0070, 0.0070, NULL, NULL, NULL,  500, 1200, NULL, 0.097100, 0, 1),
        ('6061', 0.180, 0.960, 0.0020, 0.0020, 0.0060, 0.0060, NULL, NULL, NULL,  400,  900, NULL, 0.097500, 0, 1);
    PRINT 'Seeded: AlloyProperty (5 rows)';
END
ELSE
    PRINT 'AlloyProperty already seeded — skipped';
GO

-- NO SEED: PayoffPosition -- its three rows are pinned (non-IDENTITY) and
-- seeded by FlatWire_DDL_01_Lookup.sql itself, because FK targets must exist
-- before the DDL that references them runs. Deliberate, not an omission.

-- ============================================================
-- Spool -- PROVISIONAL FIXTURES
-- ============================================================
-- The carriers are physical articles, one per stencilled number, and all one
-- size -- which is why SpoolConfiguration was merged into this table on
-- 23 Aug 2026 rather than kept as a one-row parent. The limits below are
-- therefore IDENTICAL on every row, by design and not by accident: that is
-- the denormalisation the merge accepted. See 01_Lookup for the trade.
--
-- THE REGISTRY IS 45 ARTICLES, SP-0001 .. SP-0045 -- the fixed spool list the
-- client confirmed and RodOrderAllocation_DesignPlan.md records. This replaced
-- four placeholder rows (S01..S04) on 23 Aug 2026.
--
-- !! FOUR DIGITS, NOT FIVE, AND THAT IS THE WHOLE POINT. OQ-K:
--    "Carriers are SP-0001..SP-0045 (four digits); material spools are
--     SP-##### (five, e.g. SP-00021). One digit apart on the same prefix, for
--     the two objects Spool exists to keep apart ... Build to SP-0001..SP-0045
--     meanwhile."
--    Five digits would not merely LOOK similar -- SP-00031 would be BOTH a
--    Spool.SpoolNo and a SpoolProcessing.Alpha, since the seeded material
--    alphas (SP-00031/32/33) all fall inside 1..45. That re-creates the exact
--    conflation the Spool / SpoolProcessing split (Q60) exists to prevent, and
--    breaks SpoolQueue.md item 1 (closed 20 Aug 2026): "any one identifier on
--    the label -- the spool number or any alpha -- resolves the spool."
--    Verification query for this lives in [DEP] step 3 / the plan: zero rows
--    from  SELECT SpoolNo FROM Spool WHERE SpoolNo IN (SELECT Alpha FROM SpoolProcessing).
--
-- !! SpoolNo's FORMAT IS STILL NOT RATIFIED -- Q42 is open (format, and whether
--    the count is 30 or 45). These rows are provisional. The format is built
--    from ONE expression below precisely so that resolving Q42 is a one-line
--    edit and not 45 -- treat them the way this file treats the OQ-83
--    threshold: present, usable, and explicitly marked TBD.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Spool])
BEGIN
    -- FORMAT IN ONE PLACE (Q42 open): change this expression, not 45 rows.
    -- 'SP-' + 4-digit zero-padded ordinal -> SP-0001 .. SP-0045.
    INSERT INTO [dbo].[Spool]
        ([SpoolNo],[SizeClass],
         [MinWeightLb],[MaxWeightLb],[MinCoreDiameterIn],[MaxCoreDiameterIn],
         [MinOuterDiameterIn],[MaxOuterDiameterIn],[IsActive],[Notes])
    SELECT
        'SP-' + RIGHT('0000' + CAST(n.[n] AS VARCHAR(4)), 4),
        'TKUP-1 Intermediate Spool',
        -- Limits carried over verbatim from the former SpoolConfiguration Id 1
        -- ('TKUP-1 Intermediate Spool'): 500-3500 lb, core 8-12", OD 24-40".
        -- IDENTICAL on every row, by design: the SpoolConfiguration merge (Q86)
        -- denormalised a one-row size class onto 45 articles. See 01_Lookup.
        500.00, 3500.00, 8.0000, 12.0000, 24.0000, 40.0000,
        CASE WHEN n.[n] = 45 THEN 0 ELSE 1 END,
        CASE n.[n]
             WHEN  2 THEN 'PROVISIONAL fixture -- carries SP-00031 in the demo dataset'
             WHEN  3 THEN 'PROVISIONAL fixture -- carries SP-00032 in the demo dataset'
             WHEN 45 THEN 'PROVISIONAL fixture -- withdrawn, damaged flange; exercises IsActive = 0'
             ELSE 'PROVISIONAL fixture -- SpoolNo format open (Q42)' END
    -- Inline numbers list rather than a recursive CTE or spt_values: portable to
    -- SQL Server 2019 (no GENERATE_SERIES before 2022), and the 45 is countable
    -- on the page.
    FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
                 (11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
                 (21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
                 (31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
                 (41),(42),(43),(44),(45)) AS n([n]);
    PRINT 'Seeded: Spool (45 PROVISIONAL rows, 44 active + 1 withdrawn -- Q42 open)';
END
ELSE
    PRINT 'Spool already seeded -- skipped';
GO
