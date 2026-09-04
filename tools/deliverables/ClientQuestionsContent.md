# Flat Wire Mill — Client Questions Workbook Content

**Project:** Flat Wire Mill Implementation
**Last Updated:** September 3, 2026 — **`Q93` authored** — the six unreadable points in Tim O'Brien's pass-calculator formula document (`D-43`), of which items 3 and 4 are asked now and the rest wait for the calculator itself. *(previously August 25, 2026 — **ten missing entries authored** — `Q48`–`Q55`, `Q59`, `Q87`; without them the client questions workbook could not be rebuilt *(previously August 20, 2026 — client-facing prose added for **`Q37`–`Q47`**: the four shared-record sign-off values from the check-in write-back, and the seven questions from the 20 Aug client call on the spool carrier, the multi-order spool and FL2 pre-check-in. Workbook regenerated to **47 open questions**, leakage scan clean. *(previously August 18, 2026 — `Q68` amended — the status moves to the flat wire module’s own rod record, and the client is asked which reports filter on the coil status field *(previously August 12, 2026)*)*)*)*
**Document Type:** Source content for a generated client deliverable — not a specification
**Status:** Active

---

## What this file is

**The client-facing prose for the questions workbook, and the only place it is authored.** The workbook
`../../deliverables/FlatWire_ClientQuestions.xlsx` is generated from this file plus the two registers by
`./build_questions_xlsx.py`. **Edit this file and re-run the generator; never edit the
`.xlsx`.**

**Division of labour with the registers.** Structural fields — question number, priority, scope, owner, decided
date — are read from `../../90-registers/Questions.md` and `../../90-registers/Decisions.md` at build time
and are **not** restated here. What is authored here is the part that does not exist anywhere else: the
plain-language rewrite and the consolidated recommendation.

**Why the rewrite exists.** The registers are written for the build team. Their bodies carry table and column
names, constraint names, endpoint names, requirement identifiers, gap identifiers and cross-file links, none of
which mean anything to the client and none of which may appear in a client deliverable. The client-facing text
cannot be produced by filtering those out — a sentence about a column rename has to be **rewritten** as a sentence
about a business rule.

**Rules the generator enforces mechanically, so they cannot be broken by accident:**

| Rule | Enforcement |
|---|---|
| Every question in a register has an entry here, and vice versa | Build fails, naming the question |
| `Register title:` still matches the register | Build fails — catches a renumbering silently moving prose onto the wrong question |
| No file names, paths, requirement/gap/test identifiers, table or column names, endpoints or code spans reach the workbook | Every cell of the built workbook is scanned; build fails on a match |
| **No machine tag paths reach the workbook** | Scanned for the line-prefixed tag shape. The tag surface has exactly one client-facing home and this workbook is not it — see the anti-drift rule in `CLAUDE.md`. Naming conventions and controller station names are described in words instead |

**`Recommended answer:` is one consolidated position.** Each register question carries its own `Recommendation:`.
That text is the input to the field here, not the output: where the register's recommendation holds it carries
through with tightened wording, and where it needed qualifying the qualified position is the one stated. The client
sees one answer to confirm or correct, not two vendor opinions. **A recommendation carries no client authority** —
confirming one is what closes the question.

**Field vocabulary.** `Register title` · `Area` · `Needs input from` · `What we need` · `Answer together with` ·
`Question` · `Background` · `Already agreed` · `Options` · `Recommended answer` · `Why` · `Impact if unanswered`
for open questions; `Register title` · `Area` · `Question` · `Background` · `Decision as recorded` · `Still open` ·
`Our recommendation` for decisions. `Answer together with`, `Already agreed`, `Options` and `Still open` are
optional; everything else is required.

---

# Part 1 — Open Questions

---

## Q1

**Register title:** Roll gap validation before run start
**Area:** Run start and machine setup
**Needs input from:** Tim O., Engineering
**What we need:** Decision

**Question:** Before a run starts, how do we confirm the roll gaps are actually set to what the pass schedule says? Does the operator measure each gap and enter the readings, does the machine report its own achieved gap position back to us, or does the system simply push the settings and start the run with no check? And if a gap is found out of tolerance, is a supervisor override enough to proceed, or must it be a hard stop?
**Background:** The pass schedule specifies a roll gap for every active component. When the operator acknowledges the schedule at check-in, those values are sent to the machine. Nothing currently reads back what the machine actually did with them, so a mis-sent value and a correct one look identical to the system, and the first evidence of a problem is out-of-spec wire. Whether a readback is even available differs by component, which is why this needs an engineering answer rather than a design decision.
**Options:** (1) The operator physically measures each active roll gap and enters the readings; the system compares them against the pass schedule. (2) The machine reports its achieved gap position and the system compares that against the setting; the run cannot start until every active component reports within tolerance. (3) The operator acknowledges the schedule, settings are sent, and the run starts with no readback at all — the current implied design, which we rate high risk.
**Recommended answer:** Option 2 — machine readback compared against the pass schedule setting — for every component where a readback exists, falling back to option 1 (operator measurement) on components where it does not. Please tell us which components can report their gap position. Option 3 should not ship. Treat an out-of-tolerance gap as a **supervisor-overridable block, not a hard stop**.
**Why:** A run that starts with no readback cannot tell a mis-sent setting from a correct one, and the cost of finding out is scrap. A hard stop with no override is the opposite failure: it strands the line every time the tolerance value itself turns out to be wrong.
**Impact if unanswered:** The run-start gate cannot be built, and the check-in sequence has an unspecified step in the middle of it.

---

## Q2

**Register title:** FL3 scheduling representation
**Area:** Planning and scheduling
**Needs input from:** Tim O., Stephen
**What we need:** Decision
**Question:** FL3 is the hybrid mode in which FL1 feeds FL2 continuously. In the scheduling system, is an FL3 job a single machine booking, or two simultaneous bookings — one on FL1 and one on FL2?
**Background:** FL1, FL2 and FL3 are already agreed to be three separate machines for scheduling purposes, and it is already agreed that FL3 cannot run when either FL1 or FL2 has work booked. What is not settled is the shape of the booking record itself, which determines how capacity views report and how a scheduler sees the two lines being consumed.
**Already agreed:** FL3 cannot run if there are scheduled orders on FL1 or FL2, and the three lines are tracked as separate machines in scheduling.
**Recommended answer:** A single FL3 booking that reserves FL1 and FL2 capacity as a side effect, rather than two bookings the scheduler has to keep in step. Runs report against the FL3 booking; capacity views subtract from both lines.
**Why:** The operational rule is already fixed, so only the representation is open — and one booking with a two-line reservation cannot drift out of sync the way two linked bookings can.
**Impact if unanswered:** Capacity reporting for the hybrid route is undefined, and schedulers have no agreed way to book it.

---

## Q3

**Register title:** Traveler screen fields per station
**Area:** Shopfloor screens
**Needs input from:** Tim O.
**What we need:** Confirmation of our reading
**Question:** The traveler screens need a confirmed field list for each station on FL1, FL2 and FL3. Who owns defining that list, and by when?
**Background:** The generic groupings — incoming bundle information, run detail, output — are agreed in principle, but the actual field list per station has never been written down. Every field we would propose is already visible on the operator screens you have reviewed, so this is a question of ownership and sign-off rather than of content.
**Recommended answer:** We publish the field list taken from the approved screen designs and send it to you to mark up, rather than waiting for it to be authored from scratch. Target the mark-up before the check-in build begins.
**Why:** The blocker here is ownership, not content — every field is already on a screen you have approved, so a redline is a short exercise and a blank-page authoring task is not.
**Impact if unanswered:** The traveler build has no agreed field list, and the digital traveler is a committed deliverable.

---

## Q4

**Register title:** Coreless coil skid labeling rules
**Area:** Output and packaging
**Needs input from:** Tim O., Shannon R.
**What we need:** Confirmation of our reading
**Question:** Final output is two coreless oscillated coils per skid. Do skid labelling, alpha assignment and packaging records follow United Aluminum's existing coil packaging rules unchanged, or does flat wire need its own variations? And which existing convention is the one being inherited?
**Background:** The two-coils-per-skid rule was given to us as inherited from existing practice, but the artifacts asserting that never named a specific, definable convention to inherit from. The output geometry and the handling are the same as existing coil packaging, so we expect the rules to carry over unchanged.
**Impact if unanswered:** Label layout and packaging records cannot be finalised, and coil and skid labels are printed output.

---

## Q5

**Register title:** Traceability granularity for certs
**Area:** Certification and traceability
**Needs input from:** Tim O., Mick
**What we need:** Decision
**Question:** What is the minimum traceability unit welding wire customers require — coil, lot or heat? Does that granularity have to be printed on the Certificate of Conformance, or is a lot reference enough?
**Background:** We already record which source rods produced which footage of output, so a coil-level certificate can resolve down to lot or heat when asked. What we need to know is what has to be **printed**.
**Recommended answer:** Build coil-level traceability with full rod genealogy behind it, print the lot reference, and hold the heat detail queryable. Please confirm only whether heat must be printed.
**Why:** The genealogy we already capture satisfies the strictest plausible answer without waiting for it, so the only real decision is what appears on the printed certificate.
**Impact if unanswered:** Certificate layout cannot be finalised. The underlying data model is unaffected either way.

---

## Q6

**Register title:** Weld attribution on output footage
**Area:** Certification and traceability
**Needs input from:** Tim O.
**What we need:** Decision
**Question:** When a weld joins two source rods into one continuous run, how is the output footage attributed between them for certification and yield — split at the weld point, or all attributed to whichever rod contributed most?
**Background:** The weld already records the footage position at which it was made, so a footage-based split needs no extra capture. Attributing the whole coil to the larger contributor would make a certificate assert that material came from a rod it did not come from.
**Recommended answer:** Footage-based split at the weld point, not dominant-rod attribution.
**Why:** It is the natural reading of data we already hold, it costs nothing extra at capture, and the alternative puts an untrue statement on a certificate.
**Impact if unanswered:** Certificate and yield attribution for welded runs is undefined — and welded runs are the normal case on continuous feed.

---

## Q7

**Register title:** Max weld joints per finished coil
**Area:** Certification and traceability
**Needs input from:** Tim O., Sales
**What we need:** Values or data
**Question:** Is there a customer-specified limit on how many weld joints a single coreless oscillated coil may contain?
**Background:** Too many joints can jam the customer's welding equipment. If a limit exists it has to be a validation at coil completion, and validations of that kind are cheap to add now and expensive to retrofit once certificates are being issued.
**Recommended answer:** Build the validation now with a per-order configurable limit that defaults to unlimited, so it sits inert until Sales supplies a value per customer. A superseded weld attempt should not count toward the limit — see the related question on rework welds.
**Why:** It costs little to add at completion and a great deal to add after certificates are issuing, and a null default means no behaviour changes until you give us a number.
**Impact if unanswered:** No functional block, provided the validation is built now. If it is not, adding it later touches the certificate path.

---

## Q8

**Register title:** C of C frequency — per coil/order/heat
**Area:** Certification and traceability
**Needs input from:** Tim O., Mick
**What we need:** Decision
**Question:** Are Certificates of Conformance issued per coil, per order or per heat for flat wire? Is that consistent across all flat wire customers, or customer-specific?
**Background:** Finished coils are roughly 900 lb, so a 44,000 lb order is around fifty coils. Per-coil certification on that order means fifty certificates.
**Recommended answer:** Issue per order with per-coil detail attached, rather than separate certificates, and allow a customer-specific override. Please confirm whether any welding wire customer contractually requires per-coil.
**Why:** It matches how the coil business already issues certificates, and it avoids fifty certificates on a single order while still carrying the per-coil detail.
**Impact if unanswered:** Certificate issuing cannot be built.

---

## Q9

**Register title:** Twist and torsion tolerance for welding wire
**Area:** Quality and tolerances
**Needs input from:** Tim O., Technical
**What we need:** Decision
**Question:** Is there a maximum allowable twist per foot for flat wire, particularly for welding wire that has to feed through automated welding equipment?
**Background:** Excess twist jams wire at the customer and is a common first-shipment field failure. Camber has already been settled as an optional measurement active only when the order specifies a limit; twist is the same shape of characteristic.
**Recommended answer:** Treat it exactly as camber is already treated — an optional quality checkpoint field, active only when the order specifies a limit. Please supply the limit only for the customers who require it.
**Why:** It reuses a pattern already agreed for a customer-conditional dimensional characteristic, needs no new mechanism, and does not make every order measure something only some orders care about.
**Impact if unanswered:** Welding wire orders cannot enforce a twist limit; no impact on orders that do not specify one.

---

## Q10

**Register title:** Footage-to-weight conversion factor
**Area:** Weights and measurement
**Needs input from:** Tim O., Bob S.
**What we need:** Decision
**Question:** How is footage converted to weight per alloy and cross-section? We believe it is the standard calculation — density times cross-sectional area times length. What we specifically need decided is the **dimensional basis**: nominal or measured gauge and width, and whether the rounded edge is corrected for.
**Background:** Output weight is derived from length rather than weighed, so this factor sits behind spool completion, the printed coil label and the pass schedule calculations. The formula itself is not really in doubt; the basis it is applied to is, and a nominal-versus-measured difference is large enough to matter on a label.
**Why:** Two independently confirmed factors will disagree in the third decimal and nobody will know which is authoritative. The same number is also being requested for the pass schedule calculations and must not resolve to a second value.
**Impact if unanswered:** Every derived weight in the system — spool completion, coil label, planning — rests on an unconfirmed basis. This is one of the most widely depended-on numbers in the build.

---

## Q11

**Register title:** Yield loss factor for planning rod input
**Area:** Costing and yield
**Needs input from:** Tim O., Margo
**What we need:** Values or data
**Question:** Is there a per-pass scrap allowance — die entry crop, edge trim, end crop, weld scrap — that planning must apply when sizing rod input for an order?
**Background:** If this is not built in, planners will systematically under-order rod and the shortage will be discovered at the machine.
**Recommended answer:** Hold a per-pass scrap allowance as configuration, with die entry crop, edge trim, end crop and weld scrap as **separate line items** so each can be tuned independently. Seed them provisionally and refine from trial data. The figures must agree with the metallic yield answer.
**Why:** Rolling them into one factor makes the number impossible to improve later, because nobody can tell which component was wrong.
**Impact if unanswered:** Planning under-orders rod and the shortage surfaces at the machine.

---

## Q12

