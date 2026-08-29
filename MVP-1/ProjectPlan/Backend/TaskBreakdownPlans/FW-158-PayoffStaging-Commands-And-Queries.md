# FW-158 · `PayoffStagingController` — staging commands and queries

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **A de-stub — all four routes exist.** Two acceptance criteria are **stale on the card**
**Owner:** Backend (.NET) stream
**Audience:** The developer building `FW-158`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Twenty-six hours, and **five details decide whether it is
> right — two of them because the card is out of date about its own scope.**
>
> **⛔ `409` must come from the DATABASE, not from application code.** AC 3 is the whole point
> of the story: a read-then-write check *"is there a rod on this bay"* has a race window, and
> two rods on one physical bay is the defect `G21` recorded.
> **`Blocked` is a DERIVED state, never a fourth `Status`.** An inspection `Fail` **commits**
> the row and returns **`201`** with `state: "Blocked"`. It was `422`-and-write-nothing until
> 31 Jul 2026 — **the bay must stay occupied, because the failed bundle is physically on it.**
> **Two of the card's own criteria are superseded:** the FL2 `422` rejection is **withdrawn**
> (`FR-533`, and the endpoint change is an **unapplied** ledger wave), and
> `POST /staging/rod/mark-welded` **is not built** — it was retired 1 Aug 2026.
> **The inspection is 3 items, not 4** (`G14`) — do not add a connector-tag item.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-158 · `PayoffStagingController` — staging commands and queries
> **Hours:** 26 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE
>
> **As a** developer,
> **I want** bay staging exposed as commands and queries with conflicts enforced by the database,
> **So that** two rods can never occupy one bay through a read-then-write race.
>
> **Acceptance Criteria:**
> - [ ] `GET /payoff/status`, `GET /staging/queue`, `POST /staging/rod`, `POST /staging/rod/unstage`
> - [ ] `StageRodCommand` (reuses the **3-item** `InspectionDto` — **do not add a connector-tag item**, see **G14**), `UnstageRodCommand` (writes `RodCheckout` with `Mode='ModeP'`), `MarkStagedRodWeldedCommand` (validates alloy/temper/diameter against the running coil)
> - [ ] **Bay-occupancy conflicts surface as `409` from the filtered unique indexes**, not from application-level checking
> - [ ] ~~**FL2 rejected `422`**~~ ⚠ **withdrawn with `FR-031`, 20 Aug 2026 reversal** — FL2 pre-check-in is accepted (`FR-533`). The endpoint change is wave W5 of the 20 Aug ledger and is **not yet applied**
> - [ ] **An inspection `Fail` commits the staging row and returns `201` with `state: "Blocked"`** plus the WIP-rejection route, with **no override** — the bay must stay occupied because the failed bundle is physically on it *(changed 31 Jul 2026; was `422`-and-write-nothing)*
> - [ ] Prior footage without acknowledgement rejected `422` (`PRC007`)
> - [ ] **`POST /staging/rod/mark-welded` is not built** — it was retired 1 Aug 2026; DB2A's weld posts to `POST /weldevent` in Phase 6
>
> **Rate-card basis:** 3 commands @ 6 h = 18 h + 2 queries @ 4 h = 8 h → 26 h (§2, §3 worked derivation)
> **Dependencies:** FW-139, FW-159
> **Blockers:** **G21** · **G22** · **OQ-23** *(WIP rejection releases a blocked bay — the cross-phase link to Phase 7)*

### 1.1 Out of scope

| Concern | Story |
|---|---|
| `POST /weldevent` — where DB2A's weld actually posts | [`FW-172`](FW-172-Run-Event-Markers.md) / `FW-166`, **Phase 6** |
| `PayoffStateChanged` broadcasts | `FW-160` — this story **raises** the state change; that one broadcasts it |
| The check-in that consumes a staged row | [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) |
| WIP rejection releasing a blocked bay | [`FW-174`](FW-174-WipRejection-And-Checkout-Services.md), **Phase 7** — ⚠ `OQ-23`'s cross-phase link |
| `RodStaging` the table and its indexes | `FW-159`, DB — ✅ **built** |
| The DB2A screen | `RodPreCheckin.md` |

### 1.2 What already exists

Read off the built code on 29 Aug 2026. **The controller and all four routes are built.**

