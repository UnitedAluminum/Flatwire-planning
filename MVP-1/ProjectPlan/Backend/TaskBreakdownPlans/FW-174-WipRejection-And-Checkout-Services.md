# FW-174 · `POST /wipreject`, `POST /checkout` and their services

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **AC 4 is a behaviour change, not a new feature**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-174`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Two off-ramps in one story, and three things that will not be
> obvious from the code you are replacing.
>
> **`POST /wipreject` is the only thing in the entire system that clears a `Blocked` bay.**
> Not an unstage, not an override, not an admin action. If this endpoint is wrong, a bay stays
> occupied forever.
> **Mode B supervisor approval is now enforced by constraint** — the card calls it *"a
> behaviour change for any code that wrote a Mode B checkout without one."*
> **And the bay is cleared by publishing a domain event, not by reaching into `RodStaging`** —
> shorter, works, and breaks the aggregate boundary.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-174 · `POST /wipreject`, `POST /checkout` and their services
> **Hours:** 24 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 7 · **Stream:** BE
>
> **As a** developer,
> **I want** both off-ramps written server-side with their status transitions,
> **So that** disposition and material status can never disagree.
>
> **Acceptance Criteria:**
> - [ ] `WipRejectionController POST /wipreject` → status + `alertBroadcast`; `SubmitWipRejection` handler; `WipRejectionService` sets status, adds the WIP-Held entry and raises the alert
> - [ ] `CheckOutController POST /checkout` (mode / footage / reason / rodDisposition / materialDisposition / remainingWeight) → `newRodStatus` / `plcTagsCleared` / `partialSpoolAlpha`; `CheckOutRod` handler; `CheckOutService` voids the acknowledgement, calls `ClearPayoffTags`, creates PENDING DISPOSITION and notifies the supervisor
> - [ ] **A WIP rejection on the staging path also releases the bay** — sets `RodStaging.Status='Unstaged'`, `UnstageKind='WipRejection'`, `WipRejectionId`, and broadcasts `PayoffStateChanged{NotStaged}`. **Nothing else clears a `BLOCKED` bay**
> - [ ] **Mode B supervisor approval enforced by constraint** — this is a behaviour change for any code that wrote a Mode B checkout without one
> - [ ] Line-state gate before tag clear; partial spool alpha only on Accept
> - [ ] Operators flag, supervisors dispose; all audited
>
> **Rate-card basis:** 2 command endpoints @ 6 h = 12 h + 2 services @ 6 h = 12 h → 24 h (§2)
> **Dependencies:** FW-139, FW-176, FW-151
> **Blockers:** **`Q13`** · **`Q23`**

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The DB8 / DB12 screens | `FW-067`, FE |
| The `WipRejection` / `RodCheckout` tables | `FW-176`, DB |
| The durable supervisor queue this notifies into | `FW-175` — ⚠ **deferred from the trial** |
| The broadcasts | [`FW-177`](FW-177-Exception-Broadcasts.md) |
| `ClearPayoffTags` itself | [`FW-151`](FW-151-PLCTagService.md) |

---

## 2. The three non-obvious rules

### 2.1 The only thing that clears a `Blocked` bay

`G21` and `phase-01b` L93. A failed inspection at staging commits the row and returns
**`201` with `state:"Blocked"`** — *"the bay must stay occupied because the failed bundle is
physically on it"* — with **no override**.

`POST /wipreject` sets `RodStaging.Status='Unstaged'`, `UnstageKind='WipRejection'`,
`WipRejectionId`, and broadcasts `PayoffStateChanged{NotStaged}`.

> ⚠ **`Blocked` is a *derived* state** — `Status='Staged'` + any inspection column `='Fail'` —
> **never a stored `Status` value**. So the release is not "clear the Blocked flag"; it is
> *"leave `Staged`"*, after which the derivation no longer holds.

⚠ **`PayoffStateChanged` must never enter the ~100 ms batch**
([`FW-150 §2`](FW-150-Broadcast-Loop.md)) — a bay changing hands is an operator-visible
transition, not a sample.

### 2.2 Release by event, not by reach

`[SVC §3.2a]`: `WipRejection` *"publishes a domain event rather than reaching into
`RodStaging`."* `WipRejection` and `RodStaging` are **separate aggregate roots**, and a direct
write couples two roots inside one transaction.

```
POST /wipreject → WipRejection raises BayStateChanged
                → handler updates RodStaging + broadcasts PayoffStateChanged
```

[`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) owns the plumbing and lists this
chain as its own AC 5.

### 2.3 Mode B is enforced by the database now

**A constraint, not a service check** — so code that previously wrote a Mode B checkout
without a supervisor stamp **now fails at write time**. That is intended, and it is why the
card flags it as a behaviour change.

