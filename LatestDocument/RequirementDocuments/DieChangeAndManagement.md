# Flat Wire Processing — Die Change and Die Management Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL3 (die change) · Maintenance (die management)
**Version:** 2.1
**Last Updated:** August 1, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Die Change (operator, mid-run) — presented as a **dialog over the paused run**, not as a separate screen (see version 2.1) · Die Management (maintenance, tooling inventory)
**Requirement source:** SRS die-change rules; `Q56` (post-die-change resume gate); die identity convention `D-{size×1000}-{seq}`

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Apr 2026 | Initial specification — die change event capture, reason codes, conditional quality hold and SPC notice, die management screen and its lifecycle operations. |
| 1.1 | May 4, 2026 | Post-die-change resume gate confirmed as a hard block with thread mode permitted; routing corrected for gauge drift and size change. |
| 2.0 | Aug 1, 2026 | **Issued for client review.** FM2 corrected to three 6″ stands. The conflicting die-life colour bands between the two screens raised as a client decision rather than silently reconciled. Restructured as a client deliverable; screen styling, navigation targets and interface payloads removed. |
| 2.1 | Aug 1, 2026 | **Presentation change only — no requirement altered.** The die change is now logged in a dialog over the paused run rather than on a page navigated to. One consequence the client should confirm: when the reason is **gauge drift** or **size change** and *Require SPC on resume* is left on, confirming the change now **opens the SPC checkpoint directly**, pre-filled with this die change as its trigger, instead of leaving the operator to find that screen. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 9. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

Two related capabilities are specified here:

| | **Die Change** | **Die Management** |
|---|---|---|
| Audience | **Operator**, at the line | **Maintenance**, in tooling inventory |
| Nature | A mid-run **event logger** | A **lifecycle manager** |
| Records | That a die was physically replaced, and why | The die inventory, life thresholds, and disposition history |
| Relationship | **Reads** die identity, footage and life threshold from die management | **Is the source of truth** for those three values |

## 1.2 Scope

**In scope:** capture of a mid-run die replacement and its consequences; the reason codes and what each one triggers; quality holds on suspect footage; the post-change verification gate; and the full die inventory lifecycle — registration, life thresholds, counter resets after reconditioning, and retirement.

**Not in scope:** the SPC checkpoint procedure itself; WIP rejection processing; roll gap adjustment on the finishing stands; die procurement.

## 1.3 Applicable lines

| Line | Draw box 1 | Draw box 2 | Die change | Also has |
|---|---|---|---|---|
| **FL1** | Yes | Yes | **Yes** | — |
| **FL3** (hybrid) | Yes | Yes | **Yes** | Roll adjustment on the FM2 stands |
| **FL2** | — | — | **No** | Spool-fed; no drawing dies |

FL3 has the same drawing section as FL1 and adds the three-stand finishing mill downstream — **8″ roller, 6″ S1, 6″ S2 with edger, 6″ S3 with edger**. FL2 has no drawing dies and never needs a die change.

> `[CLIENT INPUT REQUIRED]` **Which lines expose roll adjustment is stated inconsistently** across the requirement set — FL1/FL2 in one place, FL3 only in another, FL2 and FL3 here. FL1, having only drawing and the flattening mill, is unlikely to expose it. Please confirm which action bars carry the control (OI-11).

---

# 2. The Die Change Event

## 2.1 Context

The screen is opened from the active run. **The run is paused while it is open**, and the operator must complete or cancel before production resumes. The event is permanently tied to the output coil's traceability record at the current footage position.

## 2.2 Which die block

Three mutually exclusive choices. The selection drives what the outgoing panel shows and what the confirm action is labelled.

| Choice | Use when |
|---|---|
| **DB1** — draw box 1 | Changing the roughing die only |
| **DB2** — draw box 2 | Changing the finishing die only — **the most common case, and the default** |
| **Both blocks** | A full-line die rebuild, or when a failure on one block has stressed the other. Logged as a single simultaneous event; each incoming die must be identified separately |

The default falls to DB2 because it is the die that sets the final wire diameter before the flattening mill, and it is typically the one closer to end of life in an active run.

## 2.3 The outgoing die — read-only

Auto-filled from the machine's current die assignment. The operator confirms rather than types.

| Field | Meaning |
|---|---|
| Die identity | The die being removed |
| Life consumed | Percentage of scheduled footage life used, with a visual bar |
| Die size | Hole diameter |
| Footage on die | Total footage run since installation |
| Scheduled life | Engineering or supplier specified maximum footage |
| Remaining | Footage left before scheduled end of life |
| Die type | Material and construction |
| Installed | When the outgoing die was loaded |

