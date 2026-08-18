# FW-138 · Fifteen thin controllers over `UAController`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — FL2 fixture corrected to `PS-1100-FL2-002` (`G40`); §3.0a trial subset, §6.1 QA0 checklist and the four cross-cutting conventions added; `G6` answered (no effect — the 24 actions carry bare `[Authorize]`) *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **one contract conflict must be settled first (§5, `P-06`)**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-138`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** `FW-138` is the story that makes the whole Angular stream
> possible: `phase-01b` ships stub endpoints first *"so 1A can build against the real
> service early."* Its shape looks obvious — fifteen controllers, one per `[API §3.1]` row —
> and two things about it are not.
>
> **First, the framework cannot produce the contracted envelope.** `ActionResultBase<T>`
> has no `errors` array, its `ErrorCode` is an `int` where the catalogue is strings, and
> `CoilCheckin` — the binding template — returns **HTTP 200 on failure**, which contradicts
> `[API §1.3]` outright. That is decision `P-06` and it is a prerequisite, not a detail.
>
> **Second, the story is smaller than its title.** `FW-N04` already delivered the fifteen
> shells. What is left is **24 stub endpoints across 13 controllers** — the other two
> controllers get no actions at all.
>
> This is the build order. It is derived from the specifications and **loses to every one
> of them.**

---

## 1. The story

From `[TB §7]` — reproduced verbatim:

> ###### FW-138 · Fifteen thin controllers over `UAController`
> **Hours:** **45 h BE** *(was 56)* · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** developer,
> **I want** every controller present and returning the standard envelope from day one,
> **So that** the Angular library can build against the real service before any handler exists.
>
> **Acceptance Criteria:**
> - [ ] All **fifteen** exist and extend `UAController`: `LinesController`, `PassScheduleController`, `RodReceivingController`, **`PayoffStagingController`**, `CheckInController`, `RunController`, `SpcController`, `WeldEventController`, `RollAdjustController`, `DieChangeController`, `CheckOutController`, `WipRejectionController`, **`SpoolController`**, `CoilController`, `ShiftSummaryController`
> - [ ] **`SpoolController` covers `GET /spools`** — endpoint 16a, `FR-097`–`FR-099`, DB5/DB5A
> - [ ] **`PayoffStagingController` covers `/payoff/status` and `/staging/**`** — endpoints 10, 11, 12 and 14. ⚠ Endpoint 13 (`POST /staging/rod/mark-welded`) was **retired 1 Aug 2026** in favour of `POST /weldevent` as the single weld write — **do not scaffold it**
> - [ ] ⚠ **`POST /staging/rod` returns `201 Created` with `state:"Blocked"` on inspection failure** — the row is committed **before** the inspection gate, and it is still a hard block with no override. `Blocked` is a **derived** bay state, never a stored `Status`, and `POST /wipreject` is the only thing that clears it (**G21**)
> - [ ] Each returns the `{Data, Success, Errors}` envelope
> - [ ] **`[Authorize]` on every controller and every endpoint** — no bare `ControllerBase`, no unprotected route
> - [ ] Stub endpoints return schema-valid fixtures for the seed alphas, per `[API §4]` shapes
> - [ ] ⚠ **The stub endpoints stay; the suite that asserted them is withdrawn** (15 Aug 2026, `[TS §1.2]`). `[API §7.2]`'s five obligations are verified by the **signed-off manual contract walkthrough** at QA0 (`[TS §4.2]`), not by xUnit. **1A still builds against these stubs** — dropping the test does not drop the fixtures
>
> **Rate-card basis:** 14 controllers @ 4 h = 56 h (§2, query-endpoint rate for scaffold + stub), **less the withdrawn contract suite → 42 h** (15 Aug 2026)
> **Dependencies:** FW-N04
> **Blockers:** —

### 1.1 What is already done

**`FW-N04` delivered the fifteen controller shells** — class, `[ApiController]`, `[Authorize]`,
class-level `[Route("api/v1/flatwire")]`, `IMediator` constructor injection, no actions.
See [`FW-N04`](FW-N04-FlatWire-Solution-Skeleton.md) step 8 and decision `P-04`.

