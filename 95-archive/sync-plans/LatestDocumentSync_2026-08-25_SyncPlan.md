# `LatestDocument/` → `MVP-1/ProjectPlan/` — Sync Audit and Propagation Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — **executed**; status restamped and the eight out-of-audit findings recorded
**Status:** ✅ **EXECUTED 25 Aug 2026 — all waves W1–W10, plus eight findings this audit did not have.**

> ⚠ **This header said *“Audit complete, propagation not executed. No wave below has been applied”*
> until the work was done — which is exactly the defect it recorded as **C3** against
> [`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md). Restamped so this ledger does not
> repeat it.

**What was applied.** 43 files. `W1`–`W4` (the count chain, `[DBD §6.2]` first), `W5` (the
`SharedCoilNo` rename — 17 live references, including two test cases and three acceptance criteria),
`W6`–`W10` (the ledger restamp, the register mints, the wiring, the generator, the changelog).

**Eight findings this audit did not contain, in descending order of consequence:**

| | Finding |
|---|---|
| **1** | ⚠ **The repository’s own coverage gate was FAILING.** `build_coverage_matrix.py` exited **FATAL** on **22 requirements, 21 of them `Must`**, with no test case and no `§10.4` entry. **33 cases written** (`TC-751`–`TC-783`); coverage **79.5 % → 86.9 %**. This **corrects this audit’s own ✅ on rod ↔ order** — the tables and requirements were there; the tests were not |
| **2** | ⚠ **The DEPLOYED database is two schema changes behind the scripts** — measured on the shared instance: **34 tables · 57 FKs**, still holding `SpoolCarrier` and `SpoolConfiguration`, **no `SpoolProcessing`**, and **3 rows**. A teardown and rebuild is owed before any build work reads it |
| **3** | **The 20 Aug FL2 pre-check-in reversal had never reached the requirement text.** `FR-031` read as a refusal in **both** documents five days on. Now superseded in place, with **`FR-533`–`FR-540`** in `[REQ] §5.29`, all `[PROPOSED]` pending **`Q41`** |
| **4** | **The live effort figure `3,358 h` existed in one line of one file** while nine documents circulated `3,186` or `3,292` — and `[CE]`’s own header said a third number |
| **5** | **`[PLC]` (227 citations), `[PSG]` and `[MS]` were declared nowhere**, and **~1,900 screen-rule citations named a `…_v3.docx` deleted on 1 Aug** |
| **6** | **`ProjectPlanPrompt.md` would have rebuilt a conflicting seven-document set** — marked superseded |
| **7** | **`../../DOCUMENTS.md`, *the map*, listed neither `Spool.md` nor `PartialRodReCheckin.md`**, which by its own citation rule made them invisible; five of its self-counts were wrong, two contradicting each other two lines apart |
| **8** | **The 6 Aug ledger’s blocker citation was wrong** — *“`Q32`, renumbered `Q65`”* names two different questions after the renumbering passes, one open and one decided in May. Read as written, the blocker looked closed |

**Four of this audit’s own findings were FALSE ALARMS on verification**, recorded so nobody re-audits:
the **teardown** needs no table names (`DROP DATABASE`); **`D-21`** is a properly struck row, missed by a
strikethrough-blind regex; the **leakage guard** covers tag paths and the field carrying `FL2.FM2` is
*“never written to the workbook”*; and **`FW-224`** was not falsely claimed as minted — that citation is a
wave instruction in a ledger that says the wave is not done.

**Still owed, none of it closable here:** the shared-instance rebuild (`99_Teardown` drops the database —
the environment owner’s decision, and the only way to settle the unverified **251** seed-row figure); the
FL2 endpoint, screen control and `FL2PO`, with **`FW-224`** reserved and unsized on **`Q41`**; and the 6 Aug
artifact waves, blocked on **`Q32`** and **`Q49`**.
**Document Type:** Propagation ledger — the same shape as the `ClientCall_*_SyncPlan.md` ledgers in `BaseDocuments/` and [`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md)
**Audits:** [`../../10-requirements/MasterSpecification.md`](../../10-requirements/MasterSpecification.md) · [`RodOrderAllocation.md`](RodOrderAllocation.md) · [`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md) · [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) against `MVP-1/ProjectPlan/`
**Verification tool:** [`../../tools/deliverables/verify_schema_counts.py`](../../tools/deliverables/verify_schema_counts.py)

---

## 0. The headline

**`MVP-1/ProjectPlan/` is substantially in sync. The gap is not missing content — it is stale
*numbers* and stale *column names* left behind by the 23 Aug `SpoolConfiguration` merge (`Q60`) and
the 22 Aug `SharedCoilNo` rename, plus three unregistered findings from a document that arrived on
24 Aug and is referenced from nowhere.**

Four things were checked and are **correctly in sync** — recorded here so nobody re-audits them:

| Axis | State |
|---|---|
| **Rod ↔ order allocation** (`RodOrderAllocation.md`) | ✅ **Fully propagated.** Both tables built in `03_Materials` / `04_Runs`, in the runner, seeded, documented in all six `FlatWireSchema_*.md`, `FR-541`–`FR-560` / `ORD003`–`ORD017` live in `[REQ]` §5.28, ids `Q48`–`Q58` / `OI-123`–`OI-125` / `G47` / `G48` minted |
| **`OI-##` register** | ✅ Master spec and `MVP-1/` both run to **`OI-126`**. No orphan citations |
| **`FR-###` register** | ✅ The 64 FRs in the master spec but absent from `[REQ]` are **all** MVP-2 screens — `FR-241`–`254` (`DMG`), `FR-361`–`375` (`PSM`), `FR-380`–`390` (generation), `FR-401`–`409` (`PSL`), `FR-481`–`489` (`SHS`), `FR-501`–`507` (`OEE`). Deliberate exclusion, **not a gap** |
| **`Q60` `Spool`/`SpoolCarrier` swap** | ✅ Propagated through the DDL, all six schema docs and `[DBD §6.2a]`. No live `SpoolCarrier` reference survives outside the announcement header and the `Analysis/` audit trail |

`verify_schema_counts.py` passes: **33 tables · 55 FKs · 69 index statements · 1 procedure ·
1 trigger**, 33/33 documented, 33/33 seeded, 0 orphan scripts. **That is the true baseline** and it
is what every finding below is measured against.

---

## 1. What is actually out of sync

Six changes, in descending order of blast radius. **Counts are measured, not estimated** — each is a
`grep -rn` over `LatestDocument/` and `MVP-1/`.

| | Change | Files | Severity |
|---|---|---|---|
| **C1** | **`34 tables · 57 FKs` → `33 · 55`** as a *live* figure, and **`212` → `251` seed rows**. Includes a **self-contradiction inside the defining site** and **two deployment/AC gates that would reject a correct build** | **12** | ⚠ **Critical** |
| **C2** | **`SharedCoilNo` → `CoilNo`** and **`@expectedSharedCoilNo` → `@expectedCoilNo`** — the 22 Aug rename never finished. Two **test cases** and three **acceptance criteria** name objects that do not exist | **7** | ⚠ **Critical** |
| **C3** | **`RodOrderAllocation_SyncPlan.md` header says "Planned, not executed"** while the work it plans is fully applied and its own subject document says "APPLIED" | 1 | High |
| **C4** | **Three findings from `RodOrderAllocation_WorkedExamples.md` are unregistered** — recorded only in `CHANGELOG.md` as "none of them minting a new id". One is a **validator defect against a live `CHECK` constraint** | 4 | High |
| **C5** | **`RodOrderAllocation_WorkedExamples.md` / `.html` are invisible to `MVP-1/`** — no screen spec, phase, test or `CLAUDE.md` row references either | 3 | Medium |
| **C6** | **`build_allocation_examples_xlsx.py` and `AllocationExamplesContent.md` do not exist**, yet `../../Tools/README.md` documents both and their output `../../deliverables/FlatWire_OrderAllocationExamples.xlsx` is a shipped client deliverable | 2 | Medium |

---

## 2. The two that are not documentation tidying

**C1 and C2 both have a version that fails a correct build.** They are first for that reason, not
for file count.

### C1 — the defining site contradicts itself

`[DBD §6.2]` is the **one site that may assert the object baseline** (memory: only three sites may,
and this one wins). It now says both things:

- [`DatabaseDesign.md:24`](../../30-database/DatabaseDesign.md#L24) — *"The baseline moved on 23 Aug 2026: it is now **33 tables · 55 FKs** … and **251** seed rows"*, followed by *"Anything still saying 34 tables or 57 FKs as a live figure is stale."*
- [`DatabaseDesign.md:34`](../../30-database/DatabaseDesign.md#L34) — *"**Proven**, on a real teardown-and-rebuild: `99_Teardown` → `RunAll` produced **34 tables · 57 FKs** … **matching this section**"*, and *"loaded **212** rows"*.

The **evidence paragraph for the current baseline carries the pre-merge numbers and claims they
match.** `verify_schema_counts.py` does not catch it because it parses the assertion at line 24, not
the prose at line 34. **Fix line 34 first** — every other C1 edit is a copy of whatever this site
says, and this is exactly the re-copy hazard `G12` records.

⚠ **Two of the twelve are gates, and a wrong gate rejects a correct deployment** — the failure mode
`[DEP §4.2]` has already suffered four times:

| Site | Says | Effect |
|---|---|---|
| [`FlatWire_MasterSpecification.md:2052`](../../10-requirements/MasterSpecification.md#L2052) | Post-deployment verification: *"**34 tables** present"* | Rejects a correct 33-table deploy |
| [`FW-223.md:103`](../../40-backend/tasks/FW-223.md#L103) | AC: *"`RunAll` produces **34 tables** and zero rows"* | Fails a correct story |

**The rest of C1, classified.** Update the **live** ones; the **dated audit trail keeps its numbers
by design** and must not be swept.

*Update (live figures):*

| File | Line | Current |
|---|---|---|
| `../../10-requirements/MasterSpecification.md` | 4 | Header — *"Object counts unchanged: 34 · 57 · 69"* (true on 23 Aug **before** the merge; now stale) |
| `../../10-requirements/MasterSpecification.md` | 58 | §1 scope table — *"(**34 tables**)"* |
| `../../10-requirements/MasterSpecification.md` | 88 | §1 status — *"34 tables, 57 FK constraints, 69 indexes"* |
| `../../10-requirements/MasterSpecification.md` | 2052 | ⚠ **gate** (above) |
| `../../10-requirements/MasterSpecification.md` | 2906 | Phase-1 table — *"`FlatWireDB` created with **34 tables**"* |
| `DatabaseDesign.md` | 34 | ⚠ **defining site** (above) — also `212` → `251` |
| `BusinessRequirements.md` | 94 | Mermaid node `FlatWireDB<br/>34 tables` |
| `VisionAndScope.md` | 154, 277 | Scope table and `D-03`/`D-04` row |
| `CapacityAndEffortModel.md` | 418 | *"deployed and verified on the shared instance — 34 tables · 57 FKs"* |
| `phase-01c-database-foundation.md` | 10, 35 | Header trail and the applied-changes callout |
| `FW-142.md` | 169, 186, 206 | *"map all **34** tables"*, *"Read AC 2 as **34** tables"*, object-baseline row |
| `FW-143.md` | 18, 124 | *"None of the **34** tables … is an audit log"* |
| `FW-223.md` | 103 | ⚠ **gate** (above) |
| `Orchestration.md` | 234 | `P-13` row — *"Map **34** tables"* |
| `SQL/README.md` | 60 | *"47 of the **57** FKs"* split-count |

⚠ **Two files are worse than stale — they say `28`**, a figure retired on 22 Aug:
[`phase-01b:47`](../../60-delivery/phases/phase-01b-backend-foundation.md#L47) and
[`FW-142:71`](../../40-backend/tasks/FW-142.md#L71),
both phrased *"there is one number now, and it is **28**"*. `FW-142` then says `34` at line 169 —
**one file, two wrong numbers.**

*Leave alone (dated audit trail):* `GapsRegister.md:35` (`G12`, resolved 11 Aug) ·
`DatabaseDesign.md:30` (*"The previous baseline, for reference"*) · `Architecture.md:250` and master
spec `D-03`/`3114` (both already carry the *"34 until the 23 Aug merge"* form, which is correct) ·
master spec `OI-118`/`OI-120` clauses — **but** re-read these two: *"it is now 34"* reads as live and
should become *"was 34, now 33"*.

*Already correct — do not touch:* `Architecture.md:45,79` · `Deployment.md:186` ·
`MVP2-SCOPE.md:43,56` · all six `FlatWireSchema_*.md` headers · every SQL script header.

### C2 — the `SharedCoilNo` rename left live references behind

The column **is** `CoilNo` in [`FlatWire_DDL_05_QualityOutput.sql:167`](../../30-database/sql/FlatWire_DDL_05_QualityOutput.sql#L167)
and the procedure parameter **is** `@expectedCoilNo` in
[`50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql:328`](../MVP-1/ProjectPlan/Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql#L328).
Seven files still name the old forms as **live** objects:

| File | Line | Problem |
|---|---|---|
| `../../70-testing/TestCases.md` | 463 (`TC-717`) | Test step asserts `CoilOutput.SharedCoilNo` — **column does not exist** |
| `../../70-testing/TestCases.md` | 471 (`TC-725`) | Retry test captures `SharedCoilNo` — same |
| `../../60-delivery/TaskBreakdown.md` | 682, 689 | Two ACs: *"persisted on **`CoilOutput.SharedCoilNo`**"* |
| `FW-219.md` | 38, 48, 73, 75, 85 | Design text plus AC *"Retry with **`@expectedSharedCoilNo`**"* — **parameter does not exist** |
| `../../20-architecture/Integration.md` | 223 | *"The retry contract is `CoilOutput.SharedCoilNo`"* — live prose |
| `../../40-backend/APIs.md` | 1190 | Mixed in one sentence: correct `CoilOutput.CoilNo`, then `@expectedSharedCoilNo` |
| `../../60-delivery/TrialRunPlan.md` | 753 | Scope row *"`CoilOutput.SharedCoilNo` / `SharedSkidNo`"* |

⚠ **Check `SharedSkidNo` in the same pass.** It appears beside `SharedCoilNo` in `FW-219` and
`TrialRunPlan` and was **not** part of the `Q58` rename — confirm against
`FlatWire_DDL_05_QualityOutput.sql` before touching it, and do not rename it by association.

*Leave alone (rename records):* `DatabaseDesign.md:323` · `phase-09:130` (*"**`CoilOutput.SharedCoilNo`** is renamed `CoilNo` (`Q58`)"*) · `FlatWireSchema_QualityOutput.md:116` (already `CoilNo`).

---

## 3. The four that are bookkeeping

### C3 — a ledger that denies its own execution

[`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md) header: *"**Planned, not
executed.** No wave below has been applied."* All six waves **are** applied — verified above, and
`RodOrderAllocation.md` itself now reads *"Design analysis — **APPLIED**"*. `CLAUDE.md` also records
the propagation as complete. **Two documents in one folder disagree about whether the same work
happened.** Restamp the ledger and mark each wave.

### C4 — three findings with no register home

`CHANGELOG.md:530` records them explicitly as *"none of them minting a new id"*. Two are cosmetic;
**one is a live defect.**

| # | Finding | Verified | Disposition |
|---|---|---|---|
| **(1)** | `RodOrderAllocation.md` §2.8 numbers `CoilAlpha` **per spool** (`FW-00001-C01`, `FW-00003-C01`) where `[REQ]`'s alpha table and the master spec both make **`FW-#####` the order** and `C##` the sequence within it. On a 40,000 lb run: one `C01`…`C45` across 23 spools, **not** 23 separate `C01`s | Contradiction is real; `WorkedExamples` §2.1 already uses the authoritative form | Correct §2.8 **in place**, or badge it as superseded by `WorkedExamples` §2.1. No new id |
| **(2)** | ⚠ **`PinRole='Sole'` is in the `CHECK` list but in none of §3's four tiers.** `partition(order.rods)` covers `PinnedFirst`, `Free`, `Free`+`Partial`, `PinnedLast` — a `Sole` row **matches nothing** and `minTier` is undefined over it | ✅ Confirmed against [`FlatWire_DDL_03_Materials.sql:428`](../../30-database/sql/FlatWire_DDL_03_Materials.sql#L428): `CHECK ([PinRole] IN ('Sole','PinnedFirst','Free','PinnedLast','PinnedBoth'))` | **Mint a `G##`.** The validator must special-case `Sole`. Harmless only while a `Sole` order has exactly one rod — which nothing enforces. Needs a test case beside `FR-541`–`FR-560` |
| **(3)** | Recorded weld footage and the material boundary are **captured at different moments** — the encoder is read when the operator joins at the payoff, but the join passes the counter later. The traces bound segments at the **material** boundary; nothing states whether the two coincide | Same class as `OI-25` | **Mint an `OI-##`** in master spec §11, or fold into `OI-25` |

### C5 — a 24 Aug document nothing points to

`RodOrderAllocation_WorkedExamples.md` (seven traces) and its client-facing `.html` are referenced
**only** from `RodOrderAllocation.md`'s header and `CHANGELOG.md`. Not from `CLAUDE.md`'s
`LatestDocument/` row (which still says **four** files — the folder holds **seven**), not from
`SpoolCompletionNotification.md` / `OutputCoilCompletion.md` / `WeldEvent.md` / `RocCheckin.md`
(the four screen specs it was assembled *from* and whose gaps it exposes), and not from
`phase-09`. Its `§9` demonstration — a good 1,800 lb spool forced into **two sub-minimum coils**
because `CoilOutput.OrderId` is a scalar `NOT NULL` — is `G48` made concrete and belongs cited on
`G48`.

### C6 — a shipped deliverable with no source

`../../Tools/README.md` (lines 4, 23, 40, 54) documents `build_allocation_examples_xlsx.py` and
`AllocationExamplesContent.md`, including its guard set (*"**arithmetic** · coverage · drift · team
names · leakage"* — the first generator whose figures are **computed rather than parsed**).
**Neither file is on disk or in git.** Only `__pycache__/build_allocation_examples_xlsx.cpython-314.pyc`
and the output `../../deliverables/FlatWire_OrderAllocationExamples.xlsx` survive.

The client workbook therefore **cannot be regenerated**, which breaks the repo's own rule
(*"edit whichever source owns the field and re-run; never edit the `.xlsx`"*). This is the same
failure as the uncommitted SRS round-trip scripts `CLAUDE.md` already warns about — **recurrence,
not a one-off.**

---

## 4. The waves

Ordered so that no wave copies a figure a later wave changes. **W1 must land first** — it is the
site every other count is copied from.

| Wave | Scope | Depends on | Files |
|---|---|---|---|
| **W1** | **Repair the defining site.** `[DBD §6.2]` line 34: `34 · 57` → `33 · 55`, `212` → `251` seed rows. Re-run `verify_schema_counts.py` | — | 1 |
| **W2** | **The two gates.** Master spec §2052 post-deployment verification; `FW-223` AC line 103 | W1 | 2 |
| **W3** | **Master spec live figures** — lines 4, 58, 88, 2906; reword the `OI-118`/`OI-120` *"it is now 34"* clauses to *"was 34, now 33"* | W1 | 1 |
| **W4** | **Remaining `MVP-1/` live figures** — `BusinessRequirements` 94 · `VisionAndScope` 154, 277 · `CapacityAndEffortModel` 418 · `phase-01c` 10, 35 · `FW-142` 169, 186, 206 · `FW-143` 18, 124 · `Orchestration` 234 · `SQL/README` 60. **Plus the two `28`s**: `phase-01b:47`, `FW-142:71` | W1 | 10 |
| **W5** | **Finish the `SharedCoilNo` rename** — the seven files in §2. Verify `SharedSkidNo` against the DDL **before** editing; do not rename by association | — (independent of W1–W4) | 7 |
| **W6** | **Restamp `RodOrderAllocation_SyncPlan.md`** — status → applied, per-wave marks | — | 1 |
| **W7** | **Register the three `WorkedExamples` findings** — mint a `G##` for `PinRole='Sole'` (+ a `TC-` beside `FR-541`–`560`), an `OI-##` for the weld-footage/material-boundary offset (or fold into `OI-25`), and correct or badge `RodOrderAllocation.md` §2.8's per-spool `CoilAlpha` | — | 4 |
| **W8** | **Wire `WorkedExamples` in** — cite it on `G48`, from `phase-09`, and from the four screen specs it was assembled from; correct `CLAUDE.md`'s `LatestDocument/` row from **four files to seven** | W7 | 6 |
| **W9** | **Restore the allocation-examples generator** — recover `build_allocation_examples_xlsx.py` + `AllocationExamplesContent.md`, or strike them from `../../Tools/README.md` and mark the `.xlsx` hand-built. **Decide, do not leave the README describing files that do not exist** | — | 2 |
| **W10** | **Append to `CHANGELOG.md`** under each owning document; cross-document notes under `## Repository-wide`. Bump `Last Updated` on every file touched | W1–W9 | 1 |

**W1 → W2 → W3 → W4** is the only hard chain. **W5, W6, W7 and W9 are independent** and can run in
any order or in parallel.

---

## 5. Verification

| | Check | Passes when |
|---|---|---|
| **V1** | `python MVP-1/ProjectPlan/Tools/verify_schema_counts.py` | Still `OK`, and `[DBD §6.2]` no longer self-contradicts |
| **V2** | `grep -rn "34 tables\|57 FK" --include=*.md LatestDocument/ MVP-1/` | Every survivor is a **dated** audit-trail statement or carries the *"34 until the 23 Aug merge"* form |
| **V3** | `grep -rn "SharedCoilNo\|expectedSharedCoilNo" --include=*.md MVP-1/` | Every survivor is a **rename record**, never a live object reference |
| **V4** | `grep -rn "28 tables" --include=*.md MVP-1/` | `phase-01b:47` and `FW-142:71` are gone |
| **V5** | Teardown → `FlatWire_DDL_RunAll.sql` → `FlatWire_SampleData_RunAll.sql` **on the shared instance** | 33 tables · 55 FKs · 69 index statements · 1 procedure · 1 trigger · 251 rows, 0 empty tables, idempotent on re-run. ⚠ **Not LocalDB** — the 23 Aug figure was LocalDB-verified and `[DBD §6.2]` flags what that does not prove |
| **V6** | `python MVP-1/ProjectPlan/Tools/build_allocation_examples_xlsx.py` | Runs — or W9 chose the strike-it option and `../../Tools/README.md` no longer lists it |

---

## 6. What this plan does not do

- **It does not touch `MVP-2/`.** Out of scope by [`../design-notes/MVP-2-scope-note.md`](../design-notes/MVP-2-scope-note.md).
- **It does not sweep the dated audit trail.** Per the counts convention, most of the ~40 files
  quoting object counts are history and keep their numbers. Only the sites listed in §2 are live.
- **It does not renumber any register.** `Q##`, `OI-##`, `G##`, `FR-###` and `FW-###` are all
  stable; W7 **mints at the tail**, it does not reassign.
- **It does not resolve `Q42`** (spool-number format, 30-vs-45) or **`OI-97`/`OQ-J`** (the 4,000 lb
  rod, one of three figures in circulation — every `WorkedExamples` count scales with it). Both are
  client-owned and stay open.
- **It does not re-derive any effort figure.** No wave changes hours, so
  `CapacityAndEffortModel.md` line 418 is a **count** edit only — not a re-baseline.
