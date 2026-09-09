---
id: FW-152
legacy_id:
title: FlatWireDB creation, ordered DDL runner, indexes and grants
status: in-review
status_confirmed: false
status_note: "✅ **BUILT AND DEPLOYED on `DEV00164-001`.** All seven acceptance criteria **measured live on 30 Aug 2026** (§5.1); two card details are recorded rather than fixed — §2.2, §2.3"
owner:
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB]
priority: critical
hours: 12
sprint: S0
depends_on: []
blocked_by: []
has_plan: true
started:
completed:
---
# FW-152 · `FlatWireDB` creation, ordered DDL runner, indexes and grants

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 30, 2026 — Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story — **build-state record**
**Status:** ✅ **BUILT AND DEPLOYED on `DEV00164-001`.** All seven acceptance criteria **measured live on 30 Aug 2026** (§5.1); two card details are recorded rather than fixed — §2.2, §2.3
**Owner:** Database (SQL Server) stream
**Audience:** Anyone picking up `FW-152` and expecting to write DDL
**Shortcode:** — *(implementation plan, derived from the DDL and the tools; **not citable as a requirement**)*
**Part of:** `30-database/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** ⛔ **To stop someone building a thing that already exists**, and to
> settle the two places the card reads wider than the design it cites.
>
> **The chain is built, deployed and idempotent.** Measured, not read: the count guard passes all
> six checks, every `CREATE` and every FK is guarded, no `USE [united_db]` header survives, and the
> two programmability objects are the two the card names. **`sp_ShiftSummary` is correctly absent.**
> **The one thing that moved is *where*.** The target is **`DEV00164-001`** — the only instance on
> which the no-MSDTC premise this whole design rests on has ever been demonstrated (§2.1).
> ⚠ **A literal reading of AC 4 finds a defect that is not there.** `[DBD §6.8]` governs, and the
> DDL follows it exactly (§2.2). **Do not add the index** — it moves a baseline to buy nothing.
> ⚠ **AC 5 spans two folders and two grant conventions**, and the card names neither (§2.3).

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-152 · `FlatWireDB` creation, ordered DDL runner, indexes and grants
> **Hours:** 12 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB
>
> **As a** database owner,
> **I want** the whole schema deployable by one idempotent, ordered script,
> **So that** any environment can be rebuilt from scratch and re-run safely.
>
> **Acceptance Criteria:**
> - [ ] `FlatWireDB` created; every `USE [united_db]` header retargeted
> - [ ] Execution order preserved, a contiguous chain: `00` database → `01` Lookup → **`02` Schedule** → `03` Materials → `04` Runs → `05` Quality/Output → `06` **all FKs last** → `07` Indexes → `08` Programmability. ⚠ **`02_Schedule` IS in this chain** — `D-31` (15 Aug 2026) moved the three `PassSchedule*` tables into MVP-1. *(This line read "`02_Schedule` is absent — the pass schedule is owned outside MVP-1" until 26 Aug 2026.)* Only `09_Programmability_MVP2` stays out
> - [ ] Every `CREATE` and FK guarded (`IF NOT EXISTS`); `FlatWire_DDL_RunAll.sql` is **idempotent and re-runnable**
> - [ ] All ER-doc recommended nonclustered indexes present, including `(RunId)` on every child/event table
> - [ ] `GRANT EXECUTE` / least-privilege for `ua_user`; audit columns on override tables
> - [ ] Post-run check: the objects are **`sp_GetGaugeTrace`** and **`trg_CoilTraceability_NoOverlap`**; the counts are `[DBD §6.2]`'s and are verified by `[DEP §4.2]`'s `V1`–`V3` gate or [`../../tools/deliverables/verify_schema_counts.py`](../../tools/deliverables/verify_schema_counts.py), **not restated here**. *(This line published `33 · 55 · 69` until 26 Aug 2026; `Q89` took the index count to 70 that day.)*
> - [ ] **`sp_ShiftSummary` is MVP-2's and must not be created, dropped or granted from this scope**
>
> **Rate-card basis:** database creation + ordered runner + index strategy + security (12 h, §2)
> **Dependencies:** None
> **Blockers:** —

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| The tables the chain builds | `FW-005` (Lookup) · `FW-006` (Materials) · `FW-007` (Runs + Quality/Output) — this story owns the **runner**, not the groups |
| Deploy **step 2**, the shared-schema rows | [`FW-241`](FW-241.md) — Draft, no reverse script, **never run**, and the chain's only irreversible step |
| `sp_ShiftSummary` and `09_Programmability_MVP2` | MVP-2. AC 7 exists to keep it out |
| `sp_IngestRodFromCoils` | `FW-223` — a `FlatWireDB` object that ships in `scripts/`, deliberately **not** in the runner |
| The counted baseline | **`[DBD §6.2]`** — the only site that defines it. This record states none |
| The count guard's `C6` blind spot | [`FW-248`](FW-248.md) — and its `[DBD]` repairs with it |
| Moving the DDL into `ual-database` | [`FW-242`](FW-242.md) |

### 1.2 What already exists

Measured by **running the tools and reading the DDL on 30 Aug 2026**, not read off a document.

| Thing | State |
|---|---|
| `FlatWireDB` creation | ✅ `FlatWire_DDL_00_Database.sql` — guarded `CREATE DATABASE`, plus `READ_COMMITTED_SNAPSHOT` and `ALLOW_SNAPSHOT_ISOLATION` on |
| **AC 1** — retargeting | ✅ **Zero executable `USE [united_db]` remain.** Every `USE` in the folder is `USE [FlatWireDB]`; the surviving `united_db` mentions are comment prose |
| **AC 2** — the chain | ✅ The runner's `:r` list is a contiguous `00`→`08`, nine includes, `02_Schedule` among them. `09_Programmability_MVP2` is excluded by name, in a banner that says why |
| **AC 3** — guards | ✅ Every table, every FK and every index guarded; the eight compound FK guards all carry their `NOT EXISTS` half, so there is no idempotency hole. `:on error exit` is set |
| **AC 4** — indexes | ✅ Every index lives in `07`, one guard per statement, no duplicates. `(RunId)` is present on all fourteen run children. ⚠ The fifteenth is **§2.2** |
| **AC 5** — grants | ✅ `EXECUTE ON SCHEMA::[dbo]`, `db_datareader` and `db_datawriter` to `ua_user`, all principal-guarded; `RollOverride` carries `OperatorId` + `Timestamp`. ⚠ The other half is **§2.3** |
| **AC 6** — objects | ✅ Exactly `sp_GetGaugeTrace` and `trg_CoilTraceability_NoOverlap`. No views, no functions |
| **AC 7** — `sp_ShiftSummary` | ✅ Isolated in `09` and its own runner. `08`'s stale `DROP`, its fake success `PRINT` and its `GRANT` were **removed**, and a comment records the removal |
| The count guard | ✅ [`verify_schema_counts.py`](../../tools/deliverables/verify_schema_counts.py) — **all six checks green**, and `C1` reconciles the DDL against `[DBD §6.2]` **and** `[DEP §4.2]`'s gate |
| The deployment | ✅ **`DEV00164-001`** — deployed 26 Aug 2026, full `[DEP §4.2]` sequence less the sign-off-gated step 2. ⭐ **Re-verified live on 30 Aug 2026: `V1`–`V6` green, `V4` at 7/7, `Q60` clean, and the runner re-run idempotently — see §5.1** |
| Teardown | ✅ `FlatWire_DDL_99_Teardown.sql`, guarded, in neither runner by design |

---

## 2. The three details

### 2.1 The chain is built; where it is built is the part that moved

The runner has always carried a ⚠ banner saying the target is the **shared** instance, because
check-in spans `FlatWireDB` and the shared schema in **one** `SqlTransaction` under the local
transaction manager with no MSDTC (`[INT §8.0]`, `[ARC §10]`). LocalDB has none of those databases,
so a build validated only there **silently** loses atomicity. That has never been in doubt.

**What was in doubt is which shared instance, and the answer is `DEV00164-001`.** Three
independent records agree, and none of them is this file:

| Record | What it says |
|---|---|
| `[DEP §2]`'s environments table | `test1`'s database server is **`DEV00164-001`** *(verified 26 Aug 2026)* |
| `ual-api`'s [`appsettings.json`](../../../Second-Branch/ual-api/API/Domain/FlatWire/FlatWire.API/appsettings.json) | `SqlSetting:DSN` resolves `UA_Connection_String_dev00164001` — `G57`, raised and closed 27 Aug |
| The 26 Aug deploy record | ⭐ **The no-MSDTC premise was demonstrated there for the first time** — `is_local = 1`, `is_enlisted = 0` on one transaction spanning `FlatWireDB` and `proddb`, with `united_db..machines` read in the same pass |

That third row is the one that settles it. The premise `[INT §8.0]` and `[ARC §10]` assert had
**never** been proven anywhere before, `DEVUAL-UADEV001\TEST1` included.

⚠ **So `DEVUAL-UADEV001\TEST1` is retired for `FlatWireDB`, not behind.** Its copy predates the
23 Aug `Q60` swap — it still holds `SpoolConfiguration` and `SpoolCarrier`, has no
`SpoolProcessing`, and its `Spool` still carries `Alpha`, which is the one rename `CLAUDE.md` flags
as *silently wrong rather than obviously stale*. **No teardown of it is owed by this story.**
Anything describing that rebuild as outstanding work describes an abandoned instance.

> ⚠ **And a guarded re-run would not have repaired it anyway.** `IF NOT EXISTS` is what makes the
> chain idempotent, and it is exactly what makes it unable to fix a drifted database: it steps over
> the stale `Spool` rather than correcting it. On a drifted instance the sequence is
> `99_Teardown` **then** `FlatWire_DDL_RunAll.sql` — never the runner alone. Recorded because
> "idempotent and re-runnable" (AC 3) reads like a repair guarantee and is not one.

### 2.2 AC 4 reads wider than `[DBD §6.8]`, and the DDL follows `[DBD §6.8]`

Fifteen tables carry a `RunId`. Fourteen have an index on it. The fifteenth is
**`PassScheduleChangeLog`**, and read literally — *"`(RunId)` on every child/event table"* — that is
a missing index.

**It is not.** `[DBD §6.8]` is the authority here: the ER documentation was absorbed into `[DBD]`
§6–§7 on 13 Aug 2026 and deleted, so *"ER-doc recommended"* means that section's coverage list. It
asks for *"every FK / `RunId` **join column**"* and *"`(RunId)` on every **event** table"* — and for
this table it names exactly one index, `PassScheduleChangeLog(PassScheduleId, Timestamp DESC)`,
which is the one that exists.

Three things make `RunId` there not qualify:

- **It carries no FK.** The table's only FK is `FK_PSChangeLog_PassSchedule`.
- **It is nullable context, not a parent link** — the column's own comment reads *"run in progress
  when the change was made; **NULL when made outside a run**"*.
- **It joins in no query path**, and `[DBD §6.10]` names none. **MVP-1 reads a pass schedule and
  never authors one** (`OI-110`), so the changelog is barely written and never read by run.

⛔ **Do not add the index.** It would take the index baseline up by one and cascade into `[DBD §6.2]`,
`[DBD §6.8]`, `[DEP §4.2]`'s `V3` in **both** its SQL-comment and checklist forms, `FlatWire_DDL_07_Indexes.sql`'s
own header and both runner banners — a `Q##`-sized change across the three sites permitted to
restate a count, buying an index nothing queries and a write cost on an audit table. The card's
parenthetical stays as audit trail, per `P-193`; `FlatWire_DDL_07_Indexes.sql` now carries a comment saying so,
so the next reviewer does not re-raise it. **`P-263`.**

