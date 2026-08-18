# Flat Wire Processing — Rod Checkout Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL3
**Version:** 2.3
**Last Updated:** August 15, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 12 — Rod Checkout. Presented as a **dialog** rather than a separate screen (see version 2.1); the caller states the mode.
**Requirement source:** SRS §4.17 (post-check-in removal); pre-check-out has **no source requirement ID** — new text is proposed in Section 6

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

The existing rod lifecycle has **no formal checkout step**. Once checked in, a rod leaves that state only by running to completion, by rejection or scrap, or by being welded to its successor. United Aluminum requires the ability to **deliberately remove a rod from a payoff position** without any of those outcomes — because the wrong rod was scanned, because an order was rescheduled, because a defect was found late, or because the rod must be relocated.

This document specifies that capability.

## 1.2 Scope

**In scope:** removal of rod from a payoff position in three distinct situations; the reason and disposition captured in each; the approval required; the machine-control precondition; and the material status that results.

**Not in scope:** WIP rejection processing; the partial re-check-in of a rod that comes back later; spool and coil completion; weld events.

## 1.3 The three modes

| Mode | Situation | Run exists | Footage | Pass schedule | Machine tags | Approval |
|---|---|---|---|---|---|---|
| **Mode P** — pre-check-out | Rod was **staged but never checked in** | No | 0 | Nothing to void | **Nothing to clear** | Depends on the weld (Section 6) |
| **Mode A** — pre-run checkout | Checked in and acknowledged, **run not started** | Yes | 0 | **Voided** | **Cleared** | Operator |
| **Mode B** — mid-run checkout | Checked in and **running** | Yes | > 0 | **Voided** | Cleared after a confirmed stop | **Supervisor** |

The distinction that matters: **Mode A and B gate on footage produced; Mode P gates on whether the material has been physically joined.** These are different risks and they arrive at different moments.

---

# 2. Mode A — Pre-Run Checkout

The rod was checked in — payoff assigned, pass schedule acknowledged — but the line has not yet started.

## 2.1 Triggers

| Trigger | Notes |
|---|---|
| Wrong rod scanned during check-in | Operator error on the serial |
| Order cancelled or rescheduled before the run | Planning change |
| Rod fails a physical re-inspection after check-in | Late discovery of a surface defect |
| Rod relocated to a different line | FL1 ↔ FL3 reassignment |

## 2.2 What the operator provides

| Field | Entry |
|---|---|
| Rod serial | Read-only — the current rod |
| Payoff position | Read-only |
| Checkout reason | **Required** — from the codes below |
| Notes | Optional; **required** when the reason is *Other* |
| Return destination | **Required** — floor storage or warehouse |

**Reason codes:** wrong rod / mis-scan · order cancelled or deferred · failed re-inspection · relocated to a different line · other.

## 2.3 What the system does

| # | Action |
|---|---|
| 1 | Rod status changes from `INFLAT` to `STAGED` (returned to the floor) or `RECEIVED` (returned to the warehouse), per the operator's selection |
| 2 | The payoff position is cleared |
| 3 | The pass-schedule acknowledgement is **voided** |
| 4 | The machine tags for that payoff position are **cleared** |
| 5 | The checkout event is logged — timestamp, operator, reason, resulting status |
| 6 | The station returns to *ready for check-in* |

---

# 3. Mode B — Mid-Run Checkout

The rod is running and footage has been produced, but the rod must come off before it is exhausted.

## 3.1 Triggers

| Trigger | Notes |
|---|---|
| Equipment failure requiring rod removal | A fault that cannot be cleared with the rod loaded |
| Quality hold decision | A supervisor pulls the rod mid-run |
| Order quantity reached early | Less footage needed than the rod can supply |
| Shift deferral | The run cannot complete in the current shift |

**Reason codes:** equipment failure · quality hold · order quantity reached · shift deferral · other.

## 3.2 Supervisor approval is mandatory `[CONFIRMED — May 4, 2026]`

**The operator cannot unilaterally accept partial material.** The operator submits; a supervisor reviews and dispositions. The approval is notification-driven, so the supervisor can act from any connected terminal rather than having to walk to the line.

## 3.3 Flow

