# Flat Wire Mill — AI Opportunities

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 4, 2026 — first issue. Eight ideas that change the shape of the problem, plus a 48-item catalogue beneath them
**Document Type:** Opportunity assessment — direction only
**Status:** ⚠ **Direction only. Nothing in this document is scope.** No item here is costed, scheduled, assigned to a phase or committed. It mints no `FR-`, `G`, `Q` or `OI-` identifier and changes no register. Its own ids — `B1`–`B8` and `AI-01`–`AI-48` — are **document-local**, in the manner of `[VS §14]`'s `PP-##`
**Owner:** Programme management
**Audience:** Sponsors, Operations, Process Engineering, delivery leadership
**Sources:** [`../10-requirements/screens/PassScheduleGenerationSpec.md`](../10-requirements/screens/PassScheduleGenerationSpec.md) §13 · [`../10-requirements/screens/PassScheduleManagement.md`](../10-requirements/screens/PassScheduleManagement.md) §9 · [`VisionAndScope.md`](VisionAndScope.md) · [`../30-database/DatabaseDesign.md`](../30-database/DatabaseDesign.md) · [`../20-architecture/PLCTagSpecification.md`](../20-architecture/PLCTagSpecification.md) · [`../90-registers/Gaps.md`](../90-registers/Gaps.md) · [`../90-registers/Questions.md`](../90-registers/Questions.md) · [`../10-requirements/MasterSpecification.md`](../10-requirements/MasterSpecification.md) §10–§11
**Shortcode:** `[AI]`
**Part of:** `00-overview/` — index: [DOCUMENTS.md](../DOCUMENTS.md)

---

## 1. Two different things are called AI here, and only one of them is this document

**AI-assisted development** is a recorded client decision of 23 July 2026 and the basis of the
retention factors in `[DE]`. It is about how fast this project is built.

**AI product features** — what the delivered system does for United Aluminum — are what this
document is about.

`[DE]` warns against conflating them by name, and the warning is repeated here because it is the
most likely misreading of this document:

> *"the 'AI-assisted generation' in `PassScheduleGenerationSpec.md` is a **product** feature — ML
> proposing pass schedules from production history — and is unrelated to development productivity.
> **Do not conflate the two.**"*

Nothing below claims any delivery saving.

---

## 2. Why this module, specifically

### 2.1 This is not a blank page

`[PSG §13]` already carries a six-item AI roadmap, authored as post-go-live direction: *automatic
optimisation · SPC feedback integration · historical schedule learning · predictive quality analysis
· AI-assisted generation · digital twin simulation*. `[PSG]` also fixes the framing that governs
everything here:

> *"Models trained on the plant's own production history could propose starting points for novel
> products, always subject to the same engineering validation and approval gate. **This complements
> the physics-based engine; it does not replace it.**"*

`PassScheduleManagement.md` §9 adds *data-driven refinement* — using accumulated SPC results,
rejections and throughput to tune the engine's coefficients. **Those items are asserted in those
documents and are cited, never restated, here.** Several of this document's ideas are readings of
them rather than new inventions, and each says so.

### 2.2 Three facts about this system, none of them generic

**Every event carries a footage position.** Welds, die changes, roll overrides, SPC checkpoints,
pauses, rejections and readings are all footage-stamped, and `CoilTraceability` resolves coil
footage to rod footage to supplier heat. The claim is not *"the coil is traceable"*. It is that
**every inch has a causal history**, and that continuous welded feed is what makes it so — a process
no pancake-coil producer runs.

> ⚠ **The trap that comes with it.** Coil footage is **run-cumulative** and spool footage is
> **spool-local** (`[DBD §6.4]`, `OI-25`). Joining the two chains without re-anchoring returns a
> plausible wrong answer. **Weight is the safe common currency.**

**Setpoint and actual are paired by construction, not by retrofit.** `PassSchedule` holds the
targets and `PassScheduleComponent` the component setpoints; `RunReading` holds measured gauge,
width and speed keyed by footage; and `CoilOutput.PassScheduleSnapshot` freezes the exact
configuration each coil was made under, permanently (`NFR013`). Configuration in, measurement out,
joined on the run.

Two tables carry labelled outcomes already:

| Table | What makes it valuable |
|---|---|
| `SpcMeasurement` | `TargetValue` / `ToleranceValue` / `ActualValue` with `Deviation` and `InSpec` as computed columns — pre-computed labelled deviation. ⚠ See `G51` in §5 |
| `RollOverride` | ⭐ **The richest training row in the schema.** Old value → new value → `Delta`, *plus* the `MeasuredGaugeIn` / `MeasuredWidthIn` that prompted the change, *plus* the reason code, *plus* the footage position. A labelled human decision with its own cause attached |

**The repository has already invented the governance pattern AI needs.**
`RodOrderConsumption` stores `LbPerFtUsed`, `ConversionBasis` and `ConverterVersion` on the row, so
that a later formula change never retro-changes history. That is model provenance, built for
arithmetic. §3.6 is the observation that it generalises.

