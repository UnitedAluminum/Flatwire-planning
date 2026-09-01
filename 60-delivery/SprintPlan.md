# Flat Wire Mill — Sprint Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 18, 2026 — **`D-32`: there is no shared-schema migration.** The `FW-001` cross-feature impact and **RISK-05** are retired and replaced by the narrower **`OI-111`** *(previously August 15, 2026 — §9.2 DoD requires **`data-testid` on every element an automated test must reach**, the one E2E obligation that lands inside the trial window *(otherwise August 13, 2026 — split out of `05-SprintPlanAndBacklog.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*)*
**Document Type:** Capacity position, delivery model, sprint calendar, dependencies, DoR/DoD
**Status:** Published — **the plan does not fit the window; §1 requires a programme decision**
**Owner:** Delivery lead / programme management
**Audience:** Delivery lead, scrum team, programme management
**Shortcode:** `[SP]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

---

## 1. Capacity reality check — read this before the plan

> ### ⚠ The plan in this document is presented **as scoped**, and **as scoped it does not fit the window**.
>
> This is arithmetic, not judgement, and it is stated first because every other section depends on the decision it forces.

| Measure | Value |
|---|---|
| Total effort — **MVP-1** | **3,186 hours** = 398.3 dev-days (at 1 dev-day = 8 h) *(re-baselined 18 Aug 2026, `D-32`; previously 3,292 h)* |
| Working days available (Thu 30 Jul → 30 Sep) | **44** — of which **32 are post-gate** |
| Capacity per full-time person over the window | **352 hours** |
| **Sustained requirement** | **≈ 9.4 FTE** |
| Phase-1 gate (1,027 h in 12 working days) | **10.7 FTE on Phase 1 alone** |
| W7 (587 h in 3 working days) | **24.5 FTE — arithmetically impossible** |
| Recovery from the full descope ladder | **448 h = 12 %**, leaving ≈ 9.3 FTE |

**The full derivation, the roster, the rate card, the weekly capacity grid and the three options are owned by [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md).** This section states the conclusion; that document is where the arithmetic lives and is the only place either should be changed.

### 1.4 One scheduling consequence, independent of team size

**UAT cannot share W7 with feature work.** Phase 14's 267 h — including 112 h of QA and 40 h of UAT/BA — must be pulled into a dedicated window after feature-complete, whichever date that lands on. At no team size can stakeholder sign-off begin on the same day feature work completes.

### 1.5 Status

**Gap `G1` / open issue `OI-51`.** The effort model itself is **delivered**; the **escalation is the open item**, together with the unfilled roster in [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §1.

---

---

## 2. Delivery model

### 2.1 Fourteen phases, one of them layered

**Phase 1 is the only phase organised by technology layer** (1A Angular · 1B Backend · 1C Database, in parallel). **Phases 2–14 are complete vertical slices** — UI → API → business layer → database → real-time → dashboard — delivered in the sequence users experience the system. No phase is "the Angular phase" or "the database phase".

The canonical phrasing: **14 phases = 1 platform + 13 workflow phases (2–14).**

### 2.2 Why two phases were removed

**Rod Receiving** and **Order Planning & Line Scheduling** were originally planned as Phases 3 and 4 and have been **removed from the shopfloor build**. They are handled upstream by the existing CoilReceiving / Planning / Scheduling systems.

Their outputs remain **prerequisites consumed at Phase 4**:

| Removed phase | Now consumed at Phase 4 as |
|---|---|
| Rod Receiving | A rod row in the shared `coils` table with status `RECEIVED`/`STAGED`, carrying alloy, temper, diameter, weights, supplier heat and lot |
| Order Planning & Line Scheduling | A rod→order allocation in `planning_routings` and an order→line booking with operation letter `F` |

**If either upstream track slips, Phase 4 has no material and no scheduled job.** Their 14 stories are listed in §7.5 and are **not costed here**.

### 2.3 Stub-first

The shopfloor UI builds against dummy data first, via the two DI-swapped API implementations in `[API §7]`. This is what makes Phases 2–9 buildable in parallel with the backend, and it is why Phase 1's mock service and stub controllers are on the critical path.

**Schedule an explicit de-stub pass** when OI-46, OI-47 and OI-48 close — the stub deliberately routes around them by assuming a single active schedule, and that assumption will not remove itself.

---

---

---

## 3. Team model

**Six delivery streams — FE · BE · QA · RT · DB · BA.** Owner on every phase is a **stream, not a person**.

The stream table, the **unfilled roster** and the **unit-rate card** that prices every story in §7 all live in [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §1–§2. They were restated here until 13 Aug 2026 and are not restated any more: two copies of a rate card is how the hours drift.

**FE is the binding constraint** — roughly 35 % of all hours, and 6.0–6.5 FTE in every peak week.

---

---

## 4. Sprint calendar

### 4.1 The week grid

The week grid — working days per week, Labor Day inside W4, and the three-day W7 — is owned by [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §4. Both sprint cadences derive from it.

> **§4.2's `S0`–`S4` cadence was retired on 13 Aug 2026** in favour of the four even two-week sprints below, with **`S1` starting Mon 24 Aug**. That leaves the 17–21 Aug carry-over week outside every sprint rather than absorbing it, and merges the old `S3` and `S4`.

### 4.2 Sprints

Two-week cadence with **S1 starting Mon 24 Aug**. `S0` is the pre-window gate sprint, fixed by the hard 14 Aug Phase-1 gate. **The week of 17–21 Aug sits between S0 and S1 and is deliberately not a sprint** — it is Phase-1 carry-over, and the only week in the plan with zero planned load.

| Sprint | Dates | Wk days | Cap/person | Phases | Hours | Req. FTE |
|---|---|---|---|---|---|---|
| **S0** *(gate)* | Thu 30 Jul – Fri 14 Aug | 12 | 96 h | 1A, 1B, 1C | **1,027** | **10.7** |
| *— carry-over —* | *Mon 17 – Fri 21 Aug* | *5* | *40 h* | *Phase 1 completion* | **0** | *0.0* |
| **S1** | Mon 24 Aug – Fri 4 Sep | 10 | 80 h | 3 | **190** | **2.4** |
| **S2** | Mon 7 Sep – Fri 18 Sep | 9 | 72 h | 4, 5, 6, 7, 8 *(start)* | **971** | **13.5** |
| **S3** | Mon 21 Sep – Wed 30 Sep | 8 | 64 h | 8 *(finish)*, 9, 10, 11, 12, 13, 14 | **1,104** | **17.3** |
| | | **44** | **352 h** | | **3,292** | **9.4** sustained |

Derived from [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §3b's MVP-1 weekly grid by pairing weeks: `S1 = W2+W3` · `S2 = W4+W5` · `S3 = W6+W7`, with `W1` left unsprinted. **Labor Day (Mon 7 Sep)** is excluded from S2. Hours sum to 3,292 and working days to 44 with no leakage.

#### Three things this cadence produces

1. **The carry-over week is visible instead of buried.** Starting S1 on 24 Aug leaves 17–21 Aug outside every sprint, which is what §4 of the model already calls it: *"the only slack in the entire plan… the whole recovery budget, 200 person-hours at 5 FTE."* Had S1 started 17 Aug it would have absorbed that week and read **1.2 FTE**, hiding the one recovery buffer the plan has.
2. **S1 holds Phase 3 whole.** Phase 3 is a W2–W3 phase, so the pairing lands it cleanly in one sprint — the real-time backbone ships as a single sprint outcome rather than split across a boundary.
3. **S3 is seven phases in 8 working days**, including the sequential `8→9→10` chain and the whole of Phase 14 (three E2E route runs, PLC commissioning, UAT). At **17.3 FTE** it is the plan's largest risk and a direct consequence of the even cadence.

> ### S3's truncation is a choice, not an accident
> S3's natural two-week boundary is **Fri 2 Oct**; it is cut at **Wed 30 Sep** because that is the published **M5** feature-complete and **QA5** UAT date. Running it to its natural end costs **two days** and drops the peak from **17.3 to 13.8 FTE** — the cheapest schedule relief available anywhere in the plan, and cheaper than any rung of the descope ladder.

> ### The underlying finding is unchanged
> `CapacityAndEffortModel.md`'s headline stands: **3,186 h against 44 working days needs ~9.1 people sustained** *(`D-32`; previously 3,292 h / 9.4)*, and W7 — now inside S3 — needs **24.5 FTE against three days**. No sprint boundary makes that achievable. This document re-expresses the arithmetic; it does not solve it. See model §7 for the three options.

#### Divergence from `05-SprintPlanAndBacklog.md` §4.2

That file defines `S0`–`S4` on a phase-grouped cadence (S1 = W1–W3, S2 = W4–W5, S3 = W6, S4 = W7). **That model is retired** in favour of the even cadence above: this one has **four sprints, not five**, and §4.2's `S3` and `S4` are merged into this `S3`. §4.2's **entry/exit criteria, demos and gates are preserved** in the sprint sections below.

---


### 4.3 Post-window

| Event | Date | Note |
|---|---|---|
| PLC commissioning target | by **30 Sep 2026** | Until it completes, every line runs `SimulatePLCTagPush` + mock SignalR. **Development is not blocked; go-live is** |
| On-line trial | early **Oct 2026** | TBD with Tim O. / Shannon R. |
| Production | **Q4 2026** | After trial acceptance |

> **Superseded — do not use.** The April-dated documents carry "commissioning end of June 2026 · trials 1 July 2026 · production 1 August 2026 · ~10-week window · 5 sprints". **Every one of those is dead.** `05-SprintPlanAndBacklog.md`, `04-APIContract.md`, `FlatWireSchema_Mapping.md` and `03-HLD-and-ERDiagram.md` §14 still print them.

---

---

---

## 5. Phase table

The per-phase owner, hours, days and window table is owned by [`../00-overview/Roadmap.md`](Roadmap.md), which indexes the 15 phase specifications in [`Development/Phases/`](Phases/). It was duplicated here until 13 Aug 2026.

---

---

## 6. Dependency chain

### 6.1 Sequencing and the critical path

The prerequisite chain from [`../90-registers/Gaps.md`](../90-registers/Gaps.md), expressed sprint-to-sprint:

```
S0   Phase 1 (1A Angular · 1B Backend · 1C Database)  ── hard gate 14 Aug ──┐
                                                                            │
     [carry-over week 17-21 Aug: Phase 1 completion only]                   │
                                                                            ▼
