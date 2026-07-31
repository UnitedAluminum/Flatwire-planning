# PHASE 5 — Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3)

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 4 — Rod Check-In & PLC Configuration](./phase-04-rod-checkin-plc-config.md) · **Next:** [Phase 6 — In-Run Production Events](./phase-06-in-run-production-events.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** Full-stack vertical slice
**Owner:** **FE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **221 h** (27.6 d) — FE 116 · BE 12 · DB 8 · RT 24 · QA 32 · cont. 29 · **Window:** W4 (Sep 8–11, **4** working days — Labor Day Mon Sep 7)
**Scope call:** **Partly deferrable** — DB13 HMI schematic + DB14 SCADA trends are **ladder rung 7** (67 h recovered); the DB3 run cockpit is not deferrable. Latest call: W4.

*The continuously-displayed run cockpit — live streaming traces, payoff bars, machine status, action bar, and the Machine-View/SCADA extensions.*

## Business Overview
- **Objective:** real-time monitoring with streaming gauge/width traces, payoff status, machine status, weld markers, and one-click access to every in-run action.
- **Business purpose:** the operator's primary screen during production; drives quality reaction (out-of-spec auto-prompts) and continuity (weld-soon alerts).
- **User roles:** FL1/FL3 operator.
- **Entry conditions:** active run (Phase 4); real-time spine (Phase 3).
- **Exit conditions:** operator can monitor and launch any action; Complete Run → Dashboard 7.

## User Journey
1. Header shows Order/Alpha/Alloy/Target Gauge/Target Width.
2. **Traces tab:** streaming gauge + width (Chart.js), target dashed line, tolerance band, green/red points, vertical weld markers with rod alpha; after N consecutive out-of-spec readings (configurable, default 5) → auto-prompt SPC toast.
3. **Machine View tab (Dashboard 13 compressed):** live SVG schematic with flow animation; tab preference in `localStorage`.
4. Machine status: speed, footage counter, DB1/DB2 status+die, FM1 status+gap; payoff bars (green>50/amber25-50/red<25/flashing<10; WELD SOON/NOW chips).
5. **Action bar** — FL1: Log Weld · Die Change · SPC · Pause · WIP Reject · Complete · Check Out Rod (footage=0). FL3 adds **Roll Adjust**. **View Trends** → Dashboard 14.
- **Decision points:** which action; complete run (confirm dialog: footage total, outgoing alpha, SPC complete).
- **Error scenarios:** SignalR drop → banner + cached state; FL2 mode shows no live trace (Phase 8).

## UI Implementation (Angular)
- **Screens:** Dashboard 3 (`dashboard_3_active_run.html`, FL3 `dashboard_3_active_run_fl3.html`), Dashboard 13 (`dashboard_13_hmi_schematic.html`), Dashboard 14 (`dashboard_14_scada_trends.html`).
- **Components:** `dashboard-3-active-run`, shared `gauge-trace-chart` (Chart.js streaming, `isLive` flag), `payoff-weight-bar`, `machine-status-panel`, `action-bar` (line-mode configurable), `dashboard-13-hmi-schematic`, `dashboard-14-scada-trends`.
- **Services:** `flat-wire-signalr.service` (`gaugeReading$/widthReading$/speedFpm$/payoffWeight$/componentStatus$/footageCounter$`), `run-state.service`.
- **Models:** `active-run.model.ts`, `signalr-events.model.ts`.
- **State/nav:** action buttons open dashboards/dialogs preserving run state; Machine-View tab persistence.
- **Error handling:** reconnect banner; out-of-spec auto-prompt.

## Backend Implementation (.NET)
- **APIs:** `RunController` `GET /run/active?line=` (load/resume), `GET /run/{runId}/gaugetrace` (paged historical for resume/FL2), plus the hub for live ticks.
- **Response models:** active-run DTO (payoffs, weldEvents, components), gauge-trace DTO (readings, weldMarkers, limits).
- **Business services:** `RunQueryService`; OPC poller already broadcasting (Phase 3).
- **Repository:** `RunRepository` (Dapper for trace paging with `from/to/resolution`).
- **Business rules:** out-of-spec detection thresholds surfaced to client (config); weld markers from `WeldEvent`.
- **Logging/authz:** any authenticated role reads.

## Database Changes
- **Tables (read):** `FlatWireRun`, `WeldEvent` (markers), `RollOverride`/`DieChangeEvent` (component current values), gauge readings (buffered/optionally persisted for trace).
- **Stored procs:** optional `sp_GetGaugeTrace` for paged reads.
- **Indexes:** trace query support on run+footage.

## Real-Time Functionality
- **Events consumed:** `GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, `ComponentStatus`, `FootageCounter`; markers via `WeldJoinEvent/DieChangeEvent/PauseEvent/SPCCheckpoint`.
- **Publishers:** OPC poller + event handlers.
- **Cache sync/retry:** last-window buffer; reconnect re-join; SCADA settings (interval, SPC N, control limits) client-side.

## Integration Flow
`PLC/OPC → poller → FlatWireHub (FLxData) → flat-wire-signalr.service → gauge-trace-chart / payoff-bar / machine-status → operator`. Complete Run → `POST /coil/complete` (Phase 9).

## Testing
- **Unit:** in-spec/out-of-spec coloring; auto-prompt after N; payoff color thresholds; FL1 vs FL3 action bar.
- **API:** active-run + gauge-trace contracts.
- **UI:** streaming render; weld marker placement; Machine-View toggle; reconnect.
- **Integration:** simulated stream drives traces + markers.
- **Acceptance:** operator sees live gauge/width with weld markers and can launch every action.

## Deliverables
Dashboard 3 (FL1/FL3) + Dashboard 13 + Dashboard 14; `gauge-trace-chart`; `RunController` (active + gaugetrace); SCADA multi-trend + settings.

**OQ blockers:** OQ-4 (SCADA/tag paths), configurable out-of-spec N. **Stories:** FW-062, FW-081, FW-080; DB13/14 from `HMIAndSCADALayout.md`.
