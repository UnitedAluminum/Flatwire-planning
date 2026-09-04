# Flat Wire — UI Conventions

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 4, 2026 — Change history is in [`../CHANGELOG.md`](../CHANGELOG.md)
**Document Type:** Frontend UI conventions, derived from a built screen
**Status:** Active — **read before building any flat wire screen**
**Owner:** Frontend (Angular)
**Audience:** Every developer building a flat wire dashboard
**Shortcode:** **`[UIC]`** — *folder-local; derived from the repository and from `[CMP]`, and **not citable as a requirement***
**Part of:** `ProjectPlan/Frontend/` — index: [`tasks/Orchestration.md`](tasks/Orchestration.md)

---

> **Why this file exists.** The mockups in [`mockups/`](mockups/) are the **content** authority —
> what a screen shows, in what grouping, with what labels. They are **not** the **look** authority:
> they carry a `--color-*` token palette that **exists nowhere in this repository** and were composed
> at 1280 × 1024. This file is what a screen actually gets built from.
>
> **It is derived from real screens**, not proposed: `flat-wire-landing.component` (DB3 Active Run
> Monitor, the landing screen) and `supervisor-dashboard.component` (DB1 Line Status), both in
> `projects/flat-wire/`. Everything below compiles, lints and renders.
>
> ⚠ **Both screens are UI skeletons.** Every value on them is a literal in a private builder — there
> is **no API client, no SignalR and no subscription anywhere in the library**, and every rail entry
> is inert. This file is therefore authoritative on **look, composition and structure**, and says
> nothing about behaviour that has not been built. Where a rule below depends on live data, it says so.
>
> ⚠ **DB3 is the one to copy.** It is the landing screen, and every other flat wire screen is either
> near-identical to it or a close variant.

---

## 1. The reference implementation

| | |
|---|---|
| **Built screens** | `components/flat-wire-landing/` — **DB3 Active Run Monitor**, the default child of `#/flat-wire` · `components/supervisor-dashboard/` — DB1 Line Status at `#/flat-wire/supervisor-dashboard` |
| **Shared controls to consume** | **`projects/shared`** — `lib-nav-rail` · `lib-chart-canvas` · `lib-trace-panel` · `buildTraceConfig` (§3.22). ⚠ **`shared` has 23 dependent libraries**, so `ng build shared` before any dependent test run: jest resolves the `shared` alias to `dist/`, not source |
| **UI pattern source** | `projects/slitter-interface/.../slitter-traveler-landing.component.html` — ⚠ **its rail is now `lib-nav-rail` too**, so there is no rail markup left there to copy |
| **Card layout source** | `.claude/commands/scaffold-form.md` §8 — ⛔ **the card layout only, never its modal layout** |
| **Content sources** | [`mockups/dashboard_3_active_run.html`](mockups/dashboard_3_active_run.html) · [`mockups/dashboard_1_line_status.html`](mockups/dashboard_1_line_status.html) |

⛔ **Do not take UI patterns from `ot-signup` or `print-traveler`.** They are both routing modules
**and** injectable libraries, so their wiring carries things a flat wire screen must not copy.

⚠ **Only the UI comes from `slitter-traveler-landing`** — its markup, classes and palette. **Not** its
services, state stores, facades or subscriber services; flat wire has its own and `FW-132` owns the
API client.

⛔ **And not its grid components.** `slitter-traveler-landing` renders its info grids with
`lib-static-grid` / `lib-common-grid`, and using those here breaks **`D-06`**: *"`checkin-precheckin`,
`shop-floor*`, `common-grid`, `wip-rejection` and `slitter-*` are **not** to be copied; the only reuse
is `shared`'s foundational services."* `[TB §7]`'s `FW-133` card says the same. **Tabular data is
plain Bootstrap `<table>` markup**, and `CommonGridModule` is not imported by `FlatWireModule`.
`FW-163` owns the eventual shared `info-grid`.

⚠ **This is the line:** take slitter's **classes, palette and card idiom**; take **none** of its
components, services or state stores.

### 1.1 Where the UI goes — the shell, the wrapper and the default load

⛔ **The UI does not go in the shell component.** Measured: `slitter-interface.component` is *only*

```html
<lib-header [isExeLogin]="true" [serverName]="serverName" [showHelpIcon]="true" /><router-outlet /><lib-footer /><lib-global-spinner /><lib-toast />
```

and **every piece of UI — nav rails, context bars, cards — lives in its routed child**
`slitter-traveler-landing`. `flat-wire.component` is the same frame, with the header wrapped in a
`container-fluid`. **Build the screen as a child component and leave the shell alone.**

⚠ **`isExeLogin` is a required input on every shell that runs on a machine terminal.** It replaced
`lib-header`'s internally-derived `multiUser` field, so a shell that omits it silently loses the
machine-login header treatment. Flat wire, slitter-interface and furnace-scheduling pass `true`.

| Layer | What it is |
|---|---|
| **Host route** | `src/app/routes.ts` lazy-loads `src/app/project-routes/<lib>-wrapper.module.ts` by `webpackChunkName`. ⚠ **The file is not alphabetical — append.** |
| **Wrapper module** | `@NgModule({ imports: [FlatWireModule] })`, importing the library module from its **source** path — which is why a routing application needs no `tsconfig` path, no `dist` bundle and no build-chain entry |
| **Library routing** | one parent `path: ''` → the shell component, carrying `canActivate: [AuthenticationGuard]`, `data: { resolveData: [...] }` and `resolve: { contentData: ContentDataService }`; **screens are its children** |
| **Default load** | ⚠ `slitter-interface` needs none, because the shop-floor menu navigates to `shop-floor/slitter/traveler`. **Nothing navigates to flat wire**, so the routing module carries `{ path: '', pathMatch: 'full', redirectTo: '<landing>' }` as its **first child** — without it the shell renders with an empty outlet. `login-routing.module.ts` is the in-repo precedent |

### 1.2 Four authorities, and each one answers exactly one question

⚠ **The mockup folder does not settle which dashboard a story owes** — nineteen files, several
variants per line, and no mapping to story ids.

| Question | Authority |
|---|---|
| **Which screen, and which sections?** | the **story plan**. If a plan does not name its screen, that is a gap to raise in the plan — not a choice to make silently |
| **What goes on it?** | the **mockup** — content only. ⛔ Not composition (`F-15`), not its `--color-*` tokens (they exist nowhere in the repository), not `flat-wire-fit.js`'s scaling (§4.1) |
| **What does it look like?** | **this document**, and **`projects/shared`** for the rail and the chart — consume them, do not rewrite them (§3.22) |
| **How is the code written?** | ⚠ **the application repository's rules, and they are mandatory** — `UALUADEV/CLAUDE.md`, `.claude/instructions/` per file type, `/generate-tests` before any spec and `/angular-review` before the PR. See *Before you write code* in the repository [`CLAUDE.md`](../CLAUDE.md) |

⚠ **The fourth row is not advisory and is not remembered.** A `PreToolUse` hook in `UALUADEV`
(`.claude/hooks/inject-rules.cjs`) pushes the matching rule digest from
`.claude/instructions/digests/` into context on **every file write**, because *"read the instruction
file first"* was advisory and was skipped every time. ⛔ **`ng lint` passing is not evidence of
compliance** — the rules that actually get broken are the ones ESLint cannot see (§3.20, §3.21).

