# Client e-mail — 1 September 2026 — downtime, WIP rejection and IT inhibit reason codes

**Source:** `RE: Flatwire  requirements : Questions` — Tim O'Brien (UA) to Jaspreet Singh, Bob Scott,
Shannon Riotte; cc Srikanth Prabhala, DG UA DEV.
**Sent:** Tue 1 Sep 2026 17:56 UTC. **Analysed:** 2 Sep 2026.
**Attachment:** `Reason Codes.xlsx` — three sheets, 8 embedded images.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §5.

---

## 1. What this closes

This is Tim's inline reply to **Jaspreet's 22 Jul 2026** question list — answered 41 days later.
[`ClientCall_2026-07-23_SyncPlan.md`](ClientCall_2026-07-23_SyncPlan.md) §4 records six actions owned
by Tim and says of four of them: *"reference data the build cannot proceed without."*

| Action owed | Status |
|---|---|
| **`A4`** Share flat wire **downtime reasons** | ✅ **Closed** — 72 codes in four time buckets |
| **`A5`** Share flat wire **web rejection reasons** | ✅ **Closed** — 72 reasons |
| **`A6`** Share flat wire **IT inhibit reasons** | ✅ **Closed** — 8 reasons |
| **`A2`** **Temper calculation logic** from the Technical Team | ⚠ **Partial** — three regimes named; *"a formula work sheet will be sent separately"* |
| **`A3`** **Weight approach for non-cylindrical rod** | ⚠ **Partial** — basis answered (cylindrical; weight is an input); worksheet owed |
| **`A1`** Provide the **OD calculation formula** | ⛔ **Not answered at all.** Question 1 is the only one of the 13 with no inline reply |

**Propagation wave `W3`** — *"downtime and rejection reason vocabularies once `A4`/`A5` arrive"*, the
only wave marked **Blocked** on client input — is now unblocked.

> ⚠ **No open `Q##` closes outright.** Every question this mail touches gains a decided *portion* and
> keeps an owed one. `Q4`, `Q10`, `Q11`, `Q20`, `Q21`, `Q32`, `Q33`, `Q44` and `Q87` all stay `Open`.
> What closes is three client **actions**.

**The substance is split between the body and the workbook, and the workbook's meaning is in its cell
colours.** The three sheets are not "here are the new codes" — they are the *existing* UA code lists
with a three-way colour classification applied. Read as plain text they are unusable. See §3.

---

## 2. The thirteen answers

Verbatim, abridged only where marked.

| # | Question | Tim's answer |
|---|---|---|
| **1** | Formula for a spool's Outer Diameter | ⛔ **no reply** |
| **2** | Temper change during rolling | *"Temper change, or work hardening will be calculated by reduction percentage, however it will be different depending on where in the process the reduction is occurring… There will be a calculation for Round to Round, Round to Flat, & Flat to Flat. Flat to Flat will work per our existing reduction rules (thickness Reduction) but will need a new table as the wire properties respond differently to the work hardening than the coil. Round to Round will be based upon Diameter Reduction Percentage… Round to Flat will be calculated based upon Cross Sectional Area Reduction (Our Current Approach)… This is heavily affected by Roll Geometry, Roll Finish, & Lubrication. A formula work sheet will be sent separately."* |
| **3** | Is incoming rod cylindrical for weight? | *"The Rod will be considered cylindrical although it is not perfectly round. **The Rod weight is given at the time of coil receiving so there is no need to calculate, it is an input instead.** Calculating the footage on the other hand is a different story. We can calculate the footage, but it will/can be off +/- xft, due to the diameter/ovality not being consistent throughout. The given weight guarantees a set footage during the drawing process, although even drawing has a tolerance… but the tolerance range is significantly tighter than the provided rod. A formula work sheet will be sent separately."* |
| **4** | Mill Jog equivalent; is setup material scrap? | *"Yes, we will have jog events on **all three stands of FL2**, as well as **open/close on stand rolls**, and **thread position on dancers**. We will definitely need to record the threading as a WIPREJ/Scrap. This should be covered through the **Materials Loss Table that I sent to Ashwani**. We need to determine the actual footage for these events **through testing** and populate the data fields in the table."* |
| **5** | Tension control on the dancers | *"The dancers will maintain little to know [sic] tension by design. As a dancer senses no tension or high tension, the equipment will speed up or slow down to compensate. This function will be controlled through the **machine program**, and each dancer will have a **range(position)** that it is set to maintain. **This will not be adjustable from an operator standpoint and will remain constant.** We will have a tension mode available **on FL2 however it will only work with heavier & larger dimension products**. I am uncertain how this will work in this scenario and will need to follow up with engineering for more detail."* |
| **6** | Additional downtime reasons? | *"Yes, I have attached the down time Reasons."* |
| **7** | Additional WIP rejection reasons? | *"Yes, I have attached the WIPREJ Reasons."* |
| **8** | Additional IT inhibit reasons? | *"I have attached the IT Inhibit Reasons."* |
| **9** | Dedicated Supervisor Monitor required? | **"No"** |
| **10** | Labels and printers | Printers — *"FL1 Payoff – SATO · FL1 Operator Station – SATO & ZEBRA High-Temp · FL2 Operator Station – SATO & Previsions for Zebra High-Temp (Not needed at this time given there is no way to anneal."* Labels — *"(Need to confirm with Bob S. & Shannon R.)"*: **Return to Stock @ Payoff · Coil/Spool Label High-Temp · Finished Coil Label · Skid Label**. Open: ***"Do we need two SATOs at FL2?"*** addressed to Bob |
| **11** | Yield calculation and reporting | *"Yield should be calculated as a percentage of the following (**Open for Discussion**)"* — **FL1**: produced lb ÷ consumed lb per **Bundle**, per **Shift**, per **Order**. **FL2**: the same per **Spool**, per **Shift**, per **Order** |
| **12** | Cost Ledger | *"This question should be presented to **Jeff G.**"* |
| **13** | Throughput calculation and reporting | *"Throughput calculation and reporting will be **similar to that of the slitters**. I have sent Ashwani the required fields, terminology, and layout. The lines will be broken up into **Setup & Handling buckets (i.e. S1, H1a, H1b, etc.)**, and given the allotted setup and handling time, and the **calculated speed for a given pass schedule**, the **standards should be generated**."* |

