---
id: FW-N19
legacy_id:
title: LineId → MachineName — the flat-wire Angular library
status: done
status_confirmed: true
status_note: "✅ **Done, 8 Sep 2026 — 243 sites across 20 files, 210 tests green at 100 % on all four metrics, `ng build flat-wire` clean.** `enums/line-id.enum.ts` is now `enums/machine-name.enum.ts` with `enum MachineName`, and all 14 import paths follow. `resolveLineId` → `resolveMachineName`; ⛔ `stationFor()` and `machineIndexFor()` keep their names as `D-55`'s other two facts. `ROUTE_PARAMS.LINE_ID` → `MACHINE_NAME: 'machineName'`, which **is** the URL — the route is composed from it. Two type holes closed in passing: `RunHeader.machineName` and `FlatWireLine.machineName` were `string`, now the enum; `LineAlert.machineName` is `MachineName | null` and its plant-wide-alert sentinel moved `''` → `null`. ⛔ `ACTIVE_RUN_SCREEN_KEY` untouched. **Rendered output is byte-identical** — every binding still prints `FL1`/`FL2`/`FL3` and no operator-visible label changed."
owner:
jira:
mvp: 1
phase: "1A"
stream: FE
streams: [FE]
priority: high
hours: 6
sprint: S0
depends_on: [FW-N18]
blocked_by: []
has_plan: true
started: 2026-09-08
completed: 2026-09-08
---

# FW-N19 - LineId → MachineName — the flat-wire Angular library

## What to build

Rename `LineId` to `MachineName` through `projects/flat-wire`, per **`D-56`** — the third of
`[API §2.1]`'s three mirrors.

**The operator must not be able to tell.** Screens keep the word *Line*, every binding still
renders `FL1` / `FL2` / `FL3`, and no label moves. Only identifiers change.

## Context you need

- **Blast radius is one library.** Verified: **zero** hits in the host app (`src/`) and zero in the
  other 27 libraries. `public-api.ts` exports only `flat-wire.component` and `flat-wire.module`, so
  the enum never crosses the library boundary — **no consumer breaks and there is no public API
  change**. `projects/shared` is untouched, so `ng build shared` is not required.
- ⛔ `dist/united-aluminum/flat-wire.js` and `coverage/flat-wire` are build artifacts. Never
  hand-edited.
- ⛔ **`LINE_MACHINE_INDEX` keeps its values** (125 / 126 / 127) and its warning comment verbatim.
  Only the key type moves.

## Build order

1. Rename the enum file and symbol; let the compiler drive outward.
2. Models → interfaces → constants → routing.
3. Services, then components, then templates.
4. Specs **last**, and check the route fixture key by hand — see below.
5. `/fix-jsdoc` on every touched file, then `/generate-tests` for any spec needing a rebuild.
6. `/angular-review` before the PR.

## Decisions made here

### `LineAlert` could not simply be retyped

`supervisor-dashboard.component.ts` set `lineId: ''` as a sentinel for a **plant-wide alert with no
line**, which is *why* the interface was `string` and not the enum. Retyping it to `MachineName`
breaks that call site.

**Resolved as `MachineName | null`**, with the sentinel moved `''` → `null`. The template's existing
`@if (alert.machineName)` truthiness guard already covers `null`, so no template logic changed.
Recorded here per `[UIC §5]` because it is a behaviour change to a mock, however small.

### Two type holes closed rather than carried

`RunHeader.lineId` and `FlatWireLine.lineId` were typed `string`, not the enum — so the three-way
mirror was **already broken on the client** before this story. Both are now `MachineName`. This was
in scope because the alternative was renaming a field while knowingly leaving it untyped.

### What the rename must not touch

- ⛔ **`ACTIVE_RUN_SCREEN_KEY`.** Its own comment says it is *deliberately NOT the route segment*
  because it is stamped into every DOM id (`act-{key}-{screenKey}`, `btn-{item}-{screenKey}`).
  `CLAUDE.md` flags exactly this trap.
- **`resolveMachineName`'s module header comment** is rewritten as prose, not token-swapped — it
  names the three identifiers in a sentence.

> ### ⚠ The one miss that would not fail the build
>
> `convertToParamMap({ lineId: 'fl1' })` appears **9 times** in `active-run.component.spec.ts`.
> Leave that key and the route resolves `null`, the screen renders idle, and **the tests still
> pass** — green against the wrong thing. It is the only place in this story where a mistake is
> silent, so verify it by eye rather than by compiler.

## Verification

```bash
cd "c:/UAL/Second-Branch/ual-angular"
npm run test:flat-wire
npx ng build flat-wire
```

**Measured 8 Sep 2026:** 13 suites, **210 tests passed**; coverage **100 %** statements (473/473),
branches (155/155), functions (129/129), lines (441/441); `ng build flat-wire` clean.

The route is now `#/flat-wire/flatline/fl1` keyed on `:machineName`. ⚠ The segment **value** is
unchanged — `resolveMachineName` upper-cases it — so only the parameter name moved, not the address
an operator would bookmark.

## Handoff

- ⛔ **Ships with `FW-N18`, not after it.** The JSON body, query string and hub payload names all
  change together.
- ⚠ **The route grammar still disagrees with itself**, and this story did not resolve it: `D-55`
  and `[CMP §5.2]` say `#/flat-wire/home/:machineName`, while the built router composes
  `flatline/:machineName`. Pre-existing; raised in `D-56`'s open questions.
- `/angular-review` and the `[UIC]` update are owed before the PR, per `CLAUDE.md`'s seven steps.
