/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 08_CommonDB_OPCModules_ColumnDrift.sql
  Target DBs   : CommonDB - ALTERS dbo.OPCModules only. Adds TWO NULLABLE COLUMNS and
                            nothing else. Writes no row, creates no constraint, drops
                            nothing. The only SELECTs are its own validation.
  Last Updated : 2026-09-05 (first issue)
  Status       : Draft - RUNNABLE, and on DEV00164-001 it is already a no-op: the columns
                 were added there BY HAND on 5 Sep 2026 and this script is the record of
                 that change, not a pending one. It reports "present" twice and exits.
  Story        : FW-238 (Register flat wire with OPCConnection) - G100
  Runs BEFORE  : 11_. Independent of 09_ - neither touches what the other checks, so either
                 order works - but BOTH must precede 11_. See DEPLOY ORDER in README.md.

  PURPOSE
  -------
  Brings dbo.OPCModules level with ual-database source control by adding the two columns a
  stale CommonDB is missing:

      [OPCEventType]         [int] NULL
      [EventDurationSeconds] [int] NULL

  ual-database\Databases\CommonDB\Tables\OPCModules\CreateTable.sql declares SIX columns.
  DEV00164-001 - the instance [DEP section 2] names as the test1 database server - carried
  FOUR. That is G100, and it is the difference 11_ section 4a inserts into: without these
  two columns its FIRST insert dies on Msg 207 "Invalid column name 'OPCEventType'".

  WHY THIS IS A SCRIPT AND NOT A HAND-RUN ALTER
  ---------------------------------------------
  It was a hand-run ALTER on DEV00164-001, which is exactly the problem this file solves.
  staging and production are both *fill* in [DEP section 2] - unmeasured - and G100 asks for
  the drift to be re-checked per environment. A hand-typed ALTER leaves nothing to re-run
  there and nothing in the audit trail here. This is that artifact.

  WHAT IT DELIBERATELY DOES NOT DO
  --------------------------------
  1. IT WRITES NO ROW, AND IN PARTICULAR IT DOES NOT BACKFILL. The four pre-existing modules
     - Hole Detection, CoilReceiving, Handheld Service, Furnace Scheduling - are left NULL in
     both new columns, because their correct values are not this project's to invent.

     *** READ THIS BEFORE REFRESHING dbo.GetOPCServerAndTagDetails ***

     Those NULLs are safe only while the deployed procedure does not select the two columns,
     which on a stale instance it does not. The source-controlled procedure DOES (:26-27),
     and UA.APIDTO.OPCInfo maps both as NON-NULLABLE int through Dapper
     (OPCConnection.Infrastructure\Repositories\ContextRepository.cs:41, gr.Read<OPCInfo>()).
     So refreshing the procedure while the rows are NULL makes GetOPCInfo THROW for all four
     of those modules.

     Note the interlock this script removes: before the columns existed, CREATE OR ALTER on
     that procedure was IMPOSSIBLE - it binds columns at create time and failed on Msg 207.
     It will now succeed. BACKFILL OPCModulesIdx 1-4 FIRST. See G100.

  2. It adds NULLABLE columns, matching source control exactly rather than improving on it.
     NOT NULL with a default would diverge from the declaration this script exists to match,
     and would silently give four other modules' rows a value this project chose.

  3. It touches only OPCModules. The other four OPC tables were compared column by column
     against source control on 5 Sep 2026 and match exactly; OPCModules is the only drifted
     object of the five.

  TARGET
  ------
  An EXISTING, POPULATED CommonDB. This script never drops or re-creates a table and never
  modifies a single row of data.

      sqlcmd -S "<server>" -d CommonDB -E -C -b -i 08_CommonDB_OPCModules_ColumnDrift.sql

  IDEMPOTENCY
  -----------
  Safe to re-run. Each column is added behind its own COL_LENGTH guard, so an instance that
  is current reports "present" and changes nothing, and one that somehow has a single column
  gets only the missing one.

  SAFETY
  ------
  ALTER TABLE ... ADD of a NULLABLE column with no default is a metadata-only operation: no
  row is touched and no data is rewritten. Section 2 runs inside one transaction, so a
  failure part-way cannot leave the table half level. Section 3 reports the NULLs the change
  creates, because they are the hazard above rather than an incidental detail.

  *** NEVER "refresh" this table by running ual-database's OPCModules\CreateTable.sql. *** It
  opens with DROP TABLE IF EXISTS and would take the live module rows with it. Since 09_ ran
  it now fails outright on Msg 3726 against FK_OPCTagApplicationMapping_OPCModules and
  FK_OPCServerApplicationMapping_OPCModules - an accidental benefit of that hardening, and
  not something to rely on before 09_ has run somewhere.

  REVERSIBILITY
  -------------
  There is NO reverse script and there should not be one. Dropping a column that source
  control declares would re-create the drift this script closes. Same position 09_ takes.

  SOURCE CONTROL
  --------------
  The column declaration's permanent home is ual-database, at
  Databases\CommonDB\Tables\OPCModules\CreateTable.sql. That file follows that repo's
  drop-then-create idiom and cannot be run against a populated server; this script is the
  deployment form of the same declaration. Keep the two in step.
