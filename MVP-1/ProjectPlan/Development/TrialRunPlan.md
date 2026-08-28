# Flat Wire Mill — Six-Screen Trial Run Plan (sign-off ~16 Nov 2026)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — **§1.4's controller counts 15 → 14 and 8 → 7** (`FW-138` `P-53`, no `/rod/**` surface); hours cells untouched so the workbook guards still pass, and ⚠ **DB2's rod scan has no endpoint** until `P-54` closes. Earlier the same day: **re-baselined at three resources × 6.5 h/day from 31 August: feature-complete Tue 3 Nov, sign-off ~Mon 16 Nov 2026.** §2 only — **no effort figure moved**, and 869 / 459 / 330 h and §4's allocation are untouched, which is why §3, §4 and §6 needed no edit. Two things invert: **the over-commitment is gone** (T1 was 102 % and T3 114 %; all three blocks now sit under capacity with 28 h of margin), and **no staffing option reaches 30 Sep** — even five resources land in early October. The 6.5 h is an **availability** figure, not the hands-on-keyboard reading in `[CE §4]`'s sensitivity table. ⚠ [`StaffedSprintPlans.md`](StaffedSprintPlans.md) and `[CE §4]` remain on the 8 h basis and now disagree with this document by design. *(previously August 22, 2026 — **§8’s count assertion is re-derived and now runnable** (32 · 50 · 57 · 2 · 1), with the `QUOTED_IDENTIFIER`/`Msg 1934` and false-`PRINT`-pass traps written down beside it *(previously August 18, 2026 — **`FW-219` enters the trial: the FL2/FL3 run-end write-back into the shared schema, 40 h AI-assisted / 56 h hand-coded, additive.** §5.3 is the reasoning; the short version is that `phase-05` routes the FL2 screen's *Complete Run* into `POST /coil/complete`, which wrote **only** `FlatWireDB`, so a completed trial coil was invisible to packing, shipping, cost and yield. **§4's "Phases 9–14 are wholly outside the trial" gains its first exception**, on the same reasoning §5.1 used for `FW-202`. New blocker **6** (`Q34`–`Q36`, which block a shared environment but not the build). **The published 832 / 462 / 409 h figures are unchanged and now understate by 40 h** — as with `FW-202`, the additive hours are stated here and not folded in. *(Earlier same day: **`D-32`: there is no shared-schema migration.** `FW-001` is **cancelled rather than deferred** — its −36 h stops being a debt owed to production — and `FW-002` (3 h) goes with it. ⚠ **The published 832 / 462 / 409 h figures are deliberately held**, so read them as 3 h conservative *(previously August 15, 2026 — **blocker 4 (`G6`) closed**: all six roles exist as JWT claims; its residual re-dated to the T1 QA0 walkthrough. Revision history in [`CHANGELOG.md`](../../../CHANGELOG.md))*)*))*
**Document Type:** Scoped delivery plan for the client-requested trial run
**Status:** Published — **three resources at 6.5 h/day reach 3 Nov on development alone; UAT still needs its own window, to ~16 Nov.** §2.2 prices what more resources would buy
**Owner:** Delivery lead / programme management
**Audience:** Development leads, delivery lead, programme management, client stakeholders
**Shortcode:** `[TRP]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../README.md)

---

> ## Read this first
>
> **This is a scoped subset, not a replacement for the plan of record.** [`StaffedSprintPlans.md`](StaffedSprintPlans.md)
> `[SSP]` remains the staffed plan for **all** of MVP-1 development — 103 stories, 1,396 h, finish 25 Nov 2026.
> This document covers only the **six screens the client requested for a trial run** plus what they depend on.
>
> **What the client asked for (14 Aug 2026):** six operator screens working for a trial run **finishing 30 Sep
> 2026**, with **UAT signed off inside that window**. PLC commissioning and the on-mill trial follow in October,
> consistent with `[SP §4.3]`.
>
> **Basis:** **AI-assisted**, per the client decision of 23 July 2026 — every figure here is a `[DE]` factor applied
> to a `[CE]` §3 column, or a `[SSP §5]` story hour. **Development only.** QA (+20 %, ~156 h), BA and contingency
> are separate streams and must not be booked against the capacity in §2.
>
> **⚠ The headline is not about the screens.** The six screens are **88 h** of Angular work. **Phase 1 — the
> platform, not started, whose hard gate was 14 Aug and was not met — is 459 h, 55 % of the trial.** Cutting
> screens is the weakest lever available to this plan; shortening Phase 1 is the strongest. Both client removals
> of 14 Aug together recovered **107 h**; one additional developer on Phase 1 for two weeks recovers more.

---

## 1. Scope

### 1.1 The six requested screens

| # | Screen | Mockup | Owning specification | Phase | Story | `FR-###` | `TC-###` |
|---|---|---|---|---|---|---|---|
| 1 | **DB2** Rod Check-in (FL1) | `dashboard_2_rod_checkin.html` | [`RocCheckin.md`](../Business/Screens/RocCheckin.md) | 4 | `FW-061` | FR-063–084 | TC-070…109 |
| 2 | **DB3** Active Run (FL1) | `dashboard_3_active_run.html` | [`ActiveRunMonitor.md`](../Business/Screens/ActiveRunMonitor.md) | 5 | `FW-062` | FR-100–120 | TC-130…159 |
| 3 | **DB6** SPC Checkpoint *(dialog)* | `spc_checkpoint.js` | [`SPCCheckpoint.md`](../Business/Screens/SPCCheckpoint.md) | 6 | `FW-065` | FR-180–196 | TC-220…244 |
| 4 | **DB8** WIP Rejection *(dialog)* | `wip_rejection.js` | [`WipRejection.md`](../Business/Screens/WipRejection.md) | 7 | `FW-067` | FR-290–299 | TC-355…369 |
| 5 | **DB5** Spool Check-in (FL2) | `dashboard_5_spool_checkin.html` | [`RocCheckin.md`](../Business/Screens/RocCheckin.md) §4.3 | 8 | `FW-064` | FR-090–096 | TC-110…118 |
| 6 | **DB3** Active Run (FL2) | `dashboard_3_active_run_fl2.html` | `ActiveRunMonitor.md` | 8 | `FW-178` | FR-109, FR-120 | TC-137 |

**Two of the six are launcher pages, not screens.** `dashboard_6_spc_checkpoint.html` and
`dashboard_8_wip_rejection.html` became launchers on 1 Aug 2026; the screens live in `spc_checkpoint.js` and
`wip_rejection.js`. **Build them as `MatDialog` components, not routes** — WIP rejection is raised from five
different places and each supplies its own material context.

### 1.2 Adjacent items in scope

| Item | h | Why it is not optional |
|---|---|---|
| **Pause / Resume** dialogs | 20 | Both active-run screens carry a Pause button, and DB6 is reached through the pause dialog's *Manual SPC measurement* route. Without it two requested screens ship with a dead control. FR-260–266, TC-315…329 |
| **FL1 run completion → `SpoolProcessing`** (`FW-202`) | **67** | ⚠ **Inside screen #2's approved mockup, and the only thing that creates what DB5 checks in.** See §5.1 |
| **Minimal landing route** (`FW-204`) | 5 | Replaces DB1 as the entry point and the way back into a running line. **Retires when `FW-060` ships.** See §1.5 |
| **FL2/FL3 run-end write-back** (`FW-219`) | **40** | ⚠ **The trial's FL2 run has nowhere to land.** `phase-05` routes *Complete Run* to `POST /coil/complete`, and until 18 Aug 2026 that endpoint wrote **only** `FlatWireDB` — so a completed trial coil is invisible to packing, shipping, cost and yield. Client-directed. See §5.3 | 
| **Simulator console `DB-S1`** (`FW-214`) | 15 | ⚠ **Not a seventh screen and not a dashboard** — no `DB##` number, absent from the fifteen-dashboard inventory, the navigation map and the topbar tiles (`[SIM §9.1]`). It is the **engineer's half of the acceptance run**: UAT executes §8 in front of the client and step 7 times a **3 s stop against a 5 s dwell**, which is a button, not a saved HTTP request and a stopwatch. **Ships with unbacked controls greyed** — see §1.4 |

### 1.3 Total

| Block | AI-assisted h | Share |
|---|---|---|
| **Phase 1 platform** (1A Angular · 1B Backend · 1C Database) | **459** | **55 %** |
| Navigation, reconnect and the run index *(was Phase 3)* | 15 | 2 % |
| Phase 4 — rod check-in *(no DB2A staging)* | 74 | 9 % |
| Phase 5 — DB3 FL1 shell **+ the simulator console** | 89 | 11 % |
| Phase 6 — SPC + Pause/Resume *(no weld, no die change, no roll adjust)* | 56 | 7 % |
| Phase 7 — WIP rejection | 31 | 4 % |
| **FL1 spool completion — Part B** (`FW-202`) | **67** | **8 %** |
| Phase 8 — DB5 + DB3 FL2 | 38 | 5 % |
| **FL2/FL3 run-end write-back** (`FW-219`) | **40** | **5 %** |
| | **869 h** | |

| Stream | h | Share |
|---|---|---|
| **FE** Angular | 329 | 38 % |
| **BE** .NET | 264 | 30 % |
| **RT** real-time / PLC | 141 | 16 % |
| **DB** SQL Server | 135 | 16 % |

#### What the four streams are

The **delivery streams** of `[CE §1]`, which defines six — the two not costed here are **QA** (a separate ~156 h,
§9) and **BA** (Ops liaison and question closure, which does not compress at all).

| Stream | Surface | What it owns |
|---|---|---|
| **FE** | `ual-angular` → new library `flat-wire` (prefix `fw`) | Screens, dialogs, shared controls, SCSS against the existing token set |
| **BE** | `ual-api` → new `FlatWire` microservice | Controllers, MediatR commands/queries, services, validation, auth |
| **DB** | SQL Server → new `FlatWireDB` ~~+ the shared-schema `FW-001` renames~~ *(cancelled 18 Aug 2026, `D-32`)* | DDL, seed data, indexes, EF/Dapper mapping, repositories |
| **RT** | `FlatWireHub` · OPC ingest · `PLCTagService` | **Real-time and PLC integration** — see below |

**`RT` is the one worth spelling out, because this plan leans on it and it is not simply "the SignalR bit".** It is
a separate stream rather than part of FE or BE precisely because it **spans both**: the Angular SignalR client and
the .NET hub, ingest loop and tag push are one skill set, and splitting them across two owners is how a typed hub
contract drifts from its client. In this trial RT's 141 h is:

| Where | h | What |
|---|---|---|
| **1A** | 27 | `FW-135` SignalR client service · `FW-136` `MockSignalRService` · `FW-137` PWA cache + reconnect banner |
| **1B** | 75 | `FW-080` `FlatWireHub` (typed, MessagePack, line groups) · `FW-149` `IFlatWireClient` · `FW-150` cadence broadcast loop · `FW-151` `PLCTagService` + `SimulatePLCTagPush` · **`FW-205` `ITInhibitService`** · the OPC feed simulator |
| **Phase 4** | 11 | `FW-082` — the PLC tag group push on check-in acknowledgement |
| **Phase 6** | 7 | `FW-172` — run-event markers and the `LineStatus` transitions |
| **Phase 7** | 5 | `FW-177` — exception broadcasts |
| **`FW-202`** | 13 | the two spool-completion hub events (§5.1) |
| **Phase 8** | 3 | `FW-181` — the FL2 null-gauge contract and the Live/Profile binding |
| | **141** | |

