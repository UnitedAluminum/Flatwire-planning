---
id: FW-N06
legacy_id:
title: Alert rules engine and the AlertRaised/AlertCleared lifecycle
status: not-started
status_confirmed: false
status_note: "⚠ **Four of five rules buildable; rule 5 cannot be evaluated until Phase 4.** `OI-28` open"
owner:
jira:
mvp: 1
phase: "3"
stream: RT
streams: [RT]
priority: high
hours: 40
sprint: S1
depends_on: [FW-149, FW-150]
blocked_by: [OI-28]
has_plan: true
started:
completed:
---
# FW-N06 · Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Four of five rules buildable; rule 5 cannot be evaluated until Phase 4.** `OI-28` open
**Owner:** Backend (.NET) / real-time stream
**Audience:** The developer building `FW-N06`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Forty hours — **the largest story in Phase 3** — and **four
> details decide whether it is right.**
>
> **Phase 4 back-feeds Phase 3.** Rule 5 reads `RodStaging`, which Phase 4 delivers, so **the
> largest story in this phase cannot finish inside it.** That is stated on the card and is easy
> to discover late.
> **⛔ A weight of zero is not an empty bay.** AC 3 exists because `PayoffWeight` alone
> **cannot** distinguish an unloaded payoff from a sensor reading zero. Rule 5 reads
> `RodStaging` occupancy — and a rule that reads the weight instead is *plausible, wrong, and
> fires on a healthy line.*
> **`AlertRaised` already has a consumer and no producer.** `FW-150` records that the fault bit
> has **no channel** — *"it is `AlertRaised`, `FW-177`'s, and unwired"*. This story is the
> producer.
> **Unbatched, for the same correctness reason as `FW-160`** — a rare event riding the
> newest-wins telemetry batch can be dropped outright.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-N06 · Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle
> **Hours:** 40 h RT · **Priority:** High · **Sprint:** S1 · **Phase:** 3 · **Stream:** RT
>
> **As a** supervisor,
> **I want** the system to raise and clear alerts on defined thresholds,
> **So that** a developing problem reaches me before it stops the line.
>
> **Acceptance Criteria:**
> - [ ] Five rules implemented: Payoff1 < 3,000 lb → **Warning** · gauge outside ±tolerance → **Warning** · component fault → **Critical** · active WIP rejection → **Warning** · **Payoff2 not loaded AND Payoff1 < 2,000 lb → Critical**
> - [ ] `AlertRaised` and `AlertCleared` broadcast as **rare domain events — immediate and unbatched**, never inside the 10 Hz telemetry batch
> - [ ] **"Payoff2 not loaded" reads `RodStaging`** — a `Staged` row on `(LineId, PayoffPosition)` means loaded. `PayoffWeight` alone **cannot** distinguish an empty bay from a sensor reading zero
> - [ ] Consumes `PayoffStateChanged` (Phase 4) to keep the evaluation live
> - [ ] Unit tests cover each threshold's raise and clear edges
>
> **Rate-card basis:** 5 × hub event / rule @ 8 h = 40 h (§2)
> **Dependencies:** FW-149, FW-150
> **Blockers:** **⚠ Until Phase 4 delivers `RodStaging`, rule 5 cannot be evaluated at all** — nothing else records bay occupancy. Phase 4 back-feeds this phase · **OI-28** (alerts unbacked)

### 1.1 Out of scope

| Concern | Story |
|---|---|
| Exception broadcasts and supervisor notification | [`FW-177`](FW-177.md), Phase 7 — ⚠ **it consumes `AlertRaised`** |
| The telemetry loop | [`FW-150`](FW-150.md) — built, and ⛔ these events stay out of its batch |
| `PayoffStateChanged` itself | `FW-160`, Phase 4 — this story **consumes** it |
| Bay occupancy writes | [`FW-158`](FW-158.md), Phase 4 |
| Reading alerts for page load | [`FW-154`](FW-154.md)'s `ActiveAlertDto` |
| The `ITInhibit` interlock | [`FW-205`](FW-205.md) — ⚠ **a different mechanism**; do not conflate (§2.4) |

### 1.2 What already exists

