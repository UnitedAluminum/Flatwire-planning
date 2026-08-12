-- ============================================================
-- SCOPE: MVP-2 (deferred) -- moved 11 Aug 2026 from MVP-1/DBChanges. NOT part of MVP-1.
-- Requires the MVP-1 chain (00..08) to be deployed first.
-- ============================================================
-- Flat Wire Mill — Sample Data: PassSchedule + PassScheduleComponent
-- Run order : after DDL scripts 01 and 02
-- Rows      : 10 PassSchedule  ·  70 PassScheduleComponent (7 per schedule)
-- ============================================================
--
-- FK assumptions (FlatWire_SampleData_Lookup.sql must be loaded first):
--
--   Stand.Id   (Aug-4-2026: FM2 is three stands — S1 8", S2 6", S3 6" final)
--     1 = FM1 (12")    2 = FM2_S1 (8")  3 = FM2_S2 (6")  4 = FM2_S3 (6", final)
--
--   Drawer.Id  (die hole diameter = output wire size after drawing)
--     1 = DIE-0210  0.210"     7 = DIE-0270  0.270"
--     2 = DIE-0240  0.240"     8 = DIE-0275  0.275"
--     3 = DIE-0250  0.250"     9 = DIE-0300  0.300"
--     4 = DIE-0265  0.265"    10 = DIE-0310  0.310"
--     5 = DIE-0315  0.315"    11 = DIE-0320  0.320"
--     6 = DIE-0330  0.330"    12 = DIE-0335  0.335"
--                              13 = DIE-0340  0.340"
--
--   Edger.Id
--     1 = EDGE-ROUND-A  (Round)    2 = EDGE-SQUARE-B  (Square)
--
-- Coverage matrix
--   Status  : Draft (3) · Active (6) · Inactive (1)
--   LineId  : FL1 (8)   · FL2 (1)    · FL3 (1)
--   Route   : Standalone (3) · Hybrid (7)
--   Alloy   : 1100 (5) · 3003 (2) · 1350 (1) · 5052 (1) · 6061 (1)
--   EdgeType: Round (6) · Square (4)
-- ============================================================

USE [FlatWireDB]
GO

-- Required when writing tables that carry PERSISTED computed columns.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- PassSchedule  (idempotent: skip if any sample rows already present)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[PassSchedule])
INSERT INTO [dbo].[PassSchedule]
    ([ScheduleId],         [Description],
     [Alloy], [LineId],   [RouteMode],  [Status],
     [TargetGauge], [GaugeTolerance],
     [TargetWidth],  [WidthTolerance],
     [InputRodDiameterIn], [InputTemper], [InputCondition],
     [LineSpeedMinFpm], [LineSpeedMaxFpm],
     [CreatedBy],  [CreatedAt],
     [ModifiedBy], [ModifiedAt])
VALUES

-- 1 ── 1100 · FL1 · Standalone · Active ───────────────────────
--     Standard round-edge product. DB1+DB2 draw, FM1 flatten.
--     Aspect ratio 4.55 — FM2 not required.
('PS-1100-FL1-001',
 '1100 rod → 0.110" × 0.500" round edge — FL1 standalone',
 '1100', 'FL1', 'Standalone', 'Active',
 0.1100, 0.0020,
 0.5000, 0.0050,
 0.3750, 'H19', 'Hard drawn',
 800, 1600,
 'Tim O.',  '2026-04-01 06:00:00 -05:00',
 'Bob S.',  '2026-04-21 08:30:00 -05:00'),

-- 2 ── 1100 · FL1 · Standalone · Inactive ────────────────────
--     Wider, thicker profile retired after product spec change.
--     Single draw pass only; FM2 bypassed throughout campaign.
('PS-1100-FL1-002',
 '1100 rod → 0.140" × 0.640" round edge — FL1 standalone (retired)',
 '1100', 'FL1', 'Standalone', 'Inactive',
 0.1400, 0.0025,
 0.6400, 0.0060,
 0.3750, 'H19', 'Hard drawn',
 1000, 1800,
 'Tim O.',  '2023-11-15 07:00:00 -05:00',
 'Tim O.',  '2024-08-30 14:20:00 -05:00'),

