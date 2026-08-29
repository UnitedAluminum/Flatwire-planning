# PHASE 13 — Administration & Reference Data

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../../00-overview/Roadmap.md).** See [Foundations](../../20-architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 12 — Yield, Cost Ledger & Scrap](./phase-12-yield-cost-ledger-scrap.md) · **Next:** [Phase 14 — Integration Testing, PLC Commissioning & Go-Live](./phase-14-integration-testing-plc-commissioning-golive.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-06
**Status:** Ready to build
**Layer:** Full-stack vertical slice (admin)
**Owner:** **FE + BE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **MVP-1 143 h** (17.9 d) — FE 56 · BE 32 · DB 8 · RT 4 · QA 20 · BA 4 · cont. 19 · **Window:** W7 (Sep 28–30, **3** working days)
**Effort (both scopes, as published Jul 30):** 209 h — FE 80 · BE 48 · DB 16 · RT 4 · QA 30 · BA 4 · cont. 27. The **66 h difference** is Die Management: the screen (24 FE), the die lifecycle service (16 BE) and the die inventory table (8 DB), with QA and contingency re-derived. Basis: [`CapacityAndEffortModel.md` §3b](../CapacityAndEffortModel.md).
**Scope call:** **Partly deferrable** — the **role-assignment UI** is the deferrable part of **ladder rung 5**; the alloy lookup and machine tabs are not. Latest call: W6. **⚠ Rung 5's published 99 h is no longer available in full:** it bundled the Die Management screen with the role-assignment UI, and the screen is now MVP-2, so only the role-UI share can still be cut. **✅ The die-inventory schema gap is closed** — it was never MVP-1's table. Die inventory and lifecycle are owned outside MVP-1, so the **8 h moved out with the screen** (see the effort lines above and `CapacityAndEffortModel.md` §3b). MVP-1's die change reads size, `LastGrindingFeet` and `TotalFeetAllowed` from the **`Drawer`** size catalogue seeded in Phase 1, and **`D4` is enforced at size level** — it rejects an unrecognised die *size*, not an unregistered physical tool. The accepted consequence is that **die life is tracked per size, so two dies of one diameter share a counter**. Authority: [`DieChangeAndManagement.md` §2.4a](../../10-requirements/screens/DieChangeAndManagement.md) (v2.4).

*The admin surfaces that keep the platform running: alloy lookup, die management, machine config, roles.*

> **⚠ The Die Management work in this phase is MVP-2** (11 Aug 2026) — carved out verbatim to
> [`phase-13-mvp2-die-management.md`](./phase-13-mvp2-die-management.md):
> the screen, the die lifecycle service and the die inventory status vocabulary.
> **What stays MVP-1:** the alloy lookup admin and CRUD (`FW-004`), machine template tabs (`FW-003`), role
> assignment, the `Stand`/`Drawer`/`Edger`/`Spool` lookups, and the **30 Jul alloy client answers
> below — which block Phase 4**. The **`FW-N07` table half is also MVP-1**: MVP-1's die change (`FW-073`) rejects
> a die not in inventory, so the 8 h costed for the missing die table stays here even though the screen does not.
> **The 209 h figure above was not apportioned** and now overstates MVP-1. The ladder's rung-5 99 h is **not** the
> MVP-2 share — it bundles this screen with the MVP-1 role-assignment UI.

## Business Overview
- **Objective:** maintain alloy properties, machine configuration tabs, and role/permission assignment. *(Die inventory and life are **MVP-2** — see the callout above.)*
- **User roles:** Process Engineering/Admin (alloy table), Maintenance (machine config), Admin (roles). *(Maintenance's die-management role is MVP-2.)*
- **Entry conditions:** Phase 1 lookups seeded.
- **Exit conditions:** reference data editable without code changes. *(Die life tracking is MVP-2; MVP-1 reads size-level life from the `Drawer` seed.)*

## UI / Backend / Database
- **UI:** alloy lookup admin grid; machine template tabs (Machines app, FW-003); role assignment. *(The **Die Management** screen is **MVP-2** — see [`phase-13-mvp2-die-management.md`](./phase-13-mvp2-die-management.md).)*
- **Backend:** alloy CRUD (audit-logged, restricted); machine config. *(The die lifecycle service is MVP-2.)*
- **Database:** alloy lookup; `Stand`/`Drawer`/`Edger` lookups; `Spool` (article, with its merged size limits) configuration`. *(The die inventory table — status `Active/Nearing/Overdue/Spare/Retired` — is **MVP-2**, and its 8 h went with it. `Drawer` is seeded in Phase 1 and is what MVP-1's die change validates against.)*

## Real-Time / Testing / Deliverables
- Tests: alloy edit audit + restriction; **size-level** die validation against `Drawer` (an unrecognised size is refused). Deliverables: alloy admin, machine tabs, role config. *(The die-life banner, threshold/reset tests and the register-before-scan rule are **MVP-2** — MVP-1 has no per-tool registration to test.)*

**OQ blockers:** OQ-83 (die life tracking — decided; threshold TBD), die-life threshold configurability, OI-77/43 (edger profiles/roll spares). **Stories:** FW-004 (admin), FW-003 (machine tabs), Die Management from `DieChangeAndManagement.md`.

---

## Client answers of 30 Jul 2026 — alloy reference data

**The alloy tolerance admin screen now maintains four min/max pairs, not two single ± values** (**OQ-22**). `AlloyProperty` carries `GaugeTolerance{Minus,Plus}In`, `WidthTolerance{Minus,Plus}In`, `RodDiameterTolerance{Minus,Plus}In` and `RodOvalityMaxIn`. The bands are **offsets about nominal and may be asymmetric**, so the editor must not collapse them to one field. Ovality takes an upper limit only.

⛔ **Blocked on the client, and it blocks Phase 4 too.** Tim confirmed the tolerances exist and will **send the width, height, diameter and ovality values by e-mail**; he did not have them to hand (*"I want to say it's plus or minus 10"*). Until they arrive:

- `RodDiameterTolerance{Minus,Plus}In` and `RodOvalityMaxIn` are **NULL in the seed on purpose** — do not populate them from the Dashboard 2A mock map, which is explicitly labelled mock data.
- `CHK007` cannot fire, at pre-check-in or at check-in.
- The hard-coded ovality limit of `0.003"` must live in this table rather than in code — **it is per-alloy reference data, not a constant**. *(It was hard-coded in `CheckinImplementationPlan.md`, deleted 13 Aug 2026; `AlloyProperty.RodOvalityMaxIn` is now its only home, and it is unseeded pending `OI-07`.)*

The values still need Process Engineering sign-off as well as the e-mail — the *Alloy Lookup Table* in [`../../95-archive/design-notes/FlatWireShopfloorDashboards.md` § **Alloy Reference Data**](../../95-archive/design-notes/FlatWireShopfloorDashboards.md) carries that caveat already. **That section is MVP-1 and top-level since 11 Aug 2026**; it had been inside the MVP-2 Dashboard 9 section, where a scope tag would have carried this phase's own reference data out of MVP-1.
