---
id: FW-N05
legacy_id:
title: OPC ingest hosted service and bounded channel
status: blocked
status_confirmed: true
status_note: "⚠ **Deferred for the trial, not cancelled** — `FW-203` stands in until commissioning. ⛔ **`not-started` was WRONG and is corrected 6 Sep 2026** — the defect [`CHANGELOG.md`](../../CHANGELOG.md) raised on 31 Aug against **1,030 implemented lines** and left unfixed. The contract and the hosted service are BUILT and harness-verified (9/9); the service is **registered off** and cannot complete a single read until **`G59`** gives it an identity. That is `blocked`, not unstarted"
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
blocked_by: [G59, G60, G29, G32, G33, PLC-Q05]
has_plan: true
started:
completed:
---
# FW-N05 · OPC ingest hosted service and bounded channel

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 6, 2026 (executed) — ⭐ **THE TWO THINGS THIS CARD COULD STILL DO WERE DONE, AND ONE OF THEM FALSIFIED A `✅` IT ALREADY CARRIED.** ✅ **The channel harness is in the repository at last** — `ReadingChannelTests`, 6 tests replaying the 28 Aug burst (1,524 → bounded at 1,024, oldest 500 dropped, freshest survived, `written − drained = 500`), **suite 279 passing / 0 failed** (was 273), **no production file changed**. ⭐ **Mutation-checked, not merely green**: `DropOldest` → `DropWrite` fails exactly one test, the freshest-survive one — the regression that bounds memory identically and would silently freeze the panel on stale readings. ✅ **The owed boot re-run was performed against the LIVE registration** and failed exactly where `P-120` said it would: the `OpcModuleId` guard no longer fires, the resolve reaches `GetOPCInfo`, and **`G59` throws first** — `NullReferenceException at GetTokenAsync ← RestClient.SetHeadersAsync`, named by the ingest, once per line. Health **`200`**, `database.reachable: true`, host up throughout — **a blocked ingest degrades the service and does not stop it.** ✅ **The registration was verified independently in `CommonDB`**: module **6** `FlatWire`, `ct=21317`, **41** mappings (machine 125 → 18, 126 → 23), 2 system-error rows — and **`OPCTags` has no `TagKey` column**, confirming `D-45` against the database rather than the register. ⛔ **NEW GAP `G102`**: with `G59` open the ingest logs **a full stack trace twice a second** — 78 stack traces + 156 `RestClient` INFO lines in 40 s against **2** from its own guard, ≈500,000 a day. **The guard works and the ingest is not at fault** — `RestClient` logs beneath it — and it reads as new **only because `G60` closed**, so §5's *"2 log lines"* was true when written and is falsified by its own re-run. ⚠ **`G59` remains the sole blocker; nothing here unblocks the story.** *(previously September 6, 2026 — ⚠ **RECONCILED AGAINST `D-45`–`D-51`. The build is untouched and every measured number in this card still holds; what moved is the ground under two of its sections.** ⛔ **The one correction that would have caused damage: §2.3's *"the map has moved to `CommonDB`, so zero tag paths in any file"* is WRONG and is struck.** `D-45` (5 Sep) withdrew `G93` without building it — there is **no `TagKey` column**, no `CommonDbTagPathResolver`, and `appsettings` **keeps** all 72 paths behind the unchanged `ITagPathResolver` while `OPCTags` registers them too, deliberately, reconciled by a config-vs-rows diff. The check reverts to **zero tag-path strings in *code***, which is what this card was built to and passed. ✅ **`G60` IS HALF CLOSED — `11_` ran and committed on `DEV00164-001`, 6 Sep 2026**: module **6** at `ConnectionType` **21317**, 4 endpoint mappings, 41 `OPCTags`, 41 mappings — so §2.4's *"none of the eight `30-database/scripts/` files touches `OPCModules`"* is stale, and `OpcModuleId` is now **`6` in `appsettings`**, which retires the exact boot message §5 recorded as this card's `G60` evidence. ⛔ **`G59` is now the sole *design* blocker left, and it is unmoved.** ⭐ **`PLC-Q08` IS ANSWERED — `D-47`: FL3 has no controller of its own, so this card's `{FL1,FL2}`-or-`{FL3}` rule is RETIRED, not pending.** FL3 is not registered, has no `MachineId`, and its 33 configured paths still lack the `PLC` element `D-46` added to FL1's and FL2's — **FL3 can never simply be added to `IngestLines`**, and the two-controller push that replaces the rule is `G99`, on the write path. ✅ **`G94` no longer touches this ingest — `D-51`, 6 Sep**: flat wire deploys from `feature/UADEV-23146`, where `ReadTag` calls `GetOpcUaTagName()`. ⚠ **But `ConnectionType 21317` makes flat wire the first module on `OPCUAManager`** — the manager that never sets `IsGood` — so §2.4 row 3's *"do not gate on `IsGood`"* is no longer a precaution against an unknown, it is the only available behaviour. ✅ **`D-50` reversed the no-backend-tests rule for the unit level and `FlatWire.UnitTests` now exists in `FlatWire.sln`**, so §5's stated reason for leaving the channel harness uncommitted is spent — **no card owns it yet**. ⚠ **Two `ual-api` comment blocks still teach the retired FL3 rule** (§7). *(previously August 28, 2026 — ✅ **EXECUTED, AND VERIFIED BY HARNESS AND BY BOOT. The contract is built and the hosted service is built, registered off, and blocked exactly where `P-120` said it would be.** Built in `ual-api`: **`Reading`** (`FlatWire.Domain/Models/RealTime/Reading.cs`), **`IReadingChannel`** + **`ReadingChannel`** (bounded, `DropOldest`, `SingleReader`, `SingleWriter = false`), **`OpcIngestService`** (`FlatWire.Infrastructure`), three new options (`SimulateOpcFeed`, `ChannelCapacity`, `IngestLines`) with validation, and the registration seam `AddFlatWireOpcIngest`. **0 errors, 13 warnings on a clean rebuild — 5 code warnings, all pre-existing, none in these files.** ✅ **The headline behaviour is verified: 9 of 9 harness assertions pass.** A 1,524-snapshot burst against a stalled drain stayed **bounded at 1,024**, the **oldest 500 were dropped and the freshest survived**, `written − drained = 500` made the resolution loss observable, and the whole burst allocated **349.7 KB** — ~235 bytes a snapshot, so `P-28`'s 1024 default costs ~240 KB. ⛔ **EXECUTION FOUND A DEFECT THE REVIEW DID NOT: the configuration binder APPENDS to a collection that already holds C# defaults.** `IngestLines = ["FL1","FL2"]` in code plus the same two in `appsettings` bound to **`FL1, FL2, FL1, FL2`** — four poll loops reading every tag **twice a second**, which the boot log printed as *"OPC ingest started: FL1, FL2, FL1, FL2"*. Worse than the doubling: a deployer setting `["FL3"]` would get `FL1, FL2, FL3` and **could not remove the first two**, making this card's `{FL1,FL2}`-or-`{FL3}` rule impossible to honour. **Fixed by removing the C# default** (`P-123`) — the default lives in `appsettings.json`, where it can be overridden — **plus a dedupe guard** in the service, since a deployer listing a line twice is the same bug by hand. ✅ **Re-booted: `FL1, FL2` once each.** ✅ **`G59`/`G60` reproduced by boot, by name:** with the flag flipped, both lines log *"cannot resolve … `FlatWireOpc:OpcModuleId` is not configured (gap G60 …)"* — **once per line, twice in 15 seconds of ticking**, and the host **stayed up** (health `200`, `database.reachable: true`). That last property is the one that matters: a deferred, blocked ingest does not take the API down. ⚠ **Two of this card's own numbers are corrected by the build: the read list is 14 of FL1's 17 paths and 11 of FL2's 22 — 25 tag reads in 2 POSTs a second**, not the ~37 this card estimated, because the dancers, the two edger keys and the write-only interlock have nowhere to land (`P-122`). ⚠ **And one is now stale: `Polly` IS in `FlatWire.Infrastructure`'s package set** — `FW-151` added it on 28 Aug. What was missing instead was **`Microsoft.Extensions.Hosting.Abstractions`**, which AC 1's placement requires and which was **not** centrally pinned; added at **8.0.1** to match the net8.0 shared framework (`P-121`). ⚠ **One review finding withdrawn:** the *"no fault tag on any FM2 stand"* item is **already tracked** — `TagNames.Fm2S3Faulted` carries a derived path and its own note citing `PLC-Q02` / `[PLC §5.4]`. It was not a new gap.)*)* Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
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
and it is the seam `OI-A` was contained behind.

