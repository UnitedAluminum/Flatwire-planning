# FW-233 · A host for the `/rod/**` surface

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⛔ **Blocked on `P-54`, which is `open`.** The decision is `[API]`'s and may cancel the build
**Owner:** Backend (.NET) stream
**Audience:** The developer building `FW-233`, and `[API]`'s owner deciding `P-54`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Six hours, and **four details decide whether it is right —
> starting with whether it should be built at all.**
>
> **`P-53` was right and left a hole.** *"The service hosts no `/rod/**` surface"* — rod
> receiving is not shopfloor. But `[API §4.3]` and `[API §4.20]` **remain specified with nowhere
> to go**, so four requirements have no reachable endpoint.
> **This story may close with no build.** If `[API]` re-specifies instead of re-homing, the
> hours are released (AC 5). **That is a legitimate outcome, not a failure.**
> **`[TRP]`'s DB2 scans a rod**, so this reaches the trial, not only the contract.
> **`CoilCheckin` covers only the shared-schema half** — it is not the fallback it looks like.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-233 · A host for the `/rod/**` surface
> **Hours:** 6 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE
>
> > `P-53` withdrew `RodReceivingController` on 25 Aug 2026 — *"the service hosts no `/rod/**`
> > surface"*, rod receiving not being shopfloor — and the withdrawal was right. What it left behind
> > is not: **`[API §4.3]` and `[API §4.20]` remain specified with nowhere to go**, so `FR-042`,
> > `FR-064`, `FR-043`'s carry-forward gate and `Q24`'s station switching have **no endpoint**, and
> > `CoilCheckin`'s `getCheckinCoilInfo` covers only the shared-schema half. `[TRP]`'s DB2 is a trial
> > screen that **scans a rod**.
> >
> > ⚠ **Shell and route wiring only.** `[API §4.20]`'s order set is `FW-226`'s and the check-in reads
> > are their owning stories'. `P-54` names three options and the choice — **re-home or re-specify**
> > — is `[API]`'s, not a plan's.
>
> **Acceptance Criteria:**
> - [ ] `[API]` records the `P-54` outcome first: re-home to a controller, fold into an existing one, or re-specify the two sections away
> - [ ] If re-homed: a controller shell + routes for `[API §4.3]` and `[API §4.20]`, `FlatWireResult<T>`, `[Authorize]`, `401` unauthenticated — **no handler bodies**
> - [ ] `FR-042`, `FR-064`, `FR-043`'s carry-forward gate and `Q24`'s station switching each name a reachable endpoint, or `[API]` records why they do not need one
> - [ ] `[API §3.1]`/`§3.2` updated to match, and the endpoint count restated **there**
> - [ ] ⚠ If `[API]` re-specifies instead, this story closes as a **specification change with no build** and its hours are released
>
> **Rate-card basis:** 1 controller shell **3 h** (`FW-138` §8 basis, as `FW-232`) + route wiring for 3 endpoints ≈ **3 h** = **6 h**. ⚠ **No `[CE §2]` endpoint unit is priced here** — the bodies belong to `FW-226` and the check-in stories
> **Dependencies:** FW-138, FW-N04, **FW-226** *(order set)*
> **Blockers:** ⛔ **`P-54` is `open`** and this is blocked on `[API]`, not on code. It also reaches `[TRP]` — DB2 scans a rod

### 1.1 Out of scope

| Concern | Story |
|---|---|
| `[API §4.20]`'s **order set** bodies | ⛔ **`FW-226`, already costed** |
| The check-in reads' bodies | [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) and the staging stories |
| The `/order/**` host | [`FW-232`](FW-232-OrderController-Shell.md) — sibling finding, same `[API]` owner |
| Rod ingestion into `FlatWireDB` | [`FW-223`](FW-223-Rod-Ingestion.md) — `sp_IngestRodFromCoils`, a **different** mechanism |
| Rod ↔ order entities | [`FW-240`](FW-240-RodOrder-Domain-Entities.md) |

### 1.2 What already exists

