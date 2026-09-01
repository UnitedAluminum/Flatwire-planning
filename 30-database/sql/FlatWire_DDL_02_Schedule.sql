-- ============================================================================
-- FLAT WIRE MILL - DATABASE SCHEMA
-- Script 02 of 09 : Pass Schedule tables
-- ----------------------------------------------------------------------------
-- Project         : Flat Wire Mill Implementation - United Aluminum
-- Document type   : Database deployment script - ISSUED FOR CLIENT REVIEW
-- Version         : 1.1
-- Last updated    : August 27, 2026
-- Target database : FlatWireDB  (new and standalone; NOT united_db)
-- Creates         : PassSchedule, PassScheduleComponent, PassScheduleChangeLog
-- File encoding   : ASCII only, so the script loads identically under SQLCMD,
--                   SSMS and any text editor, whatever the code page.
-- ============================================================================
--
-- READING CONVENTION
--
--   [CONFIRMED]              Agreed with United Aluminum. Built as stated.
--   [PROPOSED]               Our design recommendation; please confirm at review.
--   [CLIENT INPUT REQUIRED]  We do not know this and will not assume it. Every
--                            instance is listed under OPEN POINTS, at the foot
--                            of this file.
--
-- ----------------------------------------------------------------------------
-- 1. WHAT A PASS SCHEDULE IS
-- ----------------------------------------------------------------------------
--
--   A pass schedule is the master configuration record for one flat wire
--   product on one line. It states the alloy, the route, the dimensional
--   targets and their tolerances, the line speed window and - one row per
--   station - which components are engaged and at what setting.
--
--   It is the highest-priority dependency on the flat wire floor. The operator
--   acknowledges a pass schedule at rod or spool check-in, and the system
--   pushes the PLC tag set FROM that schedule on acknowledgement. No run
--   starts without one.
--
-- ----------------------------------------------------------------------------
-- 2. THE THREE TABLES
-- ----------------------------------------------------------------------------
--
--   PassSchedule           The header. One row per schedule. Business key
--                          ScheduleId, format PS-{alloy}-{line}-{sequence},
--                          for example PS-1100-FL1-003.
--
--   PassScheduleComponent  The detail. One row per component station, in
--                          processing order. Successor to the legacy
--                          FlatLineSetup table.
--
--   PassScheduleChangeLog  Append-only audit trail: every override, every edit
--                          made after a schedule went Active, and every
--                          operator acknowledgement at check-in - who, when,
--                          old value, new value, reason.
--
-- ----------------------------------------------------------------------------
-- 3. THE EQUIPMENT THESE TABLES CONFIGURE                        [CONFIRMED]
-- ----------------------------------------------------------------------------
--
--   DB1, DB2   Wire drawing dies. Reduce rod diameter ahead of flattening.
--   FM1        12" flattening mill. Not bypassable.
--   EdgeSet    Edger tooling. Applies a Round or a Square edge.
--
--   FM2, the finishing mill on FL2, is THREE stands:
--     FM2_S1   8" finishing stand
--     FM2_S2   6" finishing stand
--     FM2_S3   6" finishing stand, the final stand. Cannot be bypassed.
--   Edgers are fitted at S2 and S3 only.
--
--   Component identifiers carry POSITION ONLY. Roll diameter is data, held in
--   Stand.RollDiameterIn (FM1 12.000; FM2 S1 8.000, S2 6.000, S3 6.000), so a
--   change of rolls never invalidates an identifier.
--
--   FL1 has no edger.                    [CLIENT INPUT REQUIRED - OPEN POINT 4]
--
-- ----------------------------------------------------------------------------
-- 4. SCOPE - THIS PHASE READS PASS SCHEDULES, IT DOES NOT AUTHOR THEM
-- ----------------------------------------------------------------------------
--
--   The tables are built here and the flat wire application reads them at
--   check-in to build the PLC push payload. It does not create, edit, approve
--   or list a pass schedule in this phase, and exposes no pass-schedule API
--   endpoint. Pass schedule authoring - the Pass Schedule Management and Pass
--   Schedule List screens - is a later phase.
--
--   Which system populates these tables in production is not yet settled.
--                                        [CLIENT INPUT REQUIRED - OPEN POINT 1]
--
-- ----------------------------------------------------------------------------
-- 5. RUN ORDER, DEPENDENCIES AND HOW TO RUN
-- ----------------------------------------------------------------------------
--
--   This script creates TABLES ONLY.
--     - The foreign keys to Stand, Drawer, Edger and AlloyProperty are created
--       by script 06, and the indexes by script 07, so that every constraint
--       is applied to empty tables and cannot fail on existing data.
--     - Script 01 (lookup and reference tables) must therefore run before this
--       one for ordering, even though nothing here references it directly.
--
--   Whole schema, in order. SQLCMD mode is required, because the runner uses
--   the :r include directive:
--
--       cd <this folder>
--       sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql
--
--   This script on its own:
--
--       sqlcmd -S "<server>" -E -C -i FlatWire_DDL_02_Schedule.sql
--
--   In SSMS: Query menu -> SQLCMD Mode, then Execute.
--
--   Deployment target: FlatWireDB must be created on the SAME SQL Server
--   instance as united_db, because a check-in writes FlatWireDB and the shared
--   schema inside ONE local transaction, with no distributed transaction
--   coordinator.
--
--   Idempotent: every object is guarded, so re-running this script against an
--   existing FlatWireDB reports what is already present and changes nothing.
--
-- ============================================================================

