# PHASE 11 (MVP-2 part) — Supervisor Shift Summary (DB10)

> **⚠ MVP-2 — deferred scope.** This is a **partial phase file**: only the DB10 content was carved out of the MVP-1 phase, **verbatim at bullet level**. The rest of that phase — the reporting suite and the welding-wire certification — is MVP-1 and stays there. Read this alongside [`phase-11-shift-summary-reporting-certification.md`](./phase-11-shift-summary-reporting-certification.md), which remains the authority on the phase as a whole.
>
> **Effort: 71 h** (11 Aug 2026). Derived by re-pricing this file's deliverables from the rate card in [`CapacityAndEffortModel.md` §2](../CapacityAndEffortModel.md) rather than by dividing the published total — the descope ladder cannot supply a split, since its **rung 6 defers four of the five reports, which are MVP-1**, and says nothing about DB10. The carve: **DB10 screen 24 FE** (the MVP-1 phase's FE 64 is DB10 24 + five reports at 8 FE each = 40, which checks exactly), **`GET /shiftsummary` 4 BE + `ShiftSummaryService` 16 BE**, **`sp_ShiftSummary` 8 DB**; QA and contingency **re-derived** from the reduced base, not scaled. **MVP-1 keeps 175 h** — the reporting suite and the welding-wire certification. Full working in **§3b**.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**
**Carved from:** [`phase-11-shift-summary-reporting-certification.md`](./phase-11-shift-summary-reporting-certification.md) on 11 Aug 2026, bullets copied verbatim

*The **DB10 Supervisor Shift Summary** screen and the `GET /shiftsummary` endpoint behind it. The reporting suite and the welding-wire certification in this phase are MVP-1.*

## Business Overview

- **Objective (DB10 portion):** deliver the per-machine shift summary.
- **Business purpose:** shift review.
- **User roles:** Supervisor/Shift Manager.
- **Entry conditions:** runs producing data (Phases 4–10).
- **Exit conditions:** shift renders correct data.

## User Journey

1. **Dashboard 10** per-machine tabs (FL1/FL2/FL3/All Lines): throughput (orders/footage/weight/coils/skids), quality (SPC pass rate, WIP rejections + breakdown, suspended), utilisation (`(shift hrs − pause − fault)/shift hrs`) + downtime by category, weld events per line, material status; Export/Print.

## UI Implementation (Angular)

- **Screens:** Dashboard 10 (`dashboard_10_shift_summary.html`) — in [`../../../MVP-2/Mockups/`](../../Mockups/).
- **Components:** `dashboard-10-shift-summary` (machine tabs).
- **Services:** `flat-wire-api` (`shiftsummary`).

## Backend Implementation (.NET)

- **APIs:** `ShiftSummaryController GET /shiftsummary` (shift/date/line).
- **Business services:** `ShiftSummaryService` (aggregates SPC log, pause log, weld log, coils, run timers).
- **Repository:** Dapper aggregations; optional `sp_ShiftSummary`.
- **Authz:** Supervisor+.

## Database Changes

- **Reads:** `SpcCheckpoint`/`SpcMeasurement`, `RunPauseEvent`, `WeldEvent`, `CoilOutput`, `CoilTraceability`, `FlatWireRun`, `WipRejection` — **all MVP-1 tables.** DB10 writes nothing.
- **Stored procs/views:** shift aggregation. `sp_ShiftSummary` is the one programmability object that moved to [`../../30-database/sql/FlatWire_DDL_09_Programmability_MVP2.sql`](../../30-database/sql/FlatWire_DDL_09_Programmability_MVP2.sql).
- **Indexes:** shift-window filters on timestamp + line.

## Real-Time Functionality

Dashboard 10 is primarily query-based (on-demand/end-of-shift); optionally live-refreshes counts via `LineStatus`/completion events.

## Integration Flow

`Supervisor → DB10 → GET /shiftsummary → ShiftSummaryService aggregates logs → per-machine KPIs`

## Testing

- **Unit:** utilisation formula; per-machine tab data.
- **API:** shift summary contract.
- **Acceptance:** supervisor reviews a shift per machine.

## Deliverables

Dashboard 10 (per-machine); `ShiftSummaryController` + service.

**Stories:** FW-069.

---

## ⚠ What stayed in MVP-1, and why it matters

| Part | Scope |
|---|---|
| DB10 screen, `GET /shiftsummary`, `ShiftSummaryService`, `sp_ShiftSummary`, story `FW-069` | **MVP-2** (here) |
| The five Flattening Lines reports — Gauge Trace, Gauge CPK, SPC at Flattening Line, Coil Pass Detail, **Cut Traceability** — stories `FW-090`–`FW-095` | **MVP-1** |
| **C of C / welding-wire certification traceability** | **MVP-1** |

**The certification path is the reason this phase could not simply be deferred whole.** The MVP-1 acceptance criterion is *"quality traces a coil to heat for a welding-wire cert"* — Cut Traceability resolves Coil→Spool→Rod→Lot→Heat and is *"needed before first shipment"* (`FW-095`). That obligation is independent of the shift board.

**`OI-101` is unresolved and blocks this file entirely:** shift boundaries are undefined, which blocks **every figure** on the shift summary. Deferring DB10 defers the symptom, not the question.
