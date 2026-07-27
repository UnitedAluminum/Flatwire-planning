# PHASE 11 — Supervisor Shift Summary, Reporting & Certification

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 10 — FL3 Hybrid Continuous Operation](./phase-10-fl3-hybrid-continuous-operation.md) · **Next:** [Phase 12 — Yield, Cost Ledger & Scrap](./phase-12-yield-cost-ledger-scrap.md)

---

*Back-office visibility: the per-machine shift board plus the reporting suite and welding-wire certification traceability.*

## Business Overview
- **Objective:** deliver the per-machine shift summary and the High-priority reports (Gauge Trace, CPK, SPC, Coil Pass Detail, Cut Traceability) + C of C traceability.
- **Business purpose:** shift review, quality/process capability, and customer certification.
- **User roles:** Supervisor/Shift Manager; Quality/Process Engineering.
- **Entry conditions:** runs producing data (Phases 4–10).
- **Exit conditions:** shift + reports render correct data; cert traceability available before first shipment.

## User Journey
1. **Dashboard 10** per-machine tabs (FL1/FL2/FL3/All Lines): throughput (orders/footage/weight/coils/skids), quality (SPC pass rate, WIP rejections + breakdown, suspended), utilisation (`(shift hrs − pause − fault)/shift hrs`) + downtime by category, weld events per line, material status; Export/Print.
2. **Reports tab (Flattening Lines)**: Gauge Trace (real-time FL1/FL3, historical FL2, weld markers), Gauge CPK Deviation + CPK (`Strip/Flat Wire/All`), SPC at Flattening Line (all 5 checkpoint types), Coil Pass Detail, Cut Traceability (Coil→Spool→Rod→Lot→Heat).

## UI Implementation (Angular)
- **Screens:** Dashboard 10 (`dashboard_10_shift_summary.html`) + `reports` library.
- **Components:** `dashboard-10-shift-summary` (machine tabs), report views.
- **Services:** `flat-wire-api` (`shiftsummary`), reports service.

## Backend Implementation (.NET)
- **APIs:** `ShiftSummaryController GET /shiftsummary` (shift/date/line); Reports via existing `Reports` service extended with Flattening Lines tab.
- **Business services:** `ShiftSummaryService` (aggregates SPC log, pause log, weld log, coils, run timers); report queries.
- **Repository:** Dapper aggregations; optional `sp_ShiftSummary`.
- **Authz:** Supervisor+.

## Database Changes
- **Reads:** `SpcCheckpoint`/`SpcMeasurement`, `RunPauseEvent`, `WeldEvent`, `CoilOutput`, `CoilTraceability`, `FlatWireRun`, `WipRejection`.
- **Stored procs/views:** shift aggregation + gauge-trace report views/procs.
- **Indexes:** shift-window filters on timestamp + line.

## Real-Time Functionality
Dashboard 10 is primarily query-based (on-demand/end-of-shift); optionally live-refreshes counts via `LineStatus`/completion events. Gauge Trace report reuses the hub for live FL1/FL3 view.

## Integration Flow
`Supervisor → DB10 → GET /shiftsummary → ShiftSummaryService aggregates logs → per-machine KPIs`; `Quality → Reports (Flattening Lines) → Cut Traceability query (Coil→…→Heat)`.

## Testing
- **Unit:** utilisation formula; per-machine tab data; CPK filter.
- **API:** shift summary contract; report filters.
- **Integration:** a completed run appears in shift totals + traceability report.
- **Acceptance:** supervisor reviews a shift per machine; quality traces a coil to heat for a welding-wire cert.

## Deliverables
Dashboard 10 (per-machine); `ShiftSummaryController` + service; Flattening Lines reports (Gauge Trace/CPK/SPC/Coil Pass Detail/Cut Traceability).

**OQ blockers:** OQ-21/25 (cert granularity/frequency), OQ-38 (tolerance bands), OQ-8 (WIP report columns). **Stories:** FW-069, FW-090–FW-095.
