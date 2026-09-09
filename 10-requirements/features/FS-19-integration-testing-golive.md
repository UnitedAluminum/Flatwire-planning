---
id: FS-19
title: Integration Testing, Commissioning and Go-Live
phases: [14]
requirements: []
screens: []
jira:
owner:
---
# FS-19 · Integration Testing, Commissioning and Go-Live

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — **cross-cutting: verification**
**Status:** 🟡 **Authored** — §3 needs no acceptance criteria of its own; see below
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

**Business purpose.** Proving the module works against real controllers on a real floor, and
getting it into production. Three end-to-end scenarios — FL1 standalone, FL2 standalone, FL3 hybrid
— plus PLC commissioning support, UAT and stakeholder sign-off, a defect allowance, and the
operational moves that go with go-live.

⚠ **This is the one category permitted to index the others**, because it is where they are all
verified together. It is labelled **cross-cutting: verification** rather than functional, and it
carries the largest hour total of any category at 289 h — of which **112 h is QA and 64 h BA**, the
only category where those two streams dominate.

⛔ **Commissioning is what makes the PLC tag surface real.** `[PLC]` is v1.0 with **no
`[CONFIRMED]` tag by design** — a tag path becomes confirmed when commissioning test `C1`/`C11`
says the controller accepted it. Every tag path in the module is unconfirmed until this category
runs, which makes `FS-19` a *precondition of correctness* for `FS-04`, `FS-07` and `FS-13` rather
than merely their test.

⚠ **`[COM]` is safety-critical.** It sets preconditions, who must be present, `C1`–`C11` and the
abort criteria. It is not a document to skim.

**Functional scope.** Owned by
[`phase-14-integration-testing-plc-commissioning-golive.md`](../../60-delivery/phases/phase-14-integration-testing-plc-commissioning-golive.md),
cited not restated. Ten activities: the three E2E scenarios; UAT and sign-off; PLC commissioning
support; the defect allowance and renamed-column regression; the OPC sidecar adapter; moving
`FlatWireDB` into the `ual-database` repository; re-deriving the DB-stream total; and repairing the
development-plan generator.

**Out of scope.**

- **Unit and component tests.** Those belong to the category that owns the code —
  `FW-263`–`FW-267` are [`FS-02`](FS-02-backend-service-foundation.md)'s.
- **The hub load test** — [`FS-06`](FS-06-line-visibility-alerting.md), because Dashboard 1 holds
  the most concurrent connections.
- **The simulator.** `FW-203`, `FW-210`–`FW-215` and the `DB-S1` console are
  [`FS-04`](FS-04-realtime-plc-backbone.md)'s. ⚠ The **OPC sidecar** (`FW-217`) is here because it
  exists to stand in for a real OPC UA server during commissioning.
- **Rollback rehearsal**, which `[RB]` requires before the first production deployment and which
  belongs to `[DEP]`'s operational sequence.

---

## 2. Consolidated existing stories

