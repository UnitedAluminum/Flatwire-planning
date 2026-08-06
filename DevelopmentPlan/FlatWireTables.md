# Flat Wire Mill — Database Table Design

**Project:** Flat Wire Mill Implementation  
**Last Updated:** April 30, 2026  
**Document Type:** Database Schema Reference  
**Source:** Derived from `FlatWireTables.xlsx`, `APIContracts.md`, `FlatWireJiraStories.md`  
**Status:** Analysis + Recommendations — Review Required

---

## Summary

The Excel file contains **7 tables** (6 sheets of design + 1 Spool table). These were reviewed against the full API contract. The verdict:

| Table | Status | Issue |
|---|---|---|
| `FlatLineProcessing` | Needs update | Per-stop detail table — rename to `FlatWireRunDetail`; add `RunId` FK to new `FlatWireRun` header; run-level fields (`Status`, `RouteMode`, `LineId`, timestamps) belong on `FlatWireRun`, not here |
| `FlatLineSetup` | Needs update | Should be the pass schedule component table; missing `PassScheduleId` FK, `ComponentState`, `EdgeType`; no header table exists |
| `Drawer` | Minor updates | Missing dimensional constraints; rename recommended |
| `Edger` | Needs update | Missing `EdgeType` (Round/Square) — this is a required field in all API contracts |
| `Stand` | OK with minor fix | `MinId`/`MaxId` column names are ambiguous |
| `SpoolConfiguration` | OK | Good structure |
| `Spool` | Needs significant update | Missing `Alpha`, `Status`, `Alloy`, `Temper`, `GaugeIn`, `WidthIn`, weights, location, timestamps |

