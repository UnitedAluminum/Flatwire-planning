# FW-168 · `POST /spc` and `SpcService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **`RollAdjustTrigger` must exist in all three layers before S2**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-168`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** The story's own "so that" states the rule that shapes it:
> **an in-spec verdict cannot be produced by the client.** The server computes it. A screen
> that decides pass/fail and posts the answer has inverted the whole point.
>
> And one enum value is load-bearing across three layers: **`CheckpointType` has five
> members, and `RollAdjustTrigger` is the one that was missing.** `[TB §7]`: *"Phase 8 wires
> the FL2 roll-adjust button against it; if 1C ships a four-value `CHECK`, that button fails
> at write time."* This story is where the server side must be right.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-168 · `POST /spc` and `SpcService`
> **Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE
>
> **As a** developer,
> **I want** the spec calculation and hold behaviour on the server,
> **So that** an in-spec verdict cannot be produced by the client.
>
> **Acceptance Criteria:**
> - [ ] `SpcController POST /spc`; `SubmitSpcCheckpoint` handler
> - [ ] `SpcService` computes in/out of spec and sets coil `SPC-HOLD` on suspend
> - [ ] Measurements accepted per checkpoint type; **`CheckpointType` accepts all five values including `RollAdjustTrigger`**
> - [ ] Writes `SpcCheckpoint` + `SpcMeasurement`; auto-links to the die change when raised from one
> - [ ] All events audited
>
> **Rate-card basis:** command endpoint 6 h + `SpcService` 6 h = 12 h (§2)
> **Dependencies:** FW-139, FW-147, FW-171
> **Blockers:** —

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The `CheckpointType` enum itself | [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) |
| The five in-run event tables | `FW-171`, DB |
| The DB6 dialog | `FW-071`, FE |
| The die change that raises a checkpoint | `FW-073` — **deferred from the trial** |
| The roll override that writes `RollAdjustTrigger` | `FW-169` — **deferred from the trial** |
| The SPC-HOLD **QA release** | ⚠ **No endpoint exists** — `OI-32` |

---

## 2. The five checkpoint types

`[API §2.2]` and `phase-01b` L181 — **five, not four**:

`PreRun` · `PostDieChange` · **`RollAdjustTrigger`** · `ManualSpotCheck` · `PostRun`

> ⚠ **`RollAdjustTrigger` is the correction.** It was missing from the published contract and
> `/rolloverride`'s side effect writes it. **Verify all three layers agree before S2** — the
> C# enum ([`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md)), the TypeScript
> union (`FW-132`) and the DB `CHECK` (`FW-007`). *"A change to any one is a change to all
> three."*

⚠ **`PostDb1` must not be accepted.** The decision was applied to the UI and never to the data
model, so the enum and the `CHECK` do not carry it — `OI-10`, one of the **three rejection
rules the validator owes** (`phase-01b` L184).

### 2.1 Where the mandated checkpoints come from

`[SVC §3.2a]` puts `SpcCheckpoint` + `SpcMeasurement` **inside the `FlatWireRun` aggregate**,
whose invariants include *"SPC mandated after a die change and after a roll adjust."*

So a checkpoint is raised three ways, and the auto-link matters for one of them:

| Raised by | Type | Link |
|---|---|---|
| Check-in | `PreRun` | the run |
| A die change | `PostDieChange` | ⚠ **auto-linked to the die change** |
| A roll override | `RollAdjustTrigger` | the override |
| An operator | `ManualSpotCheck` | the run |
| Run end | `PostRun` | the run |

⚠ **`OI-18`: an SPC checkpoint cannot join to its trigger** in the current schema. The
auto-link is the requirement; the mechanism is an open item.

### 2.2 Suspend → `SPC-HOLD`

`SpcService` computes the verdict and, on suspend, sets coil **`SPC-HOLD`**. Out-of-spec at
the final SPC is one of the three things `OutputCoilCompletion` owns a decision on — *"none
of which a headless service can decide."*

