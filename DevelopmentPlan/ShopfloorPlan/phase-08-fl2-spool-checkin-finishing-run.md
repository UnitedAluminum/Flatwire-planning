# PHASE 8 — FL2 Spool Check-In & Finishing Run (FL2 Standalone)

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 7 — Exception Handling: WIP Rejection & Rod Checkout](./phase-07-wip-rejection-rod-checkout.md) · **Next:** [Phase 9 — Output Coil Completion, Labeling & Packing](./phase-09-output-coil-completion-labeling-packing.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** Full-stack vertical slice
**Owner:** **FE + BE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **118 h** (14.8 d) — FE 48 · BE 18 · DB 12 · RT 8 · QA 17 · cont. 15 · **Window:** W5–W6 (Sep 14–25, 10 working days)
**Scope call:** **Not deferrable.** The **smallest check-in phase** — it reuses the Phase 2 `pass-schedule-table`/`confirm-bar` and the Phase 5 `gauge-trace-chart` in profile mode.

*The FL2 operator journey: check in an FL1-produced spool, review its historical gauge profile, run the 3-stand finishing mill.*

## Business Overview
- **Objective:** check in a spool onto the TPO, display the FL1 historical gauge profile (with weld markers), acknowledge the FL2 pass schedule, push FL2 PLC tags, and run FM2.
- **Business purpose:** the finishing leg that produces the coreless coil; FL2 has no live gauge trace (historical/profile only).
- **User roles:** FL2 operator.
- **Entry conditions:** a spool exists from an FL1 run (Phase 4–6 output) or hybrid path; FL2 pass schedule Active.
- **Exit conditions:** spool `INFLAT`, FL2 run active (FL2 Dashboard 3 variant), ready to complete.

## User Journey
1. Operator opens **Dashboard 5**; scans spool alpha; source rods auto-populate from FL1 run traceability; alloy/temper read-only; enters measured gauge/width/weights.
2. **Historical gauge profile** chart (from the FL1 run) with target/tolerance and weld markers; "✓ all in spec" or "⚠ N out of spec".
3. FL2 pass schedule table (8" Roller, 6"S1, 6"S2, 6"S3; **Edgers at S2 and S3**) read-only; **no visual inspection** (done at FL1).
4. Acknowledge (same confirm gate) → push FL2 PLC tags → spool `INFLAT` → FL2 Dashboard 3 variant (action bar: Pause, WIP Reject, Roll Adjust, Complete — no Weld/Die).
- **Decision points:** hybrid-origin spool validation (OQ-52 residual — must not apply a standalone FL2 schedule to hybrid material).
- **Error scenarios:** spool not ready-for-FL2 → blocked; hybrid mismatch → blocked (pending OQ-52).

## UI Implementation (Angular)
- **Screens:** Dashboard 5 (`dashboard_5_spool_checkin.html`), Dashboard 3 FL2 variant (`dashboard_3_active_run_fl2.html`).
- **Components:** `dashboard-5-spool-checkin`, historical `gauge-trace-chart` in profile mode (`isLive=false`; inline-SVG path per mockup), shared `pass-schedule-table`, `confirm-bar`.
- **Services:** `flat-wire-api` (`checkin/spool`, `run/{runId}/gaugetrace`), `line-context` (FL2).
- **Validation:** measured gauge/width required; acknowledge gate.
- **Navigation:** → Dashboard 3 (FL2 mode).

## Backend Implementation (.NET)
- **APIs:** `CheckInController POST /checkin/spool`; `RunController GET /run/{runId}/gaugetrace` (historical FL1 readings + weld markers).
- **Request/Response:** `CheckInSpoolCommand` (spoolAlpha, measured gauge/width, weights, passScheduleId) → run response; gauge-trace DTO.
- **Business services:** `CheckInService` (spool path, FL2 tags), `RunQueryService` (historical trace).
- **Business rules:** FL2 tags = 8"/6"S1/6"S2/6"S3 + edgers (no DB/FM1); no visual inspection; hybrid-origin validation (OQ-52).
- **Authz:** Operator+.

## Database Changes
- **Tables (write):** `SpoolCheckin` (LineId restricted FL2/FL3), `FlatWireRun` (FL2 run header), `Spool.Status=INFLAT`.
- **Reads:** source FL1 run gauge trace + `WeldEvent` markers; `Spool.SourceRunId`/`ParentRodAlpha` for traceability.
- **Relationships:** `Spool → FlatWireRun(SourceRunId)`, `Spool → Rod(ParentRodAlpha)`.

## Real-Time Functionality
- FL2 standalone broadcasts **`null`** for live gauge/width (historical only); still emits `SpeedFPM`, `PayoffWeight`, `LineStatus`, `FootageCounter`, `ComponentStatus`. Dashboard 3 FL2 variant renders the historical profile, not a live streaming trace.

## Integration Flow
`FL2 op → DB5 (scan spool, review FL1 profile, Acknowledge) → POST /checkin/spool → FL2 PLC push → Spool INFLAT → FL2 Dashboard 3 → run finishing mill`.

## Testing
- **Unit:** FL2 tag set; no-inspection path; hybrid validation guard.
- **API:** spool check-in + gauge-trace contracts.
- **UI:** historical profile with weld markers; FL2 action bar (no Weld/Die).
- **Integration:** FL1 run → spool → FL2 check-in shows correct profile.
- **Acceptance:** FL2 operator checks in a spool with its FL1 history and starts the finishing run.

## Deliverables
Dashboard 5 + Dashboard 3 FL2 variant; `POST /checkin/spool`; historical gauge-trace query; FL2 PLC tag push.

**OQ blockers:** OQ-15 (spool identifier — needs confirmation), OQ-52 (hybrid-origin FL2 validation — residual), OQ-57 (spool state machine — in progress). **Stories:** FW-064, FW-070 (FL2 roll adjust reused from Phase 6).

---

## Client answers of 30 Jul 2026 — spool completion

**The completion basis changed.** Completion is graded against the **customer's min/max weight range from the order** (e.g. 900 lb max / 800 lb min), **by weight** — not by footage, and **not** against the previously assumed **2,000 lb default, which is withdrawn** (it had no basis and exceeds the TKUP-2 ceiling of 1,100 lb). Spools are sized at roughly **1,800 lb** so that **two finished coils** can be cut at FL2. Still open: which order field carries the range (**OQ-60**).

**A short close is a specified transaction, not an absence of one** (**OQ-65**). Closing below target is an **unplanned stop** on the mill **10-90 SOP** pattern with a reason code:

- **Inside** the customer range → continue.
- **Outside** it → **supervisor override + production hold**, or **offer to the customer under concession** before planning a remake. The offer comes first.
- **The spool is run off either way.** FL2 has **no spool stripper**, so it must be emptied and returned to FL1 whatever is decided about the material. A reject-and-remake path must never imply stopping and removing a part-full spool.

**Mid-run coil break:** the stop is **removed and a new stop starts from zero** — weight does **not** resume from the break point. Leftover incoming material is welded to the next coil on FL1; on FL2 it is run to a finished stop and offered, or scrapped.

> **Two cautions.** The **10-90 SOP document is not in this repository** and must be obtained from Operations rather than paraphrased. And the restart-from-zero rule is a **run/stop model** change, not a screen rule — verify it against `FlatWireRun`/`CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage (**OI-25**) before building.
