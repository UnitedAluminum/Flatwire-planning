---
id: FW-135
legacy_id:
title: SignalR client service
status: not-started
status_confirmed: true
status_note: "✅ **The hub path is settled and the re-map is DONE — no longer a blocker.** `FW-080 §0` executed it on 6 Sep 2026 and proved it on a running service: `Constants.Routes.Hub` is now `/hubs/flat-wire`, the path `[SIG §5.1]` owns, and `prefix` + `flatWireHubUrl` composes to the deployed `/API.FlatWire/hubs/flat-wire`. `FW-145`'s `?access_token=` handler matches the *same constant*, so the two cannot diverge *(corrected 7 Sep 2026 — this note was written 28 Aug, was true then, and went stale when `FW-080 §0` landed)*. ⚠ Still owed, and now split across two gaps: `@microsoft/signalr-protocol-msgpack` is absent while the hub enables MessagePack by default (`G10`, infrastructure), and **enums cross as strings under MessagePack but integers under JSON, so the protocol decides the payload contract** (`G105`, raised 7 Sep 2026) — write the mappers to accept both forms whichever is chosen. Also waits on `FW-N03`"
owner:
jira:
mvp: 1
phase: "1A"
stream: RT
streams: [RT]
priority: critical
hours: 24
sprint: S0
depends_on: [FW-N03]
blocked_by: [G10, G105]
has_plan: true
started:
completed:
---
# FW-135 · `flat-wire-signalr.service.ts` — the SignalR client

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 7, 2026
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **Hub path settled** — `flatWireHubUrl` is `FlatWire/hubs/flat-wire` and the running hub answers at `/hubs/flat-wire` (`[SIG §5.1]`); [`FW-080 §0`](../../40-backend/tasks/FW-080.md) executed the re-map on 6 Sep 2026, so **nothing is owed** *(corrected 7 Sep 2026)*. ⛔ **The blocker is now the protocol** — one package must still be added and MessagePack-vs-JSON decided (`G10`)
**Owner:** Frontend (Angular) stream — ⚠ **`RT` stream label, `ual-angular` code**
**Audience:** The Angular developer building `FW-135`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Depends on:** [`FW-N03`](FW-N03.md)
**Unblocks:** [`FW-136`](FW-136.md) · [`FW-137`](FW-137.md) · and `FW-081`'s live wiring in Phase 5
**Part of:** `ProjectPlan/Frontend/tasks/` — index: [Orchestration.md](Orchestration.md) · shared context: [Phase-01A-ImplementationPlan.md](Phase-01A-ImplementationPlan.md)

---

> **Read [`[P1A §2]`](Phase-01A-ImplementationPlan.md) first**, and `[SIG §4]`/`§5` for the contract
> this implements. This story carries the `RT` stream label; the label says **when** the work happens,
> not which repository it lands in — this is Angular code.
>
> ⛔ **Fourteen observables, not twelve.** An older reading of `[SIG §5.6]`'s map gives twelve, missing
> the two order-allocation streams. `phase-01a` and `[TB §7]`'s `FW-136` are **still** stale at twelve
> and nine — `[P1A §6.12]`.
>
> This plan is derived from the specifications and **loses to every one of them.**

---

## 1. The story

From `[TB §7]`:

> ###### FW-135 · SignalR client service
> **Hours:** 24 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1A · **Stream:** RT
>
> **As an** operator,
> **I want** a purpose-built SignalR client that survives reconnects and never storms change detection,
> **So that** live traces render at 60 fps without freezing the panel.
>
> **Acceptance Criteria:**
> - [ ] `flat-wire-signalr.service.ts` using `@microsoft/signalr` + `@microsoft/signalr-protocol-msgpack` (**MessagePack**)
> - [ ] Auto-reconnect with **exponential backoff** and **line-group re-join on reconnect**; JWT via `?access_token=`
> - [ ] Callbacks run **outside NgZone** into a **ring buffer**; render throttled by `requestAnimationFrame` (~60 fps); fixed window of the last ~500 points
> - [ ] Typed Observables per event
> - [ ] **New service — deliberately not derived from `supervisor-monitor-hub`, `CoilDataHub` or `OPCManagerHub`**
> - [ ] Verified: streaming a mock trace triggers no change-detection storm under OnPush
>
> **Rate-card basis:** real-time client, priced against `[SIG]`'s stated design (24 h)
> **Dependencies:** FW-N03
> **Blockers:** **G10**

⚠ **"Typed Observables per event" is now fourteen**, and that criterion is why the stale map mattered:
a client built to it before 27 Aug would have shipped **12 of 14 streams**.

---

## 2. Build order

### Step 1 — the packages

✅ **`@microsoft/signalr` 9.0.6 is already in `package.json`.**
⛔ **`@microsoft/signalr-protocol-msgpack` is absent** — this is gap **`G10`**, and `[SIG §4.1]`
treats MessagePack as **measure-first**: *"batching and decimation are the real win."*

**Two provisioning facts to settle before T2, neither of them code:**