Tim's covering note routes the whole message onward: *"@Scott, Bob & @Riotte, Shannon, Please review
the attached and the comments below and add notes if changes are necessary, or you disagree."*
**So none of this is final in Tim's own framing.**

---

## 3. `Reason Codes.xlsx` — the three vocabularies

### 3.1 The colour key is the content

Every sheet opens with a two-row legend whose **swatches**, not text, carry the classification:

| Fill | Legend text | Meaning |
|---|---|---|
| **Yellow** `FFFFFF00` | *"Existing Reason Codes that will apply to Wire Flattening"* | **Reuse this code** |
| **Green** theme 9 | *"Additional Reason Codes that need to be added for Wire Flattening"* | **New code** |
| *(no fill)* | — | **Existing code that does NOT apply** |

The third state is unlabelled and is the largest of the three. Totals by fill:

| Sheet | Applies | New | Not applicable | **In scope** |
|---|---|---|---|---|
| Down Time Reasons | 36 | 36 | 59 | **72** |
| WIPREJ Reasons | 64 | 8 | 24 | **72** |
| IT Inhibit Reasons | 6 | 2 | 0 | **8** |
| | | | | **152** |

⚠ **`C1`'s warning was right.** The 23 Jul ledger said of the downtime reasons: *"15 reasons in 5
categories already exist. Tim's list either ratifies or replaces them — **do not assume it extends
them**."* It does neither cleanly: it **replaces the taxonomy** and re-uses **38 %** of the existing
UA delay codes while discarding 62 % of them.

### 3.2 Down Time — four time buckets, not five semantic categories

Structure: `Setup` (`SET01`–`SET28`) · `Run Time` (`RUN01`–`RUN14`) · `Handling` (`HDL01`–`HDL17`) ·
`Downtime` (`DWN01`–`DWN36`). Per-code attributes **`Nonprod Time` · `Status` · `Delay Buffer`**, with
**`Supervisor Override` on the `Downtime` bucket only**.

**Existing codes that apply (36).**

| Bucket | Codes |
|---|---|
| Setup (8) | `SET10` QC / Process Monitor Quality · `SET11` Prior Shift unaccountable · `SET12` Operator Training · `SET19` Computer problems *(Inactive)* · `SET21` Replace Banding Material · `SET23` Other *(Inactive)* · `SET24` Machine Demonstration · `SET28` Active Inspection |
| Run Time (6) | `RUN04` Rough or Cracked Edges · `RUN05` Shape Problems · `RUN06` Operator Training · `RUN12` Other *(Inactive)* · `RUN13` Active Inspection · `RUN14` Machine Demonstration |
| Handling (6) | `HDL07` Operator Training · `HDL11` Replace Banding Material · `HDL14` Edge Damage from Width Changes · `HDL15` Other *(Inactive)* · `HDL16` Machine Demonstration · `HDL17` Active Inspection |
| Downtime (16) | `DWN01` unscheduled maintenance · `DWN06` Scheduled w/o Man Power · `DWN07` Fire Drill · `DWN08` Schedule/Unschedule Meeting · `DWN09` Weather Storm · `DWN10` Computer Problem · `DWN13` Technical Monitoring · `DWN14` Process Monitoring · `DWN15` Power Outage · `DWN17` Scheduled Maintenance · `DWN18` Maintenance Dept PM · `DWN24` Toolbox\Shapeup · `DWN25` IT Maintenance · `DWN29` Other · `DWN32` Machine Demonstration · `DWN33` Operators Transferred To Conveyor |

