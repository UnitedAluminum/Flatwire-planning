# FW-139 · MediatR registration and pipeline behaviours

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-139`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Three things about MediatR here are not what a developer
> expects. **(1)** UAL does not call `AddMediatR` — registration is a **Scrutor assembly
> scan**, and the one place it is copied from contains a bug that double-registers a
> handler. **(2)** Two of the three pipeline behaviours already exist in the framework and
> must not be rewritten; the third **cannot be inherited** because it binds to a concrete
> `DbContext`. **(3)** `[SVC §3.2]` forbids SignalR types in Application, which is what
> forces command side-effects through domain events rather than a hub call in the handler.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-139 · MediatR registration and pipeline behaviours
> **Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** developer,
> **I want** MediatR wired with validation and logging behaviours,
> **So that** every command gets cross-cutting concerns without repeating them.
>
> **Acceptance Criteria:**
> - [ ] `Commands/` and `Queries/` folders per `04-APIContract.md`
> - [ ] MediatR registered in `Program.cs` (copied from `CoilCheckin.API/Program.cs`)
> - [ ] Pipeline behaviours for validation and structured logging
> - [ ] A sample command round-trips controller → MediatR → handler → envelope
>
> **Rate-card basis:** cross-cutting infrastructure (16 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** —

*(`04-APIContract.md` was absorbed into `Backend/APIs.md` on 13 Aug 2026 — read `[API §3.2]`/`[API §4]`.)*

### 1.1 In scope

`Commands/` and `Queries/` folders · the Scrutor registration · the behaviour pipeline ·
a `FlatWireDbContext`-bound `TransactionBehaviour` · one sample command proving the round trip.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The controllers the commands are reached through | [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) |
| Service registration and the stub/real swap | [`FW-140`](FW-140-DI-Registration-And-Stub-Swap.md) |
| `FlatWireDbContext` itself — **`TransactionBehaviour` needs it** (§5 `P-10`) | [`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) |
| The validators the validation behaviour invokes | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) |
| Domain events raised inside handlers | `FW-208` |
| Real commands and queries | Phases 3–9 |

---

## 2. Precedence and traps

| Question | Authority |
|---|---|
| Where commands, queries and behaviours live | `[SVC §3.1]`, `[SVC §3.2]` |
| What Application must **not** contain | `[SVC §3.2]` — EF `DbContext` types, HTTP types, **SignalR types** |
| Validation split — behaviour vs aggregate | `[SVC §3.4]`, `phase-01b` L94 |
| The registration pattern | `[ARC §2.2]` — `CoilCheckin` is binding for MediatR wiring |

### 2.1 UAL does not use `AddMediatR`

`CoilCheckin.API/Extensions/ApplicationConfiguration.cs` registers handlers with a **Scrutor
scan**:

```csharp
services.Scan(scan => scan
    .FromAssemblies(assemblies)
    .RegisterHandlers(typeof(IRequestHandler<,>))
    .RegisterHandlers(typeof(IRequestPreProcessor<>))
    .RegisterHandlers(typeof(IRequestPostProcessor<,>))
    .RegisterHandlers(typeof(IRequestExceptionHandler<,,>))
    .RegisterHandlers(typeof(IRequestExceptionAction<,>)));
```

with `RegisterHandlers` in `HandlerExtensionRegistry.cs` using
`RegistrationStrategy.Append` · `AsImplementedInterfaces()` · `WithScopedLifetime()`.
`IMediator` itself is registered in `DependencyInjectionRegistry.AddPersistence`
(`services.AddScoped<IMediator, Mediator>()`).

> ⚠ **`RegistrationStrategy.Append` makes duplicate handlers a live hazard, and the template
> has one.** `CoilCheckin` declares `GetCoilsQueryHandler` **twice** — once nested inside
> `GetCoilsQuery.cs` and again as a standalone `GetCoilsQueryHandler.cs` in a second
> namespace — both handling the same request. Append registers both. **Nest every handler
> inside its command/query and never create a standalone handler file**, which is also
> `ual-api`'s own C# instruction.

### 2.2 Handlers are nested; commands are records

`CoilCheckin`'s shape, which is the binding one:

```csharp
public sealed record CoilCheckinCommand(CoiCheckinlDetails Model) : IRequest<bool>
{
    internal class CoilCheckinCommandHandler : IRequestHandler<CoilCheckinCommand, bool>
    { … }
}
```

### 2.3 No SignalR in Application — and this is what forces domain events

`[SVC §3.2]` bars SignalR types from Application, which leaves a command handler no clean
way to broadcast. `[SVC §3.2c]` answers it: the aggregate raises a domain event, the context
dispatches **after commit**, and a handler in Infrastructure/API translates to
`IFlatWireClient`. **The rule is satisfied, not worked around.** That is `FW-208`; build
nothing here that reaches for `IHubContext`.

---

## 3. Target layout

```
FlatWire.Application/
├── Commands/          one folder per endpoint family, per [API §4]
├── Queries/
└── BusinessRules/     concrete rules (Domain/Rules/ holds reusable specifications)
FlatWire.API/
└── Behaviors/         TransactionBehaviour.cs  ← domain-local, see P-10
```