---

## 2. Create no new classes, styles or colours

**Almost everything a flat wire screen needs already exists.** The reference screen carries **no
`.scss` file of its own** — `projects/flat-wire/` has none and registers none — and the whole of it
was built from existing classes bar the additions to `src/styles/styles.scss` recorded below.

| Need | Use | Defined by |
|---|---|---|
| widths, heights, font sizes | `w-100` · `min-w-0` · `h-91` · `h-100` · `fs-14` · `fs-15` | `_dynamic-classes.scss` generates `w-1…99` (%), `h-1…99` (vh) and `fs-N` (px) |
| colours | `bg-semi-dark-blue` · `bg-dark-subtle` · `bg-body-secondary` · `bg-light-grey` · `bg-white` · `text-black` · `text-white` | `_colors.scss`'s `$colors` map → `.bg-<name>` and `.<name>` generated for **every** entry |
| nav rail | ⛔ **none — you write no rail markup.** Bind `<lib-nav-rail>` from `projects/shared`, which owns `menu-sidebar` · `menu-content` · `menu-icon-btn` · `extra-big` · `bigger` and its own width binding internally (§3.22) | `projects/shared` |
| modals | `modal-header bg-semi-dark-blue` + `cdkDrag` · `modal-body bg-light-grey` · `modal-footer` with the close button last as `btn extra-big btn-danger fw-bold` — opened through `CommonPopupService` | `.claude/instructions/popup.md` |
| cards, grid, progress, alerts, badges | `card border-0 shadow-sm` · `row g-2` / `col-4` / `col-6` · `progress` / `progress-bar` · `alert alert-warning` · `badge` | Bootstrap 5.3.8 |
| tables | `table table-sm table-hover` in an `overflow-x-auto` wrapper, `text-nowrap` cells, `bg-light-grey` header row | Bootstrap 5.3.8 — ⛔ **not** a grid component, see §1 |
| collapse chevrons | `fa-circle-chevron-up` / `fa-circle-chevron-down` toggled on a `fa-2x` icon in the card header | Font Awesome, as `slitter-traveler-landing` does |
| status dots | `<i class="fa-solid fa-circle text-success">`, plus `live-dot` when it stands for something **live** (§3.18) | Font Awesome for the dot — ⚠ **an icon, not a CSS dot**; the pulse is `styles.scss`'s, ⛔ **not** Font Awesome's `fa-beat-fade` |

⚠ **If a requirement genuinely needs a new class, say so explicitly** in that story's plan — what was
created and why. Silence is read as "nothing was created".

**Five classes have been created, and how they were named is the model to follow.** Each earned
its place the same way: the thing it does is wanted by **more than one** screen, so binding it
inline per instance would guarantee the next screen diverges. Each therefore went into
`styles.scss` under a **generic name** — `.floating-popover`, not `.spool-card`:

| Created | Where | Why it is a class and not a binding |
|---|---|---|
| `.floating-popover` (+ its `.pill` modifier) | `src/styles/styles.scss` | The corner anchor, width and z-index of **any** non-modal advisory. Naming it for the spool would have forced the next one to duplicate it |
| `.floating-popover-scale` | same | Centres each label on the percentage it is bound to, so a ticked scale reads as an axis |
| `.live-dot` (+ its two keyframes) | same | The liveness pulse (§3.18). Font Awesome's equivalent is invisible at dot size, and a pulse belongs to **any** live indicator, not to the spool |
| `.min-w-0` · `.min-h-0` | `src/styles/_dynamic-classes.scss` | ⚠ **These were being used before they existed.** The generators emit percentages and vh **from 1**, so neither could be expressed, and Bootstrap ships neither — every `min-w-0` in the repository was a silent no-op, `slitter-traveler-landing`'s included. Required by §4.1 |

⛔ **A screen-specific `.scss` file is still not the answer.** `projects/flat-wire/` has no stylesheet
and registers none (`[FW-N03]`). Anything reusable enough to deserve a class is reusable enough to
belong in `src/styles/`.

---

## 3. Rules learned from building the screen

### 3.1 ⛔ Badge text colour follows the badge background — it is not a blanket rule

| Badge background | Shade | Text |
|---|---|---|
| `bg-dark-subtle` | **light** grey | **`text-black`** — white does not read on it |
| `bg-secondary` | **dark** grey | **leave the default (white)** — do **not** add `text-black` |

⚠ **This is the rule that is easiest to over-apply.** *"Badge text is black"* is wrong; the contrast
is what decides. Check the background before adding `text-black`.

### 3.2 A card-header subtitle keeps the header's weight

The qualifier beside a card title — `FL3 Hybrid` — is **not** `fw-normal`. It inherits the header's
`fw-bold` and differs by **size only** (`fs-14`), so the heading reads as one thing. Use `titlecase`
on a value that arrives lower case.

```html
<span class="fw-bold fs-5 text-white">
  {{ line.lineId }}
  @if (line.subtitle) {
    <span class="fs-14">{{ line.subtitle | titlecase }}</span>
  }
</span>
```

### 3.3 Bootstrap's `.badge` renders at 10.5 px here

That is below `[VAL §7.5]`'s **14 px floor**. **Every badge carrying text takes an explicit `fs-14`.**

### 3.4 The app's `.btn` rule owns the **hover** state, and forces the label white

**Measured**: the base `.btn` in `styles.scss` sets `line-height`, `font-size: inherit`,
`vertical-align` and `border` — **no colour at all**, so at rest a button is whatever Bootstrap and
your own classes make it. On **hover and focus-visible** it forces background and border to
`#343a40` (`$light-black`), the label to **white** `!important`, and the icon to cyan.

⚠ **The consequence to design around is the hover, not the rest state.** A button whose own
background is light will still go near-black with a white label under the cursor, so pick a rest
background that the hover reads as a deliberate change from — `bg-dark-subtle` on nav and action
buttons, exactly as `slitter-traveler-landing` does.

### 3.5 The icon rail scales with the canvas

The collapsed rail is **60 px** — `menu-icon-btn`, which is `60px !important` square in
`styles.scss` — with **`fa-2x`** icons; expanded it is **240 px** with **`extra-big fs-15`** labels.

⚠ **None of those three is switchable.** `lib-nav-rail` applies `| uppercase`, `fa-2x` and `fs-15`
unconditionally — there are no per-screen inputs for them, and the ones that briefly existed were
removed deliberately. The **widths** are inputs (`collapsedWidth` / `expandedWidth`) defaulting to
`NAV_RAIL_WIDTH` (§3.10).

⛔ **There is no `big-screen` class.** It was written alongside `menu-icon-btn` and is defined
**nowhere** — 0 occurrences in the built stylesheet — so it was a silent no-op, exactly like
`min-w-0` was (§2). It has been removed from both screens; `slitter-traveler-landing` never used
it. **The button is 60 px, not 75.**

### 3.6 ⛔ A mockup's bottom action bar becomes the **left nav rail**

**Every mockup that ends in an action bar** — DB3's *Run events · Go to · Run control* clusters, and
the same shape on the others — **is built as the collapsible left rail instead.** The bar is not
reproduced at the bottom of the screen.

