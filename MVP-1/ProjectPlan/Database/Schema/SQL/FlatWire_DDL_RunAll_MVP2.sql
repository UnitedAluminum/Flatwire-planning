-- ============================================================
-- ⚠ MVP-2 SCOPE. NOT built by FlatWire_DDL_RunAll.sql.
-- Flat Wire Mill (MVP-2) — Deferred-Scope Deployment Runner
-- ============================================================
-- This runner is now ONE OBJECT: sp_ShiftSummary.
--
-- ⚠ IT USED TO BUILD THE PASS SCHEDULE. On 15 Aug 2026 decision D-31
--   moved PassSchedule, PassScheduleComponent and PassScheduleChangeLog
--   -- with their seed, their 10 foreign keys and their 6 indexes --
--   INTO MVP-1. FlatWire_DDL_RunAll.sql builds all of that now.
--
--   If you are looking for 02_Schedule or SampleData_Schedule: they are in
--   the MVP-1 runner, in numeric order. Nothing is missing.
--
--   If you are looking for 06b or 07b: they no longer exist. On 23 Aug 2026
--   they were folded back into 06_ForeignKeys and 07_Indexes, which now hold
--   all 55 FKs and all 70 index statements. The MVP-1 chain is 00..08 and
--   this file is 09.
--
-- WHAT IS LEFT, AND WHY
--
--   sp_ShiftSummary backs DASHBOARD 10, the Supervisor Shift Summary,
--   which is an MVP-2 screen. No MVP-1 code path calls it, so MVP-1
--   deliberately does not create it -- see MVP2-SCOPE.md.
--
--   ⚠ Do not "helpfully" add it to the MVP-1 chain. phase-01b is
--     explicit: "sp_ShiftSummary is MVP-2's -- do not create, drop or
--     grant it."
--
-- PREREQUISITE: FlatWire_DDL_RunAll.sql must have been run first.
-- This chain is purely ADDITIVE.
--
-- REQUIRES SQLCMD MODE (`:r` and `:on error exit` are SQLCMD-only):
--   cd "C:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"
--   sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll_MVP2.sql
--
-- Idempotent: the included script guards its objects.
--
-- Teardown: there is no 99b. MVP-1's FlatWire_DDL_99_Teardown.sql
-- drops the whole database and is scope-agnostic.
-- ============================================================

:on error exit

PRINT '======================================================';
PRINT ' Flat Wire MVP-2 schema deployment - START';
PRINT '======================================================';
GO

:r FlatWire_DDL_09_Programmability_MVP2.sql

GO
PRINT '======================================================';
PRINT ' Flat Wire MVP-2 schema deployment - COMPLETE';
PRINT '======================================================';
GO
