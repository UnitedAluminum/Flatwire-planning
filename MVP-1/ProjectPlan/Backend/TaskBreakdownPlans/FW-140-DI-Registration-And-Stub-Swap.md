# FW-140 · DI registration and the stub/real service swap

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 26, 2026 — ✅ **BUILT.** Twelve interfaces, twelve stubs and twelve real shells are live in `ual-api`; the eleven `*Fixtures.cs` are gone; `useMockData` binds, swaps and logs at boot. §5.1 carries the measured verification, including the **65-body value diff** that caught a wire change the 61-case probe could not see. `P-65` remains **open**. *(Previously August 25, 2026 — ⚠ **corrected against the code that now exists, and the mechanism is specified for the first time.** `FW-N04`, `FW-138` and `FW-139` are built, and this plan described a swap with **nothing to switch**: there are no service interfaces in the build, the fixtures sit in static classes called straight from the controllers, and **no domain in `ual-api` has the `CoilCheckin` pattern §2.1 said to copy**. Four decisions minted — **`P-62`** service-level swap, **`P-63`** the stub is the single home of fixture data, **`P-64`** the real implementations ship as loud shells, **`P-65`** consumption pending ratification. §5's stale **24 → 22** closed. Earlier the same day: `FW-138`'s endpoint count **24 → 22** (`P-53` withdrew the three `/rod/**` endpoints); the mock must lose them too *(previously August 15, 2026 — first issue)*)*
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **BUILT and verified on the running service, 26 Aug 2026** (§5.1) — the swap is real: flipping the flag changes the resolved implementation, and with it off every endpoint fails with a `NotImplementedException` naming its owning story. ⚠ **`P-65` is still unratified against `[SVC §3.2]`** — twenty-one controllers now forward to an injected interface with no handler between, which is built and working but wants a signature
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
>
> **The third, added 25 Aug 2026, will cost a developer a morning if they do not know it:
> the pattern this story is told to copy does not exist.** The card, `phase-01b` L84 and this
> document's own §2.1 all said *"as in `CoilCheckin`"*. There is no swap in `CoilCheckin`, or in
> any of the eleven `DependencyInjectionRegistry.cs` files in `ual-api` — see §2.1 for the
> measurement. **FlatWire is establishing this pattern, not inheriting it.**

---

