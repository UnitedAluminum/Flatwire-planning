# Phase 1A — Shared Context, Decisions and Plan Index (Frontend)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 1, 2026
**Document Type:** Phase-level foundation for nine story plans — the measured checkout, the `F-##` decisions, the findings, and the index of the nine
**Status:** Active — 🟡 **wave 0 is built and awaiting commit** ([`FW-N03`](FW-N03.md)); `FW-130`, `FW-131`, `FW-132` and `FW-135` unlock when it lands
**Owner:** Frontend (Angular) stream
**Audience:** The Angular developer building Phase 1A, and the delivery lead sequencing it
**Shortcode:** **`[P1A]`** — *declared here because the nine story plans cite it as `[P1A §n]`. It is a **folder-local** convention, not one of the repository's document shortcodes, and it is **not citable as a requirement**: this file is derived from the specifications and loses to all of them*
**Part of:** `ProjectPlan/Frontend/tasks/` — folder index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Phase 1A's requirements are spread across
> [`phase-01a`](../../60-delivery/phases/phase-01a-angular-foundation.md), [`[CMP]`](../Components.md),
> [`[SCR]`](../ScreenPlan.md), [`[VAL]`](../ValidationRules.md) and `[TB §7]`, and they are consistent
> with each other. They are **not** consistent with the Angular repository. Seven instructions cannot be
> followed as written and one story cannot be built at all — not because a specification is careless, but
> because none of them was written with the checkout open.
>
> This is the build order. It is **derived from the specifications and loses to every one of them** —
> where this document and a specification disagree, the specification wins and this document is
> corrected up to it. Where the repository and a specification disagree, this document **raises** it
> (§6) and does not overrule it.
>
> **It holds no component design and no pixel decisions.** Those are `[CMP]`'s and the mockups'.
> **It restates no hour figure** — `[TB §7]` owns those.
>
> ### ⚠ This file no longer carries the build steps — read §3 first
>
> **On 27 Aug 2026 this plan was divided into nine per-story plans**, one per Phase-1A story, each
> with its own build order, verification and blockers. §3 is the index. **What stayed here is what is
> shared**: the measured checkout (§2), the eight integration points (§2.1), the `F-01`–`F-15`
> decisions (§4), the phase-level exit criteria (§5) and the twelve findings (§6).
>
> **The division was by story, not by subject** — so a developer opens one file, and the facts nine
> files would otherwise each restate live in exactly one place. That is deliberate: the repository has
> already paid for the alternative once, in six contradictory copies of the PLC tag surface.

---

## 1. Scope and precedence

**Nine stories**, the `FE 224 h` + `RT 44 h` of `[TB §7]`'s Phase 1A block:

`FW-N03` · `FW-130` · `FW-131` · `FW-132` · `FW-133` · `FW-134` — **FE**
`FW-135` · `FW-136` · `FW-137` — **RT, and all three are `ual-angular` code**

**Each has its own plan — see §3 for the index.**

**Out of this plan:** `FW-204` (minimal landing route) and `FW-214` (simulator console `DB-S1` — **a standalone WinForms tool since `D-33`, so it does not touch this Angular plan at all**) are **trial scope, additive to `[CE §3b]`**; the 38 downstream FE stories of Phases 3–14; and everything MVP-2.

**Precedence, highest first:**

1. [`phase-01a`](../../60-delivery/phases/phase-01a-angular-foundation.md) — the layer spec
2. [`[CMP]`](../Components.md) · [`[SCR]`](../ScreenPlan.md) · [`[VAL]`](../ValidationRules.md) · [`[SIG]`](../../Architecture/SignalR.md) · [`[SEC]`](../../Architecture/Security.md) · [`[API]`](../../Backend/APIs.md) · [`[ARC]`](../../Architecture/Architecture.md)
3. `[TB §7]`'s acceptance criteria — the contract per story
4. **This document**

**Dependency waves are [`Orchestration.md §2`](Orchestration.md)'s** and are not restated here. The
short form: `FW-N03` is the single root; `FW-130`/`131`/`132`/`135` unlock together; `FW-133`/`134`/`136`/`137`
follow. The critical path is `FW-N03 → FW-130 → FW-133`.

---

## 2. The target checkout, as measured 27 Aug 2026

Target: **`c:\UAL\Second-Branch\ual-angular`, branch `feature/flat-wire`** — see `F-01`.

⚠ **Every row below was read from the repository, not inferred from a document.** Where a row
contradicts a specification it is flagged, and the contradiction is filed in §6.

