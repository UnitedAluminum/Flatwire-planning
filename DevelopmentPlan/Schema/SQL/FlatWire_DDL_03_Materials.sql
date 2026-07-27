-- ============================================================
-- Flat Wire Mill — DDL Script 03: Material Tables
-- Run order : 03 of 09
-- Tables    : Rod, FlatWireRun (header — placed here so Spool
--             can reference it), Spool
-- Dependencies: 01_Lookup (SpoolConfiguration), 02_Schedule (PassSchedule)
-- Note      : [Rod] is kept as a FlatWireDB-local master (Hybrid
--             foundation decision) so rod-alpha FKs are enforced
--             in-database; it mirrors the shared legacy `coils`
--             record populated by the Receiving module.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- Rod
-- Wire rod receiving and lifecycle tracking. Every processed
-- rod carries an alpha identifier used across all event tables.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Rod]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Rod] (
        [Id]           INT           NOT NULL IDENTITY(1,1),
        [Alpha]        VARCHAR(20)   NOT NULL,              -- e.g. R00041; unique scan key
        [Alloy]        VARCHAR(10)   NOT NULL,              -- e.g. 1100, 3003
        [Temper]       VARCHAR(10)   NOT NULL,              -- e.g. O, H14
        [DiameterIn]   DECIMAL(8,4)  NOT NULL,              -- rod wire diameter (in)
        [GrossWeightLb] DECIMAL(8,2) NOT NULL,              -- gross weight including packaging (lb)
        [NetWeightLb]  DECIMAL(8,2)  NOT NULL,              -- net aluminum weight (lb)
        [TareWeightLb] AS ([GrossWeightLb] - [NetWeightLb]) PERSISTED,  -- computed: gross − net (lb)
        [SupplierHeat] VARCHAR(50)   NULL,                  -- supplier heat/cast number for certification
        [InventoryType] VARCHAR(20)  NULL,                  -- planning/cost inventory classification (OQ-18 PROVISIONAL)
        [Status]       VARCHAR(20)   NOT NULL,              -- RECEIVED|STAGED|INFLAT|COMPLETE|HOLD|SCRAP
        [Location]     VARCHAR(50)   NULL,                  -- physical floor location
        [StagedPayoffPosition] INT   NULL,                  -- pre-check-in staging: intended payoff (1|2); FlatwireQueue model (PROVISIONAL)
        [IsWelded]     BIT           NOT NULL CONSTRAINT [DF_Rod_IsWelded] DEFAULT (0),  -- pre-check-in "Mark as Welded" flag
        [FootageRunToDate] DECIMAL(10,2) NULL,              -- cumulative footage produced across partial runs (Phase 7 / OQ-47)
        [RemainingWeightEstimateLb] DECIMAL(8,2) NULL,      -- estimated remaining weight after a partial run (lb)
        [ReceivedAt]   DATETIMEOFFSET NOT NULL CONSTRAINT [DF_Rod_ReceivedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [CreatedBy]    VARCHAR(50)   NULL,                  -- audit: receiving/creating operator
        [ModifiedBy]   VARCHAR(50)   NULL,
        [ModifiedAt]   DATETIMEOFFSET NULL,
        [RowVersion]   ROWVERSION    NOT NULL,              -- optimistic-concurrency token

        CONSTRAINT [PK_Rod]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Rod_Alpha]   UNIQUE ([Alpha]),
        CONSTRAINT [CK_Rod_Status]  CHECK ([Status] IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')),
        CONSTRAINT [CK_Rod_DiamPos] CHECK ([DiameterIn] > 0),
        CONSTRAINT [CK_Rod_StagedPayoff] CHECK ([StagedPayoffPosition] IN (1, 2) OR [StagedPayoffPosition] IS NULL)
    );
    PRINT 'Created table: Rod';
END
ELSE
    PRINT 'Table already exists: Rod';
GO

-- ------------------------------------------------------------
-- FlatWireRun
-- Core run header — one row per check-in event (rod or spool
-- on a line). All event tables join back to this via RunId.
-- Placed in this script so Spool can reference SourceRunId.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlatWireRun]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[FlatWireRun] (
        [Id]             INT           NOT NULL IDENTITY(1,1),
        [RunId]          VARCHAR(20)   NOT NULL,            -- e.g. RUN-0042; referenced by all child tables
        [LineId]         VARCHAR(5)    NOT NULL,            -- FL1 | FL2 | FL3
        [OrderId]        VARCHAR(20)   NOT NULL,            -- manufacturing order number
        [PassScheduleId] VARCHAR(30)   NOT NULL,            -- FK → PassSchedule.ScheduleId
        [Alloy]          VARCHAR(10)   NOT NULL,            -- denormalized from PassSchedule.Alloy
        [RouteMode]      VARCHAR(15)   NOT NULL,            -- Standalone | Hybrid
        [Status]         VARCHAR(20)   NOT NULL,            -- Running | Paused | Complete | Aborted
        [StartedAt]      DATETIMEOFFSET NOT NULL,
        [PausedAt]       DATETIMEOFFSET NULL,               -- current active pause start; NULL if not paused
        [CompletedAt]    DATETIMEOFFSET NULL,               -- NULL while run is still active
        [FootageFt]      DECIMAL(10,2) NOT NULL CONSTRAINT [DF_FlatWireRun_FootageFt] DEFAULT (0),  -- standardized to DECIMAL(10,2)
        [OperatorId]     VARCHAR(50)   NOT NULL,
        [CreatedBy]      VARCHAR(50)   NULL,                -- audit (StartedAt serves as created timestamp)
        [ModifiedBy]     VARCHAR(50)   NULL,
        [ModifiedAt]     DATETIMEOFFSET NULL,
        [RowVersion]     ROWVERSION    NOT NULL,            -- optimistic-concurrency token (FootageFt/Status updated live)

        CONSTRAINT [PK_FlatWireRun]           PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_FlatWireRun_RunId]     UNIQUE ([RunId]),
        CONSTRAINT [CK_FlatWireRun_LineId]    CHECK ([LineId]    IN ('FL1','FL2','FL3')),
        CONSTRAINT [CK_FlatWireRun_RouteMode] CHECK ([RouteMode] IN ('Standalone','Hybrid')),
        CONSTRAINT [CK_FlatWireRun_Status]    CHECK ([Status]    IN ('Running','Paused','Complete','Aborted')),
        CONSTRAINT [CK_FlatWireRun_Footage]   CHECK ([FootageFt] >= 0)
    );
    PRINT 'Created table: FlatWireRun';
