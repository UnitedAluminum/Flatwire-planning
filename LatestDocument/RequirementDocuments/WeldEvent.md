# Flat Wire Processing — Weld Event Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL3 (rod-to-rod joins at the payoff)
**Version:** 2.2
**Last Updated:** August 1, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 2A — Rod Pre-Check-In (*Mark as welded*) — see 4.1
**Requirement source:** SRS welding rules (`WLD003`, `WLD005`, `WLD006`, `WLD010`, `WLD011`, `WLD012`), traceability rules (`TRV002`, `TRV004`)

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Apr 2026 | Initial specification — screen purpose, captured data, traceability chain, confirm behaviour, end-to-end flow. |
| 2.0 | Aug 1, 2026 | **Issued for client review.** Weld type corrected to **induction only** (laser withdrawn May 21, 2026). Incorporates the July 30, 2026 decisions on releasing a welded rod, the absence of a welded-not-checked-in status, the no-stacking confirmation, and the mid-run coil-break rule. Restructured as a client deliverable; internal schema and interface detail removed. |
| 2.1 | Aug 1, 2026 | Added Section 4.1 — the weld event is captured from **two screens** (Dashboard 4 and Dashboard 2A's *Mark as welded*), both writing the same record with the same mandatory quality result; there is no lighter path that omits it. Recorded that **a failed weld does not complete the join**: where the incoming rod is pre-checked-in, a Fail leaves it staged and un-welded for a remake, so only a Pass marks the rod welded. Noted that a remade weld leaves more than one record of one physical join — which **widens the existing Q24** (re-welds on the certificate) to cover a weld that fails at capture, not only one that breaks mid-run; footage attribution across the two boundaries remains **Q22**. |
| 2.2 | Aug 1, 2026 | **The separate Weld Event screen is retired.** Dashboard 4 was withdrawn and the *Log Weld Event* action removed from the active-run monitors on all three lines, so §4.1 now describes **one** capture point rather than two: the Rod Pre-Check-In station's *Mark as welded* dialog. Added decisions **D6–D8** (§8), the Pass-only annotation on the §4 effects table, and two new open items — **G27** (the retired screen's rod queue and traceability chain were not rehoused) and **G28** (FL2 has no pre-check-in station and therefore no weld capture path). |

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

The weld event is the record of a **rod changeover made without stopping the line**. When the running bundle nears exhaustion, the operator joins the tail of the running rod to the head of the staged rod. This specification defines what the system captures at that moment, and how that record becomes the genealogy that a welding-wire customer certificate resolves against.

## 1.2 Why it matters commercially

For welding wire, the weld record is not administrative overhead — it is a deliverable. The customer's automated welding equipment is sensitive to what happens at a join, and their certification requires knowing which source rod produced which footage of the coil they received. **A weld that is not recorded is footage that cannot be certified.**

## 1.3 Scope

**In scope:** capture of the weld, the outgoing/incoming rod link, weld quality and its failure reasons, the footage position of the join, and the resulting traceability chain through spool, coil and skid.

**Not in scope:** staging the incoming rod (pre-check-in specification); the physical welding procedure and its equipment; certificate layout and generation; the payoff transition itself, which is driven by material consumption.

## 1.4 Weld method `[CONFIRMED — May 21, 2026]`

**Induction welding is the only method.** Laser welding for flat-to-flat joins was evaluated and **withdrawn as not viable**. There is no weld-type choice presented to the operator; the type is recorded as induction. The laser value survives in the data model only so that any historical record can still be read — it is never selectable.

---

# 2. Trigger and Sequence

## 2.1 When the weld happens

1. The running payoff drops below **3,000 lb** — the system raises a *prepare weld* alert.
2. The next bundle is pre-checked-in on the idle payoff.
3. The operator opens *Mark as welded* at the pre-check-in station. The weld-point footage is read automatically from the machine encoder.
4. The operator identifies the incoming rod and records the weld quality.
5. On confirmation the system links the two rods at that footage and advances the run's active rod.
6. The payoff transition itself occurs later, when the outgoing rod reaches zero remaining `[WLD005]`.

**Recording the weld does not switch payoffs.** The two are deliberately separate: the weld is a physical join that has already happened; the transition is driven solely by material consumption.

## 2.2 Which rod is offered

The weld defaults to whichever rod is actually **staged on the idle payoff** `[PCI008]`. The operator may override by scanning a different rod. This is *physical* weld sequencing — it is unrelated to the planned processing order, which is governed separately at staging.