**New codes to add (36)** — `(N)` / `(Y)` is `Nonprod Time`; the `Downtime` rows also carry
`Supervisor Override`. **All 36 have blank code, Status and Delay Buffer cells.**

| Bucket | New reasons |
|---|---|
| Setup (13) | Wire Break (N) · Trouble Threading The Line (N) · Change Straightener Rolls (N) · Change Dies (N) · Change Edger Rolls (N) · Rewind Bundle (Y) · Cannot Find Bundle/Spool, Not Correct Bundle/Spool, Searching For Bundle/Spool (N) · Searching For Next bundle/Spool (Y) · Digging Out Next Bundle/Spool (Y) · Refill Draw Lube (N) · Cobble (N) · Tangle (N) · Wire Break Due to Bad Weld (N) |
| Run Time (6) | Wire Break (N) · **Traverse Problems** (N) · Cobble (N) · Tangle (N) · Refill Draw Lube (N) · Wire Break Due to Bad Weld (N) |
| Handling (8) | Wire Break (N) · Trouble Threading The Line (N) · Change Straightener Rolls (N) · Change Dies (N) · Change Edger Rolls (N) · Wire Break Due to Bad Weld (N) · Rewind Bundle (N) · Cleaning Scrap From Line (N) |
| Downtime (9) | Wire Break (N, ovr 0) · Trouble Threading The Line (N, 0) · Change Straightener Rolls (N, **1**) · Change Dies (N, **1**) · Change Edger Rolls (N, **1**) · **Waiting for Spool From Previous Operation** (Y, 0) · Searching For Next bundle/Spool (Y, 0) · Refill Draw Lube (N, 0) · Digging Out Next Bundle/Spool (Y, 0) |

Three data details that bite on seeding:

- ⚠ **`DWN29 Other` has a blank `Nonprod Time` cell.** Every other row in that bucket says `Yes`.
  A `NOT NULL` column fails on this row.
- ⚠ **`Rewind Bundle` is `Nonprod = Yes` under Setup and `No` under Handling.** Same words, different
  attribute — so the code is per *(bucket, reason)*, never per reason.
- **`Change Straightener Rolls` is one of three new codes appearing in all four buckets**, alongside
  `Change Dies` and `Change Edger Rolls`. `Straightener` still has no home in this repository
  (recorded on the 31 Aug mail, §4.6).

### 3.3 WIPREJ — a flat list with no groups at all

72 in scope. **New (8):** Cobble · Tangle · Underproduced / Under Weight · Wire Brk / Pull Apart ·
Wire Brk Due To Tangle · Wrong Bundle / Spool · Wrong Incoming Diameter · Wrong Temper.

**Existing that apply (64):** Bad Shape (wavy ege [sic] or buckle) · Broken Bands · Broken Welds ·
Burr, Rolled Edges · Camber · Chatter · Collapsed ID · Crossbreaks · Cutter Mark · Damaged Edges ·
Damaged Packing · Dents · Forced Recalculation (No Reason Assigned) · Gauge Varies · Grain · Heads
and Tails · Herringbone · ID Damage · Incorrect Buildup / Plan Not Followed · Live Scratches · Loaded
Wrong · Loose Bands · Loosewound Coil · Machine / IT Problem · No Appointment · No Bands · No Packing
· No Paperwork · OD Damage · Off Weight · Oil Stain, Smut · Order Cancelation / For acct. Purposes ·
Other · OVERPRODUCED ORDER · Oxidation, Magnesium Stain · Plan Required Head Scrap · Plan Required
Tail Scrap · Planned Excess Tail Scrap · Roll Mark · Rolled-in Scratches · Rough or Cracked Edges ·
SCRAP BALANCE · Shipping Delay · Sliver, Holes, Inclusion · Telescoped · Telescoped, Oscillated Coil ·
Too Many Welds · Traffic Marks · Twist · Water Stain · Water Stain in Warranty / Vendor Issue · Wet At
Receiving · Width Varies · Wire Brk Due To Edge Cracks · Wire Brk Due To Holes, Laminations, Blisters,
Inclusions · Wire Brk Due To Machine Problem · Wire Brk Due To Shape · Wrong Alloy · Wrong Banding ·
Wrong Gauge · Wrong ID · Wrong OD · Wrong Skid Size · Wrong Width.

