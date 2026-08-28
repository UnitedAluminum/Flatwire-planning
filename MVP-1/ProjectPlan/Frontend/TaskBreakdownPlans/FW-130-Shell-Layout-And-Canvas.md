# FW-130 · Shell layout and the 1920 × 1080 shopfloor canvas

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 28, 2026 — ⚠ **The Mockups folder is 38 files / 19 HTML** — `dashboard_3_active_run_ual.html`, a **styling comparison build** (DB3 in the host app’s CSS at 1920×1080) plus five generated assets. The folder is still **flat**. Counts and the "composed for 5:4" statements updated — **18 of 19**, not all 19. Earlier: August 28, 2026 — ⛔ **REVIEWED against the built library, and step 2 carried a factual error that would have cost real time.** This plan said the mockups' stylesheet *"carries `/* stylelint-disable */` at the top"*. **It does not** — `F-03` is the decision that the shipped copy *shall*, so **adding it is the developer's job and the order matters**: measured, the file yields **856 stylelint errors**, `npm run lint:styles` runs with **`--fix`**, and one un-disabled run **rewrites the file 29,788 → 30,406 bytes and still leaves 64 errors** (55 `color-no-hex`); prepending the comment gives **zero**. ⛔ **Three further conflicts with `[CMP §7.4]`'s *"consume as-is"* are now named** — the sheet is **14 sections, not a token file**, §2/§3 **hard-code the old 1280 canvas** inside the story whose subject is 1920, §13 is the **retired** progress ring, and it declares **138 bare global selectors including `.btn`**, which collides with Bootstrap for the whole application (the precedent `shop-floor-common.styles.scss` declares **one**). New **§2a/§2b/§2c** carry the measurements and three costed options. ⚠ **New §1a**: `FW-N03` shipped **four routes rendering a placeholder with no shell**, so this story **becomes their parent** and deletes the placeholder. ⚠ **New §1b**: `[CMP §7.4]`'s reason for `ViewEncapsulation.None` — *"so the tokens resolve"* — **does not hold** (custom properties inherit regardless), and choosing it would leak those 138 selectors; use `:host`. New **step 7** carries the two lint traps `FW-N03` hit. Earlier the same day: ✅ **`FW-N03` landed 28 Aug 2026, so this story is unblocked**; ⛔ its §6.4 records that **`npm start` cannot run in this checkout** (`flexmonster` missing, [`P1A §6.15`](Phase-01A-ImplementationPlan.md)), so the browser-side half of this plan's verification is deferred. Earlier the same day: **refreshed against the measured repository.** ⚠ The `[TCS]` suite holds **405 defined cases**, not 799 — `TC-799` is the highest *id*, and 47 ids are cited but never defined; the finding that **no case covers Phase 1A** is unchanged. Restored the card's **Rate-card basis** line (16 h is a discounted 20 h — the tokens are consumed, not authored), which this plan had dropped. Earlier the same day: gained a **Depends on / Unblocks** header line, and a **Test cases** row in Verification. Written 27 Aug 2026 as one of the nine plans `Phase-01A-ImplementationPlan.md` was divided into
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **Buildable now — `FW-N03` landed 28 Aug 2026** (wave 1). ⚠ The app `styles` array slot is empty and waiting for this story's stylesheet; `FlatWirePlaceholderComponent` is the temporary landing component **this story replaces with the shell**
**Owner:** Frontend (Angular) stream
**Audience:** The Angular developer building `FW-130`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Depends on:** [`FW-N03`](FW-N03-Angular-Library-Scaffold.md)
**Unblocks:** [`FW-133`](FW-133-Shared-Composite-Controls.md) · [`FW-134`](FW-134-Shared-Primitive-Controls.md) — **for the tokens only**
**Part of:** `ProjectPlan/Frontend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md) · shared context: [Phase-01A-ImplementationPlan.md](Phase-01A-ImplementationPlan.md)

---

> **Read [`[P1A §2]`](Phase-01A-ImplementationPlan.md) first.** Decisions this story rests on:
> **`F-03`** (the token stylesheet and stylelint), **`F-14`** (the canvas), **`F-15`** (what the
> mockups are and are not authoritative for).
>
> **This story is on the critical path.** `FW-N03 → FW-130 → FW-133` is the 160 h path, and
> `FW-133` cannot start without this story's tokens.
>
> This plan is derived from the specifications and **loses to every one of them.**

---

## 1. The story

From `[TB §7]`:

> ###### FW-130 · Shell layout and the 1280×1024 shopfloor canvas
> **Hours:** 16 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE
>
> **As an** operator,
> **I want** a consistent shell with header, navigation and an alert slot on a fixed shopfloor canvas,
> **So that** every dashboard renders identically on the panel at arm's length.
>
> **Acceptance Criteria:**
> - [ ] Shell layout component: header (line context + operator + clock), sidebar nav to all dashboards, `alert-banner` slot
> - [ ] Fixed **1280×1024** canvas; renders in both light and `prefers-color-scheme: dark`
> - [ ] Consumes the existing semantic design-token system in `../Mockups/flat-wire-shopfloor.styles.scss` **as-is**
> - [ ] **No `--fw-*` token appears anywhere** — that prefix is stale (**G18**)
> - [ ] Minimum text size **14px** throughout, including form controls
>
> **Rate-card basis:** shared composite control 20 h, **discounted to 16 h — the token system is consumed, not authored**
> **Dependencies:** FW-N03
> **Blockers:** **G18** · **G23**

⚠ **The canvas criterion is superseded.** `F-14` sets **1920 × 1080**, which decides `G23`. The
figure in the card above and in `phase-01a` is the old one; `[VAL §7.5]` — the row every other
document derives from — was corrected on 27 Aug 2026.

### 1.1 In scope

Shell component · the token stylesheet in the library and in the app `styles` array · the canvas ·
global-CSS containment · the 14 px floor · dark mode.

### 1.2 Out of scope

| Not here | Owner |
|---|---|
| Any control the shell hosts | `FW-133` / `FW-134` |
| `alert-banner` itself — this story provides the **slot** | [`FW-134`](FW-134-Shared-Primitive-Controls.md) |
| The scale-to-window behaviour (`flat-wire-fit.js`'s Angular equivalent) | ⛔ **no story owns it** — `[P1A §6.3]` |
| Sidebar *targets* for screens not yet built | the phase-3+ screen stories |
| Re-scoping the mockup stylesheet's 138 bare global selectors | ⛔ **nobody — raised in §3 step 2c**, and it is bigger than this story |

---

## 2. The canvas — a change of shape, not of size

| | was | **now** | change |
|---|---|---|---|
| Width | 1280 | **1920** | **+640 px · ×1.50** |
| Height | 1024 | **1080** | **+56 px · ×1.05** |
| Aspect | 5:4 (1.25) | **16:9 (1.78)** | **the shape changes** |

**Six rules, and the first is the one that gets missed.**

1. ⚠ **The re-layout is horizontal. Nothing gets taller.** +56 px is one row of 14 px type with its padding, so **every vertically-constrained decision stays constrained** — including `[VAL §7.5]`'s sub-14 px exception for axis labels on `dashboard_3_active_run` / `_fl2` / `_fl3`. **1080 does not relieve the chart compression.**
2. **Spend the width on columns, not on stretching.** A 1280-composed panel widened to 1920 has 640 px of slack; filling it by scaling turns 14 px type into 21 px and a dense screen into a sparse one. Two columns → three; stacked → side by side.
3. **The 14 px floor and ≥ 48 px tap targets are physical rules** — `[VAL §7.5]` derives both from reading at arm's length with gloves, so they track **dpi, not resolution**. `F-14` carries them forward on a stated assumption: the new panel is **physically larger** of the same dpi class. ⚠ **If it is the same panel at higher density, every size scales ×1.5 and the floor becomes 21 px.** The diagonal is recorded nowhere — `[P1A §6.10]`.
4. **Fixed canvas, not responsive.** One target box, centred, letterboxed below it. It is a panel, not a browser.
5. ⚠ **You will not see it 1:1 while building it.** A 1920 × 1080 laptop loses ~100 px of height to browser chrome. The Angular scale-to-fit that would solve this **has no owner** (`[P1A §6.3]`) — until it does, review at reduced zoom and check type sizes against a rendered 1:1 reference.
6. **The mockups remain authoritative for content, not composition** (`F-15`). **18 of the 19 are laid out for 5:4.** ⚠ The exception is [`../Mockups/dashboard_3_active_run_ual.html`](../Mockups/dashboard_3_active_run_ual.html) (28 Aug 2026) — DB3 composed for **1920×1080** in the host app’s CSS. **It is a comparison build, not a design authority**, but it is the only existing rendering of a flat wire screen at this canvas, so **read it before composing the shell.** Three things it establishes by measurement: a **two-column split** (traces left in `col-8`, state rail right in `col-4`) is what spends the width without stretching; the app’s CSS needs a **35-token shim plus explicit 14 px containment** (§2a–§2c, `[P1A §6.16]`); and ⚠ **Bootstrap’s `.badge` renders at 10.5 px and the app forces every `.btn` to `#343a40` with a cyan icon on hover, both with `!important`** — neither is obvious until a screen is built on it.

