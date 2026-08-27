# FW-208 · Domain events and post-commit dispatch

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — ✅ **EXECUTED (steps 1–7, 9, 10): the dispatch mechanism is built and the defect is fixed — domain events now reach handlers.** 3 new files, 8 amended, **0 errors, no new analyzer warning**. Verified by harness on live `FlatWireDB`: lane routing with the raw event reaching **neither** lane, both lanes dispatching in-transaction-then-broadcast, the bay **actually released** inside the rejection's transaction, a failed commit **broadcasting nothing**, and `WLD010`. `FW-207`'s 137 checks still pass; the API still boots. ⛔ **Step 8 stays blocked** — `IFlatWireClient` does not exist (`FW-080`). ⛔ **Three defects only execution could find.** **(1)** `INotificationHandler<>` was **never registered** by the Scrutor scan and Infrastructure's assembly was not scanned — a handler would compile, look registered and never resolve, making `Publish` a silent no-op; **the third such trap in this one story**. **(2)** The in-transaction lane could not see a sibling aggregate's identity: `CK_RodStaging_RejectLink` needs `WipRejectionId`, and at drain time the rejection is `Added` with `Id = 0` — so **`P-94`'s order is revised to save → drain → save → commit** (two saves, one transaction). **(3)** `BayStateChanged` **had to be split** — a notification four other call sites raise cannot carry a rejection link, so the release was unwritable: **`P-98`**, `BayReleaseRequested`. Two events also gained `OperatorId`, and `ConsumeAtCheckIn` a `checkedInBy`. Earlier the same day: ⚠ **Re-reviewed before execution: `P-96`'s lane mechanism was NOT IMPLEMENTABLE and is corrected by `P-97`.** `mediator.Publish` invokes **every** registered handler for a notification type (MediatR 12.4.1, no per-call selection), so two handlers on one raw event cannot be separated at publish time — the broadcast would have fired **pre-commit**, the exact failure the two lanes exist to prevent. The lane is now a notification **type** (`InTransaction<TEvent>` / `PostCommit<TEvent>`), so routing is the compiler's job. Also corrected in that pass: **`SaveEntitiesAsync` cannot be deleted** (it is an `IUnitOfWork` obligation, so route it through the same hook), the **build order put classification after the mechanism** that depends on it, and **`PayoffStateChanged` is a name for an unbuilt interface member** — confirm it against `FW-149` rather than inventing it. Earlier the same day: ⚠ **Reviewed against the built code, and the central instruction was wrong. Four decisions minted `P-94`–`P-97`.** ⛔ **The finding that changes everything: no domain event is dispatched at all on the path a command actually takes.** `SaveEntitiesAsync` is the only method that dispatches and **nothing calls it**; `TransactionBehaviour` wraps every command and commits through `CommitTransactionAsync`, which calls the plain, **un-overridden** `SaveChangesAsync`. So every event `FW-207` raises is **silently dropped today** — and this plan's build order step 1 could not notice, because it checks the wrong method (`P-95`). ⛔ **AC 2 is also wrong and acting on it would break transactional integrity:** the built context dispatches **before** `SaveChangesAsync` *deliberately* (option A, so in-transaction handlers enlist in the same transaction), and its own remark says *"`FW-208` owns POST-COMMIT dispatch … **do not reorder this method** — `FW-208` adds a second, post-commit path."* ⛔ **And that second path cannot be a second call**: the inherited dispatcher **clears the events before publishing**, so a post-commit re-scan finds an empty change tracker. It must be **capture-then-replay across two lanes** (`P-94`), which is a mechanism to design — contradicting this card's *"not a mechanism to design"* premise. Also: **six events, not five** (`FW-207` added `RunResumed`); **AC 1 and steps 2–3 are already delivered** by `FW-207`; **§2.3's "must be recreated" is done** (`FW-142` built `FlatWire.Infrastructure/MediatorExtension.cs`); **AC 3 is not buildable** — `IFlatWireClient` and `FlatWireHub` exist in no checkout; and **`G38` is closed** by `FW-207`. Earlier: August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **BUILT — 27 Aug 2026, steps 1–7, 9 and 10.** The dispatch mechanism is in `ual-api`: the two lane wrappers, capture-then-replay hooked into `CommitTransactionAsync`, `SaveEntitiesAsync` routed through the same hook, and the two in-transaction handlers. **3 new files, 8 amended, 0 errors, no new analyzer warning.** Verified by harness against live `FlatWireDB` — lane routing, both lanes dispatching in the right order, the bay actually released inside the rejection's transaction, a rollback broadcasting nothing, and `WLD010`. `FW-207`'s 137 checks still pass. ⛔ **Step 8 — the BROADCAST handlers — remains blocked**: `IFlatWireClient` still does not exist (`FW-080`, `P-22`). ⚠ **Three defects found on execution**: `INotificationHandler<>` was never registered, the in-transaction lane could not see a sibling's identity (`P-94`'s order revised), and `BayStateChanged` had to be split (`P-98`). Earlier: ⚠ partly blocked and not "ready" as written — at that point **nothing dispatched at all**, which this story has now fixed.
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-208`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

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
>
> ⛔ **That last sentence was checked against the built code on 27 Aug 2026 and it is wrong.**
> Both pieces do exist, and neither gives this story what it needs:
>
> **(1) Nothing dispatches.** `SaveEntitiesAsync` is the only method that calls the dispatcher, and
> **no caller anywhere invokes it.** `TransactionBehaviour` wraps every command and commits through
> `CommitTransactionAsync`, which calls the plain, **un-overridden** `SaveChangesAsync`. So the six
> events `FW-207` raises are collected on the entities and **thrown away**. `P-95`.
>
> **(2) The inherited dispatcher clears before publishing** — `ClearDomainEvents()` runs on every
> tracked entity *before* the publish loop — so "call it again after commit" finds an empty change
> tracker. The post-commit path must **capture and replay**. `P-94`.
>
> **(3) One lane is not enough.** `BayStateChanged` must update `RodStaging` *inside* the
> transaction and broadcast *outside* it. Those are opposite requirements and cannot be one handler
> on one path. `P-96`.
>
> **The wiring is the story.** The handlers are the easy half, and only the BROADCAST half of them
> is blocked on a hub that does not exist — the in-transaction handlers are buildable now, and they
> are the half whose loss would leave a bay blocked forever. ⚠ **No hour cell is restated** — the 8 h basis
> reads *"the dispatcher itself is inherited"*, which is true of the pre-commit drain and not of the
> post-commit lane; that is owed to the re-baseline.

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

> ### ⛔ Corrections to the card above — it is quoted verbatim and is NOT amended in place
>
> The card is `[TB §7]`'s and stays as written; these are the standing corrections, restated in §7.
>
> **AC 2 — *"`FlatWireDbContext.SaveChangesAsync` calls `DispatchDomainEventsAsync` after commit —
> never before"* is wrong twice over.** The dispatching method is **`SaveEntitiesAsync`**, not
> `SaveChangesAsync` (which is EF's own and is **not overridden**); and it dispatches **before** the
> save *on purpose*, so handlers sharing the scoped context enlist in the same transaction. The
> context's own remark forbids the reorder this AC asks for. **Both orders are needed, on two
> lanes** — `P-94`.
>
> **AC 1 is already delivered.** `FW-207` defined the events in `FlatWire.Domain/Events/RunEvents.cs`
> and raises them from the aggregates via `AddDomainEvent` (27 Aug 2026). **Six, not five** — it
> added `RunResumed`, because a resume is a broadcast-worthy state change and the four resume
> outcomes are recorded on it.
>
> **AC 3 is not buildable yet.** `IFlatWireClient` and `FlatWireHub` **exist in no `ual-api`
> checkout**. `FW-080` mints the interface (`P-22`) in wave 2; this story is wave 3.
>
> **AC 5 is delivered on the raising side and outstanding on the receiving side.** `WipRejection`
> already publishes rather than reaching — `FW-207` built `WipRejection.ReleaseBay(...)`, which
> raises `BayStateChanged` and touches no `RodStaging`. **What is missing is the handler**, and it
> is two handlers, not one — `P-96`.

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
| 1 | The **aggregate** raises the event via the inherited `AddDomainEvent` | In `FlatWire.Domain`. **Do not raise from a handler** — the aggregate knows the state changed; the handler only asked. ✅ **Built by `FW-207`** |
| 2 | **`FlatWireDbContext` dispatches** | ⚠ **On TWO lanes, not one** — see §2.0. In-transaction handlers run **before** the save so they enlist in it; broadcasts run **after the commit succeeds**. The card's *"after commit, never before"* is right about broadcasts and wrong as a blanket rule (`P-94`) |
| 3 | A handler in **Infrastructure/API** translates to `IFlatWireClient` | **Not in Application** — that is the whole point (`P-35`). ⛔ Blocked: the interface does not exist yet |

### 2.0 ⚠ Two lanes, and why one is not enough — `P-94`

**The card asks for a single post-commit dispatch. That cannot serve both kinds of handler**, and the
built context already committed to the other half:

| Lane | When | For | Why it must be there |
|---|---|---|---|
| **In-transaction** | **before** `SaveChangesAsync` — the drain `SaveEntitiesAsync` already performs | handlers that **write the database**, e.g. `BayStateChanged` updating `RodStaging` | They enlist in the same transaction, so the whole set commits or fails together. Move this after the commit and a crash between commit and handler leaves a bay **blocked forever**, with no compensating action |
| **Post-commit** | **after** `transaction.CommitAsync()` succeeds | handlers that **broadcast**, i.e. every `IFlatWireClient` call | A broadcast for a transaction that then rolls back tells nine operators a lie the database will never agree with. This is the lane the card is really asking for |

⛔ **The post-commit lane cannot be a second call to `DispatchDomainEventsAsync`.** The inherited
dispatcher runs `ClearDomainEvents()` on every tracked entity **before** the publish loop — for a
good reason, so a handler touching the same entity cannot re-raise into the batch being drained — so
by the time a commit returns, **there is nothing left to find**. The events must be **captured**
during the drain and **replayed** afterwards.

### 2.1 The six events

`RunPaused` · **`RunResumed`** · `WeldRecorded` · `CoilCompleted` · `BayStateChanged` ·
`SpoolCompletionPromptRaised`

⚠ **Six, not the card's five** — `FW-207` added `RunResumed` on 27 Aug 2026, and it carries the
`Outcome` (one of the **four** resume outcomes, of which Rod Checkout is the fourth) plus the pause
duration. All six are in `FlatWire.Domain/Events/RunEvents.cs` as `sealed record … : INotification`,
carrying **values, not entities** — a post-commit handler must not touch an entity whose context has
moved on.

### 2.2 ⚠ `WipRejection` clears a blocked bay **by publishing**, not by reaching

`[SVC §3.2a]`: `WipRejection` is *"the only thing that clears a `Blocked` bay — publishes a
domain event rather than reaching into `RodStaging`."*

This is the acceptance criterion most likely to be quietly violated, because reaching into
the other aggregate is shorter and works. It breaks the aggregate boundary: two roots would
share a transaction's worth of internal state, and `Blocked` is a **derived** condition
(`Staged` + any inspection `Fail`), not a field to clear.

✅ **The raising side is built.** `FW-207` delivered `WipRejection.ReleaseBay(station, position, rod,
releasedAt)`, which raises `BayStateChanged` and touches no `RodStaging`. **What is outstanding is
the handler.**

⛔ **And it is TWO handlers, not one — `P-96`.** The chain as this section stated it —
*"a handler updates `RodStaging` **and** broadcasts `PayoffStateChanged`"* — merges two effects with
opposite transactional requirements into one method, and it cannot be correct on either lane:

| Effect | Lane | What goes wrong on the other lane |
|---|---|---|
| Update `RodStaging` — release the bay | **in-transaction** | Post-commit, a crash between the commit and the handler leaves the bay **blocked forever**. The rejection is committed; the release is not; nothing retries |
| Broadcast `PayoffStateChanged` | **post-commit** | In-transaction, a later rollback has already told every DB2A screen the bay is free. The operators act on it; the database never agrees |

So: `POST /wipreject` → `WipRejection` raises `BayStateChanged` →
**`BayStateChangedStateHandler`** (in-transaction) releases the staged row via
`RodStaging.Unstage(...)` → commit → **`BayStateChangedBroadcastHandler`** (post-commit) sends
`PayoffStateChanged`, which [`FW-150`](FW-150-Broadcast-Loop.md) sends **immediately, never in the
~100 ms batch**.

⚠ **`Blocked` is derived, so the state handler does not "clear a flag"** — it calls
`RodStaging.Unstage(...)`, which sets `Status = 'Unstaged'`, and `IsBlocked` stops being true because
the row is no longer `Staged`. There is no field to clear (`G21`).

### 2.3 The dispatcher — ✅ built, and it has one property that decides this story's design

`DispatchDomainEventsAsync` is **strongly typed to the concrete context**, so it cannot be shared
across services and had to be recreated for `FlatWireDbContext`. ✅ **`FW-142` did that** — it is
`FlatWire.Infrastructure/MediatorExtension.cs`, and its own remarks say it is a deliberate no-op
until something raises an event. *(This section previously read "it must be recreated"; that was true
on 15 Aug and was done on 27 Aug. Build order step 1a now verifies rather than instructs.)*

⛔ **The property that matters — read the body before designing the post-commit lane:**

```csharp
domainEntities.ForEach(entity => entity.Entity.ClearDomainEvents());   // ← clears FIRST
foreach (INotification domainEvent in domainEvents)
{
    await mediator.Publish(domainEvent);
}
```

**It clears every entity's events before publishing any of them.** That is correct for the
in-transaction lane — a handler touching the same entity cannot re-raise into the batch being drained
— and it is exactly why the post-commit lane **cannot re-scan the change tracker**. `domainEvents` is
a local list; once the method returns, it is gone.

**Inherit the pattern; do not write a new dispatcher** — but do **capture** what it drains (`P-94`).

---

## 3. Build order

⛔ **Step 1 as originally written would have broken transactional integrity.** It read: *"Confirm
`FW-142`'s `MediatorExtension` retyped to `FlatWireDbContext`, and that `SaveEntitiesAsync` calls it
**after** `SaveChangesAsync`."* The first half is now done and merely verified; **the second half was
an instruction to reorder a method whose own remarks forbid reordering**, and following it would have
moved the in-transaction handlers out of the transaction. It is replaced by steps 1a–1c.

⚠ **The order below was itself corrected on 27 Aug 2026.** Classification used to come *after* the
mechanism, and it cannot: the dispatcher's shape depends on knowing which events go on which lane.
~~Define the events~~ and ~~raise them from the aggregates~~ are struck outright — ✅ **both
delivered by `FW-207`**, six events in `Domain/Events/RunEvents.cs`, raised via `AddDomainEvent`.

1. **Verify what is already there** *(no code)*. `FlatWire.Infrastructure/MediatorExtension.cs`
   exists and is typed to `FlatWireDbContext` ✅. It **clears before publishing** ✅ — read the body,
   because the whole post-commit design turns on that. `FW-207`'s six events exist ✅ and the
   aggregates raise them ✅. Note `SaveEntitiesAsync` is on **`IUnitOfWork`**, so it stays.
2. **Classify all six events by lane** — `P-96`'s table. **Do this before writing the dispatcher**,
   not after: an event with no lane either broadcasts a lie or never lands, and the dispatcher cannot
   be written without the answer.
3. **Declare the lane wrappers** — `InTransaction<TEvent>` and `PostCommit<TEvent>` (`P-97`). This is
   what makes MediatR route the two lanes to different handlers; without it, `Publish` runs both
   handlers pre-commit and the broadcast fires before the commit.
4. ⛔ **Hook the path a command actually takes.** `SaveEntitiesAsync` dispatches and **nothing calls
   it**; `TransactionBehaviour` → `CommitTransactionAsync` → the plain **un-overridden**
   `SaveChangesAsync` is the real path, and it dispatches nothing. **Until this is fixed every event
   `FW-207` raises is silently dropped.** `P-95` puts the hook in `CommitTransactionAsync`.
   ⚠ **Do not** make `TransactionBehaviour` call `SaveEntitiesAsync` instead — that abandons the
   transaction the behaviour opened. ⚠ **Do not** override `SaveChangesAsync` — `CommitTransactionAsync`
   calls it mid-commit, so the drain would run before the commit it is meant to follow.
5. **Capture and replay** (`P-94`). Drain once; publish the `InTransaction<>` wrappers immediately so
   handler writes join the same `SaveChanges`; hold the `PostCommit<>` wrappers in a **local** until
   `CommitAsync()` returns, then publish them. Observe all five properties — in particular that the
   post-commit publish sits **outside** the `try`, or a failing broadcast triggers
   `RollbackTransaction()` against a committed transaction.
6. **Route `SaveEntitiesAsync` through the same hook** so the two entry points cannot diverge
   (`P-95`).
7. **Write the in-transaction handlers** — buildable **now**, and they are the half that must not be
   lost: `BayStateChanged` → `RodStaging.Unstage(...)`, and `WeldRecorded` → mark the incoming rod
   welded, ⚠ only when `QualityPassed` (`WLD010`). Neither touches SignalR, so neither is blocked.
8. ⛔ **Write the broadcast handlers in Infrastructure** (`P-35`), one per post-commit-lane event.
   **Blocked**: `IFlatWireClient` does not exist — `FW-080` mints it (`P-22`), and `P-35` holds only
   if it lands in `FlatWire.Domain`. Steps 1–7 are the deliverable until then, and they are the
   substance of the story.
9. **Verify the layering by reference, not by intention** — `P-34`. ✅ Already true today:
   `Application.csproj` references only `Domain.csproj` and carries no SignalR package.
10. **Prove something actually fired** — the harness route of §5, because no endpoint reaches an
    aggregate. A wrong implementation broadcasts **nothing on either path** and reads as a pass.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder. This story owns **`P-34`**, **`P-35`** and
> **`P-94`**–**`P-98`**; `P-01`–`P-33` precede it and `P-36`–`P-93` were minted after it by other
> plans in the folder. New decisions mint at **`P-99`+**.

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

⚠ **Confirmed viable on 27 Aug 2026, and one condition makes it so.** Infrastructure can hold a
broadcast handler **only because `IFlatWireClient` lives in `FlatWire.Domain`** — `[SVC §3.2]`'s
layer table puts it there, beside the repository interfaces. The handler depends on the interface;
DI supplies the API-side `IHubContext<FlatWireHub, IFlatWireClient>` implementation. **If `FW-080`
lands the interface in the API project instead, `P-35` becomes unbuildable** and the handlers move to
API — so check where it lands before writing them.

⚠ **The in-transaction handlers are the same decision for a different reason.** A state handler needs
a repository (`IRodStagingRepository`), which is Infrastructure's; putting it in API would make the
composition root do data access.

### `P-94` — two lanes, and the post-commit lane is **capture-then-replay**, not a second scan

**The card's single post-commit dispatch cannot serve both kinds of handler**, and the built context
had already chosen the other half deliberately: `SaveEntitiesAsync` drains **before**
`SaveChangesAsync` so handlers sharing the scoped context enlist in the same transaction, and its
remarks say in terms that `FW-208` *"adds a second, post-commit path"* rather than reordering it.

**So: two lanes.** §2.0 has the table. Database-writing handlers run in-transaction; broadcasting
handlers run after `CommitAsync()` returns.

⛔ **THE ORDER IS REVISED ON EXECUTION (27 Aug 2026): save → drain → save → commit**, not
drain → save → commit. An in-transaction handler that references a sibling aggregate created by
the same command needs that aggregate's **surrogate**, and EF assigns identities at `SaveChanges` —
before it, a newly `Added` row has `Id = 0`. The concrete failure: `BayReleaseHandler` must set
`RodStaging.WipRejectionId`, because `CK_RodStaging_RejectLink` requires it whenever
`UnstageKind = 'WipRejection'`, and the rejection is inserted by the command that raised the event.
Draining first made the link unknowable and the commit died on the CHECK constraint. **Two saves,
one transaction — atomicity is unaffected**, because both sit inside the explicit transaction that
`CommitAsync` commits. Neither ordering is safe for the other kind — one leaves
a bay blocked forever after a crash, the other broadcasts a state the database rejects.

⛔ **And the post-commit lane must CAPTURE, because the dispatcher clears.**
`DispatchDomainEventsAsync` calls `ClearDomainEvents()` on every tracked entity **before** its publish
loop, so after the drain the change tracker holds nothing to dispatch. A post-commit re-scan finds an
empty list and publishes nothing — **silently**, which is the worst failure mode available. Buffer
the drained events, publish the in-transaction subset at once, hold the rest until the commit
returns.

**Five properties the implementation must have.** *(1)* A **rollback publishes nothing** — the
buffer is discarded on the failure path. *(2)* The buffer is **cleared before a retry**:
`TransactionBehaviour` runs inside `CreateExecutionStrategy()`, so its body can execute more than
once on a transient fault, and a surviving buffer would double-broadcast. ⚠ **Make the buffer a
local, not a field** — then both properties hold structurally instead of by remembering to clear.
*(3)* A post-commit handler **must not touch a tracked entity** — the events carry values only
(`FW-207` built them as records of alphas and primitives), and this is why.

*(4)* ⚠ **The post-commit publish sits OUTSIDE the `try`.** `CommitTransactionAsync`'s `catch` calls
`RollbackTransaction()`; if a broadcast throws from inside that `try`, the rollback runs against a
transaction that has **already committed**. A failing SignalR send must never attempt to undo
committed material — log it and move on. The material is on the floor either way; the screens
recover on the next refresh.

*(5)* ⛔ **Decide what happens to an event an IN-TRANSACTION handler raises, because today it is
dropped silently.** The drain clears before publishing, so anything raised *during* the
in-transaction lane is still sitting on the change tracker when the lane finishes, and a single-pass
drain never looks again. **This is not hypothetical** — `BayStateChanged` is raised in **five**
places (four in `RodStaging`, one in `WipRejection`), and the WIP-rejection chain hits it directly:

> `WipRejection.ReleaseBay` raises `BayStateChanged` → the in-transaction handler calls
> `RodStaging.Unstage(...)` → **which raises `BayStateChanged` a second time** → the drain has
> already run, so event #2 is never dispatched.

**The behaviour is correct today by luck**, not design: the broadcast fires from event #1, so the
screens update. But the next in-transaction handler that raises something the broadcast lane needs
will lose it, with no symptom.

**Take the simple option and write it down: one pass, and handler-raised events are NOT dispatched.**
An in-transaction handler that needs a broadcast should be **subscribed to the event it already
has** rather than raising a new one. ⚠ **Do not "fix" this with a drain loop** — `Unstage` raising
the same event the handler reacts to is a cycle, and a loop would either spin or need a depth cap
chosen arbitrarily. ⚠ **And do not delete the duplicate raise from `RodStaging.Unstage`**: the
pre-check-out path unstages a bay *without* a rejection, and there that event is the only one raised
— it fires before the drain and dispatches normally.

⚠ **Do not solve this by making the events durable.** An outbox table is the right answer to a
different question — guaranteed delivery across a process crash — and it is not in MVP-1's scope,
budget or schema. A dropped broadcast is recovered by the operator refreshing; the **state** lane is
what must not be lost, and it is transactional precisely so it cannot be.

### `P-95` — hook the path a command actually takes: `CommitTransactionAsync`

⛔ **This is the defect the story exists to fix, and the card does not mention it.** As built:

| Method | Dispatches? | Called by |
|---|---|---|
| `SaveEntitiesAsync` | ✅ yes — the only one | ⛔ **nothing, anywhere** |
| `SaveChangesAsync` | ❌ no — **not overridden**, it is EF's own | `CommitTransactionAsync` |
| `CommitTransactionAsync` | ❌ no | `TransactionBehaviour`, on every command |

**So every event `FW-207` raises is collected and thrown away.** The pre-commit lane is not merely
mis-ordered; it never runs.

**The hook goes in `CommitTransactionAsync`**, which is where the commit boundary actually is: drain
into the buffer, `SaveChangesAsync()`, `transaction.CommitAsync()`, then replay the broadcast lane.
That places both lanes on the one path `TransactionBehaviour` drives.

⚠ **Two tempting alternatives, both wrong.** Making `TransactionBehaviour` call `SaveEntitiesAsync`
instead abandons the transaction the behaviour opened. Overriding `SaveChangesAsync` to dispatch puts
side effects on a method that EF itself calls internally and that `CommitTransactionAsync` calls
mid-commit — the drain would run before the commit it is supposed to follow.

⚠ **`SaveEntitiesAsync` cannot simply be deleted, and this plan previously implied it could.** It is
declared on **`UA.Framework.Domain.Uow.IUnitOfWork`**, which `FlatWireDbContext` implements — so it
is a framework contract obligation, not dead code somebody forgot. It has no caller because
`TransactionBehaviour` drives the transaction API instead. **Route it through the same hook** so both
entry points behave identically; a second dispatching method that behaves differently is how this
defect would come back.

### `P-97` — the lane is a TYPE: `InTransaction<T>` and `PostCommit<T>`

⛔ **Forced by MediatR's semantics, not chosen for elegance.** `Publish` invokes every registered
handler for a notification type, so two handlers on one raw event cannot be separated at publish
time (`P-96`). The lane has to be visible to MediatR's routing, which means it has to be in the type:

```csharp
public sealed record InTransaction<TEvent>(TEvent Event) : INotification where TEvent : INotification;
public sealed record PostCommit<TEvent>(TEvent Event) : INotification where TEvent : INotification;
```

A state handler implements `INotificationHandler<InTransaction<BayStateChanged>>`; a broadcast
handler implements `INotificationHandler<PostCommit<BayStateChanged>>`. The dispatcher publishes the
`InTransaction<>` wrapper during the drain and buffers the `PostCommit<>` wrapper for after the
commit. **Routing is then the compiler's job**, and a handler cannot end up on the wrong lane —
which is the same reasoning as `P-34` proving the SignalR-free layer by project reference rather
than by review note.

**The one wrinkle: the dispatcher closes the generic at run time.** It drains `INotification`s whose
concrete type is only known then, so it needs
`typeof(PostCommit<>).MakeGenericType(evt.GetType())` and MediatR's `Publish(object)` overload. That
is a handful of lines in one place, and it should **cache the closed types** — a `MakeGenericType`
per event per commit is avoidable overhead on a 10 Hz-adjacent path.

⚠ **Two alternatives considered and rejected, both for reasons worth recording.**

**Resolve and filter handlers manually** — `GetServices(typeof(INotificationHandler<>)…)`, filter by
a marker interface, invoke directly. It avoids the wrappers but **reimplements the part of MediatR
that pipeline behaviours hook into**, so `LoggingBehavior` and anything later added stop seeing
domain-event handlers. Rejected.

**Let broadcast handlers self-defer** — publish once pre-commit and have each broadcast handler
enqueue its `IFlatWireClient` call into a scoped queue flushed after commit. Fewer moving parts, and
**rejected because it is a discipline rather than a guarantee**: a handler author who sends directly
gets a pre-commit broadcast and no compile error. That is exactly the class of failure `P-34` and
`P-90` were written to avoid.

### `P-96` — every event is assigned a lane, and `BayStateChanged` gets both

An event with no lane either broadcasts a lie or never lands, so the assignment is written down here
rather than inferred per handler:

| Event | Lane | Handler does |
|---|---|---|
| `RunPaused` | post-commit | broadcast the pause to the line's screens |
| `RunResumed` | post-commit | broadcast the resume and its outcome |
| `WeldRecorded` | **both** | **in-transaction:** mark the incoming rod welded on its staged row — ⚠ only when `QualityPassed` (`WLD010`); a failed weld records the event and leaves the flag clear. **post-commit:** broadcast |
| `CoilCompleted` | post-commit | broadcast; the coil row is already written by its own aggregate |
| `BayStateChanged` | **both** | **in-transaction:** release the bay via `RodStaging.Unstage(...)`. **post-commit:** broadcast `PayoffStateChanged`, immediately and never in the batch |
| `SpoolCompletionPromptRaised` | post-commit | broadcast the prompt. ⚠ The prompt is **already durable** — `FW-207` persists it to `FlatWireRun`'s five prompt columns, so a missed broadcast is recovered by a refresh (`G38`) |

⚠ **`WeldRecorded` and `BayStateChanged` each need two handler classes, not one handler doing two
things.**

⛔ **Correction, 27 Aug 2026 — this decision previously said the lane is "decided by which
dispatcher publishes it… key it off the handler's marker interface". THAT IS NOT IMPLEMENTABLE**, and
the reason is the first thing to understand before writing the dispatcher. **`mediator.Publish(evt)`
invokes EVERY registered `INotificationHandler<TEvent>`** — MediatR 12.4.1 offers no per-call handler
selection. So if both handlers subscribe to `BayStateChanged` and the drain publishes it, **the
broadcast handler runs pre-commit**, which is precisely the failure the two lanes exist to prevent.
A marker interface on the handler cannot help: by the time `Publish` returns, both have run.

**The lane must therefore be part of the notification TYPE, not a property of the handler** —
`P-97`.

### `P-98` — split the release REQUEST from the state NOTIFICATION: `BayReleaseRequested`

⛔ **Forced by a CHECK constraint, not chosen for elegance.** The earlier review raised the overload
as an open item and said a distinct event *"would remove the guards"*. Execution proved it is
**required**: `CK_RodStaging_RejectLink` demands `WipRejectionId` whenever
`UnstageKind = 'WipRejection'`, so the release must record which rejection caused it — and
`BayStateChanged` is raised by **four other call sites in `RodStaging`**, none of which has a
rejection. A notification shared by five origins cannot carry a field meaningful to one.

**The two types now say different things, and the distinction is command versus notification:**

| | `BayReleaseRequested` | `BayStateChanged` |
|---|---|---|
| Means | *"release that bay"* | *"a bay changed"* |
| Raised by | `WipRejection.ReleaseBay` | `RodStaging` — `Stage`, `MarkWelded`, `ConsumeAtCheckIn`, `Unstage` |
| Carries | the rejection's **business** key, and the operator | the new state, and the operator |
| Lane | **in-transaction** (it is a write) | **post-commit** (it is a broadcast) |

**Two consequences worth knowing.** The handler no longer needs the origin and state guards the
earlier design required — the event means exactly one thing. And it carries the **business** key
rather than the surrogate, because at raise time the rejection is `Added` with `Id = 0`; the handler
resolves the surrogate through `IWipRejectionRepository`, which works **only** because `P-94`'s
revised order assigns identities before the lane runs. ⚠ **Revert that order and this lookup returns
null and the release silently stops happening** — the handler therefore throws a named exception
rather than unstaging without the link.

⚠ **The four `RodStaging` raises are unchanged and still needed.** The pre-check-out path unstages a
bay with no rejection at all, and its `BayStateChanged` is the only event raised there.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

> ⛔ **Two of these rows cannot be run through an endpoint, for the same reason `FW-207 §6` records:
> every service is a stub or a `NotImplementedException`, so no request reaches an aggregate, and no
> aggregate raises an event during a walkthrough.** `FW-207` solved it by driving the aggregates
> directly in a throwaway harness; **do the same here** — the dispatch rows are exactly the kind that
> read green when nothing fired at all.

| AC | How it is checked |
|---|---|
| Aggregates raise the **six** events | ✅ **Already done** — `FW-207`, verified. Not this story's to re-check |
| ⛔ **Anything dispatches at all** | **Run a command end to end and assert a handler ran.** This is the row the card is missing and the one that fails today: nothing calls the dispatching method (`P-95`). Check it *first* — every row below is meaningless while it fails |
| **In-transaction lane** | A state handler's write and the command's own write are in **one** transaction: force a failure *after* the handler and confirm **both** roll back |
| **Post-commit lane** | Force a `SaveChangesAsync`/`CommitAsync` failure — **no broadcast is sent**. ⚠ And the converse, which is the trap: on success **a broadcast IS sent**. The clear-before-publish behaviour means a wrong implementation sends nothing on either path and looks like it passed (`P-94`) |
| **Retry safety** | `TransactionBehaviour` runs inside an execution strategy. Force a transient fault so the body re-executes, and confirm **one** broadcast, not two (`P-94`) |
| Handlers translate to `IFlatWireClient` | One handler per broadcast-lane event; no magic-string sends. ⛔ Blocked until `FW-080` mints the interface |
| **No SignalR in Application** | `grep` returns zero **and** the `.csproj` cannot reference it *(`P-34`)*. ✅ True as of 27 Aug 2026: `Application.csproj` references only `Domain.csproj` and carries no SignalR package |
| `WipRejection` clears via event | ✅ raising side built (`FW-207`). Outstanding: the bay clears **in the transaction** and `PayoffStateChanged` broadcasts **after** it, with **no direct call** into `RodStaging` from the rejection |
| `PayoffStateChanged` timing | Immediate, **never** inside the ~100 ms batch |
| Every event has a lane | The six-row table in `P-96` is complete, and adding a seventh event forces a choice rather than defaulting |

### 5.1 ✅ Executed 27 Aug 2026 — steps 1–7, 9 and 10

**Built on `ual-api` branch `feature/UADEV-23146`: 3 new files, 8 amended, 0 errors, no new analyzer
warning** (13 solution-wide, all pre-existing).

| Step | Delivered |
|---|---|
| **1** verify | `MediatorExtension` typed to the context ✅, clears before publishing ✅, six events raised ✅ |
| **2** classify | `P-96`'s table, and it changed on execution — see `P-98` |
| **3** wrappers | `Domain/Events/DispatchLanes.cs` — `InTransaction<TEvent>` / `PostCommit<TEvent>` |
| **4** hook | `CommitTransactionAsync` now dispatches. ⛔ **Before this, nothing did** |
| **5** capture/replay | `DispatchInTransactionAndCaptureAsync` + `PublishDeferredAsync`, closed generics cached |
| **6** `SaveEntitiesAsync` | routed through the same hook; no-ops its drain when a transaction is open, so the commit boundary owns dispatch |
| **7** in-transaction handlers | `BayReleaseHandler`, `WeldMarkHandler` — both in `Infrastructure/EventHandlers/` (`P-35`) |
| **9** layering | ✅ re-verified: `Application.csproj` references only `Domain.csproj`, no SignalR package |
| **10** proof | harness below |
| ⛔ **8** broadcast handlers | **NOT built** — `IFlatWireClient` still does not exist (`FW-080`) |

**Verified by harness, because no endpoint reaches an aggregate. All checks passed.**

| What | Result |
|---|---|
| Lane routing (`P-97`) | ✅ `InTransaction<>` reaches only the in-transaction handler, `PostCommit<>` only the broadcast handler, and **the raw event reaches neither** — so nothing can subscribe to an undefined lane |
| Dispatch happens at all | ✅ `CommitTransactionAsync` ran both lanes against live `FlatWireDB` — **the defect `P-95` names is fixed** |
| Order | ✅ `intx:release` **before** `post:release`, asserted on sequence and not on counts |
| The handler's real effect | ✅ bay `FL1PO/1` released — `Status='Unstaged'`, attributed to the rejection's operator — committed in the **same** transaction as the rejection |
| ⛔ Rollback | ✅ a failed commit **broadcast nothing**, and the write rolled back with it |
| `WLD010` | ✅ a failed weld does **not** mark the rod; a passing one does, stamps the operator, and a redelivery does **not** overwrite the first stamp |
| No regression | ✅ `FW-207`'s harness still **137/137**; API boots, `/health` `200` with `database.reachable: true`, `/lines/status` `401` |

> ### ⛔ Three defects execution found that no review would have
>
> **(1) `INotificationHandler<>` was not registered — and neither was Infrastructure's assembly.**
> The Scrutor scan in `ApplicationConfiguration` covered the five **request** handler shapes and
> nothing else, and `AddCommonApplication()` was called with no extra assemblies. So a notification
> handler would compile, look registered, and never resolve: `Publish` finds zero handlers and
> **completes successfully having done nothing**. Both fixed — the generic added to the scan, and
> `Program.cs` now passes the Infrastructure assembly. **This is the third silent no-op in one
> story**, after the missing hook and the clear-before-publish trap.
>
> **(2) The in-transaction lane could not see a sibling aggregate's identity, so `P-94`'s order is
> REVISED.** `CK_RodStaging_RejectLink` requires `WipRejectionId` whenever
> `UnstageKind = 'WipRejection'`, and the rejection being linked to is inserted by the very command
> that raised the event — at drain time it is `Added` with `Id = 0`. Draining before the save made
> the link unknowable and the commit died on the CHECK constraint. **The order is now save → drain →
> save → commit**: identities first, both saves inside the one transaction, atomicity unchanged.
>
> **(3) `BayStateChanged` had to be split — `P-98`.** The open item raised in the earlier review said
> a distinct release event "would remove the guards"; execution proved it is **required**, not
> cosmetic. A notification four other call sites also raise cannot carry a rejection link, so the
> release was unwritable. `BayReleaseRequested` now carries the rejection's **business** key and the
> handler resolves the surrogate — which works only because of (2).

⚠ **Two events gained `OperatorId`** — `BayStateChanged` and `WeldRecorded`. `Unstage` needs
`unstagedBy` and `MarkWelded` needs `weldedBy`; both DDL columns mean a person, and neither event
carried one, so a handler had nothing truthful to pass. `RodStaging.ConsumeAtCheckIn` gained a
`checkedInBy` parameter for the same reason. **These are `FW-207`'s files**, edited here for the same
reason `FW-146`'s arm was edited by `FW-207`: the consumer is what proves the surface incomplete.

⚠ **One pre-existing failure seen during the boot check and deliberately not touched:** `/health`
answers `500` on some early polls with a `TaskCanceledException` from `HttpClient` — the OPC check
timing out against an `API.OPCConnection` that is not running locally. That is `P-87`/`G9`, not this
story.

---

## 6. Handoff

This is what lets every later phase's command handlers have side effects without a hub
reference — Phases 4 through 9 all rely on it. `FW-150` delivers what these handlers send.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **Nothing dispatches** *(new, 27 Aug 2026)* | `SaveEntitiesAsync` is the only dispatching method and **has no caller**; `TransactionBehaviour` commits through `CommitTransactionAsync` → the un-overridden `SaveChangesAsync`. **Every event `FW-207` raises is dropped.** `P-95` — and it is this story's first task, before any handler |
| **`IFlatWireClient` / `FlatWireHub` do not exist** *(new, 27 Aug 2026)* | Verified absent from `ual-api`. `FW-080` mints the interface (`P-22`, wave 2); this story is wave 3. **AC 3 and build step 7 are blocked**; steps 1a–6 are not, and they are the substance |
| ~~**`G38`**~~ ✅ | **Closed by `FW-207`.** `FlatWireRun` carries the five prompt columns and `RaiseCompletionPrompt`/`ResolveCompletionPrompt` persist against them, verified on the live schema — so `SpoolCompletionPromptRaised` is **already durable** and a missed broadcast is recovered by a refresh. *(This row read "persisted … never held in memory" as an obligation; it is now a fact.)* |
| **`G21`** | `Blocked` is **derived**, never stored — so the state handler calls `RodStaging.Unstage(...)` rather than clearing a flag. ⚠ *This row said the handler "recomputes it"; it does not recompute anything* — `IsBlocked` simply stops being true once the row is no longer `Staged` |
| **`D-30`** | `WipRejection` is one of the three roots without a `ROWVERSION` token, and it is mutated after insert. ⚠ Sharper here than elsewhere: the in-transaction state handler mutates `RodStaging`, which **does** have a token, from an event raised by an aggregate that does **not** — so a lost update on the rejection is invisible while the bay release is protected |
| **`P-35` depends on where `FW-080` puts the interface** | Handlers can live in Infrastructure **only if `IFlatWireClient` lands in `FlatWire.Domain`** as `[SVC §3.2]`'s layer table says. If it lands in the API project, the handlers move there |
| ⛔ **`Publish` invokes EVERY handler** *(new, 27 Aug 2026)* | MediatR **12.4.1** offers no per-call handler selection, so two handlers on one raw event cannot be separated at publish time — the broadcast would fire pre-commit. `P-96`'s original *"key it off the handler's marker interface"* was **not implementable** and is corrected; `P-97` puts the lane in the notification **type** instead |
| ⚠ **`SaveEntitiesAsync` is an `IUnitOfWork` obligation** *(new, 27 Aug 2026)* | It cannot be deleted — `UA.Framework.Domain.Uow.IUnitOfWork` declares it and `FlatWireDbContext` implements it. It has no caller only because `TransactionBehaviour` drives the transaction API. **Route it through the same hook** rather than leaving two dispatching methods that can diverge (`P-95`) |
| ⚠ **`PayoffStateChanged` is named but does not exist** | The broadcast §2.2 describes is an `IFlatWireClient` member, and that interface is unbuilt. Confirm the member name against `FW-149` before writing the handler rather than inventing it here |
| ⚠ **`BayStateChanged` is raised in five places** *(new, 27 Aug 2026)* | Four in `RodStaging` (`Stage`, `MarkWelded`, `ConsumeAtCheckIn`, `Unstage`) and one in `WipRejection.ReleaseBay`. The rejection chain therefore raises it **twice** — once by the rejection, once by the `Unstage` its own handler calls — and the second is **dropped silently** because the drain has already run. Correct today by luck, not design; `P-94` property (5) settles the policy. **An in-transaction handler should subscribe to the event it already has rather than raise a new one** |

| Stale | Correct | Source |
|---|---|---|
| AC 2: *"`SaveChangesAsync` calls `DispatchDomainEventsAsync` **after commit** — never before"* | The method is **`SaveEntitiesAsync`** (`SaveChangesAsync` is not overridden), it dispatches **before** the save deliberately, and **both orders are needed on two lanes** | `P-94`, `FlatWireDbContext` remarks |
| Build step 1: *"confirm `SaveEntitiesAsync` calls it **after** `SaveChangesAsync`"* | **An instruction to reorder a method whose remarks forbid it** — replaced by steps 1a–1c | `P-95`, `FW-142` |
| *"the five events"* / *"~five translation handlers"* | **Six** — `FW-207` added `RunResumed` | `FW-207 §6.1` |
| §2.3: *"it must be **recreated** against `FlatWireDbContext`"* | ✅ **Done** — `FlatWire.Infrastructure/MediatorExtension.cs` | `FW-142` |
| *"This is wiring … **not a mechanism to design**"* | The post-commit lane **is** a mechanism: capture-then-replay across two lanes, hooked into the real commit path | `P-94`, `P-95` |
| §2.2: *"a handler updates `RodStaging` **and** broadcasts"* | **Two handlers** — the effects have opposite transactional requirements | `P-96` |
| *"`P-01`–`P-33` precede this story"* | Still true, but the folder now runs to **`P-96`**; new decisions mint at `P-97`+ | `Orchestration.md §4a` |
| ~~*"No stale citations in this card."*~~ | **Struck 27 Aug 2026** — there were six, listed above | this review |
