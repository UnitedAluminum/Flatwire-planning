# Flat Wire — Task ID Map (`FW-###` ↔ JIRA)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 7, 2026 · **8 Sep 2026 (`D-56`): `LineId` is renamed `MachineName` throughout** — same `VARCHAR(5)` shape, same `CHECK` values, operator-visible labels unchanged. `FW-N17`/`FW-N18`/`FW-N19`.
**Document Type:** Register — the only home for the story-id ↔ JIRA-issue pairing
**Status:** Active — seeded from commit history; filled in as JIRA issues are created
**Owner:** Delivery lead
**Audience:** Delivery lead, anyone running the id cutover
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

---

## Why this file exists

Task ids stay in the `FW-###` format until JIRA issues exist. At that point `FW-###` is
**replaced** by the real JIRA id, in one scripted pass
([`tools/migrate_task_ids.py`](../tools/README.md)). That pass reads **this table and
nothing else** — it is the only place the pairing is recorded, so a story's JIRA key is
never copied into a second document that can drift from it.

Until a row exists here, a task file's `jira:` field stays empty and its `id:` stays
`FW-###`. Nothing else in the repository changes.

---

## ⚠ The mapping is many-to-one today, and the cutover cannot run until it is not

Mining `ual-api` history for `FW-###` ↔ `UADEV-#####` pairs returns **one JIRA key covering
at least eight stories**:

| JIRA | Covers | Source |
|---|---|---|
| `UADEV-23146` | `FW-145`, `FW-150`, `FW-151`, `FW-202`, `FW-203`, `FW-205`, `FW-218`, `FW-N05` | `ual-api` branch `feature/UADEV-23146` commit messages |

`UADEV-23146` is a **container issue for the Phase-1B backend**, not a per-story issue. That
matters more than it looks:

> **A replacement needs one JIRA issue per `FW-###` story.** Eight stories cannot all be
> renamed to `UADEV-23146.md`, and eight tasks cannot share one status in JIRA — which is the
> whole reason for the swap. **If JIRA issues continue to be raised at phase or epic
> granularity, the id replacement is not possible** and `FW-###` has to remain the working id
> with `jira:` carrying the epic as a *reference* rather than a replacement.

This is a decision for the delivery lead, and it is the one thing that gates the cutover.

### ⚠ The `FS-##` consolidation did NOT resolve this — 9 Sep 2026

The 204 stories were consolidated into the 20 parents `FS-01`–`FS-20`
([`StoryConsolidationMap.md`](StoryConsolidationMap.md) `[SCM]`), which makes an obvious
suggestion available: raise **one JIRA epic per `FS-##`** and let `jira:` on the parent carry it —
the *reference rather than replacement* fallback this section already describes.

**It is recorded here as an option and nothing more. No decision has been taken, and this file
claims none.** The measured obstacle is that the epic boundary and the category boundary are not the
same boundary today:

| | |
|---|---|
| `UADEV-23146` covers | `FW-145`, `FW-150`, `FW-151`, `FW-202`, `FW-203`, `FW-205`, `FW-218`, `FW-N05` |
| Those eight fall in | **three** categories — `FS-02` (1), `FS-04` (6), `FS-08` (1) |

So the one epic that exists straddles three parents. Adopting `FS-##` as the epic boundary while
`UADEV-23146` stands would create **three** id spaces with two many-to-one edges, where there is one
many-to-one edge today — strictly worse than the present state.

**What would have to be true first:** the delivery lead commits to raising epics *on the `FS`
boundary*, and `UADEV-23146` is either split or accepted as a legacy exception. Until one of those is
recorded here, `FW-###` remains the working id, every parent's `jira:` field stays empty, and the
cutover stays gated by the two things named below.

✅ **The task files are back, so the cutover tool's job is unchanged.** Full dissolution briefly
retired them on 9 Sep 2026 and was reversed the same day, so a pass that renames
`*/tasks/FW-###.md` still has files to rename. ⚠ **But it now has three more places to sweep:**
the `[TB §7]` card heading, the `[SCM]` row, and each parent's activity row — all tables, none of
them a filename, and none of them existed when this section was written.

