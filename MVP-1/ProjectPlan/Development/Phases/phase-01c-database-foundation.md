# PHASE 1C — Database Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../Roadmap.md).** One of the three layer specs that replace the combined Phase 1 doc.
> **Siblings:** [1A — Angular Foundation](./phase-01a-angular-foundation.md) · [1B — Backend Foundation](./phase-01b-backend-foundation.md)
> **Reference context (do not restate):** [`[ARC §13.1]`](../../Architecture/Architecture.md) `D-02` (new `FlatWireDB`). **The dissolved foundations doc's decision 3 — "rod = existing `coils`, `Rod` dropped" — is SUPERSEDED by master-spec `D-04`: `Rod` is retained.** See *Target database & table set*. Also [`[DBD §6.2]`](../../Database/DatabaseDesign.md) — the **counted** object baseline. Source DDL: [`Database/Schema/SQL/`](../../Database/Schema/SQL/) (`FlatWire_DDL_01`, `03`–`08`, the four `FlatWire_SampleData_*.sql` seeds; the ER documentation was absorbed into `[DBD]` §6–§7 on 13 Aug 2026 and deleted). **`FlatWire_DDL_02_Schedule.sql` and `FlatWire_SampleData_Schedule.sql` joined this set on 15 Aug 2026 (`D-31`), as did the files then called `06b` and `07b` — which were folded into `06` and `07` on 23 Aug 2026 and no longer exist** — only `09_Programmability_MVP2` (`sp_ShiftSummary`, for the deferred DB10) stays MVP-2.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-23 — **the acceptance criteria and post-run checks were the 11 Aug version and would have failed a correct deployment**: they asserted 25 tables / 33 FKs and stated that the three `PassSchedule*` tables are not built here, contradicting five other lines in this file. Both now defer to `[DEP §4.2]`'s gate and `[DBD §6.2]`'s baseline. `06b`/`07b` folded into `06`/`07`; `08b` is now `09_Programmability_MVP2` *(previously 2026-08-18 — **`D-32`: there is no shared-schema migration.** `FW-001`/`FW-002` cancelled and the existing-schema migration removed as a deliverable of this layer; **221 → 138 h** (DB 100 · QA 20 · cont. 18). This layer now touches `FlatWireDB` and nothing else. *(Previously 2026-08-15 — **`D-31`: the three `PassSchedule*` tables, their seed, `06b` and `07b` moved INTO MVP-1**, so the runner builds **34 tables · 57 FKs · 69 indexes · 1 procedure · 1 trigger** (live-deploy verified, 22 Aug 2026) and `PassScheduleId` is an **enforced FK**. Also **`G38` schema delta landed**: five `FlatWireRun` prompt columns this phase owes 1B, without which `FR-144`'s durable spool-completion prompt has nowhere to live and `phase-01b` acceptance criterion 4 cannot be met *(otherwise 2026-08-14 — reconciled to the 13 Aug ProjectPlan restructure; table counts corrected to the `[DBD §6.2]` baseline; blockers and stories trailers added. **No effort figure in this file changed** — but see the understatement note below)*)*)*
**Status:** **Ready to build — but the 14 Aug gate was not met**
**Layer:** SQL Server (`ual-database`)
**Owner:** **DB** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Scope call:** **Wholly MVP-1** — and since `D-31` (15 Aug 2026) that includes the three `PassSchedule*` tables, their seed, their 10 FKs and their 6 indexes. **`PassScheduleId` is a real, enforced FK**, not an external reference. Only `sp_ShiftSummary` is MVP-2's. ⚠ **MVP-1 builds and reads these tables; it never authors a schedule** — DB9/DB9A stay MVP-2 (`OI-110`).
**Effort:** **138 h** (17.3 d) — DB 100 · QA 20 · cont. 18 · **Window:** W0 (to Aug 14, 12 working days = 96 h/person) — ⚠ **re-derived 18 Aug 2026 by `D-32`** *(previously **221 h** — DB 160 · QA 32 · cont. 29, including a discrete **40 h FW-001 impact audit** across `united_db` + the legacy tier, see `[CE §2]`)*. `FW-001` (56 h) and `FW-002` (4 h) are **cancelled**: there is no shared-schema migration, so QA and contingency are re-derived from the reduced base. ⚠ **`[CE §3b]` still publishes 221 h and is deliberately not re-derived** — `[TB]`'s Phase 1C reconciliation is the derivation of record for this figure

