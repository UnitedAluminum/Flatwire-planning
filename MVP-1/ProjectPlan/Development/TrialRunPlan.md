# Flat Wire Mill — Six-Screen Trial Run Plan (30 Sep 2026)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 14, 2026 — **this document is now the parse source for `FlatWire_TrialRunPlan.xlsx`** (see Related Documents), and **`FW-203`/`FW-204` were minted** so all 61 work items carry an identifier. Also: **§1.3 gains *What the four streams are*** — FE/BE/DB/RT defined against `[CE §1]`, with **RT decomposed to all 127 h** and the note that `RT`/`DB` are stream codes, not document shortcodes. Same day: **§1.4 completed** with the 1B sprint split (164 h T1 / 28 h T2) and Phase 1 **all-in at 584 h**, so it is comparable with the hand-coded 1,027 h. Also: **new §1.4 breaks Phase 1 out at deliverable level** (1A/1B/1C on all three bases, three trial reductions named), **§1.3 gains the phase × stream staffing grid**, the removals record renumbers **§1.4 → §1.5**, and **DB1 Line Status and DB2A Pre-Check-in + weld capture were removed from trial scope** on client direction, **885 h → 778 h** *(initial publication same day)*
**Document Type:** Scoped delivery plan for the client-requested trial run
**Status:** Published — **three developers reach ~1 Oct on development alone; UAT still needs its own window.** §2.2 states what each staffing option lands
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
> platform, not started, whose hard gate was 14 Aug and was not met — is 423 h, 54 % of the trial.** Cutting
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
| **FL1 run completion → `Spool`** (`FW-202`) | **67** | ⚠ **Inside screen #2's approved mockup, and the only thing that creates what DB5 checks in.** See §5.1 |
| **Minimal landing route** (`FW-204`) | 5 | Replaces DB1 as the entry point and the way back into a running line. **Retires when `FW-060` ships.** See §1.5 |

### 1.3 Total

| Block | AI-assisted h | Share |
|---|---|---|
| **Phase 1 platform** (1A Angular · 1B Backend · 1C Database) | **423** | **54 %** |
| Navigation, reconnect and the run index *(was Phase 3)* | 15 | 2 % |
| Phase 4 — rod check-in *(no DB2A staging)* | 74 | 10 % |
| Phase 5 — DB3 FL1 shell | 74 | 9 % |
| Phase 6 — SPC + Pause/Resume *(no weld, no die change, no roll adjust)* | 56 | 7 % |
| Phase 7 — WIP rejection | 31 | 4 % |
| **FL1 spool completion — Part B** (`FW-202`) | **67** | **9 %** |
| Phase 8 — DB5 + DB3 FL2 | 38 | 5 % |
| | **778 h** | |

| Stream | h | Share |
|---|---|---|
| **FE** Angular | 314 | 40 % |
| **BE** .NET | 225 | 29 % |
| **RT** real-time / PLC | 127 | 16 % |
| **DB** SQL Server | 112 | 15 % |

#### What the four streams are

The **delivery streams** of `[CE §1]`, which defines six — the two not costed here are **QA** (a separate ~156 h,
§9) and **BA** (Ops liaison and question closure, which does not compress at all).

| Stream | Surface | What it owns |
|---|---|---|
| **FE** | `ual-angular` → new library `flat-wire-shopfloor` (prefix `fw`) | Screens, dialogs, shared controls, SCSS against the existing token set |
| **BE** | `ual-api` → new `FlatWire` microservice | Controllers, MediatR commands/queries, services, validation, auth |
| **DB** | SQL Server → new `FlatWireDB` + the shared-schema `FW-001` renames | DDL, seed data, indexes, EF/Dapper mapping, repositories |
| **RT** | `FlatWireHub` · OPC ingest · `PLCTagService` | **Real-time and PLC integration** — see below |

**`RT` is the one worth spelling out, because this plan leans on it and it is not simply "the SignalR bit".** It is
a separate stream rather than part of FE or BE precisely because it **spans both**: the Angular SignalR client and
the .NET hub, ingest loop and tag push are one skill set, and splitting them across two owners is how a typed hub
contract drifts from its client. In this trial RT's 127 h is:

