---
id: FS-15
title: The Shared-Schema Boundary
phases: [4, 9]
requirements: [FR-509-518, FR-519-528, FR-529-532, FR-561-570]
screens: []
jira:
owner:
---
# FS-15 · The Shared-Schema Boundary

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — **an integration contract**, not a user-facing feature
**Status:** ✅ **Authored and current** — ⛔ *§3 carries no acceptance criteria of its own, and that is settled, not outstanding: measured, only 7 % of the 1,222 criteria cite any spec or `FR`, so they are original build detail and stay on their `[TB §7]` card. See [`README.md`](README.md).*
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

**Business purpose.** Everywhere flat wire touches United Aluminum's existing databases. Rod
arrives through the shared `coils` schema and has to be ingested; a check-in has to claim a WIP
station and reserve the order; a finished coil has to appear to costing, yield, shipping and the
coil master as an ordinary UA coil. This is the seam, and it is the only place in the module where
a defect damages data that predates the project.

⚠ **Declared an integration contract, not a feature**, and separated from
[`FS-14`](FS-14-order-allocation-fulfilment.md) for exactly that reason. Nobody operates it and no
screen shows it; four other categories depend on it being right.

⛔ **`D-32`, 18 Aug 2026: there is no shared-schema migration.** The existing `coils` and scheduling
schema is **read and written as it stands and never altered** — no rename, no new column, no new
status value. `FW-001` and `FW-002` are cancelled. `INFLAT` is a `FlatWireDB`-local status and never
enters the shared vocabulary. Every write in this category lands in a column that **already
exists**, and `[REQ §5.25]` says so explicitly.

⚠ **The transactional guarantee is real but partial.** Check-in spans `FlatWireDB` and the shared
databases in **one `SqlTransaction`** under the local transaction manager with **no MSDTC**
(`[INT §8.0]`, `[ARC §10]`). That works only because the databases are **co-located on one
instance** — which is why `FlatWireDB` must deploy to the shared instance and not to LocalDB, and
why `DEV00164-001` is the instance where atomicity was actually proven. **The database half is one
ACID transaction; the PLC half is compensation, not rollback.**

**Functional scope.** `[REQ §5.25]`–`§5.27` and `§5.30`. Five activities: FL2/FL3 run-end
write-back; FL1/FL3 check-in write-back; station release and reqsum reversal; rod ingestion into
the flat wire tables; and registering every flat wire alpha in the shared coil master.

**Out of scope.**

- **`FlatWireDB`'s own schema** — [`FS-03`](FS-03-database-foundation.md).
- **The allocation being reserved** — [`FS-14`](FS-14-order-allocation-fulfilment.md).
- **The operator actions that trigger these writes** — check-in is
  [`FS-07`](FS-07-rod-checkin-plc-config.md), completion is
  [`FS-12`](FS-12-output-completion-packing.md), spool check-in is
  [`FS-11`](FS-11-spool-lifecycle-fl2.md).
- **Altering anything shared.** By `D-32`, out of scope permanently rather than deferred.

---

## 2. Consolidated existing stories

