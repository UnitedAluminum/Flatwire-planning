# PHASE 1C — Database Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../Roadmap.md).** One of the three layer specs that replace the combined Phase 1 doc.
> **Siblings:** [1A — Angular Foundation](./phase-01a-angular-foundation.md) · [1B — Backend Foundation](./phase-01b-backend-foundation.md)
> **Reference context (do not restate):** [`[ARC §13.1]`](../../Architecture/Architecture.md) `D-02` (new `FlatWireDB`). **The dissolved foundations doc's decision 3 — "rod = existing `coils`, `Rod` dropped" — is SUPERSEDED by master-spec `D-04`: `Rod` is retained.** See *Target database & table set*. Also [`[DBD §6.2]`](../../Database/DatabaseDesign.md) — the **counted** object baseline. Source DDL: [`Database/Schema/SQL/`](../../Database/Schema/SQL/) (`FlatWire_DDL_01`, `03`–`08`, the four `FlatWire_SampleData_*.sql` seeds, `FlatWire_ERDiagram_Documentation.md`). **`FlatWire_DDL_02_Schedule.sql`, `FlatWire_SampleData_Schedule.sql`, `06b` and `07b` joined this set on 15 Aug 2026 (`D-31`)** — only `08b` (`sp_ShiftSummary`, for the deferred DB10) stays MVP-2.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-15 — **`D-31`: the three `PassSchedule*` tables, their seed, `06b` and `07b` moved INTO MVP-1**, so the runner builds **28 tables · 43 FKs · 47 indexes · 1 procedure · 1 trigger** (live-deploy verified) and `PassScheduleId` is an **enforced FK**. Also **`G38` schema delta landed**: five `FlatWireRun` prompt columns this phase owes 1B, without which `FR-144`'s durable spool-completion prompt has nowhere to live and `phase-01b` acceptance criterion 4 cannot be met *(otherwise 2026-08-14 — reconciled to the 13 Aug ProjectPlan restructure; table counts corrected to the `[DBD §6.2]` baseline; blockers and stories trailers added. **No effort figure in this file changed** — but see the understatement note below)*
**Status:** **Ready to build — but the 14 Aug gate was not met**
**Layer:** SQL Server (`ual-database`)
**Owner:** **DB** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Scope call:** **Wholly MVP-1** — and since `D-31` (15 Aug 2026) that includes the three `PassSchedule*` tables, their seed, their 10 FKs and their 6 indexes. **`PassScheduleId` is a real, enforced FK**, not an external reference. Only `sp_ShiftSummary` is MVP-2's. ⚠ **MVP-1 builds and reads these tables; it never authors a schedule** — DB9/DB9A stay MVP-2 (`OI-110`).
**Effort:** **221 h** (27.6 d) — DB 160 · QA 32 · cont. 29 · **Window:** W0 (to Aug 14, 12 working days = 96 h/person) · includes a discrete **40 h FW-001 impact audit** across `united_db` + the legacy tier — see `[CE §2]`

