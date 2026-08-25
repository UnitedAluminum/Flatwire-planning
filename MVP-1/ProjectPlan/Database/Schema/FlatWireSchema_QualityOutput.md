# Flat Wire Mill — Quality Control & Output Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 23, 2026 — **`Spool` and `SpoolCarrier` are SWAPPED (`Q60`).** The reusable stencilled article is now **`Spool`** in `01_Lookup`; the material record is now **`SpoolProcessing`** in `03_Materials`; `CarrierNo` → `SpoolNo`. ⚠ **A stale `Spool` reference is now *silently wrong*, not obviously stale** — see `[DBD §6.2a]`, the naming convention this closed. **`SpoolConfiguration` is also merged into `Spool`** — counts move to **33 tables · 55 FKs · 69 index statements**. *(previously August 23, 2026 — corrected up to the DDL; header fields standardised)*
**Document Type:** Final Schema — Quality Control & Output Tables
**Source:** the April gap analysis, now the appendix of [FlatWireSchema_Mapping.md](FlatWireSchema_Mapping.md) (absorbed 13 Aug 2026 when `FlatWireTables.md` was deleted; recoverable in git history)
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `SQL/FlatWire_DDL_05_QualityOutput.sql`
**Status:** Active — corrected up to the DDL, August 23, 2026
**Scope:** MVP-1
**Owner:** Architecture stream / DBA
**Audience:** DBA, .NET developers, BA
**Part of:** `ProjectPlan/Database/` — the as-built model and the counted baseline are [`DatabaseDesign.md`](../DatabaseDesign.md) (`[DBD]`)
**Authority:** `SQL/FlatWire_DDL_05_QualityOutput.sql` **wins** on types, nullability and constraints. This document explains them; it does not define them, and it states no object counts — those are `[DBD §6.2]`. No shortcode is declared, deliberately: these are derived documents and must not be cited as authority.

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
| `NetWeightLb` | decimal(8,2) | NOT NULL | — | Net weight in pounds; footage × `AlloyProperty.LbPerFtFactor` (OQ-10) |
| `NetWeightOverrideLb` | decimal(8,2) | NULL | — | Manual override when derived weight is disputed (OQ-10 fallback) |
| `ScaleWeightLb` | decimal(8,2) | NULL | — | Physical scale weight captured at packing (Dashboard 7b) |
| `FinalGaugeIn` | decimal(8,4) | NOT NULL | — | Final measured gauge of the coil in inches |
| `FinalWidthIn` | decimal(8,4) | NOT NULL | — | Final measured width of the coil in inches |
| `FootageFt` | decimal(10,2) | NOT NULL | — | Total footage of wire on this coil in feet (standardized to `decimal(10,2)`) |
| `PassScheduleId` | varchar(30) | NULL | `PassSchedule.ScheduleId` | Schedule effective at coil creation (OQ-64) |
| `PassScheduleSnapshot` | nvarchar(max) | NULL | — | JSON snapshot of the schedule config at coil creation (NFR013) |
| `CoilNo` | varchar(9) | NULL | — | Shared-schema coil identity → `proddb..coils.coil_no`; minted by `CommonDB.dbo.GenerateCoilAlpha` off the source rod. Filtered-UNIQUE (`UX_CoilOutput_CoilNo`), which is what makes the run-end write-back's retry contract enforceable — `FR-509`, `[INT §8.1]` |
| `SharedSkidNo` | varchar(9) | NULL | — | Legacy skid number → `united_db..wip_skids.skid_no`, allocated by `proddb..generate_new_skid_no` — `FR-514` |
| `SkidId` | varchar(20) | NULL | — | External skid reference, no local FK. ⚠ **The skid table is `united_db..wip_skids` + `proddb..wip_skid_coils`** (`OI-104` closed 18 Aug 2026); `SharedSkidNo` holds the resolved legacy number |
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

