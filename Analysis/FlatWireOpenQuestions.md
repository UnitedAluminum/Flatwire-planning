# Flat Wire Mill — Open Questions Register

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 4, 2026
**Total Questions:** 95 · **Shopfloor scope:** 68
**Status Legend:** `Open` · `In Progress` · `Decided` · `Deferred`
**Scope Legend:** `Shopfloor` — Flat Wire Mill shopfloor changes · `Other` — adjacent modules

> Questions marked **Critical** must be resolved before development begins on the dependent module.
> Questions marked **High** must be resolved before July 1 trials.
> Questions marked **Medium** must be resolved before August 1 production.
> Questions marked **Low** can be resolved post go-live.

---

## Shopfloor Scope — Filtered Index

**68 of 95 questions relate to Flat Wire Mill shopfloor changes** — the operator execution screens (Dashboards 1–12+) plus the reference data, equipment limits and validation rules those screens consume. The remaining 27 belong to adjacent modules (orders/quotes, pricing, costing, planning, scheduling, receiving, certification, maintenance) and are retained here marked `Scope = Other`.

**Nothing is filtered out by deletion.** The Change Log at the foot of this file cites question numbers throughout, and `OQ-##` references point inbound from the phase files, [REVIEW.md](../DevelopmentPlan/REVIEW.md) and the master specification. The numbering must stay contiguous, per the register convention in [CLAUDE.md](../CLAUDE.md).

**Filter rule applied:** a question is `Shopfloor` if a shopfloor screen **reads it, validates against it, or writes it**. That keeps reference data and equipment limits in scope (Q32 coil weight, Q36 footage-to-weight, Q38 tolerance bands, Q41 die life) and leaves scheduling representation (Q10), pre-scheduling validation (Q53) and order-entry behaviour (Q9, Q11, Q12) out, even where they touch flat wire.

### Shopfloor — Open / In Progress (47)

| Priority | Questions |
|---|---|
| `Critical` | **Q1** pass schedule UI · **Q14** traveler fields per station · **Q15** FL2 spool check-in identifier · **Q36** footage-to-weight factor · **Q51** pass schedule selection at check-in · **Q52** FL3 hybrid schedule + FL2 validation · **Q90** confirm every machine tag path · **Q94** FM2 PLC station rename · **Q95** confirm every measure name |
| `High` | **Q16** skid labeling rules · **Q21** cert traceability granularity · **Q22** weld footage attribution · **Q23** max weld joints per coil · **Q30** roll gap validation *(IP)* · **Q38** published tolerance bands · **Q47** partial-rod re-check-in *(IP)* · **Q49** PLC tags on checkout *(IP)* · **Q57** spool state machine *(IP)* · **Q58** OD→weight formula · **Q60** target spool weight source *(IP)* · **Q63** `FL{n}.LineState` vocabulary · **Q66** scale-vs-calculated weight *(IP)* · **Q71** dimensional tolerance columns *(IP — values owed)* · **Q72** failed-inspection row *(IP)* · **Q74** staging overrides *(IP)* · **Q76** FL1/FL3 bay uniqueness · **Q78** rod scheduled on neither rod line · **Q80** shopfloor panel resolution · **Q81** rod bundle gross weight · **Q85** speed pushed as target or limit · **Q86** edge type push + missing edger tags · **Q87** FM2 tag namespace on FL3 · **Q89** take-up load cells / completion weight |
| `Medium` | **Q24** rework weld on cert · **Q42** edger blade profiles · **Q61** TKUP-2 alert ladder · **Q62** supervisor mirroring · **Q64** stop-popup arbitration · **Q70** `RodSeqno` scope · **Q73** FL3 WIP station · **Q79** multi-order rod sequencing · **Q82** WIP rejection list screen · **Q83** *Welds this run* at cold start · **Q84** destination after check-in · **Q88** units carried in tag paths · **Q91** ordinal naming convention |
| `Low` | **Q8** WIP REJ report columns |

### Shopfloor — Decided (20) · Superseded (1)

~~**Q4** SCADA chart layout *(May 15)*~~ **superseded Aug 4 — DB13/DB14 descoped; the tag half is now `PLC-Q02`** · **Q27** mid-run alpha handling *(May 4)* · **Q28** pass schedule override authority *(May 4)* · **Q29** component failure protocol *(May 4)* · **Q32** max finished coil weight *(Apr 28)* · **Q39** camber *(May 4)* · **Q40** edge burr *(May 4)* · **Q41** die life tracking *(May 4)* · **Q48** mid-run checkout authorisation *(May 4)* · **Q50** partial-run disposition *(May 4)* · **Q54** pass schedule ID on cert record *(May 4)* · **Q55** spool alpha through anneal *(May 4)* · **Q56** SPC on resume *(May 4)* · **Q65** short-close path *(Jul 30)* · **Q67** pre-check-in coil status *(Jul 30)* · **Q68** pre-check-out approval *(Jul 30)* · **Q69** multi-order rod *(Jul 30)* · **Q75** VPS bundle stacking *(Jul 30)* · **Q77** welded-rod release *(Jul 30)* · **Q92** `ITInhibit` line-scoped *(Aug 4)* · **Q93** FM2 three stands, S1 = 8″ *(Aug 4)*

### Out of shopfloor scope (27)

**Q2** pricing · **Q3** costing codes · **Q5** standard times · **Q6** throughput rates · **Q7** baler dimensions · **Q9** Finish field lock · **Q10** FL3 scheduling representation · **Q11** bundle width range · **Q12** edge critical attribute · **Q13** scrap banding · **Q17** rod receiving label · **Q18** rod inventory type · **Q19** rod storage location · **Q20** anneal rules timeline · **Q25** C of C frequency · **Q26** tolled cert liability · **Q31** coil OD/ID limits · **Q33** oscillation interleave · **Q34** twist and torsion · **Q35** metallic yield per route · **Q37** yield loss factor · **Q43** roll regrind · **Q44** line speed range · **Q45** FL1/FL2 simultaneous operation · **Q46** anneal furnace capacity · **Q53** pre-scheduling validation · **Q59** planning grid layout

---

## Quick Reference — Decision Log

| # | Question (Short) | Scope | Priority | Owner | Status | Decided Date |
|---|-----------------|-------|----------|-------|--------|--------------|
| 1 | Pass Schedule UI vs. table management | `Shopfloor` | Critical | Tim O. | Open | |
| 2 | Pricing auto-population mechanism | `Other` | High | Sales / Tim O. | Open | |
| 3 | Costing standards and industry codes | `Other` | High | Jeff G. / Tim O. | Open | |
| 4 | ~~SCADA chart layout owner and timeline~~ — **superseded**; DB13/DB14 descoped, tag half → `PLC-Q02` | `Shopfloor` | High | UA (Tim O.) | Superseded | Aug 4, 2026 |
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
| 60 | Target spool weight source for the completion alert + over-target behavior | `Shopfloor` | High | Tim O. / Operations | In Progress | Jul 30, 2026 *(basis)* |
| 61 | Does the spool completion alert ladder apply to finished coils at TKUP-2 (FL2/FL3)? | `Shopfloor` | Medium | Tim O. / Jaspreet | Open | |
| 62 | Supervisor mirroring and audit persistence of milestone acknowledgements | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 63 | `FL{n}.LineState` vocabulary, stop-dwell value, and pause-reason suppression | `Shopfloor` | High | Engineering / Tim O. | Open | |
| 64 | Stop-confirmation popup — supervisor visibility and multi-operator arbitration | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 65 | Short-close path — closing a spool below target weight | `Shopfloor` | Medium | Tim O. / Operations | Decided | Jul 30, 2026 |
| 66 | Scale-vs-calculated spool weight — tolerance, default basis, approval authority | `Shopfloor` | High | Tim O. / Shannon R. | In Progress | |
| 67 | Pre-check-in coil status — `INFLAT` (SRS) or `STAGED` (walkthrough), and what reverses it | `Shopfloor` | Critical | Tim O. / IT | Decided | Jul 30, 2026 |
| 68 | Does pre-check-out (un-staging) require supervisor approval? | `Shopfloor` | High | Tim O. / Shannon R. | Decided | Jul 30, 2026 |
| 69 | Can a rod carry more than one production order? *(was: staging against a future order)* | `Shopfloor` | Medium | Tim O. / Planning | Decided | Jul 30, 2026 |
| 70 | `RodSeqno` scope — per line, per order, or global | `Shopfloor` | Medium | IT / Team | Open | |
| 71 | Dimensional tolerances — min/max for gauge, width, diameter **and ovality**; no column exists | `Shopfloor` | High | Tim O. / IT | In Progress | Jul 30, 2026 *(shape)* |
| 72 | Does a failed staging inspection persist a `RodStaging` row, and what releases it? | `Shopfloor` | High | Tim O. / IT | In Progress | Jul 31 *(items 1–2)* · Jul 30 *(item 3)* |
| 73 | Which WIP station does FL3 pre-check-in post to? There is no `FL3PO` | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 74 | Staging deviations — off-schedule (auto-switch), out-of-sequence (override), PIN source | `Shopfloor` | High | Tim O. / Shannon R. | In Progress | Jul 30, 2026 *(off-schedule)* |
| 75 | Can multiple rod bundles be stacked on one VPS position? | `Shopfloor` | Medium | Tim O. / Bob S. | Decided | Jul 30, 2026 |
| 76 | Are FL1 and FL3 one pre-check-in station or two? `UX_RodStaging_Bay` permits two rods on one bay | `Shopfloor` | High | Tim O. / IT | Open | |
| 77 | May a welded staged rod be released, and by whom? (`WLD011`) | `Shopfloor` | Medium | Tim O. / Shannon R. | Decided | Jul 30, 2026 |
| 78 | May a rod be processed when its order is scheduled on **neither** FL1 nor FL3? | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 79 | Multi-order rod — sequencing rule and MVP1/MVP2 scope | `Shopfloor` | Medium | Srikanth / Tim O. | Open | |
| 80 | Shopfloor panel resolution — 1280×1024 (stocked) vs 1920×1080 (required) | `Shopfloor` | High | Tim O. / Charles / Juan | Open | |
| 81 | Rod bundle gross weight — 8,690–8,840 lb or ~2,000 lb? Calibrates the payoff bar and weld alerts | `Shopfloor` | High | Tim O. / Bob S. | Open | |
| 82 | Dashboard 1's "WIP Rejections" — is a rejection *list* screen in scope? | `Shopfloor` | Medium | Tim O. / Shray | Open | |
| 83 | At cold start, should *Welds this run* be absent, or present and unavailable? | `Shopfloor` | Medium | Tim O. / Bob S. | Open | |
| 84 | Where should the operator land after pressing *Acknowledge & Begin Check-in*? | `Shopfloor` | Medium | Tim O. / Bob S. / Juan | Open | |
| 85 | Is speed pushed to the PLC as a **target/setpoint** or a **limit/clamp**? | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 86 | Is edge type pushed to the machine, and where are the **edger** tag paths? | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 87 | On FL3, are FM2 tags addressed as `FL2.FM2.*` or `FL3.FM2.*`? | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 88 | ~~Are units carried in tag paths?~~ — **specified: no, units never appear in the path.** Open on the half that bites: **what unit are the values in?** | `Shopfloor` | Medium | Tim O. / Engineering | Open | Part 1 Aug 4, 2026 |
| 89 | Do take-up load cells exist, and is the spool-completion weight **read** or **derived**? | `Shopfloor` | High | Tim O. / Bob S. / Engineering | Open | |
| 90 | Confirmation of **every machine tag path** with the controls commissioning engineer | `Shopfloor` | **Critical** | Tim O. / Engineering | Open | |
| 91 | Ordinal naming convention — **resolved as two non-competing rules** (R6 ordinals `DB1`/`Payoff2`, R5 assembly stations `FM2.S2`); confirmation still open | `Shopfloor` | Medium | Tim O. / Engineering | Open | Resolution Aug 4, 2026 |
| 92 | ~~Is `ITInhibit` plant-level or line-scoped?~~ — **DECIDED: line-scoped, `FL1.ITInhibit` / `FL2.ITInhibit`** (one tag per line) | `Shopfloor` | High | Tim O. / Engineering | **Decided** | Aug 4, 2026 |
| 93 | ~~FM2 roller sizes~~ — **DECIDED: three stands, `S1` = 8″, `S2` = 6″, `S3` = 6″** (client correction). Edgers at S2/S3 and S3 final are unchanged; the 8″ roller **is S1**, not a separate stand | `Shopfloor` | **Critical** | Tim O. | **Decided** | Aug 4, 2026 |
| 94 | Confirm the FM2 **PLC station rename** — specified `S1`/`S2`/`S3` vs the controller's observed `Stand8`/`Stand6S1`/`Stand6S2` (`PLC-Q04`) | `Shopfloor` | **Critical** | Tim O. / Engineering | Open | |
| 95 | Confirm **every measure name** in the tag map — the measure segment was reshaped on our own reading, departing from **13** observed `[CONFIRMED]` strings (`PLC-Q05`) | `Shopfloor` | **Critical** | Tim O. / Engineering | Open | |

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

**Q4** · `High` · Owner: UA — Tim O. · **Decided — May 15, 2026** · ~~**SUPERSEDED — Aug 4, 2026**~~
**SCADA chart layout owner and timeline**
UA is responsible for defining the SCADA chart layout and machine tags for flat wire. No owner or delivery date has been specified. This blocks SCADA report development.

~~**Decision (May 15, 2026):** The SCADA chart layout is now fully defined as **Dashboard 14 — SCADA Multi-Trend Charts** in `HMIAndSCADALayout.md`. This covers gauge, width, speed, and payoff weight trend charts with configurable time windows, SPC control limits, event markers (weld, die change, pause, SPC), and CSV export. The HMI line schematic is defined as Dashboard 13. All PLC tag paths required for both screens are documented in the PLC Tag Mapping table in that document. Tag paths must be confirmed with Tim O. and the commissioning engineer before go-live.~~

**SUPERSEDED (Aug 4, 2026) — the answer has been withdrawn, not the question.** The client confirmed that **SCADA Trends (Dashboard 14), the HMI Line Schematic (Dashboard 13) and the Machine View tab are not required**, so the artifact that closed Q4 — `HMIAndSCADALayout.md` — is deleted along with both mockups. Q4 splits in two:

- **The chart-layout half is moot.** There is no chart layout to own, because there are no trend charts. Nothing further is owed on it.
- **The machine-tags half survives and is still open.** Q4's other subject was *"machine tags for flat wire"*, and those tags are still read — by the active run monitor, the line status board, the rod-checkout gatekeeper, the spool stop prompt and the die-life counter. They now have a single home in [PLCTagSpecification.md](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) and remain unconfirmed: **`PLC-Q02`** (confirm every tag path with the commissioning engineer) is the successor open item.

