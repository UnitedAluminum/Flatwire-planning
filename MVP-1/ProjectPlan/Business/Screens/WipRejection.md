# Flat Wire Processing — WIP Rejection Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3, and the pre-check-in station
**Version:** 1.2
**Last Updated:** August 15, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 8 — WIP Rejection. Presented as a **dialog over the screen the operator is already on**, not as a separate screen (see §1.4).
**Requirement source:** SRS WIP rejection and disposition rules; the blocked-bay release decision (Q23); the no-weld disposition question (Q31)

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 8. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register; those prefixed **G** are gaps recorded against the delivery plan.

---

# 1. Introduction

## 1.1 Purpose

WIP rejection is how an operator takes material out of the normal production flow when it fails a quality check, and records why. It produces the audit record that supports a scrap claim, a supplier return, a customer concession, or a rework decision.

## 1.2 Why it exists

Material that is wrong must stop moving, and it must stop moving with a reason attached. Without a rejection record the material either continues and reaches a customer, or it is quietly set aside and reappears later with no history. Both outcomes are worse than the rejection itself.

## 1.3 Scope

**In scope:** the five points from which a rejection is raised, the material and measurement context each carries, the reason vocabulary, the three dispositions and their consequences, the release of a blocked staging bay, and the audit record.

**Not in scope:** QA review of held material and the decision to accept or scrap it; the scrap disposition and sales module; the SPC checkpoint that may precede a rejection; the physical movement of rejected material.

## 1.4 It is a dialog, and that is a requirement `[CONFIRMED — August 1, 2026]`

Rejection is reached from **five different places**, and as a standalone screen it could only ever describe one of them. Its material banner was fixed to a single mid-run example, and the pre-check-in entry path could not be represented at all. As a dialog, the screen that opens it supplies the material context and the dialog follows.

Two consequences follow, and both are requirements rather than implementation detail:

- **The caller supplies the context.** Material identity, stage, footage position, operator, and — where relevant — the failing measurement are passed in. Nothing is hard-coded to one line or one run.
- **Dialogs are never stacked.** Where a rejection follows another dialog, the first closes before this one opens. Two simultaneous dialogs leave the operator unable to complete either.

---

# 2. The Five Entry Paths

| Entry point | Material context | Footage | Notable |
|---|---|---|---|
| **Mid-run, from the active run monitor** | The rod or spool in process | The position at which the operator raised it | The common case |
| **Failed staging inspection, at pre-check-in** | The staged rod | **None — the rod never ran** | This path releases the bay. See §5 |
| **An out-of-specification SPC checkpoint** | The material measured | The checkpoint footage | The **failing measurement is carried in and pre-filled** |
| **The resume confirmation, after a pause** | The rod or spool in process | The footage frozen at the pause | Reached by resolving a pause as a rejection |
| **Directly, from the screen's action menu** | Operator-selected | As applicable | For material found outside a run |

## 2.1 Footage is absent, not zero, on the pre-check-in path

A rod rejected at staging has produced nothing. Recording its footage as zero would place it in the same class as a rod that ran and produced zero — a real and different condition. The record states that there is no footage position, and no run.

## 2.2 A checkpoint failure arrives with its evidence

When an out-of-specification checkpoint routes here, the failing measurement — what was measured, the reading, the target range, and the signed deviation — is carried across and shown. The operator does not re-enter a value they have already recorded, and the rejection and the checkpoint cannot disagree about what was measured.

---

# 3. The Rejection Reason

## 3.1 Groups and reasons `[CONFIRMED]`

| Group | Reasons |
|---|---|
| **Dimensional** | Gauge out of spec · Width out of spec · Edge burr · Camber |
| **Surface quality** | Oxidation · Water stain · Surface defect · Scratch · Pit |
| **Weld quality** | Weld failure · Weld break mid-run |
| **Material** | Chemistry non-conformance · Wrong alloy · Temper incorrect |
| **Process** | Die failure · Roll gap error · Component fault |

## 3.2 The common reasons are offered directly `[PROPOSED]`

The reasons that account for most rejections are reachable in one action, without first selecting a group. The full grouped list remains available. An operator standing at a stopped machine should not navigate a taxonomy to record *gauge out of spec*.

## 3.3 Observation

A free-text note for what the structured fields do not capture. It is stored with the record and is the field a later QA reviewer reads first.

---

# 4. Disposition

## 4.1 The three outcomes `[CONFIRMED]`

| Disposition | Effect |
|---|---|
| **Suspend** | The material goes on **hold**. It moves to the held queue, cannot advance, and a supervisor is notified. QA subsequently accepts with a concession or rejects |
| **Scrap** | The material is set to **scrap** and routed to the scrap disposition module |
| **Rework** | The material is flagged for rework and the operator names the stage it returns to |

## 4.2 Suspend is the default

It is the reversible outcome. Scrap is not, and it should be a decision the operator makes deliberately rather than one they accept by not changing a selection.

## 4.3 Rework requires a return stage

Rework without a named destination is not actionable. The operator selects the stage the material returns to from the stages that are valid for the material's current point in the process.

> `[CLIENT INPUT REQUIRED]` **The valid rework stages per material state are not confirmed.** Re-drawing at a draw bench is plainly valid for rod; whether a partially flattened spool can return to the flattening mill is a process question we cannot answer. Listed as **OI-100**.

## 4.4 Hold is not currently distinguishable from an SPC hold

A rejection hold and a hold placed by an SPC checkpoint would be recorded identically, although the requirement names them as distinct states. Whether QA needs to tell them apart determines whether a separate state is added (OI-23).

