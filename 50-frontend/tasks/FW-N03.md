---
id: FW-N03
legacy_id:
title: Angular library scaffold, routing and configuration
status: not-started
status_confirmed: false
status_note: "⬜ **Not started.** The 28 Aug 2026 build was **reverted on 31 Aug 2026** — `projects/flat-wire/` no longer exists in `Second-Branch/ual-angular` and none of the eleven integration points are wired. This plan is the unexecuted spec again: **the root of Phase 1A, and nothing on the FE stream starts until it lands**"
owner:
jira:
mvp: 1
phase: "1A"
stream: FE
streams: [FE]
priority: critical
hours: 24
sprint: S0
depends_on: []
blocked_by: []
has_plan: true
started:
completed:
---
# FW-N03 · `flat-wire` Angular library scaffold, routing and configuration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 31, 2026 — ⬜ **REVERTED to not-started.** The 28 Aug 2026 build was undone: `projects/flat-wire/` and the eleven host integration points were removed from `Second-Branch/ual-angular`, and the **§6 execution record was deleted** with it. **Nothing this plan describes exists in any checkout.** Earlier: August 28, 2026 — **refreshed against the measured repository.** ✅ Re-measured and unchanged: `angular.json` holds **31 entries and no `flat-wire`**, and every precedent this plan names is present — `projects/ot-signup/`, `print-traveler-wrapper.module.ts`, the `build:base` / `build:shop-floor` / `lint:styles` / `everything` scripts, `shop-floor-common.styles.scss` already in the app `styles` array, and the `anyComponentStyle` **10 kB error / 5 kB warning** budget. ⚠ The `[TCS]` suite holds **405 defined cases**, not 799 — `TC-799` is the highest *id*. Earlier the same day: **the `[TB §7]` acceptance criterion gained `--standalone=false`**, closing the last divergence between the card a developer is measured against and the command that actually produces an NgModule library; §1 records it. Earlier the same day the card was renamed to `flat-wire` with the repository sweep, the *"cannot be met as written"* table dropped to one row and `F-13` was struck from §4. Written 27 Aug 2026 as one of the nine plans `Phase-01A-ImplementationPlan.md` was divided into
**Document Type:** Implementation plan for a single backlog story
**Status:** ⬜ **Not started.** The 28 Aug 2026 build was **reverted on 31 Aug 2026** — `projects/flat-wire/` no longer exists in `Second-Branch/ual-angular` and none of the eleven integration points are wired. This plan is the unexecuted spec again: **the root of Phase 1A, and nothing on the FE stream starts until it lands**
**Owner:** Frontend (Angular) stream
**Audience:** The Angular developer building `FW-N03`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Depends on:** **nothing** — the single root of Phase 1A
**Unblocks:** [`FW-130`](FW-130.md) · [`FW-131`](FW-131.md) · [`FW-132`](FW-132.md) · [`FW-135`](FW-135.md) — **four at once**
**Part of:** `ProjectPlan/Frontend/tasks/` — index: [Orchestration.md](Orchestration.md) · shared context: [Phase-01A-ImplementationPlan.md](Phase-01A-ImplementationPlan.md)

---

> **Read [`[P1A §2]`](Phase-01A-ImplementationPlan.md) first — the measured state of the checkout.**
> This plan does not restate it. The decisions it depends on are `[P1A §4]`'s `F-01`, `F-02`, `F-11`
> and `F-13`, cited where they bite and not re-argued here.
>
> **This is the root node of Phase 1A.** It is the only 1A story with no dependency, and **four
> others name it as theirs** (`FW-130`, `FW-131`, `FW-132`, `FW-135`). Nothing on the FE stream
> starts until it lands.
>
> This plan is derived from the specifications and **loses to every one of them.**

---

## 1. The story

From `[TB §7]` — reproduced verbatim, because the acceptance criteria are the contract:

> ###### FW-N03 · Angular library scaffold, routing and configuration
> **Hours:** 24 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE
>
> **As a** developer,
> **I want** a `flat-wire` Angular library scaffolded, routed and configured,
> **So that** every later phase is pure feature work with no infrastructure lift.
>
> **Acceptance Criteria:**
> - [ ] Library generated via `ng generate library flat-wire --prefix=fw --standalone=false` → `projects/flat-wire/`; registered in `angular.json` and `tsconfig` paths
> - [ ] Added to the `build:shop-floor` npm chain **for build ordering only** — no UI reuse from any library in that chain
> - [ ] Folder structure `src/lib/{components,components/shared,services,models,guards,styles}` + module, routing and `public-api.ts` — standard Angular-library layout, **not** copied from any existing feature library
> - [ ] Lazy-loaded `FLAT_WIRE_ROUTES` under `/flat-wire` with per-line routes
> - [ ] `app-config.service` + `environment.*.ts` carry `useMockData`, API base and hub URL; `ui-log.service` wired for client telemetry
> - [ ] Library builds and lints clean and does not break the `build:shop-floor` chain
>
> **Dependencies:** None — the `shared` foundational services already exist
> **Blockers:** —

⚠ **One of those criteria cannot be met as written:**

| Criterion says | Reality | Decision |
|---|---|---|
| `environment.*.ts` carry `useMockData` | **there is no `environment.development.ts`**; config is runtime JSON | `F-02` |

✅ **Two things that used to be wrong here are now right.** The card quoted `flat-wire-shopfloor` until
28 Aug 2026, when the repository sweep took `[TB §7]` and `phase-01a` to **`flat-wire`** (`F-13`). The same
day the AC gained **`--standalone=false`**: the command had read `ng generate library flat-wire --prefix=fw`,
and **a developer following it exactly would have produced a standalone entry point to unpick** — the
schematic emits the NgModule this repository needs only when the flag is present (§2 step 1). `[CMP §5.1]`
and this plan already carried it; the acceptance criterion, `phase-01a` and the master specification did
not. **All six copies of the command now agree.**

### 1.1 In scope

| # | Deliverable |
|---|---|
| 1 | `projects/flat-wire/` generated, with the NgModule the repository's conventions require |
| 2 | **All eleven integration points** of `[P1A §2.1]` — the three the story names are not the whole set |
| 3 | The `[CMP §5.1]` folder tree, created empty |
| 4 | `FlatWireModule` and `flat-wire-routing.ts` with `[CMP §5.2]`'s routes |
| 5 | `src/assets/content-data/flat-wire.json` + the `FlatWireContent` type (`F-11`) |
| 6 | Config keys in `environment.js` and `local-config.json` (`F-02`) |

### 1.2 Out of scope — and who owns each

| Not here | Owner |
|---|---|
| The shell component, header, sidebar, canvas | [`FW-130`](FW-130.md) |
| Guard **bodies**, interceptors, the error envelope | [`FW-131`](FW-131.md) |
| The API client and models | [`FW-132`](FW-132.md) |
| The SignalR service | [`FW-135`](FW-135.md) |
| Any control or screen | `FW-133` / `FW-134` and the phase-3+ stories |

> This story creates `guards/` and puts **route wiring** in place. `FlatWireAuthGuard` may be
> referenced from the routes as a stub; **its logic is `FW-131`'s.**

---

## 2. Build order

### Step 1 — generate, with the flag that decides the outcome

```bash
cd c:\UAL\Second-Branch\ual-angular       # F-01
ng generate library flat-wire --prefix=fw --standalone=false
```

**`--standalone=false` is not stylistic.** Measured against `node_modules/@schematics/angular/library`:
the schematic branches on `options.standalone` and, when false, **also runs the `module` schematic**.
Without the flag you get a standalone entry point to unpick in a repository where every component is
explicitly `standalone: false`.

### Step 2 — undo three things the schematic does