-- 3 ── 1100 · FL1 · Standalone · Draft ───────────────────────
--     Thin narrow gauge under development. Two draw passes
--     reduce 0.375" rod to 0.250" before FM1 flattening.
('PS-1100-FL1-003',
 '1100 rod → 0.090" × 0.450" round edge — FL1 standalone (draft)',
 '1100', 'FL1', 'Standalone', 'Draft',
 0.0900, 0.0020,
 0.4500, 0.0040,
 0.3750, 'H19', 'Hard drawn',
 600, 1100,
 'Bob S.',  '2026-05-10 08:45:00 -05:00',
 NULL, NULL),

-- 4 ── 3003 · FL1 · Hybrid · Active ──────────────────────────
--     High aspect ratio (7.89) square-edge wire. All FM2 stands
--     engaged for precision finishing on FL2.
('PS-3003-FL1-001',
 '3003 rod → 0.095" × 0.750" square edge — FL1/FL2 hybrid',
 '3003', 'FL1', 'Hybrid', 'Active',
 0.0950, 0.0030,
 0.7500, 0.0080,
 0.3750, 'H18', 'Hard drawn',
 700, 1400,
 'Tim O.',  '2026-04-10 07:15:00 -05:00',
 'Bob S.',  '2026-04-25 11:00:00 -05:00'),

-- 5 ── 3003 · FL1 · Hybrid · Draft ───────────────────────────
--     Experimental high-aspect (12.0) wide square-edge product.
--     Pending verification of FM2 stand capacity.
('PS-3003-FL1-002',
 '3003 rod → 0.075" × 0.900" square edge — FL1/FL2 hybrid (draft)',
 '3003', 'FL1', 'Hybrid', 'Draft',
 0.0750, 0.0020,
 0.9000, 0.0060,
 0.3750, 'H18', 'Hard drawn',
 600, 1000,
 'Tim O.',  '2026-05-12 09:30:00 -05:00',
 NULL, NULL),

-- 6 ── 1350 · FL1 · Hybrid · Active ──────────────────────────
--     Welding wire grade. 1350 alloy limits max reduction to 22%
--     per pass; all FM2 stands active for dimensional precision.
('PS-1350-FL1-001',
 '1350 welding wire → 0.100" × 0.700" round edge — FL1/FL3 hybrid',
 '1350', 'FL1', 'Hybrid', 'Active',
 0.1000, 0.0020,
 0.7000, 0.0060,
 0.3750, 'H14', 'Hard drawn',
 600, 1200,
 'Tim O.',  '2026-04-18 06:30:00 -05:00',
 'Tim O.',  '2026-05-02 07:45:00 -05:00'),

-- 7 ── 5052 · FL1 · Standalone · Active ──────────────────────
--     Strain-hardened alloy. Single draw pass keeps reduction
--     within 5052 limit (20% max). FM2 not required.
('PS-5052-FL1-001',
 '5052 rod → 0.160" × 0.560" round edge — FL1 standalone',
 '5052', 'FL1', 'Standalone', 'Active',
 0.1600, 0.0030,
 0.5600, 0.0070,
 0.3750, 'H34', 'Strain hardened',
 500, 1200,
 'Bob S.',  '2026-04-22 08:00:00 -05:00',
 NULL, NULL),

-- 8 ── 1100 · FL2 · Hybrid · Active ──────────────────────────
--     FL2 receives pre-drawn round wire from FL1 TKUP-1 spool.
--     DB1 and DB2 bypassed — wire arrives already sized.
('PS-1100-FL2-001',
 '1100 pre-drawn wire → 0.090" × 0.650" square edge — FL2 hybrid',
 '1100', 'FL2', 'Hybrid', 'Active',
 0.0900, 0.0020,
 0.6500, 0.0060,
 0.3750, 'H19', 'Hard drawn',
 800, 1600,
 'Tim O.',  '2026-04-14 07:00:00 -05:00',
 'Bob S.',  '2026-05-05 09:15:00 -05:00'),

