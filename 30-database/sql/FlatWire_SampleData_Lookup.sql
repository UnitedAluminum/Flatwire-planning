-- ============================================================
-- Flat Wire Mill — Sample Data: Lookup / Reference Tables
-- Run order : after DDL 06 (FKs), BEFORE FlatWire_SampleData_Schedule
-- Tables    : Stand, Drawer, ToolingInventoryDie, Edger, Dancer,
--             AlloyProperty, Spool
-- ============================================================
-- These fixed IDENTITY values are the FK targets the schedule
-- sample data (FlatWire_SampleData_Schedule.sql) references:
--   Stand.Id  1=FM1  2=FM2_S1  3=FM2_S2  4=FM2_S3
--   Drawer.Id 1=DB1  2=DB2   (the two draw boxes; the schedule no longer
--             references them at all -- DrawerId was dropped 2 Sep 2026)
--   Edger.Id  1=Round  2=Square
-- ToolingInventoryDie.Id 1..14 are the FK targets for
--   FlatWire_SampleData_Runs.sql's DieChangeEvent.OldDieId / NewDieId.
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
-- Drawer  (the two DRAW BOXES -- not the dies)
--
-- Two rows is the whole table. CK_Drawer_Name admits only DB1 and DB2 and
-- UQ_Drawer_Name makes each unique, so a third row is impossible without a
-- schema change -- the cap is structural, not seeded.
--
-- LineId FL1 for both: FL1 owns the physical boxes and FL3 runs through them,
-- as it shares FL1's VPS payoff. Client-confirmed 31 Aug 2026 -- the Tooling
-- Inventory grid attributes dies to Machine Name = FL1 and NO FL3 row appears
-- in any of the three tool grids.
--
-- The 13 die-SIZE rows that used to live here moved to ToolingInventoryDie on
-- 2 Sep 2026 as physical dies, with the die-life counters. See 01_Lookup.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Drawer])
BEGIN
    SET IDENTITY_INSERT [dbo].[Drawer] ON;
    INSERT INTO [dbo].[Drawer] ([Id], [Name], [LineId], [IsActive]) VALUES
        (1, 'DB1', 'FL1', 1),
        (2, 'DB2', 'FL1', 1);
    SET IDENTITY_INSERT [dbo].[Drawer] OFF;
    PRINT 'Seeded: Drawer (2 rows)';
END
ELSE
    PRINT 'Drawer already seeded — skipped';
GO

