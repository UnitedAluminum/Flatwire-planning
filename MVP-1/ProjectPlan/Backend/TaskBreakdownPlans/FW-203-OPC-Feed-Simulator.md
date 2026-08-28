# FW-203 · OPC feed simulator — a stand-in for the real ingest

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — ⛔ **RE-REVIEWED BEFORE EXECUTION against the built `ual-api`, which did not exist when this was written; `P-133`/`P-134` minted.** ⛔ **The headline: three acceptance criteria cannot be met as written, and the reason is configuration rather than code.** `LineStateMap` is `{}` on all three lines, so `ITagPathResolver.TryMapLineState` returns **`false` for every value** and `FW-150` broadcasts **no `LineStatus` at all** — whatever this simulator writes into `Reading.LineStateRaw`. That kills AC 2 and AC 3's *"`LineStatus`"* and **all of AC 5**, the `RUNNING → STOPPED` edge that arms `FW-202`'s stop-confirmation prompt, which is a trial screen. **`P-133`** fixes it in the slot built for it — a values-only `LineStateMap` edit — and names the tempting wrong fix, which the resolver's own comment already forbids: *"never resolve the RUNNING to STOPPED edge by adding an enum member."* ⚠ **`P-134`:** AC 6's *"one flag pair"* needs **no new key** — `AddFlatWireOpcIngest` already branches on `SimulateOpcFeed`, so the simulator is that `if`'s `else`, which also enforces structurally the *"exactly one publisher"* rule `FlatWireOpcOptions` states in prose. ⚠ **Two build notes:** `Reading` carries **`PayoffWeights` and `ComponentStates` collections**, so a simulator that sets only the scalar fields drives four of seven channels and leaves the component panel and payoff bars dead; and **`G9`'s cadence is already picked and recorded** — `PublishIntervalMs = 1000` — so read it rather than choose one, or the two cadences drift. Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **Built — `OpcFeedSimulator` is live, 0 errors and no analyzer warning from the changed files, and the whole RT spine now runs end to end: simulator → channel → `FW-150` drain → broadcast + `RunReading` → `FW-205`'s watchdog.** ⚠ **Steering, the stop edge and the drop-readings fault are built but NOT exercisable until [`FW-218`](FW-218-Sim-Control-Surface.md) exposes them** — that is `G43`, and `P-36` chose it deliberately
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-203`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** One mistake in this story kills two of the six trial screens,
> and it is the natural mistake to make.
>
> **FL2 must be driven too.** `[SIG §5.3]` suppresses **only** the batched gauge and width
> channels on FL2 — `SpeedFPM`, `FootageCounter`, `ComponentStatus` and `LineStatus` still
> flow, and `FR-120` makes live gauge/width **`null`**, which is not the same as *absent*.
> `[TRP]` puts it plainly: ***"A simulator that drives FL1 only leaves both FL2 screens
> dead."*** DB5 and DB3-FL2 are two of the six.
>
> The second rule is the one that keeps this story honest: **it adds no interface of its
> own.** If the simulator needs a contract change, the contract is wrong.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-203 · OPC feed simulator — a stand-in for the real ingest
> **Hours:** 8 h RT · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> > **New 14 Aug 2026 for the six-screen trial run** (`[TRP §1.4]`). It **replaces `FW-N05`** (real OPC ingest, 32 h) *for the trial only* — `[DE §1]` prices that work at retention **0.90** and calls it *"not verifiable without the hardware"*, so it moves to the October commissioning window. **`FW-N05` is not cancelled**; this story is what lets the trial run without it. Hours are **additional to `[CE §3b]`**.
>
> **As a** developer,
> **I want** a synthetic gauge, width, speed, weight and footage feed on the same contract the real ingest uses,
> **So that** every screen can be built, demonstrated and accepted before a controller is available.
>
> **Acceptance Criteria:**
> - [ ] Publishes to the **same bounded channel** `FW-N05` will publish to, at the same cadence, so `FW-150`'s broadcast loop is unchanged when the real ingest arrives
> - [ ] Drives `GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus` and `LineStatus` for **FL1**
> - [ ] ⚠ **FL2 is driven too, and only gauge/width are suppressed.** `[SIG §5.3]` suppresses **only** the batched gauge and width channels on FL2 — `SpeedFPM`, `FootageCounter`, `ComponentStatus` and `LineStatus` **still flow**, and `FR-120` makes live gauge/width **`null`**. Two of the six trial screens are FL2 (DB5, DB3-FL2) and `[TRP §8]` step 9 requires Profile to stay static *"across several live ticks"* — which needs FL2 ticking. **A simulator that drives FL1 only leaves both FL2 screens dead**
> - [ ] Traces can be steered to produce **in-spec, drifting and out-of-spec** runs, so the `FR-119` reconnect path and Dashboard 3's N-consecutive-out-of-spec auto-prompt are both demonstrable
> - [ ] Drives a `RUNNING → STOPPED` edge on demand, which is what `FW-202`'s stop-confirmation state machine is armed by
> - [ ] **Switchable by configuration alongside `SimulatePLCTagPush`** — one flag pair puts the whole system in simulation
> - [ ] ⚠ **Adds no interface of its own.** If the simulator needs a contract change, the contract is wrong — that is the whole reason `FW-150` and `FW-151` are not reduced for the trial
>
> **Rate-card basis:** non-trivial service, low end @ **8 h** (§2) — **6 h AI-assisted** at `[DE §1]`'s 0.75 RT factor, which is the figure `[TRP §4]` schedules
> **Dependencies:** FW-N05 *(contract only — this story implements the other side of it)*, FW-150
> **Blockers:** **G9 / OI-34**

### 1.1 ⚠ "Steered" and "on demand" need a control surface this story does not have

Two acceptance criteria — *"traces can be steered"* and *"drives a `RUNNING → STOPPED` edge
on demand"* — describe behaviour a publisher cannot offer. `[SIM §1.2]`'s own comparison
table marks `FW-203` ❌ on *"an operator-drivable control surface"*, and **configuration plus
a restart cannot do it: a restart destroys the run being demonstrated**, which is exactly
what `[TRP §8]` steps 7 and 10 are asserting about.

**That is `G43`, and [`FW-218`](FW-218-Sim-Control-Surface.md) is its resolution.** Build the
*mechanisms* here — a steerable trace generator and a stoppable run — and let `FW-218` expose
them. See `P-36`.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The control endpoints that steer this | [`FW-218`](FW-218-Sim-Control-Surface.md) |
| The console `DB-S1` | `FW-214`, FE |
| The channel and the contract | [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md) |
| Draining and broadcasting | [`FW-150`](FW-150-Broadcast-Loop.md) |
| A line **model** that reacts to a pass-schedule push | `FW-210`, `FW-212` — **out**, deliberately |

> `[TRP §1.4]`: *"The trial does not need a machine that **reacts** — it needs a feed it can
> **steer**, and a screen to steer it from."*

---

## 2. What it must drive

| Line | Batched gauge / width | Speed · footage · component · line status |
|---|---|---|
| **FL1** | ✅ driven | ✅ driven |
| **FL2** | ❌ **suppressed**, live values **`null`** | ✅ **driven** — this is the criterion that gets missed |
| FL3 | hybrid — **not** suppressed | ✅ |

⚠ **`null` is not silence.** `FR-120` requires FL2's live gauge and width to be **`null`**,
and `[TRP §7]` calls the FL2 empty state *"the single most likely thing to ship wrong"* —
the Live view must render *"No live gauge on FL2 · see Profile"* and **must not draw a flat
line at target**, which reads as a real in-spec measurement.

⚠ **The suppression is conditioned on FL2 *in standalone mode*, not on FL2 as a line.**

---

## 3. Build order

1. A publisher writing `Reading` values into
   [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md)'s **bounded channel** — same type,
   same cadence, **no new interface**.
2. Trace generation per line with a steerable target offset, so in-spec, drifting and
   out-of-spec runs are all reachable.
3. **FL2 driven**, gauge/width suppressed at the broadcast boundary — which is
   [`FW-150`](FW-150-Broadcast-Loop.md)'s existing rule, not a simulator branch.
4. A stoppable run producing a **`RUNNING → STOPPED`** edge at a chosen instant.
5. Expose the steer/stop/drop hooks internally for
   [`FW-218`](FW-218-Sim-Control-Surface.md) — `P-36`.
6. One configuration flag, paired with `SimulatePLCTagPush`, selected **by configuration,
   not by call site**.

### 3.1 The fixtures it runs against

The trial's continuous journey is FL1 → FL2. Use **`PS-1100-FL1-001`** (Standalone, Active)
for the FL1 leg and **`PS-1100-FL2-002`** (Standalone, Active) for the FL2 leg.

> ⚠ **Not `PS-1100-FL2-001`** — it is **Hybrid** and was demoted to **`Inactive`** by `G40`
> so `-002` could exist, because `UX_PassSchedule_OneActivePerLineAlloy` permits one Active
> per line + alloy. `FR-091` validates the schedule's route mode against the **spool's
> origin route mode**, and the trial's spool comes from a Standalone FL1 run.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-35` precede this story.

