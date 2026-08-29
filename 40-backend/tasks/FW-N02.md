---
id: FW-N02
legacy_id:
title: Spool completion weight milestones and machine-stop confirmation
status: blocked
status_confirmed: false
status_note: "⚠ **Part A only.** Part B moved to [`FW-202`](FW-202.md) — ⛔ **the card's ACs still describe both**"
owner:
jira:
mvp: 1
phase: "8"
stream: RT
streams: [RT]
priority: medium
hours: 8
sprint: S3
depends_on: [FW-150]
blocked_by: [OQ-18, OQ-79]
has_plan: true
started:
completed:
---
# FW-N02 · Spool completion weight milestones and machine-stop confirmation

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Part A only.** Part B moved to [`FW-202`](FW-202.md) — ⛔ **the card's ACs still describe both**
**Owner:** Real-time stream
**Audience:** The developer building `FW-N02`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Four hours, and **four details decide whether it is right — the
> first being that most of what the card lists is no longer this story's.**
>
> **⛔ This story retains PART A ONLY** — `FR-130`–`FR-136`, the **advisory milestone ladder**,
> which is `Should` and *"advisory and non-blocking"*.
> [`FW-202`](FW-202.md) took Part B. ⚠ **Its acceptance criteria still
> describe the stop confirmation, the grading and the short close** — all Part B.
> **The 4 h was never enough for what the card lists**, and the card says so: *"a 26-requirement
> subsystem with 25 test cases … **4 h RT does not build it**."*
> **⛔ Advisory and non-blocking is a design constraint, not a caveat.** A milestone must never
> gate a transaction — that is `FW-202`'s prompt, which is a different mechanism with a dwell,
> an edge and a suppression rule.
> **⚠ The 10-90 SOP is not in this repository** and must be obtained from Operations, **not
> paraphrased.**

---

## 1. The story

From `[TB §7]` — verbatim. ⚠ One relative link is rebased to resolve from this folder.

