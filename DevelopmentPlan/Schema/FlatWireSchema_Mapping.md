# Flat Wire Mill — Schema Mapping & Entity Relationships

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
**Document Type:** Final Schema — Entity Relationships, FK Mapping & Enumeration Reference
**Source:** Derived from `FlatWireTables.md` recommendations
**Target DB:** `FlatWireDB` (schema `dbo`)

---

## Entity Relationship Diagram

```
AlloyProperty ──(1:many)──> PassSchedule   (PassSchedule.Alloy → AlloyProperty.Alloy)

PassSchedule ──(1:many)──> PassScheduleComponent
     │                           │
     │                     Stand / Drawer / Edger (lookups)
     ├──(1:many)──> PassScheduleChangeLog
     ├──(0:many)──> CoilOutput (schedule effective at coil creation, OQ-54)
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
     FlatWireRun ──(1:many)──> CoilOutput ──(1:many)──> CoilTraceability ──> Rod (alpha)
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
| `CoilOutput` | `PassScheduleId` | `PassSchedule` | `ScheduleId` | NULL | Schedule effective at coil creation (OQ-54) |
| `RunReading` | `RunId` | `FlatWireRun` | `RunId` | NOT NULL | Sampled gauge profile per run |
| `CoilTraceability` | `CoilAlpha` | `CoilOutput` | `CoilAlpha` | NOT NULL | Many traceability rows per coil |
| `CoilTraceability` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Source rod for this footage range |
| `RodCheckout` | `RunId` | `FlatWireRun` | `RunId` | NULL | NULL for Mode A pre-run checkout |
| `RodCheckout` | `RodAlpha` | `Rod` | `Alpha` | NOT NULL | Rod being checked out |
| `Spool` | `SpoolTypeId` | `SpoolConfiguration` | `Id` | NOT NULL | Spool type / size classification |
| `Spool` | `ParentRodAlpha` | `Rod` | `Alpha` | NULL | Rod that was drawn into this spool on FL1 |
| `Spool` | `SourceRodAlpha` | `Rod` | `Alpha` | NULL | Partial-run source rod (Phase 7 / OQ-47) |
| `Spool` | `SourceRunId` | `FlatWireRun` | `RunId` | NULL | FL1 run that produced this spool |

**Total: 37 FK constraints** (added in `FlatWire_DDL_06_ForeignKeys.sql`).

---

## Table Inventory

### Existing Tables (7) — Updated or Renamed

| Original Name | Final Name | Change Type | Schema File |
|---|---|---|---|
| `FlatLineProcessing` | `FlatWireRunDetail` | Renamed; run-level columns removed; `RunId` FK added | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |
| `FlatLineSetup` | `PassScheduleComponent` | Renamed; restructured; `RollGap` → `ParameterValue`; `ComponentName` / `State` / `EdgeType` added | [FlatWireSchema_Schedule.md](FlatWireSchema_Schedule.md) |
| `Drawer` | `Drawer` | `Diameter` → `DiameterIn`; `MinDiameterIn` / `MaxDiameterIn` / `IsActive` added | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Edger` | `Edger` | `EdgeType` / `IsActive` added; `Set` → `ToolingSetNo` | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Stand` | `Stand` | `MinId` / `MaxId` → `MinGaugeIn` / `MaxGaugeIn`; `MinOD` / `MaxOd` → `MinWidthIn` / `MaxWidthIn`; `LineId` / `IsActive` added | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `SpoolConfiguration` | `SpoolConfiguration` | Unit suffixes added to all dimension/weight columns; `MinId`/`MaxId` → `MinCoreDiameterIn`/`MaxCoreDiameterIn` | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `Spool` | `Spool` | `Alpha` / `Status` / `GaugeIn` / `WidthIn` / weights / `Location` / timestamps / `SourceRunId` / `LineId` added; `ParentRod` → `ParentRodAlpha` | [FlatWireSchema_Materials.md](FlatWireSchema_Materials.md) |

### New Tables (15) — Net New

| Table | Domain | Purpose | Schema File |
|---|---|---|---|
| `PassSchedule` | Schedule | Pass schedule header — alloy, line, targets, speed range | [FlatWireSchema_Schedule.md](FlatWireSchema_Schedule.md) |
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
| `RodCheckout` | Output | Rod removal from payoff position (Mode A and B) | [FlatWireSchema_QualityOutput.md](FlatWireSchema_QualityOutput.md) |

### Production-Readiness Additions (3) — July 26, 2026

| Table | Domain | Purpose | Schema File |
|---|---|---|---|
| `AlloyProperty` | Lookup | Per-alloy generator inputs + footage→weight factor; authoritative alloy list | [FlatWireSchema_Lookup.md](FlatWireSchema_Lookup.md) |
| `PassScheduleChangeLog` | Schedule | Override/edit/acknowledgment audit trail (OQ-28) | [FlatWireSchema_Schedule.md](FlatWireSchema_Schedule.md) |
| `RunReading` | Runs | Sampled gauge/width/speed profile per run (G3) | [FlatWireSchema_Runs.md](FlatWireSchema_Runs.md) |

**Total: 25 tables** (7 existing updated/renamed + 15 net new + 3 production-readiness additions)

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
| `FM2_8in` | Finishing mill | FL2, FL3 | FM2 8-inch roll (legacy; retained for pre-May-21 schedules) |
| `FM2_6inS1` | Finishing mill | FL2, FL3 | FM2 6-inch stand S1 |
| `FM2_6inS2` | Finishing mill | FL2, FL3 | FM2 6-inch stand S2 (edger position) |
| `FM2_6inS3` | Finishing mill | FL2, FL3 | FM2 6-inch stand S3, final (edger position; May-21-2026 revision) |

*Note: `FM1` is not bypassable; `EdgeSet` is FL1-legacy (FL1 has no edger per the May-21-2026 revision — edgers are at FM2 S2/S3).*

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

## Change Log

| Date | Change |
|---|---|
| July 26, 2026 | Retargeted to `FlatWireDB`. Added 3 production-readiness tables (`AlloyProperty`, `PassScheduleChangeLog`, `RunReading`) → 25 tables, 37 FKs. Added FKs `PassSchedule.Alloy→AlloyProperty`, `PassScheduleChangeLog→PassSchedule`, `CoilOutput.PassScheduleId→PassSchedule`, `RunReading→FlatWireRun`, `Spool.SourceRodAlpha→Rod`. Added component `FM2_6inS3` (May-21-2026 revision). Documented MMS ID / spool-numbering resolutions. See per-domain docs for column-level changes; schema validated on SQL Server 2019. |
