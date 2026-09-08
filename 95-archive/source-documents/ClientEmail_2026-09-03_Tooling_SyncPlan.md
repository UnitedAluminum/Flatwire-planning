# Client e-mail — 3 September 2026 — Straighteners, mill rolls, and what the Tooling Inventory holds

**Source:** `RE: New Flat Wire Machine : Impact on .Net Applications` — Tim O'Brien (UA) to Yogender
Punia; cc DG UA DEV, Ritika Raheja, Srikanth Prabhala, Bob Scott, Shannon Riotte, Ashwani Tandon.
**Sent:** Thu 3 Sep 2026 **11:23:56 UTC**. **Analysed:** 3 Sep 2026.
**Attachments:** 18 — all inline, **all a re-send**. See §7.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §5.

---

## 1. ⚠ Two ledgers now share 3 September, and they are different messages

| | This file | [`ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md`](ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md) |
|---|---|---|
| **Sent** | 3 Sep **11:23 UTC** | 3 Sep **04:42 UTC** |
| **Direction** | **UA → us.** Tim answering | **Us → UA.** Sushant asking |
| **Subject matter** | Straighteners and what belongs in Tooling Inventory | SMP process letters, `EDGE`, anneal types |
| **Outcome** | **Six answers.** Two of the 31 Aug ledger's open rows close | Three questions, still unanswered |

They are the same thread and two different sub-conversations running in parallel. **The other
ledger's §8 provenance chain stops at 04:42 UTC** — seven hours before this message — and it does
not record the outbound mail this one answers either: **Yogender's 1 Sep 07:31** questions on the
Tooling Inventory tab, a second Nagarro→UA question set alongside Sushant's.

**What this closes**, from the 31 Aug ledger's *"still owed by the client"* list:

| Row | Item | Status |
|---|---|---|
| **9** | Straightener purpose; FL1/FL3-only, position, not-in-schedule — *"all read from the images, to confirm"* | ✅ **Closed on all four legs, and the images were read correctly** |
| **10** | Stand / Dancer / Spool — tooling or not; and whether FL3 holds its own tooling | ✅ **Closed on both halves** |

⛔ **`A12`'s Speed-tab leg is still unmentioned — the third consecutive client message.** Do not
mark it closed.

**No new `A##` id is minted here.** `ClientEmail_*` ledgers consume call-ledger ids; they do not
mint them.

---

## 2. The six answers, in Tim's words

| # | Yogender asked | Tim answered |
|---|---|---|
| 1 | What are straighteners used for? | *"The straightener rolls are used to straighten the wire in both the x, y, & z axis."* |
| 2 | Which line — FL1, FL2 or FL3? | *"They will be used on FL1"* |
| 3 | Where are they positioned in the mill? | *"The straightener blocks are positioned on the entry side of the 12″ mill on FL1."* |
| 4 | Are they part of the Pass Schedule? | *"No, they are always used on FL, however we did include them in our setup time due to the manual setup required of the operator."* |
| 5 | Stands, Dancers and Spools too? | *"Good point! We should include **mill rolls for traceability**, 12″ (FL1-S1) 2 roll set, **DB1/DB2 Capstans (rolls)** current inventory = 2, will be adding a spare and **they can be refurbished**, 8″, 6″, 6″ rolls for (FL2-S1, FL2-S2, FL2-S3) 2 roll sets. We will **NOT** need to include dancers, entry guides, payoffs, spools, etc. in the tooling table."* |
| 6 | Tooling per line, or FL1+FL2 with FL3 combining? | *"We should maintain them for FL1/FL2 and **FL3 should use a combination of the two**."* |

⚠ **Answer 4's *"they are always used on FL"* is a typo for FL1** — answer 2 says so, and FL3 runs
through FL1's equipment. Read it as FL1, and FL3 by inheritance.

⚠ **Answer 4 also contains two statements, not one.** Straighteners are **not** a pass-schedule
component **and** they **are** a setup-time element. Both matter, and they point at different
tables.

---

## 3. What the repository already knew, and where this corrects it

### 3.1 The straightener inference from the images was right

The 31 Aug ledger read all four straightener facts off the mockup grids and flagged them *"to
confirm"*. **All four confirm.** The Setup/Handling transcription already had *Set Wire
Straightener* and *Straightener Roll Change* under FL1's `S1` bucket — which is exactly what
answer 4's *"we did include them in our setup time"* describes — and the tooling grid already
attributed straighteners to `Machine Name = FL1`.

**Answer 3 is new information**, though: *entry side of the 12″ mill*. The FL1 material path in
this repository runs rod → `DB1` → `DB2` → `FM1`; the straightener blocks sit **between `DB2` and
`FM1`**, and nothing recorded that before.

