# Client e-mail — 9 September 2026 — the 12 Aug questions workbook comes back, complete

**Source:** `RE: Flat Wire Mill — 33 open questions and 25 decisions for your confirmation` —
Tim O'Brien (UA) to Yogender Punia, Shannon Riotte, Bob Scott. Cc Srikanth Prabhala, DG UA DEV.
**Analysed:** 9 Sep 2026.
**Attachment:** `Copy of FlatWire_ClientQuestions (002).xlsx` (56,878 bytes) — his completed copy of
our 12 Aug workbook, three sheets, **58 answered rows**.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §6.

⚠ **Not to be confused with
[`ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`](ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md)**
— the same subject line, the same thread, a different attachment. That one is Tim's annotated
worked-examples `.docx`; this one is the **workbook itself**. §1 disambiguates the four messages.

---

## 1. What this closes

**This is the 12 Aug workbook arriving — 28 days late.** The thread is now four messages, and three
of the four carry different attachments under one subject line:

| Date | From | Attachment | What it was |
|---|---|---|---|
| **12 Aug 2026 18:09 UTC** | Yogender Punia | `FlatWire_ClientQuestions.xlsx` | Our outbound — the **33 open questions + 25 decisions** workbook |
| **24 Aug 2026 17:28** | Yogender Punia | `RodOrderAllocation_WorkedExamples.html` | Our outbound — `A1`, the seven worked examples |
| **3 Sep 2026 11:05 UTC** | Tim O'Brien | `How rods, orders, spools and coils fit together.docx` | Answers to `A1` — recorded separately |
| **9 Sep 2026** | **Tim O'Brien** | **`Copy of FlatWire_ClientQuestions (002).xlsx`** | **The workbook, completed** |

[`ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`](ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md)
§1 records the workbook as ⛔ **"NEVER RETURNED — 22 days."** That line is now closed.

> *"Attached are the 25 decisions/33 questions. Please note that I owe you information regarding the
> following…"* — Tim O'Brien, 9 Sep 2026

**Nothing was left blank.** Every one of the 58 rows carries a dropdown value, a name and a date.
Answers are dated **4 Sep** (11 decisions) and **8 Sep** (14 decisions + all 33 questions).

---

## 2. The shape of the return

| Sheet | Rows | Verdicts |
|---|---|---|
| **Decisions to Confirm** | 25 | **20 `Confirmed`** · **5 `Not confirmed — see next column`** |
| **Open Questions** | 33 | **17 `Agree with recommendation`** · **12 `Different answer`** · **4 `Needs discussion`** |

Eight decision rows and eighteen question rows carry free text as well as the dropdown, and the free
text is not always consistent with the dropdown — **three rows marked `Confirmed` carry a
correction or a question in the free-text column** (`Q65`, `Q73`, `Q83`), and one row marked
`Agree with recommendation` carries a statement that contradicts a shipped requirement (`Q19`, §5.1).
**Read the free text on every row, not only on the rows that dissent.**

⚠ **`Q26` is on the Open Questions sheet here but has already left the open register.** It closed on
7 Sep 2026 by a separate route and moved to [`Decisions.md`](../../90-registers/Decisions.md). Tim's
answer in this workbook — `Different answer`, **1920 × 1080** — is independent corroboration of that
close, not a new input. It does not reopen anything.

---

## 3. The 25 recorded decisions

### 3.1 The five that are NOT confirmed

**`Q67` — FL1 and FL2 on different orders concurrently.** Deferred to trial data:

> *"This is tied to Q66, if the output speed of FL2 is greater than initial estimates, this gap would
> close. Given this, we wont have an absolute answer until we have processed some trial data."*

Not a correction — a **suspension**. The decision cannot be confirmed until `Q66`'s line-speed
figures exist, which are themselves owed after the trial.

**`Q68` — does pre-check-in commit the shared coil record.** He adopts our position wholesale:

> *"Please proceed with your position that these writes should move to check-in alongside the status,
> so that pre-check-in has no effect outside the flat wire system at all."*

⭐ **This is the large one.** The recorded decision covered the *status* only; the residual we wrote
against it named the queue insert, the requirements summary and the WIP order insert as uncovered.
All three now move to check-in. **Removing a staged rod becomes a clean local delete** — no
cross-database undo at all.

**`Q70` — pre-check-in against a future order.**

> *"Per the email that I sent today referencing the HTML document, we do not want multiple orders on
> one spool, we will want to stop the line and force a spool change."*

⚠ **This is the second time he has said it, and it is still one voice.** See §5.2.

**`Q72` — releasing a welded rod from its bay.**

