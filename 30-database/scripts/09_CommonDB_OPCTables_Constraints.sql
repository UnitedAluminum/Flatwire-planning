/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 09_CommonDB_OPCTables_Constraints.sql
  Target DBs   : CommonDB - ALTERS dbo.OPCModules, dbo.OPCServers, dbo.OPCTags,
                            dbo.OPCTagApplicationMapping, dbo.OPCServerApplicationMapping
                          - Adds KEYS, CONSTRAINTS and INDEXES only. Writes no row and
                            alters no column. The only SELECTs are its own validation.
  Last Updated : 2026-09-05 (first issue)
  Status       : Draft - RUNNABLE, and the only script in this folder that is.
                 NOT blocked by G100: it references only columns that exist on BOTH
                 DEV00164-001 and source control, so the dbo.OPCModules column drift
                 that stops 11_ has no bearing on it. Pre-flight measured against
                 DEV00164-001 on 5 Sep 2026: 16 checks, 0 conflicts.
  Story        : FW-238 (Register flat wire with OPCConnection) - schema hardening
  Runs BEFORE  : 10_ and 11_. See DEPLOY ORDER below - this is why it is numbered 09.

  PURPOSE
  -------
  Adds primary keys, unique constraints, foreign keys, one check constraint and two
  supporting indexes to the five CommonDB OPC configuration tables.

  All five are pure HEAPs today - no PK, no unique index, no FK, no check constraint of
  any kind. Their legacy united_db predecessors (OPC_Tags, OPC_Servers,
  OPC_Tag_Application_Mapping, OPC_Server_Application_Mapping) DO carry primary keys and
  two foreign keys, under Databases\united_db\Tables\OPC_*\Constraints\. The constraints
  were lost when the tables were migrated into CommonDB and never re-created. This script
  closes that gap.

  This is an INTEGRITY fix, not a performance one. Measured SET STATISTICS IO for the sole
  consumer, GetOPCServerAndTagDetails, is 21 logical reads across all five tables - they
  are 1-5 pages each, so a heap scan is already near-optimal.

  WHY THIS FOLDER, AND WHY BEFORE 11_
  -----------------------------------
  11_CommonDB_Insert_OPCRegistration_FlatWire.sql carries hand-written guards and fault
  probes that exist ONLY because these constraints are missing. Its own header says so:

      "OPCTags: No primary key and no unique index of any kind exists on this table in
       source control. Idempotency is therefore enforced by this script's own guards,
       not by the schema."
      "Guard: ModuleName has no unique index, so a duplicate would make the id lookup
       ambiguous."
      "A duplicate (machine, module, tag) mapping. The table has no unique index to
       prevent it."
      "A duplicated ConnectionSequence on one line ... No unique index prevents it."
      "A server mapping pointing at an endpoint that does not exist ... OPCServersIdx
       carries no foreign key."

  Running this FIRST turns every one of those from a hand-written guard into a schema
  guarantee, and protects 11_'s inserts from the first run rather than the second.

  11_ stays safe under the new constraints: it writes parents before children (OPCModules,
  then the server mappings, then OPCTags, then the tag mappings), and 16_ deletes children
  before parents. Both orders already satisfy the four foreign keys added here.

  TARGET
  ------
  An EXISTING, POPULATED CommonDB. This script never drops or re-creates a table and never
  modifies a single row of data.

      sqlcmd -S "<server>" -d CommonDB -E -C -i 09_CommonDB_OPCTables_Constraints.sql

  IDEMPOTENCY
  -----------
  Safe to re-run. Every object is created behind an IF NOT EXISTS guard, so a second run
  reports "present" and changes nothing. Unlike the per-table files in ual-database under
  Databases\CommonDB\Tables\OPC*\Constraints\, this script NEVER drops an existing
  constraint -- on a live server that would briefly leave data unprotected.

  SAFETY
  ------
  Section 1 validates every constraint against the data BEFORE anything is created, and
  aborts with the failing checks printed if any conflict exists. Sections 2-5 run inside a
  single transaction, so a failure part-way through cannot leave the database half
  constrained.

  REVERSIBILITY
  -------------
  Reversible, DEV only, and by hand - there is no reverse script. Every object added here
  is named PK_OPC*, UQ_OPC*, FK_OPC*, CK_OPC* or IX_OPC*, so section 6's two result sets
  list exactly what to drop. Note that dropping a clustered PK returns the table to a heap.

  NOT INCLUDED, DELIBERATELY
  --------------------------
  - No foreign key on Machineidx. Both mapping tables carry it, but the dbo.machines they
    join to is a CommonDB VIEW over united_db..machines. SQL Server supports neither
    cross-database foreign keys nor foreign keys to a view. All 74 + 882 values were
    verified valid against united_db.dbo.machines (0 orphans), but the rule is not
    expressible. This matches LabelButtonMachineMapping and OptionButtonMachineMapping,
    which likewise have no FK on their machine column.
  - No covering indexes. See the 21-logical-read measurement above. A covering index would
    add write cost for no measurable read gain. Revisit only if these tables grow by an
    order of magnitude.
  - No unique constraint on OPCServers.OPCServerClass - all four rows share
    'SWToolbox.TOPServer.V6'.

  COLUMN ORDER NOTE
  -----------------
  The mapping-table natural keys lead with OPCModuleId, not Machineidx. Column order does
  not change what a unique constraint enforces, but it decides whether it is usable as an
  index. OPCModuleId alone is the predicate in all three result sets of
  GetOPCServerAndTagDetails and in both DELETE statements of 16_, so leading with it is
  strictly more useful at no cost.

  SOURCE CONTROL
  --------------
  The same 18 objects exist as per-table files in the ual-database repository, under
  Databases\CommonDB\Tables\OPC{Modules,Servers,Tags,TagApplicationMapping,
  ServerApplicationMapping}\{Constraints,Indexes}\. Those follow that repo's drop-then-create
  idiom and are the permanent home; this script is the deployment form for an already
  populated server. Keep the two in step.
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
PRINT ' CommonDB OPC tables - add keys, constraints and indexes';
PRINT ' Server:   ' + @@SERVERNAME;
PRINT ' Database: ' + DB_NAME();
PRINT ' Started:  ' + CONVERT(VARCHAR(19), GETDATE(), 120);
PRINT '================================================================';
PRINT '';
GO