DB3's rail, as built: **SPC Checkpoint · Roll Adjust · WIP Reject · Pause Run · Checkout · Complete
Coil**, plus a **More Options** entry (`fa-list`) at the foot of the rail — the
`slitter-traveler-landing` idiom, which carries one on its own rail. ⚠ Note this is **not** a literal transcription of the mockup's bar, which reads *Die Change*
and *Complete Run* — the rail is what was agreed.

⚠ **Entries for screens that do not exist yet are `isActive: false`, not omitted.** The rail renders
them `[disabled]`, so the operator sees the full shape of the screen's actions from day one and no
entry appears later as a surprise. All seven on DB3 and all five on DB1 are currently inert.

⛔ **No right-hand action rail.** `slitter-traveler-landing` has one; flat wire does not.

### 3.7 ⛔ A mockup's demo scaffolding is not screen content

Mockups carry controls that exist to **drive the mockup**, and they must not be built:

| In the mockups | What it is |
|---|---|
| `.fwn-demo` | a fixed bar at `left:96px; bottom:16px` reading *"mockup demo — jump to"*, with percentage jump buttons and `■ stop` / `▶ start`. Injected by `spool_notification.js` behind `FW_SPOOL_CONFIG.demo: true`, and labelled in its own source as *"Mockup-only demo controls"* |
| `FW_*_CONFIG` script blocks | the data that feeds the demo — `FW_SPOOL_CONFIG` and friends |

⚠ **Anything fixed-positioned that drives the demo is scaffolding.** If in doubt, look for a `demo`
flag gating it.

### 3.8 Charts go through `shared`'s `ChartConfigBuilder`

⚠ **Read §3.22 first — for a trace you consume `lib-trace-panel` and never touch any of this.** What
follows is for a chart that is genuinely new.

`projects/shared/src/lib/models/chart-util/chart-util.model.ts`, with `ChartType.LINE` from
`shared`'s `constants/chart.constants.ts`. ⚠ **Two consumers, not four** — `buildTraceConfig` and
`safety-summary-report`. The other chart screens (`furnace-view-graph`, `furnaces-graph`,
`effectiveness-chart`) call `new Chart(...)` directly, so they are **not** precedents for using it.

⚠ **The builder is bar-oriented** — `setYAxisData` sets `barPercentage`/`categoryPercentage`,
`setXAxisLabels` takes `string[][]`. Build with it, then adjust the returned `ChartConfiguration`;
**do not edit the shared model**, which has another consumer.

**Three settings that are not optional:**

1. **`responsive: false`** — right for the screen, which is a fixed panel and not a browser, **and**
   a responsive chart **crashes the Jest worker at teardown**. ⚠ **It does not mean `width`/`height`
   attributes on the `<canvas>`**: `lib-chart-canvas` carries none and instead sizes the drawing
   buffer itself with `chart.resize(clientWidth, clientHeight)` against a `position-absolute` canvas
   filling its box. That is what makes the chart follow a flex budget (§4.1).
2. **`maintainAspectRatio: false`** — without it the height is derived from the width and the budget
   is ignored.
3. **`setupFiles: ['jest-canvas-mock']`** in the library's `jest.config.js` — **`projects/shared`'s
   as well as the consuming library's** — *and* `import 'jest-canvas-mock';` at the top of every
   spec that renders a chart. Both are needed; either alone fails.

**Target line and tolerance band** come from `chartjs-plugin-annotation`, registered with
`Chart.register(annotationPlugin, ...registerables)` **as the first statement inside the config
builder** (§3.14a). The one-line precedent in the repository is `effectiveness-chart`;
`furnace-view-graph` registers a longer, different set and is not the model to copy.

### 3.9 ⛔ Numbers live in objects, not in bare arrays

`@typescript-eslint/no-magic-numbers` is **`error`** with only `0` and `1` ignored, and — measured —
**only `*.spec.ts` is exempt.** `.constants.ts` is **not**, contrary to what `CLAUDE.md` says.

The rule ignores numbers used as **object property values** (`detectObjects` defaults to false),
which is why `SHARED_NUMBERS = { TWO: 2 }` passes. **It does not ignore array elements.** So a series
of readings goes in an object and is consumed with `Object.values(...)`:

```typescript
export const GAUGE_TRACE_READINGS = { T1: 0.109, T2: 0.111, T3: 0.11 };
// points: Object.values(GAUGE_TRACE_READINGS)
```

A number assigned to a named `const` is fine — `export const GAUGE_TARGET = 0.11;` passes.

### 3.10 The nav rail's width is bound in **px**, not a percentage and not `w-auto`

Two constraints have to hold at once, and only px satisfies both:

| Constraint | Why a percentage fails | Why `w-auto` fails |
|---|---|---|
| The 60 px button must always fit | `menu-icon-btn` is **60 px `!important`** square, so a percentage width is wide enough only at one viewport. Below that the button overflows a container with `overflow: hidden` — the rail visibly distorts | — |
| The collapse must animate | — | `menu-sidebar` carries `transition: width 250ms ease`, and **CSS cannot transition to or from `auto`.** The animation silently stops working |

✅ **`lib-nav-rail` already does this and you inherit it** — it binds `[style.width.px]` on a
`menu-sidebar` div internally, from `NAV_RAIL_WIDTH = { COLLAPSED: 60, EXPANDED: 240 }` in
`projects/shared/src/lib/shared.constants.ts`. **60** matches the button exactly; **240** clears
`extra-big`'s `min-width: 120px` and holds a label like *SPC Checkpoint*. Both are overridable per
screen through the `collapsedWidth` / `expandedWidth` inputs, but there has been no reason to.

⛔ **Do not write the div.** The two constraints above are recorded so the next person does not
"simplify" the width binding back into a class — not as an instruction to rebuild the rail.

⚠ **`slitter-traveler-landing` used `w-5` collapsed, and no longer does.** It was tuned for 1280 and
would have broken at 1920; that markup was deleted when the screen moved to `lib-nav-rail`, so all
three consumers now share one px width.

### 3.11 The canvas takes the height that is left over, and never adds to it

With `responsive: false` (§3.8) Chart.js never reflows on its own, so the size has to come from
somewhere. ⛔ **Do not give the canvas a fixed height.** A `height="260"` attribute makes the chart
the single largest **fixed** cost on the screen, and it is what pushes the page past a windowed
browser — 260 and then 200 were both tried and neither fitted (`[UIC §4.1]`).

**Take it out of the flow instead**, so CSS derives the height and the canvas can never make the
page taller. ✅ **`lib-chart-canvas` is exactly this and you consume it** — its own template is:

```html
<div class="position-relative flex-grow-1 min-h-0">
  <canvas #chartCanvas class="position-absolute top-0 start-0 w-100 h-100"></canvas>
</div>
```

⚠ **The canvas has no `id`.** It is reached by `viewChild.required`, not `getElementById`. A `chartId`
field on a panel model is a leftover from before the component existed — do not add one back.

That needs the flex chain above it to be unbroken — **card body → row → column → panel** all pass
the height down (§4.1), and the panel's own header and stats row are `flex-shrink-0` so the canvas
box gets the remainder.

