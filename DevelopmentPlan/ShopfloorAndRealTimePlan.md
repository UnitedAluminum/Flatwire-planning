# Flat Wire Mill — Master Implementation Roadmap

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
**Document Type:** Implementation Roadmap (workflow-driven, end-to-end vertical slices)
**Supersedes:** the previous *Shopfloor UI & Real-Time Integration Plan* (layer-oriented sprint plan)
**Status:** Master roadmap — implementation-ready
**Development window:** 17 Aug 2026 → 30 Sep 2026 (~6.5 weeks) · **Phase-1 hard gate 14 Aug 2026** · UAT/sign-off at window close (late Sep) · on-line trial + production post-sign-off (Q4 2026, TBD)
**Effort & capacity:** **3,727 hours** (465.9 dev-days) across 14 phases vs **44 working days** available (32 post-gate) = **352 h per person** → **10.6 FTE sustained**. See [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) — the window **does not close as scoped** and needs a programme decision (G1).
**Note:** the original `Jul 1 2026 trial / Aug 1 2026 production` targets in the source docs predate this development window and are **superseded**.

> **This is the index.** The roadmap is split into one file per phase (plus shared foundations and back matter) under [`ShopfloorPlan/`](./ShopfloorPlan/) for easier reading and maintenance. Start with **[Foundations](./ShopfloorPlan/00-foundations.md)** for cross-cutting context, then walk the phases below.
>
> **Scope note:** **Rod Receiving** and **Order Planning & Line Scheduling** (originally planned as separate phases) have been **removed** — they are not part of the shopfloor implementation; they are handled upstream by the existing **CoilReceiving / Planning / Scheduling** systems. Their outputs (a received `STAGED` rod, a scheduled job) remain **prerequisites** consumed at Phase 4. The remaining shopfloor phases are numbered **contiguously 1–14**.

---

## 0. How to Read This Document

This roadmap replaces the old shopfloor-only, technology-layered plan. It is organised into two parts:

1. **Phase 1 — Core Platform Setup.** The one-time technical foundation across Angular, Backend, and Database. Every later phase assumes this exists. This is the *only* phase organised by technology layer.
2. **Business-workflow phases (2–14).** Each phase is a **complete vertical slice** of one operator/business workflow — UI → API → business layer → database → real-time → dashboard — delivered in the sequence users actually experience the system. No phase is "the Angular phase" or "the database phase"; each ships a working feature end to end. *(Rod receiving and order planning/line scheduling are out of shopfloor scope — handled upstream; see the scope note above.)*

Each workflow phase (2–14) follows the fixed template: **Business Overview · User Journey · UI (Angular) · Backend (.NET) · Database · Real-Time · Integration Flow · Testing · Deliverables**, and closes with its **OQ blockers** and **backlog stories**.

The single source of truth for scope is the `c:\UAL\Flat Wire` planning repository. Nothing here is invented: every table, endpoint, dashboard, status value, and algorithm below is traceable to an artifact in that repo (`Analysis/`, `DevelopmentPlan/`, `DevelopmentPlan/Schema/`, `Mockups/`). Where a decision is still open it is called out as an **OQ-##** blocker rather than assumed.

## Roadmap Navigation

**Shared context (read first):**
- [Foundations — §0.2 Reference Codebase Map · §0.3 Domain Cheat-Sheet · §0.4 Real-Time Architecture](./ShopfloorPlan/00-foundations.md)

**Phase files:**

