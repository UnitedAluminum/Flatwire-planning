# FW-172 · Run-event markers and the `LineStatus` transitions

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **every marker here is immediate and unbatched**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-172`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** The story's "so that" is the acceptance test: *"the screen and
> the record never disagree."* Everything follows from that.
>
> **All five broadcasts are rare domain events — immediate and unbatched.** None may enter
> [`FW-150`](FW-150-Broadcast-Loop.md)'s ~100 ms batch. A marker that arrives up to a tick
> late while its row is already written is exactly the disagreement this story exists to
> prevent.
>
> And the naming trap, which is deliberate and looks like drift: the aggregate, the table, the
> endpoint and the story all say **`WeldEvent`** — **`WeldJoinEvent` survives only as the
> SignalR method name.**

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-172 · Run-event markers and the `LineStatus` transitions
> **Hours:** 20 h RT · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** RT
>
> **As an** operator,
> **I want** every event I record to appear on the trace immediately,
> **So that** the screen and the record never disagree.
>
> **Acceptance Criteria:**
> - [ ] Markers published to the DB3 traces: `WeldJoinEvent`, `DieChangeEvent`, `SPCCheckpoint`, `PauseEvent`
> - [ ] `LineStatus` transitions RUNNING ↔ PAUSED, reaching Dashboard 1
> - [ ] `PayoffWeight` re-established after a weld; `ComponentStatus` re-broadcast after a roll override
> - [ ] All are **rare domain events — immediate and unbatched**
> - [ ] Standard reconnect and group re-join apply
>
> **Rate-card basis:** 4 marker events @ 4 h = 16 h + `LineStatus`/`ComponentStatus` wiring 4 h = 20 h (§2)
> **Dependencies:** FW-149, FW-081
> **Blockers:** —

### 1.1 ⚠ Three of the five markers have no writer in the trial

The markers are broadcasts of events other stories record. In trial scope:

| Marker | Its writer | In trial? |
|---|---|---|
| `SPCCheckpoint` | [`FW-168`](FW-168-Spc-And-SpcService.md) | ✅ |
| `PauseEvent` | [`FW-170`](FW-170-Pause-Resume-And-RunControlService.md) | ✅ |
| `WeldJoinEvent` | `FW-166` | ❌ **deferred with DB2A** |
| `DieChangeEvent` | `FW-073` | ❌ deferred |
| `RodCheckoutEvent` *(`FW-177`'s)* | `FW-072` | ❌ deferred |

**Build all of them.** `[TRP §7]`: *"Build the weld-marker layer even though it renders empty
… with no `WeldEvent` rows in trial scope the array is empty, which is a **legitimate state,
not a defect**. Deleting the layer is rework when weld capture returns."*

⚠ **AC 1 lists four markers; `[SIG §5.4]` publishes six** — the two not here are `AlertEvent`
and `RodCheckoutEvent`, and `RodCheckoutEvent` belongs to
[`FW-177`](FW-177-Exception-Broadcasts.md). See §4 `P-45`.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The typed contract these are declared on | [`FW-149`](FW-149-IFlatWireClient.md) |
| The batch loop these bypass | [`FW-150`](FW-150-Broadcast-Loop.md) |
| `RodCheckoutEvent` and `AlertRaised` | [`FW-177`](FW-177-Exception-Broadcasts.md) |
| The DB3 chart rendering them | `FW-081`, `FW-163`, FE |
| Domain-event plumbing | [`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) |

---

## 2. Immediate, unbatched — and how a handler reaches the hub

`[SIG §4.2]` and [`FW-150 §2`](FW-150-Broadcast-Loop.md): rare domain events are sent
**immediately and unbatched**; only gauge, width, speed, payoff weight and footage are
batched at ~100 ms, with `ComponentStatus`/`LineStatus` **on change only**.

> ⚠ `PayoffStateChanged` must never enter the batch either — but that is
> [`FW-150`](FW-150-Broadcast-Loop.md)'s, not this story's.

**The route from a command handler to the hub is a domain event**, because `[SVC §3.2]` bars
SignalR types from `FlatWire.Application`:

```
aggregate raises  →  FlatWireDbContext dispatches AFTER commit  →  handler in
(AddDomainEvent)     (DispatchDomainEventsAsync)                    Infrastructure →
                                                                    IFlatWireClient
```

