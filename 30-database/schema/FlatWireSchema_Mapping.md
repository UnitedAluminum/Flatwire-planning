# Flat Wire Mill — Schema Mapping & Entity Relationships

**Project:** Flat Wire Mill Implementation
**Last Updated:** September 3, 2026 — **`ToolingInventoryRollSet` added to the table inventory** (31 net-new tables), the fourth Tooling Inventory tool type (`D-42`). ⚠ It has **no legacy sheet behind it** — unlike every other row here, it originates from a client mail rather than from the source workbook. *(previously August 23, 2026 — **`Spool` and `SpoolCarrier` are SWAPPED (`Q60`).** The reusable stencilled article is now **`Spool`** in `01_Lookup`; the material record is now **`SpoolProcessing`** in `03_Materials`; `CarrierNo` → `SpoolNo`. ⚠ **A stale `Spool` reference is now *silently wrong*, not obviously stale** — see `[DBD §6.2a]`, the naming convention this closed. **`SpoolConfiguration` is also merged into `Spool`** — counts move to **33 tables · 55 FKs · 69 index statements**. *(previously August 23, 2026 — corrected up to the DDL; header fields standardised)*)*
**Document Type:** Legacy-to-new table mapping, the change-type inventory, and the collected enumeration reference. **Not** an ER diagram and **not** an FK list — both were deleted on 23 Aug 2026 in favour of `[DBD §7]`. The filename is kept because ~17 files cite it.
**Source:** the April gap analysis, now the appendix of [FlatWireSchema_Mapping.md](FlatWireSchema_Mapping.md) (absorbed 13 Aug 2026 when `FlatWireTables.md` was deleted; recoverable in git history)
**Target DB:** `FlatWireDB` (schema `dbo`)
**Status:** Active — corrected up to the DDL, August 23, 2026
**Scope:** MVP-1
**Owner:** Architecture stream / DBA
**Audience:** DBA, .NET developers, BA
**Part of:** `ProjectPlan/Database/` — the as-built model and the counted baseline are [`DatabaseDesign.md`](../DatabaseDesign.md) (`[DBD]`)
**Authority:** the DDL in `SQL/` wins on types, nullability and constraints, and the `CHECK` constraints win on every vocabulary listed here. No shortcode is declared, deliberately: this is a derived document and must not be cited as authority.

---

## Entity Relationship Diagram

**Deleted 23 Aug 2026.** This was an ASCII diagram that had fallen six tables behind the schema,
and it duplicated `[DBD §7]`, which carries the same model as eight mermaid diagrams generated
from the DDL. **See `[DBD §7.1]`-`§7.7`.**

## Foreign Key Reference Table

**Deleted 23 Aug 2026, and worth knowing why, because the same table will be proposed again.**

A hand-maintained list of every foreign key is not worth keeping when the DDL is the authority,
and this one proved it: it had been corrected three times and was **still** wrong on the day it
was removed - **37 data rows against 57 constraints in the script** - with the prose immediately
below it giving a fourth number (*"40 FKs and 06b adds 10, for 50"*). Its own correction note
recorded that an earlier published figure of "37" had been arrived at by **counting the rows in
this table rather than the script**, which is the failure mode in one sentence.

**What replaces it:**

- **The policy**, which is short and stable: every FK is created in `FlatWire_DDL_06_ForeignKeys.sql`
  after all tables exist, in one script; **no delete cascades** are declared and every constraint is
  `NO ACTION`; and the `OrderNo` columns on `SpoolOrder` / `RodOrderAllocation` /
  `RodOrderConsumption` deliberately have **no** FK, because `D-32` means there is no shared-schema
  migration to reference.
- **The counted total and the per-parent breakdown:** `[DBD §6.2]` and `[DBD §7.8]`.
- **The live answer**, which is always current:

```sql
SELECT  OBJECT_NAME(fk.parent_object_id)     AS ChildTable,
        COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
        OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
        fk.name                              AS ConstraintName
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
ORDER BY ChildTable, ConstraintName;
```

