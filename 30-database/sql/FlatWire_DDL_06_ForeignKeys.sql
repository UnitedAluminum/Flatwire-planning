-- ============================================================
-- Flat Wire Mill — DDL Script 06: Foreign Key Constraints
-- Run order : 06 of 09  (run AFTER all 01–05 scripts)
-- Creates   : ALL 62 foreign keys. There is no second FK script.
--             62, not 58, since 2 Sep 2026 (later the same day): the client's
--             reason-code lists added FK_RunPauseEvent_DelayCode,
--             FK_LineDowntimeEvent_DelayCode, FK_LineDowntimeEvent_Run and
--             FK_WipRejection_Reason.  (+4)
--             It was 58, not 55, since 2 Sep 2026: the die split dropped
--             FK_PSC_Drawer with PassScheduleComponent.DrawerId and added
--             FK_DieChangeEvent_OldDie, FK_DieChangeEvent_NewDie,
--             FK_DieHistory_Die and FK_DieHistory_Run.  (-1 +4)
--             It was 55, not 57, from 23 Aug 2026: the SpoolConfiguration
--             merge (Q60) dropped FK_SpoolProcessing_SpoolConfiguration and
--             FK_Spool_SpoolConfiguration with their SpoolTypeId columns.
-- ============================================================
-- All FK constraints are added here in a single script so
-- tables can be created in logical groups (01–05) without
-- worrying about dependency order within each script.
-- To drop all FKs for a rebuild, run the DROP section below.
--
-- ⚠ 06b WAS FOLDED BACK INTO THIS FILE. It was split out on 11 Aug
--   2026 when the schema was divided by MVP scope, returned to MVP-1
--   on 15 Aug 2026 by D-31, and merged back here because the division
--   that justified a separate file no longer exists. Its ten schedule
--   FKs are the last section below. Do not re-split it: the "47 of the
--   57 FKs" split-count is exactly the two-number form that drifted
--   four times across four documents.
--
-- The counted total is [DBD 6.2]. This file does not restate it.
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
       -- EVERY table this database has a foreign key on. Keep this roster in
       -- step with 01-05: a name missing here means its constraints are NOT
       -- dropped, so the rebuild half-completes and looks like it worked.
       --
       -- The three PassSchedule* tables ARE MVP-1 and ARE listed below --
       -- decision D-31, 15 Aug 2026, which also made PassScheduleId a REAL
       -- ENFORCED foreign key on FlatWireRun, RodCheckin, SpoolCheckin and
       -- CoilOutput (added by 06b, folded into this file). Any comment or
       -- document still calling PassScheduleId "a documented external
       -- reference with no local parent" is STALE.
       --
       -- Still external, still with no local parent, still NOT to be given
       -- an FK: PlanId, CoilOrderPlanId, CoilOutput.SkidId, and the OrderNo
       -- columns on SpoolOrder / RodOrderAllocation / RodOrderConsumption
       -- (D-32 -- there is no shared-schema migration).
       -- See phase-01c-database-foundation.md, "Cross-DB logical FKs".
       --
       -- Lookup / Schedule
       'PassSchedule','PassScheduleComponent','PassScheduleChangeLog',
       'Spool',
       -- Materials
       'FlatWireRun','SpoolProcessing','SpoolTraceability','SpoolOrder','RodOrderAllocation',
       -- Runs
       'FlatWireRunDetail','RodStaging','RodCheckin','SpoolCheckin','SpoolStaging',
       'RunPauseEvent','WeldEvent','RollOverride','DieChangeEvent','DieHistory','RunReading',
       'RodOrderConsumption',
       -- ToolingInventoryDie is deliberately ABSENT: it is a pure parent, with no
       -- FK column of its own, and this roster lists CHILD tables only.
       -- Quality / Output  (CoilOutput and CoilTraceability are MVP-1;
       -- Phase 9 returned whole on 11 Aug 2026)
       'SpcCheckpoint','SpcMeasurement','WipRejection',
       'CoilOutput','CoilTraceability','RodCheckout'
   );
