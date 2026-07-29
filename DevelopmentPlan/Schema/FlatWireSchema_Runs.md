# Flat Wire Mill — Run Tracking Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 30, 2026
**Document Type:** Final Schema — Run Tracking Tables
**Source:** Derived from `FlatWireTables.md` recommendations
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `SQL/FlatWire_DDL_04_Runs.sql` (`FlatWireRun` itself is created in `DDL_03`)

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
| `IsWelded` | bit | NOT NULL | — | `1` once the operator records the induction weld to the running rod (`WLD010`); default `0` |
| `Status` | varchar(12) | NOT NULL | — | `Staged` → `CheckedIn`, or `Unstaged` — see allowed values |
| `OrderId` | varchar(20) | NULL | — | Order this rod is staged against, **resolved from `planning_routings` at the scan** — never typed. On a cold line this is what the first rod reveals |
| `OffScheduleOverride` | bit | NOT NULL | — | `1` when the order was booked on a **different line** and a supervisor authorised staging it here anyway; default `0` |
| `OutOfSequenceOverride` | bit | NOT NULL | — | `1` when the rod was **not the one planning expected next** and a supervisor authorised the deviation; default `0` |
| `ScheduledLineId` | varchar(5) | NULL | — | Line the order was actually booked on. Set exactly with `OffScheduleOverride`, and must differ from `LineId` |
| `ExpectedRodAlpha` | varchar(20) | NULL | — | The rod planning expected next, captured at the moment of deviation. Set exactly with `OutOfSequenceOverride`, and must differ from `RodAlpha` |
| `OverrideBy` | varchar(50) | NULL | — | Authorising supervisor badge/ID. **The PIN is never stored** |
| `OverrideAt` | datetimeoffset | NULL | — | Timestamp of the authorisation |
| `OverrideReason` | varchar(200) | NULL | — | Why the line is running off-schedule |
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
| `WeldedAt` | datetimeoffset | NULL | — | Timestamp of the Mark-as-Welded action (`WLD003`) |
| `WeldedBy` | varchar(50) | NULL | — | Operator who recorded the weld (`WLD003`) |
| `CheckedInAt` | datetimeoffset | NULL | — | Set when check-in consumes this staged row |
| `RodCheckinId` | int | NULL | `RodCheckin.Id` | FK closing the staging → check-in chain |
| `UnstagedAt` | datetimeoffset | NULL | — | Timestamp of pre-check-out |
| `UnstagedBy` | varchar(50) | NULL | — | Operator who un-staged it |
| `UnstageReasonCode` | varchar(40) | NULL | — | Pre-check-out reason code |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

**Allowed values — `Status`:**

| Value | Meaning |
|---|---|
| `Staged` | Rod is physically at the bay, pre-checked-in, not yet checked in |
| `CheckedIn` | Consumed by check-in on Dashboard 2; the bay is now running or ready to run |
| `Unstaged` | Removed by pre-check-out (`RodCheckout.Mode = ModeP`) without ever being checked in |

> **There is no `Blocked` status — it is derived.** Dashboard 2A and `GET /payoff/status` both expose a **`Blocked`** bay state meaning "inspection failed at staging". That is `Status = 'Staged'` with any of the three inspection columns `= 'Fail'`, **not** a fourth `Status` value. Deriving it is also the operationally correct reading: `UX_RodStaging_Bay` is filtered on `Status = 'Staged'`, and a failed bundle is still physically in the bay, so it must keep the bay occupied. Adding a `Blocked` status would fall outside that filter and free a bay that is not free.
>
> **Open (Q72):** nothing currently *writes* such a row. A failed inspection is a hard block with no bypass (`CHK010`) and routes straight to WIP Rejection, so the staging record is never committed and the `Blocked` state is unreachable in practice. Whether pre-check-in commits the row before handing off — and what then releases it — is unresolved.