> *"A weld flag should not be possible unless a rod has been checked in or prechecked in. In this
> instance, if a miss-scan occurred, the operator would have had to check in and weld the coil and
> therefore the coil would need to be reversed out of staging and rejected, via a supervisor
> override."*

Answers the residual exactly as it was asked. **There is no clear-the-flag-in-place case** — the
only path is reverse out of staging and reject. So the missing audit target we flagged does not need
inventing; the existing rejection path carries it.

**`Q85` — FM2 stand count and roller sizes.**

> *"FL2 - Has three stands S1 = 8", S2 = 6", S3 = 6". There are two edgers, one sits between S1/S2 &
> the other between S2/S3. There is no edger after S3."*

✅ **Corroborates `D-26` on the stand model** — three stands, the 8″ roller *is* S1. The dropdown
says `Not confirmed` because he is restating the correction he originally raised, not because he
disagrees with what we recorded.

⚠ **But the edger positions are stated differently from how we hold them.** [`CLAUDE.md`](../../CLAUDE.md)
says *"Edgers at S2 and S3 only"*; Tim says *between* S1/S2 and *between* S2/S3. These are the same
two physical inter-stand gaps under two naming conventions, and `Q28` (§4.3) names them **E1** and
**E2**. **Pick one convention in `[PLC]` before a third appears.**

### 3.2 The three marked `Confirmed` that carry free text

| Q | Dropdown | Free text | Reading |
|---|---|---|---|
| **`Q65`** | Confirmed | *"Check point = SPC?"* | ⚠ **A question back, not an answer.** He is confirming a decision whose subject term he is not certain of. Needs a one-line reply before it counts as closed |
| **`Q73`** | Confirmed | *"For No-Welding branch, continue to utilize the three-tier rule. This keeps things consistent and clean. The rules apply all the time, regardless of welding."* | ⭐ **Closes the genuinely unresolved branch.** The residual asked exactly this and said *"do not read the no-welding case as an unqualified 'the sequence is free'"*. He agrees: the rule is unconditional |
| **`Q83`** | Confirmed | *"Correct, Dies will have a unique identifier to track their usage individually."* | Per-die identity confirmed. The threshold figures are still deferred |

### 3.3 The seventeen confirmed without comment

`Q61` · `Q62` · `Q63` · `Q64` · `Q66` · `Q69` · `Q71` · `Q74` · `Q75` · `Q76` · `Q77` · `Q78` ·
`Q79` · `Q80` · `Q81` · `Q82` · `Q84`.

⚠ **Confirming a decision does not clear the residual we wrote against it.** Thirteen of the 25 rows
carry an *"Anything still open"* note that is ours, not his — `Q62`, `Q66`, `Q69`, `Q71`, `Q79`,
`Q83`, `Q84` among the confirmed ones. Those residuals are untouched by the confirmation.
`Q79`'s in particular is still owed **as a document** (§7).

---

## 4. The 33 open questions

### 4.1 ⛔ The two that contradict something already built

Both are in §5.1. They are listed here only so the count reconciles: **`Q19`** and **`Q22`**.

### 4.2 The five Critical

| Q | Verdict | What he said |
|---|---|---|
| **`Q2`** | ✅ Agree | *"I agree, a single FL3 booking should reserve FL1/2 capacities."* |
| **`Q3`** | ✅ Agree | *"The data already exists in the application layouts and therefore would be a printout version. **Ownership can be assigned to me for redlining.**"* — the field list gets an owner |
| **`Q10`** | ⚠ Different | **Nominal, not measured.** *"The rod dimension used is the nominal, as the measured will only be in the position measured… This is why the weight of the incoming rod is a key factor in the calculation, as it is a fixed value where the others are variable."* And: *"there is a round edge correction when leaving the 12" mill stand, as there is no edging capability presently."* |
| **`Q14`** | ✅ Agree | Block check-in, alert Operations |
| **`Q15`** | ⚠ Different | ⛔ **The premise is void.** *"FL3 does not produce on spools, it produces coreless oscillate coils."* |

⭐ **`Q10` is the answer the footage dispute was waiting for.** It supplies the **dimensional basis**
half that `[Questions.md §Q10]` explicitly declined to recommend on, because it was UA's to state.
Both parts land: **nominal** dimensions, and the **round-edge correction applies at FL1 output**
(because FL1 has no edger — consistent with `D-26` and with `Q28` below). He also points back at
`Wire Flattening Mathematical Calculation Formulas.docx`, already recorded as `D-43`.