> ⛔ **STRUCK 6 Sep 2026 — this paragraph said the map had moved out of `appsettings`, and it has
> not.** It read: *"✅ The map has now moved — `D-44`, 4 Sep 2026: it is the `CommonDB` `OPCTags`
> registration … only the implementation behind it becomes a `CommonDbTagPathResolver` (`FW-238`,
> gated on `G93`). ⚠ One check tightens — zero hits outside configuration becomes **zero hits in any
> file**, since no file holds a path at all."* **`D-45` (5 Sep) withdrew `G93` without building it.**
> There is no `TagKey` column, so `OPCTags` cannot be addressed by meaning and **`ConfigurationTagPathResolver`
> stays** — `appsettings` resolves *and* `OPCTags` registers, both deliberately, kept in step by a
> config-vs-rows diff (`FW-238`). ⚠ **Acting on the struck text would have been destructive**: it
> licenses deleting the 72 paths this service resolves from. **The check is `zero tag-path strings in
> CODE`** — what §5 measured and what this build passes — not *zero in any file*. ✅ **Nothing in the
> built service changes either way**; that is what the seam bought.

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
`FlatWireOpcOptions.Lines` says so in as many words, and the reason **used to be** the open
`PLC-Q08` / `G30`.

✅ **`PLC-Q08` IS ANSWERED — `D-47`, 5 Sep 2026, and the answer makes FL3's exclusion permanent
rather than provisional.** FL3 has **no controller of its own**: FM1 and the die blocks belong to
the FL1 controller, FM2 to the FL2 controller, and **there is no `FL3.PLC.*` namespace on any
machine**. So FL3's tags *are* FL1's and FL2's, already polled.

