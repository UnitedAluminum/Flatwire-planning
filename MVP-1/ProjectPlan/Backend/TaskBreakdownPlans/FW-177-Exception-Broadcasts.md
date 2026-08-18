# FW-177 · Exception broadcasts and the supervisor notification

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — `G6` answered: role targeting unblocked; §3.1 rewritten around the **silent** failure mode of a wrong group name *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Its durable backing (`FW-175`) is deferred from the trial**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-177`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** This story carries the two run-event markers
> [`FW-172`](FW-172-Run-Event-Markers.md) does not, and between them the six of `[SIG §5.4]`
> are covered — which matters because `phase-01b`'s **exit criterion 4** counts them.
>
> **One of its events lost its consumer and was re-homed.** `RodCheckoutEvent` rendered on
> **DB14**, which was descoped on 4 Aug 2026. The card names **DB3** explicitly *"so the event
> is not left without one"* — a marker with nowhere to render is how an event quietly stops
> being built.
>
> ⚠ **And its durability is deferred.** AC 3 is *"backed by `FW-175`'s durable queue"*, and
> `FW-175` is out of trial scope. A supervisor notification carried only by a transient
> SignalR message is stranded when a terminal disconnects.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-177 · Exception broadcasts and the supervisor notification
> **Hours:** 16 h RT · **Priority:** Medium · **Sprint:** S2 · **Phase:** 7 · **Stream:** RT
>
> **As a** supervisor,
> **I want** holds and checkouts to reach the board and my terminal immediately,
> **So that** I can act on locked material without being told verbally.
>
> **Acceptance Criteria:**
> - [ ] `AlertRaised` (WIP hold) → Dashboard 1
> - [ ] **`RodCheckoutEvent` marker renders on the Dashboard 3 traces** as a run event *(DB14 was the previously-listed consumer and was descoped; DB3 is now named explicitly so the event is not left without one)*
> - [ ] SignalR notification to the **Supervisor role** for a pending disposition, backed by FW-175's durable queue
> - [ ] `LineStatus` → IDLE on checkout
>
> **Rate-card basis:** 2 × hub event @ 8 h = 16 h (§2)
> **Dependencies:** FW-149, FW-175
> **Blockers:** **G7**

### 1.1 What this story owns, and what `FW-172` owns

Per [`FW-172 §4`](FW-172-Run-Event-Markers.md) `P-45` — the split is stated in neither card:

| Marker | Owner |
|---|---|
| `WeldJoinEvent` · `DieChangeEvent` · `SPCCheckpoint` · `PauseEvent` | [`FW-172`](FW-172-Run-Event-Markers.md) |
| **`RodCheckoutEvent`** · **`AlertEvent`** | **this story** |

**Together: all six of `[SIG §5.4]`.** Neither story alone covers them.

Plus two of `[SIG §5.2]`'s twelve events: **`AlertRaised`** and `LineStatus`.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The rejections and checkouts being broadcast | [`FW-174`](FW-174-WipRejection-And-Checkout-Services.md) |
| The durable queue behind AC 3 | `FW-175` — ⚠ **deferred from the trial** |
| The typed contract | [`FW-149`](FW-149-IFlatWireClient.md) |
| Dashboard 1 | `FW-060` — ⚠ **left trial scope on 14 Aug** |
| `AlertCleared` and the alert lifecycle | `FW-N06` — deferred; *"its only consumer was DB1's alert bar"* |

---

## 2. Two consumers, and one of them is not in the trial

| Event | Renders on | In trial? |
|---|---|---|
| `AlertRaised` (WIP hold) | **Dashboard 1** | ❌ **DB1 left trial scope, 14 Aug** |
| **`RodCheckoutEvent`** | **Dashboard 3** traces | ✅ DB3 is in |
| Supervisor notification | the supervisor's terminal | ✅ — but see §3 |
| `LineStatus` → IDLE | DB1 and DB3 | partly |

> ⚠ **`AlertRaised`'s consumer is the same class of problem `RodCheckoutEvent` already hit.**
> `RodCheckoutEvent` lost DB14 and was re-homed to DB3 by name. `AlertRaised` renders on DB1,
> which left trial scope with `FW-060`, and `FW-N06` — the alert rules engine — was deferred
> *"because its only consumer was DB1's alert bar."*
>
> **Build and broadcast it anyway.** It is one of `[SIG §5.2]`'s twelve, exit criterion 4
> counts it, and DB1 returns after the trial. The same reasoning as the weld-marker layer:
> *"a legitimate state, not a defect."*

### 2.1 Immediate and unbatched

All of these are **rare domain events**: immediate, never inside
[`FW-150`](FW-150-Broadcast-Loop.md)'s ~100 ms batch. `LineStatus` is **on-change only**.

The route from handler to hub is a **domain event dispatched after commit**
([`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md)), because `[SVC §3.2]` bars SignalR
types from `FlatWire.Application`. **After commit, never before** — a broadcast for a hold the
database rejected is worse than a late one.

---

## 3. The supervisor notification, and what deferring `FW-175` costs

AC 3: a SignalR notification to the **Supervisor role**, *"backed by `FW-175`'s durable
queue."* `FW-175`'s own premise: *"pending dispositions persisted to a durable queue, **not**
carried only by a transient SignalR notification"* — *"so that locked material is never
stranded because a notification was missed."*