### `P-36` — build the levers here, expose them in `FW-218`

Two of this card's criteria are unreachable without a control surface (§1.1). Splitting them
the other way — putting the mechanism in `FW-218` — would make `FW-218` a rewrite of the
simulator rather than an API over it, and would break the *"first increment of `FW-215`"*
relationship `[TRP §1.4]` establishes.

**So: the steerable generator, the stop edge and the drop-readings fault are built here as
internal capabilities; `FW-218` adds four HTTP endpoints over them and nothing else.**

⚠ **Consequence to accept:** those two criteria are **not demonstrable at the end of this
story**. That is not a defect in this story — it is why `G43` was raised and `FW-218`
scheduled.

### `P-133` — `LineStateMap` is the simulator's vocabulary too, and it is CONFIG

⛔ **Found by re-reviewing against the built resolver.** `LineStateMap` is `{}` on FL1, FL2 and
FL3, so `TryMapLineState` returns `false` for **every** value and `FW-150` sends **no
`LineStatus`**. Three acceptance criteria depend on it, and AC 5's `RUNNING → STOPPED` edge is
what arms `FW-202`'s stop-confirmation prompt — one of the six trial screens.

**So the simulated environment gets a vocabulary, in the slot that exists for exactly this.**
The simulator writes a raw string of its choosing into `Reading.LineStateRaw`; the map
translates it to a `LineState`. **Values only — no code, in this story or downstream.**

