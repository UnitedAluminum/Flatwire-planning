# Flat Wire Mill — Open Questions Register

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 28, 2026
**Total Questions:** 66
**Status Legend:** `Open` · `In Progress` · `Decided` · `Deferred`

> Questions marked **Critical** must be resolved before development begins on the dependent module.
> Questions marked **High** must be resolved before July 1 trials.
> Questions marked **Medium** must be resolved before August 1 production.
> Questions marked **Low** can be resolved post go-live.

---

## Quick Reference — Decision Log

| # | Question (Short) | Priority | Owner | Status | Decided Date |
|---|-----------------|----------|-------|--------|--------------|
| 1 | Pass Schedule UI vs. table management | Critical | Tim O. | Open | |
| 2 | Pricing auto-population mechanism | High | Sales / Tim O. | Open | |
| 3 | Costing standards and industry codes | High | Jeff G. / Tim O. | Open | |
| 4 | SCADA chart layout owner and timeline | High | UA (Tim O.) | Open | |
| 5 | Standard times for FL1/FL2/FL3 | High | Tim O. / Jeff G. | Open | |
| 6 | FL1/FL2/FL3 output throughput rates | Medium | Bob S. | Open | |
| 7 | Baler maximum dimensions | Low | Plant / Tim O. | Open | |
| 8 | WIP REJ report column definitions | Low | Shannon R. | Open | |
| 9 | Finish field lock — temporary or permanent | Medium | Tim O. | Open | |
| 10 | FL3 scheduling representation | Critical | Tim O. / Stephen | In Progress | |
| 11 | Bundle Width range determination | High | Sales / Tim O. | Open | |
| 12 | Edge critical attribute default logic | Medium | Tim O. / Technical | Open | |
| 13 | Scrap banding material | Low | Tim O. / Plant | Open | |
| 14 | Traveler screen fields per station | Critical | Jaspreet / Tim O. | Open | |
| 15 | FL2 spool check-in identifier | Critical | Jaspreet / Tim O. | Open | |
| 16 | Coreless coil skid labeling rules | High | Tim O. / Shannon R. | Open | |
| 17 | Rod receiving label format | High | Tim O. / Darlene | Open | |
| 18 | Inventory type for rods in coils table | Critical | Tim O. / Jeff G. | Open | |
| 19 | Rod storage system-side location tracking | Medium | Naj / Chuck | Open | |
| 20 | Anneal rules for rod/wire timeline | High | Dan F. | Open | |
| 21 | Traceability granularity for certs | High | Tim O. / Mick | Open | |
| 22 | Weld attribution on output footage | High | Jaspreet / Tim O. | Open | |
| 23 | Max weld joints per finished coil | High | Tim O. / Sales | Open | |
| 24 | Rework weld traceability on cert | Medium | Tim O. / Mick | Open | |
| 25 | C of C frequency — per coil/order/heat | High | Tim O. / Mick | Open | |
| 26 | Tolled flat wire cert liability | Medium | Tim O. / Legal | Open | |
| 27 | Mid-run pass schedule change — alpha handling | Critical | Jaspreet / Tim O. | Decided | May 4, 2026 |
| 28 | Pass schedule override authority and logging | High | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 29 | Component failure mid-run protocol | High | Tim O. / Plant | Decided | May 4, 2026 |
| 30 | Roll gap validation before run start | High | Jaspreet / Tim O. | In Progress | |
| 31 | Coreless coil OD/ID limits | High | Tim O. / Sales | In Progress | |
| 32 | Maximum finished coil weight | High | Tim O. / Bob S. | Decided | Apr 28, 2026 |
| 33 | Oscillation layer interleave material | Medium | Tim O. / Sales | Decided | May 4, 2026 |
| 34 | Twist and torsion tolerance for welding wire | High | Tim O. / Technical | Open | |
| 35 | Expected metallic yield per route | Critical | Tim O. / Jeff G. | Open | |
| 36 | Footage-to-weight conversion factor | Critical | Tim O. / Bob S. | Open | |
| 37 | Yield loss factor for planning rod input | High | Tim O. / Margo | Open | |
| 38 | Published tolerance bands (ASTM / customer) | High | Tim O. / Mick | Open | |
| 39 | Camber and flatness limits | Medium | Tim O. / Technical | Decided | May 4, 2026 |
| 40 | Edge burr height limit and measurement | Medium | Tim O. / Technical | Decided | May 4, 2026 |
| 41 | Die life tracking — system or manual | Medium | Tim O. / Maintenance | Decided | May 4, 2026 |
| 42 | Edger blade profiles — standard or custom | Medium | Tim O. / Maintenance | Open | |
| 43 | Roll regrind, spare inventory, tracking | Medium | Tim O. / Maintenance | Open | |
| 44 | Line speed range per alloy/gauge | High | Tim O. / Bob S. | Decided | May 4, 2026 |
| 45 | FL1 and FL2 simultaneous independent operation | Critical | Tim O. / Stephen | Decided | May 4, 2026 |
| 46 | Shared anneal furnace capacity for flat wire | High | Dan F. / Tim O. | Open | |
| 47 | Partial-rod re-check-in and traceability carry-forward | High | Jaspreet / Tim O. | In Progress | |
| 48 | Mid-run rod checkout authorisation level | High | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 49 | PLC tag behaviour on rod checkout | High | Jaspreet / Tim O. | In Progress | |
| 50 | Partial-run material disposition authority | High | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 51 | Pass schedule selection mechanism at check-in | Critical | Tim O. / Jaspreet | Open | |
| 52 | FL3 hybrid pass schedule — one or two schedules? | Critical | Tim O. / Jaspreet | Open | |
| 53 | Pass schedule validation during planning/scheduling | Medium | Tim O. / Stephen | Open | |
| 54 | Pass schedule ID on coil completion and cert record | High | Tim O. / Mick | Decided | May 4, 2026 |
| 55 | Spool alpha continuity through anneal or re-pass | High | Tim O. / Jaspreet | Decided | May 4, 2026 |
| 56 | "Require SPC on resume" override authority | Medium | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 57 | Spool status state machine — all valid transitions | High | Tim O. / Jaspreet | In Progress | |
| 58 | OD/diameter → weight conversion formula for spool | High | Tim O. | Open | |
| 59 | Planning: flat wire orders in existing grid vs new dedicated section | Medium | IT / Team | Open | |
| 60 | Target spool weight source for the completion alert + over-target behavior | High | Tim O. / Operations | Open | |
| 61 | Does the spool completion alert ladder apply to finished coils at TKUP-2 (FL2/FL3)? | Medium | Tim O. / Jaspreet | Open | |
| 62 | Supervisor mirroring and audit persistence of milestone acknowledgements | Medium | Tim O. / IT | Open | |
| 63 | `FL{n}.LineState` vocabulary, stop-dwell value, and pause-reason suppression | High | Engineering / Tim O. | Open | |
| 64 | Stop-confirmation popup — supervisor visibility and multi-operator arbitration | Medium | Tim O. / IT | Open | |
| 65 | Short-close path — closing a spool below target weight | Medium | Tim O. / Operations | Open | |
| 66 | Scale-vs-calculated spool weight — tolerance, default basis, approval authority | High | Tim O. / Shannon R. | In Progress | |

