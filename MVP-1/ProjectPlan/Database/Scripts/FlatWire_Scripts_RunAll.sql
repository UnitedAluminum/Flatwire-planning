-- ============================================================
-- Flat Wire Mill — Cross-Database Scripts Runner
-- ============================================================
-- Creates the flat wire grants and the five cross-database procedures.
--
-- ⚠⚠ THIS RUNNER DELIBERATELY SKIPS ONE FILE:
--
--       10_CommonDB_Insert_WIPStations_FlatWire.sql
--
--   It is NOT an oversight and it must NOT be added. That script writes
--   ROWS into united_db..machines, CommonDB..WIPStations and
--   CommonDB..MachineStationsConfiguration -- SHARED tables that other
--   modules read -- it is still Draft with machine_type, the station set
--   and StationType pending sign-off, and NO REVERSE SCRIPT EXISTS.
--
--   Automating an irreversible write into databases this project does not
--   own is the accident this runner is shaped to prevent. It is the same
--   reasoning that removed the sample data from FlatWire_DDL_RunAll.sql on
--   19 Aug 2026: a runner should not make a hard-to-undo action a single
--   keystroke. Run it BY HAND, after sign-off. See README.md.
--
-- WHAT THIS RUNNER DOES CONTAIN
--
--   20  grants                (idempotent; run once per environment)
--   30  sp_IngestRodFromCoils (FlatWireDB)
--   40  FlatWire_CheckInRod         (united_db)
--   50  FlatWire_CompleteCoilOnSkid (united_db)
--   60  FlatWire_ReleaseStation     (united_db)
--   70  FlatWire_ReverseReqsum      (united_db)
--
-- ⚠ THE ORDER OF 30..70 AMONG THEMSELVES IS ARBITRARY. CREATE PROCEDURE
--   uses DEFERRED NAME RESOLUTION, so these five have no compile-time
--   dependency on one another and none references another's body. The
--   numbers group them by owning database; they do not encode a chain.
--   Do not invent a dependency from the numbering.
--
-- ⚠ TWO OF THESE CARRY OPEN SIGN-OFF ITEMS AND ONE IS DESTRUCTIVE:
--     40  Q37-Q39  transaction_name, coil_skid_status, the coils rod stamp
--     50  Q34-Q36  transaction_name, coil_status, smp_no, coil_slit_cuts
--     70  Q40      the proddb..wip_coil_orders DELETE -- NOT signed off for
--                  a shared environment. @deleteOrphan defaults to 1.
--   Creating a procedure does not execute it, so building them here is safe;
--   CALLING 70 on a shared environment before Q40 closes is not.
--
-- PREREQUISITES
--   1. FlatWireDB exists -- ../Schema/SQL/FlatWire_DDL_RunAll.sql has run.
--   2. Co-location proved. FlatWireDB must sit on the SAME instance as
--      united_db / proddb / SlitterDB / CommonDB / wiplogdb: the check-in
--      transaction model spans them in ONE SqlTransaction under the LOCAL
--      transaction manager, with no MSDTC ([INT 8.0], [ARC 10]). The
--      verification query is in 20_FlatWire_Grants.sql -- run it FIRST.
--   3. 10_CommonDB_Insert_WIPStations_FlatWire.sql has been run by hand,
--      after sign-off. FlatWire_CheckInRod claims a WIP station, so it has
--      nothing to claim until those rows exist.
--
-- REQUIRES SQLCMD MODE (`:r` and `:on error exit` are SQLCMD-only):
--   cd "c:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Scripts"
--   sqlcmd -S "<server>" -E -C -i FlatWire_Scripts_RunAll.sql
--
-- Run it FROM this folder -- the `:r` paths are relative to the invocation
-- directory. Idempotent: 20 is guarded and 30-70 are all CREATE OR ALTER.
--
-- The full cross-folder deploy sequence has ONE home: [DEP 4.2].
-- Teardown: 99_united_db_Proc_FlatWire_Teardown.sql (code), then
-- ../Schema/SQL/FlatWire_DDL_99_Teardown.sql (the database). Neither undoes
-- 10's shared rows -- by design.
-- ============================================================

:on error exit

PRINT '======================================================';
PRINT ' Flat Wire cross-database scripts - START';
PRINT '======================================================';
PRINT ' NOTE: 10_CommonDB_Insert_WIPStations_FlatWire.sql is NOT run here.';
PRINT '       Run it by hand, after sign-off. See README.md.';
GO

:r 20_FlatWire_Grants.sql
:r 30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql
:r 40_united_db_Proc_FlatWire_CheckInRod.sql
:r 50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql
:r 60_united_db_Proc_FlatWire_ReleaseStation.sql
:r 70_united_db_Proc_FlatWire_ReverseReqsum.sql

GO
PRINT '======================================================';
PRINT ' Flat Wire cross-database scripts - COMPLETE';
PRINT '======================================================';
PRINT ' Reminder: 10 (WIP stations / machines rows) is a separate,';
PRINT '           sign-off-gated, NON-REVERSIBLE manual step.';
GO
