# FW-N05 · OPC ingest hosted service and bounded channel

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Deferred for the trial, not cancelled** — `FW-203` stands in until commissioning
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-N05`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Two things.
>
> **This story is deferred and uncancelled, and the difference matters.** `[TRP §1.4]` calls
> deferring it *"the single highest-value deferral in this plan"* — it moves 16 h **and**
> removes the trial's only hardware dependency. But **the contract must still be built**, and
> that is the whole point: `FW-150` and `FW-151` are **unreduced for the trial** precisely so
> the real ingest drops in behind them unchanged. **Neither the simulator nor `FW-218`
> offsets this story's 32 h.**
>
> **And its design is one specific idea:** a bounded channel with **drop-oldest/coalesce**,
> so *"backpressure degrades resolution, never memory."* A slow consumer must lose
> **precision**, not the process.

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
> **Blockers:** **`PLC-Q05`** / **G33** · **G29** · **G32**

### 1.1 The trial substitution

| | |
|---|---|
| **Trial (30 Sep)** | [`FW-203`](FW-203-OPC-Feed-Simulator.md) publishes to **this story's channel, on this story's contract**, at the same cadence |
| **This story** | Deferred to the **October commissioning window**. `[DE §1]` prices it at retention **0.90** and calls it *"not verifiable without the hardware"* |
| **Not offset** | `FW-203`'s 8 h and `FW-218`'s 18 h are **additive**; this story's 32 h stands |

**The contract is the deliverable that cannot slip.** If the simulator needs a contract
change, the contract is wrong.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| Draining the channel and broadcasting | [`FW-150`](FW-150-Broadcast-Loop.md) |
| **Writing** tags | [`FW-151`](FW-151-PLCTagService.md) — this story only **reads** |
| The tag-path map's contents | `[PLC]`; bound by [`FW-144`](FW-144-Configuration-Binding.md) |
| The simulated feed | [`FW-203`](FW-203-OPC-Feed-Simulator.md) |
| The `IReadingSource` seam | `FW-211` — **unscheduled**, additive to `[CE §3b]` |

---

## 2. The design

### 2.1 The channel is the whole idea

A **bounded** `System.Threading.Channels.Channel<Reading>` with **drop-oldest / coalesce** on
overflow. It decouples the OPC poll rate from hub fan-out, which is what lets the two
cadences differ (§2.2).

- **Bounded, never unbounded.** An unbounded channel converts a slow consumer into a memory
  leak, which is the failure this criterion exists to prevent.
- **Drop-oldest / coalesce**, not block and not drop-newest. For 10 Hz telemetry the freshest
  reading is the useful one; losing an old sample costs resolution, and that is the
  acceptable trade.

> ⚠ **The channel cannot be sized.** `G9`/`OI-34` leaves the AGC sample rate, concurrent
> client count and latency budget undefined, so there is no arithmetic for the bound and
> `TC-620`–`TC-623` are untestable. **Pick a value, record it, and say it is provisional** —
> see `P-28`.

### 2.2 Two cadences, and this is the upstream one

| Knob | Value | Whose |
|---|---|---|
| **OPC publish interval** | `NFR005`: **1 s default**, configurable 5 / 10 / 30 s — `[PLCC]`'s `PublishIntervalMs` | **this story** |
| Hub drain cadence | ~100 ms / 10 Hz | [`FW-150`](FW-150-Broadcast-Loop.md) |

They sit on opposite sides of the channel. **Never derive one from the other**
([`FW-144 §2.1`](FW-144-Configuration-Binding.md)).

### 2.3 What to subscribe to is an open decision

`phase-01b` L106: **`G31`** publishes several read rows as
`[NO REMAINING CONSUMER — confirm before subscribing]`, and `G35`'s dancer elements are
read-only `[PROPOSED]`. **The ingest subscription list *is* that decision** — do not
subscribe to everything the map contains on the assumption that reading is free.

---

## 3. Build order

1. `IHostedService` in `FlatWire.Infrastructure`, reading FL1/FL2/FL3 through the existing
   **`OPCConnection`** domain (`[ARC §2.2]`: the tag layer to integrate with).
2. The bounded channel, drop-oldest/coalesce, size from configuration (`P-28`).
3. Tag paths from configuration — **never from code**, so a wrong path found at
   commissioning is a config edit, not a redeploy.
4. Publish interval from configuration, default 1 s.
5. Subscribe only to tags with a confirmed consumer (§2.3).
6. Resilience: **Polly** on the outbound OPC call, shared with
   [`FW-151`](FW-151-PLCTagService.md)'s policy.
7. **Publish nothing the contract does not already carry** — the interface `FW-203` and this
   story share is `[SIG §5.2]`'s, and neither may widen it.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-27` precede this story.

