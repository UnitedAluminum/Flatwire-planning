# Flat Wire Mill — Run Tracking Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 25, 2026 — `CK_RodStaging_LineId` explained as correctly unchanged by the FL2 reversal *(previously August 23, 2026 — **`Spool` and `SpoolCarrier` are SWAPPED (`Q60`).** The reusable stencilled article is now **`Spool`** in `01_Lookup`; the material record is now **`SpoolProcessing`** in `03_Materials`; `CarrierNo` → `SpoolNo`. ⚠ **A stale `Spool` reference is now *silently wrong*, not obviously stale** — see `[DBD §6.2a]`, the naming convention this closed. **`SpoolConfiguration` is also merged into `Spool`** — counts move to **33 tables · 55 FKs · 69 index statements**. *(previously August 23, 2026 — corrected up to the DDL; header fields standardised)*)*
**Document Type:** Final Schema — Run Tracking Tables
**Source:** the April gap analysis, now the appendix of [FlatWireSchema_Mapping.md](FlatWireSchema_Mapping.md) (absorbed 13 Aug 2026 when `FlatWireTables.md` was deleted; recoverable in git history)
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `../sql/FlatWire_DDL_04_Runs.sql` (`FlatWireRun` itself is created in `DDL_03`)
**Status:** Active — corrected up to the DDL, August 23, 2026
**Scope:** MVP-1
**Owner:** Architecture stream / DBA
**Audience:** DBA, .NET developers, BA
**Part of:** `ProjectPlan/Database/` — the as-built model and the counted baseline are [`DatabaseDesign.md`](../DatabaseDesign.md) (`[DBD]`)
**Authority:** `../sql/FlatWire_DDL_04_Runs.sql` **wins** on types, nullability and constraints. This document explains them; it does not define them, and it states no object counts — those are `[DBD §6.2]`. No shortcode is declared, deliberately: these are derived documents and must not be cited as authority.

Run tables capture the complete lifecycle of a flat wire production run — from initial check-in through all in-process events. `FlatWireRun` is the central header record; all event tables reference it by `RunId`.

---

## `FlatWireRun`

Core run header table. One row is created when the first rod or spool is checked in to a flat wire line. All in-process events (pauses, welds, overrides, SPC checkpoints) are children of this record via `RunId`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL UNIQUE | — | Unique run identifier (e.g. `RUN-0042`); referenced by all child event tables |
| `LineId` | varchar(5) | NOT NULL | — | Flat wire line executing this run: `FL1`, `FL2`, or `FL3` |
| `OrderId` | varchar(20) | NOT NULL | — | Manufacturing order number associated with this run |
| `PassScheduleId` | varchar(30) | NOT NULL | `PassSchedule.ScheduleId` | FK to the pass schedule — defines die sizes, roll gaps, and component states for this run |
| `Alloy` | varchar(10) | NOT NULL | — | Aluminum alloy; denormalized from `PassSchedule.Alloy` for query convenience — keep in sync if the alloy ever changes |
| `RouteMode` | varchar(15) | NOT NULL | — | `Standalone` or `Hybrid`; governs whether FL1 output is packaged as spools for FL2/FL3 |
| `Status` | varchar(20) | NOT NULL | — | Run lifecycle state — see allowed values |
| `StartedAt` | datetimeoffset | NOT NULL | — | Timestamp when the first rod or spool was checked in and the run began |
| `PausedAt` | datetimeoffset | NULL | — | Timestamp of the current active pause; NULL when the run is not currently paused |
| `CompletedAt` | datetimeoffset | NULL | — | Timestamp when the run was completed or aborted; NULL while still active |
| `FootageFt` | decimal(10,2) | NOT NULL | — | Cumulative footage counter in feet; updated in real time by PLC integration; starts at 0 (standardized to `decimal(10,2)`) |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator who initiated the run |
| `CreatedBy` | varchar(50) | NULL | — | Audit (StartedAt serves as created timestamp) |
| `ModifiedBy` | varchar(50) | NULL | — | Audit: last modifier |
| `ModifiedAt` | datetimeoffset | NULL | — | Audit: last-modified timestamp |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token (FootageFt/Status updated live) |

**Allowed values:**
- `Status`: `Running`, `Paused`, `Complete`, `Aborted`
- `RouteMode`: `Standalone`, `Hybrid`

---

## `FlatWireRunDetail`

*(Renamed from `FlatLineProcessing`)*