S1   Phase 3 (line board + real-time backbone) ─────────────► consumed by 4,5,6,8,9
                                                                            │
S2   Phase 4 (rod check-in + DB2A staging) ◄── upstream rod + external pass schedule
       ├─► Phase 5 (active run + live trace) ─► Phase 6 (in-run events) ─► Phase 7 (WIP/checkout)
       └─► Phase 8 (FL2 spool check-in, starts)      [needs an FL1-produced spool]
       Phase 4 RodStaging ──► back-feeds Phase 3's "Payoff2 not loaded" alert
                          ──► Phase 6 (PCI008 weld default) · Phase 7 (Mode P)
                                                                            ▼
S3   Phase 8 (finishes) ─► Phase 9 (coil/label/skid) ─► Phase 10 (FL3 hybrid)
     Phases 11 · 12 · 13 (back-office, parallel) ── consume completed-run + reference data
     Phase 14 ── requires every critical-path phase ── LAST
```

**Must be sequential:** `4→5→6→7`, `8→9`, `9→10`, and `14` last. **Parallelisable:** Phase 6's five events by feature; Phases 11/12/13 against each other.

#### Dependencies that cross the MVP-1 boundary and are not satisfied here

| Story | Depends on | Which is |
|---|---|---|
| `FW-061` Dashboard 2 rod check-in *(Critical)* | `FW-020` R-series alpha generation | **Upstream** — built by the CoilReceiving team, deleted from this backlog. No rod alphas, no rod check-in |
| `FW-061`, `FW-082` PLC tag push *(both Critical)* | `FW-010` Pass schedule data model + API | **MVP-2** — [`FlatWireJiraStories-MVP2.md`](./FlatWireJiraStories-MVP2.md). MVP-1 only *reads* a schedule at check-in to build the push payload |

`PassScheduleId` is carried on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput` as a **documented external reference**, unenforced by design (`phase-01c` §Cross-DB logical FKs). Do not add a local FK or a stub table.

