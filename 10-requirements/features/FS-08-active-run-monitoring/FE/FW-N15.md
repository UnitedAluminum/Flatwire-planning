---
id: FW-N15
legacy_id:
title: Active Run machine context — the flatline/:machineName route, line resolution and the line capability profile
status: in-progress
status_confirmed: true
status_note: "🟡 **Built and covered; the commit is what is left.** Ten of the twelve checks in §1.1 stand in the working tree — the route, `resolveMachineName`, `LINE_PROFILES`, the four-field `LineProfile`, `ACTIVE_RUN_SCREEN_KEY` and the `paramMap` subscription: `test:flat-wire` is **13 suites / 220 tests at 100 %** on all four metrics (493/159/136/457). ⚠ **The code was built before the story recorded it**, so measure before planning anything here. ✅ **All four open points are decided as `D-59`**: the address is `#/flat-wire/flatline/fl1|fl2|fl3`, `line-context.model` is a **pure module** rather than an injectable, the **terminal-registration resolve is struck** (nothing in `projects/shared` can read a terminal's own machine), and `#/flat-wire` **lands on DB1**. ⛔ **No code changed for any of it** — the specifications did. ⛔ **Still owed:** the commit (the tree is staged and uncommitted, and carries `FW-081`'s work too) and the `/angular-review` call on `stationFor` / `machineIndexFor`, which are covered but have no production caller. ⚠ Blocked on `OI-11` for one array cell only (Roll Adjust on FL1); the other three profile rows are decided and built"
owner: Frontend (Angular) stream
jira:
mvp: 1
phase: "5"
stream: FE
streams: [FE]
priority: critical
hours: 8
sprint: S2
depends_on: [FW-N03]
blocked_by: [OI-11]
has_plan: true
started: 2026-09-08
completed:
---

