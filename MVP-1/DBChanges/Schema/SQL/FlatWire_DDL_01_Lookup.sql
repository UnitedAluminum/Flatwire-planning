-- ============================================================
-- Flat Wire Mill — DDL Script 01: Lookup / Reference Tables
-- Run order : 01 of 09
-- Tables    : Stand, Drawer, Edger, SpoolConfiguration, AlloyProperty,
--             PayoffPosition
-- Dependencies: 00_Database (FlatWireDB)
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- Stand
-- Rolling mill finishing stands. Referenced by PassScheduleComponent
-- for FM-type component slots.
--
-- Aug-4-2026 correction: FM2 has THREE stands — S1 (8"), S2 (6"),
-- S3 (6", final) — not a separate 8" roller plus three 6" stands.
-- Roll diameter is now DATA (RollDiameterIn), not part of the name:
--   FM2_8in -> FM2_S1 (8.000)   FM2_6inS1 -> FM2_S2 (6.000)
--   FM2_6inS2 -> FM2_S3 (6.000, final)   FM2_6inS3 -> withdrawn
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stand]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Stand] (
        [Id]             INT          NOT NULL IDENTITY(1,1),
        [Name]           VARCHAR(30)  NOT NULL,               -- position only: FM1, FM2_S1, FM2_S2, FM2_S3
        [LineId]         VARCHAR(5)   NULL,                   -- FL1 / FL2 / FL3; NULL = shared across lines
        [RollDiameterIn] DECIMAL(5,3) NOT NULL,               -- working roll diameter in inches (FM1 12.000; FM2 S1 8.000, S2/S3 6.000)
        [MinGaugeIn]     DECIMAL(8,4) NOT NULL,               -- minimum input gauge in inches
        [MaxGaugeIn]     DECIMAL(8,4) NOT NULL,               -- maximum input gauge in inches
        [MinWidthIn]     DECIMAL(8,4) NOT NULL,               -- minimum strip width in inches
        [MaxWidthIn]     DECIMAL(8,4) NOT NULL,               -- maximum strip width in inches
        [IsActive]       BIT          NOT NULL CONSTRAINT [DF_Stand_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Stand]                  PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Stand_Name]             UNIQUE ([Name]),
        CONSTRAINT [CK_Stand_Gauge]            CHECK ([MinGaugeIn] < [MaxGaugeIn]),
        CONSTRAINT [CK_Stand_Width]            CHECK ([MinWidthIn] < [MaxWidthIn]),
        CONSTRAINT [CK_Stand_RollDiameterIn]   CHECK ([RollDiameterIn] > 0)
    );
    PRINT 'Created table: Stand';
END
ELSE
    PRINT 'Table already exists: Stand';
GO