| Thing | Where | State |
|---|---|---|
| `PayoffStagingController` | `FlatWire.API/Controllers/PayoffStaging/` | ✅ **Built** |
| **All four routes** | `payoff/status` `:63` · `staging/rod` `:84` · `staging/rod/unstage` `:108` · `staging/queue` `:129` | ✅ **Built and wired** — AC 1 is **already met** |
| `IPayoffStagingService` + stub + named-throw shell | `FlatWire.Domain/Services/`, `FlatWire.Infrastructure/Services/` | ✅ Built (`FW-140`, `P-64`) |
| `RodStaging` aggregate | `AggregatesModel/RodStaging.cs` | ✅ Built (`FW-207`) |
| `RodStaging` table + **filtered unique indexes** | `04_Runs`, `07_Indexes` — `UX_RodStaging_Bay` | ✅ **Built** — the mechanism AC 3 requires |
| `RodCheckout` aggregate + table | | ✅ Built — `UnstageRodCommand` writes `Mode='ModeP'` |
| `FW-146`'s `409` arm | `ExceptionHandlingMiddleware` | ✅ Built |
| `BayStateChanged` domain event | `FlatWire.Domain/Events/RunEvents.cs:165` | ✅ Built — carries `RodSeqno`, `IsWelded`, `IsBlocked` (`P-139`) |
| The commands and handlers | | ⛔ **Do not exist.** This is the deliverable |

⚠ **`BayStateChanged` already carries `IsBlocked` as a distinct field** (`P-139`) precisely
because `Blocked` is **derived** and cannot be recovered from the other values. The domain
already models §2.2 correctly — **the handlers must not flatten it.**

---

## 2. The five details

### 2.1 `409` comes from the index, and that is the story

AC 3 is not a style preference. An application-level *"is this bay occupied"* read followed by a
write has a race window, and two rods on one physical bay is precisely what `G21` recorded.

**The filtered unique index `UX_RodStaging_Bay` is the enforcement**; the handler's job is to
let the `DbUpdateException` surface and `FW-146` translate it to **`409`**.

⛔ **`G21`'s shape matters here.** FL1 and FL3 **share one physical payoff** —
`STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"}` — so the index is keyed on the **station**, not
on the line. **A handler that scopes the conflict check by `LineId` re-opens the gap with the
index still in place.**

### 2.2 `Blocked` is derived, and a `Fail` returns `201`

The rule changed on 31 Jul 2026 and the old behaviour is the intuitive one, which is why it
needs stating: an inspection `Fail` **commits the staging row** and returns **`201`** with
`state: "Blocked"` and the WIP-rejection route. **No override.**

The reason is physical: **the failed bundle is on the bay.** Writing nothing would leave the
system believing a bay is free while a rod sits on it.

⛔ **`Blocked` is `Status='Staged'` + any inspection column `='Fail'`.** It is **never a fourth
`Status` value**, and `IsWelded` is a **flag on a `Staged` row**, not a status either. So any
handler branching on *"staged"* also matches welded and blocked rods **unless it says
otherwise** — and that is the single most likely bug in this story.

### 2.3 Two acceptance criteria are stale

| Criterion | State |
|---|---|
| *"FL2 rejected `422`"* | ⛔ **Withdrawn** — the 20 Aug 2026 `FR-031` reversal; **FL2 pre-check-in is accepted** (`FR-533`). ⚠ **The endpoint change is wave W5 of the 20 Aug ledger and is NOT YET APPLIED** |
| `POST /staging/rod/mark-welded` | ⛔ **Not built** — retired 1 Aug 2026. DB2A's weld posts to `POST /weldevent` in **Phase 6** |

⚠ **`MarkStagedRodWeldedCommand` is still listed in AC 2** while its endpoint is retired in AC 7
— **the same card says both.** The command may still be needed (the weld *does* change bay
state), but **it is not reached by a `/staging/rod/mark-welded` route.** Resolve before
building: either the command is invoked from `POST /weldevent`'s handler in Phase 6, or it does
not exist.

⛔ **Check whether ledger wave W5 has been applied before writing the FL2 branch.** Building to
the card's withdrawn `422` would ship a rejection the client reversed.

### 2.4 The inspection is three items

`G14`: `RodStaging` and DB2A deliberately use **3 inspection items** and `R#####` alphas, and
**do not inherit a 4th item**. ⛔ **Do not add a connector-tag item.**