---

## 3. Build order

### Step 1 — the shell component

| Region | Content |
|---|---|
| Header | line context (FL1/FL2/FL3) · operator · clock |
| Sidebar | nav to the MVP-1 dashboards; entries for unbuilt screens are inert, not absent |
| Body | `<router-outlet>` on the canvas |
| Alert slot | a named slot `FW-134`'s `alert-banner` projects into |

`ChangeDetectionStrategy.OnPush`.

#### 1a. ⚠ You are replacing something that already exists — `FW-N03` shipped a placeholder

**Measured in the checkout after `FW-N03` landed (28 Aug 2026):**
`flat-wire-routing.module.ts` declares **four routes — `''`, `line/:lineId/checkin/rod`,
`line/FL2/checkin/spool`, `line/:lineId/run/active` — and *all four* render
`FlatWirePlaceholderComponent` directly, with no shell around them.** That was deliberate: `[TB §7]`'s
AC 4 needs routes that *resolve*, and the screen components belong to Phase-3+ stories
([`FW-N03 §6.3`](FW-N03-Angular-Library-Scaffold.md)).

**So this story does not add a component beside the routes — it becomes their parent.** Restructure to
a shell-as-layout route with children, which is what makes one `<router-outlet>` serve every screen:

```typescript
export const FLAT_WIRE_ROUTES: Routes = [
  { path: '', component: FlatWireShellComponent,
    canActivate: [FlatWireAuthGuard],
    data: { resolveData: ['flat-wire', 'shared'] },
    resolve: { contentData: ContentDataService },
    children: [ /* the four paths above, minus their own guard/resolve */ ] }
];
```