> ### ⚠ Coding standard — read `[SVC §3.4a]` before writing code
>
> The repository C# standard binds every `.cs` file here, and `[SVC §3.4a]` records the **four
> standing divergences** so they are not re-litigated in review. What this story owns:
>
> **Twelve interfaces, twenty-four implementations, one registration method.** Every type is
> `sealed`; every interface member carries a single-line XML comment; the stub and the real
> implementation of one interface live side by side in `FlatWire.Infrastructure/Services/` so a
> reviewer sees both in one directory listing.
>
> **`AddPersistence` is the one place a registration may be written.** A service registered from
> `Program.cs` instead is invisible to the boot-time log `P-11` requires and will not be found when
> `FW-N12` deletes the stubs.

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
> - [ ] `useMockData` / environment swap of stub vs real implementations
> - [ ] With `useMockData` on, the API serves schema-valid fixtures end to end
>
> **Rate-card basis:** DI + configuration swap (12 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** —

⚠ **The card above is the text as corrected on 25 Aug 2026, and two criteria changed.** The flag
was written **`useStub`** twice — `phase-01b` L84 is explicit: *"**Flag name: `useMockData`**,
matching `[API §7.1]` and 1A — *not* `useStub`."* — and criterion 2 ended *"as in `CoilCheckin`"*,
which named a pattern that **does not exist** (§2.1). **Any copy of this card you find still saying
`useStub`, or pointing at `CoilCheckin` for the swap, predates that correction.**

### 1.1 In scope

`AddPersistence`-equivalent service registration · every service behind an interface ·
the `useMockData` swap · proving fixtures serve end to end with it on.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The fixtures themselves, and the controllers serving them | [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) |
| MediatR handler registration | [`FW-139`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) |
| Repository registration — `FW-141` writes them, this story registers the shape | [`FW-141`](FW-141-Repository-Layer.md) |
| `SimulatePLCTagPush` and `IReadingSource` — **different switches** (§2.2) | `FW-151`, `FW-N05`/`FW-211` |
| The Angular half of the stub contract | 1A |

⚠ **Binding `useMockData` moved OUT of this table on 25 Aug 2026 — it is this story's.** It was listed as `FW-144`'s, but [`FW-144 §2`](FW-144-Configuration-Binding.md) says the opposite in as many words — *"`useMockData` is **Angular's** (`environment.*.ts`); the backend swap of the same name is `FW-140` `P-11`"* — and its settings table does not list the key. **Each document pointed at the other and nobody bound it.** `FW-144` still owns every other key.

---

## 2. Precedence and the three switches

| Question | Authority |
|---|---|
| The flag **name** | `[API §7.1]`, `phase-01b` L84 |
| The stub **mechanism** | ⚠ **`phase-01b` L84 only.** `[API §7.1]` is the **Angular** mechanism — `flat-wire-api.interface.ts`, `flat-wire-api-mock.service.ts`, `environment.development.ts` — and specifies no backend behaviour at all. It is cited here for the *name*, so the two halves of the stub contract cannot be configured by two switches that disagree |
| What a stub must return | `[API §7.2]` |
| Layering — what may be registered where | `[SVC §3.2]` |
| The registration pattern | `CoilCheckin.Infrastructure/DependencyInjectionRegistry.cs` |

### 2.1 ⚠ There is no pattern to copy — measured 25 Aug 2026

**What `CoilCheckin` actually contributes is the registration *method*, not the swap.**
`AddPersistence(this IServiceCollection, IConfiguration)` registers every service behind its
interface with `AddScoped`, including `RestClient` — which is how a domain calls a sibling
service, and the hook FlatWire uses to reach `API.OPCConnection` (`FW-151`, `FW-148`). Under
`FW-N04` decision `P-02` the registration is invoked from `Program.cs` in `FlatWire.API`. Keep
the extension method; move only where it is called from.

**What it does not contribute is any stub swap, because it has none.** Measured across `ual-api`:

| Checked | Found |
|---|---|
| `CoilCheckin`'s `AddPersistence` | A flat list of ten `AddScoped<IFoo, Foo>()`. It **takes `IConfiguration` and never reads it** |
| `useMockData` / `useStub` in any `.cs` or `.json` | **None, anywhere** |
| Conditional registration in the **eleven** `DependencyInjectionRegistry.cs` files | **None.** Every one documents the `configuration` parameter and ignores it |
| `Stub*` / `Mock*` service types | One — `MockSocketProxy.cs`, in **`Scale.UnitTests`**. A test double, not a DI swap |

So the card's *"as in `CoilCheckin`"*, repeated at `phase-01b` L84 and in this document's own
earlier text, is **a false lead**. Both upstream sources were corrected on 25 Aug 2026; §7 records
it. **FlatWire is the first UAL service to carry a configuration-driven stub swap**, which is why
§4's `P-62`–`P-65` specify it rather than pointing at a template.

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

1. **Define the twelve service interfaces** in `FlatWire.Domain/Services/`, beside
   `Repository/` — `P-62`. The inventory is **not** open: it is one interface per
   controller-that-has-actions, and the build has exactly twelve of those.

   | | | |
   |---|---|---|
   | `ICheckInService` | `ICheckOutService` | `ICoilService` |
   | `IDieChangeService` | `ILineStatusService` | `IPayoffStagingService` |
   | `IRollAdjustService` | `IRunService` | `ISpcService` |
   | `ISpoolService` | `IWeldEventService` | `IWipRejectionService` |

   ⚠ **`PassScheduleController` and `ShiftSummaryController` get none.** They are scaffolded
   action-less — their handlers are MVP-2 — so there is nothing to serve and nothing to swap.
   Fourteen controllers, twelve services.
2. **`DependencyInjectionRegistry.AddPersistence`** in `FlatWire.Infrastructure`, invoked
   from `Program.cs`. Register the repository open generic, `RestClient`, and the services.

   > ⚠ **Do not register `IMediator`.** `P-51` lifted that line into `Program.cs` on 25 Aug 2026
   > — without it the host could not start, because `AddControllersAsServices()` makes every
   > controller a DI service that `Build()` validates. A second descriptor for the same pair is a
   > duplicate registration. **Verify it is there; do not add it.** `FW-142` carries the same
   > warning for the same reason.
3. **Bind `useMockData`** from configuration — **this story's, not `FW-144`'s** (§1.2). Default
   **on in Development only**. `P-11` requires the resolved set to be logged at boot; that log is
   the only place the active configuration is visible in one piece.
4. **Move the fixture data into the stubs — this is the bulk of the story** (`P-63`).
   `Stub{Area}Service` in `FlatWire.Infrastructure/Services/` takes over the body of the
   matching `{Area}Fixtures` class, **and the fixture file is deleted in the same commit**.
   Eleven files move; the twelfth source is `GetLinesStatusQuery`'s handler body, because
   `P-61` already deleted `LinesFixtures.cs`.

   ⚠ **Never leave a fixture file beside its stub.** Two copies of one fixture drift, and the
   contract they drift away from is the one 1A built its screens against.
5. **Write the twelve real shells** (`P-64`) — `{Area}Service`, same folder, each throwing
   `NotImplementedException` naming the story that fills it in.
6. **The swap.** Register the stub or the real implementation against the same interface:
   ```csharp
   if (useMockData) services.AddScoped<ILineStatusService, StubLineStatusService>();
   else             services.AddScoped<ILineStatusService, LineStatusService>();
   ```
   Decide the registration **once at startup**, not per request — see `P-11`.
7. **Wire the consumers** (`P-65`, **pending ratification**). `GetLinesStatusQueryHandler`
   takes `ILineStatusService`. The other twenty-one endpoints have no handler yet, so their
   controller injects the interface directly and forwards; when the handler lands, the
   dependency moves to it and **the interface does not change**. That invariance is the whole
   point of doing this before the handlers exist.
8. **Prove it end to end** — with `useMockData` on, every one of `FW-138`'s **22** endpoints
   returns its schema-valid fixture with no database present, and **no `*Fixtures.cs` remains in
   the tree**. *(24 until 25 Aug 2026; `FW-138`'s `P-53` withdrew the three `/rod/**` endpoints
   from the service and `§4.20` was never added. **The mock must lose them too** — a mock serving
   a route the real service does not have is the one failure this story exists to prevent.)*

⚠ **Steps 4–7 are a refactor of delivered, verified code.** `FW-138`'s probe covers all 22
endpoints and 61 cases; run it before and after and require the same result. A fixture whose
value changes during the move is a contract change to a screen 1A has already built.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; **`P-01`–`P-61` precede this story** — `P-01`–`P-05`, `P-50`, `P-51` in `FW-N04`; `P-06`–`P-08`, `P-52`–`P-58` in `FW-138`; `P-09`, `P-10`, `P-59`–`P-61` in `FW-139`. New here at **`P-62`**.

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
binary. The alternative — conditional compilation — makes the de-stub pass (`[API §7.3]`)
invisible to a code search. Keeping them compiled and registered-only-when-flagged is what makes
`FW-N12` a tractable deletion, and `P-64` is what stops a mis-set flag from serving them silently.
*(This paragraph said the consequence was "already true of `CoilCheckin`'s pattern" until 25 Aug
2026. `CoilCheckin` has no stub implementations at all — §2.1.)*

---

### `P-62` — the swap is service-level: one `I{Area}Service` per controller

**Interfaces in `FlatWire.Domain/Services/`; both implementations in
`FlatWire.Infrastructure/Services/`.** Both folders already exist from `FW-N04`, and this
placement keeps the delivered reference graph exactly as built — `Application → Domain`,
`Infrastructure → Domain`, and **Infrastructure does not reference Application** — so `P-02`
holds without an edge being added. `[SVC §3.1]` already puts services in
`FlatWire.Infrastructure/Services/`; this differs from `CoilCheckin`, which puts them in
Application and consequently needs the edge `P-02` removed.

**Why the controller and not the repository.** The alternative was to swap `FW-141`'s seven
repository interfaces. Rejected: the fixtures are per **endpoint**, not per aggregate — one
repository backs several endpoints and several endpoints span repositories — so a repository-level
stub cannot reproduce `[API §7.2]`'s per-endpoint failing cases without inventing a mapping that
exists nowhere in the contract.

⚠ **This refines `P-08`; it does not reverse it.** `P-08` put fixtures **one per controller** so
the de-stub pass has one seam per screen. That survives exactly — one `Stub{Area}Service` per
controller. What changes is that the seam becomes an **injected interface** instead of a static
class, which is what makes it swappable at all.

---

### `P-63` — the stub is the single home of fixture data

`Stub{Area}Service` takes over the body of `{Area}Fixtures`, **and the fixture file is deleted in
the same commit.** No endpoint keeps two copies.

This is stated as a decision because the tempting alternative — leave the fixture classes and have
the stubs call them — looks harmless and is not. The fixtures are a **published interface** the
moment 1A builds against them; two copies of one fixture drift, and the copy that drifts is
discovered by a screen breaking, not by a compiler.

**Eleven files move.** The twelfth source is `GetLinesStatusQuery`'s handler body — `P-61` already
deleted `LinesFixtures.cs` when it de-stubbed `GET /lines/status` through MediatR.

---

### `P-64` — the real implementations ship as loud shells

Each `{Area}Service` is created **now**, throwing `NotImplementedException` naming the story that
fills it in — `FW-157` (check-in), `FW-164` (run queries), `FW-168` (SPC), `FW-170`
(pause/resume), `FW-174` (WIP rejection and checkout), `FW-179` (spool), and so on.

Two things this buys, and neither is available if the `else` branch is left unregistered:

1. **The AC becomes testable today.** §5 asks that flipping the flag changes the resolved
   implementation. With no real branch there is nothing to resolve to, and the check degrades into
   reading the source.
2. **A mis-set flag fails loudly, per endpoint.** The failure mode this replaces is the dangerous
   one: a production deploy quietly serving fixture data, with `R00041` on an operator's screen and
   nothing in the log to say why.

---

### `P-65` — consumption, and it needs ratification

`[SVC §3.2]` says *"Controllers are thin. All logic routes through MediatR."* Exactly **one** of
the 22 endpoints has a handler today (`P-61`).

**The rule:** until an endpoint has a handler, its controller injects `I{Area}Service` and
forwards. When the handler lands, the dependency moves to the handler and **the interface does not
change**. That invariance is why this is worth doing before the handlers exist.

**Why this is not a `[SVC §3.2]` violation, and why it still needs a signature.** A thin forward to
an injected interface is not business logic in a controller, and it is strictly better than the
static-fixture call it replaces — which is what those twenty-one controllers do **today**. But
`[SVC §3.2]` is written absolutely, and a reviewer reading it literally will reject the shape.
**Ratify alongside `P-06` and `P-53`** rather than leaving the developer to argue it in review.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 manual walkthrough.

| AC | How it is checked |
|---|---|
| Every service behind an interface | No concrete service type is injected anywhere; constructor parameters are interfaces |
| The swap | Flip `useMockData` and confirm the resolved implementation changes; log the active set at boot |
| Fixtures end to end with the flag on | All **22** `FW-138` endpoints return their contracted shapes **with no database reachable** — this is the criterion that matters, because it is what 1A depends on. *(Said 24 until 25 Aug 2026; `P-53` withdrew three and §3 was corrected while this row was not.)* |
| **No fixture file survives** (`P-63`) | `find . -name "*Fixtures.cs"` returns **nothing** under `FlatWire.API/Controllers/`. Eleven existed at the start of this story |
| **The real branch fails loudly** (`P-64`) | With `useMockData` **off**, an endpoint returns a `500` naming its owning story — not a fixture, and not a DI resolution error |
| **No contract drifted** | `FW-138`'s probe passes **61/61** after the move, with the same values it returned before it. A fixture that changes during a relocation is a breaking change to a built screen |

The last row is the real test of this story: if any endpoint needs a database with
`useMockData` on, the swap is incomplete and 1A is blocked.

### 5.1 What the build actually verified — 26 Aug 2026

Built in `ual-api` at `API/Domain/FlatWire/`. **0 errors; 18 warnings, and all 18 are the
pre-existing set** (10 `S112`, 8 `NU1506`) — measured with `--no-incremental` against nothing
running, because a live service inflates the count with `MSB3061`/`MSB3026` file-lock noise.

| AC | Result |
|---|---|
| Every service behind an interface | ✅ **12 interfaces · 12 stubs · 12 real** — `IFlatWireServices.cs` in `FlatWire.Domain/Services/`, both implementation sets in `FlatWire.Infrastructure/Services/` |
| `P-02` still holds | ✅ `dotnet list reference`: **`Infrastructure → Domain` only**, `Application → Domain` only. No edge to Application was introduced |
| The swap | ✅ with the flag **off** the boot log reads *"useMockData=false - all 12 services bound to REAL implementations"*, and endpoints return `500` |
| The active set is logged at boot (`P-11`) | ✅ one line, naming the mode and the count |
| **The real branch fails loudly** (`P-64`) | ✅ `NotImplementedException: ILineStatusService.GetLinesStatusAsync is not implemented yet - it is FW-164's. Run with useMockData=true until then (FW-140, P-64).` |
| **No fixture file survives** (`P-63`) | ✅ **0** `*Fixtures.cs` remain; eleven were deleted and their data is in the stubs |
| Fixtures end to end with the flag on | ✅ **61/61**, no database reachable |
| **No contract drifted** | ✅ **all 65 response bodies byte-identical** before and after — see below |

**The value diff earned its place, and this is the part worth reading.** A 61/61 probe passed
*both* before and after the refactor while a real wire change sat in two responses. Carrying the
committed-row status in `ErrorCode` — the obvious move, and what the blocked-staging branch already
did — changed `errorCode` from `0` to `201` on `POST /staging/rod` and `POST /spool/complete`. The
HTTP status was correct either way, so **no status-level assertion could see it**; `errorCode` is a
published field of `[API §1.2]` that 1A builds against. It now travels in a `[JsonIgnore]`
`SuccessStatusCode`, and the 65-body diff is clean.

**Three things the move surfaced that the plan did not predict.**

**(1) `POST /spool/complete` has two success statuses**, and an action-level status is therefore
wrong by construction: a decline is a **200 with no payload written** — *"not an error, and the
decline is logged"* — while a commit is a **201**. The first cut put `201` on the action and broke
the decline path; the probe caught it. `FlatWireResult<T>.Created` now carries the status on the
**branch that commits**, which is where the decision is actually made.

**(2) `GET /run/active` on an idle line returns `204`, which an envelope cannot express** — a 204
must not carry a body. The service carries it like any other status and `Envelope.From` maps it
back to a bodyless `NoContentResult`.

**(3) Two fixture constants were not in the fixture class.** `OtherLineOrderId` and
`AlreadyCheckedInStagingId` — the `WRONG_STATION` and `409` triggers — lived in
`PayoffStagingController`'s *Private Variables* region, so replacing that region wholesale dropped
them. They are fixture data and now sit with the rest of it.

⚠ **The controller files are internally mixed CRLF/LF** — `CheckInController` alone had 185 CRLF
lines and 19 LF, from earlier edits in this repository. Each rewrite was written back in its own
dominant ending, but the mixing predates this story and is not fixed by it.

---

## 6. Handoff

1A builds against this. **This story binds `useMockData`**; `FW-144` owns every other key
(§1.2). `FW-141` and `FW-142` supply the data access the twelve real services will use, and the
per-area service stories (`FW-157`, `FW-164`, `FW-168`, `FW-170`, `FW-174`, `FW-179`, …) fill in
the shells `P-64` leaves behind — **each one deletes its own `NotImplementedException`, which is
the cheapest possible progress ledger.**

`FW-N12` / `[API §7.3]` removes the stubs — and **that pass will not happen by itself**: the stub
check-in deliberately routes around `OI-46`, `OI-47` and `OI-48` by assuming a single active
schedule, and a signer-off is needed per screen.

⚠ **`FW-N12` has no plan and no hours.** `[TB]` records it as *"Cited against Phase 4,
**uncosted**. In practice absorbed by `FW-166` (weld) and `FW-201` (defect allowance)"* — which
covers two screens, not twelve. `FW-139 §8` raised the same gap for the model-binding gate.
**`P-63` and `P-64` are what keep the deletion tractable when someone finally owns it**: one stub
class per screen, and a shell that names its successor.

---

## 7. Open items and stale citations

| Item | Effect here |
|---|---|
| **`OI-46` / `OI-47` / `OI-48`** | The stub bakes in "a single active schedule". Record it where the de-stub pass will find it |
| **`P-65` is unratified** *(new, 25 Aug 2026)* | Twenty-one controllers forward to an injected interface without a handler in between. `[SVC §3.2]` reads absolutely; **ratify before wiring them**, alongside `P-06`/`P-53` |
| **`FW-N12` is uncosted** *(new, 25 Aug 2026)* | The story that deletes the twelve stubs has no plan and no hours — `[TB]`. Named here so the debt is visible from the story that creates it |
| **12 h understates this story** *(new, 25 Aug 2026)* | Twelve interfaces, twelve stubs, twelve shells and eleven file relocations. **No hour cell is restated** — the overrun is owed to the re-baseline, as `FW-138`'s 42 h and `FW-147`'s 12 h are (`FW-N04 §1.2`) |

| Stale | Correct | Source |
|---|---|---|
| The AC says the flag is **`useStub`** — twice | **`useMockData`** | `phase-01b` L84, L171; `[API §7.1]` |
| *"environment swap of stub vs real … **as in `CoilCheckin`**"* — in the AC **and** `phase-01b` L84 | **There is no such pattern in `CoilCheckin` or any `ual-api` domain.** FlatWire establishes it | §2.1, measured 25 Aug 2026. **Both sources corrected the same day** |
| `[API §7.1]` cited as the authority for the stub **mechanism** | It is the **Angular** mechanism and specifies no backend behaviour. It is authority for the flag **name** only | §2 |
