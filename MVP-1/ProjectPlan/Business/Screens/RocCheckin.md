# Flat Wire Processing — Rod and Spool Check-in Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL3 rod check-in · FL2 / FL3 spool check-in
**Version:** 2.4
**Last Updated:** August 15, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 2 — Rod Check-in · Dashboard 5 — Spool Check-in
**Requirement source:** SRS check-in rules (`CHK005`–`CHK010`), `FR-094`/`FR-096` (FL2 acknowledgement and tag push), pass-schedule rules (`PSM005`–`PSM010`)

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

This document specifies what the system does when an operator completes check-in and presses **Acknowledge & Begin Check-in**. That single action is the boundary between "material is at the line" and "the machine is configured and a production run is open" — it acknowledges the pass schedule, writes the traceability records, pushes the configuration to machine control, and starts the run.

## 1.2 Scope

**In scope:** pre-flight validation at both check-in stations; pass-schedule recommendation, confirmation and substitution; the ordering of record writes against the PLC push; the tag set pushed; run creation and the resulting status changes.

**Not in scope:** pre-check-in / payoff staging (separate specification); rod checkout; the content and authoring of pass schedules; SPC checkpoint procedure; weld events.

## 1.3 Why acknowledgement is the gate

**No configuration reaches machine control until the operator has explicitly confirmed the pass schedule.** The operator is not configuring the machine by hand — the system does it — so the acknowledgement is the point at which a human confirms that the configuration about to be applied is the right one for the material in front of them. Everything downstream (the run record, the traces, the certificate) resolves against the schedule confirmed here.

---

# 2. Position in the Process

| Step | Event | Run | Pass schedule | PLC tags | Shared material status |
|---|---|---|---|---|---|
| Before | Pre-check-in (staging) | Not created | Not acknowledged | **Never pushed** | Unchanged |
| **This document** | **Check-in** | **Created** | **Acknowledged** | **Pushed** | **Set to `INFLAT`** |
| After | Active run | Open | In force | In force | `INFLAT` |

**The shared coil status is committed here, not at staging** `[CONFIRMED]`. Pre-check-in does not change it. There is no intermediate status for a rod that has been welded but not yet checked in.

---

# 3. FL1 / FL3 Rod Check-in

## 3.1 Step 1 — Pre-flight validation

The **Acknowledge & Begin Check-in** control is enabled only when every check below passes.

| # | Check | Behaviour on failure |
|---|---|---|
| 1 | Rod serial is valid and exists in the coil master (`CHK006`) | Blocked, with an error |
| 2 | Rod is not already checked in elsewhere (`CHK009`) | Blocked, with an error |
| 3 | Measured **diameter** is within the alloy's min/max limits (`CHK007`) | Blocked, field highlighted |
| 4 | Gross and net weight entered | Missing fields highlighted |
| 5 | Payoff position present (see 3.2) | Missing field highlighted |
| 6 | All **three** visual inspection items pass (`CHK010`) | **Hard block** — routed to WIP Rejection; no bypass |
| 7 | Pre-run SPC diameter recorded | Blocked, field highlighted |
| 8 | A pass schedule has been resolved for the order | Blocked — *"No active pass schedule for this order — contact Operations"* |

**Visual inspection failure is a hard block with no bypass.** The only forward action is WIP Rejection.

> `[CLIENT INPUT REQUIRED]` The **min/max values** applied at check 3 are the same four-attribute set as at pre-check-in — gauge, width, diameter and ovality per alloy. The shape is agreed; the values are owed (Q22). Until they arrive, nothing is seeded and this check cannot be enforced.

## 3.2 Payoff position `[CONFIRMED]`

| How the rod arrived | Payoff selector |
|---|---|
| Through **pre-check-in** (staged) | **Pre-filled and read-only** — the position was captured at staging |
| Scanned **directly** at check-in | Operator selects; an occupied position is unavailable |

This resolves the apparent conflict between `CHK005` — which places the payoff buttons at the pre-check-in station only — and the check-in screen's own selector: the selector exists for the direct-check-in path, and it is inert when staging already answered the question.

