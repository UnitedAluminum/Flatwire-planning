-- ============================================================
-- Flat Wire Mill (MVP-2) — DDL 07b: Indexes on MVP-2 tables
-- Run order : 07b of 06 (MVP-2 chain)
-- Scope     : MVP-2 (deferred). NOT part of MVP-1.
-- ============================================================
-- Split out of FlatWire_DDL_07_Indexes.sql on 11 Aug 2026 when the schema was
-- divided by MVP scope. 13 of the 47 indexes.
--
-- PREREQUISITE: the whole MVP-1 chain must already be deployed
-- (00_Database .. 08_Programmability under MVP-1/DBChanges).
-- These objects are ADDITIVE on top of it.
-- ============================================================

USE [FlatWireDB]
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO


-- Helper note: pattern is
--   IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'<ix>' AND object_id = OBJECT_ID(N'dbo.<Table>'))
--       CREATE INDEX ...

-- ------------------------------------------------------------
-- PassSchedule
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PassSchedule_LineAlloyStatus' AND object_id = OBJECT_ID(N'dbo.PassSchedule'))
    CREATE NONCLUSTERED INDEX [IX_PassSchedule_LineAlloyStatus] ON [dbo].[PassSchedule] ([LineId], [Alloy], [Status]);
GO

-- Business rule (Schedule.md): only ONE Active schedule per LineId + Alloy at a time.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_PassSchedule_OneActivePerLineAlloy' AND object_id = OBJECT_ID(N'dbo.PassSchedule'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_PassSchedule_OneActivePerLineAlloy]
        ON [dbo].[PassSchedule] ([LineId], [Alloy])
        WHERE [Status] = 'Active';
GO

-- ------------------------------------------------------------
-- PassScheduleComponent / PassScheduleChangeLog
-- (PassScheduleComponent already covered by UQ (PassScheduleId, Sequence))
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PSC_StandId' AND object_id = OBJECT_ID(N'dbo.PassScheduleComponent'))
    CREATE NONCLUSTERED INDEX [IX_PSC_StandId] ON [dbo].[PassScheduleComponent] ([StandId]) WHERE [StandId] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PSC_DrawerId' AND object_id = OBJECT_ID(N'dbo.PassScheduleComponent'))
    CREATE NONCLUSTERED INDEX [IX_PSC_DrawerId] ON [dbo].[PassScheduleComponent] ([DrawerId]) WHERE [DrawerId] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PSC_EdgerId' AND object_id = OBJECT_ID(N'dbo.PassScheduleComponent'))
    CREATE NONCLUSTERED INDEX [IX_PSC_EdgerId] ON [dbo].[PassScheduleComponent] ([EdgerId]) WHERE [EdgerId] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PSChangeLog_PassScheduleId' AND object_id = OBJECT_ID(N'dbo.PassScheduleChangeLog'))
    CREATE NONCLUSTERED INDEX [IX_PSChangeLog_PassScheduleId] ON [dbo].[PassScheduleChangeLog] ([PassScheduleId], [Timestamp] DESC);
GO