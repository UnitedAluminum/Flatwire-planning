# FW-150 · Cadence-driven broadcast loop

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **unreduced for the trial, deliberately**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-150`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** The loop looks like "drain a channel every 100 ms and send".
> Four rules make it not that, and each has a named consequence:
>
> **`PayoffStateChanged` must never enter the batch** — *"a bay changing hands is an
> operator-visible state transition, not a sampled reading."* Batching it puts up to 100 ms
> of lag on the pre-check-in screen's most important signal.
> **FL2 suppresses batched gauge and width only** — speed, footage, component and line status
> **still flow**. A loop that silences FL2 wholesale leaves both FL2 trial screens dead.
> **`ITInhibit` gates persistence, not broadcast.**
> And this story is **not reduced for the trial**, because the real ingest has to drop in
> behind it unchanged.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-150 · Cadence-driven broadcast loop
> **Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> **As an** operator,
> **I want** telemetry batched at a fixed cadence and rare events sent immediately,
> **So that** the panel stays responsive under a full three-line load.
>
> **Acceptance Criteria:**
> - [ ] Drains the channel on a **fixed cadence (default ~100 ms / 10 Hz)**, sending **batched arrays** per line group
> - [ ] Hot numeric channels decimated to cadence; `ComponentStatus` / `LineStatus` sent **on change only**
> - [ ] **Rare domain events sent immediately and unbatched** — they must not enter the 10 Hz batch
> - [ ] **FL2 standalone suppresses batched gauge/width** and broadcasts `null`; the historical profile is a REST query
> - [ ] Cadence is configuration-driven (FW-144)
>
> **Rate-card basis:** 2 × hub event group @ 8 h = 16 h (§2)
> **Dependencies:** FW-N05, FW-149
> **Blockers:** **G9 / OI-34** (AGC sample rate undefined)

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The channel being drained | [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md) / [`FW-203`](FW-203-OPC-Feed-Simulator.md) |
| The hub, groups and transport | [`FW-080`](FW-080-FlatWireHub.md) |
| The typed event contract | [`FW-149`](FW-149-IFlatWireClient.md) |
| `ITInhibit`'s conditions — this story hosts the **gate**, not the logic | [`FW-205`](FW-205-ITInhibitService.md) |
| The cadence values as configuration | [`FW-144`](FW-144-Configuration-Binding.md) |

---

## 2. The four traffic classes

`[SIG §4.2]` and `phase-01b` L107. **Getting a channel into the wrong class is the defect
this story ships or avoids.**

| Class | Traffic | Treatment |
|---|---|---|
| **Batched** | gauge, width, speed, payoff weight, footage | Arrays per line group at the cadence; hot numeric channels **decimated** to it |
| **On change only** | `ComponentStatus`, `LineStatus` | Sent when the value changes, not every tick |
| **Immediate, unbatched** | rare domain events — weld, die change, pause, SPC, alert, checkout | Sent as they happen; **must not enter the 10 Hz batch** |
| **Immediate — and easy to get wrong** | **`PayoffStateChanged`** | ⚠ **Never in the batch.** It is a state transition, not a sample |

### 2.1 FL2 — suppress two channels, not the line

`FR-120` makes FL2's **live gauge and width `null`**; the historical profile is a REST query.
`[SIG §5.3]` suppresses **only** the batched gauge and width channels.

> ⚠ **`SpeedFPM`, `FootageCounter`, `ComponentStatus` and `LineStatus` still flow on FL2.**
> `[TRP]` is explicit: *"A simulator that drives FL1 only leaves both FL2 screens dead"* —
> and the same is true of a broadcast loop that suppresses FL2 wholesale. **Two of the six
> trial screens are FL2** (DB5, DB3-FL2).

⚠ **The rule is conditioned on FL2 *in standalone mode*, not on FL2 as a line** — `FR-120`
and `[SIG §5.3]` both say so, and `G40` records this as one of the assertions that rested on
the earlier error. An FL3 hybrid run drives FM2 and is **not** suppressed.

### 2.2 The `ITInhibit` gate sits inside this loop

`phase-01b` L112: *"While set, no rolling data is recorded without an active coil — so the
interlock gates the broadcast loop's `RunReading` persistence."*

**Persistence stops; broadcast does not.** The gate goes immediately before the `RunReading`
write, not around the send. An operator watching a blocked line still sees telemetry; the
system simply does not record it as run data.

---

## 3. Build order

1. A drain loop on a **fixed** cadence from configuration (default ~100 ms), reading
   [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md)'s bounded channel.
2. Group the drained readings **per line group** (`FL1Data` / `FL2Data` / `FL3Data`) and send
   **arrays**, typed on [`FW-149`](FW-149-IFlatWireClient.md)'s `IFlatWireClient`.
3. Decimate hot numeric channels to the cadence.
4. `ComponentStatus` / `LineStatus` — track last value, send on change.
5. **Route `PayoffStateChanged` and the rare domain events around the batch entirely.**
6. FL2 standalone — suppress batched gauge/width, broadcast `null` live values (§2.1).
7. The `RunReading` persistence gate (§2.2).
8. `RunReading.ReadingTs` is **UTC `DATETIME2`** — the one deliberate exception to
   `DATETIMEOFFSET` throughout, because it is a high-volume time series (`[API §1.6]`).

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-29` precede this story.

