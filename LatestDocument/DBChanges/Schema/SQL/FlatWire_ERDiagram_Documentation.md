# FlatWire Database - Entity Relationship Diagram & Documentation

## Overview
The FlatWire database schema manages the complete lifecycle of aluminum flat wire manufacturing processes across three production lines (FL1, FL2, FL3) with support for both standalone and hybrid production routes.

**Target database:** `FlatWireDB` (standalone SQL Server database on `ual-database`), schema `dbo`. Created by `FlatWire_DDL_00_Database.sql`. The `Rod` table is kept as a FlatWireDB-local master (Hybrid foundation decision) mirroring the shared legacy `coils` record; rod-alpha FKs are therefore enforced in-database.

**Table count:** 27 tables across five domains — Lookup (6), Schedule (3), Materials (3), Runs (9), Quality/Output (6). Build scripts run in order `00 → 08` plus the two seed scripts (Lookup seed before Schedule seed). The full set has been validated on SQL Server 2019 (clean build + idempotent re-run + constraint/genealogy tests).

---

## Schema Organization by Logical Groups

### 1. **Lookup/Reference Tables** (Foundational - DDL_01)
Core reference data used throughout the system:

| Table | Purpose | Key Attributes |
|-------|---------|-----------------|
| **Stand** | Rolling mill finishing stands (FM1, FM2_S1, FM2_S2, FM2_S3) | Id (PK), Name (UK), LineId, **RollDiameterIn**, MinGaugeIn, MaxGaugeIn, MinWidthIn, MaxWidthIn, IsActive |
| **Drawer** | Draw box die configurations (DB1, DB2) | Id (PK), Name, DiameterIn (output wire size), MinDiameterIn, MaxDiameterIn, **LastGrindingFeet** (feet run *since* the last grind — a resettable counter, not the reading at it), **TotalFeetAllowed** (scheduled life; NULL until thresholds arrive, OQ-41), IsActive |
| **Edger** | Edger tooling configurations (Round/Square edge profiles) | Id (PK), Name (UK), EdgeType (Round\|Square), ToolingSetNo, IsActive |
| **SpoolConfiguration** | Spool type definitions with weight/diameter constraints | Id (PK), Name (UK), MinWeightLb, MaxWeightLb, MinCoreDiameterIn, MaxCoreDiameterIn, MinOuterDiameterIn, MaxOuterDiameterIn, IsActive |
| **AlloyProperty** | Per-alloy process properties (generator inputs + footage→weight factor) | Id (PK), Alloy (UK), MaxReductionPerPass, SpringbackFactor, GaugeTolerance Minus/PlusIn, WidthTolerance Minus/PlusIn, RodDiameterTolerance Minus/PlusIn (NULL until the values arrive), RodOvalityMaxIn, SpeedRangeMin/MaxFpm, LbPerFtFactor, DensityLbPerIn3, IsWeldingWire, IsActive |
| **PayoffPosition** | Material input positions. Gives `FlatWireRunDetail.PayoffPositionId` a real parent — it was previously an FK-style INT with no table (REVIEW.md #15). Seeded with three pinned rows: the dual VPS bays used by FL1/FL3 plus FL2's traversing take-up | Id (PK, **pinned** 1\|2\|3 — not IDENTITY), Code (UK: Payoff1\|Payoff2\|TraversingTakeup), DisplayName, Equipment (VPS\|TraversingTakeup), MaxWeightLb, IsRodFed, IsActive |

---

### 2. **Schedule Tables** (DDL_02)
Define pass schedules and component configurations:

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| **PassSchedule** | Header: defines alloy, line, dimensional targets, speed range | FK → AlloyProperty; 1-N with PassScheduleComponent, PassScheduleChangeLog, FlatWireRun, RodCheckin, SpoolCheckin, CoilOutput |
| **PassScheduleComponent** | Detail rows: per-component tool station setup (DB1, FM1, EdgeSet, FM2 stands) | FK → PassSchedule, Stand, Drawer, Edger |
| **PassScheduleChangeLog** | Immutable override/edit/acknowledgment audit trail (OQ-28) | FK → PassSchedule |

**Key Fields:**
- `ScheduleId` (PK): e.g., "PS-1100-FL1-003"
- `RouteMode`: Standalone \| Hybrid
- `Status`: Draft \| Active \| Inactive
- `TargetGauge`, `TargetWidth`: Output dimensional targets
- `LineSpeedMinFpm`, `LineSpeedMaxFpm`: Operating speed range

---

### 3. **Material Tables** (DDL_03)
Track material flow from receipt through processing:

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| **Rod** | Wire rod receiving & lifecycle (RECEIVED→STAGED→INFLAT→COMPLETE→HOLD→SCRAP). FlatWireDB-local master mirroring legacy `coils`. Adds carry-forward (FootageRunToDate, RemainingWeightEstimateLb), InventoryType, computed TareWeightLb, audit + RowVersion. **Pre-check-in staging moved out** to `RodStaging` — the retired `StagedPayoffPosition`/`IsWelded` columns could not enforce one-rod-per-bay | 1-N with RodStaging, RodCheckin, Spool (ParentRod + SourceRod), WeldEvent, RollOverride, DieChangeEvent, CoilTraceability, RodCheckout |
| **FlatWireRun** | Core run header (one per check-in event). FootageFt standardized to DECIMAL(10,2); audit + RowVersion | 1-N hub connecting to all run tracking & quality tables |
| **Spool** | Pre-drawn wire spools (FL1 Hybrid output → FL2/FL3 input). Adds SourceRodAlpha (partial-run), OriginRouteMode (hybrid-origin validation), LineId CHECK, audit + RowVersion | FK → SpoolConfiguration, Rod (ParentRodAlpha + SourceRodAlpha), FlatWireRun |

**Key Fields:**
- `Rod.Alpha`: Unique scan key (e.g., "R00041")
- `FlatWireRun.RunId`: Unique run identifier (e.g., "RUN-0042")
- `Spool.Alpha`: Unique spool scan key (e.g., "SP-00021")

---

### 4. **Run Tracking Tables** (DDL_04)
Capture all run events and modifications:

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| **FlatWireRunDetail** | Per-stop detail rows with footage & dimension readings | FK → FlatWireRun, **PayoffPosition** |
| **RodStaging** | **Pre-check-in**: the next rod registered against a VPS bay while the current coil still runs (SRS §4.2 PCI001–PCI008). Carries RodSeqno, IsWelded (WLD010), 3-item inspection, carry-forward evidence, and the release audit. Status `Staged → CheckedIn` \| `Unstaged`, where `Unstaged` has **two routes** distinguished by `UnstageKind`: a pre-check-out, or a **WIP rejection** after a failed staging inspection. FL1/FL3 only — PCI002 excludes FL2 | FK → Rod, PayoffPosition, RodCheckin, **WipRejection**; two **filtered unique** indexes enforce one rod per bay and one bay per rod |
| **RodCheckin** | Rod check-in event + pre-run SPC measurements (FL1, FL2, FL3) | FK → FlatWireRun, Rod, PassSchedule |
| **SpoolCheckin** | Spool check-in event for hybrid route (FL2, FL3 only) | FK → FlatWireRun, Spool, PassSchedule |
| **RunPauseEvent** | Pause/resume cycles with reason codes & outcomes | FK → FlatWireRun; Active pause has NULL ResumedAt |
| **WeldEvent** | Rod-to-rod weld join events (OutgoingRod tail + IncomingRod lead) | FK → FlatWireRun, Rod (2x: outgoing & incoming) |
| **RollOverride** | Run-specific die/roll parameter adjustments (computed Delta; ReasonCode CHECK) | FK → FlatWireRun, Rod |
| **DieChangeEvent** | Die replacement events (auto-triggers PostDieChange SPC; ReasonCode CHECK) | FK → FlatWireRun, Rod, RollOverride (optional) |
| **RunReading** | Sampled gauge/width/speed profile persisted per run (FL2 historical trace + Gauge-Trace/CPK/Cut-Traceability reports). Not a per-tick historian | FK → FlatWireRun |

**Key Event IDs:**
- `RodCheckin` / `SpoolCheckin`: Linked to runs
- `WeldEvent.WeldEventId`: e.g., "WLD-002"
- `RollOverride.OverrideId`: e.g., "OVR-0042"
- `DieChangeEvent.DieChangeId`: e.g., "DC-0041"

---

### 5. **Quality Control & Output Tables** (DDL_05)
Track quality measurements and final outputs:

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| **SpcCheckpoint** | SPC measurement session header (PreRun, PostDieChange, ManualSpotCheck, PostRun, RollAdjustTrigger) | FK → FlatWireRun; 1-N with SpcMeasurement |
| **SpcMeasurement** | Individual measurement readings (e.g., FM1Gauge, WireDiameterPostDraw) | FK → SpcCheckpoint; TargetValue, ToleranceValue, ActualValue → computed Deviation + InSpec |
| **WipRejection** | Material rejection events (pre-run or mid-run); RunId is nullable | FK → FlatWireRun (0-N, nullable) |
| **CoilOutput** | Finished output coils (one per completed run segment). Adds PassScheduleId + PassScheduleSnapshot (OQ-54), NetWeightOverrideLb + ScaleWeightLb (OQ-36 / packing), StagingLocation, audit + RowVersion | FK → FlatWireRun, PassSchedule; 1-N with CoilTraceability |
| **CoilTraceability** | Maps footage ranges within an output coil back to the source rod, and — on a spool-fed line — the source **spool** (`SpoolAlpha`, NULL when rod-fed) | FK → CoilOutput, Rod, **Spool**; Enables genealogy: coil → spool → rod → supplier heat (the `FR-333` chain) |
| **RodCheckout** | Rod removal from a payoff position (Mode P: pre-check-out, never checked in; Mode A: pre-run; Mode B: mid-run emergency). Carries the **supervisor approval stamp** — required for Mode B (OQ-48) and for a **welded** Mode P removal, which is a rejection to HOLD (OQ-68) | FK → FlatWireRun (nullable), Rod |

**Key IDs:**
- `SpcCheckpoint.CheckpointId`: e.g., "SPC-0041"
- `WipRejection.RejectionId`: e.g., "REJ-0041"
- `CoilOutput.CoilAlpha`: e.g., "FW-00421-C01" (unique)
- `RodCheckout.CheckoutId`: e.g., "CO-0041"

---

## Primary Relationships & Cardinality

### Central Hub: FlatWireRun (1-to-Many)
`FlatWireRun` serves as the central aggregation point:
```
FlatWireRun (1) ──┬──→ (N) FlatWireRunDetail
                  ├──→ (N) RodCheckin
                  ├──→ (N) SpoolCheckin
                  ├──→ (N) RunPauseEvent
                  ├──→ (N) WeldEvent
                  ├──→ (N) RollOverride
                  ├──→ (N) DieChangeEvent
                  ├──→ (N) RunReading
                  ├──→ (N) SpcCheckpoint
                  ├──→ (0-N) WipRejection (RunId nullable)
                  ├──→ (N) CoilOutput
                  └──→ (0-N) RodCheckout (RunId nullable)
```

### PassSchedule Cascade (1-to-Many)
```
AlloyProperty (1) ──→ (N) PassSchedule   (PassSchedule.Alloy → AlloyProperty.Alloy)

PassSchedule (1) ──┬──→ (N) PassScheduleComponent ──┬──→ Stand
                   │                                ├──→ Drawer
                   │                                └──→ Edger
                   ├──→ (N) PassScheduleChangeLog
                   ├──→ (N) FlatWireRun
                   ├──→ (N) RodCheckin
                   ├──→ (N) SpoolCheckin
                   └──→ (0-N) CoilOutput   (schedule effective at coil creation, OQ-54)
```

### Material Traceability Chain
```
Rod (1) ──┬──→ (N) RodStaging (pre-check-in: staged at a payoff bay)
          ├──→ (N) RodCheckin (pre-run validation)
          ├──→ (N) WeldEvent (as OutgoingRod or IncomingRod)
          ├──→ (N) RollOverride (modifications)
          ├──→ (N) DieChangeEvent (maintenance)
          ├──→ (0-1) Spool (parent rod for hybrid-produced spool)
          ├──→ (N) CoilTraceability (footage mapping in coil)
          └──→ (N) RodCheckout (removal events)

Spool (1) ──┬──→ (N) SpoolCheckin (pre-run validation)
            ├──→ (1) SpoolConfiguration (constraints)
            ├──→ (0-1) Rod (parent rod Alpha, if hybrid-produced)
            └──→ (0-1) FlatWireRun.SourceRunId (FL1 run that produced it)

RodStaging (1) ──→ (0-1) RodCheckin (set when check-in consumes the staged row)
    Status: Staged ──→ CheckedIn   (operator acknowledges on Dashboard 2)
                  └─→ Unstaged     (pre-check-out / Mode P)
```

### Quality Traceability
```
CoilOutput (1) ──→ (N) CoilTraceability ──→ Rod (source material)
                                         ├──→ Spool (source spool; NULL when rod-fed)
                                         └──→ Footage range mapping

SpcCheckpoint (1) ──→ (N) SpcMeasurement (individual readings)
                   └──→ FlatWireRun (parent run)

WipRejection ──→ FlatWireRun (nullable for pre-run rejections)
             ──→ Material (Rod or Spool Alpha)
```

---

## Key Business Rules & Constraints

### Run Status Workflow
- `FlatWireRun.Status`: Running → Paused (with RunPauseEvent) → Complete or Aborted
- `FlatWireRun.PausedAt`: Current active pause start (NULL if not paused)
- `RunPauseEvent.ResumedAt`: NULL = pause still active; populated on resume

### Check-In Validation
- **RodCheckin**: Captures pre-run SPC (M1, M2 measurements → ovality computed)
- **SpoolCheckin**: Gauge & width measurements validated against PassSchedule targets
- **PlcTagsPushed**: Boolean flag (1 = PLC tags written successfully)

### Material Status Lifecycle
- `Rod.Status`: RECEIVED → STAGED → INFLAT → COMPLETE → HOLD or SCRAP
- `Spool.Status`: RECEIVED → STAGED → INFLAT → COMPLETE → HOLD or SCRAP
- `WipRejection.NewMaterialStatus`: HOLD or SCRAP (terminal state)

### Hybrid Route (FL1 → FL2/FL3)
- FL1 produces **Spool** from **Rod** in Hybrid mode
- Spool is checked in at FL2/FL3 via **SpoolCheckin**
- `Spool.SourceRunId` links to FL1 **FlatWireRun**
- `Spool.ParentRodAlpha` links to source **Rod**

### Quality & Maintenance Events
- **DieChangeEvent** auto-triggers **SpcCheckpoint** (PostDieChange)
- **RollOverride** captures parameter adjustments (Delta = NewValue - OldValue)
- **RollOverride.LinkedOverrideId** in DieChangeEvent provides audit trail
- **SpcMeasurement**: Deviation = ActualValue - TargetValue (signed)

### Rejection Handling
- **WipRejection**: RunId nullable (supports pre-run material rejections)
- **RejectionGroup**: SurfaceQuality, Dimensional, WeldQuality, Material, Process
- **Disposition**: Suspend, Scrap, Rework (maps to `NewMaterialStatus`: HOLD or SCRAP)

### Rod Removal (Checkout)
- **RodCheckout.Mode**: ModeP (pre-check-out — never checked in), ModeA (pre-run), or ModeB (mid-run emergency)
- **RodCheckout.RunId**: NULL for ModeP and ModeA, populated for ModeB
- **RodCheckout ModeP**: enforced to RunId NULL, footage 0, PlcTagsCleared 0, no in-process disposition — nothing was acknowledged and no tags were ever pushed
- **RodCheckout approval**: the `ApprovedBy`/`ApprovedAt`/`OverrideReason` stamp is all-or-nothing, required for Mode B, and required together with `NewRodStatus='HOLD'` when `WasWelded=1`. `WasWelded` is Mode P only
- **RodStaging.Status**: exactly one `Staged` row per (LineId, PayoffPosition), and per RodAlpha, via filtered unique indexes
- **ModeB Disposition**: HoldPendingSupervisor, Scrap, or AcceptAsPartialRun

---

## Indexes & Key Performance Considerations

### Natural Unique Keys (UK)
- `Stand.Name`
- `Drawer.Name`
- `Edger.Name`
- `SpoolConfiguration.Name`
- `AlloyProperty.Alloy`
- `PassSchedule.ScheduleId`
- `PassScheduleComponent.{PassScheduleId, Sequence}`
- `Rod.Alpha` (primary trace key)
- `FlatWireRun.RunId` (primary run key)
- `Spool.Alpha` (primary spool trace key)
- `WeldEvent.WeldEventId`
- `RollOverride.OverrideId`
- `DieChangeEvent.DieChangeId`
- `SpcCheckpoint.CheckpointId`
- `WipRejection.RejectionId`
- `CoilOutput.CoilAlpha`
- `RodCheckout.CheckoutId`

### Implemented Indexes (DDL_07)
All of the following are created by `FlatWire_DDL_07_Indexes.sql` (40 non-clustered + 1 filtered-unique):
- `RodCheckin(RunId)`, `RodCheckin(RodAlpha)`, `RodCheckin(PassScheduleId)`
- `FlatWireRun(LineId,Status)`, `FlatWireRun(Status)`, `FlatWireRun(PassScheduleId)`, `FlatWireRun(OrderId)`
- `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`, `Spool(SourceRodAlpha)`, `Spool(Status)`
- `RunReading(RunId, FootageFt)` — gauge-trace query path
- `CoilTraceability(CoilAlpha, FootageFrom, FootageTo)`, `CoilTraceability(RodAlpha)`, `CoilTraceability(SpoolAlpha)` **filtered** `WHERE SpoolAlpha IS NOT NULL`
- `SpcCheckpoint(RunId, CheckpointType)`, `SpcMeasurement(CheckpointId)`
- `WipRejection(RunId)`, `WipRejection(MaterialAlpha)`
- `CoilOutput(RunId/OrderId/SkidId/PassScheduleId)`, `PassSchedule(LineId,Alloy,Status)`
- All event tables indexed on `RunId` for range queries
- **Filtered UNIQUE** `UX_PassSchedule_OneActivePerLineAlloy (LineId, Alloy) WHERE Status='Active'` — enforces one Active schedule per line+alloy

### Production-Readiness Hardening
- **Concurrency:** `ROWVERSION` token on `PassSchedule`, `Rod`, `FlatWireRun`, `Spool`, `CoilOutput`.
- **Computed columns:** `Rod.TareWeightLb` (Gross−Net, PERSISTED), `RodCheckin.SpcOvalityIn` (|M1−M2|, PERSISTED), `RollOverride.Delta` (New−Old, PERSISTED), `SpcMeasurement.Deviation` + `InSpec` (from Target/Tolerance/Actual, PERSISTED), `RunPauseEvent.PauseDurationSeconds` (DATEDIFF on resume).
- **Overlap guard:** trigger `trg_CoilTraceability_NoOverlap` (DDL_08) enforces non-overlapping footage ranges per coil (DM010).
- **Read procs:** `sp_GetGaugeTrace`, `sp_ShiftSummary` (DDL_08).
- **SET options:** every object-creating script sets `QUOTED_IDENTIFIER ON` / `ANSI_NULLS ON` (required for the PERSISTED computed columns and filtered index).

---

## Audit & Timestamp Fields

### Audit Trail Columns (Present in Most Entities)
- **Creation**: `CreatedBy` (varchar), `CreatedAt` (datetimeoffset)
- **Modification**: `ModifiedBy` (varchar), `ModifiedAt` (datetimeoffset)
- **Transactional Timestamps**: `Timestamp` (datetimeoffset) with DEFAULT (SYSDATETIMEOFFSET())

### Status & Temporal Tracking
- `FlatWireRun`: StartedAt, PausedAt, CompletedAt (nullable)
- `RunPauseEvent`: PausedAt, ResumedAt (nullable), PauseDurationSeconds (computed)
- `RodCheckin`, `SpoolCheckin`: CheckedInAt
- `WipRejection`, `CoilOutput`, `RodCheckout`: Timestamp

---

## Data Validation & Constraints

### Check Constraints (Key Examples)
- `Stand`: MinGaugeIn < MaxGaugeIn; MinWidthIn < MaxWidthIn; RollDiameterIn > 0
- `Drawer`: DiameterIn > 0; MinDiameterIn < MaxDiameterIn (if both set); LastGrindingFeet ≥ 0; TotalFeetAllowed > 0 when set. **No constraint that LastGrindingFeet ≤ TotalFeetAllowed** — *overdue* is a real state the Die Management screen displays, not a data error
- `SpoolConfiguration`: MinWeightLb < MaxWeightLb; MinCoreDiameterIn < MaxCoreDiameterIn; MinOuterDiameterIn < MaxOuterDiameterIn
- `PassSchedule`: LineSpeedMinFpm < LineSpeedMaxFpm; GaugeTolerance > 0; WidthTolerance > 0
- `PassScheduleComponent`: State ∈ {Active, Bypass, Skip}; EdgeType required when EdgeSet Active
- `FlatWireRun`: Status ∈ {Running, Paused, Complete, Aborted}; FootageFt ≥ 0
- `RodStaging`: LineId ∈ {FL1, FL3} (PCI002 excludes FL2); PayoffPosition ∈ {1, 2}; Status ∈ {Staged, CheckedIn, Unstaged}; UnstageKind ∈ {PreCheckOut, WipRejection}; welded/unstage/check-in stamps are all-or-nothing, and the rejection link is present exactly when the release was a rejection
- `PayoffPosition`: Id ∈ {1, 2, 3} pinned — Payoff1, Payoff2, TraversingTakeup (FL2). Rod-fed tables deliberately narrow to {1, 2}
- `RodCheckin`: PayoffPosition ∈ {1, 2}; InspectionOxidation ∈ {Pass, Fail}; SpcOvalityIn ≥ 0
- `WeldEvent`: WeldQuality ∈ {Pass, Fail}; FootagePosition ≥ 0
- `SpcCheckpoint`: CheckpointType ∈ {PreRun, PostDieChange, ManualSpotCheck, PostRun, RollAdjustTrigger}
- `WipRejection`: RejectionGroup ∈ {SurfaceQuality, Dimensional, WeldQuality, Material, Process}; Disposition ∈ {Suspend, Scrap, Rework}
- `RodCheckout`: Mode ∈ {ModeP, ModeA, ModeB}

---

## Data Dictionary Summary

### Lines
- **FL1**: Flat Wire Line 1 (Hybrid route - produces spools or standalone runs)
- **FL2**: Flat Wire Line 2 (Consumer of FL1 spools or standalone runs)
- **FL3**: Flat Wire Line 3 (Consumer of FL1 spools or standalone runs)

### Route Modes
- **Standalone**: Rod checked in → run completed → coil output (direct line process)
- **Hybrid**: Rod checked in FL1 → Spool produced → Spool checked in FL2/FL3 → Coil output

### Component Names
- **DB1, DB2**: Draw box dies (stage 1)
- **FM1**: 12" flattening mill — **not bypassable** (CHECK `CK_PSC_FM1NotBypassable`)
- **EdgeSet**: Edging station (FL1 legacy; per May-21-2026 revision FL1 has no edger)
- **FM2_S1, FM2_S2, FM2_S3**: FL2/FL3 finishing stands — **three stands only**. `FM2_S1` carries the **8"** roller; `FM2_S2` and `FM2_S3` carry **6"** rollers, and both have edgers. `FM2_S3` is the final gauge-control stand and is **not bypassable**. Diameter is data (`Stand.RollDiameterIn`), not part of the name.
  - *Aug-4-2026 correction.* The old four-name set `FM2_8in / FM2_6inS1 / FM2_6inS2 / FM2_6inS3` modelled a separate 8" roller upstream of three 6" stands. The 8" roller **is S1** and there is no fourth stand. Mapping: `FM2_8in`→`FM2_S1`, `FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`, `FM2_6inS3` withdrawn (it never had a tag path or a seed row). This closes **OI-04** — the DDL's `FM2_6inS2` and the SRS's `6" S3` named the same physical stand

### Checkpoint Types
- **PreRun**: Before run starts (Rod/Spool SPC validation)
- **PostDieChange**: Auto-triggered after die change (3-piece sample)
- **ManualSpotCheck**: Operator-initiated random sample
- **PostRun**: After run completion (final QC)
- **RollAdjustTrigger**: Auto-triggered when gauge/width out of spec

### Rejection Groups
- **SurfaceQuality**: Oxidation, scratches, water stains
- **Dimensional**: Gauge, width, diameter, ovality
- **WeldQuality**: Weld breaks, poor penetration
- **Material**: Wrong alloy, wrong temper, supplier issues
- **Process**: Parameter violations, run aborted

---

## Query Patterns & Analytics

### End-to-End Traceability (Finished Coil → Source Rod → Supplier)
```sql
-- Find all material lineage for a coil
SELECT 
    c.CoilAlpha,
    ct.FootageFrom, ct.FootageTo,
    r.Alpha as SourceRodAlpha,
    r.Alloy, r.Temper, r.SupplierHeat
FROM CoilOutput c
JOIN CoilTraceability ct ON c.CoilAlpha = ct.CoilAlpha
JOIN Rod r ON ct.RodAlpha = r.Alpha
WHERE c.CoilAlpha = 'FW-00421-C01'
```

### Run Quality Summary
```sql
-- Count pass/fail at each SPC checkpoint type
SELECT 
    f.RunId,
    sc.CheckpointType,
    COUNT(*) as TotalReadings,
    SUM(CASE WHEN sm.InSpec = 1 THEN 1 ELSE 0 END) as PassCount
FROM FlatWireRun f
JOIN SpcCheckpoint sc ON f.RunId = sc.RunId
LEFT JOIN SpcMeasurement sm ON sc.CheckpointId = sm.CheckpointId
GROUP BY f.RunId, sc.CheckpointType
```

### Rejection & Yield Analysis
```sql
-- Material disposition (Hold/Scrap) by line
SELECT 
    wr.LineId,
    wr.RejectionGroup,
    COUNT(*) as RejectionCount,
    SUM(CASE WHEN wr.NewMaterialStatus = 'SCRAP' THEN 1 ELSE 0 END) as ScrapCount
FROM WipRejection wr
WHERE wr.Timestamp >= DATEADD(DAY, -30, SYSDATETIMEOFFSET())
GROUP BY wr.LineId, wr.RejectionGroup
```

### Run Pause Analysis
```sql
-- Pause reasons and durations per run
SELECT 
    f.RunId,
    rp.ReasonCode,
    rp.ReasonCategory,
    COUNT(*) as PauseCount,
    SUM(DATEDIFF(SECOND, rp.PausedAt, ISNULL(rp.ResumedAt, SYSDATETIMEOFFSET()))) as TotalPauseSeconds
FROM FlatWireRun f
JOIN RunPauseEvent rp ON f.RunId = rp.RunId
WHERE rp.ResumedAt IS NOT NULL
GROUP BY f.RunId, rp.ReasonCode, rp.ReasonCategory
```

---

## Integration Points & APIs

### Check-In Events
- **RodCheckin** API: Validates rod + initializes run
- **SpoolCheckin** API: Validates spool for hybrid route

### Event Logging
- **WeldEvent**, **DieChangeEvent**, **RollOverride**: Real-time event capture
- **RunPauseEvent**: Reason tracking for downtime analysis

### Quality Reporting
- **SpcCheckpoint** + **SpcMeasurement**: QC data points for dashboards
- **WipRejection**: Defect tracking & root cause analysis

### Traceability APIs
- **CoilTraceability**: Genealogy queries (coil → spool → rod → supplier)
- **RodCheckout**: Material disposition tracking

---

## Appendix: Build / Run Order
0. **Database & security** (`DDL_00`) — create `FlatWireDB`, RCSI, `ua_user` grants
1. **Lookup tables** (`DDL_01`) — Stand, Drawer, Edger, SpoolConfiguration, **AlloyProperty**, **PayoffPosition**
2. **Schedule tables** (`DDL_02`) — PassSchedule, PassScheduleComponent, **PassScheduleChangeLog**
3. **Material tables** (`DDL_03`) — Rod, FlatWireRun, Spool
4. **Run tracking tables** (`DDL_04`) — FlatWireRunDetail, **RodStaging**, RodCheckin, SpoolCheckin, RunPauseEvent, WeldEvent, RollOverride, DieChangeEvent, **RunReading**
5. **Quality & output tables** (`DDL_05`) — SpcCheckpoint, SpcMeasurement, WipRejection, CoilOutput, CoilTraceability, RodCheckout
6. **Foreign keys** (`DDL_06`) — all references added last
7. **Indexes** (`DDL_07`) — performance + filtered-unique active schedule
8. **Programmability** (`DDL_08`) — overlap trigger + read procs
9. **Seed data** — `FlatWire_SampleData_Lookup.sql` (first) then `FlatWire_SampleData_Schedule.sql`

All scripts are idempotent (`IF NOT EXISTS` / `IF EXISTS…DROP…CREATE`) and re-runnable.

---

*Document generated from FlatWire DDL scripts (DDL_00 through DDL_08).*
*Last updated: August 1, 2026 — applied the 30 Jul client decisions: `RodStaging` loses its `OffScheduleOverride`/`ScheduledLineId` pair (a rod booked on the other rod line now triggers an **automatic station switch**, not an override) and gains `UnstageKind`/`WipRejectionId` so a **WIP rejection releases a blocked bay**; `AlloyProperty` tolerances become **min/max pairs** for gauge, width and diameter plus an ovality maximum, with diameter and ovality NULL until the values arrive; `RodCheckout` gains the **supervisor approval stamp** it never had (gap G24), enforced for Mode B and for a welded Mode P removal. Table count unchanged at 27. Rebuilt and validated on SQL Server 2019 — `RunAll` clean, 15 constraint tests pass.*

*Previously: July 26, 2026 — retargeted to FlatWireDB; added AlloyProperty, PassScheduleChangeLog, RunReading; production-readiness hardening (rowversion, computed columns, indexes, overlap trigger, filtered-unique active schedule).*
