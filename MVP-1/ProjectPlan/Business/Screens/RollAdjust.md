# Flat Wire Processing — Roll Adjust Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** **FL2 / FL3 only** — not FL1 (see §1.5)
**Version:** 1.1
**Last Updated:** August 12, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 11 — Roll Adjust. Presented as a **dialog over the paused run**, not as a separate screen (see §1.4).
**Requirement source:** SRS roll override rules; the August 4 2026 FM2 three-stand correction (decision D-26)

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Aug 11, 2026 | **First issue.** Consolidated from the shopfloor dashboard design reference, which was the only home for this screen. The component table has been **rebuilt to the three-stand FM2 model** — the source table was left internally inconsistent by the August 4 2026 correction, listing five rows for three stands with duplicated position labels. Records the run-level override principle, the reason vocabulary, the measurement panel, the change history panel, and the automatic quality-checkpoint linkage. **Settles the line scope as FL2 / FL3** against four sources that disagreed. Screen styling, layout dimensions and scripting detail removed for the client issue. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 10. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

Roll adjust lets an operator change a roll gap mid-run, when measured gauge or width has drifted outside the pass schedule's tolerance, **without altering the pass schedule itself**. The change is recorded as an override against the run and the footage position at which it was applied.

## 1.2 Why the distinction matters

The pass schedule is the approved configuration for a product. It is authored or generated, approved by Operations, and it is what the machine was set up from at check-in. An operator correcting for roll warm-up or gradual wear is not re-approving that configuration — they are compensating for a condition on one run.

If those corrections were written back into the schedule, the schedule would drift away from the approved design one shift at a time, with no record of who changed what or why, and the next run would start from an unapproved state. **The override is therefore recorded separately and linked to the footage position, and the pass schedule record is never modified here.**

## 1.3 Scope

**In scope:** the run context displayed, the component gap table and what is editable, the measurement panel that justifies the adjustment, the reason vocabulary, the change history, what happens on apply, and access control.

**Not in scope:** authoring or approving a pass schedule; the SPC checkpoint as a standalone event; die changes, which act on the drawing dies rather than the mill rolls.

## 1.4 It is a dialog over the paused run `[CONFIRMED — August 1, 2026]`

Roll adjust is raised over the run being adjusted, so the run stays visible behind it. It is reached from the active run monitor's action set, and from the *roll adjustment* pause reason.

**Documents elsewhere in this project still describe Roll Adjust as a standalone screen.** They predate the conversion of the run-event screens to dialogs, and this specification supersedes them on that point.

## 1.5 Which lines have it `[CONFIRMED]`

**Roll Adjust is available on FL2 and FL3. It is not available on FL1.**

FL1 runs a single flattening mill and its action bar carries no Roll Adjust control; FL3 adds Roll Adjust to the FL1 action set, and FL2 includes it while omitting weld and die change, having no drawing dies.

**Four of our own documents stated this four different ways**, which is worth recording because the wrong answer is still present in some of them:

| Source | What it said | Verdict |
|---|---|---|
| Requirement text (`FR-107`, `FR-108`, `FR-109`) | FL1 none · FL3 yes · FL2 yes | **Correct** |
| The three active-run mockups | FL1 no control; FL2 and FL3 both have one | **Correct — agrees with the requirements** |
| The dashboard design reference, screen section | "FL1 / FL2 Operator" | Wrong — omits FL3, wrongly includes FL1 |
| The dashboard design reference, inventory and action table | "FL3 Operator" / "FL3 only" | Wrong — omits FL2 |

The requirement text and the mockups agree, and they are the authorities. The design reference predates them and is stale on this point in two different directions.

---

# 2. Run Context

Displayed read-only at the top of the dialog, so the operator can confirm what they are adjusting:

| Field | Source |
|---|---|
| Material alpha — rod or spool | The active run |
| Pass schedule identifier | The active run |
| **Footage at adjustment** | The footage counter **when the dialog was opened** |
| Output targets — gauge and width with tolerances | The pass schedule |
| Override type | Always **run-level**; the pass schedule is never modified here |

**Footage is captured on opening, not on apply.** It marks the beginning of the material affected by the drift being corrected, and it must not move because the operator took several minutes to measure and decide.

---

# 3. The Component Gap Table

## 3.1 Components are identified by position `[CONFIRMED — August 4, 2026]`

The finishing mill **FM2 has three stands — `S1`, `S2` and `S3`** — and roll diameter is **data about a stand, not part of its name**: S1 carries 8-inch rolls, S2 and S3 carry 6-inch. FM1 is a single 12-inch mill.

**This matters here specifically.** The earlier four-stand model listed a separate 8-inch roller above three 6-inch stands, which produced a table with more rows than the mill has stands and adjustment formulas that did not cover the final stand. Position-only identifiers remove the ambiguity that caused it.