---

# 3. Information Captured

| Item | Source | Notes |
|---|---|---|
| Outgoing rod serial | Automatic — the running payoff | |
| Incoming rod serial | Operator scan, or keyed | Must resolve to a known rod |
| Weld-point footage | Machine encoder | Not operator-entered |
| Length laid by the outgoing rod | Calculated — weld point less that rod's start | |
| Outgoing and incoming payoff positions | Automatic | The weld *is* the payoff handover; recording it makes the handover reportable |
| Weld method | System | **Induction** — the only live value |
| Quality result | Operator | Pass / Fail |
| Failure reason | Operator — **mandatory when Fail** | From the list below |
| Operator | Session | Not typed |
| Timestamp | **Server**, at submission | Never the screen clock |
| Output coil serial | Derived from the active run | |

## 3.1 Weld failure reasons

- Misalignment at the join
- Weld break on inspection
- Surface burn / scorching
- Weld not fully fused
- Diameter mismatch at the join
- Other — described in the observation

## 3.2 Validation before the record is accepted

| Check | Behaviour on failure |
|---|---|
| Incoming rod serial is present and resolves to a known rod | Blocked, field highlighted inline |
| Quality is selected | Blocked, field highlighted inline |
| A failure reason is chosen when quality is Fail | Blocked, field highlighted inline |
| Alloy, temper and diameter of the incoming rod match the running rod `[WLD006]` | Blocked — a mismatch cannot be welded into a certified coil |

Validation is reported **inline on the offending field**, never as a dialog. The operator is at the machine with the wire in front of them; a modal that hides the form is the wrong instrument.

---

# 4. What Happens on Confirmation

| # | Effect | Pass | Fail |
|---|---|:--:|:--:|
| 1 | The weld record is written — the two rod serials permanently tied to a footage position on the output coil | ✔ | ✔ |
| 2 | The run's active rod advances to the incoming rod | ✔ | — |
| 3 | The *weld pending* condition on the line is cleared | ✔ | — |
| 4 | The incoming rod is **marked as welded** on its payoff position | ✔ | — |
| 5 | The event is flagged for supervisor review and an alert is raised; the run is not silently blocked | — | ✔ |
| 6 | The station states that the last weld failed, with its reason, and the weld action stays available for a remake | — | ✔ |
| 7 | The operator is returned to the pre-check-in station with a brief confirmation of what was recorded | ✔ | ✔ |

**A failed weld still records the event and still links the rods.** Suppressing the record because the weld was poor would lose exactly the genealogy that a quality investigation needs. Disposition is a supervisor decision, not a data-capture decision.

**But a failed weld does not complete the join** *(added Aug 1, 2026)*. Recording the event and *treating the rods as joined* are different things. Where the incoming rod is a **pre-checked-in rod on the idle payoff position**, a Fail leaves that rod **staged and un-welded**: the join did not hold, so the line cannot transition through it, the position keeps reading *not yet welded*, and the operator **remakes the weld**. Only a **Pass** marks the rod welded — which is what the Pass/Fail columns above express.

**A remade weld leaves more than one record of one physical join.** Each attempt is recorded — the failure happened, it is a real quality event, and hiding it would defeat the purpose of the record. Whether a superseded attempt should appear on the customer certificate, and how output footage is attributed across two weld boundaries a few feet apart, is **not yet decided** — see the open items.

## 4.1 Where a weld is recorded

The weld event is captured at **one place**: the **Rod Pre-Check-In station (Dashboard 2A)**, using its *Mark as welded* dialog. That dialog records every field the weld record requires — both rod serials, weld type, footage at the weld, and the **quality result with its reason**.

This is where the weld physically happens: the operator has just positioned and staged the incoming bundle at the payoff, and joins it to the running rod's tail. Recording it at the same station removes the walk to a separate screen.

> **The separate Weld Event screen was retired on 1 Aug 2026** and the weld action was removed from the active-run monitors on all three flattening lines. There is **no other route** to record a weld.

**Two capabilities of the retired screen have not been rehoused** and are listed as open items: a **re-sequenceable queue of the rods awaiting weld**, and the **traceability chain** view showing completed → outgoing → incoming → future rod (`FR-175`).

> `[CLIENT INPUT REQUIRED]` **FL2 has no pre-check-in station**, so with the weld action removed from its run monitor, FL2 has **no way to record a weld**. This is correct if FL2 only ever inherits the weld markers of the spool it receives (as §6 states), and wrong if FL2 joins one spool to the next — the shift summary reports FL2 weld events, which suggests it may. **Confirmation needed.**