---

## The map

One row per story. `Created` is the date the JIRA issue was raised, for audit.

| `FW-###` | JIRA id | Created | Note |
|---|---|---|---|
| — | — | — | *No 1:1 pairing recorded yet. Add a row per story as its issue is created.* |

---

## Rules

1. **A story appears at most once.** Two rows for one `FW-###` is a defect, not a merge.
2. **Never infer a pairing.** A commit that mentions a story under an epic key is evidence of
   *work*, not of a 1:1 issue; the table above records exactly that distinction.
3. **Ids that will never get a JIRA issue stay `FW-###` forever** — the cancelled
   (`FW-001`, `FW-002`), the upstream-deleted (`FW-020`–`FW-022`) and the MVP-2 set. They are
   simply absent from this table, and the migration tool leaves them alone and reports them.
4. **`CHANGELOG.md` and any archived document keep the old ids by design**, the same
   convention the repository already applies to the `Q##` renumbering.
5. **`FW-N##` is in scope for this map and takes a row like any other id** *(added 7 Sep 2026 — the
   form existed for six stories and was addressed by no rule here)*. The `N` marks a story **minted
   after the original numbering**, not a different class of work: `FW-N01`–`FW-N06` carry task files,
   `[TB]` cards and `[SCM]` rows exactly as `FW-###` stories do, and `tools/fwtasks.py` matches
   both with one pattern (`^FW-N?\d+\.md$`). ⚠ **When the cutover pass is written it must scan `FW-N?\d+`, not
   `FW-\d{3}`**, or the six are silently skipped.
   ⛔ **And it has not been written: `tools/migrate_task_ids.py` does not exist** *(measured 7 Sep
   2026)*, though the section above names it as this table's sole consumer. The cutover is
   consequently gated by two things, not one — the many-to-one JIRA problem **and** an absent tool.
   ⚠ Whoever writes it must reuse `tools/fix_task_links.py`'s guard
   `\bFW-(\d{3}|N\d{2})(?![\dA-Za-z-])`: **`FW-#####-C##` is an output-coil alpha, not a story id**,
   and there are 299 of them in the repository.
6. ⚠ **`FW-N07`–`FW-N12` are minted but have no task file.** They
   are reserved in [`TaskBreakdown.md`](../60-delivery/TaskBreakdown.md)'s Appendix B ledger and
   cross-referenced from around a dozen documents. **They are not free to reuse, and they take no
   row here** until a task file exists — Rule 1 counts stories, not reservations. They are carried in
   [`[SCM]`](StoryConsolidationMap.md)'s retired-ids table with `Retain`, so their requirement
   ranges reach a category (mostly `FS-20`) even though they were never work. ~~**New `N` ids therefore mint at
   `FW-N13`.**~~ ~~**Restated 8 Sep 2026: they now mint at `FW-N20`.**~~ ⚠ **Restated again
   9 Sep 2026: they mint at `FW-N34`.** `FW-N20`–`FW-N33` were all taken between 8 and 9 Sep 2026,
   which is why a next-free id must be **measured, not read** — the highest `FW-N##` across
   [`TaskBreakdown.md`](../60-delivery/TaskBreakdown.md) and [`[SCM]`](StoryConsolidationMap.md) is
   the only answer that is not already stale. `FW-N13` was taken on
   7 Sep, `FW-N15`/`FW-N16` by `D-55` the same day, and `FW-N17`–`FW-N19` by `D-56` on 8 Sep — all
   six carry task files and `[TB]` cards, so all six are stories by Rule 1.
7. ⚠ **`FW-N17`–`FW-N19` have no JIRA id yet and therefore take no row above.** They are the
   `LineId` → `MachineName` rename (`D-56`), one story per stream: `FW-N17` DB, `FW-N18` BE,
   `FW-N19` FE. ⛔ **This is not a gap in the map** — the 1:1 table above is keyed by JIRA id and
   records a pairing only once an issue exists. Add a row per story as its issue is created, and
   note that `FW-N18`'s work landed on `ual-api` branch `feature/UADEV-23146`, which the
   many-to-one table already covers under `UADEV-23146`.