### 2.3 And the fact that makes the obvious answer wrong

**The three lines have produced nothing.** New lines, new PLC hardware, a new standalone database —
zero domain rows at go-live. All pre-production telemetry comes from a simulator built on our own
assumptions (`G39`), whose `[SIM §5.6]` table permanently ignores lateral spread and does not compute
rolling force. A model trained on it learns our assumptions back.

The standard response to that is *wait for data*. **Waiting is the wrong answer**, and §3 is eight
reasons why.

---

## 3. Eight ideas that change the shape of the problem

Each one takes something the project currently records as a *problem* — no data, a forbidden control
loop, a drifting simulator, an unanswered formula, a contractual traceability burden — and uses it
as the mechanism.

### 3.1 `B1` — Run the October trial as a designed experiment, not just a trial

**The idea.** Choose which samples to run for **information value**, not only to prove the line
works. Optimal experimental design selects the product and setpoint combinations that shrink
uncertainty on `C₅`, `C₆`, `k` and mill modulus fastest, and re-plans after each run.

**Why it matters here.** It inverts the project's defining constraint: *"we have no data"* becomes
*"we have one trial and a choice about what it teaches us."* `[PSG §12.3]` already sorts the
blockers this way — B1, B2 and B3 are data requests, while **B4 and B5** *"are different in kind:
they require measurement, and cannot be resolved by asking harder."* `[PSG §12.5]`'s prerequisite
`P5` is trial instrumentation.

**And coverage is not incidental.** `G90` records that the client's round→flat correlation is
undefined over part of its input range and that the nominal product sits roughly three points above
its validity floor. *Where* the samples fall decides whether the correlation is characterised at all
in the region United Aluminum actually sells into.

> ⏳ **This is the only item in this document with an expiry date.** A trial planned for coverage
> produces a calibrated mill. A trial planned to prove the line runs produces a line that runs, and
> coefficients that are still placeholders.

### 3.2 `B2` — Physics plus a learned correction, never physics *or* ML

**The idea.** `prediction = the client's F16 / F19 / F20, plus a learned residual`, the residual
carrying an uncertainty band. A grey-box model, not a black box. This is a reading of
`[PSG §13]`'s *SPC feedback integration*, not a new proposal.

**Why it matters here.** It is the literal, mathematical form of the rule `[PSG]` already wrote —
*complements the physics-based engine; does not replace it*. Three consequences:

| Property | Why it follows |
|---|---|
| **Works with very little data** | The physics carries most of the signal; the model only learns what the formula gets wrong. It does not need the corpus a from-scratch model would |
| **Stays auditable** | The physics term and the correction term display separately. An engineer can see how far the machine has pulled the formula, and in which direction |
| **Answers `PSG-D35`** | That item exists because *"an uncalibrated prediction and a calibrated one look identical on the screen."* Show a confidence interval on predicted width and that stops being true |

The third is a single change to one screen, and it is the one that decides whether engineers trust
the number at all.

### 3.3 `B3` — Pre-train on the plant United Aluminum already has

**The idea.** Flat wire has no history. United Aluminum has decades of it — the existing production
and mill databases (`[DBD §6.6]` already names `MillsDB..RollCoil_GetTotalRolledWeightinlastMillRun`
as prior art for rolled weight), plus lot chemistry and every heat ever consumed from the vendors
`[VS §3.1]` names. Alloy behaviour, density, temper response, incoming-material quality, and delay
and downtime patterns transfer. Pre-train there; fine-tune on flat wire.

**Why it matters here.** It dissolves *"zero data"* for a whole class of features rather than one at
a time. **Supplier-heat quality scoring needs no flat-wire data at all** — it could be answered
before the first coil is made, and it is purchasing leverage rather than a shopfloor tool.

> ⚠ **Confirm before relying on it.** `D-06` makes `SlitterInterface` explicitly **not** a reference.
> That rule is about *code and structure*, not about reading data — but the distinction should be
> confirmed rather than assumed. `D-32` freezes the shared schema against *writes*; reading it is
> untouched. And `OI-117` leaves `Rod.SupplierHeat` with no source, which has to be closed before
> any heat-level model has a key to join on.

### 3.4 `B4` — Sell the coil's genome, not just a certificate

**The idea.** Because every event is footage-stamped and genealogy resolves to supplier heat,
United Aluminum can ship a **per-foot quality record**: for every foot, the gauge, the width, which
rod and heat it came from, the distance to the nearest weld, the die age at that moment, the SPC
state. AI's role is to compress it, summarise it, flag the at-risk feet **before** shipment, and
answer questions against it in plain language.

**Why it matters here.** It changes what United Aluminum sells rather than how it runs. `[VS §1.2]`
names welding-wire buyers as a market UAL cannot serve today and *"the most demanding on
traceability"*; `[VS §4.2]` records that some impose a **contractual maximum weld count per coil**,
because exceeding it jams their automated welding equipment. And `G89` records the client's own
position on tracking that limit: it *"would require the operator to track."*

