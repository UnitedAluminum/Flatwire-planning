# Flat Wire Mill — Open Questions Register

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 30, 2026
**Total Questions:** 75 · **Shopfloor scope:** 48
**Status Legend:** `Open` · `In Progress` · `Decided` · `Deferred`
**Scope Legend:** `Shopfloor` — Flat Wire Mill shopfloor changes · `Other` — adjacent modules

> Questions marked **Critical** must be resolved before development begins on the dependent module.
> Questions marked **High** must be resolved before July 1 trials.
> Questions marked **Medium** must be resolved before August 1 production.
> Questions marked **Low** can be resolved post go-live.

---

## Shopfloor Scope — Filtered Index

**48 of 75 questions relate to Flat Wire Mill shopfloor changes** — the operator execution screens (Dashboards 1–14+) plus the reference data, equipment limits and validation rules those screens consume. The remaining 27 belong to adjacent modules (orders/quotes, pricing, costing, planning, scheduling, receiving, certification, maintenance) and are retained here marked `Scope = Other`.

**Nothing is filtered out by deletion.** The Change Log at the foot of this file cites question numbers throughout, and `OQ-##` references point inbound from the phase files, [REVIEW.md](../DevelopmentPlan/REVIEW.md) and the master specification. The numbering must stay contiguous, per the register convention in [CLAUDE.md](../CLAUDE.md).

**Filter rule applied:** a question is `Shopfloor` if a shopfloor screen **reads it, validates against it, or writes it**. That keeps reference data and equipment limits in scope (Q32 coil weight, Q36 footage-to-weight, Q38 tolerance bands, Q41 die life) and leaves scheduling representation (Q10), pre-scheduling validation (Q53) and order-entry behaviour (Q9, Q11, Q12) out, even where they touch flat wire.

### Shopfloor — Open / In Progress (35)

| Priority | Questions |
|---|---|
| `Critical` | **Q1** pass schedule UI · **Q14** traveler fields per station · **Q15** FL2 spool check-in identifier · **Q36** footage-to-weight factor · **Q51** pass schedule selection at check-in · **Q52** FL3 hybrid schedule + FL2 validation · **Q67** pre-check-in coil status |
| `High` | **Q16** skid labeling rules · **Q21** cert traceability granularity · **Q22** weld footage attribution · **Q23** max weld joints per coil · **Q30** roll gap validation *(IP)* · **Q38** published tolerance bands · **Q47** partial-rod re-check-in *(IP)* · **Q49** PLC tags on checkout *(IP)* · **Q57** spool state machine *(IP)* · **Q58** OD→weight formula · **Q60** target spool weight source · **Q63** `FL{n}.LineState` vocabulary · **Q66** scale-vs-calculated weight *(IP)* · **Q68** pre-check-out approval · **Q71** rod diameter tolerance column · **Q72** failed-inspection row *(IP)* · **Q74** staging overrides *(IP)* · **Q76** FL1/FL3 bay uniqueness |
| `Medium` | **Q24** rework weld on cert · **Q42** edger blade profiles · **Q61** TKUP-2 alert ladder · **Q62** supervisor mirroring · **Q64** stop-popup arbitration · **Q65** short-close path · **Q69** future-order staging · **Q70** `RodSeqno` scope · **Q73** FL3 WIP station · **Q75** VPS bundle stacking · **Q77** welded-rod release (`WLD011`) |
| `Low` | **Q8** WIP REJ report columns |

### Shopfloor — Decided (13)

**Q4** SCADA chart layout *(May 15)* · **Q27** mid-run alpha handling *(May 4)* · **Q28** pass schedule override authority *(May 4)* · **Q29** component failure protocol *(May 4)* · **Q32** max finished coil weight *(Apr 28)* · **Q39** camber *(May 4)* · **Q40** edge burr *(May 4)* · **Q41** die life tracking *(May 4)* · **Q48** mid-run checkout authorisation *(May 4)* · **Q50** partial-run disposition *(May 4)* · **Q54** pass schedule ID on cert record *(May 4)* · **Q55** spool alpha through anneal *(May 4)* · **Q56** SPC on resume *(May 4)*

### Out of shopfloor scope (27)

**Q2** pricing · **Q3** costing codes · **Q5** standard times · **Q6** throughput rates · **Q7** baler dimensions · **Q9** Finish field lock · **Q10** FL3 scheduling representation · **Q11** bundle width range · **Q12** edge critical attribute · **Q13** scrap banding · **Q17** rod receiving label · **Q18** rod inventory type · **Q19** rod storage location · **Q20** anneal rules timeline · **Q25** C of C frequency · **Q26** tolled cert liability · **Q31** coil OD/ID limits · **Q33** oscillation interleave · **Q34** twist and torsion · **Q35** metallic yield per route · **Q37** yield loss factor · **Q43** roll regrind · **Q44** line speed range · **Q45** FL1/FL2 simultaneous operation · **Q46** anneal furnace capacity · **Q53** pre-scheduling validation · **Q59** planning grid layout

---

## Quick Reference — Decision Log

