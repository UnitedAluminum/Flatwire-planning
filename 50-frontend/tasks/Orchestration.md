# Phase 1A — Execution Orchestration (Frontend)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 4, 2026 — Change history is in [`../../CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Execution index and dependency graph for the Phase-1A implementation and the FE stream downstream of it
**Status:** Active — **the entry point for this folder**
**Owner:** Frontend (Angular)
**Audience:** The delivery lead sequencing the FE stream, and any developer picking up a screen
**Shortcode:** — *(orchestration, derived from the specifications and the backlog; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Frontend/tasks/` — folder index: this file · shared context: [`Phase-01A-ImplementationPlan.md`](Phase-01A-ImplementationPlan.md) · **nine per-story plans, named in §1**

---

> ### ✅ This folder now holds nine per-story plans — one per Phase-1A story
>
> The Backend sibling indexes **35 plans**, one file per story, each saying *how* to build it.
> **The FE stream has its first nine, written 27 Aug 2026**, and §1.1/§1.2's rows name them as
> `plan` beside their owning specification. Until that day every row named only its specification,
> which was the convention
> [`TrialOrchestration.md §1`](../../40-backend/tasks/TrialOrchestration.md) uses —
> *"FE and DB rows name the owning document instead of a plan"* — because that folder is
> Backend-scoped.
>
> **The shared context sits in one file, not in nine.**
> [`Phase-01A-ImplementationPlan.md`](Phase-01A-ImplementationPlan.md) keeps the measured checkout,
> the eleven integration points every new library must touch, the `F-01`–`F-15` decision series and
> the twelve findings. **Nothing was copied into the nine.** ⛔ Two of its findings change rows here:
> the client has **no role source at all**, so `FlatWireRoleGuard` cannot be built rather than merely
> not verified (§5's `G6` row); and the hub contract carries **fourteen** events where `[TB §7]`'s
> `FW-136` card enumerates nine.
>
> **A plan loses to every specification, exactly as this file does** — where a plan and an owning
> document disagree, **the owning document wins**.
>
> ⚠ **Phases 3–14's FE stories still have no plans.** §1.4's thirty-eight rows name their owning
> specification, and that is the state of the stream, not an omission in this file.

---

> **What this file is.** It says **what can start, in what order, and what is stopping it.**
> It holds **no build detail** — every statement here resolves to a specification, and this
> file loses to all of them.
>
> **The one thing to read first:** the Phase-1A critical path is **160 h** — `FW-N03` →
> `FW-130` → `FW-133` — and **`FW-133` is 120 h of it.** Three quarters of the path is one
> story, and unlike 1B's path, nothing on it is blocked. The constraint is not a decision
> anyone owes; it is that **one story gates every screen in the programme**. See §3.
>
> **Building the 30 Sep trial rather than MVP-1?**
> [TrialOrchestration.md](../../40-backend/tasks/TrialOrchestration.md) sequences all
> 66 trial stories by sprint, including this stream's 20. It answers *what ships on 30 Sep*;
> this file answers *what can start*.

---

## 1. Status board

**49 stories carry FE hours** — Phase 1A's six (§1.1), three Phase-1A stories labelled `RT`
that are Angular code (§1.2), two trial-scope additions (§1.3), and **38 downstream across
Phases 3–14** (§1.4). Hours are `[TB §7]`'s, **quoted not restated**.

> **§1.1–§1.3 are Phase 1A and are what §2–§6 sequence.** §1.4's downstream stories sit in
> later phases and are ordered by sprint in
> [TrialOrchestration.md](../../40-backend/tasks/TrialOrchestration.md) and `[TB §7.2]`,
> not by wave here.
>
> **`plan` in the *Owning document* column is that story's own implementation plan** — nine of them,
> written 27 Aug 2026, each carrying its verbatim `[TB §7]` card, its build order, its verification and
> its blockers. Each sits **beside** the owning specification and **loses to it**, so a row naming both
> still resolves to the specification on any disagreement.
>
> **The shared context is not in the nine.** The measured checkout, the eleven integration points, the
> `F-##` decisions and the findings live once, in
> [`Phase-01A-ImplementationPlan.md`](Phase-01A-ImplementationPlan.md) — §2, §2.1, §4 and §6.

### 1.1 Phase 1A — FE 224 h

| Story | Subject | h | Wave | Owning document | Status |
|---|---|---|---|---|---|
| `FW-N03` | Angular library scaffold, routing, configuration | 24 | **0** | [`[CMP §5.1]`](../Components.md) · [`phase-01a`](../../60-delivery/phases/phase-01a-angular-foundation.md) · [`plan`](FW-N03.md) | 🟡 **Built, awaiting commit.** All three of [`plan §3`](FW-N03.md)'s commands pass — `npm run build` emits **`flat-wire.js` as a named lazy chunk**, `ng lint` is clean across all 32 targets, `npm run test:flat-wire` is **25 tests at 100 %** on all four metrics · ⚠ **Those figures now cover two screens, not the scaffold** — DB3 and DB1 were built on top of it · ⚠ **The working tree is the only copy**: `HEAD` holds **31** `angular.json` entries and no `flat-wire`. **Wave 1 opens on the commit** |
| `FW-130` | Shell layout and the **1920×1080** canvas | 16 | 1 | [`[VAL §7.5]`](../ValidationRules.md) · [`[CMP §7.4]`](../Components.md) · [`plan`](FW-130.md) | 🟡 **Partly built.** The shell layout and the **1920×1080** canvas exist on both screens, with the height **budgeted** rather than scaled ([`[UIC §4.1]`](../UIConventions.md)) · ⛔ **Not done**: the line card's payoff section and its components / die-life / SPC section; dark mode is unverified · ✅ **`G23` decided 27 Aug 2026 — 1920×1080** ([`P1A`](Phase-01A-ImplementationPlan.md) `F-14`), and **in the expensive direction**: +50 % width against +5 % height, 5:4 → 16:9, so **re-composition, not rescaling** · ⚠ **`FW-N03` ships the shell component**, so this story **fills in its layout**; no stylesheet is shipped |
| `FW-131` | Route guards, interceptors, error envelope | 12 | 1 | [`[SEC §8]`](../../Architecture/Security.md) · [`[API §1.2]`](../../Backend/APIs.md) · [`plan`](FW-131.md) | ⛔ Not started · ⛔ **`G6` is worse than filed** — the client has **no role source at all**, so the role guard cannot be **built** (§5) · ⚠ **No `FlatWireAuthGuard`** — no library in the repository defines a guard, and `FW-N03` wires `shared`'s |
| `FW-132` | DI-swappable API client and domain models | 20 | 1 | [`[CMP §5.3]`](../Components.md) · [`[API §7]`](../../Backend/APIs.md) · [`plan`](FW-132.md) | ⛔ Not started · ⛔ **its fixture list names three alphas the seeds never create** (§8.1) · ⚠ `G14` · **owes `TC-020`'s third leg** (`G56`, `P-84`) |
| **`FW-133`** | **Shared composite controls** | **120** | 2 | [`[CMP §7.6]`](../Components.md) · [`../Mockups/`](../Mockups/) · [`plan`](FW-133.md) | 🟡 **`gauge-trace-chart`'s foundation is built** — `lib-chart-canvas`, `lib-trace-panel` and `buildTraceConfig` are in **`projects/shared`** and consumed by DB3 · ⛔ **The other five controls, the runtime `isLive` contract and the SVG profile mode are untouched** · 🔴 **still the critical path** — 45 % of the layer, every screen depends on it, `[TRP]`: *"not trimmable"* · ⚠ **the 120 h is deliberately not restated and now overstates what is left** ([`plan`](FW-133.md)) |
| `FW-134` | Shared primitive controls and `alert-banner` | 32 | 2 | [`[CMP §7.6]`](../Components.md) · [`plan`](FW-134.md) | ⛔ Not started · ⚠ **two of its consumer slots already exist as inline markup** on DB1 — the alerts card and the line-card weight bars. When these controls land that markup is **replaced**, not left beside them |

### 1.2 Phase 1A — RT 44 h, and all of it is Angular

⚠ **These three carry the `RT` stream label and are `ual-angular` code.** The label says *when*
the work happens, not which repository it lands in — recorded at
[`TrialOrchestration.md §1.2`](../../40-backend/tasks/TrialOrchestration.md), which is
why the Backend folder deliberately does not plan them.

| Story | Subject | h | Wave | Owning document | Status |
|---|---|---|---|---|---|
| `FW-135` | `flat-wire-signalr.service.ts` — MessagePack, NgZone, ring buffer | 24 | 1 | [`[SIG §4]`](../../Architecture/SignalR.md) · [`plan`](FW-135.md) | ⛔ Not started · ⚠ **`G10`** — MessagePack is a new client dependency and `[SIG]` treats it as measure-first · ⛔ **It cannot connect** — `flatWireHubUrl` is `FlatWire/hubs/flat-wire` and the running hub is mapped at `/hubs/flatwire`; `FW-080` owes the re-map (§5) |
| `FW-136` | `MockSignalRService` and the typed event set | 12 | 2 | [`[SIG §5.2]`](../../Architecture/SignalR.md) · [`plan`](FW-136.md) | ⛔ Not started · **fourteen events + six markers**, matching `IFlatWireClient` name for name · ⚠ `[TB §7]`'s own acceptance criteria for this story enumerate **nine** ([`P1A §6.12`](Phase-01A-ImplementationPlan.md)) |
| `FW-137` | PWA cache sync and the reconnect banner | 8 | 2 | [`[SIG §4]`](../../Architecture/SignalR.md) · [`plan`](FW-137.md) | ⛔ Not started |

### 1.3 Trial scope — additive to `[CE §3b]`, offsets nothing

| Story | Subject | h | Owning document | Status |
|---|---|---|---|---|
| `FW-204` | Minimal landing route — the entry point while DB1 is out of trial scope | 8 | [`[SCR §7.2]`](../ScreenPlan.md) | ⛔ Not started · **retires when `FW-060` ships** · ⚠ **`/flat-wire` already resolves — to DB3, not to this story's tiles.** DB1's skeleton also exists, so **whether this story is still needed is an open question** ([`plan`](FW-204.md)) |
| `FW-214` | Simulator control console `DB-S1` — **standalone WinForms** (`D-33`) | **52** | [`[SIM §9]`](../../Architecture/MachineSimulator.md) · [`../mockups/simulator_console.html`](../mockups/simulator_console.html) | ⛔ Not started · ⚠ **not one of the fifteen dashboards** (`[SCR §7.1]`); ships with controls **greyed** until `FW-218` |

### 1.4 Downstream — 38 FE stories, Phases 3–14

Ordered by phase, not by wave. **Every one of them is downstream of `FW-133`, `FW-134` or
both**, directly or through a screen that is.

| Phase | Stories (h) | Owning specification |
|---|---|---|
| **3** | `FW-060` 44 · `FW-153` 20 | [`LineStatusOverview.md`](../../10-requirements/screens/LineStatusOverview.md) (DB1) · 🟡 **DB1 already renders** as `supervisor-dashboard.component` — **UI skeleton only**, every value placeholder, no streams, rail inert ([`FW-060`](FW-060.md)) |
| **4** | `FW-061` 36 · `FW-N01` 24 · `FW-209` 4 · `FW-226` FE 6 · `FW-227` FE 10 | [`RocCheckin.md`](../../10-requirements/screens/RocCheckin.md) (DB2) · [`RodPreCheckin.md`](../../10-requirements/screens/RodPreCheckin.md) (DB2A) |
| **5** | `FW-062` 32 · `FW-162` 20 · `FW-163` 20 · `FW-081` FE 4 | [`ActiveRunMonitor.md`](../../10-requirements/screens/ActiveRunMonitor.md) (DB3) · 🟡 **DB3 already renders** as `flat-wire-landing.component`, the default child of `#/flat-wire` — **UI skeleton only** ([`FW-062`](FW-062.md)). `FW-163`'s two behaviours exist **inline, not as controls**; `FW-081`'s FE maximise is **built as a popup** |
| **6** | `FW-063` 20 · `FW-073` 24 · `FW-065` 24 · `FW-070` 28 · `FW-071` 24 | [`WeldEvent.md`](../../10-requirements/screens/WeldEvent.md) · [`DieChangeAndManagement.md`](../../10-requirements/screens/DieChangeAndManagement.md) · [`SPCCheckpoint.md`](../../10-requirements/screens/SPCCheckpoint.md) · [`RollAdjust.md`](../../10-requirements/screens/RollAdjust.md) (DB11) |
| **7** | `FW-067` 20 · `FW-072` 24 · `FW-173` 20 | [`WipRejection.md`](../../10-requirements/screens/WipRejection.md) (DB8) · [`RodCheckout.md`](../../10-requirements/screens/RodCheckout.md) (DB12) · [`PartialRodReCheckin.md`](../../95-archive/design-notes/PartialRodReCheckin.md) *(rationale only — the rules are `RodPreCheckin.md` §7 / `RodCheckout.md` §7.2)* |
| **8** | `FW-124` 24 · `FW-064` 16 · `FW-178` 8 | [`SpoolQueue.md`](../../10-requirements/screens/SpoolQueue.md) (DB5A) · [`RocCheckin.md`](../../10-requirements/screens/RocCheckin.md) §4.3 (DB5) |
| **5/8 boundary** | `FW-202` FE 32 | [`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md) · ⚠ **must land before Phase 8 *starts***, not beside it · 🟡 **Part A's card and docked pill are already on the DB3 landing** — the milestone ladder, escalation and the live weight stream are still this story's ([`[UIC §3.16]`](../UIConventions.md)) |
| **9** | `FW-066` 24 · `FW-182` 24 · `FW-183` 40 · `FW-184` 16 | [`OutputCoilCompletion.md`](../../10-requirements/screens/OutputCoilCompletion.md) — **v1.1 owns DB7 and DB7b together** |
| **10** | `FW-189` 12 | FL3 variants of DB2 and DB3 |
| **11** | `FW-091` 8 · `FW-092` 8 · `FW-093` 8 · `FW-094` 8 · `FW-095` 8 | reports — ⚠ **four of the five are descope-ladder rung 6** |
| **12** | `FW-100` FE 24 · `FW-102` FE 12 · `FW-110` FE 8 | ⚠ `FW-110` is **rung 1 — the first thing off the plan** |
| **13** | `FW-194` 20 · `FW-054` 12 · `FW-003` 12 · `FW-195` 12 | `../../95-archive/design-notes/FlatWireShopfloorDashboards.md` *"Alloy Reference Data"* (MVP-1 reference data) |
| **14** | `FW-201` FE 16 | [`[UAT]`](../../Testing/UATPlan.md) |

> ⚠ **Five screens in `[SCR §7.1]`'s inventory are MVP-2 and have no story here** — DB9, DB9A,
> DB10, Die Management and OEE. Their mockups live in [`MVP-2/Mockups/`](../../../../MVP-2/Mockups/),
> **not** in [`../Mockups/`](../Mockups/). Do not build them, and do not read their presence in
> the inventory as scope.

---

## 2. Dependency graph

> **This graph is Phase-1A-scoped by design.** It shows §1.1–§1.2's nine stories and the two
> convergence edges that leave the layer. **§1.3's and §1.4's are deliberately absent** —
> merging a wave axis and a sprint axis into one diagram is how a map stops being readable.

```mermaid
graph LR
  N03["FW-N03 · library scaffold"]

  N03 --> C130["FW-130 shell + canvas"]
  N03 --> C131["FW-131 guards + interceptors"]
  N03 --> C132["FW-132 API client + models"]
  N03 --> C135["FW-135 SignalR client"]

  C130 --> C133["FW-133 composite controls · 120h"]
  C130 --> C134["FW-134 primitive controls"]

  C135 --> C136["FW-136 MockSignalR"]
  C135 --> C137["FW-137 PWA cache"]

  API(["1B · envelope + routes"]) -.-> C132
  SEED(["1C · seed fixtures"]) -.-> C132
```

**Waves** — level = 1 + the deepest dependency:

| Wave | Stories | Note |
|---|---|---|
| **0** | `FW-N03` | The single root. **Nothing else starts.** 🟡 **Built and awaiting commit** — the wave opens on the commit, not on the build |
| **1** | `FW-130` `FW-131` `FW-132` `FW-135` | Four unlock at once. ⚠ Two of them carry a blocker that outlives wave 0: `FW-131`'s role half (`G6`) and **`FW-135`'s hub path** (§5) |
| **2** | `FW-133` `FW-134` `FW-136` `FW-137` | ⚠ **`FW-133` is 120 h of this wave's 172** |

> **Two dashed edges leave the layer, and neither blocks.** `phase-01a`: *"This layer is not
> blocked by 1B/1C because it develops against the **mock** API + **mock** SignalR
> (`useMockData: true`)."* The convergence is on **shape**, not availability — and there are
> exactly two things to settle with 1B rather than assume: the flag is **`useMockData`** on
> both sides (`[API §7.1]`), and the **JSON naming policy** reconciling this library's
> `{success,data,errors}` against 1B's C# `{Data,Success,Errors}` is **1B's to configure**.
> ✅ **The second is now answered by the built service** — `FW-138` verified the envelope on
> the wire as `data` · `success` · `errors` · `errorCode`, **camelCase** (`P-06`, `P-56`).

---

## 3. The critical path — 160 h, and one story is 120 of it

```
FW-N03 (24) → FW-130 (16) → FW-133 (120)
                                  45 % of the layer; every screen depends on it
```

**160 h**, against the 60 h of the longest RT chain (`FW-N03 → FW-135 → FW-136`). Three
consequences, and the second is the one that decides staffing:

1. **Nothing on this path is blocked, and its first node is now built.** Unlike 1B, where the path's
   second node spent a fortnight waiting on `G6`, every 1A node is buildable today. `G23` shadowed
   `FW-130` and never stopped it; it is now **decided at 1920×1080**
   ([`P1A`](Phase-01A-ImplementationPlan.md) `F-14`), which removes the shadow and **adds composition
   work instead** — see §4. 🟡 **`FW-N03`'s 24 h is done but uncommitted** (§1.1), so the path is
   **136 h remaining** the moment it lands. ⚠ **The blocked node is off this path**: `FW-135`'s hub
   mismatch sits on the RT chain, not on `FW-N03 → FW-130 → FW-133`.
   ⚠ **`FW-130` is smaller than 16 h now describes** — `FW-N03` ships the shell component and no
   stylesheet is authored, so the *"tokens consumed, not authored"* basis prices work that no longer
   happens. **Flagged for `[CE]`, not re-estimated here** ([`FW-130 §5`](FW-130.md)).
2. **`FW-133` is not trimmable, but it is divisible — and those are different claims.**
   `[TRP §1.4]` says *"It is not trimmable"*, meaning **no control can be cut**; it does not say
   one developer must build all six. `pass-schedule-table`, `confirm-bar`, `gauge-trace-chart`,
   `tab-wizard`, `action-bar` and `payoff-weight-bar` are independent of one another and share
   only `FW-130`'s tokens. ⚠ **`gauge-trace-chart` is the one to start first** — it is the only
   member with a live-streaming contract behind it (`FW-081`, `[SIG §5.6]`) and the only one
   whose `isLive` input must be **runtime-switchable, not mount-time**, which Phase 8's FL2
   Live/Profile control and a hybrid FL3 run both require.
   🟡 **`gauge-trace-chart`'s foundation is already built** — the canvas, the Chart.js lifetime and
   the config builder are in `projects/shared` and drawing on DB3. **Its 120 h is deliberately not
   restated and now overstates what is left**; whoever reconciles the estimate should read
   [`FW-133`](FW-133.md), not infer effort from the number.
3. **FE compresses better than any other stream, and that cuts both ways.** `[TRP §1.4]` prices
   FE retention at **0.62** against RT's 0.75–0.90 — the most AI-assisted leverage in the
   programme sits on this path. It is also the stream `[DE §4.3]` warns *"is not the constraint"*,
   so compressing 1A does not shorten the programme; it only stops 1A from being the thing that
   holds up eleven phases of screens.

> *The 160 h is derived here for sequencing only. It re-states no published total and changes
> no figure in `[CE]`, `[DE]`, `[SSP]`, `[TRP]` or `[TB §7]`.*

---

## 4. Decision gates — and where each decision actually lives

⚠ **This file mints no decision ids, deliberately.** The `P-##` series belongs to
[`Backend/tasks/`](../../Backend/tasks/) and is continuous across that
folder; a second series here would collide in citation, which is the failure the `[GAP]`/`G##`
and `[SIG]`/`[RT]` shortcode rules already guard against. **FE decisions resolve in the registers
that own them**, and this table is the index.

| Decision | Blocks | Where it is decided |
|---|---|---|
| **`G23`** ✅ | `FW-130` → **every screen** | ✅ **Decided: the canvas is 1920×1080** ([`P1A`](Phase-01A-ImplementationPlan.md) `F-14`). The gap's own impact line priced this as *"a re-layout of every screen, not a rescale"*, and that price is **accepted, not argued with**: +50 % width against +5 % height and a 5:4 → 16:9 shape change. ⚠ **The mockups keep authority over content and lose it over composition** (`F-15`), and composition at the new canvas is **not in `[TB §7]`'s hours**. ⚠ **Still open underneath it:** the **panel diagonal** is recorded nowhere, and the 14 px floor is a dpi rule — [`P1A`](Phase-01A-ImplementationPlan.md) §6.10. ⚠ **`[GAP]` `G23` still says 1280×1024 and is still `Open`** — but **`[VAL §7.5]`, the row every other document derives from, reads 1920×1080**  |
| **no new styles** ✅ | `FW-130`, `FW-133`, `FW-134` | **The mockups' token stylesheet is not shipped into the repository.** Flat wire uses the **existing application styles** — Bootstrap 5.3.8, `src/styles/styles.scss` and its `_colors.scss` SCSS variables, `shared`'s components — and **a new style or class is written only when a requirement calls for one**. `[P1A §4]` **`F-03` is withdrawn**, `FW-130`'s step 2 with it. ⚠ **`--color-*` is defined nowhere in this repository** — the application's colour system is the SCSS variables in `src/styles/_colors.scss` |
| **the hub path** ✅ | `FW-135`, and `FW-080` in 1B | **The SignalR hub is `/hubs/flat-wire`** — kebab-case, matching the library name, and every document names it. ⛔ **The decision is made and the code is not**: `FW-080` maps `/hubs/flatwire` and owes the re-map, plus `FW-145 §3.5`'s token handler — §5 |
| **`D-06`** | `FW-133`, `FW-134`, every screen | **There is no Angular structural or UI template.** `checkin-precheckin`, `shop-floor*`, `common-grid`, `wip-rejection` and `slitter-*` are **not** to be copied; the only reuse is `shared`'s foundational services. ⚠ **`flat-wire` joins no build chain at all** — it is a routing application that publishes no bundle ([`P1A §2.1`](Phase-01A-ImplementationPlan.md)). `[ARC §2.2]` calls these *"the rules most likely to be broken by a developer working from habit"* — **settled, and the one most likely to be broken anyway** |
| **`D-08`** | `FW-061` | **Dashboard 2 is the six-step tab wizard**, `dashboard_2_rod_checkin.html`. The grid + progress-ring `- Old.html` is retired and was deleted 11 Aug 2026 — **the plain filename no longer refers to a retired screen**. `[ARC §13.1]` `D-08` |
| **`G18`** | — | ⚠ **A trap, not a gate.** The `--fw-*` prefix is **retired and there is nothing to migrate** — no mockup and no stylesheet uses it. Consume `--color-*` as-is. If it resurfaces from an older commit it is wrong. `[CMP §7.4]` |
| **`P-58`** / **`P-83`** | `FW-132` | **Fourteen canonical enums, mirrored in all three layers, and `LineId` is never narrowed** — line eligibility is a per-endpoint *shape* rule, so no screen gets an FL2 refusal free from enum membership. Settled in [`FW-147`](../../40-backend/tasks/FW-147.md); the TypeScript leg is **owed by `FW-132`** (`G56`) |
| **`P-53`** 🔴 / **`P-54`** | `FW-061`, `FW-N01` | **The service hosts no rod-receiving surface**, so **DB2's rod scan has no endpoint** — `GET /rod/{alpha}` was *"everything staging and check-in need in one round trip"*. `[API]`'s call, not a plan's. [`FW-138 §8.1`](../../40-backend/tasks/FW-138.md) |
| **`OI-05`** | `FW-061`, `FW-064` | ⚠ **`Bevel edge` must not be offered or accepted** — a live *fourth* edge vocabulary on the DB9/9A Generate modal with no domain value behind it. `EdgeType` is `Round`/`Square`, displayed *"Round Edge"* / *"Flat Edge"* through **one** pipe (`[API §2.1]`) |

---

## 5. Blocker calendar

| By | Blocker | Stops | Owning document |
|---|---|---|---|
| ✅ **Answered** | **`G23` — the canvas is 1920×1080** | ⚠ **The rework is now scheduled rather than risked.** The register's mitigation half-holds: `data-fit="fill"` already widens to the window, so width is the cheap direction and the height barely moves — but **no script re-composes a screen**, and 18 mockups are laid out for 5:4. **Two follow-ups, neither of them a build stop:** close `G23` in the register, and **get the panel diagonal** — the 14 px floor survives on the assumption that the panel is physically larger, not denser. ✅ **The resolution half of the ask is closed on our side** (`Q26`, 24 Aug 2026): the 1920×1080 requirement is with Tim and Charles **in writing**, so what remains is UA's answer, not our action. ⚠ **And `Q26` records an ambiguity that lands squarely on the dpi assumption** — Tim's phrasing was *workstation* resolution, which may not be the shopfloor HMI panel this question is about. **A workstation monitor and an HMI panel are different dpi classes**, so one answer may not cover both, and it is the panel's number `F-14` needs | [`[GAP]` `G23`](../../Development/GapsRegister.md) · [`Q26`](../../90-registers/Questions.md) · `[VAL §7.5]` · [`P1A §6.10`](Phase-01A-ImplementationPlan.md) |
| **Before `FW-131`'s role half** | ⛔ **`G6` — the client has no role source at all**: no role field on `LoginStatusDetails`, no role vocabulary in `shared.constants.ts`, no JWT decoder in the repository | ⛔ **Construction, not verification.** `FlatWireRoleGuard` **cannot be built** until a source is chosen. ⚠ **This row named `FlatWireAuthGuard` as the unaffected half until 1 Sep 2026 — there is no such guard.** Authentication is `shared`'s `AuthenticationGuard`, already wired by `FW-N03`, so **the auth half is not merely unblocked, it is done** ([`P1A §6.18`](Phase-01A-ImplementationPlan.md)); only the role half is blocked. Three options and a recommendation in [`P1A`](Phase-01A-ImplementationPlan.md) `F-12`; either way bind to one constants class, as `FW-145` does server-side | `[SEC §8]` · [`FW-145 §5`](../../40-backend/tasks/FW-145.md) · [`P1A §6.1`](Phase-01A-ImplementationPlan.md) |
| **Before `FW-135` connects** | ⛔ **The hub answers at `/hubs/flatwire`; every document names `/hubs/flat-wire`** | ⛔ **`FW-135`, entirely.** **[`FW-080`](../../40-backend/tasks/FW-080.md) is built on the old path and owes the re-map**, and it is **two lines, not one**: `app.MapHub<FlatWireHub>` and [`FW-145 §3.5`](../../40-backend/tasks/FW-145.md)'s `?access_token=` handler, which matches the same segment with `StartsWithSegments` and would otherwise answer **401 to a valid token**. ✅ `FW-145` is still `blocked`, so its half is free. ⚠ **Nothing is owed on the client side** — `FW-N03` already reads the value from config | [`FW-080 §0`](../../40-backend/tasks/FW-080.md) · [`FW-N03 §8·1`](FW-N03.md) · re-run `[DEP]` S5 / `TC-704` |
| **Before T2** | **`G10`** — IIS WebSockets on the target, and MessagePack as a new client dependency | Transport **silently** falls back to long-poll. **A provisioning task, not a build one**; `[SIG]` treats the package as measure-first | [`FW-080`](../../40-backend/tasks/FW-080.md) · `[DEP §4.4]` |
| **Before Phase 4** | **`G14`** — 3- vs 4-item inspection · `R#####` vs `ROD-#####` · `FootageFt` INT vs DECIMAL | ⚠ **`FW-132` bakes whichever it picks into the models every screen binds to.** The alpha-format half is ✅ **closed and verified** server-side — `Program.cs` requires `RodAlpha("ROD-00041")` to throw at boot — so **`R#####` is settled**; the inspection-count and footage-type halves are not | [`[GAP]` `G14`](../../Development/GapsRegister.md) |
| **Before Phase 4** | **`OI-109`** return-to-DB2A pending client confirmation · **`Q3`** · **`Q14`** · ⛔ **`Q22`** | `FW-061`. **`Q22` is the hard one** — the four tolerance values are **owed by e-mail and nothing is seeded**, so `CHK007` cannot be exercised at either station | [`RocCheckin.md`](../../10-requirements/screens/RocCheckin.md) |
| **Before Phase 8** | **`Q18`** — which order field carries the coil min–max weight range | Surfaced by `FW-163`'s `info-grid`; **blocks the FL2 DB3 variant** (`FW-178`) and `FW-202` | [`ActiveRunMonitor.md`](../../10-requirements/screens/ActiveRunMonitor.md) |
| **Before Phase 9** | ⛔ **`Q10` / `OI-45`** — the footage→weight **dimensional basis** | `FW-066`, `FW-183`, `FW-100` and `FW-202`. ⚠ **The one open question deliberately carrying no recommendation** — UA must answer it from its own practice — and the most widely depended-on number in the build. `[CE §2]` holds a **16–32 h reserve** against it | [`../../90-registers/Questions.md`](../../90-registers/Questions.md) `Q10` |
| **Before Phase 9** | **`OI-104`** no skid table · **`OI-105`** three weight figures with no precedence rule · **`OI-106`** no staging locations | `FW-182` (DB7b Packing). **All three are `G36`** — returning Phase 9 to MVP-1 imported three uncosted dependencies, every one of them on the packing side | [`OutputCoilCompletion.md`](../../10-requirements/screens/OutputCoilCompletion.md) |
| **Before Phase 11** | **`OI-101`** — shift boundaries are undefined | ⚠ Blocks **every shift-scoped figure**, including `FW-090`'s reporting views. *(DB10 itself is MVP-2.)* | master spec §11 |
| No date | **`G9` / `OI-34`** — real-time NFRs undefined | **Blocks validation, not build.** ⚠ **Not the cadence** — `[SIG §4.2]`/`§5.2` specify batched **~10 Hz**, which is what `MockSignalRService` emits at. What `G9` leaves open is the **AGC publish rate at source** (`PLC-Q11`), the **client count** and the **latency budget**  | `[SIG]` · [`FW-150`](../../40-backend/tasks/FW-150.md) |
| No date | **`G27`** / **`G28`** — the weld screen's rod queue and traceability chain lost their host; **FL2 may have no way to record a weld at all** | `FW-063`. DB4 was retired 1 Aug 2026 into DB2A's *Mark as welded* dialog, and **two things did not move with it** | [`WeldEvent.md`](../../10-requirements/screens/WeldEvent.md) |

---

## 6. Exit criteria → owning documents

`phase-01a`'s five. **The layer is not done until each maps to a signed-off owner.**

| # | Criterion | Owner |
|---|---|---|
| 1 | `flat-wire` builds, lints, reachable at `/flat-wire` behind **`AuthenticationGuard`** | `FW-N03` · [`[CMP §5.1]`](../Components.md), [`[CMP §5.2]`](../Components.md) · 🟡 **Met in the working tree** — builds (a named `flat-wire.js` lazy chunk), lints clean, and the route is wired behind the guard, with `#/flat-wire` redirecting to `flat-wire-landing`; ⚠ **none of it is committed** · ⚠ **No library in the repository defines a guard** — `FW-N03` wires `shared`'s and `FW-131` builds none ([`P1A §6.18`](Phase-01A-ImplementationPlan.md)) |
| 2 | Shell renders on the **1920×1080** canvas in light **and** dark; no `--fw-*` anywhere | **canvas:** [`[VAL §7.5]`](../ValidationRules.md) · `FW-130` · 🟡 **The canvas half is met** — both screens render at 1920×1080 with the height **budgeted**, not scaled ([`[UIC §4.1]`](../UIConventions.md)); ⛔ **dark is unverified** · ⛔ **The token half is not implemented**: `--color-*` is defined **nowhere in the repository** and no stylesheet ships it — no new styles are created. ✅ The `--fw-*` half passes trivially (`G18`) · ⚠ `phase-01a`'s own wording still says 1280×1024 |
| 3 | DI swaps real↔mock by `useMockData`; **mock returns the seed fixtures** through the `{success,data,errors}` envelope | `FW-132` — [`[API §7.1]`](../../Backend/APIs.md) · ⛔ **cannot be met as written**: three of the named fixtures do not exist (§8.1) |
| 4 | `MockSignalRService` drives a `gauge-trace-chart` live — rAF-throttled, OnPush, reconnect + group re-join simulated | `FW-133` · `FW-135` · `FW-136` — [`[SIG §5.6]`](../../Architecture/SignalR.md) |
| 5 | Jest smoke suite green | `FW-N03`…`FW-137` — 🟡 **Green, and well past a smoke suite**: `npm run test:flat-wire` is **25 tests across 6 suites at 100 %** statements / branches / functions / lines · ⚠ **it exercises the mock path only** (§8.1 finding 6) — **there is no API path to exercise**: the library contains no `HttpClient`, no service call and no subscription · 🔴 **`npm run test:shared` exits 1** on a **pre-existing** global branch shortfall (94.93 % against 95 %) traceable to an untested file that predates this work — it fails CI independently of flat wire |

---

## 7. Two tracks — know which you are building

| | **MVP-1** | **Trial (30 Sep)** |
|---|---|---|
| `FW-133` | **120 h** — all six composite controls | **75 h** ([`TrialOrchestration §2`](../../40-backend/tasks/TrialOrchestration.md)) |
| Screens | 15 dashboards | **6** |
| Landing route | DB1 (`FW-060`) | `FW-204`, until `FW-060` ships |
| Deferred FE | — | **DB1, DB2A + weld, die change, roll adjust, rod checkout, DB5A** — part of `[TRP]`'s 330 h |
| Hours basis | `[TB §7]` hand-coded | `[TRP §1.4]` AI-assisted, **0.62 FE retention** |

⚠ **The standing rule for a deferred feature is *grey the control and state "not in trial
scope"*, never delete it** (`[TRP §7]`). Deleting is rework when the feature returns.

⚠ **`[TRP]`: *"never mix a `[DE §2]` stream cell with a `[SSP §5]` one."*** The two models
re-derive on their own retention factors.

---

## 8. What this file does not cover

> **The scope, stated once.** This file sequences **Phase 1A** and maps **the FE stream
> downstream of it**. It plans no backend or database work — those are
> [`Backend/tasks/Orchestration.md`](../../40-backend/tasks/Orchestration.md)
> and [`Database/tasks/Orchestration.md`](../../30-database/tasks/Orchestration.md)
> — and it contains **no Angular code and no component design**. That is `[CMP]`'s and the
> mockups'.
>
> ⚠ **Silence is not coverage.** The exclusions are named, because a boundary that is only
> implied gets read as completeness.

| Item | Why |
|---|---|
| DB9 · DB9A · DB10 · Die Management · OEE | **MVP-2.** Mockups at [`MVP-2/Mockups/`](../../../../MVP-2/Mockups/); do not plan, estimate or implement them |
| `FW-215` | Simulator set — unscheduled and additive. ⚠ **`FW-210`, `FW-211` and `FW-212` are planned AND built, and `FW-213` and `FW-217` are planned**, all on 31 Aug 2026 — indexed at [`Backend/tasks/Orchestration.md §1.12`](../../40-backend/tasks/Orchestration.md). Only `FW-214`'s console is FE — and since `D-33` it is a **WinForms desktop tool**, carded `FE` because `FE` means the user-facing surface, not Angular — and only in trial scope. ⛔ **`FW-215` is owed one endpoint it is not carded for** — a configuration read, which is `G68` |
| The `[ARC §2.2]` reference rules | **Binding, and `[ARC]`'s.** Summarised as `D-06` in §4 and not restated |
| Pixel-level design | The mockups are **the pixel authority**. This file names which one owns a screen and stops there |

### 8.1 Six findings raised and deliberately not fixed

All six are other documents' to correct, so they are recorded here rather than edited:

1. ⛔ **Three seed fixtures in the mock-service instruction do not exist.** `[CMP §5.3]` and
   `phase-01a`'s *Dependencies* both tell `FW-132` to mirror `SP-00021`, `RUN-0042` and
   `RUN-0043`. **Measured against `Database/Schema/SQL/FlatWire_SampleData_*.sql` on
   27 Aug 2026:** the spool alphas are **`SP-00031`–`SP-00033`**, the run alphas
   **`RUN-0001`–`RUN-0005`**, and **`SP-00021` occurs only inside a comment** in the lookup
   seed. `R00041`–`R00043` and `PS-1100-FL1-003` are correct. `[DEP §4.2]`'s checklist was
   corrected on 26 Aug 2026 for exactly this; **`[CMP]` and `phase-01a` were not.** ⚠ The irony
   is load-bearing: `[CMP §5.3]` warns *"Older implementation documents use inconsistent
   fixtures — do not follow them"* while carrying three wrong alphas itself. **Exit criterion 3
   cannot be met as written.**
2. **`[SCR §7.1]`'s "27 HTML files" is stale — the folder holds 19.** Twenty-four across both
   scopes (19 here + 5 in `MVP-2/Mockups/`). §7.3's *"25 of 27 screens include it"* and
   *"26 of 27 files use `data-fit=fill`"* rest on the same figure. ⚠ **The named exceptions are
   right and only the denominators are wrong** — measured 28 Aug 2026, **17 of 19** include
   `flat-wire-topbar.js` (all but `coil-spinner.html` and `dashboard_2_rod_checkin.html`, which
   inlines its own app bar) and **17 of 19** use `data-fit="fill"`. ⚠ **The two figures no longer
   move together**: `dashboard_3_active_run_ual.html` loads the topbar but **deliberately omits
   `flat-wire-fit.js`**, whose hard-coded `DESIGN_W = 1280` would letterbox its 1920×1080 canvas.
   So *"clone Dashboard 12's skeleton, not Dashboard 2's"* still holds exactly as written.
3. **A fourth RT-labelled story is Angular, and `TrialOrchestration §1.2` names only three.**
   `FW-081`'s **RT 24 h** is *"RT live wiring across 6 event streams"* — ring buffer,
   `requestAnimationFrame`, outside NgZone — by its own rate-card basis, which is
   `ual-angular` code. The Angular repository therefore receives **at least four** RT-labelled
   stories, not three. Reported, not renamed: the stream label drives `[DE §2]`'s retention
   factors and relabelling would move published hours.
4. **`FW-061` is Critical MVP-1 and depends on `FW-010`, which is wholly MVP-2.** DB2 rod
   check-in *acknowledges a pass schedule*, and pass-schedule authoring left with Phase 2.
   MVP-1 only **reads** a schedule — but no phase file or plan says what `FW-061` binds to when
   nothing in MVP-1 authors one in production (`OI-110`). `[TB §7]`'s card carries the
   dependency and nothing resolves it.
5. **DB2's rod scan has no endpoint.** `P-53` withdrew `RodReceivingController` on 25 Aug 2026;
   `GET /rod/{alpha}` was *"everything staging and check-in need in one round trip"*
   (`[API §4.3]`). `FW-061` and `FW-N01` both read it, and with it go the carry-forward gate
   (`FR-043` needs `footageRunToDate`) and station switching (`Q24` needs `scheduledLineId`).
   Three options are in `P-54`; **it is `[API]`'s call and it lands on this stream.**
6. **1A's stated verification exercises the mock path only.** `phase-01a`'s *Testing* section
   lists guards, `flat-wire-api-mock.service`, `line-context`/`run-state` and
   `MockSignalRService` — **`flat-wire-api-real.service.ts` appears in no criterion.** With
   `[TS §1.2]` having withdrawn the backend's automated tests, the first thing that exercises
   the real client end to end is the QA0 walkthrough, which is a **backend** checklist
   ([`FW-138 §6.1`](../../40-backend/tasks/FW-138.md),
   `reviewer: TBD`). **No document names an FE reviewer for it.**
   ⚠ **Sharper than when it was filed:** the two screens built since exercise **neither** path —
   `projects/flat-wire` contains no `HttpClient`, no API service and no subscription at all, and
   every value on both screens is a literal. There is currently nothing for a mock service to feed.

---

## 9. Keeping this file true

- **An owning document changes → check §1's status and §5's calendar.** Nothing else here
  restates owned content, so nothing else drifts.
- **A blocker closes → strike it from §5** and update the owning document's open-items table.
- **Never add build detail here.** It belongs in `[CMP]`, `[SCR]`, `[VAL]` or the screen
  specification — **two homes is how the six PLC tag copies happened.**
- **Never restate an hour figure.** §1 quotes `[TB §7]`; §3's 160 h is derived for sequencing
  and is not a published total.
- **Never mint a `P-##` here.** That series is the Backend folder's and is continuous across it
  (§4).
- **A per-story FE plan gets written → its §1 row names the plan instead of the owning
  document**, and the plan then wins over this file exactly as the Backend plans do.
- Per repository convention, changes go in [`CHANGELOG.md`](../../CHANGELOG.md) — **do
  not add a change log to this file.**
