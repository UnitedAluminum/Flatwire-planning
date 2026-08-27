# FW-139 · MediatR registration and pipeline behaviours

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — ⚠ **The validator count is fourteen, not thirteen** — corrected in **six** places here from the `FW-147` review. The 25 Aug count missed `UnstageRodRequestValidator` (`POST /staging/rod/unstage`, `[API §4.5a]`); `RequestValidators.cs` holds fourteen `AbstractValidator<>` classes. **`P-59` and its argument are unaffected** — the bridge applies to all fourteen and none is rewritten. ⚠ Note also that **`P-59`’s bridge is not reachable from an endpoint yet**: `StageRodCommand` exists, but `PayoffStagingController` still calls its service directly, so every validator exercised from an endpoint today runs on `P-60`’s **model-binding** gate — §6.1’s behavioural proof was taken through `IMediator` directly and stands as taken. Also corrected: §6.1 and §8 named that endpoint **`POST /payoff/stage`**, which exists nowhere — the route is **`POST /staging/rod`** (`[API §4.5]`, and `PayoffStagingController`’s own attribute). Earlier: August 25, 2026 — ✅ **BUILT.** The Scrutor scan, both inherited behaviours and the `P-59` bridge are live in `ual-api`; `GET /lines/status` is de-stubbed through MediatR (`P-61`); §6.1 carries the measured verification, including the pipeline order read off the log and the **one AC that cannot be performed on a developer machine as configured** — the service has no Console sink. Earlier the same day — ⚠ **corrected against the code that now exists.** `LoggingBehavior`/`ValidatorBehavior` **do** exist in the framework - a note added earlier the same day claimed they did not, and it is retracted in the conformance block. Step 3 now verifies `P-51`'s `IMediator` registration instead of duplicating it; step 4 records that `ValidatorBehavior` resolves on the **command**, not the DTO; step 7 and **`P-59`** bridge the fourteen built validators; **`P-60`** keeps both validation gates until the de-stub completes; **`P-61`** makes the sample command the first real de-stub *(previously August 15, 2026 — first issue)*
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **BUILT and verified on the running service, 25 Aug 2026** (§6.1) — the `P-59` bridge is proven *behaviourally*, not merely registered: an empty `StageRodCommand` is rejected in the pipeline and seven of `StageRodRequestValidator`'s rules fire through the delegation. `P-61` is applied and is the first entry in the `FW-N12` de-stub ledger
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
> ### ⚠ Coding standard — read `[SVC §3.4a]` before writing code
>
> The repository C# standard binds every `.cs` file here, and `[SVC §3.4a]` records the **four
> standing divergences** so they are not re-litigated in review. What this story owns:
>
> **Validation is auto-validated at model binding today, not behind the pipeline** (`P-57`), and
> the fourteen validators it runs are **already built** — `FlatWire.Application/Validators/`.
> Moving them behind the pipeline means **registering the framework's `ValidatorBehavior`**
> (§4 step 4) and **bridging the validators to the commands** (§4 step 7, `P-59`). Both gates then
> coexist until the de-stub pass completes — `P-60`.
>
> ⚠ **Correction, 25 Aug 2026.** This block previously said *"there is no such behaviour anywhere
> in `ual-api` to copy; only `TransactionBehaviour` exists."* **That is wrong** — `LoggingBehavior`
> and `ValidatorBehavior` both exist at `UA.Framework.API/Application/Behaviors/`, exactly as §4
> step 4 has always said, and that step's *"Do not write new ones"* stands. The claim came from a
> filename search for `ValidationBehavio*r*` (the framework's is `Validator`Behavior) followed by a
> truncated result list read as an absence.


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

The Scrutor registration · the two inherited behaviours · the command/validator bridge (`P-59`) ·
the per-family `Commands/` and `Queries/` subfolders · one sample command proving the round trip.

⚠ **The `FlatWireDbContext`-bound `TransactionBehaviour` is in scope but NOT buildable yet** -
`P-10` lands it when `FW-142` merges. This line previously listed it flatly, which reads as
*build it now* and cannot compile: there is no context to bind.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The controllers the commands are reached through | [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) |
| Service registration and the stub/real swap | [`FW-140`](FW-140-DI-Registration-And-Stub-Swap.md) |
| `FlatWireDbContext` itself — **`TransactionBehaviour` needs it** (§5 `P-10`) | [`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) |
| ~~The validators the validation behaviour invokes~~ - ⚠ **BUILT 25 Aug 2026**, **fourteen** of them in `FlatWire.Application/Validators/`. This story does not write them; it **bridges** them to the commands (`P-59`) | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) |
| Retiring the model-binding gate once every endpoint has a handler (`P-60`) | `FW-N12` / `[API §7.3]` |
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
(`services.AddScoped<IMediator, Mediator>()`) - **in `CoilCheckin`. FlatWire does it in
`Program.cs` instead** (`P-51`), because this story's behaviours and `FW-138`'s controllers both
need the mediator before there is any persistence to hang it off. See step 3.

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

1. **Add the assembly marker.** A single `public interface IApplicationMarker {}` in
   `FlatWire.Application`, so the scan has an anchor that does not move. *(The alternative -
   anchoring on the first real query type - is now `P-61`'s `GetLinesStatusQuery`. Either works;
   the marker is preferred because a type that moves or is renamed silently changes what the scan
   sees.)*
2. **Bootstrap in `FlatWire.API`,** not Infrastructure — `FW-N04` decision `P-02`. Port
   `AddCommonApplication` + `HandlerExtensionRegistry` from `CoilCheckin.API/Extensions/`.
3. **`IMediator` is already registered — verify, do not duplicate.** `FW-N04`'s **`P-51`** put
   `services.AddScoped<IMediator, Mediator>()` in `Program.cs` on 25 Aug 2026, because
   `AddControllersAsServices()` makes every controller a DI service and `Build()` validates them:
   fifteen `IMediator` constructors against no registration is a startup failure, and that is how
   the fault first presented. Adding a second descriptor for the same pair is exactly what `P-51`
   tells `FW-142` not to do.
4. **Register the two inherited behaviours** (order matters — logging outermost):
   ```csharp
   services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
   services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidatorBehavior<,>));
   ```
   Both are in `UA.Framework.API/Application/Behaviors/` — **verified present 25 Aug 2026**.
   **Do not write new ones.**
   `ValidatorBehavior` injects `IEnumerable<IValidator<TRequest>>`, aggregates
   FluentValidation failures and throws `CustomException` wrapping a `ValidationException` —
   which is what `FW-146` maps to `400`.

   ⚠ **`TRequest` is the COMMAND, not the request DTO — and this is the trap.** The fourteen
   validators are `AbstractValidator<StageRodRequest>` and friends. Resolving
   `IValidator<StageRodCommand>` finds **nothing**, the behaviour receives an empty collection,
   and **every command passes validation with no error and no log**. Step 7 closes it (`P-59`).
5. **`FlatWire.API/Behaviors/TransactionBehaviour.cs` — DEFERRED to `FW-142`, `P-10`.** It binds
   the concrete `FlatWireDbContext`, which does not exist yet, so it cannot be written here. When
   `FW-142` merges: copy from `UATemplate.API/Behaviors/`, retype, and register it **after** the
   other two so it is innermost. The folder is already there with a `.gitkeep`.
6. **Create the per-family `Commands/` and `Queries/` subfolders** matching `[API §4]`'s families.
   ⚠ The **top-level** `Commands/`, `Queries/` and `BusinessRules/` folders already exist -
   `FW-N04` created them and `Validators/` joined them on 25 Aug. Only the per-family subfolders
   are missing, which is what acceptance criterion 1 is asking for.
7. **Bridge the validators to the commands** — `P-59`. **This comes before the sample, not after:**
   without it step 4 is inert, and a sample command written first would demonstrate exactly the
   silent pass the callout above warns about. Every command lands with its validator in the same
   commit.
8. **One sample command** proving controller → MediatR → handler → envelope, returning
   `FlatWireResult<T>` (`P-56`). `GET /lines/status` (`[API §4.1]`) is still the smallest — but it
   is now a **built stub**, so the sample *replaces* `LinesFixtures.Status()` rather than filling a
   void. That makes it a de-stub: see **`P-61`**. Being a query it carries no validator, so pair it
   with one command from step 7 to exercise the `ValidatorBehavior` path.

---

## 5. Decisions this plan makes

> `P-##` is **continuous across this folder**. `P-01`–`P-05`, `P-50` and `P-51` are in
> [`FW-N04`](FW-N04-FlatWire-Solution-Skeleton.md); `P-06`–`P-08` and `P-52`–`P-58` in
> [`FW-138`](FW-138-Fifteen-Thin-Controllers.md). New decisions here mint at `P-59`.

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