> ⚠ **The published 221 h is known to be understated, and this file does not correct it.** *(215 h until 15 Aug 2026, when `FW-007` gained 4 h for `G21`'s `Station` column and re-keyed index — a separate matter from the understatement below; do not net them.)* `[CE §8]`: *"**1C is costed against 22 tables, and the build is larger — the gap is wider than this line has ever said.** The table count is `[DBD §6.2]` … Each table beyond the 22 is **4 h** plus its share of QA and contingency."* ⚠ **`[CE]`'s hour figure was deliberately not restated when its table count was corrected on 23 Aug 2026** — substituting a count into an effort derivation without re-deriving makes the arithmetic lie — so the *"roughly 17 h"* this line used to quote is withdrawn and no replacement is published here. `[TRP §1.4]` carries the same finding on its own basis (*"65 h + ~11 h of known understatement"*). **`[CE]` owns the figure** — it is stated here so the two documents stop disagreeing by omission, not re-priced here.

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate) — **not met**
> Phase 1 was to be complete by **14 Aug 2026** (user mandate; superseded the roadmap's W1 = Aug 17–23). The DDL already exists in `Database/Schema/SQL/`; this layer's job is to **retarget, harden, seed, and wire** it so 1B's `FlatWireDbContext` maps cleanly and 1A's fixtures are backed by real rows. ~~**FW-001 column renames touch the existing shared scheduling schema — high blast radius; front-load the impact audit.**~~ **Struck 18 Aug 2026, `D-32`: this layer touches `FlatWireDB` and nothing else.**
> **`[RM]` records that 30 Sep is now a trial-run date, not an MVP-1 feature-complete date.** `[TRP]` requires 1C to finish inside T1 — it gates every write — and had deferred `FW-001`'s renames and their 40 h audit out of trial scope entirely. ⚠ **As of `D-32` (18 Aug 2026) they are not deferred but cancelled**, so the trial's −36 h reduction is no longer a debt carried into production.

## Objective
Create and populate a new **`FlatWireDB`**, execute the numbered DDL in order, apply the Phase-1
hardening (indexes, missing constraints, the new `RunReading` table), author the lookup seed the
author the lookup seed the sample data depends on — leaving a schema that `FlatWireDbContext` binds to
and reports can query. ⚠ **No longer in this layer: the FW-001/FW-002 existing-schema migrations**, cancelled
18 Aug 2026 by `D-32`. This layer now touches **`FlatWireDB` and nothing else**.

## Dependencies
- **Template/source:** the DDL scripts (`00`–`08`, a contiguous chain — `06b` and `07b` were folded into `06` and `07` on 23 Aug 2026) + **five** `FlatWire_SampleData_*.sql` seeds, in `MVP-1/ProjectPlan/Database/Schema/SQL/`. The as-built description is `[DBD]` §6–§7, which absorbed the deleted ER documentation on 13 Aug 2026.
- **Converges with:** 1B (`FlatWireDbContext` + repositories) and 1A (fixture alphas). No blocker.
- **Backlog:** see the **Stories** trailer at the foot of this file.

> **Schema changes from the 30 Jul 2026 client call — already applied to the DDL.** `RodStaging` **drops** `OffScheduleOverride`, `ScheduledLineId`, `CK_RodStaging_OffSched` and `CK_RodStaging_OffSchedLine` (the station auto-switches instead — OQ-24) and **gains** `UnstageKind` + `WipRejectionId` with an FK into `WipRejection`, so a WIP rejection can release a blocked bay (OQ-23). `AlloyProperty`'s two single-± tolerance columns become **four min/max pairs** — gauge, width, rod diameter, ovality — with **diameter and ovality NULL because the values are owed by e-mail** (OQ-22); do not seed them. `RodCheckout` gains `WasWelded` and the `ApprovedBy`/`ApprovedAt`/`OverrideReason` stamp it never had (**G24**), which **retro-enforces the OQ-74 Mode B approval**. Verified: teardown → `RunAll` clean and idempotent, **all 33 tables built by the MVP-1 runner** (`D-31`), 15 constraint tests pass on SQL Server 2019. ~~**FW-002 is narrowed** — `INFLAT` is set at check-in only, so the pre-check-in path must not write it.~~ ⚠ **Superseded 18 Aug 2026 — `D-32`: `FW-002` is cancelled, not narrowed.** `INFLAT` never enters the shared coil-status vocabulary; the check-in-only timing rule now applies to **`Rod.Status`**, whose CHECK constraint in `03_Materials` already carries the value and **did not change in this pass**.

## Target database & table set

- **New `FlatWireDB`** (decision 2). Any DDL still headering `USE [united_db]` must be retargeted.
- **`Rod` is RETAINED** — master-spec **`D-04`** (the "Hybrid foundation" decision, 29 Jul 2026) **supersedes the dissolved foundations doc's decision 3**, which had it dropped — the reversal is recorded at [`[ARC §13.1]`](../../Architecture/Architecture.md). `Rod` is a `FlatWireDB`-local master mirroring the shared `coils` record, with **enforced** rod-alpha FKs. `coils` remains the source of truth for the rod *lifecycle* (receipt, status incl. `INFLAT`, chemistry/heat, lot); the local mirror is what lets the FKs be enforced. **This resolves `G12`** — anything still saying "`Rod` dropped / 21–22 tables" predates `D-04`.
- **Table count: the full set in `[DBD §6.2]`, which is the defining site and the only place that states it** — MVP-1 and the full design are the same set since `D-31` (15 Aug 2026) moved the three `PassSchedule*` tables into MVP-1. ⚠ **Every earlier count is superseded**, including this line's own former "28".
- **Verified by a clean teardown-and-rebuild on 15 Aug 2026:** **34 tables · 57 FKs · 69 index statements · 1 procedure** (`sp_GetGaugeTrace`) **· 1 trigger** (`trg_CoilTraceability_NoOverlap`), idempotent on re-run. `sp_ShiftSummary` is **MVP-2's** and is correctly **absent**.

*The table set below is the whole of MVP-1 — `[DBD §6.2]` is the counted baseline and this table deliberately gives no totals. The seven bold entries were built between 20 and 22 Aug 2026 and were missing from this table until 23 Aug.*

| Group | Tables (MVP-1) |
|---|---|
| **Lookup** (`01`) | `Stand`, `Drawer`, `Edger`, **`Dancer`**, **`Spool`**, `AlloyProperty`, `PayoffPosition`, **`Spool`** |
| **Schedule** (`02`) | `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` — **MVP-1 since `D-31`**; built by the runner, **read** by MVP-1 and authored by nobody in it |
| **Materials** (`03`) | **`Rod`** (retained per `D-04`), `FlatWireRun` (hub — created here so `SpoolProcessing.SourceRunId` can reference it), `SpoolProcessing`, **`SpoolTraceability`**, **`SpoolOrder`**, **`RodOrderAllocation`** |
| **Runs** (`04`) | `FlatWireRunDetail`, `RodCheckin`, `RodStaging`, `SpoolCheckin`, **`SpoolStaging`**, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`**, **`RodOrderConsumption`** |
| **Quality/Output** (`05`) | `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout` |
| **FKs** (`06`) | **all** FK constraints added after the tables, in one script — including the four now-enforced `PassScheduleId` links. `06b` was folded into `06` on 23 Aug 2026; there is no second FK script. Count: `[DBD §6.2]` |

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Database structure** | Create `FlatWireDB`; retarget `USE` statements; execute in **contiguous numeric order** `00_Database → 01_Lookup → 02_Schedule → 03_Materials → 04_Runs → 05_QualityOutput → 06_ForeignKeys → 07_Indexes → 08_Programmability`, which is exactly what `FlatWire_DDL_RunAll.sql` does. `09_Programmability_MVP2` (`sp_ShiftSummary`) is **not** in this chain |
| **Index strategy** | Add the ER-doc **recommended nonclustered indexes** (none exist today beyond PK-clustered + UNIQUE): `FlatWireRun(LineId)`, `FlatWireRun(Status)`, `FlatWireRun(PassScheduleId)`, plus **`(RunId)` on every child/event table** (`FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `RunReading`, `SpcCheckpoint`, `WipRejection`, `CoilOutput`, `RodCheckout`), `RodCheckin(RodAlpha)`, `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`, `CoilTraceability(CoilAlpha)`, `CoilTraceability(RodAlpha)`, `SpcMeasurement(CheckpointId)`, `CoilOutput(CoilAlpha)` |
| **Lookup + alloy seed** | Author `FlatWire_SampleData_Lookup.sql` (**currently missing** — the schedule seed depends on it): seed `Stand` (FM1 12″, FM2_S1 8″, FM2_S2 6″, FM2_S3 6″ — four rows, each with `RollDiameterIn`), `Drawer` (DIE-0210…DIE-0340), `Edger` (round/square), `Spool`, and the **Alloy properties lookup** (FW-004: `Alloy, MaxReductionPerPass, SpringbackFactor, GaugeToleranceDefault, WidthToleranceDefault, SpeedRangeMinFPM, SpeedRangeMaxFPM`) seeded 1100/1350/3003/5052/6061 — with **fixed IDENTITY values** matching the `Stand.Id 1–4 / Drawer.Id 1–13 / Edger.Id 1–2` the schedule seed references |
| **Schedule seed** | `FlatWire_SampleData_Schedule.sql` — 10 `PassSchedule` + 70 `PassScheduleComponent` rows spanning all lines/routes/alloys/statuses (fixtures `R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043` for 1A/1B mocks). **Fix the header coverage comment** (says Standalone 3 / Hybrid 7; actual **4 / 6**) |
| ~~**Existing-schema migration (FW-001/002)**~~ **— CANCELLED, `D-32`, 18 Aug 2026. Not a deliverable of this layer or any other.** Retained as the record of what was cancelled | ~~Slash-dual-name renames on the existing scheduling/`coils` schema: `CoilNo→Coil/BundleNo`, `SlitWidth→Slit/FlatWidth`, `IsCampaingCoil→IsCampaignCoil/Bundle`, `CoilLocation→Coil/BundleLocation`, `CoilWeight→Coil/BundleWeight`, `CoilStatus→Coil/BundleStatus`, `OutgoingCoilId→OutgoingCoil/BundleId`, `OutgoingCoilOd→OutgoingCoil/BundleOd`; new columns `OutgoingCoil/BundleWidth`, `IncomingWireDia`; new coil status **`INFLAT`** (FW-002). **Precede with a full SP/view/report impact audit** (high blast radius)~~ |
| **Data-access wiring** | Map `FlatWireDbContext` (1B) to **every table in `[DBD §6.2]`**; keep legacy `FlatLineSetup`/`FlatLineProcessing` for the migration window, then drop after data moves to `FlatWireRunDetail` — ⚠ **and to `PassScheduleComponent`, which is MVP-2's**, so the legacy drop cannot complete inside MVP-1 alone (`G8` has no migration deliverable) |
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
- All **nine** DDL scripts (`00`–`08`) + all **five** seeds run **clean and idempotent** on a fresh dev `FlatWireDB` (re-runnable). The seeds are a separate runner, `FlatWire_SampleData_RunAll.sql`, and are **DEV/TRIAL only**.
- Post-run checks: run **`[DEP §4.2]`'s `V1`–`V6` verbatim** — this phase does **not** maintain a second copy of their expected values, because keeping two copies in step is what let them drift into rejecting a correct deployment twice. The baseline they assert is defined in `[DBD §6.2]`. Then, beyond the gate: every FK in `06` resolves; every index in `07` exists; `PassSchedule` has exactly one `Active` row per `LineId+Alloy`; `CoilTraceability` ranges are non-overlapping per coil.
- ⚠ **`sp_ShiftSummary` must be ABSENT.** It is MVP-2's (`09_Programmability_MVP2`), and *requiring* it is what failed a correct deployment before. `V4` expects **2** programmability objects after `RunAll`, and **3** only once `Database/Scripts/` has been applied — the third being `sp_IngestRodFromCoils`, which is a `FlatWireDB` object that ships outside the runner.
- `FlatWireDbContext` (1B) reads/writes each table; a smoke insert→select round-trips through EF.
- Seed integrity: schedule seed FK-resolves against the lookup seed IDENTITY values.

