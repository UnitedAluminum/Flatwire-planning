# Flat Wire Processing — Supervisor Shift Summary Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3, individually and combined
**Version:** 1.1
**Last Updated:** August 12, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 10 — Supervisor Shift Summary
**Requirement source:** SRS shift reporting rules; the May 21 2026 per-machine page decision

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Aug 11, 2026 | **First issue.** Consolidated from the shopfloor dashboard design reference, which was the only home for this screen. Carries the May 21 2026 decision that the summary is presented as per-machine pages with the KPI strip following the selected machine, the four content blocks, the data source for every figure, and the navigation added when the spool queue screen was created. Screen styling, layout dimensions and scripting detail removed for the client issue. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 9. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register; those prefixed **PP** are findings raised by the project plan document set.

---

# 1. Introduction

## 1.1 Purpose

The shift summary is the supervisor's account of what the flat wire floor produced during a shift: how much material each line put out, how it performed against available time, what failed quality, how many welds were made, and what material is sitting on the floor at the end of it.

## 1.2 Who it is for

A shift supervisor or shift manager, at end of shift and on demand during it. It is a reporting view — **it writes nothing.** Every figure on it is derived from records created by the operator screens.

## 1.3 Scope

**In scope:** the shift window and machine selection, throughput and utilisation figures, quality and weld counts, end-of-shift material status, the data source behind each figure, and export and print.

**Not in scope:** the events themselves — pauses, checkpoints, rejections, welds and coil completions are each specified with their own screen. Overall equipment effectiveness reporting is a separate scope item (see §9). Cost and yield reporting is outside this specification.

## 1.4 Presentation — per-machine pages `[CONFIRMED — May 21, 2026]`

The summary was originally a single page stacking all three lines. **The client corrected this to individual machine pages.** FL1, FL2 and FL3 are selected by tab, and **the KPI strip — footage and weight — reflects the selected machine.** An *All Lines* view remains available for the combined position.

The reason is operational: a supervisor investigating why FL2 underperformed does not want FL1's numbers in the same visual field, and the earlier design made the per-line figures secondary to a combined total that nobody was accountable for.

---

# 2. Shift Window and Machine Selection

## 2.1 The machine selector

| Selection | KPI tiles show | Utilisation shows |
|---|---|---|
| **FL1** | FL1 footage, weight out, coils, downtime | The FL1 timeline |
| **FL2** | FL2 footage, weight out, coils, downtime | The FL2 timeline |
| **FL3** | FL3 footage, weight out, coils, downtime | The FL3 timeline |
| **All Lines** | Combined totals | All three timelines |

## 2.2 A line that did not run says so

A line idle or offline for the whole shift shows zero with an explicit statement that it did not run. A blank tile and a zero tile read the same way and mean different things — no production versus no data.

> `[CLIENT INPUT REQUIRED]` **Shift boundaries are not defined anywhere in this design.** Every figure on this screen is filtered to a shift window, and no shift start and end times, shift names, or weekend and holiday pattern have been supplied. A run that crosses a shift boundary must also be apportioned or attributed, and that rule is not stated either. Listed as OI-101, and it blocks every number on this screen.

---

# 3. Throughput

| Figure | Basis |
|---|---|
| **Footage** | The footage counter for that line, filtered to the shift window |
| **Weight out** | The sum of net weights of coils completed on that line |
| **Orders run** | Distinct orders processed on that line during the shift |
| **Coils out** | Output alphas completed on that line during the shift |
| **Skids closed** | FL2 and FL3 only — a skid closes on its second coil |
| **Utilisation** | Shift hours, less pause minutes and machine fault minutes, over shift hours |

## 3.1 Both footage and weight are shown `[CONFIRMED]`

Footage is what the machine counts; weight is what the customer buys and what the plant is measured on. Neither substitutes for the other, and a gauge or width change alters the relationship between them within a single shift.

## 3.2 Utilisation distinguishes pauses from faults

Operator pauses and machine faults are both downtime, and they are not the same management problem. Utilisation subtracts both, and the downtime breakdown separates them.

---

# 4. Downtime

Downtime is grouped by the pause reason categories recorded on the active run monitor — **Equipment / Mechanical, Material Handling, Quality / Measurement, Operational, Safety**, and *Other*.

This grouping is only as reliable as the vocabulary behind it, which is why the pause dialog submits a reason code and category rather than a display label. A wording change on the operator screen must not fragment a downtime category in this report.

---

# 5. Quality and Welds

| Figure | Basis |
|---|---|
| **SPC pass rate** | Checkpoint records for the shift window |
| **WIP rejections** | Rejection records filtered to the shift, including those raised from a resumed pause |
| **Material suspended** | Coils and rods currently on hold from this shift |
| **Weld events per line** | Weld records filtered to the shift |
| **Weld quality** | The aggregate pass state of those welds |

## 5.1 Weld counts are per line

FL1 and FL3 make induction welds to sustain continuous feed. FL2 does not weld — it is fed from a spool. A weld count against FL2 is a data error, not a legitimate zero.

> `[CLIENT INPUT REQUIRED]` **FL2 currently has no weld capture path at all** (gaps **G27**, **G28**), following the retirement of the separate weld event screen. If FL2 can produce a weld under any circumstance, this figure has no source.

---

# 6. End-of-Shift Material Status

| Figure | Basis |
|---|---|
| **Rod in storage** | Rod available and not yet staged |
| **Spools on floor** | Completed FL1 spools awaiting FL2 |
| **Coils in packing** | Completed coils awaiting label or skid closure |
| **Material held** | Rods and coils on hold, with the reason |