⛔ **`Q15` invalidates its own question.** We asked how FL2 check-in guards a *spool* produced on a
hybrid FL3 run. If FL3 produces finished coils and never a spool, no such spool exists and there is
nothing to guard. **Check what else in the repo assumes an FL3-origin spool** before closing this —
the question was `Critical` and FL2 check-in was said to be blocked on it.

### 4.3 The machine-interface set — the biggest block of change

These were flagged in the workbook's own Read Me as *"all blocked on the same controls engineer and
best closed in a single session"*. He answered them all.

**`Q1` — roll gap verification.** ⚠ Different:

> *"We will have position feedback on all mill stands and edgers for both FL1 & FL2. We have auto
> position control on the 12" mill and FL2-S3 (6") stands via the gauging stands down stream. The
> edgers and FL2-S1/S2 will be fixed position. The feedback we will be given will be in relation to
> the mill stand screw down, correlating to the roll gap. **However this will not match the "product
> gauge"** as there is deflection, spread, roll diameter, and coefficient variables. The pass
> schedule will dictate roll gap and desired product output gauge i.e.(to get .025" product gauge,
> roll gap will be set to .22")"*

Readback exists everywhere, so our option 2 is buildable — **but the value read back is screw-down
position, not gauge**, so the comparison is roll gap against roll gap, never against product gauge.
⚠ **The pass schedule must therefore carry both numbers per stand.** That is a schema consequence,
not just a validation rule.

**`Q27` — line speed as setpoint or ceiling.** ⚠ Different — **neither**:

> *"While we will develop Recommended speeds for pass schedules based upon trial/run history, **we
> will not feed the line speed to the Opc from the machine application. Speeds shall be controlled
> via the machine HMI & programming.** The speed will be available as an OPC tag for retrieval
> purposes."*

⭐ **This deletes a write from the tag surface.** The safety consequence the question was raised for
disappears with it — an acknowledgement can no longer start a threading line at scheduled speed,
because acknowledgement no longer sends a speed at all. Speed becomes **read-only**.

**`Q28` — edge type push and edger signals.** ⚠ Different, and it supplies figures:

> *"Correct, there are only edgers on FL2/3. The edgers are of the roll type, NOT knives. The rolls
> have multiple grooves cut into them at various gauges, to accommodate different material
> thicknesses. The FL2/FL3 will have a position signal being that they have to be set to the required
> width. There is also a limit (max) allowable reduction allowed for each edger and they differ from
> one another. **E1 (between S1-S2) = .015" max reduction & E2 (between S2-S3) = .006" max
> reduction.**"*

Three answers in one: FL1 has no edger (confirming our reading of the fifth list as an omission),
**the blade-profile vocabulary question is void** — they are grooved rolls, not knives — and the
addressable signal is **position**, not profile. The two max-reduction limits are new engineering
constraints on the pass schedule calculation.

**`Q29` — FM2 address space on FL3.** ✅ Agree, and it confirms the harder case is not needed:

> *"Only two controllers are present, FL1/FL2. FL2 will be the owner and FL3 will use the FL2
> address."*

⚠ **We designed the FL3 push for two controllers deliberately** — *"that is the harder of the two
cases; building for it costs little now"*. The answer says one controller owns FM2, so the
per-controller batch and compensating clear are **insurance, not a requirement**. Keep or simplify
is now a cost call, not an open question. Commissioning test `C5` still needs the step that names
which controller answered.

**`Q21` — `LineState` vocabulary.** 🟡 Needs discussion:

> *"Why would we not follow the same protocols as the Z-Mills, where we do exactly these types of
> stops, jogs, "pauses", faults? Typically, machine output is Stop/Run. We would not to reset any
> data unless an operator performed a coil complete transaction, and then a spool checkout. Any
> movement above zero, would be a run flag no? Lets really discuss what's needed here."*

⚠ **This is a partial answer masquerading as a deferral.** It says two concrete things — the machine
output is **binary Stop/Run**, and **any movement above zero is Run** — which is the enumeration
question answered, if tersely. It conflicts with the 1 Sep answer recorded at `[Questions.md §Q21]`
that jog events fire on all three FL2 stands. **Jog may be a real event without being a distinct
`LineState` value.** Put that reconciliation in the discussion he is asking for.

**`Q32` — FM2 dancer modes.** ⚠ Different. The question was published flagged *"we may have this
wrong"*, and we were right to flag it:

> *"There are multiple dancers throughout both machines however only two contain the capability of
> tension mode and they are positioned on the finishing mill. Typical dancers are designed to sense
> tension and output a position signal signifying no tension (0) or high tension… The goal is to have
> close to no tension between all processes throughout the lines… As stated, the finish mill has
> tension mode, which I was not made aware of until very late as it was **secret addition to the
> project**. Tension mode is for heaver gauge materials and works as the Z-mills do. **This will be
> an operator adjusted value, but will need to be data logged.** The goal would be that we, via trial
> data established standard tension values, that can be used as setpoints when in tension mode. **The
> switching between modes can be done on the machine HMI.**"*

⭐ **Our recommendation was wrong and the flag was right.** Mode is **machine-side**, switched at the
HMI — so the read-only view we already built is correct and **no write surface is needed**. But the
answer adds a requirement we did not ask for: the operator-set tension value **must be data logged**.
That is a new persistence target with no home yet.

⚠ **The second engineering question inside `Q32` is not answered.** We asked whether applied tension
reducing roll separating force models something the equipment does not do. His answer — dancers sense
tension and the goal is near-zero tension, *except* in tension mode on the finishing mill — implies
the model applies **only in tension mode**, but he does not say so. **The calculated roll gap still
rides on this.**

### 4.4 Weights and measurement

**`Q30` and `Q33` get the same answer**, and it settles both:

> *"The finish weight is calculated by linear feet & cross sectional area as indicated in the formula
> document. **There are no available loadcells installed on the take-ups or payoffs.** Product OD will
> be calculated by engineering by way of an encoder that tracks footage, against the speed of the
> take-up. This is necessary in order to allow for correct positioning and speed settings if a stop
> occurs, and a run command is given. Without it, the machine would reset to zero and the take up
> speed would be wildly fast and cause a coil break. **The OD calculation will be available as an OPC
> tag.**"*

✅ **Our recommendation stands and is now unconditional** — completion weight is derived, not weighed,
because there is nothing to weigh with. The corroborating-reading fallback we offered is moot.
⚠ **But `Q33` is not fully answered:** we asked for the OD → remaining weight formula. He says OD is
*derived from footage*, which inverts the question — if OD comes from footage, then weight comes from
footage directly and OD is not an input to weight at all. **Confirm that reading before closing.**

⚠ **This also bears on `Q12`.** A payoff scale is exactly what he is separately arguing *for* (§4.5)
while confirming here that none exists today.

### 4.5 The four `Needs discussion`

| Q | Who it goes to | Substance already given |
|---|---|---|
| **`Q5`** cert traceability granularity | *"I would defer to Mick, Ryan B. & Fabian"* | ⭐ Not empty: *"continuous cast rod comes with a **Cast# which can be considered Lot#**. **I do not believe they use a heat number.** I would imagine that the cert would need the cast#(s) associated with the rod alpha(s)."* Plus a full ASTM B230/B800 content list |
| **`Q8`** certificate per coil / order / heat | *"I would defer to Mick, Ryan B. & Fabian"* | Nothing further |
| **`Q12`** partial-rod carry-forward + payoff scale | Bob S. and Shannon R., **Thursday** | ⭐ *"I agree with your concerns and **I am for the addition of a scale at the payoff of FL1** for the purpose of scaling in a partial or even scaling out a partial "return to stock"/"WIPREJ"."* The carry-forward design half is not separately dissented from |
| **`Q21`** `LineState` vocabulary | Controls session | See §4.3 — partially answered in substance |

⚠ **`Q5` half-answers itself.** *"They do not use a heat number"* removes one of the three
granularities the question offered. If there is no heat, the question reduces to coil versus lot,
and Cast# is the lot. **The deferral is about what must be printed, not about what exists.**

### 4.6 The rest

| Q | Verdict | Note |
|---|---|---|
| **`Q4`** skid labelling | ⚠ Different | *"Please forward to me the existing rules for review."* Plus ASTM B233 §14 marking clauses — manufacturer identity, alloy, size/temper/net weight, batch codes. **The question is returned, not answered** (§7) |
| **`Q6`** weld footage attribution | ✅ Agree | Footage-based split at the weld point |
| **`Q7`** max weld joints per coil | ✅ Agree | *"ASTM does not specify a limit, however customers may have one."* Confirms the configurable-defaulting-to-unlimited build |
| **`Q9`** max twist per foot | ✅ Agree | Treat as camber is treated |
| **`Q11`** per-pass scrap allowance | ✅ Agree | No figures supplied |
| **`Q13`** settings on mid-run checkout | ✅ Agree | The proposed behaviour is adopted as written |
| **`Q17`** spool state machine | ⚠ Different | See §5.3 |
| **`Q18`** customer min/max weight source | ✅ Agree | Both parts, including the over-target state |
| **`Q23`** mandatory notes on failed inspection | ✅ Agree | |
| **`Q24`** out-of-sequence override at check-in | ✅ Agree | Both entry points, shared credential path |
| **`Q25`** unscheduled material | ✅ Agree | *"This works, especially given that the same override would be required to push a pass schedule for a non existent order."* — extends the override to a second case |
| **`Q26`** monitor resolution | ⚠ Different | **1920 × 1080.** Already closed 7 Sep — corroboration only |
| **`Q31`** no-weld wire-break disposition | ✅ Agree | ⚠ **The frequency question is not answered**, and the recommendation made sizing conditional on it |
| **`Q16`** warn on missing pass schedule | ✅ Agree | Warn, do not block |
| **`Q19`** 75/90/100 ladder at the coil take-up | ✅ Agree | ⛔ But see §5.1 |
| **`Q20`** completion alert to supervisor | ✅ Agree | Mirror the unacknowledged 100 % only |

---

## 5. What this changes in the repository

### 5.1 ⛔ Two answers contradict something already written — flagged, NOT actioned

**(a) `Q19` versus `FR-120`.** Tim, on a question about the notification ladder:

> *"The FL2 does have a gauge stand that tracks thickness and width throughout the production run."*

The repository asserts the opposite in **six places**:

| Site | What it says |
|---|---|
| [`BusinessRules.md`](../../10-requirements/BusinessRules.md) L22 | *"FL2 standalone broadcasts `null` live gauge and width"* |
| [`BusinessRequirements.md`](../../10-requirements/BusinessRequirements.md) `FR-120` | historical profile, not a live trace |
| [`BusinessRequirements.md`](../../10-requirements/BusinessRequirements.md) `FR-137` | *"For FL2, gauge and width shall come from the pass schedule / order, not live measurement"* |
| [`SignalR.md`](../../20-architecture/SignalR.md) L79 | `FR-120` cited as a constraint on the broadcast |
| [`EndToEndProcess.md`](../../10-requirements/EndToEndProcess.md) L314 | *"gauge profile is available when material is checked into FL2, not live"* |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) L138 | the line-comparison table |

