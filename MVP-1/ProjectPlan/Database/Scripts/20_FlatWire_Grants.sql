/*==============================================================================================
  Project      : UAL Flat Wire Mill - Shopfloor
  Script       : 20_FlatWire_Grants.sql
  Target DBs   : united_db, proddb, CommonDB, SlitterDB, wiplogdb, FlatWireDB
  Last Updated : 2026-08-19
  Status       : Draft - run once per environment. Step 3 of 10 ([DEP 4.2]): after the schema and
                 the WIP-station rows, before the procedures are first EXECUTED.
                 (Section 1 below says "run this FIRST" -- that refers to the CO-LOCATION CHECK,
                  which is step 0. The two are not in conflict; the wording used to suggest they were.)
  Story        : FW-220 / FW-221 (extends FW-144's configuration work)
  Specification: MVP-1/ProjectPlan/Architecture/Integration.md Sec 8.0 / Sec 8.1

  PURPOSE
  -------
  Gives the application account the cross-database reach the flat wire procedures need.

  FW-219 Sec 3 asks for this in one clause - "extend FW-144's configuration with read/write
  grants on proddb, united_db, SlitterDB, CommonDB" - and nobody had written it down. Without
  it the procedures compile and then fail at run time on the FIRST cross-database statement,
  which in FlatWire_CheckInRod is step 3 and in FlatWire_CompleteCoilOnSkid is step 4. The error
  is a permission error on a three-part name, which reads like a missing object and sends people
  looking in the wrong place.

  WHY THIS IS NEEDED AT ALL, GIVEN EVERY PROCEDURE GRANTS TO [public]
  -------------------------------------------------------------------
  The UAL convention is GRANT EXECUTE ... TO [public], and the flat wire procedures follow it.
  But [public] membership is PER DATABASE: it grants nothing in a database where the login has
  no user. So the work here is not really granting - it is making sure the account EXISTS as a
  user in all six databases. The explicit role memberships are what make the permission set
  reviewable rather than implied.

  *** OWNERSHIP CHAINING IS NOT RELIED ON. *** Cross-database ownership chaining would remove
  the need for most of this, but it is off by default, it is a server- or database-level setting
  this project does not own, and turning it on to make flat wire work would change the security
  posture of every other module on the instance. Explicit users and role memberships instead.

  WHY EVERY BLOCK IS DYNAMIC SQL, WHICH LOOKS LIKE OVER-ENGINEERING AND IS NOT
  ---------------------------------------------------------------------------
  USE cannot be made conditional. A plain

      IF DB_ID(N'FlatWireDB') IS NOT NULL BEGIN ... END
      GO
      USE [FlatWireDB];

  still executes the USE, and on an instance where that database is absent the batch fails with
  Msg 911 and everything after it is skipped. The first draft of this script did exactly that,
  and its own header claimed absent databases were "skipped with a message" - which was false,
  and was caught by running it. USE inside sp_executesql is scoped to the dynamic batch, so the
  loop below is the shortest correct form: one template, six databases, and a genuinely skipped
  database when one is missing.

  This matters because the script is expected to be run on a developer instance that has some of
  the six and not others.

  IDEMPOTENT. Safe to re-run.

  RUN ORDER
  ---------
      This script is STEP 3 OF 10. The full cross-folder sequence has ONE home and it is not here:

          [DEP 4.2]  --  MVP-1/ProjectPlan/Operations/Deployment.md, section 4.2

      A four-step copy used to live at this spot. It omitted all four united_db procedures, the
      seed step and the verification gate, so it drifted -- which is exactly the argument for one
      home. See also ./README.md for this folder's manifest and sign-off state.

      What matters locally: the schema (step 1) and the WIP-station rows (step 2) come BEFORE this
      script, and all five procedures come after. Step 2 is a SIGN-OFF GATE with no reverse script.

  All five are CROSS-DATABASE and all five need the grants above. sp_IngestRodFromCoils lives in
  FlatWireDB rather than united_db, but it belongs to this step and not to the schema runner for
  exactly that reason: it reads proddb..coils and united_db..alloys, so a FlatWireDB-only deploy
  cannot verify it.

  *** FlatWireDB MUST BE ON THE SAME INSTANCE as united_db / proddb / SlitterDB / CommonDB /
  wiplogdb. *** The whole check-in transaction model depends on it: one SqlConnection with one
  SqlTransaction spans both halves under the LOCAL transaction manager, with no MSDTC. The
  deploy snippet in CLAUDE.md shows (localdb)\MSSQLLocalDB, which is a DEVELOPER CONVENIENCE and
  is not this topology - LocalDB has no united_db. Section 1 below reports co-location; if it
  warns, stop and move FlatWireDB before relying on anything downstream.
==============================================================================================*/

SET NOCOUNT ON;
GO

PRINT '=== FlatWire_Grants: start ===';
GO