A per-foot record turns that liability into a differentiator. UAL ships the evidence, prices on it,
and can warn a customer about a specific footage range proactively instead of receiving a complaint
about it later.

### 3.5 `B5` — Acknowledged autonomy: the pattern that makes AI admissible here

**The idea.** AI never writes to the PLC. It pre-computes the next configuration and presents it as
a **one-tap acknowledgement carrying its reasoning and its confidence**. The human still decides;
the decision simply arrives with evidence attached and takes seconds rather than minutes.

**Why it matters here.** Every governance rule in this project points the same way — `[VS §8]`
forbids any software stop command, the application is a **gatekeeper** that reads line state,
`VO-1` requires every foot to be made under a configuration a human explicitly acknowledged, and
`D-09` forbids an auto-applied pass schedule.

Read as a blocker, that set of rules kills automation outright. Read correctly, it *specifies the
interface*: **the constraint is not that a human is slow, it is that a human is accountable.** This
pattern takes most of automation's value and violates none of it — and it is the design decision
that determines whether any other item in this document can ever ship.

> **The governing rule for every recommended item in this document: AI proposes, a human approves,
> and the approval is what reaches the machine or the customer.** That is not a concession. It is
> `[PSG §13]`'s framing and `VO-1`'s requirement.

### 3.6 `B6` — Model provenance on the certificate path

**The idea.** Any AI-derived number that touches a contractual artefact records, on the row itself,
which model version, which coefficients and what confidence produced it — exactly as
`RodOrderConsumption` already records its conversion basis and converter version so that a formula
change never retro-changes history (§2.2).

**Why it matters here.** This is what makes AI *shippable* inside a contractual traceability chain,
and it is rare in manufacturing. `G91` states the failure mode precisely: with no home for the
coefficients, *"the first calibration lands as a code edit or a spreadsheet outside the system…
a stale coefficient would then be invisible."*

An invisible stale coefficient inside a certificate is a recall. The repository has already solved
this problem once, for arithmetic. The move is to notice that and generalise it.

### 3.7 `B7` — One objective across allocation, sequencing, annealing and quoting

**The idea.** Rod-to-order allocation, line loading, anneal capacity and quotation are four separate
human judgements today. One optimiser, one objective — margin per hour, subject to due dates,
tooling life, weld-count caps, anneal capacity, and the constraint that **FL3 blocks both other
lines** (`Q67`).

**Why it matters here.** ⭐ **It is operations research, not machine learning, so it needs no
production history whatsoever.** The constraints and the costs already exist. It is deliverable
before the lines make a coil, and it is the largest financial number in this document.

Every constraint is documented, and every one is resolved by hand today:

| Constraint | Register |
|---|---|
| Three-tier consumption sequence — full coils, then partials, then multi-order last, worked as a pick list in planned order | `Q73` |
| Two orders on one rod with different pass schedules, where **the boundary cannot be crossed with the rod mounted** | `Q48` *(Critical)* |
| What overrun past the allocation is acceptable — *no bound exists anywhere* | `Q50` |
| A shared rod exhausting before the order is satisfied — top up, or stay short | `Q52` / `Q53` |
| FL1 : FL2 throughput ≈ 3 : 1, so open capacity falls unevenly by order mix; FL3 blocks both | `Q67` |
| Anneal scheduling rules and shared furnace capacity | `OI-64` |

And it replaces a **live client spreadsheet** — the one whose output the repository already
reproduces end to end in the rod-allocation worked examples.

### 3.8 `B8` — Turn the simulator from a risk into the twin

**The idea.** Make the simulator's divergence from the real line a monitored, minimised metric.
Every real run becomes a test of the simulator. As it converges it becomes three things at once: a
safe place to try a schedule, a generator of **rare events nobody can afford to wait for** such as
wire breaks, and an operator training rig with no material cost. This is a reading of `[PSG §13]`'s
*digital twin simulation*.

**Why it matters here.** `G39` currently reads purely as a risk — the simulator, built from our own
assumptions, *"becomes the de facto spec of machine behaviour"* with nothing reconciling it to the
line, and *"the divergence surfaces in the October commissioning window."* Nothing about that
changes except whether anyone measures the divergence. Measure it, and the liability becomes the
asset that makes the digital twin real.

⚠ Today's simulator is **not** a physics model: `[SIM §5.6]` records lateral spread as ignored and
rolling force as not computed, both as permanent simplifications.

---

## 4. The catalogue

Forty-eight opportunities in eight themes. The **B** column names which of §3's ideas each belongs
to. **No item here is scope** — see the Status header.

### 4.1 `T1` — Numbers the mill can measure about itself

The signature theme. Every row is a value somebody is currently waiting to be told, and a running
line supplies it by measurement.