**Excluded (24)**, worth recording because several are the *side*-scrap and coil-form reasons that do
not exist on wire: Angel Wings · Anodizing Quality · Blisters / Centerline Blisters (Vendor) · Broken
Coil · Buff Scratches · Coil Set · Core Problems · Crossbow · Earing · Excess Side Scrap · Hot Mill
Pickup · Lunder Bands · Periodicity · Plan Required Side Scrap · Planned Excess Side Scrap · Plastic
Coating Problem · Tolling · Vendor Rolled Matl (B2B/Hybrid) · Volmer Gauge Marks · Welds Wrong
Location · Wiperroll Marks · Wrong - Slit width · Wrong Incoming Coil Width · Wrong Surface Finish no
Rolls Available.

⚠ **There is no grouping in the sheet.** `WipRejection.RejectionGroup` is `NOT NULL` under
`CK_WipRejection_Group` (`SurfaceQuality|Dimensional|WeldQuality|Material|Process`) — so **all 72
group values would be ours**, not the client's.

⚠ **No threading reason exists**, although answer 4 requires threading to be recorded as a WIPREJ.

### 3.4 IT Inhibit — 8 reasons, and they barely overlap the specification

| Reason | Fill |
|---|---|
| Correct Pass Schedule Not Loaded. Mismatched OPC and Pass Schedule Values | applies |
| No Qualified Operators Are Logged In | applies |
| Pass Schedule is Not Accepted | applies |
| SPC is Not Done | applies |
| Supervisor Monitor | applies |
| System Air Pressure Low | applies |
| **Next Bundle Not Welded** | **new** |
| **No Bundle/Spool is Checked In** | **new** |

Against `[PLC §8.2]`'s five set conditions:

| `[PLC §8.2]` | In Tim's sheet? |
|---|---|
| 1. No coil or rod is checked in | ✅ *No Bundle/Spool is Checked In* |
| 2. No active material-tracking identifier exists | ⛔ absent |
| 3. Feet data from the machine is unavailable | ⛔ absent |
| 4. Feet data from the machine is invalid | ⛔ absent |
| 5. Two or more consecutive data recordings are missing | ⛔ absent |

**One of five.** And §8.2's five are not loose prose — they are `FR-008`/`FR-009` with alternate flows
`ALT002`–`ALT005` / `DAT009` and **five P1 test cases `TC-011`–`TC-015`**. The union is ~12 reasons.
Nobody has said the five are superseded, so **this is additive or it is a contradiction — it is not a
replacement**.

### 3.5 The eight images

Provenance, not new requirements — but images 7 and 8 contradict the sheet Tim attached beside them.

| Image | Content |
|---|---|
| 1–6 | Screenshots of the **current WIPREJ dropdown** — the source the reason list was read off. Image 6 is a single tooltip, *Wrong skid size* |
| **7** | Live **IT Inhibit** pop-up, machine A: *No qualified operators are logged in · No coil is checked in · SPC is not done* (in red) · *Air pressure is low · Plastic is not applied · Wiper Pressure is not applied/Wiper is not closed · Head - Payoff combination not online for the coil · **ID calculated for a coil is not within Rewind ID range** · Platten Failure*. Footer: *"Please close this pop-up if facing problem in opc events."* Buttons: **`Call Supervisor`** · `Close` |
| **8** | Live **IT Inhibit** pop-up, machine B: *No operator is logged in · No coil is checked in · **Torch and conductivity test in progress** · Pass Schedule is not accepted · Air pressure is down · Correct pass schedule not loaded. Mismatched OPC and pass schedule values · **Manderel not collapsed for scrap piece** · **Low periodicity score** · Supervisor monitoring* |

Two things follow. **A `Call Supervisor` action exists on the real dialog** and is in neither the
repo's inhibit modelling nor `[PLC §8.3]`. And **the screenshots carry conditions the sheet drops** —
periodicity, torch/conductivity, mandrel state — so the 8-row sheet is a curated subset of what these
machines actually inhibit on, not an exhaustive list.

---

## 4. What this changes in the repository

### 4.1 The delay-code model replaces the pause taxonomy outright

