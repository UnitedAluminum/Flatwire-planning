# PHASE 5 — Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3)

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 4 — Rod Check-In & PLC Configuration](./phase-04-rod-checkin-plc-config.md) · **Next:** [Phase 6 — In-Run Production Events](./phase-06-in-run-production-events.md)
> **Owning specification:** [`ActiveRunMonitor.md`](../../RequirementDocuments/ActiveRunMonitor.md) (DB3) — authoritative on this phase's screen, including the Pause/Resume dialog (§6); the owning doc wins on any disagreement.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-02
**Status:** Ready to build
**Layer:** Full-stack vertical slice
**Owner:** **FE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **~154 h** (19.3 d) — FE 76 · BE 12 · DB 8 · RT 24 · QA 22 · cont. 12 · *(was 221 h; −67 h on 4 Aug 2026 when DB13/DB14 were descoped)* · **Window:** W4 (Sep 8–11, **4** working days — Labor Day Mon Sep 7)
**Scope call:** **Not deferrable.** DB13 and DB14 were ladder rung 7; on **4 Aug 2026 the client descoped both outright**, so the rung is gone rather than spent — their 67 h is now never-planned effort, and everything remaining in this phase is the DB3 run cockpit, which cannot be deferred.

*The continuously-displayed run cockpit — live streaming traces, payoff bars, machine status and the action bar.*

## Business Overview
- **Objective:** real-time monitoring with streaming gauge/width traces, payoff status, machine status, weld markers, and one-click access to every in-run action.
- **Business purpose:** the operator's primary screen during production; drives quality reaction (out-of-spec auto-prompts) and continuity (weld-soon alerts).
- **User roles:** FL1/FL3 operator.
- **Entry conditions:** active run (Phase 4); real-time spine (Phase 3).
- **Exit conditions:** operator can monitor and launch any action; Complete Run → Dashboard 7.

## User Journey
1. Header shows Order/Alpha/Alloy/Target Gauge/Target Width.
2. **Status-card strip** — three cards: *Machine* (run time, speed, footage, spool fill, lube temp), *Payoffs* (P1/P2 with rod alpha and a consumption bar each), *Components* (DB1/DB2 dies, FM1 gap + width, headed by the pass-schedule id).
3. **Spool Information** and **Order Information** grids, both collapsible. *(Rod Information on FL1 — the grid is per-line: rod on FL1/FL3, spool on FL2.)* Order Information carries customer, due date, tolerances, setup width/gauge, finish, OD min–max, weights.
4. **Chart tab strip** with a section collapse toggle; the collapse state persists in `localStorage`. *(The tab state went with the Machine View tab on 4 Aug 2026 — one tab remains.)*
5. **Traces tab:** streaming gauge + width (Chart.js), target dashed line, tolerance band, green/red points, vertical weld markers with rod alpha; after N consecutive out-of-spec readings (configurable, default 5) → auto-prompt SPC toast. Each panel **maximizes to full screen** (backdrop, ESC and backdrop-click restore).
6. ~~**Machine View tab (Dashboard 13 compressed).**~~ **Descoped 4 Aug 2026** together with Dashboard 13 itself. The tab strip keeps a single inert *Traces* label so it still titles the section and hosts the collapse toggle — the shape FL2 always had.
7. **Action bar, grouped by intent** (`dashboard_3_active_run.html`, the approved FL1 layout):
   - **Run events** — SPC Checkpoint · WIP Reject.
   - **Go to** — Die Change · Check Out Rod *(disabled once footage > 0; mid-run checkout is reached through Pause)*. *(View Trends/DB14 removed 4 Aug 2026.)*
   - **Run control** — Pause run · **Complete Run** (confirmation-gated).
   - **No Log Weld** — Dashboard 4 was retired 1 Aug 2026 and the weld is captured at pre-check-in (DB2A). *This line listed it until 2 Aug 2026.*
   - **FL1 has no Roll Adjust** (FR-107 — one mill); **FL3 adds it** (FR-108). See phase 6: it is a dialog, not a screen.