### 2.3 Grants straddle two folders and two conventions

AC 5 is one line and its subject lives in two places. Both are correct; neither is wrong; the card
names only the first.

| Half | Where | Convention |
|---|---|---|
| Database-local privileges | `FlatWire_DDL_00_Database.sql` (`EXECUTE ON SCHEMA::[dbo]`, `db_datareader`, `db_datawriter`) and `FlatWire_DDL_08_Programmability.sql` (`sp_GetGaugeTrace`) | Granted to **`ua_user`**, principal-guarded |
| The `ua_user` **principal itself**, in six databases | [`20_FlatWire_Grants.sql`](../scripts/20_FlatWire_Grants.sql) — **deploy step 3**, outside the `00`–`08` chain | Its procedures grant to **`[public]`**, *"the UAL convention"*, stated in the script's own header |

⚠ **Two consequences.** A reader checking AC 5 against the runner alone finds half of it and may
report the `[public]` grants as a least-privilege regression — they are the house convention, not a
defect. And **step 3 is also where the co-location pre-flight query lives**, so §2.1's proof and
AC 5's grants are the same script.

`EXECUTE ON SCHEMA::[dbo]` is broader than per-object least privilege. It is deliberate and
documented in place — it covers future procedures without a grant edit per object.

---

## 3. Build order — what is left