## Table Inventory

### Existing Tables (7) — Updated or Renamed

| Original Name | Final Name | Change Type | Schema File |
|---|---|---|---|
| `FlatLineProcessing` | `FlatWireRunDetail` | Renamed; run-level columns removed; `RunId` FK added | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `FlatLineSetup` | `PassScheduleComponent` | Renamed; restructured; `RollGap` → `ParameterValue`; `ComponentName` / `State` / `EdgeType` added | [FlatWireSchema_Schedule.md](./FlatWireSchema_Schedule.md) |
| `Drawer` | `Drawer` **+ `ToolingInventoryDie`** | **SPLIT 2 Sep 2026.** The legacy sheet mixed the draw box with its tooling. `Drawer` keeps the name and becomes the **two draw boxes** (`DB1`, `DB2`; `Name` and `LineId` CHECKs); `Diameter` → **`ToolingInventoryDie.HoleSizeIn`** along with the feed range and the die-life columns added 6 Aug 2026. ⚠ **`Q90`’s `Drawer` → `Die` rename is superseded** — the name is now correct | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Edger` | `Edger` | `EdgeType` / `IsActive` added; `Set` → `ToolingSetNo` | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Stand` | `Stand` | `MinId` / `MaxId` → `MinGaugeIn` / `MaxGaugeIn`; `MinOD` / `MaxOd` → `MinWidthIn` / `MaxWidthIn`; `LineId` / `IsActive` added | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `SpoolConfiguration` | ~~`SpoolConfiguration`~~ → **`Spool`** | Unit suffixes added to all dimension/weight columns; `MinId`/`MaxId` → `MinCoreDiameterIn`/`MaxCoreDiameterIn`. **Merged into `Spool` 23 Aug 2026 (`Q60`)** — the target table no longer exists; the six `Min/Max` columns and `Name` (as `SizeClass`) landed on the article | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `SpoolProcessing` | `SpoolProcessing` | `Alpha` / `Status` / `GaugeIn` / `WidthIn` / weights / `Location` / timestamps / `SourceRunId` / `LineId` added; `ParentRod` → `ParentRodAlpha` | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |

### New Tables (31) — Net New

*(Corrected twice. The heading read "16" against a list of 16 with an arithmetic that used 15; a 13 Aug 2026 pass said `RodStaging` and `PayoffPosition` had been added and **they had not been** — both were still absent on 23 Aug, along with the six tables built 20–22 Aug. All eight were added on 23 Aug 2026, at which point the inventory sums to **7 + 24 + 3 = 34** and matches the DDL exactly. The audit that first found the drift, `GapAnalysis.md`, was retired the same day — see [`CHANGELOG.md`](../../CHANGELOG.md).)*

