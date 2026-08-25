# FW-207 · Domain model — aggregates, value objects and invariants

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — `G41` and `G42` recorded — `G41`'s stated resolution names this story's `IBusinessRule` set *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **two criteria are closed by design and unverifiable; do not delete them**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-207`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** `FlatWire` is **the first UAL service built to tactical
> DDD** (`D-29`, 15 Aug 2026), and the most likely failure mode is not doing it badly — it
> is **rewriting machinery that already exists**. `UA.Framework.Domain` ships `Entity` and
> `ValueObject`; `CoilCheckin` ships `IBusinessRule`, `CheckRule` and
> `DispatchDomainEventsAsync`. All of it is **dormant** — `CoilCheckin` kept every piece and
> modelled `DBModels/` as anemic property bags. *"If you are writing an `Entity` or
> `ValueObject` base class, you have missed the one in `UA.Framework.Domain`."*
>
> The second thing: **the alpha is the identity, but `Entity.Equals()` operates on `Id`.**
> Those two facts coexist and the gap between them is a real bug waiting to be written.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-207 · Domain model — aggregates, value objects and invariants
> **Hours:** 32 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> > **New 15 Aug 2026 — decision `D-29`, tactical DDD.** The framework already ships the toolkit: `UA.Framework.Domain.EntityModels.Entity` (domain events, identity equality) and `ValueObject` (`GetAtomicValues`, structural equality); `CoilCheckin` ships `IBusinessRule`/`CheckRule` → `BusinessRuleValidationException`. **Inherit them — do not write new base classes.**
>
> **As a** developer,
> **I want** aggregates that enforce their own invariants,
> **So that** rules cannot be bypassed by a caller that forgets to run a validator.
>
> **Acceptance Criteria:**
> - [ ] **Seven aggregate roots** — `FlatWireRun`, `RodStaging`, `WeldEvent`, `SpoolProcessing`, `CoilOutput`, `RodCheckout`, `WipRejection` — each inheriting `Entity`. Boundaries per `[SVC §3.2a]`
> - [ ] ⚠ **`RunReading` is in NO aggregate** — 10 Hz time series; it stays an append-only write model read by Dapper. Materialising it inside `FlatWireRun` is the failure this criterion exists to prevent
> - [ ] ⚠ **`Rod` and `PassSchedule` get no aggregate and no repository** — read models. `PassSchedule` is MVP-2-owned and reached only through `PassScheduleSnapshot`
> - [ ] **Six alpha value objects** with validating constructors — `RodAlpha` `R#####`, `SpoolAlpha` `SP-#####`, `RunAlpha` `RUN-####`, `CoilAlpha` `FW-#####-C##`, `DieAlpha`, `PassScheduleReference`. `RodAlpha("ROD-00041")` must throw (**closes `G14`'s format half**)
> - [ ] **Seven dimensioned quantities** — `Gauge`, `Width`, `Footage`, `WeightLb`, `SpeedFpm`, `RollGap`, `RollDiameter` — each inheriting `ValueObject`
> - [ ] Invariants as `IBusinessRule`, enforced by `CheckRule` → `BusinessRuleValidationException` → **`422`**. Includes **`G21` bay occupancy**, which must reject a second rod on the same physical station **with the DB index absent**
> - [ ] The **alpha is the identity** — repositories key on it, not on `Entity.Id`
>
> > ⚠ **Two criteria above are no longer demonstrable, and they are the evidence behind two closed gaps.** With backend tests withdrawn (15 Aug 2026, `[TS §1.2]`), nothing exercises `RodAlpha("ROD-00041")` throwing — which is what *"closes `G14`'s format half"* — and nothing runs the bay rule **with the DB index absent**, which is what makes `G21`'s index *"belt-and-braces, not the sole defence"* rather than the only defence. **Both criteria stay: the design is right and must still be built.** They are restated in `[GAP]` as **closed by design, unverified**. Do not delete them to make the story pass.
>
> **Rate-card basis:** 7 roots × 3 h = 21 · 13 value objects × 0.5 h ≈ 7 · rules ≈ 4 = **32 h**. Above §2's *"non-trivial service 12–24 h"* band because it is ~20 items, not one. **Unchanged by the 15 Aug test withdrawal** — every hour here is production code; the withdrawn tests were never priced into it
> **Dependencies:** FW-N04
> **Blockers:** — *(⚠ **`D1` open**: `ROWVERSION` is absent on `WeldEvent`, `RodCheckout` and `WipRejection`, all three mutated after insert. Decide before the schema freeze)*

