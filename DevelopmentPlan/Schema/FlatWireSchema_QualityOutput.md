# Flat Wire Mill — Quality Control & Output Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
**Document Type:** Final Schema — Quality Control & Output Tables
**Source:** Derived from `FlatWireTables.md` recommendations
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `SQL/FlatWire_DDL_05_QualityOutput.sql`

These tables capture SPC measurement sessions, material rejections, and the finished output coils produced by a run. Together they provide full quality traceability from raw rod through to the finished coil.

---

## `SpcCheckpoint`

Header record for each SPC measurement session. A checkpoint groups one or more individual measurements taken at a specific footage position and trigger type. `AllInSpec` is computed once all `SpcMeasurement` rows for the checkpoint are saved.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CheckpointId` | varchar(20) | NOT NULL UNIQUE | — | Unique checkpoint identifier (e.g. `SPC-0041`) |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run this checkpoint belongs to |
| `LineId` | varchar(5) | NOT NULL | — | Line where the checkpoint was performed |
| `CheckpointType` | varchar(30) | NOT NULL | — | What triggered this checkpoint — see allowed values |
| `FootagePosition` | int | NOT NULL | — | Footage counter value at the time the checkpoint was initiated |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the measurements |
| `TriggerDescription` | varchar(200) | NULL | — | Human-readable description of the trigger event (e.g. `"DB2 die changed from 0.310 → 0.308"`) |
| `AllInSpec` | bit | NULL | — | `1` if all measurements in this checkpoint are within spec; `0` if any are out of spec; NULL until all measurements are saved and evaluated |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp when the checkpoint was initiated |

**Allowed values — `CheckpointType`:**

| Value | Trigger |
|---|---|
| `PreRun` | Performed before the run begins — validates material before processing starts |
| `PostDieChange` | Triggered automatically by a `DieChangeEvent` |
| `ManualSpotCheck` | Operator-initiated ad-hoc measurement during a run |
| `PostRun` | Performed at run completion — final dimensional verification |
| `RollAdjustTrigger` | Triggered by a roll gap adjustment event |

---

## `SpcMeasurement`

Individual measurement rows belonging to an SPC checkpoint. Each row captures one named measurement point, its specification target, actual value, and whether it falls within spec.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CheckpointId` | varchar(20) | NOT NULL | `SpcCheckpoint.CheckpointId` | FK to the parent SPC checkpoint |
| `Name` | varchar(50) | NOT NULL | — | Named measurement point (e.g. `FM1Gauge`, `FM1Width`, `WireDiameterPostDraw`) |
| `TargetValue` | decimal(8,4) | NOT NULL | — | Specification target value for this measurement point |
| `ToleranceValue` | decimal(8,4) | NOT NULL | — | ± tolerance band for this measurement (drives `InSpec`) |
| `ActualValue` | decimal(8,4) | NOT NULL | — | Operator-measured actual value |
| `Deviation` | decimal(8,4) | computed | — | **Computed PERSISTED**: `ActualValue − TargetValue` (signed) |
| `InSpec` | bit | computed | — | **Computed PERSISTED**: `ABS(ActualValue − TargetValue) <= ToleranceValue` |

---

## `WipRejection`

Material rejection events raised during a run or during incoming material inspection. Captures the rejected material, rejection reason, measured vs. target values, and resulting disposition. `RunId` is nullable to support pre-run incoming material rejections.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `RejectionId` | varchar(20) | NOT NULL UNIQUE | — | Unique rejection identifier (e.g. `REJ-0041`) |
| `RunId` | varchar(20) | NULL | `FlatWireRun.RunId` | FK to the run in which rejection occurred; NULL for pre-run incoming material rejections |
| `LineId` | varchar(5) | NOT NULL | — | Line where the rejection was identified |
| `MaterialAlpha` | varchar(20) | NOT NULL | — | Alpha of the rejected material — rod alpha (e.g. `R00041`) or spool alpha (e.g. `SP-00021`) |
| `Stage` | varchar(30) | NOT NULL | — | Production stage at which the rejection occurred (e.g. `FL1ActiveRun`, `FL2Incoming`, `FL1Incoming`) |
| `FootagePosition` | int | NULL | — | Footage counter value at the point of rejection; NULL for pre-run rejections |
| `RejectionGroup` | varchar(30) | NOT NULL | — | High-level rejection category — see allowed values |
| `RejectionReason` | varchar(50) | NOT NULL | — | Specific rejection reason code (e.g. `GaugeOutOfSpec`, `WeldBreak`, `SurfaceDefect`) |
| `MeasuredValue` | decimal | NULL | — | Actual measured value that triggered the rejection |
| `TargetMin` | decimal | NULL | — | Minimum acceptable value for this measurement |
| `TargetMax` | decimal | NULL | — | Maximum acceptable value for this measurement |
| `Disposition` | varchar(20) | NOT NULL | — | Action taken on the rejected material: `Suspend`, `Scrap`, `Rework` |
| `ObservationNotes` | varchar(500) | NULL | — | Free-text operator observations about the rejection event |
| `NewMaterialStatus` | varchar(20) | NOT NULL | — | Status the material is updated to following rejection: `HOLD` or `SCRAP` |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator logging the rejection |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the rejection event |