| Table | Domain | Purpose | Schema File |
|---|---|---|---|
| `PassSchedule` | Schedule | Pass schedule header — alloy, line, targets, speed range | [FlatWireSchema_Schedule.md](./FlatWireSchema_Schedule.md) |
| `Rod` | Material | Wire rod receiving and lifecycle tracking | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |
| `FlatWireRun` | Runs | Run header — one row per check-in event | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RodCheckin` | Runs | Rod check-in events with inspection and SPC data | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `SpoolCheckin` | Runs | Spool check-in events at FL2/FL3 | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RunPauseEvent` | Runs | Pause/resume cycles within a run | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `WeldEvent` | Runs | Rod-to-rod weld join events | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RollOverride` | Runs | Run-level roll gap / die parameter adjustments | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `DieChangeEvent` | Runs | Die replacement events; gained `OldDieId` / `NewDieId` on 2 Sep 2026 | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `ToolingInventoryDie` | Lookup | **New 2 Sep 2026.** Register of physical dies — identity, hole size, type, lifecycle status, die life | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `DieHistory` | Runs | **New 2 Sep 2026.** One append-only log for a die’s installs, resets, retirements, threshold edits and per-run footage | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `ToolingInventoryRollSet` | Lookup | **New 3 Sep 2026 (`D-42`).** Register of physical roll sets — the **fourth** Tooling Inventory tool type. Mill rolls mount on a `Stand`, capstan rolls on a `Drawer`; one discriminated table, a grind life model, and **no legacy sheet behind it** | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `SpcCheckpoint` | Quality | SPC measurement session headers | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `SpcMeasurement` | Quality | Individual SPC measurement readings | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `WipRejection` | Quality | Material rejection events | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `CoilOutput` | Output | Finished output coil records | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `CoilTraceability` | Output | Rod-to-coil footage range mapping | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `RodCheckout` | Output | Rod removal from payoff position — **Mode A, Mode B and Mode P** *(Mode P, the pre-check-out, was missing here until 13 Aug 2026)* | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `Dancer` | Lookup | Tension-management rollers — one on FM1, two on FM2 (`D-28`) | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| **`RodStaging`** | Runs | **Pre-check-in / payoff staging** — the next rod registered against a VPS bay while the current coil still runs. Two **filtered unique** indexes enforce one rod per bay and one bay per rod. `Blocked` is a **derived** state (`Status='Staged'` + any inspection `Fail`), never a fourth `Status` value | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| **`PayoffPosition`** | Lookup | **Material input/output positions with pinned Ids, not IDENTITY** — 1 `Payoff1`, 2 `Payoff2`, 3 `TraversingTakeup`. Seeded by the DDL itself, because the `FlatWireRunDetail` FK depends on the rows existing | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `PayoffPosition` | Lookup | Material input/output positions, with **pinned non-IDENTITY Ids** so FK targets exist before the DDL that references them runs | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Spool` | Lookup | The **physical article** the wire is wound on, and, since the 23 Aug 2026 `SpoolConfiguration` merge (`Q60`), **its own size limits**. Stencil-keyed; format open (`Q42`) | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `RodStaging` | Runs | Pre-check-in payoff staging — the most heavily constrained table in the schema. `Blocked` is **derived**, not a fourth status | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `SpoolStaging` | Runs | The **FL2 pre-check-in queue**. Deliberately not `RodStaging`: one payoff, no inspection columns, no station claim, and a fractional non-unique `QueuePosition` | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RodOrderConsumption` | Runs | What a check-in **actually** consumed, per order — one check-in, N rows. Two weight latches, and the overrun between them is captured | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `SpoolTraceability` | Material | Which rod produced which feet of a **spool** — the spool-side half of the welding-wire genealogy (`FR-333`, `G42`) | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |
| `SpoolOrder` | Material | The orders a spool is committed to. **Derived** from `RodOrderAllocation`, with the order boundary in pounds (`G48`) | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |
| `RodOrderAllocation` | Material | The **plan**: which orders a rod is committed to, and in what sequence. Split point held in pounds, never feet | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |

| `DowntimeReason` | Lookup | The **delay-code vocabulary** — four time buckets, 72 codes. Replaced the 15-reason/5-category pause taxonomy outright (client, 1 Sep 2026) | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `WipRejectionReason` | Lookup | The **WIP rejection vocabulary** — 72 reasons. The client supplied no groups, so every `RejectionGroup` is ours and `[PROPOSED]` | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `ItInhibitReason` | Lookup | Why `ITInhibit` is set — 8 client reasons plus the 4 `[PLC §8.2]` conditions the client omitted, seeded **inactive** | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `LineDowntimeEvent` | Runs | **Line-scoped** downtime intervals. Exists because `RunPauseEvent.RunId` is `NOT NULL` and all 25 `DWN##` codes are line-down time | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |

### Production-Readiness Additions (3) — July 26, 2026

| Table | Domain | Purpose | Schema File |
|---|---|---|---|
| `AlloyProperty` | Lookup | Per-alloy generator inputs + footage→weight factor; authoritative alloy list | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `PassScheduleChangeLog` | Schedule | Override/edit/acknowledgment audit trail (OQ-62) | [FlatWireSchema_Schedule.md](./FlatWireSchema_Schedule.md) |
| `RunReading` | Runs | Sampled gauge/width/speed profile per run (G3) | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |

**Table count: `[DBD §6.2]`.** That section is the only site in the repository that states it, and this document does not restate it. What this inventory adds, and `[DBD]` does not carry, is the per-table **change type** — `Renamed`, `Added`, and the date — which is what a legacy migration needs.

---

## Enumeration Reference

> **Derived and non-authoritative.** Every vocabulary below is enforced by a `CHECK` constraint in
> the DDL, and **the constraint wins**. This sheet is collected here because one place to read all
> of them earns its keep; it is not a source. If it disagrees with the DDL, the DDL is right and
> this is stale.

### Material Status Values
*Used by:* `Rod.Status`, `SpoolProcessing.Status`, `CoilOutput.Status`, `RodCheckout.NewRodStatus`, `WipRejection.NewMaterialStatus`

| Value | Applicable To | Meaning |
|---|---|---|
| `RECEIVED` | Rod, Spool | Received from supplier or FL1; not yet staged |
| `STAGED` | Rod, Spool | Positioned at a payoff position; ready for check-in |
| `INFLAT` | Rod, Spool | Currently in-process on a flat wire line |
| `COMPLETE` | Rod, Spool, CoilOutput | Fully processed; output produced |
| `HOLD` | Rod, Spool, CoilOutput | On hold pending quality or supervisor review |
| `SCRAP` | Rod, Spool, CoilOutput | Scrapped; no longer usable |

### Run Status Values
*Used by:* `FlatWireRun.Status`

| Value | Meaning |
|---|---|
| `Running` | Run is actively processing |
| `Paused` | Run is paused; an open `RunPauseEvent` exists |
| `Complete` | Run completed normally |
| `Aborted` | Run terminated abnormally |

### Pass Schedule Status Values
*Used by:* `PassSchedule.Status`

| Value | Meaning |
|---|---|
| `Draft` | Schedule is being configured; not yet approved for production |
| `Active` | Schedule is approved and selectable at check-in |
| `Inactive` | Schedule is retired; no longer selectable |

### Component Name Values
*Used by:* `PassScheduleComponent.ComponentName`, `RollOverride.ComponentName`

| Value | Type | Line Applicability | Description |
|---|---|---|---|
| `DB1` | Draw box | FL1, FL2, FL3 | First draw box — primary die reduction |
| `DB2` | Draw box | FL1, FL2, FL3 | Second draw box — secondary die reduction |
| `FM1` | Finishing mill | FL1, FL2, FL3 | First finishing mill stand |
| `EdgeSet` | Edger | FL1, FL2, FL3 | Edge profile tooling station |
| `FM2_S1` | Finishing mill | FL2, FL3 | FM2 stand **S1 — 8-inch roller**; bypassable, no edger |
| `FM2_S2` | Finishing mill | FL2, FL3 | FM2 stand **S2 — 6-inch roller**; bypassable, edger position |
| `FM2_S3` | Finishing mill | FL2, FL3 | FM2 stand **S3 — 6-inch roller**; edger position, **final gauge control, not bypassable** |

*Note: `FM1` is not bypassable; `EdgeSet` is FL1-legacy (FL1 has no edger per the May-21-2026 revision — edgers are at FM2 S2/S3).*

> **FM2 correction `[CONFIRMED — Aug 4 2026]`:** FM2 has **three** stands, not four — the 8" roller **is S1**. Renamed `FM2_8in`→`FM2_S1`, `FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`; `FM2_6inS3` withdrawn. Roll diameter is now `Stand.RollDiameterIn` (8.000 / 6.000 / 6.000) rather than part of the name. Closes **OI-04**.

### Component State Values
*Used by:* `PassScheduleComponent.State`

| Value | Meaning |
|---|---|
| `Active` | Component is engaged and processing material |
| `Bypass` | Component is present on the line but bypassed (material flows through without processing) |
| `Skip` | Component is not part of this schedule (not applicable to this line/alloy combination) |