USE [FlatWireDB]
GO

-- These two settings must be ON for any session that later writes these tables.
-- Script 07 creates a FILTERED unique index on PassSchedule, and SQL Server
-- rejects inserts and updates against a filtered index unless QUOTED_IDENTIFIER
-- and ANSI_NULLS are ON. They are set here so that the whole build runs under
-- one consistent set of options.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- TABLE 1 of 3 : PassSchedule
-- ----------------------------------------------------------------------------
-- The header record. One row per pass schedule.
--
-- Defines what the product is (alloy, dimensional targets and tolerances),
-- where it is made (line and route) and how fast it may run. Only a schedule
-- in Active status may be selected at check-in; Draft and Inactive rows are
-- visible but cannot be run.
--
-- Status lifecycle                                                [CONFIRMED]
--   Draft     Being authored or trialled. Not selectable at check-in.
--   Active    Approved and in use. One per line and alloy - see below.
--   Inactive  Retired. Kept, never deleted, because historical runs point at
--             it and the traceability record must stay readable.
--
-- ONE ACTIVE SCHEDULE PER LINE AND ALLOY                           [PROPOSED]
--   Enforced by the filtered unique index UX_PassSchedule_OneActivePerLineAlloy
--   in script 07. Activating a second schedule for a line and alloy pair
--   therefore means demoting the incumbent first; the two cannot coexist.
--                                        [CLIENT INPUT REQUIRED - OPEN POINT 5]
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PassSchedule]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PassSchedule] (
        -- ---- identity ------------------------------------------------------
        [ScheduleId]         VARCHAR(30)    NOT NULL,   -- business key. Format PS-{alloy}-{line}-{seq}, e.g. PS-1100-FL1-003
        [Description]        VARCHAR(200)   NULL,       -- operator-facing one-line summary, shown on the check-in screen

        -- ---- what and where ------------------------------------------------
        [Alloy]              VARCHAR(10)    NOT NULL,   -- 1100 | 1350 | 3003 | 5052 | 6061. FK to AlloyProperty, added by script 06
        [LineId]             VARCHAR(5)     NOT NULL,   -- FL1 | FL2 | FL3
        [RouteMode]          VARCHAR(15)    NOT NULL,   -- Standalone = one line only; Hybrid = FL1 feeding FL2 continuously
        [Status]             VARCHAR(10)    NOT NULL,   -- Draft | Active | Inactive

        -- ---- output targets, all in inches ---------------------------------
        [TargetGauge]        DECIMAL(8,4)   NOT NULL,   -- target output thickness
        [GaugeTolerance]     DECIMAL(8,4)   NOT NULL,   -- permitted deviation either side of TargetGauge
        [TargetWidth]        DECIMAL(8,4)   NOT NULL,   -- target output width
        [WidthTolerance]     DECIMAL(8,4)   NOT NULL,   -- permitted deviation either side of TargetWidth

        -- ---- expected input material ---------------------------------------
        -- These describe the rod the schedule is written for. On a schedule fed
        -- by a spool rather than by rod, they describe the rod that produced
        -- that spool upstream; they are not a statement that the line draws rod.
        [InputRodDiameterIn] DECIMAL(8,4)   NULL,       -- expected rod diameter, e.g. 0.3750
        [InputTemper]        VARCHAR(10)    NULL,       -- e.g. H14, H18, H19, H34, T8
        [InputCondition]     VARCHAR(50)    NULL,       -- e.g. Hard drawn, Strain hardened, Solution treated

        -- ---- operating window, feet per minute -----------------------------
        [LineSpeedMinFpm]    INT            NOT NULL,
        [LineSpeedMaxFpm]    INT            NOT NULL,

        -- ---- current use ---------------------------------------------------
        [ActiveJobId]        VARCHAR(20)    NULL,       -- order or job currently running this schedule; drives the "in use" chip on screen. NULL when idle. See OPEN POINT 6

        -- ---- audit ---------------------------------------------------------
        [CreatedBy]          VARCHAR(50)    NOT NULL,
        [CreatedAt]          DATETIMEOFFSET NOT NULL CONSTRAINT [DF_PassSchedule_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [ModifiedBy]         VARCHAR(50)    NULL,
        [ModifiedAt]         DATETIMEOFFSET NULL,
        [RowVersion]         ROWVERSION     NOT NULL,   -- concurrency token: two people editing one schedule cannot silently overwrite each other

        CONSTRAINT [PK_PassSchedule]           PRIMARY KEY CLUSTERED ([ScheduleId] ASC),

        -- A schedule is either for one line on its own, or for FL1 feeding FL2.
        CONSTRAINT [CK_PassSchedule_RouteMode] CHECK ([RouteMode] IN ('Standalone', 'Hybrid')),
        -- Only Active schedules may be selected at check-in.
        CONSTRAINT [CK_PassSchedule_Status]    CHECK ([Status]    IN ('Draft', 'Active', 'Inactive')),
        -- The three flattening lines.
        CONSTRAINT [CK_PassSchedule_LineId]    CHECK ([LineId]    IN ('FL1', 'FL2', 'FL3')),
        -- The speed window must be a window, not a point or an inversion.
        CONSTRAINT [CK_PassSchedule_Speed]     CHECK ([LineSpeedMinFpm] < [LineSpeedMaxFpm]),
        -- A zero tolerance would put every reading out of spec, so both must be positive.
        CONSTRAINT [CK_PassSchedule_GaugeTol]  CHECK ([GaugeTolerance] > 0),
        CONSTRAINT [CK_PassSchedule_WidthTol]  CHECK ([WidthTolerance] > 0)
    );
    PRINT 'Created table: PassSchedule';
END
ELSE
    PRINT 'Table already exists: PassSchedule';
GO

-- ============================================================================
-- TABLE 2 of 3 : PassScheduleComponent
-- ----------------------------------------------------------------------------
-- The detail rows. One row per component station on the line, in processing
-- order. Successor to the legacy FlatLineSetup table.
--
-- Each row answers three questions about one station: is it engaged, which
-- physical tool is fitted, and at what setting.
--
-- State - three values, never a yes/no                            [CONFIRMED]
--   Active  Engaged. ParameterValue and the tool reference are set.
--   Bypass  The component exists on this line but is wired out of the pass.
--   Skip    The component is not part of this schedule at all.
--   The distinction matters on the floor: Bypass is a threading decision the
--   operator can see at the machine, Skip is a product decision.
--
-- ParameterValue - meaning depends on the component               [CONFIRMED]
--   DB1, DB2            die hole diameter, inches
--   FM1, FM2_S1..S3     roll gap set-point, inches
--   EdgeSet             edger clearance, inches
--   NULL whenever the component is not Active.
--
-- Tool reference - exactly one of the three is populated on an Active row
--   StandId   -> Stand    for FM1 and the FM2 stands
--   DrawerId  -> Drawer   for DB1 and DB2
--   EdgerId   -> Edger    for EdgeSet
--   All three foreign keys are created by script 06.
--
-- EntryGauge and ExitGauge are informational: the calculated gauge entering
-- and leaving the station. They let the gauge chain be read down a schedule
-- and reconciled against the header's TargetGauge.
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PassScheduleComponent]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PassScheduleComponent] (
        [Id]             INT          NOT NULL IDENTITY(1,1),
        [PassScheduleId] VARCHAR(30)  NOT NULL,   -- owning schedule. FK to PassSchedule.ScheduleId, added by script 06
        [ComponentName]  VARCHAR(20)  NOT NULL,   -- DB1 | DB2 | FM1 | EdgeSet | FM2_S1 | FM2_S2 | FM2_S3
        [State]          VARCHAR(10)  NOT NULL,   -- Active | Bypass | Skip
        [ParameterValue] DECIMAL(8,4) NULL,       -- die diameter, roll gap or edger clearance, in inches; NULL unless Active
        [EdgeType]       VARCHAR(10)  NULL,       -- Round | Square. Edger components only
        [Sequence]       INT          NOT NULL,   -- processing order within the schedule, 1 upwards
        [IsMandatory]    BIT          NOT NULL CONSTRAINT [DF_PSC_IsMandatory] DEFAULT (0),  -- when 1, the screen locks the component and the operator cannot switch it off
        [StandId]        INT          NULL,       -- fitted stand. FK to Stand.Id, added by script 06
        [DrawerId]       INT          NULL,       -- fitted die.   FK to Drawer.Id, added by script 06
        [EdgerId]        INT          NULL,       -- fitted edger. FK to Edger.Id, added by script 06
        [EntryGauge]     DECIMAL(8,4) NULL,       -- calculated gauge entering this station, inches; informational
        [ExitGauge]      DECIMAL(8,4) NULL,       -- calculated gauge leaving this station, inches; informational
        [SetupNo]        VARCHAR(20)  NULL,       -- legacy setup number carried over from FlatLineSetup, for historical traceability

        CONSTRAINT [PK_PassScheduleComponent]          PRIMARY KEY CLUSTERED ([Id] ASC),
        -- No two components may occupy the same position in one schedule.
        CONSTRAINT [UQ_PassScheduleComponent_Sequence] UNIQUE ([PassScheduleId], [Sequence]),

        -- The complete station vocabulary. FM2 is three stands - S1 (8"),
        -- S2 (6") and S3 (6", final) - identified by position, with roll
        -- diameter held as data in Stand.RollDiameterIn.
        CONSTRAINT [CK_PSC_ComponentName]    CHECK ([ComponentName] IN ('DB1','DB2','FM1','EdgeSet','FM2_S1','FM2_S2','FM2_S3')),
        CONSTRAINT [CK_PSC_State]            CHECK ([State]         IN ('Active', 'Bypass', 'Skip')),
        CONSTRAINT [CK_PSC_EdgeType]         CHECK ([EdgeType]      IN ('Round', 'Square') OR [EdgeType] IS NULL),

        -- A setting may only be recorded against a component that is engaged,
        -- so a bypassed station cannot carry a stale set-point.
        CONSTRAINT [CK_PSC_ParamValue]       CHECK ([State] = 'Active' OR [ParameterValue] IS NULL),

        -- An engaged edger must say which edge it applies.
        CONSTRAINT [CK_PSC_EdgeTypeReq]      CHECK ([ComponentName] <> 'EdgeSet' OR [State] <> 'Active' OR [EdgeType] IS NOT NULL),

        -- The flattening mill is not bypassable, so no schedule may switch it
        -- off.                             [CLIENT INPUT REQUIRED - OPEN POINT 3]
        CONSTRAINT [CK_PSC_FM1NotBypassable] CHECK ([ComponentName] <> 'FM1' OR [State] = 'Active')
    );
    PRINT 'Created table: PassScheduleComponent';
END
ELSE
    PRINT 'Table already exists: PassScheduleComponent';
GO

-- ============================================================================
-- TABLE 3 of 3 : PassScheduleChangeLog
-- ----------------------------------------------------------------------------
-- Append-only audit trail. One row per change. Nothing in it is ever updated
-- or deleted.
--
-- It records three kinds of event                                 [CONFIRMED]
--   Override         A setting changed for one run only, without altering the
--                    schedule itself - typically die wear or SPC drift.
--   Edit             A change to the schedule after it went Active.
--   Acknowledgment   A check-in: the operator accepted this schedule for a
--                    run. ParameterName, OldValue and NewValue are NULL,
--                    because the whole schedule is what was acknowledged.
--
-- OldValue and NewValue are text and unit-agnostic on purpose: one column pair
-- has to carry a die size, a roll gap, an edge type and a status.
--
-- RunId is a soft reference. It is deliberately NOT a foreign key, so that a
-- change made outside any run - the normal case for an Edit - can still be
-- recorded.
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PassScheduleChangeLog]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[PassScheduleChangeLog] (
        [Id]             INT            NOT NULL IDENTITY(1,1),
        [PassScheduleId] VARCHAR(30)    NOT NULL,   -- schedule the change was made to. FK to PassSchedule.ScheduleId, added by script 06
        [ChangeType]     VARCHAR(20)    NOT NULL,   -- Override | Edit | Acknowledgment
        [ParameterName]  VARCHAR(50)    NULL,       -- what changed, e.g. FM1.RollGap or DB2.Die. NULL on an acknowledgment
        [OldValue]       VARCHAR(100)   NULL,       -- value before the change, as text
        [NewValue]       VARCHAR(100)   NULL,       -- value after the change, as text
        [ReasonCode]     VARCHAR(50)    NULL,       -- DieWear | SpcDrift | OrderSpec | ProcessUpdate | CampaignStart. See OPEN POINT 2
        [ReasonNotes]    VARCHAR(500)   NULL,       -- free text entered by the operator
        [RunId]          VARCHAR(20)    NULL,       -- run in progress when the change was made; NULL when made outside a run
        [OperatorId]     VARCHAR(50)    NOT NULL,   -- who made the change
        [Timestamp]      DATETIMEOFFSET NOT NULL CONSTRAINT [DF_PSChangeLog_Timestamp] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_PassScheduleChangeLog]  PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_PSChangeLog_ChangeType] CHECK ([ChangeType] IN ('Override','Edit','Acknowledgment'))
    );
    PRINT 'Created table: PassScheduleChangeLog';
