# FW-147 · FluentValidation, value objects and the canonical cross-layer enums

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — `G41` recorded — `CK_PSC_FM1NotBypassable` is line-blind; the fix lands in `FW-207`, not here *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **two of the card's sample rules belong in the aggregate, not here (§5, `P-19`)**
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
> all three."* The test that proves they agree is manual now — and **the test case itself is
> defective**.

---

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

---

## 2. The split, which is the point

`[SVC §3.4]` and `phase-01b` L94 — **two homes, and the boundary is the deliverable**:

| Rule kind | Home | Mechanism | Status |
|---|---|---|---|
| The **shape** of a request — field presence, types, ranges, enum membership | **FluentValidation** | pipeline behaviour | **`400`** |
| Breakable by **state** | **the aggregate** | `CheckRule(IBusinessRule)` → `BusinessRuleValidationException` | **`422`** |

`phase-01b` L94 lists which is which:

> A rule breakable by **state** belongs in the **aggregate** → `CheckRule` → `422`: bay
> occupancy, rod eligibility (**`Rod.Status` not `INFLAT`** since `D-32`, and `coils.coil_status` not in `INFLAT`/`COMPLETE`/`HOLD`/`SCRAP`),
> Mode B's supervisor stamp, **`FM2_S3` must be Active**, **FL3 ⇒ Hybrid**. A rule about the
> **shape** of a request stays in **FluentValidation** → **`400`**: field presence, ranges,
> enum membership.

So of the card's three sample rules, **only the third** — `State ∈ {Active, Bypass, Skip}` —
is a validator rule. It is enum membership. The other two are named in the aggregate list.

### 2.1 Validator rules that *are* this story's

`lineId = FL2` rejected at `/staging/rod` (`[SVC §3.4]`) — `LINE_NOT_ELIGIBLE` → `422` by the
catalogue, but a shape rule by construction. Field presence and ranges across every command.
Enum membership for all fourteen.

> ⚠ The catalogue assigns `LINE_NOT_ELIGIBLE` **422**, while the split assigns shape rules
> **400**. `[API §1.8]` is the contract the client branches on — **follow the catalogue for
> codes that name a status**, and keep the split for rules the catalogue does not cover.

### 2.2 The three rejection rules the contract owes

`phase-01b` L94, L184 — build these, and know each has an open item behind it:

| Rule | Open item |
|---|---|
| `Bevel` is not a domain edge value | `OI-05` |
| `PostDb1` is in the UI, absent from the enum and the DB `CHECK` | `OI-10` |
| Mode B requires the supervisor stamp | — *(aggregate-side)* |

---

## 3. The fourteen enums

`[API §2]`: **define once; mirror in three places** — a C# enum in `FlatWire.Domain/Enums`, a
TypeScript union in the Angular library's `models/`, a `CHECK` constraint in the DDL.
**A change to any one is a change to all three.**

The ones with a stated trap (`phase-01b` L181):

| Enum | Rule |
|---|---|
| `ComponentState` | `{Active, Bypass, Skip}` — **never a boolean** |
| `EdgeType` | `{Round, Square}` — **nullable**, one vocabulary not three |
| `CheckpointType` | **Five**: `{PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun}` |
| `PayoffPosition` | **Pinned ids** — `TraversingTakeup = 3` |
| `ComponentName` | **Three** FM2 stands — `FM2_S1` / `FM2_S2` / `FM2_S3` |
| `StagingStatus`, `CheckoutMode`, `MaterialStatus`, `AlertSeverity`, `DispositionCode` | per `[API §2]` |

Two consequences worth carrying:

- **Edge type has an operator-facing half.** Domain and wire values are `Round`/`Square`; the
  rendered labels are **"Round Edge" / "Flat Edge"**, mapped by **a single Angular display
  pipe** — *"no other translation exists anywhere in the system."* **Do not add a display
  string to the C# enum.**
- **`"FM2_S3` must be Active" has no DB constraint anywhere.** The only non-bypassable
  `CHECK` is `CK_PSC_FM1NotBypassable`, and it is for **FM1**. The rule is correct and is
  **necessarily application-only** (`phase-01b` L183) — which is another reason it belongs in
  the aggregate, where it is enforced, rather than in a validator, where it would look like
  it were.

### 3.1 Two pending renames — build to `[API]`/`[SIG]`

