# Flat Wire Mill — Tech Stack Recommendation

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 13, 2026 — decisions confirmed and accepted *(body otherwise April 29, 2026)*
**Document Type:** Architecture Decision Record
**Status:** **Accepted** — these decisions are built against, not proposed

---

## Summary

Stay entirely within the existing UAL stack. The Flat Wire Mill module is an extension of the existing manufacturing execution system, not a greenfield application. The compressed delivery window leaves no room for new technology ramp-up, and every requirement maps directly to patterns already running in furnace or slitter modules.

> **Accepted 13 Aug 2026.** This ADR sat at *"Recommendation — Pending Review"* for fifteen weeks while the whole build proceeded on its decisions — the `FlatWire` microservice, `FlatWireDB`, SignalR and the extended `OPCConnection` are all in the roadmap and Phase 1 is building them. **Two open points in the body have been closed** and are marked inline: the database decision, and the SPC-checkpoint count. The original delivery framing referenced a **July 1 trial**, superseded on 26 Jul 2026 by the **17 Aug – 30 Sep 2026** window with production in **Q4 2026**.
>
> **One reference correction:** the rationale for Angular cites *"the shopfloor pattern exists in slitter/furnace modules"*. That is true of the platform but **must not be read as permission to copy them** — `00-foundations.md` §0.2 makes `SlitterInterface` **explicitly not a reference**, for neither UI nor hub pattern, and there is **no** Angular structural template for `flat-wire-shopfloor`. The screens are built from [`MVP-1/Mockups/`](../Mockups/); the only reuse is the foundational `shared` services.

---

## Core Stack

| Layer | Technology | Rationale |
|---|---|---|
| **Frontend** | Angular 18.2+ (existing `ual-angular`) | Mockups are already HTML; shopfloor pattern exists in slitter/furnace modules |
| **API** | .NET 8.0 — new `FlatWire` microservice in `ual-api` | Clean Architecture already established; MediatR CQRS fits command-heavy shopfloor ops (check-in, weld event, die change) |
| **Database** | SQL Server — **a new standalone `FlatWireDB`** *(decided; the "or schema extension" alternative is closed)* | Consistent with all other UAL databases; traceability joins across R-series, coil, and order tables stay in-engine. **Built by `FlatWire_DDL_00_Database.sql`** — 25 MVP-1 tables of 28 in the full design, verified by a clean rebuild on 11 Aug 2026. Cross-database references (`PlanId`, `SkidId`, `PassScheduleId`, rod alphas into `coils`) are **documented logical FKs, unenforced by design** — the cost of the standalone choice, tracked as **`G17`** |
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

### 4. Pass Schedule as a First-Class Entity — **MVP-2 to build, MVP-1 to read**

> **Scope, added 13 Aug 2026.** The judgement below is unchanged and still right — but **MVP-1 does not build the pass schedule.** Authoring, generation and management are owned by a **separate track** (not deferred to a later MVP-1 sprint), along with the three `PassSchedule*` tables, DB9/DB9A and `FW-010`–`FW-013`. **MVP-1 only *reads* a schedule at check-in** to build the PLC tag push payload, and `PassScheduleId` is a **documented external reference** with no local FK — the same class as `PlanId` and `SkidId`. The Service Worker caching in §3 above is therefore MVP-1 (it caches a schedule the line is running), while the dedicated API module described here is not.

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
| No new frameworks (React, Blazor, etc.) | The delivery window does not allow ramp-up; team is already Angular/.NET. *(Written against the April 10-week estimate; the argument is **stronger** now — the window is **~6.5 weeks**, 17 Aug – 30 Sep 2026, and already needs 9.4 FTE sustained.)* |
| No separate mobile app | Angular PWA covers the touchscreen use case without a separate codebase |
| No message broker (Kafka/RabbitMQ) in Phase 1 | SignalR is sufficient for AGC gauge trace volume; revisit post-go-live if throughput becomes an issue |

---

## Key Design Decisions by Feature Area

| Feature | Approach |
|---|---|
| Rod receiving (R-series alpha) | New `RodReceiving` controller in `FlatWire.API`; sequence managed in SQL with no-gap guarantee |
| ~~Pass schedule management~~ **(MVP-2)** | Dedicated module with versioned records. **The PLC tag push on operator acknowledgement is MVP-1** — it happens at rod check-in, reading a schedule the other track published |
| Rod check-in / FL1 and FL2 | Shared Angular UI component; route mode (FL1/FL2/FL3) drives which fields and steps are shown |
| Weld join traceability | `WeldJoinEvent` domain entity linking Rod 1 alpha → Rod 2 alpha → output coil alpha; required for cert generation |
| Gauge trace (live) | SignalR hub streaming AGC data → Chart.js component; FL1 and FL3 hybrid mode |
| Gauge trace (historical) | Query-based profile view for FL2 standalone mode |
| SPC checkpoints | **Five physical measurement points** — incoming rod, post-die, FM1 output, **FM2 final-stand (S3) output**, final coil; stored per run, surfaced in reports. **These are not the `CheckpointType` enum** — see the note below |
| WIP rejection | Existing WIP rejection module extended with flat wire outlet options and observation codes |
| Certificate of Conformance | Existing Certs module; traceability chain must include all weld join events for welding wire customers |
| Scrap disposition | Scrap module extended with new outlet: `Scrap Box` vs. `Scrap Skid` |

> ### The "five SPC checkpoints" and the `CheckpointType` enum are different axes
>
> **Closed 13 Aug 2026** (`REVIEW.md` Tier 1 #7, which read the two lists as a contradiction).
>
> - **The five above are physical measurement points** — *where on the line* a checkpoint is taken.
> - **`CheckpointType`** — `{PreRun, PostDieChange, ManualSpotCheck, PostRun, RollAdjustTrigger}` — is *why the checkpoint fired*. It is an event cause, not a location.
>
> They do not map one-to-one and were never meant to: an incoming-rod measurement is a `PreRun`, an FM1-output measurement could be a `PostDieChange`, a `ManualSpotCheck` or a `RollAdjustTrigger` depending on what prompted it. **Neither list is wrong and neither needs to be reconciled to the other** — the measurement *name* is what distinguishes them within a checkpoint, which is why `SpcMeasurement` is a child of `SpcCheckpoint`. `RollAdjustTrigger` was missing from the enum until 13 Aug 2026 even though `POST /rolloverride` already wrote it.

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
| [FlatWireEndToEndProcess.md](../../Analysis/FlatWireEndToEndProcess.md) | Full end-to-end process reference with all 11 stages |
| [FlatWirePlan.md](../../Analysis/FlatWirePlan.md) | Implementation plan — scope, milestones, risks |
| [FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) | Open questions register |
| [FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md) | Shopfloor screen specifications |
