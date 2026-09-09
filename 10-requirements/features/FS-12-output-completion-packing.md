---
id: FS-12
title: Output Completion, Labelling and Packing
phases: [9]
requirements: [FR-330-340, FR-345-352]
screens: [DB7, DB7b]
jira:
owner:
---
# FS-12 · Output Completion, Labelling and Packing

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — the single source of truth for this functional area
**Status:** 🟡 **Authored** — §3's merged acceptance criteria are still outstanding
**Owner:** —
**Audience:** Anyone changing this functionality, and anyone assessing the impact of a change to it
**Shortcode:** — *(derived from the specifications; **not** citable as a requirement)*
**Part of:** `10-requirements/features/` — index: [README.md](README.md)
---

> **Precedence.** This file is the single source of truth for **what this functional area is,
> what it requires, where it stands and what is open**. It is **derived** and it does not
> outrank the documents it cites: against a phase specification the phase specification wins,
> against a build record the record wins, and on any number `[CE §3e]` and `[TB §7.3]` win.
> Its absorbed-story table is generated - do not edit inside the markers. Full rules in
> [README.md](README.md).

---

## 1. Overview

**Business purpose.** Where a run becomes product. The coreless coil coming off TKUP-2 is given its
alpha, its weights and footage, its genealogy back to the rod or spool it came from, and its label;
then two coils go on a skid and the skid becomes a shippable unit. This is the last point at which
flat wire is a flat wire concern — after it, the coil belongs to costing, yield and shipping.

**Functional scope.** Owned by
[`phase-09-output-coil-completion-labeling-packing.md`](../../60-delivery/phases/phase-09-output-coil-completion-labeling-packing.md),
cited not restated. Ten activities: Dashboard 7 (Output Coil Completion) and Dashboard 7b (Packing
Station); the source-traceability table and skid tracker; the coil label and its print path;
`POST /coil/complete` and `GET /coil/{alpha}/label`; `CoilOutput`, `CoilTraceability` and the
non-overlap trigger; completion broadcasts; the `CoilCompleted` hub member; the footage-to-weight
converter; and the footage→weight basis analysis.

**Alpha format:** output coil is **`FW-#####-C##`**, with a mid-run child taking `…-A`.
⚠ **That is a coil alpha, not a story id, and there are 299 of them in this repository.** Any bulk
rewrite of `FW-` ids must exclude them.

**The traveler is fully digital** — no printing. **Coil and skid labels are still printed**, and
that print path is `FW-184`.

**Out of scope.**

- **The run that produced the coil** — [`FS-08`](FS-08-active-run-monitoring.md); and the spool it
  was finished from — [`FS-11`](FS-11-spool-lifecycle-fl2.md).
- **The six-database write set** that makes the coil visible to UA — `[INT §8.1]`, owned by
  [`FS-15`](FS-15-shared-schema-boundary.md). This category raises the transaction; `FS-15` owns
  where it lands.
- **Yield, cost and scrap** — [`FS-17`](FS-17-yield-cost-scrap.md) — and **certification** —
  [`FS-16`](FS-16-reporting-certification.md). Both consume this category's output.
- **Fulfilment rollup** — [`FS-14`](FS-14-order-allocation-fulfilment.md).

---

## 2. Consolidated existing stories