Per [`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md); the count and the list are generated below.

<!-- BEGIN GENERATED: absorbed-stories -->

> ⚙ **Written by `tools/build_features.py`, now hand-maintained** — the task files it derived from have been retired, so this table is the single writable record of status for this category. Keep the columns exactly as they are; `--check` and `FEATURES.md` both parse them.

**10 absorbed stories**, seeded one activity each. **Activities are expected to merge downward** as work proceeds — `FW-N17`/`N18`/`N19` are one rename, not three.

| Ref | Activity | Streams | Status | Depends on | Blocked by |
|---|---|---|---|---|---|
| `FW-120` | E2E FL1 standalone | QA | ⬜ not-started | — | — |
| `FW-121` | E2E FL2 standalone | QA | ⬜ not-started | — | **OQ-15** **OQ-17** |
| `FW-122` | E2E FL3 hybrid | QA | ⬜ not-started | — | **G30** **OQ-15** |
| `FW-123` | UAT and stakeholder sign-off | BA·QA | ⬜ not-started | — | — |
| `FW-200` | PLC commissioning support | RT | ⬜ not-started | FW-082 FW-151 FW-190 | **G29** **G30** **PLC-Q04** **PLC-Q05** |
| `FW-201` | Defect allowance and renamed-column regression | FE·BE·DB·QA | ⬜ not-started | FW-001 FW-120 FW-121 FW-122 | — |
| `FW-217` | OPC sidecar adapter — the models behind a test-only OPC UA server | RT | ✅ done | FW-210 FW-211 FW-N05 | **G32** **G33** **G59** **G60** |
| `FW-242` | Move FlatWireDB into the ual-database repository | DB | ⬜ not-started | FW-152 FW-241 | — |
| `FW-249` | Re-derive the DB-stream total on the current basis | BA | ⬜ not-started | — | — |
| `FW-250` | build_development_plan_xlsx.py silently drops every multi-stream s | DB | ⬜ not-started | — | — |

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

**This category owns no `FR` range, and that is correct.** It verifies requirements rather than
adding any. Its authorities are `[TS]` (strategy and gates), `[TCS]` (the case catalogue and
coverage matrix), `[UAT]` (participants, scripts, sign-off), `[COM]` (`C1`–`C11`, safety-critical)
and `[DEP]`/`[RB]` for the deployment and rollback sequence.

⚠ **`[NFR]` records that four NFR targets are undefined, so those tests cannot fail.** That is this
category's problem more than anyone's: it holds the tests, and four of them are unfalsifiable. The
same absence appears as `G9`/`OI-34` under `FS-06`.

⚠ **`FW-201` is a "defect allowance and renamed-column regression" at 56 h.** The renamed-column
half is worth reading carefully: **`D-32` cancelled the shared-schema renames**, so the regression
it was scoped against largely does not exist any more, while `D-56`'s `LineId` → `MachineName`
rename *does* — a different rename, in `FlatWireDB` rather than the shared schema. Whether the 56 h
still describes the work is unverified here.

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

| Stream | Scope |
|---|---|
| **QA** | **112 h, the dominant stream.** Three end-to-end scenarios — FL1 standalone, FL2 standalone, FL3 hybrid — and the QA half of the defect allowance |
| **BA** | **64 h.** UAT and stakeholder sign-off at 56 h, the largest single activity here, plus re-deriving the DB-stream total |
| **RT** | **PLC commissioning support** at 40 h, and the **OPC sidecar adapter** — the only `done` activity in this category |
| **DB** | Moving `FlatWireDB` into the `ual-database` repository, and repairing the development-plan generator's multi-stream defect |
| **FE / BE** | Only through `FW-201`'s regression pass, which spans all four build streams |

⚠ **`FW-250` is this category's most self-referential activity:** *"`build_development_plan_xlsx.py`
silently drops every multi-stream story"* — a defect found by running the generator during
verification of the very story set that introduced it. It is also the exact defect this
consolidation makes worse, since every consolidated story is multi-stream.

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

> ⚙ **Generated by `tools/build_features.py`.** Do not edit inside the markers - the union of `blocked_by:` across this category, which exists in no other document.

**10 register items cited by 4 of 10 activities** - **8 open**, **2 resolving to no register** (`G61`).

| Item | State | Blocks | What is missing |
|---|---|---|---|
| **`G30`** | ⛔ open | `FW-122` · `FW-200` | FM2's controller namespace on FL3 is undetermined, and it decides what partial failure means. Every published tag map ad |
| **`OQ-15`** | ⚠ no register | `FW-121` · `FW-122` | **Retired prefix resolving to nothing** - needs retargeting or removal (`G61`) |
| **`G29`** | ⛔ open | `FW-200` | No edger tag path exists on any line, yet edge type is in the push payload. Four of five sources list edge type among th |
| **`G32`** | ⛔ open | `FW-217` | The FM2 PLC station names in the spec are ours, not the controller's. The 4 Aug 2026 roller-size correction established |
| **`G33`** | ⛔ open | `FW-217` | The measure segment of every tag is ours, not the controller's — and it departs from thirteen observed strings. On 4 Aug |
| **`G59`** | ⛔ open | `FW-217` | No service identity exists for a PLC write that no operator initiated. ✅ Mechanism confirmed by executing FW-151 on 28 A |
| **`G60`** | ⛔ open | `FW-217` | ⚠ HALF CLOSED 6 Sep 2026 — the registration EXISTS on DEV00164-001; the running service is still unproven. 11_ ran and c |
| **`OQ-17`** | ⚠ no register | `FW-121` | **Retired prefix resolving to nothing** - needs retargeting or removal (`G61`) |
| **`PLC-Q04`** | ⛔ open | `FW-200` | Confirm the FM2 station names — S1, S2, S3, carrying position only (§4.3). Every FM2 row in §5.2.2 is [PROPOSED] until t |
| **`PLC-Q05`** | ⛔ open | `FW-200` | Confirm every measure name in §5.2 — RollGap, Gauge, Width, Footage, Diameter, Weight, Status.IsActive, Status.IsFaulted |

<!-- END GENERATED: blockers -->

**Ten items, and six of them say the same thing: the tag surface is ours, not the controller's.**

- ⛔ **`G32` — the FM2 PLC station names in the specification are ours, not the controller's**, and
  **`G33` — the measure segment of every tag is ours too.** Together with **`G29`** (no edger tag
  path exists on any line, yet edge type is in the push payload) and **`G30`** (FM2's controller
  namespace on FL3 is undetermined), the position is that **a substantial part of `[PLC]`'s tag
  surface is a proposal awaiting a controls engineer.** `PLC-Q04` and `PLC-Q05` are the formal
  send-backs for the station names and the measure names.
- ⛔ **`G59` — no service identity exists for a PLC write that no operator initiated.** Blocks
  `FS-07`'s `FW-237` as well as commissioning.
- **`G60`** — ⚠ **half closed, 6 Sep 2026.** The `OPCConnection` registration **exists on
  `DEV00164-001`**; the other half does not. A half-closed blocker is easy to read as closed.
- **`OQ-15`** and **`OQ-17`** resolve to no register (`G61`).

**Gaps this category owns that no story cites:**

- ⛔ **Four NFR targets are undefined, so four tests cannot fail.** `[NFR]` states it; nothing
  schedules the fix. A test suite with unfalsifiable members provides no regression protection for
  the properties it claims to cover.
- ⚠ **There is no exception-path E2E scenario.** The three scenarios are FL1, FL2 and FL3 happy
  paths. `FS-10`'s three checkout modes, WIP rejection, carry-forward and the supervisor approval
  queue are the module's least-tested behaviours and appear in none of them.
- ⚠ **`FW-241`'s deploy sign-off at `[DEP §4.2]` step 2 has never been passed**, and it is the gate
  in front of `FS-15` reaching any shared database. The story is `FS-03`'s; the gate is this
  category's concern.
- ⚠ **`FW-201`'s 56 h may be scoped against a cancelled rename** (§3 above).

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories — on all of them, by definition.** Its recorded edges are `FS-19` → `FS-03`,
`FS-04` and `FS-13`, with mutual pairs against `FS-04` (5 edges out, 1 back) and `FS-18`. But the
edge list understates it: **the three E2E scenarios exercise every operator-facing category**, and
`FS-13`'s acceptance *is* `FW-122`.

**On PLC and OPC — the binding external dependency.** Six of ten blockers are tag-surface items
that only a controls engineer can close, and commissioning cannot be scheduled against a proposed
tag map. `SimulatePLCTagPush` stands in until then, which means **every PLC interaction in the
module is currently unproven against real hardware.**

**On the deployment topology.** `FlatWireDB` must sit alongside `united_db`, `proddb` and `CommonDB`
on one instance for `FS-15`'s transaction to be atomic. `DEV00164-001` is where that was proven
(`is_local = 1`, `is_enlisted = 0`, 26 Aug 2026), and `DEVUAL-UADEV001\TEST1` is **retired** for
`FlatWireDB`. Moving the database into `ual-database` (`FW-242`) must not lose that co-location.

**On client and third parties.** UAT participants and sign-off (`[UAT]`), a controls engineer for
`PLC-Q04`/`PLC-Q05`, and whoever owns the step-2 deploy sign-off.

---

## 8. Change-impact profile

**What a change here affects.** Nothing functionally — and that is the wrong way to read it. What
changes here changes **what is known to be true** about every other category.

| A change to… | Affects |
|---|---|
| **a confirmed tag path** (`C1`/`C11`) | `FS-04`'s push, `FS-07`'s acknowledgement, `FS-13`'s two-controller write. **Until commissioning runs, all three are built against an unconfirmed surface** |
| **the E2E scenario set** | The only place `FS-15`'s six-database transaction and `FS-13`'s hybrid route are exercised end to end |
| **an NFR target** | Makes four currently-unfalsifiable tests falsifiable — which may turn a passing suite into a failing one, and that is the point |
| **the deployment topology** (`FW-242`) | `FS-15`'s atomicity guarantee, which is environment-dependent and silently degrades off a co-located instance |
| **the defect allowance** (`FW-201`) | The schedule. It is 56 h of contingency inside a category already at 289 h |

**Existing implementation to modify.** One activity is `done` — `FW-217`'s OPC sidecar, verified —
and the other nine are `not-started`. So the **stand-in for real hardware exists and the
commissioning against real hardware does not**, which is the expected order but worth stating: the
simulator's existence is not evidence about the controllers.

**Regression areas.**

- **This category is the module's only integration safety net, and it has holes.** Four
  unfalsifiable NFR tests and no exception-path scenario.
- **A commissioning finding invalidates built work.** If `C1` shows a tag path wrong, `FS-04` and
  `FS-07` change after they are built. That is the intended sequence, and it means their acceptance
  is provisional until this category runs.
- **`G60`'s half-closed state** is the kind of thing read as closed at a glance.
- **`FW-250` will get worse before it gets better.** The generator drops multi-stream stories, and
  consolidation makes every story multi-stream.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
