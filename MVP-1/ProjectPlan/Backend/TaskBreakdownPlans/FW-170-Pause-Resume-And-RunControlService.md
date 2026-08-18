# FW-170 · `POST /run/{id}/pause` and `/resume`, and `RunControlService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **four resume outcomes, not three**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-170`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

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
| `RunPauseEvent` the table | `FW-171`, DB |
| `PLCTagService`'s hold/idle and restore operations | [`FW-151`](FW-151-PLCTagService.md) — *built in Phase 1, first called here* |
| The `PauseEvent` marker on the trace | [`FW-172`](FW-172-Run-Event-Markers.md) |
| Rod checkout, the fourth outcome's destination | `FW-072` — **deferred from the trial** |

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

Two reasons route somewhere: *Die change* and *Manual SPC measurement* apply the pause and
then open those dialogs (die change suppressed on FL2). That routing is the client's; the
server records the pause either way.

---

## 3. Build order

1. Two actions on [`FW-138`](FW-138-Fifteen-Thin-Controllers.md)'s `RunController` —
   endpoints **19** and **20**.
2. `PauseRun` / `ResumeRun` commands, handlers nested.
3. **Shape** rules in FluentValidation → `400`: reason present, code in the enum, notes
   present when `Other`. **State** rules in the `FlatWireRun` aggregate → `422`: the
   pause/resume state machine is one of its invariants (`[SVC §3.2a]`).
4. `RunControlService` — clock and **PLC idle/restore** together (§2.1).
5. Write `RunPauseEvent`; **server-side timestamps at API receipt** (`FR-174`).
6. Return the **pause duration** — the schema has `PauseDurationSeconds` computed.
7. Raise `RunPaused` as a domain event
   ([`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md)) so
   [`FW-172`](FW-172-Run-Event-Markers.md) can broadcast the marker **without this handler
   touching SignalR**.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-43` precede this story.

### `P-44` — resume outcomes are an enum with four members, and the greyed one still exists

`FW-072` is deferred from the trial, so one of the four outcomes has no destination there.

**Build the enum with all four and let the trial disable the control, not the contract.**
Reasons: `[SIG §5.2]`/`[API §2]`'s enums are mirrored in three layers and a member added later
is a **three-layer change**; `[TRP §4]`'s own wording is *"Resume ships with three of its four
outcomes"* — three of four, not an enum of three; and `[TRP §7]`'s standing pattern for
deferred features is **grey the control, state "not in trial scope"**, which is what it does
for die change and roll adjust.

⚠ **A four-value enum against a three-value DB `CHECK` fails at write time** — the same defect
class as `RollAdjustTrigger` in [`FW-168 §2`](FW-168-Spc-And-SpcService.md). **Verify the
`CHECK` carries four before S2.**

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| Pause | Clock pauses **and PLC idle is driven** — not the clock alone |
| Resume | Clock restores, PLC restores, **pause duration returned** |
| Reason required | A pause without one → `400` |
| `Other` | Notes **mandatory**; `CK_RunPauseEvent_NotesOther` enforces it |
| Payload | Carries `ReasonCode` + `ReasonCategory`, **never a label** |
| **Four outcomes** | All four accepted by the API; the DB `CHECK` carries four *(`P-44`)* |
| Rod Checkout | **Not** in the reason list — it is a resume outcome (`FR-262` superseded) |
| `RunPauseEvent` | Written; timestamps **server-side at receipt** |
| Idle ≠ stop | The pause path sends no stop (`FR-302` is Phase 7's, and this must not pre-empt it) |

---

## 6. Handoff

[`FW-172`](FW-172-Run-Event-Markers.md) broadcasts the `PauseEvent` marker and the
`LineStatus` RUNNING ↔ PAUSED transition. `FW-065` (FE) is the dialog pair. `FW-072`'s
checkout is the fourth outcome's destination, deferred from the trial.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`OI-14`** | Closed on **four** outcomes — recorded here because three-outcome text survives in older artifacts |
| **`FR-262`** | **Superseded** — Rod Checkout is a resume outcome, not a pause reason |
| **`FR-302`** | Phase 7's never-send-a-stop invariant. This story's idle must not become it |
