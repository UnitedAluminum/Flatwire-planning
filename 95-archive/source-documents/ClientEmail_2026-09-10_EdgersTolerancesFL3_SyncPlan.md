# Client e-mail — 10 September 2026 — the edger grid answered, four edge profiles, and tolerance data at a fourth grain

**Source:** `RE: New Flat Wire Machine : Impact on .Net Applications` — Tim O'Brien (UA) to Yogender
Punia, Srikanth Prabhala, Bob Scott, Shannon Riotte; cc DG UA DEV.
**Sent:** Thu 10 Sep 2026 **10:43:54 UTC**. **Analysed:** 10 Sep 2026.
**Attachments:** 21 — all inline, **and not one of them is new**. See §7.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §5.

⚠ **Not to be confused with the two earlier ledgers on this same thread.** All three carry the
subject `RE: New Flat Wire Machine : Impact on .Net Applications`:

| Ledger | Sent | Direction | Subject matter |
|---|---|---|---|
| [`ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md`](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) | 31 Aug 19:06 UTC | UA → us | The four Machines Application tabs, as pictured |
| [`ClientEmail_2026-09-03_Tooling_SyncPlan.md`](ClientEmail_2026-09-03_Tooling_SyncPlan.md) | 3 Sep 11:23 UTC | UA → us | Straighteners, mill rolls, what Tooling Inventory holds |
| **This file** | **10 Sep 10:43 UTC** | **UA → us** | **The edger grid's five silences, the edge-profile vocabulary, dimensional tolerances, FL3** |

**This message is the fourth in the thread and only its top post is new.** It answers **Yogender
Punia's 8 Sep 06:27 EDT** question list — Parts 1, 2, 3 and 5 — with **27 inline
`[O'Brien, Timothy]` annotations. It does not answer Honey Sachdeva's 4 Sep 16:45 list at all**; Tim
replied over the top of it. See §6.

⚠ **Yogender's list jumps `Part 3` → `Part 5`.** There is no Part 4 in the message as sent. No
answer is missing as a result — every question present was answered — but whether a Part 4 was
intended and dropped is worth one line of confirmation.

---

## 1. What this closes

**This is the send-back returning on three positions the repository took deliberately and marked
"do not fix — a send-back is what changes them".**

| Held open | Status after this message |
|---|---|
| **`Q95`** — five things the edger Tooling Inventory grid does not say | ✅ **All five answered.** Four outright, one (the serial) partially |
| **`Q94`** legs 2 and 3 — two FL3 Setup/Handling rows that contradict each other | ✅ **Both answered**, and they turn out to have **one** root cause. Leg 1 (crew size) is untouched |
| **`G104`** — `ToolingInventoryEdger` has no natural key | ✅ **Answered** — set numbers become meaningful and unique |
| **`Q46`** — mandrel / core diameter at FL1: selected, fixed, or read? | ✅ **Closes on the recommendation.** ⚠ `Q46` was **not** among the 33 answered on 9 Sep — this is its first answer |
| **`G76`** — edge type is `Round`/`Square` in the database and `Round Edge`/`Flat Edge` on the order screen | ✅ **Both halves answered** — the vocabulary, and where it is entered |
| **`A3`** — the PLC technical review | ⭐ **First movement since 6 Aug 2026.** Reviewed, marked up, forwarded to Automation Engineering. **Still open** |

**And from the 3 Sep ledger's §6 *"still owed by the client"* list — four of seven close:**

| Row | Item | Status |
|---|---|---|
| 1 | The roll-set grid columns (`Q92`) | ⛔ **Still not supplied** — *"once we determine best approach for identifying"* |
| **2** | One tool option or two — capstan versus mill rolls | ✅ **Answered** — lump them together |
| **3** | What *"refurbished"* means against the edger's `In Grinding` | ✅ **Answered** — one vocabulary, covering in-house and outsourced |
| **4** | `Machine Name` for a capstan roll | ✅ **Answered** — `FL1`. ⚠ The location half contradicts itself (§4.6) |
| 5 | The Speed tab — the fourth `A12` leg | ⛔ **Unmentioned in a FOURTH consecutive message.** Do not mark it closed |
| 6 | The `.134` / `.184` straightener range discrepancy | ⛔ **Still not addressed** |
| **7** | `OI-77`'s edger-blade-profile half, and the regrind turnaround | ✅ **The profile half is answered.** The regrind turnaround and in-house-or-out are still open |

⛔ **`OI-143` also goes unanswered for a third time** — *"is `EDGE` an SMP process step in its own
right, or an attribute of the flatten it sits inside?"*, asked 1 Sep and re-sent 3 Sep.

**No new `A##` id is minted here.** `ClientEmail_*` ledgers consume call-ledger ids; they do not
mint them.

---

## 2. The 27 answers, in Tim's words

### 2.1 Part 1 — outstanding since July