| ID | Opportunity | B | Why it is a candidate |
|---|---|---|---|
| `AI-01` | Spread coefficients `C₅` / `C₆` / `k` | `B1` `B2` `B6` | The placeholders `D-43` arrived with. Retires the coefficient half of B4/B5 the only way `[PSG §12.3]` says it can be retired. `G91` records they are lookup tables with no home and an unknown key (`Q93`) |
| `AI-02` | ⭐ Mill spring — roll gap to gauge | `B1` `B2` | `PSG-D12`: *"Roll gap cannot be set without it — gap is not gauge. Gap settings cannot be calculated; first-off setup becomes trial and error."* Every gap-setpoint / measured-gauge pair fits the curve |
| `AI-03` | Strain to temper | `B1` | `A2`, owed since 23 July and **explicitly not supplied** on 2 September. `V16` reports *not evaluated*, so target temper is a mandatory input that nothing consumes |
| `AI-04` | Per-alloy safe reduction limits | `B1` `B3` | Blocker B1, which `[PSG §12.3]` says *"exists somewhere, in your engineers' experience."* `PSG-R02`: limits set from assumption give *"wire breakage, or over-conservative schedules with unnecessary passes"* |
| `AI-05` | Spool outside diameter | `B1` | `A1` / `Q33` — owed since 23 July, asked twice, left blank in the 1 September reply. Directly measurable from footage, gauge, width and traverse on wound spools |
| `AI-06` | Footage to weight, self-calibrating | `B2` `B6` | `[DBD §6.6]` already recommends integrating over `RunReading` rather than using target dimensions, and shows `FR-153`'s ±2 % rule is unreachable from targets — a good coil trips an override. `SpoolCompletionNotification.md` §3.3 already names the loop. Serves `OI-45` / `Q10` / `OI-105` / `OI-56` |
| `AI-07` | Expected yield per route, and per-pass scrap allowance | `B1` | `OI-60` and `OI-61`, both undefined; die-entry crop, edge trim, end crop and weld scrap are all unquantified |
| `AI-08` | Die life and roll grind life | `B1` `B2` | `TotalFeetAllowed` is NULL because `OQ-83` refused to seed an invented limit — correctly. A curve from real grind-to-grind footage plus the excursions preceding each change is measured, not invented, and dissolves `OI-12`, where two MVP-1 screens will show different bands for the same die. Extends to the roll sets `D-42` added, which track **grind life, not footage**, and whose every column is `[PROPOSED]` (`G87` / `Q92`) |
| `AI-09` | Stable line-speed envelope per product | `B1` | `Q66`: ranges *"unknown at this time and will be determined by trial."* `PSG-D14` attributes absolute speed to *"operator judgement"* |
| `AI-10` | Coil-overage economic cut point | `B1` | `G88`: the client describes cutting at a weight and forcing a rejection for the overage, with no reason code, no requirement and no threshold — and an instruction *"do not infer the threshold."* Measure it instead |

### 4.2 `T2` — In-run assistance for the operator

| ID | Opportunity | B | Why it is a candidate |
|---|---|---|---|
| `AI-11` | Gauge and width drift early warning | `B5` | Operators react to a breach; a one-sided CUSUM or EWMA reacts to the trend and warns before scrap exists. Labelled for free by `RollOverride` |
| `AI-12` | Roll-adjust suggestion with a sanity envelope | `B5` | `RollAdjust.md` carries *"Operator discretion — the operator anticipates drift from experience"* as a first-class reason code, and `OI-103` records that **no bound exists on a roll-gap change** — a mistyped gap is written straight to the machine |
| `AI-13` | ⭐ Context-ranked reason codes | `B5` | **Needs no history** — context rules first, learning later. Operators choose from roughly 96 rejection reasons, 15 pause reasons and 72 delay codes on a gloved touch panel, and a miscode corrupts scrap analysis and OEE at source |
| `AI-14` | Time-to-weld and remaining-material forecast | `B5` | Today: fixed alerts at two weight thresholds, plus an operator's eyeball remaining-weight estimate at checkout. A forecast says *when to stage*, not that staging is already late |
| `AI-15` | Wire-break risk | — | `G34`: the client described the whole flow and it has **no persistence target**; `OI-13` is the missing record. Prerequisite before any model |
| `AI-16` | Weld-quality risk and weld-count guard | `B4` | Six captured failure modes, and the contractual cap of `[VS §4.2]` / `G89`. Lets the operator remake a bad weld now rather than have it found in a customer's machine. ⚠ `OI-59` / `Q6`: rows are weld *attempts*, not one per join |
| `AI-17` | Unsupervised anomaly detection | `B1` | The one model needing no labels, so the natural first thing to run on trial data. ⚠ **Scope it to signals that exist** — see the sensor note below |
| `AI-18` | Alert prioritisation and flood suppression | — | `OI-28`: there is no alert table, so *"alerts cannot survive a restart; acknowledgements cannot be audited."* Prerequisite first |
| `AI-19` | Next-spool and next-rod recommendation | `B7` | The spool queue exists so the operator *"knows what material is waiting instead of guessing"*, but the operator still picks the spool **and** the order it is for — *"the system never guesses it."* Ranking by due date and changeover cost is a recommendation, not a guess |

