---
# Rod Checkout — Use Case Analysis

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 1, 2026
**Document Type:** Use Case Analysis
**Status:** Partially Decided — See Open Questions section for per-question status. **Mode P (pre-check-out) added Aug 1, 2026** from the 30 Jul client call, together with a persistence gap this document's own May 4 decisions never got (**G24**)

---

## Background

The existing rod lifecycle has no formal checkout step. A checked-in rod (`INFLAT` status) currently leaves that state only via **Run Complete**, **WIP Rejection/Scrap**, or a **Weld Event**. The customer requirement is to allow a rod to be **deliberately removed from a payoff position** without those outcomes — for example, when the wrong rod was scanned, an order is rescheduled, or the rod must be relocated.

This analysis defines two distinct scenarios and recommends implementing them as **Dashboard 12 — Rod Checkout** (see [FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md)).

---

## Scenario A — Pre-Run Checkout (Run Never Started)

Rod was checked in (payoff position assigned, pass schedule acknowledged) but the line has not yet started.

### Triggers

| Trigger | Notes |
|---------|-------|
| Wrong rod scanned during check-in | Operator error on rod alpha |
| Order cancelled or rescheduled before run | Planning change |
| Rod fails physical re-inspection after check-in | Late discovery of surface defect |
| Rod relocated to a different line | FL1 ↔ FL3 reassignment |

### Flow

```
Dashboard 2 (Rod Check-in — pre-acknowledged)
  OR
Dashboard 3 (Active Run Monitor — footage = 0)
    ↓ [Button: "Check Out Rod"]
    ↓ Checkout dialog opens
        ├─ Rod Alpha           (read-only — current rod)
        ├─ Payoff Position     (read-only — 1 or 2)
        ├─ Checkout Reason     (required — dropdown, see reason codes below)
        ├─ Notes               (optional; required when reason = Other)
        └─ [Cancel]  [Confirm Checkout]
    ↓
    System Actions:
        ├─ Rod status:               INFLAT → STAGED or RECEIVED (operator choice)
        ├─ Payoff position:          cleared
        ├─ Pass schedule ack:        voided
        ├─ PLC tags:                 cleared for that payoff position
        ├─ Checkout event logged:    timestamp, operator, reason, new status
        └─ Dashboard returns to "Ready for Check-In" state
```

### Pre-Run Checkout Reason Codes

| Reason | Use When |
|--------|----------|
| Wrong rod / mis-scan | Operator scanned or entered the wrong alpha |
| Order cancelled / deferred | Planning cancelled or rescheduled the job |
| Failed re-inspection | Defect found after check-in was acknowledged |
| Relocated to different line | Rod reassigned to FL3 or another FL1 position |
| Other | Free-text required |

### Status After Checkout

| Operator Selection | Resulting Rod Status | Meaning |
|-------------------|---------------------|---------|
| Return to floor storage | `STAGED` | Rod stays in production area, ready for re-check-in |
| Return to warehouse | `RECEIVED` | Rod returned to incoming storage |

---

## Scenario B — Mid-Run Checkout (Run Started, Rod Removed Early)

Rod is actively running (`INFLAT`, footage > 0) but must be removed before natural exhaustion.

### Triggers

| Trigger | Notes |
|---------|-------|
| Equipment failure requiring rod removal | PLC fault that cannot be cleared with rod loaded |
| Quality hold decision | Supervisor decides to pull rod mid-run |
| Order quantity reached early | Less footage needed than the rod can supply |
| Shift deferral | Run not completable within current shift; rod must be off-loaded |

### Flow

**Decided (May 4, 2026):** Mid-run checkout requires supervisor approval. Operator cannot unilaterally accept partial spool footage. The flow below reflects the confirmed notification-driven remote approval model.

