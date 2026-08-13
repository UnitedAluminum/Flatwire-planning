# Flat Wire Processing — SPC Checkpoint Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3
**Version:** 2.2
**Last Updated:** August 12, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 6 — SPC Checkpoint. Presented as a **dialog over the run being measured**, not as a separate screen (see version 2.1).
**Requirement source:** SRS SPC rules (`SPC001` and following), `FR-184` (checkpoint types), die-change rules (`Q65`)

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Apr 2026 | Initial specification — purpose, triggers, checkpoint types, measurement rows, tolerance evaluation, the two submit paths. |
| 2.0 | Aug 1, 2026 | **Issued for client review.** Checkpoint types corrected to the **five** persisted values. Adds the May 4, 2026 decision that a post-die-change checkpoint is a hard block with thread mode permitted, and the July 30, 2026 min/max tolerance decision. Restructured as a client deliverable; screen styling, layout dimensions and scripting detail removed. |
| 2.1 | Aug 1, 2026 | **Presentation change only — no requirement altered.** The checkpoint is now raised as a dialog over the screen the operator is already on rather than as a page navigated to, so the run stays visible behind it. Two consequences the client should confirm: a post-die-change checkpoint is opened **directly by** the die change that mandated it, carrying that change as its stated trigger; and the line status board's *last check … View* link now opens the checkpoint **read-only**, as a review of what was recorded, instead of a blank entry form. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 8. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

The SPC checkpoint is the **mandatory quality gate** that stops a production run from continuing until an operator has physically measured the wire and confirmed it is within dimensional specification. It is raised automatically after events that change what the machine is producing, and it can be opened at any time as a spot check.

## 1.2 Why it exists

Statistical process control on this line is not a reporting exercise. Out-of-specification gauge on welding wire causes jams in the customer's automated welding equipment, and it is a common first-shipment field failure. The checkpoint is the mechanism that stops unverified material from being produced at volume after the process has been disturbed.

## 1.3 Scope

**In scope:** when a checkpoint is raised, what is measured, how each measurement is evaluated against target and tolerance, the two exit paths and their consequences, and the audit record produced.

**Not in scope:** the die change or roll adjustment that triggers a checkpoint; QA disposition of held material; control-chart reporting and trend analysis; the incoming-rod inspection performed at check-in.

## 1.4 Where checkpoints are taken

| Point | Typical trigger | Capture |
|---|---|---|
| Incoming rod | Before a run starts | Manual |
| Post-die-change | After a die swap for gauge drift or a size change | Manual |
| FM1 output | Gauge and width at the flattening mill | Manual, with automatic gauge control data available |
| FM2 final stand output | Finished dimensions on FL2 / FL3 | Manual, with automatic gauge control data available |

---

# 2. When a Checkpoint Is Raised

| Trigger | Raised automatically? |
|---|---|
| Die change with reason **gauge drift** | **Yes** |
| Die change with reason **size change** | **Yes** |
| Roll adjustment / override | **Yes** |
| Mid-run pass schedule change | **Yes** |
| Before a run starts | Yes — as part of check-in |
| Operator discretion | No — opened manually as a spot check |

## 2.1 The post-die-change gate `[CONFIRMED — May 4, 2026]`

When a checkpoint is raised automatically after a die change, the run **is blocked** — this is a hard gate, not a queued task the operator can defer.

| Rule | Behaviour |
|---|---|
| **Thread mode is permitted** | The operator may run the line slowly to confirm the new die is seated and producing on-target material |
| **Full production is blocked** | The run cannot return to normal production until the checkpoint passes |
| **Routing** | Confirming a gauge-drift or size-change die change routes directly to this screen, not back to the run |
| **The gate may be waived** | Only by an Operations Manager or Quality role, and every waiver is audited |

> `[CLIENT INPUT REQUIRED]` **Who may waive the gate** was not settled beyond the hard-block behaviour itself. Our recommendation is Operations Manager as the minimum authority (Q65). Every waiver is written to the audit log with user, role, timestamp and the triggering event, and any run that resumed without a completed checkpoint after gauge drift or a size change appears as a flagged exception on the shift summary and quality reporting.

---

# 3. Checkpoint Types

## 3.1 Persisted types `[CONFIRMED]`

Five values are recorded:

| Type | Meaning |
|---|---|
| **Pre-run** | Incoming material verified before a run begins |
| **Post die change** | Required after a die swap |
| **Roll adjust trigger** | Raised by a roll gap override |
| **Manual spot check** | Operator discretion, at any time |
| **Post-run** | Final verification at run completion |

The selected type determines which measurements are required, how the record is categorised, and who is notified.

