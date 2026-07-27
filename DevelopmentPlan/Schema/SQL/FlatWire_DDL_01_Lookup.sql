-- ============================================================
-- Flat Wire Mill — DDL Script 01: Lookup / Reference Tables
-- Run order : 01 of 09
-- Tables    : Stand, Drawer, Edger, SpoolConfiguration, AlloyProperty
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
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stand]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Stand] (
        [Id]         INT          NOT NULL IDENTITY(1,1),
        [Name]       VARCHAR(30)  NOT NULL,               -- e.g. FM1, FM2_8in, FM2_6inS1, FM2_6inS2
        [LineId]     VARCHAR(5)   NULL,                   -- FL1 / FL2 / FL3; NULL = shared across lines
        [MinGaugeIn] DECIMAL(8,4) NOT NULL,               -- minimum input gauge in inches
        [MaxGaugeIn] DECIMAL(8,4) NOT NULL,               -- maximum input gauge in inches
        [MinWidthIn] DECIMAL(8,4) NOT NULL,               -- minimum strip width in inches
        [MaxWidthIn] DECIMAL(8,4) NOT NULL,               -- maximum strip width in inches
        [IsActive]   BIT          NOT NULL CONSTRAINT [DF_Stand_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Stand]          PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Stand_Name]     UNIQUE ([Name]),
        CONSTRAINT [CK_Stand_Gauge]    CHECK ([MinGaugeIn] < [MaxGaugeIn]),
        CONSTRAINT [CK_Stand_Width]    CHECK ([MinWidthIn] < [MaxWidthIn])
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
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Drawer]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Drawer] (
        [Id]            INT          NOT NULL IDENTITY(1,1),
        [Name]          VARCHAR(50)  NOT NULL,             -- die name or part number
        [DiameterIn]    DECIMAL(8,4) NOT NULL,             -- die hole diameter in inches (output wire size)
        [MinDiameterIn] DECIMAL(8,4) NULL,                 -- minimum acceptable feed diameter
        [MaxDiameterIn] DECIMAL(8,4) NULL,                 -- maximum acceptable feed diameter
        [IsActive]      BIT          NOT NULL CONSTRAINT [DF_Drawer_IsActive] DEFAULT (1),

        CONSTRAINT [PK_Drawer]             PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Drawer_Name]        UNIQUE ([Name]),
        CONSTRAINT [CK_Drawer_DiamPos]     CHECK ([DiameterIn] > 0),
        CONSTRAINT [CK_Drawer_FeedRange]   CHECK ([MinDiameterIn] IS NULL OR [MaxDiameterIn] IS NULL OR [MinDiameterIn] < [MaxDiameterIn])
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
-- derivation (LbPerFtFactor — footage → weight, OQ-36 default).
-- The authoritative alloy list referenced by PassSchedule.Alloy.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlloyProperty]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[AlloyProperty] (
        [Id]                    INT          NOT NULL IDENTITY(1,1),
        [Alloy]                 VARCHAR(10)  NOT NULL,       -- e.g. 1100, 1350, 3003, 5052, 6061
        [MaxReductionPerPass]   DECIMAL(5,3) NOT NULL,       -- fractional max area reduction per pass (e.g. 0.220 = 22%)
        [SpringbackFactor]      DECIMAL(5,3) NOT NULL,       -- roll-gap springback multiplier (e.g. 0.970)
        [GaugeToleranceDefault] DECIMAL(8,4) NOT NULL,       -- default ± gauge tolerance (in)
        [WidthToleranceDefault] DECIMAL(8,4) NOT NULL,       -- default ± width tolerance (in)
        [SpeedRangeMinFpm]      INT          NOT NULL,       -- default minimum line speed (ft/min)
        [SpeedRangeMaxFpm]      INT          NOT NULL,       -- default maximum line speed (ft/min)
        [LbPerFtFactor]         DECIMAL(10,6) NULL,          -- footage → weight factor (lb per ft); OQ-36 PROVISIONAL — confirm per cross-section
        [DensityLbPerIn3]       DECIMAL(10,6) NULL,          -- alloy density (lb/in^3) for area×density fallback
        [IsWeldingWire]         BIT          NOT NULL CONSTRAINT [DF_AlloyProperty_IsWeldingWire] DEFAULT (0),  -- welding-wire grade flag (extra traceability)
        [IsActive]              BIT          NOT NULL CONSTRAINT [DF_AlloyProperty_IsActive] DEFAULT (1),

        CONSTRAINT [PK_AlloyProperty]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_AlloyProperty_Alloy]     UNIQUE ([Alloy]),
        CONSTRAINT [CK_AlloyProperty_Reduction] CHECK ([MaxReductionPerPass] > 0 AND [MaxReductionPerPass] < 1),
        CONSTRAINT [CK_AlloyProperty_Speed]     CHECK ([SpeedRangeMinFpm] < [SpeedRangeMaxFpm]),
        CONSTRAINT [CK_AlloyProperty_GaugeTol]  CHECK ([GaugeToleranceDefault] > 0),
        CONSTRAINT [CK_AlloyProperty_WidthTol]  CHECK ([WidthToleranceDefault] > 0)
    );
    PRINT 'Created table: AlloyProperty';
END
ELSE
    PRINT 'Table already exists: AlloyProperty';
GO