**Acceptance criterion 1 is therefore already satisfied** when this story starts. Confirm it
rather than rebuild it.

### 1.2 In scope

| # | Deliverable |
|---|---|
| 1 | **The response envelope** — the contracted `{data, success, errors[]}` shape with a string error code, which the framework does not supply (`P-06`) |
| 2 | **24 stub endpoints across 13 controllers** — §3 is the allocation |
| 3 | Canonical fixture data behind them, mirroring the DB seed |
| 4 | **At least one failing case per endpoint**, returning the contracted status code and machine-readable code |
| 5 | The three special-case behaviours of §4 step 5 — `201`/`Blocked`, FL2 `null` gauge/width, `Draft` schedule → `422` |
| 6 | `[ProducesResponseType]` on every action, so Swagger publishes the contract |

### 1.3 Out of scope — and who owns each

| Concern | Story |
|---|---|
| Real handlers behind any endpoint | Phases 3–9 |
| MediatR registration + pipeline behaviours | [`FW-139`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) |
| The Angular `useMockData` mock service — the *other* stub (§2.2) | [`FW-140`](FW-140-DI-Registration-And-Stub-Swap.md) / 1A |
| **Global exception middleware** — this story returns codes from the actions; the middleware that catches what they miss | [`FW-146`](FW-146-Exception-Middleware-And-Envelope.md) |
| Role **policies** (`[Authorize(Policy=…)]`); this story carries bare `[Authorize]` only | [`FW-145`](FW-145-JWT-And-Role-Policies.md) |
| FluentValidation validators and the 14 canonical enums as C# types | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) |
| `GET /health` — endpoint 30, which has **no controller** | [`FW-148`](FW-148-Health-Checks.md) |
| The mock SignalR stream — `[API §7.2]`'s fifth obligation (§2.3) | [`FW-080`](FW-080-FlatWireHub.md) |
| The de-stub pass that removes what the stubs assume | `FW-N12` / `[API §7.3]` |

> **No hour cell has been restated.** `FW-N04` pulled the fifteen shells forward out of this
> story's 45 h; the note in [`FW-N04 §1.2`](FW-N04-FlatWire-Solution-Skeleton.md) explains
> why re-deriving in place would desynchronise `[CE]`, `[DE]`, `[SSP]`, `[TRP]` and
> `[TB §7]`'s reconciliation. Re-baselining is a separate, additive exercise.

---

## 2. Precedence, and three things that are easy to misread

| Question | Authority |
|---|---|
| Envelope, status codes, headers, pagination, units | `[API §1.1]`–`[API §1.8]` |
| The controller list | `[API §3.1]` — **fifteen**, corrected 15 Aug 2026 |
| Which endpoints exist, their phase and their role | `[API §3.2]` — 32 live rows |
| Per-endpoint request/response shapes | `[API §4]` |
| What a stub owes | `[API §7.2]` |
| Roles | `[SEC §8]` is the matrix of record; `[API §9.2]` is only a summary |
| Layering — controllers are thin | `[SVC §3.2]` |

### 2.1 The count, stated once

`[API §3.2]` carries **32 live rows** — 1–30 with **#13 retired**, plus **16a**, **16b**,
**18a**. Seven are outside MVP-1: the six pass-schedule endpoints (2–7) and `GET /shiftsummary`
(29). **MVP-1 implements 25 of 32.**

One of those 25 — `GET /health`, #30 — **has no controller** and belongs to `FW-148`.

> **So this story delivers 24 endpoints, not 25 and not 32.** The remaining seven are
> scaffolded as controllers with no actions. That arithmetic appears in no specification and
> is derived here; §3 shows the working.

⚠ **`[API]`'s own front matter says "31 live rows, of which MVP-1 implements 24."** It is
stale by one — `16b POST /spool/complete` was added the same day and §3.2's heading, its
explanatory note and `phase-01b` L82 all say 32/25. **Build to 32/25.**

### 2.2 There are two stubs, and `[API §7]` reads as though there is one

