# Six-Screen Trial Run — Execution Orchestration (30 Sep 2026)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — **trial controllers 8 → 7, five of which serve a screen** (`FW-138` `P-53`), with a warning that DB2's rod scan has no endpoint until `P-54` closes. Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Execution index and story map for the 30 Sep trial run
**Status:** Active — **the trial-scope companion to [Orchestration.md](Orchestration.md)**
**Owner:** Delivery lead, across all four streams
**Audience:** Anyone sequencing or building the trial
**Shortcode:** — *(orchestration, derived from `[TRP]` and the plans; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — Phase-1B companion: [Orchestration.md](Orchestration.md)

---

> **What this file is, and how it differs from its sibling.** Two orchestrations over
> overlapping stories, on **different axes**:
>
> | | [Orchestration.md](Orchestration.md) | **this file** |
> |---|---|---|
> | Axis | Phase 1B, by **dependency wave** | the trial, by **sprint** |
> | Covers | 22 stories, one layer, all planned | **66 stories, four streams, three sprints** |
> | Question | *what can start?* | *what ships on 30 Sep?* |
>
> **`[TRP]` is the authority; this is a map of it.** Where they disagree, `[TRP]` wins.
>
> ⚠ **The trial is not MVP-1 feature-complete** — *"30 Sep is a trial-run date, not an MVP-1
> feature-complete date"* (`[RM]`). **330 h of MVP-1 work is deferred out of it**, §5.

---

## 1. Coverage — 66 stories, 31 with a plan

| | Stories | Planned | Where the rest live |
|---|---|---|---|
| **BE** | 21 | **21** ✅ | — |
| **RT** | 13 | **10** | `FW-135`/`136`/`137` are Angular (§1.2) |
| **FE** | 20 | 0 | `ual-angular`; owning specs in `Business/Screens/` |
| **DB** | 12 | 0 | `Database/Schema/SQL/` |
| | **66** | **31** | |

**This folder is Backend-scoped**, so it holds the 31 server-side plans and maps the other 35
without duplicating their specifications. FE and DB rows below name the owning document
instead of a plan.

### 1.1 The ten added for the trial

Beyond Phase 1B's 22, these ten are trial-path server stories:

| Plan | h | Phase | Why it matters here |
|---|---|---|---|
| [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md) | 36 | 4 | The largest BE story; ⚠ **trial runs it without `RodStaging`** |
| [FW-082](FW-082-PLC-Tag-Push-On-Acknowledgement.md) | 16 | 4 | The moment software configures a machine |
| [FW-164](FW-164-Run-Queries-And-RunQueryService.md) | 12 | 5 | ⚠ **`GET /run/active` is the trial's landing route** |
| [FW-168](FW-168-Spc-And-SpcService.md) | 12 | 6 | Server-side verdict; five `CheckpointType` values |
| [FW-170](FW-170-Pause-Resume-And-RunControlService.md) | 8 | 6 | Four resume outcomes; PLC idle/restore |
| [FW-172](FW-172-Run-Event-Markers.md) | 20 | 6 | Four markers, immediate and unbatched |
| [FW-174](FW-174-WipRejection-And-Checkout-Services.md) | 24 | 7 | **The only thing that clears a `Blocked` bay** |
| [FW-177](FW-177-Exception-Broadcasts.md) | 16 | 7 | The other two markers |
| [FW-179](FW-179-CheckIn-Spool-And-Spools-Query.md) | 18 | 8 | FL2 tags only; ⚠ **`[API §4.6a]`'s example is stale** |
| [FW-181](FW-181-FL2-Null-Gauge-Contract.md) | 4 | 8 | ⚠ *"the single most likely thing to ship wrong"* |

### 1.2 ⚠ Three RT stories are Angular, not backend

`FW-135` (`flat-wire-signalr.service.ts`, NgZone, ring buffer), `FW-136`
(`MockSignalRService`, Jest) and `FW-137` (service worker, PWA cache) carry the **RT** stream
label but are **`ual-angular` code**. They belong with 1A and are **deliberately not planned
here** — a Backend folder is the wrong home, and `[ARC §2.2]` gives them **no Angular
template** to work from anyway.

---

## 2. The three sprints

`[TRP §4]`. **832 h total**; the four new stories (`FW-202`, `FW-203`, `FW-204`, `FW-218`) plus
`FW-214` are **additive to `[CE §3b]`**.

> **Sequencing within a sprint is `[TRP §3]`'s, not this file's.** It is not restated here —
> duplicating a sequence is how the six PLC tag-map copies happened. Two ordering constraints
> are load-bearing enough to name, and both are already in the owning plans:
>
> | Constraint | Why | Plan |
> |---|---|---|
> | **`FW-202` before Phase 8 *starts*, not beside it** | It writes the `SpoolProcessing` row DB5 reads. `[TRP §3]`: *"In a five-day sprint that is a real sequencing constraint, not a formality"* | [FW-179 §4](FW-179-CheckIn-Spool-And-Spools-Query.md) |
> | **`FW-218` before the acceptance run** | Three of `[TRP §8]`'s ten steps cannot be executed without a control surface (§7) | [FW-218](FW-218-Sim-Control-Surface.md) |
>
> For the **Phase-1B** stories in T1, the dependency waves and the 134 h critical path are in
> [Orchestration.md §2–§3](Orchestration.md).

### T1 — Phase 1 platform · 409 h

| Stream | Stories | h |
|---|---|---|
| **FE** | `FW-N03` · `FW-130` · `FW-131` · `FW-132` · **`FW-133` 75** · `FW-134` | 139 |
| **BE** | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) · [FW-138](FW-138-Fifteen-Thin-Controllers.md) *(7 controllers, `P-53`)* · [FW-139](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) · [FW-140](FW-140-DI-Registration-And-Stub-Swap.md) · [FW-141](FW-141-Repository-Layer.md) · [FW-142](FW-142-Dapper-EF-And-FlatWireDbContext.md) · [FW-143](FW-143-Serilog-And-Audit-Log.md) · [FW-144](FW-144-Configuration-Binding.md) · [FW-145](FW-145-JWT-And-Role-Policies.md) · [FW-146](FW-146-Exception-Middleware-And-Envelope.md) · [FW-147](FW-147-FluentValidation-Value-Objects-And-Enums.md) · [FW-148](FW-148-Health-Checks.md) · [FW-207](FW-207-Domain-Model.md) · [FW-208](FW-208-Domain-Events-Post-Commit-Dispatch.md) | 145 |
| **RT** | `FW-135` · `FW-136` · `FW-137` *(Angular)* · [FW-080](FW-080-FlatWireHub.md) · [FW-149](FW-149-IFlatWireClient.md) | 60 |
| **DB** | ~~`FW-002`~~ *(cancelled, `D-32`)* · `FW-152` · `FW-005` · `FW-004` · `FW-006` · **`FW-007` 31** | 65 *(62 after `D-32`; published figure held — see `[TRP §2.1]`)* |

