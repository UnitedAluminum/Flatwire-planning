# Flat Wire Processing — Line Status Overview Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3
**Version:** 1.3
**Last Updated:** August 15, 2026
**Status:** **First issue** — consolidated from existing specifications; requires review
**Screen reference:** Dashboard 1 — Line Status Overview
**Requirement source:** SRS line-status rules; alert rules as specified in the shopfloor dashboard set

---

> **Please read this one with particular attention.** Every other document in this set is a revision of an existing specification. This is the first statement of this screen as a requirement in its own right, so anything wrong here has not been reviewed before.

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 7. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

The line status overview is the **master board for the flat wire floor** — one view of all three lines, the job on each, its live readings, and every active alert. It is the supervisor's default screen and it is intended to be **persistently displayed**.

## 1.2 Who it is for

| User | Uses it to |
|---|---|
| **Supervisor / Foreman** | Know the state of all three lines without walking them, and see an alert before the operator at the machine needs to react |
| **Operator** | Reach their line's active run, schematic or trends |
| **Operations** | Confirm which configuration each line is running |

## 1.3 Scope

**In scope:** the per-line card and its content; line states; the alert set and its severities; navigation to the operational screens; and refresh behaviour.

**Not in scope:** the transactional screens reached from it; the underlying thresholds where they are owned by another specification; shift and production reporting.

## 1.4 Design intent

**Alert-first.** Payoff weight, gauge deviation and component faults surface here **before** they become a problem at the machine. The board's value is not that it shows three lines — it is that a supervisor looking at it learns what needs attention without having to interpret anything.

---

