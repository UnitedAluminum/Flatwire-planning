/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 99_FlatWireDB_Proc_FlatWire_Teardown.sql
  Target DB    : FlatWireDB   (the four procedures MOVED here from united_db
                               on 26 Aug 2026, change [H]; this teardown moved with them)
  Last Updated : 2026-08-26
  Status       : Draft
  Story        : FW-220 / FW-221
  Companion to : FlatWire_DDL_99_Teardown.sql (which tears down FlatWireDB and NOTHING ELSE)

  PURPOSE
  -------
  Drops the four flat wire procedures, and since 8 Sep 2026 the FlatWireDB.dbo.WIPStations VIEW
  as well (35_, FW-N16). They lived in united_db until 26 Aug 2026; change [H] moved them into
  FlatWireDB.

  *** READ THIS BEFORE ASSUMING THE FILE IS NOW REDUNDANT. ***

  [H] INVERTED THIS SCRIPT'S ORIGINAL REASON FOR EXISTING, and the old text is worth stating so
  the change is legible. It used to read:

      "IT DOES NOT DROP sp_IngestRodFromCoils. That one lives in FlatWireDB, so it goes with
       the database when FlatWire_DDL_99_Teardown.sql runs. Two teardowns, split by which
       database owns the object - not an omission. [...] until now FlatWire_DDL_99_Teardown.sql
       was the whole teardown story - which left the shared-schema procedures behind on every
       environment they had ever been deployed to. A developer tearing down and redeploying got
       a clean FlatWireDB and stale procedures, which is the worst of the two states because it
       looks clean."

  ALL FIVE PROCEDURES NOW LIVE IN FlatWireDB. So:

    - the "split by owning database" is gone - there is one owning database;
    - the stale-procedure hazard is gone - DROP DATABASE takes all five with it;
    - in the FULL teardown path this script is therefore a NO-OP by the time
      FlatWire_DDL_99_Teardown.sql has run, and running it first is merely tidy.

  *** IT IS STILL REQUIRED, for the one path that is not a full teardown. ***

  Reverting change [H] itself, or backing out a bad procedure deploy, means dropping the four
  procedures WITHOUT dropping FlatWireDB - which holds the run data and must survive. There is
  no other way to do that, and the [H] abort path depends on this file existing.

  *** THIS DROPS CODE, NOT DATA. ***

  It does NOT undo anything the procedures wrote. Rows in routings, wip_coil_orders,
  WIPStations, coils, wip_log, coil_gen_history, coil_cost, coil_slit_cuts, wip_skids and
  wip_skid_coils are left exactly as they are, deliberately:

    - they are in the SHARED schema, which other modules read and which this project does not own;
    - undoing a check-in is FlatWire_ReverseReqsum's job, and it is a business operation with an
      open sign-off (Q40), not a teardown step;
    - undoing a coil completion has no procedure at all and should not acquire one by accident.

  If you need the shared rows gone from a DEV environment, remove them deliberately and by hand,
  with the genealogy and cost rows first. Do not add it here.

  DEPLOY / TEARDOWN ORDER
  -----------------------
      deploy:    FlatWire_DDL_RunAll.sql
              -> the machines / WIP-station seed (FW-241; the old script
                 10_CommonDB_Insert_WIPStations_FlatWire.sql was withdrawn
                 6 Sep 2026 and must be re-authored before this step runs)
              -> 20_FlatWire_Grants.sql
              -> the four procedures

      teardown:  *** THIS SCRIPT ***          (procedures, FlatWireDB)
              -> FlatWire_DDL_99_Teardown.sql (FlatWireDB)

  Procedures first: FlatWire_CheckInRod and FlatWire_ReverseReqsum are written to run inside a
  caller transaction that also touches FlatWireDB, so leaving them present after the database
  has gone leaves callable code whose other half does not exist.

  IDEMPOTENT. Every drop is guarded; running it twice, or on an environment that never had them,
  prints and moves on.
==============================================================================================*/

USE [FlatWireDB];
GO

SET NOCOUNT ON;
GO

PRINT '=== FlatWire procedure teardown (FlatWireDB): start ===';
GO