| # | Yogender asked | Tim answered |
|---|---|---|
| 1 | Spool OD → weight formula | *"Answered in detail in the 25 decisions/36 questions doc. **Spool OD will be calculated through the OIT and will be available as an OPC tag.**"* |
| 2 | Rod footage formula and ± ft tolerance | *"Formula was supplied in the Mathematical Calculation Formulas doc. As for tolerance, **are you asking for the tolerance for the linear footage calculations?**"* — plus a re-paste of the `Linear Feet Wire/Rod` formula image |
| 3 | Dimensional tolerances — upper and lower limits for gauge, width, diameter and ovality | *"Some of this was answered in the 25 decisions/36 questions document, however I will expand here as well: **ASTM B211 / B211M** (Standard Specification for Aluminum and Aluminum-Alloy Rolled or Cold-Finished Bar, Rod, and Wire)"* — then the four tables transcribed at §3.1 |

⚠ **Answer 1's claim does not hold.** The 9 Sep workbook ledger records no spool-OD content at all.
The answer given *here* is new information, and it **contradicts `FR-271`** — see §4.1.

⚠ **Answer 2's formula is not new either.** It is `F1`, already transcribed at
[`ClientEmail_2026-09-02_PassCalculatorFormulas_SyncPlan.md`](ClientEmail_2026-09-02_PassCalculatorFormulas_SyncPlan.md)
§3 and in `tools/deliverables/build_formula_review_xlsx.py`. His legend confirms
`(r) = Radius of the wire rod`, which is the correct reading **for F1**; `Q93`'s disputed `r`
concerns `F10`/`F14`, so **`Q93` is unchanged**.

### 2.2 Part 2 — blocking work in progress

| Yogender asked | Tim answered |
|---|---|
| PLC technical review — *"pending for quite some time, and this week's coding activities depend on its completion"* | *"**I have reviewed and marked up the PLC tag doc. and forwarded to Automation Engineering.** I will push it along once they have completed their portions."* |

⭐ **This is `A3` moving for the first time since 6 Aug 2026** — recorded *"overdue"* and *"three
weeks unmoved"* on the 20 and 24 Aug call ledgers, then unmentioned in three client messages. It
still gates `PLC-Q02`, `PLC-Q04` and `PLC-Q05`, all **Critical** on `[PLC]`'s sign-off sheet, plus
the Phase-4 tag push and commissioning tests `C1` / `C11`.

### 2.3 Part 3a — edge type and edger sets

| # | Yogender asked | Tim answered |
|---|---|---|
| 1 | Which is correct: Round / Square, or Round Edge / Flat Edge? | ⭐ *"**Natural Round Edge (no edging), Full Round Edge, Square Edge, Broken Edge**"* |
| 2 | Is that the complete list, or is there an edge-profile library? | *"Yes, there are additional edge types, see above comment."* |
| 3 | Where is edge profile entered? It does not appear on the Tooling screen | ⭐ *"**Edge type is selected via the Quotes & Orders Application as it is dictated by the customer at point of order.** That edge type **must carry over to the order specifications so that the pass-schedule can be generated accordingly**."* |
| 4 | Is an edger set ground for a single profile, or can one set produce both? | *"To keep things clean, **a set will NOT share different profiles**."* |
| 5 | What actually distinguishes one edger set from another? | *"This was an oversight on my part, **edger sets are distinguished from one another by gauge band and profile (edge type)**"* |
| 5a | All three sets share OD, ID, Roll Qty, Min OD and STD Removal | *"Yes, **physically the rolls are identical in every attribute, except what is cut into them**."* |
| 5b | Is gauge the only differentiator — or profile, or physical position? | *"To differentiate between the sets, we will use gauge range & edge type. **Positioning is determined by edger entry gauge.** If FL2.S1 output gauge is .065", and Square, then the appropriate edge set must be selected that falls within the gauge range and edge type. If FL2.S2 had an output gauge of .065" and square edge, it would need the exact same edge set allocated."* |
| 6 | Is the profile defined per set or per groove? | *"**Per set**, depending on groove height, there could be **1-5+ grooves cut into a roll**. All groves would have the same profile, just **different grove heights**."* |
| 7 | What does `Location` record? | *"**Great point!** We should probably record **position allocated in the line as E1 or E2**. **E1 = Edger located between S1-S2 & E2 = Edger located between S2-S3**."* |
| 8 | What is the difference between Active, In Service, In Grinding? | *"I followed the same provisions we are using currently, meaning that **"In Grinding" = being resurfaced either roll grinding or outsourced**, **"In Service = Installed in the machine either at FL2.E1 or FL2.E2**, and **"Active" meaning available to allocate** or not being used or resurfaced."* |
| 9 | Is a worn-out set retired, or removed? | *"A set that has worn out after its last available grind shall be taken out of service and **marked as "In Active"**."* |
| 10 | Is a set identified by Set Number + P/N? Is A / B / C unique across tool types? | ⚠ *"**We may have to take an entirely different approach to this given the variables. We may need to track as individual rolls, and have assigned set numbers, with profile and gauge range identifiers. I am open to suggestions and alternatives, lets discuss.**"* — with the table at §3.3 |
| 11 | Is there a serial number for an edger set? | *"The edgers are **designed by UA and then sent out for production**, where the other tooling is purchased "off the shelf". This is not to say that we can assign a SN, however **I would need to verify with engineering**."* |
| 12 | Does `STD Removal From OD .100` mean per grind? | ⛔ *"**This was an arbitrary number that I entered.** I will need to verify with engineering what the actual standard would be. **This could also be variable depending on the groove width range.**"* |
| 13 | Are grooves identified by number / edge profile, or only by gauge? | *"As mentioned above, we will need to **identify the rolls by groove gauge range and profile**. **The gauge ranges I gave are again arbitrary**, given that rolls would be cut based upon a tight range of finished gauge products being produced."* |

