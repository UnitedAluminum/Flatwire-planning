-- ============================================================
-- Flat Wire Mill — Sample Data Runner  (DEV AND TRIAL ONLY)
-- ============================================================
-- Seeds the five FlatWire_SampleData_*.sql files in dependency order.
--
-- ⚠⚠  DO NOT RUN THIS AGAINST A PRODUCTION DATABASE.  ⚠⚠
--
-- WHY THIS FILE EXISTS (19 Aug 2026)
-- ----------------------------------
-- Until now these five files were included by FlatWire_DDL_RunAll.sql
-- UNCONDITIONALLY, so every schema deployment also inserted eight fake
-- rods (R00041..R00048), fake runs, check-ins, coil outputs and quality
-- records. That was harmless while FlatWireDB lived on
-- (localdb)\MSSQLLocalDB and nothing else could see it.
--
-- It stops being harmless the moment FlatWireDB is deployed to the SHARED
-- instance alongside united_db / proddb / SlitterDB / CommonDB, which is
-- what the check-in transaction model now requires ([INT 8.0], [ARC 10]).
--
-- It also actively undermines the rod-ingestion design. sp_IngestRodFromCoils
-- creates the [Rod] mirror row on the first write that names a rod, and
-- REFRESHES it if it is already there. A seeded R00041 that never came from
-- proddb..coils is therefore silently "refreshed" instead of created, and the
-- mirror carries a rod the shared schema has never heard of. See OI-42.
--
-- A conditional include was NOT used, and could not be: `:r` is a SQLCMD
-- PARSE-TIME directive, so wrapping it in `IF` includes the file regardless
-- and the IF would guard only the first statement of the first batch. A
-- separate runner is the only correct mechanism.
--
-- REQUIRES SQLCMD MODE (`:r` and `:on error exit` are SQLCMD-only):
--   cd "c:\UAL\Flatwire-planning\30-database\sql"
--   sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_RunAll.sql
--
-- Run FlatWire_DDL_RunAll.sql FIRST — this file seeds tables, it does not
-- create them.
--
-- IDEMPOTENT. Every block in all five seed files is guarded by IF NOT EXISTS, so a
-- second full run is a clean no-op. (This note warned of duplicate-key errors until
-- 8 Sep 2026 -- measured wrong, and it discouraged a safe re-run.)
--
-- ⚠ WHAT IS NOT SAFE IS A *PARTIAL* STATE, and that is the real hazard. Each block
-- guards on ITS OWN table being empty, so if sp_IngestRodFromCoils has already created
-- Rod rows, the eight fixture rods are skipped while the runs and check-ins that
-- reference them are not - and the chain dies mid-file on FK_RodCheckin_Rod with
-- :on error exit. FlatWire_SampleData_Materials.sql now THROWs 60001 up front rather
-- than letting that happen. The clean path from any partial state is
-- FlatWire_DDL_99_Teardown.sql, then the schema runner, then this.
-- ============================================================

:on error exit

PRINT '';
PRINT '======================================================';
PRINT ' Flat Wire SAMPLE DATA — DEV / TRIAL ONLY';
PRINT ' If this is a production database, STOP.';
PRINT '======================================================';
GO

USE [FlatWireDB];
GO

-- Seed data — strict dependency order:
--   Lookup (IDENTITY targets: Stand, Drawer, ToolingInventoryDie,
--           ToolingInventoryEdger, AlloyProperty)
--   → Schedule (needs those IDENTITY values)
--   → Materials (Rod/Run/SpoolProcessing -- FlatWireRun.PassScheduleId needs
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
PRINT ' Flat Wire sample data — COMPLETE (DEV / TRIAL ONLY)';
PRINT '======================================================';
GO