| | Measured |
|---|---|
| **Angular · TypeScript · Jest** | **20.3.12** · 5.9.3 · Jest 30 + `jest-preset-angular` 15 · `ng-packagr` 20 — ⚠ the ecosystem docs say Angular 18.2.7 (§6.4) |
| **`projects/`** | **31 committed `angular.json` entries — 30 libraries + the host app `united-aluminum`, and no `flat-wire`.** ⚠ The **working tree** holds a 32nd entry and `projects/flat-wire/`, both **uncommitted** — this row counts what has landed |
| **Components** | NgModule-based; **`standalone: false`** written explicitly on every `@Component` |
| **Routing** | `HashLocationStrategy` (so `/flat-wire` resolves as `#/flat-wire`); host `src/app/routes.ts` lazy-loads one **wrapper module** per library from `src/app/project-routes/`, each of which imports the library module from its **source** path |
| **Configuration** | `environment.js` (a Node script) writes `src/assets/config.json`; `src/environments/` holds only `environment.ts` and `environment.prod.ts`, carrying nothing but `production`. `AppConfig` = `typeof src/assets/local-config.json`. Read through `AppConfigService.getEndpoint()` — ⚠ **there is no `environment.development.ts`** (`F-02`) |
| **Build configurations** | `defaultConfiguration: production`, whose `fileReplacements` swaps `environment.ts` → `environment.prod.ts`. So **every `npm run build:*` reads `config.json`** and **`ng serve` reads `local-config.json`**, which the production asset list deliberately does not deploy |
| **`SharedModule`** | `@NgModule.providers` carries `provideHttpClient(withInterceptorsFromDi())`, `UILogService`, `CorrelationIdService`, `SubscriptionService`. `forRoot()` adds the services, **both guards** and the **three `HTTP_INTERCEPTORS`** (token · correlation-id · error) plus `{provide: ErrorHandler, useClass: GlobalErrorHandler}` |
| **Envelope in `shared`** | `HTTPResponse<T>` = `{data?, success?, errorCode?, errorDescription?}` — **no `errors[]`** (`F-04`) |
| **`ApiGatewayService`** | **`get` and `post` only** — sufficient for all of MVP-1 (`F-05`) |
| **Authorization primitive** | per-module **ACCESS / WRITE** (`UserPermissionModel`, `USER_PERMISSIONS`). ⛔ **No role vocabulary, no role field on the login response, no JWT decoder anywhere** (§6.1) |
| **Already present** | `@microsoft/signalr` 9.0.6 · `chart.js` 4.5.1 with `annotation`/`zoom`/`datalabels` · `ngx-touch-keyboard` and `shared`'s `KeypadComponent` · `@ng-bootstrap/ng-bootstrap` 19 · `jest-canvas-mock` |
| **Absent** | ⛔ `@microsoft/signalr-protocol-msgpack` (`G10`) · ⛔ `@angular/service-worker` (`FW-137`) |
| **Style lint** | `npm run lint:styles` globs `projects/**/*.scss`; rules include **`color-no-hex: true`** and `color-named: 'never'`. **Zero `.scss` under `projects/` contains a hex colour**; `src/styles/_colors.scss` carries a blanket `/* stylelint-disable */`. `em` units are disallowed and the token stylesheet uses **none** (`F-03`) |
| **Code conventions (lint-enforced)** | `jsdoc/require-jsdoc: error` on every function and method · `strict` · `strictTemplates` · `noUnusedLocals` · `noUnusedParameters` · `inject()` over constructor injection · the custom `max-params-no-constructor` rule |
| **Build budgets** | `anyComponentStyle` **10 kB error / 5 kB warning** — a component `.scss` past 10 kB **fails the production build**. `initial` is 2 MB, which flat wire does not touch: it is lazy |
| **Test gate** | root `jest.config.js` globs `projects/**/jest.config.js`, so a new library's config is picked up automatically. Every library sets **95 %** on statements, branches, functions and lines. `collectCoverageFrom` globs `*.component.ts`, `*.service.ts`, `*.guard.ts`, `*.pipe.ts`, `*.directive.ts`, `*.model.ts`, `*.utils.ts` (`F-08`) |
| **Global CSS the shell must survive** | `src/styles/styles.scss` sets `body { font-family: Verdana; font-size: 12px !important }` and `html, body { text-align: center }`, and Bootstrap 5.3.8's reboot is global |

### 2.1 The eight integration points

A new library is not done when it compiles. These are the files that make it *exist* in this
monorepo, each with the library to copy the shape from.

⚠ **`flat-wire` is a routing application, not an injectable library** — nothing imports it by
package name and it publishes no bundle, so three integration points an injectable library needs do
not apply here. **The precedent for every row is `planning`**, measured; `ot-signup` is not, because
it is both a routing module and an injectable library.

| # | File | What goes in | Precedent |
|---|---|---|---|
| 1 | `angular.json` | project entry, `projectType: library`, ng-packagr builder + lint target. ⚠ **No karma `test` target** — this repository is Jest | `planning` |
| 2 | `package.json` | a `test:flat-wire` script. ⚠ **Not appended to `build:shop-floor`** — row 2 of the struck table | `planning` |
| 3 | `src/app/routes.ts` | the lazy route loading the wrapper module. ⚠ **Append it — the file is not alphabetical** | `planning` |
| 4 | `src/app/project-routes/flat-wire-wrapper.module.ts` | `@NgModule({ imports: [FlatWireModule] })`, importing from `projects/flat-wire/src/lib/flat-wire.module` — the **source** path | `planning-wrapper.module.ts` |
| 5 | `src/assets/content-data/flat-wire.json` | the shell's user-facing strings (`F-11`) | `planning.json` |
| 6 | `src/types/content-data/index.d.ts` | `export type FlatWireContent = typeof flatWireJson;` | every library |
| 7 | `environment.js` | `flatWireApiUrl: 'FlatWire/api/v1/'` · `flatWireHubUrl: 'FlatWire/hubs/flat-wire'` · `useMockData: false`. ⚠ The `// to be removed once live data is available` comment goes **here** — this file is JavaScript | the `config` object |
| 8 | `src/assets/local-config.json` | the same three keys with **`useMockData: true`**. ⚠ **Strict JSON — it cannot carry that comment**, and it is also the `AppConfig` *type* | — |

#### ⛔ What a routing application does not get

| Not done | Why |
|---|---|
| a `tsconfig.json` path | A path exists so other code can `import { X } from '<lib>'` against `dist/<lib>`. **Nothing imports `flat-wire`**; the wrapper imports it from source. **Measured: `planning` has no path** |
| a `build:shop-floor` chain entry | With no consumer there is no bundle to order. **Measured: `planning` is in no chain** — not `build:base`, not `build:shop-floor`, not `build:coil-receiving`; the app build compiles it from source |
| a `jest.base.config.js` alias | The alias resolves a package-name import to a bundle. There is neither. **Measured: `planning` is not in `moduleNameMapper`** |
| an app `styles` array entry | **No new styles are created** — the existing application styles are used, and a new style or class is written only when a requirement calls for one. ⚠ The mechanism and precedent remain: `planning-styles.scss` is one of four library sheets already in that array, so a later requirement follows it. → `F-03`, withdrawn |