### 2.4 Part 3b — roll sets

| # | Yogender asked | Tim answered |
|---|---|---|
| 1 | Could you provide the roll-set grid as a screenshot? | ⛔ *"Yes, **I will put something together once we determine best approach for identifying**."* |
| 2 | Are capstan rolls the same *Choose Tool* option as mill rolls? | *"While they are not the same, **we could lump them in with the mill rolls to streamline the approach**."* |
| 3 | What should `Machine Name` contain for a capstan roll? | ⚠ *"**FL1 would be the asset** they are associated with and **DB1/DB2 would be the location** as 12" rolls would belong to FL1 but would be **located at FM1**."* |

### 2.5 Part 5 — lines and equipment

| # | Yogender asked | Tim answered |
|---|---|---|
| a1 | Is the spool core diameter fixed across all spools, or does it vary? | *"**The diameter is fixed for the current application**, however we will be looking to expand FL1 into other product lines which could warrant a collapsable spool(s) with different core diameters."* |
| b1 | Does FL3 use one pass schedule or two? | *"**One schedule.**"* |
| b2 | Is FL3 represented as its own line, or as FL1 and FL2 linked? | ⚠ *"This one is tough, **I would like to see what Stephen has to say** on the matter as it directly affects him."* |
| b3-i | FL3's `H1AA` includes `SPC: Takeup-1`, which FL3 does not wind to | ⭐ *"**This is my mistake, it should have contained SPC FL1.FM1 not Takeup1.**"* |
| b3-ii | FL1's `H1B` contains `SPC: FL1-Stand 1`. FL3's does not | ⭐ *"**FL2 and FL3 should have SPC at FL2.FM2 for H1B**, SPC for FL3 at FL1.FM1 under H1B **is not necessary as the stop is has been completed and these dimensions would not represent final gauge/width**. SPC for that position would only be important while setting up the machine for the production run."* |

⚠ **Answer b2 contradicts his own answer of two days earlier.** On **8 Sep**, on the returned
questions workbook, he wrote of `Q2`: *"I agree, a single FL3 booking should reserve FL1/2
capacities."* ⛔ **The deferral to Stephen does not supersede that agreement** — see §4.7.

---

## 3. The new reference data

### 3.1 Dimensional tolerances — four product forms, fifteen bands

⛔ **Recorded here, seeded nowhere.** See §4.2 for why.

**(a) Wire rod, as received** — cited to **ASTM B211 / B211M**

| Diameter | Tolerance | Ovality |
|---|---|---|
| `.375"` – `.500"` | ± `.020"` | ± `.030"` |

> *"Note that this is the **max**, and actual tolerances are vendor specific and tolerances can be
> much tighter depending on vendor capabilities. I would also note that per ASTM B211/211M &
> **ANSI H35.2**, Flattened wire with a rolled flat edge falls under the category of **Rectangular
> wire & bar**, and is **diameter, temper, & alloy specific**."*

**(b) Drawn wire**

| Diameter | Diameter tol. | Ovality tol. |
|---|---|---|
| `.015"` – `.035"` | ± `.0005"` | ± `.001"` |
| `.036"` – `.064"` | ± `.001"` | ± `.002"` |
| `.065"` – `.374"` | ± `.0015"` | ± `.003"` |

**(c) Flat wire, round edges**

| Thickness | Tol. | | Width | Tol. |
|---|---|---|---|---|
| `.018"` – `.020"` | ± `.001"` | | `.500"` – `.625"` | ± `.0025"` |
| `.021"` – `.060"` | ± `.0015"` | | `.626"` – `1.500"` | ± `.004"` |
| `.061"` – `.080"` | ± `.002"` | | `1.501"` – `4.750"` | ± `.006"` |

**(d) Flat wire, rolled flat edge (square edges)** — *"falls under the Rectangular Wire Standard"*

