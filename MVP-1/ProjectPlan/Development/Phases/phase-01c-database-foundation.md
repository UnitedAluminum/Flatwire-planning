# PHASE 1C — Database Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../Roadmap.md).** One of the three layer specs that replace the combined Phase 1 doc — see the [Phase 1 index](../Roadmap.md).
> **Siblings:** [1A — Angular Foundation](./phase-01a-angular-foundation.md) · [1B — Backend Foundation](./phase-01b-backend-foundation.md)
> **Reference context (do not restate):** [Foundations §0.2](../../Architecture/Architecture.md) decision 2 (new `FlatWireDB`). **Its decision 3 — "rod = existing `coils`, `Rod` dropped" — is SUPERSEDED by master-spec `D-04`: `Rod` is retained.** See *Target database & table set*. Source DDL: [`MVP-1/DBChanges/Schema/SQL/`](../../../DBChanges/Schema/SQL/) (`FlatWire_DDL_01`, `03`–`08`, the four `FlatWire_SampleData_*.sql` seeds, `FlatWire_ERDiagram_Documentation.md`). **`FlatWire_DDL_02_Schedule.sql` and `FlatWire_SampleData_Schedule.sql` are not in this set** — the pass schedule is owned outside MVP-1.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** SQL Server (`ual-database`)
**Owner:** **DB** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **215 h** (26.9 d) — DB 156 · QA 31 · cont. 28 · **Window:** W0 (to Aug 14, 12 working days = 96 h/person) · includes a discrete **40 h FW-001 impact audit** across `united_db` + the legacy tier — see model §2

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate)
> Phase 1 must be complete by **14 Aug 2026** (user mandate; supersedes the roadmap's W1 = Aug 17–23). The DDL already exists in `MVP-1/DBChanges/Schema/SQL/`; this layer's job is to **retarget, harden, seed, and wire** it so 1B's `FlatWireDbContext` maps cleanly and 1A's fixtures are backed by real rows. **FW-001 column renames touch the existing shared scheduling schema — high blast radius; front-load the impact audit.**

## Objective
Create and populate a new **`FlatWireDB`**, execute the numbered DDL in order, apply the Phase-1
hardening (indexes, missing constraints, the new `RunReading` table), author the lookup seed the
sample data depends on, and run the FW-001/FW-002 existing-schema migrations — leaving a schema that
`FlatWireDbContext` binds to and reports can query.

## Dependencies
- **Template/source:** the DDL scripts (`01`, `03`–`08`) + the four `FlatWire_SampleData_*.sql` seeds + ER doc in `MVP-1/DBChanges/Schema/SQL/`. *(`02_Schedule` and its seed are not MVP-1.)*
- **Converges with:** 1B (`FlatWireDbContext` + repositories) and 1A (fixture alphas). No blocker.
- **Backlog:** FW-001 (renames), FW-002 (`INFLAT`), FW-004 (alloy lookup), FW-005/006/007 (tables).

> **Schema changes from the 30 Jul 2026 client call — already applied to the DDL.** `RodStaging` **drops** `OffScheduleOverride`, `ScheduledLineId`, `CK_RodStaging_OffSched` and `CK_RodStaging_OffSchedLine` (the station auto-switches instead — OQ-24) and **gains** `UnstageKind` + `WipRejectionId` with an FK into `WipRejection`, so a WIP rejection can release a blocked bay (OQ-23). `AlloyProperty`'s two single-± tolerance columns become **four min/max pairs** — gauge, width, rod diameter, ovality — with **diameter and ovality NULL because the values are owed by e-mail** (OQ-22); do not seed them. `RodCheckout` gains `WasWelded` and the `ApprovedBy`/`ApprovedAt`/`OverrideReason` stamp it never had (**G24**), which **retro-enforces the OQ-74 Mode B approval**. Verified: teardown → `RunAll` clean and idempotent, **28 tables** unchanged, 15 constraint tests pass on SQL Server 2019. **FW-002 is narrowed** — `INFLAT` is set at check-in only, so the pre-check-in path must not write it.

## Target database & table set

- **New `FlatWireDB`** (decision 2). Any DDL still headering `USE [united_db]` must be retargeted.
- **`Rod` is RETAINED** — master-spec **`D-04`** (the "Hybrid foundation" decision, 29 Jul 2026) **supersedes [Foundations](../../Architecture/Architecture.md) decision 3**, which had it dropped. `Rod` is a `FlatWireDB`-local master mirroring the shared `coils` record, with **enforced** rod-alpha FKs. `coils` remains the source of truth for the rod *lifecycle* (receipt, status incl. `INFLAT`, chemistry/heat, lot); the local mirror is what lets the FKs be enforced. **This resolves `G12`** — anything still saying "`Rod` dropped / 21–22 tables" predates `D-04`.
- **Table count: 24 for MVP-1**, 27 in the full design. The three `PassSchedule*` tables are **not built here** — the pass schedule is owned outside MVP-1, so `02_Schedule` is absent from the runner and `PassScheduleId` is a **documented external reference** (see *Cross-DB logical FKs* below).
- **Verified by a clean teardown-and-rebuild on 11 Aug 2026:** 25 tables · 33 FKs · 1 procedure (`sp_GetGaugeTrace`) · 1 trigger (`trg_CoilTraceability_NoOverlap`). `sp_ShiftSummary` is **MVP-2's** and must not be created, dropped or granted from this scope.

| Group | Tables (MVP-1) |
|---|---|
| **Lookup** (`01`) | `Stand`, `Drawer`, `Edger`, `SpoolConfiguration`, `AlloyProperty`, `PayoffPosition` |
| **Schedule** (`02`) | — *not MVP-1; `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` are owned outside this scope* |
| **Materials** (`03`) | **`Rod`** (retained per `D-04`), `FlatWireRun` (hub — created here so `Spool.SourceRunId` can reference it), `Spool` |
| **Runs** (`04`) | `FlatWireRunDetail`, `RodCheckin`, `RodStaging`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`** |
| **Quality/Output** (`05`) | `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout` |
| **FKs** (`06`) | all 33 FK constraints added last |

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Database structure** | Create `FlatWireDB`; retarget `USE` statements; execute in order `01_Lookup → 02_Schedule → 03_Materials → 04_Runs → 05_QualityOutput → 06_ForeignKeys`, then `FlatWire_SampleData_Schedule.sql`. `06` adds **all FKs last**. All `CREATE`/FK guards idempotent (`IF NOT EXISTS`). |
| **Index strategy** | Add the ER-doc **recommended nonclustered indexes** (none exist today beyond PK-clustered + UNIQUE): `FlatWireRun(LineId)`, `FlatWireRun(Status)`, `FlatWireRun(PassScheduleId)`, plus **`(RunId)` on every child/event table** (`FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `RunReading`, `SpcCheckpoint`, `WipRejection`, `CoilOutput`, `RodCheckout`), `RodCheckin(RodAlpha)`, `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`, `CoilTraceability(CoilAlpha)`, `CoilTraceability(RodAlpha)`, `SpcMeasurement(CheckpointId)`, `CoilOutput(CoilAlpha)` |
| **Lookup + alloy seed** | Author `FlatWire_SampleData_Lookup.sql` (**currently missing** — the schedule seed depends on it): seed `Stand` (FM1 12″, FM2_S1 8″, FM2_S2 6″, FM2_S3 6″ — four rows, each with `RollDiameterIn`), `Drawer` (DIE-0210…DIE-0340), `Edger` (round/square), `SpoolConfiguration`, and the **Alloy properties lookup** (FW-004: `Alloy, MaxReductionPerPass, SpringbackFactor, GaugeToleranceDefault, WidthToleranceDefault, SpeedRangeMinFPM, SpeedRangeMaxFPM`) seeded 1100/1350/3003/5052/6061 — with **fixed IDENTITY values** matching the `Stand.Id 1–4 / Drawer.Id 1–13 / Edger.Id 1–2` the schedule seed references |
| **Schedule seed** | `FlatWire_SampleData_Schedule.sql` — 10 `PassSchedule` + 70 `PassScheduleComponent` rows spanning all lines/routes/alloys/statuses (fixtures `R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043` for 1A/1B mocks). **Fix the header coverage comment** (says Standalone 3 / Hybrid 7; actual **4 / 6**) |
| **Existing-schema migration (FW-001/002)** | Slash-dual-name renames on the existing scheduling/`coils` schema: `CoilNo→Coil/BundleNo`, `SlitWidth→Slit/FlatWidth`, `IsCampaingCoil→IsCampaignCoil/Bundle`, `CoilLocation→Coil/BundleLocation`, `CoilWeight→Coil/BundleWeight`, `CoilStatus→Coil/BundleStatus`, `OutgoingCoilId→OutgoingCoil/BundleId`, `OutgoingCoilOd→OutgoingCoil/BundleOd`; new columns `OutgoingCoil/BundleWidth`, `IncomingWireDia`; new coil status **`INFLAT`** (FW-002). **Precede with a full SP/view/report impact audit** (high blast radius) |
| **Data-access wiring** | Map `FlatWireDbContext` (1B) to all **24 MVP-1 tables**; keep legacy `FlatLineSetup`/`FlatLineProcessing` for the migration window, then drop after data moves to `PassScheduleComponent`/`FlatWireRunDetail` |
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
- Post-run checks: **25 tables** present (33 FKs, 1 procedure, 1 trigger — verified by clean deploy 11 Aug 2026); every FK in `06` resolves; every recommended index exists; `PassSchedule` has exactly one `Active` row per `LineId+Alloy`; `CoilTraceability` ranges non-overlapping per coil.
- `FlatWireDbContext` (1B) reads/writes each table; a smoke insert→select round-trips through EF.
- Seed integrity: schedule seed FK-resolves against the lookup seed IDENTITY values.