## Acceptance criteria (exit)
1. `FlatWireDB` created; DDL 01–06 + lookup seed + schedule seed execute clean, in order, idempotently.
2. **The full table set of `[DBD §6.2]` exists** — including `RunReading` **and `Rod`** (`D-04` retains it, superseding the "drop `Rod`" position in [Foundations](../../Architecture/Architecture.md) decision 3) **and the three `PassSchedule*` tables**, which `D-31` (15 Aug 2026) moved into MVP-1. All FKs and all indexes present. ⚠ **This criterion previously said the `PassSchedule*` tables were "not built here — the pass schedule is owned outside MVP-1". That is retired and was contradicted by five other lines in this same file.** What has *not* changed: MVP-1 **builds** those tables and never **authors** a schedule — no create, edit, approve or list, no endpoint, and nothing in MVP-1 populates them in production (`OI-110`). Verified by `[DEP §4.2]`, not by a count maintained here.
3. `RodCheckout.NewRodStatus` and every status column carry an enumerating `CHECK`; the doc-stated business constraints are enforced (see Review-fixes).
4. ~~FW-001 renames + FW-002 `INFLAT` applied on the existing schema behind a completed impact audit.~~ — **struck 18 Aug 2026, `D-32`.** The existing schema is left exactly as it is. ⚠ **`INFLAT` is still required, locally**: `Rod.Status`, `SpoolProcessing.Status` and `RodCheckout.NewRodStatus` carry it in their CHECK constraints (criterion 3), and after `D-32` those are the **only** places it exists.
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
- ⚠ **`PassScheduleId` LEFT that list on 15 Aug 2026 (`D-31`) — it is now a real, enforced FK.** `FK_FlatWireRun_PassSchedule`, `FK_RodCheckin_PassSchedule`, `FK_SpoolCheckin_PassSchedule` and `FK_CoilOutput_PassSchedule` are created by `06`'s schedule section — the file formerly called `06b`, folded in on 23 Aug 2026 — which the MVP-1 runner includes; all four verified **enforced and trusted** on a live deploy, with **zero orphans**.
  - **The seeded values are now real parents, not external identifiers.** `PS-1100-FL1-001` and friends resolve to rows in `PassSchedule`, seeded by `FlatWire_SampleData_Schedule.sql` immediately before the Materials seed.
  - **The `NOT NULL` question is closed.** `PassScheduleId` being `NOT NULL` on `FlatWireRun`, `RodCheckin` and `SpoolCheckin` no longer asserts an existence MVP-1 cannot verify — it can, and the FK does. **Do not `NULL` it.**
  - ⚠ **This does not make MVP-1 an author.** It reads schedules; DB9/DB9A stay MVP-2 and no endpoint writes one. **Nothing in MVP-1 populates the table in production** — `OI-110`.