| Where | h | What |
|---|---|---|
| **1A** | 27 | `FW-135` SignalR client service · `FW-136` `MockSignalRService` · `FW-137` PWA cache + reconnect banner |
| **1B** | 61 | `FW-080` `FlatWireHub` (typed, MessagePack, line groups) · `FW-149` `IFlatWireClient` · `FW-150` cadence broadcast loop · `FW-151` `PLCTagService` + `SimulatePLCTagPush` · the OPC feed simulator |
| **Phase 4** | 11 | `FW-082` — the PLC tag group push on check-in acknowledgement |
| **Phase 6** | 7 | `FW-172` — run-event markers and the `LineStatus` transitions |
| **Phase 7** | 5 | `FW-177` — exception broadcasts |
| **`FW-202`** | 13 | the two spool-completion hub events (§5.1) |
| **Phase 8** | 3 | `FW-181` — the FL2 null-gauge contract and the Live/Profile binding |
| | **127** | |

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
| **1B** Backend foundation | — | **131** | — | **61** | **192** | T1 · T2 |
| **1C** Database foundation | — | — | **65** | — | **65** | T1 |
| Navigation, reconnect, run index | 12 | — | 3 | — | **15** | T2 |
| **4** Rod check-in | 24 | 24 | 15 | 11 | **74** | T2 |
| **5** DB3 FL1 shell | **61** | 8 | 5 | — | **74** | T2 |
| **6** SPC + Pause/Resume | 30 | 13 | 6 | 7 | **56** | T2 · T3 |
| **7** WIP rejection | 13 | 8 | 5 | 5 | **31** | T3 |
| **`FW-202`** FL1 spool completion | 20 | **29** | 5 | 13 | **67** | T3 |
| **8** DB5 + DB3 FL2 | 15 | 12 | 8 | 3 | **38** | T3 |
| | **314** | **225** | **112** | **127** | **778** | |

**Four things this grid shows that the phase totals hide:**

1. **Phase 1 is not one problem, it is three unequal ones** — 1A is **139 h of pure FE**, 1B is **131 BE + 61 RT**,
   1C is **65 h of pure DB**. They genuinely parallelise across different people, which is why T1 is the only
   sprint where a fifth developer pays for itself.
2. **RT is 88 of its 127 h inside Phase 1** — 27 in 1A (the SignalR client, `MockSignalRService`, the reconnect
   banner) and 61 in 1B (the hub, `IFlatWireClient`, the broadcast loop, `PLCTagService`, the OPC simulator).
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

### 1.4 Phase 1 in detail — 423 h, 54 % of the trial

Phase 1 is the largest block in this plan by a wide margin, it has not started, and its hard gate was 14 Aug and
was not met. It is broken out here at deliverable level because *"the platform is 423 h"* is not actionable and
*"the shared composite controls are 75 h of it"* is.

**Three bases, and they must not be mixed.** Hand-coded is `[CE §3]`'s and is the **base of record**; AI-assisted
is `[DE §2]`/`[SSP §5]`'s and is what this plan schedules; trial scope is AI-assisted **less three named
reductions**.

| | Hand-coded `[CE §3]` | AI-assisted, full | **Trial scope** | Reduction | T1 | T2 |
|---|---|---|---|---|---|---|
| **1A** Angular foundation | **370** | 166 | **166** | — | 166 | — |
| **1B** Backend foundation | **442** | 217 | **192** | −25 | 164 | **28** |
| **1C** Database foundation | **215** | 101 | **65** | −36 | 65 | — |
| | **1,027 h** | **484 h** | **423 h** | **−61 h** | **395** | **28** |

**1B is the only sub-phase that crosses a sprint boundary.** Its T2 tail is exactly three items — `FW-150`
(broadcast loop 11), `FW-151` (`PLCTagService` + `SimulatePLCTagPush` 11) and the **OPC feed simulator** (6) — and
they are last because they are the only 1B work with nothing downstream waiting on it inside T1. **1A and 1C must
finish inside T1** or the whole T2 chain slips: 1A gates every screen and 1C gates every write. The T1 column sums
to **395 h**, which is §2.1's T1 figure — the two reconcile by construction, not by coincidence.

#### Phase 1 all-in, on the trial's own basis

