# Flat Wire Mill — Capacity & Effort Model

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 25, 2026 — **new §3f — `FW-224`, additive and deliberately unsized** (blocked on `Q41`); `3,358 h` established as the one citable all-in figure; object count 34 → 33 *(previously August 18, 2026 — **new §3d: `FW-219`, the FL2/FL3 run-end write-back, +77 h all-in (56 h base / 40 h AI-assisted), additive.** MVP-1 becomes **3,263 h** and both scopes **3,631 h** — ⚠ **superseded the same day by §3e (rod ↔ order, +116 h): the live all-in is `3,358 h`, in §3e's roll-up row, which is the only site that may assert it**; §3, §3b and §3c are **not** re-derived. Phase 9's published 222 h is unchanged and understates by 77 h — quote `222 + 77`. *(Earlier same day: **new §3c: the `D-32` re-derivation.** The shared-schema migration is cancelled (`FW-001`, `FW-002`, and `FW-176`'s shared-`coils` columns), **−76 h base / −106 h all-in**: Phase 1C **221 → 138 h**, Phase 7 **205 → 182 h**, MVP-1 **3,292 → 3,186 h**, both scopes **3,660 → 3,554 h**. ⚠ **§3 and §3b are deliberately NOT re-derived and remain the base of record** — §3c is additive, per the pattern in `[DE]` and `[YCS]`. *(Previously August 13, 2026 — §3's story-point cross-check marked **historical** (its denominator was retired when the backlog moved to hours) and its finding 1 recorded as **closed**; Related-Documents row re-pointed. *(Earlier same day: resolved-correction narrative removed to [`../CHANGELOG.md`](../CHANGELOG.md).)* **No hours figure changed then** — the first hours change since is §3c.)*)*)*
**Document Type:** Capacity & Effort Model (per-phase owners, effort in hours, working-day capacity)
**Status:** Published — **roster unfilled**; §1 must be completed by programme management
**Estimating unit:** **hours**. Day figures are derived (**1 dev-day = 8 h**) and shown only as a reading aid.
**Resolves:** Gaps register **G1** (Critical) · Master-spec open issue **OI-51** · `REVIEW.md` #31, #53
**Scope:** the 14 shopfloor phases in [`Development/Phases/`](Phases/). Upstream rod receiving and order planning/line scheduling are out of scope and are **not** costed here.
**Shortcode:** `[CE]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

> ### ⚠ Headline finding
> The plan as specified is **3,660 hours** (457.5 dev-days) for **both scopes**, and **3,292 h** for **MVP-1 alone** (§3b). The window to the 30 Sep target contains **44 working days** — **352 hours per person**. That requires **≈10.4 people sustained** for both scopes, **≈9.4 for MVP-1**, and **27.2 in W7** either way.
>
> **The 30 Sep date is not achievable at any plausible team size, and descoping cannot rescue it.** The full descope ladder in §5 recovers only **448 h (12%)**, leaving a **9.3-FTE** requirement. G1's own recommended mitigation — *"defer Phase 12 & non-critical 13"* — recovers **276 h**, worth about **0.8 FTE**. That is roughly an order of magnitude short of the gap.
>
> This document does not solve that. It makes it **arithmetic instead of adjective**, so the choice between *more people*, *less scope*, and *a later date* is made deliberately in July rather than discovered in late September. See §7 for the three options and what each costs.

---

## 0. Why this document exists

G1 and OI-51 record the same defect: 14 phases in ~6.5 weeks with **no capacity or effort model, no per-phase owner, and no effort estimate**. Verified before writing this:

- Zero occurrences of effort, hours, days, FTE, capacity or velocity anywhere in `Development/Phases/`'s 18 files.
- No `Owner` on any phase file. Only `phase-01a/01b/01c` carried a doc-control block at all (`REVIEW.md` #53).
- The one quantified basis — `05-SprintPlanAndBacklog.md` — sized its stories against the **dead 5-sprint model**, with no sprint→phase crosswalk (`REVIEW.md` #33; the crosswalk and an hours cross-check were added there 13 Aug 2026).

**A note on the phase count.** OI-51 says *"thirteen workflow phases"*; G1 says *"14 phases"*. **Both are correct and neither is a drift.** `../00-overview/Roadmap.md` §0 defines Phase 1 as the layer-organised **platform** phase and Phases 2–14 as the **13 business-workflow phases**. The canonical phrasing, used throughout this document, is: **14 phases = 1 platform + 13 workflow phases (2–14)**.

---

## 1. Delivery streams and roster

Six streams, derived from the layers the phase files actually name.

| Code | Stream | Repo / surface | Hours | Share |
|---|---|---|---|---|
| **FE** | Angular | `ual-angular` → new library `flat-wire` (prefix `fw`) | **1,211** | 33.1% |
| **BE** | .NET | `ual-api` → new `FlatWire` microservice | **840** | 23.0% |
| **QA** | Test / E2E / UAT | all phases + Phase 14 | **701** | 19.2% |
| **RT** | Real-time / PLC | `FlatWireHub`, OPC ingest, `PLCTagService` | **408** | 11.1% |
| **DB** | SQL Server | new `FlatWireDB` ~~+ the shared-schema FW-001 renames~~ *(cancelled, `D-32` — see §3c)* | **404** | 11.0% |
| **BA** | BA / Ops liaison | pass-schedule content, OQ closure, UAT coordination | **96** | 2.6% |
| | | **Total** | **3,660** | 100% |

Stream hours **include each stream's pro-rata share of contingency** (factor **1.146976** = 3,660 ÷ 3,191 base), so the column sums exactly to 3,660. §3 shows the same total with contingency broken out as its own column.

**These are both scopes.** For MVP-1 only, scale to **3,292 h** — see §3b. ⚠ **After `D-32` (18 Aug 2026) the figures are 3,554 h both scopes / 3,186 h MVP-1 — see the additive §3c.** §3 and §3b are the base of record and are deliberately not re-derived.

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

`03-HLD-and-ERDiagram.md` §14 asserts only that *"the team is already Angular/.NET"* — it never states team size, which is precisely the hole G1 identifies.

---

## 2. Estimating basis — the unit-rate card

The unit is **hours**. Story points are deliberately **not** the unit; see the cross-check in §3.

No prior estimate of any kind exists, so the estimate is **derived, auditable and re-runnable** rather than asserted: each phase's effort is built from the deliverable inventory that phase already publishes (its `- **Screens:**`, `- **Components:**`, `- **APIs:**` and `## Database Changes` / `## Real-Time Functionality` bullets), priced with the rate card below.

| Unit | Hours | Notes |
|---|---|---|
| New dashboard screen | **24 h** | `MVP-1/ProjectPlan/Frontend/Mockups/*.html` is the approved visual spec — no design time included |
| Screen variant (FL2/FL3 mode of an existing screen) | **8 h** | |
| Modal / dialog | **12 h** | |
| Shared composite control | **20 h** | `pass-schedule-table`, `gauge-trace-chart`, `tolerance-viz`, `tab-wizard`, `action-bar`, `payoff-weight-bar` |
| Shared primitive control | **8 h** | `.input` states, monospace readouts, pass/fail buttons, `alert-banner` |
| Command endpoint (MediatR + FluentValidation) | ~~6 h~~ → **5 h** | `API/Domain/CoilCheckin` is the template (`[ARC §2.2]`). ⚠ **Restated 15 Aug 2026**: this row read *"+ unit test"* and priced one in. **There are no automated backend tests** (`[TS §1.2]`) |
| Query endpoint | ~~4 h~~ → **3 h** | Same withdrawal — the bundled test is out |
| Non-trivial business service / algorithm | **12–24 h** | priced individually; shown in §3's derivations |
| Table (DDL + FK + index + EF mapping + repository) | **4 h** | |
| Stored proc / reporting view | **8 h** | |
| Report | **8 h** FE + **8 h** BE | extends the existing `Reports` service |
| New hub event (typed contract + publisher + subscriber) | **8 h** | Foundations §0.4 |
| PLC tag group push + compensating clear | **16 h** | |
| **QA uplift** | **+20%** of FE+BE+DB+RT | suppressed in Phase 14, which *is* the QA phase. ⚠ **Do not reduce this line when a phase loses automated tests.** The two endpoint rows above fell on 15 Aug 2026; QA did **not**, and 1B holds it at 78 h against a mechanical 74. Manual regression is where withdrawn tests reappear as cost — applying the formula mechanically books the saving twice |
| **Contingency** | **+15%** of (base + QA) | stated once, not hidden per line |

