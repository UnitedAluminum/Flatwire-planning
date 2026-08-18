# FW-208 · Domain events and post-commit dispatch

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — the last of the three `D-29` stories
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-208`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Eight hours, and it is the story that makes `[SVC §3.2]`'s
> hardest rule survivable.
>
> Application may not reference SignalR types. That leaves a command handler no way to
> broadcast its own side effect — and the tempting fix is to inject `IHubContext` and move
> on. **Domain events are the answer the specification already chose**, and `[SVC §3.2c]`
> says the rule is *"satisfied rather than worked around."*
>
> The hours are low for a reason worth knowing: **`MediatorExtension.DispatchDomainEventsAsync`
> and `Entity.DomainEvents` already exist.** This is wiring plus about five translation
> handlers — not a mechanism to design.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-208 · Domain events and post-commit dispatch
> **Hours:** 8 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> > **New 15 Aug 2026 (`D-29`).** Low because `MediatorExtension.DispatchDomainEventsAsync` and `Entity.DomainEvents` **already exist** — this is wiring plus the translation handlers.
>
> **As a** developer,
> **I want** aggregates to raise domain events that reach the hub after commit,
> **So that** command handlers broadcast side effects without referencing SignalR.
>
> **Acceptance Criteria:**
> - [ ] Aggregates raise `RunPaused`, `WeldRecorded`, `CoilCompleted`, `BayStateChanged`, `SpoolCompletionPromptRaised` via the inherited `AddDomainEvent`
> - [ ] `FlatWireDbContext.SaveChangesAsync` calls **`DispatchDomainEventsAsync` after commit** — never before
> - [ ] Handlers in Infrastructure/API translate each to `IFlatWireClient`
> - [ ] ⚠ **No SignalR type is referenced from `FlatWire.Application`** — `[SVC §3.2]`'s rule is satisfied, not worked around
> - [ ] `WipRejection` clearing a `Blocked` bay goes **via a domain event**, not by reaching into the `RodStaging` aggregate
>
> **Rate-card basis:** dispatcher wiring + ~5 translation handlers @ 8 h (§2) — the dispatcher itself is inherited
> **Dependencies:** FW-207, FW-142, FW-080

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The aggregates that raise the events | [`FW-207`](FW-207-Domain-Model.md) |
| `FlatWireDbContext` and its `SaveEntitiesAsync` hook | [`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) |
| `IFlatWireClient` and its payloads | [`FW-149`](FW-149-IFlatWireClient.md) |
| The hub the handlers send through | [`FW-080`](FW-080-FlatWireHub.md) |

---

## 2. The three-step flow

`[SVC §3.2c]`, and each step has a rule attached:

| # | Step | Rule |
|---|---|---|
| 1 | The **aggregate** raises the event via the inherited `AddDomainEvent` | In `FlatWire.Domain`. **Do not raise from a handler** — the aggregate knows the state changed; the handler only asked |
| 2 | **`FlatWireDbContext` dispatches after commit** | ⚠ **After `SaveChangesAsync`, never before.** Dispatching first broadcasts a state the database may still reject |
| 3 | A handler in **Infrastructure/API** translates to `IFlatWireClient` | **Not in Application** — that is the whole point |

### 2.1 The five events

`RunPaused` · `WeldRecorded` · `CoilCompleted` · `BayStateChanged` ·
`SpoolCompletionPromptRaised`

### 2.2 ⚠ `WipRejection` clears a blocked bay **by publishing**, not by reaching

`[SVC §3.2a]`: `WipRejection` is *"the only thing that clears a `Blocked` bay — publishes a
domain event rather than reaching into `RodStaging`."*

This is the acceptance criterion most likely to be quietly violated, because reaching into
the other aggregate is shorter and works. It breaks the aggregate boundary: two roots would
share a transaction's worth of internal state, and `Blocked` is a **derived** condition
(`Staged` + any inspection `Fail`), not a field to clear.