/*----------------------------------------------------------------------------------------------
  0. Configuration - the one place to change the account.
----------------------------------------------------------------------------------------------*/
DECLARE @AppLogin SYSNAME = N'ua_user';

/*----------------------------------------------------------------------------------------------
  1. Pre-flight. Both checks are cheap, so both run before anything is granted.
----------------------------------------------------------------------------------------------*/
IF SUSER_ID(@AppLogin) IS NULL
BEGIN
    RAISERROR('ABORT: the application login does not exist on this server. Create it, then re-run.', 16, 1);
    RETURN;
END

DECLARE @targets TABLE
(
      [name]     SYSNAME PRIMARY KEY
    , [needExec] BIT     NOT NULL          -- EXECUTE on dbo is needed wherever a procedure is called
    , [note]     VARCHAR(200) NOT NULL
);

INSERT INTO @targets ([name], [needExec], [note])
VALUES ( N'united_db' , 1, 'procedure home; routings, planning_routings, the order reference tables, the audit tables' )
     , ( N'proddb'    , 1, 'coils, wip_coil_orders, wip_skid_coils, wip_log_view. DELETE is used here and only here (Q40)' )
     , ( N'CommonDB'  , 1, 'WIPStations, and the helper procedures both ends of the run call' )
     , ( N'SlitterDB' , 1, 'coil_slit_cuts, at coil completion only - flat wire does not slit' )
     , ( N'wiplogdb'  , 0, 'reached only through proddb..wip_log_view, but permissions check the BASE table' )
     , ( N'FlatWireDB', 1, 'already handled by FlatWire_DDL_00_Database.sql; re-asserted so one script shows the whole surface' );

DECLARE @missing NVARCHAR(1000) = N'';

SELECT @missing = @missing + [name] + N' '
FROM   @targets
WHERE  DB_ID([name]) IS NULL;

IF @missing <> N''
BEGIN
    PRINT '';
    PRINT '*** WARNING: these databases are not on this instance: ' + @missing;
    PRINT '*** The flat wire check-in transaction model REQUIRES all six on ONE instance.';
    PRINT '*** If this is a developer LocalDB, deploy FlatWireDB to the shared instance instead.';
    PRINT '*** They are SKIPPED below, not failed - but the design is not atomic without them.';
    PRINT '';
END
ELSE
    PRINT 'Co-location confirmed: all six databases are on this instance.';

/*----------------------------------------------------------------------------------------------
  2. Apply, one database at a time. USE is inside the dynamic batch, so a missing database is
     genuinely skipped instead of aborting the script - see the header.
----------------------------------------------------------------------------------------------*/
DECLARE @db       SYSNAME
      , @needExec BIT
      , @note     VARCHAR(200)
      , @sql      NVARCHAR(MAX)
      , @lit      NVARCHAR(300)            -- the login as a quoted string literal
      , @qn       NVARCHAR(300);           -- the login as a quoted identifier