### `P-59` - the command wraps the request DTO; its validator delegates

**Settled - minted 25 Aug 2026, and without it step 4 is inert.**

`ValidatorBehavior` resolves `IValidator<TRequest>` on the **command**. The fourteen built
validators target the **request DTOs**. Bridge them rather than rewriting them:

```csharp
public sealed record StageRodCommand(StageRodRequest Model) : IRequest<StageRodResponse>
{
    internal sealed class StageRodCommandHandler : IRequestHandler<StageRodCommand, StageRodResponse>
    { ... }
}

public sealed class StageRodCommandValidator : AbstractValidator<StageRodCommand>
{
    public StageRodCommandValidator() =>
        RuleFor(x => x.Model).SetValidator(new StageRodRequestValidator());
}
```

Three reasons this is the right shape and not a workaround:

- **It is `CoilCheckin`'s own** - `CoilCheckinCommand(CoiCheckinlDetails Model)`, section 2.2 - and
  `[ARC 2.2]` binds that template for the MediatR command pattern.
- **The C# standard asks for it**: *"a params/DTO object is forwarded whole to the repository, not
  destructured into individual arguments."*
- **All fourteen validators are reused unchanged**, so the shape rule keeps one definition.
  Rewriting them onto commands would leave every endpoint still on a stub with no validation until
  its command exists, and Phases 3-9 land them one at a time.

