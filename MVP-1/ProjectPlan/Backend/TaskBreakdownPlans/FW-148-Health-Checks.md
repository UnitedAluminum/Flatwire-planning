# FW-148 · Health checks

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — **re-reviewed before execution: four build-order corrections, three of them to the same day's earlier review.** ⚠ **The one that would have cost real time: §3 step 2's "registration-ordering trap" does not exist.** `CustomDbContext.ResolveConnectionString` reads **`IConfiguration` directly** and never touches the `SqlSetting` options object (consumed only by `ContextRepository`, on the Dapper path), so `AddCustomHealthChecks` at `Program.cs:142` versus `Configure<SqlSetting>` at 146 is **irrelevant** — the `IConfiguration` the check needs is already the parameter it receives and ignores. No deferral, no factory overload needed. The **real** consequence, now stated instead: an eager resolve moves a missing-key failure from *first query* to **boot**, which is a choice to make rather than a trap to avoid. **(2) `Polly` needs no reference** — it is in `FlatWire.Api.deps.json` at 8.4.2, transitively from `UA.Framework.API`, as is `UA.Framework.RestClient` 1.0.0 from `FlatWire.Application`; the earlier *"neither package is referenced"* was true of **direct** references only and told the developer to add one they already have. **Only `AspNetCore.HealthChecks.SqlServer` is genuinely absent — and adding it is not free:** its nuspec requires **`Microsoft.Data.SqlClient >= 5.2.0`** while this service resolves **5.1.5** from EF Core 8.0.8, and because that package is unpinned in `Directory.Packages.props` with transitive pinning **off**, it floats **silently up to 5.2.0** — the provider every EF query and every Dapper call goes through. §3 step 1 now puts that as an explicit A/B choice and **recommends a ~20-line hand-written `IHealthCheck` running `SELECT 1`** on the existing driver, per `[ARC §14]`; the package's `connectionStringFactory` overload was verified to exist in 8.0.2 either way. **(3) `version` must have the `+<sha>` cut off** — the built `Api.AssemblyInfo.cs` carries `AssemblyInformationalVersionAttribute("1.0.0+364d0572…")` because the .NET 8 SDK appends the source revision, so *"emit the informational version"* would have produced `"version": "1.0.0+364d0572…"` and **failed `[API §4.19]`'s `"1.0.0"` at QA0**; no `<Version>` property is needed, only the cut. **(4) `[TRP §6]` → `[TRP §1.4]`** on `P-85` and on §1's hours note — both cited lines sit under §1.4's *1B Backend foundation*; §6 is *Blockers*, which is the correct home for the `G10` citation and stays. Also added: §2.5 now states **what a 200 from `OPCConnection`'s `/liveness` does not prove** — that service registers exactly one `AddCheck("self", …Healthy())`, so the probe establishes the web application is serving and says **nothing about OPC-server or PLC connectivity**, which is `C1`/`C11`'s business. Earlier the same day: **reviewed against the built service; five factual corrections, `P-20` restated and `P-85`–`P-87` minted.** ⚠ **The correction that changes what this story is: the route disagreement `P-20` was minted to settle does not exist.** `[API §1]` declares the REST base URL **`/api/v1/flatwire`** and every row of `[API §3.2]` is written base-relative to it — `GET /lines/status` is built as `Routes.Base + "lines/status"` in code today — so **row 30's `/health` and `[DEP]`'s `/api/v1/flatwire/health` are the same string in two notations**, and there was never a second path to map. `P-20` is restated to record that; **the "map it at both paths" resolution is withdrawn**, and the *real* undecided question — `UseHealthChecks` terminal middleware versus `MapHealthChecks`, and where — is now **`P-85`**, aligned to `[TRP §1.4]`, which already says `MapHealthChecks`. Four more: **(2) the hub metrics are not this story's** — `[MON §7.1]` gives *Hub connection count* and *Broadcast cadence* their own rows sourced from **`FlatWireHub`** and *"Hub instrumentation"*, not from `/health`, and §2.1's five-member shape has no room for them; the plan contradicted itself and the belief had propagated into **`FW-080` and `FW-150`, both corrected at source the same day** (`P-86`). **(3) The OPC probe cannot call `OPCConnection`'s API** — all three of its routes are `[HttpPost]` behind `AddCustomMvc`'s global `AuthorizeFilter` and a health check carries no token; the token-free target is that service's own **`/liveness`**, mapped before its `UseAuthentication()`. **(4) `CoilCheckin`'s route is `/liveness`, not `/liveliness`** — `GlobalConstants.MiscConstants.Liveliness` is a constant *name* whose *value* is `/liveness`; probing the name 404s. **(5) `AspNetCore.HealthChecks.SqlServer` is versioned in `Directory.Packages.props` but not referenced by `FlatWire.API.csproj`** — a `PackageVersion` entry is not a reference — while the project *does* reference `AspNetCore.HealthChecks.UI.Client`, the one shape §2.1 rejects. *(This clause also said `Polly` was unreferenced; corrected in the re-review above — it is available transitively.)* Also: `AddCustomHealthChecks` **already exists** with an unused `configuration` parameter — reuse `CustomDbContext.ResolveConnectionString`, and see the re-review above for why the `142`-versus-`146` ordering it also flagged turned out not to matter; §5 gains the **QA0 gate**, which is this story's earliest verification and was omitted; and **`P-87`** records that `SimulatePLCTagPush = true` in *every* environment until commissioning makes `[DEP]`'s S1 gate and `[MON]`'s 2-minute alert **inert** if `opc.reachable` is keyed off that flag. *(previously August 15, 2026 — first issue)*
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **Re-reviewed before execution, 27 Aug 2026 — buildable as written.** Every §3 instruction has been checked against the built service and the restored packages. **Two decisions still need ratifying (§4): `P-85`** (the mapping mechanism) and **`P-87`** (whether `opc.reachable` tells the truth before commissioning). **One choice belongs to the developer and is deliberately left open: §3 step 1's A/B** — a hand-written `IHealthCheck` (recommended) versus `AspNetCore.HealthChecks.SqlServer`, which bumps `Microsoft.Data.SqlClient` service-wide. The route is settled and is no longer a decision
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-148`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Eight hours, and it is the only endpoint in the service that
> is **anonymous** and the only one with **no controller** — `[API §3.2]` row 30 leaves the
> controller column empty, so it is mapped in `Program.cs` rather than routed by MVC. Its
> response body is **neither** the ASP.NET Core default **nor** the
> `UIResponseWriter.WriteHealthCheckUIResponse` shape every sibling service emits, so a custom
> `ResponseWriter` is unavoidable. And it is the **only backend artifact named in the QA0 gate
> by itself** (`[TS §4.2]`) — `[DEP]` blocks a deployment on it, `[RB]` blocks a rollback on
> it, and `[MON]` alerts on it.
>
> **What this document said until 27 Aug 2026 and no longer says:** that two specifications
> disagreed about the route. They do not — see `P-20`. The eight hours buy a custom writer,
> two real dependency checks and a token-free way to reach `OPCConnection`; they do not buy a
> routing analysis.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-148 · Health checks
> **Hours:** 8 h BE · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As an** operations engineer,
> **I want** a health endpoint covering the database and OPC reachability,
> **So that** a failing dependency is visible before an operator finds it.
>
> **Acceptance Criteria:**
> - [ ] ASP.NET Core health checks at `/health` covering DB and OPC reachability
> - [ ] `/health` green in Development, with OPC reporting simulated-healthy
> - [ ] Unhealthy dependency returns a non-200 and names the failing check
>
> **Rate-card basis:** shared primitive (8 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** —

> ⚠ **Do not re-derive the 8 h.** `[SP]` and `[TRP §1.4]` both carry this story at **5 h**, which
> is the trial re-baseline applied uniformly across the layer (`FW-146` 8 → 5, `FW-147` 12 → 8),
> not a scope reduction here. The card's figure and the re-baselined figure are both correct for
> their own document.

### 1.1 What already exists

| Artifact | State |
|---|---|
| `FlatWire.API/Extensions/HealthCheck.cs` | **Exists.** `AddCustomHealthChecks(IServiceCollection, IConfiguration)` registering **`AddCheck("self", …Healthy())`** and nothing else. Its `configuration` parameter is **unused** — this story is what uses it |
| `Program.cs:142` | `builder.Services.AddCustomHealthChecks(builder.Configuration)` is already called |
| The route | **Not mapped.** `Program.cs`'s header comment says so explicitly: *"The health-check endpoint, which FW-148 owns … the route is not mapped in this story"* |
| `Program.cs:353` | `app.UsePathBase(pathBase)` — `PATH_BASE` is `/API.FlatWire` in `appsettings.json` and is **not** overridden in Development |

---

## 2. The contract

### 2.1 The shape

`[API §4.19]` and `phase-01b` L95 — the response body:

```json
{
  "status": "Healthy",
  "database": { "reachable": true, "latencyMs": 12 },
  "opc":      { "reachable": true, "latencyMs": 31 },
  "version":  "1.0.0",
  "environment": "Development"
}
```

⚠ **This is not the ASP.NET Core default shape**, and it is not
`UIResponseWriter.WriteHealthCheckUIResponse` either — which is what `CoilCheckin`,
`OPCConnection` and the rest of `ual-api` use. A custom `ResponseWriter` is required.

**Five members, and no sixth.** Anything wanting to publish a metric through this endpoint is
asking to change `[API §4.19]`. See `P-86`.

### 2.2 The consumers

| Consumer | Needs | Where it is written |
|---|---|---|
| **QA0** | `GET /health` returning **the full documented shape** — part of 1B's contribution to the **Phase-1 hard gate**, signed off by a named reviewer because there is no suite to run it | `[TS §4.2]`, `phase-01b` L177, `[RM]` |
| `[DEP]` | Gates deployment on **`database.reachable` *and* `opc.reachable`** (smoke case `S1`); the probe is **unauthenticated** | `[DEP §4.4]` V11, `[DEP §5]` |
| `[RB]` | *"`/health` green on the previous version"* — twice, in both rollback paths | `[RB]` |
| `[MON]` | Alerts when not-healthy, **or `opc.reachable` false for more than 2 minutes** | `[MON §7.1]`, row 1 |
| Operators | Indirectly — *"a failing dependency is visible before an operator finds it"* | the card |

> ⚠ **Hub connection count and broadcast-cadence deviation are NOT on this list**, and this
> document asserted for twelve days that they were. `[MON §7.1]` is a five-column table with
> **one row per instrument**, and it sources those two from **`FlatWireHub`** and
> *"Hub instrumentation"* — separate rows from the `/health` row, whose source is
> `FlatWire.API`. The mistaken reading came from `phase-01b` L95, which appends them to its
> *Health checks* row with the words *"both of which are **hub code this layer writes**"* —
> "this layer" being **Phase 1B**, and the sentence naming hub code explicitly. Decision
> `P-86`; corrected at source in [`FW-080`](FW-080-FlatWireHub.md) and
> [`FW-150`](FW-150-Broadcast-Loop.md), which had both taken the claim from here.

### 2.3 Anonymous, and it is the only one

`[Authorize]` on every controller and endpoint, with **one documented exception**:
`GET /health` is *"Any / anonymous per policy"* (`[API §3.2]` row 30, `phase-01b` L91) and
`[DEP]` gates the deploy smoke test on an **unauthenticated** probe. `TC-655` excepts it by
name.

**Three mechanisms could have made it non-anonymous, and none of them does — verified in the
built service, not assumed:**

| Mechanism | Effect on `/health` |
|---|---|
| `AddCustomMvc()`'s global `AuthorizeFilter(RequireAuthenticatedUser())` | **None.** It is an **MVC filter**; it binds MVC actions only, and health is not one |
| `app.UseAuthorization()` — added 25 Aug 2026 by `P-55`, *after this plan first issued* | **None**, provided the endpoint carries no authorization metadata. `MapHealthChecks` adds none unless `.RequireAuthorization()` is called |
| An authorization **fallback policy** | **Does not exist.** There is no `AddAuthorization`, no `AddPolicy` and no `FallbackPolicy` anywhere in `FlatWire` — grep confirms zero hits |

So anonymity is available under **either** mapping mechanism, and the original reasoning
(*"map it outside MVC, before `UseAuthentication()`, and you sidestep the filter"*) is now only
half the picture: it predates `UseAuthorization()`. Make the anonymity **explicit in code**
rather than implicit in pipeline position — `P-85`.

### 2.4 What the surrounding code actually has

**`CoilCheckin`** registers `hcBuilder.AddCheck("self", () => HealthCheckResult.Healthy())` —
that is all — and exposes two routes:

| Constant | Value | Predicate |
|---|---|---|
| `GlobalConstants.MiscConstants.Liveliness` | **`/liveness`** | `r => r.Name.Contains("self")` |
| `GlobalConstants.MiscConstants.HC` | `/hc` | `_ => true`, `UIResponseWriter` |

⚠ **The constant is named `Liveliness`; its value is `/liveness`.** Probing `/liveliness`
returns 404. This document had the route wrong until 27 Aug 2026 — and it matters twice, because
`/liveness` is also the OPC probe target in §2.5.

**Neither route is `/health`, and neither checks anything real.** This story adds the database
and OPC checks and the documented shape.

> **The naming trap is real but is not what this document said.** The extension that shadows the
> framework's built-in `AddHealthChecks()` is the **framework's own**
> `UA.Framework.Api.Extensions.HealthCheck.AddHealthChecks(IServiceCollection, IConfiguration)`;
> `CoilCheckin` duplicates it locally in `Api.Extensions`. `UATemplate` renamed its copy
> **`AddCustomHealthChecks`** to escape the collision and `FW-N04` step 6 kept the rename — which
> is why `FlatWire.API/Extensions/HealthCheck.cs` is already correct. **Do not rename it back.**

### 2.5 Reaching `OPCConnection` — the probe target is not its API

⚠ **`API.OPCConnection` exposes no anonymous API endpoint and no `GET` at all.** Its single
controller has three routes — `GetOPCInfo`, `ReadTag`, `WriteTag` — and every one is
`[HttpPost]` on a `UAController` behind `AddCustomMvc()`'s global `AuthorizeFilter`. **A health
check runs with no user and no bearer token**, so calling any of them yields `401`, which a
naive check would report as *OPC unreachable* on a perfectly healthy service.

**What is anonymous on that service is its own health surface**, mapped before its
`UseAuthentication()` exactly as `CoilCheckin` maps its:

```
http://uanet02/API.OPCConnection/liveness      ← the probe target
http://uanet02/API.OPCConnection/hc
```

⚠ **This is not under the configured endpoint.** `Services:OPCConnectionService:EndPoint` is
`http://uanet02/API.OPCConnection/api/v1/` — the probe path is a **sibling of `api/v1/`, not a
child of it**. Derive the application root from the configured value; do not append.