| # | Question (Short) | Scope | Priority | Owner | Status | Decided Date |
|---|-----------------|-------|----------|-------|--------|--------------|
| 1 | Pass Schedule UI vs. table management | `Shopfloor` | Critical | Tim O. | Open | |
| 2 | Pricing auto-population mechanism | `Other` | High | Sales / Tim O. | Open | |
| 3 | Costing standards and industry codes | `Other` | High | Jeff G. / Tim O. | Open | |
| 4 | SCADA chart layout owner and timeline | `Shopfloor` | High | UA (Tim O.) | Decided | May 15, 2026 |
| 5 | Standard times for FL1/FL2/FL3 | `Other` | High | Tim O. / Jeff G. | Open | |
| 6 | FL1/FL2/FL3 output throughput rates | `Other` | Medium | Bob S. | Open | |
| 7 | Baler maximum dimensions | `Other` | Low | Plant / Tim O. | Open | |
| 8 | WIP REJ report column definitions | `Shopfloor` | Low | Shannon R. | Open | |
| 9 | Finish field lock — temporary or permanent | `Other` | Medium | Tim O. | Open | |
| 10 | FL3 scheduling representation | `Other` | Critical | Tim O. / Stephen | In Progress | |
| 11 | Bundle Width range determination | `Other` | High | Sales / Tim O. | Open | |
| 12 | Edge critical attribute default logic | `Other` | Medium | Tim O. / Technical | Open | |
| 13 | Scrap banding material | `Other` | Low | Tim O. / Plant | Open | |
| 14 | Traveler screen fields per station | `Shopfloor` | Critical | Jaspreet / Tim O. | Open | |
| 15 | FL2 spool check-in identifier | `Shopfloor` | Critical | Jaspreet / Tim O. | Open | |
| 16 | Coreless coil skid labeling rules | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 17 | Rod receiving label format | `Other` | High | Tim O. / Darlene | Open | |
| 18 | Inventory type for rods in coils table | `Other` | Critical | Tim O. / Jeff G. | Open | |
| 19 | Rod storage system-side location tracking | `Other` | Medium | Naj / Chuck | Open | |
| 20 | Anneal rules for rod/wire timeline | `Other` | High | Dan F. | Open | |
| 21 | Traceability granularity for certs | `Shopfloor` | High | Tim O. / Mick | Open | |
| 22 | Weld attribution on output footage | `Shopfloor` | High | Jaspreet / Tim O. | Open | |
| 23 | Max weld joints per finished coil | `Shopfloor` | High | Tim O. / Sales | Open | |
| 24 | Rework weld traceability on cert | `Shopfloor` | Medium | Tim O. / Mick | Open | |
| 25 | C of C frequency — per coil/order/heat | `Other` | High | Tim O. / Mick | Open | |
| 26 | Tolled flat wire cert liability | `Other` | Medium | Tim O. / Legal | Open | |
| 27 | Mid-run pass schedule change — alpha handling | `Shopfloor` | Critical | Jaspreet / Tim O. | Decided | May 4, 2026 |
| 28 | Pass schedule override authority and logging | `Shopfloor` | High | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 29 | Component failure mid-run protocol | `Shopfloor` | High | Tim O. / Plant | Decided | May 4, 2026 |
| 30 | Roll gap validation before run start | `Shopfloor` | High | Jaspreet / Tim O. | In Progress | |
| 31 | Coreless coil OD/ID limits | `Other` | High | Tim O. / Sales | In Progress | |
| 32 | Maximum finished coil weight | `Shopfloor` | High | Tim O. / Bob S. | Decided | Apr 28, 2026 |
| 33 | Oscillation layer interleave material | `Other` | Medium | Tim O. / Sales | Decided | May 4, 2026 |
| 34 | Twist and torsion tolerance for welding wire | `Other` | High | Tim O. / Technical | Open | |
| 35 | Expected metallic yield per route | `Other` | Critical | Tim O. / Jeff G. | Open | |
| 36 | Footage-to-weight conversion factor | `Shopfloor` | Critical | Tim O. / Bob S. | Open | |
| 37 | Yield loss factor for planning rod input | `Other` | High | Tim O. / Margo | Open | |
| 38 | Published tolerance bands (ASTM / customer) | `Shopfloor` | High | Tim O. / Mick | Open | |
| 39 | Camber and flatness limits | `Shopfloor` | Medium | Tim O. / Technical | Decided | May 4, 2026 |
| 40 | Edge burr height limit and measurement | `Shopfloor` | Medium | Tim O. / Technical | Decided | May 4, 2026 |
| 41 | Die life tracking — system or manual | `Shopfloor` | Medium | Tim O. / Maintenance | Decided | May 4, 2026 |
| 42 | Edger blade profiles — standard or custom | `Shopfloor` | Medium | Tim O. / Maintenance | Open | |
| 43 | Roll regrind, spare inventory, tracking | `Other` | Medium | Tim O. / Maintenance | Open | |
| 44 | Line speed range per alloy/gauge | `Other` | High | Tim O. / Bob S. | Decided | May 4, 2026 |
| 45 | FL1 and FL2 simultaneous independent operation | `Other` | Critical | Tim O. / Stephen | Decided | May 4, 2026 |
| 46 | Shared anneal furnace capacity for flat wire | `Other` | High | Dan F. / Tim O. | Open | |
| 47 | Partial-rod re-check-in and traceability carry-forward | `Shopfloor` | High | Jaspreet / Tim O. | In Progress | |
| 48 | Mid-run rod checkout authorisation level | `Shopfloor` | High | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 49 | PLC tag behaviour on rod checkout | `Shopfloor` | High | Jaspreet / Tim O. | In Progress | |
| 50 | Partial-run material disposition authority | `Shopfloor` | High | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 51 | Pass schedule selection mechanism at check-in | `Shopfloor` | Critical | Tim O. / Jaspreet | Open | |
| 52 | FL3 hybrid pass schedule — one or two schedules? | `Shopfloor` | Critical | Tim O. / Jaspreet | Open | |
| 53 | Pass schedule validation during planning/scheduling | `Other` | Medium | Tim O. / Stephen | Open | |
| 54 | Pass schedule ID on coil completion and cert record | `Shopfloor` | High | Tim O. / Mick | Decided | May 4, 2026 |
| 55 | Spool alpha continuity through anneal or re-pass | `Shopfloor` | High | Tim O. / Jaspreet | Decided | May 4, 2026 |
| 56 | "Require SPC on resume" override authority | `Shopfloor` | Medium | Tim O. / Shannon R. | Decided | May 4, 2026 |
| 57 | Spool status state machine — all valid transitions | `Shopfloor` | High | Tim O. / Jaspreet | In Progress | |
| 58 | OD/diameter → weight conversion formula for spool | `Shopfloor` | High | Tim O. | Open | |
| 59 | Planning: flat wire orders in existing grid vs new dedicated section | `Other` | Medium | IT / Team | Open | |
| 60 | Target spool weight source for the completion alert + over-target behavior | `Shopfloor` | High | Tim O. / Operations | Open | |
| 61 | Does the spool completion alert ladder apply to finished coils at TKUP-2 (FL2/FL3)? | `Shopfloor` | Medium | Tim O. / Jaspreet | Open | |
| 62 | Supervisor mirroring and audit persistence of milestone acknowledgements | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 63 | `FL{n}.LineState` vocabulary, stop-dwell value, and pause-reason suppression | `Shopfloor` | High | Engineering / Tim O. | Open | |
| 64 | Stop-confirmation popup — supervisor visibility and multi-operator arbitration | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 65 | Short-close path — closing a spool below target weight | `Shopfloor` | Medium | Tim O. / Operations | Open | |
| 66 | Scale-vs-calculated spool weight — tolerance, default basis, approval authority | `Shopfloor` | High | Tim O. / Shannon R. | In Progress | |
| 67 | Pre-check-in coil status — `INFLAT` (SRS) or `STAGED` (walkthrough), and what reverses it | `Shopfloor` | Critical | Tim O. / IT | Open | |
| 68 | Does pre-check-out (un-staging) require supervisor approval? | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 69 | Can a rod be pre-checked-in against a future order, or only the current one? | `Shopfloor` | Medium | Tim O. / Planning | Open | |
| 70 | `RodSeqno` scope — per line, per order, or global | `Shopfloor` | Medium | IT / Team | Open | |
| 71 | Rod diameter tolerance (`CHK007`) has no column anywhere in the schema | `Shopfloor` | High | Tim O. / IT | Open | |
| 72 | Does a failed staging inspection persist a `RodStaging` row, or is nothing written? | `Shopfloor` | High | Tim O. / IT | Open | |
| 73 | Which WIP station does FL3 pre-check-in post to? There is no `FL3PO` | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 74 | Staging overrides — off-schedule + out-of-sequence, PIN source, and the mid-order case | `Shopfloor` | High | Tim O. / Shannon R. | In Progress | |
| 75 | Can multiple rod bundles be stacked on one VPS position? Bundle weight stated as both 2,000 lb and 8,780 lb | `Shopfloor` | Medium | Tim O. / Bob S. | Open | |

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

