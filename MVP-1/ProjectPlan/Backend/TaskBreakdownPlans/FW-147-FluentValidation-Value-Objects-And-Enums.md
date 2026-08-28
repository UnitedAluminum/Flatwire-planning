# FW-147 · FluentValidation, value objects and the canonical cross-layer enums

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — ✅ **EXECUTED. `TC-020` has been run** (new §6.1) and step 4's `P-19` handoff verified as already in `FW-207`. **12 of 14 enums pass C# ↔ DDL with zero mismatches** — legs extracted mechanically, all 87 value-list `CHECK`s parsed, 24 constraints compared. ⚠ **It is a TWO-way diff: the TypeScript leg does not exist in any `ual-angular` checkout** (`FW-132` unbuilt), and `LineState`/`AlertSeverity` have **no DB leg either**, so two enums are asserted by nothing — **`G56`**, and `TC-020` is now signed off **per leg** (**`P-84`**). One real defect found: **`G55`** — `CK_SpoolCheckin_PayoffPos` pins FL2's spool to payoff position `1` (`Payoff1`, a rod-fed VPS bay) while this story's enum and the pinned lookup both make FL2's payoff `3` (`TraversingTakeup`), on a column with **no FK**; the *membership* diff passes because the disagreement is about **meaning**. Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **EXECUTED — 27 Aug 2026.** All five build-order steps are complete or accounted for: the fourteen enums and fourteen validators were built 25 Aug (`P-57`/`P-58`), step 4's `P-19` handoff was **already in `FW-207`** in three places, and **`TC-020` has now been run** (§6.1) — **12 of 14 pass C# ↔ DDL with zero mismatches**. ⚠ **It is a TWO-way diff: the TypeScript leg does not exist** (`FW-132` unbuilt), and `LineState`/`AlertSeverity` have no DB leg either, so two enums are asserted by nothing — gap **`G56`**, and `TC-020` is signed off **per leg** (`P-84`). One real defect found: **`G55`**, FL2's spool check-in is pinned to payoff position `1` while the enum and the lookup both make it `3`. **Two of the card's sample rules belong in the aggregate, not here (§5, `P-19`).**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-147`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** The card's first acceptance criterion asks FluentValidation
> to enforce *"`FM2_S3` must be Active; FL3 requires Hybrid"*. **Both belong in the
> aggregate**, and `[SVC §3.4]` and `phase-01b` L94 both say so: a rule breakable by
> **state** is a domain invariant returning **`422`**; a rule about the **shape of a
> request** is FluentValidation returning **`400`**. Putting these two in a validator
> returns the wrong status code for the rest of the system's life.
>
> The second thing: this story owns one third of a **three-way mirror**. Fourteen enums exist
> as a C# enum, a TypeScript union and a DB `CHECK`, and *"a change to any one is a change to
> all three."* The test that proves they agree is manual now — **and it is correct and
> runnable**, which is not what this plan said until 27 Aug 2026 (§6).

---
> ### ⚠ Coding standard — read `[SVC §3.4a]` before writing code
>
> The repository C# standard binds every `.cs` file here, and `[SVC §3.4a]` records the **four
> standing divergences** so they are not re-litigated in review. What this story owns:
>
> ⚠ **This story's scope was BUILT EARLY, alongside `FW-138` on 25 Aug 2026** — both are S0/Phase 1B
> and depend only on `FW-N04`, so this is sequencing, not a phase jump. Delivered: the **fourteen
> canonical enums** (`FlatWire.Domain/Enums/`, `P-58`) and the **fourteen request validators**
> (`FlatWire.Application/Validators/`, `P-57`). **`P-19` is honoured** — `FM2_S3`-Active and
> FL3⇒Hybrid are NOT in the validators; they remain `FW-207`'s. **Do not re-derive the 12 h:** it is
> owed to the re-baseline, like `FW-138`'s 42 h. What remains here is `TC-020`'s three-way diff,
> which still has no named owner.
>
> ⚠ **The validators target request DTOs, and `ValidatorBehavior` resolves on the COMMAND.**
> `FW-139`'s **`P-59`** bridges them — the command wraps the DTO and its validator delegates via
> `SetValidator`, so all fourteen are reused unchanged. Nothing here needs rewriting.
> *(`FW-139` and `Orchestration.md` said "thirteen" until 27 Aug 2026 and are now corrected;
> the built file holds **fourteen** `AbstractValidator<>` classes — §3.3.)*


## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-147 · FluentValidation, value objects and the canonical cross-layer enums
> **Hours:** **12 h BE** *(was 16)* · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> > **Restated 15 Aug 2026: 16 → 12 h** — the validator unit tests are withdrawn (`[TS §1.2]`). **The validators themselves are production code and stay.**
>
> **As a** developer,
> **I want** command validation and one canonical enum definition per concept,
> **So that** the Angular model, the backend enum and the database `CHECK` cannot drift.
>
> **Acceptance Criteria:**
> - [ ] FluentValidation per command; sample rules implemented — `FM2_S3` must be Active; FL3 requires Hybrid; `PassScheduleComponent.State ∈ {Active, Bypass, Skip}`
> - [ ] **`CheckpointType` is five-valued** — `{PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun}`. `RollAdjustTrigger` was missing and is required by `/rolloverride`'s side-effect
> - [ ] **`EdgeType ∈ {Round, Square}`** — one vocabulary, not three
> - [ ] **`State` is an enum, never a boolean `IsActive`**
> - [ ] All three match FW-132 (Angular models) and FW-007 (DB `CHECK`s). ⚠ **Validator unit tests are withdrawn** (15 Aug 2026, `[TS §1.2]`) — the three-way agreement is `TC-020`, now a **manual diff across 14 enums with a named owner**, not a green build
>
> **Rate-card basis:** validation layer + enum definitions (12 h, §2), **less the withdrawn validator tests → 12 h** (15 Aug 2026)
> **Dependencies:** FW-N04
> **Blockers:** —
>
> > **`RollAdjustTrigger` is load-bearing.** Phase 8 wires the FL2 roll-adjust button against it; if 1C ships a four-value `CHECK`, that button fails at write time. Verify all three layers agree before S2.

### 1.1 Note on the title

The card's title says *"value objects"*, but the six alphas and seven dimensioned quantities
are **[`FW-207`](FW-207-Domain-Model.md)'s** acceptance criteria, not this story's — none of
this card's five criteria mentions them. Treat value objects as `FW-207`'s and this story as
**validators + enums**. Flagged in §8.

⚠ **They have since moved again, and not to here.** `FW-141`'s **`P-66`** folds `FW-207`'s
*structural* half forward — the seven roots' declarations and **the six alphas are authored by
`FW-141`**, because its repository signatures name them. Nothing in that move lands in this
story; the pointer is recorded so a developer chasing "value objects" stops in the right file.

---

## 2. The split, which is the point

`[SVC §3.4]` and `phase-01b` L94 — **two homes, and the boundary is the deliverable**:

| Rule kind | Home | Mechanism | Status |
|---|---|---|---|
| The **shape** of a request — field presence, types, ranges, enum membership | **FluentValidation** | pipeline behaviour | **`400`** |
| Breakable by **state** | **the aggregate** | `CheckRule(IBusinessRule)` → `BusinessRuleValidationException` | **`422`** |

`phase-01b` L94 lists which is which — quoted verbatim:

> A rule breakable by **state** belongs in the **aggregate** → `CheckRule` →
> `BusinessRuleValidationException` → **`422`**: bay occupancy, rod eligibility
> (`coils.coil_status` not in `INFLAT`/`COMPLETE`/`HOLD`/`SCRAP`), Mode B's supervisor stamp,
> `FM2_S3` must be Active, FL3 ⇒ Hybrid. A rule about the **shape of a request** stays in
> **FluentValidation** → **`400`**: field presence, ranges, enum membership.

⚠ **One clause of that quote is stale and the conclusion is not.** Since `D-32` (18 Aug 2026)
`INFLAT` is **`FlatWireDB`-local** — it lives on `Rod.Status` / `SpoolProcessing.Status` /
`RodCheckout.NewRodStatus` and never enters `coils.coil_status`, so rod eligibility reads
**both** stores. `[API §1.8]`'s `ROD_UNAVAILABLE` row already says so. It is still state, still
the aggregate's, still `422`.

So of the card's three sample rules, **only the third** — `State ∈ {Active, Bypass, Skip}` —
is a validator rule. It is enum membership. The other two are named in the aggregate list.

### 2.1 The validator rules that *are* this story's

Field presence, ranges and cross-field conditionals across every command; enum membership for
all fourteen; the fifteen string vocabularies of §3.2; and **line eligibility, one rule per
endpoint** — which is the part that reads as settled and is not.

**Line eligibility is a shape rule, and it is *not* enum membership.** `LineId` carries **all
three lines** in all three layers, and narrowing it would break the mirror — the TypeScript
union and the DB `CHECK` both carry `FL1`/`FL2`/`FL3`. So an FL2 value is a **valid** `LineId`
at every endpoint, and where a line does not admit an action the refusal is an **explicit
predicate**. Five were built (**`P-83`**):

| Endpoint | Rule as built | Message constant |
|---|---|---|
| `POST /staging/rod` | `FL1` or `FL3` | `RodLineOnly` |
| `POST /checkin/rod` | `FL1` or `FL3` — FL2 uses `POST /checkin/spool` | `RodCheckInLineOnly` |
| `POST /checkin/spool` | `FL2` only | `SpoolCheckInLineOnly` |
| `POST /rolloverride` | `FL2` or `FL3` — `FR-107`–`FR-109`, **not FL1** | `RollAdjustLineOnly` |
| `POST /diechange` | not `FL2` — there is no drawing on FL2 | `DieChangeNotOnFl2` |