**Three tidy-ups that belong to this story, not to a later one:**

1. **Delete `FlatWirePlaceholderComponent`** — the `.ts`, `.html` and `.spec.ts` — and drop it from `FlatWireModule`'s `declarations`/`exports` and from `public-api.ts`. ⚠ **It is exported today**, so removing it is a public-API change; nothing outside the library consumes it yet.
2. **Remove `projects/flat-wire/src/lib/styles/.gitkeep`** when the stylesheet of step 2 lands — the folder is no longer empty.
3. ⚠ **The shell component needs a spec on the day it is written.** `collectCoverageFrom` globs `*.component.ts` and the gate is **95 %** (`F-08`); `FW-N03` hit exactly this — its first suite run failed at **36 %** because a guard stub had no spec ([`FW-N03 §6.2`](FW-N03-Angular-Library-Scaffold.md) item 6).

#### 1b. ⚠ Prefer `:host` over `ViewEncapsulation.None`, and know why the spec offers both

`[CMP §7.4]` says *"`ViewEncapsulation.None` or `:host` scoping **so the tokens resolve**."* ⚠ **The
stated reason does not hold, and picking the first option because of it is actively harmful.** CSS
custom properties are **inherited** — Angular's emulated encapsulation adds attribute selectors to
component styles and creates no style boundary, and custom properties pierce even a real shadow
boundary by design. **`var(--color-*)` resolves under the default encapsulation with nothing switched
off.**

