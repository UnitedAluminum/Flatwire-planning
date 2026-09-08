---
id: FW-170
legacy_id:
title: POST /run/{id}/pause and /resume, and RunControlService
status: not-started
status_confirmed: false
status_note: "⛔ **The pause vocabulary changed model on 2 Sep 2026 (`D-34`) — three buckets, not five categories, and `Downtime` goes to `FW-255`**"
owner:
jira:
mvp: 1
phase: "6"
stream: BE
streams: [BE]
priority: medium
hours: 8
sprint: S2
depends_on: [FW-139, FW-171, FW-254]
blocked_by: []
has_plan: true
started:
completed:
---
# FW-170 · `POST /run/{id}/pause` and `/resume`, and `RunControlService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — ⚠ **Re-reviewed against the BUILT code: this is a DE-STUB, and more of it is done than the card suggests.** ✅ `FlatWireRun.Pause()`/`Resume()` **already raise `RunPaused`/`RunResumed`**, both broadcast handlers are built (`FW-208` step 8), and **`CK_RunPauseEvent_Outcome` already carries all four outcomes** — `P-44`'s three-value-`CHECK` hazard is closed. ⛔ **Two corrections:** `Outcome` is a **string on the contract, not an enum**, so membership is FluentValidation's job; and `CK_RunPauseEvent_NotesOther` keys on **`ReasonCategory`**, not on the code. ⚠ **`[API §4.8]` still lists a `RodCheckout` pause *category*** citing the superseded `FR-262`. Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **A de-stub — four resume outcomes, and the database already enforces them**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-170`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Eight hours, and three details decide whether it is right.
>
> **Pause drives the PLC, not just the clock.** *"A paused line is genuinely idle"* — the
> service calls `PLCTagService`'s hold/idle and restore operations, which is why this story
> is Phase 6 and the operation was built back in Phase 1.
> **Resume has four outcomes.** `OI-14` closed on four; **Rod Checkout is the fourth**, and it
> is no longer a pause *reason* — that supersedes `FR-262`.
> **The payload carries a code, never a label.** `ReasonCode` + `ReasonCategory`, with notes
> mandatory on `Other` and enforced by `CK_RunPauseEvent_NotesOther`.

---

