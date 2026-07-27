# Flat Wire Mill — Lookup & Reference Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
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

---

## Change Log

| Date | Change |
|---|---|
| July 26, 2026 | Added `AlloyProperty` lookup (FW-004); added `IsActive` to `SpoolConfiguration`; added unique constraints on `Drawer.Name`, `Edger.Name`, `SpoolConfiguration.Name`; corrected bare `decimal` weights to `decimal(8,2)`. Retargeted to `FlatWireDB`. |