The three checkout modes (`[EX]`, `[SVC §3.2a]`):

| Mode | Rule |
|---|---|
| **P** — pre-check-out | **Must carry null footage** |
| **A** | — |
| **B** | **Supervisor stamp + PLC-locked footage > 0** |

⚠ **`G24`: `RodCheckout` has no `ApprovedBy`, `ApprovedAt` or `OverrideReason` columns at
all.** `RodStaging` has the credential trio; the checkout table does not. So *"enforced by
constraint"* needs those columns to exist — **confirm with `FW-176` before building against
them.** Every supervisor-gated checkout is otherwise unauditable.

---

## 3. The checkout sequence

`CheckOutService`, in order:

1. **Line-state gate** — refuse if the line reports Running (`LINE_STILL_RUNNING` → `422`)
2. Void the acknowledgement
3. `ClearPayoffTags(lineId, payoffPosition)` — [`FW-151`](FW-151-PLCTagService.md)
4. Create **PENDING DISPOSITION**
5. Notify the supervisor
6. **`partialSpoolAlpha` only on Accept**

> ⚠ **Phase 7 adds the never-send-a-stop invariant, `FR-302`** — the gate precedes the clear
> and the clear is not a stop.

⚠ **Step 5 needs `FW-175`'s durable queue**, which is **deferred from the trial**. A pending
disposition carried only by a transient SignalR notification is stranded when the supervisor's
terminal disconnects — the defect `FW-175` exists to prevent. See `P-46`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-45` precede this story.

### `P-46` — persist PENDING DISPOSITION here; the queue that reads it is `FW-175`'s

`FW-175` (durable supervisor queue) is deferred from the trial, and this story creates the
pending dispositions it would hold.

**Write the PENDING DISPOSITION to the database as part of the checkout transaction
regardless.** It is a **status on the material**, not a notification — the notification is the
volatile part. `FW-175`'s absence means nobody is reliably *told*; it must not also mean the
state is not *recorded*.

The trial consequence is worth stating: **a pending disposition raised during the trial may go
unseen**, and the material stays locked. That is a known trial limitation, not a defect in
this story.

⚠ **`OI-32`: supervisor disposition of a pending Mode B checkout has no endpoint at all**, and
it is a **decided requirement** (`FR-325`, `FR-326`). So this story creates a state with **no
supported transition out of it**. Flag it; do not invent the endpoint.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough and by the trial's
acceptance run.

| Check | Expected |
|---|---|
| **Blocked bay released** | A staged rod failing inspection → `201`/`Blocked`; `POST /wipreject` → bay reports `NotStaged`. **The only path** |
| Release mechanism | Via a **domain event** — no direct write into `RodStaging` from the rejection handler |
| `PayoffStateChanged` | Broadcast **immediately**, never in a batch |
| **Mode B** | Without a supervisor stamp → **fails at the constraint**, not in the service |
| Mode P | **Null footage**; a non-null value rejected |
| Line-state gate | Checkout on a running line → `422` `LINE_STILL_RUNNING` |
| Order | Gate → void → `ClearPayoffTags` → PENDING → notify |
| `partialSpoolAlpha` | Only on Accept |
| Roles | **Operators flag, supervisors dispose**; all audited |

---

## 6. Handoff

[`FW-177`](FW-177-Exception-Broadcasts.md) broadcasts `AlertRaised`, `RodCheckoutEvent` and
`LineStatus → IDLE`. `FW-176` (DB) owns the tables — **and `G24`'s missing columns**.
`FW-175` makes the supervisor notification durable, when it is scheduled. `FW-067` (FE) is
DB8/DB12.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`Q13`** *(blocker)* | Re-weld on certificate — bears on the traceability a rejection interrupts |
| **`Q23`** *(blocker)* | — |
| **`G24`** ⚠ | **`RodCheckout` has no `ApprovedBy`/`ApprovedAt`/`OverrideReason`.** AC 4's constraint has nothing to constrain until `FW-176` adds them. **Confirm before building** |
| **`OI-32`** | **No endpoint for supervisor disposition of a pending Mode B** — a decided requirement (`FR-325`/`FR-326`) with no surface. `P-46` |
| **`OI-38`** | The supervisor PIN's validation source, unsettled for all overrides |
| **`OI-20`** | Polymorphic material refs with no integrity — affects both endpoints |
| **`OI-21`** | Two rejection-ID formats (`REJ-####` vs `REJ-2026-0418`). Pick one and record it |
| **`OI-22`** | The **`Rework` disposition is unpersistable** |
| **`G21`** | Bay uniqueness is keyed on the **physical station**, not the line |
