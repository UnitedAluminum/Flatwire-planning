# Archived implementation plans

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — archived by the `FS-##` consolidation, step 9
**Document Type:** Archive — the per-story implementation plans, retired as planning units
**Status:** ⛔ **Not citable.** Nothing here is a requirement, ever
**Audience:** Anyone reconstructing how a story was built

---

⛔ **`95-archive/` is not citable by repository rule, and that applies here.** These 108 files were
`{30,40,50,60,70}-*/tasks/FW-###.md` — one implementation plan per story, and the unit of planning
until 9 September 2026. They are **moved, not destroyed**: each plan's build order, the decisions it
made and its verification notes are all still readable.

**What replaced them**

| For | Read |
|---|---|
| What a functional area is, what it requires, what a change touches | [`10-requirements/features/`](../../10-requirements/features/README.md) — the 20 `FS-##` parents |
| Which category a story became part of | [`StoryConsolidationMap.md`](../../90-registers/StoryConsolidationMap.md) `[SCM]` |
| Status, by feature and by phase | [`FEATURES.md`](../../FEATURES.md) and [`STATUS.md`](../../STATUS.md) — both generated |
| A story's cost, phase, sprint, stream and acceptance criteria | its card in `[TB §7.2]` — **retained, all 1,222 criteria** |

⚠ **The measured verification from every completed plan was lifted out before archiving**, into the
owning parent's §2, precisely because this folder is not citable. To prove that built work was
verified, cite the parent — not this folder.

⚠ **A further 96 files were deleted rather than archived.** Those carried `has_plan: false` and their
entire body was a restatement of the backlog card, generated from it by `tools/init_tasks.py`. Nothing
in them existed anywhere else. They are recoverable from git at tag `pre-fs-consolidation`.

The filename prefix is the folder each plan came from — `backend-`, `frontend-`, `database-`,
`testing-`, `delivery-`.