> **A consequence outside this register.** Dashboard 14 was also the answer to the legacy .NET **"SCADA Report"** line item in [FlatWirePlan.md](FlatWirePlan.md) §Reporting Suite (Medium priority) and to the risk *"SCADA chart layout and machine tags undetermined."* With DB14 withdrawn, that report has no design again. **Whether the legacy SCADA report is also descoped is a separate client decision and has not been asked.**

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

**Widened Aug 1, 2026 — a second route to the same question.** `PCI022` makes weld quality mandatory at capture, and a weld that **fails its quality check does not mark the rod welded**: the operator remakes it before any material runs through the join. So a remade weld now arises two ways, and both leave **several `WeldEvent` rows for one physical join**:

| Route | When | Material through the join |
|---|---|---|
| Weld **breaks mid-run** (the original Q24 case) | After the join has been running | Yes — footage already attributed |
| Weld **fails its quality check at capture** (new) | Before the line transitions through it | **No** — the attempt produced no accepted material |

The second case may deserve a different answer from the first, precisely because nothing ran through it. **The question to settle is the same either way:** is a superseded attempt a record that reaches the certificate, or an annotation on the successful weld?

Note that **no uniqueness constraint exists** on `(RunId, OutgoingRodAlpha, IncomingRodAlpha)` and none should — whatever is decided must not be implemented by preventing the second row.

Footage attribution across two weld boundaries a few feet apart belongs to **Q22**, not here.

Related: **Q22** (footage attribution at the weld point), **Q21** (cert traceability granularity), **Q23** (max weld joints per coil), `CK_WeldEvent_FailReason` / `WLD013`.

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

**Q57** · `High` · Owner: Tim O. / Jaspreet · `In Progress` — *the FL2-visible states are decided (Aug 2, 2026); the stored state machine is still open*

**Spool status state machine — all valid transitions**

> **Decided (August 2, 2026) — FL2 shows two statuses and runs one spool at a time.** Because **FL2 has no space to stage material**, a spool is either waiting for the line or on it; there is no third place for it to be. The operator-visible vocabulary at FL2 is therefore fixed at **`Ready for FL2`** (schema `RECEIVED`) and **`Checked in`** (schema `INFLAT`). **`STAGED` is never set at FL2** — staging is the FL1 concept (PCI002), and the ~~"At TPO"~~ status is withdrawn from the spool queue. Second half of the decision: **check-in is exclusive.** While any spool is checked in, **no spool offers a check-in action** — not the others and not the checked-in one — and the action returns only on checkout. Applied to [dashboard_5a_spool_queue.html](../Mockups/dashboard_5a_spool_queue.html) and [SpoolQueue.md](../LatestDocument/RequirementDocuments/SpoolQueue.md) §3.5 (rules SQ-7 to SQ-10). **Still open:** the stored status list and its transitions — this decision fixes what the FL2 operator sees, not what the database records, and the two rival vocabularies of **OI-06** are still unmapped. **Two consequences that need owners:** (1) exclusivity has **no backing constraint** — `dbo.Spool` has no filtered unique index on `Status` and carries **no `LineId` at all**, so "one spool checked in per line" cannot currently be expressed in the schema; `POST /checkin/spool` must reject the second check-in with a `409`. (2) A **quality-held spool now has no place on the FL2 queue** — it is neither ready nor checked in, so it simply is not listed. Raised to the client as SpoolQueue.md open item 6.

**Status (May 4, 2026):** Tim provided the following operational framework:
- Spools shall have unique identifiers similar to furnace plates.
- Alphas are loaded onto a spool number at the start of the FL1 job; operators are required to input the spool number being used.
- The spool number is then tracked physically and in the system: tow motor moves it to the furnace, then to cooling, and then the operator on FL2 selects it by spool number for check-in.

The full formal state machine (all valid statuses and the events that trigger each transition) is still to be defined. Without a defined state machine, the system cannot enforce valid status progressions (e.g., preventing a spool from being planned for two orders simultaneously, or a completed spool being re-opened for FL2 check-in).

---

**Q60** · `High` · Owner: Tim O. / Operations · `In Progress` — *basis decided Jul 30, 2026; the source field and the over-target behaviour remain open*
**Target spool weight source for the completion alert, and over-target behavior**

> **Decided (July 30, 2026) — the basis is the customer weight range, not a fixed default.** ~~Working assumption *order value capped by equipment capacity*, with a **default target spool weight of 2,000 lb** when the order carries none.~~ Tim/Bob: the customer specifies a **min–max weight** (e.g. 900 lb max / 800 lb min) and completion is graded against **that range, by weight** — not against footage and not against an assumed default. Spools are sized at roughly **1,800 lb** so that **two finished coils** can be cut from one spool at FL2. The **2,000 lb default is withdrawn** and must be removed from Q65, [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) and the mockup. Still open: **which order field carries the customer min/max**, and whether the ladder still escalates to a distinct over-target state.

The spool completion alert ([SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md)) compares actual processed weight against a target. Two candidate sources exist: the order's **Max Wgt of Spool** (customer/order-driven) and the **take-up equipment capacity** (TKUP-1 = 3,500 lb). Note the customer maximum can be well below the TKUP-2 capacity of 1,100 lb, so on FL2/FL3 the customer value governs rather than the cap.

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

Part B of [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) conditions the spool-removal popup on the PLC confirming a `RUNNING → STOPPED` transition, using the same `FL{n}.LineState` tag the system already reads as the rod-checkout gatekeeper. Three specifics are needed before it can be built:

1. **The tag's actual state vocabulary** — is it a two-state run/stop bit, or does it distinguish `RUNNING / STOPPED / PAUSED / FAULT / THREADING / JOG`? A jog or thread state that reports as STOPPED changes the filtering required.
2. **Dwell time** — how long must STOPPED persist before the stop is treated as real? Proposed default **5 seconds**, with speed ≈ 0 as corroboration. Needs a value from someone who knows how the drives behave on slow-down.
3. **Pause-reason suppression** — if the operator already used the software Pause dialog and captured a reason (die change, weld prep, break), should the popup be suppressed because the reason is already known? Proposed yes, unless the reason indicates spool removal.

---

**Q64** · `Medium` · Owner: Tim O. / IT · `Open`
**Stop-confirmation popup — supervisor visibility and multi-operator arbitration**

Is the spool-removal confirmation strictly an operator-at-the-HMI decision, or does the supervisor see that a prompt is pending (particularly one left unanswered with the line stopped at target, which means production is halted with no transaction recorded)? And with several operators signed in on the shared screen, does the prompt appear once per line with first-answer-wins (proposed), or per operator session? The answering operator is recorded on the audit record either way.

---

**Q65** · `Medium` · Owner: Tim O. / Operations · `Decided July 30, 2026`
~~**Short-close path — closing a spool below target weight**~~

~~The stop-confirmation popup is armed only at or above target weight, so a spool the operator wants to close **early** — order satisfied, rod exhausted, quality problem, end of campaign — gets no prompt. Is a short close a real operational case, and if so should stopping below target also prompt (with a reason code and a partial-spool alpha), or should it stay a purely manual action the operator initiates?~~

**Decision (July 30, 2026):** a short close is a real case and is handled as an **unplanned stop**, mirroring the mill **10-90 SOP**, with an unplanned-stop reason code.

1. **Graded by weight against the customer min–max**, not by footage and not against a fixed target (see **Q60**). Example figures given: 900 lb max / 800 lb min.
2. **Inside the range → continue.** If the short weight still yields the finished coils the order requires, no escalation.
3. **Outside the range → flagged.** Either a **supervisor override plus a production hold**, or the piece is **offered to the customer under concession** before a remake is planned. Shannon's direction is explicit: **offer first**, remake last.
4. **The spool is run off in either case.** FL2 has **no spool stripper**, so the spool must be emptied and returned to FL1 regardless of the disposition of the material on it. This constrains the reject-and-remake path — "scrap it" is never "stop and remove it".
5. **Coil break mid-run:** the stop is **removed and a new stop starts from zero** — weight does **not** resume from the break point. The leftover incoming material is welded to the next coil on FL1; on FL2 it is either run to a finished stop and offered to the customer, or scrapped.

Item 5 is a **run/stop model** change rather than a screen rule — check it against `FlatWireRun` / `CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage (**OI-25**) before it is written as settled. Overlaps the partial-spool handling in **Q47** and [PartialRodReCheckin.md](PartialRodReCheckin.md); the **10-90 SOP document itself is not in this repository** and must be obtained rather than paraphrased.

---

**Q66** · `High` · Owner: Tim O. / Shannon R. · `Open`
**Scale-vs-calculated spool weight — tolerance, default basis, and approval authority**

The spool completion step now captures a **scale weight** (gross) alongside the **system-calculated** net (footage × cross-section × density) and asks the operator which to record ([SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) Part B, rules S-16…S-21). Four points need a decision:

1. **Variance tolerance** — proposed **±2 %** of the calculated weight, matching the spirit of the existing scale-vs-vendor check at rod receiving. What is the real acceptable spread on a ~2,000 lb spool?
2. **Default basis** — proposed: the **scale reading wins** once entered (a weighing outranks a derivation), operator able to override to calculated. Confirm that is right for FL1, and whether it also holds for finished coils at TKUP-2.
3. ~~**Out-of-tolerance authority**~~ — **DECIDED (July 29, 2026):** an out-of-tolerance variance must **not** stop the operator from creating the spool. The completion is **authorised, not blocked**: a **supervisor override** (reason + supervisor badge/ID + PIN) appears and the commit control stays enabled, with a remote-approval fallback when no supervisor is on the floor. The override, the authorising supervisor and the reason are recorded on the spool. Still to confirm: whether the PIN is validated against the existing login/authorisation service or a separate supervisor credential store.
4. **Is a scale even available at the take-up?** The weigh-at-payoff question is already open in **Q47**; the same uncertainty applies here. If there is no scale at TKUP-1, the capture is optional and the calculated weight stands — but then **Q58**'s formula never gets validated against measured data.

Directly related: **Q58** (OD → weight conversion formula) — accumulated scale-vs-calculated variances are the data that would settle it.

---

**Q67** · `Critical` · Owner: Tim O. / IT · `Decided July 30, 2026` — *item 1 decided; the commitment residual moves to the follow-up list*
**Pre-check-in coil status — `INFLAT` or `STAGED`, and what reverses it**

> **Decision (July 30, 2026): `INFLAT` is set only when the rod is actually checked in at FL1.** Pre-check-in does **not** commit the shared coil status, and there is **no intermediate status** for a rod that has been welded but not yet checked in (Tim: not needed). This **supersedes the interim design**, which followed the SRS §4.2 `PCI` data note — that note is now wrong wherever it is quoted, and [FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) step 8 (`RECEIVED → STAGED`) becomes the winning source. Rod status `STAGED` stops being vestigial for FL1 and becomes the real staging status. **Unblocks the Phase 4 staging build.**
>
> **Residual, deliberately still open (items 2–3 below).** The decision covers the **status column**, not the rest of the SRS data note: whether pre-check-in still performs the `FlatwireQueue` insert, the reqsum and the `wip_coil_orders` insert. If those writes stay at staging the compensating-write burden (**G2/G16**) is unchanged and only the status moved; if they move to check-in, pre-check-out becomes a pure `FlatWireDB` delete and **OI-01** closes completely. Sent back to Tim O. / IT — see the follow-up list in [ClientCall_2026-07-30_SyncPlan.md](ClientCall_2026-07-30_SyncPlan.md) §6.

Two delivered documents disagree about what happens to the shared coil record when a rod is pre-checked-in at the payoff:

- **SRS §4.2** (`PCI` data note) has pre-check-in performing the `FlatwireQueue` insert (`Rodno`, `RodSeqno`, `Welded`), setting `proddb..coils.coil_status = INFLAT`, and doing the reqsum + `wip_coil_orders` insert — i.e. the material is **committed** as soon as it is queued.
- **[FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) step 8** has it as `RECEIVED → STAGED`, with `INFLAT` arriving later at check-in.

The interim design follows the SRS and treats the two as orthogonal — `RodStaging.Status` is bay occupancy, `coils.coil_status` follows the SRS — which makes rod status `STAGED` effectively vestigial for FL1. Three things need confirming:

1. Does pre-check-in really commit the material to `INFLAT`, or should the shared status stay `STAGED` until acknowledgement?
2. If `INFLAT`: pre-check-out must **reverse** the `wip_coil_orders` insert and reqsum. Is that reversal safe for planning, and does it leave any trace planners need to see?
3. If `STAGED`: does anything downstream (planning availability, WIP queue, traveler) actually need the material committed at staging time — which is presumably why the SRS specified `INFLAT` in the first place?

This is **Critical** because staging writes cross database boundaries and are **compensating writes, not one transaction** (gaps G2/G16) — the more state pre-check-in commits, the more there is to unwind correctly. Blocks the Phase 4 staging build. Detail in [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md).

---

**Q68** · `High` · Owner: Tim O. / Shannon R. · `Decided July 30, 2026`
**Does pre-check-out (un-staging) require supervisor approval?**

> **Decision (July 30, 2026): it depends on whether the rod has been welded.**
>
> | Rod state | Approval | What is recorded | Rod status |
> |---|---|---|---|
> | **Not welded** | **None** — operator-only, as the interim design assumed | Pre-check-out reason | Returns to inventory |
> | **Welded** | **Supervisor override required** | Documented reason — this **is a rejection** | **HOLD** |
>
> The reasoning is physical, not procedural: removing a welded rod means **cutting or splitting the material**, so the un-stage is a rejection rather than a return. This also **answers Q77** — a welded rod *can* be released, by a supervisor, and the Jul 31 removal of the Unstage control from welded rows is superseded; the control returns behind a supervisor gate and routes to rejection.
>
> **Schema consequence:** `RodCheckout` has **no supervisor columns at all** today — Q48's mid-run approval is equally unpersisted. Mode P needs `ApprovedBy` / `ApprovedAt` / `OverrideReason` and a check constraint requiring them (plus `NewRodStatus = 'HOLD'`) when the un-staged rod was welded. Pre-check-out still needs its own `PCI`-series requirement ID either way — §4.17 covers only post-check-in removal.

**Q48** decided that a **mid-run** checkout (footage > 0) requires supervisor approval, because footage has been produced and material must be dispositioned. Pre-check-out is the opposite end of the scale: the rod was never checked in, no pass schedule was acknowledged, no PLC tags were pushed and no footage exists — so the interim design allows **operator-only** un-staging.

Confirm that is right. The counter-argument is inventory discipline rather than material risk: un-staging returns a bundle to the floor or warehouse and reverses a WIP queue entry, and a mis-scan corrected quietly leaves no supervisor visibility. If approval *is* wanted, is it a blocking gate (as in Q50's notification-driven remote model) or an after-the-fact notification?

Related: pre-check-out has **no SRS requirement ID at all** — §4.17 covers only post-check-in removal. A new `PCI`-series requirement block is needed regardless of how this is decided.

---

**Q69** · `Medium` · Owner: Tim O. / Planning · `Decided July 30, 2026` — *reframed: the question was the wrong shape*
**Can a rod be pre-checked-in against a future order, or only the current one?**

> **Decision (July 30, 2026): a single rod may legitimately carry more than one production order.** Srikanth and Tim confirmed the case — finishing order 1 on a 7,000 lb A-rod and starting order 2 on the remainder, both orders being the same alloy. The intent is for this to be handled **in planning** (the upstream operation), in multiples of the ~900 lb outgoing coil.
>
> **This inverts the Jul 29 leaning.** The interim rule — staging validates that the rod *"belongs to the **current** production order"*, singular, with a rod from any other order a **hard refusal** — is **wrong as written**: the successor order is on the *same rod*, so a refusal would stop the line mid-bundle. The consequence recorded on Jul 29 (*"continuous feed cannot cross an order boundary"*) is therefore also wrong for the same-rod case, and [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md)'s order-lookup table needs *"order differs → Refused"* rewritten as membership in an **ordered set** rather than equality with one order.
>
> **What is not decided:** the sequencing behaviour when the operator departs from the planned order across a multi-order rod — Srikanth is checking his earlier notes. Shray's proposal (complete one order at a time and assign the remaining piece to the next order) is to be considered when he reverts. **MVP2 deferral to be confirmed with Srikanth.** Logged as **Q79**; until it closes, the staging validation is a **known-wrong rule**, not a rule to edit.

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

**Q71** · `High` · Owner: Tim O. / IT · `In Progress` — *shape decided Jul 30, 2026; the values are owed by e-mail*
**Dimensional tolerances — min/max for gauge, width, diameter and ovality; no column exists**

> **Decision (July 30, 2026): the tolerances exist, they are min/max, and there are four of them.** Tim confirmed **upper and lower limits for height (gauge), width and diameter, plus ovality**. They are held in the **lookup** and applied at **both pre-check-in and check-in**. He did not have the figures to hand — *"I want to say it's plus or minus 10"* — and will **send the width, height, diameter and ovality tolerances by e-mail**.
>
> **Two structural consequences, both larger than this gap as first written:**
>
> 1. `AlloyProperty` holds `GaugeToleranceDefault` / `WidthToleranceDefault` as **single ± values**. Min/max means explicit `Min`/`Max` pairs — a **rename plus widen**, not the single `RodDiameterToleranceDefault` add proposed below (and in **OI-07**). Do diameter and ovality in the same change.
> 2. Ovality already exists as a *computed* check — `RodCheckin.SpcOvalityIn` with a hard-coded **≤ 0.003"** in [CheckinImplementationPlan.md](../DevelopmentPlan/CheckinImplementationPlan.md). That constant must move into the lookup, or ovality is validated two ways.
>
> **No values are to be seeded until the e-mail arrives.** "Plus or minus 10" is not a specification. Add the columns nullable, keep the Dashboard 2A per-alloy map visibly marked as mock, and hold the seed script. **Still blocks Phase 4 implementation** even though the shape is settled.

`CHK007` requires the measured rod diameter to be validated against nominal **± a lookup tolerance**, at both pre-check-in (Dashboard 2A) and check-in (Dashboard 2). There is nowhere to read that tolerance from.

`AlloyProperty` carries `GaugeToleranceDefault` and `WidthToleranceDefault`, but those are **flat wire output** dimensions — the gauge and width the mill produces. Incoming rod diameter is a different measurement, and no column for its tolerance exists in `FlatWireDB` or in the shared `coils` schema. A search across `Schema/` returns gauge and width tolerances only.

As a result the Dashboard 2A mockup hard-coded a single `0.005"` for every alloy, which is wider than every value in the standards table in [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) (*Alloy Lookup Table*: 1100 → ± 0.003", 1350 → ± 0.002", 3003 → ± 0.004") — so out-of-tolerance rod would have been accepted. The mockup now reads a per-alloy map mirroring that table, but the map is mock data with no backing store.

