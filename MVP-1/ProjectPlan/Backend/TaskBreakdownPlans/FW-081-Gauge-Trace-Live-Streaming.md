# FW-081 · `gauge-trace-chart` live streaming, maximize and runtime source toggle

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** **Ready to build on the server side** — the six streams and four of six markers exist
**Owner:** Real-time stream *(with a 4 h FE half)*
**Audience:** The developer building `FW-081`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Twenty-eight hours across two streams, and **four details
> decide whether it is right.**
>
> **⛔ `isLive` is a RUNTIME-switchable input, not mount-time** — and the card says why: **Phase 8
> needs exactly this for FL2's Live/Profile control, and a hybrid FL3 run has both.** Building it
> as a mount-time flag is the single most expensive mistake available here.
> **Two of the six marker streams have no producer yet.** `FW-172` owns four
> (`P-45`); `WeldJoinEvent` needs [`FW-166`](FW-166-WeldEvent-And-WeldService.md) and
> `RodCheckoutEvent` needs [`FW-174`](FW-174-WipRejection-And-Checkout-Services.md).
> **FL2 broadcasts `null` gauge and width — deliberately.** The chart must render an **empty
> state**, not zeros. That is [`FW-181`](FW-181-FL2-Null-Gauge-Contract.md), *"the single most
> likely thing to ship wrong."*
> **The series is sampled at 4 ft, not at 100 ms.** `FR-018` gates `RunReading` on footage, so a
> ~500-point window is a **distance** window whose duration varies with line speed.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-081 · `gauge-trace-chart` live streaming, maximize and runtime source toggle
> **Hours:** 4 h FE · 24 h RT · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE + RT
>
> **As an** operator,
> **I want** the gauge and width traces streaming live with weld markers,
> **So that** I can react to drift before it produces out-of-spec material.
>
> **Acceptance Criteria:**
> - [ ] Streaming gauge + width (Chart.js) with target dashed line, tolerance band, green/red points and **vertical weld markers carrying the rod alpha**
> - [ ] Consumes `gaugeReading$ / widthReading$ / speedFpm$ / payoffWeight$ / componentStatus$ / footageCounter$`; markers via `WeldJoinEvent / DieChangeEvent / PauseEvent / SPCCheckpoint / RodCheckoutEvent`
> - [ ] Renders from the ring buffer under `requestAnimationFrame`, outside NgZone, on a fixed ~500-point window
> - [ ] **Each panel maximizes to full screen** — backdrop, ESC and backdrop-click restore
> - [ ] ⚠ **`isLive` is a runtime-switchable input, not mount-time.** The chart must switch between live streaming and a static historical profile **after mount, without remounting** — Phase 8 needs exactly this for FL2's Live/Profile control, and a hybrid FL3 run has both
> - [ ] Last-window buffer survives a reconnect and re-join
>
> **Rate-card basis:** FE maximize + runtime toggle 4 h + RT live wiring across 6 event streams 24 h = 28 h (§2)
> **Dependencies:** FW-133, FW-135, FW-150
> **Blockers:** —

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The broadcast loop producing the six streams | [`FW-150`](FW-150-Broadcast-Loop.md) — ✅ built |
| Four of the six markers | [`FW-172`](FW-172-Run-Event-Markers.md) — `P-45` |
| `WeldJoinEvent`'s producer | [`FW-166`](FW-166-WeldEvent-And-WeldService.md) |
| `RodCheckoutEvent`'s producer | [`FW-174`](FW-174-WipRejection-And-Checkout-Services.md) |
| The FL2 null-gauge **contract** | [`FW-181`](FW-181-FL2-Null-Gauge-Contract.md) — this story **renders** it |
| The historical profile query | [`FW-164`](FW-164-Run-Queries-And-RunQueryService.md) — `gaugetrace` |
| The Angular chart component | `FW-133`, FE |

### 1.2 What already exists

Read off the built code on 29 Aug 2026.

| Thing | State |
|---|---|
| `FW-150`'s broadcast loop | ✅ **Built and verified** — 15/15 harness assertions |
| **Gauge and width take ARRAYS**; speed, payoff weight and footage take a **single** payload | ✅ Built (`P-124`) — ⚠ **the six streams are not uniform** |
| `null` means no sample — **skip the channel, never send `0`** | ✅ Built (`P-124`) |
| FL2 branch | ⛔ **None, deliberately** — `[SIG §5.3]` *"entirely"* + no `AGC` path = nothing to suppress |
| `RunReading` write | ✅ Built — **footage-gated at 4 ft** (`FR-018`), 20 ft intermediate |
| `[SIG §5.4]`'s six marker payloads | ✅ **Published `[PROPOSED]` by `FW-149`** — shared `lineId · runId · footagePosition · timestamp` base plus one to three fields each, **all six verified against the built code** |
| `IFlatWireClient` | ✅ 20 members, 21 types — `FW-149` closed the server leg at 20 of 20 |
| `FW-080`'s replay on join | ✅ Built (`P-100`) |
| **Marker producers** | ⚠ **Four are `FW-172`'s (unbuilt); `WeldJoinEvent` and `RodCheckoutEvent` need `FW-166`/`FW-174`** |
| ⛔ **`G9` / `OI-34`** | **No cadence, decimation or on-change test case exists** — `FW-150` recorded this |