## 6.1 The spool figure navigates to the spool queue `[CONFIRMED — August 2, 2026]`

The spools-on-floor figure links to the FL2 Spool Queue. **This link previously went nowhere** — it was drawn as a navigation target before a spool queue screen existed. It now resolves.

## 6.2 Held material names itself

A held count without identities is not actionable at a shift handover. The held block names the material and states the reason it is held.

---

# 7. Export and Print

| Action | Purpose |
|---|---|
| **Export shift report** | The summary as a file, for distribution and retention |
| **View rejections** | Opens the rejection detail behind the count |
| **Print** | A physical copy for shift handover |

**Printing is permitted here.** The digital-traveler rule removes traveler printing for flat wire; it does not apply to reports or to coil and skid labels.

> `[CLIENT INPUT REQUIRED]` **The export format and its recipients are unspecified** — whether a spreadsheet, a PDF, or a scheduled e-mail at shift end, and who receives it (OI-102).

---

# 8. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | The summary is presented as **per-machine pages**, with the KPI strip reflecting the selected machine | May 21, 2026 |
| D2 | An **All Lines** view is retained for the combined position | May 21, 2026 |
| D3 | Both **footage and weight** are reported; neither substitutes for the other | Apr 2026 |
| D4 | **Utilisation subtracts operator pauses and machine faults**, and the breakdown separates them | Apr 2026 |
| D5 | Downtime is grouped by the **five pause reason categories** recorded on the run monitor | Aug 1, 2026 |
| D6 | The screen is **read-only** and derives every figure from records created elsewhere | Apr 2026 |
| D7 | The spools-on-floor figure **navigates to the FL2 Spool Queue** — a link that previously resolved to nothing | Aug 2, 2026 |
| D8 | **Printing is permitted here**; the digital-traveler rule does not extend to reports or labels | Apr 28, 2026 |

---

# 9. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-101** | High | **Shift definitions** — start and end times, shift names, weekend and holiday pattern, and how a run crossing a boundary is attributed | **Every figure on this screen** |
| **G27 / G28** | High | **FL2 weld capture** — FL2 has no path to record a weld, so the per-line weld figure has no source for that line | The weld block for FL2 |
| **OI-102** | Medium | **Export format and recipients** | The export action |
| **PP-03** | Medium | **Overall equipment effectiveness has no owning story or phase**, although it has an approved mockup and source requirements. Whether OEE is delivered, and whether it is reached from here, is undecided | OEE scope, and this screen's navigation |
| **Q26** | Medium | **Panel resolution** — this screen is authored for the shopfloor panel | Final layout |
| **OI-107** | Low | Whether a **rejection list screen** is required, or the count and its drill-through suffice | The *view rejections* action |

---

# 10. Assumptions

| # | Assumption |
|---|---|
| A1 | Machine fault time is available separately from operator pause time, so utilisation can distinguish them. |
| A2 | Net weight per completed coil is available, which depends on the alloy density factor being held as reference data. |
| A3 | This screen is read-only and derives every figure from records created elsewhere; it never adjusts a figure. |
| A4 | A supervisor viewing the summary has visibility of all three lines, irrespective of which line they are assigned to. |
| A5 | Historical shifts can be selected, not only the current one, so that a handover or an investigation can look back. |

---

# 11. Related Specifications

| Document | Relationship |
|---|---|
| [Active Run Monitor](../../MVP-1/ProjectPlan/Business/Screens/ActiveRunMonitor.md) | Produces the pause and downtime data, and the reason categories this report groups by |
| [Line Status Overview](../../MVP-1/ProjectPlan/Business/Screens/LineStatusOverview.md) | The live floor view; this is its retrospective counterpart |
| [SPC Checkpoint](../../MVP-1/ProjectPlan/Business/Screens/SPCCheckpoint.md) | Supplies the pass rate |
| [WIP Rejection](../../MVP-1/ProjectPlan/Business/Screens/WipRejection.md) | Supplies the rejection count and the held material |
| [Output Coil Completion](../../MVP-1/ProjectPlan/Business/Screens/OutputCoilCompletion.md) | Supplies coils out, weight out and skids closed |
| [Weld Event](../../MVP-1/ProjectPlan/Business/Screens/WeldEvent.md) | Supplies the weld counts |
| [Spool Queue](../../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) | The target of the spools-on-floor navigation |
| [Rod Checkout](../../MVP-1/ProjectPlan/Business/Screens/RodCheckout.md) | Rods that left the line during the shift |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.4 | Per-machine pages, with the KPI strip following the selected machine | ☐ | ☐ |
| §2.1 | The FL1 / FL2 / FL3 / All Lines selector and what each changes | ☐ | ☐ |
| §2.2 | A line that did not run states so, rather than showing a bare zero | ☐ | ☐ |
| §3 | The throughput figures and their basis | ☐ | ☐ |
| §3.2 | Utilisation subtracts both pauses and faults, and reports them separately | ☐ | ☐ |
| §4 | Downtime grouped by the five pause categories | ☐ | ☐ |
| §5.1 | Weld counts are per line, and FL2 does not weld | ☐ | ☐ |
| §6.2 | Held material is named, not only counted | ☐ | ☐ |
| §7 | Export, rejection drill-through, and print | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-101 | Shift definitions and boundary attribution | | ☐ |
| G27 / G28 | Whether FL2 can weld, and where it would be captured | | ☐ |
| OI-102 | Export format and recipients | | ☐ |
| PP-03 | Whether OEE is in scope, and its owner | | ☐ |
| Q26 | Panel resolution | | ☐ |
| OI-107 | Whether a rejection list screen is required | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Production** | | | |
| **Quality** | | | |
| 1.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