Read off the built code on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| `AlertRaised` / `AlertCleared` hub members | `FlatWire.Domain/IFlatWireClient.cs` | ✅ **Built** — part of the 20 members `FW-149` verified |
| `AlertSeverity` enum | `FlatWire.Domain/Enums/CanonicalEnums.cs` | ✅ Built — ⚠ **`G56`: it has no DB leg**, so `TC-020` verified it on one side only |
| `AlertTypes.DataRecording` | added by `FW-205` | ✅ Built — ⚠ **one alert type exists; this story adds the rest** |
| `IFlatWireBroadcaster` | `FlatWire.Domain/Services/` | ✅ Built — handlers inject this, never `IHubContext<>` (`P-101`) |
| `FW-150`'s reading channel + per-run cache | built | ✅ Built — ⚠ carries `InSpec`'s band **cached per run** (`P-125`) |
| The fault bit | ⛔ **has no channel** — `FW-150` records it as *"`AlertRaised`, `FW-177`'s, and unwired"* | **This story is the producer** |
| **A rules engine** | — | ⛔ **Does not exist** |
| `RodStaging` | table + aggregate ✅ built; **the staging writes** are `FW-158`'s (Phase 4) | ⚠ Rule 5's data source (§2.1) |
| `WipRejection` | table + aggregate ✅ built; the service is `FW-174`'s (Phase 7) | ⚠ Rule 4's source |

⚠ **Two of the five rules read state whose *writer* is in a later phase** — rule 4
(`WipRejection`, Phase 7) and rule 5 (`RodStaging` staging writes, Phase 4). **The tables exist;
nothing populates them yet.**

---

## 2. The four details

### 2.1 Phase 4 back-feeds Phase 3, and rule 5 is the reason

The card says it outright: *"Until Phase 4 delivers `RodStaging`, rule 5 cannot be evaluated at
all — nothing else records bay occupancy."*

⚠ **So the largest story in Phase 3 cannot complete inside Phase 3.** Options:

- ⛔ **Wait for Phase 4** — holds 32 h of buildable work behind 8 h of blocked work.
- ✅ **Build four rules now, rule 5 when its producer lands**, recording the partial state
  explicitly.

**Take the second**, the same shape as [`FW-206`](FW-206.md)'s `P-179`.
⚠ **And record it** — *"four of five rules"* is defensible; *"we thought all five were on"* is
not, and an alert engine that silently omits its only **Critical** bay rule is exactly the
failure this story exists to prevent.

### 2.2 ⛔ Zero pounds is not an empty bay

AC 3 is the most important line on the card. `PayoffWeight` **cannot** distinguish:

| Reality | `PayoffWeight` |
|---|---|
| Bay empty, no rod loaded | `0` (or null) |
| Rod loaded, sensor faulty or reading zero | `0` |
| Rod loaded and nearly consumed | `~0` |

**A `Staged` row on `(LineId, PayoffPosition)` means loaded.** That is the only sound source.

⚠ **And `Staged` is subtler than it looks**: `Blocked` is **derived** (`Status='Staged'` + a
`Fail`), and `IsWelded` is a **flag on a `Staged` row**. So *"is the bay loaded"* is true for
staged, welded **and** blocked rows — a blocked rod is still physically on the bay, which is why
`FW-158` commits it. ⛔ **A rule reading `Status='Staged'` without saying so excludes welded and
blocked rods and fires "Payoff2 not loaded" on a loaded bay** (`P-184`).

⛔ **`G21`: FL1 and FL3 share `FL1PO`.** Rule 5 must not evaluate the shared bay twice, nor
report FL3's payoff as unloaded because it queried by line.

### 2.3 Unbatched, and the reason is delivery, not latency

Same as `FW-160` §2.2: `FW-150`'s loop is **decimated and newest-wins** for scalars, and sends
**nothing on an empty tick**. A raise/clear pair routed through it could be **collapsed to one**
or dropped entirely.

⚠ **Raise and clear are a pair, and losing the clear is worse than losing the raise** — a stuck
alert trains supervisors to ignore the panel.

### 2.4 This is not the interlock, and the difference is directional

`FW-205`'s `ITInhibitService` also evaluates conditions and also reacts to missing data. **They
are different mechanisms and must not be merged:**

| | `ITInhibit` (`FW-205`) | Alerts (this story) |
|---|---|---|
| Effect | **Writes a PLC tag** — stops the line | **Broadcasts to a screen** — informs a supervisor |
| Audience | The controller | The supervisor |
| Failure of the mechanism | Line runs unguarded | Supervisor is uninformed |

⛔ **`P-132`'s lesson transfers**: do not let this engine re-derive the interlock's arming rule
or write its tag. A component fault raising a **Critical** alert here is correct; that same
fault **must not** also be evaluated into `ITInhibit` from this code.

---

## 3. Build order

1. **Decide the partial delivery** (§2.1) and record it — four rules now, rule 5 with Phase 4.
2. **The engine**: an evaluator over the reading stream and the state tables, with an
   `AlertRaised`/`AlertCleared` **lifecycle** — the clear edge is half the work and half the
   acceptance (AC 5).
   ⚠ **Hold raised-alert state**, or every evaluation re-raises. Keyed on
   `(LineId, AlertType[, Position])`.