**Additionally, 15 tables are entirely missing** that the API contracts require. These are listed in the [Missing Tables](#missing-tables) section.

---

## Existing Tables — Analysis & Recommended Updates

---

### `FlatLineProcessing`

Stores per-stop and per-sequence detail records for a flat wire run. The parent/header record is the new `FlatWireRun` table (see Missing Tables). Each row captures footage, gauge measurements, and output dimensions for one stop within a run. Rename this table to `FlatWireRunDetail`.

#### Current columns
| Column | Type (inferred) | Notes |
|---|---|---|
| `Id` | int PK | |
| `SetupNo` | varchar | Links to setup record |
| `StopNo` | int | Stop number within a run |
| `SequenceNo` | int | Sequence within a stop |
| `MfgOrderNo` | varchar | Manufacturing order number |
| `HomeMfgOrderNo` | varchar | Home/parent order number |
| `PlanId` | int | FK to planning table |
| `CoilOrderPlanId` | int | FK — coil-level plan; may overlap with `PlanId` |
| `StopFeet` | decimal | Footage at which this stop occurs |
| `OnGaugeWeight` | decimal | Weight of on-gauge material |
| `OutputOD` | decimal | Output coil/spool outer diameter |
| `OutputID` | decimal | Output coil/spool inner diameter |
| `StartingPositionId` | int | FK — references payoff position (Payoff1, Payoff2, TraversingTakeup) |
| `StartGauge` | decimal | Starting gauge measurement |
| `ExitGauge` | decimal | Exit gauge measurement |

#### Issues
- **No `RunId` FK** — no link to the parent `FlatWireRun` header record; stop rows cannot be associated with a run without it.
- **`CoilOrderPlanId` vs `PlanId`** — relationship between these two is unclear; may be redundant.
- **Missing dimensional tolerances** — `TargetGauge`, `GaugeTolerance`, `TargetWidth`, `WidthTolerance` are needed for in-process quality checks.
- **Naming and scope**: `FlatLineProcessing` conflates run-header and stop-detail concerns. Rename to `FlatWireRunDetail`. Run-level fields (`Status`, `RouteMode`, `LineId`, `PassScheduleId`, `StartedAt`, `PausedAt`, `CompletedAt`) belong on the new `FlatWireRun` header table, not on per-stop rows.

#### Recommended updated columns

Rename table to `FlatWireRunDetail`. Run-level fields are removed below — they belong on the `FlatWireRun` header table.

| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `RunId` | varchar(20) NOT NULL | **Add** — FK to `FlatWireRun.RunId` |
| `SetupNo` | varchar(20) | Keep — legacy traceability |
| `StopNo` | int | Keep |
| `SequenceNo` | int | Keep |
| `PlanId` | int | Keep |
| `CoilOrderPlanId` | int | **Review** — clarify or remove if redundant with `PlanId` |
| `HomeMfgOrderNo` | varchar(50) | Keep |
| `PayoffPositionId` | int | **Rename** from `StartingPositionId` |
| `FootageFt` | decimal | **Rename** from `StopFeet` |
| `OnGaugeWeight` | decimal | Keep |
| `TargetGauge` | decimal | **Add** |
| `GaugeTolerance` | decimal | **Add** |
| `TargetWidth` | decimal | **Add** |
| `WidthTolerance` | decimal | **Add** |
| `StartGauge` | decimal | Keep |
| `ExitGauge` | decimal | Keep |
| `OutputOD` | decimal | Keep |
| `OutputID` | decimal | Keep |
| ~~`LineId`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`PassScheduleId`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`RouteMode`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`Status`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`StartedAt`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`PausedAt`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`CompletedAt`~~ | | **Remove** — on `FlatWireRun` header |
| ~~`MfgOrderNo`~~ | | **Remove** — derivable from `FlatWireRun.OrderId` |

---

### `PassScheduleComponent` *(renamed from `FlatLineSetup`)*

Renamed and restructured from `FlatLineSetup`. Each row defines one component slot in a pass schedule — its tool selection, operating state, and parameter value. Belongs to a `PassSchedule` header via `PassScheduleId`. Requires a new `PassSchedule` header table (see [Missing Tables](#missing-tables)).

#### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `PassScheduleId` | varchar(30) NOT NULL | FK → `PassSchedule.ScheduleId` |
| `ComponentName` | varchar(20) NOT NULL | `DB1`, `DB2`, `FM1`, `EdgeSet`, `FM2_S1`, `FM2_S2`, `FM2_S3` — FM2's three stands: S1 (8"), S2 (6"), S3 (6", final) |
| `State` | varchar(10) NOT NULL | `Active`, `Bypass`, `Skip` |
| `ParameterValue` | decimal(8,4) NULL | Die diameter or roll gap; NULL when Bypass/Skip |
| `EdgeType` | varchar(10) NULL | `Round` or `Square`; only populated for `EdgeSet` component |
| `Sequence` | int NOT NULL | Display/apply order (consolidates `StandSequence` and `DrawerSequence`) |
| `StandId` | int NULL | Optional FK → `Stand` |
| `DrawerId` | int NULL | Optional FK → `Drawer` |
| `EdgerId` | int NULL | Optional FK → `Edger` |
| `EntryGauge` | decimal(8,4) NULL | Informational — entry gauge for this component |
| `ExitGauge` | decimal(8,4) NULL | Informational — exit gauge for this component |
| `SetupNo` | varchar(20) NULL | Legacy traceability only |

#### Removed from `FlatLineSetup`

| Column | Reason |
|---|---|
| `RollGap` | Consolidated into `ParameterValue` (covers both roll gap and die size) |
| `StandSequence` / `DrawerSequence` | Consolidated into single `Sequence` column |
| `SpoolId` | Does not belong on a component row |
| `MfgOrderNo` / `HomeMfgOrderNo` | Belongs on the `PassSchedule` header, not per-component |
| `StopNo` / `SequenceNo` | Belongs on run records (`FlatWireRunDetail`) |
| `PlanId` | Belongs on the `PassSchedule` header |

---

### `Drawer`

Represents draw box / wire drawing die configurations (DB1, DB2).

#### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Diameter` | decimal | Die diameter |
| `Name` | varchar | Die name/identifier |

#### Issues
- No dimensional constraints (`MinDiameter`, `MaxDiameter`).
- Column name `Diameter` is too generic — this is the **die hole diameter**; rename to `DiameterIn` for clarity and unit consistency.
- No `IsActive` or `Status` column for managing retired dies.

#### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Name` | varchar(50) | Keep |
| `DiameterIn` | decimal(8,4) | **Rename** from `Diameter` |
| `MinDiameterIn` | decimal(8,4) NULL | **Add** — minimum feed diameter this die can accept |
| `MaxDiameterIn` | decimal(8,4) NULL | **Add** — maximum feed diameter |
| `IsActive` | bit NOT NULL | **Add** — default 1; set 0 for retired dies |

---

### `Edger`

Represents edger tooling configurations (EdgeSet component).

#### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Name` | varchar | Edger name |
| `Set` | varchar/int | Configuration set number |

#### Issues
- **Missing `EdgeType`** — `Round` vs `Square` edge profile is a required field in the API contract (`PassScheduleComponentDto.EdgeType`). Every pass schedule involving an edger must specify this.
- `Set` column purpose is unclear — if it means a tooling set number, rename to `ToolingSetNo` for clarity.

#### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Name` | varchar(50) | Keep |
| `EdgeType` | varchar(10) NOT NULL | **Add** — `Round` or `Square` |
| `ToolingSetNo` | varchar(20) NULL | **Rename** from `Set` |
| `IsActive` | bit NOT NULL | **Add** |

---

### `Stand`

Represents rolling mill stands (FM1, FM2 variants).

#### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Name` | varchar | Stand name — position only (`FM1`, `FM2_S1`, `FM2_S2`, `FM2_S3`); roll diameter lives in `RollDiameterIn` |
| `MinId` | decimal | Minimum — likely Inner Diameter |
| `MaxId` | decimal | Maximum ID |
| `MinOD` | decimal | Minimum Outer Diameter |
| `MaxOd` | decimal | Maximum OD |

#### Issues
- **`MinId`/`MaxId`** column names are ambiguous — `Id` typically means primary key in .NET/SQL Server conventions. Rename to `MinInsideDiameterIn` / `MaxInsideDiameterIn`, or if these refer to gauge: `MinGaugeIn` / `MaxGaugeIn`.
- `MinOD`/`MaxOd` — casing inconsistency (`OD` vs `Od`). Standardize.
- No `LineId` — if certain stands only exist on specific lines (FL1 vs FL2/FL3), this needs tracking.

#### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Name` | varchar(30) | Keep |
| `LineId` | varchar(5) NULL | **Add** — `FL1`, `FL2`, `FL3`, or NULL if shared |
| `MinGaugeIn` | decimal(8,4) | **Rename** from `MinId` |
| `MaxGaugeIn` | decimal(8,4) | **Rename** from `MaxId` |
| `MinWidthIn` | decimal(8,4) | **Rename** from `MinOD` |
| `MaxWidthIn` | decimal(8,4) | **Rename** from `MaxOd` |
| `IsActive` | bit NOT NULL | **Add** |

---

### `SpoolConfiguration`

Reference table for spool types with physical dimensional and weight constraints.

#### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Name` | varchar | Configuration name |
| `MinWeight` | decimal | |
| `MaxWeight` | decimal | |
| `MinId` | decimal | |
| `MaxId` | decimal | |
| `MinOd` | decimal | |
| `MaxOd` | decimal | |

#### Issues
- Same `MinId`/`MaxId` naming ambiguity as `Stand` — rename to `MinInsideDiameterIn`/`MaxInsideDiameterIn` (or `MinCoreDiameterIn` for spools).
- No units suffix on weight — add `Lb` suffix.

#### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Name` | varchar(50) | Keep |
| `MinWeightLb` | decimal | **Rename** |
| `MaxWeightLb` | decimal | **Rename** |
| `MinCoreDiameterIn` | decimal(8,4) | **Rename** from `MinId` |
| `MaxCoreDiameterIn` | decimal(8,4) | **Rename** from `MaxId` |
| `MinOuterDiameterIn` | decimal(8,4) | **Rename** from `MinOd` |
| `MaxOuterDiameterIn` | decimal(8,4) | **Rename** from `MaxOd` |

---

### `Spool`

Represents a physical spool of pre-processed flat wire (used at FL2 check-in).

#### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `SpoolTypeId` | int | FK to `SpoolConfiguration` |
| `OrderNo` | varchar | |
| `RelLetter` | varchar | Release letter |
| `ParentRod` | varchar | The rod alpha that was drawn into this spool |

#### Issues
- **Missing `Alpha`** — every material tracked in the system has an alpha identifier (e.g. `SP-00021`). This is the primary lookup key used in API calls (`GET /rod/{alpha}`, `POST /checkin/spool`). A spool with no alpha cannot be scanned or looked up.
- **Missing `Status`** — `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP`.
- **Missing physical dimensions** — `GaugeIn`, `WidthIn` are required for FL2 check-in validation.
- **Missing weights** — `GrossWeightLb`, `NetWeightLb`.
- **Missing location** — `Location` for floor tracking.
- **Missing `LineId`** — which line produced/is processing this spool.
- **Missing `RunId`** — which FL1 run produced it (for source traceability on Dashboard 5).
- **Missing timestamps** — `ReceivedAt`, `StagedAt`.
- `ParentRod` is a good field; retain as `ParentRodAlpha`.

#### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Alpha` | varchar(20) NOT NULL UNIQUE | **Add** — e.g. `SP-00021`; scanned at FL2 check-in |
| `SpoolTypeId` | int | Keep (FK → `SpoolConfiguration`) |
| `OrderNo` | varchar(50) | Keep |
| `RelLetter` | varchar(10) | Keep |
| `ParentRodAlpha` | varchar(20) | **Rename** from `ParentRod` |
| `SourceRunId` | varchar(20) NULL | **Add** — FK to `FlatWireRun.RunId` (the FL1 run that produced this spool) |
| `LineId` | varchar(5) NULL | **Add** — line currently processing or that produced this spool |
| `Status` | varchar(20) NOT NULL | **Add** — `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP` |
| `GaugeIn` | decimal(8,4) NULL | **Add** |
| `WidthIn` | decimal(8,4) NULL | **Add** |
| `GrossWeightLb` | decimal | **Add** |
| `NetWeightLb` | decimal | **Add** |
| `Location` | varchar(50) NULL | **Add** |
| `ReceivedAt` | datetimeoffset NULL | **Add** |
| `StagedAt` | datetimeoffset NULL | **Add** |

---

---

## Missing Tables

The following tables are required by the API contracts but do not exist in the Excel file.

---

### `PassSchedule` *(header — critical)*

The most important missing table. `FlatLineSetup` rows have no parent to belong to.

| Column | Type | Notes |
|---|---|---|
| `ScheduleId` | varchar(30) PK | e.g. `PS-1100-FL1-003` |
| `Description` | varchar(200) | Human-readable description |
| `Alloy` | varchar(10) NOT NULL | e.g. `1100`, `3003`, `1350` |
| `LineId` | varchar(5) NOT NULL | `FL1`, `FL2`, `FL3` |
| `RouteMode` | varchar(15) NOT NULL | `Standalone` or `Hybrid` |
| `Status` | varchar(10) NOT NULL | `Draft`, `Active`, `Inactive` |
| `TargetGauge` | decimal(8,4) NOT NULL | inches |
| `GaugeTolerance` | decimal(8,4) NOT NULL | ± inches |
| `TargetWidth` | decimal(8,4) NOT NULL | inches |
| `WidthTolerance` | decimal(8,4) NOT NULL | ± inches |
| `LineSpeedMinFpm` | int NOT NULL | Feet per minute |
| `LineSpeedMaxFpm` | int NOT NULL | |
| `CreatedBy` | varchar(50) NOT NULL | |
| `CreatedAt` | datetimeoffset NOT NULL | |
| `ModifiedBy` | varchar(50) NULL | |
| `ModifiedAt` | datetimeoffset NULL | |

---

### `PassScheduleComponent`

> **Not a new table.** `PassScheduleComponent` is the renamed and restructured form of the existing `FlatLineSetup` table — see the [`FlatLineSetup` section above](#flatlinesetup) for the full column definition and recommended changes. It is listed in the Table Count Summary under "Existing — needs structural redesign", not under "Missing — must add".

---

### `Rod`

Wire rod receiving and lifecycle tracking. This is the "R-series alpha" entity.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Alpha` | varchar(20) NOT NULL UNIQUE | e.g. `R00041`; scanned at check-in |
| `Alloy` | varchar(10) NOT NULL | |
| `Temper` | varchar(10) NOT NULL | e.g. `O`, `H14` |
| `DiameterIn` | decimal(8,4) NOT NULL | inches |
| `GrossWeightLb` | decimal NOT NULL | |
| `NetWeightLb` | decimal NOT NULL | |
| `TareWeightLb` | decimal NULL | Tare weight |
| `SupplierHeat` | varchar(50) NULL | Supplier heat/cast number |
| `Status` | varchar(20) NOT NULL | `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP` |
| `Location` | varchar(50) NULL | Floor location |
| `ReceivedAt` | datetimeoffset NOT NULL | |

---

### `FlatWireRun`

Core run tracking table — one row per check-in event (one rod or spool checked in on one line).

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `RunId` | varchar(20) NOT NULL UNIQUE | e.g. `RUN-0042` |
| `LineId` | varchar(5) NOT NULL | `FL1`, `FL2`, `FL3` |
| `OrderId` | varchar(20) NOT NULL | Manufacturing order |
| `PassScheduleId` | varchar(30) NOT NULL | FK → `PassSchedule.ScheduleId` |
| `Alloy` | varchar(10) NOT NULL | Denormalized from `PassSchedule.Alloy` for query convenience — keep in sync if alloy changes |
| `RouteMode` | varchar(15) NOT NULL | |
| `Status` | varchar(20) NOT NULL | `Running`, `Paused`, `Complete`, `Aborted` |
| `StartedAt` | datetimeoffset NOT NULL | |
| `PausedAt` | datetimeoffset NULL | Current pause start (null if not paused) |
| `CompletedAt` | datetimeoffset NULL | |
| `FootageFt` | int NOT NULL DEFAULT 0 | Live footage counter |
| `OperatorId` | varchar(50) NOT NULL | Operator who checked in |

---

### `RodCheckin`

Captures every rod check-in event with inspection results.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | |
| `RodAlpha` | varchar(20) NOT NULL | FK → `Rod.Alpha` |
| `PayoffPosition` | int NOT NULL | `1` or `2` |
| `DiameterMeasuredIn` | decimal(8,4) NOT NULL | Operator-measured diameter |
| `GrossWeightLb` | decimal NOT NULL | |
| `NetWeightLb` | decimal NOT NULL | |
| `PassScheduleId` | varchar(30) NOT NULL | Schedule acknowledged at check-in |
| `OrderId` | varchar(20) NOT NULL | |
| `OperatorId` | varchar(50) NOT NULL | |
| `CheckedInAt` | datetimeoffset NOT NULL | |
| `PlcTagsPushed` | bit NOT NULL | |
| `InspectionOxidation` | varchar(10) NOT NULL | `Pass` or `Fail` |
| `InspectionSurfaceDefects` | varchar(10) NOT NULL | |
| `InspectionWaterStains` | varchar(10) NOT NULL | |
| `InspectionConnectorTag` | varchar(10) NOT NULL | |
| `InspectionNotes` | varchar(500) NULL | |
| `SpcM1In` | decimal(8,4) NOT NULL | Pre-run SPC measurement 1 |
| `SpcM2In` | decimal(8,4) NOT NULL | Pre-run SPC measurement 2 (90°) |
| `SpcOvalityIn` | decimal(8,4) NOT NULL | |M1 − M2|, computed |

---

### `SpoolCheckin`

Captures every spool check-in event at FL2 or FL3 with inspection results. Mirrors `RodCheckin` for the spool-feed workflow.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | `FL2` or `FL3` |
| `SpoolAlpha` | varchar(20) NOT NULL | FK → `Spool.Alpha` |
| `PayoffPosition` | int NOT NULL | `1` or `2` |
| `GaugeIn` | decimal(8,4) NOT NULL | Operator-measured gauge |
| `WidthIn` | decimal(8,4) NOT NULL | Operator-measured width |
| `GrossWeightLb` | decimal NOT NULL | |
| `NetWeightLb` | decimal NOT NULL | |
| `PassScheduleId` | varchar(30) NOT NULL | Schedule acknowledged at check-in |
| `OrderId` | varchar(20) NOT NULL | |
| `OperatorId` | varchar(50) NOT NULL | |
| `CheckedInAt` | datetimeoffset NOT NULL | |
| `PlcTagsPushed` | bit NOT NULL | |
| `InspectionSurface` | varchar(10) NOT NULL | `Pass` or `Fail` |
| `InspectionNotes` | varchar(500) NULL | |

---

### `RunPauseEvent`

Tracks each pause/resume cycle for a run.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `PausedAt` | datetimeoffset NOT NULL | |
| `FootageAtPause` | int NOT NULL | |
| `ReasonCode` | varchar(50) NOT NULL | e.g. `GaugeWidthInvestigation` |
| `ReasonCategory` | varchar(50) NOT NULL | e.g. `QualityMeasurement` |
| `Notes` | varchar(500) NULL | Required when category = `Other` |
| `ResumedAt` | datetimeoffset NULL | NULL = still paused |
| `PauseDurationSeconds` | int NULL | Computed on resume |
| `Outcome` | varchar(30) NULL | `ResumeRun`, `LogWipRejection`, `CheckOutRod`, `ContinuePause` |
| `ActivityCompleted` | varchar(500) NULL | Free-text from operator on resume |

---

### `WeldEvent`

Rod-to-rod weld join events recorded during a run.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `WeldEventId` | varchar(20) NOT NULL UNIQUE | e.g. `WLD-002` |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | |
| `OutgoingRodAlpha` | varchar(20) NOT NULL | |
| `IncomingRodAlpha` | varchar(20) NOT NULL | |
| `FootagePosition` | int NOT NULL | Footage at which weld occurred |
| `WeldType` | varchar(20) NOT NULL | `InductionWeld`, `LaserWeld` |
| `WeldQuality` | varchar(10) NOT NULL | `Pass` or `Fail` |
| `WeldQualityFailReason` | varchar(200) NULL | |
| `OperatorId` | varchar(50) NOT NULL | |
| `Timestamp` | datetimeoffset NOT NULL | |

---

### `RollOverride`

Records run-level roll gap / die adjustments. Does NOT modify the pass schedule.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `OverrideId` | varchar(20) NOT NULL UNIQUE | e.g. `OVR-0042` |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | |
| `RodAlpha` | varchar(20) NOT NULL | Material in-process at time of override |
| `FootagePosition` | int NOT NULL | |
| `ComponentName` | varchar(20) NOT NULL | Which component was adjusted |
| `OldValue` | decimal(8,4) NOT NULL | Scheduled/previous value |
| `NewValue` | decimal(8,4) NOT NULL | Override value |
| `Delta` | decimal(8,4) NOT NULL | NewValue − OldValue |
| `ReasonCode` | varchar(50) NOT NULL | `GaugeDriftHigh`, `GaugeDriftLow`, etc. |
| `Notes` | varchar(500) NULL | |
| `MeasuredGaugeIn` | decimal(8,4) NULL | Gauge reading that prompted the override |
| `MeasuredWidthIn` | decimal(8,4) NULL | |
| `PlcTagWritten` | bit NOT NULL | |
| `OperatorId` | varchar(50) NOT NULL | |
| `Timestamp` | datetimeoffset NOT NULL | |

---

### `DieChangeEvent`

Records die replacement events. Automatically triggers a PostDieChange SPC checkpoint.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `DieChangeId` | varchar(20) NOT NULL UNIQUE | e.g. `DC-0041` |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | |
| `RodAlpha` | varchar(20) NOT NULL | |
| `FootagePosition` | int NOT NULL | |
| `DiePosition` | varchar(5) NOT NULL | `DB1` or `DB2` |
| `OldDieSizeIn` | decimal(8,4) NOT NULL | |
| `NewDieSizeIn` | decimal(8,4) NOT NULL | |
| `ReasonCode` | varchar(50) NOT NULL | `DieWear`, `GaugeDrift`, `Breakage`, etc. |
| `LinkedOverrideId` | varchar(20) NULL | FK → `RollOverride.OverrideId` (auto-created) |
| `SpcCheckpointRequired` | bit NOT NULL DEFAULT 1 | |
| `OperatorId` | varchar(50) NOT NULL | |
| `Timestamp` | datetimeoffset NOT NULL | |

---

### `SpcCheckpoint`

Header record for each SPC measurement session.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `CheckpointId` | varchar(20) NOT NULL UNIQUE | e.g. `SPC-0041` |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | |
| `CheckpointType` | varchar(30) NOT NULL | `PreRun`, `PostDieChange`, `ManualSpotCheck`, `PostRun`, `RollAdjustTrigger` |
| `FootagePosition` | int NOT NULL | |
| `OperatorId` | varchar(50) NOT NULL | |
| `TriggerDescription` | varchar(200) NULL | e.g. "DB2 die changed from 0.310 → 0.308" |
| `AllInSpec` | bit NULL | Computed after measurements saved |
| `Timestamp` | datetimeoffset NOT NULL | |

---

### `SpcMeasurement`

Individual measurement rows belonging to an SPC checkpoint.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `CheckpointId` | varchar(20) NOT NULL | FK → `SpcCheckpoint.CheckpointId` |
| `Name` | varchar(50) NOT NULL | `FM1Gauge`, `FM1Width`, `WireDiameterPostDraw`, etc. |
| `TargetValue` | decimal(8,4) NOT NULL | |
| `ActualValue` | decimal(8,4) NOT NULL | |
| `InSpec` | bit NOT NULL | |
| `Deviation` | decimal(8,4) NOT NULL | ActualValue − TargetValue |

---

### `WipRejection`

Material rejection events raised during a run.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `RejectionId` | varchar(20) NOT NULL UNIQUE | e.g. `REJ-0041` |
| `RunId` | varchar(20) NULL | FK → `FlatWireRun.RunId` (null if pre-run) |
| `LineId` | varchar(5) NOT NULL | |
| `MaterialAlpha` | varchar(20) NOT NULL | Rod or spool alpha |
| `Stage` | varchar(30) NOT NULL | `FL1ActiveRun`, `FL2Incoming`, etc. |
| `FootagePosition` | int NULL | |
| `RejectionGroup` | varchar(30) NOT NULL | `SurfaceQuality`, `Dimensional`, `WeldQuality`, `Material`, `Process` |
| `RejectionReason` | varchar(50) NOT NULL | e.g. `GaugeOutOfSpec` |
| `MeasuredValue` | decimal NULL | |
| `TargetMin` | decimal NULL | |
| `TargetMax` | decimal NULL | |
| `Disposition` | varchar(20) NOT NULL | `Suspend`, `Scrap`, `Rework` |
| `ObservationNotes` | varchar(500) NULL | |
| `NewMaterialStatus` | varchar(20) NOT NULL | `HOLD` or `SCRAP` |
| `OperatorId` | varchar(50) NOT NULL | |
| `Timestamp` | datetimeoffset NOT NULL | |

---

### `CoilOutput`

Output coil records generated at run completion.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `CoilAlpha` | varchar(30) NOT NULL UNIQUE | e.g. `FW-00421-C01` |
| `RunId` | varchar(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `LineId` | varchar(5) NOT NULL | |
| `OrderId` | varchar(20) NOT NULL | |
| `GrossWeightLb` | decimal NOT NULL | |
| `NetWeightLb` | decimal NOT NULL | |
| `FinalGaugeIn` | decimal(8,4) NOT NULL | |
| `FinalWidthIn` | decimal(8,4) NOT NULL | |
| `FootageFt` | int NOT NULL | |
| `SkidId` | varchar(20) NULL | FK → skid table (existing) |
| `SkidStatus` | varchar(20) NULL | `Open`, `Closed` |
| `Status` | varchar(20) NOT NULL | `COMPLETE`, `HOLD`, `SCRAP` |
| `GaugeInSpec` | bit NULL | From final SPC checkpoint |
| `WidthInSpec` | bit NULL | |
| `CompletedAt` | datetimeoffset NOT NULL | |
| `OperatorId` | varchar(50) NOT NULL | |

---

### `CoilTraceability`

Source traceability — maps footage ranges within a coil back to the rod alpha that produced them.

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `CoilAlpha` | varchar(30) NOT NULL | FK → `CoilOutput.CoilAlpha` |
| `RodAlpha` | varchar(20) NOT NULL | FK → `Rod.Alpha` |
| `FootageFrom` | int NOT NULL | Start footage (inclusive) |
| `FootageTo` | int NOT NULL | End footage (inclusive) |

---

### `RodCheckout`

Records rod removal from a payoff position (Mode A = pre-run, Mode B = mid-run).

| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `CheckoutId` | varchar(20) NOT NULL UNIQUE | e.g. `CO-0041` |
| `RunId` | varchar(20) NULL | FK → `FlatWireRun.RunId` (null for Mode A pre-run) |
| `LineId` | varchar(5) NOT NULL | |
| `RodAlpha` | varchar(20) NOT NULL | |
| `PayoffPosition` | int NOT NULL | |
| `Mode` | varchar(10) NOT NULL | `ModeA` or `ModeB` |
| `FootageAtCheckout` | int NOT NULL DEFAULT 0 | |
| `ReasonCode` | varchar(50) NOT NULL | |
| `RodDisposition` | varchar(30) NOT NULL | `ReturnToFloorStorage`, `ReturnToWarehouse`, `HoldReturnToStorage`, `Scrap`, `DeferContinueLater` |
| `RemainingWeightLbEstimate` | decimal NULL | Mode B only |
| `InProcessMaterialDisposition` | varchar(30) NULL | Mode B only — `HoldPendingSupervisor`, `Scrap`, `AcceptAsPartialRun` |
| `PartialSpoolAlpha` | varchar(20) NULL | Generated if `AcceptAsPartialRun` |
| `NewRodStatus` | varchar(20) NOT NULL | |
| `PlcTagsCleared` | bit NOT NULL | |
| `OperatorId` | varchar(50) NOT NULL | |
| `Timestamp` | datetimeoffset NOT NULL | |

---

---

## Entity Relationship Overview

```
PassSchedule ──(1:many)──> PassScheduleComponent
     │                           │
     │                     Stand / Drawer / Edger (lookups)
     │
     └──(1:many)──> FlatWireRun ──(1:many)──> FlatWireRunDetail
                         │
          ┌──────────────┼──────────────────────┬──────────────────────┐
          │              │                      │                      │
     RodCheckin    RunPauseEvent           WeldEvent            SpoolCheckin
          │                                                            │
      Rod (alpha)                                               Spool (alpha)

     FlatWireRun ──(1:many)──> RollOverride
     FlatWireRun ──(1:many)──> DieChangeEvent
     FlatWireRun ──(1:many)──> SpcCheckpoint ──(1:many)──> SpcMeasurement
     FlatWireRun ──(1:many)──> WipRejection
     FlatWireRun ──(1:many)──> CoilOutput ──(1:many)──> CoilTraceability ──> Rod (alpha)

Spool ──> SpoolConfiguration
Spool ──> FlatWireRun (SourceRunId — the FL1 run that produced this spool)
```

---

## Table Count Summary

| Category | Tables |
|---|---|
| Existing — OK with minor fixes | `SpoolConfiguration` |
| Existing — needs column updates | `FlatWireRunDetail` (renamed from `FlatLineProcessing`), `Drawer`, `Edger`, `Stand`, `Spool` |
| Existing — needs structural redesign | `FlatLineSetup` → `PassScheduleComponent` |
| **Missing — must add** | `PassSchedule`, `Rod`, `FlatWireRun`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout` |

**Total tables needed: 22** (7 existing + 15 new, two existing renamed)

---

## Related Documents

| Document | Purpose |
|---|---|
| [APIContracts.md](APIContracts.md) | Full API contract — the source of truth for all field names and types |
| [FlatWireJiraStories.md](FlatWireJiraStories.md) | Sprint plan — FW-001 covers schema changes |
| [TechStackRecommendation.md](TechStackRecommendation.md) | Architecture decisions |
| [CheckinImplementationPlan.md](CheckinImplementationPlan.md) | Check-in implementation — uses `RodCheckin` and `Rod` tables |