Per-stop and per-sequence detail records for a run. Each row captures footage, gauge measurements, and output dimensions at a specific stop point within a run. Child of `FlatWireRun`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the parent run record |
| `SetupNo` | varchar(20) | NULL | — | Legacy setup number from `FlatLineProcessing`; retained for historical traceability |
| `StopNo` | int | NOT NULL | — | Sequential stop number within this run |
| `SequenceNo` | int | NOT NULL | — | Sub-sequence number within a stop |
| `PlanId` | int | NULL | — | FK to the production planning table |
| `CoilOrderPlanId` | int | NULL | — | FK to the coil-level order plan; review for redundancy with `PlanId` |
| `HomeMfgOrderNo` | varchar(50) | NULL | — | Home or parent manufacturing order number |
| `PayoffPositionId` | int | NOT NULL | `PayoffPosition.Id` | FK to the payoff position reference — `1` Payoff1, `2` Payoff2, `3` TraversingTakeup. The parent table now exists (`FlatWireSchema_Lookup.md`); previously this was an FK-style int with no parent (REVIEW.md #15) |
| `FootageFt` | decimal | NOT NULL | — | Footage counter reading at which this stop event occurred |
| `OnGaugeWeight` | decimal | NULL | — | Weight of on-gauge material produced to this stop point, in pounds |
| `TargetGauge` | decimal | NULL | — | Target gauge for quality control at this stop, in inches |
| `GaugeTolerance` | decimal | NULL | — | Acceptable gauge deviation (±) at this stop, in inches |
| `TargetWidth` | decimal | NULL | — | Target width at this stop, in inches |
| `WidthTolerance` | decimal | NULL | — | Acceptable width deviation (±) at this stop, in inches |
| `StartGauge` | decimal | NULL | — | Actual gauge measurement at the start of this stop, in inches |
| `ExitGauge` | decimal | NULL | — | Actual gauge measurement at the exit of this stop, in inches |
| `OutputOD` | decimal | NULL | — | Output coil or spool outer diameter at this stop, in inches |
| `OutputID` | decimal | NULL | — | Output coil or spool inner diameter (core) at this stop, in inches |

---

## `RodStaging`

**Pre-check-in.** The next rod is registered against a VPS payoff bay while the current coil is still running, so the line can run continuously through an induction weld. One row per staging event. No `RunId` — a staged rod has no run yet, and **no PLC tags are pushed at this stage**.

Implements SRS §4.2 `PCI001`–`PCI008`, `WLD003`/`WLD010` (Mark as Welded), `TRV004`/`TRV009` (Traveler Queue), and the §4.18 `PRC007` carry-forward gate. **FL1 and FL3 only** — `PCI002` excludes FL2, which has no staging space.

Supersedes the retired `Rod.StagedPayoffPosition` / `Rod.IsWelded` columns.

> **Planned order is authorised, not enforced — and both sequences are retained.** Rods are planned in a predefined order (say `R00043 → R00044 → R00045`). Departing from it is permitted, but it is **not** the operator's unilateral call: the operator is **notified** that the rod is not the one planning expects next, and a **supervisor authorises** the deviation (`OutOfSequenceOverride`). It is never a hard refusal — the commit control stays reachable once signed off.
>
> There is deliberately **no constraint relating `PlannedSeqno` to `RodSeqno`**. A difference between them is a legitimate, authorised outcome, not a data error; the authorisation columns are what make it accountable.
>
> That is why this table carries **two** sequence columns rather than one. `RodSeqno` records what actually happened, for traceability; `PlannedSeqno` preserves what planning intended, for reporting. Variance is then a subtraction rather than a reconstruction.
>
> *(Superseded July 30 2026: an earlier requirement had the operator free to re-order without any authorisation. The notify-and-authorise rule replaces it.)*
>
> `PlannedSeqno` is a **snapshot**, not a live join back to planning — the same pattern the design already uses for the pass schedule, whose id, version and effective date are copied onto the run record at check-in rather than re-resolved later. A traceability record that has to reach into current planning data years afterwards to answer "was this run in planned order?" is exactly the join that breaks.
>
> Do not read `PCI008` ("surface pre-checked-in material during weld selection **to enforce sequencing**") as planned-order enforcement. It means *physical* weld sequencing — the weld defaults to whichever rod is actually staged on the idle bay, and the operator can still override by scanning.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `LineId` | varchar(5) | NOT NULL | — | Line the bay belongs to: `FL1` or `FL3` |
| `PayoffPosition` | int | NOT NULL | `PayoffPosition.Id` | Intended payoff bay: `1` or `2` (`PCI006`) |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | FK to the rod being staged |
| `RodSeqno` | int | NOT NULL | — | **Actual** processing sequence, assigned here at pre-check-in. This is the SRS `FlatwireQueue` sequence (`Rodno`/`RodSeqno`/`Welded`), which that model inserts at pre-check-in. Monotonic per line. Drives Traveler Queue ordering |
| `PlannedSeqno` | int | NULL | — | **Planned** sequence, snapshotted at staging. NULL when the rod has no planned position (e.g. a substitution). See the free-order note below |
| `IsWelded` | bit | NOT NULL | — | `1` once the induction weld to the running rod is recorded **and passes its quality check** (`WLD010`); default `0`. Set by `POST /weldevent` in the same transaction as the `WeldEvent` row — **on `WeldQuality = 'Pass'` only**. A failed weld writes the event and leaves this `0`, because the join did not hold and the rod is not joined to the running rod |
| `Status` | varchar(12) | NOT NULL | — | `Staged` → `CheckedIn`, or `Unstaged` — see allowed values |
| `OrderId` | varchar(20) | NULL | — | Order this rod is staged against, **resolved from `planning_routings` at the scan** — never typed. On a cold line this is what the first rod reveals |
| `OutOfSequenceOverride` | bit | NOT NULL | — | `1` when the rod was **not the one planning expected next** and a supervisor authorised the deviation; default `0`. **The only staging deviation** since the off-schedule case became an auto-switch |
| `ExpectedRodAlpha` | varchar(20) | NULL | — | The rod planning expected next, captured at the moment of deviation. Set exactly with `OutOfSequenceOverride`, and must differ from `RodAlpha` |
| `OverrideBy` | varchar(50) | NULL | — | Authorising supervisor badge/ID. **The PIN is never stored** |
| `OverrideAt` | datetimeoffset | NULL | — | Timestamp of the authorisation |
| `OverrideReason` | varchar(200) | NULL | — | Why the planned sequence was departed from |
| `ScrapBoxRef` | varchar(20) | NULL | — | Optional scrap box, same-alloy carry-forward as check-in (`PCI005`) |
| `DiameterIn` | decimal(8,4) | NOT NULL | — | Diameter measured at staging (`PCI004`), in inches |
| `GrossWeightLb` | decimal(8,2) | NOT NULL | — | Gross weight at staging, in pounds |
| `NetWeightLb` | decimal(8,2) | NOT NULL | — | Net weight at staging, in pounds |
| `FootageRunToDateAtStaging` | decimal(10,2) | NOT NULL | — | Rod's prior footage captured at the staging scan; `> 0` forces the carry-forward path (`PRC007`) and blocks the fresh-start path. Default `0` |
| `InspectionOxidation` | varchar(10) | NOT NULL | — | Visual oxidation result before unbanding: `Pass` or `Fail` |
| `InspectionSurfaceDefects` | varchar(10) | NOT NULL | — | Visual surface defect result: `Pass` or `Fail` |
| `InspectionWaterStains` | varchar(10) | NOT NULL | — | Water stain result: `Pass` or `Fail` |
| `InspectionNotes` | varchar(500) | NULL | — | Free-text observation; expected when any item fails |
| `StagedAt` | datetimeoffset | NOT NULL | — | Timestamp the rod was staged |
| `StagedBy` | varchar(50) | NOT NULL | — | Operator who staged it |
| `WeldedAt` | datetimeoffset | NULL | — | Timestamp of the passing weld (`WLD003`). Set with `IsWelded`, from the `WeldEvent` write |
| `WeldedBy` | varchar(50) | NULL | — | Operator who recorded the passing weld (`WLD003`). Set with `IsWelded`, from the `WeldEvent` write |
| `CheckedInAt` | datetimeoffset | NULL | — | Set when check-in consumes this staged row |
| `RodCheckinId` | int | NULL | `RodCheckin.Id` | FK closing the staging → check-in chain |
| `UnstagedAt` | datetimeoffset | NULL | — | Timestamp of the release — pre-check-out **or** WIP rejection |
| `UnstagedBy` | varchar(50) | NULL | — | Operator who released it |
| `UnstageReasonCode` | varchar(40) | NULL | — | Release reason code |
| `UnstageKind` | varchar(20) | NULL | — | **How** the bay was released: `PreCheckOut` or `WipRejection`. Required whenever `Status = 'Unstaged'` |
| `WipRejectionId` | int | NULL | `WipRejection.Id` | The rejection that released the bay. Present exactly when `UnstageKind = 'WipRejection'` |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

> **Dropped 1 Aug 2026 — `OffScheduleOverride`, `ScheduledLineId`.** A rod whose order is booked on the **other** rod line is no longer a deviation: the station **switches to the correct line automatically**, with no message and no override, at both pre-check-in and check-in (**Q24**, client 30 Jul 2026). `CK_RodStaging_OffSched` and `CK_RodStaging_OffSchedLine` went with them, and `CK_RodStaging_Override` — generalised on 30 Jul to cover *either* deviation — reverts to keying on `OutOfSequenceOverride` alone.
>
> **`OverrideBy` / `OverrideAt` / `OverrideReason` are retained**: they are shared with the out-of-sequence override, which stays. Dropping all five would have deleted the surviving override's audit trail.
>
> If **Q25** (an order scheduled on *neither* rod line) later needs an authorisation, it **re-adds** its own columns; only the credential trio is reusable.

**Allowed values — `Status`:**

| Value | Meaning |
|---|---|
| `Staged` | Rod is physically at the bay, pre-checked-in, not yet checked in |
| `CheckedIn` | Consumed by check-in on Dashboard 2; the bay is now running or ready to run |
| `Unstaged` | Released from the bay without ever being checked in — **two routes**, distinguished by `UnstageKind`: a **pre-check-out** (`RodCheckout.Mode = ModeP`), or a **WIP rejection** after a failed staging inspection |

> **There is no `Blocked` status — it is derived.** Dashboard 2A and `GET /payoff/status` both expose a **`Blocked`** bay state meaning "inspection failed at staging". That is `Status = 'Staged'` with any of the three inspection columns `= 'Fail'`, **not** a fourth `Status` value. Deriving it is also the operationally correct reading: `UX_RodStaging_Bay` is filtered on `Status = 'Staged'`, and a failed bundle is still physically in the bay, so it must keep the bay occupied. Adding a `Blocked` status would fall outside that filter and free a bay that is not free.
>
> **Q23 — first half resolved (Jul 31 2026): pre-check-in commits the row *before* the inspection gate.** Previously nothing wrote such a row: a failed inspection returned `422` and routed straight to WIP Rejection without committing, so the `Blocked` state was unreachable in practice. That was wrong about the physical situation — bundles are not unbanded until positioned at the payoff, which is why the inspection happens at staging, so a failed rod is **already on the bay**. With no row, `GET /payoff/status` reported the occupied position as `NotStaged` and the next rod could be staged into it. `POST /staging/rod` now returns `201` with `state: "Blocked"` (`04-APIContract.md`). `CHK010` is unchanged — no bypass, WIP Rejection is still the only forward path.
>
> **Q23 residual — RESOLVED (client, 30 Jul 2026): the WIP rejection releases it.** A failed staging inspection is captured as a **rejection with a reason on the rejection screen**, and the rod goes to **`HOLD`**. That is what takes the row out of `Status = 'Staged'` and frees the bay — the bundle has physically left it, so the bay genuinely *is* free.
>
> Implemented by **reusing `Unstaged`** with a new `UnstageKind` discriminator (`PreCheckOut` | `WipRejection`) and a `WipRejectionId` link, rather than adding a fourth `Rejected` status. A fourth value would have forced the vocabulary, `CK_RodStaging_Unstaged` and `UX_RodStaging_Bay`'s filter to change together, and would have multiplied the branches in every query that asks "what is staged", for no operational gain. **A blocked bay is now clearable.**
>
> Still open from Q23: whether `InspectionNotes` should be constraint-enforced NOT NULL when any item fails.

**Inspection columns:** `Pass`, `Fail`. **Three items, not four** — the connector-tag item belongs to check-in (gap **G14**); do not add it here. `InspectionNotes` is nullable but expected whenever an item fails; **Q23** asks whether that should be enforced by a constraint, in the same all-or-nothing style as the welded / unstaged / checked-in column groups below.

**Constraints:**

- `CK_RodStaging_Override` — the credential stamp is **all-or-nothing**: `OverrideBy`/`OverrideAt`/`OverrideReason` are all set exactly when `OutOfSequenceOverride = 1`. An override with no supervisor or no reason is unauditable, which defeats the point of permitting the deviation
- `CK_RodStaging_OutOfSeq` — `ExpectedRodAlpha` present exactly when `OutOfSequenceOverride = 1`
- `CK_RodStaging_OutOfSeqRod` — `ExpectedRodAlpha <> RodAlpha`; "out of sequence" means the rod staged is not the one expected
- `CK_RodStaging_LineId` — `FL1` or `FL3` only. ⚠ **Unchanged by the 20 Aug 2026 FL2 reversal, and correctly so**: FL2 pre-check-in lives in `SpoolStaging`, because this table is rod-shaped (rod inspection columns, `IsWelded`, two bay states, `PayoffPosition NOT NULL`) and widening the CHECK would admit FL2 rows that cannot populate half of it
- `CK_RodStaging_PayoffPos` — `1` or `2`
- `CK_RodStaging_Welded` — `WeldedAt`/`WeldedBy` are both set exactly when `IsWelded = 1`. **Unchanged by the Aug 1 2026 quality decision:** a failed weld sets none of the three, so the all-or-nothing group still holds. Quality itself is **not** mirrored here — it lives on `WeldEvent`, and duplicating it would let the two disagree about one join
- `CK_RodStaging_Unstaged` — `UnstagedAt`/`UnstagedBy`/`UnstageReasonCode`/`UnstageKind` are all set exactly when `Status = 'Unstaged'`
- `CK_RodStaging_UnstageKind` — `UnstageKind` is NULL or one of `PreCheckOut` / `WipRejection`
- `CK_RodStaging_RejectLink` — `WipRejectionId` present exactly when `UnstageKind = 'WipRejection'`. Written with `ISNULL(UnstageKind,'')` rather than a bare comparison: `UnstageKind = 'WipRejection'` evaluates to **UNKNOWN** while the column is NULL, and a CHECK constraint *accepts* UNKNOWN — a still-`Staged` row could otherwise carry a rejection link
- `CK_RodStaging_CheckedIn` — `CheckedInAt`/`RodCheckinId` are both set exactly when `Status = 'CheckedIn'`
- **`UX_RodStaging_Bay`** — filtered UNIQUE on `(LineId, PayoffPosition) WHERE Status = 'Staged'`: **one rod per payoff bay**
- **`UX_RodStaging_RodActive`** — filtered UNIQUE on `(RodAlpha) WHERE Status = 'Staged'`: **one bay per rod**

> The two filtered unique indexes are the reason this is a table rather than columns on `Rod`: they make the bay-occupancy invariant impossible to violate, including under concurrent staging from two clients. Note that any client writing to this table needs `QUOTED_IDENTIFIER ON` (a filtered-index requirement, same as the PERSISTED computed columns elsewhere in this schema).

---

## `SpoolStaging`

**The FL2 pre-check-in queue.** The spool-side counterpart to `RodStaging`, and deliberately a
separate table rather than a widening of it.

> **Why not `RodStaging`?** That table is keyed on a **payoff bay** and carries rod inspection
> columns and a shared-schema station claim. FL2 has **one** payoff, its material is inspected as
> rod back at FL1, and this queue is unbounded rather than bay-limited. Recorded as `OI-118`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | - | Surrogate primary key, IDENTITY |
| `SpoolAlpha` | varchar(20) | NOT NULL | `SpoolProcessing.Alpha` | The row's identity |
| `LineId` | varchar(5) | NOT NULL | - | `FL2`; `FL3` permitted should it ever queue |
| `QueuePosition` | decimal(9,3) | NOT NULL | - | Operator-ordered; lowest is checked in by default |
| `Status` | varchar(20) | NOT NULL | - | Default `Queued` |
| `PreCheckedInBy` | varchar(50) | NOT NULL | - | Who validated it - the audit the queue exists to provide |
| `PreCheckedInAt` | datetimeoffset | NOT NULL | - | Default `SYSDATETIMEOFFSET()` |
| `RemovedAt` | datetimeoffset | NULL | - | Set when checked in, or withdrawn |
| `RemovedReason` | varchar(200) | NULL | - | Free text |
| `RowVersion` | rowversion | NOT NULL | - | Optimistic concurrency: two terminals may reorder at once |

**Allowed values - `Status`:** `Queued`, `CheckedIn`, `Withdrawn`

**Constraints:**
- `PK_SpoolStaging` - `Id`
- `CK_SpoolStaging_LineId` - `FL2` or `FL3`
- `CK_SpoolStaging_Status` - enumerating check
- `CK_SpoolStaging_Pos` - `QueuePosition > 0`
- `CK_SpoolStaging_Removed` - `RemovedAt` is set exactly when `Status <> 'Queued'`
- `UX_SpoolStaging_LiveSpool` - filtered unique on `Status = 'Queued'`, **so a spool can re-enter
  the queue after check-in** - which two orders on one spool requires

> **`QueuePosition` is deliberately NOT unique, and it is `DECIMAL(9,3)` on purpose.** A
> drag-and-drop swap creates a **transient duplicate** that a UNIQUE index rejects, and the failure
> does not surface until the *second* reorder. The decimal lets a row be inserted **between** two
> others without renumbering the queue.

> **No station claim - entirely `FlatWireDB`-local.** That is what keeps the queue unbounded:
> nothing here reserves a shared WIP station, so pre-check-in cannot exhaust one.

> `FL3` is permitted because it shares FM2, but FL3 creates no spool, so in practice it will not
> queue one.

---

## `RodCheckin`

Captures every rod check-in event with inspection results and pre-run SPC measurements. One row is created per rod loaded at a payoff position. Initiates or contributes to a `FlatWireRun`. Where the rod was pre-checked-in, check-in **consumes** the `RodStaging` row (`Status → CheckedIn`, `RodCheckinId` linked) rather than creating a parallel record.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run this check-in initiated or contributed to |
| `LineId` | varchar(5) | NOT NULL | — | Line where the rod was checked in |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | FK to the rod being checked in |
| `PayoffPosition` | int | NOT NULL | — | Payoff position where the rod was loaded: `1` or `2` |
| `DiameterMeasuredIn` | decimal(8,4) | NOT NULL | — | Operator-measured rod diameter at check-in, in inches |
| `GrossWeightLb` | decimal | NOT NULL | — | Gross weight verified at check-in, in pounds |
| `NetWeightLb` | decimal | NOT NULL | — | Net weight verified at check-in, in pounds |
| `PassScheduleId` | varchar(30) | NOT NULL | `PassSchedule.ScheduleId` | Pass schedule the operator acknowledged and accepted at check-in |
| `OrderId` | varchar(20) | NOT NULL | — | Manufacturing order confirmed at check-in |
| `ScrapBoxRef` | varchar(20) | NULL | — | Optional scrap-box reference (reuses slitter scrap-box source; **PROVISIONAL** ScrapBox default) |
| `MmsId` | varchar(30) | NULL | — | Material-tracking identity for this input coil, generated at check-in (**MMS ID** default home) |
| `MmsStatus` | varchar(15) | NULL | — | `Open`/`Active`/`Closed`; closed on consumption (remaining ft = 0) |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the check-in |
| `CheckedInAt` | datetimeoffset | NOT NULL | — | Timestamp of the check-in event |
| `PlcTagsPushed` | bit | NOT NULL | — | `1` if PLC tag values (die sizes, roll gaps) were successfully written for this rod; `0` if push failed |
| `InspectionOxidation` | varchar(10) | NOT NULL | — | Visual oxidation inspection result: `Pass` or `Fail` |
| `InspectionSurfaceDefects` | varchar(10) | NOT NULL | — | Visual surface defect inspection result: `Pass` or `Fail` |
| `InspectionWaterStains` | varchar(10) | NOT NULL | — | Water stain inspection result: `Pass` or `Fail` |
| `InspectionConnectorTag` | varchar(10) | NOT NULL | — | Connector tag presence inspection result: `Pass` or `Fail` |
| `InspectionNotes` | varchar(500) | NULL | — | Free-text operator notes from the physical inspection |
| `SpcM1In` | decimal(8,4) | NOT NULL | — | Pre-run SPC measurement 1 — primary rod diameter at entry point, in inches |
| `SpcM2In` | decimal(8,4) | NOT NULL | — | Pre-run SPC measurement 2 at 90° — secondary rod diameter at entry point, in inches |
| `SpcOvalityIn` | decimal(8,4) | computed | — | **Computed PERSISTED**: `ABS(SpcM1In − SpcM2In)`; indicates out-of-round condition |

**Allowed values — inspection columns:** `Pass`, `Fail`

---

## `SpoolCheckin`

Captures every spool check-in event at FL2 or FL3 with inspection results. Mirrors `RodCheckin` for the spool-feed workflow in Hybrid route mode. One row is created per spool loaded at a payoff position.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run this spool check-in initiated |
| `LineId` | varchar(5) | NOT NULL | — | Line where the spool was checked in: `FL2` or `FL3` |
| `SpoolAlpha` | varchar(20) | NOT NULL | `SpoolProcessing.Alpha` | FK to the spool being checked in |
| `PayoffPosition` | int | NOT NULL | — | Payoff position where the spool was loaded: `1` or `2` |
| `GaugeIn` | decimal(8,4) | NOT NULL | — | Operator-measured spool wire gauge at check-in, in inches; validated against `PassSchedule.TargetGauge ± GaugeTolerance` |
| `WidthIn` | decimal(8,4) | NOT NULL | — | Operator-measured spool wire width at check-in, in inches; validated against `PassSchedule.TargetWidth ± WidthTolerance` |
| `GrossWeightLb` | decimal | NOT NULL | — | Gross weight verified at check-in, in pounds |
| `NetWeightLb` | decimal | NOT NULL | — | Net weight verified at check-in, in pounds |
| `PassScheduleId` | varchar(30) | NOT NULL | `PassSchedule.ScheduleId` | Pass schedule the operator acknowledged and accepted at check-in |
| `OrderId` | varchar(20) | NOT NULL | — | Manufacturing order confirmed at check-in |
| `MmsId` | varchar(30) | NULL | — | Material-tracking identity for this input spool, generated at check-in |
| `MmsStatus` | varchar(15) | NULL | — | `Open`/`Active`/`Closed` |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the check-in |
| `CheckedInAt` | datetimeoffset | NOT NULL | — | Timestamp of the check-in event |
| `PlcTagsPushed` | bit | NOT NULL | — | `1` if PLC tag values were successfully written for this spool; `0` if push failed |
| `InspectionSurface` | varchar(10) | NOT NULL | — | Visual surface condition inspection result: `Pass` or `Fail` |
| `InspectionNotes` | varchar(500) | NULL | — | Free-text operator notes from the inspection |

**Allowed values — `InspectionSurface`:** `Pass`, `Fail`

---

## `RunPauseEvent`

Tracks each pause/resume cycle within a run. One row is created when the run is paused; the same row is updated with resume details when the run continues. Rows with NULL `ResumedAt` represent an active (still-open) pause.

⚠ **The reason vocabulary changed model on 2 Sep 2026, not just content.** The client's `Reason Codes.xlsx` (Tim O'Brien, 1 Sep 2026) replaced the 15-reason / 5-semantic-category taxonomy with UA's **delay-code** model — four *time* buckets and `SET##` / `RUN##` / `HDL##` / `DWN##` codes. **The column names are deliberately unchanged**: `ReasonCode` now holds a `DelayCode` and `ReasonCategory` a `DelayBucket`, so `POST /run/{runId}/pause` keeps its field names and every consumer needs a vocabulary swap rather than a rename. Vocabulary: [`DowntimeReason`](FlatWireSchema_Lookup.md).