> `[CLIENT INPUT REQUIRED]` **"Post DB1" is offered on screen but is not one of the recorded types.** It was agreed as an addition on May 21, 2026 and applied to the screen, but never to the recorded value set. Either it becomes a sixth recorded type or the option is removed from the selector — it cannot remain as it is (OI-10).

## 3.2 Trigger context

When a checkpoint was raised by a die change, the screen shows the triggering event so the operator has the full context without navigating away: which draw box was changed, the size change (for example 0.310″ → 0.308″), the footage at which it was logged, who logged it, and how long ago.

> `[CLIENT INPUT REQUIRED]` **A checkpoint cannot currently be joined back to its trigger.** The link is free text only, so it is not possible to prove programmatically which die change a given checkpoint verified. For a quality audit that is a real limitation, and we recommend adding an explicit link (OI-18).

---

# 4. Measurements

## 4.1 What the operator does

The operator measures the wire at the machine with a calibrated instrument and enters each value. Each entry is evaluated immediately against its target and tolerance, and the screen reports in-spec or out-of-spec per measurement together with the signed deviation. A live summary states how many measurements are in specification.

## 4.2 The default measurement set for a post-die-change checkpoint

| # | Measurement | Point of measurement |
|---|---|---|
| 1 | Wire diameter | At the changed draw box output |
| 2 | Gauge | At the flattening mill output |
| 3 | Width | At the flattening mill output |

Targets and tolerances are **not fixed in the screen** — they are read from the order's product specification for the alloy and die-size combination in force.

> `[CLIENT INPUT REQUIRED]` Two inputs are outstanding and both are required before this evaluation can be enforced:
> - **The published tolerance bands** per alloy and temper — whether ASTM, customer purchase order, or United Aluminum internal (OI-57 / OI-57). Without these, control limits cannot be configured and the gauge trace produces no meaningful alarm.
> - **The min/max dimensional limits** for gauge, width, diameter and ovality agreed in shape on July 30, 2026, with values still owed (Q22).

## 4.3 How a measurement is presented

Each measurement shows four things together, because an operator reading a gauge needs more than a pass/fail verdict:

| Element | Purpose |
|---|---|
| Target and tolerance | What the value is being judged against |
| The entered value | Large, monospaced, on a touch target sized for gloved use |
| A **tolerance track** with a position marker | Where the reading falls inside — or outside — the band |
| Result and signed deviation | In spec / out of spec, and by how much |

**The tolerance track is deliberate.** A number alone communicates pass or fail; a marker position communicates *how close to the limit* the reading is. Readings that consistently sit near one edge of the band indicate drift before any failure occurs — which is the entire purpose of statistical process control.

## 4.4 Observation

An optional free-text note for anything the structured fields do not capture: surface marks on the wire, unusual noise from a draw box, visible die wear that did not warrant a failure, or uncertainty about instrument calibration. It is stored with the checkpoint record.

---

# 5. The Two Exit Paths

Both paths save the checkpoint record in full. They differ in what happens to the material.

## 5.1 Submit and continue the run

| # | Effect |
|---|---|
| 1 | The checkpoint record is saved with all measurements, type, trigger reference, operator, footage, timestamp and observation |
| 2 | Any SPC hold placed by the triggering event is lifted |
| 3 | The line returns to running |
| 4 | The operator returns to the active run |

**Used when** all measurements are in specification — the normal path — or when the operator re-measured and confirmed that a first reading was erroneous, which the observation should state.

## 5.2 Submit and suspend material

| # | Effect |
|---|---|
| 1 | The checkpoint record is saved identically |
| 2 | The output coil is placed on **SPC hold** — it cannot advance to the next operation, be shipped, or be released until QA lifts the hold |
| 3 | **The machine is not stopped.** The record marks the material already produced up to this footage as under review |
| 4 | A QA notification is raised, carrying the footage range, the out-of-specification values and their deviations |
| 5 | The operator returns to the active run; production may continue, but the flagged footage range is locked pending QA |

**Used when** a measurement is out of specification and the operator cannot resolve it, when the operator wants QA to review before release, or on supervisor instruction.

QA subsequently either accepts with a concession and lifts the hold, or rejects, and the material is quarantined or scrapped.

## 5.3 Why two buttons rather than one

The consequence is stated on the control itself. A single submit with a confirmation dialog adds a step and still describes the outcome in a place the operator has to read separately; the label *"submit · suspend material"* tells them what they are authorising before they press it.

When any measurement is out of specification, the suspend action is **visually elevated** — the system has determined which path is appropriate and guides the operator toward it, without disabling the continue path for the operator who has legitimately re-measured.