#### Known cross-sprint hazard — `G26`

**Dashboard 2A's *Mark as welded* button ships in Phase 4, but `POST /weldevent` is written in Phase 6.** Both land in S2, but Phase 4 completes first. `FW-N01` therefore ships against a **stub** and `FW-166` de-stubs it. The same applies to `GET /run/{runId}/weldevents`, which returns an empty array until Phase 6 — a legitimate state, stubbed with sample rows for the gate review.

---


### 6.2 Two corrections to the published graph

1. **`../90-registers/Gaps.md` draws Phase 8 → 9 → 10**, implying FL3 hybrid depends on the FL2 **spool check-in**. **It does not — FL3 has no intermediate spool.** FL3 depends on Phases 4, 5, 6 and 9. Corrected above.
2. **Phase 6 depends on Phase 13.** Die-change validation (`FR-233`) needs the die inventory that Die Management creates — and **no die master table exists anywhere in the schema**. Either pull a minimal die reference forward into Phase 6 or resequence. Unresolved — **OI-41**, drawn as a dashed back-edge above.

### 6.3 Shared building blocks — build once, reuse everywhere

| Asset | Built in | Reused by |
|---|---|---|
| `flat-wire-signalr.service` + `FlatWireHub` | 1 / 3 | 3, 5, 6, 7, 8, 9, 11 |
| `PLCTagService` (push / clear) | 1 / 4 | 4, 6, 7, 8, 10 |
| `pass-schedule-table` + `confirm-bar` | 2 / 4 | 2, 4, 8 |
| `gauge-trace-chart` (live + profile, one component) | 3 / 5 | 5, 8, 11 |
| `FlatWireRun` hub + event tables | 1 | all shopfloor phases |
| `CoilTraceability` genealogy | 9 | 9, 11 (Cut Traceability), 12 (yield) |
| Alloy lookup | 1 | 2 (generate), 9/12 (weight), 13 (admin) |