---

## 2. The four details

### 2.1 ⛔ `isLive` must switch after mount, and Phase 8 is the reason

The card is unusually explicit: *"a runtime-switchable input, not mount-time … Phase 8 needs
exactly this for FL2's Live/Profile control, and a hybrid FL3 run has both."*

**Why a hybrid FL3 run "has both" is the part worth understanding:** FL3 is FL1 feeding FL2
continuously. The FL1 half has **real-time** gauge; the FL2 half is **historical/profile**. So one
run legitimately shows a live trace and a static profile **on the same screen at the same time**,
and a control that toggles a panel between them cannot remount.

⛔ **A mount-time flag forces a remount**, which loses the ring buffer, re-subscribes the hub, and
re-triggers the replay-on-join — visible as a flicker and a gap in the trace at exactly the
moment an operator is watching for drift.

### 2.2 The six streams are not uniform, and two markers have no producer

| Stream | Shape | Producer |
|---|---|---|
| `gaugeReading$`, `widthReading$` | **Arrays** (`P-124`) | ✅ `FW-150` |
| `speedFpm$`, `payoffWeight$`, `footageCounter$` | **Single payload**, newest-wins | ✅ `FW-150` |
| `componentStatus$` | **On-change** | ✅ `FW-150` |
| `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint` + one more | markers | ⚠ [`FW-172`](FW-172-Run-Event-Markers.md), unbuilt — **four of six** (`P-45`) |
| **`WeldJoinEvent`** | marker | ⛔ [`FW-166`](FW-166-WeldEvent-And-WeldService.md), unbuilt |
| **`RodCheckoutEvent`** | marker | ⛔ [`FW-174`](FW-174-WipRejection-And-Checkout-Services.md), unbuilt |

⚠ **`payoffWeight$` is FL1/FL3 only** — `RodStaging` does not cover FL2, so FL2 sends none
(`FW-150`). **The chart must not read an absent stream as zero weight.**

### 2.3 The window is a distance, not a duration

AC 3 asks for *"a fixed ~500-point window"*. ⚠ **`FR-018` gates the `RunReading` write on
footage — 4 ft per data point, 20 ft intermediate — not on the 100 ms tick.**

So the row rate is **speed-dependent**: `(FPM ÷ 60) ÷ spacing_ft`. A 500-point window is
**2,000 ft** at 4 ft spacing, and its wall-clock duration changes as the line speeds up or slows.

⚠ **That is correct for a gauge trace** — an operator reasons about drift **over material**, not
over time — but it means the x-axis is footage and a time-based buffer eviction would be wrong.

⛔ **And the broadcast cadence is a third thing again** (~100 ms), so **three cadences** are in
play: the tick, the footage gate, and the render frame.

### 2.4 FL2 renders an empty state, and this is the known trap

FL2 broadcasts **`null`** gauge and width. `P-124` established the server rule: **null means no
sample — skip the channel, never send `0`.**

⛔ **So the chart must distinguish "no data" from "zero"** and render an empty state with the
Profile view available. [`FW-181`](FW-181-FL2-Null-Gauge-Contract.md) is called *"the single most
likely thing to ship wrong"*, and `P-49` records that **the client binds to route mode and the
server must publish it** — so the chart decides Live-versus-Profile from **route mode**, not from
whether data happens to be arriving.

⚠ **`FR-120` conditions the null-gauge rule on FL2 in *standalone* mode**, not on FL2 as a line —
which is why route mode is the discriminator and `G40`'s `PS-1100-FL2-002` matters.

---

## 3. Build order

**RT half (24 h)** — the server side this plan owns:

1. Confirm the six streams against `FW-150`'s built shapes (§2.2) — ⚠ **arrays for two, single
   payload for three, on-change for one.**
2. Ensure **route mode is published** so the client can bind Live-versus-Profile (`P-49`, §2.4).
3. Wire the marker streams that exist; **record the two with no producer** rather than stubbing
   them.