and [`CLAUDE.md`](../../CLAUDE.md) repeats it in the domain screen.

⛔ **Nothing is edited.** The statement was made in passing, on a question about *notifications*.

> ⚠ **This section first said the two readings were "equally consistent". They are not, and that
> was corrected the same day.** What follows is the re-weighted reading.

⭐ **All six sites restate one assumption of ours.** They trace to **`A3`** in
[`[PLC] §14 Assumptions`](../../20-architecture/PLCTagSpecification.md) — *"Gauge and width are
measured live on FL1 and FL3. **FL2 has no live measurement**"* — and a search of this folder finds
**no client source stating it, ever**. Six documents agreeing with each other are six restatements
of one unconfirmed assumption.

⛔ **`A2`, the row directly above it, was falsified by this same mail.** It asserts load cells on
both payoffs and both take-ups; `Q30` says *"there are no available loadcells installed on the
take-ups or payoffs"*. An adjacent assumption in the same table has just been shown false.

⭐ **`Q1` is a second and stronger contradiction.** *"We have auto position control on the 12″ mill
and **FL2-S3 (6″) stands via the gauging stands down stream**"* describes a **closed
automatic-gauge-control loop on FL2** — a stand cannot hold gauge automatically from a measurement
nobody is taking continuously. It answers about the equipment, in reply to a different question, so
it corroborates `Q19` independently.