> ⚠ **A command with no validator is silently unvalidated** - the behaviour receives an empty
> collection and passes. Add the validator in the same commit as the command, and see section 6's
> registration assertion.

### `P-60` - both validation gates coexist until the de-stub completes

**Settled - 25 Aug 2026. This refines `P-57`; it does not reverse it.**

`AddFluentValidationAutoValidation()` and the envelope-shaping `InvalidModelStateResponseFactory`
stay in place while any endpoint is still a stub. Model binding runs **first**, so a migrated
endpoint never reaches the pipeline validator with a bad shape: no double error, only a redundant
registration, and both paths produce the same rule and the same `400`.

**Remove the model-binding gate only when the last endpoint has a handler** - the closing step of
the de-stub pass (`FW-N12`, `[API 7.3]`). Removing it earlier strips shape validation from every
endpoint still stubbed, which today is **all twenty-two**.

> ⚠ **The two gates fail differently and `FW-146` must handle both**: model binding produces the
> envelope directly through the factory, while `ValidatorBehavior` throws
> `CustomException`/`ValidationException` for the middleware to map. Same status, two routes.

### `P-61` - the sample command is the first real de-stub

**Settled - 25 Aug 2026.**

`GET /lines/status` is still the smallest round trip, but it is a **built stub**. So
`GetLinesStatusQuery` **replaces** the `LinesFixtures.Status()` call in `LinesController`, and
`LinesFixtures` is deleted with it - which is exactly what `P-08`'s per-controller seam exists to
make possible.

That makes the sample a de-stub rather than scaffolding: **record it as the first entry in
`FW-N12`'s ledger**, and note that it consumes DB1's seam ahead of Phase 3. A throwaway `PingQuery`
was rejected - the acceptance criterion asks for a round trip *through a controller*, and a query
that never routes through one does not give one.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. Verified in the QA0 manual walkthrough.

| AC | How it is checked |
|---|---|
| `Commands/` and `Queries/` folders | Present, matching `[API §4]` families |
| MediatR registered | The sample command resolves and executes at runtime |
| Validation + logging behaviours | A deliberately invalid request produces the `ValidatorBehavior` path; the log shows `----- Handling command …` / `----- Command … handled` |
| Sample command round-trips | Controller → MediatR → handler → envelope, returning **`FlatWireResult<T>`** (`P-56` - `data` · `success` · `errors[]` · `errorCode` as the int status · `errorDescription` as the `[API §1.8]` code) |
| **The bridge actually bites** (`P-59`) | Post the sample command with a deliberately invalid payload and confirm the **`ValidatorBehavior`** path runs - the `CustomException` log, not a model-binding 400. If the binding 400 comes back instead, resolve `IEnumerable<IValidator<TCommand>>` and check it is non-empty: an empty collection is the silent failure |
| **Both gates agree** (`P-60`) | The same invalid payload returns the same status and the same machine code whichever gate catches it |

Plus, and this is the one worth doing deliberately: **assert exactly one handler is
registered per request type.** Resolve `IEnumerable<IRequestHandler<TSample, TResponse>>` at
startup and confirm a single entry — the Append strategy makes a duplicate silent until it
throws at dispatch.

### 6.1 What the build actually verified — 25 Aug 2026

Built in `ual-api` at `API/Domain/FlatWire/`. Builds with **0 errors**; the warning set is
unchanged and pre-existing (`S112` in `ServiceLocator`/`HttpContextServiceProviderProxy`,
`NU1506`, and the SDK analyzer-version notice).