---

**OQ blockers:** ~~**`G21`**~~ **✅ RESOLVED 15 Aug 2026 — one physical station.** `RodStaging` gained a persisted **`[Station] VARCHAR(10) NOT NULL`** and `UX_RodStaging_Bay` was re-keyed to `([Station],[PayoffPosition]) WHERE [Status]='Staged'`. Verified against a live deploy: an FL3 rod staged at `FL1PO` position 1 is now rejected — *"duplicate key value is (FL1PO, 1)"* — where the old `(LineId,PayoffPosition)` key allowed it. The `RodStaging` **aggregate** enforces the same rule in code (`D-29`), so the index is belt-and-braces. **The DB2A toggle half is `FW-209`.** *(Original text: **`UX_RodStaging_Bay` did not enforce one-rod-per-bay across FL1/FL3** — `CK_RodStaging_LineId` admits both, so `(FL1,1)` and `(FL3,1)` are distinct entries while everything in the design assumes one physical VPS. **Blocks the Phase-4 schema freeze**; the reading on record is to key uniqueness on the *station*) · **`G3`** (register still reads Open while `RunReading` is built here under `FW-007` — reconcile the register, not the schema) · **`G17`** (rod→`coils` cross-DB logical FKs; `Rod` is a local mirror precisely so the alpha FKs can be **enforced**) · **`OI-33`** (**`planning_routings` columns unmapped** — 1B's `RodRepository` and the `Available` queue projection are built against them) · **`G14`** (footage `DECIMAL` vs `INT`, and the non-canonical `ROD-`/`SPL-` alphas in older worked examples) · **`G35`** (if the dancer mode turns out to be a **pass-schedule parameter** rather than machine-side, the full design goes 28 → 29 and a component row plus a DDL column follow — `OQ-32` decides) · **`OI-22`** (`AlloyProperty`'s rod-diameter and ovality min/max pairs are **deliberately seeded NULL** pending values owed by e-mail — do not invent them) · **`OQ-10`** (`AlloyProperty.LbPerFtFactor` is seeded **NULL, "OQ-10 PENDING"** — the dimensional basis for footage→weight is undecided and is the most widely depended-on number in the build) · **`G38`** (**new 15 Aug 2026 — the spool-completion prompt has no persistence target**; this phase owes 1B the five `FlatWireRun` prompt columns above, and `phase-01b` acceptance criterion 4 is blocked until they land).