`[API §7.1]`'s mechanism — `flat-wire-api.interface.ts`, two implementations, `useMockData`
— is **Angular**. It is easy to read all of §7 as 1A's problem and skip it.

`[API §7.2]`'s obligations apply to **both** stubs, and `phase-01b` L127–131 applies them to
this layer explicitly. The backend stub is this story; the Angular mock is `FW-140` and 1A.
**They must return the same fixtures**, which is the whole point of naming canonical alphas.

### 2.3 Four of the five obligations are yours

| `[API §7.2]` obligation | Owner |
|---|---|
| The exact response envelope, including `success` and `errors` | **This story** |
| The canonical fixture alphas, mirroring the DB seed | **This story** |
| At least one failing case per endpoint | **This story** |
| `null` live gauge and width for FL2 | **This story** |
| A mock SignalR stream at the real cadence with real batch shapes | `FW-080` — it is hub telemetry, not an endpoint |

---

## 3. Endpoint allocation — the 24, by controller

From `[API §3.2]`. **Route column is the suffix after the class-level `api/v1/flatwire`.**

| Controller | # | Method + route | Shape in | Phase |
|---|---|---|---|---|
| `Lines` | 1 | `GET /lines/status` | `[API §4.1]` | 3 |
| `RodReceiving` | 8 | `GET /rod/{alpha}` | `[API §4.3]` | 4 |
| | 9 | `POST /rod` | — | upstream |
| `PayoffStaging` | 10 | `GET /payoff/status?lineId=` | `[API §4.4]` | 4 |
| | 11 | `POST /staging/rod` | `[API §4.5]` | 4 |
| | 12 | `POST /staging/rod/unstage` | `[API §4.5a]` | 4 / 7 |
| | 14 | `GET /staging/queue?lineId=` | `[API §4.7]` | 4 |
| `CheckIn` | 15 | `POST /checkin/rod` | `[API §4.6]` | 4 |
| | 16 | `POST /checkin/spool` | `[API §4.6a]` | 8 |
| `Spool` | 16a | `GET /spools[?spoolAlpha=]` | `[API §4.6b]` | 8 |
| | 16b | `POST /spool/complete` | `[API §4.6c]` | 5 |
| `Run` | 17 | `GET /run/active?line=` | `[API §4.7a]` | 5 |
| | 18 | `GET /run/{runId}/gaugetrace` | `[API §4.17]` | 5 / 8 |
| | 18a | `GET /run/{runId}/weldevents` | `[API §4.17a]` | 4 |
| | 19 | `POST /run/{runId}/pause` | `[API §4.8]` | 6 |
| | 20 | `POST /run/{runId}/resume` | `[API §4.8]` | 6 |
| `Spc` | 21 | `POST /spc` | `[API §4.9]` | 4, 6 |
| `WeldEvent` | 22 | `POST /weldevent` | `[API §4.10]` | 6 |
| `RollAdjust` | 23 | `POST /rolloverride` | `[API §4.11]` | 6 |
| `DieChange` | 24 | `POST /diechange` | `[API §4.12]` | 6 |
| `CheckOut` | 25 | `POST /checkout` | `[API §4.13]` | 7 |
| `WipRejection` | 26 | `POST /wipreject` | `[API §4.14]` | 7 |
| `Coil` | 27 | `POST /coil/complete` | `[API §4.15]` | 9 |
| | 28 | `GET /coil/{alpha}/label` | `[API §4.16]` | 9 |

**24 endpoints, 13 controllers.**

### 3.0a ⚠ The trial needs eight controllers, not fifteen

`[TRP §1.4]` scopes this story to **14 h / eight controllers** for the 30 Sep trial, against
the 45 h / fifteen above. **Build the full fifteen if you are building MVP-1; build these
eight if you are building the trial** — and know which you are doing before you start.

| In trial scope | Out of trial scope |
|---|---|
| `Lines` · `RodReceiving` · `CheckIn` · `Run` · `Spc` · `WipRejection` · `Spool` · `Coil` | `PassSchedule` · `PayoffStaging` · `WeldEvent` · `DieChange` · `RollAdjust` |

