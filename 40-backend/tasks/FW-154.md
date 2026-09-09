---
id: FW-154
legacy_id:
title: GET /lines/status and LineStatusService
status: not-started
status_confirmed: false
status_note: "**Ready to build — and further along than the card suggests.** This is a **de-stub**, not a build"
owner:
jira:
mvp: 1
phase: "3"
stream: BE
streams: [BE]
priority: high
hours: 16
sprint: S1
depends_on: [FW-138, FW-141]
blocked_by: []
has_plan: true
started:
completed:
---
# FW-154 · `GET /lines/status` and `LineStatusService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** **Ready to build — and further along than the card suggests.** This is a **de-stub**, not a build
**Owner:** Backend (.NET) stream
**Audience:** The developer building `FW-154`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Sixteen hours, and **four details decide whether it is right.**
>
> **The route, the query, the handler and the interface all exist.** `GetLinesStatusQuery` was
> built as `P-61`'s first real de-stub and **already replaced `LinesFixtures.Status()`**. What
> is missing is one method body. **Do not rebuild the plumbing.**
> **⛔ The built code contradicts itself about who owns this.** `LineStatusService.cs:13` says
> *"Owned by FW-164"*; the throw at `:30` says *"it is `FW-154`'s"*. **`FW-154` is right** —
> `FW-164` is `GET /run/active` — and the header comment is wrong.
> **`LineStatus` is dark until commissioning test `C2`.** `TryMapLineState` returns `false`,
> which is why `FW-150` had to move its cache invalidation off it (`P-125`). **A snapshot
> endpoint reading line state inherits that**, and it must not report `false` as a state.
> **Bay occupancy is FL1/FL3 only.** `RodStaging` does not cover FL2, which checks in a spool.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-154 · `GET /lines/status` and `LineStatusService`
> **Hours:** 16 h BE · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** BE
>
> **As a** client developer,
> **I want** a snapshot endpoint for page load,
> **So that** the board renders immediately and then goes live rather than starting empty.
>
> **Acceptance Criteria:**
> - [ ] `LinesController` `GET /lines/status` returns `LinesStatusResponse` / `LineStatusDto` / `PayoffStatusDto` / `ActiveAlertDto`
> - [ ] `PayoffStatusDto` carries bay **occupancy** (`state`, `rodAlpha`) alongside live weight
> - [ ] `LineStatusService` composes scheduling data + run state + latest OPC readings
> - [ ] Any authenticated role may read
> - [ ] Contract test against `04-APIContract.md`
>
> **Rate-card basis:** query endpoint 4 h + `LineStatusService` non-trivial service 12 h = 16 h (§2)
> **Dependencies:** FW-138, FW-141
> **Blockers:** —

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The live telemetry stream that follows the snapshot | [`FW-150`](FW-150.md) — built |
| `LineStatus` transitions and markers | [`FW-172`](FW-172.md) |
| `GET /run/active` and `gaugetrace` | [`FW-164`](FW-164.md) — ⚠ **the story the header comment confuses this with** |
| The alert lifecycle behind `ActiveAlertDto` | `FW-N06` — ⚠ this endpoint **reads** alerts, it does not raise them |
| Bay staging commands | [`FW-158`](FW-158.md) |
| DB1 the screen | ⚠ **Left MVP-1 scope** — which is why `FW-164` is *"the trial's landing route"* |

### 1.2 What already exists

Read off the built code on 29 Aug 2026. **Most of this story is built.**