**Nothing in the DDL.** All seven acceptance criteria are met. What remains is closure:

1. ⬜ **Confirm the status.** This record's `status_confirmed` is `false`. ⚠ **It is no longer
   *inferred* — §5.1 measured every acceptance criterion against the live database on 30 Aug 2026** —
   but `done` is an owner's signature, not a tool's, so it stays `in-review` until someone signs it.
   **This is the only item still open.**
2. ✅ **Re-run the guard and the gate** — `python tools/deliverables/verify_schema_counts.py`, then
   `[DEP §4.2]`'s `V1`–`V6`. The guard is static; the gate is live; **AC 6 wants both**.
   **Both run green on 30 Aug 2026 and they agree with each other** (§5.1).
3. ✅ **Teardown was not required.** §2.1's callout applies only to a drifted instance, and
   `DEV00164-001` measured post-`Q60` and clean. The runner alone was correct, and re-running it
   changed nothing (§5.1).
4. ⬜ **Leave step 2 alone.** It is [`FW-241`](FW-241.md)'s, it is irreversible, and the `scripts/`
   runner skips it on purpose.

> ⚠ **This story changes no schema object.** `C1`'s measurement must be **identical** before and
> after anything done under it.

---

## 4. Decisions this plan makes

> The `P-##` series belongs to [`40-backend/tasks/`](../../40-backend/tasks/Orchestration.md) and is
> continuous across the repository; `P-01`–`P-261` precede this story.
>
> ⚠ **These three were minted as `P-258`–`P-260` on 29 Aug 2026 and renumbered on 31 Aug 2026.**
> The de-stub of [`FW-157`](../../40-backend/tasks/FW-157.md) had taken the same three ids in code the same
> day, for the check-in unit of work, the acknowledgement snapshot and the component filter. The code's
> ids are cited from four `ual-api` source files and this file's were cited nowhere, so **this is the
> side that moved** — the one exception to *register ids are never renumbered*, taken because a collision
> is worse than a renumber and the cost here was three lines.

