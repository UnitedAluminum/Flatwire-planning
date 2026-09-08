# Client e-mail — 3 September 2026 — Tim's answers on the rod / order / spool / coil worked examples

**Source:** `RE: Flat Wire Mill — 33 open questions and 25 decisions for your confirmation` —
Tim O'Brien (UA) to Yogender Punia, Shannon Riotte, Bob Scott.
**Sent:** Thu 3 Sep 2026 11:05 UTC. **Analysed:** 3 Sep 2026.
**Attachment:** `How rods, orders, spools and coils fit together.docx` (47,914 bytes) — his annotated
copy of our 24 Aug worked-examples document, carrying **13 Word comments**.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §5.

⚠ **Not to be confused with
[`ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md`](ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md)**
— a different thread, analysed the same day. That one is Sushant's outbound SMP process-letter
questions; this one is Tim's inbound answers on rod↔order allocation.

---

## 1. What this closes

**This is action `A1` arriving.** The thread is three messages:

| Date | From | Attachment | What it was |
|---|---|---|---|
| **12 Aug 2026 18:09 UTC** | Yogender Punia | `FlatWire_ClientQuestions.xlsx` | Our outbound — the **33 open questions + 25 decisions** workbook |
| **24 Aug 2026 17:28** | Yogender Punia | `RodOrderAllocation_WorkedExamples.html` | Our outbound — **`A1`**, the seven worked examples |
| **3 Sep 2026 11:05 UTC** | **Tim O'Brien** | `How rods, orders, spools and coils fit together.docx` | **The answers** |

> *"Please review the attached doc. I have answered all questions and asked for some information and
> clarification in a few areas."* — Tim O'Brien, 3 Sep 2026

[`ClientCall_2026-08-24_SyncPlan.md`](ClientCall_2026-08-24_SyncPlan.md) §4 records `A1` — *"Excel
walkthrough of the multi-order / multi-alpha spool, pictures **and** description"* — as ⚠ *"Slipped.
Due before Mon 24 Aug"*, and as **the only thing scheduled against `D8`'s unadopted replacement
design**. It was sent that afternoon, and this is the reply.

| Leg | Status |
|---|---|
| `A1` — the worked-examples walkthrough | ✅ **Closed.** Sent 24 Aug, answered 3 Sep |
| All five `CLIENT INPUT REQUIRED` points in the document | ✅ **All five answered** |
| The four `Assumptions behind every figure` | ✅ 2 confirmed · ⚠ **2 corrected** |
| **The 12 Aug workbook — 33 open questions + 25 decisions** | ⛔ **NEVER RETURNED — 22 days.** See §6 |

⚠ **`D8`'s replacement design is now unscheduled.** `A1` was the only item against it, and it has
closed — so nothing is scheduled against it at all. That is what makes §4.1's ratification urgent.

---

## 2. Thirteen comments, nine distinct answers

All 13 comments are Tim's, timestamped 04:54–06:16 UTC on 3 Sep. **No tracked changes, no
highlighting, no insertions or deletions** — the document body is our text unaltered and every answer
is a comment. Four comments are duplicates, because the document asks two of its questions twice
(once inline where it bites, once in the closing summary table) and Tim answered both instances:

| Duplicate pair | Same answer given to |
|---|---|
| **C3** (inline, Example 6) **= C5** (summary table) | *Can two orders on one rod have different gauge, width or edge?* |
| **C4** (inline, Example 7) **= C6** (summary table) | *What should FL2 do when the boundary lands a few pounds past a coil cut?* |
| **C0** (the figures table) **≈ C10** (the assumptions) | The footage formula — raised twice, same challenge |

**So: 13 comments → 9 distinct answers.** Quoting a "C" number without this mapping will make the
same answer look like two independent confirmations.

---

## 3. The nine answers, verbatim

### 3.1 ⛔ FL2 cannot weld — flattened material cannot be welded at all

**C1** (05:11), anchored on our sentence *"Leftover incoming material is welded to the next coil back
at FL1, or run off at FL2 and offered to the customer"*:

> *"I need more clarification on this statement, are you implying that the left over material on
> spool at FL2 shall be welded to the next coil at FL1? If that is the case, **the statement is
> invalid. Once the material has been Flattened, it is no longer able to be welded due to a lack of
> capability at UA.**"*

**C11** (06:15), on our assumption *"Welding is induction and happens on the FL1 side only. FL2 cuts
and re-threads rather than joining one spool to the next"*:

> *"**Correct**"*

**Two statements, one conclusion: FL2 never welds, and flattened material is unweldable anywhere.**
This closes `G28` — see §4.2.

### 3.2 ⛔ No multi-order spool, and the boundary needs a check-out/check-in

**C3 = C5** (05:48 / 06:01), on *"Can two orders on one rod have different gauge, width or edge?"*:

> *"Yes, two orders can be planned on one Rod with shared or differing specifications **however, in
> both cases the system should require a check-out/check-in of the Rod, and the check-in of a new
> empty spool. I do not believe that we want to have multiple orders on a spool.** The process would
> become very complex and the room for error at coil generation/skidding would be substantial."*

⚠ **This reverses the premise of four open items and a gap, and invalidates two of our own worked
examples.** See §4.1 — it is the most consequential thing in the mail and it is **not** being
actioned as a decision.

### 3.3 All source rod alphas must appear on the label and certificate

**C2** (05:25), on our `CLIENT INPUT REQUIRED` asking whether a multi-rod coil gets one new combined
alpha or both parent alphas:

> *"When distinct rod coils are joined via end-to-end welding (such as flash-butt or cold-pressure
> welding) to maintain a continuous wire-drawing line, the final product contains material from
> multiple source batches. **To comply with ASTM traceability requirements, the product labels or
> accompanying certification tags must list all corresponding rod alphas (lot/heat numbers) present
> in that continuous spool.**"*

**Answer: all of them, not a new combined alpha.** `Q87`, `OI-99`, `OI-58`.

### 3.4 Coil overage — cut at the maximum and force a WIPREJ for the remainder

**C4 = C6** (05:52 / 06:02), on our three options for the 12.64 lb that runs past the order boundary
(ship over the maximum · mis-attribute it to the next order · keep the remainder — we proposed the
third):

> *"**Cut at 900 lb. and keep the remainder, a WIPREJ would be forced for the overage**, essentially
> a **peel-back** of the coil to put with in the allowable range."*

✅ **Confirms our `PROPOSED` option — and adds a mechanism we had not specified.** The WIPREJ
peel-back is new: see `G88` in §5.

### 3.5 ✅ The odd final coil ships as a single-coil skid

**C7** (06:04):

> *"This would depend on whether or not the customer allowed multiple orders to be combined on skid
> and whether they had a second order in cue. That is a lot of "Ifs".
> **The planners should be planning the orders in even numbers of coils to ensure that we ship
> complete skids, however in the instance that an odd number was produced we would ship the skid
> with one coil, as it completes the order.**"*

**Closes `OI-98`.** Note the two conditions he attaches, and that the primary control is a
**planning** rule (even coil counts), not a packing rule.

### 3.6 No ASTM weld-count limit — but a customer limit has nowhere to live

**C8** (06:10):

> *"**ASTM standards do not set a limit to the number of welds, or welding across LOT#s/Heats, only
> across differing alloys, tempers, & drastically different chemistries.**
>
> A Customer could have a #ofWelds specification, and **we did not capture this in any fields in the
> quotes & orders applications.** This may fall under customer note/spec, but the would require the
> operator to track. **We may need to discuss this further as it might need to be captured in a
> systematic way to prevent rejections due to multiple weld joints.**"*

Answers `OI-59`'s joint-limit half: **the constraint is alloy / temper / chemistry, not a count.**
The customer-specification half becomes `G89` — and note it is **Tim identifying a gap in UA's own
applications**, and asking for a discussion.

### 3.7 ⚠ Rod bundles are 4,400 / 5,600 / 7,400 lb — a third figure set