> ⚠ **The published 221 h is known to be understated, and this file does not correct it.** *(215 h until 15 Aug 2026, when `FW-007` gained 4 h for `G21`'s `Station` column and re-keyed index — a separate matter from the understatement below; do not net them.)* `[CE §8]`: *"**1C is costed against 22 tables, and the build is 25.** Each table beyond the 22 is **4 h** plus its share of QA and contingency (~5.5 h all-in), so 1C is **understated by roughly 17 h**."* `[TRP §1.4]` carries the same finding on its own basis (*"65 h + ~11 h of known understatement"*). **`[CE]` owns the figure** — it is stated here so the two documents stop disagreeing by omission, not re-priced here.

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate) — **not met**
> Phase 1 was to be complete by **14 Aug 2026** (user mandate; superseded the roadmap's W1 = Aug 17–23). The DDL already exists in `Database/Schema/SQL/`; this layer's job is to **retarget, harden, seed, and wire** it so 1B's `FlatWireDbContext` maps cleanly and 1A's fixtures are backed by real rows. **FW-001 column renames touch the existing shared scheduling schema — high blast radius; front-load the impact audit.**
> **`[RM]` records that 30 Sep is now a trial-run date, not an MVP-1 feature-complete date.** `[TRP]` requires 1C to finish inside T1 — it gates every write — and defers `FW-001`'s renames and their 40 h audit out of trial scope entirely.

## Objective
Create and populate a new **`FlatWireDB`**, execute the numbered DDL in order, apply the Phase-1
hardening (indexes, missing constraints, the new `RunReading` table), author the lookup seed the
sample data depends on, and run the FW-001/FW-002 existing-schema migrations — leaving a schema that
`FlatWireDbContext` binds to and reports can query.

## Dependencies
- **Template/source:** the DDL scripts (`01`–`08`, including `02`, `06b` and `07b`) + **five** `FlatWire_SampleData_*.sql` seeds + ER doc in `MVP-1/ProjectPlan/Database/Schema/SQL/`.
- **Converges with:** 1B (`FlatWireDbContext` + repositories) and 1A (fixture alphas). No blocker.
- **Backlog:** see the **Stories** trailer at the foot of this file.

> **Schema changes from the 30 Jul 2026 client call — already applied to the DDL.** `RodStaging` **drops** `OffScheduleOverride`, `ScheduledLineId`, `CK_RodStaging_OffSched` and `CK_RodStaging_OffSchedLine` (the station auto-switches instead — OQ-24) and **gains** `UnstageKind` + `WipRejectionId` with an FK into `WipRejection`, so a WIP rejection can release a blocked bay (OQ-23). `AlloyProperty`'s two single-± tolerance columns become **four min/max pairs** — gauge, width, rod diameter, ovality — with **diameter and ovality NULL because the values are owed by e-mail** (OQ-22); do not seed them. `RodCheckout` gains `WasWelded` and the `ApprovedBy`/`ApprovedAt`/`OverrideReason` stamp it never had (**G24**), which **retro-enforces the OQ-74 Mode B approval**. Verified: teardown → `RunAll` clean and idempotent, **all 28 tables built by the MVP-1 runner** (`D-31`), 15 constraint tests pass on SQL Server 2019. **FW-002 is narrowed** — `INFLAT` is set at check-in only, so the pre-check-in path must not write it.

## Target database & table set

- **New `FlatWireDB`** (decision 2). Any DDL still headering `USE [united_db]` must be retargeted.
- **`Rod` is RETAINED** — master-spec **`D-04`** (the "Hybrid foundation" decision, 29 Jul 2026) **supersedes the dissolved foundations doc's decision 3**, which had it dropped — the reversal is recorded at [`[ARC §13.1]`](../../Architecture/Architecture.md). `Rod` is a `FlatWireDB`-local master mirroring the shared `coils` record, with **enforced** rod-alpha FKs. `coils` remains the source of truth for the rod *lifecycle* (receipt, status incl. `INFLAT`, chemistry/heat, lot); the local mirror is what lets the FKs be enforced. **This resolves `G12`** — anything still saying "`Rod` dropped / 21–22 tables" predates `D-04`.
- **Table count: 28 — MVP-1 and the full design are the same set** since `D-31` (15 Aug 2026) moved the three `PassSchedule*` tables into MVP-1. `[DBD §6.2]` is the baseline. ⚠ **Every earlier count is superseded**, including the "25 for MVP-1 / 28 in the full design" split this line used to carry, and `[DBD §6.2]`'s stale sequence **20 → 21 → 22 → 24 → 27**.
- **Verified by a clean teardown-and-rebuild on 15 Aug 2026:** **28 tables · 43 FKs · 47 index statements · 1 procedure** (`sp_GetGaugeTrace`) **· 1 trigger** (`trg_CoilTraceability_NoOverlap`), idempotent on re-run. `sp_ShiftSummary` is **MVP-2's** and is correctly **absent**.

| Group | Tables (MVP-1) |
|---|---|
| **Lookup** (`01`) | `Stand`, `Drawer`, `Edger`, `SpoolConfiguration`, `AlloyProperty`, `PayoffPosition` |
| **Schedule** (`02`) | `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` — **MVP-1 since `D-31`**; built by the runner, **read** by MVP-1 and authored by nobody in it |
| **Materials** (`03`) | **`Rod`** (retained per `D-04`), `FlatWireRun` (hub — created here so `Spool.SourceRunId` can reference it), `Spool` |
| **Runs** (`04`) | `FlatWireRunDetail`, `RodCheckin`, `RodStaging`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`** |
| **Quality/Output** (`05`) | `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout` |
| **FKs** (`06`, `06b`) | all **43** FK constraints added after the tables — 33 in `06`, 10 in `06b` (the schedule group, **including the four now-enforced `PassScheduleId` links**) |

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Database structure** | Create `FlatWireDB`; retarget `USE` statements; execute in **contiguous numeric order** `01_Lookup → 02_Schedule → 03_Materials → 04_Runs → 05_QualityOutput → 06_ForeignKeys → 06b_ForeignKeys → 07_Indexes → 07b_Indexes → 08_Programmability`, then **five** seeds in dependency order: `Lookup → Schedule → Materials → Runs → QualityOutput`. ⚠ **The schedule seed must precede Materials** — `FlatWireRun.PassScheduleId` is now a real FK, so seeding Materials first fails the deploy. ⚠ **`02_Schedule`, its seed, `06b` and `07b` moved into MVP-1 on 15 Aug 2026 (`D-31`)**; text elsewhere calling them *"deliberately absent"* or *"MVP-2-owned"* is **stale**. Only `08b` (`sp_ShiftSummary`, Dashboard 10) stays MVP-2. All DDL runs before any seed, so the FK chain lands on **empty tables**. All guards idempotent (`IF NOT EXISTS`) — `FlatWire_DDL_RunAll.sql` is safe to re-run. |
| **Index strategy** | Add the ER-doc **recommended nonclustered indexes** (none exist today beyond PK-clustered + UNIQUE): `FlatWireRun(LineId)`, `FlatWireRun(Status)`, `FlatWireRun(PassScheduleId)`, plus **`(RunId)` on every child/event table** (`FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `RunReading`, `SpcCheckpoint`, `WipRejection`, `CoilOutput`, `RodCheckout`), `RodCheckin(RodAlpha)`, `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`, `CoilTraceability(CoilAlpha)`, `CoilTraceability(RodAlpha)`, `SpcMeasurement(CheckpointId)`, `CoilOutput(CoilAlpha)` |
| **Lookup + alloy seed** | Author `FlatWire_SampleData_Lookup.sql` (**currently missing** — the schedule seed depends on it): seed `Stand` (FM1 12″, FM2_S1 8″, FM2_S2 6″, FM2_S3 6″ — four rows, each with `RollDiameterIn`), `Drawer` (DIE-0210…DIE-0340), `Edger` (round/square), `SpoolConfiguration`, and the **Alloy properties lookup** (FW-004: `Alloy, MaxReductionPerPass, SpringbackFactor, GaugeToleranceDefault, WidthToleranceDefault, SpeedRangeMinFPM, SpeedRangeMaxFPM`) seeded 1100/1350/3003/5052/6061 — with **fixed IDENTITY values** matching the `Stand.Id 1–4 / Drawer.Id 1–13 / Edger.Id 1–2` the schedule seed references |
| **Schedule seed** | `FlatWire_SampleData_Schedule.sql` — 10 `PassSchedule` + 70 `PassScheduleComponent` rows spanning all lines/routes/alloys/statuses (fixtures `R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043` for 1A/1B mocks). **Fix the header coverage comment** (says Standalone 3 / Hybrid 7; actual **4 / 6**) |
| **Existing-schema migration (FW-001/002)** | Slash-dual-name renames on the existing scheduling/`coils` schema: `CoilNo→Coil/BundleNo`, `SlitWidth→Slit/FlatWidth`, `IsCampaingCoil→IsCampaignCoil/Bundle`, `CoilLocation→Coil/BundleLocation`, `CoilWeight→Coil/BundleWeight`, `CoilStatus→Coil/BundleStatus`, `OutgoingCoilId→OutgoingCoil/BundleId`, `OutgoingCoilOd→OutgoingCoil/BundleOd`; new columns `OutgoingCoil/BundleWidth`, `IncomingWireDia`; new coil status **`INFLAT`** (FW-002). **Precede with a full SP/view/report impact audit** (high blast radius) |
| **Data-access wiring** | Map `FlatWireDbContext` (1B) to all **25 MVP-1 tables**; keep legacy `FlatLineSetup`/`FlatLineProcessing` for the migration window, then drop after data moves to `FlatWireRunDetail` — ⚠ **and to `PassScheduleComponent`, which is MVP-2's**, so the legacy drop cannot complete inside MVP-1 alone (`G8` has no migration deliverable) |
| **Security** | `GRANT EXECUTE`/least-privilege for `ua_user`; audit columns (`CreatedBy/At`, `ModifiedBy/At`) on `PassSchedule` + override tables |
| **Spool-completion prompt state — `G38`** ✅ **landed 15 Aug 2026** | `FR-144` requires `SpoolCompletionPromptDue` to be **server-owned state persisted against the run**, re-delivered on group re-join (`[SIG §5.2]`, `TC-173` **P1**) — and no column could hold it. **Five columns added to `FlatWireRun`**: `PromptDueAt` · `PromptPlcStopTs` (the latch instant) · `PromptLatchedWeightLb` · `PromptResolvedAt` · `PromptAnswer`, with `CK_FlatWireRun_PromptAnswer CHECK ([PromptAnswer] IN ('Yes','No','AutoDismissed') OR [PromptAnswer] IS NULL)` per `[SIG §5.2]`'s vocabulary. **Columns, not a new table** — *"persisted against the run"* is literal and the table count is unaffected. ⚠ **Cost is sequencing, not hours**: `FW-202` already carries **DB 8 h** and its AC *"server-owned state, persisted against the run"* is this work — **do not add a second DB allocation.** This phase owns the DDL so it exists when `RunAll` deploys; `FW-202` builds against it in T3 |

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
- ⚠ **`PassScheduleId` LEFT that list on 15 Aug 2026 (`D-31`) — it is now a real, enforced FK.** `FK_FlatWireRun_PassSchedule`, `FK_RodCheckin_PassSchedule`, `FK_SpoolCheckin_PassSchedule` and `FK_CoilOutput_PassSchedule` are created by `06b`, which the MVP-1 runner now includes; all four verified **enforced and trusted** on a live deploy, with **zero orphans**.
  - **The seeded values are now real parents, not external identifiers.** `PS-1100-FL1-001` and friends resolve to rows in `PassSchedule`, seeded by `FlatWire_SampleData_Schedule.sql` immediately before the Materials seed.
  - **The `NOT NULL` question is closed.** `PassScheduleId` being `NOT NULL` on `FlatWireRun`, `RodCheckin` and `SpoolCheckin` no longer asserts an existence MVP-1 cannot verify — it can, and the FK does. **Do not `NULL` it.**
  - ⚠ **This does not make MVP-1 an author.** It reads schedules; DB9/DB9A stay MVP-2 and no endpoint writes one. **Nothing in MVP-1 populates the table in production** — `OI-110`.