**This is `P-37` working, not an exception to it.** `FW-150` stays unable to tell a simulated
feed from a real one, because the difference lives entirely in configuration. At commissioning
`C2` the controller's real vocabulary replaces the simulated one **in the same slot**, and no
code moves — which is the drop-in `P-37` is protecting.

⛔ **The wrong fix is the tempting one, and the resolver already forbids it in a comment:**
*"callers must render 'unknown', never assume Idle, and **must never resolve the RUNNING to
STOPPED edge by adding an enum member**."* A developer who sees no `LineStatus` and reaches
into `LineState` or bypasses the resolver has broken the `PLC-Q01` boundary to fix a config gap.

### `P-135` — the nominal trace centres on the TRIAL FIXTURES, or the default run is out of spec

⛔ **Found by running it.** The first build centred FL1's gauge on **0.0325 in** — a plausible
flat-wire number, and nowhere near the schedules the trial actually runs. `FW-150` computes
`InSpec` against the **active run's** band, and the seeded fixtures are
`PS-1100-FL1-001` at **0.1100 ± 0.0020** and `PS-1100-FL2-002` at **0.1000 ± 0.0020**.

**So every FL1 reading would have recorded `InSpec = false` from the first tick**, and DB3's
N-consecutive-out-of-spec auto-prompt would fire before anyone touched a control. The
acceptance criterion is *"steered to produce in-spec, **drifting** and out-of-spec runs"* —
**in-spec is the baseline steering moves away from**, and without it there is nothing to steer.

**The nominal is now per line, taken from §3.1's fixtures.** If a run carries a different band,
**steer rather than rebuild**: `Steer` moves the centre at runtime and is what `FW-218` exposes.

⚠ **This is `G39` in miniature.** The number was invented, looked reasonable, and was wrong by
a factor of three. Nothing in the feed is evidence of how the machine behaves.

### `P-134` — the simulator is the existing flag's `else`, not a second flag

`AddFlatWireOpcIngest` already reads `SimulateOpcFeed` and registers `OpcIngestService` when it
is **false**. AC 6's *"switchable by configuration alongside `SimulatePLCTagPush`"* therefore
needs **no new key**: the simulator registers when it is **true**, in the same branch.

**The if/else is doing more than tidiness.** `FlatWireOpcOptions` states the rule in prose —
*"exactly one publisher may write to the bounded channel … registering both would double-write
every tick, two snapshots per line from alternating sources, and a gauge trace that looks like
noise."* An `if`/`else` makes that **unrepresentable**; two independent flags would leave it as
a deployment mistake nobody would diagnose from the symptom.

### `P-37` — no new interface, and no simulator-aware branch downstream

AC 7 is the load-bearing constraint. **This story adds no type, no interface and no channel**
— it publishes against what `FW-N05` defines.

The corollary belongs downstream: **`FW-150` and `FW-151` must not be able to tell** whether
the feed is real. If either grows a simulator branch, the substitution has failed and the
October ingest drop-in is no longer a drop-in. That is the entire reason `[TRP §1.4]` leaves
both unreduced.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified by observation in the QA0 walkthrough and by
`[TRP §8]`'s acceptance run.

| Check | Expected |
|---|---|
| Same channel, same cadence | `FW-150` drains it with **no code change** |
| No new interface | The diff adds no type to the telemetry contract |
| FL1 | All seven channels driven |
| **FL2 driven** | Speed, footage, component and line status **arriving**; gauge/width **`null`**, not absent, not zero, not a flat line at target |
| FL3 hybrid | Not suppressed |
| Steering | In-spec, drifting and out-of-spec runs all reachable |
| Stop edge | `RUNNING → STOPPED` at a chosen instant |
| Config | One flag pair with `SimulatePLCTagPush`; no `IsDevelopment()` |
| Fixtures | FL1 `PS-1100-FL1-001`, FL2 **`PS-1100-FL2-002`** |

⚠ **Steering and the stop edge are only *exercisable* once
[`FW-218`](FW-218-Sim-Control-Surface.md) lands.**

---

## 6. Handoff

`FW-218` puts four endpoints over this. `FW-214` (FE) puts a console over those. `FW-N05`
replaces it at commissioning with **no change to `FW-150`** — that is `P-37`'s test.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`G9` / `OI-34`** *(blocker)* | The real-time NFRs are undefined, so **the simulator has no target cadence to match — pick one and record it** |
| **`G43`** | Resolved by `FW-218`; without it two criteria here are unreachable |
| **`G39`** | ⚠ **Steering an unverified model does not make it verified.** A reproducible acceptance run driven by a feed we wrote is exactly the *"convincing simulator"* that gap warns about. **Do not read a green trial as evidence the machine behaves this way** |
| **`G40`** | Fixtures — §3.1 |

No stale citations in this card.