> `[CLIENT INPUT REQUIRED]` **SPC hold is not currently distinguishable from a WIP-rejection hold.** The requirement names it as a distinct state that blocks advancement, shipping and release, but the two holds would be recorded identically. Whether QA needs to tell them apart determines whether a separate state is added (OI-23).

---

# 6. Audit Record

Three values are stamped on every checkpoint and cannot be edited by the operator:

| Field | Source |
|---|---|
| Operator | The active session |
| **Footage at check** | The counter value **when the checkpoint was opened**, not when it was submitted |
| Timestamp | Server-side |

**Footage is captured on opening deliberately.** It marks the beginning of the potentially affected material range, and it must not move because the operator took several minutes to complete the measurements.

Leaving the screen without submitting does not cancel or delete the checkpoint; the operator is warned that the checkpoint is incomplete and that the material remains held.

---

# 7. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | **A post-die-change checkpoint is a hard block on full production**, not a queued task. Thread mode is permitted while measurements are taken | May 4, 2026 |
| D2 | Confirming a **gauge drift** or **size change** die change routes directly to this screen | May 4, 2026 |
| D3 | A waiver of the gate is auditable and restricted to Operations Manager or Quality | May 4, 2026 |
| D4 | **Five checkpoint types are recorded**, including the roll-adjust trigger | Jul 2026 |
| D5 | Targets and tolerances come from the order's product specification, not from the screen | Apr 2026 |
| D6 | **Dimensional limits are min/max** on gauge, width, diameter and ovality, held as reference data | Jul 30, 2026 |

---

# 8. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-57 / OI-57** | High | **Published tolerance bands** per alloy and temper — ASTM, customer PO, or UA internal | Control limits, evaluation, and every gauge-trace alarm |
| **Q22** | High | **Min/max values** for gauge, width, diameter and ovality | Dimensional acceptance at every checkpoint |
| **Q65** | Medium | **Who may waive the post-die-change gate** | The override authority and its audit |
| **OI-10** | Medium | **"Post DB1"** — add it as a recorded type, or remove it from the selector | The checkpoint type list |
| **OI-18** | Medium | Should a checkpoint carry an **explicit link to its triggering event**? | Proving which die change a checkpoint verified |
| **OI-23** | Medium | Must **SPC hold** be distinguishable from a WIP-rejection hold? | The QA release flow |

---

# 9. Assumptions

| # | Assumption |
|---|---|
| A1 | The operator measures with a calibrated instrument at the machine; the system does not read these values automatically. |
| A2 | Target and tolerance values exist on the order's product specification for every alloy and die-size combination in production. |
| A3 | QA has a route to review held material and lift or reject a hold; that workflow is specified elsewhere. |
| A4 | Placing material on hold does not stop the machine — the physical line continues under operator control. |

---

# 10. Related Specifications

| Document | Relationship |
|---|---|
| [Die Change and Die Management](DieChangeAndManagement.md) | The event that raises most automatic checkpoints |
| [Rod Check-in](RocCheckin.md) | Records the pre-run checkpoint |
| [Pass Schedule Management](../../../../MVP-2/RequirementDocuments/PassScheduleManagement.md) | A mid-run configuration change also raises a checkpoint |
| [Line Status Overview](LineStatusOverview.md) | Where an out-of-spec reading raises the gauge-deviation alert |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §2.1 | Post-die-change checkpoint is a hard block; thread mode permitted | ☐ | ☐ |
| §3.1 | The five recorded checkpoint types | ☐ | ☐ |
| §4.2 | Targets and tolerances read from the order's product specification | ☐ | ☐ |
| §4.3 | Tolerance track presentation, showing proximity to the limit | ☐ | ☐ |
| §5.1 | Continue path lifts the hold and returns the line to running | ☐ | ☐ |
| §5.2 | Suspend path holds the material but does not stop the machine | ☐ | ☐ |
| §5.3 | Two explicit exit actions rather than one submit with a confirmation | ☐ | ☐ |
| §6 | Footage stamped when the checkpoint opens, not when it is submitted | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-57 / OI-57 | Published tolerance bands by alloy and temper | | ☐ |
| Q22 | Min/max dimensional values | | ☐ |
| Q65 | Waiver authority for the post-die-change gate | | ☐ |
| OI-10 | "Post DB1" — add or remove | | ☐ |
| OI-18 | Explicit checkpoint-to-trigger link | | ☐ |
| OI-23 | SPC hold distinguishable from a rejection hold | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Quality** | | | |
| **Operations** | | | |
| **Process Engineering** | | | |
| 2.2 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
