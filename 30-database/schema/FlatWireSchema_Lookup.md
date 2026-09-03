# Flat Wire Mill — Lookup & Reference Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** September 3, 2026 — **`ToolingInventoryRollSet` added** (`D-42`), the **fourth** Tooling Inventory tool type: mill rolls on a `Stand`, capstan rolls on a `Drawer`, one discriminated table, a **grind** life model rather than footage. ✅ The `Drawer` *"nothing holds a foreign key to this table"* note is **closed** — this is its first referrer. ⚠ `CK_ToolingInventoryDie_LineId` loses `FL3`; **`CK_Drawer_LineId` keeps it** — equipment versus tooling, do not align them. ⛔ Every roll-set column is `[PROPOSED]` pending `Q92` (`G87`). *(previously September 2, 2026 — **three reason-code tables added** from the client's `Reason Codes.xlsx` (Tim O'Brien, 1 Sep 2026): `DowntimeReason`, `WipRejectionReason`, `ItInhibitReason`. ⚠ **They are seeded by the DDL, not the sample-data script** — production reference data, and a production deploy runs `RunAll` without the sample data. The `Dancer` note on `SupportsTensionMode` is also corrected: `0` on FM1 now records **"no"**, not "not stated", and the `OQ-32` mode conflict is **resolved**. *(previously August 23, 2026 — **`Spool` and `SpoolCarrier` are SWAPPED (`Q60`).** The reusable stencilled article is now **`Spool`** in `01_Lookup`; the material record is now **`SpoolProcessing`** in `03_Materials`; `CarrierNo` → `SpoolNo`. ⚠ **A stale `Spool` reference is now *silently wrong*, not obviously stale** — see `[DBD §6.2a]`, the naming convention this closed. **`SpoolConfiguration` is also merged into `Spool`** — counts move to **33 tables · 55 FKs · 69 index statements**. *(previously August 23, 2026 — corrected up to the DDL; header fields standardised)*)*)*
**Document Type:** Final Schema — Lookup / Configuration Tables
**Source:** the April gap analysis, now the appendix of [FlatWireSchema_Mapping.md](FlatWireSchema_Mapping.md) (absorbed 13 Aug 2026 when `FlatWireTables.md` was deleted; recoverable in git history)
**Target DB:** `FlatWireDB` (schema `dbo`)
**Status:** Active — corrected up to the DDL, August 23, 2026
**Scope:** MVP-1
**Owner:** Architecture stream / DBA
**Audience:** DBA, .NET developers, BA
**Part of:** `ProjectPlan/Database/` — the as-built model and the counted baseline are [`DatabaseDesign.md`](../DatabaseDesign.md) (`[DBD]`)
**Authority:** `../sql/FlatWire_DDL_01_Lookup.sql` **wins** on types, nullability and constraints. This document explains them; it does not define them, and it states no object counts — those are `[DBD §6.2]`. No shortcode is declared, deliberately: these are derived documents and must not be cited as authority.

These tables define physical equipment configuration and reference data used throughout the flat wire mill system. They are relatively static — entries are added when equipment is commissioned and soft-deleted via `IsActive` when retired. DDL: `../sql/FlatWire_DDL_01_Lookup.sql`; seed: `../sql/FlatWire_SampleData_Lookup.sql`.

---

## `Stand`

Rolling mill finishing stands. A stand applies compressive force to reduce material thickness and width. Each stand has physical capacity limits defined by gauge and width ranges. Stands are referenced by `PassScheduleComponent` rows for FM-type components.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(30) | NOT NULL | — | Stand identifier used in pass schedules and UI — **position only**: `FM1`, `FM2_S1`, `FM2_S2`, `FM2_S3` |
| `LineId` | varchar(5) | NULL | — | Flat wire line this stand belongs to (`FL1`, `FL2`, `FL3`); NULL if the stand is shared across lines |
| `RollDiameterIn` | decimal(5,3) | NOT NULL | — | Working roll diameter in inches. **FM1 `12.000`; FM2 `S1` `8.000`, `S2` `6.000`, `S3` `6.000`.** Feeds the bite condition and roll-force limits in the generation engine ([PassScheduleGenerationSpec](../../10-requirements/screens/PassScheduleGenerationSpec.md) §3.3.2 / §3.3.6) |
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