⚠ **Two links of that chain are host classes on the shared components, not classes you can see in
your template.** `TracePanelComponent` carries `h-100 d-flex flex-column` and `ChartCanvasComponent`
carries `d-flex flex-grow-1 min-h-0`, both declared in the component's `host` metadata. Without them
the chain breaks at the component boundary — an Angular component host is `display: inline` by
default, and a blank canvas is the symptom. **If you write a component that must participate in a
flex budget, put its flex classes on its host, not on its outermost `<div>`.**

**Then follow the box with the drawing buffer**, or the chart renders at Chart.js's default 300×150
and is scaled up by CSS into a blur. `lib-chart-canvas` owns this too — `resize()` is a
`@HostListener('window:resize')` calling `chart.resize(clientWidth, clientHeight)`.

⚠ **The screen still owns the resizes the window does not raise** — the nav rail expanding, a table
opening or closing. Reach the panels with `viewChildren(TracePanelComponent)` and call their public
`resize()`, which delegates down:

```typescript
@HostListener('window:resize')
public resizeTraces(): void {
  this.tracePanelViews().forEach((panel: TracePanelComponent) => panel.resize());
}
```

⛔ **Do not hold `Chart` instances in a field on the screen.** The screen holds no charts at all;
`ChartCanvasComponent` owns every one of them and releases it on teardown.

✅ **A `if (!this.chart) return;` guard in `resize()` is correct, and it is coverable.** The false
branch is exercised by creating a **second fixture and never calling `detectChanges()` on it**, so
the view — and therefore the chart — is never built. That technique is what replaces the old advice
to keep the method branch-free; guards no longer have to be avoided to protect the branch gate.

---

### 3.11a A collapsed section destroys its canvas — and `lib-chart-canvas` already handles it

**This bit twice, and it is worth knowing why even though it is now solved for you.**
`@if (isTraceSectionExpanded)` removes the `<canvas>` from the DOM. Any `Chart` object still held in
a field then points at a detached element; on expand Angular creates **new, empty** canvases and
nothing draws to them — the graph is simply gone. Resizing does not help: it resizes charts bound to
elements that no longer exist.

✅ **The hazard is still live and the remedy is automatic.** `ChartCanvasComponent` owns the whole
lifetime in its constructor:

| | |
|---|---|
| `effect(() => this.render(this.config()))` | draws whenever the config changes — **destroying the previous chart first**, unless `isLive`, in which case it updates in place with `update('none')` |
| `afterNextRender(() => this.resize())` | matches the buffer to the box once the view exists |
| `destroyRef.onDestroy(() => this.releaseChart())` | collapse destroys the component, which releases its chart |

So collapsing destroys the canvas **and** its chart together, and expanding creates a new component
that draws in its own effect. **There is nothing to call and no lifetime to manage on the screen.**

⛔ **Do not write a `drawTraces()`, a `renderTrace()` or a `charts` field.** None of them exists any
more, and adding one back gives the chart two owners — which is the original bug.

⚠ **Maximise is a different problem with the same cause** — see §3.14, which is why maximise opens a
popup rather than expanding a panel in place.

### 3.12 Every `ngbTooltip` carries `triggers="hover"`

Without it the tooltip also opens on focus, which on a touch panel means it opens and stays open
after a tap. ✅ `lib-nav-rail` and `lib-trace-panel` set it on every tooltip they own, so consuming
them gets this right by default — ⚠ **which is how `slitter-traveler-landing`'s hamburger toggle was
fixed**: it carried an `ngbTooltip` with no `triggers` until the rail was shared.

### 3.13 A badge's label is `fw-normal`; only its value is bold

Bootstrap's `.badge` sets `font-weight: 700`, so a `label + value` badge renders both alike and
reads as one string. **Put `fw-normal` on the label span and leave the value bold.**

```html
<span class="badge bg-dark-subtle fs-14 p-2 text-black">
  <span class="fw-normal">{{ chip.label }}</span>
  <strong>{{ chip.value }}</strong>
</span>
```

⚠ **This is not §3.2's case.** A card-header subtitle keeps the header's weight and differs by size;
a badge label differs by **weight** from its own value.

### 3.14 ⛔ Maximise opens a **popup** — never expand a chart in place

The mockups draw a maximise button on every trace panel, and it must work. **It opens the enlarged
trace in a modal** — `CommonPopupService.popupModal(…, { modalSize: MODAL_SIZE.XL, modalName }, { panel })`,
where `MODAL_SIZE` comes from `shared` and `modalName` is required, not optional.

✅ **The popup renders the same `lib-trace-panel`**, in a `modal-body … h-70`. It draws **no chart of
its own** and owns **no canvas** — one component, at two sizes, so the two traces cannot drift.

⚠ **The enlarged panel hides its own maximise button by simply not being given a `maximizeLabel`.**
The control is behind `@if (maximizeLabel())`, so withholding the input withholds the button — there
is no separate flag, and adding one would be a second source of truth.

⛔ **Do not do it by expanding the panel in place.** Toggling `col-6` → `col-12` behind an `@if`
**destroys the other panel's DOM**, and Angular builds a *new* canvas element when it comes back —
while the held `Chart` instance still points at the old, detached one. **The restored graph renders
blank.** That bug is why this rule exists.

The popup keeps the inline panels mounted throughout, so nothing is destroyed and nothing to
re-attach.

⚠ **ESC and backdrop-click do not restore, and that is deliberate.** `CommonPopupService` opens
every modal with `backdrop: 'static'` and `keyboard: false`, which `[VAL §7.5]` requires. Where a
story's acceptance criteria ask for ESC-to-restore, **the criterion and that rule conflict** — settle
it in the story rather than changing the popup service (`FW-081`).

### 3.14a `Chart.register` belongs with the config builder, not in a screen

A popup that draws its own chart runs in its own module context. If registration sits at the top of
one component, the popup fails with **`"linear" is not a registered scale`**.

⚠ **And it cannot sit at module scope in a `.model.ts`** — `padding-line-between-statements` forbids
a blank line after an `expression` *and* after a `block-like`, while `jsdoc/lines-before-block`
requires one before the exported function's JSDoc. That is a genuine deadlock. **Put the call as the
first line inside the builder** — `Chart.register` is idempotent, so the cost is nothing:

```typescript
export function buildTraceConfig(panel: TracePanel): ChartConfiguration {
  Chart.register(annotationPlugin, ...registerables);
```

⚠ **The builder is shared, and its only caller is `lib-trace-panel`** — `buildTraceConfig` lives at
`projects/shared/src/lib/models/trace-chart/trace-chart.model.ts` and is reached through the panel's
`config` computed. **Neither the screen nor the popup calls it**, which is what makes it impossible
for the inline trace and the maximised one to drift.

### 3.15 No method calls in template interpolation

Compute into a field and refresh it when the state changes. With `OnPush`, inject `ChangeDetectorRef`
and call `detectChanges()` after mutating state.

---

### 3.16 A notification card is fixed to the corner and is never modal

`spool_notification.js`'s card is an **advisory**, not a decision the operator has to clear. It has
**no backdrop and no focus trap** — every control behind it stays operable while it is up. It is
raised at a milestone, and it must **escalate in place**: a second milestone re-dresses the same card
rather than stacking a second one.