⚠ **`D1` was renumbered `D-30` on 15 Aug 2026** — it collided with `[PLC]`'s retired
`D1`–`D17` log — and promoted into `[ARC §13.1]`. Same decision.

---

## 2. The seven roots, and what each owns

`[SVC §3.2a]` — the boundary table of record:

| Root | Contains | Invariants it enforces |
|---|---|---|
| **`FlatWireRun`** | `FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `RollOverride`, `DieChangeEvent`, `SpcCheckpoint` + `SpcMeasurement` | Pause/resume state machine and its **four** resume outcomes; SPC mandated after a die change and after a roll adjust; roll-gap override requires authority, and **revert is Operations-Manager-only** (`FR-212`) |
| **`RodStaging`** | bay state | **`G21` — one rod per *physical* station**, keyed on `Station` not `LineId`. `Blocked` is **derived** (`Staged` + any inspection `Fail`), never stored; `IsWelded` is a **flag on a `Staged` row**, not a status |
| **`WeldEvent`** | — | **Its own root, not part of `FlatWireRun`** — welds are recorded at pre-check-in **before a run exists** |
| **`SpoolProcessing`** | completion state | Prompt raised **once** per `RUNNING → STOPPED` edge; weight **latched at the PLC stop timestamp** |
| **`CoilOutput`** | `CoilTraceability` | **DM010 non-overlap is an aggregate invariant** — footage ranges may not overlap. The trigger stays as belt-and-braces |
| **`RodCheckout`** | — | Mode P / A / B; Mode B needs the supervisor stamp and PLC-locked footage > 0; **Mode P must carry null footage** |
| **`WipRejection`** | — | Disposition lifecycle; **the only thing that clears a `Blocked` bay** — and it does so by **publishing a domain event**, never by reaching into `RodStaging` |

### 2.1 The three deliberate exclusions

- **`RunReading`** — *"the most important exclusion in this design."* 10 Hz time series;
  inside `FlatWireRun` it would materialise thousands of rows on every command. Append-only
  write model, read by Dapper via `sp_GetGaugeTrace`.
- **`Rod`** — a `FlatWireDB`-local mirror of `coils` (`D-04`); `coils` owns the lifecycle.
- **`PassSchedule`** — a read model, reached only through `PassScheduleSnapshot`.

> ⚠ **AC 3's *"`PassSchedule` is MVP-2-owned"* is superseded.** `D-31` (15 Aug 2026) moved
> the three `PassSchedule*` tables **into MVP-1** and made `PassScheduleId` a real enforced
> FK. **The read-model status is unchanged and is the operative half** — MVP-1 reads
> schedules and never authors them, so there is still no aggregate and no repository. Only
> the ownership clause is wrong.

### 2.2 ⚠ The alpha is the identity — and equality is not

`[SVC §3.2a]`:

> ⚠ **The surrogate is not the identity.** `FlatWireRun` carries both `[Id] INT IDENTITY`
> and `[RunId] VARCHAR(20)` — and it is `RunId` that every child table references. […] So
> **repositories are keyed by the alpha value object**. […] Note `Entity.Equals()` and
> `IsTransient()` operate on `Id`, so **equality is surrogate-based**: do not assume two
> instances with the same alpha compare equal before both are persisted.

Both halves are true at once. **Key on the alpha; do not rely on `==` for identity before
persistence.** A `HashSet<FlatWireRun>` or a `Distinct()` over unsaved aggregates will not
behave as the domain reads.

---

## 3. Value objects

**Six alphas**, each with a validating constructor — `[BR §3]` owns the formats:

`RodAlpha` `R#####` · `SpoolAlpha` `SP-#####` · `RunAlpha` `RUN-####` ·
`CoilAlpha` `FW-#####-C##` (mid-run child `…-A`) · `DieAlpha` `D-{size×1000}-{seq}` ·
`PassScheduleReference` (opaque)

> **`RodAlpha("ROD-00041")` must throw.** This *"closes `G14`'s format half by
> construction"* — a malformed alpha becomes unrepresentable rather than merely discouraged.
> `PartialRodReCheckin.md`'s worked examples use exactly those non-canonical `ROD-`/`SPL-`
> forms, which is the drift this constructor ends.

