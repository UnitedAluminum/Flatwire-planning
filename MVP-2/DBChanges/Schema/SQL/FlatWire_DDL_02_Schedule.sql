-- ============================================================
-- SCOPE: MVP-2 (deferred) -- moved 11 Aug 2026 from MVP-1/DBChanges. NOT part of MVP-1.
-- Requires the MVP-1 chain (00..08) to be deployed first.
-- ============================================================
-- Flat Wire Mill — DDL Script 02: Pass Schedule Tables
-- Run order : 02 of 09
-- Tables    : PassSchedule, PassScheduleComponent, PassScheduleChangeLog
-- Dependencies: 01_Lookup (Stand, Drawer, Edger, AlloyProperty)
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- PassSchedule
-- Header record for a pass schedule. Defines alloy, line,
-- dimensional targets, and speed range. Only Active schedules
-- may be selected at run check-in.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PassSchedule]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PassSchedule] (
        [ScheduleId]       VARCHAR(30)   NOT NULL,          -- e.g. PS-1100-FL1-003
        [Description]      VARCHAR(200)  NULL,
        [Alloy]            VARCHAR(10)   NOT NULL,          -- e.g. 1100, 3003, 1350
        [LineId]           VARCHAR(5)    NOT NULL,          -- FL1 | FL2 | FL3
        [RouteMode]        VARCHAR(15)   NOT NULL,          -- Standalone | Hybrid
        [Status]           VARCHAR(10)   NOT NULL,          -- Draft | Active | Inactive
        [TargetGauge]      DECIMAL(8,4)  NOT NULL,          -- target output gauge (in)
        [GaugeTolerance]   DECIMAL(8,4)  NOT NULL,          -- ± gauge tolerance (in)
        [TargetWidth]      DECIMAL(8,4)  NOT NULL,          -- target output width (in)
        [WidthTolerance]   DECIMAL(8,4)  NOT NULL,          -- ± width tolerance (in)
        [InputRodDiameterIn] DECIMAL(8,4) NULL,              -- expected input rod diameter (in); e.g. 0.375
        [InputTemper]        VARCHAR(10)  NULL,              -- rod temper; e.g. H19, H14, H18, H34, T8
        [InputCondition]     VARCHAR(50)  NULL,              -- rod condition; e.g. Hard drawn, Strain hardened
        [LineSpeedMinFpm]  INT           NOT NULL,          -- minimum line speed (ft/min)
        [LineSpeedMaxFpm]  INT           NOT NULL,          -- maximum line speed (ft/min)
        [ActiveJobId]      VARCHAR(20)   NULL,              -- order/job currently using this schedule ("in-use" chip); NULL when idle
        [CreatedBy]        VARCHAR(50)   NOT NULL,
        [CreatedAt]        DATETIMEOFFSET NOT NULL CONSTRAINT [DF_PassSchedule_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [ModifiedBy]       VARCHAR(50)   NULL,
        [ModifiedAt]       DATETIMEOFFSET NULL,
        [RowVersion]       ROWVERSION    NOT NULL,          -- optimistic-concurrency token

        CONSTRAINT [PK_PassSchedule]             PRIMARY KEY CLUSTERED ([ScheduleId] ASC),
        CONSTRAINT [CK_PassSchedule_RouteMode]   CHECK ([RouteMode]  IN ('Standalone', 'Hybrid')),
        CONSTRAINT [CK_PassSchedule_Status]      CHECK ([Status]     IN ('Draft', 'Active', 'Inactive')),
        CONSTRAINT [CK_PassSchedule_LineId]      CHECK ([LineId]     IN ('FL1', 'FL2', 'FL3')),
        CONSTRAINT [CK_PassSchedule_Speed]       CHECK ([LineSpeedMinFpm] < [LineSpeedMaxFpm]),
        CONSTRAINT [CK_PassSchedule_GaugeTol]    CHECK ([GaugeTolerance] > 0),
        CONSTRAINT [CK_PassSchedule_WidthTol]    CHECK ([WidthTolerance] > 0)
    );
    PRINT 'Created table: PassSchedule';
END
ELSE
    PRINT 'Table already exists: PassSchedule';
GO

-- ------------------------------------------------------------
-- PassScheduleComponent
-- Renamed from FlatLineSetup. Per-component rows belonging to
-- a pass schedule. Each row defines one tool station — name,
-- state, and operating parameter.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PassScheduleComponent]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PassScheduleComponent] (
        [Id]             INT          NOT NULL IDENTITY(1,1),
        [PassScheduleId] VARCHAR(30)  NOT NULL,             -- FK → PassSchedule.ScheduleId
        [ComponentName]  VARCHAR(20)  NOT NULL,             -- DB1|DB2|FM1|EdgeSet|FM2_S1|FM2_S2|FM2_S3
        [State]          VARCHAR(10)  NOT NULL,             -- Active | Bypass | Skip
        [ParameterValue] DECIMAL(8,4) NULL,                 -- die diameter or roll gap; NULL when Bypass/Skip
        [EdgeType]       VARCHAR(10)  NULL,                 -- Round | Square — edger components only
        [Sequence]       INT          NOT NULL,             -- processing order within the schedule
        [IsMandatory]    BIT          NOT NULL CONSTRAINT [DF_PSC_IsMandatory] DEFAULT (0),  -- UI lock: component cannot be toggled off
        [StandId]        INT          NULL,                 -- FK → Stand.Id (FM components only)
        [DrawerId]       INT          NULL,                 -- FK → Drawer.Id (DB components only)
        [EdgerId]        INT          NULL,                 -- FK → Edger.Id (EdgeSet only)
        [EntryGauge]     DECIMAL(8,4) NULL,                 -- calculated entry gauge (in); informational
        [ExitGauge]      DECIMAL(8,4) NULL,                 -- calculated exit gauge (in); informational
        [SetupNo]        VARCHAR(20)  NULL,                 -- legacy traceability from FlatLineSetup

        CONSTRAINT [PK_PassScheduleComponent]            PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_PassScheduleComponent_Sequence]   UNIQUE ([PassScheduleId], [Sequence]),
        -- FL1 has no edger (May-21-2026).
        -- Aug-4-2026 correction: FM2 is THREE stands — S1 (8"), S2 (6"), S3 (6", final) — with
        -- edgers at S2 and S3 only. Diameter left the identifier (see Stand.RollDiameterIn):
        --   FM2_8in -> FM2_S1 · FM2_6inS1 -> FM2_S2 · FM2_6inS2 -> FM2_S3 · FM2_6inS3 withdrawn.
        -- This closes OI-04: the mandatory final stand named 'FM2_6inS2' here and '6" S3' in the
        -- SRS were always the same physical stand — now unambiguously FM2_S3.
        CONSTRAINT [CK_PSC_ComponentName]  CHECK ([ComponentName] IN ('DB1','DB2','FM1','EdgeSet','FM2_S1','FM2_S2','FM2_S3')),
        CONSTRAINT [CK_PSC_State]          CHECK ([State]         IN ('Active', 'Bypass', 'Skip')),
        CONSTRAINT [CK_PSC_EdgeType]       CHECK ([EdgeType]      IN ('Round', 'Square') OR [EdgeType] IS NULL),
        -- ParameterValue must be NULL when component is not active
        CONSTRAINT [CK_PSC_ParamValue]     CHECK ([State] = 'Active' OR [ParameterValue] IS NULL),
        -- EdgeType required when an edger component is Active
        CONSTRAINT [CK_PSC_EdgeTypeReq]    CHECK ([ComponentName] NOT IN ('EdgeSet') OR [State] <> 'Active' OR [EdgeType] IS NOT NULL),
        -- FM1 (12" flattening mill) is not bypassable (SRS §2.8 equipment table)
        CONSTRAINT [CK_PSC_FM1NotBypassable] CHECK ([ComponentName] <> 'FM1' OR [State] = 'Active')
    );
    PRINT 'Created table: PassScheduleComponent';
END
ELSE
    PRINT 'Table already exists: PassScheduleComponent';
GO

-- ------------------------------------------------------------
-- PassScheduleChangeLog
-- Immutable audit trail of every post-Active pass-schedule
-- action: overrides, edits, and check-in acknowledgments
-- (who / when / old→new / reason). Satisfies OQ-62 and the
-- Dashboard 9 "Change History" tabs. One row per change.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PassScheduleChangeLog]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PassScheduleChangeLog] (
        [Id]             INT           NOT NULL IDENTITY(1,1),
        [PassScheduleId] VARCHAR(30)   NOT NULL,             -- FK → PassSchedule.ScheduleId
        [ChangeType]     VARCHAR(20)   NOT NULL,             -- Override | Edit | Acknowledgment
        [ParameterName]  VARCHAR(50)   NULL,                 -- component/target changed; NULL for whole-schedule acks
        [OldValue]       VARCHAR(100)  NULL,                 -- prior value (text, unit-agnostic)
        [NewValue]       VARCHAR(100)  NULL,                 -- new value applied
        [ReasonCode]     VARCHAR(50)   NULL,                 -- e.g. DieWear, SpcDrift, OrderSpec, ProcessUpdate, CampaignStart
        [ReasonNotes]    VARCHAR(500)  NULL,
        [RunId]          VARCHAR(20)   NULL,                 -- run context when the change was made (nullable)
        [OperatorId]     VARCHAR(50)   NOT NULL,
        [Timestamp]      DATETIMEOFFSET NOT NULL CONSTRAINT [DF_PSChangeLog_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_PassScheduleChangeLog]      PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_PSChangeLog_ChangeType]     CHECK ([ChangeType] IN ('Override','Edit','Acknowledgment'))
    );
    PRINT 'Created table: PassScheduleChangeLog';
END
ELSE
    PRINT 'Table already exists: PassScheduleChangeLog';
GO
