# PHASE 12 — Yield, Cost Ledger & Scrap

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 11 — Supervisor Shift Summary, Reporting & Certification](./phase-11-shift-summary-reporting-certification.md) · **Next:** [Phase 13 — Administration & Reference Data](./phase-13-administration-reference-data.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
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
- **Database:** reads `CoilTraceability`/`WeldEvent`/`CoilOutput`; renamed yield fields (FW-001).

## Real-Time / Testing / Deliverables
- No real-time. Tests: multi-rod yield rows; weight formula; scrap outlet applies to Flat Wire/Conveyors/Inspection. Deliverables: footage-weight yield, weld-yield attribution, cost ledger config, scrap outlet.

**OQ blockers:** OI-60 (yield per route), OQ-10 (weight), OI-68 (costing), OI-68 (standard times), OI-83/OI-83 (baler/banding). **Stories:** FW-100, FW-101, FW-102, FW-110.