**So the question splits, and only half of it is open:**

| | Status |
|---|---|
| Does the stand **measure** live? | **Almost certainly yes** — two independent client statements |
| Is the reading **exposed to us** as an OPC tag, and how often? | **Genuinely open**, and far more answerable |

**Ask the sharper question:** *the gauging stands that drive FL2-S3's automatic position control —
are their thickness and width readings available to us as OPC tags during a run, and at what update
rate?* ⚠ **A yes is a tag-surface addition, not merely a requirement flip** — `[PLC §2]` records
that *"FL2 measures nothing live, so **FL2 has no gauge or width tag at all**"*, so it means new
paths, a bound-map change, and a payload that currently sends `null`.

**Verdict: `A3` is probably wrong and `FR-120` probably follows it down — but this is inference from
two side-remarks, so nothing is edited and `G120` carries it.**

**(b) `Q22` versus the `AlloyProperty` grain.** Our recommendation said **"per-alloy is sufficient
granularity unless Process Engineering states that tolerance varies by vendor or by nominal size"**.
He has now stated exactly that, for both:

> *"The tolerances are defined by vendor for the incoming rod, and also vary by size. ASTM standard
> applies tolerances to two groups, .375" - .500" and .501" - 1.000". These are some tolerance
> supplied to us by two vendors. i.e. **vendor A = +/- .010" diameter and +/- .015" ovality. Vendor B
> = +/- .020" diameter and .030" ovality.** ASTM B233 specification: **.375"-.500" +/- .020" diameter
> & .030" ovality; .501"-1.000" +/- .025" diameter & .035" ovality.** All vendors will at a minimum
> adhere to the ASTM B233 standard but will run tighter tolerances themselves like Vendor A above."*

