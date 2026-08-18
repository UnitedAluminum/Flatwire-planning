# FW-146 · Global exception middleware and the response envelope

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — §2.4 added (what `HttpGlobalExceptionFilter` actually emits); **`P-18` settled — forced, not chosen — and its "survivable fallback" withdrawn**; §7 restructured into open / closed / stale, closing four of five *(earlier same day: §2.1's code-is-a-label rule; `P-18`'s overload correction; `G2`/`OI-39` dated to before T2)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **`P-18` settled; four of five open items closed (§7.2). `P-06` remains, and is `FW-138`'s**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-146`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Eight hours, one shared primitive, and **two ways to get it
> wrong that are both invisible until a screen misbehaves.**
>
> **The first:** `POST /staging/rod` returns **`201 Created` with `state:"Blocked"`** when an
> inspection fails. `phase-01b` L93 names this *"exactly what a global exception middleware
> gets wrong"* — a failed business rule returning a success code, with the row committed.
> A middleware that maps rule violations to `422` will break it.
>
> **The second:** the framework already installs a `HttpGlobalExceptionFilter` via
> `AddCustomMvc()`, and **it wins** — it is inner to any middleware and sets
> `ExceptionHandled = true` on every path. Add middleware without removing it and the
> middleware is **dead code**, while the filter collapses every non-validation exception to
> `500`. §2.4 and `P-18`.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-146 · Global exception middleware and the response envelope
> **Hours:** 8 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** client developer,
> **I want** every failure mapped to a predictable status and envelope,
> **So that** the UI can branch on a contract rather than on a message string.
>
> **Acceptance Criteria:**
> - [ ] Global exception middleware maps to `400` validation, `404` not found, `409` conflict, `422` unprocessable, `500` PLC/server
> - [ ] Every response — success or failure — uses the `{Data, Success, Errors}` envelope
> - [ ] Tests assert each status path
>
> **Rate-card basis:** shared primitive (8 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** —

### 1.1 ⚠ The envelope is not yours to define

[`FW-138`](FW-138-Fifteen-Thin-Controllers.md) `P-06` establishes `FlatWireResult<T>`
(`Data` · `Success` · `Errors` `string[]` · `ErrorCode` `string`) because **no framework type
produces `[API §1.2]`'s shape** — `ActionResultBase<T>` has no `errors` array and an `int`
code, and `UAController.Error(...)` returns `{ErrorMessage, RequestUri}`.

**This story wires the middleware onto that type. It must not redefine it.** The AC's
`{Data, Success, Errors}` is satisfied by `P-06`, not by a second envelope.

⚠ **This story is blocked on the *artifact*, not on the *answer*** — it needs the type to
exist, not the ratification to have happened. Both stories are wave 1, so if `FW-138` lands
first there is no wait. `P-06` remains the one open item here (§7.1).

---

## 2. The mapping

`[API §1.3]` and `phase-01b` L92:

| Exception / condition | HTTP | Note |
|---|---|---|
| FluentValidation failure (via `ValidatorBehavior`) | **400** | Shape, type and range only |
| Not authenticated / not permitted | **401** / **403** | Handled by the auth layer, not here |
| Resource not found | **404** | Rod alpha, schedule id, run id |
| `ROWVERSION` mismatch, uniqueness violation, state conflict | **409** | *"someone got there first — re-read and retry"* |
| `BusinessRuleValidationException` | **422** | *"this will never succeed as submitted"* |
| PLC push failure, unhandled | **500** | Transaction aborted, compensating writes issued |

**The `409`/`422` split is load-bearing** (`[API §1.3]`). It is the difference between a
client that retries and a client that stops, and it is the most likely thing to be collapsed
by a middleware written from habit.

### 2.1 The 18-code catalogue travels with the status

`[API §1.8]` — emit the machine-readable code **alongside** the human-readable `errors[]`,
so a client can branch on the reason: `ROD_NOT_FOUND`, `ROD_NOT_ALLOCATED`,
`ROD_UNAVAILABLE`, `ROD_WRONG_ORDER`, `BAY_OCCUPIED`, `ROD_ALREADY_STAGED`,
`LINE_NOT_ELIGIBLE`, `INSPECTION_FAILED`, `CARRY_FORWARD_REQUIRED`,
`DIAMETER_OUT_OF_TOLERANCE`, `SUPERVISOR_AUTH_REQUIRED`, `SCHEDULE_NOT_ACTIVE`,
`SCHEDULE_NO_MATCH`, `RUN_ALREADY_ACTIVE`, `PAYOFF_MISMATCH`, `LINE_STILL_RUNNING`,
`PLC_PUSH_FAILED`, `CONCURRENCY_CONFLICT`.

`INSPECTION_FAILED` additionally carries `{route:"wipRejection", rodAlpha}` — a payload, not
just a code.

> ### ⚠ The code is a **label**, never a selector
>
> **Status comes from the exception type, or from the action that returned it. It is never
> looked up from the error code.** Build a `Dictionary<string, HttpStatusCode>` and this
> story is wrong — that is the natural first implementation and it must not be written.
>
> **`INSPECTION_FAILED` is the case that proves it.** The same code, carrying the same
> `{route, rodAlpha}` payload, appears at two statuses:
>
> | Endpoint | Status | Source |
> |---|---|---|
> | `POST /checkin/rod` | **`422`** — throws; the middleware maps the **type** | `[API §4.6]` |
> | `POST /staging/rod` | **`201 Created`** + `state:"Blocked"` — **throws nothing**; the action returns it (§2.2) | `[API §4.5]` |
>
> Derived from the type, the two never collide: one path throws and one does not. Derived
> from the code, one of them is always wrong.
>
> ⚠ **`[API §1.8]`'s row states `INSPECTION_FAILED | 422` unqualified**, which is wrong at
> `/staging/rod`. Raise it with the contract owner; **do not edit the catalogue from here**
> and do not build to the unqualified reading.

### 2.2 ⚠ The `201`/`Blocked` exception

`POST /staging/rod` commits the row **before** the inspection gate and returns
**`201 Created`** with `state:"Blocked"` on failure — because writing nothing reported an
occupied bay as free, and a bundle is already physically on the payoff when it is inspected.
It is still a hard block with no override; `POST /wipreject` is the only thing that clears it.

**This is not an exception path at all** — the action returns it deliberately
([`FW-138`](FW-138-Fifteen-Thin-Controllers.md) §4 step 5a). The middleware's job is to
**leave it alone**. A rule that says "inspection failure → `INSPECTION_FAILED` → `422`" is
correct everywhere except here, and here it is wrong.

### 2.3 PLC failures are compensated, not rolled back

`phase-01b` L111: OPC writes are **not transactional** — model recovery as **compensating
re-clears**, not "rollback" (`G2`). Cross-DB check-in is **not one ACID transaction**. So a
`500` from `PLC_PUSH_FAILED` means *the database transaction aborted and compensating writes
were issued*, which is a different promise from "nothing happened". Do not word it as a
rollback.

### 2.4 ⚠ What `HttpGlobalExceptionFilter` does if you leave it in

Read from `UA.Framework.API/Infrastructure/Filters/HttpGlobalExceptionFilter.cs` on
15 Aug 2026. `OnException` has exactly **two branches**, and sets
`context.ExceptionHandled = true` **unconditionally**:

| Exception | What it emits |
|---|---|
| `CustomException` *(what `ValidatorBehavior` throws)* | **`ValidationProblemDetails`** — `application/problem+json`, **not the UAL envelope** — status **400**, with `Errors["DomainValidations"] = [ context.Exception.Message ]` |
| **everything else** | `ActionResultBase<object>` with `ErrorCode = (int)HttpStatusCode.InternalServerError`, `ErrorDescription = "An error occurred. Please try again."`, status **500** |

**Four consequences, and the first is fatal to the contract:**

1. ⚠ **Every non-validation exception becomes `500`.** `BusinessRuleValidationException` →
   `500` not `422`. A `ROWVERSION` conflict → `500` not `409`. Not-found → `500` not `404`.
   **The 409/422 split `[API §1.3]` calls load-bearing does not survive at all** — §2's whole
   mapping table becomes unreachable.
2. **Validation returns `problem+json`, not the envelope** — no `success`, no `errors[]`, a
   different content type.
3. ⚠ **The validation failures are discarded.** It reads only `context.Exception.Message`,
   which for `CustomException` is the fixed string
   `"Command Validation Errors for type CheckInRodCommand"`. The `failures` collection inside
   the wrapped `ValidationException` is **never touched** — so the client learns nothing
   about which field failed. Not one error: **zero useful ones**.
4. **In Development it writes `Convert.ToString(context.Exception)`** — the full exception and
   stack — into `ErrorDescription`, which §3 step 7 forbids.

> **And `ExceptionHandled = true` is set on every path**, so with the filter present the
> middleware is never reached for anything thrown inside MVC.

---

## 3. Build order

1. **Confirm `P-06`** and the `FlatWireResult<T>` type.
2. **Remove `HttpGlobalExceptionFilter` after `AddCustomMvc()`** — `P-18`. Do this *before*
   writing the middleware, or it will appear to work while the filter is answering.
3. **Map the exception types** per §2, each with its catalogue code.
4. **Preserve the correlation id** — `[API §1.4]` requires `X-Correlation-Id` echoed on
   *every* response, and error paths are where it matters most.
5. **Log at the boundary** with the correlation id, via `FW-143`'s Serilog wiring.
6. **Verify the `201`/`Blocked` path is untouched** (§2.2).
7. **Do not leak internals** — `ErrorDescription = ex.Message` is `CoilCheckin`'s habit and
   puts exception text on the wire.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-17` precede this story.

### `P-18` — the framework filter must be removed. ✅ **Settled 15 Aug 2026 — forced, not chosen**

`AddCustomMvc()` adds `HttpGlobalExceptionFilter` to the MVC filter pipeline. This story adds
a global handler. **Two handlers for one exception is the defect.**

> ✅ **This was marked *"needs ratifying"* and is now settled, because reading the filter
> removed the choice.** §2.4: it collapses **every non-validation exception to `500`**, so
> `BusinessRuleValidationException` returns `500` instead of `422` and a `ROWVERSION`
> conflict returns `500` instead of `409` — **`[API §1.3]`'s load-bearing 409/422 split does
> not survive in any form**. It also emits `problem+json` for validation, **discards the
> validation failures entirely**, and leaks the stack in Development.
>
> **There is nothing left to ratify: keeping it fails `[API §1.2]`, `[API §1.3]`,
> `[API §1.8]` and `phase-01b` exit criterion 2 simultaneously.** Removal is the only build
> that meets the contract.

An MVC **filter** only sees exceptions thrown inside the MVC pipeline; **middleware** sees
those plus everything outside it. `[API §1.2]`'s envelope must apply to both — a client
cannot branch on a contract that holds only for some failures.

⚠ **And the filter is *inner* to the middleware, which decides the answer.** If it stays, it
handles every MVC exception first and the middleware **never sees them** — so "leave the
filter in place" does not produce two handlers competing, it produces **middleware that is
dead code for all 24 endpoints**. That is worse than the problem this decision exists to
avoid.

**Resolution: call `AddCustomMvc()` as `[ARC §2.2]` binds, then remove just the exception
filter, and let the middleware be the single mapper.**

```csharp
services.AddCustomMvc();                    // template-bound: global AuthorizeFilter,
                                            // CorsPolicy, AddControllersAsServices()
services.Configure<MvcOptions>(o =>         // then remove only the exception filter
    o.Filters.RemoveType<HttpGlobalExceptionFilter>());
```

Middleware sits **before `UseRouting()`**, so it sees MVC exceptions *and* everything thrown
outside the pipeline — which is what `[API §1.2]`'s envelope has to cover.

**Why not simply skip `AddCustomMvc()`.** It also supplies the global
`AuthorizeFilter(RequireAuthenticatedUser())` — **the thing that actually enforces
`[Authorize]`, since this pipeline has no `app.UseAuthorization()`** (`FW-N04` step 6) — plus
the `CorsPolicy` and `AddControllersAsServices()`. Forfeiting all of that to avoid one filter
is the wrong trade.

⚠ **Correction — an earlier draft of this plan called *"keep the filter, scope the middleware
to what escapes MVC"* a worse-but-survivable fallback. It is not survivable.** §2.4 shows
why: the filter answers *every* MVC exception and collapses the status contract, so that
option does not degrade the design — it forfeits it. **There is no fallback.**

**Rejected alternative:** shadowing the filter by registering our own earlier and setting
`ExceptionHandled` first. It leans on filter-ordering semantics, reads as accidental, and
leaves a dead filter in the collection. `RemoveType` is explicit and greppable.

**On the divergence.** This is the only UAL service whose contract specifies a status **per
failure kind** — `[API §1.3]`'s 409/422 split, `[API §1.8]`'s 18 codes. The sibling services
carry no such contract, so the filter costs them nothing. **The divergence is in the
requirement, not in the taste** — and it must still be visible in `Program.cs` with a comment
pointing here, because §5 has to assert the removal: a missed one fails silently.

Related and already settled by `FW-N04` step 6: **there is no `app.UseAuthorization()`** in
this pipeline, so `401`/`403` come from the global `AuthorizeFilter` and never reach this
middleware. That is expected, not a gap.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes AC 3 as written. Each status
path is walked manually in the QA0 contract walkthrough.

| Path | Expected |
|---|---|
| Validation failure | `400`, `success:false`, `errors[]` populated, `data:null` |
| Unknown rod alpha | `404` + `ROD_NOT_FOUND` |
| Occupied bay | `409` + `BAY_OCCUPIED` |
| `Draft` schedule at check-in | `422` + `SCHEDULE_NOT_ACTIVE` |
| Stale `ROWVERSION` | `409` + `CONCURRENCY_CONFLICT` |
| PLC push failure | `500` + `PLC_PUSH_FAILED` |
| **Failed staging inspection** | **`201`**, `state:"Blocked"` — **not** `422`. The regression check for this story |
| **Failed inspection at check-in** | **`422` + `INSPECTION_FAILED`** — the *same code* as the row above at a **different status**. Both must hold at once (§2.1) |
| **One handler only** | `HttpGlobalExceptionFilter` is **absent from `MvcOptions.Filters`** at runtime, and every failure — MVC and non-MVC — returns the identical shape *(`P-18`)* |
| Any failure | `X-Correlation-Id` echoed; no exception text or stack on the wire |

⚠ **The two inspection rows are the ones to run together.** Passing either alone is
consistent with a code→status lookup, which is the implementation §2.1 forbids.

**Four checks that exist because of §2.4.** Each expected value is precisely what the
framework filter returns if the removal was missed, so each is a positive test that it was
not:

| Check | Expected — and what a missed removal gives instead |
|---|---|
| `BusinessRuleValidationException` | **`422`** — the filter gives **`500`** |
| Stale `ROWVERSION` | **`409`** — the filter gives **`500`** |
| Validation failure, content type | the **envelope** as `application/json` — the filter gives **`ValidationProblemDetails`** as `application/problem+json` |
| Validation failure, field detail | `errors[]` naming **the fields that failed** — the filter gives the single fixed string `"Command Validation Errors for type …"` |

⚠ **Run at least one in `Development`**, where the filter additionally writes the full
exception and stack into `ErrorDescription` — the fastest way to see it is still answering.

---

## 6. Handoff

Every controller and handler depends on this being consistent. `FW-138`'s per-action failure
returns and this middleware must produce the identical shape — a client that sees two shapes
has no contract.

---

## 7. Open items and stale citations

> **How an item leaves this section.** Three routes, and most of what was here took the
> second or third: **(a) resolved** — the question now has an answer · **(b) scoped out** —
> the item is real, but *this story's obligation is fully determined regardless*, and it
> lives on elsewhere · **(c) reclassified** — it was never an open question, but a stale
> citation or a dependency.

### 7.1 Open — one, and it is not this story's to settle

| Item | Effect here |
|---|---|
| **`P-06`** | The envelope **type**, owned by [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) §5 and marked *needs ratifying* there. ⚠ **This story is blocked on the *artifact*, not on the *answer*** — both are wave 1, so if `FW-138` lands first there is no wait. **Evidence that should make ratification a formality, from §2.4:** the framework's own filter sets `ActionResultBase<T>.ErrorCode = (int)HttpStatusCode.InternalServerError` — so `ErrorCode` means *"HTTP status as an integer"*, **incompatible with `[API §1.8]`'s 18 string codes in meaning, not merely in type** |

### 7.2 Closed 15 Aug 2026 — four

| Item | Route | Why it closed | Residual, and who holds it |
|---|---|---|---|
| **`P-18`** | **a** | ✅ **Forced, not chosen.** §2.4 shows the filter collapses every non-validation exception to `500` and destroys the 409/422 split, so **removal is the only build that meets the contract** — nothing remains to ratify | None. Recorded in §4, asserted in §5 |
| **`INSPECTION_FAILED` two statuses** | **a + c** | ✅ **Design settled** by §2.1's rule — status comes from the exception type or the action, never from the code, so the two paths never collide | `[API §1.8]`'s **unqualified `422`** is a **spec defect**, not an open question → §7.3, for the contract owner |
| **`OI-46`** | **b** | ✅ **This story's obligation is complete**: emit `SCHEDULE_NO_MATCH` + `422` + `errors[]`. The *"block and alert Operations"* half is a **side effect**, and exception middleware must not carry business behaviour on an already-failing path | `OI-46` stays open. [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) owns the behaviour, via `FW-208` → `AlertRaised`. Must close before the de-stub pass (`[API §7.3]`) |
| **`G2` / `OI-39`** | **b** | ✅ **No exposure to the outcome.** §2.3's wording — `500` means *the transaction aborted and compensating writes were issued*, never *"rollback"* — holds whichever strategy `G2` picks, saga/outbox or `INFLAT` mirror | `G2` stays **Critical**, **before T2**, 24–64 h reserve, **settle `G30` first** — owned by [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) and [`FW-151`](FW-151-PLCTagService.md), where the recovery is built |

### 7.3 Stale citations

| Stale | Correct | Source |
|---|---|---|
| AC 3: *"Tests assert each status path"* | Withdrawn 15 Aug 2026; manual walkthrough instead | `[TS §1.2]` |
| Reading AC 2's `{Data, Success, Errors}` as *"use `ActionResultBase<T>`"* | No framework type carries an `errors` array, and `ErrorCode` is an `int` the framework itself uses to mean *HTTP status* (§2.4) | `FW-138` `P-06` |
| **`[API §1.8]`: `INSPECTION_FAILED \| 422`**, unqualified | **`422` at `POST /checkin/rod`; `201` + `state:"Blocked"` at `POST /staging/rod`.** The catalogue's HTTP column cannot be endpoint-agnostic for this code | `[API §4.5]`, `[API §4.6]` — **raise with the contract owner** |
| **This plan's own `P-18`**, before 15 Aug 2026: *"not calling `AddCustomMvc()`'s filter-adding overload"* | ⚠ **No such overload exists.** `AddCustomMvc()` **and** `AddCustomMvcWithoutAuthentication()` both `Filters.Add(typeof(HttpGlobalExceptionFilter))`; only the `AuthorizeFilter` differs. The filter is **removed after registration**, not avoided at it | `UA.Framework.API/Extensions/ServiceCollectionExtensions.cs` |
| **This plan's own `P-18` fallback**, before 15 Aug 2026: *"keep the filter … worse, survivable"* | ⚠ **Not survivable** — it forfeits the status contract entirely (§2.4). **There is no fallback** | `UA.Framework.API/Infrastructure/Filters/HttpGlobalExceptionFilter.cs` |