> **Two things that are deliberately *not* in the eight**, because neither makes the library exist:
>
> - ✅ **The git hooks need nothing.** `.husky/pre-push` derives each project path from the
>   `"test:*"` scripts in `package.json`, so point 2 is what makes it run this library's suite;
>   `pre-commit` lints every project and `commit-msg` is a generic regex. **No hook enumerates
>   projects.**
> - ⚠ **The repository's instruction files do need updating** — `CLAUDE.md`,
>   `.claude/project-context.md` and `.github/copilot-instructions.md`, which must state the
>   **routing-application vs injectable-library** distinction and name `flat-wire` as the former.
>   [`FW-N03` step 10](FW-N03.md) owns it.

---

## 3. The nine plans

**The build steps moved out of this file on 27 Aug 2026.** Each story now has its own plan, and each
one carries its verbatim `[TB §7]` card, its own build order, its own verification and its own
blockers. **This file keeps what is genuinely shared** — the measured checkout (§2), the `F-##`
decisions (§4), the phase-level verification (§5) and the findings (§6) — because copying those nine
times is how a repository ends up with six contradictory copies of one fact.

| Wave | Story | Plan | h | State |
|---|---|---|---|---|
| **0** | `FW-N03` · library scaffold, routing, configuration | [FW-N03.md](FW-N03.md) | 24 | 🟡 **Built, awaiting commit** — all three verification commands pass |
| **1** | `FW-130` · shell layout and the 1920 × 1080 canvas | [FW-130.md](FW-130.md) | 16 | ✅ buildable · 🔴 on the critical path |
| **1** | `FW-131` · guards, interceptors, error envelope | [FW-131.md](FW-131.md) | 12 | ⛔ **role half blocked** on `F-12` |
| **1** | `FW-132` · API client and domain models | [FW-132.md](FW-132.md) | 20 | ⚠ bakes in `G14`'s two undecided halves |
| **1** | `FW-135` · SignalR client service | [FW-135.md](FW-135.md) | 24 | ⚠ needs the MessagePack package (`G10`) |
| **2** | **`FW-133`** · six shared composite controls | [FW-133.md](FW-133.md) | **120** | 🔴 **the critical path** — 45 % of the layer |
| **2** | `FW-134` · shared primitives and `alert-banner` | [FW-134.md](FW-134.md) | 32 | ✅ buildable |
| **2** | `FW-136` · `MockSignalRService` | [FW-136.md](FW-136.md) | 12 | ⛔ **its `[TB §7]` criteria list 9 of 14 events** |
| **2** | `FW-137` · PWA cache sync and reconnect banner | [FW-137.md](FW-137.md) | 8 | ⛔ `@angular/service-worker` absent |

*Hours are `[TB §7]`'s, quoted for navigation. This file restates no total.*

### 3.1 What each plan owns, and what it does not

**A story plan owns its build order and its verification.** It does **not** own:

| | Home |
|---|---|
| the measured state of the checkout | **§2 of this file** |
| the eight integration points a new library must touch | **§2.1 of this file** — `FW-N03` executes them |
| every `F-##` decision | **§4 of this file** |
| the findings raised against other documents | **§6 of this file** |
| dependency waves, the blocker calendar, the critical path | [`Orchestration.md`](Orchestration.md) |
| component design, pixels, screen inventory | `[CMP]`, the mockups, `[SCR]` |

⚠ **If you are about to restate one of those inside a story plan, don't.** Cite it. That rule is the
reason this file still exists after the split.

### 3.2 The critical path, unchanged by the split

```
FW-N03 (24) → FW-130 (16) → FW-133 (120)
                                  45 % of the layer; every screen depends on it
```

**160 h**, against the 60 h of the longest RT chain (`FW-N03 → FW-135 → FW-136`). **Nothing on the
path is blocked**, and `FW-133` is **not trimmable but is divisible** — its six controls are
independent of one another and share only `FW-130`'s tokens, which is where a second developer goes.
Detail in that story's plan §2.

> *The 160 h is derived here for sequencing only. It re-states no published total and changes no figure
> in `[CE]`, `[DE]`, `[SSP]`, `[TRP]` or `[TB §7]`.*

---

## 4. Decisions — the `F-##` series

⚠ **This series is new, and it is deliberately not `P-##`.** That series belongs to
[`Backend/tasks/`](../../40-backend/tasks/Orchestration.md) and is continuous
across that folder; a second series there would collide in citation.
**`F-##` is scoped to `Frontend/tasks/`.**