**Q67** · `Critical` · Owner: Tim O. / IT · `Open`
**Pre-check-in coil status — `INFLAT` or `STAGED`, and what reverses it**

Two delivered documents disagree about what happens to the shared coil record when a rod is pre-checked-in at the payoff:

- **SRS §4.2** (`PCI` data note) has pre-check-in performing the `FlatwireQueue` insert (`Rodno`, `RodSeqno`, `Welded`), setting `proddb..coils.coil_status = INFLAT`, and doing the reqsum + `wip_coil_orders` insert — i.e. the material is **committed** as soon as it is queued.
- **[FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) step 8** has it as `RECEIVED → STAGED`, with `INFLAT` arriving later at check-in.

The interim design follows the SRS and treats the two as orthogonal — `RodStaging.Status` is bay occupancy, `coils.coil_status` follows the SRS — which makes rod status `STAGED` effectively vestigial for FL1. Three things need confirming:

1. Does pre-check-in really commit the material to `INFLAT`, or should the shared status stay `STAGED` until acknowledgement?
2. If `INFLAT`: pre-check-out must **reverse** the `wip_coil_orders` insert and reqsum. Is that reversal safe for planning, and does it leave any trace planners need to see?
3. If `STAGED`: does anything downstream (planning availability, WIP queue, traveler) actually need the material committed at staging time — which is presumably why the SRS specified `INFLAT` in the first place?

This is **Critical** because staging writes cross database boundaries and are **compensating writes, not one transaction** (gaps G2/G16) — the more state pre-check-in commits, the more there is to unwind correctly. Blocks the Phase 4 staging build. Detail in [RodPreCheckin.md](RodPreCheckin.md).

---

**Q68** · `High` · Owner: Tim O. / Shannon R. · `Open`
**Does pre-check-out (un-staging) require supervisor approval?**

**Q48** decided that a **mid-run** checkout (footage > 0) requires supervisor approval, because footage has been produced and material must be dispositioned. Pre-check-out is the opposite end of the scale: the rod was never checked in, no pass schedule was acknowledged, no PLC tags were pushed and no footage exists — so the interim design allows **operator-only** un-staging.