**This table takes three of the four buckets** — `Setup`, `RunTime`, `Handling` (**47 codes**). The `Downtime` bucket's 25 codes go to [`LineDowntimeEvent`](#linedowntimeevent) below.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run that was paused |
| `PausedAt` | datetimeoffset | NOT NULL | — | Timestamp when the run was paused |
| `FootageAtPause` | int | NOT NULL | — | Footage counter value at the exact moment of pause |
| `ReasonCode` | varchar(10) | NOT NULL | `DowntimeReason.DelayCode` | The delay code — `SET##`, `RUN##` or `HDL##`. Narrowed from `varchar(50)` with the vocabulary change |
| `ReasonCategory` | varchar(10) | NOT NULL | `DowntimeReason.DelayBucket` | The delay bucket — `Setup`, `RunTime` or `Handling` |
| `IsNonprodTime` | bit | NULL | — | **Snapshot** from `DowntimeReason` at the moment of pause |
| `DelayBufferMin` | int | NULL | — | **Snapshot** of the buffer in force when the pause was taken |
| `Notes` | varchar(500) | NULL | — | Free-text operator notes; required on the per-bucket `Other` codes `SET23` / `RUN12` / `HDL15` (enforced by `CK_RunPauseEvent_NotesOther`) |
| `ResumedAt` | datetimeoffset | NULL | — | Timestamp when the run was resumed; NULL if the pause is still active |
| `PauseDurationSeconds` | int | computed | — | **Computed**: `DATEDIFF(SECOND, PausedAt, ResumedAt)`; NULL while open |
| `Outcome` | varchar(30) | NULL | — | Action taken at resume — see allowed values; NULL while still paused |
| `ActivityCompleted` | varchar(500) | NULL | — | Free-text description of activities performed during the pause; entered by the operator on resume |
| `OperatorId` | varchar(50) | NOT NULL | — | Operator who paused the run |
| `ResumedBy` | varchar(50) | NULL | — | Operator who resumed the run |