⛔ **The `{FL1, FL2}` *or* `{FL3}` rule is therefore RETIRED — do not implement it, and do not wait
for it.** Three measured facts close it (6 Sep 2026): FL3 is **not registered** (`11_` seeds
machines 125 and 126 and `GetOPCServerAndTagDetails` correctly returns nothing for 127); FL3 has
**no `MachineId`** in `appsettings`, so naming it in `IngestLines` fails the resolve **by name**;
and FL3's 33 configured paths still read `FL3.AGC.Gauge`, **without the `PLC` element `D-46` added
to FL1's and FL2's** — they address nothing. **`IngestLines` is `{FL1, FL2}`, full stop.**

⚠ **What replaces the rule is a WRITE-path problem, not this card's** — `G99`: one FL3
acknowledgement must now push to **two** controllers, in two `WriteTag` batches, with a re-clear
spanning two failure domains. **The ingest is unaffected**, because reading FL1 and FL2 already
reads every tag FL3 has.

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
| 3 | ⛔ **A failed read is indistinguishable from a good one.** Both managers return the tag **unchanged** on a null read or an `OpcException`; `OPCUAManager.ReadTag` logs at `LogInformation` and **never sets `IsGood`**, while `OPCDAManager.ReadTag` does — and `ConnectionType` decides which one runs (`G58`'s read-side twin). ⛔ **DECIDED 6 Sep 2026, and against us: `11_` registers flat wire at `ConnectionType` 21317, so this is the FIRST module to run on `OPCUAManager`** — the manager that never sets it | **Send `Value = null` and treat a null return as *no reading*** (`FW-151` `P-105`'s sentinel, natural on a read path). **Do not gate on `IsGood`** — it is now not merely unreliable but **never set on our path**, so a reviewer asking for the `IsGood` check is asking for a field that is always `false`. Publish `null`, and **never carry the previous tick's value forward** |
| 4 | ⛔ **`RestClient` reports transport faults in-band** — it catches everything and returns `Result.Fail`; a connectivity failure inside the handler throws and surfaces the same way | Branch on **`Result.IsFailure`**, not on an exception (`FW-151` `P-109`). Polly retries on the result |

