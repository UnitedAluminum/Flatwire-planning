# PHASE 1 — Core Platform Setup

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context (codebase map, domain cheat-sheet, real-time architecture).
> **Next:** [Phase 2 — Pass Schedule Management](./phase-02-pass-schedule-management.md)

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** Angular + .NET + SQL Server (the only layer-organised phase)
**Owner:** **FE** (1A) · **BE + RT** (1B) · **DB** (1C) — *named owners TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **1,027 h** (128.4 d) roll-up — 1A **370 h** · 1B **442 h** · 1C **215 h** · **Window:** W0 (to Aug 14, 12 working days = 96 h/person)

> ### ⚠ Capacity warning
> 1,027 hours in 12 working days — 96 h per person — requires **10.7 FTE**. 1A/1B/1C genuinely parallelise, so this is a **headcount** problem, not a sequencing one. Either staff to it or cut Phase-1 scope **before** the gate — see [Capacity & Effort Model](../CapacityAndEffortModel.md) §4 and §7. This phase is also the model's **calibration checkpoint** (§6): record actual hours against the three estimates (370 / 442 / 215 h) and restate the rate card.
>
> Note that epic **E01 (7 stories / 28 points) is entirely database work** — there is no backlog story covering the Angular library scaffold, the `FlatWire` .NET solution and its 13 controllers, or the OPC ingest and `PLCTagService`. That omission is the main reason this phase was believed to fit.

---

**Objective:** stand up a reusable Angular + .NET + SQL Server platform so that every workflow phase is pure feature work with no further infrastructure lift. This is the only layer-organised phase.
**Backlog coverage:** FW-001, FW-002, FW-004, FW-005, FW-006, FW-007 (Epic 1 Foundation) + the scaffold portions of FW-080/FW-082 (SignalR/OPC skeletons).
**Exit condition:** an authenticated, routable `flat-wire-shopfloor` Angular library talking (via mock and real toggles) to a running `FlatWire` .NET microservice, whose EF/Dapper layer targets the fully-created `FlatWireDB` schema, with a `FlatWireHub` skeleton streaming simulated data.

## 1A. Angular Foundation

| Setup activity | Concrete deliverable |
|---|---|
| **Project architecture** | New library `flat-wire-shopfloor` (prefix `fw`) scaffolded with `ng generate library flat-wire-shopfloor --prefix=fw` → `projects/flat-wire-shopfloor/`; registered in `angular.json` and `tsconfig` paths; added to the `build:shop-floor` npm chain |
| **Folder structure** | `src/lib/{components,components/shared,services,models,guards,styles}` + `flat-wire-shopfloor.module.ts`, `flat-wire-shopfloor-routing.ts`, `public-api.ts` (standard Angular-library layout — **not** copied from any existing feature library) |
| **Shared services / UI controls** | Consume `projects/shared` **foundational services only** (HTTP/auth/config/logging per §0.2). **Build all flat-wire UI new** — `pass-schedule-table`, `payoff-weight-bar`, `gauge-trace-chart`, `alert-banner`, `action-bar`, `confirm-bar` are new `fw`-prefixed controls, **not** derived from `shop-floor-common` or any existing UI library |
| **Routing** | Lazy-loaded `FLAT_WIRE_ROUTES` under `/flat-wire`; per-line routes e.g. `/flat-wire/line/:lineId/checkin/rod`, `/flat-wire/line/FL2/checkin/spool`, `/flat-wire/line/:lineId/run/active` |
| **Layout** | Shell layout component: header (line context + operator + clock), sidebar nav to all dashboards, alert-banner slot; fixed 1280×1024 shopfloor canvas |
| **Authentication** | Reuse `shared` `login.service` / `login-api.service` + `token-interceptor.service` (JWT bearer) |
| **Authorization / Route guards** | `FlatWireAuthGuard` (authenticated) + `FlatWireRoleGuard` (Operations Manager routes — DB9/9A — gated from operator routes) per the role matrix in §Roles |
| **Interceptors** | Reuse `token-interceptor` (JWT), `correlation-id-interceptor`, and `global-error-handler-api` — no new interceptors |
| **Shared components** | Controls per the **new approved mockups**: standard `.input` with validation states, `payoff-option` selector cards, pass/fail + OK/NG/NA inspection buttons, tab-wizard, SPC tolerance-viz, monospace readouts (`--font-mono`), Pass Schedule confirm-bar gate. Sizing/touch targets follow the new mockups (fixed 1280×1024 canvas) |
| **Common services** | `line-context.service` (current FL1/FL2/FL3 scope), `run-state.service` (active alpha/footage/payoff) |
| **API client** | `flat-wire-api.interface.ts` with two implementations — `flat-wire-api-real.service.ts` (over `shared` `api-gateway.service`) and `flat-wire-api-mock.service.ts`; DI-swapped by `useMockData` env flag |
| **Models** | `rod.model.ts`, `spool.model.ts`, `pass-schedule.model.ts`, `active-run.model.ts`, `checkin.model.ts`, `weld-event.model.ts`, `spc-checkpoint.model.ts`, `signalr-events.model.ts` |
| **Error handling** | Reuse `error-handler.service`; standardise on the `{ success, data, errors[] }` envelope; toast + inline field errors |
| **Global state** | `run-state.service` + RxJS `BehaviorSubject`s; no NgRx (not used in repo) |
| **Configuration** | `app-config.service` + `environment.*.ts` (`useMockData: true` in `environment.development.ts`, `false` elsewhere; API base + hub URL) |
| **Logging** | `ui-log.service` for client telemetry |
| **Theme** | Consume the **existing semantic design-token system** in `Mockups/flat-wire-shopfloor.styles.scss/.css` **as-is** — `--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono` (every mockup already uses it; the `--fw-*` prefix in older docs is stale — G18); light + `prefers-color-scheme: dark`; components use `ViewEncapsulation.None`/`:host` so tokens resolve |
| **Utilities** | `util.service` + local `fw` helpers (footage/gauge formatting, SVG path builders) |
| **Real-time client** | `flat-wire-signalr.service.ts` — `@microsoft/signalr` + **MessagePack** protocol, auto-reconnect w/ backoff, callbacks **outside NgZone** into a ring buffer, `requestAnimationFrame`-throttled render (see §0.4); typed Observables per event; `MockSignalRService` timer-driven for stub mode. **New service — deliberately not the existing `supervisor-monitor-hub` pattern.** |