**C9** (06:13), on our assumption *"4,000 lb rods, an 1,800 lb spool target and an 800–900 lb
customer coil range, alloy 1100 at 0.110″ × 0.625″ leaving FL1 and 0.0160″ × 0.625″ leaving FL2"*:

> *"This is good as **we are looking at stocking three different vendors with rod bundle weights at
> 4400, 5600, and 7400 lbs.** A more realistic theoretical output for **FL1 is .085t x .700w and FL2
> is .016t x .699w.**"*

⚠ **Two corrections in one comment**, and both invalidate arithmetic:

- **Rod weight** — `OI-97` records the figure *"stated two ways"* (8,690–8,840 lb versus ~2,000 lb)
  and our reading as *"8,690–8,840 lb is correct… Confirm with Bob S. rather than assume."* The
  client has now stated a **third** answer directly, and it agrees with neither.
- **Gauge and width** — every figure in the worked examples uses 0.110 × 0.625 and 0.0160 × 0.625.

### 3.8 ⚠ The footage figures are disputed — twice

**C0** (04:54), anchored precisely on *"1,800 lb ≈ 22,250 ft"*:

> *"**What formula was used to calculate the linear footage**, this number is **lower than my
> calculations** and thus the output of FL2 is significantly lower as well."*

**C10** (06:14), on the rounding assumption:

> *"As noted earlier in the doc., the footage calculated here does not match my estimates. **Please
> provide the formula used for comparison.**"*

**This is not an answer — it is a challenge, and it is the one thing he has asked for twice.** §7
carries the reply, ready to send.

### 3.9 ✅ Raising the final spool over the order weight is right

**C12** (06:16), on *"The 40,400 lb in Example 4 against a 40,000 lb order is your planner working as
intended: the final spool is raised rather than left as a 400 lb tail"*:

> *"**Yes, I believe this is the best option to prevent yield loss.**"*

---

## 4. What this changes in the repository

### 4.1 ⚠ The multi-order-spool reversal — flagged, NOT actioned

§3.2 contradicts the recorded basis of **four open items and one gap**, all of which were written on
the 20 Aug client call's finding that *"a spool off FL1 may carry two or more orders while FL2 makes
one order at a time"*:

| Item | The premise Tim contradicts |
|---|---|
| **`OI-119`** | *"against a spool the client has confirmed carries many orders"* — if no spool carries two, the scalar `SpoolProcessing.OrderNo` is **correct** and the item dissolves |
| **`OI-123`** | *"The rod ↔ order design keeps a rod mounted across the boundary — one check-in, so one run spans two orders."* Tim requires a check-out/check-in, so **two check-ins ⇒ two runs**, and the scalar `FlatWireRun.OrderId` is right |
| **`OI-124`** | *"The order boundary is lost at the spool hop"* — presupposes a spool that spans a boundary |
| **`G48`** | *"a spool crossing an order boundary cannot say where the boundary is"* — the positional column exists to solve a case Tim says will not occur |
| **`Q43`** | Its index cell reads `Aug 20, 2026 (many)`. Tim now says **one** |

**And it invalidates our own document.** Examples 6 and 7 are built entirely on *"the rod never comes
off"* — *"Order 00422 begins immediately, on the same rod, with no dismount and no second check-in."*
Tim's answer says the opposite. Example 7's whole contribution — the boundary-alignment rule that
recovers 900 lb — presumes a spool that spans the boundary.

⛔ **Nothing is closed on this.** The 20 Aug basis was a **multi-voice client call**; this is **one
voice by e-mail**. That is precisely the situation `ClientCall_2026-08-24_SyncPlan.md` §3.1 flags for
`D1`, where a one-person position was accepted only once Bob and Tim both agreed on the record — and
where Tim's own alternative was left *"explicitly unadopted."* All five items are annotated
**premise contradicted, pending ratification** and stay open. Ratification is §6 item 3.

### 4.2 ✅ `G28` closes — and it names the wrong artefact