## Acceptance criteria (exit)
1. `FlatWireDB` created; DDL 01–06 + lookup seed + schedule seed execute clean, in order, idempotently.
2. **25 tables** exist (incl. `RunReading` **and `Rod`** — `D-04` retains it, superseding the "drop `Rod`" position in [Foundations](../../Architecture/Architecture.md) decision 3); all FKs and recommended indexes present. The three `PassSchedule*` tables are **not** built here — the pass schedule is owned outside MVP-1.
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
- **`PassScheduleId` joins that list** (11 Aug 2026) — on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput`. **Pass schedule generation and management are owned outside MVP-1**, so `PassSchedule`, `PassScheduleComponent` and `PassScheduleChangeLog` are not built here and no local FK is possible. This is **not** a missing table or a deferred constraint: it is the same class of reference as `PlanId`, and `FlatWire_DDL_RunAll.sql` produces a complete MVP-1 database on its own. Rod check-in still **reads** a schedule's contents to build the PLC push payload — that boundary is specified in `phase-04`.
  - Seeded `PassScheduleId` values (`PS-1100-FL1-001` and friends) are therefore **external identifiers, not orphans**. Treat them as you treat a seeded `PlanId`.
  - **Consider `NULL`-ing the constraint:** `PassScheduleId` is `NOT NULL` on `FlatWireRun`, `RodCheckin` and `SpoolCheckin`, which asserts an existence MVP-1 cannot verify. Leaving it is defensible (check-in genuinely cannot proceed without a schedule); relaxing it is also defensible. **Decide once and record it here** rather than per-table.