- **Decision points:** which action; complete run (confirm dialog: footage total, outgoing alpha, SPC complete).
- **Error scenarios:** SignalR drop → banner + cached state; FL2 mode has no live gauge/width — the hub sends `null` and the Live view must show an explicit empty state rather than a flat line at target (Phase 8).

## UI Implementation (Angular)
- **Screens:** Dashboard 3 only — **`dashboard_3_active_run.html`** (the FL1 layout since 1 Aug 2026, when the earlier left-rail layout that held this filename was withdrawn; named `dashboard_3_active_run_v2.html` until 11 Aug 2026) and FL3 `dashboard_3_active_run_fl3.html`. *(Dashboards 13 and 14 were descoped on 4 Aug 2026 and both mockups are deleted.)*
- **Components:** `dashboard-3-active-run`, shared `gauge-trace-chart` (Chart.js streaming; `isLive` is a **runtime-switchable** input, not mount-time — see below), `run-status-cards`, `info-grid`, `chart-tab-strip`, `action-bar` (line-mode configurable, intent-grouped). *(`dashboard-13-hmi-schematic` and `dashboard-14-scada-trends` removed 4 Aug 2026 with the descope.)*
- **⚠ Component list revised 2 Aug 2026 to match the mockups.** `machine-status-panel` is absorbed, `payoff-weight-bar` stops being a **DB3** layout element, and three are new. **This phase owns the DB3 shell for all three lines**, so build these once here and let phases 8 (FL2) and 10 (FL3) configure them — do not let a line fork its own copy, which is the divergence the 2 Aug mockup pass undid:
  - **`run-status-cards`** *(absorbs `machine-status-panel`)* — the three-card strip on a `1fr 1.35fr 1fr` grid. The outer cards are Machine and Components on every line; **the middle card is line-specific** — *Payoffs* (two rod payoffs with consumption bars) on FL1/FL3, *Material flow* (spool draining in, coil filling out) on FL2. Same shell, different middle card; the FL2 card is not a payoff bar and must not reuse its labels.
  - **`payoff-weight-bar` survives as the Payoffs card's content**, not as a sibling of the status panel. It is still used directly by **Dashboard 1** (phase 3), so it stays in the shared control set from phase 1A — this is a change to DB3's composition, not a deletion.
  - **`info-grid`** *(new — had no owner in any phase)* — the collapsible titled data grid. Two instances per monitor: Rod/Spool Information and Order Information. Content is per-line; the accordion, table chrome and empty state are not.
  - **`chart-tab-strip`** *(new)* — **re-chartered 4 Aug 2026.** Its stated variation point was *"FL1/FL3 mount two tabs, FL2 mounts one"*; with the Machine View descoped **every line now mounts one**, so what survives is **the section collapse toggle and its `localStorage` persistence**, plus a single inert tab label that titles the section. Either keep it as the collapse control or fold it into the DB3 shell — but note the **collapse toggle has no requirement of its own** (`FR-112` covered only the tabs), which is a pre-existing gap now visible.
  - **`gauge-trace-chart` gains two things:** a **maximize** affordance, and a **runtime source toggle** — it must be able to switch between live streaming and a static historical profile *after* mount, not be fixed by an input at mount. Phase 8 needs exactly this for FL2's Live/Profile control; FL3 needs it because a hybrid run has both.
  - **`action-bar` gains intent grouping** (Run events · Go to · Run control) on top of its existing line-mode configurability, so the per-line difference is now *which buttons land in which cluster*, not just which buttons exist.
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
- **Reads added by the Order Information grid (2 Aug 2026).** The monitor now displays customer, due date, gauge/width tolerance, setup width/gauge, finish, OD min–max, coil/spool max weight, total spool weight and order weight. These live in the **shared order/scheduling schema, not FlatWireDB** — a cross-database read on the same unenforced-link basis as the rod-alpha references (`00-foundations.md` decision 3). Serve them from the active-run DTO rather than a second round trip. The coil min–max weight field is **OQ-18** and blocks the FL2 variant in phase 8.
- **Reads added by the Rod/Spool Information grid:** already available from `RodCheckin`/`SpoolCheckin` and the rod master; no new source.
- **Stored procs:** optional `sp_GetGaugeTrace` for paged reads.
- **Indexes:** trace query support on run+footage.