> **`FW-133` (75 h) is the single largest story in the trial and all six screens depend on
> it** — `pass-schedule-table`, `confirm-bar`, `gauge-trace-chart`, `tab-wizard`,
> `action-bar`, `payoff-weight-bar`. **`[TRP]`: "It is not trimmable."**

### T2 — check-in and the run monitor · 280 h

| Group | Stories | h |
|---|---|---|
| **1B close-out** | [FW-150](FW-150-Broadcast-Loop.md) · [FW-151](FW-151-PLCTagService.md) · [FW-205](FW-205-ITInhibitService.md) · [FW-203](FW-203-OPC-Feed-Simulator.md) *(for `FW-N05`)* · [FW-218](FW-218-Sim-Control-Surface.md) | 53 |
| navigation | `FW-204` · `FW-153` · `FW-155` | 15 |
| **Phase 4** | `FW-061` · [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md) · `FW-159` · [FW-082](FW-082-PLC-Tag-Push-On-Acknowledgement.md) | 74 |
| **Phase 5** | `FW-062` · `FW-162` · `FW-081` · `FW-163` · [FW-164](FW-164-Run-Queries-And-RunQueryService.md) · `FW-165` · `FW-214` | 89 |
| **Phase 6** *(start)* | `FW-065` · `FW-071` · [FW-168](FW-168-Spc-And-SpcService.md) · [FW-170](FW-170-Pause-Resume-And-RunControlService.md) · `FW-171` | 49 |

