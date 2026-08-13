-- ============================================================
-- Flat Wire Mill (MVP-2) — Deferred-Scope Deployment Runner
-- ============================================================
-- Adds the three MVP-2 tables and everything that hangs off them on
-- top of an already-deployed MVP-1 FlatWireDB:
--   PassSchedule, PassScheduleComponent, PassScheduleChangeLog
--
-- CoilOutput and CoilTraceability were returned to MVP-1 on
-- 11 Aug 2026 -- the coil genealogy they carry is what the
-- welding-wire customer certificates are produced from, which is an
-- MVP-1 obligation even though the DB7/DB7b SCREENS stay deferred.
--
-- PREREQUISITE: MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_DDL_RunAll.sql
-- must have been run first. This chain is purely ADDITIVE.
--
-- REQUIRES SQLCMD MODE (`:r` and `:on error exit` are SQLCMD-only):
--   cd "C:\UAL\Flatwire-planning\MVP-2\DBChanges\Schema\SQL"
--   sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll_MVP2.sql
--
-- ------------------------------------------------------------
-- THE ORDER BELOW IS NOT THE 02->08 NUMERIC ORDER, DELIBERATELY.
-- ------------------------------------------------------------
-- The pass-schedule SEED runs before the FOREIGN KEYS, because
-- MVP-1 seeds FlatWireRun, RodCheckin and SpoolCheckin rows whose
-- PassScheduleId values point at pass schedules created here. Add
-- the constraints first and they fail on those pre-existing rows.
--
-- Seed-then-constrain is the only order that works on a database
-- that has already been through the MVP-1 chain.
-- ------------------------------------------------------------
--
-- Idempotent: every included script guards its objects.
--
-- Teardown: there is no 99b. MVP-1's FlatWire_DDL_99_Teardown.sql
-- drops the whole database and is scope-agnostic.
-- ============================================================

:on error exit

PRINT '======================================================';
PRINT ' Flat Wire MVP-2 schema deployment - START';
PRINT '======================================================';
GO

-- 1. Tables
:r FlatWire_DDL_02_Schedule.sql

-- 2. Pass-schedule seed BEFORE constraints (see the note above)
:r FlatWire_SampleData_Schedule.sql

-- 3. Constraints -- includes the FOUR FKs that sit on MVP-1 tables
--    (FlatWireRun, RodCheckin, SpoolCheckin, CoilOutput -> PassSchedule)
:r FlatWire_DDL_06b_ForeignKeys.sql

-- 4. Indexes and programmability
:r FlatWire_DDL_07b_Indexes.sql
:r FlatWire_DDL_08b_Programmability.sql

GO
PRINT '======================================================';
PRINT ' Flat Wire MVP-2 schema deployment - COMPLETE';
PRINT '======================================================';
GO
