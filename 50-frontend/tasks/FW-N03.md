---
id: FW-N03
legacy_id:
title: Angular library scaffold, routing and configuration
status: in-progress
status_confirmed: true
status_note: "Built in the working tree and awaiting commit. `npm run build` exits 0 and emits `flat-wire.js` as a named lazy chunk, `ng lint` passes across all 32 targets, `npm run test:flat-wire` is 25 tests at 100 % on all four metrics. `HEAD` carries no `flat-wire`, so **wave 1 opens on the commit**"
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
**Last Updated:** September 4, 2026 — Change history is in [`../../CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** 🟡 **Built in the working tree, awaiting commit.** All three verification commands pass (§3); `HEAD` carries no `flat-wire`, so **wave 1 opens on the commit**
**Owner:** Frontend (Angular) stream
**Audience:** The Angular developer building `FW-N03`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Depends on:** **nothing** — the single root of Phase 1A
**Unblocks:** [`FW-130`](FW-130.md) · [`FW-131`](FW-131.md) · [`FW-132`](FW-132.md) · [`FW-135`](FW-135.md) — **four at once**
**Part of:** `ProjectPlan/Frontend/tasks/` — index: [Orchestration.md](Orchestration.md) · shared context: [Phase-01A-ImplementationPlan.md](Phase-01A-ImplementationPlan.md)

---

> **Read [`[P1A §2]`](Phase-01A-ImplementationPlan.md) first — the measured state of the checkout.**
> This plan does not restate it. The decisions it depends on are `[P1A §4]`'s `F-01`, `F-02`, `F-11`
> and `F-13`.
>
> **This is the root node of Phase 1A.** It is the only 1A story with no dependency, and **four
> others name it as theirs** (`FW-130`, `FW-131`, `FW-132`, `FW-135`). Nothing on the FE stream
> starts until it lands.
>
> **The reference is `projects/planning/` and nothing else** — the repository's other routing
> application. Copy its *shape*, never its content. ⛔ **Not `projects/ot-signup/`**, which is both a
> routing module **and** an injectable library: it carries a `tsconfig` path, a `dist` bundle and a
> jest alias because other libraries import from it. **Nothing imports `flat-wire`.**
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

### 1.1 In scope

| # | Deliverable |
|---|---|
| 1 | `projects/flat-wire/` generated and registered in `angular.json` |
| 2 | The **eight** integration points of §2 step 3 |
| 3 | The `planning`-shaped folder tree — §2 step 5 |
| 4 | `FlatWireModule` and `flat-wire-routing.module.ts` with the landing route |
| 5 | `flat-wire.component` — header · `router-outlet` · footer · spinner · toast |
| 6 | `flat-wire-landing.component` under `components/` |
| 7 | `src/assets/content-data/flat-wire.json` + the `FlatWireContent` type (`F-11`) |
| 8 | Config keys in `environment.js` and `local-config.json` (`F-02`) |

### 1.2 Out of scope — and who owns each

| Not here | Owner |
|---|---|
| The shell layout, canvas and styling of `flat-wire.component` | [`FW-130`](FW-130.md) |
| The role guard, interceptors, the error envelope | [`FW-131`](FW-131.md) |
| The API client and models | [`FW-132`](FW-132.md) |
| The SignalR service | [`FW-135`](FW-135.md) |
| Any control or screen beyond the landing component | `FW-133` / `FW-134` and the phase-3+ stories |

> **The parent route runs `AuthenticationGuard` from `shared`** — exactly as
> `planning-routing.module.ts` does, and as all eleven routing modules in the repository do.
> **No guard file is written in this library.** `FW-131` adds `FlatWireRoleGuard` beside it once a
> role source exists (`G6`, `[P1A §4]` `F-12`). ⚠ A guard stub would not be free: `collectCoverageFrom`
> globs `*.guard.ts` against a 95 % gate, so it owes a spec the day it is written (§6).

---

## 2. Build order

### Step 1 — generate

```bash
cd c:\UAL\Second-Branch\ual-angular       # F-01
ng generate library flat-wire
```

⚠ **No `--prefix`** — every one of the 31 projects uses `prefix: lib`, and the schematic supplies it.
⚠ **No `--standalone=false`** either: the schematic emits a standalone entry point, which step 2
**deletes**. The NgModule is written by hand on `planning.module.ts`'s shape (step 6), so there is
nothing to convert.

### Step 2 — clean up after the schematic

| # | What |
|---|---|
| 1 | **Revert `angular.json` and insert the project entry by hand**, in the house style, alphabetically between `customer-search` and `furnace-scheduling` — the schematic reformats the whole file (§6 trap 1) |
| 2 | Replace all three tsconfigs with the house shape — `types: ["jest","node"]`, `module: CommonJs`, extending `../../tsconfig.spec.json` (§6 trap 3) |
| 3 | Rewrite `eslint.config.mjs` to `planning`'s shape |
| 4 | **Delete `src/lib/flat-wire.ts` and its spec** — the standalone entry point. Step 7 replaces them |
| 5 | **Write `jest.config.js`** — the schematic does not generate one, and `test:flat-wire` needs it |

**The `angular.json` entry matches `planning`'s exactly:** builder
`@angular-devkit/build-angular:ng-packagr`, `options.project` and `options.tsConfig`, a `production`
configuration and a lint target. ⛔ **No karma `test` target** — this repository is Jest — and **no
`development` build configuration**; no other project has either.

### Step 3 — the integration points: **eight**

| # | Point |
|---|---|
| 1 | `angular.json` — project entry, ng-packagr builder, lint target |
| 2 | `package.json` — a `test:flat-wire` script |
| 3 | `src/app/routes.ts` — a top-level `path: 'flat-wire'` `loadChildren` entry with the `webpackChunkName` comment, in `planning`'s form. ⚠ **Append it — the file is not alphabetical** (it groups the `shop-floor/*` children, then top-level modules in insertion order) |
| 4 | `src/app/project-routes/flat-wire-wrapper.module.ts` — `@NgModule({ imports: [FlatWireModule] })`, importing from the **source** path exactly as `planning-wrapper.module.ts` does |
| 5 | `src/assets/content-data/flat-wire.json` |
| 6 | `src/types/content-data/index.d.ts` — the import plus `export type FlatWireContent = typeof flatWireJson;` |
| 7 | `environment.js` — `flatWireApiUrl: 'FlatWire/api/v1/'` · `flatWireHubUrl: 'FlatWire/hubs/flat-wire'` · `useMockData: false` |
| 8 | `src/assets/local-config.json` — the same three keys, **`useMockData: true`** |

⛔ **Three things a library like this does *not* get**, because they exist to publish a library that
other code imports — and nothing imports `flat-wire`:

| Not done | Why |
|---|---|
| a `tsconfig.json` path | A path resolves `import { X } from '<lib>'` against `dist/<lib>`. The wrapper imports from source. **`planning` has none** |
| a `jest.base.config.js` alias | Same reason — there is no bundle and no package-name import to resolve. **`planning` is not in `moduleNameMapper`** |
| an entry in the app `styles` array | **No new styles are created.** Flat wire uses the existing application styles — Bootstrap 5.3.8, `src/styles/styles.scss` and its `_colors.scss` variables, `shared`'s components — and a new style or class is written **only when a requirement calls for one**. ⚠ The mechanism remains: `planning-styles.scss` is one of four library sheets already in that array, so a later requirement follows it |

⛔ **`flat-wire` joins no build chain** — not `build:base`, not `build:shop-floor`, not
`build:coil-receiving`. With no consumer there is no bundle to order, and the app build compiles the
library from source. **`planning` is in no chain either.**

### Step 4 — the library's own files, on `planning`'s shape

`package.json` · `ng-package.json` · `tsconfig.lib.json` · `tsconfig.lib.prod.json` ·
`tsconfig.spec.json` · `eslint.config.mjs` · `jest.config.js`.

**`jest.config.js` follows `planning/jest.config.js`:** spread `../../jest.base.config`,
`coverageDirectory: '<rootDir>/coverage/flat-wire'`, the repo's **95 %** thresholds (`F-08`),
`displayName`, `rootDir: '../..'`, `roots: ['<rootDir>/projects/flat-wire/src']`, and the
`jest-preset-angular` transform pointing at `projects/flat-wire/tsconfig.spec.json`.

### Step 5 — the folder tree

```
projects/flat-wire/src/
├── lib/
│   ├── components/
│   │   └── flat-wire-landing/   flat-wire-landing.component.{ts,html,spec.ts}
│   ├── constants/               api-methods.constants.ts · flat-wire.constants.ts
│   ├── enums/
│   ├── interfaces/
│   ├── models/
│   ├── services/
│   ├── flat-wire.component.{ts,html,spec.ts}
│   ├── flat-wire.module.ts
│   └── flat-wire-routing.module.ts
└── public-api.ts
```

**This mirrors `projects/planning/src/lib/`**, minus its two project-specific folders.
`public-api.ts` exports the component and the module and nothing else, as `planning`'s does.

⛔ **No `.scss` on either component, and no `styleUrls`.** `planning.component.scss`'s
`:host { height: 100%; width: 100% }` exists because **golden-layout** requires a sized host element;
flat wire has no golden-layout and needs no such rule.

⚠ **`enums/`, `interfaces/`, `models/` and `services/` are not created empty.** Git does not track
empty directories and **this repository uses no `.gitkeep`**, so each appears with its first file.

⚠ **`flat-wire-routing.module.ts`, not `flat-wire-routing.ts`** — the repository has five
`*-routing.module.ts` files and no counter-example. `[CMP §5.1]` names the other form; the conflict
is `[P1A §6.14]`.

### Step 6 — `FlatWireModule`

On `planning.module.ts`'s shape:

```typescript
@NgModule({
  declarations: [FlatWireComponent, FlatWireLandingComponent],
  imports: [CommonModule, FlatWireRoutingModule, SharedModule.forRoot(),
            FormsModule, ReactiveFormsModule, NgbModule]
})
export class FlatWireModule {}
```

⚠ **`SharedModule.forRoot()` is load-bearing and is easy to read as boilerplate.** It provides this
module's own `HttpClient` (via `provideHttpClient(withInterceptorsFromDi())` in `SharedModule`'s own
`providers`) **and** the three `HTTP_INTERCEPTORS` into the same injector — which is what wires token,
correlation-id and error interception for the whole library. `planning` imports it the same way.
`FW-131` verifies it; **this story must not omit it.**

### Step 7 — the two components

**`flat-wire.component` is the routed shell**, and its template is `planning.component.html` minus
the hamburger toggle:

```html
<div class="container-fluid"><lib-header [serverName]="serverName" /></div>
<router-outlet />
<lib-footer />
<lib-global-spinner />
<lib-toast aria-atomic="true" aria-live="polite" />
```

✅ **Nothing here is built.** All four `lib-*` components are declared **and exported** by
`SharedModule` — `projects/shared/src/lib/components/{header,footer,global-spinner,toast}/` — so
`SharedModule.forRoot()` in step 6 is what makes the template compile.

**`serverName` is built in the constructor, as `PlanningComponent` does it:**

```typescript
this.serverName = {
  url: this.appConfigService.getEndpoint().flatWireApiUrl,
  suffix: FLAT_WIRE_API_METHODS.GET_SERVER_INFO_FLAT_WIRE
};
```

✅ **The suffix is the same call in every application — only the controller segment changes.**
Measured across nine libraries: `Planning/GetServerConnectionInfo` ·
`CoilReceiving/GetServerConnectionInfo` · `Scheduling/GetServerConnectionInfo` ·
`SlitterInterface/GetServerConnectionInfo` · `ManpowerScheduling/GetServerConnectionInfo` ·
`Login/GetServerConnectionInfo`. Flat wire's is **`'FlatWire/GetServerConnectionInfo'`**, declared as
`GET_SERVER_INFO_FLAT_WIRE` in `constants/api-methods.constants.ts`. ⚠ **It is the only endpoint this
story calls**, and it is not `[API]`'s to define — every service already exposes it. `ServerName`
(`url` + `suffix`) is exported from `shared`.

**`flat-wire-landing.component`** sits under `components/flat-wire-landing/`: `standalone: false`,
`OnPush`, no stylesheet, content data read through `AppConfigService.getContentData()` per `F-11`.
⚠ **It is no longer the stub this step created** — it is now **DB3, the Active Run Monitor**
(`FW-062`), so **`FW-204` no longer has a stub to replace**; see that story.

### Step 8 — routing

`flat-wire-routing.module.ts`, on `planning-routing.module.ts`'s shape — **no exported constant:**

```typescript
const routes: Routes = [
  {
    path: '',
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'flat-wire-landing' },
      { path: 'flat-wire-landing', component: FlatWireLandingComponent }
    ],
    component: FlatWireComponent,
    canActivate: [AuthenticationGuard],
    data: { resolveData: ['flat-wire', 'shared'] },
    resolve: { contentData: ContentDataService }
  }
];
@NgModule({ imports: [RouterModule.forChild(routes)], exports: [RouterModule] })
export class FlatWireRoutingModule {}
```

**The route is still lazy** — the host lazy-loads the *wrapper module* (step 3 point 3).

⚠ **The empty-path child is the default load.** `slitter-interface` needs none because the
shop-floor menu navigates to `shop-floor/slitter/traveler`; **nothing navigates to flat wire**, so
without the redirect `#/flat-wire` renders the shell with an empty outlet.
`login-routing.module.ts` is the in-repo precedent for a child redirect.

⚠ **`[CMP §5.2]`'s per-line routes are not wired here.** They name screen components owned by
Phase-3+ stories; each arrives with its own.
⚠ **The run events are dialogs, not routes** — do not add `run/weld | spc | rolladjust | diechange |
checkout`.
⚠ **No MVP-2 routes** — `/passschedule`, `/shift`, `/dies` are not built.
⚠ Under `HashLocationStrategy` the base resolves as **`#/flat-wire`** (`F-09`).

### Step 9 — configuration and logging

Three keys per `F-02`, read through `AppConfigService.getEndpoint()`, in **both** files:

| Key | Value |
|---|---|
| `flatWireApiUrl` | `FlatWire/api/v1/` — the repository's `<Service>/api/v1/` shape, which `serverName`'s suffix pairs with |
| `flatWireHubUrl` | `FlatWire/hubs/flat-wire` — with `prefix` of `http://<host>/API.` and `FW-080`'s `PATH_BASE` of `/API.FlatWire`, this resolves to `/API.FlatWire/hubs/flat-wire` |
| `useMockData` | `false` in `environment.js`, **`true`** in `local-config.json` |

⚠ **The `// to be removed once live data is available` comment goes in `environment.js` only** —
that file is JavaScript. **`src/assets/local-config.json` cannot carry a comment**: it is strict
JSON, imported through `resolveJsonModule`, and it is also the source of the `AppConfig` type.

**Nothing to build for error telemetry** — `SharedModule.forRoot()` already registers
`GlobalErrorHandler`, which uses `UILogService` internally (`F-06`). Deliberate log calls need one
additive export in `projects/shared/src/public-api.ts`; **take that only if you have a call to
make.**

### Step 10 — the repository's own instruction files

**Three files tell a developer and an agent how this monorepo is built, and none of them knew about
`flat-wire`.** They are not integration points — they do not make the library exist — but leaving
them stale is what produces the wrong wiring on the next attempt.

| File | What it gains |
|---|---|
| `CLAUDE.md` | A **Library Kinds** section under *Key Architecture Patterns*: **routing application vs injectable library**, and which of `tsconfig` path · `dist` bundle · jest alias · `build:*` chain entry each gets. `flat-wire` is named as a routing application, with its prefix, file-local routes, `AuthenticationGuard` and absent stylesheet |
| `.claude/project-context.md` | `flat-wire` in the `projects/` tree, each entry labelled `(routing app)` / `(injectable)` / `(BOTH)` |
| `.github/copilot-instructions.md` | The same tree — it is byte-identical to the one above, so both move together or they disagree |

⚠ **`ot-signup` and `print-traveler` are *both* kinds**, so neither is a safe reference for a routing
application — that is the mistake this section exists to stop.

---

## 3. Verification

**Three commands, and no others.**

```bash
npm run build                 # app build; compiles flat-wire from source via the wrapper
ng lint flat-wire
npm run test:flat-wire
```

✅ **The git hooks need nothing.** `.husky/pre-push` greps every `"test:*"` script out of
`package.json` and strips the `--config` value down to a project path — with `test:flat-wire`
present that yields `projects/flat-wire`, so this library's suite runs on any commit touching it.
`.husky/pre-commit` runs bare `ng lint` (every project) plus glob-based `lint-staged`, and
`commit-msg` is a generic `UADEV-#####` regex. **No hook enumerates projects**, so step 3 point 2 is
the only thing that wires them.

⚠ **There is no `ng build flat-wire`** — the library has no bundle to produce. `npm run build` is
what proves it compiles, because it runs `build:base` → the chains → `ng build`, and the app build
pulls `FlatWireModule` in through the wrapper's source import. ⚠ **`build:base` first is not
optional**: a stale `dist/shared` fails inside `shop-floor-common` and reads like flat wire breaking
the chain.

| AC | Proof |
|---|---|
| 1 · generated and registered | `npm run build` compiles the library through the wrapper; the `angular.json` entry matches the other 30 |
| 3 · folder structure | step 5's tree exists; `public-api.ts` exports the component and the module |
| 4 · lazy route under `/flat-wire` | `#/flat-wire/flat-wire-landing` resolves through the wrapper and logs its resolved `contentData` |
| 5 · config carries the three keys | `AppConfigService.getEndpoint().useMockData` is `true` under `ng serve` |
| 6 · builds and lints clean | the three commands above |

**Current result:** `npm run build` exits 0 and emits **`flat-wire.js` as a named lazy chunk**, which
is what proves the route → wrapper → module wiring; `ng lint` reports *All files pass linting* for
all 32 targets; `npm run test:flat-wire` is **25 tests across 6 suites at 100 %** statements /
branches / functions / lines. ⚠ **The scaffold now carries two real screens** — DB3 (`FW-062`) and
DB1 (`FW-060`) — so the figures above cover far more than the scaffold itself.

**Test cases:** ⛔ **None.** Phase 1A has **no test cases in `[TCS]`** — against its **405 defined
cases** (the ids run to `TC-799`, but 47 are cited and never defined), nothing covers the Angular
library, the shell, the canvas, the guards or the mock hub. This story's verification is this plan
plus Jest, and nothing else. → `[TCS]`, `[P1A §6.13]`

---

## 4. Blockers and open items

**None block this story.** For completeness:

| Item | Effect |
|---|---|
| `F-01` — the checkout differs from `phase-01a` / `[ARC §2.1]` | raised for `[ARC]`; does not stop work |
| `F-09` — the route base and machine context | ⚠ **decide before `FW-132`**, because `line-context.service` is where `CURRENT_MACHINE` would be set |
| ⛔ **the hub path** | `flatWireHubUrl` is `FlatWire/hubs/flat-wire`, but [`FW-080`](../../40-backend/tasks/FW-080.md) maps the hub at `/hubs/flatwire` and owes the re-map, with [`FW-145 §3.5`](../../40-backend/tasks/FW-145.md)'s `?access_token=` handler beside it. **Blocks `FW-135`, not this story** — `FW-080 §0` |

---

## 5. Handoff

**Landing this unblocks four stories at once** — `FW-130`, `FW-131`, `FW-132` and `FW-135`
(`[Orchestration §2]`, wave 1). Tell those four developers three things:

1. **`SharedModule.forRoot()` is already imported** — do not add interceptors, and do not import it again in a child module.
2. **There is still no stylesheet in this library** — no `styles` array slot, no `lib/styles/` folder, and not even a component `.scss`; there is no global sheet to register and no bundle to rebuild. ⚠ **The screens built since did not need one** — five classes were added to the **application's** `src/styles/` instead, which is the sanctioned route ([`[UIC §2]`](../UIConventions.md)). Do not add a library stylesheet.
3. **The parent route already runs `AuthenticationGuard` from `shared`.** `FW-131` adds the role guard **beside** it once `G6` has a role source.

---

## 6. Traps this repository sets for a new library

**Measured, and every one of them costs an hour or more to rediscover.** They apply to the next
library scaffold as much as to this one.

| # | Trap | What to do |
|---|---|---|
| 1 | ⛔ **The library schematic reformats the whole of `angular.json`** — every inline object expanded, a **~1,200-line diff** against a repo whose prettier config is `objectWrap: collapse`, `printWidth: 120` | **`git checkout -- angular.json`, then insert the project entry by hand** in the house style, alphabetically. The entry is ~21 lines |
| 2 | ⚠ **It generates `eslint.config.mjs` but not `jest.config.js`** | Keep the first, rewritten to the house shape; write the second by hand from `planning`'s |
| 3 | ⛔ **The schematic's tsconfigs are wrong for this repo.** `tsconfig.spec.json` types **`jasmine`** and extends the root `tsconfig.json` — in a **Jest** repository | Replace all three with the house shape: `types: ["jest","node"]`, `module: CommonJs`, extends `../../tsconfig.spec.json`. Otherwise the spec config does not type Jest globals |
| 4 | ⚠ **It emits Angular-20 default filenames** — `flat-wire-module.ts`, `flat-wire.ts`. House convention is **36 × `*.module.ts`**, **313 × `*.component.ts`**, **5 × `*-routing.module.ts`** | Rename to `*.module.ts` / `*-routing.module.ts` / `*.component.ts` |
| 5 | ⛔ **A lint-rule conflict makes a JSDoc block on an NgModule unfixable.** `@stylistic/padding-line-between-statements` forbids the blank line `jsdoc/lines-before-block` requires; `ng lint --fix` reports **`ESLintCircularFixesWarning`** and leaves an error either way | Use **`/* … */` block comments, never `/** … */`, immediately above a decorator, and carry no doc block on the module class — as `planning.module.ts` does. `multiline-comment-style` separately forbids consecutive `//` lines, so **block comments are the only form that passes** |
| 6 | ⚠ **The 95 % coverage gate bites at scaffold time, not at feature time** (`F-08`). `collectCoverageFrom` globs `*.guard.ts`, `*.service.ts`, `*.model.ts` and `*.component.ts` across the whole library | **Every file matching those globs owes a spec the day it is written** — one uncovered stub drops the suite below the threshold and fails the run |
