# Flat Wire Mill — Development Plan Review

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-13 — **#33, #51 and #57 re-closed** against the rewritten sprint-wise backlog (#51 now **moot** — no epics or points remain to be wrong about) and the `FlatWireJiraStories.md` worklist row retired. *(Earlier same day: the Appendix worklist executed; findings updated, three worklist rows struck as wrong, six new findings added.)*
**Status:** Review — findings & recommendations. **The 13 Aug reconcile-up did edit source documents** (the April four, the two check-in docs, the workspace file and two `ShopfloorPlan/` headers)

**Scope reviewed:** `MVP-1/DevelopmentPlan/` — `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`, `ShopfloorAndRealTimePlan.md`, `ShopfloorPlan/*`, ~~`CheckinImplementationPlan.md`~~, ~~`CheckinImplementationPrompt.md`~~ *(both **deleted 13 Aug 2026** — recoverable at `1964086`; see the Tier 5 banner)*; plus the schema design and DDL, since moved to `MVP-1/DBChanges/Schema/*` + `Schema/SQL/*`.

> ## ⚠ This document deliberately keeps the old file names
>
> **The folder it reviews no longer exists.** On 13 Aug 2026 `MVP-1/DevelopmentPlan/` was consolidated into
> `MVP-1/ProjectPlan/`, and the four April documents were **absorbed into the documents that own their subjects
> and deleted**:
>
> | Reviewed here as | Now resolves to |
> |---|---|
> | `APIContracts.md` | `04-APIContract.md` (its §2.3 records the four corrections) |
> | `FlatWireJiraStories.md` | `05-SprintPlanAndBacklog.md` §4, §6, §7, §8 |
> | `FlatWireTables.md` | `../DBChanges/Schema/FlatWireSchema_Mapping.md`, appendix |
> | `TechStackRecommendation.md` | `03-HLD-and-ERDiagram.md` §14 |
> | `ShopfloorAndRealTimePlan.md`, `ShopfloorPlan/*` | unchanged, now under `ProjectPlan/` |
>
> **The names below were not rewritten, and that is deliberate.** Every finding is a statement *about a document as
> it stood when the finding was made*. Substituting the new names would make this document assert that
> `04-APIContract.md` carries the defects its own §2.3 corrects — which is the opposite of true. Read the table
> above, not the names, when following a finding to its current home. Same convention as `CHANGELOG.md`.

> ## ⚠ Read this before using the Appendix worklist — it has been executed, and three of its rows were wrong
>
> **The reconcile-up ran on 13 Aug 2026.** All four April documents are now scope-marked, re-baselined to the 14-phase model and the 17 Aug – 30 Sep window, and carry banners naming what supersedes them. **Three worklist instructions were found to be wrong on the way and were struck rather than executed** — each would have introduced an error:
>
> | Row | Why it was not executed |
> |---|---|
> | `FlatWireTables.md` — *"drop the dedicated `Rod` table (rod = `coils`)"* | **Superseded by `D-04`.** `Rod` is retained as a `FlatWireDB`-local master; the mirror is what lets rod-alpha FKs be enforced. **`G12` closed 11 Aug 2026** with the finding that the DDL was right and the plan documents were stale |
> | `APIContracts.md` — *"Fix the `/passschedule/generate` example (Tier 1.1)"* | **Out of MVP-1 scope**, as this document's own banner already says. Correcting the example would harden arithmetic that `PassScheduleGenerationSpec.md` v1.5 has since superseded on the physics |
> | `FlatWireJiraStories.md` — table count *"20 → 22"* | **Stale.** The verified baseline is **25 MVP-1 / 28 full** (clean rebuild, 11 Aug 2026) |
>
> **A fourth worklist figure was also wrong: #51's "E07 = 67, total 226".** Recounted from the story rows on 13 Aug: **E07 is 15 stories / 72 points** and the grand total is **59 / 231**. #51 was correct when written and was overtaken by `FW-124` — see new finding **#57**.

> **⚠ This review predates the 11 Aug 2026 MVP-1/MVP-2 split and does not cover it.** Every finding below was written against a single undivided scope. Three scope decisions have since been taken, and each changes how a finding should be read — **none of them is recorded in the tiers below, by design**:
>
> 1. **Pass schedule generation and management are owned outside MVP-1.** Phase 2, `FW-010`–`FW-013`, DB9/DB9A, the three `PassSchedule*` tables and the generation engine are all out. `PassScheduleId` is a **documented external reference**, in the same class as `PlanId` and `SkidId`.
> 2. **Die inventory and lifecycle are out of MVP-1; the mid-run die change event stays.** `D4` is restated at **die-size** level against the `Drawer` catalogue — see `DieChangeAndManagement.md` v2.4.
> 3. **Phase 9 is wholly MVP-1** — DB7, DB7b, both coil endpoints and `CoilCompletionService` returned, closing the *"splitting it is a design decision nobody has taken"* seam.
>
> **Where the tiers are now wrong, they are marked inline.** In particular: **Tier 1 #1** (the `/passschedule/generate` worked example) and the §10.5 callout above it are **out of MVP-1 scope**, not open bugs; **Tier 2 #13** (lot / skid undefined) is now an **MVP-1 blocker** rather than a low-priority gap, because DB7b is in scope and needs both — registered as gap **`G36`** with `OI-104`/`OI-105`/`OI-106` alongside the escalated `OI-24`.

> **Blind spot this review shared with every other doc (added 2026-07-29).** The scope above is markdown- and SQL-only. **`.docx` files are zip containers, so `grep` never reaches inside them** — which is how `SRS §4.2 PCI001`–`PCI008` (pre-check-in), `WLD010`, `TRV004`/`TRV009` and §4.18 `PRC001`–`PRC019` went unnoticed across the whole `MVP-1/DevelopmentPlan/`. A specified, testable feature had no analysis note, mockup, table, endpoint or phase owner, and `CommonDB_Insert_WIPStations_FlatWire.sql` D2 explicitly declined to create its station. Recorded as **G19**. **Any future audit of this repo must extract the SRS `.docx` and read §4 requirement-by-requirement, not grep for it.**

---

## Executive summary

The DevelopmentPlan is thorough and largely self-aware — its own [`ShopfloorPlan/back-matter.md`](./ShopfloorPlan/back-matter.md) **Gaps register (G1–G36)** already tracks many of the issues below as "Open." The dominant problem is **doc split-brain**:

> Four docs dated **Apr 29–30 2026** (`APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`) were **never reconciled** with the **July 26 2026 rewrite** (`ShopfloorAndRealTimePlan.md` + the `ShopfloorPlan/*` phase files). The April docs still present the dead "May–June 2026 / Trial Jul 1 / Prod Aug 1" timeline and a 5-sprint model; the roadmap re-baselined to **Aug 17 – Sep 30 (~6.5 wk)**, 14 phases, production Q4 2026. **Most contradictions in this review descend from that un-propagated split.**