| id | Decision |
|---|---|
| **`F-01`** | **Target checkout is `c:\UAL\Second-Branch\ual-angular` @ `feature/flat-wire`.** `phase-01a` and `[ARC §2.1]` name `c:\UAL\ual-angular`. ⚠ **This plan does not supersede a specification** — the conflict is raised for `[ARC]` to settle |
| **`F-02`** | **`useMockData`, `flatWireApiUrl` and `flatWireHubUrl` are config keys, not `environment.*.ts` constants.** The file `phase-01a` names — `environment.development.ts` — does not exist. The repo's own mechanism gives the spec's exact semantics: `useMockData: true` in **`src/assets/local-config.json`** (read only by `ng serve`, never deployed), `useMockData: false` plus the two URLs in **`environment.js`** (→ `config.json`, read by every built environment). ⚠ **Both files must carry every key** — `AppConfig` is `typeof local-config.json`, so that file is also the type, and a key in only one of them makes the type and the runtime value diverge. ✅ **Values set 1 Sep 2026:** `flatWireApiUrl: 'FlatWire/api/v1/'` — correct, because `prefix` is `http://<host>/API.` and `FW-080`'s `PATH_BASE` is `/API.FlatWire`. ✅ **`flatWireHubUrl: 'FlatWire/hubs/flat-wire'`** — the hyphen was adopted across all layers on 1 Sep 2026 (`[API §1]`, `[SIG §4]`, `[ARC]`, `[DEP]`, `phase-01b`, the master specification and four backend plans — 22 occurrences). ⛔ **`FW-080` is built on the old path and owes the re-map**, with `FW-145 §3.5`'s `?access_token=` handler beside it; `FW-135` cannot connect until then — [`FW-N03 §8·1`](FW-N03.md) |
| **`F-04`** | **The library defines its own `FlatWireResponse<T>`** — `data · success · errorCode · errorDescription · errors[] · errorContext` per `[API §1.2]`. `shared`'s `HTTPResponse<T>` has no `errors[]` and is neither extended nor reused |
| **`F-05`** | **No MVP-1 gap from `ApiGatewayService`'s `get`/`post`-only surface.** The contract's only `PUT` and `PATCH` are `PUT /passschedule/{id}` and `PATCH /passschedule/{id}/status` — **both Phase 2, both MVP-2** — so `get`/`post` covers all **27** MVP-1 endpoints. ⚠ **27, not 25** *(corrected 28 Aug 2026)*: `[API §3.2]`'s heading says *"32 endpoints, of which MVP-1 implements 25"* while that document's own header records the index as **two rows short** — `§4.20`/`§4.21`, added 22 Aug and never indexed — making the surface **34/27** (`P-53`, `P-54`). ✅ **The decision is unaffected and is in fact firmer**: both missing rows are `GET /rod/{alpha}/orders` and `POST /order/{orderNo}/complete`, so a larger surface is still entirely GET/POST. Recorded because it becomes a gap the day pass-schedule authoring returns |
| **`F-06`** | **`UILogService` is provided by `SharedModule` but not exported from `shared`'s public API.** Error telemetry is therefore **already wired** — `forRoot()` registers `GlobalErrorHandler`, which uses it. Deliberate log calls need one additive export line in `projects/shared/src/public-api.ts`; take that **only if 1A needs explicit logging**, and never re-implement the service |
| **`F-07`** | **Class guards in `canActivate: [...]`**, not functional guards — matching all eleven existing routing modules |
| **`F-08`** | **The library's `jest.config.js` keeps the repo's 95 % thresholds.** `phase-01a`'s *"smoke tests"* is the floor, not the gate — and the root config picks the library up automatically, so there is no opt-out short of shipping no config at all. ⚠ The cost is wider than the component stories: `collectCoverageFrom` globs `*.model.ts` and `*.service.ts` too, so **`FW-132`'s mock service and its eight models carry the same obligation** as `FW-133`/`FW-134`'s controls. Flagged as effort risk against `[TB §7]`'s hours, which this plan does not restate |
| **`F-09`** | **Route base stays `/flat-wire`** per `[CMP §5.2]` (as `#/flat-wire`). ⚠ **Raised, not settled** — it bypasses the repo's machine-context mechanism. `shared`'s `AuthenticationGuard` stashes `CURRENT_MACHINE` only when the path contains the literal **`shop-floor`** *and* its last segment is a positive number; `shared.service.ts` reads that in two places, and `LoginService.monitorUsers(machineConfigurationId)` drives the topbar's multi-operator chips that `[SCR §7.3]` requires. `[CMP §5.2]`'s routes satisfy **neither** test — `:lineId` is `FL1`/`FL2`/`FL3`, non-numeric and not the last segment. **Recommendation:** keep `/flat-wire` and make `line-context.service` resolve `:lineId` → machine id and set `CURRENT_MACHINE`, so multi-operator is consumed rather than rebuilt. → `[SCR]` / `[CMP]` |
| **`F-10`** | **`FW-137` is sequenced last** and its dependency named: `@angular/service-worker` is a provisioning item, like MessagePack, not a build one |
| **`F-11`** | **Flat wire follows the repo's content-data convention** — `src/assets/content-data/flat-wire.json`, a `FlatWireContent` type, and the `resolveData` / `ContentDataService` route pair — rather than the mockups' inlined English. In 1A the file covers shell chrome only and grows per screen |
| **`F-12`** | ⛔ **The role source must be decided before `FlatWireRoleGuard` can be built.** Options: **(a)** decode the JWT the client already holds; **(b)** extend the login response with the six roles — touches `Login`; **(c)** map the six onto the existing per-module ACCESS/WRITE primitive — no new mechanism, but loses `FR-212`'s Operations-Manager-only granularity. **This plan recommends (a)**: the roles are already in the token (`ClaimTypes.Role`, confirmed 15 Aug 2026), decoding is a few lines with no new dependency and no second team, and `[SEC §8]` puts the real gate on the API (`[Authorize]` + role policies) — which makes the guard **UX and defence-in-depth, not the enforcement point**, exactly the case where the cheap self-contained option wins. (b) remains right if `[SEC]` wants a server-authoritative shape. Either way the guard binds to **one constants class**, as [`FW-145`](../../40-backend/tasks/FW-145.md) does server-side. ✅ **All three options and this recommendation are now recorded in [`[SEC §8]`](../../Architecture/Security.md) itself** (27 Aug 2026), marked as a recommendation with the decision left to that document. → `[SEC]` / `G6` |
| **`F-13`** | **The library is `flat-wire`, not `flat-wire-shopfloor`.** Everything derived follows — `projects/flat-wire/`, `test:flat-wire`, `FlatWireModule`, `flat-wire-routing.module.ts`, `content-data/flat-wire.json` — and the route base matches the library name. ⚠ **There is no tsconfig path key, no `moduleNameMapper` entry and no `flat-wire.styles.scss`** (§2.1), and the selector prefix is the repository default `lib`. ✅ **Applied repository-wide on 28 Aug 2026** — 43 occurrences across sixteen documents (§6.8). ⚠ **The mockups' `flat-wire-shopfloor.styles.scss` / `.css` keep their names** — 23 HTML files link them. ✅ `[CMP §5.1]`, `phase-01a` and `FW-N03`'s acceptance criteria **all now say `flat-wire`** (§6.8) |
| **`F-14`** | **The canvas is 1920 × 1080.** User instruction, 27 Aug 2026, and it **decides `G23`** — the gap whose whole content was that nobody had confirmed 1280 × 1024. It is decided **in the expensive direction**: +50 % width against +5 % height, and 5:4 → 16:9, so the work is **re-composition, not rescaling** (step 2's six rules). ⚠ **The 14 px text floor and ≥ 48 px tap targets are carried forward unchanged on a stated assumption** — both are physical legibility rules (`[VAL §7.5]`: arm's length, gloved), so they track **dpi, not resolution**, and they hold only if the 1920 × 1080 panel is a **physically larger** panel of the same dpi class (a ~21.5" 16:9 against a 17–19" 5:4, both ~96–102 dpi). **If it is the same physical panel at higher density, every size in the token system scales ×1.5 and the floor becomes 21 px.** No document records the diagonal (§6.10) |
| **`F-15`** | **At the new canvas the mockups remain the authority on *content*, not on *composition*.** They keep their standing for controls, states, colour semantics, wording, interaction and the button-icon rule — `[SCR §7.1]`'s *"approved visual baseline and pixel authority"* is unaffected there. **What they cannot be is the layout authority for a canvas they were not composed at**: 18 files are laid out for 5:4. ⚠ **So composition at 1920 × 1080 is new design work with no mockup behind it**, and it is **not in `[TB §7]`'s hours** — flagged, not re-estimated, because `[CE]` owns the figure. **Do not re-author the mockups as part of 1A**: `G23`'s own instruction is *"do not re-author anything until answered"*, and the answer belongs to `[SCR]` / `[VAL]`, which still specify 1280 × 1024 |