Two discrete line items that are **not** rate-card units:

| Discrete item | Hours | Where |
|---|---|---|
| ~~FW-001 shared-schema rename **impact audit**~~ — **CANCELLED, `D-32`, 18 Aug 2026** | ~~**40 h**~~ → 0 | ~~Phase 1C~~ |
| Hub load test (N clients × 3 lines × cadence) | **16 h** | Phase 3 |

### Two costs the inventory does not capture

Both are added as explicit lines, because omitting them is how the plan under-read its own size in the first place.

1. ~~**FW-001 shared-schema rename audit — 40 h, in Phase 1C.**~~ ⚠ **CANCELLED — `D-32`, 18 Aug 2026: there is no shared-schema migration.** Retained because this list exists to record costs the plan had missed, and removing the entry silently would repeat that mistake. **One thing the audit would have produced is genuinely lost** — an inventory of every stored procedure, view and report reading these columns; **`OI-111`** asks for the one-column version of it. The original text: The `Coil/Bundle…` slash-dual renames (`CoilNo`, `SlitWidth`, `CoilStatus`, `OutgoingCoilId`, …) land on the **shared** `coils`/scheduling schema, which the legacy `ual-dot-net` applications and existing reports also read. `phase-01c` itself flags *"high blast radius; front-load the impact audit."* The rename is 16 h; the SP/view/report impact audit across `united_db` and the legacy tier is a separate 40 h.
2. **Cross-DB check-in recovery (G2 / OI-39) — a 24–64 h reserve on Phase 4, not in the total.** Check-in spans `FlatWireDB` + shared `coils`/`wip_coil_orders` + the PLC and is **not one ACID transaction**. Neither candidate (saga/outbox with compensating PLC clears, or an `INFLAT` mirror in `FlatWireDB`) has been chosen. **Phase 4's estimate is provisional until OI-39 closes.**

A third, smaller reserve: **OQ-10 / OI-45 (footage→weight) — 16–32 h on Phase 9.** The formula is settled but the *dimensional basis* (target vs measured-at-completion vs integrated over `RunReading`) is not, and the integration option is materially more work than the other two.

---

## 3. Per-phase effort

All figures in **hours**. `Cont` = contingency. The `Days` column is derived (hours ÷ 8) and is a reading aid only.

> ⚠ **After `D-32` (18 Aug 2026): 3,554 h both scopes / 3,186 h MVP-1 — see the additive §3c, which re-derives Phases 1C and 7 from reduced bases. This table is deliberately left on its published figures.**
>
> **This table is BOTH SCOPES combined.** For the MVP-1-only figure — **3,292 h / 9.4 FTE** — see **§3b**. Phase 2 is wholly MVP-2; phases 11 and 13 are split there; **Phase 9 is wholly MVP-1 and its row below is whole and correct**, so do not go looking for a missing carve.

> **Rounding convention — every figure printed here is the figure used.** Each cell is a whole number of hours, and each row total is the sum of its own printed cells. There is no "figures may not sum due to rounding" caveat: **every row adds up exactly as shown, and so does every column.** Verify any row by hand.

| Phase | Stream owner | FE | BE | DB | RT | QA | BA | Cont | **Hours** | Days | Window | Deferrable |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **1A** Angular Foundation | FE | 224 | — | — | 44 | 54 | — | 48 | **370** | 46.2 | W0 | No |
| **1B** Backend Foundation | BE + RT | — | 208 | — | 112 | 64 | — | 58 | **442** | 55.2 | W0 | No |
| **1C** Database Foundation | DB | — | — | 156 | — | 31 | — | 28 | **215** | 26.9 | W0 | No |
| **2** Pass Schedule Management | FE + BE | 80 | 62 | 12 | — | 31 | 16 | 30 | **231** | 28.9 | W2–W3 | No |
| **3** Line Status Board & Real-Time Backbone | RT + FE | 64 | 16 | 4 | 40 | 41 | — | 25 | **190** | 23.8 | W2–W3 | No |
| **4** Rod Check-In & PLC Config | FE + BE + RT | 60 | 62 | 28 | 28 | 36 | 8 | 33 | **255** | 31.9 | W4 | No |
| **5** Active Run Monitoring & Gauge Trace | FE | 76 | 12 | 8 | 24 | 22 | — | 12 | **154** | 19.3 | W4 | **No** — DB13/14 descoped 4 Aug |
| **6** In-Run Production Events | FE + BE | 120 | 56 | 20 | 20 | 43 | — | 39 | **298** | 37.2 | W5 | No |
| **7** WIP Rejection & Rod Checkout | FE + BE | 64 | 40 | 28 | 16 | 30 | — | 27 | **205** | 25.6 | W5 | No |
| **8** FL2 Spool Check-In & Finishing Run | FE + BE | 48 | 18 | 12 | 8 | 17 | — | 15 | **118** | 14.8 | W5–W6 | No |
| **9** Output Coil Completion & Packing | FE + BE | 104 | 26 | 16 | 8 | 31 | 8 | 29 | **222** | 27.8 | W6 | No |
| **10** FL3 Hybrid Continuous Operation | BE + FE | 12 | 20 | 4 | 8 | 9 | — | 8 | **61** | 7.6 | W6 | No — core route |
| **11** Shift Summary, Reporting & Certification | BE + FE | 64 | 76 | 28 | 4 | 34 | 8 | 32 | **246** | 30.8 | W6 | Partly — 4 of 5 reports |
| **12** Yield, Cost Ledger & Scrap | BE | 44 | 72 | 12 | — | 26 | — | 23 | **177** | 22.1 | W7 | **Yes — whole phase** |
| **13** Administration & Reference Data | FE + BE | 80 | 48 | 16 | 4 | 30 | 4 | 27 | **209** | 26.1 | W7 | Partly — Die Mgmt, roles |
| **14** Integration Testing, PLC Commissioning & Go-Live | QA + BA | 16 | 16 | 8 | 40 | 112 | 40 | 35 | **267** | 33.4 | W7 | No |
| | **TOTAL** | **1,056** | **732** | **352** | **356** | **611** | **84** | **469** | **3,660** | **457.5** | | |

The `TOTAL` row is the **raw column sum**: 1,056 + 732 + 352 + 356 + 611 + 84 + 469 = **3,660**.

**Roll-ups:** Phase 1 (1A+1B+1C) = **1,027 h** (128.4 d) · Phases 2–14 = **2,633 h** (329.1 d) · grand total = **3,660 h** (both scopes). **MVP-1 only: 3,292 h** — see §3b.

> ⚠ **The `1,027 h` above is this model's ORIGINAL Phase-1 figure, and after 18 Aug 2026 it collides with a different one — do not treat the two as the same number.** `[TB]` restated Phase 1 to **1,110 h** on 14–15 Aug (1A 370 · 1B 519 · 1C 221), which this model deliberately does not carry (§8); `D-32` then cancelled `FW-001`/`FW-002`, taking 1C to 138 h and Phase 1 back to **1,027 h** — composed **1A 370 · 1B 519 · 1C 138**. Two derivations, one total. **Check the composition, never the total**, before concluding which basis a document is on. See §3c.
**Largest phases:** 1B (442) · 1A (370) · 6 (298) · 14 (267) · 4 (255). **Smallest:** 10 (61) · 8 (118).
**Reserves excluded from the total:** G2/OI-39 on Phase 4 (**24–64 h**) · OQ-10/OI-45 on Phase 9 (**16–32 h**, now understated — see §3b).

### Worked derivation — Phase 4 (reproduce this shape for any phase)