## 2.4 The incoming die — operator entered

| Field | Entry |
|---|---|
| Die identity | **Scanned**, or keyed. The scan resolves against the die inventory and populates the fields below |
| Condition | **New** (full scheduled life) or **Reconditioned** (reduced scheduled life) |
| Die size | Must match the outgoing die **unless the reason is a size change** |
| Source | Die room, or external supplier |
| Inspection | Timestamp of the pre-use inspection, from the die room record |
| Die type | Must match the outgoing die type |
| Scheduled life | From the die record |

**A die that is not in the inventory cannot be installed.** If a scanned die has no record, the scan is refused with an instruction to have Maintenance register it first. This is what keeps the footage counter and life threshold meaningful.

## 2.5 Reason for the change

Five mutually exclusive reasons. Each determines what else the system does.

| Reason | Meaning | Consequence |
|---|---|---|
| **Planned life** *(default)* | The die reached or approached its scheduled footage limit | None — routine swap |
| **Gauge drift** | Die wear is pushing gauge toward or outside specification | **SPC checkpoint required before full production** |
| **Die failure** | The die cracked, chipped or broke during the run | **Quality hold section opens** for the suspect footage range |
| **Size change** | A different hole size is deliberately required | **SPC checkpoint required before full production** |
| **Other** | Anything not covered above | Detail expected in the observation |

## 2.6 Quality hold — when the die failed

Material produced with a failing die may be off specification, so the operator marks the suspect range.

| Field | Behaviour |
|---|---|
| **Hold from footage** | Editable. Defaults to the footage at which the current rod started on this die; the operator can move it if they know when the failure actually occurred |
| **Hold to footage** | **Read-only** — the current counter value at the time of the die change. The system knows when the change was logged |
| **Flag for QA hold** | Creates a quality hold against that footage range on the output coil. QA must review and disposition the range before the coil can ship |

## 2.7 The verification gate — when gauge drifted or size changed `[CONFIRMED — May 4, 2026]`

| Rule | Behaviour |
|---|---|
| **Hard block, not a soft queue** | Confirming the die change routes **directly to the SPC checkpoint**, not back to the run |
| **Thread mode permitted** | The line may be run slowly to confirm the new die is seated and producing on-target material |
| **Full production blocked** | The run cannot return to normal production until the checkpoint passes |
| **The requirement may be waived** | Only as a supervisor-level action, and every waiver is audited and appears as a flagged exception on shift and quality reporting |

### Why both reasons require it

- **Gauge drift** — the die was replaced *because* dimensions were drifting. The replacement's output is unverified, and the process is not back in control until measurements confirm it.
- **Size change** — the hole size changed deliberately, so the new target dimensions are unverified until measured.

In both cases, material run before verification could be out of specification.

> **This gate is enforced at confirmation, not at resume.** There is no general-purpose resume control on the active run screen — resume exists only inside the pause flow, and the die change screen returns directly to the run. The gate therefore has to sit on the confirm action, which is where it is specified.

## 2.8 Post-change routing `[CONFIRMED]`

| Reason | On confirm |
|---|---|
| Planned life | Return to the run; production resumes |
| Die failure | Return to the run; production resumes — **the hold is on the footage, not on the run** |
| **Gauge drift** | **Route to the SPC checkpoint.** Run stays blocked; thread mode allowed |
| **Size change** | **Route to the SPC checkpoint.** Run stays blocked; thread mode allowed |

## 2.9 Audit stamp and confirmation

| Field | Source |
|---|---|
| Operator | The active session |
| Timestamp | **Server-stamped at submission** — the screen clock is for operator visibility only |
| Footage at change | Machine encoder position when the change was initiated |
| Output coil | The coil the event is recorded against |

**Cancel is always safe.** No partial record is written; the run simply resumes with no die change logged.

## 2.10 Information recorded on confirmation

| Item |
|---|
| Die block changed |
| Outgoing die identity, size, and footage accumulated on it |
| Incoming die identity, size and condition |
| Reason code |
| Footage at the change |
| Output coil identity |
| Operator and server timestamp |
| Quality hold range, where a die failure was flagged |
| Whether an SPC checkpoint is required |

---

# 3. Die Change — Design Principles

| Principle | Detail |
|---|---|
| **Immutable record** | Once confirmed, a die change event is never edited. Corrections go through a separate audit route |
| **Default to the common case** | DB2, planned life and new condition are pre-selected; the operator overrides only when something unusual applies |
| **Conditional sections are additive** | Selecting *die failure* adds a quality hold workflow — it does not replace the normal die change flow. Both happen |
| **Server timestamp** | The event time is captured server-side at receipt |
| **Cancel writes nothing** | No partial records |

