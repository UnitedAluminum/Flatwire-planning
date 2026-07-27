-- ============================================================
-- Flat Wire Mill — Master Deployment Runner
-- ============================================================
-- Executes the full schema build in the correct order:
--   00 → 08 (DDL) then the two seed scripts (Lookup before Schedule).
--
-- REQUIRES SQLCMD MODE (the `:r` include and `:on error exit`
-- directives are SQLCMD-only):
--   * CLI:  sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql
--   * SSMS: Query menu → "SQLCMD Mode", then Execute
--
-- Run this file FROM the SQL folder (the `:r` paths are relative
-- to the invocation directory), e.g.:
--   cd "C:\UAL\Flat Wire\DevelopmentPlan\Schema\SQL"
--   sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql
--
-- Idempotent: every included script guards its objects, so this
-- runner is safe to re-run against an existing FlatWireDB.
-- ============================================================

:on error exit

PRINT '======================================================';
PRINT ' Flat Wire schema deployment — START';
PRINT '======================================================';
GO

:r FlatWire_DDL_00_Database.sql
:r FlatWire_DDL_01_Lookup.sql
:r FlatWire_DDL_02_Schedule.sql
:r FlatWire_DDL_03_Materials.sql
:r FlatWire_DDL_04_Runs.sql
:r FlatWire_DDL_05_QualityOutput.sql
:r FlatWire_DDL_06_ForeignKeys.sql
:r FlatWire_DDL_07_Indexes.sql
:r FlatWire_DDL_08_Programmability.sql

-- Seed data — strict dependency order:
--   Lookup (IDENTITY targets) → Schedule (+ change log) → Materials
--   (Rod/Run/Spool) → Runs (checkins/events) → Quality/Output
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