> ⛔ **CORRECTION — 2 SEPTEMBER 2026. THE PAUSE VOCABULARY CHANGED MODEL, AND TWO STATEMENTS
> ABOVE ARE NOW WRONG.** `[API §4.8]` was rewritten and `D-34` makes the client's **delay-code**
> system authoritative: four *time* buckets — `Setup` · `RunTime` · `Handling` · `Downtime` —
> replacing the 15 reasons in five semantic categories **outright**. **Literal overlap is zero.**
>
> ⛔ **This endpoint accepts THREE of the four buckets.** `CK_RunPauseEvent_Bucket CHECK
> ([ReasonCategory] IN ('Setup','RunTime','Handling'))` is live in `04_Runs.sql`, so a `DWN##`
> code is refused here — line downtime is [`FW-255`](FW-255.md)'s `LineDowntimeEvent`, whose
> `RunId` is **nullable**, because *Power Outage* and *Fire Drill* happen when no run is open.
> **47 codes here, 25 there** (`D-35`).
>
> ⛔ **The header's own correction is stale.** `CK_RunPauseEvent_NotesOther` now keys on
> **`ReasonCode`** — `CHECK ([ReasonCode] NOT IN ('SET23','RUN12','HDL15') OR [Notes] IS NOT
> NULL)` — **not** on `ReasonCategory`. ⚠ **`Other` is a code, not a category**: one per bucket.
> A caller sending `reasonCategory: "Other"` must now be rejected, and `[API §4.8]`'s example
> payload reads `{"reasonCode": "RUN13", "reasonCategory": "RunTime"}`.
>
> ⚠ **Two additions this story now owns.** The response persists **`IsNonprodTime` and
> `DelayBufferMin` as snapshots** taken at the moment of pause, so retuning editable reference
> data cannot re-price history. And **`FK_RunPauseEvent_DelayCode` is COMPOSITE on (code,
> bucket)** — *Rewind Bundle* is `Nonprod = Yes` under `Setup` and `No` under `Handling` — so
> validation on the code alone is insufficient. Reason rows come from
> [`FW-254`](FW-254.md).
>
> ✅ *"`[API §4.8]` still lists a `RodCheckout` pause category"* is **fixed** — `RodCheckout`
> remains not a pause reason, it navigates instead, and `FR-262` stays superseded. ⛔ **`G83`:
> `OperatorBreak`, `ShiftChangeover`, `AwaitingSupervisor` and `SafetyObservation` have no
> successor code at all.** They were in the SRS; they do not simply vanish.
>
> ⚠ **The 8 h is not re-priced here** — [`FW-258`](../../60-delivery/tasks/FW-258.md) owns that.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-170 · `POST /run/{id}/pause` and `/resume`, and `RunControlService`
> **Hours:** 8 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE
>
> **As a** developer,
> **I want** pause and resume to drive the PLC and the run clock together,
> **So that** a paused line is genuinely idle and its downtime is measurable.
>
> **Acceptance Criteria:**
> - [ ] `RunController POST /run/{id}/pause` and `POST /run/{id}/resume`; `PauseRun` and `ResumeRun` handlers
> - [ ] `RunControlService` pauses/restores the run clock and drives **PLC idle / restore**
> - [ ] Pause requires a reason; payload carries `ReasonCategory` + `ReasonCode` and, for `Other`, mandatory notes
> - [ ] Resume accepts one of the **four** outcomes and returns the pause duration
> - [ ] Writes `RunPauseEvent`
>
> **Rate-card basis:** 2 command endpoints, priced as one service pair (8 h, §2)
> **Dependencies:** FW-139, FW-171
> **Blockers:** —

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The pause/resume dialogs (`pause_run.js`) | `FW-065`, FE |
| `RunPauseEvent` the table | [`FW-171`](../../30-database/tasks/FW-171.md), DB — ✅ **built** |
| `PLCTagService`'s hold/idle and restore operations | [`FW-151`](FW-151.md) — ✅ **built and harness-verified 28 Aug**; first called here |
| The `PauseEvent` marker on the trace | [`FW-172`](FW-172.md) — ✅ **its two handlers are already built** |
| Rod checkout, the fourth outcome's destination | [`FW-174`](FW-174.md) / `FW-072` — **deferred from the trial** |

### 1.2 What already exists

Read off the built code on 29 Aug 2026. **Most of this story's plumbing is done.**

| Thing | State |
|---|---|
| `RunController` endpoints **19** / **20** | ✅ Built (`FW-138`) |
| `PauseRunRequest` / `PauseRunResponse` / `ResumeRunRequest` / `ResumeRunResponse` | ✅ Built — `PauseDurationSeconds` and `Outcome` on the resume response |
| `IRunService.PauseRunAsync` / `ResumeRunAsync` + stub + named-throw shells | ✅ Built (`FW-140`, `P-64`) |
| **`FlatWireRun.Pause()` / `Resume()`** | ✅ Built (`FW-207`) — **they already raise `RunPaused` / `RunResumed`**, so build step 7 is done |
| `RunPausedBroadcastHandler` / `RunResumedBroadcastHandler` | ✅ **Built by `FW-208` step 8** — **one `PauseEvent` marker type serves both**, discriminated by `IsResume` |
| `RunPauseEvent` table, `PauseDurationSeconds` computed | ✅ Built ([`FW-171`](../../30-database/tasks/FW-171.md)) |
| **`CK_RunPauseEvent_Outcome`** | ✅ Built — `ResumeRun` \| `LogWipRejection` \| `CheckOutRod` \| `ContinuePause`. **Four, verified 29 Aug 2026** |
| `IPLCTagService.HoldAsync` / `RestoreAsync` | ✅ Built — `HoldRestoreRequest(Context, Values)`: **the caller supplies the values** (`P-112`) |
| **The service body** | ⛔ **Absent.** This is the deliverable |