**Two properties of RT drive decisions elsewhere in this plan.** It is **the stream that does not compress** —
`[DE §1]` puts OPC ingest and PLC tag push at retention **0.90** (*"integration against a real controller; not
verifiable without the hardware"*) and Phase 14 commissioning at **1.00**, against FE's 0.62 — which is why
`[DE §4]` finds RT's *share* of effort rises under AI assistance while every other stream's falls. And in this
trial it is also **the stream that does not spread** (§1.3 finding 2), which is why §2.1 gives it a dedicated owner
in T1 and pairs it with DB afterwards.

> **Do not read `RT` as a document shortcode.** `CLAUDE.md` is explicit that `[RT]` and `[DB]` are the **delivery-stream**
> codes, which is why the real-time *specification* is cited as **`[SIG]`** and the database design as **`[DBD]`**.
> `RT` in any table in this document means hours in a stream, never a reference to a file.

#### Phase × stream — the staffing grid

The two tables above cross-tabulated, because a phase total does not say whether it is an Angular problem or a
.NET one. **Every row is the sum of its own printed cells and every column sums to its printed total** — `[CE §3]`'s
convention, and verifiable by hand. Derived from the `[SSP §5]` story hours allocated in §4.

| Phase | FE | BE | DB | RT | **Total** | Sprint |
|---|---|---|---|---|---|---|
| **1A** Angular foundation | **139** | — | — | 27 | **166** | T1 |
| **1B** Backend foundation | — | **156** | — | **75** | **231** | T1 · T2 |
| **1C** Database foundation | — | — | **62** | — | **62** | T1 |
| Navigation, reconnect, run index | 12 | — | 3 | — | **15** | T2 |
| **4** Rod check-in | 24 | 24 | 15 | 11 | **74** | T2 |
| **5** DB3 FL1 shell **+ console** | **76** | 8 | 5 | — | **89** | T2 |
| **6** SPC + Pause/Resume | 30 | 13 | 6 | 7 | **56** | T2 · T3 |
| **7** WIP rejection | 13 | 8 | 5 | 5 | **31** | T3 |
| **`FW-202`** FL1 spool completion | 20 | **29** | 5 | 13 | **67** | T3 |
| **8** DB5 + DB3 FL2 | 15 | 12 | 8 | 3 | **38** | T3 |
| **`FW-219`** run-end write-back | — | **14** | **26** | — | **40** | T3 |
| | **329** | **264** | **135** | **141** | **869** | |

**Four things this grid shows that the phase totals hide:**

1. **Phase 1 is not one problem, it is three unequal ones** — 1A is **139 h of pure FE**, 1B is **156 BE + 75 RT**,
   1C is **65 h of pure DB**. They genuinely parallelise across different people, which is why T1 is the only
   sprint where a fifth developer pays for itself.
2. **RT is 102 of its 141 h inside Phase 1** — 27 in 1A (the SignalR client, `MockSignalRService`, the reconnect
   banner) and 75 in 1B (the hub, `IFlatWireClient`, the broadcast loop, `PLCTagService`, `ITInhibitService`,
   the OPC simulator).
   **Outside Phase 1 the whole RT stream is 39 h**, spread thinly across five blocks, so the RT owner must pick up
   DB or BE work from T2 or idle. That is `[DE §4]`'s finding sharpened: **RT is the stream that does not
   compress**, and in this trial it is also the stream that does not spread.
3. **`FW-202` is the only block in the trial that is BE-heavy** (29 of 67 h). Everything else is FE-led. It is also
   the last thing built and gates Phase 8 — so the BE owner's tail is the schedule's tail.
4. **DB is never the constraint after T1** — 65 of 112 h is Phase 1C. From T2 the DB stream is **47 h across seven
   blocks**, none larger than 15 h, which is why §2.1 pairs it with RT on one person rather than staffing it alone.

> **One story is dual-tagged and is counted as FE here.** `[SSP §5]` tags `FW-081` (`gauge-trace-chart` live
> streaming, maximize, runtime source toggle, 18 h) as **FE/RT**. It is counted wholly under **FE** in Phase 5,
> because the deliverable is an Angular component; splitting it 9/9 would move Phase 5 to FE 52 · RT 9 and the
> trial totals to FE 305 · RT 136. **Pick one reading and keep it** — the tables above use FE throughout.

### 1.4 Phase 1 in detail — 459 h, 55 % of the trial

Phase 1 is the largest block in this plan by a wide margin, it has not started, and its hard gate was 14 Aug and
was not met. It is broken out here at deliverable level because *"the platform is 459 h"* is not actionable and
*"the shared composite controls are 75 h of it"* is.

**Three bases, and they must not be mixed.** Hand-coded is `[CE §3]`'s and is the **base of record**; AI-assisted
is `[DE §2]`/`[SSP §5]`'s and is what this plan schedules; trial scope is AI-assisted **less three named
reductions**.

| | Hand-coded `[CE §3]` | AI-assisted, full | **Trial scope** | Reduction | T1 | T2 |
|---|---|---|---|---|---|---|
| **1A** Angular foundation | **370** | 166 | **166** | — | 166 | — |
| **1B** Backend foundation | **519** | 268 | **231** | −37 | 178 | **53** |
| **1C** Database foundation | **138** | 62 | **62** | — | 62 | — |
| | **1,027 h** | **496 h** | **459 h** | **−37 h** | **406** | **53** |

> ⚠ **Every 1C cell moved on 18 Aug 2026 and the reduction column emptied — `D-32`.** `FW-001` (36 AI-assisted) and `FW-002` (3) are **cancelled**, not deferred, so they leave the *AI-assisted full* column as well as trial scope: **101 → 62**, and 1C's **−36 trial reduction becomes zero** because there is nothing left to defer. Hand-coded **221 → 138** is re-read off `[TB]`'s Phase 1C reconciliation, as the note below requires. **1B's −37 is now the whole of Phase 1's reduction.**

> **The hand-coded column is `[TB]`'s, not `[CE §3]`'s original**, and it moves whenever a story is repriced.
> **Re-read it off `[TB]`'s `Phase 1X reconciliation` lines rather than transcribing it** — that is a build
> guard, added because a transcribed baseline goes stale silently.

**1B is the only sub-phase that crosses a sprint boundary.** Its T2 tail is `FW-150` (broadcast loop 11),
`FW-151` (`PLCTagService` + `SimulatePLCTagPush` 11), `FW-205` (`ITInhibitService` 14), the **OPC feed
simulator** `FW-203` (6) and its **control surface** `FW-218` (11) — they are last because they are the only 1B
work with nothing downstream waiting on it inside T1. **1A and 1C must
finish inside T1** or the whole T2 chain slips: 1A gates every screen and 1C gates every write. The T1 column sums
to **406 h**, which is §2.1's T1 figure — the two reconcile by construction, not by coincidence.

#### Phase 1 all-in, on the trial's own basis

Every figure elsewhere in this plan is **development only**. The hand-coded column above is all-in (it carries
`[CE §3]`'s QA and contingency), so the two are **not comparable as printed**. On the trial's AI-assisted basis,
with `[CE §2]`'s uplifts applied:

| | Dev | QA (+20 %) | Contingency (+15 %) | **All-in** |
|---|---|---|---|---|
| **1A** | 166 | 33 | 30 | **229** |
| **1B** | 231 | 46 | 42 | **319** |
| **1C** | 62 | 12 | 11 | **85** |
| **Phase 1** | **459** | **91** | **83** | **633** |

*Rounding is **half-up per cell** and the total row is **the sum of the printed cells**, both per `[CE §3]`. Deriving
the total from 459 directly would give QA 92 / cont. 83 — a 634, one hour off. The cell-sum convention is kept anyway
so that every row and column verifies by hand.*

**Quote 459 h against a developer roster and 633 h against a budget — never the other way round.** The 633 h is
offered because a foundation phase is normally read for budgeting, and because comparing 459 against the
hand-coded 1,027 overstates the saving: the like-for-like comparison is **633 against 1,027**, a **38 % reduction**,
not the 55 % the dev-only figures imply. ⚠ **Both percentages fell on 18 Aug 2026 (from 43 % and 59 %) and that is not a worse result** — `D-32` cancelled `FW-001`/`FW-002` on **both** bases at once, so the hand-coded denominator shrank by more than the trial numerator did. The saving is smaller because the work is gone, not because the trial grew. `[DE §3]` makes the same caution about its own contingency line.

#### 1A Angular foundation — 166 h (FE 139 · RT 27)

| Deliverable | Hand-coded | Story | **Trial h** |
|---|---|---|---|
| Library scaffold, routing and configuration | 24 | `FW-N03` | 15 |
| Shell layout and the 1280×1024 shopfloor canvas | 16 | `FW-130` | 10 |
| Route guards, interceptor wiring, error envelope | 12 | `FW-131` | 7 |
| DI-swappable API client and domain models | 20 | `FW-132` | 12 |
| **Six shared composite controls** @ 20 h | **120** | **`FW-133`** | **75** |
| Four shared primitives + `alert-banner` @ 8 h | 32 | `FW-134` | 20 |
| SignalR client service | 24 | `FW-135` | 15 |
| `MockSignalRService` + the typed event set | 12 | `FW-136` | 7 |
| PWA cache sync and the reconnect banner | 8 | `FW-137` | 5 |
| | **268** base → QA 54 → cont. 48 = **370** | | **166** |

**`FW-133` is 45 % of 1A and the single largest story in the trial.** The six controls are `pass-schedule-table`,
`confirm-bar`, `gauge-trace-chart`, `tab-wizard`, `action-bar` and `payoff-weight-bar` — **all six screens depend
on all six**, so it is not trimmable and nothing downstream starts without it. It is also the story whose 0.62
retention factor carries the most risk: if the mockups turn out to be less complete a visual spec than `[DE §1]`
assumes, this is where that shows up first.

**`FW-136` `MockSignalRService` is the keystone of stub-first delivery** (`[ARC §0.5]`). At 7 h it is the cheapest
schedule insurance in the plan — without it the whole FE stream queues behind 1B.

#### 1B Backend foundation — 231 h (BE 156 · RT 75) · **the largest sub-phase**

| Deliverable | Hand-coded | Story | Full | **Trial h** |
|---|---|---|---|---|
| `FlatWire` solution + four-project Clean Architecture skeleton | 16 | `FW-N04` | 11 | 11 |
| **Thin controllers over `UAController`** @ 3 h | **45** *(14)* | **`FW-138`** | 27 | **14** *(7)* |
| MediatR registration and pipeline behaviours | 16 | `FW-139` | 11 | 11 |
| DI registration and the stub/real service swap | 12 | `FW-140` | 8 | 8 |
| Repository layer | 28 | `FW-141` | 14 | 14 |
| Dapper/EF data access + `FlatWireDbContext` | 24 | `FW-142` | 16 | 16 |
| Serilog structured logging and the audit log | 12 | `FW-143` | 8 | 8 |
| Configuration binding | 12 | `FW-144` | 8 | 8 |
| JWT authentication and role authorization policies | 16 | `FW-145` | 11 | 11 |
| Global exception middleware and the response envelope | 8 | `FW-146` | 5 | 5 |
| FluentValidation and the canonical cross-layer enums | 12 | `FW-147` | 8 | 8 |
| Health checks | 8 | `FW-148` | 5 | 5 |
| `FlatWireHub` — strongly-typed, MessagePack, line groups | 28 | `FW-080` | 22 | 22 |
| `IFlatWireClient` typed event contract | 16 | `FW-149` | 11 | 11 |
| **OPC ingest hosted service + bounded channel** | **32** | **`FW-N05`** → **`FW-203`** | 22 | **6** ⚠ |
| Cadence-driven broadcast loop | 16 | `FW-150` | 11 | 11 |
| `PLCTagService` skeleton + `SimulatePLCTagPush` | 16 | `FW-151` | 11 | 11 |
| **`ITInhibitService`** — per-line tag write, conditions 3–5 | **16** | **`FW-205`** | 14 | **14** |
| **Domain model** — 7 aggregates, 13 value objects, invariants | **32** | **`FW-207`** | 21 | **21** |
| **Domain events** — post-commit dispatch to the hub | **8** | **`FW-208`** | 5 | **5** |
| ⚠ **Simulator control surface** — steer · stop edge · dropped readings · state read | **18** | **`FW-218`** | 11 | **11** ⚠ |
| | **373** base → QA 78 → cont. 68 = **519** | | **268** | **231** |

**Two trial reductions, both deliberate:**

> ⚠ **The controller counts above are 14 and 7, not 15 and 8 — `P-53`, 25 Aug 2026.**
> `RodReceivingController` is withdrawn from the service: rod receiving is not shopfloor. **The
> hours cells are deliberately unchanged** (45 and 14) — the rate-card basis becomes 14 × 3 h
> = **42 h** full and seven controllers trial, and both are **owed to the next re-baseline**
> rather than restated here, so `build_trial_run_xlsx.py` still reads the same figures.
> ⚠ **Of the trial's seven, only five serve a screen** — and the loss reaches T1: **DB2 rod
> check-in scans a rod**, which `[API §4.3]` served, so the trial has no scan validation, no
> carry-forward gate and no station switching until `[API]` re-homes it
> ([`FW-138`](../Backend/TaskBreakdownPlans/FW-138-Fifteen-Thin-Controllers.md) `P-54`).

- **`FW-138` 27 h → 14 h, and its baseline moved twice.** `[API §3.1]` now lists **fifteen** controllers, not
  thirteen — `PayoffStagingController` was never counted and **`SpoolController` was added 15 Aug 2026** — and the
  rate fell **4 h → 3 h** when automated backend tests were withdrawn (`[TS §1.2]`). The trial needs **eight**:
  Lines *(now the landing route)*, Rod, CheckIn, Run, Spc, WipRejection, **Spool** *(`GET /spools` **and**
  `POST /spool/complete`)* and Coil. `PassSchedule`, `PayoffStaging`, `WeldEvent`, `DieChange` and `RollAdjust`
  are out of trial scope.
  ⚠ **Health is not a controller** and is not the ninth: `GET /health` is `MapHealthChecks` middleware and
  appears in no controller list. Eight controllers @ 3 h = 24 h hand-coded, ×0.60 = **14 h**.
  ⚠ **Two of the eight carry no in-scope endpoint, and that is deliberate.** `LinesController` hosts only
  `/lines/status`, which **left with DB1** on 14 Aug (§1.5) — the landing route uses `GET /run/active?line=`
  instead; and `CoilController` hosts `/coil/**`, which is **Phase 9**, wholly outside the trial. Only **six**
  controllers serve a trial screen: Rod, CheckIn, Run, Spc, WipRejection, Spool. **The two are kept as empty
  scaffolds on purpose** — DB1 returns after the trial and Phase 9 is the next thing built, and a scaffold is
  where the de-stub pass hangs its fixtures. Restating to six would save **3 h** and re-baseline every total in
  this document for it; **the 14 h stands**, and this note is why. *(Do not "correct" the eight to six without
  re-running the workbook guards.)*
> ### The machine simulator — what the trial takes from it, and what it leaves
>
> A **machine simulator** was specified on 15 Aug 2026 —
> [`MachineSimulator.md`](../Architecture/MachineSimulator.md) `[SIM]`, stories **`FW-210`–`FW-215`** (111 h
> dev) and **`FW-217`** (+24 h) — a model of FL1/FL2/FL3 that runs a whole production run and reacts to the
> pass-schedule push, plus an engineering console `DB-S1`. **One 9 h increment of it is now in this plan; the
> other 126 h is not.**
>
> ⚠ **Why any of it is in a plan that otherwise excludes the simulator.** `FW-203` is a **publisher with no
> control surface** — `[SIM §1.2]`'s own comparison table marks it ❌ on *"an operator-drivable control
> surface"* — yet **§8's acceptance run has to steer it while a run is live**:
> step 3 forces N consecutive out-of-spec readings, step 7 needs a `RUNNING → STOPPED` edge at a chosen
> instant (`TC-171`'s **3 s stop against a 5 s dwell**, `TC-172`'s weight latched at that timestamp), and
> `FW-205`'s condition 5 can only be exercised by **dropping readings**. **Configuration plus a restart cannot
> do any of it** — it destroys the run being demonstrated, which is also what steps 7 and 10 are asserting
> about. **The trial would otherwise be specified to demonstrate behaviour it has no way to trigger.**
>
> **`FW-218` closes that** — four of `[SIM §8.1]`'s five endpoints (`steer`, `DELETE /run`, `fault` limited to
> dropped readings, and `GET /sim/state`), built over `FW-203` rather than over the line model, **11 h**. It
> is the **first increment of `FW-215`** exactly as `FW-203` is of `FW-211`. `[SIM §2.4]`'s rule travels with
> it: **when simulation is off the routes are not registered at all — `404`, not `403`.**
>
> **And `FW-214`, the console `DB-S1`, is in at 15 h — with controls greyed.** An API alone means UAT is
> executed by an engineer issuing HTTP calls beside the operators, and step 7 times a **3 s stop against a 5 s
> dwell**. ⚠ **Its own dependency is `FW-215` in full**, which needs `FW-210` (24 h) and `FW-213` (16 h) —
> **making every control live is +50 h AI-assisted and the window does not have it.** So the screen is built
> whole against `FW-218`'s four endpoints and the rest is greyed: **Start**, the **scenario picker**, **six of
> the seven fault buttons** and the **seed**. Live: stop, steer, drop-readings, the readouts, the dual state
> badges, and `lbPerFt` — **which displays NULL, putting `OQ-10` on screen instead of burying it.** Grey them,
> do not delete them; each returns as configuration. Same pattern as Die Change and Roll Adjust in §4.
>
> **Still out, deliberately:** `FW-210` (the kinematic model), `FW-211` (the seam), `FW-212` (the closed loop
> that converges on the pushed pass schedule), `FW-213` (the fault catalogue beyond one fault), `POST /sim/{lineId}/run`,
> and `FW-217` (the OPC sidecar). The trial does not need a machine that *reacts* — it needs a feed it can
> *steer*, and a screen to steer it from.
>
> - **`FW-203` is not rewritten, re-priced or superseded.** Its **8 h base / 6 h AI-assisted** figure stands.
>   The T2 close-out block it sits in is now **53 h** (`FW-150` 11 · `FW-151` 11 · `FW-205` 14 · `FW-203` 6 ·
>   **`FW-218` 11**).
> - **`FW-N05` is still deferred and still uncancelled.** Neither the simulator nor `FW-218` offsets its 32 h.
> - **`G39` applies to `FW-218` too** — steering an unverified model does not make it verified. See §9.
>
> The 111 h and this 26 h are all **additive to `[CE §3b]`**, on the same footing as `FW-202`, `FW-203` and
> `FW-204`. ⚠ **`FW-214`'s 24 h base is not additive twice** — it is the simulator set's own FE line, pulled
> forward out of the unscheduled 111 h rather than minted on top of it, so the set's remainder is **87 h**.

- ⚠ **`FW-N05` 22 h → a 6 h simulator.** `[DE §1]` prices real OPC ingest at retention **0.90** and calls it *"not
  verifiable without the hardware"*. Deferring it to the October commissioning window and driving the trial from a
  simulated feed is the single highest-value deferral in this plan: it moves 16 h *and* removes the trial's only
  hardware dependency. **The bounded-channel and broadcast-loop design must still be built to contract** so the
  real ingest drops in behind it — `FW-150` and `FW-151` are unreduced for exactly that reason.

**RT is 75 of 1B's 220 h.** `FW-080` + `FW-149` + `FW-150` + `FW-151` + `FW-205` + `FW-203` are the real-time
spine every later phase consumes (`[SP §6.3]`), and none of it compresses well — 0.75–0.90 against FE's 0.62.

#### 1C Database foundation — 65 h (DB 65)

| Deliverable | Hand-coded | Story | Full | **Trial h** |
|---|---|---|---|---|
| ⚠ **Shared-schema renames + new columns** — **CANCELLED, `D-32`** *(was 16 rename + 40 impact audit)* | 0 | **`FW-001`** | 0 | 0 |
| **`INFLAT` coil status** — **CANCELLED, `D-32`** *(was 4 h)* | 0 | `FW-002` | 0 | 0 |
| `FlatWireDB` creation, ordered DDL runner, indexes, grants | 12 | `FW-152` | 8 | 8 |
| Lookup group tables + seed | 16 | `FW-005` | 10 | 10 |
| `AlloyProperty` lookup + seed | 8 | `FW-004` | 5 | 5 |
| Materials group tables | 12 | `FW-006` | 8 | 8 |
| Runs and Quality/Output group tables | 52 | `FW-007` | 31 | 31 |
| | **100** base → QA 20 → cont. 18 = **138** | | **62** | **62** |

> **`FW-007`'s 52 h includes** the `RodStaging.Station` column and the `UX_RodStaging_Bay` re-key from
> `(LineId, PayoffPosition)` to `(Station, PayoffPosition)`, for **`G21`**. **The trial column is deliberately
> not re-derived**: that work is bay-uniqueness work, and DB2A left the trial on 14 Aug, so the
> +4 h is real on the hand-coded basis and absent from trial scope. The table still deploys (§8) — only the
> re-key does not.

⚠ **`FW-001` is now CANCELLED, not deferred — `D-32`, 18 Aug 2026.** Its −36 h is still the largest single reduction in the trial, but it is no longer a debt: there will not be any shared-schema migration, in the trial or in production. **`FW-002` goes with it (−3 h from T1's DB line).**

> ⚠ **The −3 h IS folded through, and it had to be.** §1.4's hand-coded column is **parsed from `[TB]`'s `Phase 1X reconciliation` lines by the workbook build**, so leaving 1C at 221 h against a backlog that now derives 138 h fails the build outright — that guard exists precisely to stop a transcribed baseline going stale. Folding one cell forces the rest, because §1.3, §2.1 and §2.2 reconcile *by construction*. **Everything moved together: 832 → 829 h · Phase 1 462 → 459 h · T1 409 → 406 h · DB 112 → 109 h · Phase 1 hand-coded 1,110 → 1,027 h · Phase 1 all-in 638 → 633 h.** Two second-order figures moved with them and are called out where they sit: the like-for-like reduction **43 % → 38 %**, and the 5→4 developer slack, which was **stale at 42 h** before this pass touched it.

The original deferral reasoning, retained: The `Coil/Bundle…`
slash-dual renames land on the **shared** `coils`/scheduling schema that the legacy `ual-dot-net` tier and existing
reports read — `[CE §2]` prices the rename at 16 h and the **impact audit across `united_db` and the legacy tier at
a separate 40 h**, and `phase-01c` flags *"high blast radius; front-load the impact audit."* **A trial does not need
it; production does.** ~~`FW-002` (`INFLAT`) stays, because check-in writes it.~~ — **superseded: `FW-002` is cancelled too.** Check-in still writes `INFLAT`, but to **`FlatWireDB`'s `Rod.Status`**, whose CHECK constraint already carries the value; nothing is needed in the shared schema.

> **⚠ `[CE §8]` records that 1C is understated, and `D-31` widened the gap.** It was costed against **22 tables**;
> the build is larger — `[DBD §6.2]` counts it. ⚠ **This derivation's basis is stale and is flagged, not
> substituted (26 Aug 2026):** it read *"the build is now **28**"*, true only between `D-31` (15 Aug 2026,
> which moved the three `PassSchedule*` tables into MVP-1) and the 20 Aug spool work — §8's live
> deploy confirmed 28 at the time. Each extra table is 4 h plus its QA and contingency share (~5.5 h all-in), so the
> understatement was **~33 h all-in on the hand-coded basis** against a build of 28, and is larger now. `[CE §8]` publishes no total at all. It is inherited here and **not** corrected
> in the 65 h above, because correcting it in place would drift `[CE §3b]`. Treat 1C as **65 h + ~21 h of known
> understatement on the trial's AI-assisted basis.**

#### One reconciliation to know before quoting these figures

**`[DE §2]` and `[SSP §5]` agree on every sub-phase total to within 1 h and disagree on the FE/BE/RT split by up to
19 h.** `[DE §2]` factors `[CE §3]`'s *phase* columns (1A: FE 224 × 0.60 = 134 · RT 44 × 0.75 = 33 = **167**);
`[SSP §5]` factors each *story* (1A: FE **139** · RT **27** = **166**). Same for 1B — `[DE]` BE 121 · RT 95 = 216
against `[SSP]` BE 140 · RT 77 = 217.

This is the same two-bases artefact `[SSP §2]` already documents at plan level (*"the per-stream figures sum to
1,406 h, not 1,396 h… the two disagree by 10 h"*). **This plan uses the story basis throughout**, because that is
what §4 allocates and what a sprint import reconciles to. **Quote sub-phase totals freely; do not mix a `[DE §2]`
stream cell with a `[SSP §5]` one.**

### 1.5 The two client removals of 14 Aug 2026, and what each takes with it

Both are defensible trial-scope calls. Neither is a clean subtraction, and the consequences below are stated so
they are decisions rather than discoveries.

#### DB1 Line Status Overview — **−42 h, +5 h back = −37 h net**

Out: `FW-060` (the screen, 31 h FE) and `FW-154` (`GET /lines/status` + `LineStatusService`, 11 h BE — a DB1-only
read; nothing else in trial scope calls it).

| Consequence | Handling |
|---|---|
| **Every one of the six mockups' back button targets `dashboard_1_line_status.html`**, and DB5's Cancel does too. The trial has no entry point and no way back into a running line | **A minimal landing route, 5 h** — a two-tile line picker routing to DB2/DB5 when a line is idle and DB3 when it is running. It reuses **`GET /run/active?line=`** (`FW-164`, already in scope), so it needs no new endpoint |
| **`FR-079a` — Acknowledge returns the operator to DB2A**, which is also now out of scope | **Acknowledge → DB3 active run.** That was the behaviour until 1 Aug 2026 and it is the natural trial flow. `TC-079a` does not apply; **`OI-109` was awaiting client confirmation anyway**, so nothing settled is being overridden |
| **The SPC dialog's read-only mode loses its only caller** — DB1's *"SPC · Last check 07:38 AM · In spec · View →"* | Keep the `readOnly` input on `fw-spc-checkpoint-dialog` so re-adding DB1 is not rework, but **no trial path exercises it** |
| ⚠ **`AlertRaised`/`AlertCleared` have no consumer.** DB1's alert bar was the only one | **The WIP rejection's supervisor alert has no visible destination in the trial** — the event fires and nothing displays it, so *"a rejection notifies someone"* cannot be demonstrated. Same class as gap **`G31`**. **Raise with the client** |
| **20 test cases drop out** — TC-490…TC-509 | Out of trial scope; they return with DB1 |

**Two things in the old Phase 3 row are *not* DB1's and stay:** `FW-153`'s **reconnect banner and cached-state
fallback** (`FR-119`/`NFR006` require it on every screen, and the acceptance run exercises it on DB3) and
`FW-155`'s **`FlatWireRun(LineId, Status)` index** (check-in's *single active run per line* rule and
`GET /run/active` both need it). **And the real-time backbone is untouched** — `FlatWireHub`, the OPC ingest and
the broadcast loop are **Phase 1B**, not Phase 3. Anyone reading *"Phase 3 removed"* as *"real-time removed"* has
it wrong.

#### DB2A Pre-Check-in + weld capture — **−70 h**

Out: `FW-N01` (the station, 16 h FE), `FW-158` (`PayoffStagingController`, 18 h BE), `FW-160`
(`PayoffStateChanged`, 8 h RT), the `RodStaging` **write path** (4 h DB, out of `FW-159`), `FW-063` (the weld
dialog, 13 h FE), `FW-166` (`POST /weldevent` + `WeldService`, 8 h BE) and the `WeldEvent` **write path**
(3 h DB, out of `FW-171`).

> ⚠ **Those two DB reductions are write paths, not tables.** `FW-007`
> in **1C** builds the whole Runs/Quality group, and §8 requires `FlatWire_DDL_RunAll.sql` to deploy **all 32
> tables, `RodStaging` and `WeldEvent` included** — *"do not remove them from the schema to match the trial's
> scope."* Reading the 7 h as *"the tables leave"* would double-count against 1C, which is unreduced. **The
> tables are created and go unwritten;** only the code that writes them is out.

> **This is 70 h, where §5.2 priced the block at 64 h.** That figure was the *incremental* cost over a plan that
> kept a trimmed 6 h staging controller to serve check-in's payoff read. With DB2A gone entirely there is nothing
> for it to serve, so the **full 18 h of `FW-158` leaves** and the removal is 70 h. The 64 h figure is retained in
> §5.2 as the audit trail for the correction it recorded.

**Two blockers leave the trial with it, which is the largest benefit of this removal:**

| Blocker | Why it goes |
|---|---|
| **`G21`** — `(LineId, PayoffPosition)` uniqueness across FL1/FL3 | It **blocked the Phase-4 schema freeze**, and it is a defect *in `RodStaging`*. No staging table, no gap in trial scope. **It remains open for MVP-1** |
| **`G26`** — the merged weld write straddles phases 4 and 6 | It existed only because DB2A's *Mark as welded* button shipped in Phase 4 against a Phase-6 endpoint. Neither is in the trial |

**And these are the costs:**

| Consequence | Handling |
|---|---|
| ⚠ **No weld markers on either gauge chart.** Phase 5's DB3 live trace and DB5's FL1 historical profile both specify vertical weld markers with rod alpha (`FR-093`, `FR-120`); with no `WeldEvent` rows there are none | Build both charts' marker layer — it is part of `FW-081`/`FW-064` and the data contract carries `weldMarkers[]` — but **it renders empty in the trial.** Do not delete it; an empty marker array is a legitimate state |
| ⚠ **The trial demonstrates a single-rod spool only.** No rod-to-rod join means no multi-rod genealogy, **no continuous feed through a weld, and the welding-wire customer-certificate chain is not exercised** | `CoilTraceability` genealogy is an **MVP-1 obligation** (`phase-09`, `NFR012`) and this is the one removal that touches it. **Raise with the client explicitly** — the trial will not show the traceability the certificates depend on |
| **55 test cases drop out, and 25 of them are labelled contractual** — TC-040…TC-069 (pre-check-in) and **TC-190…TC-214, which `[TCS §5.6]` heads *"the contractual suite"*** | A defensible scope call, but it should be a **visible** one at sign-off. The suites are unchanged and return with the feature |
| **DB2's payoff selector is now always editable** — `CHK005`'s pre-filled/read-only branch has no trigger | Build the direct-check-in fallback only. This is the simpler of the two paths `phase-04` describes |
| **`FW-202`'s source-rod list degrades to one rod** — its acceptance criterion reads *"source rods from the run's `WeldEvent` chain"* | Correct as written; with no welds the chain is one rod long. The story is **not** trimmed — it is MVP-1 scope and its criteria stay complete |
| **`PayoffStateChanged` has no publisher and no consumer** | Both ends were DB2A and DB1. Nothing else referenced it |

---

## 2. The capacity position

Working days **31 Aug → 3 Nov 2026: 46** — Labor Day (Mon 7 Sep) deducted, counted on `[CE §4]`'s grid.

> **⚠ Re-baselined 25 Aug 2026: three resources at 6.5 h/day, starting 31 August.** Both halves of that
> changed at once, and the second is the one that moves the date. The **17–28 Aug** period went to requirements
> work rather than build — the 24 Aug client call put it plainly, *"the full-fledged development will start from
> the Monday"* — so the clock starts **Mon 31 Aug**. And the team's committed availability is **6.5 h/day per
> resource**, not 8. See [`ClientCall_2026-08-24_SyncPlan.md`](../../../BaseDocuments/ClientCall_2026-08-24_SyncPlan.md) §3.4.
>
> **The 6.5 h is an availability figure, not a productivity figure**, and `[CE §4]` requires that reading be
> stated: each resource commits 6.5 h of the working day to flat wire and the balance goes elsewhere. **The
> estimates remain calendar-hour estimates and the 869 h does not move** — only the hours available per day do.
> This is *not* the hands-on-keyboard reading in `[CE §4]`'s sensitivity table; that one would additionally
> inflate the effort requirement, and nothing here claims it. Mixing the two, as that section warns, "either
> double-counts overhead or hides it."

| Measure | Value |
|---|---|
| Trial development effort | **869 h** — unchanged |
| 3 resources × 6.5 h | **19.5 h/day** |
| Working days needed | **44.6** — 46 once each block rounds to a whole day |
| Development window | **Mon 31 Aug → Tue 3 Nov 2026** = **897 h** |
| Utilisation, development alone | **97 %** — before one hour of QA |
| **Margin** | **28 h** |

**UAT cannot share a sprint with feature work.** `[SP §1.4]` states it independently of team size, and
`phase-14`'s own scope call is blunter: *"pull this into a dedicated post-feature-complete window regardless of
team size."* So UAT gets its own block after 3 Nov (T4 below) rather than overlapping T3.

> **What the re-baseline changed, and what it did not.** **The over-commitment is gone and the date has moved
> instead.** On the 8 h basis T1 planned 406 h against 400 h of capacity and T3 ran at 114 %, and §2.1 called T1
> *"the sprint that cannot slip"*; on 6.5 h days across a longer calendar **every block now sits under
> capacity**. That is the more honest failure mode and the easier one to manage — the plan is no longer
> pretending the work fits a window it does not fit. **What did not change is the shape:** Phase 1 is still 56 %
> of the work, the allocation in §4 is untouched, UAT still cannot overlap feature work, and **no effort figure
> moved** — 869 h, 459 h of platform and 330 h deferred all stand exactly as before.

### 2.1 The shape — three resources, three blocks of work

**T1, T2 and T3 are blocks of work, not two-week sprints.** They carry exactly the content §4 allocates to
them; what the re-baseline changes is how long each one takes at 19.5 h/day. Nothing has been re-cut, which is
why §3, §4 and §6 are untouched by this revision.

| Sprint | Dates | Wk days | Team | Capacity | Planned | Util | Content |
|---|---|---|---|---|---|---|---|
| **T1** | Mon 31 Aug – Tue 29 Sep | 21 | **3** | 410 h | **406 h** | 99 % | Phase 1A ∥ 1B ∥ 1C |
| **T2** | Wed 30 Sep – Tue 20 Oct | 15 | **3** | 292 h | **280 h** | 96 % | Phase 1 close-out · navigation · 4 · 5 · 6 (start) |
| **T3** | Wed 21 Oct – Tue 3 Nov | 10 | **3** | 195 h | **183 h** | 94 % | 6 close · 7 · spool completion · 8 · **run-end write-back** |
| | **— feature complete Tue 3 Nov —** | **46** | | **897 h** | **869 h** | **97 %** | |
| **T4** | Wed 4 Nov – Mon 16 Nov | 9 | 3 + QA + BA | 176 h | **unsized** ⚠ | — | Regression · **de-stub pass** · defects · **UAT + sign-off** |

**Three-resource split: 1 FE · 1 BE/DB · 1 RT/FE**, per the 24 Aug call — two on the front end and Yogender on
the back end once the team is complete. **FE is 40 % of the work and is the binding constraint**, as `[SP §3]`
finds for the full plan, so the FE share is what to watch inside T1 rather than the block total.

> **T1 fits now, and that is the whole of the good news.** On the 8 h basis it planned **406 h against 400 h**
> and §1.4's dependency chain made it the one block that could not be allowed to run long; at 19.5 h/day over
> 21 working days it has **410 h of capacity for the same 406 h of work**. The three previously-recommended
> ways out — starting a day early, moving `FW-149` into T2, a sixth pair of hands — are **no longer needed and
> have been withdrawn**. **1A and 1C must still finish inside T1** or the whole T2 chain moves; that constraint
> is structural and survives the re-baseline.

**Margin: 28 h in total, spread across all three blocks** — 4 h in T1, 12 h in T2, 12 h in T3. That is better
than the 16 h this plan carried at 8 h/day *and* better distributed, since none of it used to sit in T1. It is
still **less than either reserve at its upper bound** (§2.3), so the reserves remain a programme-management
decision rather than something the schedule absorbs.

### 2.2 What each staffing option lands

| Option | Feature complete | Sign-off | Note |
|---|---|---|---|
| **3 resources** *(the baseline — §2.1)* | **Tue 3 Nov** | **~Mon 16 Nov** | 869 h ÷ 19.5 h/day = **44.6 working days** from 31 Aug, 46 once each block rounds. This is the staffed plan, not an option: it is what the team actually is |
| **4 resources** | ~Fri 16 Oct | ~late Oct | 26.0 h/day → **34 working days**. Buys back roughly **two and a half weeks**. The fourth pair of hands is worth most in T1, where the three tracks genuinely parallelise |
| **5 resources** | ~Wed 7 Oct | ~mid-Oct | 32.5 h/day → **27 working days**. Beyond T1 the chain is sequential, so the fifth resource returns much less than the fourth — see §3 |

**No staffing option reaches 30 September, and the three-resource row is not an option — it is the plan.**
Even five resources from 31 Aug land feature-complete in the first week of October, with UAT after that. The
honest published answer at three resources is **feature-complete 3 November and sign-off around 16 November**,
inside the planned Q4 2026 production window. The 4- and 5-resource rows are priced here so that the cost of
the date is visible — not because either is staffed.

> **`FW-219`'s 40 h no longer threatens a date — superseded 25 Aug 2026.** Until this re-baseline this callout
> recorded that the client-directed run-end write-back (§5.3) had consumed the five-to-four option's slack and
> left it 21 h short, with T3 at **114 %** of capacity. **On 6.5 h days T3 sits at 94 %** and the 40 h is
> absorbed. The scope itself is unchanged and remains non-optional.
>
> **One part of it survives and is not about capacity.** `FW-219` cannot start before `FW-066`, and `FW-202`
> must land before Phase 8 begins — so **T3 carries two ordered dependencies**, and a longer block does not
> loosen an ordering constraint. Sequence T3 from §3 rather than from its utilisation figure.

### 2.3 Reserves, excluded from the 869 h

| Reserve | h | Basis |
|---|---|---|
| `G2` / `OI-39` — cross-DB check-in recovery | **24–64** | `[CE §2]`. Phase 4's estimate is provisional until it closes |
| `OQ-10` / `OI-45` — footage→weight dimensional basis | **16–32** | `[CE §2]` prices it on Phase 9, but `TC-167`/`TC-168` put the same calculation in the spool-completion path this trial builds. See §5.1 |

Neither is a coding problem, so neither compresses under AI assistance. **The 28 h of margin in §2.1 covers
either reserve at its lower bound, and neither at its upper** — 24 h or 16 h fits; 64 h or 32 h does not. Both
together do not fit at any bound. **Nothing has first claim on it any more**, which is new: the re-baseline
removed T1's overrun, so the margin is genuinely uncommitted for the first time. If both reserves land, the
date moves, and that is a programme-management decision rather than something the schedule absorbs.

---

## 3. Sequencing

```
Phase 1 (1A ∥ 1B ∥ 1C) ──► navigation ──► Phase 4 ──┬──► 5 ──► {6-SPC · 6-Pause} ──► 7-WIP
                                                     └──► FW-202 spool completion ──► 8 (DB5 · DB3-FL2)
```

Derived from `[SP §6.1]`, narrowed to trial scope. **Must be sequential:** `4→5→6→7`, and `FW-202` before
Phase 8. **Parallelisable:** 1A/1B/1C against each other; SPC and Pause/Resume against each other once Phase 5
exists.

Two rules the schedule depends on:

1. **Stub-first is mandatory, not optional** (`[ARC §0.5]`). FE builds every screen against the DI-swapped mock
   API and `MockSignalRService` from Phase 1A. Without it the FE stream idles behind BE and the chain will not
   compress into T2.
2. **The de-stub pass in T4 is planned work, not contingency.** `[SP §2.3]` requires one: the check-in stub
   deliberately routes around `OQ-14`/`OQ-15` by assuming a single active schedule, and that assumption will not
   remove itself.
3. **`FW-218` gates the acceptance run, not any screen.** Nothing renders differently without it — which is why
   it is easy to drop and why dropping it is expensive. **Three of §8's ten steps cannot be executed at all**
   without a way to steer the feed mid-run (3, 7, and condition 5 of the interlock). It must land in T2 with
   `FW-203`, not be pushed into T4 alongside the run it is supposed to drive.

*`G26`'s cross-phase weld hazard no longer applies to this plan — see §1.5.*

---

## 4. Story → sprint allocation

Story ids are frozen and are the repository's join key — import against these. **`FW-130`–`FW-201` are all
allocated**, so this plan mints **`FW-202`**, **`FW-203`**, **`FW-204`** and **`FW-218`**, and pulls **`FW-214`** forward out of the unscheduled simulator set.
*(Note: `CLAUDE.md`'s "new work is minted at `FW-130`+" is stale. **`FW-216` is burnt** — deliberately unused,
`[TB]`'s simulator section — and `FW-217` is the OPC sidecar, which is why the new id is 218.)*

> **All four new stories are defined in `[TB §7]` and all four are additive to `[CE §3b]`** — none is folded into
> a published phase total. They are also **excluded from `[SSP §5]`'s allocation on purpose**, because that document
> is the full-scope plan of record and these are trial scope; the full-plan workbook reports them as excluded rather
> than absorbing them. **`FW-204` is the only one that is temporary** — it retires when `FW-060` ships, so it never
> enters the MVP-1 baseline at all. **`FW-218` is not temporary**: it is the first three endpoints of `FW-215`
> and survives into the simulator proper.

### T1 — Phase 1 platform · 406 h

| Stream | Stories | h |
|---|---|---|
| **FE** | `FW-N03` 15 · `FW-130` 10 · `FW-131` 7 · `FW-132` 12 · **`FW-133` 75** · `FW-134` 20 | **139** |
| **BE** | `FW-N04` 11 · **`FW-138` 14** *(8 controllers @ 3 h, not 13 @ 4 h)* · `FW-139` 11 · `FW-140` 8 · `FW-141` 14 · `FW-142` 16 · `FW-143` 8 · `FW-144` 8 · `FW-145` 11 · `FW-146` 5 · `FW-147` 8 · `FW-148` 5 · **`FW-207` 21** · **`FW-208` 5** | **145** |
| **RT** | `FW-135` 15 · `FW-136` 7 · `FW-137` 5 · `FW-080` 22 · `FW-149` 11 | **60** |
| **DB** | `FW-152` 8 · `FW-005` 10 · `FW-004` 5 · `FW-006` 8 · `FW-007` 31 | **62** |

`FW-133` (shared composite controls, 75 h) is the single largest story in the trial and **all six screens depend
on it** — `pass-schedule-table`, `confirm-bar`, `gauge-trace-chart`, `tab-wizard`, `action-bar`,
`payoff-weight-bar`. It is not trimmable.

### T2 — check-in and the run monitor · 280 h

| Phase | Stories | h |
|---|---|---|
| 1B close-out | `FW-150` 11 · `FW-151` 11 · **`FW-205` 14** *(`ITInhibitService`; needs `FW-151`)* · **`FW-203` 6** — OPC feed simulator, *in place of `FW-N05`* · **`FW-218` 11** — its control surface *(steer · stop edge · dropped readings · state read; §8 cannot be executed without it)* | 53 |
| navigation | **`FW-204` 5** — minimal landing route · `FW-153` 7 *(reconnect + cached fallback)* · `FW-155` 3 *(run index)* | 15 |
| **4** | `FW-061` 24 · `FW-157` 24 · `FW-159` 15 *(check-in write path + the `FlatWireDB`-local `INFLAT` write, `D-32`; **no `RodStaging`**)* · `FW-082` 11 | 74 |
| **5** | `FW-062` 17 *(FL1 only)* · `FW-162` 13 · `FW-081` 18 · `FW-163` 13 · `FW-164` 8 · `FW-165` 5 · **`FW-214` 15** — simulator console `DB-S1`, *unbacked controls greyed* | 89 |
| **6** *(start)* | `FW-065` 15 · `FW-071` 15 · `FW-168` 8 · `FW-170` 5 · `FW-171` 6 *(SPC + pause tables; **no `WeldEvent`**)* | 49 |

### T3 — exceptions, completion, FL2 · 183 h

| Phase | Stories | h |
|---|---|---|
| 6 close | `FW-172` 7 | 7 |
| **7** | `FW-067` 13 · `FW-174` 8 · `FW-176` 5 · `FW-177` 5 | 31 |
| **new** | **`FW-202` 67** — FL1 spool completion, Part B *(98 h hand-coded)* | **67** |
| **8** | `FW-064` 10 · `FW-178` 5 · `FW-179` 12 · `FW-180` 8 · `FW-181` 3 | 38 |
| **new** | **`FW-219` 40** — FL2/FL3 run-end shared write-back *(56 h hand-coded)* | **40** |

**`FW-202` must land before Phase 8 starts, not beside it** — it writes the `SpoolProcessing` row DB5 reads. In a five-day
sprint that is a real sequencing constraint, not a formality.

### Deferred — still MVP-1, out of the trial · 330 h

| Deferred | h | Why it is safe to defer for a trial |
|---|---|---|
| **DB1** `FW-060` + `FW-154` | 42 | Client direction, 14 Aug 2026. See §1.5 for what goes with it |
| **DB2A + weld** `FW-N01`, `FW-158`, `FW-160`, `FW-063`, `FW-166` + 2 tables | 70 | Client direction, 14 Aug 2026. See §1.5 |
| **`FW-001`** shared-schema renames — **CANCELLED outright, `D-32`, 18 Aug 2026; no longer a descope decision** | 36 | Highest blast radius in the plan — the `Coil/Bundle…` renames land on the shared `coils`/scheduling schema that the legacy `ual-dot-net` tier and existing reports read. **A trial does not need it; production does.** Keep `FW-002` (`INFLAT`) |
| **`FW-N05`** real OPC ingest | 22 | Factor **1.00** work — `[DE §1]` prices it as *"not verifiable without the hardware"*. Belongs in the October commissioning window; the trial runs on a simulated feed + `SimulatePLCTagPush` |
| **`FW-N06`** alert rules engine | 28 | Its only consumer was DB1's alert bar |
| **Spool completion Part A** (`FR-130`–`FR-136`) | 25 | Explicitly `Should` and *"advisory and non-blocking"*. **Part B is `Must` and stays** — see §5.1 |
| **`FW-073`** die change · **`FW-167`** | 23 | Grey the DB3 button; state "not in trial scope" |
| **`FW-070`** roll adjust · **`FW-169`** | 26 | FL2/FL3 only (`FR-107`–`FR-109`); grey on DB3-FL2 |
| **`FW-072`** rod checkout · **`FW-173`** · **`FW-175`** | 39 | Resume ships with three of its four outcomes; *Check out rod* disabled |
| **`FW-124`** DB5A spool queue · **`FW-N02`** | 19 | DB5's *Browse spool queue →* greyed. The scan still validates — `GET /spools` ships in `FW-179` |

Phases **9–14** (coil completion, FL3 hybrid, reporting, yield/cost, admin, integration) are outside the
trial **with one exception, added 18 Aug 2026: `FW-219`, the run-end write-back**, which is Phase 9 work
pulled in for exactly the reason `FW-202` was pulled in from Phase 8 (§5.1) — a requested screen routes
into it. **The DB7/DB7b screens stay out**; only the server-side transaction behind *Complete Run* comes in.
See §5.3.

---

## 5. Two estimate corrections this plan makes

### 5.1 FL1 spool completion is a specified subsystem costed at 3 hours

**It was first priced at 14 h in the working plan. That was wrong, and the correction is the most consequential
figure in this document.**

What is specified:

| Artifact | Content |
|---|---|
| [`BusinessRequirements.md`](../Business/BusinessRequirements.md) §5.5 | **`FR-130`–`FR-155` — 26 requirements.** Part A the advisory milestone ladder (`Should`); **Part B the PLC-confirmed stop confirmation (`Must`) — *"it is the gate on the spool completion transaction"*** |
| [`TestCases.md`](../Testing/TestCases.md) §5.5 | **`TC-160`…`TC-184` — 25 cases**, eleven of them **P1** |
| [`SpoolCompletionNotification.md`](../Business/Screens/SpoolCompletionNotification.md) | The owning specification, Parts A/B/C |
| [`SignalR.md`](../Architecture/SignalR.md) | Two hub events — `SpoolCompletionPromptDue`, `SpoolCompletionPromptResolved` — **server-owned state, persisted against the run, re-delivered on reconnect** |
| `spool_notification.js` | A built mockup component, **included at `dashboard_3_active_run.html:1396`** |

What is costed: **`FW-N02`, 3–4 h RT**, whose acceptance criteria cover only the weight milestones and the
machine-stop confirmation.

**Three consequences:**

1. **This is not adjacent scope — it is inside screen #2.** `spool_notification.js` is one of the seven
   run-event scripts and is loaded by the DB3 FL1 mockup the client explicitly asked for. Building `FW-062` to
   its approved mockup means building this.
2. **It is the transaction that creates the `SpoolProcessing` row DB5 checks in.** `phase-05` routes *Complete Run* to
   `POST /coil/complete` — **Phase 9's FL2 output-coil endpoint** (`FW-185`: *"coil alpha, genealogy, skid"*).
   **No story writes the FL1 TKUP-1 spool.** Without Part B, **DB5 has nothing to check in and the FL1→FL2 trial
   cannot be demonstrated at all.**
3. **Part B is genuinely hard.** A server-owned prompt state machine — armed only at or above target (`FR-140`),
   fired on the `RUNNING→STOPPED` **edge** exactly once per stop (`FR-141`), suppressed by a configurable dwell
   (`FR-142`), weight **latched at the PLC stop timestamp** (`FR-143`), surviving a browser refresh (`FR-144`),
   suppressed by an unrelated open pause (`FR-145`) — plus scale-vs-calculated weight basis, a ±2 % variance
   whose override **never disables commit** (`FR-152`–`FR-154`), and both weights persisted regardless of basis.

**Re-priced on `[CE §2]`'s rate card — twice, and the second pass is the one to use.** A first pass gave 52 h and
was arrived at too quickly; pricing each deliverable against the card and applying the matching `[DE §1]` factor
gives:

| | Rate-card items | Hand-coded | Factor | **AI-assisted** |
|---|---|---|---|---|
| **FE** | stop-confirmation dialog 12 · weight-basis/variance composite 20 | 32 | 0.62 | **20** |
| **BE** | `SpoolCompletionService` state machine 24 · `CompleteSpool` endpoint 6 · `lb-per-ft` derivation 12 | 42 | 0.58–0.70 | **29** |
| **RT** | 2 hub events @ 8 | 16 | 0.80 | **13** |
| **DB** | `SpoolProcessing` write path + index | 8 | 0.60 | **5** |
| | | **98 h** | | **67 h** |

**Part B is 67 h, not 52.** Part A ≈ 25 h and is deferred (§4). All-in on `[CE §2]`'s uplifts the base becomes
`98 → QA 20 → Cont 18 = **136 h**`, which belongs in an additive restatement and **not** in Phase 8's published
118 h. Tracked as gap **`G37`** and story **`FW-202`**; `FW-N02` retains Part A only.

> ⚠ **`FR-137` carries `OQ-10`.** The `lb-per-ft` derivation reads `united_db..alloys.alloy_density`
> cross-database, and the **dimensional basis is undecided**. `[CE §2]` prices it as a 16–32 h reserve on Phase 9,
> but `TC-167`/`TC-168` put the same calculation here. It is the most widely depended-on open number in the build
> and the one open question deliberately carrying **no recommendation**, because UA must answer it from its own
> practice.

### 5.2 DB2A + weld capture was ~64 h, not ~24 h — and 70 h once removed

**Retained as the audit trail for a correction, now that the block itself is out of scope (§1.5).** The screen
(`FW-N01`) is 16 h; making it work pulled in the `PayoffStagingController`, `PayoffStateChanged`, the `RodStaging`
table and the weld chain. The **64 h** figure was the *incremental* cost over a plan that kept a trimmed 6 h
staging controller to serve check-in's payoff read; with DB2A gone entirely that has nothing to serve, so the
**full 18 h leaves and the removal is 70 h.** Both figures are correct against their own baseline, which is
exactly the sort of thing that reads as a discrepancy later if it is not written down.

---

### 5.3 A completed trial coil was invisible to every downstream system

**This is not an estimate correction — it is scope the plan did not have, and the trial surfaces it whether or not
anyone planned for it.**

`phase-05` routes the FL2 active-run screen's **Complete Run** control to `POST /coil/complete`. That endpoint has
always written `CoilOutput`, `CoilTraceability` and the run header — all in `FlatWireDB` — and **nothing else**.
So a coil completed during the acceptance run exists to the flat wire module and to no one else: there is no
`coils` row, no order link, no genealogy, no cost record, no skid and no WIP log entry. Packing, shipping,
certification, cost and yield all read those tables.

**None of the seven shared objects was named anywhere in this repository before 18 Aug 2026** — `wip_skids`,
`wip_skid_coils`, `coil_slit_cuts`, `coil_gen_history` and `wip_log` had **zero** occurrences across every `.md`,
`.sql`, `.py` and `.html`. `wip_coil_orders` appeared only as a check-in write. This was not a deferred decision;
it was an absence.

**It closes `OI-104` as a side effect.** `CoilOutput.SkidId` has always been documented as pointing at "the
existing skid table", which *no document named, no story created and nothing verified*. It is
`united_db..wip_skids`, linked through `proddb..wip_skid_coils`, with numbers from `proddb..generate_new_skid_no` —
which is what `FR-339` required all along, so **`FR-339` becomes testable for the first time** and its
*"blocked on `G36`"* note is lifted.

| | Rate-card items | Hand-coded | Factor | **AI-assisted** |
|---|---|---|---|---|
| **DB** | the procedure — 8 writes, one transaction, retry contract | 32 | 0.75 | **24** |
| **DB** | `CoilOutput.CoilNo` / `SharedSkidNo`, 2 indexes, schema docs | 4 | 0.60 | **2** |
| **BE** | `CoilCompletionService` call, primary-rod resolution, retry / compensation, grants | 20 | 0.70 | **14** |
| | | **56 h** | | **40 h** |

The **0.75** on the procedure is deliberate and is not the 0.60 mechanical-DDL factor: this is a multi-database
transactional procedure against an undocumented legacy schema with active triggers, which `[DE §1]` prices as a
*non-trivial business service*. All-in on `[CE §2]`'s uplifts the base becomes
`56 → QA 11 → cont. 10 = **77 h**`, carried in an additive `[CE §3d]` and **not** folded into Phase 9's 222 h.
Story `FW-219`, gap **`G44`**.

> ⚠ **The procedure is drafted, and that is not the same as done.** Its nine steps, its 43- and 44-column lists
> and every column name are verified against the scripted DDL — that verification is what the 0.75 buys. What
> remains is the half AI does not help with: running it against a real `proddb` / `united_db` / `SlitterDB`,
> confirming the trigger side effects fire as read, and closing `Q34`–`Q36` with IT.

> ⚠ **This is Phase 9 work in a trial that excludes Phase 9, and the precedent is §5.1.** `FW-202` came in from
> Phase 8 because a requested screen's approved mockup contained it. `FW-219` comes in from Phase 9 because a
> requested screen's *Complete Run* button routes into it. **The DB7 and DB7b screens stay out** — only the
> server-side transaction comes in. §4's *"Phases 9–14 are wholly outside the trial"* is amended accordingly.

> ⚠ **What the trial will and will not prove.** It will prove the eight rows appear and that the skid rule holds.
> It will **not** prove the three values are right: `Q34` (the transaction token), `Q35` (`coil_status = 'ONSKID'`)
> and `Q36` (sample number / planned operations) are IT answers about *existing* consumers, and the impact audit
> that would have found them was cancelled with `D-32`. A trial in DEV cannot substitute for that conversation.

---

## 6. Blockers — what must close, and by when

**One of the five left with DB2A** (§1.5): **`G21`**, bay-uniqueness, which blocked the Phase-4 schema freeze and
is a defect *in `RodStaging`*. **`G26`** (the cross-phase weld write) was a sequencing hazard rather than a listed
blocker and went with the same removal. Both **remain open for MVP-1**; neither blocks the trial. **Four remain:**

> ### ✅ Blocker 1 closed — decision `D-31`
> *"The pass schedule is external and MVP-1 cannot create one"* blocked **both** check-in screens, i.e. the whole
> trial: `FlatWire_DDL_RunAll.sql` produced no schedule table, no schedule rows and no endpoint to fetch one.
> **The three `PassSchedule*` tables, their seed, their 10 FKs and their 6 indexes moved into MVP-1**, settling
> `[API §4.2]`'s open assumption in favour of the local-query option. A clean deploy now contains
> **`PS-1100-FL1-001`** (FL1, Standalone, Active) and **`PS-1100-FL2-002`** (FL2, **Standalone**, Active).
>
> ⚠ **The FL2 fixture is `PS-1100-FL2-002`, and the trial cannot run without it.** The other FL2 schedule —
> `PS-1100-FL2-001` — is **`Hybrid`**, and `FR-091`
> has DB5 validate the schedule's route mode against the **spool's origin route mode**. The trial's spool is
> produced by an FL1 **Standalone** run, so it had no FL2 schedule it could legally be checked in under and
> §8's one continuous journey could not complete. `PS-1100-FL2-001` was **demoted to `Inactive`** to make room:
> `UX_PassSchedule_OneActivePerLineAlloy` permits exactly **one Active schedule per line + alloy**, so the two
> cannot coexist. Gap **`G40`**. *(A hybrid run is an FL3 run and `PS-1100-FL3-001` already covers it, which is
> why the Hybrid FL2 row was the anomalous fixture of the two.)*
>
> ⚠ **Closed for the trial, not for production.** MVP-1 owns these tables and **never writes them** — no
> authoring surface, DB9/DB9A still MVP-2 — so nothing populates them in production. **`OI-110`**, carried in §9.
>
> **The numbering below is unchanged** (2, 3, 4) so existing citations to "blocker #3" still resolve; **`G38`
> is appended as 5** rather than renumbering.

| # | Blocker | Blocks | Needed by |
|---|---|---|---|
| **2** | **`OQ-22` — min/max tolerance values.** ⛔ Owed by the client by e-mail; nothing is seeded. `CHK007` is a band check at both stations | DB2 step 3, DB5 dimensions | Before T2 |
| **3** | **`G2` / `OI-39` — cross-DB check-in recovery undecided.** Check-in spans `FlatWireDB` + `coils` + `wip_coil_orders` + the PLC and is **not one ACID transaction** — describe it as compensating writes, never "atomic rollback" (`G16`). Carries the 24–64 h reserve of §2.3 | Phase 4 is provisional until it closes | Before T2 |
| **4** | ✅ ~~**`G6`** — roles not confirmed as existing JWT claims~~ **— closed 15 Aug 2026: all six exist on `ClaimTypes.Role`.** The DB2 supervisor overrides, the SPC skip, the WIP disposition and the spool weight-variance override are all reachable. ⚠ **Residual:** the claim **values** are coded rather than labelled and the mapping is unsupplied — those actions **build** but cannot be **verified** until it lands, and in the supervisor notification a wrong value fails **silent** | ~~Every role-gated action in the trial~~ → the T1 QA0 walkthrough only | ~~Before T1 closes (28 Aug)~~ → **before the T1 QA0 walkthrough** |
| **5** | ⚠ **`G38` — the durable spool-completion prompt has a column and no owner.** `FR-144` makes `SpoolCompletionPromptDue` **server-owned state, persisted against the run and re-delivered on group re-join** — the one event in `[SIG §5.2]` that is **not fire-and-forget**. The five prompt columns landed on `FlatWireRun` on 15 Aug, and `phase-01b` acceptance criterion 4 now requires the behaviour **in 1B**. **No line item in §1.4's 1B table covers it**, and `FW-202` — which owns spool completion — is **T3**. `TC-173` is **P1** and is §8 step 7. With backend tests withdrawn the failure is silent: the event is typed, everything compiles, the durability simply never happens | The spool-completion step of the acceptance run; the platform sprint cannot exit | **Inside T1**, with `FW-080` |
| **6** | ⚠ **`Q34` / `Q35` / `Q36` — three shared-schema values the run-end write-back cannot guess.** `FW-219` writes a finished coil into `proddb..coils`, `coil_gen_history` and `wip_log`, and each needs an eight-character transaction token (`Q34`, proposed `FWCOMPLT`), a coil status (`Q35`, proposed reusing `ONSKID`) and a sample number / planned-operations pair (`Q36`). All three are **IT questions about existing consumers** — which procedures, views and reports branch on those columns — and the impact audit that would have answered them was cancelled with `D-32`. **The build is not blocked**: each is a one-line change and the procedure isolates all three as named constants. **A shared environment is blocked.** `OI-114` (the cut-record sentinels) rides along and is genuinely unanswerable from the codebase — the five legacy non-slit writers disagree with each other | `FW-219` running anywhere but DEV; the §8 acceptance run if it is executed against a shared database | **Before the trial deploys outside DEV** — ask now, it is a short conversation |

**Second tier — none stops the build:** `OQ-10`/`OI-45` (§5.1 — ⚠ **stops nothing in the *build* but does stop an *assertion***: `AlloyProperty.LbPerFtFactor` is seeded **NULL, "OQ-10 PENDING"**, so §8 step 7's calculated net weight is NULL and the ±2 % scale-vs-calculated variance cannot execute. Either seed a **clearly-marked provisional** factor or accept that assertion as untestable at trial) · `OQ-76` (which identifier DB5 scans) ·
`OQ-15`/`OI-47` (hybrid-origin guard — ⚠ **undefined, not merely open.** `TC-118` is **P1** and its expected
result is *"Behaviour undefined — `OI-47`. Records observed behaviour; gate fails until specified,"* and
`[TCS §5.6]`'s coverage table says the same. The trial does not walk into it — `PS-1100-FL2-002` is
Standalone-origin against a Standalone schedule — but **it must be specified before Phase 8 ships for real**) · `OQ-14` (no-matching-schedule path —
stubbed to a single active schedule) · `OQ-18` (which order field carries coil min–max weight) · `OQ-79`
(short-close transaction) · `G9`/`OI-34` (real-time NFRs undefined, so the hub load test has no pass criteria).
⚠ **`G10` — IIS WebSockets must be enabled on the deployment target** and MessagePack is a client dependency the repo does not otherwise use. The trial leans on the hub for §8 steps 3, 7, 9 and **10 (reconnect and group re-join on staging)**; if `devual-uadev001` lacks the feature the transport silently falls back to long-poll and the cadence assertions change character. **Pre-check the environment before T2** — it is a provisioning task, not a build one.

⚠ **`G23` — the 1280×1024 shopfloor canvas has never been confirmed.** All
25+ mockups are authored to it, `flat-wire-fit.js` calibrates its 14 px floor against it, and **§7's DoD bar and
T4's UAT both assert conformance at 1280×1024 at 1:1** — against a question (`Q26`) that is still open with Tim.
**1920×1080 is 1.5× width and 1.05× height: a re-layout of every screen, not a rescale.** `data-fit="fill"` makes
a wider panel the cheap direction, so the exposure is bounded, but an answer arriving after T1 lands on finished
screens. **Chase it before T1 closes** — it is the one open item here that gets more expensive every sprint.

**`G28`** (whether FL2 ever welds spool-to-spool) is **moot for the trial** now that no weld is captured anywhere,
and stays open for MVP-1.

---

## 7. Build notes that will otherwise cost rework

- **FM2 has three stands** — `FM2_S1` (8″) → `FM2_S2` (6″) → `FM2_S3` (6″, non-bypassable), **edgers on S2 and
  S3 only**; roll diameter is data in `Stand.RollDiameterIn`. Anything showing four stands or a separate
  *8″ Roller* row is stale (decision **`D-26`**). **DB5 and DB3-FL2 are already correct — do not "fix" them
  back.** `TC-115` asserts exactly three rows.
- **FL2 broadcasts `null` live gauge/width.** The Live view must render an explicit empty state — *"No live gauge
  on FL2 · see Profile"* — and **must not draw a flat line at target**, which reads as a real in-spec
  measurement. The mockup animates a simulated trace only because a static prototype has no hub (`phase-08`
  §Real-Time). **This is the single most likely thing to ship wrong.**
- **Build the weld-marker layer even though it renders empty.** Both charts' data contracts carry
  `weldMarkers[]`; with no `WeldEvent` rows in trial scope the array is empty, which is a **legitimate state, not
  a defect** (§1.5). Deleting the layer is rework when weld capture returns.
- **The DB3 shell is built once in Phase 5 and *configured* by Phase 8** — `run-status-cards`, `info-grid`,
  `chart-tab-strip`, the intent-grouped `action-bar`, and a `gauge-trace-chart` whose `isLive` is
  **runtime-switchable, not a mount-time input**. FL1 and FL2 diverged once already and the 2 Aug 2026 mockup
  pass undid it. **Do not fork an FL2 copy.**
- **Never stack two dialogs.** SPC-suspend → WIP rejection, and pause → SPC, are hand-offs: close the current
  dialog, then open the next. Two live focus traps leave the operator unable to reach either. **The spool
  notification is the exception that proves the rule** — `FR-133`/`TC-163` require it to be non-blocking: no
  overlay, no backdrop, no focus trap.
- **Reference-code rules (`[ARC §2.2]`), binding.** Backend template is `API/Domain/CoilCheckin`;
  **`SlitterInterface` is explicitly not a reference**. There is **no** Angular structural template —
  `flat-wire` is all-new from the mockups, and `checkin-precheckin`, `shop-floor*`, `common-grid`,
  `wip-rejection`, `slitter-*` are not to be copied. Only the foundational `shared` services are reused.
- **DoD bar is unchanged in every respect but one** (`[SP §9.2]`): Jest 95 % coverage, UI conformance at
  1280×1024 at 1:1, **no text below 14 px**, tap targets ≥ 48 px, no hover-dependent action, no new `--fw-*`
  tokens. ⚠ **The exception: `.NET` carries no automated tests** — *"xUnit + validator tests"* was struck
  from the DoD on **15 Aug 2026** (`[TS §1.2]`). The trial therefore verifies the backend by **manual
  contract walkthrough**, which has to be staffed inside the window rather than assumed.

---

## 8. Acceptance — the trial run

**Per story:** the `TC-###` ranges in §1.1, each executed with at least one negative path and one permission case.

**Out of trial scope: ~173 cases.** Counting only the two client removals gives 75 and leaves the reader to
infer that everything else executes. It does not — §4 defers five more features, and their suites go with them:

| Out | Cases | Why |
|---|---|---|
| TC-040…069 · pre-check-in | 30 | DB2A removed, 14 Aug (§1.5) |
| TC-190…214 · weld genealogy — **the contractual suite** | 25 | weld capture removed, 14 Aug (§1.5) |
| TC-490…509 · line status | 20 | DB1 removed, 14 Aug (§1.5) |
| TC-250…264 · roll adjust | 15 | `FW-070`/`FW-169` deferred (§4) |
| TC-270…289 · die change | 20 | `FW-073`/`FW-167` deferred (§4) |
| TC-375…399 · rod checkout | 25 | `FW-072`/`FW-173`/`FW-175` deferred (§4) |
| TC-405…429 · coil completion | 25 | Phase 9, wholly outside the trial |
| TC-435…444 · packing | 10 | Phase 9, wholly outside the trial |
| TC-350…352 · wire break | 3 | `FR-280`–`FR-282` are *"Not deliverable"*; `G34` has no persistence target |
| | **~173** | |

⚠ **This matters to more than the QA plan.** §9's ~161 h QA figure is `[CE §2]`'s mechanical +20 % of the build
base — a **feature-volume proxy**, not a count of these cases — so it does not move. What moves is what the
trial can be *said* to have verified at sign-off: **the deferred suites are the ones that come back**, and
three of them (roll adjust, die change, rod checkout) have live mockups and greyed controls on screens the
trial does ship. **State the number at sign-off.**

**Schema** — deploy clean and confirm the count:

```powershell
cd "c:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_99_Teardown.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql
# expect 33 tables · 55 FKs · 70 index statements · 1 procedure · 1 trigger  (static count 26 Aug 2026;
#   69 index statements until Q89 added UX_CoilTraceability_ChildAlpha on 26 Aug 2026. The
#   22 Aug live-deploy figure of 34/57 predates the Q60 SpoolConfiguration merge -- re-deploy
#   owed. [DBD 6.2] is the defining site; verify with Tools/verify_schema_counts.py)
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql   # idempotent re-run
```

The line above is a comment, so it asserts nothing. Run this and read the numbers:

```sql
SELECT 'tables',   COUNT(*) FROM sys.tables            -- 32
UNION ALL SELECT 'FKs',     COUNT(*) FROM sys.foreign_keys   -- 50
UNION ALL SELECT 'indexes', COUNT(*) FROM sys.indexes        -- 57
    WHERE object_id IN (SELECT object_id FROM sys.tables)
      AND type <> 0 AND is_primary_key = 0 AND is_unique_constraint = 0
UNION ALL SELECT 'procs',    COUNT(*) FROM sys.procedures    -- 1  (sp_GetGaugeTrace only;
                                                             --     sp_IngestRodFromCoils ships in
                                                             --     Database/Scripts/, not in RunAll)
UNION ALL SELECT 'triggers', COUNT(*) FROM sys.triggers WHERE parent_class = 1;  -- 1
```

⚠ **Two traps when running DML against this schema by hand.** `sqlcmd` does not set `QUOTED_IDENTIFIER ON`, and several tables carry **filtered** indexes, so an `INSERT` fails with **`Msg 1934`** until you `SET QUOTED_IDENTIFIER ON`. And with `XACT_ABORT OFF` a failed `INSERT` **terminates only that statement** — a following `PRINT 'PASS'` still runs, so a hand-written check can report success while having inserted nothing. Assert with `COUNT(*)`, never by reaching a `PRINT`.

**Then assert the two fixtures the acceptance run depends on** — both cheap, and both the kind of thing that
fails at step 8 with an unhelpful message if it is wrong:

```sql
-- (a) FL2 has exactly one Active schedule and it is Standalone.
--     UX_PassSchedule_OneActivePerLineAlloy allows only one per line+alloy,
--     so a second Active FL2/1100 row is not a warning — it is a failed insert.
SELECT ScheduleId, RouteMode, Status FROM PassSchedule WHERE LineId = 'FL2';
--     expect PS-1100-FL2-002 Standalone Active · PS-1100-FL2-001 Hybrid Inactive

-- (b) No STANDALONE FL2 schedule engages FM1 (FL1's 12" mill).
--     Expect exactly one row today: PS-1100-FL2-002 — forced by
--     CK_PSC_FM1NotBypassable, which is line-blind. Gap G41.
--     When G41 closes this must return zero rows.
SELECT p.ScheduleId, c.ComponentName, c.State
FROM   PassScheduleComponent c
JOIN   PassSchedule p ON p.ScheduleId = c.PassScheduleId
WHERE  p.LineId = 'FL2' AND p.RouteMode = 'Standalone'
  AND  c.ComponentName = 'FM1' AND c.State = 'Active';
```

> ⚠ **Do not generalise (b) into *"a component's `Stand.LineId` must equal its schedule's `LineId`"*.** That
> assertion returns **18 rows** and most are legitimate: an **FL3** schedule drives `FM1` (FL1's) *and*
> `FM2_S1..S3` (FL2's) because FL3 **is** FL1 feeding FL2, and a **Hybrid FL1** schedule reaches FM2 for the
> same reason. The defect is the single narrow case above. **Do not add a trigger for it either** — this
> section publishes *"1 trigger"* as a verified count.

**The DDL builds all 33 tables** — including the three `PassSchedule*`, which joined MVP-1 on 15 Aug 2026 (`D-31`).
`RodStaging` and `WeldEvent` are created and simply go unwritten in the trial — do not remove them from the schema
to match the trial's scope. ⚠ **The counts above are from a live deploy, not arithmetic**, and `sp_ShiftSummary`
is deliberately **absent** (it is MVP-2's, for DB10). Any "25 tables / 33 FKs / 41 indexes" figure is pre-`D-31`.

**The acceptance run is one continuous FL1 → FL2 journey.** This is the only thing that proves the six screens
are a system rather than six pages, and it is what UAT executes:

> ⚠ **Four of these steps are driven from the simulator console (`FW-214`) over `FW-218`'s endpoints, not from
> an operator screen.** The operator drives the application; a test engineer drives the machine, from `DB-S1`. **`POST /sim/{lineId}/steer`** produces
> step 3's out-of-spec run, **`DELETE /sim/{lineId}/run`** produces step 7's stop edge at a chosen instant, and
> **`POST /sim/{lineId}/fault`** (dropped readings) is the only way to reach the interlock's condition 5.
> ⚠ **The console and its endpoints are `Engineer`/`Admin` and are not registered at all when simulation is
> off** — so `DB-S1` exists on staging and **cannot exist on a commissioned line** (`[SIM §2.4]`, `[SIM §8.4]`).
> **Plan the UAT session around this**: the engineer's console is part of the run, it is a second screen in the
> room, and the sequence should be rehearsed before operators are in it. ⚠ **Several of its controls are greyed**
> (§1.4) — brief the client, or the greyed scenario picker reads as a defect on the day.

1. **Landing route** — FL1 and FL2 both idle; each tile routes to its check-in screen.
2. **DB2** — scan a rod, clear all six wizard steps, select the payoff, **Confirm Schedule** (amber → green),
   against **`PS-1100-FL1-001`** — ⚠ **not `PS-1100-FL1-003`, which is seeded `Draft`** and must be *refused* with
   `SCHEDULE_NOT_ACTIVE` → 422. The seed carries Active/Inactive/Draft variants of the same line and alloy so the
   status gate is testable; `[API §7.2]` has the full mapping. Then
   Acknowledge. Assert **records are written before the PLC push**, tags push **only** on acknowledgement,
   **`Rod.Status` → `INFLAT`** *(`FlatWireDB`-local since `D-32`; the shared `coils` row is not written)*, run `Running`, and the operator lands on **DB3**.
3. **DB3 FL1** — live gauge/width streams with tolerance band. Force N consecutive out-of-spec readings
   (**`POST /sim/FL1/steer`**) → the auto-prompt SPC toast fires. Action bar has **exactly six buttons and no Roll Adjust** (`TC-135`, `FR-107`).
   **The weld-marker layer renders empty** — no welds are captured in the trial.
4. **Pause** → *Manual SPC measurement* → the pause applies, **then** the SPC dialog opens carrying the frozen
   footage. Never both at once.
5. **DB6 SPC** — record an out-of-spec reading → **Submit · suspend material** hands straight to **DB8** with the
   failing reading pre-filled and the coil `SPC-HOLD`.
6. **DB8 WIP** — Suspend requires an observation; submit sets the material status and files the WIP-Held queue
   entry. ⚠ **The supervisor alert fires with no screen to display it** (§1.5) — verify the event on the wire, not
   on a dashboard.
7. **Spool completion (`FW-202`)** — run to target, then stop the line with **`DELETE /sim/FL1/run`**. Assert: the prompt fires on the **edge**
   and only once (`TC-170`); a 3 s stop against a 5 s dwell raises **nothing** (`TC-171`); the weight is
   **latched at the PLC stop timestamp** (`TC-172`); **Escape and backdrop-click do not dismiss** (`TC-178`); the
   prompt **survives a browser refresh** (`TC-173`); Yes commits **before** it prints (`TC-175`). Result: a
   `SpoolProcessing` row with an `SP-#####` alpha, **one** source rod and its footage.
8. **DB5** — scan that spool, against **`PS-1100-FL2-002`** (FL2, **Standalone**, Active). The
   source-traceability panel shows **a single rod and no weld row**; the **historical** profile renders against
   the spool's own **0.110″** arrival gauge **with an empty marker layer**; **no visual-inspection section**
   (`TC-114`, `FR-095`); the FM2 table shows **exactly three rows** (`TC-115`) closing 0.110″ → 0.106″ → 0.103″
   → 0.100″; all five pre-flight checks pass; Acknowledge pushes FM2 tags.
   ⚠ **The schedule matters as much as the spool.** `FR-091` validates route mode against the spool's **origin**,
   and the FL1 leg is Standalone — so a Hybrid FL2 schedule refuses this check-in. `PS-1100-FL2-001` is seeded
   `Inactive` for exactly that reason (§6). ⚠ **The target is 0.110″, not the 0.113″ that appears in no seed** —
   `PS-1100-FL1-001` produces 0.110″ × 0.500″.
9. **DB3 FL2** — three FM2 rows, edgers on S2/S3 only; **Live shows its empty state and Profile stays static
   across several live ticks**; SPC and WIP Reject open over the live run; **no Weld and no Die Change**
   (`TC-137`, `FR-109`).
   ⚠ **The empty-state assertion is only correct because step 8 checked in a *standalone* schedule.** `FR-120`
   and `[SIG §5.3]` suppress live gauge/width for **FL2 in standalone mode** — not for FL2 as a line. Run this
   step against a Hybrid schedule and the assertion is wrong rather than merely unmet.
10. **Reconnect** — kill the hub mid-run: banner over cached last-known state, **never a blank screen**
    (`FR-119`/`NFR006`), backoff reconnect, group re-join, trace restored without a refresh.

**UAT (T4, 4–16 Nov):** operators execute steps 1–10 on staging (`devual-uadev001` or equivalent) on touch
screens, against the §7 DoD bar. **Sign-off is the trial deliverable.** PLC commissioning
([`PLCCommissioning.md`](../Testing/PLCCommissioning.md) — `C1` tag paths, `C8` AGC latency, `C11` FM2 station
names) and the on-mill trial follow in October, per `[SP §4.3]`.

---

## 9. Assumptions and known risks

> ⚠ **New 18 Aug 2026 — the trial writes into shared production tables for the first time.** Every earlier
> trial write was either `FlatWireDB`-local or a check-in touch into a column the legacy system already
> expects. `FW-219` (§5.3) creates a **finished-goods coil row, a skid and a WIP log entry** in `proddb`,
> `united_db` and `SlitterDB`. Three consequences worth stating before the acceptance run is scheduled:
>
> 1. **Run it against DEV copies until `Q34`–`Q36` close** (blocker 6). Nothing about the *build* is
>    blocked; what is blocked is writing a transaction token and a coil status that existing reports may
>    read, without knowing which reports those are.
> 2. **Two triggers fire side effects the trial did not previously exercise** — `coils_iud_tg` writes
>    `coil_link_master_coil`, and `WIP_SKIDS_AFTER_UPD` resets `Certs_Documents.Processed` on **insert** as
>    well as update. Both are correct and intended; neither is obvious from its name, and a reviewer seeing
>    certification documents re-queue after a trial skid opens should know it was expected.
> 3. **`OI-112` will bite on the second run of any line.** `FR-077` sets `wip_stations.coilno` at check-in
>    and **nothing clears it**, against a UNIQUE index on that column. This is a pre-existing defect the
>    write-back surfaced rather than caused, it is out of `FW-219`'s scope by design, and it is unspecified —
>    so plan on clearing the column by hand between trial runs, or specify the release first.

- **The `[DE §1]` retention factors are assumed, not measured**, and a factor error propagates to every figure
  here at once. The Aug-14 gate was the calibration point and was not met, so **this plan is uncalibrated** —
  T1's actuals are the first real signal. `[DE §6]`'s early check applies: five people should book ~200 h/week.
- ⚠ **The trial does not exercise weld traceability**, and `CoilTraceability` genealogy is the chain the
  **welding-wire customer certificates** are produced from (`NFR012`). A single-rod spool is a real case, but it
  is the easy one. **This is the largest single thing the 14 Aug removals give up** and it should be signed off
  knowingly, not discovered at certificate time.
- ⚠ **Automated E2E is not in this plan, and UAT's stated entry criterion therefore is not met by it.** `[TS §4.1]` makes **three green E2E runs** the entry criterion for UAT, and this plan commits to UAT signed off inside the window. **Automated E2E (`FW-120`–`FW-122`, plus the Playwright harness) is Phase 14 work and deliberately out of trial scope** — none of its ~152 h touches the 832 h here. **The substitute is §8's ten-step FL1 → FL2 acceptance run, executed manually**, recorded as a trial-scoped substitution in `[TS §4.1]` so the gate is met by something real rather than waived by omission. **What the substitute does not give you:** no FL3 hybrid, no weld traceability (out with the 14 Aug removal), and **no regression value** — a manual run proves the journey once, on one path, and proves nothing about the next change.
- ⚠ **The screens must carry `data-testid` even though E2E is out of scope.** The Playwright suite is Phase 14, but the screens are written **here**, in Phases 1A and 4–8. There are **zero** test hooks in any mockup today. Added during the build this costs minutes per component; retrofitted afterwards it is **~16 h of FE rework**. `[SP §9.2]`'s DoD now requires them — **this is the one E2E-driven obligation that lands inside the trial window.**
- ⚠ **Nothing populates the pass schedule in production.** `D-31` put the `PassSchedule*` tables into MVP-1 and
  closed this plan's first blocker, but **MVP-1 reads them and never writes them** — there is no authoring surface
  and DB9/DB9A stay MVP-2. `FlatWire_SampleData_Schedule.sql` covers the trial. **The trial will therefore pass
  without ever exercising the real population path**, which is the same class of risk as *"the trial proves the
  screens, not the machine"* below. Tracked as **`OI-110`**.
- **Nothing in the trial displays an alert.** With DB1 out, `AlertRaised`/`AlertCleared` have no consumer, so the
  WIP rejection's supervisor notification is verifiable only on the wire.
- **QA does not compress with development.** `[DE §0]` is explicit: building the same features faster does not
  shrink the test surface. The ~156 h QA figure is +20 % of the build base as a **feature-volume** proxy and must
  be staffed separately.
- **BA does not compress at all.** The blockers in §6 close at the client's pace, and two of the four are
  client-owned.
- ~~**`FW-001` deferral is a debt, not a saving.**~~ **RETIRED 18 Aug 2026 — `D-32` cancels the migration outright, so the deferral is a saving after all** and the 40 h audit is not owed to production. ⚠ **One debt does survive in a smaller form: `OI-111`.** Nothing now marks flat-wire material in `coils.coil_status`, and the audit that would have found which reports depend on it is cancelled with the change. The original wording: The renames must land before production and their 40 h impact
  audit across `united_db` and the legacy tier is not in this plan.
- **The trial proves the screens, not the machine.** Every line runs `SimulatePLCTagPush` and a simulated OPC
  feed. **Nothing in this plan verifies a single tag path against a controller** — that is `C1`/`C11` in October,
  and `G32`/`G33` record that the whole tag map is currently `[PROPOSED]`.
  ⚠ **`FW-218` makes this more comfortable, not more true.** A steerable feed means the acceptance run is
  reproducible and the awkward cases (a 3 s stop, a dropped reading, a drift into out-of-spec) can be shown on
  demand — which is exactly the *"convincing simulator"* `G39` warns about. **What we can steer, we have not
  verified.** The trial's `FW-218` and the simulator's `FW-210`–`FW-215` sit on the same side of that line.
- **Four deferred items are re-entry points, not deletions.** DB1, DB2A + weld, the die-change and roll-adjust
  dialogs all have live requirements, test suites and mockups. Keep their inputs, marker layers and greyed
  controls in place so their return is configuration rather than rework.
- ⚠ **`ITInhibit` ships with three of its five conditions.** `FW-205` (conditions 3–5 — feet data unavailable,
  invalid, or two consecutive recordings missing) is in T2. **`FW-206` (conditions 1–2) is in no sprint at all**,
  and condition 1 is *"no coil or rod is checked in"* — precisely the state every check-in demonstration starts
  from. It is **`Blocked` on `PLC-Q12`**: the *"active material-tracking identifier"* has never had its format
  specified, and whether it is the same identity as the run is unresolved. **Either close `PLC-Q12` and add the
  8 h, or state the partial build at sign-off** — what must not happen is UAT discovering that an idle line does
  not interlock.
- ⚠ **`FW-205`'s watchdog is exercised only through `FW-218`.** The story depends on `FW-N05` for its footage
  feed; the trial defers `FW-N05` and drives everything from `FW-203`, whose criteria cover in-spec, drifting
  and out-of-spec traces and a stop edge — **not dropped readings**, which is what condition 5 watches for.
  That is why `FW-218`'s third endpoint exists and why its fault list is exactly one entry long. **If `FW-218`
  is cut, condition 5 is assumed rather than tested**, and with backend tests withdrawn nothing else would
  catch it.
- ⚠ **`G39` — the simulator is becoming the specification, and its reconciliation is half-built.** Every channel
  `FW-203` drives is modelled on an unconfirmed reading: the `LineStatus` vocabulary is ours (`OI-35`), the tag
  map is `[PROPOSED]` throughout (`G32`/`G33`), the footage→weight basis is undecided (`Q10`/`OI-45`) and the
  cadence has no target (`G9`/`OI-34`, `FW-203`'s own blocker). `[SIM §5.6]`'s **A1–A10 assumption table** is
  written; commissioning step **`C13`** — *record the observed value for every simulated channel and diff it
  against the model* — **is not yet in `[COM]`**. Until it is, the assumption table is documentation nobody is
  required to read, and the divergence surfaces in October, in the window `[PLCC §4]` already calls *"the worst
  compression in the schedule."*
- ⚠ **`SpoolProcessing` cannot represent multi-rod genealogy, and that outlives the trial.** §1.5 records the single-rod
  spool as a **scope** consequence of the weld removal. It is also a **schema** one: `SpoolProcessing` carries
  `ParentRodAlpha` and `SourceRodAlpha` — two single-rod columns, the second documented as the *partial-run*
  source (`OQ-12`) — and `CoilTraceability` is **coil**-level, not spool-level. So when weld capture returns
  there is still nowhere to record *"this spool came from rods R00041 and R00042 at these footages."* **Raise it
  now, while the change is free.** Gap **`G42`**.
- ⚠ **T4 is the only sprint with no planned hours.** §3 calls the de-stub pass *"planned work, not
  contingency"*, and `[SP §2.3]` requires one — the check-in stub deliberately routes around `OQ-14`/`OQ-15` by
  assuming a single active schedule. Yet §2.1 prints **192 h of capacity against an unsized workload**:
  de-stub, regression, defect fixing, **manual backend contract walkthrough** (§7 — there are no automated
  backend suites) and UAT support, all in eight days that also have to produce a sign-off. **Size it before T3
  closes.** An unsized sprint is where the 42 h of margin goes without anyone deciding to spend it.

---

## Related Documents

| Document | Why you would open it |
|---|---|
| [`StaffedSprintPlans.md`](StaffedSprintPlans.md) `[SSP]` | **The plan of record for all of MVP-1 development** — three developers, 103 stories, 1,396 h, finish 25 Nov 2026. This document is a scoped subset of it, not a replacement |
| [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) `[CE]` | The hours model of record — §2 rate card, §3b MVP-1 columns, §4 the week grid this plan counts against, §7 the three programme options |
| [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) `[DE]` | The AI-assisted retention factors every figure here depends on, and why RT compresses by only 14.3 % |
| [`SprintPlan.md`](SprintPlan.md) `[SP]` | §1.4 (UAT cannot share a sprint with feature work), §6.1 the dependency chain, §9 DoR/DoD |
| [`TaskBreakdown.md`](TaskBreakdown.md) `[TB]` | The story bodies — acceptance criteria, dependencies, `Rate-card basis:` per story. **`FW-202` is defined there** |
| [`GapsRegister.md`](GapsRegister.md) `[GAP]` | `G37` (this plan's finding), plus `G2` and `G6` — the blockers in §6 — and `G21`, `G26`, `G28`, `G31`, which the 14 Aug removals took out of trial scope while leaving them open for MVP-1 |
| [`Phases/`](Phases/) | The per-phase deliverable inventories this plan subsets |
| [`Testing/TestCases.md`](../Testing/TestCases.md) `[TCS]` | The `TC-###` ranges in §1.1, the 75 cases §1.5 puts out of scope, and the acceptance run in §8 |
| **`FlatWire_TrialRunPlan.xlsx`** *(this folder)* | **This document as a workbook** — ten sheets, filterable, one row per work item. Generated by [`../Tools/build_trial_run_xlsx.py`](../Tools/build_trial_run_xlsx.py); **every figure in it is parsed from this file, so change this document and re-run.** Never edit the workbook. Five fatal guards, including one that refuses to build if any total here stops reconciling |