SET @lit = N'N''' + REPLACE(@AppLogin, N'''', N'''''') + N'''';
SET @qn  = QUOTENAME(@AppLogin);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT [name], [needExec], [note] FROM @targets ORDER BY [name];

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db, @needExec, @note;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF DB_ID(@db) IS NULL
    BEGIN
        PRINT 'SKIP ' + @db + ' - not on this instance';
    END
    ELSE
    BEGIN
        PRINT @db + ' ...';
        PRINT '  (' + @note + ')';

        SET @sql =
            N'USE ' + QUOTENAME(@db) + N';' + NCHAR(13) + NCHAR(10) +

            N'IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ' + @lit + N')' + NCHAR(13) + NCHAR(10) +
            N'BEGIN' + NCHAR(13) + NCHAR(10) +
            N'    CREATE USER ' + @qn + N' FOR LOGIN ' + @qn + N';' + NCHAR(13) + NCHAR(10) +
            N'    PRINT ''  created user'';' + NCHAR(13) + NCHAR(10) +
            N'END' + NCHAR(13) + NCHAR(10) +

            N'IF NOT EXISTS (SELECT 1 FROM sys.database_role_members rm' + NCHAR(13) + NCHAR(10) +
            N'               JOIN sys.database_principals r ON rm.role_principal_id   = r.principal_id' + NCHAR(13) + NCHAR(10) +
            N'               JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id' + NCHAR(13) + NCHAR(10) +
            N'               WHERE r.name = N''db_datareader'' AND m.name = ' + @lit + N')' + NCHAR(13) + NCHAR(10) +
            N'    ALTER ROLE [db_datareader] ADD MEMBER ' + @qn + N';' + NCHAR(13) + NCHAR(10) +

            N'IF NOT EXISTS (SELECT 1 FROM sys.database_role_members rm' + NCHAR(13) + NCHAR(10) +
            N'               JOIN sys.database_principals r ON rm.role_principal_id   = r.principal_id' + NCHAR(13) + NCHAR(10) +
            N'               JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id' + NCHAR(13) + NCHAR(10) +
            N'               WHERE r.name = N''db_datawriter'' AND m.name = ' + @lit + N')' + NCHAR(13) + NCHAR(10) +
            N'    ALTER ROLE [db_datawriter] ADD MEMBER ' + @qn + N';' + NCHAR(13) + NCHAR(10);

        -- Schema-level EXECUTE covers every helper the flat wire procedures call, now and in
        -- future. wiplogdb needs none: nothing executes a procedure there, the WIP log is
        -- written through proddb..wip_log_view.
        IF @needExec = 1
            SET @sql = @sql + N'GRANT EXECUTE ON SCHEMA::[dbo] TO ' + @qn + N';' + NCHAR(13) + NCHAR(10);

        -- db_datawriter already covers DELETE, but the flat wire DELETE is a decision with an
        -- open sign-off (Q40, FlatWire_ReverseReqsum) and naming it makes the permission
        -- auditable rather than incidental.
        IF @db = N'proddb'
            SET @sql = @sql +
                N'IF OBJECT_ID(N''dbo.wip_coil_orders'', N''U'') IS NOT NULL' + NCHAR(13) + NCHAR(10) +
                N'    GRANT DELETE ON [dbo].[wip_coil_orders] TO ' + @qn + N';' + NCHAR(13) + NCHAR(10);

        SET @sql = @sql + N'PRINT ''  roles and grants applied'';';

        EXEC sys.sp_executesql @sql;
    END

    FETCH NEXT FROM db_cursor INTO @db, @needExec, @note;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
GO

PRINT '=== FlatWire_Grants: done ===';
GO

/*==============================================================================================
  VERIFICATION
  ---------------------------------------------------------------------------------------------
  1. CO-LOCATION AND ISOLATION. Run this FIRST, before anything else in the flat wire build.
     SIX rows, or the one-transaction check-in model is not available on this instance.

     The second column is the isolation baseline the procedures' header blocks refer to.
     MEASURED on DEVUAL-UADEV001\TEST1, 19 Aug 2026 - the split is NOT uniform, and not where
     the WITH (NOLOCK) hints scattered through the legacy code would lead you to guess:

         united_db 1 | proddb 1 | wiplogdb 1 | CommonDB 0 | SlitterDB 0 | FlatWireDB 1

     CommonDB is the one that matters at check-in: the WIPStations claim takes LOCKING reads
     while everything else in the same transaction takes snapshot reads. SlitterDB is its
     counterpart at coil completion.

     SELECT name, database_id, is_read_committed_snapshot_on, snapshot_isolation_state
     FROM   sys.databases
     WHERE  name IN ('FlatWireDB','united_db','proddb','SlitterDB','CommonDB','wiplogdb')
     ORDER BY name;

  2. THE USER EXISTS EVERYWHERE. Six rows - a missing one becomes a run-time permission error on
     a three-part name, which reads like a missing object.

     SELECT 'FlatWireDB' AS db, name FROM FlatWireDB.sys.database_principals WHERE name = 'ua_user'
     UNION ALL SELECT 'united_db', name FROM united_db.sys.database_principals WHERE name = 'ua_user'
     UNION ALL SELECT 'proddb',    name FROM proddb.sys.database_principals    WHERE name = 'ua_user'
     UNION ALL SELECT 'CommonDB',  name FROM CommonDB.sys.database_principals  WHERE name = 'ua_user'
     UNION ALL SELECT 'SlitterDB', name FROM SlitterDB.sys.database_principals WHERE name = 'ua_user'
     UNION ALL SELECT 'wiplogdb',  name FROM wiplogdb.sys.database_principals  WHERE name = 'ua_user';

  3. THE REAL TEST - impersonate and touch one object in each database. This catches the case
     where the user exists but a role membership did not take.

     EXECUTE AS LOGIN = 'ua_user';
       SELECT TOP 1 'coils'           AS obj, coil_no    FROM proddb..coils;
       SELECT TOP 1 'WIPStations'     AS obj, WIPStation FROM CommonDB..WIPStations;
       SELECT TOP 1 'routings'        AS obj, coil_no    FROM united_db..routings;
       SELECT TOP 1 'coil_slit_cuts'  AS obj, coil_no    FROM SlitterDB..coil_slit_cuts;
       SELECT TOP 1 'wip_log'         AS obj, coil_no    FROM proddb..wip_log_view;
     REVERT;

  4. NO MSDTC. With a transaction open across both halves this must show ONE local transaction.

     BEGIN TRAN;
       SELECT TOP 1 * FROM FlatWireDB.dbo.Rod;
       SELECT TOP 1 * FROM proddb.dbo.coils;
       SELECT is_local FROM sys.dm_tran_current_transaction;    -- expect 1
     ROLLBACK;
==============================================================================================*/