| Thickness | Tol. | | Width — **all tempers except `O`, `F` and `H112`** | Tol. |
|---|---|---|---|---|
| `.018"` – `.020"` | ± `.001"` | | `< .500"` | ± `.0015"` |
| `.021"` – `.060"` | ± `.0015"` | | `.501"` – `1.000"` | ± `.002"` |
| `.061"` – `.080"` | ± `.002"` | | `1.001"` – `2.000"` | ± `.0025"` |

⚠ **Three observations that decide where this can live.**

1. ⛔ **The standard cited conflicts with the one already on record.** On 8 Sep, for the same rod
   band, he cited **ASTM B233**: *".375"-.500" +/- .020" diameter & .030" ovality; .501"-1.000" +/-
   .025" diameter & .035" ovality."* **The numbers for the first band are identical; the standard
   number is not, and the second band is absent here.** `B211`/`B211M` and `ANSI H35.2` appear
   **nowhere** in the repository; `B233` is cited in twelve live places.
2. **The grain is now product form × size band × edge profile × temper.** `G121` had already
   recorded that rod tolerance is per **vendor** and per **size band**, which alone defeats
   `AlloyProperty`'s alloy grain. This is wider again.
3. ⭐ **These are *published bands*, which is what `OI-57` has been asking for** — and the
   square-edge width table is **temper-qualified**, exactly the dimension `OI-57` names.

### 3.2 The edge-profile vocabulary — four values, and only three tools

| Profile | Needs an edger set? |
|---|---|
| **`Natural Round Edge`** | ⛔ **No — it means "no edging"** |
| **`Full Round Edge`** | Yes |
| **`Square Edge`** | Yes |
| **`Broken Edge`** | Yes |

⭐ **His own tolerance heading settles `G76`'s other half.** §3.1(d) reads *"Flat**t** Wire Rolled
Flat Edge **(Square Edges)**"* — so the order screen's `Flat Edge` and the database's `Square`
**are the same profile**, and `G76`'s *"`Flat` is not `Square`"* concern dissolves. The canonical
name is **`Square Edge`**.

⚠ **`Bevel edge` is still not accounted for.** Dashboard 9 / 9A offer it; `OI-05` asks whether it is
a fourth vocabulary or dead UI. **It is not in this list, and `Broken Edge` is** — whether they are
the same thing is §6 item 3.

### 3.3 The roll-level table, as sent

| Set No | Roll No. | Edge Type | Gauge Range |
|---|---|---|---|
| `400-S` | `R1-0001-S` | Square | `035–.045` |
| `400-S` | `R1-0002-S` | Square | `035–.045` |
| `401-S` | `R2-0001-S` | Square | `.015-.025` |
| `401-S` | `R2-0002-S` | Square | `.015-.025` |
| `402-S` | `R3-0001-S` | Square | `.065-.075` |
| `402-S` | `R3-0002-S` | Square | `.065-.075` |
| `400-R` | `R1-0001-R` | Full Round | `035–.045` |
| `400-R` | `R1-0002-R` | Full Round | `035–.045` |
| **`400-B`** | `R2-0001-B` | Broken | `.015-.025` |
| **`400-B`** | `R2-0002-B` | Broken | `.015-.025` |

⛔ **The last two rows are internally inconsistent.** Read across the `-S` rows, the numeric stem
encodes the **gauge band** — `400` = `.035–.045`, `401` = `.015–.025`, `402` = `.065–.075` — and the
suffix encodes the **profile**. The `Broken` rows carry stem `400` with roll prefix `R2` and gauge
`.015-.025`, both of which say `401`. **Either they should read `401-B`, or the stem encodes nothing
and the whole key proposal collapses.** §6 item 2.

⚠ Three rows are also missing a leading decimal point (`035–.045` for `.035–.045`) — a transcription
slip, not a data question. **No `Natural Round Edge` row appears**, which is consistent with §3.2.

---

## 4. What this changes in the repository

### 4.1 ⛔ Spool OD now has a third stated source, and it contradicts a live requirement

**`FR-271`** says Spool OD is *"read-only, **auto-populated from Rod Buildup and Spool ID**"*, and
`TC-338` asserts *"Change Rod Buildup → Spool OD recalculates"*. No formula for that derivation
exists anywhere, and Rod Buildup has no unit (`RA-Q42`, `RA-AMB16`, `CL-37`).

Tim now says it *"will be calculated through the **OIT** and will be available as an **OPC tag**"*.

⚠ **And it is a *second* OD read, not the one already in flight.** `Q33`, answered 8 Sep, and
`FW-N25` add a **coil** OD for FL2, derived by engineering from encoder footage against take-up
speed. Tim's is **spool** OD at FL1's **Takeup-1** — a different measurement in a different place.
`[PLC]` v1.3 publishes **no** OD, spool-diameter or take-up-diameter tag at all, and states that a
take-up *weight* tag *"will not"* exist.

