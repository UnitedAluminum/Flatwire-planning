# Flat Wire Mill — Lookup & Reference Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 6, 2026
**Document Type:** Final Schema — Lookup / Configuration Tables
**Source:** the April gap analysis, absorbed into `FlatWireSchema_Mapping.md`’s appendix on 13 Aug 2026 when `FlatWireSchema_Mapping.md` was deleted
**Target DB:** `FlatWireDB` (schema `dbo`)

These tables define physical equipment configuration and reference data used throughout the flat wire mill system. They are relatively static — entries are added when equipment is commissioned and soft-deleted via `IsActive` when retired. DDL: `SQL/FlatWire_DDL_01_Lookup.sql`; seed: `SQL/FlatWire_SampleData_Lookup.sql`.

---

## `Stand`

Rolling mill finishing stands. A stand applies compressive force to reduce material thickness and width. Each stand has physical capacity limits defined by gauge and width ranges. Stands are referenced by `PassScheduleComponent` rows for FM-type components.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(30) | NOT NULL | — | Stand identifier used in pass schedules and UI — **position only**: `FM1`, `FM2_S1`, `FM2_S2`, `FM2_S3` |
| `LineId` | varchar(5) | NULL | — | Flat wire line this stand belongs to (`FL1`, `FL2`, `FL3`); NULL if the stand is shared across lines |
| `RollDiameterIn` | decimal(5,3) | NOT NULL | — | Working roll diameter in inches. **FM1 `12.000`; FM2 `S1` `8.000`, `S2` `6.000`, `S3` `6.000`.** Feeds the bite condition and roll-force limits in the generation engine ([PassScheduleGenerationSpec](../../../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) §3.3.2 / §3.3.6) |
| `MinGaugeIn` | decimal(8,4) | NOT NULL | — | Minimum input gauge this stand can process, in inches |
| `MaxGaugeIn` | decimal(8,4) | NOT NULL | — | Maximum input gauge this stand can process, in inches |
| `MinWidthIn` | decimal(8,4) | NOT NULL | — | Minimum strip width this stand can process, in inches |
| `MaxWidthIn` | decimal(8,4) | NOT NULL | — | Maximum strip width this stand can process, in inches |
| `IsActive` | bit | NOT NULL | — | `1` = active and selectable in pass schedules; `0` = retired |

**Constraints:**
- `MinGaugeIn < MaxGaugeIn`
- `MinWidthIn < MaxWidthIn`
- `CK_Stand_RollDiameterIn` — `RollDiameterIn > 0`
- `UQ_Stand_Name` — `Name` is unique