**Register title:** Partial-rod re-check-in and traceability carry-forward
**Area:** Rod checkout and partial material
**Needs input from:** Tim O., Scott, Bob S., Shannon R.
**What we need:** Confirmation of our reading
**Question:** When a rod is removed part-used and later brought back, how does its history carry forward? And is a scale going to be available at the payoff to weigh the returning rod?
**Background:** Partial decisions were given in May 2026 and the carry-forward design has since been built to them. The remaining uncertainty is the scale. Our design works from an estimated remaining weight; a scale would improve the estimate's accuracy rather than change the design.
**Already agreed:** Any material left in the mill when the rod is removed is scrapped. A single rod can legitimately produce partial spool identifiers across several separate runs, and that capability is needed. The remaining rod going back to the warehouse may need weighing to validate remaining weight — Scott, Bob and Shannon were asked to weigh in on whether a small scale at the payoff should be available.
**Recommended answer:** Confirm the carry-forward design as built: the rod keeps a persistent record carrying footage run to date and an estimated remaining weight, and each partial spool records the rod it came from. Treat the payoff scale as a separate question — the same scale question arises at the take-up — and do not hold the build for it.
**Why:** The design already works from an estimate, so the scale answer changes accuracy rather than structure. Holding the build for it delays working functionality for an improvement.
**Impact if unanswered:** The carry-forward design remains unconfirmed while it is being built against. The scale answer separately affects how accurate returned-rod weights are.

---

## Q13

**Register title:** PLC tag behaviour on rod checkout
**Area:** Rod checkout and partial material
**Needs input from:** Tim O., Engineering
**What we need:** Confirmation of our reading
**Question:** When a rod is checked out mid-run, what should happen to the machine settings the system had sent? We have proposed a behaviour and need engineering to confirm it.
**Background:** The concern is losing footage or interrupting the machine's control logic while material is still moving. Our proposal avoids both by never commanding the machine and only clearing settings once the line is confirmed stopped. Whether "stopped" is reliably readable depends on the line-state signal, which is the subject of a separate question.
**Already agreed:** Nothing yet — the behaviour below is our proposal awaiting engineering confirmation.
**Options:** As proposed: the application never sends a stop command — the operator always controls the machine physically; settings are cleared only when the line is confirmed stopped; and the system checks the line is stopped before allowing checkout to proceed. On screen: if the line is still running when the operator presses Check Out Rod, checkout is blocked with the message "Line is still running. Stop the line before checking out the rod." If the line is confirmed stopped, the checkout dialog opens, the footage reading is taken and locked at that moment, and settings are cleared only after the operator confirms.
**Recommended answer:** Adopt the proposed behaviour as written. We are asking engineering to confirm the line-state signal we read to decide "stopped", not to redesign the flow.
**Why:** It is the only design that cannot drop footage or interrupt control logic mid-motion, because the operator stops the line physically and the system only ever follows.
**Impact if unanswered:** Mid-run rod checkout cannot be built, and it is a routine operational event.

---

## Q14

**Register title:** Pass schedule selection mechanism at check-in
**Area:** Pass schedule at check-in
**Needs input from:** Tim O.
**What we need:** Decision
**Question:** What happens at check-in when no pass schedule matches the order? Must check-in be blocked and Operations alerted so a schedule can be created, or may the operator proceed by manually picking a schedule that does not match?
**Background:** The selection mechanism itself is settled and visible on the screens you have reviewed: the system looks up a schedule by alloy, rod diameter, target gauge and width, and route mode, and presents the best match for the operator to confirm before check-in can begin. A change control offers alternatives, and picking a non-recommended schedule is flagged for Operations review. What the screens do not show is the case where the lookup returns nothing at all.
**Already agreed:** The selection mechanism — attribute-based lookup, system recommendation, explicit operator confirmation before check-in is enabled, alternatives available with non-recommended choices flagged for Operations review.
**Recommended answer:** Block the check-in and alert Operations, showing which attributes failed to match so the missing schedule can be authored without a phone call. The operator must not be able to proceed by hand-picking a schedule that does not match the order.
**Why:** Hand-picking a non-matching schedule is precisely the path that produces scrap under a configuration that looks plausible on screen — and making the match explicit is the whole purpose of the confirmation step.
**Impact if unanswered:** The check-in gate logic cannot be built, and this is the first thing that happens on every run.

---

## Q15

**Register title:** FL3 hybrid pass schedule — one or two schedules?
**Area:** Pass schedule at check-in
**Needs input from:** Tim O.
**What we need:** Decision
**Question:** When a spool produced on a hybrid FL3 run later arrives at FL2 for check-in, how does the system verify it was produced under the correct hybrid configuration? Is there a guard stopping the operator applying a standalone FL2 schedule to material originally run as hybrid?
**Background:** The data model question — one unified hybrid schedule or two coordinated ones — is effectively resolved toward a single record covering both mills, and the FL3 check-in screen reflects that with a hybrid route tag in the lookup. The FL2 spool check-in screen, however, only shows standalone FL2 schedules, so nothing currently prevents hybrid-origin material being re-passed under a configuration that never applied to it.
**Already agreed:** A single unified pass schedule record covers the FL1 and FL2 components of a hybrid run, with hybrid route as a lookup attribute.
**Recommended answer:** Record the originating route mode on the spool and have FL2 check-in refuse a standalone FL2 schedule for a hybrid-origin spool unless a supervisor overrides with a reason — the same override pattern used for the other supervisor-gated deviations.
**Why:** The spool already carries the run that produced it, so this is a lookup rather than new data to capture. Without it, hybrid material can be re-passed under a configuration that never applied to it.
**Impact if unanswered:** FL2 check-in development cannot begin.

---

## Q16

**Register title:** Pass schedule validation during planning/scheduling
**Area:** Planning and scheduling
**Needs input from:** Tim O., Stephen
**What we need:** Decision
**Question:** Should planning or scheduling warn when a job is booked on a flattening line but no pass schedule exists for that product's alloy, gauge, width and edge type?
**Background:** Without a check at scheduling time, operators arrive at the machine ready to run and find no schedule available, and the line waits while Operations authors one. The hard gate at check-in is being handled separately.
**Recommended answer:** Warn at scheduling time, do not block. A scheduler should be able to book work before Operations has authored the schedule, but not unknowingly. Check-in provides the hard gate at the point it matters.
**Why:** Warning at scheduling plus blocking at check-in covers the failure without making planning depend on pass schedule authoring being finished first.
**Impact if unanswered:** Lines will occasionally sit waiting for a schedule that could have been flagged days earlier.

---

## Q17

**Register title:** Spool status state machine — all valid transitions
**Area:** Spool lifecycle
**Needs input from:** Tim O.
**What we need:** Decision
**Question:** What is the full list of spool statuses the system stores, and which transitions between them are valid? Separately: a spool on quality hold is currently neither ready nor checked in, so it does not appear on the FL2 queue at all — where should it show?
**Background:** What the FL2 operator sees was settled on 2 August 2026, but that decision fixed the operator's view rather than what the system records, and two vocabularies for the stored status are still unreconciled. Without a defined set of valid transitions the system cannot prevent invalid progressions — a spool planned for two orders at once, or a completed spool re-opened for check-in.
**Already agreed:** FL2 shows two statuses and runs one spool at a time. Because FL2 has no space to stage material, a spool is either waiting for the line or on it — the operator-visible vocabulary is "Ready for FL2" and "Checked in", with no staging status and no "at the payoff" status. Check-in is exclusive: while any spool is checked in, no spool offers a check-in action, and the action returns only on checkout. From May 2026: spools carry unique identifiers similar to furnace plates, identifiers are loaded onto a spool number at the start of the FL1 job with the operator entering the spool number used, and the spool is then tracked physically and in the system through the furnace and cooling until the FL2 operator selects it by spool number.
**Recommended answer:** Make the stored vocabulary the existing coil status set already in use across the plant, and treat the two-status FL2 view as a filtered presentation of it rather than a second vocabulary. Add a third **view** state, Held, for the quality-held spool — visible on the queue with no check-in action — so it stops being invisible.
**Why:** Reusing the existing status set closes the two-vocabulary problem without inventing a third list. A quality-held spool that appears nowhere is a spool nobody chases.
**Impact if unanswered:** The system cannot enforce valid status progressions, and quality-held spools are invisible to the FL2 operator.

---

## Q18

**Register title:** Target spool weight source for the completion alert + over-target behavior
**Area:** Spool lifecycle
**Needs input from:** Tim O., Operations
**What we need:** Decision
**Question:** Two parts. Which order field carries the customer's minimum and maximum weight? And if the operator does not acknowledge the completion notification and weight keeps climbing past target, should the notification escalate to a distinct over-target state, or keep showing "target reached" with a percentage above 100?
**Background:** The basis was settled on 30 July 2026 — completion is graded against the customer's weight range — but the field that carries that range has not been named, and there are two candidate sources for a target: the order's maximum spool weight, and the take-up equipment capacity. Note the customer maximum can sit well below the finished-coil take-up capacity, in which case the customer value governs rather than the equipment cap.
**Already agreed:** The basis is the customer weight range, not a fixed default: the customer specifies a minimum and maximum — for example 900 lb maximum and 800 lb minimum — and completion is graded against that range by weight, not by footage and not against an assumed default. Spools are sized at roughly 1,800 lb so two finished coils can be cut from one spool at FL2.
**Recommended answer:** Carry the customer minimum and maximum on the **order**, reusing the existing maximum spool weight field for the maximum and adding a matching minimum, rather than introducing a new target record. On the second part, escalate to a distinct over-target state.
**Why:** The short-close rule already grades against the same range, so one source serves both. A percentage climbing past 100 with no change of state gives the operator nothing new to react to at exactly the moment the equipment limit is being approached.
**Impact if unanswered:** The completion alert has no confirmed target to compare against, and the over-target behaviour is unspecified.

---

## Q19

**Register title:** Does the spool completion alert ladder apply to finished coils at TKUP-2 (FL2/FL3)?
**Area:** Spool lifecycle
**Needs input from:** Tim O.
**What we need:** Confirmation of our reading
**Question:** The 75 / 90 / 100 per cent approaching-target notification was specified for spool creation at FL1. FL2 and FL3 wind finished coils at the second take-up with the same concern. Should the same notification run there with coil wording and the coil target weight?
**Background:** The operator concern is identical at both places. One point to note if the answer is yes: FL2 running standalone does not broadcast live gauge and width, so its weight-per-foot factor has to come from the pass schedule or the order rather than from live measurement.
**Recommended answer:** Yes — run the same 75 / 90 / 100 ladder at the finished-coil take-up, with coil wording and the coil target weight. On FL2 standalone the weight-per-foot factor comes from the pass schedule or order, and it is the same factor as elsewhere rather than a new one.
**Why:** The operator concern is identical, and a second differently-shaped notification on the same shop floor is a training cost for no benefit.
**Impact if unanswered:** Finished-coil completion has no approaching-target warning, so operators get no notice before the coil reaches weight.

---

## Q20

**Register title:** Supervisor mirroring and audit persistence of milestone acknowledgements
**Area:** Spool lifecycle
**Needs input from:** Tim O., IT
**What we need:** Decision
**Question:** Is the spool completion alert operator-only, or is it also shown to the supervisor — particularly an **unacknowledged** 100 per cent milestone, which means nobody is at the machine while the spool fills? And where is the acknowledgement recorded for audit?
**Background:** An unanswered completion notification is a specific and actionable signal: the spool is filling and no one is responding. The other two rungs of the ladder are not, and mirroring all three would teach a supervisor to ignore the notification.
**Recommended answer:** Mirror only the unacknowledged 100 per cent milestone to the supervisor, not the whole ladder. Record the acknowledgement in the existing run-event history rather than a new record type.
**Why:** The unanswered completion is the one state a supervisor needs; mirroring everything trains them to ignore it. An acknowledgement is an event with an actor and a timestamp, which is exactly what the run-event history already holds.
**Impact if unanswered:** Supervisors get no visibility of an unattended machine at spool completion, and the acknowledgement has no confirmed audit home.

---

## Q21

**Register title:** FL{n}.LineState vocabulary, stop-dwell value, and pause-reason suppression
**Area:** Machine interface
**Needs input from:** Engineering, Tim O.
**What we need:** Values or data
**Answer together with:** Q13, Q27
**Question:** Three specifics about the signal the machine uses to report whether a line is running. First and most important: what are the actual state values it reports — is it a simple running/stopped indication, or does it distinguish running, stopped, paused, faulted, threading and jogging? Second: how long must "stopped" persist before we treat the stop as real? Third: if the operator has already used the software pause dialog and given a reason, should the stop-confirmation prompt be suppressed?
**Background:** This signal is what tells the system a spool can be removed and a rod can be checked out. If a threading or jogging state reports as "stopped", the system will offer those actions while the machine is still moving — so we need the literal list of values, not a description of them.
**Recommended answer:** On the first point, please give us the enumeration as a **list of literal values**, because the filtering depends on whether threading and jogging report distinctly or as stopped. On the second and third, adopt our proposals: a **five-second dwell** with speed at approximately zero as corroboration, and **suppress the prompt when a pause reason has already been captured**, unless that reason indicates spool removal.
**Why:** Only the first point genuinely needs your input — the other two are defaults we are happy to be corrected on. A described vocabulary rather than a literal one is what leaves us guessing.
**Impact if unanswered:** The spool-removal prompt and the rod-checkout gate both depend on deciding when the line is really stopped, so neither can be built.

---

## Q22

**Register title:** Dimensional tolerances — min/max for gauge, width, diameter and ovality; no column exists
**Area:** Quality and tolerances
**Needs input from:** Tim O.
**What we need:** Values or data