END
ELSE
    PRINT 'Table already exists: PassScheduleChangeLog';
GO

PRINT 'Script 02 of 09 (Pass Schedule tables) complete.';
GO

-- ============================================================================
-- OPEN POINTS - FOR CONFIRMATION AT REVIEW
-- ============================================================================
--
-- 1. WHO POPULATES THESE TABLES IN PRODUCTION
--    This phase reads pass schedules and never authors them, so a schedule has
--    to arrive from somewhere before the first production check-in. The design
--    assumes the owning system writes directly into FlatWireDB. Please confirm
--    which system that is, and when it will be available.
--
-- 2. CHANGE REASON CODES
--    ReasonCode is free text today, with five values in use: DieWear,
--    SpcDrift, OrderSpec, ProcessUpdate and CampaignStart. Please confirm the
--    list is complete. If it is, we will move it to a lookup table, so that
--    the screen can offer a fixed set and reporting can group on it reliably.
--
-- 3. FM1 ON AN FL2 SCHEDULE
--    CK_PSC_FM1NotBypassable enforces "the flattening mill is not bypassable"
--    on every schedule, without regard to line. An FL2 standalone schedule is
--    fed an already-flattened spool, so the 12" mill on FL1 is not in its
--    material path at all - yet the rule still forces an Active FM1 row on it.
--    Please confirm whether an FL2 standalone schedule should be allowed to
--    mark FM1 as not applicable. If so, we will narrow the rule to the lines
--    that carry FM1.
--
-- 4. THE EDGER MODEL
--    Two questions, both about EdgeSet:
--      (a) FL1 has no edger, but the model allows an FL1 schedule to carry an
--          Active EdgeSet row, and the sample data uses one. Please confirm
--          how the edge condition of an FL1 product should be recorded.
--      (b) FM2 has edgers at S2 and S3, but a schedule carries a single
--          EdgeSet row. Please confirm whether the two positions are always
--          set the same, or whether they need to be configured separately.
--
-- 5. ONE ACTIVE SCHEDULE PER LINE AND ALLOY
--    The design allows exactly one Active schedule for a given line and alloy
--    at a time, so activating a replacement demotes the incumbent. Please
--    confirm this matches how the floor works, and that no line ever needs two
--    approved schedules for one alloy at the same time.
--
-- 6. ActiveJobId
--    This column names the order or job currently running the schedule, and
--    drives the "in use" indicator on screen. Please confirm which identifier
--    belongs in it - the customer order number, the internal job number, or
--    the coil order plan reference.
--
-- ============================================================================
