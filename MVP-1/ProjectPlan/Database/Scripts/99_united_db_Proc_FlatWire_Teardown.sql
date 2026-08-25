/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 99_united_db_Proc_FlatWire_Teardown.sql
  Target DB    : united_db
  Last Updated : 2026-08-19
  Status       : Draft
  Story        : FW-220 / FW-221
  Companion to : FlatWire_DDL_99_Teardown.sql (which tears down FlatWireDB and NOTHING ELSE)

  PURPOSE
  -------
  Drops the four flat wire procedures that live in united_db.

  *** IT DOES NOT DROP sp_IngestRodFromCoils. *** That one lives in FlatWireDB, so it goes with
  the database when FlatWire_DDL_99_Teardown.sql runs. Two teardowns, split by which database
  owns the object - not an omission.

  FlatWire_DDL_99_Teardown.sql removes FlatWireDB, and until now that was the whole teardown
  story - which left the shared-schema procedures behind on every environment they had ever been
  deployed to. A developer tearing down and redeploying got a clean FlatWireDB and stale
  procedures, which is the worst of the two states because it looks clean.

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
              -> 10_CommonDB_Insert_WIPStations_FlatWire.sql
              -> 20_FlatWire_Grants.sql
              -> the four procedures

      teardown:  *** THIS SCRIPT ***          (procedures, united_db)
              -> FlatWire_DDL_99_Teardown.sql (FlatWireDB)

  Procedures first: FlatWire_CheckInRod and FlatWire_ReverseReqsum are written to run inside a
  caller transaction that also touches FlatWireDB, so leaving them present after the database
  has gone leaves callable code whose other half does not exist.

  IDEMPOTENT. Every drop is guarded; running it twice, or on an environment that never had them,
  prints and moves on.
==============================================================================================*/

USE [united_db];
GO

SET NOCOUNT ON;
GO

PRINT '=== FlatWire procedure teardown (united_db): start ===';
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

PRINT '=== FlatWire procedure teardown (united_db): done ===';
GO

/*==============================================================================================
  VERIFICATION - four rows before, zero after.

  SELECT name, type_desc, create_date, modify_date
  FROM   united_db.sys.objects
  WHERE  type = 'P' AND name LIKE 'FlatWire[_]%'
  ORDER BY name;

  Nothing else in the shared schema should carry the FlatWire_ prefix. If this returns something
  you did not expect, it was added outside this script set and needs an owner.
==============================================================================================*/