`G28` asked *"whether FL2 ever welds spool-to-spool"* and said **exactly one of two artefacts is
wrong and nobody has said which**: `dashboard_10_shift_summary.html`, which renders FL2 weld events,
or [`WeldEvent.md`](../../10-requirements/screens/WeldEvent.md) §6, which says an FL2 coil *inherits*
the spool's weld markers.

**§3.1 settles it. `WeldEvent.md` §6 is right; the mockup fixture is wrong.**

⚠ `G28`'s own resolution note says *"Do not resolve by deleting the fixture — that removes the
evidence of the disagreement without answering it."* That instruction applied **while the question
was open**. It is now answered, so correcting the fixture *is* the resolution. `WeldEvent.md`'s three
`[CLIENT INPUT REQUIRED]` blocks resolve with it, and §6's inheritance rule becomes normative.

### 4.3 The answers that land cleanly

| Answer | Effect |
|---|---|
| §3.5 odd final coil | **`OI-98` closes** |
| §3.3 all rod alphas on the label | **`Q87`** and **`OI-99`** answered; **`OI-58`** advanced |
| §3.6 no ASTM weld-count limit | **`OI-59`**'s joint-limit half answered |
| §3.4 cut at max, WIPREJ the remainder | **`OI-74`**'s open *"does the ladder apply to finished coils at TKUP-2"* half gains an answer shape |
| §3.9 raise the final spool | Confirms the planner behaviour Example 4 shows |

### 4.4 ⚠ Two assumption corrections that no figure has absorbed

§3.7 changes the rod weight and both gauges. **Nothing is re-derived here, deliberately** — every
figure in the worked examples chains off those inputs, and
`tools/deliverables/build_allocation_examples_xlsx.py` generates a client workbook from them. A
corrected set belongs in an additive pass once `OI-97` and `Q10` are settled, not in an edit to the
existing arithmetic.

⚠ **One consequence is worth stating now:** at **4,400 lb** a rod leaves an **800 lb tail** — exactly
the coil minimum. Example 1's conclusion (*"the 400 lb tail makes no shippable coil"*) becomes a
marginal coil rather than scrap, which changes the yield argument the document is built to make.

### 4.5 ⚠ Tim answered the 24 Aug copy, and the repository moved on two days later

Both renderings are in the repository, and the split is deliberate: the `.md` is the internal
analysis and the `.html` is *"the client-facing rendering of the same seven scenarios, in business
language"*, which the `.md` header declares as a **Companion** with the standing rule *"Same
numbers; **any change here must land there too.**"*

**The 24 Aug attachment and the repo's `.html` are not the same file.** Measured 3 Sep 2026:

| | Bytes | md5 |
|---|---|---|
| The 24 Aug attachment Tim answered | 63,031 | `f443c6f9…` |
| `95-archive/design-notes/RodOrderAllocation_WorkedExamples.html` (26 Aug) | 63,276 | `50100e49…` |

**They differ in exactly one paragraph**, and it is the one that matters here. The 26 Aug revision
replaced *"one coil per welded spool has two parents on its certificate"* with a fuller statement
that such a coil *"comes from two rods — so it carries **two identities** rather than one, each
holding only the weight that came from its own rod."*

— ⚠ **So C2 ratifies a decision Tim never saw.** He was reading the pre-revision copy, and asked
whether a multi-rod coil should get one new combined alpha or an alpha per parent rod with both on
the label. The 26 Aug change had already chosen the second, as part of the welded-coil-alpha work
(`Q89`). His answer — *"the product labels or accompanying certification tags must list all
corresponding rod alphas"* — **agrees with it**. That is corroboration, not new direction.

