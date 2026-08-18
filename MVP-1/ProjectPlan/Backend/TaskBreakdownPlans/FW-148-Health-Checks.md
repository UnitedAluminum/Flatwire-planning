# FW-148 · Health checks

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **pin the route decision here (§5, `P-20`)**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-148`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Eight hours, and it is the only endpoint in the service that
> is **anonymous**, the only one with **no controller**, and the one whose route two
> specifications state differently. `phase-01b` L95 does not resolve that disagreement — it
> assigns it: *"base-relative; `[DEP]` calls the absolute `/api/v1/flatwire/health`, **so pin
> the routing decision here**."* This story is where it gets pinned, and a deployment smoke
> suite probes whatever is decided.
>
> It also has a **third consumer nobody reads about in the card**: `[MON]` instruments hub
> connection count and broadcast-cadence deviation off this surface.

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
`UIResponseWriter.WriteHealthCheckUIResponse` either — which is what `CoilCheckin` uses.
A custom `ResponseWriter` is required.

### 2.2 Three consumers, three different needs

| Consumer | Needs |
|---|---|
| `[DEP]` | Gates deployment on **`database.reachable` *and* `opc.reachable`**; the smoke test probes it **unauthenticated** |
| `[MON]` | Alerts when not-healthy, **or `opc.reachable` false for more than 2 minutes**; also instruments **hub connection count** and **broadcast-cadence deviation** |
| Operators | Indirectly — *"a failing dependency is visible before an operator finds it"* |

> The `[MON]` row is the one the card omits. **Hub connection count and broadcast-cadence
> deviation are hub code this layer writes** (`phase-01b` L95). They are metrics rather than
> health checks — a hub with zero connections at 3 a.m. is not unhealthy — so expose them as
> instrumentation, not as gating checks. Coordinate with
> [`FW-080`](FW-080-FlatWireHub.md); the hub does not exist until it lands.

### 2.3 Anonymous, and it is the only one

`[Authorize]` on every controller and endpoint, with **one documented exception**:
`GET /health` is *"Any / anonymous per policy"* and `[DEP]` gates the deploy smoke test on an
**unauthenticated** probe. It has **no controller** — `[API §3.2]` row 30 leaves the
controller column empty — so it is mapped in `Program.cs`.

This matters twice over: `AddCustomMvc()` installs a **global**
`AuthorizeFilter(RequireAuthenticatedUser())`, so an MVC-routed health endpoint would be
protected by default. Mapping it outside MVC — `UseHealthChecks(...)` before
`UseAuthentication()`, as `CoilCheckin` does — sidesteps that cleanly.

### 2.4 What `CoilCheckin` actually has, and why it is not enough

`CoilCheckin` registers `hcBuilder.AddCheck("self", () => HealthCheckResult.Healthy())` —
that is all — and exposes two routes: `/liveliness` (predicate `Name.Contains("self")`) and
`/hc` (everything). **Neither is `/health`, and neither checks anything real.** This story
adds the database and OPC checks and the documented shape.

> Use **`AddCustomHealthChecks`**, not `AddHealthChecks` — `CoilCheckin`'s local extension
> shadows the built-in; `UATemplate` renamed it and `FW-N04` step 6 kept the rename.

---

## 3. Build order

1. **Pin the route** — `P-20`.
2. **Database check** — `AspNetCore.HealthChecks.SqlServer` is already in
   `API/Directory.Packages.props` at 8.0.2. Measure `latencyMs`.
3. **OPC check** — reachability of `API.OPCConnection` via `RestClient`, with **Polly** on
   the outbound call (`phase-01b` L97). Under `SimulatePLCTagPush = true` it reports
   **simulated-healthy**, which is AC 2 and is the normal state in every environment until
   commissioning.
4. **Custom `ResponseWriter`** emitting §2.1's shape, including `version` and `environment`.
5. **Non-200 when unhealthy**, naming the failing check (AC 3).
6. **Confirm anonymity** — probe with no `Authorization` header.
7. **Hub instrumentation** — after `FW-080`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-19` precede this story.

### `P-20` — serve `/health` at **both** paths; the absolute one is canonical

**Needs ratifying.** Two specifications disagree and `phase-01b` L95 assigns the tiebreak
here:

| Source | Route |
|---|---|
| `[API §3.2]` row 30, the card, `phase-01b` L95 | `/health` — **base-relative** |
| `[DEP]` | `/api/v1/flatwire/health` — **absolute** |

They are less far apart than they look. With `PATH_BASE = /API.FlatWire` on IIS, a
base-relative `/health` is served at `/API.FlatWire/health` — which is neither of the two
strings above.

**Resolution: map the health endpoint at both `/health` and `/api/v1/flatwire/health`, and
treat the absolute path as canonical.** `[DEP]`'s smoke suite and `[MON]`'s alerting are the
things that break if the path is wrong, and both use the absolute form; the base-relative
form costs one extra `UseHealthChecks` line and keeps every document's literal text true.

**Record the chosen canonical path in `[DEP]` and `[API §4.19]`** so the next reader finds
one answer rather than this analysis. Mapping both is the pragmatic resolution, not a
licence to leave the disagreement unrecorded.

*(`CoilCheckin`'s `/liveliness` and `/hc` are its own; do not inherit those names.)*

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. The deployment smoke suite in `[DEP §5]` is the real
consumer and is a deployment gate rather than a unit test.

| AC | How it is checked |
|---|---|
| Health checks at `/health` covering DB and OPC | Both checks present; both report `reachable` and `latencyMs` |
| Green in Development, OPC simulated-healthy | With `SimulatePLCTagPush = true`, `status: "Healthy"` and `opc.reachable: true` |
| Unhealthy names the failing check | Stop SQL Server → non-200, `database.reachable: false`, the failing check named |
| **Anonymous** | `curl` with **no** `Authorization` header returns 200. `TC-655` excepts this endpoint from the auth sweep |
| Shape | Exactly `[API §4.19]`'s five members — **not** the `UIResponseWriter` shape |
| Both routes *(`P-20`)* | `/health` and `/api/v1/flatwire/health` both answer |

---

## 6. Handoff

`[DEP]` gates deployment on this. `[MON]` alerts on it and adds the hub metrics once
`FW-080` lands. It is the first thing anyone checks when the service misbehaves, which is
why the shape and the anonymity both matter more than the eight hours suggest.

---

## 7. Open items and stale citations

| Item | Effect here |
|---|---|
| **`P-20`** | The route disagreement, assigned to this story to settle |
| **`G9` / `OI-34`** | Real-time NFRs are undefined, so broadcast-cadence deviation **has no threshold to alert against**. Instrument the metric; the alarm level is not yours to invent |
| **`G10`** | IIS WebSockets must be enabled — a deployment prerequisite this endpoint cannot detect |

No stale citations found in this story's card. Note only that `CoilCheckin`'s health
extension is named `AddHealthChecks` and shadows the built-in; use `AddCustomHealthChecks`.
