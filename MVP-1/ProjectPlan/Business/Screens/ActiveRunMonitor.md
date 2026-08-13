# Flat Wire Processing — Active Run Monitor Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3
**Version:** 1.1
**Last Updated:** August 12, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 3 — Active Run Monitor. The operator's continuously displayed screen during a production run.
**Requirement source:** SRS run-monitoring and pause/resume rules; the four resume outcomes (OI-14); trace behaviour per line

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Aug 11, 2026 | **First issue.** Consolidated from the shopfloor dashboard design reference, which was the only home for this screen. Carries the trace display rules, payoff weight indication, the per-line quick-action sets, the redesigned pause dialog with its five reason categories, the four resume outcomes confirmed on August 1 2026, and the shift-summary contribution. Screen styling, layout dimensions, scripting detail and internal verification notes removed for the client issue. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 11. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

The Active Run Monitor is the screen an operator watches for the duration of a production run. It shows what the machine is producing right now, how much material remains on each payoff, and it is the launching point for every event that can occur mid-run — a die change, a quality checkpoint, a rejection, a pause, or the completion of the run.

## 1.2 Why it is the operator's home screen

Every other operator screen in this system is entered, completed and left. This one is not: it stays open for hours. That has two consequences the design follows throughout. First, the information that changes must be readable at a glance from arm's length, without interaction. Second, the actions that interrupt a run must be reachable from here rather than requiring the operator to navigate away from the run they are responsible for.

## 1.3 Scope

**In scope:** the run header, the gauge and width traces and their display rules, machine and component status, payoff weight indication and its alert thresholds, the quick-action set per line, the pause dialog and its reason vocabulary, the resume confirmation and its four outcomes, and what this screen contributes to the shift summary.

**Not in scope:** the content of the dialogs this screen opens — die change, SPC checkpoint, WIP rejection, rod checkout and roll adjust are each specified separately. Spool and coil completion alerts are specified in the Spool Completion Notification document. Check-in, which creates the run, is specified in Rod Check-in.

## 1.4 Applicability

| Line | Trace behaviour | Notable differences |
|---|---|---|
| **FL1** | Real-time gauge and width | No edger. Two payoffs, continuous feed by induction weld. No roll adjust for the finishing mill |
| **FL2** | **Historical / profile only** | Fed from a pre-flattened spool, so there is one input rather than two payoffs. No draw boxes, therefore no die change |
| **FL3** | Real-time gauge and width | FL1 feeding FL2 continuously. The fullest action set |

---

# 2. Layout and Content

```
┌───────────────────────────────────────────────────────────────────┐
│  FL1 — ACTIVE RUN          Order: <order>     Alpha: <rod alpha>  │
│  Alloy · Target Gauge · Target Width                              │
├─────────────────────────────────┬─────────────────────────────────┤
│  GAUGE TRACE                    │  WIDTH TRACE                    │
│         [target ± tolerance]    │         [target ± tolerance]    │
├─────────────────────────────────┴─────────────────────────────────┤
│  MACHINE STATUS                                                    │
│  Speed · Footage  │  Draw box states and die sizes in force        │
│  Payoff 1 — weight remaining, bar, percentage, weld alert          │
│  Payoff 2 — weight remaining, bar, ready state                     │
├───────────────────────────────────────────────────────────────────┤
│  ACTIONS — grouped as “Run events” and “Go to”                     │
└───────────────────────────────────────────────────────────────────┘
```

## 2.1 The run header

States the line, the run state, the order, the rod or spool alpha in process, and the dimensional targets in force from the pass schedule. These are the facts an operator or a passing supervisor needs to identify what they are looking at without touching the screen.

## 2.2 The trace section

Gauge and width are plotted side by side against their target and tolerance band. The section carries a collapse toggle so an operator working through a dialog-heavy sequence can recover vertical space.

## 2.3 Machine status

Line speed, the cumulative footage counter, and the state of each component in the active pass schedule together with the die size or roll gap currently in force. Bypassed components are shown as bypassed rather than omitted, so the operator can see the configuration the run was checked in against.

## 2.4 Payoff monitoring

FL1 and FL3 show both payoff positions with weight remaining, a proportional bar and a percentage. This is the operator's cue to prepare the next weld, and its alert thresholds are in Section 4.

## 2.5 A mid-run configuration change must be acknowledged here `[CONFIRMED]`

An Operations Manager may override a pass schedule setting while a run is active. When that happens, this screen is where the operator learns of it:

| # | Step |
|---|---|
| 1 | The override is logged against the pass schedule, with a reason |
| 2 | **This screen raises an alert** — the schedule has been updated, and the change is presented for review |
| 3 | **The operator must acknowledge before production continues.** The alert offers accept, or stop the run |