The chain: `POST /wipreject` → `WipRejection` raises `BayStateChanged` → a handler updates
`RodStaging` and broadcasts `PayoffStateChanged` — which
[`FW-150`](FW-150-Broadcast-Loop.md) sends **immediately, never in the batch**.

### 2.3 The dispatcher is inherited but not reusable

`MediatorExtension.DispatchDomainEventsAsync` exists in `CoilCheckin.Infrastructure` — and it
is **strongly typed to the concrete context**, so it must be **recreated** against
`FlatWireDbContext` ([`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) step 2). It scans
`ChangeTracker.Entries<Entity>()` for entities with events, clears them, and publishes each
through MediatR.

**Inherit the pattern; do not write a new dispatcher.**

---

## 3. Build order

1. Confirm `FW-142`'s `MediatorExtension` retyped to `FlatWireDbContext`, and that
   `SaveEntitiesAsync` calls it **after** `SaveChangesAsync`.
2. Define the five events in `FlatWire.Domain/Events/` as MediatR `INotification`s.
3. Raise them from the aggregates ([`FW-207`](FW-207-Domain-Model.md)) via `AddDomainEvent`.
4. Write ~five translation handlers **in Infrastructure or API**, each mapping one event to
   one `IFlatWireClient` call.
5. Wire the `WipRejection` → `BayStateChanged` → `RodStaging` chain per §2.2.
6. **Verify the layering by reference, not by intention** — `P-34`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-33` precede this story.

### `P-34` — prove the SignalR-free Application layer by project reference

AC 4 is a **negative** — *"no SignalR type is referenced from `FlatWire.Application`"* — and
negatives are what silently regress. With backend tests withdrawn (`[TS §1.2]`) nothing
mechanical guards it.

**Make the layering structural rather than disciplinary:** `FlatWire.Application`'s `.csproj`
carries **no** SignalR package reference and no reference to the API project, so a handler
that reaches for `IHubContext` **fails to compile**. That is a stronger guarantee than a
review note, costs nothing, and matches how [`FW-205`](FW-205-ITInhibitService.md) `P-25`
enforces its own absence.

Then add a one-line QA0 check — `grep` `FlatWire.Application` for `SignalR` and
`IHubContext`, expecting zero — so a future package addition is caught at review.

### `P-35` — translation handlers live in Infrastructure

`[SVC §3.2c]` says *"a handler in Infrastructure/API"* and leaves the choice open. **Put
them in Infrastructure**, beside the repositories and the context whose commit triggers them.

Reasoning: they are dispatched by `FlatWireDbContext`, which is Infrastructure's; the API
project is already the composition root and adding runtime behaviour there blurs it; and
Infrastructure may hold no business rules (`[SVC §3.2]`) — a translation from a domain event
to a hub call is not one.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| AC | How it is checked |
|---|---|
| Aggregates raise the five events | Each raised via the inherited `AddDomainEvent`, from the aggregate |
| **Dispatch after commit** | Force a `SaveChangesAsync` failure — **no event is broadcast**. The check that matters |
| Handlers translate to `IFlatWireClient` | One handler per event; no magic-string sends |
| **No SignalR in Application** | `grep` returns zero **and** the `.csproj` cannot reference it *(`P-34`)* |
| `WipRejection` clears via event | The bay clears and `PayoffStateChanged` broadcasts, with **no direct call** into `RodStaging` |
| `PayoffStateChanged` timing | Immediate, **never** inside the ~100 ms batch |

---

## 6. Handoff

This is what lets every later phase's command handlers have side effects without a hub
reference — Phases 4 through 9 all rely on it. `FW-150` delivers what these handlers send.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`G38`** | `SpoolCompletionPromptRaised` is the durable one — persisted to `FlatWireRun`'s five prompt columns, **never held in memory** ([`FW-080 §3.3`](FW-080-FlatWireHub.md)) |
| **`G21`** | `Blocked` is **derived**, never stored — so `BayStateChanged`'s handler recomputes it rather than clearing a flag |
| **`D-30`** | `WipRejection` is one of the three roots without a `ROWVERSION` token, and it is mutated after insert |

No stale citations in this card.
