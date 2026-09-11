---
id: FS-20
title: Unscheduled and Unhosted Requirements
phases: []
requirements: [FR-001-022, FR-270-277, FR-280-282, FR-500-508]
screens: [OEE]
jira:
owner:
---
# FS-20 · Unscheduled and Unhosted Requirements

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — the single source of truth for this functional area
**Status:** ✅ **Authored and current** — **holds no story by design**; that is what it records. No card, so no acceptance criteria to carry.
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

**Business purpose.** **This category exists to make four sets of requirements visible that no
other structure can hold.** They are numbered, they are in the requirements document's coverage
matrix, and they have **no phase, no owner, no hours and no task file**. Under the old
sprint → phase → story shape there was nowhere to put them, so they were recorded in an appendix
and effectively invisible. A functional axis can hold them; a delivery axis cannot.

⚠ **This is a correctness fix, not a granularity choice.** A category map built from task files
would silently lose all four ranges, because none of `FW-N08`–`FW-N11` has a card or a file. This
file is built from `[TB §11]`, `§11.1`, appendix B.4 and B.5 — **the registers, not the backlog.**

**What is here:**

| Requirements | Subject | Why it is here |
|---|---|---|
| **`FR-001`–`022`** | Cross-cutting — identity, ordering, alphas, footage, dates, integration | `FW-N11` (operator session) is **uncosted**. Cited against Phase 6, never scheduled. *(Was "Operator session / `ITInhibit`"; split 14 Aug 2026, and the `ITInhibit` half is built under `FS-04`)* |
| **`FR-270`–`277`** | Stop transaction and output of rolling | `FW-N10` (stop popup) is **uncosted, with no phase assignment** |
| **`FR-280`–`282`** | Wire break | `FW-N08` is **blocked with no persistence target** — a decided flow that has nowhere to write |
| **`FR-500`–`508`** | OEE dashboard | `FW-N09` has **no phase and no owner** (`PP-03`), is MVP-2, and its mockup lives in the MVP-2 folder |

**Out of scope.**

- **Anything that has a phase.** If work is scheduled, it belongs to its functional category. This
  category is defined by the absence.
- **The `ITInhibit` interlock**, which was split out of `FW-N11` on 14 Aug 2026 and **is built** —
  `FW-205` under [`FS-04`](FS-04-realtime-plc-backbone.md), with `FW-206` and `FW-257` extending it.
- **The withdrawn requirements.** `FR-440`–`FR-470` (DB13 HMI schematic, DB14 SCADA trends) were
  **descoped by the client on 4 Aug 2026** — withdrawn entirely, not deferred. They are not
  unhosted; they are gone, and `[REQ §5.21]`/`§5.22` are struck.
- **`FW-N12`** (de-stub pass), which is `Retire` rather than `Retain`: absorbed in practice by
  `FW-166` and `FW-201`.

---

## 2. Consolidated existing stories

