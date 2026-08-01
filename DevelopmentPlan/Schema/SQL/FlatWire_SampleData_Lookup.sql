-- ============================================================
-- Flat Wire Mill — Sample Data: Lookup / Reference Tables
-- Run order : after DDL 06 (FKs), BEFORE FlatWire_SampleData_Schedule
-- Tables    : Stand, Drawer, Edger, SpoolConfiguration, AlloyProperty
-- ============================================================
-- These fixed IDENTITY values are the FK targets the schedule
-- sample data (FlatWire_SampleData_Schedule.sql) references:
--   Stand.Id  1=FM1  2=FM2_8in  3=FM2_6inS1  4=FM2_6inS2  5=FM2_6inS3
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
-- May-21-2026 revision: FM1 (no edger) + FM2 three 6" stands
-- (edgers at S2 and S3). FM2_8in retained for legacy schedules.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Stand])
BEGIN
    SET IDENTITY_INSERT [dbo].[Stand] ON;
    INSERT INTO [dbo].[Stand] ([Id], [Name], [LineId], [MinGaugeIn], [MaxGaugeIn], [MinWidthIn], [MaxWidthIn], [IsActive]) VALUES
        (1, 'FM1',        'FL1', 0.0700, 0.2000, 0.4000, 0.9000, 1),
        (2, 'FM2_8in',    'FL2', 0.0700, 0.1600, 0.4000, 0.9000, 1),
        (3, 'FM2_6inS1',  'FL2', 0.0700, 0.1600, 0.4000, 0.9000, 1),
        (4, 'FM2_6inS2',  'FL2', 0.0700, 0.1600, 0.4000, 0.9000, 1),
        (5, 'FM2_6inS3',  'FL2', 0.0700, 0.1600, 0.4000, 0.9000, 1);
    SET IDENTITY_INSERT [dbo].[Stand] OFF;
    PRINT 'Seeded: Stand (5 rows)';
END
ELSE
    PRINT 'Stand already seeded — skipped';
GO

-- ============================================================
-- Drawer  (die hole diameter = output wire size after drawing)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Drawer])
BEGIN
    SET IDENTITY_INSERT [dbo].[Drawer] ON;
    INSERT INTO [dbo].[Drawer] ([Id], [Name], [DiameterIn], [MinDiameterIn], [MaxDiameterIn], [IsActive]) VALUES
        ( 1, 'DIE-0210', 0.2100, NULL, NULL, 1),
        ( 2, 'DIE-0240', 0.2400, NULL, NULL, 1),
        ( 3, 'DIE-0250', 0.2500, NULL, NULL, 1),
        ( 4, 'DIE-0265', 0.2650, NULL, NULL, 1),
        ( 5, 'DIE-0315', 0.3150, NULL, NULL, 1),
        ( 6, 'DIE-0330', 0.3300, NULL, NULL, 1),
        ( 7, 'DIE-0270', 0.2700, NULL, NULL, 1),
        ( 8, 'DIE-0275', 0.2750, NULL, NULL, 1),
        ( 9, 'DIE-0300', 0.3000, NULL, NULL, 1),
        (10, 'DIE-0310', 0.3100, NULL, NULL, 1),
        (11, 'DIE-0320', 0.3200, NULL, NULL, 1),
        (12, 'DIE-0335', 0.3350, NULL, NULL, 1),
        (13, 'DIE-0340', 0.3400, NULL, NULL, 1);
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

-- ============================================================
-- SpoolConfiguration  (intermediate TKUP-1 spool + finish coil)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[SpoolConfiguration])
BEGIN
    INSERT INTO [dbo].[SpoolConfiguration]
        ([Name], [MinWeightLb], [MaxWeightLb], [MinCoreDiameterIn], [MaxCoreDiameterIn], [MinOuterDiameterIn], [MaxOuterDiameterIn], [IsActive]) VALUES
        ('TKUP-1 Intermediate Spool', 500.00, 3500.00, 8.0000, 12.0000, 24.0000, 40.0000, 1),
        ('Coreless Finish Coil',      100.00, 1100.00, 8.0000, 16.0000, 20.0000, 36.0000, 1);
    PRINT 'Seeded: SpoolConfiguration (2 rows)';
END
ELSE
    PRINT 'SpoolConfiguration already seeded — skipped';
GO

-- ============================================================
-- AlloyProperty  (authoritative alloy list for PassSchedule.Alloy)
-- LbPerFtFactor left NULL — OQ-36 (footage→weight factor) PENDING.
-- DensityLbPerIn3 provided as the area×density fallback basis.
-- Max-reduction and welding-wire flags per SRS / mockup analysis.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[AlloyProperty])
BEGIN
    -- Gauge/width tolerances carry the previously seeded SYMMETRIC value into both the
    -- Minus and Plus columns — same numbers as before, no new data invented.
    -- Rod diameter and ovality are deliberately NULL: those values are OWED BY E-MAIL
    -- (Q71 / OI-07). Do NOT seed them from the mockup's mock per-alloy map.
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
