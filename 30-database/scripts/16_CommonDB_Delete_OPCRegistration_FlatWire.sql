/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 16_CommonDB_Delete_OPCRegistration_FlatWire.sql
  Target DBs   : CommonDB (dbo.OPCTagApplicationMapping, dbo.OPCTags,
                           dbo.OPCServerApplicationMapping, dbo.OPCModules)
                 dbo.OPCServers is NOT in that list and must never join it - see SCOPE.
  Last Updated : 2026-09-05 (second pass - D-48: OPCServers is a lookup, so there is nothing
                 of ours in it to reverse)
  Status       : Draft - DEV ONLY. See SCOPE before running anywhere else.
  Story        : FW-238 (Register flat wire with OPCConnection)

  PURPOSE
  -------
  Reverses 11_CommonDB_Insert_OPCRegistration_FlatWire.sql. Numbered 16 to sit five after the
  script it reverses, the same way 15 reverses 10.

  SCOPE - WHAT THIS DOES AND DOES NOT TOUCH
  -----------------------------------------
  Deletes ONLY rows this project created, matched by exact value:
      - OPCTagApplicationMapping rows for OPCModuleId 6
      - OPCTags rows whose TagName begins FL1.PLC. or FL2.PLC. AND that no OTHER mapping
        still points at
      - OPCServerApplicationMapping rows for OPCModuleId 6
      - the OPCModules row for OPCModuleId 6, ONLY if no mapping of either kind survives

  ⛔ NOTHING IS DELETED FROM dbo.OPCServers (D-48). That table is a LOOKUP of site endpoints
  shared by every module; 11_ SELECTS a row from it and never inserts one, so there is no flat
  wire row in it to reverse. An earlier version of this script deleted the endpoint "only if no
  mapping of any module still references it" - that conservatism was not merely unnecessary, it
  was WRONG: an endpoint nothing currently maps is still infrastructure, and removing it here
  would have deleted somebody else's lookup row on the strength of our own rollback.

  It does NOT touch united_db.dbo.machines, CommonDB.WIPStations or
  MachineStationsConfiguration. Those are script 10's rows and script 15 reverses them.

  ORDER IS NOT OPTIONAL
  ---------------------
  Mappings come out before the rows they point at. Delete OPCTags first and the mapping rows
  are orphaned - OPCTagsIdx is an int with no foreign key anywhere in source control, so
  nothing stops it - and the natural key that 11 matches on (TagName joined through the
  mapping) stops resolving, which makes a later re-run insert duplicates rather than skip.

  WHY THERE IS A REVERSE SCRIPT HERE AND NOT FOR SCRIPT 10
  --------------------------------------------------------
  Script 10 writes rows that other modules read the moment they exist - machines and WIP
  stations are shared reference data with live runtime state hanging off them. This script's
  rows are inert to every other module: OPCModuleId 6 is ours alone, and the tag paths are
  namespaced by line. That makes them safely removable on a DEV instance, which is what this
  script is for.

  ⚠ Still not for production without sign-off. If the lines are commissioned, deleting the
  registration stops GetOPCInfo answering and every push fails.
==============================================================================================*/

USE [CommonDB];
GO

SET NOCOUNT ON;
GO

DECLARE @OPCModuleId INT          = 6;
DECLARE @ModuleName  VARCHAR(128) = 'FlatWire';

/*----------------------------------------------------------------------------------------------
  Pre-flight - report what is about to go, so a mistaken run is visible before it commits.
----------------------------------------------------------------------------------------------*/
PRINT 'About to remove the flat wire OPC registration. Current state:';

SELECT    'OPCTagApplicationMapping' AS [Table], COUNT(*) AS [Rows]
FROM      [dbo].[OPCTagApplicationMapping] WHERE [OPCModuleId] = @OPCModuleId
UNION ALL
SELECT    'OPCServerApplicationMapping', COUNT(*)
FROM      [dbo].[OPCServerApplicationMapping] WHERE [OPCModuleId] = @OPCModuleId
UNION ALL
SELECT    'OPCModules', COUNT(*)
FROM      [dbo].[OPCModules] WHERE [OPCModulesIdx] = @OPCModuleId;

-- Guard: refuse to run against a module that is not ours.
IF EXISTS ( SELECT 1
            FROM   [dbo].[OPCModules]
            WHERE  [OPCModulesIdx] = @OPCModuleId
                   AND ISNULL(RTRIM([ModuleName]), '') <> @ModuleName )