## 3.3 Automatic line selection `[CONFIRMED]`

If the rod's order is scheduled on the **other** flattening line, the station **switches to that line automatically** and the check-in continues — no blocking message, no supervisor override, no exception record. The operator is not deviating from anything; only the view was wrong. This is the same behaviour as at pre-check-in.

> `[CLIENT INPUT REQUIRED]` The treatment of a **part-completed wizard** when the station switches mid-transaction must be confirmed (OI-26/G21), as must the case of a rod scheduled on **neither** line (Q25).

## 3.4 Step 2 — Pass schedule confirmation `[CONFIRMED]`

The system resolves a recommended schedule by **attribute lookup** — alloy, rod diameter, target gauge × width, and route mode — and presents it for explicit confirmation:

> *"System recommends **PS-1100-FL1-003** — matched on Alloy 1100, Rod 0.375″, Target 0.110″ × 0.625″. Is this correct?"*  **[ Confirm ]  [ Select a different schedule ]**

| Rule | Behaviour |
|---|---|
| Confirmation is **mandatory** | The acknowledge action stays disabled until the schedule is confirmed |
| Selecting a **different** schedule | Presents active schedules for the alloy/product; a non-recommended choice **requires a free-text reason** and is **flagged for Operations review** |
| Schedule is resolved **at check-in**, not at planning | The order record does not carry a schedule beforehand |
| Tags are pushed **only after** confirmation | Pressing the button is not the gate — the confirmation is |

> `[CLIENT INPUT REQUIRED]` **The no-match path is undefined.** If the attribute lookup returns nothing — the first run of a new product variant — the screen has no specified behaviour. Our recommendation, for confirmation: block check-in, display *"No matching pass schedule found for this order's attributes. Operations must create a schedule before check-in can proceed,"* and route to pass-schedule management. Whether an Operations-Manager-credentialled manual override should also exist is your decision. (Section 8, PSM-1.)

## 3.5 Step 3 — Records written, before any tag is pushed `[CONFIRMED]`

| Record | Content |
|---|---|
| Visual inspection result | Operator, timestamp, pass/fail per item, against the rod |
| Pre-run SPC measurement | Recorded as a **Pre-run** checkpoint |
| Pass schedule identity | **ID, version and effective date copied onto the run record** |
| Acknowledgement event | Operator, timestamp, pass schedule ID |
| Staging record | The pre-check-in record is **consumed** and linked to this check-in |

**Audit records are written before the PLC push.** If the push then fails, an incomplete-push marker exists to recover from; the alternative — pushing first — can leave a configured machine with no record of who authorised it.

**The schedule is copied, not referenced.** If the schedule is edited after the run, the configuration actually in force must still be reconstructable. A live reference cannot do that; a snapshot can.

## 3.6 Step 4 — PLC tag push `[CONFIRMED]`

On the operator’s acknowledgement — and **only** after the schedule has been explicitly confirmed — the system writes the confirmed schedule to machine control. **Audit records are written first, the tags second**, so a failed push leaves a recoverable marker. The push is logged with its timestamp, the schedule ID and the operator who triggered it.

> **The values pushed are specified in [`PLCTagSpecification.md`](../../Architecture/PLCTagSpecification.md) §4.2**, per line, and the ordering and failure behaviour at §4.4–§4.5. This section previously listed the payload itself and **disagreed with the other four sources on two points** — whether *edge type* is pushed, and whether speed is a **target** or a **limit**. Both are now settled in one place: edge type is pushed on FL2/FL3 and is not applicable on FL1 (FL1 has no edger), and the speed question is open as **`PLC-Q06`**.

## 3.7 Step 5 — Run starts `[CONFIRMED]`

- The run timer starts and the production run opens.
- Rod status becomes **`INFLAT`**.
- The line status board shows the line as **running**, with the pass schedule ID displayed.
- **The operator is returned to the rod pre-check-in station** `[PROPOSED — revised August 1, 2026]`.