### `P-262` — the target instance is `DEV00164-001`, and `DEVUAL-UADEV001\TEST1` is recorded as retired

§2.1. Two shared instances with different schema versions is a trap that costs a debugging session
each time someone reads the wrong one, and the deciding evidence is one-sided: `DEV00164-001` is
`[DEP §2]`'s server for `test1`, it is what `ual-api` resolves, and it is the only place the
no-MSDTC premise has been demonstrated.

**Fallback:** keep both and mark the old one *"behind"*. Rejected — *"behind"* invites a rebuild
nobody owes, and it is how the pre-`Q60` copy stayed live-looking for a week.

### `P-263` — `PassScheduleChangeLog.RunId` stays unindexed; the card's wording is audit trail

§2.2. `[DBD §6.8]` says *event* table, the card says *child/event*, and the DDL follows the design.
Moving a counted baseline to close a wording gap costs six documents and buys nothing.

**Fallback:** add the index and sweep the baseline. Correct but disproportionate, and it would have
to be a `Q##` — the counts are not this story's to move.

### `P-264` — AC 5's second half is documented here rather than added to the card

§2.3. The grants seam is real and the two conventions are both correct, so this is a *reading*
problem, not a scope problem. `[TB §7]`'s card is the contract and stays verbatim; the record
carries what the contract leaves implicit.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified on a DEV instance and by running the tools.

| Check | Expected |
|---|---|
| **The guard** | `python tools/deliverables/verify_schema_counts.py` — **all six checks green**, and `C1` identical before and after this record |
| **The gate** | `[DEP §4.2]`'s `V1`–`V6` on `DEV00164-001`, `V4` at 7/7, `V5`/`V6` zero rows |
| AC 1 | `grep` the SQL folder for an executable `USE [united_db]` and find none |
| AC 2 | The runner's `:r` list is `00`→`08`, contiguous, `02_Schedule` present, `09` absent |
| AC 3 | Teardown → `FlatWire_DDL_RunAll.sql` → **run it again**: the second pass reports no change |
| AC 4 | Every index in `07`, one guard each; `(RunId)` on all fourteen run children, with §2.2's exemption recorded in the script itself |
| AC 5 | `ua_user` exists in six databases and the co-location query returns `is_local = 1`, `is_enlisted = 0` (§2.3) |
| AC 6 | `sys.procedures` and `sys.triggers` return **`sp_GetGaugeTrace`** and **`trg_CoilTraceability_NoOverlap`**. ⚠ **Count after a real teardown** — an incremental count silently includes `sp_IngestRodFromCoils` |
| AC 7 | `sp_ShiftSummary` **absent** after the MVP-1 chain alone; the guard fails the build if it appears |
| **The paths resolve** | Every `cd` in the runner's banner and in `[DEP §4.2]` step 2.1 names a directory that exists |
| **No count here** | This record states no figure. `grep` this file for a baseline number and find none |

### 5.1 Measured on `DEV00164-001`, 30 Aug 2026

**Executed, not asserted.** The gate was run live and the runner re-run against the deployed database.

