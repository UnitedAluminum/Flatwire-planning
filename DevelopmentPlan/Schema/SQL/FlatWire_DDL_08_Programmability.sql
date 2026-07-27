-- ============================================================
-- Flat Wire Mill — DDL Script 08: Programmability
-- Run order : 08 of 09  (run AFTER 07_Indexes)
-- Objects   : trg_CoilTraceability_NoOverlap (trigger),
--             sp_GetGaugeTrace, sp_ShiftSummary (read procs)
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
-- sp_ShiftSummary
-- Per-line shift aggregation (Dashboard 10). Phase-1 read stub —
-- returns throughput, coil count, SPC pass rate, WIP rejections,
-- and pause/downtime seconds for a line + shift window.
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[sp_ShiftSummary]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ShiftSummary];
GO

CREATE PROCEDURE [dbo].[sp_ShiftSummary]
    @LineId     VARCHAR(5),
    @ShiftStart DATETIMEOFFSET,
    @ShiftEnd   DATETIMEOFFSET
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @LineId AS LineId,
        @ShiftStart AS ShiftStart,
        @ShiftEnd   AS ShiftEnd,
        (SELECT COUNT(*)               FROM [dbo].[CoilOutput]
           WHERE [LineId] = @LineId AND [CompletedAt] >= @ShiftStart AND [CompletedAt] < @ShiftEnd)                     AS CoilsCompleted,
        (SELECT ISNULL(SUM([NetWeightLb]),0) FROM [dbo].[CoilOutput]
           WHERE [LineId] = @LineId AND [CompletedAt] >= @ShiftStart AND [CompletedAt] < @ShiftEnd)                     AS NetWeightLb,
        (SELECT ISNULL(SUM([FootageFt]),0)   FROM [dbo].[CoilOutput]
           WHERE [LineId] = @LineId AND [CompletedAt] >= @ShiftStart AND [CompletedAt] < @ShiftEnd)                     AS FootageFt,
        (SELECT COUNT(*)               FROM [dbo].[WipRejection]
           WHERE [LineId] = @LineId AND [Timestamp] >= @ShiftStart AND [Timestamp] < @ShiftEnd)                        AS WipRejections,
        (SELECT COUNT(*)               FROM [dbo].[SpcCheckpoint]
           WHERE [LineId] = @LineId AND [Timestamp] >= @ShiftStart AND [Timestamp] < @ShiftEnd)                        AS SpcCheckpoints,
        (SELECT ISNULL(SUM(CASE WHEN [AllInSpec] = 1 THEN 1 ELSE 0 END),0) FROM [dbo].[SpcCheckpoint]
           WHERE [LineId] = @LineId AND [Timestamp] >= @ShiftStart AND [Timestamp] < @ShiftEnd)                        AS SpcCheckpointsInSpec,
        (SELECT ISNULL(SUM(rp.[PauseDurationSeconds]),0)
           FROM [dbo].[RunPauseEvent] rp
           JOIN [dbo].[FlatWireRun] r ON r.[RunId] = rp.[RunId]
           WHERE r.[LineId] = @LineId AND rp.[PausedAt] >= @ShiftStart AND rp.[PausedAt] < @ShiftEnd)                  AS PauseSeconds;
END
GO

PRINT 'Created procedure: sp_ShiftSummary';
GO

-- ------------------------------------------------------------
-- Least-privilege EXECUTE grants (per-object, UAL convention).
-- ------------------------------------------------------------
IF DATABASE_PRINCIPAL_ID(N'ua_user') IS NOT NULL
BEGIN
    GRANT EXECUTE ON [dbo].[sp_GetGaugeTrace] TO [ua_user];
    GRANT EXECUTE ON [dbo].[sp_ShiftSummary]  TO [ua_user];
    PRINT 'Granted EXECUTE on read procedures to ua_user';
END
GO
