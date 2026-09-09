# Flat Wire Mill — Frontend Components

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — Change history is in [`../CHANGELOG.md`](../CHANGELOG.md) · **8 Sep 2026 (`D-56`): `LineId` is renamed `MachineName` throughout** — same `VARCHAR(5)` shape, same `CHECK` values, operator-visible labels unchanged. `FW-N17`/`FW-N18`/`FW-N19`.
**Document Type:** Library structure, routing, state, charts, the design-token system
**Status:** Baselined for build
**Owner:** Frontend (Angular) stream
**Audience:** Angular developers
**Shortcode:** `[CMP]`
**Part of:** `ProjectPlan/Frontend/` — index: [README.md](../DOCUMENTS.md)

---

## 5. Frontend design

---

### 5.1 Library structure

Scaffolded with `ng generate library flat-wire --prefix=lib --standalone=false`, registered in `angular.json`.

> **The library is `flat-wire`.** It was `flat-wire-shopfloor` until 27 Aug 2026. **The selector prefix is `lib`** (`D-54`); the **mockups'** `flat-wire-shopfloor.styles.scss` / `.css` keep their own names.
>
> ⚠ **Three corrections landed here on 7 Sep 2026, all measured against the built library.** *(1)* This section said `--prefix=fw` and *"the prefix stays `fw`"*; `angular.json` declares `"prefix": "lib"`, `eslint.config.mjs` enforces `lib` for components and directives, and all five components ship as `lib-*` — as do all 27 sibling libraries, so `fw` would have made flat wire the only one that deviates. `D-54` ratifies `lib`. *(2)* The **`tsconfig` paths entry and the `build:shop-floor` chain entry are NOT required and deliberately absent** — the host reaches a routed library through a wrapper module that imports it from **source**, so it needs no `dist` bundle and no build-ordering entry, exactly as [`[UIC §1.1]`](UIConventions.md) explains and as `slitter-interface` and `coil-receiving` both demonstrate. *(3)* **The library carries no stylesheet**, so `flat-wire.styles.scss` is removed from §5.1's tree below — see [`[UIC §2]`](UIConventions.md).
>
> **`--standalone=false` is required, not stylistic** — every component in this repository is explicitly `standalone: false`, and the flag is what makes the schematic emit the NgModule instead of a standalone entry point.
>
> ⚠ **The three registrations named above are not the whole set.** A new library must also be reachable from the host app (a wrapper module in `src/app/project-routes/` plus a route in `src/app/routes.ts`), carry its own `jest.config.js` and `eslint.config.mjs` (selector prefix **`lib`**, `D-54`), have a content-data JSON and type, and have its config keys added to `environment.js` **and** `local-config.json`. The full list — **eleven integration points** — is [`Phase-01A-ImplementationPlan.md §2.1`](tasks/Phase-01A-ImplementationPlan.md) and is deliberately not restated here.

```
projects/flat-wire/src/lib/
├── components/            one folder per MVP-1 screen — DB1, DB2, DB2A, DB3 (ONE folder,
│                          all three lines — D-55), DB5, DB5A, DB6, DB7, DB7b, DB8, DB11,
│                          DB12, DC
├── components/shared/     the lib-prefixed reusable controls ([CMP §7.6]) — for controls
│                          ONLY flat wire uses; a control shared with another library
│                          goes to projects/shared instead ([UIC §3.22])
├── constants/ enums/      api-methods + screen constants; LineState, SpoolMilestone
├── interfaces/            the per-screen VIEW models — and they are the contract any
│                          API mapper must return ([UIC §5])
├── services/              flat-wire-api-*.service, flat-wire-signalr.service,
│                          line-context.service, run-state.service
├── models/                wire DTOs + the TypeScript mirror of the canonical enums
├── guards/                FlatWireRoleGuard  (no FlatWireAuthGuard — the shell binds
│                          shared's AuthenticationGuard; FW-131)
├── flat-wire.module.ts
├── flat-wire-routing.module.ts
└── public-api.ts
```