## 3.2 The table

| Column | Editable | Content |
|---|---|---|
| **Component** | No | The stand position, from the active pass schedule. Bypassed stands are shown but not editable |
| **Scheduled gap** | No | The value defined in the active pass schedule |
| **Current gap** | No | The value in effect now — equal to scheduled unless a prior override exists on this run |
| **New gap** | **Yes** | The operator's target. Blank, or equal to current, means no change |
| **Delta** | Automatic | New less current, calculated as the operator types, and signed |

For a finishing mill run the table therefore has **three rows**, one per stand:

| Component | Rolls | Bypassable |
|---|---|---|
| **S1** | 8″ | Yes |
| **S2** | 6″ | Yes |
| **S3** | 6″ | **No — S3 is the final stand and is never bypassed** |

## 3.3 Interaction rules `[CONFIRMED]`

- **Bypassed stands are shown, read-only.** Omitting them would leave the operator unable to see the configuration the run was checked in against.
- **Only components with a gap are listed.** Edgers set edge shape and have no gap parameter, so they do not appear. Edgers are present at S2 and S3 only.
- **Delta recalculates on every keystroke**, and a row with a non-zero delta is highlighted, because the consequence of a typing error here is out-of-specification product.

## 3.4 No change means no record

If every delta is zero, the confirm action states that there is no change and returns to the run. **No override record is written.** An empty override in the audit trail is worse than no entry — it implies an adjustment that did not occur.

---

# 4. The Measurement Panel

The adjustment must be justified by a measurement. The panel shows the operator's most recent readings for the affected dimensions:

| Element | Purpose |
|---|---|
| Measured value | The reading, prominently displayed |
| Target and tolerance | From the pass schedule |
| Status | In specification or out of specification |
| **Deviation** | How far outside the limit, signed |
| Range indicator | Where the reading sits relative to the tolerance band |

**The deviation is stated, not left to be inferred.** An operator adjusting a gap needs to know the size of the error to size the correction, and a pass/fail badge does not carry that.

---

# 5. Reason for the Adjustment

## 5.1 The vocabulary `[CONFIRMED]`

A reason is **mandatory** — the apply action stays disabled until one is chosen.

| Reason | When it applies |
|---|---|
| **Gauge drift (high)** | Measured gauge above maximum tolerance |
| **Gauge drift (low)** | Measured gauge below minimum tolerance |
| **Width drift** | Width outside tolerance |
| **Quality flag** | A statistical process control trigger |
| **Roll wear** | Gradual gap creep attributed to roll surface wear |
| **Post-weld correction** | A gauge change observed after a weld join passes through |
| **Operator discretion** | The operator anticipates drift from experience |

Free-text notes are optional and stored with the record.

## 5.2 Why the reason is required rather than optional

The override history is the evidence base for two later decisions: when rolls need regrinding or replacing, and whether a pass schedule's gap values are systematically wrong. Neither is answerable from a list of gap changes without reasons attached.

---

# 6. Change History

The dialog shows the most recent adjustments made against the **active pass schedule** — across all runs and all operators, not only the current run.

| Column | Content |
|---|---|
| Time | When the prior adjustment was made |
| Operator | Who made it |
| Component | Which stand |
| Change | Previous gap to new gap |
| Reason | The reason recorded at the time |

**Showing other operators' adjustments is deliberate.** An operator about to tighten S3 by two ten-thousandths should be able to see that the previous two shifts did the same thing, because that pattern is a roll condition, not three independent corrections.

---

# 7. What Happens on Apply

| # | Effect |
|---|---|
| 1 | An override record is written against the **run, the material alpha and the footage position** — **not** against the pass schedule |
| 2 | Each changed gap is logged individually: component, previous value, new value, delta, reason, operator, timestamp and footage |
| 3 | The **machine tag for each adjusted roll gap is updated** to its new value |
| 4 | The active run monitor reflects the new current gap in its component status |
| 5 | The override appears in the pass schedule's override history, for traceability without altering the schedule |
| 6 | The operator returns to the run |

## 7.1 The measurements are recorded as a quality checkpoint `[CONFIRMED]`

The readings entered here are written to the quality checkpoint record with the type **roll adjust trigger**. **No separate checkpoint is required for the same footage position** — requiring the operator to re-enter the same measurement in a second dialog would produce two records that can disagree.

---

# 8. Access Control

| Action | Permitted |
|---|---|
| View the dialog | Line operators |
| Apply an override | Line operators — logged automatically, with no supervisor gate |
| View override history | Operators and supervisors |
| **Revert an override** | **Operations Manager only** |

**Applying is an operator action; reverting is not.** Applying is a correction the operator is qualified to judge from a measurement in front of them. Reverting undoes a recorded decision that a previous operator justified, and it is an override of that judgement rather than a routine adjustment.

