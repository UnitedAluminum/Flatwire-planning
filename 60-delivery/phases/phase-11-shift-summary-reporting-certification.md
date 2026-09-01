# PHASE 11 — Supervisor Shift Summary, Reporting & Certification

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../../00-overview/Roadmap.md).** See [Foundations](../../20-architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 10 — FL3 Hybrid Continuous Operation](./phase-10-fl3-hybrid-continuous-operation.md) · **Next:** [Phase 12 — Yield, Cost Ledger & Scrap](./phase-12-yield-cost-ledger-scrap.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** Full-stack vertical slice (back-office)
**Owner:** **BE + FE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **MVP-1 175 h** (21.9 d) — FE 40 · BE 56 · DB 20 · RT 4 · QA 24 · BA 8 · cont. 23 · **Window:** W6 (Sep 21–25, 5 working days)
**Effort (both scopes, as published Jul 30):** 246 h — FE 64 · BE 76 · DB 28 · RT 4 · QA 34 · BA 8 · cont. 32. The **71 h difference** is DB10: the screen (24 FE), `GET /shiftsummary` + `ShiftSummaryService` (20 BE) and `sp_ShiftSummary` (8 DB), with QA and contingency re-derived. Basis: [`CapacityAndEffortModel.md` §3b](../CapacityAndEffortModel.md).
**Scope call:** **Partly deferrable** — reports FW-092/093/094/095 (4 of the 5) are **ladder rung 6** (105 h recovered), leaving only the Gauge Trace report. Latest call: W5. This phase's seven stories cannot co-exist with Phases 8, 9 and 10 in W6 at any credible team size — that is why rung 6 exists.

*Back-office visibility: the per-machine shift board plus the reporting suite and welding-wire certification traceability.*

> **⚠ The DB10 shift-summary work in this phase is MVP-2** (11 Aug 2026) — carved out verbatim to
> [`phase-11-mvp2-shift-summary.md`](./phase-11-mvp2-shift-summary.md):
> the DB10 screen, `GET /shiftsummary`, `ShiftSummaryService`, `sp_ShiftSummary` and story `FW-069`.
> **What stays MVP-1:** the five Flattening Lines reports (`FW-090`–`FW-095`) and the **C of C / welding-wire
> certification traceability** — `FW-095` Cut Traceability is *"needed before first shipment"*, which is why this
> phase could not be deferred whole. **The 246 h figure above was not apportioned** and now overstates MVP-1.

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
- **Screens:** the `reports` library. *(Dashboard 10 is **MVP-2** — see [`phase-11-mvp2-shift-summary.md`](./phase-11-mvp2-shift-summary.md).)*
- **Components:** report views. *(`dashboard-10-shift-summary` and its machine tabs are MVP-2.)*
- **Services:** reports service. *(`flat-wire-api` `shiftsummary` is MVP-2.)*

## Backend Implementation (.NET)
- **APIs:** Reports via the existing `Reports` service extended with a Flattening Lines tab. *(`ShiftSummaryController GET /shiftsummary` is **MVP-2**.)*
- **Business services:** report queries. *(`ShiftSummaryService` is MVP-2.)*
- **Repository:** Dapper aggregations for the reports. *(`sp_ShiftSummary` is **MVP-2** — it lives in `../../30-database/sql/FlatWire_DDL_09_Programmability_MVP2.sql`, not in this scope's `08`.)*
- **Authz:** Supervisor+.

## Database Changes
- **Reads:** `SpcCheckpoint`/`SpcMeasurement`, `RunPauseEvent`, `WeldEvent`, `CoilOutput`, `CoilTraceability`, `FlatWireRun`, `WipRejection`.
- **Stored procs/views:** shift aggregation + gauge-trace report views/procs.
- **Indexes:** shift-window filters on timestamp + line.

## Real-Time Functionality
Dashboard 10 is primarily query-based (on-demand/end-of-shift); optionally live-refreshes counts via `LineStatus`/completion events. Gauge Trace report reuses the hub for live FL1/FL3 view.

## Integration Flow
`Quality → Reports (Flattening Lines) → Cut Traceability query (Coil→…→Heat)`. *(The `Supervisor → DB10 → GET /shiftsummary → ShiftSummaryService` flow is **MVP-2**.)*

## Testing
- **Unit:** utilisation formula; per-machine tab data; CPK filter.
- **API:** shift summary contract; report filters.
- **Integration:** a completed run appears in shift totals + traceability report.
- **Acceptance:** supervisor reviews a shift per machine; quality traces a coil to heat for a welding-wire cert.

## Deliverables
Dashboard 10 (per-machine); `ShiftSummaryController` + service; Flattening Lines reports (Gauge Trace/CPK/SPC/Coil Pass Detail/Cut Traceability).

**OQ blockers:** OQ-5/25 (cert granularity/frequency), OI-57 (tolerance bands), OI-84 (WIP report columns). **Stories:** FW-069, FW-090–FW-095.
