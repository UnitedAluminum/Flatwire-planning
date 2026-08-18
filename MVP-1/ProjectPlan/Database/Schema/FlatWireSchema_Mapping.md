# Flat Wire Mill — Schema Mapping & Entity Relationships

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 6, 2026
**Document Type:** Final Schema — Entity Relationships, FK Mapping & Enumeration Reference
**Source:** the April gap analysis from `FlatWireTables.md`, absorbed into this document's appendix on 13 Aug 2026 when that file was deleted
**Target DB:** `FlatWireDB` (schema `dbo`)

---

## Entity Relationship Diagram

```
AlloyProperty ──(1:many)──> PassSchedule   (PassSchedule.Alloy → AlloyProperty.Alloy)

PassSchedule ──(1:many)──> PassScheduleComponent
     │                           │
     │                     Stand / Drawer / Edger (lookups)
     ├──(1:many)──> PassScheduleChangeLog
     ├──(0:many)──> CoilOutput (schedule effective at coil creation, OQ-64)
     │
     └──(1:many)──> FlatWireRun ──(1:many)──> FlatWireRunDetail
                         │
          ┌──────────────┼──────────────────────┬──────────────────────┐
          │              │                      │                      │
     RodCheckin    RunPauseEvent           WeldEvent            SpoolCheckin
          │                                                            │
      Rod (alpha)                                               Spool (alpha)

     FlatWireRun ──(1:many)──> RollOverride
     FlatWireRun ──(1:many)──> DieChangeEvent ──> RollOverride (LinkedOverrideId)
     FlatWireRun ──(1:many)──> SpcCheckpoint ──(1:many)──> SpcMeasurement
     FlatWireRun ──(1:many)──> WipRejection
     FlatWireRun ──(1:many)──> RunReading (sampled gauge/width/speed profile)
     FlatWireRun ──(1:many)──> CoilOutput ──(1:many)──> CoilTraceability ──┬──> Rod (alpha)
                                                                           └──> Spool (alpha, NULL when rod-fed)
     FlatWireRun ──(1:many)──> RodCheckout

Spool ──> SpoolConfiguration
Spool ──> Rod (ParentRodAlpha)
Spool ──> Rod (SourceRodAlpha — partial-run source)
Spool ──> FlatWireRun (SourceRunId — the FL1 run that produced this spool)
```

---

## Foreign Key Reference Table

| Child Table | Child Column | Parent Table | Parent Column | Nullable | Notes |
|---|---|---|---|---|---|
| `PassSchedule` | `Alloy` | `AlloyProperty` | `Alloy` | NOT NULL | Authoritative alloy list |
| `PassScheduleChangeLog` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NOT NULL | Override/edit/ack audit trail |
| `PassScheduleComponent` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NOT NULL | Many components per schedule |
| `PassScheduleComponent` | `StandId` | `Stand` | `Id` | NULL | FM-type components only |
| `PassScheduleComponent` | `DrawerId` | `Drawer` | `Id` | NULL | DB-type components only |
| `PassScheduleComponent` | `EdgerId` | `Edger` | `Id` | NULL | EdgeSet component only |
| `FlatWireRun` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NOT NULL | Schedule governing this run |
| `FlatWireRunDetail` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many detail rows per run |
| `RodCheckin` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many check-ins per run |
| `RodCheckin` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Rod being checked in |
| `RodCheckin` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NOT NULL | Schedule acknowledged at check-in |
| `SpoolCheckin` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many check-ins per run |
| `SpoolCheckin` | `SpoolAlpha` | `Spool` | `Alpha` | NOT NULL | Spool being checked in |
| `SpoolCheckin` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NOT NULL | Schedule acknowledged at check-in |
| `RunPauseEvent` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many pause events per run |
| `WeldEvent` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many welds per run |
| `WeldEvent` | `OutgoingRodAlpha` | `Rod` | `Alpha` | NOT NULL | Depleting (tail) rod |
| `WeldEvent` | `IncomingRodAlpha` | `Rod` | `Alpha` | NOT NULL | Joining (lead) rod |
| `RollOverride` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many overrides per run |
| `RollOverride` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Material in-process at override time |
| `DieChangeEvent` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many die changes per run |
| `DieChangeEvent` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Material in-process at die change time |
| `DieChangeEvent` | `LinkedOverrideId` | `RollOverride` | `OverrideId` | NULL | Auto-created override for the die size change |
| `SpcCheckpoint` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many checkpoints per run |
| `SpcMeasurement` | `CheckpointId` | `SpcCheckpoint` | `CheckpointId` | NOT NULL | Many measurements per checkpoint |
| `WipRejection` | `RunId` | `FlatWireRun` | `RunId` | NULL | NULL for pre-run incoming rejections |
| `CoilOutput` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Many coils per run |
| `CoilOutput` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NULL | Schedule effective at coil creation (OQ-64) |
| `RunReading` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Sampled gauge profile per run |
| `CoilTraceability` | `CoilAlpha` | `CoilOutput` | `CoilAlpha` | NOT NULL | Many traceability rows per coil |
| `CoilTraceability` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Source rod for this footage range |
| `CoilTraceability` | `SpoolAlpha` | `Spool` | `Alpha` | NULL | Source spool for this footage range; NULL on a rod-fed run |
| `RodCheckout` | `RunId` | `FlatWireRun` | `RunId` | NULL | NULL for Mode A pre-run checkout |
| `RodCheckout` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Rod being checked out |
| `Spool` | `SpoolTypeId` | `SpoolConfiguration` | `Id` | NOT NULL | Spool type / size classification |
| `Spool` | `ParentRodAlpha` | `Rod` | `Alpha` | NULL | Rod that was drawn into this spool on FL1 |
| `Spool` | `SourceRodAlpha` | `Rod` | `Alpha` | NULL | Partial-run source rod (Phase 7 / OQ-12) |
| `Spool` | `SourceRunId` | `FlatWireRun` | `RunId` | NULL | FL1 run that produced this spool |