**Stories:** ~~`FW-001` 56~~ and ~~`FW-002` 4~~ — **both cancelled 18 Aug 2026, `D-32`; −60 h base** · `FW-004` 12 (alloy lookup) · `FW-005` 16 (Lookup group + seed) · `FW-006` 12 (Materials group) · `FW-007` **52** (Runs and Quality/Output groups, incl. `RunReading`, **plus `G21`'s `RodStaging.Station` column and re-keyed index**) · `FW-152` 8 — **DB 100** → QA 20 → cont. 18 → **138 h** *(re-derived 18 Aug 2026 by `D-32`; `[CE §3b]` still publishes **221 h** from the old **DB 160** → QA 32 → cont. 29 and is deliberately not re-derived)*, subject to the ~17 h understatement recorded in the header. ⚠ **`FW-006`'s `PassSchedule*` tables are MVP-1 as of `D-31`** (15 Aug 2026) — `02_Schedule` is in the runner and the schedule FKs and indexes are in `06` and `07`, so the "both-scopes story" caveat that stood here is retired; only `sp_ShiftSummary` (`09_Programmability_MVP2`) remains MVP-2.

---

## Rod ↔ order tables — the count moves to 34

**Added 22 Aug 2026.** Two tables join the schema: **`RodOrderAllocation`** (`03_Materials`) and
**`RodOrderConsumption`** (`04_Runs`), with 7 FKs in `06` and 12 index statements in `07`. Plus
`SpoolTraceability.ChildAlpha` and `SpoolOrder.SpoolWeightFrom`/`To`.

**Verified on the shared instance, 22 Aug 2026:** **34 tables · 57 FKs · 69 index statements · 1 procedure
· 1 trigger** — clean deploy plus an idempotent re-run, with the file-level statement count and
`sys.indexes` agreeing independently at 69.

**Two constraints in this set carry business meaning and should not be "simplified":**

- **`UX_RodOrderConsumption_Station`** — keyed on **`Station`**, not `LineId`, because FL1 and FL3 share one
  physical VPS. This is the same correction `G21` forced on `RodStaging`. Its predicate must stay a literal
  `IN` list: SQL Server forbids a computed column in a filtered-index predicate.
- **`CK_RodOrderAllocation_WeightRange`** — asserts `To − From = AllocatedWeightLb`. Holding the split in
  **pounds** rather than footage is what makes this expressible as a single-row check at all.

**Three invariants are deliberately *not* in the schema** because they are cross-row and SQL Server has no
exclusion constraint: a rod's ranges tile the rod, a `PinnedBoth` row is its order's only row, and an order
with an allocation has ≥ 1 rod. A trigger is viable for the first — both weight columns are `NOT NULL` —
with `trg_CoilTraceability_NoOverlap` as precedent.
