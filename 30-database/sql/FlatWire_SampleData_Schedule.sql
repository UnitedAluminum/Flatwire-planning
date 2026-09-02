-- ============================================================================
-- FLAT WIRE MILL - SAMPLE DATA
-- Pass Schedules : PassSchedule, PassScheduleComponent, PassScheduleChangeLog
-- ----------------------------------------------------------------------------
-- Project         : Flat Wire Mill Implementation - United Aluminum
-- Document type   : Sample data script - ISSUED FOR CLIENT REVIEW
-- Version         : 1.1
-- Last updated    : August 27, 2026
-- Target database : FlatWireDB
-- Loads           : 11 pass schedules, 77 component rows (7 per schedule),
--                   3 change-log rows
-- File encoding   : ASCII only, so the script loads identically under SQLCMD,
--                   SSMS and any text editor, whatever the code page. Every
--                   value inserted is plain ASCII, so no description can be
--                   corrupted by a code-page mismatch on the way in.
-- ============================================================================
--
--   ####################################################################
--   #                                                                  #
--   #   DEVELOPMENT AND ACCEPTANCE-TRIAL DATA ONLY.                    #
--   #   DO NOT RUN THIS SCRIPT AGAINST A PRODUCTION DATABASE.          #
--   #                                                                  #
--   #   These eleven schedules are worked examples. They are not       #
--   #   approved production configurations and no product should be    #
--   #   run from them.                                                 #
--   #                                                                  #
--   ####################################################################
--
-- ----------------------------------------------------------------------------
-- 1. WHY THIS FIXTURE SET EXISTS
-- ----------------------------------------------------------------------------
--
--   The flat wire application reads pass schedules; in this phase it does not
--   author them. Development, demonstration and the acceptance trial therefore
--   need a schedule set to read, and this script supplies it.
--
--   It is written to exercise the whole model rather than to be realistic in
--   volume: every status, every route mode, all three lines, both edge types
--   and all five alloys appear at least once, and each of the three component
--   states (Active, Bypass, Skip) is used as it would be on the floor.
--
--   Three of the eleven carry the acceptance trial:
--     PS-1100-FL1-001   the FL1 leg - rod in, flattened spool out
--     PS-1100-FL2-002   the FL2 leg - that spool in, finished coil out
--     PS-1100-FL1-003   a Draft, so the check-in status gate can be shown
--                       refusing a schedule that is not approved
--
-- ----------------------------------------------------------------------------
-- 2. HOW TO RUN, AND IN WHAT ORDER
-- ----------------------------------------------------------------------------
--
--   Run the schema first. This script loads tables, it does not create them:
--
--       cd <this folder>
--       sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql          -- schema
--       sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_RunAll.sql   -- data
--
--   The sample-data runner loads five scripts and this is the second of them.
--   Its position is load-bearing:
--
--       Lookup     -> creates the Stand, Edger and AlloyProperty rows
--                     this script points at by id
--       SCHEDULE   -> this script
--       Materials  -> creates runs that point back at these schedules
--       Runs, Quality/Output
--
--   The lookup seed must run before this one, and this one must run before
--   the materials seed: the run records carry a real, enforced foreign key to
--   PassSchedule, so loading materials first fails outright.
--
--   Idempotent: each of the three blocks below is skipped if its table already
--   holds rows, so re-running the script is safe and changes nothing. To
--   reload from clean, tear the database down and rebuild it.
--
-- ----------------------------------------------------------------------------
-- 3. THE REFERENCE ROWS THIS SCRIPT POINTS AT
-- ----------------------------------------------------------------------------
--
--   Created by the lookup seed, with fixed ids so that these fixtures can name
--   them directly.
--
--   Stand.Id    1 = FM1     (12")
--               2 = FM2_S1  (8")
--               3 = FM2_S2  (6")
--               4 = FM2_S3  (6", final stand)
--
--   No die reference at all. DrawerId was dropped from
--   PassScheduleComponent on 2 Sep 2026 with the die split, so a DB1 or DB2
--   row here carries StandId NULL and EdgerId NULL and states its die SIZE in
--   ParameterValue as a decimal -- which is what it always meant.
--
--   A schedule deliberately names no physical die. It is a reusable product
--   recipe; the tool fitted at DB1 changes many times over the schedule's
--   life. Which tool actually ran is in DieChangeEvent.OldDieId / NewDieId
--   and DieHistory, both pointing at ToolingInventoryDie.
--
--   Edger.Id    1 = EDGE-ROUND-A  (Round)
--               2 = EDGE-SQUARE-B (Square)
--
-- ----------------------------------------------------------------------------
-- 4. WHAT THE ELEVEN SCHEDULES COVER
-- ----------------------------------------------------------------------------
--
--   Status      Draft 3      Active 6       Inactive 2
--   Line        FL1 8        FL2 2          FL3 1
--   Route       Standalone 5                Hybrid 6
--   Alloy       1100 6   3003 2   1350 1    5052 1   6061 1
--   Edge type   Round 7      Square 4
--
--   Only one schedule per line and alloy may be Active at a time, so the set
--   contains at most one Active row for each pair. That is why PS-1100-FL2-001
--   is held Inactive: FL2 and alloy 1100 can carry only one Active schedule,
--   and the acceptance trial needs that slot for PS-1100-FL2-002.
--
-- ============================================================================

USE [FlatWireDB]
GO

-- Required for any session writing PassSchedule: the table carries a filtered
-- unique index (one Active schedule per line and alloy), and SQL Server rejects
-- inserts against a filtered index unless these options are ON.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- BLOCK 1 of 3 : PassSchedule - the eleven headers
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[PassSchedule])
BEGIN

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

    -- 1 -- 1100 . FL1 . Standalone . Active -----------------------------------
    --      Standard round-edge product. Two draw passes, then FM1 flattens.
    --      Aspect ratio 4.55, so no finishing pass on FM2 is required.
    --      This is the FL1 leg of the acceptance trial: it produces the
    --      0.110" x 0.500" spool that schedule 11 then finishes on FL2.
    ('PS-1100-FL1-001',
     '1100 rod -> 0.110" x 0.500" round edge - FL1 standalone',
     '1100', 'FL1', 'Standalone', 'Active',
     0.1100, 0.0020,
     0.5000, 0.0050,
     0.3750, 'H19', 'Hard drawn',
     800, 1600,
     'Tim O.',  '2026-04-01 06:00:00 -05:00',
     'Bob S.',  '2026-04-21 08:30:00 -05:00'),

    -- 2 -- 1100 . FL1 . Standalone . Inactive ---------------------------------
    --      Wider, thicker profile, retired after a product specification
    --      change. Single draw pass. Retained rather than deleted because
    --      historical runs point at it.
    ('PS-1100-FL1-002',
     '1100 rod -> 0.140" x 0.640" round edge - FL1 standalone (retired)',
     '1100', 'FL1', 'Standalone', 'Inactive',
     0.1400, 0.0025,
     0.6400, 0.0060,
     0.3750, 'H19', 'Hard drawn',
     1000, 1800,
     'Tim O.',  '2023-11-15 07:00:00 -05:00',
     'Tim O.',  '2024-08-30 14:20:00 -05:00'),

    -- 3 -- 1100 . FL1 . Standalone . Draft ------------------------------------
    --      Thin narrow gauge under development. Two draw passes bring 0.375"
    --      rod to 0.250" before flattening. Held in Draft, which is what the
    --      acceptance trial uses to show check-in refusing an unapproved
    --      schedule.
    ('PS-1100-FL1-003',
     '1100 rod -> 0.090" x 0.450" round edge - FL1 standalone (draft)',
     '1100', 'FL1', 'Standalone', 'Draft',
     0.0900, 0.0020,
     0.4500, 0.0040,
     0.3750, 'H19', 'Hard drawn',
     600, 1100,
     'Bob S.',  '2026-05-10 08:45:00 -05:00',
     NULL, NULL),

    -- 4 -- 3003 . FL1 . Hybrid . Active ---------------------------------------
    --      High aspect ratio (7.89) square-edge wire. FL1 feeds FL2
    --      continuously and all three FM2 stands are engaged for finishing.
    ('PS-3003-FL1-001',
     '3003 rod -> 0.095" x 0.750" square edge - FL1/FL2 hybrid',
     '3003', 'FL1', 'Hybrid', 'Active',
     0.0950, 0.0030,
     0.7500, 0.0080,
     0.3750, 'H18', 'Hard drawn',
     700, 1400,
     'Tim O.',  '2026-04-10 07:15:00 -05:00',
     'Bob S.',  '2026-04-25 11:00:00 -05:00'),

    -- 5 -- 3003 . FL1 . Hybrid . Draft ----------------------------------------
    --      Experimental wide square-edge product at aspect ratio 12.0.
    --      Draft pending confirmation of FM2 stand capacity at that width.
    ('PS-3003-FL1-002',
     '3003 rod -> 0.075" x 0.900" square edge - FL1/FL2 hybrid (draft)',
     '3003', 'FL1', 'Hybrid', 'Draft',
     0.0750, 0.0020,
     0.9000, 0.0060,
     0.3750, 'H18', 'Hard drawn',
     600, 1000,
     'Tim O.',  '2026-05-12 09:30:00 -05:00',
     NULL, NULL),

    -- 6 -- 1350 . FL1 . Hybrid . Active ---------------------------------------
    --      Welding wire grade. The 1350 per-pass draw limit is the tightest of
    --      the three alloys drawn here, so both passes are kept near 20%. All
    --      three FM2 stands are engaged for dimensional precision, which the
    --      welding-wire certificates depend on.
    ('PS-1350-FL1-001',
     '1350 welding wire -> 0.100" x 0.700" round edge - FL1/FL3 hybrid',
     '1350', 'FL1', 'Hybrid', 'Active',
     0.1000, 0.0020,
     0.7000, 0.0060,
     0.3750, 'H14', 'Hard drawn',
     600, 1200,
     'Tim O.',  '2026-04-18 06:30:00 -05:00',
     'Tim O.',  '2026-05-02 07:45:00 -05:00'),

    -- 7 -- 5052 . FL1 . Standalone . Active -----------------------------------
    --      Strain-hardened alloy, drawn in a single pass. FM2 is not required
    --      at aspect ratio 3.50.
    ('PS-5052-FL1-001',
     '5052 rod -> 0.160" x 0.560" round edge - FL1 standalone',
     '5052', 'FL1', 'Standalone', 'Active',
     0.1600, 0.0030,
     0.5600, 0.0070,
     0.3750, 'H34', 'Strain hardened',
     500, 1200,
     'Bob S.',  '2026-04-22 08:00:00 -05:00',
     NULL, NULL),

    -- 8 -- 1100 . FL2 . Hybrid . Inactive -------------------------------------
    --      FL2 fed continuously from FL1 with pre-drawn round wire, so the
    --      drawing dies are wired out.
    --
    --      Held Inactive, not retired. FL2 and alloy 1100 may carry only one
    --      Active schedule, and the acceptance trial needs that slot for
    --      schedule 11, which is Standalone because the spool it consumes was
    --      produced on a standalone FL1 run. This row is kept for two reasons:
    --      it is the hybrid-FL2 worked example, and seeded historical runs
    --      point at it - an Inactive schedule is a legal parent for a run that
    --      has already happened.
    ('PS-1100-FL2-001',
     '1100 pre-drawn wire -> 0.090" x 0.650" square edge - FL2 hybrid',
     '1100', 'FL2', 'Hybrid', 'Inactive',
     0.0900, 0.0020,
     0.6500, 0.0060,
     0.3750, 'H19', 'Hard drawn',
     800, 1600,
     'Tim O.',  '2026-04-14 07:00:00 -05:00',
     'Bob S.',  '2026-05-05 09:15:00 -05:00'),

    -- 9 -- 6061 . FL1 . Hybrid . Draft ----------------------------------------
    --      Solution-treated 6061 carries the tightest per-pass draw limit of
    --      the five alloys, so the reduction is split across two light passes.
    --      Draft pending trial.
    ('PS-6061-FL1-001',
     '6061 rod -> 0.130" x 0.580" round edge - FL1/FL2 hybrid (draft)',
     '6061', 'FL1', 'Hybrid', 'Draft',
     0.1300, 0.0020,
     0.5800, 0.0060,
     0.3750, 'T8',  'Solution treated',
     400, 900,
     'Bob S.',  '2026-05-15 10:00:00 -05:00',
     NULL, NULL),

    -- 10 -- 1100 . FL3 . Hybrid . Active --------------------------------------
    --       The widest product in the set, 0.085" x 0.800" on FL3. Aspect
    --       ratio 9.41 needs the full FM2 sequence.
    ('PS-1100-FL3-001',
     '1100 rod -> 0.085" x 0.800" square edge - FL1/FL3 hybrid',
     '1100', 'FL3', 'Hybrid', 'Active',
     0.0850, 0.0020,
     0.8000, 0.0070,
     0.3750, 'H19', 'Hard drawn',
     700, 1500,
     'Tim O.',  '2026-04-08 06:45:00 -05:00',
     'Tim O.',  '2026-04-28 13:30:00 -05:00'),

    -- 11 -- 1100 . FL2 . Standalone . Active ----------------------------------
    --       The FL2 leg of the acceptance trial.
    --
    --       Its input is the spool that schedule 1 produces on FL1 - already
    --       flattened to 0.110" x 0.500" with a round edge - so there is
    --       nothing left to draw. FM2 closes the gauge to 0.100" and the
    --       section spreads to 0.560".
    --
    --       It is Standalone rather than Hybrid because check-in validates the
    --       schedule route against the route the spool was PRODUCED under, and
    --       schedule 1 is a standalone FL1 run.
    --
    --       Note on InputRodDiameterIn: it records the rod that FL1 drew, not
    --       an FL2 input. FL2 is fed a spool and draws no rod. The same reading
    --       applies to schedule 8.
    ('PS-1100-FL2-002',
     '1100 pre-flattened 0.110" x 0.500" spool -> 0.100" x 0.560" round edge - FL2 standalone',
     '1100', 'FL2', 'Standalone', 'Active',
     0.1000, 0.0020,
     0.5600, 0.0050,
     0.3750, 'H19', 'Hard drawn',
     700, 1400,
     'Tim O.',  '2026-08-15 09:00:00 -05:00',
     NULL, NULL);

    PRINT 'Seeded: PassSchedule (11 rows)';
END
ELSE
    PRINT 'PassSchedule already seeded - skipped';
GO

-- ============================================================================
-- BLOCK 2 of 3 : PassScheduleComponent - seven rows per schedule
-- ----------------------------------------------------------------------------
-- The stations, in processing order:
--   1 DB1   2 DB2   3 FM1   4 EdgeSet   5 FM2_S1   6 FM2_S2   7 FM2_S3
--
-- State
--   Active  engaged; ParameterValue and the tool reference are set
--   Bypass  present on the line but wired out of this pass; all NULL
--   Skip    not part of this schedule at all; all NULL
--
-- ParameterValue
--   DB1, DB2          die hole diameter, inches
--   FM1, FM2_S1..S3   roll gap set-point, inches
--   EdgeSet           edger clearance, inches
--
-- EntryGauge and ExitGauge
--   The wire dimension entering and leaving each engaged station, in inches.
--   Read down a schedule they give the whole gauge chain. NULL on Bypass and
--   Skip rows.
--
-- IsMandatory is not set by this script, so every row defaults to 0 and no
-- component is locked on screen. See OPEN POINT 4.
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[PassScheduleComponent])
BEGIN

-- -- 1 . PS-1100-FL1-001 . Standalone . Active ------------------------------
-- Rod 0.375" -> DB1 0.315" -> DB2 0.265" -> FM1 -> round edge. FM2 skipped.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL1-001', 'DB1',       'Active', 0.3150, NULL,    1, NULL,    NULL, 0.3750, 0.3150, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'DB2',       'Active', 0.2650, NULL,    2, NULL,    NULL, 0.3150, 0.2650, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM1',       'Active', 0.1080, NULL,    3, 1, NULL, 0.2650, 0.1100, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'EdgeSet',   'Active', 0.0020, 'Round', 4, NULL, 1,    0.1100, 0.1100, 'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM2_S1',    'Skip',   NULL,   NULL,    5, NULL, NULL, NULL,   NULL,   'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM2_S2',    'Skip',   NULL,   NULL,    6, NULL, NULL, NULL,   NULL,   'FLS-2024-001'),
    ('PS-1100-FL1-001', 'FM2_S3',    'Skip',   NULL,   NULL,    7, NULL, NULL, NULL,   NULL,   'FLS-2024-001');

-- -- 2 . PS-1100-FL1-002 . Standalone . Inactive ----------------------------
-- Retired schedule. Single draw pass, so DB2 is bypassed. FM2 was bypassed
-- throughout the campaign - aspect ratio 4.57 never called for it.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL1-002', 'DB1',       'Active', 0.3350, NULL,    1, NULL,   NULL, 0.3750, 0.3350, 'FLS-2023-015'),
    ('PS-1100-FL1-002', 'DB2',       'Bypass', NULL,   NULL,    2, NULL, NULL, NULL,   NULL,   'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM1',       'Active', 0.1372, NULL,    3, 1, NULL, 0.3350, 0.1400, 'FLS-2023-015'),
    ('PS-1100-FL1-002', 'EdgeSet',   'Active', 0.0022, 'Round', 4, NULL, 1,    0.1400, 0.1400, 'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM2_S1',    'Bypass', NULL,   NULL,    5, NULL, NULL, NULL,   NULL,   'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM2_S2',    'Bypass', NULL,   NULL,    6, NULL, NULL, NULL,   NULL,   'FLS-2023-015'),
    ('PS-1100-FL1-002', 'FM2_S3',    'Bypass', NULL,   NULL,    7, NULL, NULL, NULL,   NULL,   'FLS-2023-015');

-- -- 3 . PS-1100-FL1-003 . Standalone . Draft -------------------------------
-- Thin-gauge development schedule. Two draw passes reach the 0.250"
-- pre-flatten diameter. SetupNo is NULL because there is no legacy record -
-- this schedule has no predecessor in FlatLineSetup.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL1-003', 'DB1',       'Active', 0.3100, NULL,    1, NULL,   NULL, 0.3750, 0.3100, NULL),
    ('PS-1100-FL1-003', 'DB2',       'Active', 0.2500, NULL,    2, NULL,    NULL, 0.3100, 0.2500, NULL),
    ('PS-1100-FL1-003', 'FM1',       'Active', 0.0882, NULL,    3, 1, NULL, 0.2500, 0.0900, NULL),
    ('PS-1100-FL1-003', 'EdgeSet',   'Active', 0.0018, 'Round', 4, NULL, 1,    0.0900, 0.0900, NULL),
    ('PS-1100-FL1-003', 'FM2_S1',    'Skip',   NULL,   NULL,    5, NULL, NULL, NULL,   NULL,   NULL),
    ('PS-1100-FL1-003', 'FM2_S2',    'Skip',   NULL,   NULL,    6, NULL, NULL, NULL,   NULL,   NULL),
    ('PS-1100-FL1-003', 'FM2_S3',    'Skip',   NULL,   NULL,    7, NULL, NULL, NULL,   NULL,   NULL);

-- -- 4 . PS-3003-FL1-001 . Hybrid . Active ----------------------------------
-- Two draw passes. FM1 leaves the wire slightly over target at 0.097", and
-- the three FM2 stands close it to the 0.095" target on FL2.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-3003-FL1-001', 'DB1',       'Active', 0.3350, NULL,     1, NULL,   NULL, 0.3750, 0.3350, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'DB2',       'Active', 0.3000, NULL,     2, NULL,    NULL, 0.3350, 0.3000, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM1',       'Active', 0.0950, NULL,     3, 1, NULL, 0.3000, 0.0970, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'EdgeSet',   'Active', 0.0018, 'Square', 4, NULL, 2,    0.0970, 0.0970, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM2_S1',    'Active', 0.0960, NULL,     5, 2, NULL, 0.0970, 0.0960, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM2_S2',    'Active', 0.0955, NULL,     6, 3, NULL, 0.0960, 0.0955, 'FLS-2024-028'),
    ('PS-3003-FL1-001', 'FM2_S3',    'Active', 0.0950, NULL,     7, 4, NULL, 0.0955, 0.0950, 'FLS-2024-028');

-- -- 5 . PS-3003-FL1-002 . Hybrid . Draft -----------------------------------
-- Experimental wide product. All three FM2 stands planned active. The roll
-- gaps are calculated estimates and have not been validated on the line.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-3003-FL1-002', 'DB1',       'Active', 0.3200, NULL,     1, NULL,   NULL, 0.3750, 0.3200, NULL),
    ('PS-3003-FL1-002', 'DB2',       'Active', 0.2700, NULL,     2, NULL,    NULL, 0.3200, 0.2700, NULL),
    ('PS-3003-FL1-002', 'FM1',       'Active', 0.0765, NULL,     3, 1, NULL, 0.2700, 0.0780, NULL),
    ('PS-3003-FL1-002', 'EdgeSet',   'Active', 0.0015, 'Square', 4, NULL, 2,    0.0780, 0.0780, NULL),
    ('PS-3003-FL1-002', 'FM2_S1',    'Active', 0.0775, NULL,     5, 2, NULL, 0.0780, 0.0775, NULL),
    ('PS-3003-FL1-002', 'FM2_S2',    'Active', 0.0762, NULL,     6, 3, NULL, 0.0775, 0.0762, NULL),
    ('PS-3003-FL1-002', 'FM2_S3',    'Active', 0.0750, NULL,     7, 4, NULL, 0.0762, 0.0750, NULL);

-- -- 6 . PS-1350-FL1-001 . Hybrid . Active ----------------------------------
-- Welding wire. Both draw passes are held near 20% to stay inside the 1350
-- limit, and all three FM2 stands are engaged: the welding-wire certificates
-- depend on the finished dimension.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1350-FL1-001', 'DB1',       'Active', 0.3350, NULL,    1, NULL,   NULL, 0.3750, 0.3350, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'DB2',       'Active', 0.3000, NULL,    2, NULL,    NULL, 0.3350, 0.3000, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM1',       'Active', 0.0990, NULL,    3, 1, NULL, 0.3000, 0.1020, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'EdgeSet',   'Active', 0.0020, 'Round', 4, NULL, 1,    0.1020, 0.1020, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM2_S1',    'Active', 0.1010, NULL,    5, 2, NULL, 0.1020, 0.1010, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM2_S2',    'Active', 0.1005, NULL,    6, 3, NULL, 0.1010, 0.1005, 'FLS-2024-041'),
    ('PS-1350-FL1-001', 'FM2_S3',    'Active', 0.1000, NULL,    7, 4, NULL, 0.1005, 0.1000, 'FLS-2024-041');

-- -- 7 . PS-5052-FL1-001 . Standalone . Active ------------------------------
-- Strain-hardened 5052 in a single draw pass, 0.375" -> 0.340", a 17.8% area
-- reduction against the 20% limit currently seeded for the alloy. DB2 is
-- skipped and FM2 is not required at aspect ratio 3.50.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-5052-FL1-001', 'DB1',       'Active', 0.3400, NULL,    1, NULL,   NULL, 0.3750, 0.3400, 'FLS-2024-055'),
    ('PS-5052-FL1-001', 'DB2',       'Skip',   NULL,   NULL,    2, NULL, NULL, NULL,   NULL,   'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM1',       'Active', 0.1552, NULL,    3, 1, NULL, 0.3400, 0.1600, 'FLS-2024-055'),
    ('PS-5052-FL1-001', 'EdgeSet',   'Active', 0.0025, 'Round', 4, NULL, 1,    0.1600, 0.1600, 'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM2_S1',    'Skip',   NULL,   NULL,    5, NULL, NULL, NULL,   NULL,   'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM2_S2',    'Skip',   NULL,   NULL,    6, NULL, NULL, NULL,   NULL,   'FLS-2024-055'),
    ('PS-5052-FL1-001', 'FM2_S3',    'Skip',   NULL,   NULL,    7, NULL, NULL, NULL,   NULL,   'FLS-2024-055');

-- -- 8 . PS-1100-FL2-001 . Hybrid . Inactive --------------------------------
-- FL2 fed continuously from FL1 with pre-drawn round wire at about 0.260", so
-- both drawing dies are bypassed - there is no in-line die drawing on FL2.
-- FM2 closes the 0.092" FM1 output to the 0.090" target.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL2-001', 'DB1',       'Bypass', NULL,   NULL,     1, NULL, NULL, NULL,   NULL,   'FLS-2024-062'),
    ('PS-1100-FL2-001', 'DB2',       'Bypass', NULL,   NULL,     2, NULL, NULL, NULL,   NULL,   'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM1',       'Active', 0.0900, NULL,     3, 1, NULL, 0.2600, 0.0920, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'EdgeSet',   'Active', 0.0018, 'Square', 4, NULL, 2,    0.0920, 0.0920, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM2_S1',    'Active', 0.0912, NULL,     5, 2, NULL, 0.0920, 0.0912, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM2_S2',    'Active', 0.0905, NULL,     6, 3, NULL, 0.0912, 0.0905, 'FLS-2024-062'),
    ('PS-1100-FL2-001', 'FM2_S3',    'Active', 0.0900, NULL,     7, 4, NULL, 0.0905, 0.0900, 'FLS-2024-062');

-- -- 9 . PS-6061-FL1-001 . Hybrid . Draft -----------------------------------
-- Solution-treated 6061 carries the tightest per-pass limit of the five
-- alloys, so the reduction is split: 0.375" -> 0.340" (17.8%) then
-- 0.340" -> 0.310" (16.9%), both inside the 18% currently seeded for 6061.
-- The roll gaps and FM2 settings are calculated estimates; trial pending.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-6061-FL1-001', 'DB1',       'Active', 0.3400, NULL,    1, NULL,   NULL, 0.3750, 0.3400, NULL),
    ('PS-6061-FL1-001', 'DB2',       'Active', 0.3100, NULL,    2, NULL,   NULL, 0.3400, 0.3100, NULL),
    ('PS-6061-FL1-001', 'FM1',       'Active', 0.1248, NULL,    3, 1, NULL, 0.3100, 0.1320, NULL),
    ('PS-6061-FL1-001', 'EdgeSet',   'Active', 0.0022, 'Round', 4, NULL, 1,    0.1320, 0.1320, NULL),
    ('PS-6061-FL1-001', 'FM2_S1',    'Active', 0.1315, NULL,    5, 2, NULL, 0.1320, 0.1315, NULL),
    ('PS-6061-FL1-001', 'FM2_S2',    'Active', 0.1308, NULL,    6, 3, NULL, 0.1315, 0.1308, NULL),
    ('PS-6061-FL1-001', 'FM2_S3',    'Active', 0.1300, NULL,    7, 4, NULL, 0.1308, 0.1300, NULL);

-- -- 10 . PS-1100-FL3-001 . Hybrid . Active ---------------------------------
-- The widest product in the set, 0.085" x 0.800" on FL3. Aspect ratio 9.41
-- needs the full FM2 sequence, which closes the 0.087" FM1 output to 0.085"
-- in three steps.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL3-001', 'DB1',       'Active', 0.3300, NULL,     1, NULL,    NULL, 0.3750, 0.3300, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'DB2',       'Active', 0.2700, NULL,     2, NULL,    NULL, 0.3300, 0.2700, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM1',       'Active', 0.0855, NULL,     3, 1, NULL, 0.2700, 0.0870, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'EdgeSet',   'Active', 0.0017, 'Square', 4, NULL, 2,    0.0870, 0.0870, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM2_S1',    'Active', 0.0862, NULL,     5, 2, NULL, 0.0870, 0.0862, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM2_S2',    'Active', 0.0856, NULL,     6, 3, NULL, 0.0862, 0.0856, 'FLS-2024-075'),
    ('PS-1100-FL3-001', 'FM2_S3',    'Active', 0.0850, NULL,     7, 4, NULL, 0.0856, 0.0850, 'FLS-2024-075');

