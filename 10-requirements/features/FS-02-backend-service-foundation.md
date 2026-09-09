---
id: FS-02
title: Backend Service Foundation
phases: [1B]
requirements: []
screens: []
jira:
owner:
---
# FS-02 · Backend Service Foundation

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — the single source of truth for this functional area
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

**Business purpose.** The `FlatWire` microservice everything server-side lives in: its four-project
Clean Architecture solution, the controllers, the CQRS pipeline, the domain model and its
aggregates, the repositories and data access, and the cross-cutting concerns — logging, validation,
configuration, error handling, health checks and the audit log.

⚠ **This is the most delivered category in the module.** Fourteen of its activities are `done` and
two are `in-review`; six remain. Every other category is mostly or entirely unbuilt.

⚠ **One of three technical-layer categories** (`FS-01` / `FS-02` / `FS-03`) — the deliberate
exception to the *"no technical-layer categories"* rule. See
[`README.md`](README.md#four-boundaries-that-are-not-the-phase-model).

**Functional scope.** Owned by
[`phase-01b-backend-foundation.md`](../../60-delivery/phases/phase-01b-backend-foundation.md),
cited not restated. The solution skeleton; the thin controllers over `UAController`; MediatR
registration and pipeline behaviours; DI registration with the stub/real swap; the repository layer;
Dapper/EF data access and `FlatWireDbContext`; Serilog and the audit log; configuration binding;
JWT authentication and role policies; global exception middleware and the response envelope;
FluentValidation, value objects and the **canonical cross-layer enums**; health checks; the domain
model with its aggregates and invariants; domain events with post-commit dispatch; the audit-log
persistence target; the unit-test project and four test suites; the `PLCTagService` simulate branch;
the environment-badge endpoint; and the `LineId` → `MachineName` rename.

**Binding architectural rules** — `[ARC §2.2]`:

- **`API/Domain/CoilCheckin` is the primary reference template.** `OPCConnection` is the PLC tag
  layer to integrate with. ⛔ **`SlitterInterface` is explicitly NOT a reference.**
- **First UAL service built to tactical DDD** (`D-29`) — **seven aggregate roots**: `FlatWireRun`,
  `RodStaging`, `WeldEvent`, `SpoolProcessing`, `CoilOutput`, `RodCheckout`, `WipRejection`.
  Deliberately **not** aggregates: `RunReading` (append-only), `Rod` (a read model of `coils`),
  `PassSchedule` (a read model — MVP-1 never authors one) and reference data.
- **Stub-first delivery** (`[API §7]`): stub endpoints return contracted shapes so `FS-01` can be
  built and demoed before this service is populated.

**Out of scope.**

- **The real-time surface.** `FlatWireHub`, the OPC ingest, the broadcast loop and the simulator are
  [`FS-04`](FS-04-realtime-plc-backbone.md), even though they compile into the same solution.
- **`FlatWireDB`'s schema** — [`FS-03`](FS-03-database-foundation.md).
- **The shared-schema procedures** — [`FS-15`](FS-15-shared-schema-boundary.md).
- **Any endpoint's business behaviour.** The controllers are thin and the services belong to their
  functional category.

---

## 2. Consolidated existing stories

Per [`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md); the count and the list are generated below.

<!-- BEGIN GENERATED: absorbed-stories -->

> ⚙ **Written by `tools/build_features.py`, now hand-maintained** — the task files it derived from have been retired, so this table is the single writable record of status for this category. Keep the columns exactly as they are; `--check` and `FEATURES.md` both parse them.

**22 absorbed stories**, seeded one activity each. **Activities are expected to merge downward** as work proceeds — `FW-N17`/`N18`/`N19` are one rename, not three.

| Ref | Activity | Streams | Status | Depends on | Blocked by |
|---|---|---|---|---|---|
| `FW-138` | Fifteen thin controllers over UAController | BE | ✅ done | FW-N04 | — |
| `FW-139` | MediatR registration and pipeline behaviours | BE | ✅ done | FW-N04 | — |
| `FW-140` | DI registration and the stub/real service swap | BE | ✅ done | FW-N04 | — |
| `FW-141` | Repository layer — one per aggregate root | BE | ✅ done | FW-N04 FW-006 | **G17** |
| `FW-142` | Dapper/EF data access and FlatWireDbContext | BE | ✅ done | FW-N04 FW-006 FW-007 | — |
| `FW-143` | Serilog structured logging and the audit log | BE | ✅ done | FW-N04 | — |
| `FW-144` | Configuration binding | BE | 🔵 in-review | FW-N04 | **G33** **PLC-Q05** |
| `FW-145` | JWT authentication and role authorization policies | BE | ⬜ not-started | FW-N04 | — |
| `FW-146` | Global exception middleware and the response envelope | BE | ✅ done | FW-N04 | — |
| `FW-147` | FluentValidation, value objects and the canonical cross-layer enum | BE | ✅ done | FW-N04 | — |
| `FW-148` | Health checks | BE | ✅ done | FW-N04 | — |
| `FW-207` | Domain model — aggregates, value objects and invariants | BE | 🔵 in-review | FW-N04 | — |
| `FW-208` | Domain events and post-commit dispatch | BE | ✅ done | FW-207 FW-142 FW-080 | — |
| `FW-234` | Audit-log persistence target | BE·DB | ⬜ not-started | FW-143 FW-142 FW-151 FW-007 | — |
| `FW-263` | FlatWire.UnitTests — the test project, its fixtures and the OPC st | BE | ✅ done | FW-142 | — |
| `FW-264` | Pure-domain suite — the validators, the 20 rules and the 15 value | BE | ⬜ not-started | FW-263 FW-147 | — |
| `FW-265` | PLCTagService — the simulate branch and FW-236's FR-074 outcome br | BE | ✅ done | FW-263 FW-151 | — |
| `FW-266` | Line models and the two simulators, with the two small testability | RT·BE | ⬜ not-started | FW-263 FW-210 | — |
| `FW-267` | DbContext-backed services — the guard clauses and BusinessKeyGener | BE | ⬜ not-started | FW-263 | — |
| `FW-N04` | FlatWire solution and four-project Clean Architecture skeleton | BE | ✅ done | — | — |
| `FW-N13` | FlatWire/GetServerConnectionInfo — the shared header's environment | BE | ⬜ not-started | FW-138 | — |
| `FW-N18` | LineId → MachineName — the FlatWire service | BE | ✅ done | FW-N17 | — |

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

**This category owns no `FR` range, and that is correct.** A solution skeleton, a CQRS pipeline and
a repository layer carry no requirement of their own. Its authorities are `[SVC]` (solution
structure, CQRS, validation, error handling), `[API]` (the REST contract — conventions, enums, the
endpoint set and the stub-first delivery contract) and `[ARC §2.2]` for the reference rules.

⚠ **`[API]`'s controller count moved and its endpoint total is a citation, not a restatement.**
`RodReceivingController` was withdrawn 25 Aug 2026 (`P-53`), leaving **14** controllers — while
`FW-138`'s title still says *"Fifteen thin controllers"* and its measured result records **22
endpoints across 12 controllers**. Three figures for one thing; `[API §3.1]` is the authority.

⚠ **Several build records correct a stale acceptance criterion in `[TB §7]`** — `FW-140`'s
`useStub`, `FW-141`'s repository list, `FW-142`'s table count, `FW-145`'s five roles, `FW-147`'s
rule placement. **Read the plan beside the card, not instead of it.**

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

| Stream | Scope |
|---|---|
| **BE** | Twenty-one of twenty-two activities. The solution, controllers, MediatR, DI, repositories, data access, logging, configuration, JWT, middleware, validation, health checks, the domain model, domain events, the audit target, the four test suites, the `PLCTagService` simulate branch and the environment badge |
| **DB** | Only through `FW-234`'s audit-log persistence target, which needs a table `FS-03` does not yet have |
| **RT** | Only through `FW-266`, which tests the line models and the two simulators — the code is `FS-04`'s |
| **FE** | **None** |
| **QA** | ⚠ **No QA activity, and the unit tests are `BE`.** `FW-263`–`FW-267` were reinstated for the unit level by `D-50`/`G101`; `phase-01b` carries **no automated tests** at its own gate (`[TS §1.2]`), which passed on a signed-off manual contract walkthrough and a `/health` shape check |

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

> ⚙ **Generated by `tools/build_features.py`.** Do not edit inside the markers - the union of `blocked_by:` across this category, which exists in no other document.

**3 register items cited by 2 of 22 activities** - **3 open**.

| Item | State | Blocks | What is missing |
|---|---|---|---|
| **`G17`** | ⛔ open | `FW-141` | rod→coils multiplies cross-DB logical FKs (every Rod.Alpha ref) |
| **`G33`** | ⛔ open | `FW-144` | The measure segment of every tag is ours, not the controller's — and it departs from thirteen observed strings. On 4 Aug |
| **`PLC-Q05`** | ⛔ open | `FW-144` | Confirm every measure name in §5.2 — RollGap, Gauge, Width, Footage, Diameter, Weight, Status.IsActive, Status.IsFaulted |

<!-- END GENERATED: blockers -->

**Only three blockers against twenty-two activities** — the best ratio in the module, and the
reason this category got built while others stalled. None blocks the foundation itself:

- **`G17`** — `rod`→`coils` multiplies cross-database logical FKs on every `Rod.Alpha` reference,
  and nothing enforces them. Shared with `FS-03` and `FS-07`.
- **`G33`** / **`PLC-Q05`** — the measure segment of every tag path is ours, not the controller's,
  and every measure name needs confirming. Both reach `FW-265`'s `PLCTagService` simulate branch and
  are really `FS-04`/`FS-19` items.

**Gaps this category owns that no story cites:**

- ⚠ **`G126` — four of this category's cards carried a stale acceptance criterion whose
  correction lived only in the now-archived plan.** Corrected on the card 9 Sep 2026:
  **`FW-141`** four repositories → **seven, one per aggregate root, and none for `Rod` or
  `PassSchedule`**; **`FW-142`** the 25/28 table split → **one set, counted only by `[DBD §6.2]`**;
  **`FW-145`** five roles → **six, the omission being QA**; **`FW-147`** all three sample rules in
  FluentValidation → **only the third, the other two being aggregate state rules returning `422`**.
  ✅ **`G126` is closed** — all 97 correction rows across the fourteen archived plans adjudicated,
  and `FW-207` and `FW-208` each carried further stale criteria, now corrected on their cards. See [`Gaps.md`](../../90-registers/Gaps.md).

- ⛔ **`CLAUDE.md` points at the wrong checkout.** It says the implementation lands in `../ual-api`,
  which resolves to a checkout with **no `FlatWire` domain at all**. Measured today: the four
  projects are in **`Second-Branch/ual-api/API/Domain/FlatWire`**. Fourteen `done` activities live
  somewhere the documentation does not name.
- ⚠ **`P-71` — there is no `IGenericRepository<,>`, deliberately.** `GenericRepository` is **not** a
  framework type (every domain carries its own) and `EntityRepositoryBase` implements **no
  interfaces**. Declaring the generic would put EF back in Domain against `P-67`.
- ⚠ **`FW-141`'s `==` in the alpha predicates is reference equality in C#** and works only because
  EF translates it. It is correct in the query and would be wrong in memory.
- ⚠ **`FW-145` (JWT) is the only MVP-2 story in the backlog** — carved out by `D-52` on 6 Sep 2026,
  which also took its `G6` dependency with it and **removed the only `Blocked` plan from the
  critical path**. `FS-01`'s `FW-131` guards depend on it.
- ⚠ **`OI-33` still gates `FW-141`'s step 6**, recorded in the build record rather than as a
  blocker.

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories.** `FS-02` → `FS-03` and `FS-04`, with mutual pairs against both — `FS-03`
(5 edges out, 1 back) and `FS-04` (14 edges in, 4 out). **Every backend category depends on it**,
and its own dependency on `FS-03` is real: `FW-141`'s repositories and `FW-142`'s `DbContext` need
the Materials and Runs tables to exist.

**On `FS-04`.** The most tangled boundary in the module: 14 edges from `FS-04` into here and 4 back.
They compile into one solution and are separated because the real-time pipeline is a cross-phase
concern four categories consume, while this is the service chassis.

**On the application repository.** ⚠ Its `CLAUDE.md`, C# review guidelines and the semantic review
checklist are mandatory and are **not in this repository**.

---

## 8. Change-impact profile

**What a change here affects.** Every server-side category, and the contract `FS-01` builds against.

| A change to… | Affects |
|---|---|
| **the canonical enums** | `FS-01`'s models and `FS-03`'s `CHECK` constraints. `State ∈ {Active, Bypass, Skip}` — **never a boolean `IsActive`** — and `EdgeType ∈ {Round, Square}` with "Round Edge / Flat Edge" as display labels only. Defined **once**, here |
| **the response envelope** | Every screen's error handling. `{ success, data, errors[] }` is `FS-01`'s contract |
| **an aggregate boundary** | Every service that loads it. `[SVC §3.2a]`'s seven roots are the ruling, and `P-91` still owes a decision on `FS-14`'s two entities |
| **the repository layer** | Seven repositories, all delivered and registered. `P-71` says no generic — adding one puts EF back in Domain |
| **JWT and roles** (`FW-145`) | `FS-01`'s guards and every route. Now **MVP-2**, so the guards have no backing in MVP-1 |

**Existing implementation to modify.** ⚠ **This is the category where "modify" actually applies.**
Fourteen activities are `done` and verified against a live `FlatWireDB` — see the generated evidence
in §2 — and two are `in-review`. **Changes here are changes to working code**, not to paper, and it
is the only category where that is true at scale.

**Regression areas.**

- **The seven repositories were verified 13/13 accessors against live `FlatWireDB` in a rolled-back
  transaction.** That evidence is in the build record and is the only proof; it is lifted into §2
  because `95-archive/` will not be citable.
- **`P-67`/`P-71` are architectural invariants, not preferences.** A well-meaning generic
  repository would put EF in Domain and pass review.
- **The reference-equality `==` in the alpha predicates** is a correctness trap for anyone moving
  that code out of a query.
- **`FW-145`'s move to MVP-2 left `FS-01`'s guards without backing**, and the six roles exist as
  JWT claims whose **values are coded rather than labelled** with the mapping unsupplied.
- **The documented repository path is wrong**, so a reviewer looking for the built code in
  `../ual-api` finds nothing and may conclude it was never built.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