## Real-Time Functionality
- **Events consumed:** `GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, `ComponentStatus`, `FootageCounter`; markers via `WeldJoinEvent/DieChangeEvent/PauseEvent/SPCCheckpoint`.
- **Publishers:** OPC poller + event handlers.
- **Cache sync/retry:** last-window buffer; reconnect re-join. *(The client-side SCADA settings store — interval, SPC N, control limits — went with DB14 on 4 Aug 2026.)*

## Integration Flow
`PLC/OPC → poller → FlatWireHub (FLxData) → flat-wire-signalr.service → gauge-trace-chart / run-status-cards → operator`. Complete Run → `POST /coil/complete` (Phase 9).

## Testing
- **Unit:** in-spec/out-of-spec coloring; auto-prompt after N; payoff color thresholds; FL1 vs FL3 action bar (**FL1 has no Roll Adjust and no Log Weld**).
- **UI — the shared shell across three lines, which is what the 2 Aug rework is for:** the middle status card is *Payoffs* on FL1/FL3 and *Material flow* on FL2; FL2 mounts one chart tab and FL1/FL3 two; `gauge-trace-chart` switches source **after** mount without remounting; both info grids collapse and the chart section collapse survives a reload.
- **API:** active-run + gauge-trace contracts.
- **UI:** streaming render; weld marker placement; Machine-View toggle; reconnect.
- **Integration:** simulated stream drives traces + markers.
- **Acceptance:** operator sees live gauge/width with weld markers and can launch every action.

## Deliverables
Dashboard 3 (FL1/FL3); **the shared DB3 shell — `run-status-cards`, `info-grid`, `chart-tab-strip`, the grouped `action-bar` and `gauge-trace-chart` with maximize + runtime source switching — which phases 8 (FL2) and 10 (FL3) configure rather than reimplement**; `RunController` (active + gaugetrace, now including order fields for the Order Information grid). *(The SCADA multi-trend screen and its settings panel were descoped 4 Aug 2026.)*

**OQ blockers:** **`PLC-Q02`** (confirm every machine tag path with the commissioning engineer — successor to the superseded PLC-Q02), configurable out-of-spec N, **OQ-18** (order field carrying the coil min–max weight range — surfaced by the new Order Information grid). **Stories:** FW-062, FW-081, FW-080. *(The DB13/DB14 scope inside FW-062 is withdrawn; the story keeps its 8 points, since neither screen ever had acceptance criteria in it. `HMIAndSCADALayout.md` is deleted — the machine tags this phase reads are in [`PLCTagSpecification.md`](../../RequirementDocuments/PLCTagSpecification.md).)*

---

## Mockup alignment of 2 Aug 2026 — the DB3 shell

`dashboard_3_active_run_fl2.html` was rebuilt to this phase's FL1 layout (`dashboard_3_active_run.html`) on 2 Aug 2026, and doing so exposed that **this phase's component list predated its own approved mockup.** The FL1 monitor had already grown a status-card strip, two collapsible info grids, a chart tab strip and maximizable traces; the plan still described `payoff-weight-bar` + `machine-status-panel` as siblings and an ungrouped action bar. §UI Implementation and §Deliverables now match the mockup. Points worth carrying forward:

- **The shell is one component set serving three lines.** FL1 and FL2 diverged once — different structure for the same job — and the 2 Aug pass undid it. The per-line differences are now enumerable: the middle status card, the info grid's subject (rod vs spool), the tab count, and which action buttons sit in which cluster.
- **`gauge-trace-chart` must switch source at runtime.** The `isLive` flag as a mount-time input is not sufficient — phase 8's FL2 variant toggles Live/Profile on a live screen, and a hybrid FL3 run has both.
- **`info-grid` had no owner.** It does now.
- **Roll Adjust is not an FL1 button** (FR-107). Log Weld is no longer anyone's button (DB4 retired 1 Aug 2026). Both were still listed in §User Journey until this pass.
