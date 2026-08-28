# Flat Wire Mill — Frontend Components

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — **five corrections and three additions, from a review against the `Second-Branch/ual-angular` checkout.** ⛔ **§5.3's fixture list named three alphas no seed creates** (`SP-00021`, `RUN-0042`, `RUN-0043`) and did not say that `PS-1100-FL1-003` is the **negative** fixture — both corrected against `FlatWire_SampleData_*.sql`, in the very sentence that warns against following other documents' inconsistent fixtures. ⛔ **`environment.development.ts` does not exist**, so `useMockData` is a config key. ⚠ **§5.2 routed five dialogs as screens** and carried four MVP-2 routes. ⚠ **The library is `flat-wire`**, and the scaffold needs `--standalone=false`. ⚠ **§5.1's tree listed MVP-2 screens.** Added: the eleven-point registration pointer, a note that the canvas is `[VAL §7.5]`'s rather than §7.4's, and per-story ownership for §7.6's twenty controls. *(previously August 13, 2026 — split out of `03-HLD-and-ERDiagram.md`, `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*
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

Scaffolded with `ng generate library flat-wire --prefix=fw --standalone=false`, registered in `angular.json` and `tsconfig` paths, added to the `build:shop-floor` npm chain.

> **The library is `flat-wire`.** It was `flat-wire-shopfloor` until 27 Aug 2026. The prefix stays `fw`; the **mockups'** `flat-wire-shopfloor.styles.scss` / `.css` keep their own names, and the library's copy of that stylesheet is `flat-wire.styles.scss`.
>
> **`--standalone=false` is required, not stylistic** — every component in this repository is explicitly `standalone: false`, and the flag is what makes the schematic emit the NgModule instead of a standalone entry point.
>
> ⚠ **The three registrations named above are not the whole set.** A new library must also be reachable from the host app (a wrapper module in `src/app/project-routes/` plus a route in `src/app/routes.ts`), carry its own `jest.config.js` and `eslint.config.mjs` (selector prefix `fw`), have a content-data JSON and type, and have its config keys added to `environment.js` **and** `local-config.json`. The full list — **eleven integration points** — is [`Phase-01A-ImplementationPlan.md §2.1`](TaskBreakdownPlans/Phase-01A-ImplementationPlan.md) and is deliberately not restated here.

```
projects/flat-wire/src/lib/
├── components/            one folder per MVP-1 screen — DB1, DB2, DB2A, DB3 (+ FL2 and
│                          FL3 variants), DB5, DB5A, DB6, DB7, DB7b, DB8, DB11, DB12, DC
├── components/shared/     the fw-prefixed reusable controls ([CMP §7.6])
├── services/              flat-wire-api-*.service, flat-wire-signalr.service,
│                          line-context.service, run-state.service
├── models/                DTOs + the TypeScript mirror of the canonical enums
├── guards/                FlatWireAuthGuard, FlatWireRoleGuard
├── styles/                flat-wire.styles.scss — the mockups'
│                          flat-wire-shopfloor.styles.scss, consumed as-is
├── flat-wire.module.ts
├── flat-wire-routing.ts
└── public-api.ts
```

This is the **standard Angular library layout, not copied from any existing feature library**.

> ⚠ **DB9, DB9A, DB10, Die Management and OEE get no folder here — they are MVP-2**, and their mockups live in [`MVP-2/Mockups/`](../../../MVP-2/Mockups/). *(This tree listed `DB9A`, `DM` and `OEE` until 27 Aug 2026, and omitted `DB9` while listing `DB9A`.)*

---

### 5.2 Routing

Lazily-loaded `FLAT_WIRE_ROUTES` under `/flat-wire`, per-line:

```
/flat-wire/line/:lineId/checkin/rod
/flat-wire/line/:lineId/staging            (FL1, FL3 only — guarded)
/flat-wire/line/FL2/checkin/spool
/flat-wire/line/:lineId/run/active
/flat-wire/status                          (DB1)
/flat-wire/packing                         (DB7b)
```

> ⚠ **The run events are dialogs, not routes** *(corrected 27 Aug 2026)*. SPC checkpoint, WIP rejection, roll adjust, die change and rod checkout open **over** the active-run screen — `spc_checkpoint.js`, `wip_rejection.js`, `roll_adjust.js`, `die_change.js`, `rod_checkout.js` — and weld capture is DB2A's *Mark as welded* dialog since **DB4 was retired on 1 Aug 2026**. This section previously listed `run/weld | spc | rolladjust | diechange | checkout` as routes; **all five are dialogs**, and the launcher pages in [`Mockups/`](Mockups/) exist so a reviewer can see each one standalone, not as operator navigation. Whether any should also carry a deep link is **`[SCR]`'s call and is unresolved**.
>
> ⚠ **Four MVP-2 routes were also removed** — `/passschedule`, `/passschedule/:id` (DB9A / DB9), `/shift` (DB10) and `/dies` (Die Management). `/packing` (DB7b) is MVP-1 and stays.

---

### 5.3 The API client — two implementations

`flat-wire-api.interface.ts` with **two implementations**:

| Implementation | Backed by | Selected when |
|---|---|---|
| `flat-wire-api-real.service.ts` | The shared `api-gateway.service` | `useMockData = false` |
| `flat-wire-api-mock.service.ts` | The canonical fixture set, mirroring the DB seed | `useMockData = true` (`src/assets/local-config.json` — see below) |

DI-swapped by the `useMockData` environment flag. **This is what lets the UI be built against dummy data before the service exists** — the stub-first delivery model in `[API §7]`.

> ⚠ **`useMockData` is a config key, not an `environment.*.ts` constant** *(corrected 27 Aug 2026)*. `ual-angular` has **no `environment.development.ts`** — `src/environments/` carries only `environment.ts` and `environment.prod.ts`, and neither holds anything but `production`. Configuration is runtime JSON: `environment.js` writes `src/assets/config.json`, which every built environment reads, while `ng serve` reads `src/assets/local-config.json`, which the production asset list does not deploy. So **`useMockData: true` lives in `local-config.json` and `false` in `environment.js`**, read through `AppConfigService.getEndpoint()`. ⚠ **Both files must carry the key** — `AppConfig` is `typeof local-config.json`, so that file is also the type.

The mock service must mirror the **DB seed**, not invent fixtures. **Measured against `Database/Schema/SQL/FlatWire_SampleData_*.sql` on 27 Aug 2026:**

| Use | Fixture | |
|---|---|---|
| Rods | **`R00041`–`R00048`** | |
| Spools | **`SP-00031`–`SP-00033`** | ⚠ **not `SP-00021`** — no seed creates it; it occurs only inside a comment |
| Runs | **`RUN-0001`–`RUN-0005`** | ⚠ **not `RUN-0042` / `RUN-0043`** — no seed creates either |
| FL1 happy path | **`PS-1100-FL1-001`** (`Active`) | |
| FL1 negative | `PS-1100-FL1-003` (**`Draft`**) | ⚠ must be **refused** — `SCHEDULE_NOT_ACTIVE` → 422. A stub that acknowledges it successfully asserts the opposite of the contract (`[API §7.2]`) |
| FL2 happy path | **`PS-1100-FL2-001`** (`Active`) | |
| FL3 hybrid | `PS-1100-FL3-001` (`Active`) | |

⚠ **This paragraph previously named `SP-00021`, `RUN-0042` and `RUN-0043`** — three alphas no seed creates — and named `PS-1100-FL1-003` without saying it is the **negative** fixture. Older implementation documents also use inconsistent fixtures (`PS-1100-FL2-001` vs `-007`) — **do not follow those either**.

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

> **The canvas is not defined in this section.** It is `[VAL §7.5]`'s, and it is **1920 × 1080** as of 27 Aug 2026. This section owns tokens only — if you arrived here from a citation about the canvas, **the citation is wrong**.

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

**Twelve of them are Phase 1A; the rest belong to the screen that first needs them** *(added 27 Aug 2026 — the list above named no owner, so eight controls read as unowned)*:

| Owner | Controls |
|---|---|
| **`FW-133`** — shared composite controls | `pass-schedule-table` · `payoff-weight-bar` · `gauge-trace-chart` · `tolerance-viz` · `tab-wizard` · `action-bar` |
| **`FW-134`** — shared primitives | `.input` states · monospace readouts · `pill-btn` and OK/NG/NA buttons · `alert-banner` · `confirm-bar` · `payoff-option` |
| **The screen story that first needs it** | `option-card` · `consequence-box` · `footer-stamp` · `info-table` accordion · `machine-status-panel` · `skid-tracker` · `source-traceability-table` · `coil-label` |

⚠ **Row 3 is a costing boundary, not a licence to reimplement.** Those controls are still built once and shared — they are simply not costed in 1A.

✅ **Two of `[VAL §7.5]`'s constraints are met by reuse rather than by a new control:** the on-screen keyboard and numeric keypad are `ngx-touch-keyboard` (already a dependency, and `NgxTouchKeyboardModule` is imported by `SharedModule`) and `shared`'s `KeypadComponent`. Consuming a foundational `shared` component is **not** a `D-06` violation.

---