⚠ **What `ViewEncapsulation.None` would actually do here is leak step 2c's 138 bare global selectors
out of the shell into every UAL module in the app.** Use **`:host`**, which `[CMP §7.4]` permits
equally. **This plan does not overrule `[CMP]`** — the reason attached to the choice is raised for it
to correct; the choice itself is already this plan's to make.

### Step 2 — the token stylesheet

Copy the mockups' **`flat-wire-shopfloor.styles.scss`** (which keeps its own name, `F-13`) to:

```
projects/flat-wire/src/lib/styles/flat-wire.styles.scss
```

and register it in `angular.json`'s app `styles` array — the slot `FW-N03` left empty. ✅ **Verified
28 Aug 2026: the array holds no flat-wire entry**, and the precedent
`projects/shop-floor-common/src/lib/styles/shop-floor-common.styles.scss` **is** already there.

#### 2a. ⛔ Add `/* stylelint-disable */` FIRST — the file does not carry it, and the order matters

⚠ **This plan said *"It carries `/* stylelint-disable */` at the top"* until 28 Aug 2026. It does
not.** `F-03` is the decision that the shipped copy *shall* carry it — **adding it is your job**, and
doing it before the first lint run is not a formality. Measured against the repo's
`stylelint.config.mjs`:

| Run | Result |
|---|---|
| the file as it stands | ⛔ **856 errors** |
| ⚠ after `--fix` | **64 errors remain** — **55 `color-no-hex`**, plus `keyframes-name-pattern` and `declaration-property-value-disallowed-list` — and **the file is rewritten: 29,788 → 30,406 bytes** |
| ✅ with `/* stylelint-disable */` prepended | **zero errors**, file otherwise untouched |

⛔ **`npm run lint:styles` runs with `--fix`** — the script is
`stylelint "src/styles/**/*.scss" "projects/**/*.scss" --fix`. **So running it once on an
un-disabled copy reformats the stylesheet in ~700 places and still fails on the 64.** You would then
have a library copy that is neither lint-clean nor recognisable as the mockups' file, which breaks
*"consume as-is"* **and** AC 3's own proof. The precedents for suppressing are `src/styles/_colors.scss`
and `multi-grid-layout.scss`. **`em` units are not a factor — the stylesheet uses none.**

#### 2b. ⚠ It is not a token file — §1 is tokens and §2–§14 are base component styles

The file has **14 sections**. Only **§1** is the `:root` token block the acceptance criterion talks
about; **§2–§14** are working CSS for `.dashboard`, `.panel`, `.header`, `.btn`, `.field`, `.input`,
`.section-*`, `.callout`, `.footer`, badges, navigation and a schedule table. **Two consequences the
card does not anticipate:**

1. ⛔ **§2 and §3 hard-code the old canvas** — `body { min-width: 1280px }` (line 100) and
   `.dashboard { width: 1280px }` (line 113). **Copying "as-is" imports 1280 into the story whose whole
   subject is 1920** (`F-14`). Change these two declarations, and **record that you did** — it is the
   one place *"as-is"* and `F-14` are in direct conflict.
2. ⚠ **§13 is a Progress Ring, and that control is retired.** `FW-133` replaces it with `tolerance-viz`
   and says *"do not resurrect it."* Copying as-is imports dead CSS for a control no screen will use.

#### 2c. ⛔ 138 bare global selectors, and `.btn` collides with Bootstrap

**The single biggest thing this step does that nobody costed.** The stylesheet declares **138
top-level bare class selectors**, among them **`.btn`**, `.panel`, `.field`, `.input`, `.header`,
`.footer`. Registered in the app `styles` array it is a **global** sheet, in an application that
`@use`s **Bootstrap 5.3.8** in `src/styles/styles.scss` and hosts 30 other libraries. **`.btn` is
Bootstrap's own class**, so whichever loads later wins — for every module, not just flat wire.

⚠ **This is not the house pattern.** The precedent named above,
`shop-floor-common.styles.scss`, declares **exactly one** bare selector — `.order-info-iframe` — and
**none** of the six names above. And the repository has already met and solved this collision once:
`CLAUDE.md` records the four run-event dialog scripts being rescoped under `.fwdc` / `.fwspc` /
`.fwwip` precisely because *"the originals defined bare `.section`, `.btn`, `.field` and `.footer`
that collide with every host screen."* **The stylesheet never received the same treatment.**