Owner is a **delivery stream**, not a person — the named-owner roster is filled in [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §1. Effort is in **hours** across six streams (FE Angular · BE .NET · DB SQL · RT real-time/PLC · QA · BA), derived in that document §2–§3 at **1 dev-day = 8 h**.

| # | Phase | Owner (stream) | Hours | Days | Wk | File |
|---|---|---|---|---|---|---|
| 1 | Core Platform Setup | FE · BE+RT · DB | **1,027** (1A 370 · 1B 442 · 1C 215) | 128.4 | W0 | [phase-01-core-platform-setup.md](./ShopfloorPlan/phase-01-core-platform-setup.md) (index) → [1A Angular](./ShopfloorPlan/phase-01a-angular-foundation.md) · [1B Backend](./ShopfloorPlan/phase-01b-backend-foundation.md) · [1C Database](./ShopfloorPlan/phase-01c-database-foundation.md) |
| 2 | Pass Schedule Management (Operations Manager) | FE + BE | 231 | 28.9 | W2–W3 | [phase-02-pass-schedule-management.md](./ShopfloorPlan/phase-02-pass-schedule-management.md) |
| 3 | Line Status Board & Real-Time Backbone | RT + FE | 190 | 23.8 | W2–W3 | [phase-03-line-status-board-realtime-backbone.md](./ShopfloorPlan/phase-03-line-status-board-realtime-backbone.md) |
| 4 | Rod Check-In & PLC Configuration (FL1 / FL3) | FE + BE + RT | 255 *(+24–64 h G2)* | 31.9 | W4 | [phase-04-rod-checkin-plc-config.md](./ShopfloorPlan/phase-04-rod-checkin-plc-config.md) |
| 5 | Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3) | FE | 221 | 27.6 | W4 | [phase-05-active-run-monitoring-gauge-trace.md](./ShopfloorPlan/phase-05-active-run-monitoring-gauge-trace.md) |
| 6 | In-Run Production Events (Weld · Die Change · SPC · Roll Adjust · Pause) | FE + BE | 298 | 37.2 | W5 | [phase-06-in-run-production-events.md](./ShopfloorPlan/phase-06-in-run-production-events.md) |
| 7 | Exception Handling: WIP Rejection & Rod Checkout | FE + BE | 205 | 25.6 | W5 | [phase-07-wip-rejection-rod-checkout.md](./ShopfloorPlan/phase-07-wip-rejection-rod-checkout.md) |
| 8 | FL2 Spool Check-In & Finishing Run (FL2 Standalone) | FE + BE | 118 | 14.8 | W5–W6 | [phase-08-fl2-spool-checkin-finishing-run.md](./ShopfloorPlan/phase-08-fl2-spool-checkin-finishing-run.md) |
| 9 | Output Coil Completion, Labeling & Packing | FE + BE | 222 *(+16–32 h OQ-36)* | 27.8 | W6 | [phase-09-output-coil-completion-labeling-packing.md](./ShopfloorPlan/phase-09-output-coil-completion-labeling-packing.md) |
| 10 | FL3 Hybrid Continuous Operation | BE + FE | 61 | 7.6 | W6 | [phase-10-fl3-hybrid-continuous-operation.md](./ShopfloorPlan/phase-10-fl3-hybrid-continuous-operation.md) |
| 11 | Supervisor Shift Summary, Reporting & Certification | BE + FE | 246 | 30.8 | W6 | [phase-11-shift-summary-reporting-certification.md](./ShopfloorPlan/phase-11-shift-summary-reporting-certification.md) |
| 12 | Yield, Cost Ledger & Scrap | BE | 177 | 22.1 | W7 | [phase-12-yield-cost-ledger-scrap.md](./ShopfloorPlan/phase-12-yield-cost-ledger-scrap.md) |
| 13 | Administration & Reference Data | FE + BE | 209 | 26.1 | W7 | [phase-13-administration-reference-data.md](./ShopfloorPlan/phase-13-administration-reference-data.md) |
| 14 | Integration Testing, PLC Commissioning & Go-Live | QA + BA | 267 | 33.4 | W7 | [phase-14-integration-testing-plc-commissioning-golive.md](./ShopfloorPlan/phase-14-integration-testing-plc-commissioning-golive.md) |
| | **Total** | | **3,727 h** | **465.9** | | 44 working days × 8 h = **352 h/person** → **10.6 FTE sustained** |

> ⚠ **The window does not close as scoped.** 3,727 hours against 32 post-gate working days (44 including the run-up to the Aug-14 gate — **352 h per person**) requires ~10.6 concurrent people, and W7 requires 27.2. The full descope ladder recovers only 12% (448 h), leaving 9.3 FTE. On a hands-on-keyboard reading of the hours (6.5 productive h/day) the requirement rises to **13.0 FTE**. This needs a programme decision — see [Capacity & Effort Model](./CapacityAndEffortModel.md) §7 (staff up / move the date / cut scope) and gaps register **G1**.

**Cross-phase planning material:**
- [Back Matter — Feature Dependency Mapping · Overall Roadmap (window/milestones/risks) · Known Gaps & Issues Register · Appendices A–C · Related Documents](./ShopfloorPlan/back-matter.md)

### 0.1 Source artifacts this roadmap consolidates