Every figure elsewhere in this plan is **development only**. The hand-coded column above is all-in (it carries
`[CE §3]`'s QA and contingency), so the two are **not comparable as printed**. On the trial's AI-assisted basis,
with `[CE §2]`'s uplifts applied:

| | Dev | QA (+20 %) | Contingency (+15 %) | **All-in** |
|---|---|---|---|---|
| **1A** | 166 | 33 | 30 | **229** |
| **1B** | 192 | 38 | 35 | **265** |
| **1C** | 65 | 13 | 12 | **90** |
| **Phase 1** | **423** | **84** | **77** | **584** |

*Rounding is **half-up per cell** and the total row is **the sum of the printed cells**, both per `[CE §3]`. Deriving
the total from 423 directly would give QA 85 / cont. 76 — the same 584, distributed differently. The cell-sum
convention wins so that every row and column verifies by hand.*

**Quote 423 h against a developer roster and 584 h against a budget — never the other way round.** The 584 h is
offered because a foundation phase is normally read for budgeting, and because comparing 423 against the
hand-coded 1,027 overstates the saving: the like-for-like comparison is **584 against 1,027**, a **43 % reduction**,
not the 59 % the dev-only figures imply. `[DE §3]` makes the same caution about its own contingency line.

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

#### 1B Backend foundation — 192 h (BE 131 · RT 61) · **the largest sub-phase**

| Deliverable | Hand-coded | Story | Full | **Trial h** |
|---|---|---|---|---|
| `FlatWire` solution + four-project Clean Architecture skeleton | 16 | `FW-N04` | 11 | 11 |
| **Thin controllers over `UAController`** @ 4 h | **52** *(13)* | **`FW-138`** | 35 | **26** *(9)* |
| MediatR registration and pipeline behaviours | 16 | `FW-139` | 11 | 11 |
| DI registration and the stub/real service swap | 12 | `FW-140` | 8 | 8 |
| Repository layer | 20 | `FW-141` | 14 | 14 |
| Dapper/EF data access + `FlatWireDbContext` | 24 | `FW-142` | 16 | 16 |
| Serilog structured logging and the audit log | 12 | `FW-143` | 8 | 8 |
| Configuration binding | 12 | `FW-144` | 8 | 8 |
| JWT authentication and role authorization policies | 16 | `FW-145` | 11 | 11 |
| Global exception middleware and the response envelope | 8 | `FW-146` | 5 | 5 |
| FluentValidation and the canonical cross-layer enums | 12 | `FW-147` | 8 | 8 |
| Health checks | 8 | `FW-148` | 5 | 5 |
| `FlatWireHub` — strongly-typed, MessagePack, line groups | 32 | `FW-080` | 22 | 22 |
| `IFlatWireClient` typed event contract | 16 | `FW-149` | 11 | 11 |
| **OPC ingest hosted service + bounded channel** | **32** | **`FW-N05`** → **`FW-203`** | 22 | **6** ⚠ |
| Cadence-driven broadcast loop | 16 | `FW-150` | 11 | 11 |
| `PLCTagService` skeleton + `SimulatePLCTagPush` | 16 | `FW-151` | 11 | 11 |
| | **320** base → QA 64 → cont. 58 = **442** | | **217** | **192** |

**Two trial reductions, both deliberate:**

- **`FW-138` 35 h → 26 h.** Thirteen controllers are priced; the trial needs **nine** — Lines *(now the landing
  route)*, Rod, CheckIn, Run, Spc, WipRejection, Spool, Coil *(for `FW-202`'s `CompleteSpool`)* and Health.
  `PassSchedule`, `PayoffStaging`, `WeldEvent`, `DieChange` and `RollAdjust` are out of trial scope.
- ⚠ **`FW-N05` 22 h → a 6 h simulator.** `[DE §1]` prices real OPC ingest at retention **0.90** and calls it *"not
  verifiable without the hardware"*. Deferring it to the October commissioning window and driving the trial from a
  simulated feed is the single highest-value deferral in this plan: it moves 16 h *and* removes the trial's only
  hardware dependency. **The bounded-channel and broadcast-loop design must still be built to contract** so the
  real ingest drops in behind it — `FW-150` and `FW-151` are unreduced for exactly that reason.

**RT is 61 of 1B's 192 h.** `FW-080` + `FW-149` + `FW-150` + `FW-151` are the real-time spine every later phase
consumes (`[SP §6.3]`), and none of it compresses well — 0.75–0.90 against FE's 0.62.

#### 1C Database foundation — 65 h (DB 65)

| Deliverable | Hand-coded | Story | Full | **Trial h** |
|---|---|---|---|---|
| ⚠ **Shared-schema renames + new columns** *(16 rename + **40 impact audit**)* | **56** | **`FW-001`** | 36 | **0** ⚠ |
| `INFLAT` coil status | 4 | `FW-002` | 3 | 3 |
| `FlatWireDB` creation, ordered DDL runner, indexes, grants | 12 | `FW-152` | 8 | 8 |
| Lookup group tables + seed | 16 | `FW-005` | 10 | 10 |
| `AlloyProperty` lookup + seed | 8 | `FW-004` | 5 | 5 |
| Materials group tables | 12 | `FW-006` | 8 | 8 |
| Runs and Quality/Output group tables | 48 | `FW-007` | 31 | 31 |
| | **156** base → QA 31 → cont. 28 = **215** | | **101** | **65** |

⚠ **`FW-001` is deferred and it is the largest single reduction in the trial (−36 h).** The `Coil/Bundle…`
slash-dual renames land on the **shared** `coils`/scheduling schema that the legacy `ual-dot-net` tier and existing
reports read — `[CE §2]` prices the rename at 16 h and the **impact audit across `united_db` and the legacy tier at
a separate 40 h**, and `phase-01c` flags *"high blast radius; front-load the impact audit."* **A trial does not need
it; production does.** `FW-002` (`INFLAT`) stays, because check-in writes it.

> **⚠ `[CE §8]` records that 1C is understated by ~17 h.** It was costed against **22 tables** and the build is
> **25** — each extra table is 4 h plus its QA and contingency share (~5.5 h all-in). That understatement is
> inherited here and is **not** corrected in the 65 h above, because correcting it in place would drift `[CE §3b]`.
> Treat 1C as **65 h + ~11 h of known understatement on the trial's AI-assisted basis.**

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
(`PayoffStateChanged`, 8 h RT), the `RodStaging` table (4 h DB, out of `FW-159`), `FW-063` (the weld dialog,
13 h FE), `FW-166` (`POST /weldevent` + `WeldService`, 8 h BE) and the `WeldEvent` table (3 h DB, out of
`FW-171`).

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

Working days **17 Aug → 30 Sep 2026: 32** — Labor Day (Mon 7 Sep) deducted and the final week is three days,
counted on `[CE §4]`'s grid.

| Measure | Value |
|---|---|
| Trial development effort | **778 h** |
| 3 developers × 32 days × 8 h | **768 h** |
| Utilisation, development alone | **101 %** — before one hour of QA |
| Development days available if UAT gets 21–30 Sep | **24** = **576 h** |
| **Shortfall against that** | **202 h** |

**UAT cannot share a sprint with feature work.** `[SP §1.4]` states it independently of team size, and
`phase-14`'s own scope call is blunter: *"pull this into a dedicated post-feature-complete window regardless of
team size."* So the 576 h figure, not the 768 h one, is the one that governs.

> **What the two removals changed, and what they did not.** 107 h came out, and the position improved materially:
> three developers now finish development around **1 Oct** rather than 7–9 Oct, and **one additional developer
> very nearly closes the whole trial** (4 × 24 days = 768 h against 778 — ten hours short) where before it was
> 117 h short. **What did not change is the shape:** Phase 1 is still 54 % of the work, UAT still cannot overlap
> feature work, and neither removal touched the platform.

### 2.1 Recommended shape — five for the platform, four for the screens

Phase 1's three tracks genuinely parallelise, so it is a **headcount problem, not a sequencing one** — which makes
it the one place extra people convert directly into calendar. Everything after it is a sequential chain where they
do not.

| Sprint | Dates | Wk days | Team | Capacity | Planned | Util | Content |
|---|---|---|---|---|---|---|---|
| **T1** | Mon 17 – Fri 28 Aug | 10 | **5** | 400 h | **395 h** | 99 % | Phase 1A ∥ 1B ∥ 1C |
| **T2** | Mon 31 Aug – Fri 11 Sep | 9 | **4** | 288 h | **240 h** | 83 % | Phase 1 close-out · navigation · 4 · 5 · 6 (start) |
| **T3** | Mon 14 – Fri 18 Sep | 5 | **4** | 160 h | **143 h** | 89 % | 6 close · 7 · spool completion · 8 |
| | **— feature complete Fri 18 Sep —** | **24** | | **848 h** | **778 h** | **92 %** | |
| **T4** | Mon 21 – Wed 30 Sep | 8 | 3 + QA + BA | — | — | — | Regression · **de-stub pass** · defects · **UAT + sign-off** |

**Five-person shape for T1: 2 FE · 1 BE · 1 BE/DB · 1 RT**, dropping to 2 FE · 1 BE · 1 RT/DB for T2–T3. FE is
40 % of the work and is the binding constraint, as `[SP §3]` finds for the full plan.

**This is the first version of this plan with real margin: 70 h in total — 5 h in T1, 48 h in T2 and 17 h in T3.**
T2's 48 h is enough to absorb `G2`'s reserve at its lower bound (§2.3), which no earlier shape could do.

### 2.2 What each staffing option lands

| Option | Feature complete | Sign-off | Note |
|---|---|---|---|
| **5 → 4 developers** (§2.1) | **Fri 18 Sep** | **Wed 30 Sep** | Meets the client's date with 70 h of slack. Requires two additional people for T1 and one for T2–T3 |
| **4 developers throughout** | ~18–22 Sep | ~30 Sep – 2 Oct | **Ten hours short of closing on paper** (768 h against 778) and therefore zero-slack. Viable only if one reserve is dropped or T1 starts early |
| **3 developers** *(current baseline)* | **~1 Oct** | **~mid Oct** | 778 h ÷ 24 h/day = 32.4 working days from 17 Aug. Development almost reaches 30 Sep; **UAT then has nowhere to go.** Lands inside the planned Q4 2026 production window |

**Recommendation: one additional developer, and a second for T1 only.** The two removals brought 30 Sep within
reach of a small increment, which was not true before them. At three developers the honest answer is a **mid-October
sign-off**, and that remains a legitimate outcome to publish.

### 2.3 Reserves, excluded from the 778 h

| Reserve | h | Basis |
|---|---|---|
| `G2` / `OI-39` — cross-DB check-in recovery | **24–64** | `[CE §2]`. Phase 4's estimate is provisional until it closes |
| `OQ-10` / `OI-45` — footage→weight dimensional basis | **16–32** | `[CE §2]` prices it on Phase 9, but `TC-167`/`TC-168` put the same calculation in the spool-completion path this trial builds. See §5.1 |

Neither is a coding problem, so neither compresses under AI assistance. **T2's 48 h and T3's 17 h can absorb one
of them at its lower bound, not both at their upper.** That is a genuine improvement on every earlier version of
this plan, and it is the whole of the margin.

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

*`G26`'s cross-phase weld hazard no longer applies to this plan — see §1.5.*

---

## 4. Story → sprint allocation

Story ids are frozen and are the repository's join key — import against these. **`FW-130`–`FW-201` are all
allocated**, so this plan mints **`FW-202`**, **`FW-203`** and **`FW-204`**. *(Note: `CLAUDE.md`'s "new work is
minted at `FW-130`+" is stale.)*

> **All three new stories are defined in `[TB §7]` and all three are additive to `[CE §3b]`** — none is folded into
> a published phase total. They are also **excluded from `[SSP §5]`'s allocation on purpose**, because that document
> is the full-scope plan of record and these are trial scope; the full-plan workbook reports them as excluded rather
> than absorbing them. **`FW-204` is the only one that is temporary** — it retires when `FW-060` ships, so it never
> enters the MVP-1 baseline at all.

### T1 — Phase 1 platform · 395 h

| Stream | Stories | h |
|---|---|---|
| **FE** | `FW-N03` 15 · `FW-130` 10 · `FW-131` 7 · `FW-132` 12 · **`FW-133` 75** · `FW-134` 20 | **139** |
| **BE** | `FW-N04` 11 · `FW-138` 26 *(9 controllers, not 13)* · `FW-139` 11 · `FW-140` 8 · `FW-141` 14 · `FW-142` 16 · `FW-143` 8 · `FW-144` 8 · `FW-145` 11 · `FW-146` 5 · `FW-147` 8 · `FW-148` 5 | **131** |
| **RT** | `FW-135` 15 · `FW-136` 7 · `FW-137` 5 · `FW-080` 22 · `FW-149` 11 | **60** |
| **DB** | `FW-002` 3 · `FW-152` 8 · `FW-005` 10 · `FW-004` 5 · `FW-006` 8 · `FW-007` 31 | **65** |

`FW-133` (shared composite controls, 75 h) is the single largest story in the trial and **all six screens depend
on it** — `pass-schedule-table`, `confirm-bar`, `gauge-trace-chart`, `tab-wizard`, `action-bar`,
`payoff-weight-bar`. It is not trimmable.

### T2 — check-in and the run monitor · 240 h

| Phase | Stories | h |
|---|---|---|
| 1B close-out | `FW-150` 11 · `FW-151` 11 · **`FW-203` 6** — OPC feed simulator, *in place of `FW-N05`* | 28 |
| navigation | **`FW-204` 5** — minimal landing route · `FW-153` 7 *(reconnect + cached fallback)* · `FW-155` 3 *(run index)* | 15 |
| **4** | `FW-061` 24 · `FW-157` 24 · `FW-159` 15 *(check-in write path + cross-DB `INFLAT`; **no `RodStaging`**)* · `FW-082` 11 | 74 |
| **5** | `FW-062` 17 *(FL1 only)* · `FW-162` 13 · `FW-081` 18 · `FW-163` 13 · `FW-164` 8 · `FW-165` 5 | 74 |
| **6** *(start)* | `FW-065` 15 · `FW-071` 15 · `FW-168` 8 · `FW-170` 5 · `FW-171` 6 *(SPC + pause tables; **no `WeldEvent`**)* | 49 |

### T3 — exceptions, completion, FL2 · 143 h

| Phase | Stories | h |
|---|---|---|
| 6 close | `FW-172` 7 | 7 |
| **7** | `FW-067` 13 · `FW-174` 8 · `FW-176` 5 · `FW-177` 5 | 31 |
| **new** | **`FW-202` 67** — FL1 spool completion, Part B *(98 h hand-coded)* | **67** |
| **8** | `FW-064` 10 · `FW-178` 5 · `FW-179` 12 · `FW-180` 8 · `FW-181` 3 | 38 |

**`FW-202` must land before Phase 8 starts, not beside it** — it writes the `Spool` row DB5 reads. In a five-day
sprint that is a real sequencing constraint, not a formality.

### Deferred — still MVP-1, out of the trial · 330 h

| Deferred | h | Why it is safe to defer for a trial |
|---|---|---|
| **DB1** `FW-060` + `FW-154` | 42 | Client direction, 14 Aug 2026. See §1.5 for what goes with it |
| **DB2A + weld** `FW-N01`, `FW-158`, `FW-160`, `FW-063`, `FW-166` + 2 tables | 70 | Client direction, 14 Aug 2026. See §1.5 |
| **`FW-001`** shared-schema renames | 36 | Highest blast radius in the plan — the `Coil/Bundle…` renames land on the shared `coils`/scheduling schema that the legacy `ual-dot-net` tier and existing reports read. **A trial does not need it; production does.** Keep `FW-002` (`INFLAT`) |
| **`FW-N05`** real OPC ingest | 22 | Factor **1.00** work — `[DE §1]` prices it as *"not verifiable without the hardware"*. Belongs in the October commissioning window; the trial runs on a simulated feed + `SimulatePLCTagPush` |
| **`FW-N06`** alert rules engine | 28 | Its only consumer was DB1's alert bar |
| **Spool completion Part A** (`FR-130`–`FR-136`) | 25 | Explicitly `Should` and *"advisory and non-blocking"*. **Part B is `Must` and stays** — see §5.1 |
| **`FW-073`** die change · **`FW-167`** | 23 | Grey the DB3 button; state "not in trial scope" |
| **`FW-070`** roll adjust · **`FW-169`** | 26 | FL2/FL3 only (`FR-107`–`FR-109`); grey on DB3-FL2 |
| **`FW-072`** rod checkout · **`FW-173`** · **`FW-175`** | 39 | Resume ships with three of its four outcomes; *Check out rod* disabled |
| **`FW-124`** DB5A spool queue · **`FW-N02`** | 19 | DB5's *Browse spool queue →* greyed. The scan still validates — `GET /spools` ships in `FW-179` |

Phases **9–14** (coil completion, FL3 hybrid, reporting, yield/cost, admin, integration) are wholly outside the
trial.

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
2. **It is the transaction that creates the `Spool` row DB5 checks in.** `phase-05` routes *Complete Run* to
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
| **DB** | `Spool` write path + index | 8 | 0.60 | **5** |
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

## 6. Blockers — what must close, and by when

**One of the five left with DB2A** (§1.5): **`G21`**, bay-uniqueness, which blocked the Phase-4 schema freeze and
is a defect *in `RodStaging`*. **`G26`** (the cross-phase weld write) was a sequencing hazard rather than a listed
blocker and went with the same removal. Both **remain open for MVP-1**; neither blocks the trial. **Four remain:**

| # | Blocker | Blocks | Needed by |
|---|---|---|---|
| **1** | **The pass schedule is external and MVP-1 cannot create one.** Phase 2 and the three `PassSchedule*` tables are wholly MVP-2. Check-in *reads* a schedule to build the push payload; **no schedule means no acknowledgement, no push and no run** — there is no default schedule and no partial path (`phase-04`, *The pass-schedule read contract*). Confirm the read mechanism and that readable FL1 **and** FL2 schedules exist | DB2, DB5 — **both check-in screens, i.e. the whole trial** | **Before T2 (31 Aug)** |
| **2** | **`OQ-22` — min/max tolerance values.** ⛔ Owed by the client by e-mail; nothing is seeded. `CHK007` is a band check at both stations | DB2 step 3, DB5 dimensions | Before T2 |
| **3** | **`G2` / `OI-39` — cross-DB check-in recovery undecided.** Check-in spans `FlatWireDB` + `coils` + `wip_coil_orders` + the PLC and is **not one ACID transaction** — describe it as compensating writes, never "atomic rollback" (`G16`). Carries the 24–64 h reserve of §2.3 | Phase 4 is provisional until it closes | Before T2 |
| **4** | **`G6` — roles not confirmed as existing JWT claims.** Operator / Supervisor / Ops Manager gate the DB2 supervisor overrides, the SPC skip, the WIP disposition and the spool weight-variance override | Every role-gated action in the trial | **Before T1 closes (28 Aug)** |

**Second tier — none stops the build:** `OQ-10`/`OI-45` (§5.1) · `OQ-76` (which identifier DB5 scans) ·
`OQ-15` (hybrid-origin guard — DB5 blocks amber by design, `TC-118`) · `OQ-14` (no-matching-schedule path —
stubbed to a single active schedule) · `OQ-18` (which order field carries coil min–max weight) · `OQ-79`
(short-close transaction) · `G9`/`OI-34` (real-time NFRs undefined, so the hub load test has no pass criteria).
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
  `flat-wire-shopfloor` is all-new from the mockups, and `checkin-precheckin`, `shop-floor*`, `common-grid`,
  `wip-rejection`, `slitter-*` are not to be copied. Only the foundational `shared` services are reused.
- **DoD bar is unchanged** (`[SP §9.2]`): Jest 95 % coverage, xUnit + validator tests, UI conformance at
  1280×1024 at 1:1, **no text below 14 px**, tap targets ≥ 48 px, no hover-dependent action, no new `--fw-*`
  tokens.

---

## 8. Acceptance — the trial run

**Per story:** the `TC-###` ranges in §1.1, each executed with at least one negative path and one permission case.
**75 cases are out of trial scope** with the two removals — TC-040…069, TC-190…214 and TC-490…509 (§1.5).

**Schema** — deploy clean and confirm the count:

```powershell
cd "c:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_99_Teardown.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql
# expect 25 tables · 33 FKs · 41 index statements · 1 procedure · 1 trigger
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql   # idempotent re-run
```

**The DDL still builds all 25 tables.** `RodStaging` and `WeldEvent` are created and simply go unwritten in the
trial — do not remove them from the schema to match the trial's scope.

**The acceptance run is one continuous FL1 → FL2 journey.** This is the only thing that proves the six screens
are a system rather than six pages, and it is what UAT executes:

1. **Landing route** — FL1 and FL2 both idle; each tile routes to its check-in screen.
2. **DB2** — scan a rod, clear all six wizard steps, select the payoff, **Confirm Schedule** (amber → green),
   Acknowledge. Assert **records are written before the PLC push**, tags push **only** on acknowledgement,
   `coils` → `INFLAT`, run `Running`, and the operator lands on **DB3**.
3. **DB3 FL1** — live gauge/width streams with tolerance band. Force N consecutive out-of-spec readings → the
   auto-prompt SPC toast fires. Action bar has **exactly six buttons and no Roll Adjust** (`TC-135`, `FR-107`).
   **The weld-marker layer renders empty** — no welds are captured in the trial.
4. **Pause** → *Manual SPC measurement* → the pause applies, **then** the SPC dialog opens carrying the frozen
   footage. Never both at once.
5. **DB6 SPC** — record an out-of-spec reading → **Submit · suspend material** hands straight to **DB8** with the
   failing reading pre-filled and the coil `SPC-HOLD`.
6. **DB8 WIP** — Suspend requires an observation; submit sets the material status and files the WIP-Held queue
   entry. ⚠ **The supervisor alert fires with no screen to display it** (§1.5) — verify the event on the wire, not
   on a dashboard.
7. **Spool completion (`FW-202`)** — run to target, then stop the line. Assert: the prompt fires on the **edge**
   and only once (`TC-170`); a 3 s stop against a 5 s dwell raises **nothing** (`TC-171`); the weight is
   **latched at the PLC stop timestamp** (`TC-172`); **Escape and backdrop-click do not dismiss** (`TC-178`); the
   prompt **survives a browser refresh** (`TC-173`); Yes commits **before** it prints (`TC-175`). Result: a
   `Spool` row with an `SP-#####` alpha, **one** source rod and its footage.
8. **DB5** — scan that spool. The source-traceability panel shows **a single rod and no weld row**; the
   **historical** profile renders against the spool's own 0.113″ target **with an empty marker layer**; **no
   visual-inspection section** (`TC-114`, `FR-095`); the FM2 table shows **exactly three rows** (`TC-115`); all
   five pre-flight checks pass; Acknowledge pushes FM2 tags.
9. **DB3 FL2** — three FM2 rows, edgers on S2/S3 only; **Live shows its empty state and Profile stays static
   across several live ticks**; SPC and WIP Reject open over the live run; **no Weld and no Die Change**
   (`TC-137`, `FR-109`).
10. **Reconnect** — kill the hub mid-run: banner over cached last-known state, **never a blank screen**
    (`FR-119`/`NFR006`), backoff reconnect, group re-join, trace restored without a refresh.

**UAT (T4, 21–30 Sep):** operators execute steps 1–10 on staging (`devual-uadev001` or equivalent) on touch
screens, against the §7 DoD bar. **Sign-off is the trial deliverable.** PLC commissioning
([`PLCCommissioning.md`](../Testing/PLCCommissioning.md) — `C1` tag paths, `C8` AGC latency, `C11` FM2 station
names) and the on-mill trial follow in October, per `[SP §4.3]`.

---

## 9. Assumptions and known risks

- **The `[DE §1]` retention factors are assumed, not measured**, and a factor error propagates to every figure
  here at once. The Aug-14 gate was the calibration point and was not met, so **this plan is uncalibrated** —
  T1's actuals are the first real signal. `[DE §6]`'s early check applies: five people should book ~200 h/week.
- ⚠ **The trial does not exercise weld traceability**, and `CoilTraceability` genealogy is the chain the
  **welding-wire customer certificates** are produced from (`NFR012`). A single-rod spool is a real case, but it
  is the easy one. **This is the largest single thing the 14 Aug removals give up** and it should be signed off
  knowingly, not discovered at certificate time.
- **Nothing in the trial displays an alert.** With DB1 out, `AlertRaised`/`AlertCleared` have no consumer, so the
  WIP rejection's supervisor notification is verifiable only on the wire.
- **QA does not compress with development.** `[DE §0]` is explicit: building the same features faster does not
  shrink the test surface. The ~156 h QA figure is +20 % of the build base as a **feature-volume** proxy and must
  be staffed separately.
- **BA does not compress at all.** The blockers in §6 close at the client's pace, and two of the four are
  client-owned.
- **`FW-001` deferral is a debt, not a saving.** The renames must land before production and their 40 h impact
  audit across `united_db` and the legacy tier is not in this plan.
- **The trial proves the screens, not the machine.** Every line runs `SimulatePLCTagPush` and a simulated OPC
  feed. **Nothing in this plan verifies a single tag path against a controller** — that is `C1`/`C11` in October,
  and `G32`/`G33` record that the whole tag map is currently `[PROPOSED]`.
- **Four deferred items are re-entry points, not deletions.** DB1, DB2A + weld, the die-change and roll-adjust
  dialogs all have live requirements, test suites and mockups. Keep their inputs, marker layers and greyed
  controls in place so their return is configuration rather than rework.

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