# FW-N15 · Active Run machine context — the `flatline/:machineName` route, line resolution and the line capability profile

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 10, 2026 — Change history is in [`../../../../CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** 🟡 **Built and covered — ten of the twelve checks in §1.1. All four decisions recorded as `D-59`. What is left is the commit** — §1.2
**Owner:** Frontend (Angular) stream
**Audience:** The Angular developer closing `FW-N15`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Depends on:** [`FW-N03`](../../FS-01-angular-application-shell/FE/FW-N03.md) — **`done`**, so nothing gates this
**Unblocks:** [`FW-062`](FW-062.md) — the machine-driven Active Run shell, which cannot be built without this and `FW-N16`
**Part of:** category [`FS-08` Active Run Monitoring](../../FS-08-active-run-monitoring.md)

---

> ### ⛔ This is a close-out plan. The code is built; the commit is what is left.
>
> **Ten of the twelve checks in §1.1 are built and covered** in
> `c:\UAL\Second-Branch\ual-angular` — **staged and uncommitted** on `67426e67e`, branch
> `feature/flat-wire`. ⛔ **Treating this as greenfield would rewrite working, fully covered code.**
>
> ⚠ **The story was built before it was recorded.** `D-55` minted it on 7 Sep; the code landed over
> the following two days inside the Active Run rebuild and the `D-56` rename, while this file still
> read `not-started`. **Measure before you plan anything here** — that is how it went unrecorded.
>
> **All four open points are decided, in one citable row —
> [`D-59`](../../../MasterSpecification.md):**
>
> | | Decided | Detail |
> |---|---|---|
> | 1 | The address is **`#/flat-wire/flatline/fl1\|fl2\|fl3`** | §4.1 |
> | 2 | `LineContextService` is a **pure module**, not an injectable | §4.2 |
> | 3 | The terminal-registration resolve is **struck** | §4.3 |
> | 4 | `#/flat-wire` **lands on DB1**, and is not stranded | §4.4 |
>
> ⛔ **No code moved for any of them** — the specifications did, across ten documents (§3 step 1).
> ⚠ **`D-59` is where they are citable from**; this file is a plan and loses to every specification.

---

## 1. What to build

From `[TB §7]` — reproduced verbatim, because the acceptance criteria are the contract:

> ###### FW-N15 · Active Run machine context — the `flatline/:machineName` route, line resolution and the line capability profile
> **Hours:** 8 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE
>
> **As an** FL1, FL2 or FL3 operator,
> **I want** the run monitor to open on my own line from its address,
> **So that** one screen serves all three lines and shows me the material on mine.
>
> **Acceptance Criteria:**
> - [ ] One child route `path: 'flatline/:machineName'` serves all three lines — `#/flat-wire/flatline/fl1|fl2|fl3` (`D-59`)
> - [ ] `FLAT_WIRE_CONSTANTS.FLAT_WIRE_LANDING` is replaced by `FLATLINE`; ⛔ **`screenKey` does NOT follow it** — it is stamped into every element id, so it binds to a stable semantic key (`ACTIVE_RUN_SCREEN_KEY = 'active-run'`)
> - [ ] The segment is normalised to upper case to reach `MachineName`; ⛔ an unrecognised or absent line is **refused**, never defaulted to FL1
> - [ ] `line-context.model` is the single site resolving `machineName` / `station` / `machineIdx` — machine values **cited** from `[INT]`, never retyped. ⚠ **A pure module, not an injectable** (`D-59`): the route already holds which line is in scope, so what this asks for is a *single site*, not a stateful service
> - [ ] `LINE_PROFILES` carries **four fields per line**; ⛔ nothing the API already supplies may enter it (`components[]`, `RouteMode`, `weldEvents[]`, `payoffs[]`, the station claim are **data**)
> - [ ] ⚠ **A line switch reloads, it does not relabel** (`FW-209`'s rule) — subscribe to `paramMap`, never `snapshot`; leave and re-join the hub group
> - [ ] ⛔ **`#/flat-wire` is NOT stranded — it lands on DB1** (`supervisor-dashboard`), which shows all three lines with their live state (`D-59`). ⛔ **The terminal-registration resolve is STRUCK** — nothing in `projects/shared` can read a terminal's own machine and no story owns building one; **`FW-204`'s picker is not the answer either**, and whether it is still wanted is `FW-204`'s own question
>
> **Rate-card basis:** 8 h, a **proxy not a measurement** — §2's smallest unit is 4 h for a whole table and a service-plus-route-plus-constant has no card entry (the reasoning `FW-209` used). ⛔ Not 0 h: `hours: 0` means **cancelled** here
> **Dependencies:** FW-N03
> **Blockers:** **`OI-11`** *(Roll Adjust on FL1 — the action-set profile row only)*

⚠ **`[TB]` is the costing baseline and a client-facing deliverable, so it is off the automatic path**
— a story change must never sweep it. The four criteria above that carry `D-59` were brought level
**by explicit instruction**; treat the next one the same way. ⛔ **Nothing costed has ever moved** —
hours, priority, sprint, phase, stream, dependency and blocker are byte-identical to the original
card, so no quoted figure changed. ⚠ **The three `.xlsx` workbooks read `[TB]` as their data source
and are stale against it** — ⛔ do not regenerate them.

### 1.1 Measured against the working tree

⚠ **The `#` column is this plan's own check numbering, not the card's AC numbers.** Twelve checks
over seven acceptance criteria: **checks 5 and 9 are the two halves of card AC 7**, **6a and 7 the
two halves of card AC 5**, and **6b comes from [`[UIC §3.22]`](../../../../50-frontend/UIConventions.md),
not the card at all**. ⛔ **Name a clause, never rank it** — *"AC 5"* means the four-field profile
contract, and *"AC 7's fallback"* is ambiguous by inheritance: `D-55`'s prose made the terminal
registration the fallback from an absent segment, while the card made `FW-204`'s picker the fallback
from the terminal registration. **Both are struck** (§4.3, §4.4), so nothing turns on it — but say
*"AC 7's terminal-registration clause"* and *"its `stranded` premise"* and the confusion cannot start.

| # | Check | Where it lives | Verdict |
|---|---|---|---|
| 1 | One child route for all three lines | `flat-wire-routing.module.ts` — one `ActiveRunComponent` child, path composed from `FLAT_WIRE_CONSTANTS` | ✅ **Built**, and **`flatline/:machineName` is now the decided address** — §4.1 |
| 2a | `FLAT_WIRE_LANDING` replaced | `flat-wire.constants.ts` — the constant is gone; **`FLATLINE: 'flatline'`** took its place | ✅ **Built**, and the card now names `FLATLINE` too — §4.1 |
| 2b | ⛔ `screenKey` does **not** follow the route | `ACTIVE_RUN_SCREEN_KEY = 'active-run'`, carrying its own comment saying *deliberately NOT the route segment* | ✅ **Built**, and already protected — `FW-N19` records it as explicitly out of scope for the `D-56` rename |
| 3a | Upper-case normalisation | `models/line-context.model.ts` → `resolveMachineName()` trims and upper-cases before matching | ✅ **Built** |
| 3b | ⛔ Unrecognised or absent line **refused** | `resolveMachineName` returns `null`; `ActiveRunComponent.openLine(null)` leaves the previous hub group and clears the screen | ✅ **Built** — and it clears rather than freezing, so no stale line's material survives |
| 4 | Single site resolving `machineName` / `station` / `machineIdx`, machine values cited | `models/line-context.model.ts` — `resolveMachineName` · `stationFor` · `machineIndexFor`. ⚠ `LINE_MACHINE_INDEX` (125/126/127) and its cite-don't-derive comment live in `constants/flat-wire.constants.ts` and are **imported** by the model, not defined in it | ✅ **Built**, ⚠ **as a pure module, not a service** — §4.2, ratified by `D-59` |
| 5 | **Does a terminal-registration mechanism exist at all?** *(card AC 7's terminal-registration clause)* | — | ⛔ **No. Nothing in `projects/shared` can read a terminal's own machine, and `D-59` STRIKES the resolve** — §4.3 |
| 6a | `LINE_PROFILES`, four fields per line | `constants/line-profiles.constant.ts` + `interfaces/line-profile.interface.ts` — `infoSubject` · `centreCard` · `actions` · `hasSpoolOverlay` | ✅ **Built**, exactly four. ⭐ **`G120` (9 Sep) removed the last candidate for a fifth field** — a per-line trace mode — because the trace treatment is uniform across all three lines ([`[UIC §5.0]`](../../../../50-frontend/UIConventions.md)); the cadence that differs is `[PLC]`'s and `FW-081`'s, not a profile row |
| 6b | Every label resolves through content data *(from `[UIC §3.22]`, not the card)* | `actions` holds **content-data keys**, not labels; `ActiveRunComponent.toNavActions()` reads each key from the `contentData` map the constructor resolved — `getContentData()` is called **once**, not per action | ✅ **Built** — and keying `ACTION_ICONS` on the same key is what keeps the rail's `iconMap` working under translation |
| 7 | ⛔ Nothing the API carries may enter the profile | Verified against `active-run-response.model.ts`: `components[]`, `RouteMode`, `weldEvents[]`, `payoffs[]` and the station claim are all **absent** from `LineProfile` | ✅ **Built clean** |
| 8 | Reload, not relabel — `paramMap`, never `snapshot`; leave and re-join the group | `ActiveRunComponent` constructor subscribes `route.paramMap`; `openLine()` calls `joinLine()`, and the service leaves whichever group it held | ✅ **Built** — `FW-209`'s defect class does not exist here |
| 9 | **What does the lineless address actually resolve to?** *(card AC 7's `stranded` premise and its `FW-204` picker fallback)* | `''` redirects to **`supervisor-dashboard`** (DB1) | ⚠ **Neither: it is not stranded and it is not the picker. Answered a third way, and `D-59` ratifies it** — §4.4 |

**Coverage** — `npm run test:flat-wire`: **13 suites, 220 tests passed**, **100 %** statements
(493/493), branches (159/159), functions (136/136), lines (457/457), measured 10 Sep 2026.
`line-context.model.ts` is at 100 % on all four in its own right.

### 1.2 What is left

⛔ **Two things, and the first is the whole of it.**

1. **Commit the tree** — §3 step 5. ⚠ It is not this story's work alone; the step says whose it is.
2. **Decide the two uncalled functions at `/angular-review`** — `stationFor` and `machineIndexFor`
   are covered but have no production caller, and the Angular standards forbid exports nothing
   reads. §4.2 sets out the choice and recommends deleting them.

✅ **Everything else is done:** the four decisions are recorded as `D-59`, both document sweeps are
executed (§3 step 1), and `[TB §7]`'s card is level with nothing costed moved (§1).

⛔ **`OI-11` does not gate any of it.** It blocks one array cell (`ROLL_ADJUST` in FL1's `actions`),
the profile already follows `FR-107` in leaving it out, and the constant's own comment says so.
**The story does not wait on it** — if `OI-11` resolves the other way, one line changes.

### 1.3 Out of scope — and who owns each

| Not here | Owner |
|---|---|
| The Active Run screen itself — the data path, the mapper, the eight builders | [`FW-062`](FW-062.md) |
| The station-claim read — the `FlatWireDB..WIPStations` view over `CommonDB.dbo.WIPStations` | [`FW-N16`](../BE/FW-N16.md) — ⚠ **`in-progress`, not `done`**: the read and the view are built and green, and it stays **`blocked_by: G54`** for FL2 / FL1-segment material |
| The trace panels, live streaming, the source toggle | [`FW-081`](FW-081.md) |
| The line picker at `#/flat-wire` | [`FW-204`](../../FS-06-line-visibility-alerting/FE/FW-204.md) |
| The five **sibling** routes' grammar (`checkin/rod`, `staging`, …) | [`[CMP §5.2]`](../../../../50-frontend/Components.md)'s own flag — **not this story**, see §4.1 |

---

## 2. Context you need

| Where | What it settles |
|---|---|
| **`D-55`** ([`[MS §10.2]`](../../../MasterSpecification.md)) | The decision this story implements — one component, four profile rows, the station rule. ⚠ Its text still says `:lineId` (**`D-56` renamed that fact and nothing else**) and ⛔ **its URL is now superseded** — see §4.1 |
| **`D-56`** ([`[MS §10.2]`](../../../MasterSpecification.md)) | The `MachineName` vocabulary, and nothing else. ⛔ **It does NOT carry the route-grammar question** — this plan asserted twice that it did, and it has no open-questions line at all. **The only durable record of the disagreement was [`FW-N19`](../../FS-01-angular-application-shell/FE/FW-N19.md)'s Handoff**, which §4.1 closes |
| **`D-59`** ([`[MS §10.2]`](../../../MasterSpecification.md)) | ⭐ **The four decisions this story made**, in one citable row — the address, the pure module, the struck fallback, the DB1 landing. Written 10 Sep 2026 |
| [`ActiveRunMonitor.md §1.4a`](../../../screens/ActiveRunMonitor.md) | The four varying things, in the client's own document |
| [`[UIC §3.22]`](../../../../50-frontend/UIConventions.md) | `screenKey`'s effect on element ids, and `lib-nav-rail`'s `iconMap`/`iconClass` rule — which is why `actions` holds keys, not labels |
| [`[CMP §5.2]`](../../../../50-frontend/Components.md) | ⚠ **Superseded twice** — by `D-55` on route shape (it is written line-first, `/flat-wire/line/:machineName/...`, and this is screen-first), and now by §4.1 on the segment itself |
| [`[CMP §5.4]`](../../../../50-frontend/Components.md) | The state layer — `line-context.model` (pure) beside `run-state.service` (a real `BehaviorSubject`). §4.2 is why they differ |
| [`[INT]`](../../../../20-architecture/Integration.md) | The `machine_idx` values. **Cite them; never retype them** — `LINE_MACHINE_INDEX` already carries the warning |
| [`FW-209`](../../FS-07-rod-checkin-plc-config/FE/FW-209.md) | *"Reload, not relabel"* — the same defect class, on DB2A. ✅ Already avoided here |
| [`FW-N19`](../../FS-01-angular-application-shell/FE/FW-N19.md) | The `D-56` FE pass. Its **Handoff** was the only place the route-grammar conflict was ever written down, and ✅ **this story closed it** |

**The checkout is `c:\UAL\Second-Branch\ual-angular`.** ⚠ `c:\UAL\ual-api` carries no `FlatWire`
domain at all, so `CLAUDE.md`'s `../ual-api` is not the checkout the API half lives in either.

---

## 3. Closing it out

⛔ **Nothing here regenerates working code.** The four decisions are made (§4, `D-59`) and the
document sweep is executed; [`CHANGELOG.md`](../../../../CHANGELOG.md) is where what-moved is
recorded, not this file.

### Step 1 — the code sites that must NOT move

⛔ These two are already right — verified by grep across `projects/` and `src/`, and they are the
**only** two:

| File | Line | Action |
|---|---|---|
| `constants/flat-wire.constants.ts` | `FLATLINE: 'flatline',` | ⛔ **leave** |
| `flat-wire-routing.module.ts` | `` path: `${FLAT_WIRE_CONSTANTS.FLATLINE}/:${…MACHINE_NAME}` `` | ⛔ **leave** |

⛔ **`ACTIVE_RUN_SCREEN_KEY` does not move either**, and this decision does not make it tempting: it
stays `'active-run'` because it is stamped into every DOM id. That is check 2b, and `FW-N19` already
had to defend it once against the `D-56` rename.

### Step 2 — four rules the sweep leaves behind

⛔ **Do not sweep these three carriers.**
[`[SCM §2]`](../../../../90-registers/StoryConsolidationMap.md) carries the old title *and*
`not-started`, but it is generated by `build_consolidation_map.py`, which runs **only when category
membership changes** — so it stays behind until the next legitimate regeneration, and that is
expected rather than a defect. `95-archive/` is never citable. `CHANGELOG.md`'s rows are history and
are correct as written.

✅ **One false positive — do not "fix" it.** `[UIC §1.1]`'s **Default load** row writes
`redirectTo: '<landing>'` as a **placeholder**, and is correct as written. It must stay generic.

⚠ **A `[CONFIRMED]` client row takes a superseding note, never a rewrite.**
[`ActiveRunMonitor.md`](../../../screens/ActiveRunMonitor.md) is `Issued for Client Review and
Sign-off` at `Version: 1.4`, so §1.4a kept its confirmed text and gained a note, with the previous
value nested in its `Last Updated` header in that file's own style. ⛔ **No version bump** — the
precedent is the larger 9 Sep `G120` reversal, which stayed at v1.4. **The same treatment gave `D-55`
its note**: a decision row keeps its full recorded text.

⛔ **The `flat-wire-landing` → `active-run` component rename is `FW-N19`'s, not this story's.** Three
sites still carry the old folder name and are listed in §6 so nobody re-finds them.

### Step 3 — commit ⛔ still owed, and it is not this story's commit alone

The tree is **staged and uncommitted** on `67426e67e` (branch `feature/flat-wire`) — **46 staged
files, 5 of them staged and then modified again, and 7 modified but never staged.** ⛔ **It is not
`FW-N15`'s work in isolation:**

| Belongs to | What is in the tree |
|---|---|
| **`FW-N15`** | the route and constant, `line-context.model.ts`, `line-profiles.constant.ts`, `line-profile.interface.ts` |
| **`FW-062` / `FW-N19`** | the `flat-wire-landing` → `active-run` rename and the Active Run rebuild |
| **`FW-081`** | `projects/shared` — `trace-chart.model`, `chart-canvas.component.spec`, `shared.constants`, `shared.interface` |
| *incidental* | one `furnace-scheduling` spec |

⚠ **`projects/shared` is touched, so `ng build shared` before any dependent test run** — jest
resolves `shared` to `dist/`, not source ([`[UIC §1.1]`](../../../../50-frontend/UIConventions.md)
states the rule and the reason).

**The commit owes a `CHANGELOG` row of its own** — the planning-side rows already exist, so record
what shipped, not what was decided.

### Step 4 — decide the two uncalled functions at `/angular-review`

`stationFor` and `machineIndexFor` are fully covered and have **no production caller**, which the
Angular standards forbid. §4.2 sets out both defensible outcomes and recommends deleting them.
⛔ **Do not let the review resolve it silently in either direction.**

---

## 4. Decisions made here

✅ **All four are recorded as `D-59`** ([`[MS §10.2]`](../../../MasterSpecification.md)).
⛔ **Nothing below is a recommendation** — read them as decided, and cite
`D-59` rather than this file, which is a plan and not citable as a requirement.

### 4.1 The address is `#/flat-wire/flatline/fl1|fl2|fl3` — the built router is ratified

**What it settled.** `D-55` and [`[CMP §5.2]`](../../../../50-frontend/Components.md) specified
`#/flat-wire/home/:machineName`; the built router composes `flatline/:machineName`.
⚠ **[`FW-N19`](../../FS-01-angular-application-shell/FE/FW-N19.md)'s handoff was the only place that
disagreement was ever written down** — ⛔ **not `D-56`, which has no open-questions line at all.**
**This story is where it landed**, because it is the story that owns the route.

⭐ **Decided for `flatline` by user decision.** It is a decision about the product's address rather
than an inference from the documents. The four grounds:

1. **The segment names the thing an operator is looking at.** `#/flat-wire/flatline/fl1` reads as
   *the flattening line FL1*; `#/flat-wire/home/fl1` reads as *somebody's home page*, which is a
   statement about navigation rather than about the plant. The screen is the run happening on a
   line, and the address now says so.
2. **`home` is a weak segment for a screen that is not a home.** DB3 is not the front door — §4.4
   is explicit that `#/flat-wire` lands on DB1 — so an address calling DB3 *home* would contradict
   the routing that is actually built one line above it in the same file.
3. **Nothing is owed to the specifications by default.** `D-55` chose `home` in passing, in a
   decision whose subject was the four profile rows; it was never argued. A choice made in passing
   does not outrank one made deliberately, and **it is cheaper to move a set of document sites once
   than to carry an address nobody wants for the life of the module.**
4. ⭐ **The repository had already made this argument against itself.**
   [`[UIC §5.0]`](../../../../50-frontend/UIConventions.md) holds that *"`'home'` is a location, not
   a screen"* — written to keep `screenKey` **off** the route, and it is the same objection applied
   to the segment. `[UIC]` even said *"`FW-N15` owns the choice"*, so the reasoning was sitting in
   the conventions document waiting for this story to act on it. **Cited, not re-argued.**

⛔ **The consequence ran toward the documents, and it was not optional.** Ratifying the code and
leaving them would have been the *same* defect as changing the code and leaving them — the
repository asserting one address and shipping another. ✅ **Both sweeps are executed and `D-59` is
the row that closes them** (§3 step 1).

⚠ **The one thing given up.** `#/flat-wire/flatline/…` repeats a word: *flat-wire* then *flatline*.
That is the strongest argument the other way and it is recorded here rather than discovered later.
It was weighed and accepted, because the repetition costs a reader nothing while `home` costs them
a wrong expectation about what the screen is.

⛔ **This does NOT decide the sibling grammar.** `[CMP §5.2]`'s five other routes are line-first
(`/flat-wire/line/:machineName/checkin/rod`) while this one is screen-first, and that split is a
real defect — but it belongs to whichever story builds the second route, and `[CMP §5.2]`'s own note
is already the flag. **Ratifying `flatline` neither creates nor fixes it**, and the next screen to
land is still free to settle it either way.

### 4.2 `LineContextService` stays a pure module

`D-55` and `[CMP §5.4]` both name a **service**. The build wrote `models/line-context.model.ts` —
three exported functions, no `@Injectable`, no state — and its header comment argues the case:
*"the route already holds which line is in scope, so a service holding it again would be a second
copy of the same fact."*

**That argument is right, and the AC's actual requirement is met.** What AC 4 asks for is a **single
site** that resolves the line, and that is exactly what exists: `resolveMachineName` has **one**
production caller, `ActiveRunComponent`, and `LINE_MACHINE_INDEX` has one, `machineIndexFor`.
Angular DI would buy nothing here — there are no dependencies to inject and no substitution point to
create — while a stateful service would introduce the second copy the comment warns about.

**So `[CMP §5.4]` is what moved, not the code** — `D-59` decision 2.

⚠ **Said honestly: `stationFor` and `machineIndexFor` have NO production caller** — only their spec —
**and they are not exported from `public-api.ts` either**, so no other library can reach them today.
They are the contract for `FW-N16`'s FE half and for OPC/scheduling reads that do not exist yet.
⛔ **It is not fine to describe them as *in use*, and `resolveMachineName` is the only one of the
three that is** — one production caller, `ActiveRunComponent`, which is exactly the *single site*
AC 4 asks for.

> ⛔ **And this is not settled, because the Angular standards say the opposite.** `UALUADEV`'s
> mandatory TypeScript rules include *"**No dead code.** An exported constant, interface property or
> field that nothing reads must go — **and a test is not a consumer**"*. By that rule `stationFor` and
> `machineIndexFor` are **deletable today**, and ⚠ **`/angular-review` will flag them** — it is
> exactly the class of violation `CLAUDE.md` warns `ng lint` cannot see.
>
> ⚠ **Decide it at the review, not by ignoring it.** Two defensible outcomes: **delete them and their
> spec**, letting `FW-N16`'s FE half reintroduce `stationFor` when it has a caller — which costs
> nothing, because the resolution rule they encode is three lines and its *reasoning* lives in the
> module's header comment; or **keep them and record the exemption**, on the grounds that they are the
> single site of a rule (`station == machineName`, and `machineIdx` never derived from the name) that
> `D-55` requires to exist in exactly one place. ⭐ **The first is the better default** — a rule kept
> in a comment cannot rot into a second caller, and 100 % coverage on an uncalled function is coverage
> of nothing. ⛔ **What must not happen is the review silently deleting them while this plan says they
> are a contract.**

### 4.3 The terminal-registration resolve is STRUCK — it had no mechanism

**Card AC 7's terminal-registration clause** says `#/flat-wire` *"resolves from the terminal
registration, falling back to `FW-204`'s picker"*. **`D-55`'s prose put it the other way round** —
the resolver *"falls back to the terminal's own machine registration when no segment is supplied"* —
so ⚠ **the word *fallback* points at the picker in one source and at the terminal registration in
the other.** ⛔ **Both readings are struck**, and this section is about the mechanism either would
need. ⚠ **Do not call it "AC 5"**: on the card, AC 5 is the four-field profile contract.

**Nothing in the repository can do it.** `projects/shared` was searched for a terminal, workstation
or host-machine service and has none — its 19 services carry no such thing, its only `terminal` hit
is an `isTerminal` flag on a workflow response, and `station` appears solely as a **caller-supplied**
payload field. `shop-floor.constants.ts` is a static list of furnace ids, read by nobody here.

⚠ **The requirement was inherited from `D-55`'s prose, not from a specification of the mechanism**,
and no story anywhere owns building one.

⛔ **Struck, not deferred — `D-59` decision 3.** With §4.4's redirect in place the
case it existed for — an operator reaching `#/flat-wire` with no line — is already answered, and
answered better: DB1 shows all three lines rather than guessing at one. **The `D-59` row records the
absence of a mechanism**, so a later reader finds a decision rather than a silence; if terminal-derived
defaulting is genuinely wanted it is its own story, with its own source of truth.

⛔ **Do not implement a guess.** Defaulting a line from anything other than an explicit registration
is precisely what check 3b forbids, one step removed.

### 4.4 `#/flat-wire` is not stranded — it lands on DB1

`D-55` predicted that a required `:machineName` would strand `#/flat-wire`, and named
[`FW-204`](../../FS-06-line-visibility-alerting/FE/FW-204.md)'s two-tile picker or a
terminal-registration resolve as the two ways out. **The build took a third:** the empty-path child
redirects to `supervisor-dashboard` — DB1, the Line Status Overview.

**That is a better answer than either, and ✅ it is ratified — `D-59` decision 4**: DB1 already shows
all three lines with their live state, so an operator arriving with no line in the address gets more
information than a picker would give them, from a screen that has to exist anyway.

⚠ **It changes `FW-204`'s premise**, and that is now written into `FW-204` itself. That story's
retirement condition was already re-opened by DB1 existing as a skeleton (`FW-060`); this makes the
question sharper rather than answering it — building the tiles would now displace a working screen
showing three lines, not a screen showing one — and it stays `FW-204`'s to answer.

---

## 5. Verification

```bash
cd "c:/UAL/Second-Branch/ual-angular"
npx ng build shared            # projects/shared is modified in this tree - jest reads dist/
npm run test:flat-wire
npx ng build flat-wire
npx ng lint flat-wire
```

**Measured 10 September 2026:** 13 suites, **220 tests passed**; coverage **100 %** statements
(493/493), branches (159/159), functions (136/136), lines (457/457).

⚠ **`ng build shared` comes FIRST and is not optional here** — `FW-081`'s work put `projects/shared`
in the same working tree, and jest resolves `shared` to `dist/` rather than source
([`[UIC §1.1]`](../../../../50-frontend/UIConventions.md) owns that rule and its reason), so a
flat-wire run against a stale `dist/` proves nothing about what is in the tree.

⚠ **§3 changed no code, so these figures are the closing figures, not a baseline.** Re-run them
anyway before the PR — the commit in step 5 is what they have to describe.

*(the numbers are §1.1's checks, not the card's AC numbers — see §1.1's note)*

| Check | Proof |
|---|---|
| 1 · 2a · one route, right segment | **`#/flat-wire/flatline/fl1`, `/fl2` and `/fl3`** all resolve to `ActiveRunComponent`; grep finds **no** `home` segment and no surviving `FLAT_WIRE_LANDING` |
| 2b · `screenKey` unmoved | `ACTIVE_RUN_SCREEN_KEY` is still `'active-run'`; rendered ids read `btn-{item}-active-run` and `act-{key}-active-run` |
| 3a · normalisation | `line-context.model.spec.ts` — lower case, upper case and padded segments all resolve |
| 3b · refusal | the same spec asserts `null` for `fl4`, `null`, `undefined` and `''`; the component spec asserts the screen clears |
| 4 · single site | `resolveMachineName` has exactly one production caller — verify by grep, not by reading. ⚠ `stationFor` and `machineIndexFor` have **none**, and are not in `public-api.ts`; that is expected (§4.2) |
| 6 · four fields, labels via content data | `LineProfile` has four members and no fifth; `toNavActions` reads every label from the `contentData` map the constructor resolved — one `getContentData()` call, not one per action |
| 7 · nothing the API carries | `LineProfile` names none of `components`, `routeMode`, `weldEvents`, `payoffs`, `station` |
| 8 · reload not relabel | switching `#/flat-wire/flatline/fl1` → `/fl2` re-reads and re-joins; the previous group is left |
| 9 · the lineless address | `''` redirects to `supervisor-dashboard`; ⛔ grep finds no surviving claim that `#/flat-wire` is *stranded* or resolves from a terminal registration |

⛔ **`ng lint` passing proves nothing about the rules that actually break here** — `CLAUDE.md` is
explicit, and two consecutive flat wire reviews found violations in every category with zero lint
errors. `/angular-review` before the PR.

**Test cases:** ⛔ **None in `[TCS]` cover the route or the resolver.** This plan plus Jest is the
verification, as it was for `FW-N03`.

---

## 6. Handoff

- ⚠ **`FW-062` is what this unblocks**, and it should be told two things: the profile it consumes is
  `LINE_PROFILES[machineName]` and it must not grow a fifth field; and the line reaches it as a
  signal, `machineName()`, which is `null` until the route resolves.
- ⚠ **`FW-062` still needs a re-measure of its own.** Its `status_note` has been corrected on the
  three facts `D-59` governs — the component name, the address and the default child — but its
  *"no API client, no live stream"* description of a UI skeleton was **not** re-scoped here, and the
  built `active-run.component.ts` has both. **Re-measure it before planning it**; what remains of
  the eight hardcoded builders is not established by this story.
- ⛔ **`FW-204`'s retirement condition is still its own question.** It now records that `#/flat-wire`
  lands on DB1, so `D-59` sharpened the question rather than answering it: building its tiles would
  displace a working screen showing three lines.
- ⭐ **The address is `#/flat-wire/flatline/:machineName`, settled and citable at `D-59`.** ✅ Every
  document that asserted `home` has moved — **if you find another, it is a new finding, not a known
  gap**. ⛔ **Two carriers stay behind deliberately**: `[SCM §2]`'s generated row and `95-archive/`
  (§3 step 2).
- ⛔ **`[CMP §5.2]`'s two-grammar flag stays open** and is not this story's to close. ⚠ Whoever
  builds the second screen inherits it, and now inherits a **concrete** screen-first precedent
  rather than a proposed one.
- ⚠ **The `flat-wire-landing` → `active-run` component rename is `FW-N19`'s residue, not this
  story's**, and three sites still carry the old folder name: `FW-130` asserts
  `redirectTo: 'flat-wire-landing'` as a live requirement, `FW-N03` quotes it in a `done` story's code
  excerpt, and `[UIC]` names the old folder in four more places. **Listed here so nobody re-finds them.**
- ⛔ **`/angular-review` will flag `stationFor` and `machineIndexFor` as dead code**, because
  `UALUADEV`'s rules say an export nothing reads must go and **a test is not a consumer**. §4.2 sets
  out the two defensible outcomes and recommends deleting them; ⚠ **whoever runs the review must
  decide it explicitly** rather than deleting them against a plan that calls them a contract.
- ⚠ **Two comment-only edits are in the tree and ship with the commit** — behaviour untouched, and
  the coverage figures in §5 were measured after them: `ACTIVE_RUN_SCREEN_KEY`'s comment no longer
  argues from the retired `home` segment, and `line-profiles.constant.ts` now says *six run actions
  plus `moreOptions`*, which is what FL1's seven-entry array holds.
- **Per `CLAUDE.md`'s seven steps:** `/angular-review`, then the `[UIC §5]` update, then the
  `CHANGELOG` row — which for this story also has to say that the work was done before it was
  recorded.