### `P-30` — fixed cadence, not adaptive, and the ratio is provisional

`G9`/`OI-34` leaves the AGC sample rate and latency budget undefined, so **the decimation
ratio cannot be validated** and the QA2 load test **cannot fail**.

**Build a fixed, configured cadence — do not build an adaptive one.** An adaptive loop tunes
itself against a target nobody has specified, is untestable for the same reason, and makes
the cadence assertions in `TC-601`–`TC-613` non-deterministic. A fixed 100 ms default with
the value in configuration is revisable the moment `G9` closes.

**Record the achieved cadence at QA0 as an observation**, so `G9` can be closed against a
measurement rather than an estimate.

### `P-31` — the loop is unreduced for the trial; the feed is what changes

`[TRP §1.4]`: *"The bounded-channel and broadcast-loop design must still be built to
contract so the real ingest drops in behind it — `FW-150` and `FW-151` are unreduced for
exactly that reason."*

So this story is built **once**, to the full contract, and the only trial-vs-production
difference is which side publishes to the channel. **Do not add a simulator-aware branch** —
if the loop can tell the difference, `FW-203`'s substitution has failed.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified by observation in the QA0 walkthrough; `[NFR]`
`TC-601`–`TC-613` cover cadence, reconnect, group isolation and the PLC audit.

| Check | Expected |
|---|---|
| Cadence | Batches at ~100 ms; value changes from configuration with no rebuild |
| Batched arrays per group | A client in `FL1Data` receives FL1 arrays only |
| Decimation | Hot channels reduced to cadence, not sent per reading |
| On-change only | `ComponentStatus` / `LineStatus` do not repeat on an unchanged tick |
| **`PayoffStateChanged`** | Delivered **immediately**; **never** inside a batch |
| Rare domain events | Immediate and unbatched |
| **FL2** | Batched gauge/width suppressed, live values **`null`** — **and speed, footage, component and line status still arriving** |
| FL3 hybrid | **Not** suppressed |
| `ITInhibit` gate | With the interlock set, telemetry still broadcasts and **`RunReading` rows stop** |
| `ReadingTs` | UTC `DATETIME2` |

⚠ **`TC-620`–`TC-623` are untestable** (`G9`/`OI-34`) — the decimation ratio cannot be
validated. Record what was achieved; do not invent a target.

---

## 6. Handoff

`FW-080` hosts the hub this sends through. `FW-205` sets the interlock this honours.
`FW-N05` replaces `FW-203` behind the channel with no change here — that is `P-31`'s test.
`FW-148` instruments broadcast-cadence deviation off this loop.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`G9` / `OI-34`** *(blocker)* | AGC sample rate, client count and latency budget undefined — the ratio cannot be validated and the load test cannot fail. `P-30` |
| **`G3`** | `RunReading` is the store this loop persists to |
| **`G10`** | If IIS WebSockets is absent the transport silently falls back to long-poll and **the cadence assertions change character** — `[TRP §6]` calls this a provisioning task, to pre-check **before T2** |
| **Pending renames** | `LineStatus` → `LineStateChanged` (`[PLCC §6.3]`). **Build to `[API]`/`[SIG]`**; rename in one pass |

No stale citations in this card.