# 2. Layout

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FLAT WIRE MILL — LINE STATUS                     Aug 1, 2026  07:42 AM  │
│                                                                          │
├────────────────────────┬────────────────────────┬────────────────────────┤
│  FL1                   │  FL2                   │  FL3 (Hybrid)          │
│  ● RUNNING             │  ● IDLE                │  ○ OFFLINE             │
│                        │                        │                        │
│  Order    FW-00421     │  Next    FW-00419      │                        │
│  Material R00042       │  Spool   SP-00031      │                        │
│  Alloy    1100         │  Alloy   —             │                        │
│  Route    Rod → Flat   │  Route   Flat → Finish │                        │
│  Schedule PS-1100-FL1-003                       │                        │
│  Speed    1,620 FPM    │  Speed   —             │                        │
│  Gauge    0.110"       │                        │                        │
│  Width    0.625"       │                        │                        │
│  Payoff 1 4,200 lb ⚠   │                        │                        │
│  Payoff 2 READY        │                        │                        │
│  Run time 1h 22m       │                        │                        │
│                        │                        │                        │
│  [ Open HMI ]          │  [ Open HMI ]          │  [ Open HMI ]          │
├────────────────────────┴────────────────────────┴────────────────────────┤
│  ALERTS                                                                  │
│  ⚠  FL1 — Payoff 1 below 3,000 lb — prepare weld                        │
│  ✓  No active WIP rejections                                            │
└──────────────────────────────────────────────────────────────────────────┘
```

---

# 3. Line Card Content

| Field | Source | Notes |
|---|---|---|
| **Line state** | Machine and system | Running · Idle · Setup · Offline · Fault |
| **Current order** | Scheduling | The active job on the line |
| **Material identity** | Run record | Rod serial on FL1 / FL3; spool serial on FL2 |
| **Alloy** | Order | |
| **Route** | Pass schedule route mode | Rod → flat · flat → finish · hybrid |
| **Pass schedule** | Run record | **The schedule identity in force** — see 3.1 |
| **Speed** | Live machine value | |
| **Gauge · width** | Live measurement | Real-time on FL1 and FL3; **blank on FL2**, whose trace is historical |
| **Payoff 1 weight** | Load cell | Decrements as the rod runs off |
| **Payoff 2 state** | Staging record | Ready · not loaded — see 3.2 |
| **Run time** | System | Since check-in acknowledgement |

## 3.1 Why the pass schedule is on the card `[CONFIRMED — May 4, 2026]`

A supervisor cannot judge an alert without knowing what the line was asked to produce. Showing the schedule identity here means a gauge deviation can be interpreted immediately, rather than after navigating into the run.

## 3.2 Payoff 2 state comes from staging `[CONFIRMED]`

*Ready* means a rod has been pre-checked-in on the second payoff position. This is what makes the critical alert in Section 4 possible: before payoff staging was recorded, nothing in the system knew whether weld material was available.

## 3.3 Idle and offline lines

A line with no active run shows its **next** scheduled job rather than an empty card, and suppresses the live readings — a blank speed is information; a zero is a misstatement.

---

# 4. Alerts `[CONFIRMED]`

| Condition | Level | Message |
|---|---|---|
| Payoff 1 below **3,000 lb** | Warning | Prepare weld — Payoff 2 must be ready |
| Gauge outside target tolerance | Warning | Gauge deviation on FL1 / FL3 |
| Component fault reported by the machine | **Critical** | Component fault — line stopped |
| Active WIP rejection on any line | Warning | WIP rejection requires disposition |
| Payoff 2 **not loaded** with Payoff 1 below **2,000 lb** | **Critical** | No weld material available |

## 4.1 Absolute weight, not percentage

Payoff alerting is driven by **absolute remaining pounds**. Against a 9,000 lb position, a percentage ladder escalates later than the alerts it is meant to reinforce. The same thresholds are used on the schematic and at the pre-check-in station, so all three screens escalate together.

## 4.2 Alert behaviour

| Rule | Detail |
|---|---|
| Alerts are **raised and cleared by the system**, not dismissed by a user | A cleared alert means the condition ended, not that someone looked at it |
| The absence of alerts is stated explicitly | *"No active WIP rejections"* — a blank area is ambiguous |
| Critical alerts are visually distinct from warnings | The two demand different responses |

> `[CLIENT INPUT REQUIRED]` **The alert lifecycle is not fully specified** — whether an alert is acknowledged by anyone, whether that acknowledgement is recorded, and whether alert history is retained for reporting. Today only raise and clear are defined (OI-28).

---

# 5. Navigation

| Action | Destination |
|---|---|
| *(Removed 4 Aug 2026)* | ~~**Open HMI** → the line schematic~~ and ~~**SCADA Trends** → the trend charts~~. Both destinations are descoped (`FR-425` withdrawn); neither header action was ever implemented in the mockup |
| Selecting a running line | That line's active run monitor |
| Selecting an idle line | That line's check-in station |

---

# 6. Refresh and Availability

| Requirement | Detail |
|---|---|
| **Live** | Readings update continuously from the same stream that feeds the active run monitor and the schematic — the three must never disagree |
| **Reconnects automatically** | After a network interruption, without operator action |
| **Machine communications health is visible** | If the connection to the machine is down, the board says so rather than continuing to display the last values as though they were current |
| **Persistent display** | The board is designed to run unattended on a wall panel for a full shift |

**Stale data must never look live.** A board displayed continuously is trusted precisely because nobody is actively checking it, so a lost connection has to be visible on the board itself.

---

# 7. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-35 / Q21** | High | **The line-state vocabulary** — the states the machine reports (running, stopped, paused, fault, threading?) and how they map to the five shown here | The state badge on every card |
| **OI-28** | Medium | **The alert lifecycle** — acknowledgement, retention and history | Alert behaviour and any alert reporting |
| **Q20** | Medium | Should **spool completion milestones** and similar operator notifications also be **mirrored to this board**? | Supervisor visibility of operator-level events |
| **Q26** | High | **Shopfloor panel resolution** — the board is authored for 1280 × 1024; a wall panel is likely to differ | Layout at readable size |
| — | Medium | **Confirmation of the card field set** — is anything a supervisor relies on missing, and is anything here noise? | The card content |
| — | Low | **Does an offline line remain on the board**, or is it hidden until it returns? | Card behaviour |

---

# 8. Assumptions

| # | Assumption |
|---|---|
| A1 | The three lines are the whole of the flat wire floor; the board is not intended to scale beyond them. |
| A2 | Live readings are published per line and are the same values the operator screens consume. |
| A3 | Scheduling can supply the next job for an idle line. |
| A4 | The board is displayed on a shared panel and is not tied to an individual signed-in operator. |
| A5 | FL2 does not publish live gauge and width, so those fields stay blank rather than showing a stale value. |

---

# 9. Related Specifications

| Document | Relationship |
|---|---|
| [PLC Tag Specification](../../Architecture/PLCTagSpecification.md) | The machine tags behind this board — line state, speed, live gauge and width, payoff weight and the component-fault signal |
| [Rod Pre-Check-in](RodPreCheckin.md) | Source of the payoff thresholds and the Payoff 2 ready state |
| [Pass Schedule Management](../../../../MVP-2/RequirementDocuments/PassScheduleManagement.md) | Source of the schedule identity shown on each card |
| [Rod and Spool Check-in](RocCheckin.md) | Sets the line running and starts the run timer |
| [Spool Completion](SpoolCompletionNotification.md) | Operator notifications that may be mirrored here |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.4 | Alert-first intent — the board's job is to surface what needs attention | ☐ | ☐ |
| §3 | The line card field set | ☐ | ☐ |
| §3.1 | The pass schedule identity is shown per line | ☐ | ☐ |
| §3.3 | Idle lines show the next job and suppress live readings | ☐ | ☐ |
| §4 | The five alert conditions and their severities | ☐ | ☐ |
| §4.1 | Payoff alerting by absolute weight | ☐ | ☐ |
| §4.2 | Alerts are system-raised and system-cleared | ☐ | ☐ |
| §5 | The navigation set | ☐ | ☐ |
| §6 | Machine communications health is visible on the board | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-35 / Q21 | Line-state vocabulary | | ☐ |
| OI-28 | Alert lifecycle and retention | | ☐ |
| Q20 | Mirroring of operator notifications | | ☐ |
| Q26 | Panel resolution | | ☐ |
| — | Card field set — anything missing or unnecessary | | ☐ |
| — | Whether offline lines stay on the board | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Supervision** | | | |
| **IT** | | | |
| 1.2 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