---

## Detailed Questions

---

### Section A — Project-Specific Questions

---

#### A1. Pass Schedule & System Architecture

**Q1** · `Critical` · Owner: Tim O.
**Pass Schedule UI vs. table management**
The system requires a Pass Schedule database (not an auto-generator) — confirmed. Is there a UI screen for Operations/Maintenance to create and edit pass schedule records, or is this managed directly in a database table? A UI is expected given the manual maintenance requirement.

---

**Q27** · `Critical` · Owner: Jaspreet / Tim O. · `Decided May 4, 2026`
**Mid-run pass schedule change — alpha handling**
If a pass schedule changes mid-coil (e.g., due to a die swap or edge change), does the system create a new child alpha for the post-change material, or amend the existing alpha?

**Decision (May 4, 2026):** Not all mid-run changes are equal. Five cases are defined:

**Case 1 — Same-spec tooling swap (planned life, gauge drift, die failure)**
The target product specification does not change. A DB2 die at 0.310" is replaced with another 0.310" die because the old one wore out. The material before and after the swap is the same product.
- **Decision:** Single alpha + die change event at footage position. Tim confirmed this approach.

**Case 2 — Size change or product configuration change**
The pass schedule is updated to change the product itself — a different die size (e.g., 0.310" → 0.296"), edge type switches from Round to Flat, or a roll gap adjusted to target a different width. Material after the change is a different product from material before it.
- **Decision:** New child alpha at the footage breakpoint (e.g., FW-00421-C01-A). Pre-change alpha closes with defined start/end footage and pass schedule. Tim confirmed this approach.

**Case 3 — Edge type change**
Different product definition: cert and customer requirements differ.
- **Decision:** New child alpha. Tim confirmed this approach.

**Case 4 — Roll gap adjustment within tolerance (automatic gauge control)**
Process tuning within spec, not a product change. Note: Both FL1 and FL2 mills have automatic gauge control (AGC). Roll gaps can deviate to maintain gauge/width within tolerance via output of gauge/width trace devices.
- **Decision:** Single alpha, no change. Tim confirmed — there should be no change to alpha for AGC-driven adjustments.

**Case 5 — Roll gap change to a new target width/gauge**
Product spec changes — a deliberate operator-driven reset to a new target, not AGC correction.
- **Decision:** New child alpha. Tim confirmed this approach.

---

**Q28** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**Pass schedule override authority and logging**

**Decision (May 4, 2026):** The four-step mid-run configuration change flow is confirmed:

**Step 1 — Operations log the override**
- Floor operators have read-only access to the pass schedule at check-in. They cannot edit it unless it is a one-for-one change (e.g., replace DB1 die 0.285" with new die 0.285" — same size). Any other change requires an Operations Manager.
- The Operations Manager opens Pass Schedule Management Dashboard, edits the pass schedule. The system records: what parameter changed, old value → new value, who made the change (user ID), timestamp, and a reason code or free-text reason.
- Pass Schedule Management Dashboard includes an Override Log showing the last 5 changes with date, user, parameter, and reason. Tim confirmed this approach.

**Step 2 — Active Run Monitor shows an alert requiring operator acknowledgment**
- When the override is saved, the system pushes a real-time notification to the Active Run Monitor Dashboard on the active line.
- The operator must explicitly either Acknowledge (understood; production continues under new config) or Stop Run (supervisor review required before proceeding). Passive dismissal is not permitted.
- The notification bridges the gap between the updated database record and the PLC tags still running the machine under the old configuration. Tim confirmed this approach.

**Step 3 — System records material before and after the change under respective configurations**
- The system records the footage counter value at the moment of the change.
- If within-spec tuning: configuration event recorded on the existing alpha at the footage position.
- If product specification changes: existing alpha closes at that footage, new child alpha opens at that footage with the new pass schedule. Tim confirmed this approach.

**Step 4 — Automatic SPC checkpoint triggered post-change**
- When pass schedule changes mid-run (especially die size or roll gap change), the system automatically triggers an SPC checkpoint to verify the machine has settled to the new targets.
- This works the same as the existing die change flow: when reason is gauge_drift or size_change, spcCheckpointRequired is set to true.
- Active Run Monitor shows "Configuration Change Logged — Awaiting SPC Checkpoint." Operator cannot close that status without completing SPC. Tim confirmed this approach.

---

**Q29** · `High` · Owner: Tim O. / Plant · `Decided May 4, 2026`
**Component failure mid-run protocol**

**Decision (May 4, 2026):** Build an unplanned component bypass event as a distinct transaction from a planned bypass. Tim acknowledged that while some components cannot be bypassed, with experience and ingenuity some may be workable around. The full framework is confirmed:

- **New event type** — When an operator bypasses a component that was planned active, they must explicitly record it as an unplanned bypass (not silently inherit the planned config). Captures: which component, time of bypass, footage position at failure, reason code, and operator ID.
- **Alpha split at the bypass point** — Create a child alpha at the split point. Pre-failure material runs under the original pass schedule; post-bypass material runs under the modified effective configuration.
- **Supervisor acknowledgment** — Bypass-and-continue requires supervisor-level confirmation, not operator-only.
- **Disposition decision for pre-bypass material** — If the failure event itself may have affected material quality before the component was bypassed, a disposition step (accept / inspect / reject) is required for the footage produced during the failure window (parallel to Q50 partial-run disposition flow).