### T3 — exceptions, completion, FL2 · 143 h

| Group | Stories | h |
|---|---|---|
| Phase 6 close | [FW-172](FW-172-Run-Event-Markers.md) | 7 |
| **Phase 7** | `FW-067` · [FW-174](FW-174-WipRejection-And-Checkout-Services.md) · `FW-176` · [FW-177](FW-177-Exception-Broadcasts.md) | 31 |
| **new** | **`FW-202` 67** — FL1 spool completion, Part B | 67 |
| **Phase 8** | `FW-064` · `FW-178` · [FW-179](FW-179-CheckIn-Spool-And-Spools-Query.md) · `FW-180` · [FW-181](FW-181-FL2-Null-Gauge-Contract.md) | 38 |

> ⚠ **`FW-202` must land *before* Phase 8 starts, not beside it** — it writes the `SpoolProcessing` row
> DB5 reads. `[TRP §3]`: *"In a five-day sprint that is a real sequencing constraint, not a
> formality."*

---

## 3. What the trial builds differently

Not reduced quality — **reduced surface**. Each has a plan section saying so.

| | Trial | MVP-1 | Where |
|---|---|---|---|
| Controllers | **7**, of which only **5** serve a screen | 14 | [FW-138 §3.0a](FW-138-Fifteen-Thin-Controllers.md) |
| OPC ingest | [FW-203](FW-203-OPC-Feed-Simulator.md) simulator | [FW-N05](FW-N05-OPC-Ingest-And-Bounded-Channel.md) real | [FW-N05 §1.1](FW-N05-OPC-Ingest-And-Bounded-Channel.md) |
| Check-in | **no `RodStaging`** | staged-row consumption | [FW-157 §2.3](FW-157-CheckIn-Rod-And-CheckInService.md) |
| Resume | 3 of 4 outcomes; *Check out rod* disabled | four | [FW-170 §2.2](FW-170-Pause-Resume-And-RunControlService.md) |
| Weld markers | layer built, **renders empty** | populated | [FW-172 §1.1](FW-172-Run-Event-Markers.md) |
| Supervisor notify | **transient** — `FW-175` deferred | durable queue | [FW-177 §3](FW-177-Exception-Broadcasts.md) |
| Broadcast loop · `PLCTagService` | **unreduced, deliberately** | same | [FW-150 §`P-31`](FW-150-Broadcast-Loop.md) |

> ⚠ **`P-53` reaches the trial's opening screen — 25 Aug 2026.** `RodReceivingController` and
> all three `/rod/**` endpoints leave the service, and **DB2 rod check-in scans a rod**: the
> scan was served by `GET /rod/{alpha}`, *"everything staging and check-in need in one round
> trip"* (`[API §4.3]`). The trial therefore has no scan validation, no carry-forward gate
> (`FR-043` needs `footageRunToDate`) and no station switching (`Q24` needs `scheduledLineId`)
> until `[API]` re-homes them — `FW-138`'s `P-54`. **Settle it before T1 is scheduled.**

> **`FW-150` and `FW-151` are not reduced** precisely so the real ingest drops in behind them
> unchanged. **If either can tell the feed is simulated, the substitution has failed.**

---

## 4. Trial blockers — `[TRP §6]`