`FW-N04` created these empty. `[SVC §3.1]` places pipeline behaviours in Application; the
one behaviour that **must** live in `FlatWire.API` is the transactional one, because it
takes the concrete context — see `P-10`.

---

## 4. Build order

1. **Add the assembly marker.** A single `public interface IApplicationMarker {}` (or the
   first real query type) in `FlatWire.Application`, so the scan has an anchor that does not
   move.
2. **Bootstrap in `FlatWire.API`,** not Infrastructure — `FW-N04` decision `P-02`. Port
   `AddCommonApplication` + `HandlerExtensionRegistry` from `CoilCheckin.API/Extensions/`.
3. **Register `IMediator`** — `services.AddScoped<IMediator, Mediator>()`.
4. **Register the two inherited behaviours** (order matters — logging outermost):
   ```csharp
   services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
   services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidatorBehavior<,>));
   ```
   Both are in `UA.Framework.API/Application/Behaviors/`. **Do not write new ones.**
   `ValidatorBehavior` injects `IEnumerable<IValidator<TRequest>>`, aggregates
   FluentValidation failures and throws `CustomException` wrapping a `ValidationException` —
   which is what `FW-146` maps to `400`.
5. **Write `FlatWire.API/Behaviors/TransactionBehaviour.cs`** — copy from
   `UATemplate.API/Behaviors/`, retype to `FlatWireDbContext`. Register it **after** the
   other two. See `P-10` for sequencing against `FW-142`.
6. **Create the `Commands/` and `Queries/` folder skeleton** matching `[API §4]`'s families.
7. **One sample command** proving controller → MediatR → handler → envelope. Use a real
   contract shape so it is not thrown away — `GET /lines/status` (`[API §4.1]`) is the
   smallest.

---

## 5. Decisions this plan makes

> `P-##` is **continuous across this folder**. `P-01`–`P-05` are in
> [`FW-N04`](FW-N04-FlatWire-Solution-Skeleton.md), `P-06`–`P-08` in
> [`FW-138`](FW-138-Fifteen-Thin-Controllers.md).

### `P-09` — Scrutor scan, not `AddMediatR`

`[ARC §2.2]` binds `CoilCheckin` for MediatR wiring, and the repo's central package manifest
carries `MediatR` 12.4.1 with the Scrutor 5.0.1 scan on top. Keep it. Consistency with the
other eleven services is worth more here than the ergonomics of `AddMediatR`, and the
handler-registration semantics differ in ways that would surprise a maintainer.

*(Note: `UATemplate`'s own `Directory.Packages.props` — deleted by `FW-N04` step 3 — pinned
the **legacy** `MediatR.Extensions.Microsoft.DependencyInjection` 9.0.0. If a `dotnet new`
scaffold left it behind, that is the file that should have gone.)*

### `P-10` — `TransactionBehaviour` lands with `FW-142`, not here

**Sequencing, not scope.** `TransactionBehaviour` cannot be inherited from the framework: the
`UATemplate` and `OPCConnection` copies both take the **concrete** context in their primary
constructor, so FlatWire needs its own bound to `FlatWireDbContext` — which `FW-142` creates.

**Build the other two behaviours and the registration now; land the transactional one when
`FW-142` merges.** It skips transactions when the request type name contains `Query`, then
`CreateExecutionStrategy()` → `BeginTransactionAsync()` → `CommitTransactionAsync()`.

⚠ This story's `Dependencies` reads `FW-N04` only, which is true for everything except this
behaviour. Do not treat the missing `DbContext` as a blocker on the whole story.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. Verified in the QA0 manual walkthrough.

| AC | How it is checked |
|---|---|
| `Commands/` and `Queries/` folders | Present, matching `[API §4]` families |
| MediatR registered | The sample command resolves and executes at runtime |
| Validation + logging behaviours | A deliberately invalid request produces the `ValidatorBehavior` path; the log shows `----- Handling command …` / `----- Command … handled` |
| Sample command round-trips | Controller → MediatR → handler → envelope, returning `[API §1.2]`'s shape |

Plus, and this is the one worth doing deliberately: **assert exactly one handler is
registered per request type.** Resolve `IEnumerable<IRequestHandler<TSample, TResponse>>` at
startup and confirm a single entry — the Append strategy makes a duplicate silent until it
throws at dispatch.

---

## 7. Handoff

`FW-147` supplies the validators `ValidatorBehavior` invokes. `FW-146` maps the exceptions
these behaviours throw. `FW-142` completes `P-10`. `FW-208` adds the post-commit dispatch
that makes handler side effects reach the hub.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`P-10`** | The transactional behaviour is blocked on `FW-142`; the rest is not |
| **`P-02`** *(inherited)* | The bootstrap lives in `FlatWire.API`. If that decision is reversed, it moves to Infrastructure and `Infrastructure → Application` returns |

| Stale | Correct | Source |
|---|---|---|
| The AC cites **`04-APIContract.md`** | Absorbed into `Backend/APIs.md` on 13 Aug 2026 | `[GAP]`, the `ProjectPlan/` restructure |
| Copying `CoilCheckin.API/Program.cs` wholesale | It registers **no** `IPipelineBehavior` at all, has no `UseSerilog`, and carries the duplicate-handler bug | §2.1; `FW-N04` step 6 |