**What to do, in preference order.** ⚠ **Do not silently pick one** — whichever you take, write it down,
because `[CMP §7.4]`'s *"consume as-is"* does not survive contact either way:

| | Approach | Cost |
|---|---|---|
| **1** | Ship **§1 (tokens) globally** and scope **§2–§14 under the shell's `:host`** or a single `.fw-root` class | The honest fix. **Not free, and not in the 16 h** — it is a mechanical but wide edit of ~138 selectors |
| **2** | Ship the whole file globally, unscoped, **as the mockups wrote it** | Literal compliance with *"as-is"*, and it **puts `.btn` into the global namespace of the whole application**. Only acceptable if someone owns the regression risk on 30 other libraries |
| **3** | Ship §1 globally and **defer §2–§14** until a screen needs them | Smallest change now; risks each screen story re-deriving base CSS, which is the duplication `FW-133` exists to prevent |

**Raised for `[CMP §7.4]`**, which owns the *"as-is"* instruction and was written before anyone counted
the selectors. → `[CMP §7.4]`, and see the *Out of scope* row in §1.2.

### Step 3 — global-CSS containment

⚠ **This is a real step, and skipping it produces a bug that looks like "the mockup was wrong."**

The host `src/styles/styles.scss` sets:

```scss
body { font-family: Verdana, ...; font-size: 12px !important; }
html, body { text-align: center; }
```

and Bootstrap 5.3.8's reboot is global. A **direct** declaration on the shell root beats an
**inherited** one — including an inherited `!important` — so the shell re-declares font family, size
and text alignment for its own subtree. **Verify in the browser, not by reasoning.**

### Step 4 — the 14 px floor

Set `input, select, textarea, button, option` **explicitly**. Form controls do not inherit the body
font and the browser default is **13.333 px** (`[VAL §7.5]`).

### Step 5 — dark mode

`@media (prefers-color-scheme: dark)`, which the stylesheet already implements. Verify **every**
`--color-*` group resolves in both schemes.

### Step 6 — keep component styles small

⚠ **`anyComponentStyle` is a 10 kB *error*, not a warning** — a component `.scss` past it **fails the
production build**. Shared bulk belongs in the library stylesheet from step 2, never in a component.

### Step 7 — two lint traps `FW-N03` hit, so you do not have to

Both are `eslint` rules on the TypeScript, and both cost time on first contact
([`FW-N03 §6.2`](FW-N03-Angular-Library-Scaffold.md) item 5):

1. ⛔ **Never put a `/** … */` JSDoc block immediately above `@Component` or `@NgModule`.**
   `@stylistic/padding-line-between-statements` forbids the blank line that `jsdoc/lines-before-block`
   requires, so the two rules are **circular** — `ng lint --fix` reports
   `ESLintCircularFixesWarning` and leaves an error whichever way it goes.
2. ✅ **Use `/* … */` block comments there instead.** `multiline-comment-style` separately forbids
   consecutive `//` lines, so **a block comment is the only form that passes.** JSDoc on *methods* is
   still required (`jsdoc/require-jsdoc: error`) and is fine — the conflict is specific to a doc block
   sitting between a statement and a decorator.

---

## 4. Verification

```bash
npm run build:base && ng build flat-wire   # build:base FIRST - see below
ng lint flat-wire
npm run lint:styles                        # ONLY after step 2a - this script runs --fix
npm run test:flat-wire                     # 95 % - the shell component needs its spec
grep -r '\-\-fw-' projects/flat-wire       # must return nothing
npm start                                  # #/flat-wire, both colour schemes - BLOCKED, see below
```

⛔ **`npm start` cannot run in this checkout, so the browser-side half of this story cannot be
verified yet.** `flexmonster`'s core package is missing from `node_modules` (`ngx-flexmonster` is
declared at `^2.9.130` and also absent), which fails the host application build for reasons unrelated
to flat wire — [`P1A §6.15`](Phase-01A-ImplementationPlan.md). **This bites `FW-130` hardest of the
nine stories**, because the canvas, dark mode and the 14 px computed-style checks have **no
compile-time equivalent**: they are only observable in a browser. **Try `npm install` first** — the
lockfile pins both packages, so it is most likely an incomplete install.