| By | Blocker | Stops | Plan |
|---|---|---|---|
| ~~28 Aug~~ ✅ **Closed 15 Aug** | ~~**`G6`** — roles as JWT claims~~ | ~~🔴 Every role-gated action in the trial~~ — **answered: the six roles exist on `ClaimTypes.Role`**, so DB2 overrides, the SPC skip, WIP disposition and the spool weight-variance override are all reachable | [FW-145](FW-145-JWT-And-Role-Policies.md) · [FW-177](FW-177-Exception-Broadcasts.md) |
| **Before the T1 QA0 walkthrough** | **`G6` residual** — the six claim **values**, coded rather than `[SEC §8]`'s labels | ⚠ Those same role-gated actions **build** fine and cannot be **verified** until the mapping lands. In `FW-177` a wrong value fails *silent* — the supervisor notification reaches an empty group | [FW-145 §5](FW-145-JWT-And-Role-Policies.md) · [FW-177 §3.1](FW-177-Exception-Broadcasts.md) |
| **Before T2** | **`Q22`** — min/max tolerance values | ⛔ Owed by e-mail, **nothing seeded**. `CHK007` is a band check at both stations | [FW-168 §`P-43`](FW-168-Spc-And-SpcService.md) |
| **Before T2** | **`G2` / `OI-39`** — cross-DB recovery | **Phase 4 is provisional until it closes**; carries the 24–64 h reserve | [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md) · [FW-151](FW-151-PLCTagService.md) |
| **Before T2** | **`G10`** — IIS WebSockets on `devual-uadev001` | Transport **silently** falls back to long-poll. **Provisioning, not build** | [FW-080](FW-080-FlatWireHub.md) |
| **Before T1 closes** | **`G23`** — the 1280×1024 canvas unconfirmed | 1920×1080 is **a re-layout of every screen, not a rescale**. *"Gets more expensive every sprint"* | FE — `[TRP §6]` |
| Before Phase 8 ships | **`Q15` / `OI-47`** — hybrid-origin guard **undefined** | `TC-118` is P1: *"gate fails until specified"*. The trial does not walk into it | [FW-179 §3](FW-179-CheckIn-Spool-And-Spools-Query.md) |

✅ **Blocker 1 closed by `D-31`** — the three `PassSchedule*` tables, their seed, 10 FKs and 6
indexes moved into MVP-1. It had blocked **both check-in screens, i.e. the whole trial**.

⚠ **Second-tier, stops no build:** `Q10`/`OI-45` — `AlloyProperty.LbPerFtFactor` is seeded
**NULL, "OQ-10 PENDING"**, so step 7's calculated net weight is NULL and **the ±2 %
scale-vs-calculated variance cannot execute**. Seed a clearly-marked provisional factor or
accept it as untestable.

---

## 5. Deferred — still MVP-1, out of the trial · 330 h

`[TRP §4]`. **Deferred is not cancelled.**