**Question:** We need the actual tolerance figures. The shape was confirmed on 30 July 2026 — upper and lower limits for gauge, width, diameter and ovality — and the values were to follow by e-mail. They have not arrived. Two secondary points: are the alloy tolerance figures already in circulation authoritative or do they need Process Engineering sign-off, and can tolerance vary by rod vendor or by nominal size within one alloy?
**Background:** Incoming rod diameter has to be validated against nominal plus or minus a tolerance at both pre-check-in and check-in, and there is currently nowhere to read that tolerance from. In the interim the pre-check-in screen shows a per-alloy set of figures that is explicitly mock data with nothing behind it. We are holding the reference data empty rather than seeding a guess: "plus or minus ten" is not a specification, and a seeded wrong number is worse than an empty one because it looks authoritative. Note the figures in circulation are tighter than the placeholder in the mockup, which means out-of-tolerance rod would have been accepted.
**Already agreed:** The tolerances exist, they are minimum and maximum pairs rather than single values, and there are four of them — gauge, width, diameter and ovality. They live in reference data and are applied at both pre-check-in and check-in.
**Recommended answer:** Send the four sets of figures. We will make the structural change now and seed nothing until they arrive, so the build is not waiting on the values. **Per-alloy is sufficient granularity** unless Process Engineering states that tolerance varies by vendor or by nominal size — please confirm that specifically. We will also consolidate the one ovality limit that is currently hard-coded so ovality is validated in one place rather than two.
**Why:** The shape is decided and the structure can be built empty, so the numbers and the schema are not blocking each other. But nothing can be validated against a tolerance that does not exist, so the figures block the check-in build regardless.
**Impact if unanswered:** Rod acceptance validation at both pre-check-in and check-in cannot be completed. This is a current blocker.

---

## Q23

**Register title:** Does a failed staging inspection persist a RodStaging row, and what releases it?
**Area:** Rod staging and pre-check-in
**Needs input from:** Tim O., IT
**What we need:** Confirmation of our reading
**Question:** One point remains. When a staging inspection fails, should the inspector's notes be **mandatory**? They are currently optional but documented as expected whenever any item fails.
**Background:** The substantive parts of this question were settled in July 2026. The reasoning behind them is physical: bundles are not unbanded until they are positioned at the payoff — which is precisely why the inspection happens at staging — so a rod that fails inspection is already sitting on the bay. Recording nothing left the system reporting an occupied bay as empty and offering it to the next rod, while a physically present rejected bundle blocked it.
**Already agreed:** A blocked bay is a **derived** state — staged, with any inspection item failed — rather than a separate status. Pre-check-in commits the staging record **before** the inspection gate, so the failure and the observation are both persisted and the bay correctly reads as blocked. There is no bypass: rejection remains the only forward path. A failed inspection is captured as a rejection on the rejection screen, the operator enters the reason there, the rod goes to hold, and that rejection is what releases the bay.
**Recommended answer:** Make the inspection notes **mandatory when any inspection item fails**, matching the treatment already applied to the other conditional field groups.
**Why:** A failure with no observation is the one case where the note carries the whole evidentiary value — and the existing documentation already says a note is expected there.
**Impact if unanswered:** Failed inspections may be recorded with no observation, which undermines the rejection audit trail.

---

## Q24

**Register title:** Staging deviations — off-schedule (auto-switch), out-of-sequence (override), PIN source
**Area:** Rod staging and pre-check-in
**Needs input from:** Tim O., Shannon R.
**What we need:** Decision
**Answer together with:** Q73
**Question:** Does the same out-of-sequence supervisor override apply at check-in as well as pre-check-in? And the out-of-sequence override itself was left in place provisionally pending your review — please confirm or remove it.
**Background:** Two parts of this were settled on 30 July 2026. On the out-of-sequence override you said it "might not be a bad idea" and asked to leave it in place while you reviewed something in the specification it may support — so it is currently built on an unconfirmed rule, and anything depending on it is depending on a provisional decision. On the check-in point, the decision said pre-check-in and check-in, but only the pre-check-in screen carries the control today.
**Already agreed:** Off-schedule is not a deviation at all — there is no blocking message and no override, and the system selects the correct station automatically. If the rod is planned for FL3 and the operator is on the FL1 tab, the screen switches to FL3 and the transaction continues, at both pre-check-in and check-in. Separately, and provisionally: the operator must be notified when the rod being checked in is not the one planning expects next, and a supervisor override is required to depart from the planned sequence — reason, badge or identifier and PIN, with a remote-approval fallback, all recorded. "Expects next" means the lowest planned sequence still available, so a blocked bundle does not freeze the sequence behind it.
**Recommended answer:** Yes to the check-in point — build the identical control at check-in, because a validation enforced at one of two entry points is not enforced. Validate the PIN against the **existing login and authorisation service**, so one credential path serves this override, the weight-variance override and the welded pre-check-out override. And please close the review you committed to on the out-of-sequence override.
**Why:** The multi-order sequencing rule independently requires the same control at check-in, so the two land together. A second credential store is an authentication surface with no owner. And a provisional rule that downstream work treats as final is the kind of thing that surfaces late.
**Impact if unanswered:** The sequence validation is enforceable at only one of the two entry points, and three supervisor overrides have no confirmed credential source.

---

## Q25

**Register title:** May a rod be processed when its order is scheduled on neither FL1 nor FL3?
**Area:** Rod staging and pre-check-in
**Needs input from:** Tim O., Shannon R.
**What we need:** Decision
**Question:** Three parts. Is running unscheduled material a real case — an unscheduled job, a trial, a rush piece the floor is told to run before planning catches up — or is planning always ahead of the floor? If it is allowed, is a supervisor override the right gate, and does it apply at both pre-check-in and check-in? And what order does the run book against: is scheduling corrected after the fact, or does the run carry an unscheduled marker?
**Background:** The case where a rod's order is booked on the *other* rod line is settled — the station switches automatically. This is the different case where the order is booked on **no flattening line at all**. Today that is a refusal by omission rather than by decision: staging checks a planning allocation exists and scheduling then supplies the line, and nothing states what to do when the allocation exists but the booking does not. This was raised on the 30 July call and not reached — it was carried forward to the next session.
**Recommended answer:** Allow it behind a supervisor override, at both pre-check-in and check-in, with the run carrying an **unscheduled marker** rather than being force-fitted to an order.
**Why:** Trials and rush pieces are real, and a refusal by omission means the floor works around the system instead of in it. Reusing the existing supervisor override fields and adding only the marker is a far smaller change than the alternative.
**Impact if unanswered:** Unscheduled material cannot be run at all, and nobody has decided that it should not be.

---

## Q26

**Register title:** Shopfloor panel resolution — 1280×1024 (stocked) vs 1920×1080 (required)
**Area:** Shopfloor screens
**Needs input from:** Tim O., Charles, Juan
**What we need:** Decision
**Question:** Will the flat wire screens run on the same 1280×1024 monitors United Aluminum stocks today, or on 1920×1080 panels? We need this confirmed in writing, and it is time-critical.
**Background:** Every screen is designed at 1280×1024, and the minimum text size for arm's-length reading on the floor is calibrated to that. You expected the same monitors as the current screens and were going to verify with Charles and Juan; our action was to send you the required resolution by e-mail. The reason it is urgent rather than merely open: 1920×1080 is a 1.5 times width change with almost no extra height, so it is a **re-layout of all twenty-five-plus screens, not a rescale**. The canvas size is an acceptance criterion for the first delivery phase, which closes on 14 August 2026 — an answer after that is an answer that arrives too late to be free.
**Recommended answer:** Hold 1280×1024, and confirm it in writing before 14 August. Our screens already degrade gracefully onto a wider panel — they never scale up beyond their natural size and they widen to fill available width — so 1920×1080 hardware would display them correctly today, simply leaving horizontal space unused.
**Why:** That makes 1280×1024 the safe commitment and any later re-layout an optimisation rather than a rescue. We are not re-authoring anything until this is answered.
**Impact if unanswered:** A late answer of 1920×1080 turns into a re-layout of every screen after the first phase gate has closed.

---

## Q27

**Register title:** Is speed pushed to the PLC as a target/setpoint or a limit/clamp?
**Area:** Machine interface
**Needs input from:** Tim O., Engineering
**What we need:** Decision
**Answer together with:** Q21, Q28, Q29
**Question:** When the pass schedule's line speed is sent to the machine at check-in acknowledgement, does the machine expect it as a **speed setpoint** it should run at, or as a **ceiling** bounding whatever speed the operator selects?
**Background:** Our own delivered documents say both, in different places, and they are not the same thing and do not fail the same way. If the value goes to a setpoint when the machine expected a ceiling, acknowledging a check-in starts the line moving at the scheduled speed — a serious surprise on a line that needs threading first. If it goes to a ceiling when the machine expected a setpoint, the line does not move at all and the fault looks like a missing signal. This is not resolvable from documents; it needs a controls answer.
**Recommended answer:** Please tell us which the machine expects. Until then we will implement against a **ceiling**, and leave the contradictory requirement wording unfixed rather than guess.
**Why:** We prefer the loud failure. A ceiling that should have been a setpoint means the line does not move, which is obvious and safe. A setpoint that should have been a ceiling starts a threading line at full scheduled speed the moment the operator acknowledges — a commissioning-time safety surprise.
**Impact if unanswered:** One of the values sent at every check-in has an unconfirmed meaning, with a safety consequence in one of the two readings.

---

## Q28

**Register title:** Is edge type pushed to the machine, and where are the edger tag paths?
**Area:** Machine interface
**Needs input from:** Tim O., Engineering
**What we need:** Decision
**Answer together with:** Q27
**Question:** Two parts. Is edge type actually sent to the machine at check-in — our documents list it in four places and omit it in a fifth? And do the FM2 edgers have addressable signals at all? We have found none. Separately, if an edger blade profile is to be sent, what are the permitted profile values and who maintains them?
**Background:** The likely explanation for the omission is that the fifth list was written FL1-first, and FL1 has no edger — but that is our inference, not a confirmation. The more substantive finding is that no edger signal exists anywhere in the published machine interface: the only edger-adjacent signal on any line is on FL1, the one line with no edger. So the specification currently sends an edge configuration to equipment that has nothing addressable on the read side. We have proposed signal names derived from the naming convention so there is something concrete to confirm or correct, and they are marked as our invention.
**Recommended answer:** Push edge type on **FL2 and FL3 only**, and treat its absence from the fifth list as the FL1-first omission it appears to be — FL1 has no edger, so there is nothing to write there. We will put our proposed edger signal names to your controls engineer as concrete strings to confirm or correct, clearly marked as our invention. Please answer the blade-profile vocabulary in the same conversation.
**Why:** A profile signal whose permitted values are unknown cannot be commissioned, so the paths and the vocabulary have to be settled together.
**Impact if unanswered:** Edge configuration cannot be sent to FM2, which affects every FL2 and FL3 run.

---

## Q29

**Register title:** On FL3, are FM2 tags addressed as FL2.FM2 or FL3.FM2?
**Area:** Machine interface
**Needs input from:** Tim O., Engineering
**What we need:** Decision
**Answer together with:** Q27
**Question:** On a hybrid FL3 run, is the finishing mill reached through FL2's controller, or does FL3 have its own address space for it? Put plainly: when FL3 sends its settings in one batch, does that batch cross a controller boundary?
**Background:** Every published machine map addresses the finishing mill stands under FL2. FL3 is the hybrid route and needs both mills configured, sent as a single batch on one acknowledgement. So either the finishing mill is physically owned by the FL2 controller and FL3 reaches it through FL2's address space — in which case the FL3 send writes to **two controllers** in one logical batch — or FL3 has its own address space for it and the send is one controller.
**Recommended answer:** We will assume the finishing mill is owned by the FL2 controller and that FL3 reaches it through FL2's address space, and **design the FL3 send for two controllers from the start** — a per-controller batch with an explicit compensating clear on partial failure. Please confirm or correct.
**Why:** That is the harder of the two cases, and building for it costs little now whereas discovering it at commissioning costs a redesign of the send. It also decides what a partial failure looks like and what the compensating clear has to undo — which is not a naming preference.
**Impact if unanswered:** The hybrid send is designed against an assumption about controller ownership, and the existing commissioning test passes either way so it cannot detect a wrong guess.

---

## Q30

**Register title:** Do take-up load cells exist, and is the spool-completion weight read or derived?
**Area:** Weights and measurement
**Needs input from:** Tim O., Bob S., Engineering
**What we need:** Decision
**Answer together with:** Q10
**Question:** Are there load cells on the take-ups? And is the spool completion weight **read** from them or **derived** from the footage counter and the measured cross-section? If both exist, which is authoritative when they disagree?
**Background:** Two of our documents disagree. One records an assumption that load cells are fitted on both payoff positions and on both take-ups; the other states the completion weight is derived from live footage and measured cross-section. And no take-up weight signal appears in the machine interface on any line. So the interface currently specifies a behaviour — the machine-stop prompt fires when take-up weight reaches target, and the recorded value is what appears on the **printed label** — that reads a value with no published source.
**Recommended answer:** Specify the completion weight as **derived from footage and cross-section**, and treat any take-up load cell as a **corroborating** reading rather than the source. If the cells exist, tell us and we will add their signals so commissioning can read them — but the transaction will not depend on them.
**Why:** It puts the scale-versus-calculated reconciliation in one place, one level down, instead of creating two competing rules at this level. Note the consequence: if the weight is derived, its accuracy rests entirely on the footage-to-weight dimensional basis, which is separately open and already critical.
**Impact if unanswered:** The most consequential number in the completion transaction — the one printed on the label — has no confirmed source.

---

## Q31

**Register title:** Wire break where the customer accepts no welds — the disposition set, the supervisor gate and where the decision is persisted
**Area:** Rod checkout and partial material
**Needs input from:** Tim O., Shannon R.
**What we need:** Decision
**Question:** Four points remain on the no-weld wire break. Is the disposition list exactly the Z-mill set — return to warehouse, scrap, continue processing, hold, concession — and does it reuse the existing screen? Is the supervisor gate a credential block, or an operator decision recorded against a supervisor's name? Does the concession path reuse the existing coil-break e-mail flow? And, before any of that, how often does this actually happen?
**Background:** The principle was agreed on the 6 August call: it is handled with the same logic as a Z-mill coil break, with a supervisor judging the material already on the spool against the planned weight. If there is enough material, approach the customer for a concession — "will you still take this, it's underweight by 250 pounds". If the break is early in the run, reject the material, strip the spool, mount an empty one, replan onto another input rod and rerun the order. You flagged this yourself as a genuine one-off — a customer ordering one or two skids rather than a truckload, who also refuses welds — and cautioned against over-engineering it.
**Already agreed:** Same logic as a Z-mill coil break. The judgement is a supervisor's, made on the total footage or weight already on the spool against the planned weight. Enough material means approach the customer for a concession; early in the run means reject, strip the spool, mount an empty spool, replan onto another input rod and rerun.
**Recommended answer:** Reuse the Z-mill disposition set and the existing screens — warehouse, scrap, continue, hold — with concession handled through the existing coil-break e-mail flow, and persist the decision in the run-event history. **Confirm the frequency before we size anything.** If it is genuinely a one-off, the right build is a supervisor disposition on existing rails and **no new screen**.
**Why:** We are taking your own caution seriously: building a dedicated path for a case that may never recur is the wrong trade against a 30 September window.
**Impact if unanswered:** A no-weld customer's wire break has no defined disposition path, and the persistence target is undecided.