```
Dashboard 3 (Active Run Monitor — footage > 0)
    ↓ [Pause Run — existing flow]
    ↓ From Pause Resume dialog: "Check Out Rod (Partial Run)" option
        ├─ Rod Alpha                   (read-only)
        ├─ Footage at Removal          (required — auto-captured from PLC counter; read-only)
        ├─ Remaining Weight Estimate   (optional — operator estimate)
        ├─ Checkout Reason             (required — dropdown, see reason codes below)
        ├─ Disposition of Rod          (required — radio)
        │      • Hold — return to storage (partial rod, re-usable)
        │      • Scrap — rod not re-usable
        │      • Defer — continue later on same line
        ├─ Notes                       (optional)
        └─ [Cancel]  [Submit for Supervisor Approval]
    ↓
    System Actions on Submit:
        ├─ Run event closed — partial run record saved with footage counter value
        ├─ Rod status:   INFLAT → HOLD / SCRAP / STAGED (per rod disposition selection)
        ├─ PLC tags:     cleared
        ├─ Checkout event logged with footage, reason, rod disposition
        ├─ PENDING DISPOSITION record created — material locked, not plannable, no alpha yet
        └─ SignalR notification pushed to supervisor role
    ↓
    Supervisor reviews from any connected terminal:
        ├─ Gauge trace for the partial run
        ├─ Footage produced, reason for stop
        ├─ Operator ID and timestamp
        ↓
        ├─ ACCEPT  → Partial spool alpha generated; enters spool queue
        ├─ HOLD    → Partial spool alpha generated with Hold status; QC must release
        └─ REJECT  → WIP Rejection flow triggered; material goes to scrap
    ↓
    Disposition record written: supervisor ID, decision, reason code, timestamp
    Dashboard returns to "Ready for Check-In" state
```

### Mid-Run Checkout Reason Codes

| Reason | Use When |
|--------|----------|
| Equipment failure | PLC fault or mechanical failure requiring rod removal |
| Quality hold | Supervisor or operator decision to pull rod for quality review |
| Order quantity reached | Required footage met before rod exhausted |
| Shift deferral | Run cannot complete in current shift |
| Other | Free-text required |

---

## UI Placement Summary

| Scenario | Screen | Button / Entry Point |
|----------|--------|----------------------|
| Pre-run (check-in not yet acknowledged) | Dashboard 2 footer | "Check Out Rod" (next to Cancel) |
| Pre-run (check-in acknowledged, run not started) | Dashboard 3 header actions | "Check Out Rod" |
| Mid-run (footage > 0) | Dashboard 3 → Pause dialog | "Check Out Rod (Partial Run)" as a fourth resume option |

**Guard rule:** The "Check Out Rod" button on Dashboard 3 is **disabled once footage > 0**. At that point, only the mid-run path (accessed through the Pause dialog) is available, ensuring footage and material disposition are always captured for partial runs.

---

## Data Model

### New Table: `rod_checkout_events`

| Column | Type | Notes |
|--------|------|-------|
| `checkout_id` | INT PK | |
| `rod_alpha` | VARCHAR | FK → coils table |
| `payoff_position` | INT | 1 or 2 |
| `checkin_id` | INT FK | Links back to originating check-in record |
| `scenario` | ENUM | `PRE_RUN`, `MID_RUN` |
| `checkout_reason` | ENUM/LOOKUP | Reason codes from tables above |
| `footage_at_checkout` | DECIMAL | 0 for pre-run; actual footage for mid-run |
| `remaining_weight_estimate` | DECIMAL | Operator estimate; nullable |
| `rod_disposition` | ENUM | `STAGED`, `RECEIVED`, `HOLD`, `SCRAP`, `DEFER` |
| `material_disposition` | ENUM | `HOLD`, `SCRAP`, `ACCEPT_PARTIAL`; nullable (pre-run only) |
| `partial_spool_alpha` | VARCHAR | Generated if material_disposition = ACCEPT_PARTIAL; nullable |
| `operator_id` | INT FK | |
| `checkout_timestamp` | DATETIME | Auto-stamped; operator cannot modify |
| `notes` | VARCHAR(500) | |

### Coil Status Changes

No new status codes are required if `HOLD`, `RECEIVED`, and `STAGED` already exist:

| Checkout Outcome | Rod Status Transition |
|-----------------|----------------------|
| Return to floor storage | `INFLAT` → `STAGED` |
| Return to warehouse | `INFLAT` → `RECEIVED` |
| Hold for review | `INFLAT` → `HOLD` |
| Scrap | `INFLAT` → `SCRAP` |
| Defer — same line | `INFLAT` → `STAGED` (re-check-in required) |

---

## PLC Tag Behavior on Checkout

### What a PLC Tag Is

