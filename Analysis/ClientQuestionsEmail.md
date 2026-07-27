# Flat Wire Mill — Client Questions Email

---

**To:** Tim O'Brien, Shannon R., Bob S., Jeff G., Dan F., Mick, Stephen, Margo, Darlene, Naj, Chuck, Sales (Laura G. / Ron F.)
**From:** Jaspreet / Development Team
**Date:** April 27, 2026
**Subject:** Flat Wire Mill — Open Questions Requiring Your Input (57 Items)

---

Hi All,

As we move into active development for the Flat Wire Mill implementation (trials target: July 1, production target: August 1), we have compiled all open questions from the analysis phase into a single list. We need decisions on these before we can build the dependent modules.

Questions are grouped by **priority** and then by **topic**. Please review the items under your name and respond by the dates noted.

> **Critical** — Must be resolved before development begins on the dependent module.
> **High** — Must be resolved before July 1 trials.
> **Medium** — Must be resolved before August 1 production.
> **Low** — Can be resolved post go-live.

We have called out the **11 Critical blockers** at the top so those can be actioned first.

---

## PART 1 — CRITICAL BLOCKERS (11 Questions)

*These questions must be answered before their dependent modules can be built. Development cannot proceed on these areas until decisions are received.*

---

**[Q1] Pass Schedule UI — Tim O.**
The system requires a Pass Schedule database (confirmed — not an auto-generator). Is there a UI screen for Operations/Maintenance to create and edit pass schedule records, or will this be managed directly in a database table? A dedicated UI is expected given the ongoing manual maintenance requirement.

---

**[Q10] FL3 Scheduling Representation — Tim O. / Stephen**
FL3 is the hybrid continuous mode (FL1 feeding directly into FL2). How should it be represented in the scheduling system — as a single machine booking entry for "FL3," or as simultaneous bookings on both FL1 and FL2? Does scheduling a job on FL3 automatically block both FL1 and FL2 capacity? This directly affects capacity planning logic.

---

**[Q14] Traveler Screen Fields Per Station — Tim O.**
Generic labels for the traveler screens (e.g., "Incoming Bundle Information") are agreed. However, the full field list required at each station — FL1 rod check-in, FL2 spool check-in, and FL3 hybrid check-in — has not been documented. Who is responsible for defining these, and what is the delivery date? This is the basis of the shopfloor screen build.

---

**[Q15] FL2 Spool Check-in Identifier — Tim O. / Jaspreet**
When flat wire arrives at FL2 loaded onto the TPO on a spool, what identifier does the operator use to check it in — the SP-series alpha, a separate spool number, or a bundle ID? How does that identifier link to the outgoing coreless coil record created at TKUP-2?

---

**[Q18] Inventory Type for Rods in Coils Table — Tim O. / Jeff G.**
The SRS notes that the Inventory Type for rod entries in the coils table is TBD. Who defines this, and how does it affect planning allocation, cost tracking, and yield reporting? This blocks both the rod receiving module and the planning system changes.

---

**[Q27] Mid-Run Pass Schedule Change — Alpha Handling — ~~Tim O. / Jaspreet~~ ✅ DECIDED May 4, 2026**
~~If a pass schedule changes mid-coil (for example, a die is swapped or the edge configuration changes during a run), does the system create a new child alpha for all material produced after the change, or does it amend the existing alpha?~~

**Decision:** Five cases defined — not all mid-run changes are equal:
- **Case 1 (Same-spec tooling swap):** Single alpha + die change event at footage position.
- **Case 2 (Size change / product config change):** New child alpha at footage breakpoint.
- **Case 3 (Edge type change):** New child alpha.
- **Case 4 (Roll gap within tolerance — AGC):** Single alpha, no change. Both mills have automatic gauge control; AGC-driven roll gap deviations do not generate a new alpha.
- **Case 5 (Roll gap to new target width/gauge):** New child alpha.

---

**[Q35] Expected Metallic Yield Per Route — Tim O. / Jeff G.**
What is the target metallic yield (%) for each production route:
- (a) Rod → Flat Wire direct
- (b) Rod → Round Wire → Flat Wire
- (c) Flat Wire → Flat Wire re-pass