---

## 5. Verification — phase-level

> **Each story plan carries its own verification against its own acceptance criteria.** This section is the **phase** gate: the commands in dependency order, and `phase-01a`'s five exit criteria mapped to the stories that satisfy them.

**In dependency order.** ⚠ `build:base` comes first: the tsconfig path resolves `shared` to
`dist/shared`, so nothing compiles against an unbuilt `shared`.

```bash
cd c:\UAL\Second-Branch\ual-angular

npm run build                 # clean:dist -> build:base -> the chains -> ng build.
                              # This is what compiles flat-wire: the wrapper imports it from
                              # SOURCE, so there is no `ng build flat-wire` and no chain entry
ng lint flat-wire             # eslint
npm run test:flat-wire        # Jest, 95 % thresholds
npm start                     # then #/flat-wire, light and dark
npm run everything            # build && lint && test — the aggregate gate
```

| # | `phase-01a` exit criterion | How it is proved | State |
|---|---|---|---|
| 1 | Library builds, lints, reachable at `/flat-wire` behind `FlatWireAuthGuard` | `ng build` + `ng lint` clean; `#/flat-wire` redirects when unauthenticated | ⚠ **role half blocked** on `F-12` |
| 2 | Shell renders on the **1920 × 1080** canvas, light **and** dark; all `--color-*` resolve, no `--fw-*` | browser check both schemes at 1920 × 1080; `grep -r '\-\-fw-' projects/flat-wire` returns nothing | ⚠ **restated by `F-14`** — `phase-01a`'s own wording says 1280 × 1024 (§6.10). ⚠ reviewing it 1:1 needs the scale-to-fit nobody owns (§6.3) |
| 3 | DI swaps real ↔ mock by `useMockData`; mock returns the seed fixtures through the envelope | `ng serve` (mock) vs a built environment (real); assert the fixture alphas | ⛔ **not meetable as written** — three named fixtures do not exist; meetable with step 4's table |
| 4 | `MockSignalRService` drives a `gauge-trace-chart` live — rAF-throttled, OnPush, reconnect + re-join simulated | run the mock stream; Angular DevTools shows no change-detection storm | — |
| 5 | Jest smoke suite green | `npm run test:flat-wire` | ⚠ exercises the **mock path only** (§6.6) |

---

## 6. Findings raised, not fixed

All are other documents' to correct, so they are recorded rather than edited.

### 6.1 ⛔ There is no client-side role source, so `FlatWireRoleGuard` cannot be built

`G6` / `OI-37` was closed on 15 Aug 2026 — the six roles exist as JWT claims on `ClaimTypes.Role` — and
the residual is filed as *"the claim **values** are coded rather than labelled, so the guard can be
**built** but not **checked**."* **Measured, it cannot be built either.** `LoginStatusDetails` carries
`userName`, `badgeNo`, `jwtToken`, `moduleId`, `machineType` and no role field; `shared.constants.ts`
has no role vocabulary; there is no `atob`, no JWT decoder and no role accessor anywhere in
`projects/` or `src/`. The repository's live authorization primitive is **per-module ACCESS / WRITE**
(`UserPermissionModel`, `USER_PERMISSIONS`), which is not the same shape as six named roles.

✅ **Raised to its owner and accepted there, 27 Aug 2026 — but the decision is still owed.**
[`[SEC §8]`](../../Architecture/Security.md) now **splits the residual across the wire**: server-side
construction is unblocked and only verification is gated, client-side **construction is blocked**. It
tables the three options with this plan's recommendation marked as a recommendation, and states plainly
that **`[SEC]` owns the choice**. ⛔ **`FW-131`'s role half stays blocked until it is made** —
`FlatWireAuthGuard` is unaffected.

⚠ **Two further corrections came out of the same review, and one of them was pointing at the wrong
scope entirely.** `[SEC §8]` described `FlatWireRoleGuard`'s MVP-1 job as *"Operations-Manager routes
DB9/DB9A gated from operator routes"* — **both are MVP-2 screens**, so the only worked example of the
guard was of something MVP-1 does not build; the live gate is `FR-212` on DB11, which `[SEC §8.9]`'s own
last row already said. And its API citation was wrong: **`[API §9]` is Traceability**, while the
per-endpoint roles are `[API §3.2]`'s. → `[SEC §8]`, `G6`, `F-12`.

### 6.2 ⛔ Three seed fixtures in the mock-service instruction do not exist