⚠ **`G14`'s check-in half is a different matter and still blocks Phase 4**: the DDL builds four
inspection columns `NOT NULL` plus `SpcM1In`/`SpcM2In`, and `POST /checkin/rod` supplies none,
so **every check-in insert fails as specified** (`REVIEW.md` Tier 1 #5). **That is
[`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md)'s problem, not this story's** — but the
two must not disagree about how many items there are.

### 2.5 The state change is raised, not broadcast

`FW-160` owns `PayoffStateChanged`. This story **raises `BayStateChanged`** as a domain event
(`FW-208`'s lane) so the broadcast happens without a handler here touching SignalR (`P-35`,
`P-101`).

⚠ **A failed weld changes no bay state and broadcasts nothing** (`FW-160` AC 2) — so the
handler must not raise the event on a failure path.

---

## 3. Build order

1. **Resolve §2.3 first** — has ledger wave W5 been applied, and does `MarkStagedRodWeldedCommand`
   survive its endpoint's retirement? Both change what gets built.
2. `StageRodCommand` + handler. **3-item `InspectionDto`** (`G14`, §2.4).
3. **Let the index enforce the conflict** (§2.1) — no pre-read. Confirm `FW-146` maps
   `DbUpdateException` on `UX_RodStaging_Bay` to **`409`**.
   ⛔ **Do not scope the conflict by `LineId`** — the station is shared (`G21`).
4. **The `Fail` path**: commit the row, return **`201`**, `state: "Blocked"`, WIP-rejection
   route, **no override** (§2.2).
5. `UnstageRodCommand` + handler → writes `RodCheckout` with `Mode='ModeP'`.
6. `PRC007`: prior footage without acknowledgement → **`422`**.
   ⚠ **Shape rules are FluentValidation's `400`; state rules are the aggregate's `422`**
   (`[SVC §3.2a]`) — this is a state rule.
7. The two queries — `GET /payoff/status`, `GET /staging/queue`.
   ⚠ **FL2 has no payoff bays**; agree with [`FW-154`](FW-154-Lines-Status-And-LineStatusService.md)'s
   `P-182` — *not applicable* is not *unoccupied*.
8. **Raise `BayStateChanged`** on stage, unstage, a **passing** weld and check-in consumption —
   never on a failure (§2.5).

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-182` precede this story.

### `P-183` — the bay conflict is never scoped by line

§2.1. `G21`'s fix is that FL1 and FL3 **share** `FL1PO`, and `UX_RodStaging_Bay` is keyed on the
station. A handler that filters by `LineId` before writing would find the bay free for FL3 while
a FL1 rod occupies it — **the exact defect, with the index still in place and satisfied.**

### `P-184` — no branch says "staged" without saying what it means about welded and blocked

§2.2. `Blocked` is derived from `Status='Staged'` plus a `Fail`, and `IsWelded` is a flag on a
`Staged` row. **Every predicate over `Status='Staged'` must state explicitly whether it includes
welded and blocked rows.** `BayStateChanged` already carries all three separately (`P-139`); the
handlers must preserve that.

### `P-185` — `MarkStagedRodWeldedCommand`'s fate is decided before the story starts

§2.3. AC 2 requires the command and AC 7 retires its endpoint. **Either it is invoked from
`POST /weldevent`'s Phase-6 handler, or it does not exist** — and building it with no caller
would be a third silent no-op of the class `FW-208` found three times.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **De-stub only** | Routes unchanged — `git diff` adds commands and handlers, **not a controller** |
| **`409` from the index** | Two concurrent stages on one bay → **one `201`, one `409`**. ⛔ Verify by **removing** any application-level pre-read and confirming the behaviour is unchanged |
| **Shared station** | Staging on FL3 while a FL1 rod occupies `FL1PO` → **`409`** (`P-183`, `G21`) |
| **`Fail` → `201`** | The row **is committed**, `state: "Blocked"`, WIP route returned, **no override** (§2.2) |
| **`Blocked` derived** | No fourth `Status` value exists in the data. `Blocked` = `Staged` + a `Fail` |
| **Welded ≠ a status** | `IsWelded` is a flag on a `Staged` row; every "staged" predicate states its intent (`P-184`) |
| Inspection | **3 items**, no connector tag (`G14`) |
| FL2 | Per the **applied** ledger state, not the card's withdrawn `422` (§2.3) |
| `PRC007` | Prior footage without acknowledgement → **`422`**, from the aggregate |
| Unstage | Writes `RodCheckout` with `Mode='ModeP'` |
| Event | `BayStateChanged` raised on stage/unstage/passing-weld/consumption; ⛔ **nothing on a failed weld** |
| Queries | FL2 reported *not applicable*, not *unoccupied* — agrees with `FW-154` (`P-182`) |

---

## 6. Handoff

`FW-160` broadcasts `PayoffStateChanged` from the `BayStateChanged` this story raises.
[`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) consumes a staged row — ⚠ **and carries
`G14`'s check-in half, which still blocks Phase 4**.
[`FW-174`](FW-174-WipRejection-And-Checkout-Services.md) releases a blocked bay in Phase 7
(`OQ-23`'s cross-phase link). `POST /weldevent` in Phase 6 is where DB2A's weld actually posts —
and where `MarkStagedRodWeldedCommand` lives, if it lives (`P-185`).

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **Ledger wave W5** | The FL2 endpoint change is **documented and not executed**. Check before building the FL2 branch |
| ⛔ **`P-185`** | AC 2 requires `MarkStagedRodWeldedCommand`; AC 7 retires its endpoint. **Same card, both** |
| **`G21`** | ✅ Fixed — FL1/FL3 share `FL1PO`. ⚠ **The conflict must not be line-scoped** (`P-183`) |
| **`G22`** | Listed blocker on the card |
| **`OQ-23`** | WIP rejection releasing a blocked bay — the Phase-7 cross-link |
| **`G14`** | 3 items here. ⚠ **Its check-in half still blocks Phase 4** and is `FW-157`'s |
| **`FR-031` / `FR-533`** | The 20 Aug reversal — FL2 pre-check-in is **accepted** |
