-- ============================================================
-- Flat Wire Mill — Master Deployment Runner
-- ============================================================
-- Executes the full MVP-1 schema build in the correct order:
--   00 -> 08 (DDL) then the seed scripts.  Result: 28 tables.
--
-- ⚠ ONE FILE IN THIS FOLDER IS MVP-2 AND IS DELIBERATELY NOT RUN HERE:
--     FlatWire_DDL_08b_Programmability.sql  (sp_ShiftSummary)
--   It backs DASHBOARD 10, the Supervisor Shift Summary, which is an MVP-2
--   screen.  Nothing in MVP-1 calls that procedure, so building it here
--   would import an object no MVP-1 code path uses.  To add it, run
--   FlatWire_DDL_RunAll_MVP2.sql AFTER this file.  See MVP2-SCOPE.md.
--
-- REQUIRES SQLCMD MODE (the `:r` include and `:on error exit`
-- directives are SQLCMD-only):
--   * CLI:  sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql
--   * SSMS: Query menu -> "SQLCMD Mode", then Execute
--
-- Run this file FROM the SQL folder (the `:r` paths are relative
-- to the invocation directory), e.g.:
--   cd "C:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"
--   sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql
--
-- Idempotent: every included script guards its objects, so this
-- runner is safe to re-run against an existing FlatWireDB.
--
-- ============================================================
-- !!  READ THIS BEFORE DEPLOYING  !!
-- ============================================================
-- THE PASS SCHEDULE TABLES ARE BUILT HERE (decision D-31,
-- 15 Aug 2026). This runner builds ALL 28 tables and THAT IS THE
-- COMPLETE MVP-1 DATABASE. There is no second runner to chase.
--
-- ⚠ THIS REVERSES THE 11 AUG 2026 SPLIT, DELIBERATELY. If you are
--   reading an older document that says "25 tables", "the three
--   PassSchedule* tables are owned outside MVP-1", or "02_Schedule
--   is deliberately absent" -- that text is STALE, not a rule you
--   are violating. See MVP2-SCOPE.md and CHANGELOG.md.
--
-- WHY THEY MOVED
--
--   APIs.md 4.2 always carried an OPEN ASSUMPTION with two options:
--     (a) MVP-1 calls the owning track's API and snapshots locally, or
--     (b) the owning track WRITES INTO FlatWireDB and the read is a
--         local query.
--   D-31 chooses (b). This is arbitration between two published
--   options, not new scope.
--
-- WHAT IS *NOT* IN MVP-1, AND HAS NOT CHANGED
--
--   AUTHORING. MVP-1 never creates, edits, approves or lists a pass
--   schedule. Dashboards 9 and 9A stay MVP-2, and the API exposes NO
--   pass-schedule endpoint. MVP-1 is a READER of these tables.
--   Something outside MVP-1 must populate them in production -- the
--   seed below covers development and the trial only.
--
-- WHAT THIS MEANS FOR PassScheduleId  -- CHANGED
--
--   FlatWireRun, RodCheckin, SpoolCheckin and CoilOutput each carry
--   a PassScheduleId column, and as of D-31 each has a REAL, ENFORCED
--   foreign key into PassSchedule (added by 06b below).
--
--   ⚠ It was previously a DOCUMENTED EXTERNAL REFERENCE with no local
--     parent. That is no longer true and the change is intentional.
--     PlanId, CoilOrderPlanId and CoilOutput.SkidId are UNAFFECTED and
--     remain external references with no local parents.
--
--   See phase-01c-database-foundation.md, "Cross-DB logical FKs".
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

-- DDL — numeric order throughout. Every table is created before any
-- constraint, and every constraint before any row, so the FK chain is
-- applied to EMPTY tables and cannot fail on pre-existing data.
:r FlatWire_DDL_00_Database.sql
:r FlatWire_DDL_01_Lookup.sql
:r FlatWire_DDL_02_Schedule.sql
:r FlatWire_DDL_03_Materials.sql
:r FlatWire_DDL_04_Runs.sql
:r FlatWire_DDL_05_QualityOutput.sql
:r FlatWire_DDL_06_ForeignKeys.sql
:r FlatWire_DDL_06b_ForeignKeys.sql
:r FlatWire_DDL_07_Indexes.sql
:r FlatWire_DDL_07b_Indexes.sql
:r FlatWire_DDL_08_Programmability.sql

-- Seed data — strict dependency order:
--   Lookup (IDENTITY targets: Stand, Drawer, Edger, AlloyProperty)
--   → Schedule (needs those IDENTITY values)
--   → Materials (Rod/Run/Spool -- FlatWireRun.PassScheduleId needs
--     its parent schedule to exist, now that the FK is enforced)
--   → Runs (checkins/events) → Quality/Output
--
-- ⚠ THE SCHEDULE SEED MUST PRECEDE MATERIALS. Materials seeds
--   FlatWireRun rows carrying PassScheduleId values ('PS-1100-FL1-001'
--   and friends) whose parents are created by the Schedule seed. Under
--   D-31 that link is a REAL FK, so reversing these two lines fails the
--   deployment rather than leaving a harmless dangling reference as it
--   did before.
:r FlatWire_SampleData_Lookup.sql
:r FlatWire_SampleData_Schedule.sql
:r FlatWire_SampleData_Materials.sql
:r FlatWire_SampleData_Runs.sql
:r FlatWire_SampleData_QualityOutput.sql

GO
PRINT '======================================================';
PRINT ' Flat Wire schema deployment — COMPLETE';
PRINT '======================================================';
GO