---

**Q30** · `High` · Owner: Jaspreet / Tim O. · `In Progress`
**Roll gap validation before run start**
How are roll gap settings confirmed before a run begins — manual measurement by the operator, encoder feedback logged by PLC, or a system confirmation step required before check-in is allowed to proceed?

**Status (May 4, 2026):** Tim needs to confirm with engineering. Three options remain open:
- **Option 1** — Operator physically measures each active roll gap and enters readings; system compares against pass schedule setpoints.
- **Option 2** — PLC encoder feedback available; system reads back actual achieved roll gap position and compares to setpoint. Run cannot start until all active rollers report within tolerance.
- **Option 3** — Operator acknowledges pass schedule, system pushes PLC tags, run starts with no readback (current implied design — rated HIGH risk).

Once the approach is confirmed, a secondary question must also be resolved: Is a supervisor override sufficient to bypass a gap-out-of-tolerance block, or should an out-of-tolerance gap be treated as a hard stop?

---

#### A2. Scheduling & FL3

**Q10** · `Critical` · Owner: Tim O. / Stephen · `In Progress`
**FL3 scheduling representation**
FL3 is the hybrid continuous mode (FL1 + FL2). How is it represented in the scheduling system — as a single machine booking entry, or as simultaneous bookings on both FL1 and FL2? Does scheduling a job on FL3 block both lines simultaneously?

**Partial decision (May 4, 2026):** FL3 cannot run if there are scheduled orders on FL1 or FL2. FL1, FL2, and FL3 are treated as separate machines in scheduling. The remaining open point is how FL3 is represented as a booking unit and whether it generates a single combined booking or simultaneous entries on both lines.

---

**Q45** · `Critical` · Owner: Tim O. / Stephen · `Decided May 4, 2026`
**FL1 and FL2 simultaneous independent operation**

**Decision (May 4, 2026):**
- FL1 and FL2 can run independent orders simultaneously in non-hybrid mode. They are designated and tracked as separate machines in scheduling — analogous to how an order might run on ZR24 then U30.
- Each has its own machine booking, separate alphas, and separate check-in events.
- FL1/FL2 throughput ratio is approximately 3:1 (FL1 significantly faster than FL2). This creates open capacity on FL1 more often than FL2 depending on order mix.
- FL3 (hybrid continuous mode) cannot run if there are scheduled orders on FL1 or FL2.

---

#### A3. Shopfloor & Traveler Screens

**Q14** · `Critical` · Owner: Jaspreet / Tim O.
**Traveler screen fields per station**
Generic labels (e.g., "Incoming Bundle Information") are agreed in principle. The full field list per station for FL1, FL2, and FL3 has not been documented. Who is responsible for defining these, and by when?

---

**Q15** · `Critical` · Owner: Jaspreet / Tim O.
**FL2 spool check-in identifier**
When flat wire arrives at FL2 on a spool loaded onto the TPO, what identifier (alpha, spool number, bundle ID) is used for check-in? How does that identifier link to the outgoing coreless coil record at TKUP-2?

---

#### A4. Rod Receiving

**Q17** · `High` · Owner: Tim O. / Darlene
**Rod receiving label format**
The label format for received rod material is listed as TBD. What fields are required on the label, and does it need to support tolling labels for customer-supplied rod?

---

**Q18** · `Critical` · Owner: Tim O. / Jeff G.
**Inventory type for rods in coils table**
The SRS notes that Inventory Type for rod entries in the coils table is TBD. Who defines this, and how does it affect planning allocation, cost tracking, and yield reporting?

---

**Q19** · `Medium` · Owner: Naj / Chuck
**Rod storage system-side location tracking**
Naj and Bob are working on the physical rod storage layout. Are there system-side location tracking requirements (e.g., bay/row/position fields), or will rod storage be managed physically with no system location record?

---

#### A5. Output & Packaging

**Q16** · `High` · Owner: Tim O. / Shannon R.
**Coreless coil skid labeling rules**
Final output is 2 coreless oscillated coils per skid — consistent with transformer line behavior. Do skid labeling, alpha assignment, and packaging records follow the exact same rules as the transformer line, or are flat wire-specific adjustments required?

---

#### A6. Web Application

**Q2** · `High` · Owner: Sales / Tim O.
**Pricing auto-population (Orders/Quotes)**
The mechanism for auto-populating flat wire pricing on the Orders and Quotes screens is listed as TBD. Who owns this decision, and what is the pricing model (fixed price list, formula-based, manual override)?

---

**Q9** · `Medium` · Owner: Tim O.
**Finish field lock — temporary or permanent**
The Finish field on the Orders screen is locked (read-only) per Tim O.'s decision. Is this a temporary restriction pending a future decision, or a permanent policy for flat wire orders?

---

**Q11** · `High` · Owner: Sales / Tim O.
**Bundle Width range determination**
The IQR mockup shows a Min/Max range for Bundle Width. How are these ranges determined — by order specification, by alloy, by machine capability, or entered manually by the sales team? Are there default ranges per product family?

---

**Q12** · `Medium` · Owner: Tim O. / Technical
**Edge critical attribute default**
When Flat Wire is selected, the "Edge" critical attribute is auto-set to "5 - Edge not a consideration." Are there any flat wire products (e.g., contact strip, precision flat-edge wire) where edge quality is a contractual requirement and this default should not apply?

---

#### A7. Yield, Cost & Reporting

**Q3** · `High` · Owner: Jeff G. / Tim O.
**Costing standards and industry codes**
Are new industry codes needed for flat wire, or do existing codes (e.g., 510 = Flat Fin, 530 = Spiral Fin Hudson) apply regardless of routing (pancake, tolled, flat wire)? Who is responsible for defining this?

---

**Q4** · `High` · Owner: UA — Tim O. · **Decided — May 15, 2026**
**SCADA chart layout owner and timeline**
UA is responsible for defining the SCADA chart layout and machine tags for flat wire. No owner or delivery date has been specified. This blocks SCADA report development.

