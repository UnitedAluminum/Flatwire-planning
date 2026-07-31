# Flat Wire Mill — Capacity & Effort Model

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 30, 2026
**Document Type:** Capacity & Effort Model (per-phase owners, effort in hours, working-day capacity)
**Status:** Published — **roster unfilled**; §1 must be completed by programme management
**Estimating unit:** **hours**. Day figures are derived (**1 dev-day = 8 h**) and shown only as a reading aid.
**Resolves:** Gaps register **G1** (Critical) · Master-spec open issue **OI-51** · `REVIEW.md` #31, #53
**Scope:** the 14 shopfloor phases in [`ShopfloorPlan/`](./ShopfloorPlan/). Upstream rod receiving and order planning/line scheduling are out of scope and are **not** costed here.

> ### ⚠ Headline finding
> The plan as specified is **3,727 hours** (465.9 dev-days). The window from today (Thu 30 Jul 2026) to the 30 Sep target contains **44 working days** — **352 hours per person**. That requires **≈10.6 people sustained**, and **27.2 people in W7**.
>
> **The 30 Sep date is not achievable at any plausible team size, and descoping cannot rescue it.** The full descope ladder in §5 recovers only **448 h (12%)**, leaving a **9.3-FTE** requirement. G1's own recommended mitigation — *"defer Phase 12 & non-critical 13"* — recovers **276 h**, worth about **0.8 FTE**. That is roughly an order of magnitude short of the gap.
>
> This document does not solve that. It makes it **arithmetic instead of adjective**, so the choice between *more people*, *less scope*, and *a later date* is made deliberately in July rather than discovered in late September. See §7 for the three options and what each costs.

---

## 0. Why this document exists

G1 and OI-51 record the same defect: 14 phases in ~6.5 weeks with **no capacity or effort model, no per-phase owner, and no effort estimate**. Verified before writing this:

- Zero occurrences of effort, hours, days, FTE, capacity or velocity anywhere in `ShopfloorPlan/`'s 19 files.
- No `Owner` on any phase file. Only `phase-01a/01b/01c` carried a doc-control block at all (`REVIEW.md` #53).
- The one quantified basis — `FlatWireJiraStories.md` — points 58 stories against the **dead 5-sprint model**, with no sprint→phase crosswalk (`REVIEW.md` #33).

**A note on the phase count.** OI-51 says *"thirteen workflow phases"*; G1 says *"14 phases"*. **Both are correct and neither is a drift.** `ShopfloorAndRealTimePlan.md` §0 defines Phase 1 as the layer-organised **platform** phase and Phases 2–14 as the **13 business-workflow phases**. The canonical phrasing, used throughout this document, is: **14 phases = 1 platform + 13 workflow phases (2–14)**.

---

## 1. Delivery streams and roster

Six streams, derived from the layers the phase files actually name.

| Code | Stream | Repo / surface | Hours | Share |
|---|---|---|---|---|
| **FE** | Angular | `ual-angular` → new library `flat-wire-shopfloor` (prefix `fw`) | **1,302** | 34.9% |
| **BE** | .NET | `ual-api` → new `FlatWire` microservice | **870** | 23.3% |
| **QA** | Test / E2E / UAT | all phases + Phase 14 | **621** | 16.7% |
| **RT** | Real-time / PLC | `FlatWireHub`, OPC ingest, `PLCTagService` | **432** | 11.6% |
| **DB** | SQL Server | new `FlatWireDB` + the shared-schema FW-001 renames | **418** | 11.2% |
| **BA** | BA / Ops liaison | pass-schedule content, OQ closure, UAT coordination | **84** | 2.3% |
| | | **Total** | **3,727** | 100% |

Stream hours **include each stream's pro-rata share of contingency**, so the column sums exactly to 3,727. §3 shows the same total with contingency broken out as its own column.

**FE is the binding constraint** — 35% of all hours, and 6.0–6.5 FTE in every peak week.

### Roster — **to be completed by programme management**

This is the one table this document cannot fill. Until it is filled, §4's gap column cannot be computed and **G1 remains partly open**.

| Stream | Named owner | FTE | Hours available in window | Available from | Absence (PTO/holiday/split allocation) |
|---|---|---|---|---|---|
| FE — Angular lead | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| FE — Angular dev(s) | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| BE — .NET lead | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| BE — .NET dev(s) | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| DB — SQL / data | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| RT — real-time / PLC / OPC | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| QA | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |
| BA / Ops liaison | *TBD* | *TBD* | *TBD* | *TBD* | *TBD* |

One full-time person available for the whole window contributes **352 h** (44 working days × 8 h). Pro-rate for later start dates and absence. Every phase file's `**Owner:**` line names a **stream**, not a person, and points here.

`TechStackRecommendation.md` asserts only that *"the team is already Angular/.NET"* — it never states team size, which is precisely the hole G1 identifies.

---

## 2. Estimating basis — the unit-rate card

The unit is **hours**. Story points are deliberately **not** the unit; see the cross-check in §3.

No prior estimate of any kind exists, so the estimate is **derived, auditable and re-runnable** rather than asserted: each phase's effort is built from the deliverable inventory that phase already publishes (its `- **Screens:**`, `- **Components:**`, `- **APIs:**` and `## Database Changes` / `## Real-Time Functionality` bullets), priced with the rate card below.

| Unit | Hours | Notes |
|---|---|---|
| New dashboard screen | **24 h** | `Mockups/*.html` is the approved visual spec — no design time included |
| Screen variant (FL2/FL3 mode of an existing screen) | **8 h** | |
| Modal / dialog | **12 h** | |
| Shared composite control | **20 h** | `pass-schedule-table`, `gauge-trace-chart`, `tolerance-viz`, `tab-wizard`, `action-bar`, `payoff-weight-bar` |
| Shared primitive control | **8 h** | `.input` states, monospace readouts, pass/fail buttons, `alert-banner` |
| Command endpoint (MediatR + FluentValidation + unit test) | **6 h** | `API/Domain/CoilCheckin` is the template (Foundations §0.2) |
| Query endpoint | **4 h** | |
| Non-trivial business service / algorithm | **12–24 h** | priced individually; shown in §3's derivations |
| Table (DDL + FK + index + EF mapping + repository) | **4 h** | |
| Stored proc / reporting view | **8 h** | |
| Report | **8 h** FE + **8 h** BE | extends the existing `Reports` service |
| New hub event (typed contract + publisher + subscriber) | **8 h** | Foundations §0.4 |
| PLC tag group push + compensating clear | **16 h** | |
| **QA uplift** | **+20%** of FE+BE+DB+RT | suppressed in Phase 14, which *is* the QA phase |
| **Contingency** | **+15%** of (base + QA) | stated once, not hidden per line |

Two discrete line items that are **not** rate-card units:

| Discrete item | Hours | Where |
|---|---|---|
| FW-001 shared-schema rename **impact audit** | **40 h** | Phase 1C |
| Hub load test (N clients × 3 lines × cadence) | **16 h** | Phase 3 |

### Two costs the inventory does not capture

Both are added as explicit lines, because omitting them is how the plan under-read its own size in the first place.

1. **FW-001 shared-schema rename audit — 40 h, in Phase 1C.** The `Coil/Bundle…` slash-dual renames (`CoilNo`, `SlitWidth`, `CoilStatus`, `OutgoingCoilId`, …) land on the **shared** `coils`/scheduling schema, which the legacy `ual-dot-net` applications and existing reports also read. `phase-01c` itself flags *"high blast radius; front-load the impact audit."* The rename is 16 h; the SP/view/report impact audit across `united_db` and the legacy tier is a separate 40 h.
2. **Cross-DB check-in recovery (G2 / OI-39) — a 24–64 h reserve on Phase 4, not in the total.** Check-in spans `FlatWireDB` + shared `coils`/`wip_coil_orders` + the PLC and is **not one ACID transaction**. Neither candidate (saga/outbox with compensating PLC clears, or an `INFLAT` mirror in `FlatWireDB`) has been chosen. **Phase 4's estimate is provisional until OI-39 closes.**

A third, smaller reserve: **OQ-36 / OI-45 (footage→weight) — 16–32 h on Phase 9.** The formula is settled but the *dimensional basis* (target vs measured-at-completion vs integrated over `RunReading`) is not, and the integration option is materially more work than the other two.

---

## 3. Per-phase effort

All figures in **hours**. `Cont` = contingency. The `Days` column is derived (hours ÷ 8) and is a reading aid only.

> **Rounding convention — every figure printed here is the figure used.** Each cell is a whole number of hours, and each row total is the sum of its own printed cells. There is no "figures may not sum due to rounding" caveat: **every row adds up exactly as shown, and so does every column.** Verify any row by hand.

| Phase | Stream owner | FE | BE | DB | RT | QA | BA | Cont | **Hours** | Days | Window | Deferrable |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **1A** Angular Foundation | FE | 224 | — | — | 44 | 54 | — | 48 | **370** | 46.2 | W0 | No |
| **1B** Backend Foundation | BE + RT | — | 208 | — | 112 | 64 | — | 58 | **442** | 55.2 | W0 | No |
| **1C** Database Foundation | DB | — | — | 156 | — | 31 | — | 28 | **215** | 26.9 | W0 | No |
| **2** Pass Schedule Management | FE + BE | 80 | 62 | 12 | — | 31 | 16 | 30 | **231** | 28.9 | W2–W3 | No |
| **3** Line Status Board & Real-Time Backbone | RT + FE | 64 | 16 | 4 | 40 | 41 | — | 25 | **190** | 23.8 | W2–W3 | No |
| **4** Rod Check-In & PLC Config | FE + BE + RT | 60 | 62 | 28 | 28 | 36 | 8 | 33 | **255** | 31.9 | W4 | No |
| **5** Active Run Monitoring & Gauge Trace | FE | 116 | 12 | 8 | 24 | 32 | — | 29 | **221** | 27.6 | W4 | Partly — DB13/14 |
| **6** In-Run Production Events | FE + BE | 120 | 56 | 20 | 20 | 43 | — | 39 | **298** | 37.2 | W5 | No |
| **7** WIP Rejection & Rod Checkout | FE + BE | 64 | 40 | 28 | 16 | 30 | — | 27 | **205** | 25.6 | W5 | No |
| **8** FL2 Spool Check-In & Finishing Run | FE + BE | 48 | 18 | 12 | 8 | 17 | — | 15 | **118** | 14.8 | W5–W6 | No |
| **9** Output Coil Completion & Packing | FE + BE | 104 | 26 | 16 | 8 | 31 | 8 | 29 | **222** | 27.8 | W6 | No |
| **10** FL3 Hybrid Continuous Operation | BE + FE | 12 | 20 | 4 | 8 | 9 | — | 8 | **61** | 7.6 | W6 | No — core route |
| **11** Shift Summary, Reporting & Certification | BE + FE | 64 | 76 | 28 | 4 | 34 | 8 | 32 | **246** | 30.8 | W6 | Partly — 4 of 5 reports |
| **12** Yield, Cost Ledger & Scrap | BE | 44 | 72 | 12 | — | 26 | — | 23 | **177** | 22.1 | W7 | **Yes — whole phase** |
| **13** Administration & Reference Data | FE + BE | 80 | 48 | 16 | 4 | 30 | 4 | 27 | **209** | 26.1 | W7 | Partly — Die Mgmt, roles |
| **14** Integration Testing, PLC Commissioning & Go-Live | QA + BA | 16 | 16 | 8 | 40 | 112 | 40 | 35 | **267** | 33.4 | W7 | No |
| | **TOTAL** | **1,096** | **732** | **352** | **356** | **621** | **84** | **486** | **3,727** | **465.9** | | |

The `TOTAL` row is the **raw column sum** with contingency in its own column: 1,096 + 732 + 352 + 356 + 621 + 84 + 486 = **3,727**. §1 and §4 instead report each stream **with its pro-rata share of contingency folded in** (FE 1,302 · BE 870 · QA 621 · RT 432 · DB 418 · BA 84), because capacity planning needs the all-in figure per stream. Both views total 3,727.

**Roll-ups:** Phase 1 (1A+1B+1C) = **1,027 h** (128.4 d) · Phases 2–14 = **2,700 h** (337.5 d) · grand total = **3,727 h**.
**Largest phases:** 1B (442) · 1A (370) · 6 (298) · 14 (267) · 4 (255). **Smallest:** 10 (61) · 8 (118).
**Reserves excluded from the total:** G2/OI-39 on Phase 4 (**24–64 h**) · OQ-36/OI-45 on Phase 9 (**16–32 h**).

### Worked derivation — Phase 4 (reproduce this shape for any phase)

> **FE 60 h** — Dashboard 2 `dashboard_2_rod_checkin - New.html` as a 6-step tab wizard with tolerance-viz, OK/NG/NA machine inspection and supervisor override (36 h, above the 24 h base rate for the wizard's six steps) + Dashboard 2A pre-check-in (24 h). `payoff-option` cards and `confirm-bar` are already built in 1A/Phase 2.
> **BE 62 h** — `POST /checkin/rod` as a complex command spanning two databases and the PLC (20 h) + `PayoffStagingController`'s 3 commands (18 h) and 2 queries (8 h) + `CheckInRod` service and validation rules (16 h).
> **DB 28 h** — new `RodStaging` table (4 h) + repository/EF writes across `RodCheckin`, `FlatWireRun`, `SpcCheckpoint`, `SpcMeasurement`, `RodCheckout` (16 h) + the cross-DB `coils → INFLAT` write (8 h).
> **RT 28 h** — new `PayoffStateChanged` domain event, sent immediately and unbatched per §0.4 (8 h) + `LineStatus`/`ComponentStatus` broadcast on success (4 h) + PLC tag group push with compensating clear (16 h).
> **BA 8 h** — closing OQ-14 (traveler field list), OQ-46/51 (no-match path).
> **QA** +20% of the 178 h dev base = 36 h · **Contingency** +15% of (178 + 8 + 36) = 33 h → **Total 255 h** (60 + 62 + 28 + 28 + 36 + 8 + 33), plus the 24–64 h G2 reserve.

### Cross-check against the April story points — and what the divergence reveals

The April backlog puts the **44 shopfloor stories at 184 points** (226 − 42 upstream; FW-054 stays in shopfloor Phase 13). Against 3,727 h that is **20.3 h/point** — about 2½ days per point, roughly double a conventional ~1 day (8 h) per point. The divergence exceeds the 25% investigation threshold, so it was investigated. Two causes, both real:

1. **The backlog has no story for most of Phase 1.** Epic E01 "Foundation & Infrastructure" is 7 stories / 28 points, and **all seven are database stories** (FW-001 renames, FW-002 `INFLAT`, FW-003 machines, FW-004 alloys, FW-005/006/007 tables). There is **no story anywhere in the 58** for scaffolding the `flat-wire-shopfloor` Angular library, for creating the `FlatWire` .NET solution and its 13 controllers, or for the OPC ingest and `PLCTagService`. Phase 1 is **1,027 h** against ~28 points of nominal coverage. **This is a backlog gap, not an estimating error** — and it is the single largest reason the window was believed to fit.
2. **Excluding Phase 1, the ratio is 2,700 h / 156 points = 17.3 h/point.** For touch-screen shopfloor dashboards built to mockup fidelity, with a full vertical slice (UI + MediatR command + validation + DDL + hub event + tests) per phase, ~17 h/point is the more defensible figure. Phase 6 is the clearest illustration: 4 full dashboards + 2 dialogs + 6 endpoints + 5 write tables was sized at 19 points ≈ 152 h if a point is a day — i.e. under 30 h per dashboard *including* backend, database and test. The model prices it at 298 h.

**The rate card in §2 is the single calibration knob.** If the team's measured throughput at the Phase-1 gate is better than these rates, rescale §2 and re-publish §3/§4 — see §6.

---

## 4. Capacity model

`required FTE = stream-hours scheduled that week ÷ (working days that week × 8 h)`

Working days are counted, not assumed. **Labor Day falls on Mon 7 Sep 2026**, inside W4, and W7 holds only 3 days.

| Week | Dates | Wk days | Capacity / person | FE | BE | DB | RT | QA | BA | Hours | **Peak FTE** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **W0** | to **Aug 14** | 12 | 96 h | 2.8 | 2.6 | 1.9 | 1.9 | 1.6 | — | 1,027 | **10.7** |
| W1 | Aug 17–21 | 5 | 40 h | — | — | — | — | — | — | 0 | **0.0** ← only slack in the plan |
| W2 | Aug 24–28 | 5 | 40 h | 2.2 | 1.2 | 0.2 | 0.6 | 0.9 | 0.2 | 210 | **5.3** |
| W3 | Aug 31–Sep 4 | 5 | 40 h | 2.2 | 1.2 | 0.2 | 0.6 | 0.9 | 0.2 | 210 | **5.3** |
| W4 | Sep 8–11 | **4** | **32 h** | 6.5 | 2.7 | 1.3 | 1.9 | 2.1 | 0.2 | 476 | **14.9** |
| W5 | Sep 14–18 | 5 | 40 h | 6.1 | 3.1 | 1.6 | 1.2 | 2.0 | — | 562 | **14.1** |
| W6 | Sep 21–25 | 5 | 40 h | 6.0 | 3.9 | 1.6 | 0.7 | 2.1 | 0.4 | 588 | **14.7** |
| W7 | Sep 28–30 | **3** | **24 h** | 7.1 | 6.9 | 1.9 | 2.6 | 7.0 | 1.8 | 653 | **27.2** |

The `Hours` column sums to **3,727** — the grand total, allocated with no leakage. Phases spanning two weeks are split evenly (Phase 2 and 3 across W2/W3; Phase 8 across W5/W6). Phase 1 is allocated wholly to **W0** because the Aug-14 gate is hard; W1 therefore shows zero planned load.

**Post-gate window (W1–W7) = 32 working days = 256 h/person.** Whole window inclusive of Thu 30 Jul = **44 working days = 352 h/person**.

### Sustained requirement, and the gap table

Over the full 44 working days, one full-time person contributes **352 h**:

| Stream | Hours (incl. contingency) | Sustained FTE | Available hours | **Gap** |
|---|---|---|---|---|
| FE | 1,302 | **3.7** | *TBD* | *TBD* |
| BE | 870 | **2.5** | *TBD* | *TBD* |
| QA | 621 | **1.8** | *TBD* | *TBD* |
| RT | 432 | **1.2** | *TBD* | *TBD* |
| DB | 418 | **1.2** | *TBD* | *TBD* |
| BA | 84 | **0.2** | *TBD* | *TBD* |
| | **3,727** | **10.6** | *TBD* | *TBD* |

The `Available` and `Gap` columns compute themselves the moment §1's roster is filled. **This plan assumes ~10.6 concurrent people and 3,727 hours. It has never said so.**

### Sensitivity — what "one hour" means

The rate card is authored on **calendar hours**: one dev-day is one working day of a person's paid time, normal meeting/email/context-switch overhead already absorbed. On that reading, capacity is 8 h/day and the requirement is 10.6 FTE.

If your organisation instead tracks **hands-on-keyboard hours** — i.e. you would book these 3,727 h against productive time only — divide by realistic productive hours per day:

| Effective productive h/day | Hours per person over 44 days | **Required FTE** |
|---|---|---|
| 8.0 *(calendar reading — this model's default)* | 352 | **10.6** |
| 7.5 | 330 | **11.3** |
| 7.0 | 308 | **12.1** |
| 6.5 *(common industry norm)* | 286 | **13.0** |
| 6.0 | 264 | **14.1** |
| 5.5 | 242 | **15.4** |

**Pick one reading and state it before comparing against a roster** — mixing them either double-counts overhead or hides it. Every other figure in this document uses the 8 h calendar reading. If the team books time at ~6.5 productive h/day, the real requirement is **13 people, not 10.6**, and every conclusion below gets worse, not better.

### What the model predicts will fail

1. **The Aug-14 Phase-1 gate.** 1,027 h in 12 working days (96 h/person) needs **10.7 FTE on Phase 1 alone**, of which 2.8 FE and 2.6 BE are on the critical path. 1A/1B/1C genuinely parallelise, so this is not a sequencing problem — it is a headcount problem.
2. **W7 is arithmetically impossible.** 653 h in 3 working days (24 h/person) = **27.2 FTE**. W7 carries Phase 12 + Phase 13 + Phase 14, and Phase 14 alone is three E2E route runs, PLC commissioning support, renamed-column regression, **and** full UAT with stakeholder sign-off. UAT cannot start on the same day feature work completes.
3. **W4–W6 run at ~14–15 FTE** with FE peaking at 6.0–6.5 — roughly triple the FE load of W2/W3. FE is the binding constraint in every peak week, at 35% of all hours.
4. **W1 is the only slack in the entire plan** (5 working days, no planned load). It exists solely because the Aug-14 gate supersedes the roadmap's original W1. It is the whole recovery budget — **200 person-hours at 5 FTE.**

### Inverse: what date each team size actually lands

All 14 phases, starting Thu 30 Jul 2026, weekends and US holidays excluded, at 8 h/person/day.

| Team (FTE) | Capacity | Working days | Finish | vs 30 Sep |
|---|---|---|---|---|
| 4 | 32 h/day | 117 | Mon 18 Jan 2027 | +110 days |
| 5 | 40 h/day | 94 | Mon 14 Dec 2026 | +75 days |
| 6 | 48 h/day | 78 | Wed 18 Nov 2026 | +49 days |
| 8 | 64 h/day | 59 | Thu 22 Oct 2026 | +22 days |
| 10 | 80 h/day | 47 | Tue 6 Oct 2026 | +6 days |
| **11** | 88 h/day | 43 | **Wed 30 Sep 2026** | **on target** |
| 12 | 96 h/day | 39 | Thu 24 Sep 2026 | −6 days |
| 14 | 112 h/day | 34 | Thu 17 Sep 2026 | −13 days |

---

## 5. Descope ladder

Pre-agreed and ordered, so descoping is a decision already taken rather than an improvisation on 29 Sep. Each rung carries the same QA and contingency uplift as §3, so the hours are directly comparable.

**Rungs 1–4 are all inside Phase 12** — FW-110, FW-102 and FW-101 are Phase-12 stories, so rung 4 is the **remainder** of the phase, not the phase again. The cumulative column is therefore additive with no double-counting.

| # | Rung | Hours | Cumulative | What is lost | Sign-off | Latest call |
|---|---|---|---|---|---|---|
| 1 | FW-110 Scrap Box/Skid outlet (Low) | 33 | 33 | Scrap routed manually post-go-live | Ops | W6 |
| 2 | FW-102 Cost Ledger config (Medium) | 49 | 82 | No flat-wire cost standards; costing reports blank | Cost accounting | W6 |
| 3 | FW-101 Weld traceability in yield (High) | 28 | 110 | Yield not attributed per source rod — **welding-wire certs affected** | Tim O. / Quality | W6 |
| 4 | Remainder of **Phase 12** (footage-based weight + yield form) | 67 | **177** = whole of Phase 12 | No footage-based yield at go-live | Programme | W6 |
| 5 | Phase 13 non-critical (Die Management screen, role assignment UI) | 99 | 276 | Die life tracked on paper; roles assigned by DBA | Maintenance / IT | W6 |
| 6 | Phase 11 reports FW-092/093/094/095 (4 of 5) | 105 | 381 | Only the Gauge Trace report ships; CPK/SPC/traceability reports deferred | Tim O. / Quality | W5 |
| 7 | DB13 HMI schematic + DB14 SCADA trends (Phase 5) | 67 | **448** | Operators lose the schematic and trend views; run cockpit (DB3) unaffected | Engineering | W4 |
| — | *Phase 10 FL3 hybrid* | *61* | — | **Not deferrable** — FL3 is one of the three production routes | — | — |

**The ladder is not enough.** Rungs 1–7 recover **448 of 3,727 hours — 12%** — leaving **3,279 h, still 9.3 FTE** over 44 working days. G1's own stated mitigation is rungs 1–5 (defer Phase 12 entirely plus non-critical Phase 13): **276 h ≈ 0.8 FTE**, against a shortfall measured in whole people.

Rungs 6 and 7 are **new to the ladder** and are the model's own additions: Phase 11's seven stories cannot co-exist with Phases 8, 9 and 10 in W6 at any credible team size, and DB13/DB14 are the largest genuinely-optional FE items in the critical-path phases.

Below rung 7 there is nothing left that is not a production route, a check-in path, or the traveler — i.e. every remaining rung would cut something the mill cannot run without. **That is the finding: scope is not where the 30 Sep date can be recovered.**

---

## 6. Calibration checkpoint

This model is a derivation from a rate card, not a measurement. It becomes trustworthy only once measured against real throughput, and the **Aug-14 Phase-1 gate is the calibration point**:

1. Record **actual hours** for 1A, 1B and 1C against the estimates (**370 / 442 / 215 h**).
2. Compute the variance per stream and restate the §2 rate card.
3. Re-publish §3 and §4 with the corrected rates, and re-run §4's inverse table.
4. Confirm which hour definition the recorded actuals use (calendar vs hands-on-keyboard) and lock the §4 sensitivity row that matches.
5. Record the revision in the Change Log.

Because the gate is 12 working days away and the model says Phase 1 needs 10.7 FTE, the *first* calibration signal will arrive well before 14 Aug: if Phase 1 is not booking on the order of **500 hours in its first week**, the §4 conclusions are confirmed and §7's decision cannot wait for the gate.

---

## 7. The decision this model forces

Three options. They are not mutually exclusive, and doing none of them is itself a choice — the one G1 calls *"silent scope loss."*

| Option | What it means | Cost / consequence |
|---|---|---|
| **A — Staff to the plan** | ~11 concurrent people (**88 h/day**) across the six streams, from W0 | The only option that holds 30 Sep. Requires ~3.7 FE, ~2.5 BE, ~1.8 QA, ~1.2 RT, ~1.2 DB, ~0.2 BA. Ramp-up time is **not** in the 3,727 h. |
| **B — Move the date** | Keep a realistic team; publish the date the model gives | At 6 FTE (48 h/day) → **18 Nov 2026**; at 8 FTE (64 h/day) → **22 Oct 2026**. Both land inside the already-planned Q4 2026 production window. |
| **C — Cut scope to the critical path** | Full descope ladder (§5) plus a further decision on which of Phases 11/13 ship at all | Recovers only **12%** (448 h), leaving 3,279 h ≈ 9.3 FTE. **Insufficient alone**; must be combined with A or B. |

**Recommendation: B, combined with C's rungs 1–4.** The Q4 2026 production target already sits past 30 Sep, so an Oct 22–Nov 18 feature-complete date does not move the business outcome, whereas Option A's ~11 concurrent people has no evidence of being available and Option C alone cannot close the gap. This is a programme-management decision, not an engineering one — it is recorded here so it is made on numbers.

A separate scheduling consequence, independent of team size: **UAT cannot share W7 with feature work.** Phase 14's 267 h — including 112 h of QA and 40 h of UAT/BA — should be pulled into a dedicated window after feature-complete, whichever date that lands on.

---

## 8. Assumptions and known estimate risks

- **Hour definition:** one dev-day = **8 h** of a person's working day, normal overhead absorbed (the "calendar" reading). See §4's sensitivity table for the hands-on-keyboard alternative, which raises the requirement to 13–14 FTE.
- **Other assumptions:** no ramp-up or onboarding time; mockups in `Mockups/` are final so no UI design time is costed; `Mockups/flat-wire-shopfloor.styles.scss` is consumed as-is with no token migration (G18); the `CoilCheckin` backend template is directly reusable (Foundations §0.2).
- **Phase 4 is provisional** until OI-39 / G2 (cross-DB check-in recovery) is decided — **24–64 h reserve**.
- **Phase 9 is provisional** until OI-45 / OQ-36 (footage→weight basis) is decided — **16–32 h reserve**. Integrating over `RunReading` is materially more work than a target-derived weight.
- **Phase 12 is provisional** — OQ-3 (costing), OQ-5 (standard times) and OQ-35 (yield per route) are all open; it is also rungs 1–4 of the ladder.
- **Phase 3 carries a 16 h hub load test** whose pass criteria do not exist. G9 / OI-34 records that the NFRs (AGC sample rate, concurrent clients, latency budget, `RunReading` retention) are undefined. If the load test fails, the real-time rework is **not** in this model.
- **Die inventory has no table.** Phase 13 requires die inventory with cumulative footage, life thresholds and status `Active/Nearing/Overdue/Spare/Retired`, but the `FlatWireDB` table set has only the `Drawer` lookup and `DieChangeEvent` — no die master. 8 h is costed for it here, but this is a **schema gap not yet in the gaps register** and is raised for a decision separately from this document.
- **Table-count drift is unresolved** (`phase-01c` says 22; G12 says DDL/ERD agree at 27). 1C is costed against the 22 the phase file states; each additional table is **4 h** plus its share of QA and contingency (~5.5 h all-in).
- Upstream stories (rod receiving, order planning, line scheduling — 14 stories, 42 points) are **out of scope here** and are staffed by their own teams. If those slip, Phase 4 has no material and no scheduled job.

---

## Related Documents

| Document | Purpose |
|---|---|
| [`ShopfloorAndRealTimePlan.md`](./ShopfloorAndRealTimePlan.md) | Master roadmap index — carries the per-phase Owner/Effort summary |
| [`ShopfloorPlan/back-matter.md`](./ShopfloorPlan/back-matter.md) | Week grid, milestones, risks, gaps register (G1) |
| [`ShopfloorPlan/phase-*.md`](./ShopfloorPlan/) | Per-phase `Owner:` / `Effort:` doc-control blocks and the deliverable inventories this model prices |
| [`FlatWireJiraStories.md`](./FlatWireJiraStories.md) | The April 5-sprint backlog — source of the 184-point cross-check only; **not** a schedule |
| [`REVIEW.md`](./REVIEW.md) | Audit findings #31 (calendar conflict) and #53 (no doc-control block) |
| `LatestDocument/FlatWire_MasterSpecification.md` | §9.4 week grid, §9.5 backlog, §11.1 OI-51 |

## Change Log
| Date | Changed By | Description |
|------|-----------|-------------|
| Jul 30, 2026 | Plan team | **Re-authored the whole model in hours** at the stated rate **1 dev-day = 8 h**, per request for the complete estimation in hours. Hours are now the **authored unit** and every component is a whole number of hours, so each row and column sums exactly as printed; day figures are derived (hours ÷ 8) and shown only as a reading aid. Grand total **3,727 h (465.9 d)**; Phase 1 **1,027 h**; Phases 2–14 **2,700 h**. Converted the rate card, per-phase table, weekly capacity, gap table, descope ladder, inverse table, calibration targets and §7 options; added per-person capacity columns (**352 h** over the window; 96 h in W0, 40 h/full week, 32 h in W4, 24 h in W7), a stream-share table in §1 (FE is **35%** of all hours), and a new **§4 hour-definition sensitivity** table — on a hands-on-keyboard reading at 6.5 productive h/day the requirement rises from **10.6 to 13.0 FTE**. Whole-hour rounding moved a few derived day figures by ≤0.2 d against the first publication (e.g. Phase 3 23.7→23.8, Phase 9 27.6→27.8; grand total 465.6→465.9 d); the hours are authoritative. **Every conclusion is unchanged** — 10.6 sustained FTE, 10.7 at the Phase-1 gate, 27.2 in W7, a 12% descope ladder, and the same finish dates by team size — which cross-validates both derivations. |
| Jul 30, 2026 | Plan team | **Initial publication — resolves G1 / OI-51.** Defined six delivery streams + an unfilled roster (§1); published a unit-rate card driven off each phase's existing deliverable inventory (§2); derived per-phase effort for all 17 phase specs (§3); built a working-day capacity model showing **10.6 sustained FTE**, a 10.7-FTE Phase-1 gate and an impossible 27.2-FTE W7 (§4); ordered a descope ladder and showed it recovers only **12%**, leaving 9.3 FTE (§5), after correcting an initial double-count in which rungs 1–3 (FW-110/102/101, all Phase-12 stories) were added on top of "Phase 12 entire" rather than being carved out of it; set the Aug-14 gate as the calibration point (§6); and stated the three options the arithmetic forces (§7). Corrected the working-day count to **32 post-gate / 44 total** by deducting **Labor Day (Mon 7 Sep 2026)** and the 3-day W7. Recorded that "thirteen workflow phases" (OI-51) and "14 phases" (G1) are both correct — 1 platform + 13 workflow phases. Documented two costs the inventory omitted (FW-001 rename audit; G2 recovery reserve) and the finding that **epic E01 contains no story for the Angular or .NET scaffold**, which is why the window was believed to fit. |