-- ------------------------------------------------------------
-- Drawer
-- Draw box die configurations (DB1, DB2). Die hole diameter
-- determines the output wire size after drawing.
--
-- DIE LIFE (Aug-6-2026). LastGrindingFeet / TotalFeetAllowed give the
-- die-life numbers their first home in the schema. Semantics are from
-- DieChangeAndManagement.md 4.2 / 4.4 -- read the column comments, because
-- LastGrindingFeet does NOT mean "the odometer reading at the last grind".
--
-- SCOPE, so nobody reads more into these two columns than they carry:
-- Drawer is a die-SIZE catalogue (13 rows, one per hole diameter), so a
-- counter here accumulates against a size, not against a physical tool.
-- The per-die inventory (D-{size*1000}-{seq}, condition, Active/Nearing/
-- Overdue/Spare/Retired, disposition history) still does not exist --
-- OI-41 is NARROWED, NOT CLOSED. When that table lands, these two columns
-- move to it.
--
-- Nothing maintains them automatically yet: DieChangeEvent identifies its
-- dies by OldDieSizeIn / NewDieSizeIn decimals with no DrawerId FK, so no
-- run event can attribute footage to a row here. Until that FK or the PLC
-- die counter arrives, both values are Maintenance-maintained.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Drawer]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Drawer] (
        [Id]            INT          NOT NULL IDENTITY(1,1),
        [Name]          VARCHAR(50)  NOT NULL,             -- die name or part number
        [DiameterIn]    DECIMAL(8,4) NOT NULL,             -- die hole diameter in inches (output wire size)
        [MinDiameterIn] DECIMAL(8,4) NULL,                 -- minimum acceptable feed diameter
        [MaxDiameterIn] DECIMAL(8,4) NULL,                 -- maximum acceptable feed diameter
        -- Feet run SINCE the last grinding/reconditioning -- a resettable counter,
        -- not the odometer value at that grind. Reset to 0 when the die returns
        -- from the die room (DieChangeAndManagement.md 4.4 "Footage resets to zero").
        [LastGrindingFeet] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_Drawer_LastGrindingFeet] DEFAULT (0),
        -- Scheduled life: the engineering/supplier maximum footage this die may run
        -- before it is pulled. Configurable, and set LOWER on a reconditioned die.
        -- NULL until the client supplies thresholds (OQ-83 -- tracking decided,
        -- threshold TBD). Do not seed an invented limit.
        [TotalFeetAllowed] DECIMAL(10,2) NULL,
        [IsActive]      BIT          NOT NULL CONSTRAINT [DF_Drawer_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Drawer]             PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Drawer_Name]        UNIQUE ([Name]),
        CONSTRAINT [CK_Drawer_DiamPos]     CHECK ([DiameterIn] > 0),
        CONSTRAINT [CK_Drawer_FeedRange]   CHECK ([MinDiameterIn] IS NULL OR [MaxDiameterIn] IS NULL OR [MinDiameterIn] < [MaxDiameterIn]),
        CONSTRAINT [CK_Drawer_LastGrindingFeet] CHECK ([LastGrindingFeet] >= 0),
        CONSTRAINT [CK_Drawer_TotalFeetAllowed] CHECK ([TotalFeetAllowed] IS NULL OR [TotalFeetAllowed] > 0)
        -- Deliberately NO check that LastGrindingFeet <= TotalFeetAllowed. "Overdue"
        -- is a real operating state the Die Management screen must display
        -- (DieChangeAndManagement.md 5), not a data error to refuse at the database.
    );
    PRINT 'Created table: Drawer';
END
ELSE
    PRINT 'Table already exists: Drawer';
GO

-- ------------------------------------------------------------
-- Edger
-- Edger tooling configurations (EdgeSet component). Produces
-- either Round or Square edge profiles on the flat wire.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Edger]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Edger] (
        [Id]           INT         NOT NULL IDENTITY(1,1),
        [Name]         VARCHAR(50) NOT NULL,               -- edger assembly name/identifier
        [EdgeType]     VARCHAR(10) NOT NULL,               -- Round | Square
        [ToolingSetNo] VARCHAR(20) NULL,                   -- physical tooling set number
        [IsActive]     BIT         NOT NULL CONSTRAINT [DF_Edger_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Edger]          PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Edger_Name]     UNIQUE ([Name]),
        CONSTRAINT [CK_Edger_EdgeType] CHECK ([EdgeType] IN ('Round', 'Square'))
    );
    PRINT 'Created table: Edger';
END
ELSE
    PRINT 'Table already exists: Edger';
GO