⚠ **"OIT" is undefined in this repository.** Presumed Operator Interface Terminal; confirm.

### 4.2 The tolerance values cannot be seeded, and that is `G121`'s point

`G121` — *"rod tolerance is defined by vendor and by size, and `AlloyProperty` has only an alloy
grain"* — already made `Q22` **a worse Phase-4 blocker than when the values were missing**, because
seeding at the wrong grain is wrong data rather than absent data. `70-testing/plan/test-plan.md`
carries it as blocker **`CL-05`** with `SC-011` and `SC-012` **Not Testable**.

**Nothing in §3.1 changes that, and it widens the grain further.** So the figures are recorded here
and the registers are amended; **`AlloyProperty` is not touched**, and `FW-N22` — the story that
re-grains it — gains a **scope note** rather than new scope: it covers **rod only**, and its
acceptance criterion seeding *"the two ASTM B233 bands"* is now contested.

### 4.3 ⭐ `Q95`'s five silences, answered — and one design choice returns to where it started

| Leg | Answer | Effect |
|---|---|---|
| 1 — serial number | Possible, pending engineering | `SerialNo` **stays** and stays `[PROPOSED]`. `Q95`'s *"the column should go rather than sit empty forever"* does **not** fire |
| 2 — is `Set Number` unique? | Encoded and meaningful (§3.3) | ⭐ Supplies the natural key **`(MachineName, SetNumber)`**, which the DDL records as *"the obvious replacement key … **DELIBERATELY NOT** [taken]"* pending exactly this. **`FW-268` adds it** |
| 3 — are grooves numbered? | Identified **by gauge range and profile**, not position | **`GrooveNo` is dropped.** `Q95`.3 said the answer *"decides whether `GrooveNo` is real data or should be dropped"* |
| 4 — does `.100` mean per grind? | ⛔ *"an arbitrary number that I entered"* | **The `~12-grind` life model has no basis.** See §4.4 |
| 5 — is a set classified by profile at all? | **Yes** — by gauge band **and** profile, one profile per set | `EdgeType` returns to **`NOT NULL`** |

✅ **Leg 5 is not a reversal against `D-53`'s author.** `D-53` relaxed `EdgeType` to `NULL`
*"because the grid does not classify a set by profile at all"* and **named `Q95` as the send-back**
that would decide it. `Q95` has returned and says a set *is* so classified. **The absorption, the
gauge child table and the grind life model all stand**, and `D-56` had already reversed the rename
limb. Only the relaxation limb moves.

⚠ **The two `EdgeType` vocabularies now differ in size, not just in meaning.** The DDL already
insists `CK_PSC_EdgeType` and `CK_TIE_EdgeType` stay separate — *"the tool's capability and the
schedule's chosen profile are different assertions. Do not merge them."* They now differ in
**cardinality** too: the schedule takes **all four** profiles; the tool takes **three**, because
`Natural Round Edge` means no edging and no set is ground for it (§3.2, and his own table has no
such row). That makes the separation load-bearing rather than stylistic.

### 4.4 ⛔ The edger life model rests on a number the client made up

`G77` records the life model as *"`StdRemovalFromOdIn` `.100`, `OdIn` `6.00`, `MinOdIn` `4.75`,
**about twelve grinds**"*, and the DDL states it in the same terms. `Q95` leg 4 flagged this as
*"the one that silently produces wrong numbers rather than an obviously empty field"* and asked for
the arithmetic.

**The answer is that `.100` was arbitrary, and may vary by groove width range.** So the *"about
twelve grinds"* arithmetic is struck as fact wherever it is asserted, the column keeps its value,
and no screen may display a remaining-grinds figure until engineering confirms the standard.
⚠ Whether `StdRemovalFromOdIn` belongs on the **groove** rather than the set depends on an answer
Tim does not have — **do not move it speculatively.**

### 4.5 ⭐ `Q94`'s two disputed rows have one root cause, and the guard is now meant to fail

`Q94` legs 2 and 3 went back together because *"the two point opposite ways"* — one keeps a step for
equipment FL3 does not have, the other drops a step for equipment it does. **They resolve into a
single mislabelling.**

| Row | As seeded | Corrected |
|---|---|---|
| FL3 `H1AA` seq 8 | `SPC: Takeup-1` | **`SPC: FL1-Stand 1`** — *"it should have contained SPC FL1.FM1 not Takeup1"* |
| FL3 `H1B` — absence of `SPC: FL1-Stand 1` | absent | ✅ **Correctly absent.** *"not necessary as the stop is has been completed and these dimensions would not represent final gauge/width"* |
| FL2 `H1B` seq 2 · FL3 `H1B` seq 2 | `SPC: Takeup-2` | **`SPC: FL2-Stand 3`** — *"FL2 and FL3 should have SPC at FL2.FM2 for H1B"* |

