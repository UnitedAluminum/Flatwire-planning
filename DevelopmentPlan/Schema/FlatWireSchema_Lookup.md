# Flat Wire Mill — Lookup & Reference Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 29, 2026
**Document Type:** Final Schema — Lookup / Configuration Tables
**Source:** Derived from `FlatWireTables.md` recommendations
**Target DB:** `FlatWireDB` (schema `dbo`)

These tables define physical equipment configuration and reference data used throughout the flat wire mill system. They are relatively static — entries are added when equipment is commissioned and soft-deleted via `IsActive` when retired. DDL: `SQL/FlatWire_DDL_01_Lookup.sql`; seed: `SQL/FlatWire_SampleData_Lookup.sql`.

---

## `Stand`

Rolling mill finishing stands. A stand applies compressive force to reduce material thickness and width. Each stand has physical capacity limits defined by gauge and width ranges. Stands are referenced by `PassScheduleComponent` rows for FM-type components.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(30) | NOT NULL | — | Stand identifier used in pass schedules and UI (e.g. `FM1`, `FM2_8in`, `FM2_6inS1`, `FM2_6inS2`) |
| `LineId` | varchar(5) | NULL | — | Flat wire line this stand belongs to (`FL1`, `FL2`, `FL3`); NULL if the stand is shared across lines |
| `MinGaugeIn` | decimal(8,4) | NOT NULL | — | Minimum input gauge this stand can process, in inches |
| `MaxGaugeIn` | decimal(8,4) | NOT NULL | — | Maximum input gauge this stand can process, in inches |
| `MinWidthIn` | decimal(8,4) | NOT NULL | — | Minimum strip width this stand can process, in inches |
| `MaxWidthIn` | decimal(8,4) | NOT NULL | — | Maximum strip width this stand can process, in inches |
| `IsActive` | bit | NOT NULL | — | `1` = active and selectable in pass schedules; `0` = retired |

**Constraints:**
- `MinGaugeIn < MaxGaugeIn`
- `MinWidthIn < MaxWidthIn`
- `UQ_Stand_Name` — `Name` is unique

---

## `Drawer`

Draw box die configurations (DB1, DB2). A die is a tungsten carbide tool with a specific hole diameter through which wire is pulled to reduce its cross-section. The die hole diameter determines output wire size. Dies are referenced by `PassScheduleComponent` rows for DB-type components.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(50) | NOT NULL | — | Die name or part number identifier |
| `DiameterIn` | decimal(8,4) | NOT NULL | — | Die hole diameter in inches; determines the output wire diameter after drawing |
| `MinDiameterIn` | decimal(8,4) | NULL | — | Minimum input wire diameter this die can accept, in inches |
| `MaxDiameterIn` | decimal(8,4) | NULL | — | Maximum input wire diameter this die can accept, in inches |
| `IsActive` | bit | NOT NULL | — | `1` = die is in service and selectable; `0` = retired / removed from service |

**Constraints:**
- `DiameterIn` must be positive
- When both are non-null: `MinDiameterIn < MaxDiameterIn`
- `UQ_Drawer_Name` — `Name` is unique

---

## `Edger`

Edger tooling configurations (EdgeSet component). An edger applies side pressure to shape the lateral edges of the flat wire — either rounding them (`Round`) or keeping them sharp (`Square`). Each row represents one distinct tooling set-up. Referenced by `PassScheduleComponent` rows where `ComponentName = 'EdgeSet'`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(50) | NOT NULL | — | Edger assembly name or identifier |
| `EdgeType` | varchar(10) | NOT NULL | — | Edge profile produced: `Round` or `Square` |
| `ToolingSetNo` | varchar(20) | NULL | — | Physical tooling set number identifying the specific edger tooling configuration |
| `IsActive` | bit | NOT NULL | — | `1` = active and selectable in pass schedules; `0` = retired |

**Allowed values — `EdgeType`:** `Round`, `Square`

**Constraints:**
- `UQ_Edger_Name` — `Name` is unique

---

## `SpoolConfiguration`