> ⚠ **What the line does not measure, which bounds `AI-17` and much of the predictive-maintenance
> literature.** `[PLC]` carries **no temperature tag, no motor current, torque or load, no vibration,
> and no take-up load cell** (`PLC-Q14`). A component fault bit exists for FM1 only (`PLC-Q02`).
> Edgers and dancers have no observed path on any line (`PLC-Q07`). `LineState`'s vocabulary is
> undocumented — `[PLC §6]` calls it *"the single riskiest ambiguity in the interface."* And
> **every row in the tag map is `[PROPOSED]`; none has been read off a machine** (`PLC-Q02`).
> What does exist: gauge, width, speed, roll gap per stand, die diameter per box, dancer position,
> mode and tension, payoff weight on both positions, footage, and component active / faulted.

### 4.3 `T3` — Quality, traceability and certification

| ID | Opportunity | B | Why it is a candidate |
|---|---|---|---|
| `AI-20` | ⭐ CPK per run and capability trend | — | Not AI — statistics — and listed high for that reason. `FR-190` / `SPC013` is a stated **Must** with no code, no column and no procedure, and the *stable process window* it depends on is defined nowhere. `RunReading` is the right substrate |
| `AI-21` | Scrap and rejection driver attribution | `B3` | Ranks drivers against setpoints, alloy, die age, weld proximity, shift and line — answering *"why is FL2 scrapping this week"*, answered from memory today. Bonus: `G79` records that **all 72 rejection groupings are ours**, invented over a flat 96-row client list; real co-occurrence is the first evidence for or against that taxonomy |
| `AI-22` | ⭐ Free text to structure | `B6` | Free text is everywhere — the SPC trigger description, pause notes, rejection notes (*"the field a later QA reviewer reads first"*), checkout notes, the reason for choosing a non-recommended schedule. And it is the **only** link an SPC checkpoint has to its trigger (`OI-18`), so parsing it **repairs** the die-change-to-deviation causal chain rather than merely reporting on it |
| `AI-23` | Supplier-heat and vendor quality scoring | `B3` `B4` | Genealogy built for certificates also scores vendors. ⚠ `OI-117`: `Rod.SupplierHeat` has no source yet, and the certificate traces through it |
| `AI-24` | Certificate conformance checking | `B4` `B6` | **Needs no history** — deterministic. Does this coil satisfy footage coverage, non-overlap, weld count and the customer's stated limits, *before* it ships |
| `AI-25` | Customer-spec ingestion to machine-readable tolerances | `B4` | `OI-57` names three competing tolerance sources — a published standard, the customer purchase order, and UAL internal — and none is loaded anywhere; `Q22`'s numbers are owed. Extraction turns the thing blocking every SPC limit and every trace band into data |

### 4.4 `T4` — Planning, scheduling and commercial

All of `B7`. Mostly optimisation, therefore mostly available before the lines run.

| ID | Opportunity | Why it is a candidate |
|---|---|---|
| `AI-26` | ⭐⭐ Rod-to-order allocation optimisation — **no history needed.** The constraint set is §3.7's table, and it replaces a live client spreadsheet |
| `AI-27` | Line loading and changeover-minimising sequence — **no history needed.** Grouping by die size and alloy is pure setup-time recovery |
| `AI-28` | Anneal batching and shared furnace capacity — **no history needed.** `OI-64`, already parked as post-go-live; the furnaces are shared with existing production |
| `AI-29` | ⭐ Quote-time manufacturability screening — `[PSG §13]`'s *"feasibility confirmed at quotation rather than discovered at production."* The mechanism exists: `[PSG §6.3]` Step 3A rod adequacy plus `V43`. Its force is proven — `FW-013`'s own published acceptance criterion was **falsified on 3 September** when the client's own `F16` put the required entry diameter past the rod it was to be made from. Catching that at quotation is the commercial case |
| `AI-30` | Yield, cost and margin forecast per order — Phase 12 records cost *after* the fact. Forecasting needs `AI-07`'s measured yield |
| `AI-31` | Completion ETA and throughput forecast — the line board already shows a payoff ETA computed arithmetically. A forecast accounting for welds, die changes and historic pause patterns is a promise date |
| `AI-32` | Delay and OEE-loss attribution — the downtime vocabulary carries a **standard grace time per code** against actual pause and downtime seconds, with the non-productive flag snapshotted per event. Standard versus actual, aimed at the Six Big Losses, and it gives `PP-03`'s ownerless OEE dashboard an analytical core. ⚠ Blocked twice: `OI-101` leaves shift boundaries undefined, and the line-downtime table has **no MVP-1 capture screen**, so it stays empty |

