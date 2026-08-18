-- ============================================================
-- SCOPE: MVP-1. Built by FlatWire_DDL_RunAll.sql immediately after 07
-- (decision D-31, 15 Aug 2026; was MVP-2 from 11 Aug).
-- Flat Wire Mill — DDL 07b: Indexes on the schedule tables
-- Run order : 07b, immediately after 07
-- Scope     : MVP-1
-- ============================================================
-- Split out of FlatWire_DDL_07_Indexes.sql on 11 Aug 2026 when the schema was
-- divided by MVP scope, and returned to MVP-1 on 15 Aug 2026 by D-31.
-- 6 of the 47 index statements (41 in 07, 6 here).
--
-- PREREQUISITE: the whole MVP-1 chain must already be deployed
-- (00_Database .. 08_Programmability under MVP-1/ProjectPlan/Database).
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