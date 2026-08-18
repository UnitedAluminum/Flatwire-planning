# FW-145 · JWT authentication and role authorization policies

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — **`G6`/`OI-37` largely closed**: the six roles exist as JWT claims on `ClaimTypes.Role`; only the six **value strings** remain outstanding (`P-17` restated)
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

---

## 2. Six roles, not five

`[SEC §8]` and `phase-01b` L91 — **the matrix of record, all six with a column**:

**Operator · Supervisor · Operations Manager · Engineering/Maintenance · QA · Admin**

The card's list omits **QA**, which is a real role with real capability — `/wipreject`
dispose and SPC-HOLD release (`[API §9.2]`).

> **`Admin` is a *platform* role** — provisioning, environment configuration, reference data,
> audit-log access — and owns **no production transaction**, which is why most of its cells
> are `✗`. Do not read an empty Admin row as an oversight.

### 2.1 Two strings that appear on endpoints and in no matrix

`phase-01b` L91. **Map each to a column; do not invent a policy:**

| String | Where | Resolves as |
|---|---|---|
| **`Receiving`** | `POST /rod` (endpoint 9) | **Upstream — not this service's to police** |
| **`Process Engineering / System Admin`** | `FW-004`, the alloy-lookup row | **Eng/Maint ✓ + Admin ✓** |

### 2.2 The one anonymous endpoint

`[Authorize]` on every controller and every endpoint, with one documented exception:
**`GET /health` is "Any / anonymous per policy"**, and `[DEP]` gates the deployment smoke
test on an **unauthenticated** probe. See [`FW-148`](FW-148-Health-Checks.md).

### 2.3 The supervisor PIN is not authentication into this service

`[SEC §8]`: the supervisor PIN **authenticates only** — it is *"never carried in the payload
and never stored"* (`OI-38`). It is an override credential on specific commands
(`/staging/rod`'s out-of-sequence override, Mode B checkout), not a second login. Do not
model it as a role or a claim.

---

## 3. What is inherited, and what is new

### 3.1 Inherited — do not rebuild

`AddCustomAuthentication(config)` in `UA.Framework.API` already does the JWT bearer setup,
and `FW-N04` step 6 already calls it. Its behaviour, verbatim from the framework:

- the secret comes from a **double-indirect environment variable** —
  `GetEnvironmentVariable(GetEnvironmentVariable(UAJWTEnvironmentVariable))`
- `ValidateIssuer = false`, `ValidateAudience = false`, **`ValidateLifetime = false`**,
  `ClockSkew = TimeSpan.Zero`, `RequireHttpsMetadata = false`
- registers `JWTSetting` as a singleton

> ⚠ **`ValidateLifetime = false` is the platform's existing choice**, and
> `UA_JWT_Token_Expiration_Minutes` is configured at 40. That combination means expiry is
> enforced at issue and not at validation. It is inherited behaviour, out of scope to change
> here, and worth knowing before anyone reports it as a finding against this story.

**There is no `app.UseAuthorization()`** in the UAL pipeline — authorization is enforced by
the global `AuthorizeFilter(RequireAuthenticatedUser())` that `AddCustomMvc()` adds.
Adding `UseAuthorization()` "for completeness" changes behaviour.

### 3.2 New in this story

Role **policies** — `AddAuthorization(o => o.AddPolicy(...))` — one per role column, plus
`[Authorize(Policy = …)]` on the endpoints that need more than "authenticated". And the hub's
`?access_token=` handling.

### 3.3 Hub authentication

`JwtBearerOptions.Events.OnMessageReceived` reading `access_token` from the query string when
the path is `/hubs/flatwire` — the standard SignalR pattern, because browsers cannot set an
`Authorization` header on a WebSocket handshake. Hub methods carry `[Authorize]`.
[`FW-080`](FW-080-FlatWireHub.md) depends on this story for exactly this.

---

## 4. Build order

1. Confirm `AddCustomAuthentication` from `FW-N04`; do not re-implement it.
2. **Confirm the role claim arrives on `ClaimTypes.Role`** — read one real token and look.
   `G6` says it does; this step is the five-minute check that it does *here*, before six
   policies are built on the assumption. If it does not, `TokenValidationParameters.
   RoleClaimType` is the single knob — see §5.
3. Define **six** policies from `[SEC §8]`, each `RequireRole(FlatWireRoles.X)` against the
   six-constant class in §5. **Steps 3–6 do not wait on the value strings** — the constants
   compile against placeholders and the mapping lands in one file.
4. Apply `[Authorize(Policy = …)]` per `[SEC §8]`, leaving bare `[Authorize]` where the
   answer is "any authenticated".
5. Add the `?access_token=` event handler for `/hubs/flatwire`.
6. Walk the matrix manually (§6).

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-16` precede this story.

### `P-17` — six policies from `[SEC §8]`, and six role constants

> **Restated 15 Aug 2026.** This decision read *"…and **one claim-type** constant"* until
> `G6` was answered. The claim type turned out to need no constant of ours — it is
> `ClaimTypes.Role` — and the six **values** turned out to need one each. Same intent,
> different object.

**Build six policies, not five**, named for `[SEC §8]`'s columns. The card's list and its
rate-card basis both predate the six-role matrix; `[SEC §8]` and `phase-01b` L91 are the
later and explicit sources, and `[API §9.2]` defers to `[SEC §8]` by its own words.

Do **not** invent policies for `Receiving` or `Process Engineering / System Admin` (§2.1).

#### `G6`'s answer, and what it changed — 15 Aug 2026

**The six roles exist as JWT claims, on the standard `ClaimTypes.Role`.** Two consequences,
both good:

- **No framework change.** `UA.Framework.Common`'s `JWTClaims` struct defines only `UserId`,
  `EmailID` and `BadgeNo` — there is no role constant, and had the token used a UAL-specific
  name, one would have had to be added and the whole pack → `C:\Nuget\Repo` → clear cache →
  rebuild dance run for it, because the version never bumps off `1.0.0` (`FW-N04` §5).
- **No `RoleClaimType` configuration.** `ClaimTypes.Role` is what `RequireRole()` and
  `[Authorize(Roles = …)]` read by default. A bare `"role"` claim would have needed
  `TokenValidationParameters.RoleClaimType` set inside the *inherited*
  `AddCustomAuthentication`, i.e. a local override of framework configuration.

**This plan's original hedge is superseded, because it bounded the unknown that evaporated.**
It proposed routing every policy through one claim-type constant in
`Domain/Constants/Constants.cs`. That constant is now unnecessary — .NET supplies
`ClaimTypes.Role` — and the unknown that *survived* is one the hedge did not cover.

#### The surviving unknown: six values, not one claim type

**The claim values are abbreviated or coded — they are not `[SEC §8]`'s labels.** So
`RequireRole("Operations Manager")` is wrong, and the mapping from the matrix's six labels to
the token's six strings is the outstanding item. The hedge therefore changes shape — **one
constant becomes six**:

```csharp
// Domain/Constants/FlatWireRoles.cs — the only place a role string is written.
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
> gets `403` on every policy-gated endpoint. Bare `[Authorize]` endpoints — the 24 from
> `FW-138` — keep working, and `TC-655` tests only that every endpoint *requires
> authentication*. **Nothing in the automated or scripted coverage distinguishes "correctly
> denied" from "denied because the string is wrong."** §6's cell-by-cell matrix walk is the
> only check that does, which makes it load-bearing rather than diligent.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes AC 4 as written. The
behaviour it described is covered manually by **`TC-655`** (auth on every endpoint, excepting
the anonymous `/health`) in the QA0 walkthrough.

| AC | How it is checked |
|---|---|
| JWT inherited | A valid token authenticates; an absent one returns `401` on all 24 endpoints |
| Hub auth | A hub connection with `?access_token=` succeeds; without it, fails |
| Role policies | Walk `[SEC §8]` cell by cell — for each role, one permitted and one forbidden endpoint, expecting `403` on the second. ⚠ **The permitted half is the load-bearing one** — it is the only check in the whole plan that catches a wrong role-value mapping (§5), which otherwise presents as a uniform, plausible `403` |
| *(AC 4, restated)* | An Operator token against an Ops-Manager-only endpoint returns **`403`**, not `401` and not `200` |

`GET /health` must answer an **unauthenticated** probe — `[DEP]`'s smoke test depends on it,
and it is the one endpoint that would look like a defect if it returned `401`.

---

## 7. Handoff

[`FW-080`](FW-080-FlatWireHub.md) lists this story in its `Dependencies` — it cannot
authenticate a hub connection without §3.3. `FW-138`'s controllers carry bare `[Authorize]`
and gain policies here. `FW-205`'s `ITInhibit` service has **no operator path by design** and
needs no policy — that is enforced by the absence of an endpoint, not by authorization.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`G6` / `OI-37`** | ✅ **Largely closed, 15 Aug 2026.** The six roles **do** exist as JWT claims, on `ClaimTypes.Role` — so the *"can block the build outright"* reading is spent, and `[TRP §6]` blocker 4 no longer threatens T1 close. ⚠ **Residual: the six claim *values* are abbreviated or coded and the label→value mapping is not yet supplied.** It does not block building — §5's six-constant class absorbs it — but it blocks *verifying*, because §6's matrix walk cannot pass against placeholder strings. **Needed before the QA0 walkthrough, not before the build** |
| **`OI-38`** | The supervisor PIN's handling — authenticates only, never carried, never stored |
| **`OI-32`** | `[API §9.2]` marks five role capabilities *"endpoint missing"*. **A policy cannot be applied to an endpoint that does not exist**; four are MVP-1 |

| Stale | Correct | Source |
|---|---|---|
| AC 3 lists **five** roles — QA missing | **Six**: Operator · Supervisor · Operations Manager · Engineering/Maintenance · QA · Admin | `[SEC §8]`, `phase-01b` L91 |
| AC 3 cites **`04-APIContract.md`'s matrix** | `[SEC §8]` is the matrix of record; `[API §9.2]` is a summary and defers to it | `phase-01b` L91 |
| AC 4: *"Authorization tests prove…"* | Withdrawn 15 Aug 2026; covered by `TC-655` manually | `[TS §1.2]` |
| Rate-card basis: *"auth + **five** role policies"* | Six | `[SEC §8]` |
