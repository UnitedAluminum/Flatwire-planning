# Flat Wire Mill — Run Tracking Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
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
| `PayoffPositionId` | int | NOT NULL | — | FK to the payoff position reference — Payoff1, Payoff2, or TraversingTakeup |
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

## `RodCheckin`

Captures every rod check-in event with inspection results and pre-run SPC measurements. One row is created per rod loaded at a payoff position. Initiates or contributes to a `FlatWireRun`.

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
| `FootagePosition` | int | NOT NULL | — | Footage counter value at the moment the weld was made |
| `WeldType` | varchar(20) | NOT NULL | — | Welding process used: `InductionWeld` (only type per May-21-2026 revision) or `LaserWeld` (retained for historical genealogy) |
| `WeldQuality` | varchar(10) | NOT NULL | — | Weld quality assessment: `Pass` or `Fail` |
| `WeldQualityFailReason` | varchar(200) | NULL | — | Reason description; **required when `WeldQuality = 'Fail'`** (`CK_WeldEvent_FailReason`, WLD013) |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the weld |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the weld event |

**Allowed values:**
- `WeldType`: `InductionWeld`, `LaserWeld`
- `WeldQuality`: `Pass`, `Fail`

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
| July 26, 2026 | Added `RunReading` (sampled gauge profile, G3). `FlatWireRun.FootageFt` → `decimal(10,2)`; added audit + `RowVersion` on `FlatWireRun`. `RodCheckin`: computed `SpcOvalityIn`, added `MmsId`/`MmsStatus`/`ScrapBoxRef`. `SpoolCheckin`: added `MmsId`/`MmsStatus`. `RunPauseEvent`: added `OperatorId`/`ResumedBy`, computed `PauseDurationSeconds`, Notes-when-Other CHECK. `WeldEvent`: fail-reason-required CHECK. `RollOverride`: computed `Delta`, ReasonCode CHECK. `DieChangeEvent`: ReasonCode CHECK. Retargeted to `FlatWireDB`. |