---

# 5. Releasing a Blocked Staging Bay `[CONFIRMED — July 30, 2026]`

A staging bay becomes **blocked** when a staged rod fails its visual inspection. Before this decision the blocked state could be entered but not cleared, which left a payoff position permanently unusable.

**Submitting the rejection is what releases the bay.** On the pre-check-in path:

| # | Effect |
|---|---|
| 1 | The rejection record is written, with no run and no footage position |
| 2 | The rod is taken off the bay and placed on **hold** |
| 3 | **The bay is released** and returns to its empty state, available for the next rod |
| 4 | The pre-check-in station is updated so that any operator viewing it sees the bay free |

**Nothing else clears a blocked bay.** Because this is the only exit, the dialog states it on screen — the operator submitting the rejection needs to know they are also freeing the payoff.

> `[CLIENT INPUT REQUIRED]` **The scope of payoff position uniqueness across FL1 and FL3 is unresolved** (gap **G21**). FL3 is FL1 feeding FL2, so whether the two lines share payoff positions or hold them separately changes what "the bay" refers to when a rod is released. This affects this specification only on the pre-check-in path.

---

# 6. The Audit Record

Stamped automatically and not editable by the operator:

| Field | Source |
|---|---|
| Operator | The active session |
| Timestamp | Server-side |
| Material identity | From the calling screen |
| Stage | Where in the process the rejection occurred |
| Footage position | From the calling screen, or explicitly absent |
| Triggering event | The checkpoint, pause or inspection that led here, where there was one |

---

# 7. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | **The WIP rejection releases a blocked staging bay**, and is the only thing that does | Jul 30, 2026 |
| D2 | Rejection is a **dialog** over the calling screen, with context supplied by the caller | Aug 1, 2026 |
| D3 | **Three dispositions** — suspend, scrap, rework — with suspend as the default | Apr 2026 |
| D4 | An out-of-specification checkpoint carries its **failing measurement** into the rejection | Aug 1, 2026 |
| D5 | Rework requires a **named return stage** | Apr 2026 |
| D6 | The pre-check-in path records **no run and no footage**, rather than zero footage | Aug 1, 2026 |

---

# 8. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **Q31** | High | **The no-weld customer disposition set** — the supervisor gate, and whether the concession path reuses the existing coil-break e-mail flow | The wire-break disposition options offered here |
| **G21** | High | **Payoff position uniqueness across FL1 and FL3** | What "the bay" means on the pre-check-in release path (§5) |
| **OI-100** | Medium | **Valid rework stages per material state** | The rework return-stage list |
| **OI-23** | Medium | Must a **rejection hold be distinguishable from an SPC hold**? | The QA release flow |
| **OI-107** | Low | Is a **WIP rejection list screen** required, or is the shift summary's count sufficient? | Whether a review screen is in scope |

---

# 9. Assumptions

| # | Assumption |
|---|---|
| A1 | QA has a route to review held material and lift or reject a hold; that workflow is specified elsewhere. |
| A2 | The scrap disposition module accepts material routed from here; its internal workflow is outside this specification. |
| A3 | A supervisor notification channel exists for the suspend outcome. |
| A4 | Rejecting material does not stop the machine — the line continues under operator control unless the operator also pauses it. |
| A5 | Rejection is available to any operator without a supervisor gate, except where the outstanding no-weld disposition question (Q31) introduces one. |

---

# 10. Related Specifications

| Document | Relationship |
|---|---|
| [Active Run Monitor](ActiveRunMonitor.md) | The mid-run entry path, and the resume outcome that routes here |
| [Rod Pre-Check-in](RodPreCheckin.md) | The failed-inspection entry path and the blocked bay this releases |
| [SPC Checkpoint](SPCCheckpoint.md) | The out-of-specification entry path, which carries its measurement across |
| [Rod Checkout](RodCheckout.md) | The alternative outcome for a rod leaving the line without a quality failure |
| [Output Coil Completion](./OutputCoilCompletion.md) | Where a coil failing final check is dispositioned here instead of completed |
| [Shift Summary](../../../../MVP-2/RequirementDocuments/ShiftSummary.md) | Reports rejection counts and held material |
| [Weld Event](WeldEvent.md) | Weld failure and mid-run weld break as rejection reasons |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.4 | Rejection is a dialog, with context supplied by the calling screen | ☐ | ☐ |
| §2 | The five entry paths | ☐ | ☐ |
| §2.1 | The pre-check-in path records no footage, rather than zero | ☐ | ☐ |
| §2.2 | A failing checkpoint measurement is carried in and pre-filled | ☐ | ☐ |
| §3.1 | The five rejection groups and their reasons | ☐ | ☐ |
| §4.1 | The three dispositions and their effects | ☐ | ☐ |
| §4.2 | Suspend is the default disposition | ☐ | ☐ |
| §4.3 | Rework requires a named return stage | ☐ | ☐ |
| §5 | The rejection releases a blocked staging bay, and is the only exit from that state | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| Q31 | No-weld customer disposition set and supervisor gate | | ☐ |
| G21 | Payoff position uniqueness across FL1 / FL3 | | ☐ |
| OI-100 | Valid rework stages per material state | | ☐ |
| OI-23 | Rejection hold distinguishable from SPC hold | | ☐ |
| OI-107 | Whether a WIP rejection list screen is required | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Quality** | | | |
| **Operations** | | | |
| **Production** | | | |
| 1.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