⚠ **Two of the eight carry no in-scope endpoint, and that is deliberate.** `LinesController`
hosts only `/lines/status`, which **left with DB1** on 14 Aug — the trial's landing route is
`GET /run/active?line=` instead; and `CoilController` hosts `/coil/**`, which is Phase 9.
**Only six controllers serve a trial screen.** The two are kept as empty scaffolds on
purpose — DB1 returns after the trial, Phase 9 is next, and a scaffold is where the de-stub
pass hangs its fixtures. *`[TRP §1.4]`: do not "correct" the eight to six without re-running
the workbook guards.*

⚠ **`GET /health` is not the ninth controller** — it is `MapHealthChecks` middleware and
appears in no controller list ([`FW-148`](FW-148-Health-Checks.md)).

### 3.1 The two controllers that get no actions

| Controller | Endpoints | Why |
|---|---|---|
| `PassSchedule` | 2, 3, 4, 5, 6, 7 | **MVP-1 exposes no pass-schedule endpoint of its own** — no create, edit, approve or list. MVP-1 *reads* a schedule at check-in, via a local Dapper query, not through this controller |
| `ShiftSummary` | 29 | DB10 is MVP-2; `sp_ShiftSummary` is MVP-2's and must not be created |

Both classes exist so the contract surface is complete and the Angular client has a stable
base URL set. **Leave them action-less** — an endpoint that returns a stub the client then
builds against is worse than one that visibly does not exist.

### 3.2 Two rows that must not be built

- **#13 `POST /staging/rod/mark-welded`** — retired 1 Aug 2026. `POST /weldevent` is the
  single weld write and sets `RodStaging.IsWelded`/`WeldedAt`/`WeldedBy` in the same
  transaction, **on `WeldQuality = 'Pass'` only**.
- **#30 `GET /health`** — `FW-148`, registered in `Program.cs`, and the one **anonymous**
  route in the service.

---

## 4. Build order

### Step 1 — settle the envelope (`P-06`) before writing any action

This is a prerequisite. See §5.

### Step 2 — confirm the shells

`FW-N04` step 8 delivered all fifteen. Verify names and route prefixes against `[API §3.1]`
before adding actions; do not re-create them.

### Step 3 — the 24 action signatures

One method per §3 row. Controllers stay **thin** (`[SVC §3.2]`): the action builds the
envelope and returns it. No business logic, no EF queries, no direct OPC calls.

```csharp
[HttpGet]
[Route("lines/status")]
[ProducesResponseType(typeof(FlatWireResult<LinesStatusResponse>), (int)HttpStatusCode.OK)]
public async Task<IActionResult> GetLinesStatusAsync()
```

Rules:

- **Explicit per-action routes**, never the `[controller]` token — `FW-N04` `P-04`. The token
  cannot express `PayoffStagingController`'s two prefixes.
- **`[ProducesResponseType]` for the success shape and every failure code the endpoint can
  return.** Swagger is how 1A discovers the contract before the handlers exist.
- **`[Authorize]` is inherited from the class.** Do not add role policies — `FW-145`.
- Match `[API §4]` field names exactly, and `[API §1.7]` on units: the suffix states the
  unit (`gaugeIn`, `footageFt`, `weightLb`, `speedFpm`).
- Timestamps are ISO 8601 with offset and **server-side at receipt** (`[API §1.6]`).

**Four cross-cutting conventions this story owns**, from `phase-01b` L96–L97. They belong to
no other 1B story and are easy to leave unimplemented because no acceptance criterion names
them:

| Convention | Rule |
|---|---|
| **Server-side timestamps — `FR-174`** | Every event timestamp is stamped **at API receipt**, never from the client clock, **even when the screen displays it**. `DATETIMEOFFSET` throughout; `RunReading.ReadingTs` is the one UTC `DATETIME2` exception |
| **Pagination** | `page` (1-based, default 1) and `pageSize` (default **50**, max **200**), returning `{items, totalCount, page, pageSize}` **inside `data`**. ⚠ `GET /lines/status` and `GET /staging/queue` are **not** paginated — bounded by three lines and one order |
| **Units** | Inches / feet / pounds / FPM, with the **suffix stating the unit** (`gaugeIn`, `footageFt`, `weightLb`, `speedFpm`) — `[API §1.7]` |
| **Versioning** | Base URL `/api/v1/flatwire`. Adding an optional request field or a response field is non-breaking; **removing a field, narrowing a type, adding a required field, or changing a status for an existing condition mints `v2`** (`[API §8]`) |