To resolve:

1. Add `AlloyProperty.RodDiameterToleranceDefault` (or confirm the tolerance belongs on a rod-spec record rather than the alloy)?
2. Are the standards-table values authoritative, or do they need Process Engineering sign-off first? That table already carries the note *"must be confirmed and maintained by Process Engineering (Tim O.) — editable via an admin table, not hardcoded."*
3. Can tolerance vary by rod vendor or by nominal size within one alloy, or is per-alloy sufficient?

Blocks the Phase 4 check-in and staging validation. Detail in [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md).

---

**Q72** · `High` · Owner: Tim O. / IT · `In Progress` — *items 1–2 decided Jul 31, 2026; item 3 decided Jul 30, 2026; item 4 open*

> **Decided (Jul 31, 2026) — items 1 and 2.** `Blocked` is **derived** (`Status = 'Staged'` + any inspection column `= 'Fail'`), not a fourth `Status` value; and pre-check-in **commits the `RodStaging` row before the inspection gate**. `POST /staging/rod` now returns `201 Created` with `state: "Blocked"` and the WIP-rejection route, replacing the `422`-and-write-nothing behaviour. The deciding argument is physical: bundles are not unbanded until positioned at the payoff — which is *why* the inspection happens at staging — so a rod that fails is **already on the bay**. Writing no row left `GET /payoff/status` reporting an occupied position as `NotStaged`, Dashboard 2A offering it as "Empty — available", and the next rod stageable into a bay that physically holds a rejected bundle. `CHK010` is unchanged: no bypass, WIP Rejection remains the only forward path. Contracts updated in [APIContracts.md](../DevelopmentPlan/APIContracts.md), [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md) and [phase-04](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md).
>
> **Decided (July 30, 2026) — item 3, the blocking residual.** A failed staging inspection is **captured as a rejection on the rejection screen** — the operator enters the rejection reason there — and **the rod goes to `HOLD`**. That is what releases the `RodStaging` row and frees the bay: the WIP rejection carries the material out of the bay, so the row leaves `Status = 'Staged'` and `UX_RodStaging_Bay`'s filter with it. **A blocked bay is now clearable.**
>
> **Implementation choice, not a business one** — recorded here because the DDL has to pick one: reuse `Status = 'Unstaged'` with a release-reason discriminator, or add a fourth `Rejected` value. **Recommendation: reuse `Unstaged` plus a `ReleaseReason`.** A fourth value multiplies branches in every "staged" query and forces `CK_RodStaging_Unstaged`, the status vocabulary and the filtered index to change together for no operational gain — the bay genuinely *is* free once the bundle leaves. `CK_RodStaging_Unstaged` currently ties `Unstaged` to the pre-check-out column group, so that constraint must admit the rejection route as a second way in.

**Does a failed staging inspection persist a `RodStaging` row, or is nothing written?**

Dashboard 2A and `GET /payoff/status` both expose a **`Blocked`** bay state, defined as *"inspection failed at staging"*. `RodStaging.Status` has no such value — it is only `Staged | CheckedIn | Unstaged`.

The state *is* derivable: the three inspection columns are `NOT NULL` `Pass`/`Fail`, so a blocked bay is `Status = 'Staged'` with any inspection column `= 'Fail'`. That reading is also the correct one operationally, because `UX_RodStaging_Bay` is filtered on `Status = 'Staged'` — the failed bundle is still physically in the bay and must keep it occupied. But no artifact states this, and the alternative (a fourth status value) would change the filtered index.

The sharper problem is that **nothing currently writes the row**. On a failed inspection the wizard is a hard block with no bypass (`CHK010`) and the only forward action is a link to WIP Rejection, so the staging record is never committed and the inspection evidence is lost at navigation. The `Blocked` state is therefore unreachable in practice.

To resolve:

1. Confirm `Blocked` is **derived** (`Staged` + any `Fail`) rather than a fourth `Status` value.
2. Does pre-check-in commit a `RodStaging` row *before* routing to WIP Rejection, so the failure and its observation are persisted and the bay reads BLOCKED?
3. ~~**(Now blocking.)**~~ **DECIDED Jul 30, 2026 — see the block above: WIP rejection releases it and the rod goes to `HOLD`.** What releases that row — a pre-check-out (`ModeP`), or does the WIP rejection itself un-stage it? `Status` has only `Staged | CheckedIn | Unstaged`, and `CK_RodStaging_Unstaged` ties `Unstaged` to the pre-check-out column group, so a WIP-rejection outcome has **no status to land in**. A fourth value would have to change the vocabulary, the constraint *and* `UX_RodStaging_Bay`'s filter together — and anything outside `Status = 'Staged'` frees a bay that is not physically free. Deliberately not invented. **Until this is answered a blocked bay is enterable but not clearable.**
4. `InspectionNotes` is nullable but documented as *"expected when any item fails."* Should it be enforced NOT NULL when any item is `Fail`, matching the constraint style already used for the welded/unstaged/checked-in column groups?

**Two untraced consequences of the item-2 decision**, recorded rather than resolved: `RodStaging` now holds rows for material that was never accepted, which affects the **`TRV009`** traveler (is `Blocked` a third class alongside pre-checked-in and welded?); and the **`Available`** queue projection must exclude rods sitting blocked, or a rejected bundle reappears as stageable.

Related to `CHK010` and gap **G14**. Detail in [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md).

---

**Q73** · `Medium` · Owner: Tim O. / IT · `Open`
**Which WIP station does FL3 pre-check-in post to? There is no `FL3PO`**

The data model, DDL and API all scope staging to **FL1 and FL3** — `CK_RodStaging_LineId` allows `FL1` or `FL3`, and `/staging/**` rejects only `FL2` (`PCI002`). The WIP station seed does not match: [CommonDB_Insert_WIPStations_FlatWire.sql](../DevelopmentPlan/DBScripts/CommonDB_Insert_WIPStations_FlatWire.sql) creates `FL1PO`, deliberately omits `FL2PO`, and **never mentions `FL3PO`**. The SRS text is no help either — `PCI003` names a dedicated Pre-Check-In station for **FL1** only; FL3's inclusion is an inference from the fact that the hybrid line draws rod from the same VPS.

The Dashboard 2A mockup previously wrote `FL3PO` into the station stamp when the FL3 toggle was selected — a station code that exists nowhere. It now assumes FL3 posts to `FL1PO`, on the reading that FL3 *is* FL1 running hybrid into FL2, so there is one physical payoff and one station.

To confirm:

1. Is that reading right — one VPS shared between FL1 and FL3 modes, so `FL1PO` covers both?
2. If instead FL3 warrants its own station row, `FL3PO` must be seeded and the D2 note updated.
3. Either way, should staging rows record `LineId = 'FL3'` when the line is in hybrid mode, even though the station is `FL1PO`? That decides whether the Traveler Queue for FL3 is a distinct queue or the same one.

Detail in [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md).

---

**Q74** · `High` · Owner: Tim O. / Shannon R. · `In Progress`
**Staging deviations — off-schedule (now auto-switch), out-of-sequence, PIN source, and the mid-order case**

**Decided (July 30, 2026) — off-schedule is no longer a deviation at all.** ~~A rod whose order is scheduled on a **different line** is notified and authorised by a **supervisor override**.~~ Tim's direction: **no blocking message and no override — the system selects the correct station automatically.** If the rod is planned for FL3 and the operator is on the FL1 tab, the screen **switches to FL3** and the transaction continues. The same behaviour applies to **pre-check-in and check-in**.

> **This supersedes the July 29, 2026 decision below, and the columns that implemented it are dropped** (project decision, Aug 1, 2026): `RodStaging.OffScheduleOverride`, `ScheduledLineId` and `CK_RodStaging_OffSched` are removed, and `CK_RodStaging_Override` — generalised on Jul 30 to cover *either* deviation — reverts to keying on `OutOfSequenceOverride` alone.
>
> **`OverrideBy` / `OverrideAt` / `OverrideReason` survive.** They are shared with the out-of-sequence override, which stays. Dropping all five columns would delete the surviving override's audit trail.
>
> **Two things this raises rather than settles:** auto-switching moves the operator between stations **mid-transaction** — the behaviour of a part-completed wizard must be specified; and it presumes an FL3 tab exists on the FL1 panel at all, which is **Q73/Q76** surfacing as a UI question. If **Q78** later needs an authorisation for the not-scheduled-anywhere case, it **re-adds** a column group rather than reusing this one.

**Decided (July 30, 2026) — out-of-planned-sequence, provisionally confirmed.** The operator must be **notified** when the rod being checked in / pre-checked-in is not the one the planning system expects next, and a **supervisor override is required** to depart from the planned sequence. Same credential block: reason + badge/ID + PIN, remote-approval fallback, all recorded (`RodStaging.OutOfSequenceOverride` + `ExpectedRodAlpha`, sharing the credential stamp). "Expects next" is the lowest planned sequence still available, so a blocked bundle does not freeze the sequence behind it.

> **Re-review committed.** On the Jul 30 call Tim agreed the override *"might not be a bad idea"* and asked to **leave it in place for now** while he reviews something in the spec that it may support. **Confirm at the next review** before anything downstream treats it as final.
>
> This **supersedes** the earlier free-processing-order requirement, which had the operator re-sequencing at will with explicitly no warning and no override (see **Q70**). Both sequence columns are retained regardless — the deviation is now authorised *and* recorded.

~~**Decided (July 29, 2026) — off-schedule.**~~ **SUPERSEDED July 30, 2026 — see above.** ~~A rod whose order is scheduled on a **different line** is **not refused**. The operator is notified at pre-check-in / check-in that the order belongs to another line, and a **supervisor override** authorises staging it here. Following the pattern already decided in **Q66** part 3: reason + supervisor badge/ID + PIN, remote-approval fallback when no supervisor is on the floor. The override, the authorising supervisor and the reason are recorded on the staging record (`RodStaging.OffScheduleOverride` / `ScheduledLineId` / `OverrideBy` / `OverrideAt` / `OverrideReason`, all-or-nothing via `CK_RodStaging_OffSched`). The PIN is never stored.~~

Rod→order comes from **`planning_routings`**, so the order is *resolved* from the scan rather than chosen — which is what makes even the first rod on a cold line validatable.

Still to confirm:

1. **PIN validation source** — the existing login/authorisation service, or a separate supervisor credential store? Inherited unresolved from Q66; it still gates the out-of-sequence override and the welded pre-check-out (**Q68**), so it should be settled once for all of them.
2. ~~**The mid-order case is different and currently a hard refusal.**~~ **Reframed by Q69 (Jul 30, 2026):** a rod can legitimately carry **more than one order**, so "a rod from another order" is not automatically a foreign rod. The refusal survives only for a genuinely unrelated order; the same-rod successor must pass. Sequencing across the two is **Q79**.
3. **Does the same override apply at check-in (Dashboard 2)?** The decision says "checkin/precheckin", so Dashboard 2 needs the identical out-of-sequence panel and the same columns on `RodCheckin`. Only Dashboard 2A carries it today.
4. ~~**Does the scheduled line need updating** when an order is authorised to run elsewhere?~~ **Moot** — auto-switch runs the order on the line it was booked on, so there is no booking to correct.
5. ~~**Should an off-schedule run notify the other line's operator?**~~ **Moot** for the same reason.

Detail in [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md).

---

**Q75** · `Medium` · Owner: Tim O. / Bob S. · `Decided July 30, 2026`
~~**Can multiple rod bundles be stacked on a single VPS payoff position?**~~

> **Decision (July 30, 2026): no.** Tim confirmed rods **cannot be stacked** on a single payoff. **Only two rods total may be checked in at a time — one per payoff** — the same rule as the mills. The one-bundle-per-bay assumption every artifact already makes is correct, `UX_RodStaging_Bay` is right as keyed *(subject to **Q76**, which is about its FL1/FL3 scope, not its shape)*, and **none of the four schema consequences below are to be built**: no `StackPosition`, no `MaxStackDepth`, no re-based weight thresholds.
>
> **`CK_WeldEvent_PayoffDiff` stays as it is.** The pre-emptive relaxation recommended below was insurance against a "yes"; with a "no", a weld is always a bay handover and "a bay cannot be welded to itself" is the correct invariant.
>
> **Item 1 below does *not* close with this.** The **bundle gross weight** is stated two incompatible ways across the delivered contracts and it calibrates the payoff weight bar and the weld alerts independently of stacking. It is re-homed as **Q81** so it survives this question closing.

Every artifact assumes exactly one bundle per bay — `UX_RodStaging_Bay` enforces it as a filtered unique index, and [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md) calls "one rod per payoff bay" the whole point of a two-bay station. **Nothing states whether that is the equipment's limit or only the current modelling assumption.** Eye-to-sky is the payoff geometry in which stacking coils on a vertical spindle — tail of the upper bundle welded to the head of the one below — is standard wire-industry practice, so the assumption is worth confirming rather than inheriting.

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

**No SRS requirement covers stacking**, and it is not required for continuous operation — two alternating bays already deliver non-stop running (see [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md)). Recommendation is therefore **not to build it**, but to settle item 1 before the Phase-4 schema freeze and relax `CK_WeldEvent_PayoffDiff` pre-emptively.

Related: **Q6** (throughput rates — the same equipment-data gap), **Q36** (footage-to-weight factor), **Q23** (max weld joints per coil — stacking multiplies welds per bay).

---

**Q76** · `High` · Owner: Tim O. / IT · `Open`
**Are FL1 and FL3 one physical pre-check-in station or two? `UX_RodStaging_Bay` currently permits two rods on one bay**

`UX_RodStaging_Bay` is a filtered unique index on **`(LineId, PayoffPosition) WHERE Status = 'Staged'`**, and `CK_RodStaging_LineId` admits **`FL1` and `FL3`**. So `(FL1, 1)` and `(FL3, 1)` are two distinct index entries.

If FL1 and FL3 share one physical VPS — which is the working assumption everywhere, including `STATION_BY_LINE = { FL1: "FL1PO", FL3: "FL1PO" }` in the Dashboard 2A mockup, and the whole reason `FL3PO` was never seeded (**Q73**) — then **two different rods can be `Staged` on the same physical payoff position with every constraint satisfied.** The invariant the table exists to enforce, "one rod per payoff bay" ([RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md) calls it *the whole point of a two-bay station*), does not hold across the FL1/FL3 pair.

This is a different defect from **G20**, which settled the *vocabulary* of payoff position (the `PayoffPosition` lookup and the `FlatWireRunDetail` FK). It did not settle the **uniqueness scope**.

The answer determines the fix, and the two are opposites:

| If… | Then |
|---|---|
| **One station** (FL3 is FL1 running hybrid — the current assumption) | Key the index on the **station**, not `LineId` — either index `FL1PO` directly or add a persisted station column. `CK_RodStaging_LineId` stays as-is; the mockup's `STATION_BY_LINE` is correct |
| **Two stations** | `FL3PO` must be seeded in `CommonDB_Insert_WIPStations_FlatWire.sql`, the index is already right, and the mockup's assumption is **wrong** |

Also unresolved by either answer: what the FL1/FL3 toggle on Dashboard 2A *means*. It currently relabels the badge, station stamp, queue heading and modal subtitle without reloading the bays or the queue — and because the off-schedule check reads the current line, toggling silently reclassifies already-staged rod as off-schedule with no visual change.

**Blocks the Phase-4 schema freeze.** Related: **Q73** (which station FL3 posts to — this is its data-model consequence), **Q75** (the other `UX_RodStaging_Bay` scope question), **G20**, **G21**.

---

**Q77** · `Medium` · Owner: Tim O. / Shannon R. · `Decided July 30, 2026`
**May a welded staged rod ever be released, and by whom? (`WLD011`)**

> **Decision (July 30, 2026): yes — by a supervisor, and it is a rejection.** Answered as part of **Q68**. Releasing a welded rod requires a **supervisor override** with a **documented reason**, because removal means cutting or splitting the material; the rod goes to **`HOLD`**. Tim also confirmed **no separate status is needed** for a rod that is welded but not yet checked in.
>
> **This supersedes the Jul 31, 2026 fix** that removed **Unstage** from welded rows and made `openPreCheckout()` reject a welded bay. The control **returns**, gated on supervisor authorisation and routed to rejection rather than to "returns to inventory". The Jul 31 finding was right about the *unqualified* control and wrong about there being no path at all.
>
> **Residual:** `WLD011` is *"supervisor reversal of a welded coil"*, which is broader than un-staging — reversing a weld **in place**, on a rod that stays staged (mis-scan, wrong rod welded, weld failed after marking), is still unspecified and still has no audit target. `CK_RodStaging_Welded` ties `WeldedAt`/`WeldedBy` to `IsWelded`, so an in-place reversal is a three-column clear plus an audit trail that does not exist. Items 1–2 below therefore remain open; item 3 is answered for the un-staging direction only.

Mark-as-welded sets `RodStaging.IsWelded` on a `Staged` row — welded is a **flag, not a status**. Every control that acts on a "staged" bay therefore also matched a welded one, so until Jul 31 2026 the Dashboard 2A queue offered **Unstage** on a welded rod and the guard admitted it. That rod is physically induction-welded to the rod currently in the mill, so the pre-check-out modal's promise — *"the payoff bay is released and the rod returns to inventory"* — is not something that can happen.

The control has been removed from both the queue row and the bay card, and `openPreCheckout()` now rejects a welded bay. **That closes the button, not the question:**

1. Is there any legitimate need to reverse a weld record — mis-scan, wrong rod welded, weld failed after marking?
2. If so, is it a supervisor action (contrast **Q48** for mid-run checkout), and what does it write? `IsWelded` is guarded by `CK_RodStaging_Welded` (`WeldedAt`/`WeldedBy` set exactly when `IsWelded = 1`), so a reversal is a three-column clear plus an audit trail that does not exist yet.
3. `WLD011` — *supervisor reversal of a welded coil* — is listed in the SRS but **never specified**. It needs a requirement before it gets a control.

Until then there is deliberately **no UI path** to un-weld. Related: **Q48**, `WLD003`/`WLD010`.

---

**Q78** · `High` · Owner: Tim O. / Shannon R. · `Open`
**May a rod be processed when its order is scheduled on neither FL1 nor FL3?**

**Q74** settled what happens when a rod's order is booked on the *other* rod line — the station auto-switches. It does not answer the case where the order is scheduled on **no flattening line at all**, or the rod has no line-bearing schedule: an unscheduled job, a trial, a rush piece the floor is told to run before planning catches up.

Today that is a **hard refusal** by omission rather than by decision — staging validates that a `planning_routings` allocation exists, and scheduling then supplies the line. Nothing states what to do when the allocation exists but the booking does not, or when the operator is simply asked to run material that was never scheduled.

Asked on the Jul 30 call as *"is it possible to process an order or rod that is not scheduled on either FL1 or FL3?"*, with the suggestion that a **supervisor override** should gate it if it is allowed, applying to **both pre-check-in and check-in**. **Not covered in the call — carried forward to the next session.**

To resolve:

1. Is running unscheduled material a real case, or is planning always ahead of the floor?
2. If allowed, is a supervisor override the right gate, and does it apply at both pre-check-in and check-in?
3. If allowed, **what order does the run book against** — does scheduling get corrected after the fact, or does the run carry an "unscheduled" marker?

**Cost note:** the off-schedule override column group (`OffScheduleOverride`, `ScheduledLineId` and `CK_RodStaging_OffSched`) was **dropped** on Aug 1, 2026 when Q74 removed its only use. If the answer here is "allowed with an override", it **re-adds** a column group rather than reusing that one — the three shared credential columns (`OverrideBy` / `OverrideAt` / `OverrideReason`) do survive and can be reused.

Related: **Q74**, **Q53** (pre-scheduling validation), **Q79**.

---

**Q79** · `Medium` · Owner: Srikanth / Tim O. · `Open`
**Multi-order rod — sequencing rule, and MVP1 or MVP2?**

**Q69** decided (Jul 30, 2026) that a single rod may carry **more than one production order**. The sequencing behaviour was explicitly left open on the call: Srikanth is checking his earlier notes and will come back on it. The intent expressed was that this is handled **in planning** — the upstream operation — in multiples of the ~900 lb outgoing coil. **Shray's proposal**, to be considered when Srikanth reverts: complete one order at a time and assign the remaining piece to the next order.

The planning scenario put to the client, which is still the shape of the question:

```
R1 → O1     R2 → O1     R3 → O1     R4 → O1 / O2
```

1. If the operator departs from the planned processing sequence and stages **R4 before R1–R3**, what should happen — the **Q74** out-of-sequence override, or something stricter because R4 straddles two orders?
2. Can a rod be pre-checked-in against the **later** order on that rod while the earlier one is still running, or only against the order currently being consumed?
3. **MVP1 or MVP2?** The call recorded *"can we keep it in MVP2"*, and the **deferral is to be confirmed with Srikanth**.

**Until this closes, the staging validation is a known-wrong rule rather than a rule to edit.** [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md) refuses any rod whose order differs from the established one; Q69 makes that wrong for the same-rod successor, but the correct replacement depends on the answer here. The minimum change when it lands: the `planning_routings` lookup returns **orders (plural)**, "belongs to the established order" becomes membership in an **ordered set**, and `RodStaging.OrderId` needs a defined meaning when a rod spans two — recommended as *the order this staging is being consumed for*, with the successor visible in the queue.

Related: **Q69**, **Q74**, **Q47** (partial rod carry-forward — the same physical remainder), **Q57**.

---

**Q80** · `High` · Owner: Tim O. / Charles / Juan · `Open`
**Shopfloor panel resolution — 1280×1024 (stocked) or 1920×1080 (required)?**

Every mockup is authored at **1280×1024**, `flat-wire-fit.js` measures against that design box and calibrates the 14 px minimum-text floor to it, and [phase-01a](../DevelopmentPlan/ShopfloorPlan/phase-01a-angular-foundation.md) pins *"fixed 1280×1024 shopfloor canvas"* as an acceptance criterion.

Tim expects the new flat wire screens to use the **same monitors as the current ones — 1280×1024, which is what UA stocks** — but will **verify with Charles and Juan** before confirming. Our action from the call: **send Tim the required resolution (1920×1080) by e-mail**; if that is what the application needs, he will look at different screens.

**Why this is `High` and time-critical:** 1920×1080 is a **1.5× width and 1.05× height** change, so it is a **re-layout of all 25+ screens, not a rescale** — the extra pixels are almost entirely horizontal. `flat-wire-fit.js` already degrades gracefully *downward* (it never scales above 1:1, and `data-fit="fill"` widens the design box to the window), so a wider panel is the cheap direction and the height barely moves. But the canvas is a **Phase 1 acceptance criterion** against a **14 Aug 2026 gate**, so an answer after Phase 1 closes is an answer that arrives too late to be free.

**Do not re-author anything until this is answered.**

Related: `flat-wire-fit.js`, [phase-01a](../DevelopmentPlan/ShopfloorPlan/phase-01a-angular-foundation.md), the 14 px minimum text floor.

---

**Q81** · `High` · Owner: Tim O. / Bob S. · `Open`
**Rod bundle gross weight — 8,690–8,840 lb or ~2,000 lb?**

Re-homed from **Q75** on Aug 1, 2026 so that it survives that question closing. Q75 decided that bundles are **not** stacked; the weight contradiction is independent of stacking and still unresolved.

The delivered contracts state received bundle gross weight **two incompatible ways**, against the 9,000 lb position rating in `PayoffPosition.MaxWeightLb`:

| Source | Rod gross weight |
|---|---|
| `GET /payoff/status`, `GET /staging/queue`, `POST /staging/rod` | **8,690 – 8,840 lb** |
| `GET /rod/{alpha}`, `POST /checkin/rod` | **2,000 lb** |

Same `R#####` series, same 0.375" diameter, **4× apart**. One set of examples in [APIContracts.md](../DevelopmentPlan/APIContracts.md) is wrong and must be corrected.

**It matters beyond the examples.** The payoff weight bar and the weld alerts are calibrated to it — warning below **3,000 lb**, critical when the other bay is unstaged and this one is below **2,000 lb**. Against 8,800 lb bundles those thresholds are correct; against 2,000 lb bundles the warning fires before the bundle is ever mounted and the critical never fires at all.

Related: **Q75** (closed), **Q6** (throughput rates — the same equipment-data gap), **Q36**.

---

**Q82** · `Medium` · Owner: Tim O. / Shray · `Open`
**Dashboard 1's "WIP Rejections" — is a rejection *list* screen in scope?**

Surfaced on Aug 1, 2026 when DB8 was converted from a screen into a dialog. The line status board's header carries a nav item labelled **"WIP Rejection*s*"** (plural), which reads as a **list of recorded rejections** — a screen that has never been specified, designed or scheduled. It pointed at the rejection **entry form**, and as a page that mismatch was invisible; as a dialog it is not, because a nav item that opens a blank entry form on a supervisor's overview board is plainly the wrong action.

Three possibilities, and they cost very different amounts:

1. **The label is wrong.** It always meant the entry form; rename it "WIP Rejection" and nothing else changes.
2. **A list is wanted and exists elsewhere.** Held/rejected material already has a queue implied by the Suspend disposition ("stays in WIP held queue until disposition decided") and by the supervisor's shift summary. If that queue is a real screen in another module, DB1 should link to it rather than duplicate it.
3. **A list is wanted and is new work.** A rejection register — filterable by line, shift, disposition and reason, with the QA disposition action on each row — is a screen, an endpoint and a phase owner that no phase currently carries.

Option 3 is the only one with schedule impact, and it is the one most consistent with the label. Until this closes the nav item opens the rejection dialog, which is what it did as a page.

Related: **Q72** (the staging rejection path), **Q50** (supervisor disposition of held material), **DB10** shift summary.

---

**Q83** · `Medium` · Owner: Tim O. / Bob S. · `Open`
**At cold start, should *Welds this run* be absent, or present and unavailable?**

Surfaced on Aug 1, 2026 when Dashboard 2A's **weld-readiness strip was removed** and its two controls moved onto the bay cards. *Welds this run* went onto the **active** bay card, because the run belongs to that bay. That placement is right whenever a run exists — and it has one consequence at cold start, where **no bay is active**: there is no card to host the control, so it is **not rendered at all**. Previously it was a station-level control, always present and shown greyed with the explanation *"no run in progress"*.

Both readings are defensible and they teach the operator different things:

1. **Absent** is the honest representation of the state. There is no run, so there is nothing to list, and a screen that offers no control makes that plain. It also follows from the placement rule without exception — every control sits on the thing it acts on, and there is no thing.
2. **Present and unavailable** teaches location. A new operator learns where the control lives *before* they need it, and the greyed tooltip explains the precondition rather than leaving its absence to be inferred. This is the argument that kept the disabled state on the old strip.

The same question does **not** arise for *Mark as welded*: it sits on the staged card, and at cold start nothing is staged either, so its absence follows from there being no card rather than from a design choice.

This supersedes **TC-068e**, which asserts the control is "disabled at cold start with *no run in progress*". **TC-068f** now tests the absent behaviour; whichever way this closes, one of the two is rewritten.

Related: **Q24**, **G27** (the *Rods In Queue* name collision), `FR-051a`.

---

**Q84** · `Medium` · Owner: Tim O. / Bob S. / Juan · `Open`
**Where should the operator land after pressing *Acknowledge & Begin Check-in*?**

Changed on Aug 1, 2026 from **Dashboard 3 (active run monitor)** to **Dashboard 2A (rod pre-check-in)**, and raised here rather than applied silently because it rests on an assumption about operator habit that we have not tested.

The reasoning for the change: check-in is complete the instant the button is pressed — records written, tags pushed, run open, rod drawing. The destination is therefore a question about what the operator does **next**, not about what check-in still owes. In the continuous-feed cycle the next task is staging the following rod on the idle payoff, which is Dashboard 2A. Landing there closes the loop — stage → check in → stage the next — on one path, instead of putting the operator on a monitor and leaving them to navigate back. Dashboard 3 stays reachable from the application bar and the line status board.

**The assumption that needs testing:** that an FL1 operator does not expect to *see* the run start. There is a real argument the other way — at start-up the operator may want to confirm the line took the tags, the mill is drawing and the gauge trace is live, and the monitor is where that is visible. If so, Dashboard 3 is the correct destination and this reverts to it.

A third possibility, if both are wanted: land on Dashboard 3 and offer a prominent return to the staging station, which serves the confirm-then-stage sequence without a navigation.

Note this is **navigation only** — no record, status, tag push or broadcast changes with it.

Related: `FR-079a`, **TC-079a**, **Q83** (the other DB2A behaviour raised by the same build).

---

**Q85** · `High` · Owner: Tim O. / Engineering · `Open`
**Is speed pushed to the PLC as a target/setpoint, or as a limit/clamp?**

Raised Aug 4, 2026 while consolidating the PLC tag surface into [PLCTagSpecification.md](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) (`PLC-Q06`). The delivered artifacts say both, and **the SRS contradicts itself**:

| Source | Wording |
|---|---|
| `02-SRS.md` §9.1 · `03-HLD` §9.2 · `04-APIContract` §6.1 · master spec §6.8 | speed **targets** |
| `02-SRS.md` `FR-073` · [RocCheckin.md](../LatestDocument/RequirementDocuments/RocCheckin.md) §3.6 | speed **limits** |

**These are not the same tag and they do not fail the same way.** A *setpoint* commands the drives to a speed; a *clamp* bounds whatever speed the operator selects. If the pass schedule's value is written to a setpoint tag when the machine expected a ceiling, acknowledging a check-in starts the line moving at the scheduled speed — which is a commissioning-time surprise on a threading line. If it is written to a clamp when the machine expected a setpoint, the line does not move at all and the fault looks like a missing tag.

Not resolvable from documents. It needs a controls answer, and it is the reason `FR-073`'s wording is left unfixed until this closes.