/*------------------------------------------------------------------------------
  SECTION 1 - PRE-FLIGHT VALIDATION (read only, aborts on any failure)
------------------------------------------------------------------------------*/
PRINT '-- Section 1: pre-flight validation ----------------------------';

DECLARE @Problems TABLE ( [Check] VARCHAR(80) NOT NULL, [Conflicts] INT NOT NULL );

-- Surrogate keys must be unique before a PRIMARY KEY can be created.
INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'PK OPCModules.OPCModulesIdx', COUNT(*) - COUNT(DISTINCT [OPCModulesIdx]) FROM [dbo].[OPCModules]
UNION ALL SELECT 'PK OPCServers.OPCServersIdx', COUNT(*) - COUNT(DISTINCT [OPCServersIdx]) FROM [dbo].[OPCServers]
UNION ALL SELECT 'PK OPCTags.OPCTagsIdx', COUNT(*) - COUNT(DISTINCT [OPCTagsIdx]) FROM [dbo].[OPCTags]
UNION ALL SELECT 'PK OPCTagApplicationMapping', COUNT(*) - COUNT(DISTINCT [OPCTagApplicationMappingIdx]) FROM [dbo].[OPCTagApplicationMapping]
UNION ALL SELECT 'PK OPCServerApplicationMapping', COUNT(*) - COUNT(DISTINCT [OPCServerApplicationMappingIdx]) FROM [dbo].[OPCServerApplicationMapping];