**`FW-175` is deferred from the trial.** So in trial scope the notification is transient, and
a supervisor whose terminal was disconnected is not told.

**The state is still recorded** — [`FW-174`](FW-174-WipRejection-And-Checkout-Services.md)
`P-46` persists PENDING DISPOSITION as part of the checkout transaction regardless. So the
material is not lost, only unannounced.

⚠ **And there is no endpoint to act on it.** `OI-32`: supervisor disposition of a pending
Mode B checkout is a **decided requirement** (`FR-325`, `FR-326`) with **no API surface**.

### 3.1 Role targeting — `G6` answered

Notifying *"the Supervisor role"* requires the role to exist as a claim, and **it does**:
`G6`/`OI-37` was answered **15 Aug 2026** — the six roles are carried on the standard
`ClaimTypes.Role`, so `[TRP §6]` blocker 4 no longer threatens this story.

**Read the Supervisor value from `FlatWireRoles.Supervisor`**
([`FW-145`](FW-145-JWT-And-Role-Policies.md) §5), never from a literal. The claim *values*
are abbreviated or coded rather than `[SEC §8]`'s labels, and the mapping is still
outstanding — so a hard-coded `"Supervisor"` here would compile, pass review, and silently
notify nobody.

> ⚠ **This story's exposure to a wrong role string is worse than `FW-145`'s.** A bad policy
> value fails closed and is *visible* — someone gets a `403` and complains within the hour. A
> bad **group name** fails **silent**: the broadcast goes to a group with no members, no error
> is raised anywhere, and the pending disposition simply never reaches a supervisor. §6 must
> therefore assert a **received** notification, not a dispatched one.

---

## 4. Build order

1. Confirm `AlertRaised`, `RodCheckoutEvent`, `AlertEvent` and `LineStatus` are typed on
   `IFlatWireClient` ([`FW-149`](FW-149-IFlatWireClient.md)).
2. Translation handlers in **Infrastructure**
   ([`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) `P-35`), fired **after commit**.
3. `AlertRaised` on a WIP hold; `RodCheckoutEvent` on checkout.
4. `LineStatus → IDLE` on checkout — on-change only.
5. Supervisor-targeted notification, reading the role from `FlatWireRoles.Supervisor` (§3.1)
   — never a literal.
6. **Immediate, unbatched** throughout.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-46` precede this story.

### `P-47` — broadcast to a group, not to a connection

The notification targets *"the Supervisor role"*, and SignalR offers three ways: a named user,
a connection, or a **group**.

**Use a group — `Supervisors` — joined on connect for any principal holding the role.**

Reasons: a supervisor may have several terminals open, and a per-connection send reaches one;
`[SIG §4.3]`'s existing pattern is group-based (`FL1Data`/`FL2Data`/`FL3Data`) with re-join on
reconnect, so a group inherits reconnect behaviour for free; and it keeps the hub **stateless**
(`[SIG §4.3]`), so the Redis backplane stays a **config-only** path if the API goes
multi-instance.

⚠ **A group send is still transient.** It does not substitute for `FW-175` — a supervisor
connected to *no* terminal receives nothing, which is exactly the gap the durable queue
closes.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`. Verified by observation in the QA0 walkthrough.

| Check | Expected |
|---|---|
| `AlertRaised` | Broadcast on a WIP hold — **even with DB1 out of trial scope** |
| **`RodCheckoutEvent`** | Renders on the **DB3** traces as a run event |
| `LineStatus → IDLE` | On checkout, on-change only |
| Supervisor notification | **Arrives at every connected supervisor terminal** *(`P-47`)* — observed at the terminal, never inferred from a log line at the sender. ⚠ **This is the only check that catches a wrong role value** (§3.1): an empty `Supervisors` group raises no error anywhere |
| **After commit** | Force a save failure → **no broadcast** |
| Unbatched | None of these appears inside a batched payload |
| Typed | No magic-string sends |

⚠ **Three states, and this story owns only the middle one.** A notification can be
**dispatched** (the send executed), **received** (it reached a connected terminal), or
**guaranteed** (it survives a disconnected supervisor). Verify **received** — dispatched is
what a wrong role value also achieves, and guaranteed belongs to `FW-175`, which is out of
trial scope. Record that it is not yet guaranteed.

---

## 7. Handoff

[`FW-172`](FW-172-Run-Event-Markers.md) covers the other four markers. `FW-175` makes this
durable when scheduled. `FW-060`/`FW-154` bring DB1 back after the trial, restoring
`AlertRaised`'s consumer. `FW-N06`'s rules engine adds `AlertCleared` and the lifecycle.

---

## 8. Open items

| Item | Effect here |
|---|---|
| **`G7`** *(blocker)* | — |
| **`G6` / `OI-37`** | ✅ **Answered 15 Aug 2026** — the six roles exist on `ClaimTypes.Role`, so the target group is real. ⚠ **Residual: the claim values are coded and unmapped**, and here a wrong value **fails silent** rather than closed (§3.1) |
| **`OI-32`** | **No endpoint for supervisor disposition of a pending Mode B** — a decided requirement with no surface. This story announces a state nobody can act on through the API |
| **`FW-175` deferred** | The notification is transient in the trial (§3) |
| **Pending renames** | `LineStatus` → `LineStateChanged` (`[PLCC §6.3]`). **Build to `[API]`/`[SIG]`** |
