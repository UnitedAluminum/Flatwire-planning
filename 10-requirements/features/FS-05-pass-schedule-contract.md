---
id: FS-05
title: Pass Schedule - the consumer contract and ownership boundary
phases: [2]
requirements: [FR-360-391, FR-400-410]
screens: [DB9, DB9A]
jira:
owner:
---
# FS-05 · Pass Schedule - the consumer contract and ownership boundary

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — the single source of truth for this functional area
**Status:** 🟡 **Authored** — holds no story by design; §3 records where the requirements went
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

**Business purpose.** The pass schedule is the **master configuration record** for a run: which
stands are active, bypassed or skipped, what each is set to, and what the material is meant to
become. Rod check-in **acknowledges** one, and that acknowledgement is what pushes the PLC tags. It
is the single most depended-upon object in the module.

⛔ **This category exists because MVP-1 depends on something MVP-1 does not build.** Phase 2 moved
to MVP-2 **whole and unedited** on 11 Aug 2026 — all four screen and engine stories deferred
(`FW-010` data model and API, `FW-011` DB9A, `FW-012` DB9, `FW-013` Generate-from-Specs) with
`231 h`. `phase-04` states the position plainly: the pass schedule is *"an EXTERNAL dependency, not
a Phase-2 deliverable"* and MVP-1 *"builds no authoring UI and creates no schedule"*.

**So this category owns a consumer contract, not a backlog.** No card and no task file maps here.
What it owns is the boundary: what MVP-1 may assume about a pass schedule, where one comes from,
and what happens when there isn't one.

⚠ **The three `PassSchedule*` tables ARE MVP-1**, since `D-31` (15 Aug 2026) — `PassSchedule`,
`PassScheduleComponent` and `PassScheduleChangeLog` are built and their FKs enforced by
`FlatWire_DDL_RunAll.sql`, under [`FS-03`](FS-03-database-foundation.md). **Owning the table is not
owning the data.** MVP-1 reads pass schedules and never authors one.

⚠ **`phase-02`'s own scope call contradicts itself, and says so.** It reads *"Not deferrable — the
highest-priority dependency in the plan; gates every check-in phase"* — which remains true of MVP-1.
Deferring the phase did not remove the dependency; **it removed the thing MVP-1 depends on.**

**Out of scope.**

- **The three tables** — [`FS-03`](FS-03-database-foundation.md) builds and seeds them.
- **Authoring, the DB9/DB9A screens and the generation engine** — MVP-2, and `[PSG]` remains the
  authority on generation physics and arithmetic over `FR-380`–`FR-391` even while deferred.
- **The acknowledgement itself** — [`FS-07`](FS-07-rod-checkin-plc-config.md) owns check-in, and
  [`FS-04`](FS-04-realtime-plc-backbone.md) owns the tag push it triggers.
- **The mid-run override**, whose MVP-1 trigger is `FW-169` under
  [`FS-09`](FS-09-in-run-production-events.md). `FW-014`'s MVP-2 *sink* is retired as subsumed.

---

## 2. Consolidated existing stories

