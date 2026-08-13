-- ============================================================
-- Flat Wire Mill (MVP-2) — DDL 08b: MVP-2 programmability
-- Run order : 08b of 06 (MVP-2 chain)
-- Scope     : MVP-2 (deferred). NOT part of MVP-1.
-- ============================================================
-- Split out of FlatWire_DDL_08_Programmability.sql on 11 Aug 2026 when the schema was
-- divided by MVP scope. trg_CoilTraceability_NoOverlap (DM010, CoilTraceability) and sp_ShiftSummary (DB10). sp_GetGaugeTrace stays in MVP-1.
--
-- PREREQUISITE: the whole MVP-1 chain must already be deployed
-- (00_Database .. 08_Programmability under MVP-1/ProjectPlan/Database).
-- These objects are ADDITIVE on top of it.
-- ============================================================

USE [FlatWireDB]
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
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