⛔ **The escape clause fired, so the recommendation is withdrawn by its own terms.** The min/max
columns need a **vendor × size-band** grain, not a per-alloy one. That is a real change in
[`FlatWire_DDL_01_Lookup.sql`](../../30-database/sql/FlatWire_DDL_01_Lookup.sql), and it changes what
the pre-check-in and check-in validations look up — they now need the rod's **vendor** in hand at
validation time, which the current flow may not carry.

⚠ **And the values have finally arrived** — the ASTM floor for both size bands, plus two named
vendors. `[Questions.md §Q22]` says *"No values are to be seeded until the e-mail arrives"* and
records the question as a **current blocker on Phase 4**. The e-mail has arrived. **But do not seed
against the old shape** — seeding per-alloy values that are actually per-vendor would be worse than
the empty table.

### 5.2 ⚠ The multi-order-spool reversal — a second voice, but the same voice

`Q70` repeats the 3 Sep position: no multiple orders on one spool, stop the line and force a spool
change. [`ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`](ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md)
§4.1 held five items — `OI-119`, `OI-123`, `OI-124`, `G48`, `Q43` — as *"premise contradicted,
pending ratification"*, because the 20 Aug basis was a **multi-voice call** and the reversal was
**one voice by e-mail**.

⛔ **This does not ratify it.** It is the same person saying the same thing a second time, in writing,
six days later. The bar `ClientCall_2026-08-24_SyncPlan.md` §3.1 set for `D1` was **Bob and Tim
agreeing on the record** — not one person repeating themselves. Two independent statements from one
voice is stronger evidence than one, and it is still not the bar.

✅ **What it does change:** the position is now unambiguous and durable enough to plan against. Note
it on all five items as *"restated 9 Sep, still unratified"* and keep the ratification action open.

### 5.3 ⚠ `Q17` reopens something the workbook listed as already agreed

Tim accepts the `Held` view state, then adds:

> *"however we had requested that FL2 have a precheckin staging ability similar to that of FL1. **Bob
> S. had explained why this was necessary** to reduce downtime in the event of an incorrectly selected
> spool. The precheckin (staged) function would act as a validation prior to actually checkin,
> preventing lost time locating a correct spool."*

The `Already agreed` column of that very row says *"the operator-visible vocabulary is 'Ready for
FL2' and 'Checked in', **with no staging status**"*, on the stated ground that FL2 has no space to
stage material.

⚠ **This is a scope addition, and it cites Bob S. as its author** — so unlike §5.2 it is *not* a
single voice. It needs to go back as a direct question: **does FL2 pre-check-in mean a physical
staging area, or a validation step with no material movement?** The second is cheap and consistent
with everything else; the first contradicts the "no space to stage" premise the current design rests
on.

### 5.4 The clean closes

Seventeen questions answered `Agree with recommendation`. The **eleven with no qualifying text**
closed outright and **have moved** to [`Decisions.md`](../../90-registers/Decisions.md) — a decided
question moves, it does not change state in place:

`Q6` · `Q9` · `Q11` · `Q13` · `Q14` · `Q16` · `Q18` · `Q20` · `Q23` · `Q24` · `Q31`.

**Measured before and after, not inherited:** `Questions.md` **73 → 62** body entries and
**60 → 49** index rows; `Decisions.md` **35 → 46** body and **28 → 39** indexed, window extended to
**Sep 8**. ➕ **`Q6` and `Q11` opened a new Section 9 — Certification, Yield and Traceability**,
because neither had a home among Sections 1–8 and filing them under quality or scheduling would
have buried them. **Nothing was renumbered to make room.**

⚠ **Four of the eleven were on the *partly answered* list and have now left it** — `Q13`, `Q18`,
`Q23`, `Q24` — so that paragraph in `Questions.md` reads **four**, not eight, and the matching
paragraph in `Decisions.md` reads **six**, not ten.

⚠ **`Q31` moved with a caveat**: the frequency question inside it was not answered, and the
recommendation made the build size conditional on the answer. The residual is stated on the entry.

