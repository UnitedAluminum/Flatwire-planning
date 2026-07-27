# PHASE 1C — Database Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** One of the three layer specs that replace the combined Phase 1 doc — see the [Phase 1 index](./phase-01-core-platform-setup.md).
> **Siblings:** [1A — Angular Foundation](./phase-01a-angular-foundation.md) · [1B — Backend Foundation](./phase-01b-backend-foundation.md)
> **Reference context (do not restate):** [Foundations §0.2](./00-foundations.md) decisions 2 & 3 (new `FlatWireDB`; rod = existing `coils`). Source DDL: [`../Schema/SQL/`](../Schema/SQL/) (`FlatWire_DDL_01..06`, `FlatWire_SampleData_Schedule.sql`, `FlatWire_ERDiagram_Documentation.md`).

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-26
**Status:** Ready to build
**Layer:** SQL Server (`ual-database`)

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate)
> Phase 1 must be complete by **14 Aug 2026** (user mandate; supersedes the roadmap's W1 = Aug 17–23). The DDL already exists in `Schema/SQL/`; this layer's job is to **retarget, harden, seed, and wire** it so 1B's `FlatWireDbContext` maps cleanly and 1A's fixtures are backed by real rows. **FW-001 column renames touch the existing shared scheduling schema — high blast radius; front-load the impact audit.**

## Objective
Create and populate a new **`FlatWireDB`**, execute the numbered DDL in order, apply the Phase-1
hardening (indexes, missing constraints, the new `RunReading` table), author the lookup seed the
sample data depends on, and run the FW-001/FW-002 existing-schema migrations — leaving a schema that
`FlatWireDbContext` binds to and reports can query.

## Dependencies
- **Template/source:** the six DDL scripts + `FlatWire_SampleData_Schedule.sql` + ER doc in `Schema/SQL/`.
- **Converges with:** 1B (`FlatWireDbContext` + repositories) and 1A (fixture alphas). No blocker.
- **Backlog:** FW-001 (renames), FW-002 (`INFLAT`), FW-004 (alloy lookup), FW-005/006/007 (tables).

## Target database & table set
- **New `FlatWireDB`** (decision 2). The DDL scripts currently header `USE [united_db]` and must be **retargeted to `FlatWireDB`** (one find-replace across DDL 01–06 + seed).
- The designed **`Rod` table is dropped** (decision 3): R-series rod material lives in the existing **`coils`** table (single source of truth). Every rod-alpha reference (`RodCheckin.RodAlpha`, `WeldEvent.Outgoing/IncomingRodAlpha`, `RollOverride.RodAlpha`, `DieChangeEvent.RodAlpha`, `CoilTraceability.RodAlpha`, `RodCheckout.RodAlpha`, `Spool.ParentRodAlpha`) is a **cross-database logical link to `coils` — no enforced FK** (G2/G17).
- **Table count: 22** = the roadmap's 21 (after dropping `Rod`) **+ the new `RunReading`** time-series table added here (see Review-fixes / G3).

| Group | Tables |
|---|---|
| **Lookup** (`01`) | `Stand`, `Drawer`, `Edger`, `SpoolConfiguration` |
| **Schedule** (`02`) | `PassSchedule` (PK `ScheduleId` varchar), `PassScheduleComponent` |
| **Materials** (`03`) | `FlatWireRun` (hub — created here so `Spool.SourceRunId` can reference it), `Spool` — *`Rod` dropped* |
| **Runs** (`04`) | `FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`** (new) |
| **Quality/Output** (`05`) | `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout` |
| **FKs** (`06`) | all FK constraints added last |

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Database structure** | Create `FlatWireDB`; retarget `USE` statements; execute in order `01_Lookup → 02_Schedule → 03_Materials → 04_Runs → 05_QualityOutput → 06_ForeignKeys`, then `FlatWire_SampleData_Schedule.sql`. `06` adds **all FKs last**. All `CREATE`/FK guards idempotent (`IF NOT EXISTS`). |
| **Index strategy** | Add the ER-doc **recommended nonclustered indexes** (none exist today beyond PK-clustered + UNIQUE): `FlatWireRun(LineId)`, `FlatWireRun(Status)`, `FlatWireRun(PassScheduleId)`, plus **`(RunId)` on every child/event table** (`FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `RunReading`, `SpcCheckpoint`, `WipRejection`, `CoilOutput`, `RodCheckout`), `RodCheckin(RodAlpha)`, `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`, `CoilTraceability(CoilAlpha)`, `CoilTraceability(RodAlpha)`, `SpcMeasurement(CheckpointId)`, `CoilOutput(CoilAlpha)` |
| **Lookup + alloy seed** | Author `FlatWire_SampleData_Lookup.sql` (**currently missing** — the schedule seed depends on it): seed `Stand` (FM1, FM2_8in, FM2_6inS1, FM2_6inS2, FM2_6inS3), `Drawer` (DIE-0210…DIE-0340), `Edger` (round/square), `SpoolConfiguration`, and the **Alloy properties lookup** (FW-004: `Alloy, MaxReductionPerPass, SpringbackFactor, GaugeToleranceDefault, WidthToleranceDefault, SpeedRangeMinFPM, SpeedRangeMaxFPM`) seeded 1100/1350/3003/5052/6061 — with **fixed IDENTITY values** matching the `Stand.Id 1–4 / Drawer.Id 1–13 / Edger.Id 1–2` the schedule seed references |
| **Schedule seed** | `FlatWire_SampleData_Schedule.sql` — 10 `PassSchedule` + 70 `PassScheduleComponent` rows spanning all lines/routes/alloys/statuses (fixtures `R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043` for 1A/1B mocks). **Fix the header coverage comment** (says Standalone 3 / Hybrid 7; actual **4 / 6**) |
| **Existing-schema migration (FW-001/002)** | Slash-dual-name renames on the existing scheduling/`coils` schema: `CoilNo→Coil/BundleNo`, `SlitWidth→Slit/FlatWidth`, `IsCampaingCoil→IsCampaignCoil/Bundle`, `CoilLocation→Coil/BundleLocation`, `CoilWeight→Coil/BundleWeight`, `CoilStatus→Coil/BundleStatus`, `OutgoingCoilId→OutgoingCoil/BundleId`, `OutgoingCoilOd→OutgoingCoil/BundleOd`; new columns `OutgoingCoil/BundleWidth`, `IncomingWireDia`; new coil status **`INFLAT`** (FW-002). **Precede with a full SP/view/report impact audit** (high blast radius) |
| **Data-access wiring** | Map `FlatWireDbContext` (1B) to all 22 tables; keep legacy `FlatLineSetup`/`FlatLineProcessing` for the migration window, then drop after data moves to `PassScheduleComponent`/`FlatWireRunDetail` |
| **Security** | `GRANT EXECUTE`/least-privilege for `ua_user`; audit columns (`CreatedBy/At`, `ModifiedBy/At`) on `PassSchedule` + override tables |

## Relationship model
`FlatWireRun` (natural key `RunId`) is the hub — 1→N to `FlatWireRunDetail`, `RodCheckin`,
`SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`**,
`SpcCheckpoint`(→`SpcMeasurement`), `CoilOutput`(→`CoilTraceability`); 0→N (nullable `RunId`) to
`WipRejection` and `RodCheckout` (pre-run cases). Certs genealogy:
`CoilOutput.CoilAlpha → CoilTraceability (FootageFrom..FootageTo) →` **`coils` R-series row** →
heat/lot via the existing chemistry/`Lots` tables.

## Testing
- All six DDL scripts + both seeds run **clean and idempotent** on a fresh dev `FlatWireDB` (re-runnable).
- Post-run checks: 22 tables present; every FK in `06` resolves; every recommended index exists; `PassSchedule` has exactly one `Active` row per `LineId+Alloy`; `CoilTraceability` ranges non-overlapping per coil.
- `FlatWireDbContext` (1B) reads/writes each table; a smoke insert→select round-trips through EF.
- Seed integrity: schedule seed FK-resolves against the lookup seed IDENTITY values.

## Acceptance criteria (exit)
1. `FlatWireDB` created; DDL 01–06 + lookup seed + schedule seed execute clean, in order, idempotently.
2. 22 tables exist (incl. `RunReading`); `Rod` table **not** created; all FKs and recommended indexes present.
3. `RodCheckout.NewRodStatus` and every status column carry an enumerating `CHECK`; the doc-stated business constraints are enforced (see Review-fixes).
4. FW-001 renames + FW-002 `INFLAT` applied on the existing schema behind a completed impact audit.
5. `FlatWireDbContext` binds all tables; seed rows back the 1A/1B fixture alphas.

## Review-fixes applied in this layer
- **G3 — new `RunReading` table** (persists raw AGC readings; FL2 historical profile + Gauge-Trace / Cut-Traceability reports depend on it). Suggested shape — add to `04_Runs`:
  ```sql
  CREATE TABLE dbo.RunReading (
      Id           INT IDENTITY(1,1) CONSTRAINT PK_RunReading PRIMARY KEY,
      RunId        VARCHAR(20)   NOT NULL,           -- logical FK → FlatWireRun.RunId
      FootageFt    DECIMAL(10,2) NOT NULL,
      GaugeIn      DECIMAL(8,4)  NULL,
      WidthIn      DECIMAL(8,4)  NULL,
      SpeedFPM     DECIMAL(8,2)  NULL,
      InSpec       BIT           NOT NULL CONSTRAINT DF_RunReading_InSpec DEFAULT(1),
      ReadingTs    DATETIME2     NOT NULL
  );  -- FK to FlatWireRun in 06; index (RunId, FootageFt); define retention/rollup policy
  ```
- **`RodCheckout.NewRodStatus` CHECK** added (every other status column has one) — `CHECK (NewRodStatus IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP'))`.
- **Enforce doc-stated constraints in DDL:** filtered unique index for one `Active` `PassSchedule` per `LineId+Alloy`; `CoilTraceability` non-overlapping footage ranges per coil; `RunPauseEvent.Notes` required when `ReasonCategory='Other'`; `WeldEvent` fail-reason required when `WeldQuality='Fail'`; RodCheckout Mode-A/B field rules.
- **Precision drift (doc↔DDL):** the **DDL scaled types are authoritative** — weights `DECIMAL(8,2)`, gauges `DECIMAL(8,4)`, footage/measures `(10,2)/(10,4)`. Do **not** regenerate DDL from the schema `.md` files (they say bare `decimal` = `decimal(18,0)`, which would drop precision); the schema docs should be corrected up to the DDL (tracked for the reconcile-up pass).
- **`FootageFt` datatype:** standardise — `FlatWireRunDetail.FootageFt DECIMAL(10,2)` and `RunReading.FootageFt DECIMAL(10,2)`; event-marker footage positions stay `INT` only where whole-foot is intended, documented per column (resolves the INT-vs-DECIMAL inconsistency, G14).
- **Missing lookup seed authored** (the schedule seed's `Stand/Drawer/Edger` IDENTITY references were previously unshippable).
- **Canonical enums (cross-layer):** `PassScheduleComponent.State CHECK IN ('Active','Bypass','Skip')`; `Edger`/edge type CHECK `IN ('Round','Square')`. Must match 1A model + 1B enum.
- **`CheckpointType`** CHECK includes `'RollAdjustTrigger'` (mirror of the 1B enum fix).
- **Cross-DB logical FKs** to `coils` (rod alphas), `CoilOutput.SkidId`, planning `PlanId`/`CoilOrderPlanId`, `PayoffPositionId` stay **unenforced and are documented as external references** (G2/G17) rather than dangling FKs implying a missing local table.