Confirm that is right. The counter-argument is inventory discipline rather than material risk: un-staging returns a bundle to the floor or warehouse and reverses a WIP queue entry, and a mis-scan corrected quietly leaves no supervisor visibility. If approval *is* wanted, is it a blocking gate (as in Q50's notification-driven remote model) or an after-the-fact notification?

Related: pre-check-out has **no SRS requirement ID at all** — §4.17 covers only post-check-in removal. A new `PCI`-series requirement block is needed regardless of how this is decided.

---

**Q69** · `Medium` · Owner: Tim O. / Planning · `Open`
**Can a rod be pre-checked-in against a future order, or only the current one?**

Dashboard 2A stages a rod against an `OrderId`. In the continuous-feed case that is the order already running, but the physical workflow does not require it: an operator could stage the first bundle of the *next* job on the idle bay near the end of a campaign. Is that allowed, and if so:

- Does the weld-selection surfacing (`PCI008`) need to exclude a staged rod belonging to a different order, since welding rod from one order into another would break coil genealogy?
- Should `Mark as Welded` be blocked outright when the staged rod's order differs from the running order — over and above the existing alloy/temper/diameter match check (`WLD006`)?

**Leaning toward "no" (Jul 29, 2026).** The free-processing-order requirement specifies that staging validates the rod *"belongs to the **current** production order"* — singular. Scoped that way, a future-order rod is not a staging candidate at all, and the `PCI008` genealogy concern above resolves itself because cross-order material never reaches the bay.

Not treated as decided, because that requirement is about *processing order within* an order and does not address the cross-order case head-on. Two consequences need confirming before it closes:

1. **Continuous feed cannot cross an order boundary.** The last rod of order A cannot be welded to the first rod of order B. Probably correct — the pass schedule may change between orders anyway, so the line would stop regardless — but it should be confirmed, not discovered on the floor.
2. If the answer is genuinely "current order only", the interim design is already right and the `Available` projection needs no change. If future-order staging is later allowed, `PCI008` weld selection must exclude cross-order rod explicitly.

---

**Q70** · `Medium` · Owner: IT / Team · `Open`
**`RodSeqno` scope — per line, per order, or global**

The SRS `FlatwireQueue` model carries `RodSeqno` alongside `Rodno` and `Welded`, and it drives the ordering of the Traveler Queue section (`TRV004`). Its scope is not stated: is the sequence numbered within a line, within an order, or globally across flat wire? The choice determines whether numbers restart (and when), whether two lines can show the same `Seq 2`, and whether the queue ordering survives an order change.

**Partly resolved (Jul 29, 2026).** The requirement to retain **both** the planned and the actual sequence — planned for planning and reporting, actual in the transaction history for traceability — showed the original framing was too narrow: the question was never only "what is the scope", it was "**which of two sequences is this field**". A single `RodSeqno` could not answer that, and the ambiguity was a live defect rather than a deferred decision.

> **Superseded in part (Jul 30, 2026).** The first version of that requirement also said planned order was *not enforced at all* — the operator free to re-sequence with no warning and no override. That is **replaced** by the notify-and-authorise rule in **Q74**: departing from the planned order is permitted, but the operator is notified and a **supervisor authorises** it. The two-sequence data model is unaffected — both columns stay, for exactly the reasons above.

Applied: `RodStaging.RodSeqno` is the **actual** processing sequence, assigned server-side at pre-check-in (consistent with the SRS inserting `FlatwireQueue` at pre-check-in, and with the column already being `NOT NULL`), **monotonic per line**. A new `RodStaging.PlannedSeqno int NULL` snapshots the planned position at staging time, nullable for a rod with no planned position. `GET /staging/queue` returns `rodSeqno: null` on `Available` rows.

Still to confirm:

1. **Per line** is the interim choice for `RodSeqno` scope. Per *order* would restart numbering at each order boundary, which reads more naturally on a traveler but makes two concurrent orders on one line show duplicate positions. Per line avoids that at the cost of ever-growing numbers — does it need a reset point (per shift, per campaign, per order)?
2. Does `PlannedSeqno` scope per order (the natural reading, since planning generates stops per order), and should it be displayed as `3 of 5` rather than a bare ordinal?
3. Should un-staging **release** the actual position for reuse, or leave a gap? The interim design releases it, since the rod was never processed — but that means the same number can be issued twice, which a traceability audit may object to.

---

**Q71** · `High` · Owner: Tim O. / IT · `Open`
**Rod diameter tolerance (`CHK007`) has no column anywhere in the schema**

`CHK007` requires the measured rod diameter to be validated against nominal **± a lookup tolerance**, at both pre-check-in (Dashboard 2A) and check-in (Dashboard 2). There is nowhere to read that tolerance from.

`AlloyProperty` carries `GaugeToleranceDefault` and `WidthToleranceDefault`, but those are **flat wire output** dimensions — the gauge and width the mill produces. Incoming rod diameter is a different measurement, and no column for its tolerance exists in `FlatWireDB` or in the shared `coils` schema. A search across `Schema/` returns gauge and width tolerances only.

As a result the Dashboard 2A mockup hard-coded a single `0.005"` for every alloy, which is wider than every value in the standards table in [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) (*Alloy Lookup Table*: 1100 → ± 0.003", 1350 → ± 0.002", 3003 → ± 0.004") — so out-of-tolerance rod would have been accepted. The mockup now reads a per-alloy map mirroring that table, but the map is mock data with no backing store.

To resolve:

1. Add `AlloyProperty.RodDiameterToleranceDefault` (or confirm the tolerance belongs on a rod-spec record rather than the alloy)?
2. Are the standards-table values authoritative, or do they need Process Engineering sign-off first? That table already carries the note *"must be confirmed and maintained by Process Engineering (Tim O.) — editable via an admin table, not hardcoded."*
3. Can tolerance vary by rod vendor or by nominal size within one alloy, or is per-alloy sufficient?

Blocks the Phase 4 check-in and staging validation. Detail in [RodPreCheckin.md](RodPreCheckin.md).

---

**Q72** · `High` · Owner: Tim O. / IT · `In Progress` — *items 1–2 decided Jul 31, 2026; items 3–4 open*

> **Decided (Jul 31, 2026) — items 1 and 2.** `Blocked` is **derived** (`Status = 'Staged'` + any inspection column `= 'Fail'`), not a fourth `Status` value; and pre-check-in **commits the `RodStaging` row before the inspection gate**. `POST /staging/rod` now returns `201 Created` with `state: "Blocked"` and the WIP-rejection route, replacing the `422`-and-write-nothing behaviour. The deciding argument is physical: bundles are not unbanded until positioned at the payoff — which is *why* the inspection happens at staging — so a rod that fails is **already on the bay**. Writing no row left `GET /payoff/status` reporting an occupied position as `NotStaged`, Dashboard 2A offering it as "Empty — available", and the next rod stageable into a bay that physically holds a rejected bundle. `CHK010` is unchanged: no bypass, WIP Rejection remains the only forward path. Contracts updated in [APIContracts.md](../DevelopmentPlan/APIContracts.md), [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md) and [phase-04](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md).
>
> **Item 3 is now the blocking residual** and is *not* answered by the above — see below.

**Does a failed staging inspection persist a `RodStaging` row, or is nothing written?**

Dashboard 2A and `GET /payoff/status` both expose a **`Blocked`** bay state, defined as *"inspection failed at staging"*. `RodStaging.Status` has no such value — it is only `Staged | CheckedIn | Unstaged`.

The state *is* derivable: the three inspection columns are `NOT NULL` `Pass`/`Fail`, so a blocked bay is `Status = 'Staged'` with any inspection column `= 'Fail'`. That reading is also the correct one operationally, because `UX_RodStaging_Bay` is filtered on `Status = 'Staged'` — the failed bundle is still physically in the bay and must keep it occupied. But no artifact states this, and the alternative (a fourth status value) would change the filtered index.

The sharper problem is that **nothing currently writes the row**. On a failed inspection the wizard is a hard block with no bypass (`CHK010`) and the only forward action is a link to WIP Rejection, so the staging record is never committed and the inspection evidence is lost at navigation. The `Blocked` state is therefore unreachable in practice.

To resolve:

1. Confirm `Blocked` is **derived** (`Staged` + any `Fail`) rather than a fourth `Status` value.
2. Does pre-check-in commit a `RodStaging` row *before* routing to WIP Rejection, so the failure and its observation are persisted and the bay reads BLOCKED?
3. **(Now blocking.)** What releases that row — a pre-check-out (`ModeP`), or does the WIP rejection itself un-stage it? `Status` has only `Staged | CheckedIn | Unstaged`, and `CK_RodStaging_Unstaged` ties `Unstaged` to the pre-check-out column group, so a WIP-rejection outcome has **no status to land in**. A fourth value would have to change the vocabulary, the constraint *and* `UX_RodStaging_Bay`'s filter together — and anything outside `Status = 'Staged'` frees a bay that is not physically free. Deliberately not invented. **Until this is answered a blocked bay is enterable but not clearable.**
4. `InspectionNotes` is nullable but documented as *"expected when any item fails."* Should it be enforced NOT NULL when any item is `Fail`, matching the constraint style already used for the welded/unstaged/checked-in column groups?

**Two untraced consequences of the item-2 decision**, recorded rather than resolved: `RodStaging` now holds rows for material that was never accepted, which affects the **`TRV009`** traveler (is `Blocked` a third class alongside pre-checked-in and welded?); and the **`Available`** queue projection must exclude rods sitting blocked, or a rejected bundle reappears as stageable.

Related to `CHK010` and gap **G14**. Detail in [RodPreCheckin.md](RodPreCheckin.md).

---

**Q73** · `Medium` · Owner: Tim O. / IT · `Open`
**Which WIP station does FL3 pre-check-in post to? There is no `FL3PO`**

The data model, DDL and API all scope staging to **FL1 and FL3** — `CK_RodStaging_LineId` allows `FL1` or `FL3`, and `/staging/**` rejects only `FL2` (`PCI002`). The WIP station seed does not match: [CommonDB_Insert_WIPStations_FlatWire.sql](../DevelopmentPlan/DBScripts/CommonDB_Insert_WIPStations_FlatWire.sql) creates `FL1PO`, deliberately omits `FL2PO`, and **never mentions `FL3PO`**. The SRS text is no help either — `PCI003` names a dedicated Pre-Check-In station for **FL1** only; FL3's inclusion is an inference from the fact that the hybrid line draws rod from the same VPS.

The Dashboard 2A mockup previously wrote `FL3PO` into the station stamp when the FL3 toggle was selected — a station code that exists nowhere. It now assumes FL3 posts to `FL1PO`, on the reading that FL3 *is* FL1 running hybrid into FL2, so there is one physical payoff and one station.

To confirm:

1. Is that reading right — one VPS shared between FL1 and FL3 modes, so `FL1PO` covers both?
2. If instead FL3 warrants its own station row, `FL3PO` must be seeded and the D2 note updated.
3. Either way, should staging rows record `LineId = 'FL3'` when the line is in hybrid mode, even though the station is `FL1PO`? That decides whether the Traveler Queue for FL3 is a distinct queue or the same one.

Detail in [RodPreCheckin.md](RodPreCheckin.md).

---

**Q74** · `High` · Owner: Tim O. / Shannon R. · `In Progress`
**Supervisor overrides at staging — off-schedule, out-of-sequence, PIN source, and the mid-order case**

**Decided (July 30, 2026) — out-of-planned-sequence.** The operator must be **notified** when the rod being checked in / pre-checked-in is not the one the planning system expects next, and a **supervisor override is required** to depart from the planned sequence. Same credential block as below: reason + badge/ID + PIN, remote-approval fallback, all recorded (`RodStaging.OutOfSequenceOverride` + `ExpectedRodAlpha`, sharing the credential stamp). "Expects next" is the lowest planned sequence still available, so a blocked bundle does not freeze the sequence behind it.

> This **supersedes** the earlier free-processing-order requirement, which had the operator re-sequencing at will with explicitly no warning and no override (see **Q70**). Both sequence columns are retained regardless — the deviation is now authorised *and* recorded.

**Decided (July 29, 2026) — off-schedule.** A rod whose order is scheduled on a **different line** is **not refused**. The operator is notified at pre-check-in / check-in that the order belongs to another line, and a **supervisor override** authorises staging it here. Following the pattern already decided in **Q66** part 3: reason + supervisor badge/ID + PIN, remote-approval fallback when no supervisor is on the floor. The override, the authorising supervisor and the reason are recorded on the staging record (`RodStaging.OffScheduleOverride` / `ScheduledLineId` / `OverrideBy` / `OverrideAt` / `OverrideReason`, all-or-nothing via `CK_RodStaging_OffSched`). The PIN is never stored.

Rod→order comes from **`planning_routings`**, so the order is *resolved* from the scan rather than chosen — which is what makes even the first rod on a cold line validatable.

Still to confirm:

1. **PIN validation source** — the existing login/authorisation service, or a separate supervisor credential store? Inherited unresolved from Q66; it now gates two overrides, so it should be settled once for both.
2. **The mid-order case is different and currently a hard refusal.** Once a line has an order established, a rod from *another* order is rejected outright rather than offered an override, because welding across orders breaks coil genealogy (see **Q69**, **Q72**). Is that right, or should a supervisor be able to authorise an order switch mid-run too — and if so, what happens to the weld?
3. **Does the same override apply at check-in (Dashboard 2)?** The decision says "checkin/precheckin", so Dashboard 2 needs the identical panel and the same columns on `RodCheckin`. Only Dashboard 2A carries it today.
4. **Does the scheduled line need updating** when an order is authorised to run elsewhere — i.e. should scheduling be corrected, or is the override purely a shop-floor exception that leaves the booking untouched? This affects whether the *next* rod of that order also triggers the override.
5. **Should an off-schedule run notify the other line's operator**, whose scheduled material has just been consumed elsewhere?

Detail in [RodPreCheckin.md](RodPreCheckin.md).

---

**Q75** · `Medium` · Owner: Tim O. / Bob S. · `Open`
**Can multiple rod bundles be stacked on a single VPS payoff position?**

Every artifact assumes exactly one bundle per bay — `UX_RodStaging_Bay` enforces it as a filtered unique index, and [RodPreCheckin.md](RodPreCheckin.md) calls "one rod per payoff bay" the whole point of a two-bay station. **Nothing states whether that is the equipment's limit or only the current modelling assumption.** Eye-to-sky is the payoff geometry in which stacking coils on a vertical spindle — tail of the upper bundle welded to the head of the one below — is standard wire-industry practice, so the assumption is worth confirming rather than inheriting.

**The resolving fact is the received bundle weight, and the delivered contracts state it two ways** against the 9,000 lb position rating in `PayoffPosition.MaxWeightLb`:

| Source | Rod gross weight | Bundles per 9,000 lb bay |
|---|---|---|
| `GET /payoff/status`, `GET /staging/queue`, `POST /staging/rod` | **8,690 – 8,840 lb** | **1** — no room to stack |
| `GET /rod/{alpha}`, `POST /checkin/rod` | **2,000 lb** | **4** — the rating is a multi-bundle figure |

Same `R#####` series, same 0.375" diameter, 4× apart. If bundles really are ~8,800 lb the question is closed by physics. If they are ~2,000 lb, a 9,000 lb *position* rating only makes sense as a stack rating — and operators will stack whether or not the software models it.

To confirm:

1. **What is the actual received rod bundle gross weight?** Needed regardless of stacking — the payoff weight bar and the weld alerts are calibrated to it (warning below **3,000 lb**, critical when the other bay is unstaged and this one is below **2,000 lb**). Against 2,000 lb bundles those thresholds are meaningless; against 8,800 lb they are correct. Whichever is right, one set of examples in [APIContracts.md](../DevelopmentPlan/APIContracts.md) is wrong and should be corrected.
2. **Does the VPS physically accept a stack** — separator plates, retaining cone, a depth limit — or is it one bundle per spindle by design?
3. If stacking is real, **when are the lower bundles unbanded and inspected?** The rule today is that a bundle is unbanded only once positioned at the payoff, and the derived `Blocked` state occupies the **whole bay** — a failed bundle underneath good ones cannot be removed without de-stacking.

**Schema consequences if the answer is yes.** Four things break, and one is worth pre-empting cheaply now:

- `UX_RodStaging_Bay` would need a **`StackPosition`** column — `(LineId, PayoffPosition, StackPosition) WHERE Status='Staged'` — and `PayoffPosition` a `MaxStackDepth` plus a summed-weight check against `MaxWeightLb`.
- **`CK_WeldEvent_PayoffDiff`** — "a bay cannot be welded to itself" — **rejects the in-stack weld outright**. The real invariant is that the two *rod alphas* differ, not the two bays. Relaxing it to that costs nothing, is correct under either answer, and it is the one constraint that would otherwise force a migration against live weld-genealogy data. A `WeldKind` (`InStack` | `BayHandover`) would keep handovers distinguishable in reporting.
- `PayoffWeight` is one scalar per bay, so a 3-high stack crosses the 3,000 lb warning only before the **last** bundle — the operator would get **no prepare-weld warning for the first two in-stack welds**. Thresholds would have to re-base onto the paying-off bundle, and the critical rule scoped to bay handovers or it fires spuriously.
- `FlatWireRunDetail.PayoffPositionId` and `CHECK (PayoffPosition IN (1,2))` survive unchanged — stacking is a slot *within* a position, not a new position.

**No SRS requirement covers stacking**, and it is not required for continuous operation — two alternating bays already deliver non-stop running (see [RodPreCheckin.md](RodPreCheckin.md)). Recommendation is therefore **not to build it**, but to settle item 1 before the Phase-4 schema freeze and relax `CK_WeldEvent_PayoffDiff` pre-emptively.

Related: **Q6** (throughput rates — the same equipment-data gap), **Q36** (footage-to-weight factor), **Q23** (max weld joints per coil — stacking multiplies welds per bay).

---

**Q76** · `High` · Owner: Tim O. / IT · `Open`
**Are FL1 and FL3 one physical pre-check-in station or two? `UX_RodStaging_Bay` currently permits two rods on one bay**

`UX_RodStaging_Bay` is a filtered unique index on **`(LineId, PayoffPosition) WHERE Status = 'Staged'`**, and `CK_RodStaging_LineId` admits **`FL1` and `FL3`**. So `(FL1, 1)` and `(FL3, 1)` are two distinct index entries.

If FL1 and FL3 share one physical VPS — which is the working assumption everywhere, including `STATION_BY_LINE = { FL1: "FL1PO", FL3: "FL1PO" }` in the Dashboard 2A mockup, and the whole reason `FL3PO` was never seeded (**Q73**) — then **two different rods can be `Staged` on the same physical payoff position with every constraint satisfied.** The invariant the table exists to enforce, "one rod per payoff bay" ([RodPreCheckin.md](RodPreCheckin.md) calls it *the whole point of a two-bay station*), does not hold across the FL1/FL3 pair.

This is a different defect from **G20**, which settled the *vocabulary* of payoff position (the `PayoffPosition` lookup and the `FlatWireRunDetail` FK). It did not settle the **uniqueness scope**.

The answer determines the fix, and the two are opposites:

| If… | Then |
|---|---|
| **One station** (FL3 is FL1 running hybrid — the current assumption) | Key the index on the **station**, not `LineId` — either index `FL1PO` directly or add a persisted station column. `CK_RodStaging_LineId` stays as-is; the mockup's `STATION_BY_LINE` is correct |
| **Two stations** | `FL3PO` must be seeded in `CommonDB_Insert_WIPStations_FlatWire.sql`, the index is already right, and the mockup's assumption is **wrong** |

Also unresolved by either answer: what the FL1/FL3 toggle on Dashboard 2A *means*. It currently relabels the badge, station stamp, queue heading and modal subtitle without reloading the bays or the queue — and because the off-schedule check reads the current line, toggling silently reclassifies already-staged rod as off-schedule with no visual change.

**Blocks the Phase-4 schema freeze.** Related: **Q73** (which station FL3 posts to — this is its data-model consequence), **Q75** (the other `UX_RodStaging_Bay` scope question), **G20**, **G21**.

---

**Q77** · `Medium` · Owner: Tim O. / Shannon R. · `Open`
**May a welded staged rod ever be released, and by whom? (`WLD011`)**

Mark-as-welded sets `RodStaging.IsWelded` on a `Staged` row — welded is a **flag, not a status**. Every control that acts on a "staged" bay therefore also matched a welded one, so until Jul 31 2026 the Dashboard 2A queue offered **Unstage** on a welded rod and the guard admitted it. That rod is physically induction-welded to the rod currently in the mill, so the pre-check-out modal's promise — *"the payoff bay is released and the rod returns to inventory"* — is not something that can happen.

The control has been removed from both the queue row and the bay card, and `openPreCheckout()` now rejects a welded bay. **That closes the button, not the question:**

1. Is there any legitimate need to reverse a weld record — mis-scan, wrong rod welded, weld failed after marking?
2. If so, is it a supervisor action (contrast **Q48** for mid-run checkout), and what does it write? `IsWelded` is guarded by `CK_RodStaging_Welded` (`WeldedAt`/`WeldedBy` set exactly when `IsWelded = 1`), so a reversal is a three-column clear plus an audit trail that does not exist yet.
3. `WLD011` — *supervisor reversal of a welded coil* — is listed in the SRS but **never specified**. It needs a requirement before it gets a control.

Until then there is deliberately **no UI path** to un-weld. Related: **Q48**, `WLD003`/`WLD010`.

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
| Jul 29, 2026 | Analysis team | Added **Q67–Q70** from the pre-check-in / payoff-staging build ([RodPreCheckin.md](RodPreCheckin.md)): coil status at staging (`INFLAT` per SRS §4.2 vs `STAGED` per the process walkthrough, and what reverses it — **Critical**, blocks the Phase 4 staging build), whether pre-check-out needs supervisor approval (contrast Q48 for mid-run), staging against a future order and its effect on weld selection, and the scope of `RodSeqno`. Also noted: pre-check-out has **no SRS requirement ID** — §4.17 covers only post-check-in removal, so a new `PCI`-series block is needed. Total questions: 70. |
| Jul 29, 2026 | Analysis team | Added **Q71–Q73** from the Dashboard 2A mockup review: rod diameter tolerance (`CHK007`) has **no column anywhere in the schema** — `AlloyProperty` carries only gauge/width, which are flat-wire *output* dimensions, so the mockup had hard-coded a single 0.005" that is wider than every value in the standards table; whether a failed staging inspection persists a `RodStaging` row at all, given that the UI/API `Blocked` bay state is derivable (`Staged` + any `Fail`) but nothing currently writes it; and which WIP station FL3 pre-check-in posts to, since the schema/DDL/API all scope staging to FL1 **and FL3** while only `FL1PO` is seeded and no `FL3PO` exists. Total questions: 73. |
| Jul 29, 2026 | Client requirement | **Free rod processing order.** Planned rod sequence is explicitly **not enforced** — the operator may process rods in any order; staging validates only current-order membership and availability, and must never block because an earlier-planned rod is unprocessed. Both sequences are retained: planned for planning/reporting, actual in the transaction history for traceability. **Q70 partly resolved** — reframed from "what is `RodSeqno`'s scope" to "which of two sequences is it"; `RodSeqno` is now the *actual* sequence and a new `RodStaging.PlannedSeqno` snapshots the planned one. **Q69 leaning "no"** — validation is scoped to the *current* order, which makes a future-order rod a non-candidate; not closed, because continuous feed then cannot cross an order boundary and that consequence needs confirming. |
| Jul 29, 2026 | Client direction | **Q74 added, part-decided.** Rod→order resolves from **`planning_routings`** at pre-check-in / check-in, so the order is *revealed* by the scan rather than chosen — which makes the first rod on a cold line validatable and removes the need for an order chooser. A rod whose order is scheduled on **another line** is **not refused**: the operator is notified and a **supervisor override** (reason + badge/ID + PIN, remote-approval fallback — the Q66 pattern) authorises it, with the override, supervisor and reason recorded on `RodStaging`. Still open: PIN validation source (shared with Q66), whether the mid-order cross-order case should also be overridable given the weld/genealogy constraint, applying the same panel at Dashboard 2, whether scheduling gets corrected, and whether the other line's operator is notified. |
| Jul 30, 2026 | Analysis team | Added **Q75** — whether multiple rod bundles can be **stacked on a single VPS payoff position**. Every artifact assumes one bundle per bay (`UX_RodStaging_Bay` enforces it as a filtered unique index), but nothing states whether that is the equipment's limit or a modelling assumption, and eye-to-sky is the geometry in which stacking is standard practice. The resolving fact — received bundle gross weight — is stated **two incompatible ways** in the delivered contracts: **8,690–8,840 lb** in `/payoff/status`, `/staging/queue` and `/staging/rod` versus **2,000 lb** in `/rod/{alpha}` and `/checkin/rod`, against a 9,000 lb position rating. That contradiction matters independently of stacking, because the payoff weight bar and the weld alerts (warn 3,000 lb / critical 2,000 lb) are calibrated to it. Recorded the four schema consequences if stacking is real, and flagged **`CK_WeldEvent_PayoffDiff`** as worth relaxing pre-emptively — it rejects an in-stack weld outright, and the real invariant is that the rod *alphas* differ, not the bays. Total questions: 75. |
| Jul 30, 2026 | Analysis team | **Scoped the register to shopfloor.** Added a `Scope` column to the Quick Reference table and a **Shopfloor Scope — Filtered Index** section at the top: **48 of 75** questions relate to Flat Wire Mill shopfloor changes (35 Open/In Progress, 13 Decided); the other 27 belong to adjacent modules and are marked `Other`. **Nothing was deleted** — this Change Log cites question numbers throughout, and `OQ-##` references point inbound from the phase files, `REVIEW.md` and the master specification, so the numbering must stay contiguous. Filter rule: `Shopfloor` if a Dashboard 1–14 screen reads, validates against or writes it — which keeps reference data and equipment limits in scope (Q32, Q36, Q38, Q41) and leaves scheduling representation (Q10), pre-scheduling validation (Q53) and order-entry behaviour (Q9, Q11, Q12) out. Also corrected the **Q4** Quick Reference row, which still read `Open` although its detail entry records it **Decided May 15, 2026**. |
| Jul 31, 2026 | Analysis team | **Q72 items 1–2 decided; Q76–Q77 added** from the Dashboard 2A UX review ([Dashboard2A_UXReview.md](Dashboard2A_UXReview.md)). **Q72:** `Blocked` confirmed **derived**, and pre-check-in now **commits the `RodStaging` row before the inspection gate** — `POST /staging/rod` returns `201` with `state: "Blocked"` instead of `422`-and-write-nothing. The deciding argument is physical: a bundle is not unbanded until it is on the payoff, so a rod that fails inspection is already in the bay, and writing no row made `GET /payoff/status` report an occupied position as `NotStaged` and let the next rod be staged into it. `CHK010` unchanged (no bypass). Item 3 — *what releases a blocked row* — is now the blocking residual: `Status` has no value for a WIP-rejection outcome and inventing one would move the row outside `UX_RodStaging_Bay`'s filter, freeing a bay that is not free. **Q76:** `UX_RodStaging_Bay` is keyed `(LineId, PayoffPosition)` while `CK_RodStaging_LineId` admits both `FL1` and `FL3` — so if the two lines share one physical VPS (the assumption everywhere, and why `FL3PO` was never seeded, Q73), **two rods can be staged on one physical bay with every constraint satisfied**. Not covered by G20, which settled payoff-position vocabulary rather than uniqueness scope; logged as **G21**. **Q77:** a welded rod could be un-staged from the queue — welded is `IsWelded` on a `Staged` row, so every "staged" control matched it — despite being physically welded to the rod in the mill; the control is removed, but `WLD011` (supervisor reversal of a weld) remains unspecified. Total questions: 77. |
| Jul 30, 2026 | Client direction | **Q74 extended — out-of-planned-sequence now requires supervisor authorisation.** The operator is notified when the rod is not the one planning expects next, and a supervisor override is required to depart from the planned sequence — same credential block as the off-schedule override (reason + badge/ID + PIN, remote-approval fallback), recorded as `RodStaging.OutOfSequenceOverride` + `ExpectedRodAlpha`. Two deviations can co-occur and share one sign-off. **This supersedes the earlier free-processing-order requirement** (Q70), which had the operator re-sequencing at will with no warning and no override; both sequence columns are retained regardless, so the deviation is now authorised as well as recorded. |