So FL3's `H1AA` SPC row named FL1's **takeup** when it should have named FL1's **mill**, and the
`H1B` omission was right all along. It also explains why FL1 legitimately keeps `SPC: FL1-Stand 1`
in its own `H1B`: **FL1's output *is* final gauge.**

⛔ **`FW-262`'s verification guard asserts the disputed rows POSITIVELY** — *"FL3 `H1AA` must be 15
rows **including** `SPC: Takeup-1`, FL3 `H1B` must be 5 rows **excluding** `SPC: FL1-Stand 1`"* — so
that *"a well-meant correction fails the guard instead of passing silently"*. **This message is the
authorised change, so the guard must be re-pointed in the same commit as the seed.**

⚠ **Two readings of `SPC: FL2.FM2`, and we chose one.** `FL2-Stand 3` is applied, because S3 is the
final non-bypassable stand and `CLAUDE.md`'s canonical checkpoint is *"FM2 S3 output"*. **That is our
reading, not his words** — §6 item 9.

⚠ **His labels are a fifth naming convention and are not adopted.** `SPC: FL1.FM1` and
`SPC: FL2.FM2` occur nowhere in the repository; `FL1.FM1` is a **PLC tag path**. The element table's
own vocabulary is `FL1-Stand 1` / `FL2-Stand 1..3`, and `A12` says do not reconcile component
identifiers until the Speed tab lands.

⚠ **One consequence worth recording: the three double-homed labels become two.** The element table
is *"keyed on group + label, never label alone"* because three labels sit in two groups each —
`Load Spool: Takeup-1` (S1, S2), `Thread: Takeup-1` (H1AA, H1B) and `SPC: Takeup-2` (H1AA, H1B).
Replacing the `H1B` occurrence leaves `SPC: Takeup-2` in `H1AA` only. **The composite key still
stands on the surviving two** — no schema change — but the three sites that quote the count are
restated.

### 4.6 The tooling answers that land cleanly

- **Capstan rolls** join the mill rolls as **one** *Choose Tool* option; `ToolingInventoryRollSet`
  does not split. Closes `G87` leg 2.
- **`In Grinding`** covers *"either roll grinding or outsourced"* — one vocabulary, closing `G87`
  leg 3 and the *"refurbished"* half of `OI-77`.
- **`Location` gains a sibling, and is not redefined.** *"We should probably record position
  allocated in the line as E1 or E2"* — but `Location` is documented as *"roll shop / crib
  position"*, and a set that is `In Grinding` has **no** line position; the client's own grid reads
  `Location = Edger` for exactly that row. **Two facts, two columns:** a new
  `AllocatedPosition` `('E1','E2')` beside the existing `Location`.
- ⚠ **The capstan location answer contradicts itself** — *"DB1/DB2 would be the location as 12"
  rolls would belong to FL1 but would be **located at FM1**"*. `DB1`/`DB2` and `FM1` are different
  stations. `Machine Name = FL1` is taken; the location half is §6 item 4.
- ⛔ **`OI-77`'s blade-profile half stays void.** `Q28` retired it — *"grooved rolls have no profile
  to select"* — and that remains true: there is no *blade*-profile library. A groove is **cut** to an
  edge profile, which is a different statement, and it lands on `G76` and `EdgeType`. **Do not
  reopen `OI-77` on the strength of this message.**

### 4.7 FL3 — one answer confirms what is built, the other contradicts himself

- ✅ *"One schedule"* **corroborates `FR-363`** — *"a Hybrid FL3 schedule is a **single unified
  record** covering both drawing and finishing components"*. **Nothing changes.** It closes the
  one-or-two leg that `Q15` and the client workbook both framed; `OI-47`'s separate question — whether
  Dashboard 5 must prevent applying a standalone FL2 schedule to hybrid material — stays open.
- ⛔ **The scheduling-representation answer regresses.** *"I would like to see what Stephen has to
  say"* was written **two days after** he agreed the recommendation on `Q2`: *"I agree, a single FL3
  booking should reserve FL1/2 capacities."* **The agreement stands; the deferral is noted, not
  actioned.** ⚠ And it lands on a pre-existing split: `Q2`'s header still reads `Open` while its
  body records the 8 Sep answer, and `OI-63` still reads open.

### 4.8 FL1's spool core diameter is fixed — `Q46` closes on its recommendation

`Q46` asked whether the mandrel / core diameter is **selected per spool**, **fixed** by the single
standard spool size, or **read from the machine**, and recommended *"fixed by the standard size, and
therefore not entered"*. ✅ **The recommendation is confirmed.**

