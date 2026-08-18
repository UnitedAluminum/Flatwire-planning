-- ============================================================
-- SCOPE: MVP-1. Built by FlatWire_DDL_RunAll.sql immediately after 06
-- (decision D-31, 15 Aug 2026; was MVP-2 from 11 Aug).
-- Flat Wire Mill — DDL 06b: Foreign keys touching the schedule tables
-- Run order : 06b, immediately after 06
-- Scope     : MVP-1
-- ============================================================
-- Split out of FlatWire_DDL_06_ForeignKeys.sql on 11 Aug 2026 when the schema was
-- divided by MVP scope, and returned to MVP-1 on 15 Aug 2026 by D-31.
-- 10 of the 43 FKs. FOUR OF THEM ARE ON MVP-1 TABLES -- see the note below.
-- ============================================================

-- ============================================================
-- !!  FOUR OF THESE FKs ARE NOW ENFORCED WHERE THEY WERE NOT  !!
-- ============================================================
--   FlatWireRun.PassScheduleId  -> PassSchedule
--   RodCheckin.PassScheduleId   -> PassSchedule
--   SpoolCheckin.PassScheduleId -> PassSchedule
--   CoilOutput.PassScheduleId   -> PassSchedule   (added 11 Aug 2026,
--       when CoilOutput and CoilTraceability returned to MVP-1)
--
-- ⚠ THIS IS A DELIBERATE REVERSAL, 15 Aug 2026 (D-31). From 11 to 15
--   Aug these four were routed out of MVP-1's 06 so that an MVP-1-only
--   build stayed deployable without a PassSchedule table -- which left
--   PassScheduleId as a free-text column on four tables, with nothing
--   stopping a bad value going in, on the very path (rod check-in)
--   that acknowledges a schedule and pushes PLC tags from it.
--
--   With the schedule tables now in MVP-1 that trade-off is gone and
--   the four links are REAL, ENFORCED foreign keys.
--
-- ⚠ PassScheduleId IS NO LONGER "a documented external reference".
--   Any document still describing it as unenforced, or as the same
--   class as PlanId / CoilOrderPlanId / SkidId, is STALE. Those three
--   ARE still external references with no local parents -- only
--   PassScheduleId changed.
--
-- ORDERING: FlatWire_DDL_RunAll.sql applies this to EMPTY tables
-- (all DDL runs before any seed), so there is no data to violate it.
-- The seed order still matters -- see the note in that runner.
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