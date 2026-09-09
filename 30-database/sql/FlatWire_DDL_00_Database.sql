-- ============================================================
-- Flat Wire Mill — DDL Script 00: Database & Security
-- Run order : 00 of 09  (run FIRST, before all table scripts)
-- Creates   : FlatWireDB database + ua_user access
-- Dependencies: none
-- ============================================================
-- Per phase-01c-database-foundation.md, the flat-wire schema is
-- a NEW standalone database (FlatWireDB), not an extension of
-- united_db. Rod material remains mirrored in the shared legacy
-- `coils` table for planning/cost continuity (see §E of the
-- schema plan); rod-alpha FKs are enforced locally against the
-- FlatWireDB [Rod] table.
--
-- Idempotent: safe to re-run. CREATE DATABASE cannot run inside
-- a user transaction, so this script is deliberately standalone.
-- ============================================================

IF DB_ID(N'FlatWireDB') IS NULL
BEGIN
    CREATE DATABASE [FlatWireDB];
    PRINT 'Created database: FlatWireDB';
END
ELSE
    PRINT 'Database already exists: FlatWireDB';
GO

-- Recommended options for a transactional OLTP workload.
-- ⚠ BOTH ARE GUARDED, and that is what makes the "safe to re-run" claim above true.
--   READ_COMMITTED_SNAPSHOT ON carries WITH ROLLBACK IMMEDIATE, which KILLS EVERY OPEN
--   TRANSACTION in FlatWireDB. Unguarded, every RunAll re-run did that -- harmless on a
--   throwaway copy, not harmless on the shared instance this runner targets ([DEP 2]).
--   ALLOW_SNAPSHOT_ISOLATION ON has no rollback clause and instead BLOCKS until every open
--   transaction finishes, so an unguarded re-run could hang the deploy behind a live session.
-- Re-running now reads sys.databases and does nothing when the options are already set.
IF NOT EXISTS (SELECT 1 FROM sys.databases
               WHERE name = N'FlatWireDB' AND is_read_committed_snapshot_on = 1)
BEGIN
    ALTER DATABASE [FlatWireDB] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
    PRINT 'Set READ_COMMITTED_SNAPSHOT ON';
END
ELSE
    PRINT 'READ_COMMITTED_SNAPSHOT already ON - left alone (no rollback forced)';
GO
IF NOT EXISTS (SELECT 1 FROM sys.databases
               WHERE name = N'FlatWireDB' AND snapshot_isolation_state = 1)
BEGIN
    ALTER DATABASE [FlatWireDB] SET ALLOW_SNAPSHOT_ISOLATION ON;
    PRINT 'Set ALLOW_SNAPSHOT_ISOLATION ON';
END
ELSE
    PRINT 'ALLOW_SNAPSHOT_ISOLATION already ON - left alone (no blocking wait)';
GO

USE [FlatWireDB]
GO

-- ------------------------------------------------------------
-- Application login / user (least privilege).
-- ua_user is the shared UAL application account (see parent
-- CLAUDE.md connection string). Grants are limited to DML +
-- EXECUTE; DDL rights are reserved for deployment accounts.
-- ------------------------------------------------------------
IF SUSER_ID(N'ua_user') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'ua_user')
    BEGIN
        CREATE USER [ua_user] FOR LOGIN [ua_user];
        PRINT 'Created database user: ua_user';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.database_role_members rm
                   JOIN sys.database_principals r  ON rm.role_principal_id   = r.principal_id
                   JOIN sys.database_principals m  ON rm.member_principal_id  = m.principal_id
                   WHERE r.name = N'db_datareader' AND m.name = N'ua_user')
        ALTER ROLE [db_datareader] ADD MEMBER [ua_user];

    IF NOT EXISTS (SELECT 1 FROM sys.database_role_members rm
                   JOIN sys.database_principals r  ON rm.role_principal_id   = r.principal_id
                   JOIN sys.database_principals m  ON rm.member_principal_id  = m.principal_id
                   WHERE r.name = N'db_datawriter' AND m.name = N'ua_user')
        ALTER ROLE [db_datawriter] ADD MEMBER [ua_user];

    -- EXECUTE on all current + future stored procedures (schema-level grant).
    GRANT EXECUTE ON SCHEMA::[dbo] TO [ua_user];
    PRINT 'Granted db_datareader, db_datawriter, EXECUTE to ua_user';
END
ELSE
    PRINT 'Login [ua_user] not found on this server — skipping user/grant setup (create the login, then re-run).';
GO
