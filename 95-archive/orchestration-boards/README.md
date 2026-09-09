# Archived orchestration boards

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — archived by the story-folder restructure
**Document Type:** Archive — the five hand-maintained sequencing boards, retired
**Status:** ⛔ **Not citable.** Nothing here is a requirement, ever — and nothing here is current
**Audience:** Anyone reconstructing how the streams were sequenced

---

⛔ **`95-archive/` is not citable by repository rule, and that applies here.** These five files were
the per-stream sequencing boards:

| Was | Held |
|---|---|
| `40-backend/tasks/Orchestration.md` | the dependency graph, seven build waves, six ratification gates, the blocker calendar |
| `40-backend/tasks/TrialOrchestration.md` | the 66 trial stories across four streams, by sprint |
| `30-database/tasks/Orchestration.md` | the DB stream's execution index |
| `50-frontend/tasks/Orchestration.md` | the FE stream's, on the same axis |
| `50-frontend/tasks/Phase-01A-ImplementationPlan.md` | phase 1A's shared frontend context |

They were **demoted for status on 9 Sep 2026** when `FEATURES.md` and `STATUS.md` became the
generated boards, and **archived and closed to further updates** the same day.

**What replaced them**

| For | Read |
|---|---|
| Status, % complete, what is blocked, what can start | [`FEATURES.md`](../../FEATURES.md) and [`STATUS.md`](../../STATUS.md) — both **generated** |
| What a functional area is, and what a change to it touches | [`10-requirements/features/`](../../10-requirements/features/README.md) — the 20 `FS-##` parents |
| Which category and stream folder a story sits in | its own path, and `python tools/storymap.py --check` |

⚠ **The 66-story trial view goes with them.** `tools/stamp_trial_status.py` stamped live status into
`TrialOrchestration.md`'s sprint grids; it is **retired**, and the trial's own record is now
[`[TRP §4]`](../../60-delivery/TrialRunPlan.md) and `FlatWire_TrialRunPlan.xlsx`.

⚠ **Their `FW-###` links point at the pre-restructure flat layout** (`*/tasks/FW-###.md`) and no
longer resolve. That is deliberate: the paths were correct when these files were written, and
rewriting them would falsify the record. Stories now live at
`10-requirements/features/<category>/<STREAM>/FW-###.md`.

**What is still worth reading here:** the dependency-wave and sequencing narrative, which exists
nowhere else. ⛔ **Do not trust a status glyph, a percentage or a blocker list on any of these
pages**, and do not cite them.
