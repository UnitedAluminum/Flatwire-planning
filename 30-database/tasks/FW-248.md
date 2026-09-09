---
id: FW-248
legacy_id:
title: Harden verify_schema_counts.py's C6, and repair the two count sites it cannot see
status: blocked
status_confirmed: false
status_note: "**Ready to build.** ⛔ **And the guard is RED today for an unrelated reason — see §1.2**"
owner:
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB]
priority: high
hours: 8
sprint: S1
depends_on: [FW-152]
blocked_by: []
has_plan: true
started:
completed:
---
# FW-248 · Harden `verify_schema_counts.py`'s `C6`, and repair the two count sites it cannot see

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** **Ready to build.** ⛔ **And the guard is RED today for an unrelated reason — see §1.2**
**Owner:** Database (SQL Server) stream
**Audience:** The developer building `FW-248`
**Shortcode:** — *(implementation plan, derived from the tool and the documents; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Database/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Eight hours, and **four details decide whether it is right.**
>
> **Both contradictions are confirmed by running the tool, not by reading about them.**
> `C1` measures **70** index statements; `[DBD §6.2]`'s own file says **69** in one paragraph
> and **70** in two others, and `ProjectPlan/README.md` says **69** from a site not permitted
> to say anything. `C6` reported **`0` disagreeing, `0` advisory** across both.
> **⛔ The guard does not pass today.** `C2` fails on `FlatWire_DDL_02_Schedule.sql`. That is
> **not** this story's subject and **is** this story's baseline — a new gap, `G63` (§1.2).
> **This story must state no count.** Neither in the plan, nor in the fixture, nor in the
> fixture's documentation. `[DBD §6.2]` defines the baseline; everything else cites it.
> **The `README.md` restatement is deleted, not corrected.** Correcting it to `70` would
> leave a non-permitted site holding a number that goes stale again in a week.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-248 · Harden `verify_schema_counts.py`'s `C6`, and repair the two count sites it cannot see
> **Hours:** 8 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** 1C · **Stream:** DB
>
> > ⛔ **The schema-count guard has a blind spot, and it is the exact class of drift the guard exists
> > to stop.** `[DBD §6.2]` — **the document that defines the baseline** — contradicts itself: it
> > states the current index figure after `Q89` added `UX_CoilTraceability_ChildAlpha` on 26 Aug 2026,
> > while an earlier paragraph **in the same file** still carries the previous one. And
> > `ProjectPlan/README.md` restates the baseline at all, which it **is not one of the three permitted
> > sites** to do, and restates it stale.
> >
> > ⛔ **`C6` reported zero disagreeing claims in permitted sites and zero advisory elsewhere on the
> > same run.** That matters because `C6` exists precisely so *"the number in the document cannot
> > drift away from the scripts again"* — and `[DEP §4.2]`'s gate has already rejected a correct
> > deployment **five times** on exactly this.
>
> **Acceptance Criteria:**
> - [ ] `C6` scans **every** count-shaped claim in `[DBD §6.2]`'s own file, not only the defining sentence — the self-contradiction is caught
> - [ ] `C6` flags a restatement in **any non-permitted site** as advisory, `ProjectPlan/README.md` included; the three permitted sites stay permitted
> - [ ] Both live contradictions repaired: `[DBD §6.2]`'s stale paragraph, and `README.md`'s restatement **removed rather than corrected** — it is not permitted to carry one
> - [ ] A regression fixture: a file with a deliberately stale count is detected by `C6`
> - [ ] ⚠ **This story states no count itself**, and neither does its test fixture's documentation. `[DBD §6.2]` is the only site that defines the baseline
> - [ ] All six checks green on a clean run afterwards
>
> **Rate-card basis (§2):** not a rate-card unit — a tooling change with a regression fixture plus two document repairs, priced at one script-class deliverable = **8 h**
> **Dependencies:** FW-152
> **Blockers:** —

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| The counted baseline itself | **`[DBD §6.2]`** — the only site that defines it |
| Re-deriving the DB-stream hours total | `FW-249` — a different kind of number entirely |
| `build_development_plan_xlsx.py`'s multi-stream bug | [`FW-250`](FW-250.md) — a sibling tooling defect, same `S1` |
| Any schema change | `FW-244`, `FW-245`, `FW-246` — **this story changes no DDL** |
| `[DEP §4.2]`'s numeric gate | A permitted restatement; stays permitted |

### 1.2 What already exists

Measured by **running the tool on 29 Aug 2026**, not read off a document.

| Thing | State |
|---|---|
| [`verify_schema_counts.py`](../../tools/deliverables/verify_schema_counts.py) | ✅ Built — six checks `C1`–`C6` |
| `C6`'s machinery | ✅ Substantial: `C6_FATAL` permitted-site tuple (`:288`), `C6_SKIP_DIRS`/`_FILES`/`_SUFFIXES`, a dated-history heuristic (`RE_C6_DATED`, `C6_HISTORY`), `C6_CONTEXT`, `C6_MIN_WHOLE`, five claim regexes (`RE_C6_TABLES`/`_FKS`/`_IDX`/`_PROCS`/`_TRIGS`), `C6_NEAR` proximity window |
| **`C1`'s measurement** | **70 index statements** — the live figure |
| **`C6`'s verdict** | ⛔ **`0` disagreeing in permitted sites, `0` advisory elsewhere** — while both contradictions below are present |
| **Contradiction 1** | `../DatabaseDesign.md` **`:34`** — *"the current scripts measure … **69** index statements"*, against **`:24`** and **`:327`** which both say **70**. ⛔ **Same file, three claims, two values** |
| **Contradiction 2** | `ProjectPlan/README.md` **`:81`** — restates the full baseline at **69**, from a **non-permitted** site. (`:177` also restates the table count) |
| ⛔ **A live `C2` failure** | **`../sql/FlatWire_DDL_02_Schedule.sql` creates tables but has no `"Tables :"` header block** — the run **FAILS** today. See below |

> ⛔ **`G63` — the guard is red, and neither Orchestration says so.**
> `FlatWire_DDL_02_Schedule.sql` was reissued **27 Aug 2026** on the *"ISSUED FOR CLIENT
> REVIEW"* template (v1.1), which names its header key **`Creates :`**. Every other DDL file
> uses **`Tables :`**, which is what `C2` parses. So the reissue silently broke the check the
> same day the DB Orchestration recorded *"run today passes all six checks."*
>
> ⚠ **This is not `FW-248`'s subject** — it is `C2`, not `C6` — **but it is `FW-248`'s
> baseline**, because AC 6 says *"all six checks green on a clean run afterwards"* and that
> cannot be true until this is fixed. **Fix it here** (§3 step 1): it is a one-line header
> repair in the DDL, and this is the story that owns the tool. Raised as **`G63`**.

---

## 2. The four details

### 2.1 Why `C6` misses a self-contradiction

`C6` is built to compare a *document's* claim against `C1`'s *measurement*. Its permitted-site
list (`C6_FATAL`) makes disagreement fatal in the four sites allowed to restate, and advisory
elsewhere. What it does not do is compare a file's claims **against each other**.

`[DBD §6.2]` is the defining site, so `C6` finds a claim there, matches it to `C1`, and passes.
The **other two** claims in the same file are either not reached, or are absorbed by the
`C6_HISTORY` / `RE_C6_DATED` heuristics that exist to let audit-trail sentences keep their old
numbers by design.

⚠ **That heuristic is correct and must not be weakened.** The file is full of deliberately
stale figures — *"previously 34 · 57 · 69"*, *"20 → 21 → 22 → 24 → 27"* — and every one of them
is audit trail. The line at `:34` is different: it says **"the current scripts measure"**.
It is a present-tense claim, not history, and the fix is to notice the difference rather than
to stop trusting the heuristic.

### 2.2 The defining site needs a stricter rule than everywhere else

Elsewhere, a stale number is a citation that drifted. **Inside `[DBD §6.2]`'s own file it is the
definition disagreeing with itself**, which is worse: every other document in the repository is
correct to cite this file, so a reader who follows the rule lands on a contradiction.

**So `C6` gains a rule that applies to the defining file alone:** every present-tense
count-shaped claim in `DatabaseDesign.md` must agree with `C1`, and disagreement is **fatal**,
not advisory — with the existing history heuristics still exempting the past-tense ones.

### 2.3 `README.md`'s restatement is deleted, not corrected

AC 3 is explicit — *"**removed rather than corrected** — it is not permitted to carry one"* —
and the reason is structural. `ProjectPlan/README.md:81` currently ends with *"Defined once in
`[DBD §6.2]` — every other mention is a citation."* **The sentence states the rule it is
breaking.**

Correcting `69` → `70` would leave a fifth site holding a number that goes stale at the next
`Q##`. **Replace the figures with the citation.**

⚠ **`:177` restates the table count too** (*"the same **33 tables**"*) and AC 3 names only one
site. Both are the same defect; **fix both**, and note that the count there is load-bearing to a
sentence about `D-31` — so it is reworded, not merely cut.

### 2.4 The fixture must not carry a real count

AC 5 forbids this story from stating a count "and neither does its test fixture's
documentation." The trap is obvious once named: a regression fixture containing a **deliberately
stale** real figure is itself a count-shaped claim in the repository, and `C6` — once hardened —
will find it.

**Two ways out, and one is right:**
- ⛔ Add the fixture to `C6_SKIP_FILES`. Works, and blinds the guard to the one file guaranteed to
  contain a wrong number.
- ✅ **Make the fixture's numbers impossible** — well below `C6_MIN_WHOLE`, or in a temporary file
  the test writes and deletes. The check is exercised; nothing lasting claims a count.

Take the second, as a **temporary file created by the test run**.

---

## 3. Build order

1. ⛔ **Green the baseline first (`G63`).** Give `FlatWire_DDL_02_Schedule.sql` a `Tables :`
   header line beside its `Creates :` line, or teach `C2` to accept both keys.
   ⚠ **Prefer the DDL edit** — one template drifting from eight others is the defect; teaching
   the parser both spellings blesses the drift. **Keep `Creates :`** so the client-review
   template is intact.
2. **Confirm the run is green** before touching `C6`, so anything red afterwards is this story's.
3. **`C6`, rule A** (§2.2): every present-tense count claim in the defining file agrees with
   `C1`; disagreement **fatal**. Reuse `RE_C6_DATED` / `C6_HISTORY` unchanged to exempt
   audit-trail sentences.
4. **`C6`, rule B**: a restatement in **any** non-permitted site is advisory, `README.md`
   included. The four permitted sites stay permitted.
5. **Repair contradiction 1** — `DatabaseDesign.md:34`. ⚠ Its sentence is *about* a superseded
   teardown run, so the **69 belongs to the historical clause and the present-tense clause is
   what is wrong.** Reword so the historical figure stays and the live one is a citation.
6. **Repair contradiction 2** — `README.md:81` and `:177` (§2.3): figures out, citation in.
7. **Regression fixture** (§2.4) — a temporary file written by the test run, with impossible
   numbers, asserted to be caught, then deleted.
8. **Re-run.** All six green, and `C6` now reports the advisory count it should have reported
   all along.

> ⚠ **This story changes no DDL except `02_Schedule.sql`'s header comment**, and no schema
> object. `C1`'s measurement must be **identical** before and after.

---

## 4. Decisions this plan makes

> The `P-##` series belongs to [`Backend/tasks/`](../../Backend/tasks/)
> and is continuous across the repository; `P-01`–`P-153` precede this story.

### `P-154` — the defining file gets a fatal self-consistency rule; everywhere else stays advisory

§2.2. A definition that disagrees with itself defeats every correct citation of it.

**Fallback:** advisory-only inside the defining file, with the run printing the disagreeing
line numbers. Weaker — `C6` already prints advisories and this one went unnoticed.

### `P-155` — `G63` is fixed in the DDL, not in the parser

§3 step 1. One file drifting from eight is the defect; making the parser accept both spellings
records the drift as acceptable and lets the next reissue drift further.

⚠ **Keep the client-review header intact** — add `Tables :`, do not rename `Creates :`.

### `P-156` — the fixture is temporary and its numbers are impossible

§2.4. A permanent fixture with a realistic stale count would have to be skipped, and a skip is
a blind spot — the thing this story exists to remove.

---

## 5. Verification

| Check | Expected |
|---|---|
| **Baseline green** | ⛔ Before any `C6` work: all six checks pass. **They do not today** (`G63`) |
| `C1` unchanged | The measured figures are **identical** before and after. This story changes no object |
| **Self-contradiction caught** | `C6` flags `DatabaseDesign.md`'s present-tense disagreement as **fatal** — before the repair, so the check is proven to work |
| History still exempt | *"previously 34 · 57 · 69"* and *"20 → 21 → 22 → 24 → 27"* stay silent. ⚠ **Regression risk lives here** |
| **Advisory elsewhere** | `README.md`'s restatement is flagged **before** repair; `0` advisory after |
| Permitted sites | `[DEP §4.2]`, `phase-01c` ×2 and `RunAll.sql`'s banner stay permitted and silent |
| Repairs | `DatabaseDesign.md:34` reworded; `README.md:81`/`:177` carry a **citation, not a figure** |
| Fixture | Deliberate staleness detected; the file is **gone** after the run |
| **No count here** | This plan, the fixture and its documentation state no figure. `grep` this file for a baseline number and find none |
| Final | All six green on a clean run (AC 6) |

---

## 6. Handoff

[`FW-244`](FW-244.md) and `FW-234` both **move the counted
baseline**; they update `[DBD §6.2]` and re-run this guard. **Sequence `FW-248` first in `S1`**
so those stories run against a guard that can actually see a stale restatement — otherwise each
one re-opens the same blind spot. [`FW-250`](FW-250.md) is
the sibling tooling defect and was found the same way: **by running the tool.**

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`G63`** | ➕ **Raised by this plan, 29 Aug 2026.** `C2` fails on `02_Schedule.sql`'s `Creates :` header. ⚠ **Both Orchestration files claim all six checks pass** — that claim has been stale since 27 Aug |
| **`[DBD §6.2]`** | The **only** site that defines the baseline. This story states none |
| **`[DEP §4.2]`** | Its gate has rejected a correct deployment **five times** on this class of drift |
| **`Q89`** | Added `UX_CoilTraceability_ChildAlpha` on 26 Aug 2026 — the change the stale paragraph predates |
| **`FW-249`** | Re-derives the DB-stream **hours** total. A different kind of number; do not merge the two stories |