3. **Rule 1** — Payoff1 < 3,000 lb → Warning.
4. **Rule 2** — gauge outside ±tolerance → Warning. ⚠ **Reuse `FW-150`'s per-run cached band**
   (`P-125`); do not re-query per reading. ⛔ **And `Q22` leaves the band unseeded**, so this is
   built and unexercised, like [`FW-245`](../../30-database/tasks/FW-245.md).
5. **Rule 3** — component fault → Critical. **This is the fault bit's missing channel** (§1.2).
6. **Rule 4** — active WIP rejection → Warning. ⚠ Nothing writes `WipRejection` until Phase 7.
7. **Rule 5** — deferred (§2.1). When built: `RodStaging` occupancy, **including welded and
   blocked rows** (§2.2), **not** `PayoffWeight`, and **not** line-scoped on `FL1PO` (`G21`).
8. **Unbatched send** through `IFlatWireBroadcaster` (§2.3) — ⛔ never through `FW-150`'s batch.
9. Consume `PayoffStateChanged` (AC 4) to keep rule 5 live once `FW-160` lands.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-187` precede this story.

### `P-188` — four rules ship in Phase 3; rule 5 lands with its producer

§2.1, the shape `P-179` uses for `FW-206`. Holding 32 h of buildable work behind an 8 h
cross-phase dependency helps nobody.

⚠ **Record the partial state on the build.** An alert engine missing its only **Critical** bay
rule, believed complete, is worse than one known to be four-fifths done.

### `P-189` — occupancy is read from `RodStaging`, and the predicate names welded and blocked explicitly

§2.2, applying `P-184`. A rule written as `Status='Staged'` silently excludes welded and blocked
rods and raises *"Payoff2 not loaded"* on a bay with a rod physically on it.

**Fallback:** none. `PayoffWeight` is not an acceptable substitute at any threshold — AC 3 is
explicit, and the sensor-reads-zero case is indistinguishable.

### `P-190` — the alert engine never writes a PLC tag

§2.4. Alerts inform; the interlock acts. A component fault legitimately does both, but through
**two mechanisms with two owners**, and this engine owns only the broadcast (`P-132`'s lesson,
transferred).

---

## 5. Verification

**No automated tests for the service layer** — `[TS §1.2]`. ⚠ **AC 5 asks for unit tests on the
threshold edges**, which is the one place the card asks for more than the standing position;
raise it rather than silently dropping it.

| Check | Expected |
|---|---|
| Raise edge | Each rule fires **once** as its threshold is crossed — not on every evaluation |
| **Clear edge** | Each rule clears when the condition ends. ⛔ **A stuck alert is the primary failure** |
| **Unbatched** | Raise and clear both arrive immediately; **a raise/clear pair inside one 100 ms window is not collapsed** (§2.3) |
| Rule 1 | Payoff1 < 3,000 lb → Warning |
| Rule 2 | Gauge outside band → Warning. ⚠ Uses the **cached** band (`P-125`); ⛔ **unexercised while `Q22` is open** |
| Rule 3 | Component fault → Critical — **the fault bit now has a channel** |
| Rule 4 | Active WIP rejection → Warning (inert until Phase 7) |
| **Rule 5, when built** | Reads `RodStaging`; **a loaded bay with a zero weight raises nothing** (`P-189`) |
| **Welded / blocked** | A welded or blocked rod counts as **loaded** (`P-189`, `P-184`) |
| **Shared bay** | `FL1PO` evaluated once for FL1 and FL3, not twice (`G21`) |
| **No tag write** | `grep` finds no PLC write in this engine (`P-190`) |
| Partial state | The build records **four of five** (`P-188`) |

---

## 6. Handoff

[`FW-177`](FW-177.md) (Phase 7) consumes `AlertRaised` for supervisor
notification — ⚠ **and `FW-175` is deferred, so that notification is transient.**
[`FW-154`](FW-154.md)'s `ActiveAlertDto` reads the current
alert set for page load and must return an empty list until this story lands. `FW-160` supplies
`PayoffStateChanged`; [`FW-158`](FW-158.md) writes the
occupancy rule 5 reads.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⚠ **`OI-28`** | Alerts unbacked — the card's listed blocker |
| ⚠ **Phase 4 back-feed** | Rule 5's producer is in a later phase (`P-188`) |
| ⛔ **`Q22`** | The tolerance band is unseeded, so rule 2 ships **correct and unexercised** |
| **`G56`** | `AlertSeverity` has **no DB leg**, so `TC-020` verified it on one side only |
| **`G21`** | FL1 and FL3 share `FL1PO` — one bay, evaluated once |
| **`P-184`** | Every "staged" predicate must state its intent about welded and blocked rows |
| **AC 5's unit tests** | ⚠ Against `[TS §1.2]`'s *no automated backend tests*. **Raise it; do not silently drop it** |
