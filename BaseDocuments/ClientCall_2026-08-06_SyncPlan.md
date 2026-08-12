# Client Call 6 Aug 2026 — Action Items and Document Sync Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 6, 2026
**Status:** **Registers applied 6 Aug 2026.** The eight decisions are recorded against `Q73`, `Q31`–`Q73 item 6`, `OI-13`, `G22`, `G34`, `G35` and the generation spec's edger section. Artifact-level propagation (SRS, contracts, DDL, mockups, phase files) is sequenced in §5 and **not yet executed**.
**Source:** Client call 6 Aug 2026, 10:59 UTC, 39m 50s — Tim O'Brien, Bob Scott, Shannon Riotte (United Aluminum); Srikanth Prabhala, Yogender Punia, Shray Anand, Divesh Malhotra, Waseem Khan, Ritika Raheja, Jaspreet Singh, Vicky Arora (Nagarro). Transcript: [`Shopfloor _ Review Priorities _ Discuss Open Items _ Use Time For Demos (35).docx`](<Shopfloor _ Review Priorities _ Discuss Open Items _ Use Time For Demos (35).docx>) — Teams meeting recording transcript, filed in this folder alongside this document.
**Registers touched:** `Q##` ([FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md), 95 → 99) · `OI-##` ([FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §11) · `G##` ([back-matter.md](../MVP-1/DevelopmentPlan/ShopfloorPlan/back-matter.md), G33 → G35) · `PSG-D`/`PSG-Q` ([PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md))

---

## 1. Why this call mattered

Two of the eight decisions close items that were **actively blocking build work**, and two are **new physical facts that no artifact in the repository contains**.

| | What it unblocks |
|---|---|
| **`Q73` answered** (rod consumption sequence) | `G22` has stood since 1 Aug as a **knowingly wrong rule** — staging refuses any rod whose order differs from the established one, which `Q70` made wrong on 30 Jul, and the correct replacement was explicitly waiting on this answer. [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md) §5.3 carries the wrong rule with a `[CLIENT INPUT REQUIRED]` note. **Phase 4 staging validation** |
| **`OI-13` flow specified** (wire break) | `FR-280`–`FR-282` are marked **"Not deliverable"** in [05-SprintPlanAndBacklog.md](../MVP-1/ProjectPlan/05-SprintPlanAndBacklog.md), story `FW-N08` is **blocked**, and `TC-350`–`TC-352` are written-and-blocked in the test plan. The flow now exists; only the persistence target is missing (`G34`) |
| **Edging is roll-forming, not knifing** (new) | [PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) treats the edger purely as an **area correction** (§3.3.4, round vs square) and describes over-width material as *"trimmed or upset"*. Tim's correction adds a **whole formula subset** and makes the final stand a **skim pass** |
| **FM2 has two dancers with two modes** (new) | Nothing models a dancer on FM2 — no lookup row, no `PassScheduleComponent`, no tag element on any line. And **tension mode contradicts** `PSM012` / master spec §233, *"tension is derived from speed, never entered manually"* (`G35`) |

Nothing decided on this call **reverses** a delivered artifact, which is the material difference from the [30 Jul call](ClientCall_2026-07-30_SyncPlan.md) — that one carried three reversals persisted in DDL, contracts and mockup JavaScript. This one adds and closes.

---

## 2. Decision ledger — the eight answers mapped to register IDs

| # | Topic | Register ID | New status | Effect |
|---|---|---|---|---|
| **D1** | Rod consumption sequence: **full → partial → multi-order**, when welding is involved | **`Q73`** · new **`Q73 item 6`** | `Decided` | Closes `Q73`, resolves **`G22`**. Validation at pre-check-in **and** check-in. See §3.1 |
| **D2** | Wire break with a weld keeps the **same alpha** | **`OI-13`** · new **`G34`** | Flow `Decided` — persistence undefined | Gives `FR-280`–`FR-282` a flow at last; the table is still open. See §3.2 |
| **D3** | Wire break where the customer **accepts no welds** → Z-mill coil-break logic | new **`Q31`** | `Open` — principle decided | Supervisor disposition point on both pieces. See §3.3 |
| **D4** | FM2 stands re-confirmed **S1 = 8″, S2 = 6″, S3 = 6″** | **`Q85`** / `D-26` | Unchanged — corroborated | Independent client confirmation of the 4 Aug correction. No edit |
| **D5** | Edgers sit **between S1/S2 and S2/S3**; **none at the mill exit** | **`G29`** note | Unchanged — sharpened | *"Edgers at S2 and S3"* is confirmed as **entry-side**. Proposed tag paths stand. See §3.4 |
| **D6** | Edging is **vertical profiling roll-forming**, its own operation with its own formulas; **S3 is a skim pass** | new **`PSG-D24–D26`** · **`PSG-D24`–`D26`** · **`PSG-Q27`–`Q62`** | `Open` — data owed | New generation-spec section; the *"trimmed"* wording is wrong. See §3.4 |
| **D7** | FM2 carries **two dancers**, each with **dancer mode and tension mode** | new **`Q32`** · new **`G35`** | `Open` | Unmodelled in schema, tags and pass schedule; contradicts `PSM012`. See §3.5 |
| **D8** | Output multiples: **FL1 ~1,800 lb**, **FL2 800/900 lb** | `Q18` / [Spool.md](../MVP-1/RequirementDocuments/Spool.md) | Unchanged — corroborated | Matches the 30 Jul figures. Supplies the worked example in §3.1 |

---

## 3. The decisions in detail

### 3.1 D1 — the consumption sequence, and the two corrections it went through

Shray opened with the case: three coils, one of which carries **two orders**, and an operator free to pick any of them. If he starts with the multi-order coil, order 2's tail has nowhere to go and the weld cannot be made.

**The rule as finally agreed:**

1. **Full coils first.**
2. **Partials next** — a partial is a **back-to-stock**.
3. **Coils carrying multiple orders last**, always. *"There can be no other option for it because it has a second order."*
4. Full coils of the **same order** in the middle may be taken in **any order** — *"it won't make a difference."*
5. Operators work a **pick list in planned order**, the same pattern as the mills. An operator **may not jump a multi-order coil to the head of the line**; that is a **validation in the flat wire interface**, not a UI convention.
6. **Where there is no welding**, sequence is free — subject to `Q73 item 6` below.
7. **The validation applies at pre-check-in and at check-in.** Srikanth: *"in case they do not do a pre-check-in, it applies at the check-in."*

> **Recorded because it was stated three ways before it settled.** Srikanth first gave *full → partial → multi-order*. Tim then said *partials first* (11:03). Srikanth challenged it (12:04), and Tim corrected himself explicitly — *"Shray got this correct. The partials are at the end. It's full coils first, partials, and then coils with multiple orders"* (12:30). **The final rule is item 1–3 above.** Anyone reading only the first half of the transcript will get it backwards.

**The worked example given (D8 supplies the numbers).** An order of **44,000 lb** including upper tolerance, incoming rod at **~5,500 lb**, output from FL1 in multiples of **~1,800 lb** and from FL2 in multiples of **800/900 lb** → planning lays out **~9 A-rods: 8 full, 1 partial**. With welding: the eight full rods run first, then the partial and any multi-order rod.

**`Q73 item 6` — the residual.** Yogender argued (14:28) that the multi-order-last rule must hold **even without welding**, because order 1 must complete before order 2 starts on a continuous feed. Srikanth agreed — but his confirming sentence was *"that's why the multiple orders on the data that will be processed at the last **if welding is involved**"*. Both readings are on the recording, and they differ by one validation branch. Logged rather than assumed.

**Consequence for `G22`.** The replacement rule can now be written: `planning_routings` returns **orders (plural)**, order membership becomes an **ordered set** rather than a single established order, `RodStaging.OrderId` means *the order this staging is being consumed for*, and the ordering constraint is the three-tier sequence above. Applies to **stock orders** as well (Shray asked; confirmed).

### 3.2 D2 — a wire break does not create a new alpha

Tim, with Bob and Shannon confirming:

1. The wire breaks — on FL1, between the two drawing blocks, or between a drawing block and the flattening mill.
2. **The machine stops.** A physical component — *"a dancer or something"* — trips a tag that tells the system a stop occurred.
3. The system **prompts for the reason**: WIP rejection, a tangle (restart the machine), or a break.
4. If it is a break, the system asks **WIP reject, or weld and continue**.
5. On weld-and-continue: **no new alpha.** Bob: *"If it's not actually splitting and you're welding back together, it's the same alpha, no new alpha."* Shannon: *"because it's coming off the machine as one piece."*
6. The **weld is recorded** with its footage position — Shannon: *"we will have a record that there's a weld in there, so if there's ever some problem we'll know where the footage is"* — and the material is **flagged in SCADA**.

This is consistent with `Q61` Case 1 (a same-spec event mid-run keeps one alpha and records an event at a footage position). It does **not** change `Q61`.

**What is still missing — `G34`.** Where the stop reason, the break confirmation, the `WBK002` OD verification and the `WBK003` defect inspection are **persisted**. Candidates to evaluate: `RunPauseEvent` (the stop and its reason), `WeldEvent` (the weld and its footage), `WipRejection` (the reject branch). Until that lands, `FR-280`–`FR-282` stay undeliverable and `FW-N08` stays blocked.

### 3.3 D3 — no-weld customers get the coil-break treatment

Yogender asked what happens when the customer does not accept welds. Tim's answer, with Shannon converging on it:

- It is handled *"just like the current e-mails where if we have a coil break and we're not going to meet the planned weight"* — i.e. **the existing Z-mill coil-break logic**.
- A **supervisor decision point on both pieces**: return to warehouse · scrap · continue processing · put on hold · **seek a concession**.
- The judgement is made on the **total linear footage / weight already on the FL1 spool** against the planned weight. Enough material → approach the customer for a concession (*"will you still take this, it's underweight by 250 pounds"*). Early in the run → **WIP reject**, strip the spool, mount an **empty spool**, **replan** onto another input rod and rerun the order.
- Shannon: *"It could be returned to warehouse, it could be scrap, it could be continue processing, could be put it on hold — they're going to have to make a decision."*

Tim flagged the shape of the risk: this is a **one-off case** (a customer ordering one or two skids rather than a truckload, who also refuses welds), so it should not be over-engineered. Logged as **`Q31`**: the disposition vocabulary, the supervisor gate, whether the concession path reuses the existing coil-break e-mail flow, and where the decision is persisted.

### 3.4 D5 and D6 — the edger is a roll-former, and S3 is a skim pass

Tim's notes on [PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md), given verbatim on the call:

**Position (D5).** *"There's two edging devices and they sit between — one sits between S1 and S2, and the second sits between S2 and S3. On the exit side of the mill, there is no edging capability there."* The spec's *"edgers at S2 and S3"* is therefore correct read as **entry-side**, and there is no exit-side edger to model. The sequence is `S1 → E1 → S2 → E2 → S3`.

**Mechanism (D6).** *"Edging in this document is referred to as a knifing operation, where in our case we are using vertical profiling rollers to create our edge. It's not a cutting capability, it's an actual roll-forming capability."*

The per-pass physics as described:

| Stage | What happens |
|---|---|
| **E1** (between S1 and S2) | Width is **narrowed**. The displaced material expands **laterally and longitudinally** — length increases and the section **bulges in the middle**, so thickness rises slightly. **E1 also converts the section from round to square.** |
| **S2** | Flattens the bulge out; **the edge widens again** |
| **E2** (between S2 and S3) | Narrows the width back out |
| **S3** | The last draft, then a **skim pass** — **light reduction, no edging** — whose purpose is a **uniform cross-sectional area edge to edge**, not gauge |

**Why this is a formula subset and not a wording fix.** The spec presently handles the edge only through §3.3.4's area correction (`A = t·w − 0.2146·t²` for a round edge) and describes over-width material as *"trimmed or upset at the edger"* ([line 470](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md)). A roll-former **never trims** — there is no scrap stream at the edger — and it **feeds width back into length and thickness**, which changes the mass balance the allocation step depends on. Tim: *"there's actually another subset of formulas that needs to be used and they need to be treated like their own operation."*

Recorded as new **§3.3.11** in the spec — placed at the end of the 3.3 group rather than beside §3.3.4, so that **no existing §3.3.5–§3.3.10 cross-reference moves** — with **`PSG-D24`–`PSG-D26`** for the coefficients we do not have and **`PSG-Q27`–`PSG-Q28`** for the two questions that follow. **`PSG-D25` joins §12.3 as critical blocker `B5`**: without the partition coefficient the section entering S2 and S3 is unknown, so the finishing drafts are allocated against a guessed entry. `PSG-D24–D26` carries a pointer so the main register knows the item exists.

**Tim's overall verdict on the spec:** *"Well put together. There's a ton of math in here that I need to verify and it flows really, really nice. And if we can do this, I think this will be a fantastic tool for this process."*

### 3.5 D7 — FM2's dancers have two modes

*"On FM2 we are going to have two different modes on the mill dancers. The two dancers were essentially where the edgers are — between S1/S2 and S2/S3. Those dancers will have two modes: regular dancer mode, compensating speed control, and tension mode… similar to what we see on the current mills."*

Three things follow, and they are why this is `G35` rather than a note:

1. **There is no dancer on FM2 anywhere in the repository.** The dancer appears only as an FM1 component ([FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §156, [FlatWireProcessWalkthrough.md](../Analysis/FlatWireProcessWalkthrough.md) step 19). No `Stand`/`Drawer`/`Edger`-style lookup row, no `PassScheduleComponent` entry, no seed data.
2. **No tag element addresses a dancer** on any line — so a mode that the operator or the schedule selects has nowhere to be written and nothing to be read back from.
3. **Tension mode contradicts a stated rule.** `PSM012` and master spec §233 both say *"tension is derived from speed, never entered manually."* In tension mode it is not derived from speed. The rule needs qualifying by mode rather than deleting.

`Q32` asks: who selects the mode, is it per dancer or per line, is it a **pass schedule parameter** or a machine-side setting, does the system **write** it at check-in acknowledgement or only **read** it, and — for `[PLC]` to answer — what carries it.

---

## 4. Action items with owners and dates

| # | Action | Owner | Due |
|---|---|---|---|
| **A1** | Finish the **prediction calculator** and submit the answers to all outstanding question lists. Carries the formulas everyone is waiting on: **OD calculation, linear feed/footage, reductions, width calculations, edgers** (in progress at call time), **take-ups**. Feeds planning validation, pass schedule and item-template creation. *"I have to verify that all the math is correct and that I have made no mistakes… hoping to have this done by the end of the week."* | **Tim O.** | **End of week — 7/9 Aug** |
| **A2** | Return **annotated comments on `PassScheduleGenerationSpec`** — D5–D7 are the first tranche, delivered verbally; the math verification follows. *"I'm going to put a bunch of notes on there and send it over."* | **Tim O.** | With A1 |
| **A3** | Owed specifically to planning (Shray): **OD calculation formula, feed calculation, planning validation failures / coil-order rules** | **Tim O.** | With A1 |
| **A4** | **Review [PLCTagSpecification.md](../MVP-1/RequirementDocuments/PLCTagSpecification.md)** — not started; next after A1. This is what closes `PLC-Q02`/`PLC-Q04`/`PLC-Q05`, all Critical | **Tim O.** | After A1 |
| **A5** | Reshare the **updated generation spec** with the S1-8″ and edger-position corrections applied; update the **PLC document** with the details shared and reshare | **Yogender** | This week |
| **A6** | Begin **database planning** — slipped this week, started same day | **Yogender** | Started 6 Aug |
| **A7** | Capture the **D1 consumption-sequence validations** in the flat wire interface, at **pre-check-in and check-in**. The flat wire interface **estimate** is due end of next week | **Yogender / team** | Estimate ~**14 Aug** |
| **A8** | **Review the non-flat-wire-interface timelines internally and finalise them at the 7 o'clock meeting tomorrow.** Hard-dated on the call: *"It can't be any later than tomorrow."* Covers coil receiving with projections, gauge trace report, item template, planning. Start dates **10 Aug** for anything that can begin next week, otherwise **17 Aug** or **24 Aug**. **Do not wait on the flat wire estimate** — *"we are cutting very close now"* | **Ritika / Jaspreet / Divesh / Waseem** (chair: Srikanth) | **7 Aug 2026, 19:00** |
| **A9** | **Planning module** starts after the **21 Aug sprint** completes → **24 Aug**, built against **mock data**, with a buffer retained for rework when real data arrives | **Divesh / Shray** | **24 Aug** |
| **A10** | Send the **item-template mockup**; work with the team to **fake item data in the database table** so planning can pick it up — *"we have two weeks to figure out this mock data"* | **Srikanth + team** | ~**20 Aug** |
| **A11** | After Sunday's deployment and the **handheld migration**, start the **gauge trace report** changes for flat wire / projections | **Waseem** | After 9 Aug |

### Risks stated on the call

- **QC has not delivered the reduction rules and the format.** This is why Tim is building the calculator himself, why his other work was disrupted, and why **Sushant's 24 Aug start** on the item / pass-schedule tags is **at risk**. Srikanth: *"QC thing is a must for us, but we can only share with you the process or the mock-up that QC had sent us back then."* Mitigation agreed: proceed on the existing QC mockup plus faked data.
- **Tim is overloaded** — *"a major distraction this week"*; he took the generation spec home to read.
- The schedule is **tight against the 17 Aug start and the 14 Aug Phase-1 gate**. Srikanth: *"I think we are cutting very close now. We should not wait for flatware estimate to be ready."*
- **Planning will build on mock data** and expects rework — that buffer is explicit, not a contingency.

### Context — Sunday deployment (not flat wire)

No open concerns from Jaspreet, Waseem or Divesh. Window most likely **06:30–06:45**, confirmed with supervisors on Sunday morning; mills and furnaces run 24×7, so the window depends on being between passes or between coils. Files copied over ahead; **DB scripts run when the window starts**; **furnace logger and mail interface verified first**, production resumes, then the remaining applications are verified gradually. Screenshots already reviewed by Bob and Shannon. The web/planning release including the multiplier report is on track.

---

## 5. Propagation waves — not yet executed

Everything below §5's first wave is **documented, not done**. Wave W1 is complete as of 6 Aug 2026.

> ### ⚠ Re-pointed 11 Aug 2026 after the `Analysis/` → `RequirementDocuments/` consolidation
>
> The consolidation completed the per-screen migration: **five new owning specifications** were created — [`ActiveRunMonitor.md`](../MVP-1/RequirementDocuments/ActiveRunMonitor.md) (DB3), [`OutputCoilCompletion.md`](../MVP-1/RequirementDocuments/OutputCoilCompletion.md) (DB7), [`WipRejection.md`](../MVP-1/RequirementDocuments/WipRejection.md) (DB8), [`ShiftSummary.md`](../MVP-2/RequirementDocuments/ShiftSummary.md) (DB10) and [`RollAdjust.md`](../MVP-1/RequirementDocuments/RollAdjust.md) (DB11) — and `FlatWireShopfloorDashboards.md` ceased to be a requirements source. **Three consequences for the waves below:**
>
> 1. **W3's file paths are unchanged, but its section numbers may have moved.** `RodPreCheckin.md` §13 and `RodCheckout.md` §11 (Related Specifications) were rewritten to remove links into `Analysis/`, and `RodCheckout.md` gained a new **§7.2**, and `RocCheckin.md` a new **§4.3**. **Re-read the target sections before editing** rather than trusting the section numbers recorded here on 6 Aug.
> 2. **W8 gains two owning documents.** `wip_rejection.js` is now specified by `WipRejection.md` and `pause_run.js` by `ActiveRunMonitor.md`. **A mockup change in W8 must be reflected in its owning specification**, which was not true when W8 was written — neither script had an owner then.
> 3. **W4–W7 are unaffected**, and **W3, W5 and W6 remain blocked on `Q32` and `Q73 item 6` regardless** of this reorganisation. Nothing here unblocks a wave.
>
> Six new open items were raised by the consolidation — **OI-98** to **OI-103**, registered in master spec §11 — and none of them blocks a wave below.

| Wave | Targets | Files | Risk |
|---|---|---|---|
| **W1 — Registers** ✅ | [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) (`Q73` decided; `Q31`–`Q73 item 6` added; index + change log), [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) (`OI-13` and its three citations), [back-matter.md](../MVP-1/DevelopmentPlan/ShopfloorPlan/back-matter.md) (`G22` resolved; `G34`, `G35` added; `G29` note) | 3 | L |
| **W2 — Generation spec** ✅ | [PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) **v1.2 + v1.3**. *v1.2 — the physics:* new §3.3.11, the *"trimmed or upset"* wording, the §2.3 route table, §3.3.9, `PSG-D24`–`D26`, `PSG-Q27`–`Q62`. *v1.3 — the propagation into the calculation:* **§6.3 Steps 9, 10, 11 and 12 rewritten plus new Step 9A (edger passes)**; **§3.3.5 allocation restructured** around the S3 skim; the **§3.3.6 tension omission** found and raised as `PSG-D27`/`PSG-Q29`; validations **V36–V38** added with V10/V20/V27/V30 amended; §6.1 flowchart, M4/M8 master rows, §8.7 blocked-validation table. `MVP-2/SRS/PassScheduleGenerationSpec.docx` re-rendered via [build_docx.py](../MVP-1/DevelopmentPlan/Tools/build_docx.py).<br><br>**Two gap audits followed the same day, taking the spec to v1.4 and then v1.5** — thirty defects, twelve of them algorithmic. They are recorded here because several were *caused* by W2: propagating the edger physics into a thirteen-step sequence written before edgers existed left five steps consuming quantities no step produced. The largest: **the width chain was never computed**, and with **no edger at the mill exit the final width leaves S3**, so `PSG-D08` governs finished-goods width and not just the FL1 spool's. **Eight further client items** are owed — `PSG-D31`–`D35`, `PSG-Q32`–`PSG-Q34` — of which two are High: **rolling friction stated separately from drawing friction**, and the **grip criterion for the round → flat pass**. Also **`PSG-D32`**, the planned output multiple, which is `D8` on this call: Step 12A had been splitting orders against take-up *ratings*, roughly halving the unit count | 1 (+1 generated) | M |
| **W3 — Requirement docs** | [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md) §5.3 order-membership rule, §6.2 sequence authorisation, §11 open-items table and the sign-off checklist (`Q73` row closes) · [RocCheckin.md](../MVP-1/RequirementDocuments/RocCheckin.md) — the same validation at check-in · [WeldEvent.md](../MVP-1/RequirementDocuments/WeldEvent.md) — the break-weld case and same-alpha rule | 3 | **H** |
| **W4 — SRS / requirement text** | [02-SRS.md](../MVP-1/ProjectPlan/02-SRS.md) — `FR-280`–`FR-282` gain a persistence target once `G34` closes; new `FR-###` for the consumption sequence (**do not renumber; supersede in place**) · [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §5 event table | 2 | M |
| **W5 — Contracts + schema** | [APIContracts.md](../MVP-1/DevelopmentPlan/APIContracts.md) and [04-APIContract.md](../MVP-1/ProjectPlan/04-APIContract.md) — staging/check-in sequence-validation responses · `FlatWire_DDL_04_Runs.sql` (`RodStaging.OrderId` semantics) · `FlatWire_DDL_01_Lookup.sql` (a dancer component, if `Q32` says the mode is scheduled). **Re-run `FlatWire_DDL_RunAll.sql`; table count stays 27 unless `Q32`/`G34` add one** | 4 | **H** |
| **W6 — PLC surface** | [PLCTagSpecification.md](../MVP-1/RequirementDocuments/PLCTagSpecification.md) — **a read-only dancer element and mode — authored 12 Aug 2026** (`PLC-Q18`, test `C12`). **The write surface is still blocked**: `Q32` is now `Q65`, and the 23 Jul meeting contradicts the 6 Aug position on whether the mode is scheduled at all; **the client doc owns every path string** · [PLCTagImplementation.md](../MVP-1/DevelopmentPlan/PLCTagImplementation.md) — **carries no path strings by rule** | 2 | M |
| **W7 — Plans + tests** | [05-SprintPlanAndBacklog.md](../MVP-1/ProjectPlan/05-SprintPlanAndBacklog.md) (unblock `FW-N08`), [06-TestPlanAndTestCases.md](../MVP-1/ProjectPlan/06-TestPlanAndTestCases.md) (`TC-350`–`TC-352`), `phase-04`, `phase-06`, `phase-07` | 5 | M |
| **W8 — Mockups** | `pause_run.js` — the machine-stop prompt chain (stop reason → break → WIP reject or weld-and-continue) · `dashboard_2a_rod_precheckin.html` — pick-list ordering and the sequence refusal · `wip_rejection.js` — the no-weld disposition set.<br><br>**Since 11 Aug 2026 each of these has an owning specification that must be updated with it:** `pause_run.js` → [`ActiveRunMonitor.md`](../MVP-1/RequirementDocuments/ActiveRunMonitor.md) §6 · `wip_rejection.js` → [`WipRejection.md`](../MVP-1/RequirementDocuments/WipRejection.md) §3–§4 · `dashboard_2a_rod_precheckin.html` → [`RodPreCheckin.md`](../MVP-1/RequirementDocuments/RodPreCheckin.md) | 3 (+3 specs) | **H** |

**Blocked on client input:** W3 partly (`Q73 item 6`), W5's dancer column and **the write half of W6** (`Q32`, renumbered `Q65`; its read half was executed 12 Aug 2026), W4's `FR-280`–`FR-282` (`G34`, which is ours to decide, not the client's).

**Convention reminders for every wave:** update **Last Updated** on each document touched and append its change-log row to [`../CHANGELOG.md`](../CHANGELOG.md) — **not to the document itself**, which no longer carries a `## Change Log` section (consolidated 12 Aug 2026; waves W3–W8 were written before that change); strike resolved register items through with a `DECIDED (date)` note and **never delete them**; keep `Q##` numbering contiguous; phase files must not restate foundations text; and **no tag path string may be written outside `PLCTagSpecification.md`**.

---

## 6. Send back to the client (open, blocking, or owed)

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | **The prediction calculator and the formula set** — OD, feed, reductions, widths, edgers, take-ups (A1) | Tim O. | `FW-013`, planning validation, item template |
| 2 | **`Q73 item 6`** — does multi-order-last hold when **no welding** is involved? | Srikanth / Tim O. | One branch of the check-in validation |
| 3 | **`Q31`** — the no-weld disposition set, the supervisor gate and whether the concession path reuses the coil-break e-mail flow | Tim O. / Shannon R. | Wire-break screen scope |
| 4 | **`Q32`** — dancer mode: who selects it, per dancer or per line, scheduled or machine-side, read or written | Tim O. / Engineering | `G35`, the PLC dancer element, pass schedule shape |
| 5 | **`PSG-D24`–`D26`** — edger width-reduction limit, the spread/bulge partition coefficient, the round→square transition at E1 | Tim O. / QC | The edging step of the generation engine |
| 5a | **`PSG-D31`** and **`PSG-Q32`** (both **High**) — **rolling** friction stated separately from **drawing** friction, and the criterion by which the plant judges bite on the **round → flat** pass. The bite limit is quadratic in μ, so one number for both contacts is an order-of-magnitude error; and the flat-entry relation applied to a round entry rejects the spec's own nominal example | Tim O. / Process Eng. | The bite check — currently unrunnable on any pass |
| 5b | **`PSG-D32`** — the **planned output multiple** per line (`D8`: ~1,800 lb FL1, 800/900 FL2), as distinct from the take-up rating. Take the figure planning already uses; it must not resolve to two values | Tim O. / Planning | Step 12A's order split; overlaps `Q18` |
| 5c | **`PSG-D33`**–**`PSG-D35`**, **`PSG-Q33`**, **`PSG-Q34`** — as-rolled incoming edge geometry, the torque lever arm, coefficient sanity bounds, permitted edger bypass combinations, and whether a requested line is a constraint or a default | Tim O. / Engineering | The FL2 spool path, the drive-power check, and two validations that check against data never requested |
| 6 | **The QC reduction rules and format** — the item blocking Sushant's 24 Aug start | QC (via Tim O.) | Item template, pass schedule tags |
| 7 | **`PLC-Q02` / `PLC-Q04` / `PLC-Q05`** — confirmation of the tag paths, the FM2 station rename and the measure grammar (all Critical, pending A4) | Tim O. / Engineering | Phase 4 tag push, commissioning `C1`/`C11` |
| 8 | Carried from 30 Jul and **still owed**: tolerance values (`Q22`), the 1920×1080 answer (`Q26`), `Q25`, the `Q68` residual, the customer weight-range field (`Q18`), the PIN validation source (`OI-38`), the bundle gross weight (`OI-97`) | Tim O. / Bob S. / IT | Seed data, Phase 1 canvas, Phase 4 |

---

## Related Documents

| Document | Why |
|---|---|
| [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) | Authoritative register — W1 |
| [ClientCall_2026-07-30_SyncPlan.md](ClientCall_2026-07-30_SyncPlan.md) | The precedent for this document; `Q73` was raised there |
| [PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) | Target of D5–D7 — W2 |
| [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md) | Carries the wrong order-membership rule D1 replaces |
| [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) | `OI-##` register and the reconciliation authority |
| [back-matter.md](../MVP-1/DevelopmentPlan/ShopfloorPlan/back-matter.md) | `G##` register — `G22` resolved, `G34`/`G35` added |
| [PLCTagSpecification.md](../MVP-1/RequirementDocuments/PLCTagSpecification.md) | Target of A4 and of the `Q32` dancer element |