-- ---------------------------------------------------------------------------
-- Dancer — tension-management rollers.
--
-- FM1 carries ONE dancer; FM2 carries TWO, sitting BETWEEN stands (S1/S2 and
-- S2/S3) rather than at them (client decision D-28, 6 Aug 2026).
--
-- Mode is unresolved (OQ-32): the 6 Aug call described two selectable modes,
-- while the 23 Jul meeting recorded tension control as machine-driven. The
-- columns below carry the equipment capability only — no pass schedule column
-- is added, because that is contingent on the answer and PassScheduleComponent
-- is MVP-2. See [PLC 5.5] and ClientCall_2026-07-23_SyncPlan.md 3.1.
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Dancer' AND xtype = 'U')
BEGIN
    CREATE TABLE [dbo].[Dancer] (
        [Id]                  INT         NOT NULL IDENTITY(1,1),
        [Name]                VARCHAR(30) NOT NULL,               -- position-only: FM1_Dancer, FM2_Dancer1, FM2_Dancer2
        [LineId]              VARCHAR(5)  NULL,                   -- FL1 / FL2 / FL3; NULL = shared across lines
        [Position]            VARCHAR(20) NOT NULL,               -- FM1 | FM2_S1_S2 | FM2_S2_S3
        [Ordinal]             INT         NULL,                   -- 1 = upstream, 2 = downstream; NULL when single (FM1)
        [SupportsTensionMode] BIT         NOT NULL CONSTRAINT [DF_Dancer_SupportsTension] DEFAULT (0),
        [DefaultMode]         VARCHAR(10) NOT NULL CONSTRAINT [DF_Dancer_DefaultMode]     DEFAULT ('Dancer'),
        [IsActive]            BIT         NOT NULL CONSTRAINT [DF_Dancer_IsActive]        DEFAULT (1),

        CONSTRAINT [PK_Dancer]             PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Dancer_Name]        UNIQUE ([Name]),
        CONSTRAINT [CK_Dancer_Position]    CHECK ([Position] IN ('FM1', 'FM2_S1_S2', 'FM2_S2_S3')),
        CONSTRAINT [CK_Dancer_DefaultMode] CHECK ([DefaultMode] IN ('Dancer', 'Tension')),
        CONSTRAINT [CK_Dancer_Ordinal]     CHECK ([Ordinal] IS NULL OR [Ordinal] IN (1, 2)),
        -- Tension may only be the default on a dancer that supports it.
        CONSTRAINT [CK_Dancer_ModeSupport] CHECK ([DefaultMode] <> 'Tension' OR [SupportsTensionMode] = 1)
    );
    PRINT 'Created table: Dancer';
END
ELSE
    PRINT 'Table already exists: Dancer';
GO

-- ------------------------------------------------------------
-- SpoolConfiguration
-- Reference table for spool types. Defines weight and
-- dimensional constraints validated at FL2/FL3 check-in.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpoolConfiguration]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[SpoolConfiguration] (
        [Id]                 INT          NOT NULL IDENTITY(1,1),
        [Name]               VARCHAR(50)  NOT NULL,         -- configuration name (e.g. 15lb, 30lb)
        [MinWeightLb]        DECIMAL(8,2) NOT NULL,         -- minimum acceptable spool weight (lb)
        [MaxWeightLb]        DECIMAL(8,2) NOT NULL,         -- maximum acceptable spool weight (lb)
        [MinCoreDiameterIn]  DECIMAL(8,4) NOT NULL,         -- minimum core (inside arbor) diameter (in)
        [MaxCoreDiameterIn]  DECIMAL(8,4) NOT NULL,         -- maximum core diameter (in)
        [MinOuterDiameterIn] DECIMAL(8,4) NOT NULL,         -- minimum outer diameter of loaded spool (in)
        [MaxOuterDiameterIn] DECIMAL(8,4) NOT NULL,         -- maximum outer diameter of loaded spool (in)
        [IsActive]           BIT          NOT NULL CONSTRAINT [DF_SpoolConfig_IsActive] DEFAULT (1),  -- soft-delete flag (consistent with other lookups)

        CONSTRAINT [PK_SpoolConfiguration]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_SpoolConfig_Name]           UNIQUE ([Name]),
        CONSTRAINT [CK_SpoolConfig_Weight]         CHECK ([MinWeightLb] < [MaxWeightLb]),
        CONSTRAINT [CK_SpoolConfig_CoreDiam]       CHECK ([MinCoreDiameterIn] < [MaxCoreDiameterIn]),
        CONSTRAINT [CK_SpoolConfig_OuterDiam]      CHECK ([MinOuterDiameterIn] < [MaxOuterDiameterIn])
    );
    PRINT 'Created table: SpoolConfiguration';
END
ELSE
    PRINT 'Table already exists: SpoolConfiguration';
GO

