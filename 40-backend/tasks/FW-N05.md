---
id: FW-N05
legacy_id:
title: OPC ingest hosted service and bounded channel
status: not-started
status_confirmed: false
status_note: "⚠ **Deferred for the trial, not cancelled** — `FW-203` stands in until commissioning"
owner:
jira:
mvp: 1
phase: "1B"
stream: RT
streams: [RT]
priority: critical
hours: 32
sprint: S0
depends_on: [FW-144, FW-080]
blocked_by: [G29, G32, G33, PLC-Q05]
has_plan: true
started:
completed:
---
# FW-N05 · OPC ingest hosted service and bounded channel

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 28, 2026 — ✅ **EXECUTED, AND VERIFIED BY HARNESS AND BY BOOT. The contract is built and the hosted service is built, registered off, and blocked exactly where `P-120` said it would be.** Built in `ual-api`: **`Reading`** (`FlatWire.Domain/Models/RealTime/Reading.cs`), **`IReadingChannel`** + **`ReadingChannel`** (bounded, `DropOldest`, `SingleReader`, `SingleWriter = false`), **`OpcIngestService`** (`FlatWire.Infrastructure`), three new options (`SimulateOpcFeed`, `ChannelCapacity`, `IngestLines`) with validation, and the registration seam `AddFlatWireOpcIngest`. **0 errors, 13 warnings on a clean rebuild — 5 code warnings, all pre-existing, none in these files.** ✅ **The headline behaviour is verified: 9 of 9 harness assertions pass.** A 1,524-snapshot burst against a stalled drain stayed **bounded at 1,024**, the **oldest 500 were dropped and the freshest survived**, `written − drained = 500` made the resolution loss observable, and the whole burst allocated **349.7 KB** — ~235 bytes a snapshot, so `P-28`'s 1024 default costs ~240 KB. ⛔ **EXECUTION FOUND A DEFECT THE REVIEW DID NOT: the configuration binder APPENDS to a collection that already holds C# defaults.** `IngestLines = ["FL1","FL2"]` in code plus the same two in `appsettings` bound to **`FL1, FL2, FL1, FL2`** — four poll loops reading every tag **twice a second**, which the boot log printed as *"OPC ingest started: FL1, FL2, FL1, FL2"*. Worse than the doubling: a deployer setting `["FL3"]` would get `FL1, FL2, FL3` and **could not remove the first two**, making this card's `{FL1,FL2}`-or-`{FL3}` rule impossible to honour. **Fixed by removing the C# default** (`P-123`) — the default lives in `appsettings.json`, where it can be overridden — **plus a dedupe guard** in the service, since a deployer listing a line twice is the same bug by hand. ✅ **Re-booted: `FL1, FL2` once each.** ✅ **`G59`/`G60` reproduced by boot, by name:** with the flag flipped, both lines log *"cannot resolve … `FlatWireOpc:OpcModuleId` is not configured (gap G60 …)"* — **once per line, twice in 15 seconds of ticking**, and the host **stayed up** (health `200`, `database.reachable: true`). That last property is the one that matters: a deferred, blocked ingest does not take the API down. ⚠ **Two of this card's own numbers are corrected by the build: the read list is 14 of FL1's 17 paths and 11 of FL2's 22 — 25 tag reads in 2 POSTs a second**, not the ~37 this card estimated, because the dancers, the two edger keys and the write-only interlock have nowhere to land (`P-122`). ⚠ **And one is now stale: `Polly` IS in `FlatWire.Infrastructure`'s package set** — `FW-151` added it on 28 Aug. What was missing instead was **`Microsoft.Extensions.Hosting.Abstractions`**, which AC 1's placement requires and which was **not** centrally pinned; added at **8.0.1** to match the net8.0 shared framework (`P-121`). ⚠ **One review finding withdrawn:** the *"no fault tag on any FM2 stand"* item is **already tracked** — `TagNames.Fm2S3Faulted` carries a derived path and its own note citing `PLC-Q02` / `[PLC §5.4]`. It was not a new gap. Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Deferred for the trial, not cancelled** — `FW-203` stands in until commissioning
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-N05`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — index: [README.md](../../DOCUMENTS.md)

---

> **Why this document exists.** Three things.
>
> **This story is deferred and uncancelled, and the difference matters.** `[TRP §1.4]` calls
> deferring it *"the single highest-value deferral in this plan"* — it moves 16 h **and**
> removes the trial's only hardware dependency. But **the contract must still be built**, and
> that is the whole point: `FW-150` and `FW-151` are **unreduced for the trial** precisely so
> the real ingest drops in behind them unchanged. **Neither the simulator nor `FW-218`
> offsets this story's 32 h.**
>
> **Its design is one specific idea:** a bounded channel with **drop-oldest/coalesce**, so
> *"backpressure degrades resolution, never memory."* A slow consumer must lose **precision**,
> not the process.
>
> **And the deferral hid a build-order trap.** Because the hosted service waits for
> commissioning, nobody checked whether it can authenticate — and it cannot. `G59` and `G60`
> are step 0 here (§2.4, `P-120`), not October's problem.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-N05 · OPC ingest hosted service and bounded channel
> **Hours:** 32 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> **As an** operator,
> **I want** PLC tag values ingested continuously without the service falling behind,
> **So that** a slow consumer degrades resolution rather than crashing the pipeline.
>
> **Acceptance Criteria:**
> - [ ] `IHostedService` in `FlatWire.Infrastructure` reads FL1/FL2/FL3 tags via the existing `OPCConnection` domain
> - [ ] Readings land in a **bounded `System.Threading.Channels.Channel<Reading>`** with **drop-oldest / coalesce** on overflow — backpressure degrades resolution, never memory
> - [ ] Tag paths come from configuration (FW-144), never from code
> - [ ] Integration test: a burst faster than the drain rate coalesces rather than growing unbounded
>
> **Rate-card basis:** OPC ingest priced against §0.4's backpressure-safe design (32 h)
> **Dependencies:** FW-144, FW-080
> **Blockers:** **`PLC-Q05`** / **G33** · **G29** (no edger tag path exists on any line) · **G32** (FM2 station names are ours, not the controller's)

### 1.1 The trial substitution

| | |
|---|---|
| **Trial (30 Sep)** | [`FW-203`](FW-203.md) publishes to **this story's channel, on this story's contract**, at the same cadence |
| **This story** | Deferred to the **October commissioning window**. `[DE §1]` prices it at retention **0.90** and calls it *"not verifiable without the hardware"* |
| **Not offset** | `FW-203`'s 8 h and `FW-218`'s 18 h are **additive**; this story's 32 h stands |

⚠ **The 16 h and the 32 h are both right — they are different bases.** `[TRP §1.4]`'s
*"moves 16 h"* is the **AI-assisted** delta (22 h → the 6 h simulator); **32 h is the
hand-coded base** `[TB §7]` publishes and `[CE §3b]` carries. Neither figure is restated here.

**The contract is the deliverable that cannot slip.** If the simulator needs a contract
change, the contract is wrong.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| Draining the channel and broadcasting | [`FW-150`](FW-150.md) |
| **Writing** tags | [`FW-151`](FW-151.md) — this story only **reads** |
| The tag-path map's contents | `[PLC]`; bound by [`FW-144`](FW-144.md) |
| **FL2's `null` gauge/width suppression** | [`FW-150`](FW-150.md) / [`FW-181`](FW-181.md) — a **broadcast-boundary** rule (`[SIG §5.3]`, `FR-120`). **The ingest has no FL2 branch** |
| Resolving a line's **active run** | [`FW-150`](FW-150.md), which persists `RunReading` — §2.5 |
| The simulated feed | [`FW-203`](FW-203.md) |
| The `IReadingSource` seam | `FW-211` — **unscheduled**, additive to `[CE §3b]` |

---

## 2. The design

### 2.1 The channel is the whole idea

A **bounded** `System.Threading.Channels.Channel<Reading>` with **drop-oldest / coalesce** on
overflow. It decouples the OPC poll rate from hub fan-out, which is what lets the two
cadences differ (§2.2).

- **Bounded, never unbounded.** An unbounded channel converts a slow consumer into a memory
  leak, which is the failure this criterion exists to prevent.
- **Drop-oldest / coalesce**, not block and not drop-newest. For telemetry the freshest
  reading is the useful one; losing an old sample costs resolution, and that is the
  acceptable trade.
- **One channel for all lines** — single-reader (`FW-150`), one writer **per polled line**.
  Set `SingleReader = true` and leave **`SingleWriter = false`**: each line's poll loop writes,
  and claiming a single writer to save an interlocked operation is a correctness bug, not a
  saving. `FW-150` groups per line as it already must — and `IFlatWireBroadcaster` is already
  `Line(LineId) → IFlatWireClient`, so **per line is the unit the whole RT spine is keyed on.**
- ⚠ **`DropOldest` gives you no signal that it dropped** — `TryWrite` returns `true` either
  way. So expose a **written count** here and let `FW-150` expose the drained count: the
  difference *is* the resolution loss, and without those two numbers *"degrades resolution"* is
  unobservable. Two counters, no instrumentation framework.

**Concretely: `BoundedChannelFullMode.DropOldest` over a per-line snapshot, and nothing else**
(`P-119`). One `TryWrite` per line per tick — no lock, no dictionary, no last-value cache.

> ⚠ **Where backpressure actually comes from — worth saying plainly, because it changes what
> to build.** At `NFR005`'s 1 s default the source produces **two snapshots a second** (§2.3:
> FL3 is configured and inert) and the drain runs at **10 Hz**: the channel is **empty almost always** and no coalescing happens in
> the steady state. The bound earns its place in exactly two situations — a **stalled drain**
> (a blocked broadcast, a slow `RunReading` write) and an **AGC feed faster than the poll
> interval**, which is `G9`. **Do not build machinery for the steady state; build the cheap
> thing that survives the stall.**

> ⚠ **The channel cannot be sized from published NFRs.** `G9`/`OI-34` leaves the AGC sample
> rate, concurrent client count and latency budget undefined, so there is no arithmetic for
> the bound and `TC-620`–`TC-623` are untestable. **Pick a value, record it, and say it is
> provisional** — `P-28`, which now carries the shape of the arithmetic and a default.

### 2.2 Two cadences, and this is the upstream one

| Knob | Value | Whose |
|---|---|---|
| **OPC publish interval** | `NFR005`: **1 s default**, configurable 5 / 10 / 30 s — `[PLCC]`'s `PublishIntervalMs`, bound on `FlatWireOpcOptions` | **this story** |
| Hub drain cadence | ~100 ms / 10 Hz — `FlatWireSignalROptions.DrainCadenceMs` | [`FW-150`](FW-150.md) |

They sit on opposite sides of the channel. **Never derive one from the other**
([`FW-144 §2.1`](FW-144.md), which built and validated both keys —
`PublishIntervalMs` is rejected at boot unless it is 1000 / 5000 / 10000 / 30000).

### 2.3 What to read — the API is built, and `G31` is more decidable than it looks

**The surface exists, is measured, and has a method.**
[`FW-144`](FW-144.md) built the map behind **`ITagPathResolver`**
(`ConfigurationTagPathResolver`, `FlatWire.Domain/Services/`), and
**`ITagPathResolver.LogicalNamesFor(LineId)`** is documented on the built interface as *"the
ingest subscription list — `FW-N05` subscribes from this."* **Resolve through that interface;
never compose a path in code** — that is what keeps `grep` at zero hits outside configuration,
and it is the seam `OI-A` was contained behind. ✅ **The map has now moved — `D-44`, 4 Sep 2026:
it is the `CommonDB` `OPCTags` registration.** Nothing in this story changes: the interface,
the call and the start-up resolve are identical, and only the implementation behind it becomes a
`CommonDbTagPathResolver` (`FW-238`, gated on `G93`). ⚠ **One check tightens** — *zero hits
outside configuration* becomes **zero hits in any file**, since no file holds a path at all.

⚠ **Resolve the path list ONCE at start-up, not per tick.** `Resolve` throws
`KeyNotFoundException` **by design** — an unresolved path must fail the operation that needed
it — and in a 1 Hz loop that design becomes an exception every second. Build each line's
`(logical name → path)` list at boot, fail loudly there, and poll from the built list.

⚠ **The logical names are NOT the same on every line, so no shared hard-coded list works.**
Footage is `TKUP1` on FL1 and `TKUP2` on FL2/FL3 (`FL1.TKUP2` is *deliberately absent* —
`PLC-Q02`); FL1 and FL3 have two payoffs, FL2 one; **and FL2 has no `AGC` row at all**. This is
exactly why `LogicalNamesFor(line)` takes a line.

**`G31` is more decidable than its wording suggests — `[PLC]`'s own *"used in"* column answers
most of it**, and it disagrees with the gap's *"no named surviving consumer"*:

| Read | Consumer named in `[PLC]` | Verdict |
|---|---|---|
| `Status.IsActive`, `RollGap`, `Diameter` | Run-monitor **component panel** · **roll-adjust *Current*** (`PLC-Q09`) — matching `[SIG §5.2]` event 6's stated consumers | **Read** |
| `Status.IsFaulted` | **The line status board's Critical *component fault* alert** — i.e. `AlertRaised`, which is why it is absent from event 6's payload | **Read** |
| Dancer elements | Component panel, `[PROPOSED]` under `PLC-Q18` / `G35`, test `C12` | **Read; expect nulls** |
| **`FL1.EdgeSet.Status.IsActive`** | **None, anywhere** — and FL1 is the one line **with no edger** (`G29`) | **Do not read** |
| `ITInhibit` | Written, never read (`[PLC §8.1]`) | **Not a read at all** |

⛔ **FL3 is configured and inert, and the ingest must poll FL1 and FL2 only.** The built
`FlatWireOpcOptions.Lines` says so in as many words, and the reason is `PLC-Q08` / `G30`:
whether FL3's finishing stands are addressed `FL3.FM2.*` or **`FL2.FM2.*`** is unanswered. Under
the second answer, polling FL2 and FL3 together **reads the same load cell and the same three
stands twice a second** — a doubling of OPC load that no screen would reveal. When `PLC-Q08`
answers, the rule is **{FL1, FL2} *or* {FL3}, never all three.**

> ⚠ **"Subscription" is the register's word, not the mechanism.** `OPCConnection` does expose a
> real subscription path (`IOPCManager.SubscribeAll`, pushed over `OPCManagerHub`), but the
> integration surface every existing consumer uses is **`GetOPCInfo` then `ReadTag`** — a
> **poll**. So this is a **read list**, and `P-118` records why we do not take the subscription.

⚠ **The `41`-path figure this card carried is struck.** `41` (FL1 15 · FL2 14 · FL3 23) predates
`[PLC]` v1.1's dancer rows; `FW-144` measured **72** bound at runtime (FL1 17 · FL2 22 ·
FL3 33). **The risk is unchanged — it is *every* path — and re-baselining the literal is
`G33`'s, not this plan's.**

✅ **The read list is measured, not estimated — `14` of FL1's 17 and `11` of FL2's 22, so **25 tag
reads in 2 POSTs a second** (logged at boot, 28 Aug 2026). It is smaller than this section first
implied because a read needs somewhere to land: the write-only interlock, the two derived edger
keys and the ten dancer elements are all excluded, each for a stated reason — `P-122`.

### 2.4 The transport, and four things the built `ual-api` forces

Measured against `API/Domain/OPCConnection` on 28 Aug 2026. All four are shared with
[`FW-151`](FW-151.md), which found them on the write path; **three bite harder
here, because this path runs continuously rather than once per operator action.**

| # | What the code does | Consequence for the ingest |
|---|---|---|
| 1 | **`ReadTag([FromBody] OPCInfo opc)` returns `List<OPCTag>`** — the handler resolves one manager, checks connectivity **once**, then loops `opcManager.ReadTag(tag)` over `OPC.Tags` | **One POST reads a whole line.** 2 POSTs/s at the 1 s default, not ~39 (`P-118`) |
| 2 | **`GetOPCInfo` must run first** — `MachineId`, `OPCServers`, `ConnectionType` and `IsReadonly` are `CommonDB` state and cannot be hand-built (`FW-151` `P-104`) | Resolve **once at start-up, every line in one call.** ✅ The cache is **already built and configured** — `FlatWireOpcOptions.OpcInfoCacheSeconds`, default **300** — so reuse it rather than adding one. Never resolve per tick |
| 3 | ⛔ **A failed read is indistinguishable from a good one.** Both managers return the tag **unchanged** on a null read or an `OpcException`; `OPCUAManager.ReadTag` logs at `LogInformation` and **never sets `IsGood`**, while `OPCDAManager.ReadTag` does — and `ConnectionType` decides which one runs (`G58`'s read-side twin) | **Send `Value = null` and treat a null return as *no reading*** (`FW-151` `P-105`'s sentinel, natural on a read path). **Do not gate on `IsGood`.** Publish `null`, and **never carry the previous tick's value forward** |
| 4 | ⛔ **`RestClient` reports transport faults in-band** — it catches everything and returns `Result.Fail`; a connectivity failure inside the handler throws and surfaces the same way | Branch on **`Result.IsFailure`**, not on an exception (`FW-151` `P-109`). Polly retries on the result |

⛔ **And two blockers that stop the first line of it — `P-120`.**

- **`G59` — there is no identity.** `RestClient.SetHeadersAsync` reads the token from
  `context.HttpContext`; a hosted service has none, so it dereferences null and **`GetOPCInfo`
  fails before the network**, with a message naming neither the identity nor the caller.
  `ReadTagQueryValidator` independently requires a **non-empty `AccessToken`** and
  `MachineId > 0`, and both routes sit behind the global `AuthorizeFilter`. **The register names
  `SetITInhibit` and hold/restore; this story is the third and largest case.**
- **`G60` — nothing registers flat wire with `OPCConnection`.** `OPCModules` has five members
  and no flat wire one, and none of the eight `30-database/scripts/` files touches
  `OPCModules` / `OPCServers` / `OPCTags` / `OPCTagApplicationMapping`. **With a token and no
  registration, `GetOPCInfo` returns an empty list.**

⚠ **`RestClient` is registered `AddScoped` (`FW-151` step 0) and an `IHostedService` is a
singleton** — take an `IServiceScopeFactory` and open a scope per tick. Cheap, and the
alternative is a captive-dependency bug that only shows under load.

⛔ **Exactly one publisher may be registered.** This service and
[`FW-203`](FW-203.md) write to the same channel, so registering both
double-writes every tick — two snapshots per line, alternating sources, and a gauge trace that
looks like noise. ⚠ **The flag that decides is not built yet:** `FlatWireOpcOptions` carries
`SimulatePLCTagPush` and no feed flag, so `FW-203`'s *"switchable by configuration alongside
`SimulatePLCTagPush`"* has only one half. **Whoever builds second owns the pair** — and the
registration, not the call site, is where the choice belongs (`FW-140`'s stub-swap pattern).

### 2.5 `Reading` — the contract, defined here at last

`P-29` has required this since first issue and nothing in the repository defines it, while
`FW-203` publishes to it and `FW-150` drains it. **It is one record per line per tick — the
POST's response, mapped once at ingest** (`P-119`).

| Field | Type | Note |
|---|---|---|
| `Line` | **`Enums.LineId`** | The built enum — `FL1` / `FL2` / `FL3`, and the same type `ITagPathResolver` and `IFlatWireBroadcaster.Line()` already take |
| `ReadAt` | `DateTimeOffset` | Stamped **at ingest, server-side** (`FR-174`). `FW-150` converts to UTC for `RunReading.ReadingTs`, the one `DATETIME2` exception |
| `GaugeIn` · `WidthIn` | `decimal?` | `null` = **absent**, and on FL2 that is structural, not a branch (below) |
| `SpeedFpm` · `FootageFt` | `decimal?` | Unit suffix per `phase-01b`'s cross-cutting rule. **`0` is a real value here** — a stopped line, a run at footage zero |
| `LineStateRaw` | `string?` | The controller's **raw** value. Mapping is `ITagPathResolver.TryMapLineState`, which **returns `false` until commissioning test `C2`** and callers must not treat that as an error; `enum LineState` has no `Stopped` member |
| `PayoffWeights` | small array of **`(PayoffPosition, decimal)`** | One entry per configured payoff — **two on FL1/FL3, one on FL2** |
| `ComponentStates` | small array of **`(ComponentName, bool isActive, bool isFaulted, decimal? currentValue)`** | `ComponentName` is the built 7-member enum (`DB1`, `DB2`, `FM1`, `EdgeSet`, `FM2_S1..S3`). **`currentValue` is the roll gap for mills and the die diameter for die blocks** |

⛔ **Raw primitives, not the seven quantity value objects — and the reason is a throw, not a
preference.** `FW-207` built `Gauge`, `Width`, `Footage`, `WeightLb`, `SpeedFpm`, `RollGap` and
`RollDiameter` precisely so units cannot be mixed, so a reviewer will ask for them here. **But
`Gauge` and `Width` are `RequirePositive`: `new Gauge(0)` throws** — and `0` is exactly what an
idle, unconfigured or mis-read tag returns, so constructing them in the poll loop makes a bad
tag value an exception **every second**. `Footage`, `WeightLb`, `SpeedFpm` and `RollGap` are
`RequireNonNegative` and would not throw, but splitting the record between VOs and primitives is
worse than either. **So: primitives in the channel, value objects constructed downstream** —
which is also `Gauge`'s own documented rule, *"absent rather than zero — model that as a `null`
`Gauge`, never `new Gauge(0)`."*

**The mapping rule that follows, and it is the one to get right:** gauge and width **`≤ 0` → `null`**
(zero thickness is not a measurement); speed, footage and weight **keep `0`** (a stopped line is
not a missing reading — `SpeedFpm` even publishes `IsStopped`).

**Four properties, each load-bearing:**

1. **Path → channel mapping happens here, once**, through `ITagPathResolver`. Handing raw
   `OPCTag` lists downstream would put tag-path knowledge inside the broadcast loop.
2. **It is a snapshot, so drop-oldest coalesces correctly** — a newer snapshot supersedes an
   older one in every field. That is why no keyed coalescer is needed, and it is why the unit is
   a line: `IFlatWireBroadcaster` is already `Line(LineId) → IFlatWireClient`.
3. ✅ **FL2's `null` gauge and width need no ingest branch, because FL2's published map has no
   `AGC` row at all** — `[PLC §5.2.2]` carries the three stands, speed, one payoff, footage,
   line state and the dancers, and no live measurement (assumption `A3`: *"FL2 has no live
   measurement"*). So `LogicalNamesFor(FL2)` returns nothing to suppress. ⚠ **Never write
   `if (line == FL2)` anywhere in this service** — the suppression `[SIG §5.3]` and `FR-120`
   describe is `FW-150`'s broadcast-boundary rule, and here it is simply absence.
4. **`RunId` is deliberately absent.** The ingest reads a **line**, not a run; `FW-150`
   resolves the active run when it persists. And `RunReading`'s built columns — `FootageFt`,
   `GaugeIn`, `WidthIn`, `SpeedFPM`, `InSpec`, `ReadingTs` — **already are a per-line
   snapshot**, so persistence is 1:1 with no reshaping (`G3`, table half built 26 Aug 2026).

---

## 3. Build order

0. ⛔ **Identity and registration first** (`P-120`) — without them nothing after step 1 can be
   executed even once. `G59` decides how a hosted service authenticates (the `CoolingChamber`
   badge-login precedent, or a token held for the run's duration); `G60` adds the flat wire
   `OPCModules` member and the `CommonDB` registration script. **Neither is this story's to
   decide alone — raise both now, not in the 40 h Phase-14 window.**
1. `IHostedService` in `FlatWire.Infrastructure`, reading through the existing
   **`OPCConnection`** domain (`[ARC §2.2]`: the tag layer to integrate with) — `GetOPCInfo`
   **once** at start-up, cached (§2.4 row 2). ⚠ The AC says *"FL1/FL2/FL3"*; **build for three
   and poll two** — FL3 is configured and inert (step 2), exactly as `FlatWireOpcOptions.Lines`
   already is.
2. **One `PeriodicTimer` loop per polled line — FL1 and FL2 only** (§2.3: FL3 is configured and
   inert pending `PLC-Q08` / `G30`), `await`ing its read inside the loop, so a slow OPC read
   **delays the next poll instead of stacking** and one slow line never blocks the other.
   `WaitForNextTickAsync` skips missed ticks rather than queueing them, which is the behaviour
   wanted. No fire-and-forget per tick.
3. **Resolve each line's path list once, here, at start-up** (§2.3) — `Resolve` throws by design,
   so a missing logical name must fail the boot, not every tick.
4. **One batched `ReadTag` POST per line per tick**, `Value = null` on every tag (§2.4 rows 1
   and 3). Map the response to one `Reading` — primitives, `≤ 0` gauge/width to `null` (§2.5) —
   and `TryWrite` it.
5. The bounded channel — `DropOldest`, `SingleReader`, `SingleWriter = false`, capacity from
   configuration (`P-28`), plus the written counter that makes a drop observable (§2.1).
6. Tag paths through `ITagPathResolver` — **never from code**, so a wrong path found at
   commissioning is a config edit, not a redeploy.
7. Publish interval from configuration, default 1 s (§2.2).
8. Read only the paths with a confirmed consumer — **not `EdgeSet`** (§2.3).
9. Resilience: **Polly** on the outbound call, sharing
   [`FW-151`](FW-151.md)'s policy — **retry on `Result.IsFailure`, not on an
   exception** (`P-109`), once, and never on a rejected read. ✅ **`Polly` is already in
   `FlatWire.Infrastructure`'s package set** — `FW-151` added it on 28 Aug 2026, so this step needs
   no `<PackageReference>`. ⚠ **`Microsoft.Extensions.Hosting.Abstractions` was the one missing**,
   and unlike Polly it was not centrally pinned (`P-121`). ⚠ **The retry sits inside a per-tick
   deadline** — the whole attempt is bounded by the publish interval, so a hung OPC server costs one
   tick rather than the client timeout plus a retry. On a 1 s cadence the next poll IS the retry.
10. **Publish nothing beyond §2.5's record.** The surface `FW-203` and this story share is
   **this card's `Reading` and channel**, and neither may widen it. *(This step cited
   `[SIG §5.2]` until 28 Aug 2026 — that is `FW-149`'s **client** contract, on the far side of
   `FW-150`, and widening it is `FW-149`'s business, not this seam's.)*

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder. This story owns **`P-28`**, **`P-29`** and
> **`P-118`**–**`P-123`**; new decisions elsewhere mint at **`P-124`+**.
>
> **`P-121`–`P-123` were minted by executing it**, which is why they read like build notes
> rather than design calls: two of the three are things the plan could not have known.

### `P-28` — size the channel by configuration, with a stated default and stated reasoning

`G9`/`OI-34` means there is no defensible arithmetic from the NFRs. **But there is a shape for
one**, and writing it down beats "pick a number":

> **capacity ≈ expected snapshots per second × seconds of drain stall to survive.**

At the 1 s default that is 2/s (§2.1 — FL1 and FL2). **Provisional default: `1024`** — a snapshot is a few
hundred bytes, so the worst case is well under a megabyte, and it absorbs a multi-minute stall
or an AGC feed far faster than 1 Hz. **Configured, not `const`**: a guess in `appsettings` is
revisable at commissioning, a guess in code is a redeploy. It belongs on `FlatWireOpcOptions`
beside `PublishIntervalMs`, validated by `FW-144`'s existing `IValidateOptions<T>` so a
nonsense value fails at boot **by name**.

Record the number and this reasoning in the configuration comment, and state that it is
provisional pending `G9`. **Do not let the absence of NFRs become a reason to leave it
unbounded** — bounded-with-a-guessed-size degrades gracefully; unbounded fails as a memory
leak under exactly the load nobody has specified.

### `P-29` — the contract is frozen before the simulator uses it

`FW-203` publishes to this channel and `FW-150` drains it, both **before** this story is built.
So the `Reading` type, the channel's shape and the publish semantics are fixed by the trial and
must not change when the real ingest arrives — that is the entire justification for `FW-150`
and `FW-151` being unreduced.

**Practical consequence: define `Reading` and the channel here and now, even though the hosted
service is deferred.** A deferred story whose *contract* is also deferred cannot be stood in
for. ✅ **Discharged 28 Aug 2026 — §2.5.**

### `P-118` — one batched `ReadTag` POST per line per interval; no per-tag call, no subscription

`ReadTag` takes `OPCInfo.Tags` as a list and the handler loops inside one connectivity check,
so **the batch is free and already built**. Per-tag calls would cost one round trip per
bound path — **FL1 17 + FL2 22 ≈ 39 a second** — against **2**, each with its own token header, validation and manager resolution — the easiest
way to make this service the slow part of the plant.

**Per line, not one POST for all lines:** `OPCInfo` carries one `MachineId` and one server list
— `LineTagOptions.MachineId`, one per line — so a line is the natural unit, and it isolates a
slow or dead line. **Two lines are polled today** (§2.3).

⚠ **Honest about what the batch does and does not save.** It collapses **HTTP** round trips;
inside the handler `OPCConnection` still reads **tag by tag** (`easyDAClient.ReadItem` /
`easyUAClient.Read` per tag, sequentially, after one `CheckConnectivityAndChannelStatus`). So a
line's read costs *n* OPC reads however it is called — **the win is 2 requests instead of 39,
not fewer OPC operations.** If a line's serial read ever approaches the publish interval, the
fix is a batch read in `OPCConnection` (`ReadMultipleItems`), which is **that service's change,
not this one's** — the same boundary `G58` draws.

**And we do not take `OPCConnection`'s subscription path** (`SubscribeAll` + `OPCManagerHub`),
though it exists. Three reasons, in order: the cadence would be that service's rather than
`NFR005`'s configured one; it adds a second SignalR **client** and a connection lifecycle to a
service that already owns a hub; and every existing consumer in `ual-api` polls `GetOPCInfo` +
`ReadTag`, so polling is the path with precedent and with `FW-151`'s Polly policy already
shaped for it. ⚠ **If `G9` ever specifies an AGC rate a 1 s poll cannot serve, this is the
decision to revisit** — and `IReadingSource` (`FW-211`) is where it would be revisited without
touching `FW-150`.

### `P-119` — `Reading` is a per-line snapshot, and that is what makes "coalesce" free

The AC says drop-oldest **/ coalesce**, and coalescing is not a channel feature. The obvious
implementation — a dictionary of last values per tag behind a lock, drained on a timer — puts a
lock on the hot path and duplicates `FW-150`'s on-change detection.

**So make the channel item a per-line snapshot** (§2.5). A newer snapshot supersedes an older
one in every field, so `BoundedChannelFullMode.DropOldest` **is** the coalesce, at zero cost
and with no shared state: one allocation per line per tick, one `TryWrite`, no lock anywhere.

✅ **The built code already agrees the unit is a line.** `IFlatWireBroadcaster` is
`Line(LineId) → IFlatWireClient`, `ITagPathResolver` is keyed by `LineId`, and `OPCInfo` carries
one `MachineId`. A per-tag channel item would be the only per-tag thing in the whole spine.

⚠ **Consequence to accept:** coalescing is **per line, not per tag** — a dropped snapshot loses
that instant's other channels too. That is correct for telemetry sampled together off one
controller read, and it is the trade the AC's *"degrades resolution"* already names.

### `P-120` — identity and registration are step 0, not commissioning detail

`G59` and `G60` were both raised on the **write** path and neither names this story, which is
how a deferred plan hides its own hardest precondition: **the first `GetOPCInfo` this service
issues fails before the network, and the register does not say so.**

**So they are build-order step 0** (§3), owned here to the extent of raising them with dates and
named owners. The reasoning is `G60`'s own: `SimulatePLCTagPush` is `true` in every environment
until commissioning, so **nothing exercises this path before Phase 14** — the window
`[PLCC §4]` already calls the worst compression in the schedule, where `C1`/`C11` must also
confirm every tag path (`G33`) and the FM2 station names (`G32`). **Discovering there is no
service identity inside that window spends commissioning time on an architecture decision.**

⚠ **Whichever identity is chosen, the failure must be loud.** The measured behaviour is a caught
`NullReferenceException` returned in-band as `Result.Fail` — a continuous ingest that logs and
retries that quietly is a line running blind behind a green service.

### `P-121` — `Hosting.Abstractions` is pinned centrally; AC 1's placement stands

AC 1 puts the `IHostedService` in `FlatWire.Infrastructure`, and that project could not see
`BackgroundService` — **`Microsoft.Extensions.Hosting.Abstractions` was not in
`API/Directory.Packages.props`**, unlike the three packages `FW-151` added. So a **new central
pin** was needed, at **8.0.1** to match the net8.0 shared framework the API runs on rather than
pulling a 9.x or 10.x assembly behind it.

**Adding a pin is safe; changing one would not be.** A `PackageVersion` applies only to projects
that reference the package, so the blast radius today is `FlatWire.Infrastructure` alone.

⚠ **This is `P-108`'s case, not `P-101`'s**, and they look identical until you check why. `P-101`
had to mint a Domain-side abstraction because `IHubContext<>` lives in the ASP.NET Core **shared
framework**, which a class library cannot reference at all. This is an ordinary NuGet package, so
an extra interface would be indirection bought for nothing.

### `P-122` — the read list is the snapshot's fields, and the excluded names are logged

`G31` asks which tags to subscribe to. The build answers it with a rule rather than a list:
**a read needs somewhere to land.** Every name in `IngestedNames` maps to a field on `Reading`
and thence to a published `[SIG §5.2]` payload. **Measured at boot: 14 of FL1's 17 paths and 11
of FL2's 22 — 25 tag reads in 2 POSTs a second.** What is excluded, and why:

| Excluded | Reason |
|---|---|
| `ITInhibit` | **Written, never read** (`[PLC §8.1]`). Reading it is the first step toward the operator clear path that must not exist |
| `Fm2S2EdgerActive` · `Fm2S3EdgerActive` | **`ComponentName` carries one `EdgeSet` member and FM2 has two edgers**, so the published payload cannot tell them apart — and `G29` says no edger path exists on any line anyway |
| The ten `Dancer*` elements | **No `ComponentName` member and no field in any published payload** (`G35`, `PLC-Q18`, test `C12`). Their stated consumer is the component panel, so when a payload carries them, the list and `Reading` grow together |

**The count of excluded names is logged at boot, per line, with the reason** — a bounded read
list that reports what it dropped, not one that quietly looks complete.

### `P-123` — a configuration-bound collection gets NO C# default

**Measured, not theorised.** `IngestLines = ["FL1", "FL2"]` in code plus the same two in
`appsettings` bound to **`FL1, FL2, FL1, FL2`**: the binder **appends** to a collection that
already holds items. Four poll loops, every tag read twice a second, and the boot log said so —
*"OPC ingest started: FL1, FL2, FL1, FL2."*

**The worse half is not the doubling.** A deployer setting `["FL3"]` would get `FL1, FL2, FL3`
and **could not remove the first two**, so `{FL1,FL2}`-or-`{FL3}` — the rule that keeps FL3's
possible aliasing of FL2's namespace from double-reading every tag — would be unhonourable from
configuration.

**So the property starts empty and the default lives in `appsettings.json`**, where it can
actually be overridden, and the validator refuses an empty list by name. **Plus a dedupe guard
in the service**, because a deployer listing a line twice is the same defect by hand.

⚠ Applies to the bound **list** only. `Tags` and `LineStateMap` are dictionaries — bound by key,
so they replace rather than accumulate — and `Confirmed` is a set, where appending a duplicate is
idempotent. **`FW-144`'s options are unaffected; this was the only bound list in the surface.**

---

## 5. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes AC 4's *"integration test"* as
written. Verified instead by a **scratchpad harness** over the built assemblies and by **booting
the service with the flag flipped**; results below are measured, 28 Aug 2026.

| AC | Result |
|---|---|
| **Bounded channel, drop-oldest/coalesce** | ✅ **9 of 9 harness assertions.** A **1,524**-snapshot burst against a stalled drain stayed **bounded at 1,024**; the **oldest 500 dropped, the freshest survived** (`first survivor = 500`, `last = 1523`); `written − drained = 500`; **349.7 KB** allocated for the whole burst. **The one behaviour that matters, and it holds** |
| Hosted service reads via `OPCConnection` | ⛔ **Not executable, as `P-120` predicted.** With `SimulateOpcFeed=false` both lines log **`G60` by name** and keep trying. Recorded as the result rather than skipped — it needs `G59` (identity) and `G60` (registration), not hardware |
| Tag paths from configuration | ✅ **Zero tag-path strings in the new code.** Paths come from `ITagPathResolver`; the read list is `TagNames` constants |
| Publish interval | ✅ `1000 ms` observed at boot; the validator rejects anything outside NFR005's set, by name (`FW-144`) |
| **One POST per line per tick** | ✅ **2 POSTs a second, reading 25 tags** — `FL1: 14 of 17`, `FL2: 11 of 22`, logged at boot. Per-path polling would be ~25 requests a second |
| **FL3 is not polled** | ✅ `OPC ingest started: FL1, FL2` — after `P-123`'s fix. ⛔ **Before it: `FL1, FL2, FL1, FL2`** |
| **A failed read publishes `null`, not a stale value** | ✅ By construction — a null `Value` back leaves the field null and **no previous tick's value is carried forward**. Warned **once per path**, naming `G33` |
| **The ingest cannot take the API down** | ✅ **Measured.** 15 s of per-tick resolve failures produced **2 log lines** (one per line) and the host stayed up — health `200`, `database.reachable: true`. *(`opc.reachable: false` is pre-existing: no `OPCConnection` runs locally.)* |
| Contract unchanged | ✅ `Reading` and `IReadingChannel` are published for `FW-203` and `FW-150`. **Nothing of this story was built before it** — no `Channel<>`, no `IHostedService`, no `Reading` existed |

⚠ **`TC-620`–`TC-623` remain untestable** — the AGC sample rate, client count, latency budget and
`RunReading` retention are undefined, so the channel size and decimation ratio **cannot be
validated** and the QA2 load test **cannot fail** (`G9`/`OI-34`). The harness proves the channel
**behaves**; it cannot prove the number is **right**.

⚠ **The harness is scratchpad-only and is not in the repository** — `[TS §1.2]` withdraws automated
backend tests, and adding a test project would reverse that decision from inside a leaf story. It
is reproducible from this card: build a `ReadingChannel` over `ChannelCapacity`, write
`capacity + N` snapshots with no reader, and assert the four properties in the first row.

---

## 6. Handoff

`FW-150` drains this channel. `FW-205`'s watchdog runs over the footage tag this delivers — and
**shares `G59` with it**, since both run in a hosted service with no HTTP context. `FW-203`
stands in until commissioning. `FW-211` — unscheduled — makes the two interchangeable through
`IReadingSource`.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`G59`** *(blocker, and this story is its largest case)* | **No service identity for a hosted-service read** — `GetOPCInfo` fails before the network. `P-120` |
| ⛔ **`G60`** *(blocker)* | **Nothing registers flat wire with `OPCConnection`** — `GetOPCInfo` returns an empty list. `P-120` |
| **`PLC-Q05` / `G33`** *(blocker)* | The measure segment of **every** path is ours; **a wrong path fails silently.** ⚠ The literal `41` is struck — `FW-144` measured **72** bound (FL1 17 · FL2 22 · FL3 33), and the re-baseline is `G33`'s |
| **`G29`** *(blocker)* | **No edger tag path exists on any line** |
| **`G32` / `PLC-Q04`** *(blocker)* | FM2 station names pending sign-off |
| **`G58`** | The read-side twin: a failed read returns the tag **unchanged**, and `IsGood` is set by only one of the two managers — §2.4 row 3 is the workaround, per-tag status is `OPCConnection`'s fix |
| **`G94`** *(new, 4 Sep 2026)* | ⚠ **Off this story's path by DECISION, not by luck** — `P-118` polls `GetOPCInfo` and `ReadTag` rather than subscribing, so `OPCUAManager`'s notification defect (`:670`) cannot reach this ingest at all. ⛔ **But `ReadTag` is itself one of the five sites**: it passes the bare tag name, which resolves to namespace **0** where the subscription uses **2**. Latent only because every `OPCModules` row is `OPCDA` today — and `D-44` puts our 72 paths into that same registration. `OPCConnection`'s change, owned by `FW-236` |
| **`G31`** | Read tags with no remaining consumer. ⚠ **Mostly decidable from `[PLC]`'s own *"used in"* column, which contradicts the gap's wording** — §2.3's table settles five of six classes; **the one genuine orphan is `FL1.EdgeSet.Status.IsActive`** |
| ⛔ **`PLC-Q08` / `G30`** *(blocker for FL3 only)* | Whether FL3's stands are `FL3.FM2.*` or **`FL2.FM2.*`**. Until it answers, **FL3 is configured and inert** — and if it aliases, polling FL2 and FL3 together double-reads every FL2 tag |
| ⚠ ~~**No fault tag on any FM2 stand**~~ **WITHDRAWN 28 Aug 2026** | **Already tracked — the observation was right and it was not new.** `TagNames.Fm2S3Faulted` exists with a derived path and carries its own note: *"a fault bit is on record for FM1 ONLY. No FM2 stand has one and neither do the die blocks, so the component-fault alert cannot fire for any of them — `PLC-Q02`, `[PLC §5.4]`."* The observation was right and it was not new. **Read `PLC-Q02`'s row before citing it: it also carries the FL1 second-take-up question** |
| **`PLC-Q02`** | Whether FL1 has a second take-up. `FL1.TKUP2` is deliberately absent, which is why footage's logical name differs by line (§2.3) |
| **`G35`** | Dancer elements read-only, `[PROPOSED]` (`PLC-Q18`, commissioning test `C12`) |
| **`G9` / `OI-34`** | The channel cannot be sized from NFRs and the load test cannot fail — `P-28` gives the arithmetic's shape and a provisional default |
| **`G3`** | `RunReading` is the store the broadcast loop persists to. ✅ **Table half built 26 Aug 2026** — and its columns are a per-line snapshot, which is §2.5's evidence |
| ✅ **`OI-A`** | **CLOSED 4 Sep 2026 — `D-44`: the map moves to the `CommonDB` registration.** Contained behind `ITagPathResolver`, so there are **no caller changes and nothing here to do**. The move is `FW-238`'s and is gated on **`G93`** (`OPCTags` has no logical-name column) |

**Citations corrected 28 Aug 2026:** the `41`-path literal (→ `G33`, measured 72) and
`[SIG §5.2]` as the shared ingest contract (→ this card's §2.5).

**Re-reviewed before execution, same day, against the built `FlatWire` projects** — which is
where the `LineId` / `PayoffPosition` / `ComponentName` types, `LogicalNamesFor`,
`OpcInfoCacheSeconds`, the `RequirePositive` throw and FL3's inertness all came from. **Nothing
for this story is built yet:** no `Channel<>`, no `IHostedService`, no `Reading` type exists in
`FlatWire.Infrastructure`, so §2.5 remains the first definition and `P-29` still binds.
