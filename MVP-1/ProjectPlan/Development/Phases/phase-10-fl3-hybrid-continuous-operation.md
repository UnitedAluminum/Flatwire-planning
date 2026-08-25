# PHASE 10 — FL3 Hybrid Continuous Operation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../Roadmap.md).** See [Foundations](../../Architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 9 — Output Coil Completion, Labeling & Packing](./phase-09-output-coil-completion-labeling-packing.md) · **Next:** [Phase 11 — Supervisor Shift Summary, Reporting & Certification](./phase-11-shift-summary-reporting-certification.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** Full-stack vertical slice (mostly reuse)
**Owner:** **BE + FE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **61 h** (7.6 d) — FE 12 · BE 20 · DB 4 · RT 8 · QA 9 · cont. 8 · **Window:** W6 (Sep 21–25, 5 working days)
**Scope call:** **Not deferrable — FL3 is one of the three production routes.** The **cheapest phase in the plan** because it reuses Phases 4–6 and 9 behind mode flags; only the FL3 screen variants and the single-batch hybrid push are new. The FL3 E2E (FW-122) is costed in Phase 14, not here.

*Validating the most complex route: FL1 feeds FL2 continuously with a single acknowledgment, no intermediate spool, continuous real-time trace.*

## Business Overview
- **Objective:** run a hybrid job where one check-in acknowledgment configures both mills and material flows FM1→FM2 without stopping; no intermediate spool alpha.
- **Business purpose:** the continuous route for high-aspect-ratio / welding-wire product (1350).
- **User roles:** FL3 operator.
- **Entry conditions:** an Active **Hybrid** pass schedule (FL3, unified record — OQ-15 Option A); FL1/FL2 both free (FL3 blocks both).
- **Exit conditions:** coreless coil completed directly from the continuous run.

## User Journey
1. Rod check-in on FL1 in FL3 mode (Dashboard 2 FL3 variant) → **single acknowledgment** pushes both FM1 and FM2 tags.
2. Dashboard 3 FL3 variant runs continuously; **Roll Adjust** available; real-time trace throughout; no intermediate spool alpha generated.
3. Weld events mid-run keep traceability continuous; completion → Dashboard 7 coreless coil.
- **Decision points:** hybrid schedule selection; roll adjust on FM2 stands.
- **Error scenarios:** FL1/FL2 shown unavailable during FL3; single-push failure → full rollback.

## UI / Backend / Database / Real-Time
Reuses Phases 4–6, 9 with FL3 mode flags:
- **UI:** Dashboard 2/3 FL3 variants (`*_fl3.html`); action bar includes Roll Adjust.
- **Backend:** `CheckInRod` with route=Hybrid → `PLCTagService` pushes **all** FM1+FM2 tags in one batch; no `SpoolProcessing` row created; `FlatWireRun.RouteMode=Hybrid`.
- **Database:** `FlatWireRun(RouteMode=Hybrid)`; no intermediate `SpoolProcessing`; `CoilOutput`/`CoilTraceability` as in Phase 9.
- **Real-Time:** continuous `GaugeReading`/`WidthReading` end-to-end (no FL2 historical switch).

## Integration Flow
`FL3 op → DB2(FL3) single Acknowledge → PLCTagService push FM1+FM2 → continuous run (real-time trace, Roll Adjust) → weld events → DB7 coreless coil (no intermediate spool)`.

## Testing
- **Integration (E2E):** single PLC push covers all components; no intermediate alpha; FL1/FL2 unavailable in scheduling; Roll Adjust present (FL3), absent (FL1); continuous trace.
- **Acceptance:** a full hybrid run from rod to coreless coil with continuous traceability.

## Deliverables
FL3 variants of check-in/active-run; hybrid single-push logic; hybrid completion.

**OQ blockers:** OQ-15 (hybrid schedule model — Option A assumed), OQ-2/OQ-67 (FL3 blocks FL1/FL2 — decided). **Stories:** FW-122 (hybrid E2E), reuse FW-061/062/082/066.