| Stage | Detail |
|---|---|
| **Entry** | From the active run, through the Pause dialog — *Check out rod (partial run)* |
| **Operator provides** | Footage at removal (**captured automatically from the counter, read-only**) · remaining weight estimate (optional) · checkout reason · rod disposition (hold / scrap / defer) · notes |
| **On submit** | The run event closes with a partial run record at the counter value · rod status becomes `HOLD`, `SCRAP` or `STAGED` per the disposition · machine tags cleared · the checkout is logged with footage, reason and disposition · **a pending-disposition record is created — the material is locked, not plannable, and carries no identity yet** · the supervisor is notified |
| **Supervisor reviews** | The gauge trace for the partial run, footage produced, the stated reason, operator and timestamp |
| **Supervisor decides** | **Accept** → partial spool identity issued, enters the spool queue · **Hold** → identity issued with a hold status, QA must release · **Reject** → routed to WIP rejection, material to scrap |
| **Recorded** | Supervisor, decision, reason code and timestamp |

**No material identity is created until the supervisor has dispositioned it** `[CONFIRMED — May 4, 2026]`. Issuing an identity first and reversing it afterwards would put unapproved material into the planning pool.

## 3.4 Entry-point rule

| Situation | Entry point |
|---|---|
| Checked in, not acknowledged | Rod check-in screen — *Check out rod* |
| Acknowledged, run not started (footage = 0) | Active run screen — *Check out rod* |
| Footage > 0 | **Only** through the Pause dialog — *Check out rod (partial run)* |

**The direct control is disabled once footage exceeds zero.** From that point the mid-run path is the only route, which guarantees that footage and material disposition are always captured for a partial run.

---

# 4. Machine-Control Precondition

## 4.1 The application is a gatekeeper, not a stop controller `[CONFIRMED]`

Checked-in rod is represented to the mill by a set of machine-control values — which rod is loaded, whether the line is running, the footage counter, and the checked-in flag. Checking a rod out means clearing those values.

**Before the checkout dialog opens, the application reads the line state.**

| Line state | Behaviour |
|---|---|
| **Running** | Checkout is **blocked**: *"Line is still running. Stop the line before checking out the rod."* The dialog does not open |
| **Stopped** | The dialog opens, the footage counter value is read and locked at that moment, and the checkout may proceed |

**The application never issues a stop command.** The operator remains in physical control of the machine at all times; the software only enforces that the stop has already happened before any value is touched.

## 4.2 Why

| Reason | Detail |
|---|---|
| **Safer** | The software cannot initiate a motion change; physical control stays with the operator |
| **Simpler** | One value is read; nothing is commanded. No bidirectional handshake is required |
| **Independent of machine capability** | It does not depend on whether the controller supports a software-initiated safe stop |
| **Footage is accurate** | By the time the dialog opens the line is confirmed stopped, so the counter value is final |

## 4.3 Why clearing while running is dangerous

- The drive loses the rod's identity mid-motion, and any control logic tied to those values may behave unpredictably.
- The footage counter stops recording while wire is still moving — that footage is physically real but invisible to the system.
- The partial material record then understates what is physically on the spool.
- Interlocks that depend on the checked-in flag to permit motion could force an uncontrolled stop rather than a controlled deceleration.

Small footage discrepancies compound across successive partial runs and end up as a traceability gap at certificate time.

> `[CLIENT INPUT REQUIRED]` **What "stopped" means must be confirmed with the controls team** — whether the line-state value is a discrete stopped state, or whether it also requires drive speed below a threshold. The checkout guard must match the machine's own definition of stopped. The state vocabulary itself is also undocumented (OI-35, Q13).

---

# 5. Mode P — Pre-Check-Out (Removing a Staged Rod)

A rod that was **pre-checked-in at the payoff but never checked in** has no run to close, no acknowledgement to void and no machine values to clear. Removing it is a different transaction, and its approval turns on one question only: **has the rod been welded?**

| Rod state | Approval | Reason | Resulting status | Why |
|---|---|---|---|---|
| **Not welded** | **Operator** | Captured | Returns to inventory | Nothing was committed; the bundle simply comes off the position |
| **Welded** | **Supervisor override** | **Required, documented** | **`HOLD`** — routed to WIP rejection | The rod is induction-welded to the rod in the mill. Removing it means **cutting or splitting the material**, so it is a rejection, not a return |