Reference table for spool types. Defines the physical dimensional and weight constraints for each class of spool used as FL1 output and FL2/FL3 feed material. Used at check-in to validate that spool measurements fall within acceptable bounds for the spool type.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(50) | NOT NULL | — | Configuration name identifying the spool type (e.g. `15lb`, `30lb`, `Small`) |
| `MinWeightLb` | decimal(8,2) | NOT NULL | — | Minimum acceptable loaded spool weight in pounds |
| `MaxWeightLb` | decimal(8,2) | NOT NULL | — | Maximum acceptable loaded spool weight in pounds |
| `MinCoreDiameterIn` | decimal(8,4) | NOT NULL | — | Minimum spool core (inside arbor) diameter in inches |
| `MaxCoreDiameterIn` | decimal(8,4) | NOT NULL | — | Maximum spool core (inside arbor) diameter in inches |
| `MinOuterDiameterIn` | decimal(8,4) | NOT NULL | — | Minimum overall outer diameter of a loaded spool in inches |
| `MaxOuterDiameterIn` | decimal(8,4) | NOT NULL | — | Maximum overall outer diameter of a loaded spool in inches |
| `IsActive` | bit | NOT NULL | — | `1` = active/selectable; `0` = retired (added for consistency with the other lookups) |

**Constraints:**
- `MinWeightLb < MaxWeightLb`
- `MinCoreDiameterIn < MaxCoreDiameterIn`
- `MinOuterDiameterIn < MaxOuterDiameterIn`
- `UQ_SpoolConfig_Name` — `Name` is unique

---

## `AlloyProperty`