==============================================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @CurrentDb SYSNAME = DB_NAME();
IF @CurrentDb <> 'CommonDB'
BEGIN
    RAISERROR('Wrong database: this script must run against CommonDB (currently %s).', 16, 1, @CurrentDb);
    SET NOEXEC ON;
END
GO

PRINT '================================================================';
PRINT ' CommonDB dbo.OPCModules - close the source-control column drift';
PRINT ' Server:   ' + @@SERVERNAME;
PRINT ' Database: ' + DB_NAME();
PRINT ' Started:  ' + CONVERT(VARCHAR(19), GETDATE(), 120);
PRINT '================================================================';
PRINT '';
GO

/*------------------------------------------------------------------------------
  SECTION 1 - PRE-FLIGHT (read only, aborts on any failure)
------------------------------------------------------------------------------*/
PRINT '-- Section 1: pre-flight ---------------------------------------';

IF OBJECT_ID('[dbo].[OPCModules]', 'U') IS NULL
BEGIN
    RAISERROR('ABORT: dbo.OPCModules does not exist in this database. This is not a CommonDB, or it has never been provisioned.', 16, 1);
    SET NOEXEC ON;
END
GO

-- The four columns that must ALREADY be there. If any is missing, this instance is behind
-- source control by more than the two columns below and a wider refresh is owed - which is
-- CommonDB provisioning's call, not this script's.
DECLARE @Missing VARCHAR(400) = '';

IF COL_LENGTH('dbo.OPCModules', 'OPCModulesIdx') IS NULL SET @Missing = @Missing + 'OPCModulesIdx ';
IF COL_LENGTH('dbo.OPCModules', 'ModuleName')    IS NULL SET @Missing = @Missing + 'ModuleName ';
IF COL_LENGTH('dbo.OPCModules', 'IsReadOnly')    IS NULL SET @Missing = @Missing + 'IsReadOnly ';
IF COL_LENGTH('dbo.OPCModules', 'ConnectionType') IS NULL SET @Missing = @Missing + 'ConnectionType ';

IF @Missing <> ''
BEGIN
    PRINT '   dbo.OPCModules as it stands on this instance:';
    SELECT    c.[column_id], c.[name], t.[name] AS [type], c.[is_nullable]
    FROM      sys.columns AS c
              INNER JOIN sys.types AS t ON t.[user_type_id] = c.[user_type_id]
    WHERE     c.[object_id] = OBJECT_ID('dbo.OPCModules')
    ORDER BY  c.[column_id];

    RAISERROR('ABORT: dbo.OPCModules is missing a BASE column (%s) - this instance is behind source control by more than the two columns this script adds. Refer it to whoever owns CommonDB provisioning. Nothing was changed.', 16, 1, @Missing);
    SET NOEXEC ON;
END
ELSE
BEGIN
    PRINT '   All 4 base columns present.';
    PRINT '';
END
GO