---

# 9. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | The adjustment is a **run-level override**; the pass schedule record is never modified here | Apr 2026 |
| D2 | **Roll Adjust is available on FL2 and FL3, and not on FL1** | Aug 2, 2026 |
| D3 | Presented as a **dialog over the paused run**, not a standalone screen | Aug 1, 2026 |
| D4 | **FM2 has three stands** identified by position — S1, S2, S3 — with roll diameter held as data. **S3 is never bypassed** | Aug 4, 2026 |
| D5 | Footage is captured **when the dialog opens**, not on apply | Apr 2026 |
| D6 | A **reason is mandatory**; the apply action stays disabled until one is chosen | Apr 2026 |
| D7 | Measurements are recorded as a **roll-adjust-trigger quality checkpoint**; no second entry is required | Apr 2026 |
| D8 | Operators may **apply** an override; only an **Operations Manager may revert** one | Apr 2026 |
| D9 | If every delta is zero, **no override record is written** | Apr 2026 |

---

# 10. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-57 / OI-57** | High | **Published tolerance bands** per alloy and temper | The in-specification determination in §4 |
| **Q22** | High | **Min/max values** for gauge, width, diameter and ovality | The measurement evaluation |
| **OI-103** | Medium | **Are gap adjustments bounded?** No maximum single-step change or cumulative limit is specified, so an operator can enter any value. A mistyped gap is written to the machine | Validation before apply |
| **Q65** | Medium | **FM2 dancer modes** — who selects a mode, per dancer or per line, scheduled or machine-side. A dancer affects tension, which affects gauge | Whether tension is adjustable alongside gap |
| **PLC-Q04 / PLC-Q04** | Medium | **FM2 station naming for the machine interface** is pending sign-off | The tag written on apply |

---

# 11. Assumptions

| # | Assumption |
|---|---|
| A1 | Every stand with an adjustable gap exposes that gap as a writable machine tag; a stand whose gap is set only by hand cannot be adjusted here. |
| A2 | The pass schedule holds a scheduled gap for every non-bypassed component, so the table always has a baseline to compare against. |
| A3 | The operator measures with a calibrated instrument at the machine; the system does not read these values automatically. |
| A4 | An override applies for the remainder of the run and does not persist to the next run, which starts from the pass schedule. |
| A5 | Adjusting a gap does not stop the line — the change is applied to a running machine. |

---

# 12. Related Specifications

| Document | Relationship |
|---|---|
| [Active Run Monitor](ActiveRunMonitor.md) | Where this is opened from, and where the updated gap is reflected |
| [Pass Schedule Management](../../../../MVP-2/RequirementDocuments/PassScheduleManagement.md) | Supplies the scheduled gaps, and hosts the override history without being modified |
| [SPC Checkpoint](SPCCheckpoint.md) | Receives the measurements as a roll-adjust-trigger checkpoint |
| [Die Change and Die Management](DieChangeAndManagement.md) | The equivalent event for the drawing dies rather than the mill rolls |
| [PLC Tag Specification](../../Architecture/PLCTagSpecification.md) | The write surface for the adjusted gap, and the FM2 station naming |
| [Pass Schedule Generation](../../../../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) | Derives the scheduled gaps this dialog overrides, including the mill-spring relationship between gap and gauge |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.2 | The override never modifies the pass schedule | ☐ | ☐ |
| §1.4 | Presented as a dialog over the run | ☐ | ☐ |
| §2 | Footage captured when the dialog opens, not on apply | ☐ | ☐ |
| §1.5 | Roll Adjust is on FL2 and FL3, and not on FL1 | ☐ | ☐ |
| §3.1 | FM2 has three stands, identified by position, with diameter as data | ☐ | ☐ |
| §3.3 | Bypassed stands shown read-only; edgers excluded; S3 never bypassed | ☐ | ☐ |
| §3.4 | No change means no record is written | ☐ | ☐ |
| §5.1 | The seven reason codes, and that a reason is mandatory | ☐ | ☐ |
| §6 | History shows other operators' adjustments against the same schedule | ☐ | ☐ |
| §7.1 | Measurements are recorded as a roll-adjust-trigger checkpoint, with no second entry | ☐ | ☐ |
| §8 | Operators apply; only an Operations Manager reverts | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-57 / OI-57 | Published tolerance bands | | ☐ |
| Q22 | Min/max dimensional values | | ☐ |
| OI-103 | Bounds on a single or cumulative gap change | | ☐ |
| Q65 | FM2 dancer modes and whether tension is adjustable here | | ☐ |
| PLC-Q04 / PLC-Q04 | FM2 station naming for the machine interface | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Process Engineering** | | | |
| **Operations** | | | |
| **Maintenance** | | | |
| 1.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
