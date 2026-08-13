# Flat Wire Mill — Frontend Components

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `03-HLD-and-ERDiagram.md`, `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Library structure, routing, state, charts, the design-token system
**Status:** Baselined for build
**Owner:** Frontend (Angular) stream
**Audience:** Angular developers
**Shortcode:** `[CMP]`
**Part of:** `ProjectPlan/Frontend/` — index: [README.md](../README.md)

---

## 5. Frontend design

---

### 5.1 Library structure

Scaffolded with `ng generate library flat-wire-shopfloor --prefix=fw`, registered in `angular.json` and `tsconfig` paths, added to the `build:shop-floor` npm chain.

```
projects/flat-wire-shopfloor/src/lib/
├── components/            one folder per screen (DB1 … DB12, DB2A, DB7b, DB9A, DC, DM, OEE)
├── components/shared/     the fw-prefixed reusable controls ([CMP §7.6])
├── services/              flat-wire-api-*.service, flat-wire-signalr.service,
│                          line-context.service, run-state.service
├── models/                DTOs + the TypeScript mirror of the canonical enums
├── guards/                FlatWireAuthGuard, FlatWireRoleGuard
├── styles/                consumes flat-wire-shopfloor.styles.scss as-is
├── flat-wire-shopfloor.module.ts
├── flat-wire-shopfloor-routing.ts
└── public-api.ts
```

This is the **standard Angular library layout, not copied from any existing feature library**.

---

### 5.2 Routing

Lazily-loaded `FLAT_WIRE_ROUTES` under `/flat-wire`, per-line:

```
/flat-wire/line/:lineId/checkin/rod
/flat-wire/line/:lineId/staging            (FL1, FL3 only — guarded)
/flat-wire/line/FL2/checkin/spool
/flat-wire/line/:lineId/run/active
/flat-wire/line/:lineId/run/weld | spc | rolladjust | diechange | checkout
/flat-wire/status                          (DB1)
/flat-wire/passschedule | /passschedule/:id  (DB9A / DB9 — role-guarded)
/flat-wire/shift | /packing | /dies
```

---

### 5.3 The API client — two implementations

`flat-wire-api.interface.ts` with **two implementations**:

| Implementation | Backed by | Selected when |
|---|---|---|
| `flat-wire-api-real.service.ts` | The shared `api-gateway.service` | `useMockData = false` |
| `flat-wire-api-mock.service.ts` | The canonical fixture set, mirroring the DB seed | `useMockData = true` (`environment.development.ts`) |

DI-swapped by the `useMockData` environment flag. **This is what lets the UI be built against dummy data before the service exists** — the stub-first delivery model in `[API §7]`.

The mock service must mirror the **DB seed**, not invent fixtures: alphas `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042` / `RUN-0043`. Older implementation documents use inconsistent fixtures (`PS-1100-FL2-001` vs `-007`) — **do not follow them**.

---

### 5.4 State

`line-context.service` (which line is in scope) and `run-state.service` (active alpha, footage, payoff) over RxJS `BehaviorSubject`s. **No NgRx** — it is not used in the repository.

---

### 5.5 Charts

| Use | Technology | Why |
|---|---|---|
| Live streaming gauge/width traces | **Chart.js**, updated in place with `update('none')` | Bounded redraw cost under a 10 Hz feed |
| Historical FL2 profile | **Inline SVG** | The mockup's profile is hand-crafted SVG, not Chart.js |

`gauge-trace-chart` is **one component with an `isLive` flag**, not two components.

---

### 7.4 The design-token system

Every screen uses **one semantic token system**, defined in `flat-wire-shopfloor.styles.scss` and compiled to `.css`. **Edit the `.scss`; the `.css` is its output.**

| Group | Tokens |
|---|---|
| Backgrounds | `--color-background-primary` `-secondary` `-tertiary` `-info` `-success` `-warning` `-danger` `-draft` `-purple` |
| Text | `--color-text-primary` `-secondary` `-tertiary` `-info` `-success` `-warning` `-danger` `-draft` `-purple` |
| Borders | `--color-border-primary` `-secondary` `-tertiary` |
| Semantic colour | `--color-green` `#1D9E75` · `--color-amber` `#EF9F27` · `--color-red` `#D85A30` · `--color-blue` `#185FA5` · `--color-purple` `#6B3FA0` · `--color-gray` `#888780`, each with a `-light` companion |
| Type | `--font-sans` · `--font-mono` |
| Radius | `--border-radius-md` 8px · `--border-radius-lg` 12px |

**Colour semantics, used consistently:** green = active / in spec / on target · amber = warning / weld-soon / draft-attention · red = fault / out of spec / overdue · grey = bypassed or offline · **purple = Draft status and the FL3 hybrid route**.

**Dark mode** is supported via `@media (prefers-color-scheme: dark)`. Angular components must use `ViewEncapsulation.None` or `:host` scoping so the tokens resolve.

> **The `--fw-*` token prefix in older source documents is stale.** No mockup and no stylesheet uses it, and **no `--fw-*` token exists — there is no migration to perform.** The two April check-in documents that hard-coded such a system were **deleted on 13 Aug 2026**; if the prefix resurfaces from an older commit, it is wrong. Gap **G18**.

---

### 7.6 Reusable controls to build — all new, `fw`-prefixed

There is **no Angular structural or UI template** for this library. Every control is built fresh from the mockups:

`pass-schedule-table` · `confirm-bar` (amber → green gate) · `payoff-option` selector cards · `payoff-weight-bar` · `gauge-trace-chart` (live and profile modes, one component with an `isLive` flag) · `tolerance-viz` (track + marker + min/center/max labels) · `alert-banner` · `action-bar` (line-mode configurable) · `option-card` (radio card with name + consequence) · `consequence-box` · `footer-stamp` · `tab-wizard` (progressive unlock) · pass/fail `pill-btn` and OK/NG/NA inspection buttons · `.input` with `.invalid` / `field-error` states · `info-table` accordion · `machine-status-panel` · `skid-tracker` · `source-traceability-table` · `coil-label` preview with barcode bar · monospace readouts.

---