Per-alloy process properties. Consumed by the pass-schedule generator (max reduction per pass, springback) and by output-weight derivation (`LbPerFtFactor` — footage → weight). This is the **authoritative alloy list** referenced by `PassSchedule.Alloy` (FK). Seeded with 1100, 1350, 3003, 5052, 6061.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Alloy` | varchar(10) | NOT NULL | — | Alloy designation (unique); e.g. `1100`, `1350`, `3003`, `5052`, `6061` |
| `MaxReductionPerPass` | decimal(5,3) | NOT NULL | — | Fractional maximum area reduction per pass (e.g. `0.220` = 22%) |
| `SpringbackFactor` | decimal(5,3) | NOT NULL | — | Roll-gap springback multiplier (e.g. `0.970`) |
| `GaugeToleranceDefault` | decimal(8,4) | NOT NULL | — | Default ± gauge tolerance, in inches |
| `WidthToleranceDefault` | decimal(8,4) | NOT NULL | — | Default ± width tolerance, in inches |
| `SpeedRangeMinFpm` | int | NOT NULL | — | Default minimum line speed (ft/min) |
| `SpeedRangeMaxFpm` | int | NOT NULL | — | Default maximum line speed (ft/min) |
| `LbPerFtFactor` | decimal(10,6) | NULL | — | Footage → weight factor (lb per ft). **PROVISIONAL** — OQ-36 pending confirmation per cross-section |
| `DensityLbPerIn3` | decimal(10,6) | NULL | — | Alloy density (lb/in³) for the area × density weight fallback |
| `IsWeldingWire` | bit | NOT NULL | — | `1` = welding-wire grade (extra traceability); default `0` |
| `IsActive` | bit | NOT NULL | — | `1` = active/selectable; default `1` |

**Constraints:**
- `UQ_AlloyProperty_Alloy` — `Alloy` is unique
- `0 < MaxReductionPerPass < 1`
- `SpeedRangeMinFpm < SpeedRangeMaxFpm`
- `GaugeToleranceDefault > 0`, `WidthToleranceDefault > 0`

> **Gap — no rod diameter tolerance (Q71).** `CHK007` requires the measured **incoming rod diameter** to be validated against nominal ± a lookup tolerance, at both pre-check-in (Dashboard 2A) and check-in (Dashboard 2). The two tolerance columns above are **flat wire output** dimensions — the gauge and width the mill produces — and no rod-diameter tolerance column exists anywhere in `FlatWireDB` or the shared `coils` schema. `CHK007` is therefore not implementable as written, and the Dashboard 2A mockup carries a mock per-alloy map with no backing store. Likely resolution is a `RodDiameterToleranceDefault decimal(8,4)` here, pending confirmation that the tolerance is per-alloy rather than per rod spec or vendor. Values to seed are in the *Alloy Lookup Table* in `Analysis/FlatWireShopfloorDashboards.md`, which is itself marked as needing Process Engineering sign-off.

---

## `PayoffPosition`

Reference table for material input positions. Gives `FlatWireRunDetail.PayoffPositionId` a real parent — previously it was an FK-style `int` pointing at a table that did not exist (`REVIEW.md` #15).

Three positions are modelled, not two: FL1/FL3 draw rod from the dual-position **VPS** (Variable Position Payoff, 9,000 lb per bay), while FL2 uses a **traversing take-up**.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Primary key. **Pinned, not IDENTITY** — `1`, `2`, `3` so values match the API enum `PayoffPosition { Payoff1 = 1, Payoff2 = 2 }` |
| `Code` | varchar(20) | NOT NULL UNIQUE | — | `Payoff1`, `Payoff2`, or `TraversingTakeup` |
| `DisplayName` | varchar(40) | NOT NULL | — | Operator-facing label (e.g. "Payoff 1") |
| `Equipment` | varchar(20) | NOT NULL | — | `VPS` or `TraversingTakeup` |
| `MaxWeightLb` | decimal(8,2) | NULL | — | Position capacity in pounds; 9,000 lb for each VPS bay |
| `IsRodFed` | bit | NOT NULL | — | `1` = accepts a rod bundle (the two VPS bays on FL1/FL3) |
| `IsActive` | bit | NOT NULL | — | `1` = active/selectable; default `1` |

**Seed rows** (created by the DDL, not the sample-data script — these are fixed physical positions, and the `FlatWireRunDetail` FK depends on them existing):

| Id | Code | Equipment | MaxWeightLb | IsRodFed |
|---|---|---|---|---|
| 1 | `Payoff1` | `VPS` | 9000.00 | 1 |
| 2 | `Payoff2` | `VPS` | 9000.00 | 1 |
| 3 | `TraversingTakeup` | `TraversingTakeup` | NULL | 0 |

> **Deliberate narrowing.** Rod-fed tables (`RodStaging`, `RodCheckin`, `RodCheckout`, `SpoolCheckin`) keep `CHECK (PayoffPosition IN (1,2))`. That is intentional, not an oversight: a rod bundle is only ever mounted on a VPS bay. `TraversingTakeup` exists so FL2 can be represented without inventing a fourth vocabulary, but it currently has no UI (`REVIEW.md` #15 remains partly open).

---

## Change Log

| Date | Change |
|---|---|
| July 29, 2026 | Documented a gap on `AlloyProperty`: `CHK007` validates **incoming rod diameter** against nominal ± a lookup tolerance, but the only tolerance columns here are `GaugeToleranceDefault`/`WidthToleranceDefault`, which are flat-wire *output* dimensions. No rod-diameter tolerance column exists anywhere in the schema, so `CHK007` is not implementable as written (**Q71**). No DDL change yet — the column shape and owner need confirming first. |
| July 29, 2026 | Added **`PayoffPosition`** with three pinned rows (Payoff1, Payoff2, TraversingTakeup), giving `FlatWireRunDetail.PayoffPositionId` an enforced FK parent and resolving the "payoff modelled three ways" contradiction in `REVIEW.md` #15. Seeded in the DDL rather than the sample-data script because the FK depends on the rows existing. |
| July 26, 2026 | Added `AlloyProperty` lookup (FW-004); added `IsActive` to `SpoolConfiguration`; added unique constraints on `Drawer.Name`, `Edger.Name`, `SpoolConfiguration.Name`; corrected bare `decimal` weights to `decimal(8,2)`. Retargeted to `FlatWireDB`. |