| Thing | Where | State |
|---|---|---|
| `LinesController` + route | `FlatWire.API/Controllers/Lines/LinesController.cs:63` | ✅ Built — sends `GetLinesStatusQuery` through MediatR |
| **`GetLinesStatusQuery` + handler** | `FlatWire.Application/Queries/Lines/GetLinesStatusQuery.cs` | ✅ **Built** — `P-61`'s first real de-stub; **already replaced `LinesFixtures.Status()`** |
| Handler registration, boot-asserted | `Program.cs:390` — *"expected exactly 1"* | ✅ Built |
| `ILineStatusService` | `FlatWire.Domain/Services/` | ✅ Built (`FW-140`) |
| `StubLineStatusService` | `FlatWire.Infrastructure/Services/` | ✅ Built — serves fixtures under `useMockData` |
| **`LineStatusService` (real)** | `FlatWire.Infrastructure/Services/LineStatusService.cs:28` | ⛔ **`throw new NotImplementedException("… it is FW-154's …")`** — `P-64`'s named shell. **This is the deliverable** |
| DTOs | `LinesStatusResponse`, `LineStatusDto`, `PayoffStatusDto`, `ActiveAlertDto` | ✅ Built — `FW-138` authored them (`P-52`) |
| `RodStaging` | `AggregatesModel/RodStaging.cs` + table | ✅ Built — ⚠ **FL1/FL3 only** |

> ⛔ **A contradiction in the built code, and it should be fixed with this story.**
> `LineStatusService.cs:13` reads *"The real `ILineStatusService` — served when `useMockData` is
> off. **Owned by FW-164**"*, and `:21` says *"`FW-164` replaces each throw"* — while the throw
> itself at `:30` names **`FW-154`**. **`FW-154` is correct**; `FW-164` owns `GET /run/active`
> and `gaugetrace`. The header comment was copied from a sibling service.

---

## 2. The four details

### 2.1 This is a de-stub — one method body

`P-64`'s pattern is already in place: the interface, the stub, the named-throw shell, the query,
the handler and the registration are all built and boot-asserted. **The 16 h buys the
composition logic inside `GetLinesStatusAsync`, and nothing structural.**

⚠ **The 16 h basis was priced as *"query endpoint 4 h + non-trivial service 12 h"*.** The
4 h half is already spent — `FW-138` built the endpoint and `FW-139` the query. **Do not read
the remaining work as 16 h of greenfield.**

### 2.2 `LineStatus` is dark until `C2`

`TryMapLineState` returns `false` until commissioning test `C2`. `FW-150` discovered what that
means: a cache keyed on `LineStatus` **would never invalidate**, which is why `P-125` moved
invalidation onto run-lifecycle events.

⛔ **A snapshot endpoint must not report an unmappable state as a state.** The honest answer is
`null`/unknown, and the client renders accordingly — the same discipline `FW-150` applies when
it sends nothing rather than `0`.

⚠ `FW-150`'s loop is **silent on `LineStatus` pre-`C2`** for exactly this reason. **This
endpoint must agree with the stream**, or the board renders a state on load that the live feed
then never confirms or corrects.

### 2.3 Bay occupancy is FL1/FL3 only

AC 2 puts occupancy (`state`, `rodAlpha`) on `PayoffStatusDto`. That comes from `RodStaging`,
which is **FL1/FL3 only** — FL2 checks in a spool and has a traversing take-up, not VPS payoffs.

⚠ **`FW-150` hit this exact asymmetry** and sends no `PayoffWeight` for FL2. **This endpoint
must not report FL2 as having empty bays**, which is what a naive `RodStaging` query returns —
an empty result and a "not loaded" alert on a line that has no bays to load.

⛔ **`G21`: FL1 and FL3 share one physical payoff (`FL1PO`).** So occupancy for FL3 is **the same
bay** as FL1's. Reporting them as independent is the defect `G21` recorded.

### 2.4 "Any authenticated role" is a real requirement, and `FW-145` is unbuilt

AC 4 says any authenticated role may read. That is the **absence** of a role policy, not a
policy — so it needs no `FlatWireRoles` constant and is not blocked by `FW-145`.

⚠ **But `FW-145` is unbuilt**, so today every endpoint is `[Authorize]`-gated with **no role
claim issued** — `P-136` records that `/sim` therefore denies everyone. **This endpoint will
behave correctly once a token exists**; it should not acquire a role check to compensate.

---

## 3. Build order

1. **Fix the header comment** on `LineStatusService.cs:13`/`:21` — `FW-154`, not `FW-164`
   (§1.2). One line, and it stops the next reader looking in the wrong plan.
2. Implement `GetLinesStatusAsync`, composing the three sources AC 3 names: scheduling data,
   run state, latest OPC readings.
   ⚠ **The readings source is `FW-N05`'s channel / `RunReading`, not a live OPC call** — this is
   a snapshot, and `RunReading` is written by raw SQL and **absent from the EF model** (`P-12`),
   so read it with Dapper on the context's connection as `FW-150` does.
