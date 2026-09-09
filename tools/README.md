# tools/ — tracking and migration scripts

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026
**Status:** Working scripts, committed so they stop being re-derived
**Audience:** Anyone maintaining the planning repository

---

These are the **repository-level** scripts: the task-tracking generator, its checkers, and the
one-off migration helpers. The **client-deliverable renderers** are separate and live in
[`MVP-1/ProjectPlan/Tools/`](deliverables/README.md) — the `.docx` and `.xlsx`
builders and `verify_schema_counts.py`. The two sets are kept apart because these are run by
developers on every commit and those are run when a client artifact is reissued.

All scripts here are **dependency-free** (standard library only) and find the repository root
by looking for `.git`, so they work from any working directory.

| Script | Reads | Writes | Fails on |
|---|---|---|---|
| [`build_status.py`](build_status.py) | `fwtasks.load_units()` — every `*/tasks/FW-*.md` front-matter, the phase files and all four registers. *(If the task files were ever retired it would fall back to the parents' activity tables joined to [`[SCM]`](../90-registers/StoryConsolidationMap.md); while they exist it returns them unchanged, which is the identity guarantee that kept `STATUS.md` byte-identical across the reversed dissolution.)* | [`STATUS.md`](../STATUS.md) | `--check`: STATUS.md is stale |
| [`build_features.py`](build_features.py) | the 20 parents, `[SCM]`, all four registers | [`FEATURES.md`](../FEATURES.md) **and** each parent's `absorbed-stories` and `blockers` marker blocks | `--check`: the board or any block is stale. `--selftest`: an activity table does not round-trip — **and a zero total is a failure**, because seeded only from `load_tasks()` this check went vacuous the moment the task files were deleted |
| [`build_consolidation_map.py`](build_consolidation_map.py) | every `*/tasks/FW-*.md`, `[TB §7]`, `[REQ]` | [`StoryConsolidationMap.md`](../90-registers/StoryConsolidationMap.md) §2 only — §1 and §3 are hand-owned | a story in no category or two, a no-op or stale membership rule, a `[REQ]` section reaching no category. ⚠ It **freezes itself** — prints a notice and exits 0 — if the task files are absent, because it cannot generate without them |
| [`check_docs.py`](check_docs.py) | the same, **plus the 20 parents and `[SCM]`** | nothing — reports | **Errors:** a card costed with no map row or a map row with no card (rule 4), a parent's `phases:` not resolving or carrying `status`/`hours`/`stream`/`depends_on` (rule 7), a map row naming a parent that does not exist, or a parent no story maps to that the map does not declare empty (rule 8). **Warnings:** a card's `**Blockers:**` line diverging from the authoritative activity row in its parent (rule 9 — **50 today**; the whole floor is **237**, the other 187 being the long-standing task-scoped ones) |
| [`linkcheck.py`](linkcheck.py) | every `.md` `.sql` `.html` `.js` `.py` | `_linkcheck_baseline.json` | a reference that resolved in the baseline and no longer does. ⚠ **A mid-dissolution re-pin (4,120 → 3,304 pairs) was REVERTED** with the task files; the baseline is the pre-consolidation one again, green at ~4,500 pairs. `_linkcheck_delta_2026-09-09.txt` keeps that measurement as the audit trail of a reversed change — it does **not** describe the repository today |
| [`stamp_trial_status.py`](stamp_trial_status.py) | — | — | ⛔ **RETIRED 9 Sep 2026 — DO NOT RUN.** It wrote into `TrialOrchestration.md`, which is archived at [`95-archive/orchestration-boards/`](../95-archive/orchestration-boards/) and closed to further updates. Running it would stamp current-looking status into a place that is by rule never current. It refuses rather than raising. The 66-story trial record is now `[TRP §4]` and `FlatWire_TrialRunPlan.xlsx` |
| [`storymap.py`](storymap.py) | every `*/tasks/FW-*.md` and `10-requirements/features/`, plus `[SCM]` | — *(computes; `retree.py` moves)* | a story in no category, a destination collision, or a planned count that does not match the task files. **Owns the placement rule** — `destination_stream()` is `FE`→`BE`→`RT`→`DB`→`QA`→`BA`, first present wins — and `check_docs` rule 6 compares the tree against it, so the two cannot drift. `--check` reports any story not where the rule puts it |
| [`fwtasks.py`](fwtasks.py) | — | — | **Not a script** — the shared reader every generator and the checker import, so they can never disagree about what a story says. ⚠ **`load_units()` is the safety seam:** it returns `load_tasks()` unchanged while task files exist, so `STATUS.md` stayed byte-identical across the migration, and reconstitutes the same row shape from `[SCM]` + the activity tables once they are gone |
| [`init_tasks.py`](init_tasks.py) | `../60-delivery/TaskBreakdown.md` §7 | `*/tasks/FW-*.md` | ⛔ **DEAD — DO NOT REPAIR AND DO NOT RUN.** It reads a pre-29-Aug path and raises `FileNotFoundError` on the first line of `main()`. **A repaired version would overwrite the front-matter of all 204 live task files from the backlog** — every `status:`, `owner:`, `depends_on:` and `blocked_by:` value, which is the one writable copy of each. If a generator is ever needed, write a new one-way tool |
| [`fix_task_links.py`](fix_task_links.py) | every text file | the same | the output-coil alpha count changing |
| [`fix_changelog_anchors.py`](fix_changelog_anchors.py) | `CHANGELOG.md` | the same | — *(reports anchors that match no heading)* |
| [`pathmap.py`](pathmap.py) | `git ls-files` | — | a destination collision, which would silently lose a file |
| [`retree.py`](retree.py) | every text file | the same | — *(resolves references, moves 396 files, repoints 2,029 citations in one operation)* |
| [`fix_tool_paths.py`](fix_tool_paths.py) | `tools/deliverables/*.py` | the same | — *(marker-based repo root, path joins, and the client-leakage guard lists)* |

---

## The daily loop

```bash
python tools/build_status.py     # the phase board, after editing a task file
python tools/build_features.py   # the feature board and the parents' generated blocks
python tools/build_features.py --selftest   # the activity tables still round-trip
python tools/storymap.py --check     # every story where the placement rule puts it
python tools/check_docs.py       # would CI pass?  0 errors, 237 warnings (the floor)
python tools/linkcheck.py        # did I break a path reference?
```

Install the hook once and the first two happen automatically:

```bash
cp tools/hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

For CI, or a nightly job, use the strict forms — they promote the tracked-debt warnings to
failures:

```bash
python tools/build_status.py --check
python tools/linkcheck.py --literal
python tools/check_docs.py --strict
python tools/linkcheck.py
```

---

## Three details that look like defects and are not

**1. `check_docs.py` allowlists.** Three constants — `STALE_BLOCKER_IDS`, `KNOWN_CYCLES` and
`FOLDER_STREAM_EXCEPTIONS` — each name a gap (`G61`, `G63`, `G62`) and exist so the checker is
**green with the debt visible** rather than permanently red. A permanently red checker trains
people to ignore it. **Delete entries as they are resolved**; when a list empties, the rule
becomes fatal on its own and the constant should go.

**2. A blocker that has closed is a *warning*, not an error.** Closing `G2` must not break the
build for whoever happens to own `FW-157`. `STATUS.md` renders *"⚠ blocker closed — needs status
update"* on the row and `--strict` fails nightly. The signal is loud; the gate is where it belongs.

**3. `STATUS.md` publishes no hours total, on purpose.** The first build summed the story cards
to **2,823 h** against the documented **3,186 h** — a second figure to disagree with `[CE]`,
which is the exact defect this tracking layer exists to remove. Percentages are by **task
count**; per-task `h` is quoted from the card, never summed.

---

## The encoding trap, written down because it bit this work twice

The registers separate fields with **U+00B7 MIDDLE DOT** (`**Q22** · \`High\` · Owner: …`).
Writing a Python file through a shell heredoc on this machine decodes stdin as **cp1252**, which
turns that character into mojibake — and a regex containing mojibake matches **nothing at all**,
silently, with no error. It cost a debugging pass when `RE_Q_ENTRY` suddenly parsed zero of 56
entries.

`fwtasks.py` therefore writes the separator as an escape rather than a literal, and every file
here is written with an explicit `encoding='utf-8'`. **Edit these scripts with a real editor or
a file-writing tool, not a heredoc.**
