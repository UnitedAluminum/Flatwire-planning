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
| [`build_status.py`](build_status.py) | every `*/tasks/FW-*.md` front-matter, the phase files, all four registers | [`STATUS.md`](../STATUS.md) | `--check`: STATUS.md is stale |
| [`check_docs.py`](check_docs.py) | the same | nothing — reports | an unknown status, a dependency cycle, a blocker id in no register, backlog↔task drift, a task naming a phase that has no file, a stub in the wrong stream's folder |
| [`linkcheck.py`](linkcheck.py) | every `.md` `.sql` `.html` `.js` `.py` | `_linkcheck_baseline.json` | a reference that resolved in the baseline and no longer does |
| [`fwtasks.py`](fwtasks.py) | — | — | **Not a script** — the shared reader both generators import, so the board and the checker can never disagree about what a task file says |
| [`init_tasks.py`](init_tasks.py) | `../60-delivery/TaskBreakdown.md` §7 | `*/tasks/FW-*.md` | — *(one-off, Stage 1; safe to re-run — it preserves bodies and rewrites only front-matter)* |
| [`fix_task_links.py`](fix_task_links.py) | every text file | the same | the output-coil alpha count changing |
| [`fix_changelog_anchors.py`](fix_changelog_anchors.py) | `CHANGELOG.md` | the same | — *(reports anchors that match no heading)* |
| [`pathmap.py`](pathmap.py) | `git ls-files` | — | a destination collision, which would silently lose a file |
| [`retree.py`](retree.py) | every text file | the same | — *(resolves references, moves 396 files, repoints 2,029 citations in one operation)* |
| [`fix_tool_paths.py`](fix_tool_paths.py) | `tools/deliverables/*.py` | the same | — *(marker-based repo root, path joins, and the client-leakage guard lists)* |

---

## The daily loop

```bash
python tools/build_status.py     # regenerate the board after editing a task file
python tools/check_docs.py       # would CI pass?
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