END
ELSE
    PRINT 'Table already exists: FlatWireRun';
GO

-- ------------------------------------------------------------
-- Spool
-- Pre-drawn wire spools produced on FL1 (Hybrid mode) and
-- fed into FL2/FL3. Identified by alpha code; validated
-- against SpoolConfiguration constraints at check-in.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Spool]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Spool] (
        [Id]             INT           NOT NULL IDENTITY(1,1),
        [Alpha]          VARCHAR(20)   NOT NULL,            -- e.g. SP-00021; scan key at FL2/FL3
        [SpoolTypeId]    INT           NOT NULL,            -- FK → SpoolConfiguration.Id
        [OrderNo]        VARCHAR(50)   NULL,                -- manufacturing order number
        [RelLetter]      VARCHAR(10)   NULL,                -- release letter
        [ParentRodAlpha] VARCHAR(20)   NULL,                -- FK → Rod.Alpha (rod drawn into this spool)
        [SourceRodAlpha] VARCHAR(20)   NULL,                -- FK → Rod.Alpha (partial-run source rod; Phase 7 / OQ-47)
        [SourceRunId]    VARCHAR(20)   NULL,                -- FK → FlatWireRun.RunId (FL1 run that produced it)
        [LineId]         VARCHAR(5)    NULL,                -- line that produced or is processing this spool
        [OriginRouteMode] VARCHAR(15)  NULL,               -- Standalone | Hybrid — origin route; FL2 rejects a Standalone schedule on a Hybrid-origin spool (OQ-52)
        [Status]         VARCHAR(20)   NOT NULL,            -- RECEIVED|STAGED|INFLAT|COMPLETE|HOLD|SCRAP
        [GaugeIn]        DECIMAL(8,4)  NULL,                -- wire gauge (in); set at FL2/FL3 check-in
        [WidthIn]        DECIMAL(8,4)  NULL,                -- wire width (in); set at FL2/FL3 check-in
        [GrossWeightLb]  DECIMAL(8,2)  NULL,                -- gross weight (lb)
        [NetWeightLb]    DECIMAL(8,2)  NULL,                -- net material weight (lb)
        [Location]       VARCHAR(50)   NULL,                -- physical floor location
        [ReceivedAt]     DATETIMEOFFSET NULL,               -- timestamp received at FL2/FL3
        [StagedAt]       DATETIMEOFFSET NULL,               -- timestamp staged at payoff position
        [CreatedBy]      VARCHAR(50)   NULL,                -- audit
        [ModifiedBy]     VARCHAR(50)   NULL,
        [ModifiedAt]     DATETIMEOFFSET NULL,
        [RowVersion]     ROWVERSION    NOT NULL,            -- optimistic-concurrency token

        CONSTRAINT [PK_Spool]        PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Spool_Alpha]  UNIQUE ([Alpha]),
        CONSTRAINT [CK_Spool_Status] CHECK ([Status] IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')),
        CONSTRAINT [CK_Spool_LineId] CHECK ([LineId] IN ('FL1','FL2','FL3') OR [LineId] IS NULL),
        CONSTRAINT [CK_Spool_OriginRoute] CHECK ([OriginRouteMode] IN ('Standalone','Hybrid') OR [OriginRouteMode] IS NULL)
    );
    PRINT 'Created table: Spool';
END
ELSE
    PRINT 'Table already exists: Spool';
GO