---

## Q32

**Register title:** FM2 dancer modes (dancer vs tension) — who selects, per dancer or per line, scheduled or machine-side, read or written
**Area:** Machine interface
**Needs input from:** Tim O., Engineering
**What we need:** Decision
**Question:** ⚠ **We may have this wrong, and we would rather say so than present a clean recommendation.** Five points on the FM2 dancer modes. Who selects the mode — the operator, the pass schedule, or is it fixed per product? Both dancers always in the same mode, or set independently? Is the mode a **pass schedule parameter**, in which case it is sent to the machine at check-in, or a **machine-side setting** the system only reads? If it is sent, what carries it? And in tension mode, is a tension setpoint entered, and where does it come from?
**Background:** You disclosed this equipment behaviour on the 6 August call: FM2 will have two dancers, positioned where the edgers are, each with a regular dancer mode for compensating speed control and a tension mode similar to the current mills. Nothing in our design models it. Two further points follow. Tension mode contradicts a rule we hold — that tension is derived from speed and never entered manually — which needs qualifying by mode rather than deleting. And the third question decides whether this adds schedule data or only a read subscription.
**Already agreed:** The equipment is on record — one dancer on FM1, two on FM2, between the first and second stands and between the second and third. What is missing is the model rather than the equipment. We have authored a **read-only** view of the mode, which holds whichever way the third question is answered; the write side is absent.
**Recommended answer:** ⚠ **Read this against your own earlier statement before acting on it.** On 23 July you told us dancers **remove** tension rather than apply it, that tension control is primarily **machine-driven**, and that configuration values are controlled through process settings. If that is right, **this recommendation is wrong and the read-only view we have already built is the whole answer.** Our recommendation, left standing deliberately so you can knock it down: model the mode as a **pass schedule parameter** rather than a machine-side setting we merely read, and set it **per dancer**, since the two sit in different positions. A second engineering question rides on the same answer: if dancers remove rather than apply tension, then our model of applied tension reducing roll separating force may be modelling something the equipment does not do — and that feeds through to the calculated roll gap.
**Why:** We recommend the schedule-parameter treatment because the mode changes two calculated values on the pass schedule — separating force, and therefore roll gap — so a read-only treatment would let the schedule and the machine disagree about the physics. But the 23 July statement argues the opposite and it is the earlier, more specific one. Both readings may even be true: a dancer can physically absorb tension while still offering a machine-side tension mode. This is an engineering answer, not an editorial one, which is why we are showing you the conflict rather than resolving it ourselves.
**Impact if unanswered:** Until this closes we generate pass schedules untensioned and flagged — conservative for force, but **not** for gauge, so the calculated roll gap may deliver thin in tension mode.

---

## Q33

**Register title:** OD/diameter → weight conversion formula for spool
**Area:** Weights and measurement
**Needs input from:** Tim O.
**What we need:** Confirmation of our reading
**Answer together with:** Q10
**Question:** When a spool is measured by its outer diameter at the take-up, how is the remaining weight calculated? We need the formula confirmed and documented.
**Background:** Weight distribution is already tracked through footage and revolutions, but the diameter-based verification calculation is a separate thing and is still needed before spool weight tracking and as-is stock handling can be built.
**Recommended answer:** Derive it from the same single footage-to-weight factor rather than as an independent formula — the volume of the annulus from outer diameter, inner diameter and coil width, times alloy density — so spool weight, coil weight and the printed label all trace back to one number.
**Why:** Two independently confirmed formulas will disagree in the third decimal and nobody will know which is authoritative. The accumulated scale-versus-calculated variances are the data that would validate this one.
**Impact if unanswered:** Spool weight tracking and as-is stock handling cannot be implemented.

## Q34

**Register title:** Transaction name for a flat wire coil completion in the shared plant records, and whether any existing report filters on it
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Confirmation of our reading
**Answer together with:** Q35
**Question:** Completing a flat wire coil now creates the same set of plant records any other finished coil has, and each of those records carries a short transaction name. What name should a flat wire coil completion use, and does any existing report, screen or process filter on that name in a way a new value would disturb?
**Background:** Three of the records created at coil completion carry a transaction name, and all three use the same eight-character field. Reusing an existing name would make a flat wire completion indistinguishable from the skid creation the slitters do, which defeats the purpose of recording it. One other existing name would additionally cause a duplicate history entry to be written.
**Recommended answer:** A new name reserved for flat wire, eight characters so it fits the field exactly, used consistently across all three records so that one completion is traceable end to end.
**Why:** This is the one value in the new records that every existing consumer of the shop-floor history can see, and we cannot tell from the code which reports depend on that column — the impact review that would have told us was removed along with the shared-schema changes. It is a short conversation and an expensive thing to get wrong, because a wrong value does not raise an error: it writes a name an existing report may quietly filter out.
**Impact if unanswered:** The work can be built and tested against development copies, but must not run against live plant data.

---

## Q35

**Register title:** Whether a finished flat wire coil carries the existing on-skid status or needs one of its own
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Confirmation of our reading
**Answer together with:** Q34
**Question:** The finished coil record created at completion needs a status value. Should a finished flat wire coil carry the existing status used for a coil that is complete and on a skid, or does finished flat wire need to be distinguishable from other finished material by its status?
**Background:** The existing status is accurate — the coil is complete and it is on a skid — and it is exactly what the equivalent transaction writes for a slitter coil. A new value would be an addition to a status vocabulary that every system in the plant reads.
**Recommended answer:** Reuse the existing status. Introduce a new value only if a named report or process actually requires flat wire to be told apart, in which case the right change is to that report rather than to the shared vocabulary.
**Why:** The question is not what the coil is, which is settled, but whether anything downstream needs to distinguish it. If something does, we would rather find out now than after the first coil is written, because a status value is read far more widely than it is written.
**Impact if unanswered:** As Q34 — buildable, but not against live plant data.

---

## Q36

**Register title:** Sample number and planned operations for a flat wire output coil when they cannot be inherited from the rod
**Area:** Shared plant records
**Needs input from:** Tim O. / Planning
**What we need:** Confirmation of our reading
**Question:** The record linking a finished coil to its order carries a sample number and a planned-operations value. Where the source rod already has an order record these are copied from it. Where it does not, what should a flat wire output coil carry?
**Background:** Copying from the rod is established behaviour and needs no decision. The fallback only applies when a rod reaches coil completion without an order record, which should not happen if check-in worked correctly — so this is a question about what a defensive path should write.
**Recommended answer:** Copy from the rod wherever a record exists, and fall back to the same values the equivalent slitter transaction uses. Only the fallback needs confirming.
**Why:** The cost of being wrong is a misleading sample number on an edge case rather than a broken transaction, which is why we have ranked this below the other two. But a defensive path that writes a plausible wrong value is harder to notice later than one that writes nothing.
**Impact if unanswered:** Minor. A rod arriving at completion without an order record would be linked with an unconfirmed sample number.

---

## Q37

**Register title:** Transaction token for a flat wire rod check-in in the shared plant records
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Confirmation of our reading
**Answer together with:** Q38, Q39, Q40
**Question:** Checking a rod in at a flattening line now creates a set of records in the existing plant systems, several of which carry a short transaction name. What name should a flat wire rod check-in use, and does any existing report, screen or process filter on that name in a way a new value would disturb?
**Background:** Nine plant records are written when a rod is checked in, and several of them carry the same eight-character transaction name field every other operation uses. Reusing an existing operation's name would make a flat wire check-in indistinguishable from that operation in the shop-floor history, which defeats the point of recording it at all.
**Recommended answer:** A new name reserved for flat wire check-in, eight characters so it fits the field exactly, used consistently across every record written by the same check-in so one transaction is traceable from end to end.
**Why:** This is the most widely visible of the new values — every existing consumer of the shop-floor history can see it — and we cannot tell from the code which reports depend on it, because the impact review that would have told us was removed along with the shared-schema changes. A wrong value does not raise an error: it writes a name an existing report may quietly filter out.
**Impact if unanswered:** The work can be built and tested against development copies, but must not run against live plant data.

---

## Q38

**Register title:** Transaction-log status value for a rod on a flattening line — new value or reuse
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Confirmation of our reading
**Answer together with:** Q37
**Question:** The shop-floor history entry written when a rod is checked in needs a status value describing what is happening to the material. Does flat wire need a status of its own here, or should it reuse the value already used for material on a rolling mill?
**Background:** A new status value would be an addition to a vocabulary every system in the plant reads, and adding to shared vocabularies is exactly the class of change that was cancelled when the shared-schema work was dropped. The existing rolling value is accurate — the material is on a mill being rolled. The flat wire module does keep a flattening status of its own internally, which nothing outside it sees.
**Recommended answer:** Reuse the existing rolling status. Introduce a flat-wire-specific value only if a named report or process genuinely needs to tell flattening from rolling in the history, in which case the right change is to that report rather than to the shared vocabulary.
**Why:** A status value is read far more widely than it is written, so the cost of a new one is spread across systems nobody is currently looking at. If something does need the distinction we would rather find out now than after the first rod runs.
**Impact if unanswered:** As Q37 — buildable, but not against live plant data.

---

## Q39

**Register title:** Is stamping the rod's shared coil row with a flattening station safe for existing consumers?
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Confirmation of our reading
**Answer together with:** Q37
**Question:** When a rod is checked in we propose stamping its existing material record with the station it is being processed at, the operator badge, the transaction name and the time — the same marks every other operation leaves. Is that safe for the reports and screens that already read those fields?
**Background:** With the shared-schema changes cancelled, nothing outside the flat wire module now marks a rod as being on a flattening line, so a rod can be in process with no sign of it anywhere else. Stamping these four fields restores that visibility using columns that already exist. We are deliberately **not** changing the material's status, which is the field read most widely of all.
**Recommended answer:** Write all four. They are how every operation marks material as being worked, the values are ordinary ones, and leaving them blank is what created the visibility gap in the first place.
**Why:** The alternative is a rod being processed with nothing in the plant record to say where it is, which was judged unacceptable when we found it. We are asking you to confirm rather than assume, because this is the one place flat wire becomes visible in the wider system at all.
**Impact if unanswered:** As Q37 — buildable, but not against live plant data, and the visibility gap stays open until it runs.

---

## Q40

**Register title:** On reversing the reqsum at pre-check-out, delete the row or zero it?
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Decision
**Answer together with:** Q37
**Question:** Checking a rod in writes a requirement record against the order, showing the material the order has claimed. If the rod is then taken back off the line before anything has been made, that record has to be reversed. Should the reversal remove the record entirely, or leave it in place with its quantities set to zero?
**Background:** The reversal already refuses to run once any material has been produced, because at that point the order genuinely did receive material. So this question is only about the case where the rod comes off having made nothing.
**Options:** (1) Delete the record, leaving no trace of the claim. (2) Leave the record and set its quantities to zero.
**Recommended answer:** Leave it and zero it. A deleted record destroys the evidence that the material was ever claimed against the order; a zeroed one is auditable and can be corrected. Please tell us if any existing report counts these records rather than summing their quantities — that is the one case where a zeroed record reads differently from an absent one.
**Why:** Both directions are recoverable except one: you can always zero a record you decided to keep, and you cannot restore one you decided to delete. Where the two are otherwise equal we would rather keep the audit trail.
**Impact if unanswered:** We will build the safer direction — zeroing — so that a missing answer never causes a deletion.

---

## Q41

**Register title:** What does an FL2 pre-check-in do — persist or validate, hold a station or release it, gate check-in or not
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Bob S.
**What we need:** Decision
**Question:** You have asked for pre-check-in at FL2, so the operator can validate the next spool rather than discover at check-in that they have fetched the wrong one. We need to know what that step should actually do. Does it record that the check was made, or is it a look-and-go validation? Does it reserve the line for that spool, or release it again immediately? And must it be completed before check-in, or does it stay optional as it is on the rod line?
**Background:** FL2 has one payoff and no floor space, so there is nowhere to stage a spool — which is why pre-check-in was previously excluded there. Your reason for wanting it is validation rather than staging, and those are different things. Two of the things the rod line's pre-check-in does have no equivalent at FL2: it performs a visual inspection before unbanding, which is not done on a spool because the material was already inspected as rod, and it manages two alternating payoff positions, of which FL2 has one.
**Already agreed:** FL2 does get pre-check-in, to validate the next spool and eliminate downtime spent locating the right material after finding out at check-in that the wrong spool was collected.
**Options:** (1) Validate only — the screen checks the spool and records nothing. (2) Validate and record, releasing the line again immediately. (3) Validate and reserve the line until the spool is checked in. And separately, for any of the three: required before check-in, or optional.
**Recommended answer:** Option 2, and keep the step optional. Recording it makes the check auditable and means the operator's effort is not lost if they are called away. Releasing rather than reserving reflects the single payoff — a reservation would block the line on a spool that has not arrived. Keeping it optional matters most: check-in must stay reachable without it, exactly as on the rod line, so a busy operator is never prevented from starting a run.
**Why:** The answer decides whether this is a change to a screen you have already seen or a new record with new rules behind it, and that difference is material to both the estimate and the sprint it lands in. It also decides whether an operator can be blocked from starting a run, which is the kind of rule that is easy to agree in a meeting and expensive to live with on a shift.
**Impact if unanswered:** The screen can be prepared but the step itself cannot be built, and it cannot be included in the sprint starting 24 August.

---

## Q42