### Route Mode Values
*Used by:* `PassSchedule.RouteMode`, `FlatWireRun.RouteMode`

| Value | Meaning |
|---|---|
| `Standalone` | Single-line processing; output is a direct finished coil |
| `Hybrid` | FL1 produces pre-drawn spools; spools feed FL2 or FL3 for further reduction |

### SPC Checkpoint Type Values
*Used by:* `SpcCheckpoint.CheckpointType`

| Value | Trigger |
|---|---|
| `PreRun` | Performed before the run starts |
| `PostDieChange` | Auto-triggered by a `DieChangeEvent` |
| `ManualSpotCheck` | Operator-initiated ad-hoc check |
| `PostRun` | Performed at run completion |
| `RollAdjustTrigger` | Triggered by a roll gap adjustment |

---

## Alpha Identifier Formats

| Entity | Format | Example |
|---|---|---|
| Rod | `R{5 digits}` | `R00041` |
| Spool | `SP-{5 digits}` | `SP-00021` |
| Run | `RUN-{4 digits}` | `RUN-0042` |
| Pass Schedule | `PS-{Alloy}-{Line}-{Seq}` | `PS-1100-FL1-003` |
| Weld Event | `WLD-{3 digits}` | `WLD-002` |
| Roll Override | `OVR-{4 digits}` | `OVR-0042` |
| Die Change | `DC-{4 digits}` | `DC-0041` |
| SPC Checkpoint | `SPC-{4 digits}` | `SPC-0041` |
| WIP Rejection | `REJ-{4 digits}` | `REJ-0041` |
| Rod Checkout | `CO-{4 digits}` | `CO-0041` |
| Coil Output | `FW-{5 digits}-C{2 digits}` | `FW-00421-C01` |

> **MMS ID** (per input coil) is captured on `RodCheckin.MmsId` / `SpoolCheckin.MmsId` (generated at check-in, closed on consumption). Intermediate-spool numbering canonical format is `SP-#####` (narrative `TS######` retired, pending Tim O. confirmation).

---

### Staging Status Values

| Value | Table | Meaning |
|---|---|---|
| `Staged` | `RodStaging` | On the payoff, awaiting check-in |
| `CheckedIn` | `RodStaging` | Acknowledged on Dashboard 2; the run exists |
| `Unstaged` | `RodStaging` | Released from the bay — see `UnstageKind` for why |
| `Queued` | `SpoolStaging` | In the FL2 queue; the filtered unique index keys on this value |
| `CheckedIn` | `SpoolStaging` | Taken into a run |
| `Withdrawn` | `SpoolStaging` | Removed from the queue without running |

> **`Blocked` is not in this list, and that is deliberate.** It is a **derived** bay state —
> `Status='Staged'` plus any inspection column `='Fail'` — never a stored fourth value. Any code
> branching on "staged" therefore also matches blocked *and* welded rods unless it says otherwise.

### Unstage and Checkout Values

| Column | Values |
|---|---|
| `RodStaging.UnstageKind` | `PreCheckOut`, `WipRejection` — NULL while `Status='Staged'`. The `WipRejectionId` link is present **exactly** when this is `WipRejection` |
| `RodCheckout.Mode` | `ModeA` (post-acknowledgement, zero footage), `ModeB` (mid-run, footage produced — supervisor approval required), `ModeP` (pre-check-out, before the run) |

### Rejection and Pause Values

| Column | Values |
|---|---|
| `WipRejection.RejectionGroup` | the rejection taxonomy — enforced by `CHECK`; read the constraint |
| `WipRejection.Disposition` | the disposition taxonomy — likewise |
| `RunPauseEvent.Outcome` | the four resume outcomes. **Rod checkout is the fourth** — it is *not* a pause reason (closes `OI-14`, supersedes `FR-262`) |

### Rod ↔ Order Values