**Timeline note (authoritative):** **Phase 1 must be complete by 14 Aug 2026** (current directive). ~~This is *earlier* than the roadmap's own W1 (Aug 17–23 in [`back-matter.md`](./ShopfloorPlan/back-matter.md)), so the roadmap calendar, milestone M1 (Aug 23) and QA1 need re-baselining against the Aug-14 gate.~~ **Re-baselined Jul 30 2026** — the grid now opens with **W0 = to Aug 14**, M1 moved to Aug 14, QA0 added (#31). Phase-1 work has to be underway well before the gate — the [Capacity & Effort Model](./CapacityAndEffortModel.md) finds Phase 1 needs **1,027 h — 10.7 FTE across the 12 working days to Aug 14**, so the gate is at risk on headcount, not on sequencing. **Phase 1 is unaffected by the MVP split**: none of its three layer specs carries deferred work, so the 1,027 h figure means MVP-1 as it stands. *(Phase 1 has been split into three execution-ready layer specs — [1A Angular](./ShopfloorPlan/phase-01a-angular-foundation.md) · [1B Backend](./ShopfloorPlan/phase-01b-backend-foundation.md) · [1C Database](./ShopfloorPlan/phase-01c-database-foundation.md) — that carry the Aug-14 gate and bake in the Phase-1-relevant fixes below.)*

**Remediation posture (recommended):** treat the July 26 roadmap as the source of truth and **reconcile the four April docs *up to* it** (see the Appendix worklist), rather than maintaining two timelines.

### Top 5 to fix first

