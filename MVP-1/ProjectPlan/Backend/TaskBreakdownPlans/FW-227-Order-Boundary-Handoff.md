# FW-227 · The order-boundary handoff and its notification

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⛔ **Blocked on `Q48`, `Q50`, `Q51`** — and `Q48` decides whether the handoff is universal at all
**Owner:** Backend (.NET) stream *(with an FE half)*
**Audience:** The developer building `FW-227`
**Shortcode:** — *(implementation plan, derived from `[REQ §5.28]`, `[SIG]`, the DDL and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Twenty-six hours, and **five details decide whether it is
> right.**
>
> **⛔ The close-and-open must be ONE transaction**, or `UX_RodOrderConsumption_Station` — a
> filtered unique index on the shared station — **rejects the handover itself**. The index that
> protects the invariant is the thing that breaks a two-step implementation.
> **The station is handed over, not released.** Release happens at checkout, and calling
> `FlatWire_ReleaseStation` here would free a station mid-run.
> **Crossing is detected server-side on the footage stream**, once per pairing — not by a
> client threshold check. `SpoolWeightMilestone`'s rule, and the reason is the same.
> **Two weight latches, and the difference is the overrun** — persisted, not recomputed.
> **Events 13/14 are DURABLE and re-delivered on group re-join**, following event 11's
> contract. ⚠ **Event 11 is `SpoolCompletionPromptDue`, and `[SIG §5.5]`'s `targetLb` has no
> persisted source** — read `FW-149`'s finding before copying the contract wholesale.

---

## 1. The story

From `[TB §7]` — verbatim. ⚠ **Compact `FW-225`–`FW-231` card variant.**

> ###### FW-227 · The order-boundary handoff and its notification
> **Hours:** 26 h (BE 16 · FE 10) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE + FE
>
> > The rod is checked in **once** and stays mounted across the boundary. The state machine is
> > `Pending → InProgress → ThresholdReached → Closed`, plus `Voided`.
>
> - [ ] Crossing detected **server-side on the footage stream**, once per pairing — not a client threshold check (`SpoolWeightMilestone`'s rule)
> - [ ] Hub events **13/14**, durable and re-delivered on group re-join, following event 11's contract
> - [ ] **Two weight latches** — at the crossing and at the acknowledgement. The difference is the overrun and it is persisted
> - [ ] ⚠ The close-and-open at a boundary must be **one transaction**, or `UX_RodOrderConsumption_Station` rejects the handover
> - [ ] The station is **handed over, not released**; release happens at checkout
> - [ ] `POST /order/{orderNo}/complete` — the only thing that closes an order
>
> **Blockers:** **`Q50`** (the escalation bound), **`Q51`** (the early-ack remainder)

### 1.1 Out of scope

| Concern | Story |
|---|---|
| **The endpoint's controller shell** | [`FW-232`](FW-232-OrderController-Shell.md) — 3 h, **already costed there**; this story is the handler |
| The allocation tables and invariants | [`FW-225`](FW-225-Rod-Order-Allocation-Schema-And-Domain.md) |
| Sequence validation | [`FW-226`](FW-226-Sequence-Validation-Four-Tier.md) |
| Footage-to-weight | [`FW-228`](FW-228-Footage-To-Weight-Converter.md) — supplies the latched weights |
| Station **release** | [`FW-221`](../../Database/TaskBreakdownPlans/FW-221-Station-Release-And-Reqsum-Reversal.md) — ⛔ **at checkout, not here** |
| Fulfilment rollup | `FW-229`, Phase 9 |
| The footage stream itself | [`FW-150`](FW-150-Broadcast-Loop.md) — built |

### 1.2 What already exists

Verified on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| `RodOrderConsumption` + `State` | `04_Runs.sql:733` | ✅ Built — the state machine's storage |
| **`UX_RodOrderConsumption_Station`** | `07_Indexes.sql:337` — `UNIQUE ON ([Station]) WHERE [State] IN ('InProgress','ThresholdReached')` | ✅ **Built — and it is what forces §2.1** |
| `RodOrderConsumption.RowVersion` | `04_Runs.sql:772` — *"State and footage move live"* | ✅ Built, ⛔ **unmapped** until `FW-240` |
| The footage stream | `FW-150`'s loop + `RunReading` | ✅ Built — ⚠ **the write is footage-gated at 4 ft** (`FR-018`) |
| `FW-208`'s post-commit dispatch | built | ✅ — the lane events 13/14 ride |
| Event 11 `SpoolCompletionPromptDue` | `[SIG §5.2]`, durable | ✅ Built — ⚠ **and `FW-149` found it 4-of-6 fillable** (§2.4) |
| `G38`'s five prompt columns | `FlatWireRun` `03_Materials.sql:100`–`:104` | ✅ Built — **the durability pattern to copy** |
| **`OrderController`** | — | ⛔ **Absent** — [`FW-232`](FW-232-OrderController-Shell.md) |
| **Hub events 13/14** | — | ⛔ **Absent** |

---

## 2. The five details

### 2.1 ⛔ One transaction, because the index says so

`UX_RodOrderConsumption_Station` is `UNIQUE ON ([Station]) WHERE [State] IN ('InProgress',
'ThresholdReached')`. At a boundary the outgoing pairing is `ThresholdReached` and the incoming
one must become `InProgress` — **both states are inside the filter**.

So a two-step implementation:

1. Open the new pairing → ⛔ **rejected**, two rows in the filtered set.
2. Close the old, then open the new → a window where the station has **no** active pairing, and
   any footage arriving in it belongs to nothing.

**Only one transaction works.** ⚠ **And note the index is keyed on `Station`, not `LineId`** —
FL1 and FL3 share one physical VPS (`FW-225` §2.4), so a handoff on FL1 and one on FL3 contend
for the same row even though they are different lines.

### 2.2 Handed over, not released

AC 5. The station stays claimed across the boundary; **release happens at checkout**.

⛔ **Do not call `FlatWire_ReleaseStation` here.** [`FW-221`](../../Database/TaskBreakdownPlans/FW-221-Station-Release-And-Reqsum-Reversal.md)
AC 3 lists its legitimate callers — FL1 spool completion, FL2/FL3 run completion, checkout modes
A and B — and **an order boundary is none of them**. Releasing mid-run would let `FW-220` allow
another rod to claim a station that is still physically loaded.

⚠ **The rod is checked in once and stays mounted** — that is the premise of the whole story, and
it is exactly what `Q48` may overturn (§2.5).

### 2.3 Server-side crossing detection, once per pairing

AC 1: detected **on the footage stream, server-side**, once per pairing — *"not a client
threshold check (`SpoolWeightMilestone`'s rule)"*.

⚠ **Two consequences that are easy to miss:**

- **`FW-150`'s `RunReading` write is footage-gated at 4 ft** (`FR-018`, 20 ft intermediate), so
  the footage series is **sampled, not continuous**. A crossing is detected on the first sample
  **at or past** the threshold — never exactly at it. **The overrun is real and expected**,
  which is precisely why AC 3 latches and persists it.
- **Once per pairing** needs idempotence against a restarted loop or a replayed reading. Hold
  the "already fired" state **on the pairing row**, not in memory — `G38`'s five `FlatWireRun`
  prompt columns are the pattern.

### 2.4 Durable events, and event 11's contract has a known hole

AC 2: events 13/14 **durable and re-delivered on group re-join, following event 11's contract**.

✅ **The durability pattern is `G38`'s** — persist the prompt state against the row
(`PromptDueAt`, `PromptPlcStopTs`, `PromptLatchedWeightLb`, `PromptResolvedAt`, `PromptAnswer`),
and re-deliver on join. `FW-080` built `P-100`'s replay-on-join.

⛔ **But copy the *pattern*, not the payload.** `FW-149` step 3 found that event 11
(`SpoolCompletionPromptDue`) is **4 of 6 fillable**: `spoolAlpha` is one join away, and
**`targetLb` has no persisted source anywhere in the schema.** ⚠ **Events 13/14 must not inherit
an unfillable field** — check every field has a persisted source **before** publishing the
contract, because `[API §8]` makes adding one later a breaking change.

### 2.5 `Q48` may make the whole premise conditional

*"The rod is checked in once and stays mounted across the boundary"* is the story's opening
line. **`Q48` asks whether two orders on one rod can have different pass schedules** — and if
they can, a boundary between them needs a **re-acknowledgement and a PLC re-push**, which is not
a mounted handoff at all.

⛔ **That is a second path**, reaching `FW-082`'s tag push and `[PLC]`'s acknowledgement
contract. `FW-225`'s `P-199` escalates it; **this story cannot start until it is answered.**

⚠ **`Q50` (the escalation bound) and `Q51` (the early-ack remainder)** are narrower and shape the
notification behaviour rather than the architecture.

---

## 3. Build order

1. ⛔ **`Q48` first** (§2.5) — it decides whether this story exists in its current form.
2. ⛔ **`Q50` and `Q51`** — the escalation bound and the early-ack remainder.
3. ⛔ **Predecessors**: [`FW-240`](FW-240-RodOrder-Domain-Entities.md) (entities, blocked on
   `[SVC §3.2a]`), [`FW-225`](FW-225-Rod-Order-Allocation-Schema-And-Domain.md) (invariants),
   [`FW-232`](FW-232-OrderController-Shell.md) (the shell this handler hangs off).
4. The state machine `Pending → InProgress → ThresholdReached → Closed`, plus `Voided`, on
   `RodOrderConsumption.State`.
5. **Crossing detection** on the footage stream, **idempotent per pairing**, state held on the
   row (§2.3).
6. **Two weight latches** — at the crossing and at the acknowledgement; **persist the
   difference** as the overrun. Weights come from
   [`FW-228`](FW-228-Footage-To-Weight-Converter.md), which persists **basis + factor + version**
   alongside.
7. ⛔ **The close-and-open as ONE transaction** (§2.1).
8. **Hand over, do not release** (§2.2).
9. Events 13/14, durable on `G38`'s pattern — ⛔ **every field checked for a persisted source
   first** (§2.4).
10. `POST /order/{orderNo}/complete` handler — **the only thing that closes an order.**

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-202` precede this story.

### `P-203` — the boundary is one transaction, and the index is the reason to say so explicitly

§2.1. Both the naive orderings fail, and they fail differently — one is rejected outright, the
other opens a window in which footage belongs to no pairing. **The second is the dangerous one**
because it succeeds.

⚠ **And the contention is by station, not by line** — an FL1 boundary and an FL3 boundary touch
the same row.

### `P-204` — "once per pairing" is persisted state, not an in-memory flag

§2.3. `FW-150`'s loop restarts, and readings can be replayed. An in-memory flag re-fires events
13/14 on every restart — and they are **durable**, so a spurious one is re-delivered on join and
outlives the mistake.

**Follow `G38`**: the fired/acknowledged state lives on the row.

### `P-205` — events 13/14 publish no field without a persisted source

§2.4, applying `FW-149`'s `targetLb` finding. `[API §8]` makes adding a field later breaking, so
the cost of checking now is one pass over the payload and the cost of not checking is a
permanently unfillable member — which is exactly what event 11 carries today.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough with `FW-203` driving the feed.

| Check | Expected |
|---|---|
| **One transaction** | At a boundary, close-and-open commits atomically. ⛔ **Force the two-step ordering and confirm the index rejects it** (`P-203`) |
| **No gap** | No footage sample falls between a close and an open |
| **Station contention** | An FL1 and an FL3 boundary on the shared VPS serialise correctly |
| **Handed over** | The station is **not** released; `FlatWire_ReleaseStation` is **not** called (§2.2) |
| **Once per pairing** | Restart the loop mid-run: events 13/14 **do not re-fire** (`P-204`) |
| Crossing | Detected server-side on the **sampled** footage series, at or past the threshold |
| **Overrun persisted** | The two latched weights differ by the overrun, and the difference **is stored**, not recomputed |
| **Durable** | Events 13/14 survive a refresh and are re-delivered on group re-join (`G38` pattern) |
| **Every field fillable** | ⛔ No member of 13/14 lacks a persisted source (`P-205`) — the check `FW-149` had to make retrospectively |
| Close | `POST /order/{orderNo}/complete` is the **only** path that closes an order |
| Concurrency | `RowVersion` mapped (`FW-240`, `P-172`); a concurrent state move returns `409` |

---

## 6. Handoff

[`FW-232`](FW-232-OrderController-Shell.md) hosts the endpoint — ⛔ **and is blocked on `[API]`
minting the controller**. [`FW-228`](FW-228-Footage-To-Weight-Converter.md) supplies the latched
weights and their basis snapshot. `FW-229` (Phase 9) rolls fulfilment up.
[`FW-221`](../../Database/TaskBreakdownPlans/FW-221-Station-Release-And-Reqsum-Reversal.md)
releases the station **at checkout**, not here. The FE half is DB2A/DB3's boundary notification.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`Q48`** | May make the mounted handoff **conditional**, which is a second path, not a branch (§2.5) |
| ⛔ **`Q50`** | The escalation bound |
| ⛔ **`Q51`** | The early-ack remainder |
| ⛔ **`[SVC §3.2a]`** | `FW-240`'s boundary signature — the entities |
| **`P-54`** | `open` — `[API §4.20]`'s order set still has no host |
| **`FR-018`** | The footage series is **sampled at 4 ft**, so the overrun is expected (§2.3) |
| **`[SIG §5.5]`** | Event 11's `targetLb` has no persisted source — **do not inherit the pattern** (`P-205`) |