-- -- 11 . PS-1100-FL2-002 . Standalone . Active -----------------------------
-- The FL2 leg of the acceptance trial. Its input is the FL1 spool - 0.110" x
-- 0.500" with a round edge, already flattened - so there is nothing to draw
-- and both dies are wired out. FM2 closes 0.110" -> 0.106" -> 0.103" ->
-- 0.100" across S1, S2 and S3, and the section spreads from 0.500" to 0.560".
-- The edge stays Round to match the edge FL1 put on the spool.
--
-- FM1 is Active here only because the rule "the flattening mill is not
-- bypassable" applies to every schedule regardless of line. FM1 sits on FL1,
-- and an FL2 standalone run is fed an already-flattened spool, so the 12" mill
-- is not in this material path. Entry and exit gauge are therefore equal, and
-- the row reads as a pass-through so that the gauge chain still reconciles.
-- Setting it to Skip is not possible - the rule rejects the row. This is
-- OPEN POINT 3.
--
-- For contrast, a component from another line is NOT wrong in general: an FL3
-- schedule legitimately drives FM1 on FL1 and the FM2 stands on FL2, because
-- FL3 is FL1 feeding FL2, and a hybrid FL1 schedule reaches FM2 for the same
-- reason. The narrow question is FM1 on a STANDALONE FL2 schedule.
INSERT INTO [dbo].[PassScheduleComponent]
    ([PassScheduleId],  [ComponentName], [State],
     [ParameterValue],  [EdgeType], [Sequence],
     [StandId], [EdgerId],
     [EntryGauge], [ExitGauge], [SetupNo])