Independently re-measured against `FlatWire_SampleData_*.sql` on 27 Aug 2026, confirming
[`Orchestration.md §8.1`](Orchestration.md) finding 1: the spool alphas are **`SP-00031`–`SP-00033`**,
the run alphas **`RUN-0001`–`RUN-0005`**, and `SP-00021` occurs only inside a comment. `R00041`–`R00043`
and `PS-1100-FL1-003` are correct — but the latter is the **negative** fixture.

✅ **Half-closed 27 Aug 2026: [`[CMP §5.3]`](../Components.md) is corrected** — it now carries the measured
fixture table, names `PS-1100-FL1-003` as the negative case, and records that it had been warning
*"do not follow them"* while carrying three wrong alphas itself. ⛔ **`phase-01a`'s *Dependencies* line is
not corrected** and still names `SP-00021` and `RUN-0042/0043`, so **exit criterion 3 remains unmeetable as
written**. → `phase-01a`.

### 6.3 ⚠ The mockups' dialog runtime is not a porting target — but the scale-to-fit behaviour has no owner

`fw-modal.js`'s duties — open/close, focus restore, backdrop dismissal, ESC, focus trap — are already
`NgbModal`'s, wrapped by `shared`'s `CommonPopupService` (which tracks refs and dismissal). That is
**reuse, not a build**, and porting the script would duplicate sanctioned infrastructure. What
genuinely has no owner is **`flat-wire-fit.js`'s scale-to-window and the no-scroll dialog fit
(`--fw-modal-fit`)**: `[SCR §7.3]` names the former as shared chrome, every dialog screen (DB6, DB8,
DB12, DC, pause, weld) inherits both, and **no acceptance criterion in `FW-130`, `FW-133` or `FW-134`
mentions either.** ⚠ **`F-14` raises the stakes here**: at a 1920 × 1080 design box almost no developer
machine renders a screen 1:1, so the missing scale-to-fit stops being a nicety and becomes how anyone reviews
their own layout.

✅ **Recorded 27 Aug 2026, not resolved.** [`[SCR §7.3]`](../ScreenPlan.md) now lists `fw-modal.js` and the
four dialog scripts it had omitted, states that the Angular duties are `NgbModal`'s via `CommonPopupService`,
and warns that `flat-wire-fit.js`'s hard-coded 1280 × 1024 box is the *mockup* canvas rather than the build
target; [`[VAL §7.5]`](../ValidationRules.md) gained a **Dialog height** row. **No story owns the Angular
scale-to-fit, which is the half that matters.** → `[TB §7]`.

### 6.4 ⚠ The stack version of record is two majors behind the checkout

The ecosystem `CLAUDE.md` and `[ARC]` describe Angular 18.2.7, Jest 29 and a `serve:planning` /
`serve:furnace` script set. The checkout is **Angular 20.3.12**, TypeScript 5.9.3, Jest 30, and its
`package.json` has **no `serve:*` scripts at all**. Nothing in 1A depends on the difference, but every
estimate and every "copy the pattern" instruction was written against the older stack.
→ parent `CLAUDE.md`, `[ARC §14]`.

### 6.5 ⚠ The shared error interceptor will show operators raw machine codes

`ErrorHandlerService` pops a `MultiButtonPopupComponent` modal whenever a response carries
`body.errorDescription`, and `[API §1.2]` defines that field as *"the `[API §1.8]` machine code —
`BAY_OCCUPIED`"*. So every FlatWire error surfaces as a modal containing a code, while `FW-131`
specifies **toast + inline field errors**. The interceptor is global and provided by `SharedModule`,
so this is a design decision, not a bug to route around. → `[API §1.2]`, `phase-01a`.

### 6.6 ⚠ 1A's stated verification exercises the mock path only

`phase-01a`'s *Testing* section lists guards, the mock API service, `line-context` / `run-state` and
`MockSignalRService` — **`flat-wire-api-real.service.ts` appears in no criterion.** With `[TS §1.2]`
having withdrawn the backend's automated tests, the first thing that exercises the real client end to
end is the QA0 walkthrough, which is a **backend** checklist, and **no document names an FE reviewer
for it.** → `[TS]`, `[TB §7]`.

### 6.7 ⚠ The 95 % test gate is stricter than the phase spec, and two packages are absent

The gate is repo-wide and automatic; `phase-01a` asks for smoke tests. And `@microsoft/signalr-protocol-msgpack`
(`G10`, *measure-first*) and `@angular/service-worker` (`FW-137`, unregistered anywhere) both have to
be added to `package.json` before their stories can start. → `[TS]`, `[GAP]` `G10`, `[TB §7]`.

### 6.10 ⚠ The 1920 × 1080 canvas is decided here and stated as 1280 × 1024 in five places

`F-14` sets the canvas. ✅ **`[VAL §7.5]` — the row every other document derives from — was corrected on
27 Aug 2026.** ⚠ **Four sites still say 1280 × 1024, and one of them is an acceptance criterion this plan is
verified against:**

| Where | What it still says |
|---|---|
| [`[VAL §7.5]`](../ValidationRules.md) | ✅ **1920 × 1080**, with the geometry, the horizontal-re-layout rule, the dpi assumption behind the 14 px floor and a request for the panel diagonal |
| [`phase-01a`](../../60-delivery/phases/phase-01a-angular-foundation.md) | *"fixed **1280×1024** shopfloor canvas"*, and **exit criterion 2** |
| `[TB §7]` — `FW-130` | *"Fixed **1280×1024** canvas"*, an acceptance criterion |
| [`[GAP]` `G23`](../../Development/GapsRegister.md) | **still Open**, with *"do not re-author anything until answered"* as its resolution — the answer has now arrived and the row has not |
| [`../Mockups/`](../Mockups/) | **19 files, 18 of them composed for 5:4**; `flat-wire-fit.js` hard-codes `DESIGN_W = 1280` and `MIN_H = 1024`. ⚠ The 19th, `dashboard_3_active_run_ual.html` (28 Aug 2026), is DB3 at **1920×1080 in the host app’s CSS** — a comparison build, and the only rendering of a flat wire screen at the decided canvas |