| Check | Result |
|---|---|
| **Step 0 — co-location** | ✅ All six databases on one instance: `FlatWireDB` · `united_db` · `proddb` · `CommonDB` · `SlitterDB` · `wiplogdb` |
| ⭐ **The no-MSDTC premise** | ✅ **Re-proven.** One transaction spanning `FlatWireDB` and `proddb` reports **one** session transaction, `is_local = 1`, `is_enlisted = 0` — `[INT §8.0]` / `[ARC §10]` hold on this instance |
| **`V1` / `V2` / `V3`** | ✅ All three match `[DBD §6.2]`'s baseline exactly |
| **`V4`** | ✅ **7/7** — the two from the runner plus the five from `scripts/` |
| **`V5` / `V6`** | ✅ Zero rows each |
| **AC 7, live** | ✅ `sp_ShiftSummary` **absent** from the instance |
| **`Q60`, live** | ✅ `SpoolProcessing` present with its `Alpha`; `SpoolConfiguration`, `SpoolCarrier` and `Spool.Alpha` all **gone**. ⭐ **This instance is post-`Q60` and clean** — §2.1's teardown-first path did **not** apply |
| **AC 4, live** | ✅ Fourteen run children carry a leading-key index on `RunId` / `SourceRunId`. `PassScheduleChangeLog` is the one without, exactly as §2.2 sets out |
| **AC 5, live** | ✅ `ua_user` present in all six databases |
| ⭐ **AC 3 — idempotency** | ✅ **`FlatWire_DDL_RunAll.sql` re-run: exit 0, no errors.** All 33 tables reported *"already exists"*, FKs and indexes no-op'd, and only the two programmability objects were dropped and recreated — which is `08`'s design. **The gate was identical afterwards and no row moved** |

> ⭐ **The `251` seed figure is verified — and `[DBD §6.2]` says nothing had ever verified it.**
> The instance holds **423** rows across all 33 tables with **zero empty**. The difference is one
> table: `RunReading` carries 15 seeded rows dated 20–21 Jul and **172 written in a single burst on
> 28 Aug** by the plant-data feed simulator. **423 − 172 = 251, exactly.** ⚠ **Do not read the live
> total as seed drift** — the seed is intact and every other table is untouched. `[DBD §6.2]`'s
> *"still unverified by anything"* can be closed on this evidence (§7).

---

## 6. Handoff

This story is **wave 0 — the single root**. `FW-005`, `FW-004`, `FW-006` and `FW-007` build on it,
and `FW-007` is the parent of eight downstream DB stories.

⚠ **Four of those five Phase 1C cards still read `not-started` while `Orchestration.md` §1.1 marks
them ✅ Built** — the same contradiction this record fixes for `FW-152`, on the same evidence. They
are `status_confirmed: true` by stub default, not by anyone's confirmation. Fixing them is a
delivery call and is deliberately not taken here.

[`FW-241`](FW-241.md) owns deploy step 2 and is waiting on **an approval, not on code**.
[`FW-248`](FW-248.md) owns the count guard's `C6` blind spot and the `[DBD]` repairs; sequence it
first in `S1`, before anything that moves the baseline. [`FW-242`](FW-242.md) moves this DDL into
`ual-database`, where it does not yet exist at all.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`[DBD §6.2]`** | The **only** site that defines the counted baseline. This record states none, and AC 6 already says so. ⭐ **Its seed-row figure is no longer unverified** — §5.1 confirms it live, with zero empty tables across all 33. The sentence saying it *"is not covered by any tool"* and *"still unverified by anything"* can be closed; ⚠ **the figure itself does not change**, so this is a wording repair for `FW-248`'s `[DBD]` pass, not a baseline move |
| **`[DBD §6.8]`** | Owns the index coverage list — and therefore settles §2.2. ⚠ **Its list still names `Spool(SourceRunId)`, `(ParentRodAlpha)`, `(SourceRodAlpha)`** — pre-`Q60` names for `SpoolProcessing`, while the DDL has `IX_SpoolProcessing_SourceRunId`. Fold into `FW-248`'s `[DBD]` pass |
| **`G65`** | Open. The welded-coil design of record carries a **`CoilTraceability` → `FlatWire_CoilTraceability` rename** across eight unbuilt waves. It moves no count, but it invalidates the trigger name AC 6 pins and `UX_CoilTraceability_ChildAlpha` |
| **`Q89`** | Added `UX_CoilTraceability_ChildAlpha` on 26 Aug 2026 — the last change to move this chain's index baseline |
| **`OI-110`** | MVP-1 **reads** pass schedules and never authors one. Load-bearing for §2.2 |
| ⚠ **Step 2 has never run** | So FL1/FL2/FL3 are in neither `united_db..machines` nor `CommonDB..WIPStations`. Not this story's, but it is what a reader expecting a complete deployment will notice first |