Per [`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md); the count and the list are generated below.

<!-- BEGIN GENERATED: absorbed-stories -->

> ⚙ **Written by `tools/build_features.py`, now hand-maintained** — the task files it derived from have been retired, so this table is the single writable record of status for this category. Keep the columns exactly as they are; `--check` and `FEATURES.md` both parse them.

**10 absorbed stories**, seeded one activity each. **Activities are expected to merge downward** as work proceeds — `FW-N17`/`N18`/`N19` are one rename, not three.

| Ref | Activity | Streams | Status | Depends on | Blocked by |
|---|---|---|---|---|---|
| `FW-066` | Dashboard 7 — Output Coil Completion | FE | ⬜ not-started | FW-183 FW-184 FW-185 | **OI-105** **OI-25** **OI-45** **OQ-10** |
| `FW-182` | Dashboard 7b — Packing Station | FE | ⬜ not-started | FW-066 FW-185 | **OI-104** **OI-105** **OI-106** **OQ-4** |
| `FW-183` | source-traceability-table and skid-tracker | FE | ⬜ not-started | FW-185 | **OI-25** **OI-99** |
| `FW-184` | coil-label and the print path | FE | ⬜ not-started | FW-185 | **OI-24** **OI-99** |
| `FW-185` | POST /coil/complete, GET /coil/{alpha}/label and their services | BE | ⛔ blocked | FW-139 FW-186 FW-171 | **OI-104** **OQ-10** |
| `FW-186` | CoilOutput, CoilTraceability and the non-overlap trigger | DB | 🔵 in-review | FW-007 | **G36** **OI-104** |
| `FW-187` | Completion broadcasts | RT | ⬜ not-started | FW-149 FW-185 | — |
| `FW-188` | Footage→weight basis and skid labelling | BA | ⬜ not-started | — | **OQ-10** |
| `FW-228` | Footage-to-weight converter | BE | ⬜ not-started | — | — |
| `FW-235` | CoilCompleted broadcast member | RT·FE | ⛔ blocked | FW-208 FW-080 FW-149 FW-136 FW-185 | **OI-140** |

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

Owned ranges, from [`[SCM §2.2]`](../../90-registers/StoryConsolidationMap.md): **FR-330-340**
(`[REQ §5.16]`, Output Coil Completion — DB7) and **FR-345-352** (`§5.17`, Packing Station — DB7b)
— **19 requirements**. **Cited, never restated.** Screen authority is
[`OutputCoilCompletion.md`](../screens/OutputCoilCompletion.md), which covers both.

⚠ **`FR-330`–`FR-340` is shared with [`FS-17`](FS-17-yield-cost-scrap.md).** `[TB §11]` names both
`FW-066` and `FW-100` as delivering it. The completion half is here; the yield half is there.

**The detailed acceptance criteria stay on the backlog cards, and that is deliberate.**
This category's 55 criteria across 10 cards were measured, and **only 7 % of the 1,222 in the
backlog cite any specification or `FR`** — they are original build detail (schema invariants,
seed values, deployment contracts, arithmetic rules), not a restatement of something upstream.
Merging them up would either lose them or make this file three times its size, so
[`[TB §7.2]`](../../60-delivery/TaskBreakdown.md) remains their home and this section is the
**index and the coverage assertion** over them.

⚠ **What is still owed here** is the coverage sweep, not a merge: confirming that every
criterion on every absorbed card resolves to a requirement range above, to a cited screen
specification, or to a stated gap in §6 — and that none is orphaned. That is the gate in front
of the deletion step and no tool can do it.

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

| Stream | Scope |
|---|---|
| **FE** | Four activities and 104 of 186 h. DB7's completion flow and DB7b's packing station; the **source-traceability table and skid tracker** at 40 h — the largest FE activity here, and the surface that shows a coil's genealogy; and the coil label with its print path |
| **BE** | `POST /coil/complete` and `GET /coil/{alpha}/label` with their services (`blocked`), plus the **footage-to-weight converter** — which sits here rather than in `FS-07` because completion is what consumes it |
| **DB** | `CoilOutput`, `CoilTraceability` and the **non-overlap trigger** — the one trigger in the MVP-1 build, which stops two coils claiming the same footage range. `in-review` |
| **RT** | Completion broadcasts, and the `CoilCompleted` hub member that `OI-140` records as missing |
| **BA** | The **footage→weight basis and skid labelling** (`FW-188`) — ⚠ and `FS-17` needs the same basis with no story of its own for it |

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

> ⚙ **Generated by `tools/build_features.py`.** Do not edit inside the markers - the union of `blocked_by:` across this category, which exists in no other document.

**11 register items cited by 8 of 10 activities** - **8 open**, 1 closed but still cited, **2 resolving to no register** (`G61`).

| Item | State | Blocks | What is missing |
|---|---|---|---|
| **`OI-104`** | ✅ closed | `FW-182` · `FW-185` · `FW-186` | ✅ CLOSED — 18 Aug 2026. The skid table is united_db..wip_skids, linked to coils through proddb..wip_skid_coils. Skid num — ⚠ still cited here |
| **`OQ-10`** | ⚠ no register | `FW-066` · `FW-185` · `FW-188` | **Retired prefix resolving to nothing** - needs retargeting or removal (`G61`) |
| **`OI-105`** | ⛔ open | `FW-066` · `FW-182` | Which of three weights is authoritative on the coil record is undecided. §3.3 calculates net weight from footage and den |
| **`OI-25`** | ⛔ open | `FW-066` · `FW-183` | Two footage coordinate systems. Run events use cumulative run footage; CoilTraceability.FootageFrom/To are coil-local. M |
| **`OI-99`** | ⛔ open | `FW-183` · `FW-184` | Lot number is undefined when a coil has more than one source rod, which is the normal case under continuous welded feed. |
| **`G36`** | ⛔ open | `FW-186` | Returning Phase 9 to MVP-1 imported three uncosted dependencies, all on the DB7b packing side. Phase 9 became wholly MVP |
| **`OI-106`** | ⛔ open | `FW-182` | Staging locations are undefined. FR-351 requires the packing station to assign a staging location when a skid closes, bu |
| **`OI-140`** | ⛔ open | `FW-235` | ⛔ A COMPLETED OUTPUT COIL IS NEVER BROADCAST — there is no hub member to send it on. FW-207 raises CoilCompleted and FW- |
| **`OI-24`** | ⛔ open | `FW-184` | Lot number has no column and no generator. GET /coil/{alpha}/label returns lotNumber and the label prints it. Escalated |
| **`OI-45`** | ⛔ open | `FW-066` | OQ-10 — footage-to-weight: the formula and the density source are now settled; the dimensional basis is not. §5.4 fixes |
| **`OQ-4`** | ⚠ no register | `FW-182` | **Retired prefix resolving to nothing** - needs retargeting or removal (`G61`) |

<!-- END GENERATED: blockers -->

**Eleven items, and four of them are about identity and measurement — what a coil *is* and how much
of it there is.**

- ⛔ **`OI-140` — a completed output coil is NEVER broadcast.** There is no hub member for it.
  `FW-235` is the 12 h answer and is `blocked`. Until then, nothing downstream learns a coil
  finished except by polling.
- ⛔ **`OI-24` — lot number has no column and no generator**, and `GET /coil/{alpha}/label` is
  specified to return one. Compounded by **`OI-99`**, which says the lot number is undefined when a
  coil has more than one source rod — **the normal case under continuous welding.** Together they
  mean the label has a field the system cannot populate.
- ⛔ **`OI-105` — which of three weights is authoritative on the coil record is undecided.** Three
  candidate weights, no ruling, and `FS-16`'s certificate and `FS-17`'s yield both read whichever
  it turns out to be.
- **`OI-106`** — staging locations are undefined, and `FR-351` requires the packing station to
  know them.
- **`OI-25`** — the two footage coordinate systems, shared with `FS-08` and `FS-11`.
- **`OI-45`** — the footage-to-weight formula and density source, shared with `FS-08`.
- **`G36`** — returning Phase 9 to MVP-1 imported three uncosted dependencies.
- ~~`OI-104`~~ — ✅ closed 18 Aug 2026: the skid table is `united_db..wip_skids`.
- **`OQ-4`** and **`OQ-10`** resolve to no register (`G61`).

**Gaps this category owns that no story cites:**

- ⚠ **Three open items converge on one question — *what number goes on the coil record?*** `OI-105`
  (which weight), `OI-25` (which footage), `OI-45` (which formula). All three have to be answered
  together, and each is currently tracked separately in a different category's list.
- ⚠ **The label has an unpopulatable field.** `OI-24` plus `OI-99` means the printed label's lot
  number cannot be produced for a welded coil, which is the common case. That is a **shipping**
  problem, not a screen problem.
- **`FW-188`'s basis serves two categories and only this one has the story.**

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories.** `FS-12` → `FS-02`, `FS-03`, `FS-04` and `FS-09`, with `FS-15` depending on
it (2 edges in, 1 out). Three categories consume its output: `FS-14`'s fulfilment rollup, `FS-16`'s
certificate and `FS-17`'s yield. **It is the module's hand-off point** — everything before it is
production, everything after is business.

**On `FS-15` — the hard one.** Completing a coil writes to **six databases** in one transaction:
`wip_skids` (united_db), `wip_skid_coils` (proddb), a finished-goods `coils` row,
`coil_gen_history`, `coil_slit_cuts` (SlitterDB), `wip_log` (wiplogdb, 44 `NOT NULL` columns) and
`coil_cost`. This category raises it; `FS-15` owns whether it lands correctly, and eight of `FS-15`'s
client questions are about the values this transaction has to supply.

**On client decisions.** `OI-105`'s weight, `OI-24`/`OI-99`'s lot number, `OI-106`'s staging
locations. The lot number is the one with a shipping consequence.

---

## 8. Change-impact profile

**What a change here affects.** Everything downstream of production, plus the shared schema.

| A change to… | Affects |
|---|---|
| **the authoritative weight** (`OI-105`) | `FS-16`'s certificate, `FS-17`'s yield, `FS-15`'s `coil_cost` write. **Three consumers, one undecided value**, and one of them is contractual |
| **the lot number** (`OI-24`, `OI-99`) | The printed label, `FS-16`'s certificate traceability, and `FS-07`'s weld capture if attribution needs a field it does not record |
| **the coil alpha format** | 299 existing `FW-#####-C##` references in this repository, plus `FS-15`'s shared coil master registration (`G54`) |
| **`CoilTraceability`'s genealogy** | `FS-16`'s `NFR012` — the contractual weld-joint traceability — and `FS-11`'s spool traceability upstream of it |
| **the non-overlap trigger** | `FS-03`'s schema. It is the only trigger in the MVP-1 build |

**Existing implementation to modify.** One activity is `in-review` — `FW-186`'s tables and the
non-overlap trigger — and two are `blocked`. So **the schema that records a coil is settling while
`OI-105` leaves it undecided which weight the record should hold.** That is the same inversion as
`FS-10` and `FS-11`, and here it has a contractual consumer.

**Regression areas.**

- **`OI-105`, `OI-25` and `OI-45` must be answered as a set.** Answering one alone produces a
  coil record whose numbers are internally inconsistent, and the inconsistency surfaces in a
  certificate or a yield report rather than here.
- **The six-database write is the module's widest transaction** and its failure mode is a
  half-visible coil. `FS-19`'s E2E scenarios are the only place it is exercised.
- **The label print path is the only remaining printed artifact.** The traveler is fully digital, so
  a regression in printing has no fallback.
- **A bulk `FW-` id rewrite would corrupt 299 coil alphas.** `tools/fix_task_links.py` carries the
  guard and a pre/post count assertion; anything new must reuse it.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