Read off the built code on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| Controller folders | `FlatWire.API/Controllers/` — fourteen | ⛔ **No `RodReceiving`, and no `Rod`** — `P-53` withdrew it and it was never built |
| `PayoffStagingController` | `Controllers/PayoffStaging/` | ✅ Built — ⚠ **the most likely re-home target** (§2.2) |
| `CheckInController` | `Controllers/CheckIn/` | ✅ Built — the other candidate |
| `IPayoffStagingService` + stub + shell | `FlatWire.Domain/Services/`, `FlatWire.Infrastructure/Services/` | ✅ Built (`FW-140`) |
| `CoilCheckin`'s `getCheckinCoilInfo` | the **shared** service, not this one | ⚠ Covers **only the shared-schema half** — not a substitute (§2.4) |
| `[API §4.3]`, `[API §4.20]` | `Backend/APIs.md` | ⛔ **Specified, with no owning controller** |

**Nothing in this card is cancelled by `D-31`/`D-32`.** ⚠ But `D-32` **did** change what rod
receiving writes — `INFLAT` is now `FlatWireDB`-local only — so any rod endpoint reads local
state (`FR-044`) rather than the shared vocabulary.

---

## 2. The four details

### 2.1 The decision comes first, and it may cancel the build

AC 1 puts `[API]`'s decision **before** any code, and AC 5 says the story may close as *"a
specification change with no build"*. `P-54` names three options:

| Option | Consequence |
|---|---|
| **Re-home** to a new controller | A sixteenth base URL — the same 1A freeze pressure as `FW-232` |
| **Fold** into an existing controller | No new base URL. ⚠ **`PayoffStaging` or `CheckIn`** (§2.2) |
| **Re-specify** the two sections away | ⛔ Then `FR-042`, `FR-064`, `FR-043`'s gate and `Q24` need another home, or `[API]` records why they need none |

⚠ **Do not start with option 1 because it is the tidiest.** `P-53`'s reasoning — rod receiving
is not shopfloor — argues *against* a dedicated rod controller in a shopfloor service, and
option 2 respects it while still giving the four requirements an endpoint.

### 2.2 If it folds, `PayoffStaging` is the better host

Both `CheckInController` and `PayoffStagingController` exist. The rod reads in question serve
**DB2A pre-check-in** — scanning a rod, its carry-forward gate, station switching — which is
staging, not check-in. `RodStaging` is the staging table and `IPayoffStagingService` already
exists.

⚠ **`CheckIn` is the wrong host**: check-in is the *commit*, and these reads happen before it.
Putting them there would make the controller answer for two lifecycle stages.

### 2.3 Four requirements, and they are not equivalent

| Requirement | What it needs |
|---|---|
| `FR-042` | Rod lookup on scan |
| `FR-064` | *(reads with `FR-042`)* |
| **`FR-043`'s carry-forward gate** | ⚠ Its rules live in `RodPreCheckin.md` §7 / `RodCheckout.md` §7.2, and it is tested by `TC-050`/`TC-051`. **`Q12` is still open** on whether a payoff-side scale exists |
| **`Q24`'s station switching** | ⚠ Open question, and it interacts with `G21` — FL1 and FL3 **share** `FL1PO` |