---

## 2. The three details

### 2.1 Pause drives the PLC

`RunControlService` **pauses the run clock and drives PLC idle**; resume restores both.
`phase-01b` L108 lists *"hold/idle and restore (Phase 6, drive enable + speed on
pause/resume)"* among the six `PLCTagService` operations **built in Phase 1 and first
exercised later** — this is that later.

> ⚠ **Phase 7 adds the never-send-a-stop invariant** (`FR-302`) and a line-state gate before
> `ClearPayoffTags`. This story's idle is **not** a stop; do not implement it as one.

### 2.2 Four resume outcomes — `OI-14` closed

**Rod Checkout is the fourth outcome**, and the change has a consequence that reads like a
bug if you do not know it: **Rod Checkout is no longer a pause *reason*.** It moved from the
reason list to the resume outcomes, **superseding `FR-262`**.

So a reason list carrying "Rod checkout" is stale — `pause_run.js` already reflects this,
with 15 reasons in five categories and `Other` at the foot of the Equipment column.

⚠ `[TRP §4]` defers `FW-072`: *"Resume ships with three of its four outcomes; **Check out
rod* disabled"*. **Build all four; expect one greyed in the trial.**

### 2.3 Code and category, never a label

The payload carries **`ReasonCode` + `ReasonCategory`** — not display text. `Other` **keeps
its code** and puts the prose in `notes`, and notes are **required** in that case per
**`CK_RunPauseEvent_NotesOther`**.

⚠ **The constraint keys on the CATEGORY, not the code** — `CHECK ([ReasonCategory] <> 'Other' OR
[Notes] IS NOT NULL)`. So a request carrying `reasonCode = "Other"` under some *other* category
passes the database untouched and lands notes-free. **Validate on the pair**, not on whichever
half you happen to read first.

⛔ **`[API §4.8]`'s reason table still lists a `RodCheckout` category**, annotated *"navigates to
Rod Checkout instead of pausing — `FR-262`"* — the rule `OI-14` superseded, in the same section
that then states the four-outcome model. **A validator generated from the contract would accept a
pause reason this story must refuse.** Reject it, and read the table as fifteen codes in five
categories, per `pause_run.js`.

Two reasons route somewhere: *Die change* and *Manual SPC measurement* apply the pause and
then open those dialogs (die change suppressed on FL2). That routing is the client's; the
server records the pause either way.

---

## 3. Build order

1. ⚠ **Both actions already exist** on [`FW-138`](FW-138.md)'s
   `RunController` — endpoints **19** and **20**. De-stub `PauseRunAsync` / `ResumeRunAsync`.
2. `PauseRun` / `ResumeRun` commands, handlers nested.
3. **Shape** rules in FluentValidation → `400`: reason present, code in the enum, notes
   present when `Other`. **State** rules in the `FlatWireRun` aggregate → `422`: the
   pause/resume state machine is one of its invariants (`[SVC §3.2a]`).