**Register title:** Spool carrier identifier format, and where the registry is mastered
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Bob S.
**What we need:** Values or data
**Answer together with:** Q44
**Question:** What will the numbers stencilled on the spools look like, and how many spools will there be in the end? The screens accept the number as typed and check it against a registered list, so we need that list.
**Background:** You have confirmed the spools are reusable physical carriers identified much like furnace plates — thirty purchased, with a decision on a further fifteen pending, and all of one standard size. The number is typed and checked rather than chosen from a list, because thirty to forty-five entries is too long to scroll on a shop-floor panel.
**Already agreed:** Spool numbers are static and stencilled on the spool, not generated per job. All spools are one standard size. The number is entered as text and validated, not selected from a drop-down.
**Recommended answer:** Whatever nomenclature you decide to stencil, given to us as a plain list so we can load it. We will accept the number as typed and ignore capitalisation, since the operator is reading paint off steel. We hold the list inside the flat wire module rather than adding it to an existing plant table, so adding or retiring a spool is a data change and nothing more.
**Why:** Until the list exists the number cannot be checked, and an unchecked number is worse than no number: a mistyped entry would be accepted and the material would be recorded against the wrong carrier, which then travels through the furnace and arrives at FL2 mislabelled.
**Impact if unanswered:** We will build the validation against a placeholder list and swap it, but nothing can be tested end to end until the real numbers exist.

---

## Q43

**Register title:** How many orders per spool, and does FL2 check-in choose the order or inherit it?
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Planning
**What we need:** Decision
**Question:** A spool can carry more than one order. When it is checked in at FL2, does the operator choose which order is being made, or should the system determine it? And is there a practical limit to how many orders one spool can carry?
**Background:** You confirmed that a spool coming off FL1 may carry two or more orders, while FL2 makes one order at a time. Separately, a spool with no order at all is a legitimate case — a planning remainder, or a part-run spool accepted back by a supervisor — and the spool queue screen already allows such a spool to be checked in.
**Already agreed:** A spool may carry several source rods and several orders. FL2 makes one order at a time out of a spool.
**Options:** (1) The operator selects the order at check-in from those on the spool. (2) The system derives it from the material expected off the spool first. (3) Planning nominates the order and the operator cannot change it.
**Recommended answer:** Option 1, defaulted from option 2 — planning allocates the set of orders to the spool, the system offers the order of the material expected off first, and the operator can change it. That makes the common case a single keypress and still lets the operator correct it when the spool is threaded the other way round. We would not put a limit in the system on how many orders a spool may carry; the check that matters is that the order chosen is genuinely one of those on the spool.
**Why:** Deciding this now rather than later is what stops the records being designed around a single order and rebuilt when the second one appears. It also settles whether a spool with no order can still be run, which the screens currently allow and the underlying records currently forbid — a contradiction we would rather resolve deliberately than discover on a shift.
**Impact if unanswered:** Order allocation on a spool cannot be recorded, and the one documented case of a spool with no order cannot be checked in at all.

---

## Q44

**Register title:** What the FL1 spool label prints, and on what media
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Bob S.
**What we need:** Decision
**Answer together with:** Q42
**Question:** Exactly what should print on the spool label, and will the etched steel plates you are investigating replace the label or sit alongside it?
**Background:** The label itself is settled: the inch-and-a-half by three-inch high-temperature label already used on mill output, two to a label so one goes on each side of the spool, printed when the spool is completed, carrying the spool number and the material identities on it. Nothing else survives the anneal. What is not settled is the full list of what prints, and this document has referred to printing the labels throughout without ever stating it.
**Already agreed:** The high-temperature label, two per spool, one per side. It carries the spool number and the material identities on the spool, and scanning any one of them at FL2 finds the spool — the same way scanning one identity on a furnace plate gets the plate into anneal.
**Recommended answer:** Print the spool number, every material identity on the spool with the weight each contributed, and the order or orders. The spool number is the primary barcode and each material identity a secondary, so the operator can scan whichever is facing them. The pass schedule stays off the label, as agreed previously. If the etched plates prove workable, we would suggest they carry the spool number only and sit alongside the label rather than replacing it — the spool is permanent and so is the etching, whereas the material on it changes every cycle.
**Why:** The weights are the part worth deciding deliberately: they are what the welding wire certificates are built from, and they depend on the footage-to-weight conversion still outstanding. Printing a number derived from an unconfirmed conversion is worse than not printing it, because a figure on a label is treated as measured.
**Impact if unanswered:** The label prints the spool number and the identities only, and any weight has to be looked up on a screen instead.

---

## Q45

**Register title:** Is last on, first off guaranteed — is the label's lead alpha a fact or a prediction?
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Engineering
**What we need:** Confirmation of our reading
**Question:** Does a spool always unwind in the reverse of the order it was wound, so that the last material on is the first off? And should the system therefore treat the identity leading the label as the one it requires at the next check-in, or as an expectation it must be willing to be wrong about?
**Background:** You told us the spool runs in reverse, and that the identity leading the label should be the one expected at the next operation. It was also pointed out that FL1 runs continuously, so the finished coils cut from a spool cannot be sequenced in advance. Both statements are correct and they are about different things — the first about the source material going onto the spool, the second about the coils coming off it — but they lead to different behaviour at check-in, which is why we are asking.
**Already agreed:** The identity leading the printed label should be the one expected at the next check-in.
**Options:** (1) The leading identity is required — scanning any other identity on the spool is refused. (2) It is expected — any identity on the spool is accepted, and the expected one is shown for information. (3) It is expected, and a mismatch warns without blocking.
**Recommended answer:** Option 2. Show the expected identity prominently and accept any identity on the spool without a warning; the operator is holding the spool and the system is not. If engineering can confirm the unwind direction is genuinely guaranteed, please tell us — it would let the system catch a mis-threaded spool, which is a check we have no other way of making.
**Why:** The two possible mistakes cost very different amounts. Treating an expectation as a rule stops a correct spool at check-in and puts the operator on the phone to a supervisor. Treating a rule as an expectation only loses a check nobody has today. Until the direction is confirmed, the permissive reading is the safe one.
**Impact if unanswered:** We build the permissive behaviour, which is safe but leaves a mis-threaded spool undetected.

---

## Q46

**Register title:** Mandrel / core diameter at FL1 — selected per spool, fixed by the standard size, or read from the machine?
**Area:** Run start and machine setup
**Needs input from:** Tim O.
**What we need:** Confirmation of our reading
**Question:** You mentioned that the system needs to know the diameter of the mandrel fitted, comparing it to selecting the mandrel size on a slitter. Does this vary from spool to spool, or is it fixed by the one standard spool size?
**Background:** Nothing records this today. On a slitter the mandrel genuinely varies, which is why the operator selects it. Here you have also confirmed that every spool is the same standard size, which would make the diameter a fixed property rather than a choice.
**Options:** (1) The operator selects it per spool when the spool is completed. (2) It is fixed by the standard spool size and recorded once, with no operator entry. (3) It is read from the machine.
**Recommended answer:** Option 2, if the spools really are all one size. A box that can only ever hold one value is a box that will eventually be filled in wrongly, and the diameter belongs to the spool specification rather than to the shift. If it does vary, then option 1 — and it belongs on the spool completion step beside the spool number, not at check-in, which is at the other end of the machine.
**Why:** It also feeds the outside-diameter to weight calculation. Taking the diameter from a permitted range rather than a single known value is how a calculated weight quietly drifts, and that weight ends up on a label and a certificate.
**Impact if unanswered:** We record the diameter against the spool specification and do not ask the operator for it, which is reversible if you tell us it varies.

---

## Q47

**Register title:** Is the maximum output coil weight the optimisation target, or the start of a downward search?
**Area:** Planning and scheduling
**Needs input from:** Tim O. / Planning
**What we need:** Confirmation of our reading
**Question:** When planning divides an order into finished coils, should it always divide by the customer's maximum coil weight, or should it try smaller weights downward from the maximum to find the one that leaves the least unusable material?
**Background:** The method agreed is to take the planned weight, divide by the maximum finished coil weight, round down to a whole number of coils and multiply back — which stays inside the customer's tolerance and leaves no overage. On a 44,000 lb planned weight against a 900 lb maximum that gives 48 coils and 43,200 lb. The remaining question is narrower than the method: whether the maximum is simply the divisor, or the starting point of a search.
**Already agreed:** Plan to the maximum finished coil weight and work backwards. Maximise the spool weight coming off FL1 to make best use of anneal capacity, then respect the customer's minimum and maximum at FL2 so that no unshippable remainder is created — a coil below the customer minimum is scrap, not a short coil. Where the order quantity is smaller than one spool, the order quantity governs. The calculation runs on the planner's planned weight rather than the order weight, with the existing over-order warning.
**Options:** (1) Always divide by the maximum. (2) Search downward from the maximum for the weight that minimises leftover material. (3) Search downward for the weight that minimises over-shipment against the order.
**Recommended answer:** Option 1. Rounding down already guarantees no overage, and the largest coils mean the fewest cuts for us and the fewest units for the customer, which is the reason you gave for starting at the maximum. Show the planner what is left over and let them place it, rather than having the system choose a slightly different coil weight on every order for reasons the planner cannot see.
**Why:** Both of you said to optimise to the maximum, but the question actually asked was about searching downward from it, and those are compatible statements that do not settle it. A search is easy to build and hard to predict at the planning desk, which is the wrong trade for a number a planner has to defend to a customer.
**Impact if unanswered:** Planning is built to divide by the maximum. Changing it later is a calculation change rather than a redesign, so this is the least costly of the open planning questions to defer.

---

## Q48

**Register title:** Can two orders on one rod have different pass schedules? If so the boundary cannot be crossed mounted
**Area:** Planning and scheduling
**Needs input from:** Tim O. / Planning
**What we need:** Decision
**Question:** When planning puts two orders on a single rod, can those two orders call for different mill settings - a different gauge, width or edge - or will they always share the same settings?
**Background:** A rod stays mounted across an order boundary, and the machine settings are sent to the line once, when the rod is checked in. If the second order needs different settings there is no moment at which to send them without stopping and re-checking-in, which means unloading a part-run rod.
**Options:** (1) Two orders on one rod always share the same settings, and planning enforces it. (2) They may differ, and the operator must check the rod out and back in at the boundary. (3) They may differ and the system sends new settings mid-rod.
**Recommended answer:** Option 1. Have planning refuse to pair orders with different settings on one rod.
**Why:** Option 3 means changing the mill while material is in it, which nobody has proposed and which would leave a length of wire made to neither setting. Option 2 works but throws away the benefit of pairing orders on a rod in the first place. Option 1 costs planning a validation rule and costs the shopfloor nothing.
**Impact if unanswered:** This is the most consequential unanswered question in the rod-to-order design. If different settings are possible, the mounted-across-the-boundary flow needs a stop-and-restart path built into it, and the estimate grows.

---

## Q49

**Register title:** Does multi-order-last hold when no weld is involved? Q73 item 6's unresolved branch
**Area:** Planning and scheduling
**Needs input from:** Tim O.
**What we need:** Confirmation of our reading
**Question:** The rule that a rod shared between orders is run last in its order applies when that rod is welded to the next one. Does it still apply when there is no weld?
**Background:** The reason given for running a shared rod last was to keep the weld at the end of the order rather than in the middle of it. Where no weld is involved that reason does not apply, so it is unclear whether the sequencing rule is still wanted.
**Options:** (1) The rule applies to every shared rod. (2) It applies only to welded ones.
**Recommended answer:** Option 1 - apply it to every shared rod.
**Why:** A single rule the operator can predict is worth more than a narrower one that is technically minimal, and the cost of running a shared rod last when it did not strictly need to be is nil.
**Impact if unanswered:** The sequence check refuses rods presented out of order. If the rule is narrower than we have built, it will refuse work the plant considers perfectly normal.

---

## Q50

**Register title:** What overrun is acceptable past the allocated weight - warn at what, escalate to whom?
**Area:** Weights and measurement
**Needs input from:** Tim O. / Shannon R.
**What we need:** Values or data
**Question:** Material keeps being produced between the moment an order's allocated weight is reached and the moment the operator confirms it. How much overrun is acceptable before someone is told, and who is told?
**Background:** The line is deliberately not stopped when the allocation is reached, so some overrun is unavoidable. In the worked examples the overrun on one order equals the shortfall on the next to the pound, so it is not waste - but it is unattributed until someone decides where it belongs.
**Options:** (1) A fixed number of pounds. (2) A percentage of the allocation. (3) A percentage with a pounds floor for small orders.
**Recommended answer:** Option 3, starting at 2% with a 25 lb floor, adjustable without a code change.
**Why:** A flat percentage is unusable on a small order, where 2% may be a few pounds and would fire constantly; a flat pounds figure is meaningless on a 40,000 lb run. Making it configurable lets the first month of real running set it rather than this meeting.
**Impact if unanswered:** We have built a warning and a supervisor escalation, but the threshold is a guess. Set too low it will cry wolf on every order; set too high it will never fire.

---

## Q51

**Register title:** On an early acknowledgement, where does the unconsumed allocation go?
**Area:** Planning and scheduling
**Needs input from:** Tim O. / Planning
**What we need:** Decision
**Question:** An operator may mark an order complete before its allocated weight is reached, because they can see the material is finished. What happens to the pounds that were allocated and never run?
**Background:** The system records the shortfall, so the number is not lost. What is undecided is whether those pounds return to the order to be made up later, move to the next order on the rod, or are written off as a short shipment.
**Options:** (1) The order closes short and the remainder is written off. (2) The remainder returns to the order for a later rod. (3) The remainder moves to the next order on the rod.
**Recommended answer:** Option 1, with the shortfall reported.
**Why:** The operator acknowledged early because the material was genuinely done, which is a statement that the order is finished, not that it is owed more. Options 2 and 3 both re-plan on the operator's behalf from a single button press.
**Impact if unanswered:** The order's material status is worked out from what was consumed. Without this rule an early acknowledgement leaves an order looking permanently part-filled, and planning cannot tell whether to schedule more material.

---

## Q52

**Register title:** A shared rod exhausts before the outgoing order is satisfied - top up, or stay short?
**Area:** Planning and scheduling
**Needs input from:** Tim O. / Planning
**What we need:** Decision
**Question:** If a rod shared between two orders runs out before the first order has had its allocated weight, does the plant bring another rod in to top that order up, or does the order ship short?
**Background:** The planned split assumes the rod yields its nominal weight. Real rods vary, and the rod weight itself is one of three figures currently in circulation, so a shortfall is likely rather than exceptional.
**Options:** (1) Top up from another rod, with supervisor authorisation. (2) Ship short and let planning decide. (3) Top up only above a stated shortfall.
**Recommended answer:** Option 1.
**Why:** An unplanned substitution already needs a supervisor, so the mechanism exists; and shipping short without asking is the outcome least likely to be what the customer wanted.
**Impact if unanswered:** This decides whether bringing in an unplanned rod is a normal path needing a supervisor authorisation, which we have built, or an exception that should not arise.

---

## Q53

