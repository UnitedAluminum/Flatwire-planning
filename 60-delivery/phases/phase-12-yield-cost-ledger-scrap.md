# PHASE 12 — Yield, Cost Ledger & Scrap

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../../00-overview/Roadmap.md).** See [Foundations](../../20-architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 11 — Supervisor Shift Summary, Reporting & Certification](./phase-11-shift-summary-reporting-certification.md) · **Next:** [Phase 13 — Administration & Reference Data](./phase-13-administration-reference-data.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-18 — **`D-32`**: the FW-001 renamed yield fields are struck; this phase reads the existing column names *(previously 2026-08-13 — pointer added to the new phase sheet; **no scope or effort figure in this file changed**)*
**Status:** Ready to build — ⚠ but see the specification gap in the phase sheet below
**Phase sheet:** [`YieldCostAndScrapSheet.md`](../YieldCostAndScrapSheet.md) — story-level effort on both delivery bases (hand-coded **177 h** / AI-assisted **126 h**), the descope-ladder role, and the blocker analysis. **Read it before scheduling this phase:** it records that `FW-101`, `FW-102` and `FW-110` carry **no `FR-` IDs and have no owning requirement document**, so this phase's 177 h was priced against four Jira cards.
**Layer:** Full-stack vertical slice (back-office)
**Owner:** **BE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **177 h** (22.1 d) — FE 44 · BE 72 · DB 12 · QA 26 · cont. 23 · **Window:** W7 (Sep 28–30, **3** working days)
**Scope call:** **Deferrable — this phase is the whole of ladder rungs 1–4** (177 h recovered in total): rungs 1–3 defer FW-110 (33 h), FW-102 (49 h) and FW-101 (28 h) individually, and rung 4 is the **67 h remainder**. Latest call: W6. ⚠ **Estimate provisional:** OI-68 (costing), OI-68 (standard times) and OI-60 (yield per route) are all open, and OQ-10 gates the weight formula.

*Costing/accounting and scrap disposition — Medium/Low priority; first candidates to slip past the Sep 30 window (post-trial acceptable).*

## Business Overview
- **Objective:** footage-based yield with weld attribution, flat-wire cost ledger configuration, and scrap box/skid outlet.
- **User roles:** Production controller, Cost accountant, Scrap operator.
- **Entry conditions:** completion + traceability data; footage→weight factor confirmed.
- **Exit conditions:** yield attributes footage per source rod; costing reportable; scrap routed correctly.

## UI / Backend / Database
- **UI:** yield form ("Flat Wire" checkbox; field renames), cost ledger config, scrap module outlet (`Scrap Box`/`Scrap Skid`).
- **Backend:** extend `CoilYield`, `CoilCosting`, scrap services; footage×area×density weight; per-rod yield attribution across weld points; cost standards/times (OI-68/OI-68).
- **Database:** reads `CoilTraceability`/`WeldEvent`/`CoilOutput`. ⚠ ~~renamed yield fields (FW-001)~~ — **struck 18 Aug 2026, `D-32`**: `FW-001` is cancelled, so the yield fields keep their **existing** names and this phase reads them unchanged.

## Real-Time / Testing / Deliverables
- No real-time. Tests: multi-rod yield rows; weight formula; scrap outlet applies to Flat Wire/Conveyors/Inspection. Deliverables: footage-weight yield, weld-yield attribution, cost ledger config, scrap outlet.

**OQ blockers:** OI-60 (yield per route), OQ-10 (weight), OI-68 (costing), OI-68 (standard times), OI-83/OI-83 (baler/banding). **Stories:** FW-100, FW-101, FW-102, FW-110.