4. ⚠ **Do not add an FL2 branch** — `FW-150` deliberately has none, and adding one here would put
   the FL2 rule in two places.

**FE half (4 h)** — recorded for completeness; it lands in `ual-angular`:

5. Runtime `isLive` switching **without remount** (§2.1) — the buffer and subscription survive.
6. Maximize per panel: backdrop, ESC, backdrop-click restore.
   ⚠ **`fw-modal.js`'s suite rule is that no dialog scrolls and oversized dialogs are scaled**;
   a maximized chart is a different thing and should use the full viewport.
7. Ring buffer under `requestAnimationFrame`, **outside NgZone**, on a ~500-**point** (footage)
   window (§2.3).
8. **Empty state for FL2**, driven by **route mode** (§2.4) — ⛔ never by absence of data.
9. Last-window buffer survives reconnect and re-join, alongside `FW-080`'s `P-100` replay.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-217` precede this story.

### `P-218` — Live-versus-Profile is decided by route mode, never by data arriving

§2.4, applying `P-49`. A chart that infers "profile" from the absence of readings shows **Live
with no data** during a pause, a thread, or a transient dropout — and shows **Profile** on a
healthy FL1 line whose first reading has not landed yet.

⛔ **Route mode is a fact about the run; data arrival is a symptom.**

### `P-219` — the window is footage-based, and eviction is by distance

§2.3. `FR-018` samples on footage, so a time-based ring buffer holds a varying amount of material
and the x-axis stops being comparable between runs.

⚠ **`FW-N11` owns `FR-018`'s number and route rule**; `FW-150` owns only the gate. **This story
owns neither** — it consumes the series as delivered.

### `P-220` — the two producer-less markers are recorded, not stubbed

§2.2. A stubbed marker stream that silently emits nothing is indistinguishable from a working one
with no events, and the trial would demo a trace with no weld markers **looking correct**.

**Fallback:** if a demo needs them before `FW-166`/`FW-174`, drive them from
[`FW-203`](FW-203-OPC-Feed-Simulator.md)'s simulator — **visibly synthetic**, not a silent stub.

---

## 5. Verification

**No automated backend tests** — `[TS §1.2]`. ⚠ **And `G9`/`OI-34` means there is no test case
for cadence, decimation or the on-change channels** — `FW-150` recorded this and it applies here.

| Check | Expected |
|---|---|
| **Runtime toggle** | `isLive` flips **after mount**; the ring buffer and hub subscription **survive** (`P-218`, §2.1) |
| **Hybrid FL3** | A live panel and a profile panel render **simultaneously** for one run |
| **FL2 empty state** | Renders empty, **not zeros**; driven by **route mode** (`P-218`) |
| Stream shapes | Arrays for gauge/width; single payload for speed/weight/footage; on-change for component status |
| **No `0` for null** | A skipped channel never renders as a zero point |
| `payoffWeight$` on FL2 | Absent, and **not** read as zero weight |
| Window | ~500 points ≈ **2,000 ft** at 4 ft spacing; eviction by **distance** (`P-219`) |
| Markers | Four render once `FW-172` lands; ⛔ **`WeldJoinEvent` and `RodCheckoutEvent` recorded as producer-less** (`P-220`) |
| Weld marker | Carries the **rod alpha** |
| Reconnect | Last-window buffer survives; replay-on-join does not duplicate points |
| Maximize | Backdrop, ESC and backdrop-click all restore |

---

## 6. Handoff

[`FW-181`](FW-181-FL2-Null-Gauge-Contract.md) (Phase 8) is the FL2 Live/Profile control this
story's runtime toggle exists for — ⛔ **and `P-49` requires the server to publish route mode.**
[`FW-164`](FW-164-Run-Queries-And-RunQueryService.md) supplies the historical `gaugetrace`
the Profile view renders. [`FW-172`](FW-172-Run-Event-Markers.md),
[`FW-166`](FW-166-WeldEvent-And-WeldService.md) and
[`FW-174`](FW-174-WipRejection-And-Checkout-Services.md) are the marker producers.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`G9` / `OI-34`** | **No test case for cadence, decimation or the on-change channels** |
| **`FR-018`** | The series is sampled at **4 ft**, so the window is a distance (`P-219`) |
| **`FR-120`** | The null-gauge rule is conditioned on FL2 **standalone**, not on FL2 as a line |
| **`P-49`** | The client binds to **route mode**; the server must publish it |
| **Two markers** | `WeldJoinEvent` and `RodCheckoutEvent` have **no producer** (`P-220`) |
| **`G10`** | IIS WebSockets provisioning — transport silently falls back to long-poll, changing cadence |
