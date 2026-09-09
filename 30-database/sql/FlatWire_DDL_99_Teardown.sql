-- ============================================================
-- Flat Wire Mill — Teardown (DESTRUCTIVE)
-- ============================================================
-- Drops the entire FlatWireDB database so it can be rebuilt from
-- scratch via FlatWire_DDL_RunAll.sql. Intended for DEV/TEST only.
--
--   !!  THIS PERMANENTLY DELETES ALL FLAT WIRE DATA  !!
--
-- Guarded: no-op if FlatWireDB does not exist. Forces a single-user
-- rollback of open connections before dropping.
--
--   sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql
-- ============================================================

-- ⚠ USE [master] FIRST. Every other script in this folder opens USE [FlatWireDB]; this is the
-- one that needs the opposite. SET SINGLE_USER WITH ROLLBACK IMMEDIATE evicts OTHER sessions but
-- never the caller's own, so running this from a session whose current database is FlatWireDB --
-- the normal case straight after RunAll in the same SSMS window -- failed with Msg 3702,
-- "Cannot drop database ... because it is currently in use."
USE [master];
GO

IF DB_ID(N'FlatWireDB') IS NOT NULL
BEGIN
    PRINT 'Dropping database FlatWireDB ...';
    ALTER DATABASE [FlatWireDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [FlatWireDB];
    PRINT 'FlatWireDB dropped.';
END
ELSE
    PRINT 'FlatWireDB does not exist — nothing to drop.';
GO
