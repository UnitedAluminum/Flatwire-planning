# Flat Wire Mill — Planning Repository

Planning, requirements and design for the **Flat Wire Mill module** of the UAL manufacturing
execution system. There is no shippable code here: the implementation lands in
**`../ual-api`** (the `FlatWire` microservice) and **`../ual-angular`** (the `flat-wire`
library), and this repository is the specification they are built from.

---

## Start here

| I want to know… | Go to |
|---|---|
| **What are we building?** | [`00-overview/VisionAndScope.md`](00-overview/VisionAndScope.md) `[VS]`, then [`BusinessRequirements.md`](10-requirements/BusinessRequirements.md) `[REQ]` — the numbered `FR-###` register |
| **What needs to be done?** | **[`STATUS.md`](STATUS.md)** — every task, grouped by phase |
| **What is this functionality, and what does a change to it touch?** | **[`10-requirements/features/`](10-requirements/features/README.md)** — the 20 consolidated parent stories `FS-01`–`FS-20`. One file per functional area, and the single source of truth for its requirements, scope, open items, dependencies and change-impact |
| **How is each *feature* progressing?** | **[`FEATURES.md`](FEATURES.md)** — the category board. `STATUS.md` answers *where are we by phase*; this answers *where are we by feature* |
| **Which category did `FW-157` become part of?** | [`90-registers/StoryConsolidationMap.md`](90-registers/StoryConsolidationMap.md) `[SCM]` — the story → category ledger and the id-retirement register |
| **Who is doing it?** | [`STATUS.md`](STATUS.md), `Owner` column. It is set in the task file, nowhere else |
| **What is in progress / blocked / pending / done?** | [`STATUS.md`](STATUS.md) — one row per task, one enum value |
| **What is stopping us right now?** | [`STATUS.md`](STATUS.md) § *⛔ Stopping work right now* — open register items ordered by how many tasks each blocks |
| **How is each phase / MVP progressing?** | [`STATUS.md`](STATUS.md) § *At a glance* |
| **What can I start today?** | [`STATUS.md`](STATUS.md) — each phase ends with **▶ Ready to start now** |
| **How do I build task `FW-157`?** | Its task file: [`40-backend/tasks/FW-157.md`](40-backend/tasks/FW-157.md). That file *is* the plan |
| **What is still undecided?** | [`90-registers/Questions.md`](90-registers/Questions.md) `Q##` (business) · [`90-registers/Gaps.md`](90-registers/Gaps.md) `G##` (internal) · master spec §11 `OI-##` |
| **Where is everything else?** | [`./DOCUMENTS.md`](./DOCUMENTS.md) — the document map and shortcode table |

---

## The three files that matter most

**[`STATUS.md`](STATUS.md) — the board, by phase.** ⚙ **Generated. Never edit it.** Every value
comes from the front-matter of a task file. To change what it says, change the task file and re-run
`python tools/build_status.py`.

**[`FEATURES.md`](FEATURES.md) — the board, by feature.** ⚙ **Also generated.** Its unit is the
**activity**, not the category: a category inherits the union of its stories' blockers, so a
category-level board would read as permanently blocked. Regenerate with
`python tools/build_features.py`.

**[`10-requirements/features/FS-##-*.md`](10-requirements/features/README.md) — the unit of
*understanding*.** Twenty consolidated parent stories, one per functional area. When you need to
know what a piece of functionality is, what it requires, where it stands, what is open about it, or
what a change to it would touch, this is the file. Its absorbed-story table, blocker roll-up and
verification evidence are generated; its prose is hand-owned. Rules in
[`10-requirements/features/README.md`](10-requirements/features/README.md).

**`*/tasks/FW-###.md` — the unit of *work*, and a build record.** One file per story, in its
stream's folder:

```
50-frontend/tasks/    FE stories (and three RT)
40-backend/tasks/     BE and RT stories
30-database/tasks/    DB stories
70-testing/tasks/     QA stories
60-delivery/tasks/    BA stories (no build stream)
```

Each carries machine-readable front-matter above the `---` and the developer's plan below it. Two
developers on two tasks never edit the same file. ⚠ **A story is no longer the unit of planning** —
that is now its category. These files remain the build record and the writable home of `status:`.

## Picking up a task

```bash
# 1. Find work: STATUS.md -> your stream -> "Ready to start now"
#    (dependencies met, nothing blocking)

# 2. Claim it. One line, in your own file, and no other file changes:
#      status: in-progress
#      owner: <you>
#      started: <today>

# 3. Work. The file you claimed IS the plan - section 3 "Build order" is the steps.

# 4. Blocked? Name the register id. Never prose:
#      status: blocked
#      blocked_by: [G2]

# 5. Done? Record the measured result in section 5 "Verification", then:
#      status: in-review   ->   a reviewer sets   status: done

python tools/build_status.py     # regenerate the board
python tools/check_docs.py       # would CI pass?
```

**Status values:** `not-started` → `in-progress` → `in-review` → `done`, with `blocked` and
`cancelled` as side states. `blocked` must always name a register id.

---

## Tools

Run from the repository root. All are dependency-free except the workbook builders.

| Command | What it does |
|---|---|
| `python tools/build_status.py` | Regenerate [`STATUS.md`](STATUS.md). `--check` fails if it is stale |
| `python tools/build_features.py` | Regenerate [`FEATURES.md`](FEATURES.md) **and** each parent's generated blocks. `--check` for CI |
| `python tools/build_consolidation_map.py` | Regenerate [`StoryConsolidationMap.md`](90-registers/StoryConsolidationMap.md). Refuses to emit rather than emit something wrong |
| `python tools/check_docs.py` | Assert the task ↔ phase ↔ register relationships. `--strict` for CI |
| `python tools/linkcheck.py` | Verify no path reference broke against the pinned baseline |
| `python tools/deliverables/verify_schema_counts.py` | Assert the DDL matches its published object counts |
| `python tools/deliverables/build_coverage_matrix.py` | Prove every `FR-###` reaches a test case |

---

## Conventions worth knowing before you edit

- **A fact is asserted in one document and cited everywhere else.** If you are typing a number
  another document owns — an hour figure, a table count — cite `[CE §3]` or `[DBD §6.2]` instead.
  That is why `STATUS.md` shows no hours total.
- **One change log:** [`CHANGELOG.md`](CHANGELOG.md) at the root. Never add a `## Change Log`
  section to a document.
- **Documents are cited by shortcode**, declared in each header — `[REQ]`, `[ARC]`, `[SIG]`,
  `[DBD]`, `[API]`, `[TB]`, `[CE]`. Shortcodes survive a file move; paths do not.
- **Ids are never renumbered** — `FR-`, `Q`, `OI-`, `G`, `TC-`, `D-`. Task ids are the one
  exception: `FW-###` is a working id that will be **replaced** by the real JIRA id once issues
  exist, in one scripted pass driven by
  [`TaskIdMap.md`](90-registers/TaskIdMap.md).
- **[`CLAUDE.md`](CLAUDE.md) carries the domain traps** — the `Spool` / `SpoolProcessing` rename,
  the FM2 three-stand model, the alpha formats. Read it before touching schema or terminology.