`RunPauseEvent.ReasonCode` / `.ReasonCategory` are `VARCHAR(50) NOT NULL` with **no CHECK on either**
— the vocabulary lives only in [`pause_run.js`](../../50-frontend/mockups/pause_run.js), the master
spec and [`APIs.md`](../../40-backend/APIs.md): **15 reasons in 5 semantic categories**
(`EquipmentMechanical` · `MaterialHandling` · `QualityMeasurement` · `Operational` · `Safety`).

Tim's model is UA's existing **delay-code** system: four *time* buckets keyed to the standard-time
model, `SET##`/`RUN##`/`HDL##`/`DWN##`, plus `Nonprod` / `Delay Buffer` / `Supervisor Override`.
**Literal overlap with the 15 is zero.** Semantic overlap is partial — *Die change* ↔ new
*Change Dies*, *Lubrication / coolant* ↔ new *Refill Draw Lube*, *Downstream blockage (TKUP-2 full)*
↔ new *Waiting for Spool From Previous Operation*, *Manual SPC measurement* ↔ `SET10`.

⛔ **Four of the 15 have no code in Tim's list at all**: `OperatorBreak`, `ShiftChangeover`,
`AwaitingSupervisor`, `SafetyObservation`. `SET11 Prior Shift unaccountable` is not shift changeover
and `DWN07 Fire Drill` is not a safety observation. These were in the SRS; they do not simply vanish.

### 4.2 It is one model with the 31 Aug mail

Answer 13's *"Setup & Handling buckets (i.e. S1, H1a, H1b, etc.)"*, the 31 Aug Setup/Handling Times
tab's seven codes (`S1 · H1A · H1AA · R · H1B · S2 · H2`) and this sheet's four buckets are the same
system — the buckets hold the standard time, the delay codes consume it. Mapping: `Setup` → `S1`/`S2`,
`Handling` → `H1A`/`H1AA`/`H1B`/`H2`, `Run Time` → `R`, `Downtime` → nonproductive, outside the
standard.

Answer 4's *"Materials Loss Table that I sent to Ashwani"* **is** the Material Loss tab transcribed in
[`ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md`](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md)
§3.4 — the tab whose FL1 rows are *Threading Drawblock #1/#2* and *Threading FL1-Stand #1* and whose
FL2 rows are *Threading FL2-Stand #1/#2/#3*. **Its values are empty and owed from trial**, which is
what answer 4 means by *"determine the actual footage… through testing."*

### 4.3 44 `Downtime` codes have nowhere to be recorded

`RunPauseEvent.RunId` is `VARCHAR(20) NOT NULL` with an FK to `FlatWireRun`; `FootageAtPause` is
`NOT NULL`; `CK_RunPauseEvent_Outcome` allows only
`ResumeRun|LogWipRejection|CheckOutRod|ContinuePause`. **Every one of those assumes a run.**

The `Downtime` bucket's 25 in-scope codes (16 existing + 9 new) are all line-down time — *Power
Outage*, *Fire Drill*, *Scheduled Maintenance*, *Waiting for Spool From Previous Operation* — which is
exactly when no run is open. `WipRejection.RunId` is nullable for precisely this reason.

**Resolved 2 Sep 2026: a new `LineDowntimeEvent` table**, line-scoped with a nullable `RunId`, rather
than relaxing `RunPauseEvent`. `RunPauseEvent` keeps its shape and its domain narrows to the three run
buckets — **47 codes** (20 existing + 27 new); `LineDowntimeEvent` takes the other **25**.

### 4.4 `wip_stations.PrinterName` cannot express the printer topology

[`10_CommonDB_Insert_WIPStations_FlatWire.sql`](../../30-database/scripts/10_CommonDB_Insert_WIPStations_FlatWire.sql)
seeds five stations against **four invented printer names** — `FL1$PRINT`, `FL2$PRINT`, `FL3$PRINT`,
`FWPACK$PRINT`, each `CHAR`-padded to exactly 12 (`D6`, asserted by the script's own verification
step). Answer 10 gives the real topology, and it does not fit:

| Tim's location | Printers | Against the seed |
|---|---|---|
| FL1 **Payoff** | SATO | `FL1PO` currently **shares `FL1$PRINT`** with `FL1` — it needs its own |
| FL1 **Operator Station** | SATO **and** Zebra High-Temp | ⛔ **two printers, one `PrinterName` column** |
| FL2 **Operator Station** | SATO (+ provisioned Zebra, unused — no anneal at FL2) | `FL2$PRINT` |
| *(none named)* | — | **`FL3$PRINT` has no counterpart** — FL3's operator stations *are* FL1's and FL2's |
| *(none named)* | — | **`FWPACK$PRINT`** may be the second FL2 SATO Tim is asking Bob about |