> **Where the operator goes after check-in — changed August 1, 2026, and needing confirmation.** Check-in previously ended on the **active run monitor**. It now ends on the **rod pre-check-in station**.
>
> The reasoning: check-in is complete the instant *Acknowledge & Begin Check-in* is pressed — the tags are pushed, the run is open and the rod is drawing. What the operator has to do **next** is stage the following rod on the idle payoff position, which is the pre-check-in station. Returning there closes the working cycle — stage, check in, stage the next — on a single path, instead of landing the operator on a monitor and leaving them to navigate back. The active run monitor remains reachable from the application bar and from the line status board.
>
> `[CLIENT INPUT REQUIRED]` This assumes the operator's next action after starting a run is to prepare the next rod rather than to watch the run begin. If FL1 operators expect to see the run monitor at start-up — to confirm the line took the tags and the gauge trace is live — the previous destination is the right one. **Open item OI-109.**

---

# 4. FL2 / FL3 Spool Check-in

The same five steps, with a different material and a different tag set.

## 4.1 Step 1 — Pre-flight validation

| # | Check | Behaviour on failure |
|---|---|---|
| 1 | Spool serial is valid and the spool is ready for FL2 | Blocked, with an error |
| 2 | Gauge and width entered, or confirmed from the FL1 production data | Missing fields highlighted |
| 3 | Weight entered | Missing field highlighted |
| 4 | A pass schedule has been resolved | Blocked — *"No active FL2 pass schedule — contact Operations"* |
| 5 | **Hybrid (FL3) only:** the spool's FL1 schedule route mode is Hybrid and matches the expected FL2 input | Blocked — *"Spool was not produced under a hybrid-mode pass schedule — cannot check in on FL2"* |

## 4.2 Steps 2–5

| Step | Behaviour |
|---|---|
| **Confirmation** | Identical pattern to Section 3.4 — explicit confirmation of schedule identity before any tag is pushed |
| **Records** | Spool check-in record; the FL2 run linked to the source spool **and to its source rod serials**, preserving the traceability chain; schedule ID and version on the run record |
| **Tag push** | FM2 settings — the roll gap and stand state for **S1, S2 and S3**, plus edger activation and edge type at **S2 and S3** |
| **Run start** | FL2 run timer starts; spool status becomes `INFLAT`; the operator moves to the FL2 active run view |

> **Equipment note.** FM2 has **three stands: S1 with an 8″ roller, S2 with a 6″ roller, and S3 with a 6″ roller.** **Edgers are at S2 and S3 only**, and **S3 is the final gauge-control stand and cannot be bypassed**. FL1 has **no edger**. `[CONFIRMED — August 4, 2026]`
>
> | FM2 stand | Roller | Edger | Bypassable |
> |---|---|---|---|
> | **S1** | **8″** | No | Yes |
> | **S2** | **6″** | Yes | Yes |
> | **S3** | **6″** | Yes | **No — final gauge control** |
>
> *This corrects the note previously carried here as `[CONFIRMED — May 21, 2026]`, which read "FM2 has three 6″ stands — S1, S2 and S3". That was understood as a separate 8″ roller feeding three 6″ stands — four components — and the check-in screen listed four rows. **The 8″ roller is S1.** The stand count and the edger placement were right; the roller sizes were not.*

> **Resolved `[CONFIRMED — August 4, 2026]` — the stand that cannot be bypassed is `S3`.** This was previously flagged as needing your confirmation because the requirement set appeared to name two different stands (6″ S3 in the SRS, `FM2_6inS2` in the validation rules and HMI specification). With the three-stand correction the two are **the same physical stand**, so there was never a real disagreement — only a fourth stand that does not exist making one answer look like two. The pass-schedule validation can be locked (**OI-04 closed**).

> `[CLIENT INPUT REQUIRED]` **Hybrid-origin spools at FL2.** If a spool produced by a hybrid FL3 run is later loaded on FL2 for a standalone pass, does the system (a) refuse a standalone FL2 schedule without an explicit re-classification, or (b) treat it as any other spool? Undefined today (Section 8, PSM-2).