**The operator cannot be bypassed.** They are running the machine against a configuration they acknowledged at check-in; changing it underneath them without a confirmation would leave them responsible for a setup they never saw. The alert is therefore blocking, and stopping the run is an equal-weight option rather than a buried one.

A mid-run configuration change also raises a quality checkpoint, so the material produced after the change is verified.

---

# 3. Trace Display Rules

## 3.1 Behaviour against tolerance `[CONFIRMED]`

| Condition | Display behaviour |
|---|---|
| Reading within target ± tolerance | Trace shown in the in-specification colour |
| Reading outside tolerance | Trace shown in the alert colour, with a banner naming the deviation |
| Consecutive out-of-specification readings | The system prompts for a quality checkpoint. The number of readings is configurable |
| A weld point | A vertical marker on the trace, labelled with the rod alpha that was welded in |

**The weld marker matters commercially.** It is what lets a later quality investigation locate which source rod was in process at a given footage, and it is the visible counterpart of the traceability chain required for welding-wire customer certificates.

## 3.2 FL2 produces no live trace `[CONFIRMED]`

FL2 does not broadcast live gauge or width. Its trace section is populated from the historical profile of the spool being processed, not from a live instrument feed. The screen must state this rather than showing an empty chart that reads as a fault.

> `[CLIENT INPUT REQUIRED]` **The consecutive-reading threshold that auto-prompts a checkpoint has no agreed value.** It is configurable by design, but a default is needed before the line runs. This depends on the published tolerance bands, which are also outstanding (OI-57 / OI-57, Q22).

## 3.3 Descoped — Machine View and View Trends `[CONFIRMED — August 4, 2026]`

The **Machine View** tab and the **View Trends** action were both withdrawn at client request, together with Dashboards 13 and 14. The trace section keeps its collapse toggle; the tab strip carries a single inert label, which matches FL2, which never had a second tab. The machine tags the Machine View would have displayed are specified in the PLC Tag Specification.

---

# 4. Payoff Weight Indication

## 4.1 Thresholds `[CONFIRMED]`

| Weight remaining | Indication | Operator action |
|---|---|---|
| Above 50 % | Normal | None |
| 25 % – 50 % | Caution | None |
| Below 25 % | Alert | Prepare the weld |
| Below 10 % | Critical | Weld now |

## 4.2 Absolute weight is shown alongside the percentage

A percentage alone is not actionable, because the operator's decision — whether there is time to prepare a rod and weld it in — depends on pounds remaining and line speed, not on a proportion of a bundle whose starting weight varies. Both are shown, and the same rule is applied on the Line Status Overview.

> `[CLIENT INPUT REQUIRED]` **Rod bundle gross weight is not established** (OI-97), so the denominator behind every percentage on this screen is currently an assumption. The absolute figure is safe; the percentage is not, until that value is supplied.

---

# 5. Quick Actions

## 5.1 What each action opens

| Action | Opens | Lines | Availability |
|---|---|---|---|
| **Die Change** | Die change dialog | FL1, FL3 | When a drawing die needs replacing. Not offered on FL2, which has no draw boxes |
| **SPC Checkpoint** | SPC checkpoint dialog | All | Any time, as a spot check |
| **Roll Adjust** | Roll adjust dialog | **FL2, FL3** | When measured gauge or width drifts from the pass schedule. **Not offered on FL1** |
| **Pause Run** | Pause dialog — Section 6 | All | Any time |
| **WIP Reject** | WIP rejection dialog | All | Any time |
| **Complete Run** | Run completion | All | End of rod or end of job |
| **Check Out Rod** | Rod checkout, Mode A | FL1, FL3 | Only when footage is zero — nothing has been produced |

## 5.2 Weld capture is no longer an action here `[CONFIRMED — August 1, 2026]`

**Log Weld Event was removed.** The weld is captured where it physically happens — at the pre-check-in station, as *Mark as welded* on the staged rod, because that rod is the incoming one being joined. Dashboard 4, the separate weld event screen, is retired. The traceability consequences are specified in the Weld Event document.

## 5.3 The action bar differs by line `[CONFIRMED]`

| Line | Action bar |
|---|---|
| **FL1** | Six actions. **No Roll Adjust** and no edger controls — FL1 runs one mill and has no edger |
| **FL3** | Seven actions — the FL1 set **plus Roll Adjust** |
| **FL2** | Omits weld and die change, having no drawing dies; **includes Roll Adjust** and Complete Coil |

**Roll Adjust is therefore FL2 and FL3, and not FL1.** Four project documents stated this four different ways; the requirement text and all three active-run mockups agree on the above, and the design reference is stale on the point. The reconciliation is recorded in the Roll Adjust specification §1.5.

## 5.4 Actions are grouped, not listed

The actions divide into **run events** — things that happen to the material and produce a record — and **navigation**. Grouping them prevents the most consequential control on the screen sitting adjacent to a link that merely changes the view.