All five return **`400`**, and all five are guarded `.When(x => x.LineId.HasValue)` so the
`NotNull` rule owns the missing-field case and one bad request does not produce two errors.

> ### ⚠ Do not build the `lineId = FL2` **`422`** — it is withdrawn
>
> **`FR-533`, client reversal 20 Aug 2026** (`[REQ §5.29]`): FL2 **does** get pre-check-in, as
> a validation queue rather than a staging bay, so the action is *shown* on FL2 and not
> refused. `LINE_NOT_ELIGIBLE` is struck through at `[API §1.3]`, `§1.8`, `§4.4` and `§4.5`,
> and `[API §4.4]` says in terms: *"Do not build the refusal; do not delete it from this
> contract without the W5 change."* The endpoint change is **wave W5** of the 20 Aug ledger
> and is **not yet applied**.
>
> **What is withdrawn is the `422` and its code — not the refusal.** `POST /staging/rod`
> refuses FL2 today as `RodLineOnly`, a **`400`**, because W5 has not landed and there is no
> FL2 staging behaviour to accept. That is also the forward-compatible shape: W5 **widens a
> predicate**, which `[API §8]` calls non-breaking, whereas retiring a `422` for an existing
> condition would be breaking. See [`FW-138 §8.2`](FW-138-Fifteen-Thin-Controllers.md).
>
> ⚠ **The earlier reading here — *"an FL2 value fails enum membership, so no line-eligibility
> validator is needed"* — is withdrawn (27 Aug 2026).** It was wrong twice over: `LineId`
> admits FL2 by construction, and five line rules exist in the built file.

> ⚠ **Where `[API §4]` names a status for a conditional-required rule, that status wins over
> the split.** That is `P-57`'s refinement, found while building: moving
> `weldQualityFailReason`, the die-size match, `existingSkidId` and three others from their
> specified `422` to a general `400` would be a status change for an existing condition —
> **breaking**, under `[API §8]`. The split governs everything the contract does not price.

### 2.2 The three rejection rules the contract owes — two are delivered by absence

`phase-01b` L94, L184. **Do not write a rule for the first two**: each is enforced by the value
being missing from the enum, so `JsonStringEnumConverter` fails deserialisation at model
binding and the envelope's `400` comes out without a `RuleFor` anywhere.

| Rule | Delivered as | Open item |
|---|---|---|
| `Bevel` is not a domain edge value | `EdgeType` has two members; nothing to match | `OI-05` |
| `PostDb1` is not a `CheckpointType` | `CheckpointType` has five members; nothing to match | `OI-10` |
| Mode B requires the supervisor stamp | **Not built** — aggregate-side, `422` | — |

⚠ **The absence is the enforcement, so a "helpful" addition breaks it.** Adding `Bevel` or
`PostDb1` to the C# enum to *"reject it with a better message"* makes both endpoints accept a
value the DB `CHECK` refuses, and the failure moves from model binding to write time.

---

## 3. The fourteen enums

`[API §2]`: **define once; mirror in three places** — a C# enum in `FlatWire.Domain/Enums`, a
TypeScript union in the Angular library's `models/`, a `CHECK` constraint in the DDL.
**A change to any one is a change to all three.**

All fourteen, in `[API §2]`'s own order — which is the order they are written in, in **one
file**, `CanonicalEnums.cs`, precisely so `TC-020`'s diff is a side-by-side read against a
single code block rather than a walk through fourteen files (`P-58`):

| # | Enum | Members, and the trap where there is one |
|---|---|---|
| 1 | `LineId` | `{FL1, FL2, FL3}` — **all three, never narrowed per endpoint** (`P-83`) |
| 2 | `LineState` | `{Running, Idle, Setup, Paused, Fault, Offline}` — **no `Stopped`**, deliberately (§3.1) |
| 3 | `RouteMode` | `{Standalone, Hybrid}` |
| 4 | `ScheduleStatus` | `{Draft, Active, Inactive}` — MVP-1 **reads** these and never authors one |
| 5 | `ComponentName` | `{DB1, DB2, FM1, EdgeSet, FM2_S1, FM2_S2, FM2_S3}` — **three** FM2 stands; **no `Edger` member** |
| 6 | `ComponentState` | `{Active, Bypass, Skip}` — **never a boolean** |
| 7 | `EdgeType` | `{Round, Square}` — one vocabulary, not three; **nullable at the column and the DTO**, not in the enum |
| 8 | `MaterialStatus` | `{RECEIVED, STAGED, INFLAT, COMPLETE, HOLD, SCRAP}` — `INFLAT` is **local** since `D-32` |
| 9 | `PayoffPosition` | **Pinned ids** — `Payoff1 = 1`, `Payoff2 = 2`, `TraversingTakeup = 3` |
| 10 | `CheckpointType` | **Five**: `{PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun}` |
| 11 | `DispositionCode` | `{Suspend, Scrap, Rework}` — `Rework` is canonical but **unpersistable** (`OI-22`) |
| 12 | `AlertSeverity` | `{Info, Warning, Critical}` |
| 13 | `CheckoutMode` | `{ModeP, ModeA, ModeB}` |
| 14 | `StagingStatus` | `{Staged, CheckedIn, Unstaged}` — **`Blocked` is derived, not a fourth value** |

