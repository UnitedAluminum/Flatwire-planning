-- ============================================================
-- Flat Wire Mill — DDL Script 08: Programmability
-- Run order : 08 of 09  (run AFTER 07_Indexes)
-- Objects   : trg_CoilTraceability_NoOverlap (trigger),
--             sp_GetGaugeTrace (read proc)
--
-- sp_ShiftSummary is NOT here -- it belongs to Dashboard 10, which
-- is MVP-2, and lives in MVP-2/DBChanges/Schema/SQL/
-- FlatWire_DDL_08b_Programmability.sql. This script must not drop,
-- create or grant on it; doing so from an MVP-1 deploy would delete
-- an object this scope does not own.
-- ============================================================
-- SQL Server has no exclusion constraint, so the "footage ranges
-- within one coil must not overlap" rule (DM010) is enforced by
-- a trigger. Read-heavy paths (gauge trace, shift summary) use
-- stored procedures per UAL convention (Dapper reads).
-- All objects use IF EXISTS…DROP…CREATE so the script is
-- idempotent / re-runnable.
-- ============================================================

USE [FlatWireDB]
GO

-- Required for triggers/procs on tables with computed columns and filtered indexes.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ------------------------------------------------------------
-- trg_CoilTraceability_NoOverlap
-- Rejects any INSERT/UPDATE that makes two footage ranges of the
-- SAME coil overlap. Ranges are treated as half-open [From, To):
-- a and b overlap when a.From < b.To AND b.From < a.To.
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[trg_CoilTraceability_NoOverlap]', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[trg_CoilTraceability_NoOverlap];
GO

-- ------------------------------------------------------------
-- sp_GetGaugeTrace
-- Paged gauge/width trace for a run (Dashboard 3 / 14 and the
-- Gauge-Trace report). Returns sampled RunReading rows in a
-- footage window plus the weld markers that fall in that window.
-- Phase-1 read stub — resolution/decimation to be tuned at trial.
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[sp_GetGaugeTrace]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetGaugeTrace];
GO

CREATE PROCEDURE [dbo].[sp_GetGaugeTrace]
    @RunId      VARCHAR(20),
    @FromFt     DECIMAL(10,2) = 0,
    @ToFt       DECIMAL(10,2) = NULL,   -- NULL = to end of run
    @Resolution INT           = 1       -- return every Nth reading (decimation)
AS
BEGIN
    SET NOCOUNT ON;

    IF @ToFt IS NULL
        SELECT @ToFt = MAX([FootageFt]) FROM [dbo].[RunReading] WHERE [RunId] = @RunId;

    -- Readings (decimated by @Resolution via ROW_NUMBER on footage order)
    ;WITH ordered AS (
        SELECT [FootageFt], [GaugeIn], [WidthIn], [SpeedFpm], [InSpec], [ReadingTs],
               ROW_NUMBER() OVER (ORDER BY [FootageFt]) AS rn
        FROM [dbo].[RunReading]
        WHERE [RunId] = @RunId
          AND [FootageFt] >= @FromFt
          AND [FootageFt] <= @ToFt
    )
    SELECT [FootageFt], [GaugeIn], [WidthIn], [SpeedFpm], [InSpec], [ReadingTs]
    FROM ordered
    WHERE @Resolution <= 1 OR (rn - 1) % @Resolution = 0
    ORDER BY [FootageFt];

    -- Weld markers within the window (second result set)
    SELECT [WeldEventId], [FootagePosition], [OutgoingRodAlpha], [IncomingRodAlpha],
           [WeldType], [WeldQuality], [Timestamp]
    FROM [dbo].[WeldEvent]
    WHERE [RunId] = @RunId
      AND [FootagePosition] >= @FromFt
      AND [FootagePosition] <= @ToFt
    ORDER BY [FootagePosition];
END
GO

PRINT 'Created procedure: sp_GetGaugeTrace';
GO

-- ------------------------------------------------------------
-- sp_ShiftSummary — deliberately absent (MVP-2).
--
-- Until 11 Aug 2026 this script DROPPED sp_ShiftSummary and then
-- PRINTed "Created procedure: sp_ShiftSummary" without ever
-- creating it: the procedure moved to MVP-2's 08b with Dashboard 10
-- but its drop, its PRINT and its GRANT were left behind. Three
-- consequences, all now fixed by removing them --
--   * the deploy log claimed an object that was never created;
--   * running this script AFTER MVP-2's runner DELETED MVP-2's
--     procedure, silently;
--   * the GRANT below failed on any server where ua_user exists.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- Least-privilege EXECUTE grants (per-object, UAL convention).
-- ------------------------------------------------------------
IF DATABASE_PRINCIPAL_ID(N'ua_user') IS NOT NULL
BEGIN
    GRANT EXECUTE ON [dbo].[sp_GetGaugeTrace] TO [ua_user];
    -- No grant for sp_ShiftSummary: it is MVP-2's object (see above).
    PRINT 'Granted EXECUTE on read procedures to ua_user';
END
GO



CREATE TRIGGER [dbo].[trg_CoilTraceability_NoOverlap]
ON [dbo].[CoilTraceability]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM [dbo].[CoilTraceability] ct
        JOIN [dbo].[CoilTraceability] other
          ON  other.[CoilAlpha] = ct.[CoilAlpha]
          AND other.[Id]       <> ct.[Id]
          AND ct.[FootageFrom]  < other.[FootageTo]
          AND other.[FootageFrom] < ct.[FootageTo]
        JOIN inserted i ON i.[Id] = ct.[Id]
    )
    BEGIN
        RAISERROR (N'CoilTraceability footage ranges within a coil must not overlap (DM010).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

PRINT 'Created trigger: trg_CoilTraceability_NoOverlap';
GO