**Register title:** Is fulfilment consumed or produced pounds - and which does the certificate state?
**Area:** Certification and traceability
**Needs input from:** Tim O. / Shannon R.
**What we need:** Decision
**Question:** Is an order counted as fulfilled by the pounds of rod consumed against it, or by the pounds of finished wire produced from it - and which of the two does the customer certificate quote?
**Background:** The two figures differ by process loss, so they are never equal. Consumption is what the plant controls and can measure at the payoff; production is what the customer receives.
**Options:** (1) Consumed pounds throughout. (2) Produced pounds throughout. (3) Track both; fulfil on consumed, certify on produced.
**Recommended answer:** Option 3.
**Why:** They answer different questions and both are wanted: the plant needs consumption to know when a rod's allocation is spent, and the customer needs produced weight because that is what arrives. Tracking both costs one extra stored figure and removes the need to choose.
**Impact if unanswered:** Every fulfilment figure, the completion notification and the certificate all read from the same basis. Choosing later means changing all three together.

---

## Q54

**Register title:** Does the order acknowledgement also close the FL1 spool, or may a spool span the boundary?
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Bob S.
**What we need:** Decision
**Question:** When the operator marks an order complete part-way through winding an FL1 spool, does that also close the spool, or may one spool carry material belonging to two orders?
**Background:** A finished coil belongs to exactly one order. If a spool spans an order boundary, the finishing mill must cut at that boundary, and the worked examples show that turning a good 1,800 lb spool into two coils below the customer minimum. Closing the spool at the acknowledgement avoids that outright, at the cost of a lighter spool.
**Options:** (1) The acknowledgement closes the spool. (2) A spool may span the boundary and the mill cuts at it. (3) It spans only if the material left exceeds one coil weight.
**Recommended answer:** Option 1.
**Why:** It removes the failure rather than managing it. A lighter spool costs a little anneal capacity; two sub-minimum coils cost the material and the order.
**Impact if unanswered:** This is the strongest available fix for a known failure that otherwise makes unsellable coils from good material. Building it later means changing spool completion, the spool queue and the mill's cutting rules together.

---

## Q55

**Register title:** Should the spool carrier prefix differ from the material one? SP-0001 against SP-00021
**Area:** Spool lifecycle
**Needs input from:** Tim O. / Bob S.
**What we need:** Confirmation of our reading
**Question:** The reusable stencilled spool and the batch of material wound onto it are two different things, and both get a number. Should they be told apart by their prefix, or is the context always enough?
**Background:** The physical spool is stencilled once and used for years; the material on it changes every run. Today both read as SP- numbers of different lengths.
**Options:** (1) Keep one prefix and rely on context. (2) Give the carrier its own prefix.
**Recommended answer:** Option 2, with SC- for the carrier.
**Why:** Two things sharing a prefix and differing only in how many digits follow is the kind of distinction that survives in a specification and not on a shop floor at shift change. This is the cheapest moment it will ever be to separate them.
**Impact if unanswered:** A cosmetic choice with a long tail: the prefix is stencilled onto physical equipment and appears on labels, so changing it after the first batch is stencilled is not a software change.

---

## Q59

**Register title:** Can another caller of the shared alpha generator be issued an alpha an FL1 segment already holds?
**Area:** Shared plant records
**Needs input from:** Tim O. / IT
**What we need:** Confirmation of our reading
**Question:** Flat wire takes its identifiers from the same shared generator the rest of the plant uses. Can any other caller be handed an identifier that a flat wire spool segment is already using?
**Background:** The generator works out the next free number by scanning the tables it knows about. The flat wire database is not among them, so prior flat wire identifiers are passed in explicitly on every call. That works only for as long as every caller does it.
**Options:** (1) Confirm no other caller can collide. (2) Add flat wire to the generator's own scan. (3) Reserve a number range for flat wire.
**Recommended answer:** Option 3 if a range is available, otherwise option 2.
**Why:** Both remove the dependency on every future caller remembering to pass prior identifiers in. A reserved range is the simpler of the two and needs no change to a shared piece of plumbing that four databases already depend on.
**Impact if unanswered:** A duplicated identifier across two modules is the kind of defect found at certification rather than at build, and it cannot be put right once labels are printed.

---

## Q87

**Register title:** What does the FL2 finished-coil label carry, on what media - and does a two-rod coil print one alpha or two?
**Area:** Output and packaging
**Needs input from:** Tim O. / Bob S. / Shannon R.
**What we need:** Decision
**Answer together with:** Q4
**Question:** What is printed on the label of the finished coil the customer receives, on what media - and where a coil was wound from two source rods, does the label carry one identifier or both?
**Background:** The label the plant uses today prints as a sheet, so a single coil would waste most of one. The skid label is a candidate carrier instead, and something has to sit under the stretch wrap. Traceability wants both source identifiers recorded, but that is not the same as printing both on the face the customer sees.
**Already agreed:** Whatever is chosen must be consistent with the coil labels the plant already produces, and full traceability must be recorded even where it is not all printed on the customer-facing label.
**Options:** (1) A coil label on new media. (2) Traceability on the skid label with a minimal coil label. (3) One identifier on the printed face, both recorded against the coil.
**Recommended answer:** Option 3 for the identifiers, with the media decided together with Q4.
**Why:** A customer reading two identifiers on one coil has to work out what that means; the certificate is the right place for the full genealogy, and the coil record already holds it. The media half genuinely depends on the skid decision and should not be settled separately.
**Impact if unanswered:** Deferred on the 24 August call. Coil completion cannot be finished without it, and it is bound up with the skid labelling question - the same decision seen from the other end.

---

## Q92

**Register title:** What columns does the roll-set Tooling Inventory grid carry, and are capstan rolls the same tool option as mill rolls?
**Area:** Tooling management
**Needs input from:** Tim O. / Maintenance
**What we need:** Information
**Answer together with:** Q26
**Question:** What columns should the roll-set grid on the Tooling Inventory tab carry, and in what order - and should capstan rolls be the same tool option as mill rolls, or a separate one?
**Background:** On 3 September you asked us to include mill rolls for traceability, naming the 12 inch set on FL1, the DB1 and DB2 capstan rolls, and the 8, 6 and 6 inch sets on FL2, and confirming that dancers, entry guides, payoffs and spools are not tooling. That is the fourth tool type on the tab. The other three - dies, edging rolls and straighteners - each reached us as a screenshot of the grid with the columns in the order you wanted them. Roll sets reached us as a sentence, so the register is built against our reading of it rather than against a grid you have seen.
**Already agreed:** Roll sets belong on the Tooling Inventory tab, for traceability. Dancers, entry guides, payoffs and spools do not. Tooling is maintained for FL1 and FL2, with FL3 using a combination of the two. The capstan rolls can be refurbished, current inventory is two and a spare is being added.
**Options:** (1) Send the roll-set grid as a screenshot, as you did for the other three. (2) Confirm our proposed column list as it stands. (3) Tell us the differences from the edging-roll grid and we will apply them.
**Recommended answer:** Option 1, plus a one-line answer to each of the three follow-ups below.
**Why:** A screenshot is how the other three arrived and it took one round. Our proposed list is the edging-roll and straightener columns merged, which is a reasonable guess but still a guess, and a tooling grid that collects the wrong fields is expensive to unwind once the roll shop has started entering data against it.
**Impact if unanswered:** The register is built and seeded, so nothing is blocked in the database. What is blocked is the fourth tool option on the tab and the screen that renders its grid. Three smaller points travel with this one: whether refurbishing a capstan is the same operation as the In Grinding state the edging rolls already use or something separate; what Machine Name a capstan roll carries, given DB1 and DB2 sit on FL1; and whether two roll set means two rolls in a set or two sets per position, which reads both ways in the same sentence and changes how many rows the inventory has.

---

## Q93

**Register title:** Six readings in the pass-calculator formula document that the page cannot settle
**Area:** Pass schedule generation
**Needs input from:** Tim O. / Process Engineering
**What we need:** Information
**Question:** Six points in your Wire Flattening Mathematical Calculation Formulas document read more than one way. Two of them change what the engine calculates, and one of them decides whether our worked example is a product that can be made at all.
**Background:** Thank you for these - the width formulas are the answer to something we asked for and could not work out ourselves, and we have adopted them as the basis for width, area, footage and edging. Every formula in the document is a picture rather than text, so reading them is an act of interpretation on our side, and we would rather ask than guess. We have built to our best reading in each case and flagged it at the point of use.
**Already agreed:** The formulas are the engineering basis for the generation engine. The two empirical factors are placeholders until sample runs produce a table. The temper calculations are still to come.
**Options:** (1) Send the calculator next week as planned and let us read the cell formulas, which answers four of the six by demonstration. (2) Answer all six in a line each. (3) Answer the two that matter most now and leave the rest for the calculator.
**Recommended answer:** Option 3. The two we would like now are items 3 and 4 below. The other four are exactly the kind of thing a working spreadsheet settles better than an email.
**Why:** Items 3 and 4 are about what you meant, not about what the arithmetic does, and a spreadsheet will show us the cells without explaining the intent behind them. Item 4 in particular changes a result rather than a detail.
**Impact if unanswered:** Nothing in the build stops. What stops is sign-off on the generate-from-specs story, whose expected result we have had to re-derive and cannot confirm until item 4 is settled. The six points are: (1) The Final Cross-Sectional Area Flat Wire formula subtracts an area from a width, which cannot be right dimensionally - we read it as a missing multiplication by the final thickness, which then matches your Round to Flat area formula exactly. Is that the intended reading? (2) In the Round to Flat Cross-Sectional Area formula the legend gives r as the radius of the wire rod, but the formula only produces the right answer when r is the edge radius, which is half the final thickness. On a quarter-inch rod the two readings differ by about a quarter of the area. Please confirm r is the edge radius. (3) The Cumulative True Strain formula adds the length, width and thickness strains together. For any pass that conserves volume those three always add to zero, so as written the total is always nil. We think you mean the sum across passes rather than across the three dimensions - is that right? (4) Your two linear-feet formulas use width times thickness as the cross-section, while your two area formulas use the rounded-edge shape. The difference is about four percent, and on our nominal product it is the difference between a section that can be rolled and one that cannot. Which of the two should the footage calculation use? (5) Are the three empirical factors single numbers or lookup tables, and if tables, what are they looked up by - alloy, stand, gauge range, or something else? We ask because you mentioned generating a table from samples, and a table needs a key. Two smaller points here: the second spread factor is not in the legend, and there are two different thickness-reduction percentages in the document that only agree when the entry is already flat. (6) The Theoretical and Calculated Width Flat to Flat formula has one bracket unclosed as printed. Our reading is the only one that works dimensionally, but please confirm the grouping, and confirm the square root covers the roll radius times the thickness change together.

---

# Part 2 — Decisions to Confirm

---

## Q88

**Register title:** Two identities on a welded coil — the form they take
**Area:** Output and packaging
**Question:** A coil cut across a weld comes from two rods, and you asked for two identities to be kept rather than one. Your planning sheet writes those as the segment name with a letter added — R00002AA and R00001CA. Do you need that exact form, or two identities generated the normal way?
**Background:** The form in the sheet cannot be used as a stored identifier. The letter it adds says which cut of the spool a piece came from, not which coil came from that rod, so every piece in one cut gets the same letter — which is why your own run contains R00004AB with no R00004AA. The same string can also mean two different things, and past twenty-six pieces off one rod it repeats outright. Generated identities avoid all three, and they are checked for uniqueness against every coil in the plant, which a locally built string is not.
**Decision as recorded:** Two identities, generated the same way every other coil identity in the plant is generated — one rooted on each contributing rod. The label and the certificate show both, joined the way your sheet joins identities. **The strings will not match the ones in your sheet**, and that is the visible consequence of this decision.
**Our recommendation:** Confirm as recorded. If the exact strings from the sheet matter for continuity with something we have not seen, tell us — it is the one part of this we would revisit.

---

## Q89

**Register title:** Each rod's share of a welded coil as its own coil record
**Area:** Output and packaging
**Question:** For a coil made from two rods, should each rod's share appear as its own coil record in the wider plant systems, each carrying only its own weight?
**Background:** Roughly nine of the twenty-three spools on your own planning run carry a weld, so this is the normal case rather than an edge one. Recording each rod separately means cost, yield and the coil family tree all see the true split. The alternative credits the whole coil to one rod — on a 900 lb coil that means crediting 900 lb to a rod that supplied 500.
**Decision as recorded:** One record per contributing rod, each carrying its own weight — 500 lb against one rod and 400 lb against the other for a 900 lb coil, so the two add to the coil's weight and nothing is counted twice. Every rod is named on the certificate either way; this decides what the plant's own coil records show.
**Still open:** Two consequences need your sign-off. This changes how a skid counts its two coils, because a coil now has more than one record — the rule stays two coils per skid, counted as physical coils. And it is bound up with **Q87**, the label question deferred on the 24 August call.
**Our recommendation:** Confirm as recorded. It is the only option where cost and yield see the real numbers, and it removes a known mismatch between the coil family tree and the certificate. It costs more to build, which is why we are asking rather than assuming.

---

## Q61

**Register title:** Mid-run pass schedule change — alpha handling
**Area:** Pass schedule and run control
**Question:** If a pass schedule changes mid-coil — for example a die is swapped or the edge configuration changes during a run — does the system create a new child identifier for all material produced after the change, or amend the existing one?
**Background:** The answer determines how material either side of a mid-run change is certified, because a child identifier means the pre-change material closes as its own piece with its own defined footage range. Not all mid-run changes are equivalent, so the decision was taken as five separate cases.
**Decision as recorded:** Five cases, each answered. **(1) Same-specification tooling swap** — a worn die replaced with another of the same size, so the product does not change: single identifier, with a die change event recorded at the footage position. **(2) Size or product configuration change** — a different die size, an edge type switch, or a roll gap moved to target a different width, so material after the change is a different product: **new child identifier** at the footage breakpoint, with the pre-change identifier closing at defined start and end footage. **(3) Edge type change** — a different product definition with different certification and customer requirements: **new child identifier**. **(4) Roll gap adjustment within tolerance under automatic gauge control** — process tuning within specification, not a product change: single identifier, no change. Both mills have automatic gauge control and roll gaps legitimately deviate to hold gauge and width within tolerance. **(5) Roll gap change to a new target gauge or width** — a deliberate operator-driven reset rather than automatic correction: **new child identifier**.
**Our recommendation:** Confirm as recorded. The five cases have held without amendment since May 2026 and the distinction that matters — whether the product changed — is the right one to hang it on.