⚠ **Do not narrow `SpoolConfiguration` to a single value.** `CK_SpoolConfig_CoreDiam` is
`Min < Max`, so a genuinely fixed diameter cannot be expressed by it at all. The seeded range
`8.0000`–`12.0000` is the configurability the 23 Jul call's `C9` asked for; the current value is
`12"`, which `C9` records and the seed holds as the **maximum**. The future expansion Tim mentions —
*"collapsable spool(s) with different core diameters"* — is **context, not scope.**

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`Questions.md`](../../90-registers/Questions.md) | `Q95` **closed** on all five legs · `Q46` **closed** · `Q94` legs 2–3 **closed**, leg 1 (crew size) and the `H1B` replace-or-add residue **open** · `Q22` amended with §3.1 and the standard conflict · `Q92` amended — the roll-set grid is still owed · `Q2` amended with the 8 Sep-versus-10 Sep contradiction · the new send-back minted |
| [`Gaps.md`](../../90-registers/Gaps.md) | `G76` **closed** — vocabulary and point of entry both answered · `G104` **closed** — the natural key · `G77` amended — the `.100` life model struck as unverified · `G87` legs 2 and 3 **closed** · `G121` amended — the grain widens to product form × size band × edge profile × temper · `G74` corroborated · **two minted** — the `FR-271` spool-OD contradiction, and the edge-type carry-over that has no owner in this backlog |
| [`Decisions.md`](../../90-registers/Decisions.md) | The four product edge profiles and the tool's three · `EdgeType` back to `NOT NULL` (settling `D-53`'s relaxation limb, as `D-53` provided for) · the `Inactive` status label · FL3 one schedule, recorded as corroboration of `FR-363` |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) | §5 edger description · `OI-05` (Bevel) · `OI-57` (published bands — §3.1 is a partial answer) · `OI-63` · `OI-77` (profile half answered, regrind still open) · `OI-143` (third non-answer) · the `.100` strike |
| `FlatWire_DDL_01_Lookup.sql` · `02_Schedule.sql` · `07_Indexes.sql` · `FlatWire_SampleData_Lookup.sql` | `EdgeType` widened and `NOT NULL`; the two CHECKs re-valued at four and three; `AllocatedPosition` added; `GrooveNo` dropped; `(MachineName, SetNumber)` unique; `LifecycleStatus` `Retired` → `Inactive` on all three registers; the two Setup/Handling seed corrections |
| [`PLCTagSpecification.md`](../../20-architecture/PLCTagSpecification.md) | The spool-OD read — **the only home for a tag path string** |
| Stories | `FW-268` · `FW-269` · `FW-270` unblocked by `Q95` · `FW-005` · `FW-003` · `FW-132` · `FW-264` · `FW-N22` · `FW-N25` amended · Tier-1 follow-ons minted for `FW-147`, `FW-142` and `FW-262` |

⚠ **`60-delivery/TaskBreakdown.md` and the three `.xlsx` deliverables are deliberately NOT
updated** — they are client-facing and the costing baseline. The card-versus-story divergence is
reported, not silently fixed.

---

## 6. Still owed by the client

| # | Item | Why it matters |
|---|---|---|
| 1 | ⛔ **The roll-set grid columns** — `Q92`, sent 3 Sep, **still not supplied** | Every column in `ToolingInventoryRollSet` is ours. `FW-259` and `FW-261` stay blocked |
| 2 | ⛔ **`400-B` or `401-B`?** The stem encodes the gauge band everywhere except the last two rows | If the stem encodes nothing, the natural-key proposal collapses |
| 3 | ⛔ **Is `Bevel edge` the same as `Broken Edge`?** | ⭐ **Answer before the enum is touched.** `OI-05` is exactly *"a fourth vocabulary or dead UI"*, and `FW-147`'s enforcement **is** the enum's two-ness — a wrong guess means doing that rework twice |
| 4 | ⛔ **Capstan `Location` — `DB1`/`DB2` or `FM1`?** His own sentence says both | The other three grids all carry a station in that column |
| 5 | ⛔ **Which standard governs rod dimensional tolerance — `B233` or `B211`/`B211M`?** | `B233` is cited in twelve live places, including `FW-N22`'s acceptance criterion. **No citation changes until this is answered** |
| 6 | ⛔ **Roll-level tracking** — *"I am open to suggestions and alternatives, lets discuss"* | ⛔ **Nothing is built on that sentence** — that is the `G87` mistake. Our proposal goes back with the question |
| 7 | ⛔ **Honey Sachdeva's 4 Sep list, unanswered in full** — field type (label / textbox / dropdown / checkbox) per column for Dies, Edgers, Straighteners and Roll Sets; the Roll Sets column list; and **whether `Crew Size` applies to the FL machines** | The last is `Q94` leg 1, where the vocabulary is already *measured* as `1`/`2`/`3` but `CrewSize` keeps a range `CHECK` and stays `[PROPOSED]` awaiting exactly this |
| 8 | ⛔ **Rod footage ± ft tolerance** — he returned the question | `D-37` says footage *"carries a ± x ft tolerance from ovality"* and *"the formula worksheet is still owed"*. **We owe him the clarification first** |
| 9 | ⛔ **Does *"SPC at FL2.FM2"* mean stand S3?** And does it **replace** `SPC: Takeup-2` or sit beside it | We applied *replace*, at `FL2-Stand 3`. Replace keeps the element counts at `5`/`5`; add would move FL2 to 30 and FL3 to 48 and change the seed banner |
| 10 | ⛔ **FL3 as a booking unit** — and which of his two answers stands, 8 Sep or 10 Sep | `Q2` versus `OI-63`; upstream Scheduling |
| 11 | ⛔ **The Speed tab** — the fourth `A12` leg, **unmentioned in four consecutive messages** | Blocks Ashwani's build and gates the component-identifier reconciliation |
| 12 | ⛔ **The `.134` / `.184` straightener range**, and a straightener field set | `G77`'s remaining half |
| 13 | ⛔ **`OI-143`** — is `EDGE` an SMP process step or an attribute of the flatten? | Asked 1 Sep, re-sent 3 Sep, **unanswered a third time** |
| 14 | ⛔ **The regrind turnaround, and in-house or outsourced** | `OI-77`'s surviving half |
| 15 | ⛔ **`STD Removal From OD`, and whether it varies by groove width range** | With engineering. No remaining-life figure may be displayed until it lands |
| 16 | ⛔ **An edger serial number** — can one be assigned? | With engineering. `SerialNo` stays `[PROPOSED]` meanwhile |

