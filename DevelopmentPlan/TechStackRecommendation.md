# Flat Wire Mill — Tech Stack Recommendation

**Project:** Flat Wire Mill Implementation
**Last Updated:** April 29, 2026
**Document Type:** Architecture Decision Record
**Status:** Recommendation — Pending Review

---

## Summary

Stay entirely within the existing UAL stack. The Flat Wire Mill module is an extension of the existing manufacturing execution system, not a greenfield application. The July 1 trial date leaves no room for new technology ramp-up, and every requirement maps directly to patterns already running in furnace or slitter modules.

---

## Core Stack

| Layer | Technology | Rationale |
|---|---|---|
| **Frontend** | Angular 18.2+ (existing `ual-angular`) | Mockups are already HTML; shopfloor pattern exists in slitter/furnace modules |
| **API** | .NET 8.0 — new `FlatWire` microservice in `ual-api` | Clean Architecture already established; MediatR CQRS fits command-heavy shopfloor ops (check-in, weld event, die change) |
| **Database** | SQL Server — new `FlatWireDB` or schema extension | Consistent with all other UAL databases; traceability joins across R-series, coil, and order tables stay in-engine |
| **Real-time / PLC data** | SignalR (existing pattern) | Gauge trace is live streaming — AGC data needs push, not polling; already wired in OPCConnection service |
| **OPC / PLC tags** | Existing `OPCConnection` service, extended for FL1/FL2/FL3 | PLCs are new hardware but OPC servers are unchanged — no new integration layer needed |
| **Auth / Logging** | JWT + Serilog (inherited from UAL) | Zero additional work |

---

## Shopfloor-Specific Additions

These differ from existing Angular apps and require targeted attention:

### 1. Touch-First UI
Operator screens (rod check-in, active run, weld event) run on shop floor touchscreens. Use Angular Material's large-target components and avoid hover states. The existing HTML mockups are a solid baseline for component design.

### 2. Real-Time Gauge Trace Panel
A Chart.js streaming chart fed by SignalR. FL1 operates in live mode; FL2 uses a historical profile view. Implement as one component with an `isLive` flag to handle both modes.

### 3. PWA / Local Resilience
The shop floor has spotty network connectivity. Use Angular Service Worker with a short cache for the pass schedule and active run state. This prevents operator screens from going blank mid-run during a network drop.

### 4. Pass Schedule as a First-Class Entity
The Pass Schedule is the most critical data structure in the system — it controls which components are active or bypassed, die configurations, roll clearances, and all gauge/width targets. It must have its own dedicated API module with versioning, not just a lookup table.

---

## Suggested New API Microservice Structure

```
FlatWire/
├── FlatWire.API/
│   └── Controllers/          # RodReceiving, PassSchedule, CheckIn, WeldEvent, SPC
├── FlatWire.Application/
│   ├── Commands/             # CheckInRod, RecordWeldJoin, SubmitWIPRejection, CompleteCoil
│   └── Queries/             # GetPassSchedule, GetActiveRun, GetGaugeTrace
├── FlatWire.Domain/
│   └── AggregatesModel/      # Rod, FlatWireRun, PassSchedule, WeldJoinEvent
└── FlatWire.Infrastructure/
    └── Repositories/         # RodRepository, RunRepository, PLCTagService
```

---

## What to Avoid

| Decision | Reason |
|---|---|
| No new frameworks (React, Blazor, etc.) | 10-week window does not allow ramp-up; team is already Angular/.NET |
| No separate mobile app | Angular PWA covers the touchscreen use case without a separate codebase |
| No message broker (Kafka/RabbitMQ) in Phase 1 | SignalR is sufficient for AGC gauge trace volume; revisit post-go-live if throughput becomes an issue |

---

## Key Design Decisions by Feature Area

| Feature | Approach |
|---|---|
| Rod receiving (R-series alpha) | New `RodReceiving` controller in `FlatWire.API`; sequence managed in SQL with no-gap guarantee |
| Pass schedule management | Dedicated module with versioned records; PLC tag push triggered on operator acknowledgement |
| Rod check-in / FL1 and FL2 | Shared Angular UI component; route mode (FL1/FL2/FL3) drives which fields and steps are shown |
| Weld join traceability | `WeldJoinEvent` domain entity linking Rod 1 alpha → Rod 2 alpha → output coil alpha; required for cert generation |
| Gauge trace (live) | SignalR hub streaming AGC data → Chart.js component; FL1 and FL3 hybrid mode |
| Gauge trace (historical) | Query-based profile view for FL2 standalone mode |
| SPC checkpoints | Five defined checkpoints (incoming rod, post-die, FM1 output, FM2 S2 output, final coil); stored per run, surfaced in reports |
| WIP rejection | Existing WIP rejection module extended with flat wire outlet options and observation codes |
| Certificate of Conformance | Existing Certs module; traceability chain must include all weld join events for welding wire customers |
| Scrap disposition | Scrap module extended with new outlet: `Scrap Box` vs. `Scrap Skid` |

---

## Phase 1 Constraints (from April 16 Meeting)

- No Angular/frontend receiving screen changes in Phase 1 — rod receiving is backend only
- No EDI — manual rod receiving only
- One shared UI for FL1 and FL2 check-in and transactions
- PLCs are new hardware; OPC servers remain unchanged

---

## Related Documents

| Document | Purpose |
|---|---|
| [FlatWireEndToEndProcess.md](../Analysis/FlatWireEndToEndProcess.md) | Full end-to-end process reference with all 11 stages |
| [FlatWirePlan.md](../Analysis/FlatWirePlan.md) | Implementation plan — scope, milestones, risks |
| [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) | Open questions register |
| [FlatWireShopfloorDashboards.md](../Analysis/FlatWireShopfloorDashboards.md) | Shopfloor screen specifications |
