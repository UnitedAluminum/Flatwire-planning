---
id: FW-168
legacy_id:
title: POST /spc and SpcService
status: blocked
status_confirmed: false
status_note: "⛔ **A de-stub with a blocking mapping defect** — the write cannot succeed until §2.3 is fixed"
owner:
jira:
mvp: 1
phase: "6"
stream: BE
streams: [BE]
priority: medium
hours: 12
sprint: S2
depends_on: [FW-139, FW-147, FW-171]
blocked_by: []
has_plan: true
started:
completed:
---
# FW-168 · `POST /spc` and `SpcService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — ⚠ **Re-reviewed against the BUILT code: this is a DE-STUB.** ✅ **`RollAdjustTrigger` is present in both built layers** — the C# enum has five members and `CK_SpcCheckpoint_Type` five values; the TypeScript union **does not exist yet** (the `flat-wire` library is still a placeholder), so the three-layer check is *pending*, not failing. ⛔ **Two defects found in the built code:** `SpcMeasurementConfiguration` maps `Deviation` and `InSpec` as **ordinary writable columns while the DDL declares both `AS (…) PERSISTED`** — the first real insert fails at the database; and `SpcMeasurementInput` **takes `TargetValue` and `ToleranceValue` from the client**, which is the verdict this story exists to keep server-side (`P-255`). Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⛔ **A de-stub with a blocking mapping defect** — the write cannot succeed until §2.3 is fixed
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-168`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — index: [Orchestration.md](Orchestration.md)

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
| The `CheckpointType` enum itself | [`FW-147`](FW-147.md) — ✅ **built with five members** |
| The five in-run event tables | [`FW-171`](../../30-database/tasks/FW-171.md), DB — ✅ **built** |
| The `InSpec` expression itself | [`FW-245`](../../30-database/tasks/FW-245.md), DB — `G51`; **it depends on this story** |
| The DB6 dialog | `FW-071`, FE |
| The die change that raises a checkpoint | [`FW-167`](FW-167.md) / `FW-073` — **deferred from the trial** |
| The roll override that writes `RollAdjustTrigger` | [`FW-169`](FW-169.md) — **deferred from the trial** |
| The SPC-HOLD **QA release** | ⚠ **No endpoint exists** — `OI-32` |

### 1.2 What already exists

Read off the built code on 29 Aug 2026. **This story is a de-stub, not a build.**

| Thing | State |
|---|---|
| `SpcController` — endpoint **21** | ✅ Built (`FW-138`) |
| `ISpcService` + `StubSpcService` + named-throw shell | ✅ Built (`FW-140`, `P-64`) |
| `SpcCheckpointRequest` / `SpcMeasurementInput` / `…Response` | ✅ Built — ⛔ **the input carries `TargetValue` and `ToleranceValue`** (§2.3) |
| `SpcCheckpoint` + `SpcMeasurement` entities, inside the `FlatWireRun` aggregate | ✅ Built (`FW-207`) — `AddMeasurement` derives `AllInSpec`, and **it stays `null` while any measurement is unjudged** |
| `FlatWireRun.RecordSpcCheckpoint` · `EnsureMandatedSpcCheckpointsSatisfied` | ✅ Built — §2.1's invariant has a home |
| `CheckpointType` — **five** members | ✅ Built, and `CK_SpcCheckpoint_Type` carries the same five |
| **The TypeScript union** | ⛔ **Not authored** — `projects/flat-wire` is a placeholder library (`FW-132`) |
| **`SpcMeasurementConfiguration`'s computed columns** | ⛔ **Mis-mapped** (§2.3) |
| **The service body** | ⛔ **Absent.** This is the deliverable |

⚠ **`SpcCheckpointResponse.AllInSpec` and `SpcMeasurementResult.InSpec` are non-nullable `bool`**
while the entities are `bool?`. **An unjudged measurement therefore serialises as `false` — "out
of spec" — which is exactly the meaning the aggregate refuses to give it.** `P-43`'s *fail the
checkpoint with a clear reason* is what keeps that case off the wire; do not "fix" it by
defaulting to `true`.

---

## 2. The five checkpoint types

`[API §2.2]` and `phase-01b` L181 — **five, not four**:

`PreRun` · `PostDieChange` · **`RollAdjustTrigger`** · `ManualSpotCheck` · `PostRun`

> ⚠ **`RollAdjustTrigger` is the correction.** It was missing from the published contract and
> `/rolloverride`'s side effect writes it. **Verify all three layers agree before S2** — the
> C# enum ([`FW-147`](FW-147.md)), the TypeScript
> union (`FW-132`) and the DB `CHECK` (`FW-007`). *"A change to any one is a change to all
> three."*
>
> ✅ **Two of the three were verified on 29 Aug 2026** — `CheckpointType` has five members and
> `CK_SpcCheckpoint_Type` lists the same five, `RollAdjustTrigger` included. ⚠ **The third does
> not exist yet**: `projects/flat-wire` is a placeholder library with no contract types, so the
> mirror is **owed by `FW-132`, not broken by it.** The failure mode the card warns about — a
> four-value layer meeting a five-value one — is now only reachable from the TypeScript side.

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

### 2.3 ⛔ There are three places a verdict could be computed, and only one may win

Read the built code before writing a line of `SpcService`:

| Site | What it does today |
|---|---|
| **The client** | `SpcMeasurementInput` carries **`TargetValue` and `ToleranceValue`** on the request |
| **The database** | `SpcMeasurement.InSpec` is `AS (CASE WHEN ABS(Actual − Target) <= Tolerance …) **PERSISTED**` — the verdict is **written to disk** from the row's own tolerance |
| **The aggregate** | `SpcCheckpoint.AddMeasurement` derives `AllInSpec`, and only from measurements already judged |

⛔ **So the card's "so that" is currently false by construction.** A client that posts a generous
`ToleranceValue` gets an in-spec verdict *persisted* — no service code required. **The service
must overwrite `TargetValue` and `ToleranceValue` from `AlloyProperty` and ignore the request's
values** (`P-43`, `P-255`); the request fields stay on the contract because DB6 shows the operator
the band it is measuring against, **not** because they are inputs.

⛔ **And the first real insert will fail.** `SpcMeasurementConfiguration` maps `Deviation` and
`InSpec` as **ordinary writable properties** while the DDL declares both computed and `PERSISTED`,
so EF includes them in the `INSERT` and SQL Server rejects it — *"the column cannot be modified
because it is either a computed column or is the result of a UNION operator."* **The stub path
never hit this because it never wrote a row.** Fix it in the configuration
(`ValueGeneratedOnAddOrUpdate`, or map them as computed), **not by dropping the columns from the
entity** — [`FW-245`](../../30-database/tasks/FW-245.md)
still needs them and reads them back.

⚠ **`G51`: the persisted expression is symmetric and `Q22`'s bands are min/max pairs**, so an
asymmetric band yields a **stored** wrong verdict. `FW-245` fixes the column and **depends on this
story** — align on one band shape before either ships.

---

## 3. Build order

0. ⛔ **Fix the computed-column mapping first** (§2.3) — nothing below can be demonstrated until an
   insert succeeds.
1. ⚠ **`SpcController POST /spc` already exists** on
   [`FW-138`](FW-138.md)'s shell — endpoint **21**. De-stub it.
2. `SubmitSpcCheckpoint` command, handler nested
   ([`FW-139 §2.2`](FW-139.md)).
3. **Shape** validation in FluentValidation → `400`; **state** rules in the `FlatWireRun`
   aggregate → `422` ([`FW-147 §2`](FW-147.md)).
   Enum membership — including rejecting `PostDb1` — is shape.
4. `SpcService`: **overwrite target and tolerance from `AlloyProperty`** and let the persisted
   column carry the verdict (`P-255`); accept measurements per type.
5. Write `SpcCheckpoint` + `SpcMeasurement` through the aggregate (§2.1).
6. Auto-link to the die change when raised from one (`OI-18`).
7. `SPC-HOLD` on suspend.
8. Audit every event; `Operator, QA` per `[API §3.2]`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-42` preceded `P-43` when it was minted on
> 15 Aug 2026. **`P-255` is added by the 29 Aug re-review**; `P-253` was the high-water mark.

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

