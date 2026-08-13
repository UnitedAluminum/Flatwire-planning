# PHASE 1A — Angular Foundation

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** One of the three layer specs that replace the combined Phase 1 doc — see the [Phase 1 index](./phase-01-core-platform-setup.md).
> **Siblings:** [1B — Backend Foundation](./phase-01b-backend-foundation.md) · [1C — Database Foundation](./phase-01c-database-foundation.md)
> **Reference context (do not restate):** [Foundations §0.2](./00-foundations.md) (codebase map — build against `c:\UAL\ual-angular`), **§0.3** (domain cheat-sheet), **§0.4** (real-time architecture).

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-07-30
**Status:** Ready to build
**Layer:** Angular frontend (`ual-angular`)
**Owner:** **FE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **370 h** (46.2 d) — FE 224 · RT 44 · QA 54 · cont. 48 · **Window:** W0 (to Aug 14, 12 working days = 96 h/person) · ⚠ **needs 3.8 FTE on this layer alone** — see model §4

> ### ⏱ Due: **14 Aug 2026** (Phase-1 gate)
> Phase 1 must be complete by **14 Aug 2026** (user mandate; supersedes the roadmap's W1 = Aug 17–23). Today is Jul 26 → ~2.5 working weeks. 1A/1B/1C run **in parallel** and converge only on the shared API contract (`04-APIContract.md`) + seed fixtures. This layer is not blocked by 1B/1C because it develops against the **mock** API + **mock** SignalR (`useMockData: true`).

## Objective
Stand up a reusable, authenticated, routable `flat-wire-shopfloor` Angular library so every later
workflow phase is pure feature work with no further infrastructure lift — talking to the backend via
a DI-swappable **real/mock** client and a purpose-built SignalR service.

## Dependencies
- **Blocking:** none for the mock path. `shared` foundational services must exist (they do).
- **Converges with:** 1B (`04-APIContract.md` envelope + endpoints) and 1C (seed fixtures `R00041–R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042/0043`) — used to shape the mock service.
- **Backlog:** scaffold portions of FW-060…073 UI shells; client half of FW-080/FW-081.

## Setup tasks & concrete deliverables

| Setup activity | Concrete deliverable |
|---|---|
| **Project architecture** | New library `flat-wire-shopfloor` (prefix `fw`) via `ng generate library flat-wire-shopfloor --prefix=fw` → `projects/flat-wire-shopfloor/`; registered in `angular.json` + `tsconfig` paths; added to the `build:shop-floor` npm chain (build-ordering only — **no** UI reuse from other libraries in the chain, per §0.2) |
| **Folder structure** | `src/lib/{components,components/shared,services,models,guards,styles}` + `flat-wire-shopfloor.module.ts`, `flat-wire-shopfloor-routing.ts`, `public-api.ts` (standard Angular-library layout — **not** copied from any existing feature library) |
| **Shared services (consume only)** | `api-gateway.service`, `app-config.service`, `login.service` + `login-api.service`, `token-interceptor.service`, `correlation-id-interceptor` + `correlation-id.service`, `error-handler.service` + `global-error-handler-api.service`, `ui-log.service`, `notification.service`, `subscription.service`, `print-export.service`, `util.service`. **Do not rebuild these; do not copy any feature-library UI.** |
| **Routing** | Lazy-loaded `FLAT_WIRE_ROUTES` under `/flat-wire`; per-line routes e.g. `/flat-wire/line/:lineId/checkin/rod`, `/flat-wire/line/FL2/checkin/spool`, `/flat-wire/line/:lineId/run/active` |
| **Layout** | Shell layout component: header (line context + operator + clock), sidebar nav to all dashboards, `alert-banner` slot; fixed **1280×1024** shopfloor canvas |
| **Authentication** | Reuse `shared` `login.service` / `login-api.service` + `token-interceptor.service` (JWT bearer) |
| **Authorization / route guards** | `FlatWireAuthGuard` (authenticated) + `FlatWireRoleGuard` (Operations-Manager routes — DB9/9A — gated from operator routes) per the Authorization Matrix in `04-APIContract.md` |
| **Interceptors** | Reuse `token-interceptor` (JWT), `correlation-id-interceptor`, `global-error-handler-api` — **no new interceptors** |
| **Shared UI controls (all new, `fw`-prefixed)** | `pass-schedule-table`, `payoff-weight-bar`, `gauge-trace-chart`, `alert-banner`, `action-bar`, `confirm-bar`, standard `.input` with validation states, `payoff-option` selector cards, pass/fail + OK/NG/NA inspection buttons, tab-wizard, SPC tolerance-viz, monospace readouts. Built fresh from the **approved `MVP-1/Mockups/*.html`** — **not** derived from `shop-floor-common`, `checkin-precheckin`, or any existing UI library (§0.2, decision 5) |
| **Common services** | `line-context.service` (current FL1/FL2/FL3 scope), `run-state.service` (active alpha/footage/payoff via RxJS `BehaviorSubject`s; no NgRx — not used in repo) |
| **API client** | `flat-wire-api.interface.ts` with two impls — `flat-wire-api-real.service.ts` (over `shared` `api-gateway.service`) and `flat-wire-api-mock.service.ts`; DI-swapped by the `useMockData` env flag |
| **Models** | `rod.model.ts`, `spool.model.ts`, `pass-schedule.model.ts`, `active-run.model.ts`, `checkin.model.ts`, `weld-event.model.ts`, `spc-checkpoint.model.ts`, `signalr-events.model.ts` |
| **Error handling** | Reuse `error-handler.service`; standardise on the `{ success, data, errors[] }` envelope; toast + inline field errors |
| **Configuration** | `app-config.service` + `environment.*.ts` (`useMockData: true` in `environment.development.ts`, `false` elsewhere; API base + hub URL) |
| **Logging** | `ui-log.service` for client telemetry |
| **Theme** | Consume the **existing semantic design-token system** in `MVP-1/Mockups/flat-wire-shopfloor.styles.scss/.css` **as-is** — `--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono`; light + `prefers-color-scheme: dark`; `ViewEncapsulation.None`/`:host` so tokens resolve. **⚠ Use `--color-*`, never the stale `--fw-*` prefix (see Review-fixes below / G18).** |
| **Utilities** | `util.service` + local `fw` helpers (footage/gauge formatting, SVG path builders) |

## Real-time slice (client half — per §0.4)
| Piece | Deliverable |
|---|---|
| **SignalR client** | `flat-wire-signalr.service.ts` — `@microsoft/signalr` + `@microsoft/signalr-protocol-msgpack` (**MessagePack**), auto-reconnect w/ **exponential backoff** + **line-group re-join on reconnect**, JWT via `?access_token=`, callbacks **outside NgZone** into a **ring buffer**, `requestAnimationFrame`-throttled render (~60 fps), typed Observables per event, fixed window (last ~500 points). **New service — deliberately not `supervisor-monitor-hub`.** |
| **Mock stream** | `MockSignalRService` — timer-driven, emits the full typed event set so DB1/DB3 shells demo without a live hub |
| **Cache sync** | PWA service worker caches pass schedule + active-run snapshot for short network drops; "Reconnecting…" banner instead of blank screen |
| **Typed event set** | `GaugeReading[]`, `WidthReading[]`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`, **`LineStatus`, `AlertRaised`, `AlertCleared`** — the complete set the backend broadcasts (§0.3) |

## Testing
- Angular library **builds + lints** clean; joins `build:shop-floor` without breaking the chain.
- **Jest** smoke tests: guards (`FlatWireAuthGuard` redirects unauthenticated; `FlatWireRoleGuard` blocks operator from DB9/9A), `flat-wire-api-mock.service` returns schema-valid fixtures, `line-context`/`run-state` state transitions, `MockSignalRService` emits typed events into the ring buffer.
- OnPush + outside-NgZone verified: streaming a mock trace does not trigger a change-detection storm.

## Acceptance criteria (exit)
1. `flat-wire-shopfloor` builds, lints, and is reachable at `/flat-wire` behind `FlatWireAuthGuard`.
2. Shell layout renders on the 1280×1024 canvas in both light and dark; all `--color-*` tokens resolve (no `--fw-*` anywhere).
3. DI swaps real↔mock API by `useMockData`; mock returns the seed fixtures via the `{success,data,errors}` envelope.
4. `MockSignalRService` drives a `gauge-trace-chart` live (rAF-throttled, OnPush) with reconnect + group re-join simulated.
5. Jest smoke suite green.

## Review-fixes applied in this layer
- **G18 — `--color-*` not `--fw-*`:** older April docs used a stale `--fw-*` token system (`CheckinImplementationPrompt.md` was its source and was **deleted 13 Aug 2026**); this spec mandates the shared `--color-*` semantic tokens used by every mockup and the stylesheet. No `--fw-*` token exists and there is no migration to perform.
- **Retired DB2 UI:** Dashboard 2 uses its revised **`dashboard_2_rod_checkin.html`** — a guided **6-step tab-wizard** with SPC tolerance-viz and the confirm-bar gate — **not** the retired grid + progress-ring `- Old.html`.
- **Forbidden references:** no structural/UI copy from `checkin-precheckin` or any feature library; only `shared` foundational services are consumed.
- **Full SignalR event set:** the client subscribes to `LineStatus`/`AlertRaised`/`AlertCleared` (omitted in FW-080's list) in addition to the batched telemetry.
- **Canonical enums (cross-layer, define once):** `pass-schedule.model.ts` models component state as `State = 'Active' | 'Bypass' | 'Skip'` (**not** a boolean `IsActive`); `EdgeType = 'Round' | 'Square'` with UI labels "Round Edge / Flat Edge" mapped in a display pipe. Must match the backend enum (1B) and DB `CHECK` (1C).