**No card and no task file maps here** — **5** retained ids, tracked but not absorbed, per
[`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md). That absence is the finding, not an
omission.

<!-- BEGIN GENERATED: absorbed-stories -->

*No story maps here. This category is authored from specifications and registers, not from the backlog - see `[SCM §2.3]`.*

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

Owned requirement ranges, from [`[SCM §2.2]`](../../90-registers/StoryConsolidationMap.md):
**FR-360-391** (`[REQ §5.18]`, Pass Schedule Management) and **FR-400-410** (`[REQ §5.19]`, Pass
Schedule List) — **39 requirements**. **Cited, never restated.**

⚠ **Neither range has a `[REQ]` section any more.** Both headings were folded into `[REQ]`'s MVP-2
index row, so the ranges survive only in `[TB §11]`. Their authorities are
[`PassScheduleManagement.md`](../screens/PassScheduleManagement.md) and — for the generation physics
of `FR-380`–`FR-391` — the client deliverable
[`PassScheduleGenerationSpec.md`](../screens/PassScheduleGenerationSpec.md) `[PSG]`. **Being
deferred does not demote `[PSG]`.**

**What MVP-1 actually requires of a pass schedule is written nowhere in this range.** The read
contract, the mandatory snapshot at acknowledgement and `PassScheduleId` as a cross-database
reference are spread across `phase-04`, `phase-09`, `[PLC §7.2]` and `[PLC §11.2]`. **Assembling
them into one stated contract is this category's first piece of real work.**

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

**No stream has an activity here in MVP-1**, and that is the correct answer rather than an empty
table. What each stream *consumes* is:

| Stream | What it consumes, and from where |
|---|---|
| **FE** | `pass-schedule-table` renders a schedule read-only, honouring `State ∈ {Active, Bypass, Skip}` — built in `FW-133` under [`FS-01`](FS-01-angular-application-shell.md). Active Run's Components card renders **from the run's pass schedule**, not from per-line markup (`D-55`) |
| **BE** | `PassScheduleController` and the read model. `[SVC §3.2a]` is explicit that `PassSchedule` is **deliberately not an aggregate root** — it is a read model, because MVP-1 never authors one |
| **DB** | The three tables and their four FKs, built under `FS-03`. `PassScheduleChangeLog` exists with nothing in MVP-1 writing to it |
| **RT** | The acknowledgement's tag push reads the schedule's component values. `[PLC §7.2]`/`§11.2` own the tag paths |
| **BA** | ⚠ **Unassigned, and this is the gap.** Nobody owns writing down what MVP-1 requires of a pass schedule, or how one comes to exist before go-live |

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

*No activity in this category cites a blocker.*

<!-- END GENERATED: blockers -->

**Gaps this category owns that no story cites** — and with no story here, *nothing* cites them:

- ⛔ **How pass schedules are authored and approved for MVP-1 is undefined.** This is the first
  open consequence recorded in the MVP-2 scope note, and it is unresolved. MVP-1 cannot start a run
  without an **Active** pass schedule, and MVP-1 has no way to create one. Either they are authored
  outside the system before go-live, or the deferral is not viable.
- ⛔ **`FW-082` is the only story in the whole backlog that depends on a deferred id.** It is
  `critical`, MVP-1, and it is *"PLC tag group push on check-in acknowledgement"* — the mechanism
  this category's data feeds — and it declares `depends_on: FW-010`, which is MVP-2 with no task
  file. `check_docs.py` reports that as a **warning** (`2-dep`), not an error, so **the single
  hardest scope contradiction in the plan is recorded at the lowest severity the checker has.**
- ⚠ **`phase-02` claims both `FW-061` and `FW-082` depend on `FW-010`.** Only `FW-082` does now;
  `FW-061`'s front-matter no longer names it. One of the two is stale and it is not clear which was
  intended.
- **`PassScheduleId` is an unenforced cross-database reference.** Nothing in `FlatWireDB` guarantees
  the schedule a run acknowledges still exists or still says the same thing.
- **`PassScheduleChangeLog` is a table nothing writes.** It is built, enforced and unreachable in
  MVP-1 — the change log for an object MVP-1 cannot change.
- **`231 h` is the only phase figure in its division published clean and unapportioned**, which
  makes it the cleanest number in the plan to re-admit if the deferral is reversed.

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories — inverted, and that is the point.** This category depends on nothing. Four
others depend on **it**: `FS-04` (the tag push reads component values), `FS-07` (check-in
acknowledges), `FS-08` (the Components card renders from it) and `FS-09` (the mid-run override
changes a stand's setting). `[SP]` sequences 2 → 4 for that reason, and the sequencing survived the
deferral even though the phase did not.

**On MVP-2.** Everything this category would build is there. The dependency does not run the other
way: MVP-2 does not need MVP-1's consumer contract, but MVP-1 needs MVP-2's data.

**On client decisions.** The unanswered question is not technical. **Where does an Active pass
schedule come from between go-live and MVP-2?** Until that is answered, `FS-07` has an entry
condition it cannot satisfy from inside the system.

---

## 8. Change-impact profile

**What a change here affects.** More than any other category, because everything reads it and
nothing else writes it.

| A change to… | Affects |
|---|---|
| **the read contract** — what MVP-1 may assume | `FS-07`'s acknowledgement, `FS-04`'s tag payload, `FS-08`'s Components card, `FS-09`'s override. **Four categories, and none of them states the contract itself** |
| **the three tables' shape** | `FS-03`'s DDL and every reader above. `FW-N23` is already changing it — the pass schedule now carries roll gap *and* target product gauge per stand, plus two edger reduction limits |
| **`State`'s vocabulary** | `FS-01`'s `pass-schedule-table`, which hard-codes `Active`/`Bypass`/`Skip` as a canonical enum, and `FS-03`'s `CHECK` constraints |
| **the deferral decision itself** | The largest single scope change available. It re-admits `231 h`, four stories and two screens, and closes `FW-082`'s dangling dependency |

**Existing implementation to modify.** ⚠ **The tables are built; nothing else is.** So a change to
the *schema* is already a migration, while a change to the *contract* costs nothing yet because the
contract has never been written down. **That asymmetry favours writing it now.**

**Regression areas.**

- **`FW-N23` is a live schema change to a table four categories read**, and none of those four has
  a story to re-verify against it, because none of them is built either.
- **The unenforced `PassScheduleId`** means a run can reference a schedule that has changed under
  it. There is no constraint and no test that would catch it.
- **Reversing the deferral is not just a costing change.** It re-admits requirements whose `[REQ]`
  sections no longer exist, so there would be nothing for a test case to trace to — the same
  condition `FS-17` is in.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