### `P-255` — the band is server-supplied, and the verdict has exactly one site

§2.3. Three places can compute in/out of spec today, and the client is one of them.

**So: `SpcService` sets `TargetValue` and `ToleranceValue` on every measurement from
`AlloyProperty`, discards whatever the request carried, and lets the persisted column be the
single stored verdict** — with the aggregate's `AllInSpec` derived from it rather than from a
second calculation in the service.

Reasons: a second C# calculation is a second answer that can disagree with the column, and the
column is what SPC reporting reads back; the request's tolerance fields are a **display** contract
for DB6, so silently trusting them turns a display value into an authority; and `FW-245` is about
to change the expression, so the fewer places that encode the band, the smaller that change is.

⚠ **This makes the EF mapping fix (§2.3) a prerequisite, not a tidy-up** — the column can only be
the verdict if EF stops trying to write it.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **De-stub only** | The controller and contracts are not re-created; `git diff` adds a service body and **removes the `NotImplementedException`** |
| **The write actually lands** | ⛔ **Post one checkpoint against the real database** — with the computed columns mis-mapped this fails before any rule is exercised (§2.3) |
| **Verdict is server-side** | A client-supplied pass/fail **or tolerance** is ignored; the persisted verdict is computed from `AlloyProperty`'s band *(`P-255`)* |
| **Five checkpoint types** | All five accepted — **including `RollAdjustTrigger`** |
| `PostDb1` | **Rejected** (`OI-10`) |
| Writes | `SpcCheckpoint` + `SpcMeasurement`, through the `FlatWireRun` aggregate |
| Die-change link | A checkpoint raised from a die change is auto-linked |
| Suspend | Sets coil `SPC-HOLD` — and **note there is no release path** (`OI-32`) |
| Tolerance band | From `AlloyProperty`; **null band fails the checkpoint** *(`P-43`)* |
| Authorization | `Operator`, `QA` |

**Three-layer check:** `CheckpointType` has five members in the C# enum ✅, the DB `CHECK` ✅ and
the TS union ⛔ **(not authored — `FW-132`)** — part of `TC-020`'s manual diff, which needs a named
owner. ⚠ **The XML doc on `SpcCheckpoint.CheckpointType` says *"which of the four moments this
is"*.** It is five; correct the comment while you are in the file.

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
| ⛔ **Computed-column mapping** *(new 29 Aug 2026)* | `Deviation` / `InSpec` are mapped writable against `PERSISTED` computed columns — **the first real insert fails** (§2.3). Blocking |
| **`G51`** | The persisted expression is **symmetric**; `Q22`'s bands are min/max pairs. [`FW-245`](../../30-database/tasks/FW-245.md) owns the fix and **depends on this story** |
| **`FW-132`** | The TypeScript `CheckpointType` union does not exist yet — the third layer of `TC-020`'s diff |