**Allowed values — `Outcome`:** `ResumeRun`, `LogWipRejection`, `CheckOutRod`, `ContinuePause`
**Allowed values — `ReasonCategory`:** `Setup`, `RunTime`, `Handling` (`CK_RunPauseEvent_Bucket`)

**Constraints worth knowing:**
- `FK_RunPauseEvent_DelayCode` is **composite** on `(ReasonCode, ReasonCategory)`, targeting `UQ_DowntimeReason_CodeBucket`. Single-column would let the denormalised bucket disagree with the lookup — a `Setup` code filed under `Handling`.
- `CK_RunPauseEvent_NotesOther` was **rewritten**, and it had to be. It read `ReasonCategory <> 'Other' OR Notes IS NOT NULL`, keying on a *category* that no longer exists — under the delay-code model `Other` is a **code**, one per bucket. Left alone the predicate was vacuously true on every row and silently stopped requiring notes.

**Why the snapshot columns.** `DowntimeReason` is editable reference data. Without `IsNonprodTime` and `DelayBufferMin` on the event row, retuning a buffer would silently re-price every historical pause.

> ⚠ **Four previous reasons have no successor code** — `OperatorBreak`, `ShiftChangeover`, `AwaitingSupervisor`, `SafetyObservation`. Owed back to the client; see the `DowntimeReason` notes.

