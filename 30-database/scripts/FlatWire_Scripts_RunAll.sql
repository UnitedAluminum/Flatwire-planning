-- ============================================================
-- Flat Wire Mill — Cross-Database Scripts Runner
-- ============================================================
-- Creates the flat wire grants and the five cross-database procedures.
--
-- ⚠⚠ THIS RUNNER DELIBERATELY SKIPS FIVE FILES:
--
--       08_CommonDB_OPCModules_ColumnDrift.sql
--       09_CommonDB_OPCTables_Constraints.sql
--       10_CommonDB_Insert_WIPStations_FlatWire.sql
--       11_CommonDB_Insert_OPCRegistration_FlatWire.sql
--       16_CommonDB_Delete_OPCRegistration_FlatWire.sql
--
--   None is an oversight and none must be added.
--
--   08 ALTERS a SHARED CommonDB table -- it adds the two columns
--   ual-database's OPCModules\CreateTable.sql declares and a stale CommonDB
--   lacks, OPCEventType and EventDurationSeconds. It writes no row and drops
--   nothing, and 11 cannot insert without them (G100). It has already been run
--   on DEV00164-001 and it is idempotent, so a re-run reports 'present' twice.
--   It is still a schema change to a table this project does not own, which is
--   exactly the kind of thing that should not be one keystroke inside a runner.
--   ⚠ It deliberately does NOT backfill: OPCModulesIdx 1-4 are left NULL, and
--   refreshing dbo.GetOPCServerAndTagDetails without backfilling them first makes
--   GetOPCInfo throw for four other modules. Read the script's header, and G100.
--
--   09 ALTERS five SHARED CommonDB tables -- it adds the primary keys,
--   unique constraints, foreign keys and indexes those tables have never
--   had, so it changes the schema of objects four other modules read
--   (hole detection, coil receiving, handheld service, furnace
--   scheduling). It writes no row. Nothing blocks it -- G100 does not touch
--   it -- and it has already been run on DEV00164-001. It should be run BY
--   HAND and EARLY, because it turns 11's hand-written idempotency
--   guards into schema guarantees. A schema change to tables this project
--   does not own is precisely the kind of thing that should not be one
--   keystroke inside a runner.
--
--   10 writes ROWS into united_db..machines, CommonDB..WIPStations and
--   CommonDB..MachineStationsConfiguration -- SHARED tables that other
--   modules read -- it is still Draft with machine_type, the station set
--   and StationType pending sign-off, and NO REVERSE SCRIPT EXISTS.
--
--   11 writes ROWS into CommonDB..OPCModules, OPCTags and the two
--   application-mapping tables -- shared in exactly the same way -- and it
--   READS CommonDB..OPCServers, which is a LOOKUP table it never inserts
--   into or updates (D-48). G97 is now ANSWERED (D-49: the endpoint pair is
--   OPCServersIdx 1 and 2, both lines onto both), so the script has no
--   placeholder left and WILL RUN -- which is exactly why it stays out of
--   this runner. It must not be activated before FW-236 / G94 merges, and
--   G100 no longer stops it -- 08 levelled dbo.OPCModules on DEV00164-001 and
--   section 4a now binds clean. It is a sign-off gate, and it claims
--   OPCModulesIdx 6 on a table whose IDENTITY nothing else reserves.
--
--   16 reverses 11 and is DEV ONLY. A reverse belongs in the chain even less
--   than a forward seed does: FW-241 makes the same call for 15.
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
--   40  FlatWire_CheckInRod         (FlatWireDB)
--   50  FlatWire_CompleteCoilOnSkid (FlatWireDB)
--   60  FlatWire_ReleaseStation     (FlatWireDB)
--   70  FlatWire_ReverseReqsum      (FlatWireDB)
--
--   ⚠ 40-70 MOVED from united_db to FlatWireDB on 26 Aug 2026 (change [H]).
--     All FIVE procedures now live in ONE database. The tables they read and
--     write did NOT move -- united_db, proddb, CommonDB, SlitterDB and
--     wiplogdb are unchanged, and so is the transaction model: one instance,
--     one local transaction manager, no MSDTC.
--
-- ⚠ THE ORDER OF 30..70 AMONG THEMSELVES IS ARBITRARY. CREATE PROCEDURE
--   uses DEFERRED NAME RESOLUTION, so these five have no compile-time
--   dependency on one another and none references another's body. The
--   numbers group them by owning database; they do not encode a chain.
--   Do not invent a dependency from the numbering.
--   ⚠ Since [H] all five share ONE owning database, so the numbering no
--     longer groups by database either. It is ordering only.
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
-- Teardown: 99_FlatWireDB_Proc_FlatWire_Teardown.sql (code), then
-- ../Schema/SQL/FlatWire_DDL_99_Teardown.sql (the database). Neither undoes
-- 10's shared rows -- by design.
-- ============================================================

:on error exit

PRINT '======================================================';
PRINT ' Flat Wire cross-database scripts - START';
PRINT '======================================================';
PRINT ' NOTE: 08_ (OPCModules column drift), 09_ (OPC constraints), 10_ (WIP';
PRINT '       stations), 11_ (OPC registration) and 16_ (its reverse) are NOT';
PRINT '       run here. 08_ and 09_ are by hand and unblocked; 10_ and 11_';
PRINT '       are by hand, after sign-off.';
PRINT '       See README.md.';
GO

:r 20_FlatWire_Grants.sql
:r 30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql
:r 40_FlatWireDB_Proc_FlatWire_CheckInRod.sql
:r 50_FlatWireDB_Proc_FlatWire_CompleteCoilOnSkid.sql
:r 60_FlatWireDB_Proc_FlatWire_ReleaseStation.sql
:r 70_FlatWireDB_Proc_FlatWire_ReverseReqsum.sql

GO
PRINT '======================================================';
PRINT ' Flat Wire cross-database scripts - COMPLETE';
PRINT '======================================================';
PRINT ' Reminder: 10 (WIP stations / machines rows) and 11 (the OPC';
PRINT '           registration) are separate, sign-off-gated manual steps.';
PRINT '           10 is NON-REVERSIBLE. 11 is reversed by 16, DEV only.';
PRINT '           11 has no placeholder left (G97 answered, D-49) and G100';
PRINT '           is cleared on DEV00164-001 - what holds it now is';
PRINT '           FW-236 / G94 alone. Run 08 and 09 by hand first.';
GO