⚠ **`styles/` is deliberately absent, and so is any `.scss`** *(corrected 7 Sep 2026 — this tree
carried `styles/flat-wire.styles.scss` as though the mockups' sheet were shipped into the library)*.
`projects/flat-wire/` **has no stylesheet and registers none**: the mockups' `--color-*` palette
exists nowhere in the application, and anything reusable enough to deserve a class goes into
`src/styles/` under a generic name. See [`[UIC §2]`](UIConventions.md), which records the five
classes created that way.

⚠ **As built, `components/shared/`, `services/`, `models/` and `guards/` do not exist yet** — they
arrive with their first occupant. `constants/`, `enums/` and `interfaces/` do.

This is the **standard Angular library layout, not copied from any existing feature library**.

> ⚠ **DB9, DB9A, DB10, Die Management and OEE get no folder here — they are MVP-2**, and their mockups live in [`MVP-2/Mockups/`](../../../MVP-2/Mockups/). *(This tree listed `DB9A`, `DM` and `OEE` until 27 Aug 2026, and omitted `DB9` while listing `DB9A`.)*

---

### 5.2 Routing

Lazily-loaded `FLAT_WIRE_ROUTES` under `/flat-wire`, per-line:

```
/flat-wire/line/:machineName/checkin/rod
/flat-wire/line/:machineName/staging            (FL1, FL3 only — guarded)
/flat-wire/line/FL2/checkin/spool
/flat-wire/home/:machineName                    (DB3 — see the D-55 note below)
/flat-wire/status                          (DB1)
/flat-wire/packing                         (DB7b)
```

> ⚠ **The run events are dialogs, not routes** *(corrected 27 Aug 2026)*. SPC checkpoint, WIP rejection, roll adjust, die change and rod checkout open **over** the active-run screen — `spc_checkpoint.js`, `wip_rejection.js`, `roll_adjust.js`, `die_change.js`, `rod_checkout.js` — and weld capture is DB2A's *Mark as welded* dialog since **DB4 was retired on 1 Aug 2026**. This section previously listed `run/weld | spc | rolladjust | diechange | checkout` as routes; **all five are dialogs**, and the launcher pages in [`Mockups/`](Mockups/) exist so a reviewer can see each one standalone, not as operator navigation. Whether any should also carry a deep link is **`[SCR]`'s call and is unresolved**.
>
> ⚠ **Four MVP-2 routes were also removed** — `/passschedule`, `/passschedule/:id` (DB9A / DB9), `/shift` (DB10) and `/dies` (Die Management). `/packing` (DB7b) is MVP-1 and stays.

> ### ⭐ The `D-55` note — the route grammar inverted on 7 September 2026
>
> **DB3 is now `#/flat-wire/home/:machineName`** — one component for FL1, FL2 and FL3, with the line read
> from the segment. `FW-N15` owns the route, the resolver and `LINE_PROFILES`. The `#` needs no work:
> `HashLocationStrategy` is provided app-wide in `app.module.ts`.
>
> ⚠ **This is screen-first, and the five routes above are line-first.** They are shaped
> `/flat-wire/line/:machineName/...` — the line *above* the screen — while `home/:machineName` puts it *below*.
> ⛔ **Two grammars in one library is a defect, not a style difference.** Either the siblings become
> `/flat-wire/checkin/rod/:machineName`, `/flat-wire/spool-queue/:machineName` and so on, or the split is
> recorded as a deliberate decision. **It is currently neither, and this note is the flag.**
>
> ⚠ **`#/flat-wire` is stranded** now the landing child carries a required param. It resolves from
> the terminal's own machine registration, falling back to a line picker — which is **`FW-204`**,
> whose note already complains that *"`/flat-wire` already resolves — to DB3, not to this story's
> tiles."* `D-55` is what makes that story coherent rather than redundant.
>
> ⛔ **`screenKey` does not follow the route.** It is stamped into every element id
> ([`[UIC §3.22]`](UIConventions.md)), so it stays a stable semantic key; `'home'` is a location, not
> a screen.

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

`line-context.service` (which line is in scope — ⭐ **`D-55` makes this the single site that resolves the line from the URL segment**, holding `machineName`, `station` and `machineIdx`; `station` equals `machineName` by rule and the machine values are **cited** from [`[INT]`](../20-architecture/Integration.md), never retyped. It also owns **`LINE_PROFILES`**, the four-field-per-line configuration the one Active Run component is driven by — info-grid subject, centre status card, action set, spool-completion overlay. ⛔ Nothing the API already carries may enter it: `components[]`, `RouteMode`, `weldEvents[]`, `payoffs[]` and the station claim are **data**. `FW-N15` owns it) and `run-state.service` (active alpha, footage, payoff) over RxJS `BehaviorSubject`s. **No NgRx** — it is not used in the repository.

---

### 5.5 Charts

| Use | Technology | Why |
|---|---|---|
| Live streaming gauge/width traces | **Chart.js**, updated in place with `update('none')` | Bounded redraw cost under a 10 Hz feed |
| Historical FL2 profile | **Inline SVG** | The mockup's profile is hand-crafted SVG, not Chart.js |

`gauge-trace-chart` is **one component with an `isLive` flag**, not two components.

> ⭐ **`D-55` (7 Sep 2026) makes the trace treatment uniform across all three lines** — the same panel titles (`Gauge` and `Width`), the same axis, one source path, with `isLive` driven by the data rather than by the line. The mockups' per-line titles (*"Final gauge · post S3"*) are **superseded**, and that departure is recorded in `FW-062` and [`[UIC §5]`](UIConventions.md).
>
> ⛔ **A `null` gauge or width reading renders a NO-MEASUREMENT state, never a flat line at target** — that would show an operator a perfectly in-spec measurement of nothing (`FW-181`).
>
> ✅ **THE `FR-120` COLLISION IS RESOLVED, 9 Sep 2026 — in `D-55`'s favour.** This note recorded that uniform treatment *"collides with `FR-120`, which is `Must` and `[CONFIRMED]`"*, and with `ActiveRunMonitor` §3.2 and `TC-140`, and that *"the reconciliation is a client decision and is deliberately not made here."* **It is made.** `FR-120` is **superseded** and its basis — assumption `A3` of `[PLC §14]` — **retired**: FL2 measures gauge and width live, at 4 s. `ActiveRunMonitor` §3.2 is rewritten and `TC-140` inverted. ⛔ **So the inline-SVG profile row does NOT stand — it is retired with `FR-120`.** `D-55`'s uniform treatment is now simply correct, with `isLive` driven by the data on every line. ⚠ **What remains line-specific is cadence, not treatment:** FL2 publishes at **4 s**, so footage gaps must render as gaps rather than be interpolated, and any consecutive-reading threshold is per line.

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

✅ **Built and living in `projects/shared`, because slitter-interface consumes them too:**

| Control | Consumers today |
|---|---|
| **`lib-nav-rail`** — the collapsible icon rail | DB3 landing · DB1 supervisor · `slitter-traveler-landing`'s left rail |
| **`lib-chart-canvas`** — a canvas and its Chart.js lifetime | via `lib-trace-panel`; available to any chart |
| **`lib-trace-panel`** — reading header + chart + statistics | DB3's two trace panels **and** the enlarged popup |

⚠ **The rail was never in this register** — `[UIC §3.6]` makes a mockup's action bar *become* the
rail, so its action half sits conceptually with `FW-133`'s `action-bar` and its navigation half with
`FW-130`'s shell. **No hours have been restated for either story**; this row records what exists.

⛔ **`slitter-traveler-landing`'s RIGHT sidebar was deliberately left on its own markup.** It is not
item-driven: seven bespoke buttons, an embedded `<lib-format-grid>`, a spinner-instead-of-icon
loading state, a red icon on a white badge, and two actions that are component-only methods on a
component already at the 400-line lint ceiling. Bending the shared rail to fit one caller would have
cost more than it saved.

✅ **Two of `[VAL §7.5]`'s constraints are met by reuse rather than by a new control:** the on-screen keyboard and numeric keypad are `ngx-touch-keyboard` (already a dependency, and `NgxTouchKeyboardModule` is imported by `SharedModule`) and `shared`'s `KeypadComponent`. Consuming a foundational `shared` component is **not** a `D-06` violation.

---