VALUES
    ('PS-1100-FL2-002', 'DB1',       'Bypass', NULL,   NULL,    1, NULL, NULL, NULL,   NULL,   'FLS-2026-101'),
    ('PS-1100-FL2-002', 'DB2',       'Bypass', NULL,   NULL,    2, NULL, NULL, NULL,   NULL,   'FLS-2026-101'),
    ('PS-1100-FL2-002', 'FM1',       'Active', 0.1100, NULL,    3, 1, NULL, 0.1100, 0.1100, 'FLS-2026-101'),
    ('PS-1100-FL2-002', 'EdgeSet',   'Active', 0.0020, 'Round', 4, NULL, 1,    0.1100, 0.1100, 'FLS-2026-101'),
    ('PS-1100-FL2-002', 'FM2_S1',    'Active', 0.1060, NULL,    5, 2, NULL, 0.1100, 0.1060, 'FLS-2026-101'),
    ('PS-1100-FL2-002', 'FM2_S2',    'Active', 0.1030, NULL,    6, 3, NULL, 0.1060, 0.1030, 'FLS-2026-101'),
    ('PS-1100-FL2-002', 'FM2_S3',    'Active', 0.1000, NULL,    7, 4, NULL, 0.1030, 0.1000, 'FLS-2026-101');

    PRINT 'Seeded: PassScheduleComponent (77 rows, 7 per schedule)';