⛔ **And two blockers that stop the first line of it — `P-120`.**

- **`G59` — there is no identity.** `RestClient.SetHeadersAsync` reads the token from
  `context.HttpContext`; a hosted service has none, so it dereferences null and **`GetOPCInfo`
  fails before the network**, with a message naming neither the identity nor the caller.
  `ReadTagQueryValidator` independently requires a **non-empty `AccessToken`** and
  `MachineId > 0`, and both routes sit behind the global `AuthorizeFilter`. **The register names
  `SetITInhibit` and hold/restore; this story is the third and largest case.**
- ✅ **`G60` — HALF CLOSED 6 Sep 2026. The registration now exists.** As written this bullet said
  *"`OPCModules` has five members and no flat wire one, and none of the eight
  `30-database/scripts/` files touches `OPCModules` / `OPCServers` / `OPCTags` /
  `OPCTagApplicationMapping`"* — **both halves are now stale.**
  [`11_CommonDB_Insert_OPCRegistration_FlatWire.sql`](../../30-database/scripts/11_CommonDB_Insert_OPCRegistration_FlatWire.sql)
  ran and committed on `DEV00164-001`: module **6** (not the enum's apparently-free `5`, which the
  slitters hold — `G96`), `ConnectionType` **21317**, **4** endpoint mappings, **41** `OPCTags`
  (39 data + 2 system-error rows, `G95`) and 41 tag mappings. `OpcModuleId` is **`6` in
  `appsettings`**. ⚠ **Do not reconcile 41 against `FW-144`'s 72** — 41 excludes FL3 (`D-47`) and
  counts registered rows; 72 counts bound paths. Both are right.
  ⛔ **Not retired, and the remainder is what bites here:** `GetOPCInfo` has **never been exercised
  through the running service** (`FW-238` §3 step 9 — and this card's own boot is one of the two
  proofs owed), and **nothing is registered on `test1`, staging or production.**

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