`[CONFIRMED — July 30, 2026]`

Staging and un-staging need **no line-state precondition**. The gatekeeper rule of Section 4 exists because clearing values on a running line is dangerous; an idle payoff position is not running, which is precisely why staging is safe to perform while the other position draws.

---

# 6. Proposed Requirement Text

The SRS covers removal only *after* check-in. The following have no source requirement and are proposed here for adoption.

| Ref | Proposed requirement |
|---|---|
| **RC-1** | The system shall support removal of a rod that was pre-checked-in but never checked in, without creating or closing a production run. |
| **RC-2** | Removal of an **unwelded** staged rod shall require the operator only, with a captured reason. |
| **RC-3** | Removal of a **welded** staged rod shall require supervisor authorisation with a documented reason, and shall place the rod on `HOLD`. |
| **RC-4** | Every supervisor authorisation in this process — mid-run checkout, partial-material disposition, and welded removal — shall record the **authorising supervisor, the timestamp, and the reason**, and that record shall be retrievable against the material. |
| **RC-5** | No material identity shall be issued for partial material until a supervisor has dispositioned it. |
| **RC-6** | The checkout control shall be unavailable while the line reports running. |

> **RC-4 corrects an omission.** The mid-run and disposition approvals were agreed in May 2026 and described as producing a record of supervisor, decision, reason and timestamp — but no such record was ever specified into the design. It is being added for all three approval points at once, together with the pre-check-out override.

---

# 7. Information Captured

| Item | Notes |
|---|---|
| Rod serial | |
| Payoff position | |
| Link to the originating check-in | Absent for Mode P |
| Mode | Pre-check-out · pre-run · mid-run |
| Checkout reason | From the mode's reason codes |
| Footage at checkout | Zero for Mode P and Mode A; the locked counter value for Mode B |
| Remaining weight estimate | Optional operator estimate |
| Rod disposition | Returned to floor · returned to warehouse · hold · scrap · defer |
| Material disposition | Hold · scrap · accept partial — Mode B only |
| Partial material identity | Issued only on supervisor acceptance |
| Authorising supervisor, timestamp, reason | Required wherever an approval or override applies |
| Operator and timestamp | Server-stamped; not operator-editable |
| Notes | |

## 7.1 Resulting rod status

No new status values are needed.

| Outcome | Transition |
|---|---|
| Returned to floor storage | `INFLAT` → `STAGED` |
| Returned to the warehouse | `INFLAT` → `RECEIVED` |
| Held for review | `INFLAT` → `HOLD` |
| Scrapped | `INFLAT` → `SCRAP` |
| Deferred on the same line | `INFLAT` → `STAGED` (re-check-in required) |
| Welded rod removed at staging | → `HOLD` |

## 7.2 Partial material takes its own identity, linked back to the rod `[PROPOSED]`

When a supervisor accepts the partial material produced before a Mode B checkout, that material is issued **its own spool identity** — not a reservation against the rod's identity. If the same rod returns and runs again, that second segment takes a **second, separate identity**. Both point back to the same rod.

| Segment | Identity | Links to |
|---|---|---|
| First run before checkout | `SP-#####` | The rod `R#####` |
| Second run after re-check-in | `SP-#####` (a different number) | The same rod `R#####` |

**Why not one identity spanning both runs.** Each spool is a separate physical object on a separate bobbin. Between the two runs it can be moved, inspected, annealed or shipped independently, and it needs a settled identity to carry a label and to record those events against. A single identity held open across the gap would mean the first segment sits in storage with nothing to label it, and if the rod is later scrapped instead of re-run, that identity is never closed and the first spool becomes untrackable.

The two runs may also differ in operator, die, pass schedule and quality readings. Those conditions attach to the identity of the segment produced under them, so merging both segments into one identity would make a certificate unable to state which footage was produced under which conditions.

**The link back to the rod is what keeps the genealogy whole.** Each spool identity records the rod that produced it, so a certificate query resolves both segments to the same rod, and from there to its heat, alloy and receiving record.