---

# 4. Die Management

The maintenance-facing counterpart, reached from tooling inventory. It is not accessible from the shopfloor screens.

## 4.1 Division of responsibility

| Capability | Die change | Die management |
|---|---|---|
| Log a mid-run die swap | **Yes** | No |
| View outgoing die remaining life | Yes — read only | Yes — editable |
| Scan and assign an incoming die | **Yes** | No |
| Register a new die into inventory | No | **Yes** |
| Set or edit a life threshold | No | **Yes** |
| Reset the footage counter after reconditioning | No | **Yes** |
| Retire a die permanently | No | **Yes** |
| View full run history per die | No | **Yes** |
| View the replacement and reset log | No | **Yes** |

## 4.2 Inventory view

A summary strip states how many dies are active on line, overdue for replacement, nearing end of life, and available as spares. The list is filterable by status and by line, and is sorted by urgency — overdue first, then nearing end, active, spare and retired.

| Column | Content |
|---|---|
| Identity | Die identifier |
| Block | DB1 or DB2 |
| Size | Hole diameter |
| Line | Currently assigned line, or none for a spare |
| Status | Active · Nearing end · Overdue · Spare · Retired |
| Life used | Progress bar and percentage |
| Footage | Footage run against threshold |
| Last reset | Date of the last counter reset, or *new* for a first-install spare |

## 4.3 Die detail

Selecting a die shows its identity, status, block, size and type, the line it is on, its life bar, and:

| Field | Notes |
|---|---|
| Footage on die | Since the last counter reset |
| Life threshold | Configured maximum footage |
| Remaining | Threshold less footage; emphasised when near or past the limit |
| Die size and type | |
| Last reset by | Operator and date |

Alerts are stated in plain language: *"Replacement overdue — pull at end of current run"* for an overdue die, and *"Schedule a replacement die — do not load for a new order without a spare on hand"* for one nearing end of life.

Two history views are available: **run history** (order, line, footage added, date, operator — one row per run in which the die was active) and the **replacement log** (install, reset and retirement events, each with who performed it and what changed).

## 4.4 Lifecycle operations

| Operation | Purpose | What it captures |
|---|---|---|
| **Reset counter** | The die has returned from reconditioning, or a new spare is being entered into the counter system | Disposition (reconditioned or new spare) · date removed from line · date returned and ready · **new life threshold** (reconditioned only) · inspection date · performed by · die room source · notes. Footage resets to zero |
| **Edit threshold** | Change the footage limit — for this die, or for **all dies of the same type and size** | A reason is required. Changing the type-level value updates the default for future registrations |
| **Retire die** | Permanent removal | Date retired · reason (end of life · physical damage · bore out of tolerance · size discontinued · other) · notes. Retired dies remain in history for traceability but leave the active and spare counts |
| **Register new die** | Bring a die into inventory as a spare | Identity (`D-{size×1000}-{seq}`) · compatible block · hole size · type and material · life threshold · source · condition · inspection date · notes |

**A reconditioned die does not return with its original life.** The reset defaults its threshold to a reduced figure, because a re-lapped die has less remaining life than a new one — the default is a starting point that Maintenance can adjust.

## 4.5 What the die change screen consumes from here

| Value | Used for |
|---|---|
| Die identity → size, type, condition | Resolving the incoming die scan |
| Footage counter | The outgoing die's accumulated footage and remaining life |
| Life threshold | The life bar and the remaining figure |

---

# 5. Die Life Status

| Status | Condition | Meaning |
|---|---|---|
| **Active** | Well inside the threshold | Normal |
| **Nearing end** | Approaching the threshold | Schedule a replacement |
| **Overdue** | At or past the threshold | Pull at the end of the current run |
| **Spare** | No footage, not installed | Available |
| **Retired** | Permanently removed | Historical only |

> `[CLIENT INPUT REQUIRED]` **The two screens currently use different bands for the same die**, and both are internally consistent with their own source:
>
> | Screen | Bands |
> |---|---|
> | Die Change | Green below 60 % · amber 60–85 % · red above 85 % |
> | Die Management | Active below 65 % · nearing end 65–79 % · overdue at 80 % and above |
>
> The same die therefore reads differently depending on where it is viewed, which is exactly the kind of inconsistency that erodes trust in a life indicator. **One set must be chosen** (OI-12).