**Allowed values:**
- `RejectionGroup`: `SurfaceQuality`, `Dimensional`, `WeldQuality`, `Material`, `Process`
- `Disposition`: `Suspend`, `Scrap`, `Rework`
- `NewMaterialStatus`: `HOLD`, `SCRAP`

---

## `CoilOutput`

Output coil records generated at run completion. One row per finished coil produced by a run. Final gauge and width spec results are populated from the `PostRun` SPC checkpoint.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CoilAlpha` | varchar(30) | NOT NULL UNIQUE | — | Unique alpha identifier for this output coil (e.g. `FW-00421-C01`) |
| `RunId` | varchar(20) | NOT NULL | `FlatWireRun.RunId` | FK to the run that produced this coil |
| `LineId` | varchar(5) | NOT NULL | — | Line that produced this coil |
| `OrderId` | varchar(20) | NOT NULL | — | Manufacturing order this coil fulfills |
| `GrossWeightLb` | decimal(8,2) | NOT NULL | — | Gross weight of the finished coil in pounds |
| `NetWeightLb` | decimal(8,2) | NOT NULL | — | Net weight in pounds; footage × `AlloyProperty.LbPerFtFactor` (OQ-36) |
| `NetWeightOverrideLb` | decimal(8,2) | NULL | — | Manual override when derived weight is disputed (OQ-36 fallback) |
| `ScaleWeightLb` | decimal(8,2) | NULL | — | Physical scale weight captured at packing (Dashboard 7b) |
| `FinalGaugeIn` | decimal(8,4) | NOT NULL | — | Final measured gauge of the coil in inches |
| `FinalWidthIn` | decimal(8,4) | NOT NULL | — | Final measured width of the coil in inches |
| `FootageFt` | decimal(10,2) | NOT NULL | — | Total footage of wire on this coil in feet (standardized to `decimal(10,2)`) |
| `PassScheduleId` | varchar(30) | NULL | `PassSchedule.ScheduleId` | Schedule effective at coil creation (OQ-54) |
| `PassScheduleSnapshot` | nvarchar(max) | NULL | — | JSON snapshot of the schedule config at coil creation (NFR013) |
| `SkidId` | varchar(20) | NULL | — | External skid reference (existing skid table; no local FK) |
| `SkidStatus` | varchar(20) | NULL | — | Skid status: `Open`, `Closing`, `Staged`, `Closed` |
| `StagingLocation` | varchar(20) | NULL | — | Packing staging bay (e.g. `A-3`, `A-4`, `A-5`) |
| `Status` | varchar(20) | NOT NULL | — | Material status: `COMPLETE`, `HOLD`, or `SCRAP` |
| `GaugeInSpec` | bit | NULL | — | `1` if final gauge is within specification per the `PostRun` SPC checkpoint; NULL until evaluated |
| `WidthInSpec` | bit | NULL | — | `1` if final width is within specification per the `PostRun` SPC checkpoint; NULL until evaluated |
| `CompletedAt` | datetimeoffset | NOT NULL | — | Timestamp when this coil was finalized |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator who completed the coil |
| `CreatedBy` | varchar(50) | NULL | — | Audit (CompletedAt serves as created timestamp) |
| `ModifiedBy` | varchar(50) | NULL | — | Audit: last modifier |
| `ModifiedAt` | datetimeoffset | NULL | — | Audit: last-modified timestamp |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

**Allowed values:**
- `Status`: `COMPLETE`, `HOLD`, `SCRAP`
- `SkidStatus`: `Open`, `Closing`, `Staged`, `Closed`

---

## `CoilTraceability`

Source traceability — maps footage ranges within an output coil back to the specific rod alpha that produced that material. Enables full genealogy from finished coil to supplier heat number. Multiple rows per coil when the run involved more than one rod.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CoilAlpha` | varchar(30) | NOT NULL | `CoilOutput.CoilAlpha` | FK to the output coil this traceability row belongs to |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | FK to the rod that produced material in this footage range |
| `FootageFrom` | int | NOT NULL | — | Start footage position (inclusive) in this coil that originated from `RodAlpha` |
| `FootageTo` | int | NOT NULL | — | End footage position (inclusive) in this coil that originated from `RodAlpha` |