-- 9 ── 6061 · FL1 · Hybrid · Draft ───────────────────────────
--     Solution-treated alloy — lowest max reduction (18% per pass).
--     All FM2 stands planned for precision sizing. Pending trial.
('PS-6061-FL1-001',
 '6061 rod → 0.130" × 0.580" round edge — FL1/FL2 hybrid (draft)',
 '6061', 'FL1', 'Hybrid', 'Draft',
 0.1300, 0.0020,
 0.5800, 0.0060,
 0.3750, 'T8',  'Solution treated',
 400, 900,
 'Bob S.',  '2026-05-15 10:00:00 -05:00',
 NULL, NULL),

-- 10 ── 1100 · FL3 · Hybrid · Active ─────────────────────────
--      Widest product: 0.085" × 0.800" square-edge on FL3 line.
--      Full FM2 sequence for high-aspect-ratio (9.41) finishing.
('PS-1100-FL3-001',
 '1100 rod → 0.085" × 0.800" square edge — FL1/FL3 hybrid',
 '1100', 'FL3', 'Hybrid', 'Active',
 0.0850, 0.0020,
 0.8000, 0.0070,
 0.3750, 'H19', 'Hard drawn',
 700, 1500,
 'Tim O.',  '2026-04-08 06:45:00 -05:00',
 'Tim O.',  '2026-04-28 13:30:00 -05:00');
GO

-- ============================================================
-- PassScheduleComponent — 7 rows per schedule
--   DB1, DB2, FM1, EdgeSet, then the three FM2 stands FM2_S1 / FM2_S2 / FM2_S3.
--
-- State guide
--   Active : component engaged; ParameterValue, FK set
--   Bypass : component present on line but wired out; all NULL
--   Skip   : component absent from this schedule entirely; all NULL
--
-- ParameterValue
--   DB components  → die hole diameter (in)
--   FM / EdgeSet   → roll gap set-point (in)
--
-- EntryGauge / ExitGauge
--   Wire diameter entering / leaving each active station (in)
--   NULL for Bypass and Skip rows
-- ============================================================

-- Idempotent guard: skip the whole component block if any rows already present.
IF NOT EXISTS (SELECT 1 FROM [dbo].[PassScheduleComponent])
BEGIN

-- ── 1 · PS-1100-FL1-001 · Standalone · Active ───────────────
-- Rod 0.375" → DB1 0.315" → DB2 0.265" → FM1 → EdgeSet (Round) → [FM2 Skip]
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL1-001', 'DB1',       'Active', 0.3150, NULL,    1, NULL, 5,    NULL, 0.3750, 0.3150, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'DB2',       'Active', 0.2650, NULL,    2, NULL, 4,    NULL, 0.3150, 0.2650, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM1',       'Active', 0.1080, NULL,    3, 1,    NULL, NULL, 0.2650, 0.1100, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'EdgeSet',   'Active', 0.0020, 'Round', 4, NULL, NULL, 1,    0.1100, 0.1100, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM2_S1',    'Skip',   NULL,   NULL,    5, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM2_S2',    'Skip',   NULL,   NULL,    6, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM2_S3',    'Skip',   NULL,   NULL,    7, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-001');

-- ── 2 · PS-1100-FL1-002 · Standalone · Inactive ─────────────
-- Retired schedule. Single draw pass (DB2 bypassed).
-- FM2 bypassed on all campaigns — aspect ratio 4.57 never triggered it.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL1-002', 'DB1',       'Active', 0.3350, NULL,    1, NULL, 12,   NULL, 0.3750, 0.3350, 'FLS-2023-015'),
    ('PS-1100-FL1-002', 'DB2',       'Bypass', NULL,   NULL,    2, NULL, NULL, NULL, NULL,   NULL,   'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM1',       'Active', 0.1372, NULL,    3, 1,    NULL, NULL, 0.3350, 0.1400, 'FLS-2023-015'),
    ('PS-1100-FL1-002', 'EdgeSet',   'Active', 0.0022, 'Round', 4, NULL, NULL, 1,    0.1400, 0.1400, 'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM2_S1',    'Bypass', NULL,   NULL,    5, NULL, NULL, NULL, NULL,   NULL,   'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM2_S2',    'Bypass', NULL,   NULL,    6, NULL, NULL, NULL, NULL,   NULL,   'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM2_S3',    'Bypass', NULL,   NULL,    7, NULL, NULL, NULL, NULL,   NULL,   'FLS-2023-015');