> **FM2 configuration `[CONFIRMED — Aug 4 2026]`.** FM2 has **three** stands: **S1 (8")**, **S2 (6", edger)**, **S3 (6", edger, final and non-bypassable)**. The earlier four-name set (`FM2_8in`, `FM2_6inS1`, `FM2_6inS2`, `FM2_6inS3`) wrongly modelled a separate 8" roller upstream of three 6" stands — the 8" roller **is S1**. Mapping: `FM2_8in`→`FM2_S1`, `FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`, `FM2_6inS3` withdrawn. `Stand.Id` 1–4 are unchanged for 1–4; Id 5 is removed. Diameter moved into `RollDiameterIn` so a re-roll is a one-row update rather than a repo-wide rename. See [Business/BusinessRules.md](../../10-requirements/BusinessRules.md) §0.3.

---

## `Drawer`

**The two draw boxes — `DB1` and `DB2`.** A draw box (die block) is the *machine* that pulls rod through a die to reduce its diameter. The **die** is the tooling fitted in it and lives in `ToolingInventoryDie` below.

> **Restructured 2 Sep 2026 by the die split.** This table used to hold **13 rows, one per die hole diameter**, plus the two die-life counters — so it was named after the machine and populated with the tooling. `DiameterIn`, the feed-diameter range and both die-life columns moved to `ToolingInventoryDie`; two rows is now the whole table, because there are exactly two physical draw boxes.
>
> `phase-13-mvp2-die-management.md` had called this split impossible — *"a table cannot be split"* — because a **scope seam** ran through it: die inventory was MVP-2 while the die change was MVP-1, so the counters were bolted on here on 6 Aug 2026 as a workaround. The seam is gone; **`OI-41` closes with the split**, and **`Q90`'s `Drawer` → `Die` rename is superseded** — the name is now correct.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Name` | varchar(50) | NOT NULL | — | `DB1` or `DB2` — the draw box, not the die |
| `LineId` | varchar(5) | NOT NULL | — | `FL1` for both. FL1 owns the physical boxes and FL3 runs through them, as it shares FL1's VPS payoff |
| `IsActive` | bit | NOT NULL | — | `1` = box in service |

**Constraints:**
- `PK_Drawer` — clustered on `Id`
- `UQ_Drawer_Name` — `Name` is unique
- `CK_Drawer_Name` — `Name IN ('DB1','DB2')`
- `CK_Drawer_LineId` — `LineId IN ('FL1','FL3')`

**Max two rows is structural, not policed.** `CK_Drawer_Name` admits only two values and `UQ_Drawer_Name` makes each unique, so a third row is impossible without a schema change — no trigger and no row-counting rule. `LineId = 'FL1'` for both rows is client-confirmed: the 31 Aug 2026 Tooling Inventory grid attributes dies to `Machine Name = FL1`, and **no FL3 row appears in any of the three tool grids**.

> ✅ **One foreign key now points at this table, and until 3 Sep 2026 none did.** `PassScheduleComponent.ComponentName` and `DieChangeEvent.DiePosition` both name `DB1`/`DB2` as CHECK-constrained strings, and `PassScheduleComponent.DrawerId` was dropped with the split. So `Drawer` was an **equipment register, not a join target** — deliberate, and worth knowing before writing a query that assumes otherwise. **`ToolingInventoryRollSet.DrawerId` (`D-42`) is the first** — the capstan roll sets mount on the draw boxes. It is the referrer this note predicted, though it arrived from the roll sets rather than from `G77`'s edger and straightener work, which is still owed.

> ⚠ **`CK_Drawer_LineId` keeps `FL3`, and `CK_ToolingInventoryDie_LineId` no longer does.** That is not an inconsistency. `Drawer` is **equipment** and FL3 genuinely runs through `DB1`/`DB2`; the tooling registers carry the client's 3 Sep rule that inventory is maintained for **FL1/FL2 only, with FL3 using a combination of the two** (`D-42`). Do not "align" the two constraints.

> ⚠ **Naming: the client calls these `D1`/`D2` on one tab and `DB1`/`DB2` on another** — four spellings across four surfaces, per the 31 Aug 2026 mail analysis §4.8. `DB1`/`DB2` is retained deliberately; that analysis says **do not reconcile until the Speed tab lands** (action `A12`, still open).

---

## `ToolingInventoryDie`

**The register of physical dies — one row per tool, not per size.** A die is a tungsten carbide tool with a specific hole diameter through which wire is pulled to reduce its cross-section; the hole diameter determines the output wire size.

The name is the client's own term: the Machines Application **Tooling Inventory** tab carries **four** tool types — Die, Edger, Straightener (31 Aug 2026) and **Roll Set** (3 Sep 2026, `D-42`). This table is the first of the four; **edger and straightener inventory are not covered here — that is `G77`** — and the fourth is [`ToolingInventoryRollSet`](#toolinginventoryrollset) below.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `DieAlpha` | varchar(20) | NOT NULL | — | `D-{size×1000}-{seq}`, e.g. `D-310-034` for a 0.310″ die. **Not present on the client's grid** — see `OI-141` |
| `SerialNo` | varchar(50) | NULL | — | Client grid `S/N`. Unique when set, via a **filtered** index |
| `PartNo` | varchar(50) | NULL | — | Client grid `P/N` |
| `Location` | varchar(50) | NULL | — | Client grid `Location` — die room / crib position |
| `LineId` | varchar(5) | NULL | — | Client grid `Machine Name`. NULL for a die not assigned to a line |
| `HoleSizeIn` | decimal(8,4) | NOT NULL | — | Client grid `ID(")` — the hole diameter, and so the output wire size |
| `MinFeedDiameterIn` | decimal(8,4) | NULL | — | Minimum acceptable feed diameter (was `Drawer.MinDiameterIn`) |
| `MaxFeedDiameterIn` | decimal(8,4) | NULL | — | Client grid `Max Imput Dia.` (was `Drawer.MaxDiameterIn`) |
| `PitchIn` | decimal(8,4) | NULL | — | Client grid `Pitch` |
| `MaxIdIn` | decimal(8,4) | NULL | — | Client grid `Max ID(")` |
| `LubricationType` | varchar(50) | NULL | — | Client grid `Lubrication Type` |
| `DieType` | varchar(20) | NULL | — | `TC Mono` · `TC Poly` · `Natural diamond` (`FR-247`). Also what §2.4's *"must match the outgoing die type"* compares |
| `LastGrindingFeet` | decimal(10,2) | NOT NULL | — | Feet run **since the last grinding / reconditioning** — a resettable counter, not the reading *at* that grind. Default `0` |
| `TotalFeetAllowed` | decimal(10,2) | NULL | — | Scheduled life — maximum footage before the die is pulled. NULL until the client supplies thresholds (`OQ-83`) |
| `LifecycleStatus` | varchar(20) | NOT NULL | — | `Active` · `In Service` · `In Grinding` · `Retired`. Default `In Service` |
| `InUse` | bit | NOT NULL | — | Client grid `In Use`. Default `0`. Feeds the derived `Spare` band |
| `Source` · `Condition` · `InspectionDate` · `Notes` | varchar / date | NULL | — | `FR-247` registration fields |
| `LastResetBy` · `LastResetAt` | varchar / datetimeoffset | NULL | — | `FR-245` / `FR-248` |
| `IsActive` | bit | NOT NULL | — | In-service flag, distinct from `LifecycleStatus` |

**Constraints:**
- `PK_ToolingInventoryDie`, `UQ_ToolingInventoryDie_DieAlpha`
- `CK_ToolingInventoryDie_HoleSize` — `HoleSizeIn > 0`
- `CK_ToolingInventoryDie_FeedRange` — `MinFeedDiameterIn < MaxFeedDiameterIn` when both present
- `CK_ToolingInventoryDie_LastGrindingFeet` — `>= 0`
- `CK_ToolingInventoryDie_TotalFeetAllowed` — NULL or `> 0`
- `CK_ToolingInventoryDie_LifecycleStatus` · `CK_ToolingInventoryDie_LineId` · `CK_ToolingInventoryDie_DieType`
- `UX_ToolingInventoryDie_SerialNo` — **filtered** unique, `WHERE SerialNo IS NOT NULL` (script `07`)

**No uniqueness on `HoleSizeIn`.** The old one-row-per-diameter premise is gone: many physical dies share a size, which is the point of the split. **No `LastGrindingFeet <= TotalFeetAllowed` check** — *overdue* is a real operating state the Die Management screen must display, not a data error.

`SerialNo` uniqueness is a filtered index rather than a `UNIQUE` constraint because the seed leaves all fourteen serials NULL and a plain `UNIQUE` admits only **one** NULL row.

### Status — two vocabularies, resolved by derivation

The client's grid carries three values (`Active` · `In Service` · `In Grinding`); `FR-253` specifies five (`Active < 65 % used` · `Nearing end 65–79 %` · `Overdue ≥ 80 %` · `Spare`, meaning 0 footage and not installed · `Retired`). Read `FR-253` closely and three of its five are **percentage bands**:

- **Stored** in `LifecycleStatus`: the client's three verbatim, plus `Retired` from `FR-250`. A `bit` cannot express *In Grinding* — the same narrowness `G77` flags on `Edger.IsActive`.
- **Derived**, never stored: `Nearing` / `Overdue` from `LastGrindingFeet` against `TotalFeetAllowed`; `Spare` from `InUse = 0 AND LastGrindingFeet = 0`.

> ⚠ **Both vocabularies contain the word `Active`, meaning different things** — a lifecycle state here, a life band under 65 % in `FR-253`. The client's value is quoted, not edited; the two distinct names are what disambiguate. Never store a derived band in `LifecycleStatus`.

> ⚠ **`OI-141` is open on ownership, not on this shape.** `[MSP §4.10]` puts Die Management on the Machines Application → Tooling Inventory tab, while `FR-254` makes it the runtime source of truth the Die Change screen reads — and the client's grid carries **none** of the four values `FR-254` names. The column set above is the **union** of both field sets. If `OI-141` resolves to *two* registers, this is the `FlatWireDB` one and `FR-254`'s exclusivity needs restating; the table itself stands either way.

**`ID(MM)` is not a column.** It is a derived display value — `0.343 × 25.4 = 8.712`, shown on the client grid as `8,700`. Compute it in the UI.

**Die life migrated here from `Drawer`, unchanged in meaning.** `LastGrindingFeet` and `TotalFeetAllowed` are what [DieChangeAndManagement.md](../../10-requirements/screens/DieChangeAndManagement.md) §4.2 calls *"footage on die"* and *"scheduled life"*; the screen derives `Remaining` and `Life used %`. What changed is the **grain**: the counter now accumulates against a physical tool, so `OI-41`'s accepted consequence — *"two dies of one diameter share a counter"* — is retired.

⚠ **`LastGrindingFeet` is denormalised** against `SUM(DieHistory.FootageAddedFt)`, deliberately. `FR-254` makes the running total what the Die Change screen reads, so it must be one cheap column rather than an aggregate over a growing log, while `FR-252` needs the per-run rows. The total is authoritative for the screens; the log explains it. They can drift and nothing in the database prevents it — the invariant lives in the application beside `FR-255`'s increment, **not in a trigger** (`G41`: a trigger joining on a nullable column passes silently, and `DieHistory.RunId` is nullable).

---

## `ToolingInventoryRollSet`

**The register of physical roll sets — the fourth Tooling Inventory tool type.** Added 3 September 2026 from Tim O'Brien's mail: *"We should include mill rolls for traceability, 12″ (FL1-S1) 2 roll set, DB1/DB2 Capstans (rolls) current inventory = 2, will be adding a spare and they can be refurbished, 8″, 6″, 6″ rolls for (FL2-S1, FL2-S2, FL2-S3) 2 roll sets. We will **NOT** need to include dancers, entry guides, payoffs, spools, etc. in the tooling table."* — `D-42`.

**Same split as the die.** [`Stand`](#stand) and [`Drawer`](#drawer) are the **positions**; this is the physical **tool** fitted to one of them, exactly as `ToolingInventoryDie` is to `Drawer`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RollSetAlpha` | varchar(20) | NOT NULL | — | `RS-{position}-{seq}`, e.g. `RS-FM1-001`. **Ours, not the client's** — no alpha appears on any tooling grid they have sent (`OI-141`) |
| `RollType` | varchar(10) | NOT NULL | — | `Mill` · `Capstan` — the discriminator |
| `StandId` | int | NULL | `Stand.Id` | Mill rolls: `FM1`, `FM2_S1`, `FM2_S2`, `FM2_S3` |
| `DrawerId` | int | NULL | `Drawer.Id` | Capstan rolls: `DB1`, `DB2`. **The first FK ever taken on `Drawer`** |
| `LineId` | varchar(5) | NULL | — | Client grid `Machine Name`. **`FL1` or `FL2` only** — FL3 uses a combination and holds no tooling of its own |
| `SetNumber` | varchar(20) | NULL | — | Client grid `Set Number` — lettered `A` / `B` / `C` on the edger and straightener grids |
| `RollQty` | int | NOT NULL | — | Client grid `Roll Qty`. Default `2` — every set the client named is a two-roll set |
| `NominalDiameterIn` | decimal(5,3) | NULL | — | The **tool's** own nominal size: `12.000` for FM1; `8.000` / `6.000` / `6.000` for FM2 S1/S2/S3 |
| `OdIn` · `MinOdIn` · `IdIn` | decimal(8,4) | NULL | — | Client grid `OD(")` · `Min OD(")` · `ID(")`. The **grind** life model |
| `SerialNo` · `PartNo` · `Location` | varchar | NULL | — | Client grid `S/N` · `P/N` · `Location`. `SerialNo` unique when set, via a **filtered** index |
| `LifecycleStatus` | varchar(20) | NOT NULL | — | `Active` · `In Service` · `In Grinding` · `Retired`. Default `In Service` — identical to the die |
| `IsRefurbishable` | bit | NOT NULL | — | *"they can be refurbished"* — the client's word, attached to the **capstans** specifically. Default `0` |
| `DateOfChange` · `DateOfLastGrind` | date | NULL | — | Client grid `Date of Change` · `Date of Last Grind` |
| `InUse` | bit | NOT NULL | — | Client grid `In Use`. Default `0` |
| `Notes` · `IsActive` | varchar / bit | — | — | As elsewhere |

**Constraints:**
- `PK_ToolingInventoryRollSet`, `UQ_ToolingInventoryRollSet_Alpha`
- `CK_TIRS_RollType` — `RollType IN ('Mill','Capstan')`
- `CK_TIRS_Mount` — **exactly one mount, agreeing with the discriminator**: a `Mill` row has `StandId` and no `DrawerId`; a `Capstan` row has `DrawerId` and no `StandId`
- `CK_TIRS_LineId` — `LineId IN ('FL1','FL2')` · `CK_TIRS_RollQty` — `> 0` · `CK_TIRS_NominalDiameter` — NULL or `> 0`
- `CK_TIRS_Od` — `MinOdIn < OdIn` when both present · `CK_TIRS_LifecycleStatus`
- `IX_ToolingInventoryRollSet_StandId` · `_DrawerId` — both **filtered**, since `CK_TIRS_Mount` guarantees one of the pair is NULL on every row
- `IX_ToolingInventoryRollSet_LifecycleStatus` · `UX_ToolingInventoryRollSet_SerialNo` — **filtered** unique (script `07`)

**One table, not two, and the discriminator is why.** Mill rolls hang off a `Stand` and capstan rolls off a `Drawer` — two parents, which normally argues for two tables. The client named both in one breath as one answer about one tab option, and `DieHistory` already set the precedent here of one discriminated table serving two shapes.

> ⚠ **The life model is grind, not footage.** A die is consumed by feet (`LastGrindingFeet` / `TotalFeetAllowed`); a roll is **reground until it reaches a minimum OD**. So this table carries `OdIn` / `MinOdIn` / `DateOfLastGrind` and **no footage counter**. `G77` already recorded that the two models differ — do not add die-life columns here by analogy.

> ⚠ **`Stand.RollDiameterIn` stays authoritative for the machine.** `D-26` and `[PLC §5.4]` both rest on it. `NominalDiameterIn` here is the tool's own size. They are **not** duplicates and neither is stale.

> ⛔ **Every column here is `[PROPOSED]` until `Q92` returns — `G87`.** Die, Edger and Straightener each arrived as a screenshot grid with an ordered column list. Roll sets arrived as **one sentence**. Four things are open: the column list itself; whether capstan rolls are the same tab option as mill rolls or a fifth; whether *"refurbished"* is the edger's `In Grinding` under another name; and what `Machine Name` a capstan roll carries, given `DB1`/`DB2` sit on FL1.

> ⚠ **The seed is six rows — one set per position — and that is a floor, not the client's count.** *"2 roll set(s)"* reads both as *two rolls per set* and *two sets per position* in the same paragraph. `RollQty = 2` records the first, which the edger grid's `Roll Qty 2` corroborates; the second would change the **row count** and is left unseeded rather than guessed. The capstan spare is not seeded either — *"will be adding a spare"* is future tense.

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
| `SupportsTensionMode` | bit | NOT NULL | — | `1` where the client stated a selectable tension mode. **`0` on FM1 records "no"** since 1 Sep 2026 — tension mode is FL2-only. See below |
| `DefaultMode` | varchar(10) | NOT NULL | — | `Dancer` (compensating speed control) or `Tension` |
| `IsActive` | bit | NOT NULL | — | `1` = in service |

**Allowed values — `Position`:** `FM1`, `FM2_S1_S2`, `FM2_S2_S3`
**Allowed values — `DefaultMode`:** `Dancer`, `Tension`

**Constraints:**
- `UQ_Dancer_Name` — `Name` is unique
- `CK_Dancer_Ordinal` — `Ordinal` is `NULL`, `1` or `2`
- `CK_Dancer_ModeSupport` — `DefaultMode` may only be `Tension` where `SupportsTensionMode = 1`

**Naming matches the tag surface deliberately.** `Dancer1` / `Dancer2` are the same ordinals `[PLC §5.2.2]` uses, and **`Dancer1` is the upstream one** — stated as a convention in `[PLC §4.2]` R6 because nothing else in the data makes it obvious.

> **What this table does *not* carry, and why — and the reason is now settled.** There is **no pass schedule column for dancer mode**, and there will not be one. The client answered on **1 Sep 2026**: dancers hold *"little to know [sic] tension by design"*, control is **the machine program**, each dancer holds a **range (position)**, and it *"will not be adjustable from an operator standpoint and will remain constant"*. **Nobody selects the mode** — not the operator at the HMI, not the pass schedule — so no write surface is owed and the read-only PLC dancer element (`PLC-Q18`) was the correct call. A tension mode does exist, *"on FL2 however it will only work with heavier & larger dimension products"*, which is why `SupportsTensionMode` is `1` on FM2's pair and `0` on FM1.
>
> This **resolves the `C6` / `D-28` conflict** recorded in [ClientCall_2026-07-23_SyncPlan.md](../../95-archive/source-documents/ClientCall_2026-07-23_SyncPlan.md) §3.1 and held unapplied since 12 Aug 2026 — a 1 Sep statement is later client direction than the 6 Aug call, and it makes both readings true at once. ⚠ **What is *not* resolved is the physics**: `PSG-D27` models applied front/back tension reducing separating force, and if dancers *remove* tension that substitution describes something FM1 does not do at all. Tim is *"uncertain how this will work… will need to follow up with engineering"*.

---

## `Spool`

**The physical article the wire is wound on.** A carrier outlives the material on it: `SpoolProcessing.Alpha`
is the *material's* identity, this is the *article's*. Referenced by `Spool.SpoolId`.

**`SpoolConfiguration` was merged into this table on 23 Aug 2026 (`Q60`).** It was a **size class**
holding exactly **one** meaningful row — the client confirmed every article is the same size — while
the articles number 30-45, so its six dimensional columns and its `Name` now live here, per article.

> ⚠ **The trade, stated because it is real.** This **denormalises**: the same eight values repeat on
> all 30-45 rows, and a second purchased size becomes a multi-row `UPDATE` where the old shape needed
> one `INSERT`. It holds only while *"every article is one size"* does. **If the client confirms a
> second size, revisit the merge** — the fallback below stops being well-defined at that moment.

> **The nullable-limits fallback.** `SpoolProcessing.SpoolId` is **nullable by design** (`Q42` is open
> and nothing seeds articles in production yet), so a material row may have no article and therefore
> no limits to validate against. The documented fallback is **any active `Spool` row's limits** —
> well-defined precisely because all articles are one size, and needing no external constant. The
> previous shape had to keep a one-row table alive to answer the same question.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | - | Surrogate primary key, IDENTITY |
| `SpoolNo` | varchar(20) | NOT NULL | - | The **stencilled** string the operator reads off the carrier, e.g. `S1` .. `S45` |
| `SizeClass` | varchar(50) | NULL | - | Descriptive size name, e.g. `TKUP-1 Intermediate Spool`. **Not unique** — every article shares one name, so `UQ_SpoolConfig_Name` could not survive the merge and is deliberately not recreated. Was `SpoolConfiguration.Name` |
| `MinWeightLb` | decimal(8,2) | NULL | - | Minimum acceptable loaded weight (lb). *Merged from `SpoolConfiguration`* |
| `MaxWeightLb` | decimal(8,2) | NULL | - | Maximum acceptable loaded weight (lb) |
| `MinCoreDiameterIn` | decimal(8,4) | NULL | - | Minimum core (inside arbor) diameter (in) |
| `MaxCoreDiameterIn` | decimal(8,4) | NULL | - | Maximum core diameter (in) |
| `MinOuterDiameterIn` | decimal(8,4) | NULL | - | Minimum outer diameter of the loaded article (in) |
| `MaxOuterDiameterIn` | decimal(8,4) | NULL | - | Maximum outer diameter of the loaded article (in) |
| `IsActive` | bit | NOT NULL | - | Soft delete, as the other lookups. Default `1` |
| `Notes` | varchar(200) | NULL | - | e.g. "re-stencilled 08/2026", "withdrawn - damaged flange" |

**Constraints:**
- `PK_Spool` - `Id`
- `UQ_Spool_No` - `SpoolNo` is unique
- `DF_Spool_IsActive` - defaults to `1`
- `CK_Spool_Weight` / `CK_Spool_CoreDiam` / `CK_Spool_OuterDiam` - carried over from `CK_SpoolConfig_*`, each now **all-or-nothing per band**: both bounds NULL, or both set with `Min < Max`. The explicit `IS NOT NULL` pair matters — `Min < Max` alone evaluates to UNKNOWN when one side is NULL and **a CHECK accepts UNKNOWN**, so half a band would have been admitted

> **The stencil is the key, and that is a UI decision as much as a data one.** The operator types
> what is painted on the carrier rather than picking from a list, because 30-45 rows will not
> scroll usefully on a shopfloor panel at arm's length.

> **`SpoolNo`'s format is open - `Q42`** (format and mastering). The `S1..S45` pattern above is
> illustrative, not ratified. Seed rows for this table are marked provisional for the same reason.
> Raised as `OI-120`: nothing in the schema was a carrier before this table.

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
> **~~Gap — no rod diameter tolerance (Q22).~~** `CHK007` requires the measured **incoming rod diameter** to be validated against nominal ± a lookup tolerance, at both pre-check-in (Dashboard 2A) and check-in (Dashboard 2). The two tolerance columns above are **flat wire output** dimensions — the gauge and width the mill produces — and no rod-diameter tolerance column exists anywhere in `FlatWireDB` or the shared `coils` schema. `CHK007` is therefore not implementable as written, and the Dashboard 2A mockup carries a mock per-alloy map with no backing store. Likely resolution is a `RodDiameterToleranceDefault decimal(8,4)` here, pending confirmation that the tolerance is per-alloy rather than per rod spec or vendor. Values to seed are in the *Alloy Lookup Table* in the **Seeded values** table below, which is itself marked as needing Process Engineering sign-off.

---


### Seeded values

Migrated from `ReferenceData.md` on 23 Aug 2026, when that document was retired: it held one table
and two caveats, had exactly **one** inbound link in the repository, and its own header claimed
citations from this file and from `phase-13` that neither actually carried. Keeping the seed values
away from the column definitions is what let its column list drift out of date - it still named
`GaugeToleranceDefault` and `WidthToleranceDefault`, which became min/max pairs on 1 Aug 2026.

Seeded by `FlatWire_SampleData_Lookup.sql`. **Maintained through the Phase-13 alloy-lookup admin
grid**, which is the non-deferrable half of that phase - these are editable reference data, not
hardcoded constants.

| Alloy | Max reduction / pass | Spring-back factor | Gauge tol. | Width tol. | Speed range (FPM) |
|---|---|---|---|---|---|
| 1100 | 26% | 0.98 | ± 0.003" | ± 0.010" | 800 - 2,000 |
| 1350 | 22% | 0.97 | ± 0.002" | ± 0.008" | 600 - 1,600 |
| 3003 | 24% | 0.98 | ± 0.004" | ± 0.012" | 700 - 1,800 |
| 5052 | 20% | 0.97 | ± 0.003" | ± 0.010" | 500 - 1,400 |
| 6061 | 18% | 0.96 | ± 0.003" | ± 0.010" | 400 - 1,200 |

> **The tolerance columns above are a single symmetric figure; the table is not.** Each `± x` seeds
> **both** halves of the corresponding min/max pair documented above. The pairs exist because `Q22`
> established the bands may be asymmetric; the seed simply has no asymmetric values yet.

> **These values must be confirmed and maintained by Process Engineering (Tim O.).**

> **⚠ `Spring-back factor` is a contested quantity - do not build physics on it.** Master
> specification **§10.5** arbitrates the springback model as wrong: the roll gap sits **below**
> gauge by a **load-dependent mill-spring** term (`h1 = S0 + F/K`), not above it by a fixed
> per-alloy multiplier, and springback (a **material** property) has been conflated with mill
> spring (**machine stiffness**). The column stays because `AlloyProperty` carries it and the
> schema is seeded from these values; **the pass-schedule generation that consumes it is MVP-2**,
> and `PassScheduleGenerationSpec.md` is the authority on the physics. It is harmless where it
> stands, but it is seeded with values that will be read as authoritative.

> **Rod diameter and ovality tolerances are deliberately absent.** They are owed by e-mail (`Q22`)
> and are seeded `NULL` rather than guessed.

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

## `DowntimeReason`

The **delay-code vocabulary** for the flattening lines, from the client's `Reason Codes.xlsx` (Tim O'Brien, 1 Sep 2026), which closes action `A4` of the 23 Jul call.

⚠ **This replaced the previous pause taxonomy; it did not extend it.** The repo carried **15 reasons in 5 semantic categories** (`EquipmentMechanical` / `MaterialHandling` / `QualityMeasurement` / `Operational` / `Safety`, with codes like `DieChangeMidRun`). The client's model is UA's existing delay-code system: **four *time* buckets** keyed to the throughput standard-time model. **Literal overlap between the two vocabularies was zero.** The 23 Jul ledger's `C1` warned exactly this — *"Tim's list either ratifies or replaces them — do not assume it extends them."*

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `DelayBucket` | varchar(10) | NOT NULL | — | `Setup` / `RunTime` / `Handling` / `Downtime` |
| `DelayCode` | varchar(10) | NOT NULL | — | `SET##` / `RUN##` / `HDL##` / `DWN##` — the client's own codes where they exist |
| `Description` | varchar(120) | NOT NULL | — | Client wording, **verbatim** — see the vocabulary note below |
| `IsNonprodTime` | bit | **NULL** | — | Does this code consume non-productive time? **Nullable for one row**: `DWN29 Other` has a blank cell on the sheet |
| `Status` | varchar(10) | NOT NULL | — | `Active` / `Inactive`; the client marks several inherited codes `Inactive` |
| `DelayBufferMin` | int | NOT NULL | — | Grace period in minutes before the delay counts |
| `SupervisorOverride` | bit | NULL | — | **`Downtime` bucket only** — the sheet carries this column on no other. `NULL` = the client did not state one |
| `IsProposedCode` | bit | NOT NULL | — | `1` = **the code string is ours.** The sheet leaves code, `Status` and `Delay Buffer` blank on all 36 new rows |
| `IsActive` | bit | NOT NULL | — | Soft delete, per the other lookups |

**Allowed values — `DelayBucket`:** `Setup`, `RunTime`, `Handling`, `Downtime`

**Constraints:**
- `UQ_DowntimeReason_Code` — `DelayCode` is unique
- `UQ_DowntimeReason_CodeBucket` — redundant on purpose: it is the FK target that lets `RunPauseEvent` constrain `(ReasonCode, ReasonCategory)` as a **pair**, so a `Setup` code cannot be filed under `Handling`
- `CK_DowntimeReason_Prefix` — the code prefix and the bucket must agree
- `CK_DowntimeReason_Override` — `SupervisorOverride` is `NULL` outside the `Downtime` bucket

**Which table consumes which bucket.** `Setup` / `RunTime` / `Handling` (**47 codes**) are `RunPauseEvent.ReasonCode` — a pause of a live run. `Downtime` (**25 codes**) is `LineDowntimeEvent` in [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md), because every `DWN` code is line-down time and `RunPauseEvent.RunId` is `NOT NULL`.

**Seed rows** (created by the DDL, not the sample-data script): **72** — 36 existing codes the client marked as applying, 36 new. The **83 codes the client marked as not applying are deliberately absent.**

> ⚠ **The workbook's meaning is in cell fill colour**, not text: yellow = applies, green = new, **no fill = does not apply** (unlabelled, and the largest group). Do not "complete" this list from the spreadsheet without re-reading the colours.

> ⚠ **Four previous reasons have no successor code**: `OperatorBreak`, `ShiftChangeover`, `AwaitingSupervisor`, `SafetyObservation`. `SET11 Prior Shift unaccountable` is not shift changeover and `DWN07 Fire Drill` is not a safety observation. Owed back to the client; **do not invent codes for them.**

> ⚠ **`Rewind Bundle` appears twice with different attributes** — `Nonprod = Yes` under `Setup` (`SET34`), `No` under `Handling` (`HDL24`). The attribute is per *(bucket, reason)*, never per reason.

---

## `WipRejectionReason`

The **WIP rejection vocabulary**, from the same workbook — action `A5`.

⚠ **The client's sheet has no grouping at all.** It is a flat list of 96 rows, 72 in scope. `WipRejection.RejectionGroup` is `NOT NULL`, so **every `RejectionGroup` value here is ours**, and every one is `[PROPOSED]`. `CK_WipRejection_Group` was **dropped** from `WipRejection` in `05_QualityOutput`: holding the vocabulary in two places guarantees drift the first time a group is reassigned.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `ReasonCode` | varchar(20) | NOT NULL | — | `WREJ###` — **ours.** The client's list carries no codes |
| `Description` | varchar(120) | NOT NULL | — | Client wording, **verbatim, typos included** (`wavy ege`) |
| `RejectionGroup` | varchar(30) | NOT NULL | — | `SurfaceQuality` / `Dimensional` / `WeldQuality` / `Material` / `Process` — **ours** |
| `IsProposedGroup` | bit | NOT NULL | — | `1` = the group assignment is not the client's. Currently `1` on **every** row |
| `IsNewForFlatWire` | bit | NOT NULL | — | `1` on the 8 the client marked as new |
| `IsActive` | bit | NOT NULL | — | Soft delete |

**Constraints:**
- `UQ_WipRejectionReason_Code` — `ReasonCode` is unique
- `UQ_WipRejectionReason_CodeGroup` — the FK target that lets `WipRejection` constrain `(RejectionReason, RejectionGroup)` as a **pair**, since that table denormalises the group onto the event row

**Why a minted code rather than the prose.** `WipRejection.RejectionReason` is `varchar(20)` and the longest client string is **56 characters** — *"Wire Brk Due To Holes, Laminations, Blisters, Inclusions"*. A stable code also survives the client rewording a label.

**Seed rows** (created by the DDL): **72** — 64 existing that apply, 8 new. The 24 not-applicable are absent; several are the *side*-scrap and coil-form reasons that do not exist on wire (`Excess Side Scrap`, `Coil Set`, `Crossbow`, `Earing`).

> ⚠ **No threading reason exists**, although the same mail's answer 4 requires threading to be recorded as a WIPREJ/scrap. Owed back to the client; **do not invent one.**

---

## `ItInhibitReason`

Why the `ITInhibit` tag is set. The mechanism is `[PLC §8]`; this is the vocabulary — action `A6`.

⚠ **The client's eight and the specification's five share exactly one.** `[PLC §8.2]` lists five set conditions; the sheet lists eight; the only overlap is *"no coil or rod is checked in"*. The specification's other four are **not loose prose** — they are `FR-008` / `FR-009` with alternate flows `ALT002`–`ALT005` / `DAT009` and **five P1 test cases, `TC-011`–`TC-015`**. Nobody has said they are superseded.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `ReasonCode` | varchar(20) | NOT NULL | — | `ITINH###` — ours |
| `Description` | varchar(200) | NOT NULL | — | Client or specification wording, verbatim |
| `Source` | varchar(10) | NOT NULL | — | `Client` (the sheet) or `PLC-8.2` (the specification only) |
| `IsNewForFlatWire` | bit | NOT NULL | — | `1` on the 2 the client marked as new |
| `IsActive` | bit | NOT NULL | — | **`0` on the four `PLC-8.2`-only rows** — present and traceable, evaluated by nothing, pending a client answer |

**Seed rows** (created by the DDL): **12** — 8 from the client (active), 4 from `[PLC §8.2]` only (**inactive**). Seeding all twelve keeps the union visible without deciding it: dropping the four would silently orphan two FRs and five P1 test cases, and activating them would decide a question the client has not been asked.

> ⚠ **`ITINH004 No Qualified Operators Are Logged In` cannot be evaluated by anything that exists.** It presumes the Leadman / Operator / Helper roles and the qualification matrix of the 23 Jul call's `C10`; `[SEC §8]` has six roles, neither Leadman nor Helper, and no matrix at all.

> ⚠ **`ITINH007 Supervisor Monitor` survives an answer that removes it.** The same mail's answer 9 is a flat **"No"** to a dedicated Supervisor Monitor, superseding `C13`'s *"desired but not required"*. The sheet still marks the reason as applying, and one attached screenshot shows *"Supervisor monitoring"* live on a real machine. A *screen* and *a supervisor is presently monitoring* are different things; which one sets this is owed back.

> **Not modelled, and on both real screenshots the client attached:** a **`Call Supervisor`** action on the inhibit dialog. It appears in no requirement.
