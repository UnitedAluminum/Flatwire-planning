---
id: FS-03
title: Database Foundation and Deployment
phases: [1C]
requirements: []
screens: []
jira:
owner:
---
# FS-03 · Database Foundation and Deployment

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — the single source of truth for this functional area
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

**Business purpose.** `FlatWireDB` — every table the module writes to, their constraints, indexes,
seed data and the ordered chain that builds them, plus the deploy path onto the shared instance.
Nine other categories store something here.

⚠ **One of three technical-layer categories** (`FS-01` / `FS-02` / `FS-03`) — the deliberate
exception to the *"no technical-layer categories"* rule. See
[`README.md`](README.md#four-boundaries-that-are-not-the-phase-model).

**Functional scope.** Owned by
[`phase-01c-database-foundation.md`](../../60-delivery/phases/phase-01c-database-foundation.md),
cited not restated. The database creation and ordered DDL runner with indexes and grants; the five
table groups; the deploy step-2 shared-schema insert and its reverse script; six schema-repair
activities; the Machine Setup schema; the tooling reconciliations; and five schema changes minted
since 7 September.

**Two things a reader must get right:**

- ⛔ **Deploy to the SHARED instance, not LocalDB.** `FlatWireDB` must sit alongside `united_db`,
  `proddb` and `CommonDB`, because check-in spans them in **one `SqlTransaction`** under the local
  transaction manager with **no MSDTC** (`[INT §8.0]`, `[ARC §10]`). LocalDB has no `united_db`, so a
  build validated only there **silently loses atomicity**. The instance is **`DEV00164-001`**, where
  that atomicity was actually proven (`is_local = 1`, `is_enlisted = 0`, 26 Aug 2026). ⚠
  **`DEVUAL-UADEV001\TEST1` is retired** for `FlatWireDB`.
- **The DDL is authoritative for types, nullability and constraints — never regenerate it from the
  markdown.** Files are numbered by execution order: `00` database → `01` Lookup → `02` Schedule →
  `03` Materials → `04` Runs → `05` Quality/Output → `06` **all FKs** → `07` Indexes →
  `08` Programmability, with `99` teardown. **Put new FKs in `06`.** Every script guards its objects,
  so `RunAll` is idempotent.

⚠ **Object counts are asserted in `[DBD §6.2]` and nowhere else.** This file does not restate them —
they propagate to roughly forty places and only three sites may state them.

**Out of scope.**

- **The shared schema.** `D-32` (18 Aug 2026): the existing `coils` and scheduling schema is **read
  and written as it stands and never altered.** `FW-001` and `FW-002` are `cancelled` and are here
  only as the record of what the change would have required.
- **The shared-schema procedures** — [`FS-15`](FS-15-shared-schema-boundary.md).
- **`sp_ShiftSummary`**, which is MVP-2 (`09_Programmability_MVP2`).
- **What the tables mean.** Each functional category owns its own domain rules; this one owns their
  storage.

---

## 2. Consolidated existing stories

Per [`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md); the count and the list are generated below.

<!-- BEGIN GENERATED: absorbed-stories -->

> ⚙ **Written by `tools/build_features.py`, now hand-maintained** — the task files it derived from have been retired, so this table is the single writable record of status for this category. Keep the columns exactly as they are; `--check` and `FEATURES.md` both parse them.

**21 absorbed stories**, seeded one activity each. **Activities are expected to merge downward** as work proceeds — `FW-N17`/`N18`/`N19` are one rename, not three.

| Ref | Activity | Streams | Status | Depends on | Blocked by |
|---|---|---|---|---|---|
| `FW-001` | Shared-schema column renames and new columns | DB | ⊘ cancelled | — | — |
| `FW-002` | INFLAT coil status | DB | ⊘ cancelled | FW-001 | — |
| `FW-004` | AlloyProperty lookup and seed | DB | ⬜ not-started | FW-152 | **OQ-22** **G121** |
| `FW-005` | Lookup group tables and seed | DB | ⬜ not-started | FW-152 | **G32** **PLC-Q04** |
| `FW-006` | Materials group tables | DB | ⬜ not-started | FW-152 | **G17** |
| `FW-007` | Runs and Quality/Output group tables | DB | ⬜ not-started | FW-152 FW-006 | **G14** **G21** **G34** |
| `FW-152` | FlatWireDB creation, ordered DDL runner, indexes and grants | DB | 🔵 in-review | — | — |
| `FW-241` | Deploy step 2 — author the shared-schema insert and its reverse sc | DB | ⬜ not-started | FW-152 FW-003 | — |
| `FW-244` | G49 — nine decided requirements with no column | DB | ⬜ not-started | FW-007 FW-006 | — |
| `FW-245` | G51 — SpcMeasurement.InSpec stores a wrong verdict for an asymmetr | DB | ⬜ not-started | FW-004 FW-007 FW-168 FW-N22 | **Q22** **G121** |
| `FW-246` | G50 / G52 / G41 / G55 — constraint and referential-integrity repai | DB | ⬜ not-started | FW-005 FW-006 FW-007 FW-147 FW-225 | **G55** |
| `FW-248` | Harden verify_schema_counts.py's C6, and repair the two count site | DB | ⛔ blocked | FW-152 | — |
| `FW-251` | Restate the schema baseline to 40/64/86 and repair the DB cards th | DB | ⬜ not-started | FW-152 | — |
| `FW-259` | Reconcile ToolingInventoryRollSet with the client's roll-set grid | DB | ⬜ not-started | FW-251 | **Q92** **G87** |
| `FW-262` | Machine Setup schema — Setup/Handling Times and Material Loss, fiv | DB | ✅ done | — | — |
| `FW-268` | Reconcile ToolingInventoryEdger with the client's edger grid when | DB | ⬜ not-started | FW-251 | **Q95** **G104** |
| `FW-N17` | LineId → MachineName — the database layer | DB | ✅ done | — | — |
| `FW-N20` | SpoolOrder re-grained from the spool to the segment | DB·BE | ✅ done | — | — |
| `FW-N21` | SpoolConfiguration split back out of Spool | DB | ✅ done | — | — |
| `FW-N22` | AlloyProperty re-grained to vendor and rod size band | DB | ⬜ not-started | FW-004 FW-152 | — |
| `FW-N23` | Pass schedule carries roll gap and target product gauge per stand | DB | ⬜ not-started | FW-006 FW-152 | — |

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

**This category owns no `FR` range, and that is correct.** Schema, constraints, indexes, seed and a
deploy chain carry no requirement of their own. Its authorities are `[DBD]` (read §6 and §7 first —
the **as-built** description, and §6.2 the **only** site that states object counts), the six
per-domain schema documents, `30-database/sql/` (**executable truth**) and `[DEP §4.2]` for the
ten-step deploy chain.

⚠ **`G49` — nine decided requirements have no column.** Nine requirements were decided and the
schema does not carry them; `FW-244` is the 8 h repair. So the relationship between requirements and
this category is not "none" but "nine unhonoured".

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

**Every activity is `DB`** except `FW-N20`, which has a `BE` half. That is what makes this a layer
category.

| Activity group | Scope |
|---|---|
| **Build chain** | Database creation, the ordered DDL runner, indexes and grants — `in-review` |
| **The five table groups** | Lookup, Schedule, Materials, Runs and Quality/Output, in execution order. ⚠ `FlatWireRun` is created in **`03_Materials`**, not `04_Runs`, so `SpoolProcessing.SourceRunId` can reference it |
| **Repairs** | `G49`'s nine missing columns; `G51`'s wrong `InSpec` verdict; `G50`/`G52`/`G41`/`G55`'s constraint and referential repairs; the count-guard hardening; and the baseline restatement |
| **Deploy** | Step 2's shared-schema insert **and its reverse script, run under sign-off** — the gate in front of `FS-15` |
| **Late changes** | Machine Setup (`done`), the `LineId` rename (`done`), `SpoolOrder` re-grained to the segment (`done`), `SpoolConfiguration` split back out (`done`), `AlloyProperty` re-grained to vendor and size band, and the pass schedule's roll gap and target gauge per stand |

⚠ **`SpoolConfiguration` is a table.** `Q60` merged it into `Spool` on 23 Aug 2026 and **`D-58`
split it back out on 8 Sep 2026**, with its six limits `NOT NULL` again and `IsDefault` replacing the
merge's fallback. `Spool.SpoolTypeId` is `NOT NULL` with an enforced FK, so **deleting references to
it as "stale" breaks a live constraint.**

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

> ⚙ **Generated by `tools/build_features.py`.** Do not edit inside the markers - the union of `blocked_by:` across this category, which exists in no other document.

**14 register items cited by 8 of 21 activities** - **12 open**, 1 closed but still cited, **1 resolving to no register** (`G61`).

| Item | State | Blocks | What is missing |
|---|---|---|---|
| **`G121`** | ⛔ open | `FW-004` · `FW-245` | ROD TOLERANCE VARIES BY VENDOR AND BY SIZE, AND AlloyProperty HAS ONLY AN ALLOY GRAIN. Q22's recommendation carried an e |
| **`G104`** | ⛔ open | `FW-268` | ToolingInventoryEdger HAS NO NATURAL KEY, AND THREE COLUMNS ON IT ARE OURS RATHER THAN THE CLIENT'S. Built (D-53) from t |
| **`G14`** | ⛔ open | `FW-007` | Pre-build data inconsistencies: 3- vs 4-item inspection (+M1/M2 ovality), R##### vs ROD-#####, FootageFt INT vs DECIMAL, |
| **`G17`** | ⛔ open | `FW-006` | rod→coils multiplies cross-DB logical FKs (every Rod.Alpha ref) |
| **`G21`** | ✅ closed | `FW-007` | UX_RodStaging_Bay does not enforce "one rod per payoff bay" across FL1/FL3. The filtered unique index is keyed (LineId, — ⚠ still cited here |
| **`G32`** | ⛔ open | `FW-005` | The FM2 PLC station names in the spec are ours, not the controller's. The 4 Aug 2026 roller-size correction established |
| **`G34`** | ⛔ open | `FW-007` | Wire break now has a decided flow and still no persistence target. The client specified the whole sequence on 6 Aug 2026 |
| **`G55`** | ⛔ open | `FW-246` | FL2's spool check-in is constrained to payoff position 1, while the canonical enum and the pinned lookup row both make F |
| **`G87`** | ⛔ open | `FW-259` | The fourth Tooling Inventory tool type is built from one sentence, and every column in it is ours. Die, Edger and Straig |
| **`OQ-22`** | ⚠ no register | `FW-004` | **Retired prefix resolving to nothing** - needs retargeting or removal (`G61`) |
| **`PLC-Q04`** | ⛔ open | `FW-005` | Confirm the FM2 station names — S1, S2, S3, carrying position only (§4.3). Every FM2 row in §5.2.2 is [PROPOSED] until t |
| **`Q22`** | ⛔ open | `FW-245` | Dimensional tolerances — min/max for gauge, width, diameter and ovality; no column exists |
| **`Q92`** | ⛔ open | `FW-259` | What columns does the roll-set Tooling Inventory grid carry — and are capstan rolls the same tool option as mill rolls? |
| **`Q95`** | ⛔ open | `FW-268` | Five things the edger Tooling Inventory grid does not say — and one of them decides how a roll set is identified at all. |

<!-- END GENERATED: blockers -->

**Fourteen items — second only to `FS-07` — and they cluster into three kinds.**

**Columns that cannot hold what they are asked to.** ⛔ **`G104`** —
`ToolingInventoryEdger` has **no natural key** and three of its columns are wrong. ⛔ **`G121`** —
rod tolerance varies by vendor and by size while `AlloyProperty` has only an alloy grain; `FW-N22`
is the re-graining. **`G55`** — FL2's spool check-in is constrained to payoff position 1 while the
rule is wider.

**Values nobody has supplied.** **`Q22`** — dimensional tolerances, min/max for gauge, width and
diameter. **`Q92`**/**`Q95`** — the roll-set and edger grid column sets, with **`G87`** recording
that the fourth tool type was built from **one sentence**.

**Tag and station names that are ours, not the controller's.** **`G32`**/**`PLC-Q04`** — the FM2
station names. These are really `FS-19` items and reach here through the seed.

Plus **`G14`** (pre-build data inconsistencies), **`G17`** (unenforced cross-database logical FKs),
**`G34`** (wire break has no persistence target — the only remaining unbuilt MVP-1 table need),
~~`G21`~~ (closed, still cited) and **`OQ-22`** (no register).

**Gaps this category owns that no story cites:**

- ⛔ **`G51` is a built defect, not a gap.** `SpcMeasurement.InSpec` **stores a wrong verdict for an
  asymmetric band** today. Every SPC report, CPK report and certificate reads it. `FW-245` is 6 h.
- ⛔ **Deploy step 2's sign-off has never been passed.** `[DEP §4.2]`'s chain has a sign-off gate at
  step 2 and `FW-241` is `not-started`. **Nothing in `FS-15` may reach a shared database until it
  is.**
- ⚠ **The verifier is static, not a deploy.** Six green checks from `verify_schema_counts.py` mean
  the scripts *say* the right thing, not that a database *has* it. `FW-248` hardens its blind spot
  (`C6`) and is `blocked`.
- ⚠ **`FW-251` restates the schema baseline**, and baselines here have drifted repeatedly — the
  published figure has been `33 · 55 · 69`, then `46 · 68 · 89`, then `47 · 69 · 90` in a week.
  **`[DBD §6.2]` is the only site permitted to state them**; this file deliberately states none.

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories — the most depended-upon category in the module.** `FS-03` → `FS-02`,
`FS-09`, `FS-14` and `FS-18`, and **thirteen categories depend on it**. Its own outbound edges are
mostly repairs that need a service to exist first, which is why it forms mutual pairs with `FS-02`
(1 back-edge), `FS-09`, `FS-14` and `FS-18` (11 in, 1 out).

**On the deployment topology — a hard constraint.** The single-transaction guarantee requires
co-location on one instance. `FS-19`'s `FW-242` moves the database into `ual-database` and **must
not lose it**.

**On client decisions.** `Q22`'s tolerances, `Q92`/`Q95`'s grid columns, `PLC-Q04`'s station names.
Four values, six blocked activities.

**On sign-off.** `FW-241`'s step-2 gate is a human approval, and it blocks an entire category
(`FS-15`) rather than a story.

---

## 8. Change-impact profile

**What a change here affects.** Everything that stores anything.

| A change to… | Affects |
|---|---|
| **any table's shape** | The category that owns its domain rules, plus `FS-02`'s `DbContext` and repositories. **Nine categories store something here** |
| **a `CHECK` constraint** | `FS-02`'s canonical enums — they must agree, and the enums are defined once in `FS-02` |
| **`AlloyProperty`'s grain** (`G121`, `FW-N22`) | `FS-07`'s check-in reads, `FS-09`'s SPC bands, `FS-16`'s certification tolerances, `FS-18`'s admin grid. **Four categories on one lookup** |
| **the pass-schedule tables** (`FW-N23`) | `FS-05`'s consumer contract and the four categories that read a schedule |
| **`SpoolConfiguration`** | `FS-11`'s spool lifecycle. It was merged and un-merged inside three weeks; its FK is live |
| **the deploy chain** | `FS-15`'s ability to write anywhere shared, and `FS-19`'s go-live |

**Existing implementation to modify.** Four activities are `done`, one is `in-review`, one is
`blocked`, thirteen are `not-started` and two are `cancelled`. ⚠ **So the schema is roughly a
quarter delivered while `G104`, `G121` and `G55` say three of its tables cannot hold what they are
asked to.** Late schema changes have already arrived five times since 7 September — `FW-N17`,
`FW-N20`, `FW-N21`, `FW-N22`, `FW-N23` — which is the clearest signal that this category's inputs
are not settled.

**Regression areas.**

- **`G51` is producing wrong answers now**, and every consumer inherits them silently.
- **A LocalDB-only validation passes and is worthless** for the transactional guarantee. Nothing in
  the code makes that visible.
- **`RunAll` is idempotent, so re-running is safe** — but `verify_schema_counts.py` being green is
  not evidence of a deployed database.
- **Deleting `SpoolConfiguration` references as stale breaks a `NOT NULL` foreign key.**
- **Object counts propagate to about forty places.** Restating one here would create the next
  contradiction, which is why this file states none.
- **`FW-242`'s move to `ual-database` could silently break atomicity** if co-location is lost.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
