# Flat Wire Mill — Task Breakdown and Backlog

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 4, 2026 (OPC UA tag identity) — **[`FW-236`](../40-backend/tasks/FW-236.md)'s card absorbs new gap `G94`: `OPCUAManager` has no canonical tag identity, and it is ordered AHEAD of `G58`.** Six acceptance criteria added — canonicalise identity before lifting `G58`'s swallow, correct `ReadTag`/`WriteTag` from namespace **0** to **2**, correlate notifications on the `object state` overload rather than `NodeDescriptor.ToString()`, and give `OPCConnection` its first unit tests behind a first-party adapter (the QuickOPC singular methods are **extension methods** and cannot be mocked). ⚠ **`G94` is latent and measured so** — all four `CommonDB.OPCModules` rows are `21316` (`OPCDA`), so the UA manager runs nowhere today. ⚠ **HOURS NOT RE-DERIVED and no story minted** — the card stays at **16 h** because the `Hours` cell feeds three client `.xlsx` generators; a re-price belongs in an additive pass. Card kept byte-identical to its task-file twin. *(previously September 3, 2026 (tooling) — **`FW-259`–`FW-261` minted, 27 h** (DB 5 · BE 10 · FE 12) for the **fourth** Tooling Inventory tool type (`D-42`). `FW-003` and `FW-253` move from **three** tool types to four; `FW-003`'s stale *"`Straightener` exists nowhere else in this repository"* is corrected; **`FW-251`'s `FW-005` leg is discharged** — that card seeded `Drawer` with 13 die-size rows the split took apart. ⛔ `FW-261` owes an un-priced mockup. ⚠ **No figure re-derived** — `FW-258` still owns the arithmetic. *(previously September 1, 2026 (second pass) — ⛔ **§7’s `FW-215` card again: the first pass had not checked that the story’s one new route is BUILDABLE, and it is not as `[SIM §8.1]` words it.** Of *"scenario, seed, start weight, target"*, **the seed and the start weight are constructor-only** on `LineModelBase` and nothing on `ILineModel` sets either — so `POST /sim/{lineId}/run` **replaces** the line’s model through the seam’s factory rather than mutating a live one, which is also the only way `[SIM §5.7]`’s tick-for-tick reproducibility holds. The `G70` seam therefore carries `CreateModel` too, absorbing a **byte-identical duplicate** in both hosts. ⛔ **New gap `G73`** — `[SIM §9.2]` specifies **Pause** and nothing commands it, so a **target run state** joins `POST /run`; no seventh route. ⚠ **`/sim/state` carries at most TWO lines, never three** (`{FL1,FL2}` or `{FL3}`), omits an unhosted line and still answers `200`. ⚠ **`G68`’s *"settable"* is the seed’s alone**, so the config endpoint stays a **read** and no write is owed. ⚠ **The fault route takes all SEVEN of `[SIM §7.2]`.** ⚠ **No hours-bearing cell changed and no total moves** — the `**Hours:** … **Stream:**` line is untouched and the three `.xlsx` generators re-parse unchanged *(previously September 1, 2026 — **§7's `FW-215` card reconciled against the 31 Aug simulator build — stale in eight places, and owner of four gaps it never named.** ⛔ **Four of its five endpoints are already BUILT** (`FW-218`, closed), so `POST /sim/{lineId}/run` is the one new route and the story **extends** that surface (`P-39`). Corrected: the prefix is **`/sim`**, not `/api/v1/flatwire/sim`; the surface is a **minimal-API group, not MediatR controllers** (`P-38`); the gate is **`FlatWireOpc:SimulateOpcFeed`**, not `SimulatePLCTagPush`; *"all three snapshots"* becomes **one per hosted line** (FL3 excluded, `PLC-Q08` / `G30`); and *"`[API]`'s 30 endpoints"* now cites **`[API §3.2]`** without a number. **`G68`** adds a sixth endpoint `GET /sim/config`, **`G70`** the widened gate and the shared seam, **`G69`** becomes its blocker; dependencies gain **`FW-218`** and **`FW-217`**. ⚠ **The 23 h is re-aimed, not re-priced, and no total moves** — a six-endpoint re-price is `[CE]`'s. *(previously August 29, 2026 — **§7's `FW-214` card retargeted to WinForms (`D-33`): 24 → 52 h base, 15 → 36 h AI-assisted.** Ten acceptance criteria, a new **FL3 greyed** row (that endpoint returns 400 today — `PLC-Q08`/`G30`), the `GET /sim/state` row corrected to name its **six** fields, and dependencies **`FW-130`/`FW-135` → `FW-145`**. ⚠ **The 40 h of `FW-130`/`FW-135` is not recovered** — both serve the six operator screens *(previously August 25, 2026 — **`FW-138`: fifteen controllers → fourteen (`P-53`, no `/rod/**` surface).** AC 1 restated; the hours cell deliberately unchanged, 42 h owed to the re-baseline. Earlier the same day: **`FW-224` recorded as reserved**; the FL2 `422` acceptance criterion withdrawn; `CoilNo` rename completed; object count 34 → 33 *(previously August 18, 2026 — **`D-32`: there is no shared-schema migration.** `FW-001` and `FW-002` **cancelled**; `FW-176`'s shared-`coils` column line cancelled with them; `FW-186`, `FW-201` and the FL1/FL2/FL3 machine story lose the acceptance criteria and dependencies that referenced them. **Phase 1C 221 → 138 h · Phase 7 205 → 182 h · Phase 1 1,110 → 1,027 h · baseline 116 / 3,292 h → 114 live / 3,186 h** *(earlier: **`G6` resolved on both blocked story cards** (`FW-145` and the Angular guard story): the six roles exist as JWT claims on `ClaimTypes.Role`; earlier still: **the machine simulator story set minted**: `FW-210`–`FW-215` (**111 h dev** — RT 64 · FE 24 · BE 23) and `FW-217` (+24 h), specified in [`MachineSimulator.md`](../20-architecture/MachineSimulator.md) `[SIM]`, gap **`G39`**. **Additive to `[CE §3b]`** like `FW-202`/`203`/`204`; **`FW-203` is unchanged** and becomes `FW-211`'s first increment. ⚠ **`FW-209` was already taken** — `FW-218` was the next free id and is now used; **the next free id is `FW-220`** (`FW-219` = the FL2/FL3 run-end shared write-back, minted 18 Aug 2026), and `FW-216` is deliberately skipped *(otherwise August 14, 2026 — **`FW-203`** (plant-data feed simulator, 8 h) and **`FW-204`** (minimal landing route, 8 h) minted for the trial run, both additive to `[CE §3b]` and both deliberately absent from `[SSP §5]`. Earlier same day: **`FW-202` minted** (FL1 spool completion — stop confirmation, weight basis and the `SpoolProcessing` write, **98 h**) and `FW-N02` reduced to Part A; gap **`G37`** *(otherwise August 13, 2026)* — split out of `05-SprintPlanAndBacklog.md` in the ProjectPlan restructure)*. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*)*)*)*)*)*)*
**Document Type:** The MVP-1 shopfloor backlog — 116 story ids (**114 live**), the descope ladder, the coverage matrix
**Status:** **Authoritative for MVP-1 shopfloor delivery** — **114 live stories / 3,186 h** *(re-baselined 18 Aug 2026 by `D-32`; previously **116 / 3,292 h**)*, plus **`FW-202`** *(new 14 Aug 2026, gap `G37`)*, which is **additive and deliberately outside that baseline**: its 98 h base / 136 h all-in is carried in `[TRP]` and is **not** folded into the 3,186 h or into Phase 8's 118 h.<br>⚠ **The baseline moved deliberately and this is the pass that moves it.** `D-32` cancels `FW-001` (56 h) and `FW-002` (4 h) outright and `FW-176`'s 16 h shared-`coils` column line, re-deriving **Phase 1C 221 → 138 h** and **Phase 7 205 → 182 h** from the reduced bases: **−106 h all-in.** Both phases sit wholly inside MVP-1, so the subtraction is valid whatever composition produced the 3,292 h. **Now cite "114 stories / 3,186 h"**, and expect the old pair to survive in documents this pass did not reach — the figure is quoted in five others and in `[CE]`, which is **not** re-derived (`[CE §8]`). **The 116 id count is unchanged** — ids are frozen and `FW-001`/`FW-002` keep theirs as cancelled cards.
**Owner:** Delivery lead / programme management
**Audience:** Delivery lead, scrum team, developers, QA
**Shortcode:** `[TB]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

---

## 7. Backlog

**114 live stories / 3,186 h across four sprints and 15 phase specifications** *(116 ids, two cancelled by `D-32` on 18 Aug 2026; previously 3,292 h)*. Every story carries a `Rate-card basis:` line, and each phase closes on its `CapacityAndEffortModel.md` §3b figure — **except Phases 1C and 7, which `D-32` re-derives here** (138 h and 182 h) and which `[CE §3b]` still publishes at 221 h and 205 h.

### 7.1 How stories are sized

The unit is **hours**, factored from [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §2's rate card. Every story carries a **`Rate-card basis:`** line so its figure is auditable rather than asserted.

**Story hours are development hours only** — the FE / BE / DB / RT / BA streams. **QA (+20% of the FE+BE+DB+RT base) and contingency (+15% of base+BA+QA) are applied at phase level, never per story**; pricing them per story double-counts. Each phase section closes with the arithmetic.

Worked example, reproducing §3's own Phase 4 derivation:

```
Σ story dev-hours (FE 60 + BE 62 + DB 28 + RT 28)  = 178   ← dev base
                                           + BA 8  = 186
QA   = 0.20 × 178                                  =  36
Cont = 0.15 × (178 + 8 + 36)                       =  33
                                           Total   = 255   ← §3b Phase 4
```

**Priority legend:** `Critical` blocks go-live · `High` required for the 30 Sep feature-complete milestone (M5) · `Medium` required for production, first onto the descope ladder · `Low` post go-live.

**Stream codes:** `FE` Angular · `BE` .NET · `DB` SQL Server · `RT` real-time/PLC · `QA` test · `BA` analysis.

---


### 7.2 The sprints

#### S0 — Platform Gate

**Dates:** Thu 30 Jul – Fri 14 Aug 2026 · **12 working days** · **96 h/person**
**Phases:** 1A Angular Foundation · 1B Backend Foundation · 1C Database Foundation
**Hours:** **1,027** (1A 370 · 1B 519 · 1C 138) · **Required FTE: 10.7** — ⚠ **re-derived 18 Aug 2026, `D-32`** *(previously **1,110**, 1C at 221, FTE 11.6)*
**Goal:** stand up the platform. Every later phase assumes it exists.

**Entry criteria:** roster confirmed; `FlatWireDB` server available; `ual-angular` / `ual-api` branches cut.
**Exit criteria:** Angular library scaffolded and building; `FlatWire` four-project solution with stubbed controllers returning contracted shapes; `FlatWireHub` skeleton broadcasting simulated data; `PLCTagService` in simulate mode; `FlatWireDB` deployed with **33 tables, 55 FKs, 1 procedure, 1 trigger** and full seed *(the 25/33 figures predate `D-31`)*. ~~FW-001 impact audit complete.~~ — **struck, `D-32`: there is no migration and no audit.**
**Demo:** scaffolded UI ↔ stubbed service ↔ created schema ↔ simulated hub, end to end.
**Gates:** **M1 (14 Aug) hard gate** · **QA0** (Jest smoke; **signed-off manual contract walkthrough + `/health` shape** — 1B carries no automated tests, `[TS §1.2]`; DDL/seed idempotency + post-run table checks) · **effort calibration checkpoint** (model §6).

> **1A, 1B and 1C run in parallel** and converge only on `04-APIContract.md` and the seed fixtures (`R00041–R00043`, `SP-00021`, `RUN-0042/0043`). 1A is not blocked by 1B/1C because it develops against the mock API and mock SignalR (`useMockData: true`); 1B ships stub endpoints first.
>
> **⚠ The model still predicts this gate fails.** **1,027 h** in 12 working days needs **10.7 FTE on Phase 1 alone**. 1A/1B/1C genuinely parallelise, so this is a headcount problem, not a sequencing one, and `D-32` has not changed that — it has moved the requirement from 11.6 FTE to 10.7.
>
> ⚠ **Do not read the new figure as a revert — the collision is a coincidence and it is a trap.** The **1,027 h / 10.7 FTE** that `[CE §2]`–`§5` carry is the **pre-14-Aug basis**, composed differently (it predates the 1B restatements). The 1,027 h above is the **post-`D-32`** figure and is composed **1A 370 · 1B 519 · 1C 138**. Two different derivations that happen to land on the same number; check the composition, never the total, when deciding which basis a document is on. *(`[CE §2]`–`§5` are still deliberately not re-derived — see `[CE §8]`.)*

---

##### S0 · Phase 1A — Angular Foundation

**Spec:** [`phase-01a-angular-foundation.md`](phases/phase-01a-angular-foundation.md) · **Owner:** FE · **370 h** (FE 224 · RT 44 · QA 54 · cont. 48)

---

###### FW-N03 · Angular library scaffold, routing and configuration
**Hours:** 24 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** a `flat-wire` Angular library scaffolded, routed and configured,
**So that** every later phase is pure feature work with no infrastructure lift.

**Acceptance Criteria:**
- [ ] Library generated via `ng generate library flat-wire --prefix=fw --standalone=false` → `projects/flat-wire/`; registered in `angular.json` and `tsconfig` paths
- [ ] Added to the `build:shop-floor` npm chain **for build ordering only** — no UI reuse from any library in that chain (Foundations §0.2)
- [ ] Folder structure `src/lib/{components,components/shared,services,models,guards,styles}` + module, routing and `public-api.ts` — standard Angular-library layout, **not** copied from any existing feature library
- [ ] Lazy-loaded `FLAT_WIRE_ROUTES` under `/flat-wire` with per-line routes (`/flat-wire/line/:lineId/checkin/rod`, `/flat-wire/line/FL2/checkin/spool`, `/flat-wire/line/:lineId/run/active`)
- [ ] `app-config.service` + `environment.*.ts` carry `useMockData`, API base and hub URL; `ui-log.service` wired for client telemetry
- [ ] Library builds and lints clean and does not break the `build:shop-floor` chain

**Rate-card basis:** library scaffold + routing + config + logging + utilities, priced as foundational setup (§2)
**Dependencies:** None — the `shared` foundational services already exist
**Blockers:** —

---

###### FW-130 · Shell layout and the 1280×1024 shopfloor canvas
**Hours:** 16 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As an** operator,
**I want** a consistent shell with header, navigation and an alert slot on a fixed shopfloor canvas,
**So that** every dashboard renders identically on the panel at arm's length.

**Acceptance Criteria:**
- [ ] Shell layout component: header (line context + operator + clock), sidebar nav to all dashboards, `alert-banner` slot
- [ ] Fixed **1280×1024** canvas; renders in both light and `prefers-color-scheme: dark`
- [ ] Consumes the existing semantic design-token system in `../50-frontend/mockups/flat-wire-shopfloor.styles.scss` **as-is** — `--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono`
- [ ] **No `--fw-*` token appears anywhere** — that prefix is stale (**G18**); `ViewEncapsulation.None`/`:host` so tokens resolve
- [ ] Minimum text size **14px** throughout, including form controls, which do not inherit the body font

**Rate-card basis:** shared composite control 20 h, discounted to 16 h — the token system is consumed, not authored (§2, §8 *"no token migration"*)
**Dependencies:** FW-N03
**Blockers:** **G18** (stale token prefix in older source docs) · **G23** (the 1280×1024 canvas is an unconfirmed acceptance criterion — 1920×1080 means a re-layout)

---

###### FW-131 · Route guards, interceptor wiring and the error envelope
**Hours:** 12 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** security owner,
**I want** authenticated, role-gated routes reusing the existing `shared` interceptors,
**So that** no flat-wire screen is reachable without a valid token and the right role.

**Acceptance Criteria:**
- [ ] `FlatWireAuthGuard` (authenticated) and `FlatWireRoleGuard` (role-gated routes) per the Authorization Matrix in [04-APIContract.md](../40-backend/APIs.md)
- [ ] Reuses `shared` `login.service` / `login-api.service` / `token-interceptor.service` (JWT bearer) — **no new interceptors**
- [ ] `correlation-id-interceptor` and `global-error-handler-api` wired
- [ ] Standardises on the `{ success, data, errors[] }` envelope; toast + inline field errors via `error-handler.service`
- [ ] Jest: guard redirects an unauthenticated user; role guard blocks an operator from a restricted route

**Rate-card basis:** shared primitive 8 h + guard/interceptor wiring 4 h (§2)
**Dependencies:** FW-N03
**Blockers:** ~~**G6** (roles not confirmed as existing JWT roles vs new)~~ ✅ **Resolved 15 Aug 2026** — all six exist as JWT claims on `ClaimTypes.Role`. ⚠ Residual: the claim **values** are coded rather than labelled and the mapping is unsupplied — gates verification, not construction

---

###### FW-132 · DI-swappable API client and domain models
**Hours:** 20 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** one API interface with real and mock implementations swapped by DI,
**So that** the whole UI can be built and demoed before the backend is populated.

**Acceptance Criteria:**
- [ ] `flat-wire-api.interface.ts` with `flat-wire-api-real.service.ts` (over `shared` `api-gateway.service`) and `flat-wire-api-mock.service.ts`
- [ ] DI swap driven by the `useMockData` environment flag; mock returns the 1C seed fixtures through the `{success,data,errors}` envelope
- [ ] Models authored: `rod`, `spool`, `pass-schedule`, `active-run`, `checkin`, `weld-event`, `spc-checkpoint`, `signalr-events`
- [ ] `line-context.service` (current FL1/FL2/FL3 scope) and `run-state.service` (active alpha/footage/payoff via RxJS `BehaviorSubject`s — **no NgRx**, which is not used in this repo)
- [ ] **Canonical enums defined once:** `State = 'Active' | 'Bypass' | 'Skip'` (never a boolean `IsActive`) and `EdgeType = 'Round' | 'Square'` with "Round Edge / Flat Edge" as display labels in a pipe

**Rate-card basis:** API client + two implementations + 8 models, priced as a shared composite (20 h, §2)
**Dependencies:** FW-N03; converges with FW-147 (backend enums) and FW-007 (DB `CHECK`s)
**Blockers:** **G14** (contract inconsistencies: 3- vs 4-item inspection, `R#####` vs `ROD-#####`, `FootageFt` INT vs DECIMAL)

---

###### FW-133 · Shared composite controls
**Hours:** 120 h FE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** the six shared composite controls built once from the approved mockups,
**So that** no phase reimplements them and every screen looks like one system.

**Acceptance Criteria:**
- [ ] `pass-schedule-table` — read-only component/state table, honouring `State ∈ {Active, Bypass, Skip}`
- [ ] `payoff-weight-bar` — consumption bar with colour thresholds; used directly by Dashboard 1 and as the Payoffs card's content on Dashboard 3
- [ ] `gauge-trace-chart` — Chart.js streaming shell with target line, tolerance band, green/red points and weld markers *(live wiring, maximize and the runtime source toggle land in FW-081)*
- [ ] `tolerance-viz` — SPC marker on a band; **replaces the retired inline-SVG progress ring**
- [ ] `tab-wizard` — progressive-unlock step strip backing Dashboard 2's six steps
- [ ] `action-bar` — line-mode configurable, **intent-grouped** (Run events · Go to · Run control)
- [ ] All six built fresh from `../Mockups/*.html`; **none derived from `shop-floor-common`, `checkin-precheckin` or any existing UI library** (Foundations §0.2, decision 5)

**Rate-card basis:** 6 × shared composite control @ 20 h = 120 h (§2)
**Dependencies:** FW-130 (tokens)
**Blockers:** **G18**

---

###### FW-134 · Shared primitive controls and `alert-banner`
**Hours:** 32 h FE · **Priority:** High · **Sprint:** S0 · **Phase:** 1A · **Stream:** FE

**As a** developer,
**I want** the shared primitives built once,
**So that** field states, readouts and inspection buttons behave identically everywhere.

**Acceptance Criteria:**
- [ ] Standard `.input` with `.invalid` / `field-error` validation states
- [ ] Monospace numeric readouts for gauge/width/footage
- [ ] Pass/fail `pill-btn` and OK/NG/NA machine-inspection buttons
- [ ] `alert-banner` — raise/clear driven, auto-dismiss on `AlertCleared`
- [ ] `confirm-bar` (amber → green) and `payoff-option` selector cards
- [ ] All pinned to the **14px** floor; `input, select, textarea, button, option` set explicitly, since form controls do not inherit the body font

**Rate-card basis:** 4 × shared primitive @ 8 h = 32 h (§2)
**Dependencies:** FW-130
**Blockers:** —

---

###### FW-135 · SignalR client service
**Hours:** 24 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT

**As an** operator,
**I want** a purpose-built SignalR client that survives reconnects and never storms change detection,
**So that** live traces render at 60 fps without freezing the panel.

**Acceptance Criteria:**
- [ ] `flat-wire-signalr.service.ts` using `@microsoft/signalr` + `@microsoft/signalr-protocol-msgpack` (**MessagePack**)
- [ ] Auto-reconnect with **exponential backoff** and **line-group re-join on reconnect**; JWT via `?access_token=`
- [ ] Callbacks run **outside NgZone** into a **ring buffer**; render throttled by `requestAnimationFrame` (~60 fps); fixed window of the last ~500 points
- [ ] Typed Observables per event
- [ ] **New service — deliberately not derived from `supervisor-monitor-hub`, `CoilDataHub` or `OPCManagerHub`** (Foundations §0.4, decision 4)
- [ ] Verified: streaming a mock trace triggers no change-detection storm under OnPush

**Rate-card basis:** real-time client, priced against §0.4's stated design (24 h)
**Dependencies:** FW-N03
**Blockers:** **G10** (MessagePack dependency / deploy prereqs)

---

###### FW-136 · `MockSignalRService` and the typed event set
**Hours:** 12 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT

**As a** developer,
**I want** a timer-driven mock hub emitting the full typed event set,
**So that** Dashboard 1 and Dashboard 3 shells demo before a live hub exists.

**Acceptance Criteria:**
- [ ] `MockSignalRService` emits `GaugeReading[]`, `WidthReading[]`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`
- [ ] **Also emits `LineStatus`, `AlertRaised` and `AlertCleared`** — the three omitted from `FW-080`'s original list, and the reason command side-effects had no typed client contract
- [ ] Drives a `gauge-trace-chart` live with reconnect and group re-join simulated
- [ ] Jest: emitted events land in the ring buffer with correct types

**Rate-card basis:** hub event set + mock harness (12 h, §2)
**Dependencies:** FW-135
**Blockers:** —

---

###### FW-137 · PWA cache sync and the reconnect banner
**Hours:** 8 h RT · **Priority:** Medium · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT

**As an** operator,
**I want** the last known state cached and a clear reconnect message,
**So that** a short network drop never leaves me looking at a blank screen.

**Acceptance Criteria:**
- [ ] Service worker caches the pass-schedule and active-run snapshot for short drops
- [ ] "Reconnecting…" banner replaces a blank screen; cached last-known state remains visible
- [ ] Banner clears automatically on successful re-join

**Rate-card basis:** shared primitive 8 h (§2)
**Dependencies:** FW-135
**Blockers:** —

---

**Phase 1A reconciliation** — FE `24+16+12+20+120+32 = 224` · RT `24+12+8 = 44` · base **268** → QA `0.20 × 268 = 54` → Cont `0.15 × (268+54) = 48` → **370 h** ✓ (§3b)

---

##### S0 · Phase 1B — Backend Foundation

**Spec:** [`phase-01b-backend-foundation.md`](phases/phase-01b-backend-foundation.md) · **Owner:** BE + RT · **519 h** (BE 249 · RT 124 · QA 78 · cont. 68)

> **The largest single layer in the plan** — needs **5.4 FTE** on its own. Template is `API/Domain/CoilCheckin` (controller, MediatR command, `Program.cs`, `.csproj`, NuGet set). **`SlitterInterface` is explicitly NOT a reference** (`[ARC §2.2]`, `D-06`).
>
> **This header was stale at 442 h through both the 14 Aug and 15 Aug restatements** — corrected 15 Aug 2026 along with §7's reconciliation, the phase summary table and the S0 total. The figure history is **442 → 469 (14 Aug) → 541 (15 Aug, `D-29`) → 519 (15 Aug, backend tests withdrawn + `SpoolController`)**; the reconciliation below §7 is the derivation of record.

---

###### FW-N04 · `FlatWire` solution and four-project Clean Architecture skeleton
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** the `FlatWire` microservice solution created to the `CoilCheckin` pattern,
**So that** every later phase adds commands and queries only.

**Acceptance Criteria:**
- [ ] `API/Domain/FlatWire/` with `FlatWire.sln` and four projects — `FlatWire.API` / `.Application` / `.Domain` / `.Infrastructure`
- [ ] Project references: `API → Application, Domain, Infrastructure`; `Application → Domain`; `Infrastructure → Domain`
- [ ] `.csproj` and NuGet set copied from `CoilCheckin`
- [ ] `FlatWire.sln` builds; `FlatWire.API` boots under Development

**Rate-card basis:** solution scaffold from an existing template (16 h, §2)
**Dependencies:** None
**Blockers:** —

---

###### FW-138 · Fifteen thin controllers over `UAController`
**Hours:** **45 h BE** *(was 56)* · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

> **Restated 25 Aug 2026: fifteen controllers → fourteen. `RodReceivingController` is withdrawn — rod receiving is not shopfloor.** The `FlatWire` service hosts no `/rod/**` surface: **#8 `GET /rod/{alpha}`, #9 `POST /rod` and `[API §4.20]` `GET /rod/{alpha}/orders`** all leave with it, taking this story to **22 endpoints across 12 controllers**. Recorded as decision `P-53` in [`FW-138`](../40-backend/tasks/FW-138.md) §5, applied in `[API §3.1]` the same day. ⚠ **The hours cell above is NOT restated** — the rate-card basis becomes 14 × 3 h = **42 h**, and that −3 h is **owed to the next re-baseline**, additively, because re-deriving in place desynchronises `[CE]`, `[DE]`, `[SSP]`, `[TRP]` and §11's reconciliation. ⚠ **#8 and §4.20 are specified and unhosted, not withdrawn**: `FR-042`, `FR-064`, `FR-043`'s carry-forward gate and `Q24`'s station switching have no endpoint until `[API]` re-homes them (`P-54`), and **DB2 — a trial screen — scans a rod.** `RodReceivingController.cs` was **deleted from `ual-api` on 25 Aug 2026** once the five affected documents were corrected; `git restore` from `FW-N04`'s commit reverses it.

> **Restated 15 Aug 2026: 56 → 45 h, on two changes pulling opposite ways.** **(−)** The query-endpoint rate this story is priced at (4 h) bundles a unit test per `[CE §2]`; with backend tests withdrawn (`[TS §1.2]`) the rate is **3 h** and the **stub contract suite** goes with it. **(+)** **Fourteen → fifteen controllers**: `[API §3.1]` omitted **`SpoolController`** while §3.2 assigned `GET /spools` to it, so an MVP-1 endpoint had no host — resolved in `[API §3.1]` on 15 Aug 2026. **15 × 3 h = 45 h.** The controllers and their stub fixtures are unchanged; only the suite asserting them is gone.

> **Corrected 14 Aug 2026: thirteen → fourteen, 52 → 56 h.** `[API §3.1]` has always listed **fourteen** controllers; `PayoffStagingController` — which owns **four of the 30 endpoints** (10, 11, 12, 14, the whole DB2A pre-check-in surface) — was never counted. This is an arithmetic correction against the story's own source, not new scope.

**As a** developer,
**I want** every controller present and returning the standard envelope from day one,
**So that** the Angular library can build against the real service before any handler exists.

**Acceptance Criteria:**
- [ ] All **fourteen** exist and extend `UAController`: `LinesController`, `PassScheduleController`, **`PayoffStagingController`**, `CheckInController`, `RunController`, `SpcController`, `WeldEventController`, `RollAdjustController`, `DieChangeController`, `CheckOutController`, `WipRejectionController`, **`SpoolController`**, `CoilController`, `ShiftSummaryController`. ⚠ **`RodReceivingController` was the fifteenth and is withdrawn** (`P-53`, 25 Aug 2026) — `FW-N04` built it and the class was **deleted the same day**, the solution rebuilding clean
- [ ] **`SpoolController` covers `GET /spools`** — endpoint 16a, `FR-097`–`FR-099`, DB5/DB5A. ⚠ It is **MVP-1** and Phase 8; it was absent from `[API §3.1]` until 15 Aug 2026 while §3.2 already assigned it, so it is the one controller with no prior story coverage
- [ ] **`PayoffStagingController` covers `/payoff/status` and `/staging/**`** — endpoints 10, 11, 12 and 14. ⚠ Endpoint 13 (`POST /staging/rod/mark-welded`) was **retired 1 Aug 2026** in favour of `POST /weldevent` as the single weld write — **do not scaffold it**
- [ ] ⚠ **`POST /staging/rod` returns `201 Created` with `state:"Blocked"` on inspection failure** — the row is committed **before** the inspection gate, and it is still a hard block with no override. `Blocked` is a **derived** bay state, never a stored `Status`, and `POST /wipreject` is the only thing that clears it (**G21**)
- [ ] Each returns the `{Data, Success, Errors}` envelope
- [ ] **`[Authorize]` on every controller and every endpoint** — no bare `ControllerBase`, no unprotected route
- [ ] Stub endpoints return schema-valid fixtures for the seed alphas, per `[API §4]` shapes
- [ ] ⚠ **The stub endpoints stay; the suite that asserted them is withdrawn** (15 Aug 2026, `[TS §1.2]`). `[API §7.2]`'s five obligations are verified by the **signed-off manual contract walkthrough** at QA0 (`[TS §4.2]`), not by xUnit. **1A still builds against these stubs** — dropping the test does not drop the fixtures

**Rate-card basis:** 14 controllers @ 4 h = 56 h (§2, query-endpoint rate for scaffold + stub), **less the withdrawn contract suite → 42 h** (15 Aug 2026)
**Dependencies:** FW-N04
**Blockers:** —

> `PassScheduleController` and `ShiftSummaryController` are scaffolded here but their handlers are **MVP-2**. They exist so the contract surface is complete and the Angular client has a stable base URL set.

---

###### FW-139 · MediatR registration and pipeline behaviours
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** MediatR wired with validation and logging behaviours,
**So that** every command gets cross-cutting concerns without repeating them.

**Acceptance Criteria:**
- [ ] `Commands/` and `Queries/` folders per `04-APIContract.md`
- [ ] MediatR registered in `Program.cs` (copied from `CoilCheckin.API/Program.cs`)
- [ ] Pipeline behaviours for validation and structured logging
- [ ] A sample command round-trips controller → MediatR → handler → envelope

**Rate-card basis:** cross-cutting infrastructure (16 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-140 · DI registration and the stub/real service swap
**Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** interface-driven services swappable between stub and real by configuration,
**So that** 1A can integrate before the database is populated.

**Acceptance Criteria:**
- [ ] `Program.cs` service registration; every service behind an interface
- [ ] `useMockData` / environment swap of stub vs real implementations
- [ ] With `useMockData` on, the API serves schema-valid fixtures end to end

> ⚠ **Corrected 25 Aug 2026.** The flag is **`useMockData`**, not `useStub` — `phase-01b` L84 and
> `[API §7.1]`; a backend flag named differently from 1A's means the two halves of the stub
> contract are configured by two switches that can disagree. And *"as in `CoilCheckin`"* is struck
> from criterion 2 because **there is no such pattern** — `CoilCheckin`'s `AddPersistence` takes
> `IConfiguration` and never reads it, and no domain in `ual-api` carries a stub swap. See
> [`FW-140 §2.1`](../40-backend/tasks/FW-140.md).

**Rate-card basis:** DI + configuration swap (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-141 · Repository layer — one per aggregate root
**Hours:** 28 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** repositories behind interfaces for each aggregate,
**So that** handlers never touch a connection directly.

**Acceptance Criteria:**
- [ ] `FlatWire.Infrastructure/Repositories/` with `PassScheduleRepository`, `RodRepository`, `RunRepository`, `CoilRepository` and siblings, each behind an interface
- [ ] `RodRepository` reads the shared `coils` table (cross-database, unenforced link)
- [ ] Unit tests cover each repository against the seeded fixtures

**Rate-card basis:** 5 repositories @ 4 h = 20 h (§2, table rate covers repository)
**Dependencies:** FW-N04, FW-006
**Blockers:** **G17** (rod→`coils` multiplies cross-DB logical FKs)

---

###### FW-142 · Dapper/EF data access and `FlatWireDbContext`
**Hours:** 24 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** developer,
**I want** the mixed Dapper/EF convention wired against `FlatWireDB`,
**So that** high-volume reads stay fast and entity writes stay typed.

**Acceptance Criteria:**
- [ ] **Dapper** for high-volume reads — gauge trace, list grids, report aggregations
- [ ] **EF Core `FlatWireDbContext`** for entity writes, mapped to all **25 MVP-1 tables** (`Rod` **is** among them per `D-04`; 28 in the full design — `[DBD §6.2]`)
- [ ] A smoke insert→select round-trips through EF against every table
- [ ] **The three `PassSchedule*` tables are not mapped** — they are owned outside MVP-1

**Rate-card basis:** context + mapping across 24 tables, priced as a non-trivial service (24 h, §2). ⚠ **The table count in this derivation is stale — flagged, not substituted (23 Aug 2026).** The live figure is `[DBD §6.2]`. Replacing the count without re-deriving the hours would make the arithmetic lie, and per the standing convention an effort change lands in an **additive new sheet, never an in-place edit of a total**. **Owed: re-derive against `[DBD §6.2]` using `[CE §2]`'s rate card** — `[CE]`'s owner, not this document's.
**Dependencies:** FW-N04; converges with FW-006 / FW-007
**Blockers:** —

---

###### FW-143 · Serilog structured logging and the audit log
**Hours:** 12 h BE · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** compliance owner,
**I want** every PLC push and schedule override written to an audit log,
**So that** a machine configuration can be reconstructed after the fact.

**Acceptance Criteria:**
- [ ] Serilog wired to the inherited UAL configuration; structured logs throughout
- [ ] **Audit log** entries for PLC pushes (tag, value, operator, result) and pass-schedule overrides
- [ ] Audit entries are queryable by run and by operator

**Rate-card basis:** logging + audit sink (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-144 · Configuration binding
**Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** deployer,
**I want** every environment-specific value bound from configuration,
**So that** no tag path, connection string or cadence is compiled in.

**Acceptance Criteria:**
- [ ] `appsettings.{Environment}.json` carries the **`FlatWireDB`** connection string, JWT settings and SignalR settings (MessagePack, keep-alive/timeout, cadence)
- [ ] **OPC tag-path map is config-driven, not hardcoded** — the map's contents are owned by [`PLCTagSpecification.md`](../20-architecture/PLCTagSpecification.md); this story binds it, it does not author it
- [ ] `SimulatePLCTagPush` is a configuration flag, switchable without a rebuild

**Rate-card basis:** configuration binding across four concern groups (12 h, §2)
**Dependencies:** FW-N04
**Blockers:** **`PLC-Q05`** (the measure segment of every tag path is ours, not the controller's — **G33**)

---

###### FW-145 · JWT authentication and role authorization policies
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** security owner,
**I want** role policies matching the Authorization Matrix,
**So that** each endpoint admits only the roles that should reach it.

**Acceptance Criteria:**
- [ ] JWT bearer authentication inherited from the UAL configuration
- [ ] Hub authentication via `?access_token=` query parameter
- [ ] Role policies for Operator / Operations Manager / Maintenance / Supervisor / Admin, matching `04-APIContract.md`'s matrix
- [ ] Authorization tests prove an operator cannot reach an Ops-Manager-only endpoint

**Rate-card basis:** auth + five role policies (16 h, §2)
**Dependencies:** FW-N04
**Blockers:** ~~**G6** (roles not confirmed as existing JWT roles vs new)~~ ✅ **Resolved 15 Aug 2026** — all six exist as JWT claims on `ClaimTypes.Role`. ⚠ Residual: the claim **values** are coded rather than labelled and the mapping is unsupplied — gates verification, not construction

---

###### FW-146 · Global exception middleware and the response envelope
**Hours:** 8 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As a** client developer,
**I want** every failure mapped to a predictable status and envelope,
**So that** the UI can branch on a contract rather than on a message string.

**Acceptance Criteria:**
- [ ] Global exception middleware maps to `400` validation, `404` not found, `409` conflict, `422` unprocessable, `500` PLC/server
- [ ] Every response — success or failure — uses the `{Data, Success, Errors}` envelope
- [ ] Tests assert each status path

**Rate-card basis:** shared primitive (8 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-147 · FluentValidation, value objects and the canonical cross-layer enums
**Hours:** **12 h BE** *(was 16)* · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

> **Restated 15 Aug 2026: 16 → 12 h** — the validator unit tests are withdrawn (`[TS §1.2]`). **The validators themselves are production code and stay.**

**As a** developer,
**I want** command validation and one canonical enum definition per concept,
**So that** the Angular model, the backend enum and the database `CHECK` cannot drift.

**Acceptance Criteria:**
- [ ] FluentValidation per command; sample rules implemented — `FM2_S3` must be Active; FL3 requires Hybrid; `PassScheduleComponent.State ∈ {Active, Bypass, Skip}`
- [ ] **`CheckpointType` is five-valued** — `{PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun}`. `RollAdjustTrigger` was missing and is required by `/rolloverride`'s side-effect
- [ ] **`EdgeType ∈ {Round, Square}`** — one vocabulary, not three
- [ ] **`State` is an enum, never a boolean `IsActive`**
- [ ] All three match FW-132 (Angular models) and FW-007 (DB `CHECK`s). ⚠ **Validator unit tests are withdrawn** (15 Aug 2026, `[TS §1.2]`) — the three-way agreement is `TC-020`, now a **manual diff across 14 enums with a named owner**, not a green build

**Rate-card basis:** validation layer + enum definitions (12 h, §2), **less the withdrawn validator tests → 12 h** (15 Aug 2026)
**Dependencies:** FW-N04
**Blockers:** —

> **`RollAdjustTrigger` is load-bearing.** Phase 8 wires the FL2 roll-adjust button against it; if 1C ships a four-value `CHECK`, that button fails at write time. Verify all three layers agree before S2.

---

###### FW-148 · Health checks
**Hours:** 8 h BE · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

**As an** operations engineer,
**I want** a health endpoint covering the database and OPC reachability,
**So that** a failing dependency is visible before an operator finds it.

**Acceptance Criteria:**
- [ ] ASP.NET Core health checks at `/health` covering DB and OPC reachability
- [ ] `/health` green in Development, with OPC reporting simulated-healthy
- [ ] Unhealthy dependency returns a non-200 and names the failing check

**Rate-card basis:** shared primitive (8 h, §2)
**Dependencies:** FW-N04
**Blockers:** —

---

###### FW-080 · `FlatWireHub` — strongly-typed, MessagePack, line groups
**Hours:** **28 h RT** *(was 32)* · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

> **Restated 15 Aug 2026: 32 → 28 h** — the automated hub smoke harness is withdrawn (`[TS §1.2]`); the behaviour moves to the QA0 manual walkthrough.

**As an** operator,
**I want** a purpose-built hub streaming per-line telemetry,
**So that** three lines can be watched live without a page refresh.

**Acceptance Criteria:**
- [ ] `FlatWire.API/Hubs/FlatWireHub.cs` as a **strongly-typed `Hub<IFlatWireClient>`**
- [ ] **MessagePack** via `AddSignalR().AddMessagePackProtocol()`; WebSockets-first with `SkipNegotiation` where topology allows
- [ ] `[Authorize]`; `JoinLineGroup` / `LeaveLineGroup` over groups `FL1Data` / `FL2Data` / `FL3Data`
- [ ] **Hosted only inside `FlatWire.API`** — the shared `Notification` service is not extended, and `CoilDataHub` / `OPCManagerHub` / `supervisor-monitor-hub` are **not** templates (Foundations §0.4, decision 4)
- [ ] Stateless hub; Redis / Azure SignalR backplane is a **config-only** path if the API goes multi-instance
- [ ] ⚠ **The automated smoke test is withdrawn** (15 Aug 2026, `[TS §1.2]`). The behaviour it covered — a client joining `FL1Data` receiving simulated batched `GaugeReading[]` at cadence, and re-joining after a reconnect — moves into the **manual contract walkthrough** at QA0 (`[TS §4.2]`, obligation 5). It is still verified; it is no longer verified by a harness

**Rate-card basis:** hub infrastructure priced against `[SIG §4]`'s stated design (32 h), **less the withdrawn smoke harness → 28 h** (15 Aug 2026)
**Dependencies:** FW-N04, FW-145
**Blockers:** **G10** (deploy prereqs — IIS WebSockets feature) · **G9 / OI-34** (NFRs undefined; the load test in FW-156 has no pass criteria)

---

###### FW-149 · `IFlatWireClient` typed event contract
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As a** developer,
**I want** one typed contract covering every event the backend broadcasts,
**So that** a command side-effect cannot broadcast an event the client has no type for.

**Acceptance Criteria:**
- [ ] `IFlatWireClient` in `FlatWire.Domain` carries the **full** set: `GaugeReading(GaugeReading[])`, `WidthReading(WidthReading[])`, `SpeedFPM`, `PayoffWeight`, **`PayoffStateChanged`**, `FootageCounter`, `ComponentStatus`, **`LineStatus`, `AlertRaised`, `AlertCleared`**
- [ ] SCADA markers included: `WeldJoinEvent`, `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint`, `RodCheckoutEvent`
- [ ] Matches FW-136's client-side typed set exactly
- [ ] **Naming:** the aggregate, table, endpoint and story all say **`WeldEvent`**; `WeldJoinEvent` survives only as the SignalR method name and is documented as such

**Rate-card basis:** 2 × hub event group @ 8 h = 16 h (§2)
**Dependencies:** FW-080
**Blockers:** —

---

###### FW-N05 · OPC ingest hosted service and bounded channel
**Hours:** 32 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As an** operator,
**I want** PLC tag values ingested continuously without the service falling behind,
**So that** a slow consumer degrades resolution rather than crashing the pipeline.

**Acceptance Criteria:**
- [ ] `IHostedService` in `FlatWire.Infrastructure` reads FL1/FL2/FL3 tags via the existing `OPCConnection` domain
- [ ] Readings land in a **bounded `System.Threading.Channels.Channel<Reading>`** with **drop-oldest / coalesce** on overflow — backpressure degrades resolution, never memory
- [ ] Tag paths come from configuration (FW-144), never from code
- [ ] Integration test: a burst faster than the drain rate coalesces rather than growing unbounded

**Rate-card basis:** OPC ingest priced against §0.4's backpressure-safe design (32 h)
**Dependencies:** FW-144, FW-080
**Blockers:** **`PLC-Q05`** / **G33** · **G29** (no edger tag path exists on any line) · **G32** (FM2 station names are ours, not the controller's)

---

###### FW-150 · Cadence-driven broadcast loop
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As an** operator,
**I want** telemetry batched at a fixed cadence and rare events sent immediately,
**So that** the panel stays responsive under a full three-line load.

**Acceptance Criteria:**
- [ ] Drains the channel on a **fixed cadence (default ~100 ms / 10 Hz)**, sending **batched arrays** per line group
- [ ] Hot numeric channels decimated to cadence; `ComponentStatus` / `LineStatus` sent **on change only**
- [ ] **Rare domain events sent immediately and unbatched** — they must not enter the 10 Hz batch
- [ ] **FL2 standalone suppresses batched gauge/width** and broadcasts `null`; the historical profile is a REST query
- [ ] Cadence is configuration-driven (FW-144)

**Rate-card basis:** 2 × hub event group @ 8 h = 16 h (§2)
**Dependencies:** FW-N05, FW-149
**Blockers:** **G9 / OI-34** (AGC sample rate undefined)

---

###### FW-151 · `PLCTagService` skeleton and `SimulatePLCTagPush`
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

**As a** developer,
**I want** the PLC write surface built with a simulate mode from the start,
**So that** every check-in phase can be developed and demoed before commissioning.

**Acceptance Criteria:**
- [ ] `FlatWire.Infrastructure/Services/PLCTagService.cs` with `PushPassSchedule(...)` and `ClearPayoffTags(...)`, batch write
- [ ] **`SimulatePLCTagPush` dev mode** logs an audit entry instead of writing, and is switchable by configuration
- [ ] ⚠ **OPC writes are not transactional.** Failure recovery is modelled as **compensating re-clears**, and the code and comments say so — **the word "rollback" does not appear** (**G2**; `G16` closed 4 Aug 2026)
- [ ] The saga/compensation boundary for a cross-database check-in is documented in the service

**Rate-card basis:** PLC tag group push + compensating clear @ 16 h (§2)
**Dependencies:** FW-144
**Blockers:** **G2 / OI-39** (cross-DB check-in recovery undecided — saga/outbox vs `INFLAT` mirror; carries the 24–64 h Phase-4 reserve)

> **This is the service; `FW-082` is its use at check-in.** Splitting them keeps `FW-082`'s cited meaning — *"PLC tag push on check-in ack"* — intact while giving the S0 scaffold its own card.

---

###### FW-203 · OPC feed simulator — a stand-in for the real ingest
**Hours:** 8 h RT · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

> **New 14 Aug 2026 for the six-screen trial run** ([`TrialRunPlan.md`](TrialRunPlan.md) §1.4). It **replaces
> `FW-N05`** (real OPC ingest, 32 h) *for the trial only* — `[DE §1]` prices that work at retention **0.90** and
> calls it *"not verifiable without the hardware"*, so it moves to the October commissioning window. **`FW-N05` is
> not cancelled**; this story is what lets the trial run without it. Hours are **additional to `[CE §3b]`**.

**As a** developer,
**I want** a synthetic gauge, width, speed, weight and footage feed on the same contract the real ingest uses,
**So that** every screen can be built, demonstrated and accepted before a controller is available.

**Acceptance Criteria:**
- [ ] Publishes to the **same bounded channel** `FW-N05` will publish to, at the same cadence, so `FW-150`'s broadcast loop is unchanged when the real ingest arrives
- [ ] Drives `GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus` and `LineStatus` for **FL1**
- [ ] ⚠ **FL2 is driven too, and only gauge/width are suppressed.** `[SIG §5.3]` suppresses **only** the batched gauge and width channels on FL2 — `SpeedFPM`, `FootageCounter`, `ComponentStatus` and `LineStatus` **still flow**, and `FR-120` makes live gauge/width **`null`**. Two of the six trial screens are FL2 (DB5, DB3-FL2) and `[TRP §8]` step 9 requires Profile to stay static *"across several live ticks"* — which needs FL2 ticking. **A simulator that drives FL1 only leaves both FL2 screens dead**
- [ ] Traces can be steered to produce **in-spec, drifting and out-of-spec** runs, so the `FR-119` reconnect path and Dashboard 3's N-consecutive-out-of-spec auto-prompt are both demonstrable
- [ ] Drives a `RUNNING → STOPPED` edge on demand, which is what `FW-202`'s stop-confirmation state machine is armed by
- [ ] **Switchable by configuration alongside `SimulatePLCTagPush`** — one flag pair puts the whole system in simulation
- [ ] ⚠ **Adds no interface of its own.** If the simulator needs a contract change, the contract is wrong — that is the whole reason `FW-150` and `FW-151` are not reduced for the trial

**Rate-card basis:** non-trivial service, low end @ **8 h** (§2) — the contract already exists, so this is a publisher against it, not a design. **6 h AI-assisted** at `[DE §1]`'s 0.75 RT factor, which is the figure `[TRP §4]` schedules
**Dependencies:** FW-N05 *(contract only — this story implements the other side of it)*, FW-150
**Blockers:** **G9 / OI-34** *(the real-time NFRs are undefined, so the simulator has no target cadence to match — pick one and record it)*

---

###### FW-218 · Trial control surface for the feed generator — steer, stop, drop, read
**Hours:** 18 h BE · **Priority:** Critical · **Sprint:** S1 · **Phase:** 1B · **Stream:** BE

> **New 15 Aug 2026.** `[TRP §8]`'s acceptance run requires the simulated feed to be **steered while a run is
> live**. `FW-203` is a publisher and has **no control surface** — `[SIM §1.2]`'s own comparison table marks it
> ❌ on *"an operator-drivable control surface"* — and `FW-215`'s five endpoints are unscheduled post-trial work
> that depends on `FW-210` and `FW-213`, neither of which is in the trial. **This is the three endpoints the
> trial actually needs**, built over `FW-203` rather than over the line model. It is the **first increment of
> `FW-215`**, the same relationship `FW-203` has to `FW-211` — a superset, not a replacement. Hours are
> **additive to `[CE §3b]`**, like `FW-202`, `FW-203` and `FW-204`.

**As a** test engineer running the trial,
**I want** to steer and stop the simulated line while a run is live,
**So that** the acceptance run's out-of-spec, stop-edge and missing-data assertions can be executed at all.

**Acceptance Criteria:**
- [ ] `POST /sim/{lineId}/steer` — move gauge and width toward or away from target **on a live run**, which is what `[TRP §8]` step 3's *"force N consecutive out-of-spec readings"* requires and what Dashboard 3's auto-prompt threshold is measured against
- [ ] `DELETE /sim/{lineId}/run` — a `RUNNING → STOPPED` edge **at a chosen instant**, so `TC-171`'s **3 s stop against a 5 s dwell** and `TC-172`'s **weight latched at the stop timestamp** are executable. ⚠ **Configuration plus a restart cannot do this** — it destroys the run being demonstrated, and step 7's prompt-durability and step 10's reconnect assertions both need the run to survive
- [ ] `POST /sim/{lineId}/fault` — **one fault only, dropped readings.** It is the sole way to exercise `FW-205`'s condition 5 (*two or more consecutive recordings missing*); the rest of `[SIM §7.2]`'s catalogue is `FW-213` and stays out
- [ ] `GET /sim/state` — all three snapshots in one read, **so `FW-214`'s console populates on load without polling**. Added 15 Aug 2026 when the console entered trial scope; it is the fourth of `[SIM §8.1]`'s five, and `POST /sim/{lineId}/run` is the one that stays out (the trial starts runs through check-in, not through the simulator)
- [ ] ⚠ **Routes are not registered at all when simulation is off — `404`, not `403`** (`[SIM §2.4]`). A present-but-forbidden control plane is one misconfigured role away from driving a live line
- [ ] `Engineer` / `Admin` policy on top of that, **never `Operator`** (`[SIM §8.4]`)
- [ ] ⚠ **Not among `[API]`'s 30 endpoints** and must not be added to that count — an engineering surface on a separate prefix (`[SIM §8.2]`)
- [ ] **Adds nothing to the telemetry contract.** `FW-150` and `FW-151` are unchanged — the same rule that makes `FW-203` a publisher against an existing contract rather than a design

**Rate-card basis:** 3 command endpoints @ 5 h + 1 query @ 3 h = **18 h** (§2, at the **15 Aug 2026 restated** rates). **11 h AI-assisted** at `[DE §1]`'s 0.60 backend factor, which is the figure `[TRP §4]` schedules
**Dependencies:** FW-203, FW-138, FW-145
**Blockers:** —

> ⚠ **`FW-218` is not in the Phase 1B reconciliation below** and must not be folded into it — trial-run scope,
> additive to `[CE §3b]`, exactly as `FW-203` is. It does **not** offset `FW-215`'s 23 h either: the remaining
> two endpoints, the console and the line model behind them are all still to be built.

---

###### FW-219 · FL2/FL3 run-end write-back into the shared schema
**Hours:** 40 h (DB 26 · BE 14) · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** DB + BE

> **New 18 Aug 2026, client-directed.** Until now a completed FL2/FL3 coil was written **only** to
> `FlatWireDB`. From `proddb`/`united_db`'s point of view the finished goods did not exist: no `coils` row,
> no order link, no genealogy, no cost record, no skid, no WIP log entry — and **not one of those tables was
> named anywhere in this repository**. Packing, shipping, certification, cost and yield all read them.
> Specified as `FR-509`–`FR-518` and `[INT §8.1]`; the procedure is drafted at
> [`Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql`](../Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql).
> **It closes `OI-104`** — the skid table `CoilOutput.SkidId` has always pointed at, which no document named,
> is `united_db..wip_skids` + `proddb..wip_skid_coils` — which makes **`FR-339` testable for the first time**.
> Hours are **additive to `[CE §3b]`**, like `FW-202`, `FW-203`, `FW-204` and `FW-218`. Gap **`G44`**.

**Acceptance Criteria:**
- [ ] `united_db.dbo.FlatWire_CompleteCoilOnSkid` deployed, writing **eight** shared objects in **one transaction**: `proddb..coils` · `proddb..wip_coil_orders` · `united_db..coil_gen_history` · `coil_cost` (via `CoilCost_UpdateInsert`) · `SlitterDB..coil_slit_cuts` · `united_db..wip_skids` · `proddb..wip_skid_coils` · `proddb..wip_log_view`
- [ ] **Every write lands in a column that already exists** — no rename, no new column, no new status value, so `D-32` is verifiably untouched
- [ ] The shared coil identity comes from `CommonDB.dbo.GenerateCoilAlpha(rodAlpha, '')` and is persisted on **`CoilOutput.CoilNo`** (new column, `VARCHAR(9)`, filtered-UNIQUE `UX_CoilOutput_CoilNo`). `coils.coil_no` is `char(9)`; `FW-#####-C##` is twelve characters and is **never** written to the shared schema (`FR-509`)
- [ ] `CoilOutput.SharedSkidNo` (new column) holds the legacy `char(9)` skid number from `proddb..generate_new_skid_no`, satisfying `FR-339`'s *"follow the existing skid rules"*
- [ ] **One call per coil, never batched** — `coils_iud_tg` gates on `@ins_count = 1`, so a set-based insert silently skips the `coil_link_master_coil` row
- [ ] `Coil1Of2` opens a skid with `IsComplete = 0`; `Coil2Of2` closes it with `IsComplete = 1`; a third coil is refused (`FR-335`, `FR-515`). ⚠ `wip_skids.IsComplete` is `NOT NULL` with no default and is **absent from `proddb..wip_skids`**, so the insert must target `united_db..wip_skids` — the view cannot be inserted through
- [ ] Exactly **one** `coil_slit_cuts` row per coil, supplying `cutMovementCount` and `under_review` (both `NOT NULL`, no default) and a **derived** `skid_coil_seq_no` of 1 or 2 — every legacy template hard-codes 1, which flat wire cannot use
- [ ] All **44** `wip_log` columns supplied, with the `(wip_log_rev_time, seq_no)` collision resolved by the second-granularity spin from `coils_iud_tg`
- [ ] `CoilCompletionService` resolves the **primary source rod** (lowest `CoilTraceability.FootageFrom`) for the genealogy parent, and documents that the shared tree holds **one** parent while `CoilTraceability` remains authoritative for a welded coil (`OI-113`)
- [ ] **The retry contract works and is tested:** `CoilNo` is persisted the moment the procedure returns, and a retry passing it back through `@expectedCoilNo` is a **no-op**. Without it a retry mints a *second* coil
- [ ] A procedure failure rolls back its whole half and is **surfaced for operator retry, not swallowed** — the two halves are compensating writes, not one ACID transaction (`[ARC §10]`)
- [ ] Out-of-spec final SPC takes the **existing** hold vocabulary — `skid_status = 'HOLDP'` plus a `SKIDHOLD`/`PRHOLD` WIP log row — not a flat-wire-only status (`FR-517`)
- [ ] `FlatWire` service granted read/write on `proddb`, `united_db`, `SlitterDB` and `CommonDB` (extends `FW-144`)
- [ ] ⚠ **Does not release `wip_stations.coilno`.** That is `OI-112`, it belongs to *run* completion, and it is unspecified — do not bolt it on here

**Rate-card basis:** procedure 32 h hand-coded @ **0.75** (`[DE §1]` *non-trivial business service* — it is domain reasoning against an undocumented legacy schema with triggers, **not** the 0.60 mechanical-DDL case) = 24 h · `CoilOutput` columns, 2 indexes and schema docs 4 h @ 0.60 = 2 h · `CoilCompletionService` call, primary-rod resolution, retry/compensation and grants 20 h @ 0.70 = 14 h. **56 h hand-coded → 40 h AI-assisted.** All-in on `[CE §2]`'s uplifts: `56 → QA 11 → cont. 10 = **77 h**`, which belongs in an additive restatement (`[CE §3d]`) and **not** in Phase 9's published 222 h.

> ⚠ **The drafted procedure is not a finished 40 hours.** Its structure, its 43/44-column lists and every column name are verified against the scripted DDL, which is what the 0.75 factor buys. What remains is the expensive half and is **not** assisted: executing it against a real `proddb`/`united_db`/`SlitterDB`, confirming the trigger side effects fire as read, and closing `Q34`–`Q36` and `OI-114` with IT.

**Dependencies:** FW-066, FW-141, FW-142, FW-144
**Blockers:** **Q34** (the eight-character transaction token), **Q35** (`coil_status = 'ONSKID'` for finished flat wire), **Q36** (sample number / planned operations) — all three must close before this runs outside DEV. **`OI-114`** (cut-record sentinels) is not a hard blocker: the procedure parameterises them, so a wrong answer is a one-line change.

---

###### FW-220 · FL1/FL3 check-in write-back into the shared schema
**Hours:** 32 h (DB 24 · BE 8) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB + BE

> **New 19 Aug 2026.** `FR-077` has named four shared writes at check-in since it was written — the reqsum
> into `wip_coil_orders`, `actual_start_date` on `planning_routings` and `routings`, and the
> `wip_stations.coilno` claim — and **there was no procedure, script or code for any of them.** The same
> absence `FW-219` found at the other end of the run. Specified as `FR-519`–`FR-528` and `[INT §8.0]`;
> the procedure is drafted at
> [`Database/Scripts/40_united_db_Proc_FlatWire_CheckInRod.sql`](../Database/Scripts/40_united_db_Proc_FlatWire_CheckInRod.sql),
> the plan at [`FW-220.md`](../40-backend/tasks/FW-220.md).
> **It largely closes `OI-111`** — stamping the rod's `coils` row with `wip_station` restores what the
> shared schema lost when `D-32` cancelled `FW-002`, without touching the status vocabulary.
> Hours are **additive to `[CE §3b]`**, like `FW-202` and `FW-219`. Gap **`G45`**.

**Acceptance Criteria:**
- [ ] `united_db.dbo.FlatWire_CheckInRod` deployed, writing **nine** shared objects: `routings` (copied from `planning_routings`, all 94 columns) · `mfg_sales_order_ref` · `routings_orders` · `proddb..wip_coil_orders` · `wip_orders` (via `del_or_upd_wip_orders`) · `planning_routings.actual_start_date` · `routings.actual_start_date`/`machine_idx`/`actual_weight_on` · `CommonDB..WIPStations` · `proddb..coils` rod stamp · `proddb..wip_log_view`
- [ ] **Every write lands in a column that already exists** — `coil_status` is never written, and `'INFLAT'` in `wip_log.coil_skid_status` was **rejected** in favour of the existing `'INROLL'`, so `D-32` is verifiably untouched
- [ ] ⚠ **The procedure does NOT open a transaction — the caller does**, and it asserts `@@TRANCOUNT > 0` rather than assuming. This is the opposite of `FlatWire_CompleteCoilOnSkid` and both headers say why
- [ ] **The database half of check-in is one ACID transaction**: one `SqlConnection`, one `SqlTransaction`, EF writes first, the procedure **last**, commit, then the PLC push. **Requires `FlatWireDB` co-located with the shared databases** — verify before building on it
- [ ] The `Rod` mirror is upserted **first**, inside the same transaction — `FK_RodCheckin_Rod` is an enforced FK and `OI-42` says nothing reliably populates the mirror
- [ ] `machine_idx` is a **validated parameter**, not derived: `IsRollingOpLetter` matches only `'R'`, so the legacy CASE falls to its ELSE branch for the flattening letter `'F'`
- [ ] `actual_start_date` writes are guarded on the `'1800-01-01'` sentinel, so a **partial-rod re-check-in** is a no-op rather than a false restart
- [ ] All **44** `wip_log` columns supplied, with the `(wip_log_rev_time, seq_no)` collision resolved by the second-granularity spin from `coils_iud_tg`, **scoped to include `seq_no`**
- [ ] Weights beyond the `smallint` bound on `WIPStations` are **refused**, not truncated
- [ ] Re-entry inside one transaction is a **no-op** — the station claim and `actual_start_date` are their own evidence, so no caller-held retry token is needed (unlike `FW-219`)
- [ ] `FlatWire` service granted read/write on `united_db`, `proddb`, `CommonDB`, `SlitterDB` and `wiplogdb` via `20_FlatWire_Grants.sql` (extends `FW-144`) — `[public]` membership is **per database**
- [ ] ⚠ **FL2 is refused** (`@lineId` validated against FL1/FL3). Its shared write set is undefined — **`OI-115`**, and it blocks rather than merely awaiting sign-off

**Rate-card basis:** procedure 32 h hand-coded @ **0.75** (`[DE §1]` *non-trivial business service* — domain reasoning against an undocumented legacy schema with triggers) = 24 h · `CheckInService` call, unit-of-work seam and grants 12 h @ 0.70 = 8 h. **44 h hand-coded → 32 h AI-assisted.**

> ⚠ **The BE half is partly already priced.** `FW-157` is costed at 36 h for *"a complex command spanning two databases and the PLC"* — the shared half was always in that number, it simply had nothing to call. The 8 h here is the seam and the grants, not the command.

**Dependencies:** FW-157, FW-159, FW-141, FW-142, FW-144, FW-003, `10_CommonDB_Insert_WIPStations_FlatWire.sql`
**Blockers:** **Q37** (the check-in transaction token), **Q38** (the WIP-log status value), **Q39** (stamping the rod's `coils` row) — all three must close before this runs outside DEV. **`OI-115`** blocks the FL2 half. **`OI-116`** (the rolling-processing table) is not a hard blocker.

---

###### FW-221 · Station release and reqsum reversal
**Hours:** 9 h DB · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB

> **New 19 Aug 2026. `FW-220` is a one-shot without this.** `FR-077` *sets* `wip_stations.coilno` and no
> requirement clears it, against a UNIQUE index — so a line is unusable after its first run. `FW-219`
> correctly refused to bolt the release onto *coil* completion because it belongs to *run* completion,
> which left it owned by nobody. **This closes `OI-112`.** It also implements `[ARC §10]`'s closing line,
> which required pre-check-out to reverse the reqsum and which nothing implemented — `OI-01`'s residual.

**Acceptance Criteria:**
- [ ] `FlatWire_ReleaseStation` returns `CoilNo` to the **station's own name padded to 9** — not NULL and not empty, because a plain UNIQUE index admits only one of each
- [ ] Transaction-agnostic (called both inside a caller transaction and standalone), fully idempotent, and **refuses a late release** of a station already re-claimed by another rod
- [ ] Called at FL1 spool completion (`FW-202`), FL2/FL3 run completion (`FW-185`/`FW-219`'s caller) and checkout modes A and B (`FW-174`) — **never at coil completion**
- [ ] **Check in → release → check in another rod at the same station succeeds** — the failure mode `OI-112` predicted
- [ ] `FlatWire_ReverseReqsum` deletes the reqsum row, resets both `actual_start_date` values to the sentinel, and releases the station — caller-owned transaction, same contract as `FW-220`
- [ ] **It refuses when footage > 0.** That is a Mode B mid-run removal whose reqsum records material the order genuinely received; deleting it would make produced material vanish
- [ ] It deletes only when **check-in created the row** — `RodCheckin.WipCoilOrdersWritten`, from `FW-222`
- [ ] The delete is audited: `wip_coil_orders_d_tg` archives to `wip_coil_orders_hist` **and** sets `reassign_order_info.status = 2`. The trigger is **single-row-scalar**, so one row per call, never batched

**Rate-card basis:** release procedure 6 h + reversal procedure 10 h + teardown script 2 h = 18 h hand-coded @ 0.50 (mechanical, against a schema already read for `FW-220`) = 9 h.

**Dependencies:** FW-220, FW-222, FW-174, FW-185, FW-202
**Blockers:** **Q40** (delete the reqsum row versus leave an orphan) — must close before this runs outside DEV. `@deleteOrphan = 0` makes it a no-op if the answer is "leave it".

---

###### FW-222 · Single-active-run index and the reversal flag
**Hours:** 2 h DB · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB

> **New 19 Aug 2026, and the first half is a live correctness gap.** *"Single active run per line"* is stated
> as a business rule in `phase-04`, owed as `409 RUN_ALREADY_ACTIVE` by `FW-157 §3`, and enforced **nowhere**:
> `IX_FlatWireRun_LineId` is a **non-unique** index. Two concurrent check-ins on one line both pass the
> aggregate check and both commit — precisely the read-then-write race `CoilCheckin`'s
> `IsAnyCoilCheckedInRule` has, reproduced in new code.

**Acceptance Criteria:**
- [ ] `UX_FlatWireRun_ActiveLine` — filtered UNIQUE on `LineId` where `Status IN ('Running','Paused')`, in the `UX_RodStaging_Bay` idiom. The aggregate still enforces the rule in code; this is **belt-and-braces**, and it is what makes the `409` truthful under concurrency rather than merely likely
- [ ] Two concurrent check-ins on one line: one succeeds, the other fails on the index and surfaces `409 RUN_ALREADY_ACTIVE`
- [ ] `RodCheckin.WipCoilOrdersWritten BIT NOT NULL DEFAULT 0` — **defaults to the safe direction**, so a missing value never authorises `FW-221`'s delete
- [ ] Object baseline moves **49 → 50 index statements**, verified by count; the table count stays **28**. `[DBD §6.2]` moves with it

**Rate-card basis:** 3 h hand-coded @ 0.60 (mechanical DDL) = 2 h.

**Dependencies:** FW-007
**Blockers:** —

---

###### FW-223 · Rod ingestion — populating the FlatWire tables
**Hours:** 14 h (DB 10 · BE 4) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB + BE

> **New 19 Aug 2026, and it is a build blocker rather than an improvement.** **Nothing populated
> `FlatWireDB.Rod` in production.** Rod receiving (`FW-020`–`FW-022`) is upstream, was deleted from this
> backlog on 13 Aug 2026 as another team's work, and writes `proddb..coils` — not `FlatWireDB`. The only
> thing that ever put a row in `Rod` is `FlatWire_SampleData_Materials.sql`, which seeds eight fake rods.
> `FK_RodCheckin_Rod` and `FK_RodStaging_Rod` are **enforced**, so on a clean production database **the
> first staging or check-in fails on a foreign key**. That is `OI-42`, open since `D-04` and described in
> `[DBD]` as *"a real design hole, not a documentation nit"*. Specified as `FR-529`–`FR-532` and
> `[INT §7.9]`; plan at [`FW-223.md`](../40-backend/tasks/FW-223.md).
> **It closes `OI-42`** and raises **`OI-117`**. Hours are **additive to `[CE §3b]`**.

**Acceptance Criteria:**
- [ ] `FlatWireDB.dbo.sp_IngestRodFromCoils` deployed, projecting one rod from `proddb..coils` into the local mirror **inside the caller's transaction** (asserts `@@TRANCOUNT > 0`, same contract as `FlatWire_CheckInRod`)
- [ ] Called as the **first statement** of `POST /staging/rod` and `POST /checkin/rod`, before any other `FlatWireDB` write — both have an enforced FK to `Rod.Alpha`, and a direct scan into Dashboard 2 means check-in cannot assume staging ran
- [ ] ⚠ **`GET /rod/{alpha}` does NOT ingest** (`FR-530`). It is documented `Idempotent` and any role may call it; a supervisor scanning a rod to look at it must not create records
- [ ] **The refresh touches shared-mastered columns only** (`FR-531`). `Status`, `FootageRunToDate` and `RemainingWeightEstimateLb` are **locally mastered** — `Status` carries `INFLAT` (local since `D-32`) and resetting it un-marks a running rod; clearing `FootageRunToDate` offers a fresh-start check-in for a rod that has already run, which `FR-043` forbids. **This is why it is not a `MERGE`**
- [ ] The alloy is resolved through `united_db..alloys` (`alloy_idx` → `alloy`) — a **lookup, not a cast**. `coil_alloy` is `smallint`, `Rod.Alloy` is `varchar(10)` holding `'1100'`; storing the code as text does not fail, it silently stops every downstream alloy comparison from matching
- [ ] `Rod.DiameterIn` takes the **operator's measurement** — `proddb..coils` has no rod-diameter column and `coil_gauge` is a *strip* gauge. This is why ingestion is at first use and not at receipt: at receipt there is no measurement
- [ ] `Rod.SupplierHeat` is left **`NULL` deliberately** — nothing sources it (**`OI-117`**)
- [ ] A rod absent from `proddb..coils` is refused **before any `FlatWireDB` write** (`FR-532`)
- [ ] Idempotent: twice in one transaction → one row, `@rodExisted` `0` then `1`
- [ ] **Sample data no longer deploys with the schema.** The five seeds moved from `FlatWire_DDL_RunAll.sql` to a new `FlatWire_SampleData_RunAll.sql`; the schema runner now yields 33 tables and **zero rows**. A conditional `:r` was impossible — it is a SQLCMD **parse-time** directive
- [ ] `FlatWireDB` object baseline is **1 procedure**; `sp_ShiftSummary` still absent (MVP-2)

**Rate-card basis:** procedure 10 h hand-coded @ 0.75 (`[DE §1]` *non-trivial business service* — a cross-database projection against an undocumented legacy schema) = 8 h · seed-runner split 2 h @ 1.0 (mechanical, but it is a deployment-behaviour change and wants reading) = 2 h · two call sites and the ordering 5 h @ 0.80 = 4 h. **17 h hand-coded → 14 h AI-assisted.**

**Dependencies:** FW-007, FW-142, FW-144, FW-157, FW-158, FW-159, FW-220
**Blockers:** **None of its own** — every column either has a source or is deliberately `NULL`, so there is no IT sign-off item. **Shares `FW-220`'s deployment prerequisite**: `FlatWireDB` must be on the same instance as `proddb` and `united_db`, because the projection reads both inside the caller's transaction.
---

###### FW-205 · `ITInhibitService` — the run-block interlock
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT

> **New 14 Aug 2026.** `ITInhibit` is specified in full at `[PLC §8]`, carries **seven P1 test cases**
> (`TC-011`–`TC-017a`) and `FR-008`–`FR-010`/`FR-020`, and had **no phase home and no costed story** — it was
> bundled into `FW-N11` *"Operator session / `ITInhibit`"*, which is uncosted and cited against Phase 6.
> **This story is the split.** `FW-N11` keeps its id for the operator-session remainder.

**As a** production system,
**I want** the machine blocked whenever the prerequisites for recording a run are not met,
**So that** it is impossible to produce material the system cannot account for.

**Acceptance Criteria:**
- [ ] **One tag per line** — `FL1.ITInhibit`, `FL2.ITInhibit` — **written, never read**, so it is a `PLCTagService` operation and not a subscription
- [ ] **Line-scoped**: a blocked line blocks **only itself** — an idle FL1 does not stop a scheduled FL2 (`TC-017a`)
- [ ] Sets on **conditions 3, 4 and 5** — feet data **unavailable**, feet data **invalid**, and **two or more consecutive recordings missing** — one shared watchdog over the footage tag the OPC ingest delivers
- [ ] Condition 5 additionally raises the **prominent data-recording alert** via the existing `AlertRaised` event — no new hub event
- [ ] **While set, no rolling data is recorded without an active coil** — the interlock gates `FW-150`'s broadcast loop before it persists `RunReading`
- [ ] **Clears automatically only.** `TC-016` attempts an operator clear *via every UI surface* and must find none — **enforced by the absence** of any endpoint, command or hub method
- [ ] Config key sits **inside each line's `Tags` block, never at the root** — a root key would surface the first time an idle line blocked a running one
- [ ] Honours `SimulatePLCTagPush`; every set and clear is audit-logged with tag path, value, timestamp and result

**Rate-card basis:** non-trivial business service, mid-band **16 h** (§2, *12–24 h priced individually*) — comparable to the card's *"PLC tag group push + compensating clear | 16 h"*: a tag write plus stateful evaluation, but one boolean per line rather than a group push
**Dependencies:** FW-144 (config), FW-151 (`PLCTagService`), FW-N05 (the footage feed)
**Blockers:** **`G30`** *(whether FL3 carries its own `FL3.ITInhibit` or asserts FL1's and FL2's together follows from the namespace question — build FL1/FL2 now and leave FL3 behind the same config switch)*

> **`FW-205` + `FW-206` = 24 h**, the top of the 12–24 h band, which is where all five conditions price. Conditions
> 1–2 are counted in `FW-206` **only** — carrying 24 h on both sides would double-count them.

---

###### FW-209 · DB2A line toggle must reload, not relabel
**Hours:** 4 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** FE

> **New 15 Aug 2026** — the second half of **`G21`**, which no story covered. A schema fix cannot
> reach it, and it is a defect *however* the uniqueness question closes.

**As an** operator,
**I want** switching the station between FL1 and FL3 to reload what I am looking at,
**So that** rod already staged is not silently reclassified under a relabelled heading.

**Acceptance Criteria:**
- [ ] Toggling FL1↔FL3 **reloads the bays and the Traveler Queue** — it currently relabels the badge, station stamp, queue heading and modal subtitle and reloads nothing
- [ ] ⚠ Because the off-schedule check reads the **current** line, a rod staged before the toggle must not change classification with no visible change
- [ ] The station stamp reflects the reloaded data, not the toggle position

**Rate-card basis:** small screen-behaviour fix, **4 h** — ⚠ **a proxy**: §2's smallest unit is 4 h for a whole table, and a behaviour fix has no card entry. Not measured
**Dependencies:** FW-061
**Blockers:** —

---

###### FW-206 · `ITInhibit` conditions 1–2 — check-in and material-tracking state
**Hours:** 8 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> **New 14 Aug 2026**, the Phase-4 half of the `FW-205` split. **Blocked** — do not schedule until `PLC-Q12` closes.

**As a** production system,
**I want** the interlock also set when nothing is checked in or no material-tracking identifier is active,
**So that** all five `[PLC §8.2]` conditions are enforced, not three.

**Acceptance Criteria:**
- [ ] Condition 1 — **no coil or rod is checked in** on the line
- [ ] Condition 2 — **no active material-tracking identifier exists**
- [ ] Both feed the same `ITInhibitService` evaluation built in `FW-205`; no second write path
- [ ] The runbook reconciliation step for an **orphaned identifier** is covered — `[PLC §8.4]` names it the most common cause after an interrupted transaction

**Rate-card basis:** two condition evaluators against existing check-in state, 8 h (§2)
**Dependencies:** FW-205, FW-061
**Blockers:** ⚠ **`PLC-Q12`** — `[PLC §8.5]`: the *"active material-tracking identifier"* **has never had its format specified**, and whether it is the same identity as the run is unresolved. Condition 2 is specified against a concept that is not yet fully defined

---

###### FW-207 · Domain model — aggregates, value objects and invariants
**Hours:** 32 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

> **New 15 Aug 2026 — decision `D-29`, tactical DDD.** The framework already ships the toolkit:
> `UA.Framework.Domain.EntityModels.Entity` (domain events, identity equality) and `ValueObject`
> (`GetAtomicValues`, structural equality); `CoilCheckin` ships `IBusinessRule`/`CheckRule` →
> `BusinessRuleValidationException`. **Inherit them — do not write new base classes.**

**As a** developer,
**I want** aggregates that enforce their own invariants,
**So that** rules cannot be bypassed by a caller that forgets to run a validator.

**Acceptance Criteria:**
- [ ] **Seven aggregate roots** — `FlatWireRun`, `RodStaging`, `WeldEvent`, `SpoolProcessing`, `CoilOutput`, `RodCheckout`, `WipRejection` — each inheriting `Entity`. Boundaries per `[SVC §3.2a]`
- [ ] ⚠ **`RunReading` is in NO aggregate** — 10 Hz time series; it stays an append-only write model read by Dapper. Materialising it inside `FlatWireRun` is the failure this criterion exists to prevent
- [ ] ⚠ **`Rod` and `PassSchedule` get no aggregate and no repository** — read models. `PassSchedule` is MVP-2-owned and reached only through `PassScheduleSnapshot`
- [ ] **Six alpha value objects** with validating constructors — `RodAlpha` `R#####`, `SpoolAlpha` `SP-#####`, `RunAlpha` `RUN-####`, `CoilAlpha` `FW-#####-C##`, `DieAlpha`, `PassScheduleReference`. `RodAlpha("ROD-00041")` must throw (**closes `G14`'s format half**)
- [ ] **Seven dimensioned quantities** — `Gauge`, `Width`, `Footage`, `WeightLb`, `SpeedFpm`, `RollGap`, `RollDiameter` — each inheriting `ValueObject`
- [ ] Invariants as `IBusinessRule`, enforced by `CheckRule` → `BusinessRuleValidationException` → **`422`**. Includes **`G21` bay occupancy**, which must reject a second rod on the same physical station **with the DB index absent**
- [ ] The **alpha is the identity** — repositories key on it, not on `Entity.Id`

> ⚠ **Two criteria above are no longer demonstrable, and they are the evidence behind two closed gaps.**
> With backend tests withdrawn (15 Aug 2026, `[TS §1.2]`), nothing exercises `RodAlpha("ROD-00041")` throwing
> — which is what *"closes `G14`'s format half"* — and nothing runs the bay rule **with the DB index absent**,
> which is what makes `G21`'s index *"belt-and-braces, not the sole defence"* rather than the only defence.
> **Both criteria stay: the design is right and must still be built.** They are restated in `[GAP]` as
> **closed by design, unverified**. Do not delete them to make the story pass.

**Rate-card basis:** 7 roots × 3 h = 21 · 13 value objects × 0.5 h ≈ 7 · rules ≈ 4 = **32 h**. Above §2's *"non-trivial service 12–24 h"* band because it is ~20 items, not one. **Unchanged by the 15 Aug test withdrawal** — every hour here is production code; the withdrawn tests were never priced into it
**Dependencies:** FW-N04
**Blockers:** — *(⚠ **`D1` open**: `ROWVERSION` is absent on `WeldEvent`, `RodCheckout` and `WipRejection`, all three mutated after insert. Decide before the schema freeze)*

---

###### FW-208 · Domain events and post-commit dispatch
**Hours:** 8 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE

> **New 15 Aug 2026 (`D-29`).** Low because `MediatorExtension.DispatchDomainEventsAsync` and
> `Entity.DomainEvents` **already exist** — this is wiring plus the translation handlers.

**As a** developer,
**I want** aggregates to raise domain events that reach the hub after commit,
**So that** command handlers broadcast side effects without referencing SignalR.

**Acceptance Criteria:**
- [ ] Aggregates raise `RunPaused`, `WeldRecorded`, `CoilCompleted`, `BayStateChanged`, `SpoolCompletionPromptRaised` via the inherited `AddDomainEvent`
- [ ] `FlatWireDbContext.SaveChangesAsync` calls **`DispatchDomainEventsAsync` after commit** — never before
- [ ] Handlers in Infrastructure/API translate each to `IFlatWireClient`
- [ ] ⚠ **No SignalR type is referenced from `FlatWire.Application`** — `[SVC §3.2]`'s rule is satisfied, not worked around
- [ ] `WipRejection` clearing a `Blocked` bay goes **via a domain event**, not by reaching into the `RodStaging` aggregate

**Rate-card basis:** dispatcher wiring + ~5 translation handlers @ 8 h (§2) — the dispatcher itself is inherited
**Dependencies:** FW-207, FW-142, FW-080
**Blockers:** —

---

**Phase 1B reconciliation** — BE `16+45+16+12+28+24+12+12+16+8+12+8+32+8 = 249` · RT `28+16+32+16+16+16 = 124` · base **373** → QA **78** *(held — see below)* → Cont `0.15 × (373+78) = 68` → **519 h**

> ### Restated 15 Aug 2026: 541 → 519 h — backend tests withdrawn
>
> No automated backend tests of any kind (`[TS §1.2]`). **Itemised, not applied as a blanket fraction** —
> three stories carry priced test content and the rest do not: **`FW-138` 56 → 45** (query-endpoint rate 4 h → 3 h and the stub contract suite goes, offset by **fourteen → fifteen controllers**), **`FW-147` 16 → 12** (validator tests), **`FW-080` 32 → 28**
> (hub smoke harness). **BE 264 → 249 · RT 128 → 124 · base 392 → 373.**
>
> ⚠ **The saving is −22 h net (−26 on tests, +4 for `SpoolController`), not the ~−44 a percentage-of-base assumption suggests.** Most of 1B is production
> artifacts with no test priced into them: **`FW-207`'s 32 h is itemised as 7 roots + 13 value objects +
> rules**, and `FW-150` has no test criterion at all. Both are **unchanged**. Anyone re-deriving this by
> applying a flat test fraction to the base will overstate the saving by ~70 %.
>
> ⚠ **QA is deliberately held at 78 h and NOT recomputed.** `[CE §2]` defines it as a mechanical +20 % of the
> dev base, which would give `0.20 × 373 = 75` and book a *saving* on the one line that must absorb the work
> — with no automated tests, regression across Phases 4–14 is manual. Holding QA is a **decision, not an
> arithmetic slip**; the mechanical figure would be 515 h. **Do not "correct" 78 to 75.**
>
> ⚠ **The 1B saving is the small number in this change.** 22 h net leaves Phase 1; the cost recurs across
> ~2,600 h of Phases 2–14 as manual regression and lands hardest in Phase 14, which *is* the QA phase and
> where `[CE §2]` suppresses the QA uplift precisely because testing is the work. A re-derivation quoting
> only the saving is misleading.

> **Restated 14 Aug 2026 from 442 h.** Two corrections, both of omissions against published sources rather than
> re-scopes: **`FW-138` 52 → 56 h** (priced at 13 controllers against an `[API §3.1]` that has always listed 14)
> and **`FW-205` +16 h** (`ITInhibit`, specified at `[PLC §8]` with seven P1 test cases and no costed story).
> `[RM]`'s Phase 1 row moves **1,027 → 1,054**. ⚠ **This is the hand-coded basis.** `[DE]` and `[SSP]` re-derive on
> their own retention factors and **disagree with each other on Phase-1B RT by up to 19 h** — per `[TRP §1.4]`,
> *never mix a `[DE §2]` stream cell with a `[SSP §5]` one.* Do not publish a single AI-assisted figure for either
> story. **`FW-206`'s 8 h is Phase 4's, not counted here.**

> ⚠ **`FW-203` is not in that reconciliation.** It is trial-run scope introduced on 14 Aug 2026 and its **8 h is
> additive to `[CE §3b]`**, like `FW-202`'s. Do not fold it in — and note it does **not** offset `FW-N05`'s 32 h
> either, because that story still has to be built for production.

---

##### Unscheduled · The machine simulator — `FW-210`–`FW-215`, `FW-217`

**Spec:** [`MachineSimulator.md`](../20-architecture/MachineSimulator.md) `[SIM]` · **Owner:** RT · **111 h dev**
(RT 64 · FE 24 · BE 23), **+24 h** for the sidecar

> **New 15 Aug 2026.** A **machine simulator** — a model of FL1/FL2/FL3 that runs a production run end to end
> and reacts to what the application does to it — plus an engineering control console. It **extends
> `FW-203`**, which stays exactly as published: its 8 h base / 6 h AI-assisted figure and its place in
> `[TRP §4]`'s T2 tail are **unchanged**, and it becomes the first increment of `FW-211`'s in-process adapter.
>
> ⚠ **These hours are additive to `[CE §3b]`**, exactly as `FW-202`, `FW-203` and `FW-204` are. **Do not fold
> them into the 3,186 h baseline** — that figure is quoted in five other documents and re-counting it here
> would drift them all. They do **not** offset `FW-N05`'s 32 h either; real OPC ingest is still production work.
>
> ⚠ **Do not publish a single AI-assisted figure for these.** `[DE §2]` and `[SSP §5]` disagree on Phase-1B RT
> by up to 19 h, and `[TRP §1.4]`'s rule is *never mix a `[DE §2]` stream cell with a `[SSP §5]` one.* Re-derive
> per stream on `[DE §1]`'s own factors if one is wanted (RT is 0.75).
>
> **Priority is `High`, not `Critical`, throughout.** The 30 Sep trial does not depend on any of this —
> `FW-203` covers it. Marking these Critical would misrepresent the trial's critical path.

---

###### FW-210 · Line model core — the kinematic state machine for FL1/FL2/FL3
**Hours:** 24 h RT · **Priority:** High · **Sprint:** — *(unscheduled; post-trial)* · **Phase:** 1B · **Stream:** RT

**As a** developer,
**I want** three line models that hold run state and produce coupled, believable telemetry,
**So that** a whole run can be exercised end to end before a controller exists.

**Acceptance Criteria:**
- [ ] `ILineModel` in `FlatWire.Domain` with **no infrastructure dependency** — `Tick`, `ApplyConfiguration`, `ApplyScenario`, `InjectFault`, `SetRunState` (`[SIM §3.2]`)
- [ ] **Three distinct models, not three instances of one.** FL1 rod→`DB1`/`DB2`→`FM1`→spool · FL2 spool→`FM2_S1`/`S2`/`S3` · FL3 **one run**, `RouteMode='Hybrid'`, speeds coupled through the chain
- [ ] ⚠ **FL2 ticks.** Only batched `GaugeReading`/`WidthReading` are suppressed (`[SIG §5.3]`); `SpeedFPM`, `FootageCounter`, `PayoffWeight`, `ComponentStatus` and `LineStatus` still flow, and `FR-120` makes live gauge/width **`null`**. Gauge is still computed internally for the `RunReading` profile
- [ ] Kinematics per `[SIM §5]`: footage integrates speed and is **monotonic**; weight depletes by `footage × lbPerFt`; gauge/width converge first-order on target
- [ ] **`lbPerFt` is read from configuration and never a constant** — `Q10` carries no recommendation and `OI-45` is open (`[SIM §5.3]`)
- [ ] **Mill spring places the roll gap *below* gauge**, load-proportionally — master spec §10.5, not `FR-386`'s alloy multiplier
- [ ] Component vocabulary is `CK_PSC_ComponentName`: `DB1`,`DB2`,`FM1`,`EdgeSet`,`FM2_S1`,`FM2_S2`,`FM2_S3`. **No `FM2_6inS3`** — withdrawn as never-existent
- [ ] **Run status and line state are separate** (`[SIM §4.4]`) — `CK_FlatWireRun_Status` is ours and settled; the line-state vocabulary is **ours and unconfirmed** (`OI-35`)
- [ ] Noise is **seeded and reproducible**; the seed is settable
- [ ] ⚠ The `[SIM §5.6]` assumption table is filled in and kept current — it is `G39`'s only instrument

**Rate-card basis:** non-trivial service / algorithm, **top** of the 12–24 h band (§2) — three distinct state machines with coupled kinematics, not one parameterised model
**Dependencies:** FW-N05 *(the `Reading` contract only)*
**Blockers:** **G9 / OI-34** *(no target cadence — pick one and record it)* · **`Q10` / OI-45** *(`lbPerFt` basis)* · **OI-35** *(line-state vocabulary)*

---

###### FW-211 · The simulation seam — `IReadingSource` and the in-process adapter
**Hours:** 12 h RT · **Priority:** High · **Sprint:** — *(unscheduled; post-trial)* · **Phase:** 1B · **Stream:** RT

**As a** developer,
**I want** the simulated and real feeds behind one DI-swapped interface,
**So that** the real ingest drops in with no call-site change anywhere.

**Acceptance Criteria:**
- [ ] `IReadingSource` in `FlatWire.Infrastructure`; **`FW-N05` and the simulation host are two implementations of it**, neither aware of the other
- [ ] Publishes to the **same bounded `Channel<Reading>`** at the same cadence, so `FW-150`'s broadcast loop is untouched
- [ ] **Selected by configuration, not by call site** — no `if (simulating)` anywhere. One flag pair with `SimulatePLCTagPush` puts the whole system in simulation (`[SIM §2.2]`)
- [ ] Bound to a strongly-typed options class and **validated at startup**, per `[PLCC §1.7]`'s existing rule
- [ ] ⚠ **Adds no interface of its own.** If the seam needs a change to `IFlatWireClient` or the `Reading` shape, the contract is wrong (`[SIM §2.1]`)
- [ ] **`FW-203` is this story's first increment** and is not rewritten or re-priced

**Rate-card basis:** non-trivial service, **low** end of the 12–24 h band (§2) — an interface, one implementation and options binding, against a contract that already exists
**Dependencies:** FW-210, FW-144 *(config)*, FW-150
**Blockers:** —

---

###### FW-212 · Closed loop — the model consumes the `SimulatePLCTagPush` payload
**Hours:** 12 h RT · **Priority:** High · **Sprint:** — *(unscheduled; post-trial)* · **Phase:** 4 · **Stream:** RT

**As an** operator,
**I want** the simulated line to reconfigure itself when I acknowledge a check-in,
**So that** the screens demonstrate a machine responding, not a feed replaying.

**Acceptance Criteria:**
- [ ] The model observes the simulated push and applies it per `[SIM §6]` — component active/bypass, die sizes, roll gaps, edge type, speed, gauge/width targets
- [ ] **A roll adjust moves the trace within one cadence** — `FW-070`'s *Apply* writes one component's gap and that stand's target shifts. Without this the roll-adjust dialog is untestable
- [ ] A **bypassed** component contributes nothing; `State` is `Active`/`Bypass`/`Skip` (`CK_PSC_State`)
- [ ] **Ordering is observed, not inverted** — `[PLCC §1.2]` writes records *before* tags, so the model sees the push after the record exists
- [ ] A `PushFailure` fault leaves the line on its **previous** configuration — the silent failure `G32`/`G33` warn about
- [ ] ⚠ **The word "rollback" does not appear.** OPC writes are not transactional; recovery is a compensating re-clear (`G16`, closed 4 Aug 2026)

**Rate-card basis:** non-trivial service, **low** end of the 12–24 h band (§2) — a payload reader and a target-setter over an existing model
**Dependencies:** FW-210, FW-151, FW-082
**Blockers:** **G2 / OI-39** *(cross-DB recovery undecided)* · **G30** *(one failure domain or two)*

---

###### FW-213 · Scenario and fault injection
**Hours:** 16 h RT · **Priority:** High · **Sprint:** — *(unscheduled; post-trial)* · **Phase:** 5 · **Stream:** RT

**As a** tester,
**I want** to drive a line into any state a real one can reach,
**So that** the exception paths are demonstrable and reproducible.

**Acceptance Criteria:**
- [ ] The five scenarios of `[SIM §7.1]`: `InSpec` · `Drifting` · `OutOfSpec` · `Erratic` · `ToTarget`
- [ ] The seven faults of `[SIM §7.2]`: `LineStop` · `CommsDrop` · `Stall` · `WireBreak` · `DieWear` · `PushFailure` · `WeightVariance`
- [ ] ⚠ **`LineStop` is edge-triggered exactly once per stop** (`FR-141`), with the weight **latched at the stop timestamp** (`FR-143`). A repeating edge would mask a non-idempotent client, and idempotency on re-delivery is specified behaviour
- [ ] `CommsDrop` stops readings **without closing the hub connection** — exercises `FR-119`'s cached state behind *"Reconnecting…"*, never a blank screen
- [ ] `OutOfSpec` reaches DB3's N-consecutive auto-prompt and the SPC → WIP-rejection chain
- [ ] Every scenario and fault is **reproducible from a seed** (`[SIM §5.7]`)
- [ ] `WireBreak` is simulatable **before it is storable** — `G34` has a decided flow and no persistence target; that is expected, not a defect

**Rate-card basis:** non-trivial service, **mid** band (§2) — twelve behaviours over an existing model, comparable to the card's stateful-service entries
**Dependencies:** FW-210
**Blockers:** **G34** *(wire break has no persistence target)*

---

###### FW-215 · Simulator control API — `/sim/**`
**Hours:** 23 h BE · **Priority:** High · **Sprint:** — *(unscheduled; post-trial — ⚠ now the only unbuilt card of the seven)* · **Phase:** 1B · **Stream:** BE

> ✅ **BUILT 1 Sep 2026 — six endpoints at `/sim`, 71/71 harness checks, 0 errors, 14 warnings byte-identical to the baseline.** The gate was measured in all three configurations: no model hosted → **404**; feed simulator → **401**; `OPCConnection` double → **401**, where it was **404** before `G70` was closed. `P-306`–`P-314` minted. ⚠ **The functional rows need `FW-145`** — no role claim is issued, so every route denies today, fail-closed by design.
>
> ⚠ **Reconciled against the 31 Aug simulator build before it was built.** ⛔ **Four of
> the five endpoints were already BUILT.** `FW-218` shipped `steer`, `stop`, `fault` and `state` at
> **`/sim`** and is closed, so `POST /sim/{lineId}/run` is the one new route and this story **extends
> that surface** rather than authoring one (`P-39`). The prefix is **`/sim`**, not
> `/api/v1/flatwire/sim`; the surface is a **minimal-API group, not MediatR controllers** (`P-38`);
> and the gate is **`FlatWireOpc:SimulateOpcFeed`**, not `SimulatePLCTagPush` — the *write* half of
> the flag pair, `true` in every environment until commissioning.
>
> ⚠ **`G68`, `G69`, `G70`, `G72` and `G73` all name this story owner** — a sixth endpoint, an
> undecided vocabulary, the seam `FW-217`'s E2E double needs, a guard on a role name `[SEC §8]` does
> not have, and a `Pause` control nothing commands. **The 23 h is re-aimed, not re-priced.**
>
> ⛔ **Second pass, 1 Sep 2026: the one new route is not buildable as `[SIM §8.1]` words it.** Of
> *"scenario, seed, start weight, target"*, the **seed and start weight are constructor-only** on
> `LineModelBase` and nothing on `ILineModel` sets either — so `POST /run` **replaces** the line's
> model through the seam's factory, which is also the only way `[SIM §5.7]`'s tick-for-tick
> reproducibility holds. ⚠ `/sim/state` carries **at most two** lines, never three.

**As an** engineer,
**I want** to drive the simulator over HTTP,
**So that** the console and the automated suites use one control surface.

**Acceptance Criteria:**
- [ ] **`POST /sim/{lineId}/run`** — scenario, seed, start weight, target and the **target run state** (`[SIM §8.1]`). **The one genuinely new route**, and what lets a line stopped through `DELETE /sim/{lineId}/run` restart without a service restart
- [ ] ⛔ **Two of those parameters have no lever, so the route REPLACES the line's model rather than mutating a live one.** The seed is set in `LineModelBase`'s **constructor** and `StartWeightLb` is `private set`, also constructor-only; `ApplyConfiguration` carries neither. Replacing is what `[SIM §5.7]`'s tick-for-tick reproducibility requires anyway. ⚠ **Do not add a reseed or set-weight member to `ILineModel`**, and ⚠ **copy the options rather than mutating the bound `IOptionsMonitor` instance**, or the override leaks to every line
- [ ] ⛔ **The target run state is what makes `Pause` reachable — `G73`.** `SetRunning(line, false)` maps straight to `Stopped`, so `Paused` and `Idle` cannot be commanded at all and `[SIM §4.4]`'s run-versus-line distinction has never been demonstrable, though `[SIM §9.2]` puts **Start / Stop / Pause** on every panel. ⛔ **No seventh route** — `DELETE /run` keeps the `Stopped` edge
- [ ] **The four built endpoints are re-pointed at the line model, not rewritten** — paths, shapes and semantics unchanged (`P-39`). ⛔ **Do not change `OpcFeedSimulator`'s four lever signatures** (`P-266`; `FW-218` is closed)
- [ ] ⚠ **The prefix is `/sim`** — a separate engineering prefix (`[SIM §8.2]`), and what `FW-214`'s delivered console already calls
- [ ] ⚠ **Extended as the existing minimal-API group, not converted to MediatR controllers over `UAController`** (`P-38`) — a controller would exist and then be *un-mapped* by a convention, a weaker claim than never mapping it. **The `{data,success,errors}` wire shape is unchanged**
- [ ] ⚠ **Routes are not registered at all when no line model is hosted — `404`, not `403`** (`[SIM §2.4]`, `P-38`). A present-but-forbidden control plane is one misconfigured role away from driving a live line. ⛔ **The gate is `FlatWireOpc:SimulateOpcFeed`**, and ⚠ do not "fix" `G66` with a role check instead — `[SEC §8.8b]` makes the `404` the control and the policy the backstop
- [ ] ⛔ **`G70`: widen that condition to *"the readings come from a line model"*** — `SimulateOpcFeed` **or** `UseOpcConnectionDouble` — and give the handlers **one seam satisfied by both `OpcFeedSimulator` and `OpcConnectionDouble`** instead of the concrete simulator. ⚠ **No second control surface for the double** (`P-39`)
- [ ] **The seam carries the model factory too**, because `POST /run` needs it — both hosts hold a **byte-identical** private `CreateModel(LineId, FlatWireSimulationOptions)`, and one factory behind the seam replaces two copies. ⚠ That is the whole addition; the four lever signatures are untouched
- [ ] **Bind `FW-145`'s `SimulatorControl` policy** (`RequireAuthorization(FlatWirePolicies.SimulatorControl)`) **on top of** that, never `Operator` (`[SIM §8.4]`). ⛔ **`G72`: the built surface hardcodes `Roles = "Engineer,Admin"` and `Engineer` is not one of `[SEC §8]`'s six roles**, so it keeps denying after the claim is issued. ⚠ Do **not** add an `Engineer` role, and do **not** fall back to a bare `[Authorize]`. ⚠ **Standing condition, not a criterion:** `FW-145` issues no role claim yet, so these deny today — fail-closed
- [ ] **`POST /sim/{lineId}/fault` accepts all seven of `[SIM §7.2]`'s faults**, not `FW-218`'s single `DroppedReadings`; `FaultId` was built with all seven, `FW-213`'s twelve behaviours are reachable on the objects only, and the console greys **six of seven** buttons for want of this route. ⚠ An unsupported kind stays **rejected, not ignored**
- [ ] **`GET /sim/config` — the sixth endpoint (`G68`)**: the active `lbPerFt`, the seed and the simulation flag. `[SIM §9.2]` asks for `lbPerFt` ***displayed*** and the seed ***"displayed and settable"*** — ⚠ **"settable" is the seed's alone** and `POST /run` already carries it, so **a read closes `G68`**. ⛔ **Do not add a configuration write**: a runtime `lbPerFt` setter would decide `Q10` / `OI-45` by the back door. ⚠ `lbPerFt` **stays nullable** (`P-271`). ⛔ **Do not widen `SimLineState`** (six fields, `P-267`; `[SIM §9.2]` forbids it)
- [ ] **`GET /sim/state` returns one snapshot per *hosted* line** so the console needs no poll on load. ⛔ **At most two, never three** — the standing rule is `{FL1,FL2}` or `{FL3}`, since polling FL2 and FL3 together would read one load cell and three stands twice a second, so `[SIM §8.1]`'s *"all three"* is unreachable **by design**. ⚠ **An unhosted line is OMITTED and the answer is still `200`**; the `400` belongs to the per-line routes
- [ ] ⚠ **These belong to no endpoint total** — an engineering surface on a separate prefix; do not add them to `[API §3.2]`'s index (`[SIM §8.2]`)

**Rate-card basis:** ⚠ **Re-aimed, not re-priced.** The **23 h** priced *five new* endpoints (4 commands @ 5 h + 1 query @ 3 h, §2, at the **15 Aug 2026 restated** rates — the withdrawn bundled unit test is not priced). Four are now built under `FW-218`'s own 18 h, which is **additive to `[CE §3b]` and does not offset this story**, so the same 23 h buys `POST /run`, the `G68` config read, the `G70` seam and re-pointing the four. ⚠ **`G68` asks for a six-endpoint card; any re-price is `[CE]`'s** — the figure is not restated here.
**Dependencies:** **FW-218** *(the surface this extends — built)*, FW-210, FW-211, FW-213, **FW-217** *(the double the `G70` seam must also serve)*, FW-138, FW-145
**Blockers:** **G69** *(which run-state vocabulary the console shows is undecided)*

---

###### FW-214 · Simulator control console DB-S1 — standalone WinForms desktop tool
**Hours:** 52 h FE · **Priority:** High · **Sprint:** **S2** *(trial scope, 15 Aug 2026)* · **Phase:** 5 · **Stream:** FE

> ⚠ **Retargeted to WinForms 29 Aug 2026 — `D-33`. This is no longer an Angular screen.**
> `DB-S1` becomes a **standalone WinForms desktop tool** in `ual-api/Tools/FlatWireSimConsole/`, built and
> released independently of `ual-angular`. It stays a **thin client** — the machine model remains in
> `FlatWire.API`, driven over `/sim` and the `FlatWireHub`, and `[SIM §2.1]` still binds.
>
> **Why.** `flat-wire` is an Angular *library*, not a build target: it ships **inside the shop-floor bundle**
> (`[DEP §1.1]`), and every environment build wipes `dist/` and rebuilds all 17 libraries plus the app. An
> engineering tool that `[SIM §9.1]` insists **is not a dashboard** was riding the operator app's release
> train. A separate EXE severs that, and it can **not be installed** on a commissioned line at all.
>
> **The stream stays `FE`** — `FE` is the user-facing surface, not "Angular" — so no tooling changes.
> ⚠ **`FW-130` and `FW-135` stop being dependencies of this story**; both remain in the plan for the six
> operator screens, so **retiring the Angular console saves none of their 40 h**.

> ⚠ **Brought into the trial 15 Aug 2026, and it ships with controls greyed — read this before building it.**
> `[TRP §8]`'s acceptance run is executed **in front of the client during UAT**, and step 7 times a **3 s stop
> against a 5 s dwell**. Driving that from a saved HTTP request collection with a stopwatch is where a sign-off
> event goes wrong, which is why the screen is in and not just the API.
>
> **The console is built whole; its backing is not.** This story's stated dependency is `FW-215` in full, which
> depends on `FW-210` (the kinematic model, 24 h) and `FW-213` (scenarios and faults, 16 h). **None of those
> is in the trial** — making every control live is **+50 h AI-assisted**, which the window does not have. So
> the trial builds against **`FW-218`'s four endpoints** and **greys what has no backing**, exactly
> as `[TRP §4]` greys Die Change, Roll Adjust and *Browse spool queue* on shipped screens.
>
> | Control | Trial |
> |---|---|
> | **Stop** · speed slider · gauge/width nudges | ✅ live — `DELETE /sim/{lineId}/run`, `POST /sim/{lineId}/steer` |
> | **Drop readings** fault | ✅ live — the one fault `FW-218` carries |
> | Live readouts · dual state badges · target-vs-actual strips | ✅ live — ⚠ **`GET /sim/state` seeds only six fields** (`Line`, `Running`, `FootageFt`, `GaugeOffsetIn`, `DriftPerTickIn`, `DropTicksRemaining`); **speed, payoff weight, remaining %, gauge/width actual, line state and run status all come from the hub** |
> | **Start** | ⚪ greyed — the trial starts runs through check-in, not the simulator (`POST /sim/{lineId}/run` is out) |
> | **The whole FL3 panel** | ⚪ greyed — `SimControlSurface` returns **400** for `FL3` today (`PLC-Q08` / `G30`) |
> | **Scenario picker** (`InSpec`/`Drifting`/`OutOfSpec`/`Erratic`/`ToTarget`) | ⚪ greyed — whole-run shapes need `FW-210` |
> | **Six of the seven fault buttons** | ⚪ greyed — `FW-213`. ⚠ `WeightVariance` would be inert anyway: `AlloyProperty.LbPerFtFactor` is seeded NULL (`OQ-10`) |
> | Seed, displayed and settable | ⚪ greyed — determinism is `[SIM §5.7]`, which needs the model |
> | `lbPerFt`, displayed | ✅ live, and it displays **NULL** — which is `OQ-10` made visible rather than buried, exactly as `[SIM §5.3]` intends |
>
> **Grey them, do not delete them.** Each returns as configuration when the simulator proper is built, and a
> deleted control is rework. The mockup already draws all of them.

**As an** engineer,
**I want** one tool that drives all three simulated lines,
**So that** a demo, a UAT rehearsal or a bug reproduction is a few clicks rather than a config edit.

**Acceptance Criteria:**
- [ ] A **standalone WinExe** at `ual-api/Tools/FlatWireSimConsole/`, `net8.0-windows`, **its own `.sln`** — it builds and releases without `ual-angular` and without the `FlatWire.API` solution
- [ ] Three line panels per `[SIM §9.2]` — dual state badges (**run status and line state are different things**, `[SIM §4.4]`), start/stop/pause, scenario picker, live speed/footage/weight readouts, target-vs-actual strips, speed slider, the seven fault buttons. **One `UserControl`, instantiated three times**
- [ ] **FL2's gauge/width strips render *"No live gauge · see Profile"*** — **never a flat line at target**, which reads as a real in-spec measurement. `[TRP §8]` calls this the single most likely thing to ship wrong
- [ ] Global: a **simulation on/off indicator that reads configuration, not UI state**; the active **`lbPerFt`**; the noise **seed**, displayed and settable
- [ ] ⚠ **Not a dashboard** (`[SIM §9.1]`) — absent from the fifteen-dashboard inventory, the navigation map and the topbar *More Options* tiles. It carries **no `DB##` number** deliberately
- [ ] **The contract is referenced, never re-declared.** Link `FlatWire.Domain/Models/RealTime/HubContracts.cs` and `Enums/CanonicalEnums.cs` as `<Compile Include …>` items — they depend on nothing but each other, so this costs no package graph. ⚠ **Do not hand-write DTOs**: `HubContracts.cs` records that *"names are the contract on both ends"*
- [ ] **`Microsoft.AspNetCore.SignalR.Client` on the JSON protocol.** ⚠ **Do not add the MessagePack protocol package** — `FlatWire.API` registers `AddJsonProtocol` unconditionally and aligns both protocols on **string enums**, and a client built against MessagePack breaks the moment `FlatWireSignalR:EnableMessagePack` is turned off to measure
- [ ] Hub client: WebSockets + `SkipNegotiation`, JWT via `AccessTokenProvider`, `WithAutomaticReconnect()`, **line-group re-join on reconnect**, and cached last-known state behind *"Reconnecting…"* — **never a blank screen** (`FR-119`)
- [ ] ⚠ **The console must not open when simulation is off.** Probe `GET /sim/state` at startup; on **404**, show a lock-out panel and nothing else. The server-side 404 remains the control (`[SEC §8.8b]`) — this is the client half of it
- [ ] Consistent `Control.Name` / `AccessibleName` on every control. ⚠ **`data-testid` no longer applies** — it exists for the Playwright suite (`[SP §9.2]`), which cannot drive WinForms, and `DB-S1` was never in an E2E journey

**Rate-card basis:** **52 h**, itemised — scaffold/config/linked contracts 5 · auth 5 · REST client 4 · **SignalR client 12** · line panel 12 · FL2 variant + FL3 greying 3 · global bar and control log 4 · greying rules 2 · simulation-off probe 2 · packaging and the `[DEP]` entry 3. **36 h AI-assisted** at `[DE §1]`'s **0.70 desktop-client** factor. ⚠ **The 0.62 frontend factor does not apply** — its stated basis is that conversion of an approved mockup to Angular components against one token system *"is largely mechanical"*, and that is precisely what the move gives up. ⚠ **The published 24 h / 15 h are the retired Angular sizing** (`D-33`). The greying still changes nothing: the console is drawn whole either way
**Dependencies:** **`FW-218`** *(trial — four endpoints; `FW-215` in full is the post-trial dependency)*, **`FW-145`** *(no role claim is issued today, so `RequireAuthorization(Roles = "Engineer,Admin")` denies every caller — this blocks the acceptance run and is **not** affected by the technology choice)*
**Blockers:** —

---

###### FW-217 · OPC sidecar adapter — the models behind a test-only OPC UA server
**Hours:** 24 h RT · **Priority:** Medium · **Sprint:** — *(unscheduled)* · **Phase:** 14 · **Stream:** RT

**As a** tester,
**I want** the simulated lines served over a real OPC endpoint,
**So that** E2E exercises the real ingest path instead of bypassing it.

**Acceptance Criteria:**
- [ ] The **same** `ILineModel` instances re-hosted behind a test-only OPC UA server — the physics is written once (`[SIM §3.1]`)
- [ ] `FW-N05`'s real ingest subscribes normally and is **unmodified**
- [ ] ⚠ **Never the production OPC servers** — `[PLC §5.3]` A5; they are unchanged infrastructure
- [ ] Satisfies `[TS §3.1]`'s existing *"test-only OPC server sidecar"* row rather than adding a second sidecar
- [ ] Available for commissioning **rehearsal** — and `[SIM §10]` still applies: it proves the pipeline, not the tag paths

**Rate-card basis:** non-trivial service, top of the 12–24 h band (§2) plus the server host — the models are inherited, so this is an adapter, not a rebuild
**Dependencies:** FW-210, FW-211, FW-N05
**Blockers:** **G32** / **G33** *(the map is `[PROPOSED]`, so the sidecar serves paths we invented)*

---

**Simulator reconciliation** — RT `24+12+12+16 = 64` · FE `24` · BE `23` · dev base **111 h**; with `FW-217`
**135 h**. Indicative all-in on 111 h: QA `0.20 × 111 = 22` → Cont `0.15 × (111+22) = 20` → **153 h**.

> ⚠ **QA and contingency are shown here as an indication only.** `[CE §2]`'s convention is that both are
> applied **at phase level, never per story** — pricing them per card double-counts. The 111 h dev figure is
> the one to carry.
>
> ⚠ **`FW-216` is deliberately unused.** The console mockup
> ([`simulator_console.html`](../50-frontend/mockups/simulator_console.html)) is a planning artifact, not a
> story — `[CE §2]` prices a screen at 24 h **with** the mockup as its approved visual spec and no design
> time included.
>
> ⚠ **`FW-224` is RESERVED and not yet minted.** It is the **FL2 pre-check-in** story owed by the
> 20 Aug 2026 client call, which reversed `FR-031` — see [`ClientCall_2026-08-20_SyncPlan.md`](../95-archive/source-documents/ClientCall_2026-08-20_SyncPlan.md)
> wave **W7** and action **`A6`** (*size `FW-224`+ across DB, BE, FE and test, additive to the 3,186 h
> baseline*), still unreported as of the 24 Aug call. **`FW-225`–`FW-230` were minted over it on
> 22 Aug 2026**, so `FW-224` is a hole in the sequence rather than the tail — that is deliberate and the
> id stays claimed for this story. It is **blocked on `Q41`** (what an FL2 pre-check-in actually does),
> which is `Critical` and open. Cited from `Q41`'s Related line and `CHANGELOG.md`; **do not reuse it**
> and do not read those citations as evidence it exists.

---

##### S0 · Phase 1C — Database Foundation

**Spec:** [`phase-01c-database-foundation.md`](phases/phase-01c-database-foundation.md) · **Owner:** DB · **215 h** (DB 156 · QA 31 · cont. 28)

> **The DDL already exists** in [`../Database/Schema/SQL/`](../Database/Schema/SQL/). This layer **retargets, hardens, seeds and wires** it. Target is a new standalone **`FlatWireDB`**, not `united_db`.
>
> **`Rod` is retained** — master-spec `D-04` supersedes Foundations decision 3. **Anything saying "`Rod` is dropped" or "21–22 tables" is stale** (**G12**, closed 11 Aug 2026).

---

###### FW-001 · Shared-schema column renames and new columns
**Hours:** 0 h DB *(was 56 h)* · **Priority:** Cancelled · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

> ⚠ **CANCELLED — the heading keeps its id and title deliberately.** `FW-###` ids **and their titles** are the repo's join key: the workbook builds parse this heading and reject a story whose title drifts from the client-facing content files. Cancel in the body, never in the heading.

> ⚠ **CANCELLED 18 Aug 2026 — decision `D-32`. There will not be any shared-schema migration.** The existing
> `coils` / scheduling schema is **read and written as it stands and is never altered**. The card is retained
> rather than deleted because `FW-###` ids are the repo's join key and six stories cite this one.
> **−56 h from Phase 1C**; the 40 h impact audit goes with it, as does `[RB §6.3]`'s rename rollback treatment
> and `FW-201`'s QA4 regression pass. **Dependent stories:** `FW-002` is cancelled too; `FW-004`, `FW-005`,
> `FW-006` and `FW-007` build `FlatWireDB` and never needed the renames, so their dependency is **removed,
> not satisfied**; `FW-176`, `FW-186` and `FW-201` lose the acceptance criteria that referenced it.

**Acceptance Criteria — none of the following is to be built:**
- [ ] Renames applied: `CoilNo → Coil/BundleNo` · `SlitWidth → Slit/FlatWidth` · `IsCampaingCoil → IsCampaignCoil/Bundle` *(typo corrected)* · `CoilLocation → Coil/BundleLocation` · `CoilWeight → Coil/BundleWeight` · `CoilStatus → Coil/BundleStatus` · `OutgoingCoilId → OutgoingCoil/BundleId` · `OutgoingCoilOd → OutgoingCoil/BundleOd`
- [ ] New columns added: `OutgoingCoil/BundleWidth`, `IncomingWireDia`
- [ ] **A full SP / view / report impact audit across `united_db` and the legacy `ual-dot-net` tier completes BEFORE the migration runs** — this is a discrete 40 h line item, not a rounding
- [ ] All existing stored procedures, views and API queries updated to the new names
- [ ] No regression in existing reports or screens; regression suite re-run in Phase 14 (FW-201)

**Rate-card basis:** ~~rename migration 16 h + **FW-001 impact audit 40 h** (discrete item, §2) = 56 h~~ → **0 h, cancelled**
**Dependencies:** None
**Blockers:** —

> ~~**Highest blast radius in the plan.**~~ It **had been** the highest blast radius in the plan — these would have landed on the **shared** `coils`/scheduling schema, which the legacy applications and existing reports also read, which is why `phase-01c` said *"front-load the impact audit."* **That risk is now removed rather than managed.** The residual is **`OI-111`**: with no shared marker, nothing in the shared schema shows that a rod is on a flattening line, and the 40 h audit that would have found any report depending on it is cancelled too.

---

###### FW-002 · `INFLAT` coil status
**Hours:** 0 h DB *(was 4 h)* · **Priority:** Cancelled · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

> ⚠ **CANCELLED 18 Aug 2026 — decision `D-32`.** The shared coil-status vocabulary never gains `INFLAT`.
> ⚠ **`INFLAT` itself is not cancelled** — it survives as a **`FlatWireDB`-local** value on `Rod.Status`,
> `SpoolProcessing.Status` and `RodCheckout.NewRodStatus`, where the CHECK constraints in `03_Materials` and
> `05_QualityOutput` already carry it and are untouched. What goes is the **shared** half: `FR-077`'s
> `coils.coil_status = INFLAT` write and the `INFLAT` term in `FR-044`'s shared-side availability test,
> which now reads local `Rod.Status`. **−4 h from Phase 1C. `OI-111`** carries the upstream-visibility
> consequence; `OI-01`'s headline question is moot and only its reqsum residual survives.

**As a** scheduling operator,
**I want** a coil status marking material actively on a flattening line,
**So that** in-process flat wire is distinctly tracked.

**Acceptance Criteria:**
- [ ] `INFLAT` added to the coil status reference table
- [ ] **Set at check-in only.** The pre-check-in / staging path must **not** write `coils.coil_status` — narrowed by the 30 Jul client answer
- [ ] Cleared on rod checkout, run completion or WIP rejection
- [ ] Appears in every status dropdown and filter list where coil status is shown
- [ ] Existing status transition rules are unbroken

**Rate-card basis:** reference-data change (4 h, §2)
**Dependencies:** ~~FW-001~~ — cancelled with it
**Blockers:** —

---

###### FW-152 · `FlatWireDB` creation, ordered DDL runner, indexes and grants
**Hours:** 12 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** database owner,
**I want** the whole schema deployable by one idempotent, ordered script,
**So that** any environment can be rebuilt from scratch and re-run safely.

**Acceptance Criteria:**
- [ ] `FlatWireDB` created; every `USE [united_db]` header retargeted
- [ ] Execution order preserved, a contiguous chain: `00` database → `01` Lookup → **`02` Schedule** → `03` Materials → `04` Runs → `05` Quality/Output → `06` **all FKs last** → `07` Indexes → `08` Programmability. ⚠ **`02_Schedule` IS in this chain** — `D-31` (15 Aug 2026) moved the three `PassSchedule*` tables into MVP-1. *(This line read "`02_Schedule` is absent — the pass schedule is owned outside MVP-1" until 26 Aug 2026.)* Only `09_Programmability_MVP2` stays out
- [ ] Every `CREATE` and FK guarded (`IF NOT EXISTS`); `FlatWire_DDL_RunAll.sql` is **idempotent and re-runnable**
- [ ] All ER-doc recommended nonclustered indexes present, including `(RunId)` on every child/event table
- [ ] `GRANT EXECUTE` / least-privilege for `ua_user`; audit columns on override tables
- [ ] Post-run check: the objects are **`sp_GetGaugeTrace`** and **`trg_CoilTraceability_NoOverlap`**; the counts are `[DBD §6.2]`'s and are verified by `[DEP §4.2]`'s `V1`–`V3` gate or [`../tools/deliverables/verify_schema_counts.py`](../tools/deliverables/verify_schema_counts.py), **not restated here**. *(This line published `33 · 55 · 69` until 26 Aug 2026; `Q89` took the index count to 70 that day.)*
- [ ] **`sp_ShiftSummary` is MVP-2's and must not be created, dropped or granted from this scope**

**Rate-card basis:** database creation + ordered runner + index strategy + security (12 h, §2)
**Dependencies:** None
**Blockers:** —

---

###### FW-005 · Lookup group tables and seed
**Hours:** 16 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** the lookup tables created and seeded with fixed identity values,
**So that** the sample data FK-resolves and the die change has a catalogue to validate against.

**Acceptance Criteria:**
- [ ] Tables created: `Stand`, `Drawer`, `Edger`, `Dancer`, `Spool`, `AlloyProperty`, `PayoffPosition` *(`SpoolConfiguration` merged into `Spool`, 23 Aug 2026 — `Q60`)*
- [ ] `FlatWire_SampleData_Lookup.sql` authored — it was **missing**, and the schedule seed depended on it
- [ ] `Stand` seeded with **four rows carrying `RollDiameterIn`**: FM1 12.000 · **`FM2_S1` 8.000 · `FM2_S2` 6.000 · `FM2_S3` 6.000**. Identifiers are **position-only**; diameter is data
- [ ] `Drawer` seeded with the **13 size rows** (`DIE-0210`…`DIE-0340`) carrying `LastGrindingFeet` and `TotalFeetAllowed` — this is what MVP-1's die change validates against
- [ ] `Edger` seeded `Round` / `Square`; `PayoffPosition` seeded with its **3 pinned rows**
- [ ] Fixed IDENTITY values: `Stand.Id 1–4`, `Drawer.Id 1–13`, `Edger.Id 1–2`
- [ ] **No fourth FM2 stand.** `FM2_6inS3` was withdrawn as never-existent — it never had a tag path or a seed row (`D-26`)

**Rate-card basis:** 4 tables @ 4 h = 16 h (§2); `AlloyProperty` is costed separately in FW-004
**Dependencies:** FW-152
**Blockers:** **`PLC-Q04`** / **G32** (FM2 PLC station names unconfirmed)

---

###### FW-004 · `AlloyProperty` lookup and seed
**Hours:** 8 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** process engineer,
**I want** per-alloy properties and tolerance bands held as reference data,
**So that** tolerances are maintainable without a code change.

**Acceptance Criteria:**
- [ ] `AlloyProperty` created with `Alloy`, `MaxReductionPerPass`, `SpringbackFactor`, `SpeedRangeMinFPM`, `SpeedRangeMaxFPM`
- [ ] **Four min/max tolerance pairs, not two single ± values** — `GaugeTolerance{Minus,Plus}In`, `WidthTolerance{Minus,Plus}In`, `RodDiameterTolerance{Minus,Plus}In`, `RodOvalityMaxIn`. Bands are offsets about nominal and **may be asymmetric**; ovality takes an upper limit only
- [ ] Seeded for 1100 / 1350 / 3003 / 5052 / 6061
- [ ] ⛔ **`RodDiameterTolerance{Minus,Plus}In` and `RodOvalityMaxIn` are NULL on purpose** — the values are owed by client e-mail. **Do not populate them from the Dashboard 2A mock map**, which is explicitly labelled mock data
- [ ] The `0.003"` ovality limit lives in this table, **never hard-coded** — it is per-alloy reference data, not a constant

**Rate-card basis:** 1 table + seed authoring (8 h, §2)
**Dependencies:** FW-152
**Blockers:** ⛔ **OQ-22** (the four tolerance values are owed by e-mail — **this also blocks `CHK007` in Phase 4 at both stations**)

> **The title in earlier versions read *"for pass schedule algorithm"* and misled.** This is **MVP-1 reference data**; only its consumer, `FW-013`, is MVP-2. Do not sweep it out on the title.

---

###### FW-006 · Materials group tables
**Hours:** 12 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** the material master tables created,
**So that** rod, run and spool records have somewhere to live and rod-alpha FKs can be enforced.

**Acceptance Criteria:**
- [ ] `Rod` created — a `FlatWireDB`-local master **mirroring** the shared `coils` record, with **enforced** rod-alpha FKs. `coils` remains the source of truth for the rod *lifecycle*; the mirror is what makes the FKs enforceable (`D-04`)
- [ ] `FlatWireRun` created — the hub table, so `SpoolProcessing.SourceRunId` can reference it
- [ ] `SpoolProcessing` created
- [ ] Indexes: `FlatWireRun(LineId, Status)`, `(Status)`, `(PassScheduleId)`, **`SpoolProcessing(SourceRunId)`**, **`SpoolProcessing(ParentRodAlpha)`** — *the two spool indexes were listed against `Spool` until 26 Aug 2026; since `Q60` (23 Aug) that is the article lookup and carries neither column*
- [ ] **`PassScheduleId` is a real, enforced FK** on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput`, created by `06`'s schedule section. Seeded values like `PS-1100-FL1-001` resolve to rows seeded by `FlatWire_SampleData_Schedule.sql`. *(This line said it "carries no local FK — a documented external reference, in the same class as `PlanId` and `SkidId`" until 26 Aug 2026; `D-31` retired that on 15 Aug. `PlanId`, `CoilOrderPlanId` and `SkidId` are unaffected and remain external references.)*

**Rate-card basis:** 3 tables @ 4 h = 12 h (§2)
**Dependencies:** FW-152
**Blockers:** **G17** (cross-DB logical FKs). ~~The `NOT NULL` question~~ — **closed by `D-31`**: `PassScheduleId` no longer asserts an existence MVP-1 cannot verify, because the FK verifies it. **Do not `NULL` it.**

> **Wholly MVP-1 since `D-31` (15 Aug 2026).** The three `PassSchedule*` tables are built by `02_Schedule` in the MVP-1 runner, their FKs are in `06` and their indexes in `07`. *(This note read "Spans scopes … the three `PassSchedule*` tables are MVP-2-owned. They are not created here" until 26 Aug 2026.)* ⚠ **MVP-1 builds and reads them and never authors a schedule** — DB9/DB9A stay MVP-2, no endpoint writes one, and nothing in MVP-1 populates them in production (`OI-110`).

---

###### FW-007 · Runs and Quality/Output group tables
**Hours:** 52 h DB · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1C · **Stream:** DB

**As a** developer,
**I want** every event and output table created with its constraints enforced in the database,
**So that** business rules stated in prose cannot be violated by application code.

**Acceptance Criteria:**
- [ ] **Runs (`04`):** `FlatWireRunDetail`, `RodCheckin`, `RodStaging`, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, **`RunReading`**
- [ ] **Quality/Output (`05`):** `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout`
- [ ] **`RunReading` created** — persists raw AGC gauge/width/speed readings, which nothing did before (**G3**). `RunId`, `FootageFt DECIMAL(10,2)`, `GaugeIn DECIMAL(8,4)`, `WidthIn`, `SpeedFPM`, `InSpec`, `ReadingTs`; index `(RunId, FootageFt)`; retention/rollup policy defined
- [ ] **Constraints enforced in DDL, not prose:** `CoilTraceability` non-overlapping footage ranges per coil (trigger); `RunPauseEvent.Notes` required when `ReasonCategory='Other'`; `WeldEvent` fail reason required when `WeldQuality='Fail'`; `CK_RodCheckout_ModeP` and `CK_RodCheckout_ModeB` per-mode field rules
- [ ] **`RodCheckout.NewRodStatus` carries a `CHECK`** — `IN ('RECEIVED','STAGED','INFLAT','COMPLETE','HOLD','SCRAP')`; every other status column already had one
- [ ] **`CheckpointType` `CHECK` is five-valued** and includes `'RollAdjustTrigger'` — mirrors FW-147
- [ ] **`RodStaging` invariants:** `Blocked` is a **derived** bay state (`Status='Staged'` + any inspection column `='Fail'`), **never a fourth `Status` value**; `IsWelded` is a **flag on a `Staged` row**, not a status. Carries `UnstageKind` and `WipRejectionId` (FK → `WipRejection`) so a rejection can release a blocked bay
- [ ] **`RodCheckout` carries `WasWelded`, `ApprovedBy`, `ApprovedAt`, `OverrideReason`** — it had no approval columns at all, so two decided rules had nowhere to write (**G24**)
- [ ] **Precision: the DDL scaled types are authoritative** — weights `DECIMAL(8,2)`, gauges `DECIMAL(8,4)`, footage `(10,2)`. **Do not regenerate DDL from the schema `.md` files**, which say bare `decimal` (= `decimal(18,0)`) and would drop precision

**Rate-card basis:** 12 tables @ 4 h = 48 h (§2). **⚠ 15 tables are built here; 12 are costed** — §8 records that 1C is costed against 22 tables against a larger build, and is therefore **understated**. ⚠ **`[CE §8]` publishes no total for it** — the *"~17 h all-in"* this line quoted until 26 Aug 2026 rested on a build of 25 and is withdrawn at the source; `[TRP §1.4]` carries its own ~21 h / ~33 h figures on a build of 28, also stale. The figure above is the published one, not the rate-card sum. ⚠ **The table count in this derivation is stale — flagged, not substituted (23 Aug 2026).** The live figure is `[DBD §6.2]`. Replacing the count without re-deriving the hours would make the arithmetic lie, and per the standing convention an effort change lands in an **additive new sheet, never an in-place edit of a total**. **Owed: re-derive against `[DBD §6.2]` using `[CE §2]`'s rate card** — `[CE]`'s owner, not this document's.
**Dependencies:** FW-152, FW-006
**Blockers:** **G21** (`UX_RodStaging_Bay` does not enforce one-rod-per-bay across FL1/FL3 — **blocks the Phase-4 schema freeze**) · **G14** (`FootageFt` INT vs DECIMAL) · **G34** (wire break has a decided flow and still no persistence target)

---

**Phase 1C reconciliation** — DB `12+16+8+12+52 = 100` → QA `0.20 × 100 = 20` → Cont `0.15 × (100+20) = 18` → **138 h**

> ⚠ **Re-derived 18 Aug 2026 — `D-32`.** Previously `56+4+12+16+8+12+52 = 160` → QA 32 → Cont 29 → **221 h** ✓ (§3b). `FW-001` (56) and `FW-002` (4) are **cancelled**, so the base falls by 60 h and QA and contingency are re-derived from the reduced base — the convention `[CE §3b]` uses for every carve. **221 → 138 h, −83 h all-in.** This is a **removal of scope, not a productivity claim**, so the QA line is re-derived rather than held; `[CE §8]`'s warning against mechanically re-applying the 20 % concerns work that *moved* into manual regression, and here there is no work left to regress.

> **Restated 15 Aug 2026 from 215 h.** `FW-007` 48 → 52 h for **`G21`**: the `RodStaging.Station` column plus re-keying `UX_RodStaging_Bay` from `(LineId, PayoffPosition)` to `(Station, PayoffPosition)`. ⚠ **Separate from `[CE §8]`'s understatement**, which is about the costed table count rather than any scope change — **do not net them**; one is a costing gap, the other scoped work. *(The "~17 h" figure this line quoted until 26 Aug 2026 is withdrawn at the source — `[CE §8]` publishes the per-table 4 h and no total.)*

**S0 total** — `370 + 519 + 138 = **1,027 h**` ✓ · 12 working days · **10.7 FTE** *(1C re-derived to 138 h by `D-32` six lines above; this roll-up still carried the pre-`D-32` 221 h and its 1,110 h / 11.6 FTE until 26 Aug 2026. `[CE §3c]` publishes the same 1,027 h — ⚠ **check the composition, never the total**: §2–§5 of `[CE]` carry a differently-composed 1,027 h that predates the 1B restatements.)*

> **Corrected 15 Aug 2026.** This line read `370 + 442 + 215 = 1,027` and was stale by two restatements: 1B **442 → 519** (14 Aug omissions, then `D-29`, then the backend-test withdrawal and `SpoolController`) and 1C **215 → 221** (`G21`'s `Station` column). **`[CE §2]`–`§5` still publish 1,027 / 10.7 FTE deliberately** — re-deriving them there is a programme re-baseline, per `[CE §8]`.

---

#### S1 — Real-Time Backbone

**Dates:** Mon 24 Aug – Fri 4 Sep 2026 · **10 working days** · **80 h/person**
**Phases:** 3 Line Status Board & Real-Time Backbone *(whole)*
**Hours:** **190** · **Required FTE: 2.4**
**Goal:** the live backbone. First end-to-end slice: OPC → `FlatWireHub` → Dashboard 1.

**Entry criteria:** S0 exit met — hub skeleton and OPC poller exist; scheduling data available upstream.
**Exit criteria:** Dashboard 1 renders live line-state, gauge/width, payoff, speed and run-time via SignalR (real or simulated); alert rules firing; hub load test executed.
**Demo:** a supervisor watches three lines update live from the simulated PLC feed, with alerts raising and clearing.
**Gates:** **M2 (6 Sep)** Dashboard 1 live · **QA1 (6 Sep)**.

> **The single most consequential resequencing in the plan.** The real-time backbone (`FW-080`/`FW-081`) previously sat in the last sprint, **after** the dashboards that depend on it. It is now built before them. Anything still sequencing from the old five-sprint model will build the consumers first.
>
> **The carry-over week (17–21 Aug) precedes this sprint** and carries Phase-1 completion only. It is the plan's entire recovery budget — 200 person-hours at 5 FTE. Spending it on new scope removes the only slack there is.

---

##### S1 · Phase 3 — Line Status Board & Real-Time Backbone

**Spec:** [`phase-03-line-status-board-realtime-backbone.md`](phases/phase-03-line-status-board-realtime-backbone.md) · **Owning specification:** [`LineStatusOverview.md`](../10-requirements/screens/LineStatusOverview.md) (DB1) · **Owner:** RT + FE · **190 h** (FE 64 · BE 16 · DB 4 · RT 40 · QA 41 · cont. 25)

---

###### FW-060 · Dashboard 1 — Line Status Overview
**Hours:** 44 h FE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** FE

**As a** supervisor,
**I want** a persistent board showing all three lines live,
**So that** I have floor-wide situational awareness without walking the floor.

**Acceptance Criteria:**
- [ ] `dashboard-1-line-status` built from `../50-frontend/mockups/dashboard_1_line_status.html`
- [ ] `line-status-panel` per line showing status badge, order/alpha, alloy/route, speed, gauge/width, payoff weight bar + Payoff-2 status, run time
- [ ] **Gauge/width live on FL1/FL3; blank for FL2 idle** — FL2 standalone broadcasts `null` and the panel must show an explicit empty state, never a flat line at target
- [ ] Subscribes to `lineStatus$ / gaugeReading$ / widthReading$ / speedFpm$ / payoffWeight$ / alertRaised$ / alertCleared$`
- [ ] Clicking a panel routes to that line's Dashboard 3 (running) or Dashboard 2/5 (idle)
- [ ] **No header drill-downs to Dashboard 13 / 14** — both descoped 4 Aug 2026, `FR-425` withdrawn
- [ ] Reuses `payoff-weight-bar` and `alert-banner` from FW-133 / FW-134 — not reimplemented

**Rate-card basis:** new dashboard 24 h + `line-status-panel` composite 20 h = 44 h (§2)
**Dependencies:** FW-133, FW-134, FW-135, FW-154
**Blockers:** **GAP-8** (show pass-schedule id on DB1 — open, low)

---

###### FW-153 · Alert chips, reconnect banner and cached-state fallback
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** FE

**As a** supervisor,
**I want** alerts visible on the board and a clear message when the feed drops,
**So that** I can tell the difference between "nothing wrong" and "not connected".

**Acceptance Criteria:**
- [ ] Alert chips render below the panels for each of the five rules, with severity styling
- [ ] Alerts auto-dismiss on `AlertCleared`
- [ ] SignalR drop → "Reconnecting…" banner with cached last-known state; **never a blank screen**
- [ ] Cached state is visibly marked as stale rather than presented as live

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-134, FW-137, FW-N06
**Blockers:** —

---

###### FW-154 · `GET /lines/status` and `LineStatusService`
**Hours:** 16 h BE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** BE

**As a** client developer,
**I want** a snapshot endpoint for page load,
**So that** the board renders immediately and then goes live rather than starting empty.

**Acceptance Criteria:**
- [ ] `LinesController` `GET /lines/status` returns `LinesStatusResponse` / `LineStatusDto` / `PayoffStatusDto` / `ActiveAlertDto`
- [ ] `PayoffStatusDto` carries bay **occupancy** (`state`, `rodAlpha`) alongside live weight
- [ ] `LineStatusService` composes scheduling data + run state + latest OPC readings
- [ ] Any authenticated role may read
- [ ] Contract test against `04-APIContract.md`

**Rate-card basis:** query endpoint 4 h + `LineStatusService` non-trivial service 12 h = 16 h (§2)
**Dependencies:** FW-138, FW-141
**Blockers:** —

---

###### FW-155 · `FlatWireRun(LineId, Status)` index
**Hours:** 4 h DB · **Priority:** Medium · **Sprint:** S1 · **Phase:** 3 · **Stream:** DB

**As a** database owner,
**I want** the line-board query covered by an index,
**So that** a board polled by every supervisor terminal does not table-scan the hub table.

**Acceptance Criteria:**
- [ ] Nonclustered index on `FlatWireRun(LineId, Status)` created in `07_Indexes`
- [ ] `GET /lines/status` execution plan uses it
- [ ] Idempotent guard, consistent with FW-152's runner

**Rate-card basis:** index as part of the table rate (4 h, §2)
**Dependencies:** FW-006
**Blockers:** —

---

###### FW-N06 · Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle
**Hours:** 40 h RT · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** RT

**As a** supervisor,
**I want** the system to raise and clear alerts on defined thresholds,
**So that** a developing problem reaches me before it stops the line.

**Acceptance Criteria:**
- [ ] Five rules implemented: Payoff1 < 3,000 lb → **Warning** · gauge outside ±tolerance → **Warning** · component fault → **Critical** · active WIP rejection → **Warning** · **Payoff2 not loaded AND Payoff1 < 2,000 lb → Critical**
- [ ] `AlertRaised` and `AlertCleared` broadcast as **rare domain events — immediate and unbatched**, never inside the 10 Hz telemetry batch
- [ ] **"Payoff2 not loaded" reads `RodStaging`** — a `Staged` row on `(LineId, PayoffPosition)` means loaded. `PayoffWeight` alone **cannot** distinguish an empty bay from a sensor reading zero
- [ ] Consumes `PayoffStateChanged` (Phase 4) to keep the evaluation live
- [ ] Unit tests cover each threshold's raise and clear edges

**Rate-card basis:** 5 × hub event / rule @ 8 h = 40 h (§2)
**Dependencies:** FW-149, FW-150
**Blockers:** **⚠ Until Phase 4 delivers `RodStaging`, rule 5 cannot be evaluated at all** — nothing else records bay occupancy. Phase 4 back-feeds this phase · **OI-28** (alerts unbacked)

---

###### FW-204 · Minimal landing route — the entry point when Dashboard 1 is out of scope
**Hours:** 8 h FE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** FE

> **New 14 Aug 2026 for the six-screen trial run** ([`TrialRunPlan.md`](TrialRunPlan.md) §1.5). **Dashboard 1 was
> removed from trial scope on client direction**, and it was the target of **every** mockup's back button plus
> Dashboard 5's Cancel — so the trial had no entry point and no way back into a running line. This is the smallest
> thing that closes that hole. It is **not** a reduced Dashboard 1: no live panels, no alert bar, no payoff bars.
> `FW-060` is unaffected and still owns the real board. Hours are **additional to `[CE §3b]`**.

**As an** operator arriving at a terminal,
**I want** to pick my line and land on the right screen for its current state,
**So that** I can start work without knowing which screen to open.

**Acceptance Criteria:**
- [ ] Route `/flat-wire` — two tiles, **FL1** and **FL2**, each showing line name and current state only
- [ ] **Idle** routes to that line's check-in screen — Dashboard 2 for FL1, Dashboard 5 for FL2. **Running** routes to Dashboard 3 in that line's mode
- [ ] State is read from **`GET /run/active?line=`** (`FW-164`, already in scope). ⚠ **Adds no endpoint** — in particular it must **not** pull in `GET /lines/status` (`FW-154`), which left trial scope with Dashboard 1
- [ ] Becomes the target of every screen's back control and of Dashboard 5's Cancel, **replacing `dashboard_1_line_status.html`** for the trial
- [ ] Carries the `FR-119` / `NFR006` reconnect banner over cached state like every other screen — it is a route in the shell, not an exception to it
- [ ] ⚠ **Retired, not extended, when `FW-060` lands.** Dashboard 1 is the entry point in full MVP-1; leaving both in place gives the operator two front doors

**Rate-card basis:** screen variant @ **8 h** (§2) — two tiles and a state-conditional route, well under a new screen's 24 h. **5 h AI-assisted** at `[DE §1]`'s 0.62 FE factor, which is the figure `[TRP §4]` schedules
**Dependencies:** FW-N03, FW-130, FW-164
**Blockers:** —

---

###### FW-156 · Hub load test
**Hours:** 16 h QA · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** QA

**As an** architect,
**I want** the hub load-tested at realistic client counts,
**So that** a real-time design decision is validated before eight phases depend on it.

**Acceptance Criteria:**
- [ ] Load test executed: N clients × 3 lines × configured cadence
- [ ] Measures message latency, dropped/coalesced reading counts, and server CPU/memory under sustained load
- [ ] Results recorded against the run, whatever they are

**Rate-card basis:** hub load test — **discrete item, 16 h** (§2), sitting on top of the phase's 20% QA uplift
**Dependencies:** FW-080, FW-150
**Blockers:** ⚠ **G9 / OI-34 — this test has no pass criteria.** The NFRs it would be judged against (AGC sample rate, concurrent client count, latency budget, `RunReading` retention) **do not exist**. Any resulting real-time rework is **not** in the 3,292 h

---

**Phase 3 reconciliation** — FE `44+20 = 64` · BE 16 · DB 4 · RT 40 · base **124** → QA `(0.20 × 124 = 25) + 16 load test = 41` → Cont `0.15 × (124+41) = 25` → **190 h** ✓ (§3b)

> ⚠ **`FW-204` is not in that reconciliation.** Trial-run scope, 14 Aug 2026, and its **8 h is additive to
> `[CE §3b]`** — the same treatment as `FW-202` and `FW-203`. It is also the only one of the three that is
> **temporary**: it retires when `FW-060` ships, so it never enters the MVP-1 baseline at all.

**S1 total** — **190 h** ✓ · 10 working days · **2.4 FTE**

---

#### S2 — The Full FL1 Operator Journey

**Dates:** Mon 7 Sep – Fri 18 Sep 2026 · **9 working days** *(Labor Day Mon 7 Sep excluded)* · **72 h/person**
**Phases:** 4 Rod Check-In · 5 Active Run Monitoring · 6 In-Run Events · 7 WIP/Checkout · 8 FL2 Spool Check-In *(starts)*
**Hours:** **971** · **Required FTE: 13.5**
**Goal:** stage a rod, check it in, push PLC tags, watch it run, record every in-run event, and take both exception off-ramps.

**Entry criteria:** S1 exit met; an Active pass schedule available from the **externally-owned** pass-schedule track; upstream rod receiving and planning/scheduling supplying material and jobs.
**Exit criteria:** rod staged, checked in, PLC tags pushed (simulated), live trace running, every in-run event recorded, both exception off-ramps working.
**Demo:** stage → check in → run → weld → SPC → die change → pause → WIP reject → check out.
**Gates:** **M3 (13 Sep)** first full FL1 slice live · **QA2 (13 Sep)** check-in rollback + real-time integration on staging.

> **The sequential chain `4→5→6→7` must fit inside 9 working days**, alongside Phase 8's start. This is the compression the even cadence produces; the phases genuinely depend on each other and cannot be parallelised away.
>
> **Phase 8's 118 h splits evenly across the S2/S3 boundary** (59 h each), matching the capacity model's own W5/W6 split. Its story bodies are listed once, under S2.

---

##### S2 · Phase 4 — Rod Check-In & PLC Configuration (FL1 / FL3)

**Spec:** [`phase-04-rod-checkin-plc-config.md`](phases/phase-04-rod-checkin-plc-config.md) · **Owning specifications:** [`RocCheckin.md`](../10-requirements/screens/RocCheckin.md) (DB2) · [`RodPreCheckin.md`](../10-requirements/screens/RodPreCheckin.md) (DB2A) · **Owner:** FE + BE + RT · **255 h** (FE 60 · BE 62 · DB 28 · RT 28 · QA 36 · BA 8 · cont. 33)

> **⚠ Estimate provisional — carries a 24–64 h reserve excluded from the total**, pending `OI-39` / **G2**: cross-database check-in recovery is undecided between saga/outbox and an `INFLAT` mirror.
>
> **The pass schedule is an external dependency, not a Phase-2 deliverable.** MVP-1 builds no authoring UI and creates no schedule. It **reads** one: step 2 displays it, the operator acknowledges it, and that acknowledgement is the single trigger that writes PLC tags.

---

###### FW-061 · Dashboard 2 — Rod Check-in six-step wizard (FL1/FL3)
**Hours:** 36 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** FE

**As an** FL1 operator,
**I want** a guided check-in that will not let me proceed until every gate clears,
**So that** the machine is configured correctly and a wrong schedule is never silently applied.

**Acceptance Criteria:**
- [ ] Built from `../50-frontend/mockups/dashboard_2_rod_checkin.html` — a **six-step tab-wizard with progressive unlock**: (1) Visual Inspection · (2) Pass Schedule · (3) Pre-run SPC · (4) Die Block (DB1/DB2) · (5) Rolling Mill (FM1) · (6) Lube & Safety
- [ ] Footer **Acknowledge & Begin Check-in** disabled until all six steps clear, or a supervisor override is on file for a deviation
- [ ] Step 2 confirm-bar is **amber until Confirm Schedule, then green**; "Change ▼" lists alternates with non-recommended ones flagged for Ops review. **PLC tags are never pushed before this confirmation**
- [ ] Pass-schedule unavailable → **blocking error on step 2**, not a warning. There is no partial path and no default schedule
- [ ] Payoff selector renders **pre-filled and read-only** when the rod arrived via pre-check-in (`CHK005`)
- [ ] Uses `tab-wizard`, `pass-schedule-table`, `confirm-bar`, `payoff-option`, `tolerance-viz` and the OK/NG/NA buttons from FW-133 / FW-134 — **the retired inline-SVG progress ring is not used**
- [ ] On success → **Dashboard 2A** to stage the next rod (`FR-079a`); on inspection fail → WIP rejection dialog

**Rate-card basis:** new dashboard 24 h + six-step wizard uplift 12 h = 36 h (§2, above base rate for the wizard's six steps)
**Dependencies:** FW-133, FW-134, FW-157; **`FW-020`** *(upstream, deleted)*, **`FW-010`** *(MVP-2)*
**Blockers:** **OQ-3** *(Critical — traveler fields per station)* · **OQ-14** *(Critical residual — no-match path)* · ⛔ **OQ-22** *(tolerance values owed by e-mail — gates `CHK007`)* · **OQ-25** · **OQ-73** · **OI-109** *(return-to-DB2A pending client confirmation)* · **G14**

---

###### FW-N01 · Dashboard 2A — Rod Pre-Check-in station
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** FE

**As an** FL1 operator,
**I want** to stage the next rod against the idle bay while the current one runs,
**So that** the line can run continuously through an induction weld.

**Acceptance Criteria:**
- [ ] Built from `../50-frontend/mockups/dashboard_2a_rod_precheckin.html` — **three body regions**: two payoff bay cards (`NOT STAGED` / `PRE-CHECKED-IN` / `ACTIVE` / `BLOCKED`) and a **"Rods In Queue"** table
- [ ] **FL1/FL3 only for rod staging** — `RodStaging` stays `FL1`/`FL3`. ⚠ FL2 pre-check-in was granted 20 Aug 2026 (`FR-533`) and lands in `SpoolStaging`, story **`FW-224`** (reserved, unsized, blocked on `Q41`)
- [ ] Three modals: a **3-step** pre-check-in wizard (Identify rod → Assign bay → Visual inspection), pre-check-out, and the read-only weld list
- [ ] **Mark as Welded** sits on the **staged** card, enabled only when that bay is staged *and* the other is running; **Welds this run · N** sits on the **active** card. **There is no weld-readiness strip**
- [ ] **Mark as welded captures quality** — Pass/Fail with a reason mandatory on Fail. **Neither result is pre-selected** and confirm stays disabled until one is chosen; a pre-selected Pass on the gate that exists to make the operator look at the join is a rubber stamp
- [ ] **The outgoing/incoming pair for a weld resolves from whichever bay is actually running**, never from the card the operator activated (`FR-050a`) — after a payoff transition the running bay may be either one
- [ ] Bay-card actions are regenerated on every render, so handlers are bound **per render or by delegation**, not once at init
- [ ] At most **one primary action per card**; the `ACTIVE` card deliberately has **none** — both its actions are exceptional
- [ ] **Clone the Dashboard 12 skeleton, not Dashboard 2's** — DB2 inlines its own app bar and omits `flat-wire-topbar.js`
- [ ] **Ships against a stub** for `POST /weldevent` and `GET /run/{runId}/weldevents` (**G26**) — both land in Phase 6; the read returns an empty array until then, stubbed with sample rows for the gate review

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-133, FW-134, FW-158; de-stubbed by FW-166
**Blockers:** **G19** *(resolved — 2 items need business sign-off)* · **G21** *(bay uniqueness across FL1/FL3 — blocks the schema freeze)* · **G22** · **G26** · **OI-108** *(Welds-this-run absent vs disabled at cold start)* · **OQ-24** *(wrong-station auto-switch)*

---

###### FW-157 · `POST /checkin/rod` and `CheckInService`
**Hours:** 36 h BE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

**As a** developer,
**I want** check-in orchestrated as ordered, compensating writes across two databases and the PLC,
**So that** a PLC failure never leaves a half-configured machine with a run marked Running.

**Acceptance Criteria:**
- [ ] `CheckInController POST /checkin/rod`; `CheckInRodCommand` (line, rodAlpha, payoff, diameterMeasured, weights, `InspectionDto`, scheduleId, operatorId, orderId) → `CheckInRodResponse` (runId, checkedInAt, plcTagsPushed)
- [ ] **Records are written BEFORE the PLC push** — inspection result, pre-run SPC checkpoint, run record with schedule id + version, acknowledgement audit entry — then `PLCTagService.PushPassSchedule(scheduleId, lineId, payoffPosition)`
- [ ] **MVP-1 persists its own snapshot of what it pushed** — schedule id, version and effective configuration — so a certificate stays reproducible after the owning system later edits the schedule
- [ ] Business rules: Draft schedule not acknowledgeable (`422`); single active run per line (`409`); all-or-nothing
- [ ] Where a staged row exists, the request's `payoffPosition` must match it (`409` on mismatch); check-in **consumes** the staged row (`RodStaging.Status → CheckedIn`, `RodCheckinId` linked) rather than creating a parallel record
- [ ] ⚠ **Described and implemented as compensating writes, never "atomic rollback"** — check-in spans `FlatWireDB` + `coils` + `wip_coil_orders` + the PLC and **is not one ACID transaction** (**G2**; `G16` closed 4 Aug 2026)
- [ ] PLC push audited (tag, value, operator, result); Operator+ policy

**Rate-card basis:** complex command spanning two databases and the PLC 20 h + `CheckInRod` service and validation rules 16 h = 36 h (§3 worked derivation)
**Dependencies:** FW-139, FW-141, FW-151
**Blockers:** ⚠ **G2 / OI-39** *(recovery design undecided — this is what the 24–64 h reserve is for)* · **OQ-14**

---

###### FW-158 · `PayoffStagingController` — staging commands and queries
**Hours:** 26 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

**As a** developer,
**I want** bay staging exposed as commands and queries with conflicts enforced by the database,
**So that** two rods can never occupy one bay through a read-then-write race.

**Acceptance Criteria:**
- [ ] `GET /payoff/status`, `GET /staging/queue`, `POST /staging/rod`, `POST /staging/rod/unstage`
- [ ] `StageRodCommand` (reuses the **3-item** `InspectionDto` — **do not add a connector-tag item**, see **G14**), `UnstageRodCommand` (writes `RodCheckout` with `Mode='ModeP'`), `MarkStagedRodWeldedCommand` (validates alloy/temper/diameter against the running coil)
- [ ] **Bay-occupancy conflicts surface as `409` from the filtered unique indexes**, not from application-level checking
- [ ] ~~**FL2 rejected `422`**~~ ⚠ **withdrawn with `FR-031`, 20 Aug 2026 reversal** — FL2 pre-check-in is accepted (`FR-533`). The endpoint change is wave W5 of the 20 Aug ledger and is **not yet applied**
- [ ] **An inspection `Fail` commits the staging row and returns `201` with `state: "Blocked"`** plus the WIP-rejection route, with **no override** — the bay must stay occupied because the failed bundle is physically on it *(changed 31 Jul 2026; was `422`-and-write-nothing)*
- [ ] Prior footage without acknowledgement rejected `422` (`PRC007`)
- [ ] **`POST /staging/rod/mark-welded` is not built** — it was retired 1 Aug 2026; DB2A's weld posts to `POST /weldevent` in Phase 6

**Rate-card basis:** 3 commands @ 6 h = 18 h + 2 queries @ 4 h = 8 h → 26 h (§2, §3 worked derivation)
**Dependencies:** FW-139, FW-159
**Blockers:** **G21** · **G22** · **OQ-23** *(WIP rejection releases a blocked bay — the cross-phase link to Phase 7)*

---

###### FW-159 · `RodStaging`, the check-in write path and the `INFLAT` write
**Hours:** 28 h DB · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB

**As a** developer,
**I want** every check-in write persisted with bay uniqueness enforced in the database,
**So that** application code cannot violate one-rod-per-bay.

**Acceptance Criteria:**
- [ ] `RodStaging` table live with the 3-item inspection, `RodSeqno`, `IsWelded`, carry-forward evidence (`FootageRunToDateAtStaging`) and release audit (`UnstageKind`, `WipRejectionId`)
- [ ] Repository/EF writes across `RodCheckin`, `FlatWireRun`, `SpcCheckpoint`, `SpcMeasurement`, `RodCheckout`
- [ ] ~~**Cross-database write setting the `coils` rod row to `INFLAT`**~~ → **`FlatWireDB`-local write setting `Rod.Status = 'INFLAT'`** — at check-in only, never at staging. ⚠ **Changed by `D-32` (18 Aug 2026):** `FW-002` is cancelled, so `INFLAT` is not a shared status value and this stops being a cross-database write at all. **The 8 h is deliberately held** — the write still has to be made, ordered and compensated; only its target moved
- [ ] Indexes: `RodCheckin(RunId)`, `RodCheckin(RodAlpha)`, **`RodCheckin(LineId, PayoffPosition)`** *(was missing)*, `RodStaging(LineId, Status)`, `RodStaging(RodAlpha)`
- [ ] **Filtered unique indexes `UX_RodStaging_Bay` and `UX_RodStaging_RodActive`** enforce one rod per bay and one bay per rod
- [ ] `PayoffPosition` lookup has its 3 pinned rows and `FlatWireRunDetail.PayoffPositionId` now has an enforced FK parent
- [ ] **`FL1PO` WIP station seeded** by `10_CommonDB_Insert_WIPStations_FlatWire.sql`, sharing FL1's `MachineIdx` — the legacy `ZR23`/`ZR23PO` pattern. **`FL2PO` stays absent** per `PCI002`

**Rate-card basis:** `RodStaging` table 4 h + repository/EF writes across five tables 16 h + ~~cross-DB~~ **local** `Rod.Status → INFLAT` write 8 h = 28 h (§3 worked derivation) *(target changed by `D-32`; the 8 h is unchanged and Phase 4's published figure is unaffected)*
**Dependencies:** FW-007
**Blockers:** ⚠ **G21 — `UX_RodStaging_Bay` does not enforce one-rod-per-bay across FL1/FL3, and the uniqueness scope is unresolved. This blocks the schema freeze for this phase** · **G2 / G17**

---

###### FW-160 · `PayoffStateChanged` and the check-in broadcasts
**Hours:** 12 h RT · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** RT

**As a** supervisor,
**I want** bay occupancy changes to reach the board immediately,
**So that** the "Payoff2 not loaded" alert reflects reality rather than a stale poll.

**Acceptance Criteria:**
- [ ] New event `PayoffStateChanged { lineId, position, state, rodAlpha, rodSeqno, isWelded }` on every bay-occupancy change — stage, un-stage, a **passing** weld, and check-in consuming a staged row
- [ ] **A failed weld changes no bay state and broadcasts nothing**
- [ ] **Sent immediately and unbatched** as a rare domain event — it must **not** enter the ~100 ms / 10 Hz telemetry batch. Live weight keeps coming from the batched `PayoffWeight`
- [ ] On check-in success, broadcast `LineStatus {status: Running}` so Dashboard 1 flips to RUNNING, and `ComponentStatus` reflecting the pushed values
- [ ] **If the PLC push fails, no broadcast is emitted** — state is compensated first

**Rate-card basis:** new domain event 8 h + `LineStatus`/`ComponentStatus` broadcast 4 h = 12 h (§3 worked derivation)
**Dependencies:** FW-149, FW-157
**Blockers:** —

---

###### FW-082 · PLC tag group push on check-in acknowledgement
**Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** RT

**As an** operator,
**I want** my acknowledgement to configure the machine in one operation,
**So that** the line runs the schedule I confirmed and nothing else.

**Acceptance Criteria:**
- [ ] `PushPassSchedule(scheduleId, lineId, payoffPosition)` writes the six value groups the push needs: **component active/bypass state · die sizes · roll gaps · edge type · speed · gauge and width targets**. Nothing else
- [ ] Written as a batch to the selected payoff position
- [ ] **Triggered only by the step-2 acknowledgement** — never at schedule generate or apply time, and never at pre-check-in
- [ ] Failure path performs **compensating re-clears**, and no `LineStatus` broadcast is emitted
- [ ] Every tag write audited (tag, value, operator, result)
- [ ] Runs under `SimulatePLCTagPush` until commissioning (FW-200)

**Rate-card basis:** PLC tag group push + compensating clear @ 16 h (§2)
**Dependencies:** FW-151, FW-157; **`FW-010`** *(MVP-2 — the schedule this reads)*
**Blockers:** **G2 / OI-39** · **G29** *(no edger tag path exists on any line, yet edge type is in the payload)* · **G30** *(FM2's controller namespace on FL3 undetermined)* · **`PLC-Q04`/`Q05`**

---

###### FW-161 · Traveler field list and the no-match path
**Hours:** 8 h BA · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BA

**As a** business analyst,
**I want** the traveler field list and the no-match behaviour settled with the client,
**So that** the wizard's final field set stops being provisional.

**Acceptance Criteria:**
- [ ] **OQ-3** closed — traveler fields per station confirmed with Operations. *(Traveler is fully digital; no printing. Coil and skid labels are still printed.)*
- [ ] **OQ-14** closed — the no-match path defined. The stub currently assumes a single active schedule resolving to `PS-1100-FL1-003`
- [ ] **OQ-25** progressed — what happens when a rod is scheduled on neither rod line, since the auto-switch then has no target
- [ ] Outcomes recorded in the register, not only in a meeting note

**Rate-card basis:** BA / Ops liaison (8 h, §3 worked derivation)
**Dependencies:** None
**Blockers:** **OQ-3** *(Critical)* · **OQ-14** *(Critical)* · **OQ-25**

---

**Phase 4 reconciliation** — FE `36+24 = 60` · BE `36+26 = 62` · DB 28 · RT `12+16 = 28` · dev base **178** · BA 8 → QA `0.20 × 178 = 36` → Cont `0.15 × (178+8+36) = 33` → **255 h** ✓ (§3b) · **+24–64 h reserve excluded**

---

##### S2 · Phase 5 — Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3)

**Spec:** [`phase-05-active-run-monitoring-gauge-trace.md`](phases/phase-05-active-run-monitoring-gauge-trace.md) · **Owning specification:** [`ActiveRunMonitor.md`](../10-requirements/screens/ActiveRunMonitor.md) (DB3) · **Owner:** FE · **154 h** (FE 76 · BE 12 · DB 8 · RT 24 · QA 22 · cont. 12)

> **This phase owns the DB3 shell for all three lines.** Build the components once here; Phases 8 (FL2) and 10 (FL3) **configure** them. FL1 and FL2 diverged once already and the 2 Aug 2026 mockup pass undid it — **do not let a line fork its own copy.**
>
> **⚠ Arithmetic note.** This is the one phase whose QA and contingency do **not** follow the 20% / 15% uplift: the −67 h DB13/DB14 descope of 4 Aug 2026 was applied to the published total rather than re-derived. The row still sums exactly (`76+12+8+24+22+12 = 154`), and the published figure is used here unchanged.

---

###### FW-062 · Dashboard 3 — Active Run Monitor (FL1) and FL3 variant
**Hours:** 32 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** FL1 operator,
**I want** one screen showing the run live with every action one click away,
**So that** I never leave the monitor to record something.

**Acceptance Criteria:**
- [ ] `dashboard-3-active-run` built from `../50-frontend/mockups/dashboard_3_active_run.html`, plus the FL3 variant `dashboard_3_active_run_fl3.html`
- [ ] Header shows Order / Alpha / Alloy / Target Gauge / Target Width
- [ ] **Action bar grouped by intent** — *Run events* (SPC Checkpoint · WIP Reject) · *Go to* (Die Change · Check Out Rod, **disabled once footage > 0**) · *Run control* (Pause run · **Complete Run**, confirmation-gated)
- [ ] **FL1 has no Roll Adjust** (`FR-107` — one mill). **FL3 adds it** (`FR-108`)
- [ ] **No Log Weld button on any line** — Dashboard 4 was retired 1 Aug 2026 and the weld is captured at pre-check-in
- [ ] After N consecutive out-of-spec readings (**configurable, default 5**) → auto-prompt SPC toast
- [ ] SignalR drop → reconnect banner with cached state
- [ ] **Dashboards 13 and 14 are not built** — descoped 4 Aug 2026, both mockups deleted

**Rate-card basis:** new dashboard 24 h + FL3 screen variant 8 h = 32 h (§2)
**Dependencies:** FW-133, FW-162, FW-163, FW-081, FW-164
**Blockers:** **`PLC-Q02`** · configurable out-of-spec N

---

###### FW-162 · `run-status-cards`
**Hours:** 20 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** operator,
**I want** machine, material and component state in one card strip,
**So that** I can read the whole line at a glance.

**Acceptance Criteria:**
- [ ] Three-card strip on a `1fr 1.35fr 1fr` grid; **absorbs the former `machine-status-panel`**
- [ ] Outer cards are **Machine** (run time, speed, footage, spool fill, lube temp) and **Components** (dies, gap + width, headed by the pass-schedule id) on every line
- [ ] **The middle card is line-specific** — *Payoffs* (two rod payoffs with consumption bars) on FL1/FL3, *Material flow* (spool draining in, coil filling out) on FL2. **Same shell, different middle card**
- [ ] **`payoff-weight-bar` survives as the Payoffs card's content**, not as a sibling of the status panel. It is still used directly by Dashboard 1, so it stays in the FW-133 shared set — this is a change to DB3's composition, not a deletion
- [ ] The FL2 material-flow card is **not** a payoff bar and must not reuse its labels

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-133
**Blockers:** —

---

###### FW-163 · `info-grid` and `chart-tab-strip`
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** operator,
**I want** collapsible material and order detail on the monitor,
**So that** I do not have to leave the run screen to check an order tolerance.

**Acceptance Criteria:**
- [ ] **`info-grid`** — the collapsible titled data grid, **two instances per monitor**: Rod/Spool Information and Order Information. Content is per-line; the accordion, table chrome and empty state are not. *(This component previously had no owner in any phase.)*
- [ ] Order Information carries customer, due date, gauge/width tolerance, setup width/gauge, finish, OD min–max and weights
- [ ] **`chart-tab-strip`** — the **section collapse toggle with `localStorage` persistence**, plus a single inert tab label that titles the section
- [ ] ⚠ **The collapse toggle has no requirement of its own** — `FR-112` covered only the tabs, which went with the Machine View descope. This is a pre-existing gap, now visible; either keep the strip as the collapse control or fold it into the shell, but record the choice

**Rate-card basis:** `info-grid` composite 12 h + `chart-tab-strip` primitive 8 h = 20 h (§2)
**Dependencies:** FW-133
**Blockers:** **OQ-18** *(which order field carries the coil min–max weight range — surfaced by this grid, blocks the FL2 variant in Phase 8)*

---

###### FW-081 · `gauge-trace-chart` live streaming, maximize and runtime source toggle
**Hours:** 4 h FE · 24 h RT · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE + RT

**As an** operator,
**I want** the gauge and width traces streaming live with weld markers,
**So that** I can react to drift before it produces out-of-spec material.

**Acceptance Criteria:**
- [ ] Streaming gauge + width (Chart.js) with target dashed line, tolerance band, green/red points and **vertical weld markers carrying the rod alpha**
- [ ] Consumes `gaugeReading$ / widthReading$ / speedFpm$ / payoffWeight$ / componentStatus$ / footageCounter$`; markers via `WeldJoinEvent / DieChangeEvent / PauseEvent / SPCCheckpoint / RodCheckoutEvent`
- [ ] Renders from the ring buffer under `requestAnimationFrame`, outside NgZone, on a fixed ~500-point window
- [ ] **Each panel maximizes to full screen** — backdrop, ESC and backdrop-click restore
- [ ] ⚠ **`isLive` is a runtime-switchable input, not mount-time.** The chart must switch between live streaming and a static historical profile **after mount, without remounting** — Phase 8 needs exactly this for FL2's Live/Profile control, and a hybrid FL3 run has both
- [ ] Last-window buffer survives a reconnect and re-join

**Rate-card basis:** FE maximize + runtime toggle 4 h + RT live wiring across 6 event streams 24 h = 28 h (§2)
**Dependencies:** FW-133, FW-135, FW-150
**Blockers:** —

---

###### FW-164 · `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService`
**Hours:** 12 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 5 · **Stream:** BE

**As a** client developer,
**I want** an active-run snapshot and a paged historical trace,
**So that** the monitor resumes correctly and FL2 can show a finished run's profile.

**Acceptance Criteria:**
- [ ] `RunController GET /run/active?line=` returns the active-run DTO (payoffs, weldEvents, components)
- [ ] `GET /run/{runId}/gaugetrace` returns the gauge-trace DTO (readings, weldMarkers, limits), paged by `from` / `to` / `resolution` via Dapper
- [ ] **The active-run DTO carries the Order Information fields** — customer, due date, tolerances, setup width/gauge, finish, OD min–max, weights — served in one round trip rather than a second call. These live in the **shared order/scheduling schema, cross-database**, on the same unenforced-link basis as the rod-alpha references
- [ ] Out-of-spec detection thresholds surfaced to the client as configuration
- [ ] Weld markers sourced from `WeldEvent`
- [ ] Any authenticated role may read

**Rate-card basis:** 2 query endpoints @ 4 h = 8 h + `RunQueryService` / Dapper paging 4 h = 12 h (§2)
**Dependencies:** FW-138, FW-141
**Blockers:** **OQ-18**

---

###### FW-165 · `sp_GetGaugeTrace`
**Hours:** 8 h DB · **Priority:** Medium · **Sprint:** S2 · **Phase:** 5 · **Stream:** DB

**As a** database owner,
**I want** the paged trace read served by a stored procedure,
**So that** a long run's trace query stays predictable under load.

**Acceptance Criteria:**
- [ ] `sp_GetGaugeTrace` created in `08_Programmability`, taking run, footage range and resolution
- [ ] Reads `RunReading`; supports decimation by resolution rather than returning every row
- [ ] Trace-query index support on run + footage present
- [ ] `GRANT EXECUTE` per FW-152's least-privilege model

**Rate-card basis:** stored proc / reporting view 8 h (§2)
**Dependencies:** FW-007
**Blockers:** **G9** *(`RunReading` retention policy undefined)*

---

**Phase 5 reconciliation** — FE `32+20+20+4 = 76` · BE 12 · DB 8 · RT 24 · base **120** → QA 22 → Cont 12 → **154 h** ✓ (§3b) *(QA/cont carried at published values — see the arithmetic note above)*

---

##### S2 · Phase 6 — In-Run Production Events

**Spec:** [`phase-06-in-run-production-events.md`](phases/phase-06-in-run-production-events.md) · **Owning specifications:** [`SPCCheckpoint.md`](../10-requirements/screens/SPCCheckpoint.md) (DB6) · [`DieChangeAndManagement.md`](../10-requirements/screens/DieChangeAndManagement.md) §1–3, §5 · [`WeldEvent.md`](../10-requirements/screens/WeldEvent.md) · [`RollAdjust.md`](../10-requirements/screens/RollAdjust.md) (DB11) · [`ActiveRunMonitor.md`](../10-requirements/screens/ActiveRunMonitor.md) §6 · **Owner:** FE + BE · **298 h** (FE 120 · BE 56 · DB 20 · RT 20 · QA 43 · cont. 39)

> **The largest workflow phase, and it has no routed screens at all.** Every event it owns is a **dialog** over the active-run monitor. Dashboards 4, 6 and 11 and the die-change screen are **launcher pages only** — `../50-frontend/mockups/dashboard_6_spc_checkpoint.html`, `dashboard_11_roll_adjust.html`, `dashboard_die_change.html` exist so filename references keep resolving. **Do not edit a launcher to change a screen — edit the `.js`.**
>
> **Never stack two dialogs.** Close the current one, then open the next; two live focus traps leave the operator unable to reach either.
>
> **There is no die inventory in MVP-1 and `D4` is enforced at die-SIZE level.** The three values the die-change dialog needs come from the **`Drawer` lookup seeded in Phase 1** (13 size rows, `LastGrindingFeet`, `TotalFeetAllowed`, 60/85 % bands). The incoming-die check therefore **rejects an unrecognised size, not an unregistered physical die**. **Accepted consequence: die life is per size — two dies of one diameter share a counter, and fitting a fresh die resets nothing.** This also removes the old "Phase 6 depends on Phase 13" risk (`OI-41`, `REVIEW.md` #34) — `Drawer` is a Phase-1 seed.

---

###### FW-063 · Weld capture — `fw-mark-welded-dialog`
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** FL1 operator,
**I want** to record the induction weld joining the running rod to the staged one,
**So that** output-coil footage can be attributed to the right source rod on a customer certificate.

**Acceptance Criteria:**
- [ ] Dialog raised from **Dashboard 2A's staged bay card**; outgoing alpha and weld footage auto-populated
- [ ] **Incoming rod defaults to the `Staged` rod on the idle bay** rather than free entry (`PCI008`), with scan-to-override still available
- [ ] **Induction only** — laser was dropped
- [ ] Quality Pass/Fail with a **reason mandatory on Fail** (six reasons); **neither result pre-selected**; confirm gated on *material match* **AND** *quality chosen* **AND** *(Pass OR reason selected)*
- [ ] Confirm links `Rout → Rin`; all later footage attributed to the incoming rod; weld marker on the trace; WELD-SOON/NOW alert cleared
- [ ] **Operator comes from the signed-in session** — no badge re-entry (`WLD003`)
- [ ] **No edit path** — reversing a recorded weld is `WLD011` and is unspecified
- [ ] Read-only **Welds this run** dialog over `GET /run/{runId}/weldevents`, **enabled at a count of 0** (the empty state is the answer), and **absent rather than disabled at cold start** when there is no active card

**Rate-card basis:** modal/dialog 12 h + quality-gate and weld-list uplift 8 h = 20 h (§2)
**Dependencies:** FW-N01, FW-166
**Blockers:** **OQ-6** · **G26** *(this de-stubs the Phase-4 screen)* · **G27** *(the weld screen's re-sequenceable rod queue and traceability chain lost their host when DB4 was retired)* · **G28** ✅ *(**RESOLVED 3 Sep 2026** — FL2 never welds; flattened material cannot be welded at UA. **No FL2 weld entry point is to be built** — an FL2 coil inherits its spool's markers. Removed from `FW-063`'s `blocked_by`. `ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`)* · **OI-59 / Q6** *(a fail-then-remake writes several `WeldEvent` rows for one physical join; whether a superseded attempt reaches the certificate is undecided)*

---

###### FW-073 · Die change dialog
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** FL1 operator,
**I want** to record a mid-run die change and be forced into an SPC check when the reason demands it,
**So that** a gauge-affecting change is always verified before the run continues.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../50-frontend/mockups/die_change.js` — `openDieChange(ctx)`, CSS scoped under `.fwdc`, all ids prefixed
- [ ] Select DB1 / DB2 / Both; scan or key the incoming die
- [ ] **Incoming size validated against the `Drawer` 13-row size catalogue** — an unrecognised **size** is rejected. This is application-level validation; `DieChangeEvent` stores `OldDieSizeIn` / `NewDieSizeIn` as decimals with **no `DrawerId` FK**
- [ ] Die life read from `Drawer.LastGrindingFeet` / `TotalFeetAllowed` with the **60 / 85 % bands**
- [ ] Reason: Planned / Gauge drift / Die failure / Size change / Other
- [ ] **Reason = Gauge drift or Size change → opens the SPC checkpoint dialog as a hard gate**, run paused until SPC passes. Close this dialog first, then open SPC
- [ ] Die failure → optional QA hold on the footage range
- [ ] **Suppressed on FL2** — FL2 has no drawing dies
- [ ] Confirm writes the die-change event **plus a linked override**

**Rate-card basis:** modal/dialog 12 h + catalogue validation, life bands and the SPC hand-off 12 h = 24 h (§2)
**Dependencies:** FW-005 *(`Drawer` seed)*, FW-065, FW-167
**Blockers:** **OI-12** *(conflicting die-life bands — **dormant, not answered**; only the 60/85 % Die Change bands apply in MVP-1)* · die-life threshold configurability

---

###### FW-065 · SPC checkpoint dialog
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** operator,
**I want** to record a measurement against tolerance and be routed correctly when it fails,
**So that** out-of-spec material is suspended rather than shipped.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../50-frontend/mockups/spc_checkpoint.js` — `openSpcCheckpoint(ctx)`, CSS scoped under `.fwspc`
- [ ] Checkpoint types: **Pre-Run · Post DB1 · Post Die Change · Manual Spot Check · Post-Run**; measurements vary by type
- [ ] **Marker maths:** `pct = 50 + ((measured − target) / (tol × 1.67)) × 50`, **clamped 4–96 %**
- [ ] **Submit · Continue** when in spec; **Submit · Suspend material** when out of spec → **opens the WIP rejection dialog with the failing reading carried over**, coil to `SPC-HOLD`
- [ ] **Read-only mode** — Dashboard 1's "SPC · Last check … · View →" reviews a recorded checkpoint; it must not open a blank form
- [ ] Opens pre-loaded with the die change as its trigger when raised from FW-073

**Rate-card basis:** modal/dialog 12 h + five checkpoint types, marker maths and read-only mode 12 h = 24 h (§2)
**Dependencies:** FW-133 *(`tolerance-viz`)*, FW-067, FW-168
**Blockers:** **OI-57** *(tolerance bands)*

---

###### FW-070 · Roll adjust dialog
**Hours:** 28 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** FL2 or FL3 operator,
**I want** to correct roll gaps mid-run without editing the pass schedule,
**So that** drift is corrected at run level and the schedule stays the record of intent.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../50-frontend/mockups/roll_adjust.js` — **replaces the route component `dashboard-11-roll-adjust`**
- [ ] **Caller supplies the context:** `line`, `orderNo`, `alpha` + `alphaLabel` (*Spool* on FL2, *Rod* on FL3), `runId`, `passSchedule`, `footage` **read at open time**, `targets`, `measurements`, and — the load-bearing one — **`rolls`, the stand set the operator can reach**. FL2 and FL3 **do not share a stand set**, which is exactly why this could not stay a page: as a page it hard-coded FL2's
- [ ] Per-roller Scheduled / Current / New / Delta table, bypassed stands greyed
- [ ] Measured gauge **and** width required
- [ ] **A reason is required — Apply stays disabled until one is picked**
- [ ] **All-zero deltas relabel the action "No changes — return to run" and write nothing**
- [ ] Apply writes a **run-level override** (never the schedule) + PLC tag write + an SPC log at footage
- [ ] `onConfirm` returns adjustments, reason, notes and the frozen footage
- [ ] **FL2 + FL3 only, not FL1** (`FR-107`/`108`/`109`). *Note: `FlatWireShopfloorDashboards.md` and `../90-registers/Gaps.md` state this three contradictory ways and are stale;* `RollAdjust.md` *§1.5 is the owning spec*
- [ ] **Vocabulary:** roll **gap** (the setting, ~0.016″) and product **gauge** (what the strip measures, ~0.110″) are different quantities — the dialog opens over a live gauge trace, so conflating them is visible on screen

**Rate-card basis:** modal/dialog 12 h + caller-supplied stand set, delta table and PLC write 16 h = 28 h (§2)
**Dependencies:** FW-062, FW-169
**Blockers:** **OI-103** *(no bound on a roll-gap change, which is written straight to the machine)* · **OQ-62** *(override authority — decided)*

---

###### FW-071 · Pause and Resume dialogs
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

**As an** operator,
**I want** to pause the run against a categorised reason and choose what happens on resume,
**So that** downtime is attributable and every off-ramp is reachable from one place.

**Acceptance Criteria:**
- [ ] Built from `../50-frontend/mockups/pause_run.js`; expects `pause-btn`, `pause-timer-badge`, `pause-elapsed` and `.line-badge` on the host, and **falls back to the host's own `fwRunCtx()`** so argument-less `onclick="openPauseDialog()"` handlers keep reading live footage
- [ ] **Icon badge + title + purpose line**, a **context chip row** (status · order · alpha · footage · pause start) whose footage and clock **tick live and freeze on confirm**, then **15 reasons as icon tiles in five category columns** with `Other` at the foot of the Equipment column, and a notes row with a 500-char counter
- [ ] **Payload carries `ReasonCode` + `ReasonCategory`, not a label.** `Other` keeps its code and puts the prose in `notes`; notes are **required** in that case per `CK_RunPauseEvent_NotesOther`
- [ ] Confirm → timer paused, footage frozen, PLC idle, Dashboard 1 → PAUSED
- [ ] **Four resume outcomes** (`OI-14` closed): `ResumeRun` / `LogWipRejection` / `CheckOutRod` / `ContinuePause`
- [ ] **Rod Checkout is not a pause reason** — it is the fourth resume outcome, superseding `FR-262`
- [ ] Reasons that lead somewhere show a route line before the operator commits: *Die change* → opens die change (**suppressed on FL2**), *Manual SPC measurement* → opens SPC, **`RollAdjustment` → opens roll adjust** carrying the frozen footage
- [ ] Each hand-off **closes the pause dialog first, then opens the next** — never both at once
- [ ] Type set at the repo's **14px** floor, not the reference design's 10–13px

**Rate-card basis:** 2 × modal/dialog @ 12 h = 24 h (§2)
**Dependencies:** FW-062, FW-170; the resume dialog depends on **FW-067** and **FW-072** (Phase 7) for two of its four outcomes
**Blockers:** —

---

###### FW-166 · `POST /weldevent` and `WeldService`
**Hours:** 12 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** one endpoint that writes every weld,
**So that** both weld entry points compose the same row.

**Acceptance Criteria:**
- [ ] `WeldEventController POST /weldevent`; `RecordWeldEvent` handler; `WeldService` advances the active-rod pointer and clears weld-pending
- [ ] **This is the single weld write** — `POST /staging/rod/mark-welded` was retired 1 Aug 2026
- [ ] **The `RodStaging` write is conditional on quality:** a **Pass** sets `IsWelded` / `WeldedAt` / `WeldedBy` in the same transaction; a **Fail** writes the `WeldEvent` row and **leaves the rod staged and un-welded** so the operator remakes the weld
- [ ] **Broadcast `PayoffStateChanged` on Pass only**
- [ ] Quality is **not** mirrored onto `RodStaging` — one join, one quality answer
- [ ] **No uniqueness constraint on the rod pair, and none should exist** — a fail-then-remake legitimately writes several rows
- [ ] `GET /run/{runId}/weldevents` returns every weld against the active run

**Rate-card basis:** command endpoint 6 h + `WeldService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-171
**Blockers:** **G26** · **OI-59 / Q6** *(footage attribution across the two boundaries)*

---

###### FW-167 · `POST /diechange` and `DieChangeService`
**Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** a die change to create its own override and demand its SPC check,
**So that** the gate cannot be skipped by going straight to the endpoint.

**Acceptance Criteria:**
- [ ] `DieChangeController POST /diechange`; `RecordDieChange` handler
- [ ] `DieChangeService` **auto-creates the linked override** (`DieChangeEvent.LinkedOverrideId → RollOverride.OverrideId`) and sets `spcCheckpointRequired`
- [ ] **Die-change → PostDieChange SPC gate is a hard block until it passes** (thread mode allowed); `OQ-65` decided
- [ ] Incoming size validated against `Drawer`; unrecognised size → `422`
- [ ] `Require SPC on resume` toggle-off is **Ops-Manager / Quality only** and writes a logged exception

**Rate-card basis:** command endpoint 6 h + `DieChangeService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-171, FW-169
**Blockers:** —

---

###### FW-168 · `POST /spc` and `SpcService`
**Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** the spec calculation and hold behaviour on the server,
**So that** an in-spec verdict cannot be produced by the client.

**Acceptance Criteria:**
- [ ] `SpcController POST /spc`; `SubmitSpcCheckpoint` handler
- [ ] `SpcService` computes in/out of spec and sets coil `SPC-HOLD` on suspend
- [ ] Measurements accepted per checkpoint type; **`CheckpointType` accepts all five values including `RollAdjustTrigger`**
- [ ] Writes `SpcCheckpoint` + `SpcMeasurement`; auto-links to the die change when raised from one
- [ ] All events audited

**Rate-card basis:** command endpoint 6 h + `SpcService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-147, FW-171
**Blockers:** —

---

###### FW-169 · `POST /rolloverride` and `RollOverrideService`
**Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** an override written at run level with its PLC write and SPC log,
**So that** correcting drift never mutates the approved schedule.

**Acceptance Criteria:**
- [ ] `RollAdjustController POST /rolloverride`; `RecordRollOverride` handler
- [ ] `RollOverrideService` writes the override, performs the **per-roll `PLCTagService` write**, and logs an `SpcCheckpoint` of type **`RollAdjustTrigger`** at footage
- [ ] **The override never edits `PassSchedule`**
- [ ] **All deltas zero → no write**, matching the dialog's short circuit
- [ ] Response carries adjustments, delta, `plcTagWritten` and `spcCheckpointId`
- [ ] **Reverting an override is Ops-Manager only** (`FR-212`)

**Rate-card basis:** command endpoint 6 h + `RollOverrideService` 6 h = 12 h (§2)
**Dependencies:** FW-139, FW-151, FW-171
**Blockers:** **OI-103** · **OQ-62** *(decided)*

> **This subsumes the MVP-1 half of `FW-014`** (pass-schedule override logging). `FW-014`'s **sink**, `PassScheduleChangeLog`, is an **MVP-2 table** — so MVP-1 has an override path with nowhere to log the schedule-level record. The run-level `RollOverride` row **is** written. See [Appendix B](#appendix-b--id-provenance).

---

###### FW-170 · `POST /run/{id}/pause` and `/resume`, and `RunControlService`
**Hours:** 8 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

**As a** developer,
**I want** pause and resume to drive the PLC and the run clock together,
**So that** a paused line is genuinely idle and its downtime is measurable.

**Acceptance Criteria:**
- [ ] `RunController POST /run/{id}/pause` and `POST /run/{id}/resume`; `PauseRun` and `ResumeRun` handlers
- [ ] `RunControlService` pauses/restores the run clock and drives **PLC idle / restore**
- [ ] Pause requires a reason; payload carries `ReasonCategory` + `ReasonCode` and, for `Other`, mandatory notes
- [ ] Resume accepts one of the **four** outcomes and returns the pause duration
- [ ] Writes `RunPauseEvent`

**Rate-card basis:** 2 command endpoints, priced as one service pair (8 h, §2)
**Dependencies:** FW-139, FW-171
**Blockers:** —

---

###### FW-171 · The five in-run event tables
**Hours:** 20 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** DB

**As a** developer,
**I want** every in-run event persisted against run and footage,
**So that** the trace, the reports and the certificate all read from one record.

**Acceptance Criteria:**
- [ ] Write paths live for `WeldEvent`, `DieChangeEvent` (+ `LinkedOverrideId`), `SpcCheckpoint` + `SpcMeasurement`, `RollOverride`, `RunPauseEvent`
- [ ] `(RunId)` index present on every event table
- [ ] All hang off `FlatWireRun.RunId`; SPC auto-links to its die change
- [ ] Reads wired for `Drawer` (size, `LastGrindingFeet`, `TotalFeetAllowed`) and the pass-schedule components **across the external boundary** for scheduled gaps
- [ ] Constraints from FW-007 verified live: notes-on-`Other`, fail-reason-on-`Fail`

**Rate-card basis:** 5 tables @ 4 h = 20 h (§2)
**Dependencies:** FW-007
**Blockers:** **G34** *(wire break has a decided flow and no persistence target — `FR-280`–`282`, `FW-N08`)* · **G35** *(FM2's two dancers unmodelled)*

---

###### FW-172 · Run-event markers and the `LineStatus` transitions
**Hours:** 20 h RT · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** RT

**As an** operator,
**I want** every event I record to appear on the trace immediately,
**So that** the screen and the record never disagree.

**Acceptance Criteria:**
- [ ] Markers published to the DB3 traces: `WeldJoinEvent`, `DieChangeEvent`, `SPCCheckpoint`, `PauseEvent`
- [ ] `LineStatus` transitions RUNNING ↔ PAUSED, reaching Dashboard 1
- [ ] `PayoffWeight` re-established after a weld; `ComponentStatus` re-broadcast after a roll override
- [ ] All are **rare domain events — immediate and unbatched**
- [ ] Standard reconnect and group re-join apply

**Rate-card basis:** 4 marker events @ 4 h = 16 h + `LineStatus`/`ComponentStatus` wiring 4 h = 20 h (§2)
**Dependencies:** FW-149, FW-081
**Blockers:** —

---

**Phase 6 reconciliation** — FE `20+24+24+28+24 = 120` · BE `12+12+12+12+8 = 56` · DB 20 · RT 20 · base **216** → QA `0.20 × 216 = 43` → Cont `0.15 × (216+43) = 39` → **298 h** ✓ (§3b)

---

##### S2 · Phase 7 — Exception Handling: WIP Rejection & Rod Checkout

**Spec:** [`phase-07-wip-rejection-rod-checkout.md`](phases/phase-07-wip-rejection-rod-checkout.md) · **Owning specifications:** [`WipRejection.md`](../10-requirements/screens/WipRejection.md) (DB8) · [`RodCheckout.md`](../10-requirements/screens/RodCheckout.md) (DB12) · **Owner:** FE + BE · **205 h** (FE 64 · BE 40 · DB 28 · RT 16 · QA 30 · cont. 27)

> **Three checkout modes, and they are genuinely different transactions.** **Mode P** — pre-check-out from DB2A; the rod was never checked in, so there is **no acknowledgement to void, no PLC tags to clear and no line-state gate** (an idle bay is not running). **Mode A** — footage = 0. **Mode B** — footage > 0, reachable **only** through Pause.

---

###### FW-067 · WIP rejection dialog
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** FE

**As an** operator,
**I want** to flag suspect material with its context already filled in,
**So that** a hold is recorded in seconds and the supervisor is alerted.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../50-frontend/mockups/wip_rejection.js` — `openWipRejection(ctx)`, CSS scoped under `.fwwip`
- [ ] **Raised from five places**, each supplying its own material context: the active-run monitors, the pre-check-in station (failed staging inspection), the SPC checkpoint (*suspend material*), the resume dialog, and the More Options tile. **Nothing navigates to it**
- [ ] **Context contract:** `materialAlpha`, `stage`, `runId`, `footagePosition`, `trigger`, and on the staging path `payoff`
- [ ] **On the pre-check-in path `runId` and `footagePosition` are both `null`** — the rod never ran
- [ ] Context auto-populated (alpha, stage, footage, time); group → reason dropdowns; details (measured / target / deviation)
- [ ] Disposition **Suspend (→ HOLD)** / **Scrap (→ SCRAP)** / **Rework (→ return stage)**; **observation required for Suspend**
- [ ] Submit → status set, WIP-Held queue entry, `AlertRaised` to Dashboard 1

**Rate-card basis:** modal/dialog 12 h + five call sites and the context contract 8 h = 20 h (§2)
**Dependencies:** FW-134, FW-174
**Blockers:** **OI-84** *(WIP reason list — with Shannon R.)* · **OI-100** *(valid rework stages)*

---

###### FW-072 · Rod checkout dialog — Modes A, B and P
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** FE

**As an** operator,
**I want** to remove a rod with the right disposition for how far it got,
**So that** material is never left as ghost inventory.

**Acceptance Criteria:**
- [ ] Built as a `MatDialog` from `../50-frontend/mockups/rod_checkout.js` — **mode is an input the caller states**, not something the screen configures itself with
- [ ] **Mode A** (footage = 0), opened from the check-in station: reason (Wrong rod / Order cancelled / Failed re-inspection / Relocated / Other); disposition Return-to-floor (→ STAGED) / Return-to-warehouse (→ RECEIVED); Confirm → acknowledgement voided, `ClearPayoffTags`, line IDLE. **Carries no footage and no in-process material disposition** — the run never started
- [ ] **Mode B** (footage > 0), opened **only** from the pause dialog's `CheckOutRod` outcome with the frozen footage carried over: line-state guard blocks if Running; rod disposition Hold/Scrap/Defer **and** in-process material disposition Hold/Scrap/Accept-partial; → **PENDING DISPOSITION**, material locked with **no alpha**, SignalR to Supervisor
- [ ] Supervisor Accept (→ partial spool alpha, spool queue) / Hold (→ alpha Hold, QC release) / Reject (→ WIP rejection → scrap)
- [ ] **Mode P**, opened from DB2A: reason; disposition Return-to-floor / Return-to-warehouse; Confirm → `RodStaging.Status='Unstaged'`, `RodCheckout` row with `Mode='ModeP'`, the staging WIP queue entry **reversed**, `PayoffStateChanged → NotStaged`
- [ ] **A welded rod on Mode P requires a supervisor override** with a documented reason and goes to **`HOLD`** — removal means cutting the material. Recorded with `WasWelded=1` and the approval stamp
- [ ] Uses `option-card` / `consequence-box` / `footer-stamp` idioms

**Rate-card basis:** modal/dialog 12 h + three modes and the supervisor path 12 h = 24 h (§2)
**Dependencies:** FW-134, FW-174, FW-071
**Blockers:** **OQ-13** *(PLC on checkout — in progress)* · **OI-38** *(PIN validation source undecided)* · **G24**

---

###### FW-173 · Partial rod re-check-in (carry-forward)
**Hours:** 20 h FE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 7 · **Stream:** FE

**As an** operator,
**I want** a part-run rod forced onto the carry-forward path,
**So that** its remaining footage is never mistaken for a fresh rod.

**Acceptance Criteria:**
- [ ] `partial-recheckin` — **the only routed screen in this phase**
- [ ] **The gate fires at the Dashboard 2A staging scan**, where the rod is first identified, so a partial rod is caught before it is ever mounted
- [ ] Scanning a rod with `footage_run_to_date > 0` forces carry-forward; supervisor sign-off required; opens a new run at 0 ft
- [ ] **The fresh-start control is absent from the DOM, not merely disabled** (`PRC008`)
- [ ] `RodStaging.FootageRunToDateAtStaging` records the evidence; `POST /staging/rod` rejects `422` without `acknowledgedCarryForward` (`PRC007`)
- [ ] Each segment gets its own spool alpha carrying `source_rod_alpha`

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-158, FW-176
**Blockers:** **OQ-12** *(carry-forward design — in progress; still open whether a payoff-side scale exists)* · **G14** *(the design doc's worked examples use non-canonical `ROD-`/`SPL-` alphas)*

---

###### FW-174 · `POST /wipreject`, `POST /checkout` and their services
**Hours:** 24 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** BE

**As a** developer,
**I want** both off-ramps written server-side with their status transitions,
**So that** disposition and material status can never disagree.

**Acceptance Criteria:**
- [ ] `WipRejectionController POST /wipreject` → status + `alertBroadcast`; `SubmitWipRejection` handler; `WipRejectionService` sets status, adds the WIP-Held entry and raises the alert
- [ ] `CheckOutController POST /checkout` (mode / footage / reason / rodDisposition / materialDisposition / remainingWeight) → `newRodStatus` / `plcTagsCleared` / `partialSpoolAlpha`; `CheckOutRod` handler; `CheckOutService` voids the acknowledgement, calls `ClearPayoffTags`, creates PENDING DISPOSITION and notifies the supervisor
- [ ] **A WIP rejection on the staging path also releases the bay** — sets `RodStaging.Status='Unstaged'`, `UnstageKind='WipRejection'`, `WipRejectionId`, and broadcasts `PayoffStateChanged{NotStaged}`. **Nothing else clears a `BLOCKED` bay**
- [ ] **Mode B supervisor approval enforced by constraint** — this is a behaviour change for any code that wrote a Mode B checkout without one
- [ ] Line-state gate before tag clear; partial spool alpha only on Accept
- [ ] Operators flag, supervisors dispose; all audited

**Rate-card basis:** 2 command endpoints @ 6 h = 12 h + 2 services @ 6 h = 12 h → 24 h (§2)
**Dependencies:** FW-139, FW-176, FW-151
**Blockers:** **OQ-13** · **OQ-23**

---

###### FW-175 · Durable supervisor pending-approval queue
**Hours:** 16 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** BE

**As a** supervisor,
**I want** a pending disposition to survive my terminal disconnecting,
**So that** locked material is never stranded because a notification was missed.

**Acceptance Criteria:**
- [ ] Pending dispositions persisted to a durable queue, **not** carried only by a transient SignalR notification
- [ ] A supervisor connecting after the event still sees the pending item
- [ ] Items are claimable, and a claim is recorded with the supervisor id
- [ ] Resolution (Accept / Hold / Reject) closes the queue entry and writes the approval stamp

**Rate-card basis:** non-trivial business service 16 h — the discrete **G7** line item named in this phase's scope call (§2)
**Dependencies:** FW-174
**Blockers:** ⚠ **G7 — mid-run checkout supervisor approval currently relies only on transient SignalR.** This story is the fix; without it the approval path has no durability

---

###### FW-176 · `WipRejection` / `RodCheckout` tables and the shared `coils` carry-forward columns
**Hours:** 28 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** DB

**As a** developer,
**I want** carry-forward state on the rod record itself,
**So that** a part-run rod is identifiable at any station, not only inside one run.

**Acceptance Criteria:**
- [ ] `WipRejection` write path live with **nullable `RunId`** (the pre-check-in path has none); index `WipRejection(RunId)`
- [ ] `RodCheckout` write path live for Modes P / A / B with `PartialSpoolAlpha` and both dispositions; `CK_RodCheckout_ModeP` and `CK_RodCheckout_ModeB` enforce the per-mode field rules **in the database rather than in prose**; index `RodCheckout(RunId)`
- [ ] ~~⚠ **New columns on the shared `coils` table** — `footage_run_to_date`, `remaining_weight_estimate` — plus `source_rod_alpha` on `SpoolProcessing`. **This is a second shared-schema change after FW-001 and needs its own impact audit**~~ — **CANCELLED 18 Aug 2026, `D-32`.** ⚠ **This was the plan's *second* shared-schema change and is easy to miss when reading `D-32` as being only about `FW-001`.** It is cancelled on the same ground, and cancelling it costs nothing: the bullet below records that the **delivered** design is already `FlatWireDB`-local
- [ ] The delivered design is `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb` and `SpoolProcessing.SourceRodAlpha` — **all three `FlatWireDB`-local, all three already in the DDL since 26 Jul 2026**; the snake_case names in the May 2026 design doc are **proposals, not the schema**, and after `D-32` they are proposals against a table this module no longer alters
- [ ] Status transitions wired on the `coils` rod row, `SpoolProcessing.Status` and `CoilOutput.Status`
- [ ] Polymorphic `WipRejection.MaterialAlpha` (rod or spool, **no FK**) and `RodCheckout.PartialSpoolAlpha` (**no FK**) documented as such

**Rate-card basis:** 2 tables @ 4 h = 8 h + ~~shared-schema columns 16 h *(named in the scope call)*~~ **cancelled, `D-32`** + indexes 4 h = **12 h** (§2, previously 28 h)
> ⚠ **The 16 h priced the shared `coils` columns and their impact audit, and it falls to zero rather than shrinking** — the local columns that replace them (`Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb`, `SpoolProcessing.SourceRodAlpha`) were **delivered in the DDL on 26 Jul 2026**, so there is no residual schema work hiding inside the removed line. **If wiring the carry-forward write paths needs time of its own it must be re-priced as a new line, not assumed to have been inside this one.**
**Dependencies:** FW-007, ~~FW-001~~ *(cancelled)*
**Blockers:** **G24** *(the approval columns exist now; PIN source is `OI-38`)* · **G21 / OQ-23**

---

###### FW-177 · Exception broadcasts and the supervisor notification
**Hours:** 16 h RT · **Priority:** Medium · **Sprint:** S2 · **Phase:** 7 · **Stream:** RT

**As a** supervisor,
**I want** holds and checkouts to reach the board and my terminal immediately,
**So that** I can act on locked material without being told verbally.

**Acceptance Criteria:**
- [ ] `AlertRaised` (WIP hold) → Dashboard 1
- [ ] **`RodCheckoutEvent` marker renders on the Dashboard 3 traces** as a run event *(DB14 was the previously-listed consumer and was descoped; DB3 is now named explicitly so the event is not left without one)*
- [ ] SignalR notification to the **Supervisor role** for a pending disposition, backed by FW-175's durable queue
- [ ] `LineStatus` → IDLE on checkout

**Rate-card basis:** 2 × hub event @ 8 h = 16 h (§2)
**Dependencies:** FW-149, FW-175
**Blockers:** **G7**

---

**Phase 7 reconciliation** — FE `20+24+20 = 64` · BE `24+16 = 40` · DB 12 · RT 16 · base **132** → QA `0.20 × 132 = 26` → Cont `0.15 × (132+26) = 24` → **182 h**

> ⚠ **Re-derived 18 Aug 2026 — `D-32`.** Previously FE 64 · BE 40 · **DB 28** · RT 16 · base **148** → QA 30 → Cont 27 → **205 h** ✓ (§3b). `FW-176`'s **16 h shared-`coils` column line is cancelled** — the plan's second shared-schema change — taking DB from 28 to 12. **205 → 182 h, −23 h all-in.**

---

##### S2–S3 · Phase 8 — FL2 Spool Check-In & Finishing Run

**Spec:** [`phase-08-fl2-spool-checkin-finishing-run.md`](phases/phase-08-fl2-spool-checkin-finishing-run.md) · **Owning specifications:** [`SpoolQueue.md`](../10-requirements/screens/SpoolQueue.md) (DB5A) · [`RocCheckin.md`](../10-requirements/screens/RocCheckin.md) §4.3 (DB5) · [`SpoolCompletionNotification.md`](../10-requirements/screens/SpoolCompletionNotification.md) · **Owner:** FE + BE · **118 h** (FE 48 · BE 18 · DB 12 · RT 8 · QA 17 · cont. 15)

> **This phase spans the sprint boundary: 59 h in S2, 59 h in S3**, matching the capacity model's even W5/W6 split. Story bodies are listed once, here.
>
> **⚠ The 118 h estimate predates Dashboard 5A** (added 2 Aug 2026) **and the DB3-FL2 re-mock. Re-estimate before committing.** DB5A is genuinely small — read-only, one endpoint, one table, no PLC, no state change — but it is not free.
>
> **FM2 has three stands: `S1` (8″) · `S2` (6″) + edger · `S3` (6″) + edger, final and non-bypassable.** The 8″ roller **is** S1. **A fourth FM2 row is a regression** (`D-26`).

---

###### FW-124 · Dashboard 5A — FL2 Spool Queue
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** FE

**As an** FL2 operator,
**I want** to see every spool available to run without scanning anything,
**So that** I know what material is waiting instead of guessing.

**Acceptance Criteria:**
- [ ] `dashboard-5a-spool-queue` at route `/flat-wire/line/FL2/spools`, built from `../50-frontend/mockups/dashboard_5a_spool_queue.html`
- [ ] Structure: header · scan panel · context bar · list · footer, on the DB2A layout contract — definite `height: 1024px`, the list the only flexing child, `min-height: 0` on it and its table wrapper, **sticky on `th` not `thead`**
- [ ] **Two modes over one table, and the column set never changes between them** — a table that gains and loses columns as you scan reads as two tables and costs the operator their place. The `Order` column stays in both; alloy and temper get **no** columns because they are order-level and live in the context bar
- [ ] **All four scan outcomes are one response, not extra requests:** resolved order · **`404` unknown alpha (field marked, list unchanged)** · `200` with a null order and a single row for an **unallocated** spool (a real case — planning remainders and supervisor-accepted partials) · `200` with `eligible:false` for a spool that cannot run, **whose siblings still list**
- [ ] Check-in offered only for `RECEIVED` / `STAGED` spools, and leads to DB5
- [ ] **Read-only — it writes nothing**
- [ ] **Deliberately absent:** age (no `CreatedAt` on `SpoolProcessing`), location (`SpoolProcessing.Location` has no writer and no scheme), and any filter/sort furniture (the list is already limited to runnable material and the scan is the real filter)
- [ ] Covered by `TC-119`–`TC-126`

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-179
**Blockers:** **OQ-17** *(spool state machine — "available for processing" has no defined meaning without it)* · **OI-06** *(two unmapped spool status vocabularies)* · **OI-02** *(`SP-#####` vs `TS######`)* · ⚠ **confirmation that `SpoolProcessing.OrderNo` is populated from planning — if allocation is not readable by the shopfloor system, `FR-098` has nothing to resolve and this screen is invalid**

---

###### FW-064 · Dashboard 5 — FL2 Spool Check-in
**Hours:** 16 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** FE

**As an** FL2 operator,
**I want** to check in a spool and see its FL1 history before I run it,
**So that** I know what I am finishing.

**Acceptance Criteria:**
- [ ] `dashboard-5-spool-checkin` from `../50-frontend/mockups/dashboard_5_spool_checkin.html`
- [ ] Scan spool alpha; **source rods auto-populate from FL1 run traceability**; alloy/temper read-only; operator enters measured gauge/width and weights
- [ ] **Historical gauge profile** from the FL1 run with target, tolerance band and weld markers, plus a verdict badge — "✓ all in spec" or "⚠ N out of spec"
- [ ] FL2 pass-schedule table read-only, showing **exactly three stands** — `S1` (8″), `S2` (6″) + edger, `S3` (6″) + edger, final
- [ ] **No visual inspection** — done at FL1
- [ ] Acknowledge → push FL2 PLC tags → spool `INFLAT` → Dashboard 3 FL2 variant
- [ ] Reuses `pass-schedule-table` and `confirm-bar` from FW-133

**Rate-card basis:** new dashboard 24 h, discounted to 16 h — the schedule table, confirm-bar and trace chart are all reused (§2)
**Dependencies:** FW-133, FW-124, FW-179, FW-081
**Blockers:** **OQ-76** *(spool identifier)* · **OQ-15** *(hybrid-origin validation — must not apply a standalone FL2 schedule to hybrid material)*

---

###### FW-178 · Dashboard 3 FL2 variant configuration
**Hours:** 8 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 8 · **Stream:** FE

**As an** FL2 operator,
**I want** the run monitor to show spool-in and coil-out rather than payoffs,
**So that** the screen matches what my line actually does.

**Acceptance Criteria:**
- [ ] **Configures Phase 5's shell — does not reimplement it.** The differences are enumerable and are configuration, not a fork:
  - Middle status card → **Material flow** (spool in: alpha, source rods, load time, consumption bar, lb remaining/consumed · coil out: output alpha, take-up, fill bar, lb, ft/ft target, skid + coil-of-N badge)
  - Info grid subject → **Spool Information** (+ a width column FL1's omits, because material arriving here is already flattened)
  - Order Information → `Max Wgt of Spool` replaced by **`Coil Min–Max Wgt`**, the completion basis
  - Trace source → **Live / Profile toggle**, **Profile authoritative**
  - Action clusters → **no Die Change, no Weld**; **SPC Checkpoint is present** (FM2's S3 output is a specified checkpoint site)
- [ ] Components card shows **exactly three** FM2 rows with edgers on S2 and S3 only, and **no separate "8″ Roller" row**
- [ ] Check Out Rod disabled on a running line; **Complete Coil** is the only true navigation left
- [ ] Raises `fw-spc-checkpoint-dialog`, `fw-wip-rejection-dialog`, `fw-pause-dialog`/`fw-resume-dialog` and **`fw-roll-adjust-dialog`** (Phase 6), supplying **FL2's stand set**

**Rate-card basis:** screen variant of an existing screen 8 h (§2)
**Dependencies:** FW-062, FW-162, FW-163, FW-070
**Blockers:** **OQ-18** *(which order field carries the coil min–max weight range)*

---

###### FW-179 · `POST /checkin/spool` and `GET /spools`
**Hours:** 18 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** BE

**As a** client developer,
**I want** one spool endpoint serving both queue modes,
**So that** a scan resolves the order in a single call.

**Acceptance Criteria:**
- [ ] `CheckInController POST /checkin/spool`; `CheckInSpoolCommand` (spoolAlpha, measured gauge/width, weights, passScheduleId) → run response
- [ ] **`SpoolController GET /spools[?spoolAlpha=]` — one endpoint, two modes, identical response shape `{ order, spools[] }`.** Without the parameter it returns everything available for processing with a null order; with it, **the backend resolves the order** and returns it plus that order's spools in the same response
- [ ] **`404` only for an unknown alpha. An unallocated spool is a `200` with a null order** — conflating the two is the mistake to avoid
- [ ] DTO joins `CoilTraceability` / `WeldEvent` for source rods, the FL1 run for gauge/width, and the **shared order schema cross-database** for the order block
- [ ] `CheckInService` spool path pushes **FL2 tags only** — `S1`/`S2`/`S3` roll gaps and stand states plus edgers at S2/S3. **No DB or FM1 tags**
- [ ] Hybrid-origin validation guard
- [ ] Operator+ authorization

**Rate-card basis:** command endpoint 6 h + query endpoint 4 h + `CheckInService` spool path 8 h = 18 h (§2)
**Dependencies:** FW-139, FW-151, FW-180
**Blockers:** **OQ-15** · **OQ-17**

---

###### FW-180 · `SpoolCheckin` table and the `SpoolProcessing.OrderNo` index
**Hours:** 12 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** DB

**As a** database owner,
**I want** the spool queue's filter covered by an index,
**So that** a `WHERE OrderNo =` on a `VARCHAR(50)` does not scan.

**Acceptance Criteria:**
- [ ] `SpoolCheckin` write path live, `LineId` restricted to FL2/FL3
- [ ] `FlatWireRun` FL2 run header created on check-in; `SpoolProcessing.Status = INFLAT`
- [ ] **New index on `SpoolProcessing.OrderNo`** — unindexed today. It also fixes DB5's scan, which validates against nothing
- [ ] Reads wired: source FL1 run gauge trace + `WeldEvent` markers, `SpoolProcessing.SourceRunId` / `ParentRodAlpha`
- [ ] `SpoolProcessing.ParentRodAlpha` documented as a **logical link to the rod's `coils` row**, not an FK to a local table

**Rate-card basis:** 2 tables/indexes @ 4 h = 8 h + FL2 run header wiring 4 h = 12 h (§2)
**Dependencies:** FW-007
**Blockers:** **OI-25** *(the two footage coordinate systems — `CoilOutput` accumulation vs `CoilTraceability`'s coil-local footage — are unreconciled)*

---

###### FW-181 · FL2 null-gauge contract and the Live/Profile binding
**Hours:** 4 h RT · **Priority:** High · **Sprint:** S3 · **Phase:** 8 · **Stream:** RT

**As an** FL2 operator,
**I want** the Live view to say plainly that there is no live gauge,
**So that** I never read a drawn line as a real measurement.

**Acceptance Criteria:**
- [ ] FL2 standalone broadcasts **`null`** for live gauge/width while still emitting `SpeedFPM`, `PayoffWeight`, `LineStatus`, `FootageCounter`, `ComponentStatus` — **this contract is unchanged**
- [ ] ⚠ **Live renders an explicit empty state when the field is `null`** — *"No live gauge on FL2 · see Profile"* — and **must not draw a flat line at target**, which would read as a real in-spec measurement. *(The mockup animates a simulated trace because a static prototype has no hub; the built screen must not.)*
- [ ] **Profile is the value of record on FL2 standalone** — the incoming spool's FL1 history on a **footage** x-axis, with weld markers and a whole-length verdict badge. **Static: it must not be re-rendered or re-sampled by the live tick**
- [ ] **Profile is the honest default** on FL2 standalone
- [ ] **The toggle's availability binds to line mode, not a hard-coded off** — on FL3 the same variant *does* receive live gauge/width, which is why the toggle exists at all

**Rate-card basis:** hub event binding 4 h (§2)
**Dependencies:** FW-081, FW-150
**Blockers:** —

---

###### FW-N02 · Spool completion weight milestones and machine-stop confirmation
**Hours:** 4 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 8 · **Stream:** RT

> ⚠ **Superseded in part by `FW-202` (14 Aug 2026) — gap `G37`.** This story was the **only** costed work against
> `FR-130`–`FR-155`, a 26-requirement subsystem with 25 test cases (`TC-160`–`TC-184`), an owning specification,
> two hub events and a built mockup component. **4 h RT does not build it.** `FW-202` now owns **Part B**
> (`FR-140`–`FR-155`) — the PLC-confirmed stop confirmation, the completion transaction and the `SpoolProcessing` write.
> **This story retains Part A only** (`FR-130`–`FR-136`, the advisory milestone ladder), which is `Should` and
> explicitly *"advisory and non-blocking"*. Its hours are unchanged and remain inside Phase 8's reconciliation.

**As an** FL1 operator,
**I want** to be told as a spool approaches its target weight,
**So that** the machine stop is expected rather than a surprise.

**Acceptance Criteria:**
- [ ] Weight-milestone notifications raised as the spool approaches target, per [`SpoolCompletionNotification.md`](../10-requirements/screens/SpoolCompletionNotification.md)
- [ ] Machine-stop confirmation surfaced to the operator
- [ ] **Completion is graded against the customer's min/max weight range from the order, by weight** — **not** by footage and **not** against the withdrawn 2,000 lb default, which had no basis and exceeded the TKUP-2 ceiling of 1,100 lb
- [ ] **A short close is a specified transaction:** inside the customer range → continue; outside it → **supervisor override + production hold, or an offer to the customer under concession before a remake is planned — the offer comes first**
- [ ] **The spool is run off either way** — FL2 has no spool stripper, so it must be emptied and returned to FL1 whatever is decided. A reject-and-remake path must never imply stopping and removing a part-full spool

**Rate-card basis:** hub event binding 4 h (§2)
**Dependencies:** FW-150
**Blockers:** **OQ-18** *(which order field carries the range)* · **OQ-79** · ⚠ **the 10-90 SOP document is not in this repository and must be obtained from Operations rather than paraphrased**

---

###### FW-202 · FL1 spool completion — stop confirmation, weight basis and the `SpoolProcessing` write
**Hours:** 98 h — FE 32 · BE 42 · DB 8 · RT 16 · **Priority:** Critical · **Sprint:** S3 · **Phase:** 5 / 8 boundary · **Stream:** FE + BE + DB + RT

> **New 14 Aug 2026 — gap `G37`. These hours are ADDITIONAL to `[CE §3b]`** and are deliberately **outside** the
> Phase 8 reconciliation below, which reconciles to a figure priced before this scope was visible. Do not fold
> them in; re-derive additively. Scheduled in [`TrialRunPlan.md`](TrialRunPlan.md) §4.

**As an** FL1 operator,
**I want** the system to confirm the spool is finished when the machine actually stops, and record it,
**So that** the spool exists as a real, weighed, traceable piece of material that FL2 can check in.

**Acceptance Criteria — the prompt state machine (`FR-140`–`FR-145`):**
- [ ] Armed **only while actual weight ≥ target** for the current spool; a stop below target raises nothing (`TC-169`)
- [ ] Fires on the **`RUNNING → STOPPED` edge** of `FL{n}.LineState` — an edge, not a level — with speed ≈ 0 as corroboration, **exactly once per stop**, re-arming only on a return to RUNNING (`TC-170`)
- [ ] STOPPED persists for a **configurable dwell (default 5 s)** before display, so a jog or thread does not trigger it (`TC-171`)
- [ ] Weight **latched at the PLC stop timestamp** — the popup, the transaction and the label all use the latched value, not a later drifted one (`TC-172`)
- [ ] **Server-owned state, persisted against the run** and pushed over `FlatWireHub`, so it survives a refresh or screen change and is **re-delivered on reconnect** (`TC-173`)
- [ ] Suppressed when an open `RunPauseEvent` already captured a reason that is not spool removal (`TC-174`)
- [ ] **Escape and backdrop-click do not dismiss**; `Y`/`N` keys work and are advertised (`TC-178`)

**Acceptance Criteria — the completion transaction (`FR-146`–`FR-150`):**
- [ ] Yes commits, **then** prints — labels never print before the commit (`TC-175`)
- [ ] No records nothing — no transaction, no alpha, no print, no state change — and the **decline is logged** (`TC-176`)
- [ ] Auto-dismiss on resume, logged as `line resumed`, ladder re-arms (`TC-177`)
- [ ] A **manual complete-spool path stays available** — declining is never a dead end (`TC-179`)
- [ ] **The `SpoolProcessing` row is written here**: `SP-#####` alpha, `SourceRunId`, `ParentRodAlpha`, source rods from the run's `WeldEvent` chain, net weight, footage, `Status` — and the `FlatWireRun` closed. ⚠ **Nothing else in the plan creates it**; `POST /coil/complete` is Phase 9's **FL2 output coil** (`FW-185`), a different transaction on a different line

**Acceptance Criteria — the weight basis (`FR-137`, `FR-151`–`FR-155`):**
- [ ] `actual = (current footage − footage at spool start) × lb-per-ft`, where `lb-per-ft = A(in²) × 12 × ρ`, `A` applying the **round-edge correction** where applicable and ρ read from **`united_db..alloys.alloy_density`** (cross-database). Reference: 1100 at 0.110″ × 0.625″ → **0.0809 lb/ft** square edge, 0.0778 round (`TC-167`)
- [ ] **FL2 takes gauge and width from the pass schedule / order, not live measurement**, because FL2 broadcasts `null` (`TC-168`)
- [ ] Scale weight entered as **gross**, `net = gross − spool tare`; variance shown in **lb and % of calculated** (`TC-180`)
- [ ] Scale basis **pre-selected once entered and still overridable** back to calculated (`TC-181`)
- [ ] ⚠ **Variance beyond ±2 % never disables commit** (`TC-182`) — it is flagged, an override panel appears, the button relabels, the **commit control stays enabled** and remote approval is offered. An incomplete override flags the missing field, focuses the first, and commits nothing (`TC-183`)
- [ ] **Both weights, the variance, the override flag, supervisor and reason persist regardless of basis; the PIN is absent from the payload** (`TC-184`)

**Rate-card basis (§2):** stop-confirmation dialog 12 h + weight-basis/variance composite control 20 h (FE 32) · `SpoolCompletionService` prompt state machine 24 h + `CompleteSpool` command endpoint 6 h + `lb-per-ft` derivation service 12 h (BE 42) · `SpoolProcessing` write path + index 8 h (DB 8) · 2 hub events @ 8 h (RT 16) = **98 h**
**Dependencies:** FW-062, FW-081, FW-150, FW-171, FW-007
**Blockers:** ⚠ **`OQ-10` / `OI-45`** *(footage→weight **dimensional basis** — `FR-137` cannot be implemented without it; `[CE §2]`'s **16–32 h reserve** applies here as well as on Phase 9, and it is the one open question deliberately carrying no recommendation)* · **`OQ-18`** *(which order field carries the min/max range)* · **`OQ-79`** *(short close)* · **`OI-25`** *(the two footage coordinate systems)* · **`G34`** *(wire break has no persistence target and shares this stop path)* · ⚠ **the 10-90 SOP document is not in this repository and must be obtained from Operations rather than paraphrased**

---

**Phase 8 reconciliation** — FE `24+16+8 = 48` · BE 18 · DB 12 · RT `4+4 = 8` · base **86** → QA `0.20 × 86 = 17` → Cont `0.15 × (86+17) = 15` → **118 h** ✓ (§3b) · **split 59 h S2 / 59 h S3**

> ⚠ **`FW-202` is not in that reconciliation and must not be added to it.** `[CE §3b]`'s Phase 8 figure was priced
> before the `FR-130`–`FR-155` surface was visible (gap **`G37`**). Its **98 h base** is new scope: adding QA and
> contingency on `[CE §2]`'s rates gives `98 → QA 20 → Cont 18 → **136 h** all-in`, which belongs in an additive
> restatement, **not** in this figure or in any published per-phase total.

**S2 total** — `255 + 154 + 298 + 205 + 59 = **971 h**` ✓ · 9 working days · **13.5 FTE**

---

#### S3 — Finished Goods, Back-Office and Go-Live

**Dates:** Mon 21 Sep – Wed 30 Sep 2026 · **8 working days** *(truncated at the 30 Sep target; natural boundary Fri 2 Oct)* · **64 h/person**
**Phases:** 8 *(finishes)* · 9 Output Coil Completion · 10 FL3 Hybrid · 11 Reporting & Certification · 12 Yield/Cost/Scrap · 13 Administration · 14 Integration, Commissioning & Go-Live
**Hours:** **1,104** · **Required FTE: 17.3**
**Goal:** finish a coil with traceability and a label, prove all three routes, and hand over.

**Entry criteria:** an FL1-produced spool exists; the critical-path phases are complete.
**Exit criteria:** FL2 finishes a coil with a label and traceability; FL3 hybrid runs end to end; the five reports render; three green E2E route runs; UAT signed off.
**Demo:** spool → FL2 → coil → skid → certificate query; FL3 in one pass; the three-route E2E and the cert pack.
**Gates:** **M4 (20–27 Sep)** · **QA3 (24 Sep)** FL1 + FL2 E2E pass · **QA4 (28 Sep)** FL3 E2E + renamed-column regression · **QA5 (30 Sep)** full UAT · **M5 (30 Sep)** feature-complete.

> ## ⚠ This sprint is where the arithmetic breaks
>
> **Seven phases in 8 working days at 17.3 FTE**, including the sequential `8→9→10` chain and the whole of Phase 14 — three E2E route runs, PLC commissioning support, renamed-column regression **and** full UAT with stakeholder sign-off. **UAT cannot begin the day feature work completes.**
>
> Two mitigations, neither of which is this document's to choose:
> - **Extend S3 to its natural 2 Oct boundary** — costs two days, drops the peak to **13.8 FTE**. Cheapest relief in the plan.
> - **Pull Phase 14 into a dedicated post-feature-complete window**, which `CapacityAndEffortModel.md` §7 recommends regardless of team size.
>
> The descope ladder ([§5](#5-descope-ladder-mapped-to-sprints)) recovers at most 448 h across the whole programme — about 12% — and every rung of it lands in this sprint.

---

##### S3 · Phase 9 — Output Coil Completion, Labeling & Packing

**Spec:** [`phase-09-output-coil-completion-labeling-packing.md`](phases/phase-09-output-coil-completion-labeling-packing.md) · **Owning specification:** [`OutputCoilCompletion.md`](../10-requirements/screens/OutputCoilCompletion.md) v1.1 (owns **DB7 and DB7b**) · **Owner:** FE + BE · **222 h** (FE 104 · BE 26 · DB 16 · RT 8 · QA 31 · BA 8 · cont. 29)

> **Wholly MVP-1, and the 222 h figure is whole and correct.** DB7, DB7b, both coil endpoints, `CoilCompletionService` and `FW-066` were briefly carved to MVP-2 and **returned the same day**. The carve did not hold because `CoilOutput` and `CoilTraceability` are MVP-1 — the coil genealogy behind the **welding-wire customer certificates** is an MVP-1 obligation — but their **only writer** had gone to MVP-2, leaving the non-overlap trigger guarding rows nothing inserted.
>
> **⚠ Four dependencies came back with it and none is costed** — gap **`G36`**: `OI-104` (`CoilOutput.SkidId` references a skid table nothing names, creates or verifies) · `OI-24` / `OI-99` (the label returns a `lotNumber` with **no generator at all**, and no rule for the multi-rod case) · `OI-105` (`FR-346` adds a **physical scale weight** at the packing station — a third weight figure after the calculated value and DB7's override, with no rule for which governs) · `OI-106` (closure must assign a staging location and none are defined).
>
> **⚠ Estimate provisional — 16–32 h reserve excluded, and understated.** It was scoped before DB7b's physical scale weight was in MVP-1.

---

###### FW-066 · Dashboard 7 — Output Coil Completion
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As an** FL2 operator,
**I want** to confirm the finished coil with its calculated details,
**So that** the customer-facing record is created correctly at the moment the coil comes off.

**Acceptance Criteria:**
- [ ] `dashboard-7-coil-completion` from `../50-frontend/mockups/dashboard_7_coil_completion.html`
- [ ] System-calculated details: new alpha **`FW-#####-C##`** (mid-run child `…-A`), alloy/temper, footage
- [ ] **Gauge and width shown as the TARGET when in tolerance**, not the measured average
- [ ] **Net weight = footage × density factor, with an operator scale override**
- [ ] Final SPC in-spec badges; out-of-spec → **Submit · Suspend** as the primary action, routing to supervisor review
- [ ] Skid tracking: **Coil 1 of 2 (skid open) / Coil 2 of 2 (close + print skid label)** — exactly 2 per skid
- [ ] **Print Coil Label** is a physical label, **not the traveler** — the traveler is fully digital
- [ ] **Confirm & Move to Packing** → coil `COMPLETE`, skid linked, run complete, Dashboard 1 → IDLE
- [ ] Density factor pending → "pending confirmation" state plus the override, rather than a wrong number

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-183, FW-184, FW-185
**Blockers:** **OQ-10** *(footage→weight — **Critical**)* · **OI-45** *(dimensional basis)* · **OI-105** *(three weight figures, no precedence rule)* · **OI-98** ✅ *(**CLOSED 3 Sep 2026** — it ships as a single-coil skid *"as it completes the order"*; planners target even coil counts, so that is the fallback rather than the design. Removed from `FW-066`'s `blocked_by`. `ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`)* · **OI-25**

---

###### FW-182 · Dashboard 7b — Packing Station
**Hours:** 24 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As a** packing operator,
**I want** a station view of skids ready to close,
**So that** finished coils are packed and labelled without going back to the run screen.

**Acceptance Criteria:**
- [ ] `dashboard_7b_packing_station.html` built as a screen in its own right
- [ ] Packing queue driven by skid-closed events
- [ ] **Physical scale weight capture** (`FR-346`) — a second capture point after DB7's calculated value and override
- [ ] ⚠ **Which of the three weight figures governs the coil record is undecided (`OI-105`)** — surface all three rather than silently picking one, and flag the story as blocked on that rule
- [ ] Skid label printing
- [ ] Four of this screen's eight requirements are **mockup-derived and tagged `[PROPOSED]`** — confirm before building

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-066, FW-185
**Blockers:** **OI-105** *(weight precedence)* · **OI-106** *(no staging locations defined)* · **OI-104** *(no skid table)* · **OQ-4** *(skid labelling)*

---

###### FW-183 · `source-traceability-table` and `skid-tracker`
**Hours:** 40 h FE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As a** quality engineer,
**I want** each coil to show which source rods produced which footage,
**So that** a welding-wire certificate can be issued.

**Acceptance Criteria:**
- [ ] `source-traceability-table` — **one row per source rod with footage-from/to at each weld boundary**
- [ ] `skid-tracker` — 1-of-2 / 2-of-2 state, skid open/closed, skid id
- [ ] Both read from the `POST /coil/complete` response rather than issuing their own queries
- [ ] Footage ranges are **non-overlapping per coil**, matching the database trigger

**Rate-card basis:** 2 × shared composite control @ 20 h = 40 h (§2)
**Dependencies:** FW-185
**Blockers:** **OI-25** *(coil-local vs run-accumulated footage unreconciled)* · **OI-99** *(lot number for a multi-rod coil)*

---

###### FW-184 · `coil-label` and the print path
**Hours:** 16 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** FE

**As a** packing operator,
**I want** a correct physical coil label,
**So that** the coil is identifiable in the warehouse and on the customer's dock.

**Acceptance Criteria:**
- [ ] `coil-label` renders every label field including **source rod alphas** and the lot number
- [ ] Printing via the `shared` `print-export.service`
- [ ] **This is a label, not the traveler.** Coil and skid labels print; the traveler does not
- [ ] ⚠ **`lotNumber` has no generator** — surface the gap rather than emitting a blank or invented value

**Rate-card basis:** shared composite control 20 h, discounted to 16 h — printing reuses `print-export.service` (§2)
**Dependencies:** FW-185
**Blockers:** **OI-24 / OI-99** *(no lot-number generator at all, and no rule for the multi-rod case)*

---

###### FW-185 · `POST /coil/complete`, `GET /coil/{alpha}/label` and their services
**Hours:** 26 h BE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** BE

**As a** developer,
**I want** completion to generate the alpha, build the genealogy and close the skid in one transaction,
**So that** no coil exists without its traceability.

**Acceptance Criteria:**
- [ ] `CoilController POST /coil/complete` → coil alpha, skid id/status, footage total, `sourceTraceability[]`, `finalSpc`; `CompleteCoil` handler
- [ ] `GET /coil/{alpha}/label` → label DTO including source rod alphas and lot; `GetCoilLabel` handler
- [ ] `CoilCompletionService`: alpha generation, **traceability built from weld boundaries**, footage→weight via the alloy factor, the 2-per-skid rule, and marking the run complete
- [ ] **`LabelService`** for the coil label
- [ ] **2 coils per skid enforced**; gauge/width target-when-in-tolerance
- [ ] **The pass-schedule id + snapshot is written to the coil record** so a certificate stays reproducible after the schedule is later edited
- [ ] Operator+ authorization

**Rate-card basis:** command endpoint 6 h + query endpoint 4 h + `CoilCompletionService` 12 h + `LabelService` 4 h = 26 h (§2)
**Dependencies:** FW-139, FW-186, FW-171
**Blockers:** **OQ-10** *(Critical)* · **OI-104** *(`SkidId` has no target table)*

---

###### FW-186 · `CoilOutput`, `CoilTraceability` and the non-overlap trigger
**Hours:** 16 h DB · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** DB

**As a** quality owner,
**I want** overlapping footage ranges to be impossible,
**So that** a certificate cannot attribute the same foot to two rods.

**Acceptance Criteria:**
- [ ] `CoilOutput` write path live — alpha, weights, final gauge/width, `SkidId`, `SkidStatus`, `Status='COMPLETE'`, in-spec flags
- [ ] `CoilTraceability` write path live — footage ranges → rod alphas
- [ ] **`trg_CoilTraceability_NoOverlap` enforced and now actually exercised** — it had been guarding rows nothing inserted while the writer sat in MVP-2
- [ ] Indexes `CoilTraceability(CoilAlpha)` and `(RodAlpha)`
- [ ] `FlatWireRun.Status='Complete'` / `CompletedAt` written
- [ ] **`CoilOutput.SkidId` references an external skid table with no DB FK** — documented as such
- [ ] Genealogy query returns coil → `coils` R-series row → heat/lot across databases

**Rate-card basis:** 2 tables @ 4 h = 8 h + trigger/index hardening 4 h + run-completion write 4 h = 16 h (§2)
**Dependencies:** FW-007
**Blockers:** **OI-104** · **G36**

---

###### FW-187 · Completion broadcasts
**Hours:** 8 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 9 · **Stream:** RT

**As a** supervisor,
**I want** the board and the packing station to reflect completion immediately,
**So that** the next job can be started without asking.

**Acceptance Criteria:**
- [ ] `LineStatus` → IDLE on completion, reaching Dashboard 1
- [ ] Skid closed → packing-queue update reaching Dashboard 7b
- [ ] Both sent as rare domain events, immediate and unbatched

**Rate-card basis:** hub event 8 h (§2)
**Dependencies:** FW-149, FW-185
**Blockers:** —

---

###### FW-188 · Footage→weight basis and skid labelling
**Hours:** 8 h BA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 9 · **Stream:** BA

**As a** business analyst,
**I want** the weight basis and the skid rules settled,
**So that** the most widely-depended-on number in the build stops being provisional.

**Acceptance Criteria:**
- [ ] **OQ-10** closed — the **dimensional basis** for footage→weight decided: target-derived, measured-at-completion, or integrated over `RunReading`. *(The formula is settled; the basis is not, and integrating is materially more work than the other two.)* **This question deliberately carries no recommendation — it is a measurement question United Aluminum must answer from its own practice**
- [ ] **OI-105** closed — which of the three weight figures governs the coil record
- [ ] **OQ-4** closed — skid labelling
- [x] **OI-98** ✅ **CLOSED 3 Sep 2026, not merely progressed** — an odd final coil ships as a single-coil skid; even coil counts are the planning control. ⚠ The owning card `FW-188` is **not** done — its other criteria are open. `ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`
- [ ] Outcomes recorded in the register

**Rate-card basis:** BA / Ops liaison 8 h (§2)
**Dependencies:** None
**Blockers:** **OQ-10** *(Critical, and the most widely depended-on number in the build)*

---

**Phase 9 reconciliation** — FE `24+24+40+16 = 104` · BE 26 · DB 16 · RT 8 · dev base **154** · BA 8 → QA `0.20 × 154 = 31` → Cont `0.15 × (154+8+31) = 29` → **222 h** ✓ (§3b) · **+16–32 h reserve excluded, and understated**

---

##### S3 · Phase 10 — FL3 Hybrid Continuous Operation

**Spec:** [`phase-10-fl3-hybrid-continuous-operation.md`](phases/phase-10-fl3-hybrid-continuous-operation.md) · **Owner:** BE + FE · **61 h** (FE 12 · BE 20 · DB 4 · RT 8 · QA 9 · cont. 8)

> **The cheapest phase in the plan and explicitly not deferrable** — FL3 is one of the three production routes. It reuses Phases 4–6 and 9 behind mode flags; only the FL3 screen variants and the single-batch hybrid push are new. **The FL3 E2E (`FW-122`) is costed in Phase 14, not here.**

---

###### FW-189 · Dashboard 2 and 3 FL3 variants
**Hours:** 12 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 10 · **Stream:** FE

**As an** FL3 operator,
**I want** the check-in and run screens in hybrid mode,
**So that** one acknowledgement configures both mills.

**Acceptance Criteria:**
- [ ] `dashboard_2_rod_checkin` and `dashboard_3_active_run_fl3.html` variants configured from the shared shells — **not forked**
- [ ] Action bar **includes Roll Adjust** (`FR-108`), supplying **FL3's** stand set to the Phase-6 dialog
- [ ] Real-time trace runs continuously end to end; **no FL2 historical switch**
- [ ] **No intermediate spool alpha is generated or displayed**
- [ ] FL1 and FL2 shown unavailable while FL3 runs

**Rate-card basis:** 2 screen variants — check-in 8 h + run-monitor configuration 4 h = 12 h (§2)
**Dependencies:** FW-061, FW-062, FW-070
**Blockers:** **OQ-2 / OQ-67** *(FL3 blocks FL1/FL2 — decided)*

---

###### FW-190 · Hybrid single-batch PLC push and `RouteMode=Hybrid`
**Hours:** 20 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 10 · **Stream:** BE

**As an** FL3 operator,
**I want** one acknowledgement to configure FM1 and FM2 together,
**So that** material flows continuously without a second check-in.

**Acceptance Criteria:**
- [ ] `CheckInRod` with `route=Hybrid` → `PLCTagService` pushes **all FM1 + FM2 tags in one batch**
- [ ] **No `SpoolProcessing` row is created** — there is no intermediate spool on a hybrid run
- [ ] `FlatWireRun.RouteMode = Hybrid`
- [ ] **Single-push failure → full compensating clear** across both mills
- [ ] Hybrid schedule selection validated; a standalone FL2 schedule must not be applied to hybrid material

**Rate-card basis:** hybrid push logic 12 h + route-mode and no-spool branch 8 h = 20 h (§2)
**Dependencies:** FW-157, FW-082
**Blockers:** **OQ-15** *(hybrid schedule model — Option A assumed)* · ⚠ **G30 — FM2's controller namespace on FL3 is undetermined, which decides what a partial push failure even means**

---

###### FW-191 · `RouteMode` and the no-intermediate-spool rule
**Hours:** 4 h DB · **Priority:** Medium · **Sprint:** S3 · **Phase:** 10 · **Stream:** DB

**As a** developer,
**I want** hybrid runs distinguishable in the data,
**So that** reports and certificates can tell the three routes apart.

**Acceptance Criteria:**
- [ ] `FlatWireRun.RouteMode` accepts `Hybrid` with an enumerating `CHECK`
- [ ] A hybrid run has **no** `SpoolProcessing` row, and this is assertable by query
- [ ] `CoilOutput` / `CoilTraceability` behave exactly as in Phase 9

**Rate-card basis:** column + constraint as part of the table rate (4 h, §2)
**Dependencies:** FW-006
**Blockers:** —

---

###### FW-192 · Continuous end-to-end trace on FL3
**Hours:** 8 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 10 · **Stream:** RT

**As an** FL3 operator,
**I want** the trace to run unbroken from rod to coil,
**So that** traceability is continuous across the whole hybrid run.

**Acceptance Criteria:**
- [ ] Continuous `GaugeReading` / `WidthReading` end to end — **no FL2 historical switch mid-run**
- [ ] Weld events mid-run keep the traceability chain continuous
- [ ] The Live/Profile toggle is **available** on FL3, because a hybrid run genuinely has both

**Rate-card basis:** hub event binding 8 h (§2)
**Dependencies:** FW-081, FW-181
**Blockers:** —

---

**Phase 10 reconciliation** — FE 12 · BE 20 · DB 4 · RT 8 · base **44** → QA `0.20 × 44 = 9` → Cont `0.15 × (44+9) = 8` → **61 h** ✓ (§3b)

---

##### S3 · Phase 11 — Reporting & Certification

**Spec:** [`phase-11-shift-summary-reporting-certification.md`](phases/phase-11-shift-summary-reporting-certification.md) · **Owner:** BE + FE · **MVP-1 175 h** (FE 40 · BE 56 · DB 20 · RT 4 · QA 24 · BA 8 · cont. 23)

> **⚠ Dashboard 10 (Shift Summary) is MVP-2** — the screen, `GET /shiftsummary`, `ShiftSummaryService`, `sp_ShiftSummary` and story `FW-069` were carved out verbatim. **The published 246 h figure was never apportioned and overstates MVP-1**; the MVP-1 figure is **175 h**, derived in `CapacityAndEffortModel.md` §3b by re-pricing each carved deliverable off the rate card.
>
> **`sp_ShiftSummary` must not be created, dropped or granted from this scope.**
>
> **Partly deferrable — `FW-092`/`093`/`094`/`095` are ladder rung 6 (105 h), latest call inside S2.** Only the Gauge Trace report would survive. **`FW-095` Cut Traceability is needed before first shipment**, which is why this phase could not be deferred whole.

---

###### FW-090 · Flattening Lines report tab and reporting views
**Hours:** 16 h BE · 20 h DB · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** BE + DB

**As a** quality engineer,
**I want** flat wire to appear as a tab in the existing Reports application,
**So that** I use the reporting tool I already know.

**Acceptance Criteria:**
- [ ] The existing `Reports` service extended with a **Flattening Lines** tab — not a new reporting application
- [ ] Reporting views and stored procedures created in `08_Programmability` for the five reports
- [ ] Dapper aggregations over `SpcCheckpoint` / `SpcMeasurement`, `RunPauseEvent`, `WeldEvent`, `CoilOutput`, `CoilTraceability`, `FlatWireRun`, `WipRejection`
- [ ] Shift-window filter indexes on timestamp + line
- [ ] Supervisor+ authorization

**Rate-card basis:** BE tab extension 16 h + 2 reporting views/procs @ 8 h + index work 4 h = 20 h DB (§2)
**Dependencies:** FW-152, FW-186
**Blockers:** **OI-101** *(shift boundaries are undefined — this blocks every shift-scoped figure)*

---

###### FW-091 · Gauge Trace report
**Hours:** 8 h FE · 8 h BE · 4 h RT · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE + RT

**As a** quality engineer,
**I want** the gauge trace for any run,
**So that** I can review dimensional performance after the fact.

**Acceptance Criteria:**
- [ ] **Real-time view for FL1/FL3** (reusing the hub) and **historical for FL2**
- [ ] Weld markers rendered on the trace
- [ ] Reads `RunReading` via `sp_GetGaugeTrace`
- [ ] Export and print via `print-export.service`

**Rate-card basis:** report 8 h FE + 8 h BE (§2) + live-view hub reuse 4 h RT
**Dependencies:** FW-090, FW-165, FW-081
**Blockers:** —

> **The only report that survives descope rung 6.** If the rung is taken, this ships and the four below do not.

---

###### FW-092 · Gauge CPK Deviation and CPK report
**Hours:** 8 h FE · 8 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** process engineer,
**I want** capability indices across product families,
**So that** I can show the process is in control.

**Acceptance Criteria:**
- [ ] CPK computed over `RunReading` against the alloy's tolerance bands
- [ ] Filter `Strip / Flat Wire / All`
- [ ] Deviation and CPK presented together

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090
**Blockers:** **OI-57** *(tolerance bands)* · **descope ladder rung 6**

---

###### FW-093 · Coil Pass Detail report
**Hours:** 8 h FE · 8 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** process engineer,
**I want** the pass detail behind a finished coil,
**So that** I can reconstruct how it was made.

**Acceptance Criteria:**
- [ ] Per-coil pass detail drawn from the pass-schedule **snapshot written at check-in**, not from the live schedule
- [ ] Includes mid-run overrides from `RollOverride` and die changes from `DieChangeEvent`
- [ ] Export and print

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090, FW-185
**Blockers:** **descope ladder rung 6**

---

###### FW-094 · SPC at Flattening Line report
**Hours:** 8 h FE · 8 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** quality engineer,
**I want** every SPC checkpoint in one report,
**So that** I can audit quality gates across a shift or an order.

**Acceptance Criteria:**
- [ ] Covers **all five checkpoint types** — `PreRun`, `PostDieChange`, `RollAdjustTrigger`, `ManualSpotCheck`, `PostRun`
- [ ] In/out of spec flagged per measurement
- [ ] Filterable by line, run, order and date range

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090, FW-171
**Blockers:** **descope ladder rung 6**

---

###### FW-095 · Cut Traceability report
**Hours:** 8 h FE · 8 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** FE + BE

**As a** quality engineer,
**I want** to trace a finished coil back to heat,
**So that** I can issue a welding-wire certificate of conformance.

**Acceptance Criteria:**
- [ ] Full chain rendered: **Coil → Spool → Rod → Lot → Heat**
- [ ] Cross-database join from `CoilTraceability` through the `coils` R-series row to the existing chemistry/`Lots` tables
- [ ] Footage attribution per source rod, from the weld boundaries
- [ ] Export in a form the certificate pack can consume

**Rate-card basis:** report 8 h FE + 8 h BE (§2)
**Dependencies:** FW-090, FW-186, FW-183
**Blockers:** **OQ-5 / OQ-25** *(cert granularity and frequency)* · **OI-99** *(lot number for a multi-rod coil)* · **descope ladder rung 6**

> **⚠ Needed before first shipment.** It is on rung 6 with the other three, but deferring it has a different consequence: no certificate. Treat it as the rung's exception when the call is made in S2.

---

###### FW-193 · Certification granularity and tolerance bands
**Hours:** 8 h BA · **Priority:** High · **Sprint:** S3 · **Phase:** 11 · **Stream:** BA

**As a** business analyst,
**I want** the certificate's granularity and the report tolerance bands settled,
**So that** the traceability report matches what the customer is owed.

**Acceptance Criteria:**
- [ ] **OQ-5 / OQ-25** closed — certificate granularity and frequency
- [ ] **OI-57** closed — tolerance bands for the CPK report
- [ ] **OI-84** closed — WIP report columns, with Shannon R.
- [ ] **OI-101** raised to a decision — shift boundaries, which block every shift-scoped figure
- [ ] Outcomes recorded in the register

**Rate-card basis:** BA / Ops liaison 8 h (§2)
**Dependencies:** None
**Blockers:** **OI-101**

---

**Phase 11 reconciliation** — FE `8×5 = 40` · BE `16+(8×5) = 56` · DB 20 · RT 4 · dev base **120** · BA 8 → QA `0.20 × 120 = 24` → Cont `0.15 × (120+8+24) = 23` → **175 h** ✓ (§3b MVP-1 carve)

---

##### S3 · Phase 12 — Yield, Cost Ledger & Scrap

**Spec:** [`phase-12-yield-cost-ledger-scrap.md`](phases/phase-12-yield-cost-ledger-scrap.md) · **Phase sheet:** [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md) · **Owner:** BE · **177 h** (FE 44 · BE 72 · DB 12 · QA 26 · cont. 23)

> **⚠ This phase is the whole of descope ladder rungs 1–4** (177 h). Latest call: **inside S2**.
>
> **⚠ Read the phase sheet before scheduling.** It records that **`FW-101`, `FW-102` and `FW-110` carry no `FR-` IDs and the phase has no owning requirement document** — its 177 h was priced against four Jira cards. The sheet also carries the AI-assisted view at **126 h**.
>
> **Story bodies absorbed from `YieldCostAndScrapJiraStories.md`** on 13 Aug 2026 under the single-backlog decision. That file is now a pointer; **`YieldCostAndScrapSheet.md` remains the Phase-12 hours authority** and its 33/49/28/67 ladder split reconciles exactly to the figures below.

---

###### FW-100 · Footage-based yield and the weight formula
**Hours:** 24 h FE · 24 h BE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE

**As a** production controller,
**I want** yield calculated from footage,
**So that** flat wire is measured the way it is actually produced.

**Acceptance Criteria:**
- [ ] Yield form gains a **"Flat Wire" checkbox** and the flat-wire field renames
- [ ] Weight computed as **footage × area × density**; `CoilYield` extended
- [ ] **Scrap is calculated in footage, not weight**, on the Material Loss tab
- [ ] Reads `CoilTraceability` / `WeldEvent` / `CoilOutput`
- [ ] ~~Renamed yield fields from FW-001 consumed correctly~~ — **struck 18 Aug 2026, `D-32`**: there are no renamed fields. The yield form reads the shared columns under their **existing** names

**Rate-card basis:** ladder rung 4 remainder — **67 h all-in**; dev base 48 h (§2, `YieldCostAndScrapSheet.md`)
**Dependencies:** ~~FW-001~~ *(cancelled, `D-32`)*, FW-186
**Blockers:** **OQ-10** *(gates the weight formula)* · **OI-60** *(metallic yield per route)*

---

###### FW-101 · Weld traceability attribution in yield
**Hours:** 20 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 12 · **Stream:** BE

**As a** quality owner,
**I want** yield attributed per source rod across weld points,
**So that** welding-wire certificates carry correct per-rod figures.

**Acceptance Criteria:**
- [ ] Yield rows produced per source rod, split at each weld boundary
- [ ] Multi-rod coils produce multiple yield rows that sum to the coil total
- [ ] Reads the `CoilTraceability` genealogy built in Phase 9

**Rate-card basis:** ladder rung 3 — **28 h all-in**; dev base 20 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-186, FW-100
**Blockers:** **OI-60** · ⚠ **descope ladder rung 3 — deferring this affects welding-wire certificates**, which is why the rung needs Tim O. / Quality sign-off rather than a programme decision

---

###### FW-102 · Flat-wire cost ledger configuration
**Hours:** 12 h FE · 20 h BE · 4 h DB · **Priority:** Medium · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE + DB

**As a** cost accountant,
**I want** flat-wire cost standards configurable,
**So that** costing reports are not blank for the new lines.

**Acceptance Criteria:**
- [ ] Cost ledger configuration UI for flat wire
- [ ] `CoilCosting` extended with flat-wire cost standards and standard times
- [ ] Costing reports render for FL1/FL2/FL3

**Rate-card basis:** ladder rung 2 — **49 h all-in**; dev base 36 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-100
**Blockers:** **OI-68** *(costing and standard times — both open)*

---

###### FW-110 · Scrap Box / Scrap Skid outlet
**Hours:** 8 h FE · 8 h BE · 8 h DB · **Priority:** Low · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE + DB

**As a** scrap operator,
**I want** scrap routed to the right outlet,
**So that** flat-wire scrap is handled like every other material.

**Acceptance Criteria:**
- [ ] Scrap module outlet supports **`Scrap Box`** and **`Scrap Skid`**
- [ ] Outlet applies to Flat Wire, Conveyors and Inspection
- [ ] Scrap services extended

**Rate-card basis:** ladder rung 1 — **33 h all-in**; dev base 24 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-100
**Blockers:** **OI-83** *(baler/banding)* · **descope ladder rung 1 — first thing off the plan**

---

**Phase 12 reconciliation** — FE `24+12+8 = 44` · BE `24+20+20+8 = 72` · DB `4+8 = 12` · base **128** → QA `0.20 × 128 = 26` → Cont `0.15 × (128+26) = 23` → **177 h** ✓ (§3b) · ladder split `33+49+28+67 = 177` ✓

---

##### S3 · Phase 13 — Administration & Reference Data

**Spec:** [`phase-13-administration-reference-data.md`](phases/phase-13-administration-reference-data.md) · **Owner:** FE + BE · **MVP-1 143 h** (FE 56 · BE 32 · DB 8 · RT 4 · QA 20 · BA 4 · cont. 19)

> **⚠ Die Management is MVP-2** — the screen, the die lifecycle service and the die inventory status vocabulary were carved out verbatim. **The published 209 h figure was never apportioned and overstates MVP-1**; the MVP-1 figure is **143 h**.
>
> **⚠ Correction to `phase-13`'s own callout.** That file's MVP-2 banner says *"The `FW-N07` table half is also MVP-1… the 8 h costed for the missing die table stays here."* **That is stale and contradicted by the same file's scope call**, by `CapacityAndEffortModel.md` §3b (which lists "Die inventory table — 8 h DB" among the carved deliverables) and by the repository guide. **`FW-N07` is wholly MVP-2 and the 8 h left with the screen.** MVP-1's die change validates against the **`Drawer` size catalogue seeded in Phase 1**, so no die master table is needed here.
>
> **Partly deferrable — the role-assignment UI is the deferrable part of ladder rung 5.** The alloy lookup and machine tabs are not. **Rung 5's published 99 h is no longer available in full**, because it bundled the now-MVP-2 Die Management screen with the MVP-1 role UI.

---

###### FW-194 · Alloy lookup admin grid
**Hours:** 20 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As a** process engineer,
**I want** to maintain alloy properties and tolerance bands without a code change,
**So that** reference data can be corrected as the mill learns the process.

**Acceptance Criteria:**
- [ ] Admin grid over `AlloyProperty` with create, edit and audit history
- [ ] **Maintains four min/max pairs, not two single ± values** — the bands are **offsets about nominal and may be asymmetric**, so the editor **must not collapse them to one field**. Ovality takes an **upper limit only**
- [ ] Restricted to Process Engineering / Admin; every edit audit-logged
- [ ] Fields left NULL pending the client e-mail render as explicitly unset, not as zero
- [ ] The `0.003"` ovality limit is edited here, never in code

**Rate-card basis:** new dashboard 24 h, discounted to 20 h — an admin grid over one table (§2)
**Dependencies:** FW-004, FW-196
**Blockers:** ⛔ **OQ-22** *(the width, height, diameter and ovality values are owed by client e-mail; they also need Process Engineering sign-off)*

---

###### FW-054 · Alloys — Material Type across Properties, Reduction Rules and Vendor O Gauge
**Hours:** 12 h FE · **Priority:** High · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As a** process engineer,
**I want** Material Type carried consistently across the alloy screens,
**So that** flat wire and strip are distinguishable wherever alloy data is edited.

**Acceptance Criteria:**
- [ ] Material Type surfaced on the Alloy Properties, Reduction Rules and Vendor O Gauge screens
- [ ] Existing strip behaviour unchanged
- [ ] Consistent with the `AlloyProperty` model from FW-004

**Rate-card basis:** 3 screen extensions @ 4 h = 12 h (§2)
**Dependencies:** FW-194
**Blockers:** —

> **Re-homed from the deleted Epic 6** ("Web App Changes"), whose other five stories were upstream. It sits beside `FW-004`, the alloy lookup it belongs with.

---

###### FW-003 · Machine template tabs — register FL1, FL2, FL3
**Hours:** 12 h FE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As a** system administrator,
**I want** the three flattening lines registered as fully configured machines,
**So that** scheduling, planning, reporting and shopfloor can all reference them.

**Acceptance Criteria:**
- [ ] FL1, FL2, FL3 each have a unique `MachineId` / `IdNo` and appear in **every** machine dropdown system-wide
- [ ] Machine template tabs configured: Main (combined Slitter + Mill rows) · Roll Finish · **Pass Schedule** (button renamed *"Flattening Line Schedule"*) · Coating · KSI/Gauge Max Cuts (*"Max # of Cuts"* column removed) · Rewind Capabilities · ID Width Max Cuts · Setup/Handling Times · Tooling Inventory (+ **Dies, Edgers, Straighteners and Roll Sets** as new tooling types — `D-42`) · **Speed** (*"Min/Max Gauge"* → *"Min/Max Gauge/Diameter"*; checkboxes for **DB1, DB2, FM1-S1, FM2-S1/S2/S3**) · Material Loss (**scrap in footage, not weight**) · History
- [ ] Operation letter **`F`** used for flattening in `OpLetter` / `PrevOpLetter` / `RemainingOps`
- [ ] **The Speed tab's checkboxes name three FM2 stands — `FM2-S1`, `FM2-S2`, `FM2-S3`. There is no fourth**
- [ ] **Tooling Inventory carries FOUR tool types — Dies, Edgers (Edging Rolls), Straighteners and Roll Sets** — replacing the five inherited from the Slitter copy. `D-42`, 3 Sep 2026. The first three are Tim O'Brien, 31 Aug 2026 (*"They should be replaced with Dies, Edgers, & Straighteners."*); the fourth is Tim O'Brien, 3 Sep 2026 — *"We should include mill rolls for traceability, 12″ (FL1-S1) 2 roll set, DB1/DB2 Capstans (rolls)… 8″, 6″, 6″ rolls for (FL2-S1, FL2-S2, FL2-S3) 2 roll sets."* ⚠ This supersedes the 24 Aug call's two **and** the 31 Aug three. **Dancers, entry guides, payoffs and spools are explicitly NOT tooling** — do not add them. ⛔ **The roll-set grid columns are `[PROPOSED]`, not client-supplied** — the other three arrived as pictured grids and this one as one sentence: `G87`, and `Q92` is the send-back
- [ ] **Tooling is maintained for FL1 and FL2 only; FL3 uses a combination of the two** — *"We should maintain them for FL1/FL2 and FL3 should use a combination of the two"* (`D-42`). This confirms the 31 Aug observation that **no FL3 row appears in any tool grid** was intentional, not an omission in the sample
- [ ] ⚠ **`Straightener` is no longer absent from this repository.** The earlier wording here — *"exists nowhere else in this repository"* — was true when written and is now stale: three delay-reason codes (`SET31`, `HDL20`, `DWN39`, all *Change Straightener Rolls*) are seeded, and two rows carry it in the pause-run mockup. What it still lacks is an **equipment** table — `G77`. It is used on **FL1** (so FL3 by inheritance), the blocks sit on the **entry side of the 12″ mill**, and it is **not** a pass-schedule component — all four confirmed 3 Sep 2026
- [ ] ⚠ **Four tabs are configured PER LINE, not once** — *"This will be different for FL1 & FL2/FL3 as each machine has its own capabilities"* (31 Aug 2026), said of Flattening Line Schedule, Setup/Handling Times and Material Loss. FL1 and FL2/FL3 carry different field sets on each
- [ ] Setup/Handling Times category labels renamed from the Slitter copy: **S1 → "Setup Before Run"** · **H1A → "Handling Before Reduction"** · **R → "Flattening Line Run"** · **H2 → "…From Takeup"** (was *Rewind*). H1AA, H1B and S2 unchanged
- [ ] ⚠ **The Slitter and Mill screens are reference points, not screens being altered.** *"All others will be removed"* removes fields from the **Flat Wire copy** only; ZR23/ZR24 and the slitters keep theirs. Field sets: [`ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md`](../95-archive/source-documents/ClientEmail_2026-08-31_MachinesAppTabs_SyncPlan.md) §3

**Rate-card basis:** 12 template tabs, priced as configuration rather than new screens (12 h, §2)
**Dependencies:** ~~FW-001, FW-002~~ — **both cancelled, `D-32`.** ⚠ **This story is not cancelled with them:** the FL1/FL2/FL3 machine rows and the operation letter `F` are values in columns that already exist, not a schema change, so `OI-27` (no `F` case in `GetMachineTypeFromOpLetter`) stands
**Blockers:** ⚠ **the Naj/Bob/Tim standards spreadsheet must be finalised first — an external dependency**

---

###### FW-195 · Role assignment UI
**Hours:** 12 h FE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

**As an** administrator,
**I want** to assign flat-wire roles without a DBA,
**So that** operator and supervisor access is managed in the application.

**Acceptance Criteria:**
- [ ] Assign Operator / Operations Manager / Maintenance / Supervisor / Admin
- [ ] Matches the Authorization Matrix policies from FW-145
- [ ] Changes audit-logged

**Rate-card basis:** shared composite control 20 h, discounted to 12 h — it drives existing role policies (§2)
**Dependencies:** FW-145, FW-196
**Blockers:** **G6** · ⚠ **descope ladder rung 5 — if deferred, roles are assigned by a DBA**

---

###### FW-196 · Alloy CRUD, machine config and role config endpoints
**Hours:** 32 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 13 · **Stream:** BE

**As a** developer,
**I want** the admin surfaces backed by audited, restricted endpoints,
**So that** reference data cannot be changed anonymously.

**Acceptance Criteria:**
- [ ] Alloy CRUD — **audit-logged and role-restricted**
- [ ] Machine configuration endpoints for the template tabs
- [ ] Role/permission configuration endpoints
- [ ] Every write records who, what and when
- [ ] **The die lifecycle service is not built here — it is MVP-2**

**Rate-card basis:** alloy CRUD service 16 h + machine config 8 h + role config 8 h = 32 h (§2)
**Dependencies:** FW-139, FW-145
**Blockers:** —

---

###### FW-197 · Reference-data admin wiring
**Hours:** 8 h DB · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13 · **Stream:** DB

**As a** developer,
**I want** the non-die lookups editable through the admin surface,
**So that** stands, drawers, edgers and spool configurations are maintainable.

**Acceptance Criteria:**
- [ ] `Stand`, `Drawer`, `Edger` and `Spool` reachable through the admin endpoints
- [ ] Audit columns populated on edit
- [ ] **`Drawer` is already seeded in Phase 1** — this exposes it, it does not create it
- [ ] **No die inventory table is created** — die inventory and lifecycle are owned outside MVP-1

**Rate-card basis:** non-die reference-data wiring 8 h (§2, §3b — this is the surviving DB line after the die-table carve)
**Dependencies:** FW-005, FW-196
**Blockers:** **OI-77 / OI-43** *(edger profiles and roll spares)*

---

###### FW-198 · Reference-data change broadcast
**Hours:** 4 h RT · **Priority:** Low · **Sprint:** S3 · **Phase:** 13 · **Stream:** RT

**As an** operator,
**I want** a tolerance change to reach open screens,
**So that** I am not validating against a stale band.

**Acceptance Criteria:**
- [ ] Reference-data changes broadcast so open clients refresh their cached lookups
- [ ] Sent as a rare domain event, immediate and unbatched

**Rate-card basis:** hub event 8 h, discounted to 4 h — one event over existing infrastructure (§2)
**Dependencies:** FW-149, FW-196
**Blockers:** —

---

###### FW-199 · Alloy tolerance values and die-life thresholds
**Hours:** 4 h BA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 13 · **Stream:** BA

**As a** business analyst,
**I want** the outstanding alloy values chased and the die-life thresholds settled,
**So that** `CHK007` can finally fire.

**Acceptance Criteria:**
- [ ] ⛔ **OQ-22** closed — width, height, diameter and ovality tolerance values received by e-mail **and** signed off by Process Engineering
- [ ] Die-life threshold configurability decided (**OQ-83** die-life tracking is decided; the threshold is not)
- [ ] **OI-77 / OI-43** progressed — edger profiles and roll spares
- [ ] Outcomes recorded in the register

**Rate-card basis:** BA / Ops liaison 4 h (§2)
**Dependencies:** None
**Blockers:** ⛔ **OQ-22 — this also blocks Phase 4.** Tim confirmed the tolerances exist and would send them; he did not have them to hand. **Nothing is seeded until they arrive**, and the Dashboard 2A mock map must not be used as a substitute

---

**Phase 13 reconciliation** — FE `20+12+12+12 = 56` · BE 32 · DB 8 · RT 4 · dev base **100** · BA 4 → QA `0.20 × 100 = 20` → Cont `0.15 × (100+4+20) = 19` → **143 h** ✓ (§3b MVP-1 carve)

---

##### S3 · Phase 14 — Integration Testing, PLC Commissioning & Go-Live

**Spec:** [`phase-14-integration-testing-plc-commissioning-golive.md`](phases/phase-14-integration-testing-plc-commissioning-golive.md) · **Owner:** QA + BA · **267 h** (QA 112 · RT 40 · BA 40 · FE 16 · BE 16 · DB 8 · cont. 35)

> **Not deferrable — but S3 cannot hold it.** 267 hours alongside Phases 12 and 13 in 8 working days is the single worst compression in the plan. **UAT and stakeholder sign-off cannot begin the day feature work completes.** `CapacityAndEffortModel.md` §7 recommends pulling this into a dedicated post-feature-complete window **regardless of team size**.
>
> **No 20% QA uplift is applied here** — this phase *is* the QA phase, and its QA hours are explicit.

---

###### FW-120 · E2E FL1 standalone
**Hours:** 32 h QA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** QA

**As a** QA engineer,
**I want** the whole FL1 route proven end to end,
**So that** the primary production route is known to work before go-live.

**Acceptance Criteria:**
- [ ] **Automated with Playwright** — `e2e/specs/fl1-standalone.spec.ts`, driving **real OPC tags** into the test-only server sidecar. Not a manual walkthrough
- [ ] Check-in → active run → SPC → weld → complete → spool alpha → reporting. ⚠ **Starts at a seeded rod**: *received → planned → scheduled* are **upstream and out of test scope** (`[TS §2.2]`, *"fixture-supplied here"*), so the spec asserts them as preconditions rather than exercising them
- [ ] **`INFLAT` verified set and cleared** at the right moments
- [ ] PLC push logged (simulate or commissioning)
- [ ] Weld traceability and SPC records verified against the database
- [ ] Green run recorded at **QA3 (24 Sep)**

**Rate-card basis:** E2E route run, explicit QA hours (32 h, §3)
**Dependencies:** Phases 4, 5, 6, 7 complete
**Blockers:** all Critical `OQ`s must close before sign-off

---

###### FW-121 · E2E FL2 standalone
**Hours:** 24 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** QA

**As a** QA engineer,
**I want** the FL2 finishing route proven end to end,
**So that** the coil the customer receives is known to be correct.

**Acceptance Criteria:**
- [ ] **Automated with Playwright** — `e2e/specs/fl2-standalone.spec.ts`
- [ ] Spool → FL2 check-in (historical profile) → roll adjust → coil completion → skid close
- [ ] **The null-gauge case verified** — Live shows its empty state and does not draw a line at target; Profile stays static across live ticks
- [ ] **Components card shows exactly three FM2 stands**; a fourth row is a regression
- [ ] Green run recorded at **QA3 (24 Sep)**

**Rate-card basis:** E2E route run (24 h, §3)
**Dependencies:** Phases 8, 9 complete
**Blockers:** **OQ-15** · **OQ-17**

---

###### FW-122 · E2E FL3 hybrid
**Hours:** 24 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** QA

**As a** QA engineer,
**I want** the hybrid route proven end to end,
**So that** the most complex route is not first exercised in production.

**Acceptance Criteria:**
- [ ] **Automated with Playwright** — `e2e/specs/fl3-hybrid.spec.ts`. ⚠ **`G30` must close first**: it decides whether FL3's FM2 sits at `FL2.FM2.*` or `FL3.FM2.*`, and the test must write tags to whichever namespace the app reads. Until it closes this spec cannot be authored at all
- [ ] **Single acknowledgement** → continuous run → **no intermediate alpha** → weld → coreless coil
- [ ] **FL1 and FL2 confirmed unavailable** in scheduling during an FL3 run
- [ ] Single PLC push covers all FM1 + FM2 components
- [ ] Roll Adjust present on FL3 and **absent on FL1**
- [ ] Continuous trace across the whole run
- [ ] Green run recorded at **QA4 (28 Sep)**

**Rate-card basis:** E2E route run (24 h, §3)
**Dependencies:** Phase 10 complete
**Blockers:** **OQ-15** · **G30**

---

###### FW-200 · PLC commissioning support
**Hours:** 40 h RT · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** RT

**As a** commissioning engineer,
**I want** the system switched from simulation to live tags with support on hand,
**So that** the mill is configured by the application rather than by hand.

**Acceptance Criteria:**
- [ ] `SimulatePLCTagPush` switched to live
- [ ] **Every OPC tag path confirmed against the controller** with Tim O. and the commissioning engineer — this is what makes a path `[CONFIRMED]`; **no path in `[PLC]` is confirmed until a controller accepts it** (tests `C1` / `C11`)
- [ ] Push and clear validated on all three lines; live AGC feed validated
- [ ] **`PLC-Q##` sign-off sheet completed** — three of its items are `Critical`
- [ ] **Target by 30 Sep.** Until it completes every line runs simulate + mock SignalR. **Development is not blocked by this; go-live is**

**Rate-card basis:** PLC commissioning, explicit RT hours (40 h, §3)
**Dependencies:** FW-082, FW-151, FW-190
**Blockers:** **`PLC-Q04`** *(FM2 station names — `Stand8`/`Stand6S1`/`Stand6S2` observed, ours differ)* · **`PLC-Q05`** *(the measure segment of **every** tag is ours, risking all 41 paths)* · **G29** *(no edger tag path exists)* · **G30**

---

###### FW-123 · UAT and stakeholder sign-off
**Hours:** 40 h BA · 16 h QA · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** BA + QA

**As a** programme manager,
**I want** the client to accept the system on staging,
**So that** trial and production can be scheduled.

**Acceptance Criteria:**
- [ ] UAT run on staging (`devual-uadev001`) with mock SignalR and simulate PLC
- [ ] Clickable demo for Tim O., Shannon R. and the ops team
- [ ] **Every Critical open question closed before sign-off** — `OI-88`, `OQ-2`, `OQ-3`, `OQ-76`, `OI-49`, `OQ-61`, `OI-60`, `OQ-10`, `OQ-67`, `OQ-14`, `OQ-15`
- [ ] Alpha genealogy demonstrated end to end: Rod → Spool → Coil → Skid
- [ ] Sign-off recorded at **QA5 / M5 (30 Sep)**
- [ ] ⚠ **UAT must not share a window with feature work** — schedule it after feature-complete, whatever date that lands on

**Rate-card basis:** UAT coordination 40 h BA + UAT execution 16 h QA (§3)
**Dependencies:** every critical-path phase
**Blockers:** all Critical `OQ`s · ⚠ **the compression itself**

---

###### FW-201 · Defect allowance and renamed-column regression
**Hours:** 16 h FE · 16 h BE · 8 h DB · 16 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** FE + BE + DB + QA

**As a** QA engineer,
**I want** budgeted time to fix what the E2E runs find,
**So that** defects are closed rather than deferred into the trial.

**Acceptance Criteria:**
- [ ] Defect allowance available across FE, BE and DB for issues raised by `FW-120`–`FW-122`
- [ ] ~~**Regression pass over every report and screen touched by the FW-001 renames**, run at **QA4 (28 Sep)**~~ — **struck 18 Aug 2026, `D-32`**: no columns are renamed, so there is nothing to regress. ⚠ **The story's hours are deliberately held, not reduced** — this is a defect *allowance*, priced per stream rather than per acceptance criterion
- [ ] Fixes verified by re-running the affected E2E route
- [ ] Deployment path exercised: `ng build` → IIS static; `dotnet publish FlatWire.API` → IIS app pool with **WebSockets enabled**; DDL via the ordered migration scripts

**Rate-card basis:** defect allowance, explicit per-stream hours (16+16+8 = 40 h dev + 16 h QA, §3)
**Dependencies:** ~~FW-001~~ *(cancelled, `D-32`)*, FW-120, FW-121, FW-122
**Blockers:** —

---

**Phase 14 reconciliation** — QA `32+24+24+16+16 = 112` · RT 40 · BA 40 · FE 16 · BE 16 · DB 8 · base **232** → **no QA uplift** (this is the QA phase) → Cont `0.15 × 232 = 35` → **267 h** ✓ (§3b)

**S3 total** — `59 + 222 + 61 + 175 + 177 + 143 + 267 = **1,104 h**` ✓ · 8 working days · **17.3 FTE**

---

#### Additive — pending-work stories, minted 29 Aug 2026 (`FW-232`–`FW-250`)

> **New 29 Aug 2026.** Nineteen stories for work that had **no id, no plan and no hours line**,
> drawn from the two orchestration files' own recorded-but-unfixed findings
> ([`Backend/tasks/Orchestration.md`](../40-backend/tasks/Orchestration.md)
> §8.1–§8.3 and [`Database/tasks/Orchestration.md`](../30-database/tasks/Orchestration.md)
> §3 and §8.1), plus the `P-##` register and `[GAP]`. Each names the gap or finding it closes.
>
> ⚠ **Hours are additive to `[CE §3b]`** — the same treatment as `FW-202`, `FW-203`, `FW-204`,
> `FW-218` and `FW-219`. **They offset nothing, they are in no phase reconciliation above, and
> they are not folded into the 114-story / 3,186 h baseline.** A combined figure is `FW-249`'s
> job, in an additive sheet.
>
> ⚠ **Two cards deliberately price a shell and not an endpoint** — `FW-232` (handler is `FW-227`)
> and `FW-233` (order set is `FW-226`'s). Re-costing the endpoint bodies here would double-count
> two stories that are already in the baseline.
>
> **Sprint placement** is stated per card. `FW-241`–`FW-250` are 1C-residual and sit in the
> current sprint; Phase-4 work is `S2`; Phases 9/13/14 are `S3`.

---

###### FW-232 · `OrderController` — a host for `POST /order/{orderNo}/complete`
**Hours:** 3 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> `[API §4.21]` specifies `POST /order/{orderNo}/complete` and **`[API §3.1]`'s controller table
> has no `/order/**` owner** — it has had none since the endpoint was added on 22 Aug 2026 with the
> rod ↔ order allocation design. `P-50` built fifteen shells and **stopped deliberately**, raising
> the sixteenth rather than inventing it. This is that sixteenth.
>
> ⚠ **Shell, route and `[Authorize]` only. The handler is `FW-227` and is already costed** — its
> state machine, hub events 13/14 and two weight latches stay there. Building the body here would
> price one endpoint twice.

**Acceptance Criteria:**
- [ ] `OrderController : UAController` at the `/api/v1/flatwire` base, with the class-level base route and an explicit per-action route (`P-04`)
- [ ] `POST /order/{orderNo}/complete` routed and returning `FlatWireResult<T>` (`P-56`), **delegating to `FW-227`'s handler** — no logic in the controller (`[SVC §3.2]`)
- [ ] `[Authorize]` inherited from the global filter; the endpoint answers `401` unauthenticated like the other 22 (`FW-138` §6.2)
- [ ] ⚠ **`[API §3.1]` and `[API §3.2]` gain the controller and the endpoint row** — the count moves 22 → 23 and `[API]` is the file that says so, not this card
- [ ] Settled **before Phase 1A freezes its base-URL set**, which is what makes this High rather than Medium

**Rate-card basis:** **3 h**, quoted from [`FW-138`](../40-backend/tasks/FW-138.md) §8 and `P-50` — *"recommends `OrderController` as a sixteenth (**+3 h**)"*. ⚠ **Not a `[CE §2]` rate-card unit**: the card has no controller-shell row, and the command endpoint's 5 h is `FW-227`'s, not this story's
**Dependencies:** FW-138, FW-N04, **FW-227** *(handler)*
**Blockers:** ⚠ **`[API]` must mint the controller** in `[API §3.1]`. `P-50` is explicit that inventing it in a plan is what this story exists to avoid

---

###### FW-233 · A host for the `/rod/**` surface
**Hours:** 6 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> `P-53` withdrew `RodReceivingController` on 25 Aug 2026 — *"the service hosts no `/rod/**`
> surface"*, rod receiving not being shopfloor — and the withdrawal was right. What it left behind
> is not: **`[API §4.3]` and `[API §4.20]` remain specified with nowhere to go**, so `FR-042`,
> `FR-064`, `FR-043`'s carry-forward gate and `Q24`'s station switching have **no endpoint**, and
> `CoilCheckin`'s `getCheckinCoilInfo` covers only the shared-schema half. `[TRP]`'s DB2 is a trial
> screen that **scans a rod**.
>
> ⚠ **Shell and route wiring only.** `[API §4.20]`'s order set is `FW-226`'s and the check-in reads
> are their owning stories'. `P-54` names three options and the choice — **re-home or re-specify**
> — is `[API]`'s, not a plan's.

**Acceptance Criteria:**
- [ ] `[API]` records the `P-54` outcome first: re-home to a controller, fold into an existing one, or re-specify the two sections away
- [ ] If re-homed: a controller shell + routes for `[API §4.3]` and `[API §4.20]`, `FlatWireResult<T>`, `[Authorize]`, `401` unauthenticated — **no handler bodies**
- [ ] `FR-042`, `FR-064`, `FR-043`'s carry-forward gate and `Q24`'s station switching each name a reachable endpoint, or `[API]` records why they do not need one
- [ ] `[API §3.1]`/`§3.2` updated to match, and the endpoint count restated **there**
- [ ] ⚠ If `[API]` re-specifies instead, this story closes as a **specification change with no build** and its hours are released

**Rate-card basis:** 1 controller shell **3 h** (`FW-138` §8 basis, as `FW-232`) + route wiring for 3 endpoints ≈ **3 h** = **6 h**. ⚠ **No `[CE §2]` endpoint unit is priced here** — the bodies belong to `FW-226` and the check-in stories
**Dependencies:** FW-138, FW-N04, **FW-226** *(order set)*
**Blockers:** ⛔ **`P-54` is `open`** and this is blocked on `[API]`, not on code. It also reaches `[TRP]` — DB2 scans a rod

---

###### FW-234 · Audit-log persistence target
**Hours:** 12 h (BE 8 · DB 4) · **Priority:** High · **Sprint:** S1 · **Phase:** 1B/1C · **Stream:** BE + DB

> `FW-143` shipped `IAuditLog` + `SerilogAuditLog` and **AC 3 was met structurally, not
> materially** (`P-15`, the register's first `open` finding): the audit record goes to a Serilog
> sink that **nothing can query**. `[PLC §11]` expects a reviewer to read the PLC write trail,
> `FR-075` requires the operator on every write, and `FW-151`'s built `AuditEntry` already keys on
> **`RunAlpha` + `OperatorId`** — two query keys with no queryable store behind them. `P-112` had
> to smuggle a confirmation marker into the value *string* because the type has nowhere else to
> put it.

**Acceptance Criteria:**
- [ ] One table in `FlatWireDB` holding `AuditEntry` — at minimum `RunAlpha`, `OperatorId`, action, target, value, outcome, timestamp, correlation id — with indexes on the two documented query keys
- [ ] Added to the numbered DDL chain, **FKs in `06`, indexes in `07`**, and into `FlatWire_DDL_RunAll.sql` in numeric order
- [ ] ⚠ **`[DBD §6.2]`'s counted baseline moves** — that file states it and `verify_schema_counts.py` re-runs green; **this card states no count**
- [ ] `SerilogAuditLog` gains a persisting sibling (or a second sink) behind the **unchanged `IAuditLog` interface**, so no caller changes
- [ ] A query path exists for `[PLC §11.3]`'s reviewer — retrieval by `RunAlpha` and by `OperatorId`, through MediatR per `[SVC §3.2]`
- [ ] `FW-143` AC 3 re-run and signed off **materially**: write a PLC audit record, read it back
- [ ] ⚠ A write failure in the audit path **must not fail the command** — the same rule as `P-138`'s guarded replay

**Rate-card basis (§2):** 1 table @ 4 h (DB 4) · persisting `IAuditLog` implementation + query handler, priced as a small business service @ 8 h (BE 8) = **12 h**
**Dependencies:** FW-143, FW-142, FW-151, FW-007
**Blockers:** — *(`P-15` is the finding this closes, not a blocker on it)*

---

###### FW-235 · `CoilCompleted` broadcast member
**Hours:** 12 h (RT 8 · FE 4) · **Priority:** Medium · **Sprint:** S3 · **Phase:** 9 · **Stream:** RT + FE

> Found by writing `FW-208`'s handlers on 29 Aug 2026 (`P-137`): **`CoilCompleted` is raised,
> dispatched, and deliberately reaches no handler**, because `IFlatWireClient` has no member to
> send it on. `[SIG §5.2]`'s fourteen events and `[SIG §5.4]`'s six markers were counted member by
> member and **nothing carries a completed output coil**. All three alternatives lose: a
> neighbouring member would deliver a coil completion to a `RodCheckoutEvent` subscriber, and
> deleting the event hides the gap.
>
> ⚠ **The screens do not go dark today** — DB7 completes the coil through its own request/response,
> so the operator who did it sees the result. What is missing is the broadcast to the **other**
> clients on the line, **and whether that is wanted is the client's call** (`OI-140`).

**Acceptance Criteria:**
- [ ] `OI-140` answered by the client **first** — is a coil completion wanted on the other clients on the line?
- [ ] If yes: `[SIG §5.2]` gains the event, `IFlatWireClient` the member, `Models/RealTime/HubContracts.cs` the payload, `[SIG §5.6]` the Angular mirror and `FW-136` the client leg — ⚠ **in ONE pass**, because `P-22` mints the interface whole precisely so it is not widened piecemeal
- [ ] ⚠ **This is a BREAKING change under `[API §8]`** and must be recorded as one
- [ ] `FW-208`'s step-8 handler set goes from five broadcasts to six; the *"eight handlers"* figure is unchanged (six post-commit + two in-transaction)
- [ ] Payload carries what DB7's other viewers need — at least `lineId`, `runId`, coil alpha, weight and skid position — and follows `[SIG §5.4]`'s shared-base convention where it applies
- [ ] If the client says no: the event stays handler-less **by decision**, `P-137` is restated as settled, and this story closes at 0 h

**Rate-card basis (§2):** 1 new hub event (typed contract + publisher + subscriber) @ 8 h (RT 8) · Angular mirror + `FW-136` leg @ 4 h (FE 4) = **12 h**
**Dependencies:** FW-208, FW-080, FW-149, FW-136, FW-185
**Blockers:** ⛔ **`OI-140`** — open with the client. ⚠ `FW-136` does not exist as built code (`P-116`), so the client leg lands with it

---

###### FW-236 · Per-tag write status from `OPCConnection`
**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** BE

> ⛔ **`FR-074` — *"raise an exception when any individual tag write fails"* — is unimplementable
> from `OPCConnection`'s response, and that is a defect in another service** (`G58`). `WriteTag`
> returns **`200` with the tag list whatever happened**; `OPCTag.IsGood` is set by neither write
> path; `OPCUAManager.WriteTag` catches **every** exception — including its own *"Cannot write to
> tag"* — at `LogInformation`; and its verification at `OPCUAManager.cs:362` compares two freshly
> boxed `object`s with `==`, **reference equality, false for every numeric tag**, so the check
> always fails and is always swallowed. `OPCDAManager` verifies correctly but only logs a warning,
> **so the two managers disagree about what a `200` means** and `ConnectionType` decides which the
> caller gets.
>
> ⚠ `P-105`'s confirm read is the **workaround** and narrows the common case; per-tag status is the
> fix. ⚠ **This service sits on four other consumers' paths** — the change is theirs to accept.
>
> ⛔ **`G94` — added 4 Sep 2026, and it must land BEFORE the criteria above.** `OPCUAManager` has
> **no canonical tag identity**: `Subscribe` (`:247`) uses `ns=2;s=` via `GetOpcUaTagName()`, but
> `ReadTag` (`:207`) and `WriteTag` (`:359`) pass the **bare** name, which QuickOPC parses as
> namespace **0** — a different node; `GetSystemErrorTagValue` (`:554`) hand-builds the same literal
> a fifth time; and the notification handler (`:670`) publishes `NodeDescriptor.ToString()`, whose
> real output is the debug form `NodeId="ns=2;s=Tag"` — **verified by loading
> `OpcLabs.EasyOpcUAPrimitives.dll` 5.84.192**, and it parses back **without throwing** into
> namespace 0 with the whole literal as the identifier.
>
> ⛔ **The two gaps are entangled, and the order is not optional.** The `ns=0` write is a real
> reason `:362`'s check fails, and `G58`'s swallow is what has kept `G94` invisible. Lift the
> swallow first and every UA write reports a genuine-but-unexplained failure; fix the identity first
> and the writes land, so what surfaces afterwards is real.
>
> ⚠ **`G94` is LATENT, and measured so rather than assumed** — 4 Sep 2026 on `DEV00164-001`, all
> four `CommonDB.OPCModules` rows are `21316` (`OPCDA`), so `OPCUAManager` is selected by nothing
> and none of this executes today; 0 of 496 `CommonDB.OPCTags` rows carry a prefix, so there is no
> config to migrate. It bites on the first module set to `21317`, and `D-44` puts the 72 flat wire
> tag paths into that same registration.

**Acceptance Criteria:**
- [ ] `WriteTag`'s response carries a **per-tag outcome**, not a bare tag echo — at minimum written / refused / faulted, with a reason
- [ ] `OPCTag.IsGood` is set by **both** managers, or the field is removed and replaced by the per-tag outcome
- [ ] ⛔ `OPCUAManager.cs:362`'s reference-equality verification is corrected to `.Equals` (as `OPCDAManager` already does), and the result **is no longer swallowed**
- [ ] Exceptions in the write path stop being logged at `LogInformation` and surface to the caller
- [ ] ⚠ **The four existing consumers are identified and regression-tested** before the shape changes — this is the acceptance gate, not an afterthought
- [ ] `FW-151`'s `PLCTagService` consumes the per-tag outcome and `FR-074` becomes implementable; `P-105`'s confirm read may then be reduced to a commissioning check
- [ ] ⚠ **`G33` is NOT closed by this** — a wrong tag path can read back consistently wrong (`[PLC §10.3]`)
- [ ] ⛔ **`G94` first — canonicalise tag identity BEFORE lifting the swallow above.** Bare `TagName` is the domain and wire identity; the `ns=2;s=` node-id form is applied only at the QuickOPC boundary
- [ ] `ReadTag` (`:207`) and `WriteTag` (`:359`) address namespace **2**, not **0**; `:554`'s duplicated literal is collapsed to the shared formatter; and `UpdateOPCInfoTags` (`:702`) matches case-insensitively, per `OPCTag`'s own `Equals` (`OPCTag.cs:125-175`)
- [ ] Notifications correlate on the **`object state`** overload of `SubscribeDataChange` — it exists in the pinned 5.84.192 and `e.Arguments.State` reads it back — and **never** on `NodeDescriptor.ToString()`
- [ ] ⚠ **`OPCConnection` gets its first unit tests, and a seam is required to have them**: `Read`, `WriteValue` and `SubscribeDataChange` are **extension methods** on `IEasyUAClient` (which declares only `ReadMultiple` / `WriteMultiple` / `SubscribeMultipleMonitoredItems`), so `Mock<IEasyUAClient>` cannot intercept them and a narrow first-party adapter is the only route to a test
- [ ] ⚠ **`:554` is treated as its own commit** — it is the connectivity probe, and `CheckConnectivityAndChannelStatus:152` turns a false negative into operations email plus a server failover
- [ ] ⚠ **`DefaultNamespaceIndex = 2` is a compile-time constant** (`OPCTag.cs:14`) and no repository can prove every deployed server exposes tags there — either make it per-`OPCServer` configuration or record the follow-up; only `[PLC]`'s `C1`/`C11` settle it

**Rate-card basis (§2):** non-trivial change to an existing integration service, at the upper half of the 12–24 h band because it is cross-consumer and needs regression on four callers = **16 h**
**⚠ Hours NOT re-derived.** `G94` adds five call sites, a client seam and the service's first test
project to a card priced at 16 h for the write-status change alone. The figure is left at **16 h
deliberately**: the `Hours` cell is parsed into three client `.xlsx` generators and the capacity
totals are quoted in ~20 files, so a re-price belongs in an additive pass that owns the arithmetic,
not in this edit.
**Dependencies:** FW-151
**Blockers:** ⚠ **Owned by `OPCConnection`, not by FlatWire.** Needs that service's owner to accept a response-shape change

---

###### FW-237 · Service identity for unattended PLC writes
**Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> `G59`'s **identity half**, which `P-127` split out precisely because reading the gap as one item
> gets the near half missed. The `Attempted` audit record is written **before** the simulate branch
> (`[PLC §11.1]` audits simulated writes) and `AuditEntry.OperatorId` is **required**, so the first
> tag set cannot be written without an answer — **in every environment, today**. `FW-205` shipped a
> named sentinel (`SystemOperatorId`) and **documented it as a sentinel** rather than pretending it
> was a decision.
>
> ⚠ **`CoolingChamber` logs in by badge number; nothing owns that decision for FlatWire.** The
> token half stays with commissioning: `PLCTagService`'s simulate branch returns before
> `GetOPCInfo`, so nothing reaches the network until `SimulatePLCTagPush` goes false.

**Acceptance Criteria:**
- [ ] A named service identity exists for writes no operator initiated — the watchdog's `SetITInhibit`, hold/idle-and-restore, and any future hosted-service write
- [ ] The sentinel `SystemOperatorId` in `FW-205` is **replaced**, and the code that documented it as a sentinel is updated so the trail no longer carries a placeholder
- [ ] The audit trail attributes those writes to that identity and a reviewer can tell them from an operator's (`[PLC §11.3]`, the same reasoning as `P-110`'s `Compensate:` label)
- [ ] ⚠ **The token half is explicitly out of scope and stays with `G59`/commissioning** — `RestClient` reads its bearer from `HttpContext`, and a hosted service has none (`P-120`)
- [ ] The failure mode is documented: with no identity the call fails **before the network**, in-band, as `"Object reference not set to an instance of an object."` — a message naming neither the identity nor the caller

**Rate-card basis (§2):** non-trivial business/integration service at the low end of the 12–24 h band — a service credential, its issuance and its wiring through `IAuditLog` and `PLCTagService` = **12 h**
**Dependencies:** FW-143, FW-151, FW-205, FW-234
**Blockers:** ⚠ Needs a decision from whoever owns service credentials in the UAL estate — `Login`'s badge-number route is the precedent, not a specification

---

###### FW-238 · Register flat wire with `OPCConnection`
**Hours:** 12 h (BE 4 · DB 8) · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** BE + DB

> ⛔ **`G60` — nothing registers flat wire with `OPCConnection`, so `GetOPCInfo` cannot succeed and
> no tag can ever be written.** Two halves are missing: `UAL.Constants.GlobalConstants.OPCModules`
> has five members and **no flat wire one**, while `GetConfigurationsQueryValidator` requires one;
> and `CommonDB` has no flat wire rows in `OPCModules` / `OPCServers` / `OPCTags` /
> `OPCTagApplicationMapping`. `MachineId`, `OPCServers`, `ConnectionType` and `IsReadonly` are
> `CommonDB` state and **cannot be hand-built** (`P-104`).
>
> ⚠ **Not a build blocker today** — simulate short-circuits before the resolve, and `FW-N05` and
> `FW-151` both reproduce `G60` by name at boot and stay up. But the resolve-and-write path is
> **dead code until this lands**.
>
> ✅ **`OI-A` is decided — `D-44`, 4 Sep 2026: tag paths live in the `CommonDB` registration.**
> ✅ **`G93` IS WITHDRAWN — `D-45`, 5 Sep 2026.** No `TagKey` column, no shared `ALTER`, no other
> team. Flat wire registers as `TagName` only and `appsettings` stays the resolution map, which
> is what the ecosystem does anyway. ⛔ **Two different blockers replace it:** `G94` — flat wire
> is the **first module to select `ual-api`'s `OPCUAManager`**, so `FW-236`'s identity fix must
> merge or writes land in namespace 0; and `G100` — the target `CommonDB` was behind source
> control, so the script died at its first insert. ✅ **`G100`'s blocking half is CLOSED**, 5 Sep
> 2026 — `dbo.OPCModules` on `DEV00164-001` now carries all six columns (`08_`) and `11_` §4a binds
> clean, which leaves `G94` as the only blocker.
>
> ✅ **`G97` is RESOLVED — `D-49`, 5 Sep 2026.** The lines use the OPC UA endpoint pair at
> `OPCServersIdx` **1 and 2**, both lines onto both, so the script carries no placeholder.

**Acceptance Criteria:**
- [ ] ~~A flat wire member added to `UAL.Constants.GlobalConstants.OPCModules`~~ — **struck 5 Sep 2026.** No FlatWire code evaluates the enum; `ResolveOpcInfoAsync` sends `options.OpcModuleId`, a config int. Worth adding `Slitter = 5` and `FlatWire = 6` so the enum stops lying, but it **gates nothing**
- [ ] `CommonDB` rows for **FL1 and FL2 only** in `OPCModules`, `OPCServers`, `OPCServerApplicationMapping`, `OPCTags` and `OPCTagApplicationMapping`, as a **numbered, reversible script** in `Database/Scripts/`
- [ ] **41 `OPCTags` rows**: 39 data (FL1 17 · FL2 22) + **2 system-error** (`G95` — without them `GetOPCInfo` returns an empty list and the whole line is invisible). ⚠ Do **not** reconcile 41 against `FW-144 §8.2`'s **72 bound paths**: both are correct and count different things
- [ ] ⛔ **FL3 (machine 127) is NOT registered** — `D-47`/`G99`. It has no controller of its own, so its tags *are* FL1's and FL2's, and `GetOPCInfo` answering empty for FL3 is **correct**
- [ ] **`OPCModuleId = 6`** with `SET IDENTITY_INSERT` and a pre-flight abort — **not `5`**, which the six slitters use in production though the enum stops at 4 (`G96`); **`ConnectionType = 21317`**, and `IsReadOnly`/`OPCEventType`/`EventDurationSeconds` all non-NULL or `GetOPCInfo` throws
- [ ] Paths stored **bare** and in the `.PLC.` form (`D-46`), and the 39 data paths **equal** FL1's and FL2's `appsettings` values exactly — the `[DEP §5]` config-vs-rows diff
- [ ] ~~`G93` must land first — ship the column before the rows~~ — **struck: `G93` is withdrawn (`D-45`).**
- [ ] ~~`ConfigurationTagPathResolver` replaced by a `CommonDbTagPathResolver`~~ — **struck by `D-45`.** Without a logical-name column nothing in the table can resolve a logical name, so the resolver stays as built and `FW-151` keeps overwriting `GetOPCInfo`'s `Tags`
- [ ] `appsettings` keeps `SimulatePLCTagPush`, `PublishIntervalMs`, per-line `LineStateMap` and the SignalR block, and holds **no tag path** (`[PLCC §2]`)
- [ ] Sequenced with `FW-241`: both write shared reference data, and the `machines` rows `FW-003` creates are what an OPC registration keys on
- [ ] `GetOPCInfo` returns a usable `OPCInfo` for each line, verified against the real service — this is what retires `G60` in `FW-151`'s and `FW-N05`'s boot logs
- [ ] ⚠ `G33` and `G32` still have to be settled in the same commissioning window; this story does not close them

**Rate-card basis (§2):** constants + validator change (BE 4) · four-table shared registration script with a reverse script, priced as a stored-proc-class deliverable @ 8 h (DB 8) = **12 h**
**Dependencies:** FW-003, FW-144, FW-151, FW-241
**Blockers:** ✅ **`OI-A` decided (`D-44`) and `G93` WITHDRAWN (`D-45`)** — no shared-schema change, no other team. ⛔ **`G94`** — `FW-236`'s OPC UA identity fix must merge before a `21317` module is activated. ✅ **`G100` cleared on `DEV00164-001`** (5 Sep 2026, `08_`) — it no longer stops the script; it stays Open on the stale `GetOPCServerAndTagDetails`, which does not block this story. ✅ **`G97` resolved (`D-49`)** · shared reference-data sign-off, as for `FW-241`

---

###### FW-239 · Wire run-lifecycle invalidation into `FW-150`'s per-run cache
**Hours:** 4 h RT · **Priority:** High · **Sprint:** S1 · **Phase:** 1B · **Stream:** RT

> `FW-150` shipped 29 Aug 2026 with **one loose end, named on the build**: `FW-208`'s run-lifecycle
> invalidation is not wired. `P-125` caches `RunId`, `InSpec`'s band, `PercentRemaining`'s
> denominator and the `FR-018` recording spacing **once per run**, because built naively each is a
> database read inside a 10 Hz loop. It also **corrected itself before execution**: invalidating on
> `LineStatus` would never fire, since `TryMapLineState` returns `false` until commissioning test
> `C2`.
>
> ⛔ **Left unwired, readings are attributed to a finished run** — the gauge trace and `RunReading`
> keep writing against the previous `RunId` after a run ends.

**Acceptance Criteria:**
- [ ] The per-run cache invalidates on the run's **lifecycle domain events**, dispatched by `FW-208`, not on `LineStatus`
- [ ] `PayoffStateChanged` invalidates the per-rod half (`PercentRemaining`'s denominator)
- [ ] A run ending and a new run starting on the same line is demonstrated: the first reading after the boundary carries the **new** `RunId` and the **new** band
- [ ] ⚠ **`RunReading` stays out of the EF model** (`P-12`, `P-125`) — the loop inserts by raw SQL and must never gain a navigation collection
- [ ] The invalidation runs on the broadcaster's singleton lifetime without opening a scope on the hot path (`P-131`'s rule)

**Rate-card basis (§2):** below the smallest service band — an event subscription and a cache eviction on an existing structure, no new contract = **4 h**
**Dependencies:** FW-150, FW-208
**Blockers:** —

---

###### FW-240 · `RodOrderAllocation` / `RodOrderConsumption` domain entities
**Hours:** 8 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> `P-91`'s second half. `FW-207` placed the five tables deployed 22 Aug 2026 that no aggregate map
> had claimed, and **deliberately did not build these two**, because they sit **outside the seven
> roots** and `RodOrderConsumption` has **five parents spanning three aggregates** — a boundary
> call that is `[SVC §3.2a]`'s to sign, not a plan's.
>
> Verified absent from the built code on 29 Aug 2026: neither name appears in
> `FlatWire.Domain/AggregatesModel/` nor in `FlatWire.Infrastructure/EntityConfigurations/`.

**Acceptance Criteria:**
- [ ] `[SVC §3.2a]` signs the boundary first — which aggregate owns each, or whether they are read models
- [ ] Entity types + EF configurations for both, mapped against live `FlatWireDB` and verified **by column count**, not by inspection (`P-70`'s lesson: nine `ALTER`-added columns are invisible to a `CREATE TABLE` read)
- [ ] ⚠ **`RodOrderConsumption` carries a `ROWVERSION` that must be mapped as the entity lands** (`P-69` — one of the two tokens `[SVC §3.4]` does not list)
- [ ] The model still validates and `FW-207`'s harness stays green at its current count
- [ ] `FR-541`–`FR-560` / `ORD003`–`ORD017` reach a mapped type, and `FW-225`/`FW-226`/`FW-227` can bind to them

**Rate-card basis (§2):** 2 tables @ 4 h — the DDL exists, so this is the EF mapping and boundary half of the unit = **8 h**
**Dependencies:** FW-207, FW-142, FW-225
**Blockers:** ⛔ **`[SVC §3.2a]`'s signature** — `P-91` is `⚠ ratify` and this is the half it gates

---

###### FW-241 · Deploy step 2 — finalise the shared-schema insert, author its reverse script, run it under sign-off
**Hours:** 8 h DB · **Priority:** Critical · **Sprint:** S1 · **Phase:** 1C · **Stream:** DB

> ⛔ **`[DEP §4.2]` step 2 is the only irreversible step in the ten-step deploy chain, and it is the
> one that has never run.** `10_CommonDB_Insert_WIPStations_FlatWire.sql` writes
> `united_db..machines` and `CommonDB..WIPStations` / `MachineStationsConfiguration`; it is
> **Draft**, `machine_type`, the station set and `StationType` are all pending, **no reverse script
> exists**, and the `Scripts/` runner **deliberately skips it**. So FL1/FL2/FL3 exist in neither
> shared table.
>
> ⚠ **`FW-220` names this script as a dependency**, which means the FL1/FL3 check-in write-back —
> and with it `FW-221`, `FW-223` and `FW-003` — is waiting on **an approval, not on code**. The
> code half of this story is the reverse script that does not exist.

**Acceptance Criteria:**
- [ ] `machine_type`, the station set and `StationType` decided and recorded in `[DEP §4.2]` step 2, which is the record
- [ ] ⛔ **A reverse script authored, numbered and tested** — teardown of the `machines`, `WIPStations` and `MachineStationsConfiguration` rows, so the step stops being one-way
- [ ] ⚠ **`G21`'s absent `FL3PO` station is deliberate and must stay absent** — FL1 and FL3 share one physical payoff, `STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"}`, client-confirmed (`Q71`). Adding it would break the bay-uniqueness fix
- [ ] Run **by hand, after sign-off**, on each environment; the `Scripts/` runner continues to skip it and `Scripts/README.md` continues to say so
- [ ] `FW-003`'s `machines` rows and this script agree on one set of values, since an OPC registration (`FW-238`) keys on them
- [ ] Sign-off state recorded in `[DEP §4.2]` and in `Scripts/README.md`'s manifest

**Rate-card basis (§2):** reverse script authored and tested, priced at the stored-proc / script unit @ 8 h. **The approval itself carries no hours** = **8 h**
**Dependencies:** FW-152, FW-003
**Blockers:** 🔴 **Shared reference-data sign-off** — not a register id and not a gap, an **approval**, owned by whoever signs off shared reference data

---

###### FW-242 · Move `FlatWireDB` into the `ual-database` repository
**Hours:** 16 h DB · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** DB

> Checked 27 Aug 2026 and again 29 Aug: `Second-Branch/ual-database/Databases/` holds **twenty
> databases** — `CommonDB`, `PlanningDB`, `SchedulingDB`, `SlitterDB`, `proddb` and the rest — and
> **no `FlatWireDB`, and no file matching `*flatwire*` anywhere in that repository.**
>
> ⛔ **The deployable source of truth for a production database therefore lives only in a
> *planning* repo**, which is why `[DEP §4.2]`'s command has to `cd` into `Flatwire-planning`.
> **No document owns the move**, and it has to happen before go-live.

**Acceptance Criteria:**
- [ ] A `FlatWireDB` folder in `ual-database/Databases/`, following the convention the other twenty use
- [ ] The whole `00`–`08` chain, `FlatWire_DDL_RunAll.sql`, `99` teardown, the five seeds, the eight `Scripts/` files and `09_Programmability_MVP2` moved or mirrored, **with the numeric order and the `:r` chain intact**
- [ ] ⚠ **One source of truth, not two** — the planning repo either keeps the design documents and drops the executable DDL, or the two are linked with the direction of authority written down. Two copies of a schema is the failure mode this repository already documents six times over for PLC tags
- [ ] `[DEP §4.2]`'s deploy commands retargeted and re-run end to end on a clean instance
- [ ] `verify_schema_counts.py` runs against the new location and passes all six checks
- [ ] `[DBD]`, `Schema/SQL/README.md`, `Scripts/README.md` and `CLAUDE.md` updated to name the new home

**Rate-card basis (§2):** not a rate-card unit — a repository migration of 40+ files with a re-verified deploy, priced as two stored-proc-class deliverables = **16 h**
**Dependencies:** FW-152, FW-241
**Blockers:** ⚠ Needs the `ual-database` repository owner's agreement on folder convention and branch strategy

---

###### FW-243 · `D-30` — `ROWVERSION` on `WeldEvent`, `RodCheckout`, `WipRejection`
**Hours:** 6 h (DB 4 · BE 2) · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB + BE

> ⚠ **`D-30` is open and gates the Phase-4 schema freeze.** `ROWVERSION` is absent on three of the
> **seven aggregate roots**, and all three are **mutated after insert** — a weld is quality-stamped,
> a checkout is completed, a rejection is dispositioned. `P-14` and `P-24` are explicitly *interim*
> stances, and `P-69` maps all eight tokens that **do** exist while saying in terms that it does
> **not** decide whether these three should.
>
> ⚠ Without them `DbUpdateConcurrencyException` never fires on those three, so `FW-146`'s `409` arm
> guards nothing there — a lost update is silent.

**Acceptance Criteria:**
- [ ] `[SVC §3.4]` decides — **the decision is the gate, not the DDL**
- [ ] If yes: `ROWVERSION` added to the three tables by `ALTER` in the Runs / Quality-Output DDL, guarded so `RunAll` stays idempotent
- [ ] Mapped as concurrency tokens in their EF configurations, taking `P-69`'s mapped count from eight to eleven
- [ ] A concurrent-update test on each of the three returns `409` through `FW-146`'s third arm, not a silent overwrite
- [ ] ⚠ **`P-70`'s rule applies** — the columns are `ALTER`-added, so anything reading `CREATE TABLE` alone will miss them
- [ ] If no: `[SVC §3.4]` records why, `P-14`/`P-24` are restated as settled, and the story closes at 0 h

**Rate-card basis (§2):** 3 `ALTER`-added columns with guards, below one table unit (DB 4) · 3 EF concurrency-token mappings and the test (BE 2) = **6 h**
**Dependencies:** FW-007, FW-142, FW-207
**Blockers:** 🔴 **`D-30`** — `[SVC §3.4]`'s call, **before the Phase-4 schema freeze**

---

###### FW-244 · `G49` — nine decided requirements with no column
**Hours:** 8 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** 1C · **Stream:** DB

> Nine requirements that **survived client review and are stated in an owning specification** have
> nowhere in the schema to store their result. Carried over from the retired `GapAnalysis.md`
> (findings **B1**–**B9**); the affected screens are **`OutputCoilCompletion`** (DB7/DB7b),
> **`RollAdjust`** (DB11), **`WipRejection`** (DB8) and **`SpoolCompletionNotification`**.
>
> ⚠ **Raised as ONE gap on purpose, and it must be built as one delta.** Nine separate rows would
> be triaged independently and half-forgotten; they share a cause — requirements written against
> screens rather than against tables — and a remedy.

**Acceptance Criteria:**
- [ ] All nine enumerated from `[GAP] G49` with their owning requirement id and screen, **before** any DDL is written
- [ ] One schema delta covering all nine, in the right numbered files, **FKs in `06` and indexes in `07`**, idempotent under `RunAll`
- [ ] Each column reaches its owning specification's requirement — the acceptance is *"the requirement can now be stored"*, not *"a column exists"*
- [ ] `Schema/FlatWireSchema_*.md` updated to match the DDL, with **the DDL winning** on types and nullability
- [ ] ⚠ **`[DBD §6.2]`'s baseline moves and that file states it** — this card states no count; `verify_schema_counts.py` re-runs green
- [ ] The four owning screen specifications record that their requirements now have a persistence target

**Rate-card basis (§2):** priced as two table units @ 4 h — nine columns across four existing tables plus their indexes and document sync = **8 h**
**Dependencies:** FW-007, FW-006
**Blockers:** —

---

###### FW-245 · `G51` — `SpcMeasurement.InSpec` stores a wrong verdict for an asymmetric band
**Hours:** 6 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** 1C · **Stream:** DB

> The column is `AS (CASE WHEN ABS([ActualValue] - [TargetValue]) <= [ToleranceValue] … END)
> **PERSISTED**` — a **single symmetric** tolerance — while `AlloyProperty` has carried **min/max
> pairs** for gauge, width and diameter since 1 Aug 2026 (`Q22`).
>
> ⛔ **An asymmetric band is collapsed to one number and the verdict is *written*, not merely
> computed.** A measurement inside an asymmetric band can be persisted as out-of-spec, or outside
> it as in-spec, and because the column is `PERSISTED` the wrong verdict is **stored and read back**
> by SPC reporting. `P-125` independently flags the sibling hazard: `BIT NOT NULL DEFAULT (1)`
> means an omitted value **claims in-spec**.

**Acceptance Criteria:**
- [ ] The computed expression evaluates against the **min/max pair**, not a single symmetric tolerance, falling back to the symmetric form only where no pair exists
- [ ] ⛔ **Existing rows re-evaluated**, not just the expression changed — a `PERSISTED` column means the wrong answers are already on disk
- [ ] Where the band cannot be resolved the row is **not** silently marked in-spec — `P-125`'s rule for `RunReading` applies here for the same reason
- [ ] `TC-020`-style verification that the C# tolerance logic, the DDL expression and `AlloyProperty`'s seeded pairs agree
- [ ] ⚠ **`Q22` is still open** — the four min/max pairs are owed by e-mail and `AlloyProperty` is **deliberately unseeded**, so this ships correct-and-unexercised until they land. **Do not seed placeholder pairs to make a test pass**

**Rate-card basis (§2):** one computed-column redefinition with a data re-evaluation pass and its verification, between one and two table units = **6 h**
**Dependencies:** FW-004, FW-007, FW-168
**Blockers:** ⚠ **`Q22`** — the tolerance pairs are owed by the client; the fix is buildable without them, the demonstration is not

---

###### FW-246 · `G50` / `G52` / `G41` / `G55` — constraint and referential-integrity repairs
**Hours:** 12 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** 1C/4 · **Stream:** DB

> Four gaps, grouped because each is a `CHECK` or an FK on the same schema and they would otherwise
> be triaged one at a time:
>
> - **`G50`** — three referential-integrity holes: `AlloyProperty` is **orphaned on the material side** (`Rod.Alloy` and `FlatWireRun.Alloy` are free `varchar` with no FK, so a typo on a rod is unconstrained); the payoff position is modelled **two ways**, some tables FK'd and some carrying a bare integer; `PassScheduleComponent.ComponentName` is an **enumerating `CHECK` rather than a reference**.
> - **`G52`** — `PinRole='Sole'` **passes the `CHECK` and matches none of the sequence validator's four tiers**, so `minTier` is undefined over a `Sole` row while `FR-546` requires an out-of-tier rod to be refused. ⚠ `PinnedBoth` is fine — it is explicitly a member of both sets.
> - **`G41`** — `CK_PSC_FM1NotBypassable` is **line-blind**, so **a correct FL2 pass schedule cannot be authored**: an FL2-standalone run is fed an already-flattened spool and FL1's 12″ mill is not in its material path, yet every FL2 schedule must mark `FM1` Active.
> - **`G55`** — `CK_SpoolCheckin_PayoffPos` pins FL2's spool to payoff **`1`** while `CanonicalEnums.cs` and the seeded `PayoffPosition` row both make it **`3` (`TraversingTakeup`)**. ⚠ **On a column with no FK, so `TC-020`'s membership diff passes** — the disagreement is about *meaning*.

**Acceptance Criteria:**
- [ ] `G41`: the constraint becomes line-aware so an FL2 schedule can be authored. ⚠ **Do not generalise into *"a component's `Stand.LineId` must equal its schedule's `LineId`"*** — `[GAP]` forbids it explicitly
- [ ] `G55`: FL2's payoff settled at one value across the `CHECK`, `CanonicalEnums.cs` and the `PayoffPosition` seed — *"FL2 has ONE payoff"* is true and is **not** the same claim as *which one*
- [ ] `G52`: `Sole` either joins a tier in `RodOrderAllocation.md` §3's partition or leaves the `CHECK`; `FR-546`'s refusal is demonstrable at both stations
- [ ] `G50`: the three holes closed — alloy FK'd on the material side, payoff position modelled one way, `ComponentName` referencing the vocabulary
- [ ] Each change guarded so `RunAll` stays idempotent, with FKs in `06` and indexes in `07`
- [ ] `Schema/FlatWireSchema_*.md` and `CanonicalEnums.cs` re-synced, and `TC-020` re-run **per leg** (`P-84`)

**Rate-card basis (§2):** four constraint/FK repairs across six tables with re-seeding and enum re-sync, priced as three table units = **12 h**
**Dependencies:** FW-005, FW-006, FW-007, FW-147, FW-225
**Blockers:** ⚠ `G55` needs the client's FL2 payoff answer, or an internal decision recorded as one

---

###### FW-247 · `G8` — legacy `FlatLineSetup` / `FlatLineProcessing` data migration
**Hours:** 32 h (DB 24 · BA 8) · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13/14 · **Stream:** DB + BA

> There is **no data-migration deliverable** for the legacy `FlatLineSetup` / `FlatLineProcessing`
> tables, so legacy data is stranded on drop.
>
> ⚠ **The destination is no longer the blocker** — `D-31` made `PassScheduleComponent` an MVP-1
> target on 15 Aug 2026, so there is somewhere for the setup data to land. **The missing migration
> is.**

**Acceptance Criteria:**
- [ ] A column-level mapping from both legacy tables to their `FlatWireDB` destinations, authored as a document before any script
- [ ] A migration script, numbered and **reversible**, in `30-database/scripts/`
- [ ] A validation pass — row counts, spot reconciliation, and a named list of rows that **cannot** be mapped, with the reason
- [ ] **Drop criteria** stated: what must be true before the legacy tables are retired, and who signs it
- [ ] ⚠ **MVP-1 reads pass schedules and never authors them** (`OI-110`, `P-13`) — migrating setup data into `PassScheduleComponent` does not create a write path, and this story must not add one
- [ ] Run on a copy first; the production run is gated behind the same sign-off class as `FW-241`

**Rate-card basis (§2):** mapping + migration + validation + drop-criteria, three script-class deliverables @ 8 h (DB 24) · the legacy-schema analysis that has to precede them (BA 8) = **32 h**
**Dependencies:** FW-005, FW-006, FW-152
**Blockers:** ⚠ Needs access to the legacy `FlatLineSetup` / `FlatLineProcessing` data and an owner for the drop decision

---

###### FW-248 · Harden `verify_schema_counts.py`'s `C6`, and repair the two count sites it cannot see
**Hours:** 8 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** 1C · **Stream:** DB

> ⛔ **The schema-count guard has a blind spot, and it is the exact class of drift the guard exists
> to stop.** `[DBD §6.2]` — **the document that defines the baseline** — contradicts itself: it
> states the current index figure after `Q89` added `UX_CoilTraceability_ChildAlpha` on 26 Aug 2026,
> while an earlier paragraph **in the same file** still carries the previous one. And
> `ProjectPlan/README.md` restates the baseline at all, which it **is not one of the three permitted
> sites** to do, and restates it stale.
>
> ⛔ **`C6` reported zero disagreeing claims in permitted sites and zero advisory elsewhere on the
> same run.** That matters because `C6` exists precisely so *"the number in the document cannot
> drift away from the scripts again"* — and `[DEP §4.2]`'s gate has already rejected a correct
> deployment **five times** on exactly this.

**Acceptance Criteria:**
- [ ] `C6` scans **every** count-shaped claim in `[DBD §6.2]`'s own file, not only the defining sentence — the self-contradiction is caught
- [ ] `C6` flags a restatement in **any non-permitted site** as advisory, `ProjectPlan/README.md` included; the three permitted sites stay permitted
- [ ] Both live contradictions repaired: `[DBD §6.2]`'s stale paragraph, and `README.md`'s restatement **removed rather than corrected** — it is not permitted to carry one
- [ ] A regression fixture: a file with a deliberately stale count is detected by `C6`
- [ ] ⚠ **This story states no count itself**, and neither does its test fixture's documentation. `[DBD §6.2]` is the only site that defines the baseline
- [ ] All six checks green on a clean run afterwards

**Rate-card basis (§2):** not a rate-card unit — a tooling change with a regression fixture plus two document repairs, priced at one script-class deliverable = **8 h**
**Dependencies:** FW-152
**Blockers:** —

---

###### FW-249 · Re-derive the DB-stream total on the current basis
**Hours:** 8 h BA · **Priority:** Medium · **Sprint:** S1 · **Phase:** — · **Stream:** BA

> **No current DB-stream total is published anywhere.** `[TB §7.3]`'s DB column is on the
> **pre-`D-32`** Phase-1C basis, and its 119-story scope **excludes `FW-219`–`FW-231` entirely** —
> its Phase-4 DB cell is `FW-159` alone, so `FW-220` (DB 24), `FW-221` (9), `FW-222` (2), `FW-223`
> (DB 10) and `FW-225` (DB 12) are in none of it. `[CE §8]` separately records that 1C was costed
> against 22 tables and the build is larger.
>
> ⚠ **`[CE]` owns the figure, and this is why the total was not re-derived in the orchestration
> files:** effort figures propagate to roughly twenty files, and `[CE §8]` is explicit that
> substituting a number into a derivation without re-deriving it *"makes the arithmetic lie"*.

**Acceptance Criteria:**
- [ ] A DB-stream total derived from the **current** story set — post-`D-32` 1C, the 33-table build, and `FW-219`–`FW-231` included
- [ ] ⛔ **Published in an ADDITIVE new sheet or section**, never by substituting into `[CE §3]`, `§3b`, `§3c` or `[TB §7.3]`'s existing arithmetic
- [ ] The `FW-232`–`FW-249` additive set is shown **separately** and is not folded into the MVP-1 baseline
- [ ] Every figure it supersedes is named, with the section that carries it, so a reader knows which of `[CE §3]`'s three 1C figures to cite
- [ ] ⚠ **`[CE §8]`'s known 1C understatement is carried forward, not silently absorbed**
- [ ] The 114-story / 3,186 h baseline is **unchanged** by this exercise, or the change is called out as a re-baseline in its own right

**Rate-card basis (§2):** not a rate-card unit — an estimation pass across `[TB §7]`'s DB cells and `[CE]`'s three 1C bases, priced at one BA deliverable = **8 h**
**Dependencies:** — *(reads `[TB §7]` and `[CE]`; blocks no build)*
**Blockers:** —

---

###### FW-250 · `build_development_plan_xlsx.py` silently drops every multi-stream story
**Hours:** 6 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** — · **Stream:** DB

> ⛔ **Found on 29 Aug 2026 by running the generator, not by reading it.** The work-item parser
> reads a story's streams with `re.finditer(r'(\d+)\s*h\s*([A-Z]{2})', hrs)` — `<digits> h <two
> capitals>` — which matches `3 h BE` and **cannot match the parenthesised multi-stream form**
> `40 h (DB 26 · BE 14)`, because the character after `h ` is `(`. When nothing matches, the code
> does `if not streams: continue` — **a silent skip, with no warning and no error.**
>
> ⛔ **Eleven stories are missing from the client-facing `FlatWire_DevelopmentPlan.xlsx` today**, and
> the list is not marginal: **`FW-202`** (FL1 spool completion, 98 h — written in a third format,
> `98 h — FE 32 · BE 42 · DB 8 · RT 16`), **`FW-219`** (the FL2/FL3 run-end shared write-back, 40 h),
> **`FW-220`**, **`FW-223`**, and the **whole `FW-225`–`FW-231` rod ↔ order allocation set**. They
> are absent from the work-item sheet, from every effort roll-up, and — because they were never
> parsed — **from the *"excluded from plan"* line that is supposed to name what was left out.**
>
> ⚠ **The parenthesised form is the repository's convention, not an error** — it is what
> `[TB §7.1]`'s own multi-stream cards use, so this is a defect in the reader. ⚠ **The `FW-232`–
> `FW-249` set inherits it**: five of those cards (`FW-234`, `FW-235`, `FW-238`, `FW-243`,
> `FW-247`) are dropped the same way, which is how the defect surfaced.
>
> ⚠ **`BA`-only stories are a DIFFERENT case and must stay excluded** — the parser's docstring is
> explicit that QA- and BA-only stories *"are not development work and are excluded here rather
> than silently absorbed"*. `FW-249` (8 h BA) is correctly out. **Do not fix this by widening
> `DISCIPLINE`.**

**Acceptance Criteria:**
- [ ] The stream parser reads all three hours formats in use: `N h XX`, `N h (XX a · YY b)` and `N h — XX a · YY b · …` (`FW-202`'s)
- [ ] ⛔ **A card whose hours parse to no development stream FAILS the build**, or is named in a warning — never `continue`d silently. The silent skip is the defect; a wider regex alone would leave the next format to fail the same way
- [ ] `BA`- and `QA`-only stories stay excluded **by a deliberate branch that says so**, distinguishable in the output from a parse failure
- [ ] The eleven pre-existing stories appear in the work items sheet and in the effort roll-ups, and the *"excluded from plan"* line becomes trustworthy
- [ ] ⚠ **The deliverable's effort totals will move when this lands** — roughly 250 h of already-baselined work becomes visible. **That is a correction, not new scope**, and the regenerated `.xlsx` must be reviewed before it is shared
- [ ] `build_trial_run_xlsx.py` and `build_coverage_matrix.py` checked for the same pattern — all three parse `[TB §7]`

**Rate-card basis (§2):** not a rate-card unit — a parser fix plus a fail-loudly guard and a regression check across three generators, below one script-class deliverable = **6 h**
**Dependencies:** —
**Blockers:** — *(the fix is unblocked; only the regenerated deliverable needs a reviewer)*

---

> **Additive-set reconciliation** — BE `3+6+8+16+12+4+8+2 = 59` · RT `8+4 = 12` · DB
> `4+8+8+16+4+8+6+12+24+8+6 = 104` · FE 4 · BA 16 = **195 h dev** across **nineteen**
> stories. *(`FW-250` was minted on 29 Aug 2026 during this set's own verification run, which
> is how its subject was found — 187 h / 18 stories until then.)*
>
> ⚠ **No QA uplift and no contingency are applied here** — both are phase-level (§7.1) and these
> eighteen stories span seven phases. ⚠ **This total enters no published figure**; `FW-249` is the
> story that decides how, and where, a combined number is stated.

---

#### Additive — the 1–2 September 2026 scope, minted 2 Sep 2026 (`FW-251`–`FW-258`)

> **New 2 Sep 2026.** Eight stories for the work two scope events created and no card covered.
> Every layer of the repository was updated for both — the DDL, the six schema documents,
> `[DBD §6.2]`, `[REQ]`, `[API §4.8]`, the registers, `[DEP §4.2]`'s gate, `[TS]` and the two
> reworked mockups. ⛔ **The backlog was the one layer that was not**, and `FW-003` was the only
> task card touched.
>
> **The two events.** ⭐ **The die split (`Q91`, 2 Sep)** — `ToolingInventoryDie` and `DieHistory`
> added, `Drawer` cut to the two draw boxes, `DieChangeEvent` **+`OldDieId`/`NewDieId`**,
> `PassScheduleComponent` **−`DrawerId`**; **`OI-41` closed after five months**, `FR-233`/`D4`
> reverted to their per-tool form and **the whole die domain returned to MVP-1**. ⭐ **The client's
> reason codes (`A4`/`A5`/`A6`, 1 Sep)** — 156 seeded rows in three new lookups, a new
> `LineDowntimeEvent`, `CK_WipRejection_Group` dropped, the pause taxonomy replaced outright
> (`D-34`) and eight decisions `D-34`–`D-41`.
>
> ⚠ **Hours are additive to `[CE §3b]`**, the same treatment as `FW-232`–`FW-250`. **`FW-258` is
> the story that decides how a combined figure is stated** — and unlike the 29 Aug set, part of
> this one is *scope returning to MVP-1*, so a published total genuinely moves.
>
> ⛔ **Two cards carry an un-priced mockup.** `FW-253`'s screen and `FW-256`'s dialog have no
> approved visual spec, and `[CE §2]`'s 24 h and 12 h rates both assume one exists. Named on both
> cards and on `FW-258`.

---

###### FW-251 · Restate the schema baseline to 40/64/86 and repair the DB cards the die split, the reason codes and the roll set left stale
**Hours:** 8 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** 1C · **Stream:** DB

> ⛔ **Both 2 Sep schema changes reached the DDL and neither reached the task cards.** ⚠ **`FW-005`
> is the dangerous one** — it still says *"`Drawer` seeded with the **13 size rows**
> (`DIE-0210`…`DIE-0340`) … this is what MVP-1's die change validates against"* and *"`Drawer.Id
> 1–13`"*. Both are false since the split, and a developer following that card would rebuild the
> table it took apart.

**Acceptance Criteria:**
- [ ] ⚠ **This story states no count.** `[DBD §6.2]` is the only defining site and is already correct; `verify_schema_counts.py` passes today. The repair is to the *other* sites
- [ ] `C6`'s **24 advisory findings** resolved — restated by citation or marked dated audit trail: `MasterSpecification.md:88`/`:1388`, `FW-152.md:282`, DB `Orchestration.md:439`/`:442`, `FW-142.md:243`, `TrialOrchestration.md:366`, `CapacityAndEffortModel.md:433`, `Decisions.md:889`, `tools/deliverables/README.md:42`
- [x] ✅ **`FW-005` re-pointed 3 Sep 2026** — the Lookup group is **twelve** tables, `Drawer` is **two** rows (`DB1`/`DB2`, capped by `CK_Drawer_Name` + `UQ_Drawer_Name`), `ToolingInventoryDie` holds **14** and `ToolingInventoryRollSet` **six**. ⛔ **The dangerous line is struck rather than deleted** — its old *"13 size rows … this is what MVP-1's die change validates against"* is kept as strikethrough with the reason, because a developer who had already read it needs to see what changed, not just find it gone. ⚠ Done as a side effect of the roll-set pass, which added the **twelfth** table and would otherwise have made this card **more** wrong
- [ ] **`FW-007` / `FW-171` re-pointed** — **seven** in-run event tables, not five, and `DieChangeEvent` carries `OldDieId`/`NewDieId`; `FW-171`'s AC 4 reads `ToolingInventoryDie`, not `Drawer`
- [ ] **`FW-176` re-pointed** — `CK_WipRejection_Group` **dropped**, the group moved onto the lookup row, and `G79` recorded: **all 72 group values are ours**
- [ ] ⚠ The three reason tables are seeded **inline in `01_Lookup`** as production reference data (156 rows), not in sample data. `G85` — the same problem for `Stand`/`Drawer`/`Dancer`/`Edger` — is named, **not fixed here**
- [ ] The **14th** die seeded for `DC-0001`'s worked example is recorded as a pre-existing seed defect, not absorbed
- [ ] `verify_schema_counts.py` green, `C6` advisory at **0** or every survivor deliberately dated

**Rate-card basis (§2):** not a rate-card unit — a card and count-site repair across ten files with the guard as its test, one script-class deliverable = **8 h**
**Dependencies:** FW-152
**Blockers:** — *(`G79` and `G85` are recorded here, not resolved)*

---

###### FW-252 · Die lifecycle service — per-tool die life, `DieHistory` writes and per-tool `POST /diechange` validation
**Hours:** 16 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

> ⭐ **This story exists only because of the die split.** For five months `OI-41` recorded the
> accepted consequence *"two dies of one diameter share a counter, and fitting a fresh die resets
> nothing."* **`OI-41` is closed and that consequence is retired.** `FR-233` / `D4` revert to their
> per-tool form and **`TC-274` is executable for the first time**.

**Acceptance Criteria:**
- [ ] `DieLifecycleService` — register · install · reset · retire · edit-threshold, each writing one `DieHistory` row with its `EventType` (`CK_DieHistory_EventType`)
- [ ] **`POST /diechange` validates against `ToolingInventoryDie`** — an unregistered `DieAlpha` is rejected — and writes `OldDieId`/`NewDieId`. **`TC-274` passes**
- [ ] ⚠ **The rejection reason changed**: an unregistered **tool**, no longer an unrecognised **size**
- [ ] `FR-255` footage accrues as a `RunFootage` row and `LastGrindingFeet` is maintained. ⛔ It is **deliberately denormalised** against `SUM(DieHistory.FootageAddedFt)` — this service owns keeping them equal, and the reconciliation check belongs here
- [ ] `CK_DieHistory_RunFootageHasRun` and `CK_DieHistory_FootageOnlyOnRunFootage` exercised, so the Run-history tab cannot double-count a reset
- [ ] A reset zeroes `LastGrindingFeet` and stamps `LastResetBy`/`LastResetAt` (`FR-245`, `FR-248`)
- [ ] `GET /die/{dieAlpha}/history` serves **both** of `FR-252`'s views from the one discriminated table
- [ ] ⚠ **No threshold invented** — `TotalFeetAllowed` is nullable and there is deliberately no `CHECK` against `LastGrindingFeet`; *overdue* is an operating state, not a data error
- [ ] ⛔ **`OI-12` is not resolved here** — Die Change's 60/85 % and Die Management's 65/80 % bands now read one table. Owned by `FW-199`

**Rate-card basis (§2):** non-trivial business service 12 h + one query endpoint 3 h + the `POST /diechange` amendment 1 h = **16 h** — the figure `phase-13`'s carve published for *"die lifecycle service 16 BE"*
**Dependencies:** FW-167, FW-251
**Blockers:** **`OI-12`**

---

###### FW-253 · Die Management screen — the inventory grid and `FR-252`'s two history tabs
**Hours:** 24 h FE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

> ⛔ **MVP-2 until 2 Sep 2026, MVP-1 since.** `FR-240`–`FR-255` are MVP-1 requirements and
> `DieManagement.md` is an MVP-1 specification. `FW-N07`'s contested MoSCoW split is settled the
> way its own story text always read — the table is *Must*, the screen is *Should*, and both are
> in scope. ⚠ **The 66 h that left MVP-1 on 11 Aug is not this 24 h**; it bundled a service and a
> table. `FW-258` re-costs the return.

**Acceptance Criteria:**
- [ ] ⛔ **No mockup exists, and the 24 h rate assumes one does.** Author `50-frontend/mockups/die_management.html` first — shopfloor tokens, `fw-modal.js`, **14 px** minimum, no scrolling and no stacked dialogs
- [ ] Inventory grid over `ToolingInventoryDie` carrying the client's 31 Aug field set — `S/N` · `P/N` · `Location` · `Machine Name` · `ID(")` · `Max Imput Dia.` · `Pitch` · `Max ID(")` · `Lubrication Type` · `In Use` — plus `DieAlpha`, `LastGrindingFeet`, `TotalFeetAllowed`
- [ ] ⚠ **`DieAlpha` is on no client grid** (`OI-141`). The field half was resolved by building the **union**; the register half — one die register or two — **stays open** and must not be presumed
- [ ] Lifecycle bands over `LifecycleStatus` (`Active|In Service|In Grinding|Retired`) plus the derived **Spare** band from `InUse = 0`. ⚠ A `BIT` cannot express *In Grinding* — `G77`'s point, and why the column is a `VARCHAR`
- [ ] **`FR-252`'s two history tabs** — Replacement log and Run history — both from `GET /die/{dieAlpha}/history`
- [ ] Register · reset · retire · edit-threshold, each capturing `FR-249`/`FR-250`'s reason. ⚠ `FR-250`'s five retire reasons and `FR-248`'s two reset dispositions share one column and are **not** interchangeable
- [ ] An overdue die renders as a state; a `NULL`-threshold die renders without one — no invented limit, no false warning
- [ ] ⛔ **The bands are not chosen here** — `OI-12`, owned by `FW-199`
- [ ] ⚠ **Edger and straightener inventory are out of scope** — `G77`; **roll-set inventory too**, pending `Q92` (`G87`)

**Rate-card basis (§2):** New dashboard screen 24 h — the figure `phase-13`'s carve published as *"Die Management screen 24 FE"*. ⚠ **The mockup is not in it**
**Dependencies:** FW-252, FW-130, FW-133
**Blockers:** **`OI-12`** · **`OI-141`**

---

###### FW-254 · Reason-code query endpoints — the three seeded client vocabularies
**Hours:** 9 h BE · **Priority:** Critical · **Sprint:** S1 · **Phase:** 1C · **Stream:** BE

> ⭐ **The client's reason codes closed `A4`, `A5` and `A6` after 41 days** — the three actions the
> 23 Jul call called *"reference data the build cannot proceed without."* Wave **`W3`**, the only
> propagation wave marked *Blocked on client input*, is unblocked.
>
> ⚠ **`[API]` declares none of these three routes.** This story amends the specification as well as
> building it, which is also why it is Critical: `FW-071`, `FW-067`, `FW-256` and `FW-257` all read it.

**Acceptance Criteria:**
- [ ] `GET /reasons/downtime` — **72** rows with `Bucket`, `DelayCode`, `Description`, `IsNonprodTime`, `DelayBufferMin`, `SupervisorOverride`; filterable by bucket, since pause wants three and downtime wants the fourth
- [ ] `GET /reasons/wiprejection` — **72** rows with their group. ⛔ **`G79`: all 72 group values are ours**, against a client sheet with no grouping at all. The response must not present them as client-supplied
- [ ] `GET /reasons/itinhibit` — the **12** rows: 8 client-active, 4 `[PLC §8.2]`-only inactive (`G80`), returned **flagged, not hidden**
- [ ] ⚠ Inactive and withdrawn codes are returned with their flag so a **historical** event still renders its reason. The dialogs filter for selection; the API does not filter for display
- [ ] The composite key is respected — **`FK_RunPauseEvent_DelayCode` is on `(code, bucket)`**, because *Rewind Bundle* is `Nonprod = Yes` under `Setup` and `No` under `Handling`. A response keyed on code alone is wrong
- [ ] `[API §3.1]` gains the owning controller and `[API §4]` the three sections
- [ ] ⚠ **The client has not seen the codes we minted** — all 36 new downtime reasons arrived with blank `DelayCode`, `Status` and `Delay Buffer` cells. Surface it on the card, not in the payload

**Rate-card basis (§2):** 3 query endpoints @ 3 h = **9 h**
**Dependencies:** FW-138, FW-251
**Blockers:** — *(`G79` and `G80` are sign-off items; neither stops the read)*

---

###### FW-255 · `LineDowntimeEvent` write path — `LineDowntimeService` and the two line-downtime endpoints
**Hours:** 22 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

> ⛔ **44 of the client's downtime codes had nowhere to be recorded, and the reason is structural.**
> `RunPauseEvent.RunId` is `NOT NULL` with an FK to `FlatWireRun`, `FootageAtPause` is `NOT NULL`
> and all four `CK_RunPauseEvent_Outcome` values presume a run — while the `Downtime` bucket's 25
> codes are *Power Outage*, *Fire Drill*, *Scheduled Maintenance*, *Waiting for Spool From Previous
> Operation*: **exactly when no run is open.** `D-35` resolved it with a new table rather than by
> relaxing `RunPauseEvent`, which narrows to the three run buckets (**47** codes).

**Acceptance Criteria:**
- [ ] `POST /line/{lineId}/downtime` opens a **line-scoped** event, `RunId` set only if a run happens to be open
- [ ] `POST /downtime/{id}/end` closes it, stamping `EndedAt`/`EndedBy`. ⚠ **`DowntimeSeconds` is computed** — never written, `NULL` while open
- [ ] `IsNonprodTime`, `DelayBufferMin` and `SupervisorOverride` are **snapshotted from `DowntimeReason`** at start, so retuning the lookup cannot re-price history
- [ ] Only `DWN##` accepted (`CK_LineDowntimeEvent_Code`); `CK_RunPauseEvent_Bucket` rejects `Downtime` on the pause path. **Neither endpoint accepts the other's codes**
- [ ] `DWN29 Other` requires notes. ⚠ Its `Nonprod Time` cell arrived **blank** while every sibling says `Yes`; the seed's choice stands and is not re-decided
- [ ] `SupervisorOverrideBy` only ever set with `SupervisorOverride = 1`. ⚠ `Downtime` is the **only** bucket carrying override, and only the three change-tooling codes carry a delay buffer of 1
- [ ] `LineStatus` broadcast with the reason and cleared on end
- [ ] ⚠ **Decide and record who may open and close a downtime event, and whether an open event survives a shift change** — no existing event service has this shape
- [ ] ⚠ *Bundle* and *Spool* in the seeded text are **operator words**: *Waiting for Spool From Previous Operation* means `SpoolProcessing`, never `Spool`, which since `Q60` has no `Alpha` at all

**Rate-card basis (§2):** 2 command endpoints @ 5 h = 10 h + non-trivial business service 12 h = **22 h**
**Dependencies:** FW-138, FW-251, FW-254
**Blockers:** —

---

###### FW-256 · Line Downtime dialog — the 25 `DWN##` codes that have no run
**Hours:** 12 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** FE

> ⛔ **`pause_run.js` refuses this job and says so in its own header:** *"THE FOURTH BUCKET IS NOT
> HERE. Downtime (25 DWN## codes) is LINE-down time and belongs to LineDowntimeEvent, whose RunId
> is nullable; this dialog pauses a RUN. **Do not add a Downtime tab to it.**"* That leaves the
> fourth bucket with **no surface anywhere in the mockups**.

**Acceptance Criteria:**
- [ ] ⛔ **No mockup exists.** Author `50-frontend/mockups/line_downtime.js` and its thin launcher, following `pause_run.js`'s reworked quick-tiles-over-a-select pattern on `fw-modal.js`. ⚠ **Edit the `.js`, never the launcher**
- [ ] Reached from the **line status board**, not from a run — there may be no run, no footage and no active operator session
- [ ] The **25** `Downtime` codes (16 inherited + 9 new) from `GET /reasons/downtime`. ⚠ **No bucket selector** — one bucket, unlike pause's three
- [ ] `DWN29 Other` demands notes before the action button enables
- [ ] **Supervisor override captured** where the code carries it — the only bucket that does
- [ ] An **open** event is visible from the board and closable from the same dialog. ⛔ **Never stack dialogs**
- [ ] **14 px** minimum, no scrolling dialog, action button carries the icon and dismiss does not
- [ ] Descriptions render **verbatim** from the seed — operator-facing labels

**Rate-card basis (§2):** Modal / dialog 12 h. ⚠ **The mockup is not in that rate**
**Dependencies:** FW-255, FW-133
**Blockers:** —

---

###### FW-257 · Re-point the built `ITInhibitService` at the `ItInhibitReason` lookup
**Hours:** 8 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> ⛔ **`FW-205` is `done`, and the vocabulary it was built against has changed.** It implements
> `[PLC §8.2]`'s five set conditions; the client's list of eight **shares exactly one** — *no coil
> or rod is checked in*. `ItInhibitReason` is now seeded with **12** rows, 8 client-active and 4
> §8.2-only inactive. ⚠ **`G80`: nobody has said the five are superseded, so this is additive or
> it is a contradiction — it is not a replacement.** §8.2's five are `FR-008`/`FR-009` with
> `ALT002`–`ALT005`/`DAT009` and **five P1 cases `TC-011`–`TC-015`**.

**Acceptance Criteria:**
- [ ] `ITInhibitService` evaluates against **`ItInhibitReason` rows**, not a compiled-in set of five
- [ ] The two genuinely new reasons are evaluable — **`No Bundle/Spool is Checked In`** and **`Next Bundle Not Welded`**
- [ ] **`TC-011`–`TC-015` still pass.** §8.2's other four stay **live inhibits**, seeded inactive only because the client's sheet omitted them. ⛔ **Do not delete a condition the client merely failed to list**
- [ ] **`TC-015a`/`b`/`c`/`e`/`f` pass**; `TC-015d` stays **blocked with `G81` named**
- [ ] ⛔ **`No Qualified Operators Are Logged In` must not be stubbed** — `G81`: `[SEC §8]`'s six roles hold neither Leadman nor Helper and there is no qualification matrix. The row stays seeded and inactive; an always-false predicate would make it look implemented
- [ ] ⚠ **`Supervisor Monitor` is not resolved here.** `D-38` answers the **screen**; `Q20` owns what sets the inhibit
- [ ] ⚠ **A `Call Supervisor` action is on both live screenshots and in no requirement** — out of scope, recorded
- [ ] ⚠ The 8-row sheet is a **curated subset**: the screenshots carry periodicity, torch/conductivity and mandrel-state conditions it drops

**Rate-card basis (§2):** not a rate-card unit — reworking a **built** service from a literal condition set onto a seeded vocabulary, priced at one command-endpoint-class change plus the predicate set = **8 h**
**Dependencies:** FW-205, FW-254
**Blockers:** **`G80`** · **`G81`**

---

###### FW-258 · Re-cost the die domain's return to MVP-1 and the reason-code scope, additively
**Hours:** 8 h BA · **Priority:** High · **Sprint:** S2 · **Phase:** 13 · **Stream:** BA

> ⛔ **Every file that records the die reversal says the same thing: "the effort is NOT re-costed
> here."** `phase-13-administration-reference-data.md`, `phase-13-mvp2-die-management.md` and
> `05-Backlog-MVP2.md` each defer to `[CE §3b]`. **This is that deferral's owner** — and it also
> prices the reason-code scope, which arrived the same day and was never costed at all.

**Acceptance Criteria:**
- [ ] The die domain re-derived as MVP-1: `FW-251` 8 DB · `FW-252` 16 BE · `FW-253` 24 FE, reconciled against the **8 h + 66 h** that left on 11 Aug 2026 — with the difference **explained**, not averaged
- [ ] The reason-code scope priced in the same frame: `FW-254` 9 · `FW-255` 22 · `FW-256` 12 · `FW-257` 8. ⚠ **New client scope, not a re-baseline** — keep the two events distinguishable
- [ ] ⛔ **Published in an ADDITIVE new sheet or section** — never by substituting into `[CE §3]`, `§3b`, `§3c` or `[TB §7.3]`. Roughly **twenty files** quote those totals
- [ ] ⚠ **Two un-priced mockups** — `FW-253`'s screen and `FW-256`'s dialog. Price them or state the exclusion; do not let them vanish
- [ ] Every superseded figure named with its section. **Phase 13's published 143 h MVP-1 reconciliation moves** — say so
- [ ] ⚠ **State the schedule consequence.** ~74 h returns to MVP-1 against a window closing **30 Sep 2026**, and S3 is already 17.3 FTE over 8 working days. Absorb, descope or move the window is a delivery decision — surface it
- [ ] `FR-240`–`FR-255` and `DieManagement.md` counted as MVP-1 in §11's coverage matrix, and §7.5's and `05-Backlog-MVP2.md`'s MVP-2 rows updated to match
- [ ] `FW-249` is a **sibling, not a duplicate** — it re-derives the DB-stream total. One pass, or state which precedes

**Rate-card basis (§2):** not a rate-card unit — one BA estimation deliverable across `[CE §3b]` and `[TB §7.3]`, the same unit as `FW-249` = **8 h**
**Dependencies:** FW-249
**Blockers:** —

---

> **Additive-set reconciliation** — DB 8 · BE `16+9+22+8 = 55` · FE `24+12 = 36` · BA 8 =
> **107 h dev** across **eight** stories.
>
> ⚠ **No QA uplift and no contingency are applied here** — both are phase-level (§7.1) and these
> eight stories span five phases. ⛔ **Unlike the 29 Aug set, part of this one is scope RETURNING
> to MVP-1**, so a published total genuinely moves rather than merely gaining an additive
> companion. **`FW-258`** decides how and where.

---

#### Additive — the fourth Tooling Inventory tool type, minted 3 Sep 2026 (`FW-259`–`FW-261`)

> **New 3 Sep 2026.** Three stories for one client sentence. Asked whether stands, dancers and
> spools belonged on the Tooling Inventory tab, Tim O'Brien answered that **mill rolls and the
> DB1/DB2 capstan rolls do** — *"for traceability"* — and that dancers, entry guides, payoffs and
> spools do **not**. That is a **fourth** tool type where `D3` recorded two and the 31 Aug mail
> three, and it is `D-42`.
>
> **The DB work is already done, and that is why `FW-259` is small.** `ToolingInventoryRollSet`,
> its two foreign keys — including **the first ever taken on `Drawer`** — its four indexes and its
> six seed rows all landed with the decision, and `verify_schema_counts.py` is green at
> **40 / 64 / 86**. What did *not* land is client authority for the column set.
>
> ⛔ **This is the only tool type that arrived without a picture.** Dies, edgers and straighteners
> each came as a screenshot grid with the columns in order — *"please include the fields pictured
> below, in the order pictured"*. Roll sets came as one sentence, so every column is `[PROPOSED]`
> at four sites. **`G87`** owns that, **`Q92`** is the send-back, and **`FW-259`** is what removes
> the marks. Building the FE grid before `Q92` returns is how the roll shop ends up entering data
> against fields we invented.
>
> ⚠ **`FW-261` owes an un-priced mockup**, the same residual `FW-253` and `FW-256` carry — and for
> a sharper reason: there is no client screenshot of this grid either.
>
> ⚠ **Hours are additive to `[CE §3b]`**, the same treatment as `FW-232`–`FW-250` and
> `FW-251`–`FW-258`. **No figure is re-derived here** — `FW-258` still owns the arithmetic, and
> this set is a further input to it, not a second answer.

---

###### FW-259 · Reconcile `ToolingInventoryRollSet` with the client's roll-set grid when `Q92` returns
**Hours:** 5 h DB · **Priority:** Medium · **Sprint:** S2 · **Phase:** 1C · **Stream:** DB

> **The table is built; this is the reconciliation.** Five questions the client's sentence does not
> settle: the column list, whether capstan rolls are one option or two, what *"refurbished"* means
> against the edger's `In Grinding`, what `Machine Name` a capstan roll carries, and whether
> *"2 roll set(s)"* means two rolls per set or two sets per position — **the last changes the row
> count**, which is why the seed is deliberately one set per position.

**Acceptance Criteria:**
- [ ] `Q92`'s answer applied — the column list in the **client's order**, on the same terms `FW-003` records for the other three tabs
- [ ] The one-option-or-two question resolved. ⚠ **A split moves the object baseline** — pair it with a recount, counted from a deploy
- [ ] The refurbish vocabulary settled: `IsRefurbishable` + `In Grinding`, **or** a distinct state and date. Not both spellings
- [ ] `Machine Name` for a capstan roll decided — `FL1`, or the draw box
- [ ] ⚠ **`[PROPOSED]` removed from all four sites, or restated with what is still ours.** A half-answered `Q92` must not leave the marks off
- [ ] `verify_schema_counts.py` green; `G87` closed or narrowed with what it still owns

**Rate-card basis (§2):** not a rate-card unit — a schema reconciliation across four documentation sites with the guard as its test = **5 h**
**Dependencies:** FW-251
**Blockers:** **`Q92`**, **`G87`**

---

###### FW-260 · Roll-set register service — `ToolingInventoryRollSet` CRUD and the mount invariant
**Hours:** 10 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

> **The die register's sibling, and deliberately thinner.** `FW-252` carries a *lifecycle* service
> because a die accumulates footage every run and `DieHistory` explains the total. A roll set has
> **no footage counter** — it is reground to a minimum OD — so there is no per-run write path, no
> denormalised total to keep honest and no history log.

**Acceptance Criteria:**
- [ ] Read and write endpoints, following `API/Domain/CoilCheckin` — ⚠ **`SlitterInterface` is explicitly not a reference**
- [ ] **`CK_TIRS_Mount` enforced in the aggregate as well as the database**; a violation answers **422**, not 500
- [ ] `LineId` restricted to `FL1` / `FL2` at the boundary. ⚠ **An `FL3` roll set is a client error** (`D-42`)
- [ ] ⚠ **`NominalDiameterIn` is not derived from, validated against or reconciled with `Stand.RollDiameterIn`** — separate values, separate owners (`D-26`, `[PLC §5.4]`)
- [ ] Retirement sets `LifecycleStatus`; it does not delete. Same discipline as `FR-250`

**Rate-card basis (§2):** one register service with a non-trivial invariant, below `FW-252`'s 16 h because there is no lifecycle, no history log and no denormalised counter = **10 h**
**Dependencies:** FW-252, FW-259
**Blockers:** — *(buildable against the `[PROPOSED]` columns; `FW-259` may reshape them)*

---

###### FW-261 · Tooling Inventory — the fourth *Choose Tool* option and the roll-set grid
**Hours:** 12 h FE · **Priority:** Medium · **Sprint:** S3 · **Phase:** 13 · **Stream:** FE

> ⛔ **This card owes an un-priced mockup**, the same residual `FW-253` and `FW-256` carry.
> `[CE §2]`'s FE rate assumes an approved visual spec and there is none — because there is no
> client screenshot of this grid either. See `G87`.

**Acceptance Criteria:**
- [ ] **Roll Sets** as the fourth *Choose Tool* option (`D-42`). ⚠ The five Slitter-inherited options are **replaced**, not extended
- [ ] `Machine Name` shows `FL1` or `FL2` only. ⚠ **No FL3 row** — its absence from the 31 Aug grids was intentional
- [ ] Mill and capstan rows distinguishable without reading the mount column — **build the one-option form and keep the split cheap**
- [ ] Status renders four lifecycle values; **`In Grinding` is not a boolean** — the narrowness `G77` flags on `Edger.IsActive`
- [ ] ⚠ **Minimum text size 14 px.** Dancers, entry guides, payoffs and spools **do not appear** — they are not tooling

**Rate-card basis (§2):** one grid on an existing tab with a new dropdown option — below `FW-253`'s 24 h, which carries a screen and two history tabs = **12 h**. ⚠ **Rate assumes a mockup that does not exist**
**Dependencies:** FW-260, FW-003
**Blockers:** **`Q92`**, **`OI-141`**

---

> **Additive-set reconciliation** — DB 5 · BE 10 · FE 12 = **27 h dev** across **three** stories.
>
> ⚠ **No QA uplift and no contingency are applied here** — both are phase-level (§7.1) and these
> three span three phases. ⚠ **No published figure is re-derived**; `FW-258` owns the arithmetic
> and this set is a further input to it.

---


#### Additive — the Machine Setup schema, minted 4 Sep 2026 (`FW-262`)

> **The two Machine Setup tabs the client specified on 31 Aug had nowhere to store anything.**
> `FW-003` owns all twelve template tabs and is priced at **12 h as *"configuration rather than
> new screens"*** — an FE card. Five tables, 144 seeded rows, three FKs and eleven documentation
> touchpoints are not 12 h of configuration, and the storage had never been budgeted anywhere.
> **Additive to `[CE §3b]`**, like `FW-202`/`203`/`204` and `FW-259`–`FW-261` before it.

> ⛔ **`OI-110` does not close with it.** Which database these tabs write to is still unanswered,
> and reading `ual-dot-net` for the first time made the evidence *worse* for `FlatWireDB`: every
> other Machine Setup tab persists to a `united_db` satellite keyed on `united_db.dbo.machines`.
> `FlatWireDB` is the `D-02`/`D-31` decision and the three costs are recorded on the card. If the
> client answers `united_db`, all five tables move and every count site moves back.

###### FW-262 · Machine Setup schema — Setup/Handling Times and Material Loss, five tables
**Hours:** 10 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 1C · **Stream:** DB

> **Catalogue plus values, not the legacy wide shape.** `united_db.dbo.Slitters_Standards` is 32
> `float` columns with **no primary key and no index at all**, and
> `united_db.dbo.machine_mill_material_loss` is 36 `float` columns with **no audit columns**. Both
> encode *"the order pictured"* in **column order**. The client has revised these lists twice, two
> FL3 rows are disputed, and FL3's set is not derivable from FL1's and FL2's — so membership and
> order are **data** here: `FL1 33 · FL2 29 · FL3 47` setup elements over seven groups, and
> `FL1 7 · FL2 9 · FL3 12` material-loss elements.

**Acceptance Criteria:**
- [x] Five tables in `01_Lookup` — three catalogues **seeded inline by the DDL** (7 + 109 + 28 = **144 rows**), two `*Standard` value tables created **EMPTY**
- [x] The catalogues seeded by the DDL and not the sample data, for the reason the reason-code lists are: a production deploy runs `RunAll` **without** the fixtures, and both tabs would render empty in production while looking healthy everywhere else
- [x] `Sequence` stored, because *"in the order pictured"* was said separately for each line
- [x] Element uniqueness on **group + label**, never label alone — three labels legitimately sit in two groups each
- [x] `CrewSize` in the key on the setup side and **absent** on the loss side, both verified against the legacy app rather than assumed
- [x] `verify_schema_counts.py` green at **45 · 67 · 87**, advisory count back at its pre-change **24**
- [ ] ⛔ **Values loaded** — blocked on the Naj/Bob/Tim standards spreadsheet, and on `G82` for the footage half
- [ ] ⛔ **`CrewSize` vocabulary confirmed and `[PROPOSED]` removed** — `Q94`
- [ ] ⛔ **FL3's two disputed rows settled** — `SPC: Takeup-1` kept where there is no Takeup-1, `SPC: FL1-Stand 1` dropped for no stated reason. **Seeded exactly as pictured**; `Q94` is the send-back

**Rate-card basis (§2):** not a rate-card unit — five tables with a 144-row client-supplied seed, three FKs, one index and eleven documentation touchpoints under the count guard = **10 h**
**Dependencies:** —
**Blockers:** none for the schema. **`Q94`** and the standards spreadsheet block the **values**

---

### 7.3 Roll-up

> ⚠ **The `FW-232`–`FW-250` additive set is deliberately NOT in this roll-up.** Those nineteen
> stories carry **195 h dev** and are additive to `[CE §3b]`, exactly as `FW-202`, `FW-203`, `FW-204`,
> `FW-218` and `FW-219` are. They span seven phases, so folding them into a per-phase column would
> silently re-baseline six of them. **The 114-story / 3,186 h baseline below is unchanged.**
> Re-deriving a combined figure is **`FW-249`'s**, in an additive sheet — `[CE §8]` is explicit that
> substituting a number into a derivation without re-deriving it *"makes the arithmetic lie"*.

#### 4.1 By phase

| Phase | Title | Sprint | FE | BE | DB | RT | QA | BA | Cont | **Hours** | Stories |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **1A** | Angular Foundation | S0 | 224 | — | — | 44 | 54 | — | 48 | **370** | 9 |
| **1B** | Backend Foundation | S0 | — | 249 | — | 124 | 78 | — | 68 | **519** | 20 |
| **1C** | Database Foundation | S0 | — | — | 160 | — | 32 | — | 29 | **221** | 7 |
| **3** | Line Status Board & Real-Time Backbone | S1 | 64 | 16 | 4 | 40 | 41 | — | 25 | **190** | 6 |
| **4** | Rod Check-In & PLC Configuration | S2 | 60 | 62 | 28 | 28 | 36 | 8 | 33 | **255** | 8 |
| **5** | Active Run Monitoring & Gauge Trace | S2 | 76 | 12 | 8 | 24 | 22 | — | 12 | **154** | 6 |
| **6** | In-Run Production Events | S2 | 120 | 56 | 20 | 20 | 43 | — | 39 | **298** | 12 |
| **7** | WIP Rejection & Rod Checkout | S2 | 64 | 40 | 28 | 16 | 30 | — | 27 | **205** | 7 |
| **8** | FL2 Spool Check-In & Finishing Run | S2→S3 | 48 | 18 | 12 | 8 | 17 | — | 15 | **118** | 7 |
| **9** | Output Coil Completion & Packing | S3 | 104 | 26 | 16 | 8 | 31 | 8 | 29 | **222** | 8 |
| **10** | FL3 Hybrid Continuous Operation | S3 | 12 | 20 | 4 | 8 | 9 | — | 8 | **61** | 4 |
| **11** | Reporting & Certification | S3 | 40 | 56 | 20 | 4 | 24 | 8 | 23 | **175** | 7 |
| **12** | Yield, Cost Ledger & Scrap | S3 | 44 | 72 | 12 | — | 26 | — | 23 | **177** | 4 |
| **13** | Administration & Reference Data | S3 | 56 | 32 | 8 | 4 | 20 | 4 | 19 | **143** | 8 |
| **14** | Integration, Commissioning & Go-Live | S3 | 16 | 16 | 8 | 40 | 112 | 40 | 35 | **267** | 6 |
| | **TOTAL** | | **928** | **675** | **328** | **368** | **575** | **68** | **433** | **3,375** | **119** |

> ⚠ **This TOTAL is 3,375 h / 119 stories and deliberately differs from the widely-quoted 3,292 h / 116.**
> The table has to add up, so absorbing the Phase-1 restatements into the 1B and 1C rows moves the
> total with them: **1B 442 → 519** (14 Aug omissions · `D-29` · backend tests withdrawn · `SpoolController`) and
> **1C 215 → 221** (`G21`'s `Station` column), plus three stories minted after the 116 baseline —
> **`FW-205`, `FW-207`, `FW-208`**.
>
> **`[CE §3b]`'s 3,292 h / 116 stories was the published programme figure when this was written** and is *not* wrong — ⚠ **but it is superseded: `D-32` took the scheduled baseline to 3,186 h, and the live all-in figure is `3,358 h` (`[CE §3e]`, the only site that may assert it).** Read the comparison below against 3,186, not 3,292 —
> `[CE §2]`–`§5` are deliberately not re-derived, per `[CE §8]`, because doing so moves the weekly
> grid, the FTE columns and the descope ladder. **Quote 3,292 to the client and 3,375 when you need a
> table that reconciles.** They differ by exactly the 83 h above.

Every row is the sum of its own printed cells, and every column sums as shown. Totals match `CapacityAndEffortModel.md` §3b's MVP-1 apportionment exactly.

**Reserves excluded from the total:** Phase 4 **24–64 h** (`G2`/`OI-39`) · Phase 9 **16–32 h** (`OQ-10`/`OI-45`, and understated).

#### 4.2 By sprint

| Sprint | Phases | Hours | Wk days | Cap/person | Req. FTE | Stories |
|---|---|---|---|---|---|---|
| **S0** | 1A, 1B, 1C | **1,110** | 12 | 96 h | **11.6** | 36 |
| *carry-over* | *Phase 1 completion* | **0** | 5 | 40 h | *0.0* | — |
| **S1** | 3 | **190** | 10 | 80 h | **2.4** | 6 |
| **S2** | 4, 5, 6, 7, 8 *(start)* | **971** | 9 | 72 h | **13.5** | 40 |
| **S3** | 8 *(finish)*, 9, 10, 11, 12, 13, 14 | **1,104** | 8 | 64 h | **17.3** | 37 |
| | | **3,375** | **44** | **352 h** | **9.6** | **119** |

> **S0 moves 1,027 → 1,110 h and 10.7 → 11.6 FTE** on the Phase-1 restatements above; the programme
> figure moves with it, 3,292 → 3,375 / 9.4 → 9.6 FTE. See the note under §Appendix's phase table for
> why `[CE §3b]` still publishes 3,292 and why that is not a contradiction. **S1–S3 are untouched** —
> every hour of the change is in Phase 1.

*Phase 8's seven stories are counted in S2, where the phase starts; its **hours** split 59/59 across the boundary.*

#### 4.3 The AI-assisted second basis

[`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) re-derives **development hours only** (FE/BE/DB/RT) on an AI-assisted basis per the 23 Jul 2026 client decision: **MVP-1 development 1,397 h against 2,114 h hand-coded** — a 33.9% reduction, **4.0 developer-FTE against 6.0**.

**It is not an alternative total and must not be compared with the programme figure** (3,292 h when this was written; **3,186 h scheduled / `3,358 h` all-in** since `D-32` — `[CE §3e]`). It excludes QA, BA and contingency entirely, and excludes Phase 12. It is shown here at phase and sprint level only; putting it per story would imply a precision the factors do not have — they are **assumed, not measured**, and the first calibration point is the 14 Aug gate.

**The stream it does not compress is the one to staff against:** RT compresses only **14.3%** and is the only stream whose share *grows* (15.0% → 19.6%). Real-time is the constraint, not FE.

---


### 7.4 Blockers

> **⚙ This section is now generated. It lives in [`STATUS.md`](../STATUS.md).**
>
> Blockers used to be written down in **six** places — a story card's `**Blockers:**` line, a
> phase file's `**OQ blockers:**` trailer, the three tables that stood here, the gaps register,
> each task plan's *open items* table, and each `Orchestration.md` blocker calendar. Six copies
> of one fact drift, and this section is where that was proved: it carried **`G21` as blocking
> five stories for two weeks after the gap was fixed on 15 Aug 2026**, three of those rows
> claiming it *"blocks the Phase-4 schema freeze"*.
>
> A task now names its blockers **once**, in its own front-matter, as register ids:
>
> ```yaml
> blocked_by: [G2, OI-39]
> ```
>
> and [`../tools/build_status.py`](../tools/build_status.py) renders two views from that —
> a cross-phase **⛔ Stopping work right now** table ordered by how many tasks each item blocks,
> and an **Open items owned by this phase** table inside every phase section. The text and
> owner of each item are read from the registers themselves —
> [`../90-registers/Gaps.md`](../90-registers/Gaps.md) for `G##`, the master specification §11 for `OI-##`,
> the open-questions register for `Q##` and the PLC tag specification for `PLC-Q##` — so this
> document never holds a second copy of a gap's wording.
> [`../tools/check_docs.py`](../tools/check_docs.py) fails the build when a task cites a
> register id that does not exist, and flags one that is still cited after the item closed —
> which is exactly the `G21` failure, caught mechanically instead of two weeks late.
>
> **Where the old content went.** Nothing was discarded: every blocker listed here was already
> a `**Blockers:**` line on the owning story card, and `../tools/init_tasks.py` lifted those lines
> verbatim into the task files on 29 Aug 2026. The two tables that were *not* pure repetition
> are preserved below, because they record judgements rather than state.

#### 7.4.1 Decided, but the decision has nowhere to land

Kept by hand: these are **design gaps**, not task state, so no generator can derive them.

| Gap | Story | State |
|---|---|---|
| **G34** | `FW-171` | **Wire break has a decided flow and no persistence target** (`FR-280`–`282`, `FW-N08`, `TC-350`–`352`). Decide before the Phase-6 build |
| **G36** | `FW-066`, `FW-182`, `FW-186` | Phase 9's return imported **four uncosted dependencies** — `OI-104` skid table, `OI-24`/`OI-99` lot number, `OI-105` scale weight, `OI-106` staging location |
| **G7** | `FW-175` | Supervisor approval relied only on transient SignalR. `FW-175` is the fix and **is costed** |
| **G24** | `FW-176`, `FW-072` | Approval columns now exist; the **PIN validation source** is still `OI-38` |
| **G26** | `FW-N01` → `FW-166` | The weld write straddles Phase 4's screen and Phase 6's endpoint. Phase 4 **ships against a stub** |

#### 7.4.2 Gaps this backlog closes

| Gap | How |
|---|---|
| **G4** *(story→phase coverage not provable)* | Every story names its phase, and [`../tools/check_docs.py`](../tools/check_docs.py) rule 5 now **fails the build** if a task names a phase with no phase file, or if a task file is missing from `STATUS.md` |
| **G1** *(no capacity/effort model)* | Resolved by [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md); this document **consumes** it per story rather than restating a separate estimate |
| **Phase 1 backlog gap** *(1,027 h against ~28 points)* | **33 stories now cover S0**, including `FW-N03` (Angular scaffold), `FW-N04` (.NET solution + 13 controllers) and `FW-N05` (OPC ingest + host) |

### 7.5 Out of shopfloor scope — 14 upstream stories, and the ~~definition-of-done note on FW-001~~ **cancellation of FW-001**

> ⚠ **`FW-001` is cancelled — `D-32`, 18 Aug 2026. There will not be any shared-schema migration.** The four
> definition-of-done items below are cancelled with it, and so is `FW-176`'s second shared-schema change.
> Retained as the record of what the change would have required.

~~**`FW-001` is flagged high blast radius.**~~ The renames *would have* touched the shared `coils`/scheduling schema read by upstream receiving, planning, scheduling, reporting, yield and cost. Its Definition of Done *had* included:

1. ~~A completed stored-procedure / view / report / query audit across `united_db` **and the legacy `ual-dot-net` tier** (40 h, costed separately from the 16 h rename).~~
2. ~~A **reverse script**, tested.~~
3. ~~A dependent-object recompilation check.~~
4. ~~The regression pass scheduled at QA4.~~

~~**Front-load it in Phase 1C.**~~ It **had been** the risk most likely to surface late, and `[RB §6.3]` recorded it as the hardest element of the release to roll back. **Both statements are now historic.** ⚠ **One thing item 1 would have delivered is genuinely lost and is worth naming:** an inventory of every stored procedure, view and report that reads these columns. **`OI-111`** asks for the one-column version of it — who reads `coils.coil_status` — because that is the dependency the cancellation actually exposes.

**Fourteen upstream stories are out of shopfloor scope**, handled by the existing CoilReceiving / Planning / Scheduling / Web systems. They remain **Critical/High for their own teams**; this plan consumes their outputs but does not build them, and **they are not costed in the 3,292 h**.

| Epic | Stories |
|---|---|
| E03 Rod Receiving | FW-020 (R-series alpha generation) · FW-021 (rod receiving web UI) · FW-022 (suspend-coil logic for rods) |
| E04 Scheduling | FW-030 (Flattening Lines tab) · FW-031 (operation letter `F`) |
| E05 Planning | FW-040 (Flat Wire filter) · FW-041 (weight-based drop with alpha generation) · FW-042 (assign-as-is stock) · FW-043 (tabular allocation grid) |
| E06 Web | FW-050 (Orders & Quotes flags) · FW-051 (Search Customers) · FW-052 (IQR bundle width / edge type) · FW-053 (Item Template) · FW-055 (Vendor Maintenance) |

> **Ruled 13 Aug 2026.** These fourteen were tagged in-scope Critical/High, Sprint 2–3 by the April backlog and out-of-scope by this plan — the two documents disagreed for four months and both are now one document, so the disagreement is closed in favour of **out of shopfloor scope, consumed as prerequisites at Phase 4**. **If either upstream track slips, Phase 4 has no material and no scheduled job** — that is the dependency behind §10.1's upstream risk, and it is the reason they are listed here at all rather than simply deleted.

### 7.6 Appendix A — retired point basis

Story points were retired on 13 Aug 2026. **These figures are recorded once, here, so every downstream citation stays resolvable.** They are historical: nothing in this document is sized in points, and the totals must not be re-derived from the current story set.

| Basis | Stories | Points | Where it was quoted |
|---|---|---|---|
| **Shopfloor MVP-1** *(this file, previous version)* | 35 | **147** | This file's header; `../00-overview/Roadmap.md` §0.1; `REVIEW.md` #51, #57 |
| **MVP-2** | 6 | **31** | [`FlatWireJiraStories-MVP2.md`](./FlatWireJiraStories-MVP2.md) |
| **Phase 12 (Yield/Cost/Scrap)** | 4 | **11** | `YieldCostAndScrapJiraStories.md`; `YieldCostAndScrapSheet.md` |
| **Published shopfloor total** | **45** | **189** | `CapacityAndEffortModel.md` §3 cross-check; `../90-registers/Gaps.md` Appendix C |
| *Upstream (deleted, another team's work)* | *14* | *42* | *Recoverable at commit `1964086`* |
| *Retired totals* | | *184 · 220 · 231* | *All superseded before this rewrite* |

**Per-epic split of the 147** — E01 Foundation **33** (8 stories) · E02 Pass Schedule **3** (1) · E07 Shopfloor UI **65** (13) · E08 Real-Time & PLC **13** (3) · E09 Reporting **17** (6) · E12 Testing & Go-Live **16** (4).

**The two derived ratios that lose their denominator:** `CapacityAndEffortModel.md` §3's cross-check of **19.4 h/point** (3,660 h ÷ 189) and **16.4 h/point** excluding Phase 1 (2,633 h ÷ 161). Both were investigation results, not planning inputs; §3's two stated causes — the Phase-1 backlog gap and the ~16 h/point vertical-slice reality — are **both addressed by this rewrite**, the first directly.

**Epics are retired too.** They were a Jira grouping over a five-sprint model that no longer exists; phases are the grouping now. The epic ids `FW-E01`, `FW-E02`, `FW-E07`–`FW-E12` are recorded above so old references resolve.

---


### 7.7 Appendix B — ID provenance

Every `FW-###` cited anywhere in the repository resolves through this table.

#### B.1 Existing ids — numbers and titles frozen (39)

**38 of these carry a story body here; `FW-014` is subsumed (see B.5).** `38 + 6 adopted + 72 minted = 116` **ids** — of which **114 are live**, `FW-001` and `FW-002` having been cancelled by `D-32` on 18 Aug 2026. Their ids are **not** reissued.

| Range | Stories | Where they are now |
|---|---|---|
| ~~`FW-001`, `FW-002`~~ *(cancelled 18 Aug 2026, `D-32`)*, `FW-004`, `FW-005`, `FW-006`, `FW-007` | 6 *(4 live)* | **S0 / Phase 1C** |
| `FW-003`, `FW-054` | 2 | **S3 / Phase 13** |
| `FW-060` | 1 | **S1 / Phase 3** |
| `FW-061` | 1 | **S2 / Phase 4** |
| `FW-062`, `FW-081` | 2 | **S2 / Phase 5** |
| `FW-063`, `FW-065`, `FW-070`, `FW-071`, `FW-073` | 5 | **S2 / Phase 6** |
| `FW-067`, `FW-072` | 2 | **S2 / Phase 7** |
| `FW-064`, `FW-124` | 2 | **S2 / Phase 8** |
| `FW-066` | 1 | **S3 / Phase 9** |
| `FW-080` | 1 | **S0 / Phase 1B** |
| `FW-082` | 1 | **S2 / Phase 4** |
| `FW-090`–`FW-095` | 6 | **S3 / Phase 11** |
| `FW-100`, `FW-101`, `FW-102`, `FW-110` | 4 | **S3 / Phase 12** — absorbed from `YieldCostAndScrapJiraStories.md` |
| `FW-120`–`FW-123` | 4 | **S3 / Phase 14** |
| `FW-014` | 1 | **Subsumed** — see B.5 |

#### B.2 Adopted `FW-N##` ids — costed (6)

Absorbed from `05-SprintPlanAndBacklog.md` §7.3 under the single-backlog decision.

---

###### FW-225 · Rod ↔ order allocation — schema and domain model
**Hours:** 28 h (DB 12 · BE 16) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB + BE

> **New 22 Aug 2026.** Nothing persisted the rod ↔ order pairing — it existed only implicitly in
> `united_db..planning_routings`, which `[INT §8]` records the flat wire side as reading and never writing.
> Specified as `FR-541`–`FR-560` (`[REQ §5.28]`) with rule codes `ORD003`–`ORD017`; design at
> [`RodOrderAllocation.md`](../95-archive/design-notes/RodOrderAllocation.md). DDL is **already applied** —
> `RodOrderAllocation` in `03_Materials`, `RodOrderConsumption` in `04_Runs`, 7 FKs, 12 index statements —
> and verified on a live deploy, so the DB half is the domain mapping rather than the tables.

- [ ] Map both tables for read and write; the allocation is **superseded, never updated** on a re-plan
- [ ] The three invariants SQL cannot express: a rod's active ranges **tile the rod**; a `PinnedBoth` row is its order's only row; an order with an allocation has ≥ 1 rod
- [ ] `RodOrderConsumption` snapshots the allocation it ran against — never a join back
- [ ] ⚠ `UX_RodOrderConsumption_Station` is keyed on **`Station`**, not `LineId` — FL1 and FL3 share one physical VPS. Do not "fix" it to `LineId`

**Blockers:** **`Q48`** (`Critical` — can two orders on one rod have different pass schedules? It decides whether the mounted handoff is universal or conditional)

---

###### FW-226 · Sequence validation — the four-tier partition
**Hours:** 20 h (BE 14 · FE 6) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE + FE

> Rule 5 and **`Q73`** combined: **pinned-first → free full → free partial → pinned-last**. Applied at
> **both** pre-check-in and check-in (`Q73` item 7 — a rule enforced at one of two entry points is not
> enforced).

- [ ] **O(1) positional check, never enumeration** — `|freeFull|! × |freePartial|!` explodes. Enumeration exists for display and tests only, capped at 7 free rods
- [ ] A rod may be **`PinnedBoth`** — the order lies wholly inside it, so first and last are the same row. Do not assume they differ
- [ ] Out-of-tier is a **refusal**, not the `Q24` supervisor override — `Q73` consequence 1
- [ ] Acceptance: for O1 = {R1A, R1B, R1C} exactly **2** legal sequences; for O2 = {R1C, R1D} exactly **1**

**Blockers:** **`Q49`** (does multi-order-last hold with no weld? Build the stricter reading)

---

###### FW-227 · The order-boundary handoff and its notification
**Hours:** 26 h (BE 16 · FE 10) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE + FE

> The rod is checked in **once** and stays mounted across the boundary. The state machine is
> `Pending → InProgress → ThresholdReached → Closed`, plus `Voided`.

- [ ] Crossing detected **server-side on the footage stream**, once per pairing — not a client threshold check (`SpoolWeightMilestone`'s rule)
- [ ] Hub events **13/14**, durable and re-delivered on group re-join, following event 11's contract
- [ ] **Two weight latches** — at the crossing and at the acknowledgement. The difference is the overrun and it is persisted
- [ ] ⚠ The close-and-open at a boundary must be **one transaction**, or `UX_RodOrderConsumption_Station` rejects the handover
- [ ] The station is **handed over, not released**; release happens at checkout
- [ ] `POST /order/{orderNo}/complete` — the only thing that closes an order

**Blockers:** **`Q50`** (the escalation bound), **`Q51`** (the early-ack remainder)

---

###### FW-228 · Footage-to-weight converter
**Hours:** 12 h (BE 12) · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE

> One interface, one implementation, a **selectable basis**. The formula is `FR-137` / `[DBD §6.6]`; what is
> open is the dimensional basis (`Q10` / `OI-45`), which is what config selects.

- [ ] `lb/ft = A × 12ρ`, round edge `A = t·w − 0.2146·t²`, ρ read across from the shared alloy table
- [ ] Reference values: 1100 @ 0.110″ × 0.625″ → **0.0809** square / **0.0778** round (`TC-167`, `TC-409`)
- [ ] ⚠ **`FR-332a`**: the mockup's `0.069 lb/ft` must **not** be implemented
- [ ] Every consumption row persists **basis + factor + version** — a later `Q10` answer must not retro-change a historical record

---

###### FW-229 · Fulfilment rollup and order status
**Hours:** 16 h (DB 6 · BE 10) · **Priority:** High · **Sprint:** S3 · **Phase:** 9 · **Stream:** DB + BE

> Published as **views**, not service methods — the API, the reports and the certificate all need the same
> number, and a view is the only form all three can read.

- [ ] `vw_OrderFulfillment` (per order) and `vw_OrderRodAttribution` (per order, per rod)
- [ ] Apportion a multi-parent coil by **footage share**, not by counting parents — a two-parent coil is rarely 50/50
- [ ] Status: not started · in progress · **pending operator confirmation** · complete · short
- [ ] Two yield figures, **named apart**: yield on metal *run* (`produced/consumed`) and on metal *issued* (`produced/allocated`)

**Blockers:** **`Q53`** (is fulfilment consumed or produced pounds — and which does the certificate state?)

---

###### FW-230 · FL1 segment alpha — one namespace
**Hours:** 14 h (DB 4 · BE 10) · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** DB + BE

> **`Q57`.** FL1 segment alphas and FL2 coil identities are the same strings off the same six-character
> root, and `CommonDB.dbo.GenerateCoilAlpha` cannot see `FlatWireDB` — so both are minted through that one
> function. `SpoolTraceability.ChildAlpha` is already applied.
>
> ⚠ **Change `[N]` (26 Aug 2026) answers the *"cannot see `FlatWireDB`"* clause differently.** Rather than
> compensating with an ignore list, **`FW-231` makes the alphas visible** by registering them in
> `proddb..coils`. Segments keep a **single** trailing letter off the rod; coil parts take a **double** off
> the segment. Design of record: `[RodOrderAllocation.md §2.4/§2.8]`.

- [ ] ⛔ **WITHDRAWN 26 Aug 2026 (change `[N]`) — there is no ignore list.** *Superseded: "Ignore list = **every** prior segment alpha for that rod, read from `SpoolTraceability` — not just this transaction's. Cap `VARCHAR(500)`."* The mint passes **`''`**; `GenerateCoilAlpha`'s own sweep finds prior segments because **`FW-231` registers every one in `proddb..coils`**. `F11`'s 500-char cap and `F10`'s 2048 → 500 truncation stop applying to flat wire
- [ ] ⚠ **Depends on `FW-231`.** Built alone, a blank-list mint **reissues `R00001A` on every spool** (`OI-138` / `G54`). Ship them together or keep this story blocked
- [ ] Replicate the caller's guards: the `' '` blank return and the `UPDLOCK, HOLDLOCK` re-check
- [ ] `ChildAlpha` is **opaque** — never parsed, never rebuilt, and no stored letter index
- [ ] ⚠ **Cannot be tested on LocalDB** — it has no `CommonDB`
- [ ] Reference loop: `PlanningDB.dbo.GetCoilAlpha`'s `CONCAT_WS` accumulation — **cite it, do not call it** (it uses PlanningDB's divergent copy)

**Residual:** **`Q59`** — a third-party caller cannot see `FlatWireDB` and can be issued an alpha a segment holds. Accepted and monitored; the `UNIQUE` index makes it loud


###### FW-231 · Register every flat wire alpha in the shared coil master
**Hours:** 18 h (DB 12 · BE 6) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 8 · **Stream:** DB + BE

> **`OI-138` / `G54`, and it gates the whole 26 Aug alpha scheme.** Every mint now passes a **blank**
> ignore list and relies on `GenerateCoilAlpha`'s own sweep finding prior siblings — which works only for
> alphas that reach the shared schema. `50_…CompleteCoilOnSkid` is the only script that writes
> `proddb..coils`; **nothing writes an FL1 segment alpha at all.** Until this ships, the FL1 rows in
> `[RodOrderAllocation.md §2.8]` are the **design, not current behaviour**, and a blank-list mint reissues
> `R00001A` on every spool.

- [ ] Write one `proddb..coils` row per FL1 segment alpha, at spool completion (`POST /spool/complete`)
- [ ] ⚠ **Decide the `coil_status` value.** `D-32` bars a **new** shared value — `INFLAT` is `FlatWireDB`-local — and the output coil's own `ONSKID` is still open as `Q35`. Pick from the existing vocabulary
- [ ] ⚠ **Tonnage multiplication is the real risk.** Rod, segments and coils all group flat under the six-character root via `coil_link_master_coil`, so a report summing children **triple-counts** one rod's weight. Establish which reports do that **before** the first production write
- [ ] **Atomicity:** mint and insert in one transaction, or a crash leaks a name. Follow the `THROW 51011` re-check pattern under `UPDLOCK, HOLDLOCK`
- [ ] ⚠ **Cannot be tested on LocalDB** — it has no `proddb` and no `CommonDB`
- [ ] Confirm whether **`OI-115`**'s narrowing of the spool to one shared face is still wanted once every segment has its own shared identity — the way `Q89` retired `D6`'s narrowing at the coil hop

**Blocks:** **`FW-230`** (which mints the segment alphas) and, through it, every FL1 trace in the design of record. **Residual:** `OI-139` — whether an FL2-standalone spool can arrive with no segment at all

| Story | Title | Sprint / Phase |
|---|---|---|
| `FW-225` | Rod ↔ order allocation — schema and domain model | S2 / 4 |
| `FW-226` | Sequence validation — the four-tier partition | S2 / 4 |
| `FW-227` | The order-boundary handoff and its notification | S2 / 4 |
| `FW-228` | Footage-to-weight converter | S2 / 4 |
| `FW-229` | Fulfilment rollup and order status | S3 / 9 |
| `FW-230` | FL1 segment alpha — one namespace | S2 / 8 |
| `FW-231` | Register every flat wire alpha in the shared coil master | S2 / 8 |
| `FW-N01` | Dashboard 2A — Rod Pre-Check-in station | S2 / 4 |
| `FW-N02` | Spool completion weight milestones | S3 / 8 |
| `FW-N03` | Angular library scaffold | S0 / 1A |
| `FW-N04` | `FlatWire` solution skeleton | S0 / 1B |
| `FW-N05` | OPC ingest hosted service | S0 / 1B |
| `FW-N06` | Alert rules engine and lifecycle | S1 / 3 |

#### B.3 Minted ids — `FW-130`–`FW-201` (72, contiguous)

All above the previous high-water mark `FW-124`, so nothing collides with upstream (`FW-020`–`FW-055`) or MVP-2 (`FW-010`–`FW-013`, `FW-068`, `FW-069`).

| Range | Phase | Covers |
|---|---|---|
| `FW-130`–`FW-137` | 1A | Shell, guards, API client, shared controls, SignalR client, mock hub, cache sync |
| `FW-138`–`FW-151` | 1B | Controllers, MediatR, DI, repositories, data access, logging, config, auth, exceptions, validation, health, typed contract, broadcast loop, `PLCTagService` skeleton |
| `FW-152` | 1C | `FlatWireDB` creation and ordered runner |
| `FW-153`–`FW-156` | 3 | Alert chips, `/lines/status`, index, load test |
| `FW-157`–`FW-161` | 4 | Check-in command, staging controller, staging schema, `PayoffStateChanged`, BA |
| `FW-162`–`FW-165` | 5 | Status cards, info grid, run queries, `sp_GetGaugeTrace` |
| `FW-166`–`FW-172` | 6 | Five event endpoints, event tables, markers |
| `FW-173`–`FW-177` | 7 | Partial re-check-in, exception endpoints, durable queue, tables, broadcasts |
| `FW-178`–`FW-181` | 8 | FL2 monitor config, spool endpoints, schema, null-gauge contract |
| `FW-182`–`FW-188` | 9 | Packing station, traceability controls, label, coil endpoints, schema, broadcasts, BA |
| `FW-189`–`FW-192` | 10 | FL3 variants, hybrid push, route mode, continuous trace |
| `FW-193` | 11 | Certification BA |
| `FW-194`–`FW-199` | 13 | Alloy admin, role UI, admin endpoints, reference wiring, broadcast, BA |
| `FW-200`, `FW-201` | 14 | PLC commissioning, defect allowance and rename regression |

#### B.4 Adopted but **uncosted** — tracked, not scheduled (6)

**These are real work items with no hours anywhere in the capacity model.** They are listed so they are not mistaken for oversights, and so nobody assumes they are inside the 3,292 h.

| Story | Title | Status |
|---|---|---|
| `FW-N07` | Die master table | **Wholly MVP-2.** Its 8 h left `phase-13` with the Die Management screen. *(`phase-13`'s own MVP-2 callout still says the table half is MVP-1 — that line is stale and contradicts its scope call, `CapacityAndEffortModel.md` §3b and the repository guide)* |
| `FW-N08` | Wire break | **Blocked — `G34`.** A decided flow with **no persistence target**. Must be decided before the Phase-6 build |
| `FW-N09` | OEE dashboard | **MVP-2** — the mockup lives in `MVP-2/Mockups/` |
| `FW-N10` | Stop popup | Uncosted; no phase assignment |
| `FW-N11` | **Operator session** *(was "Operator session / `ITInhibit`")* | Cited against Phase 6, **still uncosted**. ⚠ **Split 14 Aug 2026 — the `ITInhibit` half has left.** It is now `FW-205` (Phase 1B, 16 h, the service and conditions 3–5) and `FW-206` (Phase 4, 8 h, conditions 1–2, blocked on `PLC-Q12`). Bundling two unrelated subjects on one card is why neither half was ever priced. The id is retained because it is cited against Phase 6 |
| `FW-N12` | De-stub pass | Cited against Phase 4, **uncosted**. In practice absorbed by `FW-166` (weld) and `FW-201` (defect allowance) |

#### B.5 Subsumed, superseded and out of scope

| Id | Disposition |
|---|---|
| `FW-014` | **Subsumed by `FW-169`** for its MVP-1 half — the mid-run override **trigger** writes a run-level `RollOverride` row. Its **sink**, `PassScheduleChangeLog`, is an **MVP-2 table**, so MVP-1 has an override path with nowhere to log the schedule-level record. Retained here as a citation target |
| `FW-010`–`FW-013`, `FW-068`, `FW-069` | **MVP-2** — [`FlatWireJiraStories-MVP2.md`](./FlatWireJiraStories-MVP2.md). `FW-010` is a live dependency of `FW-061` and `FW-082` |
| `FW-020`–`FW-022`, `FW-030`, `FW-031`, `FW-040`–`FW-043`, `FW-050`–`FW-053`, `FW-055` | **Upstream, deleted** — rod receiving, orders, planning and line scheduling, built by other teams. Recoverable at commit `1964086`. `FW-020` is a live dependency of `FW-061` |
| `FW-S1-###`, `FW-S3-###` | **Never existed.** These sprint-style ids appear in `CheckinImplementationPlan.md` and `CheckinImplementationPrompt.md` and resolve to nothing. Treat any such citation as pointing at the phase, not a story |

---

#### B.6 Minted ids — `FW-232`–`FW-250` (19, contiguous)

**Minted 29 Aug 2026** for pending work that had **no id, no plan and no hours line**, from the two
orchestration files' recorded-but-unfixed findings, the `P-##` register and `[GAP]`. Cards are in
§7.2 under *Additive — pending-work stories*. **Next free id: `FW-251`.**

| Range | Stream | Subject |
|---|---|---|
| `FW-232`–`FW-233` | BE | Hosts for the two specified-but-unhosted endpoint groups — `/order/**` and `/rod/**` |
| `FW-234`, `FW-237` | BE + DB | Audit-log persistence (`P-15`) and the service identity its unattended writes need (`G59`) |
| `FW-235`, `FW-239` | RT + FE | `CoilCompleted`'s missing hub member (`OI-140`) and `FW-150`'s unwired cache invalidation |
| `FW-236`, `FW-238` | BE + DB | The two `OPCConnection` defects — no per-tag write status (`G58`), no flat wire registration (`G60`) |
| `FW-240` | BE | `P-91`'s two rod-order entities, pending `[SVC §3.2a]` |
| `FW-241`–`FW-242` | DB | Deploy step 2's reverse script and sign-off, and moving `FlatWireDB` into `ual-database` |
| `FW-243`–`FW-246` | DB | The schema deltas and constraint repairs — `D-30`, `G49`, `G51`, and `G50`/`G52`/`G41`/`G55` |
| `FW-247`–`FW-249` | DB + BA | `G8`'s migration, the count guard's blind spot, and the DB-stream re-derivation |
| `FW-250` | DB | ⛔ **The development-plan generator silently drops every multi-stream story** — found by running it during this set's verification |

⚠ **Hours are additive to `[CE §3b]` and are in no phase reconciliation and no roll-up column.**

⚠ **This block does not follow `B.3` contiguously, and that hole is pre-existing.** `B.3` stops at
`FW-201`; **`FW-202`–`FW-231` have no appendix block at all** and are recorded only in this file's
header change entries. That set is also **not contiguous** — `FW-209` was already taken and `FW-216`
is deliberately skipped. Closing that hole is not this pass's, and is noted so `B.6` is not misread
as following `B.3`.

#### B.7 Minted ids — `FW-251`–`FW-258` (8, contiguous)

**Minted 2 Sep 2026** for the two scope events of 1–2 September that every layer of the repository
absorbed **except the backlog**. Cards are in §7.2 under *Additive — the 1–2 September 2026 scope*.
**Next free id: `FW-259`.**

| Range | Stream | Subject |
|---|---|---|
| `FW-251` | DB | The die split and the reason codes reached the DDL and not the cards — `FW-005` still seeds `Drawer` with 13 die-size rows |
| `FW-252`–`FW-253` | BE + FE | The die domain's return to MVP-1 (`Q91`): per-tool lifecycle service, and the Die Management screen `FR-240`–`FR-255` |
| `FW-254` | BE | The three seeded client vocabularies — 156 rows the dialogs cannot reach without a read |
| `FW-255`–`FW-256` | BE + FE | `LineDowntimeEvent` and its dialog — the `Downtime` bucket's 25 codes have **no run**, and `pause_run.js` refuses them by design |
| `FW-257` | BE | ⛔ **`FW-205` is `done` against a vocabulary that changed** — the client's 8 inhibit reasons share exactly one of `[PLC §8.2]`'s five |
| `FW-258` | BA | The re-cost every phase file defers to `[CE §3b]`, plus the reason-code scope nobody has priced |

⚠ **Hours are additive to `[CE §3b]` and are in no phase reconciliation and no roll-up column** —
⛔ **but unlike `B.6`, part of this set is scope RETURNING to MVP-1**, so `FW-258` is not optional
bookkeeping: a published total genuinely moves.

⚠ **`FW-N07` is still carded nowhere**, and after `Q91` it no longer needs to be — the table half is
`FW-251`'s, the service half `FW-252`'s and the screen half `FW-253`'s. `B.4` should stop listing it
as *adopted but uncosted* once `FW-258` runs.

---


---

---

## 8. Descope ladder

From [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §5. **Every rung lands in S2 or S3**, and the whole ladder recovers **448 h — about 12%** — leaving a 9.1–9.3 FTE requirement.

| # | Rung | Stories | Hours | Cumulative | Latest call | What is lost |
|---|---|---|---|---|---|---|
| 1 | Scrap Box/Skid outlet | `FW-110` | 33 | 33 | in **S3** | Scrap routed manually post-go-live |
| 2 | Cost Ledger configuration | `FW-102` | 49 | 82 | in **S3** | No flat-wire cost standards; costing reports blank |
| 3 | Weld traceability in yield | `FW-101` | 28 | 110 | in **S3** | Yield not attributed per source rod — **welding-wire certs affected** |
| 4 | Remainder of Phase 12 | `FW-100` | 67 | **177** *(whole phase)* | in **S3** | No footage-based yield at go-live |
| 5 | Phase 13 non-critical | `FW-195` *(role UI only)* | **< 99** | — | in **S2** | Roles assigned by a DBA |
| 6 | Phase 11 reports, 4 of 5 | `FW-092`, `FW-093`, `FW-094`, `FW-095` | 105 | — | in **S2** | Only Gauge Trace ships; CPK/SPC/traceability deferred |

**Two rungs no longer mean what they say:**

- **Rung 5's published 99 h is not available in full.** It bundled the **Die Management screen — now MVP-2** — with the MVP-1 role-assignment UI. Only the role-UI share can still be cut.
- **Rung 7 was removed on 4 Aug 2026, and that made the schedule harder, not easier.** DB13 and DB14 were the largest genuinely-optional FE items on the critical path, and the client **descoped them outright**. Their 67 h stopped being *recoverable* effort and became *never-planned* effort — so the ladder now recovers ~12% of a smaller base, and **Phase 5 is no longer deferrable at all**.

**Phase 10 (FL3 hybrid, 61 h) is explicitly not deferrable** — FL3 is one of the three production routes.

> **The ladder is not enough, and that is the finding.** Below rung 6 there is nothing left that is not a production route, a check-in path or the traveler. **Scope is not where the 30 Sep date can be recovered.** Extending S3 to its natural 2 Oct boundary recovers more peak FTE (17.3 → 13.8) than rungs 1–4 combined.

---


---

---

## 11. Coverage matrix — every `FR-###` reaches a story

| `[REQ]` § | FR range | Count | Delivering story | Phase |
|---|---|---|---|---|
| 5.0 | FR-001 – FR-022 | 22 | **`[NEW]` FW-N11** | 4 |
| 5.1 | FR-030 – FR-054 | 25 | **`[NEW]` FW-N01** | 4 |
| 5.2 | FR-060 – FR-084 | 25 | FW-061, FW-082, FW-010 | 4 |
| 5.3 | FR-090 – FR-096 | 7 | FW-064 | 8 |
| 5.4 | FR-100 – FR-120 | 21 | FW-062, FW-081, FW-080 | 5 |
| 5.5 | FR-130 – FR-157 | 26 | **`[NEW]` FW-N02** | 9 (uses 5) |
| 5.6 | FR-160 – FR-175 | 16 | FW-063 | 6 |
| 5.7 | FR-180 – FR-197 | 18 | FW-065 | 4, 6 |
| 5.8 | FR-200 – FR-212 | 13 | FW-070 | 6, 10 |
| 5.9 | FR-220 – FR-234 | 15 | FW-073 *(+ FW-N07 for the inventory it validates against)* | 6 |
| 5.10 | FR-240 – FR-255 | 16 | **`[NEW]` FW-N07** | 13 |
| 5.11 | FR-260 – FR-267 | 8 | FW-071 | 6 |
| 5.12 | FR-270 – FR-277 | 8 | **`[NEW]` FW-N10** | 6 |
| 5.13 | FR-280 – FR-282 | 3 | **`[NEW]` FW-N08 — BLOCKED (OI-13)** | **unassigned** |
| 5.14 | FR-290 – FR-299 | 10 | FW-067 | 7 |
| 5.15 | FR-300 – FR-327 | 19 | FW-072 | 7 |
| 5.16 | FR-330 – FR-340 | 12 | FW-066, FW-100 | 9 |
| 5.17 | FR-345 – FR-352 | 8 | FW-066 *(DB7b is inside its phase mapping)* | 9 |
| 5.18 | FR-360 – FR-391 | 28 | FW-010, FW-012, FW-013, FW-014 | 2 |
| 5.19 | FR-400 – FR-410 | 11 | FW-011, FW-068 | 2 |
| 5.20 | FR-420 – FR-428 | 9 | FW-060 *(+ FW-N06 for alert persistence)* | 3 |
| ~~5.21~~ | ~~FR-440 – FR-451~~ | ~~12~~ | ~~FW-062 (DB13 scope)~~ | **withdrawn 4 Aug 2026** |
| ~~5.22~~ | ~~FR-460 – FR-470~~ | ~~11~~ | ~~FW-062 (DB14 scope)~~ | **withdrawn 4 Aug 2026** |
| 5.23 | FR-480 – FR-490 | 11 | FW-069 | 11 |
| 5.24 | FR-500 – FR-508 | 9 | **`[NEW]` FW-N09 — `Could`, no phase** | **unassigned** |
| | **Total** | **363** | | |

### 11.1 Requirements not on the critical path — stated explicitly

| FR range | Status | Reason |
|---|---|---|
| **FR-280 – FR-282** (wire break, 3) | **Not deliverable** | `FW-N08` is blocked by **OI-13** — no screen, no table, no persistence target. The requirements are unimplementable as written |
| **FR-500 – FR-508** (OEE, 9) | **Not scheduled** | `FW-N09` has no phase and no owner (**PP-03**). Either schedule it or record OEE as out of scope |
| ~~**FR-440 – FR-470**~~ (DB13 + DB14, 23) | **[WITHDRAWN — descoped by client, Aug 4 2026]** | Withdrawn from scope entirely, not deferred. **FW-062 keeps its 8 points** — DB13, DB14 and the Machine View had no acceptance criteria of their own in it |
| **FR-500-series and FR-480-series reporting** | **Descope rung 6** | Four of five Phase-11 reports; Cut Traceability's deferral carries a shipment risk |

**All 363 requirements map to a story.** Of those, **351 (96.7 %) are schedulable**: the nine OEE requirements have a story (`FW-N09`) with no phase or owner, and the three wire-break requirements have a story (`FW-N08`) that is blocked by **OI-13**. Both are carried in the backlog rather than dropped, so neither can be lost — but neither can be committed to a sprint today. This matches `[TCS §10.4]` exactly.