Related: **Q86**, **Q87**, `PLC-Q06`, `FR-073`, `OI-52`/**Q30** (roll-gap readback — the same "what does the machine actually accept" gap).

---

**Q86** · `High` · Owner: Tim O. / Engineering · `Open`
**Is edge type pushed to the machine, and where are the edger tag paths?**

Raised Aug 4, 2026 from the same consolidation (`PLC-Q07`). Two findings that only appear once the tag surface is read as one document:

1. **Edge type is in the push payload in four sources and absent from a fifth.** `02-SRS` §9.1, `03-HLD` §9.2, `04-APIContract` §6.1 and master spec §6.8 all list *edge type* among the values written at acknowledgement; [RocCheckin.md](../LatestDocument/RequirementDocuments/RocCheckin.md) §3.6 and `FR-073` do not. The likely explanation is that RocCheckin's list was written FL1-first and FL1 has no edger — but that is inference, not a confirmation.
2. **No edger tag path exists anywhere in the repo.** The only edger-adjacent tag in any published map is `FL1.EdgeSet.Status.Active` — on **FL1, the one line with no edger** (`D-20`/`D-21`, May 21 2026). FM2's edgers at S2 and S3 (the two 6″ stands) have no status, activation or blade-profile path. So the write side is specified to push an edge configuration to equipment that has no addressable tags on the read side.

Paths are **proposed** in `[PLC §4]` from the derived naming grammar (`FL2.FM2.S2.Edger.Status.IsActive`, `.Edger.Profile`, and the same for S3) so there is something concrete to confirm or correct, but they are our invention and are marked as such.

Related: **Q42** (edger blade profiles — the reference data these tags would carry), **OI-36** (the same stand has no roll-gap path either), **G29**, `PLC-Q07`.

---

**Q87** · `High` · Owner: Tim O. / Engineering · `Open`
**On FL3, are FM2 tags addressed as `FL2.FM2.*` or `FL3.FM2.*`?**

Raised Aug 4, 2026 from the same consolidation (`PLC-Q08`). Every published tag map writes the finishing-mill stands as **`FL2.FM2.…`** — including the map headed *"FL1 shown, other lines follow the same pattern"*. FL3 is the hybrid route and needs **both** FM1 and FM2 tags, pushed as a single batch on one acknowledgement (`FR-096`-adjacent; `phase-10:35`).

So one of two things is true, and no artifact says which:

1. **FM2 is physically owned by the FL2 controller**, and FL3 reaches it through the `FL2.*` namespace. The FL3 push then writes to **two controllers** in one logical batch — which is precisely the case where "the batch was rolled back" is least true (**G16**).
2. **FL3 has its own FM2 address space** (`FL3.FM2.*`), and the FL3 push is one controller.

**This is not a naming preference.** It decides whether the FL3 single-batch push crosses a controller boundary, which determines what partial failure looks like and what the compensating re-clear has to undo. Commissioning test **C5** — *"one acknowledgement configures FM1 and FM2"* — passes either way and therefore cannot distinguish them; it needs a step added once this is answered.

Related: **Q45** (FL1/FL2 simultaneous operation — the same controller-ownership question from the scheduling side), **G16**, **G30**, `PLC-Q08`.

---

**Q88** · `Medium` · Owner: Tim O. / Engineering · `Open` — **part 1 specified Aug 4, 2026**
**~~Are units carried in tag paths, or implied?~~ — implied. What unit are the values in?**

Raised Aug 4, 2026 from the same consolidation (`PLC-Q15`). The paths were inconsistent: **`FL1.Speed.FPM`** and **`FL1.Payoff1.Weight.Lb`** named their unit in the path, while gauge, width, roll gap and die diameter did not (`FL1.AGC.Gauge.Current`, `FL1.FM1.RollGap.Current`, `FL1.DB1.Die.ActiveDiameter`) and were assumed to be inches.

**Part 1 — specified, not confirmed (Aug 4, 2026).** **Units never appear in the path.** `Speed.FPM` → `Speed` and `Payoff{n}.Weight.Lb` → `Payoff{n}.Weight`, making the convention uniform across all nine measures. This is **our specification, `[PROPOSED]`**, published as rule **R7** in `[PLC §4.2]` and carried on the sign-off sheet — it is not a client answer, and it departs from two strings that had been `[CONFIRMED]` by observation. See **Q95**, which owns the whole measure-grammar reshaping.

**Part 2 — open, and it is now the whole question.** **What are the values actually in?** Inches is the assumption throughout, but a controller reporting gauge in **mils** or **thousandths** is entirely normal on a flattening line, and nothing states the unit. A silent 1000× error on gauge would pass every structural check, push a plausible roll gap and produce out-of-spec wire.

**Removing the suffixes made part 2 more load-bearing, not less** — with `.Lb` and `.FPM` gone, **no tag on the surface declares a unit at all**, so there is nothing left in the address to cross-check a misconfigured scale against. `PLC-Q15` was accordingly raised from Medium to **High** in the tag specification's own register.

Best answered at commissioning test **C1** where every path is read back anyway — but it should be asked before then, because the *display* code assumes inches now.

Related: **Q85**, **Q86**, **Q87**, **Q95**, `PLC-Q15`, `OI-45`/**Q36** (footage-to-weight — the other place a unit assumption is load-bearing).

---

**Q89** · `High` · Owner: Tim O. / Bob S. / Engineering · `Open`
**Do take-up load cells exist, and is the spool-completion weight read from them or derived from footage?**

Raised Aug 4, 2026 by the audit of [PLCTagSpecification.md](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) (`PLC-Q14`). Two artifacts disagree about where the most consequential number in the completion transaction comes from.

| Source | Says |
|---|---|
| The tag specification’s assumption **A2** — rescued from the deleted `HMIAndSCADALayout.md`, which was its **only** home | “Load cells are fitted on both payoff positions **and on both take-ups**” |
| [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) §“Weight” | The weight is “**derived from the live footage counter and the measured cross-section**” |

**And the tag map contains no take-up weight path on any line.** So the interface currently specifies a behaviour — the machine-stop prompt fires when the take-up weight reaches target, and the latched value is what the completion records and the **printed label** carries — that reads a value with no published source.

Three things follow from the answer:

1. **If the weight is derived**, A2’s take-up load cells are real hardware that this interface never reads, and the accuracy of every completion weight rests entirely on **Q36 / `OI-45`** (the footage-to-weight dimensional basis) — already **Critical** and already open.
2. **If the weight is read**, two tag paths are missing from the map and must be added before commissioning test **C9** can pass.
3. **If both exist**, which one is authoritative when they disagree? The spool completion spec already has a scale-versus-calculated reconciliation question open as **Q66**, and this is the same question one step upstream.

Not decided in the specification on purpose: it is answerable from `SpoolCompletionNotification.md` alone only if that document’s derivation is known to be the *whole* story, and A2 says it may not be.

Related: **Q36** / `OI-45` (footage-to-weight basis), **Q66** (scale vs calculated spool weight), **Q58** (OD→weight formula), `PLC-Q03`, `PLC-Q14`.

---

**Q90** · `Critical` · Owner: Tim O. / Engineering · `Open`
**Confirmation of every machine tag path with the controls commissioning engineer**

Raised Aug 4, 2026 by the audit (`PLC-Q02`). This has been an outstanding action since **15 May 2026** and has never had a register entry — it existed as an untagged row on a client sign-off sheet in `HMIAndSCADALayout.md`, and after that file was deleted it survived only as prose in the master specification and inside the tag specification itself.

**That is the exact failure the register exists to prevent**, and it applies to the single most important confirmation in the PLC interface: every tag path published in `[PLC §5.2]` follows **a proposed naming convention, not a verified map**. None has been read off a controller.

Until it closes:

- **C1** (“read every configured tag path in turn”) is the first commissioning test and has no confirmed list to read from.
- A wrong path fails **silently** — the write reports success, nothing changes on the machine, and the line runs on whatever it was last set to. That is classified **Severity 1**.
- The correction cost is deliberately low: paths are configuration, so a wrong one is a config edit and a pool recycle, not a redeployment. **The risk is not the fix; it is not knowing.**

**The specification now states this rather than obscuring it (v1.0, 4 Aug 2026).** The `[CONFIRMED]` tag has been **retired from the document entirely** — the count of confirmed rows in the tag map is **zero**, and the Reading Convention says why: nothing has been agreed as a *string* with United Aluminum or read off a controller, so the tag would have no members. Previously eight items carried it, on the strength of the Reading Convention's second limb — *"or stated consistently across the source specifications"* — which allowed three internal copies of one unverified table agreeing with each other to read as confirmation. **That limb was the mechanism by which this question stayed invisible for eleven weeks**, and it is gone. A path becomes confirmed when **C1** or **C11** reports that the controller accepted it, and not before.

Related: **Q4** (superseded — this is the surviving half of it), **Q95**, `PLC-Q02`, commissioning test **C1**, `FR-022`.

---

**Q91** · `Medium` · Owner: Tim O. / Engineering · `Open`
**Ordinal naming convention — digit-suffixed element, or station segment?**

Raised Aug 4, 2026 by the audit (`PLC-Q17`). The observed tag paths use **two incompatible conventions for the same idea** — “the *n*th instance of a thing”:

| Convention | Examples | Rule |
|---|---|---|
| Digit suffixed onto the element name | `DB1`, `DB2`, `Payoff1`, `Payoff2`, `TKUP1`, `TKUP2` | R8 |
| A separate station segment | `FM2.S1`, `FM2.S2`, `FM2.S3` *(observed as `FM2.Stand8`, `FM2.Stand6S1`, `FM2.Stand6S2` — renamed 4 Aug 2026, `PLC-Q04`)* | R7 |

Both are defensible; they cannot both be the convention. It matters because the specification asks the client to confirm **the grammar** rather than thirty individual strings — that is the whole economy of the approach — and a grammar with two contradictory ordinal rules cannot be used to derive the paths that are still missing.

**Our resolution (Aug 4, 2026, `[PROPOSED]`) — they are not rival conventions.** The digit-suffix rule is adopted as *the* ordinal rule: **the *n*th instance of a piece of equipment suffixes its digit onto the element name** — `DB1`, `Payoff2`, `TKUP1`. The station segment is a **different** matter — the internal stations of one assembly — so `FM2.S1/S2/S3` stands unchanged and the two rules govern different things rather than competing. Nothing in the tag map moves as a result.

**This is our reading, not the client's answer, so the question stays `Open`** and both rules remain `[PROPOSED]` on the sign-off sheet. **If the machine's own addressing follows something else, we follow the machine** — commissioning test **C1** now records the string the controller accepted for every path, which is what closes this.

**Rule renumbering.** With the two rules that the reshaping withdrew removed rather than struck through (the client deliverable carries no superseded content), `[PLC §4.2]` is renumbered **R1–R8**. The two rules this question is about moved: **old R7 → R5** (assembly stations) and **old R8 → R6** (ordinals). Old R2 is unmoved, so **Q92**'s citation still reads correctly. Full mapping: R1–R4 unchanged in position (R4 rewritten), old R5 and R6 withdrawn, old R7→R5, old R8→R6, old R9→R7, and a new R8 states the bare-analogue rule.

Related: **Q88** (units in the path — the other naming-convention question, answerable in the same conversation), **Q90**, **Q95** (the measure-grammar reshaping that renumbered these rules), `PLC-Q17`.

---

**Q92** · `High` · Owner: Tim O. / Engineering · ~~Open~~ **`DECIDED Aug 4, 2026`**
**~~Is `ITInhibit` plant-level or line-scoped?~~ — line-scoped: `FL1.ITInhibit` and `FL2.ITInhibit`**

**Decision (client, Aug 4, 2026).** The interlock is **one tag per line** — **`FL1.ITInhibit`** for FL1 and **`FL2.ITInhibit`** for FL2. A line blocked from running blocks **only itself**.

Raised the same day by the audit (`PLC-Q18`). **Every tag in every source was prefixed with its line — except this one**, written bare as `ITInhibit` in all six of the pre-consolidation copies. That left two readings, and one of them was a plant-stopping defect:

1. **It is genuinely plant-level.** Then one line’s unmet prerequisite — no rod checked in, no active MMS ID, missing feet data — **blocks all three lines from running**. It would have been discovered the first time FL1 sat idle while FL2 was scheduled.
2. **Every document has recorded it wrong**, and it is `FL{n}.ITInhibit`. ← **This one.**

The tag specification had proposed the line-scoped form as an inference from the naming convention; it is now confirmed rather than inferred. **Two consequences beyond the tag itself.** Rule **R2** in `PLCTagSpecification.md` §2.2 — *"the first segment is always the line; there is no plant-level tag"* — was `[PROPOSED]` **solely because of this counterexample**, and is now `[CONFIRMED]`, which strengthens every path derived from the grammar rather than observed (the whole economy of confirming a convention instead of ~60 strings, **Q90**). And the interlock is now **testable per line**: commissioning test **C7** sets each of the five conditions on one line and asserts the other two still run.

**One residual, on FL3 only.** FL3 spans both mills, so whether it carries `FL3.ITInhibit` or asserts FL1's and FL2's together follows from the FL3 namespace question, **Q87** / `PLC-Q08` — the same question that decides whether FL3's single-batch push crosses a controller boundary. This is the one line where a blocked line legitimately implicates a second, because on FL3 the two are one physical thread of material.

**Where this now lives.** It was originally recorded as decision `D15` in the tag specification's decision log, with the question carried as `PLC-Q18`. The **v1.0 reissue (4 Aug 2026) removed both** — the decision log went with the document's revision history, and a decided question does not belong in a register of open items. The rule is now **normative prose in `[PLC §8.1]`**: *"It is one tag per line — `FL1.ITInhibit`, `FL2.ITInhibit` — so a line blocked from running blocks only itself."* Commissioning test **C7** was tightened to prove it per line. **This entry is the audit trail for the decision; the specification is the statement of the rule.**

Related: `FR-008`–`FR-010`, `FR-020`, **Q87**, **Q90**, commissioning test **C7**, `PLC-Q08`. *(`PLC-Q18` is retired — see above.)*

---

**Q93** · `Critical` · Owner: Tim O. · ~~Open~~ **`DECIDED Aug 4, 2026`**
**~~FM2 roller sizes~~ — FM2 has three stands: `S1` = 8″, `S2` = 6″, `S3` = 6″**

**Decision (client, Aug 4, 2026).** FL2's finishing mill FM2 has **three stands**. **S1 carries the 8″ roller; S2 and S3 carry 6″ rollers.** Edgers remain at **S2 and S3 only**, and **S3 remains the final, non-bypassable gauge-control stand**. FL3 drives the same FM2. FL1's FM1 is unaffected at 12″.

**Why this was a repo-wide change and not a digit swap.** The May 21 2026 equipment correction was recorded in `00-foundations.md` §0.3 as *"FM2 has **three** 6″ stands (S1, S2, S3)"*. That was read as **a separate 8″ roller upstream of three 6″ stands — four components** — and the reading propagated into roughly fifty files, the `Stand` seed data, two SQL `CHECK` constraints, the `ComponentName` enum, the PLC tag grammar and eight mockups. The 8″ roller **is S1**, and the fourth stand does not exist.

Three pieces of evidence fix the mapping:

1. The client's **published PLC map has exactly three FM2 stations** (`Stand8`, `Stand6S1`, `Stand6S2` — all `[CONFIRMED]` by observation). Three observed stations, three real stands.
2. **Every seeded pass schedule has exactly three FM2 component rows**, with a monotonically descending gap chain.
3. **`FM2_6inS3` never had a tag path or a seed row** — its absence was itself logged as `OI-36` and `G29`. It is the invented one.

**Consequences.** Component names become **position-only** (`FM2_S1` / `FM2_S2` / `FM2_S3`) and roll diameter becomes data in a new **`Stand.RollDiameterIn`** column — diameter inside the identifier is what let the misreading survive ten weeks. Mapping: `FM2_8in`→`FM2_S1`, `FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`, `FM2_6inS3` withdrawn. `Stand.Id` 1–4 keep their meaning; Id 5 is removed. **No gap or gauge value is recomputed** — the seeded three-row chains were always valid and `FR-387`'s multipliers (1.06 / 1.02 / springback) simply move from diameter labels to positions, which incidentally fixes a defect where FM2's final stand had no gap formula.

**Two open items close, and neither was ever a real defect.** **OI-04** — *"is the mandatory stand `FM2_6inS2` or `6″ S3`?"* — both named **the same physical stand**; only the phantom made one answer look like two. **OI-36** — *"the final stand has no tag path"* — the published map was complete; the stand with no path was the one that does not exist.

**One physics consequence.** Roll radius is a real input to the generation engine. The bite condition `Δh ≤ μ²R` is linear in `R`, so **S1 admits ~1.33× the draft** of a 6″ stand, while contact length `√(R′·Δh)` means it develops **~1.16× the separating force** at equal draft. `F_max` and mill modulus must therefore be supplied **per stand** (`PSG-D10`, `PSG-D12`), and `PassScheduleGenerationSpec.md` §3.3.5's allocation illustration is recomputed at `k` = 3 (**5.4% / 9.8% / 13.5%**, was 4.1% / 7.5% / 10.4%).

**Successor question: Q94 / `PLC-Q04`** — the PLC station rename departs from observed `[CONFIRMED]` strings and needs the controls engineer's sign-off.

**How this decision is presented to the client (v1.0, 4 Aug 2026).** The tag specification's equipment table — the three stands, FL1 having no edger, FL2 having no live measurement — **carries no status tag at all.** It previously read `[CONFIRMED — August 4, 2026]`, and when the `[CONFIRMED]` tag was retired the stamp was **removed rather than downgraded**, precisely so the deliverable does not describe the client's own correction as our proposal. The equipment description now reads as a statement of fact and is accepted via **Part A of the sign-off sheet**. **The decision itself is unchanged and still client-sourced; only the label is gone.**

Related: `D-26` (master spec §10.2), **OI-04**, **OI-36**, **Q94**, `PLC-Q04`, gap **G32**, commissioning test **C11**.

---

**Q94** · `Critical` · Owner: Tim O. / Engineering · `Open`
**Confirm the FM2 PLC station rename — `S1`/`S2`/`S3` or the controller's own names?**

Raised Aug 4, 2026 as the successor to **Q93**. The controller's **observed** station names are `Stand8`, `Stand6S1` and `Stand6S2`; the tag specification now specifies **`S1`, `S2`, `S3`**, on the grounds that the 8″ roller is stand one and roll diameter belongs in machine data rather than in an address.

Every FM2 row in `[PLC §5.2.2]` is `[PROPOSED]` until this is answered. If the controls engineer prefers the machine's existing names, reverting is a three-string edit. **The stand count and the roller diameters are not in question** — only the names.

**No longer the only such departure, and no longer shown as a diff.** Two things changed on Aug 4 after this question was raised. First, **Q95**'s measure-grammar reshaping departs from **thirteen** observed `[CONFIRMED]` strings against this question's three, so the FM2 rename is now the smaller of two departures. Second, the client deliverable **no longer publishes the observed names at all** — `[PLC §4.3]`'s as-published → as-specified table, the `observed as FM2.Stand8` footnotes on the nine FM2 rows, and the two-column wording of `PLC-Q04` on the sign-off sheet were all removed, because neither client-facing artifact may carry old/new content. **The observed strings are `Stand8`, `Stand6S1` and `Stand6S2`, and this register is now the only place they are recorded.** Recovering them for a revert means coming here or to git.

Related: **Q93**, **Q90**, **Q91**, **Q95**, `PLC-Q04`, gap **G32**, commissioning tests **C1** and **C11**.

---

**Q95** · `Critical` · Owner: Tim O. / Engineering · `Open`
**Confirm every measure name in the tag map — the measure segment was reshaped on our own reading**

Raised Aug 4, 2026 (`PLC-Q05`). The **measure** segment of every tag — the part after the line and the element — was respecified on the same day, from six corrections applied and then generalised across all three lines. **This register is the only record of what the strings were**, because neither client-facing artifact may carry old/new content.

| Old measure | New measure | Rule |
|---|---|---|
| `.Status.Active` | `.Status.IsActive` | R4 |
| `.Status.Fault` | `.Status.IsFaulted` | R4 |
| `.RollGap.Current` | `.RollGap` | R8 |
| `.Gauge.Current` | `.Gauge` | R8 |
| `.Width.Current` | `.Width` | R8 |
| `.Footage.Current` | `.Footage` | R8 |
| `.Die.ActiveDiameter` | `.Diameter` | R8 |
| `.Weight.Lb` | `.Weight` | R7 + R8 |
| `.Speed.FPM` | `.Speed` | R7 |
| `.Profile`, `.LineState`, `.ITInhibit` | *unchanged* | — |

Element and station segments are untouched — `DB1`, `Payoff2`, `TKUP1`, `FM2.S1/S2/S3` and `Edger` all stand (**Q91**, **Q94**). The reshaped surface is **41 paths**: FL1 15, FL2 14, FL3 23.

**Why this is Critical rather than cosmetic.** **Thirteen FL1 rows were `[CONFIRMED]` by observation** — every confirmed string on the surface except `FL1.LineState` and `FL1.ITInhibit` — and all thirteen are now `[PROPOSED]`. Where **Q94** departs from three observed strings, this departs from thirteen, and the failure mode is different in kind: if the controller really does use `Status.Active` and `.Current`, commissioning test **C1** fails **across the whole map on all three lines**, not on isolated rows. A wrong path fails silently — the write reports success and the line runs on whatever it was last set to, classified Severity 1.

**Two specific things to put in front of the controls engineer:**

1. **The analogue/boolean asymmetry is deliberate**, and worth confirming as a shape rather than row by row: booleans keep a `Status` group segment and take an `Is` prefix, while analogues are a single bare segment. The reasoning is that `Status` names a *kind* of signal, whereas a present-value suffix, a unit and a qualifier each restate something a live tag already says.
2. **`Diameter` assumes one diameter per die block.** The old string was `Die.ActiveDiameter`, and the qualifier's stated purpose was to distinguish the *fitted* die from a scheduled one. The new rule (**R8**) carries that meaning by asserting the tag *is* the present value — the machine holds no scheduled die. **If the controller in fact exposes more than one diameter per die block, `Diameter` is ambiguous and the qualifier has to come back.**

Note also that **`ActiveDiameter`** and a bare **`Active`**/**`Fault`** were intermediate forms during the same exchange and were corrected before being written anywhere; neither should appear in any artifact.

Closed by commissioning test **C1**, which now records the string the controller accepted for every path. Carried on the tag specification's sign-off sheet as `PLC-Q05`.

