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
-- Creates ALL 70 index statements. There is no second index script.
-- 70, not 69, since 26 Aug 2026: Q89 added UX_CoilTraceability_ChildAlpha.
--
-- ⚠ 07b WAS FOLDED BACK INTO THIS FILE. It was split out on 11 Aug
--   2026 when the schema was divided by MVP scope, returned to MVP-1
--   on 15 Aug 2026 by D-31, and merged back here because the division
--   that justified a separate file no longer exists. Its six schedule
--   indexes are the last section below -- including the filtered-unique
--   rule enforcing ONE Active PassSchedule per (LineId, Alloy), which
--   this header used to claim while the index lived in 07b.
--
-- The counted total is [DBD 6.2]. This file does not restate it.
--
-- All guarded with IF NOT EXISTS — idempotent / re-runnable.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for creating filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- FlatWireRun (hub) + SpoolProcessing
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FlatWireRun_LineId' AND object_id = OBJECT_ID(N'dbo.FlatWireRun'))
    CREATE NONCLUSTERED INDEX [IX_FlatWireRun_LineId] ON [dbo].[FlatWireRun] ([LineId], [Status]);
GO
-- SINGLE ACTIVE RUN PER LINE (FW-222, 19 Aug 2026).
-- IX_FlatWireRun_LineId above is NON-unique, so nothing in the database stopped two concurrent
-- check-ins on one line from both committing: each passed the aggregate check, neither saw the
-- other. That is exactly the read-then-write race CoilCheckin's IsAnyCoilCheckedInRule has, and
-- the reference implementation is not a pattern to copy here.
--   phase-04     "single active run per line" as a business rule
--   FW-157 Sec 3 owes 409 RUN_ALREADY_ACTIVE
--   SVC Sec 3.4  invariants in the aggregate -> 422
-- The aggregate still enforces it in code; this index is BELT-AND-BRACES, in the same idiom as
-- UX_RodStaging_Bay below, and it is what makes the 409 truthful under concurrency rather than
-- merely likely.
-- NOTE the filter is IN (...), which a filtered-index predicate does support as a single
-- disjunct. Do NOT rewrite it as OR - filtered indexes reject that.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_FlatWireRun_ActiveLine' AND object_id = OBJECT_ID(N'dbo.FlatWireRun'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_FlatWireRun_ActiveLine]
        ON [dbo].[FlatWireRun] ([LineId])
        WHERE [Status] IN ('Running','Paused');
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolProcessing_SourceRunId' AND object_id = OBJECT_ID(N'dbo.SpoolProcessing'))
    CREATE NONCLUSTERED INDEX [IX_SpoolProcessing_SourceRunId] ON [dbo].[SpoolProcessing] ([SourceRunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolProcessing_ParentRodAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolProcessing'))
    CREATE NONCLUSTERED INDEX [IX_SpoolProcessing_ParentRodAlpha] ON [dbo].[SpoolProcessing] ([ParentRodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolProcessing_SourceRodAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolProcessing'))
    CREATE NONCLUSTERED INDEX [IX_SpoolProcessing_SourceRodAlpha] ON [dbo].[SpoolProcessing] ([SourceRodAlpha]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolProcessing_Status' AND object_id = OBJECT_ID(N'dbo.SpoolProcessing'))
    CREATE NONCLUSTERED INDEX [IX_SpoolProcessing_Status] ON [dbo].[SpoolProcessing] ([Status]);
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
-- G21 (resolved 15 Aug 2026): keyed on [Station], NOT [LineId].
-- FL1 and FL3 share one physical VPS, so a (LineId, PayoffPosition) key admitted
-- (FL1,1) AND (FL3,1) as distinct entries for ONE bay -- the invariant this index
-- exists to defend did not hold. Q24 compounds it: the station switches line by
-- itself, so LineId is rewritten underneath the key. See 04_Runs for the column.
-- The RodStaging AGGREGATE enforces the same rule in code; this index is
-- belt-and-braces, not the sole defence.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodStaging_Bay' AND object_id = OBJECT_ID(N'dbo.RodStaging'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodStaging_Bay]
        ON [dbo].[RodStaging] ([Station], [PayoffPosition])
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckout_RunId' AND object_id = OBJECT_ID(N'dbo.RodCheckout'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckout_RunId] ON [dbo].[RodCheckout] ([RunId]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodCheckout_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RodCheckout'))
    CREATE NONCLUSTERED INDEX [IX_RodCheckout_RodAlpha] ON [dbo].[RodCheckout] ([RodAlpha]);
GO

PRINT '--- All performance indexes created successfully ---';
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
-- FR-509 / [INT §8.1]. UNIQUE and filtered: one FlatWireDB coil maps to exactly one shared
-- coils.coil_no, and this index is what makes the FlatWire_CompleteCoilOnSkid retry contract
-- enforceable rather than merely documented -- a second call for the same coil is refused here.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_CoilOutput_CoilNo' AND object_id = OBJECT_ID(N'dbo.CoilOutput'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_CoilOutput_CoilNo] ON [dbo].[CoilOutput] ([CoilNo]) WHERE [CoilNo] IS NOT NULL;
GO

-- UX_CoilTraceability_ChildAlpha -- one row per shared coil identity, and since
-- Q89 there is one identity per (coil x source rod), so a welded coil has N.
--
-- FILTERED because ChildAlpha is nullable by design: the value does not exist
-- until the cross-database mint returns, the same reason UX_CoilOutput_CoilNo
-- above is filtered. A filtered UNIQUE admits many NULLs and exactly one of
-- each non-NULL value (TC-789).
--
-- IT CANNOT ENFORCE ORD021. That rule -- no string in both
-- SpoolTraceability.ChildAlpha and CoilTraceability.ChildAlpha for one rod --
-- spans two tables and no index can express it. It rests on the shared ignore
-- list and is asserted by TC-788.
--
-- AND IT IS WHY SourceSegmentAlpha CANNOT BE AN FK: a foreign key cannot point
-- at a FILTERED unique index, so the sibling column in 05_QualityOutput is
-- guarded by the domain model and TC-794 instead. That is a SQL Server
-- limitation, not a design choice -- do not "fix" it by adding a constraint.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_CoilTraceability_ChildAlpha' AND object_id = OBJECT_ID(N'dbo.CoilTraceability'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_CoilTraceability_ChildAlpha] ON [dbo].[CoilTraceability] ([ChildAlpha]) WHERE [ChildAlpha] IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CoilOutput_SharedSkidNo' AND object_id = OBJECT_ID(N'dbo.CoilOutput'))
    CREATE NONCLUSTERED INDEX [IX_CoilOutput_SharedSkidNo] ON [dbo].[CoilOutput] ([SharedSkidNo]) WHERE [SharedSkidNo] IS NOT NULL;
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

-- ------------------------------------------------------------
-- SpoolProcessing genealogy, order set and the FL2 queue (added 22 Aug 2026)
--
-- NOTE: there is deliberately NO unique index on
-- SpoolStaging.QueuePosition. Drag-and-drop reorder swaps positions and
-- a UNIQUE index rejects the transient duplicate mid-swap -- a trap
-- that does not surface until the second reorder. Ordering uniqueness
-- is not a data-integrity property here; the fractional DECIMAL
-- position makes collisions harmless.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolTraceability_SpoolAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolTraceability'))
    CREATE NONCLUSTERED INDEX [IX_SpoolTraceability_SpoolAlpha] ON [dbo].[SpoolTraceability] ([SpoolAlpha], [SeqNo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolTraceability_RodAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolTraceability'))
    CREATE NONCLUSTERED INDEX [IX_SpoolTraceability_RodAlpha] ON [dbo].[SpoolTraceability] ([RodAlpha]);
GO

-- Resolves a spool from any order on it -- the GET /spools lookup path.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolOrder_OrderNo' AND object_id = OBJECT_ID(N'dbo.SpoolOrder'))
    CREATE NONCLUSTERED INDEX [IX_SpoolOrder_OrderNo] ON [dbo].[SpoolOrder] ([OrderNo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolOrder_SpoolAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolOrder'))
    CREATE NONCLUSTERED INDEX [IX_SpoolOrder_SpoolAlpha] ON [dbo].[SpoolOrder] ([SpoolAlpha]);
GO

-- The queue read: one line's live queue, in operator order.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolStaging_Queue' AND object_id = OBJECT_ID(N'dbo.SpoolStaging'))
    CREATE NONCLUSTERED INDEX [IX_SpoolStaging_Queue] ON [dbo].[SpoolStaging] ([LineId], [QueuePosition]) WHERE [Status] = 'Queued';
GO

-- One live queue entry per spool per line. Filtered, so a withdrawn or
-- checked-in row does not block re-queueing the same spool later --
-- which the two-run case requires.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SpoolStaging_LiveSpool' AND object_id = OBJECT_ID(N'dbo.SpoolStaging'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_SpoolStaging_LiveSpool] ON [dbo].[SpoolStaging] ([LineId], [SpoolAlpha]) WHERE [Status] = 'Queued';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpoolProcessing_SpoolId' AND object_id = OBJECT_ID(N'dbo.SpoolProcessing'))
    CREATE NONCLUSTERED INDEX [IX_SpoolProcessing_SpoolId] ON [dbo].[SpoolProcessing] ([SpoolId]) WHERE [SpoolId] IS NOT NULL;
GO

------------------------------------------------------------
-- ROD <-> ORDER  (added 22 Aug 2026)
------------------------------------------------------------

-- One ACTIVE allocation per (rod, order, release). FILTERED unique, NOT SpoolOrder's
-- ISNULL-into-the-key trick: here SQL Server's treat-NULLs-as-equal behaviour is exactly
-- what is wanted, because two rows with a NULL RelLetter for one rod and order ARE the
-- same pairing. State the difference, or the next reader "fixes" it.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodOrderAllocation_Active' AND object_id = OBJECT_ID(N'dbo.RodOrderAllocation'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderAllocation_Active] ON [dbo].[RodOrderAllocation] ([RodAlpha], [OrderNo], [RelLetter]) WHERE [IsActive] = 1;
GO

-- No two rods share a planned position within one order.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodOrderAllocation_OrderRodSeq' AND object_id = OBJECT_ID(N'dbo.RodOrderAllocation'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderAllocation_OrderRodSeq] ON [dbo].[RodOrderAllocation] ([OrderNo], [RelLetter], [RodSeqNoInOrder]) WHERE [IsActive] = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderAllocation_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RodOrderAllocation'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderAllocation_RodAlpha] ON [dbo].[RodOrderAllocation] ([RodAlpha]) INCLUDE ([OrderNo], [PinRole], [IsActive]);
GO

-- The sequence validator's read path: an order's rod set with everything it needs.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderAllocation_Order' AND object_id = OBJECT_ID(N'dbo.RodOrderAllocation'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderAllocation_Order] ON [dbo].[RodOrderAllocation] ([OrderNo], [RelLetter]) INCLUDE ([RodAlpha], [RodSeqNoInOrder], [PinRole], [RodKind], [AllocatedWeightLb]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderAllocation_OrderSeq' AND object_id = OBJECT_ID(N'dbo.RodOrderAllocation'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderAllocation_OrderSeq] ON [dbo].[RodOrderAllocation] ([OrderSeqNo]) WHERE [IsActive] = 1;
GO

-- ============================================================
-- RULE 2 AS A CONSTRAINT, NOT AS A 409.
-- Orders are processed one at a time to completion, so at most ONE pairing may be
-- open at a payoff. Enforced here rather than only in the application, for the same
-- reason UX_RodStaging_Bay is: a rule checked only in code is not enforced under
-- concurrent clients. Q17 asks for exactly this shape on the spool side.
--
-- Keyed on Station, so FL1 and FL3 -- which share one physical VPS -- cannot both
-- hold an open order.
--
-- The predicate MUST be a literal IN list: SQL Server forbids a computed column in a
-- filtered-index predicate, so an IsOpen BIT convenience column cannot be used here.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodOrderConsumption_Station' AND object_id = OBJECT_ID(N'dbo.RodOrderConsumption'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderConsumption_Station] ON [dbo].[RodOrderConsumption] ([Station]) WHERE [State] IN ('InProgress','ThresholdReached');
GO

-- No two rods take the same actual position within one order.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_RodOrderConsumption_ActualSeq' AND object_id = OBJECT_ID(N'dbo.RodOrderConsumption'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderConsumption_ActualSeq] ON [dbo].[RodOrderConsumption] ([OrderNo], [RelLetter], [ActualRodSeqNo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderConsumption_Order' AND object_id = OBJECT_ID(N'dbo.RodOrderConsumption'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_Order] ON [dbo].[RodOrderConsumption] ([OrderNo], [RelLetter]) INCLUDE ([State], [ConsumedWeightLb], [AllocatedWeightLbSnapshot], [RodAlpha]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderConsumption_RunId' AND object_id = OBJECT_ID(N'dbo.RodOrderConsumption'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_RunId] ON [dbo].[RodOrderConsumption] ([RunId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderConsumption_Checkin' AND object_id = OBJECT_ID(N'dbo.RodOrderConsumption'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_Checkin] ON [dbo].[RodOrderConsumption] ([RodCheckinId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RodOrderConsumption_RodAlpha' AND object_id = OBJECT_ID(N'dbo.RodOrderConsumption'))
    CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_RodAlpha] ON [dbo].[RodOrderConsumption] ([RodAlpha]);
GO

-- Q57. Filtered, because the column is nullable until a segment is named. This index
-- is what makes a third-party alpha collision LOUD rather than silent (Q59).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SpoolTraceability_ChildAlpha' AND object_id = OBJECT_ID(N'dbo.SpoolTraceability'))
    CREATE UNIQUE NONCLUSTERED INDEX [UX_SpoolTraceability_ChildAlpha] ON [dbo].[SpoolTraceability] ([ChildAlpha]) WHERE [ChildAlpha] IS NOT NULL;
GO


-- ============================================================
-- SECTION: Indexes on the schedule tables
-- ============================================================
-- Six of this file's index statements. Split out as 07b on 11 Aug 2026
-- by MVP scope, returned to MVP-1 on 15 Aug 2026 (D-31), and folded
-- back in here. The old file carried a PREREQUISITE note saying the
-- whole MVP-1 chain must already be deployed and that these objects
-- were ADDITIVE on top of it -- that was already false once D-31 put
-- 07b inside the MVP-1 chain ahead of 08, and it is gone.
-- ============================================================

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
