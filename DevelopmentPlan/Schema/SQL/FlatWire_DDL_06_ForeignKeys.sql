-- ============================================================
-- Flat Wire Mill — DDL Script 06: Foreign Key Constraints
-- Run order : 06 of 09  (run AFTER all 01–05 scripts)
-- ============================================================
-- All FK constraints are added here in a single script so
-- tables can be created in logical groups (01–05) without
-- worrying about dependency order within each script.
-- To drop all FKs for a rebuild, run the DROP section below.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for tables with PERSISTED computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- OPTIONAL: Drop all FlatWire FKs before re-running this script
-- Uncomment this block if you need to rebuild constraints.
-- ============================================================
/*
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'ALTER TABLE [dbo].[' + t.name + '] DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
WHERE fk.name LIKE 'FK_FlatWire%'
   OR t.name IN (
       'PassSchedule','PassScheduleComponent','PassScheduleChangeLog','FlatWireRun','Spool','FlatWireRunDetail',
       'RodStaging','RodCheckin','SpoolCheckin','RunPauseEvent','WeldEvent','RollOverride',
       'DieChangeEvent','RunReading','SpcCheckpoint','SpcMeasurement','WipRejection',
       'CoilOutput','CoilTraceability','RodCheckout'
   );
EXEC sp_executesql @sql;
*/
-- ============================================================

PRINT '--- Adding FK constraints ---';
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

