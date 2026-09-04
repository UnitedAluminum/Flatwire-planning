# Client e-mail — 3 September 2026 — SMP process letters for Draw and Edge, and anneal types

**Source:** `RE: New Flat Wire Machine : Impact on .Net Applications` — Sushant Sinha (Nagarro) to
Tim O'Brien, Srikanth Prabhala, Bob Scott, Shannon Riotte (UA), Ritika Raheja, Ashwani Tandon
(Nagarro); cc DG UA DEV.
**Sent:** Thu 3 Sep 2026 04:42 UTC. **Analysed:** 3 Sep 2026.
**Attachments:** 18 — all inline; **16 content screenshots + 2 signature graphics**. See §7.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §5.

---

## 1. What this closes — nothing. This one asks rather than answers

⚠ **Read this section before looking for answers in §2. There are none.** Every prior ledger in this
folder records UA answering us. **This is the reverse: three Nagarro→UA questions, outbound, with no
reply.** Two were asked on 1 Sep, re-sent on 3 Sep after two days of silence; the third was asked on
2 Sep. All three are still open as at the date of this file.

**The thread is the same one already recorded**, and its UA half is already transcribed:

| | |
|---|---|
| **Already recorded** | [`ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md`](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) — Tim O'Brien's answers on the four Machines-Application tabs |
| **Same message?** | **Yes.** Recorded there as `Mon 31 Aug 2026 19:06 UTC`; this copy quotes it as `01 September 2026 00:37`. Outlook renders a quoted `Sent:` in the **reader's** locale, and Sushant reads in IST — `19:06 UTC + 05:30 = 00:36 IST` on 1 Sep. The two are one message |
| **Was that transcription right?** | ✅ **Re-verified against this copy's images.** The per-line field sets, the `Annela Gauge` typo, FL3's stray `SPC: Takeup-1`, the `.134`/`.184` straightener discrepancy and the *Drawblock*/*Drawingblock* split all check out. **Nothing in §3.1–§3.4 of that file needs correcting** |
| **⛔ `A12`** | **Still open on the Speed tab leg.** This copy does not mention the Speed tab either. Do not mark it closed |
| ✅ **One thing it does close** | That file's §7 warning that `image018`–`image020` were missing. They were not — see §7 below |

**No new `A##` action id is minted here.** Neither `ClientEmail_*` ledger mints them — they consume
call-ledger ids. The three questions are carried in §6 and their binding homes are in §5.

**Sushant's standing to be asking:**
[`ClientCall_2026-08-24_SyncPlan.md`](ClientCall_2026-08-24_SyncPlan.md) — *"Sushant is cleared to
start coding the **SMP process** for the flat wire item."*

---

## 2. The three questions, in his words

### 2.1 A process letter and process id for `DRAW` — asked 1 Sep, re-sent 3 Sep

He established the free set by query rather than assumption:

```sql
SELECT DISTINCT
                   cpi.process_letter
FROM dbo.c_process_id AS cpi
UNION
SELECT DISTINCT
                   l.display_name
FROM dbo.lookups AS l
WHERE l.lookup_category_id = 930
```

> *"We found that currently only 4 letters are un-used **F, K, Q, U** out of which **F will be used
> for Flattening**. I intend to use **K for Draw**. Please suggest."*

> *"For SMP we need process letter **and process id** for draw."*

**`K` is Sushant's stated intent, not a decision.** Srikanth has not answered.

### 2.2 Is `EDGE` an SMP process, and does it need a letter regardless — asked 1 Sep, re-sent 3 Sep

> *"Along with this as per following screen shot there will be another process Edge. **Do we need to
> add edge as a part of SMP?** Do we need a process letter for Edge as well **regardless of if it's
> a part of SMP or not**."*

The screenshot is the **FL2 Flattening Line Schedule** — the same image transcribed as §3.1 `FL2` of
the 31 Aug ledger, showing `E1 EDGE` and `E2 EDGE` interleaved between the three FLAT stands.
**Two distinct questions in one paragraph**, and they have different homes in §5: the route-model
question and the letter question.

### 2.3 Anneal types for flat wire — asked 2 Sep

> *"Along with the below query, please suggest if there will only be **plain anneal** for flatwire or
> would there be **Back Anneal, QC Anneal, Upfront Anneal** etc."*

---

## 3. What the repository already knows, and where it disagrees

### 3.1 ⚠ `D` and `E` are not available, and one committed document assumes they are

[`tables.md`](../../Analysis/Planning%20System/tables.md) — committed 2 Sep 2026 under
`UADEV-22214`, one day before this mail — asserts a four-letter operation vocabulary:
`DRAW`→`D` · `FLATTEN`→`F` · `ANNEAL`→`A` · `EDGE`→`E`.

The query in §2.1 proves **`D` and `E` are already in use** by other processes. Only `F, K, Q, U`
are free. `FLATTEN`→`F` and `ANNEAL`→`A` hold; **the other two rows are wrong.**

**This matters beyond the table.** Those letters build the `TempOrderRemainingOperations` strings —
the `FA` / `FAF` route notation that `merging-logic.md` and `merging-logic-sample-data.json` are
worked against end to end. Recorded as gap **`G86`**; the two cells are marked pending, and the
worked examples are left alone because they are Flatten/Anneal routes and carry no `D` or `E`.

### 3.2 The letter namespace is settled by the shape of the query

The repository asserted `F` as *"the flattening operation letter"* for scheduling `OpLetter` in nine
places (`[MSP §3.2/§5.13]`, `[PF]`, `[EE]`, `[PW]`, `[ARC]` `D-32`, `[INT §8]`, `[DEP]`, `FW-003`,
`50_…_CompleteCoilOnSkid.sql`) and separately as `FLATTEN`→`F` in the SMP analysis, with **no
cross-reference between them.** Sushant's `UNION` of `c_process_id.process_letter` and `lookups`
category 930 settles it: **they are one namespace.** The same `F`, not two coincidences.

⚠ **Neither `c_process_id`, `process_letter` nor `lookup_category_id = 930` appeared anywhere in
this repository before this file** — zero matches across every file type. The registration surface
for an operation letter was never recorded, which is why `OI-27` could sit open for weeks with no
way to tell which letters were even available.

### 3.3 Back anneal already exists in the flat wire code path

*QC Anneal* and *Upfront Anneal* have **zero** matches here. *Plain anneal* is thoroughly specified
(`[MSP §2.1/§2.2/§2.3]`, `[BR]`, `OQ-78` — the alpha carries through an anneal unchanged).

**But *Back Anneal* has exactly one match, and it is load-bearing:**
[`40_FlatWireDB_Proc_FlatWire_CheckInRod.sql`](../../30-database/scripts/40_FlatWireDB_Proc_FlatWire_CheckInRod.sql) —
*"`Common_GetProgramNo`. That helper exists to handle `program_no = 171` (back anneal)."*

So **the flat wire check-in procedure already accommodates a back anneal.** That is evidence toward
the answer and should go to Srikanth **with** the question rather than after it: if back anneal is in
scope, part of the path already exists; if it is not, the helper's rationale needs restating.

Also already in the shared schema: `united_db..alloy_anneal_cycle` (`[MSP §5.12]`).

### 3.4 `OI-27` has a shortlist for the first time

`OI-27` has owned the operation-letter problem since it was raised —
`AccountingDB.dbo.GetMachineTypeFromOpLetter` maps `R`→1, `T`/`X`/`S`→2, `I`→3, `P`→4, `A`→5 and has
**no case for `F`**, so it returns `NULL` for flat wire today. `[ARC]` `D-32` and `[INT §111]` /
`[INT §163]` both restate it; `[INT §163]` adds that `PreCheckIn_CopyPlanningData`'s
`IsRollingOpLetter` / `IsSlittingOpLetter` / `IsOtherOpLetter` CASE matches none of them either.

**Two things are new.** The **set of free letters** is known for the first time; and a **second and
third** new letter are now in play, where the item was written assuming only `F`.

---

## 4. What this changes in the repository

### 4.1 One document is factually wrong and is corrected

`Analysis/Planning System/tables.md`'s `DRAW` and `EDGE` letter cells. Marked **pending** against
`G86` and `OI-143` rather than guessed — `K` is a proposal with no client authority, and writing it
in would make it look decided at the one site a developer would copy it from.

### 4.2 Two open items are amended and one is minted

See §5. `OI-27` and `OI-64` are **amended in place** and keep their ids, so all inbound citations
still resolve. `OI-143` is minted for the *"is Edge an SMP process"* half of §2.2, which `OI-27`
does not cover — `OI-27` is about the letter, not about whether the process exists.

### 4.3 The 31 Aug ledger's attachment warning is closed, not deleted

Per this folder's convention that a dated finding stays whole, §7 of that file is marked resolved
with the count reconciliation as evidence rather than being removed.

### 4.4 What this does **not** change

- **No new `Q##`.** These three are already in Srikanth's inbox. Minting register questions would
  re-ask them through `FlatWire_ClientQuestions.xlsx`, and the generator's strict 1:1 guard would
  additionally require three authored content blocks for questions the client has already received.
- **No component-identifier reconciliation.** The 31 Aug ledger §4.8 defers `D1`/`DB1`,
  `FL2-S1`/`FM2_S1`, `E1`/`EdgeSet` and `Takeup-1`/`TKUP-1` to one pass after the Speed tab lands.
  **This mail adds no new spelling** — leave it deferred.
- **No tooling-schema work.** `ToolingInventoryDie` was built 2 Sep (`Q91`, `OI-41` closed); the
  edger and straightener schema gap is already `G77`.
- **No `DOCUMENTS.md` change.** `Analysis/Planning System/` is unindexed and therefore uncitable by
  the repository's own rule. Indexing it needs a shortcode, a precedence ruling against the master
  specification and an owner — its own decision, not a side effect of this file.

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11.3 | **`OI-27` amended** — the free-letter set `F, K, Q, U`; `DRAW` needs a letter and `K` is **our proposal, not a decision**; `EDGE` may need one and `E` is taken; and the two-table registration surface, which is one namespace with the scheduling `OpLetter` |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11.2 | **`OI-64` amended** — already the *"sole tracking home"* for anneal rules; gains the anneal-type question and the `program_no = 171` back-anneal evidence |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11.2 | **`OI-143` minted** — is `EDGE` an SMP process step in its own right, or an attribute of the flatten it sits inside? |
| [`Gaps.md`](../../90-registers/Gaps.md) | **`G86`** — the committed plan-generation analysis assigns two operation letters the database shows are already in use |
| [`tables.md`](../../Analysis/Planning%20System/tables.md) | The `DRAW` and `EDGE` letter cells marked pending; a warning that the operation strings here and in `merging-logic.md` depend on the unassigned letters |
| [`ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md`](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) §7 | The `image018`–`image020` warning marked **resolved** |

---

## 6. Still owed by the client

| # | Item | Why it matters |
|---|---|---|
| 1 | ⛔ **The process letter and process id for `DRAW`.** `K` proposed, unconfirmed. Asked 1 Sep, **re-sent 3 Sep** | Blocks the SMP build in progress now. `D` is taken, so the analysis committed on 2 Sep cannot be built as written (`G86`, `OI-27`) |
| 2 | ⛔ **Whether `EDGE` is an SMP process at all**, and whether it needs a letter regardless. Asked 1 Sep, **re-sent 3 Sep** | Decides whether the route model gains a fourth operation or edging is an attribute of the flatten. `E` is taken either way (`OI-143`, `OI-27`) |
| 3 | ⛔ **The anneal types for flat wire** — plain only, or Back / QC / Upfront. Asked 2 Sep | The scheduler's anneal rules. ⚠ Answer it against the `program_no = 171` evidence in §3.3, not from scratch (`OI-64`) |
| 4 | ⛔ **The Speed tab** — the fourth `A12` leg, unmentioned in this copy too | Carried from the 31 Aug ledger §6. Blocks Ashwani's build, and gates the one-pass identifier reconciliation |

⚠ **Items 1 and 2 have been asked twice.** The re-send on 3 Sep is a nudge, not new content — the
question text is identical to 1 Sep. Age it from **1 September 2026**.

---

## 7. Attachments

**18 in total: 16 content screenshots + 2 signature graphics.** All extracted from the `.msg` and
read in full. **Every content image is a re-send of one already transcribed in the 31 Aug ledger
§3.1–§3.4** — nothing is transcribed again here.

| Files | Content |
|---|---|
| `image022 · image026 · image027 · image031` (all PNG) | Ashwani's **"before"** screens — Line Schedule (Mill copy), Setup/Handling (Slitter copy), Tooling Inventory (Slitter copy, 5 options), Material Loss (Mill copy) |
| `image020 · image002 · image021` | Flattening Line Schedule — FL1 · **FL2** · FL3. **`image002` is the screenshot §2.2 points at** |
| `image023 · image024 · image025` | Setup / Handling Times — FL1 · FL2 · FL3 |
| `image028 · image029 · image030` | Tooling Inventory — Die · Edger · Straightener |
| `image032 · image033 · image034` | Material Loss — FL1 · FL2 · FL3 |
| `image019.gif` (203×72, animated) · `image035.png` (154×48) | Signature graphics — Nagarro mark, and *Be Safe! Be Healthy!* Not content |

### ✅ The 31 Aug ledger's missing-attachment warning is resolved

That file's §7 warned: *"`image018`–`image020` are absent from the message; the numbering jumps
`017 → 021` … confirm in Outlook before treating the transcription as complete."*

**Nothing was missing.** Outlook re-numbers inline `cid:` references per message, so the two copies
of one thread carry different numbering — the gap was an artefact of that, not a lost attachment.
This copy is continuous, and the counts reconcile exactly:

**16 content images = 12 field sets** (3 Line Schedule + 3 Setup/Handling + 3 Tooling + 3 Material
Loss) **+ 4 "before" screens, all four PNG** — which is precisely the *"17 in total; 12 carry the
field sets"* plus four PNG "before" screens that file records. **The transcription is complete.**

⚠ **Do not reconcile the two files by image number.** `image002` here is the FL2 Line Schedule;
`image002` does not appear in the 31 Aug ledger's list at all. Cite by **content**, never by cid.

---

## 8. Thread provenance — the full chain

The 31 Aug ledger reaches back to 24 Aug. This copy carries the thread to its root.

| Date | From | What |
|---|---|---|
| 13 Apr 2026 | Srikanth Prabhala | **Original** — *"Attached are the documents related to Flat Wire machine… Welcome to the flat (wire) world!!"* |
| 18 Apr 2026 | Srikanth Prabhala | Files updated in that day's meeting |
| 24 Aug 2026 | Ashwani Tandon | The four Machines-App tab questions — `A12`'s trigger |
| 27 Aug 2026 | Ritika Raheja | Forwarded to UA |
| **31 Aug 19:06 UTC** | **Tim O'Brien** | **The answers — already recorded** in the 31 Aug ledger |
| 1 Sep 13:42 IST | Sushant Sinha | Process letters + Edge ⟵ **new** |
| 2 Sep 21:23 IST | Sushant Sinha | Anneal types ⟵ **new** |
| **3 Sep 04:42 UTC** | **Sushant Sinha** | Re-send of the process-letter question ⟵ **new** |

---

## Related Documents

| Document | Why |
|---|---|
| [ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) | **The same thread.** Its §3.1–§3.4 hold the field-set transcription this file deliberately does not repeat; its §7 warning is closed here |
| [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md) | `A12`, still open on the Speed tab leg; and the record clearing Sushant to code the SMP process |
| [Analysis/Planning System/tables.md](../../Analysis/Planning%20System/tables.md) | The operation-letter table corrected by this mail, and the SMP route model `OI-143` questions |
| [Analysis/Planning System/merging-logic.md](../../Analysis/Planning%20System/merging-logic.md) | Its `FA` / `FAF` worked examples are built from the letters in question |
| [MasterSpecification.md](../../10-requirements/MasterSpecification.md) | `OI-27` (op letters and `machine_type`), `OI-64` (anneal rules), `OI-143` |
| [Gaps.md](../../90-registers/Gaps.md) | `G86` |
| [40_FlatWireDB_Proc_FlatWire_CheckInRod.sql](../../30-database/scripts/40_FlatWireDB_Proc_FlatWire_CheckInRod.sql) | The `program_no = 171` back-anneal handling — §3.3 |