⚠ **`npm run build:base` is genuinely required first and skipping it produces a misleading failure.**
`FW-N03` skipped it on the grounds that `dist/` looked populated; `dist/shared` was stale from 23 Jul
and `build:shop-floor` failed inside `shop-floor-common`, which **looked like flat wire breaking the
chain** ([`FW-N03 §6.4`](FW-N03-Angular-Library-Scaffold.md)).

| AC | Proof |
|---|---|
| 1 · shell regions | header, sidebar and alert slot render; the slot accepts projected content |
| 2 · canvas + both schemes | renders at **1920 × 1080** (`F-14`) in light and dark |
| 3 · tokens consumed as-is | ⚠ **not achievable as literally worded — say which reading you shipped.** The `:root` token block is byte-identical; **two canvas declarations must change** (§2b) and the **138 bare selectors** need a scoping decision (§2c). ⛔ And it is byte-identical *only if* `lint:styles` never ran before the disable comment landed — `--fix` rewrites ~700 places (§2a) |
| 4 · no `--fw-*` | the grep above returns nothing |
| 5 · 14 px floor | computed style on an `<input>`, a `<select>` and a `<button>` is ≥ 14 px |

**Test cases:** ⛔ **None.** Phase 1A has **no test cases in `[TCS]`** — measured 28 Aug 2026 against its **405 defined cases** (the ids run to `TC-799`, but 47 are cited and never defined), nothing covers the Angular library, the shell, the canvas, the guards or the mock hub. This story's verification is this plan plus Jest, and nothing else. → `[TCS]`, `[P1A §6.13]`

⚠ **Exit criterion 2 of `phase-01a` still says 1280 × 1024.** Verify against **1920 × 1080** and
record the discrepancy rather than the old figure — `[P1A §6.10]`.

---

## 5. Blockers and open items

| Item | Effect |
|---|---|
| ~~`G23`~~ | ✅ **decided** — 1920 × 1080 (`F-14`). The register row is not yet struck |
| `G18` | ⚠ **a trap, not a gate.** `--fw-*` is retired; there is nothing to migrate. If it resurfaces from an older commit it is wrong |
| ⛔ **the panel diagonal** | unrecorded. The 14 px floor rests on it — `[P1A §6.10]` |
| ⛔ **no owner for scale-to-fit** | affects reviewing this story's own output — `[P1A §6.3]` |
| ⛔ **`npm start` unavailable** | `flexmonster` missing → **the canvas, dark mode and the 14 px checks cannot be observed at all**. Hardest-hit story of the nine — `[P1A §6.15]` |
| ⛔ **`[CMP §7.4]`'s *"as-is"* does not survive contact** | **three separate conflicts**: the disable comment (§2a), 1280 hard-coded in the sheet (§2b), 138 bare global selectors incl. `.btn` (§2c). **Raised for `[CMP]`; pick a reading and record it** |
| ⚠ **the §2c scoping work is not in the 16 h** | the rate-card basis prices *"the token system is consumed, not authored"*. Re-scoping ~138 selectors is authoring. Flagged, not re-estimated — `[CE]` owns the figure |

---

## 6. Handoff

**This story unblocks `FW-133` and `FW-134`** — both depend on it *for the tokens only*
(`[TB §7]`: *"Dependencies: FW-130 (tokens)"*). Tell those developers:

1. **The tokens are `--color-*`.** There is no `--fw-*` and no migration.
2. **Component styles stay under 10 kB** or the production build fails.
3. **The canvas is 1920 × 1080 and the width is where the room is** — compose in columns.
4. ⛔ **Which scoping reading you shipped for §2c**, and whether `.btn` is global. `FW-133` builds six controls and `FW-134` six primitives straight into whatever you decided; if they inherit a global `.btn` they will style against Bootstrap's and not know it.
5. ⛔ **That the browser was never opened.** Dark mode and the 14 px floor are asserted from source, not observed, until `flexmonster` is installed.