3. **Line state**: return unknown rather than a fabricated state while `TryMapLineState` is
   `false` (§2.2). **Match `FW-150`'s silence.**
4. **Bay occupancy** (§2.3): FL1/FL3 from `RodStaging`; FL2 from `SpoolCheckin`;
   ⛔ **FL1 and FL3 report the same shared `FL1PO` bay** (`G21`).
5. `ActiveAlertDto` — read whatever alert state exists. ⚠ **`FW-N06` owns the lifecycle**; if it
   is unbuilt, return an empty list rather than inventing one.
6. **Delete `StubLineStatusService`?** ⛔ **No** — `FW-N12` owns the de-stub cleanup, and `P-63`
   keeps the stub as the single home of fixture data until then.
7. Contract test against `[API]` (AC 5).

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-180` precede this story.

### `P-181` — the snapshot and the stream must agree, including about ignorance

§2.2. `FW-150` sends nothing for a channel it cannot fill and is silent on `LineStatus` pre-`C2`.
If this endpoint fabricates a state on page load, the board shows something the live feed will
never confirm or correct — **worse than an empty board**, which is the problem the story exists
to solve.

**So: unknown is a value.** The client renders "—", not "IDLE".

### `P-182` — FL2 has no bays, and that is not the same as empty bays

§2.3. A naive `RodStaging` query returns nothing for FL2 and the board raises *"Payoff2 not
loaded"* on a line with no payoffs. **The DTO must distinguish *not applicable* from
*unoccupied*.**

⚠ And **FL1/FL3 share `FL1PO`** (`G21`), so the two lines' occupancy is one fact reported twice,
not two facts.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **De-stub only** | `git diff` touches `LineStatusService` and the header comment; **no new controller, query, handler or registration** |
| Header comment | Names **`FW-154`**, not `FW-164` (§1.2) |
| Envelope | `FlatWireResult<LinesStatusResponse>` (`P-56`); `401` unauthenticated |
| Any role | Any authenticated token reads it — **no role policy added** (§2.4) |
| **Line state pre-`C2`** | Reported as **unknown**, never fabricated; **agrees with `FW-150`'s silence** (`P-181`) |
| **FL2 bays** | Reported as **not applicable**, not as empty. ⛔ No "Payoff2 not loaded" on FL2 (`P-182`) |
| **FL1/FL3 bay** | The shared `FL1PO` is one occupancy fact, reported consistently for both lines (`G21`) |
| `RunReading` | Read by Dapper on the context connection; **still absent from the EF model** (`P-12`) |
| Alerts | Empty list while `FW-N06` is unbuilt — **not fabricated** |
| Stub retained | `StubLineStatusService` still present; `FW-N12` owns its deletion (`P-63`) |
| Contract | Matches `[API]` (AC 5); 61/61 still pass |

---

## 6. Handoff

The board goes live from [`FW-150`](FW-150.md)'s stream after this snapshot, and
the two must agree (`P-181`). `FW-N06` owns the alert lifecycle `ActiveAlertDto` reads.
[`FW-158`](FW-158.md) writes the bay occupancy this reads,
and `FW-160` broadcasts its changes. `FW-N12` deletes the stub when the last throw goes.
⚠ **DB1 left MVP-1 scope**, so [`FW-164`](FW-164.md) — not this —
is the trial's landing route.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **The header comment** | `LineStatusService.cs:13`/`:21` name **`FW-164`**; the throw names `FW-154`. **`FW-154` is right** |
| **`C2`** | `TryMapLineState` returns `false` until this commissioning test (`P-181`) |
| **`G21`** | FL1 and FL3 **share** `FL1PO` — one bay, two lines (`P-182`) |
| **`P-12`** | `RunReading` has no repository and no EF mapping, by design |
| **`FW-145`** | Unbuilt, so no role claim is issued. ⚠ **Do not add a role check to compensate** (§2.4) |
| **`P-63` / `FW-N12`** | The stub stays until the de-stub completes |