⛔ **`G21`'s bay-uniqueness fix constrains station switching.** `STATION_BY_LINE = {FL1:"FL1PO",
FL3:"FL1PO"}`, so "switch station" cannot mean "move to the FL3 payoff" — there is not one.
**Whatever endpoint serves `Q24` must not imply a third bay.**

### 2.4 `CoilCheckin` is not the fallback it looks like

`CoilCheckin`'s `getCheckinCoilInfo` covers the **shared-schema half** — the `coils` row. It
does **not** carry `RodStaging`'s bay state, the three inspection results, `IsWelded`, or
`Rod.FootageRunToDate` / `RemainingWeightEstimateLb`, all of which are `FlatWireDB`-local.

⚠ **After `D-32` this gets worse, not better**: nothing in the shared schema now marks a rod as
being on a flattening line (`OI-111`), so the shared half answers less than it used to.

---

## 3. Build order

1. ⛔ **`[API]` records the `P-54` outcome** (AC 1). **Nothing below starts first**, and options 2
   and 3 change or delete most of it.
2. **If re-specified:** update `[API §4.3]`/`§4.20`, give the four requirements a home or a
   recorded reason (AC 3), and **close this story with its hours released.** Record it in
   `[TB §7]` as a specification change.
3. **If folded** (§2.2): routes added to `PayoffStagingController`, no new base URL, no new
   service interface — `IPayoffStagingService` already exists.
4. **If re-homed:** a controller shell as `FW-232` §3 does it, and **the 1A base-URL freeze
   applies to this one too.**
5. Either build path: `FlatWireResult<T>` (`P-56`), `[Authorize]` inherited, `401`
   unauthenticated, **no handler bodies** — shells throwing named for their owning story
   (`P-64`, `P-169`).
6. Request/response types in `FlatWire.Domain/Models/` per `P-52`.
7. **`[API §3.1]`/`§3.2` updated, and the endpoint count restated there** — not here.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-169` precede this story.

### `P-170` — if it folds, it folds into `PayoffStaging`, not `CheckIn`

§2.2. These reads serve pre-check-in staging; check-in is the commit that follows. `RodStaging`
is the staging table and `IPayoffStagingService` already exists, so folding costs no new
service.

⚠ **This is a recommendation into `P-54`, not a substitute for it.** The re-home / fold /
re-specify choice stays `[API]`'s.

### `P-171` — whatever serves `Q24` must not imply a third payoff bay

§2.3. `G21` was fixed on 15 Aug 2026 by FL1 and FL3 **sharing** `FL1PO`, and an endpoint shaped
as *"switch this rod to line FL3's station"* re-opens it at the contract level even with the
index intact.

**Fallback:** if station switching genuinely needs to name a station, it names `FL1PO` for both
lines and the **line** is the varying parameter — never the station.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **Decision recorded first** | `[API]` carries the `P-54` outcome **before** any code (AC 1) |
| Four requirements | `FR-042`, `FR-064`, `FR-043`'s gate and `Q24` each name a **reachable** endpoint, or `[API]` records why not (AC 3) |
| If built: `401` | Unauthenticated → `401`, like every other endpoint |
| If built: envelope | `FlatWireResult<T>` (`P-56`) |
| If built: **no bodies** | Shells throwing, named for their owning story (`P-64`) |
| **No third bay** | Nothing in the contract implies an `FL3PO` (`P-171`, `G21`) |
| `[API]` updated | `§3.1`/`§3.2` match, and **the count is restated there** |
| **No count here** | This plan states no endpoint count |
| If re-specified | The story closes with **hours released**, recorded in `[TB §7]` (AC 5) |
| Regression | The 14 controllers and 22 endpoints unchanged; 61/61 still pass |

---

## 6. Handoff

`FW-226` owns `[API §4.20]`'s order set bodies; [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md)
and the staging stories own the check-in reads. [`FW-232`](FW-232-OrderController-Shell.md) is
the sibling finding — **that one's blocker is merely unactioned; this one's `P-54` is `open`**,
which makes this the harder of the two. `[TRP]`'s DB2 scans a rod, so a re-specify outcome
reaches the trial plan and not only the contract.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`P-54`** | `open`. **The story is blocked on `[API]`, not on code**, and may close with no build |
| **`P-53`** | Withdrew `RodReceivingController` — correct, and the cause of this hole |
| **`Q12`** | Still open — whether a payoff-side scale exists. Bears on `FR-043`'s carry-forward gate |
| **`Q24`** | Station switching. ⚠ Constrained by `G21` (`P-171`) |
| **`G21`** | ✅ Fixed 15 Aug 2026 — FL1 and FL3 share `FL1PO`. **No third bay may be implied** |
| **`OI-111`** | ➕ Raised by `D-32` — nothing in the shared schema marks a rod as on a flattening line, so `CoilCheckin` answers **less** than it did (§2.4) |
| **§8.1 finding 4** | ✅ **This story closes it**, whichever way `P-54` goes |