### Step 4 — fixtures

Mirror the DB seed. `[API §7.2]`: `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`,
`RUN-0042` / `RUN-0043`.

> ⚠ **Two of these are *negative* fixtures.** `PS-1100-FL1-003` is a `Draft` schedule and
> `PS-1100-FL2-001` is `Hybrid`/`Inactive`; both must be refused at check-in with
> `SCHEDULE_NOT_ACTIVE` → `422`. A stub that acknowledges either successfully asserts the
> opposite of the contract.
>
> | Case | Schedule | Route mode | State |
> |---|---|---|---|
> | **FL1 happy path** | **`PS-1100-FL1-001`** | Standalone | `Active` |
> | **FL2 happy path** | **`PS-1100-FL2-002`** | Standalone | `Active` |
> | FL3 hybrid | `PS-1100-FL3-001` | Hybrid | `Active` |
> | FL1 negative — draft | `PS-1100-FL1-003` | — | `Draft` |
> | FL1 negative — inactive | `PS-1100-FL1-002` | — | `Inactive` |
> | **FL2 negative — inactive** | **`PS-1100-FL2-001`** | Hybrid | `Inactive` |
>
> ⚠ **`PS-1100-FL2-002` is the FL2 happy path, not `-001` — gap `G40`, 15 Aug 2026.**
> `-001` was **demoted to `Inactive`** so `-002` could exist, because
> `UX_PassSchedule_OneActivePerLineAlloy` permits exactly **one Active schedule per line +
> alloy** and the two cannot coexist. It is kept, not deleted: it is the Hybrid-FL2
> coverage case and `RUN-0004` still references it. **Verified against the seeded rows** —
> `[API §7.2]`'s callout and `[API §4.6a]`'s `POST /checkin/spool` worked example both
> still name `-001` as the FL2 happy path and are stale on both the id and the state.

> ⚠ **Older implementation documents ship inconsistent fixtures** — `PS-1100-FL2-001` vs
> `-007`, and `SP-00021` sourced from `RUN-0041` while its source rods point to `SP-00031`.
> **Align to the DB seed.**

Keep fixtures in one place per controller so the de-stub pass has a single seam to delete.

### Step 5 — the three behaviours a naive stub gets wrong

**(a) `POST /staging/rod` returns `201 Created` with `state:"Blocked"` on inspection
failure.** Not `422`. The row is committed *before* the inspection gate, because writing
nothing reported an occupied bay as free — a bundle is already physically on the payoff when
it is inspected. It remains a hard block with no override, and `POST /wipreject` is the only
thing that clears it. `Blocked` is **derived** (`Status='Staged'` + any inspection column
`='Fail'`), never a stored `Status` value.

> This is the one place a failed business rule returns a success code with a committed row,
> and `phase-01b` L93 names it as *"exactly what a global exception middleware gets wrong."*
> Return it from the action; make sure `FW-146` cannot later re-map it.

**(b) FL2 broadcasts `null` live gauge and width.** Every FL2 shape returns `null`, not `0`
and not an omitted field. FL2's trace is historical/profile.

**(c) A `Draft` or `Inactive` schedule is refused** with `SCHEDULE_NOT_ACTIVE` → `422`.

### Step 6 — one failing case per endpoint

`[API §7.2]` requires at least one, and `[API §1.8]`'s catalogue supplies the code. The
**409/422 split is load-bearing** (`[API §1.3]`): `409` means *"someone got there first —
re-read and retry"*; `422` means *"this will never succeed as submitted."*

Representative pairings from `[API §1.8]`:

| Endpoint | Failing case | Code | HTTP |
|---|---|---|---|
| `GET /rod/{alpha}` | unknown alpha | `ROD_NOT_FOUND` | 404 |
| `POST /staging/rod` | bay occupied | `BAY_OCCUPIED` | 409 |
| `POST /staging/rod` | `lineId = FL2` | `LINE_NOT_ELIGIBLE` | 422 |
| `POST /staging/rod` | inspection fail | `INSPECTION_FAILED` | **201 + `Blocked`** (§4 step 5a) |
| `POST /checkin/rod` | `Draft` schedule | `SCHEDULE_NOT_ACTIVE` | 422 |
| `POST /checkin/rod` | run already active | `RUN_ALREADY_ACTIVE` | 409 |
| `POST /checkout` | line still running | `LINE_STILL_RUNNING` | 422 |
| any write | `ROWVERSION` mismatch | `CONCURRENCY_CONFLICT` | 409 |

`INSPECTION_FAILED` carries `{route:"wipRejection", rodAlpha}` so the client can route.

### Step 7 — Swagger and the walkthrough pack

Boot with `ASPNETCORE_ENVIRONMENT=Development` and confirm Swagger lists 24 operations
across 13 controllers, with `PassSchedule` and `ShiftSummary` present and empty. This is the
artefact the QA0 manual contract walkthrough is run against, so it is the deliverable, not a
side effect.

---

## 5. Decisions this plan makes

> The `P-##` series is **continuous across this folder**, so a number means one thing
> repository-wide. `P-01`–`P-05` are in [`FW-N04`](FW-N04-FlatWire-Solution-Skeleton.md) §5.

### `P-06` — build the response envelope; the framework does not supply it

**Needs ratifying, and it blocks step 3.** This is the story's central problem and no
specification records it.

The contract, `[API §1.2]`:

```json
{ "data": { }, "success": true }
{ "success": false, "errors": ["Field X is required"] }
```

> `data` is `null` on any non-success. `errors` is always an array, never a bare string.

Plus `[API §1.8]`: a **string** machine-readable code accompanies `errors[]`. Plus
`[API §1.3]`: real HTTP status codes, with the 409/422 split load-bearing.

**Three framework paths, none of which produces that.** Verified against
`c:\UAL\ual-api` on 15 Aug 2026:

| Path | What it gives | Why it fails the contract |
|---|---|---|
| `ActionResultBase<T>` (`UA.Framework.Common.Model`) | `Data`, `Success`, `ErrorCode` (**int**), `ErrorDescription` (**string**) | **No `errors` array**; the code is an `int` where the catalogue is strings (`BAY_OCCUPIED`, …) |
| `UAController.Error(HttpStatusCode, string)` | correct status code, body `{ ErrorMessage, RequestUri }` | **No `success`, no `errors[]`, no code** — a different shape entirely |
| `CoilCheckin`'s controller pattern | `catch { …Success = false; return Ok(actionResultBase); }` | **Returns HTTP 200 on failure.** Flatly contradicts `[API §1.3]` and destroys the 409/422 split |

**Resolution: define a small `FlatWireResult<T>` in `FlatWire.Domain`** carrying
`Data` · `Success` · `Errors` (`string[]`) · `ErrorCode` (`string`), serialised camelCase,
and return it with the correct status code. Success paths use it; failures use it with
`Data = null`.

Rationale: the envelope is what the Angular client is coded against and `[API §8]` makes
changing it a **breaking change**, so the wire shape wins over the convenience of an
existing type. `[ARC §2.2]` binds `CoilCheckin` for the *controller shape* — thin, `IMediator`
injected, `UAController` base, one method per endpoint — and this keeps all of that. It
diverges only where `CoilCheckin` contradicts `[API §1.3]`, which is not a pattern worth
inheriting.

**Interaction with `FW-146`.** That story owns *"global exception middleware and the response
envelope"* (8 h). Defining the type here and letting `FW-146` wire the middleware onto it is
the split that works, because `FW-138` is the first consumer and its AC names the envelope.
**`FW-146` must not redefine it**, and must not re-map the `201`/`Blocked` response.

**If ratification prefers `ActionResultBase<T>`**, then `[API §1.2]` has to change instead —
and that is a contract change affecting every 1A screen, not a backend detail. Escalate
rather than absorb.