## 1B. Backend Foundation

| Setup activity | Concrete deliverable |
|---|---|
| **Solution architecture** | New domain `API/Domain/FlatWire/` with `FlatWire.sln` + 4 projects `FlatWire.API` / `FlatWire.Application` / `FlatWire.Domain` / `FlatWire.Infrastructure` (copied from `CoilCheckin`); refs `API→Application,Domain,Infrastructure`; `Application→Domain`; `Infrastructure→Domain` |
| **API structure** | Thin controllers extending `UAController` (`UA.Framework.API`): `LinesController`, `PassScheduleController`, `RodReceivingController`, `CheckInController`, `RunController`, `SpcController`, `WeldEventController`, `RollAdjustController`, `DieChangeController`, `CheckOutController`, `WipRejectionController`, `CoilController`, `ShiftSummaryController` |
| **MediatR setup** | `Commands/` + `Queries/` folders per `APIContracts.md`; MediatR registered in `Program.cs` (copy `CoilCheckin.API/Program.cs`); pipeline behaviors for validation + logging |
| **Dependency Injection** | `Program.cs` service registration; interface-driven services; `useStub`/environment swap of stub vs real service (as in `CoilCheckin`) |
| **Repository pattern** | `FlatWire.Infrastructure/Repositories/` — `PassScheduleRepository`, `RodRepository`, `RunRepository`, `CoilRepository`, etc. behind interfaces |
| **Dapper** | Dapper for high-volume reads (gauge trace, shift summary, list grids); EF Core `FlatWireDbContext` for entity writes — matching UAL's mixed data-access convention |
| **Logging** | Serilog (inherited UAL config) — structured logs; audit log for PLC pushes and pass-schedule overrides |
| **Configuration** | `appsettings.{Environment}.json`: connection string (**`FlatWireDB`**), JWT, **OPC tag-path map** (config-driven, not hardcoded), SignalR (MessagePack, keep-alive/timeout, cadence) |
| **Authentication** | JWT bearer (inherited); hub auth via `?access_token=` query param |
| **Authorization** | Role policies matching the Authorization Matrix in `APIContracts.md` (Operator / Operations Manager / Maintenance / Supervisor / Admin) |
| **Exception handling** | Global exception middleware → envelope (`400` validation, `404` not found, `409` conflict, `422` unprocessable, `500` PLC/server) |
| **Validation** | FluentValidation validators per command (e.g. `FM2_S3` must be Active; FL3 requires Hybrid) |
| **SignalR infrastructure** | `FlatWire.API/Hubs/FlatWireHub.cs` — **strongly-typed** `Hub<IFlatWireClient>`, **MessagePack** protocol, WebSockets-first, `[Authorize]`, `JoinLineGroup`/`LeaveLineGroup` (groups `FL1Data/FL2Data/FL3Data`); self-contained in FlatWire service; **purpose-built per §0.4 — not copied from existing hubs** |
| **Background services** | `IHostedService` OPC ingest in `FlatWire.Infrastructure` reads FL1/FL2/FL3 tags (via `OPCConnection` integration) into a bounded channel; a broadcast loop drains it on a fixed cadence |
| **Queue processing** | Bounded `System.Threading.Channels.Channel<T>` (drop-oldest/coalesce) between OPC ingest and hub broadcast; readings **batched + decimated** to ~10 Hz per line group; no external broker in Phase 1 (Redis / Azure SignalR backplane is the config-only scale-out path) |
| **Health checks** | ASP.NET Core health checks (DB + OPC reachability) at `/health` |
| **PLC tag service** | `FlatWire.Infrastructure/Services/PLCTagService.cs` — `PushPassSchedule(...)`, `ClearPayoffTags(...)`, batch/transactional write, `SimulatePLCTagPush` dev mode |