Per [`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md); the count and the list are generated below.

<!-- BEGIN GENERATED: absorbed-stories -->

> ⚙ **Written by `tools/build_features.py`, now hand-maintained** — the task files it derived from have been retired, so this table is the single writable record of status for this category. Keep the columns exactly as they are; `--check` and `FEATURES.md` both parse them.

**5 absorbed stories**, seeded one activity each. **Activities are expected to merge downward** as work proceeds — `FW-N17`/`N18`/`N19` are one rename, not three.

| Ref | Activity | Streams | Status | Depends on | Blocked by |
|---|---|---|---|---|---|
| `FW-219` | FL2/FL3 run-end write-back into the shared schema | DB·BE | ⬜ not-started | FW-066 FW-141 FW-142 FW-144 | **OI-114** **Q34** **Q35** **Q36** |
| `FW-220` | FL1/FL3 check-in write-back into the shared schema | DB·BE | ⬜ not-started | FW-157 FW-159 FW-141 FW-142 FW-144 FW-003 | **OI-115** **OI-116** **Q37** **Q38** **Q39** |
| `FW-221` | Station release and reqsum reversal | DB | ⛔ blocked | FW-220 FW-222 FW-174 FW-185 FW-202 | **Q40** |
| `FW-223` | Rod ingestion — populating the FlatWire tables | DB·BE | ⬜ not-started | FW-007 FW-142 FW-144 FW-157 FW-158 FW-159 FW-220 | — |
| `FW-231` | Register every flat wire alpha in the shared coil master | DB·BE | ⛔ blocked | — | **G54** |

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

Owned ranges, from [`[SCM §2.2]`](../../90-registers/StoryConsolidationMap.md): **FR-509-518**
(`[REQ §5.25]`, run-end write-back), **FR-519-528** (`§5.26`, check-in write-back), **FR-529-532**
(`§5.27`, inbound ingestion) and **FR-561-570** (`§5.30`, welded-coil part alphas and the shared
coil master) — **33 requirements**. **Cited, never restated.**

⚠ **Two things about this range that a reader must not miss.**

1. **Every requirement in these sections is `[PROPOSED]` and none has been client-reviewed.** They
   were written from the shared schema's own DDL rather than from a client requirement — there is no
   `.docx` source. That is why eight of this category's eleven blockers are client questions.
2. **`[TB §11]`'s coverage matrix has no row for any of them.** Its live ranges stop at `FR-508`, so
   all 33 fall outside every range it lists while it claims complete coverage.

**The detailed acceptance criteria stay on the backlog cards, and that is deliberate.**
This category's 51 criteria across 5 cards were measured, and **only 7 % of the 1,222 in the
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
| **FE** | **None.** Every activity is server-side. `[REQ §5.25]`'s own header reads *"Screen: none — this is a server-side transaction raised by DB7's Confirm & Move to Packing"* |
| **BE** | All five. The transaction orchestration, the compensation logic for the PLC half, and the alpha registration |
| **DB** | All five, and this is the category's centre of gravity. Five stored procedures under `30-database/scripts/` write the shared side: `sp_IngestRodFromCoils`, `FlatWire_CheckInRod`, `FlatWire_CompleteCoilOnSkid`, `FlatWire_ReleaseStation`, `FlatWire_ReverseReqsum` |
| **RT** | **None.** Nothing here broadcasts |
| **QA** | ⚠ **The hardest thing to test in the module.** A defect here writes to `proddb`, `united_db`, `CommonDB`, `SlitterDB` and `wiplogdb`. `FS-19`'s E2E scenarios are the only place it is exercised end to end |
| **BA** | ⚠ **Unassigned**, against eight open client questions |

**The write set is wide.** Coil completion alone touches `wip_skids` (united_db), `wip_skid_coils`
(proddb), a finished-coil `coils` row, `coil_gen_history`, `coil_slit_cuts` (SlitterDB), `wip_log`
(wiplogdb, 44 `NOT NULL` columns) and `coil_cost` via `CoilCost_UpdateInsert`. `[INT §8.1]` is the
authority and states it once.

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

> ⚙ **Generated by `tools/build_features.py`.** Do not edit inside the markers - the union of `blocked_by:` across this category, which exists in no other document.

**11 register items cited by 4 of 5 activities** - **11 open**.

| Item | State | Blocks | What is missing |
|---|---|---|---|
| **`G54`** | ⛔ open | `FW-231` | ⛔ The 26 Aug alpha design has an unbuilt precondition: nothing registers an FL1 segment alpha in proddb..coils. Every mi |
| **`OI-114`** | ⛔ open | `FW-219` | The cut-record sentinels for a product that is never slit are undecided, and the legacy writers disagree with each other |
| **`OI-115`** | ⛔ open | `FW-220` | The shared write set for FL2 spool check-in is undefined, and it blocks building rather than merely deploying. [API §4.6 |
| **`OI-116`** | ⛔ open | `FW-220` | Whether flat wire owes coil_mill_processing a row. PreCheckIn_CopyPlanningData writes it alongside routings, together wi |
| **`Q34`** | ⛔ open | `FW-219` | The transaction token for a flat wire coil completion |
| **`Q35`** | ⛔ open | `FW-219` | Is ONSKID the right coil status for a finished flat wire coil? |
| **`Q36`** | ⛔ open | `FW-219` | Sample number and planned operations for a flat wire output coil |
| **`Q37`** | ⛔ open | `FW-220` | The transaction token for a flat wire rod check-in |
| **`Q38`** | ⛔ open | `FW-220` | The wip_log status value for a rod on a flattening line |
| **`Q39`** | ⛔ open | `FW-220` | Is stamping the rod's shared coil row with a flattening station safe for existing consumers? |
| **`Q40`** | ⛔ open | `FW-221` | On reversing the reqsum at pre-check-out, delete the row or leave it? |

<!-- END GENERATED: blockers -->

**Eight of the eleven are client questions, and they are all of the same kind: *what value goes in
this existing column?*** That is the direct consequence of `D-32` — because nothing may be altered,
every write has to fit a column somebody else defined, and only the client knows what belongs there.

- **`Q34`** / **`Q37`** — the **transaction token** for a coil completion, and for a rod check-in
- **`Q35`** — is **`ONSKID`** the right coil status for a finished flat wire coil?
- **`Q36`** — sample number and planned operations for an output coil
- **`Q38`** — the **`wip_log` status value** for a rod on a flattening line
- **`Q39`** — is stamping the rod's shared coil row with a flattening station **safe**?
- **`Q40`** — on reversing the reqsum at pre-check-out, **delete the row or leave it**?

**Gaps this category owns that no story cites:**

- ⛔ **`G54` — the 26 Aug alpha design has an unbuilt precondition.** Nothing registers a flat wire
  alpha in the shared coil master, and `FW-231` is `blocked` on it. Until it is built, a flat wire
  coil is not visible to any downstream UA system.
- ⛔ **`OI-115` — the shared write set for FL2 spool check-in is undefined**, which blocks
  `FS-11`'s check-in as well as this category's.
- **`OI-114`** — the cut-record sentinels for a product **that is never slit** are undecided. A
  coreless coil is a single unit, so `FR-514` requires exactly one cut record, and what it contains
  is open.
- **`OI-116`** — whether flat wire owes `coil_mill_processing` a row.
- ⚠ **`FW-241`'s sign-off gate has never been passed.** `[DEP §4.2]`'s ten-step deploy chain has a
  sign-off at step 2 for the shared-schema insert, and it is the gate in front of this category
  reaching any shared database. `FS-03` owns the story; this category is what it protects.

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories — the most connected category in the module.** `FS-15` → seven others
(`FS-02`, `FS-03`, `FS-07`, `FS-08`, `FS-10`, `FS-12`, `FS-18`), with mutual pairs against `FS-07`
(5 edges out, 1 back), `FS-08` (2 out, 1 back) and `FS-10`. Its outbound direction dominates in
every pair, which is the shape of a contract: the operator-facing categories call it and it calls
almost nothing.

**On the deployment topology — a hard constraint, not a preference.** The single-transaction
guarantee requires `FlatWireDB` to be **co-located with `united_db`, `proddb` and `CommonDB` on one
instance**. A build validated on LocalDB silently loses atomicity, because LocalDB has no
`united_db` to span. `DEV00164-001` is where `is_local = 1, is_enlisted = 0` was measured on
26 Aug 2026.

**On external systems.** Reads `planning_routings`, `alloys`, `Lots`, chemistry and the
`WIPStations` view. Writes across five databases. Extends the existing `WipRejection` service and is
read by `Reports`, `Planning`, `Scheduling`, `CoilReceiving`, `CoilYield` and `CoilCosting`.

**On client decisions.** Eight questions, all of the form *what value goes in this existing column*.
None can be answered by inspection, because the columns belong to systems this project does not own.

---

## 8. Change-impact profile

**What a change here affects.** This is the category where the blast radius extends **outside the
project**.

| A change to… | Affects |
|---|---|
| **any shared write** | Upstream receiving, planning, scheduling, costing, yield and shipping — systems that predate flat wire and are not tested by this project. `D-32` exists to bound exactly this |
| **the transaction boundary** | `FS-07`'s check-in atomicity and `FS-12`'s completion atomicity. Widening the write set past one instance would require MSDTC and **change the guarantee**, not just the code |
| **a status or token value** (`Q35`, `Q38`, `Q34`, `Q37`) | Whatever downstream report or query filters on it. A wrong value does not fail — it makes a flat wire coil invisible or miscategorised in a system nobody here is looking at |
| **the alpha registration** (`G54`) | Every downstream system's ability to see a flat wire coil at all |

**Existing implementation to modify.** ⚠ **The five procedures exist as scripts under
`30-database/scripts/` but nothing here is delivered** — two activities are `blocked`, three
`not-started`, and there are **no build records**. The scripts are the design, not the deployment,
and the step-2 sign-off in front of them has never been passed.

**Regression areas — the highest in the module.**

- **A defect here corrupts data the project did not create**, and it is discovered by a downstream
  system rather than by a flat wire test. This is the one category where "it works on the flat wire
  screens" is not evidence.
- **Atomicity is environment-dependent.** The same code is transactional on a co-located instance
  and silently non-transactional otherwise. Nothing in the code makes that visible.
- **The PLC half compensates rather than rolls back**, so a failure after the database commit
  leaves the controller and the database disagreeing. `G99`'s two-controller case under `FS-13`
  makes that worse rather than better.
- **`wip_log` has 44 `NOT NULL` columns.** Every one has to be supplied correctly, and `Q38` means
  one of them is currently a guess.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