Three consequences worth carrying:

- **Edge type has an operator-facing half.** Domain and wire values are `Round`/`Square`; the
  rendered labels are **"Round Edge" / "Flat Edge"**, mapped by **a single Angular display
  pipe** — *"no other translation exists anywhere in the system."* **Do not add a display
  string to the C# enum.**
- **`"FM2_S3` must be Active" has no DB constraint anywhere.** The only non-bypassable
  `CHECK` is `CK_PSC_FM1NotBypassable`, and it is for **FM1**. The rule is correct and is
  **necessarily application-only** (`phase-01b` L183) — which is another reason it belongs in
  the aggregate, where it is enforced, rather than in a validator, where it would look like
  it were.
- ⚠ **Values are appended, never removed and never reordered**, and **members are pinned only
  on `PayoffPosition`**. Reordering silently corrupts stored, in-flight and cached payloads.

> ⚠ **Two mechanics that fail silently, both `P-58`'s** — verify them before trusting any
> enum test. **(1)** `JsonStringEnumConverter` is registered in `Program.cs`; without it
> `"FL1"` goes onto the wire as `0` and every fixture, screen and DB `CHECK` disagrees without
> an error. **(2)** Request DTOs carry **nullable** enums; without that a missing `lineId`
> binds to `LineId.FL1` rather than failing, and the `NotNull` rule in §2.1 never fires.
> **`PayoffPosition` stays an `int` on the wire** — `[API §4.5]` sends `"payoffPosition": 2`;
> the enum names the meanings behind it and does not replace it.

### 3.1 Two pending renames — build to `[API]`/`[SIG]`

`[PLCC §6.3]` records `LineState` → **`LineOperatingState`** (enum) and `LineStatus` →
**`LineStateChanged`** (hub event). **Not applied yet.** Build to `[API]`/`[SIG]` and apply
the rename in one pass across all three layers when it is arbitrated.

Related: **`enum LineState` has no `Stopped` member**, deliberately. Resolve the
`RUNNING → STOPPED` edge through the configurable `LineStateMap` (`[PLC §6]`), **never by
adding an enum value** (`PLC-Q01`).

### 3.2 The fifteen string vocabularies are *not* a fifteenth enum

`P-58`: the endpoint-local vocabularies — unstage reasons, `weldType`, `skidAssignment`,
`diePosition`, resume outcomes, rejection groups and nine more — are **string constants** in
`FlatWire.Domain/Constants/Vocabularies.cs`, not enums, **because a fifteenth enum would have
no TypeScript union and no DB `CHECK` to mirror against**. They are validated the same way —
a `Must` against the constants — but they are **out of `TC-020`'s scope**, and adding one to
the diff will report a mismatch that is not one.

### 3.3 Fourteen validators, not thirteen

`RequestValidators.cs` holds **fourteen** `AbstractValidator<>` classes — the thirteen
commonly cited plus `UnstageRodRequestValidator` (`POST /staging/rod/unstage`, `[API §4.5a]`).
`FW-139` (six places) and `Orchestration.md` said *thirteen* until 27 Aug 2026 and are now
corrected; `P-59`'s bridge applies to all fourteen and its argument is unaffected. **Anything
still saying thirteen predates that pass** — including `CHANGELOG.md` rows dated 25 Aug, which
keep what they said by convention.

---

## 4. Build order

Steps 1–3 are **done** (25 Aug 2026); steps 4–5 are the story's remainder.

1. ✅ The fourteen enums in `FlatWire.Domain/Enums/CanonicalEnums.cs`, plus the fifteen string
   vocabularies beside them in `Constants/Vocabularies.cs` (§3.2).
2. ✅ Validators per command in `FlatWire.Application/Validators/`, registered by
   `AddValidatorsFromAssemblyContaining<StageRodRequestValidator>()` and discovered by
   `ValidatorBehavior` — [`FW-139`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md)
   wires the behaviour; this story supplies the `IValidator<T>` implementations.
3. ✅ The rejection rules of §2.2 — **two of the three needed no code**, and that is the
   correct outcome, not an omission.
4. ✅ **Hand the two state rules to `FW-207`** — `P-19`. **Already done**: `FW-207` carries them
   in its §2 callout, its owns table and its build step 4. Nothing to hand over (§6.1).