**Decision (May 15, 2026):** The SCADA chart layout is now fully defined as **Dashboard 14 — SCADA Multi-Trend Charts** in [HMIAndSCADALayout.md](HMIAndSCADALayout.md). This covers gauge, width, speed, and payoff weight trend charts with configurable time windows, SPC control limits, event markers (weld, die change, pause, SPC), and CSV export. The HMI line schematic is defined as Dashboard 13. All PLC tag paths required for both screens are documented in the PLC Tag Mapping table in that document. Tag paths must be confirmed with Tim O. and the commissioning engineer before go-live. Mockups: [dashboard_13_hmi_schematic.html](../Mockups/dashboard_13_hmi_schematic.html) and [dashboard_14_scada_trends.html](../Mockups/dashboard_14_scada_trends.html).

---

**Q5** · `High` · Owner: Tim O. / Jeff G.
**Standard times for FL1, FL2, FL3**
Standard times per machine are required for yield calculation but have not been defined. Who is building these, and by when? No standard times means the yield module cannot be completed.

---

**Q8** · `Low` · Owner: Shannon R.
**WIP REJ report column definitions**
The WIP REJ report requires column updates but the specific columns have not been documented. Shannon R. is the likely owner — this needs to be detailed before the report can be modified.

---

**Q20** · `High` · Owner: Dan F.
**Anneal rules for rod/wire — timeline**
Anneal rules for rod and wire are required by the scheduling algorithm. Dan F. owns this area. No timeline has been specified — when will these rules be available for the scheduler to consume?

---

**Q46** · `High` · Owner: Dan F. / Tim O.
**Shared anneal furnace capacity for flat wire**
Are furnace slots for flat wire annealing shared with the existing coil anneal schedule, or is there dedicated flat wire furnace capacity? If shared, the scheduling algorithm must account for furnace contention when planning flat wire jobs requiring an intermediate anneal.

---

#### A8. Scrap & Tooling

**Q6** · `Medium` · Owner: Bob S.
**FL1/FL2/FL3 output throughput rates**
VPS, FM1/TKUP-1 (3,500 lb), and TKUP-2 (1,100 lb) capacities are documented. FL1, FL2, and FL3 output throughput rates (lbs/hr or ft/min) are not listed. Required for scheduling run-time estimates.

---

**Q7** · `Low` · Owner: Plant / Tim O.
**Baler maximum dimensions**
Out-of-spec wire bundles are compacted in the baler. The baler's maximum bundle dimensions have not been confirmed. Who provides this information?

---

**Q13** · `Low` · Owner: Tim O. / Plant
**Scrap banding material**
Documents note differences between steel and aluminum alloy banding but do not resolve which material is used for flat wire scrap bales. Confirmation needed from plant operations.

---

### Section B — Industry-Standard Questions

---

#### B1. Weld Traceability & Certification

**Q21** · `High` · Owner: Tim O. / Mick
**Traceability granularity for certs**
What is the minimum traceability unit required by welding wire customers — full coil-level, lot-level, or heat-level? Does this granularity need to appear explicitly on the Certificate of Conformance, or is a lot reference sufficient?

---

**Q22** · `High` · Owner: Jaspreet / Tim O.
**Weld attribution on output footage**
When a weld joins two source rods (R1 and R2) into a continuous run, how is output footage attributed to each source for cert and yield purposes? Is there a footage-based split at the weld point, or is the entire output coil attributed to the dominant (largest contributor) rod?

---

**Q23** · `High` · Owner: Tim O. / Sales
**Maximum weld joints per finished coil**
Is there a customer-specified limit on the number of weld joints permitted in a single coreless oscillated coil? Exceeding this limit can cause wire jams in customer welding equipment. This must be captured as a validation rule if applicable.

---

**Q24** · `Medium` · Owner: Tim O. / Mick
**Rework weld traceability on cert**
If a weld breaks mid-run and the operator re-welds, must that rework event be recorded and appear on the cert or traveler? Who defines this requirement — UAL policy or customer spec?

---

**Q25** · `High` · Owner: Tim O. / Mick
**C of C frequency — per coil, order, or heat**
Are Certificates of Conformance issued per coil, per order, or per heat for flat wire? Is this consistent across all flat wire customers or customer-specific?

---

**Q26** · `Medium` · Owner: Tim O. / Legal
**Tolled flat wire cert liability**
For orders where the customer supplies the rod, who holds chemistry cert liability — UA or the customer? This determines what chemistry data the rod receiving module must capture and retain.

---

#### B2. Dimensional Tolerances & Quality Standards

**Q38** · `High` · Owner: Tim O. / Mick
**Published tolerance bands (ASTM / customer spec)**
What are the thickness and width tolerance bands per alloy and temper for flat wire — governed by ASTM B236, customer purchase orders, or UA internal standards? These are required before SPC control limits can be configured and before the gauge trace report produces meaningful alarms.

---

**Q39** · `Medium` · Owner: Tim O. / Technical · `Decided May 4, 2026`
**Camber and flatness limits**

**Decision (May 4, 2026):** The camber measurement feature should be available in the SPC checkpoint if the customer has camber specifications. Implementation is conditional on customer requirement — the field is available but not mandatory for all orders. Inline measurement method to be confirmed per order spec.

---

**Q40** · `Medium` · Owner: Tim O. / Technical · `Decided May 4, 2026`
**Edge burr height limit and measurement method**

**Decision (May 4, 2026):** Not currently measured. No system implementation required at this time.

---

**Q34** · `High` · Owner: Tim O. / Technical
**Twist and torsion tolerance for welding wire**
Is there a maximum allowable twist per foot for flat wire — particularly for welding wire feedability through automated welding equipment? Exceeding this limit causes wire jams at the customer and is a common first-shipment field failure.

---

#### B3. Packaging & Coreless Coil Limits

**Q31** · `High` · Owner: Tim O. / Sales · `In Progress`
**Coreless coil OD/ID limits**

**Status (May 4, 2026):** Tim confirmed that limits come from both sources: UA equipment defines the outer bounds for all OD/ID dimensions, and the customer defines their specific limits within the UA equipment range through the orders/quotes application. Tim will provide a more defined answer on the specific UA equipment limits.

---

**Q32** · `High` · Owner: Tim O. / Bob S. · `Decided Apr 28, 2026`
**Maximum finished coil weight**

