# FW-140 · DI registration and the stub/real service swap

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-140`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** The story card names the flag **`useStub`**. It is
> **`useMockData`**, and `phase-01b` L84 says so in as many words. The name is not cosmetic:
> 1A's `environment.development.ts` and `[API §7.1]` both use `useMockData`, and a backend
> flag with a different name means the two halves of the stub contract are configured by two
> switches that can disagree.
>
> The second thing worth knowing is that there are **three** independent simulation switches
> in this service and they are not the same switch — §2.2.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-140 · DI registration and the stub/real service swap
> **Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** developer,
> **I want** interface-driven services swappable between stub and real by configuration,
> **So that** 1A can integrate before the database is populated.
>
> **Acceptance Criteria:**
> - [ ] `Program.cs` service registration; every service behind an interface
> - [ ] `useStub` / environment swap of stub vs real implementations, as in `CoilCheckin`
> - [ ] With `useStub` on, the API serves schema-valid fixtures end to end
>
> **Rate-card basis:** DI + configuration swap (12 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** —

⚠ **Read `useStub` as `useMockData` throughout.** `phase-01b` L84: *"**Flag name:
`useMockData`**, matching `[API §7.1]` and 1A — *not* `useStub`."*

### 1.1 In scope

`AddPersistence`-equivalent service registration · every service behind an interface ·
the `useMockData` swap · proving fixtures serve end to end with it on.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The fixtures themselves, and the controllers serving them | [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) |
| MediatR handler registration | [`FW-139`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) |
| Repository registration — `FW-141` writes them, this story registers the shape | [`FW-141`](FW-141-Repository-Layer.md) |
| Binding the flag out of configuration | [`FW-144`](FW-144-Configuration-Binding.md) |
| `SimulatePLCTagPush` and `IReadingSource` — **different switches** (§2.2) | `FW-151`, `FW-N05`/`FW-211` |
| The Angular half of the stub contract | 1A |

---

## 2. Precedence and the three switches

| Question | Authority |
|---|---|
| The flag name and the stub mechanism | `[API §7.1]`, `phase-01b` L84 |
| What a stub must return | `[API §7.2]` |
| Layering — what may be registered where | `[SVC §3.2]` |
| The registration pattern | `CoilCheckin.Infrastructure/DependencyInjectionRegistry.cs` |

### 2.1 The pattern to copy

`CoilCheckin`'s `AddPersistence(this IServiceCollection, IConfiguration)` registers every
service behind its interface with `AddScoped`, including `RestClient` — which is how a
domain calls a sibling service, and the hook FlatWire uses to reach `API.OPCConnection`.

Under `FW-N04` decision `P-02` the registration is invoked from `Program.cs` in
`FlatWire.API`. Keep the extension method; move only where it is called from.

### 2.2 ⚠ Three switches, three owners — do not collapse them

| Switch | Chooses | Default | Owner |
|---|---|---|---|
| **`useMockData`** | stub vs real **service implementations** | on in Development only | **this story** |
| **`SimulatePLCTagPush`** | whether a PLC **write** actually reaches a controller — a simulated write **logs the write it would have made** | **`true` in every environment until commissioning** | `FW-151` |
| **`IReadingSource`** | which **telemetry feed** is live — real OPC ingest vs the simulator, two implementations of one interface, DI-swapped, neither aware of the other | per environment | `FW-N05` / `FW-211` |

`SimulatePLCTagPush` is **not** a dev-only mode and is selected **by configuration, not by
call site** (`phase-01b` L109). A build that ties any of these three to
`IWebHostEnvironment.IsDevelopment()` has merged switches that must stay separate.

---

## 3. Build order

1. **Define the service interfaces.** Every service behind one — `[SVC §3.2]`. Names come
   from the phase that builds each; this story establishes the registration shape, not the
   inventory.
2. **`DependencyInjectionRegistry.AddPersistence`** in `FlatWire.Infrastructure`, invoked
   from `Program.cs`. Register `IMediator`, the repository open generic, `RestClient`, and
   the services.
3. **Bind `useMockData`** from configuration (`FW-144` owns the binding; consume it here).
4. **The swap.** Register the stub or the real implementation against the same interface:
   ```csharp
   if (useMockData) services.AddScoped<ILineStatusService, StubLineStatusService>();
   else             services.AddScoped<ILineStatusService, LineStatusService>();
   ```
   Decide the registration **once at startup**, not per request — see `P-11`.
5. **Prove it end to end** — with `useMockData` on, every one of `FW-138`'s 24 endpoints
   returns its schema-valid fixture with no database present.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-10` precede this story.

### `P-11` — the swap is resolved at startup, and the flag is `useMockData`

**Name:** `useMockData`, matching `[API §7.1]` and 1A. The story card's `useStub` is
superseded; `phase-01b` L84 is explicit and the exit criterion at L171 uses `useMockData`
too.

**Mechanism:** branch at registration time in `Program.cs`, not behind a factory or a
decorator resolved per request. Reasons: the choice is environmental and cannot change
within a process; a startup branch makes the active set visible in one place at boot; and a
per-request factory would have to be threaded through every handler, which is the coupling
the interface exists to avoid.

**Consequence to accept deliberately:** the stub implementations ship in the production
binary. That is already true of `CoilCheckin`'s pattern, and the alternative — conditional
compilation — makes the de-stub pass (`[API §7.3]`) invisible to a code search. Keeping them
compiled and registered-only-when-flagged is what makes `FW-N12` a tractable deletion.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 manual walkthrough.

| AC | How it is checked |
|---|---|
| Every service behind an interface | No concrete service type is injected anywhere; constructor parameters are interfaces |
| The swap | Flip `useMockData` and confirm the resolved implementation changes; log the active set at boot |
| Fixtures end to end with the flag on | All 24 `FW-138` endpoints return their contracted shapes **with no database reachable** — this is the criterion that matters, because it is what 1A depends on |

The last row is the real test of this story: if any endpoint needs a database with
`useMockData` on, the swap is incomplete and 1A is blocked.

---

## 6. Handoff

1A builds against this. `FW-144` owns the binding. `FW-141` and `FW-142` supply the real
implementations the flag switches to. `FW-N12` / `[API §7.3]` removes the stubs — and
**that pass will not happen by itself**: the stub check-in deliberately routes around
`OI-46`, `OI-47` and `OI-48` by assuming a single active schedule, and a signer-off is
needed per screen.

---

## 7. Open items and stale citations

| Item | Effect here |
|---|---|
| **`OI-46` / `OI-47` / `OI-48`** | The stub bakes in "a single active schedule". Record it where the de-stub pass will find it |

| Stale | Correct | Source |
|---|---|---|
| The AC says the flag is **`useStub`** — twice | **`useMockData`** | `phase-01b` L84, L171; `[API §7.1]` |