**Inspection columns:** `Pass`, `Fail`. **Three items, not four** — the connector-tag item belongs to check-in (gap **G14**); do not add it here. `InspectionNotes` is nullable but expected whenever an item fails; **Q72** asks whether that should be enforced by a constraint, in the same all-or-nothing style as the welded / unstaged / checked-in column groups below.

**Constraints:**

- `CK_RodStaging_Override` — the credential stamp is **all-or-nothing** and required by **either** deviation: `OverrideBy`/`OverrideAt`/`OverrideReason` are all set exactly when `OffScheduleOverride = 1` **or** `OutOfSequenceOverride = 1`. An override with no supervisor or no reason is unauditable, which defeats the point of permitting the deviation
- `CK_RodStaging_OffSched` — `ScheduledLineId` present exactly when `OffScheduleOverride = 1`
- `CK_RodStaging_OutOfSeq` — `ExpectedRodAlpha` present exactly when `OutOfSequenceOverride = 1`
- `CK_RodStaging_OffSchedLine` — `ScheduledLineId <> LineId`; an override only means anything against a line the order was *not* booked on
- `CK_RodStaging_OutOfSeqRod` — `ExpectedRodAlpha <> RodAlpha`; "out of sequence" means the rod staged is not the one expected
- `CK_RodStaging_LineId` — `FL1` or `FL3` only (`PCI002`)
- `CK_RodStaging_PayoffPos` — `1` or `2`
- `CK_RodStaging_Welded` — `WeldedAt`/`WeldedBy` are both set exactly when `IsWelded = 1`
- `CK_RodStaging_Unstaged` — the three `Unstaged*` columns are all set exactly when `Status = 'Unstaged'`
- `CK_RodStaging_CheckedIn` — `CheckedInAt`/`RodCheckinId` are both set exactly when `Status = 'CheckedIn'`
- **`UX_RodStaging_Bay`** — filtered UNIQUE on `(LineId, PayoffPosition) WHERE Status = 'Staged'`: **one rod per payoff bay**
- **`UX_RodStaging_RodActive`** — filtered UNIQUE on `(RodAlpha) WHERE Status = 'Staged'`: **one bay per rod**

> The two filtered unique indexes are the reason this is a table rather than columns on `Rod`: they make the bay-occupancy invariant impossible to violate, including under concurrent staging from two clients. Note that any client writing to this table needs `QUOTED_IDENTIFIER ON` (a filtered-index requirement, same as the PERSISTED computed columns elsewhere in this schema).

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
| `SpoolAlpha` | varchar(20) | NOT NULL | `Spool.Alpha` | FK to the spool being checked in |
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

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run that was paused |
| `PausedAt` | datetimeoffset | NOT NULL | — | Timestamp when the run was paused |
| `FootageAtPause` | int | NOT NULL | — | Footage counter value at the exact moment of pause |
| `ReasonCode` | varchar(50) | NOT NULL | — | Specific coded reason for the pause (e.g. `GaugeWidthInvestigation`, `DieChange`) |
| `ReasonCategory` | varchar(50) | NOT NULL | — | Broader category of the pause reason (e.g. `QualityMeasurement`, `Maintenance`, `Other`) |
| `Notes` | varchar(500) | NULL | — | Free-text operator notes; required when `ReasonCategory = 'Other'` (enforced by `CK_RunPauseEvent_NotesOther`) |
| `ResumedAt` | datetimeoffset | NULL | — | Timestamp when the run was resumed; NULL if the pause is still active |
| `PauseDurationSeconds` | int | computed | — | **Computed**: `DATEDIFF(SECOND, PausedAt, ResumedAt)`; NULL while open |
| `Outcome` | varchar(30) | NULL | — | Action taken at resume — see allowed values; NULL while still paused |
| `ActivityCompleted` | varchar(500) | NULL | — | Free-text description of activities performed during the pause; entered by the operator on resume |
| `OperatorId` | varchar(50) | NOT NULL | — | Operator who paused the run |
| `ResumedBy` | varchar(50) | NULL | — | Operator who resumed the run |