**No card and no task file maps here** — **5** retained ids, per
[`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md). Four are `Retain`; `FW-N12` is
`Retire`.

<!-- BEGIN GENERATED: absorbed-stories -->

*No story maps here. This category is authored from specifications and registers, not from the backlog - see `[SCM §2.3]`.*

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

Owned ranges, from [`[SCM §2.2]`](../../90-registers/StoryConsolidationMap.md): **FR-001-022**
(`[REQ §5.0]`), **FR-270-277** (`[REQ §5.12]`), **FR-280-282** (`[REQ §5.13]`) and **FR-500-508**
(`[REQ §5.24]`) — **42 requirements**. **Cited, never restated.**

Three of the four still have a live `[REQ]` section; `FR-500`–`508`'s was folded into the MVP-2
index row. So unlike `FS-05` and `FS-17`, **the requirements here are written down** — they are just
not scheduled. That distinction matters: this is a *delivery* gap, not a *specification* gap.

⚠ **`[TB §11]` asserts *"All 363 requirements map to a story."* It is true only in the weakest
sense** — these four map to ids that carry no hours, no phase and no file. §11.1 is more honest,
listing `FR-280`–`282` as *"Not deliverable"* and `FR-500`–`508` as *"Not scheduled"*.

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

**No stream has an activity here, by definition.** What each *would* need, if any of the four were
scheduled:

| Stream | What scheduling this would require |
|---|---|
| **FE** | The OEE dashboard has an **approved mockup and 17 source requirements** and no story (`PP-03`) — the one item here that is design-complete and delivery-absent. The stop popup and the wire-break flow are both dialogs |
| **BE** | A stop-transaction endpoint and a wire-break capture endpoint. Neither is in `[API]`'s 32 endpoint rows |
| **DB** | ⛔ **The blocking gap: wire break has no persistence target.** No table, no column, nowhere to write. Any schedule decision starts here, and `FS-03` would own it |
| **RT** | A wire break is a line event and would need a hub member; OEE needs a metrics feed |
| **BA** | ⚠ **Unassigned.** Four items need a scope decision — schedule, defer explicitly, or record as out of scope — and nobody owns making it |

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

*No activity in this category cites a blocker.*

<!-- END GENERATED: blockers -->

⚠ **The generated table above is empty, and that is the finding.** `blocked_by:` is a field on task
files, and there are none here — so the blockers on these four items are recorded **only** in
appendix B.4 and `[TB §11.1]`, where no checker reads them and no board shows them. **Four sets of
requirements are blocked and the tooling cannot see it.**

**Gaps this category owns, from the registers:**

- ⛔ **Wire break is blamed on two different blockers.** Appendix B.4 says **`G34`**; `[TB §11.1]`
  says **`OI-13`**. Both describe the same absence — a decided flow with no persistence target —
  and they are not the same register item. **One of the two is wrong and nothing reconciles them.**
- ⛔ **`PP-03` — the OEE dashboard has an approved mockup and 17 source requirements, and no story,
  no phase and no owner.** It is the clearest single instance of design running ahead of delivery
  in the whole module.
- **`FW-N10` and `FW-N11` are uncosted**, so they appear in no capacity figure. Scheduling either
  is an addition to `[CE]`, not a re-apportionment — the treatment `D-55` and `D-56` established.
- **`FW-N07`–`FW-N12` are minted but fileless**, and `TaskIdMap.md` rule 6 records that they are
  **not free to reuse** — re-using one would collide with citations in about a dozen documents.
- ✅ **`[TB]`'s next-free-id figure was stale in three places at once — corrected 9 Sep 2026.**
  Appendices B.9, B.10 and B.11 each stated *"Next free `FW-N##` id: `FW-N31`"* while `FW-N31`,
  `FW-N32` and `FW-N33` all held a card and a `[SCM]` row. One number, asserted three times, wrong
  three times — the exact failure the cite-once convention exists to prevent, so **B.9 now asserts
  `FW-N34` and B.10/B.11 cite it.** ⚠ It had also been stale at `FW-N14` and `FW-N20`, so B.9 says
  the id must be **measured** — highest `FW-N##` in `[TB]` or `[SCM]`, plus one.
- ⚠ **These four need a decision, not a build.** `[TB §11.1]`'s own words for OEE: *"Either
  schedule it or record OEE as out of scope."* Neither has happened, and the requirements sit in
  the coverage matrix looking covered.

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 2. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories.** None today — nothing here is scheduled, so nothing here can depend or be
depended upon. If scheduled: wire break would need `FS-03` (a table), `FS-04` (a hub member) and
`FS-09` (it is an in-run event); the stop popup would need `FS-08` and `FS-12`; OEE would need
`FS-16`'s reporting views; the operator session would touch **every** category, being cross-cutting.

**On client decisions.** All four. Not one is an engineering question:

- **Wire break** — is it in scope, and if so where does it persist?
- **OEE** — schedule it, or record it as out of scope. `[TB §11.1]` asks exactly this.
- **Stop transaction** and **operator session** — cost them, or state they are not being built.

**On the registers.** This category's entire content lives in `[TB §11]`/`§11.1` and appendix
B.4/B.5. **It has no other source**, which is why `tools/build_consolidation_map.py` carries these
ids as literals rather than measuring them.

---

## 8. Change-impact profile

**What a change here affects.** Nothing, today — and that is precisely the risk this file exists to
make visible. Requirements that affect nothing are requirements nobody is delivering.

| A change to… | Affects |
|---|---|
| **scheduling wire break** | `FS-03` (a new table — the only remaining unbuilt schema need in MVP-1), `FS-04`, `FS-09`. It is the most expensive of the four because it starts with a schema change |
| **scheduling OEE** | `FS-16`'s reporting views, and `[CE]` additively. Design is already done — the mockup is approved |
| **scheduling the operator session** | **Every category.** `FR-001`–`022` is cross-cutting: identity, ordering, alphas, footage, dates |
| **recording any of them out of scope** | `[TB §11]`'s coverage claim, `[REQ]`'s section status, and the coverage matrix's total. **Cheap, and it is the change that makes the plan honest** |

**Existing implementation to modify.** None whatsoever. No table, no endpoint, no screen, no story.
The `ITInhibit` half of `FW-N11` is the sole exception and it has already left for `FS-04`.

**Regression areas.**

- **The coverage claim is the regression risk.** `[TB §11]` says all requirements map to a story,
  and a reader who trusts it will not look here. Anything that keeps these four out of scope
  should also correct that sentence.
- **Scheduling wire break is a schema change after `FS-03` has seeded.** Every week it stays
  undecided makes it more expensive, and it is the only MVP-1 requirement set still needing a new
  table.
- **The three stale next-free-id restatements** mean a new `FW-N##` minted from `[TB]`'s figure
  would collide with an existing story on its first use.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