### 3.2 ⚠ *"`Straightener` appears nowhere in this repository"* is now stale

That sentence was true when the 31 Aug ledger wrote it and is **no longer true**. Since 2 Sep the
name has a home in the **delay-code lookup** — `SET31`, `HDL20` and `DWN39`, all *Change
Straightener Rolls*, seeded inline by `01_Lookup` — plus two rows in `pause_run.js`. It reached the
repository through the client's reason codes, not through the tooling work.

What it still has no home for is **equipment**. Three documents repeated the stale sentence as an
acceptance criterion — `FW-003`, its `[TB]` mirror and `G77` — and all three are corrected.

### 3.3 ⭐ Answer 5 corroborates `D-26` first-hand

*"8″, 6″, 6″ rolls for (FL2-S1, FL2-S2, FL2-S3)"* is the client, unprompted, naming **three** FM2
stands with the 8″ at S1. `D-26` (4 Aug 2026) has been carried on our own reading of the meeting
until now: three stands, position-only ids, roll diameter as data in `Stand.RollDiameterIn` at
FM1 12.000 / FM2 8.000 / 6.000 / 6.000. **Every element of that is in one clause of this sentence.**

### 3.4 `Capstan` had zero modelling

Three matches in the whole repository before this mail, all of them **setup steps** in the 31 Aug
transcription — *Jog Capstan: DB1*, *Thread Capstan: DB2*. Nothing in any schema, requirement, API
surface, PLC tag map or mockup. A DB1/DB2 capstan-roll register is entirely new ground.

### 3.5 The absence of FL3 rows was intentional

The 31 Aug ledger observed that **no FL3 row appears in any of the three tool grids** and three
sites went on to assert it as fact — the `Drawer` DDL comment, the schema document and `Q91`'s
decision text — without a register id behind it. **Answer 6 confirms the inference and supplies the
reason.** It is not a gap in the sample; it is the rule.

---

## 4. What this changes in the repository

### 4.1 The Tooling Inventory carries four tool types, and the count finally has a register home

`D3` (24 Aug) recorded **two**. The 31 Aug mail made it **three**. This makes it **four**.

⚠ **The 31 Aug ledger §5 claims a `Decisions.md` entry was written recording the three. It never
was** — there is no `D3` row and no tool-type row anywhere in that register; the count lived only
in task acceptance criteria, `G77`, DDL comments and the archived sync plan. So `D-42` is a **mint
at four**, not a supersede of three, and it becomes the single assertion site the repository's own
convention requires.

### 4.2 ⚠ The roll-set register is built from one sentence, and that is a gap in itself — `G87`

Dies, edgers and straighteners each arrived as a **pictured grid with an ordered column list**.
Roll sets arrived as the sentence in answer 5. `ToolingInventoryRollSet` is built — it has to be,
because the decision is unambiguous about *whether* — but **every column in it is ours**, marked
`[PROPOSED]` at four sites, and `Q92` is the send-back.