**Decision (Apr 28, 2026, updated May 4, 2026):** New estimated maximum capacity is **1,100 lb** (TKUP-2 equipment limit — revised from 1,000 lb stated at Apr 28 meeting). The customer defines their coil weight limit below UA's maximum capacity; this is captured in the orders/quotes application. Orders exceeding a single rod or spool weight will be split into multiple stops, each generating its own alpha. The last stop may contain multiple alphas. Weight distribution is tracked via footage and revolutions.

---

**Q33** · `Medium` · Owner: Tim O. / Sales · `Decided May 4, 2026`
**Oscillation layer interleave material**

**Decision (May 4, 2026):** No separator is required or available. UA does not currently have the capability to provide any separator between oscillate layers. No pack specification field for interleave material is needed.

---

#### B4. Yield Loss & Planning Inputs

**Q35** · `Critical` · Owner: Tim O. / Jeff G.
**Expected metallic yield per route**
What is the target metallic yield (%) for each production route — (a) rod → flat wire direct, (b) rod → round wire → flat wire, and (c) flat wire → flat wire re-pass? Without this, the planning algorithm cannot correctly calculate required rod input weight per order.

---

**Q36** · `Critical` · Owner: Tim O. / Bob S.
**Footage-to-weight conversion factor**
How is the footage-to-weight conversion calculated per alloy and cross-section? Is there a standard formula (density × cross-sectional area × footage), or is it measured empirically and maintained per product? This factor is the basis for output weight calculation (weight is derived from length, not scale).

---

**Q37** · `High` · Owner: Tim O. / Margo
**Yield loss factor for planning rod input sizing**
Is there a per-pass scrap allowance (die entry crop, edge trim, end crop) that the planning algorithm must apply when sizing rod input weight for an order? If not built in, planners will systematically under-order rod and discover the shortage at the machine.

---

#### B5. Tooling Life & Maintenance

**Q41** · `Medium` · Owner: Tim O. / Maintenance · `Decided May 4, 2026`
**Die life tracking — system or manual**

**Decision (May 4, 2026):** System-level die life tracking is required. Tim confirmed:
- Footage data must be logged against die number (die ID).
- Each die has its own unique identifier, similar to mill rolls, enabling tracking of when it is in use and total footage through it.
- Replacement threshold estimate is deferred — an accurate figure will not be available until failure data is collected from actual production.

Confirmed design approach:

| Design Point | Decision |
|---|---|
| Tracking unit | Cumulative footage per die serial/ID, incremented from PLC footage counter on each completed or partial run |
| Alert threshold | Configurable replacement threshold per die type; Maintenance sets the value per die profile |
| Alert mechanism | Passive banner on die check-in screen and Maintenance dashboard row when remaining life < 10%; no hard block — Maintenance can acknowledge and extend with a reason code |
| Mid-run die swap | System closes footage accumulation on outgoing die and starts new counter on incoming die |
| Manual reset | After physical die replacement, Maintenance (Supervisor) resets footage counter through a dedicated die-management screen; logs who reset it and when |
| Sensor requirement | Pull footage from existing PLC footage counter already used for spool/alpha tracking — no new IoT sensor needed |

---

**Q42** · `Medium` · Owner: Tim O. / Maintenance
**Edger blade profiles — standard or custom per product**
Are edger blade profiles standardized across all flat wire products, or are they custom per edge type (Round Edge vs. Flat Edge) or per alloy? Who maintains the blade profile library, and does it need to be stored in the system alongside the pass schedule?

---

**Q43** · `Medium` · Owner: Tim O. / Maintenance
**Roll regrind process, lead time, and spare inventory**
Are rolls reground in-house or sent to an outside vendor? What is the turnaround time, and how many spare roll sets are required on hand to avoid unplanned line downtime? Does the system need to track roll condition, footage run, and current location (in service / at grinder / in inventory)?

---

#### B6. Scheduling Capacity Inputs

**Q44** · `High` · Owner: Tim O. / Bob S. · `Decided May 4, 2026`
**Line speed range per alloy and gauge**

**Decision (May 4, 2026):** Line speed ranges are unknown at this time and will be determined by trial. Once determined through production runs, the data can be added to a configuration table by UA. No blocking issue for initial development — scheduling algorithm should be designed to accept these values as table-driven inputs.

---

---

### Section C — Rod Checkout

---

#### C1. Rod Checkout Scenarios

**Q47** · `High` · Owner: Jaspreet / Tim O. · `In Progress`
**Partial-rod re-check-in and traceability carry-forward**

**Status (May 4, 2026):** Partial decisions received; full answer deferred.

- **Material remaining in mill:** Any material drawn/rolled will be scrapped as it remains in the mill when the rod is removed. The remaining rod going back to warehouse may need to be weighed to validate remaining weight. Tim has asked Scott, Bob, and Shannon to weigh in on whether a small scale at the payoff should be available for this purpose.
- **Multiple partial spool alphas per rod:** Yes, this functionality is needed. There is always potential for a rod to produce partial spool alphas across separate runs.
- **Carry-forward recommendation:** Full answer deferred — Tim will confirm. The proposed design (persistent rod record with footage_run_to_date and remaining_weight_estimate, carry-forward re-check-in, source_rod_alpha foreign key on each partial spool) is documented and awaiting confirmation.

---

**Q48** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**Mid-run rod checkout authorisation level**

**Decision (May 4, 2026):** A mid-run checkout (footage > 0, rod removed before exhaustion) requires supervisor approval. Operator-only checkout authority is not sufficient. This mirrors the WIP Rejection disposition flow.

---

**Q49** · `High` · Owner: Jaspreet / Tim O. · `In Progress`
**PLC tag behaviour on rod checkout**

**Status (May 4, 2026):** Tim needs to confirm the following proposed behavior with engineering:
- The application never sends a stop command to the PLC — the operator always controls the machine physically.
- Tags are only ever cleared when the line is confirmed stopped — no footage is lost, no control logic is disrupted mid-motion.
- The application checks whether the line is stopped before allowing checkout to proceed.