**After commit, never before** — dispatching first broadcasts a marker for a row the database
may still reject, which is the disagreement in the story's "so that".
[`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) owns that plumbing; this story
supplies the translation handlers for these five.

### 2.1 The two re-broadcasts

| Trigger | Re-broadcast | Why |
|---|---|---|
| A weld | **`PayoffWeight`** | The payoff has changed physically — the old weight is wrong |
| A roll override | **`ComponentStatus`** | Component state changed outside the on-change path |

Both are ordinary events being re-sent, not new ones. They exist because
[`FW-150`](FW-150-Broadcast-Loop.md) sends `ComponentStatus` **on change only**, so a change
made through a command — not through a tag read — needs an explicit push.

### 2.2 `LineStatus` — and the rename that is pending

`RUNNING ↔ PAUSED`, reaching Dashboard 1.

⚠ **`[PLCC §6.3]` records `LineStatus` → `LineStateChanged` and `LineState` →
`LineOperatingState`.** **Not applied.** `[API §2]` and `[SIG §5.2]` are the contracts of
record and still publish the old names. **Build to `[API]`/`[SIG]`; apply the rename in one
pass across all three when arbitrated.**

⚠ **`enum LineState` has no `Stopped` member**, deliberately. Resolve any stop edge through
the configurable `LineStateMap` (`[PLC §6]`), **never by adding an enum value** (`PLC-Q01`).

---

## 3. Build order

1. Confirm all five are typed on `IFlatWireClient`
   ([`FW-149`](FW-149-IFlatWireClient.md)) — **no magic-string sends**.
2. Domain events raised by the aggregates
   ([`FW-207`](FW-207-Domain-Model.md)): `WeldRecorded`, `RunPaused` and their siblings.
3. Translation handlers in **Infrastructure**
   ([`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) `P-35`), one per event.
4. Send **immediately**, bypassing the drain loop entirely (§2).
5. The two re-broadcasts (§2.1).
6. `LineStatus` RUNNING ↔ PAUSED (§2.2).
7. Reconnect and group re-join are inherited from
   [`FW-080`](FW-080-FlatWireHub.md) — **do not re-implement**.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-44` precede this story.

### `P-45` — this story owns four markers; the other two are `FW-177`'s

`[SIG §5.4]` publishes **six** run-event markers. This card lists four, and the split with
[`FW-177`](FW-177-Exception-Broadcasts.md) is not stated anywhere.

**Resolution:**

| Marker | Owner |
|---|---|
| `WeldJoinEvent` · `DieChangeEvent` · `SPCCheckpoint` · `PauseEvent` | **this story** |
| `RodCheckoutEvent` | [`FW-177`](FW-177-Exception-Broadcasts.md) — its AC names it explicitly |
| `AlertEvent` | [`FW-177`](FW-177-Exception-Broadcasts.md), with `AlertRaised` |

Rationale: `FW-177`'s card already claims `RodCheckoutEvent` — *"DB14 was the previously-listed
consumer and was descoped; DB3 is now named explicitly so the event is not left without
one"* — and grouping the two exception broadcasts keeps one story owning the supervisor path.

**Together the two stories cover all six.** Neither alone does, and that is worth stating
because `phase-01b`'s **exit criterion 4** counts the **six markers** as one obligation.
⚠ *That criterion said "twelve events and six markers" until 28 Aug 2026 and now reads
**fourteen**; the events half never bore on this story, and the **six markers are unchanged**.*

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified by observation in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **Immediate** | Record an SPC checkpoint → the marker arrives **without waiting for a batch tick** |
| **Never batched** | No marker appears inside a `GaugeReading[]` payload |
| **After commit** | Force a save failure → **no marker is broadcast** |
| Weld / die change | Layers present and functioning; **empty in the trial is legitimate** |
| Re-broadcasts | `PayoffWeight` after a weld; `ComponentStatus` after a roll override |
| `LineStatus` | RUNNING ↔ PAUSED reaches Dashboard 1 |
| Reconnect | Group re-join restores delivery; markers are **not** replayed *(only `SpoolCompletionPromptDue` is durable — [`FW-080 §3.3`](FW-080-FlatWireHub.md))* |
| Typed | No magic-string `SendAsync` |

---

## 6. Handoff

[`FW-177`](FW-177-Exception-Broadcasts.md) covers the other two markers.
`FW-081` / `FW-163` (FE) render them on the DB3 traces.
[`FW-150`](FW-150-Broadcast-Loop.md) carries everything these bypass.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **Pending renames** | `LineStatus` → `LineStateChanged`; `LineState` → `LineOperatingState`. **Build to `[API]`/`[SIG]`** |
| **`PLC-Q01`** | `LineState` has no `Stopped` member — resolve via `LineStateMap`, never by adding a value |
| **`OI-18`** | An SPC checkpoint cannot join to its trigger — affects what the marker can carry |
| **`G9` / `OI-34`** | No latency target, so *"immediately"* has no measurable threshold. Record what is achieved |