---

# 5. Traceability Chain

The weld event is the mechanism that turns a series of separate rod bundles into one continuous, certifiable coil history.

```
Source rods (input)
  R00041: 0 – 4,100 ft ──[WELD]──► R00042: 4,100 – 12,450 ft ──[WELD]──► R00043: 12,450 ft – end
                                                                              │
                                          SP-00031  (spool, FL1 take-up output)
                                          weld markers embedded at 4,100 ft and 12,450 ft
                                                                              │
                                          FW-00421-C01  (coreless coil, FL2 take-up output)
                                                                              │
                                          SK-00201  (skid — two coils paired for shipment)
                                                                              │
                                          Certificate of Conformance — source rod traceability
```

| Link | How it is formed |
|---|---|
| **Rod → rod** | The weld record ties outgoing serial, incoming serial and footage position |
| **Rod → spool** | When the FL1 take-up reaches capacity, the spool record aggregates that run's weld events, storing each rod's footage range and embedding the weld markers on the gauge profile |
| **Spool → coil** | When a coreless coil completes at FL2, it inherits the spool's weld markers and presents the source traceability table |
| **Coil → skid** | Two coils are paired onto a skid, which carries the full genealogy forward to shipment and certification |

### Source traceability as presented at coil completion

| Rod serial | Footage from | Footage to |
|---|---|---|
| R00041 | 0 ft | 4,100 ft |
| R00042 | 4,100 ft | 12,450 ft |
| R00043 | 12,450 ft | 14,200 ft (end of coil) |

> `[CLIENT INPUT REQUIRED]` **Two footage coordinate systems are in use** and the offset between them has never been stated: run events (including welds) are recorded in **cumulative run footage**, while the coil traceability table is **coil-local**. On any run producing more than one coil, the table above is built wrong unless the coil-start offset is defined. This must be resolved before traceability is built (OI-25).

---

# 6. Welding-Wire Customer Requirements

The chain must support all of the following. Three of the five are not yet fully specified.

| Requirement | Status |
|---|---|
| **Full genealogy** — rod heat number → every weld point → finished coil | Supported |
| **Weld point location** — explicit footage position, reportable on or alongside the certificate | Supported |
| **Maximum weld joints per coil** — a validation rule the system must enforce | `[CLIENT INPUT REQUIRED]` — the limit is unknown (Q23) |
| **Re-weld traceability** — if a weld is remade, both events recorded | `[CLIENT INPUT REQUIRED]` — whether both must appear on the certificate (Q24). **Two routes produce this now:** a weld that breaks mid-run, and (since D7) a weld that fails its quality check before anything runs through the join |
| **Certificate frequency** — per coil, per order, or per heat | `[CLIENT INPUT REQUIRED]` (Q25) |

---

# 7. Design Principles

| Principle | Detail |
|---|---|
| **One action, one result** | There is no "are you sure?" step. The form is the confirmation; the back control is the escape. |
| **Server timestamp** | The recorded time is the server's at receipt, never the clock displayed on the screen. |
| **Immutable record** | Once confirmed, a weld event is never edited — only annotated or flagged. Corrections are new records with their own audit trail. A **remade weld is therefore a second record**, not an amendment of the first. |
| **The fail path still completes** | A failed quality check logs the event and links the rods. The run is not silently blocked; a supervisor dispositions it. **It does not, however, complete the join** — the rod stays un-welded and the weld is remade (§4). |
| **Quality is not optional** | A weld cannot be recorded without a quality result, and a Fail cannot be recorded without a reason. Neither answer is pre-selected: the check exists to make the operator look at the join. |
| **Captured where the work happens** | The weld is recorded at the payoff, by the operator who made it, at the moment they made it — not on a separate screen reached afterwards. |
| **The weld is the handover** | Both payoff positions are recorded, so the handover is queryable rather than merely inferable. |

---

# 8. Confirmed Decisions

Recorded from the client call of **July 30, 2026** unless otherwise dated.