Proposed screen behavior (awaiting engineering confirmation):
- **If line is still running when operator clicks "Check Out Rod":** Checkout is blocked. Message shown: "Line is still running. Stop the line before checking out the rod." Checkout dialog does not open.
- **If line is confirmed stopped:** Checkout dialog opens. Footage counter value is read from the PLC and locked at that moment. Operator completes the form, clicks Confirm, and only then are PLC tags cleared and the checkout record written.

---

**Q50** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**Partial-run material disposition authority**

**Decision (May 4, 2026):** Supervisor must approve a mid-run checkout. The notification-driven remote approval model is confirmed:

1. Operator confirms mid-run checkout (footage > 0)
2. System creates Pending Disposition record
3. Material locked — no alpha created, not plannable
4. SignalR notification pushed to supervisor role
5. Supervisor reviews from any connected terminal:
   - Gauge trace for the partial run
   - Footage produced, reason for stop
   - Operator ID and timestamp
6. Disposition decision:
   - **Accept** → Alpha created, enters spool queue
   - **Hold** → Alpha created with Hold status; QC must release
   - **Reject** → WIP Rejection flow triggered; material goes to scrap
7. Disposition record written (supervisor ID, decision, reason code, timestamp)

---

### Section D — Pass Schedule Integration

---

#### D1. Pass Schedule Selection and Hybrid Mode

**Q51** · `Critical` · Owner: Tim O. / Jaspreet
**Pass schedule selection mechanism at check-in — no-match path undefined**
The selection mechanism itself is now shown in the updated dashboards: the system performs an attribute-based lookup (alloy + rod diameter + target gauge × width + route mode) and surfaces the best match as a system recommendation in a confirm bar. The operator must explicitly confirm before "Acknowledge & Begin Check-in" is enabled. A "Change" dropdown shows alternatives, and selecting a non-recommended schedule is flagged for Operations review.

**Remaining open point:** What happens when the lookup returns no match — i.e., no active pass schedule exists for the order's attribute combination? The dashboards show no empty-match or error state. Must the check-in be blocked and an alert sent to Operations so a schedule can be created before the line starts? Or can the operator proceed by manually selecting from a list of schedules that don't match? The no-match notification path must be defined before development begins on the check-in gate logic.

---

**Q52** · `Critical` · Owner: Tim O. / Jaspreet
**FL3 hybrid pass schedule — FL2 check-in validation for hybrid spools still undefined**
The updated FL3 rod check-in dashboard (dashboard_2_rod_checkin_fl3.html) implies Option A: a single unified pass schedule record (e.g., PS-1350-FL3-001) covers all FL1 and FL2 components together. The schedule list shows FL3 records with a "Hybrid" route tag, and the check-in attribute match includes "Hybrid route" as a lookup criterion. The data model question — one unified vs. two coordinated schedules — appears resolved toward a single record.

**Remaining open point:** When a spool produced on a hybrid FL3 run later arrives at FL2's TPO for spool check-in (Dashboard 5), how does the system validate it was produced under the correct hybrid pass schedule? The current Dashboard 5 mockup only shows standalone FL2 schedules (PS-1100-FL2-007). If a hybrid spool is loaded onto FL2 as a standalone re-pass job, is there a guard preventing the operator from applying a standalone FL2 schedule to material that was originally run under a hybrid configuration? This validation rule — how Dashboard 5 handles hybrid-origin spools — must be defined before FL2 check-in development begins.

---

**Q53** · `Medium` · Owner: Tim O. / Stephen
**Pass schedule validation during planning and scheduling**
Should the scheduling or planning system warn when a job is scheduled for FL1/FL2/FL3 but no active pass schedule exists for that product's alloy, gauge, width, and edge type combination? Without this check, operators will arrive at the machine ready to run with no pass schedule available, blocking the line until Operations creates one. A pre-scheduling validation prevents that delay.

---

#### D2. Pass Schedule Traceability

**Q54** · `High` · Owner: Tim O. / Mick · `Decided May 4, 2026`
**Pass schedule ID on coil completion and cert record**

**Decision (May 4, 2026):**
- **Label:** Pass schedule data (ID, version, die sizes, roll gap values) should NOT appear on the coil label.
- **Technical traceability:** Pass schedule ID and relevant configuration data should be logged against the coil record for technical traceability. This data must be captured at coil creation time so it can be retrieved for quality audits and engineering review, even if the pass schedule is subsequently edited.

---

### Section E — Spool Lifecycle

---

**Q55** · `High` · Owner: Tim O. / Jaspreet · `Decided May 4, 2026`
**Spool alpha continuity through anneal or re-pass operations**

**Decision (May 4, 2026):**
- **Anneal step:** The alpha should be modified (updated) to maintain traceability — no new child alpha is generated for an intermediate anneal. The existing spool alpha carries forward with the anneal step recorded against it.
- **Re-pass through FL1:** UA does not have the capability to run a spool through FL1. This scenario is not applicable.

---

**Q57** · `High` · Owner: Tim O. / Jaspreet · `In Progress`
**Spool status state machine — all valid transitions**

**Status (May 4, 2026):** Tim provided the following operational framework:
- Spools shall have unique identifiers similar to furnace plates.
- Alphas are loaded onto a spool number at the start of the FL1 job; operators are required to input the spool number being used.
- The spool number is then tracked physically and in the system: tow motor moves it to the furnace, then to cooling, and then the operator on FL2 selects it by spool number for check-in.

The full formal state machine (all valid statuses and the events that trigger each transition) is still to be defined. Without a defined state machine, the system cannot enforce valid status progressions (e.g., preventing a spool from being planned for two orders simultaneously, or a completed spool being re-opened for FL2 check-in).

---

**Q60** · `High` · Owner: Tim O. / Operations · `Open`
**Target spool weight source for the completion alert, and over-target behavior**

The spool completion alert ([SpoolCompletionNotification.md](SpoolCompletionNotification.md)) compares actual processed weight against a target. Two candidate sources exist: the order's **Max Wgt of Spool** (customer/order-driven) and the **take-up equipment capacity** (TKUP-1 = 3,500 lb). Working assumption is *order value, capped by equipment capacity*, with a **default target spool weight of 2,000 lb** (the value assumed July 29, 2026 and used in the mockup) when the order carries none — needs confirmation. Note the default exceeds the TKUP-2 capacity of 1,100 lb, so on FL2/FL3 the cap would govern.

