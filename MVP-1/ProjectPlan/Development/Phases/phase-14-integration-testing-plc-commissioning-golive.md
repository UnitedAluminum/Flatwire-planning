# PHASE 14 — Integration Testing, PLC Commissioning & Go-Live

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../Roadmap.md).** See [Foundations](../../Architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 13 — Administration & Reference Data](./phase-13-administration-reference-data.md) · **Next:** [Back Matter — Dependencies, Roadmap, Gaps & Appendices](../GapsRegister.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-18 — **`D-32`**: the E2E INFLAT assertion retargeted to `Rod.Status`; `FW-201`’s renamed-column regression pass struck *(previously 2026-07-30)*
**Status:** Ready to build
**Layer:** Integration, QA & commissioning
**Owner:** **QA + BA** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **267 h** (33.4 d) — QA 112 · RT 40 (PLC commissioning) · BA 40 (UAT) · FE 16 · BE 16 · DB 8 (defect allowance) · cont. 35 · **Window:** W7 (Sep 28–30, **3** working days)
**Scope call:** **Not deferrable — but W7 cannot hold it.** 267 hours into 3 working days (72 person-hours available at 3 FTE), alongside Phases 12 and 13, is the single worst compression in the plan (W7 needs **27.2 FTE**). UAT and stakeholder sign-off cannot begin the day feature work completes. **Pull this into a dedicated post-feature-complete window regardless of team size** — model §7. The 20% QA uplift is not applied here because this phase *is* the QA phase; its QA days are explicit.

*The convergence phase: three-route E2E, PLC commissioning support, UAT, trial, production.*

## Business Overview
- **Objective:** verify all three routes end-to-end, support PLC commissioning, run UAT, and release for trial then production.
- **User roles:** QA, Ops team, PLC/commissioning engineers, PM.
- **Entry conditions:** Phases 1–13 delivered (at least critical path); staging environment.
- **Exit conditions:** signed-off UAT at window close (Sep 30); on-line trial + production scheduled post-sign-off (Q4 2026, TBD).

## Scope
- **E2E FL1 standalone (FW-120):** Rod received → planned → scheduled → check-in → active run → SPC → weld → complete → spool alpha → shift summary. Verify **`Rod.Status`** `INFLAT` set/cleared *(`FlatWireDB`-local since `D-32`; `coils.coil_status` is never written)*, PLC push logged (simulate/commissioning), weld traceability, SPC records.
- **E2E FL2 standalone (FW-121):** spool → FL2 check-in (historical profile) → roll adjust → coil completion → skid close.
- **E2E FL3 hybrid (FW-122):** single acknowledgment → continuous run → no intermediate alpha → weld → coil; FL1/FL2 unavailable.
- **PLC commissioning:** switch `SimulatePLCTagPush`→live; confirm OPC tag paths with Tim O./engineer; validate push/clear + live AGC feed.
- **UAT (FW-123):** staging (devual-uadev001) with mock SignalR + simulate PLC; clickable demo for Tim O./Shannon R./ops; resolve Critical OQs (OI-88, OQ-2, OQ-3, OQ-76, OI-49, OQ-61, OI-60, OQ-10, OQ-67, OQ-14, OQ-15) before sign-off.

## Testing / Deliverables
- Three green E2E route runs; alpha genealogy Rod→Spool→Coil→Skid; PLC audit; UAT sign-off; trial + production releases.

**OQ blockers:** all Critical OQs must close before UAT sign-off. **Stories:** FW-120, FW-121, FW-122, FW-123.