/*----------------------------------------------------------------------------------------------
  Dropped in reverse dependency order. FlatWire_ReverseReqsum calls FlatWire_ReleaseStation, so
  the caller goes first - SQL Server does not enforce this for procedures, but a half-torn-down
  set that still resolves is harder to reason about than one that fails cleanly.
----------------------------------------------------------------------------------------------*/

IF OBJECT_ID(N'[dbo].[FlatWire_ReverseReqsum]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[FlatWire_ReverseReqsum];
    PRINT 'Dropped: FlatWire_ReverseReqsum';
END
ELSE
    PRINT 'Not present: FlatWire_ReverseReqsum';
GO

IF OBJECT_ID(N'[dbo].[FlatWire_ReleaseStation]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[FlatWire_ReleaseStation];
    PRINT 'Dropped: FlatWire_ReleaseStation';
END
ELSE
    PRINT 'Not present: FlatWire_ReleaseStation';
GO

IF OBJECT_ID(N'[dbo].[FlatWire_CheckInRod]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[FlatWire_CheckInRod];
    PRINT 'Dropped: FlatWire_CheckInRod';
END
ELSE
    PRINT 'Not present: FlatWire_CheckInRod';
GO

IF OBJECT_ID(N'[dbo].[FlatWire_CompleteCoilOnSkid]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[FlatWire_CompleteCoilOnSkid];
    PRINT 'Dropped: FlatWire_CompleteCoilOnSkid';
END
ELSE
    PRINT 'Not present: FlatWire_CompleteCoilOnSkid';
GO

-- ⚠ THE FIFTH PROCEDURE. sp_IngestRodFromCoils does not carry the FlatWire_ prefix, which is
-- how it was missed here: change [H] moved ALL FIVE into FlatWireDB, and this script's whole
-- purpose is dropping the code WITHOUT dropping the database. Leaving it behind produced the
-- state the header calls the worst of the two -- a clean FlatWireDB with one stale procedure,
-- which looks clean. It is last because nothing here calls it.
IF OBJECT_ID(N'[dbo].[sp_IngestRodFromCoils]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[sp_IngestRodFromCoils];
    PRINT 'Dropped: sp_IngestRodFromCoils';
END
ELSE
    PRINT 'Not present: sp_IngestRodFromCoils';
GO

/*----------------------------------------------------------------------------------------------
  The view goes with them, and it is NOT a procedure.

  35_FlatWireDB_View_WIPStations.sql creates FlatWireDB.dbo.WIPStations over CommonDB's table. It
  is dropped here for the same reason the four procedures are: the one path that is not a full
  teardown - backing out a bad cross-database deploy while FlatWireDB itself must survive - has no
  other way to remove it.

  *** DROPPING IT REMOVES A READ AND NOTHING ELSE. *** The shared CommonDB..WIPStations table is
  untouched by this, exactly as D-32 requires. A view is a name over someone else's row.
----------------------------------------------------------------------------------------------*/

IF OBJECT_ID(N'[dbo].[WIPStations]', N'V') IS NOT NULL
BEGIN
    DROP VIEW [dbo].[WIPStations];
    PRINT 'Dropped: WIPStations (view - the shared CommonDB table is untouched)';
END
ELSE
    PRINT 'Not present: WIPStations (view)';
GO

PRINT '=== FlatWire procedure teardown (FlatWireDB): done ===';
GO

/*==============================================================================================
  VERIFICATION - five rows before, zero after.

  ⚠ This query read united_db.sys.objects until 8 Sep 2026, and filtered on the FlatWire_
  prefix alone. Both were wrong after change [H] moved the procedures into FlatWireDB: it
  returned zero rows on a CORRECTLY deployed instance, and non-zero only where a pre-[H]
  deploy had never been cleaned up - the exact inverse of the check it claims to be. The
  prefix filter also hid sp_IngestRodFromCoils, which is the fifth procedure.

  SELECT name, type_desc, create_date, modify_date
  FROM   FlatWireDB.sys.objects
  WHERE  type = 'P'
    AND (name LIKE 'FlatWire[_]%' OR name = 'sp_IngestRodFromCoils')
  ORDER BY name;

  Nothing else in the shared schema should carry the FlatWire_ prefix. If this returns something
  you did not expect, it was added outside this script set and needs an owner.
==============================================================================================*/