### 6.4 Parallelisable / sequential

**Parallelisable:** Phases 2 and 3 after Phase 1 (different streams — Ops-recipe UI versus real-time backbone), converging at Phase 4. Within Phase 6, the five events can be built in parallel by feature once Phase 5 exists. Phases 11/12/13 are parallel back-office tracks once run data exists.

**Must be sequential:** 2→4 · 4→5→6→7 · 8→9 · 9→10 · and **14 last**.

---

---

---

### 6.5 Feature dependency mapping

### Prerequisite chain (must be sequential)
```
Phase 1 (Platform: Angular scaffold + FlatWire service + FlatWireDB schema + FlatWireHub/OPC)
   │
   │   [EXTERNAL] Pass schedule — authored and approved by a SEPARATE TRACK, not by MVP-1.
   │   MVP-1 only READS one at check-in to build the PLC push payload. See phase-04,
   │   "The pass-schedule read contract". Phase 2 is wholly MVP-2 and is not in this chain.
   │
   └─> Phase 4 (Rod Check-in FL1/FL3 + Pre-Check-in/Dashboard 2A)  [also needs upstream rod + Phase 3 real-time]
             └─> Phase 5 (Active Run + live trace)
                  └─> Phase 6 (In-run events)
                       └─> Phase 7 (WIP/Checkout)
             └─> Phase 8 (FL2 spool check-in)  [needs an FL1-produced spool]
                  └─> Phase 9 (Coil completion/label/skid)
                       └─> Phase 10 (FL3 hybrid integration)
Upstream (external, existing systems: CoilReceiving + Planning/Scheduling)
   Rod Receiving + Order Planning/Line Scheduling ──> feed material + scheduled jobs into Phase 4
Phase 3 (Line board + real-time backbone) ──> consumed by Phases 4,5,6,8,9
Phase 4 RodStaging ──> back-feeds Phase 3 (the "Payoff2 not loaded" alert has no other data source)
                  └─> Phase 6 (PCI008: weld selection defaults to the staged rod)
                  └─> Phase 7 (Mode P pre-check-out; carry-forward gate moves to the staging scan)
Phases 11/12/13 ──> consume completed-run + reference data
Phase 14 ──> requires all critical-path phases
```

