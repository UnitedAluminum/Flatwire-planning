# FW-N03 · `flat-wire` Angular library scaffold, routing and configuration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 28, 2026 — ✅ **EXECUTED. The library is built** — see the new **§6 execution record**: 21 library files, a host diff of **8 files / +40 −1**, lint and styles clean, 3 tests at **100 %** coverage, and `build:shop-floor` green with `flat-wire` last. **Six schematic behaviours the plan did not predict are recorded in §6.2** — two of Step 2's three predictions are now wrong and Step 4's claim that the schematic's tsconfigs are correct is **false in a Jest repo**. ⛔ **§6.4: the host app cannot be built here at all** (`flexmonster` neither declared nor installed), so AC 4's runtime half is verified by a scoped `tsc` instead. Earlier the same day: **refreshed against the measured repository.** ✅ Re-measured and unchanged: `angular.json` holds **31 entries and no `flat-wire`**, and every precedent this plan names is present — `projects/ot-signup/`, `print-traveler-wrapper.module.ts`, the `build:base` / `build:shop-floor` / `lint:styles` / `everything` scripts, `shop-floor-common.styles.scss` already in the app `styles` array, and the `anyComponentStyle` **10 kB error / 5 kB warning** budget. ⚠ The `[TCS]` suite holds **405 defined cases**, not 799 — `TC-799` is the highest *id*. Earlier the same day: **the `[TB §7]` acceptance criterion gained `--standalone=false`**, closing the last divergence between the card a developer is measured against and the command that actually produces an NgModule library; §1 records it. Earlier the same day the card was renamed to `flat-wire` with the repository sweep, the *"cannot be met as written"* table dropped to one row and `F-13` was struck from §4. Written 27 Aug 2026 as one of the nine plans `Phase-01A-ImplementationPlan.md` was divided into
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **BUILT 28 Aug 2026 — wave 0 is complete.** `projects/flat-wire/` exists, builds, lints and tests at 100 %; all eleven integration points verified. **§6 is the execution record.** ⚠ One acceptance criterion is proved by compilation rather than in a browser, because the host app cannot be built in this checkout — `flexmonster` is missing (§6.4)
**Owner:** Frontend (Angular) stream
**Audience:** The Angular developer building `FW-N03`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Depends on:** **nothing** — the single root of Phase 1A
**Unblocks:** [`FW-130`](FW-130-Shell-Layout-And-Canvas.md) · [`FW-131`](FW-131-Guards-Interceptors-And-Envelope.md) · [`FW-132`](FW-132-API-Client-And-Domain-Models.md) · [`FW-135`](FW-135-SignalR-Client-Service.md) — **four at once**
**Part of:** `ProjectPlan/Frontend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md) · shared context: [Phase-01A-ImplementationPlan.md](Phase-01A-ImplementationPlan.md)

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
| The shell component, header, sidebar, canvas | [`FW-130`](FW-130-Shell-Layout-And-Canvas.md) |
| Guard **bodies**, interceptors, the error envelope | [`FW-131`](FW-131-Guards-Interceptors-And-Envelope.md) |
| The API client and models | [`FW-132`](FW-132-API-Client-And-Domain-Models.md) |
| The SignalR service | [`FW-135`](FW-135-SignalR-Client-Service.md) |
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

---

## 6. Execution record — built 28 Aug 2026

**Executed against `c:\UAL\Second-Branch\ual-angular` @ `feature/flat-wire`** (`F-01`), working tree
clean at start. ✅ **All six acceptance criteria met and all eleven integration points verified**;
**one criterion could not be demonstrated at runtime**, for a pre-existing reason unrelated to this
story — see the blocker below.

### 6.1 What was produced

| | |
|---|---|
| **Library** | `projects/flat-wire/` — 21 files. `ng build flat-wire` → `dist/flat-wire/fesm2022/flat-wire.mjs` in **7.9 s** |
| **Host diff** | **8 files, +40 / −1** — `angular.json` (+21), `src/app/routes.ts` (+7), `environment.js` (+3), `src/assets/local-config.json` (+3), `src/types/content-data/index.d.ts` (+2), `package.json` (+3/−1), `jest.base.config.js` (+1), `tsconfig.json` (**+1**) |
| **New host files** | `src/app/project-routes/flat-wire-wrapper.module.ts` · `src/assets/content-data/flat-wire.json` |
| **Lint** | `ng lint flat-wire` — **All files pass**. `npm run lint:styles` — clean |
| **Tests** | `npm run test:flat-wire` — **3 passed, 100 % statements / branches / functions / lines** |
| **Chain** | `npm run build:shop-floor` — all nine entry points built, **`flat-wire` last** |
| **Line endings** | every touched file is **pure CRLF**, zero stray LF. `tsconfig.json`'s diff is **one line** |

### 6.2 ⛔ Six things the plan did not predict

**Step 2 predicted three schematic behaviours. Angular 20.3.15 does five things, and two of the
plan's three are now wrong.** Recorded so the next library scaffold does not re-derive them.

| # | What actually happened | Consequence |
|---|---|---|
| 1 | ⛔ **The schematic reformats the whole of `angular.json`** — every inline object expanded, a **~1,200-line diff** against a repo whose prettier config is `objectWrap: collapse`, `printWidth: 120` | **`git checkout -- angular.json`, then insert the project entry by hand** in the house style, alphabetically (`customer-search` → `flat-wire` → `furnace-scheduling`). Result: **+21 lines** |
| 2 | ⚠ **It now generates `eslint.config.mjs`** — with the correct `fw` prefix. **Step 2 item 3 is half obsolete** | Kept the file but rewrote it to the house shape (plain array export + BOM, as `ot-signup`); `jest.config.js` is still not generated and was written by hand |
| 3 | ⛔ **Step 4 is wrong that the schematic's tsconfigs "are correct".** Its `tsconfig.spec.json` types **`jasmine`** and extends the root `tsconfig.json` — in a **Jest** repository | All three replaced with the house shape: `types: ["jest","node"]`, `module: CommonJs`, extends `../../tsconfig.spec.json`. **Following the plan literally would have produced a spec config that does not type Jest globals** |
| 4 | ⚠ **It emits Angular-20 default names** — `flat-wire-module.ts`, `flat-wire.ts`. Measured house convention: **36 × `*.module.ts`**, **313 × `*.component.ts`**, **5 × `*-routing.module.ts`** | Renamed to `flat-wire.module.ts` / `flat-wire-routing.module.ts`. ⚠ **This makes `[CMP §5.1]`'s `flat-wire-routing.ts` a conflict with the repository** — raised in `[P1A §6.14]`, not overruled here |
| 5 | ⛔ **A lint-rule conflict makes a JSDoc block on the NgModule unfixable.** `@stylistic/padding-line-between-statements` forbids the blank line `jsdoc/lines-before-block` requires; `ng lint --fix` reports **`ESLintCircularFixesWarning`** and leaves an error either way | Use **`/* … */` block comments, never `/** … */`, immediately above a decorator — and carry no doc block on the module class, matching `ot-signup.module.ts`. `multiline-comment-style` separately forbids consecutive `//` lines, so **block comments are the only form that passes** |
| 6 | ⚠ **The 95 % gate bites at scaffold time, not at feature time** (`F-08`). The first suite run failed at **36 % statements / 0 % functions** — `flat-wire-auth.guard.ts` matches `collectCoverageFrom`'s `*.guard.ts` and had no spec | Added `flat-wire-auth.guard.spec.ts`. **A guard stub is not free: it owes a spec the day it is written** |