| Artifact | What it feeds |
|---|---|
| `Analysis/FlatWireEndToEndProcess.md` | The 11-stage material journey → phase ordering |
| `Analysis/FlatWireShopfloorDashboards.md` | Authoritative screen specs for Dashboards 1–14 |
| `LatestDocument/RequirementDocuments/RocCheckin.md`, `RodCheckout.md`, `PartialRodReCheckin.md`, `Spool.md` | Check-in/checkout/spool operator flows |
| `LatestDocument/RequirementDocuments/PassScheduleManagement.md`, `DieChangeAndManagement.md`, `SPCCheckpoint.md`, `WeldEvent.md`, `OperationsManager.md`, `HMIAndSCADALayout.md` | Process workflows, role matrix, HMI/SCADA (DB13/14) |
| `DevelopmentPlan/APIContracts.md` | `FlatWire.API` REST surface + `FlatWireHub` contract |
| `DevelopmentPlan/Schema/*` + `Schema/SQL/*` | The Flat Wire schema — **21 tables** in the new **`FlatWireDB`** (the designed `Rod` table is dropped; rod uses the existing `coils` table). DDL 01–06 + seed |
| `DevelopmentPlan/CapacityAndEffortModel.md` | Per-phase owners + dev-day effort, working-day capacity model, descope ladder (resolves G1) |
| `DevelopmentPlan/FlatWireJiraStories.md` | 12 epics / 58 stories (FW-###) mapped into phases below. **Superseded as a schedule** (dead 5-sprint model); its points survive only as the 184-point cross-check in the Capacity & Effort Model |
| `DevelopmentPlan/FlatWireTables.md` | Table-by-table design + existing-table renames |
| `Analysis/FlatWireOpenQuestions.md` | 59 open questions (OQ-##) → per-phase blockers |
| `DevelopmentPlan/CheckinImplementationPlan.md` / `CheckinImplementationPrompt.md` | The stub-first implementation model |
| `DevelopmentPlan/TechStackRecommendation.md` | "Stay within the UAL stack" ADR |

---

## Change Log
| Date | Changed By | Description |
|------|-----------|-------------|
| Jul 30, 2026 | Plan team | **Added the capacity & effort model — resolves G1 / OI-51.** New [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md): six delivery streams + an unfilled named-owner roster, a published unit-rate card, per-phase effort **in hours** for all 17 phase specs (**3,727 h total**), a working-day capacity model, an ordered descope ladder (which recovers only **12%**), and a calibration checkpoint at the Aug-14 gate. Extended this file's nav table with **Owner (stream)**, **Effort** and **Wk** columns; added the model to §0.1 and flagged `FlatWireJiraStories.md` as superseded *as a schedule*. Stamped `**Owner:**` + `**Effort:**` doc-control blocks onto all 17 phase files (closes `REVIEW.md` #53). Re-baselined `back-matter.md`'s week grid to **W0 = to Aug 14** (hard gate) with **Labor Day Mon 7 Sep** deducted and W7 marked as 3 days — post-gate window is **32 working days**, whole window **44** (closes `REVIEW.md` #31); M1 and a new QA0 moved to the Aug-14 gate. **The model finds the window does not close as scoped:** 10.6 FTE sustained, a 10.7-FTE Phase-1 gate, an impossible 27.2-FTE W7, and a descope ladder that recovers only 12% — escalated as G1's residual for a programme decision. Recorded that OI-51's "thirteen workflow phases" and G1's "14 phases" are **both correct** (1 platform + 13 workflow phases 2–14), and that epic **E01 contains no story for the Angular or .NET scaffold**, which is why the window was believed to fit. |
| Jul 26, 2026 | Plan team | **Renumbered phases to a contiguous 1–14.** After the two upstream phases were removed, the remaining phases were renumbered to close the 3–4 gap: old 5→3, 6→4, 7→5, 8→6, 9→7, 10→8, 11→9, 12→10, 13→11, 14→12, 15→13, 16→14 (Phases 1–2 unchanged). Renamed the 12 phase files to match, and updated every reference — H1 headers, Prev/Next navigation, in-body cross-references, the index nav table, the dependency chain, shared-building-blocks table, roadmap grid, risks/gaps register, and Appendices A/B/C phase columns. Dashboard IDs, story IDs (FW-###), OQ/gap IDs, and stand/line labels were left unchanged. |
| Jul 26, 2026 | Plan team | **Removed Phases 3 & 4 (out of shopfloor scope).** Rod Receiving (former Phase 3) and Order Planning & Line Scheduling (former Phase 4) are handled upstream by the existing CoilReceiving / Planning / Scheduling systems and are not part of the shopfloor implementation. Deleted `phase-03-rod-receiving.md` and `phase-04-order-planning-line-scheduling.md`; reframed their references across the plan as upstream prerequisites (dependency chain, parallelisable/cross-impact notes, roadmap grid W2/W3, M2 milestone, risks, Appendix A rod endpoint); moved their 14 backlog stories (FW-020–022 rod receiving; FW-030/031, FW-040–043, FW-050–055 orders/planning/scheduling, minus FW-054 which stays in Phase 15 admin) out of the Appendix C coverage table (now **44/44 shopfloor stories**). Repaired Prev/Next navigation (Phase 2 ↔ Phase 5) and the Phase 6 entry conditions. Phase numbering kept stable (gap at 3–4) so existing "Phase N" references stay valid. |
| Jul 26, 2026 | Plan team | **Split into per-phase files.** Reorganised the single-file master roadmap into this index plus one file per phase under [`ShopfloorPlan/`](./ShopfloorPlan/): [`00-foundations.md`](./ShopfloorPlan/00-foundations.md) (§0.2–0.4 shared context), `phase-01…16-*.md` (one file per phase), and [`back-matter.md`](./ShopfloorPlan/back-matter.md) (dependency mapping, overall roadmap, gaps register, appendices, related documents). Phase content copied verbatim; no scope, decisions, or wording changed. This top-level file is now the navigation index and change log. |
| Jul 26, 2026 | Plan team | **Full rewrite.** Replaced the shopfloor-only, layer-organised sprint plan with a workflow-driven master roadmap: Phase 1 Core Platform Setup (Angular/Backend/Database/real-time), then Phases 2–16 as end-to-end vertical slices ordered by the application/user journey. Grounded in the actual `ual-angular`/`ual-api` reference assets (CoilCheckin, shared library, UAController, OPCConnection), the 22-table Flat Wire schema, the full `FlatWire.API` contract, all 14 dashboards, the May 21 equipment corrections, and the OQ register. |
| Jul 26, 2026 | Plan team | **Applied three confirmed decisions:** (1) the Flat Wire UI is a **separate new Angular library** (`flat-wire-shopfloor`); (2) the tables move to a **new `FlatWireDB`** database (DDL retargeted from `united_db`; FW-001 renames stay in the existing scheduling DB); (3) the real-time layer is **not** a copy of the existing `CoilDataHub`/`OPCManagerHub`/`supervisor-monitor-hub` patterns — it is a fresh **industry-standard, fast, optimized** design (added §0.4: strongly-typed MessagePack hub, WebSockets-first, bounded-channel ingest with batching/decimation, NgZone-out + rAF rendering, backplane-ready scale-out), self-contained in `FlatWire.API`. |
| Jul 26, 2026 | Plan team | **Approved mockups adopted as UI source of truth (`Mockups/`), verified against the actual files:** all dashboards already share one `--color-*` semantic token system (`flat-wire-shopfloor.styles.scss`) — the `--fw-*` prefix in older source docs is **stale** (no mockup or stylesheet uses it; there is **no** token migration). Every dashboard already has an approved `--color-*` mockup; **Dashboard 2** was revised to `dashboard_2_rod_checkin - New.html` — a 6-step tab-wizard (Visual Inspection → Pass Schedule → Pre-run SPC → Die Block → Rolling Mill → Lube & Safety) with tolerance-viz replacing the old progress ring, OK/NG/NA machine inspection, supervisor-override; confirm-bar retained. Updated decision 6, Phase 1A (theme/components), Phase 6 UI; corrected the `--fw-*` narrative; **G18** now tracks the stale-doc correction. |
| Jul 26, 2026 | Plan team | **Frontend reuse policy reversed (confirmed decision).** The Flat Wire UI is now **all-new screens and controls** — no existing Angular feature library (`checkin-precheckin`, `shop-floor-common`, `statistical-process-control`, `wip-rejection`, `slitter-*`, `common-grid`, etc.) is used as a structural/UI/CSS reference. The **only** reuse is the foundational `shared` services (HTTP gateway, login/JWT interceptor, app-config, error handler, correlation-id, logging), consumed so the library plugs into the app shell. Backend reuse plan is unchanged (`CoilCheckin` remains the `FlatWire.API` template; `WipRejection` still extended). Updated §0.2 (Angular note), decision 5, and §1A folder-structure / shared-services rows. Also corrected the working-tree paths to `c:\UAL\ual-angular` / `c:\UAL\ual-api` (dropped the stale `Second-Branch` note). |
| Jul 26, 2026 | Plan team | **Review round applied:** (a) development window reset to **17 Aug → 30 Sep 2026** (~6.5 wks) — roadmap grid, dev/QA/deploy milestones re-dated; original Jul 1 / Aug 1 targets superseded; (b) **rod uses the existing `coils` table** — designed `Rod` table dropped, `FlatWireDB` → **21 tables**, all `Rod.Alpha` refs now cross-DB logical links (schema/relationship/Phase 3/6/9/11 sections updated); (c) **`SlitterInterface`/`slitter-*` removed as references** (UI and real-time); (d) added **Appendix C** (all 58 FW-### → phase, with deferred flags — 58/58 covered); (e) added the **Known Gaps & Issues Register** (G1–G17, prioritised) capturing the plan review. |