-- ── 3 · PS-1100-FL1-003 · Standalone · Draft ────────────────
-- Thin-gauge development schedule. Two draw passes to reach
-- 0.250" pre-flatten diameter. SetupNo NULL — no legacy record.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL1-003', 'DB1',       'Active', 0.3100, NULL,    1, NULL, 10,   NULL, 0.3750, 0.3100, NULL),
    ('PS-1100-FL1-003', 'DB2',       'Active', 0.2500, NULL,    2, NULL, 3,    NULL, 0.3100, 0.2500, NULL),
    ('PS-1100-FL1-003', 'FM1',       'Active', 0.0882, NULL,    3, 1,    NULL, NULL, 0.2500, 0.0900, NULL),
    ('PS-1100-FL1-003', 'EdgeSet',   'Active', 0.0018, 'Round', 4, NULL, NULL, 1,    0.0900, 0.0900, NULL),
    ('PS-1100-FL1-003', 'FM2_S1',    'Skip',   NULL,   NULL,    5, NULL, NULL, NULL, NULL,   NULL,   NULL),
    ('PS-1100-FL1-003', 'FM2_S2',    'Skip',   NULL,   NULL,    6, NULL, NULL, NULL, NULL,   NULL,   NULL),
    ('PS-1100-FL1-003', 'FM2_S3',    'Skip',   NULL,   NULL,    7, NULL, NULL, NULL, NULL,   NULL,   NULL);

-- ── 4 · PS-3003-FL1-001 · Hybrid · Active ───────────────────
-- Two draw passes; FM1 overshoots to 0.097" then FM2 sequence
-- closes to 0.095" target across three stands on FL2.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-3003-FL1-001', 'DB1',       'Active', 0.3350, NULL,     1, NULL, 12,   NULL, 0.3750, 0.3350, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'DB2',       'Active', 0.3000, NULL,     2, NULL, 9,    NULL, 0.3350, 0.3000, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM1',       'Active', 0.0950, NULL,     3, 1,    NULL, NULL, 0.3000, 0.0970, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'EdgeSet',   'Active', 0.0018, 'Square', 4, NULL, NULL, 2,    0.0970, 0.0970, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM2_S1',    'Active', 0.0960, NULL,     5, 2,    NULL, NULL, 0.0970, 0.0960, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM2_S2',    'Active', 0.0955, NULL,     6, 3,    NULL, NULL, 0.0960, 0.0955, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM2_S3',    'Active', 0.0950, NULL,     7, 4,    NULL, NULL, 0.0955, 0.0950, 'FLS-2024-028');

-- ── 5 · PS-3003-FL1-002 · Hybrid · Draft ────────────────────
-- Experimental ultra-wide product. All FM2 stands planned active.
-- Roll gap values are algorithm estimates pending trial validation.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-3003-FL1-002', 'DB1',       'Active', 0.3200, NULL,     1, NULL, 11,   NULL, 0.3750, 0.3200, NULL),
    ('PS-3003-FL1-002', 'DB2',       'Active', 0.2700, NULL,     2, NULL, 7,    NULL, 0.3200, 0.2700, NULL),
    ('PS-3003-FL1-002', 'FM1',       'Active', 0.0765, NULL,     3, 1,    NULL, NULL, 0.2700, 0.0780, NULL),
    ('PS-3003-FL1-002', 'EdgeSet',   'Active', 0.0015, 'Square', 4, NULL, NULL, 2,    0.0780, 0.0780, NULL),
    ('PS-3003-FL1-002', 'FM2_S1',    'Active', 0.0775, NULL,     5, 2,    NULL, NULL, 0.0780, 0.0775, NULL),
    ('PS-3003-FL1-002', 'FM2_S2',    'Active', 0.0762, NULL,     6, 3,    NULL, NULL, 0.0775, 0.0762, NULL),
    ('PS-3003-FL1-002', 'FM2_S3',    'Active', 0.0750, NULL,     7, 4,    NULL, NULL, 0.0762, 0.0750, NULL);