/*------------------------------------------------------------------------------
  SECTION 2 - ADD THE COLUMNS (one transaction, all or nothing)
------------------------------------------------------------------------------*/
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '-- Section 2: columns ------------------------------------------';

    IF COL_LENGTH('dbo.OPCModules', 'OPCEventType') IS NULL
    BEGIN
        ALTER TABLE [dbo].[OPCModules] ADD [OPCEventType] [int] NULL;
        PRINT '   created  OPCModules.OPCEventType';
    END ELSE PRINT '   present  OPCModules.OPCEventType';

    IF COL_LENGTH('dbo.OPCModules', 'EventDurationSeconds') IS NULL
    BEGIN
        ALTER TABLE [dbo].[OPCModules] ADD [EventDurationSeconds] [int] NULL;
        PRINT '   created  OPCModules.EventDurationSeconds';
    END ELSE PRINT '   present  OPCModules.EventDurationSeconds';

    COMMIT TRANSACTION;
    PRINT '';
    PRINT '   Committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT '';
    PRINT '   ROLLED BACK - nothing was added. Error follows.';
    THROW;
END CATCH
GO

/*------------------------------------------------------------------------------
  SECTION 3 - POST-VERIFICATION
------------------------------------------------------------------------------*/
PRINT '';
PRINT '-- Section 3: verification -------------------------------------';

SELECT    c.[column_id]        AS [Ordinal]
        , c.[name]             AS [Column]
        , t.[name]             AS [Type]
        , c.[is_nullable]      AS [IsNullable]
        , c.[is_identity]      AS [IsIdentity]
FROM      sys.columns AS c
          INNER JOIN sys.types AS t ON t.[user_type_id] = c.[user_type_id]
WHERE     c.[object_id] = OBJECT_ID('[dbo].[OPCModules]')
ORDER BY  c.[column_id];

DECLARE @Cols INT, @EventType INT, @Duration INT;

SELECT @Cols = COUNT(*) FROM sys.columns WHERE [object_id] = OBJECT_ID('[dbo].[OPCModules]');

SELECT    @EventType = COUNT(*)
FROM      sys.columns
WHERE     [object_id] = OBJECT_ID('[dbo].[OPCModules]')
          AND [name] = 'OPCEventType'
          AND TYPE_NAME([user_type_id]) = 'int'
          AND [is_nullable] = 1;

SELECT    @Duration = COUNT(*)
FROM      sys.columns
WHERE     [object_id] = OBJECT_ID('[dbo].[OPCModules]')
          AND [name] = 'EventDurationSeconds'
          AND TYPE_NAME([user_type_id]) = 'int'
          AND [is_nullable] = 1;

PRINT '';
PRINT '   Columns on OPCModules        : ' + CAST(@Cols      AS VARCHAR(10)) + '   (expected 6)';
PRINT '   OPCEventType int NULL        : ' + CAST(@EventType AS VARCHAR(10)) + '   (expected 1)';
PRINT '   EventDurationSeconds int NULL: ' + CAST(@Duration AS VARCHAR(10)) + '   (expected 1)';

IF @Cols = 6 AND @EventType = 1 AND @Duration = 1
    PRINT '   RESULT: dbo.OPCModules matches ual-database source control.';
ELSE
    PRINT '   RESULT: MISMATCH - review the result set above.';
GO

/*------------------------------------------------------------------------------
  SECTION 4 - THE NULLs THIS CHANGE CREATES

  Dynamic SQL deliberately. A literal SELECT of these two columns would be BOUND when this
  batch COMPILES, so on an instance where section 1 aborted - the columns never added - the
  script would die on the very Msg 207 it exists to prevent, and report it as its own defect.
  sp_executesql defers compilation to execution, so an aborted run skips this silently.
  It is the same trap that made 11_'s original drift guard unable to fire.
------------------------------------------------------------------------------*/
PRINT '';
PRINT '-- Section 4: NULL audit ---------------------------------------';
PRINT '   Rows below carry NULL in a column the source-controlled';
PRINT '   GetOPCServerAndTagDetails SELECTs into a NON-NULLABLE DTO int.';
PRINT '   BACKFILL THEM BEFORE REFRESHING THAT PROCEDURE - see G100.';
PRINT '';

EXEC sp_executesql N'
SELECT    [OPCModulesIdx]
        , RTRIM([ModuleName]) AS [ModuleName]
        , [OPCEventType]
        , [EventDurationSeconds]
FROM      [dbo].[OPCModules]
WHERE     [OPCEventType] IS NULL OR [EventDurationSeconds] IS NULL
ORDER BY  [OPCModulesIdx];';

PRINT '';
PRINT ' Finished: ' + CONVERT(VARCHAR(19), GETDATE(), 120);
PRINT '================================================================';
GO

SET NOEXEC OFF;
GO