### Shared building blocks (build once, reuse everywhere)
| Shared asset | Built in | Reused by |
|---|---|---|
| `flat-wire-signalr.service` + `FlatWireHub` | Phase 1/3 | 3, 5, 6, 7, 8, 9, 11 |
| `PLCTagService` (push/clear) — surface in [`PLCTagSpecification.md`](../20-architecture/PLCTagSpecification.md), implementation in [`../20-architecture/PLCCommunication.md`](../20-architecture/PLCCommunication.md) | Phase 1/4 | 4, 6 (roll override), 7 (checkout), 8, 10 |
| `pass-schedule-table` + confirm-bar | Phase 2/4 | 2, 4, 8 |
| `gauge-trace-chart` (live + profile) | Phase 3/5 | 5, 8, 11 |
| `FlatWireRun` hub + event tables | Phase 1 | all shopfloor phases |
| `CoilTraceability` genealogy | Phase 9 | 9, 11 (Cut Traceability), 12 (yield) |
| Alloy lookup | Phase 1 | 2 (generate), 9/12 (weight), 13 (admin) |

### Parallelisable
- **Phase 3** follows Phase 1 directly and has no sibling to wait for — *Phase 2 has left MVP-1*, so W2–W3 now carry the real-time backbone alone (§3b of the effort model: 95 h a week, 2.4 FTE). Upstream rod receiving, planning/scheduling **and the pass-schedule track** proceed independently. They converge at Phase 4.
- Within shopfloor: Phase 6's five events can be built in parallel by feature once Phase 5 exists.
- **Phase 11/12/13** are parallelisable back-office tracks once run data exists.
- **Must be sequential:** 4→5→6→7, 8→9, 9→10, and 14 last. *(The old `2→4` edge is now an external dependency, not a phase edge.)* **Phase 6 no longer waits on Phase 13** — its die validation reads the `Drawer` catalogue seeded in Phase 1, not a die inventory (`REVIEW.md` #34 / `OI-41` closed).

### Cross-feature impacts / risks
- ~~**FW-001 column renames** touch the shared `coils`/scheduling schema well beyond flat wire — do early with full impact analysis (affects upstream receiving & planning + Phases 11, 12).~~ **RETIRED 18 Aug 2026, `D-32`: there is no shared-schema migration**, so this impact does not exist. What replaces it is narrower and is **`OI-111`** — nothing now marks a rod as being on a flattening line in the shared schema, so any report filtering `coils.coil_status` sees flat-wire material as untouched.
- **The pass schedule is still the hardest upstream gate — it has simply moved outside MVP-1.** No check-in works without one, and MVP-1 cannot create one. If the owning track does not deliver readable schedules before Phase 4, check-in has nothing to acknowledge and no tags to push: there is **no default schedule and no partial push path**. The read contract, including the unavailability behaviour, is in `phase-04`.
- **OQ-3 / OQ-14 / OQ-15** each block a specific screen build; the stub check-in deliberately routes around them (single-schedule assumption) — schedule a **de-stub pass** when these close.
- **OQ-10 (footage→weight)** blocks upstream planning + Phases 9, 12.

---

## 9. Definition of Ready / Definition of Done

### 9.1 Definition of Ready

A story may enter a sprint only when **all** hold:

- [ ] Its `FR-###` requirements in `[REQ §5]` are identified and none is blocked by an unresolved Critical `OI-##`.
- [ ] Its endpoint contract in `[API]` is published, including error codes and side effects.
- [ ] Its screen has an **approved** mockup, and the approved variant is named (notably DB2 = the 6-step wizard `dashboard_2_rod_checkin.html`, `- New.html` until 11 Aug 2026).
- [ ] Its data model exists in `FlatWireDB`, or its DDL change is in the same sprint.
- [ ] Acceptance criteria are written **Given / When / Then**.
- [ ] Its stream owner is assigned and has capacity in the sprint.
- [ ] Its dependencies (§6) are complete or in the same sprint with a stated sequence.

### 9.2 Definition of Done

A story is Done only when **all** hold:

- [ ] Code merged, reviewed, and building in the `build:shop-floor` chain (FE) or the `FlatWire.sln` (BE).
- [ ] **Angular: Jest unit + component tests at the 95 % coverage bar** (branches, functions, lines, statements).
- [ ] **.NET: no automated tests are required or expected** — decision of 15 Aug 2026, `[TS §1.2]`. In their place: **code review against `[API]`'s contracted shape and status codes**, and the manual test evidence on the next line. ⚠ **The asymmetry with the Jest bar above is deliberate.** Do not reinstate an xUnit requirement here without reversing that decision in `[TS]`.
- [ ] **Test evidence from `[TS]`:** every `TC-###` mapped to this story in `[TCS §10]` executes and passes, including at least one **negative/error-path** case and, where the story touches a role-gated action, one **permission** case.
- [ ] UI conformance checked against the mockup at **1280 × 1024 at 1:1** — no text below 14 px (bar the documented SVG-axis exception), tap targets ≥ 48 px, no hover-dependent action.
- [ ] ⚠ **`data-testid` on every element an automated test must reach** — every input, action button, status badge, numeric readout, table row and dialog root. **Kebab-case, prefixed by screen**: `fw-db2-scan-input`, `fw-db3-action-bar`, `fw-spc-submit-suspend`. **Stable across restyles** — it is a contract, not a class name, so never reuse a CSS class and never let a designer rename one.
  - **Why this is on the DoD and not in Phase 14.** The Playwright suite that consumes these hooks is **Phase 14**, but the screens are written **now**, in Phases 1A and 4–8. There are **zero** `data-testid` attributes in any mockup today. Added while a component is being written this costs minutes; retrofitted across ~14 screens and their dialogs afterwards it is **~16 h of FE rework** — and the retrofit lands on the phase least able to absorb it.
  - **Do not substitute CSS selectors, `id=`, or visible text.** A shopfloor UI is dense with numeric readouts and repeated controls; text-based selectors break on every wording change and `id=` is not reserved for testing. This bullet exists because the alternative is a suite nobody trusts.
- [ ] Real-time behaviour verified where the story emits or consumes hub events, **including reconnect**.
- [ ] Audit obligations verified where the story performs an override, a supervisor action, a pass-schedule change or a PLC write.
- [ ] No new `--fw-*` tokens, no reference to a forbidden library, no copied `SlitterInterface` pattern.
- [ ] Documentation touched: any contract change reflected in `[API]`; any new open item raised as `OI-##` or `PP-##`.

---

---

---

## 10. Risk and issue register

### 10.1 Risks carried from `[VS §11]`

| ID | Risk | Likelihood | Impact | Owner | Needed by |
|---|---|---|---|---|---|
| **RISK-01** | The 30 Sep date is unreachable as scoped — **9.4 FTE sustained and 24.5 in W7 for MVP-1** (10.4 / 27.2 both scopes), 12 % descope ceiling | Certain | Critical | Programme management | **Immediately** |
| **RISK-02** | Pass Schedule content still being authored by Operations; Phase 2 gates every check-in phase | High | Critical | Tim O. / Operations | Before W4 |
| **RISK-03** | Footage→weight basis undefined; the ±2 % variance threshold is unreachable from target dimensions | Medium | High | Tim O. / Process Eng | Before W6 |
| **RISK-04** | Cross-database check-in has no defined recovery path | High | Critical | Architecture / Jaspreet | Before W4 |
| ~~**RISK-05**~~ | ~~FW-001 renames break existing reports~~ — **RETIRED 18 Aug 2026, `D-32`.** Replaced by the narrower **`OI-111`**: no rename can break a report, but nothing marks flat-wire material in `coils.coil_status` either | — | — | DBA / IT | Before production |
| **RISK-06** | Roles may not exist as JWT claims | Medium | High | Security / Login owner | Before W0 completes |
| **RISK-07** | PLC commissioning slips past 30 Sep | Medium | High | Engineering / Tim O. | Go-live gate |
| **RISK-08** | Real-time NFRs undefined — the QA2 load test cannot fail | High | High | Architecture / Engineering | Before QA2 (13 Sep) |
| **RISK-09** | SignalR drops on the shopfloor network | Medium | Medium | Architecture | W4 |
| **RISK-10** | UAT shares a 3-day W7 with feature work | High | High | Programme management | Before W6 |
| **RISK-11** | Touch-screen usability on an unfamiliar screen set | Medium | Medium | UX / Operations | UAT |
| **RISK-12** | Phase 6 depends on Phase 13 die data; no die master table exists | Medium | Medium | Programme management | Before W5 |

### 10.2 Gaps register

The `G##` register is owned by [`../90-registers/Gaps.md`](../90-registers/Gaps.md). The blockers that stop specific stories are in §7.4.

### 10.3 Open issues by needed-by date

See §7.4, which lists them per story and per sprint, and the `OI-##` register in [`../10-requirements/MasterSpecification.md`](../10-requirements/MasterSpecification.md) §11.

---