-- Natural keys. varchar comparison ignores trailing blanks, so UNIQUE enforces
-- exactly the RTRIM(...) semantics 11_ assumes when it matches on TagName.
INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'UQ OPCTags.TagName', COUNT(*) - COUNT(DISTINCT [TagName]) FROM [dbo].[OPCTags]
UNION ALL SELECT 'UQ OPCModules.ModuleName', COUNT(*) - COUNT(DISTINCT [ModuleName]) FROM [dbo].[OPCModules]
UNION ALL SELECT 'UQ OPCServers.OPCServerName', COUNT(*) - COUNT(DISTINCT [OPCServerName]) FROM [dbo].[OPCServers];

INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'UQ OPCTagApplicationMapping (Module,Machine,Tag)', COUNT(*)
FROM      ( SELECT 1 AS [c] FROM [dbo].[OPCTagApplicationMapping]
            GROUP BY [OPCModuleId], [Machineidx], [OPCTagsIdx] HAVING COUNT(*) > 1 ) AS x;

INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'UQ OPCServerApplicationMapping (Mod,Mac,Server)', COUNT(*)
FROM      ( SELECT 1 AS [c] FROM [dbo].[OPCServerApplicationMapping]
            GROUP BY [OPCModuleId], [Machineidx], [OPCServersIdx] HAVING COUNT(*) > 1 ) AS x;

INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'UQ OPCServerApplicationMapping (Mod,Mac,Seq)', COUNT(*)
FROM      ( SELECT 1 AS [c] FROM [dbo].[OPCServerApplicationMapping]
            GROUP BY [OPCModuleId], [Machineidx], [ConnectionSequence] HAVING COUNT(*) > 1 ) AS x;

-- Referential integrity for the four new foreign keys.
INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'FK OPCTagApplicationMapping -> OPCTags', COUNT(*)
FROM      [dbo].[OPCTagApplicationMapping] AS m
WHERE     NOT EXISTS ( SELECT 1 FROM [dbo].[OPCTags] AS t WHERE t.[OPCTagsIdx] = m.[OPCTagsIdx] );

INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'FK OPCTagApplicationMapping -> OPCModules', COUNT(*)
FROM      [dbo].[OPCTagApplicationMapping] AS m
WHERE     NOT EXISTS ( SELECT 1 FROM [dbo].[OPCModules] AS o WHERE o.[OPCModulesIdx] = m.[OPCModuleId] );

INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'FK OPCServerApplicationMapping -> OPCServers', COUNT(*)
FROM      [dbo].[OPCServerApplicationMapping] AS s
WHERE     NOT EXISTS ( SELECT 1 FROM [dbo].[OPCServers] AS x WHERE x.[OPCServersIdx] = s.[OPCServersIdx] );

INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'FK OPCServerApplicationMapping -> OPCModules', COUNT(*)
FROM      [dbo].[OPCServerApplicationMapping] AS s
WHERE     NOT EXISTS ( SELECT 1 FROM [dbo].[OPCModules] AS o WHERE o.[OPCModulesIdx] = s.[OPCModuleId] );

-- Check constraint.
INSERT INTO @Problems ( [Check], [Conflicts] )
SELECT    'CK OPCServerApplicationMapping.ConnectionSequence', COUNT(*)
FROM      [dbo].[OPCServerApplicationMapping] WHERE [ConnectionSequence] <= 0;

IF EXISTS ( SELECT 1 FROM @Problems WHERE [Conflicts] > 0 )
BEGIN
    PRINT '   ABORTING - the data violates one or more constraints below.';
    PRINT '   Resolve every row counted, then re-run. Nothing was changed.';
    PRINT '';
    SELECT [Check], [Conflicts] FROM @Problems WHERE [Conflicts] > 0 ORDER BY [Check];
    RAISERROR('Pre-flight validation failed. No constraints were created.', 16, 1);
    SET NOEXEC ON;