⚠ **The high-temp unit is a ZEBRA.** `C12` recorded *"1 high-temperature + 3 standard ≈ 4 SATO"*, and
`Q44`'s decision quotes Bob as *"the ones that are output from the mills"*. Neither says Zebra.

Label types map cleanly onto the open label questions, which is the useful part:

| Label | Printer | Register |
|---|---|---|
| **Return to Stock @ Payoff** | FL1 Payoff SATO | ⛔ **no home in this repository** |
| Coil/Spool Label High-Temp | FL1 Op Station Zebra | `Q44` — decided 20 Aug (1½ × 3, two per spool); fields still owed |
| Finished Coil Label | FL2 Op Station SATO | `Q87` |
| Skid Label | FL2 Op Station SATO | `Q4` |

**`Return to Stock @ Payoff` is a new transaction, not just a new label** — returning unconsumed rod to
stock from the FL1 payoff. It sits beside `Q12` (partial-rod re-check-in) and nothing models it.

### 4.5 The `C6` / `D-28` dancer conflict resolves

[`ClientCall_2026-07-23_SyncPlan.md`](ClientCall_2026-07-23_SyncPlan.md) §3.1 recorded a **conflict**
and deliberately applied neither side: the 23 Jul position (*dancers remove tension; control is
machine-driven*) against `D-28` of 6 Aug (*two dancers, each with two modes, one of them tension mode*).

**Answer 5 is dated 1 Sep — later client direction than either — and it makes both true.** Dancers
hold little to no tension; control is the **machine program**; each dancer holds a **range (position)**;
**not operator-adjustable, constant**. A tension mode exists, **FL2 only**, heavy/large product only,
and Tim is *"uncertain how this will work"* pending engineering.

Three consequences:

1. **`Q32` items 1 and 2 are answered.** Nobody selects the mode — not the operator at the HMI, not
   the pass schedule. So **no write surface is owed**, and the read-only `Dancer` tag element
   authored on 12 Aug (`PLC-Q18`) was the correct call.
2. **`Dancer.SupportsTensionMode = 0` on FM1 is now a fact.** Its seed comment says *"0 here records
   'not stated', not 'no'"*; tension mode being FL2-only makes it **`no`**. FM2's `1`s stand.
3. ⚠ **`PSG-D27` stays open and narrows.** It substitutes `σ̄_f,eff = σ̄_f − (σ_b + σ_f)/2` on applied
   front/back tension. If dancers *remove* tension, that models something the equipment does not do
   on FM1 at all and does conditionally on FM2. **`Q32` item 3's contradiction with `PSM012`** —
   *"tension is derived from speed, never entered manually"* — is now **qualified by mode**, not
   deleted, and remains a physics question for whoever owns the force model.

### 4.6 Answer 4 opens a new PLC read surface

*"Jog events on all three stands of FL2, as well as open/close on stand rolls, and thread position on
dancers."* None of the three exists in the published tag map. It also partly answers **`Q21` item 1**
(*is `FL{n}.LineState` a two-state bit, or does it distinguish `THREADING` / `JOG`?*) — **jog and
threading are real machine states**, so the filtering `Q21` asks about is required, not hypothetical.

**Thread position on a dancer is a second dancer element**, beyond §4.5's read-only mode element.

### 4.7 Two answers do not close the items they look like they close

- **Answer 11 does not close `OI-60`.** `OI-60` asks for **expected** metallic yield **per route**
  (rod → flat direct, rod → round wire → flat, flat → flat re-pass). Tim gave the **actual**-yield
  measurement formula at three granularities. Different question; do not mark `OI-60` answered.