### 4.5 `T5` — Language, knowledge and documents

Tier-B on runtime throughout — see §5.

| ID | Opportunity | Why it is a candidate |
|---|---|---|
| `AI-33` | ⭐ Natural-language query over runs and traceability — highest visible value, lowest process risk, because it only reads data that is already exact. **The wider UAL estate already carries a text-to-SQL framework design**, unreferenced from this repository; Flat Wire would be a consumer of it, not a new platform. ⭐ **This item now has a designed screen** — `ASK`, at [`AskFlatWire.md`](../10-requirements/screens/AskFlatWire.md), specified 4 Sep 2026 on client request. **Its status here does not change:** the screen is `PROPOSED`, with no story, phase or owner, and designing it committed nothing |
| `AI-34` | Shift-summary narrative and handover brief — the shift's story in a paragraph rather than twelve tiles. Depends on `OI-101` and `OI-102`, which leaves the report's format and recipients unspecified |
| `AI-35` | Engineering-knowledge assistant — aimed at `[PSG §1.2]`: *"the reasoning behind a given schedule lives in the engineer's head rather than in a record."* ⚠ Extra conflict: retrieval over `95-archive/` would cite non-citable material. That is a governance question, not a technical one |
| `AI-36` | Process-letter drafting and consistency checking — a live client thread, not a hypothetical, with `OI-27`, `OI-143`, `OI-64` and `G86` all still owed. Checking a letter against the pass schedule it describes is a consistency problem |
| `AI-37` | Engineering-document digitisation — **needs no plant data.** The evidence is this repository's own inbox: the twenty formulas of `D-43` arrived as **PNG images** inside a Word document with a symbol legend and no selectable text, and six readings still cannot be settled (`Q93`) — one of which decides whether the nominal product is makeable |
| `AI-38` | Operator in-context help and training — fourteen screens, gloved hands, and a process nobody has run before |

### 4.6 `T6` — Vision and sensing

New hardware, so not a software decision — but one item fills a hole nothing else can.

| ID | Opportunity | Why it is a candidate |
|---|---|---|
| `AI-39` | Surface, edge and oxidation inspection — automates two purely human calls: the pre-unbanding visual gate, which is a hard block with no bypass, and *"edge defect → judged against the edge-type spec, scrap or rework"* at coil completion |
| `AI-40` | ⭐⭐ **Vision-based gauge and width on FL2** — the one place vision fills a *structural* blind spot rather than replacing a human. FL2 standalone has **no live gauge or width measurement at all**: it broadcasts `null`, and its trace is the historical profile from the FL1 pass that made the spool (`FR-120`, `[PLC §5.2.2]`). Yet FL2 is the pass that sets **final** dimensions, on the tightest tolerance |
| `AI-41` | Coil and spool wind-quality inspection — oscillation width, telescoping and traverse faults on a coreless coil: the defect mode a customer sees first, and one no tag reports |
| `AI-42` | Rod-tag character recognition — the rod alpha is *scanned **or keyed***, and a keyed alpha at the head of the genealogy chain is the most expensive typo in the system |

### 4.7 `T7` — Twin and search

All of `B8`, except `AI-45`.

| ID | Opportunity | Why it is a candidate |
|---|---|---|
| `AI-43` | Calibrate the simulator against the real line — §3.8. Precondition for `AI-44` |
| `AI-44` | Predictive quality before committing material — `[PSG §13]`. Honest caveat at `[SIM §5.6]` |
| `AI-45` | Schedule search against an objective — `[PSG §13]`'s *automatic optimisation*. **Needs no history**; it searches the physics engine's own feasible space. ⚠ But `PSG-Q15`'s objective ladder is a recommended default the client has not confirmed, and an optimiser is only as good as the objective it is given |

### 4.8 `T8` — Named, and explicitly not recommended

Refusing these deliberately is a stronger answer than ignoring them.

| ID | Not recommended | Why |
|---|---|---|
| `AI-46` | Closed-loop AI setpoint control, or reinforcement learning on the line | `[VS §8]` forbids any software stop command; the application is a **gatekeeper** that reads line state; and automatic gauge control already closes the fast loop in the PLC, which is where it belongs |
| `AI-47` | Auto-applied pass schedules | A closed decision — `D-09` and `[VS §8]`: *"Generate from Specs produces a Draft for human approval."* `VO-1` requires every foot to be made under a configuration a human explicitly acknowledged |
| `AI-48` | AI-authored certificates or dispositions of record | Certificates are contractual and a disposition is an accountable human decision. **AI may check and draft; it may not sign** |

---

## 5. What blocks the rest, stated plainly

Grouped by what it would take to clear each one.

### 5.1 Blockers that are a decision