> **FM2 configuration `[CONFIRMED — Aug 4 2026]`.** FM2 has **three** stands: **S1 (8")**, **S2 (6", edger)**, **S3 (6", edger, final and non-bypassable)**. The earlier four-name set (`FM2_8in`, `FM2_6inS1`, `FM2_6inS2`, `FM2_6inS3`) wrongly modelled a separate 8" roller upstream of three 6" stands — the 8" roller **is S1**. Mapping: `FM2_8in`→`FM2_S1`, `FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`, `FM2_6inS3` withdrawn. `Stand.Id` 1–4 are unchanged for 1–4; Id 5 is removed. Diameter moved into `RollDiameterIn` so a re-roll is a one-row update rather than a repo-wide rename. See [`00-foundations.md`](../../ProjectPlan/ShopfloorPlan/00-foundations.md) §0.3.

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
| `LastGrindingFeet` | decimal(10,2) | NOT NULL | — | Feet run **since the last grinding / reconditioning**. A resettable counter, defaulting to `0` |
| `TotalFeetAllowed` | decimal(10,2) | NULL | — | Scheduled life — the maximum footage this die may run before it is pulled. NULL until thresholds arrive (`OQ-83`) |
| `IsActive` | bit | NOT NULL | — | `1` = die is in service and selectable; `0` = retired / removed from service |

**Constraints:**
- `DiameterIn` must be positive
- When both are non-null: `MinDiameterIn < MaxDiameterIn`
- `UQ_Drawer_Name` — `Name` is unique
- `CK_Drawer_LastGrindingFeet` — `LastGrindingFeet >= 0`
- `CK_Drawer_TotalFeetAllowed` — `TotalFeetAllowed IS NULL OR TotalFeetAllowed > 0`

### Die life

`LastGrindingFeet` and `TotalFeetAllowed` are the two die-life numbers [DieChangeAndManagement.md](../../../MVP-1/RequirementDocuments/DieChangeAndManagement.md) §4.2 calls *"footage on die"* and *"scheduled life"*. The screen derives the rest: `Remaining = TotalFeetAllowed − LastGrindingFeet`, and `Life used % = LastGrindingFeet / TotalFeetAllowed`.

- **`LastGrindingFeet` is feet accumulated *since* the last grind, not the odometer reading *at* it.** The name reads the other way round; the two differ by a subtraction. §4.4's *Reset counter* operation sets it back to `0` when a die returns from reconditioning.
- **`TotalFeetAllowed` is set lower on a reconditioned die** than on a new one — §4.4: *"a re-lapped die has less remaining life."* It is Maintenance-editable, not a constant.
- **There is deliberately no `LastGrindingFeet <= TotalFeetAllowed` constraint.** *Overdue* is a real state the Die Management screen displays (§5), not a data error.

> **What these columns do not do.** `Drawer` is a die-**size** catalogue — 13 rows, one per hole diameter — so a counter here accumulates against a size, not against a physical tool. The per-die inventory (`D-{size×1000}-{seq}`, condition, Active/Nearing/Overdue/Spare/Retired, disposition history) still does not exist: **`OI-41` is narrowed, not closed**, and Phase 6 still depends on Phase 13. When that table lands, these two columns move to it.
>
> Nor can anything maintain them automatically yet. `DieChangeEvent` identifies its dies by `OldDieSizeIn` / `NewDieSizeIn` decimals with **no `DrawerId` FK**, so no run event can attribute footage to a row here. Until that FK or the PLC die counter arrives, both values are Maintenance-maintained.

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

## `Dancer`

Tension-management rollers. **FM1 carries one; FM2 carries two**, sitting **between** stands — between S1/S2 and between S2/S3 — rather than at them (client decision `D-28`, 6 Aug 2026). A dancer absorbs the speed mismatch between adjacent stands; on FM2 the pair is also described as having a selectable **tension mode**.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(30) | NOT NULL | — | Position-only identifier: `FM1_Dancer`, `FM2_Dancer1`, `FM2_Dancer2` |
| `LineId` | varchar(5) | NULL | — | `FL1` / `FL2` / `FL3`; `NULL` = shared across lines, as `Stand` |
| `Position` | varchar(20) | NOT NULL | — | Where it sits: `FM1`, `FM2_S1_S2`, `FM2_S2_S3` |
| `Ordinal` | int | NULL | — | `1` = upstream, `2` = downstream. `NULL` when the mill carries only one (FM1) |
| `SupportsTensionMode` | bit | NOT NULL | — | `1` where the client stated a selectable tension mode. **`0` records "not stated", not "no"** — see below |
| `DefaultMode` | varchar(10) | NOT NULL | — | `Dancer` (compensating speed control) or `Tension` |
| `IsActive` | bit | NOT NULL | — | `1` = in service |

**Allowed values — `Position`:** `FM1`, `FM2_S1_S2`, `FM2_S2_S3`
**Allowed values — `DefaultMode`:** `Dancer`, `Tension`

**Constraints:**
- `UQ_Dancer_Name` — `Name` is unique
- `CK_Dancer_Ordinal` — `Ordinal` is `NULL`, `1` or `2`
- `CK_Dancer_ModeSupport` — `DefaultMode` may only be `Tension` where `SupportsTensionMode = 1`

**Naming matches the tag surface deliberately.** `Dancer1` / `Dancer2` are the same ordinals `[PLC §5.2.2]` uses, and **`Dancer1` is the upstream one** — stated as a convention in `[PLC §4.2]` R6 because nothing else in the data makes it obvious.

> **What this table does *not* carry, and why.** There is **no pass schedule column for dancer mode.** Whether the mode is a schedule parameter the system pushes at check-in, or a machine-side setting it only reads, is **unresolved** — the 6 Aug call described two selectable modes, while the 23 Jul meeting recorded tension control as *"primarily machine-driven"*, set through process settings. The question is `OQ-32`, the conflict is recorded in [ClientCall_2026-07-23_SyncPlan.md](../../../BaseDocuments/ClientCall_2026-07-23_SyncPlan.md) §3.1, and `PassScheduleComponent` is **MVP-2** in any case. This table carries the **equipment capability only**; if the mode becomes scheduled, the column is added there, not here.

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
| `GaugeToleranceMinusIn` | decimal(8,4) | NOT NULL | — | Lower gauge limit, as an offset **below** nominal (in) |
| `GaugeTolerancePlusIn` | decimal(8,4) | NOT NULL | — | Upper gauge limit, as an offset **above** nominal (in) |
| `WidthToleranceMinusIn` | decimal(8,4) | NOT NULL | — | Lower width limit (in) |
| `WidthTolerancePlusIn` | decimal(8,4) | NOT NULL | — | Upper width limit (in) |
| `RodDiameterToleranceMinusIn` | decimal(8,4) | NULL | — | Lower incoming-rod diameter limit (in); `CHK007`. **NULL until the values arrive** |
| `RodDiameterTolerancePlusIn` | decimal(8,4) | NULL | — | Upper incoming-rod diameter limit (in); `CHK007`. **NULL until the values arrive** |
| `RodOvalityMaxIn` | decimal(8,4) | NULL | — | Max \|M1 − M2\| out-of-round. **Per-alloy reference data, not a constant** — supersedes the hard-coded `0.003"` carried by the April check-in implementation plan (deleted 13 Aug 2026) |
| `SpeedRangeMinFpm` | int | NOT NULL | — | Default minimum line speed (ft/min) |
| `SpeedRangeMaxFpm` | int | NOT NULL | — | Default maximum line speed (ft/min) |
| `LbPerFtFactor` | decimal(10,6) | NULL | — | Footage → weight factor (lb per ft). **PROVISIONAL** — OQ-10 pending confirmation per cross-section |
| `DensityLbPerIn3` | decimal(10,6) | NULL | — | Alloy density (lb/in³) for the area × density weight fallback |
| `IsWeldingWire` | bit | NOT NULL | — | `1` = welding-wire grade (extra traceability); default `0` |
| `IsActive` | bit | NOT NULL | — | `1` = active/selectable; default `1` |

**Constraints:**
- `UQ_AlloyProperty_Alloy` — `Alloy` is unique
- `0 < MaxReductionPerPass < 1`
- `SpeedRangeMinFpm < SpeedRangeMaxFpm`
- `CK_AlloyProperty_GaugeTol` / `CK_AlloyProperty_WidthTol` — all four gauge/width limits `> 0`
- `CK_AlloyProperty_RodDiaTol` — the rod-diameter band is **all-or-nothing**: both NULL, or both NOT NULL and `> 0`. Written with an explicit `IS NOT NULL` pair, because `Minus > 0 AND Plus > 0` evaluates to **UNKNOWN** when one side is NULL and a CHECK constraint *accepts* UNKNOWN — half a band was admitted until this was fixed
- `CK_AlloyProperty_Ovality` — `RodOvalityMaxIn` NULL or `> 0` (ovality is an absolute difference, so only an upper limit is meaningful)

> **DECIDED (client, 30 Jul 2026) — four min/max pairs, values owed by e-mail (Q22).** Tim confirmed **upper and lower limits for gauge (height), width and diameter, plus ovality**, held here in the lookup and applied at **both** pre-check-in and check-in. The columns above implement that. Three things to know before using them:
>
> 1. **They are offsets about nominal, not absolute dimensions** — matching `CHK007` and `FR-065` ("0.30 with ±0.01 gives 0.29–0.31"). An asymmetric band is now expressible: `nominal − Minus .. nominal + Plus`. That interpretation is an assumption to confirm when the values arrive.
> 2. **Gauge and width carry the previously seeded symmetric value into both columns.** No new numbers were invented; only the asymmetry is new.
> 3. **Rod diameter and ovality are seeded NULL on purpose.** *"I want to say it's plus or minus 10"* is not a specification. The Dashboard 2A per-alloy map stays visibly mock until the e-mail lands, and `CHK007` is not implementable before then.
>
> The original gap statement is kept below for the audit trail.
>
> **~~Gap — no rod diameter tolerance (Q22).~~** `CHK007` requires the measured **incoming rod diameter** to be validated against nominal ± a lookup tolerance, at both pre-check-in (Dashboard 2A) and check-in (Dashboard 2). The two tolerance columns above are **flat wire output** dimensions — the gauge and width the mill produces — and no rod-diameter tolerance column exists anywhere in `FlatWireDB` or the shared `coils` schema. `CHK007` is therefore not implementable as written, and the Dashboard 2A mockup carries a mock per-alloy map with no backing store. Likely resolution is a `RodDiameterToleranceDefault decimal(8,4)` here, pending confirmation that the tolerance is per-alloy rather than per rod spec or vendor. Values to seed are in the *Alloy Lookup Table* in `Analysis/FlatWireShopfloorDashboards.md`, which is itself marked as needing Process Engineering sign-off.

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