BEGIN
    RAISERROR('ABORT: OPCModulesIdx 6 does not hold the flat wire module on this instance. Refusing to delete another module''s registration.', 16, 1);
    RETURN;
END

/*----------------------------------------------------------------------------------------------
  Delete, in reverse dependency order
----------------------------------------------------------------------------------------------*/
BEGIN TRY
    BEGIN TRANSACTION;

    -- Remember which tag rows were ours BEFORE the mappings go, because the mapping is the
    -- only thing that ties a tag row to this module.
    DECLARE @OurTags TABLE ( [OPCTagsIdx] INT NOT NULL PRIMARY KEY );

    INSERT INTO @OurTags ( [OPCTagsIdx] )
    SELECT DISTINCT otam.[OPCTagsIdx]
    FROM   [dbo].[OPCTagApplicationMapping] AS otam
           INNER JOIN [dbo].[OPCTags] AS ot ON ot.[OPCTagsIdx] = otam.[OPCTagsIdx]
    WHERE  otam.[OPCModuleId] = @OPCModuleId
           AND ( RTRIM(ot.[TagName]) LIKE 'FL1.PLC.%' OR RTRIM(ot.[TagName]) LIKE 'FL2.PLC.%' );

    -- 1. Tag mappings.
    DELETE FROM [dbo].[OPCTagApplicationMapping] WHERE [OPCModuleId] = @OPCModuleId;
    PRINT 'OPCTagApplicationMapping: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) deleted.';

    -- 2. The tag rows themselves - but only those nothing else still points at.
    DELETE    ot
    FROM      [dbo].[OPCTags] AS ot
              INNER JOIN @OurTags AS o ON o.[OPCTagsIdx] = ot.[OPCTagsIdx]
    WHERE     NOT EXISTS ( SELECT 1
                           FROM   [dbo].[OPCTagApplicationMapping] AS x
                           WHERE  x.[OPCTagsIdx] = ot.[OPCTagsIdx] );
    PRINT 'OPCTags: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) deleted.';

    -- 3. Server mappings. Only the MAPPING goes; the endpoint it points at is a lookup row
    --    and stays exactly where it is (D-48). The step that used to delete it is GONE, and
    --    the steps below are renumbered accordingly - see SCOPE for why it was wrong.
    DELETE FROM [dbo].[OPCServerApplicationMapping] WHERE [OPCModuleId] = @OPCModuleId;
    PRINT 'OPCServerApplicationMapping: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) deleted.';
    PRINT 'OPCServers: 0 row(s) deleted - it is a lookup table and 11_ never wrote to it.';

    -- 4. The module row, last, and only once nothing maps to it.
    DELETE    om
    FROM      [dbo].[OPCModules] AS om
    WHERE     om.[OPCModulesIdx] = @OPCModuleId
              AND RTRIM(om.[ModuleName]) = @ModuleName
              AND NOT EXISTS ( SELECT 1 FROM [dbo].[OPCTagApplicationMapping]    WHERE [OPCModuleId] = @OPCModuleId )
              AND NOT EXISTS ( SELECT 1 FROM [dbo].[OPCServerApplicationMapping] WHERE [OPCModuleId] = @OPCModuleId );
    PRINT 'OPCModules: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) deleted.';

    COMMIT TRANSACTION;
    PRINT 'Flat wire OPC registration removed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR: flat wire OPC registration delete rolled back; no table was changed.';
    THROW;
END CATCH
GO

/*----------------------------------------------------------------------------------------------
  Verification - all four must return ZERO rows.
----------------------------------------------------------------------------------------------*/
DECLARE @OPCModuleId INT = 6;

SELECT 'OPCModules'                   AS [Table], COUNT(*) AS [Remaining] FROM [dbo].[OPCModules]                   WHERE [OPCModulesIdx] = @OPCModuleId
UNION ALL
SELECT 'OPCTagApplicationMapping',              COUNT(*)            FROM [dbo].[OPCTagApplicationMapping]    WHERE [OPCModuleId]   = @OPCModuleId
UNION ALL
SELECT 'OPCServerApplicationMapping',           COUNT(*)            FROM [dbo].[OPCServerApplicationMapping] WHERE [OPCModuleId]   = @OPCModuleId
UNION ALL
SELECT 'OPCTags (FL1./FL2. paths)',             COUNT(*)            FROM [dbo].[OPCTags]
       WHERE RTRIM([TagName]) LIKE 'FL1.PLC.%' OR RTRIM([TagName]) LIKE 'FL2.PLC.%';
GO
