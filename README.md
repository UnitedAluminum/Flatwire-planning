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
| **Who is doing it?** | [`STATUS.md`](STATUS.md), `Owner` column — now **per category**, set in the parent's `owner:` front-matter and nowhere else. ⚠ **All twenty are unset**, so every row reads `—` |
| **What is in progress / blocked / pending / done?** | [`STATUS.md`](STATUS.md) — one row per task, one enum value |
| **What is stopping us right now?** | [`STATUS.md`](STATUS.md) § *⛔ Stopping work right now* — open register items ordered by how many tasks each blocks |
| **How is each phase / MVP progressing?** | [`STATUS.md`](STATUS.md) § *At a glance* |
| **What can I start today?** | [`STATUS.md`](STATUS.md) — each phase ends with **▶ Ready to start now** |
| **How do I build `FW-157`?** | Its category, [`FS-07`](10-requirements/features/FS-07-rod-checkin-plc-config.md) — requirements, scope, open items and change impact; the card in [`[TB §7]`](60-delivery/TaskBreakdown.md) for its acceptance criteria and hours. ⛔ **There is no longer a per-story plan file.** How it *was* built, if it was, is in [`95-archive/task-plans/`](95-archive/task-plans/) — **not citable** |
| **What is still undecided?** | [`90-registers/Questions.md`](90-registers/Questions.md) `Q##` (business) · [`90-registers/Gaps.md`](90-registers/Gaps.md) `G##` (internal) · master spec §11 `OI-##` |
| **Where is everything else?** | [`./DOCUMENTS.md`](./DOCUMENTS.md) — the document map and shortcode table |

---

## The three files that matter most

**[`STATUS.md`](STATUS.md) — the board, by phase.** ⚙ **Generated. Never edit it.** Its 204 rows
now come from `[SCM]` joined to the parents' activity tables. To change what it says, change the
**activity row in its parent** and re-run `python tools/build_status.py`. The page states its own
provenance at the top.

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

⛔ **`*/tasks/FW-###.md` no longer exists — retired 9 Sep 2026.** One file per story per stream
was the shape this repository tracked work in until the `FS-##` consolidation; a one-line rename
(`D-56`) cost three stories, and the FL2 gauge reversal cost four. **A story is no longer a planning
unit — its category is.** Where each thing went:

| Was in the task file | Is now |
|---|---|
| `status:`, `depends_on:`, `blocked_by:`, verification evidence | the owning parent's **activity table** — the single writable home of status |
| `owner:` | the parent's `owner:` front-matter, one per category |
| phase, sprint, MVP, streams, hours, title | [`StoryConsolidationMap.md`](90-registers/StoryConsolidationMap.md) `[SCM]`, which is **frozen** |
| the acceptance criteria | **unchanged, on the backlog card** in [`[TB §7]`](60-delivery/TaskBreakdown.md) — all 1,222 of them; only 7 % cite a spec, so they are original detail and were not merged up |
| the implementation plan — how it was built | [`95-archive/task-plans/`](95-archive/task-plans/), which is **not citable**: read it for what was built, never as a requirement |

The `*/tasks/` folders still hold five **demoted** sequencing boards. Each says so at the top, and
every `FW-###` link on them points at a retired file — `[SCM]` is the forwarding address.

## Picking up a task

⚠ **This changed on 9 Sep 2026.** Status is no longer a line in your own file — it is a **row in
the activity table** of the parent that owns the work. That table is hand-maintained and shared, so
two people working in one category edit one file. Keep the edit to your row.

```
# 1. Find work: STATUS.md -> your stream -> "Ready to start now"
#    (dependencies met, nothing blocking). FEATURES.md is the same by feature.

# 2. Open the owning parent: 10-requirements/features/FS-##-*.md, section 5.
#    Which parent? STATUS.md's row links to it, or look the id up in [SCM].

# 3. Claim your row - the Status cell only, and no other row:
#      | 7 | Check-in transaction | BE | in-progress | FW-157 | - | |

# 4. Read the card for WHAT to build: [TB section 7] carries the acceptance
#    criteria and the hours. The parent carries requirements, scope and impact.
#    There is no per-story plan any more; a past one may be in 95-archive/
#    task-plans/, which is NOT citable.

# 5. Blocked? Name the register id in the blocked_by cell. Never prose.

# 6. Done? Put the measured result in the Evidence cell - 95-archive/ is not
#    citable, so an unrecorded verification is a verification that is gone.
#    in-review -> a reviewer sets done.

python tools/build_status.py            # regenerate the phase board
python tools/build_features.py          # regenerate the feature board + blocks
python tools/build_features.py --selftest   # the tables still round-trip
python tools/check_docs.py              # would CI pass? 0 errors; 50 warnings are the floor
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
| `python tools/build_consolidation_map.py` | ⛔ **Frozen.** It generated the map *from* the task files, so with those retired it reports the freeze and exits 0. `[SCM]` is now hand-owned; correct it by editing it |
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