Without these figures, the planning algorithm cannot correctly calculate the required rod input weight per order.

---

**[Q36] Footage-to-Weight Conversion Factor — Tim O. / Bob S.**
How is the footage-to-weight conversion calculated per alloy and cross-section? Is there a standard formula (density × cross-sectional area × footage), or is it measured empirically and stored per product? This factor is the foundation of all output weight calculation — weight on flat wire is derived from length, not from a scale reading.

---

**[Q45] FL1 and FL2 Simultaneous Independent Operation — ~~Tim O. / Stephen~~ ✅ DECIDED May 4, 2026**
~~Can FL1 and FL2 run completely different orders at the same time in non-hybrid (standalone) mode?~~

**Decision:** Yes — FL1 and FL2 can run independent orders simultaneously. They are designated as separate machines in scheduling (analogous to ZR24 and U30) with separate machine bookings, separate alphas, and separate check-in events. FL1/FL2 throughput ratio is approximately 3:1. FL3 (hybrid) cannot run if there are scheduled orders on FL1 or FL2.

---

**[Q51] Pass Schedule Selection Mechanism at Check-in — Tim O. / Jaspreet**
The check-in screens (Dashboard 2 — FL1 Rod Check-in, Dashboard 5 — FL2 Spool Check-in) show the pass schedule pre-populated, but the mechanism that determines which schedule is displayed has not been defined. Three options:
- Pass schedule ID is stored on the order record at planning time
- Operator selects from a dropdown at check-in
- System looks it up from product attributes (alloy + gauge + width + edge type)

If no pass schedule matches the order's attributes, how is the operator or planner notified before the line starts? Without a clear answer here, operators may silently acknowledge the wrong schedule and produce scrap.

---

**[Q52] FL3 Hybrid Pass Schedule — One or Two Schedules? — Tim O. / Jaspreet**
In hybrid mode (FL3), material flows continuously from FL1's FM1 into FL2's FM2 with no spool intermediate and no mid-run stop. Does the hybrid run use:
- **Option A:** A single pass schedule record that covers all FL1 + FL2 components together, or
- **Option B:** Two separate pass schedules (one for FL1 components, one for FL2 components) that are explicitly linked?

If Option B: how does the system prevent FL1 and FL2 from running under mismatched configurations during a hybrid run? This decision determines the pass schedule data model and drives the FL2 check-in validation logic for hybrid jobs.

---

## PART 2 — HIGH PRIORITY (29 Questions)

*Must be resolved before July 1 trials.*

---

### 2A. Pass Schedule & Run Control

**[Q28] Pass Schedule Override Authority — ~~Tim O. / Shannon R.~~ ✅ DECIDED May 4, 2026**
~~Who on the floor is authorized to override a pass schedule setting during a run?~~

**Decision:** Four-step mid-run configuration change flow confirmed. Floor operators are read-only at check-in and cannot edit the pass schedule unless it is a one-for-one same-size die swap. Changes require an Operations Manager in Dashboard 9. Every change is logged (parameter, old → new value, user ID, timestamp, reason code). Active Run Monitor displays a real-time notification requiring explicit operator acknowledgment (Acknowledge or Stop Run). SPC checkpoint is automatically triggered post-change.

**[Q29] Component Failure Mid-Run Protocol — ~~Tim O. / Plant~~ ✅ DECIDED May 4, 2026**
~~If a scheduled component fails mid-run, what is the defined protocol?~~

**Decision:** Build an "unplanned component bypass" event as a distinct transaction from a planned bypass. Event captures: which component, time, footage position at failure, reason code, operator ID. Alpha split at the bypass point. Bypass-and-continue requires supervisor-level confirmation. Disposition step required for pre-bypass material (accept / inspect / reject).

**[Q30] Roll Gap Validation Before Run Start — Tim O. / Jaspreet** *(In Progress)*
How are roll gap settings confirmed before a run begins — by manual operator measurement, by encoder feedback logged by the PLC, or by a system confirmation step that must be completed before the check-in acknowledgment is allowed?

**Status (May 4, 2026):** Tim needs to confirm with engineering. Three options remain open (manual measurement, PLC encoder readback, or current no-readback approach). Decision pending.