⚠ **Escalation is not built.** The card renders at one fixed placeholder percentage, resolved once in
the constructor; nothing re-raises or re-dresses it. The **state machine** is `FW-202`'s — what
follows describes the card's look, which is built, not its behaviour, which is not.

**Acknowledge dismisses it to a compact pill**, which keeps the live figure visible without
alerting again. Do not use `CommonPopupService` for this — that is for modals (`[UIC §3.14]`), and
a modal would block the line.

**Its placement is `.floating-popover`** — the one class this build created (`[UIC §2]`). The
corner anchor, the 400 px width and the z-index are **not** inline bindings: every popover of this
shape wants the same geometry, and binding it per instance guarantees the next one diverges.
`.pill` is the collapsed form. Only genuinely per-instance numbers stay bound — the fill percentage
and the tick positions, which are data.

```html
<div class="floating-popover card border-0 shadow-lg" role="status" aria-live="polite" aria-atomic="false">
<div class="floating-popover pill d-inline-flex align-items-center …" role="status" aria-live="off">
```

`role="status"` with `aria-live="polite"` is what makes it advisory to a screen reader too; the
pill drops to `aria-live="off"` because it is no longer announcing anything.

**A ticked scale states its unit once, at the origin.** `75%  90%  100%` collides at 400 px wide —
the last two labels overlap however small the font goes, because they are only 10 % of the width
apart and the widest of them is the one at the edge. Drop the sign from the labels, let it be the
**axis unit** at `left: 0`, and set `fs-12`:

```html
<div class="floating-popover-scale fs-12 mb-2">
  <span>%</span>
  <span [style.left.%]="ticks.FIRST">{{ ticks.FIRST }}</span>
  <span [style.left.%]="ticks.SECOND">{{ ticks.SECOND }}</span>
  <span [style.left.%]="ticks.FULL">{{ ticks.FULL }}</span>
</div>
```

`.floating-popover-scale` centres each label on its own percentage and pulls the last one fully
inside the track, which is what makes them read as an axis instead of three spaced words.

⚠ **The bar carries the same two ticks a second time**, as `position-absolute top-0 bottom-0
border-start border-dark` rules drawn on the progress track at the same percentages — the labels sit
below the bar, the rules sit on it, and both read from one constant.

⚠ **That constant does double duty.** `SPOOL_SCALE_TICKS = { FIRST: 75, SECOND: 90, FULL: 100 }` is
both the scale's labels **and** the thresholds `resolveSpoolMilestone()` compares against (§3.19).
Changing a tick silently changes which milestone a reading lands in — that coupling is deliberate,
so the axis can never disagree with the accent.

---

### 3.17 ⛔ The screen has one theme, and it is the blue one

**The blue palette is final.** A light-theme demo toggle was built on the DB3 landing and has been
**removed** — the headers, header text, collapse chevrons, buttons and payoff progress bars are
back to fixed classes in the `class` attribute, bound to nothing:

| Element | Class |
|---|---|
| Card headers, context bar 1 | `bg-semi-dark-blue` |
| Header text and collapse chevrons | `text-white` |
| Content-area buttons — maximise, and the rail's | `bg-dark-subtle` |
| Payoff progress bars | `bg-semi-dark-blue` |

⛔ **Do not reintroduce a theme mechanism for a demo.** There is no `data-bs-theme`, no dark-mode
stylesheet anywhere in `src/styles/`, and no `THEME_CLASSES` constant — it was deleted with the
toggle. Anything conditional here is a binding that will never change value, and the review rules
call that a stale binding.

⛔ **There is no exception, and no theme input survives anywhere.** `SpoolNotificationComponent`
takes exactly two inputs — `reading` and `isAcknowledged`, both required. The `isLightTheme` input it
once carried was deleted with the toggle, so **nothing in the codebase can express a second theme**.
That is the strongest form of this rule: there is no mechanism to misuse.

⛔ **Badges were never part of it.** Their contrast follows their own background
(`[UIC §3.1]`), and the spool card's accent follows the fill (`[UIC §3.19]`) — neither is a theme
decision.

⚠ **If a swap is ever revisited, two things are already known.** `btn-outline-light` is unusable:
the app's `.btn` rule (§3.4) takes the label **white on `#343a40`** the moment the pointer touches
it, so a near-white button reads as light at rest and near-black under the cursor — the control
flickers between two identities. And the **trace popup would stay blue** — it is a separate component
with its own `modal-header`, outside any landing-scoped swap.

⛔ **One `[ngClass]` per element.** Merge a conditional class into the existing expression as an
array — a duplicate attribute fails `@html-eslint/no-duplicate-attrs`, and Angular templates have
no computed object keys. **Removing the theme re-broke this three times**, so it is worth knowing
in both directions.

---

### 3.18 A dot against anything live pulses — and only those

An operator glances at this screen. **A still dot and a stale dot look identical**, so every dot
standing for something live or time reflecting animates, and the rest hold still. The pulse is
**`.live-dot`** in `styles.scss` (`[UIC §2]`).

⛔ **Do not use Font Awesome's `fa-beat-fade` or `fa-beat` for a dot.** They were tried first and
look like nothing is happening — not because they fail (`fa-spin` animates fine elsewhere in this
application) but because their amplitude is built for a glyph, not a dot: `fa-beat-fade` scales
**1 → 1.125**, about **1.5 px** on a 12 px dot. `.live-dot` swings opacity `0.3 → 1` and scale
`1 → 1.4`, which is unmistakable at that size. It also restates `display: inline-block`, because
**`transform` is ignored on an inline element**.

⚠ **Under `prefers-reduced-motion` the scaling drops and the fade stays**, slowed to 2 s.
Liveness is *information* on a shop-floor screen, not decoration, so the signal is accommodated
rather than removed — which is also why the FA classes' own behaviour (kill the animation outright)
would have been wrong here.

| Dot | Pulses? | Why |
|---|---|---|
| A **running** line's state dot | ✅ | the line is producing right now |
| A **running** payoff | ✅ | rod is being consumed |
| The spool card's *Live · updated* footer | ✅ | it is asserting the reading is current |
| A **Live** badge on a context bar | ✅ | same claim — ⚠ **DB1's does not pulse and should.** It is a plain `fa-circle text-success` with no `live-dot`; **the code is wrong here, not this table.** Deferred to [`FW-060`](tasks/FW-060.md) with the height budget (§4.1), because DB1 is the last screen scheduled |
| Idle / offline line, idle payoff | ⛔ | a settled state, not a live one |
| **In spec / out of spec** on a trace | ⛔ | a measurement **verdict**. A pulsing verdict reads as "measuring", which is a different claim |
| Component and die settings | ⛔ | configuration |

⛔ **Do not reach for the line-state map to get a coloured dot.** `LINE_STATE_ICONS[Running]`
carries the pulse, so borrowing it for a non-live verdict animates something that should be still —
the trace panels did exactly that and were corrected. `IN_SPEC_DOT_ICON` is the still green dot;
`LIVE_DOT_ICON` is the pulsing one. Name what you mean.

---

### 3.19 The spool card's accent escalates with the fill