> **FE 60 h** — Dashboard 2 `dashboard_2_rod_checkin.html` as a 6-step tab wizard with tolerance-viz, OK/NG/NA machine inspection and supervisor override (36 h, above the 24 h base rate for the wizard's six steps) + Dashboard 2A pre-check-in (24 h). `payoff-option` cards and `confirm-bar` are already built in 1A/Phase 2.
> **BE 62 h** — `POST /checkin/rod` as a complex command spanning two databases and the PLC (20 h) + `PayoffStagingController`'s 3 commands (18 h) and 2 queries (8 h) + `CheckInRod` service and validation rules (16 h).
> **DB 28 h** — new `RodStaging` table (4 h) + repository/EF writes across `RodCheckin`, `FlatWireRun`, `SpcCheckpoint`, `SpcMeasurement`, `RodCheckout` (16 h) + the cross-DB `coils → INFLAT` write (8 h). ⚠ **After `D-32` the last 8 h is a `FlatWireDB`-local `Rod.Status` write rather than a cross-database one** — this worked derivation is left at 28 h deliberately, because it is the *shape* being taught and Phase 4's published figure is unchanged.
> **RT 28 h** — new `PayoffStateChanged` domain event, sent immediately and unbatched per §0.4 (8 h) + `LineStatus`/`ComponentStatus` broadcast on success (4 h) + PLC tag group push with compensating clear (16 h).
> **BA 8 h** — closing OQ-3 (traveler field list), OI-64/51 (no-match path).
> **QA** +20% of the 178 h dev base = 36 h · **Contingency** +15% of (178 + 8 + 36) = 33 h → **Total 255 h** (60 + 62 + 28 + 28 + 36 + 8 + 33), plus the 24–64 h G2 reserve.

### Cross-check against the April story points — and what the divergence reveals

> **⚠ This cross-check's denominator was retired on 13 Aug 2026.** [05-SprintPlanAndBacklog.md](SprintPlan.md) was rewritten as the sprint-wise MVP-1 backlog and is now **sized in hours, not points** — the point totals below are historical and are preserved in that file's *Appendix A — Retired point basis*. **The cross-check is retained because its two findings are what mattered, and both still stand.** Finding 1 is now **closed**: the rewrite re-derived the backlog from the phase specs and Phase 1 carries **33 stories** where it previously had seven database-only ones. Finding 2 stands as the calibration argument for the §2 rate card. **Do not re-derive an h/point ratio from the current backlog** — it has no points.

The backlog sized the **45 shopfloor stories at 189 points**, split across three files (`05-SprintPlanAndBacklog.md` 35 / 147 · `YieldCostAndScrapJiraStories.md` 4 / 11 · `./FlatWireJiraStories-MVP2.md` 6 / 31). Against 3,660 h that is **19.4 h/point** — about 2½ days per point, roughly double a conventional ~1 day (8 h) per point. The divergence exceeds the 25% investigation threshold, so it was investigated. Two causes, both real:

1. **The backlog has no story for most of Phase 1.** Epic E01 "Foundation & Infrastructure" is 7 stories / 28 points, and **all seven are database stories** (~~FW-001 renames, FW-002 `INFLAT`~~ *(both cancelled, `D-32`)*, FW-003 machines, FW-004 alloys, FW-005/006/007 tables). There is **no story anywhere in the backlog** for scaffolding the `flat-wire` Angular library, for creating the `FlatWire` .NET solution and its 13 controllers, or for the OPC ingest and `PLCTagService`. Phase 1 is **1,027 h** against ~28 points of nominal coverage. **This is a backlog gap, not an estimating error** — and it is the single largest reason the window was believed to fit.
2. **Excluding Phase 1, the ratio is 2,633 h / 161 points = 16.4 h/point.** For touch-screen shopfloor dashboards built to mockup fidelity, with a full vertical slice (UI + MediatR command + validation + DDL + hub event + tests) per phase, ~16 h/point is the more defensible figure. Phase 6 is the clearest illustration: 4 full dashboards + 2 dialogs + 6 endpoints + 5 write tables was sized at 19 points ≈ 152 h if a point is a day — i.e. under 30 h per dashboard *including* backend, database and test. The model prices it at 298 h.

**The rate card in §2 is the single calibration knob.** If the team's measured throughput at the Phase-1 gate is better than these rates, rescale §2 and re-publish §3/§4 — see §6.

---

## 3b. MVP-1 apportionment

§3 above prices **both scopes combined**. This section derives the **MVP-1-only** figure, which is what the 30 Sep date has to be judged against. Three scope decisions of 11 Aug 2026 fix the boundary:

1. **Pass schedule generation and management are owned outside MVP-1.** Phase 2 leaves whole, with its **231 h**, permanently — not deferred within MVP-1.
2. **Die inventory and lifecycle are outside MVP-1**; the mid-run die change event stays. The **die inventory table (8 h DB)** therefore leaves `phase-13` along with the screen and the lifecycle service.
3. **Phase 9 is wholly MVP-1.** It keeps its published **222 h** intact and needs no apportionment — DB7, DB7b, both coil endpoints and `CoilCompletionService` all returned.

So only **two** phases are split.

### Method

The published totals **cannot be divided proportionally** — the descope ladder does not align with the MVP boundary (see §5, and the rungs table in `../../MVP-2/DevelopmentPlan/README.md`). Instead each carved deliverable is **re-priced from the §2 rate card**, subtracted from the published discipline columns, and **QA and contingency are re-derived from the reduced base** rather than scaled down. That keeps §3's own convention: *every row adds up exactly as shown*.

### What was carved, and at what price

| Phase | Deliverable carved out | Rate-card basis | FE | BE | DB |
|---|---|---|---|---|---|
| **11** | Dashboard 10 (Shift Summary) | New dashboard screen | 24 | — | — |
| **11** | `GET /shiftsummary` | Query endpoint | — | 4 | — |
| **11** | `ShiftSummaryService` | Non-trivial business service | — | 16 | — |
| **11** | `sp_ShiftSummary` | Stored proc / reporting view | — | — | 8 |
| **13** | Die Management screen | New dashboard screen | 24 | — | — |
| **13** | Die lifecycle service | Non-trivial business service | — | 16 | — |
| **13** | Die inventory table | Table (DDL + FK + index + EF + repo), as costed in `phase-13` | — | — | 8 |

**Phase 11's FE splits cleanly and is worth checking by hand:** its published FE 64 is DB10 (24) plus the five-report suite at 8 FE each (40). 24 + 40 = 64 exactly. What remains in MVP-1 is the reporting suite and the welding-wire certification.

### Result

| Phase | FE | BE | DB | RT | QA | BA | Cont | **MVP-1** | Published | Overstated by |
|---|---|---|---|---|---|---|---|---|---|---|
| **9** Output Coil Completion | 104 | 26 | 16 | 8 | 31 | 8 | 29 | **222** | 222 | — *(wholly MVP-1)* |
| **11** Shift Summary → Reporting & Certification | 40 | 56 | 20 | 4 | 24 | 8 | 23 | **175** | 246 | **71** |
| **13** Administration & Reference Data | 56 | 32 | 8 | 4 | 20 | 4 | 19 | **143** | 209 | **66** |

Both derivations, reproducible from §2:

- **Phase 11** — base `40 + 56 + 20 + 4 + 8 = 128` → `QA = 0.20 × (40+56+20+4) = 24` → `Cont = 0.15 × (128+24) = 23` → **175 h**.
- **Phase 13** — base `56 + 32 + 8 + 4 + 4 = 104` → `QA = 0.20 × (56+32+8+4) = 20` → `Cont = 0.15 × (104+20) = 19` → **143 h**. The surviving DB 8 h is non-die reference data; `Drawer` is already seeded in Phase 1.

### MVP-1 roll-up

```
3,660  both scopes (§3, corrected — see the callout there)
 −231  Phase 2 — pass schedule, owned outside MVP-1
 − 71  Phase 11 carve
 − 66  Phase 13 carve
─────
3,292 h  MVP-1
```

> ⚠ **After `D-32` (18 Aug 2026) this becomes 3,186 h — see §3c**, which subtracts 106 h all-in (Phase 1C 221 → 138, Phase 7 205 → 182). Both phases sit wholly inside MVP-1, so the subtraction is valid whatever composition produced the 3,292 h. **This roll-up is deliberately left as published.**

**3,292 h ÷ 352 h per person over 44 working days = 9.4 FTE sustained**, against **10.4** for both scopes on the corrected base.

### ⚠ The recovered ~1 FTE lands where there was already slack

This is the part that must not be read as relief. Recomputing §4's weekly grid on MVP-1 hours:

| Week | Days | Both scopes | **MVP-1** | MVP-1 FTE | Change |
|---|---|---|---|---|---|
| **W0** to Aug 14 | 12 | 1,027 | **1,027** | **10.7** | none — Phase 1 has no deferred content |
| W1 Aug 17–21 | 5 | 0 | **0** | 0.0 | none |
| W2 Aug 24–28 | 5 | 210 | **95** | **2.4** | ↓ 115 — *Phase 2 sat here* |
| W3 Aug 31–Sep 4 | 5 | 210 | **95** | **2.4** | ↓ 115 — *Phase 2 sat here* |
| W4 Sep 8–11 | **4** | 409 | **409** | **12.8** | none |
| W5 Sep 14–18 | 5 | 562 | **562** | **14.1** | none |
| W6 Sep 21–25 | 5 | 588 | **517** | **12.9** | ↓ 71 |
| W7 Sep 28–30 | **3** | 653 | **587** | **24.5** | ↓ 66 |

The grid sums to **3,292** with no leakage.

**Nearly all of the reduction falls in W2–W3, which the model already showed at 5.3 FTE — the slackest weeks in the plan.** They drop to 2.4. The weeks that were impossible are barely touched: **W4 and W5 do not move at all**, W6 goes 14.7 → 12.9, and **W7 remains at 24.5 FTE against a three-day week**.

**§7's forced decision therefore stands unchanged** — staff to ~10 FTE sustained, move the date, or cut below the critical path. Scoping MVP-1 out of MVP-2 was never going to recover the schedule, and now there is a number that says so.

### One figure that is still soft

- **Phase 9's 222 h excludes its 16–32 h `OQ-10`/`OI-45` reserve**, and that reserve is now *understated*: it was scoped before DB7b's **physical scale weight** (`FR-346`) was in MVP-1, which adds a second weight-capture point to reconcile. Phase 9 also assumes the **skid table** and **lot number** source already exist; neither does (`REVIEW.md` #13).

---

## 3c. `D-32` re-derivation — the cancelled shared-schema migration

**Added 18 Aug 2026. This is an additive sheet: it changes no figure in §3, §3b or the rate card, and those remain the base of record.** It states the delta from decision **`D-32`** — *there is no shared-schema migration* — and the totals that follow from it. The pattern is the one `DevelopmentEffortModel.md` and `YieldCostAndScrapSheet.md` use, and it is used here for the same reason: §3's totals are quoted in roughly twenty other files, and editing them in place drifts all of them at once.

### What was cancelled

| Item | Base h | Phase | Note |
|---|---|---|---|
| `FW-001` shared-schema column renames + the **40 h impact audit** | **56** | 1C | 16 h rename + 40 h audit, the discrete item in §2's inventory |
| `FW-002` `INFLAT` coil status | **4** | 1C | The **shared** half only — `INFLAT` survives as a `FlatWireDB`-local `Rod.Status` / `SpoolProcessing.Status` value |
| `FW-176`'s shared `coils` carry-forward columns | **16** | 7 | ⚠ **The plan's *second* shared-schema change**, easily missed when reading `D-32` as being about `FW-001` alone. Nothing is lost: the delivered design is already local and has been in the DDL since 26 Jul 2026 |
| | **76** | | **base hours removed** |

### Re-derived phases — QA and contingency recomputed from the reduced base

Same convention as §3b's carves: re-derive from the reduced base rather than scaling the published figure down.

| Phase | Base | QA | Cont | **Total** | Published in §3 | Delta |
|---|---|---|---|---|---|---|
| **1C** | `100` *(was 160)* | `0.20 × 100 = 20` | `0.15 × 120 = 18` | **138 h** | 221 h | **−83** |
| **7** | `132` *(was 148)* | `0.20 × 132 = 26` | `0.15 × 158 = 24` | **182 h** | 205 h | **−23** |
| | | | | | | **−106 h all-in** |

**Phase 14 is deliberately unchanged.** `FW-201` loses its renamed-column regression pass, but its hours are a **defect allowance** priced per stream, not per acceptance criterion — the same reasoning §2 applies to the QA uplift.

### Resulting totals

```
3,660  both scopes, §3 (base of record, unchanged)
 −106  D-32 — Phase 1C −83, Phase 7 −23
─────
3,554 h  both scopes after D-32       → 10.1 FTE sustained (was 10.4)

3,292  MVP-1, §3b roll-up (base of record, unchanged)
 −106  D-32 — both phases sit wholly inside MVP-1
─────
3,186 h  MVP-1 after D-32              → 9.1 FTE sustained (was 9.4)
```

**Phase 1 falls from 1,110 h to 1,027 h** (1A 370 · 1B 519 · 1C 138), or **10.7 FTE** against the 12-day window rather than 11.6.

> ⚠ **Do not read 1,027 h / 10.7 FTE as a return to the pre-14-Aug basis.** §2–§5 carry a **1,027 h / 10.7 FTE** figure that is the *old* Phase-1 basis, composed differently — it predates the 1B restatements. The number above is the **post-`D-32`** figure and is composed **1A 370 · 1B 519 · 1C 138**. Two derivations that coincide on one total; **check the composition, never the total**, to tell which basis a document is on.

> **The decision in §7 does not flip.** Removing 106 h moves the sustained MVP-1 requirement from 9.4 to 9.1 FTE against a roster that is not yet confirmed, and it removes **nothing** from the Phase-1 crunch that §4 predicts will fail — 1C was never the binding constraint there, 1A and 1B were. `D-32` retires a **risk** (the highest-blast-radius change in the plan) more than it releases capacity.

---

## 3d. `FW-219` — the FL2/FL3 run-end write-back, additive

**Additive, like §3c. Nothing in §3, §3b or §3c is re-derived here** — those totals are quoted in roughly twenty
files, which is exactly why `D-32` published §3c rather than editing §3, and the same discipline applies now.

### What is being added, and why it is not already in the plan

Until 18 Aug 2026 a completed FL2/FL3 coil was written **only** to `FlatWireDB`. Eight shared objects that
packing, shipping, certification, cost and yield all read were never written, and **not one of them was named
anywhere in the repository** — `wip_skids`, `wip_skid_coils`, `coil_slit_cuts`, `coil_gen_history` and `wip_log`
had zero occurrences across every `.md`, `.sql`, `.py` and `.html`. This was an absence, not a deferral, so there
is no line item anywhere to move: the hours are genuinely new. Story **`FW-219`**, requirements
`FR-509`–`FR-518`, gap **`G44`**.

### Rate-card derivation

| Stream | Rate-card items | Hand-coded | `[DE §1]` factor | AI-assisted |
|---|---|---|---|---|
| **DB** | the procedure — 8 writes, one transaction, the retry contract, 43- and 44-column inserts | 32 | **0.75** | 24 |
| **DB** | `CoilOutput.CoilNo` / `SharedSkidNo`, 2 indexes, schema-doc updates | 4 | 0.60 | 2 |
| **BE** | `CoilCompletionService` call, primary-rod resolution, retry / compensation handling, cross-database grants | 20 | 0.70 | 14 |
| | | **56 h** | | **40 h** |

**The 0.75 is the one judgement call in this table and it is deliberate.** `[DE §1]`'s DB row is **0.60** for
*"DDL, EF mapping, repositories — mechanical"*, and this is not that. It is a multi-database transactional
procedure written against an undocumented legacy schema with two active triggers, no foreign keys, no check
constraints and no defaults — `[DE §1]`'s *non-trivial business service* band (0.65–0.75) describes it, and it
sits at the top of that band because the verification cost is human and irreducible.

### All-in, on §2's uplifts

```
   56  base (hand-coded, both streams)
  +11  QA  +20%
  +10  contingency +18%
─────
   77 h all-in
```

### Where it lands

```
3,554  both scopes after D-32 (§3c, unchanged)
  +77  FW-219 all-in
─────
3,631 h  both scopes including FW-219

3,186  MVP-1 after D-32 (§3c, unchanged)
  +77  FW-219 sits wholly inside MVP-1 (Phase 9)
─────
3,263 h  MVP-1 including FW-219
```

**Phase 9's published 222 h is unchanged and now understates by 77 h.** That is intentional and matches how
`FW-202` is carried against Phase 8's 118 h: the additive figure is stated where it is derived, and the phase file
keeps its own baseline so that every document quoting `222 h` stays internally consistent. Quote **`222 + 77`**,
not a merged number.

### Three things this section does not claim

1. **It does not recover any of `D-32`'s 106 h.** The two are unrelated: `D-32` cancelled a *migration* of the
   shared schema; `FW-219` *writes* the shared schema as it stands. Every one of its eight writes lands in a
   column that already exists, which is why no part of `FW-001` comes back.
2. **It does not include the trial's QA of the shared writes.** `[TRP]` carries `FW-219` at its **40 h
   AI-assisted** figure inside the trial's development-only basis; the QA, BA and contingency streams above are
   the MVP-1 view and must not be booked twice.
3. **It does not price closing `Q34`–`Q36` or `OI-114`.** Those are IT conversations about which existing
   procedures and reports read `coils.coil_status`, `transaction_name`, `stop_no` and `mfg_order_no` — the same
   question `OI-111` asks. The 40 h impact audit that would have answered them was cancelled with `D-32` and is
   **not** reinstated here. If the answers require changes to existing reports, that is new work again.

---

## 3e. Rod ↔ order allocation — additive

**Additive, like §3c and §3d. Nothing in §3, §3b, §3c or §3d is re-derived here.** Those totals are quoted
in roughly twenty files, which is why `D-32` published §3c rather than editing §3, and the same discipline
applies again.

### What is being added, and why it is not already in the plan

**Nothing persisted the rod ↔ order pairing.** The client confirmed on 20 Aug 2026 that a rod may carry
several orders, and `Q70` had settled the rod side on 30 Jul — but the relationship existed only implicitly
in `united_db..planning_routings`, which `[INT §8]` records the flat wire side as **reading and never
writing**. There is no line item anywhere to move: the hours are genuinely new, exactly as §3d found for the
run-end write-back.

Requirements `FR-541`–`FR-560` (`[REQ §5.28]`), rule codes `ORD003`–`ORD017`, stories
**`FW-225`–`FW-230`**, design [`RodOrderAllocation.md`](../95-archive/design-notes/RodOrderAllocation.md).

### Rate-card derivation

| Story | Stream | Rate-card items | Hand-coded | `[DE §1]` factor | AI-assisted |
|---|---|---|---|---|---|
| `FW-225` | **DB** | 2 tables, 7 FKs, 12 index statements, 3 schema-doc write-ups — **DDL already applied and live-verified**, so this is mapping and invariants | 12 | 0.60 | 7 |
| `FW-225` | **BE** | domain model, superseding-not-updating, the 3 cross-row invariants | 16 | 0.70 | 11 |
| `FW-226` | **BE** | the four-tier partition, O(1) positional validator, capped enumeration for tests | 14 | 0.70 | 10 |
| `FW-226` | **FE** | the refusal messaging at two entry points | 6 | 0.65 | 4 |
| `FW-227` | **BE** | the 5-state machine, two weight latches, the atomic close-and-open, 2 hub events | 16 | 0.70 | 11 |
| `FW-227` | **FE** | the durable prompt and `Mark order complete` on DB3 | 10 | 0.65 | 7 |
| `FW-228` | **BE** | the converter, 4 bases, per-row basis/factor persistence | 12 | 0.70 | 8 |
| `FW-229` | **DB** | 2 views | 6 | 0.60 | 4 |
| `FW-229` | **BE** | footage-share apportionment, status derivation, the two yield figures | 10 | 0.70 | 7 |
| `FW-230` | **DB** | `ChildAlpha` + its unique index — **already applied** | 4 | 0.60 | 2 |
| `FW-230` | **BE** | the cross-database mint, the ignore-list accumulation, both caller guards | 10 | 0.70 | 7 |
| | | | **116 h** | | **78 h** |

**Two judgement calls, both stated rather than buried.**

**The DB rows use `[DE §1]`'s standard 0.60, not §3d's 0.75.** §3d argued upward because that procedure was
eight writes in one transaction against a schema nobody had described. Here the DDL is **already written,
deployed and verified on the shared instance** — 33 tables · 55 FKs · 70 index statements, from a live
teardown-free deploy plus an idempotent re-run — so the remaining DB work is genuinely conventional and the
standard factor applies.

**`FW-227` is the only row I would defend upward if challenged.** The atomic close-and-open at a boundary is
one transaction spanning two state transitions under a filtered unique index, and the prompt must be durable
across reconnects. It is estimated at the standard 0.70; a case exists for 0.75 on the same reasoning §3d
used, and it is left at 0.70 because the pattern is **already built once** — the spool-completion prompt — and
this follows it rather than inventing it.

### Effect on the totals

| | Base | AI-assisted |
|---|---|---|
| MVP-1 before this sheet (`§3c`, after `D-32`) | 3,186 h | — |
| §3d — `FW-219` | +56 h | +40 h |
| **§3e — rod ↔ order** | **+116 h** | **+78 h** |
| **MVP-1 all-in** | **3,358 h** | — |

> ⚠ **`3,358 h` IS THE LIVE MVP-1 FIGURE, and this row is the only site that may assert it.**
> Cite it as *"3,186 h base plus the additive sheets = **3,358 h** all-in (`[CE §3e]`)"* — do not
> restate the bare number elsewhere, and **do not re-derive §3, §3b, §3c or §3d in place.** They are
> the base of record and each later sheet **adds** to them; that is what keeps the arithmetic
> auditable, and it is why several different totals legitimately appear in this document.
>
> **Reading the other figures you will meet:** **3,186 h** is the `D-32` base (§3c) and is still
> correct *as a base*; **3,292 h** is pre-`D-32` and stale as a live figure; **3,263 h** was this
> document's own header between §3d and §3e and is superseded by the row above; **3,727 h** predates
> the 11 Aug MVP split and is audit trail only. The equivalent both-scopes figure is **3,631 h**
> after §3d and rises with §3e on the same arithmetic.
>
> ⚠ **The backlog's headline of *114 live stories / 3,186 h* is the SCHEDULED baseline and is not
> wrong.** `TaskBreakdown.md` holds **143** `FW-` ids because the additive and *Unscheduled* sets
> (`FW-210`–`215`, `FW-217`–`223`, `FW-225`–`230`, `FW-N01`–`N06`) are deliberately outside that
> baseline. Do not "reconcile" the two counts by renumbering anything.

## 3f. FL2 pre-check-in (`FW-224`) — additive, NOT YET SIZED

**The client reversed `FR-031` on 20 August 2026: FL2 gets pre-check-in.** Requirement text landed
25 Aug 2026 as `[REQ]` §5.29, `FR-533`–`FR-540`, with cases `TC-776`–`TC-783`. **The story is
`FW-224`, reserved and unsized.**

⚠ **This sheet deliberately carries no hours.** Action **`A6`** of the
[20 Aug ledger](../95-archive/source-documents/ClientCall_2026-08-20_SyncPlan.md) — *size `FW-224`+ across
DB, BE, FE and test, additive to the baseline* — was **still unreported at the 24 Aug call**, and
the sizing is **blocked on `Q41`** (`Critical`, open): what an FL2 pre-check-in actually *does*
decides whether this is a screen change or a screen plus an endpoint plus a queue. Putting a number
here before `Q41` closes would be a guess presented as an estimate.

**What is already known, so the sizing is not from nothing:**

| Element | State | Effect on the estimate |
|---|---|---|
| **Schema** | ✅ **Done** — `SpoolStaging` built 22 Aug 2026, in the runner, seeded | **0 h.** The 20 Aug ledger’s W4 is complete; do not re-price it |
| **Requirement text** | ✅ **Done** 25 Aug 2026 — `§5.29`, eight requirements | **0 h** |
| **Test cases** | ✅ **Written** 25 Aug 2026 — `TC-776`–`TC-783`, all `[PROPOSED]` and deliberately not automated | Automation still owed |
| **Endpoint** | ❌ Owed — `POST /precheckin` must accept `lineId = FL2` and its `422` retire, in **five** places in `[API]` | BE |
| **Screen** | ❌ Owed — the action on **Dashboard 5A**, not a new screen, and **not** DB2A | FE |
| **WIP station** | ❌ Owed — `FL2PO` must be created; the script says it is *deliberately not created* | DB / deploy |
| **Mockup** | ⚠ Comments corrected 25 Aug 2026; **the control itself is not built** | FE |

**Effect on the totals: none yet.** MVP-1 all-in stays **3,358 h** (§3e) until `Q41` closes and
`FW-224` is sized. **When it is, add a §3g — do not edit §3e or the row above.**


⚠ **This does not move the 30 Sep conclusion, and it worsens it.** §3's headline finding is that the date is
not achievable at any plausible team size and that the full descope ladder recovers only part of the gap.
Adding 116 h to a plan already 3,186 h against that window does not change the conclusion; it removes
another 14.5 dev-days of slack that were not there. **No total in §3, §3b, §3c or §3d has been edited.**


---

## 3g. `FW-231` — register every flat wire alpha in the shared coil master, additive

**Change `[N]` (26 Aug 2026) makes every alpha mint pass a blank ignore list**, relying on
`CommonDB.dbo.GenerateCoilAlpha`'s own sweep to find prior siblings. That works only for alphas that
reach the shared schema — and **nothing writes an FL1 segment alpha there.** `FW-231` is that writer.
Registers **`OI-138`** and **`G54`**; design of record `[RodOrderAllocation.md §2.4/§2.8]`.

⚠ **ADDITIVE. Nothing below re-derives a published total** — `[CE §3]`'s **3,186 h MVP-1** and the
`§3b` apportionment are untouched, and `§3c`–`§3f` are untouched. Read this sheet **with** them.

| Stream | Hours | What |
|---|---:|---|
| DB | **12** | The writer itself, at spool completion. One `proddb..coils` row per segment alpha, minted and inserted in one transaction with the `THROW 51011` re-check under `UPDLOCK, HOLDLOCK` — the pattern `FlatWire_CompleteCoilOnSkid` already uses |
| BE | **6** | Wire it into `POST /spool/complete`, and surface the failure: a leaked name is worse than a refused spool |
| | **18 h** | **Total, additive to 3,186 h → 3,204 h MVP-1** *(stated here only; `[CE §3]` is not edited)* |

**Why 12 h on the database side and not 4.** The insert is trivial; **the three decisions around it
are not**, and each is a way to get it wrong quietly:

1. ⚠ **`coil_status`.** `D-32` bars a **new** shared value — `INFLAT` is `FlatWireDB`-local by
   decision — so the segment row must take an **existing** one, and the output coil's own status is
   *still open* as `Q35`. Choosing badly puts flat wire segments into some other module's report.
2. ⛔ **Tonnage multiplication — the one that would reach the client.** Rod, segments and coils all
   group flat under the six-character root through `coil_link_master_coil`. A report that sums a
   rod's children would count **one rod's 4,000 lb three times**. Finding which reports do that is
   most of the 12 h, and it is investigation, not coding.
3. **Atomicity.** Mint then insert, in one transaction, or a crash leaks an alpha that the sweep will
   never reissue and nothing owns.

⛔ **This is not optional and it is not deferrable.** It **gates `FW-230`**, and through it every FL1
alpha in the design of record. Built alone, `FW-230` reissues `R00001A` on every spool.

⚠ **Not sized here: `OI-139`.** If an FL2-standalone spool can arrive with **no** segment at all, its
coils have neither a segment nor a rod to root on, and that is a design gap rather than an estimating
one. Sizing it before that is answered would be a guess presented as an estimate — the same reason
`§3f` carries no hours.

## 4. Capacity model

`required FTE = stream-hours scheduled that week ÷ (working days that week × 8 h)`

> **The grid below is both scopes.** The MVP-1 grid is in **§3b** — it differs only in W2/W3 (Phase 2 removed), W6 and W7, and **W4/W5 are identical**. The peak is **24.5 FTE in W7** either way.

Working days are counted, not assumed. **Labor Day falls on Mon 7 Sep 2026**, inside W4, and W7 holds only 3 days.

| Week | Dates | Wk days | Capacity / person | FE | BE | DB | RT | QA | BA | Hours | **Peak FTE** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **W0** | to **Aug 14** | 12 | 96 h | 2.8 | 2.6 | 1.9 | 1.9 | 1.6 | — | 1,027 | **10.7** |
| W1 | Aug 17–21 | 5 | 40 h | — | — | — | — | — | — | 0 | **0.0** ← only slack in the plan |
| W2 | Aug 24–28 | 5 | 40 h | 2.2 | 1.2 | 0.2 | 0.6 | 0.9 | 0.2 | 210 | **5.3** |
| W3 | Aug 31–Sep 4 | 5 | 40 h | 2.2 | 1.2 | 0.2 | 0.6 | 0.9 | 0.2 | 210 | **5.3** |
| W4 | Sep 8–11 | **4** | **32 h** | 5.2 | 2.7 | 1.3 | 1.9 | 2.0 | 0.2 | **409** | **12.8** |
| W5 | Sep 14–18 | 5 | 40 h | 6.1 | 3.1 | 1.6 | 1.2 | 2.0 | — | 562 | **14.1** |
| W6 | Sep 21–25 | 5 | 40 h | 6.0 | 3.9 | 1.6 | 0.7 | 2.1 | 0.4 | 588 | **14.7** |
| W7 | Sep 28–30 | **3** | **24 h** | 7.1 | 6.9 | 1.9 | 2.6 | 7.0 | 1.8 | 653 | **27.2** |

The `Hours` column sums to **3,660** — the grand total, allocated with no leakage. Phases spanning two weeks are split evenly (Phase 2 and 3 across W2/W3; Phase 8 across W5/W6). Phase 1 is allocated wholly to **W0** because the Aug-14 gate is hard; W1 therefore shows zero planned load.

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
| | **3,660** | **10.4** | *TBD* | *TBD* |

The `Available` and `Gap` columns compute themselves the moment §1's roster is filled. **This plan assumes ~10.4 concurrent people and 3,660 hours for both scopes — 9.4 and 3,292 for MVP-1 (§3b). It has never said so.**

### Sensitivity — what "one hour" means

The rate card is authored on **calendar hours**: one dev-day is one working day of a person's paid time, normal meeting/email/context-switch overhead already absorbed. On that reading, capacity is 8 h/day and the requirement is **10.4 FTE** for both scopes, **9.4** for MVP-1.

If your organisation instead tracks **hands-on-keyboard hours** — i.e. you would book these 3,660 h against productive time only — divide by realistic productive hours per day:

| Effective productive h/day | Hours per person over 44 days | **Both scopes (3,660 h)** | **MVP-1 (3,292 h)** |
|---|---|---|---|
| 8.0 *(calendar reading — this model's default)* | 352 | **10.4** | **9.4** |
| 7.5 | 330 | **11.1** | **10.0** |
| 7.0 | 308 | **11.9** | **10.7** |
| 6.5 *(common industry norm)* | 286 | **12.8** | **11.5** |
| 6.0 | 264 | **13.9** | **12.5** |
| 5.5 | 242 | **15.1** | **13.6** |

**Pick one reading and state it before comparing against a roster** — mixing them either double-counts overhead or hides it. Every other figure in this document uses the 8 h calendar reading. If the team books time at ~6.5 productive h/day, the real requirement is **13 people, not 10.6**, and every conclusion below gets worse, not better.

### What the model predicts will fail

1. **The Aug-14 Phase-1 gate.** 1,027 h in 12 working days (96 h/person) needs **10.7 FTE on Phase 1 alone**, of which 2.8 FE and 2.6 BE are on the critical path. 1A/1B/1C genuinely parallelise, so this is not a sequencing problem — it is a headcount problem.
2. **W7 is arithmetically impossible.** **587 h MVP-1** in 3 working days (24 h/person) = **24.5 FTE** *(653 h / 27.2 FTE both scopes)*. W7 carries Phase 12 + Phase 13 + Phase 14, and Phase 14 alone is three E2E route runs, PLC commissioning support, renamed-column regression, **and** full UAT with stakeholder sign-off. UAT cannot start on the same day feature work completes.
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

> **Read the ladder against MVP-1 scope (§3b) before using it.** Two rungs straddle the boundary and are no longer worth what they say: **rung 5 (99 h)** bundled the Die Management screen — now MVP-2 — with the **MVP-1** role-assignment UI, so only the role-UI portion is still available to cut; **rung 6 (105 h)** defers four reports that are **all MVP-1** and is unaffected. Rungs 1–4 (Phase 12) are wholly MVP-1 and unaffected.

**Rungs 1–4 are all inside Phase 12** — FW-110, FW-102 and FW-101 are Phase-12 stories, so rung 4 is the **remainder** of the phase, not the phase again. The cumulative column is therefore additive with no double-counting.

| # | Rung | Hours | Cumulative | What is lost | Sign-off | Latest call |
|---|---|---|---|---|---|---|
| 1 | FW-110 Scrap Box/Skid outlet (Low) | 33 | 33 | Scrap routed manually post-go-live | Ops | W6 |
| 2 | FW-102 Cost Ledger config (Medium) | 49 | 82 | No flat-wire cost standards; costing reports blank | Cost accounting | W6 |
| 3 | FW-101 Weld traceability in yield (High) | 28 | 110 | Yield not attributed per source rod — **welding-wire certs affected** | Tim O. / Quality | W6 |
| 4 | Remainder of **Phase 12** (footage-based weight + yield form) | 67 | **177** = whole of Phase 12 | No footage-based yield at go-live | Programme | W6 |
| 5 | Phase 13 non-critical (Die Management screen, role assignment UI) | 99 | 276 | Die life tracked on paper; roles assigned by DBA | Maintenance / IT | W6 |
| 6 | Phase 11 reports FW-092/093/094/095 (4 of 5) | 105 | 381 | Only the Gauge Trace report ships; CPK/SPC/traceability reports deferred | Tim O. / Quality | W5 |
| — | *Phase 10 FL3 hybrid* | *61* | — | **Not deferrable** — FL3 is one of the three production routes | — | — |

**The ladder is not enough.** Rungs 1–7 recover **448 of 3,660 hours — 12%** — leaving **3,212 h, still 9.1 FTE** over 44 working days. *(On MVP-1 scope the ladder recovers less still: rung 5's 99 h bundled the now-MVP-2 Die Management screen.)* G1's own stated mitigation is rungs 1–5 (defer Phase 12 entirely plus non-critical Phase 13): **276 h ≈ 0.8 FTE**, against a shortfall measured in whole people.

Rung 6 is **new to the ladder** and is the model's own addition: Phase 11's seven stories cannot co-exist with Phases 8, 9 and 10 in W6 at any credible team size.

> **Rung 7 was removed on 4 Aug 2026 — and this made the schedule harder, not easier.** DB13 and DB14 were the largest genuinely-optional FE items in the critical-path phases, and the client **descoped them outright**. Their 67 h therefore stopped being *recoverable* effort and became *never-planned* effort: the programme total dropped to **3,660 h** and Phase 5 to **154 h**, but the residual after descoping everything was unchanged, the ladder now recovers **~12 % of a smaller base**, and **Phase 5 is no longer deferrable at all**.

Below rung 7 there is nothing left that is not a production route, a check-in path, or the traveler — i.e. every remaining rung would cut something the mill cannot run without. **That is the finding: scope is not where the 30 Sep date can be recovered.**

---

## 6. Calibration checkpoint

This model is a derivation from a rate card, not a measurement. It becomes trustworthy only once measured against real throughput, and the **Aug-14 Phase-1 gate is the calibration point**:

1. Record **actual hours** for 1A, 1B and 1C against the estimates (**370 / 442 / 215 h**).
2. Compute the variance per stream and restate the §2 rate card.
3. Re-publish §3 and §4 with the corrected rates, and re-run §4's inverse table.
4. Confirm which hour definition the recorded actuals use (calendar vs hands-on-keyboard) and lock the §4 sensitivity row that matches.
5. Record the revision in [`../CHANGELOG.md`](../CHANGELOG.md), under this document's section.

Because the gate is 12 working days away and the model says Phase 1 needs 10.7 FTE, the *first* calibration signal will arrive well before 14 Aug: if Phase 1 is not booking on the order of **500 hours in its first week**, the §4 conclusions are confirmed and §7's decision cannot wait for the gate.

---

## 7. The decision this model forces

Three options. They are not mutually exclusive, and doing none of them is itself a choice — the one G1 calls *"silent scope loss."*

> **Restated on MVP-1 scope (§3b), 11 Aug 2026 — the decision does not change.** MVP-1 is **3,292 h / 9.4 FTE sustained** against 3,660 / 10.4 for both scopes. That is a reduction of about **one FTE**, and it lands almost entirely in **W2–W3**, which were already the slackest weeks at 5.3 FTE. **W4 and W5 are unchanged**, and **W7 is still 24.5 FTE against three days.** Option A becomes ~9.4 concurrent people instead of ~10.4; **Options B and C are unaffected**, and B's dates move by days, not weeks. Deferring MVP-2 was not a schedule remedy and was never proposed as one.

| Option | What it means | Cost / consequence |
|---|---|---|
| **A — Staff to the plan** | ~10.4 concurrent people (**83 h/day**) across the six streams from W0 for both scopes — **~9.4 (75 h/day) for MVP-1** | The only option that holds 30 Sep. Both scopes need ~3.4 FE, ~2.4 BE, ~2.0 QA, ~1.2 RT, ~1.1 DB, ~0.3 BA. Ramp-up time is **not** in the hours. |
| **B — Move the date** | Keep a realistic team; publish the date the model gives | At 6 FTE (48 h/day) → **18 Nov 2026**; at 8 FTE (64 h/day) → **22 Oct 2026**. Both land inside the already-planned Q4 2026 production window. |
| **C — Cut scope to the critical path** | Full descope ladder (§5) plus a further decision on which of Phases 11/13 ship at all | Recovers only **12%** (448 h), leaving 3,279 h ≈ 9.3 FTE. **Insufficient alone**; must be combined with A or B. **On MVP-1 scope the ladder recovers less**, because rung 5's 99 h included the now-MVP-2 Die Management screen — see §5. |

**Recommendation: B, combined with C's rungs 1–4.** The Q4 2026 production target already sits past 30 Sep, so an Oct 22–Nov 18 feature-complete date does not move the business outcome, whereas Option A's ~11 concurrent people has no evidence of being available and Option C alone cannot close the gap. This is a programme-management decision, not an engineering one — it is recorded here so it is made on numbers.

A separate scheduling consequence, independent of team size: **UAT cannot share W7 with feature work.** Phase 14's 267 h — including 112 h of QA and 40 h of UAT/BA — should be pulled into a dedicated window after feature-complete, whichever date that lands on.

---

## 8. Assumptions and known estimate risks

- **Hour definition:** one dev-day = **8 h** of a person's working day, normal overhead absorbed (the "calendar" reading). See §4's sensitivity table for the hands-on-keyboard alternative, which raises the requirement to 13–14 FTE.
- **Other assumptions:** no ramp-up or onboarding time; mockups in `MVP-1/ProjectPlan/Frontend/Mockups/` are final so no UI design time is costed; `../50-frontend/mockups/flat-wire-shopfloor.styles.scss` is consumed as-is with no token migration (G18); the `CoilCheckin` backend template is directly reusable (Foundations §0.2).
- **Phase 4 is provisional** until OI-39 / G2 (cross-DB check-in recovery) is decided — **24–64 h reserve**.
- **Phase 9 is provisional** until OI-45 / OQ-10 (footage→weight basis) is decided — **16–32 h reserve**, and that reserve is now **understated**: it was scoped before DB7b's physical scale weight (`FR-346`) was MVP-1 scope, which adds a second weight-capture point to reconcile against the first. Integrating over `RunReading` is materially more work than a target-derived weight. Phase 9 also assumes the **skid table** and the **lot-number source** already exist — neither does (`REVIEW.md` #13), and neither is costed.
- **Phase 12 is provisional** — OI-68 (costing), OI-68 (standard times) and OI-60 (yield per route) are all open; it is also rungs 1–4 of the ladder.
- **Phase 3 carries a 16 h hub load test** whose pass criteria do not exist. G9 / OI-34 records that the NFRs (AGC sample rate, concurrent clients, latency budget, `RunReading` retention) are undefined. If the load test fails, the real-time rework is **not** in this model.
- **Die inventory is not MVP-1's table.** Die inventory and lifecycle are owned outside MVP-1, so its **8 h sits in Phase 13's MVP-2 carve**, with the screen and the lifecycle service (§3b). MVP-1's die change reads size, footage and threshold from the **`Drawer`** lookup already seeded in Phase 1, and `D4` is enforced at **size** level — see `DieChangeAndManagement.md` §2.4a. This also removes the Phase 6 → Phase 13 dependency (`REVIEW.md` #34).
- **1B is understated by 27 h, and the phase file has been corrected while this model has not.** Two omissions found 14 Aug 2026, both against published sources rather than re-scopes: **`FW-138` was priced at 13 controllers** (52 h) when `[API §3.1]` has always listed **14** — `PayoffStagingController`, which owns four of the 30 endpoints and the whole DB2A staging surface — so it is **56 h**; and **`ITInhibit`** (`[PLC §8]`, `FR-008`–`FR-010`/`FR-020`, **seven P1 test cases**) had **no phase home and no costed story**, being bundled into the uncosted `FW-N11`, so it is minted as **`FW-205`, 16 h RT**. On this model's own uplifts: BE 208 → **212**, RT 112 → **128**, base 320 → **340**, QA **68**, cont. **61** → **442 → 469 h**, and Phase 1 **1,027 → 1,054**. **`[TB §7]`'s reconciliation, the three phase files and `[RM]`'s Phase 1 row carry the corrected figures; §2, §3, §3b, §4 and §5 here deliberately do not** — re-deriving them in place would move the TOTAL row (3,660 → 3,687), MVP-1 (3,292 → 3,319), the weekly grid, the FTE columns and the descope ladder, which is a programme re-baseline rather than a documentation fix. **Absorb it at the next re-derivation**, the same way `FW-202`/`FW-203` are carried as additive. *(A third item, `FW-206` — the interlock's conditions 1–2 — is 8 h against **Phase 4** and blocked on `PLC-Q12`.)*
- **1B was restated a third time on 15 Aug 2026 — all automated backend tests withdrawn — and this model does not carry it either.** `FlatWire` ships with **no xUnit of any kind**: no unit, no validator, no stub-fixture/contract suite, no seeded-DB integration suite (`[TS §1.2]`). **1B 541 → 519 h.** Three consequences this model must eventually absorb, and all three are counter-intuitive: **(1)** the reduction is **itemised, not fractional** — `FW-138` 56→45 (tests out, but **fourteen → fifteen controllers** — `SpoolController`), `FW-147` 16→12, `FW-080` 32→28, while **`FW-207` (32 h) and `FW-150` (16 h) are unchanged** because they are priced from production artifacts with no test in the basis; a flat fraction applied to the base overstates the saving by ~70 % (the net is **−22 h**, not ~−44). **(2)** §2's **command and query endpoint rows fell 6→5 h and 4→3 h**, which is the change that actually reaches Phases 4–13 — 1B is priced at the controller rate, so the rate-card edit barely touches it. **(3)** ⚠ **The QA uplift is deliberately NOT recomputed**: 1B holds **78 h** against a mechanical `0.20 × 373 = 75`, because with no automated tests the manual-regression load across Phases 4–14 rises rather than falls. **Absorbing this at the next re-derivation must not quietly apply the 20 % to the reduced base** — that books the saving a second time on the one line that should grow.

- **1B and 1C were restated on 15 Aug 2026 for decision `D-29` (tactical DDD), and this model still does not carry it.** `FW-207` (domain model, 32 h) and `FW-208` (domain events, 8 h) are new; `FW-141` 20 → 28 h and `FW-147` 12 → 16 h. **1B: BE 212 → 264, base 392, QA 78, cont. 71 → 469 → 541 h.** Separately `FW-007` 48 → 52 h for `G21`'s `RodStaging.Station` column and re-keyed index — **1C: DB 156 → 160 → 221 h**. **Phase 1 → 1,132 h.** `FW-209` (4 h FE, DB2A toggle) sits in Phase 4. As with the 14 Aug restatement, `[TB §7]`, the phase files and `[RM]` carry the corrected figures and **§2–§5 here deliberately do not** — absorb at the next re-derivation.
- **1C is costed against 22 tables, and the build is larger — the gap is wider than this line has ever said.** The table count is `[DBD §6.2]` (the "25 / 33 / 41" figures here are pre-`D-31`, and the "three pass-schedule tables owned elsewhere" position was retired by `D-31` on 15 Aug 2026 — they are MVP-1 and the runner builds them). Each table beyond the 22 is **4 h** plus its share of QA and contingency. ⚠ **The hour figure is deliberately not restated here.** This is an effort *derivation*, so substituting a new table count without re-deriving would make the arithmetic lie; and per the standing convention an effort change lands in an **additive new sheet, never an in-place edit of a total**. **Owed: re-derive against `[DBD §6.2]` using §2's rate card.**
- Upstream stories (rod receiving, order planning, line scheduling — 14 stories, 42 points) are **out of scope here** and are staffed by their own teams. If those slip, Phase 4 has no material and no scheduled job.

---

## Related Documents

| Document | Purpose |
|---|---|
| [`DevelopmentEffortModel.md`](./DevelopmentEffortModel.md) | **Development effort only (FE/BE/DB/RT), re-derived on an AI-assisted (claude.ai) basis** per the 23 Jul 2026 client decision. **MVP-1 development = 1,397 h / 4.0 developer-FTE excluding Phase 12** (2,114 h hand-coded), or **1,486 h against 2,242 h** with Phase 12 added back from the sheet below. It factors *this* document's published columns and does **not** supersede any figure in it — QA, BA, contingency, the roster, the capacity decision and the descope ladder all remain owned here |
| [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) | **Phase 12 (Yield, Cost Ledger & Scrap) at story level**, on both delivery bases. Decomposes this document's published **177 h** to the descope ladder's own 33/49/28/67 split — both axes reconcile exactly to §3 and §5 here — and adds the AI-assisted view at **126 h**. ⚠ Records that `FW-101`, `FW-102` and `FW-110` carry **no `FR-` IDs** and the phase has **no owning requirement document**, so its 177 h was priced against four Jira cards |
| [`../00-overview/Roadmap.md`](Roadmap.md) | Master roadmap index — carries the per-phase Owner/Effort summary |
| [`../90-registers/Gaps.md`](../90-registers/Gaps.md) | Week grid, milestones, risks, gaps register (G1) |
| [`ShopfloorPlan/phase-*.md`](Phases/) | Per-phase `Owner:` / `Effort:` doc-control blocks and the deliverable inventories this model prices |
| [05-SprintPlanAndBacklog.md](SprintPlan.md) | **The authoritative MVP-1 shopfloor backlog** (rewritten 13 Aug 2026) — **116 stories / 3,292 h** across four even two-week sprints, **sized in hours off §2's rate card and reconciling exactly to §3b**. Every story carries a `Rate-card basis:` line, and each phase closes on its §3b figure. **It consumes this document; it is not a second opinion** — if §3b changes, it is re-derived. Story points are retired (Appendix A there) |
| [`REVIEW.md`](../95-archive/design-notes/REVIEW.md) | Audit findings #31 (calendar conflict) and #53 (no doc-control block) |
| `../10-requirements/MasterSpecification.md` | §9.4 week grid, §9.5 backlog, §11.1 OI-51 |