The PLC (Programmable Logic Controller) is the industrial computer that directly controls the flat wire mill — motor speed, tension, drive state, line running/stopped. It communicates with the MES software through **tags**, which are named memory addresses that hold real-time values. For example:

```
FL1.ActiveRodAlpha     = "ROD-00412"
FL1.LineState          = "Running"
FL1.FootageCounter     = 312
FL1.CheckedIn          = TRUE
```

When an operator checks a rod in, the system **writes** these tags — the machine knows which rod is loaded and that a run is active. When the run ends, the system **clears** the tags — the PLC knows the machine is idle. Rod checkout = clearing those tags.

### Design Rule — Application Checks Line State Before Allowing Checkout

The application must read the current line state from the PLC **before** the checkout dialog opens or Confirm is accepted. If the line is still running, checkout is blocked. The operator must physically stop the line first.

```
Operator clicks "Check Out Rod"
        ↓
Application reads FL1.LineState from PLC
        ↓
    ┌── LineState = "Running" ──────────────────────────────────┐
    │   Block checkout                                          │
    │   Show: "Line is still running.                          │
    │          Stop the line before checking out the rod."     │
    │   Checkout dialog does NOT open.                         │
    └───────────────────────────────────────────────────────────┘
        ↓
    ┌── LineState = "Stopped" ─────────────────────────────────┐
    │   Checkout dialog opens normally                         │
    │   Footage counter value is read and locked at this point │
    │   Operator completes checkout form and clicks Confirm    │
    │   System clears PLC tags and writes checkout record      │
    └───────────────────────────────────────────────────────────┘
```

This means the application is a **gatekeeper**, not a remote stop controller. It does not issue a stop command to the PLC — the operator is always responsible for stopping the machine physically. The application simply enforces that the stop has happened before any tags are touched.

### Why This Is the Right Approach

- **Simpler** — no bidirectional PLC command needed; the application only reads one tag, it never writes a stop request
- **Safer** — the operator remains in physical control of the machine at all times; the software cannot initiate motion changes
- **Works regardless of PLC capability** — does not depend on whether the PLC supports a software-initiated safe-stop handshake
- **Footage accuracy guaranteed** — by the time the dialog opens, the line is confirmed stopped and the footage counter value is final

### Why Clearing Tags While Running Is Dangerous

If the application cleared tags while `FL1.LineState = "Running"`:

- The drive loses its rod identity mid-motion — control logic tied to those tags may behave unpredictably
- The footage counter stops recording while wire is still moving — those last feet are physically real but invisible to the system
- The partial spool alpha records a shorter footage than what is actually on the spool
- Safety interlocks that depend on `CheckedIn = TRUE` to permit motion could trigger an uncontrolled stop rather than a controlled deceleration

Small footage discrepancies compound across multiple partial runs and become a traceability gap at cert time.

### What "Stopped" Means

Jaspreet to confirm with the PLC/SCADA team the exact tag and threshold that constitutes a safe-stopped state — for example, whether `FL1.LineState = "Stopped"` is a discrete tag or whether it requires `FL1.DriveSpeed < threshold` to be true. The checkout guard condition must match the PLC's own definition of stopped.

---

## Open Questions for Customer — Status Update May 4, 2026

| # | Question | Status | Decision |
|---|----------|--------|----------|
| OQ-A | Can a partially-run rod be re-checked-in later? Carry-forward footage and weight, or start fresh? | **In Progress** | Multiple partial spool alphas per rod: confirmed needed. Material remaining in the mill (drawn/rolled) will be scrapped — does not return with the rod. Remaining rod going back to WH may need to be weighed at payoff scale (Tim to confirm with Scott, Bob, Shannon). Full carry-forward design deferred — Tim will confirm. |
| OQ-B | Who can authorise a mid-run checkout — operator only, or supervisor approval required? | **Decided** | Supervisor must approve a mid-run checkout. Operator submits; supervisor reviews and approves/holds/rejects via notification-driven remote approval. |
| OQ-C | What is the required PLC behaviour on checkout — immediate tag clear, or "safe stop" handshake? | **In Progress** | Proposed design (pending engineering confirmation): application never sends stop command; operator stops machine physically; application checks `FL1.LineState` before allowing checkout; tags cleared only after confirmed stop. Tim to confirm with engineering. |
| OQ-D | If footage was produced, does material always get a partial spool alpha, or held pending supervisor review? | **Decided** | Held pending supervisor review. No alpha is generated until supervisor approves the disposition. Supervisor chooses Accept / Hold / Reject. See updated Scenario B flow above. |