---

**OQ blockers:** ~~**`G21`**~~ **✅ RESOLVED 15 Aug 2026 — one physical station.** `RodStaging` gained a persisted **`[Station] VARCHAR(10) NOT NULL`** and `UX_RodStaging_Bay` was re-keyed to `([Station],[PayoffPosition]) WHERE [Status]='Staged'`. Verified against a live deploy: an FL3 rod staged at `FL1PO` position 1 is now rejected — *"duplicate key value is (FL1PO, 1)"* — where the old `(LineId,PayoffPosition)` key allowed it. The `RodStaging` **aggregate** enforces the same rule in code (`D-29`), so the index is belt-and-braces. **The DB2A toggle half is `FW-209`.** *(Original text: **`UX_RodStaging_Bay` did not enforce one-rod-per-bay across FL1/FL3** — `CK_RodStaging_LineId` admits both, so `(FL1,1)` and `(FL3,1)` are distinct entries while everything in the design assumes one physical VPS. **Blocks the Phase-4 schema freeze**; the reading on record is to key uniqueness on the *station*) · **`G3`** (register still reads Open while `RunReading` is built here under `FW-007` — reconcile the register, not the schema) · **`G17`** (rod→`coils` cross-DB logical FKs; `Rod` is a local mirror precisely so the alpha FKs can be **enforced**) · **`OI-33`** (**`planning_routings` columns unmapped** — 1B's `RodRepository` and the `Available` queue projection are built against them) · **`G14`** (footage `DECIMAL` vs `INT`, and the non-canonical `ROD-`/`SPL-` alphas in older worked examples) · **`G35`** (if the dancer mode turns out to be a **pass-schedule parameter** rather than machine-side, the full design goes 28 → 29 and a component row plus a DDL column follow — `OQ-32` decides) · **`OI-22`** (`AlloyProperty`'s rod-diameter and ovality min/max pairs are **deliberately seeded NULL** pending values owed by e-mail — do not invent them) · **`OQ-10`** (`AlloyProperty.LbPerFtFactor` is seeded **NULL, "OQ-10 PENDING"** — the dimensional basis for footage→weight is undecided and is the most widely depended-on number in the build) · **`G38`** (**new 15 Aug 2026 — the spool-completion prompt has no persistence target**; this phase owes 1B the five `FlatWireRun` prompt columns above, and `phase-01b` acceptance criterion 4 is blocked until they land).

**Stories:** `FW-001` 56 *(shared-schema renames + the **40 h impact audit** across `united_db` and the legacy tier — the highest-blast-radius change in the plan)* · `FW-002` 4 (`INFLAT`) · `FW-004` 12 (alloy lookup) · `FW-005` 16 (Lookup group + seed) · `FW-006` 12 (Materials group) · `FW-007` **52** (Runs and Quality/Output groups, incl. `RunReading`, **plus `G21`'s `RodStaging.Station` column and re-keyed index**) · `FW-152` 8 — **DB 160** → QA 32 → cont. 29 → **221 h** ✓ (`[CE §3b]`), subject to the ~17 h understatement recorded in the header. ⚠ **`FW-006` also creates the MVP-2-owned `PassSchedule*` tables** and is therefore a both-scopes story absent from every scope table — build only the MVP-1 side here; `02_Schedule` stays out of the runner.
