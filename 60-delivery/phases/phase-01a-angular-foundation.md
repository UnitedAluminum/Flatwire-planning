# PHASE 1A — Angular Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../../00-overview/Roadmap.md).** One of the three layer specs that replace the combined Phase 1 doc.
> **Siblings:** [1B — Backend Foundation](./phase-01b-backend-foundation.md) · [1C — Database Foundation](./phase-01c-database-foundation.md)
> **Reference context (do not restate):** [`[ARC §2.2]`](../../Architecture/Architecture.md) — the binding reference-code rules; build against `c:\UAL\ual-angular` (and `§2.1` for repo locations) · [`[BR §3]`](../../Business/BusinessRules.md) — domain model and glossary · [`[SIG §4]`](../../Architecture/SignalR.md) — real-time architecture · [`[API §7]`](../../Backend/APIs.md) — the stub-first delivery contract.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-28 — **the scaffold command gained `--standalone=false`** (the setup table's *Project architecture* row): without it the Angular 20 library schematic emits a standalone entry point, and every component in `ual-angular` is explicitly `standalone: false`. Earlier the same day the library was renamed **`flat-wire-shopfloor` → `flat-wire`** across this file (objective, setup table, exit criterion 1) with the repository-wide sweep. *(previously 2026-08-15 — **`G6`/`OI-37` provisioning question closed**: the six roles exist as JWT claims on `ClaimTypes.Role`; the entry's *verification* half survives against the unmapped claim values)*
**Status:** **Ready to build — but the 14 Aug gate was not met**
**Layer:** Angular frontend (`ual-angular`)
**Owner:** **FE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Scope call:** **Wholly MVP-1, and not descopable** — every later phase's screens are built on this library. `FW-133` alone is 45 % of the layer and all six trial screens depend on it, so it is untrimmable.
**Effort:** **370 h** (46.2 d) — FE 224 · RT 44 · QA 54 · cont. 48 · **Window:** W0 (to Aug 14, 12 working days = 96 h/person) · ⚠ **3.8 FTE on this layer alone**; `[CE §4]` publishes Phase 1 as a whole at **10.7 FTE**, which is the figure the gate actually failed against

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate) — **not met**
> Phase 1 was to be complete by **14 Aug 2026** (user mandate; superseded the roadmap's W1 = Aug 17–23). 1A/1B/1C run **in parallel** and converge only on the shared API contract (`[API]`) + seed fixtures. This layer is not blocked by 1B/1C because it develops against the **mock** API + **mock** SignalR (`useMockData: true`).
> **`[RM]` records that 30 Sep is now a trial-run date, not an MVP-1 feature-complete date.** `[TRP]` carries 1A at **139 h of pure FE** and requires it to finish inside T1 — it gates every screen.

## Objective
Stand up a reusable, authenticated, routable `flat-wire` Angular library so every later
workflow phase is pure feature work with no further infrastructure lift — talking to the backend via
a DI-swappable **real/mock** client and a purpose-built SignalR service.

## Dependencies
- **Blocking:** none for the mock path. `shared` foundational services must exist (they do).
- **Converges with:** 1B (`[API §1.2]` envelope + `[API §3.2]` endpoints) and 1C (seed fixtures `R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043`) — used to shape the mock service. **Two convergence points must be settled with 1B rather than assumed:** the DI swap flag is **`useMockData`** on both sides (`[API §7.1]`), and the **JSON naming policy** that reconciles this library's `{success,data,errors}` wire shape with 1B's C# `{Data,Success,Errors}` property names is 1B's to configure — neither file stated it before 14 Aug 2026.
- **Backlog:** see the **Stories** trailer at the foot of this file.

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Project architecture** | New library `flat-wire` (prefix `fw`) via `ng generate library flat-wire --prefix=fw --standalone=false` → `projects/flat-wire/` — ⚠ **`--standalone=false` is required, not stylistic**: every component in `ual-angular` is explicitly `standalone: false`, and the flag is what makes the schematic emit the NgModule instead of a standalone entry point; registered in `angular.json` + `tsconfig` paths; added to the `build:shop-floor` npm chain (build-ordering only — **no** UI reuse from other libraries in the chain, per `[ARC §2.2]`) |
| **Folder structure** | `src/lib/{components,components/shared,services,models,guards,styles}` + `flat-wire.module.ts`, `flat-wire-routing.ts`, `public-api.ts` (standard Angular-library layout — **not** copied from any existing feature library) |
| **Shared services (consume only)** | `api-gateway.service`, `app-config.service`, `login.service` + `login-api.service`, `token-interceptor.service`, `correlation-id-interceptor` + `correlation-id.service`, `error-handler.service` + `global-error-handler-api.service`, `ui-log.service`, `notification.service`, `subscription.service`, `print-export.service`, `util.service`. **Do not rebuild these; do not copy any feature-library UI.** |
| **Routing** | Lazy-loaded `FLAT_WIRE_ROUTES` under `/flat-wire`; per-line routes e.g. `/flat-wire/line/:lineId/checkin/rod`, `/flat-wire/line/FL2/checkin/spool`, `/flat-wire/line/:lineId/run/active` |
| **Layout** | Shell layout component: header (line context + operator + clock), sidebar nav to all dashboards, `alert-banner` slot; fixed **1280×1024** shopfloor canvas |
| **Authentication** | Reuse `shared` `login.service` / `login-api.service` + `token-interceptor.service` (JWT bearer) |
| **Authorization / route guards** | `FlatWireAuthGuard` (authenticated) + `FlatWireRoleGuard` (role-gated routes) per the matrix of record, **`[SEC §8]`** — six roles: Operator · Supervisor · Operations Manager · Engineering/Maintenance · QA · Admin. ⚠ **DB9/9A are MVP-2 and are not built in MVP-1**, so they are not the guard's MVP-1 subject; the live MVP-1 role gate is **`FR-212`** — reverting a roll-gap override on **DB11 Roll Adjust** is Operations-Manager-only, operators may apply one but not undo it |
| **Interceptors** | Reuse `token-interceptor` (JWT), `correlation-id-interceptor`, `global-error-handler-api` — **no new interceptors** |
| **Shared UI controls (all new, `fw`-prefixed)** | `pass-schedule-table`, `payoff-weight-bar`, `gauge-trace-chart`, `alert-banner`, `action-bar`, `confirm-bar`, standard `.input` with validation states, `payoff-option` selector cards, pass/fail + OK/NG/NA inspection buttons, tab-wizard, SPC tolerance-viz, monospace readouts. Built fresh from the **approved `MVP-1/ProjectPlan/Frontend/Mockups/*.html`** — **not** derived from `shop-floor-common`, `checkin-precheckin`, or any existing UI library (`[ARC §2.2]`, `D-06`) |
| **Common services** | `line-context.service` (current FL1/FL2/FL3 scope), `run-state.service` (active alpha/footage/payoff via RxJS `BehaviorSubject`s; no NgRx — not used in repo) |
| **API client** | `flat-wire-api.interface.ts` with two impls — `flat-wire-api-real.service.ts` (over `shared` `api-gateway.service`) and `flat-wire-api-mock.service.ts`; DI-swapped by the `useMockData` env flag |
| **Models** | `rod.model.ts`, `spool.model.ts`, `pass-schedule.model.ts`, `active-run.model.ts`, `checkin.model.ts`, `weld-event.model.ts`, `spc-checkpoint.model.ts`, `signalr-events.model.ts` |
| **Error handling** | Reuse `error-handler.service`; standardise on the `{ success, data, errors[] }` envelope; toast + inline field errors |
| **Configuration** | `app-config.service` + `environment.*.ts` (`useMockData: true` in `environment.development.ts`, `false` elsewhere; API base + hub URL) |
| **Logging** | `ui-log.service` for client telemetry |
| **Theme** | Consume the **existing semantic design-token system** in `MVP-1/ProjectPlan/Frontend/Mockups/flat-wire-shopfloor.styles.scss/.css` **as-is** — `--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono`; light + `prefers-color-scheme: dark`; `ViewEncapsulation.None`/`:host` so tokens resolve. **⚠ Use `--color-*`, never the stale `--fw-*` prefix (see Review-fixes below / G18).** |
| **Utilities** | `util.service` + local `fw` helpers (footage/gauge formatting, SVG path builders) |

## Real-time slice (client half — per `[SIG §4]`)
| Piece | Deliverable |
|---|---|
| **SignalR client** | `flat-wire-signalr.service.ts` — `@microsoft/signalr` + `@microsoft/signalr-protocol-msgpack` (**MessagePack**), auto-reconnect w/ **exponential backoff** + **line-group re-join on reconnect**, JWT via `?access_token=`, callbacks **outside NgZone** into a **ring buffer**, `requestAnimationFrame`-throttled render (~60 fps), typed Observables per event, fixed window (last ~500 points). **New service — deliberately not `supervisor-monitor-hub`.** |
| **Mock stream** | `MockSignalRService` — timer-driven, emits the full typed event set so DB1/DB3 shells demo without a live hub |
| **Cache sync** | PWA service worker caches pass schedule + active-run snapshot for short network drops; "Reconnecting…" banner instead of blank screen |
| **Typed event set** | The **full published set — twelve events** (`[SIG §5.2]`), matching 1B's `IFlatWireClient` name for name: `GaugeReading[]`, `WidthReading[]`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`, `LineStatus`, `AlertRaised`, `AlertCleared`, **`PayoffStateChanged`**, **`SpoolCompletionPromptDue`**, **`SpoolCompletionPromptResolved`** — plus the **six** run-event markers (`[SIG §5.4]`): `WeldJoinEvent`, `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint`, **`AlertEvent`**, `RodCheckoutEvent`. Observable map at `[SIG §5.6]` |
| **The one non-telemetry event** | ⚠ **`SpoolCompletionPromptDue` is server-owned and durable** — it is **re-delivered on group re-join** (`FR-144`, `TC-173`), so the client must render it on reconnect rather than assuming a missed event is stale. It is raised **once per stop** on the `RUNNING → STOPPED` edge, so **duplicate delivery must be idempotent at the client**, and it carries a weight **latched at the PLC stop timestamp** — render `latchedWeightLb`, **never substitute a fresher `PayoffWeight` tick** |
| **FL2 rule** | A client subscribed to `FL2Data` **must not wait for `GaugeReading`** — FL2 standalone suppresses batched gauge and width entirely and its trace is a REST query. **Treating their absence as a fault is a defect** (`[SIG §5.3]`, `FR-120`) |

## Testing
- Angular library **builds + lints** clean; joins `build:shop-floor` without breaking the chain.
- **Jest** smoke tests: guards (`FlatWireAuthGuard` redirects unauthenticated; `FlatWireRoleGuard` blocks operator from DB9/9A), `flat-wire-api-mock.service` returns schema-valid fixtures, `line-context`/`run-state` state transitions, `MockSignalRService` emits typed events into the ring buffer.
- OnPush + outside-NgZone verified: streaming a mock trace does not trigger a change-detection storm.

## Acceptance criteria (exit)
1. `flat-wire` builds, lints, and is reachable at `/flat-wire` behind `FlatWireAuthGuard`.
2. Shell layout renders on the 1280×1024 canvas in both light and dark; all `--color-*` tokens resolve (no `--fw-*` anywhere).
3. DI swaps real↔mock API by `useMockData`; mock returns the seed fixtures via the `{success,data,errors}` envelope.
4. `MockSignalRService` drives a `gauge-trace-chart` live (rAF-throttled, OnPush) with reconnect + group re-join simulated.
5. Jest smoke suite green.

## Review-fixes applied in this layer
- **G18 — `--color-*` not `--fw-*`:** older April docs used a stale `--fw-*` token system (`CheckinImplementationPrompt.md` was its source and was **deleted 13 Aug 2026**); this spec mandates the shared `--color-*` semantic tokens used by every mockup and the stylesheet. No `--fw-*` token exists and there is no migration to perform.
- **Retired DB2 UI:** Dashboard 2 uses its revised **`dashboard_2_rod_checkin.html`** — a guided **6-step tab-wizard** with SPC tolerance-viz and the confirm-bar gate — **not** the retired grid + progress-ring `- Old.html`.
- **Forbidden references:** no structural/UI copy from `checkin-precheckin` or any feature library; only `shared` foundational services are consumed. `[ARC §2.2]` calls these *"the rules most likely to be broken by a developer working from habit"* — **there is no Angular structural/UI template for this library**, and joining the `build:shop-floor` chain is build-ordering only.
- **Full SignalR event set *(restated 14 Aug 2026)*:** the client originally added `LineStatus`/`AlertRaised`/`AlertCleared`, omitted from `FW-080`'s list. **That is no longer the full set** — `[SIG §5.2]` published `SpoolCompletionPromptDue` and `SpoolCompletionPromptResolved` on 14 Aug 2026 (`G37`/`FW-202`), taking it to **twelve events**; `PayoffStateChanged` was already in the contract and missing here; and the marker list is **six**, not zero. The table above is the current contract.
- **Canonical enums (cross-layer, define once):** `pass-schedule.model.ts` models component state as `State = 'Active' | 'Bypass' | 'Skip'` (**not** a boolean `IsActive` — a bool cannot express Bypass vs Skip); `EdgeType = 'Round' | 'Square'` with UI labels **"Round Edge" / "Flat Edge"** mapped in **a single display pipe** — *"no other translation exists anywhere in the system"* (`[API §2.1]`). Must match the backend enum (1B). ✅ **The DB mirror IS 1C** — `CK_PSC_State` and `CK_PSC_EdgeType` live in `FlatWire_DDL_02_Schedule.sql`, which `D-31` (15 Aug 2026) moved **into** the MVP-1 runner, so the mirror is 1A ↔ 1B ↔ **1C** and `TC-020` runs against one database. *(This bullet read "The DB mirror is not 1C … the mirror is 1A ↔ 1B ↔ MVP-2 DB" until 26 Aug 2026; `phase-01b` recorded the supersession on 15 Aug.)* `[API §2]` defines **14** canonical enums in total.
- ⚠ **`Bevel edge` must not be offered or accepted** until `OI-05` decides — it is a live *fourth* edge vocabulary appearing on the DB9/9A Generate modal with no domain value behind it.

---

**OQ blockers:** **`G18`** (the `--fw-*` token prefix is retired — no such token exists and there is no migration to perform; if it resurfaces from an older commit it is wrong) · **`G10`** (MessagePack is a **new client dependency the repo does not otherwise use**, and `[SIG]` treats it as **measure-first/optional**; IIS WebSockets must be enabled on the deployment target per `[DEP §4.4]`) · **`G9` / `OI-34`** (real-time NFRs undefined — there is no target cadence for the mock stream to match and no client-count budget) · **`G6`** / **`OI-37`** ✅ **provisioning question closed 15 Aug 2026** — the six roles exist as JWT claims on `ClaimTypes.Role`, so **nothing needs provisioning** and `TC-640`–`TC-655` are no longer blocked by it. ⚠ **The verification half of this entry still stands, for a different reason:** the six claim **values** are abbreviated or coded rather than the matrix's labels and the mapping is unsupplied, so the route guards can be **built** but not **checked**. Bind them to one constants class, as `FW-145` does server-side · **`OI-46` / `OI-47` / `OI-48`** (the mock check-in deliberately assumes a single active schedule — `[API §7.3]` requires an explicit **de-stub pass** to remove the assumption, and *"it will not remove itself"*).

**Stories:** `FW-N03` 24 · `FW-130` 16 · `FW-131` 12 · `FW-132` 20 · `FW-133` 120 · `FW-134` 32 — **FE 224** · `FW-135` 24 · `FW-136` 12 · `FW-137` 8 — **RT 44** · base **268** → QA 54 → cont. 48 → **370 h** ✓ (`[CE §3b]`). `FW-133` (shared composite controls) is **45 % of the layer** and every screen depends on it — it is the critical path inside 1A and, per `[TRP §1.4]`, untrimmable. Note `FW-204` (minimal landing route, 8 h FE) is **trial scope, additive to `[CE §3b]`** and outside this reconciliation; it retires when `FW-060` ships.
