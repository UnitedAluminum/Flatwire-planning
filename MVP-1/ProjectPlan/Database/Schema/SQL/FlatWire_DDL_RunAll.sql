-- ============================================================
-- Flat Wire Mill — Master Deployment Runner
-- ============================================================
-- Executes the full MVP-1 schema build in the correct order:
--   00 -> 08 (DDL).  Result: 33 tables, EMPTY.
--   The defining site for the object counts is [DBD 6.2]. This banner is
--   one of exactly three places permitted to restate them.
--
-- ⚠ SAMPLE DATA IS NO LONGER SEEDED BY THIS FILE (19 Aug 2026).
--   It moved to FlatWire_SampleData_RunAll.sql so that schema and test
--   data deploy independently -- see the note where it used to be.
--
-- ⚠ 06b AND 07b NO LONGER EXIST (23 Aug 2026). They were folded back into
--   06_ForeignKeys and 07_Indexes, which now carry all 55 FKs and all 69
--   index statements respectively. The MVP-1 chain is a contiguous 00..08.
--
-- ⚠ ONE FILE IN THIS FOLDER IS MVP-2 AND IS DELIBERATELY NOT RUN HERE:
--     FlatWire_DDL_09_Programmability_MVP2.sql  (sp_ShiftSummary)
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
--   sqlcmd -S "DEVUAL-UADEV001\TEST1" -E -C -i FlatWire_DDL_RunAll.sql
--
-- ⚠ THE TARGET IS THE SHARED INSTANCE, NOT LOCALDB. FlatWireDB must sit
--   alongside united_db / proddb / SlitterDB / CommonDB / wiplogdb: the
--   check-in transaction model spans FlatWireDB and the shared schema in
--   ONE SqlTransaction under the LOCAL transaction manager, with no MSDTC
--   ([INT 8.0], [ARC 10]). LocalDB has no united_db, so a build validated
--   only there silently loses that atomicity. Prove co-location with the
--   query in ../../Scripts/20_FlatWire_Grants.sql before relying on it.
--   For a throwaway developer copy only:
--   sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql
--
-- Idempotent: every included script guards its objects, so this
-- runner is safe to re-run against an existing FlatWireDB.
--
-- ============================================================
-- !!  READ THIS BEFORE DEPLOYING  !!
-- ============================================================
-- THE PASS SCHEDULE TABLES ARE BUILT HERE (decision D-31,
-- 15 Aug 2026). This runner builds ALL 33 tables and THAT IS THE
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
--   foreign key into PassSchedule (added by 06's schedule section --
--   the file formerly called 06b, folded in on 23 Aug 2026).
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
:r FlatWire_DDL_07_Indexes.sql
:r FlatWire_DDL_08_Programmability.sql

-- ============================================================
-- SAMPLE DATA IS NOT SEEDED HERE  (changed 19 Aug 2026)
-- ============================================================
-- The five FlatWire_SampleData_*.sql files USED to be included at this
-- point, unconditionally, so every schema deployment also inserted eight
-- fake rods (R00041..R00048) plus fake runs, check-ins, coil outputs and
-- quality records.
--
-- That was harmless while FlatWireDB lived on (localdb)\MSSQLLocalDB.
-- It stops being harmless the moment this runner is pointed at the SHARED
-- instance, which the check-in transaction model now requires
-- ([INT 8.0], [ARC 10]) -- and pointing it there is the next thing this
-- project does.
--
-- It also undermines the rod-ingestion design: sp_IngestRodFromCoils
-- creates the [Rod] mirror on the first write naming a rod and REFRESHES
-- it if present, so a seeded R00041 that never came from proddb..coils is
-- silently refreshed rather than created (OI-42).
--
-- A conditional include was not possible: `:r` is a SQLCMD PARSE-TIME
-- directive, so an `IF` around it includes the file anyway and guards only
-- the first statement of the first batch. Hence a separate runner:
--
--     sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_RunAll.sql
--
-- Run it for DEV and the trial. Never against production.
-- ============================================================

GO
PRINT '======================================================';
PRINT ' Flat Wire schema deployment — COMPLETE';
PRINT '======================================================';
GO