| # | Decision | Consequence |
|---|---|---|
| D1 | **Induction only** *(May 21, 2026)* | No weld-type selector; laser is historical-genealogy only |
| D2 | **A welded rod may be released from the payoff — by a supervisor** | Removal means cutting or splitting the material, so it is a **rejection**, not a return: documented reason, rod to `HOLD`. See the pre-check-in specification |
| D3 | **No separate status for "welded but not checked in"** | Welded is an attribute of a staged rod, not a state of its own |
| D4 | **Rods are never stacked** — two rods maximum, one per payoff | **Every weld is a payoff handover.** The rule that a weld must join two *different* positions is correct as written, and no in-stack weld case needs to be built |
| D5 | **Mid-run coil break: the stop is removed and a new stop starts from zero** | Weight does not resume from the break point. The leftover incoming material is **welded to the next coil on FL1**; on FL2 it is run off to a finished stop and offered to the customer, or scrapped |

> **D5 is a run/stop model change, not a screen rule.** The leftover weld on FL1 is an ordinary weld event, but it lands against a **new** stop, so its footage position restarts. This must be reconciled with the two footage coordinate systems (OI-25) before it is implemented.

**Recorded August 1, 2026** — project decisions, not client-call outcomes. These carry a `[PROPOSED]` weight and are listed for confirmation in Part A.

| # | Decision | Consequence |
|---|---|---|
| D6 | **A quality result is mandatory to record a weld** — Pass or Fail, with a reason required on Fail | The previous lightweight path, which recorded *that* a weld happened without stating whether it held, no longer exists. Every weld backing certifiable footage now carries an integrity statement |
| D7 | **A failing weld does not mark the rod welded** | The join did not hold, so the line cannot transition through it. The rod stays staged and un-welded, the failure and its reason are shown at the station, and the operator remakes the weld. **One physical join can therefore carry several records** — see Q24 |
| D8 | **The weld is recorded at one place: the Rod Pre-Check-In station** | The separate Weld Event screen was withdrawn and the weld action removed from all three active-run monitors. Two capabilities of the retired screen were **not** rehoused (G27), and **FL2 — which has no pre-check-in station — is left with no capture path** (G28) |

> **D8 has an unresolved consequence and is the reason G28 is High.** The decision is sound for FL1 and FL3, where the weld physically happens at the payoff the operator is standing at. It is only safe for FL2 if FL2 never makes a weld of its own. §6 says an FL2 coil *inherits* its spool's weld markers, which supports the decision; the shift report shows FL2 weld events, which contradicts it. **One of those two is wrong and we do not know which.**

---

# 9. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **G28** | **High** | **Can FL2 record a weld at all?** The weld action was removed from every active-run monitor on 1 Aug 2026 and the weld now lives only at the pre-check-in station — **which FL2 does not have**. This is correct if FL2 only ever inherits the weld markers of the spool it receives (§6); it is a functional hole if FL2 joins one spool to the next. The shift summary reports FL2 weld events, so the two statements disagree | Any weld on FL2. If FL2 does weld, it currently has no capture path |
| **G27** | Medium | **The rod queue and traceability chain have no host.** The retired Weld Event screen carried a re-sequenceable queue of rods awaiting weld and a chain view of completed → outgoing → incoming → future rod (`FR-175`). Neither moved to the pre-check-in dialog | `FR-175`; the operator's view of weld sequence and genealogy |
| **Q22** | High | **Footage attribution at the weld point** — split at the exact foot, or attribute the coil to the dominant rod? | The values in every source-traceability table |
| **Q23** | High | **Maximum weld joints per finished coil** — the limit the system must enforce | A validation rule at confirmation; run-length planning. Exceeding a customer's limit causes jams in their welding equipment |
| **Q24** | Medium | **Re-welds on the certificate** — if a weld breaks and is re-welded, must both events appear? | Whether a re-weld is a new record or an annotation |
| **Q25** | Medium | **Certificate frequency** — per coil, per order, or per heat | Certificate trigger and report format |
| **OI-25** | High | **The coil-start offset** between run-cumulative and coil-local footage | Correct traceability rows on any multi-coil run |
| — | Medium | **Reversing a weld in place** — a mis-scan, the wrong rod welded, or a weld that failed after being marked, on a rod that stays staged. Releasing a welded rod is specified; correcting the record while the rod remains on the payoff is not | Weld correction, and its audit trail |

---

# 10. Assumptions

| # | Assumption |
|---|---|
| A1 | The machine encoder is the authoritative source of weld-point footage; it is not operator-entered. |
| A2 | The incoming rod has already been pre-checked-in on the idle payoff, so its identity and inspection result exist before the weld. |
| A3 | Alloy, temper and diameter are available for both rods at the moment of the weld, so the match check can be enforced. |
| A4 | Two rods maximum are present at the line, one per payoff position. |