| # | What it does | What to do |
|---|---|---|
| 1 | writes the tsconfig path as `"flat-wire": ["./dist/flat-wire"]` | normalise to **`dist/flat-wire`** (every existing entry omits the `./`) and **move it inside the `/** mono repo paths **/` markers** |
| 2 | **adds a `references` array to the root `tsconfig.json`** | **delete it** — the root tsconfig has none, and no other library introduced one. Or pass `--skip-ts-config` and add the path by hand |
| 3 | generates **no** `eslint.config.mjs` and **no** `jest.config.js` | add both, in the shape of `projects/ot-signup/` |

### Step 3 — the eleven integration points

**Do all eleven.** `[P1A §2.1]` is the table; this is the checklist. The story names three of them,
which is why a library that builds can still be unreachable from the app.

- [ ] `angular.json` — project entry, **`prefix: fw`**, ng-packagr builder, lint target
- [ ] `tsconfig.json` — the path, inside the markers
- [ ] `jest.base.config.js` — `'^flat-wire': '<rootDir>/dist/flat-wire/fesm2022/flat-wire.mjs'`
- [ ] `package.json` — `ng build flat-wire` appended to **`build:shop-floor`**, plus a `test:flat-wire` script
- [ ] `src/app/routes.ts` — the lazy route
- [ ] `src/app/project-routes/flat-wire-wrapper.module.ts` — `@NgModule({ imports: [FlatWireModule] })`, importing from the **source** path, as `print-traveler-wrapper.module.ts` does
- [ ] `src/assets/content-data/flat-wire.json`
- [ ] `src/types/content-data/index.d.ts` — `export type FlatWireContent = typeof flatWireJson;`
- [ ] `environment.js` — `flatWireApiUrl`, `flatWireHubUrl`, `useMockData: false`
- [ ] `src/assets/local-config.json` — the same three keys, **`useMockData: true`**
- [ ] `angular.json` app `styles` array — reserved for `FW-130`'s stylesheet, so leave it to that story

⚠ **`build:shop-floor` is build ordering only.** Joining that chain implies **no** UI reuse from
`checkin-precheckin`, `shop-floor-common`, `slitter-*` or anything else in it — `D-06`, `[ARC §2.2]`.

### Step 4 — the library's own files

Copy the *shape*, never the content, from `projects/ot-signup/`:

| File | Note |
|---|---|
| `package.json` | name `flat-wire`, `tslib` dependency, Angular peer deps |
| `ng-package.json` | `"dest": "../../dist/flat-wire"` |
| `tsconfig.lib.json` · `.lib.prod.json` · `.spec.json` | unchanged from the schematic's, which are correct |
| `eslint.config.mjs` | re-export the root config, overriding `@angular-eslint/component-selector` and `directive-selector` to prefix **`fw`** |
| `jest.config.js` | `roots: ['<rootDir>/projects/flat-wire/src']`, `coverageDirectory`, `displayName`, and the repo's **95 %** thresholds (`F-08`) |

### Step 5 — the folder tree

```
projects/flat-wire/src/lib/
├── components/            one folder per MVP-1 screen, created empty
├── components/shared/     FW-133 / FW-134 fill this
├── services/
├── models/
├── guards/
├── styles/
├── flat-wire.module.ts
├── flat-wire-routing.ts
└── public-api.ts
```

**Standard Angular-library layout, not copied from any feature library** (`[CMP §5.1]`).

### Step 6 — `FlatWireModule`

On the `ot-signup.module.ts` shape:

```typescript
@NgModule({
  declarations: [...],
  imports: [CommonModule, FlatWireRoutingModule, FormsModule,
            ReactiveFormsModule, NgbModule, SharedModule.forRoot()],
  providers: [...],
  exports: [...]
})
export class FlatWireModule {}
```

⚠ **`SharedModule.forRoot()` is load-bearing and is easy to read as boilerplate.** It provides this
module's own `HttpClient` (via `provideHttpClient(withInterceptorsFromDi())` in `SharedModule`'s own
`providers`) **and** the three `HTTP_INTERCEPTORS` into the same injector — which is what wires token,
correlation-id and error interception for the whole library. `FW-131` verifies it; **this story must
not omit it.**

### Step 7 — routing

`RouterModule.forChild(FLAT_WIRE_ROUTES)` with `[CMP §5.2]`'s routes, each carrying the repo's
content-data convention:

```typescript
{ path: 'line/:lineId/checkin/rod', component: RodCheckinComponent,
  canActivate: [FlatWireAuthGuard],
  data: { resolveData: ['flat-wire', 'shared'] },
  resolve: { contentData: ContentDataService } }
```

⚠ **The run events are dialogs, not routes** — do not add `run/weld | spc | rolladjust | diechange |
checkout`. `[CMP §5.2]` was corrected on 27 Aug 2026.
⚠ **No MVP-2 routes** — `/passschedule`, `/shift`, `/dies` are not built.
⚠ Under `HashLocationStrategy` the base resolves as **`#/flat-wire`** (`F-09`).

### Step 8 — configuration and logging

`useMockData` / `flatWireApiUrl` / `flatWireHubUrl` per `F-02`, read through
`AppConfigService.getEndpoint()`. **Nothing to build for error telemetry** — `SharedModule.forRoot()`
already registers `GlobalErrorHandler`, which uses `UILogService` internally (`F-06`). Deliberate log
calls need one additive export in `projects/shared/src/public-api.ts`; **take that only if you have a
call to make.**

---

## 3. Verification

**In dependency order.** `build:base` first — the tsconfig path resolves `shared` to `dist/shared`.

```bash
npm run build:base            # REQUIRED FIRST
ng build flat-wire            # -> dist/flat-wire, fesm2022 bundle present
npm run build:shop-floor      # chain unbroken
ng lint flat-wire             # clean; fw selector prefix enforced
npm run test:flat-wire        # green at 95 %
npm start                     # then #/flat-wire resolves
```

| AC | Proof |
|---|---|
| 1 · generated and registered | `ng build flat-wire` succeeds; `dist/flat-wire` exists; the tsconfig path sits inside the markers |
| 2 · in the `build:shop-floor` chain | `npm run build:shop-floor` completes; **no import from any other library in it** |
| 3 · folder structure | the tree of step 5 exists; `public-api.ts` exports the module |
| 4 · lazy routes under `/flat-wire` | `#/flat-wire/...` resolves through the wrapper module; a route logs its resolved `contentData` |
| 5 · config carries the three keys | `AppConfigService.getEndpoint().useMockData` is `true` under `ng serve` |
| 6 · builds and lints clean | the two commands above, plus `npm run lint:styles` unaffected |

**Test cases:** ⛔ **None.** Phase 1A has **no test cases in `[TCS]`** — measured 28 Aug 2026 against its **405 defined cases** (the ids run to `TC-799`, but 47 are cited and never defined), nothing covers the Angular library, the shell, the canvas, the guards or the mock hub. This story's verification is this plan plus Jest, and nothing else. → `[TCS]`, `[P1A §6.13]`

---

## 4. Blockers and open items

**None block the build.** For completeness:

| Item | Effect |
|---|---|
| `F-01` — the checkout differs from `phase-01a` / `[ARC §2.1]` | raised for `[ARC]`; does not stop work |
| ~~`F-13` — the library rename~~ | ✅ **Closed 28 Aug 2026.** `phase-01a`, `[TB §7]`, `[ARC]`/`D-01`, the master specification and eleven other documents now say **`flat-wire`**. The mockups' `flat-wire-shopfloor.styles.scss` keeps its own name by design |
| `F-09` — the route base and machine context | ⚠ **decide before `FW-132`**, because `line-context.service` is where `CURRENT_MACHINE` would be set |

---

## 5. Handoff

**Landing this unblocks four stories at once** — `FW-130`, `FW-131`, `FW-132` and `FW-135`
(`[Orchestration §2]`, wave 1). Tell those four developers three things:

1. **`SharedModule.forRoot()` is already imported** — do not add interceptors, and do not import it again in a child module.
2. **The `styles` array slot in `angular.json` is deliberately empty** — `FW-130` fills it.
3. **The routes exist and reference `FlatWireAuthGuard`** — `FW-131` supplies its body; until then it is a stub that returns `true`.