**Constraints:**
- `FootageFrom < FootageTo` (`CK_CoilTraceability_Range`)
- **Enforced:** footage ranges within a coil must not overlap — trigger `trg_CoilTraceability_NoOverlap` (DDL_08, DM010)

---

## `RodCheckout`

Records rod removal from a payoff position. Supports two modes: **Mode A** = pre-run removal before the run starts (rod never went into production); **Mode B** = mid-run emergency removal while the line is running. Mode B requires additional fields for in-process material disposition.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CheckoutId` | varchar(20) | NOT NULL UNIQUE | — | Unique checkout identifier (e.g. `CO-0041`) |
| `RunId` | varchar(20) | NULL | `FlatWireRun.RunId` | FK to the run from which the rod was removed; NULL for Mode A pre-run checkout |
| `LineId` | varchar(5) | NOT NULL | — | Line from which the rod is being removed |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | Alpha of the rod being checked out |
| `PayoffPosition` | int | NOT NULL | — | Payoff position from which the rod is being removed |
| `Mode` | varchar(10) | NOT NULL | — | Checkout mode: `ModeA` = pre-run removal; `ModeB` = mid-run removal |
| `FootageAtCheckout` | int | NOT NULL | — | Footage counter value at the time of checkout; `0` for Mode A |
| `ReasonCode` | varchar(50) | NOT NULL | — | Coded reason for the checkout (e.g. `WrongRod`, `MaterialDefect`, `EmergencyStop`) |
| `RodDisposition` | varchar(30) | NOT NULL | — | Where the rod goes after checkout — see allowed values |
| `RemainingWeightLbEstimate` | decimal | NULL | — | Estimated remaining material weight on the rod in pounds; Mode B only |
| `InProcessMaterialDisposition` | varchar(30) | NULL | — | Disposition of the in-process material at the time of checkout — see allowed values; Mode B only |
| `PartialSpoolAlpha` | varchar(20) | NULL | — | Alpha generated for the partial spool if `InProcessMaterialDisposition = 'AcceptAsPartialRun'` |
| `NewRodStatus` | varchar(20) | NOT NULL | — | Status the rod record is updated to after checkout (e.g. `HOLD`, `SCRAP`, `RECEIVED`) |
| `PlcTagsCleared` | bit | NOT NULL | — | `1` if the PLC tags were successfully cleared for this rod; `0` if clear failed |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the checkout |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the checkout event |

**Allowed values:**
- `Mode`: `ModeA`, `ModeB`
- `RodDisposition`: `ReturnToFloorStorage`, `ReturnToWarehouse`, `HoldReturnToStorage`, `Scrap`, `DeferContinueLater`
- `InProcessMaterialDisposition`: `HoldPendingSupervisor`, `Scrap`, `AcceptAsPartialRun`
- `NewRodStatus` (CHECK `CK_RodCheckout_NewRodStatus`): `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP`

---

## Change Log

| Date | Change |
|---|---|
| July 26, 2026 | `SpcMeasurement`: added `ToleranceValue`; `Deviation` + `InSpec` now computed PERSISTED. `CoilOutput`: `FootageFt` → `decimal(10,2)`; added `PassScheduleId` + `PassScheduleSnapshot` (OQ-54/NFR013), `NetWeightOverrideLb` + `ScaleWeightLb` (OQ-36/packing), `StagingLocation`, expanded `SkidStatus` domain, audit + `RowVersion`; corrected bare `decimal` weights to `decimal(8,2)`. `CoilTraceability`: overlap now enforced by trigger. `RodCheckout`: `NewRodStatus` CHECK. Retargeted to `FlatWireDB`. |