**[Q54] Pass Schedule ID on Coil Completion and Cert Record — ~~Tim O. / Mick~~ ✅ DECIDED May 4, 2026**
~~Should the output coil record capture the pass schedule ID and configuration data?~~

**Decision:** Pass schedule data should **not** appear on the customer label. It **should** be logged against the coil record at coil creation time for technical traceability, so auditors and engineering can query it even if the pass schedule is subsequently edited.

---

### 2B. Scheduling & Capacity

**[Q20] Anneal Rules for Rod/Wire — Timeline — Dan F.**
Anneal rules for rod and wire are required by the scheduling algorithm. Dan F. owns this area. No delivery timeline has been specified — when will these rules be available for the scheduler to consume? Missing anneal rules means the scheduler cannot correctly sequence jobs that include an intermediate anneal step.

**[Q44] Line Speed Range Per Alloy and Gauge — ~~Tim O. / Bob S.~~ ✅ DECIDED May 4, 2026**
~~What is the minimum and maximum line speed (FPM) for each alloy and gauge combination on FL1 and FL2?~~

**Decision:** Unknown at this time — will be determined by trial production. Once determined, data will be added to a configuration table by UA. Scheduling algorithm must be designed to accept table-driven line speed inputs.

**[Q46] Shared Anneal Furnace Capacity for Flat Wire — Dan F. / Tim O.**
Are furnace slots for flat wire annealing shared with the existing coil anneal schedule, or is there dedicated flat wire furnace capacity? If shared, the scheduling algorithm must account for furnace contention when planning flat wire jobs that require an intermediate anneal between FL1 and FL2.

---

### 2C. Rod Receiving & Storage

**[Q17] Rod Receiving Label Format — Tim O. / Darlene**
The label format for received rod material is listed as TBD. What fields are required on the rod receiving label, and does the format need to support tolling labels for customer-supplied rod material?

**[Q20 — see above]**

---

### 2D. Rod Checkout

**[Q47] Partial-Rod Re-Check-in and Traceability Carry-Forward — Tim O. / Jaspreet** *(In Progress)*
If a rod is removed from the payoff mid-run and returned to storage, can it be re-checked-in on a later run? Must the system carry forward footage run and remaining weight?

**Status (May 4, 2026):** Multiple partial spool alphas per rod confirmed needed. Material that has been drawn/rolled will be scrapped (remains in mill); the undrawn rod is what returns to WH. Payoff scale for weighing partial returns: Tim has asked Scott, Bob, and Shannon to advise. Full carry-forward design deferred — Tim will confirm.

**[Q48] Mid-Run Rod Checkout Authorisation Level — ~~Tim O. / Shannon R.~~ ✅ DECIDED May 4, 2026**
~~Is a mid-run rod checkout an operator-level action or does it require supervisor approval?~~

**Decision:** Supervisor approval required for mid-run checkout.

**[Q49] PLC Tag Behaviour on Rod Checkout — Tim O. / Jaspreet** *(In Progress)*
When a rod checkout is confirmed, how should the system clear PLC tags — immediately or after a safe-stop handshake?

**Status (May 4, 2026):** Tim needs to confirm with engineering. Proposed design: application never sends stop command; operator stops physically; application checks `FL1.LineState` before allowing checkout; tags cleared only after confirmed stop. Pending engineering confirmation.

**[Q50] Partial-Run Material Disposition Authority — ~~Tim O. / Shannon R.~~ ✅ DECIDED May 4, 2026**
~~Does the operator have sole authority to accept partial footage as a spool alpha?~~

**Decision:** Supervisor must approve before partial spool alpha is created. Notification-driven remote approval model: operator submits → material locked → supervisor notified via SignalR → supervisor chooses Accept / Hold / Reject → alpha created accordingly.

---

### 2E. Weld Traceability & Certification

**[Q21] Traceability Granularity for Customer Certs — Tim O. / Mick**
What is the minimum traceability unit required by welding wire customers — full coil-level, lot-level, or heat-level? Does this granularity need to appear explicitly on the Certificate of Conformance, or is a lot reference sufficient?

