# Flat Wire Mill — Jira Story Plan: Yield, Cost Ledger & Scrap

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 13, 2026 — **reduced to a pointer**: the four story bodies were absorbed back into [05-SprintPlanAndBacklog.md](./05-SprintPlanAndBacklog.md) when it became the single MVP-1 backlog *(earlier same day: split out of that file; story bodies otherwise April 30, 2026)*
**Document Type:** ~~Story backlog for Phase 12~~ — **pointer document since 13 Aug 2026**
**Status:** **Superseded.** The four story bodies were absorbed into [05-SprintPlanAndBacklog.md](./05-SprintPlanAndBacklog.md) (S3 · Phase 12) when it became the single MVP-1 backlog. Retained as a citation target
**Scope:** **Epic 10 (Coil Yield & Cost Ledger)** and **Epic 11 (Scrap Management)** — `FW-100`, `FW-101`, `FW-102`, `FW-110`. **4 stories · 11 points.**
**Phase:** **12** — Yield, Cost Ledger & Scrap · **Window:** W7 (Sep 28–30, 3 working days) · **Owner:** BE stream
**Effort:** **177 h** hand-coded / **126 h** AI-assisted all-in; **128 h / 89 h** development-only — [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md)

---

> ## ⚠ Pointer — the story bodies moved on 13 Aug 2026
>
> `FW-100`, `FW-101`, `FW-102` and `FW-110` now live in **[05-SprintPlanAndBacklog.md](./05-SprintPlanAndBacklog.md) → S3 · Phase 12**, which became the single MVP-1 shopfloor backlog. **Their ids and titles are unchanged.**
>
> **Story points are retired** — the 11-point basis is historical and is recorded in that file's *Appendix A*. Sizing is now in hours: FE 44 · BE 72 · DB 12 → QA 26 → cont. 23 = **177 h**, which reconciles to `CapacityAndEffortModel.md` §3b and to the descope ladder's `33 + 49 + 28 + 67` split on both axes.
>
> **[`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) is unaffected and remains the Phase-12 hours authority**, including the AI-assisted 126 h view and the record that these four stories carry **no `FR-` IDs and have no owning requirement document**.
>
> The content below is retained as the audit trail. **Do not maintain it in parallel** — edit the backlog.

---

> ## ⚠ This is not the schedule, and its sprints do not exist
>
> All four stories carry **Sprint 5** tags. Those sprints were **superseded on 26 July 2026** and resolve to *nothing*
> in the roadmap. Under the old crosswalk Sprint 5 mapped to **Phases 3, 11, 12 and 14**; everything here is **Phase 12**.
> The live cadence is four even two-week sprints — [`05-SprintPlanAndBacklog.md`](./05-SprintPlanAndBacklog.md) §4.2 — and
> these four stories sit in **`S3` · Phase 12** there. *(The crosswalk this line used to cite went with the 13 Aug 2026
> backlog rewrite; the anchor had been dead since before that document was absorbed.)*
>
> **What this document is for:** the **story points and acceptance criteria**. For three of these four stories it is
> the *only* requirement text that exists anywhere (§3) — which is a defect, not a feature of the document.
>
> **Split out of `FlatWireJiraStories.md` on 13 Aug 2026**, mirroring the effort split of the same day. That file's
> Epic 10 and Epic 11 headings are retained there as pointers, and its Backlog Summary marks both epics *moved*.

> ## ⚠ Phase 12 is wholly deferrable — these four stories *are* descope rungs 1–4
>
> Every story here is on the descope ladder, and together they are the whole of it for this phase. Rung 4 is the
> **remainder** of the phase, not the phase again, so the ladder is additive with no double-counting. **Latest call:
> W6.** Full analysis in [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) §4.

---

## 1. Story inventory

| Story | Title | Pts | Priority | Rung | All-in h *(hand → AI)* | Dev h *(hand → AI)* | Scope |
|---|---|---|---|---|---|---|---|
| `FW-110` | Scrap module — new outlet selection | 2 | Low | **1** | 33 → **23** | 24 → **16** | MVP-1 |
| `FW-102` | Cost Ledger — flat wire costing config | 3 | Medium | **2** | 49 → **35** | 36 → **25** | MVP-1 |
| `FW-101` | Weld traceability in yield reporting | 3 | High | **3** | 28 → **21** | 20 → **15** | MVP-1 |
| `FW-100` | Footage-based weight calculation | 3 | High | **4** | 67 → **47** | 48 → **33** | MVP-1 |
| | | **11** | | | **177 → 126** | **128 → 89** | |

**Rung 4 is larger than `FW-100` alone.** It is the phase *remainder*: the footage-based weight service plus the yield
form work. `FW-100` is the only story in it, so its 3 points are priced alongside deliverables that have no story —
which is why rung 4's development hours per point (11.0) sit well above the other three (8.0 / 8.3 / 5.0).

**`FW-100` spans two phases.** It is *delivered* in **Phase 9** (the calculated net weight appears on Dashboard 7,
`FR-332`/`FR-332a`) and *consumed* here in the yield module. `back-matter.md` Appendix C writes this as `9 (yield 12)`.
Its Phase 9 delivery is costed in that phase, not here.

---

## 2. Epics

# EPIC 10 — Coil Yield & Cost Ledger (FW-E10)

**Goal:** Update yield calculation for footage-based weight, support weld traceability in yield, and configure the cost ledger for flat wire costing.
**Sprint:** ~~5~~ → **Phase 12**
**Priority:** ~~Medium — required by August 1 production.~~ → **Medium** — required for production, first onto the descope ladder. *(The August 1 target was withdrawn 26 Jul 2026; the window is 17 Aug – 30 Sep 2026.)*
**Stories:** 3 · **Points:** 9

---

### FW-100 · Footage-based weight calculation
**Points:** 3 · **Priority:** High · **Sprint:** 5 *(→ Phase 9 delivery, Phase 12 yield consumption)*

**As a** production supervisor,
**I want** output coil weight calculated from footage rather than scale weight during production,
**So that** weight is tracked accurately in real-time without a physical scale at TKUP-2.

**Acceptance Criteria:**
- [ ] Weight = Footage × (cross-section area × alloy density) — formula confirmed by Tim O. / Bob S. (OQ-10)
- [ ] Conversion factor is looked up per alloy and cross-section from the alloy properties table
- [ ] Calculated weight shown on Dashboard 7 (Output Coil Completion) as Net Weight
- [ ] Operator can override calculated weight with scale weight if scale is available
- [ ] Footage-to-weight factor is maintainable in the alloy lookup table without a code change

**Dependencies:** FW-004
**Open Questions:** OQ-10 (footage-to-weight conversion formula) must be confirmed before implementation.

> **Requirement coverage — the only story here that has any.** `FR-332` and **`FR-332a`** specify the formula, and
> `FR-332a` explicitly rules that the mockup's `14,200 ft × 0.069 lb/ft` **shall not be implemented** (0.069
> back-solves to ρ = 0.0836 lb/in³, which is not aluminium; `spool_notification.js`'s `24,900 ft × 0.0809 = 2,014 lb`
> is the correct reference). Both sit in `02-SRS.md` §5.16, which maps to **DB7 / Phase 9** — so the formula is
> specified against Phase 9 and *consumed* here with no Phase-12 requirement of its own.

---

### FW-101 · Weld traceability in yield reporting
**Points:** 3 · **Priority:** High · **Sprint:** 5

**As a** production controller,
**I want** yield reporting to attribute output footage to each source rod through weld points,
**So that** metallic yield is calculated correctly per rod heat for welding wire customers.

**Acceptance Criteria:**
- [ ] Footage split at each weld point is recorded and retrievable
- [ ] Yield report shows: Rod Alpha | Footage Contributed | Output Alpha | Order | Yield %
- [ ] Multi-rod runs (2+ welds) produce multi-row yield attribution
- [ ] "Flat Wire" checkbox added to the yield form
- [ ] Field renames applied: "Outgoing Gauge" → "Outgoing Gauge/Diameter"; "Coil #" → "Coil/Bundle #"; "Gauge" → "Gauge/Diameter"

**Dependencies:** FW-063, FW-090
**Open Questions:** OI-60 (expected metallic yield per route)

> **⚠ Two defects on this story, both raised 13 Aug 2026.**
>
> **(1) Its dependencies are stated two different ways.** `FW-063, FW-090` here; **`FW-095`** in
> `ProjectPlan/05-SprintPlanAndBacklog.md`. Both cannot be right, and this story is on the critical path for the
> welding-wire certificates.
>
> **(2) The last two acceptance criteria are attributed to a different descope rung.** The ladder puts the **yield
> form** in **rung 4** (*"footage-based weight + yield form"*), but the checkbox and the field renames are written as
> `FW-101`'s acceptance criteria — and `FW-101` is **rung 3**. So **deferring rung 3 per the ladder would defer two
> criteria the ladder believes it is keeping.** Resolve before the W6 descope call: either move those two criteria to
> a rung-4 story, or restate rung 3 as including the yield form. Effort is unaffected either way — both rungs are in
> the same phase — but the *descope decision* is not.

---

### FW-102 · Cost Ledger — flat wire costing configuration
**Points:** 3 · **Priority:** Medium · **Sprint:** 5

**As a** cost accountant,
**I want** flat wire cost reporting configured in the Cost Ledger,
**So that** wire production costs are reportable separately from coil costs.

**Acceptance Criteria:**
- [ ] Ability to report wire separately (similar to B2B capability)
- [ ] Standard times for FL1, FL2, FL3 loaded once confirmed by Tim O. / Jeff G. (OI-68)
- [ ] Industry code question resolved (OI-68) before costing standards are applied
- [ ] Placeholder configuration deployed; full activation after OI-68 is decided

**Dependencies:** FW-003
**Open Questions:** OI-68 (costing standards, industry codes, standard times per machine)

> **This story's configuration is a load-bearing TBD** — one of only four in the plan (`OI-92`, `REVIEW.md` #55).
> **`OI-68` has a recorded, buildable reading:** use the **existing industry codes unchanged by route**, and derive
> **provisional standard times arithmetically from the throughput rates owed as `OI-82`**, published visibly marked
> provisional and refined from run data after the trial. Waiting for authored standard times blocks the yield module
> for the whole build; a visibly provisional figure does not.

---

# EPIC 11 — Scrap Management (FW-E11)

**Goal:** Add the new Scrap Box / Scrap Skid outlet selection to the Scrap module and confirm scrap handling flows for flat wire.
**Sprint:** ~~5~~ → **Phase 12**
**Priority:** Low — post go-live acceptable.
**Stories:** 1 · **Points:** 2

---

### FW-110 · Scrap module — new outlet selection
**Points:** 2 · **Priority:** Low · **Sprint:** 5

**As a** scrap operator,
**I want** to select "Scrap Box" or "Scrap Skid" as the scrap outlet when logging flat wire scrap,
**So that** wire scrap is routed to the correct physical container.

**Acceptance Criteria:**
- [ ] New outlet selection in Scrap module: `Scrap Box` | `Scrap Skid`
- [ ] Selection applies to: Flat Wire, Conveyors, and Inspection systems
- [ ] Existing outlet options for coil scrap are unchanged
- [ ] Combining flat wire scrap with other scrap types: confirmed compatible (Ryan B.) — no system restriction added
- [ ] Bander material confirmation (steel vs. aluminum alloy — OI-83) must be resolved before physical packing spec is set

**Dependencies:** None
**Open Questions:** OI-83 (baler maximum dimensions, scrap banding material)

> **The software half is buildable now.** The `Scrap Box` | `Scrap Skid` vocabulary is settled; `OI-83` gates only the
> **physical** packing spec. **Do not read this story as already specified because the SRS mentions scrap** —
> `FR-063`/`FR-066` govern the scrap box **at rod check-in** and `FR-189`/`FR-273`/`FR-292` govern **WIP and
> balance-of-coil dispositions**. None of them describes outlet selection.

---

## 3. ⚠ Requirement coverage — this document is the only spec for three of four stories

| Story | `FR-` coverage | Owning specification |
|---|---|---|
| `FW-100` | `FR-332`, `FR-332a` — but filed under §5.16, which maps to **DB7 / Phase 9** | `OutputCoilCompletion.md` (Phase 9) |
| `FW-101` | **none** | **none** |
| `FW-102` | **none** | **none** |
| `FW-110` | **none** | **none** |

**Phase 12 has no owning requirement document** — it is not among the 17 files in `MVP-1/RequirementDocuments/` and has
no dashboard in the Dashboard Inventory. Every other phase in the plan has one. So the acceptance criteria above are
load-bearing in a way no other story file's are: **the 177 h estimate was priced against these four cards**, and
writing the missing specification is not inside it.

---

## 4. Effort and the points cross-check

Hours are owned by [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md); this document owns the **points**.

| Basis | Hours | Per point (11 pts) |
|---|---|---|
| All-in, hand-coded | 177 | **16.1 h** |
| All-in, AI-assisted | 126 | **11.5 h** |
| Development only, hand-coded | 128 | **11.6 h** |
| Development only, AI-assisted | **89** | **8.1 h** |

**At 8.1 development-hours per point, Phase 12 lands close to the conventional ~8 h (one day) per point** — but read
that as a coincidence of two large uncertainties, not a validation. The points are April-dated and the hours were
priced against four Jira cards; neither calibrates the other. The programme-level ratio and its investigation are in
[`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §3.

**Phase 12 is the second-least-compressible phase in the plan** — 28.8% all-in against Phase 14's 12.5% — because its
BE work carries the **0.75** retention factor, the least favourable in the plan. Phase 14 resists AI assistance because
it needs the mill; **Phase 12 resists because it needs decisions.**

---

## 5. Open questions blocking development

All four stories are blocked, and three of the four blockers are the client's to answer.

| OQ | Question | Blocks | Owner |
|---|---|---|---|
| **`Q10`** *(`OQ-10`)* | Footage-to-weight conversion factor — **`Critical`** | `FW-100`, `FW-066` | Tim O. / Bob S. |
| **`OI-60`** | Expected metallic yield per route; also whether the flat → flat re-pass route is real | `FW-101`, `FW-041` | Tim O. / Jeff G. |
| **`OI-68`** | Standard times per machine; costing standards / industry codes | `FW-102` | Tim O. / Jeff G. |
| **`OI-83`** | Baler maximum dimensions; scrap banding material (steel vs aluminium) | `FW-110` (physical packing spec) | Plant / Tim O. |

**`Q10` deliberately carries no recommendation** — the only one of the 33 open questions treated this way. The
dimensional basis it turns on (nominal or measured gauge and width, and whether the round edge is corrected) is a
measurement question **UA must answer from its own practice**; a proposed default risks being adopted as the basis
rather than confirmed. Every derived weight in the system rests on it. Also tracked as **`OI-45`**.

**`OI-60` and `OI-68` are each the *sole* tracking home** for their subject — the corresponding register questions were
withdrawn on 12 Aug 2026, so there is no second place to look.

---

## Related Documents

| Document | Purpose |
|---|---|
| [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) | **The effort and scope home for Phase 12** — story-level hours on both bases, the descope ladder, the blocker analysis and the specification gap |
| [05-SprintPlanAndBacklog.md](./05-SprintPlanAndBacklog.md) | The other 55 stories / 220 points, the **sprint → phase crosswalk** these Sprint 5 tags resolve through, and the points legends |
| [`ShopfloorPlan/phase-12-yield-cost-ledger-scrap.md`](./ShopfloorPlan/phase-12-yield-cost-ledger-scrap.md) | The phase file — deliverable inventory |
| [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) | §3 the published 177 h and the programme points cross-check · §5 the descope ladder |
| [`DevelopmentEffortModel.md`](./DevelopmentEffortModel.md) | The AI-assisted factor card (§1). Its per-phase table **excludes** Phase 12 |
| [`../ProjectPlan/02-SRS.md`](02-SRS.md) | `FR-332`/`FR-332a` (weight formula) · `FR-063`/`FR-066`/`FR-189`/`FR-273`/`FR-292` (scrap, **not** `FW-110`) |
| [`../../Analysis/FlatWireOpenQuestions.md`](../../Analysis/FlatWireOpenQuestions.md) | **`Q10`** — Critical, and the one question carrying no recommendation by decision |