---

# 6. Pausing a Run

## 6.1 The reason is mandatory and coded `[CONFIRMED]`

A pause always records why. The reason is submitted as a **code and a category**, not as a display label, so that downtime reporting groups reliably and is not broken by a wording change on the screen.

## 6.2 The reason vocabulary — fifteen reasons in five categories `[CONFIRMED]`

| Category | Reason | When it applies |
|---|---|---|
| **Equipment / Mechanical** | Die change (mid-run, no weld) | A die swap without a payoff change. **Applies the pause, then opens the die change** |
| | Roll adjustment | Line stopped to adjust roll gap |
| | Lubrication / coolant | Scheduled or reactive refill |
| | Draw box inspection | Solution level, temperature or contamination check |
| | Component inspection (non-fault) | A check that did not raise a machine fault |
| **Material Handling** | Payoff 2 loading / weld preparation | The next rod is not ready as the running payoff nears its end |
| | Downstream blockage | The take-up is full, or the downstream line cannot accept more footage |
| **Quality / Measurement** | Gauge / width investigation | An out-of-specification reading, paused before deciding on a rejection |
| | Manual SPC measurement | The line must stop to measure accurately. **Applies the pause, then opens the checkpoint** |
| | Surface inspection | Visual check of product mid-run |
| **Operational** | Operator break | Short break during shift |
| | Shift changeover | Incoming operator walkthrough before resuming |
| | Awaiting supervisor instruction | Supervisor review required before continuing |
| **Safety** | Safety observation (non-fault) | A hazard that did not raise a machine fault |
| **Other** | Other | **Notes are mandatory.** The code remains *Other* and the operator's text is stored as the note |

## 6.3 Two reasons route onward, and say so before the operator commits

*Die change* and *Manual SPC measurement* name activities that have their own dialogs. The tile states this, so the operator knows the pause is a step rather than the destination. The die change hand-off is suppressed on FL2.

## 6.4 Rod Checkout is not a pause reason `[CONFIRMED — August 1, 2026]`

It was the only entry in the reason list that did not pause the run, presented identically to the fourteen that did. It is now the fourth **resume outcome** (Section 7). This closed OI-14 and supersedes the earlier requirement text that listed it as a reason.

## 6.5 Live read-outs freeze on confirmation

Footage and the clock continue to tick while the dialog is open, because the line is still running. Confirming freezes both, and the dialog states the value the freeze actually took — not the value that was on screen when the operator reached for the button. **Footage is recorded at the freeze, and it is what the pause is logged against.**

## 6.6 What the system does on pause `[CONFIRMED]`

| Action | Detail |
|---|---|
| Run timer paused | Pause duration is tracked separately from productive run time |
| Footage counter frozen | The position at pause is recorded against the run and the alpha |
| Reason logged | Written against the run, the alpha and the footage position |
| Machine tags set to hold | Line speed and drive enable go to their idle state |
| Line status updated | The Line Status Overview shows the line as paused, with the reason visible to a supervisor |
| Pause start stamped | Server-side. The operator cannot modify it |

---

# 7. Resuming a Run

A brief confirmation is required before the line restarts. It shows the pause reason, the duration, and the footage frozen at the pause.

## 7.1 The four outcomes `[CONFIRMED — August 1, 2026]`

| Outcome | What happens |
|---|---|
| **Yes — resume run** | The run timer restarts, machine tags are restored, the screen returns to its active state, and the pause event is closed with an end time and duration |
| **No — log WIP rejection** | The pause event is closed and the WIP rejection dialog opens |
| **No — continue pause** | The dialog is dismissed; the line stays paused |
| **No — check out rod (partial run)** | Rod checkout opens in **Mode B** with the frozen footage already filled in. **The line stays paused behind it** — the pause closes when the checkout is confirmed, not when it is opened |

## 7.2 Duration is reported past an hour

Shift changeover and awaiting-supervisor pauses routinely run long. Duration is shown as hours, minutes and seconds, because a minutes-and-seconds format reports a ninety-minute stop as "90:00", which reads as a data error.

## 7.3 Activity completed

An optional free-text field. Left blank, it is filled with the pause reason. It exists so that a pause whose resolution differed from its stated reason can say so.

---

# 8. Contribution to the Shift Summary

| Shift summary figure | How this screen contributes |
|---|---|
| **Downtime** | Total pause duration, per line, per shift |
| **Downtime reason breakdown** | Grouped by the five pause categories |
| **Line utilisation** | Shift hours less pause minutes and fault minutes, over shift hours |
| **WIP rejection count** | Pauses resolved through the rejection outcome are counted here |

This is why the reason category is submitted as a code: the breakdown is only as reliable as the vocabulary behind it.

---