---

## `LineDowntimeEvent`

One row per **line-down interval**. Created when downtime starts, updated when the line comes back; rows with NULL `EndedAt` are open. **New 2 Sep 2026**, with the client's `Downtime` bucket.

### Why this is not a `RunPauseEvent`

Which is the whole reason it exists. The `Downtime` bucket's 25 in-scope codes are all line-down time — *Power Outage*, *Fire Drill*, *Scheduled Maintenance*, *Waiting for Spool From Previous Operation* — and those occur **when no run is open**. `RunPauseEvent` cannot hold them: `RunId` is `NOT NULL` with an FK to `FlatWireRun`, `FootageAtPause` is `NOT NULL`, and every value in `CK_RunPauseEvent_Outcome` (`ResumeRun` / `LogWipRejection` / `CheckOutRod` / `ContinuePause`) presumes a run to return to. Relaxing all three would leave a table named `RunPauseEvent` whose rows have no run, no footage and no outcome.

`WipRejection.RunId` is nullable for exactly the same reason, and `RunId` here follows it.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `LineId` | varchar(5) | NOT NULL | — | `FL1` / `FL2` / `FL3` — **the event is line-scoped**, which is what makes a shift-level roll-up possible |
| `RunId` | varchar(20) | **NULL** | `FlatWireRun.RunId` | Optional link, populated only when a run happened to be open |
| `DelayCode` | varchar(10) | NOT NULL | `DowntimeReason.DelayCode` | `DWN##` only (`CK_LineDowntimeEvent_Code`) |
| `StartedAt` | datetimeoffset | NOT NULL | — | When the line went down |
| `EndedAt` | datetimeoffset | NULL | — | NULL = the line is still down |
| `DowntimeSeconds` | int | computed | — | **Computed**: `DATEDIFF(SECOND, StartedAt, EndedAt)`; NULL while open |
| `IsNonprodTime` | bit | NULL | — | **Snapshot** from `DowntimeReason` |
| `DelayBufferMin` | int | NULL | — | **Snapshot** from `DowntimeReason` |
| `SupervisorOverride` | bit | NULL | — | Was an override in force for this code? |
| `SupervisorOverrideBy` | varchar(50) | NULL | — | Who exercised it, where one was taken |
| `Notes` | varchar(500) | NULL | — | Required on `DWN29 Other` (`CK_LineDowntimeEvent_NotesOther`) |
| `OperatorId` | varchar(50) | NOT NULL | — | Who recorded the start |
| `EndedBy` | varchar(50) | NULL | — | Who recorded the end |