Second part: if the operator does not acknowledge the 100% notification, live weight keeps climbing past target. Should the notification escalate to a distinct **over-target** state (proposed as milestone M4, red, "over by *n* lb"), or continue showing "target reached" with a percentage above 100? Depends on **Q58** for the authoritative weight source.

---

**Q61** · `Medium` · Owner: Tim O. / Jaspreet · `Open`
**Does the completion alert ladder apply to finished coils at TKUP-2 (FL2 / FL3)?**

The 75 / 90 / 100 ladder was specified for spool creation at FL1 TKUP-1. FL2 and FL3 wind finished coreless coils at TKUP-2 (1,100 lb) with the same "approaching target weight" concern. Should the same notification run there with "coil" wording and the coil target weight? If yes, note that FL2 standalone broadcasts `null` live gauge/width, so its lb/ft factor must come from the pass schedule / order rather than live measurement.

---

**Q62** · `Medium` · Owner: Tim O. / IT · `Open`
**Supervisor mirroring and audit persistence of milestone acknowledgements**

Is the spool completion alert an operator-only notification, or is it also surfaced to the supervisor (Dashboard 1 line status / Operations Manager view) — particularly an **unacknowledged** 100% milestone, which indicates nobody is at the machine as the spool fills? And where does the acknowledgement audit record live: a new milestone/acknowledgement table hanging off `FlatWireRun`, or an entry in the existing run-event stream?

---

**Q63** · `High` · Owner: Engineering / Tim O. · `Open`
**`FL{n}.LineState` state vocabulary, stop-dwell value, and pause-reason suppression**

Part B of [SpoolCompletionNotification.md](SpoolCompletionNotification.md) conditions the spool-removal popup on the PLC confirming a `RUNNING → STOPPED` transition, using the same `FL{n}.LineState` tag the system already reads as the rod-checkout gatekeeper. Three specifics are needed before it can be built:

1. **The tag's actual state vocabulary** — is it a two-state run/stop bit, or does it distinguish `RUNNING / STOPPED / PAUSED / FAULT / THREADING / JOG`? A jog or thread state that reports as STOPPED changes the filtering required.
2. **Dwell time** — how long must STOPPED persist before the stop is treated as real? Proposed default **5 seconds**, with speed ≈ 0 as corroboration. Needs a value from someone who knows how the drives behave on slow-down.
3. **Pause-reason suppression** — if the operator already used the software Pause dialog and captured a reason (die change, weld prep, break), should the popup be suppressed because the reason is already known? Proposed yes, unless the reason indicates spool removal.

---

**Q64** · `Medium` · Owner: Tim O. / IT · `Open`
**Stop-confirmation popup — supervisor visibility and multi-operator arbitration**

Is the spool-removal confirmation strictly an operator-at-the-HMI decision, or does the supervisor see that a prompt is pending (particularly one left unanswered with the line stopped at target, which means production is halted with no transaction recorded)? And with several operators signed in on the shared screen, does the prompt appear once per line with first-answer-wins (proposed), or per operator session? The answering operator is recorded on the audit record either way.

---

**Q65** · `Medium` · Owner: Tim O. / Operations · `Open`
**Short-close path — closing a spool below target weight**

The stop-confirmation popup is armed only at or above target weight, so a spool the operator wants to close **early** — order satisfied, rod exhausted, quality problem, end of campaign — gets no prompt. Is a short close a real operational case, and if so should stopping below target also prompt (with a reason code and a partial-spool alpha), or should it stay a purely manual action the operator initiates? This overlaps the partial-spool handling already discussed in **Q47** and [PartialRodReCheckin.md](PartialRodReCheckin.md).

---

**Q66** · `High` · Owner: Tim O. / Shannon R. · `Open`
**Scale-vs-calculated spool weight — tolerance, default basis, and approval authority**

The spool completion step now captures a **scale weight** (gross) alongside the **system-calculated** net (footage × cross-section × density) and asks the operator which to record ([SpoolCompletionNotification.md](SpoolCompletionNotification.md) Part B, rules S-16…S-21). Four points need a decision:

1. **Variance tolerance** — proposed **±2 %** of the calculated weight, matching the spirit of the existing scale-vs-vendor check at rod receiving. What is the real acceptable spread on a ~2,000 lb spool?
2. **Default basis** — proposed: the **scale reading wins** once entered (a weighing outranks a derivation), operator able to override to calculated. Confirm that is right for FL1, and whether it also holds for finished coils at TKUP-2.
3. ~~**Out-of-tolerance authority**~~ — **DECIDED (July 29, 2026):** an out-of-tolerance variance must **not** stop the operator from creating the spool. The completion is **authorised, not blocked**: a **supervisor override** (reason + supervisor badge/ID + PIN) appears and the commit control stays enabled, with a remote-approval fallback when no supervisor is on the floor. The override, the authorising supervisor and the reason are recorded on the spool. Still to confirm: whether the PIN is validated against the existing login/authorisation service or a separate supervisor credential store.
4. **Is a scale even available at the take-up?** The weigh-at-payoff question is already open in **Q47**; the same uncertainty applies here. If there is no scale at TKUP-1, the capture is optional and the calculated weight stands — but then **Q58**'s formula never gets validated against measured data.

Directly related: **Q58** (OD → weight conversion formula) — accumulated scale-vs-calculated variances are the data that would settle it.

---

### Section F — Die Change and SPC

---

**Q56** · `Medium` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**"Require SPC on resume" override authority and die change flow**

**Decision (May 4, 2026):**
- For Gauge drift and Size change die replacements, thread mode (slow running without full production) is allowed until SPC has been completed. This ensures the correct die has been installed and is seated properly before committing to production footage.
- After Confirm die change, the system should route to the SPC Checkpoint screen instead of directly back to the Active Run Dashboard.
- The run should remain in a blocked/paused state until SPC passes.
- The "Require SPC on resume" toggle should be pre-checked ON for Gauge drift and Size change reasons, and the system should enforce this routing.

---

### Section G — Planning & UI Decisions (Apr 28, 2026)

---