⚠ **And know what a 200 there does and does not prove.** `OPCConnection` registers exactly one
check — `AddCheck("self", () => HealthCheckResult.Healthy())`, in its own
`Extensions/CustomDbContext.cs` — and `/liveness` filters to it (`Predicate = r =>
r.Name.Contains("self")`). So a 200 proves **the OPCConnection web application is up and serving**
and says **nothing about whether it can reach the OPC server or the PLCs**. That is consistent with
`[DEP]`'s word *reachability* and with `[MON]`'s *"`opc.reachable` false"*, both of which are about
reach; it is **not** the same as *the tags are readable*, which is what commissioning tests `C1`/`C11`
establish. `/hc` is no deeper — same single check, `UIResponseWriter` shape. Do not describe this
check as PLC connectivity, and see `P-87`.

---

## 3. Build order

1. **Decide the database check's dependency before writing anything** — this is the only step
   that changes the service's package closure, and it is a real choice, not a formality.

   **`Polly` and `UA.Framework.RestClient` need nothing.** Both are already in
   `FlatWire.Api.deps.json` — `Polly` 8.4.2 transitively from `UA.Framework.API`, `UA.Framework.RestClient`
   1.0.0 transitively from `FlatWire.Application` — so the OPC check in step 3 adds no reference at all.
   *(The house convention in this solution is to reference explicitly what you use — `FlatWire.API.csproj`
   references `Domain` explicitly rather than transitively, and says so. Adding either as an explicit
   `PackageReference` is a style call with no restore consequence.)*

   **`AspNetCore.HealthChecks.SqlServer` is the one genuine absence** — it is versioned at 8.0.2 in
   `API/Directory.Packages.props` but not referenced by this project, and under
   `ManagePackageVersionsCentrally` a `PackageVersion` entry is **version management, not a reference**.

   ⚠ **Adding it bumps the data driver for the whole service.** Its nuspec requires
   **`Microsoft.Data.SqlClient >= 5.2.0`**; `FlatWire.Api` currently resolves **5.1.5** (transitively,
   from EF Core 8.0.8). `Microsoft.Data.SqlClient` has **no `PackageVersion` entry** and
   `CentralPackageTransitivePinning` is **off**, so it floats **silently up to 5.2.0** — no warning, no
   restore error, and it is the provider **every EF query and every Dapper call in the service** goes
   through. Two ways not to have that be a side effect of a health check:

   | Option | Cost |
   |---|---|
   | **A — hand-written `IHealthCheck`** opening a `SqlConnection` on the existing driver and running `SELECT 1` | **No new package, no driver bump**, and `latencyMs` is timed where you can see it. ~20 lines |
   | **B — `AspNetCore.HealthChecks.SqlServer` 8.0.2** | The package's `SELECT 1;` default and `SqlServerHealthCheckOptions`; **accept the 5.1.5 → 5.2.0 bump deliberately and say so in the PR** |

   **Recommendation: A**, on `[ARC §14]`'s *stay within the existing stack* and because an 8 h
   health-check story is the wrong place to move a manufacturing service's SQL driver. B is defensible
   if the bump is wanted anyway — but it is then a **data-access decision**, not this story's.

   Separately: `FlatWire.API.csproj` **does** reference `AspNetCore.HealthChecks.UI.Client`, inherited
   from the `CoilCheckin` template. §2.1 rejects that writer, so once this story lands the reference is
   **unused** — remove it or record why it stays.