-- ------------------------------------------------------------
-- AlloyProperty
-- Per-alloy process properties consumed by the pass-schedule
-- generator (max reduction, springback) and by output-weight
-- derivation (LbPerFtFactor — footage → weight, OQ-10 default).
-- The authoritative alloy list referenced by PassSchedule.Alloy.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlloyProperty]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[AlloyProperty] (
        [Id]                    INT          NOT NULL IDENTITY(1,1),
        [Alloy]                 VARCHAR(10)  NOT NULL,       -- e.g. 1100, 1350, 3003, 5052, 6061
        [MaxReductionPerPass]   DECIMAL(5,3) NOT NULL,       -- fractional max area reduction per pass (e.g. 0.220 = 22%)
        [SpringbackFactor]      DECIMAL(5,3) NOT NULL,       -- roll-gap springback multiplier (e.g. 0.970)
        -- DIMENSIONAL TOLERANCES — min/max pairs, not a single ± (client, 30 Jul 2026, Q22).
        -- Tim confirmed upper and lower limits for gauge (height), width and diameter, plus
        -- ovality, held here in the lookup and applied at BOTH pre-check-in and check-in.
        -- Modelled as OFFSETS about nominal, matching CHK007 / FR-065 ("0.30 with ±0.01 gives
        -- 0.29–0.31"), so an asymmetric band is expressible: nominal − Minus .. nominal + Plus.
        -- Gauge and width carry forward the previously seeded symmetric value in BOTH columns
        -- (interim, not new data). Diameter and ovality are NULL: the values are OWED BY
        -- E-MAIL and nothing is to be seeded until they arrive — "I want to say it's plus or
        -- minus 10" is not a specification.
        [GaugeToleranceMinusIn]     DECIMAL(8,4) NOT NULL,   -- lower gauge limit, as an offset below nominal (in)
        [GaugeTolerancePlusIn]      DECIMAL(8,4) NOT NULL,   -- upper gauge limit, as an offset above nominal (in)
        [WidthToleranceMinusIn]     DECIMAL(8,4) NOT NULL,   -- lower width limit (in)
        [WidthTolerancePlusIn]      DECIMAL(8,4) NOT NULL,   -- upper width limit (in)
        [RodDiameterToleranceMinusIn] DECIMAL(8,4) NULL,     -- lower incoming-rod diameter limit (in); CHK007
        [RodDiameterTolerancePlusIn]  DECIMAL(8,4) NULL,     -- upper incoming-rod diameter limit (in); CHK007
        [RodOvalityMaxIn]           DECIMAL(8,4) NULL,       -- max |M1 − M2| out-of-round; supersedes the
                                                             -- hard-coded 0.003" in CheckinImplementationPlan.md
        [SpeedRangeMinFpm]      INT          NOT NULL,       -- default minimum line speed (ft/min)
        [SpeedRangeMaxFpm]      INT          NOT NULL,       -- default maximum line speed (ft/min)
        [LbPerFtFactor]         DECIMAL(10,6) NULL,          -- footage → weight factor (lb per ft); OQ-10 PROVISIONAL — confirm per cross-section
        [DensityLbPerIn3]       DECIMAL(10,6) NULL,          -- alloy density (lb/in^3) for area×density fallback
        [IsWeldingWire]         BIT          NOT NULL CONSTRAINT [DF_AlloyProperty_IsWeldingWire] DEFAULT (0),  -- welding-wire grade flag (extra traceability)
        [IsActive]              BIT          NOT NULL CONSTRAINT [DF_AlloyProperty_IsActive] DEFAULT (1),

        CONSTRAINT [PK_AlloyProperty]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_AlloyProperty_Alloy]     UNIQUE ([Alloy]),
        CONSTRAINT [CK_AlloyProperty_Reduction] CHECK ([MaxReductionPerPass] > 0 AND [MaxReductionPerPass] < 1),
        CONSTRAINT [CK_AlloyProperty_Speed]     CHECK ([SpeedRangeMinFpm] < [SpeedRangeMaxFpm]),
        CONSTRAINT [CK_AlloyProperty_GaugeTol]  CHECK ([GaugeToleranceMinusIn] > 0 AND [GaugeTolerancePlusIn] > 0),
        CONSTRAINT [CK_AlloyProperty_WidthTol]  CHECK ([WidthToleranceMinusIn] > 0 AND [WidthTolerancePlusIn] > 0),
        -- Rod diameter is all-or-nothing: half a band cannot validate anything.
        -- Note the explicit IS NOT NULL pair: `Minus > 0 AND Plus > 0` alone evaluates to
        -- UNKNOWN when one side is NULL, and a CHECK constraint accepts UNKNOWN — so half a
        -- band would have been admitted.
        CONSTRAINT [CK_AlloyProperty_RodDiaTol] CHECK (
                                                    ([RodDiameterToleranceMinusIn] IS NULL AND [RodDiameterTolerancePlusIn] IS NULL)
                                                 OR ([RodDiameterToleranceMinusIn] IS NOT NULL AND [RodDiameterTolerancePlusIn] IS NOT NULL
                                                        AND [RodDiameterToleranceMinusIn] > 0 AND [RodDiameterTolerancePlusIn] > 0)
                                                ),
        -- Ovality is |M1 − M2|, so only an upper limit is meaningful.
        CONSTRAINT [CK_AlloyProperty_Ovality]   CHECK ([RodOvalityMaxIn] IS NULL OR [RodOvalityMaxIn] > 0)
    );
    PRINT 'Created table: AlloyProperty';