**One value drives three elements**, so they cannot disagree: the bell icon, the progress bar and
the acknowledge button all read the accent for the milestone the fill resolves to. The accent itself
is two fields — `{ bar, button }` — with the bell badge and the button sharing `button`.

| Fill | Milestone | Accent |
|---|---|---|
| below 90 % | `Info` | `bg-semi-dark-blue` |
| 90 % to just under target | `Warn` | `bg-warning` |
| exactly on target | `Success` | `bg-success` |
| past target | `Danger` | `bg-danger` |

⛔ **The milestone is derived, never hard-coded.** `resolveSpoolMilestone(percentComplete)` in
`components/flat-wire-landing/` owns the ladder; a screen that sets the milestone directly will disagree
with its own progress bar the moment the fill moves.

⛔ **A model function is called directly — never wrapped in a public component method.** The landing
calls `resolveSpoolMilestone(percent)` straight from its constructor. A pass-through
`public getTraceConfig(panel)` was written first and **removed in review**: it existed only so a spec
could reach it, and the standards forbid widening visibility for tests (*"test coverage for internal
logic must come through the public caller"*).

⚠ **Spec an exported function in its own co-located spec, not in the caller's.** Each of these has
one, and `describe` takes the exact function name:

| Function | Lives in | Spec |
|---|---|---|
| `resolveSpoolMilestone` | `projects/flat-wire/…/components/flat-wire-landing/spool-milestone.model.ts` | `spool-milestone.model.spec.ts` — `describe('resolveSpoolMilestone')` |
| `buildTraceConfig` | `projects/shared/…/models/trace-chart/trace-chart.model.ts` | `trace-chart.model.spec.ts` — `describe('buildTraceConfig')` |

⚠ **`buildTraceConfig` has no screen-level caller at all** — `lib-trace-panel` reaches it through a
`computed`. A screen that calls it directly has bypassed the panel and will drift from the popup.

⚠ **Extracting to a co-located model is also how a coverage gate gets met honestly.** The milestone
ladder began as a private method on the landing, where two of its branches were unreachable and the
95 % gate failed; exported from its own file it is reachable, and the ladder is tested at 73 / 90 /
100 / 104 against literals rather than against the constant it compares.

⚠ The accent **replaces the button's own background**: the milestone is the more important signal.
The button is `bigger fw-bold`, which keeps its label legible on all four accents — `bg-success` is
the tightest — and on hover the app's `.btn` rule takes it white on `#343a40` (§3.4).

---

### 3.20 What the standards review caught, so the next screen does not repeat it

The reference screen was reviewed against `.claude/code-review-guidelines/` and
`.claude/instructions/` after it was built. **`ng lint` passed throughout** — every finding below is
a convention ESLint cannot check, which is exactly why they are worth listing.

| Caught | Rule |
|---|---|
| `@param panel the trace panel being opened` | `@param` takes **the type, not prose** — `@param panel TracePanel`. Seven of these |
| A `public` pass-through to a model, present only so a spec could call it | Visibility is never widened for tests (§3.19) |
| `component.ngAfterViewInit()` called from two specs | Lifecycle hooks are triggered by `fixture.detectChanges()`, never called by hand. ✅ **The live form of this**: cover a *"no chart yet"* branch with a **second fixture that is never `detectChanges()`d**, so its view — and its chart — is never built |
| `const mock: TracePanel = { … }` | Spec mocks take the **angle-bracket** form, `<TracePanel>{ … }` |
| `expect(x).toBe(NAV_RAIL_WIDTH.EXPANDED)` | Assert the **literal** — `toBe(240)`. A constant on both sides passes even when the constant is wrong |
| `/* Placeholder data until FW-132 … */` | Placeholder comments carry **`TODO:`**; without it the code reads as finished. ⚠ **Currently unmet** — the two screens carry placeholder data in every builder and **not one `TODO:`** |
| `SpoolReading.milestone` / `.iconClass` | Dead code — written and never read. Cross-check the `.html` too, and remember **a test is not a consumer**. ⚠ **A tone map is live again** as `SPOOL_MILESTONE_TONES` → `reading().toneClass`; what was dead was a field nothing but its own test read, not the idea |
| `private cd: ChangeDetectorRef` | No unclear abbreviations — `changeDetectorRef`, as the other screen already had |
| `COMPLETE SPOOL` with no icon | **Every** button carries a semantically matched `fa-solid` icon before the label — ⚠ **except an icon-only button** with no text at all, like `lib-trace-panel`'s maximise |

⚠ **Two guideline items are deliberately not followed, and both are recorded rather than fixed.**

1. **Raw `<table>` instead of `lib-static-grid`** — `template.md` requires the grid component for
   read-only tabular data. **`D-06` forbids it here** and `FW-163` owns the eventual shared
   `info-grid` (§1). The deviation is the decision, not an oversight.
2. **`readonly` is not applied to injected services or built-once data fields.** The standards
   suggest it; the repository does not do it — **263 components declare `private x = inject(…)`
   against 5 that add `readonly`** — and matching the surrounding code wins over a lone island of
   a different idiom.
   ⚠ **This is not the same rule as signal members.** **Every** `input()`, `output()`, `viewChild()`,
   `viewChildren()` and `computed()` **is** declared `public readonly` / `private readonly`, in all
   three shared components and in `spool-notification`. The exception above covers injected services
   and built-once data fields only.

⛔ **A field with a deliberate initial state is assigned in the constructor — do not "fix" it to `!`.**
`isExpanded = false` on `lib-nav-rail` reads as a redundant zero-value assignment, and removing it in
favour of `isExpanded!: boolean` **broke two tests**: an unassigned class field is `undefined`, not
`false`. The `!` exception is for fields with **no meaningful default**; a rail that starts collapsed
is a deliberate initial state.

⚠ **The rule now lives in `projects/shared`, not on the screen** — the field moved with the rail.
And it is currently broken in the other direction: `flat-wire-landing` declares
`public isSpoolAcknowledged!: boolean;` for a card that plainly starts un-acknowledged. **That is the
`!` form this rule warns against**, and it should be an assignment.

---

### 3.21 The second standards pass — what a green `ng lint` still hides

A second review after the screen was finished found **more** than the first, with `ng lint` and
`stylelint` reporting **zero errors throughout**. Grouped by why they were missed:

| Category | Found | The lesson |
|---|---|---|
| **Dead code** | `SpoolAccent.icon`, `RunHeader.state`, `Payoff.isRunning`, `FlatWireLine.state`, `TRACE_STYLE.CANVAS_HEIGHT`/`CANVAS_WIDTH`, `FormsModule`/`ReactiveFormsModule` in the module, 4 content-data keys | A property that is **written but never read** is dead. Cross-check against the `.html` too, and remember **a test is not a consumer** |
| **Redundant tests** | 7 removed. Pairs calling the same method the same number of times, differing only in the property asserted | Asserting a different property does not make a test distinct |
| **Fabricated names** | `describe('SpoolMilestoneModel')` and `describe('TraceChartModel')` named symbols that exist **nowhere** | The outermost `describe` is the exact exported symbol. `chart-util.model.spec.ts` is the precedent — a plain function gets a `describe` named exactly that function |
| **Memory leaks** | Chart.js instances survived component teardown on both the landing and the popup — the popup leaked one per open | Anything holding native resources is released in `destroyRef.onDestroy()`. ✅ **Structurally solved since**: neither screen holds a `Chart` at all, and there is exactly **one** `destroyRef.onDestroy(() => this.releaseChart())` in the codebase, inside `lib-chart-canvas` |
| **Buttons** | 4 labels without `\| uppercase`, 1 with no Font Awesome icon | Every button: `id` + icon before the label + `\| uppercase` |
| **Assertions** | Tests asserting `NAV_RAIL_WIDTH.COLLAPSED` rather than `60` | The rail width later changed 75 → 60. Literal assertions **caught it**; constant-on-both-sides would have passed silently |

⚠ **This is why the rules are injected, not remembered.** A `PreToolUse` hook in `UALUADEV`
(`.claude/hooks/inject-rules.cjs`) now pushes the matching rule digest into context on every file
write, because "read the instruction file first" was advisory and was skipped every time.

---

### 3.22 ✅ The rail and the chart are components now — bind, do not rewrite

§3.5, §3.6, §3.10, §3.11 and §3.11a describe markup that has been **extracted into
`projects/shared`**. They remain the record of *why* each rule exists; the components are how you
now obey them.

| Instead of | Use |
|---|---|
| ~40 lines of rail markup + a width field + a toggle method | `<lib-nav-rail [items] [screenKey] [toggleLabel] [iconMap] [toggleIconClass] [areItemsDisabled] [collapsedWidth] [expandedWidth] (itemClick) (expandedChange) />` |
| a `<canvas>`, a `Chart` field, a resize listener and a destroy-rebuild method | `<lib-chart-canvas [config] [isLive] />`, plus its public `resize()` |
| the header, canvas and statistics of a trace | `<lib-trace-panel [panel] [maximizeLabel] [isLive] (maximize) />`, plus its public `resize()` |

⚠ **`screenKey` is not optional in practice.** Every button id is `btn-{item-key}-{screenKey}` and
the toggle is `btn-hamburger-menu-{screenKey}`; leave it unbound and every id on the rail collapses
to a `-` suffix, colliding with the next screen's. Both flat wire screens bind it.

⚠ **`iconMap` and `iconClass` are alternatives, not partners.** An item's own `iconClass` wins; the
map is the fallback for a data source that carries labels but no icons — which is how
`slitter-traveler-landing` dresses its store entries. **An entry in neither renders no icon at all**,
deliberately, rather than a broken `fa-solid undefined`.

⚠ **`<ng-content />` projects between the toggle and the items**, for a control that belongs on the
rail but is not a data-driven entry.

⚠ **Two levels decide whether an entry is clickable, and the screen's outranks the entry's.** An
entry carries its own `isActive`; the screen carries **`areItemsDisabled`**, a gate that withholds
**every** entry whatever each one says about itself — for a precondition the entry knows nothing
about. `slitter-traveler-landing` binds it to *"this terminal has no station assigned"*, and it is
deliberately generic so the next reason (no operator signed in, a blocking dialog open) needs no new
input. **The toggle stays usable**, so a withheld rail can still be collapsed for space.

⛔ **The gate is presentation-only.** `itemClick` still emits the entry exactly as the screen handed
it over, so a screen never has to reconstruct what it passed in.

⚠ **Neither flat wire screen binds `(itemClick)` yet** — every entry is inert until the dialog it
opens exists. Slitter binds it, and maps the emitted `NavRailItem` back to its own store entry by
`textToShow`.

**What the components now guarantee, so no screen re-derives it:** the px width binding that keeps
the 250 ms collapse animating (§3.10) · the canvas that fills its box without adding height to it
(§3.11) · the buffer that follows the box on window resize · **destroy-before-rebuild**, so a
collapsed section's graph comes back (§3.11a) · release on teardown.

⛔ **Two things a screen still owns.** A rail collapse changes the content width, so the screen
resizes its panels — bind `(expandedChange)` to that. And **maximise still opens a popup** (§3.14);
the popup simply renders the same `lib-trace-panel` at a larger size, which is what stops the two
drifting apart.

⚠ **`lib-chart-canvas` owns sizing, so pass it `responsive: false`.** Chart.js's own responsive mode
needs a `ResizeObserver`, which jsdom does not provide — a responsive chart cannot even be
constructed in a spec, quite apart from the documented worker crash at teardown.

⚠ **A spec for a screen that uses these must *declare* them, not stub them.** `NO_ERRORS_SCHEMA`
alone leaves `viewChildren(TracePanelComponent)` finding nothing, so a resize test passes vacuously:

```typescript
declarations: [FlatWireLandingComponent, TracePanelComponent, ChartCanvasComponent]
```

That is also why the spec needs `import 'jest-canvas-mock';` — declaring them means really rendering
a canvas (§3.8).

⚠ **`NavRailItem` is deliberately a structural subset of `shop-floor-common`'s `HamburgerMenuItems`.**
Its three required members — `isActive`, `textToShow` and nothing else — all exist on the store's
shape, which is why `slitter-traveler-landing` passes
`[items]="shopFloorCommonStateStoreService.hamburgerMenuItems()"` **straight in, with no mapping and
no computed signal**, and the same API is fed by hand-built arrays on flat wire. ⛔ **Any field added
to `NavRailItem` must stay optional**, or slitter stops compiling.

⚠ **The rail derives its key; you supply a label.** There is no `key` on `NavRailItem` — the rail
lower-cases `textToShow` and joins on `-`. So a label must be **space-separated words**: `Spool
Queue` gives `btn-spool-queue-…`, while a camelCase label gives a camelCase id.

⚠ **A key you *do* supply must be kebab-case.** `TracePanel.key` is stamped into
`btn-maximize-{key}-trace-panel` and an info table's key into `act-{key}-flat-wire-landing`, which is
why `INFO_KEYS` reads `rod-information` / `order-information`.

⚠ **Three rail behaviours are hard-coded and have no inputs** — labels are always `| uppercase`,
icons are always `fa-2x`, and expanded labels are always `extra-big fs-15`. The switches for these
existed briefly and were **removed deliberately**: the client runs 1080p, and per-screen variation
was drift, not flexibility.

---

## 4. Page composition at 1920 × 1080

**1920 × 1080 at 100 % scaling is 16:9.** The mockups are 5:4 — their composition does not carry
over, only their content (`F-15`).

**Spend the extra 640 px on columns, not on stretching.** The two built screens share a skeleton and
differ below the context bar — ⚠ **§1 names DB3 as the screen to copy**, so read that column first:

| Region | **DB3** — Active Run Monitor *(the reference)* | **DB1** — Line Status |
|---|---|---|
| **Left nav rail** | `<lib-nav-rail>`, collapsible, entries for unbuilt screens **inert not absent** | same |
| **Context bar 1** | `d-flex … bg-semi-dark-blue border-bottom px-2 py-1 mb-2 rounded-2` with `bg-dark-subtle rounded px-3 py-2` chips | same, at `py-2` |
| **Context bar 2** | three `col-4` **cards** — Machine · Payoffs · Components | `row g-2` of `bg-white rounded-2` stat tiles; the wide ones carry a `progress` bar |
| **Content** | two collapsible info tables, then a Traces card holding `col-6` trace panels | `row g-2` of `col-4` line cards — **no fixed width** |
| **Bottom** | ⛔ none — DB3's alerting is the corner `<lib-spool-notification>` (§3.16), outside the layout | a card holding `alert alert-warning` / `alert-success` rows |

⚠ **Card headers are `py-1` on DB3 and `py-2` on DB1.** DB3 is the tighter budget because it carries
the traces; follow the screen you are nearest to.

**Card idiom** — `scaffold-form` §8's structure in `slitter-traveler-landing`'s colours:

```html
<div class="card border-0 shadow-sm h-100">
  <div class="card-header bg-semi-dark-blue border-bottom py-2 d-flex align-items-center justify-content-between">
    <div class="d-flex align-items-center">
      <span class="badge bg-secondary me-2 p-2"><i class="fa-solid fa-industry text-warning fa-2x"></i></span>
      <span class="fw-bold fs-5 text-white">{{ title }}</span>
    </div>
  </div>
  <div class="card-body p-2"></div>
</div>
```

---

### 4.1 ⛔ The screen budgets its height. It does not scale, and it does not scroll

**The mockups fit the window by scaling** — `flat-wire-fit.js` puts `overflow:hidden` on `<html>`
and a `transform:scale()` on `<body>`, recomputed on every resize. ⛔ **Do not port this.**

| Why not | |
|---|---|
| It can only ever shrink | `Math.min(1, vh / designH, vw / DESIGN_W)` never exceeds 1:1, so it cannot help legibility — only hurt it. The script itself fights this back with a `MIN_FONT = 14` floor and per-axis label re-growing |
| It solves a problem this application does not have | Its own header says why it exists: the mockups are a **fixed 1280 × 1024 panel** and a normal browser window is 600-950 px tall, so without it they need F11. It is a preview affordance. Our screens are fluid |
| `vh` does not see a transform | The `h-*` classes are **vh**. The mockup had to publish `--fw-page-scale` and divide by it everywhere; we would inherit that tax |
| Our charts would blur | Chart.js draws to `<canvas>`, which rasterises at its buffer size and *then* gets scaled. DB3's mockup has **13 `<svg>` and 0 `<canvas>`** — SVG does not blur, ours would |
| `position: fixed` stops meaning the viewport | A transformed ancestor becomes the containing block, so `.floating-popover` (§3.16) drifts off its corner |
| Modals and drag break | The mockup needed `FwModal.fitOpen()` to re-fit open dialogs, and `cdkDrag` misreports pointer deltas under a scale |

**What the mockup actually gets right is the *budget*, not the scale.** `.dashboard` is
`height: 1024px; overflow: hidden` and each section gets a **slice** — `.traces-tab-content` is a
flat `height: 440px`. The scale is applied to an already-fitted box, afterwards.

**So budget the height with flexbox and let one region absorb the slack.** The screen is:

```html
<div class="h-91 bg-body-secondary p-1 overflow-hidden">
  <div class="d-flex align-items-stretch h-100">
    <lib-nav-rail (expandedChange)="resizeTraces()" [items]="navActions" [screenKey]="screenKey" … />
    <div class="text-start menu-content flex-grow-1 min-w-0 px-1 d-flex flex-column h-100">
      <div class="… context bar … flex-shrink-0">
      <div class="row g-2 mb-2 flex-shrink-0">              <!-- the card strip -->
      <div class="flex-grow-1 min-h-0 d-flex flex-column">  <!-- tables + traces: the slack -->
```

| Rule | Why |
|---|---|
| `align-items-stretch h-100` on the rail/content row | gives the column below it a **definite** height to divide. Without it the column is content-height and there is nothing to budget |
| `flex-shrink-0` on the rail, the context bar and the card strip | these are fixed cost. A compressed card strip is unreadable |
| `flex-grow-1 min-h-0` on the tables + traces region | **`min-h-0` is what makes it work.** A flex item defaults to `min-height:auto` and refuses to shrink below its content, so without it the region pushes the column past the box |
| the chain continues **into** the traces card | the region is itself a column: the info tables are `flex-shrink-0`, the traces card takes the remainder, and its body → row → column → panel pass the height down to the canvas box (§3.11). **Stopping the chain at the region is not enough** — a fixed-height canvas inside it still overflows. ⚠ **Its last two links are host classes on `lib-trace-panel` and `lib-chart-canvas`**, not classes in your template (§3.11) |
| `overflow-hidden` on the outer box | **decided: this screen does not scroll.** Every region either has a fixed cost or derives its height, so there is nothing left to scroll. ⚠ The trade is that a window too short for the *fixed* regions alone clips them silently rather than showing a scrollbar — acceptable, because the derived regions give way first |

⚠ **`min-w-0` did not exist when this screen was first built** (`§2`), which is the other half of
the same bug: `.menu-content` is `flex-grow-1 min-w-0`, and with the class absent the `text-nowrap`
info tables forced the row wider than the viewport — **a horizontal scrollbar at every resolution,
fullscreen included**. It was defined as part of this work.

**Below 1920 wide**, reflow with breakpoints — `col-4` → `col-md-6` → `col-12`, traces stacking —
never by scaling. **99 of 315 component templates in this repository already use a responsive column
prefix**, so the idiom is established. ⛔ **No page-level `transform: scale` exists anywhere in the
application** — the only `transform: scale` in `src/styles/` sizes shop-floor checkboxes and drives
the `live-dot` keyframes, neither of which transforms a page.

⚠ **`supervisor-dashboard` does not follow this section, and that is a scheduled deferral, not an
oversight.** It is `h-91 overflow-auto` with `align-items-start` and no height budget, which is the
shape this section replaced. **DB1 is the last screen scheduled**, so it is reconciled as part of
[`FW-060`](tasks/FW-060.md) rather than now. ⛔ **Until then, copy DB3's budget — never DB1's
layout.**

---

## 5. Keeping this file true

- **A screen is built → update its story plan**, in the same pass: what was built, **what was
  skipped**, and any class that had to be created. A plan left saying *"not started"* over a built
  screen is how the next developer rebuilds it.
- **Say plainly what is skeleton and what is behaviour.** *"The screen renders"* and *"the screen
  works"* are different claims, and only the first is currently true of either flat wire screen.
- **A new UI rule is learned while building a screen → add it to §3**, with the measurement behind it.
- **A new class is genuinely created → add it to §2** and name the story that created it.
- ⚠ **Markup that becomes a shared component → rewrite the section that described it**, from *write
  this* to *consume this*, **keeping the reason**. The reasons are what stop the next developer
  reintroducing the bug the rule was written for; the markup is not.
- ⛔ **Every number in this file is a measurement, so re-measure before repeating one.** Class counts,
  widths, icon sizes and "N of M templates" figures have all been wrong here at some point, and each
  looked authoritative while it was.
- **This file loses to `[CMP]` and `[VAL]`.** Where it and a specification disagree, the specification
  wins and this file is corrected up to it.
- Per repository convention, changes go in [`../CHANGELOG.md`](../CHANGELOG.md) — **do not add a
  change log here.**