5. ✅ Run `TC-020` manually — **run 27 Aug 2026, §6.1.** 12 of 14 pass C# ↔ DDL; the **TS leg
   does not exist**, so it is signed off per leg (`P-84`) and `G56` tracks the remainder.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder. This story owns **`P-19`**, **`P-83`** and **`P-84`**; its
> built code is additionally governed by **`P-57`** and **`P-58`**, which were minted in
> [`FW-138`](FW-138-Fifteen-Thin-Controllers.md) when this scope was built early. Read those
> two before touching either file — they carry the mechanics that fail silently (§3), and
> nothing here restates them.

### `P-19` — `FM2_S3`-must-be-Active and FL3⇒Hybrid go in the aggregate, not a validator

`[SVC §3.4]` and `phase-01b` L94 both name these two in the **aggregate** list, and
`phase-01b` L183 adds that the `FM2_S3` rule has no DB constraint and is *necessarily
application-only*. The card's AC 1 predates the `D-29` split.

It is not a filing preference. A validator returns **`400`** — *"your request is
malformed"* — and these two are **`422`** — *"this will never succeed as submitted."* The
`409`/`422`/`400` distinctions are what the client branches on (`[API §1.3]`), so the wrong
home returns the wrong contract to every screen that hits the rule.

**Build them as `IBusinessRule` implementations in `FW-207`'s work**, enforced by `CheckRule`.
This story keeps `State ∈ {Active, Bypass, Skip}` — genuine enum membership — and the shape
rules.

### `P-83` — line eligibility is a per-endpoint shape rule, and `LineId` is never narrowed

**Settled — 27 Aug 2026, and it corrects this plan's own earlier reading.**

`LineId` carries all three lines in all three layers, so **no endpoint gets a line refusal for
free from enum membership**. Where a line does not admit an action, the refusal is an explicit
`Must`/`NotEqual` on that endpoint's validator — the five of §2.1 — each guarded on
`HasValue`.

Two reasons it is not a narrower enum per endpoint:

- **The mirror.** A per-endpoint `LineId` subtype has no TypeScript union and no DB `CHECK` to
  mirror against — the same ground on which `P-58` keeps the endpoint vocabularies as strings
  rather than minting a fifteenth enum.
- **W5.** `FR-533` widens `POST /staging/rod` to FL2. Widening a predicate is non-breaking
  (`[API §8]`); widening an enum the DB `CHECK` mirrors is a schema change in three layers.

⚠ **Consequence for `FW-207`:** these five stay here because they are shape. *"This line has
no active run"*, *"this bay is occupied"* and *"this line is not running"* are **state** and
are not in a validator (`P-57`).

### `P-84` — `TC-020` is run and signed off **per leg**, not as one verdict

**Settled — 27 Aug 2026, on executing it.**

`TC-020` is written as a single three-way pass/fail, and **one of its three legs does not
exist** — `FW-132` has not built the TypeScript unions (`G56`). Treated as one verdict the test
is unrunnable indefinitely, so a real C# ↔ DDL agreement across twelve enums goes unrecorded
and unregressed for as long as the frontend takes.

So it is signed off **by leg**: the **C# ↔ DDL leg passed 27 Aug 2026**, 12 of 14 with zero
mismatches, recorded in §6.1 with the constraint names compared. The **TS leg is owed to
`FW-132`** and closes there. `LineState` and `AlertSeverity` have **no DB leg at all**, so for
those two the TS leg is not a second opinion — it is the *only* one, and until it exists they
are unverified by construction.

⚠ **The one thing a per-leg sign-off must not do is imply the whole test passed.** §6.1 leads
with that sentence for the same reason, and `G56` is the tracking home. **Do not tick `TC-020`
in `[TCS]` until the TS leg lands.**

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. The validators are production code and
stay; only the suite went.

The three-way agreement is **`TC-020`**, *"a manual diff across 14 enums with a named
owner"*. Run it as: for each enum, place the C# definition, the TS union and the DDL `CHECK`
side by side and diff the member lists. `CanonicalEnums.cs` is one file in `[API §2]`'s order
for exactly this reason (`P-58`), so the C# leg is a single read.