| | |
|---|---|
| the protocol package | `@microsoft/signalr-protocol-msgpack` must be added to `package.json` — a dependency decision, not a build step. ⚠ **Decide the protocol before the enum mappers are written**: the hub enables MessagePack by default but it is config-switchable, and enums cross as **strings** under MessagePack and **integers** under JSON, so a client written against one breaks the moment the flag flips |
| **IIS WebSockets on the target** | must be enabled, or the transport **silently falls back to long-poll** (`[DEP §4.4]`) |

### Step 2 — the connection

```typescript
new signalR.HubConnectionBuilder()
  .withUrl(`${this.appConfigService.getEndpoint().flatWireHubUrl}?access_token=${token}`)
  .withHubProtocol(new MessagePackHubProtocol())
  .withAutomaticReconnect(/* exponential backoff */)
  .build();
```

⚠ **Read the URL from config, never hand-assemble it** — `F-02` owns the value.
`flatWireHubUrl` is `FlatWire/hubs/flat-wire`, which resolves to `/API.FlatWire/hubs/flat-wire`.

✅ **The running hub answers there.** [`FW-080 §0`](../../40-backend/tasks/FW-080.md) **executed the
re-map on 6 Sep 2026** — 19 occurrences across 6 files, 273/273 unit tests passing, and proven on a
running service rather than asserted (`FW-080 §6.2`: the old path returns **404**, the new one
**401**/**101 Switching Protocols**, and `grep hubs/flatwire` across `ual-api` returns nothing):

```csharp
- public const string Hub = "/hubs/flatwire";     // was deployed
+ public const string Hub = "/hubs/flat-wire";    // what [SIG §5.1] owns
```

`app.MapHub<FlatWireHub>(Constants.Routes.Hub)` and
[`FW-145 §3.5`](../../40-backend/tasks/FW-145.md)'s `?access_token=` handler both match that **same
constant** rather than a second literal — so the two cannot drift apart, and **nothing is owed here
by anybody** *(corrected 7 Sep 2026: this block was written 28 Aug, was true then, and went stale
the moment `FW-080 §0` landed. `FW-080 §0` itself flagged that the reciprocal rows still read as
owed.)*

⚠ **`FW-145` still has to be delivered**, though, for a valid token to survive the hub's
`[Authorize]`. Until it lands, expect a **401** — which is an auth failure, not the path failure
this block used to describe. ⛔ **Do not work around either with a hard-coded URL.**

| Requirement | Detail |
|---|---|
| Transport | **WebSockets-first**, `SkipNegotiation` where the topology allows; SSE and long-poll last resort |
| Auth | JWT via the **`?access_token=` query parameter** — hub methods carry `[Authorize]` |
| Reconnect | **exponential backoff** + **line-group re-join** — `JoinLineGroup({machineName})` again on every reconnect |
| Groups | `FL1Data` / `FL2Data` / `FL3Data`; `LeaveLineGroup` on teardown |

### Step 3 — the rendering discipline, which is the point of the story

- Callbacks run **outside the Angular zone** (`NgZone.runOutsideAngular`).
- Incoming batches land in a **ring buffer**, not in a component field.
- Render on a **`requestAnimationFrame` throttle** coalesced to ~60 fps, re-entering the zone **once per frame**.
- Trace consumers keep a **fixed window of ~500 points** to bound DOM and GPU work.
- `ChangeDetectionStrategy.OnPush` everywhere.

**The cadence to expect is specified:** batched **~10 Hz** (`[SIG §4.2]` *"fixed cadence ~100 ms /
10 Hz"*, `[SIG §5.2]` rows 1–2). ⚠ **What `G9` leaves undefined is the *target*, not the cadence** —
the AGC publish rate at source is asked as `PLC-Q11` and the end-to-end latency figure comes from
commissioning test `C8`. So you have a rate to build against and no NFR to be validated against.

### Step 4 — the fourteen typed observables

Name them **exactly** as `[SIG §5.6]`, matching 1B's `IFlatWireClient` name for name:

```typescript
gaugeReading$(machineName): Observable<GaugeReadingEvent[]>
widthReading$(machineName): Observable<WidthReadingEvent[]>
speedFpm$(machineName): Observable<SpeedFpmEvent>
payoffWeight$(machineName): Observable<PayoffWeightEvent>
payoffStateChanged$(machineName): Observable<PayoffStateChangedEvent>
footageCounter$(machineName): Observable<FootageCounterEvent>
componentStatus$(machineName): Observable<ComponentStatusEvent>
lineStatus$(machineName): Observable<LineStatusEvent>
alertRaised$(machineName): Observable<AlertRaisedEvent>
alertCleared$(machineName): Observable<AlertClearedEvent>
spoolCompletionPromptDue$(machineName): Observable<SpoolCompletionPromptDueEvent>
spoolCompletionPromptResolved$(machineName): Observable<SpoolCompletionPromptResolvedEvent>
orderAllocationReached$(machineName): Observable<OrderAllocationReachedEvent>       // event 13
orderAllocationResolved$(machineName): Observable<OrderAllocationResolvedEvent>     // event 14
```

Plus the **six run-event markers** consumed by DB3 traces: `WeldJoinEvent` · `DieChangeEvent` ·
`PauseEvent` · `SPCCheckpoint` · `AlertEvent` · `RodCheckoutEvent` (`[SIG §5.4]`).

### Step 5 — ⚠ the two streams that are not fire-and-forget

**`spoolCompletionPromptDue$` and `orderAllocationReached$` are durable server state.** Every other
event may be missed by a disconnected client and recovered from the next snapshot; these may not.

| Rule | Why |
|---|---|
| **Subscribe *before* joining the group** | an outstanding prompt is re-delivered **on join**, not only on the original edge (`FR-144`, `TC-173`) |
| **Make both handlers idempotent** | each is raised once per edge, so **duplicate delivery is specified behaviour, not a fault** |
| **Render `latchedWeightLb`; never substitute a fresher `payoffWeight$` tick** | the weight is latched at the PLC stop timestamp / the crossing instant |

⚠ **`orderAllocationResolved$` does something its spool-side counterpart does not:** it **reveals the
next order** on the same rod. The rod is not dismounted and nothing is scanned, so **this event is the
only signal the screen gets that the boundary was crossed** — and the material produced between the
crossing and the acknowledgement is the **overrun**, recorded and reportable.

### Step 6 — ⚠ the FL2 rule

⛔ **REVERSED 9 Sep 2026 — FL2 publishes both channels at 4 s** (`A3` retired, `FR-120` superseded, `[SIG §5.3]` withdrawn). ~~**FL2 standalone suppresses the batched gauge and width channels entirely.**~~ A client subscribed to
`FL2Data` **must not wait for `GaugeReading`** — it will never arrive, and **treating its absence as a
fault is a defect** (`[SIG §5.3]`, `FR-120`). Status and marker events still flow.

### Step 7 — ⛔ what this service is not derived from

**A new service, deliberately.** `[ARC §2.2]` rules out `CoilDataHub`, `OPCManagerHub` and
`supervisor-monitor-hub`. The concrete reason, from reading the two live examples
(`projects/scheduling/src/lib/services/hub/hub.service.ts` and `furnace-scheduling`'s equivalent):

| They do | `[SIG §4]` requires |
|---|---|
| `.build()` with **no hub protocol** | MessagePack |
| **no reconnect configuration** | exponential backoff + group re-join |
| `.start().then(...)` into `.on(...)` **inside the Angular zone** | callbacks **outside** the zone |
| **one connection per request**, stopped on the first message | a long-lived connection with per-line groups |

**Every one of those choices is the opposite of what this story needs.** That is why the rule exists,
and it is checkable rather than aspirational.

---

## 3. Verification

```bash
npm run build   # compiles flat-wire from source via the wrapper — there is no `ng build flat-wire`
ng lint flat-wire
npm run test:flat-wire
npm start      # with FW-136's mock stream once it exists
```

| AC | Proof |
|---|---|
| 1 · the two packages | ⛔ **the protocol package must be added first** (`G10`) |
| 2 · backoff + group re-join + `?access_token=` | kill the hub, restore it, confirm re-join **and** re-delivery of an outstanding prompt |
| 3 · outside NgZone → ring buffer → rAF, ~500-point window | Angular DevTools shows **no change-detection storm** under a ~10 Hz stream |
| 4 · **fourteen** typed observables | all fourteen present and named per `[SIG §5.6]` |
| 5 · not derived from the existing hubs | ⚠ reviewable only by reading the diff — **reviewer: TBD**. §2 step 7 lists the four concrete differences, so the review is checkable rather than a matter of taste |
| 6 · no storm under OnPush | as AC 3 |

**Test cases:** ⛔ **None.** Phase 1A has **no test cases in `[TCS]`** — measured 28 Aug 2026 against its **405 defined cases** (the ids run to `TC-799`, but 47 are cited and never defined), nothing covers the Angular library, the shell, the canvas, the guards or the mock hub. This story's verification is this plan plus Jest, and nothing else. → `[TCS]`, `[P1A §6.13]`

---

## 4. Blockers and open items

| Item | Effect |
|---|---|
| ⛔ **`G10`** — the MessagePack package is absent; IIS WebSockets must be enabled | **provisioning, before T2.** Without WebSockets the transport degrades **silently** |
| ⚠ **`G9` / `OI-34`** | no NFR target to validate against — **but the cadence is specified**; blocks validation, not build |
| ⚠ **`[P1A §6.12]`** | `phase-01a` (twelve) and `[TB §7]`'s `FW-136` (nine) / `FW-080` are stale on the event count |

---

## 5. Handoff

**This story unblocks `FW-136` and `FW-137`.** Hand on:

1. **The observable surface is fourteen** — and `FW-136`'s own acceptance criteria in `[TB §7]` list nine. Build to this file, not to that card.
2. **The ring buffer and the rAF throttle are this service's**, not each screen's. A screen subscribes; it does not throttle.
3. **The two durable streams** — subscribe before joining, stay idempotent, render the latched weight.