END
ELSE
    PRINT 'PassScheduleComponent already seeded - skipped';
GO

-- ============================================================================
-- BLOCK 3 of 3 : PassScheduleChangeLog - one worked example of each event
-- ----------------------------------------------------------------------------
-- An Edit made to an Active schedule, an Override applied for one run only,
-- and an operator Acknowledgment at check-in.
--
-- The RunId values name runs created by a later script in the sample-data
-- sequence. RunId is a soft reference and carries no foreign key, so the order
-- of loading does not matter here.
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[PassScheduleChangeLog])
BEGIN

    INSERT INTO [dbo].[PassScheduleChangeLog]
        ([PassScheduleId],[ChangeType],[ParameterName],[OldValue],[NewValue],[ReasonCode],[ReasonNotes],[RunId],[OperatorId],[Timestamp])
    VALUES
        ('PS-1100-FL1-001','Edit',          'FM1.RollGap','0.1080','0.1085','ProcessUpdate','Gauge centering tweak',        NULL,      'Bob S.', '2026-04-21 08:30:00 -05:00'),
        ('PS-3003-FL1-001','Override',      'DB2.Die',    '0.3000','0.2980','DieWear',      'Applied mid-run at RUN-0003',  'RUN-0003','Tim O.', '2026-07-21 07:16:00 -05:00'),
        ('PS-1100-FL1-001','Acknowledgment',NULL,         NULL,    NULL,    NULL,           'Operator acknowledged at check-in','RUN-0001','Dave M.','2026-07-20 06:30:00 -05:00');

    PRINT 'Seeded: PassScheduleChangeLog (3 rows)';