**[Q22] Weld Attribution on Output Footage — Tim O. / Jaspreet**
When a weld joins two source rods (R1 and R2) into a continuous run, how is output footage attributed to each source for cert and yield purposes — is there a footage-based split at the weld point, or is the entire output coil attributed to the dominant (largest-contributor) rod?

**[Q23] Maximum Weld Joints Per Finished Coil — Tim O. / Sales**
Is there a customer-specified limit on the number of weld joints permitted in a single coreless oscillated coil? Exceeding this limit causes wire jams in customer welding equipment. If a limit exists, it must be built as a validation rule that flags the coil before it is released.

**[Q25] C of C Frequency — Per Coil, Order, or Heat — Tim O. / Mick**
Are Certificates of Conformance for flat wire issued per coil, per order, or per heat? Is this consistent across all flat wire customers, or is it customer-specific?

---

### 2F. Web Application

**[Q2] Pricing Auto-Population on Orders and Quotes — Sales / Tim O.**
The mechanism for auto-populating flat wire pricing on the Orders and Quotes screens is listed as TBD. Who owns this decision, and what is the pricing model — fixed price list, formula-based calculation, or manual override by Sales?

**[Q11] Bundle Width Range Determination — Sales / Tim O.**
The IQR screen shows a Min/Max range for Bundle Width. How are these ranges determined — by order specification, by alloy, by machine capability, or entered manually by the Sales team at time of order entry? Are there default ranges per product family?

**[Q16] Coreless Coil Skid Labeling Rules — Tim O. / Shannon R.**
Final output is 2 coreless oscillated coils per skid — consistent with the transformer line. Do skid labeling, alpha assignment, and packaging records follow the exact same rules as the transformer line, or are flat wire-specific adjustments required?

---

### 2G. Yield, Cost & Reporting

**[Q3] Costing Standards and Industry Codes — Jeff G. / Tim O.**
Are new industry codes needed for flat wire, or do existing codes (e.g., 510 = Flat Fin, 530 = Spiral Fin Hudson) apply regardless of production route (pancake, tolled, flat wire)? Who is responsible for defining this, and by when?

**[Q4] SCADA Chart Layout Owner and Timeline — Tim O.**
UA is responsible for defining the SCADA chart layout and machine tags for FL1, FL2, and FL3. No owner or delivery date has been assigned. This blocks SCADA report development. Who will deliver this, and by when?

**[Q5] Standard Times for FL1, FL2, FL3 — Tim O. / Jeff G.**
Standard times per machine are required for yield calculation but have not been defined. Who is building these, and by when? Without standard times, the yield module cannot be completed before go-live.

**[Q37] Yield Loss Factor for Planning Rod Input Sizing — Tim O. / Margo**
Is there a per-pass scrap allowance (die entry crop, edge trim, end crop, weld scrap) that the planning algorithm must apply when calculating the required rod input weight for an order? If not built in, planners will systematically under-order rod and only discover the shortage when the job reaches the machine.

---

### 2H. Dimensional Tolerances

**[Q34] Twist and Torsion Tolerance for Welding Wire — Tim O. / Technical**
Is there a maximum allowable twist per foot for flat wire — particularly for welding wire feedability through automated welding equipment? Exceeding this limit is a common first-shipment field failure that causes wire jams at the customer. If a limit exists, it needs to be a system-enforced quality checkpoint.

**[Q38] Published Tolerance Bands (ASTM / Customer Spec) — Tim O. / Mick**
What are the thickness and width tolerance bands per alloy and temper for flat wire — governed by ASTM B236, customer purchase orders, or UA internal standards? These values are required before SPC control limits can be configured and before the gauge trace report produces meaningful alarms.

---

### 2I. Packaging & Coil Limits

**[Q31] Coreless Coil OD/ID Limits — Tim O. / Sales**
What are the maximum OD and minimum ID for coreless oscillated coils? Are these limits driven by UAL's TKUP-2 equipment, customer unwinding equipment dimensions, or both? These figures determine how many coils are produced per rod input and how the system splits continuous output into individual coil alphas.