> **Re-derived 13 Aug 2026.** The original Top 5 is struck below with what actually happened to each. **The genuine top item is now #2's residual — the capacity escalation — because it is the only one that cannot be closed by editing a document.**
>
> | Now | Item | State |
> |---|---|---|
> | **1** | **`G1` — 3,292 MVP-1 hours against 32 post-gate working days** (9.4 FTE sustained, 24.5 in W7) | **Open, and not a doc fix.** Needs the §7 programme decision: staff up, move the date, or cut below the critical path |
> | **2** | **`G21` — the `RodStaging` bay-uniqueness scope**, which **blocks the Phase-4 schema freeze** | Open |
> | **3** | **The check-in insert cannot succeed as specified** — `RodCheckin` requires four NOT NULL fields the contract never sends (Tier 1 #5, `G14`) | Open; verified against the as-built DDL 13 Aug |
> | **4** | **`G36`** — Phase 9 returned to MVP-1 with three uncosted dependencies (skid table, lot number, third weight point) | Open |
> | **5** | **`G25`** — 41 requirements still need a test case authored | Open; the guard is in place and the number is honest |
>
> The five below are retained as the record of what the 11 Aug review judged most urgent.

1. ~~**`/passschedule/generate` is internally wrong** (Tier 1) — the worked example contradicts its own algorithm; an implementer cannot trust it.~~ **VOID — out of MVP-1 scope.** Not fixed, deliberately; see the banner above.
2. **Reconcile the three timeline/sprint models and re-baseline to the Aug-14 Phase-1 gate** (Tier 4 / G1) — the plan has no single calendar. *(Calendar re-baselined and the capacity model published Jul 30 2026 — see [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) and #31/#53. The sprint→phase crosswalk (#33) is still open, but `FlatWireJiraStories.md` is now explicitly superseded **as a schedule**; its points survive only as a cross-check. **New top-priority consequence:** the model finds **MVP-1 is 3,292 hours against 44 working days** (352 h/person) → **9.4 FTE sustained and 24.5 in W7** — the 30 Sep date needs a programme decision, not a doc fix. *(Apportioned 11 Aug 2026, model §3b; the same pass corrected a stale TOTAL row that had read 3,727 where the phase rows sum to 3,660.)*)*
3. **Persist AGC readings** (Tier 2 / **G3**) — add a `RunReading` table; FL2 profile + Gauge-Trace/Cut-Traceability reports currently have no data source. *(Done in [1C](./ShopfloorPlan/phase-01c-database-foundation.md).)*
4. **Add FK/`RunId` indexes and correct the doc↔DDL precision drift** (Tier 3) — hub-join performance + a regeneration hazard. *(Indexes/precision addressed in [1C](./ShopfloorPlan/phase-01c-database-foundation.md).)*
5. **Fix the check-in implementation docs** (Tier 5) — they steer developers to the wrong tokens, the retired UI, and a forbidden reference library.

**Legend:** `file:line` references point into `MVP-1/DevelopmentPlan/`. **[Gxx]** = matching item already in the Gaps register. **[P1✓]** = addressed in the Phase-1 layer specs.

---

## Tier 1 — Correctness bugs (executable-spec is wrong; fix before code)

> **Three PLC-surface arbitrations, added 4 Aug 2026 when the tag surface was consolidated into [`MVP-1/RequirementDocuments/PLCTagSpecification.md`](../RequirementDocuments/PLCTagSpecification.md) (`[PLC]`).** Each names a winner, so no one has to re-derive it:
>
> **(a) `scheduleId`, not `passScheduleId`.** `PushPassSchedule`’s first parameter is `scheduleId` in all four ProjectPlan documents and `passScheduleId` in `APIContracts.md:1177` and `phase-04:62`. **`scheduleId` wins** — `APIContracts.md` is already superseded, and the convention is to reconcile the April docs *up to* the roadmap. `phase-04:62` needs the one-line correction.
>
> **(b) `02-SRS.md` contradicts itself on the tag push, twice.** Its interface section said *speed **targets*** while `FR-073` says *speed **limits***; and `FR-073`/`FR-074` still describe the batch as *"a single transactional batch"* that *"shall be rolled back"*, which four other sources correctly call a **compensating re-clear** (gap **G16**). **`[PLC §7.5]` wins on the rollback wording** — that is now a text fix owed in `FR-073`/`FR-074`, and G16 closes on it. **The speed question has no winner yet**: a setpoint and a safety clamp are different tags, so it is asked as **`PLC-Q06`** and `FR-073`’s wording is deliberately left alone until it closes.
>
> **(c) Three things were called `LineState`.** The machine tag, a six-member application enum with **no `Stopped`**, and a hub event named `LineStatus` — while `FR-141` fires the spool prompt on a *running → stopped* transition. **`[PLC §6]` wins:** the machine tag keeps the name, the enum becomes `LineOperatingState`, the event becomes `LineStateChanged`, and the machine-value→state mapping is published as **configuration** so the commissioning answer (**`PLC-Q01`**) needs no code change. **Do not add a seventh enum member.**

> **The generate-from-specs *algorithm* is superseded, not only its example (added 6 Aug 2026).** Finding
> #1 below is about `APIContracts.md`'s worked example disagreeing with `FR-381`. A gap audit of
> [`PassScheduleGenerationSpec.md`](../../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md)
> (v1.5) found the deeper problem: **`FR-381`, `FR-384`, `FR-385`, `FR-386` and `FR-387` are themselves
> wrong on the physics**, so correcting the example to match them would harden the error rather than fix
> it. The arbitration is published as **`FlatWire_MasterSpecification.md` §10.5**; in one line each —
>
> - **`FR-381`** uses the **zero-elongation lower bound as the answer** (produces **under-width** wire) and
>   omits the **round-edge area correction** (0.0057″ on the published case, larger than a die increment).
> - **`FR-384`** snaps dies to *nearest*, violating `R36`/`V39` — the final die may not go **below** a
>   bounded entry — and since `FR-381` always produces one, it violates it on **every** schedule.
> - **`FR-385`/`FR-387`** set the gap **above** gauge by a fixed alloy multiplier where `h₁ = S₀ + F/K`
>   makes the compensation **negative** and **load-dependent**, and they conflate *springback* (material)
>   with *mill spring* (machine stiffness). They also treat `S3` as the gauge stand, where `D-27` makes it
>   a **skim**, and carry no edger term.
> - **`FR-386`** derives `routeMode = Hybrid` from an aspect-ratio test, conflating a **geometric**
>   question with a **metallurgical** one — it can route material needing an anneal onto the one route
>   that has none. Its non-hybrid default also bypasses `FM2_S1` and `FM2_S2`, leaving the skim stand as
>   the only active stand.
>
> **`FR-389`/`FR-390`/`FR-391` and the request/response envelope are unaffected.** **Build `FW-013` to the
> generation spec, not to the FRs or to `APIContracts.md`.**

1. ~~**Generate example contradicts its own algorithm**~~ — **OUT OF MVP-1 SCOPE (11 Aug 2026).** Pass schedule generation is owned by a separate track, so this is neither a bug to fix nor a blocker on any MVP-1 phase. The finding and the §10.5 callout above it are retained because the owning track needs both, and because `FR-380`–`FR-391` still sit in `02-SRS.md` where they are now marked out of scope. **Do not implement `FW-013` from anything in this repository.** Original finding — `APIContracts.md:606-657`. Step 1 `D_pre = sqrt(4·gauge·width/π)` for gauge 0.125 / width 0.875 yields ≈**0.373"**, but the response reports `preflattenDiameterIn: 0.265`; `areaReductionPct: 50.1` is consistent with 0.265, not the formula. Separately, `aspectRatio: 7.0` must (step 7 / warning table) **activate FM2 and set `routeMode: Hybrid`**, yet the example returns `Standalone` with FM2 bypassed and no FM2 warnings. **Fix:** correct the formula or the example so they agree, and make the aspect-ratio→Hybrid branch fire.
2. ✅ **CLOSED 13 Aug 2026** — value added to the enum in `APIContracts.md`. ~~**`CheckpointType` enum missing `RollAdjustTrigger`**~~ — the enum at `APIContracts.md:139` lists `{PreRun, PostDieChange, ManualSpotCheck, PostRun}`, but `POST /rolloverride` writes a checkpoint of type `RollAdjustTrigger` (`:1183`) and `FlatWireTables.md:537` lists it. **Fix:** add the value. **[P1✓ 1B/1C]**
3. ✅ **CLOSED 13 Aug 2026** — the three-value enum is stated in `APIContracts.md` *Common Enums* and `FW-010`'s acceptance criterion is corrected. ~~**Pass-schedule component state modeled two incompatible ways**~~ — `State ∈ {Active,Bypass,Skip}` (`APIContracts.md:135`, `FlatWireTables.md:109`) vs `IsActive (bool)` in FW-010 (`FlatWireJiraStories.md:307`); a boolean cannot express Bypass vs Skip, and FW-012's 3-state UI contradicts FW-010. **Fix:** standardise on the 3-value enum. **[P1✓ cross-layer]**
4. ✅ **CLOSED 13 Aug 2026** — `Round`/`Square` is the domain vocabulary, display labels map at the UI; fixed in `APIContracts.md` and `FW-010`. ~~**Edge-type has three vocabularies**~~ — `Round/Square` (schema/API), `Round/Flat` (FW-010:307), `Round Edge/Flat Edge` (FW-050/052). Nothing maps "Flat"↔"Square". **Fix:** one domain value set (`Round`/`Square`) + a display-label mapping. **[P1✓ cross-layer]**
5. **`RodCheckin` requires fields the check-in API never sends** — `SpcM1In/M2In/OvalityIn` + `InspectionConnectorTag` are NOT NULL (`FlatWireTables.md:404-408`), but `POST /checkin/rod` and `InspectionDto` supply none (`APIContracts.md:747-812`). Inserts fail as specified. **Fix:** make them nullable or add them to the contract.
6. **3-vs-4 inspection-item conflict** — **[G14]**, **still open, and it blocks the Phase-4 build.** First found inside `CheckinImplementationPlan.md`, whose Part 4 described 4 items + M1/M2 + ovality while its own `InspectionDto`, stub and acceptance checklist described 3; **that document was deleted 13 Aug 2026 and the conflict was not deleted with it.** The live form: the DDL builds **four** inspection columns NOT NULL (`InspectionOxidation`, `InspectionSurfaceDefects`, `InspectionWaterStains`, `InspectionConnectorTag`) plus required `SpcM1In`/`SpcM2In`, while `RodStaging` and Dashboard 2A deliberately use **three** — see Tier 1 #5 for the insert failure this produces. **Fix:** pick the count and align DDL + DTO + UI + acceptance.
7. ✅ **CLOSED 13 Aug 2026 — not a contradiction.** The five are *physical measurement points*, the enum is *why the checkpoint fired*; they are different axes and were never meant to map one-to-one. Stated in `TechStackRecommendation.md`. ~~**"Five SPC checkpoints" vs "four checkpoint types"**~~ — `TechStackRecommendation.md:84` / FW-094 name five (incl. FM1-output, FM2-final-stand-output); the API enum defines four types with no slot for those two. **Fix:** reconcile the taxonomy (type vs measurement-name).

## Tier 2 — Data-model / table gaps with no owner

8. **No table persists raw AGC gauge/width readings** — **[G3, Critical]**. FL2 historical profile (FW-064 / Phase 8) and the Gauge-Trace + Cut-Traceability reports (Phase 11) require them, but Phases 3/5 say readings are "buffered, not persisted." **Fix:** add a time-series `RunReading` table (footage, gauge, width, ts, in-spec) + retention/rollup. **[P1✓ 1C]**
9. **`SpoolCheckin` has no creation story** — required by `POST /checkin/spool` and specified in `FlatWireTables.md`, but neither FW-006 nor FW-007 creates it. **Fix:** assign a creation story. **[P1✓ 1C lists it]**
10. **`FlatWireRun` vs `FlatWireRunDetail` split unresolved** — FW-005 renames `FlatLineProcessing`→`FlatWireRun` and piles run-level fields on it; `FlatWireTables.md` renames it→`FlatWireRunDetail` and says those fields belong on a *separate* `FlatWireRun` header; `FlatWireRunDetail` never appears in the backlog. **Fix:** adopt the header/detail split. **[P1✓ 1C: FlatWireRun hub in 03_Materials]**
11. **Alloy lookup has no API contract** — FW-004 needs an editable, audit-logged alloy table the generator reads; `APIContracts.md` defines no endpoints for it. **Fix:** add CRUD + audit endpoints.
12. **Alert lifecycle unbacked** — hub `AlertRaised`/`AlertCleared` + `activeAlerts` + Dashboard-1 rules exist, but no table stores alerts and no story implements raise/clear. **Fix:** add an alert table + server logic.
13. **Lot / skid undefined** — `/coil/{alpha}/label` returns `lotNumber`; `CoilOutput.SkidId` → "skid table (existing)" that is never defined/verified; no story generates lots. **Fix:** define/verify the skid + lot sources. **⚠ ESCALATED TO MVP-1 BLOCKER AND REGISTERED (11 Aug 2026).** This was tolerable while DB7/DB7b were deferred. **Phase 9 is now wholly MVP-1**, so the packing flow and the coil label both depend on sources that do not exist — and `phase-09`'s 222 h assumes neither has to be built. Now carried as gap **`G36`** with four open items: **`OI-104`** (the skid table nothing names or creates), **`OI-24`** + **`OI-99`** (lot number — no generator at all, and no multi-rod rule), **`OI-105`** (`FR-346` adds a **physical scale weight at the packing station**, a third weight figure after the calculated value and DB7's override, with no rule for which governs — compounding `OQ-10`/`OI-45`), and **`OI-106`** (staging locations undefined).
14. **Partial-rod re-check-in unbacked** — `RodCheckout` emits `PartialSpoolAlpha`/`DeferContinueLater` (OQ-12) but no endpoint/story re-checks-in a deferred partial rod. **Fix:** add the carry-forward story. **[Partly addressed 2026-07-29]** — `POST /staging/rod` now enforces the `PRC007` gate at the staging scan (`422` without `acknowledgedCarryForward`), `RodStaging.FootageRunToDateAtStaging` records the evidence, and Dashboard 2A omits the fresh-start control from the DOM per `PRC008`. The full carry-forward *accounting* (footage/weight roll-up across segments, `source_rod_alpha` genealogy) is still Phase 7 + post-go-live.
15. **Third payoff/take-up not modeled** — `PayoffPosition` enum is `{Payoff1,Payoff2}` only; FL2 uses a traversing take-up (`TraversingTakeup`). Also modeled inconsistently as `INT CHECK(1,2)` in some tables vs an FK to a 3-position reference in `FlatWireRunDetail`. **Fix:** one representation incl. the third position. **[Data model resolved 2026-07-29]** — a `PayoffPosition` lookup now exists in `DDL_01` with three **pinned** Ids (`Payoff1`, `Payoff2`, `TraversingTakeup`) and `FlatWireRunDetail.PayoffPositionId` has a real enforced FK. Rod-fed tables keep `CHECK (1,2)` as a **documented deliberate narrowing** — a rod bundle only ever mounts on a VPS bay. **Still open:** `TraversingTakeup` has no UI anywhere. See **G20**.
16. **No rod bundle / receiving-lot header** — "rod bundle receiving" is a stated workflow, but `Rod`/`coils` model one physical unit per row with no parent lot/bundle grouping. **Fix:** confirm whether a bundle header is needed.
17. ~~**DB13/DB14 (HMI/SCADA) unbacked**~~ — **RESOLVED 4 Aug 2026 by descope.** Epic 7 scoped "13 dashboards" while the roadmap referenced 1–14; both DB13 and DB14 are now **withdrawn from scope at client request**, so there is nothing left unbacked. `FR-440`–`FR-470` are marked withdrawn (numbers retained), descope-ladder rung 7 is removed, and FW-062 keeps its 8 points because neither screen ever had acceptance criteria in it.

## Tier 3 — Doc↔DDL drift (schema sync hazards)

18. **Systematic bare `decimal` in schema docs vs scaled `DECIMAL` in DDL** — the `FlatWireSchema_*.md` docs declare many numeric columns as bare `decimal` (= `decimal(18,0)`, zero fraction) where the DDL correctly uses `DECIMAL(8,2)` (weights), `DECIMAL(8,4)` (gauges), `DECIMAL(10,2)/(10,4)` (footage/measures) — across `SpoolConfiguration`, `Rod`, `Spool`, `RodCheckin`, `SpoolCheckin`, `FlatWireRunDetail`, `WipRejection`, `CoilOutput`, `RodCheckout`. Regenerating DDL from the docs would round money/measurements to whole numbers. **Largest sync hazard. Fix:** the DDL is authoritative — correct the docs. **[P1✓ 1C states DDL authoritative]**
19. **Zero nonclustered indexes** on any FK/`RunId` column despite the ER doc's "Recommended Indexes" list — ~12 child tables join on `RunId`; parent-delete FK checks scan. **Fix:** add the recommended indexes. **[P1✓ 1C]**
20. **Doc-stated business rules not enforced in DDL** — one `Active` `PassSchedule` per `Line+Alloy` (needs a filtered unique index); `CoilTraceability` non-overlapping footage ranges (only `From<To` enforced); `RunPauseEvent.Notes` required when `Other`; `WeldEvent` fail-reason required when `Fail`; RodCheckout Mode-A/B field rules. **Fix:** add CHECK/filtered-index constraints. **[P1✓ 1C]** — **RodCheckout mode rules done 2026-07-29:** `CK_RodCheckout_ModeP` and `CK_RodCheckout_ModeB` now enforce them, alongside `CK_RodStaging_Welded`/`_Unstaged`/`_CheckedIn` and the filtered unique indexes `UX_RodStaging_Bay`/`_RodActive`. The `PassSchedule` and `CoilTraceability` rules remain unenforced.
21. ~~**`RodCheckout.NewRodStatus` missing CHECK**~~ — **stale finding:** `CK_RodCheckout_NewRodStatus` is present in `FlatWire_DDL_05_QualityOutput.sql` and enumerates the six rod statuses. Verified 2026-07-29.
22. **Dangling FK columns to nonexistent tables** — `FlatWireRunDetail.PlanId`/`CoilOrderPlanId`/`PayoffPositionId`, `CoilOutput.SkidId` are described as FKs but have no parent table and no DDL FK. **Fix:** add parents or document as external/legacy references. **[P1✓ 1C documents as external]** — **`PayoffPositionId` now has a real parent and an enforced FK** (2026-07-29, see #15). `PlanId`/`CoilOrderPlanId`/`SkidId` remain external references.
23. **`SpcCheckpoint` cannot join to its trigger** — `PostDieChange`/`RollAdjustTrigger` checkpoints are auto-created by a `DieChangeEvent`/`RollOverride`, but `SpcCheckpoint` has only `RunId` + free-text `TriggerDescription`, no `DieChangeId`/`OverrideId` FK. **Fix:** add the trigger FK.
24. **Weld↔coil footage in two coordinate systems** — run events use cumulative *run* footage; `CoilTraceability.FootageFrom/To` are *coil-local*. Mapping source-rod→coil-footage needs an unstated coil-start offset. **Fix:** document/normalise the frame.
25. **Polymorphic material refs without integrity** — `WipRejection.MaterialAlpha` (rod OR spool) and `RodCheckout.PartialSpoolAlpha` have no FK; orphan-prone. **Fix:** validation or a discriminator + checked refs.
26. **Footage datatype inconsistent** — `INT` everywhere except `FlatWireRunDetail.FootageFt DECIMAL(10,2)`. **[G14]** **Fix:** standardise per documented intent. **[P1✓ 1C]**
27. **ERD overstates audit columns** — `FlatWire_ERDiagram_Documentation.md:227-230` claims audit quad "Present in Most Entities"; only `PassSchedule` has it; lookup tables have none. **Fix:** correct the ERD or add columns.
28. **Sample data issues** — `FlatWire_SampleData_Schedule.sql` header says Standalone 3 / Hybrid 7 (actual **4 / 6**); it depends on a **Lookup seed file not present** in the repo and on exact IDENTITY ordering. **Fix:** correct the comment; ship the lookup seed. **[P1✓ 1C authors the seed + fixes comment]**
29. **`WeldJoinEvent` vs `WeldEvent` naming drift** — aggregate `WeldJoinEvent.cs` vs table/endpoint/story `WeldEvent`. **Fix:** align. **[P1✓ 1B]**
30. **No DB support for gap-free `R#####` sequence** — alphas are UNIQUE `varchar` only; no SEQUENCE/numbering table. **Fix:** add a numbering mechanism or document it as app-enforced.

## Tier 4 — Sequencing & traceability

31. ~~**Phase-1 deadline conflicts with the roadmap window** — Phase 1 due **14 Aug 2026** but the roadmap schedules it in W1 = Aug 17–23 (`back-matter.md:63`). **Fix:** re-baseline W1/M1/QA1 to the Aug-14 gate; note the compression against the thin capacity model.~~ **[G1] — ✅ ADDRESSED (Jul 30 2026).** `back-matter.md`'s grid now opens with **W0 = to Aug 14** (hard gate, 12 working days) and W1 = Aug 17–21 as carry-over; **M1 moved to Aug 14** and a new **QA0 (Aug 14)** covers the Phase-1 gate suites. **Labor Day (Mon 7 Sep)** is deducted from W4 and W7 is marked as 3 days — the post-gate window is **32 working days**, not 32.5. The compression is now quantified rather than noted: see [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §4.
32. ✅ **CLOSED 13 Aug 2026** — propagated. The crosswalk states it explicitly as *the single most consequential change*: the backbone moves from Sprint 5 to **Phase 3**, ahead of its consumers. ~~**Real-time layer scheduled after its consumers**~~ — FW-080/081/082 are Sprint 5, but their consumers (Dashboard 1/3, FW-060/062) are Sprint 4 and list them as dependencies; `APIContracts.md` also claims the hub skeleton in S1 — a third answer. **Fix:** move the real-time backbone ahead of the dashboards (the roadmap's Phase 3 already does this — propagate to the April docs).
33. ✅ **CLOSED 13 Aug 2026 — and closed again, more strongly, the same day.** `FlatWireJiraStories.md` was rewritten as the sprint-wise MVP-1 backlog: it now carries **one live sprint calendar** (`S0`–`S3`, even two-week cadence, `S1` from 24 Aug) that derives from `back-matter.md`'s week grid and reconciles to **3,292 h**. The crosswalk is no longer needed to make the old tags resolve — **the dead `S1`–`S5` model is gone rather than translated**, and `05-SprintPlanAndBacklog.md` §4.2's `S0`–`S4` is marked retired. `FW-S1-###`/`FW-S3-###` are recorded in that file's Appendix B.5 as **never having existed**. *(Original close: the 14-phase model was adopted in all three documents and a sprint→phase crosswalk published.)* ~~**Three incompatible sprint/phase models**~~ — JiraStories (5 sprints) vs APIContracts (Sprint delivery) vs roadmap (14 phases); no crosswalk, so "Sprint S3" tags don't resolve. **Fix:** adopt the 14-phase model + a sprint→phase crosswalk.
34. **Phase 6 depends on Phase 13** — die-change validation (Phase 6) needs the die-inventory reference data created in Phase 13. **Fix:** pull the minimal die reference into Phase 6, or resequence.
35. **Dependency graph mis-nests FL3** — `back-matter.md:20-22` draws Phase 8→9→10, implying FL3 (hybrid) depends on the FL2 spool check-in; FL3 has no intermediate spool. **Fix:** correct the graph (FL3 depends on P4/5/6 + P9).
36. ✅ **CLOSED 13 Aug 2026** — both check-in documents now name `FW-061`/`FW-082`/`FW-064` in their headers and say the `FW-S3-###` ids do not exist; the crosswalk resolves them. ~~**Check-in docs use non-existent story IDs**~~ — `CheckinImplementationPlan/Prompt` cite `FW-S3-009/012`, `FW-S1-001/002`; the backlog uses `FW-001…123`. **Fix:** re-map to real IDs (rod check-in = FW-061/FW-082).
37. **Shift-summary UI precedes its API** — FW-069 (S4) vs `GET /shiftsummary` (S5); `GET /lines/status` is promised in S1 with no implementing story. **Fix:** align story/endpoint sprints.
38. ✅ **CLOSED 13 Aug 2026** — the 14 upstream stories are marked, as are the seven MVP-2 stories and the one spanning both. Rows marked in place, never deleted. ~~**Scope cut not reflected in the backlog**~~ — the roadmap removed Rod Receiving (E03) + Planning/Scheduling (E04/E05) as upstream (14 stories), but `FlatWireJiraStories.md` still lists them Critical/High, Sprint 2–3. **Fix:** mark them upstream/out-of-scope in the backlog.

## Tier 5 — Check-in implementation docs stale

> **⚠ Both subject documents were DELETED on 13 Aug 2026** — `CheckinImplementationPlan.md` and `CheckinImplementationPrompt.md`, recoverable at `1964086`. The six findings below are retained as the record of what they got wrong, because the instructions survive in git history and in any April copy, and because **#6 (`G14`) is still open**. Where a closure note below says *"banner-ed in both"*, the banner went with the file; the correct position it named is stated in the live document cited alongside it. **The three things cited *from* those documents were rehomed before deletion:** the stub-first delivery contract → [`ShopfloorPlan/00-foundations.md`](ShopfloorPlan/00-foundations.md) **§0.5**; the `0.003″` ovality datum → `AlloyProperty.RodOvalityMaxIn` (per-alloy reference data, not a constant); `G14` → [`ShopfloorPlan/back-matter.md`](ShopfloorPlan/back-matter.md), which now carries the *"every check-in insert fails as specified"* statement.

39. ✅ **CLOSED 13 Aug 2026** — banner-ed in both check-in documents, then **the documents themselves were deleted the same day**, which removes the wrong tokens rather than merely warning about them. ~~**Stale `--fw-*` design tokens**~~ — `CheckinImplementationPlan/Prompt` hard-code a `--fw-*` system; the mockups and `flat-wire-shopfloor.styles.scss/.css` use `--color-*` semantic tokens. **[G18]** **Fix:** `--color-*`. **[P1✓ 1A]**
40. ✅ **CLOSED 13 Aug 2026** — banner-ed in both. ~~**Retired UI shape**~~ — they port the interim grid + progress-ring layout that held the `dashboard_2_rod_checkin.html` filename until 11 Aug 2026; the approved design is the 6-step tab-wizard (`- New.html` until it took that filename on 11 Aug 2026). **Fix:** target the wizard, now `dashboard_2_rod_checkin.html`. **[P1✓ 1A]**
41. ✅ **CLOSED 13 Aug 2026** — banner-ed in both, naming `00-foundations.md` §0.2. ~~**Forbidden reference library**~~ — "copy patterns from `checkin-precheckin`"; foundations §0.2 + decision 5 forbid it. **Fix:** build fresh from mockups. **[P1✓ 1A]**
42. ✅ **CLOSED 13 Aug 2026** — headers corrected; both say the body is April-dated and unrevised. ~~**Stale dates**~~ — `CheckinImplementationPlan.md` Last Updated April 30 2026; fixtures 2026-04-29/30 (pre-replan).
43. ✅ **CLOSED 13 Aug 2026** — banner-ed: `UAController` + `[Authorize]`. ~~**Auth inconsistency**~~ — Plan uses `UAController`+`[Authorize]`; Prompt uses bare `ControllerBase`, no `[Authorize]`; `APIContracts.md` requires auth on `/checkin/rod`. **Fix:** `UAController`+`[Authorize]`. **[P1✓ 1B]**
44. ✅ **CLOSED 13 Aug 2026** — banner-ed; canonical set is the DB seed. ~~**Inconsistent stub fixtures**~~ — `PS-1100-FL2-001` vs `-007`; `SP-00021` source `RUN-0041` vs sourceRods `R00040/R00041`→`SP-00031`. **Fix:** one canonical fixture set (align to the DB seed).

## Tier 6 — Under-specified phases & coverage

45. **Phases 12/13/14 collapse the 9-section template** — Phase 12 & 13 have **no Acceptance criterion**; Phase 14 has no exit-test matrix beyond "three green E2E runs." **[G11 — which itself omits Phase 14]** **Fix:** expand to the full template with acceptance; correct G11 to 10/12/13/14.
46. **Digital traveler orphaned** — foundations declares the traveler "fully digital," but no phase owns building/storing/displaying it (only OQ-3). **Fix:** assign an owning phase/story.
47. **SignalR NFRs thin** — no backoff/re-subscribe-on-reconnect/mid-run token refresh/decimation SLA in the April docs (the roadmap §0.4 has them). Refresh-cadence contradiction: Dashboard-1 "~5s poll" (FW-060) vs continuous stream (FW-081). **Fix:** propagate §0.4 NFRs; resolve poll-vs-stream. **[P1✓ 1A/1B implement §0.4]**
48. **FW-080 event list incomplete** — omits `LineStatus`/`AlertRaised`/`AlertCleared` that command side-effects broadcast. **Fix:** complete the list. **[P1✓ 1A/1B]**

## Tier 7 — Doc hygiene (cosmetic)

49. ~~**No change log** in `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`~~ — **the change-log half is void as of 12 Aug 2026**: the repository has one change log, [`../../CHANGELOG.md`](../../CHANGELOG.md), and no document carries its own, so having none is now correct. What remains of this finding is the **stale `Last Updated` (Apr 29–30) and `Status: Draft` on all four**, and the fact that none of the four has a section in `CHANGELOG.md` — their history was never recorded anywhere.
50. ✅ **CLOSED 13 Aug 2026** — all counts point at the verified baseline: **25 MVP-1 / 28 in the full design**, from the clean rebuild of 11 Aug 2026. ~~**Table-count drift**~~ — 20 (`FlatWireJiraStories.md:1466`) vs 21 (`back-matter.md`, post-`Rod`-drop) vs 22 (ERD); the roadmap change log is itself self-inconsistent (58/58 vs 44/44; 22 vs 21). *(With the new `RunReading` table the current count is **22**.)*
51. ⚠ **MOOT 13 Aug 2026 — story points were retired, so this finding has no subject left.** `FlatWireJiraStories.md` was rewritten and is **sized in hours**; there are no epics and no point totals to be wrong about. The last correct figures (**E07 15 / 72**, total **59 / 231**) are preserved in that file's *Appendix A — Retired point basis* alongside the 147 / 189 totals. **Do not reopen this against the current backlog.** *(Previously: ⚠ SUPERSEDED — this finding's own numbers are now stale.)* It proposed E07 = 67 / total 226, correct when written. `FW-124` (5 pts) was added afterwards: **E07 is 15 stories / 72 points and the total is 59 / 231.** Corrected in the document and re-derived from the story rows. See **#57**. ~~**E07 story-point total wrong**~~ — summary says 65; the 14 stories sum to 67, so the grand total is 226 not 224.
52. **Undefined roles** — FW-004 "Process Engineering / System Admin" and `POST /rod` "Receiving" are not in the 5-role Authorization Matrix.
53. ~~**No document-control block on any of the 14 phase files** — no owner/version/change-log/effort.~~ **✅ ADDRESSED (Jul 30 2026)** — all **17** phase specs (`phase-01`, `01a`, `01b`, `01c`, `02`–`14`) now carry `Project` / `Last Updated` / `Status` / `Layer` / **`Owner`** / **`Effort`** / **`Scope call`**. Owner names a delivery **stream**; the named-owner roster is in [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §1 and is **still unfilled**. Per-phase change logs were **not** added (the roadmap index carries the shared change log).
54. **Residual dropped-`Rod` pointers** — `phase-08` still reads "`Spool→Rod(ParentRodAlpha)`"; DDL/ERD still say `united_db` and include the dropped `Rod` table. **[G12]**
55. **Load-bearing TBD placeholders** — die-life threshold (`phase-13`), trial/production dates (`phase-14`/`back-matter`); FW-050 pricing (OI-81); FW-102 config.
56. **Path / cross-ref nits** — phases use short `/passschedule`, APIContracts uses `/api/v1/flatwire/…`; Appendix-C omits FW-068→Phase 2 and FW-054→Phase 13 from those phases' "Stories:" footers; `ShopfloorAndRealTimePlan.md` file name vs its "Master Implementation Roadmap" H1.

---

## Tier 8 — Found by the 13 Aug 2026 reconcile-up

Six findings that did not exist in the 11 Aug review. **#57 and #58 are the substantive ones.**

57. **`FW-124` is a live story that reached no summary — and the coverage appendix that exists to catch exactly this did not.** **[FIXED 13 Aug 2026; the class of defect closed later the same day]** — the backlog was re-derived from the phase specs rather than maintained as a list, so a story can no longer exist in a phase file and be absent from the backlog: **every phase's `Stories:` trailer was walked**. The four stale figures this finding tracked (**E07 72 · total 231 · 189-point basis · 45/45**) are now **all retired with story points themselves** and preserved in `FlatWireJiraStories.md` Appendix A. `back-matter.md` Appendix C is marked a **derived view** — it is correct for the 45 rows it holds and is explicitly not complete. **The lesson generalises and is worth keeping: a coverage table cannot detect a row that was never added — derive it, or verify the count against the source.** `FW-124` · *Dashboard 5A — FL2 Spool Queue* (5 pts, `High`, phase 8) is built by [`phase-08`](./ShopfloorPlan/phase-08-fl2-spool-checkin-finishing-run.md), specified by `02-SRS.md` §5.3a and owned by `SpoolQueue.md`. It was **absent from `back-matter.md` Appendix C**, whose closing line claimed *"44/44 shopfloor stories mapped"*, and from `FlatWireJiraStories.md`'s backlog summary. **The claim was not a miscount — the row was simply not there**, so nothing could detect it. One story explains four stale figures across two documents: E07 65→**72**, total 224→**231**, the *"184-point cross-check basis"*→**189**, and 44/44→**45/45**. All corrected; the Appendix C row added. **Lesson for the next audit: a coverage table cannot detect a row that was never added — verify the count against the source, not against the table.**

58. **The `.code-workspace` had not opened correctly since the folder moved.** **[FIXED 13 Aug 2026]** `Flat Wire.code-workspace` declared `../../ual-angular` and `../../ual-api`, which from `MVP-1/DevelopmentPlan/` resolve to `Flatwire-planning/ual-*` — **neither exists**. The code repos are siblings of `Flatwire-planning` under `c:\UAL`, so they are three levels up. `..` also opened `MVP-1/` rather than the planning repo root that `CLAUDE.md` describes. All three paths corrected and verified to resolve; folders given display names.

59. **Two API contract documents coexisted with no statement of which governed.** **[RULED 13 Aug 2026]** `DevelopmentPlan/APIContracts.md` (April, 2,373 lines) and `ProjectPlan/04-APIContract.md` (4 Aug, 913 lines). **The 4 Aug document is the contract of record**, consistent with the standing rule that July/August artifacts win over April ones. The April document keeps its extra detail — request/response bodies, worked examples, project structure the owner does not carry — but is **not citable**, and anything it holds that the owner lacks should be **migrated into the owner** rather than cited. Banner added to both ends of the ruling.

60. **The MVP-1/MVP-2 split had reached almost none of this folder.** **[FIXED 13 Aug 2026 for the four April docs]** Nine of the twelve top-level documents contained **zero** occurrences of "MVP-2" — including the API contract carrying 16 `/passschedule` references now owned by another track, the 58-story backlog, and the table design. Scope marking added to all four April documents. **Still zero and deliberately so:** `PLCTagImplementation.md` (the tag surface is scope-agnostic) and the two check-in documents. **Closed a different way on 13 Aug 2026:** the check-in documents were **reduced to records** — bodies removed, defect lists and cited facts retained — and `RodPreCheckinUxReviewPrompt.md` was **deleted** (recoverable at `1964086`), so scope-marking a superseded body is moot.

61. **`ShopfloorPlan/00-foundations.md` and `back-matter.md` carried no header block.** **[FIXED 13 Aug 2026]** No `Project` / `Last Updated` / `Status`, though `CLAUDE.md` mandates one for every planning document and all 17 phase files have one. These are the two most-cited files in the folder — foundations is *"do not restate"* reference material and back-matter is the live `G##` register — so neither had a modification date a reader could check.

62. **Two documents carried statuses that were untrue.** **[FIXED 13 Aug 2026]** `WeldEventPopupPlan.md` read *"Draft for approval — no edits made yet"* while its plan had been executed on 1 Aug and its `S`-steps marked DONE — the file describing the change said the change had not happened. `CheckinImplementationPlan.md` read *"Ready for implementation"* while carrying all six Tier 5 defects, including a pointer at a **forbidden** reference library. `CapacityAndEffortModel.md` was dated 30 Jul while carrying the 11 Aug §3b apportionment.

---

## Appendix — reconcile-up worklist (recommended)

Treat the July 26 roadmap as source of truth; align each April doc **up to** it. Recommendations only.

*"Add a change log" is struck from all four rows as of 12 Aug 2026 — the repository has one change log, [`../../CHANGELOG.md`](../../CHANGELOG.md), and no document carries its own. Give each of the four a **section** there instead, recording the reconciliation when it happens.*

| April doc | Reconcile to the roadmap |
|---|---|
| `FlatWireJiraStories.md` | ✅ **REWRITTEN WHOLE 13 Aug 2026** — no longer on this worklist. Re-derived from the 15 `ShopfloorPlan/` phase specs into **116 stories / 3,292 h** across four even two-week sprints (`S1` from 24 Aug), **sized in hours** off `CapacityAndEffortModel.md` §2's rate card and reconciling exactly to its §3b. It is now the **authoritative MVP-1 backlog**, superseding `05-SprintPlanAndBacklog.md` §7/§7.3. **Story ids frozen; new work minted at `FW-130`+.** Closes the Phase-1 coverage hole the capacity model named (1,027 h against seven database-only stories → **33 stories in S0**). Story points, epics and every point total are **retired** to its Appendix A. *(Earlier the same day: timeline re-baselined, upstream/MVP-2 marked, `IsActive`→`State{Active,Bypass,Skip}`, `Round/Flat`→`Round/Square`.)* See **#33**, **#51**, **#57**. |
| `APIContracts.md` | ✅ **DONE 13 Aug 2026.** `RollAdjustTrigger` added to `CheckpointType`; delivery schedule aligned to **phases**; hub event list verified complete (9 events, including `LineStateChanged`/`AlertRaised`/`AlertCleared`); the missing **alloy-lookup**, **override-revert** and **alert-lifecycle** endpoints are **recorded as gaps** rather than drafted here, because inventing a shape would create a second unowned contract. Also demoted below `ProjectPlan/04-APIContract.md` (**#59**) and given the `LineOperatingState` / `scheduleId` / edge-type fixes. ~~Fix the `/passschedule/generate` example~~ — **struck: out of MVP-1 scope.** |
| `FlatWireTables.md` | ✅ **DONE 13 Aug 2026.** The bare-`decimal` hazard is called out at the head of the document as the largest sync risk in the folder — **the DDL is authoritative and the doc is the analysis**, so the types are not restated here; the `FlatWireRun`/`FlatWireRunDetail` split, `RunReading`, `PayoffPosition`, `RodStaging` and `Dancer` are all recorded, with `SpoolCheckin`'s owner (Phase 1C creates, Phase 8 populates). `united_db` was **already absent** — 0 occurrences. ~~drop the dedicated `Rod` table~~ — **struck: `D-04` retains it**, and `G12` closed on exactly that. |
| `TechStackRecommendation.md` | ✅ **DONE 13 Aug 2026.** Status → **Accepted**; the database decision closed as **a new standalone `FlatWireDB`** (the *"or schema extension"* alternative struck), with `G17`'s cross-DB cost named. The SPC reconciliation resolved as **not a contradiction** — the five are physical measurement points, the enum is why a checkpoint fired; different axes, no mapping owed. Also corrected the Angular rationale, which cited the **forbidden** slitter/furnace modules as a pattern source. |


---

## Appendix — `WeldEventPopupPlan.md`, absorbed 13 Aug 2026

> The weld-event change plan was **executed** (applied 1 Aug 2026; `S7`, its last step, closed 13 Aug) and the file
> was deleted in the consolidation. Its design narrative and work breakdown had already been removed as spent.
> **What is retained here is what other documents still cite**: the decision attribution, the `Q-W#` register with
> its dispositions, and the gap-register outcomes. `S1`–`S9` all landed. Full text at commit `1964086`.

### The change, in one paragraph

The weld capture moved off a standalone screen and onto the pre-check-in station. **Dashboard 4 was retired**; the weld
is now a dialog reached from Dashboard 2A's staged payoff card. **`POST /staging/rod/mark-welded` was retired and
`POST /weldevent` became the single weld write** — Dashboard 2A's *Mark as welded* dialog gained the quality check, so
one row is composed by both entry points. That merge is **decision `D-A`**, which is what
[04-APIContract.md](04-APIContract.md) attributes to this document. A read-only **Welds this run** dialog was built on
Dashboard 2A over `GET /run/{runId}/weldevents`. Welds are **induction** only; laser was dropped.

### `Q-W#` register — dispositions

| Ref | Disposition |
|---|---|
| ~~**Q-W1**~~ | **DECIDED 1 Aug 2026 — yes, quality is captured at the weld.** Rather than removing the lightweight flag, Dashboard 2A's *Mark as welded* dialog gained the quality check; it already captured both alphas, weld type and footage, so quality was the only NOT NULL `WeldEvent` column missing. `POST /staging/rod/mark-welded` retired. Closed by `D-A` |
| **Q-W2** | **OPEN · Medium · ⚠ this document is its only home** — see the finding below |
| ~~**Q-W3**~~ | **DECIDED 1 Aug 2026 — yes, a weld-history view is needed.** A read-only **Welds this run** dialog on Dashboard 2A, scoped to the active `RunId`, over `GET /run/{runId}/weldevents`. Built; `G25` withdrawn rather than registered |
| ~~**Q-W4**~~ | **ACTED ON 1 Aug 2026 — the FL2 active-run link to the weld screen was removed**, along with the weld button on all four active-run screens. ⚠ **Decided rather than answered**, which is why it became gap **`G28`**: `dashboard_10_shift_summary.html` fixtures show FL2 welds (`SP-00029 → SP-00030`, induction) while `WeldEvent.md:166` says FL2 *inherits* the spool's weld markers. If FL2 does weld spool-to-spool it now has **no capture path at all** |

> ### ⚠ `Q-W2` is live, unregistered, and was nearly lost
>
> **The question:** should the post-staging weld offer be **gated to the sub-3,000 lb window**, or shown on **every**
> successful staging? It governs `D-G`, the offer's trigger rule.
>
> This document states that its `Q-W#` questions were *"to be added to `Analysis/FlatWireOpenQuestions.md`"*. **Only
> `Q-W1` and `Q-W4` were ever propagated** — `Q-W1` through `APIContracts.md`, `Q-W4` through gap `G28`. `Q-W2` was
> not, and a repository-wide search on 13 Aug 2026 found it **nowhere else**: not in the open-questions register, not
> in the master spec's `OI-##` register, not in `RodPreCheckin.md`. The 3,000 lb *alert* threshold is well specified
> (`FR-034`, `FR-423`, `RodPreCheckin.md` §alerts); **whether the weld offer follows that threshold is not.**
>
> **It needs registering in `Analysis/FlatWireOpenQuestions.md`.** Flagged rather than done, because that register is
> outside the folder this clean-up covered.

### Gap register outcomes

| Gap | Outcome |
|---|---|
| ~~**G25**~~ | **WITHDRAWN 1 Aug 2026 — built rather than deferred** (the *Welds this run* dialog). It was withdrawn before it was ever registered, so nothing cited it, and **the ID was reused on 13 Aug 2026** for the requirement-coverage gap now in [`back-matter.md`](./ShopfloorPlan/back-matter.md) |
| **G26** | **The merged weld write straddles two phases** — Dashboard 2A's weld control ships in **phase 4**, and `POST /weldevent` is a **phase 6** deliverable, so phase 4 ships a button whose target lands later. **Registered 13 Aug 2026, twelve days late**: `phase-06:45` had cited it since 1 Aug against no register entry. That omission was step `S7`, the one step of nine that did not execute on the day |