> `[CLIENT INPUT REQUIRED]` **Are these bands fixed, or configurable per die type?** A roughing die at DB1 may warrant a different alert point from a finishing die at DB2, where gauge drift risk is higher. Our recommendation is that Maintenance be able to configure the boundary per die type, with a system default.

---

# 6. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | **The post-die-change gate is a hard block on full production**, enforced at the confirm action, with thread mode permitted | May 4, 2026 |
| D2 | **Gauge drift and size change both route to the SPC checkpoint**; planned life and die failure return to the run | May 4, 2026 |
| D3 | A **die failure** holds the suspect **footage range**, not the run | Apr 2026 |
| D4 | A die that is not registered in inventory **cannot be installed** | Apr 2026 |
| D5 | Die change events are **immutable**; corrections are separate records | Apr 2026 |
| D6 | Die management is the **source of truth** for die identity, footage and life threshold | Apr 2026 |

---

# 7. Assumptions

| # | Assumption |
|---|---|
| A1 | Every die in physical circulation is registered in inventory before it reaches the line. |
| A2 | The machine reports the current die assignment, so the outgoing panel does not need operator entry. |
| A3 | The footage encoder is the authoritative source of both the change position and the accumulated die footage. |
| A4 | Die room inspection records exist and are readable, so the incoming die's inspection date can be displayed rather than typed. |
| A5 | Reconditioning reduces available life, and the reduced figure is set at the counter reset. |

---

# 8. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-12** | Medium | **Which die-life colour bands apply** — 60/85 % or 65/79/80 % | A consistent operator signal across both screens |
| — | Medium | **Are life bands configurable per die type**, or fixed system constants? | Die management configuration |
| **OI-11** | Medium | **Which lines expose roll adjustment** | Which action bars carry the control |
| **Q56** | Medium | **Who may waive the post-die-change verification gate** | Override authority and audit |
| **Q41** | Medium | **Die life tracking basis** — is scheduled life expressed in footage alone, or does another measure apply? | The threshold model |
| **OI-18** | Medium | Should the SPC checkpoint carry an **explicit link to the die change** that raised it? | Proving which change a checkpoint verified |

---

# 9. Related Specifications

| Document | Relationship |
|---|---|
| [SPC Checkpoint](SPCCheckpoint.md) | The verification gate a gauge-drift or size-change die change routes into |
| [Pass Schedule Management](PassScheduleManagement.md) | Die sizes are pass-schedule parameters; a size change is a configuration change |
| [Rod Check-in](RocCheckin.md) | Pushes the die configuration to machine control at acknowledgement |
| [HMI and SCADA Layout](HMIAndSCADALayout.md) | Die changes appear as event markers on the trend charts |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.3 | Die change applies to FL1 and FL3 only | ☐ | ☐ |
| §2.2 | Three die block choices, DB2 defaulted | ☐ | ☐ |
| §2.4 | An unregistered die cannot be installed | ☐ | ☐ |
| §2.5 | The five reason codes and what each triggers | ☐ | ☐ |
| §2.6 | Quality hold captures a footage range, with the end read-only | ☐ | ☐ |
| §2.7 | Hard block with thread mode after gauge drift or size change | ☐ | ☐ |
| §2.8 | The post-change routing table | ☐ | ☐ |
| §4.4 | The four lifecycle operations and what each captures | ☐ | ☐ |
| §4.4 | A reconditioned die returns with a reduced default life | ☐ | ☐ |
| §5 | The five life statuses | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-12 | Which die-life bands apply | | ☐ |
| — | Whether bands are configurable per die type | | ☐ |
| OI-11 | Which lines expose roll adjustment | | ☐ |
| Q56 | Waiver authority for the verification gate | | ☐ |
| Q41 | Die life tracking basis | | ☐ |
| OI-18 | Checkpoint-to-die-change link | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Maintenance** | | | |
| **Operations** | | | |
| **Quality** | | | |

---

## Change Log

| Date | Change |
|---|---|
| Apr 2026 | Initial specification — die change event capture, reason codes, conditional quality hold and SPC notice; die management screen, lifecycle operations and life thresholds. |
| May 4, 2026 | Post-die-change resume gate confirmed as a hard block with thread mode permitted; routing corrected for gauge drift and size change. |
| Aug 1, 2026 | **Reissued as version 2.0 for client review.** FM2 corrected to three 6″ stands with edgers at S2 and S3. The conflicting die-life colour bands between the two screens raised as a client decision instead of being silently reconciled, alongside the band-configurability question. Roll-adjust line applicability flagged as unresolved. Screen styling, navigation targets, interface payloads and mockup-state commentary removed; the gap-analysis framing replaced by the confirmed routing rules it produced. |