## 1C. Database Foundation

Target database: a **new `FlatWireDB`** (per the July 26 decision and the `TechStackRecommendation.md` "new `FlatWireDB`" option). The DDL scripts currently header `USE [united_db]` and must be **retargeted to `FlatWireDB`** (one find-replace across DDL 01–06 + seed). The Flat Wire schema is **21 tables** created by the numbered scripts + one seed — the designed `Rod` table is **dropped**: rod/R-series material lives in the existing **`coils`** table (single source of truth for rods). The existing-schema **column renames (FW-001) remain in the existing shared scheduling database** — the `coils`/scheduling schema is **not** moved into `FlatWireDB`. Cross-database references (`coils` rod rows referenced by `RodCheckin`/`WeldEvent`/`RollOverride`/`DieChangeEvent`/`CoilTraceability`/`RodCheckout`/`Spool.ParentRodAlpha`, plus `CoilOutput.SkidId`, planning `PlanId`) stay as unenforced logical FKs — see Gaps G2/G17.

| Setup activity | Concrete deliverable |
|---|---|
| **Database structure** | Create `FlatWireDB`; retarget DDL `USE` statements to it, then execute in order: `01_Lookup → 02_Schedule → 03_Materials → 04_Runs → 05_QualityOutput → 06_ForeignKeys`, then `FlatWire_SampleData_Schedule.sql`. `06` adds **all FK constraints last** so tables in 01–05 can be created without cross-group ordering concerns. `FlatWireRun` is created in `03_Materials` (not 04) so `Spool.SourceRunId` can reference it. All `CREATE TABLE`/FK guards are idempotent (`IF NOT EXISTS`). |
| **Core tables** | **Lookup:** `Stand`, `Drawer`, `Edger`, `SpoolConfiguration`. **Schedule:** `PassSchedule`(PK `ScheduleId` varchar), `PassScheduleComponent`. **Materials:** `FlatWireRun` (hub), `Spool` — *`Rod` dropped; rod = existing `coils` table*. **Runs:** `FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`. **Quality/Output:** `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout`. (21 total.) |
| **Common lookup tables** | Seed `Stand` (FM1 12″, FM2_S1 8″, FM2_S2 6″, FM2_S3 6″ — with `RollDiameterIn`), `Drawer` (DIE-0210…DIE-0340), `Edger` (round/square); **Alloy properties lookup** (FW-004): `Alloy, MaxReductionPerPass, SpringbackFactor, GaugeToleranceDefault, WidthToleranceDefault, SpeedRangeMinFPM, SpeedRangeMaxFPM` seeded 1100/1350/3003/5052/6061 |
| **Existing-schema changes** | **FW-001** column renames on the existing scheduling/`coils` schema (slash dual-naming): `CoilNo→Coil/BundleNo`, `SlitWidth→Slit/FlatWidth`, `IsCampaingCoil→IsCampaignCoil/Bundle`, `CoilLocation→Coil/BundleLocation`, `CoilWeight→Coil/BundleWeight`, `CoilStatus→Coil/BundleStatus`, `OutgoingCoilId→OutgoingCoil/BundleId`, `OutgoingCoilOd→OutgoingCoil/BundleOd`; new columns `OutgoingCoil/BundleWidth`, `IncomingWireDia`. **FW-002:** new coil status `INFLAT`. Both require full downstream impact analysis (high blast radius). |
| **Base stored procedures** | None ship with the DDL today (all access is EF/Dapper). Establish the SP convention (`IF EXISTS…DROP…CREATE…GRANT EXECUTE TO public`) for the handful of read-heavy procs later phases add (shift summary aggregation, gauge-trace paging). |
| **Index strategy** | Only PK-clustered + UNIQUE constraints exist today. Add the **recommended nonclustered indexes** (from the ER doc) as a Phase 1 deliverable: `FlatWireRun(LineId)`, `FlatWireRun(Status)`, `FlatWireRun(PassScheduleId)`, `RodCheckin(RunId)`, `RodCheckin(RodAlpha)`, `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`, `CoilTraceability(CoilAlpha)`, `CoilTraceability(RodAlpha)`, `SpcCheckpoint(RunId)`, `WipRejection(RunId)`, and `(RunId)` on every event table |
| **Migration scripts** | The six DDL scripts + seed are the migrations; wire `FlatWireDbContext` to the created tables; keep legacy `FlatLineSetup`/`FlatLineProcessing` for the migration window then drop after data moves to `PassScheduleComponent`/`FlatWireRunDetail` |
| **Seed data** | `FlatWire_SampleData_Schedule.sql` — 10 `PassSchedule` + 70 `PassScheduleComponent` rows spanning all lines/routes/alloys/statuses; used by the mock/stub fixtures (`R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043`) |
| **Security** | `GRANT EXECUTE`/least-privilege for the `ua_user` app account; audit columns (`CreatedBy/At`, `ModifiedBy/At`) on schedule + override tables |

