# Flat Wire Mill — Task Breakdown and Backlog

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `05-SprintPlanAndBacklog.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** The MVP-1 shopfloor backlog — 116 stories, the descope ladder, the coverage matrix
**Status:** **Authoritative for MVP-1 shopfloor delivery** — 116 stories / 3,292 h
**Owner:** Delivery lead / programme management
**Audience:** Delivery lead, scrum team, developers, QA
**Shortcode:** `[TB]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../README.md)

---

## 7. Backlog

**116 stories / 3,292 h across four sprints and 15 phase specifications.** Every story carries a `Rate-card basis:` line, and each phase closes on its `CapacityAndEffortModel.md` §3b figure.

### 7.1 How stories are sized

The unit is **hours**, factored from [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §2's rate card. Every story carries a **`Rate-card basis:`** line so its figure is auditable rather than asserted.

**Story hours are development hours only** — the FE / BE / DB / RT / BA streams. **QA (+20% of the FE+BE+DB+RT base) and contingency (+15% of base+BA+QA) are applied at phase level, never per story**; pricing them per story double-counts. Each phase section closes with the arithmetic.

Worked example, reproducing §3's own Phase 4 derivation:

```
Σ story dev-hours (FE 60 + BE 62 + DB 28 + RT 28)  = 178   ← dev base
                                           + BA 8  = 186
QA   = 0.20 × 178                                  =  36
Cont = 0.15 × (178 + 8 + 36)                       =  33
                                           Total   = 255   ← §3b Phase 4
```

**Priority legend:** `Critical` blocks go-live · `High` required for the 30 Sep feature-complete milestone (M5) · `Medium` required for production, first onto the descope ladder · `Low` post go-live.

**Stream codes:** `FE` Angular · `BE` .NET · `DB` SQL Server · `RT` real-time/PLC · `QA` test · `BA` analysis.

---


### 7.2 The sprints

#### S0 — Platform Gate

**Dates:** Thu 30 Jul – Fri 14 Aug 2026 · **12 working days** · **96 h/person**
**Phases:** 1A Angular Foundation · 1B Backend Foundation · 1C Database Foundation
**Hours:** **1,027** · **Required FTE: 10.7**
**Goal:** stand up the platform. Every later phase assumes it exists.

**Entry criteria:** roster confirmed; `FlatWireDB` server available; `ual-angular` / `ual-api` branches cut.
**Exit criteria:** Angular library scaffolded and building; `FlatWire` four-project solution with stubbed controllers returning contracted shapes; `FlatWireHub` skeleton broadcasting simulated data; `PLCTagService` in simulate mode; `FlatWireDB` deployed with **25 tables, 33 FKs, 1 procedure, 1 trigger** and full seed; FW-001 impact audit complete.
**Demo:** scaffolded UI ↔ stubbed service ↔ created schema ↔ simulated hub, end to end.
**Gates:** **M1 (14 Aug) hard gate** · **QA0** (Jest smoke; xUnit + stub-fixture + validator suites; DDL/seed idempotency + post-run table checks) · **effort calibration checkpoint** (model §6).

> **1A, 1B and 1C run in parallel** and converge only on `04-APIContract.md` and the seed fixtures (`R00041–R00043`, `SP-00021`, `RUN-0042/0043`). 1A is not blocked by 1B/1C because it develops against the mock API and mock SignalR (`useMockData: true`); 1B ships stub endpoints first.
>
> **⚠ The model predicts this gate fails.** 1,027 h in 12 working days needs **10.7 FTE on Phase 1 alone**. 1A/1B/1C genuinely parallelise, so this is a headcount problem, not a sequencing one.

---

##### S0 · Phase 1A — Angular Foundation

**Spec:** [`phase-01a-angular-foundation.md`](Phases/phase-01a-angular-foundation.md) · **Owner:** FE · **370 h** (FE 224 · RT 44 · QA 54 · cont. 48)

---

###### FW-N03 · Angular library scaffold, routing and configuration
**Hours:** 24 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** a `flat-wire-shopfloor` Angular library scaffolded, routed and configured,
**So that** every later phase is pure feature work with no infrastructure lift.

**Acceptance Criteria:**
- [ ] Library generated via `ng generate library flat-wire-shopfloor --prefix=fw` → `projects/flat-wire-shopfloor/`; registered in `angular.json` and `tsconfig` paths
- [ ] Added to the `build:shop-floor` npm chain **for build ordering only** — no UI reuse from any library in that chain (Foundations §0.2)
- [ ] Folder structure `src/lib/{components,components/shared,services,models,guards,styles}` + module, routing and `public-api.ts` — standard Angular-library layout, **not** copied from any existing feature library
- [ ] Lazy-loaded `FLAT_WIRE_ROUTES` under `/flat-wire` with per-line routes (`/flat-wire/line/:lineId/checkin/rod`, `/flat-wire/line/FL2/checkin/spool`, `/flat-wire/line/:lineId/run/active`)
- [ ] `app-config.service` + `environment.*.ts` carry `useMockData`, API base and hub URL; `ui-log.service` wired for client telemetry
- [ ] Library builds and lints clean and does not break the `build:shop-floor` chain

**Rate-card basis:** library scaffold + routing + config + logging + utilities, priced as foundational setup (§2)
**Dependencies:** None — the `shared` foundational services already exist
**Blockers:** —

---

###### FW-130 · Shell layout and the 1280×1024 shopfloor canvas
**Hours:** 16 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As an** operator,
**I want** a consistent shell with header, navigation and an alert slot on a fixed shopfloor canvas,
**So that** every dashboard renders identically on the panel at arm's length.

**Acceptance Criteria:**
- [ ] Shell layout component: header (line context + operator + clock), sidebar nav to all dashboards, `alert-banner` slot
- [ ] Fixed **1280×1024** canvas; renders in both light and `prefers-color-scheme: dark`
- [ ] Consumes the existing semantic design-token system in `../Mockups/flat-wire-shopfloor.styles.scss` **as-is** — `--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono`
- [ ] **No `--fw-*` token appears anywhere** — that prefix is stale (**G18**); `ViewEncapsulation.None`/`:host` so tokens resolve
- [ ] Minimum text size **14px** throughout, including form controls, which do not inherit the body font

**Rate-card basis:** shared composite control 20 h, discounted to 16 h — the token system is consumed, not authored (§2, §8 *"no token migration"*)
**Dependencies:** FW-N03
**Blockers:** **G18** (stale token prefix in older source docs) · **G23** (the 1280×1024 canvas is an unconfirmed acceptance criterion — 1920×1080 means a re-layout)

---

###### FW-131 · Route guards, interceptor wiring and the error envelope
**Hours:** 12 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** security owner,
**I want** authenticated, role-gated routes reusing the existing `shared` interceptors,
**So that** no flat-wire screen is reachable without a valid token and the right role.

**Acceptance Criteria:**
- [ ] `FlatWireAuthGuard` (authenticated) and `FlatWireRoleGuard` (role-gated routes) per the Authorization Matrix in [04-APIContract.md](../Backend/APIs.md)
- [ ] Reuses `shared` `login.service` / `login-api.service` / `token-interceptor.service` (JWT bearer) — **no new interceptors**
- [ ] `correlation-id-interceptor` and `global-error-handler-api` wired
- [ ] Standardises on the `{ success, data, errors[] }` envelope; toast + inline field errors via `error-handler.service`
- [ ] Jest: guard redirects an unauthenticated user; role guard blocks an operator from a restricted route

**Rate-card basis:** shared primitive 8 h + guard/interceptor wiring 4 h (§2)
**Dependencies:** FW-N03
**Blockers:** **G6** (roles not confirmed as existing JWT roles vs new)

---

###### FW-132 · DI-swappable API client and domain models
**Hours:** 20 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** one API interface with real and mock implementations swapped by DI,
**So that** the whole UI can be built and demoed before the backend is populated.

**Acceptance Criteria:**
- [ ] `flat-wire-api.interface.ts` with `flat-wire-api-real.service.ts` (over `shared` `api-gateway.service`) and `flat-wire-api-mock.service.ts`
- [ ] DI swap driven by the `useMockData` environment flag; mock returns the 1C seed fixtures through the `{success,data,errors}` envelope
- [ ] Models authored: `rod`, `spool`, `pass-schedule`, `active-run`, `checkin`, `weld-event`, `spc-checkpoint`, `signalr-events`
- [ ] `line-context.service` (current FL1/FL2/FL3 scope) and `run-state.service` (active alpha/footage/payoff via RxJS `BehaviorSubject`s — **no NgRx**, which is not used in this repo)
- [ ] **Canonical enums defined once:** `State = 'Active' | 'Bypass' | 'Skip'` (never a boolean `IsActive`) and `EdgeType = 'Round' | 'Square'` with "Round Edge / Flat Edge" as display labels in a pipe

**Rate-card basis:** API client + two implementations + 8 models, priced as a shared composite (20 h, §2)
**Dependencies:** FW-N03; converges with FW-147 (backend enums) and FW-007 (DB `CHECK`s)
**Blockers:** **G14** (contract inconsistencies: 3- vs 4-item inspection, `R#####` vs `ROD-#####`, `FootageFt` INT vs DECIMAL)

---

###### FW-133 · Shared composite controls
**Hours:** 120 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** the six shared composite controls built once from the approved mockups,
**So that** no phase reimplements them and every screen looks like one system.

**Acceptance Criteria:**
- [ ] `pass-schedule-table` — read-only component/state table, honouring `State ∈ {Active, Bypass, Skip}`
- [ ] `payoff-weight-bar` — consumption bar with colour thresholds; used directly by Dashboard 1 and as the Payoffs card's content on Dashboard 3
- [ ] `gauge-trace-chart` — Chart.js streaming shell with target line, tolerance band, green/red points and weld markers *(live wiring, maximize and the runtime source toggle land in FW-081)*
- [ ] `tolerance-viz` — SPC marker on a band; **replaces the retired inline-SVG progress ring**
- [ ] `tab-wizard` — progressive-unlock step strip backing Dashboard 2's six steps
- [ ] `action-bar` — line-mode configurable, **intent-grouped** (Run events · Go to · Run control)
- [ ] All six built fresh from `../Mockups/*.html`; **none derived from `shop-floor-common`, `checkin-precheckin` or any existing UI library** (Foundations §0.2, decision 5)

**Rate-card basis:** 6 × shared composite control @ 20 h = 120 h (§2)
**Dependencies:** FW-130 (tokens)
**Blockers:** **G18**

---

###### FW-134 · Shared primitive controls and `alert-banner`
**Hours:** 32 h FE · **Priority:** High · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** the shared primitives built once,
**So that** field states, readouts and inspection buttons behave identically everywhere.

**Acceptance Criteria:**
- [ ] Standard `.input` with `.invalid` / `field-error` validation states
- [ ] Monospace numeric readouts for gauge/width/footage
- [ ] Pass/fail `pill-btn` and OK/NG/NA machine-inspection buttons
- [ ] `alert-banner` — raise/clear driven, auto-dismiss on `AlertCleared`
- [ ] `confirm-bar` (amber → green) and `payoff-option` selector cards
- [ ] All pinned to the **14px** floor; `input, select, textarea, button, option` set explicitly, since form controls do not inherit the body font

**Rate-card basis:** 4 × shared primitive @ 8 h = 32 h (§2)
**Dependencies:** FW-130
**Blockers:** —

---

###### FW-135 · SignalR client service
**Hours:** 24 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT

**As an** operator,
**I want** a purpose-built SignalR client that survives reconnects and never storms change detection,
**So that** live traces render at 60 fps without freezing the panel.

**Acceptance Criteria:**
- [ ] `flat-wire-signalr.service.ts` using `@microsoft/signalr` + `@microsoft/signalr-protocol-msgpack` (**MessagePack**)
- [ ] Auto-reconnect with **exponential backoff** and **line-group re-join on reconnect**; JWT via `?access_token=`
- [ ] Callbacks run **outside NgZone** into a **ring buffer**; render throttled by `requestAnimationFrame` (~60 fps); fixed window of the last ~500 points
- [ ] Typed Observables per event
- [ ] **New service — deliberately not derived from `supervisor-monitor-hub`, `CoilDataHub` or `OPCManagerHub`** (Foundations §0.4, decision 4)
- [ ] Verified: streaming a mock trace triggers no change-detection storm under OnPush

**Rate-card basis:** real-time client, priced against §0.4's stated design (24 h)
**Dependencies:** FW-N03
**Blockers:** **G10** (MessagePack dependency / deploy prereqs)

---

###### FW-136 · `MockSignalRService` and the typed event set
**Hours:** 12 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT

**As a** developer,
**I want** a timer-driven mock hub emitting the full typed event set,
**So that** Dashboard 1 and Dashboard 3 shells demo before a live hub exists.

**Acceptance Criteria:**
- [ ] `MockSignalRService` emits `GaugeReading[]`, `WidthReading[]`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`
- [ ] **Also emits `LineStatus`, `AlertRaised` and `AlertCleared`** — the three omitted from `FW-080`'s original list, and the reason command side-effects had no typed client contract
- [ ] Drives a `gauge-trace-chart` live with reconnect and group re-join simulated
- [ ] Jest: emitted events land in the ring buffer with correct types

**Rate-card basis:** hub event set + mock harness (12 h, §2)
**Dependencies:** FW-135
**Blockers:** —

---

###### FW-137 · PWA cache sync and the reconnect banner
**Hours:** 8 h RT · **Priority:** Medium · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT

**As an** operator,
**I want** the last known state cached and a clear reconnect message,
**So that** a short network drop never leaves me looking at a blank screen.

**Acceptance Criteria:**
- [ ] Service worker caches the pass-schedule and active-run snapshot for short drops
- [ ] "Reconnecting…" banner replaces a blank screen; cached last-known state remains visible
- [ ] Banner clears automatically on successful re-join

**Rate-card basis:** shared primitive 8 h (§2)
**Dependencies:** FW-135
**Blockers:** —

---

**Phase 1A reconciliation** — FE `24+16+12+20+120+32 = 224` · RT `24+12+8 = 44` · base **268** → QA `0.20 × 268 = 54` → Cont `0.15 × (268+54) = 48` → **370 h** ✓ (§3b)

---

##### S0 · Phase 1B — Backend Foundation

**Spec:** [`phase-01b-backend-foundation.md`](Phases/phase-01b-backend-foundation.md) · **Owner:** BE + RT · **442 h** (BE 208 · RT 112 · QA 64 · cont. 58)

> **The largest single layer in the plan** — needs 4.6 FTE on its own. Template is `API/Domain/CoilCheckin` (controller, MediatR command, `Program.cs`, `.csproj`, NuGet set). **`SlitterInterface` is explicitly NOT a reference** (Foundations §0.2, decision 5).

---

###### FW-N04 · `FlatWire` solution and four-project Clean Architecture skeleton
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** the `FlatWire` microservice solution created to the `CoilCheckin` pattern,
**So that** every later phase adds commands and queries only.

**Acceptance Criteria:**
- [ ] `API/Domain/FlatWire/` with `FlatWire.sln` and four projects — `FlatWire.API` / `.Application` / `.Domain` / `.Infrastructure`
- [ ] Project references: `API → Application, Domain, Infrastructure`; `Application → Domain`; `Infrastructure → Domain`
- [ ] `.csproj` and NuGet set copied from `CoilCheckin`
- [ ] `FlatWire.sln` builds; `FlatWire.API` boots under Development

**Rate-card basis:** solution scaffold from an existing template (16 h, §2)
**Dependencies:** None
**Blockers:** —

---

###### FW-138 · Thirteen thin controllers over `UAController`
**Hours:** 52 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** every controller present and returning the standard envelope from day one,
**So that** the Angular library can build against the real service before any handler exists.

**Acceptance Criteria:**
- [ ] All thirteen exist and extend `UAController`: `LinesController`, `PassScheduleController`, `RodReceivingController`, `CheckInController`, `RunController`, `SpcController`, `WeldEventController`, `RollAdjustController`, `DieChangeController`, `CheckOutController`, `WipRejectionController`, `CoilController`, `ShiftSummaryController`
- [ ] Each returns the `{Data, Success, Errors}` envelope
- [ ] **`[Authorize]` on every controller and every endpoint** — no bare `ControllerBase`, no unprotected route
- [ ] Stub endpoints return schema-valid fixtures for the seed alphas, per `04-APIContract.md` shapes
- [ ] xUnit boots the API and asserts every stub's contract shape

**Rate-card basis:** 13 controllers @ 4 h = 52 h (§2, query-endpoint rate for scaffold + stub)
**Dependencies:** FW-N04
**Blockers:** —

> `PassScheduleController` and `ShiftSummaryController` are scaffolded here but their handlers are **MVP-2**. They exist so the contract surface is complete and the Angular client has a stable base URL set.

---

###### FW-139 · MediatR registration and pipeline behaviours
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** MediatR wired with validation and logging behaviours,
**So that** every command gets cross-cutting concerns without repeating them.

**Acceptance Criteria:**
- [ ] `Commands/` and `Queries/` folders per `04-APIContract.md`
- [ ] MediatR registered in `Program.cs` (copied from `CoilCheckin.API/Program.cs`)
- [ ] Pipeline behaviours for validation and structured logging
- [ ] A sample command round-trips controller → MediatR → handler → envelope

**Rate-card basis:** cross-cutting infrastructure (16 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-140 · DI registration and the stub/real service swap
**Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** interface-driven services swappable between stub and real by configuration,
**So that** 1A can integrate before the database is populated.

**Acceptance Criteria:**
- [ ] `Program.cs` service registration; every service behind an interface
- [ ] `useStub` / environment swap of stub vs real implementations, as in `CoilCheckin`
- [ ] With `useStub` on, the API serves schema-valid fixtures end to end

**Rate-card basis:** DI + configuration swap (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-141 · Repository layer
**Hours:** 20 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** repositories behind interfaces for each aggregate,
**So that** handlers never touch a connection directly.

**Acceptance Criteria:**
- [ ] `FlatWire.Infrastructure/Repositories/` with `PassScheduleRepository`, `RodRepository`, `RunRepository`, `CoilRepository` and siblings, each behind an interface
- [ ] `RodRepository` reads the shared `coils` table (cross-database, unenforced link)
- [ ] Unit tests cover each repository against the seeded fixtures

**Rate-card basis:** 5 repositories @ 4 h = 20 h (§2, table rate covers repository)
**Dependencies:** FW-N04, FW-006
**Blockers:** **G17** (rod→`coils` multiplies cross-DB logical FKs)

---

###### FW-142 · Dapper/EF data access and `FlatWireDbContext`
**Hours:** 24 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** the mixed Dapper/EF convention wired against `FlatWireDB`,
**So that** high-volume reads stay fast and entity writes stay typed.

**Acceptance Criteria:**
- [ ] **Dapper** for high-volume reads — gauge trace, list grids, report aggregations
- [ ] **EF Core `FlatWireDbContext`** for entity writes, mapped to all **24 MVP-1 tables** (`Rod` **is** among them per `D-04`)
- [ ] A smoke insert→select round-trips through EF against every table
- [ ] **The three `PassSchedule*` tables are not mapped** — they are owned outside MVP-1

**Rate-card basis:** context + mapping across 24 tables, priced as a non-trivial service (24 h, §2)
**Dependencies:** FW-N04; converges with FW-006 / FW-007
**Blockers:** —

---

###### FW-143 · Serilog structured logging and the audit log
**Hours:** 12 h BE · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** compliance owner,
**I want** every PLC push and schedule override written to an audit log,
**So that** a machine configuration can be reconstructed after the fact.

**Acceptance Criteria:**
- [ ] Serilog wired to the inherited UAL configuration; structured logs throughout
- [ ] **Audit log** entries for PLC pushes (tag, value, operator, result) and pass-schedule overrides
- [ ] Audit entries are queryable by run and by operator

**Rate-card basis:** logging + audit sink (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-144 · Configuration binding
**Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** deployer,
**I want** every environment-specific value bound from configuration,
**So that** no tag path, connection string or cadence is compiled in.

**Acceptance Criteria:**
- [ ] `appsettings.{Environment}.json` carries the **`FlatWireDB`** connection string, JWT settings and SignalR settings (MessagePack, keep-alive/timeout, cadence)
- [ ] **OPC tag-path map is config-driven, not hardcoded** — the map's contents are owned by [`PLCTagSpecification.md`](../../RequirementDocuments/PLCTagSpecification.md); this story binds it, it does not author it
- [ ] `SimulatePLCTagPush` is a configuration flag, switchable without a rebuild

**Rate-card basis:** configuration binding across four concern groups (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** **`PLC-Q05`** (the measure segment of every tag path is ours, not the controller's — **G33**)

---

###### FW-145 · JWT authentication and role authorization policies
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** security owner,
**I want** role policies matching the Authorization Matrix,
**So that** each endpoint admits only the roles that should reach it.

**Acceptance Criteria:**
- [ ] JWT bearer authentication inherited from the UAL configuration
- [ ] Hub authentication via `?access_token=` query parameter
- [ ] Role policies for Operator / Operations Manager / Maintenance / Supervisor / Admin, matching `04-APIContract.md`'s matrix
- [ ] Authorization tests prove an operator cannot reach an Ops-Manager-only endpoint

**Rate-card basis:** auth + five role policies (16 h, §2)
**Dependencies:** FW-N04
**Blockers:** **G6** (roles not confirmed as existing JWT roles vs new)

---

###### FW-146 · Global exception middleware and the response envelope
**Hours:** 8 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** client developer,
**I want** every failure mapped to a predictable status and envelope,
**So that** the UI can branch on a contract rather than on a message string.

**Acceptance Criteria:**
- [ ] Global exception middleware maps to `400` validation, `404` not found, `409` conflict, `422` unprocessable, `500` PLC/server
- [ ] Every response — success or failure — uses the `{Data, Success, Errors}` envelope
- [ ] Tests assert each status path

**Rate-card basis:** shared primitive (8 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-147 · FluentValidation and the canonical cross-layer enums
**Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** command validation and one canonical enum definition per concept,
**So that** the Angular model, the backend enum and the database `CHECK` cannot drift.

**Acceptance Criteria:**
- [ ] FluentValidation per command; sample rules implemented — `FM2_S3` must be Active; FL3 requires Hybrid; `PassScheduleComponent.State ∈ {Active, Bypass, Skip}`
- [ ] **`CheckpointType` is five-valued** — `{PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun}`. `RollAdjustTrigger` was missing and is required by `/rolloverride`'s side-effect
- [ ] **`EdgeType ∈ {Round, Square}`** — one vocabulary, not three
- [ ] **`State` is an enum, never a boolean `IsActive`**
- [ ] All three match FW-132 (Angular models) and FW-007 (DB `CHECK`s); validator unit tests cover each

**Rate-card basis:** validation layer + enum definitions (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

> **`RollAdjustTrigger` is load-bearing.** Phase 8 wires the FL2 roll-adjust button against it; if 1C ships a four-value `CHECK`, that button fails at write time. Verify all three layers agree before S2.

---

###### FW-148 · Health checks
**Hours:** 8 h BE · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As an** operations engineer,
**I want** a health endpoint covering the database and OPC reachability,
**So that** a failing dependency is visible before an operator finds it.

**Acceptance Criteria:**
- [ ] ASP.NET Core health checks at `/health` covering DB and OPC reachability
- [ ] `/health` green in Development, with OPC reporting simulated-healthy
- [ ] Unhealthy dependency returns a non-200 and names the failing check

**Rate-card basis:** shared primitive (8 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-080 · `FlatWireHub` — strongly-typed, MessagePack, line groups
**Hours:** 32 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As an** operator,
**I want** a purpose-built hub streaming per-line telemetry,
**So that** three lines can be watched live without a page refresh.

**Acceptance Criteria:**
- [ ] `FlatWire.API/Hubs/FlatWireHub.cs` as a **strongly-typed `Hub<IFlatWireClient>`**
- [ ] **MessagePack** via `AddSignalR().AddMessagePackProtocol()`; WebSockets-first with `SkipNegotiation` where topology allows
- [ ] `[Authorize]`; `JoinLineGroup` / `LeaveLineGroup` over groups `FL1Data` / `FL2Data` / `FL3Data`
- [ ] **Hosted only inside `FlatWire.API`** — the shared `Notification` service is not extended, and `CoilDataHub` / `OPCManagerHub` / `supervisor-monitor-hub` are **not** templates (Foundations §0.4, decision 4)
- [ ] Stateless hub; Redis / Azure SignalR backplane is a **config-only** path if the API goes multi-instance
- [ ] Smoke test: a client joining `FL1Data` receives simulated batched `GaugeReading[]` at the configured cadence, and re-joins its group after a reconnect

**Rate-card basis:** hub infrastructure priced against §0.4's stated design (32 h)
**Dependencies:** FW-N04, FW-145
**Blockers:** **G10** (deploy prereqs — IIS WebSockets feature) · **G9 / OI-34** (NFRs undefined; the load test in FW-156 has no pass criteria)

---

###### FW-149 · `IFlatWireClient` typed event contract
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As a** developer,
**I want** one typed contract covering every event the backend broadcasts,
**So that** a command side-effect cannot broadcast an event the client has no type for.

**Acceptance Criteria:**
- [ ] `IFlatWireClient` in `FlatWire.Domain` carries the **full** set: `GaugeReading(GaugeReading[])`, `WidthReading(WidthReading[])`, `SpeedFPM`, `PayoffWeight`, **`PayoffStateChanged`**, `FootageCounter`, `ComponentStatus`, **`LineStatus`, `AlertRaised`, `AlertCleared`**
- [ ] SCADA markers included: `WeldJoinEvent`, `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint`, `RodCheckoutEvent`
- [ ] Matches FW-136's client-side typed set exactly
- [ ] **Naming:** the aggregate, table, endpoint and story all say **`WeldEvent`**; `WeldJoinEvent` survives only as the SignalR method name and is documented as such

**Rate-card basis:** 2 × hub event group @ 8 h = 16 h (§2)
**Dependencies:** FW-080
**Blockers:** —

---

###### FW-N05 · OPC ingest hosted service and bounded channel
**Hours:** 32 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As an** operator,
**I want** PLC tag values ingested continuously without the service falling behind,
**So that** a slow consumer degrades resolution rather than crashing the pipeline.

**Acceptance Criteria:**
- [ ] `IHostedService` in `FlatWire.Infrastructure` reads FL1/FL2/FL3 tags via the existing `OPCConnection` domain
- [ ] Readings land in a **bounded `System.Threading.Channels.Channel<Reading>`** with **drop-oldest / coalesce** on overflow — backpressure degrades resolution, never memory
- [ ] Tag paths come from configuration (FW-144), never from code
- [ ] Integration test: a burst faster than the drain rate coalesces rather than growing unbounded

**Rate-card basis:** OPC ingest priced against §0.4's backpressure-safe design (32 h)
**Dependencies:** FW-144, FW-080
**Blockers:** **`PLC-Q05`** / **G33** · **G29** (no edger tag path exists on any line) · **G32** (FM2 station names are ours, not the controller's)

---

###### FW-150 · Cadence-driven broadcast loop
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As an** operator,
**I want** telemetry batched at a fixed cadence and rare events sent immediately,
**So that** the panel stays responsive under a full three-line load.

**Acceptance Criteria:**
- [ ] Drains the channel on a **fixed cadence (default ~100 ms / 10 Hz)**, sending **batched arrays** per line group
- [ ] Hot numeric channels decimated to cadence; `ComponentStatus` / `LineStatus` sent **on change only**
- [ ] **Rare domain events sent immediately and unbatched** — they must not enter the 10 Hz batch
- [ ] **FL2 standalone suppresses batched gauge/width** and broadcasts `null`; the historical profile is a REST query
- [ ] Cadence is configuration-driven (FW-144)

**Rate-card basis:** 2 × hub event group @ 8 h = 16 h (§2)
**Dependencies:** FW-N05, FW-149
**Blockers:** **G9 / OI-34** (AGC sample rate undefined)

---

###### FW-151 · `PLCTagService` skeleton and `SimulatePLCTagPush`
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As a** developer,
**I want** the PLC write surface built with a simulate mode from the start,
**So that** every check-in phase can be developed and demoed before commissioning.

**Acceptance Criteria:**
- [ ] `FlatWire.Infrastructure/Services/PLCTagService.cs` with `PushPassSchedule(...)` and `ClearPayoffTags(...)`, batch write
- [ ] **`SimulatePLCTagPush` dev mode** logs an audit entry instead of writing, and is switchable by configuration
- [ ] ⚠ **OPC writes are not transactional.** Failure recovery is modelled as **compensating re-clears**, and the code and comments say so — **the word "rollback" does not appear** (**G2 / G16**)
- [ ] The saga/compensation boundary for a cross-database check-in is documented in the service

**Rate-card basis:** PLC tag group push + compensating clear @ 16 h (§2)
**Dependencies:** FW-144
**Blockers:** **G2 / OI-39** (cross-DB check-in recovery undecided — saga/outbox vs `INFLAT` mirror; carries the 24–64 h Phase-4 reserve)

> **This is the service; `FW-082` is its use at check-in.** Splitting them keeps `FW-082`'s cited meaning — *"PLC tag push on check-in ack"* — intact while giving the S0 scaffold its own card.

---

**Phase 1B reconciliation** — BE `16+52+16+12+20+24+12+12+16+8+12+8 = 208` · RT `32+16+32+16+16 = 112` · base **320** → QA `0.20 × 320 = 64` → Cont `0.15 × (320+64) = 58` → **442 h** ✓ (§3b)

---

##### S0 · Phase 1C — Database Foundation

**Spec:** [`phase-01c-database-foundation.md`](Phases/phase-01c-database-foundation.md) · **Owner:** DB · **215 h** (DB 156 · QA 31 · cont. 28)

> **The DDL already exists** in [`../DBChanges/Schema/SQL/`](../../DBChanges/Schema/SQL/). This layer **retargets, hardens, seeds and wires** it. Target is a new standalone **`FlatWireDB`**, not `united_db`.
>
> **`Rod` is retained** — master-spec `D-04` supersedes Foundations decision 3. **Anything saying "`Rod` is dropped" or "21–22 tables" is stale** (**G12**, closed 11 Aug 2026).

---

###### FW-001 · Shared-schema column renames and new columns
**Hours:** 56 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** the scheduling schema renamed to the slash-dual flat-wire convention behind a completed impact audit,
**So that** flat wire material fits the existing schema without ambiguity and nothing downstream silently breaks.

**Acceptance Criteria:**
- [ ] Renames applied: `CoilNo → Coil/BundleNo` · `SlitWidth → Slit/FlatWidth` · `IsCampaingCoil → IsCampaignCoil/Bundle` *(typo corrected)* · `CoilLocation → Coil/BundleLocation` · `CoilWeight → Coil/BundleWeight` · `CoilStatus → Coil/BundleStatus` · `OutgoingCoilId → OutgoingCoil/BundleId` · `OutgoingCoilOd → OutgoingCoil/BundleOd`
- [ ] New columns added: `OutgoingCoil/BundleWidth`, `IncomingWireDia`
- [ ] **A full SP / view / report impact audit across `united_db` and the legacy `ual-dot-net` tier completes BEFORE the migration runs** — this is a discrete 40 h line item, not a rounding
- [ ] All existing stored procedures, views and API queries updated to the new names
- [ ] No regression in existing reports or screens; regression suite re-run in Phase 14 (FW-201)

**Rate-card basis:** rename migration 16 h + **FW-001 impact audit 40 h** (discrete item, §2) = 56 h
**Dependencies:** None
**Blockers:** —

> **Highest blast radius in the plan.** These land on the **shared** `coils`/scheduling schema, which the legacy applications and existing reports also read. `phase-01c` itself says *"front-load the impact audit."*

---

###### FW-002 · `INFLAT` coil status
**Hours:** 4 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** scheduling operator,
**I want** a coil status marking material actively on a flattening line,
**So that** in-process flat wire is distinctly tracked.

**Acceptance Criteria:**
- [ ] `INFLAT` added to the coil status reference table
- [ ] **Set at check-in only.** The pre-check-in / staging path must **not** write `coils.coil_status` — narrowed by the 30 Jul client answer
- [ ] Cleared on rod checkout, run completion or WIP rejection
- [ ] Appears in every status dropdown and filter list where coil status is shown
- [ ] Existing status transition rules are unbroken

**Rate-card basis:** reference-data change (4 h, §2)
**Dependencies:** FW-001
**Blockers:** —

---

###### FW-152 · `FlatWireDB` creation, ordered DDL runner, indexes and grants
**Hours:** 12 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** database owner,
**I want** the whole schema deployable by one idempotent, ordered script,
**So that** any environment can be rebuilt from scratch and re-run safely.

**Acceptance Criteria:**
- [ ] `FlatWireDB` created; every `USE [united_db]` header retargeted
- [ ] Execution order preserved: `00` database → `01` Lookup → `03` Materials → `04` Runs → `05` Quality/Output → `06` **all FKs last** → `07` Indexes → `08` Programmability. **`02_Schedule` is absent** — the pass schedule is owned outside MVP-1
- [ ] Every `CREATE` and FK guarded (`IF NOT EXISTS`); `FlatWire_DDL_RunAll.sql` is **idempotent and re-runnable**
- [ ] All ER-doc recommended nonclustered indexes present, including `(RunId)` on every child/event table
- [ ] `GRANT EXECUTE` / least-privilege for `ua_user`; audit columns on override tables
- [ ] Post-run check: **25 tables · 33 FKs · 1 procedure (`sp_GetGaugeTrace`) · 1 trigger (`trg_CoilTraceability_NoOverlap`)**
- [ ] **`sp_ShiftSummary` is MVP-2's and must not be created, dropped or granted from this scope**

**Rate-card basis:** database creation + ordered runner + index strategy + security (12 h, §2)
**Dependencies:** None
**Blockers:** —

---

###### FW-005 · Lookup group tables and seed
**Hours:** 16 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** the lookup tables created and seeded with fixed identity values,
**So that** the sample data FK-resolves and the die change has a catalogue to validate against.

**Acceptance Criteria:**
- [ ] Tables created: `Stand`, `Drawer`, `Edger`, `SpoolConfiguration`, `PayoffPosition`
- [ ] `FlatWire_SampleData_Lookup.sql` authored — it was **missing**, and the schedule seed depended on it
- [ ] `Stand` seeded with **four rows carrying `RollDiameterIn`**: FM1 12.000 · **`FM2_S1` 8.000 · `FM2_S2` 6.000 · `FM2_S3` 6.000**. Identifiers are **position-only**; diameter is data
- [ ] `Drawer` seeded with the **13 size rows** (`DIE-0210`…`DIE-0340`) carrying `LastGrindingFeet` and `TotalFeetAllowed` — this is what MVP-1's die change validates against
- [ ] `Edger` seeded `Round` / `Square`; `PayoffPosition` seeded with its **3 pinned rows**
- [ ] Fixed IDENTITY values: `Stand.Id 1–4`, `Drawer.Id 1–13`, `Edger.Id 1–2`
- [ ] **No fourth FM2 stand.** `FM2_6inS3` was withdrawn as never-existent — it never had a tag path or a seed row (`D-26`)

**Rate-card basis:** 4 tables @ 4 h = 16 h (§2); `AlloyProperty` is costed separately in FW-004
**Dependencies:** FW-152
**Blockers:** **`PLC-Q04`** / **G32** (FM2 PLC station names unconfirmed)

---

###### FW-004 · `AlloyProperty` lookup and seed
**Hours:** 8 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** process engineer,
**I want** per-alloy properties and tolerance bands held as reference data,
**So that** tolerances are maintainable without a code change.

**Acceptance Criteria:**
- [ ] `AlloyProperty` created with `Alloy`, `MaxReductionPerPass`, `SpringbackFactor`, `SpeedRangeMinFPM`, `SpeedRangeMaxFPM`
- [ ] **Four min/max tolerance pairs, not two single ± values** — `GaugeTolerance{Minus,Plus}In`, `WidthTolerance{Minus,Plus}In`, `RodDiameterTolerance{Minus,Plus}In`, `RodOvalityMaxIn`. Bands are offsets about nominal and **may be asymmetric**; ovality takes an upper limit only
- [ ] Seeded for 1100 / 1350 / 3003 / 5052 / 6061
- [ ] ⛔ **`RodDiameterTolerance{Minus,Plus}In` and `RodOvalityMaxIn` are NULL on purpose** — the values are owed by client e-mail. **Do not populate them from the Dashboard 2A mock map**, which is explicitly labelled mock data
- [ ] The `0.003"` ovality limit lives in this table, **never hard-coded** — it is per-alloy reference data, not a constant

**Rate-card basis:** 1 table + seed authoring (8 h, §2)
**Dependencies:** FW-152
**Blockers:** ⛔ **OQ-22** (the four tolerance values are owed by e-mail — **this also blocks `CHK007` in Phase 4 at both stations**)

> **The title in earlier versions read *"for pass schedule algorithm"* and misled.** This is **MVP-1 reference data**; only its consumer, `FW-013`, is MVP-2. Do not sweep it out on the title.

---

###### FW-006 · Materials group tables
**Hours:** 12 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** the material master tables created,
**So that** rod, run and spool records have somewhere to live and rod-alpha FKs can be enforced.

**Acceptance Criteria:**
- [ ] `Rod` created — a `FlatWireDB`-local master **mirroring** the shared `coils` record, with **enforced** rod-alpha FKs. `coils` remains the source of truth for the rod *lifecycle*; the mirror is what makes the FKs enforceable (`D-04`)
- [ ] `FlatWireRun` created — the hub table, so `Spool.SourceRunId` can reference it
- [ ] `Spool` created
- [ ] Indexes: `FlatWireRun(LineId)`, `(Status)`, `(PassScheduleId)`, `Spool(SourceRunId)`, `Spool(ParentRodAlpha)`
- [ ] **`PassScheduleId` carries no local FK** — it is a documented external reference on `FlatWireRun`, in the same class as `PlanId` and `SkidId`. Seeded values like `PS-1100-FL1-001` are **external identifiers, not orphans**

**Rate-card basis:** 3 tables @ 4 h = 12 h (§2)
**Dependencies:** FW-152
**Blockers:** **G17** (cross-DB logical FKs) · open decision: whether `PassScheduleId` should stay `NOT NULL`, which asserts an existence MVP-1 cannot verify — `phase-01c` asks for this to be **decided once and recorded there**, not per table

> **Spans scopes.** This story previously listed `PassSchedule` among its "core entity tables", but the three `PassSchedule*` tables are **MVP-2-owned**. They are **not created here**.

---

###### FW-007 · Runs and Quality/Output group tables
**Hours:** 48 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** every event and output table created with its constraints enforced in the database,
**So that** business rules stated in prose cannot be violated by application code.

**Acceptance Criteria:**
- [ ] **Runs (`04`):** `FlatWireRunDetail`, `RodCheckin`, `RodStaging`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`**
- [ ] **Quality/Output (`05`):** `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout`
- [ ] **`RunReading` created** — persists raw AGC gauge/width/speed readings, which nothing did before (**G3**). `RunId`, `FootageFt DECIMAL(10,2)`, `GaugeIn DECIMAL(8,4)`, `WidthIn`, `SpeedFPM`, `InSpec`, `ReadingTs`; index `(RunId, FootageFt)`; retention/rollup policy defined
- [ ] **Constraints enforced in DDL, not prose:** `CoilTraceability` non-overlapping footage ranges per coil (trigger); `RunPauseEvent.Notes` required when `ReasonCategory='Other'`; `WeldEvent` fail reason required when `WeldQuality='Fail'`; `CK_RodCheckout_ModeP` and `CK_RodCheckout_ModeB` per-mode field rules
- [ ] **`RodCheckout.NewRodStatus` carries a `CHECK`** — `IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')`; every other status column already had one
- [ ] **`CheckpointType` `CHECK` is five-valued** and includes `'RollAdjustTrigger'` — mirrors FW-147
- [ ] **`RodStaging` invariants:** `Blocked` is a **derived** bay state (`Status='Staged'` + any inspection column `='Fail'`), **never a fourth `Status` value**; `IsWelded` is a **flag on a `Staged` row**, not a status. Carries `UnstageKind` and `WipRejectionId` (FK → `WipRejection`) so a rejection can release a blocked bay
- [ ] **`RodCheckout` carries `WasWelded`, `ApprovedBy`, `ApprovedAt`, `OverrideReason`** — it had no approval columns at all, so two decided rules had nowhere to write (**G24**)
- [ ] **Precision: the DDL scaled types are authoritative** — weights `DECIMAL(8,2)`, gauges `DECIMAL(8,4)`, footage `(10,2)`. **Do not regenerate DDL from the schema `.md` files**, which say bare `decimal` (= `decimal(18,0)`) and would drop precision

**Rate-card basis:** 12 tables @ 4 h = 48 h (§2). **⚠ 15 tables are built here; 12 are costed** — §8 records that 1C is costed against 22 tables against a build of 25, and is therefore **understated by ~17 h all-in**. The figure above is the published one, not the rate-card sum
**Dependencies:** FW-152, FW-006
**Blockers:** **G21** (`UX_RodStaging_Bay` does not enforce one-rod-per-bay across FL1/FL3 — **blocks the Phase-4 schema freeze**) · **G14** (`FootageFt` INT vs DECIMAL) · **G34** (wire break has a decided flow and still no persistence target)

---

**Phase 1C reconciliation** — DB `56+4+12+16+8+12+48 = 156` → QA `0.20 × 156 = 31` → Cont `0.15 × (156+31) = 28` → **215 h** ✓ (§3b)

**S0 total** — `370 + 442 + 215 = **1,027 h**` ✓ · 12 working days · **10.7 FTE**

---

#### S1 — Real-Time Backbone

**Dates:** Mon 24 Aug – Fri 4 Sep 2026 · **10 working days** · **80 h/person**
**Phases:** 3 Line Status Board & Real-Time Backbone *(whole)*
**Hours:** **190** · **Required FTE: 2.4**
**Goal:** the live backbone. First end-to-end slice: OPC → `FlatWireHub` → Dashboard 1.

**Entry criteria:** S0 exit met — hub skeleton and OPC poller exist; scheduling data available upstream.
**Exit criteria:** Dashboard 1 renders live line-state, gauge/width, payoff, speed and run-time via SignalR (real or simulated); alert rules firing; hub load test executed.
**Demo:** a supervisor watches three lines update live from the simulated PLC feed, with alerts raising and clearing.
**Gates:** **M2 (6 Sep)** Dashboard 1 live · **QA1 (6 Sep)**.

> **The single most consequential resequencing in the plan.** The real-time backbone (`FW-080`/`FW-081`) previously sat in the last sprint, **after** the dashboards that depend on it. It is now built before them. Anything still sequencing from the old five-sprint model will build the consumers first.
>
> **The carry-over week (17–21 Aug) precedes this sprint** and carries Phase-1 completion only. It is the plan's entire recovery budget — 200 person-hours at 5 FTE. Spending it on new scope removes the only slack there is.

---

##### S1 · Phase 3 — Line Status Board & Real-Time Backbone

**Spec:** [`phase-03-line-status-board-realtime-backbone.md`](Phases/phase-03-line-status-board-realtime-backbone.md) · **Owning specification:** [`LineStatusOverview.md`](../../RequirementDocuments/LineStatusOverview.md) (DB1) · **Owner:** RT + FE · **190 h** (FE 64 · BE 16 · DB 4 · RT 40 · QA 41 · cont. 25)

---

###### FW-060 · Dashboard 1 — Line Status Overview
**Hours:** 44 h FE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** FE

**As a** supervisor,
**I want** a persistent board showing all three lines live,
**So that** I have floor-wide situational awareness without walking the floor.

**Acceptance Criteria:**
- [ ] `dashboard-1-line-status` built from `../Mockups/dashboard_1_line_status.html`
- [ ] `line-status-panel` per line showing status badge, order/alpha, alloy/route, speed, gauge/width, payoff weight bar + Payoff-2 status, run time
- [ ] **Gauge/width live on FL1/FL3; blank for FL2 idle** — FL2 standalone broadcasts `null` and the panel must show an explicit empty state, never a flat line at target
- [ ] Subscribes to `lineStatus$ / gaugeReading$ / widthReading$ / speedFpm$ / payoffWeight$ / alertRaised$ / alertCleared$`
- [ ] Clicking a panel routes to that line's Dashboard 3 (running) or Dashboard 2/5 (idle)
- [ ] **No header drill-downs to Dashboard 13 / 14** — both descoped 4 Aug 2026, `FR-425` withdrawn
- [ ] Reuses `payoff-weight-bar` and `alert-banner` from FW-133 / FW-134 — not reimplemented

**Rate-card basis:** new dashboard 24 h + `line-status-panel` composite 20 h = 44 h (§2)
**Dependencies:** FW-133, FW-134, FW-135, FW-154
**Blockers:** **GAP-8** (show pass-schedule id on DB1 — open, low)

---

###### FW-153 · Alert chips, reconnect banner and cached-state fallback
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** FE

**As a** supervisor,
**I want** alerts visible on the board and a clear message when the feed drops,
**So that** I can tell the difference between "nothing wrong" and "not connected".

**Acceptance Criteria:**
- [ ] Alert chips render below the panels for each of the five rules, with severity styling
- [ ] Alerts auto-dismiss on `AlertCleared`
- [ ] SignalR drop → "Reconnecting…" banner with cached last-known state; **never a blank screen**
- [ ] Cached state is visibly marked as stale rather than presented as live

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-134, FW-137, FW-N06
**Blockers:** —

---

###### FW-154 · `GET /lines/status` and `LineStatusService`
**Hours:** 16 h BE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** BE

**As a** client developer,
**I want** a snapshot endpoint for page load,
**So that** the board renders immediately and then goes live rather than starting empty.

**Acceptance Criteria:**
- [ ] `LinesController` `GET /lines/status` returns `LinesStatusResponse` / `LineStatusDto` / `PayoffStatusDto` / `ActiveAlertDto`
- [ ] `PayoffStatusDto` carries bay **occupancy** (`state`, `rodAlpha`) alongside live weight
- [ ] `LineStatusService` composes scheduling data + run state + latest OPC readings
- [ ] Any authenticated role may read
- [ ] Contract test against `04-APIContract.md`

**Rate-card basis:** query endpoint 4 h + `LineStatusService` non-trivial service 12 h = 16 h (§2)
**Dependencies:** FW-138, FW-141
**Blockers:** —

---

###### FW-155 · `FlatWireRun(LineId, Status)` index
**Hours:** 4 h DB · **Priority:** Medium · **Sprint:** S1 · **Phase:** 3 · **Stream:** DB

**As a** database owner,
**I want** the line-board query covered by an index,
**So that** a board polled by every supervisor terminal does not table-scan the hub table.

**Acceptance Criteria:**
- [ ] Nonclustered index on `FlatWireRun(LineId, Status)` created in `07_Indexes`
- [ ] `GET /lines/status` execution plan uses it
- [ ] Idempotent guard, consistent with FW-152's runner

**Rate-card basis:** index as part of the table rate (4 h, §2)
**Dependencies:** FW-006
**Blockers:** —

---

###### FW-N06 · Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle
**Hours:** 40 h RT · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** RT

**As a** supervisor,
**I want** the system to raise and clear alerts on defined thresholds,
**So that** a developing problem reaches me before it stops the line.

**Acceptance Criteria:**
- [ ] Five rules implemented: Payoff1 < 3,000 lb → **Warning** · gauge outside ±tolerance → **Warning** · component fault → **Critical** · active WIP rejection → **Warning** · **Payoff2 not loaded AND Payoff1 < 2,000 lb → Critical**
- [ ] `AlertRaised` and `AlertCleared` broadcast as **rare domain events — immediate and unbatched**, never inside the 10 Hz telemetry batch
- [ ] **"Payoff2 not loaded" reads `RodStaging`** — a `Staged` row on `(LineId, PayoffPosition)` means loaded. `PayoffWeight` alone **cannot** distinguish an empty bay from a sensor reading zero
- [ ] Consumes `PayoffStateChanged` (Phase 4) to keep the evaluation live
- [ ] Unit tests cover each threshold's raise and clear edges

**Rate-card basis:** 5 × hub event / rule @ 8 h = 40 h (§2)
**Dependencies:** FW-149, FW-150
**Blockers:** **⚠ Until Phase 4 delivers `RodStaging`, rule 5 cannot be evaluated at all** — nothing else records bay occupancy. Phase 4 back-feeds this phase · **OI-28** (alerts unbacked)

---

###### FW-156 · Hub load test
**Hours:** 16 h QA · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** QA

**As an** architect,
**I want** the hub load-tested at realistic client counts,
**So that** a real-time design decision is validated before eight phases depend on it.

**Acceptance Criteria:**
- [ ] Load test executed: N clients × 3 lines × configured cadence
- [ ] Measures message latency, dropped/coalesced reading counts, and server CPU/memory under sustained load
- [ ] Results recorded against the run, whatever they are

**Rate-card basis:** hub load test — **discrete item, 16 h** (§2), sitting on top of the phase's 20% QA uplift
**Dependencies:** FW-080, FW-150
**Blockers:** ⚠ **G9 / OI-34 — this test has no pass criteria.** The NFRs it would be judged against (AGC sample rate, concurrent client count, latency budget, `RunReading` retention) **do not exist**. Any resulting real-time rework is **not** in the 3,292 h

---

**Phase 3 reconciliation** — FE `44+20 = 64` · BE 16 · DB 4 · RT 40 · base **124** → QA `(0.20 × 124 = 25) + 16 load test = 41` → Cont `0.15 × (124+41) = 25` → **190 h** ✓ (§3b)

**S1 total** — **190 h** ✓ · 10 working days · **2.4 FTE**

---

#### S2 — The Full FL1 Operator Journey

**Dates:** Mon 7 Sep – Fri 18 Sep 2026 · **9 working days** *(Labor Day Mon 7 Sep excluded)* · **72 h/person**
**Phases:** 4 Rod Check-In · 5 Active Run Monitoring · 6 In-Run Events · 7 WIP/Checkout · 8 FL2 Spool Check-In *(starts)*
**Hours:** **971** · **Required FTE: 13.5**
**Goal:** stage a rod, check it in, push PLC tags, watch it run, record every in-run event, and take both exception off-ramps.

**Entry criteria:** S1 exit met; an Active pass schedule available from the **externally-owned** pass-schedule track; upstream rod receiving and planning/scheduling supplying material and jobs.
**Exit criteria:** rod staged, checked in, PLC tags pushed (simulated), live trace running, every in-run event recorded, both exception off-ramps working.
**Demo:** stage → check in → run → weld → SPC → die change → pause → WIP reject → check out.
**Gates:** **M3 (13 Sep)** first full FL1 slice live · **QA2 (13 Sep)** check-in rollback + real-time integration on staging.

> **The sequential chain `4→5→6→7` must fit inside 9 working days**, alongside Phase 8's start. This is the compression the even cadence produces; the phases genuinely depend on each other and cannot be parallelised away.
>
> **Phase 8's 118 h splits evenly across the S2/S3 boundary** (59 h each), matching the capacity model's own W5/W6 split. Its story bodies are listed once, under S2.

---

##### S2 · Phase 4 — Rod Check-In & PLC Configuration (FL1 / FL3)

**Spec:** [`phase-04-rod-checkin-plc-config.md`](Phases/phase-04-rod-checkin-plc-config.md) · **Owning specifications:** [`RocCheckin.md`](../../RequirementDocuments/RocCheckin.md) (DB2) · [`RodPreCheckin.md`](../../RequirementDocuments/RodPreCheckin.md) (DB2A) · **Owner:** FE + BE + RT · **255 h** (FE 60 · BE 62 · DB 28 · RT 28 · QA 36 · BA 8 · cont. 33)

> **⚠ Estimate provisional — carries a 24–64 h reserve excluded from the total**, pending `OI-39` / **G2**: cross-database check-in recovery is undecided between saga/outbox and an `INFLAT` mirror.
>
> **The pass schedule is an external dependency, not a Phase-2 deliverable.** MVP-1 builds no authoring UI and creates no schedule. It **reads** one: step 2 displays it, the operator acknowledges it, and that acknowledgement is the single trigger that writes PLC tags.

---

###### FW-061 · Dashboard 2 — Rod Check-in six-step wizard (FL1/FL3)
**Hours:** 36 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** FE

**As an** FL1 operator,
**I want** a guided check-in that will not let me proceed until every gate clears,
**So that** the machine is configured correctly and a wrong schedule is never silently applied.

**Acceptance Criteria:**
- [ ] Built from `../Mockups/dashboard_2_rod_checkin.html` — a **six-step tab-wizard with progressive unlock**: (1) Visual Inspection · (2) Pass Schedule · (3) Pre-run SPC · (4) Die Block (DB1/DB2) · (5) Rolling Mill (FM1) · (6) Lube & Safety
- [ ] Footer **Acknowledge & Begin Check-in** disabled until all six steps clear, or a supervisor override is on file for a deviation
- [ ] Step 2 confirm-bar is **amber until Confirm Schedule, then green**; "Change ▼" lists alternates with non-recommended ones flagged for Ops review. **PLC tags are never pushed before this confirmation**
- [ ] Pass-schedule unavailable → **blocking error on step 2**, not a warning. There is no partial path and no default schedule
- [ ] Payoff selector renders **pre-filled and read-only** when the rod arrived via pre-check-in (`CHK005`)
- [ ] Uses `tab-wizard`, `pass-schedule-table`, `confirm-bar`, `payoff-option`, `tolerance-viz` and the OK/NG/NA buttons from FW-133 / FW-134 — **the retired inline-SVG progress ring is not used**
- [ ] On success → **Dashboard 2A** to stage the next rod (`FR-079a`); on inspection fail → WIP rejection dialog

**Rate-card basis:** new dashboard 24 h + six-step wizard uplift 12 h = 36 h (§2, above base rate for the wizard's six steps)
**Dependencies:** FW-133, FW-134, FW-157; **`FW-020`** *(upstream, deleted)*, **`FW-010`** *(MVP-2)*
**Blockers:** **OQ-3** *(Critical — traveler fields per station)* · **OQ-14** *(Critical residual — no-match path)* · ⛔ **OQ-22** *(tolerance values owed by e-mail — gates `CHK007`)* · **OQ-25** · **OQ-73** · **OI-109** *(return-to-DB2A pending client confirmation)* · **G14**

---

###### FW-N01 · Dashboard 2A — Rod Pre-Check-in station
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** FE

**As an** FL1 operator,
**I want** to stage the next rod against the idle bay while the current one runs,
**So that** the line can run continuously through an induction weld.

**Acceptance Criteria:**
- [ ] Built from `../Mockups/dashboard_2a_rod_precheckin.html` — **three body regions**: two payoff bay cards (`NOT STAGED` / `PRE-CHECKED-IN` / `ACTIVE` / `BLOCKED`) and a **"Rods In Queue"** table
- [ ] **FL1/FL3 only** — `PCI002` excludes FL2, which has no staging space
- [ ] Three modals: a **3-step** pre-check-in wizard (Identify rod → Assign bay → Visual inspection), pre-check-out, and the read-only weld list
- [ ] **Mark as Welded** sits on the **staged** card, enabled only when that bay is staged *and* the other is running; **Welds this run · N** sits on the **active** card. **There is no weld-readiness strip**
- [ ] **Mark as welded captures quality** — Pass/Fail with a reason mandatory on Fail. **Neither result is pre-selected** and confirm stays disabled until one is chosen; a pre-selected Pass on the gate that exists to make the operator look at the join is a rubber stamp
- [ ] **The outgoing/incoming pair for a weld resolves from whichever bay is actually running**, never from the card the operator activated (`FR-050a`) — after a payoff transition the running bay may be either one
- [ ] Bay-card actions are regenerated on every render, so handlers are bound **per render or by delegation**, not once at init
- [ ] At most **one primary action per card**; the `ACTIVE` card deliberately has **none** — both its actions are exceptional
- [ ] **Clone the Dashboard 12 skeleton, not Dashboard 2's** — DB2 inlines its own app bar and omits `flat-wire-topbar.js`
- [ ] **Ships against a stub** for `POST /weldevent` and `GET /run/{runId}/weldevents` (**G26**) — both land in Phase 6; the read returns an empty array until then, stubbed with sample rows for the gate review

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-133, FW-134, FW-158; de-stubbed by FW-166
**Blockers:** **G19** *(resolved — 2 items need business sign-off)* · **G21** *(bay uniqueness across FL1/FL3 — blocks the schema freeze)* · **G22** · **G26** · **OI-108** *(Welds-this-run absent vs disabled at cold start)* · **OQ-24** *(wrong-station auto-switch)*

---

###### FW-157 · `POST /checkin/rod` and `CheckInService`
**Hours:** 36 h BE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

**As a** developer,
**I want** check-in orchestrated as ordered, compensating writes across two databases and the PLC,
**So that** a PLC failure never leaves a half-configured machine with a run marked Running.

**Acceptance Criteria:**
- [ ] `CheckInController POST /checkin/rod`; `CheckInRodCommand` (line, rodAlpha, payoff, diameterMeasured, weights, `InspectionDto`, scheduleId, operatorId, orderId) → `CheckInRodResponse` (runId, checkedInAt, plcTagsPushed)
- [ ] **Records are written BEFORE the PLC push** — inspection result, pre-run SPC checkpoint, run record with schedule id + version, acknowledgement audit entry — then `PLCTagService.PushPassSchedule(scheduleId, lineId, payoffPosition)`
- [ ] **MVP-1 persists its own snapshot of what it pushed** — schedule id, version and effective configuration — so a certificate stays reproducible after the owning system later edits the schedule
- [ ] Business rules: Draft schedule not acknowledgeable (`422`); single active run per line (`409`); all-or-nothing
- [ ] Where a staged row exists, the request's `payoffPosition` must match it (`409` on mismatch); check-in **consumes** the staged row (`RodStaging.Status → CheckedIn`, `RodCheckinId` linked) rather than creating a parallel record
- [ ] ⚠ **Described and implemented as compensating writes, never "atomic rollback"** — check-in spans `FlatWireDB` + `coils` + `wip_coil_orders` + the PLC and **is not one ACID transaction** (**G2 / G16**)
- [ ] PLC push audited (tag, value, operator, result); Operator+ policy

**Rate-card basis:** complex command spanning two databases and the PLC 20 h + `CheckInRod` service and validation rules 16 h = 36 h (§3 worked derivation)
**Dependencies:** FW-139, FW-141, FW-151
**Blockers:** ⚠ **G2 / OI-39** *(recovery design undecided — this is what the 24–64 h reserve is for)* · **OQ-14**

---

###### FW-158 · `PayoffStagingController` — staging commands and queries
**Hours:** 26 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

**As a** developer,
**I want** bay staging exposed as commands and queries with conflicts enforced by the database,
**So that** two rods can never occupy one bay through a read-then-write race.

**Acceptance Criteria:**
- [ ] `GET /payoff/status`, `GET /staging/queue`, `POST /staging/rod`, `POST /staging/rod/unstage`
- [ ] `StageRodCommand` (reuses the **3-item** `InspectionDto` — **do not add a connector-tag item**, see **G14**), `UnstageRodCommand` (writes `RodCheckout` with `Mode='ModeP'`), `MarkStagedRodWeldedCommand` (validates alloy/temper/diameter against the running coil)
- [ ] **Bay-occupancy conflicts surface as `409` from the filtered unique indexes**, not from application-level checking
- [ ] **FL2 rejected `422`** (`PCI002`)
- [ ] **An inspection `Fail` commits the staging row and returns `201` with `state: "Blocked"`** plus the WIP-rejection route, with **no override** — the bay must stay occupied because the failed bundle is physically on it *(changed 31 Jul 2026; was `422`-and-write-nothing)*
- [ ] Prior footage without acknowledgement rejected `422` (`PRC007`)
- [ ] **`POST /staging/rod/mark-welded` is not built** — it was retired 1 Aug 2026; DB2A's weld posts to `POST /weldevent` in Phase 6

**Rate-card basis:** 3 commands @ 6 h = 18 h + 2 queries @ 4 h = 8 h → 26 h (§2, §3 worked derivation)
**Dependencies:** FW-139, FW-159
**Blockers:** **G21** · **G22** · **OQ-23** *(WIP rejection releases a blocked bay — the cross-phase link to Phase 7)*

---

###### FW-159 · `RodStaging`, the check-in write path and the cross-DB `INFLAT` write
**Hours:** 28 h DB · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB

**As a** developer,
**I want** every check-in write persisted with bay uniqueness enforced in the database,
**So that** application code cannot violate one-rod-per-bay.

**Acceptance Criteria:**
- [ ] `RodStaging` table live with the 3-item inspection, `RodSeqno`, `IsWelded`, carry-forward evidence (`FootageRunToDateAtStaging`) and release audit (`UnstageKind`, `WipRejectionId`)
- [ ] Repository/EF writes across `RodCheckin`, `FlatWireRun`, `SpcCheckpoint`, `SpcMeasurement`, `RodCheckout`
- [ ] **Cross-database write setting the `coils` rod row to `INFLAT`** — at check-in only, never at staging
- [ ] Indexes: `RodCheckin(RunId)`, `RodCheckin(RodAlpha)`, **`RodCheckin(LineId, PayoffPosition)`** *(was missing)*, `RodStaging(LineId, Status)`, `RodStaging(RodAlpha)`
- [ ] **Filtered unique indexes `UX_RodStaging_Bay` and `UX_RodStaging_RodActive`** enforce one rod per bay and one bay per rod
- [ ] `PayoffPosition` lookup has its 3 pinned rows and `FlatWireRunDetail.PayoffPositionId` now has an enforced FK parent
- [ ] **`FL1PO` WIP station seeded** by `CommonDB_Insert_WIPStations_FlatWire.sql`, sharing FL1's `MachineIdx` — the legacy `ZR23`/`ZR23PO` pattern. **`FL2PO` stays absent** per `PCI002`

**Rate-card basis:** `RodStaging` table 4 h + repository/EF writes across five tables 16 h + cross-DB `coils → INFLAT` write 8 h = 28 h (§3 worked derivation)
**Dependencies:** FW-007
**Blockers:** ⚠ **G21 — `UX_RodStaging_Bay` does not enforce one-rod-per-bay across FL1/FL3, and the uniqueness scope is unresolved. This blocks the schema freeze for this phase** · **G2 / G17**

---

###### FW-160 · `PayoffStateChanged` and the check-in broadcasts
**Hours:** 12 h RT · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** RT

**As a** supervisor,
**I want** bay occupancy changes to reach the board immediately,
**So that** the "Payoff2 not loaded" alert reflects reality rather than a stale poll.

**Acceptance Criteria:**
- [ ] New event `PayoffStateChanged { lineId, position, state, rodAlpha, rodSeqno, isWelded }` on every bay-occupancy change — stage, un-stage, a **passing** weld, and check-in consuming a staged row
- [ ] **A failed weld changes no bay state and broadcasts nothing**
- [ ] **Sent immediately and unbatched** as a rare domain event — it must **not** enter the ~100 ms / 10 Hz telemetry batch. Live weight keeps coming from the batched `PayoffWeight`
- [ ] On check-in success, broadcast `LineStatus {status: Running}` so Dashboard 1 flips to RUNNING, and `ComponentStatus` reflecting the pushed values
- [ ] **If the PLC push fails, no broadcast is emitted** — state is compensated first

**Rate-card basis:** new domain event 8 h + `LineStatus`/`ComponentStatus` broadcast 4 h = 12 h (§3 worked derivation)
**Dependencies:** FW-149, FW-157
**Blockers:** —

---

###### FW-082 · PLC tag group push on check-in acknowledgement
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** RT

**As an** operator,
**I want** my acknowledgement to configure the machine in one operation,
**So that** the line runs the schedule I confirmed and nothing else.

**Acceptance Criteria:**
- [ ] `PushPassSchedule(scheduleId, lineId, payoffPosition)` writes the six value groups the push needs: **component active/bypass state · die sizes · roll gaps · edge type · speed · gauge and width targets**. Nothing else
- [ ] Written as a batch to the selected payoff position
- [ ] **Triggered only by the step-2 acknowledgement** — never at schedule generate or apply time, and never at pre-check-in
- [ ] Failure path performs **compensating re-clears**, and no `LineStatus` broadcast is emitted
- [ ] Every tag write audited (tag, value, operator, result)
- [ ] Runs under `SimulatePLCTagPush` until commissioning (FW-200)

**Rate-card basis:** PLC tag group push + compensating clear @ 16 h (§2)
**Dependencies:** FW-151, FW-157; **`FW-010`** *(MVP-2 — the schedule this reads)*
**Blockers:** **G2 / OI-39** · **G29** *(no edger tag path exists on any line, yet edge type is in the payload)* · **G30** *(FM2's controller namespace on FL3 undetermined)* · **`PLC-Q04`/`Q05`**

---

###### FW-161 · Traveler field list and the no-match path
**Hours:** 8 h BA · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BA

**As a** business analyst,
**I want** the traveler field list and the no-match behaviour settled with the client,
**So that** the wizard's final field set stops being provisional.

**Acceptance Criteria:**
- [ ] **OQ-3** closed — traveler fields per station confirmed with Operations. *(Traveler is fully digital; no printing. Coil and skid labels are still printed.)*
- [ ] **OQ-14** closed — the no-match path defined. The stub currently assumes a single active schedule resolving to `PS-1100-FL1-003`
- [ ] **OQ-25** progressed — what happens when a rod is scheduled on neither rod line, since the auto-switch then has no target
- [ ] Outcomes recorded in the register, not only in a meeting note

**Rate-card basis:** BA / Ops liaison (8 h, §3 worked derivation)
**Dependencies:** None
**Blockers:** **OQ-3** *(Critical)* · **OQ-14** *(Critical)* · **OQ-25**

---

**Phase 4 reconciliation** — FE `36+24 = 60` · BE `36+26 = 62` · DB 28 · RT `12+16 = 28` · dev base **178** · BA 8 → QA `0.20 × 178 = 36` → Cont `0.15 × (178+8+36) = 33` → **255 h** ✓ (§3b) · **+24–64 h reserve excluded**

---

##### S2 · Phase 5 — Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3)

**Spec:** [`phase-05-active-run-monitoring-gauge-trace.md`](Phases/phase-05-active-run-monitoring-gauge-trace.md) · **Owning specification:** [`ActiveRunMonitor.md`](../../RequirementDocuments/ActiveRunMonitor.md) (DB3) · **Owner:** FE · **154 h** (FE 76 · BE 12 · DB 8 · RT 24 · QA 22 · cont. 12)

> **This phase owns the DB3 shell for all three lines.** Build the components once here; Phases 8 (FL2) and 10 (FL3) **configure** them. FL1 and FL2 diverged once already and the 2 Aug 2026 mockup pass undid it — **do not let a line fork its own copy.**
>
> **⚠ Arithmetic note.** This is the one phase whose QA and contingency do **not** follow the 20% / 15% uplift: the −67 h DB13/DB14 descope of 4 Aug 2026 was applied to the published total rather than re-derived. The row still sums exactly (`76+12+8+24+22+12 = 154`), and the published figure is used here unchanged.

---

###### FW-062 · Dashboard 3 — Active Run Monitor (FL1) and FL3 variant
**Hours:** 32 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** FL1 operator,
**I want** one screen showing the run live with every action one click away,
**So that** I never leave the monitor to record something.

**Acceptance Criteria:**
- [ ] `dashboard-3-active-run` built from `../Mockups/dashboard_3_active_run.html`, plus the FL3 variant `dashboard_3_active_run_fl3.html`
- [ ] Header shows Order / Alpha / Alloy / Target Gauge / Target Width
- [ ] **Action bar grouped by intent** — *Run events* (SPC Checkpoint · WIP Reject) · *Go to* (Die Change · Check Out Rod, **disabled once footage > 0**) · *Run control* (Pause run · **Complete Run**, confirmation-gated)
- [ ] **FL1 has no Roll Adjust** (`FR-107` — one mill). **FL3 adds it** (`FR-108`)
- [ ] **No Log Weld button on any line** — Dashboard 4 was retired 1 Aug 2026 and the weld is captured at pre-check-in
- [ ] After N consecutive out-of-spec readings (**configurable, default 5**) → auto-prompt SPC toast
- [ ] SignalR drop → reconnect banner with cached state
- [ ] **Dashboards 13 and 14 are not built** — descoped 4 Aug 2026, both mockups deleted

**Rate-card basis:** new dashboard 24 h + FL3 screen variant 8 h = 32 h (§2)
**Dependencies:** FW-133, FW-162, FW-163, FW-081, FW-164
**Blockers:** **`PLC-Q02`** · configurable out-of-spec N

---

###### FW-162 · `run-status-cards`
**Hours:** 20 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** operator,
**I want** machine, material and component state in one card strip,
**So that** I can read the whole line at a glance.

**Acceptance Criteria:**
- [ ] Three-card strip on a `1fr 1.35fr 1fr` grid; **absorbs the former `machine-status-panel`**
- [ ] Outer cards are **Machine** (run time, speed, footage, spool fill, lube temp) and **Components** (dies, gap + width, headed by the pass-schedule id) on every line
- [ ] **The middle card is line-specific** — *Payoffs* (two rod payoffs with consumption bars) on FL1/FL3, *Material flow* (spool draining in, coil filling out) on FL2. **Same shell, different middle card**
- [ ] **`payoff-weight-bar` survives as the Payoffs card's content**, not as a sibling of the status panel. It is still used directly by Dashboard 1, so it stays in the FW-133 shared set — this is a change to DB3's composition, not a deletion
- [ ] The FL2 material-flow card is **not** a payoff bar and must not reuse its labels

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-133
**Blockers:** —

---

###### FW-163 · `info-grid` and `chart-tab-strip`
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** operator,
**I want** collapsible material and order detail on the monitor,
**So that** I do not have to leave the run screen to check an order tolerance.

**Acceptance Criteria:**
- [ ] **`info-grid`** — the collapsible titled data grid, **two instances per monitor**: Rod/Spool Information and Order Information. Content is per-line; the accordion, table chrome and empty state are not. *(This component previously had no owner in any phase.)*
- [ ] Order Information carries customer, due date, gauge/width tolerance, setup width/gauge, finish, OD min–max and weights
- [ ] **`chart-tab-strip`** — the **section collapse toggle with `localStorage` persistence**, plus a single inert tab label that titles the section
- [ ] ⚠ **The collapse toggle has no requirement of its own** — `FR-112` covered only the tabs, which went with the Machine View descope. This is a pre-existing gap, now visible; either keep the strip as the collapse control or fold it into the shell, but record the choice

**Rate-card basis:** `info-grid` composite 12 h + `chart-tab-strip` primitive 8 h = 20 h (§2)
**Dependencies:** FW-133
**Blockers:** **OQ-18** *(which order field carries the coil min–max weight range — surfaced by this grid, blocks the FL2 variant in Phase 8)*

---

###### FW-081 · `gauge-trace-chart` live streaming, maximize and runtime source toggle
**Hours:** 4 h FE · 24 h RT · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE + RT

**As an** operator,
**I want** the gauge and width traces streaming live with weld markers,
**So that** I can react to drift before it produces out-of-spec material.

**Acceptance Criteria:**
- [ ] Streaming gauge + width (Chart.js) with target dashed line, tolerance band, green/red points and **vertical weld markers carrying the rod alpha**
- [ ] Consumes `gaugeReading$ / widthReading$ / speedFpm$ / payoffWeight$ / componentStatus$ / footageCounter$`; markers via `WeldJoinEvent / DieChangeEvent / PauseEvent / SPCCheckpoint / RodCheckoutEvent`
- [ ] Renders from the ring buffer under `requestAnimationFrame`, outside NgZone, on a fixed ~500-point window
- [ ] **Each panel maximizes to full screen** — backdrop, ESC and backdrop-click restore
- [ ] ⚠ **`isLive` is a runtime-switchable input, not mount-time.** The chart must switch between live streaming and a static historical profile **after mount, without remounting** — Phase 8 needs exactly this for FL2's Live/Profile control, and a hybrid FL3 run has both
- [ ] Last-window buffer survives a reconnect and re-join

**Rate-card basis:** FE maximize + runtime toggle 4 h + RT live wiring across 6 event streams 24 h = 28 h (§2)
**Dependencies:** FW-133, FW-135, FW-150
**Blockers:** —

---

###### FW-164 · `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService`
**Hours:** 12 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 5 · **Stream:** BE

**As a** client developer,
**I want** an active-run snapshot and a paged historical trace,
**So that** the monitor resumes correctly and FL2 can show a finished run's profile.

**Acceptance Criteria:**
- [ ] `RunController GET /run/active?line=` returns the active-run DTO (payoffs, weldEvents, components)
- [ ] `GET /run/{runId}/gaugetrace` returns the gauge-trace DTO (readings, weldMarkers, limits), paged by `from` / `to` / `resolution` via Dapper
- [ ] **The active-run DTO carries the Order Information fields** — customer, due date, tolerances, setup width/gauge, finish, OD min–max, weights — served in one round trip rather than a second call. These live in the **shared order/scheduling schema, cross-database**, on the same unenforced-link basis as the rod-alpha references
- [ ] Out-of-spec detection thresholds surfaced to the client as configuration
- [ ] Weld markers sourced from `WeldEvent`
- [ ] Any authenticated role may read

**Rate-card basis:** 2 query endpoints @ 4 h = 8 h + `RunQueryService` / Dapper paging 4 h = 12 h (§2)
**Dependencies:** FW-138, FW-141
**Blockers:** **OQ-18**

---

###### FW-165 · `sp_GetGaugeTrace`
**Hours:** 8 h DB · **Priority:** Medium · **Sprint:** S2 · **Phase:** 5 · **Stream:** DB

**As a** database owner,
**I want** the paged trace read served by a stored procedure,
**So that** a long run's trace query stays predictable under load.

**Acceptance Criteria:**
- [ ] `sp_GetGaugeTrace` created in `08_Programmability`, taking run, footage range and resolution
- [ ] Reads `RunReading`; supports decimation by resolution rather than returning every row
- [ ] Trace-query index support on run + footage present
- [ ] `GRANT EXECUTE` per FW-152's least-privilege model

**Rate-card basis:** stored proc / reporting view 8 h (§2)
**Dependencies:** FW-007
**Blockers:** **G9** *(`RunReading` retention policy undefined)*

---

**Phase 5 reconciliation** — FE `32+20+20+4 = 76` · BE 12 · DB 8 · RT 24 · base **120** → QA 22 → Cont 12 → **154 h** ✓ (§3b) *(QA/cont carried at published values — see the arithmetic note above)*

---

##### S2 · Phase 6 — In-Run Production Events

**Spec:** [`phase-06-in-run-production-events.md`](Phases/phase-06-in-run-production-events.md) · **Owning specifications:** [`SPCCheckpoint.md`](../../RequirementDocuments/SPCCheckpoint.md) (DB6) · [`DieChangeAndManagement.md`](../../RequirementDocuments/DieChangeAndManagement.md) §1–3, §5 · [`WeldEvent.md`](../../RequirementDocuments/WeldEvent.md) · [`RollAdjust.md`](../../RequirementDocuments/RollAdjust.md) (DB11) · [`ActiveRunMonitor.md`](../../RequirementDocuments/ActiveRunMonitor.md) §6 · **Owner:** FE + BE · **298 h** (FE 120 · BE 56 · DB 20 · RT 20 · QA 43 · cont. 39)

> **The largest workflow phase, and it has no routed screens at all.** Every event it owns is a **dialog** over the active-run monitor. Dashboards 4, 6 and 11 and the die-change screen are **launcher pages only** — `../Mockups/dashboard_6_spc_checkpoint.html`, `dashboard_11_roll_adjust.html`, `dashboard_die_change.html` exist so filename references keep resolving. **Do not edit a launcher to change a screen — edit the `.js`.**
>
> **Never stack two dialogs.** Close the current one, then open the next; two live focus traps leave the operator unable to reach either.
>
> **There is no die inventory in MVP-1 and `D4` is enforced at die-SIZE level.** The three values the die-change dialog needs come from the **`Drawer` lookup seeded in Phase 1** (13 size rows, `LastGrindingFeet`, `TotalFeetAllowed`, 60/85 % bands). The incoming-die check therefore **rejects an unrecognised size, not an unregistered physical die**. **Accepted consequence: die life is per size — two dies of one diameter share a counter, and fitting a fresh die resets nothing.** This also removes the old "Phase 6 depends on Phase 13" risk (`OI-41`, `REVIEW.md` #34) — `Drawer` is a Phase-1 seed.

---

###### FW-063 · Weld capture — `fw-mark-welded-dialog`
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** FL1 operator,
**I want** to record the induction weld joining the running rod to the staged one,
**So that** output-coil footage can be attributed to the right source rod on a customer certificate.

**Acceptance Criteria:**
- [ ] Dialog raised from **Dashboard 2A's staged bay card**; outgoing alpha and weld footage auto-populated
- [ ] **Incoming rod defaults to the `Staged` rod on the idle bay** rather than free entry (`PCI008`), with scan-to-override still available
- [ ] **Induction only** — laser was dropped
- [ ] Quality Pass/Fail with a **reason mandatory on Fail** (six reasons); **neither result pre-selected**; confirm gated on *material match* **AND** *quality chosen* **AND** *(Pass OR reason selected)*
- [ ] Confirm links `Rout → Rin`; all later footage attributed to the incoming rod; weld marker on the trace; WELD-SOON/NOW alert cleared
- [ ] **Operator comes from the signed-in session** — no badge re-entry (`WLD003`)
- [ ] **No edit path** — reversing a recorded weld is `WLD011` and is unspecified
- [ ] Read-only **Welds this run** dialog over `GET /run/{runId}/weldevents`, **enabled at a count of 0** (the empty state is the answer), and **absent rather than disabled at cold start** when there is no active card

**Rate-card basis:** modal/dialog 12 h + quality-gate and weld-list uplift 8 h = 20 h (§2)
**Dependencies:** FW-N01, FW-166
**Blockers:** **OQ-6** · **G26** *(this de-stubs the Phase-4 screen)* · **G27** *(the weld screen's re-sequenceable rod queue and traceability chain lost their host when DB4 was retired)* · **G28** *(FL2 may have no way to record a weld at all)* · **OI-59 / Q6** *(a fail-then-remake writes several `WeldEvent` rows for one physical join; whether a superseded attempt reaches the certificate is undecided)*

---

###### FW-073 · Die change dialog
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** FL1 operator,
**I want** to record a mid-run die change and be forced into an SPC check when the reason demands it,
**So that** a gauge-affecting change is always verified before the run continues.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../Mockups/die_change.js` — `openDieChange(ctx)`, CSS scoped under `.fwdc`, all ids prefixed
- [ ] Select DB1 / DB2 / Both; scan or key the incoming die
- [ ] **Incoming size validated against the `Drawer` 13-row size catalogue** — an unrecognised **size** is rejected. This is application-level validation; `DieChangeEvent` stores `OldDieSizeIn` / `NewDieSizeIn` as decimals with **no `DrawerId` FK**
- [ ] Die life read from `Drawer.LastGrindingFeet` / `TotalFeetAllowed` with the **60 / 85 % bands**
- [ ] Reason: Planned / Gauge drift / Die failure / Size change / Other
- [ ] **Reason = Gauge drift or Size change → opens the SPC checkpoint dialog as a hard gate**, run paused until SPC passes. Close this dialog first, then open SPC
- [ ] Die failure → optional QA hold on the footage range
- [ ] **Suppressed on FL2** — FL2 has no drawing dies
- [ ] Confirm writes the die-change event **plus a linked override**

**Rate-card basis:** modal/dialog 12 h + catalogue validation, life bands and the SPC hand-off 12 h = 24 h (§2)
**Dependencies:** FW-005 *(`Drawer` seed)*, FW-065, FW-167
**Blockers:** **OI-12** *(conflicting die-life bands — **dormant, not answered**; only the 60/85 % Die Change bands apply in MVP-1)* · die-life threshold configurability

---

###### FW-065 · SPC checkpoint dialog
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** operator,
**I want** to record a measurement against tolerance and be routed correctly when it fails,
**So that** out-of-spec material is suspended rather than shipped.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../Mockups/spc_checkpoint.js` — `openSpcCheckpoint(ctx)`, CSS scoped under `.fwspc`
- [ ] Checkpoint types: **Pre-Run · Post DB1 · Post Die Change · Manual Spot Check · Post-Run**; measurements vary by type
- [ ] **Marker maths:** `pct = 50 + ((measured − target) / (tol × 1.67)) × 50`, **clamped 4–96 %**
- [ ] **Submit · Continue** when in spec; **Submit · Suspend material** when out of spec → **opens the WIP rejection dialog with the failing reading carried over**, coil to `SPC-HOLD`
- [ ] **Read-only mode** — Dashboard 1's "SPC · Last check … · View →" reviews a recorded checkpoint; it must not open a blank form
- [ ] Opens pre-loaded with the die change as its trigger when raised from FW-073

**Rate-card basis:** modal/dialog 12 h + five checkpoint types, marker maths and read-only mode 12 h = 24 h (§2)
**Dependencies:** FW-133 *(`tolerance-viz`)*, FW-067, FW-168
**Blockers:** **OI-57** *(tolerance bands)*

---

###### FW-070 · Roll adjust dialog
**Hours:** 28 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** FL2 or FL3 operator,
**I want** to correct roll gaps mid-run without editing the pass schedule,
**So that** drift is corrected at run level and the schedule stays the record of intent.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../Mockups/roll_adjust.js` — **replaces the route component `dashboard-11-roll-adjust`**
- [ ] **Caller supplies the context:** `line`, `orderNo`, `alpha` + `alphaLabel` (*Spool* on FL2, *Rod* on FL3), `runId`, `passSchedule`, `footage` **read at open time**, `targets`, `measurements`, and — the load-bearing one — **`rolls`, the stand set the operator can reach**. FL2 and FL3 **do not share a stand set**, which is exactly why this could not stay a page: as a page it hard-coded FL2's
- [ ] Per-roller Scheduled / Current / New / Delta table, bypassed stands greyed
- [ ] Measured gauge **and** width required
- [ ] **A reason is required — Apply stays disabled until one is picked**
- [ ] **All-zero deltas relabel the action "No changes — return to run" and write nothing**
- [ ] Apply writes a **run-level override** (never the schedule) + PLC tag write + an SPC log at footage
- [ ] `onConfirm` returns adjustments, reason, notes and the frozen footage
- [ ] **FL2 + FL3 only, not FL1** (`FR-107`/`108`/`109`). *Note: `FlatWireShopfloorDashboards.md` and `Development/GapsRegister.md` state this three contradictory ways and are stale;* `RollAdjust.md` *§1.5 is the owning spec*
- [ ] **Vocabulary:** roll **gap** (the setting, ~0.016″) and product **gauge** (what the strip measures, ~0.110″) are different quantities — the dialog opens over a live gauge trace, so conflating them is visible on screen

**Rate-card basis:** modal/dialog 12 h + caller-supplied stand set, delta table and PLC write 16 h = 28 h (§2)
**Dependencies:** FW-062, FW-169
**Blockers:** **OI-103** *(no bound on a roll-gap change, which is written straight to the machine)* · **OQ-62** *(override authority — decided)*

---

###### FW-071 · Pause and Resume dialogs
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** operator,
**I want** to pause the run against a categorised reason and choose what happens on resume,
**So that** downtime is attributable and every off-ramp is reachable from one place.

**Acceptance Criteria:**
- [ ] Built from `../Mockups/pause_run.js`; expects `pause-btn`, `pause-timer-badge`, `pause-elapsed` and `.line-badge` on the host, and **falls back to the host's own `fwRunCtx()`** so argument-less `onclick="openPauseDialog()"` handlers keep reading live footage
- [ ] **Icon badge + title + purpose line**, a **context chip row** (status · order · alpha · footage · pause start) whose footage and clock **tick live and freeze on confirm**, then **15 reasons as icon tiles in five category columns** with `Other` at the foot of the Equipment column, and a notes row with a 500-char counter
- [ ] **Payload carries `ReasonCode` + `ReasonCategory`, not a label.** `Other` keeps its code and puts the prose in `notes`; notes are **required** in that case per `CK_RunPauseEvent_NotesOther`
- [ ] Confirm → timer paused, footage frozen, PLC idle, Dashboard 1 → PAUSED
- [ ] **Four resume outcomes** (`OI-14` closed): `ResumeRun` / `LogWipRejection` / `CheckOutRod` / `ContinuePause`
- [ ] **Rod Checkout is not a pause reason** — it is the fourth resume outcome, superseding `FR-262`
- [ ] Reasons that lead somewhere show a route line before the operator commits: *Die change* → opens die change (**suppressed on FL2**), *Manual SPC measurement* → opens SPC, **`RollAdjustment` → opens roll adjust** carrying the frozen footage
- [ ] Each hand-off **closes the pause dialog first, then opens the next** — never both at once
- [ ] Type set at the repo's **14px** floor, not the reference design's 10–13px

**Rate-card basis:** 2 × modal/dialog @ 12 h = 24 h (§2)
**Dependencies:** FW-062, FW-170; the resume dialog depends on **FW-067** and **FW-072** (Phase 7) for two of its four outcomes
**Blockers:** —

---

###### FW-166 · `POST /weldevent` and `WeldService`
**Hours:** 12 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** one endpoint that writes every weld,
**So that** both weld entry points compose the same row.

**Acceptance Criteria:**
- [ ] `WeldEventController POST /weldevent`; `RecordWeldEvent` handler; `WeldService` advances the active-rod pointer and clears weld-pending
- [ ] **This is the single weld write** — `POST /staging/rod/mark-welded` was retired 1 Aug 2026
- [ ] **The `RodStaging` write is conditional on quality:** a **Pass** sets `IsWelded` / `WeldedAt` / `WeldedBy` in the same transaction; a **Fail** writes the `WeldEvent` row and **leaves the rod staged and un-welded** so the operator remakes the weld
- [ ] **Broadcast `PayoffStateChanged` on Pass only**
- [ ] Quality is **not** mirrored onto `RodStaging` — one join, one quality answer
- [ ] **No uniqueness constraint on the rod pair, and none should exist** — a fail-then-remake legitimately writes several rows
- [ ] `GET /run/{runId}/weldevents` returns every weld against the active run

**Rate-card basis:** command endpoint 6 h + `WeldService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-171
**Blockers:** **G26** · **OI-59 / Q6** *(footage attribution across the two boundaries)*

---

###### FW-167 · `POST /diechange` and `DieChangeService`
**Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** a die change to create its own override and demand its SPC check,
**So that** the gate cannot be skipped by going straight to the endpoint.

**Acceptance Criteria:**
- [ ] `DieChangeController POST /diechange`; `RecordDieChange` handler
- [ ] `DieChangeService` **auto-creates the linked override** (`DieChangeEvent.LinkedOverrideId → RollOverride.OverrideId`) and sets `spcCheckpointRequired`
- [ ] **Die-change → PostDieChange SPC gate is a hard block until it passes** (thread mode allowed); `OQ-65` decided
- [ ] Incoming size validated against `Drawer`; unrecognised size → `422`
- [ ] `Require SPC on resume` toggle-off is **Ops-Manager / Quality only** and writes a logged exception

**Rate-card basis:** command endpoint 6 h + `DieChangeService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-171, FW-169
**Blockers:** —

---

###### FW-168 · `POST /spc` and `SpcService`
**Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** the spec calculation and hold behaviour on the server,
**So that** an in-spec verdict cannot be produced by the client.

**Acceptance Criteria:**
- [ ] `SpcController POST /spc`; `SubmitSpcCheckpoint` handler
- [ ] `SpcService` computes in/out of spec and sets coil `SPC-HOLD` on suspend
- [ ] Measurements accepted per checkpoint type; **`CheckpointType` accepts all five values including `RollAdjustTrigger`**
- [ ] Writes `SpcCheckpoint` + `SpcMeasurement`; auto-links to the die change when raised from one
- [ ] All events audited

**Rate-card basis:** command endpoint 6 h + `SpcService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-147, FW-171
**Blockers:** —

---

###### FW-169 · `POST /rolloverride` and `RollOverrideService`
**Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** an override written at run level with its PLC write and SPC log,
**So that** correcting drift never mutates the approved schedule.

**Acceptance Criteria:**
- [ ] `RollAdjustController POST /rolloverride`; `RecordRollOverride` handler
- [ ] `RollOverrideService` writes the override, performs the **per-roll `PLCTagService` write**, and logs an `SpcCheckpoint` of type **`RollAdjustTrigger`** at footage
- [ ] **The override never edits `PassSchedule`**
- [ ] **All deltas zero → no write**, matching the dialog's short circuit
- [ ] Response carries adjustments, delta, `plcTagWritten` and `spcCheckpointId`
- [ ] **Reverting an override is Ops-Manager only** (`FR-212`)

**Rate-card basis:** command endpoint 6 h + `RollOverrideService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-151, FW-171
**Blockers:** **OI-103** · **OQ-62** *(decided)*

> **This subsumes the MVP-1 half of `FW-014`** (pass-schedule override logging). `FW-014`'s **sink**, `PassScheduleChangeLog`, is an **MVP-2 table** — so MVP-1 has an override path with nowhere to log the schedule-level record. The run-level `RollOverride` row **is** written. See [Appendix B](#appendix-b--id-provenance).

---

###### FW-170 · `POST /run/{id}/pause` and `/resume`, and `RunControlService`
**Hours:** 8 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** pause and resume to drive the PLC and the run clock together,
**So that** a paused line is genuinely idle and its downtime is measurable.

**Acceptance Criteria:**
- [ ] `RunController POST /run/{id}/pause` and `POST /run/{id}/resume`; `PauseRun` and `ResumeRun` handlers
- [ ] `RunControlService` pauses/restores the run clock and drives **PLC idle / restore**
- [ ] Pause requires a reason; payload carries `ReasonCategory` + `ReasonCode` and, for `Other`, mandatory notes
- [ ] Resume accepts one of the **four** outcomes and returns the pause duration
- [ ] Writes `RunPauseEvent`

**Rate-card basis:** 2 command endpoints, priced as one service pair (8 h, §2)
**Dependencies:** FW-139, FW-171
**Blockers:** —

---

###### FW-171 · The five in-run event tables
**Hours:** 20 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** DB

**As a** developer,
**I want** every in-run event persisted against run and footage,
**So that** the trace, the reports and the certificate all read from one record.

**Acceptance Criteria:**
- [ ] Write paths live for `WeldEvent`, `DieChangeEvent` (+ `LinkedOverrideId`), `SpcCheckpoint` + `SpcMeasurement`, `RollOverride`, `RunPauseEvent`
- [ ] `(RunId)` index present on every event table
- [ ] All hang off `FlatWireRun.RunId`; SPC auto-links to its die change
- [ ] Reads wired for `Drawer` (size, `LastGrindingFeet`, `TotalFeetAllowed`) and the pass-schedule components **across the external boundary** for scheduled gaps
- [ ] Constraints from FW-007 verified live: notes-on-`Other`, fail-reason-on-`Fail`

**Rate-card basis:** 5 tables @ 4 h = 20 h (§2)
**Dependencies:** FW-007
**Blockers:** **G34** *(wire break has a decided flow and no persistence target — `FR-280`–`282`, `FW-N08`)* · **G35** *(FM2's two dancers unmodelled)*

---

###### FW-172 · Run-event markers and the `LineStatus` transitions
**Hours:** 20 h RT · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** RT

**As an** operator,
**I want** every event I record to appear on the trace immediately,
**So that** the screen and the record never disagree.

**Acceptance Criteria:**
- [ ] Markers published to the DB3 traces: `WeldJoinEvent`, `DieChangeEvent`, `SPCCheckpoint`, `PauseEvent`
- [ ] `LineStatus` transitions RUNNING ↔ PAUSED, reaching Dashboard 1
- [ ] `PayoffWeight` re-established after a weld; `ComponentStatus` re-broadcast after a roll override
- [ ] All are **rare domain events — immediate and unbatched**
- [ ] Standard reconnect and group re-join apply

**Rate-card basis:** 4 marker events @ 4 h = 16 h + `LineStatus`/`ComponentStatus` wiring 4 h = 20 h (§2)
**Dependencies:** FW-149, FW-081
**Blockers:** —

---

**Phase 6 reconciliation** — FE `20+24+24+28+24 = 120` · BE `12+12+12+12+8 = 56` · DB 20 · RT 20 · base **216** → QA `0.20 × 216 = 43` → Cont `0.15 × (216+43) = 39` → **298 h** ✓ (§3b)

---

##### S2 · Phase 7 — Exception Handling: WIP Rejection & Rod Checkout

**Spec:** [`phase-07-wip-rejection-rod-checkout.md`](Phases/phase-07-wip-rejection-rod-checkout.md) · **Owning specifications:** [`WipRejection.md`](../../RequirementDocuments/WipRejection.md) (DB8) · [`RodCheckout.md`](../../RequirementDocuments/RodCheckout.md) (DB12) · **Owner:** FE + BE · **205 h** (FE 64 · BE 40 · DB 28 · RT 16 · QA 30 · cont. 27)

> **Three checkout modes, and they are genuinely different transactions.** **Mode P** — pre-check-out from DB2A; the rod was never checked in, so there is **no acknowledgement to void, no PLC tags to clear and no line-state gate** (an idle bay is not running). **Mode A** — footage = 0. **Mode B** — footage > 0, reachable **only** through Pause.

---

###### FW-067 · WIP rejection dialog
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** FE

**As an** operator,
**I want** to flag suspect material with its context already filled in,
**So that** a hold is recorded in seconds and the supervisor is alerted.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../Mockups/wip_rejection.js` — `openWipRejection(ctx)`, CSS scoped under `.fwwip`
- [ ] **Raised from five places**, each supplying its own material context: the active-run monitors, the pre-check-in station (failed staging inspection), the SPC checkpoint (*suspend material*), the resume dialog, and the More Options tile. **Nothing navigates to it**
- [ ] **Context contract:** `materialAlpha`, `stage`, `runId`, `footagePosition`, `trigger`, and on the staging path `payoff`
- [ ] **On the pre-check-in path `runId` and `footagePosition` are both `null`** — the rod never ran
- [ ] Context auto-populated (alpha, stage, footage, time); group → reason dropdowns; details (measured / target / deviation)
- [ ] Disposition **Suspend (→ HOLD)** / **Scrap (→ SCRAP)** / **Rework (→ return stage)**; **observation required for Suspend**
- [ ] Submit → status set, WIP-Held queue entry, `AlertRaised` to Dashboard 1

**Rate-card basis:** modal/dialog 12 h + five call sites and the context contract 8 h = 20 h (§2)
**Dependencies:** FW-134, FW-174
**Blockers:** **OI-84** *(WIP reason list — with Shannon R.)* · **OI-100** *(valid rework stages)*

---

###### FW-072 · Rod checkout dialog — Modes A, B and P
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** FE

**As an** operator,
**I want** to remove a rod with the right disposition for how far it got,
**So that** material is never left as ghost inventory.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../Mockups/rod_checkout.js` — **mode is an input the caller states**, not something the screen configures itself with
- [ ] **Mode A** (footage = 0), opened from the check-in station: reason (Wrong rod / Order cancelled / Failed re-inspection / Relocated / Other); disposition Return-to-floor (→ STAGED) / Return-to-warehouse (→ RECEIVED); Confirm → acknowledgement voided, `ClearPayoffTags`, line IDLE. **Carries no footage and no in-process material disposition** — the run never started
- [ ] **Mode B** (footage > 0), opened **only** from the pause dialog's `CheckOutRod` outcome with the frozen footage carried over: line-state guard blocks if Running; rod disposition Hold/Scrap/Defer **and** in-process material disposition Hold/Scrap/Accept-partial; → **PENDING DISPOSITION**, material locked with **no alpha**, SignalR to Supervisor
- [ ] Supervisor Accept (→ partial spool alpha, spool queue) / Hold (→ alpha Hold, QC release) / Reject (→ WIP rejection → scrap)
- [ ] **Mode P**, opened from DB2A: reason; disposition Return-to-floor / Return-to-warehouse; Confirm → `RodStaging.Status='Unstaged'`, `RodCheckout` row with `Mode='ModeP'`, the staging WIP queue entry **reversed**, `PayoffStateChanged → NotStaged`
- [ ] **A welded rod on Mode P requires a supervisor override** with a documented reason and goes to **`HOLD`** — removal means cutting the material. Recorded with `WasWelded=1` and the approval stamp
- [ ] Uses `option-card` / `consequence-box` / `footer-stamp` idioms

**Rate-card basis:** modal/dialog 12 h + three modes and the supervisor path 12 h = 24 h (§2)
**Dependencies:** FW-134, FW-174, FW-071
**Blockers:** **OQ-13** *(PLC on checkout — in progress)* · **OI-38** *(PIN validation source undecided)* · **G24**

---

###### FW-173 · Partial rod re-check-in (carry-forward)
**Hours:** 20 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 7 · **Stream:** FE

**As an** operator,
**I want** a part-run rod forced onto the carry-forward path,
**So that** its remaining footage is never mistaken for a fresh rod.

**Acceptance Criteria:**
- [ ] `partial-recheckin` — **the only routed screen in this phase**
- [ ] **The gate fires at the Dashboard 2A staging scan**, where the rod is first identified, so a partial rod is caught before it is ever mounted
- [ ] Scanning a rod with `footage_run_to_date > 0` forces carry-forward; supervisor sign-off required; opens a new run at 0 ft
- [ ] **The fresh-start control is absent from the DOM, not merely disabled** (`PRC008`)
- [ ] `RodStaging.FootageRunToDateAtStaging` records the evidence; `POST /staging/rod` rejects `422` without `acknowledgedCarryForward` (`PRC007`)
- [ ] Each segment gets its own spool alpha carrying `source_rod_alpha`

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-158, FW-176
**Blockers:** **OQ-12** *(carry-forward design — in progress; still open whether a payoff-side scale exists)* · **G14** *(the design doc's worked examples use non-canonical `ROD-`/`SPL-` alphas)*

---

###### FW-174 · `POST /wipreject`, `POST /checkout` and their services
**Hours:** 24 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** BE

**As a** developer,
**I want** both off-ramps written server-side with their status transitions,
**So that** disposition and material status can never disagree.

**Acceptance Criteria:**
- [ ] `WipRejectionController POST /wipreject` → status + `alertBroadcast`; `SubmitWipRejection` handler; `WipRejectionService` sets status, adds the WIP-Held entry and raises the alert
- [ ] `CheckOutController POST /checkout` (mode / footage / reason / rodDisposition / materialDisposition / remainingWeight) → `newRodStatus` / `plcTagsCleared` / `partialSpoolAlpha`; `CheckOutRod` handler; `CheckOutService` voids the acknowledgement, calls `ClearPayoffTags`, creates PENDING DISPOSITION and notifies the supervisor
- [ ] **A WIP rejection on the staging path also releases the bay** — sets `RodStaging.Status='Unstaged'`, `UnstageKind='WipRejection'`, `WipRejectionId`, and broadcasts `PayoffStateChanged{NotStaged}`. **Nothing else clears a `BLOCKED` bay**
- [ ] **Mode B supervisor approval enforced by constraint** — this is a behaviour change for any code that wrote a Mode B checkout without one
- [ ] Line-state gate before tag clear; partial spool alpha only on Accept
- [ ] Operators flag, supervisors dispose; all audited

**Rate-card basis:** 2 command endpoints @ 6 h = 12 h + 2 services @ 6 h = 12 h → 24 h (§2)
**Dependencies:** FW-139, FW-176, FW-151
**Blockers:** **OQ-13** · **OQ-23**

---

###### FW-175 · Durable supervisor pending-approval queue
**Hours:** 16 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** BE

**As a** supervisor,
**I want** a pending disposition to survive my terminal disconnecting,
**So that** locked material is never stranded because a notification was missed.

**Acceptance Criteria:**
- [ ] Pending dispositions persisted to a durable queue, **not** carried only by a transient SignalR notification
- [ ] A supervisor connecting after the event still sees the pending item
- [ ] Items are claimable, and a claim is recorded with the supervisor id
- [ ] Resolution (Accept / Hold / Reject) closes the queue entry and writes the approval stamp

**Rate-card basis:** non-trivial business service 16 h — the discrete **G7** line item named in this phase's scope call (§2)
**Dependencies:** FW-174
**Blockers:** ⚠ **G7 — mid-run checkout supervisor approval currently relies only on transient SignalR.** This story is the fix; without it the approval path has no durability

---

###### FW-176 · `WipRejection` / `RodCheckout` tables and the shared `coils` carry-forward columns
**Hours:** 28 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** DB

**As a** developer,
**I want** carry-forward state on the rod record itself,
**So that** a part-run rod is identifiable at any station, not only inside one run.

**Acceptance Criteria:**
- [ ] `WipRejection` write path live with **nullable `RunId`** (the pre-check-in path has none); index `WipRejection(RunId)`
- [ ] `RodCheckout` write path live for Modes P / A / B with `PartialSpoolAlpha` and both dispositions; `CK_RodCheckout_ModeP` and `CK_RodCheckout_ModeB` enforce the per-mode field rules **in the database rather than in prose**; index `RodCheckout(RunId)`
- [ ] ⚠ **New columns on the shared `coils` table** — `footage_run_to_date`, `remaining_weight_estimate` — plus `source_rod_alpha` on `Spool`. **This is a second shared-schema change after FW-001 and needs its own impact audit**
- [ ] The delivered design is `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb` and `Spool.SourceRodAlpha`; the snake_case names in the May 2026 design doc are **proposals, not the schema**
- [ ] Status transitions wired on the `coils` rod row, `Spool.Status` and `CoilOutput.Status`
- [ ] Polymorphic `WipRejection.MaterialAlpha` (rod or spool, **no FK**) and `RodCheckout.PartialSpoolAlpha` (**no FK**) documented as such

**Rate-card basis:** 2 tables @ 4 h = 8 h + shared-schema columns 16 h *(named in the scope call)* + indexes 4 h = 28 h (§2)
**Dependencies:** FW-007, FW-001
**Blockers:** **G24** *(the approval columns exist now; PIN source is `OI-38`)* · **G21 / OQ-23**

---

###### FW-177 · Exception broadcasts and the supervisor notification
**Hours:** 16 h RT · **Priority:** Medium · **Sprint:** S2 · **Phase:** 7 · **Stream:** RT

**As a** supervisor,
**I want** holds and checkouts to reach the board and my terminal immediately,
**So that** I can act on locked material without being told verbally.

**Acceptance Criteria:**
- [ ] `AlertRaised` (WIP hold) → Dashboard 1
- [ ] **`RodCheckoutEvent` marker renders on the Dashboard 3 traces** as a run event *(DB14 was the previously-listed consumer and was descoped; DB3 is now named explicitly so the event is not left without one)*
- [ ] SignalR notification to the **Supervisor role** for a pending disposition, backed by FW-175's durable queue
- [ ] `LineStatus` → IDLE on checkout

**Rate-card basis:** 2 × hub event @ 8 h = 16 h (§2)
**Dependencies:** FW-149, FW-175
**Blockers:** **G7**

---

**Phase 7 reconciliation** — FE `20+24+20 = 64` · BE `24+16 = 40` · DB 28 · RT 16 · base **148** → QA `0.20 × 148 = 30` → Cont `0.15 × (148+30) = 27` → **205 h** ✓ (§3b)

---

##### S2–S3 · Phase 8 — FL2 Spool Check-In & Finishing Run

**Spec:** [`phase-08-fl2-spool-checkin-finishing-run.md`](Phases/phase-08-fl2-spool-checkin-finishing-run.md) · **Owning specifications:** [`SpoolQueue.md`](../../RequirementDocuments/SpoolQueue.md) (DB5A) · [`RocCheckin.md`](../../RequirementDocuments/RocCheckin.md) §4.3 (DB5) · [`SpoolCompletionNotification.md`](../../RequirementDocuments/SpoolCompletionNotification.md) · **Owner:** FE + BE · **118 h** (FE 48 · BE 18 · DB 12 · RT 8 · QA 17 · cont. 15)

> **This phase spans the sprint boundary: 59 h in S2, 59 h in S3**, matching the capacity model's even W5/W6 split. Story bodies are listed once, here.
>
> **⚠ The 118 h estimate predates Dashboard 5A** (added 2 Aug 2026) **and the DB3-FL2 re-mock. Re-estimate before committing.** DB5A is genuinely small — read-only, one endpoint, one table, no PLC, no state change — but it is not free.
>
> **FM2 has three stands: `S1` (8″) · `S2` (6″) + edger · `S3` (6″) + edger, final and non-bypassable.** The 8″ roller **is** S1. **A fourth FM2 row is a regression** (`D-26`).

---

###### FW-124 · Dashboard 5A — FL2 Spool Queue
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** FE

**As an** FL2 operator,
**I want** to see every spool available to run without scanning anything,
**So that** I know what material is waiting instead of guessing.

**Acceptance Criteria:**
- [ ] `dashboard-5a-spool-queue` at route `/flat-wire/line/FL2/spools`, built from `../Mockups/dashboard_5a_spool_queue.html`
- [ ] Structure: header · scan panel · context bar · list · footer, on the DB2A layout contract — definite `height: 1024px`, the list the only flexing child, `min-height: 0` on it and its table wrapper, **sticky on `th` not `thead`**
- [ ] **Two modes over one table, and the column set never changes between them** — a table that gains and loses columns as you scan reads as two tables and costs the operator their place. The `Order` column stays in both; alloy and temper get **no** columns because they are order-level and live in the context bar
- [ ] **All four scan outcomes are one response, not extra requests:** resolved order · **`404` unknown alpha (field marked, list unchanged)** · `200` with a null order and a single row for an **unallocated** spool (a real case — planning remainders and supervisor-accepted partials) · `200` with `eligible:false` for a spool that cannot run, **whose siblings still list**
- [ ] Check-in offered only for `RECEIVED` / `STAGED` spools, and leads to DB5
- [ ] **Read-only — it writes nothing**
- [ ] **Deliberately absent:** age (no `CreatedAt` on `Spool`), location (`Spool.Location` has no writer and no scheme), and any filter/sort furniture (the list is already limited to runnable material and the scan is the real filter)
- [ ] Covered by `TC-119`–`TC-126`

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-179
**Blockers:** **OQ-17** *(spool state machine — "available for processing" has no defined meaning without it)* · **OI-06** *(two unmapped spool status vocabularies)* · **OI-02** *(`SP-#####` vs `TS######`)* · ⚠ **confirmation that `Spool.OrderNo` is populated from planning — if allocation is not readable by the shopfloor system, `FR-098` has nothing to resolve and this screen is invalid**

---

###### FW-064 · Dashboard 5 — FL2 Spool Check-in
**Hours:** 16 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** FE

**As an** FL2 operator,
**I want** to check in a spool and see its FL1 history before I run it,
**So that** I know what I am finishing.

**Acceptance Criteria:**
- [ ] `dashboard-5-spool-checkin` from `../Mockups/dashboard_5_spool_checkin.html`
- [ ] Scan spool alpha; **source rods auto-populate from FL1 run traceability**; alloy/temper read-only; operator enters measured gauge/width and weights
- [ ] **Historical gauge profile** from the FL1 run with target, tolerance band and weld markers, plus a verdict badge — "✓ all in spec" or "⚠ N out of spec"
- [ ] FL2 pass-schedule table read-only, showing **exactly three stands** — `S1` (8″), `S2` (6″) + edger, `S3` (6″) + edger, final
- [ ] **No visual inspection** — done at FL1
- [ ] Acknowledge → push FL2 PLC tags → spool `INFLAT` → Dashboard 3 FL2 variant
- [ ] Reuses `pass-schedule-table` and `confirm-bar` from FW-133

**Rate-card basis:** new dashboard 24 h, discounted to 16 h — the schedule table, confirm-bar and trace chart are all reused (§2)
**Dependencies:** FW-133, FW-124, FW-179, FW-081
**Blockers:** **OQ-76** *(spool identifier)* · **OQ-15** *(hybrid-origin validation — must not apply a standalone FL2 schedule to hybrid material)*

---

###### FW-178 · Dashboard 3 FL2 variant configuration
**Hours:** 8 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 8 · **Stream:** FE

**As an** FL2 operator,
**I want** the run monitor to show spool-in and coil-out rather than payoffs,
**So that** the screen matches what my line actually does.

**Acceptance Criteria:**
- [ ] **Configures Phase 5's shell — does not reimplement it.** The differences are enumerable and are configuration, not a fork:
  - Middle status card → **Material flow** (spool in: alpha, source rods, load time, consumption bar, lb remaining/consumed · coil out: output alpha, take-up, fill bar, lb, ft/ft target, skid + coil-of-N badge)
  - Info grid subject → **Spool Information** (+ a width column FL1's omits, because material arriving here is already flattened)
  - Order Information → `Max Wgt of Spool` replaced by **`Coil Min–Max Wgt`**, the completion basis
  - Trace source → **Live / Profile toggle**, **Profile authoritative**
  - Action clusters → **no Die Change, no Weld**; **SPC Checkpoint is present** (FM2's S3 output is a specified checkpoint site)
- [ ] Components card shows **exactly three** FM2 rows with edgers on S2 and S3 only, and **no separate "8″ Roller" row**
- [ ] Check Out Rod disabled on a running line; **Complete Coil** is the only true navigation left
- [ ] Raises `fw-spc-checkpoint-dialog`, `fw-wip-rejection-dialog`, `fw-pause-dialog`/`fw-resume-dialog` and **`fw-roll-adjust-dialog`** (Phase 6), supplying **FL2's stand set**

**Rate-card basis:** screen variant of an existing screen 8 h (§2)
**Dependencies:** FW-062, FW-162, FW-163, FW-070
**Blockers:** **OQ-18** *(which order field carries the coil min–max weight range)*

---

###### FW-179 · `POST /checkin/spool` and `GET /spools`
**Hours:** 18 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** BE

**As a** client developer,
**I want** one spool endpoint serving both queue modes,
**So that** a scan resolves the order in a single call.

**Acceptance Criteria:**
- [ ] `CheckInController POST /checkin/spool`; `CheckInSpoolCommand` (spoolAlpha, measured gauge/width, weights, passScheduleId) → run response
- [ ] **`SpoolController GET /spools[?spoolAlpha=]` — one endpoint, two modes, identical response shape `{ order, spools[] }`.** Without the parameter it returns everything available for processing with a null order; with it, **the backend resolves the order** and returns it plus that order's spools in the same response
- [ ] **`404` only for an unknown alpha. An unallocated spool is a `200` with a null order** — conflating the two is the mistake to avoid
- [ ] DTO joins `CoilTraceability` / `WeldEvent` for source rods, the FL1 run for gauge/width, and the **shared order schema cross-database** for the order block
- [ ] `CheckInService` spool path pushes **FL2 tags only** — `S1`/`S2`/`S3` roll gaps and stand states plus edgers at S2/S3. **No DB or FM1 tags**
- [ ] Hybrid-origin validation guard
- [ ] Operator+ authorization

**Rate-card basis:** command endpoint 6 h + query endpoint 4 h + `CheckInService` spool path 8 h = 18 h (§2)
**Dependencies:** FW-139, FW-151, FW-180
**Blockers:** **OQ-15** · **OQ-17**

---

###### FW-180 · `SpoolCheckin` table and the `Spool.OrderNo` index
**Hours:** 12 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** DB

**As a** database owner,
**I want** the spool queue's filter covered by an index,
**So that** a `WHERE OrderNo =` on a `VARCHAR(50)` does not scan.

**Acceptance Criteria:**
- [ ] `SpoolCheckin` write path live, `LineId` restricted to FL2/FL3
- [ ] `FlatWireRun` FL2 run header created on check-in; `Spool.Status = INFLAT`
- [ ] **New index on `Spool.OrderNo`** — unindexed today. It also fixes DB5's scan, which validates against nothing
- [ ] Reads wired: source FL1 run gauge trace + `WeldEvent` markers, `Spool.SourceRunId` / `ParentRodAlpha`
- [ ] `Spool.ParentRodAlpha` documented as a **logical link to the rod's `coils` row**, not an FK to a local table

**Rate-card basis:** 2 tables/indexes @ 4 h = 8 h + FL2 run header wiring 4 h = 12 h (§2)
**Dependencies:** FW-007
**Blockers:** **OI-25** *(the two footage coordinate systems — `CoilOutput` accumulation vs `CoilTraceability`'s coil-local footage — are unreconciled)*

---

###### FW-181 · FL2 null-gauge contract and the Live/Profile binding
**Hours:** 4 h RT · **Priority:** High · **Sprint:** S3 · **Phase:** 8 · **Stream:** RT

**As an** FL2 operator,
**I want** the Live view to say plainly that there is no live gauge,
**So that** I never read a drawn line as a real measurement.

**Acceptance Criteria:**
- [ ] FL2 standalone broadcasts **`null`** for live gauge/width while still emitting `SpeedFPM`, `PayoffWeight`, `LineStatus`, `FootageCounter`, `ComponentStatus` — **this contract is unchanged**
- [ ] ⚠ **Live renders an explicit empty state when the field is `null`** — *"No live gauge on FL2 · see Profile"* — and **must not draw a flat line at target**, which would read as a real in-spec measurement. *(The mockup animates a simulated trace because a static prototype has no hub; the built screen must not.)*
- [ ] **Profile is the value of record on FL2 standalone** — the incoming spool's FL1 history on a **footage** x-axis, with weld markers and a whole-length verdict badge. **Static: it must not be re-rendered or re-sampled by the live tick**
- [ ] **Profile is the honest default** on FL2 standalone
- [ ] **The toggle's availability binds to line mode, not a hard-coded off** — on FL3 the same variant *does* receive live gauge/width, which is why the toggle exists at all

**Rate-card basis:** hub event binding 4 h (§2)
**Dependencies:** FW-081, FW-150
**Blockers:** —

---

###### FW-N02 · Spool completion weight milestones and machine-stop confirmation
**Hours:** 4 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 8 · **Stream:** RT

**As an** FL1 operator,
**I want** to be told as a spool approaches its target weight,
**So that** the machine stop is expected rather than a surprise.

**Acceptance Criteria:**
- [ ] Weight-milestone notifications raised as the spool approaches target, per [`SpoolCompletionNotification.md`](../../RequirementDocuments/SpoolCompletionNotification.md)
- [ ] Machine-stop confirmation surfaced to the operator
- [ ] **Completion is graded against the customer's min/max weight range from the order, by weight** — **not** by footage and **not** against the withdrawn 2,000 lb default, which had no basis and exceeded the TKUP-2 ceiling of 1,100 lb
- [ ] **A short close is a specified transaction:** inside the customer range → continue; outside it → **supervisor override + production hold, or an offer to the customer under concession before a remake is planned — the offer comes first**
- [ ] **The spool is run off either way** — FL2 has no spool stripper, so it must be emptied and returned to FL1 whatever is decided. A reject-and-remake path must never imply stopping and removing a part-full spool

**Rate-card basis:** hub event binding 4 h (§2)
**Dependencies:** FW-150
**Blockers:** **OQ-18** *(which order field carries the range)* · **OQ-79** · ⚠ **the 10-90 SOP document is not in this repository and must be obtained from Operations rather than paraphrased**

---

**Phase 8 reconciliation** — FE `24+16+8 = 48` · BE 18 · DB 12 · RT `4+4 = 8` · base **86** → QA `0.20 × 86 = 17` → Cont `0.15 × (86+17) = 15` → **118 h** ✓ (§3b) · **split 59 h S2 / 59 h S3**

**S2 total** — `255 + 154 + 298 + 205 + 59 = **971 h**` ✓ · 9 working days · **13.5 FTE**

---

#### S3 — Finished Goods, Back-Office and Go-Live

**Dates:** Mon 21 Sep – Wed 30 Sep 2026 · **8 working days** *(truncated at the 30 Sep target; natural boundary Fri 2 Oct)* · **64 h/person**
**Phases:** 8 *(finishes)* · 9 Output Coil Completion · 10 FL3 Hybrid · 11 Reporting & Certification · 12 Yield/Cost/Scrap · 13 Administration · 14 Integration, Commissioning & Go-Live
**Hours:** **1,104** · **Required FTE: 17.3**
**Goal:** finish a coil with traceability and a label, prove all three routes, and hand over.

**Entry criteria:** an FL1-produced spool exists; the critical-path phases are complete.
**Exit criteria:** FL2 finishes a coil with a label and traceability; FL3 hybrid runs end to end; the five reports render; three green E2E route runs; UAT signed off.
**Demo:** spool → FL2 → coil → skid → certificate query; FL3 in one pass; the three-route E2E and the cert pack.
**Gates:** **M4 (20–27 Sep)** · **QA3 (24 Sep)** FL1 + FL2 E2E pass · **QA4 (28 Sep)** FL3 E2E + renamed-column regression · **QA5 (30 Sep)** full UAT · **M5 (30 Sep)** feature-complete.

> ## ⚠ This sprint is where the arithmetic breaks
>
> **Seven phases in 8 working days at 17.3 FTE**, including the sequential `8→9→10` chain and the whole of Phase 14 — three E2E route runs, PLC commissioning support, renamed-column regression **and** full UAT with stakeholder sign-off. **UAT cannot begin the day feature work completes.**
>
> Two mitigations, neither of which is this document's to choose:
> - **Extend S3 to its natural 2 Oct boundary** — costs two days, drops the peak to **13.8 FTE**. Cheapest relief in the plan.
> - **Pull Phase 14 into a dedicated post-feature-complete window**, which `CapacityAndEffortModel.md` §7 recommends regardless of team size.
>
> The descope ladder ([§5](#5-descope-ladder-mapped-to-sprints)) recovers at most 448 h across the whole programme — about 12% — and every rung of it lands in this sprint.

---

##### S3 · Phase 9 — Output Coil Completion, Labeling & Packing

**Spec:** [`phase-09-output-coil-completion-labeling-packing.md`](Phases/phase-09-output-coil-completion-labeling-packing.md) · **Owning specification:** [`OutputCoilCompletion.md`](../../RequirementDocuments/OutputCoilCompletion.md) v1.1 (owns **DB7 and DB7b**) · **Owner:** FE + BE · **222 h** (FE 104 · BE 26 · DB 16 · RT 8 · QA 31 · BA 8 · cont. 29)

> **Wholly MVP-1, and the 222 h figure is whole and correct.** DB7, DB7b, both coil endpoints, `CoilCompletionService` and `FW-066` were briefly carved to MVP-2 and **returned the same day**. The carve did not hold because `CoilOutput` and `CoilTraceability` are MVP-1 — the coil genealogy behind the **welding-wire customer certificates** is an MVP-1 obligation — but their **only writer** had gone to MVP-2, leaving the non-overlap trigger guarding rows nothing inserted.
>
> **⚠ Four dependencies came back with it and none is costed** — gap **`G36`**: `OI-104` (`CoilOutput.SkidId` references a skid table nothing names, creates or verifies) · `OI-24` / `OI-99` (the label returns a `lotNumber` with **no generator at all**, and no rule for the multi-rod case) · `OI-105` (`FR-346` adds a **physical scale weight** at the packing station — a third weight figure after the calculated value and DB7's override, with no rule for which governs) · `OI-106` (closure must assign a staging location and none are defined).
>
> **⚠ Estimate provisional — 16–32 h reserve excluded, and understated.** It was scoped before DB7b's physical scale weight was in MVP-1.

---

###### FW-066 · Dashboard 7 — Output Coil Completion
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As an** FL2 operator,
**I want** to confirm the finished coil with its calculated details,
**So that** the customer-facing record is created correctly at the moment the coil comes off.

**Acceptance Criteria:**
- [ ] `dashboard-7-coil-completion` from `../Mockups/dashboard_7_coil_completion.html`
- [ ] System-calculated details: new alpha **`FW-#####-C##`** (mid-run child `…-A`), alloy/temper, footage
- [ ] **Gauge and width shown as the TARGET when in tolerance**, not the measured average
- [ ] **Net weight = footage × density factor, with an operator scale override**
- [ ] Final SPC in-spec badges; out-of-spec → **Submit · Suspend** as the primary action, routing to supervisor review
- [ ] Skid tracking: **Coil 1 of 2 (skid open) / Coil 2 of 2 (close + print skid label)** — exactly 2 per skid
- [ ] **Print Coil Label** is a physical label, **not the traveler** — the traveler is fully digital
- [ ] **Confirm & Move to Packing** → coil `COMPLETE`, skid linked, run complete, Dashboard 1 → IDLE
- [ ] Density factor pending → "pending confirmation" state plus the override, rather than a wrong number

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-183, FW-184, FW-185
**Blockers:** **OQ-10** *(footage→weight — **Critical**)* · **OI-45** *(dimensional basis)* · **OI-105** *(three weight figures, no precedence rule)* · **OI-98** *(odd final coil)* · **OI-25**

---

###### FW-182 · Dashboard 7b — Packing Station
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As a** packing operator,
**I want** a station view of skids ready to close,
**So that** finished coils are packed and labelled without going back to the run screen.

**Acceptance Criteria:**
- [ ] `dashboard_7b_packing_station.html` built as a screen in its own right
- [ ] Packing queue driven by skid-closed events
- [ ] **Physical scale weight capture** (`FR-346`) — a second capture point after DB7's calculated value and override
- [ ] ⚠ **Which of the three weight figures governs the coil record is undecided (`OI-105`)** — surface all three rather than silently picking one, and flag the story as blocked on that rule
- [ ] Skid label printing
- [ ] Four of this screen's eight requirements are **mockup-derived and tagged `[PROPOSED]`** — confirm before building

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-066, FW-185
**Blockers:** **OI-105** *(weight precedence)* · **OI-106** *(no staging locations defined)* · **OI-104** *(no skid table)* · **OQ-4** *(skid labelling)*

---

###### FW-183 · `source-traceability-table` and `skid-tracker`
**Hours:** 40 h FE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As a** quality engineer,
**I want** each coil to show which source rods produced which footage,
**So that** a welding-wire certificate can be issued.

**Acceptance Criteria:**
- [ ] `source-traceability-table` — **one row per source rod with footage-from/to at each weld boundary**
- [ ] `skid-tracker` — 1-of-2 / 2-of-2 state, skid open/closed, skid id
- [ ] Both read from the `POST /coil/complete` response rather than issuing their own queries
- [ ] Footage ranges are **non-overlapping per coil**, matching the database trigger

**Rate-card basis:** 2 × shared composite control @ 20 h = 40 h (§2)
**Dependencies:** FW-185
**Blockers:** **OI-25** *(coil-local vs run-accumulated footage unreconciled)* · **OI-99** *(lot number for a multi-rod coil)*

---

###### FW-184 · `coil-label` and the print path
**Hours:** 16 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As a** packing operator,
**I want** a correct physical coil label,
**So that** the coil is identifiable in the warehouse and on the customer's dock.

**Acceptance Criteria:**
- [ ] `coil-label` renders every label field including **source rod alphas** and the lot number
- [ ] Printing via the `shared` `print-export.service`
- [ ] **This is a label, not the traveler.** Coil and skid labels print; the traveler does not
- [ ] ⚠ **`lotNumber` has no generator** — surface the gap rather than emitting a blank or invented value

**Rate-card basis:** shared composite control 20 h, discounted to 16 h — printing reuses `print-export.service` (§2)
**Dependencies:** FW-185
**Blockers:** **OI-24 / OI-99** *(no lot-number generator at all, and no rule for the multi-rod case)*

---

###### FW-185 · `POST /coil/complete`, `GET /coil/{alpha}/label` and their services
**Hours:** 26 h BE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** BE

**As a** developer,
**I want** completion to generate the alpha, build the genealogy and close the skid in one transaction,
**So that** no coil exists without its traceability.

**Acceptance Criteria:**
- [ ] `CoilController POST /coil/complete` → coil alpha, skid id/status, footage total, `sourceTraceability[]`, `finalSpc`; `CompleteCoil` handler
- [ ] `GET /coil/{alpha}/label` → label DTO including source rod alphas and lot; `GetCoilLabel` handler
- [ ] `CoilCompletionService`: alpha generation, **traceability built from weld boundaries**, footage→weight via the alloy factor, the 2-per-skid rule, and marking the run complete
- [ ] **`LabelService`** for the coil label
- [ ] **2 coils per skid enforced**; gauge/width target-when-in-tolerance
- [ ] **The pass-schedule id + snapshot is written to the coil record** so a certificate stays reproducible after the schedule is later edited
- [ ] Operator+ authorization

**Rate-card basis:** command endpoint 6 h + query endpoint 4 h + `CoilCompletionService` 12 h + `LabelService` 4 h = 26 h (§2)
**Dependencies:** FW-139, FW-186, FW-171
**Blockers:** **OQ-10** *(Critical)* · **OI-104** *(`SkidId` has no target table)*

---

###### FW-186 · `CoilOutput`, `CoilTraceability` and the non-overlap trigger
**Hours:** 16 h DB · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** DB

**As a** quality owner,
**I want** overlapping footage ranges to be impossible,
**So that** a certificate cannot attribute the same foot to two rods.

**Acceptance Criteria:**
- [ ] `CoilOutput` write path live — alpha, weights, final gauge/width, `SkidId`, `SkidStatus`, `Status='COMPLETE'`, in-spec flags
- [ ] `CoilTraceability` write path live — footage ranges → rod alphas
- [ ] **`trg_CoilTraceability_NoOverlap` enforced and now actually exercised** — it had been guarding rows nothing inserted while the writer sat in MVP-2
- [ ] Indexes `CoilTraceability(CoilAlpha)` and `(RodAlpha)`
- [ ] `FlatWireRun.Status='Complete'` / `CompletedAt` written
- [ ] **`CoilOutput.SkidId` references an external skid table with no DB FK** — documented as such
- [ ] Genealogy query returns coil → `coils` R-series row → heat/lot across databases

**Rate-card basis:** 2 tables @ 4 h = 8 h + trigger/index hardening 4 h + run-completion write 4 h = 16 h (§2)
**Dependencies:** FW-007
**Blockers:** **OI-104** · **G36**

---

###### FW-187 · Completion broadcasts
**Hours:** 8 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 9 · **Stream:** RT

**As a** supervisor,
**I want** the board and the packing station to reflect completion immediately,
**So that** the next job can be started without asking.

**Acceptance Criteria:**
- [ ] `LineStatus` → IDLE on completion, reaching Dashboard 1
- [ ] Skid closed → packing-queue update reaching Dashboard 7b
- [ ] Both sent as rare domain events, immediate and unbatched

**Rate-card basis:** hub event 8 h (§2)
**Dependencies:** FW-149, FW-185
**Blockers:** —

---

###### FW-188 · Footage→weight basis and skid labelling
**Hours:** 8 h BA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** BA

**As a** business analyst,
**I want** the weight basis and the skid rules settled,
**So that** the most widely-depended-on number in the build stops being provisional.

**Acceptance Criteria:**
- [ ] **OQ-10** closed — the **dimensional basis** for footage→weight decided: target-derived, measured-at-completion, or integrated over `RunReading`. *(The formula is settled; the basis is not, and integrating is materially more work than the other two.)* **This question deliberately carries no recommendation — it is a measurement question United Aluminum must answer from its own practice**
- [ ] **OI-105** closed — which of the three weight figures governs the coil record
- [ ] **OQ-4** closed — skid labelling
- [ ] **OI-98** progressed — what happens to an odd final coil
- [ ] Outcomes recorded in the register

**Rate-card basis:** BA / Ops liaison 8 h (§2)
**Dependencies:** None
**Blockers:** **OQ-10** *(Critical, and the most widely depended-on number in the build)*

---

**Phase 9 reconciliation** — FE `24+24+40+16 = 104` · BE 26 · DB 16 · RT 8 · dev base **154** · BA 8 → QA `0.20 × 154 = 31` → Cont `0.15 × (154+8+31) = 29` → **222 h** ✓ (§3b) · **+16–32 h reserve excluded, and understated**

---

##### S3 · Phase 10 — FL3 Hybrid Continuous Operation

**Spec:** [`phase-10-fl3-hybrid-continuous-operation.md`](Phases/phase-10-fl3-hybrid-continuous-operation.md) · **Owner:** BE + FE · **61 h** (FE 12 · BE 20 · DB 4 · RT 8 · QA 9 · cont. 8)

> **The cheapest phase in the plan and explicitly not deferrable** — FL3 is one of the three production routes. It reuses Phases 4–6 and 9 behind mode flags; only the FL3 screen variants and the single-batch hybrid push are new. **The FL3 E2E (`FW-122`) is costed in Phase 14, not here.**

---

###### FW-189 · Dashboard 2 and 3 FL3 variants
**Hours:** 12 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 10 · **Stream:** FE

**As an** FL3 operator,
**I want** the check-in and run screens in hybrid mode,
**So that** one acknowledgement configures both mills.

**Acceptance Criteria:**
- [ ] `dashboard_2_rod_checkin` and `dashboard_3_active_run_fl3.html` variants configured from the shared shells — **not forked**
- [ ] Action bar **includes Roll Adjust** (`FR-108`), supplying **FL3's** stand set to the Phase-6 dialog
- [ ] Real-time trace runs continuously end to end; **no FL2 historical switch**
- [ ] **No intermediate spool alpha is generated or displayed**
- [ ] FL1 and FL2 shown unavailable while FL3 runs

**Rate-card basis:** 2 screen variants — check-in 8 h + run-monitor configuration 4 h = 12 h (§2)
**Dependencies:** FW-061, FW-062, FW-070
**Blockers:** **OQ-2 / OQ-67** *(FL3 blocks FL1/FL2 — decided)*

---

###### FW-190 · Hybrid single-batch PLC push and `RouteMode=Hybrid`
**Hours:** 20 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 10 · **Stream:** BE

**As an** FL3 operator,
**I want** one acknowledgement to configure FM1 and FM2 together,
**So that** material flows continuously without a second check-in.

**Acceptance Criteria:**
- [ ] `CheckInRod` with `route=Hybrid` → `PLCTagService` pushes **all FM1 + FM2 tags in one batch**
- [ ] **No `Spool` row is created** — there is no intermediate spool on a hybrid run
- [ ] `FlatWireRun.RouteMode = Hybrid`
- [ ] **Single-push failure → full compensating clear** across both mills
- [ ] Hybrid schedule selection validated; a standalone FL2 schedule must not be applied to hybrid material

**Rate-card basis:** hybrid push logic 12 h + route-mode and no-spool branch 8 h = 20 h (§2)
**Dependencies:** FW-157, FW-082
**Blockers:** **OQ-15** *(hybrid schedule model — Option A assumed)* · ⚠ **G30 — FM2's controller namespace on FL3 is undetermined, which decides what a partial push failure even means**

---

###### FW-191 · `RouteMode` and the no-intermediate-spool rule
**Hours:** 4 h DB · **Priority:** Medium · **Sprint:** S3 · **Phase:** 10 · **Stream:** DB

**As a** developer,
**I want** hybrid runs distinguishable in the data,
**So that** reports and certificates can tell the three routes apart.

**Acceptance Criteria:**
- [ ] `FlatWireRun.RouteMode` accepts `Hybrid` with an enumerating `CHECK`
- [ ] A hybrid run has **no** `Spool` row, and this is assertable by query
- [ ] `CoilOutput` / `CoilTraceability` behave exactly as in Phase 9

**Rate-card basis:** column + constraint as part of the table rate (4 h, §2)
**Dependencies:** FW-006
**Blockers:** —

---

###### FW-192 · Continuous end-to-end trace on FL3
**Hours:** 8 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 10 · **Stream:** RT

**As an** FL3 operator,
**I want** the trace to run unbroken from rod to coil,
**So that** traceability is continuous across the whole hybrid run.

**Acceptance Criteria:**
- [ ] Continuous `GaugeReading` / `WidthReading` end to end — **no FL2 historical switch mid-run**
- [ ] Weld events mid-run keep the traceability chain continuous
- [ ] The Live/Profile toggle is **available** on FL3, because a hybrid run genuinely has both

**Rate-card basis:** hub event binding 8 h (§2)
**Dependencies:** FW-081, FW-181
**Blockers:** —

---

**Phase 10 reconciliation** — FE 12 · BE 20 · DB 4 · RT 8 · base **44** → QA `0.20 × 44 = 9` → Cont `0.15 × (44+9) = 8` → **61 h** ✓ (§3b)

---

##### S3 · Phase 11 — Reporting & Certification

**Spec:** [`phase-11-shift-summary-reporting-certification.md`](Phases/phase-11-shift-summary-reporting-certification.md) · **Owner:** BE + FE · **MVP-1 175 h** (FE 40 · BE 56 · DB 20 · RT 4 · QA 24 · BA 8 · cont. 23)

> **⚠ Dashboard 10 (Shift Summary) is MVP-2** — the screen, `GET /shiftsummary`, `ShiftSummaryService`, `sp_ShiftSummary` and story `FW-069` were carved out verbatim. **The published 246 h figure was never apportioned and overstates MVP-1**; the MVP-1 figure is **175 h**, derived in `CapacityAndEffortModel.md` §3b by re-pricing each carved deliverable off the rate card.
>
> **`sp_ShiftSummary` must not be created, dropped or granted from this scope.**
>
> **Partly deferrable — `FW-092`/`093`/`094`/`095` are ladder rung 6 (105 h), latest call inside S2.** Only the Gauge Trace report would survive. **`FW-095` Cut Traceability is needed before first shipment**, which is why this phase could not be deferred whole.

---

###### FW-090 · Flattening Lines report tab and reporting views
**Hours:** 16 h BE · 20 h DB · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** BE + DB

**As a** quality engineer,
**I want** flat wire to appear as a tab in the existing Reports application,
**So that** I use the reporting tool I already know.

**Acceptance Criteria:**
- [ ] The existing `Reports` service extended with a **Flattening Lines** tab — not a new reporting application
- [ ] Reporting views and stored procedures created in `08_Programmability` for the five reports
- [ ] Dapper aggregations over `SpcCheckpoint` / `SpcMeasurement`, `RunPauseEvent`, `WeldEvent`, `CoilOutput`, `CoilTraceability`, `FlatWireRun`, `WipRejection`
- [ ] Shift-window filter indexes on timestamp + line
- [ ] Supervisor+ authorization

**Rate-card basis:** BE tab extension 16 h + 2 reporting views/procs @ 8 h + index work 4 h = 20 h DB (§2)
**Dependencies:** FW-152, FW-186
**Blockers:** **OI-101** *(shift boundaries are undefined — this blocks every shift-scoped figure)*

---

###### FW-091 · Gauge Trace report
**Hours:** 8 h FE · 8 h BE · 4 h RT · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE + RT

**As a** quality engineer,
**I want** the gauge trace for any run,
**So that** I can review dimensional performance after the fact.

**Acceptance Criteria:**
- [ ] **Real-time view for FL1/FL3** (reusing the hub) and **historical for FL2**
- [ ] Weld markers rendered on the trace
- [ ] Reads `RunReading` via `sp_GetGaugeTrace`
- [ ] Export and print via `print-export.service`

**Rate-card basis:** report 8 h FE + 8 h BE (§2) + live-view hub reuse 4 h RT
**Dependencies:** FW-090, FW-165, FW-081
**Blockers:** —

> **The only report that survives descope rung 6.** If the rung is taken, this ships and the four below do not.

---

###### FW-092 · Gauge CPK Deviation and CPK report
**Hours:** 8 h FE · 8 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** process engineer,
**I want** capability indices across product families,
**So that** I can show the process is in control.

**Acceptance Criteria:**
- [ ] CPK computed over `RunReading` against the alloy's tolerance bands
- [ ] Filter `Strip / Flat Wire / All`
- [ ] Deviation and CPK presented together

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090
**Blockers:** **OI-57** *(tolerance bands)* · **descope ladder rung 6**

---

###### FW-093 · Coil Pass Detail report
**Hours:** 8 h FE · 8 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** process engineer,
**I want** the pass detail behind a finished coil,
**So that** I can reconstruct how it was made.

**Acceptance Criteria:**
- [ ] Per-coil pass detail drawn from the pass-schedule **snapshot written at check-in**, not from the live schedule
- [ ] Includes mid-run overrides from `RollOverride` and die changes from `DieChangeEvent`
- [ ] Export and print

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090, FW-185
**Blockers:** **descope ladder rung 6**

---

###### FW-094 · SPC at Flattening Line report
**Hours:** 8 h FE · 8 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** quality engineer,
**I want** every SPC checkpoint in one report,
**So that** I can audit quality gates across a shift or an order.

**Acceptance Criteria:**
- [ ] Covers **all five checkpoint types** — `PreRun`, `PostDieChange`, `RollAdjustTrigger`, `ManualSpotCheck`, `PostRun`
- [ ] In/out of spec flagged per measurement
- [ ] Filterable by line, run, order and date range

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090, FW-171
**Blockers:** **descope ladder rung 6**

---

###### FW-095 · Cut Traceability report
**Hours:** 8 h FE · 8 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** quality engineer,
**I want** to trace a finished coil back to heat,
**So that** I can issue a welding-wire certificate of conformance.

**Acceptance Criteria:**
- [ ] Full chain rendered: **Coil → Spool → Rod → Lot → Heat**
- [ ] Cross-database join from `CoilTraceability` through the `coils` R-series row to the existing chemistry/`Lots` tables
- [ ] Footage attribution per source rod, from the weld boundaries
- [ ] Export in a form the certificate pack can consume

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090, FW-186, FW-183
**Blockers:** **OQ-5 / OQ-25** *(cert granularity and frequency)* · **OI-99** *(lot number for a multi-rod coil)* · **descope ladder rung 6**

> **⚠ Needed before first shipment.** It is on rung 6 with the other three, but deferring it has a different consequence: no certificate. Treat it as the rung's exception when the call is made in S2.

---

###### FW-193 · Certification granularity and tolerance bands
**Hours:** 8 h BA · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** BA

**As a** business analyst,
**I want** the certificate's granularity and the report tolerance bands settled,
**So that** the traceability report matches what the customer is owed.

**Acceptance Criteria:**
- [ ] **OQ-5 / OQ-25** closed — certificate granularity and frequency
- [ ] **OI-57** closed — tolerance bands for the CPK report
- [ ] **OI-84** closed — WIP report columns, with Shannon R.
- [ ] **OI-101** raised to a decision — shift boundaries, which block every shift-scoped figure
- [ ] Outcomes recorded in the register

**Rate-card basis:** BA / Ops liaison 8 h (§2)
**Dependencies:** None
**Blockers:** **OI-101**

---

**Phase 11 reconciliation** — FE `8×5 = 40` · BE `16+(8×5) = 56` · DB 20 · RT 4 · dev base **120** · BA 8 → QA `0.20 × 120 = 24` → Cont `0.15 × (120+8+24) = 23` → **175 h** ✓ (§3b MVP-1 carve)

---

##### S3 · Phase 12 — Yield, Cost Ledger & Scrap

**Spec:** [`phase-12-yield-cost-ledger-scrap.md`](Phases/phase-12-yield-cost-ledger-scrap.md) · **Phase sheet:** [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md) · **Owner:** BE · **177 h** (FE 44 · BE 72 · DB 12 · QA 26 · cont. 23)

> **⚠ This phase is the whole of descope ladder rungs 1–4** (177 h). Latest call: **inside S2**.
>
> **⚠ Read the phase sheet before scheduling.** It records that **`FW-101`, `FW-102` and `FW-110` carry no `FR-` IDs and the phase has no owning requirement document** — its 177 h was priced against four Jira cards. The sheet also carries the AI-assisted view at **126 h**.
>
> **Story bodies absorbed from `YieldCostAndScrapJiraStories.md`** on 13 Aug 2026 under the single-backlog decision. That file is now a pointer; **`YieldCostAndScrapSheet.md` remains the Phase-12 hours authority** and its 33/49/28/67 ladder split reconciles exactly to the figures below.

---

###### FW-100 · Footage-based yield and the weight formula
**Hours:** 24 h FE · 24 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE

**As a** production controller,
**I want** yield calculated from footage,
**So that** flat wire is measured the way it is actually produced.

**Acceptance Criteria:**
- [ ] Yield form gains a **"Flat Wire" checkbox** and the flat-wire field renames
- [ ] Weight computed as **footage × area × density**; `CoilYield` extended
- [ ] **Scrap is calculated in footage, not weight**, on the Material Loss tab
- [ ] Reads `CoilTraceability` / `WeldEvent` / `CoilOutput`
- [ ] Renamed yield fields from FW-001 consumed correctly

**Rate-card basis:** ladder rung 4 remainder — **67 h all-in**; dev base 48 h (§2, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-001, FW-186
**Blockers:** **OQ-10** *(gates the weight formula)* · **OI-60** *(metallic yield per route)*

---

###### FW-101 · Weld traceability attribution in yield
**Hours:** 20 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 12 · **Stream:** BE

**As a** quality owner,
**I want** yield attributed per source rod across weld points,
**So that** welding-wire certificates carry correct per-rod figures.

**Acceptance Criteria:**
- [ ] Yield rows produced per source rod, split at each weld boundary
- [ ] Multi-rod coils produce multiple yield rows that sum to the coil total
- [ ] Reads the `CoilTraceability` genealogy built in Phase 9

**Rate-card basis:** ladder rung 3 — **28 h all-in**; dev base 20 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-186, FW-100
**Blockers:** **OI-60** · ⚠ **descope ladder rung 3 — deferring this affects welding-wire certificates**, which is why the rung needs Tim O. / Quality sign-off rather than a programme decision

---

###### FW-102 · Flat-wire cost ledger configuration
**Hours:** 12 h FE · 20 h BE · 4 h DB · **Priority:** Medium · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE + DB

**As a** cost accountant,
**I want** flat-wire cost standards configurable,
**So that** costing reports are not blank for the new lines.

**Acceptance Criteria:**
- [ ] Cost ledger configuration UI for flat wire
- [ ] `CoilCosting` extended with flat-wire cost standards and standard times
- [ ] Costing reports render for FL1/FL2/FL3

**Rate-card basis:** ladder rung 2 — **49 h all-in**; dev base 36 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-100
**Blockers:** **OI-68** *(costing and standard times — both open)*

---

###### FW-110 · Scrap Box / Scrap Skid outlet
**Hours:** 8 h FE · 8 h BE · 8 h DB · **Priority:** Low · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE + DB

**As a** scrap operator,
**I want** scrap routed to the right outlet,
**So that** flat-wire scrap is handled like every other material.

**Acceptance Criteria:**
- [ ] Scrap module outlet supports **`Scrap Box`** and **`Scrap Skid`**
- [ ] Outlet applies to Flat Wire, Conveyors and Inspection
- [ ] Scrap services extended

**Rate-card basis:** ladder rung 1 — **33 h all-in**; dev base 24 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-100
**Blockers:** **OI-83** *(baler/banding)* · **descope ladder rung 1 — first thing off the plan**

---

**Phase 12 reconciliation** — FE `24+12+8 = 44` · BE `24+20+20+8 = 72` · DB `4+8 = 12` · base **128** → QA `0.20 × 128 = 26` → Cont `0.15 × (128+26) = 23` → **177 h** ✓ (§3b) · ladder split `33+49+28+67 = 177` ✓

---

##### S3 · Phase 13 — Administration & Reference Data

**Spec:** [`phase-13-administration-reference-data.md`](Phases/phase-13-administration-reference-data.md) · **Owner:** FE + BE · **MVP-1 143 h** (FE 56 · BE 32 · DB 8 · RT 4 · QA 20 · BA 4 · cont. 19)

> **⚠ Die Management is MVP-2** — the screen, the die lifecycle service and the die inventory status vocabulary were carved out verbatim. **The published 209 h figure was never apportioned and overstates MVP-1**; the MVP-1 figure is **143 h**.
>
> **⚠ Correction to `phase-13`'s own callout.** That file's MVP-2 banner says *"The `FW-N07` table half is also MVP-1… the 8 h costed for the missing die table stays here."* **That is stale and contradicted by the same file's scope call**, by `CapacityAndEffortModel.md` §3b (which lists "Die inventory table — 8 h DB" among the carved deliverables) and by the repository guide. **`FW-N07` is wholly MVP-2 and the 8 h left with the screen.** MVP-1's die change validates against the **`Drawer` size catalogue seeded in Phase 1**, so no die master table is needed here.
>
> **Partly deferrable — the role-assignment UI is the deferrable part of ladder rung 5.** The alloy lookup and machine tabs are not. **Rung 5's published 99 h is no longer available in full**, because it bundled the now-MVP-2 Die Management screen with the MVP-1 role UI.

---

###### FW-194 · Alloy lookup admin grid
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As a** process engineer,
**I want** to maintain alloy properties and tolerance bands without a code change,
**So that** reference data can be corrected as the mill learns the process.

**Acceptance Criteria:**
- [ ] Admin grid over `AlloyProperty` with create, edit and audit history
- [ ] **Maintains four min/max pairs, not two single ± values** — the bands are **offsets about nominal and may be asymmetric**, so the editor **must not collapse them to one field**. Ovality takes an **upper limit only**
- [ ] Restricted to Process Engineering / Admin; every edit audit-logged
- [ ] Fields left NULL pending the client e-mail render as explicitly unset, not as zero
- [ ] The `0.003"` ovality limit is edited here, never in code

**Rate-card basis:** new dashboard 24 h, discounted to 20 h — an admin grid over one table (§2)
**Dependencies:** FW-004, FW-196
**Blockers:** ⛔ **OQ-22** *(the width, height, diameter and ovality values are owed by client e-mail; they also need Process Engineering sign-off)*

---

###### FW-054 · Alloys — Material Type across Properties, Reduction Rules and Vendor O Gauge
**Hours:** 12 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As a** process engineer,
**I want** Material Type carried consistently across the alloy screens,
**So that** flat wire and strip are distinguishable wherever alloy data is edited.

**Acceptance Criteria:**
- [ ] Material Type surfaced on the Alloy Properties, Reduction Rules and Vendor O Gauge screens
- [ ] Existing strip behaviour unchanged
- [ ] Consistent with the `AlloyProperty` model from FW-004

**Rate-card basis:** 3 screen extensions @ 4 h = 12 h (§2)
**Dependencies:** FW-194
**Blockers:** —

> **Re-homed from the deleted Epic 6** ("Web App Changes"), whose other five stories were upstream. It sits beside `FW-004`, the alloy lookup it belongs with.

---

###### FW-003 · Machine template tabs — register FL1, FL2, FL3
**Hours:** 12 h FE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As a** system administrator,
**I want** the three flattening lines registered as fully configured machines,
**So that** scheduling, planning, reporting and shopfloor can all reference them.

**Acceptance Criteria:**
- [ ] FL1, FL2, FL3 each have a unique `MachineId` / `IdNo` and appear in **every** machine dropdown system-wide
- [ ] Machine template tabs configured: Main (combined Slitter + Mill rows) · Roll Finish · **Pass Schedule** (button renamed *"Flattening Line Schedule"*) · Coating · KSI/Gauge Max Cuts (*"Max # of Cuts"* column removed) · Rewind Capabilities · ID Width Max Cuts · Setup/Handling Times · Tooling Inventory (+ **Dies and Edgers** as new tooling types) · **Speed** (*"Min/Max Gauge"* → *"Min/Max Gauge/Diameter"*; checkboxes for **DB1, DB2, FM1-S1, FM2-S1/S2/S3**) · Material Loss (**scrap in footage, not weight**) · History
- [ ] Operation letter **`F`** used for flattening in `OpLetter` / `PrevOpLetter` / `RemainingOps`
- [ ] **The Speed tab's checkboxes name three FM2 stands — `FM2-S1`, `FM2-S2`, `FM2-S3`. There is no fourth**

**Rate-card basis:** 12 template tabs, priced as configuration rather than new screens (12 h, §2)
**Dependencies:** FW-001, FW-002
**Blockers:** ⚠ **the Naj/Bob/Tim standards spreadsheet must be finalised first — an external dependency**

---

###### FW-195 · Role assignment UI
**Hours:** 12 h FE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As an** administrator,
**I want** to assign flat-wire roles without a DBA,
**So that** operator and supervisor access is managed in the application.

**Acceptance Criteria:**
- [ ] Assign Operator / Operations Manager / Maintenance / Supervisor / Admin
- [ ] Matches the Authorization Matrix policies from FW-145
- [ ] Changes audit-logged

**Rate-card basis:** shared composite control 20 h, discounted to 12 h — it drives existing role policies (§2)
**Dependencies:** FW-145, FW-196
**Blockers:** **G6** · ⚠ **descope ladder rung 5 — if deferred, roles are assigned by a DBA**

---

###### FW-196 · Alloy CRUD, machine config and role config endpoints
**Hours:** 32 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 13 · **Stream:** BE

**As a** developer,
**I want** the admin surfaces backed by audited, restricted endpoints,
**So that** reference data cannot be changed anonymously.

**Acceptance Criteria:**
- [ ] Alloy CRUD — **audit-logged and role-restricted**
- [ ] Machine configuration endpoints for the template tabs
- [ ] Role/permission configuration endpoints
- [ ] Every write records who, what and when
- [ ] **The die lifecycle service is not built here — it is MVP-2**

**Rate-card basis:** alloy CRUD service 16 h + machine config 8 h + role config 8 h = 32 h (§2)
**Dependencies:** FW-139, FW-145
**Blockers:** —

---

###### FW-197 · Reference-data admin wiring
**Hours:** 8 h DB · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13 · **Stream:** DB

**As a** developer,
**I want** the non-die lookups editable through the admin surface,
**So that** stands, drawers, edgers and spool configurations are maintainable.

**Acceptance Criteria:**
- [ ] `Stand`, `Drawer`, `Edger` and `SpoolConfiguration` reachable through the admin endpoints
- [ ] Audit columns populated on edit
- [ ] **`Drawer` is already seeded in Phase 1** — this exposes it, it does not create it
- [ ] **No die inventory table is created** — die inventory and lifecycle are owned outside MVP-1

**Rate-card basis:** non-die reference-data wiring 8 h (§2, §3b — this is the surviving DB line after the die-table carve)
**Dependencies:** FW-005, FW-196
**Blockers:** **OI-77 / OI-43** *(edger profiles and roll spares)*

---

###### FW-198 · Reference-data change broadcast
**Hours:** 4 h RT · **Priority:** Low · **Sprint:** S3 · **Phase:** 13 · **Stream:** RT

**As an** operator,
**I want** a tolerance change to reach open screens,
**So that** I am not validating against a stale band.

**Acceptance Criteria:**
- [ ] Reference-data changes broadcast so open clients refresh their cached lookups
- [ ] Sent as a rare domain event, immediate and unbatched

**Rate-card basis:** hub event 8 h, discounted to 4 h — one event over existing infrastructure (§2)
**Dependencies:** FW-149, FW-196
**Blockers:** —

---

###### FW-199 · Alloy tolerance values and die-life thresholds
**Hours:** 4 h BA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 13 · **Stream:** BA

**As a** business analyst,
**I want** the outstanding alloy values chased and the die-life thresholds settled,
**So that** `CHK007` can finally fire.

**Acceptance Criteria:**
- [ ] ⛔ **OQ-22** closed — width, height, diameter and ovality tolerance values received by e-mail **and** signed off by Process Engineering
- [ ] Die-life threshold configurability decided (**OQ-83** die-life tracking is decided; the threshold is not)
- [ ] **OI-77 / OI-43** progressed — edger profiles and roll spares
- [ ] Outcomes recorded in the register

**Rate-card basis:** BA / Ops liaison 4 h (§2)
**Dependencies:** None
**Blockers:** ⛔ **OQ-22 — this also blocks Phase 4.** Tim confirmed the tolerances exist and would send them; he did not have them to hand. **Nothing is seeded until they arrive**, and the Dashboard 2A mock map must not be used as a substitute

---

**Phase 13 reconciliation** — FE `20+12+12+12 = 56` · BE 32 · DB 8 · RT 4 · dev base **100** · BA 4 → QA `0.20 × 100 = 20` → Cont `0.15 × (100+4+20) = 19` → **143 h** ✓ (§3b MVP-1 carve)

---

##### S3 · Phase 14 — Integration Testing, PLC Commissioning & Go-Live

**Spec:** [`phase-14-integration-testing-plc-commissioning-golive.md`](Phases/phase-14-integration-testing-plc-commissioning-golive.md) · **Owner:** QA + BA · **267 h** (QA 112 · RT 40 · BA 40 · FE 16 · BE 16 · DB 8 · cont. 35)

> **Not deferrable — but S3 cannot hold it.** 267 hours alongside Phases 12 and 13 in 8 working days is the single worst compression in the plan. **UAT and stakeholder sign-off cannot begin the day feature work completes.** `CapacityAndEffortModel.md` §7 recommends pulling this into a dedicated post-feature-complete window **regardless of team size**.
>
> **No 20% QA uplift is applied here** — this phase *is* the QA phase, and its QA hours are explicit.

---

###### FW-120 · E2E FL1 standalone
**Hours:** 32 h QA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** QA

**As a** QA engineer,
**I want** the whole FL1 route proven end to end,
**So that** the primary production route is known to work before go-live.

**Acceptance Criteria:**
- [ ] Rod received → planned → scheduled → check-in → active run → SPC → weld → complete → spool alpha → reporting
- [ ] **`INFLAT` verified set and cleared** at the right moments
- [ ] PLC push logged (simulate or commissioning)
- [ ] Weld traceability and SPC records verified against the database
- [ ] Green run recorded at **QA3 (24 Sep)**

**Rate-card basis:** E2E route run, explicit QA hours (32 h, §3)
**Dependencies:** Phases 4, 5, 6, 7 complete
**Blockers:** all Critical `OQ`s must close before sign-off

---

###### FW-121 · E2E FL2 standalone
**Hours:** 24 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** QA

**As a** QA engineer,
**I want** the FL2 finishing route proven end to end,
**So that** the coil the customer receives is known to be correct.

**Acceptance Criteria:**
- [ ] Spool → FL2 check-in (historical profile) → roll adjust → coil completion → skid close
- [ ] **The null-gauge case verified** — Live shows its empty state and does not draw a line at target; Profile stays static across live ticks
- [ ] **Components card shows exactly three FM2 stands**; a fourth row is a regression
- [ ] Green run recorded at **QA3 (24 Sep)**

**Rate-card basis:** E2E route run (24 h, §3)
**Dependencies:** Phases 8, 9 complete
**Blockers:** **OQ-15** · **OQ-17**

---

###### FW-122 · E2E FL3 hybrid
**Hours:** 24 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** QA

**As a** QA engineer,
**I want** the hybrid route proven end to end,
**So that** the most complex route is not first exercised in production.

**Acceptance Criteria:**
- [ ] **Single acknowledgement** → continuous run → **no intermediate alpha** → weld → coreless coil
- [ ] **FL1 and FL2 confirmed unavailable** in scheduling during an FL3 run
- [ ] Single PLC push covers all FM1 + FM2 components
- [ ] Roll Adjust present on FL3 and **absent on FL1**
- [ ] Continuous trace across the whole run
- [ ] Green run recorded at **QA4 (28 Sep)**

**Rate-card basis:** E2E route run (24 h, §3)
**Dependencies:** Phase 10 complete
**Blockers:** **OQ-15** · **G30**

---

###### FW-200 · PLC commissioning support
**Hours:** 40 h RT · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** RT

**As a** commissioning engineer,
**I want** the system switched from simulation to live tags with support on hand,
**So that** the mill is configured by the application rather than by hand.

**Acceptance Criteria:**
- [ ] `SimulatePLCTagPush` switched to live
- [ ] **Every OPC tag path confirmed against the controller** with Tim O. and the commissioning engineer — this is what makes a path `[CONFIRMED]`; **no path in `[PLC]` is confirmed until a controller accepts it** (tests `C1` / `C11`)
- [ ] Push and clear validated on all three lines; live AGC feed validated
- [ ] **`PLC-Q##` sign-off sheet completed** — three of its items are `Critical`
- [ ] **Target by 30 Sep.** Until it completes every line runs simulate + mock SignalR. **Development is not blocked by this; go-live is**

**Rate-card basis:** PLC commissioning, explicit RT hours (40 h, §3)
**Dependencies:** FW-082, FW-151, FW-190
**Blockers:** **`PLC-Q04`** *(FM2 station names — `Stand8`/`Stand6S1`/`Stand6S2` observed, ours differ)* · **`PLC-Q05`** *(the measure segment of **every** tag is ours, risking all 41 paths)* · **G29** *(no edger tag path exists)* · **G30**

---

###### FW-123 · UAT and stakeholder sign-off
**Hours:** 40 h BA · 16 h QA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** BA + QA

**As a** programme manager,
**I want** the client to accept the system on staging,
**So that** trial and production can be scheduled.

**Acceptance Criteria:**
- [ ] UAT run on staging (`devual-uadev001`) with mock SignalR and simulate PLC
- [ ] Clickable demo for Tim O., Shannon R. and the ops team
- [ ] **Every Critical open question closed before sign-off** — `OI-88`, `OQ-2`, `OQ-3`, `OQ-76`, `OI-49`, `OQ-61`, `OI-60`, `OQ-10`, `OQ-67`, `OQ-14`, `OQ-15`
- [ ] Alpha genealogy demonstrated end to end: Rod → Spool → Coil → Skid
- [ ] Sign-off recorded at **QA5 / M5 (30 Sep)**
- [ ] ⚠ **UAT must not share a window with feature work** — schedule it after feature-complete, whatever date that lands on

**Rate-card basis:** UAT coordination 40 h BA + UAT execution 16 h QA (§3)
**Dependencies:** every critical-path phase
**Blockers:** all Critical `OQ`s · ⚠ **the compression itself**

---

###### FW-201 · Defect allowance and renamed-column regression
**Hours:** 16 h FE · 16 h BE · 8 h DB · 16 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** FE + BE + DB + QA

**As a** QA engineer,
**I want** budgeted time to fix what the E2E runs find,
**So that** defects are closed rather than deferred into the trial.

**Acceptance Criteria:**
- [ ] Defect allowance available across FE, BE and DB for issues raised by `FW-120`–`FW-122`
- [ ] **Regression pass over every report and screen touched by the FW-001 renames**, run at **QA4 (28 Sep)** — this is the check that the highest-blast-radius change in the plan did not break the legacy tier
- [ ] Fixes verified by re-running the affected E2E route
- [ ] Deployment path exercised: `ng build` → IIS static; `dotnet publish FlatWire.API` → IIS app pool with **WebSockets enabled**; DDL via the ordered migration scripts

**Rate-card basis:** defect allowance, explicit per-stream hours (16+16+8 = 40 h dev + 16 h QA, §3)
**Dependencies:** FW-001, FW-120, FW-121, FW-122
**Blockers:** —

---

**Phase 14 reconciliation** — QA `32+24+24+16+16 = 112` · RT 40 · BA 40 · FE 16 · BE 16 · DB 8 · base **232** → **no QA uplift** (this is the QA phase) → Cont `0.15 × 232 = 35` → **267 h** ✓ (§3b)

**S3 total** — `59 + 222 + 61 + 175 + 177 + 143 + 267 = **1,104 h**` ✓ · 8 working days · **17.3 FTE**

---


### 7.3 Roll-up

#### 4.1 By phase

| Phase | Title | Sprint | FE | BE | DB | RT | QA | BA | Cont | **Hours** | Stories |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **1A** | Angular Foundation | S0 | 224 | — | — | 44 | 54 | — | 48 | **370** | 9 |
| **1B** | Backend Foundation | S0 | — | 208 | — | 112 | 64 | — | 58 | **442** | 17 |
| **1C** | Database Foundation | S0 | — | — | 156 | — | 31 | — | 28 | **215** | 7 |
| **3** | Line Status Board & Real-Time Backbone | S1 | 64 | 16 | 4 | 40 | 41 | — | 25 | **190** | 6 |
| **4** | Rod Check-In & PLC Configuration | S2 | 60 | 62 | 28 | 28 | 36 | 8 | 33 | **255** | 8 |
| **5** | Active Run Monitoring & Gauge Trace | S2 | 76 | 12 | 8 | 24 | 22 | — | 12 | **154** | 6 |
| **6** | In-Run Production Events | S2 | 120 | 56 | 20 | 20 | 43 | — | 39 | **298** | 12 |
| **7** | WIP Rejection & Rod Checkout | S2 | 64 | 40 | 28 | 16 | 30 | — | 27 | **205** | 7 |
| **8** | FL2 Spool Check-In & Finishing Run | S2→S3 | 48 | 18 | 12 | 8 | 17 | — | 15 | **118** | 7 |
| **9** | Output Coil Completion & Packing | S3 | 104 | 26 | 16 | 8 | 31 | 8 | 29 | **222** | 8 |
| **10** | FL3 Hybrid Continuous Operation | S3 | 12 | 20 | 4 | 8 | 9 | — | 8 | **61** | 4 |
| **11** | Reporting & Certification | S3 | 40 | 56 | 20 | 4 | 24 | 8 | 23 | **175** | 7 |
| **12** | Yield, Cost Ledger & Scrap | S3 | 44 | 72 | 12 | — | 26 | — | 23 | **177** | 4 |
| **13** | Administration & Reference Data | S3 | 56 | 32 | 8 | 4 | 20 | 4 | 19 | **143** | 8 |
| **14** | Integration, Commissioning & Go-Live | S3 | 16 | 16 | 8 | 40 | 112 | 40 | 35 | **267** | 6 |
| | **TOTAL** | | **928** | **634** | **324** | **356** | **560** | **68** | **422** | **3,292** | **116** |

Every row is the sum of its own printed cells, and every column sums as shown. Totals match `CapacityAndEffortModel.md` §3b's MVP-1 apportionment exactly.

**Reserves excluded from the total:** Phase 4 **24–64 h** (`G2`/`OI-39`) · Phase 9 **16–32 h** (`OQ-10`/`OI-45`, and understated).

#### 4.2 By sprint

| Sprint | Phases | Hours | Wk days | Cap/person | Req. FTE | Stories |
|---|---|---|---|---|---|---|
| **S0** | 1A, 1B, 1C | **1,027** | 12 | 96 h | **10.7** | 33 |
| *carry-over* | *Phase 1 completion* | **0** | 5 | 40 h | *0.0* | — |
| **S1** | 3 | **190** | 10 | 80 h | **2.4** | 6 |
| **S2** | 4, 5, 6, 7, 8 *(start)* | **971** | 9 | 72 h | **13.5** | 40 |
| **S3** | 8 *(finish)*, 9, 10, 11, 12, 13, 14 | **1,104** | 8 | 64 h | **17.3** | 37 |
| | | **3,292** | **44** | **352 h** | **9.4** | **116** |

*Phase 8's seven stories are counted in S2, where the phase starts; its **hours** split 59/59 across the boundary.*

#### 4.3 The AI-assisted second basis

[`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) re-derives **development hours only** (FE/BE/DB/RT) on an AI-assisted basis per the 23 Jul 2026 client decision: **MVP-1 development 1,397 h against 2,114 h hand-coded** — a 33.9% reduction, **4.0 developer-FTE against 6.0**.

**It is not an alternative total and must not be compared with 3,292 h.** It excludes QA, BA and contingency entirely, and excludes Phase 12. It is shown here at phase and sprint level only; putting it per story would imply a precision the factors do not have — they are **assumed, not measured**, and the first calibration point is the 14 Aug gate.

**The stream it does not compress is the one to staff against:** RT compresses only **14.3%** and is the only stream whose share *grows* (15.0% → 19.6%). Real-time is the constraint, not FE.

---


### 7.4 Blockers

Sourced from each phase file's `OQ blockers:` trailer and the gaps register in [`Development/GapsRegister.md`](GapsRegister.md).

#### 6.1 The ones that stop work

| Blocker | Blocks | Why it matters |
|---|---|---|
| ⛔ **OQ-22** *(alloy tolerance values owed by client e-mail)* | `FW-004`, `FW-061`, `FW-194`, `FW-199` | `CHK007` cannot fire at **either** station. Nothing is seeded; the Dashboard 2A mock map must not be substituted. **Blocks Phase 4 and Phase 13** |
| ⚠ **G21** *(bay uniqueness scope across FL1/FL3)* | `FW-159`, `FW-N01`, `FW-158` | **Blocks the Phase-4 schema freeze.** `UX_RodStaging_Bay` does not enforce one-rod-per-bay across the two lines |
| ⚠ **OQ-10 / OI-45** *(footage→weight dimensional basis)* | `FW-066`, `FW-185`, `FW-100`, `FW-188` | **Critical**, and the most widely depended-on number in the build. Carries the 16–32 h Phase-9 reserve. **Deliberately carries no recommendation — United Aluminum must answer it from its own practice** |
| ⚠ **G2 / OI-39** *(cross-DB check-in recovery undecided)* | `FW-157`, `FW-082` | Check-in spans `FlatWireDB` + `coils` + `wip_coil_orders` + the PLC and **is not one ACID transaction**. Carries the 24–64 h Phase-4 reserve |
| ⚠ **G9 / OI-34** *(NFRs do not exist)* | `FW-156`, `FW-080`, `FW-165` | The 16 h hub load test **has no pass criteria**. Any resulting real-time rework is **not** in the 3,292 h |
| **OQ-3**, **OQ-14** *(traveler fields, no-match path)* | `FW-061`, `FW-161` | Both **Critical**; gate the wizard's final field list |
| **OQ-17** *(spool state machine)* | `FW-124`, `FW-179` | *"Available for processing"* has no defined meaning without it |
| ⚠ **`Spool.OrderNo` populated from planning?** | `FW-124` | If allocation is not readable by the shopfloor system, **`FR-098` has nothing to resolve and DB5A is invalid** |
| **`PLC-Q04`, `PLC-Q05`** *(station names, measure segment)* | `FW-N05`, `FW-082`, `FW-200` | `PLC-Q05` risks **all 41 tag paths**. Three `PLC-Q` items are `Critical` |
| **OI-101** *(shift boundaries undefined)* | `FW-090`, `FW-193` | Blocks every shift-scoped figure in reporting |

#### 6.2 Decided, but the decision has nowhere to land

| Gap | Story | State |
|---|---|---|
| **G34** | `FW-171` | **Wire break has a decided flow and no persistence target** (`FR-280`–`282`, `FW-N08`, `TC-350`–`352`). Decide before the Phase-6 build |
| **G36** | `FW-066`, `FW-182`, `FW-186` | Phase 9's return imported **four uncosted dependencies** — `OI-104` skid table, `OI-24`/`OI-99` lot number, `OI-105` scale weight, `OI-106` staging location |
| **G7** | `FW-175` | Supervisor approval relied only on transient SignalR. `FW-175` is the fix and **is costed** |
| **G24** | `FW-176`, `FW-072` | Approval columns now exist; the **PIN validation source** is still `OI-38` |
| **G26** | `FW-N01` → `FW-166` | The weld write straddles Phase 4's screen and Phase 6's endpoint. Phase 4 **ships against a stub** |

#### 6.3 Gaps this rewrite closes

| Gap | How |
|---|---|
| **G4** *(story→phase coverage not provable)* | Every story here names its phase and sprint; [§4.1](#41-by-phase) proves the count |
| **G1** *(no capacity/effort model)* | Resolved by `CapacityAndEffortModel.md`; this document now **consumes** it per story rather than restating a separate estimate |
| **Phase 1 backlog gap** *(1,027 h against ~28 points)* | **33 stories now cover S0**, including `FW-N03` (Angular scaffold), `FW-N04` (.NET solution + 13 controllers) and `FW-N05` (OPC ingest + hosted service) — the three the capacity model named as having no story anywhere |

---


### 7.5 Out of shopfloor scope — 14 upstream stories, and the definition-of-done note on FW-001

**`FW-001` is flagged high blast radius.** The renames touch the shared `coils`/scheduling schema read by upstream receiving, planning, scheduling, reporting, yield and cost. Its Definition of Done includes:

1. A completed stored-procedure / view / report / query audit across `united_db` **and the legacy `ual-dot-net` tier** (40 h, costed separately from the 16 h rename).
2. A **reverse script**, tested.
3. A dependent-object recompilation check.
4. The regression pass scheduled at QA4.

**Front-load it in Phase 1C.** It is the risk most likely to surface late, and `[RB §6.3]` records it as the hardest element of the release to roll back.

**Fourteen upstream stories are out of shopfloor scope**, handled by the existing CoilReceiving / Planning / Scheduling / Web systems. They remain **Critical/High for their own teams**; this plan consumes their outputs but does not build them, and **they are not costed in the 3,292 h**.

| Epic | Stories |
|---|---|
| E03 Rod Receiving | FW-020 (R-series alpha generation) · FW-021 (rod receiving web UI) · FW-022 (suspend-coil logic for rods) |
| E04 Scheduling | FW-030 (Flattening Lines tab) · FW-031 (operation letter `F`) |
| E05 Planning | FW-040 (Flat Wire filter) · FW-041 (weight-based drop with alpha generation) · FW-042 (assign-as-is stock) · FW-043 (tabular allocation grid) |
| E06 Web | FW-050 (Orders & Quotes flags) · FW-051 (Search Customers) · FW-052 (IQR bundle width / edge type) · FW-053 (Item Template) · FW-055 (Vendor Maintenance) |

> **Ruled 13 Aug 2026.** These fourteen were tagged in-scope Critical/High, Sprint 2–3 by the April backlog and out-of-scope by this plan — the two documents disagreed for four months and both are now one document, so the disagreement is closed in favour of **out of shopfloor scope, consumed as prerequisites at Phase 4**. **If either upstream track slips, Phase 4 has no material and no scheduled job** — that is the dependency behind §10.1's upstream risk, and it is the reason they are listed here at all rather than simply deleted.

### 7.6 Appendix A — retired point basis

Story points were retired on 13 Aug 2026. **These figures are recorded once, here, so every downstream citation stays resolvable.** They are historical: nothing in this document is sized in points, and the totals must not be re-derived from the current story set.

| Basis | Stories | Points | Where it was quoted |
|---|---|---|---|
| **Shopfloor MVP-1** *(this file, previous version)* | 35 | **147** | This file's header; `Development/Roadmap.md` §0.1; `REVIEW.md` #51, #57 |
| **MVP-2** | 6 | **31** | [`FlatWireJiraStories-MVP2.md`](../../../MVP-2/DevelopmentPlan/FlatWireJiraStories-MVP2.md) |
| **Phase 12 (Yield/Cost/Scrap)** | 4 | **11** | `YieldCostAndScrapJiraStories.md`; `YieldCostAndScrapSheet.md` |
| **Published shopfloor total** | **45** | **189** | `CapacityAndEffortModel.md` §3 cross-check; `Development/GapsRegister.md` Appendix C |
| *Upstream (deleted, another team's work)* | *14* | *42* | *Recoverable at commit `1964086`* |
| *Retired totals* | | *184 · 220 · 231* | *All superseded before this rewrite* |

**Per-epic split of the 147** — E01 Foundation **33** (8 stories) · E02 Pass Schedule **3** (1) · E07 Shopfloor UI **65** (13) · E08 Real-Time & PLC **13** (3) · E09 Reporting **17** (6) · E12 Testing & Go-Live **16** (4).

**The two derived ratios that lose their denominator:** `CapacityAndEffortModel.md` §3's cross-check of **19.4 h/point** (3,660 h ÷ 189) and **16.4 h/point** excluding Phase 1 (2,633 h ÷ 161). Both were investigation results, not planning inputs; §3's two stated causes — the Phase-1 backlog gap and the ~16 h/point vertical-slice reality — are **both addressed by this rewrite**, the first directly.

**Epics are retired too.** They were a Jira grouping over a five-sprint model that no longer exists; phases are the grouping now. The epic ids `FW-E01`, `FW-E02`, `FW-E07`–`FW-E12` are recorded above so old references resolve.

---


### 7.7 Appendix B — ID provenance

Every `FW-###` cited anywhere in the repository resolves through this table.

#### B.1 Existing ids — numbers and titles frozen (39)

**38 of these carry a story body here; `FW-014` is subsumed (see B.5).** `38 + 6 adopted + 72 minted = 116`.

| Range | Stories | Where they are now |
|---|---|---|
| `FW-001`, `FW-002`, `FW-004`, `FW-005`, `FW-006`, `FW-007` | 6 | **S0 / Phase 1C** |
| `FW-003`, `FW-054` | 2 | **S3 / Phase 13** |
| `FW-060` | 1 | **S1 / Phase 3** |
| `FW-061` | 1 | **S2 / Phase 4** |
| `FW-062`, `FW-081` | 2 | **S2 / Phase 5** |
| `FW-063`, `FW-065`, `FW-070`, `FW-071`, `FW-073` | 5 | **S2 / Phase 6** |
| `FW-067`, `FW-072` | 2 | **S2 / Phase 7** |
| `FW-064`, `FW-124` | 2 | **S2 / Phase 8** |
| `FW-066` | 1 | **S3 / Phase 9** |
| `FW-080` | 1 | **S0 / Phase 1B** |
| `FW-082` | 1 | **S2 / Phase 4** |
| `FW-090`–`FW-095` | 6 | **S3 / Phase 11** |
| `FW-100`, `FW-101`, `FW-102`, `FW-110` | 4 | **S3 / Phase 12** — absorbed from `YieldCostAndScrapJiraStories.md` |
| `FW-120`–`FW-123` | 4 | **S3 / Phase 14** |
| `FW-014` | 1 | **Subsumed** — see B.5 |

#### B.2 Adopted `FW-N##` ids — costed (6)

Absorbed from `05-SprintPlanAndBacklog.md` §7.3 under the single-backlog decision.

| Story | Title | Sprint / Phase |
|---|---|---|
| `FW-N01` | Dashboard 2A — Rod Pre-Check-in station | S2 / 4 |
| `FW-N02` | Spool completion weight milestones | S3 / 8 |
| `FW-N03` | Angular library scaffold | S0 / 1A |
| `FW-N04` | `FlatWire` solution skeleton | S0 / 1B |
| `FW-N05` | OPC ingest hosted service | S0 / 1B |
| `FW-N06` | Alert rules engine and lifecycle | S1 / 3 |

#### B.3 Minted ids — `FW-130`–`FW-201` (72, contiguous)

All above the previous high-water mark `FW-124`, so nothing collides with upstream (`FW-020`–`FW-055`) or MVP-2 (`FW-010`–`FW-013`, `FW-068`, `FW-069`).

| Range | Phase | Covers |
|---|---|---|
| `FW-130`–`FW-137` | 1A | Shell, guards, API client, shared controls, SignalR client, mock hub, cache sync |
| `FW-138`–`FW-151` | 1B | Controllers, MediatR, DI, repositories, data access, logging, config, auth, exceptions, validation, health, typed contract, broadcast loop, `PLCTagService` skeleton |
| `FW-152` | 1C | `FlatWireDB` creation and ordered runner |
| `FW-153`–`FW-156` | 3 | Alert chips, `/lines/status`, index, load test |
| `FW-157`–`FW-161` | 4 | Check-in command, staging controller, staging schema, `PayoffStateChanged`, BA |
| `FW-162`–`FW-165` | 5 | Status cards, info grid, run queries, `sp_GetGaugeTrace` |
| `FW-166`–`FW-172` | 6 | Five event endpoints, event tables, markers |
| `FW-173`–`FW-177` | 7 | Partial re-check-in, exception endpoints, durable queue, tables, broadcasts |
| `FW-178`–`FW-181` | 8 | FL2 monitor config, spool endpoints, schema, null-gauge contract |
| `FW-182`–`FW-188` | 9 | Packing station, traceability controls, label, coil endpoints, schema, broadcasts, BA |
| `FW-189`–`FW-192` | 10 | FL3 variants, hybrid push, route mode, continuous trace |
| `FW-193` | 11 | Certification BA |
| `FW-194`–`FW-199` | 13 | Alloy admin, role UI, admin endpoints, reference wiring, broadcast, BA |
| `FW-200`, `FW-201` | 14 | PLC commissioning, defect allowance and rename regression |

#### B.4 Adopted but **uncosted** — tracked, not scheduled (6)

**These are real work items with no hours anywhere in the capacity model.** They are listed so they are not mistaken for oversights, and so nobody assumes they are inside the 3,292 h.

| Story | Title | Status |
|---|---|---|
| `FW-N07` | Die master table | **Wholly MVP-2.** Its 8 h left `phase-13` with the Die Management screen. *(`phase-13`'s own MVP-2 callout still says the table half is MVP-1 — that line is stale and contradicts its scope call, `CapacityAndEffortModel.md` §3b and the repository guide)* |
| `FW-N08` | Wire break | **Blocked — `G34`.** A decided flow with **no persistence target**. Must be decided before the Phase-6 build |
| `FW-N09` | OEE dashboard | **MVP-2** — the mockup lives in `MVP-2/Mockups/` |
| `FW-N10` | Stop popup | Uncosted; no phase assignment |
| `FW-N11` | Operator session / `ITInhibit` | Cited against Phase 6, **uncosted**. `ITInhibit` is specified in `[PLC]` |
| `FW-N12` | De-stub pass | Cited against Phase 4, **uncosted**. In practice absorbed by `FW-166` (weld) and `FW-201` (defect allowance) |

#### B.5 Subsumed, superseded and out of scope

| Id | Disposition |
|---|---|
| `FW-014` | **Subsumed by `FW-169`** for its MVP-1 half — the mid-run override **trigger** writes a run-level `RollOverride` row. Its **sink**, `PassScheduleChangeLog`, is an **MVP-2 table**, so MVP-1 has an override path with nowhere to log the schedule-level record. Retained here as a citation target |
| `FW-010`–`FW-013`, `FW-068`, `FW-069` | **MVP-2** — [`FlatWireJiraStories-MVP2.md`](../../../MVP-2/DevelopmentPlan/FlatWireJiraStories-MVP2.md). `FW-010` is a live dependency of `FW-061` and `FW-082` |
| `FW-020`–`FW-022`, `FW-030`, `FW-031`, `FW-040`–`FW-043`, `FW-050`–`FW-053`, `FW-055` | **Upstream, deleted** — rod receiving, orders, planning and line scheduling, built by other teams. Recoverable at commit `1964086`. `FW-020` is a live dependency of `FW-061` |
| `FW-S1-###`, `FW-S3-###` | **Never existed.** These sprint-style ids appear in `CheckinImplementationPlan.md` and `CheckinImplementationPrompt.md` and resolve to nothing. Treat any such citation as pointing at the phase, not a story |

---


---

---

## 8. Descope ladder

From [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §5. **Every rung lands in S2 or S3**, and the whole ladder recovers **448 h — about 12%** — leaving a 9.1–9.3 FTE requirement.

| # | Rung | Stories | Hours | Cumulative | Latest call | What is lost |
|---|---|---|---|---|---|---|
| 1 | Scrap Box/Skid outlet | `FW-110` | 33 | 33 | in **S3** | Scrap routed manually post-go-live |
| 2 | Cost Ledger configuration | `FW-102` | 49 | 82 | in **S3** | No flat-wire cost standards; costing reports blank |
| 3 | Weld traceability in yield | `FW-101` | 28 | 110 | in **S3** | Yield not attributed per source rod — **welding-wire certs affected** |
| 4 | Remainder of Phase 12 | `FW-100` | 67 | **177** *(whole phase)* | in **S3** | No footage-based yield at go-live |
| 5 | Phase 13 non-critical | `FW-195` *(role UI only)* | **< 99** | — | in **S2** | Roles assigned by a DBA |
| 6 | Phase 11 reports, 4 of 5 | `FW-092`, `FW-093`, `FW-094`, `FW-095` | 105 | — | in **S2** | Only Gauge Trace ships; CPK/SPC/traceability deferred |

**Two rungs no longer mean what they say:**

- **Rung 5's published 99 h is not available in full.** It bundled the **Die Management screen — now MVP-2** — with the MVP-1 role-assignment UI. Only the role-UI share can still be cut.
- **Rung 7 was removed on 4 Aug 2026, and that made the schedule harder, not easier.** DB13 and DB14 were the largest genuinely-optional FE items on the critical path, and the client **descoped them outright**. Their 67 h stopped being *recoverable* effort and became *never-planned* effort — so the ladder now recovers ~12% of a smaller base, and **Phase 5 is no longer deferrable at all**.

**Phase 10 (FL3 hybrid, 61 h) is explicitly not deferrable** — FL3 is one of the three production routes.

> **The ladder is not enough, and that is the finding.** Below rung 6 there is nothing left that is not a production route, a check-in path or the traveler. **Scope is not where the 30 Sep date can be recovered.** Extending S3 to its natural 2 Oct boundary recovers more peak FTE (17.3 → 13.8) than rungs 1–4 combined.

---


---

---

## 11. Coverage matrix — every `FR-###` reaches a story

| `[REQ]` § | FR range | Count | Delivering story | Phase |
|---|---|---|---|---|
| 5.0 | FR-001 – FR-022 | 22 | **`[NEW]` FW-N11** | 4 |
| 5.1 | FR-030 – FR-054 | 25 | **`[NEW]` FW-N01** | 4 |
| 5.2 | FR-060 – FR-084 | 25 | FW-061, FW-082, FW-010 | 4 |
| 5.3 | FR-090 – FR-096 | 7 | FW-064 | 8 |
| 5.4 | FR-100 – FR-120 | 21 | FW-062, FW-081, FW-080 | 5 |
| 5.5 | FR-130 – FR-157 | 26 | **`[NEW]` FW-N02** | 9 (uses 5) |
| 5.6 | FR-160 – FR-175 | 16 | FW-063 | 6 |
| 5.7 | FR-180 – FR-197 | 18 | FW-065 | 4, 6 |
| 5.8 | FR-200 – FR-212 | 13 | FW-070 | 6, 10 |
| 5.9 | FR-220 – FR-234 | 15 | FW-073 *(+ FW-N07 for the inventory it validates against)* | 6 |
| 5.10 | FR-240 – FR-255 | 16 | **`[NEW]` FW-N07** | 13 |
| 5.11 | FR-260 – FR-267 | 8 | FW-071 | 6 |
| 5.12 | FR-270 – FR-277 | 8 | **`[NEW]` FW-N10** | 6 |
| 5.13 | FR-280 – FR-282 | 3 | **`[NEW]` FW-N08 — BLOCKED (OI-13)** | **unassigned** |
| 5.14 | FR-290 – FR-299 | 10 | FW-067 | 7 |
| 5.15 | FR-300 – FR-327 | 19 | FW-072 | 7 |
| 5.16 | FR-330 – FR-340 | 12 | FW-066, FW-100 | 9 |
| 5.17 | FR-345 – FR-352 | 8 | FW-066 *(DB7b is inside its phase mapping)* | 9 |
| 5.18 | FR-360 – FR-391 | 28 | FW-010, FW-012, FW-013, FW-014 | 2 |
| 5.19 | FR-400 – FR-410 | 11 | FW-011, FW-068 | 2 |
| 5.20 | FR-420 – FR-428 | 9 | FW-060 *(+ FW-N06 for alert persistence)* | 3 |
| ~~5.21~~ | ~~FR-440 – FR-451~~ | ~~12~~ | ~~FW-062 (DB13 scope)~~ | **withdrawn 4 Aug 2026** |
| ~~5.22~~ | ~~FR-460 – FR-470~~ | ~~11~~ | ~~FW-062 (DB14 scope)~~ | **withdrawn 4 Aug 2026** |
| 5.23 | FR-480 – FR-490 | 11 | FW-069 | 11 |
| 5.24 | FR-500 – FR-508 | 9 | **`[NEW]` FW-N09 — `Could`, no phase** | **unassigned** |
| | **Total** | **363** | | |

### 11.1 Requirements not on the critical path — stated explicitly

| FR range | Status | Reason |
|---|---|---|
| **FR-280 – FR-282** (wire break, 3) | **Not deliverable** | `FW-N08` is blocked by **OI-13** — no screen, no table, no persistence target. The requirements are unimplementable as written |
| **FR-500 – FR-508** (OEE, 9) | **Not scheduled** | `FW-N09` has no phase and no owner (**PP-03**). Either schedule it or record OEE as out of scope |
| ~~**FR-440 – FR-470**~~ (DB13 + DB14, 23) | **[WITHDRAWN — descoped by client, Aug 4 2026]** | Withdrawn from scope entirely, not deferred. **FW-062 keeps its 8 points** — DB13, DB14 and the Machine View had no acceptance criteria of their own in it |
| **FR-500-series and FR-480-series reporting** | **Descope rung 6** | Four of five Phase-11 reports; Cut Traceability's deferral carries a shipment risk |

**All 363 requirements map to a story.** Of those, **351 (96.7 %) are schedulable**: the nine OEE requirements have a story (`FW-N09`) with no phase or owner, and the three wire-break requirements have a story (`FW-N08`) that is blocked by **OI-13**. Both are carried in the backlog rather than dropped, so neither can be lost — but neither can be committed to a sprint today. This matches `[TCS §10.4]` exactly.
