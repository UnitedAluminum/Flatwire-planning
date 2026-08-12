-- ============================================================
-- Flat Wire Mill (MVP-2) — DDL 06b: Foreign keys touching MVP-2 tables
-- Run order : 06b of 06 (MVP-2 chain)
-- Scope     : MVP-2 (deferred). NOT part of MVP-1.
-- ============================================================
-- Split out of FlatWire_DDL_06_ForeignKeys.sql on 11 Aug 2026 when the schema was
-- divided by MVP scope. 14 of the 43 FKs. THREE OF THEM ARE ON MVP-1 TABLES -- see the note below.
--
-- PREREQUISITE: the whole MVP-1 chain must already be deployed
-- (00_Database .. 08_Programmability under MVP-1/DBChanges).
-- These objects are ADDITIVE on top of it.
-- ============================================================

-- ============================================================
-- !!  FOUR OF THESE FKs ARE ON MVP-1 TABLES  !!
-- ============================================================
--   FlatWireRun.PassScheduleId  -> PassSchedule
--   RodCheckin.PassScheduleId   -> PassSchedule
--   SpoolCheckin.PassScheduleId -> PassSchedule
--   CoilOutput.PassScheduleId   -> PassSchedule   (added 11 Aug 2026,
--       when CoilOutput and CoilTraceability returned to MVP-1)
--
-- All four CHILD tables are MVP-1; only the PARENT is MVP-2. They
-- were routed here, not left in MVP-1's 06, for one reason: an
-- MVP-1-only build has no PassSchedule table, so leaving them there
-- made the MVP-1 chain undeployable. Putting them here keeps MVP-1
-- standalone-deployable with the columns present but UNENFORCED,
-- and makes enforcement an MVP-2 add-on.
--
-- WHAT THIS COSTS: between an MVP-1 deployment and an MVP-2
-- deployment, PassScheduleId is a free-text column on four tables.
-- Nothing stops a bad value going in, and rod check-in -- which
-- acknowledges a pass schedule and pushes PLC tags from it -- is
-- one of the three.
--
-- ORDERING TRAP: these four constraints are added against rows
-- MVP-1 already seeded, so the pass-schedule rows must exist first.
-- FlatWire_DDL_RunAll_MVP2.sql runs the schedule seed before this
-- script for exactly that reason. Do not invoke this file by hand
-- on a freshly-seeded MVP-1 database.
-- ============================================================

USE [FlatWireDB]
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO


-- ------------------------------------------------------------
-- PassSchedule → AlloyProperty (authoritative alloy list)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PassSchedule_AlloyProperty')
    ALTER TABLE [dbo].[PassSchedule]
        ADD CONSTRAINT [FK_PassSchedule_AlloyProperty]
        FOREIGN KEY ([Alloy]) REFERENCES [dbo].[AlloyProperty] ([Alloy]);
GO

-- ------------------------------------------------------------
-- PassScheduleChangeLog
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PSChangeLog_PassSchedule')
    ALTER TABLE [dbo].[PassScheduleChangeLog]
        ADD CONSTRAINT [FK_PSChangeLog_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

-- ------------------------------------------------------------
-- PassScheduleComponent
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PSC_PassSchedule')
    ALTER TABLE [dbo].[PassScheduleComponent]
        ADD CONSTRAINT [FK_PSC_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PSC_Stand')
    ALTER TABLE [dbo].[PassScheduleComponent]
        ADD CONSTRAINT [FK_PSC_Stand]
        FOREIGN KEY ([StandId]) REFERENCES [dbo].[Stand] ([Id]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PSC_Drawer')
    ALTER TABLE [dbo].[PassScheduleComponent]
        ADD CONSTRAINT [FK_PSC_Drawer]
        FOREIGN KEY ([DrawerId]) REFERENCES [dbo].[Drawer] ([Id]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PSC_Edger')
    ALTER TABLE [dbo].[PassScheduleComponent]
        ADD CONSTRAINT [FK_PSC_Edger]
        FOREIGN KEY ([EdgerId]) REFERENCES [dbo].[Edger] ([Id]);
GO

-- ------------------------------------------------------------
-- FlatWireRun
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FlatWireRun_PassSchedule')
    ALTER TABLE [dbo].[FlatWireRun]
        ADD CONSTRAINT [FK_FlatWireRun_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodCheckin_PassSchedule')
    ALTER TABLE [dbo].[RodCheckin]
        ADD CONSTRAINT [FK_RodCheckin_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolCheckin_PassSchedule')
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [FK_SpoolCheckin_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilOutput_PassSchedule')
    ALTER TABLE [dbo].[CoilOutput]
        ADD CONSTRAINT [FK_CoilOutput_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO