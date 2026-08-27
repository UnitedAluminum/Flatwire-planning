# FW-145 · JWT authentication and role authorization policies

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — **re-reviewed the same day; eight corrections to the pass below, three of them factual.** **`[API §4.13]` does not carry a `supervisorOverride` object** — only `§4.5`/`§4.5a` do, and `§4.13`'s approval is a stamp with **no PIN field**, so the override has **three shapes**, not one (§2.3). **`[SEC §8]`'s *"never carried in the payload"* is contradicted by its own contract**, and its third PIN-gated override — *off-schedule staging* — was **withdrawn 30 Jul 2026** (`FR-046`), so `TC-648`'s and `TC-649`'s rows in §6.1 were wrong for different reasons. Also: build-order step 3 claimed **steps 3–7** do not wait on the role values when **step 7 is the matrix walk, which does**; steps 4–5 registered and applied `ProductionTransaction` unconditionally though **`P-76` is open**; §6.1's *"three executable denials"* is **two, or three with `P-76`**; the hub AC said it *"closes with `FW-080`"* when only the **evidence** moves there; and `FW-146` was cited by line number. **New:** `FW-146` §4 still carries the retired *"no `app.UseAuthorization()`"* rule — flagged in §8, **not fixed here**. *Earlier the same day —* **reviewed against the built service; five gaps closed and three findings raised.** **(1) §3.1 still said *"there is no `app.UseAuthorization()`"* — the line `P-55` corrected on 25 Aug and which is in the built `Program.cs` today; the banner said one thing and the body the opposite. (2) `P-17`'s policy shape was not implementable**: multiple `[Authorize]` attributes **AND**-combine, and every contested `[SEC §8]` cell admits two or more roles, so six single-role policies can express none of them — **`P-75`** makes policies capability-scoped. **(3) §3.3 named `JwtBearerOptions.Events` with no way to reach it** — the inherited `AddCustomAuthentication` owns the named scheme, and both obvious hooks fail (one throws, one is silent): **`P-77`**. **(4) The 22 hosted endpoints had no endpoint→policy mapping at all** — new §3.4, and it shows **four** policies bind, not fifteen. **(5) §6 never cited `TC-640`–`TC-654`**, the matrix walk it describes. ⚠ **New: `AC 4` cannot be executed on the MVP-1 surface** (§6.1), `[SEC §8]`'s spool-weight override **has no carrier in its endpoint contract** (§8), and **`P-76`** is offered for ratification. **No hour cell restated** *(previously August 25, 2026 — `TC-655`'s surface **24 → 22** endpoints (`FW-138` `P-53`); before that August 15, 2026 — **`G6`/`OI-37` largely closed**)*
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Buildable — one fact outstanding.** *(Was ⚠ Blocked until 15 Aug 2026)*
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-145`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** **The story card lists five roles and there are six** — QA is
> missing from it — and it points at the wrong matrix. `[SEC §8]` is the matrix of record;
> `[API §9.2]` is *"only a role→endpoint summary"* and its own table omits Admin.
>
> The blocker was real in a way most blockers are not — `phase-01b` L91: *"⚠ **Whether any
> of the six exists as a JWT claim is unconfirmed — `G6` / `OI-37`, which can block the
> build outright.**"* **It was answered on 15 Aug 2026, and the answer is good: the six
> roles do exist as JWT claims, carried on the standard `ClaimTypes.Role`.** That is the
> best of the three shapes it could have taken — `RequireRole()` and `[Authorize(Roles=…)]`
> read it natively, and nothing needs adding to `UA.Framework.Common`, whose `JWTClaims`
> struct defines only `UserId`, `EmailID` and `BadgeNo`.
>
> **One fact is still missing, and it is not the one this plan hedged against.** The claim
> *values* are abbreviated or coded — they are **not** `[SEC §8]`'s labels — so the
> label→value mapping is now the outstanding item. §5 restates `P-17` accordingly.

---
> ### ⚠ Coding standard — read `[SVC §3.4a]` before writing code
>
> The repository C# standard binds every `.cs` file here, and `[SVC §3.4a]` records the **four
> standing divergences** so they are not re-litigated in review. What this story owns:
>
> ⚠ **`app.UseAuthorization()` is already in `Program.cs`** (`P-55`, `FW-138`) — required under
> `MapControllers`, and without it every endpoint returned `500` instead of `401`. **Do not add a
> second call**; §3.1 carries the corrected rule. Role policies still arrive here. The **fourteen
> controller classes each carry one bare class-level `[Authorize]`** — no action carries one of
> its own — and **`TC-655`'s surface is 22 endpoints.**


## 1. The story

From `[TB §7]` — verbatim, **including the five-role list**. *(The one annotation is the
`Blockers` line, which carries `G6`'s resolution in the backlog itself since 15 Aug 2026.)*

> ###### FW-145 · JWT authentication and role authorization policies
> **Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** security owner,
> **I want** role policies matching the Authorization Matrix,
> **So that** each endpoint admits only the roles that should reach it.
>
> **Acceptance Criteria:**
> - [ ] JWT bearer authentication inherited from the UAL configuration
> - [ ] Hub authentication via `?access_token=` query parameter
> - [ ] Role policies for Operator / Operations Manager / Maintenance / Supervisor / Admin, matching `04-APIContract.md`'s matrix
> - [ ] Authorization tests prove an operator cannot reach an Ops-Manager-only endpoint
>
> **Rate-card basis:** auth + five role policies (16 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** ~~**G6** (roles not confirmed as existing JWT roles vs new)~~ ✅ **Resolved 15 Aug 2026** — all six exist as JWT claims on `ClaimTypes.Role`. ⚠ Residual: the claim **values** are coded rather than labelled and the mapping is unsupplied — gates verification, not construction

> ⚠ **The hour cell is not restated by this review.** The construction is smaller than the card
> implies — **four policies bind on the hosted surface, not fifteen** (§3.4) — and the
> verification is larger, because `AC 4` has no endpoint to run against (§6.1). They are not
> netted off here; `[CE]` owns any re-baseline.

---

## 2. Six roles, not five

`[SEC §8]` and `phase-01b` L91 — **the matrix of record, all six with a column**:

**Operator · Supervisor · Operations Manager · Engineering/Maintenance · QA · Admin**

The card's list omits **QA**, which is a real role with real capability — `/wipreject`
dispose and SPC-HOLD release (`[API §9.2]`).

> **`Admin` is a *platform* role** — provisioning, environment configuration, reference data,
> audit-log access — and owns **no production transaction**, which is why most of its cells
> are `✗`. Do not read an empty Admin row as an oversight.

### 2.1 Three strings that appear on endpoints and in no matrix

`phase-01b` L91 and `[SIM §8.4]`. **Map each to a column; do not invent a policy:**

| String | Where | Resolves as |
|---|---|---|
| **`Receiving`** | `POST /rod` (endpoint 9) | **Upstream — not this service's to police.** ✅ **Moot since 25 Aug 2026:** `P-53` withdrew the whole `/rod/**` surface, so there is no longer an endpoint here to attach it to |
| **`Process Engineering / System Admin`** | `FW-004`, the alloy-lookup row | **Eng/Maint ✓ + Admin ✓** |
| **`Engineer`** | `[SIM §8.4]` / `[SEC §8.8b]`, the simulator control surface | **Eng/Maint.** `[SIM]` writes `Engineer`, which is not a matrix column — it is the same role, spelled short. `FW-218` names this story as its dependency for the policy, so **the policy is registered here and applied there** (§3.4, §7) |

### 2.2 The one anonymous endpoint

`[Authorize]` on every controller and every endpoint, with one documented exception:
**`GET /health` is "Any / anonymous per policy"**, and `[DEP]` gates the deployment smoke
test on an **unauthenticated** probe. See [`FW-148`](FW-148-Health-Checks.md).

⚠ **It is not mapped yet.** `Program.cs` registers `AddCustomHealthChecks` and deliberately does
not map the route (`FW-148` owns it), so **`TC-655`'s `/health` half cannot be run in this
story's window** — only the 22 `401`s can. Say so in the QA0 pack rather than recording a pass.

### 2.3 The supervisor PIN is not authentication into this service

`[SEC §8]`: the supervisor PIN **authenticates only** — it is *"never carried in the payload
and never stored"* (`OI-38`). It is an override credential on specific commands
(`/staging/rod`'s out-of-sequence override, Mode B checkout), not a second login. Do not
model it as a role or a claim.

⚠ **This is the reason most of the matrix is invisible to authorization**, and §3.4 is where
that becomes concrete: **`[API §4.5]` and `§4.5a` — and only those two — carry a
`supervisorOverride{supervisorBadge, supervisorPin, reason}` object inside the operator's own
request.** The caller stays the operator; the elevation rides in the payload. **A role policy
cannot see it, and must not be written as though it can.**

> ⚠ **The override has three shapes, and one of them is a contradiction.** Read this before
> writing a walkthrough step against any of them — none of it changes §3.4, and all of it is
> what a reviewer reading `[SEC §8]` alone will go looking for a policy to satisfy.
>
> | `[SEC §8]` says | What `[API]` actually specifies |
> |---|---|
> | The PIN *"is **never carried in the payload** and never stored"* | **It is carried in the payload.** `supervisorPin` is a request field in `§4.5`'s and `§4.5a`'s worked examples. *Never **stored*** holds (`§4.5a`, `§4.13`); *never carried* does not. **`[API]` is the built contract**, so `[SEC §8]`'s sentence is the half to correct |
> | Three PIN-gated overrides — *spool weight · off-schedule staging · out-of-sequence staging* | **Out-of-sequence staging** ✓ `§4.5`. **Off-schedule staging** — the deviation was **withdrawn 30 Jul 2026** (`FR-045`/`FR-046`: *"it covered two deviations until 30 Jul 2026"*) and `§4.5`'s `offSchedule` object went with it, so this item is **stale, not unimplemented**. **Spool weight** — ⚠ **no carrier at all** (§8) |
> | *(not among `[SEC]`'s three)* | **Mode B checkout** needs supervisor approval (`§4.13`) and carries `approvedBy` / `approvedAt` / `overrideReason` — **a stamp with no PIN field**, a third shape, enforced all-or-nothing by `CK_RodCheckout_Approval` |

---

## 3. What is inherited, and what is new

### 3.1 Inherited — do not rebuild

`AddCustomAuthentication(config)` in `UA.Framework.API` already does the JWT bearer setup,
and `FW-N04` step 6 already calls it. Its behaviour, verbatim from the framework
(`Framework/UA.Framework.API/Extensions/ServiceCollectionExtensions.cs`):

- the secret comes from a **double-indirect environment variable** —
  `GetEnvironmentVariable(GetEnvironmentVariable(UAJWTEnvironmentVariable))`
- `ValidateIssuer = false`, `ValidateAudience = false`, **`ValidateLifetime = false`**,
  `ClockSkew = TimeSpan.Zero`, `RequireHttpsMetadata = false`
- registers the scheme under the **name `JwtBearerDefaults.AuthenticationScheme`** and assigns a
  **whole new `TokenValidationParameters` instance** — which is why §3.5's hook is the only one
  that survives it
- registers `JWTSetting` as a singleton

> ⚠ **`ValidateLifetime = false` is the platform's existing choice**, and
> `UA_JWT_Token_Expiration_Minutes` is configured at 40. That combination means expiry is
> enforced at issue and not at validation. It is inherited behaviour, out of scope to change
> here, and worth knowing before anyone reports it as a finding against this story.

`AddCustomMvc()` — also inherited, also already called — sets two things worth knowing before
reading the callout below: a global
`AuthorizeFilter(new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build())`, and
**`options.EnableEndpointRouting = false`**. The second is what makes `P-55` counter-intuitive —
MVC is configured *away* from endpoint routing while `Program.cs` terminates in `MapControllers()`
anyway, so the pipeline is mixed and only the measurement settles what it needs.

> ### ⚠ `app.UseAuthorization()` — corrected 25 Aug 2026, and this section had it backwards
>
> **This section said, until 27 Aug 2026:** *"There is no `app.UseAuthorization()` in the UAL
> pipeline — authorization is enforced by the global `AuthorizeFilter` … Adding
> `UseAuthorization()` 'for completeness' changes behaviour."* **That is `FW-N04` step 6 rule 2,
> and `P-55` reversed it while building `FW-138`.**
>
> **The observation is true of `CoilCheckin` and false here, and the difference is the routing
> model.** `CoilCheckin` terminates in `UseMvc`, where the global filter alone suffices.
> `FW-N04`'s `Program.cs` terminates in **`MapControllers()`** — endpoint routing — and ASP.NET
> then *requires* the authorization middleware between `UseRouting` and the endpoint. Without it
> **all 22 endpoints returned `500`**, not `401`:
>
> ```
> 500 System.InvalidOperationException: Endpoint …LinesController.GetLinesStatusAsync
>     contains authorization metadata, but a middleware was not found that supports authorization.
> ```
>
> **It is in the built `Program.cs` today**, between `app.UseRouting()` and `app.MapControllers()`,
> with `P-55` cited in a comment. **This story adds no middleware line at all** — it adds
> registrations before `Build()` and attributes on actions. If you find yourself typing
> `app.UseAuthorization()`, stop: it is already there, and a second call re-runs the middleware.

### 3.2 New in this story

Four registrations before `Build()` and one attribute pass:

1. `FlatWireRoles` — the six claim-value constants (§5).
2. `FlatWirePolicies` — the policy-name constants, so no `[Authorize(Policy = "…")]` carries a
   literal.
3. `AddAuthorization(o => o.AddPolicy(…))` — **capability-scoped policies, `P-75`**, not one per
   role.
4. `PostConfigure<JwtBearerOptions>` — the hub's `?access_token=` handling, **`P-77`** (§3.5).

Then `[Authorize(Policy = …)]` on the actions §3.4 names, leaving the class-level bare
`[Authorize]` to carry the rest.

### 3.3 The policy shape — capability-scoped, because attributes AND-combine

**This is the correction that matters most, and it is a language rule rather than a judgement
call.**

- **Within one policy, `RequireRole(a, b, c)` is OR** — the principal needs any one of them.
- **Across attributes, `[Authorize]` is AND** — a controller-level `[Authorize]` plus an
  action-level `[Authorize(Policy = "X")]` means *authenticated **and** X*, and two action-level
  policy attributes mean **both**.

`P-17` said *"six policies, one per role column, each `RequireRole(FlatWireRoles.X)`"*. Now read
`[SEC §8]`: **every contested row admits two or more roles** — die swap is Operator ✓ Supervisor ✓
OpsMgr ✓ Eng ✓, dispose-WIP is Supervisor ✓ OpsMgr ✓ QA ✓, revert-roll-gap is OpsMgr ✓ Eng ✓. With
one policy per role there is no way to express any of them: stacking
`[Authorize(Policy="Supervisor")]` and `[Authorize(Policy="OperationsManager")]` demands **both
roles at once**, which no real principal holds, so the endpoint **fails closed for everyone** —
and it fails closed exactly the way a wrong claim value does, which is the one failure mode this
plan already knows it cannot see (§5).

**So policies are named for the capability, not the role**, each `RequireRole(…)` over the row's
permitted set. The six role constants stay; they are what the policies are built from.

### 3.4 Which of the 22 endpoints carries a policy — and it is four

`[SEC §8]` is keyed by **action**, `[API §9.2]` by **role**, and neither is keyed by endpoint. This
is the mapping, derived from both against `FW-138 §3`'s hosted 22. **`P-76` supplies
`ProductionTransaction`; without it every `bare` below extends to the write endpoints too.**

| # | Endpoint | `[SEC §8]` row that decides it | Policy |
|---|---|---|---|
| 1 | `GET /lines/status` | read-only; no row | *bare* |
| 10 | `GET /payoff/status` | read-only; no row | *bare* |
| 11 | `POST /staging/rod` | *Authorise off-schedule / out-of-sequence staging* — **PIN**, §2.3 | `ProductionTransaction` |
| 12 | `POST /staging/rod/unstage` | none; the override is the same PIN | `ProductionTransaction` |
| 14 | `GET /staging/queue` | read-only; no row | *bare* |
| 15 | `POST /checkin/rod` | *View pass schedule / acknowledge at check-in* (all six ✓) ⚠ see note | `ProductionTransaction` |
| 16 | `POST /checkin/spool` | as above | `ProductionTransaction` |
| 16a | `GET /spools` | read-only; no row | *bare* |
| 16b | `POST /spool/complete` | *Authorise an out-of-tolerance spool weight* — ⚠ **no carrier**, §8 | `ProductionTransaction` |
| 17 | `GET /run/active` | read-only; no row | *bare* |
| 18 | `GET /run/{runId}/gaugetrace` | read-only; no row | *bare* |
| 18a | `GET /run/{runId}/weldevents` | read-only; no row | *bare* |
| 19 | `POST /run/{runId}/pause` | none | `ProductionTransaction` |
| 20 | `POST /run/{runId}/resume` | none | `ProductionTransaction` |
| 21 | `POST /spc` | **SPC disposition at transaction finalisation** — Operator ✓(record) Supervisor ✓ OpsMgr ✓ QA ✓; **Eng ✗ Admin ✗** | **`SpcDisposition`** |
| 22 | `POST /weldevent` | *Supervisor override for weld removal / reversal* — **PIN** | `ProductionTransaction` |
| 23 | `POST /rolloverride` | **Apply roll-gap override (DB11)** — Operator ✓ Supervisor ✓ OpsMgr ✓ Eng ✓; **QA ✗ Admin ✗** | **`RollGapOverride`** |
| 24 | `POST /diechange` | **One-for-one same-size die swap at run** — Operator ✓ Supervisor ✓ OpsMgr ✓ Eng ✓; **QA ✗ Admin ✗** | **`DieChangeAtRun`** |
| 25 | `POST /checkout` | *Approve mid-run rod checkout (Mode B)* — **PIN**; the operator submits (`[API §9.2]`) | `ProductionTransaction` |
| 26 | `POST /wipreject` | **Flag WIP rejection** — all five operational roles; **Admin ✗** ⚠ see note | **`WipRejectionFlag`** |
| 27 | `POST /coil/complete` | none | `ProductionTransaction` |
| 28 | `GET /coil/{alpha}/label` | read-only; no row | *bare* |

**Eight reads bare · fourteen writes · four of the fourteen narrower than `ProductionTransaction`.**

Three notes, each of which looks like an error in the table until read:

- **`WipRejectionFlag` and `ProductionTransaction` have the same five members today.** Keep them
  separate anyway: `[SEC §8]` splits *flag* from **dispose** (Supervisor ✓ OpsMgr ✓ QA ✓,
  Operator ✗ Eng ✗), and the day dispose gets an endpoint (`OI-32`) one of the two narrows.
  Merging them now is what makes that change look like a new rule instead of a filled-in one.
- **`POST /wipreject` cannot enforce the flag/dispose split at all.** `[API §4.14]` puts
  `disposition` in the *flag* request, so one call does both and one policy governs both. Recorded
  in §8; **do not narrow the endpoint to the dispose set** — that would deny Operators the
  flagging `[SEC §8]` grants them.
- **Check-in is `ProductionTransaction`, not "all six".** The matrix row that mentions check-in
  grants *viewing and acknowledging the schedule* to all six; performing the check-in is a
  production transaction, which `[SEC §8]` says Admin owns none of. If `P-76` is not ratified,
  these fall back to bare `[Authorize]` and Admin can check a rod in.

**Registered here, applied elsewhere:** **`SimulatorControl`** — `RequireRole(EngineeringMaintenance,
Admin)`, per `[SIM §8.4]` / `[SEC §8.8b]`, for `FW-218`'s `/sim/**`. ⚠ **It is the backstop, not
the control** — those routes are *not registered at all* when simulation is off (`404`, not `403`).

**Not applied anywhere, because there is nothing to apply them to:** pass-schedule create / edit /
activate / mid-run override, revert-roll-gap, dispose-WIP, alloy-lookup CRUD, die management, view
shift summary, audit-log view. Each is MVP-2 or *"endpoint missing — `OI-32`"*. **A policy cannot be
applied to an endpoint that does not exist, and inventing one to hold a policy is worse than
leaving the capability unenforced.**

### 3.5 Hub authentication — and the only hook the inherited setup leaves you

`JwtBearerOptions.Events.OnMessageReceived` reading `access_token` from the query string when
the path is `/hubs/flatwire` (`[SIG §4]`) — the standard SignalR pattern, because browsers cannot
set an `Authorization` header on a WebSocket handshake. Hub methods carry `[Authorize]`.
[`FW-080`](FW-080-FlatWireHub.md) depends on this story for exactly this.

⚠ **`AddCustomAuthentication` already owns those options, and the two obvious ways to reach them
both fail — one loudly, one silently.** This is `P-77`:

| Attempt | What happens |
|---|---|
| `AddAuthentication().AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, o => o.Events = …)` | **Throws.** `AddScheme` records the scheme in `AuthenticationOptions`, and a second registration of the same name throws `InvalidOperationException: Scheme already exists: Bearer` when those options are first resolved — at the first request, not at startup |
| `services.Configure<JwtBearerOptions>(o => o.Events = …)` | **Silent no-op.** Unnamed `Configure` binds `Options.DefaultName` (`""`); the framework registered the scheme **by name**, so this delegate never runs and the hub simply refuses every connection |
| `services.PostConfigure<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme, …)` | ✅ **Correct.** Post-configure runs after every `Configure` for that name, whatever the registration order, and mutates the instance the framework built |

```csharp
// Program.cs, immediately after builder.Services.AddCustomAuthentication(builder.Configuration).
builder.Services.PostConfigure<JwtBearerOptions>(
    JwtBearerDefaults.AuthenticationScheme,
    options =>
    {
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                string? accessToken = context.Request.Query["access_token"];
                PathString path = context.Request.Path;

                // The hub only. Lifting the token off the query string for the REST surface
                // would put a bearer token in every IIS log line and every browser history.
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs/flatwire"))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            },
        };

        // Build-order step 2 ONLY. G6 says the claim is on ClaimTypes.Role, which RequireRole
        // reads by default - leave this commented out unless a real token says otherwise.
        // options.TokenValidationParameters.RoleClaimType = "role";
    });
```

⚠ **`Path` is post-`UsePathBase`.** `Program.cs` calls `app.UsePathBase(pathBase)` when the setting
is present, so under IIS the segment to match is `/hubs/flatwire` and **not** the deployed prefix.
Matching the full external path is the mistake that works on `localhost` and fails on the panel.

---

## 4. Build order

1. Confirm `AddCustomAuthentication` from `FW-N04`; do not re-implement it. Confirm
   `app.UseAuthorization()` is present between `UseRouting()` and `MapControllers()` — it is —
   and **add nothing to the pipeline** (§3.1).
2. **Confirm the role claim arrives on `ClaimTypes.Role`** — read one real token and look.
   `G6` says it does; this step is the five-minute check that it does *here*, before six
   policies are built on the assumption. If it does not, the single knob is
   `TokenValidationParameters.RoleClaimType` — set through §3.5's `PostConfigure`, **not** by
   editing the framework.
3. Write `FlatWireRoles` (six values) and `FlatWirePolicies` (the policy names) in
   `FlatWire.Domain/Constants/`. **Steps 3–6 do not wait on the value strings** — the constants
   compile against placeholders and the mapping lands in one file. ⚠ **Step 7 does wait**: the
   matrix walk cannot pass against placeholders (§5), which is the whole of what the residual
   gates.
4. Register the policies from `[SEC §8]`, capability-scoped per `P-75`. ⚠ **The first of the six
   is `P-76`'s, and `P-76` is *open*** — register the other five regardless; add
   `ProductionTransaction` only once `[SEC]` ratifies it:

   ```csharp
   builder.Services.AddAuthorization(options =>
   {
       // P-76. Every write endpoint. [SEC 8]: Admin owns no production transaction.
       options.AddPolicy(FlatWirePolicies.ProductionTransaction, policy => policy.RequireRole(
           FlatWireRoles.Operator, FlatWireRoles.Supervisor, FlatWireRoles.OperationsManager,
           FlatWireRoles.EngineeringMaintenance, FlatWireRoles.Qa));

       // SPC disposition at transaction finalisation - Eng and Admin excluded.
       options.AddPolicy(FlatWirePolicies.SpcDisposition, policy => policy.RequireRole(
           FlatWireRoles.Operator, FlatWireRoles.Supervisor, FlatWireRoles.OperationsManager,
           FlatWireRoles.Qa));

       // Apply a roll-gap override / one-for-one die swap - QA and Admin excluded. Same set
       // today, separate rows in [SEC 8], and the revert half (OpsMgr/Eng) has no endpoint.
       options.AddPolicy(FlatWirePolicies.RollGapOverride, policy => policy.RequireRole(
           FlatWireRoles.Operator, FlatWireRoles.Supervisor, FlatWireRoles.OperationsManager,
           FlatWireRoles.EngineeringMaintenance));

       options.AddPolicy(FlatWirePolicies.DieChangeAtRun, policy => policy.RequireRole(
           FlatWireRoles.Operator, FlatWireRoles.Supervisor, FlatWireRoles.OperationsManager,
           FlatWireRoles.EngineeringMaintenance));

       // Flag a WIP rejection - Admin excluded. Deliberately NOT merged with
       // ProductionTransaction: the dispose half narrows this to Supervisor/OpsMgr/QA.
       options.AddPolicy(FlatWirePolicies.WipRejectionFlag, policy => policy.RequireRole(
           FlatWireRoles.Operator, FlatWireRoles.Supervisor, FlatWireRoles.OperationsManager,
           FlatWireRoles.EngineeringMaintenance, FlatWireRoles.Qa));

       // Registered here, applied by FW-218 - and never the only control ([SEC 8.8b]).
       options.AddPolicy(FlatWirePolicies.SimulatorControl, policy => policy.RequireRole(
           FlatWireRoles.EngineeringMaintenance, FlatWireRoles.Admin));
   });
   ```

5. Apply `[Authorize(Policy = …)]` per §3.4: **the four narrower policies now** — `POST /spc`,
   `/rolloverride`, `/diechange`, `/wipreject` — and the ten `ProductionTransaction` attributes
   **only with `P-76`**, the ten staying on the class-level bare `[Authorize]` until then. The
   eight reads keep it permanently. **Never two policy attributes on one action** (§3.3).
6. Add the `?access_token=` `PostConfigure` for `/hubs/flatwire` (§3.5).
7. Walk the matrix (§6) — and read §6.1 first, because one acceptance criterion has nothing to
   run against.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-74` precede this story.

### `P-17` — six role constants from `[SEC §8]`

> **Restated 15 Aug 2026, and again 27 Aug 2026.** It read *"…and **one claim-type**
> constant"* until `G6` was answered; the claim type turned out to need no constant of ours —
> it is `ClaimTypes.Role` — and the six **values** turned out to need one each. **The
> policy half is superseded by `P-75`**: *"six policies, one per role"* cannot express a
> matrix whose every contested cell admits two or more roles. What survives is the constants.

Build the six role constants named for `[SEC §8]`'s columns. The card's list and its
rate-card basis both predate the six-role matrix; `[SEC §8]` and `phase-01b` L91 are the
later and explicit sources, and `[API §9.2]` defers to `[SEC §8]` by its own words.

Do **not** invent policies for `Receiving`, `Process Engineering / System Admin` or `Engineer`
(§2.1).

#### `G6`'s answer, and what it changed — 15 Aug 2026

**The six roles exist as JWT claims, on the standard `ClaimTypes.Role`.** Two consequences,
both good:

- **No framework change.** `UA.Framework.Common`'s `JWTClaims` struct defines only `UserId`,
  `EmailID` and `BadgeNo` — there is no role constant, and had the token used a UAL-specific
  name, one would have had to be added and the whole pack → `C:\Nuget\Repo` → clear cache →
  rebuild dance run for it, because the version never bumps off `1.0.0` (`FW-N04` §5).
- **No `RoleClaimType` configuration.** `ClaimTypes.Role` is what `RequireRole()` and
  `[Authorize(Roles = …)]` read by default. ⚠ *This plan said until 27 Aug 2026 that a bare
  `"role"` claim would have required editing the inherited `AddCustomAuthentication`. It would
  not — `P-77`'s `PostConfigure` reaches `TokenValidationParameters.RoleClaimType` from this
  service without touching the framework. The knob is local either way.*

#### The surviving unknown: six values, not one claim type

**The claim values are abbreviated or coded — they are not `[SEC §8]`'s labels.** So
`RequireRole("Operations Manager")` is wrong, and the mapping from the matrix's six labels to
the token's six strings is the outstanding item. The hedge therefore changes shape — **one
constant becomes six**:

```csharp
// FlatWire.Domain/Constants/FlatWireRoles.cs - the only place a role string is written.
public static class FlatWireRoles
{
    public const string Operator              = "TBD";   // ⚠ G6 residual
    public const string Supervisor            = "TBD";
    public const string OperationsManager     = "TBD";
    public const string EngineeringMaintenance = "TBD";
    public const string Qa                    = "TBD";
    public const string Admin                 = "TBD";
}
```

Policies bind to the constants, never to literals, so the mapping lands as a six-line change
in one file. **Record the mapping here when it arrives** — `[SEC §8]` is written in labels
and the token is not, so without a stated mapping the matrix cannot be checked against the
running system by anyone but its author.

> ⚠ **The failure mode is quiet, and `TC-655` does not catch it.** A wrong or placeholder
> value fails **closed**: `RequireRole` simply never matches, and a legitimate Supervisor
> gets `403` on every policy-gated endpoint. Bare `[Authorize]` endpoints keep working, and
> `TC-655` tests only that every endpoint *requires authentication*. **Nothing in the automated
> or scripted coverage distinguishes "correctly denied" from "denied because the string is
> wrong."** §6's cell-by-cell matrix walk is the only check that does, which makes it
> load-bearing rather than diligent. ⚠ **And §6.1 shows how little of that walk MVP-1 can
> run** — which makes the mapping's arrival, not the walk, the real gate.

### `P-75` — policies are capability-scoped, not role-scoped

**Settled — minted 27 Aug 2026, and it corrects `P-17`'s shape rather than its intent.**

One policy per `[SEC §8]` **row that has a hosted endpoint**, each `RequireRole(…)` over that
row's permitted set — not one policy per role column. §3.3 is the reasoning: multiple
`[Authorize]` attributes AND-combine, so a role-scoped policy set can express only single-role
cells, and `[SEC §8]` has none of those among its contested rows.

**The practical result is four policies on the hosted surface** — `SpcDisposition`,
`RollGapOverride`, `DieChangeAtRun`, `WipRejectionFlag` — plus `SimulatorControl` for `FW-218`
and, if ratified, `ProductionTransaction` from `P-76`. Everything else `[SEC §8]` restricts is
carried by the supervisor PIN (§2.3), is MVP-2, or has no endpoint (`OI-32`).

`P-17`'s six role constants are untouched and are what these policies are built from.

### `P-76` ⚠ — `ProductionTransaction` on the write surface, so the Admin row means something

**Raised 27 Aug 2026 — needs ratification.** `[SEC §8]` is explicit that **Admin owns no
production transaction**: *"an administrator does not check rod in, approve a checkout or dispose
of WIP … the emptiness is the definition rather than an omission."* But **ten of the fourteen
write endpoints have no matrix row at all** — check-in, staging, pause/resume, checkout,
weld event, spool and coil completion — so read strictly from the matrix they take bare
`[Authorize]`, and **an Admin token checks a rod in.**

**The proposal:** one `ProductionTransaction` policy — the five non-Admin roles — on every write
endpoint that has no narrower policy. It costs one policy and one attribute per action, and it
turns the matrix's stated intent into something enforced rather than described.

**The case against, stated fairly:** it denies on the basis of an *absence* in the matrix rather
than a `✗` in it, and if UA ever runs a break-glass administrative correction through the API it
is the rule that blocks it. **`[SEC]` owns the call.** Until it is ratified, build the four
policies of `P-75`; the ten fall back to bare `[Authorize]` and §3.4's `bare` column widens.

### `P-77` — `PostConfigure` the named scheme; never re-register it

**Settled — minted 27 Aug 2026.**

The hub's `?access_token=` handler, and any future change to the inherited
`TokenValidationParameters`, is attached with
`services.PostConfigure<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme, …)`.

**Both alternatives are traps and neither fails at build time** — a second `AddJwtBearer` on the
same scheme name throws *"Scheme already exists: Bearer"* at the first request, and an unnamed
`services.Configure<JwtBearerOptions>` binds the default name and never runs at all, leaving a
hub that refuses every connection with nothing in the log to say why. §3.5 has the table and the
code.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes AC 4 as written. The
behaviour it described is covered manually by **`TC-655`** (auth on every endpoint, excepting
the anonymous `/health`) and by the matrix walk **`TC-640`–`TC-654`** in `[TCS §10.3]`, in the
QA0 walkthrough.

| AC | How it is checked |
|---|---|
| JWT inherited | A valid token authenticates; an absent one returns `401` on all **22** endpoints *(24 until `FW-138`'s `P-53` withdrew `/rod/**`, 25 Aug 2026)*. ⚠ `/health` is not mapped yet (§2.2) |
| Hub auth | A hub connection with `?access_token=` succeeds; without it, fails. ⚠ **The handler is this story's; the evidence is not available until [`FW-080`](FW-080-FlatWireHub.md) maps `/hubs/flatwire`** — until then there is nothing to connect to. Carry it to `FW-080`'s *Auth* verification row rather than recording an untested pass |
| Role policies | `TC-640`–`TC-654`, cell by cell — ⚠ **but only one of those fifteen has an endpoint in MVP-1**; see §6.1. **The permitted half is the load-bearing one** — it is the only check in the whole plan that catches a wrong role-value mapping (§5), which otherwise presents as a uniform, plausible `403` |
| *(AC 4, restated)* | ⚠ **Not executable as written** — §6.1. Substitute: a **QA** token against `POST /diechange` returns **`403`**, not `401` and not `200` |

`GET /health` must answer an **unauthenticated** probe — `[DEP]`'s smoke test depends on it,
and it is the one endpoint that would look like a defect if it returned `401`.

⚠ **A `403` here has an empty body, not the `Data`/`Success`/`Errors` envelope.** The
authorization middleware short-circuits before the action runs, so `FW-146`'s middleware never
sees it — [`FW-146`](FW-146-Exception-Middleware-And-Envelope.md) §2 maps `401`/`403` to
*"handled by the auth layer, not here"*. **Check the status code, not the payload** — a
walkthrough script that asserts an error envelope on a `403` fails a passing system.
*(✅ **Fixed in `FW-146` on 27 Aug 2026.** That plan's §4 had said `401`/`403` come from the global
`AuthorizeFilter` because *"there is no `app.UseAuthorization()`"* — right destination, `P-55`'s
mechanism. It now carries the correction, and the empty-body consequence above is its **§2.6**.)*

### 6.1 ⚠ AC 4 has nothing to run against, and this is the review's sharpest finding

AC 4 asks for *"an operator cannot reach an Ops-Manager-only endpoint."* **There is no
Ops-Manager-only endpoint in MVP-1.** Every one of `[SEC §8]`'s Ops-Manager-restricted
capabilities is unreachable for one of three reasons:

| `[TCS §10.3]` case | Capability | Why it cannot run here |
|---|---|---|
| `TC-640` `TC-641` `TC-642` | Pass schedule create / edit / activate / mid-run override | `PassScheduleController` has **no actions** — MVP-1 exposes no pass-schedule endpoint (`FW-138 §3.1`) |
| `TC-643` | **One-for-one same-size die swap at run** | ✅ **Runs** — `POST /diechange`, and **QA is the denied role** |
| `TC-644` | Revert a roll-gap override | *"There is no revert endpoint"* — `[API §4.11]`, `OI-32` |
| `TC-645` `TC-647` `TC-648` | Approve mid-run checkout · weld removal · out-of-sequence staging | **A supervisor credential in the operator's own request** (§2.3) — invisible to a policy. ⚠ `TC-648`'s *off-schedule* half is stale: that deviation was withdrawn 30 Jul 2026 (`FR-046`) |
| `TC-649` | Authorise an out-of-tolerance spool weight | ⚠ **Worse than credential-carried — there is no carrier at all.** `[API §4.6c]` gives the acknowledgement to the operator (§8), so the case cannot pass in any form |
| `TC-646` `TC-650` `TC-652` | Approve partial-run disposition · dispose WIP · alloy-lookup CRUD | *"endpoint missing"* — `[API §9.2]`, `OI-32` |
| `TC-651` `TC-653` | Die management · view shift summary | MVP-2; `ShiftSummaryController` has no actions |
| `TC-654` | Supervisor override for un-punched login | The `Login` service, not this one |

**One of fifteen.** So the matrix walk that §5 calls *"load-bearing rather than diligent"* has, on
the MVP-1 surface, **two executable denials — three if `P-76` is ratified** — and two of the three
exist only because this plan derived them from the matrix rather than from `[TCS]`:

| Walk | Expect | Why it is the only evidence |
|---|---|---|
| **QA** → `POST /diechange` | `403` | `TC-643`, the one runnable matrix case |
| **Eng/Maint** → `POST /spc` | `403` | `[SEC §8]`'s SPC row — **no `TC-###` covers it** |
| **Admin** → `POST /checkin/rod` | `403` | Only if `P-76` is ratified; otherwise `201` and the Admin row is unenforced |
| **Operator · Supervisor · OpsMgr** → each of the four policy-gated endpoints | the contract's success status | ⚠ **The permitted half.** All three are members of all four policies, so this is where a wrong claim value shows up — and it is the *only* place |

**State this in the QA0 pack rather than discovering it there.** Recording *"TC-640–TC-654
walked"* against a surface that can run one of them is how a matrix comes to be believed
enforced when it is not.

---

## 7. Handoff

[`FW-080`](FW-080-FlatWireHub.md) lists this story in its `Dependencies` — it cannot
authenticate a hub connection without §3.5. `FW-138`'s controllers carry bare `[Authorize]`
and gain policies here. `FW-205`'s `ITInhibit` service has **no operator path by design** and
needs no policy — that is enforced by the absence of an endpoint, not by authorization.

Two more consumers, both of which bind on §5's constants rather than on a policy:

- [`FW-177`](FW-177-Exception-Broadcasts.md) targets *"the Supervisor role"* by joining a
  `Supervisors` SignalR group, reading `FlatWireRoles.Supervisor` from this story (§3.1 there).
  ⚠ **Its exposure to a wrong value is worse than this story's**: a bad policy denies loudly, an
  empty group **notifies nobody and raises no error anywhere.**
- [`FW-218`](FW-218-Sim-Control-Surface.md) applies `SimulatorControl` (§3.4) to `/sim/**`, on
  top of conditional route registration. **Never `Operator`**, and never the policy alone.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`G6` / `OI-37`** | ✅ **Largely closed, 15 Aug 2026.** The six roles **do** exist as JWT claims, on `ClaimTypes.Role` — so the *"can block the build outright"* reading is spent, and `[TRP §6]` blocker 4 no longer threatens T1 close. ⚠ **Residual: the six claim *values* are abbreviated or coded and the label→value mapping is not yet supplied.** It does not block building — §5's six-constant class absorbs it — but it blocks *verifying*, because §6's matrix walk cannot pass against placeholder strings. **Needed before the QA0 walkthrough, not before the build** |
| **`OI-38`** | The supervisor PIN's **validation source**, undecided. **It is why most of `[SEC §8]` is invisible to authorization** (§2.3, §6.1) — the credential rides in the operator's request, so no policy sees it |
| **`OI-32`** | `[API §9.2]` marks five role capabilities *"endpoint missing"*. **A policy cannot be applied to an endpoint that does not exist**; four are MVP-1. §6.1 quantifies the cost: it is most of the matrix walk |
| **`P-76`** ⚠ | **Raised here, `[SEC]`'s to ratify.** Ten write endpoints have no matrix row, so *"Admin owns no production transaction"* is unenforceable without a policy the matrix does not literally state |
| ⚠ **New — the out-of-tolerance spool weight has no carrier** | `[SEC §8]` restricts *authorising an out-of-tolerance spool weight* to Supervisor / OpsMgr and names it one of **three PIN-gated overrides**. But `[API §4.6c]` marks `POST /spool/complete` **"Role: Operator"** and carries only `varianceAcknowledged: bool` — **no `supervisorOverride` object and no approval stamp** — where `§4.5`/`§4.5a` carry the full object and `§4.13` at least carries a stamp (§2.3). **So `TC-649` cannot pass against the built contract** and the override is enforced nowhere. `[API]`'s to specify, with `OI-38`; **do not invent the field here** |
| ⚠ **New — `[SEC §8]` says the PIN is never carried in the payload; `[API]` carries it** | `§4.5` and `§4.5a` put `supervisorPin` in the request body. *Never stored* is consistent across both documents; *never carried* is not, and the built contract is the one operators will hit. It changes nothing this story builds — recorded so it is corrected in `[SEC]` rather than rediscovered as a defect against an endpoint. See §2.3 |
| ⚠ **New — the actor is taken from the body, not the token** | Every write contract carries `operatorId` (and `[API §4.5]` a `supervisorBadge`) as **request fields**, while the authenticated identity sits in the JWT and nothing requires the two to agree. Authorization answers *may this role act*; it does not answer *is this the actor they claim to be* — and `NFR010`/`NFR011`'s audit trail is written from the payload. **Raised for `[SEC]`/`[API]`**; the fix is a reconciliation rule, not a policy, and is out of this story as scoped |

| Stale | Correct | Source |
|---|---|---|
| AC 3 lists **five** roles — QA missing | **Six**: Operator · Supervisor · Operations Manager · Engineering/Maintenance · QA · Admin | `[SEC §8]`, `phase-01b` L91 |
| AC 3 cites **`04-APIContract.md`'s matrix** | `[SEC §8]` is the matrix of record; `[API §9.2]` is a summary and defers to it | `phase-01b` L91 |
| AC 4: *"Authorization tests prove…"* | Withdrawn 15 Aug 2026; covered by `TC-640`–`TC-655` manually — ⚠ and **not executable as written** (§6.1) | `[TS §1.2]` |
| Rate-card basis: *"auth + **five** role policies"* | Six roles; **four policies bind** on the hosted surface (§3.4) | `[SEC §8]`, `FW-138 §3` |
| `FW-N04` step 6 rule 2 / this document's own §3.1 before 27 Aug 2026: *"no `app.UseAuthorization()`"* | **Required**, between `UseRouting()` and `MapControllers()` — already in `Program.cs` | `P-55` (`FW-138 §5`) |
| `[TCS]` `TC-655`: *"`401` on all **25** MVP-1 endpoints"* | **22** are hosted — `P-53` withdrew the three `/rod/**` rows, `/health` is anonymous and `POST /order/{orderNo}/complete` has no host | `FW-138 §2.1`, `P-50`, `P-53` |
| ~~⚠ **`FW-146` §4 (`P-18`)**: *"there is no `app.UseAuthorization()` in this pipeline, so `401`/`403` come from the global `AuthorizeFilter`"*~~ | The **conclusion holds** — neither code reaches that middleware — but the **mechanism** is the authorization middleware, which `P-55` added on 25 Aug. ✅ **Fixed in `FW-146` on 27 Aug 2026**, along with the empty-body `403` consequence (its new §2.6) | `P-55`, and the built `Program.cs` |
| `[SEC §8]`: three PIN-gated overrides, one of them *off-schedule staging* | **Two deviations became one on 30 Jul 2026** — `FR-045`/`FR-046` keep only *out of sequence*, and `[API §4.5]`'s `offSchedule` object was removed 1 Aug 2026 | `FR-046`, `[API §4.5]` |
| `P-17` as first written: *"six policies, one per role"* | Superseded by **`P-75`** — attributes AND-combine, so role-scoped policies cannot express a multi-role cell | §3.3 |
