/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 35_FlatWireDB_View_WIPStations.sql
  Object       : FlatWireDB.dbo.WIPStations  (VIEW)
  Target DBs   : FlatWireDB (view home)
                 CommonDB   (dbo.WIPStations - READ ONLY, the one physical station table)
  Last Updated : 2026-09-08
  Status       : Draft - no open sign-off items. It creates a READ and writes nothing.
  Story        : FW-N16 (the Active Run Monitor's station read), D-55
  Specification: Integration.md Sec 4 - "WIPStations is also a READ - D-55, 7 September 2026"
                 DatabaseDesign.md Sec 6.6 - the one-object convention (corrected 10 Sep 2026,
                 P-353: the convention is a SYNONYM; a view is for reshaping, which this does)
                 FR-077 (which SETS the station), OI-112, OI-115

  PURPOSE
  -------
  Surfaces the shared WIP station registry inside FlatWireDB, so the Active Run Monitor can read
  back what is checked in at a line.

  [INT Sec 4] listed CommonDB..WIPStations.CoilNo only as a WRITE - claimed by
  FlatWire_CheckInRod step 9, released by FlatWire_ReleaseStation. D-55 (7 Sep 2026) records the
  other half: DB3 reads it to NAME THE MATERIAL ON THE LINE, because the run header alone cannot
  say what is physically at the station.

  *** A VIEW IS A READ, SO D-32 HOLDS. No shared object is created, altered or dropped. ***

  WHY A VIEW RATHER THAN A SYNONYM OR A THREE-PART NAME AT THE CALL SITE
  ----------------------------------------------------------------------
  *** CORRECTED 10 Sep 2026 (P-353). This block used to say a view was the convention, citing
      [DBD Sec 6.6]'s claim that united_db..alloys is surfaced as a VIEW in six databases. That
      claim was measurably wrong - Alloys is a SYNONYM in six databases and a view in exactly one
      (PlanningDB) - and Sec 6.6 has been corrected. The convention for a pass-through read is a
      SYNONYM. ***

  This object is STILL a view, and the reason is now stated correctly: a synonym is only a name,
  so it cannot RESHAPE. This one renames WIPStation -> Station and trims the padding, which is
  exactly what a synonym cannot do. It absorbs two real mismatches:

    - WIPStation is VARCHAR(6) and SPACE-PADDED to six characters by the seeding script, while
      CoilNo is VARCHAR(9). An untrimmed 'FL1   ' never equals the 'FL1' an idle station parks in
      CoilNo, so an untrimmed comparison reports EVERY station as loaded.
    - Both columns are NULLABLE on the base table. Trimming here keeps the NULL a NULL rather
      than turning it into a space, so the consumer's "no material" test stays one test.

  WHAT IT DELIBERATELY DOES NOT DO
  --------------------------------
    - It does not resolve the IDLE verdict. The API resolves it, in ONE place
      (RunService.FillStationClaimAsync), so that no consumer has to know the sentinel rule. The
      view reports the columns; the service reads them.

    - It projects TWO columns and not the other twelve. Nothing on DB3 renders the five weight
      columns, StationNoCutsSetUp, StationType, the two flags or PrinterName, and a view that
      carries what nothing renders invites someone to render it. Widen it when a story needs them.

    - *** IT DOES NOT PROJECT MachineIdx, AND THAT IS THE POINT. *** It is the column a reader
      reaches for first and it is the wrong key twice over - see C2. Leaving it out means the
      mistake cannot be made through this object.

    - It does not filter to FL1/FL2/FL3. The registry holds every station in the plant and the
      consumer always names one; filtering here would make this a flat-wire subset of a shared
      table, which is a second thing to keep in step with the seed.

  TABLE CONSTRAINTS THAT SHAPE THIS SCRIPT
  ----------------------------------------
  C1. CommonDB..WIPStations is the ONE physical station table. united_db..wip_stations and
      proddb..wip_stations are BOTH VIEWS OVER IT, and so is SlitterDB..WIPStations - one row,
      several names. This view is a fourth name for the same row, which is why it must stay a
      pass-through and never a copy.

  C2. wip_stations_k0 is UNIQUE CLUSTERED on WIPStation, so keying on the name is a SEEK, and the
      station name IS the line name by rule (FlatWire_CheckInRod throws 52005 otherwise).
      *** DO NOT KEY ON MachineIdx. *** It is smallint NULL with no index, AND FL1PO shares FL1's
      value - so that predicate scans the table and returns TWO rows for FL1.

  C3. wip_stations_k1 is a plain UNIQUE index on CoilNo, so only ONE row may hold NULL. An idle
      station therefore parks ITS OWN STATION NAME in CoilNo as a guaranteed-unique placeholder -
      all 78 pre-existing rows, verified 2026-07-28. *** CoilNo EQUAL TO Station MEANS IDLE. ***
      Reading it literally shows an operator a station name where they expect a rod or spool
      number.

  C4. FL2 reads idle through a real run today, and that is a gap in the WRITER rather than in
      this read: FlatWire_CheckInRod throws 52003 for FL2 and no spool check-in procedure exists
      (OI-115). Whatever writes it must carry the same @station = @machineName guard.

  DEPLOYMENT
  ----------
  *** THIS IS THE ONE FILE IN THIS FOLDER THAT CANNOT BE CREATED WITHOUT ITS OTHER DATABASE
      PRESENT. ***

  The folder README says the five procedures have no mutual dependency, because CREATE PROCEDURE
  uses DEFERRED NAME RESOLUTION. *** VIEWS DO NOT. *** CREATE VIEW binds its referenced objects at
  creation time, so this fails with Msg 208 on any instance where CommonDB is absent or where
  ua_user cannot see it. That is why it belongs in this folder and NOT in
  ../sql/FlatWire_DDL_08_Programmability.sql - the same grounds as
  30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql: it cannot be verified by a FlatWireDB-only deploy.

  Deploy on the SHARED instance (DEV00164-001), AFTER 20_FlatWire_Grants.sql. The guard below
  reports and exits rather than failing the batch, so a FlatWireDB-only run stays green and says
  what it skipped.
==============================================================================================*/

USE [FlatWireDB];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/*----------------------------------------------------------------------------------------------
  Sec 0. PRE-FLIGHT - CommonDB must be present AND visible.

  In a batch OF ITS OWN, deliberately. Object names bind at BATCH COMPILE time, so a guard that
  shared a batch with the CREATE VIEW below would be killed by the very Msg 208 it exists to
  prevent - the mistake 11_ carried until 5 Sep 2026. Pass -b to sqlcmd so a failure stops the
  file.

  Present and visible are different things: a missing GRANT surfaces as a NULL OBJECT_ID, which
  reads like a missing table and sends people looking in the wrong place. That is the whole hazard
  of this folder.
----------------------------------------------------------------------------------------------*/
IF DB_ID(N'CommonDB') IS NULL
BEGIN
    PRINT 'SKIPPED: CommonDB is not on this instance, so dbo.WIPStations cannot be created.';
    PRINT '         A view binds at creation time - there is nothing to create against.';
    PRINT '         Deploy on the shared instance instead; see DEPLOYMENT in the header.';
END
ELSE IF OBJECT_ID(N'[CommonDB].[dbo].[WIPStations]', N'U') IS NULL
BEGIN
    RAISERROR (N'CommonDB is present but dbo.WIPStations is not visible to this login. Run 20_FlatWire_Grants.sql first (C1).', 16, 1);
END
GO

/*----------------------------------------------------------------------------------------------
  Sec 1. The view.

  CREATE OR ALTER, matching the five procedures in this folder, so the file is re-runnable. It is
  wrapped in EXEC because CREATE VIEW must be the first statement in its batch and therefore
  cannot sit inside the IF that keeps a FlatWireDB-only run green.

  ⛔ NOT SCHEMABINDING. It cannot be, across databases - and it must not be, because binding a
  flat wire view to a shared table would let this object block a change to CommonDB.
----------------------------------------------------------------------------------------------*/
IF DB_ID(N'CommonDB') IS NOT NULL
    EXEC (N'
CREATE OR ALTER VIEW [dbo].[WIPStations]
AS
SELECT  LTRIM(RTRIM(s.[WIPStation])) AS [Station]   -- C2: the seek key, trimmed once (VARCHAR(6), space-padded)
      , LTRIM(RTRIM(s.[CoilNo]))     AS [CoilNo]    -- C3: EQUAL TO Station means IDLE, not material
FROM    [CommonDB].[dbo].[WIPStations] AS s;
');
GO

IF OBJECT_ID(N'[dbo].[WIPStations]', N'V') IS NOT NULL
BEGIN
    PRINT 'Created view: FlatWireDB.dbo.WIPStations';

    IF DATABASE_PRINCIPAL_ID(N'ua_user') IS NOT NULL
    BEGIN
        /*
         * SELECT only. The view is a read, and granting anything else on a pass-through over a
         * shared table would make FlatWireDB a write path into CommonDB that D-32 forbids.
         */
        GRANT SELECT ON [dbo].[WIPStations] TO [ua_user];
        PRINT 'Granted SELECT on dbo.WIPStations to ua_user';
    END
END
GO
