# PHASE 12 — Yield, Cost Ledger & Scrap

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 11 — Supervisor Shift Summary, Reporting & Certification](./phase-11-shift-summary-reporting-certification.md) · **Next:** [Phase 13 — Administration & Reference Data](./phase-13-administration-reference-data.md)

---

*Costing/accounting and scrap disposition — Medium/Low priority; first candidates to slip past the Sep 30 window (post-trial acceptable).*

## Business Overview
- **Objective:** footage-based yield with weld attribution, flat-wire cost ledger configuration, and scrap box/skid outlet.
- **User roles:** Production controller, Cost accountant, Scrap operator.
- **Entry conditions:** completion + traceability data; footage→weight factor confirmed.
- **Exit conditions:** yield attributes footage per source rod; costing reportable; scrap routed correctly.

## UI / Backend / Database
- **UI:** yield form ("Flat Wire" checkbox; field renames), cost ledger config, scrap module outlet (`Scrap Box`/`Scrap Skid`).
- **Backend:** extend `CoilYield`, `CoilCosting`, scrap services; footage×area×density weight; per-rod yield attribution across weld points; cost standards/times (OQ-3/OQ-5).
- **Database:** reads `CoilTraceability`/`WeldEvent`/`CoilOutput`; renamed yield fields (FW-001).

## Real-Time / Testing / Deliverables
- No real-time. Tests: multi-rod yield rows; weight formula; scrap outlet applies to Flat Wire/Conveyors/Inspection. Deliverables: footage-weight yield, weld-yield attribution, cost ledger config, scrap outlet.

**OQ blockers:** OQ-35 (yield per route), OQ-36 (weight), OQ-3 (costing), OQ-5 (standard times), OQ-7/OQ-13 (baler/banding). **Stories:** FW-100, FW-101, FW-102, FW-110.