---

# 11. Related Specifications

| Document | Relationship |
|---|---|
| [Rod Pre-Check-in](RodPreCheckin.md) | Stages the incoming rod; the weld is what staging exists to enable |
| [Rod Check-in](RocCheckin.md) | Opens the run the weld is recorded against |
| [Spool Completion](SpoolCompletionNotification.md) | Aggregates weld events into the spool record; carries the coil-break rule |
| [Rod Checkout](RodCheckout.md) | Removal of a rod without a weld or a run completion |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.4 | Induction is the only weld method; no operator choice | ☐ | ☐ |
| §2.1 | Recording the weld does not switch payoffs; the transition is consumption-driven | ☐ | ☐ |
| §3 | The captured data set, including both payoff positions | ☐ | ☐ |
| §3.1 | The six weld failure reasons | ☐ | ☐ |
| §3.2 | **A quality result is mandatory**, with a reason required on Fail (D6) | ☐ | ☐ |
| §3.2 | Alloy / temper / diameter match is enforced before a weld is accepted | ☐ | ☐ |
| §4 | A failed weld still records the event and links the rods | ☐ | ☐ |
| §4 | **A failed weld does not mark the rod welded** — the weld is remade (D7) | ☐ | ☐ |
| §4.1 | **The weld is recorded only at the Rod Pre-Check-In station**; the separate Weld Event screen is withdrawn (D8) | ☐ | ☐ |
| §5 | The rod → spool → coil → skid traceability chain | ☐ | ☐ |
| §7 | Weld events are immutable; corrections are new annotating records | ☐ | ☐ |
| §8 | The five decisions of July 30, 2026 are correctly captured | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| **G28** | **Does FL2 make its own welds?** If it does, it has no way to record one | | ☐ |
| **G27** | Where the rod queue and traceability chain (`FR-175`) should live now | | ☐ |
| Q22 | Footage attribution rule at the weld point | | ☐ |
| Q23 | Maximum weld joints per finished coil | | ☐ |
| Q24 | Re-weld representation on the certificate | | ☐ |
| Q25 | Certificate frequency | | ☐ |
| OI-25 | Coil-start offset between run and coil footage | | ☐ |
| — | Weld reversal in place | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Quality** | | | |
| **IT** | | | |

---

## Change Log

| Date | Change |
|---|---|
| Apr 2026 | Initial specification — screen purpose, captured data, traceability chain, confirm behaviour, end-to-end flow, welding-wire requirements. |
| Aug 1, 2026 | **Reissued as version 2.0 for client review.** Weld type corrected to induction only. Added the alloy/temper/diameter match as a stated validation, both payoff positions as captured data, and the July 30 decisions (welded-rod release, no welded-not-checked-in status, no stacking, mid-run coil break). Raised the coil-start footage offset (OI-25) and the in-place weld reversal as blocking client questions. Interface payloads, screen navigation targets and internal schema references removed. |
| Aug 1, 2026 | **Version 2.2 — the Weld Event screen is retired.** Dashboard 4 was removed, and the *Log Weld Event* action was removed from the active-run monitors on **all three lines**. The weld is now recorded **only** at the Rod Pre-Check-In station (Dashboard 2A, *Mark as welded*), which since version 2.1 captures the complete record including the mandatory quality result — this is also where the weld physically happens, so it removes a walk to a separate screen. **Two capabilities were not rehoused:** the re-sequenceable rod queue and the traceability chain view (`FR-175`). **And FL2, which has no pre-check-in station, now has no way to record a weld at all** — correct if FL2 only inherits its spool's weld markers, wrong if it joins spool to spool; the shift summary reports FL2 weld events, so confirmation is needed. Both raised as open items. |
| Aug 1, 2026 | **Version 2.1 — weld quality is captured with the weld.** Added Section 4.1 recording that the weld event is captured wherever the weld is made, with the **same mandatory quality result** in every case — there is no lighter path that records a weld without stating whether it held. Recorded that **a failed weld does not complete the join**: where the incoming rod is pre-checked-in, a Fail leaves it staged and un-welded, and the operator remakes the weld, so only a Pass marks the rod welded. Noted that a remade weld therefore leaves more than one record of one physical join, which widens **Q24** (re-welds on the certificate) to cover a weld that fails at capture and not only one that breaks mid-run; footage attribution across the two boundaries remains **Q22**. |
