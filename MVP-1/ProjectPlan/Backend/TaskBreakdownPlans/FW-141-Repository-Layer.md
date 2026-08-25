# FW-141 · Repository layer — one per aggregate root

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **the story card's repository list is superseded (§2.1)**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-141`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** **The story card's acceptance criteria name the wrong
> repositories.** It asks for `PassScheduleRepository`, `RodRepository`, `RunRepository`,
> `CoilRepository` *"and siblings"*; `phase-01b` L85 and `[SVC §3.2a]` say **seven, one per
> aggregate root**, and that **`Rod` and `PassSchedule` get none at all**. Two of the four
> named repositories must not be built.
>
> The second correction is subtler and easier to get wrong at the keyboard: repositories are
> keyed on the **alpha value object**, not `int Id`. The surrogate is not the identity.

---

## 1. The story

From `[TB §7]` — verbatim, **including the superseded criteria**:

> ###### FW-141 · Repository layer — one per aggregate root
> **Hours:** 28 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** developer,
> **I want** repositories behind interfaces for each aggregate,
> **So that** handlers never touch a connection directly.
>
> **Acceptance Criteria:**
> - [ ] `FlatWire.Infrastructure/Repositories/` with `PassScheduleRepository`, `RodRepository`, `RunRepository`, `CoilRepository` and siblings, each behind an interface
> - [ ] `RodRepository` reads the shared `coils` table (cross-database, unenforced link)
> - [ ] Unit tests cover each repository against the seeded fixtures
>
> **Rate-card basis:** 5 repositories @ 4 h = 20 h (§2, table rate covers repository)
> **Dependencies:** FW-N04, FW-006
> **Blockers:** **G17** (rod→`coils` multiplies cross-DB logical FKs)

**The title is right and the criteria are stale.** *One per aggregate root* is the rule;
the four names predate `D-29` and the seven-root boundary table. Build to §2.

---

## 2. What to build instead

### 2.1 Seven repositories, and three deliberate absences

`phase-01b` L85 and `[SVC §3.2a]`:

| Repository | Aggregate root | Keyed on |
|---|---|---|
| `IFlatWireRunRepository` | `FlatWireRun` | `RunAlpha` |
| `IRodStagingRepository` | `RodStaging` | bay / `RodAlpha` |
| `IWeldEventRepository` | `WeldEvent` | — *(its own root; welds are recorded at pre-check-in, **before a run exists**)* |
| `ISpoolRepository` | `SpoolProcessing` | `SpoolAlpha` |
| `ICoilOutputRepository` | `CoilOutput` | `CoilAlpha` |
| `IRodCheckoutRepository` | `RodCheckout` | — |
| `IWipRejectionRepository` | `WipRejection` | — |

⚠ **`RunReading`, `Rod` and `PassSchedule` get NO repository.** They are read models:

- **`RunReading`** — 10 Hz time series, append-only, read by Dapper through
  `sp_GetGaugeTrace`. `[SVC §3.2a]` calls its exclusion *"the most important exclusion in
  this design"*: inside `FlatWireRun` it would materialise thousands of rows on every
  command.
- **`Rod`** — a `FlatWireDB`-local mirror of `coils` (`D-04`); `coils` owns the lifecycle.
- **`PassSchedule`** — a read model. `D-31` moved the tables into MVP-1 and made
  `PassScheduleId` a real FK, but **MVP-1 reads schedules and never authors them**, so there
  is no aggregate, no repository and no write path.

**So `PassScheduleRepository` must not be built**, and `RodRepository` is not a repository —
see §2.2.

### 2.2 Rod data access is real, and it is Dapper

Dropping `RodRepository` does not drop the work. `phase-01b` L60, L69:

- reads `united_db..planning_routings` — **genuinely cross-database**, and the columns are
  **unmapped** (`OI-33`)
- reads the shared `coils` table
- **writes** `actual_start_date` back to `planning_routings` **and** `routings` (`FR-077`)

All via Dapper on `IContextRepository`, not through an aggregate repository. Follow
`[DBD §6.6]`: `united_db..alloys` is surfaced as a view named `Alloys` in the consuming
databases — *"one place to absorb mismatches rather than repeating them at every call
site."*

> ⚠ **Only `planning_routings` is still cross-database.** The pass-schedule read became a
> **local** query under `D-31`, so *"the pass schedule read is cross-database"* is stale
> wherever it survives.

### 2.3 The alpha is the identity

`[SVC §3.2a]`:

> ⚠ **The surrogate is not the identity.** `FlatWireRun` carries both `[Id] INT IDENTITY`
> and `[RunId] VARCHAR(20)` — and it is `RunId` that every child table references. […] So
> **repositories are keyed by the alpha value object** — `GetByAlpha(RunAlpha)`, not
> `GetById(int)`.

Same on `SpoolProcessing` (`Alpha`) and `CoilOutput` (`CoilAlpha`).

> ⚠ **And the trap inside the trap:** `Entity.Equals()` and `IsTransient()` operate on `Id`,
> so **equality is surrogate-based**. Two instances with the same alpha do **not** compare
> equal before both are persisted. Do not write a `Contains`/`Distinct`/dictionary-key path
> that assumes they do.