**[Q32] Maximum Finished Coil Weight — ~~Tim O. / Bob S.~~ ✅ DECIDED Apr 28, 2026**
~~TKUP-2 has a 1,000 lb capacity. Is the customer-facing maximum coil weight also 1,000 lb, or is it set lower (e.g., 500 lb for ease of handling at the customer)?~~

**Decision (updated May 4, 2026):** Maximum finished coil weight confirmed at **1,100 lb** (TKUP-2 equipment limit — revised from 1,000 lb stated Apr 28). The customer defines their specific maximum below UA's equipment limit in the orders/quotes application. Orders exceeding a single rod or spool weight are split into multiple stops, with alphas generated at planning time.

---

### 2J. Spool Lifecycle

**[Q55] Spool Alpha Continuity Through Anneal or Re-Pass — ~~Tim O. / Jaspreet~~ ✅ DECIDED May 4, 2026**
~~Does an anneal step generate a new child alpha or does the existing spool alpha carry forward?~~

**Decision:** The existing alpha is **modified** to maintain traceability through an anneal — no new child alpha is generated. Re-pass through FL1 is not applicable (UA does not have the capability to run a spool through FL1).

**[Q57] Spool Status State Machine — All Valid Transitions — Tim O. / Jaspreet** *(In Progress)*
What are all valid spool statuses and what events trigger each transition?

**Status (May 4, 2026):** Operational framework confirmed: spools have unique identifiers similar to furnace plates. Alpha is loaded onto a spool number at FL1 job start; operator inputs spool number. Spool tracked: tow motor → furnace → cooling → FL2 (operator selects spool number at check-in). Full formal state machine (all statuses and transition events) is still TBD.

---

## PART 3 — MEDIUM PRIORITY (12 Questions)

*Must be resolved before August 1 production start.*

---

**[Q6] FL1/FL2/FL3 Output Throughput Rates — Bob S.**
FL1, FL2, and FL3 output throughput rates (lbs/hr or ft/min) have not been documented. Equipment capacities (VPS 9,000 lb, TKUP-1 3,500 lb, TKUP-2 1,100 lb) are known, but throughput rates are required for scheduling run-time estimates.

**[Q9] Finish Field Lock — Temporary or Permanent — Tim O.**
The Finish field on the Orders screen is locked (read-only) per a prior decision. Is this a temporary restriction pending a future decision, or a permanent policy for all flat wire orders?

**[Q12] Edge Critical Attribute Default — Tim O. / Technical**
When Flat Wire is selected on an order, the "Edge" critical attribute is auto-set to "5 — Edge not a consideration." Are there any flat wire products (e.g., contact strip, precision flat-edge wire) where edge quality is a contractual customer requirement and this default must not apply?

**[Q19] Rod Storage System-Side Location Tracking — Naj / Chuck**
Naj and Bob are working on the physical rod storage layout. Are there system-side location tracking requirements (e.g., bay/row/position fields in the database), or will rod storage be managed physically with no system location record?

**[Q24] Rework Weld Traceability on Cert — Tim O. / Mick**
If a weld breaks mid-run and the operator re-welds, must that rework event be recorded and appear on the cert or traveler? Who defines this requirement — UAL internal policy or customer specification?

**[Q26] Tolled Flat Wire Cert Liability — Tim O. / Legal**
For orders where the customer supplies the rod, who holds chemistry cert liability — UA or the customer? This determines what chemistry data the rod receiving module must capture and retain for customer-supplied material.

**[Q33] Oscillation Layer Interleave Material — ~~Tim O. / Sales~~ ✅ DECIDED May 4, 2026**
~~Is a separator required between winding layers in the coreless oscillated coil?~~

**Decision:** No separator required or available. UA does not currently have the capability to provide any separator between oscillate layers. No pack specification field needed.

**[Q39] Camber and Flatness Limits — ~~Tim O. / Technical~~ ✅ DECIDED May 4, 2026**
~~Is there a maximum camber specification for flat wire?~~

**Decision:** The camber SPC feature should be available in the SPC checkpoint if the customer has camber specifications. Implementation is conditional on customer requirement — the field is available but not mandatory for all orders.

**[Q40] Edge Burr Height Limit and Measurement — ~~Tim O. / Technical~~ ✅ DECIDED May 4, 2026**
~~For Flat Edge products, what is the maximum allowable edge burr height?~~