END
ELSE
BEGIN
    DECLARE @CheckCount INT;
    SELECT @CheckCount = COUNT(*) FROM @Problems;
    PRINT '   All ' + CAST(@CheckCount AS VARCHAR(10))
        + ' pre-flight checks passed - 0 conflicts.';
    PRINT '';
END
GO

/*------------------------------------------------------------------------------
  SECTIONS 2-5 - CREATE THE OBJECTS (one transaction, all or nothing)
------------------------------------------------------------------------------*/
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '-- Section 2: primary keys ------------------------------------';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_OPCModules' )
    BEGIN
        ALTER TABLE [dbo].[OPCModules] ADD CONSTRAINT [PK_OPCModules]
            PRIMARY KEY CLUSTERED ( [OPCModulesIdx] );
        PRINT '   created  PK_OPCModules';
    END ELSE PRINT '   present  PK_OPCModules';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_OPCServers' )
    BEGIN
        ALTER TABLE [dbo].[OPCServers] ADD CONSTRAINT [PK_OPCServers]
            PRIMARY KEY CLUSTERED ( [OPCServersIdx] );
        PRINT '   created  PK_OPCServers';
    END ELSE PRINT '   present  PK_OPCServers';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_OPCTags' )
    BEGIN
        ALTER TABLE [dbo].[OPCTags] ADD CONSTRAINT [PK_OPCTags]
            PRIMARY KEY CLUSTERED ( [OPCTagsIdx] );
        PRINT '   created  PK_OPCTags';
    END ELSE PRINT '   present  PK_OPCTags';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_OPCTagApplicationMapping' )
    BEGIN
        ALTER TABLE [dbo].[OPCTagApplicationMapping] ADD CONSTRAINT [PK_OPCTagApplicationMapping]
            PRIMARY KEY CLUSTERED ( [OPCTagApplicationMappingIdx] );
        PRINT '   created  PK_OPCTagApplicationMapping';
    END ELSE PRINT '   present  PK_OPCTagApplicationMapping';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'PK_OPCServerApplicationMapping' )
    BEGIN
        ALTER TABLE [dbo].[OPCServerApplicationMapping] ADD CONSTRAINT [PK_OPCServerApplicationMapping]
            PRIMARY KEY CLUSTERED ( [OPCServerApplicationMappingIdx] );
        PRINT '   created  PK_OPCServerApplicationMapping';
    END ELSE PRINT '   present  PK_OPCServerApplicationMapping';

    PRINT '';
    PRINT '-- Section 3: unique constraints -------------------------------';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'UQ_OPCModules_ModuleName' )
    BEGIN
        ALTER TABLE [dbo].[OPCModules] ADD CONSTRAINT [UQ_OPCModules_ModuleName]
            UNIQUE NONCLUSTERED ( [ModuleName] );
        PRINT '   created  UQ_OPCModules_ModuleName';
    END ELSE PRINT '   present  UQ_OPCModules_ModuleName';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'UQ_OPCServers_OPCServerName' )
    BEGIN
        ALTER TABLE [dbo].[OPCServers] ADD CONSTRAINT [UQ_OPCServers_OPCServerName]
            UNIQUE NONCLUSTERED ( [OPCServerName] );
        PRINT '   created  UQ_OPCServers_OPCServerName';
    END ELSE PRINT '   present  UQ_OPCServers_OPCServerName';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'UQ_OPCTags_TagName' )
    BEGIN
        ALTER TABLE [dbo].[OPCTags] ADD CONSTRAINT [UQ_OPCTags_TagName]
            UNIQUE NONCLUSTERED ( [TagName] );
        PRINT '   created  UQ_OPCTags_TagName';
    END ELSE PRINT '   present  UQ_OPCTags_TagName';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'UQ_OPCTagApplicationMapping_Module_Machine_Tag' )
    BEGIN
        ALTER TABLE [dbo].[OPCTagApplicationMapping] ADD CONSTRAINT [UQ_OPCTagApplicationMapping_Module_Machine_Tag]
            UNIQUE NONCLUSTERED ( [OPCModuleId] ASC, [Machineidx] ASC, [OPCTagsIdx] ASC );
        PRINT '   created  UQ_OPCTagApplicationMapping_Module_Machine_Tag';
    END ELSE PRINT '   present  UQ_OPCTagApplicationMapping_Module_Machine_Tag';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'UQ_OPCServerApplicationMapping_Module_Machine_Server' )
    BEGIN
        ALTER TABLE [dbo].[OPCServerApplicationMapping] ADD CONSTRAINT [UQ_OPCServerApplicationMapping_Module_Machine_Server]
            UNIQUE NONCLUSTERED ( [OPCModuleId] ASC, [Machineidx] ASC, [OPCServersIdx] ASC );
        PRINT '   created  UQ_OPCServerApplicationMapping_Module_Machine_Server';
    END ELSE PRINT '   present  UQ_OPCServerApplicationMapping_Module_Machine_Server';

    IF NOT EXISTS ( SELECT 1 FROM sys.key_constraints WHERE [name] = 'UQ_OPCServerApplicationMapping_Module_Machine_Seq' )
    BEGIN
        ALTER TABLE [dbo].[OPCServerApplicationMapping] ADD CONSTRAINT [UQ_OPCServerApplicationMapping_Module_Machine_Seq]
            UNIQUE NONCLUSTERED ( [OPCModuleId] ASC, [Machineidx] ASC, [ConnectionSequence] ASC );
        PRINT '   created  UQ_OPCServerApplicationMapping_Module_Machine_Seq';
    END ELSE PRINT '   present  UQ_OPCServerApplicationMapping_Module_Machine_Seq';

    PRINT '';
    PRINT '-- Section 4: foreign keys and check constraint ----------------';

    IF NOT EXISTS ( SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_OPCTagApplicationMapping_OPCTags' )
    BEGIN
        ALTER TABLE [dbo].[OPCTagApplicationMapping] ADD CONSTRAINT [FK_OPCTagApplicationMapping_OPCTags]
            FOREIGN KEY ( [OPCTagsIdx] ) REFERENCES [dbo].[OPCTags] ( [OPCTagsIdx] );
        PRINT '   created  FK_OPCTagApplicationMapping_OPCTags';
    END ELSE PRINT '   present  FK_OPCTagApplicationMapping_OPCTags';

    IF NOT EXISTS ( SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_OPCTagApplicationMapping_OPCModules' )
    BEGIN
        ALTER TABLE [dbo].[OPCTagApplicationMapping] ADD CONSTRAINT [FK_OPCTagApplicationMapping_OPCModules]
            FOREIGN KEY ( [OPCModuleId] ) REFERENCES [dbo].[OPCModules] ( [OPCModulesIdx] );
        PRINT '   created  FK_OPCTagApplicationMapping_OPCModules';
    END ELSE PRINT '   present  FK_OPCTagApplicationMapping_OPCModules';

    IF NOT EXISTS ( SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_OPCServerApplicationMapping_OPCServers' )
    BEGIN
        ALTER TABLE [dbo].[OPCServerApplicationMapping] ADD CONSTRAINT [FK_OPCServerApplicationMapping_OPCServers]
            FOREIGN KEY ( [OPCServersIdx] ) REFERENCES [dbo].[OPCServers] ( [OPCServersIdx] );
        PRINT '   created  FK_OPCServerApplicationMapping_OPCServers';
    END ELSE PRINT '   present  FK_OPCServerApplicationMapping_OPCServers';

    IF NOT EXISTS ( SELECT 1 FROM sys.foreign_keys WHERE [name] = 'FK_OPCServerApplicationMapping_OPCModules' )
    BEGIN
        ALTER TABLE [dbo].[OPCServerApplicationMapping] ADD CONSTRAINT [FK_OPCServerApplicationMapping_OPCModules]
            FOREIGN KEY ( [OPCModuleId] ) REFERENCES [dbo].[OPCModules] ( [OPCModulesIdx] );
        PRINT '   created  FK_OPCServerApplicationMapping_OPCModules';
    END ELSE PRINT '   present  FK_OPCServerApplicationMapping_OPCModules';

    -- Deliberately > 0 rather than BETWEEN 1 AND 2: the data is only ever a
    -- primary/failover pair today, but a three-way redundancy configuration
    -- must not be blocked by this constraint.
    IF NOT EXISTS ( SELECT 1 FROM sys.check_constraints WHERE [name] = 'CK_OPCServerApplicationMapping_ConnectionSequence' )
    BEGIN
        ALTER TABLE [dbo].[OPCServerApplicationMapping] ADD CONSTRAINT [CK_OPCServerApplicationMapping_ConnectionSequence]
            CHECK ( [ConnectionSequence] > 0 );
        PRINT '   created  CK_OPCServerApplicationMapping_ConnectionSequence';
    END ELSE PRINT '   present  CK_OPCServerApplicationMapping_ConnectionSequence';

    PRINT '';
    PRINT '-- Section 5: supporting indexes -------------------------------';

    -- These two carry the delete side of the new foreign keys, and the orphan
    -- probes in 16_, which seek OPCTagsIdx / OPCServersIdx alone. Neither is
    -- the leading column of any natural key.
    IF NOT EXISTS ( SELECT 1 FROM sys.indexes
                    WHERE [name] = 'IX_OPCTagApplicationMapping_OPCTagsIdx'
                          AND [object_id] = OBJECT_ID('[dbo].[OPCTagApplicationMapping]') )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_OPCTagApplicationMapping_OPCTagsIdx]
            ON [dbo].[OPCTagApplicationMapping] ( [OPCTagsIdx] ASC );
        PRINT '   created  IX_OPCTagApplicationMapping_OPCTagsIdx';
    END ELSE PRINT '   present  IX_OPCTagApplicationMapping_OPCTagsIdx';

    IF NOT EXISTS ( SELECT 1 FROM sys.indexes
                    WHERE [name] = 'IX_OPCServerApplicationMapping_OPCServersIdx'
                          AND [object_id] = OBJECT_ID('[dbo].[OPCServerApplicationMapping]') )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_OPCServerApplicationMapping_OPCServersIdx]
            ON [dbo].[OPCServerApplicationMapping] ( [OPCServersIdx] ASC );
        PRINT '   created  IX_OPCServerApplicationMapping_OPCServersIdx';
    END ELSE PRINT '   present  IX_OPCServerApplicationMapping_OPCServersIdx';

    COMMIT TRANSACTION;
    PRINT '';
    PRINT '   Committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT '';
    PRINT '   ROLLED BACK - nothing was created. Error follows.';
    THROW;
END CATCH
GO

/*------------------------------------------------------------------------------
  SECTION 6 - POST-VERIFICATION
------------------------------------------------------------------------------*/
PRINT '';
PRINT '-- Section 6: verification -------------------------------------';

SELECT    t.[name]                     AS [Table]
        , ISNULL(i.[name], '(HEAP)')   AS [Object]
        , i.[type_desc]                AS [Type]
        , i.[is_primary_key]           AS [IsPK]
        , i.[is_unique_constraint]     AS [IsUQ]
        , STUFF(( SELECT ', ' + c.[name]
                  FROM   sys.index_columns AS ic
                         INNER JOIN sys.columns AS c
                             ON c.[object_id] = ic.[object_id]
                                AND c.[column_id] = ic.[column_id]
                  WHERE  ic.[object_id] = i.[object_id]
                         AND ic.[index_id] = i.[index_id]
                         AND ic.[is_included_column] = 0
                  ORDER BY ic.[key_ordinal]
                  FOR XML PATH('') ), 1, 2, '') AS [KeyColumns]
FROM      sys.tables AS t
          LEFT JOIN sys.indexes AS i ON i.[object_id] = t.[object_id]
WHERE     t.[name] IN ( 'OPCModules', 'OPCServers', 'OPCTags'
                      , 'OPCTagApplicationMapping', 'OPCServerApplicationMapping' )
ORDER BY  t.[name], i.[index_id];

SELECT    fk.[name]                              AS [ForeignKey]
        , OBJECT_NAME(fk.[parent_object_id])     AS [ChildTable]
        , OBJECT_NAME(fk.[referenced_object_id]) AS [ParentTable]
        , fk.[is_not_trusted]                    AS [IsNotTrusted]
FROM      sys.foreign_keys AS fk
WHERE     OBJECT_NAME(fk.[parent_object_id])
              IN ( 'OPCTagApplicationMapping', 'OPCServerApplicationMapping' )
ORDER BY  fk.[name];

DECLARE @Heaps INT, @PKs INT, @UQs INT, @FKs INT, @CKs INT, @IXs INT, @Untrusted INT;

SELECT    @Heaps = COUNT(*)
FROM      sys.tables AS t
          INNER JOIN sys.indexes AS i ON i.[object_id] = t.[object_id]
WHERE     t.[name] IN ( 'OPCModules', 'OPCServers', 'OPCTags'
                      , 'OPCTagApplicationMapping', 'OPCServerApplicationMapping' )
          AND i.[type_desc] = 'HEAP';

SELECT @PKs = COUNT(*) FROM sys.key_constraints   WHERE [name] LIKE 'PK[_]OPC%';
SELECT @UQs = COUNT(*) FROM sys.key_constraints   WHERE [name] LIKE 'UQ[_]OPC%';
SELECT @FKs = COUNT(*) FROM sys.foreign_keys      WHERE [name] LIKE 'FK[_]OPC%';
SELECT @CKs = COUNT(*) FROM sys.check_constraints WHERE [name] LIKE 'CK[_]OPC%';
SELECT @IXs = COUNT(*) FROM sys.indexes           WHERE [name] LIKE 'IX[_]OPC%';

SELECT    @Untrusted = COUNT(*)
FROM      sys.foreign_keys
WHERE     [name] LIKE 'FK[_]OPC%' AND [is_not_trusted] = 1;

PRINT '';
PRINT '   Heaps remaining     : ' + CAST(@Heaps     AS VARCHAR(10)) + '   (expected 0)';
PRINT '   Primary keys        : ' + CAST(@PKs       AS VARCHAR(10)) + '   (expected 5)';
PRINT '   Unique constraints  : ' + CAST(@UQs       AS VARCHAR(10)) + '   (expected 6)';
PRINT '   Foreign keys        : ' + CAST(@FKs       AS VARCHAR(10)) + '   (expected 4)';
PRINT '   Check constraints   : ' + CAST(@CKs       AS VARCHAR(10)) + '   (expected 1)';
PRINT '   Nonclustered indexes: ' + CAST(@IXs       AS VARCHAR(10)) + '   (expected 2)';
PRINT '   Untrusted FKs       : ' + CAST(@Untrusted AS VARCHAR(10)) + '   (expected 0)';

IF @Heaps = 0 AND @PKs = 5 AND @UQs = 6 AND @FKs = 4 AND @CKs = 1 AND @IXs = 2 AND @Untrusted = 0
    PRINT '   RESULT: all objects present and correct.';
ELSE
    PRINT '   RESULT: MISMATCH - review the two result sets above.';

PRINT '';
PRINT ' Finished: ' + CONVERT(VARCHAR(19), GETDATE(), 120);
PRINT '================================================================';
GO

SET NOEXEC OFF;
GO
