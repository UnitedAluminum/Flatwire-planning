# FW-179 · `POST /checkin/spool` and `GET /spools`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — ⚠ **`[API §4.6a]`'s worked example uses the wrong fixture (§2.3)**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-179`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Three traps, and the third is in the contract itself.
>
> **`404` only for an unknown alpha.** An *unallocated* spool is a **`200` with a null
> order** — `[TB §7]` calls conflating the two *"the mistake to avoid"*, and it is the natural
> mistake because both feel like "not found".
> **FL2 tags only.** The push writes `S1`/`S2`/`S3` roll gaps and stand states plus edgers at
> **S2 and S3** — **no DB or FM1 tags**. FL2 is fed an already-flattened spool; FL1's drawing
> blocks and 12″ mill are not in that material path.
> **And `[API §4.6a]`'s worked example is stale** — it checks in against a schedule the
> contract must refuse **twice over**.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-179 · `POST /checkin/spool` and `GET /spools`
> **Hours:** 18 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** BE
>
> **As a** client developer,
> **I want** one spool endpoint serving both queue modes,
> **So that** a scan resolves the order in a single call.
>
> **Acceptance Criteria:**
> - [ ] `CheckInController POST /checkin/spool`; `CheckInSpoolCommand` (spoolAlpha, measured gauge/width, weights, passScheduleId) → run response
> - [ ] **`SpoolController GET /spools[?spoolAlpha=]` — one endpoint, two modes, identical response shape `{ order, spools[] }`.** Without the parameter it returns everything available for processing with a null order; with it, **the backend resolves the order** and returns it plus that order's spools in the same response
> - [ ] **`404` only for an unknown alpha. An unallocated spool is a `200` with a null order** — conflating the two is the mistake to avoid
> - [ ] DTO joins `CoilTraceability` / `WeldEvent` for source rods, the FL1 run for gauge/width, and the **shared order schema cross-database** for the order block
> - [ ] `CheckInService` spool path pushes **FL2 tags only** — `S1`/`S2`/`S3` roll gaps and stand states plus edgers at S2/S3. **No DB or FM1 tags**
> - [ ] Hybrid-origin validation guard
> - [ ] Operator+ authorization
>
> **Rate-card basis:** command endpoint 6 h + query endpoint 4 h + `CheckInService` spool path 8 h = 18 h (§2)
> **Dependencies:** FW-139, FW-151, FW-180
> **Blockers:** **`Q15`** · **`Q17`**

### 1.1 Out of scope

| Concern | Story |
|---|---|
| `SpoolCheckin` table + the `Spool.OrderNo` index | `FW-180`, DB |
| DB5 / DB5A screens | `FW-178`, FE · `FW-124` deferred |
| The `Spool` row this reads | `FW-202` — ⚠ **must land first** (§4) |
| `PLCTagService` | [`FW-151`](FW-151-PLCTagService.md) |
| The rod-side twin | [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) |

---

## 2. The three traps

### 2.1 One endpoint, two modes, one shape

`GET /spools[?spoolAlpha=]` returns **`{ order, spools[] }`** either way:

| Call | Returns |
|---|---|
| `GET /spools` | everything available for processing, **`order: null`** |
| `GET /spools?spoolAlpha=SP-00021` | **the backend resolves that spool's order**, and returns it with that order's spools |

**One round trip** — the scan resolves the order without a second call.

⚠ **`404` only for an unknown alpha.** An unallocated spool is `200` with a null order.

⚠ Two shape traps from `[API §4.6b]`: `gaugeIn`/`widthIn` come from **the source FL1 run**,
because `Spool.GaugeIn`/`WidthIn` are set at check-in and are **null for every row this
returns**; and `sourceRodAlphas` is a **list** from `CoilTraceability`/`WeldEvent`, because
`Spool` holds only two single-valued rod FKs — **`G42`**, which has no child table.

### 2.2 FL2 tags only

The spool path pushes `S1`/`S2`/`S3` roll gaps and stand states, plus **edgers at S2 and S3
only**. **No DB or FM1 tags.**

> **FM2 has three stands** — `FM2_S1` (8″) → `FM2_S2` (6″) → `FM2_S3` (6″, **non-bypassable**)
> — and roll diameter is data in `Stand.RollDiameterIn`. **Anything showing four stands, a
> separate `8" Roller`, or a 6″ stand named S1 is stale** (`D-26`). `TC-115` asserts exactly
> three rows.

⚠ **`G41`: `CK_PSC_FM1NotBypassable` is line-blind**, so every FL2 schedule must mark `FM1`
**Active** — engaging a stand FL2 does not have. **Today it is inert** because the trial's FL2
row is pass-through; **it stops being inert the moment anything reads component state to
decide what to write**, which is this story. See [`FW-207`](FW-207-Domain-Model.md).

### 2.3 ⚠ The contract's own worked example is wrong

`[API §4.6a]` shows `POST /checkin/spool` with `"passScheduleId": "PS-1100-FL2-001"` in the
request **and** in a `"success": true` response.

**That check-in must be refused twice over:**

| Ground | Result |
|---|---|
| `PS-1100-FL2-001` is **`Inactive`** | `SCHEDULE_NOT_ACTIVE` → **422** |
| It is **`Hybrid`**, against a Standalone-origin spool | **`FR-091`** route-mode validation |