EXEC sp_executesql @sql;
*/
-- ============================================================

PRINT '--- Adding FK constraints ---';
GO

-- ------------------------------------------------------------
-- SpoolProcessing
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolProcessing_Rod')
    ALTER TABLE [dbo].[SpoolProcessing]
        ADD CONSTRAINT [FK_SpoolProcessing_Rod]
        FOREIGN KEY ([ParentRodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolProcessing_FlatWireRun')
    ALTER TABLE [dbo].[SpoolProcessing]
        ADD CONSTRAINT [FK_SpoolProcessing_FlatWireRun]
        FOREIGN KEY ([SourceRunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolProcessing_SourceRod')
    ALTER TABLE [dbo].[SpoolProcessing]
        ADD CONSTRAINT [FK_SpoolProcessing_SourceRod]
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

-- A staged rod that failed inspection is released by its WIP rejection (Q23 item 3,
-- decided 30 Jul 2026). The rejection is what carries the reason and puts the rod on HOLD.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodStaging_WipRejection')
    ALTER TABLE [dbo].[RodStaging]
        ADD CONSTRAINT [FK_RodStaging_WipRejection]
        FOREIGN KEY ([WipRejectionId]) REFERENCES [dbo].[WipRejection] ([Id]);
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

-- ------------------------------------------------------------
-- SpoolCheckin
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolCheckin_FlatWireRun')
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [FK_SpoolCheckin_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolCheckin_SpoolProcessing')
    ALTER TABLE [dbo].[SpoolCheckin]
        ADD CONSTRAINT [FK_SpoolCheckin_SpoolProcessing]
        FOREIGN KEY ([SpoolAlpha]) REFERENCES [dbo].[SpoolProcessing] ([Alpha]);
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
-- RunReading
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RunReading_FlatWireRun')
    ALTER TABLE [dbo].[RunReading]
        ADD CONSTRAINT [FK_RunReading_FlatWireRun]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
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


-- ------------------------------------------------------------
-- CoilOutput
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilOutput_FlatWireRun')
    ALTER TABLE [dbo].[CoilOutput]
        ADD CONSTRAINT [FK_CoilOutput_FlatWireRun]
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

-- SpoolAlpha is nullable, so this FK constrains only the rows that name a
-- spool -- a rod-fed run leaves it NULL and the FK is not evaluated.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_CoilTraceability_SpoolProcessing')
    ALTER TABLE [dbo].[CoilTraceability]
        ADD CONSTRAINT [FK_CoilTraceability_SpoolProcessing]
        FOREIGN KEY ([SpoolAlpha]) REFERENCES [dbo].[SpoolProcessing] ([Alpha]);
GO

-- ------------------------------------------------------------
-- SpoolProcessing genealogy, order set, carrier and the FL2 queue
-- (added 22 Aug 2026)
--
-- SpoolOrder.OrderNo carries NO foreign key by design: orders live in
-- the shared schema, D-32 forbids altering it, so it is an unenforced
-- external reference on the same basis D-31 sets for PlanId /
-- CoilOrderPlanId / SkidId.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolTraceability_SpoolProcessing')
    ALTER TABLE [dbo].[SpoolTraceability]
        ADD CONSTRAINT [FK_SpoolTraceability_SpoolProcessing]
        FOREIGN KEY ([SpoolAlpha]) REFERENCES [dbo].[SpoolProcessing] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolTraceability_Rod')
    ALTER TABLE [dbo].[SpoolTraceability]
        ADD CONSTRAINT [FK_SpoolTraceability_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

-- NULL on the first segment of every spool -- there is no weld before
-- the first rod -- so the FK is simply not evaluated for those rows.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolTraceability_WeldEvent')
    ALTER TABLE [dbo].[SpoolTraceability]
        ADD CONSTRAINT [FK_SpoolTraceability_WeldEvent]
        FOREIGN KEY ([WeldEventId]) REFERENCES [dbo].[WeldEvent] ([WeldEventId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolOrder_SpoolProcessing')
    ALTER TABLE [dbo].[SpoolOrder]
        ADD CONSTRAINT [FK_SpoolOrder_SpoolProcessing]
        FOREIGN KEY ([SpoolAlpha]) REFERENCES [dbo].[SpoolProcessing] ([Alpha]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolStaging_SpoolProcessing')
    ALTER TABLE [dbo].[SpoolStaging]
        ADD CONSTRAINT [FK_SpoolStaging_SpoolProcessing]
        FOREIGN KEY ([SpoolAlpha]) REFERENCES [dbo].[SpoolProcessing] ([Alpha]);
GO

-- SpoolProcessing.SpoolId is added by a guarded ALTER in 03_Materials, so
-- confirm the column exists before constraining it.
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'[dbo].[SpoolProcessing]') AND name = N'SpoolId')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SpoolProcessing_Spool')
    ALTER TABLE [dbo].[SpoolProcessing]
        ADD CONSTRAINT [FK_SpoolProcessing_Spool]
        FOREIGN KEY ([SpoolId]) REFERENCES [dbo].[Spool] ([Id]);
GO

------------------------------------------------------------
-- ROD <-> ORDER  (added 22 Aug 2026)
------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderAllocation]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderAllocation_Rod')
    ALTER TABLE [dbo].[RodOrderAllocation]
        ADD CONSTRAINT [FK_RodOrderAllocation_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderAllocation]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderAllocation_Superseded')
    ALTER TABLE [dbo].[RodOrderAllocation]
        ADD CONSTRAINT [FK_RodOrderAllocation_Superseded]
        FOREIGN KEY ([SupersededByAllocationId]) REFERENCES [dbo].[RodOrderAllocation] ([Id]);
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderConsumption_Run')
    ALTER TABLE [dbo].[RodOrderConsumption]
        ADD CONSTRAINT [FK_RodOrderConsumption_Run]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderConsumption_Checkin')
    ALTER TABLE [dbo].[RodOrderConsumption]
        ADD CONSTRAINT [FK_RodOrderConsumption_Checkin]
        FOREIGN KEY ([RodCheckinId]) REFERENCES [dbo].[RodCheckin] ([Id]);
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderConsumption_Rod')
    ALTER TABLE [dbo].[RodOrderConsumption]
        ADD CONSTRAINT [FK_RodOrderConsumption_Rod]
        FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderConsumption_Allocation')
    ALTER TABLE [dbo].[RodOrderConsumption]
        ADD CONSTRAINT [FK_RodOrderConsumption_Allocation]
        FOREIGN KEY ([AllocationId]) REFERENCES [dbo].[RodOrderAllocation] ([Id]);
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RodOrderConsumption_Checkout')
    ALTER TABLE [dbo].[RodOrderConsumption]
        ADD CONSTRAINT [FK_RodOrderConsumption_Checkout]
        FOREIGN KEY ([RodCheckoutId]) REFERENCES [dbo].[RodCheckout] ([CheckoutId]);
GO


-- ============================================================
-- SECTION: Foreign keys touching the schedule tables
-- ============================================================
-- Ten of this file's foreign keys. Split out as 06b on 11 Aug 2026 by
-- MVP scope, returned to MVP-1 on 15 Aug 2026 (D-31), and folded back
-- in here because the division that justified a separate file no
-- longer exists.
--
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

-- FK_PSC_Drawer was REMOVED on Sep-2-2026 with the die split. It constrained
-- PassScheduleComponent.DrawerId, which is dropped: it pointed at what was then a
-- 13-row die-SIZE catalogue, and the size is already in ParameterValue. Drawer now
-- holds the two draw BOXES, which ComponentName already names. See 02_Schedule
-- section 3 and the "Tool reference" block.

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

-- ------------------------------------------------------------
-- The die domain (Sep-2-2026 die split)
--
-- DieChangeEvent's two FKs are what make FR-255 implementable -- per-tool
-- footage attribution. Both are NULLABLE by design: a die change logged
-- before its tool was registered has nothing to point at, and refusing the
-- event would lose the run record.
--
-- DieHistory.RunId is NULLABLE because Reset and Retire are die-room actions
-- with no run (FR-248, FR-250). CK_DieHistory_RunFootageHasRun in 04_Runs is
-- what stops a RunFootage row exploiting that nullability.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieChangeEvent_OldDie')
    ALTER TABLE [dbo].[DieChangeEvent]
        ADD CONSTRAINT [FK_DieChangeEvent_OldDie]
        FOREIGN KEY ([OldDieId]) REFERENCES [dbo].[ToolingInventoryDie] ([Id]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieChangeEvent_NewDie')
    ALTER TABLE [dbo].[DieChangeEvent]
        ADD CONSTRAINT [FK_DieChangeEvent_NewDie]
        FOREIGN KEY ([NewDieId]) REFERENCES [dbo].[ToolingInventoryDie] ([Id]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieHistory_Die')
    ALTER TABLE [dbo].[DieHistory]
        ADD CONSTRAINT [FK_DieHistory_Die]
        FOREIGN KEY ([DieId]) REFERENCES [dbo].[ToolingInventoryDie] ([Id]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DieHistory_Run')
    ALTER TABLE [dbo].[DieHistory]
        ADD CONSTRAINT [FK_DieHistory_Run]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO


-- ------------------------------------------------------------
-- Reason-code vocabularies (added 2 Sep 2026)
--
-- Until now the pause and rejection vocabularies were enforced NOWHERE in the
-- database -- RunPauseEvent.ReasonCode and WipRejection.RejectionReason were
-- bare VARCHARs with no CHECK, and the only statement of the allowed values
-- lived in a mockup and two markdown documents. The client's 1 Sep 2026
-- "Reason Codes.xlsx" supplies real lists, so they become referential.
--
-- TWO OF THE THREE ARE COMPOSITE ON PURPOSE. Both event tables denormalise a
-- second column beside the code -- the bucket on RunPauseEvent, the group on
-- WipRejection -- and a single-column FK would leave those copies free to
-- disagree with the lookup. The composite targets (UQ_DowntimeReason_CodeBucket,
-- UQ_WipRejectionReason_CodeGroup) exist for exactly this.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RunPauseEvent_DelayCode')
    ALTER TABLE [dbo].[RunPauseEvent]
        ADD CONSTRAINT [FK_RunPauseEvent_DelayCode]
        FOREIGN KEY ([ReasonCode], [ReasonCategory])
        REFERENCES [dbo].[DowntimeReason] ([DelayCode], [DelayBucket]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_LineDowntimeEvent_DelayCode')
    ALTER TABLE [dbo].[LineDowntimeEvent]
        ADD CONSTRAINT [FK_LineDowntimeEvent_DelayCode]
        FOREIGN KEY ([DelayCode]) REFERENCES [dbo].[DowntimeReason] ([DelayCode]);
GO

-- Nullable: a line goes down whether or not a run was open. That nullability
-- is the whole reason LineDowntimeEvent exists rather than the Downtime bucket
-- being folded into RunPauseEvent -- see the table header in 04_Runs.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_LineDowntimeEvent_Run')
    ALTER TABLE [dbo].[LineDowntimeEvent]
        ADD CONSTRAINT [FK_LineDowntimeEvent_Run]
        FOREIGN KEY ([RunId]) REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_WipRejection_Reason')
    ALTER TABLE [dbo].[WipRejection]
        ADD CONSTRAINT [FK_WipRejection_Reason]
        FOREIGN KEY ([RejectionReason], [RejectionGroup])
        REFERENCES [dbo].[WipRejectionReason] ([ReasonCode], [RejectionGroup]);
GO