-- ── 6 · PS-1350-FL1-001 · Hybrid · Active ───────────────────
-- Welding wire. 1350 springback factor 0.97 applied to FM gaps.
-- All FM2 stands active for welding-wire dimensional precision.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1350-FL1-001', 'DB1',       'Active', 0.3350, NULL,    1, NULL, 12,   NULL, 0.3750, 0.3350, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'DB2',       'Active', 0.3000, NULL,    2, NULL, 9,    NULL, 0.3350, 0.3000, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM1',       'Active', 0.0990, NULL,    3, 1,    NULL, NULL, 0.3000, 0.1020, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'EdgeSet',   'Active', 0.0020, 'Round', 4, NULL, NULL, 1,    0.1020, 0.1020, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM2_S1',    'Active', 0.1010, NULL,    5, 2,    NULL, NULL, 0.1020, 0.1010, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM2_S2',    'Active', 0.1005, NULL,    6, 3,    NULL, NULL, 0.1010, 0.1005, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM2_S3',    'Active', 0.1000, NULL,    7, 4,    NULL, NULL, 0.1005, 0.1000, 'FLS-2024-041');

-- ── 7 · PS-5052-FL1-001 · Standalone · Active ───────────────
-- Strain-hardened 5052. Single draw pass (17.8% reduction < 20%
-- max). DB2 skipped. FM2 not required at aspect ratio 3.50.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-5052-FL1-001', 'DB1',       'Active', 0.3400, NULL,    1, NULL, 13,   NULL, 0.3750, 0.3400, 'FLS-2024-055'),
    ('PS-5052-FL1-001', 'DB2',       'Skip',   NULL,   NULL,    2, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM1',       'Active', 0.1552, NULL,    3, 1,    NULL, NULL, 0.3400, 0.1600, 'FLS-2024-055'),
    ('PS-5052-FL1-001', 'EdgeSet',   'Active', 0.0025, 'Round', 4, NULL, NULL, 1,    0.1600, 0.1600, 'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM2_S1',    'Skip',   NULL,   NULL,    5, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM2_S2',    'Skip',   NULL,   NULL,    6, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM2_S3',    'Skip',   NULL,   NULL,    7, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-055');

-- ── 8 · PS-1100-FL2-001 · Hybrid · Active ───────────────────
-- FL2 receives pre-drawn round wire (~0.260") from FL1 TKUP-1 spool.
-- DB1 and DB2 bypassed — no in-line die drawing on FL2.
-- FM2 sequence closes 0.092" FM1 output to 0.090" target.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL2-001', 'DB1',       'Bypass', NULL,   NULL,     1, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-062'),
    ('PS-1100-FL2-001', 'DB2',       'Bypass', NULL,   NULL,     2, NULL, NULL, NULL, NULL,   NULL,   'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM1',       'Active', 0.0900, NULL,     3, 1,    NULL, NULL, 0.2600, 0.0920, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'EdgeSet',   'Active', 0.0018, 'Square', 4, NULL, NULL, 2,    0.0920, 0.0920, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM2_S1',    'Active', 0.0912, NULL,     5, 2,    NULL, NULL, 0.0920, 0.0912, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM2_S2',    'Active', 0.0905, NULL,     6, 3,    NULL, NULL, 0.0912, 0.0905, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM2_S3',    'Active', 0.0900, NULL,     7, 4,    NULL, NULL, 0.0905, 0.0900, 'FLS-2024-062');

-- ── 9 · PS-6061-FL1-001 · Hybrid · Draft ────────────────────
-- Solution-treated 6061 — max 18% reduction per pass.
-- Two draw passes (18.3% then 16.9%) keep within alloy limit.
-- Roll gap and FM2 values are algorithm estimates; trial pending.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-6061-FL1-001', 'DB1',       'Active', 0.3400, NULL,    1, NULL, 13,   NULL, 0.3750, 0.3400, NULL),
    ('PS-6061-FL1-001', 'DB2',       'Active', 0.3100, NULL,    2, NULL, 10,   NULL, 0.3400, 0.3100, NULL),
    ('PS-6061-FL1-001', 'FM1',       'Active', 0.1248, NULL,    3, 1,    NULL, NULL, 0.3100, 0.1320, NULL),
    ('PS-6061-FL1-001', 'EdgeSet',   'Active', 0.0022, 'Round', 4, NULL, NULL, 1,    0.1320, 0.1320, NULL),
    ('PS-6061-FL1-001', 'FM2_S1',    'Active', 0.1315, NULL,    5, 2,    NULL, NULL, 0.1320, 0.1315, NULL),
    ('PS-6061-FL1-001', 'FM2_S2',    'Active', 0.1308, NULL,    6, 3,    NULL, NULL, 0.1315, 0.1308, NULL),
    ('PS-6061-FL1-001', 'FM2_S3',    'Active', 0.1300, NULL,    7, 4,    NULL, NULL, 0.1308, 0.1300, NULL);

-- ── 10 · PS-1100-FL3-001 · Hybrid · Active ──────────────────
-- Widest product in portfolio: 0.085" × 0.800" on FL3.
-- High aspect ratio (9.41) requires full FM2 sequence.
-- FM2 progressively closes from FM1 output (0.087") to target (0.085").
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [DrawerId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL3-001', 'DB1',       'Active', 0.3300, NULL,     1, NULL, 6,    NULL, 0.3750, 0.3300, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'DB2',       'Active', 0.2700, NULL,     2, NULL, 7,    NULL, 0.3300, 0.2700, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM1',       'Active', 0.0855, NULL,     3, 1,    NULL, NULL, 0.2700, 0.0870, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'EdgeSet',   'Active', 0.0017, 'Square', 4, NULL, NULL, 2,    0.0870, 0.0870, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM2_S1',    'Active', 0.0862, NULL,     5, 2,    NULL, NULL, 0.0870, 0.0862, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM2_S2',    'Active', 0.0856, NULL,     6, 3,    NULL, NULL, 0.0862, 0.0856, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM2_S3',    'Active', 0.0850, NULL,     7, 4,    NULL, NULL, 0.0856, 0.0850, 'FLS-2024-075');

END  -- idempotent component-block guard
GO

-- ============================================================
-- PassScheduleChangeLog — override / edit / acknowledgment audit
-- (RunId here is a soft reference — populated once runs are seeded)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[PassScheduleChangeLog])
INSERT INTO [dbo].[PassScheduleChangeLog]
    ([PassScheduleId],[ChangeType],[ParameterName],[OldValue],[NewValue],[ReasonCode],[ReasonNotes],[RunId],[OperatorId],[Timestamp])
VALUES
    ('PS-1100-FL1-001','Edit',          'FM1.RollGap','0.1080','0.1085','ProcessUpdate','Gauge centering tweak',        NULL,      'Bob S.', '2026-04-21 08:30:00 -05:00'),
    ('PS-3003-FL1-001','Override',      'DB2.Die',    '0.3000','0.2980','DieWear',      'Applied mid-run at RUN-0003',  'RUN-0003','Tim O.', '2026-07-21 07:16:00 -05:00'),
    ('PS-1100-FL1-001','Acknowledgment',NULL,         NULL,    NULL,    NULL,           'Operator acknowledged at check-in','RUN-0001','Dave M.','2026-07-20 06:30:00 -05:00');
GO
