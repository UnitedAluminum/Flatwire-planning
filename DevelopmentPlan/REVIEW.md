# Flat Wire Mill — DevelopmentPlan Review

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-06
**Status:** Review — findings & recommendations (no source docs edited by this review, except the Phase-1 split)
**Scope reviewed:** `DevelopmentPlan/` — `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`, `ShopfloorAndRealTimePlan.md`, `ShopfloorPlan/*`, `CheckinImplementationPlan.md`, `CheckinImplementationPrompt.md`; plus the schema design and DDL, since moved to `LatestDocument/DBChanges/Schema/*` + `Schema/SQL/*`.

> **Blind spot this review shared with every other doc (added 2026-07-29).** The scope above is markdown- and SQL-only. **`.docx` files are zip containers, so `grep` never reaches inside them** — which is how `SRS §4.2 PCI001`–`PCI008` (pre-check-in), `WLD010`, `TRV004`/`TRV009` and §4.18 `PRC001`–`PRC019` went unnoticed across the whole `DevelopmentPlan/`. A specified, testable feature had no analysis note, mockup, table, endpoint or phase owner, and `CommonDB_Insert_WIPStations_FlatWire.sql` D2 explicitly declined to create its station. Recorded as **G19**. **Any future audit of this repo must extract the SRS `.docx` and read §4 requirement-by-requirement, not grep for it.**

---

## Executive summary

The DevelopmentPlan is thorough and largely self-aware — its own [`ShopfloorPlan/back-matter.md`](./ShopfloorPlan/back-matter.md) **Gaps register (G1–G20)** already tracks many of the issues below as "Open." The dominant problem is **doc split-brain**:

> Four docs dated **Apr 29–30 2026** (`APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`) were **never reconciled** with the **July 26 2026 rewrite** (`ShopfloorAndRealTimePlan.md` + the `ShopfloorPlan/*` phase files). The April docs still present the dead "May–June 2026 / Trial Jul 1 / Prod Aug 1" timeline and a 5-sprint model; the roadmap re-baselined to **Aug 17 – Sep 30 (~6.5 wk)**, 14 phases, production Q4 2026. **Most contradictions in this review descend from that un-propagated split.**

**Timeline note (authoritative):** **Phase 1 must be complete by 14 Aug 2026** (current directive). ~~This is *earlier* than the roadmap's own W1 (Aug 17–23 in [`back-matter.md`](./ShopfloorPlan/back-matter.md)), so the roadmap calendar, milestone M1 (Aug 23) and QA1 need re-baselining against the Aug-14 gate.~~ **Re-baselined Jul 30 2026** — the grid now opens with **W0 = to Aug 14**, M1 moved to Aug 14, QA0 added (#31). Since today is 2026-07-30, Phase-1 work has to be underway now — and the [Capacity & Effort Model](./CapacityAndEffortModel.md) finds Phase 1 needs **1,027 h — 10.7 FTE across the 12 remaining working days**, so the gate is at risk on headcount, not on sequencing. *(Phase 1 has been split into three execution-ready layer specs — [1A Angular](./ShopfloorPlan/phase-01a-angular-foundation.md) · [1B Backend](./ShopfloorPlan/phase-01b-backend-foundation.md) · [1C Database](./ShopfloorPlan/phase-01c-database-foundation.md) — that carry the Aug-14 gate and bake in the Phase-1-relevant fixes below.)*

**Remediation posture (recommended):** treat the July 26 roadmap as the source of truth and **reconcile the four April docs *up to* it** (see the Appendix worklist), rather than maintaining two timelines.