**Two consequences worth stating plainly.** ⚠ **`G23` should be closed in the register, and closing it
is not free** — its impact line prices 1920 × 1080 as *"a re-layout of every screen, not a rescale"*,
which `F-15` accepts rather than argues with. ⚠ **The panel's physical diagonal is recorded nowhere**,
and `F-14`'s carry-forward of the 14 px floor depends on it: `G23` and `Q26` were about **resolution**
only. **Ask for the diagonal with the resolution** — a same-size denser panel means every type size,
tap target and spacing token scales ×1.5, which is a change to the token system rather than to the
layouts. → `[VAL §7.5]`, `[GAP]` `G23`, `Q26`, `[TB §7]`.

✅ **`Q26` advanced on 24 Aug 2026 and this plan should not be read as though nothing has moved**
*(recorded 28 Aug 2026)*. **The Nagarro-side action is closed** — Tim, opening the 24 Aug call,
confirmed the 1920 × 1080 requirement and said he would respond to Charles's e-mail, so the number is
on record with the two people who own the answer. **The question is still `Open`**, because what UA will
actually stock is Charles's and Juan's to say. ⚠ **Two things in that progress note bear on `F-14`
rather than on `G23`:**

1. ⚠ **Tim's phrasing was *workstation* resolution.** That may not be the shopfloor HMI panel this
   question is about, and the two are **different dpi classes** — which is precisely the axis `F-14`'s
   14 px carry-forward rests on. **One answer may not cover both**, and it is the *panel's* number that
   is needed. `Q26` flags this itself; nothing has confirmed it either way.
2. ⚠ **`Q26`'s own `Recommendation:` still reads *"hold the 1280 × 1024 canvas"***, which `F-14`
   supersedes by user instruction. A reader arriving at the register first will find the opposite of the
   decision. **That is the register's line to update, not this plan's** — but it is why `G23`'s row and
   `Q26`'s recommendation should be closed in the same pass.

---

### 6.11 ⚠ Three residuals from the 27 Aug specification pass, each owned elsewhere

The three `Frontend/` specifications were corrected on 27 Aug 2026. **Three things they surfaced live
in documents this plan does not touch:**

1. **`CLAUDE.md` still lists four run-event dialogs and omits `roll_adjust.js`.** There are five. ⚠ **And it omits a sixth dialog script entirely** *(added 28 Aug 2026)*: `spool_notification.js`, the shared spool-progress component — Part A milestone card and docked pill, Part B PLC-stop modal — which `[SCR §7.3]` does list. Measured, the mockups folder holds **ten** `.js` assets: three chrome (`flat-wire-topbar` · `flat-wire-fit` · `fw-modal`), five run-event dialogs (`die_change` · `spc_checkpoint` · `wip_rejection` · `rod_checkout` · `roll_adjust`), `pause_run` and `spool_notification`. **`CLAUDE.md` names eight of the ten.** → the ecosystem `CLAUDE.md`.
2. **`OI-11` (Roll Adjust line applicability) is still carried as open** in `[REQ]`'s open-items line, although `FR-107`–`FR-109` answer it explicitly and `[SCR]` Appendix B is now corrected to match. **Answered in the requirements, unclosed in the register.** → master spec §11.
3. **`[VAL]`'s client-side validation has never been written.** Its title and Document Type both claim it; new §7.5a now records the gap rather than leaving it implied, and names what has no home: `FW-131`'s toast-versus-inline rules, `FW-134`'s `.input` states, the field formats `FW-132` bakes into its models, and **`G14`'s two unresolved halves** (3- versus 4-item inspection, `FootageFt` INT versus DECIMAL). → `[VAL]`, `G14`.

✅ **One thing that looked like a residual is not.** `[VAL §7.5]`'s Print row read *"no print action on any
operator screen"* against four `Must` requirements — `FR-336` (coil label preview before printing),
`FR-146`, `FR-335` and `FR-340` (two label printers per line). **`[VAL]` was wrong and `[REQ]` was right**;
the rule is *no **traveler** printing*, and it is corrected. Nothing in `[REQ]` needed to change.

---

### 6.12 ⛔ The hub contract carries fourteen events, and the backlog and layer spec still say nine and twelve

**Found and fixed in `[SIG]` on 27 Aug 2026, but three sites outside it are stale and one of them is a
story's acceptance criteria.** Events 11 and 12 (spool-completion prompt) were promoted on 14 Aug 2026
and events 13 and 14 (order allocation) added on 22 Aug, taking the contract to **fourteen**.

| Site | Says | Consequence |
|---|---|---|
| ✅ `[SIG §5.2]` | **14** — the table was always right | — |
| ✅ `[SIG §5.6]` observable map | was **12**, now **14** | ⛔ **`FW-135`'s criterion is *"typed Observables per event"***, so a client built to the old map ships **12 of 14** |
| ✅ `[SIG §9.3]` | was **"Ten"** | three counts behind, inside the same file |
| ⛔ `phase-01a` | *"the full published set — **twelve** events"* | the layer spec `FW-135`/`FW-136` are built from |
| ⛔ `[TB §7]` `FW-136` | enumerates **nine** | **acceptance criteria** — a mock passing them emits 9 of 14 |
| ⛔ `[TB §7]` `FW-080` | claims to match `FW-136` *"exactly"* | true of neither, so the **hub** side is unpinned too |

**The two missing streams are not minor.** `orderAllocationReached$` / `orderAllocationResolved$` are the
**only signal DB3 receives that an order boundary has been crossed on a rod that is still running** — no
rod is dismounted and nothing is scanned, so without them the screen cannot reveal the next order, and
the material produced between the crossing and the acknowledgement (the **overrun**, which is recorded
and reportable) has no operator-visible trigger at all.