-- ============================================================
-- ToolingInventoryDie  (physical dies -- one row per TOOL, not per size)
--
-- Fourteen rows: the thirteen working hole diameters that used to be the
-- Drawer catalogue, seeded as one physical die each, PLUS a 0.2980 die.
--
-- WHY THE FOURTEENTH EXISTS -- a pre-existing seed defect this split exposed.
-- FlatWire_SampleData_Runs.sql seeds DieChangeEvent DC-0001 with
-- NewDieSizeIn = 0.2980, and 0.2980 was never one of the 13 catalogue sizes.
-- So the sample data has always described an installation that D4 -- in either
-- its size-level or its per-tool form -- should have REFUSED. It passed
-- silently because nothing was a foreign key. Now that NewDieId is one, that
-- row needs a tool to point at. The event is left alone deliberately: its
-- GaugeDrift-at-footage-1200 path with a linked RollOverride is the only
-- worked example of that flow in the seed set.
--
-- Die life: LastGrindingFeet seeds at 0 -- a fresh counter, which is a fact
-- rather than an assumption. TotalFeetAllowed seeds NULL: OQ-83 records
-- die-life tracking as decided but the THRESHOLD as TBD, and an invented
-- engineering limit is worse than no limit. Same discipline as
-- AlloyProperty's rod-diameter tolerances.
--
-- LifecycleStatus 'In Service' and InUse 0: serviceable, none fitted to a
-- line. FR-253's Spare band is DERIVED from exactly that pair plus zero
-- footage, so these rows read as Spare on the Die Management screen without
-- storing a band. SerialNo / PartNo / Location / Pitch / MaxIdIn /
-- LubricationType stay NULL -- they are client grid columns and the client has
-- not supplied values. UX_ToolingInventoryDie_SerialNo is FILTERED in script
-- 07 precisely so fourteen NULL serials are legal.
--
-- DieType is NULL, not guessed: FR-247 offers TC Mono / TC Poly / Natural
-- diamond and nothing on record says which of the three these are.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[ToolingInventoryDie])
BEGIN
    SET IDENTITY_INSERT [dbo].[ToolingInventoryDie] ON;
    INSERT INTO [dbo].[ToolingInventoryDie]
        ([Id], [DieAlpha], [HoleSizeIn], [LineId], [LifecycleStatus], [InUse], [LastGrindingFeet], [TotalFeetAllowed], [IsActive]) VALUES
        ( 1, 'D-210-001', 0.2100, NULL, 'In Service', 0, 0, NULL, 1),
        ( 2, 'D-240-001', 0.2400, NULL, 'In Service', 0, 0, NULL, 1),
        ( 3, 'D-250-001', 0.2500, NULL, 'In Service', 0, 0, NULL, 1),
        ( 4, 'D-265-001', 0.2650, NULL, 'In Service', 0, 0, NULL, 1),
        ( 5, 'D-315-001', 0.3150, NULL, 'In Service', 0, 0, NULL, 1),
        ( 6, 'D-330-001', 0.3300, NULL, 'In Service', 0, 0, NULL, 1),
        ( 7, 'D-270-001', 0.2700, NULL, 'In Service', 0, 0, NULL, 1),
        ( 8, 'D-275-001', 0.2750, NULL, 'In Service', 0, 0, NULL, 1),
        ( 9, 'D-300-001', 0.3000, NULL, 'In Service', 0, 0, NULL, 1),
        (10, 'D-310-001', 0.3100, NULL, 'In Service', 0, 0, NULL, 1),
        (11, 'D-320-001', 0.3200, NULL, 'In Service', 0, 0, NULL, 1),
        (12, 'D-335-001', 0.3350, NULL, 'In Service', 0, 0, NULL, 1),
        (13, 'D-340-001', 0.3400, NULL, 'In Service', 0, 0, NULL, 1),
        -- The DC-0001 die. See the note above; do not delete without fixing that event.
        (14, 'D-298-001', 0.2980, NULL, 'In Service', 0, 0, NULL, 1);
    SET IDENTITY_INSERT [dbo].[ToolingInventoryDie] OFF;
    PRINT 'Seeded: ToolingInventoryDie (14 rows)';
END
ELSE
    PRINT 'ToolingInventoryDie already seeded — skipped';
GO

