# Flat Wire Mill — Master Implementation Roadmap

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 13, 2026 — §0.1's backlog row re-pointed at the rewritten sprint-wise backlog (**116 stories / 3,292 h**, hours not points); the *"12 epics / 58 stories / 184-point"* description was stale on every figure *(otherwise July 26, 2026)*
**Document Type:** Implementation Roadmap (workflow-driven, end-to-end vertical slices)
**Supersedes:** the previous *Shopfloor UI & Real-Time Integration Plan* (layer-oriented sprint plan)
**Status:** Master roadmap — implementation-ready
**Development window:** 17 Aug 2026 → 30 Sep 2026 (~6.5 weeks) · **Phase-1 hard gate 14 Aug 2026** · UAT/sign-off at window close (late Sep) · on-line trial + production post-sign-off (Q4 2026, TBD)
**Effort & capacity:** **MVP-1 is 3,292 hours** (411.5 dev-days) vs **44 working days** available (32 post-gate) = **352 h per person** → **9.4 FTE sustained**. *(Both scopes combined: 3,660 h / 10.4 FTE — the long-quoted 3,727 was a stale TOTAL row, corrected 11 Aug 2026.)* See [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §3b — the window **still does not close as scoped** and needs a programme decision (G1). **Deferring MVP-2 recovered about one FTE and it landed in W2–W3, which were already the slackest weeks; W4 and W5 did not move and W7 remains 24.5 FTE against three days.**
**Note:** the original `Jul 1 2026 trial / Aug 1 2026 production` targets in the source docs predate this development window and are **superseded**.

> **This is the index.** The roadmap is split into one file per phase (plus shared foundations and back matter) under [`ShopfloorPlan/`](./ShopfloorPlan/) for easier reading and maintenance. Start with **[Foundations](./ShopfloorPlan/00-foundations.md)** for cross-cutting context, then walk the phases below.
>
> **Scope note:** **Rod Receiving** and **Order Planning & Line Scheduling** (originally planned as separate phases) have been **removed** — they are not part of the shopfloor implementation; they are handled upstream by the existing **CoilReceiving / Planning / Scheduling** systems. Their outputs (a received `STAGED` rod, a scheduled job) remain **prerequisites** consumed at Phase 4. The remaining shopfloor phases are numbered **contiguously 1–14**.
>
> **Scope note — five screens are out of MVP-1, and the boundary is now settled (11 Aug 2026).** **DB9** Pass Schedule Management · **DB9A** Pass Schedule List · **DB10** Supervisor Shift Summary · **Die Management** · **OEE Dashboard** are **not part of MVP-1 and will not be part of planning**. Their mockups and owning specifications live in [`../../MVP-2/`](../../MVP-2/), whose [README](../../MVP-2/README.md) is the record.
>
> **DB7 and DB7b returned to MVP-1 the same day** — Phase 9 is **wholly MVP-1**. The tables `CoilOutput` and `CoilTraceability` were already MVP-1 for the welding-wire certificates, but their only writer, `CoilCompletionService`, had gone to MVP-2, leaving the DM010 non-overlap trigger guarding rows nothing inserted. The service does not split.
>
> **The hours are now apportioned** (§3b of the effort model), so the phase table below reads **MVP-1**, not both scopes. **Three of the four consequences the exclusion raised are closed:** pass schedule authoring is **out of MVP-1** — a separate track owns it and check-in only *reads* a schedule (`phase-04`); output-coil recording is **in**; and the die change enforces **`D4` at size level** against `Drawer` rather than a die inventory it will never have (`DieChangeAndManagement.md` §2.4a). **The one still open** is the Operations Manager role definition, which sits in `PassScheduleManagement.md` §3.3–§3.4 while `FR-212` relies on the role for **DB11 Roll Adjust**, an MVP-1 screen.

---

## 0. How to Read This Document

This roadmap replaces the old shopfloor-only, technology-layered plan. It is organised into two parts:

1. **Phase 1 — Core Platform Setup.** The one-time technical foundation across Angular, Backend, and Database. Every later phase assumes this exists. This is the *only* phase organised by technology layer.
2. **Business-workflow phases (2–14).** Each phase is a **complete vertical slice** of one operator/business workflow — UI → API → business layer → database → real-time → dashboard — delivered in the sequence users actually experience the system. No phase is "the Angular phase" or "the database phase"; each ships a working feature end to end. *(Rod receiving and order planning/line scheduling are out of shopfloor scope — handled upstream; see the scope note above.)*

Each workflow phase (2–14) follows the fixed template: **Business Overview · User Journey · UI (Angular) · Backend (.NET) · Database · Real-Time · Integration Flow · Testing · Deliverables**, and closes with its **OQ blockers** and **backlog stories**.

The single source of truth for scope is the `c:\UAL\Flat Wire` planning repository. Nothing here is invented: every table, endpoint, dashboard, status value, and algorithm below is traceable to an artifact in that repo (`Analysis/`, `MVP-1/DevelopmentPlan/`, `MVP-1/DBChanges/Schema/`, `MVP-1/Mockups/`). Where a decision is still open it is called out as an **OQ-##** blocker rather than assumed.

## Roadmap Navigation

**Shared context (read first):**
- [Foundations — §0.2 Reference Codebase Map · §0.3 Domain Cheat-Sheet · §0.4 Real-Time Architecture · §0.5 Stub-First Delivery Contract](./ShopfloorPlan/00-foundations.md)

**Phase files:**

Owner is a **delivery stream**, not a person — the named-owner roster is filled in [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §1. Effort is in **hours** across six streams (FE Angular · BE .NET · DB SQL · RT real-time/PLC · QA · BA), derived in that document §2–§3 at **1 dev-day = 8 h**.

| # | Phase | Owner (stream) | Hours | Days | Wk | File |
|---|---|---|---|---|---|---|
| 1 | Core Platform Setup | FE · BE+RT · DB | **1,027** (1A 370 · 1B 442 · 1C 215) | 128.4 | W0 | [phase-01-core-platform-setup.md](./ShopfloorPlan/phase-01-core-platform-setup.md) (index) → [1A Angular](./ShopfloorPlan/phase-01a-angular-foundation.md) · [1B Backend](./ShopfloorPlan/phase-01b-backend-foundation.md) · [1C Database](./ShopfloorPlan/phase-01c-database-foundation.md) |
| 2 | Pass Schedule Management (Operations Manager) — **wholly MVP-2** | FE + BE | 231 → MVP-2 | 28.9 | W2–W3 | [phase-02-pass-schedule-management.md](../../MVP-2/DevelopmentPlan/ShopfloorPlan/phase-02-pass-schedule-management.md) |
| 3 | Line Status Board & Real-Time Backbone | RT + FE | 190 | 23.8 | W2–W3 | [phase-03-line-status-board-realtime-backbone.md](./ShopfloorPlan/phase-03-line-status-board-realtime-backbone.md) |
| 4 | Rod Check-In & PLC Configuration (FL1 / FL3) | FE + BE + RT | 255 *(+24–64 h G2)* | 31.9 | W4 | [phase-04-rod-checkin-plc-config.md](./ShopfloorPlan/phase-04-rod-checkin-plc-config.md) |
| 5 | Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3) | FE | **154** | 19.3 | W4 | [phase-05-active-run-monitoring-gauge-trace.md](./ShopfloorPlan/phase-05-active-run-monitoring-gauge-trace.md) |
| 6 | In-Run Production Events (Weld · Die Change · SPC · Roll Adjust · Pause) | FE + BE | 298 | 37.2 | W5 | [phase-06-in-run-production-events.md](./ShopfloorPlan/phase-06-in-run-production-events.md) |
| 7 | Exception Handling: WIP Rejection & Rod Checkout | FE + BE | 205 | 25.6 | W5 | [phase-07-wip-rejection-rod-checkout.md](./ShopfloorPlan/phase-07-wip-rejection-rod-checkout.md) |
| 8 | FL2 Spool Check-In & Finishing Run (FL2 Standalone) | FE + BE | 118 | 14.8 | W5–W6 | [phase-08-fl2-spool-checkin-finishing-run.md](./ShopfloorPlan/phase-08-fl2-spool-checkin-finishing-run.md) |
| 9 | Output Coil Completion, Labeling & Packing — **wholly MVP-1** | FE + BE | 222 *(+16–32 h OQ-10)* ⚠ | 27.8 | W6 | [phase-09-output-coil-completion-labeling-packing.md](./ShopfloorPlan/phase-09-output-coil-completion-labeling-packing.md) |
| 10 | FL3 Hybrid Continuous Operation | BE + FE | 61 | 7.6 | W6 | [phase-10-fl3-hybrid-continuous-operation.md](./ShopfloorPlan/phase-10-fl3-hybrid-continuous-operation.md) |
| 11 | Supervisor Shift Summary, Reporting & Certification — *DB10 MVP-2* | BE + FE | **175** *(246 both scopes)* | 21.9 | W6 | [phase-11-shift-summary-reporting-certification.md](./ShopfloorPlan/phase-11-shift-summary-reporting-certification.md) + [MVP-2 part](../../MVP-2/DevelopmentPlan/ShopfloorPlan/phase-11-mvp2-shift-summary.md) |
| 12 | Yield, Cost Ledger & Scrap | BE | 177 | 22.1 | W7 | [phase-12-yield-cost-ledger-scrap.md](./ShopfloorPlan/phase-12-yield-cost-ledger-scrap.md) |
| 13 | Administration & Reference Data — *Die Mgmt + die table MVP-2* | FE + BE | **143** *(209 both scopes)* | 17.9 | W7 | [phase-13-administration-reference-data.md](./ShopfloorPlan/phase-13-administration-reference-data.md) + [MVP-2 part](../../MVP-2/DevelopmentPlan/ShopfloorPlan/phase-13-mvp2-die-management.md) |
| 14 | Integration Testing, PLC Commissioning & Go-Live | QA + BA | 267 | 33.4 | W7 | [phase-14-integration-testing-plc-commissioning-golive.md](./ShopfloorPlan/phase-14-integration-testing-plc-commissioning-golive.md) |
| | **Total — MVP-1** | | **3,292 h** | **411.5** | | 44 working days × 8 h = **352 h/person** → **9.4 FTE sustained** |
| | *Total — both scopes (incl. Phase 2's 231 h)* | | *3,660 h* | *457.5* | | *10.4 FTE sustained* |

> **The hours in this table are MVP-1**, apportioned 11 Aug 2026 — full working in [`CapacityAndEffortModel.md` §3b](./CapacityAndEffortModel.md). **Phase 2 is wholly MVP-2** and its **231 h** left with it, permanently: pass schedule generation and management are owned by a separate track. **Phase 9 is wholly MVP-1** and keeps its 222 h. **Phases 11 and 13 were split** by re-pricing the carved deliverables from the §2 rate card and **re-deriving** QA and contingency — not by proportional division, which the descope ladder cannot support (**rung 5** bundled the now-MVP-2 Die Management screen with the **MVP-1** role UI; **rung 6** defers four **MVP-1** reports). **⚠ Read the −1 FTE carefully:** nearly all of it lands in **W2–W3**, already the slackest weeks at 5.3 FTE. **W4 and W5 do not move at all**, and **W7 is still 24.5 FTE against three days** — the window still does not close, and §7's decision stands.

> ⚠ **The window does not close as scoped, and apportioning MVP-1 did not change that.** **MVP-1 is 3,292 hours** against 32 post-gate working days (44 including the run-up to the Aug-14 gate — **352 h per person**), requiring **~9.4 concurrent people**, and **W7 requires 24.5**. *(Both scopes: 3,660 h, 10.4 FTE, W7 at 27.2.)* **The ~1 FTE that MVP-2 deferral recovered fell almost entirely in W2–W3, already the slackest weeks at 5.3 FTE — W4 and W5 are unchanged.** The descope ladder now recovers *less* than the published 12%, because rung 5's 99 h bundled the now-MVP-2 Die Management screen with the MVP-1 role UI. On a hands-on-keyboard reading of the hours (6.5 productive h/day) the requirement rises to **~11.7 FTE**. This needs a programme decision — see [Capacity & Effort Model](./CapacityAndEffortModel.md) §3b and §7 (staff up / move the date / cut scope) and gaps register **G1**.

**Cross-phase planning material:**
- [Back Matter — Feature Dependency Mapping · Overall Roadmap (window/milestones/risks) · Known Gaps & Issues Register · Appendices A–C · Related Documents](./ShopfloorPlan/back-matter.md)

### 0.1 Source artifacts this roadmap consolidates

| Artifact | What it feeds |
|---|---|
| `Analysis/FlatWireEndToEndProcess.md` | The 11-stage material journey → phase ordering |
| `MVP-1/RequirementDocuments/*` — **16 documents (14 per-screen specifications)** *(three moved to `MVP-2/RequirementDocuments/` on 11 Aug 2026 with the deferred screens; `OutputCoilCompletion.md` moved and **returned** with Phase 9, and at v1.1 owns **DB7 and DB7b** together)* | **Authoritative screen specs.** Every dashboard has an owning document. The map is the Dashboard Inventory in `Analysis/FlatWireShopfloorDashboards.md`, which **now carries an `MVP` column and a scope badge on every section** (11 Aug 2026). `Spool.md` and `PartialRodReCheckin.md` are the two non-specifications in the folder. |
| `MVP-2/RequirementDocuments/*` — **4 specifications** | **Deferred scope — not a planning input.** `PassScheduleManagement` (DB9/DB9A) · `ShiftSummary` (DB10) · `PassScheduleGenerationSpec` (the generation engine) · `DieManagement` (extracted from `DieChangeAndManagement.md` §4). **`OutputCoilCompletion` returned to MVP-1** with Phase 9. One still binds on MVP-1 despite the deferral: `PassScheduleManagement.md` §3.3–§3.4 holds the only **Operations Manager** role definition, and `FR-212` enforces that role on DB11 Roll Adjust. |
| `Analysis/FlatWireShopfloorDashboards.md` | **No longer a requirements source (11 Aug 2026).** Retained as the internal UX/wireframe record, the navigation map and the **[Alloy Reference Data](../../Analysis/FlatWireShopfloorDashboards.md)** table — which was lifted out of the MVP-2 Dashboard 9 section on 11 Aug 2026 because it is **MVP-1** reference data feeding `AlloyProperty` and the Phase-13 admin grid. **Divided by MVP scope in place, not split.** |
| `MVP-1/RequirementDocuments/RocCheckin.md`, `RodCheckout.md`, `RodPreCheckin.md`, `SpoolQueue.md` | Check-in/checkout/spool operator flows |
| `MVP-1/RequirementDocuments/PartialRodReCheckin.md` | **Design rationale, not one of the 17 specs** — moved here from `Analysis/` 11 Aug 2026 to sit beside its owners. Nothing in it is citable; rules are in `RodPreCheckin.md` §7 and `RodCheckout.md` §7.2, requirement text in `FR-043`. Audit trail for the open `Q12` |
| `MVP-1/RequirementDocuments/Spool.md` | **Domain reference, not one of the 17 specs** — moved here from `Analysis/` 11 Aug 2026 to sit beside its owners. Authoritative for *what a spool is*; its screen sections were consolidated into `RocCheckin.md` §4.3, `SpoolQueue.md` and `OutputCoilCompletion.md` §4, and **its FM2 description is superseded by `D-26`** |
| `MVP-2/RequirementDocuments/PassScheduleManagement.md`, `DieChangeAndManagement.md`, `SPCCheckpoint.md`, `WeldEvent.md`, `PLCTagSpecification.md` | Process workflows and the role matrix, which lives in `02-SRS.md` §8 and `PassScheduleManagement.md` §3.3 *(`Analysis/OperationsManager.md` was deleted 11 Aug 2026 — recoverable at `d79ce78`)*, **the PLC/OPC tag surface** *(replaced `HMIAndSCADALayout.md`, deleted 4 Aug 2026 with the DB13/DB14 descope)* |
| `MVP-1/DevelopmentPlan/APIContracts.md` | `FlatWire.API` REST surface + `FlatWireHub` contract |
| `MVP-1/DBChanges/Schema/*` + `Schema/SQL/*` | The Flat Wire schema — **28 tables** in the new **`FlatWireDB`**, of which **24 are MVP-1** and 3 are the MVP-2 pass-schedule group. **`Rod` is retained** per master-spec **`D-04`** (the "Hybrid foundation" decision), which supersedes `00-foundations.md` decision 3 and its 21-table figure. Verified by a clean deploy on 11 Aug 2026: 25 tables, 33 FKs, 1 procedure, 1 trigger. *(the designed `Rod` table is dropped; rod uses the existing `coils` table). DDL 01–06 + seed |
| `MVP-1/DevelopmentPlan/CapacityAndEffortModel.md` | Per-phase owners + dev-day effort, working-day capacity model, descope ladder (resolves G1) |
| `MVP-1/DevelopmentPlan/FlatWireJiraStories.md` | **The authoritative MVP-1 shopfloor backlog** (rewritten 13 Aug 2026) — **116 stories / 3,292 h**, re-derived from the phase specs in `ShopfloorPlan/`, organised into four even two-week sprints (`S0`–`S3`, `S1` from **24 Aug**) and sized in **hours** off the Capacity & Effort Model's rate card. **Story points are retired**; the old 12-epic / 58-story / 184-point figures are historical and recorded in its Appendix A |
| `MVP-1/DevelopmentPlan/FlatWireTables.md` | Table-by-table design + existing-table renames |
| `Analysis/FlatWireOpenQuestions.md` | **99** open questions (`Q##` / `OQ-##`) → per-phase blockers. **Authoritative decision register** |
| `MVP-1/DevelopmentPlan/ShopfloorPlan/00-foundations.md` **§0.5** | The stub-first delivery contract. *(Rehomed there 13 Aug 2026 from `CheckinImplementationPlan.md` / `CheckinImplementationPrompt.md`, both **deleted** that day — recoverable at `1964086`.)* |
| `MVP-1/DevelopmentPlan/TechStackRecommendation.md` | "Stay within the UAL stack" ADR |