**Decision:** Not currently measured. No system implementation required at this time.

**[Q41] Die Life Tracking — ~~Tim O. / Maintenance~~ ✅ DECIDED May 4, 2026**
~~Should the system track footage run per die and generate a replacement alert?~~

**Decision:** Yes, system-level die life tracking required. Footage data logged against die number (unique identifier per die, similar to mill rolls). Tracks when in use and total footage through it. Replacement threshold deferred until failure data is available from actual production. Alert mechanism: passive banner on die check-in screen; no hard block; Maintenance can acknowledge and extend with reason code.

**[Q42] Edger Blade Profiles — Standard or Custom Per Product — Tim O. / Maintenance**
Are edger blade profiles standardized across all flat wire products, or are they custom per edge type (Round Edge vs. Flat Edge) or per alloy? Who maintains the blade profile library, and does it need to be stored in the system alongside the pass schedule?

**[Q43] Roll Regrind Process, Lead Time, and Spare Inventory — Tim O. / Maintenance**
Are rolls reground in-house or sent to an outside vendor? What is the turnaround time, and how many spare roll sets must be on hand to avoid unplanned line downtime? Does the system need to track roll condition, footage run, and current location (in service / at grinder / in spare inventory)?

**[Q53] Pass Schedule Validation in Planning/Scheduling — Tim O. / Stephen**
Should the planning or scheduling system warn when a job is scheduled for FL1/FL2/FL3 but no active pass schedule exists for that product's alloy, gauge, width, and edge type combination? Without this check, the operator arrives at the machine with no pass schedule available, blocking the line until Operations creates one.

**[Q56] "Require SPC on Resume" Override Authority — ~~Tim O. / Shannon R.~~ ✅ DECIDED May 4, 2026**
~~What role is permitted to turn off the "Require SPC on resume" toggle?~~

**Decision:** Thread mode is allowed until SPC has been completed — this ensures the correct die has been installed. For Gauge drift and Size change die replacements, confirm die change routes to the SPC Checkpoint screen, and the run stays blocked until SPC passes. Override authority details (who can turn off the toggle) should be restricted to Operations Manager or Quality role minimum, with mandatory reason code and audit log.

---

## PART 4 — LOW PRIORITY (4 Questions)

*Can be resolved post go-live.*

---

**[Q7] Baler Maximum Dimensions — Plant / Tim O.**
Out-of-spec wire bundles are compacted in the baler. The baler's maximum bundle dimensions have not been confirmed. Who provides this information from the plant?

**[Q8] WIP REJ Report Column Definitions — Shannon R.**
The WIP REJ report requires column updates, but the specific columns that change have not been documented. Shannon R. is the likely owner — please detail the required column changes before the report is modified.

**[Q13] Scrap Banding Material — Tim O. / Plant**
Documentation notes a difference between steel and aluminum alloy banding for scrap bales but does not resolve which material is used for flat wire scrap. Confirmation needed from plant operations.

---

## SUMMARY TABLE

| Priority | Count | Deadline |
|----------|-------|---------|
| Critical | 11 | Before development starts |
| High | 29 | Before July 1 trials |
| Medium | 14 | Before August 1 production |
| Low | 4 | Post go-live |
| **Total (at send date)** | **57** | |

> **Post-meeting update (Apr 28, 2026):** Q32 decided — see above. Two new questions added from Planning & Shopfloor meeting: **Q58** (OD → weight conversion formula, Tim O.) and **Q59** (planning grid vs new flat-wire section, team). Q51 and Q52 partially resolved via dashboard updates — selection mechanism and unified FL3 pass schedule approach now shown in mockups; residual open points remain (no-match path and FL2 hybrid-spool validation). **Current register total: 59 questions.** See [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) for authoritative status.

---

Please reply to this email with your answers, or flag questions where you need a meeting to discuss. For Critical items, we ask for responses by **[DATE TBD]** to keep the development schedule on track.

Thank you,
Jaspreet / Development Team

---

*Reference: Full question register maintained in `Analysis/FlatWireOpenQuestions.md`*
