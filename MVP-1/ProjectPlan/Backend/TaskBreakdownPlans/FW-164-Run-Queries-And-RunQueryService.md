# FW-164 · `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **the Order block is a cross-database read on unmapped columns**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-164`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Two reads, and each carries something that is not obvious
> from its name.
>
> **`GET /run/active` is the trial's landing route.** DB1 left trial scope on 14 Aug, so
> `[TRP §1.4]` names this endpoint as what the app opens on instead of `/lines/status`. It is
> load-bearing for the trial in a way its 12 h suggests it is not.
>
> **Its DTO reaches across databases.** The Order Information block — customer, due date,
> tolerances, setup width/gauge, finish, OD min–max, weights — lives in the **shared
> order/scheduling schema**, and it is served **in one round trip** rather than a second call.
> ⚠ Those columns are **unmapped** (`OI-33`).

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-164 · `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService`
> **Hours:** 12 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 5 · **Stream:** BE
>
> **As a** client developer,
> **I want** an active-run snapshot and a paged historical trace,
> **So that** the monitor resumes correctly and FL2 can show a finished run's profile.
>
> **Acceptance Criteria:**
> - [ ] `RunController GET /run/active?line=` returns the active-run DTO (payoffs, weldEvents, components)
> - [ ] `GET /run/{runId}/gaugetrace` returns the gauge-trace DTO (readings, weldMarkers, limits), paged by `from` / `to` / `resolution` via Dapper
> - [ ] **The active-run DTO carries the Order Information fields** — customer, due date, tolerances, setup width/gauge, finish, OD min–max, weights — served in one round trip rather than a second call. These live in the **shared order/scheduling schema, cross-database**, on the same unenforced-link basis as the rod-alpha references
> - [ ] Out-of-spec detection thresholds surfaced to the client as configuration
> - [ ] Weld markers sourced from `WeldEvent`
> - [ ] Any authenticated role may read
>
> **Rate-card basis:** 2 query endpoints @ 4 h = 8 h + `RunQueryService` / Dapper paging 4 h = 12 h (§2)
> **Dependencies:** FW-138, FW-141
> **Blockers:** **`Q18`**

### 1.1 Out of scope

| Concern | Story |
|---|---|
| `sp_GetGaugeTrace` itself | `FW-165`, DB |
| The DB3 screen | `FW-062`, `FW-163`, FE |
| Live telemetry | [`FW-150`](FW-150-Broadcast-Loop.md) — **this is the historical/REST half** |
| Weld **writes** | `FW-166` — deferred with DB2A |

---

## 2. What each read owes

### 2.1 `GET /run/active?line=` — the trial's landing route

Returns payoffs, weld events, components **and the Order Information block**.

> **One round trip, deliberately.** The alternative — a second call for the order — doubles
> latency on the screen an operator opens first. `[API §4.7a]` specifies the combined shape.

⚠ **The order block is a cross-database read** on the same unenforced-link basis as rod
alphas, and **`OI-33` leaves `planning_routings`' columns unmapped**. Follow `[DBD §6.6]`'s
convention: `united_db..alloys` is surfaced as a **view** in the consuming databases, *"one
place to absorb mismatches rather than repeating them at every call site."*

### 2.2 `GET /run/{runId}/gaugetrace` — paged, via Dapper

Readings, weld markers and limits, paged by `from` / `to` / `resolution`.

- **Dapper, not EF** — `[SVC §3.3]` puts high-volume reads on Dapper, and this is the
  heaviest query in the service. Backed by **`sp_GetGaugeTrace`** (`FW-165`).
- **Weld markers come from `WeldEvent`**, not from the readings.
- ⚠ **`RunReading` is in no aggregate** ([`FW-207 §2.1`](FW-207-Domain-Model.md)) and has
  **no repository** ([`FW-141 §2.1`](FW-141-Repository-Layer.md)) — it is an append-only
  write model read by Dapper. Do not reach for a repository that does not exist.

### 2.3 Two consumers, two shapes — and FL2 is why