**Relationship model:** `FlatWireRun` (natural key `RunId`) is the hub — 1→N to `FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `SpcCheckpoint`(→`SpcMeasurement`), `CoilOutput`(→`CoilTraceability`); 0→N (nullable `RunId`) to `WipRejection` and `RodCheckout` (pre-run cases). Genealogy chain for certs: `CoilOutput.CoilAlpha → CoilTraceability (FootageFrom..FootageTo) →` **`coils` R-series row** `→` heat/lot via the existing chemistry/`Lots` tables. All rod-alpha references (`RodCheckin.RodAlpha`, `WeldEvent.Outgoing/IncomingRodAlpha`, `RollOverride.RodAlpha`, `DieChangeEvent.RodAlpha`, `CoilTraceability.RodAlpha`, `RodCheckout.RodAlpha`, `Spool.ParentRodAlpha`) are **cross-database logical links to `coils`** — no enforced FK (G2/G17).

## Phase 1 — Real-Time / OPC Infrastructure (per §0.4)

| Piece | Deliverable |
|---|---|
| **SignalR events** | Strongly-typed `IFlatWireClient` contract; MessagePack; full event set to line groups; DTOs in `FlatWire.Domain` |
| **Event publishers** | OPC ingest (`IHostedService`) → bounded channel → cadence-driven broadcast loop (batched + decimated) |
| **Event subscribers** | `flat-wire-signalr.service` ring buffer + rAF render; typed Observables; `MockSignalRService` for stub demos |
| **Live dashboard updates** | Verified with `SimulatePLCTagPush` + mock stream (no live PLC needed); measured payload/latency budget |
| **Cache synchronisation** | PWA service worker caches pass schedule + active-run snapshot for short network drops |
| **Retry handling** | Auto-reconnect w/ exponential backoff + line-group re-join; "Reconnecting…" banner instead of blank screen |
| **Scale-out** | Stateless hub; Redis / Azure SignalR backplane is config-only if `FlatWire.API` goes multi-instance |

## Phase 1 — Testing & Deliverables

- **Tests:** Angular library builds + lints; Jest smoke tests for services/guards; xUnit boots `FlatWire.API`; stub endpoints return schema-valid fixtures; DDL runs clean on dev `FlatWireDB`; health check green.
- **Deliverables:** `flat-wire-shopfloor` library scaffold; `FlatWire` 4-project solution + stubbed controllers; `FlatWireHub` skeleton; `PLCTagService` (simulate mode); `FlatWireDbContext` + 21 tables (rod = existing `coils`) + lookups + seed + indexes; FW-001/FW-002 migrations; updated `angular.json`/`package.json`; environment/config wiring.

**Parallelism:** 1A / 1B / 1C proceed in parallel; they converge on the shared API contract (`APIContracts.md`) and the seed fixtures. This is the only cross-team barrier before feature work.