| Deferred | h | Consequence for the plans |
|---|---|---|
| **DB1** `FW-060` + `FW-154` | 42 | [FW-164](FW-164-Run-Queries-And-RunQueryService.md)'s `GET /run/active` becomes the landing route; [FW-177](FW-177-Exception-Broadcasts.md)'s `AlertRaised` **loses its consumer** and is built anyway |
| **DB2A + weld** `FW-N01`, `FW-158`, `FW-160`, `FW-063`, `FW-166` | 70 | [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md) runs without `RodStaging`; [FW-172](FW-172-Run-Event-Markers.md)'s weld marker renders empty |
| ~~**`FW-001`**~~ shared-schema renames — **CANCELLED outright, `D-32`, 18 Aug 2026; no longer a descope decision** | 36 | **Highest blast radius in the plan.** *"A trial does not need it; production does"* |
| **[`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md)** real OPC ingest | 22 | *"Not verifiable without the hardware"* — October commissioning |
| **`FW-N06`** alert rules engine | 28 | Its only consumer was DB1's alert bar |
| Spool completion **Part A** | 25 | `Should`, advisory. **Part B (`FW-202`) is `Must` and stays** |
| `FW-073` die change · `FW-167` | 23 | Grey the DB3 button |
| `FW-070` roll adjust · `FW-169` | 26 | FL2/FL3 only; grey on DB3-FL2. ⚠ **`RollAdjustTrigger` must still exist** — [FW-168 §2](FW-168-Spc-And-SpcService.md) |
| `FW-072` rod checkout · `FW-173` · `FW-175` | 39 | [FW-170](FW-170-Pause-Resume-And-RunControlService.md) ships 3 of 4 outcomes; [FW-177](FW-177-Exception-Broadcasts.md)'s notification is transient |
| `FW-124` DB5A · `FW-N02` | 19 | **`GET /spools` still ships** in [FW-179](FW-179-CheckIn-Spool-And-Spools-Query.md) |

**Phases 9–14 are wholly outside the trial.**

> ⚠ **The standing pattern for a deferred feature is *grey the control and state "not in trial
> scope"*, never delete it** (`[TRP §7]`). Deleting is rework when the feature returns.

---

## 6. Build notes that will otherwise cost rework

`[TRP §7]`, the ones with a server-side consequence:

- **FM2 has three stands** — `FM2_S1` (8″) → `FM2_S2` (6″) → `FM2_S3` (6″, non-bypassable),
  **edgers on S2 and S3 only**. Anything showing four or a separate *8″ Roller* is stale
  (`D-26`). `TC-115` asserts three rows.
- ⚠ **FL2 broadcasts `null` live gauge/width** and Live must render an explicit empty state —
  ***"the single most likely thing to ship wrong."*** [FW-181](FW-181-FL2-Null-Gauge-Contract.md).
- **Build the weld-marker layer though it renders empty** — *"a legitimate state, not a
  defect."*
- **Never stack two dialogs** — close, then open. The spool notification is the exception:
  `FR-133`/`TC-163` require it **non-blocking**.
- ⚠ **`.NET carries no automated tests`** — struck from the DoD 15 Aug 2026 (`[TS §1.2]`). The
  trial verifies the backend by **manual contract walkthrough, staffed inside the window
  rather than assumed**. Checklist: [FW-138 §6.1](FW-138-Fifteen-Thin-Controllers.md),
  **`reviewer: TBD`**.

---

## 7. The acceptance run needs a control surface

`[TRP §8]`'s ten-step run requires the simulated feed **steered while a run is live** — step 3
forces N consecutive out-of-spec readings, step 7 needs a `RUNNING → STOPPED` edge at a chosen
instant (`TC-171`'s **3 s stop against a 5 s dwell**), and
[FW-205](FW-205-ITInhibitService.md)'s condition 5 needs **dropped readings**.

**Configuration plus a restart cannot do any of it** — a restart destroys the run being
demonstrated, which is what steps 7 and 10 assert about. That was **`G43`**, and
[FW-218](FW-218-Sim-Control-Surface.md) resolves it with four endpoints over
[FW-203](FW-203-OPC-Feed-Simulator.md).

⚠ **`G39` stands regardless: steering an unverified model does not make it verified.** A
reproducible acceptance run driven by a feed we wrote is exactly the *"convincing simulator"*
that gap warns about.

---

## 8. Keeping this file true

- **A plan changes → check §1.1 and §3.** Nothing else restates plan content.
- **A blocker closes → strike it from §4** and update the owning plan.
- **Never restate an hour figure.** Every number here is `[TRP]`'s, quoted. ⚠ **Never mix a
  `[DE §2]` stream cell with a `[SSP §5]` one** — they re-derive on their own retention
  factors and **disagree on Phase-1B RT by up to 19 h.**
- **FE and DB rows name owning documents, not plans** — this folder is Backend-scoped and
  §1.2 explains the one deliberate exclusion.
- Changes go in [`CHANGELOG.md`](../../../../CHANGELOG.md) — **do not add a change log here.**

### 8.1 Two findings carried from `[TRP §1.4]`

Both hours-bearing, reported not fixed — see
[Orchestration.md §8.1](Orchestration.md):

1. **`FW-218` appears nowhere in `phase-01b`**, though it has a full card in `[TB §7]` and a
   row in `[TRP §1.4]`.
2. **`[TRP §1.4]`'s 1B Full column sums to 260 against a stated 268.** *(The Trial column
   reconciles exactly to 231.)*