---

## Mode P — Pre-check-out (un-staging), added Aug 1, 2026

A **third** checkout mode sits before the two scenarios above: removing a rod that was **pre-checked-in at the payoff but never checked in**. It is modelled as `RodCheckout.Mode = 'ModeP'` with `RunId` NULL, footage 0 and `PlcTagsCleared` false — there is no run to close, no pass-schedule acknowledgement to void and no PLC tag to clear. See [RodPreCheckin.md](RodPreCheckin.md) for the staging side.

**Approval depends on the weld** (client decision, 30 Jul 2026 — **Q68**, which also closes **Q77**):

| Rod state | Approval | Reason captured | Rod status | Why |
|---|---|---|---|---|
| **Not welded** | **None** — operator-only | Pre-check-out reason | Returns to inventory | Nothing was committed; the bundle simply comes off the bay |
| **Welded** | **Supervisor override** | **Required, documented** | **`HOLD`** | The rod is induction-welded to the rod in the mill. Removing it means **cutting or splitting the material**, so this is a **rejection**, not a return |

This is deliberately *not* the OQ-B rule. OQ-B gates on **footage produced**; Mode P has none. It gates on **whether the material has been physically joined**, which is a different risk and arrives earlier.

> **⚠️ Gap G24 — the supervisor approvals decided in this document are not persisted.** `RodCheckout` has **no `ApprovedBy`, `ApprovedAt` or `OverrideReason` columns at all**. That means the **OQ-B** mid-run approval and the **OQ-D** disposition approval — both decided 4 May 2026 and both described above as producing "a disposition record with supervisor ID, decision, reason code, timestamp" — have **nowhere to write that record**, and neither does the new welded Mode P override. `RodStaging` has the credential trio; this table does not.
>
> **Fix:** add `ApprovedBy` / `ApprovedAt` / `OverrideReason` to `RodCheckout`, with a constraint tying them (plus `NewRodStatus = 'HOLD'`) to the welded Mode P case, and requiring them for Mode B. Settle the **PIN validation source** once for every override in the module (**OI-38**).


---

## Related Documents

| Document | Relevance |
|----------|-----------|
| [FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md) | Dashboard 12 — Rod Checkout screen design |
| [FlatWireEndToEndProcess.md](../../Analysis/FlatWireEndToEndProcess.md) | Rod lifecycle state machine |
| [FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) | Q47, Q48, Q49, Q50 — rod checkout questions |
| [PartialRodReCheckin.md](../../Analysis/PartialRodReCheckin.md) | Detailed design for partial re-check-in carry-forward |

---

## Change Log

| Date | Changed By | Description |
|------|-----------|-------------|
| Apr 24, 2026 | Analysis Team | Initial use case analysis — two scenarios (pre-run and mid-run), PLC tag behavior, data model, open questions |
| May 4, 2026 | Analysis Team — Tim O. review | **OQ-B Decided:** supervisor approval required for mid-run checkout. **OQ-D Decided:** supervisor must approve before partial spool alpha is created; notification-driven remote approval model. Scenario B flow updated to reflect supervisor approval gate and pending disposition state. **OQ-A In Progress:** multiple partial spool alphas confirmed needed; weigh-at-payoff scale pending plant input; full carry-forward design deferred. **OQ-C In Progress:** PLC tag behavior pending engineering confirmation. |
| Aug 1, 2026 | Client sync (30 Jul call) | **Mode P (pre-check-out) documented, and a persistence gap found.** Un-staging a rod that was never checked in is **operator-only when the rod is unwelded** and requires a **supervisor override, a documented reason and `HOLD` when it is welded**, because removal means cutting the material — a rejection rather than a return (**Q68**, which also closes **Q77**). Unlike OQ-B this gates on whether the material has been **joined**, not on footage produced. Recorded **G24**: `RodCheckout` has no `ApprovedBy`/`ApprovedAt`/`OverrideReason` columns, so the OQ-B and OQ-D supervisor approvals decided on 4 May 2026 have never had anywhere to write the disposition record this document describes. |