⚠ **Nothing releases an `SPC-HOLD`.** `[API §9.2]` marks **QA SPC-HOLD release** as
*"endpoint missing — `OI-32`"*, and it is **MVP-1**. This story can set the hold and there is
no supported path out of it. Flag it; do not invent one.

---

## 3. Build order

1. `SpcController POST /spc` on [`FW-138`](FW-138-Fifteen-Thin-Controllers.md)'s shell —
   endpoint **21**.
2. `SubmitSpcCheckpoint` command, handler nested
   ([`FW-139 §2.2`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md)).
3. **Shape** validation in FluentValidation → `400`; **state** rules in the `FlatWireRun`
   aggregate → `422` ([`FW-147 §2`](FW-147-FluentValidation-Value-Objects-And-Enums.md)).
   Enum membership — including rejecting `PostDb1` — is shape.
4. `SpcService`: compute in/out of spec **server-side**, accept measurements per type.
5. Write `SpcCheckpoint` + `SpcMeasurement` through the aggregate (§2.1).
6. Auto-link to the die change when raised from one (`OI-18`).
7. `SPC-HOLD` on suspend.
8. Audit every event; `Operator, QA` per `[API §3.2]`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-42` precede this story.

### `P-43` — the tolerance band is data, and it is unseeded

`SpcService` computes in/out of spec against a **min/max band read from `AlloyProperty`**
(`CHK007`, restated as a band on 1 Aug 2026). ⚠ **`[TRP §6]` blocker 2: the values are owed by
the client by e-mail and nothing is seeded** — needed **before T2**.

**Do not compile a default band.** A hard-coded tolerance produces a confident verdict against
a number nobody agreed, and the verdict is exactly what this story exists to make
authoritative. **Read from `AlloyProperty`; if the band is null, fail the checkpoint with a
clear reason rather than passing it.**

The same reasoning already applies one table over: `AlloyProperty.LbPerFtFactor` is seeded
**NULL, "OQ-10 PENDING"**, and `[TRP §9]` accepts the resulting assertion as untestable at
trial rather than seeding a guess. **Follow that precedent.**

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **Verdict is server-side** | A client-supplied pass/fail is ignored; the response carries the server's |
| **Five checkpoint types** | All five accepted — **including `RollAdjustTrigger`** |
| `PostDb1` | **Rejected** (`OI-10`) |
| Writes | `SpcCheckpoint` + `SpcMeasurement`, through the `FlatWireRun` aggregate |
| Die-change link | A checkpoint raised from a die change is auto-linked |
| Suspend | Sets coil `SPC-HOLD` — and **note there is no release path** (`OI-32`) |
| Tolerance band | From `AlloyProperty`; **null band fails the checkpoint** *(`P-43`)* |
| Authorization | `Operator`, `QA` |

**Three-layer check:** `CheckpointType` has five members in the C# enum, the TS union and the
DB `CHECK` — part of `TC-020`'s manual diff, which needs a named owner.

---

## 6. Handoff

`FW-171` (DB) supplies the tables. `FW-071` (FE) is the DB6 dialog. `FW-169`'s roll override
writes `RollAdjustTrigger` — **deferred from the trial**, which is why the enum value can look
unused and must exist anyway. A die change's mandated checkpoint is `FW-073`, also deferred.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`Q22`** | **Min/max tolerance values are owed by the client and nothing is seeded** — `[TRP §6]` blocker 2, **before T2**. `P-43` |
| **`OI-10`** | `PostDb1` is in the UI, absent from the enum and the `CHECK` |
| **`OI-18`** | An SPC checkpoint **cannot join to its trigger** — the auto-link is required and the mechanism is open |
| **`OI-32`** | **QA SPC-HOLD release has no endpoint** and is MVP-1. This story can set a hold with no supported way out |
| **`FR-189`** | The release requirement behind `OI-32` |