**`FlatWire_DDL_06_ForeignKeys.sql` creates 33 FKs — that is the MVP-1 build. 43 is the full design**, the other ten belonging to the MVP-2 `PassSchedule*` group and built by `MVP-1/ProjectPlan/Database/Schema/SQL`'s `06b`. *(Corrected 13 Aug 2026, `GapAnalysis.md` **E2**: "43 as built" was the full-design figure quoted against a script that builds 33, and the ten MVP-2 FKs are listed below **with no scope marker** — a reader implementing from this table will expect constraints that cannot exist in an MVP-1 database. An earlier "37" counted the rows in this table rather than the script.)* **Treat the script as authoritative.**

---

## Table Inventory

### Existing Tables (7) — Updated or Renamed

| Original Name | Final Name | Change Type | Schema File |
|---|---|---|---|
| `FlatLineProcessing` | `FlatWireRunDetail` | Renamed; run-level columns removed; `RunId` FK added | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `FlatLineSetup` | `PassScheduleComponent` | Renamed; restructured; `RollGap` → `ParameterValue`; `ComponentName` / `State` / `EdgeType` added | [FlatWireSchema_Schedule.md](../../../../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Schedule.md) |
| `Drawer` | `Drawer` | `Diameter` → `DiameterIn`; `MinDiameterIn` / `MaxDiameterIn` / `IsActive` added; **`LastGrindingFeet` / `TotalFeetAllowed` added (Aug 6 2026)** — die life | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Edger` | `Edger` | `EdgeType` / `IsActive` added; `Set` → `ToolingSetNo` | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Stand` | `Stand` | `MinId` / `MaxId` → `MinGaugeIn` / `MaxGaugeIn`; `MinOD` / `MaxOd` → `MinWidthIn` / `MaxWidthIn`; `LineId` / `IsActive` added | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `SpoolConfiguration` | `SpoolConfiguration` | Unit suffixes added to all dimension/weight columns; `MinId`/`MaxId` → `MinCoreDiameterIn`/`MaxCoreDiameterIn` | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Spool` | `Spool` | `Alpha` / `Status` / `GaugeIn` / `WidthIn` / weights / `Location` / timestamps / `SourceRunId` / `LineId` added; `ParentRod` → `ParentRodAlpha` | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |

### New Tables (18) — Net New

*(Was "16" against a list of 16 and an arithmetic that used 15; `RodStaging` and `PayoffPosition` were added on 13 Aug 2026 — `GapAnalysis.md` **E2**.)*

| Table | Domain | Purpose | Schema File |
|---|---|---|---|
| `PassSchedule` | Schedule | Pass schedule header — alloy, line, targets, speed range | [FlatWireSchema_Schedule.md](../../../../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Schedule.md) |
| `Rod` | Material | Wire rod receiving and lifecycle tracking | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |
| `FlatWireRun` | Runs | Run header — one row per check-in event | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RodCheckin` | Runs | Rod check-in events with inspection and SPC data | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `SpoolCheckin` | Runs | Spool check-in events at FL2/FL3 | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RunPauseEvent` | Runs | Pause/resume cycles within a run | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `WeldEvent` | Runs | Rod-to-rod weld join events | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `RollOverride` | Runs | Run-level roll gap / die parameter adjustments | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `DieChangeEvent` | Runs | Die replacement events | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `SpcCheckpoint` | Quality | SPC measurement session headers | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `SpcMeasurement` | Quality | Individual SPC measurement readings | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `WipRejection` | Quality | Material rejection events | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `CoilOutput` | Output | Finished output coil records | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `CoilTraceability` | Output | Rod-to-coil footage range mapping | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `RodCheckout` | Output | Rod removal from payoff position — **Mode A, Mode B and Mode P** *(Mode P, the pre-check-out, was missing here until 13 Aug 2026)* | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |
| `Dancer` | Lookup | Tension-management rollers — one on FM1, two on FM2 (`D-28`) | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| **`RodStaging`** | Runs | **Pre-check-in / payoff staging** — the next rod registered against a VPS bay while the current coil still runs. Two **filtered unique** indexes enforce one rod per bay and one bay per rod. `Blocked` is a **derived** state (`Status='Staged'` + any inspection `Fail`), never a fourth `Status` value | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| **`PayoffPosition`** | Lookup | **Material input/output positions with pinned Ids, not IDENTITY** — 1 `Payoff1`, 2 `Payoff2`, 3 `TraversingTakeup`. Seeded by the DDL itself, because the `FlatWireRunDetail` FK depends on the rows existing | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |

### Production-Readiness Additions (3) — July 26, 2026

| Table | Domain | Purpose | Schema File |
|---|---|---|---|
| `AlloyProperty` | Lookup | Per-alloy generator inputs + footage→weight factor; authoritative alloy list | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `PassScheduleChangeLog` | Schedule | Override/edit/acknowledgment audit trail (OQ-62) | [FlatWireSchema_Schedule.md](../../../../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Schedule.md) |
| `RunReading` | Runs | Sampled gauge/width/speed profile per run (G3) | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |

**Total: 28 tables in the full design — 25 of them MVP-1.** *(Corrected 13 Aug 2026, `GapAnalysis.md` **E2**: this line read "Total: 25" against an arithmetic of 7 + 16 + 3 = 26, with a "New Tables" heading saying 16 while the sum used 15 — and **`RodStaging` and `PayoffPosition` were missing from the inventory entirely**, though both are MVP-1 tables and `RodStaging` is the newest in the design. The MVP-1 build is `25 tables · 33 FKs · 41 index statements · 1 procedure · 1 trigger`; see `DatabaseDesign.md` §6.2, which is where the baseline is defined.)*

---

## Enumeration Reference

### Material Status Values
*Used by:* `Rod.Status`, `Spool.Status`, `CoilOutput.Status`, `RodCheckout.NewRodStatus`, `WipRejection.NewMaterialStatus`

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

## Appendix — the pre-existing tables this schema replaced

> **Absorbed from `FlatWireSchema_Mapping.md` on 13 Aug 2026**, which was deleted in the same pass. It was the April
> gap analysis — *what existed, what was missing, what to add* — and the "missing tables" half is now
> superseded by the DDL. **This half is not**: it is the only surviving inventory of the legacy
> `FlatLineProcessing` / `FlatLineSetup` / `Drawer` / `Edger` / `Stand` / `SpoolConfiguration` / `Spool`
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

#### `SpoolConfiguration`

Reference table for spool types with physical dimensional and weight constraints.

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

#### `Spool`

Represents a physical spool of pre-processed flat wire (used at FL2 check-in).

##### Current columns
| Column | Type | Notes |
|---|---|---|
| `Id` | int PK | |
| `SpoolTypeId` | int | FK to `SpoolConfiguration` |
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
| `SpoolTypeId` | int | Keep (FK → `SpoolConfiguration`) |
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