### `P-07` — the seven deferred endpoints are absent, not stubbed

`PassScheduleController` and `ShiftSummaryController` carry no actions. A `404` from a route
that was never mapped is honest; a stub the client codes against is a de-stub liability in a
scope MVP-1 does not own.

### `P-08` — fixtures live per controller, not in one shared class

One seam per controller for the de-stub pass (`[API §7.3]`, `FW-N12`). A single shared
fixture class becomes a file every screen's removal has to touch.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026: `FlatWire` ships with no xUnit suite of
any kind, and `[SP]` is explicit that reinstating one requires reversing that decision in
`[TS]`. The stub endpoints and fixtures are production deliverables; only the suite that
asserted them was withdrawn.

Verification is therefore the **QA0 signed-off manual contract walkthrough** (`[TS §4.2]`),
which **needs a named reviewer and a slot in the window** or the Phase-1 gate has no 1B
criterion at all.

### 6.1 The QA0 walkthrough — the checklist, and it has no owner yet

**This story is the walkthrough's largest contributor**, so the checklist lives here.
`phase-01b` L124 and `[TRP §7]` both say the same thing in different words: it *"has to be
staffed inside the window rather than assumed."*

> **Reviewer: `TBD` — assign before the window opens.** A layer with no automated tests and
> no named reviewer has **no verification at all**, and `phase-01b` exit criterion 6 cannot
> be signed.

| # | Item | Owning plan |
|---|---|---|
| 1 | `[API §7.2]`'s five obligations against every stub endpoint | **this story** (4 of 5) · [`FW-080`](FW-080-FlatWireHub.md) (the mock SignalR stream) |
| 2 | Hub behaviour by observation — join, cadence, reconnect re-join, prompt re-delivery (`TC-173`) | [`FW-080`](FW-080-FlatWireHub.md) |
| 3 | `/health` green, documented shape, **unauthenticated** probe | [`FW-148`](FW-148-Health-Checks.md) |
| 4 | **`TC-020`** — the C# ↔ TS ↔ DB `CHECK` three-way diff across 14 enums. **Needs its own named owner** | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) |
| 5 | The three rejection rules — `Bevel`, `PostDb1`, Mode B supervisor stamp | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) · [`FW-207`](FW-207-Domain-Model.md) |
| 6 | `TC-655` — every endpoint requires auth, excepting `/health` | [`FW-145`](FW-145-JWT-And-Role-Policies.md) |
| 7 | `TC-013`–`TC-017a` — `ITInhibit` conditions 3–5, line-scoped, no operator clear path | [`FW-205`](FW-205-ITInhibitService.md) |

⚠ **`TC-011` and `TC-012` are *not* this phase's** — they are `ITInhibit` conditions 1–2,
built by `FW-206` in Phase 4, and `TC-012` is blocked on `PLC-Q12`. **Running them at QA0
fails against code that was never in scope here.**

Mapped to the acceptance criteria:

| AC | How it is checked |
|---|---|
| Fifteen controllers extending `UAController` | Reflection over the assembly; names match `[API §3.1]` — **satisfied by `FW-N04`**, confirm only |
| `SpoolController` covers `GET /spools` | Swagger lists 16a **and** 16b under `Spool` |
| `PayoffStagingController` covers 10, 11, 12, 14 | Swagger lists four operations; **`mark-welded` appears nowhere** |
| `201`/`Blocked` on inspection failure | Post a failing inspection — expect `201`, `state:"Blocked"`, and the bay reported occupied on the next `GET /payoff/status` |
| The envelope | Every response, success and failure, carries `success`; failures carry `errors[]` and a string code; `data` is `null` on failure |
| `[Authorize]` everywhere | An unauthenticated call to each of the 24 returns `401`. `TC-655` covers this, excepting the anonymous `/health` |
| Schema-valid fixtures per `[API §4]` | Walkthrough compares each response against its §4 shape |

Plus the four `[API §7.2]` obligations this story owns (§2.3), and:

- Swagger shows **24 operations across 13 controllers**; `PassSchedule` and `ShiftSummary`
  are present and empty.