---

## 3. Precedence

| Question | Authority |
|---|---|
| How many repositories, and for what | `phase-01b` L85, `[SVC §3.2a]` |
| Aggregate boundaries and invariants | `[SVC §3.2a]` |
| Interfaces in Domain, implementations in Infrastructure | `[SVC §3.1]`, `[SVC §3.2]` |
| Base types to inherit | `UA.Framework.Domain` — **do not write new ones** |

---

## 4. Build order

1. **Interfaces in `FlatWire.Domain/Repository/`.** `[SVC §3.2]` puts repository
   *interfaces* in Domain and implementations in Infrastructure; Domain must contain no
   persistence concern.
2. **Inherit the framework base.** `CoilCheckin` has
   `GenericRepository<T, TContext> : EntityRepositoryBase<TContext, T>` with
   `where T : Entity`, exposing `IUnitOfWork UnitOfWork => (IUnitOfWork)context`.
   `IGenericRepository<T>` derives from `IRepository<T>` in
   `UA.Framework.Domain.Repository`. **Do not write a new base repository.**
3. **Seven concrete repositories** in `FlatWire.Infrastructure/Repositories/`, each with a
   `GetByAlpha(...)` accessor typed to its alpha value object (`FW-207` supplies the types).
4. **`ContextRepository` for Dapper**, ported from `CoilCheckin` — `DBQueryHelper` from
   `UA.Framework.Infrastructure.Helpers`, constructed from `IOptions<SqlSetting>`. This is
   where rod, gauge-trace and list-grid reads live.
5. **Register** in `AddPersistence` — the open generic plus the seven.
6. **Rod access via Dapper** per §2.2, including the `actual_start_date` write-back.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-11` precede this story.

### `P-12` — build the seven; do not build `PassScheduleRepository` or `RodRepository`

The card's four names are superseded by `phase-01b` L85 and `[SVC §3.2a]`, both later and
both narrower. Building a `PassScheduleRepository` would create a write path into a table
MVP-1 must not author (`OI-110` already records that **nothing in MVP-1 populates it in
production**); building a `RodRepository` as an aggregate repository would imply `Rod` is a
root, which `D-04` and `[SVC §3.2a]` both say it is not.

**Rod work is not cancelled — it is relocated** to Dapper on `IContextRepository` (§2.2), and
it is the most externally-coupled data access in the service.

**Hours:** the card prices *"5 repositories @ 4 h = 20 h"* against a 28 h header, and the
real count is seven. **No hour cell is restated here** — the note in
[`FW-N04 §1.2`](FW-N04-FlatWire-Solution-Skeleton.md) explains why. Flagged in §7.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes the card's third criterion
outright. Verified in the QA0 manual walkthrough against the seeded fixtures.

| Check | Expected |
|---|---|
| Repository count | **Seven**, one per aggregate root |
| Absences | No `PassScheduleRepository`; no `RodRepository`; nothing for `RunReading` |
| Keying | Every accessor takes an alpha value object; **no public `GetById(int)`** |
| Interfaces | All seven in `FlatWire.Domain/Repository/`; implementations in Infrastructure only |
| Base types | No hand-written `Entity`, `ValueObject` or base repository |
| Rod access | Reads `coils` and `united_db..planning_routings`; writes `actual_start_date` to `planning_routings` **and** `routings` |

---

## 7. Handoff

`FW-142` supplies `FlatWireDbContext` and the Dapper wiring these sit on; `FW-207` supplies
the alpha value objects the accessors are typed to. Both converge with 1C — this story's
`Dependencies` include `FW-006`.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`G17`** *(the card's blocker)* | Rod → `coils` multiplies cross-DB logical FKs. Unenforced by design; the `Rod` mirror is what lets the **local** rod-alpha FKs be enforced (`D-04`, `[ARC §13.1]`) |
| **`OI-33`** | **`planning_routings` columns are unmapped** and rod access is built against them. The single largest unknown in this story |
| **`D-30`** | `ROWVERSION` is absent on the `WeldEvent`, `RodCheckout` and `WipRejection` roots, all three mutated after insert. Decide before the Phase-4 schema freeze; it changes these three repositories' update paths |
| **`G21`** | `RodStaging` bay uniqueness is keyed on the **physical station** (`UX_RodStaging_Bay` on `([Station],[PayoffPosition]) WHERE Status='Staged'`), **not** `(LineId, PayoffPosition)` |

| Stale | Correct | Source |
|---|---|---|
| AC 1: `PassScheduleRepository`, `RodRepository`, `RunRepository`, `CoilRepository` | **Seven, one per aggregate root**; `Rod`/`PassSchedule`/`RunReading` get none | `phase-01b` L85, `[SVC §3.2a]` |
| AC 3: *"Unit tests cover each repository"* | Withdrawn 15 Aug 2026 | `[TS §1.2]` |
| Rate-card basis: *"5 repositories @ 4 h = 20 h"* | Seven repositories against a **28 h** header | The header is the later figure; the basis line was not restated |
| *"the pass schedule read is cross-database"* | **Local** since `D-31` | `phase-01b` L63–67 |