- **Answer 13 inverts `OI-68`'s recommendation.** `OI-68` proposes *"derive provisional figures
  arithmetically from the throughput rates owed as `OI-82`."* Tim's direction is the reverse: the
  setup/handling times are **entered** (the 31 Aug tab even says *"All Standard time should be entered
  in minutes"*, with a Crew Size selector), speed is **calculated from the pass schedule**, and the
  standards are **generated** from both. `OI-82`'s owner is Bob S.; the answer came from Tim.

### 4.8 `No Qualified Operators Are Logged In` presumes an unbuilt mechanism

It requires `C10`'s **Leadman / Operator / Helper** roles and a **qualification matrix** gating
transactions. `Security.md` §8 has six roles — Operator, Supervisor, Ops Manager, Eng/Maint, QA, Admin
— **neither Leadman nor Helper**, and no matrix at all. `G6` already records that the six claim
*values* have not been supplied. So this inhibit reason cannot be evaluated by anything that exists.

### 4.9 `Supervisor Monitor` survives an answer that removes it

Answer 9 is a flat **"No"** to a dedicated Supervisor Monitor — which supersedes `C13`'s softer
*"desired but not required for initial implementation"*. Yet **`Supervisor Monitor` is a yellow
(applies) IT inhibit reason** on the sheet, and image 8 shows *"Supervisor monitoring"* live on a real
machine.

Both readings are defensible — a *screen* versus *a supervisor is presently monitoring this machine* —
and they pull opposite ways on `Q20`. Answer 9 closes the **screen**; it does not tell us what sets
this inhibit.

### 4.10 "Bundle" and "Spool" are operator words here, not schema words

Tim's new codes use both heavily: *Rewind Bundle*, *Cannot Find Bundle/Spool*, *Next Bundle Not
Welded*, *Wrong Bundle / Spool*, *Waiting for Spool From Previous Operation*.

| Tim's word | The schema |
|---|---|
| **Bundle** | the incoming rod — `Rod`, alpha `R#####` |
| **Spool** | the **material in process** — **`SpoolProcessing`**, alpha `SP-#####` |
| — | **never `Spool`**, which since `Q60` is the reusable stencilled *article* and has no `Alpha` at all |

⚠ Seed the descriptions **verbatim** — they are operator-facing labels and *"operators say spool"* is
already the recorded position. But record this mapping, because a reader who takes *"Wrong Bundle /
Spool"* at schema face value lands squarely on the `Q60` swap — the one stale reference in this repo
that is **silently wrong rather than obviously stale**.

### 4.11 The reason codes are production reference data

Answer 6–8's lists are not sample data. `PayoffPosition` sets the precedent in
[`FlatWire_DDL_01_Lookup.sql`](../../30-database/sql/FlatWire_DDL_01_Lookup.sql): its three fixed rows
are seeded **inline in the DDL** under per-row guards, so `RunAll` alone yields a working database.

If these 152 rows go only into `FlatWire_SampleData_Lookup.sql`, a production deploy that skips sample
data gets **empty reason tables and a pause dialog with nothing in it** — the same failure shape as
the 31 Aug mail's §4.1 (*empty schedule tables mean check-in cannot run in production, and the trial
will not catch it*).

⚠ Note the inconsistency this exposes: the `Dancer` seed comment says *"three rows, and they are
**equipment, not sample data**"* — while sitting in the sample-data file.

### 4.12 The pause dialog's interaction does not survive the change

[`pause_run.js`](../../50-frontend/mockups/pause_run.js) renders **15 icon tiles in 5 category
columns**. 47 delay codes cannot be tiles at the 14 px shopfloor minimum on an arm's-length panel.

[`wip_rejection.js`](../../50-frontend/mockups/wip_rejection.js) **already solves this** — quick-reason
chips over a `Group` select plus a `Specific reason` select. The pause dialog should adopt that
pattern rather than a third interaction being invented, and `wip_rejection.js` itself then needs only
a data swap.

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) `D-##` | Four-bucket delay-code model authoritative · dancer mode machine-program-controlled and FL2-only tension (**resolves `C6`/`D-28`**) · rod weight is an input, rod is cylindrical · **no dedicated Supervisor Monitor** (supersedes `C13`) · three temper regimes · yield formula + granularities · throughput standards are *generated* · `LineDowntimeEvent` |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11 | `OI-60` (§4.7) · `OI-68` (§4.7) · `OI-82` · `OI-84` · new `OI` for the `Return to Stock @ Payoff` transaction |
| [`Questions.md`](../../90-registers/Questions.md) | `Q4` `Q10` `Q11` `Q20` `Q21` `Q32` `Q33` `Q44` `Q87` annotated — **all stay `Open`**; new `Q##` for printer topology and WIPREJ group assignment |
| [`Gaps.md`](../../90-registers/Gaps.md) | Printer topology (§4.4) · WIPREJ groups are ours (§3.3) · inhibit-list disjunction (§3.4) · qualification matrix (§4.8) · no threading reason (§3.3) · four orphaned pause reasons (§4.1) · `Return to Stock` (§4.4) · reference-data-in-sample-file (§4.11) |
| [`PLCTagSpecification.md`](../../20-architecture/PLCTagSpecification.md) | §8.2 reconciliation · new `PLC-Q##` for FL2 stand jog, stand-roll open/close, dancer thread position · `Call Supervisor` action (§3.5) |
| `FlatWire_DDL_01_Lookup.sql` | `DowntimeReason` · `WipRejectionReason` · `ItInhibitReason`, seeded inline |
| `FlatWire_DDL_04_Runs.sql` | `RunPauseEvent` domain narrowed to three buckets · new `LineDowntimeEvent` |
| `FlatWire_DDL_05_QualityOutput.sql` | `CK_WipRejection_Group` dropped; the group moves to the lookup row |
| [`ClientCall_2026-07-23_SyncPlan.md`](ClientCall_2026-07-23_SyncPlan.md) | `A4`/`A5`/`A6` **closed** · `A2`/`A3` partial · `A1` still owed · **`W3` unblocked** · §3.1 **resolved** |