— ⚠ **And the companion rule was honoured in one direction only.** The 26 Aug revision landed in
the `.html` and **never in the `.md`** — zero matches for *"identities"* in that file. The `.md`
does carry the two-alpha model at the **spool** label (`R00001C - R00002A`, its own §7); what it
lacks is the 26 Aug **coil**-level statement.

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`Gaps.md`](../../90-registers/Gaps.md) | **`G28` RESOLVED** (§4.2) · **`G48`** premise contradicted, stays open (§4.1) · **`G89`** minted — a customer weld-count specification has no field anywhere · **`G88`** minted — the coil-overage WIPREJ peel-back has no reason code and no requirement |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11 | **`OI-98` CLOSED** · **`OI-119`**, **`OI-123`**, **`OI-124`** premise contradicted, stay open · **`OI-59`**, **`OI-74`**, **`OI-97`** advanced |
| [`Questions.md`](../../90-registers/Questions.md) | **`Q43`**, **`Q54`**, **`Q87`**, **`Q10`** annotated with Tim's answers. ⚠ **All four stay `Open`** — pending ratification, per this register's existing pattern for partly-answered questions |
| [`WeldEvent.md`](../../10-requirements/screens/WeldEvent.md) | §6's inheritance rule made **normative**; three `[CLIENT INPUT REQUIRED]` blocks resolved |
| [`dashboard_10_shift_summary.html`](../../50-frontend/mockups/dashboard_10_shift_summary.html) | The FL2 weld fixture removed — six sites. FL1 weld rows kept |
| [`RodOrderAllocation_WorkedExamples.md`](../design-notes/RodOrderAllocation_WorkedExamples.md) | Header note: Examples 6 and 7 describe a flow the client has rejected; the rod-weight and gauge assumptions are superseded; and the 26 Aug `.html` revision never landed here despite the companion rule. **Arithmetic untouched** |

---

## 6. Still owed — and by whom

**Owed by us:**

| # | Action | Why it cannot wait |
|---|---|---|
| 1 | ⛔ **Send Tim the footage formula.** §7 is drafted for it | Asked **twice**, and he is working from figures he believes are wrong |
| 2 | ⛔ **Chase the 12 Aug workbook** — 33 open questions + 25 decisions, unreturned **22 days**. ⚠ **No ledger in this folder records that send at all** | `Q10`, which he is now disputing, is one of the 33 |
| 3 | ⛔ **Put the §3.2 reversal to the next call** for a second and third UA voice | 4 open items + 1 gap + 2 of our worked examples hang on it, and `A1` closing leaves `D8`'s design unscheduled |
| 4 | **Ask which rod weight to build and plan against** — 4,400, 5,600, 7,400, or all three as stocked variants | §4.4 — and 4,400 changes Example 1's conclusion |
| 5 | **Confirm whether `.085 × .700` / `.016 × .699` replace the workbook dimensions**, or are theoretical maxima | Decides whether the re-derivation is one pass or two |

**Owed by the client:**

| # | Item | Why it matters |
|---|---|---|
| 6 | **`Q10`'s dimensional basis** — is the round-edge correction applied? | Worth **3.9 %** on footage alone. `Q10` is `Critical` and carries no recommendation *by decision*, because this is UA's to state from their own practice |
| 7 | **Whether a customer weld-count specification is captured systematically** — he raised it and asked to discuss | `G89`. His stated consequence: *"rejections due to multiple weld joints"* |
| 8 | **Ratification of the §3.2 reversal** by Bob and Srikanth on the record | The other side of item 3 |
| 9 | **The 12 Aug workbook** | The other side of item 2 |

---

## 7. The footage reply, drafted

Tim has asked twice. **Our arithmetic is correct for the dimensions we used; the divergence is
entirely in the input assumptions** — and the two effects pull in *opposite* directions on FL2, so
*"FL1 is low, therefore FL2 is low"* does not follow.

The formula is not new: it is `FR-137` and `FR-332`, already specified —

> **`lb/ft = A(in²) × 12 × ρ`**, with ρ from `united_db..alloys.alloy_density` (**0.098** lb/in³ for
> 1100) and `A` applying the round-edge correction where the edge type is Round.

That reproduces `FR-332a`'s published reference factors exactly — **0.0809** lb/ft square edge and
**0.0778** round at 0.110″ × 0.625″ — which is the check that the formula and the arithmetic are both
right.