---

## Q62

**Register title:** Pass schedule override authority and logging — in scope from Step 2 onward
**Area:** Pass schedule and run control
**Question:** Who on the floor is authorised to override a pass schedule setting during a run, and how is the override logged?
**Background:** ⚠ **Only part of this decision applies to the current release, and it is the part below.** Pass schedule authoring and editing — the screens an Operations Manager uses to change a schedule, and the change log behind them — sit outside this release and are owned by a separate track. What is in scope is what happens **on the line** when an override occurs: the alert on the active run monitor, its acknowledgement, and the rule that the machine keeps running on the previous settings until the operator acknowledges. Please read and confirm that half.
**Decision as recorded:** **Floor authority.** Operators have read-only access to the pass schedule at check-in and cannot edit it, except for a one-for-one replacement — a worn die swapped for another of the same size. Any other change requires an Operations Manager. **On the line (in scope for this release):** when an override is saved, a real-time alert is pushed to the active run monitor on the affected line. The operator must explicitly either **acknowledge** — understood, production continues under the new configuration — or **stop the run** for supervisor review. **Passive dismissal is not permitted.** The alert exists because the database record has been updated while the machine is still running on the old settings. **Recording.** The system records the footage counter value at the moment of the change; within-specification tuning is recorded as an event on the existing identifier, while a product specification change closes the existing identifier at that footage and opens a child identifier under the new schedule. **A quality checkpoint is then triggered automatically** to verify the machine has settled to the new targets — the same behaviour as a die change for gauge drift or size change — and the monitor shows "configuration change logged, awaiting checkpoint", which the operator cannot clear without completing the checkpoint.
**Still open:** Nothing in the decision itself. Note only that the editing screens and the change log that record the override are outside this release, so in this release an override has a full on-line response and no in-release place to be authored.
**Our recommendation:** Confirm the on-line half as recorded — the alert, the mandatory acknowledgement, and the machine continuing on previous settings until acknowledged. When confirming, please note that the authoring half will be delivered on the separate pass schedule track.

---

## Q63

**Register title:** Component failure mid-run protocol
**Area:** Pass schedule and run control
**Question:** If a scheduled component fails mid-run, what is the defined protocol?
**Background:** You noted that while some components cannot be bypassed, with experience and ingenuity some may be workable around — so the system needs to represent an unplanned bypass as a distinct event rather than silently inheriting the planned configuration.
**Decision as recorded:** Build an unplanned component bypass as a **distinct event** from a planned bypass. Four parts. **New event type** — when an operator bypasses a component that was planned active, they must explicitly record it as an unplanned bypass, capturing which component, the time, the footage position at failure, a reason code and the operator. **Identifier split at the bypass point** — a child identifier is created there: pre-failure material runs under the original schedule, post-bypass material under the modified effective configuration. **Supervisor acknowledgement** — bypass-and-continue requires supervisor confirmation, not operator-only. **Disposition for pre-bypass material** — if the failure may have affected quality before the component was bypassed, a disposition step of accept, inspect or reject is required for the footage produced during the failure window, in parallel with the partial-run disposition flow.
**Our recommendation:** Confirm as recorded.

---

## Q64

**Register title:** Pass schedule ID on coil completion and cert record
**Area:** Certification and traceability
**Question:** Should the output coil record capture the pass schedule identifier and configuration data?
**Background:** The distinction drawn was between what the customer sees on a label and what is retained for internal quality and engineering review.
**Decision as recorded:** **Not on the label.** Pass schedule data — identifier, version, die sizes, roll gap values — should not appear on the coil label. **Yes for traceability.** The pass schedule identifier and relevant configuration data are logged against the coil record, captured **at coil creation time** so they can be retrieved for quality audits and engineering review even if the schedule is subsequently edited.
**Our recommendation:** Confirm as recorded. The capture-at-creation point is the load-bearing part — a later edit to the schedule must not change what a completed coil says it was made under.

---

## Q65

**Register title:** "Require SPC on resume" override authority
**Area:** Quality and tolerances
**Question:** What role is permitted to turn off the "require a quality checkpoint on resume" setting?
**Background:** The concern is a die change committing production footage before anyone has verified the correct die is fitted and properly seated.
**Decision as recorded:** For **gauge drift and size change** die replacements, thread mode — slow running without full production — is allowed until the quality checkpoint is complete, so the die can be verified before production footage is committed. After confirming a die change the system routes to the **checkpoint screen** rather than back to the run monitor, and the run stays blocked or paused until the checkpoint passes. The "require a checkpoint on resume" setting is **pre-checked on** for gauge drift and size change reasons and the routing is enforced. Override authority is restricted to an **Operations Manager or Quality role minimum**, with a mandatory reason code and an audit record.
**Our recommendation:** Confirm as recorded.

---

## Q66

**Register title:** Line speed range per alloy and gauge
**Area:** Reference data
**Question:** What is the minimum and maximum line speed in feet per minute for each alloy and gauge combination on FL1 and FL2?
**Background:** Speed ranges bound what a pass schedule may specify and what the scheduling algorithm can assume. This is one of three questions where the honest answer was that the number does not exist yet.
**Decision as recorded:** Line speed ranges are **unknown at this time and will be determined by trial**. Once established through production runs the data can be added to a configuration table by United Aluminum. This is not a blocking issue for initial development — the scheduling algorithm is designed to take these values as table-driven inputs.
**Still open:** The figures themselves, after the trial. Nothing to confirm now beyond the approach.
**Our recommendation:** Confirm as recorded. Note that the table-driven treatment agreed here is the pattern we are recommending for standard times and metallic yield as well, both still open — so confirming it here effectively confirms the approach for those.

---

## Q67

**Register title:** FL1 and FL2 simultaneous independent operation
**Area:** Planning and scheduling
**Question:** Can FL1 and FL2 run completely different orders at the same time in non-hybrid standalone mode?
**Background:** This determines whether the two lines are independent scheduling units, and it constrains when the hybrid route can be booked at all.
**Decision as recorded:** **Yes.** FL1 and FL2 can run independent orders simultaneously in non-hybrid mode. They are designated and tracked as **separate machines** in scheduling, in the same way an order might run on one existing mill and then another. Each has its own machine booking, separate identifiers and separate check-in events. Throughput between the two runs at roughly **three to one**, FL1 being significantly faster, which creates open capacity on FL1 more often than on FL2 depending on order mix. **The hybrid route cannot run if there are scheduled orders on FL1 or FL2.**
**Still open:** How the hybrid route is represented as a booking unit — a single booking or simultaneous entries on both lines — which is asked as an open question on the other sheet.
**Our recommendation:** Confirm as recorded. The three-to-one throughput ratio in particular is worth re-confirming, because capacity planning for the two lines rests on it.

---

## Q68

**Register title:** Pre-check-in coil status — INFLAT or STAGED
**Area:** Rod staging and pre-check-in
**Question:** Does pre-check-in commit the shared coil record to `INFLAT`, or does the status stay `STAGED` until check-in? And what reverses it?
**Background:** Two of our source documents disagreed, and the answer decides how much has to be undone when a staged rod is removed before it is ever run.
**Decision as recorded:** **`INFLAT` is set only when the rod is actually checked in at FL1.** Pre-check-in does **not** commit the status, and there is **no intermediate status** for a rod that has been welded but not yet checked in — you confirmed one is not needed. Rod status `STAGED` is the real staging status for FL1 rather than a leftover value. ⚠ **Amended August 18, 2026, following your direction that there will be no changes to the existing scheduling system's database.** The timing you confirmed is unchanged — the status still changes at check-in and not before — but it is now recorded on the **flat wire module's own rod record**, and the existing shared coil record is **not written at all**. Nothing about the operator's experience changes.
**Still open:** ⚠ **A real residual, and not a small one.** The decision covers the **status** only. It does not cover the rest of the writes pre-check-in was specified to perform — the queue insert, the requirements summary and the work-in-progress order insert. If those stay at staging, the amount of work that has to be undone when a staged rod is removed is unchanged and only the status moved. If they move to check-in, removing a staged rod becomes a clean local delete. This is with you and IT.
**Our recommendation:** Confirm the status decision as recorded, and please settle the residual in the same pass — it is the part that determines how much compensating work a removal has to do. Our position is that these writes should move to **check-in** alongside the status, so that pre-check-in has no effect outside the flat wire system at all. ⚠ **The August 18 direction has already taken the status half of that position further than we proposed** — the status now never leaves the flat wire system at any point. **One consequence needs your view, and it is the reason this question is still worth a minute of your time:** with nothing written to the shared coil record, **the existing scheduling and reporting screens no longer show that a rod is on a flattening line.** The work-in-progress station, the requirements-summary entry and the routing start date all still say the rod has started, so most consumers are covered — but any report that filters on the **coil status field itself** will show flat wire material as untouched. Please tell us whether any report or screen you rely on does that.

---

## Q69

**Register title:** Does pre-check-out require supervisor approval?
**Area:** Rod staging and pre-check-in
**Question:** A staged rod being removed was never checked in — no schedule acknowledged, no settings sent, no footage produced. Is operator-only removal right, or is supervisor approval needed?
**Background:** The answer turned out to depend on a physical fact rather than a procedural one.
**Decision as recorded:** **It depends on whether the rod has been welded.** A rod that is **not welded** needs no approval — operator-only, with a reason recorded, and the rod returns to inventory. A rod that **is welded** requires a **supervisor override** with a documented reason, and **this is a rejection rather than a return**: the rod goes to **hold**. The reasoning is physical — removing a welded rod means cutting or splitting the material. This also answers the separate question of whether a welded staged rod may be released at all: it can, by a supervisor, and the control is present on welded rows behind a supervisor gate and routed to rejection.
**Still open:** Nothing in the decision. Two consequences on our side: the removal record has no supervisor fields today and needs them, and pre-check-out has no requirement identifier of its own — both are ours to fix.
**Our recommendation:** Confirm as recorded.

---

## Q70

**Register title:** Can a rod carry more than one production order?
**Area:** Rod staging and pre-check-in
**Question:** Can a rod be pre-checked-in against a future order, or only the current one?
**Background:** The question was the wrong shape as originally asked, and was reframed on answering.
**Decision as recorded:** **A single rod may legitimately carry more than one production order.** The case was confirmed: finishing order one on a 7,000 lb rod and starting order two on the remainder, both orders being the same alloy. The intent is for this to be handled **in planning**, the upstream operation, in multiples of the roughly 900 lb outgoing coil.
**Still open:** Nothing here. The sequencing rule this opened was decided separately on 6 August 2026.
**Our recommendation:** Confirm as recorded. Note what it overturned on our side: staging previously validated that a rod belonged to **the** current order, singular, and refused anything else — which would have stopped the line mid-bundle on the same-rod successor. Membership in an ordered set replaces that.

---

## Q71

**Register title:** Can rod bundles be stacked on one VPS position?
**Area:** Rod staging and pre-check-in
**Question:** Can multiple rod bundles be stacked on a single payoff position?
**Background:** Every artifact assumed one bundle per bay, but nothing stated whether that was the equipment's limit or a modelling assumption. Eye-to-sky is the geometry in which stacking is standard wire-industry practice, so it was worth asking rather than assuming.
**Decision as recorded:** **No.** Rods cannot be stacked on a single payoff. **Only two rods total may be checked in at a time — one per payoff** — the same rule as the mills. The one-bundle-per-bay assumption already made everywhere is correct. **Nothing is to be built for stacking:** no stack position, no maximum stack depth, no re-based weight thresholds. The rule that a weld is always a handover between two bays stands, and "a bay cannot be welded to itself" remains the correct invariant.
**Still open:** Nothing in the decision. The received bundle **gross weight** did not close with it — our documents state it two incompatible ways and it calibrates the payoff weight indicator independently of stacking. It is asked as an open question on the other sheet.
**Our recommendation:** Confirm as recorded, and please answer the bundle gross weight question on the open sheet at the same time — the two were asked together and only one closed.

---

## Q72

**Register title:** May a welded staged rod be released, and by whom?
**Area:** Rod staging and pre-check-in
**Question:** May a rod that has been marked as welded be released from its bay, and if so by whom?
**Background:** Marking a rod welded sets a flag on a staged record rather than changing its status, which meant every control acting on a "staged" bay also matched a welded one. But that rod is physically welded to the rod in the mill, so "the bay is released and the rod returns to inventory" is not something that can happen.
**Decision as recorded:** **Yes — by a supervisor, and it is a rejection.** Releasing a welded rod requires a **supervisor override** with a documented reason, because removal means cutting or splitting the material, and the rod goes to **hold**. **No separate status is needed** for a rod that is welded but not yet checked in. The control is therefore present on welded rows, gated on supervisor authorisation, and routed to rejection rather than to a return to inventory.
**Still open:** ⚠ **Reversing a weld in place is still unspecified.** The original requirement was for supervisor reversal of a welded rod, which is broader than removing it from the bay. Clearing the welded flag on a rod that **stays staged** — a mis-scan, the wrong rod welded, a weld that failed after being marked — has no specification and no audit target. Please tell us whether that case is real and what should happen.
**Our recommendation:** Confirm the release decision as recorded, and please answer the in-place reversal residual — it is a plausible operator error with no defined path today.

---

## Q73