**Constraints:**
- `CK_LineDowntimeEvent_Code` — `DWN##` only; the other three buckets belong to `RunPauseEvent`
- `CK_LineDowntimeEvent_Window` — `EndedAt` is NULL or at/after `StartedAt`
- `CK_LineDowntimeEvent_NotesOther` — `DWN29` requires `Notes`, mirroring `RunPauseEvent`'s rule for the other three buckets
- `CK_LineDowntimeEvent_Override` — an override cannot have an actor without having been taken

**Indexes:** `IX_LineDowntimeEvent_LineOpen` is filtered on `EndedAt IS NULL`, making *"is FL2 down right now?"* a seek; `IX_LineDowntimeEvent_RunId` is filtered on `RunId IS NOT NULL`, because most downtime has no run.

> **Scope note.** MVP-1 has no line-idle downtime **screen**. The table and its vocabulary exist so the data model is complete and the client's 25 codes have a home; the capture UI is not in the MVP-1 mockup set.

---

## `WeldEvent`


Rod-to-rod weld join events recorded during a run. A weld joins the tail of the depleting rod to the leading end of the incoming rod at a draw box, allowing continuous processing without stopping the line.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `WeldEventId` | varchar(20) | NOT NULL UNIQUE | — | Unique weld event identifier (e.g. `WLD-002`) |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run in which this weld occurred |
| `LineId` | varchar(5) | NOT NULL | — | Line where the weld was performed |
| `OutgoingRodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | Alpha of the rod being depleted — the tail (outgoing) end |
| `IncomingRodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | Alpha of the rod being joined — the leading (incoming) end |
| `OutgoingPayoffPosition` | int | NULL | — | Bay the depleting rod is drawing from (`1`/`2`). The weld *is* the payoff handover, so recording it makes the handover directly queryable instead of inferred by joining `RodCheckin`/`RodStaging` |
| `IncomingPayoffPosition` | int | NULL | — | Bay the staged rod occupies (`1`/`2`) |
| `FootagePosition` | int | NOT NULL | — | Footage counter value at the moment the weld was made |
| `WeldType` | varchar(20) | NOT NULL | — | Welding process used: `InductionWeld` (only type per May-21-2026 revision) or `LaserWeld` (retained for historical genealogy) |
| `WeldQuality` | varchar(10) | NOT NULL | — | Weld quality assessment: `Pass` or `Fail` |
| `WeldQualityFailReason` | varchar(200) | NULL | — | Reason description; **required when `WeldQuality = 'Fail'`** (`CK_WeldEvent_FailReason`, WLD013) |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the weld |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the weld event |

**Allowed values:**
- `WeldType`: `InductionWeld`, `LaserWeld`
- `WeldQuality`: `Pass`, `Fail`
- `OutgoingPayoffPosition` / `IncomingPayoffPosition`: `1`, `2`, or NULL

**Constraints:** `CK_WeldEvent_PayoffDiff` — a weld joins two *different* bays; a bay cannot be welded to itself.

> **One physical join may produce several rows.** Since 1 Aug 2026 a weld that fails its quality check is
> recorded here but leaves `RodStaging.IsWelded = 0`, so the operator remakes the weld and a second row is
> written for the same pair of rods at a near-identical footage. Rows are an audit trail of weld *attempts*,
> not a one-per-join index — nothing enforces uniqueness on `(RunId, OutgoingRodAlpha, IncomingRodAlpha)` and
> nothing should. **`CoilTraceability` attributes output footage per weld boundary and does not yet say how to
> treat a superseded attempt** (include it? exclude it from certificates?). That is **OI-59**; the footage half is **Q6**.

---

## `RollOverride`

Records run-level roll gap or die parameter adjustments applied during a run. Overrides do not modify the pass schedule — they are run-specific deviations logged for quality traceability. PLC tag updates are recorded for each override.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `OverrideId` | varchar(20) | NOT NULL UNIQUE | — | Unique override identifier (e.g. `OVR-0042`) |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run in which this override was applied |
| `LineId` | varchar(5) | NOT NULL | — | Line where the override was applied |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | Alpha of the material in-process at the time of the override |
| `FootagePosition` | int | NOT NULL | — | Footage counter value at the time of the override |
| `ComponentName` | varchar(20) | NOT NULL | — | Component that was adjusted (e.g. `DB1`, `FM1`) — matches `PassScheduleComponent.ComponentName` values |
| `OldValue` | decimal(8,4) | NOT NULL | — | Value before the override — the scheduled or previously active value |
| `NewValue` | decimal(8,4) | NOT NULL | — | Override value applied to the component |
| `Delta` | decimal(8,4) | computed | — | **Computed PERSISTED**: `NewValue − OldValue` |
| `ReasonCode` | varchar(50) | NOT NULL | — | Coded reason (CHECK): `GaugeDriftHigh`, `GaugeDriftLow`, `WidthDrift`, `SpcFlag`, `RollWear`, `PostWeldCorrection`, `OperatorDiscretion`, `Other` |
| `Notes` | varchar(500) | NULL | — | Free-text operator notes |
| `MeasuredGaugeIn` | decimal(8,4) | NULL | — | Gauge reading that prompted this override, in inches |
| `MeasuredWidthIn` | decimal(8,4) | NULL | — | Width reading that prompted this override, in inches |
| `PlcTagWritten` | bit | NOT NULL | — | `1` if the PLC tag was successfully updated with the new value; `0` if write failed |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator applying the override |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the override event |

---

## `DieChangeEvent`