---

## 4.3 How spool check-in differs from rod check-in

The two are the same five-step sequence over different material, and the differences are worth stating explicitly because they are the source of most confusion between the two screens.

| Aspect | Rod check-in (FL1 / FL3) | Spool check-in (FL2 / FL3) |
|---|---|---|
| **Incoming material** | Rod — `R#####` | Spool — `SP-#####` |
| **Gauge trace shown** | None. The run has not started | The **historical profile** from the FL1 run that produced the spool |
| **Weld markers** | Not applicable | Shown on the profile at each weld position |
| **Visual inspection** | **Required** — oxidation, surface defects, water stains | **Not required.** The material was inspected at FL1 before it was drawn and flattened |
| **Payoff staging** | Applies — two payoff positions, staged ahead of the run | Does not apply. Spools are not staged at a payoff |
| **Pass schedule** | Read and acknowledge | Read and acknowledge — identical |
| **Source links** | One incoming rod | **Multiple source rods**, inherited through the spool |

**The inspection difference is the substantive one.** A spool arriving at FL2 has already passed through the inspection at rod pre-check-in, and re-inspecting flattened wire on a bobbin would neither find the defects that inspection looks for nor be a meaningful check of anything. The traceability difference follows from it: the spool carries the genealogy of every rod welded into it during the FL1 run, so a spool check-in inherits a chain rather than starting one.

---

# 5. Rules Summary

| ID | Rule |
|---|---|
| **CI-1** | No PLC tag is written before the operator has explicitly confirmed the pass schedule. |
| **CI-2** | All audit and traceability records are written **before** the tag push. |
| **CI-3** | The pass schedule ID, version and effective date are **copied** onto the run record at acknowledgement. |
| **CI-4** | A failed visual inspection is a hard block routed to WIP Rejection; there is no bypass. |
| **CI-5** | Selecting a schedule other than the recommended one requires a reason and is flagged for Operations review. |
| **CI-6** | The shared material status becomes `INFLAT` at check-in, and only at check-in. |
| **CI-7** | A rod arriving from pre-check-in has its payoff position pre-filled and read-only; the staging record is consumed and linked. |
| **CI-8** | Material planned for the other flattening line switches the station automatically and continues. |
| **CI-9** | Dimensional acceptance uses the alloy's min/max limits for gauge, width, diameter and ovality. |
| **CI-10** | Floor operators may **view and acknowledge** a pass schedule; they may never edit one. |

---

# 6. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | Pass-schedule confirmation is a mandatory, explicit step — it is the gate for the tag push, not the button press | Apr 25, 2026 |
| D2 | Audit records are written before the PLC push, so a failed push is recoverable | Apr 25, 2026 |
| D3 | The pass schedule ID and version are stored on the run record at acknowledgement, feeding the coil certificate and any later rejection linkage | May 4, 2026 |
| D4 | The line status board displays the active pass schedule ID for supervisor awareness | May 4, 2026 |
| D5 | Attribute-based lookup (alloy + rod diameter + target gauge × width + route mode) resolves the recommended schedule at check-in; schedules are not assigned at planning time | Apr 28, 2026 |
| D6 | FL3 hybrid runs use a **single unified** pass schedule covering both the drawing and the finishing stages | Apr 28, 2026 |
| D7 | `INFLAT` is set at check-in; pre-check-in does not commit the shared status | Jul 30, 2026 |
| D8 | Material planned for the other line switches the station automatically, at check-in as well as at pre-check-in | Jul 30, 2026 |
| D9 | Dimensional limits are min/max on four attributes, applied at both stations | Jul 30, 2026 |

---

# 7. Assumptions