0. ⛔ **Identity first** (`P-120`) — without it nothing after step 1 can be executed even once.
   ✅ **`G60`'s half is DONE on `DEV00164-001`** (`11_`, 6 Sep 2026 — §2.4), so the registration
   script no longer has to be written; what remains of it is **running `11_` on every other
   environment** and proving `GetOPCInfo` through the running service. ⛔ **`G59` is untouched and
   is now the only thing standing between this service and its first successful read**: it decides
   how a hosted service authenticates (the `CoolingChamber` badge-login precedent, or a token held
   for the run's duration). **Still not this story's to decide alone — raise it now, not in the
   40 h Phase-14 window.**
1. `IHostedService` in `FlatWire.Infrastructure`, reading through the existing
   **`OPCConnection`** domain (`[ARC §2.2]`: the tag layer to integrate with) — `GetOPCInfo`
   **once** at start-up, cached (§2.4 row 2). ⚠ The AC says *"FL1/FL2/FL3"*; **build for three
   and poll two** — FL3 is configured and inert (step 2), exactly as `FlatWireOpcOptions.Lines`
   already is.
2. **One `PeriodicTimer` loop per polled line — FL1 and FL2 only** (§2.3: FL3 is configured and
   inert **permanently** — `PLC-Q08` is answered by `D-47`, not pending), `await`ing its read inside the loop, so a slow OPC read
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

> ✅ **Half discharged 6 Sep 2026, and the decision was right to force it.** `G60` was raised on
> 28 Aug because this plan insisted on it; `FW-238` owned it, and `11_` ran on `DEV00164-001` on
> 6 Sep — **outside** the Phase-14 window, which is exactly what `P-120` was for. It surfaced four
> things a commissioning session would otherwise have paid for: `G95` (no system-error row ⇒ the
> whole line is invisible, a symptom **identical** to no registration), `G96` (the enum's free-looking
> `5` is in production), `G97` (no UA endpoint) and `G100` (column drift). ⛔ **`G59` is NOT
> discharged and is now the whole of step 0.**

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
and **could not remove the first two** — a configuration key that cannot express the operator's
intent is broken whatever that intent turns out to be.

⚠ **Amended 6 Sep 2026 — the decision stands, its second example does not.** This paragraph
originally justified the *"could not remove the first two"* half by the `{FL1,FL2}`-or-`{FL3}`
rule, and **`D-47` retired that rule** (§2.3): FL3 has no controller, so it is never polled under
any answer. ✅ **The defect and the fix are unchanged and were measured** — a bound list that
silently appends to a C# default is wrong on its own terms, and `IngestLines` is the one bound
list in the surface.

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
| **Bounded channel, drop-oldest/coalesce** | ✅ **9 of 9 harness assertions.** A **1,524**-snapshot burst against a stalled drain stayed **bounded at 1,024**; the **oldest 500 dropped, the freshest survived** (`first survivor = 500`, `last = 1523`); `written − drained = 500`; **349.7 KB** allocated for the whole burst. **The one behaviour that matters, and it holds.** ⭐ **AND IT IS NOW IN THE REPOSITORY — `ReadingChannelTests`, 6 replayable tests, committed 6 Sep 2026.** Same burst, same four properties, in `FlatWire.UnitTests/Infrastructure/Services/`. ✅ **Mutation-checked, so it is not a test that only passes:** flipping the production `DropOldest` to `DropWrite` **fails `The_oldest_are_dropped_and_the_freshest_survive` and nothing else** — which is the point, because `DropWrite` bounds memory identically and would silently freeze the panel on stale readings instead. Suite **279 passing, 0 failed** (was 273); `ReadingChannel.cs` byte-identical after the mutation was reverted |
| Hosted service reads via `OPCConnection` | ✅ **RE-RUN DONE 6 Sep 2026, and it failed where this card predicted it would.** With `SimulateOpcFeed=false` against the live registration, the `OpcModuleId` guard **no longer fires** and the resolve reaches `GetOPCInfo`, where **`G59` throws first** — `NullReferenceException at AuthenticationHttpContextExtensions.GetTokenAsync ← RestClient.SetHeadersAsync`, and the ingest names the gap: *"…this is gap G59 — RestClient takes its bearer token from the current HttpContext and a hosted service has none."* **Once per line, exactly as designed.** ⛔ **Still not executable, and `G59` is now demonstrably the only thing in the way** — `P-120` predicted this in order. *(Superseded evidence, 28 Aug: both lines logged `G60` by name at the configuration guard, before any HTTP call.)* |
| Tag paths from configuration | ✅ **Zero tag-path strings in the new code.** Paths come from `ITagPathResolver`; the read list is `TagNames` constants. ⚠ **This is the correct check and it survives `D-45`** — §2.3's struck *"zero in any file"* would have failed it, since `appsettings` holds all 72 by design |
| Publish interval | ✅ `1000 ms` observed at boot; the validator rejects anything outside NFR005's set, by name (`FW-144`) |
| **One POST per line per tick** | ✅ **2 POSTs a second, reading 25 tags** — `FL1: 14 of 17`, `FL2: 11 of 22`, logged at boot. Per-path polling would be ~25 requests a second |
| **FL3 is not polled** | ✅ `OPC ingest started: FL1, FL2` — after `P-123`'s fix. ⛔ **Before it: `FL1, FL2, FL1, FL2`** |
| **A failed read publishes `null`, not a stale value** | ✅ By construction — a null `Value` back leaves the field null and **no previous tick's value is carried forward**. Warned **once per path**, naming `G33` |
| **The ingest cannot take the API down** | ✅ **Re-measured 6 Sep 2026 against the live registration and it still holds — the property that matters is intact.** 40 s of per-tick resolve failures, host alive throughout, health **`200`**, `{"status":"Degraded","database":{"reachable":true,"latencyMs":521},"opc":{"reachable":false}}`. **A deferred, blocked ingest degrades the service; it does not stop it.** ⛔ **But the *"2 log lines"* half of this row is FALSIFIED by the same re-run, and it is now `G102`.** Measured in that window: **78** `NullReferenceException` stack traces and **156** `RestClient` INFO lines against **2** from the ingest's own guard — ≈**6 lines a second**, ~500,000 a day. ⚠ **The guard is not broken and the ingest is not at fault**: `RestClient` logs the caught exception with a stack trace on every attempt, beneath us. **It reads as new only because `G60` closed** — the old evidence stopped at the configuration guard and never reached `RestClient` |
| Contract unchanged | ✅ `Reading` and `IReadingChannel` are published for `FW-203` and `FW-150`. **Nothing of this story was built before it** — no `Channel<>`, no `IHostedService`, no `Reading` existed |

⚠ **`TC-620`–`TC-623` remain untestable** — the AGC sample rate, client count, latency budget and
`RunReading` retention are undefined, so the channel size and decimation ratio **cannot be
validated** and the QA2 load test **cannot fail** (`G9`/`OI-34`). The harness proves the channel
**behaves**; it cannot prove the number is **right**.

⚠ **The harness is scratchpad-only and is not in the repository** — `[TS §1.2]` withdraws automated
backend tests, and adding a test project would reverse that decision from inside a leaf story. It
is reproducible from this card: build a `ReadingChannel` over `ChannelCapacity`, write
`capacity + N` snapshots with no reader, and assert the four properties in the first row.

⚠ **Superseded 5 Sep 2026 — `D-50`, `[TS §1.2]`.** The decision this paragraph declined to reverse
*"from inside a leaf story"* **has now been reversed in the strategy**, and `FW-263` creates the test
project. ✅ **The reasoning above stays correct** — it was not this card's to take, and that is
exactly why the reversal was taken in `[TS]` and `[SP §9.2]` instead. ⚠ **This card's channel harness
is NOT in `FW-263`–`FW-267`'s scope as minted** — the four layers are the domain, `PLCTagService`'s
simulate branch, the line models and simulators, and the reachable DbContext-backed services. The
harness described here remains the verification of record until a card exists for it.

⭐ **And the obstacle is now gone — measured 6 Sep 2026: `FlatWire.UnitTests` EXISTS and is in
`FlatWire.sln`.** Both reasons this harness stayed in a scratchpad have expired: the strategy
reinstated the unit level (`D-50`), and there is no longer a test project to create. ✅ **The channel
is the cheapest possible unit test and the highest-value one on this card** — `ReadingChannel` is
pure in-memory, needs **no hardware, no `G59` identity, no registration and no database**, and it is
the *only* acceptance criterion this story can prove today. **Write `capacity + N` snapshots with no
reader; assert bounded-at-capacity, oldest-dropped, freshest-survived, and `written − drained = N`**
— four asserts, one file, no fixture.

✅ **DONE 6 Sep 2026 — the harness is no longer scratchpad-only.**
`FlatWire.UnitTests/Infrastructure/Services/ReadingChannelTests.cs` carries the four properties plus
the configured capacity and the argument guards: **6 tests, suite 279 passing / 0 failed**, up from
273. **No production file changed** — the seam needed nothing, which is what `P-119`'s
*"no lock anywhere"* design bought. ⭐ **It was mutation-checked rather than merely run green**:
`DropOldest` → `DropWrite` fails exactly one test, the freshest-survive one. That is the assertion
worth having, because `DropWrite` bounds memory identically and passes every other check while
silently keeping the **oldest** 1,024 readings — a frozen panel rather than a lost sample.
⚠ **`G101`'s indictment applies to this card no longer**: this verification is now *a property of
the repository*, not *a claim about a build*. ⚠ **The other proofs stay manual** — the integration
and contract levels remain withdrawn, so `GetOPCInfo` and the boot above are still hand-run.

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
| ⛔ **`G59`** *(blocker, and this story is its largest case)* | **No service identity for a hosted-service read** — `GetOPCInfo` fails before the network. `P-120`. ✅ **Reproduced on the running service 6 Sep 2026 against the LIVE registration** (§5): with `G60`'s configuration half closed, this is now the **only** thing between the ingest and its first read |
| ⛔ **`G102`** *(new, 6 Sep 2026 — raised by executing this card)* | **While `G59` is open the ingest logs a full stack trace twice a second** — 78 stack traces + 156 `RestClient` INFO lines in a measured 40 s window against **2** from the ingest's own guard, ≈500,000 a day. ⚠ **The guard works and the ingest is not at fault**; `RestClient` logs the caught exception on every attempt beneath it. **New only because `G60` closed** — the old evidence stopped at the configuration guard and never reached `RestClient`. **The fix is small and is this service's**: back off a line's resolve once it has failed, since a null-reference identity failure cannot succeed on the next tick |
| ⚠ **`G60`** *(HALF CLOSED 6 Sep 2026)* | ✅ **The registration is live on `DEV00164-001`** — `11_` committed module **6** at `ConnectionType` **21317**, 4 endpoint mappings, 41 `OPCTags`, 41 mappings, and `OpcModuleId` is `6` in `appsettings` (§2.4). ⛔ **Two halves left, and the first is this card's:** `GetOPCInfo` has never been exercised **through the running service** (`FW-238` §3 step 9 — a re-boot of this ingest is one of the two proofs owed, §5), and **`test1`, staging and production have nothing registered** |
| **`PLC-Q05` / `G33`** *(blocker)* | The measure segment of **every** path is ours; **a wrong path fails silently.** ⚠ The literal `41` is struck — `FW-144` measured **72** bound (FL1 17 · FL2 22 · FL3 33), and the re-baseline is `G33`'s |
| **`G29`** *(blocker)* | **No edger tag path exists on any line** |
| **`G32` / `PLC-Q04`** *(blocker)* | FM2 station names pending sign-off |
| **`G58`** | The read-side twin: a failed read returns the tag **unchanged**, and `IsGood` is set by only one of the two managers — §2.4 row 3 is the workaround, per-tag status is `OPCConnection`'s fix |
| ✅ **`G94`** *(no longer reaches this ingest — `D-51`, 6 Sep 2026)* | ⚠ **Off this story's path by DECISION, not by luck** — `P-118` polls `GetOPCInfo` and `ReadTag` rather than subscribing, so `OPCUAManager`'s notification defect (`:670`) cannot reach this ingest at all. ✅ **And `ReadTag`'s own half is fixed on the branch that matters:** flat wire deploys from `feature/UADEV-23146`, where `ReadTag` (`:214`) and `WriteTag` (`:381`) both call `GetOpcUaTagName()`. `G94` stays open **as a statement about `release/mvp-3.x`**, which does not contain `API/Domain/FlatWire` at all — ⚠ **re-ask per environment**, against the branch that environment's `OPCConnection` is built from. ⛔ **Two claims in this row's original text are struck:** *"every `OPCModules` row is `OPCDA` today"* — **flat wire's own row is `21317`, i.e. UA**, and it is the first (§2.4 row 3) — and *"`D-44` puts our 72 paths into that registration"*, which is **41 rows** and no longer via `D-44`'s mechanism (`D-45`) |
| **`G31`** | Read tags with no remaining consumer. ⚠ **Mostly decidable from `[PLC]`'s own *"used in"* column, which contradicts the gap's wording** — §2.3's table settles five of six classes; **the one genuine orphan is `FL1.EdgeSet.Status.IsActive`** |
| ✅ **`PLC-Q08` / `G30`** *(ANSWERED — `D-47`, 5 Sep 2026; **no longer a blocker on this card**)* | **FL3 has no controller of its own.** FM1 and the die blocks are the FL1 controller's, FM2 the FL2 controller's, and there is **no `FL3.PLC.*` namespace on any machine** — so FL3 is not registered, has no `MachineId`, and reading FL1 and FL2 already reads every tag it has. ⛔ **This card's `{FL1,FL2}`-or-`{FL3}` rule is RETIRED, not pending** (§2.3, `P-123`) |
| ⛔ **`G99`** *(new, 5 Sep 2026 — replaces `G30` here, and it is NOT this card's)* | The consequence of `D-47`: one FL3 acknowledgement must **write to two controllers**, in two `WriteTag` batches, with a re-clear spanning two failure domains and **both** lines' `ITInhibit` set. ✅ **The ingest is untouched** — `G99` is entirely on the write path (`FW-151` / `[PLC §7.1]`, `[PLC §7.5]`) |
| ⚠ ~~**No fault tag on any FM2 stand**~~ **WITHDRAWN 28 Aug 2026** | **Already tracked — the observation was right and it was not new.** `TagNames.Fm2S3Faulted` exists with a derived path and carries its own note: *"a fault bit is on record for FM1 ONLY. No FM2 stand has one and neither do the die blocks, so the component-fault alert cannot fire for any of them — `PLC-Q02`, `[PLC §5.4]`."* The observation was right and it was not new. **Read `PLC-Q02`'s row before citing it: it also carries the FL1 second-take-up question** |
| **`PLC-Q02`** | Whether FL1 has a second take-up. `FL1.TKUP2` is deliberately absent, which is why footage's logical name differs by line (§2.3) |
| **`G35`** | Dancer elements read-only, `[PROPOSED]` (`PLC-Q18`, commissioning test `C12`) |
| **`G9` / `OI-34`** | The channel cannot be sized from NFRs and the load test cannot fail — `P-28` gives the arithmetic's shape and a provisional default |
| **`G3`** | `RunReading` is the store the broadcast loop persists to. ✅ **Table half built 26 Aug 2026** — and its columns are a per-line snapshot, which is §2.5's evidence |
| ✅ **`OI-A`** | **CLOSED — but NOT as `D-44` first framed it, and the difference matters here.** `D-45` (5 Sep 2026) **withdrew `G93` without building it**: there is no `TagKey` column, so `OPCTags` cannot be keyed by meaning and **`ConfigurationTagPathResolver` stays**. `appsettings` resolves **and** `OPCTags` registers — two homes on purpose, reconciled by `FW-238`'s config-vs-rows diff. ✅ **Still nothing here to do**: contained behind `ITagPathResolver`, no caller changes, and the `CommonDbTagPathResolver` this row used to promise **is not being built** (§2.3) |
| ⚠ **`ual-api` comment drift** *(found 6 Sep 2026 — comments only, no behaviour)* | **Two built comment blocks still teach the retired FL3 rule**: `FlatWireOpcOptions.IngestLines`'s remarks and `appsettings.json`'s `_comment` both say *"pending `PLC-Q08` / `G30` … when it answers the rule is {FL1,FL2} OR {FL3}"*. ✅ **The code is correct** — `IngestLines` is `["FL1","FL2"]` and FL3 fails the resolve by name — so this is a **doc fix, not a defect**, deliberately left for whoever next opens those files rather than taken from a planning card |

**Citations corrected 28 Aug 2026:** the `41`-path literal (→ `G33`, measured 72) and
`[SIG §5.2]` as the shared ingest contract (→ this card's §2.5).

**Reconciled 6 Sep 2026 against `D-45`–`D-51`, the live `CommonDB` registration and the built
`FlatWire` projects.** ✅ **Nothing measured on 28 Aug moved**: the 9/9 harness assertions, the
1,024 bound, the 349.7 KB, the `8.0.1` pin and the **14 of 17 / 11 of 22 = 25 tag reads** were all
re-verified from `appsettings` and `IngestedNames` and are unchanged. ⛔ **What moved was around
the card** — `G93` withdrawn, `G60` half closed, `PLC-Q08` answered, `G94` re-scoped, the unit-test
level reinstated — **and one of those had turned a ✅ in §2.3 into instructions that would have
deleted this service's tag map.**

**Re-reviewed before execution, 28 Aug 2026, against the built `FlatWire` projects** — which is
where the `LineId` / `PayoffPosition` / `ComponentName` types, `LogicalNamesFor`,
`OpcInfoCacheSeconds`, the `RequirePositive` throw and FL3's inertness all came from. **Nothing
for this story is built yet:** no `Channel<>`, no `IHostedService`, no `Reading` type exists in
`FlatWire.Infrastructure`, so §2.5 remains the first definition and `P-29` still binds.
