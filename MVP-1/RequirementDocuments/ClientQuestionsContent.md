# Flat Wire Mill — Client Questions Workbook Content

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 12, 2026
**Document Type:** Source content for a generated client deliverable — not a specification
**Status:** Active

---

## What this file is

**The client-facing prose for the questions workbook, and the only place it is authored.** The workbook
`MVP-1/SRS/FlatWire_ClientQuestions.xlsx` is generated from this file plus the two registers by
`MVP-1/ProjectPlan/Tools/build_questions_xlsx.py`. **Edit this file and re-run the generator; never edit the
`.xlsx`.**

**Division of labour with the registers.** Structural fields — question number, priority, scope, owner, decided
date — are read from `Analysis/FlatWireOpenQuestions.md` and `Analysis/FlatWireDecidedQuestions.md` at build time
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

---

# Part 2 — Decisions to Confirm

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
**Decision as recorded:** **`INFLAT` is set only when the rod is actually checked in at FL1.** Pre-check-in does **not** commit the shared coil status, and there is **no intermediate status** for a rod that has been welded but not yet checked in — you confirmed one is not needed. Rod status `STAGED` is the real staging status for FL1 rather than a leftover value.
**Still open:** ⚠ **A real residual, and not a small one.** The decision covers the **status** only. It does not cover the rest of the writes pre-check-in was specified to perform — the queue insert, the requirements summary and the work-in-progress order insert. If those stay at staging, the amount of work that has to be undone when a staged rod is removed is unchanged and only the status moved. If they move to check-in, removing a staged rod becomes a clean local delete. This is with you and IT.
**Our recommendation:** Confirm the status decision as recorded, and please settle the residual in the same pass — it is the part that determines how much compensating work a removal has to do. Our position is that these writes should move to **check-in** alongside the status, so that pre-check-in has no effect outside the flat wire system at all.

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