| # | Assumption |
|---|---|
| A1 | Planning has allocated the material to an order before it reaches the line, and that allocation is readable at check-in. |
| A2 | Machine control accepts the full tag set in one push; there is no partial-configuration mode. |
| A3 | The pre-run SPC measurement is taken by the operator at the machine with a calibrated instrument. |
| A4 | An operator session is authenticated, so operator identity never has to be typed into the check-in form. |
| A5 | Pass schedules are authored and approved before the material arrives at the line. |

---

# 8. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **Q22** | High | Min/max values for gauge, width, diameter and ovality per alloy | Dimensional acceptance (check 3) |
| **PSM-1** | High | **The no-match path** — what happens when no active pass schedule matches the order's attributes | First run of any new product variant |
| **PSM-2** | Medium | **Hybrid-origin spools at FL2** — refuse a standalone schedule, or treat as any other spool | FL2 check-in validation |
| ~~**OI-04**~~ | — | ~~Which FM2 stand is non-bypassable — 6″ S2 or 6″ S3~~ **CLOSED Aug 4 2026 — `S3`.** Both names referred to the same physical stand; see the equipment note in 4.2 | — |
| **OI-26 / G21** | Medium | Behaviour of a part-completed wizard when the station auto-switches; FL1 and FL3 as one station or two | Automatic line selection |
| **Q25** | High | Material whose order is scheduled on neither flattening line | Automatic line selection |
| **OI-05** | Medium | `Bevel edge` is offered in the pass-schedule screens but is not a valid edge type — add it or remove it | Edge configuration pushed to FM2 |
| **OI-109** | Medium | **Where the operator should land after check-in.** Check-in now returns to the **rod pre-check-in station** rather than the active run monitor, on the reasoning that the next task is staging the following rod. If operators expect to see the run monitor at start-up — to confirm the line took the tags and the gauge trace is live — the previous destination is correct. | The end of the check-in flow (3.7) |

---

# 9. Related Specifications

| Document | Relationship |
|---|---|
| [Rod Pre-Check-in](RodPreCheckin.md) | Staging — the step immediately before check-in |
| [Rod Checkout](RodCheckout.md) | Removal after check-in; voids the acknowledgement and clears the tags |
| [Pass Schedule Management](../../../../MVP-2/RequirementDocuments/PassScheduleManagement.md) | Where schedules are authored, approved and overridden |
| [Pass Schedule Generation](../../../../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) | The engine that drafts a schedule from product specifications |
| [SPC Checkpoint](SPCCheckpoint.md) | The pre-run checkpoint recorded during check-in |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §3.1 | The eight pre-flight checks and their failure behaviours | ☐ | ☐ |
| §3.2 | Payoff pre-filled and read-only for staged rod; selectable on direct check-in | ☐ | ☐ |
| §3.3 | Automatic line selection at check-in | ☐ | ☐ |
| §3.4 | Mandatory pass-schedule confirmation; substitution requires a reason and is flagged | ☐ | ☐ |
| §3.5 | Records written before the tag push; schedule copied onto the run record | ☐ | ☐ |
| §3.7 | `INFLAT` applied at check-in | ☐ | ☐ |
| §3.7 | **Check-in returns the operator to the rod pre-check-in station**, not the active run monitor (OI-109) | ☐ | ☐ |
| §4 | FL2 flow, including the hybrid-mode validation | ☐ | ☐ |
| §5 | Rules CI-1 to CI-10 | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| Q22 | Min/max dimensional values by alloy | | ☐ |
| PSM-1 | No-match behaviour at check-in | | ☐ |
| PSM-2 | Hybrid-origin spool handling at FL2 | | ☐ |
| ~~OI-04~~ | ~~Which FM2 stand is non-bypassable~~ — **closed Aug 4 2026: `S3`** | — | ✔ |
| **New** | **Confirm the FM2 equipment note in 4.2** — three stands, S1 8″, S2 6″, S3 6″, edgers at S2/S3, S3 final | | ☐ |
| OI-05 | Whether `Bevel` is a real edge type | | ☐ |
| OI-26/G21/Q25 | Station scope and line-selection edge cases | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Quality** | | | |
| **IT** | | | |
| 2.3 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
