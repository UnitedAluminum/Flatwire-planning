-- ============================================================
-- Flat Wire Mill — DDL Script 07: Performance Indexes
-- Run order : 07 of 09  (run AFTER 06_ForeignKeys)
-- ============================================================
-- Non-clustered indexes covering the FK/join columns and the
-- query paths driven by the dashboards (line-status board,
-- active-run gauge trace, genealogy/traceability lookups,
-- shift summary). Business/natural keys already carry UNIQUE
-- constraints (indexed), so only child FK columns and hot
-- filter columns are added here.
--
-- Includes the filtered-unique rule enforcing ONE Active
-- PassSchedule per (LineId, Alloy).
--
-- All guarded with IF NOT EXISTS — idempotent / re-runnable.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for creating filtered indexes.
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

-- ------------------------------------------------------------
-- FlatWireRun (hub) + Spool
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FlatWireRun_LineId' AND object_id = OBJECT_ID(N'dbo.FlatWireRun'))
    CREATE NONCLUSTERED INDEX [IX_FlatWireRun_LineId] ON [dbo].[FlatWireRun] ([LineId], [Status]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FlatWireRun_Status' AND object_id = OBJECT_ID(N'dbo.FlatWireRun'))
    CREATE NONCLUSTERED INDEX [IX_FlatWireRun_Status] ON [dbo].[FlatWireRun] ([Status]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FlatWireRun_PassScheduleId' AND object_id = OBJECT_ID(N'dbo.FlatWireRun'))
    CREATE NONCLUSTERED INDEX [IX_FlatWireRun_PassScheduleId] ON [dbo].[FlatWireRun] ([PassScheduleId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FlatWireRun_OrderId' AND object_id = OBJECT_ID(N'dbo.FlatWireRun'))
    CREATE NONCLUSTERED INDEX [IX_FlatWireRun_OrderId] ON [dbo].[FlatWireRun] ([OrderId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Spool_SourceRunId' AND object_id = OBJECT_ID(N'dbo.Spool'))
    CREATE NONCLUSTERED INDEX [IX_Spool_SourceRunId] ON [dbo].[Spool] ([SourceRunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Spool_ParentRodAlpha' AND object_id = OBJECT_ID(N'dbo.Spool'))
    CREATE NONCLUSTERED INDEX [IX_Spool_ParentRodAlpha] ON [dbo].[Spool] ([ParentRodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Spool_SourceRodAlpha' AND object_id = OBJECT_ID(N'dbo.Spool'))
    CREATE NONCLUSTERED INDEX [IX_Spool_SourceRodAlpha] ON [dbo].[Spool] ([SourceRodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Spool_Status' AND object_id = OBJECT_ID(N'dbo.Spool'))
    CREATE NONCLUSTERED INDEX [IX_Spool_Status] ON [dbo].[Spool] ([Status]);
GO

-- ------------------------------------------------------------
-- Run child / event tables — all indexed on RunId
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FlatWireRunDetail_RunId' AND object_id = OBJECT_ID(N'dbo.FlatWireRunDetail'))
    CREATE NONCLUSTERED INDEX [IX_FlatWireRunDetail_RunId] ON [dbo].[FlatWireRunDetail] ([RunId]);
GO
-- ------------------------------------------------------------
-- RodStaging — the bay-occupancy invariants are enforced here.
-- These two FILTERED UNIQUE indexes are the reason RodStaging is a
-- table rather than a pair of nullable columns on Rod: they make
-- "one rod per payoff bay" and "one bay per rod" impossible to
-- violate, including under concurrent staging from two clients.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodStaging_Bay' AND object_id = OBJECT_ID(N'dbo.RodStaging'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodStaging_Bay]
        ON [dbo].[RodStaging] ([LineId], [PayoffPosition])
        WHERE [Status] = 'Staged';
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodStaging_RodActive' AND object_id = OBJECT_ID(N'dbo.RodStaging'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodStaging_RodActive]
        ON [dbo].[RodStaging] ([RodAlpha])
        WHERE [Status] = 'Staged';
GO
-- Primary dashboard query: "what is on each bay of this line right now".
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodStaging_LineId_Status' AND object_id = OBJECT_ID(N'dbo.RodStaging'))
    CREATE NONCLUSTERED INDEX [IX_RodStaging_LineId_Status] ON [dbo].[RodStaging] ([LineId], [Status]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodStaging_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RodStaging'))
    CREATE NONCLUSTERED INDEX [IX_RodStaging_RodAlpha] ON [dbo].[RodStaging] ([RodAlpha]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckin_RunId' AND object_id = OBJECT_ID(N'dbo.RodCheckin'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckin_RunId] ON [dbo].[RodCheckin] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckin_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RodCheckin'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckin_RodAlpha] ON [dbo].[RodCheckin] ([RodAlpha]);
GO
-- Was missing: resolving the active rod on a given bay required a scan.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckin_LineId_PayoffPosition' AND object_id = OBJECT_ID(N'dbo.RodCheckin'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckin_LineId_PayoffPosition] ON [dbo].[RodCheckin] ([LineId], [PayoffPosition]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckin_PassScheduleId' AND object_id = OBJECT_ID(N'dbo.RodCheckin'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckin_PassScheduleId] ON [dbo].[RodCheckin] ([PassScheduleId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolCheckin_RunId' AND object_id = OBJECT_ID(N'dbo.SpoolCheckin'))
    CREATE NONCLUSTERED INDEX [IX_SpoolCheckin_RunId] ON [dbo].[SpoolCheckin] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolCheckin_SpoolAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolCheckin'))
    CREATE NONCLUSTERED INDEX [IX_SpoolCheckin_SpoolAlpha] ON [dbo].[SpoolCheckin] ([SpoolAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RunPauseEvent_RunId' AND object_id = OBJECT_ID(N'dbo.RunPauseEvent'))
    CREATE NONCLUSTERED INDEX [IX_RunPauseEvent_RunId] ON [dbo].[RunPauseEvent] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeldEvent_RunId' AND object_id = OBJECT_ID(N'dbo.WeldEvent'))
    CREATE NONCLUSTERED INDEX [IX_WeldEvent_RunId] ON [dbo].[WeldEvent] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeldEvent_OutgoingRodAlpha' AND object_id = OBJECT_ID(N'dbo.WeldEvent'))
    CREATE NONCLUSTERED INDEX [IX_WeldEvent_OutgoingRodAlpha] ON [dbo].[WeldEvent] ([OutgoingRodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeldEvent_IncomingRodAlpha' AND object_id = OBJECT_ID(N'dbo.WeldEvent'))
    CREATE NONCLUSTERED INDEX [IX_WeldEvent_IncomingRodAlpha] ON [dbo].[WeldEvent] ([IncomingRodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RollOverride_RunId' AND object_id = OBJECT_ID(N'dbo.RollOverride'))
    CREATE NONCLUSTERED INDEX [IX_RollOverride_RunId] ON [dbo].[RollOverride] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RollOverride_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RollOverride'))
    CREATE NONCLUSTERED INDEX [IX_RollOverride_RodAlpha] ON [dbo].[RollOverride] ([RodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DieChangeEvent_RunId' AND object_id = OBJECT_ID(N'dbo.DieChangeEvent'))
    CREATE NONCLUSTERED INDEX [IX_DieChangeEvent_RunId] ON [dbo].[DieChangeEvent] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DieChangeEvent_LinkedOverrideId' AND object_id = OBJECT_ID(N'dbo.DieChangeEvent'))
    CREATE NONCLUSTERED INDEX [IX_DieChangeEvent_LinkedOverrideId] ON [dbo].[DieChangeEvent] ([LinkedOverrideId]) WHERE [LinkedOverrideId] IS NOT NULL;
GO

-- ------------------------------------------------------------
-- RunReading — trace-query path (run + footage)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RunReading_RunId_Footage' AND object_id = OBJECT_ID(N'dbo.RunReading'))
    CREATE NONCLUSTERED INDEX [IX_RunReading_RunId_Footage] ON [dbo].[RunReading] ([RunId], [FootageFt]);
GO

-- ------------------------------------------------------------
-- Quality / Output
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpcCheckpoint_RunId' AND object_id = OBJECT_ID(N'dbo.SpcCheckpoint'))
    CREATE NONCLUSTERED INDEX [IX_SpcCheckpoint_RunId] ON [dbo].[SpcCheckpoint] ([RunId], [CheckpointType]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpcMeasurement_CheckpointId' AND object_id = OBJECT_ID(N'dbo.SpcMeasurement'))
    CREATE NONCLUSTERED INDEX [IX_SpcMeasurement_CheckpointId] ON [dbo].[SpcMeasurement] ([CheckpointId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WipRejection_RunId' AND object_id = OBJECT_ID(N'dbo.WipRejection'))
    CREATE NONCLUSTERED INDEX [IX_WipRejection_RunId] ON [dbo].[WipRejection] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WipRejection_MaterialAlpha' AND object_id = OBJECT_ID(N'dbo.WipRejection'))
    CREATE NONCLUSTERED INDEX [IX_WipRejection_MaterialAlpha] ON [dbo].[WipRejection] ([MaterialAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilOutput_RunId' AND object_id = OBJECT_ID(N'dbo.CoilOutput'))
    CREATE NONCLUSTERED INDEX [IX_CoilOutput_RunId] ON [dbo].[CoilOutput] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilOutput_OrderId' AND object_id = OBJECT_ID(N'dbo.CoilOutput'))
    CREATE NONCLUSTERED INDEX [IX_CoilOutput_OrderId] ON [dbo].[CoilOutput] ([OrderId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilOutput_SkidId' AND object_id = OBJECT_ID(N'dbo.CoilOutput'))
    CREATE NONCLUSTERED INDEX [IX_CoilOutput_SkidId] ON [dbo].[CoilOutput] ([SkidId]) WHERE [SkidId] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilOutput_PassScheduleId' AND object_id = OBJECT_ID(N'dbo.CoilOutput'))
    CREATE NONCLUSTERED INDEX [IX_CoilOutput_PassScheduleId] ON [dbo].[CoilOutput] ([PassScheduleId]) WHERE [PassScheduleId] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilTraceability_CoilAlpha' AND object_id = OBJECT_ID(N'dbo.CoilTraceability'))
    CREATE NONCLUSTERED INDEX [IX_CoilTraceability_CoilAlpha] ON [dbo].[CoilTraceability] ([CoilAlpha], [FootageFrom], [FootageTo]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilTraceability_RodAlpha' AND object_id = OBJECT_ID(N'dbo.CoilTraceability'))
    CREATE NONCLUSTERED INDEX [IX_CoilTraceability_RodAlpha] ON [dbo].[CoilTraceability] ([RodAlpha]);
GO
-- Filtered: SpoolAlpha is NULL on every rod-fed run, and "which coils came off
-- this spool" is the only query that uses it. Matches IX_CoilOutput_PassScheduleId above.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilTraceability_SpoolAlpha' AND object_id = OBJECT_ID(N'dbo.CoilTraceability'))
    CREATE NONCLUSTERED INDEX [IX_CoilTraceability_SpoolAlpha] ON [dbo].[CoilTraceability] ([SpoolAlpha]) WHERE [SpoolAlpha] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckout_RunId' AND object_id = OBJECT_ID(N'dbo.RodCheckout'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckout_RunId] ON [dbo].[RodCheckout] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckout_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RodCheckout'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckout_RodAlpha] ON [dbo].[RodCheckout] ([RodAlpha]);
GO

PRINT '--- All performance indexes created successfully ---';
GO