---

## 7. Attachments — 21, and not one of them is new

**Established rather than assumed.** No `.msg` parser is installed, so the CFB container was parsed
directly, the compressed-RTF body decompressed (LZFu — **321,204 bytes recovered, an exact match for
the stream's declared `rawsize`**), and the inline `cid:` anchors read **in document order**.

| Content | Count | Status |
|---|---|---|
| Flattening Line Schedule — FL1 · FL2 · FL3 | 3 | Already transcribed, 31 Aug ledger §3.1 |
| Setup / Handling Times — FL1 · FL2 · FL3 | 3 | Already transcribed, §3.2 |
| Tooling Inventory — Die · Edger · Straightener | 3 | Already transcribed, §3.3 *(referenced twice in this copy)* |
| Material Loss — FL1 · FL2 · FL3 | 3 | Already transcribed, §3.4 |
| Ashwani's four **"before"** screens | 4 | Already recorded |
| Slitter reference shots from **Honey's 4 Sep** mail — Tooling Inventory view + edit, and the Setup/Handling **Crew Size** dropdown | 3 | New to this copy, but they illustrate **questions**, not answers |
| Sender signature graphic | 1 | Not content |
| **The `Linear Feet Wire/Rod` formula** | 1 | ⚠ **Not new** — it is `F1`, transcribed in the 2 Sep formula ledger and in `build_formula_review_xlsx.py` |

**Total 21.** The twelve field sets group 3-3-3-3 exactly as the four tabs require, and the four
"before" screens, three slitter shots and one signature account for the rest.

⚠ **This copy numbers them `image001`–`image021` — a FOURTH numbering of the same set.** The 31 Aug
copy jumped `017 → 021`; Sushant's 3 Sep copy ran `image019`–`image035`; the 3 Sep tooling copy ran
`image001`–`image018`. **Outlook renumbers inline `cid:` references per message. Cite an attachment
by content, never by `cid`, and never reconcile two ledgers by image number.**

---

## Related Documents

| Document | Why |
|---|---|
| [ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) | The four tabs as pictured; **its §3.2 FL3 transcription is corrected here** |
| [ClientEmail_2026-09-03_Tooling_SyncPlan.md](ClientEmail_2026-09-03_Tooling_SyncPlan.md) | Four of its seven *"still owed"* rows close here |
| [ClientEmail_2026-09-09_QuestionsWorkbook_SyncPlan.md](ClientEmail_2026-09-09_QuestionsWorkbook_SyncPlan.md) | The 8 Sep answers this message duplicates, contradicts on `Q2`, and extends on `Q22` |
| [ClientEmail_2026-09-02_PassCalculatorFormulas_SyncPlan.md](ClientEmail_2026-09-02_PassCalculatorFormulas_SyncPlan.md) | `F1`, the re-pasted linear-feet formula |
| [Questions.md](../../90-registers/Questions.md) · [Gaps.md](../../90-registers/Gaps.md) · [Decisions.md](../../90-registers/Decisions.md) | Where the binding statements live |
| [FlatWire_DDL_01_Lookup.sql](../../30-database/sql/FlatWire_DDL_01_Lookup.sql) | The edger register, and the Setup/Handling seed |
| [FW-268.md](../../10-requirements/features/FS-03-database-foundation/DB/FW-268.md) | *"Reconcile `ToolingInventoryEdger` … when `Q95` returns"* — **unblocked by this message** |
| [FW-262.md](../../10-requirements/features/FS-03-database-foundation/DB/FW-262.md) | The seed and the guard that this message authorises changing |