⚠ **`PP-04` is the reason this survived, and it has been corrected too.** That item exists to keep the
count in step; it audited two *other* documents and never checked its own file, so both stale sites were
inside `[SIG]`. Its rule is now four sites, and it gained the distinction it was missing: **a document
that *enumerates* the events carries the count even without printing a number** — which is exactly how
§5.6 went stale silently. **I have not edited `[TB §7]`** — backlog rows feed the client `.xlsx`
generators, so that correction should be made deliberately by their owner. → `phase-01a`, `[TB §7]`.

---

### 6.13 ⛔ Phase 1A has no test cases, in a suite of 405

**Measured 28 Aug 2026 against [`[TCS]`](../../Testing/TestCases.md).** Searching the suite for the
things this layer delivers — the Angular library, the shell layout, the canvas, `FlatWireAuthGuard`,
`FlatWireRoleGuard`, `MockSignalRService` — returns **nothing**. **Not one of the 405 cases names a
Phase-1A story.**

⚠ **The suite holds 405 defined cases and its highest id is `TC-799` — those are different numbers**
. Case
ids are minted per requirement block and are **non-contiguous**: 47 ids are cited somewhere in the
repository and defined nowhere. **Cite the count when you mean the count** — an id is not a tally, and
`[TCS]`'s coverage matrix is read against the former.

**Two cases are citable, and neither was written for this layer:**

| Case | For | State |
|---|---|---|
| **`TC-020`** | the enum mirror C# ↔ TypeScript ↔ DB `CHECK`, **P1** | `FW-132` owes its third leg (`G56`). ⚠ A **manual** diff across 14 enums — `[TS §1.2]` withdrew the automated check |
| **`TC-640`–`TC-659`** | the `[SEC §8]` permission matrix | `FW-131`'s subject. ⛔ **Cannot pass** — the claim values are coded (`G6`) and the guard is blocked (`F-12`) |

**So 1A's verification is the nine plans plus Jest, and nothing else.** That is defensible for a
foundation layer — `phase-01a`'s exit criterion 5 is *"Jest smoke suite green"*, and the **95 %**
coverage gate is a build gate rather than a test-case gate. **What is not defensible is leaving it
unsaid**, because `[TCS §10.1]`'s coverage matrix is what UAT sign-off rests on, and `G25` exists
precisely because coverage was once asserted from a range table rather than measured per requirement.

⚠ **`[TCS]` is not this file's to extend.** Recorded here so the gap is visible; the cases belong to
`[TCS]` and their absence belongs in `G25`'s tally. → `[TCS]`, `G25`.

---

### 6.14 ⚠ `[CMP §5.1]`'s routing filename contradicts the repository, found on execution

`[CMP §5.1]` and this folder's Step-5 tree name the routing file **`flat-wire-routing.ts`**. Measured
in `Second-Branch/ual-angular` on 28 Aug 2026, the convention is **`<lib>-routing.module.ts`** — all
**five** existing routing files use it (`coil-receiving`, `furnace-scheduling`, `login`,
`manpower-scheduling`, `ot-signup`), alongside **36 × `*.module.ts`** and **313 × `*.component.ts`**.
The file is also genuinely an NgModule — it wraps `RouterModule.forChild(FLAT_WIRE_ROUTES)` — which is
what the `.module` suffix denotes.

**`FW-N03` was built as `flat-wire-routing.module.ts`**, following the repository, and the exported
routes constant is `FLAT_WIRE_ROUTES` exactly as `[TB §7]` requires. ⚠ **This plan does not overrule
`[CMP]`** — the conflict is raised for it to settle, and it is cosmetic: no citation anywhere depends
on the filename. The same pass found the Angular 20 schematic emits `flat-wire-module.ts` /
`flat-wire.ts`, which matches neither the spec nor the repository. → `[CMP §5.1]`.

---

## 7. What this plan does not cover

> **The scope, stated once.** This plan sequences and grounds **Phase 1A only**.

| Item | Why |
|---|---|
| Pixel-level design | [`../Mockups/`](../Mockups/) is the authority on **content** — controls, states, colour semantics, wording, interaction. ⚠ **Composition at 1920 × 1080 is not covered by them and not covered here** either: it is design work `[SCR]` / `[VAL]` own (`F-15`) |
| Component APIs, inputs, outputs | `[CMP §7.6]`'s and the mockups' |
| Wave ordering and downstream phases | [`Orchestration.md`](Orchestration.md) §2 and §5 |
| Backend and database work | [`Backend/tasks/`](../../40-backend/tasks/Orchestration.md) · [`Database/tasks/`](../../30-database/tasks/Orchestration.md) |
| DB9 · DB9A · DB10 · Die Management · OEE | **MVP-2.** Do not plan, estimate or implement |
| `FW-204` · `FW-214` | Trial scope, additive to `[CE §3b]` |
| The `[ARC §2.2]` reference rules | **Binding, and `[ARC]`'s.** Cited as `D-06`, not restated |

---

## 8. Keeping this plan true

- **A step is executed → record it in that story's plan**, not here — and record what the repository actually did, as the Backend plans do. A plan that never records its own execution becomes fiction at the first surprise.
- **A new fact about the checkout → §2 of this file.** A new decision → **§4**, minting the next `F-##`. A finding against another document → **§6**. **Never into a story plan** — nine copies of a fact is the failure this split was shaped to avoid.
- **A story's status changes → §3's index row and `Orchestration.md`'s §1 row**, which are the two places a reader looks for it.
- **A specification changes → this plan is corrected up to it.** It never wins.
- **A finding in §6 is fixed at its owning document → strike it here** and leave a pointer.
- **Never restate an hour figure.** `[TB §7]` owns them; §1 names stories, not totals.
- **Never mint a `P-##` here** — that series is the Backend folder's. `F-##` is this folder's.
- Per repository convention, changes go in [`CHANGELOG.md`](../../CHANGELOG.md) — **do not add a change log to this file.**
