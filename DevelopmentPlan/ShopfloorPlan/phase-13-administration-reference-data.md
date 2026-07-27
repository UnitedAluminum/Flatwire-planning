# PHASE 13 — Administration & Reference Data

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 12 — Yield, Cost Ledger & Scrap](./phase-12-yield-cost-ledger-scrap.md) · **Next:** [Phase 14 — Integration Testing, PLC Commissioning & Go-Live](./phase-14-integration-testing-plc-commissioning-golive.md)

---

*The admin surfaces that keep the platform running: alloy lookup, die management, machine config, roles.*

## Business Overview
- **Objective:** maintain alloy properties, die inventory/life, machine configuration tabs, and role/permission assignment.
- **User roles:** Process Engineering/Admin (alloy table), Maintenance (die management, machine config), Admin (roles).
- **Entry conditions:** Phase 1 lookups seeded.
- **Exit conditions:** reference data editable without code changes; die life tracked.

## UI / Backend / Database
- **UI:** alloy lookup admin grid; **Die Management** screen (`dashboard_die_management.html`) — inventory, life thresholds, reset/edit/retire/register; machine template tabs (Machines app, FW-003); role assignment.
- **Backend:** alloy CRUD (audit-logged, restricted); die lifecycle service (cumulative footage per die from PLC counter, configurable threshold, <10% banner, reset by Maintenance); machine config.
- **Database:** alloy lookup; die inventory (status Active/Nearing/Overdue/Spare/Retired); `Stand`/`Drawer`/`Edger` lookups; `SpoolConfiguration`.

## Real-Time / Testing / Deliverables
- Die-life banner may use passive alert. Tests: alloy edit audit + restriction; die life thresholds + reset; register-before-scan rule. Deliverables: alloy admin, Die Management screen, machine tabs, role config.

**OQ blockers:** OQ-41 (die life tracking — decided; threshold TBD), die-life threshold configurability, OQ-42/43 (edger profiles/roll spares). **Stories:** FW-004 (admin), FW-003 (machine tabs), Die Management from `DieChangeAndManagement.md`.
