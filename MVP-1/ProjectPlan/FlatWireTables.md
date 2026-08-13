# Flat Wire Mill — Database Table Design

**Project:** Flat Wire Mill Implementation  
**Last Updated:** August 13, 2026 — reconciled to the as-built schema and the 11 Aug MVP split *(the April analysis body is retained below)*  
**Document Type:** Database schema **analysis** — not the schema of record  
**Source:** Derived from `FlatWireTables.xlsx`, `APIContracts.md`, `FlatWireJiraStories.md`  
**Status:** Superseded by the executable DDL — retained as the gap analysis that produced it

---

> ## ⚠ The DDL is authoritative, not this document
>
> **[`MVP-1/DBChanges/Schema/SQL/`](../DBChanges/Schema/SQL/) is the schema of record**, with [`FlatWire_ERDiagram_Documentation.md`](../DBChanges/Schema/SQL/FlatWire_ERDiagram_Documentation.md) as the as-built description and [`phase-01c`](ShopfloorPlan/phase-01c-database-foundation.md) stating the rule. This document is the April *analysis* — what existed, what was missing, what to add — and it is retained for that reasoning, not for its column types.
>
> ### The one thing that will bite you: bare `decimal`
>
> Many columns below are declared as bare **`decimal`**, which in SQL Server means **`decimal(18,0)` — zero decimal places**. The DDL correctly uses `DECIMAL(8,2)` for weights, `DECIMAL(8,4)` for gauges and diameters, and `DECIMAL(10,2)`/`(10,4)` for footage and measures. **Regenerating DDL from this document would round every weight, gauge and measurement to a whole number.** It is the largest sync hazard in the folder (`REVIEW.md` Tier 3 #18). Treat every bare `decimal` here as "see the DDL", not as a specification.
>
> ### Verified counts — 11 Aug 2026, from a clean teardown and rebuild
>
> **25 MVP-1 tables · 33 FKs · 41 indexes · 1 procedure · 1 trigger**, of **28 tables in the full design**. The three `PassSchedule*` tables are **MVP-2** — owned by a separate track, not deferred — and live in [`MVP-2/DBChanges/`](../../MVP-2/DBChanges/). `FlatWire_DDL_RunAll.sql` builds a complete, working MVP-1 database; there is no second runner to chase.
>
> ### `Rod` is retained — do not drop it
>
> An earlier decision dropped the `Rod` table in favour of the shared `coils`. **Master-spec `D-04` (29 Jul 2026, "Hybrid foundation") supersedes that**: `Rod` is a `FlatWireDB`-local master mirroring `coils`, and the mirror is what allows rod-alpha FKs to be **enforced**. `coils` remains the source of truth for the rod *lifecycle*. Gap **`G12` closed on 11 Aug 2026** with the finding that the DDL was right and the plan documents were stale — **`REVIEW.md`'s worklist row telling you to drop `Rod` is itself superseded and has been struck.**

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
| `LastGrindingFeet` | decimal(10,2) NOT NULL | **Added Aug 6 2026** — feet run *since* the last grinding; resettable counter, default 0 |
| `TotalFeetAllowed` | decimal(10,2) NULL | **Added Aug 6 2026** — scheduled life; NULL until thresholds arrive (`OQ-83`) |
| `IsActive` | bit NOT NULL | **Add** — default 1; set 0 for retired dies |

> **Reconciled up to the as-built schema, 6 Aug 2026.** This April analysis was written against an earlier snapshot of the source workbook and lists `Drawer` as having only `Id` / `Diameter` / `Name`. The May revision now in the repo (`BaseDocuments/flatwire tables.xlsx`) also carries `Lastgrindingfeet`, `TotalFeet` and `Status`. The first two are adopted above as `LastGrindingFeet` / `TotalFeetAllowed`; `Status` is **not** adopted — `IsActive` covers the in-service/retired split, and the richer *Active · Nearing · Overdue · Spare · Retired* vocabulary belongs to the die-inventory table that still does not exist (**OI-41**).

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

**Total tables: 25 MVP-1** of 28 in the full design — the three `PassSchedule*` tables are owned outside MVP-1. Verified by a clean teardown-and-rebuild of `FlatWire_DDL_RunAll.sql`: **25 tables · 33 FKs · 1 procedure · 1 trigger**. *(This analysis originally concluded 22.)*

**Total, as built and verified 11 Aug 2026: 28 tables in the full design — 25 of them MVP-1.**

The April figure of 22 was an estimate against an earlier snapshot. What the design actually gained since:

| Table | Why it exists | Scope |
|---|---|---|
| `PayoffPosition` | The payoff vocabulary had been modelled three incompatible ways, including an FK to a table that did not exist. Three **pinned** ids: `Payoff1`, `Payoff2`, `TraversingTakeup` (**`G20`**) | MVP-1 |
| `RodStaging` | Pre-check-in / payoff staging — the whole feature was specified in the SRS and absent from every other artifact (**`G19`**) | MVP-1 |
| `RunReading` | The time-series AGC gauge/width store. Nothing persisted raw readings, yet the FL2 historical profile and the Gauge-Trace and Cut-Traceability reports all require them (**`G3`**) | MVP-1 |
| `FlatWireRunDetail` | The header/detail split — `FlatWireRun` is the run header hub, `FlatWireRunDetail` the per-pass detail. This document already renames `FlatLineProcessing` → `FlatWireRunDetail`; the **hub** is the part that was missing | MVP-1 |
| `Dancer` | FM2 carries two dancers, disclosed 6 Aug 2026 (`D-28`). Lookup seeded with three rows; the mode vocabulary is still ours and unconfirmed (**`G35`**) | MVP-1 |
| `AlloyProperty` | The per-alloy tolerance and property lookup (`FW-004`) | MVP-1 |
| `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` | The pass schedule itself | **MVP-2** — the three that make 25 into 28 |

> **`PassScheduleId` is a documented external reference.** It sits on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput` with **no local FK** — by design, not omission, and in the same class as `PlanId`, `CoilOrderPlanId` and `CoilOutput.SkidId`. The pass schedule is owned outside MVP-1 entirely, so seeded values like `PS-1100-FL1-001` are external identifiers, **not dangling orphans**. Do not "fix" them by adding a FK to a table this scope does not own.

> **`SpoolCheckin` now has a creating story.** It was required by `POST /checkin/spool` and specified here, but neither `FW-006` nor `FW-007` created it (`REVIEW.md` Tier 2 #9). It is created in **Phase 1C** with the rest of the Runs group, and populated in **Phase 8**.

> **⚠ `RodCheckin` requires fields the check-in contract does not send — still true in the as-built DDL, and narrower than `REVIEW.md` Tier 1 #5 describes.** Verified against [`FlatWire_DDL_04_Runs.sql`](../DBChanges/Schema/SQL/FlatWire_DDL_04_Runs.sql) on 13 Aug 2026:
>
> | Column | As built | Contract sends it? |
> |---|---|---|
> | `InspectionConnectorTag` | `VARCHAR(10) NOT NULL`, CHECK `Pass`/`Fail` | **No** — `InspectionDto` is the **three-item** form (oxidation, surface defects, water stains). This is gap **`G14`**, the 3-vs-4 inspection-item conflict, materialised as a constraint |
> | `SpcM1In`, `SpcM2In` | `DECIMAL(8,4) NOT NULL` | **No** — the contract carries a single `diameterMeasuredIn`, not an M1/M2 pair |
> | `SpcOvalityIn` | **computed** — `AS (ABS(SpcM1In - SpcM2In)) PERSISTED` | **n/a — derived, never supplied.** `REVIEW.md` lists `OvalityIn` among the fields the API must send; it cannot be sent and must not be added to the contract |
>
> **As specified, every rod check-in insert fails on four NOT NULL columns.** The fix is a decision, not an edit: either the DTO grows the fourth inspection item and the M1/M2 pair, or those columns become nullable. **Decide before the Phase-4 build** — it is the check-in path.

---

## Related Documents

| Document | Purpose |
|---|---|
| [04-APIContract.md](04-APIContract.md) | Full API contract — the source of truth for all field names and types |
| [FlatWireJiraStories.md](FlatWireJiraStories.md) | Sprint plan — FW-001 covers schema changes |
| [03-HLD-and-ERDiagram.md §14](03-HLD-and-ERDiagram.md) | Architecture decisions |
| [ShopfloorPlan/phase-04-rod-checkin-plc-config.md](ShopfloorPlan/phase-04-rod-checkin-plc-config.md) | Check-in implementation — uses `RodCheckin` and `Rod` tables. *(Replaces `CheckinImplementationPlan.md`, deleted 13 Aug 2026.)* |