- FL2 responses carry `null` gauge and width — not `0`, not omitted.
- `PS-1100-FL1-003` is refused with `SCHEDULE_NOT_ACTIVE`/`422`; `PS-1100-FL1-001` succeeds.

---

## 7. Handoff

These stubs are what 1A builds against, so the fixtures are a **published interface** from
the moment they land — changing one later breaks a screen. `FW-139` and `FW-146` are the
natural next two; `FW-146` inherits `P-06`.

⚠ **Schedule the de-stub pass** (`[API §7.3]`). The stub check-in deliberately routes around
`OI-46`, `OI-47` and `OI-48` by assuming a single active schedule. **That assumption will not
remove itself** — name a signer-off per screen.

---

## 8. Open items and traps

| Item | Effect here |
|---|---|
| **`P-06`** | Blocks step 3. The envelope is undefined until it is settled |
| **`G6` / `OI-37`** | ✅ **Answered 15 Aug 2026** — the six roles exist on `ClaimTypes.Role`. Never a constraint here: this story's 24 actions carry **bare `[Authorize]`**, which is unaffected either way. Policies arrive in `FW-145` |
| **`OI-32`** | **Six specified behaviours have no endpoint at all** — roll-override revert (`FR-212`, decided), supervisor disposition of a pending Mode B checkout (`FR-325`/`FR-326`, decided), alloy-lookup CRUD, die-inventory CRUD, SPC-HOLD QA release, spool-completion prompt. `phase-01b` L188: **"Criterion 2 cannot cover an endpoint that does not exist."** Four are MVP-1. Do not invent shapes |
| **`OI-33`** | `planning_routings` columns unmapped — affects the `order` block on `GET /staging/queue` and `GET /rod/{alpha}`. Stub it; flag it |
| **`G14`** | Footage is `DECIMAL(10,2)` on run tables but `INT` on event tables. **A fractional footage does not round-trip through an event endpoint** — do not let a fixture imply it does |
| **`OI-21`** | Two rejection-ID formats (`REJ-####` vs `REJ-2026-0418`). Pick one for the fixture and record which |
| **Renames pending** | `[PLCC §6.3]` records `LineState` → `LineOperatingState` and `LineStatus` → `LineStateChanged`. **Build to `[API]`/`[SIG]`**; apply the rename in one pass across all three when arbitrated |

### 8.1 Stale text — do not build to it

| Stale | Correct | Source |
|---|---|---|
| **`[API §7.2]` callout: *"FL2 happy path — `PS-1100-FL2-001`, `Active`"*** | **`PS-1100-FL2-002`**, Standalone, `Active`. `-001` is **Hybrid, `Inactive`** | **`G40`**; verified against the seeded rows |
| **`[API §4.6a]`'s `POST /checkin/spool` worked example** — `passScheduleId: "PS-1100-FL2-001"` in **both** the request and the `"success": true` response | **`PS-1100-FL2-002`**. As written the example shows a check-in the contract must refuse **twice**: `Inactive` → `SCHEDULE_NOT_ACTIVE`/`422`, and `Hybrid` against a Standalone-origin spool → `FR-091` | **`G40`** |
| Seed file's own §8 banner comment: *"`PS-1100-FL2-001` · Hybrid · **Active**"* | The row beneath it says **`Inactive`** | `FlatWire_SampleData_Schedule.sql` |
| `[API]` front matter: *"31 live rows, of which MVP-1 implements 24"* | **32 live, MVP-1 implements 25** | `[API §3.2]` heading and note; `phase-01b` L82 |
| `[SSP]`: *"Thirteen thin controllers"* at 35 h | **Fifteen**, 45 h | `[API §3.1]`, resolved 15 Aug 2026 |
| `[TB §7]` rate-card line: *"14 controllers @ 4 h = 56 h … → 42 h"* | Header says **45 h** (15 × 3 h) | The 45 h header is the later figure; the basis line was not restated |
| Anything routing spool completion through `CoilController` | **`SpoolController`**, endpoint 16b | `[API §3.2]`, added 15 Aug 2026 |