**Register title:** Multi-order rod — the consumption sequencing rule
**Area:** Rod staging and pre-check-in
**Question:** Given that a rod may carry more than one order, in what sequence may those rods be consumed, and is the rule enforced?
**Background:** The case put was three coils, one carrying two orders, and an operator free to pick any of them. Starting with the multi-order coil leaves order two's tail with nowhere to run and the weld cannot be made. ⚠ **The rule was stated three ways on the call before it settled** — partials were placed first at one point and then explicitly corrected — so the version below is the corrected one, and reading only the first half of that discussion gives the opposite answer.
**Decision as recorded:** **A three-tier rule, enforced as a validation. (1) Full coils first. (2) Partials next** — a partial is a back-to-stock. **(3) Coils carrying multiple orders last, always** — "there can be no other option for it because it has a second order." Full coils of the **same order** in the middle may be taken in any order. Operators work a **pick list in planned order**, the same pattern as the mills, and **may not jump a multi-order coil to the head of the line**. The validation applies at **both pre-check-in and check-in** — if the operator does not pre-check-in, it applies at check-in. It applies to **stock orders** as well. The worked example given: an order of 44,000 lb including upper tolerance, incoming rod at roughly 5,500 lb, FL1 output in multiples of roughly 1,800 lb and FL2 output in multiples of 800 to 900 lb, so planning lays out around nine rods — eight full and one partial. With welding, the eight full rods run first, then the partial, then any multi-order rod.
**Still open:** ⚠ **One branch is genuinely unresolved and this is the only record of it.** Where **no welding** is involved, the transcript supports two readings and they differ by one validation branch. The rule was scoped to welding at one point — if welding is not involved the sequence is harmless in any order — but the confirming sentence carried the qualifier back in, and it was argued on the call that the multi-order case is different regardless, because in a continuation one order must complete before the second starts. **The question in one sentence: when no weld is involved, may an operator run a rod that carries two orders before the other rods of the first order?** Please do not read the no-welding case as an unqualified "the sequence is free". Separately, whether a rod may be pre-checked-in against the **later** order on it while the earlier one is still running was never put to you explicitly.
**Our recommendation:** Confirm the three-tier rule as recorded, and please answer the no-welding branch — it is the one part of this decision with no other record anywhere, and it decides whether we build one validation branch or two.

---

## Q74

**Register title:** Mid-run rod checkout authorisation level
**Area:** Rod checkout and disposition
**Question:** Is a mid-run rod checkout an operator-level action, or does it require supervisor approval?
**Background:** A mid-run checkout means footage has been produced and the rod is being removed before exhaustion, so there is material to account for.
**Decision as recorded:** A mid-run checkout — footage greater than zero, rod removed before exhaustion — **requires supervisor approval**. Operator-only authority is not sufficient. This mirrors the rejection disposition flow.
**Our recommendation:** Confirm as recorded. One note for the record: this decision was miscited as still open for three months in a document that has since been removed, so if you meet a reference suggesting mid-run checkout approval is undecided, it is out of date.

---

## Q75

**Register title:** Partial-run material disposition authority
**Area:** Rod checkout and disposition
**Question:** Does the operator have sole authority to accept partial footage as a spool identifier?
**Background:** The concern is material of uncertain quality entering the plannable pool on an operator's judgement alone, and a supervisor who may not be on the floor.
**Decision as recorded:** **A supervisor must approve a mid-run checkout**, and the approval is notification-driven and can be given remotely. The confirmed flow: the operator confirms the mid-run checkout with footage greater than zero; the system creates a **pending disposition** record; the material is **locked** — no identifier created and not plannable; a notification is pushed to the supervisor role; the supervisor reviews from any connected terminal, seeing the gauge trace for the partial run, the footage produced, the reason for the stop, and the operator and timestamp; and then decides — **accept**, creating the identifier and entering the spool queue; **hold**, creating the identifier with hold status for quality to release; or **reject**, triggering the rejection flow to scrap. The disposition record captures the supervisor, the decision, a reason code and a timestamp.
**Our recommendation:** Confirm as recorded. The remote-approval element is the part worth re-confirming operationally — the flow depends on a supervisor being reachable, and the material stays locked until they respond.

---

## Q76

**Register title:** FL2 spool check-in identifier — the spool alpha
**Area:** Spool lifecycle
**Question:** When flat wire arrives at FL2 on a spool loaded onto the payoff, what identifier does the operator use to check it in — the spool identifier, a separate physical spool number, or a bundle identifier? And how does that link to the outgoing coil record?
**Background:** The physical spool carries a number on a plate, and the material carries its own identifier; the two are different things and only one can be what the transaction is keyed on.
**Decision as recorded:** **The identifier is the spool identifier**, not the physical spool number and not a bundle identifier. The physical spool number remains the plate on the equipment and may be displayed for confirmation, but the transaction is not keyed on it. The link to the outgoing coil follows from it and is already implemented: the check-in records the spool being checked in, and the coil genealogy records the source spool for each output footage range. The coil-to-spool link sits on the **footage-range detail rather than the coil header**, because a header value becomes wrong the moment one spool runs out mid-coil and a second finishes it — the relationship is per footage range, not per coil. A rod-fed coil has no source spool at all, which is why that link is optional.
**Our recommendation:** Confirm as recorded. Worth noting operationally: because the FL2 queue now presents the operator a list to pick from, the identifier is a **selection rather than a typed entry**, which removes the mis-keying risk that would otherwise make a long identifier worse than a short spool number at a machine-side screen.

---

## Q77

**Register title:** Maximum finished coil weight
**Area:** Output and packaging
**Question:** The finished-coil take-up has a stated capacity. Is the customer-facing maximum coil weight the same as the equipment capacity, or set lower for ease of handling at the customer?
**Background:** Originally asked against a 1,000 lb capacity figure, which was revised upward on review.
**Decision as recorded:** The estimated maximum capacity is **1,100 lb** — the finished-coil take-up equipment limit, revised from the 1,000 lb figure stated at the April meeting. **The customer defines their own coil weight limit below United Aluminum's maximum**, captured in the orders and quotes application. Orders exceeding a single rod or spool weight are **split into multiple stops, each generating its own identifier**, and the last stop may contain several identifiers. Weight distribution is tracked through footage and revolutions.
**Our recommendation:** Confirm as recorded, and please confirm 1,100 lb is still the right figure — it was an estimate revised once already, and it is the ceiling every coil-split calculation works to.

---

## Q78

**Register title:** Spool alpha continuity through anneal or re-pass
**Area:** Spool lifecycle
**Question:** Does an anneal step generate a new child identifier, or does the existing spool identifier carry forward?
**Background:** An intermediate anneal is a process step rather than a product change, but it interrupts the physical flow, so the identifier treatment had to be stated.
**Decision as recorded:** **Anneal:** the existing identifier is updated and **carries forward** to maintain traceability — no new child identifier is generated for an intermediate anneal, and the anneal step is recorded against the existing identifier. **Re-pass through FL1:** United Aluminum does not have the capability to run a spool back through FL1, so this scenario **is not applicable**.
**Our recommendation:** Confirm as recorded. The second half matters beyond this question: a metallic yield figure is currently being requested for a flat-wire re-pass route, and this decision says that route does not exist — so please confirm the re-pass really is out, and we will drop the request.

---

## Q79

**Register title:** Short-close path — closing a spool below target weight
**Area:** Spool lifecycle
**Question:** The stop-confirmation prompt is armed only at or above target weight, so a spool the operator wants to close early — order satisfied, rod exhausted, quality problem, end of campaign — gets no prompt. Is a short close a real case, and if so what happens?
**Background:** Direction on this was explicit that the customer should be offered the material before a remake is planned.
**Decision as recorded:** A short close **is a real case** and is handled as an **unplanned stop**, mirroring the existing mill stop procedure, with an unplanned-stop reason code. It is **graded by weight against the customer minimum and maximum**, not by footage and not against a fixed target — for example 900 lb maximum, 800 lb minimum. **Inside the range, continue** — if the short weight still yields the finished coils the order requires, no escalation. **Outside the range, flagged** — either a supervisor override plus a production hold, or the piece is **offered to the customer under concession** before a remake is planned. The direction was explicit: **offer first, remake last**. **The spool is run off in either case** — FL2 has no spool stripper, so the spool must be emptied and returned to FL1 regardless of the disposition of the material on it, which constrains the reject-and-remake path: "scrap it" is never "stop and remove it". **On a coil break mid-run**, the stop is removed and a new stop starts from zero — weight does **not** resume from the break point; leftover incoming material is welded to the next coil on FL1, and on FL2 it is either run to a finished stop and offered to the customer, or scrapped.
**Still open:** ⚠ **The coil-break clause is a change to the run and stop model rather than a screen rule**, and we have not yet validated it against how footage accumulates across a run. Please treat that clause as provisional until we confirm it. Separately, the mill stop procedure this decision mirrors is **not a document we hold** — please send it rather than have us work from a paraphrase.
**Our recommendation:** Confirm the short-close handling as recorded. Flag the coil-break clause as provisional pending our check, and please supply the stop procedure document.

---

## Q80

**Register title:** Oscillation layer interleave material
**Area:** Output and packaging
**Question:** Is a separator required between winding layers in the coreless oscillated coil?
**Decision as recorded:** **No separator is required or available.** United Aluminum does not currently have the capability to provide any separator between oscillate layers. **No packaging specification field for interleave material is needed.**
**Background:** If a separator were required it would need a packaging specification field and a consumable to manage, so a clean "no" removes both.
**Our recommendation:** Confirm as recorded.

---

## Q81

**Register title:** Camber and flatness limits
**Area:** Quality and tolerances
**Question:** Is there a maximum camber specification for flat wire?
**Background:** The answer set the pattern for customer-conditional dimensional characteristics generally.
**Decision as recorded:** The camber measurement should be **available in the quality checkpoint** where the customer has camber specifications. Implementation is **conditional on customer requirement** — the field is available but not mandatory for all orders. The inline measurement method is to be confirmed per order specification.
**Our recommendation:** Confirm as recorded. We are recommending the same treatment for twist and torsion, which is still open — so confirming this effectively confirms that pattern too.

---

## Q82

**Register title:** Edge burr height limit and measurement
**Area:** Quality and tolerances
**Question:** For flat-edge products, what is the maximum allowable edge burr height?
**Decision as recorded:** **Not currently measured. No system implementation required at this time.**
**Background:** Recorded as a closed item so that the absence of any burr capture is a decision rather than an oversight.
**Our recommendation:** Confirm as recorded — specifically that it is still not measured, since flat-edge product volume may change that.

---

## Q83

**Register title:** Die life tracking — bands in scope; per-tool mechanism is not
**Area:** Tooling
**Question:** Should the system track footage run per die and generate a replacement alert?
**Background:** ⚠ **The decision below assumes per-tool tracking, which this release does not have.** Die inventory and lifecycle, including the die register itself, moved out of this release. What this release does is read die life at **die-size** granularity — feet run since the last grind, against a scheduled allowance, held per die size — and warn at the agreed thresholds. **The consequence is worth being explicit about: die life is per size, so two dies of the same diameter share one counter.** **The 60 and 85 per cent warning bands are in this release and are the half that applies.** Please read the decision below as the eventual target state rather than as this release's behaviour.
**Decision as recorded:** System-level die life tracking is required. Footage must be logged against die identity, each die having its own unique identifier similar to mill rolls, so that time in use and total footage through it can be tracked. The replacement threshold estimate is **deferred** — an accurate figure will not be available until failure data is collected from production. The confirmed design: cumulative footage per die identity, incremented from the machine footage counter on each completed or partial run; a **configurable replacement threshold per die type**, set by Maintenance per die profile; a **passive alert** — a banner on the die check-in screen and a Maintenance row when remaining life falls below 10 per cent, with **no hard block**, so Maintenance can acknowledge and extend with a reason code; on a mid-run swap, footage accumulation closes on the outgoing die and a new counter starts on the incoming one; after physical replacement, Maintenance resets the counter through a die management screen, logging who reset it and when; and footage is pulled from the **existing machine footage counter** already used for identifier tracking, so no new sensor is needed.
**Still open:** The replacement threshold figures, deferred until failure data exists — so no life allowance is seeded and the die-size allowance is currently empty. Per-tool tracking, the die register and the die management screen are all outside this release.
**Our recommendation:** Confirm the **60 and 85 per cent bands** and the passive, no-hard-block alerting, which is what this release implements. Please acknowledge separately that per-tool tracking is a later delivery, and note the per-size consequence above — if two dies of one diameter sharing a counter is unacceptable operationally, we should know now rather than at the die management delivery.

---

## Q84

**Register title:** ITInhibit is line-scoped
**Area:** Machine interface
**Question:** The interlock signal that blocks a line from running was the one signal in every source written without a line prefix. Is the interlock plant-level or per line?
**Background:** Under the plant-level reading, one line's unmet prerequisite — no rod checked in, no active order identifier, missing footage data — would have blocked all three lines. That would have been discovered the first time FL1 sat idle while FL2 was scheduled.
**Decision as recorded:** **The interlock is one signal per line** — one for FL1 and one for FL2. A line blocked from running blocks **only itself**. The plant-level reading is excluded.
**Still open:** **The hybrid line only.** Because FL3 spans both mills, whether it carries its own interlock or asserts both mills' interlocks together follows from the hybrid addressing question, which is open on the other sheet. This is the one line where a blocked line legitimately implicates a second, because on the hybrid route the two are one physical thread of material.
**Our recommendation:** Confirm as recorded. This decision also confirmed something broader on our side — that the first segment of every machine address is always the line, with no plant-level signal. That was the only counterexample to the rule, so confirming it strengthens every address we derived from the convention rather than observed, which is the whole economy behind confirming a convention instead of sixty individual strings.

---

## Q85

**Register title:** FM2 has three stands, S1 = 8 inch
**Area:** Equipment configuration
**Question:** How many stands does the finishing mill have, and what are their roller sizes? *(Raised by you as a correction rather than by us as a question.)*
**Background:** ⚠ **This corrected a misreading that had propagated through roughly fifty of our documents for ten weeks.** The May 2026 equipment note was recorded as "three 6-inch stands", and that was read as a separate 8-inch roller **upstream of** three 6-inch stands — four components. The 8-inch roller **is** stand one, and the fourth stand does not exist.
**Decision as recorded:** The finishing mill has **three stands**. **Stand 1 carries the 8-inch roller; stands 2 and 3 carry 6-inch rollers.** Edgers remain at **stands 2 and 3 only**, and **stand 3 remains the final, non-bypassable gauge-control stand**. The hybrid route drives the same finishing mill. FL1's mill is unaffected at 12 inches. Three pieces of evidence fixed the mapping: your published machine map has exactly three finishing-mill stations; every seeded pass schedule has exactly three finishing-mill component rows with a descending gap chain; and the fourth stand never had an address or a seed row at all. **No gap or gauge value was recomputed** — the three-row chains were always valid.
**Still open:** Nothing in the decision. Two consequences: stand naming in the machine interface is asked as an open question on the other sheet, and roller radius is now a real input to the pass schedule calculations, so the maximum roll force and mill stiffness need to be supplied **per stand** rather than per mill.
**Our recommendation:** Confirm as recorded, and please supply the per-stand force and stiffness figures — the larger stand one admits roughly a third more draft than a 6-inch stand and develops around 16 per cent more separating force at equal draft, so a single per-mill figure is not sufficient.

---