### Top 5 to fix first
1. **`/passschedule/generate` is internally wrong** (Tier 1) — the worked example contradicts its own algorithm; an implementer cannot trust it.
2. **Reconcile the three timeline/sprint models and re-baseline to the Aug-14 Phase-1 gate** (Tier 4 / G1) — the plan has no single calendar. *(Calendar re-baselined and the capacity model published Jul 30 2026 — see [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) and #31/#53. The sprint→phase crosswalk (#33) is still open, but `FlatWireJiraStories.md` is now explicitly superseded **as a schedule**; its points survive only as a cross-check. **New top-priority consequence:** the model finds the plan is **3,727 hours against 44 working days** (352 h/person) — the 30 Sep date needs a programme decision, not a doc fix.)*
3. **Persist AGC readings** (Tier 2 / **G3**) — add a `RunReading` table; FL2 profile + Gauge-Trace/Cut-Traceability reports currently have no data source. *(Done in [1C](./ShopfloorPlan/phase-01c-database-foundation.md).)*
4. **Add FK/`RunId` indexes and correct the doc↔DDL precision drift** (Tier 3) — hub-join performance + a regeneration hazard. *(Indexes/precision addressed in [1C](./ShopfloorPlan/phase-01c-database-foundation.md).)*
5. **Fix the check-in implementation docs** (Tier 5) — they steer developers to the wrong tokens, the retired UI, and a forbidden reference library.

**Legend:** `file:line` references point into `DevelopmentPlan/`. **[Gxx]** = matching item already in the Gaps register. **[P1✓]** = addressed in the Phase-1 layer specs.

---

## Tier 1 — Correctness bugs (executable-spec is wrong; fix before code)

> **Three PLC-surface arbitrations, added 4 Aug 2026 when the tag surface was consolidated into [`LatestDocument/RequirementDocuments/PLCTagSpecification.md`](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) (`[PLC]`).** Each names a winner, so no one has to re-derive it:
>
> **(a) `scheduleId`, not `passScheduleId`.** `PushPassSchedule`’s first parameter is `scheduleId` in all four ProjectPlan documents and `passScheduleId` in `APIContracts.md:1177` and `phase-04:62`. **`scheduleId` wins** — `APIContracts.md` is already superseded, and the convention is to reconcile the April docs *up to* the roadmap. `phase-04:62` needs the one-line correction.
>
> **(b) `02-SRS.md` contradicts itself on the tag push, twice.** Its interface section said *speed **targets*** while `FR-073` says *speed **limits***; and `FR-073`/`FR-074` still describe the batch as *"a single transactional batch"* that *"shall be rolled back"*, which four other sources correctly call a **compensating re-clear** (gap **G16**). **`[PLC §7.5]` wins on the rollback wording** — that is now a text fix owed in `FR-073`/`FR-074`, and G16 closes on it. **The speed question has no winner yet**: a setpoint and a safety clamp are different tags, so it is asked as **`PLC-Q06`** and `FR-073`’s wording is deliberately left alone until it closes.
>
> **(c) Three things were called `LineState`.** The machine tag, a six-member application enum with **no `Stopped`**, and a hub event named `LineStatus` — while `FR-141` fires the spool prompt on a *running → stopped* transition. **`[PLC §6]` wins:** the machine tag keeps the name, the enum becomes `LineOperatingState`, the event becomes `LineStateChanged`, and the machine-value→state mapping is published as **configuration** so the commissioning answer (**`PLC-Q01`**) needs no code change. **Do not add a seventh enum member.**

> **The generate-from-specs *algorithm* is superseded, not only its example (added 6 Aug 2026).** Finding
> #1 below is about `APIContracts.md`'s worked example disagreeing with `FR-381`. A gap audit of
> [`PassScheduleGenerationSpec.md`](../LatestDocument/RequirementDocuments/PassScheduleGenerationSpec.md)
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

1. **Generate example contradicts its own algorithm** — `APIContracts.md:606-657`. Step 1 `D_pre = sqrt(4·gauge·width/π)` for gauge 0.125 / width 0.875 yields ≈**0.373"**, but the response reports `preflattenDiameterIn: 0.265`; `areaReductionPct: 50.1` is consistent with 0.265, not the formula. Separately, `aspectRatio: 7.0` must (step 7 / warning table) **activate FM2 and set `routeMode: Hybrid`**, yet the example returns `Standalone` with FM2 bypassed and no FM2 warnings. **Fix:** correct the formula or the example so they agree, and make the aspect-ratio→Hybrid branch fire.
2. **`CheckpointType` enum missing `RollAdjustTrigger`** — the enum at `APIContracts.md:139` lists `{PreRun, PostDieChange, ManualSpotCheck, PostRun}`, but `POST /rolloverride` writes a checkpoint of type `RollAdjustTrigger` (`:1183`) and `FlatWireTables.md:537` lists it. **Fix:** add the value. **[P1✓ 1B/1C]**
3. **Pass-schedule component state modeled two incompatible ways** — `State ∈ {Active,Bypass,Skip}` (`APIContracts.md:135`, `FlatWireTables.md:109`) vs `IsActive (bool)` in FW-010 (`FlatWireJiraStories.md:307`); a boolean cannot express Bypass vs Skip, and FW-012's 3-state UI contradicts FW-010. **Fix:** standardise on the 3-value enum. **[P1✓ cross-layer]**
4. **Edge-type has three vocabularies** — `Round/Square` (schema/API), `Round/Flat` (FW-010:307), `Round Edge/Flat Edge` (FW-050/052). Nothing maps "Flat"↔"Square". **Fix:** one domain value set (`Round`/`Square`) + a display-label mapping. **[P1✓ cross-layer]**
5. **`RodCheckin` requires fields the check-in API never sends** — `SpcM1In/M2In/OvalityIn` + `InspectionConnectorTag` are NOT NULL (`FlatWireTables.md:404-408`), but `POST /checkin/rod` and `InspectionDto` supply none (`APIContracts.md:747-812`). Inserts fail as specified. **Fix:** make them nullable or add them to the contract.
6. **3-vs-4 inspection-item conflict inside one doc** — `CheckinImplementationPlan.md` Part 4 describes 4 items + M1/M2 + ovality, but its `InspectionDto`/stub/acceptance checklist say 3. **[G14]** **Fix:** pick the count and align DTO+UI+acceptance.
7. **"Five SPC checkpoints" vs "four checkpoint types"** — `TechStackRecommendation.md:84` / FW-094 name five (incl. FM1-output, FM2-final-stand-output); the API enum defines four types with no slot for those two. **Fix:** reconcile the taxonomy (type vs measurement-name).

## Tier 2 — Data-model / table gaps with no owner

8. **No table persists raw AGC gauge/width readings** — **[G3, Critical]**. FL2 historical profile (FW-064 / Phase 8) and the Gauge-Trace + Cut-Traceability reports (Phase 11) require them, but Phases 3/5 say readings are "buffered, not persisted." **Fix:** add a time-series `RunReading` table (footage, gauge, width, ts, in-spec) + retention/rollup. **[P1✓ 1C]**
9. **`SpoolCheckin` has no creation story** — required by `POST /checkin/spool` and specified in `FlatWireTables.md`, but neither FW-006 nor FW-007 creates it. **Fix:** assign a creation story. **[P1✓ 1C lists it]**
10. **`FlatWireRun` vs `FlatWireRunDetail` split unresolved** — FW-005 renames `FlatLineProcessing`→`FlatWireRun` and piles run-level fields on it; `FlatWireTables.md` renames it→`FlatWireRunDetail` and says those fields belong on a *separate* `FlatWireRun` header; `FlatWireRunDetail` never appears in the backlog. **Fix:** adopt the header/detail split. **[P1✓ 1C: FlatWireRun hub in 03_Materials]**
11. **Alloy lookup has no API contract** — FW-004 needs an editable, audit-logged alloy table the generator reads; `APIContracts.md` defines no endpoints for it. **Fix:** add CRUD + audit endpoints.
12. **Alert lifecycle unbacked** — hub `AlertRaised`/`AlertCleared` + `activeAlerts` + Dashboard-1 rules exist, but no table stores alerts and no story implements raise/clear. **Fix:** add an alert table + server logic.
13. **Lot / skid undefined** — `/coil/{alpha}/label` returns `lotNumber`; `CoilOutput.SkidId` → "skid table (existing)" that is never defined/verified; no story generates lots. **Fix:** define/verify the skid + lot sources.
14. **Partial-rod re-check-in unbacked** — `RodCheckout` emits `PartialSpoolAlpha`/`DeferContinueLater` (OQ-47) but no endpoint/story re-checks-in a deferred partial rod. **Fix:** add the carry-forward story. **[Partly addressed 2026-07-29]** — `POST /staging/rod` now enforces the `PRC007` gate at the staging scan (`422` without `acknowledgedCarryForward`), `RodStaging.FootageRunToDateAtStaging` records the evidence, and Dashboard 2A omits the fresh-start control from the DOM per `PRC008`. The full carry-forward *accounting* (footage/weight roll-up across segments, `source_rod_alpha` genealogy) is still Phase 7 + post-go-live.
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
32. **Real-time layer scheduled after its consumers** — FW-080/081/082 are Sprint 5, but their consumers (Dashboard 1/3, FW-060/062) are Sprint 4 and list them as dependencies; `APIContracts.md` also claims the hub skeleton in S1 — a third answer. **Fix:** move the real-time backbone ahead of the dashboards (the roadmap's Phase 3 already does this — propagate to the April docs).
33. **Three incompatible sprint/phase models** — JiraStories (5 sprints) vs APIContracts (Sprint delivery) vs roadmap (14 phases); no crosswalk, so "Sprint S3" tags don't resolve. **Fix:** adopt the 14-phase model + a sprint→phase crosswalk.
34. **Phase 6 depends on Phase 13** — die-change validation (Phase 6) needs the die-inventory reference data created in Phase 13. **Fix:** pull the minimal die reference into Phase 6, or resequence.
35. **Dependency graph mis-nests FL3** — `back-matter.md:20-22` draws Phase 8→9→10, implying FL3 (hybrid) depends on the FL2 spool check-in; FL3 has no intermediate spool. **Fix:** correct the graph (FL3 depends on P4/5/6 + P9).
36. **Check-in docs use non-existent story IDs** — `CheckinImplementationPlan/Prompt` cite `FW-S3-009/012`, `FW-S1-001/002`; the backlog uses `FW-001…123`. **Fix:** re-map to real IDs (rod check-in = FW-061/FW-082).
37. **Shift-summary UI precedes its API** — FW-069 (S4) vs `GET /shiftsummary` (S5); `GET /lines/status` is promised in S1 with no implementing story. **Fix:** align story/endpoint sprints.
38. **Scope cut not reflected in the backlog** — the roadmap removed Rod Receiving (E03) + Planning/Scheduling (E04/E05) as upstream (14 stories), but `FlatWireJiraStories.md` still lists them Critical/High, Sprint 2–3. **Fix:** mark them upstream/out-of-scope in the backlog.

## Tier 5 — Check-in implementation docs stale

39. **Stale `--fw-*` design tokens** — `CheckinImplementationPlan/Prompt` hard-code a `--fw-*` system; the mockups and `flat-wire-shopfloor.styles.scss/.css` use `--color-*` semantic tokens. **[G18]** **Fix:** `--color-*`. **[P1✓ 1A]**
40. **Retired UI shape** — they port `dashboard_2_rod_checkin.html` (grid + progress-ring); the approved design is `dashboard_2_rod_checkin - New.html` (6-step tab-wizard). **Fix:** target the `- New.html` wizard. **[P1✓ 1A]**
41. **Forbidden reference library** — "copy patterns from `checkin-precheckin`"; foundations §0.2 + decision 5 forbid it. **Fix:** build fresh from mockups. **[P1✓ 1A]**
42. **Stale dates** — `CheckinImplementationPlan.md` Last Updated April 30 2026; fixtures 2026-04-29/30 (pre-replan).
43. **Auth inconsistency** — Plan uses `UAController`+`[Authorize]`; Prompt uses bare `ControllerBase`, no `[Authorize]`; `APIContracts.md` requires auth on `/checkin/rod`. **Fix:** `UAController`+`[Authorize]`. **[P1✓ 1B]**
44. **Inconsistent stub fixtures** — `PS-1100-FL2-001` vs `-007`; `SP-00021` source `RUN-0041` vs sourceRods `R00040/R00041`→`SP-00031`. **Fix:** one canonical fixture set (align to the DB seed).

## Tier 6 — Under-specified phases & coverage

45. **Phases 12/13/14 collapse the 9-section template** — Phase 12 & 13 have **no Acceptance criterion**; Phase 14 has no exit-test matrix beyond "three green E2E runs." **[G11 — which itself omits Phase 14]** **Fix:** expand to the full template with acceptance; correct G11 to 10/12/13/14.
46. **Digital traveler orphaned** — foundations declares the traveler "fully digital," but no phase owns building/storing/displaying it (only OQ-14). **Fix:** assign an owning phase/story.
47. **SignalR NFRs thin** — no backoff/re-subscribe-on-reconnect/mid-run token refresh/decimation SLA in the April docs (the roadmap §0.4 has them). Refresh-cadence contradiction: Dashboard-1 "~5s poll" (FW-060) vs continuous stream (FW-081). **Fix:** propagate §0.4 NFRs; resolve poll-vs-stream. **[P1✓ 1A/1B implement §0.4]**
48. **FW-080 event list incomplete** — omits `LineStatus`/`AlertRaised`/`AlertCleared` that command side-effects broadcast. **Fix:** complete the list. **[P1✓ 1A/1B]**

## Tier 7 — Doc hygiene (cosmetic)

49. **No change log** in `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`; stale `Last Updated` (Apr 29–30) and `Status: Draft` on all four.
50. **Table-count drift** — 20 (`FlatWireJiraStories.md:1466`) vs 21 (`back-matter.md`, post-`Rod`-drop) vs 22 (ERD); the roadmap change log is itself self-inconsistent (58/58 vs 44/44; 22 vs 21). *(With the new `RunReading` table the current count is **22**.)*
51. **E07 story-point total wrong** — summary says 65; the 14 stories sum to 67, so the grand total is 226 not 224.
52. **Undefined roles** — FW-004 "Process Engineering / System Admin" and `POST /rod` "Receiving" are not in the 5-role Authorization Matrix.
53. ~~**No document-control block on any of the 14 phase files** — no owner/version/change-log/effort.~~ **✅ ADDRESSED (Jul 30 2026)** — all **17** phase specs (`phase-01`, `01a`, `01b`, `01c`, `02`–`14`) now carry `Project` / `Last Updated` / `Status` / `Layer` / **`Owner`** / **`Effort`** / **`Scope call`**. Owner names a delivery **stream**; the named-owner roster is in [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §1 and is **still unfilled**. Per-phase change logs were **not** added (the roadmap index carries the shared change log).
54. **Residual dropped-`Rod` pointers** — `phase-08` still reads "`Spool→Rod(ParentRodAlpha)`"; DDL/ERD still say `united_db` and include the dropped `Rod` table. **[G12]**
55. **Load-bearing TBD placeholders** — die-life threshold (`phase-13`), trial/production dates (`phase-14`/`back-matter`); FW-050 pricing (OQ-2); FW-102 config.
56. **Path / cross-ref nits** — phases use short `/passschedule`, APIContracts uses `/api/v1/flatwire/…`; Appendix-C omits FW-068→Phase 2 and FW-054→Phase 13 from those phases' "Stories:" footers; `ShopfloorAndRealTimePlan.md` file name vs its "Master Implementation Roadmap" H1.

---

## Appendix — reconcile-up worklist (recommended)

Treat the July 26 roadmap as source of truth; align each April doc **up to** it. Recommendations only.

| April doc | Reconcile to the roadmap |
|---|---|
| `FlatWireJiraStories.md` | Timeline → **Aug 17 – Sep 30 2026**, production Q4 2026, **Phase 1 due 14 Aug 2026**; replace the 5-sprint model with the **14-phase** model + a sprint→phase crosswalk; mark the **14 upstream stories** (E03/E04/E05) out of shopfloor scope; fix the E07 point total (67) and the 20→**22** table count; add a change log; fix `IsActive`→`State{Active,Bypass,Skip}`. |
| `APIContracts.md` | Fix the `/passschedule/generate` example (Tier 1.1); add `RollAdjustTrigger` to `CheckpointType`; complete the hub event list; add alloy-lookup + override-revert endpoints; align the delivery schedule to phases (not S1–S5); add a change log. |
| `FlatWireTables.md` | Correct bare `decimal`→scaled `DECIMAL`; adopt the `FlatWireRun`/`FlatWireRunDetail` split; add `RunReading`; drop the dedicated `Rod` table (rod = `coils`); retarget `united_db`→`FlatWireDB`; add `SpoolCheckin`'s owner; add a change log. |
| `TechStackRecommendation.md` | Confirm the "new `FlatWireDB`" decision as final; reconcile "five SPC checkpoints" with the four-type enum; update Status from Recommendation; add a change log. |

---

## Change Log
| Date | Author | Change |
|---|---|---|
| 2026-07-26 | Review | Initial review of `DevelopmentPlan/`; Tiers 1–7 + reconcile-up appendix. Phase 1 split into 1A/1B/1C with the relevant fixes baked in. |
| 2026-08-06 | Review | **Tier 1 finding #1 escalated: the generate-from-specs *algorithm* is superseded, not only its worked example.** A gap audit of `LatestDocument/RequirementDocuments/PassScheduleGenerationSpec.md` (issued as v1.5) found `FR-381`, `FR-384`, `FR-385`, `FR-386` and `FR-387` wrong on the physics — bound-as-answer with no edge correction; snap-to-nearest against `R36`/`V39`; a positive fixed-multiplier roll gap where mill spring is negative and load-dependent; and the finishing-mill test conflated with route selection. Correcting `APIContracts.md`'s example to match them would have hardened the error. Arbitration published as `FlatWire_MasterSpecification.md` **§10.5**; a callout above finding #1 carries the one-line summary of each. **Contract shape is unaffected** — the envelope, `FR-389`, `FR-390` and `FR-391` stand. Note that this makes finding #1 a *symptom*: it stays open, but the fix is to rebuild the formula, not to re-derive the example. |