Source traceability — maps footage ranges within an output coil back to the specific rod alpha that produced that material, and on a spool-fed line to the source spool. Enables full genealogy from finished coil to supplier heat number, which is the `rod → spool → coil` chain `FR-333` requires. Multiple rows per coil when the run involved more than one rod or more than one spool.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CoilAlpha` | varchar(30) | NOT NULL | `CoilOutput.CoilAlpha` | FK to the output coil this traceability row belongs to |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | FK to the rod that produced material in this footage range |
| `SpoolAlpha` | varchar(20) | NULL | `SpoolProcessing.Alpha` | FK to the spool that fed this footage range. **NULL on a rod-fed run** (FL1 standalone, and FL3 when fed directly from rod) — there is no input spool to name |
| `FootageFrom` | int | NOT NULL | — | Start footage position (inclusive) in this coil that originated from `RodAlpha` |
| `FootageTo` | int | NOT NULL | — | End footage position (inclusive) in this coil that originated from `RodAlpha` |

**Constraints:**
- `FootageFrom < FootageTo` (`CK_CoilTraceability_Range`)
- **Enforced:** footage ranges within a coil must not overlap — trigger `trg_CoilTraceability_NoOverlap` (DDL_08, DM010)
- `FK_CoilTraceability_SpoolProcessing` constrains only the rows that name a spool; a NULL is not evaluated
- `IX_CoilTraceability_SpoolAlpha` is **filtered** on `SpoolAlpha IS NOT NULL`

### Why the spool lives here and not on `CoilOutput`

Added 6 Aug 2026. The relationship was missing outright: `CoilOutput` has no spool column, so a finished coil could not be traced to the spool that fed it.

- **`RunId` cannot stand in for it.** `SpoolCheckin.RunId` is not unique — many spools may be checked in against one run — and `CoilOutput.RunId` is many coils per run. `CoilOutput → SpoolCheckin` therefore returns a **set** of spools, never *the* spool.
- **A `CoilOutput.SpoolAlpha` header column would be wrong** the moment a spool runs out mid-coil and the next is mounted. The footage range here is the right grain: it records *which feet* came from which spool, which is what the welding-wire certificate needs.
- **A separate `SpoolCoilMapping` junction table was rejected** — the client's May 2026 proposed design (`BaseDocuments/flatwire tables.xlsx`) has one as `(Id, SpoolId, CoilNo)`. It records only *that* a spool contributed, carries no footage, and would be a second weaker copy of an edge this table already owns.

One spool routinely yields about two coils (client, 6 Aug 2026: FL1 spools ~1,800 lb against FL2 coils of 800/900 lb), so this is the ordinary case, not an edge case.

> **Two residual gaps this does not close.** `SpoolProcessing.ParentRodAlpha` is **singular**, so a spool welded from several rods still loses parents — that is `FR-172`'s multi-parent genealogy, a separate defect; rods-per-spool is derivable through `SpoolProcessing.SourceRunId → WeldEvent` but without footage attribution. And **`OI-25`** stands: run events use cumulative **run** footage while these ranges are **coil-local**, so the spool attribution is only as trustworthy as a coil-start offset no artifact yet states.

---

## `RodCheckout`

Records rod removal from a payoff position. Supports two modes: **Mode A** = pre-run removal before the run starts (rod never went into production); **Mode B** = mid-run emergency removal while the line is running. Mode B requires additional fields for in-process material disposition.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `CheckoutId` | varchar(20) | NOT NULL UNIQUE | — | Unique checkout identifier (e.g. `CO-0041`) |
| `RunId` | varchar(20) | NULL | `FlatWireRun.RunId` | FK to the run from which the rod was removed; NULL for Mode P and Mode A |
| `LineId` | varchar(5) | NOT NULL | — | Line from which the rod is being removed |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | Alpha of the rod being checked out |
| `PayoffPosition` | int | NOT NULL | — | Payoff position from which the rod is being removed |
| `Mode` | varchar(10) | NOT NULL | — | Checkout mode: `ModeP` = pre-check-out (never checked in); `ModeA` = pre-run removal; `ModeB` = mid-run removal |
| `FootageAtCheckout` | int | NOT NULL | — | Footage counter value at the time of checkout; `0` for Mode P and Mode A |
| `ReasonCode` | varchar(50) | NOT NULL | — | Coded reason for the checkout (e.g. `WrongRod`, `MaterialDefect`, `EmergencyStop`) |
| `RodDisposition` | varchar(30) | NOT NULL | — | Where the rod goes after checkout — see allowed values |
| `RemainingWeightLbEstimate` | decimal | NULL | — | Estimated remaining material weight on the rod in pounds; Mode B only |
| `InProcessMaterialDisposition` | varchar(30) | NULL | — | Disposition of the in-process material at the time of checkout — see allowed values; Mode B only |
| `PartialSpoolAlpha` | varchar(20) | NULL | — | Alpha generated for the partial spool if `InProcessMaterialDisposition = 'AcceptAsPartialRun'` |
| `NewRodStatus` | varchar(20) | NOT NULL | — | Status the rod record is updated to after checkout (e.g. `HOLD`, `SCRAP`, `RECEIVED`) |
| `PlcTagsCleared` | bit | NOT NULL | — | `1` if the PLC tags were successfully cleared for this rod; `0` if clear failed. Always `0` for Mode P — no tags were ever pushed, so there are none to clear |
| `WasWelded` | bit | NOT NULL | — | Mode P only: the staged rod had been **induction-welded** to the running rod when it was removed. Default `0` |
| `ApprovedBy` | varchar(50) | NULL | — | Authorising supervisor badge/ID. **The PIN is never stored** |
| `ApprovedAt` | datetimeoffset | NULL | — | Timestamp of the authorisation |
| `OverrideReason` | varchar(200) | NULL | — | Documented reason for the approved removal |
| `OperatorId` | varchar(50) | NOT NULL | — | User ID of the operator performing the checkout |
| `Timestamp` | datetimeoffset | NOT NULL | — | Timestamp of the checkout event |

**Allowed values:**
- `Mode`: `ModeP`, `ModeA`, `ModeB`
- `RodDisposition`: `ReturnToFloorStorage`, `ReturnToWarehouse`, `HoldReturnToStorage`, `Scrap`, `DeferContinueLater`
- `InProcessMaterialDisposition`: `HoldPendingSupervisor`, `Scrap`, `AcceptAsPartialRun`
- `NewRodStatus` (CHECK `CK_RodCheckout_NewRodStatus`): `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP`

### Modes compared

| | Mode P — pre-check-out | Mode A — pre-run | Mode B — mid-run |
|---|---|---|---|
| Was the rod checked in? | **No** — only pre-checked-in | Yes | Yes |
| `RunId` | NULL | NULL | Populated |
| Footage | 0 | 0 | > 0 |
| Pass schedule acknowledgement | None to void | Voided | Voided |
| PLC tags | **None were pushed** | Cleared | Cleared (after confirmed stop) |
| In-process material | None | None | Requires disposition |
| Approval | **Depends on the weld** (OQ-69): unwelded → operator, reason only. Welded → **supervisor**, documented reason, rod to `HOLD` | Operator | **Supervisor** (OQ-74) |
| Screen | Dashboard 2A | Dashboard 12 | Dashboard 12 via Pause |

**Constraints:**
- `CK_RodCheckout_ModeP` — when `Mode = 'ModeP'`: `RunId` NULL, `FootageAtCheckout` 0, `PlcTagsCleared` 0, and both `InProcessMaterialDisposition` and `PartialSpoolAlpha` NULL
- `CK_RodCheckout_ModeB` — `InProcessMaterialDisposition` is only permitted when `Mode = 'ModeB'`
- `CK_RodCheckout_WasWelded` — `WasWelded = 1` only on `ModeP`. Modes A and B follow a check-in, by which point the weld is upstream history rather than a property of *this* removal
- `CK_RodCheckout_Approval` — the approval stamp is **all-or-nothing**: `ApprovedBy`/`ApprovedAt`/`OverrideReason` are set together or not at all
- `CK_RodCheckout_ModePWelded` — a **welded** Mode P removal requires the full approval stamp **and** `NewRodStatus = 'HOLD'`. Removing a welded rod means cutting the material, so it is a rejection rather than a return (OQ-69 / OQ-72)
- `CK_RodCheckout_ModeBApproved` — a Mode B removal requires the full approval stamp (OQ-74)

> **Gap G24 — these approvals were decided long before any column could hold them.** Until 1 Aug 2026 this table had **no approval columns at all**, so **OQ-74** (mid-run checkout) and **OQ-75** (partial-run disposition), both decided 4 May 2026, were enforced at the UI and stored nothing — and [RodCheckout.md](../../Business/Screens/RodCheckout.md) describes a "disposition record: supervisor ID, decision, reason code, timestamp" that had nowhere to go. Adding the columns also **retro-enforces Mode B**: the existing sample-data Mode B row failed the rebuild until it was given an approver, which is the gap demonstrating itself.
>
> The **PIN validation source** (existing login service vs a separate supervisor store) is still undecided and now gates three flows — spool weight, out-of-sequence staging, welded pre-check-out (**OI-38**).