**Allowed values — `Outcome`:** `ResumeRun`, `LogWipRejection`, `CheckOutRod`, `ContinuePause`

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
| `DiePosition` | varchar(5) | NOT NULL | — | Draw box position where the die was changed: `DB1` or `DB2` |
| `OldDieSizeIn` | decimal(8,4) | NOT NULL | — | Die hole diameter being replaced, in inches |
| `NewDieSizeIn` | decimal(8,4) | NOT NULL | — | Die hole diameter of the replacement die, in inches |
| `ReasonCode` | varchar(50) | NOT NULL | — | Reason (CHECK): `PlannedLife`, `GaugeDrift`, `DieFailure`, `SizeChange`, `DieWear`, `Breakage`, `ScheduledChange`, `Other` |
| `LinkedOverrideId` | varchar(20) | NULL | `RollOverride.OverrideId` | FK to the `RollOverride` record auto-created for this die size change |
| `SpcCheckpointRequired` | bit | NOT NULL | — | Whether a `PostDieChange` SPC checkpoint is required; always `1` by default |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the die change |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the die change event |

**Allowed values — `DiePosition`:** `DB1`, `DB2`

**Business rule:** A `SpcCheckpoint` of type `PostDieChange` must be created immediately after this event when `SpcCheckpointRequired = 1`.

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

---

## Change Log

| Date | Change |
|---|---|
| July 29, 2026 | **Free rod processing order.** Planned sequence is not enforced — staging validates only current-order membership and availability. Added **`RodStaging.PlannedSeqno` (int NULL)** and redefined `RodSeqno` as the **actual** processing sequence assigned at pre-check-in, monotonic per line; `PlannedSeqno` snapshots the planned position (same snapshot pattern as pass schedule id/version on the run record). Added `CK_RodStaging_SeqPos` / `CK_RodStaging_PlannedSeqPos`; deliberately **no** constraint relating the two, since a difference is the normal case. Also annotated that `PCI008`'s "enforce sequencing" means *physical weld* sequencing, not planned order (**Q70** partly resolved). |
| July 29, 2026 | Documented that the Dashboard 2A / `GET /payoff/status` **`Blocked`** bay state is **derived** (`Status = 'Staged'` + any inspection column `= 'Fail'`), not a fourth `Status` value — adding one would fall outside the `UX_RodStaging_Bay` filter and free a bay that is still physically occupied. Flagged **Q72**: nothing currently writes such a row, because a failed inspection routes straight to WIP Rejection without committing, so `Blocked` is unreachable in practice; also asks whether `InspectionNotes` should be constraint-enforced when any item fails. No DDL change. |
| July 29, 2026 | Added **`RodStaging`** (pre-check-in / payoff staging) implementing SRS §4.2 `PCI001`–`PCI008`, `WLD010` and `TRV004`; two filtered unique indexes enforce one-rod-per-bay and one-bay-per-rod. `FlatWireRunDetail.PayoffPositionId` now has a real FK parent (`PayoffPosition`, REVIEW.md #15). `WeldEvent`: added `OutgoingPayoffPosition`/`IncomingPayoffPosition` + `CK_WeldEvent_PayoffDiff` so the payoff handover is queryable. `RodCheckin` documented as *consuming* the staged row. |
| July 26, 2026 | Added `RunReading` (sampled gauge profile, G3). `FlatWireRun.FootageFt` → `decimal(10,2)`; added audit + `RowVersion` on `FlatWireRun`. `RodCheckin`: computed `SpcOvalityIn`, added `MmsId`/`MmsStatus`/`ScrapBoxRef`. `SpoolCheckin`: added `MmsId`/`MmsStatus`. `RunPauseEvent`: added `OperatorId`/`ResumedBy`, computed `PauseDurationSeconds`, Notes-when-Other CHECK. `WeldEvent`: fail-reason-required CHECK. `RollOverride`: computed `Delta`, ReasonCode CHECK. `DieChangeEvent`: ReasonCode CHECK. Retargeted to `FlatWireDB`. |