| Blocker | Register |
|---|---|
| ⭐ **Telemetry retention and rollup are undefined**, and `[ARC §13.2]` wants them set before Phase 3. `RunReading` is footage-gated — one point per 4 ft for finished product, 20 ft for intermediate (`FR-018`, `NFR003` / `NFR004`) — and reconfigurable without a code change. **Ageing it out or rolling it up on storage grounds discards the only training set the first months of operation will ever produce.** And this is not a new question: it is `PSG-Q24` restated, whose own justification reads *"Determines whether to build the data capture path now, even if refinement comes later"* — **and `PSG-Q24` is open** | `OI-17` · `G3` · `G9` · `PSG-Q24` |
| **Shift boundaries are undefined** — no start and end times, no names, no weekend or holiday pattern, no run-crossing attribution. Blocks every shift-level aggregate | `OI-101` |
| **The optimisation objective is unconfirmed** — the feasibility-first ladder is a recommended default | `PSG-Q15` |
| **Nothing writes the pass-schedule tables in production** — the very tables a schedule-learning model would learn from have no production writer | `OI-110` |

### 5.2 Blockers that are a small build

| Blocker | Register |
|---|---|
| **Nothing is labellable yet.** Published tolerance bands per alloy and temper are undefined and the alloy tolerance columns are seeded NULL, so there is no in-spec truth to train against. ⛔ Worse: `SpcMeasurement.InSpec` is a persisted computed column that **stores the wrong answer for an asymmetric tolerance** — a label defect, not a modelling one | `Q22` · `OI-57` · `G51` |
| **The causal chain breaks at its most useful joint** — an SPC checkpoint links to its triggering die change or roll override only through free text | `OI-18` |
| **Outcome sources with no table** — wire break, scrap box, the alert lifecycle, rework, SPC-HOLD as distinct from a rejection hold, supervisor approval evidence, and payoff weight and component current value, which are live-only with no persistence target | `OI-13` · `OI-15` · `OI-28` · `OI-22` · `OI-23` · `G24` |
| **Footage is `decimal` on the trace and integer on every event table**, so aligning a die change or weld marker to the trace loses sub-foot precision | `[DBD §6.9]` |
| **Denormalised die footage** — the per-die grinding counter is deliberately not reconciled against the sum of its history rows, and there is no trigger, so the two can drift | `[DBD §6.5]` |

### 5.3 Blockers that are physics, time or hardware

- **No history.** Three new lines, new PLC hardware, zero domain rows at go-live.
- **Pre-production telemetry is synthetic** (`G39`, `[SIM §5.6]`).
- **The empirical constants are still placeholders**, so `AI-01` needs `[PSG §12.5]`'s prerequisite
  `P5` before it has anything to fit; `G90` bounds where the correlation is even valid.
- **No temper relation exists at all** (`A2`).
- **Sensors that do not exist** — see the note under §4.2.

### 5.4 Constraints on how anything may be built

| Constraint | Why it bites |
|---|---|
| **The shared databases are frozen.** `D-32`: the existing schema is read and written as it stands and never altered. **No AI feature may add a column, table or status value to them** | `D-32` |
| **A new runtime needs an *already in UAL production* defence.** `D-09` and `[ARC §14.2]` reject new frameworks; the one recorded exception, `D-33`'s WinForms simulator console, is defended on exactly that ground — the platform is not new to UAL and *"there is no ramp-up to fund."* No inference runtime has an analogous defence today. The rule bites hard in practice: a health check was hand-written rather than take a package dependency, and even a serialisation library is flagged *measure-first* (`G10`) | `D-09` · `[ARC §14.2]` |
| ⚠ **Egress is an open question, not an assumption.** Deployment is wholly on-premises. `[SEC]` addresses third-party services, external endpoints and outbound traffic **nowhere at all**, and the operational-technology context implies a segmented network. **Every language and vision item in `T5` and `T6` must carry this as unanswered** — it is not a detail to settle later, it decides whether those items exist | `[SEC]` · `[DEP §2]` |

---

## 6. Instrument now, model later

The actionable section, and worth acting on even if no AI is ever built. Each item costs a decision
or a column, and each is expensive to add retrospectively.

| # | Do this | Because |
|---|---|---|
| 1 | ⭐ **Answer `PSG-Q24` and `OI-17` together, and make any rollup additive** — keep raw readings alongside any aggregate | It is the same question asked twice, it is already open, it costs a decision rather than hours, and an additive rollup keeps the decision reversible |
| 2 | **Land the tolerance bands and fix the asymmetric-tolerance defect** | `Q22` / `OI-57` / `G51`. Without them nothing is labellable, and the wrong label is worse than none |
| 3 | **Add the link `OI-18` wants** — a checkpoint's triggering die change or roll override | One reference, and a whole family of cause-and-effect questions becomes answerable by query |
| 4 | **Give the coefficients a home**, with what they are keyed by, when they were calibrated and from how many samples | `G91`, and the vehicle for `B6`. A stale coefficient becomes visible instead of silent |
| 5 | **Record *predicted* width alongside measured** | `B2` needs a residual; recording it costs one column and avoids back-computing it forever |
| 6 | **Reconcile the footage types before the event tables fill** | Sub-foot marker alignment cannot be recovered later |
| 7 | **Persist what is live-only** — payoff weight, component current value — and the supervisor approval evidence `G24` discards | Live-only data is data that never existed |
| 8 | **Capture the wire-break record** | `OI-13`. It is the label for `AI-15`, and breaks are exactly the events nobody can afford to wait to accumulate |
| 9 | **Plan the trial for coverage** | §3.1. It happens once |
| 10 | ⚠ **Protect `CoilOutput.PassScheduleSnapshot`** | It is already designed and already permanent — and it is the feature vector. It must not be optimised away as redundant |