Records die replacement events during a run. Each die change event automatically triggers a `PostDieChange` SPC checkpoint to verify dimensional compliance after the new die is installed.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `DieChangeId` | varchar(20) | NOT NULL UNIQUE | — | Unique die change identifier (e.g. `DC-0041`) |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run in which this die change occurred |
| `LineId` | varchar(5) | NOT NULL | — | Line where the die change was performed |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | Alpha of the material in-process at the time of the die change |
| `FootagePosition` | int | NOT NULL | — | Footage counter value at the time of the die change |
| `DiePosition` | varchar(5) | NOT NULL | — | Draw box position where the die was changed: `DB1` or `DB2`. A CHECK-constrained string, **not** an FK to `Drawer` |
| `OldDieId` | int | NULL | `ToolingInventoryDie.Id` | **Added 2 Sep 2026.** The physical die removed |
| `NewDieId` | int | NULL | `ToolingInventoryDie.Id` | **Added 2 Sep 2026.** The physical die installed |
| `OldDieSizeIn` | decimal(8,4) | NOT NULL | — | Die hole diameter being replaced, in inches — **as measured at the swap** |
| `NewDieSizeIn` | decimal(8,4) | NOT NULL | — | Die hole diameter of the replacement die, in inches — **as measured at the swap** |
| `ReasonCode` | varchar(50) | NOT NULL | — | Reason (CHECK): `PlannedLife`, `GaugeDrift`, `DieFailure`, `SizeChange`, `DieWear`, `Breakage`, `ScheduledChange`, `Other` |
| `LinkedOverrideId` | varchar(20) | NULL | `RollOverride.OverrideId` | FK to the `RollOverride` record auto-created for this die size change |
| `SpcCheckpointRequired` | bit | NOT NULL | — | Whether a `PostDieChange` SPC checkpoint is required; always `1` by default |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the die change |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the die change event |

**Allowed values — `DiePosition`:** `DB1`, `DB2`

**Business rule:** A `SpcCheckpoint` of type `PostDieChange` must be created immediately after this event when `SpcCheckpointRequired = 1`.

> **Per-tool attribution, added 2 Sep 2026 with the die split.** `OldDieId` / `NewDieId` are the reason the split is worth doing. Until they existed this table identified its dies **by decimal size only, with no FK**, so no run event could attribute footage to a tool and both die-life counters were Maintenance-maintained by hand. With them, **`FR-255`** becomes implementable — *"closes accumulation on the outgoing die and starts a new counter on the incoming die"* — and **`FR-233` / `D4` revert to their per-tool form**.
>
> **The decimals are kept and are not redundant.** They record the size *physically measured* at the swap, which is the audit fact; the FKs record which tool it was. A disagreement between them is a real finding, not a data error, so nothing reconciles the two.
>
> **Both FKs are nullable.** A die change logged before its tool was registered has nothing to point at, and refusing the event would lose the run record — the weaker behaviour was precisely the size-level `D4` this split retires. Indexed with two filtered indexes in script `07`.

---

## `DieHistory`

**One append-only log serving both of `FR-252`'s tabs** — *Run history* (order, line, footage added, date, operator) and *Replacement log* (install, reset and retirement events).

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `DieId` | int | NOT NULL | `ToolingInventoryDie.Id` | The die this entry belongs to |
| `EventType` | varchar(20) | NOT NULL | — | `Install` · `Reset` · `Retire` · `ThresholdEdit` · `RunFootage` |
| `RunId` | varchar(20) | NULL | `FlatWireRun.RunId` | The run this entry belongs to. **NULL when made outside a run** |
| `FootageAddedFt` | decimal(10,2) | NULL | — | `RunFootage` rows only: feet this run added to the die |
| `OldValue` / `NewValue` | varchar(100) | NULL | — | Value before / after the change, as text (threshold edits, resets) |
| `ReasonCode` | varchar(50) | NULL | — | Retire reason (`FR-250`) or reset disposition (`Reconditioned` / `New spare`, `FR-248`) |
| `ReasonNotes` | varchar(500) | NULL | — | `FR-249` requires a reason on a threshold edit |
| `RemovedFromLineDate` · `ReturnedReadyDate` · `InspectionDate` | date | NULL | — | `FR-248` reset dates |
| `DieRoomSource` | varchar(100) | NULL | — | `FR-248` die room source |
| `OperatorId` | varchar(50) | NOT NULL | — | Who performed the action |
| `Timestamp` | datetimeoffset | NOT NULL | — | When. Defaults to `SYSDATETIMEOFFSET()` |

**Constraints:**
- `PK_DieHistory`
- `CK_DieHistory_EventType` — the five values above
- `CK_DieHistory_RunFootageHasRun` — `EventType <> 'RunFootage' OR RunId IS NOT NULL`
- `CK_DieHistory_FootageOnlyOnRunFootage` — `EventType = 'RunFootage' OR FootageAddedFt IS NULL`
- `CK_DieHistory_FootageNonNeg` — `FootageAddedFt IS NULL OR >= 0`

### Why it exists, and why it is one table

Two facts drive it, neither of which any existing table can carry:

1. **Reset and Retire (`FR-248`, `FR-250`) are die-room actions with no run.** `DieChangeEvent.RunId` is `NOT NULL` with an FK to `FlatWireRun`, so they cannot live there. And `FR-252` wants *history* — a die is reconditioned repeatedly — which a master row cannot hold.
2. **Nothing else records which physical die ran a given run.** The only die references in `02_Schedule`, `03_Materials` and `04_Runs` are `DieChangeEvent`'s two decimals, and `PassScheduleComponent` carries the die *size* in `ParameterValue`, not the tool. So `FR-252`'s *"footage added per die per run"* is **not derivable** for any run without a mid-run swap — it has to be written.

**One table rather than two** because [`FlatWireSchema_Schedule.md`](FlatWireSchema_Schedule.md)'s `PassScheduleChangeLog` already establishes the pattern: a discriminated append-only log with a **nullable** `RunId` and the same *"NULL when made outside a run"* semantics.

**The two CHECKs are the point.** A single discriminated table gives up the ability to make `RunId` `NOT NULL` where it belongs; they recover it, the same way `CK_PSC_ParamValue` does for `PassScheduleComponent`. Without them a `RunFootage` row could exist with no run and no footage, which is not a history entry at all.

`FR-252`'s *order* and *line* are deliberately **not** columns — derive them through `RunId` → `FlatWireRun`. Storing them would be a third copy.

> ⚠ **Indexed on `(DieId, Timestamp DESC)` and on `RunId`.** The `RunId` index is a deliberate difference from `PassScheduleChangeLog.RunId`, which is explicitly *not* indexed: that column carries no FK and joins in no query path, whereas this one carries `FK_DieHistory_Run` and is the join behind the Run history tab. `[DBD §6.8]` covers *"every FK / `RunId` join column"*.

> ⚠ **Retention and rollup are TBD.** `RunFootage` rows accrue one per die per run, so this is the only table in `04_Runs` whose growth is driven by production volume rather than operator actions. Read with `G3`, which owns `RunReading`'s retention.

---

## `RunReading`

Sampled gauge/width/speed profile persisted per run. Live telemetry stays in-memory (SignalR) in Phase 1; this table holds the **decimated/sampled** historical profile that feeds the FL2 gauge trace and the Gauge-Trace / Gauge-CPK / Cut-Traceability reports. It is **not** a per-tick historian — write cadence and retention/rollup are open (G3). Child of `FlatWireRun`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the parent run |
| `FootageFt` | decimal(10,2) | NOT NULL | — | Footage position of this reading, in feet |
| `GaugeIn` | decimal(8,4) | NULL | — | Gauge reading in inches; NULL for FL2 standalone live feed |
| `WidthIn` | decimal(8,4) | NULL | — | Width reading in inches |
| `SpeedFpm` | decimal(8,2) | NULL | — | Line speed at this position (ft/min) |
| `InSpec` | bit | NOT NULL | — | Within gauge tolerance at capture; default `1` |
| `ReadingTs` | datetime2 | NOT NULL | — | UTC capture timestamp; defaults to `SYSUTCDATETIME()` |