**Seven dimensioned quantities**, each inheriting `ValueObject`: `Gauge` (in) · `Width` (in) ·
`Footage` (ft) · `WeightLb` · `SpeedFpm` · `RollGap` (in) · `RollDiameter` (in).

> These address `G14`'s footage `DECIMAL`-vs-`INT` ambiguity and the `PLC-Q15` class — with
> `.Lb` and `.FPM` gone from the tag names **no tag declares a unit**, so a typed quantity
> catches at compile time what the tag map no longer catches at all.

Plus **`PassScheduleSnapshot`** — an immutable record of what was pushed (schedule id,
version, effective configuration), so a certificate stays reproducible after the owning
system later edits the schedule (`[PLC §11.2]`, `Q64`).

*(Six + seven = thirteen, matching the rate-card's "13 value objects".)*

---

## 4. Build order

1. **Inherit, do not write.** `Entity` and `ValueObject` from
   `UA.Framework.Domain.EntityModels`; `IBusinessRule` / `CheckRule` /
   `BusinessRuleValidationException` from the framework in preference to `CoilCheckin`'s
   local duplicates — `CoilCheckin` copies files that ship identically in
   `UA.Framework.Domain`, and the framework version is the one to take.
2. **The thirteen value objects** first — the aggregates are typed against them.
3. **The seven roots** in `FlatWire.Domain/AggregatesModel/`, with behaviour on the
   aggregate, not on a service.
4. **Invariants as `IBusinessRule`** in `Domain/Rules/` (reusable specifications) and
   `Application/BusinessRules/` (concrete rules) — `[SVC §3.4]`.
5. **Take the two rules `FW-147` hands over** —
   [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md) `P-19`: *`FM2_S3` must be
   Active* and *FL3 ⇒ Hybrid* are aggregate invariants returning `422`, not validator rules
   returning `400`.
6. **Domain events** raised via the inherited `AddDomainEvent` — dispatch is `FW-208`.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-22` precede this story.

### `P-23` — build the two unverifiable criteria anyway, and record them as such

**Not a choice so much as an instruction to follow one.** The card is explicit: with backend
tests withdrawn, nothing exercises `RodAlpha("ROD-00041")` throwing and nothing runs the bay
rule with the DB index absent — **and both criteria stay**, restated in `[GAP]` as *"closed
by design, unverified."*

**Do not delete them to make the story pass.** They are the evidence behind two closed gaps,
and deleting them silently re-opens `G14`'s format half and demotes `G21`'s index from
belt-and-braces to sole defence.

Practically: implement both, and in the QA0 walkthrough demonstrate the alpha constructor
throwing by hand. The bay rule with the index absent is genuinely not demonstrable in a
deployed environment — say so rather than claiming coverage.

### `P-24` — interim stance on `D-30`

`ROWVERSION` is absent on **`WeldEvent`, `RodCheckout` and `WipRejection`**, all three
mutated after insert. Under DDD the token belongs on the aggregate root, so this is a real
gap in three of the seven.

**Do not add the columns here** — that is 1C's schema change, and
[`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) `P-14` holds the same line. Model the
three aggregates so a token can be added without reshaping them, and route their mutations
through methods that read-then-write rather than blind setters, so the eventual decision
changes the mechanism and not the semantics.

**Decide before the Phase-4 schema freeze.**

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. The QA0 manual walkthrough is the gate.

| Check | Expected |
|---|---|
| Seven roots | Each inherits `Entity`; boundaries match `[SVC §3.2a]` |
| **No new base classes** | No hand-written `Entity`, `ValueObject`, `IBusinessRule` or `CheckRule` |
| `RunReading` | In **no** aggregate; no navigation property from `FlatWireRun` |
| `Rod`, `PassSchedule` | No aggregate, no repository |
| Thirteen value objects | Six alphas + seven quantities, all inheriting `ValueObject` |
| **`RodAlpha("ROD-00041")`** | **Throws** — demonstrate by hand *(`P-23`)* |
| Bay occupancy | Rejects a second rod on the same **physical station** — keyed on `Station`, not `LineId` |
| `Blocked` | **Derived**, never a stored `Status` value |
| Mode P | Carries **null** footage |
| `CoilOutput` | Footage ranges cannot overlap — enforced in the aggregate, not only by the trigger |
| `WipRejection` | Clears a blocked bay **via a domain event**, not by reaching into `RodStaging` |
| Invariant failures | Surface as `BusinessRuleValidationException` → **`422`** |
| Identity | Repositories key on the alpha; no reliance on `==` for unsaved aggregates *(§2.2)* |