-- ------------------------------------------------------------
-- Spool
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Spool_SpoolConfiguration')
    ALTER TABLE [dbo].[Spool]
        ADD CONSTRAINT [FK_Spool_SpoolConfiguration]
        FOREIGN KEY ([SpoolTypeId]) REFERENCES [dbo].[SpoolConfiguration] ([Id]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Spool_Rod')
    ALTER TABLE [dbo].[Spool]
        ADD CONSTRAINT [FK_Spool_Rod]
        FOREIGN KEY ([ParentRodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Spool_FlatWireRun')
    ALTER TABLE [dbo].[Spool]
        ADD CONSTRAINT [FK_Spool_FlatWireRun]
        FOREIGN KEY ([SourceRunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Spool_SourceRod')
    ALTER TABLE [dbo].[Spool]
        ADD CONSTRAINT [FK_Spool_SourceRod]
        FOREIGN KEY ([SourceRodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

-- ------------------------------------------------------------
-- FlatWireRunDetail
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FlatWireRunDetail_FlatWireRun')
    ALTER TABLE [dbo].[FlatWireRunDetail]
        ADD CONSTRAINT [FK_FlatWireRunDetail_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

-- PayoffPositionId was previously an FK-style INT with no parent table
-- (REVIEW.md #15). PayoffPosition now exists in 01_Lookup, so enforce it.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FlatWireRunDetail_PayoffPosition')
    ALTER TABLE [dbo].[FlatWireRunDetail]
        ADD CONSTRAINT [FK_FlatWireRunDetail_PayoffPosition]
        FOREIGN KEY ([PayoffPositionId]) REFERENCES [dbo].[PayoffPosition] ([Id]);
GO

-- ------------------------------------------------------------
-- RodStaging (pre-check-in)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodStaging_Rod')
    ALTER TABLE [dbo].[RodStaging]
        ADD CONSTRAINT [FK_RodStaging_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodStaging_PayoffPosition')
    ALTER TABLE [dbo].[RodStaging]
        ADD CONSTRAINT [FK_RodStaging_PayoffPosition]
        FOREIGN KEY ([PayoffPosition]) REFERENCES [dbo].[PayoffPosition] ([Id]);
GO

-- Set when check-in consumes the staged row, closing the staging → check-in chain.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodStaging_RodCheckin')
    ALTER TABLE [dbo].[RodStaging]
        ADD CONSTRAINT [FK_RodStaging_RodCheckin]
        FOREIGN KEY ([RodCheckinId]) REFERENCES [dbo].[RodCheckin] ([Id]);
GO

-- ------------------------------------------------------------
-- RodCheckin
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodCheckin_FlatWireRun')
    ALTER TABLE [dbo].[RodCheckin]
        ADD CONSTRAINT [FK_RodCheckin_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodCheckin_Rod')
    ALTER TABLE [dbo].[RodCheckin]
        ADD CONSTRAINT [FK_RodCheckin_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodCheckin_PassSchedule')
    ALTER TABLE [dbo].[RodCheckin]
        ADD CONSTRAINT [FK_RodCheckin_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

-- ------------------------------------------------------------
-- SpoolCheckin
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolCheckin_FlatWireRun')
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [FK_SpoolCheckin_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolCheckin_Spool')
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [FK_SpoolCheckin_Spool]
        FOREIGN KEY ([SpoolAlpha]) REFERENCES [dbo].[Spool] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolCheckin_PassSchedule')
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [FK_SpoolCheckin_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

-- ------------------------------------------------------------
-- RunPauseEvent
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RunPauseEvent_FlatWireRun')
    ALTER TABLE [dbo].[RunPauseEvent]
        ADD CONSTRAINT [FK_RunPauseEvent_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

-- ------------------------------------------------------------
-- WeldEvent
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_WeldEvent_FlatWireRun')
    ALTER TABLE [dbo].[WeldEvent]
        ADD CONSTRAINT [FK_WeldEvent_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_WeldEvent_OutgoingRod')
    ALTER TABLE [dbo].[WeldEvent]
        ADD CONSTRAINT [FK_WeldEvent_OutgoingRod]
        FOREIGN KEY ([OutgoingRodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_WeldEvent_IncomingRod')
    ALTER TABLE [dbo].[WeldEvent]
        ADD CONSTRAINT [FK_WeldEvent_IncomingRod]
        FOREIGN KEY ([IncomingRodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

-- ------------------------------------------------------------
-- RollOverride
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RollOverride_FlatWireRun')
    ALTER TABLE [dbo].[RollOverride]
        ADD CONSTRAINT [FK_RollOverride_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RollOverride_Rod')
    ALTER TABLE [dbo].[RollOverride]
        ADD CONSTRAINT [FK_RollOverride_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

-- ------------------------------------------------------------
-- DieChangeEvent
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieChangeEvent_FlatWireRun')
    ALTER TABLE [dbo].[DieChangeEvent]
        ADD CONSTRAINT [FK_DieChangeEvent_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieChangeEvent_Rod')
    ALTER TABLE [dbo].[DieChangeEvent]
        ADD CONSTRAINT [FK_DieChangeEvent_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieChangeEvent_RollOverride')
    ALTER TABLE [dbo].[DieChangeEvent]
        ADD CONSTRAINT [FK_DieChangeEvent_RollOverride]
        FOREIGN KEY ([LinkedOverrideId]) REFERENCES [dbo].[RollOverride] ([OverrideId]);
GO

-- ------------------------------------------------------------
-- SpcCheckpoint
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpcCheckpoint_FlatWireRun')
    ALTER TABLE [dbo].[SpcCheckpoint]
        ADD CONSTRAINT [FK_SpcCheckpoint_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

-- ------------------------------------------------------------
-- SpcMeasurement
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpcMeasurement_SpcCheckpoint')
    ALTER TABLE [dbo].[SpcMeasurement]
        ADD CONSTRAINT [FK_SpcMeasurement_SpcCheckpoint]
        FOREIGN KEY ([CheckpointId]) REFERENCES [dbo].[SpcCheckpoint] ([CheckpointId]);
GO

-- ------------------------------------------------------------
-- WipRejection
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_WipRejection_FlatWireRun')
    ALTER TABLE [dbo].[WipRejection]
        ADD CONSTRAINT [FK_WipRejection_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

-- ------------------------------------------------------------
-- CoilOutput
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilOutput_FlatWireRun')
    ALTER TABLE [dbo].[CoilOutput]
        ADD CONSTRAINT [FK_CoilOutput_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilOutput_PassSchedule')
    ALTER TABLE [dbo].[CoilOutput]
        ADD CONSTRAINT [FK_CoilOutput_PassSchedule]
        FOREIGN KEY ([PassScheduleId]) REFERENCES [dbo].[PassSchedule] ([ScheduleId]);
GO

-- ------------------------------------------------------------
-- RunReading
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RunReading_FlatWireRun')
    ALTER TABLE [dbo].[RunReading]
        ADD CONSTRAINT [FK_RunReading_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

-- ------------------------------------------------------------
-- CoilTraceability
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilTraceability_CoilOutput')
    ALTER TABLE [dbo].[CoilTraceability]
        ADD CONSTRAINT [FK_CoilTraceability_CoilOutput]
        FOREIGN KEY ([CoilAlpha]) REFERENCES [dbo].[CoilOutput] ([CoilAlpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilTraceability_Rod')
    ALTER TABLE [dbo].[CoilTraceability]
        ADD CONSTRAINT [FK_CoilTraceability_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

-- ------------------------------------------------------------
-- RodCheckout
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodCheckout_FlatWireRun')
    ALTER TABLE [dbo].[RodCheckout]
        ADD CONSTRAINT [FK_RodCheckout_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodCheckout_Rod')
    ALTER TABLE [dbo].[RodCheckout]
        ADD CONSTRAINT [FK_RodCheckout_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

PRINT '--- All FK constraints added successfully ---';
GO