⚠ **A fifth ambiguity sits inside the sentence.** *"12″ (FL1-S1) **2 roll set**"* and *"8″, 6″, 6″
rolls … **2 roll sets**"* read both as *two rolls per set* and as *two sets per position*, in one
paragraph. The first reading is seeded (`RollQty = 2`, corroborated by the edger grid's `Roll Qty
2`); the second would change the **row count**, so the seed is deliberately **one set per
position** rather than a guess at the real inventory.

### 4.3 The register follows the die split exactly, with one new twist

`Stand` and `Drawer` are the **positions**; `ToolingInventoryRollSet` is the physical **tool** — the
same shape `Q91` gave `Drawer` / `ToolingInventoryDie` on 2 Sep. The twist is **two parents**: mill
rolls mount on a `Stand`, capstan rolls on a `Drawer`. One discriminated table with `RollType` and
a mount CHECK, on the `DieHistory` precedent, rather than two tables.

✅ **`ToolingInventoryRollSet.DrawerId` is the first foreign key ever taken on `Drawer`.** The
schema document had recorded that `Drawer` was *"an equipment register, not a join target"* and
named `G77`'s work as its likely first referrer. It arrived from the roll sets instead.

### 4.4 The life model is grind, not footage

A die is consumed by **feet** (`LastGrindingFeet` / `TotalFeetAllowed`); a roll is **reground until
it reaches a minimum OD**. So the new table carries `OdIn` / `MinOdIn` / `DateOfLastGrind` and
**no footage counter**. `G77` had already drawn that distinction against the edger grid's *STD
Removal From OD .100 · OD 6.00 · Min OD 4.75* — about twelve grinds — and this is the first table
built on it.

### 4.5 ⚠ `FL3` leaves one constraint and not the other

`CK_ToolingInventoryDie_LineId` allowed `('FL1','FL3')`. Answer 6 makes an FL3 **tooling** row
impossible, so it is tightened to `('FL1')` — safe against the seed, whose fourteen rows all carry
`LineId` NULL.

⛔ **`CK_Drawer_LineId` keeps `FL3` and must not be "aligned" with it.** `Drawer` is **equipment**,
and FL3 genuinely runs through `DB1`/`DB2`. Answer 6 is about the tooling inventory. The two
constraints now differ on purpose, and both the DDL and the schema document say so in terms.

### 4.6 The object baseline moves — measured, not computed

**39 / 62 / 82 → 40 tables · 64 FKs · 86 index statements · 1 procedure · 1 trigger**, counted by
`verify_schema_counts.py` from the runner chain. `+1` table, `+2` FKs, `+4` indexes, `+6` seed rows.
`[DBD §6.2]` remains the defining site; the two runner banners, the two script headers,
`[DEP §4.2]`'s `V1`/`V2`/`V3` gate and `MVP2-SCOPE.md` are restated with it, and the guard passes.

⚠ **A raw `grep` of `CREATE TABLE` over `01`–`05` returns 40 and a raw count of `ADD CONSTRAINT
[FK_` returns 64 — and both agreeing with the verifier here is a coincidence of this pass, not a
method.** The repository's rule stands: count from the runner chain or a deploy, never by hand.

### 4.7 What this does **not** change

- **No component-identifier reconciliation.** The client calls `FM1` *"FL1-S1"* in this very
  sentence — a spelling the 31 Aug ledger §4.8 already recorded. Still deferred until the Speed tab
  lands. `Stand.Name` stays `FM1`.
- **No straightener equipment table.** Answer 1–4 settle what a straightener *is* and where it
  sits; they do not supply a grid. **`G77` still owns edger and straightener inventory.**
- **No `Dancer`, `PayoffPosition` or `Spool` migration.** Answer 5 excludes all three from tooling
  **explicitly**. They keep their own registers. ⚠ `Spool` in particular — it is the reusable
  stencilled article, and moving it would be a second `Q60`-class swap.
- **No effort re-derivation.** `FW-259`–`FW-261` carry hours; `FW-258` still owns the arithmetic.

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §10.2 | **`D-42` minted** — four tool types; dancers/guides/payoffs/spools excluded; FL1/FL2 only with FL3 combining. **Supersedes `D3`'s two and the 31 Aug three** |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11 | **`OI-77` amended** — the **roll** half is partly answered; the edger-blade-profile half untouched · **`OI-141` amended** — ownership undecided across **four** types |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §5 | `ToolingInventoryRollSet` described; `ToolingInventoryDie` is *"the first of the four"* |
| [`Gaps.md`](../../90-registers/Gaps.md) | **`G87` minted** — the fourth tool type is built from one sentence · **`G77` amended** — four types, and the *"`Straightener` appears nowhere"* claim struck as stale |
| [`Questions.md`](../../90-registers/Questions.md) | **`Q92` minted** — the roll-set grid columns, and the four sub-questions. Carried into `FlatWire_ClientQuestions.xlsx` (58 open rows, leakage scan clean) |
| `FlatWire_DDL_01_Lookup.sql` · `06` · `07` · `FlatWire_SampleData_Lookup.sql` | `ToolingInventoryRollSet` + 2 FKs + 4 indexes + 6 seed rows; `CK_ToolingInventoryDie_LineId` loses `FL3` |
| [`DatabaseDesign.md`](../../30-database/DatabaseDesign.md) `[DBD §6.2]` / `§7.3` | Baseline **40 / 64 / 86**; the Lookup group is **twelve**; the ERD gains the entity |
| [`FlatWireSchema_Lookup.md`](../../30-database/schema/FlatWireSchema_Lookup.md) · `FlatWireSchema_Mapping.md` | Full table section; the `Drawer` *"nothing holds an FK"* note **closed** |
| [`Deployment.md`](../../80-operations/Deployment.md) `[DEP §4.2]` | `V1`/`V2`/`V3` gate restated — ⚠ this gate has **rejected a correct deployment five times**; it does not now |
| `FW-003` · `FW-253` · `FW-199` · `FW-251` + [`TaskBreakdown.md`](../../60-delivery/TaskBreakdown.md) | Three → **four** tool types; the stale *"`Straightener` exists nowhere"* AC corrected; the FL1/FL2/FL3 rule added |
| **`FW-259`** DB 5 h · **`FW-260`** BE 10 h · **`FW-261`** FE 12 h | **Minted** — 27 h across three phases. ⛔ `FW-261` owes an un-priced mockup |

---

## 6. Still owed by the client

| # | Item | Why it matters |
|---|---|---|
| 1 | ⛔ **The roll-set grid columns** — `Q92`, sent 3 Sep 2026 | The register is built and its whole column set is ours. The failure mode is a tab that **looks finished** and collects the wrong fields, discovered after the roll shop has entered data against it |
| 2 | ⛔ **One tool option or two** — are capstan rolls the same *Choose Tool* entry as mill rolls | They mount on different machines. Decides `FW-261`'s dropdown and possibly splits the table |
| 3 | ⛔ **What *"refurbished"* means** against the edger's `In Grinding` | One vocabulary or two. `OI-77`'s regrind half |
| 4 | ⛔ **`Machine Name` for a capstan roll** — `FL1`, or the draw box | The other three grids all carry a line in that column |
| 5 | ⛔ **The Speed tab** — the fourth `A12` leg, **unmentioned in three consecutive messages** | Blocks Ashwani's build, and gates the one-pass identifier reconciliation |
| 6 | ⛔ **The straightener `.134` / `.184` range discrepancy** | ⚠ **Not resolved.** Tim repeated the prose range *"(.375 - .184)"* without addressing the grid, whose set A reads Min `0.134` |
| 7 | ⛔ **`OI-77`'s edger-blade-profile half**, and the regrind turnaround / in-house-or-out | `D-42` moved the roll half only |

---

## 7. Attachments — 18, and every one of them a re-send

**16 content screenshots + 2 signature graphics.** ⚠ **Nothing here is new, and nothing in it is
transcribed again** — all 16 are already transcribed at
[`ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md`](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md)
§3.1–§3.4.

**How that was established, rather than assumed.** The message's compressed-RTF body was
decompressed and its `<img>` anchors read **in document order**:

- Every *"Please include the fields pictured below, in the order pictured"* sits in the **quoted
  24 Aug mail** from Ashwani.
- **Tim's new reply contains no `<img>` at all.** The text between *"Hi Yogender"* and *"Regards,
  Yogender Punia"* — which is the whole of the new content — carries none.
- The twelve field-set images group 3-3-3-3 by pixel dimensions exactly as the four tabs require,
  and the four "before" screens and two signature graphics account for the rest. One signature
  measures **154×48**, the size the 3 Sep ProcessLetters ledger independently records.

⚠ **This copy numbers them `image001`–`image018` — a THIRD numbering of the same set.** The 31 Aug
copy jumped `017 → 021`; Sushant's copy ran `image019`–`image035`. Outlook renumbers inline `cid:`
references per message. **Cite an attachment by content, never by `cid`, and never reconcile two
ledgers by image number.**

---

## 8. Thread provenance — where this sits

The ProcessLetters ledger §8 carries the chain from 13 Apr to 3 Sep 04:42. This continues it, and
adds the outbound mail that chain omits.

| Date | From | What |
|---|---|---|
| **31 Aug 19:06 UTC** | Tim O'Brien | The four Machines-App tab answers — recorded in the 31 Aug ledger |
| 1 Sep 13:42 IST | Sushant Sinha | Process letters + `EDGE` |
| **1 Sep 07:31 (UA local)** | **Yogender Punia** | **The Tooling Inventory tab questions ⟵ recorded nowhere until now** |
| 2 Sep 21:23 IST | Sushant Sinha | Anneal types |
| 3 Sep 04:42 UTC | Sushant Sinha | Re-send of the process-letter question |
| **3 Sep 11:23 UTC** | **Tim O'Brien** | **This message — the six answers** |

---

## Related Documents

| Document | Why |
|---|---|
| [ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) | The ledger whose §6 rows 9 and 10 this closes; its §3.1–§3.4 hold the field-set transcription this file deliberately does not repeat |
| [ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md](ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md) | **The same thread, the same day, a different sub-conversation.** Read §1 of this file before reconciling the two |
| [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md) | `D3`, the two-tool-type decision this supersedes; and `A12`, still open on the Speed tab |
| [MasterSpecification.md](../../10-requirements/MasterSpecification.md) | `D-42`, `OI-77`, `OI-141`, and the `ToolingInventoryRollSet` table description |
| [Gaps.md](../../90-registers/Gaps.md) | `G87` (this register's authority) and `G77` (edger and straightener inventory, still unbuilt) |
| [Questions.md](../../90-registers/Questions.md) | `Q92` — the send-back |
| [FlatWire_DDL_01_Lookup.sql](../../30-database/sql/FlatWire_DDL_01_Lookup.sql) | The table, and the `CK_ToolingInventoryDie_LineId` tightening |
| [FlatWireSchema_Lookup.md](../../30-database/schema/FlatWireSchema_Lookup.md) | The column set, and the `Drawer` first-FK note this closes |