**Index:** `IX_RunReading_RunId_Footage (RunId, FootageFt)` — trace-query path.

## `RodOrderConsumption`

**The actual: what a check-in really consumed, per order.** `RodOrderAllocation` is the plan; this
is the outcome. **One check-in, N consumption rows** - which *is* the client's rule 7.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | - | Surrogate primary key, IDENTITY |
| `ConsumptionId` | varchar(20) | NOT NULL | - | Human key, e.g. `RC-0041`, as `CheckoutId` / `RejectionId` |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | The run |
| `RodCheckinId` | int | NOT NULL | `RodCheckin.Id` | The mount this pairing runs on |
| `Station` | varchar(10) | NOT NULL | - | e.g. `FL1PO`. **The exclusivity key** (`G21`) - not `LineId` |
| `LineId` | varchar(5) | NOT NULL | - | `FL1` or `FL3`; projection and reporting only |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | The rod |
| `OrderNo` | varchar(50) | NOT NULL | - | Shared-schema order. **No FK by design** |
| `RelLetter` | varchar(10) | NULL | - | Release letter |
| `AllocationId` | int | NULL | `RodOrderAllocation.Id` | NULL for a substitution made before the allocation row exists |
| `AllocatedWeightLbSnapshot` | decimal(8,2) | NULL | - | **Snapshot, not a join** |
| `PlannedRodSeqNoSnapshot` | smallint | NULL | - | Ditto; same pattern as `RodStaging.PlannedSeqno` |
| `ActualRodSeqNo` | smallint | NOT NULL | - | The position this rod actually took in this order |
| `State` | varchar(20) | NOT NULL | - | See vocabulary below |
| `StartFootageFt` | decimal(10,2) | NOT NULL | - | **Run-cumulative** anchor, captured live from the counter |
| `EndFootageFt` | decimal(10,2) | NULL | - | Run-cumulative at close |
| `ConsumedFootageFt` | decimal | NOT NULL | - | **Computed, PERSISTED**: `EndFootageFt - StartFootageFt` |
| `ThresholdFootageFt` | decimal(10,2) | NULL | - | Computed **once** at pairing start |
| `ThresholdReachedAt` | datetimeoffset | NULL | - | The crossing instant |
| `LatchedWeightAtThresholdLb` | decimal(8,2) | NULL | - | **First latch** - at the crossing, never a fresher tick |
| `NotificationRaisedAt` | datetimeoffset | NULL | - | When `OrderAllocationReached` went out |
| `AcknowledgedAt` / `AcknowledgedBy` | datetimeoffset / varchar(50) | NULL | - | Rule 9: **the operator closes the order, not the system** |
| `WeightAtAcknowledgementLb` | decimal(8,2) | NULL | - | **Second latch** |
| `OverrunWeightLb` | decimal | NULL | - | Computed, PERSISTED. `+` = overrun, `-` = early ack |
| `VarianceVsAllocationLb` | decimal | NULL | - | Computed, PERSISTED, against the snapshot |
| `ConsumedWeightLb` | decimal(8,2) | NULL | - | Written at close, **not computed** - the basis may be integration over `RunReading` |
| `ConversionBasis` | varchar(20) | NULL | - | `Nominal`, `Measured`, `IntegratedRunReading`, `Override` (`OI-45`) |
| `LbPerFtUsed` | decimal(10,6) | NULL | - | The factor **actually applied**; a historical row is never recomputed |
| `ConverterVersion` | varchar(20) | NULL | - | For a change of formula **shape** rather than factor |
| `ClosureReason` | varchar(25) | NULL | - | See vocabulary below |
| `RodCheckoutId` | varchar(20) | NULL | `RodCheckout.CheckoutId` | Set **only** when closure is `RodAbandoned` (Mode B) |
| `ShortfallWeightLb` | decimal(8,2) | NULL | - | Set when the pairing closed below allocation because material ran out |
| `OperatorId` | varchar(50) | NOT NULL | - | Audit |
| `CreatedAt` / `ModifiedBy` / `ModifiedAt` | - | mixed | - | Audit quad |
| `RowVersion` | rowversion | NOT NULL | - | `State` and footage move live, as on `FlatWireRun` |

**Allowed values - `State`:** `Pending`, `InProgress`, `ThresholdReached`, `Closed`, `Voided`
**Allowed values - `ClosureReason`:** `Acknowledged`, `AcknowledgedEarly`, `RodExhausted`,
`RodAbandoned`, `Superseded`

**Constraints:**
- `PK_RodOrderConsumption` - `Id`; `UQ_RodOrderConsumption_CId` - `ConsumptionId`
- `UQ_RodOrderConsumption_Pair` - `(RodCheckinId, OrderNo, RelLetter)`: **one mount, one pairing per order**
- `CK_RodOrderConsumption_State` / `_LineId` / `_Closure` - enumerating checks
- `CK_RodOrderConsumption_Footage` - `EndFootageFt >= StartFootageFt`
- `CK_RodOrderConsumption_Seq` - `ActualRodSeqNo >= 1`
- `CK_RodOrderConsumption_AckStamps` - the three acknowledgement stamps are **all-or-nothing**
- `CK_RodOrderConsumption_Abandon` - an abandoned pairing must name the checkout that abandoned it
- `UX_RodOrderConsumption_Station`, `UX_RodOrderConsumption_ActualSeq` - filtered unique

> **Two weight latches, and the overrun between them is captured rather than discarded.**
> `LatchedWeightAtThresholdLb` is taken at the crossing; `WeightAtAcknowledgementLb` when the
> operator acknowledges. `OverrunWeightLb` is the difference, and it is real production the
> business needs attributed, not an error to be rounded away.

> **The row states its own conversion.** `LbPerFtUsed`, `ConversionBasis` and `ConverterVersion`
> are stored per row, so a later change of formula - or of the open dimensional basis, `Q10` -
> never retro-changes a historical row.

> **`CK_..._AckStamps` is written with explicit `IS NULL` pairs on purpose.**
> `A IS NOT NULL AND B IS NOT NULL` evaluates to **UNKNOWN** when one side is NULL, and a CHECK
> constraint **accepts** UNKNOWN - the trap `CK_AlloyProperty_RodDiaTol` was fixed for.

> **Requirement source:** `ORD003`-`ORD017` in `[REQ]`. Consequence worth knowing: because the rod
> stays mounted across an order boundary there is no second check-in and therefore **no second PLC
> tag push**, so both orders necessarily run under the first order's pass schedule. Whether
> planning can produce a differing-schedule case is `Q48`, `Critical`.

---