END
ELSE
    PRINT 'Table already exists: AlloyProperty';
GO

-- ------------------------------------------------------------
-- PayoffPosition
-- Reference table for material input/output positions. Gives
-- FlatWireRunDetail.PayoffPositionId a real parent — previously it
-- was an FK-style INT pointing at a table that did not exist
-- (REVIEW.md #15).
--
-- Three positions are modelled, not two: FL1/FL3 draw rod from the
-- dual-position VPS (1 and 2), while FL2 uses a traversing take-up.
-- Rod-fed tables (RodStaging, RodCheckin, RodCheckout, SpoolCheckin)
-- deliberately narrow to CHECK (1,2) — that is intentional, not an
-- oversight: a rod bundle is only ever mounted on a VPS bay.
--
-- Id is explicit (no IDENTITY) so the values are pinned and match the
-- API enum PayoffPosition { Payoff1 = 1, Payoff2 = 2 }.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PayoffPosition]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PayoffPosition] (
        [Id]          INT         NOT NULL,               -- 1 | 2 | 3 — pinned, not generated
        [Code]        VARCHAR(20) NOT NULL,               -- Payoff1 | Payoff2 | TraversingTakeup
        [DisplayName] VARCHAR(40) NOT NULL,               -- operator-facing label
        [Equipment]   VARCHAR(20) NOT NULL,               -- VPS | TraversingTakeup
        [MaxWeightLb] DECIMAL(8,2) NULL,                  -- position capacity (lb)
        [IsRodFed]    BIT         NOT NULL,               -- 1 = accepts a rod bundle (FL1/FL3)
        [IsActive]    BIT         NOT NULL CONSTRAINT [DF_PayoffPosition_IsActive] DEFAULT (1),

        CONSTRAINT [PK_PayoffPosition]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_PayoffPosition_Code]   UNIQUE ([Code]),
        CONSTRAINT [CK_PayoffPosition_Id]     CHECK ([Id] IN (1, 2, 3)),
        CONSTRAINT [CK_PayoffPosition_Code]   CHECK ([Code] IN ('Payoff1','Payoff2','TraversingTakeup')),
        CONSTRAINT [CK_PayoffPosition_Equip]  CHECK ([Equipment] IN ('VPS','TraversingTakeup'))
    );
    PRINT 'Created table: PayoffPosition';
END
ELSE
    PRINT 'Table already exists: PayoffPosition';
GO

-- Seed the three fixed positions. Idempotent.
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayoffPosition] WHERE [Id] = 1)
    INSERT INTO [dbo].[PayoffPosition] ([Id],[Code],[DisplayName],[Equipment],[MaxWeightLb],[IsRodFed])
    VALUES (1, 'Payoff1', 'Payoff 1', 'VPS', 9000.00, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayoffPosition] WHERE [Id] = 2)
    INSERT INTO [dbo].[PayoffPosition] ([Id],[Code],[DisplayName],[Equipment],[MaxWeightLb],[IsRodFed])
    VALUES (2, 'Payoff2', 'Payoff 2', 'VPS', 9000.00, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayoffPosition] WHERE [Id] = 3)
    INSERT INTO [dbo].[PayoffPosition] ([Id],[Code],[DisplayName],[Equipment],[MaxWeightLb],[IsRodFed])
    VALUES (3, 'TraversingTakeup', 'Traversing take-up (FL2)', 'TraversingTakeup', NULL, 0);
GO
