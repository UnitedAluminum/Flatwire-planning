# FW-N04 · `FlatWire` solution and four-project Clean Architecture skeleton

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — **three §8.1 open items answered**: same-origin Angular/API on IIS (CORS), `C:\Nuget\Repo` confirmed, `G6` roles confirmed on `ClaimTypes.Role`
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-N04`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** The skeleton's requirements are correct and consistent
> across five specifications, but they nowhere sit together, and the binding rules are
> exactly the kind broken by a developer working from habit: `SlitterInterface` looks like
> the obvious template and is explicitly forbidden; `D-29` looks like it retires
> `CoilCheckin` and does not; the backlog card says "copied from `CoilCheckin`" while
> `ual-api` ships a `dotnet new` template that is a better `CoilCheckin`.
>
> This is the build order. It is derived from the specifications and **loses to every one
> of them** — where this document and a specification disagree, the specification wins and
> this document is corrected up to it.

---

## 1. The story

From `[TB §7]` — reproduced verbatim, because the acceptance criteria are the contract:

> ###### FW-N04 · `FlatWire` solution and four-project Clean Architecture skeleton
> **Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** developer,
> **I want** the `FlatWire` microservice solution created to the `CoilCheckin` pattern,
> **So that** every later phase adds commands and queries only.
>
> **Acceptance Criteria:**
> - [ ] `API/Domain/FlatWire/` with `FlatWire.sln` and four projects — `FlatWire.API` / `.Application` / `.Domain` / `.Infrastructure`
> - [ ] Project references: `API → Application, Domain, Infrastructure`; `Application → Domain`; `Infrastructure → Domain`
> - [ ] `.csproj` and NuGet set copied from `CoilCheckin`
> - [ ] `FlatWire.sln` builds; `FlatWire.API` boots under Development
>
> **Rate-card basis:** solution scaffold from an existing template (16 h, §2)
> **Dependencies:** None
> **Blockers:** —

**This is the root node of Phase 1B.** It is the only 1B story with `Dependencies: None`,
and thirteen others name it as theirs (`phase-01b` L194). Nothing on the backend starts
until it lands.

### 1.1 In scope

| # | Deliverable |
|---|---|
| 1 | `API/Domain/FlatWire/FlatWire.sln` + the four projects, with the `[SVC §3.1]` reference graph |
| 2 | The NuGet set reconciled against `CoilCheckin`, versions resolving from `API/Directory.Packages.props` |
| 3 | The `[SVC §3.1]` folder tree, created empty |
| 4 | `Program.cs` — a minimal pipeline that boots under Development |
| 5 | `appsettings.json` · `appsettings.Development.json` · `launchSettings.json` |
| 6 | **The fifteen controller shells** — class, attributes, `IMediator` constructor. **No actions, no stub fixtures** |
| 7 | IIS registration lines in the three deploy batch files |

### 1.2 Out of scope — and who owns each

Nothing below is forgotten; each has a story. **Do not build ahead into these.**

| Concern | Story | Hours |
|---|---|---|
| Endpoints on the fifteen controllers + stub fixtures | [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) | 45 h |
| MediatR handler registration + validation/logging pipeline behaviours | [`FW-139`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) | 16 h |
| DI registration and the stub/real service swap (`useMockData`) | [`FW-140`](FW-140-DI-Registration-And-Stub-Swap.md) | 12 h |
| The seven repositories | [`FW-141`](FW-141-Repository-Layer.md) | 28 h |
| `FlatWireDbContext` and Dapper data access | [`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) | 24 h |
| Serilog structured logging and the audit log | [`FW-143`](FW-143-Serilog-And-Audit-Log.md) | 12 h |
| Configuration binding, validated at startup | [`FW-144`](FW-144-Configuration-Binding.md) | 12 h |
| JWT authentication and role authorization policies | [`FW-145`](FW-145-JWT-And-Role-Policies.md) | 16 h |
| Global exception middleware and the response envelope | [`FW-146`](FW-146-Exception-Middleware-And-Envelope.md) | 8 h |
| FluentValidation, value objects, the canonical enums | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) | 12 h |
| Health checks | [`FW-148`](FW-148-Health-Checks.md) | 8 h |
| `FlatWireHub` | [`FW-080`](FW-080-FlatWireHub.md) | 28 h |
| The seven aggregate roots (`D-29`) | [`FW-207`](FW-207-Domain-Model.md) | 32 h |
| The typed event contract | [`FW-149`](FW-149-IFlatWireClient.md) | 16 h |
| OPC ingest + bounded channel | [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md) | 32 h |
| The broadcast loop | [`FW-150`](FW-150-Broadcast-Loop.md) | 16 h |
| `PLCTagService` + `SimulatePLCTagPush` | [`FW-151`](FW-151-PLCTagService.md) | 16 h |
| **`ITInhibitService`** — `phase-01b` **exit criterion 5** | [`FW-205`](FW-205-ITInhibitService.md) | 16 h |
| Domain events + post-commit dispatch | [`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) | 8 h |

> **Every one of `phase-01b`'s twenty stories now has a plan in this folder**, plus the two
> trial-scope stories [`FW-203`](FW-203-OPC-Feed-Simulator.md) and
> [`FW-218`](FW-218-Sim-Control-Surface.md) — twenty-two in all.
> `FW-206` (Phase 4) and `FW-N11` (uncosted) are the nearest neighbours without one.

> ⚠ **Item 6 above overlaps `FW-138`.** The controller *shells* are pulled forward into
> this story so the Angular stream has a stable base URL set from day one; `FW-138` keeps
> the endpoints, the envelope and the stub fixtures, which are the bulk of its 45 h.
> **No hour cell anywhere has been restated.** `[CE]`, `[DE]`, `[SSP]`, `[TRP]` and
> `[TB §7]`'s reconciliation all quote Phase 1B's 519 h derivation; re-deriving in place
> would desynchronise roughly twenty files. Re-baselining is a separate, additive exercise.

---

## 2. Precedence — which document wins on what

Read this before resolving any contradiction yourself.

| Question | Authority |
|---|---|
| Folder tree, project references, layering rules | `[SVC §3.1]`, `[SVC §3.2]` |
| What to copy, and what is forbidden | `[ARC §2.2]` + `D-06` |
| Domain-layer design (aggregates, value objects, events) | `D-29` — **and only the Domain layer** |
| Base URL, `UAController`, the response envelope | `[API §1.1]`, `[API §1.2]` |
| The fifteen controllers and their route prefixes | `[API §3.1]` |
| Roles | `[SEC §8]` — the six-role matrix of record |
| The deliverable row and the phase exit criteria | `phase-01b` L81, L171–177 |

### 2.1 The two rules most often broken

**`SlitterInterface` is not a reference.** `[ARC §2.2]`, decision `D-06`:

> `API/Domain/SlitterInterface` is explicitly NOT a reference — neither for UI/structure
> nor for the real-time / `CoilDataHub` pattern.

`OPCManagerHub.cs` is likewise not a hub template (`D-05`).

**`D-29` does not retire `CoilCheckin`.** `[SVC §3.1]`:

> ⚠ **`D-29` overrides only the Domain-layer half of `[ARC §2.2]`.** `CoilCheckin` remains
> the binding template for controllers, `Program.cs`, `.csproj`/NuGet, DI registration,
> MediatR wiring and pipeline behaviours. **Do not read this as "CoilCheckin is no longer
> the template."**

And, for the Domain layer that `D-29` *does* govern:

> **Inherit the framework bases. Do not write new ones** — if you are writing an `Entity`
> or `ValueObject` base class, you have missed the one in `UA.Framework.Domain`.

---

## 3. Target layout

From `[SVC §3.1]`, reproduced exactly:

```
API/Domain/FlatWire/
├── FlatWire.sln
├── FlatWire.API/            controllers (thin) + Hubs/FlatWireHub.cs + Program.cs + appsettings
├── FlatWire.Application/    Commands/ and Queries/ (MediatR), BusinessRules/, pipeline behaviors
├── FlatWire.Domain/         AggregatesModel/, ValueObjects/, Rules/, Events/, Repository/ (interfaces),
│                            Enums/, ParamModels/, Exceptions/, IFlatWireClient
└── FlatWire.Infrastructure/ Repositories/, Services/PLCTagService.cs, Context/FlatWireDbContext.cs
```

**This story creates every folder above and populates almost none of them.** What arrives
when:

| Folder | This story | Later |
|---|---|---|
| `FlatWire.API/Controllers/` | The fifteen shells | Endpoints — `FW-138` |
| `FlatWire.API/Hubs/` | empty | `FlatWireHub.cs` — `FW-080` |
| `FlatWire.API/Behaviors/` | empty | Pipeline behaviours — `FW-139` |
| `FlatWire.Application/Commands/`, `Queries/`, `BusinessRules/` | empty | From Phase 3 onward |
| `FlatWire.Domain/AggregatesModel/`, `ValueObjects/`, `Rules/`, `Events/` | empty | `FW-207` |
| `FlatWire.Domain/Repository/` | empty | Interfaces — `FW-141` |
| `FlatWire.Domain/Enums/` | empty | The 14 canonical enums — `FW-147` |
| `FlatWire.Infrastructure/Repositories/` | empty | The seven — `FW-141` |
| `FlatWire.Infrastructure/Context/` | empty | `FlatWireDbContext.cs` — `FW-142` |
| `FlatWire.Infrastructure/Services/` | empty | `PLCTagService.cs` — `FW-151` |

Keep empty folders in git with a `.gitkeep`.

> ⚠ **`IFlatWireClient` lives in `FlatWire.Domain`, not in the API project** — `[ARC §1.2]`,
> `[SVC §3.2]` and `phase-01b` L104 all agree. The hub class lives in
> `FlatWire.API/Hubs/`. Both arrive with `FW-080`; the split is recorded here because it
> is counter-intuitive and the folders are created now.

---

## 4. Build order

### Step 1 — scaffold from `UATemplate`, not from a copy of `CoilCheckin`

```bash
cd c:/UAL/ual-api/API/Domain
dotnet new ua-solution-template -n FlatWire
```

`API/UATemplate/` is a registered `dotnet new` template (`identity` `UA.Solution.Template`,
`shortName` `ua-solution-template`, `sourceName` `UATemplate`), and `ual-api`'s own
`CLAUDE.md` names it: *"Use `API/UATemplate/` as the canonical starting point when creating
a new domain."*

**This is a deliberate divergence from the card's wording and it is recorded as decision
`P-01` in §5.** `CoilCheckin` remains the binding reference for controller shape, the
MediatR command pattern and the NuGet set, exactly as `[ARC §2.2]` requires — only the
physical scaffold comes from the template. `UATemplate` is a cleaner `CoilCheckin`: it has
a `Behaviors/` folder, `builder.Host.UseSerilog(...)`, `<AssemblyName>` set, a top-level
`try`/`catch` with `Log.CloseAndFlushAsync()`, and `AddCustomHealthChecks` instead of a
method that shadows the framework's own `AddHealthChecks`.

Things `CoilCheckin` would have brought that you do not want, and would then have to
unpick: a `Dockerfile` targeting `dotnet/aspnet:6.0` and a `CoilCheckin.csproj` that does
not exist; `AutoMapper` referenced but never registered; a duplicate
`GetCoilsQueryHandler` in a second namespace that Scrutor's `RegistrationStrategy.Append`
registers twice; `wwwroot/` bootstrap and jquery boilerplate; and `<Compile Remove>` blocks
excluding three dead command folders.

### Step 2 — rename, and mint fresh GUIDs

Rename the four project folders and the `.sln` to `FlatWire.*`. Set in all four `.csproj`:

```xml
<AssemblyName>FlatWire.$(MSBuildProjectName)</AssemblyName>
```

> ⚠ **Generate new project GUIDs.** `UATemplate.sln` reuses `CoilCheckin.sln`'s four
> project GUIDs verbatim (`93B11B8C…`, `9BC6A8F5…`, `C7030743…`, `84AE1A67…`) and its own
> `SolutionGuid`. Carrying them into a third solution is a collision waiting to surface in
> tooling. Mint five new ones.

The solution's display names stay `Api` / `Application` / `Domain` / `Infrastructure`, as
in both templates; the `.csproj` file names likewise stay `Api.csproj`,
`Application.csproj`, `Domain.csproj`, `Infrastructure.csproj`.

> **Note:** `UATemplate/.template.config/template.json`'s `primaryOutputs` block is stale —
> it names `UATemplate.Appication/Appication.csproj` (missing `l`) and `API.csproj` where
> the folder actually holds `Api.csproj`. The `sources` block copies `**/*`, so
> instantiation still produces the correct tree; expect a warning, not a failure.

### Step 3 — delete the generated `Directory.Packages.props`

**Mandatory, and easily missed.** `UATemplate/` carries its own 30-line
`Directory.Packages.props` because it sits at `API/UATemplate/` and must be self-contained.
**No domain under `API/Domain/` has one** — they all inherit `API/Directory.Build.props`
and `API/Directory.Packages.props` (122 lines). Leaving the generated copy in place is not
a harmless duplicate; it actively conflicts:

| Package | UATemplate local | `API/Directory.Packages.props` |
|---|---|---|
| `AspNetCore.HealthChecks.UI.Client` | 9.0.0 | **8.0.1** |
| `Scrutor` | 5.1.1 | **5.0.1** |
| MediatR | `MediatR.Extensions.Microsoft.DependencyInjection` 9.0.0 *(legacy)* | **`MediatR` 12.4.1** |

and it omits **Serilog** (all seven packages), **Dapper**, **FluentValidation**, **Polly**,
`Microsoft.AspNetCore.Authentication.JwtBearer`, `Microsoft.EntityFrameworkCore.SqlServer`,
`UA.Framework.RestClient` and `UA.APIDTO` — every one of which the `CoilCheckin` NuGet set
or a later 1B story needs.

Delete `API/Domain/FlatWire/Directory.Packages.props` and let the repo-wide manifest apply.

### Step 4 — reference graph

Per `[SVC §3.1]` L36 and `phase-01b` L81:

```
API            → Application, Domain, Infrastructure
Application    → Domain
Infrastructure → Domain
Domain         → (nothing)
```

> ⚠ **This differs from `CoilCheckin`, and the specification wins.** See §5, decision
> `P-02` — `CoilCheckin.Infrastructure` references **Application**, and the reason it does
> has to be handled rather than ignored.

Set `TargetFramework` `net8.0`, `ImplicitUsings` and `Nullable` `enable` on the three
class-library projects, matching `CoilCheckin`. The web project carries no `PropertyGroup`
— it inherits from `API/Directory.Build.props`.

### Step 5 — NuGet set

Reconcile each `.csproj` against `CoilCheckin`'s, per the card's third acceptance
criterion. **Reference packages by name only, never with a version** — `API/Directory.Build.props`
sets `<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>`. Any package
FlatWire needs that is absent from `API/Directory.Packages.props` is added *there*.

The `CoilCheckin` set, by project:

| Project | Packages |
|---|---|
| **API** | `UA.Framework.API` · `UA.Framework.Common` · `UAL.Constants` · `Serilog.AspNetCore` · `Serilog.Enrichers.Environment` · `Serilog.Settings.Configuration` · `Serilog.Sinks.Console` · `Serilog.Sinks.File` · `Serilog.Sinks.Grafana.Loki` · `Scrutor` · `AutoMapper` · `Swashbuckle.AspNetCore` · `AspNetCore.HealthChecks.UI.Client` · `Microsoft.EntityFrameworkCore.Tools` |
| **Application** | `Microsoft.EntityFrameworkCore` · `UA.APIDTO` · `UA.Framework.RestClient` · `UAL.Constants` |
| **Domain** | `Microsoft.EntityFrameworkCore` · `UA.Framework.Common` · `UA.Framework.Domain` · `UAL.Constants` |
| **Infrastructure** | `Microsoft.EntityFrameworkCore` · `Microsoft.Extensions.Configuration.Json` · `UA.Framework.Infrastructure` · `UAL.Constants` |

`AutoMapper` is in `CoilCheckin`'s API project and never registered in its `Program.cs`; no
Flat Wire specification calls for it. **Carrying it is optional — omitting it is
defensible.** Nine analyzer packages are injected into every project by
`API/Directory.Build.props`; do not add them by hand.

> **The `UA.Framework.*` packages resolve from a local feed, not nuget.org.** They are
> `Version="1.0.0"` and built from source inside this repository
> (`API/Framework/UA.Framework.sln`, `API/Common/UAL.Constants`). There is no `nuget.config`
> in the repo — resolution relies on the machine-level `NuGet.Config` declaring the `UAL`
> source at **`C:\Nuget\Repo`**. ***Confirmed 15 Aug 2026.*** *(`ual-api`'s `CLAUDE.md`
> documents this as `D:\Nuget\Repo` and is simply wrong — the `.csproj` post-pack targets
> and the machine config both say `C:`, and so does the confirmation.)*
> If a later story needs a new `UA.Framework.*` API, budget for the full dance: pack →
> `nuget add` to the local source → clear `%HOMEPATH%\.nuget\packages\` → rebuild, because
> the version never bumps off `1.0.0`.

### Step 6 — `Program.cs`

Keep it minimal. The pipeline order below is `CoilCheckin`'s, which is the binding
reference, with the `UATemplate` improvements retained:

```
builder.Host.UseSerilog(...)                    ← from UATemplate; CoilCheckin lacks it
  AddCustomMvc()                                ← UAController + global AuthorizeFilter + CorsPolicy
  AddCustomSwagger(...)                         ← fed from Domain/Constants/Constants.cs
  AddCustomConfiguration(...)
  AddCustomAuthentication(...)
  AddCustomServices(...)
  AddCustomHealthChecks(...)                    ← NOT AddHealthChecks; see below
  AddControllers()
build
  UsePathBase(PATH_BASE)
  UseCors("CorsPolicy")
  UseMiddleware<CorrelationIdMiddleware>(...)
  UseAuthentication()
  UseSwagger().UseSwaggerUI(...)
  UseRouting()
  MapControllers()
await app.RunAsync()                            ← inside try/catch/finally + Log.CloseAndFlushAsync
```

All the `AddCustom*` methods come from `UA.Framework.Configuration.ServiceCollectionExtensions`
in `UA.Framework.API`.

Four things to get right:

1. **`AddCustomHealthChecks`, not `AddHealthChecks`.** `CoilCheckin`'s local extension is
   named `AddHealthChecks` and shadows the built-in; `UATemplate` renamed it. Keep the
   rename.
2. **No `app.UseAuthorization()`.** `CoilCheckin` has none — authorization is enforced by
   the global `AuthorizeFilter` that `AddCustomMvc()` adds. Do not add it "for
   completeness"; it changes behaviour.
3. **Omit `AddCustomDbContext` and `AddPersistence` for now.** They need
   `FlatWireDbContext`, which is `FW-142`. Their absence is why the service boots at this
   story without a database.
4. **Do not register MediatR handlers yet** — `FW-139`. The Scrutor scan needs an assembly
   marker in `FlatWire.Application`, and where that bootstrap lives is decision `P-02`.

`AddCustomMvc()` registers a CORS policy named `CorsPolicy` allowing any origin, method and
header with credentials. **Confirmed 15 Aug 2026: the Angular app is same-origin with
`FlatWire.API` on IIS**, so no browser request from the shopfloor UI is cross-origin, no
preflight is issued, and the permissive policy is **never exercised**. Keep
`UseCors("CorsPolicy")` in the pipeline as the template has it — `P-18` establishes that
this story does not fork `AddCustomMvc()` — but understand it as inert rather than as a
position anyone took. See §8.

### Step 7 — configuration

`appsettings.json`, modelled on `CoilCheckin`'s:

| Key | Value |
|---|---|
| `PATH_BASE` | `/API.FlatWire` |
| `SqlSetting.CATALOG` | `FlatWireDB` — `D-02`, a new standalone database, **not** `united_db` |
| `SqlSetting.DSN` | the `UA_Connection_String_*` indirection, per `[DEP §2.1]` |
| Serilog file sink `path` | `E:\Instance\Logs\FlatWire\log-.json` |
| Serilog Loki label `app` | `FlatWire.API` |
| `Services` | add an `OPCConnectionService` entry — `FlatWire` calls it via `UA.Framework.RestClient` |

**`launchSettings.json` needs its own ports.** `CoilCheckin` and `UATemplate` ship
*identical* values — `https://localhost:7159`, `http://localhost:5219`, IIS Express
`47311`/`44378`. A third copy collides the moment two services run together. Allocate a
fresh set and record it here when chosen.

Everything else — the OPC tag-path map, SignalR settings, `SimulatePLCTagPush`, JWT keys,
and startup-validated options binding — belongs to `FW-144` and `FW-145`.

### Step 8 — the fifteen controller shells

From `[API §3.1]`, in its order. All fifteen exist; none has an action yet.

| # | Controller | Route prefix |
|---|---|---|
| 1 | `LinesController` | `/lines/status` |
| 2 | `PassScheduleController` | `/passschedule/**` — scaffolded, **handlers MVP-2** |
| 3 | `RodReceivingController` | `/rod/**` |
| 4 | `PayoffStagingController` | `/payoff/status`, `/staging/**` |
| 5 | `CheckInController` | `/checkin/**` |
| 6 | `RunController` | `/run/**` |
| 7 | `SpcController` | `/spc` |
| 8 | `WeldEventController` | `/weldevent` |
| 9 | `RollAdjustController` | `/rolloverride` |
| 10 | `DieChangeController` | `/diechange` |
| 11 | `CheckOutController` | `/checkout` |
| 12 | `WipRejectionController` | `/wipreject` |
| 13 | `SpoolController` | `/spools` |
| 14 | `CoilController` | `/coil/**` |
| 15 | `ShiftSummaryController` | `/shiftsummary` — scaffolded, **handlers MVP-2** |

Shape — `CoilCheckin`'s controller pattern, reduced to the shell:

```csharp
// --------------------------------------------------------------------------------------------------------------------
// <copyright file="LinesController.cs" company="United Aluminum Corporation">
// Copyright (c) United Aluminum Corporation. All rights reserved.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace FlatWire.Api.Controllers.Lines;

/// <summary>Lines Controller.</summary>
[ApiController]
[Authorize]
[Route("api/v1/flatwire")]
public class LinesController : UAController
{
    private readonly IMediator mediator;

    /// <summary>Initializes a new instance of the <see cref="LinesController"/> class.</summary>
    /// <param name="mediator">The mediator.</param>
    public LinesController(IMediator mediator)
    {
        this.mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
    }
}
```

Four rules:

- **Class-level `[Route("api/v1/flatwire")]` with explicit per-action routes**, which is
  `CoilCheckin`'s pattern (`[HttpPost] [Route("CoilCheckin")]`). Do **not** use the
  `[controller]` token: `PayoffStagingController` owns two unrelated prefixes
  (`/payoff/status` and `/staging/**`) and the token cannot express that.
- **`[Authorize]` on the class**, no exceptions here. `GET /health` is the one anonymous
  endpoint in the service (`phase-01b` L91, L172) and it has no controller —
  it is registered in `Program.cs` by `FW-148`.
- **Extend `UAController`**, never a bare `ControllerBase`. It supplies the envelope
  helpers and the JWT claim accessors.
- **Do not scaffold `POST /staging/rod/mark-welded`** — endpoint 13, retired 1 Aug 2026 in
  favour of `POST /weldevent` as the single weld write (`FW-138` AC).

### Step 9 — IIS registration

Each service is an IIS application under `Default Web Site` at `/API.{Domain}`. Add
`FlatWire` to all three deploy scripts at the `ual-api` root — `01_AddAppPool.bat`,
`02_AppApplication.bat`, `03_SetApplicationAppPool.bat` — as `/API.FlatWire` →
`D:\IIS\Instance1\API\API.FlatWire`. **The path must match `PATH_BASE`** from step 7.

> `[ARC §11]` and `[REQ]` both require **the IIS WebSockets feature enabled** on the target.
> It is not needed to satisfy this story, but the app pool is created here and `FW-080`
> will need it — flag it to whoever provisions the box. Gap `G10`.

---

## 5. Decisions this plan makes

Two are divergences from a literal reading of a specification. Both are recorded so they
can be ratified or reversed rather than discovered later in a diff.

> The `P-##` series is **continuous across this folder**, so a number means one thing
> repository-wide. `P-06`–`P-08` are in [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) §5.

### `P-01` — scaffold from `UATemplate`; `CoilCheckin` stays the reference

**Needs ratifying.** The card and `phase-01b` L81 both say "copied from `CoilCheckin`".
`ual-api`'s `CLAUDE.md` says to start a new domain from `API/UATemplate/`. The two are
reconcilable: `[ARC §2.2]`'s requirement is that the *controller shape, MediatR command
pattern, `Program.cs`, `.csproj` files and NuGet set* come from `CoilCheckin`, and every
one of those still does. Only the physical `dotnet new` invocation changes, and it yields
the same four projects with the defects listed in step 1 already absent.

If ratification fails, fall back to `cp -r CoilCheckin FlatWire` and unpick those defects
by hand; nothing else in this document changes.

### `P-02` — the MediatR bootstrap goes in `FlatWire.API`, keeping `Infrastructure → Domain`

**Needs ratifying. This is a genuine conflict between the specification and its own named
template.**

`[SVC §3.1]` L36 and `phase-01b` L81 both specify `Infrastructure → Domain`.
`CoilCheckin.Infrastructure` in fact references **`Application`** — because its
`CrossCutting.cs` returns `typeof(GetCoilsQuery).Assembly` to feed the Scrutor handler
scan, and `DependencyInjectionRegistry.AddPersistence` registers Application service
interfaces. Copying the template literally therefore violates the specified graph.

**Resolution: honour `[SVC §3.1]`.** Keep `Infrastructure → Domain` only, and put the
MediatR assembly marker and the Scrutor bootstrap in **`FlatWire.API`**, which already
references `Application` and `Infrastructure` both. The API project is where
`Program.cs` calls the registration anyway, so nothing is lost but the indirection.

The specification is the better design here — `Infrastructure → Application` inverts Clean
Architecture's dependency rule, and `[SVC §3.2]` already forbids Application from holding
`DbContext` types, so the coupling buys nothing. **`FW-139` and `FW-140` inherit this
decision**; if it is reversed, both are affected.

### `P-03` — `FlatWire.*` namespaces and assembly names

Namespaces `FlatWire.Api`, `FlatWire.Application`, `FlatWire.Domain`,
`FlatWire.Infrastructure`; `<AssemblyName>FlatWire.$(MSBuildProjectName)</AssemblyName>`.

`CoilCheckin` uses bare `Api` / `Application` / `Domain` / `Infrastructure` and ships
`Api.dll`, `Domain.dll` — and has already drifted, carrying `CoilCheckin.Domain.Models`
alongside `Domain.Models` and forcing double `using` blocks in its controllers. `UATemplate`
fixed the assembly half. Prefixing avoids ambiguity against `UA.Framework.Domain`'s own
types and stops four generically-named assemblies landing on the IIS box. **Pick it once
and hold it** — the drift is the thing to avoid, more than either convention.

### `P-04` — controller routing

Class-level `[Route("api/v1/flatwire")]` + explicit per-action routes, per step 8.

### `P-05` — ports

A fresh `launchSettings.json` port set, not `7159`/`5219`/`47311`/`44378`. Record the
chosen values in this section when allocated.

---

## 6. Verification

Mapped 1:1 to the card's four acceptance criteria.

```bash
# AC 1, 2, 3 — solution, four projects, reference graph, NuGet set
dotnet build API/Domain/FlatWire/FlatWire.sln

# AC 4 — boots under Development
dotnet run --project API/Domain/FlatWire/FlatWire.API
```

| # | Criterion | How it is checked |
|---|---|---|
| 1 | Four projects under `API/Domain/FlatWire/` | `FlatWire.sln` lists exactly four; folder names match `[SVC §3.1]` |
| 2 | Reference graph | `dotnet list <proj> reference` on each — `Domain` returns none; `Infrastructure` returns `Domain` only *(`P-02`)* |
| 3 | NuGet set from `CoilCheckin` | No `Version=` attribute in any `.csproj`; restore succeeds; **no `Directory.Packages.props` under `API/Domain/FlatWire/`** |
| 4 | Builds and boots | Build is warning-clean against the nine injected analyzers; the service starts under `ASPNETCORE_ENVIRONMENT=Development` and Swagger UI loads |

Plus, for the pulled-forward scope:

- Fifteen types deriving from `UAController` are discoverable by reflection, each carrying
  `[Authorize]`, and their names and route prefixes match `[API §3.1]` exactly.
- `POST /staging/rod/mark-welded` appears nowhere.

**There are no automated tests, and that is deliberate** — `[TS §1.2]`, 15 Aug 2026:
`FlatWire` ships with no xUnit suite of any kind. `[SP]` is explicit: *"Do not reinstate an
xUnit requirement here without reversing that decision in `[TS]`."* Phase 1B's QA
contribution is a signed-off manual contract walkthrough at QA0, which this story predates.

---

## 7. Handoff

The moment `FlatWire.sln` builds, thirteen stories unblock.
**[`FW-138`](FW-138-Fifteen-Thin-Controllers.md)** (endpoints on the shells this story
creates — its plan is written) and `FW-139` (MediatR, which inherits decision `P-02`) are
the natural next two. `FW-141` and `FW-142` additionally wait on Phase 1C — `FW-141` on
`FW-006`, `FW-142` converging with `FW-006`/`FW-007`.

> ⚠ **`FW-138` found a conflict this story does not hit but `Program.cs` sits next to.**
> The framework cannot produce `[API §1.2]`'s `{data, success, errors[]}` envelope —
> `ActionResultBase<T>` has no `errors` array and an `int` error code, and `CoilCheckin`'s
> controllers return **HTTP 200 on failure**. Tracked as decision `P-06` in that plan. It
> does not change anything here, but do not "fix" a `FW-138` controller back toward the
> `CoilCheckin` catch block on the strength of `[ARC §2.2]`.

---

## 8. Open items, and four stale citations

### 8.1 Open items that touch this story

| Item | Effect here |
|---|---|
| **`G6` / `OI-37`** | ✅ **Largely closed, 15 Aug 2026** — the six roles **do** exist as JWT claims, on the standard `ClaimTypes.Role`. Nothing here changes: the skeleton was never blocked. The residual (the six claim *values* are coded, mapping unsupplied) belongs to [`FW-145`](FW-145-JWT-And-Role-Policies.md) §5. **Note it needed no `JWTClaims` addition** — had it, this story's local-feed repack dance would have been on `FW-145`'s critical path |
| **`G10`** | MessagePack is a new client dependency and IIS WebSockets must be enabled. Provisioning lead time starts now, not at `FW-080` |
| **CORS** | ✅ **Answered 15 Aug 2026: the Angular app is same-origin with `FlatWire.API` on IIS.** No specification ever stated a position — a grep across `MVP-1/ProjectPlan/` still returns nothing — but none is now needed. ⚠ **Do not conclude the policy can be removed.** It is inert *in production* and load-bearing *in development*: `ng serve` runs the UI on `localhost:4200` against the API on its own port, which is cross-origin. Tightening `CorsPolicy` to match the IIS deployment would break every developer's local loop while changing nothing in production |
| **`C:` vs `D:\Nuget\Repo`** | ✅ **Confirmed 15 Aug 2026: `C:\Nuget\Repo`.** `ual-api`'s `CLAUDE.md` says `D:` and is wrong; the `.csproj` post-pack targets and the machine `NuGet.Config` both say `C:`, and the confirmation matches them. This plan's recommendation is now a decision |

### 8.2 Stale text in the backlog — do not build to it

Each of these is in `[TB]` or `[SSP]` and is contradicted by a later, narrower source. A
developer working from the backlog alone would inherit all four.

| Stale | Correct | Source |
|---|---|---|
| `[TB §7]` `FW-140` says the flag is **`useStub`** | **`useMockData`** | `phase-01b` L84: *"matching `[API §7.1]` and 1A — *not* `useStub`"* |
| `[TB §7]` `FW-142` says *"25 MVP-1 tables … 28 in the full design"* | **28**, one number | `D-31`; `phase-01b` L47. *(`ProjectPlan/README.md` L61 and L156 carry the same stale split)* |
| `[TB §7]` `FW-141` lists `PassScheduleRepository`, `RodRepository` | **Seven repositories, one per aggregate root**, keyed by the alpha value object. **`RunReading`, `Rod` and `PassSchedule` get none** | `phase-01b` L85, `[SVC §3.2a]` |
| `[SSP]` says *"Thirteen thin controllers"* at 35 h | **Fifteen**, 45 h | `[API §3.1]`, resolved 15 Aug 2026 |