### 6.3 Two deliberate departures from the plan's letter

1. **A placeholder component exists, and `[TB §7]`'s AC 4 is why.** The plan puts *"any control or screen"* out of scope, but AC 4 requires lazy routes that **resolve**, and `[CMP §5.2]`'s routes name screen components belonging to Phase-3+ stories. `FlatWirePlaceholderComponent` (`fw-flat-wire-placeholder`, `OnPush`, no styles) renders on all four routes. ⚠ **`FW-130` replaces it with the shell**; it is marked as such in its own header comment and in `FlatWireModule`.
2. **`FLAT_WIRE_ROUTES` carries four routes, not three.** `[TB §7]` names three; a `path: ''` default was added so `#/flat-wire` itself resolves. All four carry `FlatWireAuthGuard` and the `resolveData` / `ContentDataService` pair (`F-11`).

### 6.4 ⛔ The one thing that could not be verified, and it is not this story's fault

**`npm start` / a host `ng build` cannot run in this checkout.** The app build fails with `TS2307` on
`flexmonster` and `ngx-flexmonster`, `NG6002` on `CostLedgerModule` and `Can't resolve
node_modules/flexmonster/flexmonster.min.css`. Both belong to **`projects/reports/cost-ledger`** — the
only library in the repository that uses them.

⚠ **Corrected 28 Aug 2026 — the two packages are not in the same state**, and this record first said
they were: **`ngx-flexmonster` IS declared** (`^2.9.130`) and merely absent from `node_modules`, while
only the licensed core **`flexmonster` is undeclared** (it is the wrapper's peer dependency, which
npm 7+ resolves on its own). **That makes it an incomplete install rather than a missing dependency —
try `npm install` first.** Detail and the licence caveat in `[P1A §6.15]`.

✅ **Nothing in the failure touches flat wire** — the compiler analysed the wrapper modules and
flagged `CostLedgerModule` while raising nothing for `FlatWireModule`. The wiring was proved instead
by a **scoped `tsc --noEmit`** over `flat-wire-wrapper.module.ts` + `projects/flat-wire/src/**`:
**zero errors**, so the wrapper resolves `FlatWireModule` from the source path and the library
type-checks whole.

⚠ **So AC 4's runtime half — *"`#/flat-wire` resolves"* — is verified by compilation, not by a
browser.** Whoever installs the missing packages should re-run `npm start` and confirm it, along
with `phase-01a` exit criterion 1. **New finding `[P1A §6.15]`.**

⚠ **`build:base` is genuinely required first, and skipping it produced a misleading failure.**
`dist/shared` was stale from **23 Jul 2026** while `projects/shared` had changed on 27 Aug, so
`build:shop-floor` failed inside `shop-floor-common` on a `SharedApiService` method that exists in
source but not in the stale bundle. **It looked like flat wire had broken the chain and had nothing
to do with it.** After `npm run build:base` the chain is green.