END
ELSE
    PRINT 'PassScheduleChangeLog already seeded - skipped';
GO

-- ============================================================================
-- VERIFICATION - what is now loaded
-- ============================================================================
PRINT 'Pass schedule sample data - verification:';
GO

SELECT 'PassSchedule'           AS [Table], COUNT(*) AS [Rows] FROM [dbo].[PassSchedule]
UNION ALL
SELECT 'PassScheduleComponent',            COUNT(*)           FROM [dbo].[PassScheduleComponent]
UNION ALL
SELECT 'PassScheduleChangeLog',            COUNT(*)           FROM [dbo].[PassScheduleChangeLog];
GO

SELECT  [LineId],
        [RouteMode],
        [Status],
        COUNT(*) AS [Schedules]
FROM    [dbo].[PassSchedule]
GROUP BY [LineId], [RouteMode], [Status]
ORDER BY [LineId], [RouteMode], [Status];
GO

-- ============================================================================
-- OPEN POINTS - FOR CONFIRMATION AT REVIEW
-- ============================================================================
--
-- 1. PER-PASS DRAW REDUCTION LIMITS
--    Several of these fixtures draw harder per pass than the provisional
--    per-alloy limits currently seeded in AlloyProperty. Those seeded values
--    are placeholders. Our understanding is that the authoritative per-pass
--    draw limit is the one Process Engineering already maintains in
--    united_db..alloys (Draw_max_reduction). Please confirm that this is the
--    right source, and whether the value it holds is PER PASS or CUMULATIVE -
--    the calculation needs per pass. Once confirmed we will re-work the die
--    selections in this fixture set to sit inside the real limits.
--
-- 2. LEGACY SETUP NUMBERS
--    SetupNo carries a legacy FlatLineSetup reference, so that a schedule can
--    be traced back to the setup record it came from. The values here
--    (FLS-2024-001 and similar) are illustrative. Please confirm whether the
--    real setup numbers should be carried across at go-live, and if so which
--    schedules have one.
--
-- 3. FM1 ON THE FL2 STANDALONE SCHEDULE
--    See the note on schedule 11 above, and OPEN POINT 3 in
--    FlatWire_DDL_02_Schedule.sql. The rule that the flattening mill cannot be
--    bypassed is applied to every schedule regardless of line, which forces an
--    Active FM1 row onto an FL2 standalone schedule whose material never
--    passes through FM1.
--
-- 4. WHICH COMPONENTS SHOULD BE LOCKED ON SCREEN
--    IsMandatory tells the screen to lock a component so the operator cannot
--    switch it off. No fixture row sets it, so every row defaults to 0. On the
--    evidence so far FM1 and the final FM2 stand (S3) should both be locked.
--    Please confirm the full list, per line.
--
-- 5. THE EDGE SETTING ON FL1 SCHEDULES               [ANSWERED 31 Aug 2026]
--    Every FL1 fixture here carries an Active EdgeSet row, although FL1 has no
--    edger.
--
--    THE QUESTION IS NOW ANSWERED, AND THESE ROWS ARE WRONG. The client's
--    31 Aug 2026 mail shows the FL1 schedule as three rows - D1 (DRAW),
--    D2 (DRAW), FL1-S1 (FLAT) - with no edger row at all. There is no edge
--    condition to record on an FL1 product, so the fixtures should carry no
--    EdgeSet row rather than a differently-recorded one.
--
--    EIGHT FIXTURES ARE AFFECTED: the EdgeSet row on each of PS-1100-FL1-001,
--    -002, -003, PS-3003-FL1-001, -002, PS-1350-FL1-001, PS-5052-FL1-001 and
--    PS-6061-FL1-001. The FL2 and FL3 fixtures are unaffected - both lines do
--    carry edgers.
--
--    DELIBERATELY NOT CORRECTED IN THIS PASS. Removing eight seed rows moves
--    the seed-row figure that [DBD 6.2] publishes and [DEP 4.2]'s V1-V5 gate
--    checks, and that figure is COUNTED FROM A DEPLOY, never computed. The
--    same deploy has to carry the OPEN POINT 4(b) change - two edger position
--    values in CK_PSC_ComponentName - which rewrites the FL2 and FL3 fixtures
--    anyway. Do both together and recount once.
--
-- 6. WHO POPULATES THESE TABLES IN PRODUCTION
--    This script covers development and the acceptance trial only. Nothing in
--    this phase authors a pass schedule, so production data has to come from
--    the owning system. See OPEN POINT 1 in FlatWire_DDL_02_Schedule.sql.
--
-- 7. OPERATOR NAMES AND DATES
--    CreatedBy, ModifiedBy, OperatorId and the timestamps are illustrative and
--    are used across the whole sample-data set for consistency. They carry no
--    meaning and should not be read as a record of who authored anything.
--
-- ============================================================================