2. **Database check**, named **`database`**, resolving the connection string with
   **`CustomDbContext.ResolveConnectionString(configuration)`** — `private static` today, so widen it to
   `internal static` rather than writing the double indirection a second time
   (`SqlSetting:DSN` names the section holding the string; `{catalog}` inside it is replaced by
   `SqlSetting:CATALOG` = `FlatWireDB`).

   ✅ **There is no registration-ordering problem, and an earlier draft of this plan said there was.**
   `AddCustomHealthChecks` runs at `Program.cs:142` and `Configure<SqlSetting>` at **146**, but
   `ResolveConnectionString` reads **`IConfiguration` directly** and never touches the `SqlSetting`
   options object — which is consumed only by `ContextRepository` on the Dapper path. The
   `IConfiguration` this check needs is **already the parameter `AddCustomHealthChecks` receives and
   currently ignores** (§1.1). Nothing has to be deferred to make it work.

   ⚠ **The one real consequence of resolving it here: `ResolveConnectionString` throws on a missing
   key, so an eager call moves that failure from *first query* to *boot*.** `AddCustomDbContext` defers
   it inside the `AddDbContext(options => …)` lambda, so today a missing `SqlSetting:DSN` surfaces on
   the first request. Failing at boot is consistent with `FW-144`'s `P-16` and is probably what you
   want — but make it a choice, and if you would rather it stay deferred, `AddSqlServer`'s
   `connectionStringFactory` (`Func<IServiceProvider, string>`) overload **does exist in 8.0.2**
   (verified in the shipped assembly's metadata), as does a hand-written check that resolves inside
   `CheckHealthAsync`.

3. **OPC check**, named **`opc`** — a `GET` on `API.OPCConnection`'s **`/liveness`** (§2.5),
   with **Polly** on the outbound call (`phase-01b` L97). Under `SimulatePLCTagPush = true` it
   reports **simulated-healthy**, which is AC 2 — **and read `P-87` before implementing that
   branch**, because the flag is `true` in production too until commissioning.

4. **Custom `ResponseWriter`** emitting §2.1's shape. Most of it is free:

   | Member | Source |
   |---|---|
   | `status` | `report.Status.ToString()` → `Healthy` / `Degraded` / `Unhealthy` |
   | `<check>.reachable` | `entry.Value.Status == HealthStatus.Healthy` |
   | `<check>.latencyMs` | `entry.Value.Duration.TotalMilliseconds` — **the framework already times each check**; no stopwatch of your own |
   | `environment` | `IHostEnvironment.EnvironmentName` |
   | `version` | ⚠ **The informational version, with everything from the first `+` cut off.** The built `Api.AssemblyInfo.cs` carries `AssemblyInformationalVersionAttribute("1.0.0+364d0572c6f823359a8fa9c96bc339b1e28ea3e6")` — the .NET 8 SDK appends the source revision by default — so emitting it raw gives `"version": "1.0.0+364d0572…"` and **fails `[API §4.19]`'s `"1.0.0"` at QA0**. `AssemblyVersion`/`AssemblyFileVersion` are no better: both are four-part `1.0.0.0`. Cut at the `+`. **No `<Version>` property is needed** — `Directory.Build.props` sets none, so the SDK default `1.0.0` already matches; and `Constants.Configuration` has no version constant, so do not invent one there |

   The writer looks entries up **by name**, so step 2 and step 3 must use `database` and `opc`
   exactly. The inherited **`"self"` entry is a third entry**: harmless (always `Healthy`, and
   the writer ignores it), but it does contribute to the aggregate `status`.

5. **Non-200 when unhealthy**, naming the failing check (AC 3).
   ⚠ `HealthCheckOptions.ResultStatusCodes` maps **`Degraded` → 200** by default. A dependency
   reported as `Degraded` therefore satisfies AC 3's *"non-200"* not at all. **Return
   `Unhealthy`, not `Degraded`, for a genuinely unreachable dependency** — or override
   `ResultStatusCodes`, and say which in the PR.

6. **Map the route** — `P-85`.

7. **Confirm anonymity** — probe with no `Authorization` header (§5).

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder and the register now runs to **`P-87`**; new decisions
> mint at `P-88`+. `P-20` is this story's original id and is retained — restated, not withdrawn,
> because three rows in [`Orchestration.md`](Orchestration.md) and a `CHANGELOG` entry cite it.

### `P-20` — **restated.** There is one route, and the two documents never disagreed

**Settled — no ratification needed.** `phase-01b` L95 assigned a tiebreak here:

| Source | Route as written |
|---|---|
| `[API §3.2]` row 30, `[MON §7.1]`, `[RB]`, the card | `/health` |
| `[DEP §4.4]`, `[DEP §5]`, `[SUP]` | `/api/v1/flatwire/health` |

**These are the same path in two notations.** `[API §1]` declares the REST base URL as
**`/api/v1/flatwire`**, and **every row of the `[API §3.2]` index is written base-relative to
it** — row 1's `GET /lines/status` is built in the shipped code as
`[Route(Constants.Routes.Base)]` + `[Route("lines/status")]`, where
`Routes.Base = "api/v1/flatwire"`. Row 30 is a row of that table. The split is editorial and
perfectly correlated: **the documents that write a runnable command write the full path**
(`[DEP]` and `[SUP]` are both `Invoke-RestMethod` lines); the documents that write prose use the
index shorthand.

**Resolution: map it once, at `api/v1/flatwire/health`, on the same base every controller uses.**
The earlier resolution — *"map at both paths, treat the absolute one as canonical"* — is
**withdrawn**. Its stated justification was that mapping both *"keeps every document's literal
text true"*, and that was never achievable: on IIS this service is an application at
**`/API.FlatWire`** (`02_AppApplication.bat`, and `PATH_BASE` in `appsettings.json` matches), so
the deployed URL is `<host>/API.FlatWire/api/v1/flatwire/health` and **neither** literal string
resolves. A second route would have bought a second thing to keep working, not agreement.

### `P-85` — map with `MapHealthChecks`, between `UseRouting()` and `MapControllers()`, with an explicit `.AllowAnonymous()`

**Needs ratifying.** The genuine choice, which the old `P-20` never reached:

| | `app.UseHealthChecks(path, options)` | `app.MapHealthChecks(path, options)` |
|---|---|---|
| Model | Terminal middleware, short-circuits | Endpoint routing |
| Precedent | `CoilCheckin`, `OPCConnection` | **`[TRP §1.4]`** — *"`GET /health` is `MapHealthChecks` middleware"* |
| Fits this service | Its own routing model is `UseRouting` + `MapControllers` | **Yes** — same model |
| Anonymity | By pipeline position, before `UseAuthentication()` | By absence of metadata, and **statable in code** |

**Choose `MapHealthChecks`, placed with `UseAuthorization()` and `MapControllers()` at the foot
of the pipeline, and call `.AllowAnonymous()` on it even though nothing currently requires it.**
Three reasons, in order of weight: `[TRP §1.4]` already commits to it in writing; it keeps the
probe **inside** all three cross-cutting middlewares this service has grown since 15 Aug —
`CorrelationIdMiddleware`, `UseSerilogRequestLogging` (`FW-143`) and `ExceptionHandlingMiddleware`
(`FW-146`) — where the terminal form placed at `CoilCheckin`'s position would sit outside at
least the last two; and `.AllowAnonymous()` makes **the one documented exception in the service**
visible at the line that creates it rather than inferable from ordering, which is the whole
lesson of `P-55`.

⚠ **One consequence to coordinate, not to absorb here.** `[MON]` polls this endpoint, and every
probe now produces one Serilog request-completed event at `Information`. `LevelFor` in
`Program.cs` is **`FW-143`'s**; the fix is one branch returning `Verbose` for the health path.
Raise it there — do not fork the level policy into this story.

### `P-86` — hub connection count and broadcast-cadence deviation are not this story's

**Settled.** `[MON §7.1]` sources them from **`FlatWireHub`** and *"Hub instrumentation"*, in
their own rows, and `[API §4.19]`'s body has **five members with no hub member** — this plan
simultaneously required *"exactly five members"* and *"expose the hub metrics off this surface,"*
which cannot both hold. They belong to [`FW-080`](FW-080-FlatWireHub.md) (connection count) and
[`FW-150`](FW-150-Broadcast-Loop.md) (cadence deviation), both of which had adopted the claim
from this document and are **corrected at source**.

**They are also not health checks on their own terms** — a hub with zero connections at 3 a.m.
is not unhealthy — which is the argument this plan used to justify keeping them here as
"instrumentation." That argument is sound and it points the other way.

### `P-87` — `opc.reachable` must not be keyed off `SimulatePLCTagPush`

**Needs ratifying — it changes what `[DEP]`'s gate means.** AC 2 asks for *"OPC reporting
simulated-healthy"* in Development. But `[DEP §4.4]` requires **`SimulatePLCTagPush = true` on
every environment** until PLC commissioning completes, and `appsettings.json` ships it `true`.
If `opc.reachable` simply returns `true` whenever the flag is set, then through the whole
pre-commissioning period:

- `[DEP §5]`'s **S1 gate** — *"`database.reachable` and `opc.reachable` both true"* — passes
  unconditionally on half its condition, so it gates nothing;
- `[MON §7.1]`'s **2-minute `opc.reachable` alert** can never fire.

**Recommendation: always perform the real `/liveness` probe and always report its true result in
`opc.reachable`. Let the flag govern only the *severity*** — while `SimulatePLCTagPush = true`,
an unreachable OPC yields `Degraded` (200, so Development stays green per AC 2) rather than
`Unhealthy` (503). The field then means the same thing in every environment, which is what both
downstream consumers actually read, and AC 2's *"green in Development"* still holds.

**This is a proposal, not an applied change** — it reads AC 2's *"simulated-healthy"* as being
about the endpoint staying green, not about the field lying. If Operations reads it the other
way, the alternative is to key the field off the flag and **strike the `opc.reachable` half of
`[DEP §5]` S1 and the `[MON]` alert until commissioning**, so that nothing claims to be gating
when it is not. Do not leave it undecided and build the first branch by default.

---

## 5. Verification

**No automated tests** — `[TS §1.2]` withdrew the .NET unit and integration levels entirely.
The two real gates are **QA0** (earliest; a signed-off manual check) and the **`[DEP §5]`
deployment smoke suite** (a deployment gate, not a unit test).

⚠ **The URL to actually probe.** `[DEP]` and `[SUP]` both write
`https://<host>/api/v1/flatwire/health`, which **omits the IIS application path**. This service
is an application at `/API.FlatWire` under *Default Web Site*, so:

```powershell
# Deployed (IIS)
Invoke-RestMethod -Uri "https://<host>/API.FlatWire/api/v1/flatwire/health"

# Development (Kestrel) — UsePathBase makes the prefixed form work too, but it is not needed
Invoke-RestMethod -Uri "http://localhost:<port>/api/v1/flatwire/health"
```

This is **not specific to health** — `[DEP]`'s `GET /api/v1/flatwire/lines/status` check has the
same omission, and every inter-service `EndPoint` in `appsettings.json` carries the prefix
(`http://uanet02/API.OPCConnection/api/v1/`). It is a `[DEP]`-wide notation correction, recorded
in §7 rather than patched from here.

| AC / obligation | How it is checked |
|---|---|
| Health checks covering DB and OPC | Both checks present and **named `database` and `opc`**; both report `reachable` and `latencyMs` |
| Green in Development, OPC simulated-healthy | With `SimulatePLCTagPush = true`, `status: "Healthy"` and `opc.reachable: true` — **subject to `P-87`** |
| Unhealthy names the failing check | Stop SQL Server → **non-200** (`Unhealthy`, not `Degraded` — step 5), `database.reachable: false`, the failing check named |
| **Anonymous** | `curl` with **no** `Authorization` header returns 200. `TC-655` excepts this endpoint from the auth sweep by name |
| Shape | Exactly `[API §4.19]`'s **five** members — **not** the `UIResponseWriter` shape, and **no sixth member** (`P-86`) |
| Route | One path (`P-20`). `GET <base>/api/v1/flatwire/health` answers; nothing else needs to |
| **QA0** | `[TS §4.2]` and `phase-01b` L177 — *"`/health` green and returning the full documented shape"*, **signed off by a named reviewer**. There is no suite; if the walkthrough is not staffed, this criterion is not met. `Orchestration.md` §gate 6 carries the same link |
| `[DEP §5]` S1 | `TC-700` — declared as a block (`700–714`) in `[TS §1.3]` but **not written out as a case**. Owed by `[TCS]`, not by this story |

---

## 6. Handoff

`[DEP]` gates deployment on this and `[RB]` gates both rollback paths on it. `[MON]` alerts on
it. It is the first thing anyone checks when the service misbehaves, which is why the shape, the
anonymity and the truthfulness of `opc.reachable` all matter more than the eight hours suggest.

**Nothing hands off to `FW-080` or `FW-150` any more** — see `P-86`. What does hand off is the
one-line `LevelFor` branch in `P-85`, which is `FW-143`'s file.

---

## 7. Open items and stale citations

| Item | Effect here |
|---|---|
| **`P-85`** | The mapping mechanism and position — **needs ratifying** |
| **`P-87`** | What `opc.reachable` means before commissioning — **needs ratifying**, and until it is, `[DEP §5]` S1 and `[MON §7.1]`'s alert may both be inert |
| **`[DEP]` / `[SUP]` probe URLs** | Both omit the `/API.FlatWire` application path, so the commands **do not run as written** (§5). Service-wide, not health-specific — owed to `[DEP]` as a notation note, not patched from this story |
| **`TC-700`** | Cited by `[DEP §5]` S1; the `700–714` block is declared in `[TS §1.3]` but no case is written. Owed by `[TCS]` |
| **`G10`** | IIS WebSockets must be enabled — a deployment prerequisite this endpoint cannot detect, and `[TRP §6]` dates the pre-check to **before T2** |
| **§3 step 1's A/B** | **The developer's call, deliberately left open.** Taking `AspNetCore.HealthChecks.SqlServer` bumps **`Microsoft.Data.SqlClient` 5.1.5 → 5.2.0 for the whole service** — unpinned, transitive pinning off, so it floats up with no warning. **A** (hand-written `IHealthCheck`) is recommended; **B** is fine if the bump is wanted, but say so in the PR |
| **`AspNetCore.HealthChecks.UI.Client`** | Referenced by `FlatWire.API.csproj` and **unused** once §2.1's writer lands. Remove it or record why it stays |
| **QA0 has already passed** | `[TS §4.2]` dates the Phase-1 hard gate **14 Aug 2026** and names *"`/health` … full documented shape"* in its 1B component. That date is behind us and this endpoint is unbuilt, so §5's QA0 row is an **obligation still owed**, not a future gate. Not this story's to reschedule — flagged so it is not read as satisfied |

### Struck on 27 Aug 2026

| Item | Why it is struck |
|---|---|
| ~~The `/health` route disagreement~~ | It does not exist — `P-20`. `phase-01b` L95's *"so pin the routing decision here"* is describing a conflict that the same file's L96 (*"Base URL `/api/v1/flatwire`"*) resolves |
| ~~**`G9` / `OI-34`** — no threshold for broadcast-cadence deviation~~ | Real, but **not this story's**: cadence deviation is `FW-150`'s instrument (`P-86`). `G9` still blocks it there, and `Orchestration.md`'s `G9` row is corrected to drop `FW-148` |
| ~~*"No stale citations found in this story's card"*~~ | Four were found on review — `/liveliness` for `/liveness`, the hub metrics, the OPC probe target, and *"already in `Directory.Packages.props`"* read as *"already referenced"* |
| ~~*"Add the two package references — neither is referenced"*~~ | Struck by the **same day's re-review**: `Polly` is already in the dependency closure transitively, so only one package is at issue — §3 step 1. The claim was read off the csproj, which shows **direct** references only |
| ~~The `Program.cs:142`-versus-`146` ordering trap~~ | Struck by the same re-review: `ResolveConnectionString` reads `IConfiguration`, not `IOptions<SqlSetting>`, so there is nothing to defer — §3 step 2 |
