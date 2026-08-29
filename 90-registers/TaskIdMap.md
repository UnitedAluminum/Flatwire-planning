# Flat Wire — Task ID Map (`FW-###` ↔ JIRA)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026
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