> ### ⚠ `TC-020` is correct — the *warning* about it is what is stale
>
> **Corrected 27 Aug 2026, and it reverses what this plan said at first issue.** `[TCS]`
> `TC-020` was repaired on **14 Aug 2026** — the day before this document existed — and its
> expected result now reads *"`ComponentName` is `{DB1, DB2, FM1, EdgeSet, FM2_S1, FM2_S2,
> FM2_S3}` — three FM2 stands, position-only, and excludes `Edger`"*, which matches the built
> enum value for value. It also already asserts the two §2.2 rejections.
>
> **`phase-01b` L163 carried the pre-14-Aug warning for thirteen days** (*"its expected result
> says `ComponentName` includes `FM2_6inS3`"*) and this plan inherited it at face value; **that
> bullet is now struck at source** (27 Aug 2026), rewritten to the same line count so every
> `phase-01b` L-number citation in the repository still resolves. **Do not re-fix the test case,
> and do not treat the diff as blocked** — the only thing owed is a **named owner** to run it.

| Check | Expected |
|---|---|
| `CheckpointType` | **Five** values in all three layers — the `RollAdjustTrigger` omission fails Phase 8's FL2 roll-adjust button at write time |
| `EdgeType` | `{Round, Square}`, nullable at column and DTO; **no display string in the C# enum** |
| `ComponentState` | An enum; **no `bool IsActive` anywhere** |
| `ComponentName` | **Three** FM2 members, `FM2_S1`/`S2`/`S3`; **no `Edger`** |
| `PayoffPosition` | Ids pinned, `TraversingTakeup = 3`; **`int` on the wire** |
| `LineId` | **Three** members everywhere — a per-endpoint subset is a `Must`, not a narrower enum (`P-83`) |
| Enum serialisation | `JsonStringEnumConverter` registered — `"FL1"`, not `0` (§3) |
| Validators | An invalid shape produces the envelope's **`400`** — see the note below on *which* gate produces it |
| `Bevel` / `PostDb1` | Rejected at model binding by **not being enum members** (§2.2) |
| `FM2_S3` / FL3⇒Hybrid | Produce **`422`**, from the aggregate *(`P-19`)* |

> ⚠ **The `400` does not come from `ValidatorBehavior` on thirteen of the fourteen.** `P-60`
> keeps **both** gates while any endpoint is a stub: model binding runs first and shapes the
> envelope through `InvalidModelStateResponseFactory`, and `ValidatorBehavior` only fires for
> a request that dispatches through MediatR. Today exactly one command exists —
> `StageRodCommand`, `P-59`'s bridge — and **its endpoint is still a stub**, so in practice
> every validator you exercise from an endpoint runs on the **model-binding** path. Same
> rule, same `400`, different route; do not read a passing `400` as proof the pipeline gate
> is wired.

**Verify all three layers agree before S2** — the card says so, and `RollAdjustTrigger` is
the reason.

### 6.1 What was actually run — 27 Aug 2026

**Executed, not asserted.** The three legs were extracted mechanically and diffed as sets —
`CanonicalEnums.cs` parsed to member lists, all **87** value-list `CHECK` constraints parsed out
of `FlatWire_DDL_0*.sql` (line comments stripped first, so a commented-out constraint cannot
count), and the TypeScript leg searched for across three `ual-angular` checkouts.

> ⚠ **Result in one line: the diff passes 12 of 14 with zero mismatches, and it is a
> TWO-way diff — the TypeScript leg does not exist.** `TC-020` reads as one pass/fail, so
> banking that result without this sentence claims a leg that was never compared.

| Leg | State |
|---|---|
| **C#** | ✅ `FlatWire.Domain/Enums/CanonicalEnums.cs` — **14** enums, in `[API §2]`'s order, one file |
| **DB `CHECK`** | ✅ present for **12** of the 14, across 24 constraints — `LineId` alone is mirrored by 10 |
| **TypeScript** | ❌ **does not exist.** No `flat-wire` library in `ual-angular`, `Second-Branch/ual-angular` or `ual-angular-latest`, and no `.ts` file anywhere defines `FM2_S1`, `RollAdjustTrigger`, `TraversingTakeup` or `ComponentState`. `FW-132` is unbuilt — gap **`G56`** |

**C# ↔ DDL, per enum** — set equality on member names, `PayoffPosition` also on pinned ids:

| Enum | C# | `CHECK` constraints compared | Verdict |
|---|---|---|---|
| `LineId` | 3 | 10 — `CoilOutput` · `DieChangeEvent` · `FlatWireRun` · `PassSchedule` · `RodCheckin` · `RollOverride` · `SpcCheckpoint` · `SpoolProcessing` · `WeldEvent` · `WipRejection` | ✅ |
| `LineState` | 6 | **none exist** | ⚠ no DB leg — `G56` |
| `RouteMode` | 2 | 3 — `FlatWireRun` · `PassSchedule` · `SpoolProcessing.OriginRouteMode` | ✅ |
| `ScheduleStatus` | 3 | 1 — `CK_PassSchedule_Status` | ✅ |
| `ComponentName` | 7 | 2 — `CK_PSC_ComponentName` · `CK_RollOverride_Component` | ✅ **three** FM2 stands, no `Edger`, no `FM2_6inS3` |
| `ComponentState` | 3 | 1 — `CK_PSC_State` | ✅ enum, not a boolean |
| `EdgeType` | 2 | 2 — `CK_Edger_EdgeType` · `CK_PSC_EdgeType` | ✅ no `Bevel` in any leg |
| `MaterialStatus` | 6 | 3 — `CK_Rod_Status` · `CK_SpoolProcessing_Status` · `CK_RodCheckout_NewRodStatus` | ✅ `INFLAT` local-only, `D-32` |
| `PayoffPosition` | 3 | 1 — `CK_PayoffPosition_Code` | ✅ on **members**; ⚠ **`G55` on meaning** — see below |
| `CheckpointType` | 5 | 1 — `CK_SpcCheckpoint_Type` | ✅ **five**, `RollAdjustTrigger` present *(listed last in the `CHECK`; order is immaterial to a `CHECK` and to a diff)* |
| `DispositionCode` | 3 | 1 — `CK_WipRejection_Disposition` | ✅ incl. the unpersistable `Rework` (`OI-22`) |
| `AlertSeverity` | 3 | **none exist** | ⚠ no DB leg — `G56` |
| `CheckoutMode` | 3 | 1 — `CK_RodCheckout_Mode` | ✅ |
| `StagingStatus` | 3 | 1 — `CK_RodStaging_Status` | ✅ **three** — `Blocked` correctly absent |

**The rest of §6's table, measured:**

| Check | Result |
|---|---|
| `JsonStringEnumConverter` registered | ✅ `Program.cs:124` |
| Validators registered | ✅ `AddValidatorsFromAssemblyContaining<StageRodRequestValidator>()` + `AddFluentValidationAutoValidation()`, `Program.cs:128-129` |
| Envelope on a shape failure | ✅ `ConfigureApiBehaviorOptions(... = Envelope.FromModelState)`, `Program.cs:204` — the **model-binding** gate, per `P-60` |
| `ValidatorBehavior` route | ⚠ **not reachable from an endpoint.** One command exists (`StageRodCommand`) and `PayoffStagingController.StageRodAsync` still calls `payoffStagingService` directly |
| **no `bool IsActive`** | ✅ the only `IsActive` in the C# is the enum's own warning comment. *(`PayoffPosition.IsActive` in the DDL is a lookup row-active flag — a different concept, correctly not mirrored)* |
| `PayoffPosition` `int` on the wire | ✅ `int`/`int?` on all five DTOs that carry it |
| No display string in the C# enum | ✅ *"Round Edge"/"Flat Edge"* appear once, inside `EdgeType`'s doc comment as the labels the Angular pipe owns — not as values |
| `Bevel` / `PostDb1` refused | ✅ by absence: neither is a member, so `JsonStringEnumConverter` fails deserialisation before a rule could run |
| **Step 4 — the `P-19` handoff** | ✅ **already done.** `FW-207` carries it in three places — its §2 callout (*"the two rules `FW-147`'s card samples belong HERE"*), its owns/not-in-scope table, and build step 4 in `Domain/Rules/`. Nothing to hand over |

#### Two findings, both raised as gaps

**`G55` — the membership diff passes and the *meaning* does not.** `PayoffPosition`'s members
and pinned ids agree in both legs, but `FlatWire_DDL_04_Runs.sql:684-691` replaces
`CK_SpoolCheckin_PayoffPos` with `CHECK ([PayoffPosition] = 1)` — *"FL2 has ONE payoff"*, which
is true and is a different claim from *which* payoff. The lookup pins `1 = Payoff1`
(`Equipment='VPS'`, `IsRodFed=1`) and `3 = TraversingTakeup` (`IsRodFed=0`, *"Traversing take-up
(FL2)"*), and this enum's own doc comment calls `TraversingTakeup` *"FL2's single traversing
take-up."* So the `CHECK` pins FL2's spool to a **rod-fed VPS bay**, and the column has **no
FK** to catch it. `FW-179` will have to write a value one leg calls wrong. **This is the class
of defect a set-equality diff cannot see**, which is worth knowing before anyone automates
`TC-020`.

**`G56` — the missing legs.** The TS leg does not exist for any of the fourteen, and
`LineState`/`AlertSeverity` have no DB `CHECK` either — neither is persisted, and
`CK_FlatWireRun_Status` (`{Running, Paused, Complete, Aborted}`) is **run** status, a different
vocabulary that must not be mistaken for `LineState`'s. **Those two enums are therefore asserted
by nothing today**, and `LineState` is the one carrying both a pending rename (§3.1) and a
deliberate omission (**no `Stopped`**, `PLC-Q01`).

#### One string-vocabulary note, deliberately out of scope

§3.2 rules the fifteen `Vocabularies` groups out of `TC-020`, and the sweep found why that
matters both ways: **`Vocabularies.RunStatus.Complete` is `"COMPLETE"` while
`CK_FlatWireRun_Status` publishes `'Complete'`.** SQL Server's case-insensitive collation means
a write succeeds and **stores the wrong casing**, which a C# comparison or a TypeScript
`'Complete'` union then fails on. `MaterialStatus.COMPLETE` is correctly all-caps against
`CK_Rod_Status` — the two vocabularies genuinely differ in case, and the string constant took
the material spelling for the run. `RunStatus.Declined` is **response-only** by design
(*"the prompt was declined — nothing was written"*) and correctly absent from the `CHECK`.
**Not `TC-020`'s to fail on; owed to `[API]`/`[DBD]`, and recorded here because the diff is
where it surfaced.**

---

## 7. Handoff

`FW-139`'s `ValidatorBehavior` discovers these validators and `P-59` bridges them to the
commands. **`FW-146` maps only the pipeline route** — `ValidatorBehavior` throws for the
middleware to map, while the model-binding gate produces the envelope directly through the
factory, never reaching the middleware (`P-60`, `P-81`: one `Envelope.Body` factory keeps the
two agreeing by construction). `FW-207` takes the two state rules. `FW-132` (Angular models)
and `FW-007` (DB `CHECK`s) are the other two legs of the mirror — **a change here is a change
there**.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`OI-05`** | `Bevel edge` has no domain value — enforced by its absence from `EdgeType`, not by a rule |
| **`OI-10`** | `PostDb1` is in the UI, absent from the enum and the `CHECK` — same mechanism |
| ~~**`TC-020` has no named owner**~~ | ✅ **Run 27 Aug 2026** — §6.1. The case itself was always correct; what it needed was running. Signed off **per leg** (`P-84`) |
| **`G56`** — `TC-020`'s TypeScript leg does not exist | `FW-132` is unbuilt, so the diff is **two-way**; and `LineState`/`AlertSeverity` have no DB leg either, leaving **two of the fourteen asserted by nothing**. **Do not tick `TC-020` in `[TCS]`** until the TS leg lands — it closes in `FW-132`, not here |
| **`G55`** — FL2's spool payoff position | `CK_SpoolCheckin_PayoffPos` is `= 1` (`Payoff1`, VPS, rod-fed) while this story's `PayoffPosition` enum and the pinned lookup row both make FL2's payoff **`3`** (`TraversingTakeup`). The column has **no FK**. Raised here because the enum is this story's; the fix is `[DBD]`/`[API]`'s. **A membership diff cannot see it** — the members agree and the meaning does not |
| **`G41`** | `CK_PSC_FM1NotBypassable` is **line-blind**, so a correct FL2 pass schedule cannot be authored — every FL2 schedule must mark `FM1` **Active**, engaging a stand the line does not have. It is a **`CHECK` that cannot be fixed as a `CHECK`**, so the fix lands as a domain invariant in [`FW-207`](FW-207-Domain-Model.md), not as a validator here. Recorded because this story owns the enum/`CHECK` mirror and the mirror is where it looks like a defect |
| **`OI-22`** | `DispositionCode.Rework` is canonical but **unpersistable** — named in the enum because the vocabulary is canonical; `/wipreject` refuses it explicitly rather than losing the operator's intent |
| **Pending renames** | `LineState` → `LineOperatingState`; `LineStatus` → `LineStateChanged`. Build to `[API]`/`[SIG]`; rename in one pass |
| **W5 unapplied** | `FR-533` widens `POST /staging/rod` to FL2. When it lands, widen `RodLineOnly`'s predicate — **do not** reinstate `LINE_NOT_ELIGIBLE` (§2.1) |

| Stale | Correct | Source |
|---|---|---|
| AC 1: `FM2_S3` must be Active and FL3⇒Hybrid as **FluentValidation** rules | **Aggregate** invariants → `422` | `[SVC §3.4]`, `phase-01b` L94, L183 |
| The title's *"value objects"* | The six alphas and seven quantities are **`FW-207`'s** criteria, and the alphas are **authored by `FW-141`** (`P-66`) | `[TB §7]` `FW-207`, `FW-141` `P-66` |
| ~~`phase-01b` L163 — *"`TC-020` is stale, it cites `FM2_6inS3`"*~~ | **Struck at source 27 Aug 2026.** `TC-020` was corrected **14 Aug 2026** and matches the built enum; the warning was what was stale | `[TCS]` `TC-020`, `phase-01b` L163, `CHANGELOG.md` 14 Aug 2026 |
| *"an FL2 `lineId` fails enum membership"* — this plan, to 26 Aug 2026 | `LineId` carries all three lines; the refusal is an explicit **shape rule** | `P-83`, `CanonicalEnums.cs` |
| ~~*"thirteen validators"* — `FW-139`, `Orchestration.md`~~ | **Fourteen** `AbstractValidator<>` classes in the built file. **Corrected at source 27 Aug 2026** — six places in `FW-139`, one here | `RequestValidators.cs`, §3.3 |
| `Vocabularies.RunStatus.Complete` = `"COMPLETE"` | `CK_FlatWireRun_Status` publishes **`'Complete'`**; a CI collation stores the wrong casing silently. **Out of `TC-020`'s scope** (§3.2) and owed to `[API]`/`[DBD]` — recorded because the diff surfaced it | §6.1 |
| Any artifact showing **four** FM2 stands or `FM2_6inS3` | **Three** — `FM2_S1`/`S2`/`S3` | `D-26`, master spec §10.2 |