| AC | Result |
|---|---|
| `Commands/` and `Queries/` folders | ✅ `FlatWire.Application/Commands/PayoffStaging/`, `FlatWire.Application/Queries/Lines/` |
| MediatR registered | ✅ `AddCommonApplication()` in `Program.cs`; the Scrutor scan anchors on `IApplicationMarker`, not a query type, so a rename cannot break it |
| Exactly one handler per request type | ✅ asserted **at startup**, Development only — `GetLinesStatusQuery` resolves to exactly 1 |
| Logging behaviour | ✅ `----- Handling command GetLinesStatusQuery` / `----- Command GetLinesStatusQuery handled - response: {...}` |
| Validation behaviour | ✅ `----- Validating command StageRodCommand` then `WRN Validation errors - StageRodCommand` |
| **Behaviour order** | ✅ **read off the log, not assumed**: `Handling` (Logging, outermost) → `Validating` (Validator, inner) → `handled`. This is the order `RegisterPipelineBehaviours` registers them in, confirmed empirically |
| Sample command round-trips | ✅ `GET /lines/status` → `200`, three lines, `FlatWireResult<T>` envelope, enums as strings, **FL2 live gauge/width `null`** |
| **The bridge actually bites** (`P-59`) | ✅ and **behaviourally**, not structurally — see below |
| **Both gates agree** (`P-60`) | ⚠ **partly** — see below |
| No regression | ✅ the FW-138 probe passes **61/61** against this build, with all four step-5 behaviours intact |

**The `P-59` guard was made behavioural.** A registration count would still pass if a validator
bound the wrong type, so `Program.cs` now sends a deliberately **empty** `StageRodCommand`
through `IMediator` at startup (Development only) and **requires** the `CustomException`. It
fires: seven rules from `StageRodRequestValidator` — `Model.LineId`, `Model.PayoffPosition`,
`Model.RodAlpha`, `Model.DiameterIn`, `Model.GrossWeightLb`, `Model.NetWeightLb`,
`Model.Inspection` — reach the pipeline through the delegation. **If a future command is
shipped without its bridge validator, startup aborts with a named reason** instead of that
command validating nothing for the rest of the project.

**`P-60` is only partly demonstrable today, and the reason is `P-61`'s scope, not a defect.**
`StageRodCommand` is deliberately not wired to `PayoffStagingController` — `POST /staging/rod`
is Phase 4 — so no single request has traversed *both* gates. What is proven is that each gate
runs, and that they run **the same rules by construction**: `P-59` delegates to the very
`StageRodRequestValidator` the model-binding gate uses. The end-to-end comparison belongs to the
first de-stub of a **command** endpoint, and is owed to `FW-N12`.

> **⚠ The log-based ACs above cannot be performed on a developer machine as this service is
> configured, and that is a real gap rather than a quirk of one session.** `appsettings.json`
> declares two sinks — a **File** sink at `C:\inetpub\UAL\Logs\FlatWire\` (admin-only, and
> absent on a dev box) and **GrafanaLoki** at a dev server. There is **no Console sink**, so the
> service logs *nowhere visible* locally and every `-----` line above is invisible. They were
> obtained only by injecting `Serilog__WriteTo__2__Name=Console` as an environment variable at
> run time. **`Serilog.Sinks.Console` is already a `PackageReference` and its assembly is already
> in `bin`**, so the fix is a Console sink in `appsettings.Development.json` and nothing more —
> **owed to `FW-143`**, which owns logging.
>
> A second, smaller trap on the way to the same evidence: **`dotnet run` does not forward the
> application's stdout to a redirect** — it launches the built executable as a child process, so
> `dotnet run > log.txt` captures only the launcher's own line. Run
> `dotnet bin/Debug/net8.0/FlatWire.Api.dll` directly.

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
| **`P-51`** *(inherited)* | `IMediator` is registered in `Program.cs` already. Step 3 verifies it; **`FW-142` must drop the line from `AddPersistence`** rather than adding a second descriptor for the same pair |
| **The model-binding gate is owed a removal** | `P-60` keeps it until the last endpoint has a handler. That removal is `FW-N12`'s closing step and will not happen by itself - it needs a named owner, like the rest of the de-stub pass |
| **No Console sink** *(new, 25 Aug 2026)* | The service logs nowhere visible on a developer machine, which makes this plan's own log-based ACs unperformable without an environment override. `Serilog.Sinks.Console` is already referenced; the fix is a sink in `appsettings.Development.json`. **Owed to `FW-143`** |
| **`P-60` is not fully demonstrated** *(new, 25 Aug 2026)* | No request traverses both gates until a **command** endpoint is de-stubbed, because `POST /staging/rod` is Phase 4. **Owed to `FW-N12`** |

| Stale | Correct | Source |
|---|---|---|
| The AC cites **`04-APIContract.md`** | Absorbed into `Backend/APIs.md` on 13 Aug 2026 | `[GAP]`, the `ProjectPlan/` restructure |
| Copying `CoilCheckin.API/Program.cs` wholesale | It registers **no** `IPipelineBehavior` at all, has no `UseSerilog`, and carries the duplicate-handler bug | §2.1; `FW-N04` step 6 |