> `[CLIENT INPUT REQUIRED]` **Whether a partial spool retains its identity through an anneal between runs** is open (`Q78`), and the remaining-weight estimate depends on the footage-to-weight conversion factor per alloy and cross-section, which is not established (`Q10`).

---

# 8. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | **Mid-run checkout requires supervisor approval.** The operator submits; the supervisor approves, holds or rejects, through a notification-driven remote approval | May 4, 2026 |
| D2 | **Partial material is held pending supervisor review.** No identity is issued until the disposition is made | May 4, 2026 |
| D3 | **Multiple partial identities per rod are supported.** Material remaining inside the mill is scrapped and does not return with the rod | May 4, 2026 |
| D4 | **The application never commands a stop.** It reads the line state and refuses checkout while the line runs | Proposed May 4, 2026 — pending engineering confirmation |
| D5 | **Pre-check-out approval depends on the weld** — operator for unwelded, supervisor and `HOLD` for welded | Jul 30, 2026 |

---

# 9. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **Q12** | High | **Partial rod re-check-in** — is a payoff-side scale available for weighing the remnant, and what is the full carry-forward rule? | Mode B disposition and any later re-check-in |
| **Q13 / OI-35** | High | **The definition of "stopped"** — the exact value and threshold that constitutes a safe-stopped line, and the state vocabulary | The checkout precondition (Section 4) |
| **OI-38** | High | **Where a supervisor PIN is validated** — the existing login service or a separate credential store. It gates every override in this module | Mid-run approval, welded pre-check-out, and the staging overrides |
| **OI-14** | Medium | **Pause resume outcomes** — four (including *check out rod, partial run*) or three (with checkout as a pause reason)? This determines where the door to Mode B sits | The Mode B entry point |
| — | Medium | **Confirmation of RC-4** — that the approval record content (supervisor, timestamp, reason) is what Operations and Quality need | The approval audit trail |

---

# 10. Assumptions

| # | Assumption |
|---|---|
| A1 | The footage counter is the authoritative measure of what was produced, and is read when the line is confirmed stopped. |
| A2 | Supervisors are reachable by notification at the time of a mid-run checkout; where they are not, the remote-approval path applies. |
| A3 | Existing material statuses — `STAGED`, `RECEIVED`, `HOLD`, `SCRAP` — are sufficient, and no new status is introduced. |
| A4 | Material left inside the mill at removal is scrapped and is not credited back to the rod. |

---

# 11. Related Specifications

| Document | Relationship |
|---|---|
| [Rod Pre-Check-in](RodPreCheckin.md) | The staging side of Mode P |
| [Rod Check-in](RocCheckin.md) | Creates the run and pushes the configuration that checkout reverses |
| [Rod Pre-Check-in](RodPreCheckin.md) §7 | The carry-forward gate that fires when a partial rod returns to the staging scan |
| [Weld Event](WeldEvent.md) | Why removing a welded rod is a rejection rather than a return |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.3 | Three checkout modes, distinguished as stated | ☐ | ☐ |
| §2 | Mode A — operator only, reason and return destination captured | ☐ | ☐ |
| §3.2 | Mode B — supervisor approval is mandatory | ☐ | ☐ |
| §3.3 | No material identity until the supervisor dispositions it | ☐ | ☐ |
| §3.4 | The direct control is disabled once footage exceeds zero | ☐ | ☐ |
| §4 | The application is a gatekeeper and never commands a stop | ☐ | ☐ |
| §5 | Mode P — approval determined by the weld | ☐ | ☐ |
| §6 | Proposed requirements RC-1 to RC-6 to be added to the requirement set | ☐ | ☐ |
| §7.1 | The rod status transitions, with no new status values | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| Q12 | Payoff-side scale, and the carry-forward rule | | ☐ |
| Q13 / OI-35 | The machine definition of "stopped" | | ☐ |
| OI-38 | Supervisor PIN validation source | | ☐ |
| OI-14 | Pause resume outcomes — three or four | | ☐ |
| — | Approval record content | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Quality** | | | |
| **Engineering / Controls** | | | |
| 2.2 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