### `P-28` — size the channel by configuration and record the number as provisional

`G9`/`OI-34` means there is no defensible arithmetic for the bound: without an AGC sample
rate and a latency budget, any figure is a guess.

**So make it a configured value with a stated default, not a constant** — a guess in
`appsettings` is revisable at commissioning; a guess in a `const int` is a code change.
Record the chosen default and the reasoning in the configuration comment, and state plainly
that it is provisional pending `G9`.

**Do not let the absence of NFRs become a reason to leave it unbounded.** Bounded-with-a-
guessed-size degrades gracefully; unbounded fails as a memory leak under exactly the load
nobody has specified.

### `P-29` — the contract is frozen before the simulator uses it

`FW-203` publishes to this channel and `FW-150` drains it, both **before** this story is
built. So the `Reading` type, the channel's shape and the publish semantics are fixed by the
trial and must not change when the real ingest arrives — that is the entire justification for
`FW-150` and `FW-151` being unreduced.

**Practical consequence: define `Reading` and the channel here and now, even though the
hosted service is deferred.** A deferred story whose *contract* is also deferred cannot be
stood in for.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes AC 4's *"integration test"*
as written. The behaviour it described is verified by observation in the QA0 walkthrough.

| AC | How it is checked |
|---|---|
| Hosted service reads FL1/FL2/FL3 via `OPCConnection` | Observed against a controller, or against `FW-203` before one exists |
| **Bounded channel, drop-oldest/coalesce** | Drive a burst faster than the drain rate — **memory flat, resolution degraded**. The one behaviour that matters |
| Tag paths from configuration | `grep` the solution for a tag path string → **zero hits outside configuration** |
| Publish interval | 1 s default; 5/10/30 s configurable without a rebuild |
| Contract unchanged | `FW-150` drains this channel with no code change when the real ingest replaces the simulator |

⚠ **`TC-620`–`TC-623` are untestable** — the AGC sample rate, client count, latency budget
and `RunReading` retention are undefined, so the channel size and decimation ratio **cannot
be validated** and the QA2 load test **cannot fail** (`G9`/`OI-34`).

---

## 6. Handoff

`FW-150` drains this channel. `FW-205`'s watchdog runs over the footage tag this delivers.
`FW-203` stands in until commissioning. `FW-211` — unscheduled — makes the two
interchangeable through `IReadingSource`.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`PLC-Q05` / `G33`** *(blocker)* | The measure segment of all 41 paths is ours; **a wrong path fails silently** |
| **`G29`** *(blocker)* | **No edger tag path exists on any line** |
| **`G32` / `PLC-Q04`** *(blocker)* | FM2 station names pending sign-off |
| **`G31`** | Read tags with no remaining consumer — **the subscription list is this decision** |
| **`G35`** | Dancer elements read-only, `[PROPOSED]` |
| **`G9` / `OI-34`** | The channel cannot be sized and the load test cannot fail — `P-28` |
| **`G3`** | `RunReading` is the store the broadcast loop persists to |

No stale citations in this card.