4. `RunControlService` — clock and **PLC idle/restore** together (§2.1).
5. Write `RunPauseEvent`; **server-side timestamps at API receipt** (`FR-174`).
6. Return the **pause duration** — the schema has `PauseDurationSeconds` computed.
7. ✅ **`RunPaused` / `RunResumed` are already raised by the aggregate**, and their broadcast
   handlers are built ([`FW-208`](FW-208.md) step 8) — so this
   step is *"call `Pause()` / `Resume()` and let the dispatch happen"*, **not** "write an event".
   ⛔ **Do not touch SignalR from this handler**, and do not add a second marker send: one
   `PauseEvent` type serves pause and resume, discriminated by `IsResume`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-43` preceded `P-44` when it was minted on
> 15 Aug 2026, and `P-253` is the high-water mark today.

### `P-44` — resume outcomes are an enum with four members, and the greyed one still exists

> ✅ **Half-answered by the built code, 29 Aug 2026 — and the other half moved.**
> `CK_RunPauseEvent_Outcome` **already carries all four values**, so the write-time failure this
> decision warns about cannot happen from the database side. ⚠ **But there is no `ResumeOutcome`
> enum**: `ResumeRunRequest.Outcome` is a **`string`**, with the four values named only in its XML
> comment. **Membership is therefore FluentValidation's job** — an unrecognised outcome must be a
> `400`, not a `CHECK` violation surfaced as a `500`. The three-layer mirror argument still holds
> for the day the enum is introduced; it is not what protects the write today.

`FW-072` is deferred from the trial, so one of the four outcomes has no destination there.

**Build the enum with all four and let the trial disable the control, not the contract.**
Reasons: `[SIG §5.2]`/`[API §2]`'s enums are mirrored in three layers and a member added later
is a **three-layer change**; `[TRP §4]`'s own wording is *"Resume ships with three of its four
outcomes"* — three of four, not an enum of three; and `[TRP §7]`'s standing pattern for
deferred features is **grey the control, state "not in trial scope"**, which is what it does
for die change and roll adjust.

⚠ **A four-value enum against a three-value DB `CHECK` fails at write time** — the same defect
class as `RollAdjustTrigger` in [`FW-168 §2`](FW-168.md). ✅ **Verified 29 Aug
2026: the `CHECK` carries four.**

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **De-stub only** | `git diff` adds a service body and **removes two `NotImplementedException`s**; no controller, contract or domain event is re-created |
| Pause | Clock pauses **and PLC idle is driven** — not the clock alone |
| Resume | Clock restores, PLC restores, **pause duration returned** |
| Reason required | A pause without one → `400` |
| `Other` | Notes **mandatory**; `CK_RunPauseEvent_NotesOther` enforces it |
| Payload | Carries `ReasonCode` + `ReasonCategory`, **never a label** |
| **Four outcomes** | All four accepted by the API ✅ and the DB `CHECK` ✅; **a fifth value is a `400`, not a `500`** *(`P-44`)* |
| Rod Checkout | **Not** in the reason list — it is a resume outcome (`FR-262` superseded). ⚠ **`[API §4.8]`'s table still lists it**; a pause posting that category is refused |
| `Other` under another category | Notes-free and **accepted by the `CHECK`** — the validator must catch it (§2.3) |
| `RunPauseEvent` | Written; timestamps **server-side at receipt** |
| Idle ≠ stop | The pause path sends no stop (`FR-302` is Phase 7's, and this must not pre-empt it) |

---

## 6. Handoff

[`FW-172`](FW-172.md) broadcasts the `PauseEvent` marker and the
`LineStatus` RUNNING ↔ PAUSED transition. `FW-065` (FE) is the dialog pair. `FW-072`'s
checkout is the fourth outcome's destination, deferred from the trial.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`OI-14`** | Closed on **four** outcomes — recorded here because three-outcome text survives in older artifacts |
| **`FR-262`** | **Superseded** — Rod Checkout is a resume outcome, not a pause reason. ⛔ **`[API §4.8]`'s reason table has not caught up** (§2.3) |
| **`FR-302`** | Phase 7's never-send-a-stop invariant. This story's idle must not become it |
| **No `ResumeOutcome` enum** *(new 29 Aug 2026)* | The contract carries a `string`; membership is FluentValidation's — `P-44` |
| **`D-30`** | `FlatWireRun` carries a `ROWVERSION`; two concurrent pauses on one run are a concurrency conflict, not a last-write-wins — see [`FW-243`](FW-243.md) for the three roots that do **not** |
