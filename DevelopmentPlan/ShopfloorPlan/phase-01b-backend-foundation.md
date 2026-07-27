# PHASE 1B — Backend Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** One of the three layer specs that replace the combined Phase 1 doc — see the [Phase 1 index](./phase-01-core-platform-setup.md).
> **Siblings:** [1A — Angular Foundation](./phase-01a-angular-foundation.md) · [1C — Database Foundation](./phase-01c-database-foundation.md)
> **Reference context (do not restate):** [Foundations §0.2](./00-foundations.md) (codebase map — build against `c:\UAL\ual-api`, template = `API/Domain/CoilCheckin`), **§0.3** (domain cheat-sheet), **§0.4** (real-time architecture).

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-26
**Status:** Ready to build
**Layer:** .NET 8 microservice (`ual-api`)

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate)
> Phase 1 must be complete by **14 Aug 2026** (user mandate; supersedes the roadmap's W1 = Aug 17–23). 1A/1B/1C run **in parallel**; 1B ships **stub** endpoints returning schema-valid fixtures first so 1A can build against the real service early, and wires the real repositories to 1C's `FlatWireDB` as the schema lands.

## Objective
Stand up the new `FlatWire` Clean-Architecture microservice — thin controllers over MediatR, a
DI-swappable stub/real service layer, mixed Dapper/EF data access against `FlatWireDB`, and a
purpose-built high-throughput `FlatWireHub` — so every later phase adds commands/queries only.

## Dependencies
- **Template:** `API/Domain/CoilCheckin` (copy controller / MediatR command / `Program.cs` / `.csproj` / NuGet patterns); `API/Domain/OPCConnection` for tag read/write; `UA.Framework.API/UAController` base.
- **Converges with:** 1C (`FlatWireDbContext` targets its 22 tables + seed) and 1A (`APIContracts.md` envelope). Stub path is unblocked immediately.
- **Backlog:** FW-005/006/007 wiring; scaffold of FW-080/FW-082 (hub + PLC push skeletons).

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Solution architecture** | New domain `API/Domain/FlatWire/` with `FlatWire.sln` + 4 projects `FlatWire.API` / `.Application` / `.Domain` / `.Infrastructure` (copied from `CoilCheckin`); refs `API→Application,Domain,Infrastructure`; `Application→Domain`; `Infrastructure→Domain` |
| **API structure (thin controllers over `UAController`)** | `LinesController`, `PassScheduleController`, `RodReceivingController`, `CheckInController`, `RunController`, `SpcController`, `WeldEventController`, `RollAdjustController`, `DieChangeController`, `CheckOutController`, `WipRejectionController`, `CoilController`, `ShiftSummaryController` |
| **MediatR** | `Commands/` + `Queries/` folders per `APIContracts.md`; MediatR registered in `Program.cs` (copy `CoilCheckin.API/Program.cs`); pipeline behaviors for validation + logging |
| **Dependency injection** | `Program.cs` service registration; interface-driven services; `useStub`/environment swap of stub vs real service (as in `CoilCheckin`) |
| **Repository pattern** | `FlatWire.Infrastructure/Repositories/` — `PassScheduleRepository`, `RodRepository` (reads existing `coils`), `RunRepository`, `CoilRepository`, etc. behind interfaces |
| **Data access** | **Dapper** for high-volume reads (gauge trace, shift summary, list grids); **EF Core** `FlatWireDbContext` for entity writes — UAL's mixed convention |
| **Logging** | Serilog (inherited UAL config); structured logs; **audit log** for PLC pushes + pass-schedule overrides |
| **Configuration** | `appsettings.{Environment}.json`: connection string (**`FlatWireDB`**), JWT, **OPC tag-path map** (config-driven, not hardcoded), SignalR (MessagePack, keep-alive/timeout, cadence) |
| **Authentication** | JWT bearer (inherited); hub auth via `?access_token=` query param |
| **Authorization** | Role policies matching the Authorization Matrix in `APIContracts.md` — Operator / Operations Manager / Maintenance / Supervisor / Admin. **`[Authorize]` on every controller/endpoint** (see Review-fixes) |
| **Exception handling** | Global exception middleware → envelope (`400` validation, `404` not found, `409` conflict, `422` unprocessable, `500` PLC/server) |
| **Validation** | FluentValidation per command (e.g. `FM2_6inS2` must be Active; FL3 requires Hybrid; `PassScheduleComponent.State ∈ {Active,Bypass,Skip}`) |
| **Health checks** | ASP.NET Core health checks (DB + OPC reachability) at `/health` |

## Real-time / OPC slice (server half — per §0.4)
| Piece | Deliverable |
|---|---|
| **SignalR hub** | `FlatWire.API/Hubs/FlatWireHub.cs` — **strongly-typed** `Hub<IFlatWireClient>`, **MessagePack** (`AddSignalR().AddMessagePackProtocol()`), WebSockets-first (`SkipNegotiation` where topology allows), `[Authorize]`, `JoinLineGroup`/`LeaveLineGroup` (groups `FL1Data/FL2Data/FL3Data`). Self-contained in FlatWire; **purpose-built — not copied from existing hubs.** |
| **Typed client contract** | `IFlatWireClient` in `FlatWire.Domain` with the **full event set**: `GaugeReading(GaugeReading[])`, `WidthReading(WidthReading[])`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`, **`LineStatus`, `AlertRaised`, `AlertCleared`**, + SCADA markers (`WeldJoinEvent`, `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint`, `RodCheckoutEvent`) |
| **OPC ingest** | `IHostedService` in `FlatWire.Infrastructure` reads FL1/FL2/FL3 tags (via `OPCConnection`) into a **bounded `System.Threading.Channels.Channel<Reading>`** (drop-oldest/coalesce) |
| **Broadcast loop** | Drains the channel on a **fixed cadence (default ~100 ms / 10 Hz)**, sends **batched arrays** per line group; hot numeric channels decimated to cadence; `ComponentStatus`/`LineStatus` on-change only; rare domain events sent immediately, unbatched. FL2 standalone suppresses batched gauge/width (historical profile is a REST query) |
| **PLC tag service** | `FlatWire.Infrastructure/Services/PLCTagService.cs` — `PushPassSchedule(...)`, `ClearPayoffTags(...)`, batch write, **`SimulatePLCTagPush` dev mode**. ⚠ OPC writes are **not transactional** — model failure recovery as compensating re-clears, not "rollback" (G2/G16) |
| **Scale-out** | Stateless hub; Redis / Azure SignalR backplane is a **config-only** path if `FlatWire.API` goes multi-instance. Single instance is fine for trial |

## Testing
- **xUnit** boots `FlatWire.API`; all **stub endpoints** return schema-valid fixtures (`APIContracts.md` shapes) so 1A can integrate before the DB is populated.
- `/health` green (DB + OPC checks; OPC may report simulated-healthy in dev).
- Hub smoke test: a client `JoinLineGroup('FL1Data')` receives simulated batched `GaugeReading[]` at the configured cadence; reconnect re-joins the group.
- FluentValidation unit tests for the sample rules (FM2_6inS2 Active, FL3⇒Hybrid, component `State` enum).

## Acceptance criteria (exit)
1. `FlatWire.sln` builds; `FlatWire.API` boots under Development with `useStub` on.
2. Every controller in the list exists, extends `UAController`, is `[Authorize]`-protected, and returns the `{Data,Success,Errors}` envelope.
3. Stub endpoints return schema-valid fixtures for the seed alphas; global exception middleware maps to the right status codes.
4. `FlatWireHub` streams simulated batched telemetry to line groups over MessagePack; `SimulatePLCTagPush` logs an audit entry.
5. `/health` green; xUnit + validator suites pass.

## Review-fixes applied in this layer
- **`RollAdjustTrigger` added to `CheckpointType`:** the enum used by `/rolloverride`'s side-effect (`APIContracts.md:1183`) and `SpcCheckpoint.CheckpointType` was missing this value — the backend enum here defines `{PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun}` (mirror in DB `CHECK` — 1C).
- **Full SignalR event set:** `IFlatWireClient` includes `LineStatus`/`AlertRaised`/`AlertCleared` (omitted from FW-080's list) so command side-effects that broadcast them are typed.
- **`[Authorize]` everywhere:** resolves the check-in-docs inconsistency (`CheckinImplementationPrompt` used bare `ControllerBase` with no `[Authorize]`); `APIContracts.md` Authorization Matrix is the source of truth.
- **PLC "rollback" reworded:** `PLCTagService` failure handling is compensating re-clears, not a transaction (G2/G16). Cross-DB check-in is **not** one ACID transaction — document the saga/compensation boundary.
- **Canonical enums (cross-layer):** `PassScheduleComponent.State ∈ {Active,Bypass,Skip}` (not a bool); `EdgeType ∈ {Round,Square}`. Must match 1A model + 1C `CHECK`.
- **Naming:** the domain aggregate and the table/endpoint/story name must agree — use **`WeldEvent`** consistently (source docs drift between `WeldJoinEvent` and `WeldEvent`); the SCADA marker event may keep `WeldJoinEvent` as the SignalR method name if documented.