Related: **Q88** (units — part 1 of it is one line of this table), **Q90** (no path has been read off a controller), **Q91** (the rules and their renumbering), **Q94** (the FM2 station names — the other departure), `PLC-Q05`, gap **G33**, commissioning test **C1**.

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
| Jul 28, 2026 | Analysis team | Added **Q60–Q62** from the spool completion alert requirement ([SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md)): target weight source and over-target behavior, applicability to finished coils at TKUP-2, supervisor mirroring and acknowledgement audit persistence. Total questions: 62. |
| Jul 29, 2026 | Analysis team | Q60 updated with the assumed **2,000 lb** default target spool weight. Added **Q63–Q65** from the machine-stop confirmation requirement (Part B of [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md)): `FL{n}.LineState` vocabulary + stop dwell + pause-reason suppression, supervisor visibility and multi-operator arbitration of the prompt, and the short-close-below-target path. Total questions: 65. |
| Jul 29, 2026 | Analysis team | Added **Q66** — scale-vs-calculated spool weight reconciliation on the completion step: variance tolerance (±2 % proposed), which weight is the default basis, whether an out-of-tolerance variance needs supervisor approval rather than just a reason, and whether a scale exists at the take-up at all (overlaps Q47, feeds Q58). Total questions: 66. |
| Jul 29, 2026 | Client direction | **Q66 part 3 Decided**: an out-of-tolerance spool weight must not block spool creation — the completion is authorised by a **supervisor override** (reason + badge/ID + PIN, remote-approval fallback) and the override is recorded on the spool. Q66 now In Progress; tolerance value, default basis, scale availability and PIN validation source remain open. |
| Jul 29, 2026 | Analysis team | Added **Q67–Q70** from the pre-check-in / payoff-staging build ([RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md)): coil status at staging (`INFLAT` per SRS §4.2 vs `STAGED` per the process walkthrough, and what reverses it — **Critical**, blocks the Phase 4 staging build), whether pre-check-out needs supervisor approval (contrast Q48 for mid-run), staging against a future order and its effect on weld selection, and the scope of `RodSeqno`. Also noted: pre-check-out has **no SRS requirement ID** — §4.17 covers only post-check-in removal, so a new `PCI`-series block is needed. Total questions: 70. |
| Jul 29, 2026 | Analysis team | Added **Q71–Q73** from the Dashboard 2A mockup review: rod diameter tolerance (`CHK007`) has **no column anywhere in the schema** — `AlloyProperty` carries only gauge/width, which are flat-wire *output* dimensions, so the mockup had hard-coded a single 0.005" that is wider than every value in the standards table; whether a failed staging inspection persists a `RodStaging` row at all, given that the UI/API `Blocked` bay state is derivable (`Staged` + any `Fail`) but nothing currently writes it; and which WIP station FL3 pre-check-in posts to, since the schema/DDL/API all scope staging to FL1 **and FL3** while only `FL1PO` is seeded and no `FL3PO` exists. Total questions: 73. |
| Jul 29, 2026 | Client requirement | **Free rod processing order.** Planned rod sequence is explicitly **not enforced** — the operator may process rods in any order; staging validates only current-order membership and availability, and must never block because an earlier-planned rod is unprocessed. Both sequences are retained: planned for planning/reporting, actual in the transaction history for traceability. **Q70 partly resolved** — reframed from "what is `RodSeqno`'s scope" to "which of two sequences is it"; `RodSeqno` is now the *actual* sequence and a new `RodStaging.PlannedSeqno` snapshots the planned one. **Q69 leaning "no"** — validation is scoped to the *current* order, which makes a future-order rod a non-candidate; not closed, because continuous feed then cannot cross an order boundary and that consequence needs confirming. |
| Jul 29, 2026 | Client direction | **Q74 added, part-decided.** Rod→order resolves from **`planning_routings`** at pre-check-in / check-in, so the order is *revealed* by the scan rather than chosen — which makes the first rod on a cold line validatable and removes the need for an order chooser. A rod whose order is scheduled on **another line** is **not refused**: the operator is notified and a **supervisor override** (reason + badge/ID + PIN, remote-approval fallback — the Q66 pattern) authorises it, with the override, supervisor and reason recorded on `RodStaging`. Still open: PIN validation source (shared with Q66), whether the mid-order cross-order case should also be overridable given the weld/genealogy constraint, applying the same panel at Dashboard 2, whether scheduling gets corrected, and whether the other line's operator is notified. |
| Jul 30, 2026 | Analysis team | Added **Q75** — whether multiple rod bundles can be **stacked on a single VPS payoff position**. Every artifact assumes one bundle per bay (`UX_RodStaging_Bay` enforces it as a filtered unique index), but nothing states whether that is the equipment's limit or a modelling assumption, and eye-to-sky is the geometry in which stacking is standard practice. The resolving fact — received bundle gross weight — is stated **two incompatible ways** in the delivered contracts: **8,690–8,840 lb** in `/payoff/status`, `/staging/queue` and `/staging/rod` versus **2,000 lb** in `/rod/{alpha}` and `/checkin/rod`, against a 9,000 lb position rating. That contradiction matters independently of stacking, because the payoff weight bar and the weld alerts (warn 3,000 lb / critical 2,000 lb) are calibrated to it. Recorded the four schema consequences if stacking is real, and flagged **`CK_WeldEvent_PayoffDiff`** as worth relaxing pre-emptively — it rejects an in-stack weld outright, and the real invariant is that the rod *alphas* differ, not the bays. Total questions: 75. |
| Jul 30, 2026 | Analysis team | **Scoped the register to shopfloor.** Added a `Scope` column to the Quick Reference table and a **Shopfloor Scope — Filtered Index** section at the top: **48 of 75** questions relate to Flat Wire Mill shopfloor changes (35 Open/In Progress, 13 Decided); the other 27 belong to adjacent modules and are marked `Other`. **Nothing was deleted** — this Change Log cites question numbers throughout, and `OQ-##` references point inbound from the phase files, `REVIEW.md` and the master specification, so the numbering must stay contiguous. Filter rule: `Shopfloor` if a Dashboard 1–14 screen reads, validates against or writes it — which keeps reference data and equipment limits in scope (Q32, Q36, Q38, Q41) and leaves scheduling representation (Q10), pre-scheduling validation (Q53) and order-entry behaviour (Q9, Q11, Q12) out. Also corrected the **Q4** Quick Reference row, which still read `Open` although its detail entry records it **Decided May 15, 2026**. |
| Jul 31, 2026 | Analysis team | **Q72 items 1–2 decided; Q76–Q77 added** from the Dashboard 2A UX review (`Dashboard2A_UXReview.md`, deleted 1 Aug 2026 — in git history at `2a0426b`). **Q72:** `Blocked` confirmed **derived**, and pre-check-in now **commits the `RodStaging` row before the inspection gate** — `POST /staging/rod` returns `201` with `state: "Blocked"` instead of `422`-and-write-nothing. The deciding argument is physical: a bundle is not unbanded until it is on the payoff, so a rod that fails inspection is already in the bay, and writing no row made `GET /payoff/status` report an occupied position as `NotStaged` and let the next rod be staged into it. `CHK010` unchanged (no bypass). Item 3 — *what releases a blocked row* — is now the blocking residual: `Status` has no value for a WIP-rejection outcome and inventing one would move the row outside `UX_RodStaging_Bay`'s filter, freeing a bay that is not free. **Q76:** `UX_RodStaging_Bay` is keyed `(LineId, PayoffPosition)` while `CK_RodStaging_LineId` admits both `FL1` and `FL3` — so if the two lines share one physical VPS (the assumption everywhere, and why `FL3PO` was never seeded, Q73), **two rods can be staged on one physical bay with every constraint satisfied**. Not covered by G20, which settled payoff-position vocabulary rather than uniqueness scope; logged as **G21**. **Q77:** a welded rod could be un-staged from the queue — welded is `IsWelded` on a `Staged` row, so every "staged" control matched it — despite being physically welded to the rod in the mill; the control is removed, but `WLD011` (supervisor reversal of a weld) remains unspecified. Total questions: 77. |
| Jul 30, 2026 | Client direction | **Q74 extended — out-of-planned-sequence now requires supervisor authorisation.** The operator is notified when the rod is not the one planning expects next, and a supervisor override is required to depart from the planned sequence — same credential block as the off-schedule override (reason + badge/ID + PIN, remote-approval fallback), recorded as `RodStaging.OutOfSequenceOverride` + `ExpectedRodAlpha`. Two deviations can co-occur and share one sign-off. **This supersedes the earlier free-processing-order requirement** (Q70), which had the operator re-sequencing at will with no warning and no override; both sequence columns are retained regardless, so the deviation is now authorised as well as recorded. |
| Jul 30, 2026 | Client direction | **Eleven answers from the 30 Jul call — six questions closed, three reversals.** **Q75 Decided:** rods **cannot be stacked**; only two rods at a time, one per payoff, as on the mills — the weight contradiction inside it is re-homed as **Q81**. **Q74 off-schedule REVERSED:** no blocking message and no supervisor override — the system **auto-selects the correct station** (FL3-planned rod scanned on the FL1 tab switches the tab), at both pre-check-in and check-in. Out-of-sequence override stays, provisionally, with a re-review committed. **Q72 item 3 Decided:** a failed staging inspection is captured as a rejection with a reason on the rejection screen and the rod goes to **`HOLD`** — that is what releases the row and frees the bay. **Q67 Decided (Critical):** `INFLAT` is set **only at check-in**, no intermediate status for welded-but-not-checked-in — reverses the interim SRS-following design and unblocks Phase 4; the reqsum / `wip_coil_orders` residual stays open. **Q71 shape Decided:** min/max tolerances exist for **gauge, width, diameter and ovality**, held in the lookup, applied at both pre-check-in and check-in — values to follow by e-mail, so nothing is to be seeded. **Q69 Decided:** a rod may carry **more than one order**, which inverts the "current order only, else refuse" rule; sequencing deferred to **Q79** and possibly MVP2. **Q68 Decided:** pre-check-out needs supervisor approval **only when the rod is welded**, where it is a rejection to `HOLD` — which also **decides Q77** and reverses the Jul 31 removal of the welded-rod Unstage control. **Q65 Decided:** short close is an **unplanned stop** on the mill 10-90 pattern, graded against the **customer min/max weight**, outside-range needing supervisor override + hold or a concession offer, with the spool run off regardless and a mid-run coil break restarting the stop **from zero**. **Q60 basis Decided:** the 2,000 lb default target is withdrawn in favour of the customer weight range. Added **Q78** (rod scheduled on neither FL1 nor FL3 — not covered on the call), **Q79** (multi-order sequencing / MVP scope), **Q80** (panel resolution 1280×1024 vs 1920×1080). Total questions: 81. |
| Aug 1, 2026 | Project decision | **`OffSchedule*` columns dropped.** With Q74's off-schedule case becoming a navigation behaviour, `RodStaging.OffScheduleOverride`, `ScheduledLineId` and `CK_RodStaging_OffSched` are removed and `CK_RodStaging_Override` reverts to keying on `OutOfSequenceOverride` alone. The analysis recommendation had been to retain them unwritten against **Q78**; the project decision is removal, so Q78 re-adds a column group if it ever needs one. **`OverrideBy` / `OverrideAt` / `OverrideReason` survive** — they are shared with the out-of-sequence override, and dropping them would delete the surviving override's audit trail. Propagation across the schema, contracts, mockups and the July 30 project-plan set is sequenced in [ClientCall_2026-07-30_SyncPlan.md](ClientCall_2026-07-30_SyncPlan.md). |
| Aug 1, 2026 | Project decision | **Weld quality is captured at the weld; `Q24` widened.** Dashboard 2A's Mark as welded dialog now requires a **Pass/Fail** result with a reason mandatory on Fail (`WLD013`), using the same six reasons as Dashboard 4 — so one physical join is documented identically wherever it is captured. Quality was the only NOT NULL `WeldEvent` column that dialog lacked, so **`POST /weldevent` becomes the single weld write** and `POST /staging/rod/mark-welded` is **retired**; the `RodStaging` weld columns are set in the same transaction, **on a Pass only**. This closes `WeldEventPopupPlan` **Q-W1** ("is a quality result at weld time acceptable on the floor?" — yes) and confirms its decision **D-A**; it needs **no schema change**. **A failing weld does not mark the rod welded** — the join did not hold, so the position keeps reading *not yet welded*, the station states the failure and its reason, and the operator remakes the weld. That last rule **widens Q24** rather than adding a question: a remade weld leaves **several `WeldEvent` rows for one physical join**, which is the re-weld-on-certificate question Q24 already asks — now reachable two ways (a weld that breaks mid-run, and a weld that fails its quality check before anything runs through it). Footage attribution across the two boundaries belongs to **Q22**. Total questions: 81. |
| Aug 1, 2026 | Build decision | **DB6, DB8 and DC converted from screens to dialogs.** SPC checkpoint, WIP rejection and die change are now popups (`spc_checkpoint.js`, `wip_rejection.js`, `die_change.js`) raised over the screen the operator is already on, rather than pages navigated to. The reason is context: WIP rejection alone is reached from five places and, as a page, could describe only one — its material banner was hard-coded to *R00042 at 8,220 ft*, and the **Q72 item 3** pre-check-in path (rejection releases the bay, rod to `HOLD`) could not be represented at all. It now is: on that path `runId` and `footagePosition` are `null`, the dialog states on screen that submitting releases the bay, and it reports `releasesBay` back to the staging station. Two hand-offs the spec always described also start working — a gauge-drift/size-change die change opens the SPC checkpoint it mandates (**Q56**), and an out-of-spec checkpoint's *suspend material* opens the rejection with the failing reading carried over. **No dialog scrolls**: an oversized popup is scaled to fit the window, since an operator in gloves cannot drag a scrollbar to reach *Confirm*. Added **Q82** — DB1's "WIP Rejection**s**" nav item reads as a list screen that does not exist. Total questions: 82. |
| Aug 1, 2026 | Build decision | **Dashboard 2A's weld-readiness strip removed; every control moved onto the bay it acts on.** The 96px band between the payoff cards and the traveler queue is gone. Its narrative was already duplicated by the cards in every branch but one — weight and percentage on the payoff bar, all four weld states in the bay alert, cold start in the empty-bay text — and the exception, *induction-weld tail to head*, became the staged card's alert while a rod is running. **Mark as welded** moved to the **staged** card (`PCI008` defaulting; all five disabled-tooltips kept, since they are the only statement of *why* it is unavailable) and **Welds this run · N** to the **active** card. The reclaimed space went to the queue, which is ~108px taller. Also removed: the **Open active run** link on the active card (`FR-051b`) — the run monitor is reachable from the app bar and Line Status, and this station's job is staging the next rod. The queue gained a standing **"Rods In Queue"** heading. Separately, Dashboard 2's *Acknowledge & Begin Check-in* now returns to **Dashboard 2A** rather than Dashboard 3 (`FR-079a`). Added **Q83** (at cold start *Welds this run* is now absent rather than shown-and-greyed — supersedes **TC-068e**) and **Q84** (whether the operator should land on the staging station or the run monitor after check-in). New requirements `FR-050a`, `FR-051a`, `FR-051b`, `FR-079a`; new cases TC-068f/g/h/i and TC-079a. **Note for G27:** the queue heading reuses the name *Rods In Queue* from the retired Dashboard 4 accordion but is **not** that control — it is a read-only table with no drag and no undo, so the re-sequencing capability remains homeless. Total questions: 84. |
| Aug 2, 2026 | Client direction | **Q57 part-decided — FL2 has two spool statuses and runs one spool at a time.** FL2 has no space to stage material, so a spool is either waiting for the line or on it: the operator-visible vocabulary is fixed at **`Ready for FL2`** (`RECEIVED`) and **`Checked in`** (`INFLAT`), and **`STAGED` is never set at FL2** — the "At TPO" status is withdrawn from the spool queue, staging remaining the FL1 concept per `PCI002`. **Check-in is exclusive:** while any spool is checked in, **no spool offers a check-in action** — not the others and not the checked-in one — and it returns only on checkout. Applied to [dashboard_5a_spool_queue.html](../Mockups/dashboard_5a_spool_queue.html) (lock bar, checked-in row sorted first with a *View run* action, `HOLD`/`COMPLETE`/`SCRAP`/`STAGED` pills removed) and [SpoolQueue.md](../LatestDocument/RequirementDocuments/SpoolQueue.md) v1.1 §3.5, rules **SQ-7**–**SQ-10**. **Q57 stays In Progress** — this fixes what the FL2 operator *sees*, not what is stored, and **OI-06**'s two rival vocabularies are still unmapped. **Two residuals with no owner yet:** exclusivity has **no backing constraint** (`dbo.Spool` has no filtered unique index on `Status` and **no `LineId` column at all**, so "one checked-in spool per line" is not currently expressible — `POST /checkin/spool` must return `409` on the second attempt); and a **quality-held spool now has nowhere to appear** on a two-status queue, raised to the client as SpoolQueue.md open item 6. Total questions: 84. |
| Aug 4, 2026 | Client direction | **HMI/SCADA descoped — `Q4` superseded.** The client confirmed that **SCADA Trends (DB14)**, the **HMI Line Schematic (DB13)** and the **Machine View tab** on the active run monitor are **not required**. `HMIAndSCADALayout.md` and both mockups are deleted; `FR-111`, `FR-112`, `FR-114`, `FR-440`–`FR-451` and `FR-460`–`FR-470` are marked withdrawn rather than renumbered. **`Q4` is superseded, not deleted** — its chart-layout half is moot because there is no chart layout to own, but its *other* subject, "machine tags for flat wire", survives: those tags are still read by the run monitor, the line status board, the rod-checkout gatekeeper, the spool stop prompt and the die-life counter. They are now specified in [PLCTagSpecification.md](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) and remain unconfirmed as **`PLC-Q02`**. **Raised but not asked:** DB14 was also the answer to the legacy .NET **SCADA Report** in [FlatWirePlan.md](FlatWirePlan.md) §Reporting Suite — whether that report is also descoped is a separate client decision. |
| Aug 4, 2026 | Analysis team | **Added `Q85`–`Q88` from the PLC tag-surface consolidation.** The surface existed in six partial, mutually contradictory copies; reading them as one document surfaced four questions no single copy could raise. **`Q85`** — speed is pushed as a **target** in four sources and a **limit** in two, including inside `02-SRS.md` itself (§9.1 vs `FR-073`); a setpoint and a safety clamp are different tags with opposite failure modes, so `FR-073`'s wording is deliberately left unfixed until this closes. **`Q86`** — edge type is in the push payload in four sources and absent from a fifth, and separately **no edger tag path exists anywhere in the repo**: the only edger-adjacent tag is `FL1.EdgeSet.Status.Active`, on the one line that has no edger. **`Q87`** — every map addresses FM2 as `FL2.FM2.*` even inside the FL1 map, so it is undetermined whether FL3's single-batch push crosses a controller boundary; commissioning test **C5** passes either way and cannot distinguish them. **`Q88`** — units are in the path for `Speed.FPM` and `Weight.Lb` but not for gauge, width, roll gap or die diameter, where inches are assumed and never stated; a controller reporting gauge in mils would pass every structural check and produce out-of-spec wire. Logged as **`G29`**/**`G30`** in [back-matter.md](../DevelopmentPlan/ShopfloorPlan/back-matter.md) where they carry schedule impact. Total questions: 88. |
| Aug 4, 2026 | Analysis team | **Register index reconciled.** The counts had not been updated when `Q82`–`Q84` were added on Aug 1: the header read *"81 · Shopfloor 54"* and the Open/In-Progress heading read *(35)* against 38 actual entries, and `Q82`–`Q84` were missing from the Quick Reference table entirely. Now **88 total · 61 Shopfloor** (42 Open/In Progress · 18 Decided · 1 Superseded), with `Q82`–`Q88` added to the Quick Reference table. The filtered-index scope note also read *"Dashboards 1–14+"*, corrected to **1–12+** with the DB13/DB14 descope. |
| Aug 4, 2026 | Analysis team | **Added `Q89`–`Q92` from the audit of the PLC tag deliverables.** All four are items the tag specification had marked `[CLIENT INPUT REQUIRED]` **without a register entry**, breaching its own stated rule that *"nothing is tracked only here."* **`Q90` is the serious one:** confirmation of every machine tag path has been an open action since **15 May 2026** and has never been tracked anywhere — it lived as an untagged row on the sign-off sheet of `HMIAndSCADALayout.md`, and when that file was deleted on 1 Aug it survived only as prose. It is **Critical**: every published path follows a proposed convention, none has been read off a controller, and a wrong path fails silently. **`Q89`** surfaced a contradiction the consolidation exposed — assumption A2 (rescued from the deleted file, its only home) says take-up load cells are fitted, while [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) says the completion weight is *derived* from footage × cross-section, and **the tag map publishes no take-up weight path at all** — so the machine-stop prompt, the completion transaction and the printed label all read a value with no published source. **`Q91`** (ordinal convention: `DB1`/`Payoff2` vs `FM2.Stand6S1` — R7 and R8 contradict each other) and **`Q92`** (`ITInhibit` is unprefixed in all six sources while every other tag is line-scoped; if it is genuinely plant-level, one line’s unmet prerequisite blocks all three) complete the set. Total questions: 92. |
| Aug 4, 2026 | Client direction | **`Q93` decided on arrival: FM2 has three stands — `S1` 8″, `S2` 6″, `S3` 6″.** The client corrected FL2's roller sizes. This is **not a digit swap**: the repo had modelled a separate 8″ roller upstream of three 6″ stands — **four components** — because the May 21 note was recorded as *"FM2 has three 6″ stands"* in `00-foundations.md` §0.3 and read that way. **The 8″ roller is S1**, and the fourth stand never existed. The misreading had propagated into ~50 files, the `Stand` seed data, two SQL `CHECK` constraints, the `ComponentName` enum, the PLC tag grammar and eight mockups. Three things pin the correction: the client's **published PLC map has exactly three FM2 stations**, all `[CONFIRMED]` by observation; **every seeded pass schedule has exactly three FM2 component rows** with a descending gap chain; and **`FM2_6inS3` never had a tag path or a seed row** — its absence was itself logged as `OI-36`/`G29`. **Two open items close, neither having been a real defect. `OI-04`** — *"is the mandatory stand `FM2_6inS2` or `6″ S3`?"* — both named **the same physical stand**; the phantom made one answer look like two. **`OI-36`** — *"the final stand has no tag path"* — the map was complete. **Component names become position-only** (`FM2_S1`/`FM2_S2`/`FM2_S3`) with roll diameter moved into a new `Stand.RollDiameterIn` column, because diameter inside an identifier is what let this survive ten weeks. **No gap or gauge value is recomputed** — the seeded chains were always right, and `FR-387`'s multipliers just move from diameter labels to positions, which fixes a defect where the final stand had no gap formula. **One real physics consequence:** roll radius feeds the generation engine, so S1 admits **~1.33×** the draft of a 6″ stand and develops **~1.16×** the force at equal draft — `F_max` and mill modulus become per-stand (`PSG-D10`, `PSG-D12`), and §3.3.5's allocation illustration is recomputed at `k` = 3 (**5.4% / 9.8% / 13.5%**). **Added `Q94`** (`PLC-Q04`, Critical) — the PLC station rename departs from observed `[CONFIRMED]` strings and needs the controls engineer's sign-off; gap **G32**. Total questions: 94. |
| Aug 4, 2026 | Client direction | **`Q92` decided: `ITInhibit` is line-scoped — `FL1.ITInhibit` and `FL2.ITInhibit`.** One tag per line, so a line blocked from running blocks **only itself**. The plant-level reading — in which an idle FL1 with no rod checked in would have stopped a scheduled FL2 — is excluded. All six pre-consolidation sources had recorded the tag bare, without its line prefix. **The answer reaches further than one tag.** Rule **R2** of the naming convention (*"the first segment is always the line; there is no plant-level tag"*) was `[PROPOSED]` **only because of this single counterexample** and is now `[CONFIRMED]` — which matters because the specification asks the client to confirm **the grammar** rather than ~60 individual strings, and every `[PROPOSED]` path derived from that grammar now rests on a convention with no exception in it (**Q90**). Commissioning test **C7** also becomes a per-line test: set each of the five conditions on one line, assert the other two still run. **One residual, on FL3 only** — whether the hybrid line carries `FL3.ITInhibit` or asserts both controllers' interlocks follows from **Q87** / `PLC-Q08`, the same question that decides whether FL3's single-batch push crosses a controller boundary; FL3 is the one line where a block legitimately implicates a second, the two being one physical thread of material. Applied to [PLCTagSpecification.md](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) v1.3 as decision **D15** (§2.2 R2, §2.3, §2.4, the three §3.2 tag maps, §3.4 item 4, **§5.1 — a new per-line tag table**, §12, §13.1, and Part A/Part B of the sign-off sheet), and re-rendered to `SRS/PLCTagSpecification.docx`. `PLC-Q18` closed. **Register index also reconciled:** `Q93` (decided Aug 4) and `Q94` (Critical, open) had been added without updating the filtered index — `Q93` is now listed under Decided and `Q94` under Critical/Open. Counts: **46 Open/In Progress unchanged** — less `Q92`, plus `Q94`, so 8 Critical · 24 High · 13 Medium · 1 Low — and **20 Decided** *(from 18, adding `Q92` and `Q93`)* · 1 Superseded. Total questions: 94. |
| Aug 4, 2026 | Analysis team | **The tag surface's measure segment reshaped, and all old/new content stripped from the client deliverable. Added `Q95` (Critical).** Six corrections were applied and generalised across all three lines: `Speed.FPM`→`Speed`, `Payoff{n}.Weight.Lb`→`Weight`, `Die.ActiveDiameter`→`Diameter`, `Status.Active`→`Status.IsActive`, `Status.Fault`→`Status.IsFaulted`, and `.Current` dropped from roll gap, gauge, width and footage — **41 paths, FL1 15 · FL2 14 · FL3 23**. The measure now splits two ways: **analogues are a single bare segment; booleans keep a `Status` group and take an `Is` prefix.** Element and station segments are untouched, so `FM2.S1/S2/S3` stands. **`Q91` resolved without either side losing** — the digit-suffix rule and the station-segment rule govern different things (the *n*th instance of a piece of equipment versus a station inside an assembly), so they never competed; recorded as `D16`. **`Q88` part 1 specified** (units never appear in the path) while part 2 — *what unit are the values in* — is now the whole of it and was raised to **High**, because with `.Lb` and `.FPM` gone **no tag declares a unit at all** and there is nothing left in an address to catch a misconfigured scale. **The cost is `Q95`:** thirteen FL1 rows were `[CONFIRMED]` by observation — every confirmed string on the surface bar `LineState` and `ITInhibit` — and all thirteen are now `[PROPOSED]`, so where **Q94** departs from three observed strings this departs from thirteen and **C1** fails across the whole map rather than on isolated rows if the reading is wrong. **Second half of the change:** neither `PLCTagSpecification.md` nor `SRS/PLCTagSpecification.docx` may contain old/new content, so `[PLC §4.3]`'s as-published→as-specified table, the nine `observed as FM2.Stand8` footnotes, §2.3's *"inconsistencies in the observed set"* framing and `PLC-Q04`'s two-column sign-off wording were **all removed** — **this register is now the only record of the superseded strings** (`Q94`, `Q95`). Withdrawing two rules rather than striking them renumbered `[PLC §4.2]` to **R1–R8** (old R7→R5, old R8→R6, old R9→R7, new R8); `Q92`'s R2 citation is unaffected. Also **added the missing `D15` row** to `[PLC §12]`, which cited it three times without ever listing it, and added `D17`. Applied to `PLCTagSpecification.md` **v1.4**, re-rendered to `SRS/PLCTagSpecification.docx`, with `G31` restated and **`G33`** raised in [back-matter.md](../DevelopmentPlan/ShopfloorPlan/back-matter.md) and the config keys realigned in [PLCTagImplementation.md](../DevelopmentPlan/PLCTagImplementation.md). Counts: **47 Open/In Progress** *(9 Critical · 24 High · 13 Medium · 1 Low)* · 20 Decided · 1 Superseded. Total questions: 95. |
| Aug 4, 2026 | Analysis team | **Tag specification reissued as v1.0 — a first issue, not a consolidation. `[CONFIRMED]` retired; both registers renumbered.** The document had accumulated three tells that it was a consolidation of six sources revised four times, and all three are gone. **(1) `[CONFIRMED]` is withdrawn entirely** — the legend row is deleted and the reading convention is now two tags. Tracing the status is what forced this: **no client artifact contains a single tag path** (all 14 `BaseDocuments/` files searched for every tag token returned one hit, *"~1800–2000 FPM"*, a speed figure), the strings trace to our own `HMIAndSCADALayout.md` §6.2 — deleted 4 Aug, which itself said *"they follow a proposed naming convention, not a verified map"* — and `[CONFIRMED]` was manufactured by the convention's own second limb, *"or stated consistently across the source specifications."* Eight items claimed it; the count is now **zero** (**Q90**). The dated form `[CONFIRMED — August 4, 2026]` was **removed, not downgraded**, on the equipment heading, so the deliverable does not label the client's own correction as our proposal (**Q93**). **(2) The decision log `§12` (D1–D17, Apr→Aug 2026) is deleted** — a revision history in disguise, whose every rule was already normative in the body and four of whose rows were purely editorial. `ITInhibit`'s line-scoping survived as prose in `[PLC §8.1]` with **C7** tightened to prove it per line; `D14`/`D15` citations were removed from four files and **this register is now the audit trail for both** (**Q92**, **Q93**). **(3) Restructured by subject** — equipment merged with per-line differences into §2, the one-trigger rule promoted to §3, line state reduced to what the client owns (§6, dropping the internal three-way naming collision), and the three separate lists of open questions consolidated into §13. **A live defect closed on the way:** `PLC-Q18` was listed as requiring client input although it was decided — deleted, not renumbered. **Two renumberings, both recorded here because the deliverable carries no history.** Sections: `§1.4`→`§2.1`, `§1.6`→`§3`, `§2`→`§4`, `§2.5`→`§4.3`, `§3`→`§5`, `§3.2*`→`§5.2*`, `§4`→`§7`, `§5`→`§8`, `§6`→`§9`, `§7`→`§2.2`, `§8`→`§6`, `§8.5`→`§6.2`, `§9`→`§10`, `§10`→`§11`, `§11`→`§12`, `§12`→**deleted**, `§13`–`§15` unchanged. Open items, now **numbered in priority order** (5 Critical, 10 High, 2 Medium): `Q03`→`Q02`, `Q04`→`Q03`, `Q19`→`Q04`, `Q20`→`Q05`, `Q16`→`Q14`, `Q14`→`Q16`, `Q18`→**retired**; `Q01`, `Q06`–`Q13`, `Q15`, `Q17` unmoved. **134 citations retargeted across 15 files** — 97 `[PLC §n]` section refs and 37 `PLC-Q` ids, the heaviest being [PLCTagImplementation.md](../DevelopmentPlan/PLCTagImplementation.md) (59 section refs). Re-rendered to `SRS/PLCTagSpecification.docx`. No question was added or closed by the reissue: totals stay **95 · 47 Open/In Progress · 20 Decided · 1 Superseded**. |