---

## 7. Whose day changes

The client's question was how AI helps people in their daily work. Each row names a decision a
person makes today, unaided.

| Role | What they judge today | Items |
|---|---|---|
| **Operator** | Which pass schedule, when no-match has no defined path (`OI-46`) · a new roll gap, with no bound on the change (`OI-103`) · the suspect footage range after a die failure, from recall · a reason from ~96 rejection codes · when to take a spot check · whether the order is complete, with no defined acceptable overrun (`Q50`) · which of three weights is right (`OI-105`) · a staging location, with no list to choose from (`OI-106`) | `AI-11` `AI-12` `AI-13` `AI-14` `AI-17` `AI-19` `AI-38` `AI-42` |
| **Supervisor / Foreman** | Disposition of partial-run material · override authorisation · what actually happened this shift | `AI-18` `AI-21` `AI-32` `AI-34` |
| **Operations Manager** | Which schedule to author, from experience and precedent · whether a recurring rejection implicates a schedule | `AI-29` `AI-35` `AI-44` `AI-45` |
| **Engineering / Maintenance** | When a die or roll is due · what the coefficients should be · what the machine's spring curve is · what speed is safe | `AI-01` `AI-02` `AI-04` `AI-08` `AI-09` `AI-43` |
| **QA** | Root cause of scrap · whether a coil meets a customer's spec · what to hold | `AI-20` `AI-22` `AI-24` `AI-25` |
| **Planning** | Which rod to which order · which line · which spool next | `AI-26` `AI-27` `AI-28` `AI-31` |
| **Commercial / Purchasing** | Whether a quoted product is makeable · which vendor's heats behave | `AI-23` `AI-29` `AI-30` `B4` |

---

## 8. What this document deliberately does not do

| Not done | Why |
|---|---|
| **Mints no register identifier** | `STATUS.md` derives from the registers. A new open `G##` would appear on the board as work-stopping while blocking nothing. `B#` and `AI-##` are document-local, as `[VS §14]`'s `PP-##` are |
| **Costs and schedules nothing** | `[CE §3e]` owns the effort figures and many documents cite them. Nothing here is a story, a phase or an hour |
| **States no object count** | `[DBD §6.2]` is the only site that may. Counts here are citations or absent |
| **Adds nothing to the backlog** | MVP-1 and MVP-2 are closed sets owned by their own tracks |
| **Restates nothing from `[PSG §13]` or `PassScheduleManagement.md` §9** | Those items are asserted there. §3.2 and §3.8 are *readings* of them and say so |

---

## Related Documents

| Document | Why |
|---|---|
| [PassScheduleGenerationSpec.md](../10-requirements/screens/PassScheduleGenerationSpec.md) `[PSG]` | **The prior art.** §13 is the existing AI roadmap; §12.3 sorts the blockers; §12.5 owns the trial-instrumentation prerequisite this document's `B1` acts on |
| [PassScheduleManagement.md](../10-requirements/screens/PassScheduleManagement.md) | §9's *data-driven refinement*, and the open quality-feedback-loop question |
| [VisionAndScope.md](VisionAndScope.md) `[VS]` | §8's non-goals, which bound `B5` and `T8`; §4.2's contractual weld count, which `B4` builds on; the *Future enhancements* list this document now carries |
| [DatabaseDesign.md](../30-database/DatabaseDesign.md) `[DBD]` | §6.4's two footage systems, §6.5's table purposes, §6.6's weight derivation, §6.9's open items |
| [PLCTagSpecification.md](../20-architecture/PLCTagSpecification.md) `[PLC]` | What the line measures, and — more importantly for §4.2 — what it does not |
| [MachineSimulator.md](../20-architecture/MachineSimulator.md) `[SIM]` | §5.6's assumption table, which is `G39`'s only instrument and `B8`'s starting point |
| [Gaps.md](../90-registers/Gaps.md) · [Questions.md](../90-registers/Questions.md) · [MasterSpecification.md](../10-requirements/MasterSpecification.md) §10–§11 | Every `G##`, `Q##`, `D-##` and `OI-##` cited above |
| [DevelopmentEffortModel.md](../60-delivery/DevelopmentEffortModel.md) `[DE]` | §1's distinction — the AI that builds this system, which is not the AI in this document |