> ###### FW-N02 · Spool completion weight milestones and machine-stop confirmation
> **Hours:** 4 h RT · **Priority:** Medium · **Sprint:** S3 · **Phase:** 8 · **Stream:** RT
>
> > ⚠ **Superseded in part by `FW-202` (14 Aug 2026) — gap `G37`.** This story was the **only** costed work against
> > `FR-130`–`FR-155`, a 26-requirement subsystem with 25 test cases (`TC-160`–`TC-184`), an owning specification,
> > two hub events and a built mockup component. **4 h RT does not build it.** `FW-202` now owns **Part B**
> > (`FR-140`–`FR-155`) — the PLC-confirmed stop confirmation, the completion transaction and the `SpoolProcessing` write.
> > **This story retains Part A only** (`FR-130`–`FR-136`, the advisory milestone ladder), which is `Should` and
> > explicitly *"advisory and non-blocking"*. Its hours are unchanged and remain inside Phase 8's reconciliation.
>
> **As an** FL1 operator,
> **I want** to be told as a spool approaches its target weight,
> **So that** the machine stop is expected rather than a surprise.
>
> **Acceptance Criteria:**
> - [ ] Weight-milestone notifications raised as the spool approaches target, per [`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md)
> - [ ] Machine-stop confirmation surfaced to the operator
> - [ ] **Completion is graded against the customer's min/max weight range from the order, by weight** — **not** by footage and **not** against the withdrawn 2,000 lb default, which had no basis and exceeded the TKUP-2 ceiling of 1,100 lb
> - [ ] **A short close is a specified transaction:** inside the customer range → continue; outside it → **supervisor override + production hold, or an offer to the customer under concession before a remake is planned — the offer comes first**
> - [ ] **The spool is run off either way** — FL2 has no spool stripper, so it must be emptied and returned to FL1 whatever is decided. A reject-and-remake path must never imply stopping and removing a part-full spool
>
> **Rate-card basis:** hub event binding 4 h (§2)
> **Dependencies:** FW-150
> **Blockers:** **OQ-18** *(which order field carries the range)* · **OQ-79** · ⚠ **the 10-90 SOP document is not in this repository and must be obtained from Operations rather than paraphrased**

### 1.1 Out of scope — and most of the card's own ACs are here

| Concern | Owner |
|---|---|
| ⛔ **The machine-stop confirmation** (AC 2) | [`FW-202`](FW-202.md) — **Part B** |
| ⛔ **Grading against the customer range** (AC 3) | `FW-202` — Part B's weight basis |
| ⛔ **The short-close transaction** (AC 4) | `FW-202` — Part B |
| ⛔ **The `SpoolProcessing` write** | `FW-202` |
| Footage-to-weight | [`FW-228`](FW-228.md) |
| The broadcast loop | [`FW-150`](FW-150.md) — ✅ built |

> ⚠ **Four of the card's five acceptance criteria are Part B.** Only **AC 1** — the milestone
> ladder — is this story. **AC 5 is a rule that constrains both** (§2.4).

### 1.2 What already exists

Verified on 29 Aug 2026.

| Thing | State |
|---|---|
| `FW-150`'s broadcast loop | ✅ **Built** — `payoffWeight$` is a **single payload, newest-wins** (`P-124`) |
| `SpoolCompletionPromptRaised` domain event | ✅ Built, `RunEvents.cs:234` — ⚠ **Part B's**, not the milestone |
| `SpoolCompletionPromptDue` hub member | ✅ Built — ⛔ **4 of 6 fillable; `targetLb` has NO persisted source** (`FW-149`) |
| `G38`'s five prompt columns | ✅ Built — **Part B's durable state** |
| `AlertRaised` / `AlertCleared` | ✅ Built — ⚠ producer is `FW-N06` |
| **A milestone ladder** | ⛔ **Does not exist.** This story |
| **A `targetLb` source** | ⛔ **Does not exist anywhere in the schema** (§2.2) |
| ⚠ **`payoffWeight$` on FL2** | **Absent** — `RodStaging` is FL1/FL3 only |

---

## 2. The four details

### 2.1 ⛔ Build AC 1, and record that AC 2–4 moved

The card's banner says Part B moved; its acceptance criteria were **not rewritten to match**. So
a developer working the AC list top-to-bottom builds the stop confirmation, the grading and the
short close — **all of which `FW-202` also builds, at 98 h.**

⚠ **This is the same defect class as `FW-158`'s `P-185`** — a card whose bullets contradict its
own scope statement. **The banner wins**, because it is dated and names the successor.

**Deliverable: the advisory milestone ladder, and nothing else.**

### 2.2 ⛔ The target the ladder measures against has no persisted source

*"Raised as the spool **approaches target**"* needs a target. `FW-149` step 3 found that
`SpoolCompletionPromptDue` is **4 of 6 fillable** and that **`targetLb` has no persisted source
anywhere in the schema** — its notion belongs to `[SIG §5.5]`'s **unpublished, advisory Part A**.

⚠ **Part A is this story.** So the missing field and the missing story are the same gap seen from
two sides, and `FW-149` **already named both wrong fixes** on the member.

⛔ **And `OQ-18` — which order field carries the customer's min/max range — is open**, so even
the *source* of a target is undecided.

**Consequence:** the ladder is buildable as a **mechanism** and cannot be **calibrated**. Record
it inert, as `FW-205` and `FW-245` were.

### 2.3 Advisory means it must not gate anything

`FR-130`–`FR-136` are `Should` and explicitly *"advisory and non-blocking"*.

⛔ **So a milestone must never**: block a transaction, arm `FW-202`'s prompt, set an interlock, or
be required before a completion. It is **information**.

⚠ **The distinction from `FW-202`'s prompt matters**: that prompt is armed only above target,
fires on an **edge**, waits a **dwell**, and can be **suppressed**. A milestone has none of that —
it is a threshold crossing on a weight series, and conflating the two would give the advisory
ladder the prompt's blocking behaviour.

⚠ **`FW-N06`'s alert engine is the closer analogue** — same "raise on threshold, clear on
recovery" shape, same unbatched delivery requirement. **Reuse that reasoning; do not reuse
`FW-202`'s ladder.**

### 2.4 AC 5 is a rule about the physical line, and it constrains both stories

*"The spool is run off either way — **FL2 has no spool stripper**, so it must be emptied and
returned to FL1 whatever is decided. A reject-and-remake path must never imply stopping and
removing a part-full spool."*

⚠ **This is a physical constraint, not a UI rule**, and it survives the Part A/Part B split
intact. It bears on **`FW-202`'s** short close and on **any** message this ladder shows: ⛔ **no
milestone notification may suggest removing a part-full spool.**

**The wording of the advisory text is therefore in scope here**, even though the transaction is
not.

---

## 3. Build order

1. ⛔ **Confirm the Part A/Part B split with whoever owns `[TB §7]`** (§2.1) — the card's ACs
   should be trimmed to AC 1 and AC 5.
2. ⚠ **Obtain the 10-90 SOP from Operations.** ⛔ **Do not paraphrase it.**
3. ⛔ **`OQ-18`** — which order field carries the range (§2.2).
4. The **milestone ladder** as a threshold evaluator over `payoffWeight$`, following
   [`FW-N06`](FW-N06.md)'s raise/clear shape (§2.3).
   ⚠ **FL1 only** in practice — FL2 sends no payoff weight.
5. **Unbatched delivery** — a rare event must not ride `FW-150`'s newest-wins batch, for the same
   reason `FW-160` and `FW-N06` must not.
6. ⛔ **Nothing gates on a milestone** (§2.3).
7. **Advisory wording respects AC 5** — never imply removing a part-full spool (§2.4).
8. **Record it inert** until a target source exists (§2.2).

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-235` precede this story.

### `P-236` — the card's banner wins over its acceptance criteria

§2.1. The banner is dated, names `FW-202` as successor, and states the retained scope
(`FR-130`–`FR-136`). The AC list predates it. ⛔ **Building the ACs duplicates 98 h of work.**

⚠ **Same class as `P-185`** — and it is the second such card in this pass, which suggests the
pattern is worth a sweep rather than a per-story fix.

### `P-237` — the ladder is modelled on `FW-N06`, not on `FW-202`'s prompt

§2.3. Both are "watch a value, notify at a threshold", but `FW-202`'s prompt is **blocking, edge-
triggered, dwelled and suppressible** — every one of those is wrong for an advisory milestone.

**`FW-N06`'s raise/clear evaluator is the right shape**, including its unbatched delivery rule.

### `P-238` — `targetLb`'s absence is this story's gap, and `FW-149` already named it

§2.2. `FW-149` recorded that the field has no persisted source and that its notion belongs to
Part A — **this story**. ⛔ **So the fix is not to add a field to the hub member**; it is to
decide where a target comes from (`OQ-18`) and persist it.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **Scope** | Only the **milestone ladder** is built. ⛔ No stop confirmation, no grading, no short close (`P-236`) |
| Raise | A milestone fires as the weight crosses its threshold |
| Clear | It clears on recovery, following `FW-N06`'s shape (`P-237`) |
| **Unbatched** | Arrives immediately; **not collapsed** by the newest-wins batch |
| ⛔ **Non-blocking** | No transaction, prompt, interlock or completion depends on a milestone (§2.3) |
| FL2 | No milestones — FL2 sends no payoff weight, and that is **not** an error |
| **Advisory wording** | ⛔ No message implies removing a part-full spool (AC 5, §2.4) |
| **Target** | ⛔ **Recorded inert** — no persisted source, `OQ-18` open (`P-238`) |
| SOP | Obtained from Operations, ⚠ **not paraphrased** |

---

## 6. Handoff

[`FW-202`](FW-202.md) owns Part B — the PLC-confirmed stop confirmation, the
completion transaction and the `SpoolProcessing` write — and **shares AC 5's physical
constraint**. [`FW-149`](FW-149.md) recorded `targetLb`'s absence on the hub
member and is waiting on this story's answer (`P-238`).
[`FW-N06`](FW-N06.md) is the pattern to follow.
`SpoolCompletionNotification.md` is the owning specification.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`OQ-18`** | Which order field carries the customer's min/max range — **no target without it** |
| ⛔ **`targetLb`** | **No persisted source anywhere in the schema** (`FW-149`, `P-238`) |
| ⛔ **The 10-90 SOP** | **Not in this repository.** Obtain from Operations; ⚠ do not paraphrase |
| ⛔ **The card's ACs** | Four of five are Part B and should be trimmed (`P-236`) |
| **`OQ-79`** | Short close — ⚠ **`FW-202`'s**, not this story's |
| **`G37`** | The gap that caused the Part A/Part B split |