`[PLCC §6.3]` records `LineState` → **`LineOperatingState`** (enum) and `LineStatus` →
**`LineStateChanged`** (hub event). **Not applied yet.** Build to `[API]`/`[SIG]` and apply
the rename in one pass across all three layers when it is arbitrated.

Related: **`enum LineState` has no `Stopped` member**, deliberately. Resolve the
`RUNNING → STOPPED` edge through the configurable `LineStateMap` (`[PLC §6]`), **never by
adding an enum value** (`PLC-Q01`).

---

## 4. Build order

1. The fourteen enums in `FlatWire.Domain/Enums/`.
2. Validators per command in `FlatWire.Application`, registered for `ValidatorBehavior` —
   [`FW-139`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) wires the behaviour;
   this story supplies the `IValidator<T>` implementations it discovers.
3. The three rejection rules of §2.2.
4. **Hand the two state rules to `FW-207`** — `P-19`.
5. Run `TC-020` manually (§5, and read the warning first).

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-18` precede this story.

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

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. The validators are production code and
stay; only the suite went.

The three-way agreement is **`TC-020`**, now *"a manual diff across 14 enums with a named
owner"*. Run it as: for each enum, place the C# definition, the TS union and the DDL `CHECK`
side by side and diff the member lists.

> ⚠ **`TC-020` is itself defective — fix the test case, do not build to it.**
> `phase-01b` L163: it still cites **`FM2_6inS3`**, which was **withdrawn as never-existent**
> by `D-26` (4 Aug 2026). **`FM2_S3` is correct.** Anything showing four FM2 stands, a
> separate `8" Roller`, or a 6" stand named S1 is stale.

| Check | Expected |
|---|---|
| `CheckpointType` | **Five** values in all three layers — the `RollAdjustTrigger` omission fails Phase 8's FL2 roll-adjust button at write time |
| `EdgeType` | `{Round, Square}`, nullable; **no display string in the C# enum** |
| `ComponentState` | An enum; **no `bool IsActive` anywhere** |
| `ComponentName` | **Three** FM2 members, `FM2_S1`/`S2`/`S3` |
| `PayoffPosition` | Ids pinned, `TraversingTakeup = 3` |
| Validators | An invalid shape produces `400` through `ValidatorBehavior` |
| `FM2_S3` / FL3⇒Hybrid | Produce **`422`**, from the aggregate *(`P-19`)* |

**Verify all three layers agree before S2** — the card says so, and `RollAdjustTrigger` is
the reason.

---

## 7. Handoff

`FW-139`'s `ValidatorBehavior` discovers these validators. `FW-146` maps their failures to
`400`. `FW-207` takes the two state rules. `FW-132` (Angular models) and `FW-007` (DB
`CHECK`s) are the other two legs of the mirror — **a change here is a change there**.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`OI-05`** | `Bevel edge` has no domain value |
| **`OI-10`** | `PostDb1` is in the UI, absent from the enum and the `CHECK` |
| **`TC-020` is defective** | Cites the withdrawn `FM2_6inS3`. **Fix the case; do not build to it** |
| **`G41`** | `CK_PSC_FM1NotBypassable` is **line-blind**, so a correct FL2 pass schedule cannot be authored — every FL2 schedule must mark `FM1` **Active**, engaging a stand the line does not have. It is a **`CHECK` that cannot be fixed as a `CHECK`**, so the fix lands as a domain invariant in [`FW-207`](FW-207-Domain-Model.md), not as a validator here. Recorded because this story owns the enum/`CHECK` mirror and the mirror is where it looks like a defect |
| **Pending renames** | `LineState` → `LineOperatingState`; `LineStatus` → `LineStateChanged`. Build to `[API]`/`[SIG]`; rename in one pass |

| Stale | Correct | Source |
|---|---|---|
| AC 1: `FM2_S3` must be Active and FL3⇒Hybrid as **FluentValidation** rules | **Aggregate** invariants → `422` | `[SVC §3.4]`, `phase-01b` L94, L183 |
| The title's *"value objects"* | The six alphas and seven quantities are **`FW-207`'s** criteria; none appears in this card | `[TB §7]` `FW-207` |
| Any artifact showing **four** FM2 stands or `FM2_6inS3` | **Three** — `FM2_S1`/`S2`/`S3` | `D-26`, master spec §10.2 |