# 9. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | **Four resume outcomes**, including rod checkout as an outcome rather than a pause reason. OI-14 closed | Aug 1, 2026 |
| D2 | **Weld capture moved off this screen** to the pre-check-in station; the separate weld event screen is retired | Aug 1, 2026 |
| D3 | The pause payload carries a **reason code and category**, never a display label; notes are mandatory for *Other* | Aug 1, 2026 |
| D4 | Footage is **frozen on confirmation** and the dialog reports the frozen value | Aug 1, 2026 |
| D5 | **Machine View tab and View Trends withdrawn**, with Dashboards 13 and 14 | Aug 4, 2026 |
| D6 | **FL2 broadcasts no live gauge or width**; its trace is historical profile | May 21, 2026 |
| D7 | **FL1 has no edger**; edgers are at FM2 stands S2 and S3 only | May 21, 2026 |
| D8 | Payoff alerts are stated in **absolute weight** alongside percentage | Jul 30, 2026 |

---

# 10. Assumptions

| # | Assumption |
|---|---|
| A1 | The footage counter is available continuously from the machine while a run is active; a gap in it is a fault condition, not a zero. |
| A2 | Pausing through this screen sets the line to an idle state but does not constitute an emergency stop, which remains a physical control on the machine. |
| A3 | Machine fault time is captured independently of operator pauses, so that utilisation can distinguish the two. |
| A4 | One run is active per line at a time, so this screen never has to disambiguate between two runs on one machine. |
| A5 | The dialogs launched from here return the operator to this screen on completion or cancellation. |

---

# 11. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-57 / OI-57** | High | **Published tolerance bands** per alloy and temper | The trace bands, and every deviation alert |
| **Q22** | High | **Min/max values** for gauge, width, diameter and ovality | Out-of-specification determination on the trace |
| **OI-97** | Medium | **Rod bundle gross weight** | The denominator behind every payoff percentage (§4.2) |
| **Q26** | Medium | **Panel resolution** — the screen is authored for the shopfloor panel; a 1920×1080 answer is outstanding | Final layout of the trace and action regions |
| — | Medium | **The consecutive out-of-specification reading count** that auto-prompts a checkpoint (§3.2) | The automatic quality prompt |

---

# 12. Related Specifications

| Document | Relationship |
|---|---|
| [Line Status Overview](LineStatusOverview.md) | The floor-level view this screen is reached from |
| [Rod Check-in](RocCheckin.md) | Creates the run this screen monitors |
| [Spool Completion Notification](SpoolCompletionNotification.md) | The weight milestone alerts and machine-stop confirmation raised over this screen |
| [SPC Checkpoint](SPCCheckpoint.md) | Raised from here, and automatically after some events |
| [Die Change and Die Management](DieChangeAndManagement.md) | Opened from here, and from the die-change pause reason |
| [WIP Rejection](WipRejection.md) | Opened from here, and from the rejection resume outcome |
| [Roll Adjust](RollAdjust.md) | Opened from here on FL2 and FL3 |
| [Rod Checkout](RodCheckout.md) | Mode A from here at zero footage; Mode B from the resume outcome |
| [Weld Event](WeldEvent.md) | Where weld capture now lives, and the source of the trace weld markers |
| [Shift Summary](../../../../MVP-2/RequirementDocuments/ShiftSummary.md) | Consumes the pause and rejection data this screen produces |
| [PLC Tag Specification](../../Architecture/PLCTagSpecification.md) | The machine read surface behind the traces and status, and the write surface used on pause |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §3.1 | Trace display rules, including the weld marker labelled with the rod alpha | ☐ | ☐ |
| §3.2 | FL2 shows a historical profile, not a live trace | ☐ | ☐ |
| §3.3 | Machine View and View Trends are withdrawn | ☐ | ☐ |
| §4.1 | The four payoff weight thresholds | ☐ | ☐ |
| §5.1 | The quick-action set and its per-line availability | ☐ | ☐ |
| §5.3 | Roll Adjust is on FL2 and FL3, and not on FL1 | ☐ | ☐ |
| §5.2 | Weld capture is at pre-check-in, not on this screen | ☐ | ☐ |
| §6.2 | The fifteen pause reasons in five categories | ☐ | ☐ |
| §6.4 | Rod checkout is a resume outcome, not a pause reason | ☐ | ☐ |
| §6.5 | Footage freezes on confirmation, and the frozen value is reported | ☐ | ☐ |
| §7.1 | The four resume outcomes | ☐ | ☐ |
| §8 | What this screen contributes to the shift summary | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-57 / OI-57 | Published tolerance bands by alloy and temper | | ☐ |
| Q22 | Min/max dimensional values | | ☐ |
| OI-97 | Rod bundle gross weight | | ☐ |
| Q26 | Panel resolution | | ☐ |
| — | Consecutive out-of-spec reading count for the auto-prompt | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Production** | | | |
| **Process Engineering** | | | |
| 1.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