---

## 6. Still owed by the client

| # | Item | Why it matters |
|---|---|---|
| 1 | ⛔ **The spool OD formula** — `A1`, `Q33`, owed since 23 Jul and asked twice | Spool weight tracking and "assign as-is" stock handling |
| 2 | ⛔ **The temper formula worksheet** — three regimes named, none quantified | `PSG-D29`; the Flat→Flat regime also needs a **new wire property table** |
| 3 | ⛔ **The rod footage formula worksheet**, and the `± x ft` tolerance | `Q10` / `OI-45`; `FR-153`'s ±2 % variance threshold |
| 4 | ⛔ **Material Loss footage values** — every field is empty pending testing | Threading WIPREJ has no quantity |
| 5 | **Delay codes, Status and Delay Buffer for the 36 new reasons** — all blank | We are minting codes the client has not seen |
| 6 | **A group for each of the 72 WIPREJ reasons**, or agreement that grouping is ours | `CK_WipRejection_Group` |
| 7 | **A threading WIPREJ reason** | Answer 4 mandates the transaction; no reason code exists |
| 8 | **Are `[PLC §8.2]`'s other four conditions still inhibits?** | Five P1 test cases and two FRs ride on them |
| 9 | **What sets `Supervisor Monitor`**, given answer 9 is "No" | `Q20` |
| 10 | **Codes for `OperatorBreak` / `ShiftChangeover` / `AwaitingSupervisor` / `SafetyObservation`** | Four SRS reasons with no equivalent |
| 11 | ⛔ **Printer topology** — two printers at FL1 Operator Station, none at FL3, *"two SATOs at FL2?"*, and Zebra-vs-SATO for high-temp | `wip_stations.PrinterName` is one per station |
| 12 | **What `Return to Stock @ Payoff` prints, and what transaction produces it** | No home in the repository |
| 13 | **Is a `Call Supervisor` action required on the flat wire inhibit dialog?** | On both real screenshots; in no requirement |
| 14 | **Bob's and Shannon's review** — Tim asked for it in the covering note | Tim's own framing is provisional |

---

## 7. Attachment and image inventory

One attachment; extracted and read in full.

| File | Content |
|---|---|
| `Reason Codes.xlsx` | `Down Time Reasons` (142 rows) · `WIPREJ Reasons` (100) · `IT Inhibit Reasons` (11) · `Sheet4` — **empty**, but it carries all 8 images |
| `image001–006.png` | Current WIPREJ dropdown screenshots — source of the reason list |
| `image007.png` | Live IT Inhibit pop-up, machine A — 9 conditions, `Call Supervisor` button |
| `image008.png` | Live IT Inhibit pop-up, machine B — 9 conditions, `Call Supervisor` button |

⚠ **The workbook's meaning is in cell fill colours** (§3.1). Any re-reading that flattens it to text
loses the classification entirely, and the *"does not apply"* state is unlabelled.

---

## Related Documents

| Document | Why |
|---|---|
| [ClientCall_2026-07-23_SyncPlan.md](ClientCall_2026-07-23_SyncPlan.md) | The questions this answers; `A1`–`A6`, `C1`–`C16`, and the §3.1 conflict resolved here |
| [ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md](ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) | The Setup/Handling Times and Material Loss tabs are the other half of answers 4 and 13 |
| [PLCTagSpecification.md](../../20-architecture/PLCTagSpecification.md) | §8.2's five set conditions; the new dancer and jog read surface |
| [pause_run.js](../../50-frontend/mockups/pause_run.js) · [wip_rejection.js](../../50-frontend/mockups/wip_rejection.js) | The two dialogs whose vocabularies change |
| [10_CommonDB_Insert_WIPStations_FlatWire.sql](../../30-database/scripts/10_CommonDB_Insert_WIPStations_FlatWire.sql) | `PrinterName` and the invented printer names — §4.4 |