**Q58** · `High` · Owner: Tim O.
**OD/diameter → weight conversion formula for spool**
When a spool is measured by outer diameter at the takeup, how is the remaining weight calculated? The formula (using OD, ID, coil width, and alloy density) must be confirmed by Tim O. and documented before spool weight tracking and "assign as-is" stock handling logic can be implemented. Weight distribution is tracked via footage and revolutions per the Apr 28 planning decision, but the OD-based verification formula is still needed.

---

**Q59** · `Medium` · Owner: IT / Team
**Planning: flat wire orders in existing grid vs new dedicated section**
For flat wire orders in the planning screen, should they appear in the existing planning grid with column renames ("Coil No" → "Coil/Bundle ID", "Gauge" → "Gauge/Diameter", PIW auto-calculated and display-only) and a filter dropdown (All / Back-to-back / Flat Wire), or should flat wire jobs be isolated in a new flat-wire-specific planning view? The team agreed to finalize this decision internally. The choice affects UI scoping, test coverage, and how non-flat-wire planning logic is protected from disruption.

---

## Change Log

| Date | Changed By | Description |
|------|-----------|-------------|
| Apr 23, 2026 | Plan team | Initial register created from FlatWirePlan.md; 46 questions captured |
| Apr 27, 2026 | Analysis team | Added Q47–Q57 from RodCheckout.md, PassScheduleManagement.md, Spool.md, and DieChange.md analysis; total now 57 |
| Apr 28, 2026 | Analysis team | Updated Q51 and Q52 to reflect dashboard changes: selection mechanism (attribute-based lookup + confirm bar) now shown in dashboards 2, 5, FL3; unified pass schedule approach now implied by FL3 check-in. Residual open points scoped: Q51 = no-match notification path; Q52 = FL2 check-in validation for hybrid-origin spools. Q53 and Q54 remain fully open. |
| Apr 28, 2026 | MOM — Planning & Shopfloor meeting | **Q32 Decided**: max finished coil weight = 1,000 lb (TKUP-2 limit); orders split into multiple stops with alphas generated at planning time. Added **Q58** (OD → weight conversion formula, Tim O. to share) and **Q59** (planning grid vs new flat-wire section, team to decide internally). Key decisions recorded: alpha generation at planning (not execution); stop/calculation logic system-driven; pattern visualization replaced with tabular order → spool → weight grid; three spool-to-order allocation scenarios confirmed; "assign as-is" stock checkbox added; routing retains Add Operation with no child coil hierarchy; fully digital traveler (printing disabled for flat wire). Total questions: 59. |
| May 4, 2026 | Analysis team — Tim O. review | **Q27 Decided**: five-case alpha-handling rules confirmed (same-spec swap = single alpha; size change / edge type / roll gap to new target = new child alpha; AGC roll gap adjustment = single alpha, no change). **Q28 Decided**: four-step pass schedule override flow confirmed; operator read-only except one-for-one same-size die swap. **Q29 Decided**: unplanned component bypass event confirmed as distinct transaction; alpha split, supervisor acknowledgment, and pre-bypass material disposition all required. **Q30 In Progress**: roll gap validation approach deferred pending engineering confirmation. **Q31 In Progress**: OD/ID limits from both UA equipment and customer; Tim to provide specifics. **Q32 Updated**: TKUP-2 capacity revised to 1,100 lb (up from 1,000 lb stated Apr 28). **Q33 Decided**: no separator capability; no interleave field required. **Q39 Decided**: camber SPC feature conditional on customer specification. **Q40 Decided**: edge burr not currently measured; no implementation required. **Q41 Decided**: system-level die footage tracking confirmed; unique die IDs; threshold deferred until failure data available. **Q44 Decided**: line speeds unknown; determined by trial; table-driven design. **Q45 Decided**: FL1/FL2 independent simultaneous operation confirmed; throughput ratio 3:1; FL3 blocks FL1 and FL2. **Q47 In Progress**: multiple partial spool alphas confirmed needed; weigh-at-payoff scale question open (Scott/Bob/Shannon); carry-forward design deferred. **Q48 Decided**: supervisor approval required for mid-run checkout. **Q49 In Progress**: PLC tag behavior deferred pending engineering confirmation. **Q50 Decided**: supervisor must approve partial-run disposition; notification-driven remote approval model confirmed. **Q54 Decided**: pass schedule data not on label; logged for technical traceability. **Q55 Decided**: anneal modifies existing alpha; no FL1 re-pass capability for spools. **Q56 Decided**: thread mode allowed until SPC complete post die change; system routes to SPC Checkpoint screen for gauge drift and size change cases. **Q57 In Progress**: spool unique IDs confirmed (like furnace plates); tracking workflow FL1→furnace→cooling→FL2 confirmed; full state machine transitions still TBD. **Q10 In Progress**: FL3 cannot run if orders scheduled on FL1 or FL2 (partial decision from Q45). |
| Jul 28, 2026 | Analysis team | Added **Q60–Q62** from the spool completion alert requirement ([SpoolCompletionNotification.md](SpoolCompletionNotification.md)): target weight source and over-target behavior, applicability to finished coils at TKUP-2, supervisor mirroring and acknowledgement audit persistence. Total questions: 62. |
| Jul 29, 2026 | Analysis team | Q60 updated with the assumed **2,000 lb** default target spool weight. Added **Q63–Q65** from the machine-stop confirmation requirement (Part B of [SpoolCompletionNotification.md](SpoolCompletionNotification.md)): `FL{n}.LineState` vocabulary + stop dwell + pause-reason suppression, supervisor visibility and multi-operator arbitration of the prompt, and the short-close-below-target path. Total questions: 65. |
| Jul 29, 2026 | Analysis team | Added **Q66** — scale-vs-calculated spool weight reconciliation on the completion step: variance tolerance (±2 % proposed), which weight is the default basis, whether an out-of-tolerance variance needs supervisor approval rather than just a reason, and whether a scale exists at the take-up at all (overlaps Q47, feeds Q58). Total questions: 66. |
| Jul 29, 2026 | Client direction | **Q66 part 3 Decided**: an out-of-tolerance spool weight must not block spool creation — the completion is authorised by a **supervisor override** (reason + badge/ID + PIN, remote-approval fallback) and the override is recorded on the spool. Q66 now In Progress; tolerance value, default basis, scale availability and PIN validation source remain open. |