| FL1 — 1,800 lb spool | A (in²) | lb/ft | Footage | vs ours |
|---|---|---|---|---|
| Our document, 0.110 × 0.625 | 0.06875 | 0.0809 | **22,263 ft** | — |
| Tim's realistic, 0.085 × 0.700 | 0.05950 | 0.0700 | **25,725 ft** | **+15.5 %** |

| FL2 — 900 lb coil | A (in²) | lb/ft | Footage | vs ours |
|---|---|---|---|---|
| Our document, 0.0160 × 0.625 | 0.01000 | 0.0118 | **76,531 ft** | — |
| Tim's realistic, 0.016 × 0.699 | 0.01118 | 0.0132 | **68,429 ft** | **−10.6 %** |

**Three separate things are in play, and they should be answered separately:**

1. **Gauge and width.** At his dimensions FL1 footage rises 15.5 % — which is the discrepancy he is
   seeing. But at his FL2 dimensions the FL2 footage **falls** 10.6 %, because .699″ is much wider
   than .625″ at the same gauge. His inference that FL2 must also be understated does not hold.
2. **The round-edge correction** — **+3.9 %** on footage by itself, at 0.110 × 0.625. ⚠ **This is
   the open half of `Q10`**, and it is his to answer: whether the dimensional basis is nominal or
   measured, and whether the round edge is corrected for, is a measurement question UA must state
   from its own practice. A proposed default risks being adopted as the basis rather than confirmed.
3. **Rod weight** — the actual throughput driver, and the likeliest source of *"the output of FL2 is
   significantly lower."* Every example is on 4,000 lb rods against his 4,400 / 5,600 / 7,400.

---

## 8. Attachments

One attachment on the 3 Sep message, and one on each of the two outbound messages.

| Message | File | Content |
|---|---|---|
| 3 Sep (Tim) | `How rods, orders, spools and coils fit together.docx` | 117 paragraphs · 14 tables · **13 comments, all Tim's** · **0 tracked changes, 0 highlighted runs**. The body is our 24 Aug text unaltered |
| 24 Aug (ours) | `RodOrderAllocation_WorkedExamples.html` | `A1` — the seven worked examples, client-facing rendering. ⚠ **Not byte-identical to the repo copy** — the repository's version is two days newer and differs in one paragraph; see §4.5 |
| 12 Aug (ours) | `FlatWire_ClientQuestions.xlsx` | The 33 open questions + 25 decisions workbook. ⛔ Never returned |

⚠ **All of Tim's answers are Word comments.** Read as plain document text the `.docx` looks identical
to what we sent and appears to contain no response at all. `word/comments.xml` is where the content
is; `word/commentsExtended.xml` carries the threading.

---

## Related Documents

| Document | Why |
|---|---|
| [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md) | Raises `A1`, which this closes; §3.1's `D1` note is the precedent for not treating one voice as ratification |
| [ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md](ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md) | The other 3 Sep e-mail — different thread, analysed the same day |
| [RodOrderAllocation_WorkedExamples.md](../design-notes/RodOrderAllocation_WorkedExamples.md) | The internal analysis behind the artefact Tim answered — §4.5 |
| [RodOrderAllocation.md](../design-notes/RodOrderAllocation.md) | The design whose Example 6/7 flow §3.2 rejects |
| [MasterSpecification.md](../../10-requirements/MasterSpecification.md) | `OI-98`, `OI-119`, `OI-123`, `OI-124`, `OI-59`, `OI-74`, `OI-97` |
| [Gaps.md](../../90-registers/Gaps.md) | `G28`, `G48`, `G89`, `G88` |
| [WeldEvent.md](../../10-requirements/screens/WeldEvent.md) | §6's inheritance rule, now normative — §4.2 |
| [SpoolCompletionNotification.md](../../10-requirements/screens/SpoolCompletionNotification.md) | The M3/M4 over-target ladder, which exists for spools at FL1 but not for coils at FL2 — `G88` |