-- ============================================================
-- ToolingInventoryRollSet  (physical roll sets -- the fourth tool type)
--
-- Six rows: one set per fitted position. Client mail 3 Sep 2026 names the
-- positions -- 12" (FL1-S1), 8"/6"/6" (FL2-S1, FL2-S2, FL2-S3), and DB1/DB2
-- capstans -- and the diameters come straight from that sentence.
--
-- ONE SET PER POSITION IS A FLOOR, NOT THE CLIENT'S COUNT. The mail says
-- "12" (FL1-S1) 2 roll set", "DB1/DB2 Capstans (rolls) current inventory = 2,
-- will be adding a spare", and "8", 6", 6" rolls for (FL2-S1, FL2-S2, FL2-S3)
-- 2 roll sets". Whether "2 roll set(s)" means TWO ROLLS PER SET or TWO SETS PER
-- POSITION is genuinely ambiguous in the source, and it reads both ways in one
-- paragraph. RollQty = 2 records the first reading, which the edger grid's
-- "Roll Qty 2" corroborates; the second reading would change the ROW COUNT and
-- is left unseeded rather than guessed. Q92 asks. Do not multiply these rows
-- until it comes back.
--
-- The spare is NOT seeded either: "will be adding a spare" is future tense, so
-- 2 capstan sets is today's truth and 3 is the target. Seeding the third would
-- record equipment that does not exist yet.
--
-- IsRefurbishable = 1 on the capstans only. That is the one word the client
-- attached to them specifically ("they can be refurbished"); nothing on record
-- says the mill rolls are, and 0 is the DEFAULT rather than a claim they are not.
--
-- NAMING: the client calls FM1 "FL1-S1". Our Stand row is FM1 and stays FM1 --
-- the component-identifier reconciliation is deliberately deferred until the
-- Speed tab lands (31 Aug 2026 mail analysis, section 4.8, action A12).
--
-- LineId FL1/FL2 only: FL3 uses a combination of the two and holds no tooling of
-- its own (client, 3 Sep 2026). Capstan sets are FL1 -- DB1/DB2 sit on FL1 --
-- though whether the client's "Machine Name" column would say FL1 or the draw box
-- is one of Q92's four questions.
--
-- OD / MinOD / ID / SerialNo / PartNo / Location / SetNumber stay NULL: they are
-- client grid columns and no roll-set grid has ever been supplied. G87.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[ToolingInventoryRollSet])
BEGIN
    SET IDENTITY_INSERT [dbo].[ToolingInventoryRollSet] ON;
    INSERT INTO [dbo].[ToolingInventoryRollSet]
        ([Id], [RollSetAlpha], [RollType], [StandId], [DrawerId], [LineId], [RollQty], [NominalDiameterIn], [LifecycleStatus], [IsRefurbishable], [InUse], [IsActive]) VALUES
        (1, 'RS-FM1-001',   'Mill',    1,    NULL, 'FL1', 2, 12.000, 'In Service', 0, 0, 1),
        (2, 'RS-FM2S1-001', 'Mill',    2,    NULL, 'FL2', 2,  8.000, 'In Service', 0, 0, 1),
        (3, 'RS-FM2S2-001', 'Mill',    3,    NULL, 'FL2', 2,  6.000, 'In Service', 0, 0, 1),
        (4, 'RS-FM2S3-001', 'Mill',    4,    NULL, 'FL2', 2,  6.000, 'In Service', 0, 0, 1),
        -- Capstan rolls. NominalDiameterIn NULL: the mail gives no capstan diameter.
        (5, 'RS-DB1-001',   'Capstan', NULL, 1,    'FL1', 2, NULL,   'In Service', 1, 0, 1),
        (6, 'RS-DB2-001',   'Capstan', NULL, 2,    'FL1', 2, NULL,   'In Service', 1, 0, 1);
    SET IDENTITY_INSERT [dbo].[ToolingInventoryRollSet] OFF;
    PRINT 'Seeded: ToolingInventoryRollSet (6 rows)';
END
ELSE
    PRINT 'ToolingInventoryRollSet already seeded — skipped';
GO

-- NO SEED: DieHistory -- a die's life story is empty until the line runs. Its
-- rows are written by the die change (Install), by Die Management (Reset,
-- Retire, ThresholdEdit) and per run by FR-255's footage accrual (RunFootage),
-- so any seeded row would be a fiction about production that never happened.
-- Deliberate, not an omission. Same bargain as PayoffPosition below.

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
-- SupportsTensionMode is set only on FM2's pair, and as of 2 Sep 2026 that is
-- a FACT rather than a default. The client (Tim O'Brien, 1 Sep 2026, answer 5)
-- states tension mode is available "on FL2 however it will only work with
-- heavier & larger dimension products" -- FL2 only, so FM1, an FL1 component,
-- genuinely has none. FM1's 0 previously recorded "not stated"; it now records
-- "no". PLC-Q18 stays open on the tag surface, not on this value.
-- The same answer settles the MODE question the C6 / D-28 conflict held open
-- since 12 Aug: control is the machine program, each dancer holds a position
-- range, and it "will not be adjustable from an operator standpoint and will
-- remain constant". Nobody selects the mode -- not the operator, not the pass
-- schedule -- so no write surface is owed and the read-only PLC dancer element
-- was the correct call.
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

-- NO SEED: DowntimeReason
-- NO SEED: WipRejectionReason
-- NO SEED: ItInhibitReason
-- All three are seeded by FlatWire_DDL_01_Lookup.sql itself, for the same
-- reason as PayoffPosition and one more that matters more: they are PRODUCTION
-- REFERENCE DATA, not fixtures. The 156 rows come from the client's 1 Sep 2026
-- "Reason Codes.xlsx" (72 delay codes, 72 WIP rejection reasons, 12 IT inhibit
-- reasons), and a production deploy runs RunAll WITHOUT this file. Seeded here
-- instead, the pause and rejection dialogs would come up empty in production
-- while looking perfectly healthy in every environment where the sample data
-- had been loaded -- and the trial would not catch it.
-- Deliberate, not an omission.

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
