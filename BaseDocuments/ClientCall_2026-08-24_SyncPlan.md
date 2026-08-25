# Client Call 24 Aug 2026 — Action Items and Document Sync Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 24, 2026
**Status:** **Wave W1 applied 24 Aug 2026.** One new question (**`Q87`**) is minted, **`Q26`**, **`Q44`** and **`Q4`** are updated, and **`OI-121`** records the alpha-creation agreement. **No further wave is owed by this call** — nothing here reaches requirement text, schema, contracts or mockups. Two *conditional* waves are sequenced in §5 and are blocked on answers this call did not produce.
**Source:** Client call 24 Aug 2026, 10:59 UTC, **22m 52s** — Tim O'Brien, Bob Scott, Shannon Riotte (United Aluminum); Srikanth Prabhala, Yogender Punia, Ritika Raheja, Ashwani Tandon, Shray Anand, Waseem Khan, Vicky Arora, Divesh Malhotra, Sushant (Nagarro). Transcript: *Shopfloor · Review Priorities · Discuss Open Items · Use Time For Demos*, 20260824_105919UTC — Teams meeting recording. ⚠ **The transcript is not yet filed in this folder**, the same gap the 20 Aug ledger carries as `A8`.
**Flat wire span:** effectively the whole call. There is **no non-flat-wire tail** as there was on 20 Aug — but roughly a third of it (02:30 – 10:00) is the **flattening machine inside the Planning module**, which is flat wire work in an **adjacent code base**, not MVP-1. That material is §7, and only one item of it touches a boundary this repository asserts.
**Registers touched:** `Q##` ([FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) — **`Q87` added**, 56 → 57; `Q26`, `Q44`, `Q4` updated) · `OI-##` ([FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §11 — **`OI-121` updated**, none added). **No `G##`, no `FR-###`, no DDL, no contract, no mockup.**

---

## 1. Why this call mattered

It was **22 minutes** against the previous week's **91**, and on the face of it produced almost nothing.
Three things in it are worth the document anyway, and one of them is the largest single item on this project's
critical path that nobody scheduled.

| | What it does |
|---|---|
| **`D1` — alphas at the transaction** | **It converts a one-person position into a three-way agreement.** On 20 Aug, `D8` rejected the FL1-pre-generation design **on Srikanth's word alone**, and Tim's own alternative — *wire on a spool with pounds per alpha* — was left explicitly unadopted, the exchange ending *"maybe because I'm biased that it's not a problem."* Bob and Tim have now both agreed on the record, and the moment that is **excluded** has a name for the first time: **check-in**. It settles **when**, and leaves **what** exactly where it was |
| **`Q87` — a hole in the middle of the labelling set** | **`Q44`** owns the **FL1 spool** label and **`Q4`** owns the **skid**. The **finished coil the customer actually receives** had **no owner anywhere in the register** — and it is the one a customer complains about. It surfaced only because a worked example was put to UA, which is the argument for `A1`-style artefacts generally |
| **The schedule re-baseline** | **`S1` starts 24 Aug in the plan of record. On the evidence of this call it opened with requirements work only, and the build starts 31 Aug** — a week late, three resources short, against a window that ends **30 Sep** and a **3,186 h** baseline re-based at three developers. Yogender stated plainly that the 30 Sep finish no longer holds. **This is not propagated here**, for the reason given in §3.4 |
| **What did not happen** | **`A3`, the PLC review, was not raised by either side.** It is now **three weeks unmoved** since 6 Aug, this is the **second consecutive call** it has gone undiscussed, and three `Critical` tag confirmations plus the Phase-4 tag push sit behind it. Meanwhile the build start moved a week closer to it |

**What this call does not do.** It touches no requirement, no table, no endpoint and no screen. `D-26`, `D-31`
and `D-32` are untouched, as are all nine decisions of 20 Aug — `D1` here **completes** one of them rather
than changing it.

---

## 2. Decision ledger — mapped to register IDs

| # | Topic | Register ID | New status | Effect |
|---|---|---|---|---|
| **`D1`** | **Alphas are generated dynamically at the actual transaction — explicitly *not* at check-in** | **`OI-121`** updated · 20 Aug **`D8`** corroborated | `Decided` — **moment only** | Three-way agreement replaces one voice. The replacement *design* is still unadopted and `A1` is still the only thing scheduled against it. See §3.1 |
| **`D2`** | **The *Qualify Pass Schedule* button applies to flattening machines** *(Planning module — adjacent)* | **`OI-110`** corroborated | `Decided` | First client-side sighting of **where pass-schedule authoring actually lives**. Confirms the MVP-1 read-only boundary. **No MVP-1 artefact changes.** See §3.5 |
| **`D3`** | **The Tooling Inventory dropdown drops its four current options for *dies and edgers / edging rolls* only** *(Planning — adjacent)* | — | `Decided` | Columns change too (Bob). Adjacent code base; recorded for completeness. See §7 |
| **`—`** | **The FL2 finished-coil label** — one alpha or two, on what media | **`Q87`** raised | **Deferred by UA on the call** | Five constraints stated on the way to deferring it, and they narrow the answer considerably. See §3.2 |
| **`—`** | **Shopfloor panel resolution** | **`Q26`** advanced | `Open` — our action **closed** | The 1920×1080 requirement is with Tim and Charles in writing. UA has still not said what it will stock. See §3.3 |

**Corroborated, not changed:** nothing from 20 Aug was restated or contested. **Nothing was reversed.**

---

## 3. The decisions in detail

### 3.1 D1 — alphas at the transaction, and *not* at check-in

Shray asked whether the planning-end logic was final — generate alphas **at runtime, as the actual spools are
created**. Srikanth (21:50):

> *"Yeah, the approach we spoke of last time, right? I think **dynamically is fine** and I think we should do
> it **at the transaction time, not at the check-in time**. That was my suggestion last week … Not at the
> check-in, but at the **actual transaction time**. Tim, Bob and others can come in also if required."*

Bob: *"No, I agree. **You have to wait till the transaction.**"* Tim: *"Sure. Yeah, I also agree."*

**What this adds to `D8`, which is not nothing.** The 20 Aug ledger §3.7 records `D8` as *"rejects the earlier
design; replacement not settled"* — and the rejection was **Srikanth's alone**, twice stated, with Tim's
*pounds-per-alpha* model tabled and unadopted and the exchange closing on *"maybe because I'm biased that it's
not a problem."* All three UA-side voices are now on the record together. And the **excluded** moment is named:
**check-in**, which 20 Aug never addressed.

**What it does not settle**, and this is the part to resist reading into it:

- **`OI-121`** — weight per source alpha still has no home, and still inherits **`Q10`** wholesale.
- **`Q43`** — how many orders a spool may carry and who selects the one being made.
- **Which model wins** — Tim's *one unit, many alphas, pounds per alpha* against the two-coil model. `D1` is
  compatible with both, so it does not choose between them.
- **`A1`** — Yogender's Excel walkthrough — **remains the only thing scheduled against any of it**, and it is
  late (§4).

> **Wording confirmed 24 Aug 2026.** The recording renders "alphas" as **"L pass"** and **"L plus logic"**
> throughout this exchange — a transcription artefact. Confirmed with **Yash** the same day: the agreement is
> *"**alphas are generated dynamically at the actual transaction**"*. Quote it in that form, not as it appears
> on the recording.

### 3.2 The FL2 finished-coil label — `Q87`, and why it needed a new id

Yogender put a worked case to UA: an FL2 coil wound from **two contributing lengths** — 400 ft and 500 ft — is
one physical coil standing behind **two source identities**.

> *"Down here at FL2, if the coil is generated from the combination of two [rods] — here in this example, 400
> plus 500 — so we created a coil with the combination of this. **What should be the alpha, a single alpha, or
> we will show multiple alpha at the coil?**"*

**UA deferred it.** Tim: *"Yogender, we're going to have to get back to you on that. We're going to have to
figure out what the labeling is going to look like."* Shannon: *"we'll work it out outside the meeting."*

**Five constraints were stated on the way to deferring it, and together they nearly answer it:**

1. **Consistency with the existing coil label is wanted.** Shannon: *"let's make it as consistent with the
   coils as possible so customers understand it."* Bob named the field set — *"most customers want the alloy,
   temper, gauge"* — with the coil identity added.
2. **Traceability is wanted; both alphas on the customer face may not be.** Tim: *"I know we want to have the
   alphas for traceability purposes, but do we need to put **both of them on the label**?"*
3. **The cut label is the wrong medium.** Cut labels print as a **sheet**; a finished oscillate-wound coil
   needs one. Tim: *"we would end up printing an entire sheet of cut labels for one label."* Bob: *"I don't
   want to waste seven of the labels just for that … we'll have to make a **specific one** for the spool."*
4. **The skid label is a candidate carrier.** Bob: *"the crate skid is going to happen at the same time, we
   might be able to accommodate the information needed on the coil label for the skid … the same way we do the
   skid label, **the one that goes in the skid and on the skid**."*
5. **Something must sit under the stretch wrap.** Shannon: *"they're going to want something under the stretch
   wrap … customers take the stretch wrap off and store it."* Tim reported the opposite from a customer visit
   — *"there was nothing on the material itself, it was on the cardboard that was around it"* — and Shannon's
   answer was that UA **markets** the inside label: *"we kind of tout having labels inside and customers like
   that."*

**Why a new id rather than an update to an existing one.** The labelling set had a hole in the middle:
**`Q44`** owns the **FL1 spool** label, **`Q4`** owns the **skid**, and the **finished coil the customer
receives** had no owner anywhere in the register. `Q87` is `High`, owned by **Tim O. / Bob S. / Shannon R.**

**Constraint 4 makes `Q4` and `Q87` one decision, not two** — if the coil's information rides on the skid
label, answering either alone is answering neither. Both now point at the other.

**Our recommendation, recorded on `Q87`:** print **one coil alpha as the primary identity** — the coil is one
saleable unit against one order per 20 Aug's `D2` — and carry the contributing source alphas as **secondary
traceability text**, not as co-equal identities. Use a **coil-specific label**, not a cut-label sheet, one
inside the wrap and one on the skid. Two co-equal alphas on the customer face invite the customer to treat one
coil as two line items; the genealogy is what **`CoilTraceability`** exists to hold, and the **certificate**,
not the label, is where provenance is stated (**`Q53`**).

**What is blocked meanwhile:** the coil-completion label print in
[`OutputCoilCompletion.md`](../MVP-1/ProjectPlan/Business/Screens/OutputCoilCompletion.md), and any field on it
stating a **weight**, which rests on **`Q10`** like every other derived weight in the build.

### 3.3 `Q26` advanced — our action closed, UA's answer still owed

Tim, opening the call:

> *"Divesh, I believe it was you that had asked about the workstation resolution … you were looking for the
> **1920 by 1080**? … Okay, perfect. **I'll respond to this e-mail from Charles.**"*

**The Nagarro-side action is done.** `Q26` recorded it as *"send Tim the required resolution (1920×1080) by
e-mail"*; the number is now with Tim and with Charles. **The question is not closed** — what UA actually stocks
is Charles's and Juan's answer, and it has not been given.

Two things to hold on to:

- A **1920×1080** answer is a **re-layout of 25+ screens, not a rescale** — `Q26`'s own body says so, because
  the extra pixels are almost entirely horizontal — and it contradicts
  [`phase-01a`](../MVP-1/ProjectPlan/Development/Phases/phase-01a-angular-foundation.md)'s *"fixed 1280×1024
  shopfloor canvas"* acceptance criterion. **The 14 Aug gate this was meant to beat has already passed**, so
  the free window is gone whichever way it lands.
- Tim said **workstation** resolution. `Q26` asks about the **shopfloor panel**. Confirm one answer covers both
  before treating this as settled — that is **`A11`**.

**It is now on the critical path in a way it was not last week**, because the front-end build starts 31 Aug
(§3.4) and Kanika and Srishti start on the front end.

### 3.4 The schedule re-baselined — recorded here, deliberately not propagated

Three statements, none contested on the call:

1. **Three resources came off flat wire this week.** Ritika: *"Kanika and S[rishti] will not be starting from
   this week and **Harshal will also not be part of flat wire**. So **3 resources are gone for this week**."*
   Kanika and Ashwani join **next week**, when their current work ends.
2. **Full-fledged development starts Monday 31 Aug, not 24 Aug.** Yogender: *"from next week we will start …
   I am mainly working on the **requirements** right now to finalize everything just before starting the
   development. So the **full-fledged development will start from the Monday**."* The split when it starts:
   **Kanika and Srishti on the front end, Yogender on the back end.**
3. **The 30 September finish no longer holds.** Srikanth asked for due dates; Yogender: *"Last time we were
   planning to finish everything by **30 September**, 3 resources, but **with the updated plan I will share
   with you**."* Srikanth: *"please provide that to Ritika and then she'll include that in the common
   spreadsheet."*

**What this collides with.** `S1` starts **24 Aug** in
[`TaskBreakdown.md`](../MVP-1/ProjectPlan/Development/TaskBreakdown.md), and the 20 Aug ledger's risk list
opens with *"`S1` starts Mon 24 Aug and both `D1` and `D2` land inside it"* — where those are the **FL2
pre-check-in reversal** and the **spool genealogy child table**, the latter in a window `G42` describes as
*"free"* only until something writes it. On the evidence of this call **`S1` opened with requirements work only
and the build starts a week late**, against a window ending **30 Sep 2026**.

> **Why nothing is propagated.** No effort figure, sprint date or capacity total has been touched, and none
> should be until the re-baseline exists as a number. It is **Yogender's to issue** — owed to Srikanth by
> e-mail and to Ritika for the common tracking sheet — and
> [`CapacityAndEffortModel.md`](../MVP-1/ProjectPlan/Development/CapacityAndEffortModel.md)'s totals are quoted
> in roughly twenty files, so any change is **a new additive sheet, never an in-place edit of a total**.
> Tracked as **`A9`**, and sequenced as the conditional wave **W3** in §5.

### 3.5 D2 — pass-schedule qualification lives in Planning, and that is a boundary confirmation

Ashwani, building the flattening machine type into the Planning line-schedule tab, asked whether the **Qualify
Pass Schedule** button — present for the ZR23 machine — is also needed for flattening machines. Tim: *"Yes, I
would say that it is."* Bob agreed, adding that **periodicity** may be needed too: *"we might as well have
something there that needs to be qualified for."*

**Why this is in the ledger and not only in §7.** This repository asserts, in several places, that **MVP-1
reads pass schedules and never authors them** — no create, edit, approve or list, DB9/DB9A deferred to MVP-2,
no pass-schedule endpoint, and **`OI-110`**'s observation that nothing in MVP-1 populates the table in
production. That boundary has always rested on our own reading. **This is the first client-side sighting of
where the authoring actually lives**, and it lands where the boundary predicted: in Planning.

**No MVP-1 artefact changes on the strength of it.** It is corroboration, not direction — recorded so that the
next person to ask *"who actually creates a pass schedule?"* has an answer with a date on it.

---

## 4. Action items with owners and dates

### Carried from 20 Aug — status at 24 Aug

| # | Owner | Status |
|---|---|---|
| **`A1`** — Excel walkthrough of the multi-order / multi-alpha spool, pictures **and** description | Yogender | ⚠ **Slipped.** Due *before* Mon 24 Aug; on the call: *"I was creating the examples of all the possible scenarios for the trial … **yet not able to complete this. I will finish it by today** and send it to you."* Still the **only** thing scheduled against `D8`'s unadopted replacement design |
| **`A2`** — further dry-run examples of the spool / coil sizing algorithm | Shray | **Not reported.** Shray was on the call and raised `D1` instead; `A2` was not mentioned either way |
| **`A3`** — PLC technical details | Tim O. | ⚠ **Not raised by either side.** **Unmoved since 6 Aug — three weeks**, and the second consecutive call it has gone undiscussed. `PLC-Q02` / `PLC-Q04` / `PLC-Q05` (all `Critical`), the Phase-4 tag push and commissioning `C1` / `C11` are behind it |
| **`A4`** — etched stainless barcode number plates | Bob S. | Not reported |
| **`A5`** — stencil nomenclature and the 30 → 45 confirmation | Tim O. / Bob S. | Not reported. The seed has since been **built at 45 rows** (`SP-0001`…`SP-0045`), so this now confirms a build rather than informing one |
| **`A6`** — size `FW-224`+ for the FL2 pre-check-in, additive | Nagarro | Not reported. Due *before `S1`* — and `S1` has just moved (§3.4) |
| **`A7`** — Waseem moves onto flat wire Monday | Waseem | ✅ **Done.** *"Today I started on the scheduling logic. They provided me the data … for this type of flat wire, so with that data I have started."* **40 h** high-level estimate; *"there is still some doubt, I can see some few scenarios to be handled"* |
| **`A8`** — file the 20 Aug transcript in this folder | Nagarro | ⚠ **Still owed** — and there are now **two** transcripts in that position, this call's included |

### New from this call

| # | Action | Owner | Due |
|---|---|---|---|
| **`A9`** | **Issue the re-baselined plan and due dates** — the 30 Sep finish, the 31 Aug start, the three-resource gap. To Srikanth by e-mail, to Ritika for the common tracking sheet. Any change to `[CE]` totals is **a new additive sheet**, never an in-place edit | **Yogender** | **this week** |
| **`A10`** | **Answer `Q87` together with `Q4`** — the finished-coil label field set, the media, and one alpha or two. Constraint 4 makes them one decision | **Tim O. / Bob S. / Shannon R.** | — |
| **`A11`** | **Confirm `Q26` covers the shopfloor panel and not only the workstation**, and get Charles's and Juan's answer in writing | **Tim O. / Charles / Juan** | **before the FE build starts 31 Aug** |
| **`A12`** | **Tim's e-mail on the four Planning tabs** — Line Schedule columns, Setup Handling Time, Material Lost, and the Speed tab's unexplained block (§7). Adjacent module; tracked because the call is one meeting | **Tim O.** | — |

### Risks stated or visible on the call

- **The build start moved a week later while `A3` moved not at all.** Three `Critical` tag confirmations and
  the Phase-4 tag push now sit behind a review that is three weeks old and was not mentioned.
- **`S1` began with requirements work only.** Both items the 20 Aug ledger placed inside `S1` — the `FR-031`
  reversal and `G42`'s genealogy child — are unstarted, and `G42`'s free window closes when something writes
  the table.
- **`A1` is late and singular.** `D1` settles the *moment* and nothing settles the *content*; the artefact that
  would is one person's spreadsheet, one day overdue.
- **`Q26` is now on the front-end critical path.** Two developers start on the front end on 31 Aug, against a
  canvas whose target resolution is unconfirmed and whose free window has already closed.
- **Three named resources left flat wire in one week** and the replacements arrive a week later, against a
  fixed 30 Sep window.

---

## 5. Propagation waves

**W1 is complete as of 24 Aug 2026. W2 and W3 are conditional — neither is owed by this call, and both are
blocked on answers this call did not produce.**

| Wave | Targets | Files | Risk |
|---|---|---|---|
| **W1 — Registers** ✅ | [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) — **`Q87` added** (next free id: `Q1`–`Q86` were all occupied, no holes), header counts **56 → 57 open / 49 → 50 shopfloor**, priority index and Quick Reference log realigned; **`Q26`** given a progress note; **`Q44`** and **`Q4`** cross-referenced to `Q87` · [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §11 — **`OI-121`** records `D1` and the confirmed wording | 2 | L |
| **W2 — The coil label** *(blocked on `Q87` / `A10`)* | [OutputCoilCompletion.md](../MVP-1/ProjectPlan/Business/Screens/OutputCoilCompletion.md) owns DB7/DB7b and is where the label print lands — it will need the **field list**, the **media**, and the **one-or-two-alpha** rule. `Q4`'s skid rules move with it if constraint 4 holds. Any printed weight also waits on **`Q10`**. ⚠ **Do not draft this against the recommendation** — `Q87` carries a recommendation, not a decision | 1 (+ mockup) | M |
| **W3 — Plans and effort** *(blocked on `A9`)* | [TaskBreakdown.md](../MVP-1/ProjectPlan/Development/TaskBreakdown.md) `S1`'s 24 Aug start · [CapacityAndEffortModel.md](../MVP-1/ProjectPlan/Development/CapacityAndEffortModel.md) §3b · [`Development/StaffedSprintPlans.md`](../MVP-1/ProjectPlan/Development/StaffedSprintPlans.md) and the roadmap's milestone calendar. ⚠ **The 3,186 h / three-developer figures are quoted in roughly twenty files** — re-derive in **one additive sheet** and publish once, never by editing a total in place | 4+ | **H** |

**Not owed by this call:** no `FR-###`, no schema or DDL, no contract, no mockup, no test case, no phase file.
`D2` and `D3` are **adjacent-module** decisions and change nothing in `MVP-1/`.

**Convention reminders for W2 and W3:** update **Last Updated** on each document touched and append its row to
[`../CHANGELOG.md`](../CHANGELOG.md) — **not to the document itself**; a client-review specification states its
version in its `**Version:**` header and **nowhere else**, and the same value is stamped on the `CHANGELOG.md`
row; strike resolved register items with a `DECIDED (date)` note and **never delete them**; keep `Q##`
numbering contiguous; **supersede requirement ids in place, never renumber**; and backlog story headings, hours
and sprint cells are **parsed by three `.xlsx` generators** — no strikethrough in them.

---

## 6. Send back to the client (open, blocking, or owed)

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | **`Q87`** — the FL2 finished-coil label: field list, media, and **one alpha or two** for a multi-rod coil. **Answer with `Q4`** | Tim O. / Bob S. / Shannon R. | The DB7 label print; `Q4` |
| 2 | **`Q26`** — does **1920×1080** cover the **shopfloor panel** as well as the workstation, and what will UA stock? A re-layout of 25+ screens rides on it | Tim O. / Charles / Juan | The front-end canvas, from **31 Aug** |
| 3 | **`A3` — the PLC review.** Carried from **6 Aug**, unmoved, and **not raised on either of the last two calls**. Closes `PLC-Q02` / `PLC-Q04` / `PLC-Q05`, all `Critical` | Tim O. / Engineering | Phase-4 tag push, commissioning `C1` / `C11` |
| 4 | **`A12`** — Tim's e-mail on the four Planning tabs and the Speed tab's unexplained block | Tim O. | Ashwani's Planning build, in progress now |
| 5 | **Everything on the 20 Aug send-back list is untouched** — `Q41`, `Q42`, `Q43`, `Q44`, `Q45`, `Q46`, `Q47`, `Q37`–`Q40`, `OI-115` and the carried items. See [ClientCall_2026-08-20_SyncPlan.md](ClientCall_2026-08-20_SyncPlan.md) §6 | — | — |
| 6 | **`Q10`** — the footage-to-weight dimensional basis. Still the **oldest and most depended-on open number in the build**, deliberately carrying no recommendation, and it now **also gates any weight printed on `Q87`'s label** | Tim O. / Bob S. | Every derived weight |

---

## 7. Planning module and other adjacent items, for the record

**Recorded because the call is one meeting and the flat wire team was on it. Only `D2` (§3.5) touches a
boundary this repository asserts; nothing else here changes an `MVP-1/` artefact.**

Ashwani is adding the **flattening machine type** to the Planning module and brought five items. **Two were
answered on the call** — the *Qualify Pass Schedule* button applies (**`D2`**, §3.5, with Bob floating
**periodicity** as possibly also needed), and the **Tooling Inventory dropdown loses its four current
options** for **dies and edgers / edging rolls** only (**`D3`**). Tim: *"those will not be needed."* Bob added
that **the columns change too**.

**Three are owed by Tim, by e-mail, from his notes (`A12`):** the **Line Schedule** tab column set, the **Setup
Handling Time** tab, and the **Material Lost** tab — plus, on the **Speed** tab, which columns are needed
beyond the slitter's (only *speed* has been identified so far), the **DB1/DB2 checkboxes**, and one block
Ashwani could not interpret from the requirement. Tim: *"I'll go through all the columns and verify what needs
to stay and what needs to go."* Ashwani is proceeding on dummy data and will adjust when the mail arrives.

**Other items:** Sushant is cleared to start coding the **SMP process** for the flat wire item — Srikanth:
*"you can start with the coding … I'll send you the notes from last week's conversation with QC"* — and will
start the following day. Waseem's **scheduling logic** is under way at a **40 h** high-level estimate (**`A7`**
closed). Vicky reported the **MVP credentials failing**; Srikanth's answer was to try the password **with a
trailing hyphen**, changed on the Friday.

> ⚠ **Garbled on the recording and not to be transcribed as fact:** *"planning an item site"* (Sushant's
> assignment), *"quarter saving"* (Vicky's task), *"SMP process"*, and the name rendered *"Sushti"*
> (Srishti). Confirm before any of these reaches a plan document. The `D1` exchange carried the same problem
> and was resolved — see §3.1.

---

## Related Documents

| Document | Why |
|---|---|
| [ClientCall_2026-08-20_SyncPlan.md](ClientCall_2026-08-20_SyncPlan.md) | **The call this one follows.** `D1` here completes its `D8`; its `A1`–`A8` are tracked to status in §4; its **W3–W7 remain unexecuted**, and nothing in this call unblocks them |
| [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) | Authoritative `Q##` register — W1; **`Q87`** added, `Q26` / `Q44` / `Q4` updated |
| [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) | `OI-##` register §11 and the reconciliation authority — **`OI-121`** updated; **`OI-110`** corroborated by `D2` |
| [OutputCoilCompletion.md](../MVP-1/ProjectPlan/Business/Screens/OutputCoilCompletion.md) | Owns DB7/DB7b — where **`Q87`**'s label lands once the field set is answered (W2) |
| [TaskBreakdown.md](../MVP-1/ProjectPlan/Development/TaskBreakdown.md) | `S1`'s **24 Aug** start, against a build that begins 31 Aug — W3, **not edited** |
| [CapacityAndEffortModel.md](../MVP-1/ProjectPlan/Development/CapacityAndEffortModel.md) | The **3,186 h / three-developer** baseline the re-basline replaces — W3, **not edited**; its totals are quoted in ~20 files |
| [phase-01a-angular-foundation.md](../MVP-1/ProjectPlan/Development/Phases/phase-01a-angular-foundation.md) | *"Fixed 1280×1024 shopfloor canvas"* — the acceptance criterion **`Q26`** would overturn |
| [ClientCall_2026-08-06_SyncPlan.md](ClientCall_2026-08-06_SyncPlan.md) | Where the PLC review began life as `A4`; it is `A3` on both later ledgers and has not moved since |