**The FL2 happy path is `PS-1100-FL2-002`** — Standalone, Active — added by **`G40`** on
15 Aug 2026, `-001` demoted to `Inactive` because
`UX_PassSchedule_OneActivePerLineAlloy` permits one Active per line + alloy.
**Build to `PS-1100-FL2-002`; do not copy the example.**

---

## 3. The hybrid-origin guard is undefined, not merely open

AC 6 requires it. `FR-091` has DB5 validate the schedule's route mode against the **spool's
origin route mode**.

⚠ **`Q15`/`OI-47`: the behaviour is *undefined*.** `TC-118` is **P1** and its expected result
reads *"Behaviour undefined — `OI-47`. Records observed behaviour; gate fails until
specified."*

**The trial does not walk into it** — `PS-1100-FL2-002` is Standalone-origin against a
Standalone schedule — **but Phase 8 does, and `[TRP §6]` says it must be specified before
Phase 8 ships for real.**

**Build the guard's *hook* and record observed behaviour. Do not invent the rule.**

---

## 4. Build order

1. `SpoolController GET /spools` — endpoint **16a** — on
   [`FW-138`](FW-138-Fifteen-Thin-Controllers.md)'s shell. One shape, two modes (§2.1).
2. `CheckInController POST /checkin/spool` — endpoint **16**.
3. `CheckInSpoolCommand`, handler nested.
4. DTO joins: `CoilTraceability`/`WeldEvent` → source rods · the FL1 run → gauge/width ·
   **cross-database** → the order block *(the same unenforced-link basis as
   [`FW-164 §2.1`](FW-164-Run-Queries-And-RunQueryService.md); reuse its view)*.
5. `CheckInService` spool path — **FL2 tags only** (§2.2), through
   [`FW-151`](FW-151-PLCTagService.md).
6. Hybrid-origin hook (§3).
7. `Operator+`; audit throughout.

> ⚠ **`FW-202` must land before Phase 8 starts, not beside it** — it writes the `Spool` row
> DB5 reads. `[TRP §3]`: *"In a five-day sprint that is a real sequencing constraint, not a
> formality."*

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-47` precede this story.

### `P-48` — `404` means the alpha does not exist, and nothing else

The distinction is the story's own named trap, so it needs to be unambiguous in code:

| Condition | Response |
|---|---|
| Alpha not in `Spool` | **`404`** |
| Alpha exists, **no order allocation** | **`200`**, `{ order: null, spools: [...] }` |
| Alpha exists, allocated | **`200`**, `{ order: {...}, spools: [...] }` |

**Resolve existence first, allocation second, and never let a failed order join produce a
`404`.** The order block is a **cross-database** read on unmapped columns (`OI-33`) — so a
join that returns nothing is the *expected* unallocated case *and* the shape of an
infrastructure failure. **Distinguish them:** a missing allocation is a null order; an
unreachable order schema is a `500`.

⚠ The availability rule — `RECEIVED` + `STAGED` — is a **proposal**; `Q27` leaves it
undefined. Record which you implement.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough and by `[TRP §8]`'s
acceptance run, steps 8–9.

| Check | Expected |
|---|---|
| Two modes, one shape | Both return `{ order, spools[] }` |
| **Unknown alpha** | **`404`** |
| **Unallocated spool** | **`200`** with `order: null` — *not* `404` |
| Order schema unreachable | `500`, not `404` *(`P-48`)* |
| `gaugeIn`/`widthIn` | From the **source FL1 run** — not from `Spool`, which is null here |
| `sourceRodAlphas` | A **list**, from `CoilTraceability`/`WeldEvent` |
| **FL2 tags only** | Diff the written set: `S1`/`S2`/`S3` + edgers at S2/S3. **No DB, no FM1** |
| Fixture | **`PS-1100-FL2-002`** succeeds; **`PS-1100-FL2-001` is refused** (§2.3) |
| Hybrid-origin | Hook present; behaviour **recorded, not asserted** (`OI-47`) |
| Authorization | Operator+ |

---

## 7. Handoff

`FW-180` (DB) supplies `SpoolCheckin` and the `Spool.OrderNo` index — *"a `WHERE OrderNo =` on
a `VARCHAR(50)` does not scan"*, and it also fixes DB5's scan, **which validates against
nothing today**. `FW-178` (FE) is DB5. `FW-124`'s DB5A queue is deferred — *"DB5's Browse
spool queue → greyed. The scan still validates — `GET /spools` ships in `FW-179`."*
[`FW-181`](FW-181-FL2-Null-Gauge-Contract.md) binds the FL2 Live/Profile view.

---

## 8. Open items

| Item | Effect here |
|---|---|
| **`Q15` / `OI-47`** *(blocker)* | The hybrid-origin guard is **undefined**; `TC-118` is P1 and *"gate fails until specified"*. **Before Phase 8 ships** |
| **`Q17`** *(blocker)* | — |
| **`G40`** | The FL2 fixture — §2.3 |
| **`G41`** | `CK_PSC_FM1NotBypassable` is line-blind; **stops being inert in this story** |
| **`G42`** | `Spool` cannot hold multi-rod genealogy — `sourceRodAlphas` is a list against a schema holding one |
| **`OI-33`** | The cross-DB order columns are unmapped |
| **`Q27`** | The availability rule (`RECEIVED` + `STAGED`) is a proposal |
| **`OI-25`** | Two footage coordinate systems, unreconciled (`FW-180`'s blocker, inherited by the DTO) |