---

## 7. Handoff

[`FW-141`](FW-141-Repository-Layer.md) keys its seven repositories on these alphas.
[`FW-142`](FW-142-Dapper-EF-And-FlatWireDbContext.md) maps these aggregates.
`FW-208` dispatches the events they raise. [`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md)
hands over two rules. `FW-146` maps `BusinessRuleValidationException` to `422`.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`D-30`** *(the card's `D1`)* | Three roots with no concurrency token, all mutated after insert. **Before the Phase-4 schema freeze** |
| **`G21`** | Bay uniqueness scope. The index is `UX_RodStaging_Bay` on `([Station],[PayoffPosition]) WHERE Status='Staged'` — **build to the station, not `(LineId, PayoffPosition)`** |
| **`G14`** | Format half **closed by construction** here; the footage `DECIMAL`-vs-`INT` half is not |
| **`OI-42`** | How the `Rod` mirror stays in sync with `coils` |
| **`FR-212`** | Reverting a roll-gap override is Operations-Manager-only — an invariant of `FlatWireRun`, and the reason MVP-1 still reaches into MVP-2 for that role definition |
| **`G41`** ⚠ | **Its stated resolution names this story.** `CK_PSC_FM1NotBypassable` is **line-blind** — `CHECK ([ComponentName] <> 'FM1' OR [State] = 'Active')` applies to every schedule on every line, but `Stand.Id 1` is `FM1`/`LineId = 'FL1'` and an **FL2-standalone** run is fed an already-flattened spool, so FL1's 12″ mill is not in that material path. Every FL2 schedule must therefore mark `FM1` **Active**, engaging a stand the line does not have. **A `CHECK` cannot express the fix** — it would have to reach `PassSchedule.LineId` across the row — so it is either a denormalised column or **a validator in the domain model, and `[GAP]` points at this story's `IBusinessRule` set**. ⚠ **Do not generalise it** into *"a component's `Stand.LineId` must equal its schedule's `LineId`"*: that returns **18 rows** and most are legitimate — an **FL3** schedule drives `FM1` *and* `FM2_S1..S3` because FL3 **is** FL1 feeding FL2. **Do not add a trigger** — `[TRP §8]` publishes *"1 trigger"* as a verified count |
| **`G42`** ⚠ | **`SpoolProcessing` cannot represent multi-rod genealogy**, and the weld descope hides it. `SpoolProcessing` carries `ParentRodAlpha` and `SourceRodAlpha` — two **single-rod** columns, the second documented as the *partial-run* source (`Q12`), not a second contributor — and **there is no child table**. `CoilTraceability` is **coil**-level and hangs off `CoilOutput`. So there is nowhere to record *"this spool came from rods R00041 and R00042, at these footage positions"*. **High, and an MVP-1 obligation** — the welding-wire customer certificates are produced from that genealogy (`NFR012`), and a 1,800 lb spool routinely consumes more than one rod. `FW-202`'s own criterion already reads *"source rods from the run's `WeldEvent` chain"*, **plural**, against a schema that holds one. ⚠ **Raise it while it is free**: with weld capture out of the trial nothing writes the table, so a `SpoolTraceability` child is a DDL file and a domain type; after weld capture returns it is a migration plus a backfill against certificate data |

| Stale | Correct | Source |
|---|---|---|
| Blockers: *"**`D1`** open"* | **`D-30`** — renumbered 15 Aug 2026, promoted to `[ARC §13.1]` | `[SVC §3.4]` |
| AC 3: *"`PassSchedule` is **MVP-2-owned**"* | **MVP-1 owns the tables** since `D-31`; the **read-model** status is what still holds | `D-31`, `[SVC §3.2a]` |
| Any artifact showing **four** FM2 stands, a separate `8" Roller`, or `FM2_6inS3` | **Three** — `FM2_S1`/`S2`/`S3` | `D-26`, master spec §10.2 |