| Line | Live gauge | Profile |
|---|---|---|
| FL1 / FL3 | streamed | available |
| **FL2 standalone** | **`null`** — `FR-120` | **the value of record** |

`[TRP §7]` calls the FL2 empty state *"the single most likely thing to ship wrong."* This
endpoint is what makes Profile possible: on FL2 the trace is a **REST query over the
incoming spool's FL1 history**, not a live stream. See
[`FW-181`](FW-181-FL2-Null-Gauge-Contract.md).

> ⚠ **Profile must not be re-rendered or re-sampled by the live tick** — it is static.
> A paging contract that assumes a live cursor breaks that.

### 2.4 Thresholds are configuration, not code

Out-of-spec detection thresholds are **surfaced to the client as configuration**, so
Dashboard 3's N-consecutive-out-of-spec auto-prompt is tunable without a deploy. Bind them
through [`FW-144`](FW-144-Configuration-Binding.md).

---

## 3. Build order

1. `RunController` actions on [`FW-138`](FW-138-Fifteen-Thin-Controllers.md)'s shell —
   endpoints **17** and **18** of `[API §3.2]`.
2. `RunQueryService`, Dapper paging over `sp_GetGaugeTrace`.
3. The active-run DTO per `[API §4.7a]`, including the cross-DB order block (§2.1).
4. Weld markers from `WeldEvent`.
5. Thresholds from configuration (§2.4).
6. **Any authenticated role may read** — bare `[Authorize]`, no policy.
7. Pagination per `[API §1.5]` where the trace is paged —
   [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) owns the convention.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-41` precede this story.

### `P-42` — read the order block through a view, and let the DTO carry nulls

`OI-33` leaves the `planning_routings` column mapping unknown, and this DTO must carry
customer, due date, tolerances, setup width/gauge, finish, OD min–max and weights out of it.

**Resolution, in two parts.** Surface the shared-schema read as a **view in `FlatWireDB`**,
per `[DBD §6.6]`'s established convention — so when `OI-33` closes, the mapping changes in
one object rather than at every call site. And make **every order field nullable in the DTO**,
rendering as *not available* rather than blank or zero.

Reason: this is the trial's landing route. A missing order field must degrade the screen, not
fail the request — and `Q18` (which order field carries coil min–max weight) is a second,
independent unknown in the same block. **`[TRP §6]` lists `Q18` as second-tier: it stops no
build.**

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| `GET /run/active?line=` | Active-run DTO with payoffs, weld events, components **and** the order block in **one** round trip |
| No active run | Contracted empty response — not a `404`, and not an error |
| `gaugetrace` paging | `from` / `to` / `resolution` honoured; Dapper, via `sp_GetGaugeTrace` |
| Weld markers | Sourced from `WeldEvent`; **empty array is legitimate** in trial scope, where no weld is captured |
| **FL2** | Profile served from the incoming spool's FL1 history; **static** |
| Thresholds | From configuration, no rebuild |
| Authorization | Any authenticated role; anonymous → `401` |
| Order fields absent | DTO carries nulls, request still `200` *(`P-42`)* |

> ⚠ **Build the weld-marker layer even though it renders empty in the trial** (`[TRP §7]`).
> With no `WeldEvent` rows in scope the array is empty — *"a legitimate state, not a
> defect."* **Deleting the layer is rework when weld capture returns.**

---

## 6. Handoff

`FW-062` / `FW-163` (FE) render both. [`FW-181`](FW-181-FL2-Null-Gauge-Contract.md) binds the
Live/Profile toggle. `FW-165` (DB) supplies `sp_GetGaugeTrace`. `FW-204` (FE) is the minimal
landing route that calls `GET /run/active`.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`Q18`** *(blocker)* | Which order field carries coil min–max weight. Second-tier — **stops no build** |
| **`OI-33`** | `planning_routings` columns unmapped — `P-42` |
| **`G17`** | Cross-DB logical FKs, unenforced by design |
| **`G3`** | `RunReading` is the store this reads |
| **`G14`** | Footage is `DECIMAL(10,2)` on `RunReading` but `INT` on event tables — **a fractional footage does not round-trip through an event endpoint** |
