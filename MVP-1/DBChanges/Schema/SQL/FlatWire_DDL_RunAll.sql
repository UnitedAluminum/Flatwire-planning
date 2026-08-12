-- ============================================================
-- Flat Wire Mill — Master Deployment Runner
-- ============================================================
-- Executes the full schema build in the correct order:
--   00 -> 08 (DDL, MINUS 02_Schedule) then the seed scripts.
--
-- REQUIRES SQLCMD MODE (the `:r` include and `:on error exit`
-- directives are SQLCMD-only):
--   * CLI:  sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql
--   * SSMS: Query menu -> "SQLCMD Mode", then Execute
--
-- Run this file FROM the SQL folder (the `:r` paths are relative
-- to the invocation directory), e.g.:
--   cd "C:\UAL\Flatwire-planning\MVP-1\DBChanges\Schema\SQL"
--   sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql
--
-- Idempotent: every included script guards its objects, so this
-- runner is safe to re-run against an existing FlatWireDB.
--
-- ============================================================
-- !!  READ THIS BEFORE DEPLOYING  !!
-- ============================================================
-- On 11 Aug 2026 the schema was DIVIDED BY MVP SCOPE. This runner
-- builds 25 of the 28 tables, and THAT IS THE COMPLETE MVP-1
-- DATABASE. There is no second runner to chase.
--
-- Three tables are NOT built here:
--   PassSchedule, PassScheduleComponent, PassScheduleChangeLog
--
-- They are absent because PASS SCHEDULE GENERATION AND MANAGEMENT
-- ARE OWNED OUTSIDE MVP-1 -- by a separate track, not deferred to
-- a later MVP-1 sprint. MVP-1 never creates or edits a schedule.
--
-- WHAT THIS MEANS FOR PassScheduleId
--
--   FlatWireRun, RodCheckin, SpoolCheckin and CoilOutput each carry
--   a PassScheduleId column with NO local foreign key. This is BY
--   DESIGN, not an omission: it is a DOCUMENTED EXTERNAL REFERENCE,
--   the same class as PlanId, CoilOrderPlanId and CoilOutput.SkidId,
--   which have never had local parents either.
--
--   The seeded values ('PS-1100-FL1-001' and friends) are external
--   identifiers, NOT dangling orphans. Do not "fix" them, and do not
--   add a FK to a table this scope does not own.
--
--   See phase-01c-database-foundation.md, "Cross-DB logical FKs".
--
-- WHAT MVP-1 STILL DOES WITH A PASS SCHEDULE
--
--   Rod check-in READS one to build the PLC tag push payload --
--   component states, die sizes, roll gaps, edge type, speed and the
--   gauge/width targets. That read boundary is specified in phase-04
--   and PLCTagSpecification.md; it needs no table here.
--
-- (CoilOutput and CoilTraceability are MVP-1, and so is everything
--  that writes them -- Phase 9 returned whole on 11 Aug 2026.)
--
-- Teardown is shared and scope-agnostic: FlatWire_DDL_99_Teardown.sql
-- in this folder drops the whole database.
-- ============================================================

:on error exit

PRINT '======================================================';
PRINT ' Flat Wire schema deployment — START';
PRINT '======================================================';
GO

:r FlatWire_DDL_00_Database.sql
:r FlatWire_DDL_01_Lookup.sql
:r FlatWire_DDL_03_Materials.sql
:r FlatWire_DDL_04_Runs.sql
:r FlatWire_DDL_05_QualityOutput.sql
:r FlatWire_DDL_06_ForeignKeys.sql
:r FlatWire_DDL_07_Indexes.sql
:r FlatWire_DDL_08_Programmability.sql

-- Seed data — strict dependency order:
--   Lookup (IDENTITY targets) → Materials (Rod/Run/Spool)
--   → Runs (checkins/events) → Quality/Output
--
-- There is no Schedule seed: the pass schedule is owned outside
-- MVP-1 (see the header note above), so PassScheduleId values
-- seeded below are external references, not local FKs.
:r FlatWire_SampleData_Lookup.sql
:r FlatWire_SampleData_Materials.sql
:r FlatWire_SampleData_Runs.sql
:r FlatWire_SampleData_QualityOutput.sql

GO
PRINT '======================================================';
PRINT ' Flat Wire schema deployment — COMPLETE';
PRINT '======================================================';
GO
