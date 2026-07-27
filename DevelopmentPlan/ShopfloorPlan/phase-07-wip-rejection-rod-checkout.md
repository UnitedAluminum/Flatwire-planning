# PHASE 7 — Exception Handling: WIP Rejection & Rod Checkout

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 6 — In-Run Production Events](./phase-06-in-run-production-events.md) · **Next:** [Phase 8 — FL2 Spool Check-In & Finishing Run](./phase-08-fl2-spool-checkin-finishing-run.md)

---

*Formal off-ramps for suspect material and for rods removed before natural completion, including supervisor-approved partial runs.*

## Business Overview
- **Objective:** log WIP rejections (suspend/scrap/rework) with supervisor alerting, and check out rods (Mode A pre-run / Mode B mid-run) with correct material disposition and PLC tag clearing.
- **Business purpose:** quality holds and material traceability; prevents ghost inventory; controls partial-run material.
- **User roles:** any operator (WIP reject flag); Supervisor/Ops Manager (mid-run checkout approval — OQ-48 decided).
- **Entry conditions:** active run or inspection failure.
- **Exit conditions:** material status set (`HOLD/SCRAP/STAGED/RECEIVED`); PLC tags cleared; line IDLE; partial spool alpha only after supervisor approval.

## User Journey
- **WIP Rejection (Dashboard 8):** context auto (alpha, stage, footage, time); group→reason dropdowns; details (measured/target/deviation); disposition Suspend(→HOLD)/Scrap(→SCRAP)/Rework(→return stage); observation required for Suspend; Submit → status set, WIP-Held queue, `AlertRaised` to Dashboard 1.
- **Rod Checkout Mode A (footage=0, Dashboard 12):** from DB2 footer or DB3 (footage=0); reason (Wrong rod/Order cancelled/Failed re-inspection/Relocated/Other); disposition Return-to-floor(→STAGED)/Return-to-warehouse(→RECEIVED); Confirm → ack voided, `ClearPayoffTags`, line IDLE.
- **Rod Checkout Mode B (footage>0):** **only** via Pause→"Check out rod"; DB3 button disabled when footage>0; line-state guard (app reads `FL1.LineState`, blocks if Running); reason; rod disposition Hold/Scrap/Defer; **in-process material disposition** Hold/Scrap/Accept-partial → **PENDING DISPOSITION** record, material locked (no alpha), **SignalR to Supervisor**; supervisor Accept(→partial spool alpha, spool queue)/Hold(→alpha Hold, QC release)/Reject(→WIP Rejection→scrap).
- **Partial-rod re-check-in (carry-forward):** scanning a rod with `footage_run_to_date>0` forces carry-forward path (fresh-start blocked); supervisor sign-off; opens a new run at 0 ft; each segment → its own spool alpha with `source_rod_alpha`.
- **Error scenarios:** checkout while line Running → blocked; Accept-partial without supervisor → no alpha.

## UI Implementation (Angular)
- **Screens:** Dashboard 8 (`dashboard_8_wip_rejection.html`), Dashboard 12 (`dashboard_12_rod_checkout.html`), partial re-check-in variant.
- **Components:** `dashboard-8-wip-rejection`, `dashboard-12-rod-checkout` (Mode A/B), `partial-recheckin`.
- **Services/models:** `flat-wire-api` (`wipreject`, `checkout`); `wip-rejection.model`, `rod-checkout.model`.
- **Validation:** observation required on Suspend; Mode B requires both dispositions; reason required.
- **Navigation:** SPC/inspection/pause → DB8; pause → DB12 Mode B; supervisor approval screen (any terminal).

## Backend Implementation (.NET)
- **APIs:** `WipRejectionController POST /wipreject`; `CheckOutController POST /checkout`.
- **Request/Response:** rejection (group/reason/disposition/measured/targets) → status+alertBroadcast; checkout (mode/footage/reason/rodDisposition/materialDisposition/remainingWeight) → newRodStatus/plcTagsCleared/partialSpoolAlpha.
- **Business services:** `WipRejectionService` (status + WIP-Held + alert), `CheckOutService` (ack void, `ClearPayoffTags`, PENDING DISPOSITION, supervisor notify).
- **MediatR handlers:** `SubmitWipRejection`, `CheckOutRod`, supervisor-disposition command.
- **Business rules:** Mode B supervisor approval (OQ-48/OQ-50 decided); line-state gate before tag clear (OQ-49 proposed); partial spool alpha only on Accept.
- **Logging/authz:** operator flags, supervisor disposes; all audited.

## Database Changes
- **Tables (write):** `WipRejection` (nullable `RunId`), `RodCheckout` (Mode A/B, `PartialSpoolAlpha`, dispositions); status transitions on the existing **`coils`** rod row / `Spool.Status` / `CoilOutput.Status`; carry-forward columns added to the existing **`coils`** rod row (`footage_run_to_date`, `remaining_weight_estimate`) + `source_rod_alpha` on `Spool` (**new columns — schema addition this phase**, per PartialRodReCheckin design).
- **Indexes:** `WipRejection(RunId)`, `RodCheckout(RunId)`.
- **Relationships:** polymorphic `WipRejection.MaterialAlpha` (rod or spool, no FK), `RodCheckout.PartialSpoolAlpha` (no FK).

## Real-Time Functionality
- **Publishers:** `AlertRaised` (WIP hold) → Dashboard 1; `RodCheckoutEvent` marker; **SignalR notification to Supervisor role** for pending disposition; `LineStatus` → IDLE on checkout.
- **Subscribers:** Dashboard 1, supervisor terminals, Dashboard 14 markers.

## Integration Flow
```mermaid
sequenceDiagram
  participant OP as Operator
  participant NG as DB12 (Mode B)
  participant API as CheckOutController
  participant SVC as CheckOutService
  participant DB as FlatWireDB
  participant HUB as FlatWireHub
  participant SUP as Supervisor
  OP->>NG: Pause → Check out rod (footage>0)
  NG->>API: POST /checkout (ModeB, Accept-partial)
  API->>SVC: CheckOutRodCommand
  SVC->>DB: close partial run, PENDING DISPOSITION (locked, no alpha), ClearPayoffTags
  SVC->>HUB: notify Supervisor + LineStatus IDLE
  HUB-->>SUP: pending disposition (review trace/footage)
  SUP->>API: Accept → generate partial spool alpha → spool queue
```

## Testing
- **Unit:** disposition→status mapping; Mode A vs B; carry-forward forces re-check-in; line-state gate.
- **API:** both contracts + supervisor approval; authz.
- **UI:** observation-required; Mode B dual disposition; DB3 checkout-disabled when footage>0.
- **Integration/DB:** PENDING DISPOSITION lifecycle; partial spool alpha on Accept only; alert broadcast.
- **Acceptance:** suspect material is held/scrapped with alert; a mid-run rod is checked out and its material dispositioned by supervisor.

## Deliverables
Dashboards 8 + 12 (A/B) + partial re-check-in; `WipRejectionController`/`CheckOutController` + services; supervisor-approval flow; carry-forward schema columns.

**OQ blockers:** OQ-47 (carry-forward design — in progress), OQ-48 (checkout auth — decided: supervisor), OQ-49 (PLC on checkout — in progress), OQ-50 (partial material auth — decided), OQ-8 (WIP reason list — Shannon R.). **Stories:** FW-067, FW-072, FW-071.