⚠ **`FW-166` came off `Q6`.** It was `blocked_by: [G26, OI-59, Q6]`; `Q6` is answered, so it now
reads `[G26, OI-59]` and stays blocked on the other two — `OI-59`'s **rework-weld** half is the
part still open, its footage-split half being exactly what `Q6` just settled.

The **six with qualifying text did NOT move** — `Q2`, `Q3`, `Q7`, `Q19`, `Q25`, `Q29`. Each has the
answer recorded on its entry, and **`Q19` must not move at all** (§5.1). **`Q29`'s** answer
materially simplifies the design, and its entry says so.

### 5.5 New reference data — each needs one home and one citation

Nothing below exists in the repository today. **A fact is asserted in one document and cited
everywhere else** — so each of these gets exactly one owner:

| Figure | Source | Candidate owner |
|---|---|---|
| Edger max reduction **E1 0.015″**, **E2 0.006″** | `Q28` | Pass schedule calculation — it constrains draft per edger |
| ASTM B233 bands **.375–.500 → ±.020 dia / .030 oval**; **.501–1.000 → ±.025 / .035**; Vendor A **±.010 / .015**; Vendor B **±.020 / .030** | `Q22` | Reference data, once §5.1(b)'s grain is settled |
| Position feedback on **all** FL1/FL2 stands and edgers; auto position control **only** FM1 12″ and FM2-S3; edgers and FM2-S1/S2 **fixed position** | `Q1` | `[PLC]` for the tags, architecture for the capability statement |
| Roll gap ≠ product gauge; the pass schedule dictates **both** (worked example: 0.025″ product ⇒ 0.22″ gap) | `Q1` | Pass schedule schema — this is a second column per stand |
| **No load cells** on take-ups or payoffs | `Q30` | The completion transaction |
| Coil **OD derived from encoder footage vs take-up speed**, exposed as an OPC tag | `Q30`, `Q33` | `[PLC]` |
| Operator-set **tension value must be data logged** | `Q32` | New persistence target — no home today |
| Continuous cast rod carries a **Cast#**, usable as Lot#; **no heat number** | `Q5` | Traceability model |

### 5.6 PLC tag surface — one write removed, one read added

**`[PLC]` owns every tag path string; do not write one anywhere else.**

- ⛔ **Remove the line-speed write.** `Q27`: speed is controlled at the HMI and is not sent from the
  application. It becomes a **read** tag.
- ➕ **Add the coil-OD read.** `Q30` / `Q33`: engineering will expose the calculated OD as an OPC tag.
- ➕ **Edger position** is addressable on FL2/FL3 — `Q28` answers the *"we have found none"* half.
  **Blade profile is not a tag** and never will be; the edgers are grooved rolls.
- ✅ **Dancer elements stay read-only** — `Q32` confirms the design decision that authored them that
  way. No write surface is needed.

---

## 6. Where the binding statements go

| Register | What landed |
|---|---|
| [`Questions.md`](../../90-registers/Questions.md) | **32 annotations** (all but `Q26`); **11 entries moved out**; the 21 that stay carry the client's answer in the body, per the *partly answered* convention |
| [`Decisions.md`](../../90-registers/Decisions.md) | **26 annotations** — 25 confirmations plus `Q26`'s corroboration; the 5 corrections **amend** `Q67`, `Q68`, `Q70`, `Q72`, `Q85` rather than replacing them; **11 entries received**, two of them opening Section 9 |
| [`Gaps.md`](../../90-registers/Gaps.md) | **`G120`** the `Q19` / `FR-120` contradiction · **`G121`** the `Q22` vendor × size grain · **`G122`** the `Questions.md` index drift measured during the pass |
| [`CHANGELOG.md`](../../CHANGELOG.md) | One Repository-wide row. Never a per-document change log |
| [`FW-166`](../../40-backend/tasks/FW-166.md) | Unblocked from `Q6` |

**58 annotations in total, one per workbook row, verified present after the moves.**

⚠ **Never renumber.** `Q##` ids are permanent, and a `Q##` appears in exactly one of the two
register files — **verified: no id is in both, and none is duplicated within either.**

⚠ **Every count above was measured before and after, not inherited** — three counts in
`Questions.md` had drifted before, and `G122` records that **two of them still have**: the Quick
Reference is 14 rows short of the body (`Q96`–`Q109`) and carries one phantom (`Q59`). **The move
neither caused nor worsened that** — it measured identically on both sides of the change, because
only indexed entries were moved.

---

## 7. Still owed — and by whom

Tim named five in the mail body and a sixth is implicit. All are **actions, not answers**:

| # | Item | Owner | Status per Tim |
|---|---|---|---|
| 1 | **Existing skid label rules** — for `Q4`. ⚠ **He is asking us for them**, so the action is ours first, his second | Us → Tim | *"Need Existing Skid Label Rules for review"* |
| 2 | **`Q5`** — whether heat must be printed | Mick, Ryan B., Fabian | *"Need Technical Consult"* |
| 3 | **`Q8`** — whether any welding wire customer contractually requires per-coil | Mick, Ryan B., Fabian | *"Need Technical Consult"* |
| 4 | **`Q12`** — the payoff scale | Tim with Bob S. and Shannon R. | *"report on Thursday"* — **10 Sep 2026** |
| 5 | **`Q79`** — the mill stop procedure document | Tim | *"Need to review a current document and then retool for this process"* |
| 6 | **`Q85`** — per-stand maximum roll force and mill stiffness | Engineering | *"Need engineering consult"* |

Not named by him, but owed all the same:

| # | Item | Why |
|---|---|---|
| 7 | **`Q66`** line speed figures | `Q67` is explicitly suspended until the trial produces them |
| 8 | **`Q65`** — answer his *"Check point = SPC?"* | A confirmed decision he is not certain of the terms of |
| 9 | **`Q22`** — confirm the grain before seeding | The values arrived; the shape they go into did not survive them |
| 10 | **`Q19`** — the one-sentence live-gauge question | §5.1(a) |
| 11 | **`Q17`** — physical staging or validation step | §5.3, and Bob S. is cited as its author |
| 12 | **`Q31`** — how often a no-weld wire break happens | The recommendation made sizing conditional on it |
| 13 | **`Q32`** — does the tension model apply outside tension mode | The calculated roll gap depends on it |
| 14 | **`Q33`** — confirm OD is not an input to weight | His answer inverts the question |

---

## 8. Attachment

`Copy of FlatWire_ClientQuestions (002).xlsx` — 56,878 bytes, three sheets:

| Sheet | Rows | Content |
|---|---|---|
| `Read Me` | 34 | Our instructions, unaltered. Records the priority split as **Critical 5 · High 25 · Medium 3** |
| `Decisions to Confirm` | 25 data rows | Columns `A`–`H` ours, `I`–`L` his (`Confirmed?`, correction, name, date) |
| `Open Questions` | 33 data rows | Columns `A`–`M` ours, `N`–`Q` his (`Your response`, correction, name, date) |

The workbook is generated from [`tools/deliverables/ClientQuestionsContent.md`](../../tools/deliverables/ClientQuestionsContent.md).

**His copy was diffed cell-by-cell against the 12 Aug outbound.** The two files were compared across
all three sheets — 921 cells outbound, 922 returned — and the result is:

| | Decisions | Open Questions | Read Me |
|---|---|---|---|
| Cells in **our** columns that differ | **8** | **7** | **0** |
| Cells added or removed | 0 | **1 added** | 0 |

⚠ **All 15 differences are cosmetic, and none changes a question's meaning.** They are Excel's US
autocorrect running over our text: `authorised`→`authorized` (`C6`, `E16`), `finalised`→`finalized`
(`L11`, `L12`), `authorisation`→`authorization` (`J25`), `optimisation`→`optimization` (`K27`), and
`lb`→`lb.` throughout the weight figures (`E14`, `E17`, `D21`, `E21`, `H21` on both sheets, `E23`,
`G15`). One is a spellchecker making it worse — `queryable`→**`query able`** in `J12`, the `Q5`
recommendation.

➕ **One stray cell was added: `R21` = `8`.** Column `R` is outside both the question columns (`A`–`M`)
and the answer columns (`N`–`Q`), and row 21 is `Q18`. **It is a stray keystroke, not an answer** —
`Q18`'s four answer cells are all populated normally. Do not read it as data.

**So the answers can be read against the questions as issued.** No substantive reconciliation is
needed, but if the workbook is ever regenerated and re-diffed, expect these 15 to reappear as noise.

---

## Related Documents

- [`ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`](ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md) — same thread, the `A1` answers, and the source of the *"never returned"* line this closes
- [`ClientEmail_2026-09-02_PassCalculatorFormulas_SyncPlan.md`](ClientEmail_2026-09-02_PassCalculatorFormulas_SyncPlan.md) — `D-43`, the formula document `Q10` points back to
- [`ClientCall_2026-08-24_SyncPlan.md`](ClientCall_2026-08-24_SyncPlan.md) — §3.1, the ratification bar §5.2 measures against
- [`Questions.md`](../../90-registers/Questions.md) · [`Decisions.md`](../../90-registers/Decisions.md) — where the binding statements land