| Column | Values |
|---|---|
| `RodOrderAllocation.PinRole` | `Sole`, `PinnedFirst`, `Free`, `PinnedLast`, `PinnedBoth` — **stored, not derived**: the sequence validator reads it on every scan |
| `RodOrderAllocation.RodKind` | `Full`, `Partial` (`Q73`'s tier-2 discriminator; `Partial` is a back-to-stock remainder) |
| `RodOrderAllocation.Source` | `Planned`, `Derived`, `Substituted` |
| `RodOrderConsumption.State` | `Pending`, `InProgress`, `ThresholdReached`, `Closed`, `Voided` |
| `RodOrderConsumption.ClosureReason` | `Acknowledged`, `AcknowledgedEarly`, `RodExhausted`, `RodAbandoned`, `Superseded` |
| `RodOrderConsumption.ConversionBasis` | `Nominal`, `Measured`, `IntegratedRunReading`, `Override` — the dimensional basis itself is open (`Q10`, `OI-45`) |
| `SpoolOrder.Source` | `Derived` (union of the rods' orders, computed at spool creation), `Planned` (an explicit allocation superseding the derived row) |

### Dancer Values

`Dancer` carries a per-line position and a tension mode. **FM1 has one dancer; FM2 has two**, sitting
**between** stands — between S1/S2 and between S2/S3 — rather than at them (`D-28`, 6 Aug 2026). The
vocabularies are enforced by `CHECK` in `01_Lookup`; read the constraint rather than copying values here.

### Shared-schema vocabularies

`MmsStatus` and the skid status values are **shared-schema** vocabularies, not `FlatWireDB` ones —
they belong to `united_db` / `proddb` and are constrained there. `[INT §8.0]` and `[INT §8.1]` are
authoritative; this document deliberately does not restate them, because a local copy of a value
another module owns is the drift this section's banner warns about.

## Appendix — the pre-existing tables this schema replaced

> **Absorbed from `FlatWireSchema_Mapping.md` on 13 Aug 2026**, which was deleted in the same pass. It was the April
> gap analysis — *what existed, what was missing, what to add* — and the "missing tables" half is now
> superseded by the DDL. **This half is not**: it is the only surviving inventory of the legacy
> `FlatLineProcessing` / `FlatLineSetup` / `Drawer` / `Edger` / `Stand` / `Spool` / `SpoolProcessing`
> columns, and **`OI-31` / `G8` record that no legacy migration deliverable exists**. Deleting it would
> have left that migration with nothing to migrate *from*.
>
> ### ⚠ Every bare `decimal` below is an artifact of the source, not a specification
>
> Bare **`decimal`** in SQL Server means **`decimal(18,0)` — zero decimal places**. The DDL correctly uses
> `DECIMAL(8,2)` for weights, `DECIMAL(8,4)` for gauges and diameters, and `DECIMAL(10,2)`/`(10,4)` for
> footage and measures. **Regenerating DDL from the tables below would round every weight, gauge and
> measurement to a whole number** (`REVIEW.md` Tier 3 #18). Read each bare `decimal` as "see the DDL".

---

#### `FlatLineProcessing`

Stores per-stop and per-sequence detail records for a flat wire run. The parent/header record is the new `FlatWireRun` table (see Missing Tables). Each row captures footage, gauge measurements, and output dimensions for one stop within a run. Rename this table to `FlatWireRunDetail`.

##### Current columns
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

##### Issues
- **No `RunId` FK** — no link to the parent `FlatWireRun` header record; stop rows cannot be associated with a run without it.
- **`CoilOrderPlanId` vs `PlanId`** — relationship between these two is unclear; may be redundant.
- **Missing dimensional tolerances** — `TargetGauge`, `GaugeTolerance`, `TargetWidth`, `WidthTolerance` are needed for in-process quality checks.
- **Naming and scope**: `FlatLineProcessing` conflates run-header and stop-detail concerns. Rename to `FlatWireRunDetail`. Run-level fields (`Status`, `RouteMode`, `LineId`, `PassScheduleId`, `StartedAt`, `PausedAt`, `CompletedAt`) belong on the new `FlatWireRun` header table, not on per-stop rows.

##### Recommended updated columns

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

#### `PassScheduleComponent` *(renamed from `FlatLineSetup`)*

Renamed and restructured from `FlatLineSetup`. Each row defines one component slot in a pass schedule — its tool selection, operating state, and parameter value. Belongs to a `PassSchedule` header via `PassScheduleId`. Requires a new `PassSchedule` header table (see [Missing Tables](#missing-tables)).

> ⚠ **Provenance — the source sheet is named `FlatLinePassSchedule`, not `FlatLineSetup`.** In
> `95-archive/source-documents/flatwire tables.xlsx` the eight sheets are `Drawer`, `Edger`,
> `RollerInfo`, `SpoolConfiguration`, `SpoolCoilMapping`, `Spool`, **`FlatLinePassSchedule`** and
> `FlatLineProcessing`. This repository calls it `FlatLineSetup` throughout and the rename is
> unrecorded. **The legacy name stays** — `FlatLineSetup` is cited by `D-13`, `[DBD §188]`,
> `[MSP §1473/1487/2164/3140/3362]` and the DDL, and register names are never swept. This note
> exists so the citation resolves against the workbook. The source name also corroborates what the
> table is: a **pass schedule**, which the client's 31 Aug 2026 Flattening Line Schedule screen
> confirms independently.
>
> ⚠ **This inventory does not reconcile with that sheet — see `OI-142`.** The sheet's eleven columns
> are `Id · RollerInfoId · StandSequence · DrawerId · DrawerSequence · EntryGauge · ExitGauge ·
> EdgerId · RollGap · PassNo · SpoolTypeId`. The *"Removed from `FlatLineSetup`"* table below names
> six columns to remove of which **only three are among them**; `SpoolId`, `MfgOrderNo` /
> `HomeMfgOrderNo`, `StopNo` / `SequenceNo` and `PlanId` are **`FlatLineProcessing`** columns. And
> **`RollerInfoId`, `PassNo` and `SpoolTypeId` are never accounted for anywhere.** `PassNo` is worth
> noting on its own: the legacy design was **pass-numbered**, while the client's replacement grid is
> **component-sequenced** with no pass number — which is why `Sequence` replaced it.
>
> ⚠ **This is the only legacy table with no `Current columns` section**, unlike `FlatLineProcessing`,
> `Drawer`, `Edger`, `Stand` and `SpoolProcessing` — in an appendix whose stated purpose is to be
> *"the only surviving inventory of the legacy … columns."* Reconstruct it from the eleven above.

##### Columns

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

##### Removed from `FlatLineSetup`

| Column | Reason |
|---|---|
| `RollGap` | Consolidated into `ParameterValue` (covers both roll gap and die size) |
| `StandSequence` / `DrawerSequence` | Consolidated into single `Sequence` column |
| `SpoolId` | Does not belong on a component row |
| `MfgOrderNo` / `HomeMfgOrderNo` | Belongs on the `PassSchedule` header, not per-component |
| `StopNo` / `SequenceNo` | Belongs on run records (`FlatWireRunDetail`) |
| `PlanId` | Belongs on the `PassSchedule` header |

---

#### `Drawer`

Represents draw box / wire drawing die configurations (DB1, DB2).

##### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Diameter` | decimal | Die diameter |
| `Name` | varchar | Die name/identifier |

##### Issues
- No dimensional constraints (`MinDiameter`, `MaxDiameter`).
- Column name `Diameter` is too generic — this is the **die hole diameter**; rename to `DiameterIn` for clarity and unit consistency.
- No `IsActive` or `Status` column for managing retired dies.

##### Recommended updated columns
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

#### `Edger`

Represents edger tooling configurations (EdgeSet component).

##### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Name` | varchar | Edger name |
| `Set` | varchar/int | Configuration set number |

##### Issues
- **Missing `EdgeType`** — `Round` vs `Square` edge profile is a required field in the API contract (`PassScheduleComponentDto.EdgeType`). Every pass schedule involving an edger must specify this.
- `Set` column purpose is unclear — if it means a tooling set number, rename to `ToolingSetNo` for clarity.

##### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Name` | varchar(50) | Keep |
| `EdgeType` | varchar(10) NOT NULL | **Add** — `Round` or `Square` |
| `ToolingSetNo` | varchar(20) NULL | **Rename** from `Set` |
| `IsActive` | bit NOT NULL | **Add** |

---

#### `Stand`

Represents rolling mill stands (FM1, FM2 variants).

##### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `Name` | varchar | Stand name — position only (`FM1`, `FM2_S1`, `FM2_S2`, `FM2_S3`); roll diameter lives in `RollDiameterIn` |
| `MinId` | decimal | Minimum — likely Inner Diameter |
| `MaxId` | decimal | Maximum ID |
| `MinOD` | decimal | Minimum Outer Diameter |
| `MaxOd` | decimal | Maximum OD |

##### Issues
- **`MinId`/`MaxId`** column names are ambiguous — `Id` typically means primary key in .NET/SQL Server conventions. Rename to `MinInsideDiameterIn` / `MaxInsideDiameterIn`, or if these refer to gauge: `MinGaugeIn` / `MaxGaugeIn`.
- `MinOD`/`MaxOd` — casing inconsistency (`OD` vs `Od`). Standardize.
- No `LineId` — if certain stands only exist on specific lines (FL1 vs FL2/FL3), this needs tracking.

##### Recommended updated columns
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

#### ~~`SpoolConfiguration`~~ — merged into `Spool`, 23 Aug 2026 (`Q60`)

Was a reference table for spool types with physical dimensional and weight constraints. It held one
meaningful row against 30–45 articles, so its six `Min/Max` columns and its `Name` (as `SizeClass`)
were folded into `Spool` itself. **The table no longer exists** — the mapping below is retained as the
record of what was mapped, not as a live target.

##### Current columns
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

##### Issues
- Same `MinId`/`MaxId` naming ambiguity as `Stand` — rename to `MinInsideDiameterIn`/`MaxInsideDiameterIn` (or `MinCoreDiameterIn` for spools).
- No units suffix on weight — add `Lb` suffix.

##### Recommended updated columns
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

#### `SpoolProcessing`

Represents a physical spool of pre-processed flat wire (used at FL2 check-in).

##### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| ~~`SpoolTypeId`~~ | int | **Dropped 23 Aug 2026** — `SpoolConfiguration` merged into `Spool`; the article is reached via `SpoolId` |
| `OrderNo` | varchar | |
| `RelLetter` | varchar | Release letter |
| `ParentRod` | varchar | The rod alpha that was drawn into this spool |

##### Issues
- **Missing `Alpha`** — every material tracked in the system has an alpha identifier (e.g. `SP-00021`). This is the primary lookup key used in API calls (`GET /rod/{alpha}`, `POST /checkin/spool`). A spool with no alpha cannot be scanned or looked up.
- **Missing `Status`** — `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP`.
- **Missing physical dimensions** — `GaugeIn`, `WidthIn` are required for FL2 check-in validation.
- **Missing weights** — `GrossWeightLb`, `NetWeightLb`.
- **Missing location** — `Location` for floor tracking.
- **Missing `LineId`** — which line produced/is processing this spool.
- **Missing `RunId`** — which FL1 run produced it (for source traceability on Dashboard 5).
- **Missing timestamps** — `ReceivedAt`, `StagedAt`.
- `ParentRod` is a good field; retain as `ParentRodAlpha`.

##### Recommended updated columns
| Column | Type | Change |
|---|---|---|
| `Id` | int PK | Keep |
| `Alpha` | varchar(20) NOT NULL UNIQUE | **Add** — e.g. `SP-00021`; scanned at FL2 check-in |
| ~~`SpoolTypeId`~~ | int | ~~Keep~~ — **dropped 23 Aug 2026** with the `SpoolConfiguration` merge (`Q60`) |
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
