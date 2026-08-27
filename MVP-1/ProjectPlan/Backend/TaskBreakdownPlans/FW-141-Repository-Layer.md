# FW-141 · Repository layer — one per aggregate root

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — ✅ **BUILT.** Steps 2-3 and 5 completed once `FW-142` landed `FlatWireDbContext`: seven `sealed` repositories, all registered, **13/13 accessors verified against live `FlatWireDB`** in a rolled-back transaction (§6.2). Three findings: `GenericRepository` is **not** a framework type (every domain carries its own), `EntityRepositoryBase` implements **no interfaces**, and the `==` in the alpha predicates is **reference equality in C#** that works only because EF translates it. **`P-71`** minted - no `IGenericRepository<,>`, because declaring it would put EF back in Domain against `P-67`. Earlier: August 26, 2026 — ✅ **PARTLY BUILT.** Steps 0, 1, 4 and half of 5 are in `ual-api`: the **six alphas**, the **seven structural roots**, the **seven repository interfaces**, `IContextRepository`/`ContextRepository` and its registration. **Steps 2–3 and the EF half of step 5 wait on `FW-142`.** §6.1 carries the measured verification — including that `RodAlpha("ROD-00041")` now **throws at startup**, which moves `G14`'s format half from *closed-by-design, unverified* to verified. Earlier the same day — ⚠ **corrected against the code that now exists.** §2's judgement survives intact; the **build order does not** — it could not be executed as written. `IGenericRepository<T>` **does not exist** (it takes two type parameters); §6's keying check **contradicted** §4 step 2; deriving from the mandated generic would have put **EF in the Domain layer**, which §4 step 1 forbids; and the story was marked *Ready* while every folder it needs is empty. Three decisions minted — **`P-66`** folds the structural Domain minimum in from `FW-207`, **`P-67`** derives the seven from `IRepository<T>`, **`P-68`** forbids the inherited int-keyed accessor by use rather than by absence *(previously August 15, 2026 — first issue)*
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **BUILT and verified, 27 Aug 2026** (§6.1, §6.2) — all seven repositories are delivered and registered, and **every accessor was exercised against live `FlatWireDB`**. ⚠ **Step 6 still waits on `OI-33`**; the open generic is **not built, by `P-71`**
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
>
> **The third was added 26 Aug 2026 and is the one that stops the keyboard entirely: there is no
> per-aggregate repository anywhere in `ual-api` to copy.** `CoilCheckin.Domain/Repository/` holds
> exactly two files — `IContextRepository` and `IGenericRepository` — and the generic one is
> **registered and never consumed**: the only reference to it outside its own definition is the
> `AddScoped` line. The template does all real data access through **Dapper on
> `IContextRepository`**. These seven will be the first genuinely-used EF repositories in the
> codebase, which is why §4 spells out shapes a reference implementation would normally supply.

---

> ### ⚠ Coding standard — read `[SVC §3.4a]` before writing code
>
> The repository C# standard binds every `.cs` file here, and `[SVC §3.4a]` records the **four
> standing divergences** so they are not re-litigated in review. What this story owns:
>
> **Interfaces carry no persistence type.** `[SVC §3.2]` bars persistence concerns from Domain, and
> the obvious base — `IGenericRepository<T, TContext>` — is constrained `where TContext : DbContext`,
> so deriving from it drags `Microsoft.EntityFrameworkCore` into the Domain project. `P-67` derives
> from `IRepository<T>` instead. **If you find yourself adding a `using Microsoft.EntityFrameworkCore;`
> to anything under `FlatWire.Domain/`, stop.**
>
> **Every repository is `sealed`**, every accessor is `Async`-suffixed and takes a
> `CancellationToken`, and **no accessor this story adds takes an `int`** (`P-68`).

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

### 1.1 ⚠ The dependency line is incomplete — corrected 26 Aug 2026

`Dependencies: FW-N04, FW-006` names neither of the two stories this one cannot compile without.
Measured in `ual-api` on 26 Aug 2026, **all five folders this story writes into exist and all five
are empty**: `FlatWire.Domain/AggregatesModel/`, `ValueObjects/`, `Repository/`,
`FlatWire.Infrastructure/Repositories/` and `Context/`.

| Also depends on | For what | Gates |
|---|---|---|
| **`FW-207`** | The seven roots as `Entity`, and the six alphas the accessors are typed to | — *see `P-66`* |
| **`FW-142`** | `FlatWireDbContext` — `GenericRepository<T, TContext>` is constrained `where TContext : DbContext` | **steps 2–6** |
| `FW-006` *(1C)* | The tables these read | steps 3–6 |

**`P-66` resolves the `FW-207` half rather than waiting on it**: this story now authors the
*structural* minimum itself, so **step 1 is unblocked**. `FW-142` remains a hard prerequisite for
everything after it. Until then the board's *"twelve unlock at once"* does not include this story's
implementation half — only its interfaces.

---

## 2. What to build instead

### 2.0 What this story now authors — the `FW-207` seam (`P-66`)

This story used to wait on `FW-207` for every type its signatures name. It now **folds in the
structural minimum and leaves the behavioural half where it was.** The seam is a test, not a
judgement call:

> **A Domain type belongs to this story only if a repository signature names it, or the base-class
> constraint requires it. Everything else stays `FW-207`'s.**

| Folded in here | Stays `FW-207`'s |
|---|---|
| The **seven roots** as `Entity`-derived classes carrying their persisted properties — `GenericRepository<T, TContext>` is constrained `where T : Entity` | Aggregate **behaviour**, and invariants as `IBusinessRule` → `CheckRule` → **`422`** — including `G21` bay occupancy |
| The **six alphas** with validating constructors — `RodAlpha`, `SpoolAlpha`, `RunAlpha`, `CoilAlpha`, `DieAlpha`, `PassScheduleReference`. **Four of the seven repositories key on one of these; the other three do not have an alpha at all** — §4 step 3 | The **seven dimensioned quantities** — `Gauge`, `Width`, `Footage`, `WeightLb`, `SpeedFpm`, `RollGap`, `RollDiameter` — and **`PassScheduleSnapshot`** |
| | **Domain events**, and the two rules `FW-147`'s `P-19` hands over |

⚠ **Two of the six alphas fail the test above, and are folded in anyway — by cohesion, as a named
exception.** `DieAlpha` and `PassScheduleReference` are named by **no** repository signature: `P-12`
builds neither a `DieRepository` nor a `PassScheduleRepository`, so on the test alone they would
stay with `FW-207`. They travel with the other four because the six are **one family** — one source
in `[BR §3]`, one base class, one review — and splitting them so `RodAlpha` lands here and
`DieAlpha` next door would cost more than the exception. **The test still governs everything else**;
it is recorded as an exception rather than quietly widened, because a sharp test is the whole value
of `P-66`.

**Nothing is authored twice.** `FW-207`'s two deliberately-unverifiable criteria are untouched by
the move: `RodAlpha("ROD-00041")` must still throw, which is what closes **`G14`**'s format half,
and it travels with the alphas; the **`G21`** bay rule stays with `FW-207` because it is an
invariant, not a signature.

⚠ **The CHILD entities are not folded in, and that is the seam test applying, not an oversight.**
`[SVC §3.2a]` puts seven children inside `FlatWireRun` — `FlatWireRunDetail`, `RodCheckin`,
`SpoolCheckin`, `RunPauseEvent`, `RollOverride`, `DieChangeEvent`, `SpcCheckpoint` +
`SpcMeasurement` — and `CoilTraceability` inside `CoilOutput`. **No repository signature names any
of them**, so by the test they stay with `FW-207`, whose §2 is the boundary table of record. What
lands here is each root's own columns and nothing below it. **A root therefore has no navigation
collections yet**, and a repository cannot return a loaded aggregate until `FW-207` adds them.

⚠ **A structural root is not a finished aggregate.** What lands here is enough for EF to map and
for a repository to return — properties, the alpha, the surrogate. It has no behaviour and enforces
nothing. **Do not let a handler mutate one directly** because the invariants have not arrived yet;
that is precisely the bypass `D-29` exists to prevent.

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

⚠ **`ISpoolRepository` names the `SpoolProcessing` root on purpose — do not "fix" it.** `Q60` swapped the two table names on 23 Aug 2026 (`Spool` is now the reusable stencilled article; `SpoolProcessing` is the material in process), and it **deliberately left the code identifiers out of scope** — `SpoolController`, `ISpoolRepository`, the `SP-#####` alpha and the endpoint paths all keep the operator's word. The four child tables keep their `Spool…` prefix for the same reason. `[DBD §6.2a]` is the place that says which of the three things named "spool" is which.

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

⚠ **The quotation names three roots, and it is true of four — not of all seven.** `WeldEvent`,
`RodCheckout` and `WipRejection` have **no alpha of their own**; each is identified by its own
`VARCHAR(20)` business key. The principle is unchanged and is the one that matters — *the surrogate
is never the identity* — but the parameter type is not always an alpha. §4 step 3 has the per-repository table.

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
| A per-aggregate repository to copy | ⚠ **There is none.** `CoilCheckin.Domain/Repository/` holds only `IContextRepository` and `IGenericRepository`, and the generic one is **registered but never consumed** — the template's real data access is Dapper. §4 is therefore prescriptive where it would normally just point |

---

## 4. Build order

0. **The structural Domain minimum** — `P-66`, §2.0. The six alphas first (the signatures are
   typed to them), then the seven roots as `Entity`-derived classes. This step did not exist
   before 26 Aug 2026; without it step 1 cannot be typed.
1. **Interfaces in `FlatWire.Domain/Repository/`,** deriving from **`IRepository<T>`** — `P-67`.
   `[SVC §3.2]` puts repository *interfaces* in Domain and implementations in Infrastructure, and
   **Domain must contain no persistence concern** — which is exactly why they do not derive from
   `IGenericRepository<T, TContext>`; see step 2.

   ```csharp
   // FlatWire.Domain/Repository/IFlatWireRunRepository.cs - no EF type is named
   public interface IFlatWireRunRepository : IRepository<FlatWireRun>
   {
       /// <summary>Reads a run by its alpha - the identity, not the surrogate.</summary>
       Task<FlatWireRun?> GetByAlphaAsync(RunAlpha alpha, CancellationToken cancellationToken);
   }
   ```

   **`IContextRepository` goes here too**, beside the seven — `CoilCheckin` puts it in
   `CoilCheckin.Domain/Repository/` and its implementation in Infrastructure. Step 4 builds that
   implementation.
2. **Inherit the framework base — in Infrastructure only.** The real declaration, which the
   earlier text got wrong, is:

   ```csharp
   public class GenericRepository<T, TContext>
       : EntityRepositoryBase<TContext, T>, IGenericRepository<T, TContext>
       where T : Entity
       where TContext : DbContext
   ```

   ⚠ **`IGenericRepository` takes TWO type parameters.** This plan said `IGenericRepository<T>`
   until 26 Aug 2026; there is no such type, and the one-parameter form is a compile error. The
   one-parameter interface is `IRepository<T>`, in `UA.Framework.Domain.Repository`, and that is
   what step 1 derives from. **Do not write a new base repository.**
3. **Seven concrete repositories** in `FlatWire.Infrastructure/Repositories/`, each `sealed`:

   ```csharp
   public sealed class FlatWireRunRepository
       : GenericRepository<FlatWireRun, FlatWireDbContext>, IFlatWireRunRepository
   ```

   The base supplies CRUD and `IUnitOfWork`; **the identity-keyed accessor is the only thing these
   seven add, and it is their entire justification** — the open generic already covers everything
   else, which is why the template never needed a per-aggregate repository (§3).

   ⚠ **Only four of the seven key on one of the six alphas. Do not write `GetByAlphaAsync` on the
   other three** — §2.1's `—` means *no alpha of its own*, not *nothing to key on*, and this plan
   said *"each with a `GetByAlphaAsync`"* until it was re-read on 26 Aug 2026.

   | Repository | Its identity | Also queried by |
   |---|---|---|
   | `IFlatWireRunRepository` | `RunAlpha` | — |
   | `IRodStagingRepository` | `RodAlpha` + bay | `Station` (`G21`) |
   | `ISpoolRepository` | `SpoolAlpha` | — |
   | `ICoilOutputRepository` | `CoilAlpha` | — |
   | `IWeldEventRepository` | **`WeldEventId`** `WLD-###` | `RunAlpha`, and both `RodAlpha`s — outgoing and incoming |
   | `IRodCheckoutRepository` | **`CheckoutId`** `CO-####` | `RodAlpha`; `RunAlpha` **nullable** — Mode P has no run |
   | `IWipRejectionRepository` | **`RejectionId`** `REJ-####` | `MaterialAlpha`; `RunAlpha` **nullable** — a pre-run rejection has none |

   ⚠ **`WipRejection.MaterialAlpha` cannot be typed to an alpha value object at all.** It is
   **polymorphic — rod *or* spool — with no FK and no discriminator (`OI-20`)**, so its accessor
   takes a `string` until that is resolved. Typing it to `RodAlpha` would silently exclude spools.
4. **`ContextRepository` for Dapper**, ported from `CoilCheckin` — `DBQueryHelper` from
   `UA.Framework.Infrastructure.Helpers`, constructed from `IOptions<SqlSetting>`. This is
   where rod, gauge-trace and list-grid reads live.
5. **Register** in `AddPersistence` — the open generic plus the seven.

   ⚠ **`AddPersistence` already exists.** `FW-140` built it on 26 Aug 2026 at
   `FlatWire.Infrastructure/DependencyInjectionRegistry.cs`, and left the hook in place:

   ```csharp
   // FW-141 registers the repository open generic and the seven repositories here.
   // FW-142 registers FlatWireDbContext here - and must NOT re-add IMediator (P-51).
   ```

   Register **into** it; do not create a second one. The open generic is registered
   `typeof(IGenericRepository<,>)` — two parameters, per step 2. **Do not register `IMediator`**:
   `P-51` put it in `Program.cs` and a second descriptor is a duplicate registration.
6. **Rod access via Dapper** per §2.2, including the `actual_start_date` write-back.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; **`P-01`–`P-65` precede this story** — `P-01`–`P-05`, `P-50`, `P-51` in `FW-N04`; `P-06`–`P-08`, `P-52`–`P-58` in `FW-138`; `P-09`, `P-10`, `P-59`–`P-61` in `FW-139`; `P-11`, `P-62`–`P-65` in `FW-140`. New here at **`P-66`**.

### `P-12` — build the seven; do not build `PassScheduleRepository` or `RodRepository`

The card's four names are superseded by `phase-01b` L85 and `[SVC §3.2a]`, both later and
both narrower. Building a `PassScheduleRepository` would create a write path into a table
MVP-1 must not author (`OI-110` already records that **nothing in MVP-1 populates it in
production**); building a `RodRepository` as an aggregate repository would imply `Rod` is a
root, which `D-04` and `[SVC §3.2a]` both say it is not.

**Rod work is not cancelled — it is relocated** to Dapper on `IContextRepository` (§2.2), and
it is the most externally-coupled data access in the service.

---

### `P-66` — fold the structural Domain minimum in; leave the behaviour with `FW-207`

§2.0 carries the seam and the table. The decision itself is that **this story stops waiting**: it
authors the seven roots' structure and the six alphas, because every one of them is named in a
signature it owns, and a story blocked on another story for its own type declarations is not
schedulable.

**Why not simply wait for `FW-207`.** Both are wave-1, both are `Critical`, and the board lists
them among *"twelve that unlock at once."* If this one waits, the parallelism is fictional and the
dependency is invisible — which is exactly the state found on 26 Aug 2026, with the row reading
*Ready* over five empty folders.

**Why not fold in more.** Taking the invariants too would leave `FW-207` with nothing but domain
events, and would put business rules in a story whose reviewer is checking data access. The seam is
drawn where the *compiler* draws it: signatures and constraints.

**The one exception, stated rather than hidden.** `DieAlpha` and `PassScheduleReference` are named
by no signature here — there is no Die repository and no `PassScheduleRepository` (`P-12`) — so the
test would leave them with `FW-207`. They are folded in **by cohesion**: six alphas from one
`[BR §3]` source sharing one base class, split across two stories, is worse than one recorded
exception. Nothing else is admitted this way.

⚠ **`FW-207`'s hours are not reduced here and this story's are not raised.** Both figures are
quoted by `[CE]`, `[DE]`, `[SSP]`, `[TRP]` and `[TB §7]`. The transfer is recorded in §8 as owed to
the re-baseline, exactly as `FW-138`'s 42 h and `FW-140`'s understatement are.

---

### `P-67` — the seven derive from `IRepository<T>`, not `IGenericRepository<T, TContext>`

**Because the obvious base puts EF in the Domain layer.** `IGenericRepository<T, TContext>` is
constrained `where TContext : DbContext`, so its own file carries
`using Microsoft.EntityFrameworkCore;` — and in `CoilCheckin` that file sits in **`CoilCheckin.Domain`**.
`[SVC §3.2]` says Domain must not contain *"persistence concerns"*, which §4 step 1 quotes while the
old step 2 mandated the type that breaks it.

`FlatWire.Domain.csproj` **already carries the EF package reference**, inherited from the `FW-N04`
scaffold and currently unused by a single line of code. Deriving from `IGenericRepository` would
make it load-bearing and close off ever removing it.

`IRepository<T>` takes one parameter, lives in `UA.Framework.Domain.Repository`, and gives the seven
everything the aggregate root needs. Two further benefits fall out: **step 1 no longer needs
`FW-142`** — no `DbContext` type is named in Domain at all — and the implementations still inherit
`GenericRepository<T, FlatWireDbContext>`, so *"do not write a new base repository"* is honoured.

---

### `P-68` — the inherited int-keyed accessor is forbidden by **use**, not by absence

`IRepository<TEntity>` declares **`ValueTask<TEntity> GetAsync(int id)`** and
`EntityRepositoryBase` implements `Get(int)` / `GetAsync(int)` as `public virtual`. Inheriting the
framework base therefore **guarantees** a public int-keyed accessor on every one of the seven.

§6 used to ask a reviewer to confirm *"no public `GetById(int)`"*. Literally that passes — nothing
is called `GetById` — but the intent behind it cannot be met while step 2 stands, and a reviewer
reading it as intent will hunt for something that cannot be removed. Shadowing the members with
`new` was considered and rejected: shadowing a framework member surprises at any base-typed call
site, which is a worse trap than the one being closed.

**The enforceable rule:** no accessor this story *adds* takes an `int`, and **no handler calls the
inherited one**. The identity is the alpha; the surrogate is EF's.

⚠ The companion trap in §2.3 is unchanged and is the reason this matters in practice:
`Entity.Equals()` and `IsTransient()` operate on `Id`, so **two instances with the same alpha do
not compare equal before both are persisted.**

**Hours:** the card prices *"5 repositories @ 4 h = 20 h"* against a 28 h header, and the
real count is seven. **No hour cell is restated here** — the note in
[`FW-N04 §1.2`](FW-N04-FlatWire-Solution-Skeleton.md) explains why. Flagged in §7.

### `P-71` — build **no** `IGenericRepository<T, TContext>`, and register no open generic

**Found at the keyboard, 27 Aug 2026.** §4 step 5 says to register the open generic
`typeof(IGenericRepository<,>)`. Doing so requires declaring the interface, and the sibling copies
declare it in their **Domain** project constrained `where TContext : DbContext` — which puts
`Microsoft.EntityFrameworkCore` in Domain against `[SVC §3.2]`.

**That is precisely what `P-67` refused for the seven interfaces, and the reasoning does not stop at
them.** Building it would re-activate the EF package reference `P-67` left dead in `Domain.csproj`
and undo the layering that decision exists to protect.

**Resolution: it is not built.** `GenericRepository<T, TContext>` lives in **Infrastructure**,
inherits `EntityRepositoryBase<TContext, T>` and implements `IRepository<T>` — one type parameter,
no EF type named in Domain. The seven inherit it and are registered individually.

**Nothing is lost.** §3 already records that in `CoilCheckin` the open generic is **registered and
never consumed** — the only reference to it outside its own definition is the `AddScoped` line.
Registering an interface no code resolves is not a capability.

⚠ **If a future story genuinely needs an open-generic repository**, declare the interface in
**Infrastructure**, not Domain.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026, which strikes the card's third criterion
outright. Verified in the QA0 manual walkthrough against the seeded fixtures.

| Check | Expected |
|---|---|
| Repository count | **Seven**, one per aggregate root |
| Absences | No `PassScheduleRepository`; no `RodRepository`; nothing for `RunReading` |
| Keying (`P-68`) | Every accessor **this story adds** takes a **business identity** — one of the six alphas for four of the seven, its own `VARCHAR(20)` id for the other three (§4 step 3) — and is `Async`-suffixed. `Get(int)`/`GetAsync(int)` **are present and cannot be removed** — they arrive from `IRepository<T>`. The check is that **no handler calls them** |
| **No EF in Domain** (`P-67`) | `grep -r "Microsoft.EntityFrameworkCore" FlatWire.Domain/` returns **nothing** outside the `.csproj`. If an interface names a `DbContext` type, it derived from the wrong base |
| **The fold-in is complete** (`P-66`) | The six alphas and seven `Entity`-derived roots exist and compile; `RodAlpha("ROD-00041")` **throws**. No dimensioned quantity, no `IBusinessRule` and no domain event was authored here — those are `FW-207`'s |
| **`AddPersistence` was extended, not replaced** | One `DependencyInjectionRegistry.cs`; the open generic registered as `typeof(IGenericRepository<,>)`; **no second `IMediator` descriptor** |
| Interfaces | All seven in `FlatWire.Domain/Repository/`; implementations in Infrastructure only |
| Base types | No hand-written `Entity`, `ValueObject` or base repository |
| Rod access | Reads `coils` and `united_db..planning_routings`; writes `actual_start_date` to `planning_routings` **and** `routings` |

### 6.1 What the build actually verified — 26 Aug 2026

Built in `ual-api` at `API/Domain/FlatWire/`. **0 errors; 18 warnings, and all 18 are the
pre-existing set** (10 `S112`, 8 `NU1506`) — measured with `--no-incremental` against nothing
running.

| Step | Result |
|---|---|
| **0** · structural Domain minimum (`P-66`) | ✅ **6 alphas** in `ValueObjects/Alphas.cs`, **7 roots** in `AggregatesModel/`, one file each |
| **1** · seven interfaces (`P-67`) | ✅ in `Domain/Repository/`, one file each, plus `IContextRepository` |
| **2** · inherit the framework base | — guidance only; nothing to build |
| **3** · seven concrete repositories | ✅ **Built 27 Aug 2026** — see §6.2 |
| **4** · `ContextRepository` for Dapper | ✅ built, with `sp_GetGaugeTrace` implemented |
| **5** · register in `AddPersistence` | ✅ **complete 27 Aug 2026** — `IContextRepository` plus the seven. ⚠ **No open generic — `P-71`** |
| **6** · rod access via Dapper | ⚠ **BLOCKED on `OI-33`** — the `planning_routings` columns are unmapped, and declaring a signature against columns nobody has named would be inventing them |
| `P-67` holds | ✅ **zero** `using Microsoft.EntityFrameworkCore` and **zero** EF type uses in Domain code. The package reference is still in `Domain.csproj` and is now dead — droppable, as `P-67` predicted, but not this story's to drop |
| `P-68` holds | ✅ **no int-keyed accessor added**; the inherited `Get(int)`/`GetAsync(int)` remain and no caller uses them |
| Reference graph | ✅ unchanged — `Infrastructure → Domain` only |
| No regression | ✅ FW-138 probe **61/61**, and all **65** response bodies **byte-identical** to the pre-FW-141 snapshot |

**`G14`'s format half is now verified rather than asserted.** `FW-207`'s `P-23` records
`RodAlpha("ROD-00041")` as *closed by design, unverified*, because the backend test suite was
withdrawn and nothing exercised it. `Program.cs` now constructs exactly that malformed alpha at
startup (Development only) and **requires** the throw, so a future relaxation of the pattern breaks
the boot with a named reason instead of quietly re-opening the gap that
`PartialRodReCheckin.md`'s worked examples came from.

**Four things the framework did not do that the plan assumed.**

**(1) `DBQueryHelper` has no `QueryMultipleAsync`.** The multi-result-set method is
`ExecuteSPReturnGridReaderAsync(spName, parameters, params Func<GridReader, object>[] readerFuncs)`,
returning `List<object>` — one entry per reader func, in declaration order. The funcs must fully
materialise, because the helper disposes the connection when it returns.

**(2) `DBQueryHelper` threads no `CancellationToken`.** `IContextRepository` accepts one for
contract consistency and it is **not honoured**; widening the framework helper is not this story's
to do. Server-side decimation is what keeps the trace short.

**(3) `sp_GetGaugeTrace` returns two result sets whose column names are not the contract's** —
`FootageFt` against `Footage`, `GaugeIn` against `Gauge`. A stored procedure cannot be aliased at
the call site, so two private row types map the shapes explicitly.

**(4) Those row types cost 32 analyzer warnings** — `S3459` *unassigned auto-property* and `S1144`
*unused private type*, because **Dapper populates them by reflection** and they appear only as
generic type arguments. Suppressed with the reason recorded in the file, exactly as `FW-139`
suppressed `S1144` on its Scrutor-resolved handlers. Making them public to quiet the rule would put
a storage-shaped type on the Domain surface, which is worse.

### 6.2 Steps 2–3 and 5 — built 27 Aug 2026, once `FW-142` landed

`FlatWireDbContext` exists, so the blocked half was completed the same day. **0 errors; warning set
unchanged at 13, all pre-existing** *(the 18 figure above was measured before `FW-140`'s fixture
deletions; the set is the same, the count is not)*.

**Seven `sealed` repositories** in `FlatWire.Infrastructure/Repositories/`, each
`GenericRepository<T, FlatWireDbContext>` + its Domain interface, and **all seven registered** in
`AddPersistence`. **Every accessor was exercised against live `FlatWireDB`** inside a rolled-back
transaction — 13 checks, all passing, including both sides of the weld genealogy and a negative
control returning `null`:

| Verified | |
|---|---|
| The four alpha-keyed accessors | `FlatWireRun`, `RodStaging`, `CoilOutput` *(and `SpoolProcessing` by construction — its table is not deployed)* |
| The three business-key accessors | `WeldEventId`, `CheckoutId`, `RejectionId` — plain strings, as §2.1 requires |
| `WeldEvent.GetByRodAsync` matches **both** sides | outgoing **and** incoming each return the weld — the `||` that makes the customer-certificate genealogy complete |
| `RodStaging.GetByStationAsync` | keyed on the physical `Station`, `G21` left open |
| `UnitOfWork` | reference-equal to the context, so a handler commits through the repository |
| Negative control | a non-existent alpha returns `null`, not an empty-string match |

**Three findings, each of which would have been a silent defect.**

**(1) `GenericRepository` is NOT a framework type.** Every domain carries its own copy —
`CoilCheckin` and `Common` both do — because the framework supplies only `EntityRepositoryBase`.
FlatWire needed its own, and §4 step 2's *"Do not write a new base repository"* reads as if one
could be referenced. It cannot.

**(2) `EntityRepositoryBase` implements NO interfaces** — measured by reflection, not assumed. It
carries the CRUD methods `IRepository<T>` declares, which satisfy the interface implicitly, but it
has **no `UnitOfWork` property**. Supplying that is the entire job of the local `GenericRepository`.
It also already exposes a `Context` property, so re-declaring one is `CS0108`.

**(3) ⚠ The `==` in `spool.Alpha == alpha` is REFERENCE equality in C#** — `ValueObject` overrides
`Equals` but declares **no `operator ==`**. It works only because EF translates the expression tree
through the value converter, which was confirmed by reading the generated SQL:
`WHERE [f].[RunId] = 'RUN-0042'`. **Anyone who evaluates one of these predicates in memory — a
`.ToList()` before the `.Where()`, a unit test over a fake — gets reference equality and silently
matches nothing.** The queries are correct; the trap is real.

---

## 7. Handoff

`FW-142` supplies `FlatWireDbContext` and the Dapper wiring these sit on. **`FW-207` no longer
supplies the alpha value objects — `P-66` moved them here** (§2.0), along with the seven roots'
structural declarations; what `FW-207` still supplies is the **behaviour** on those roots, the seven
dimensioned quantities, `PassScheduleSnapshot` and the domain events. Both converge with 1C — this
story's `Dependencies` include `FW-006`.

⚠ **`FW-207` adds behaviour to classes this story has already declared.** It does not re-declare
them; its build order says so at its §2.0a. A second declaration is a compile error, not a merge.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`G17`** *(the card's blocker)* | Rod → `coils` multiplies cross-DB logical FKs. Unenforced by design; the `Rod` mirror is what lets the **local** rod-alpha FKs be enforced (`D-04`, `[ARC §13.1]`) |
| **`OI-33`** | **`planning_routings` columns are unmapped** and rod access is built against them. The single largest unknown in this story |
| **`D-30`** | `ROWVERSION` is absent on the `WeldEvent`, `RodCheckout` and `WipRejection` roots, all three mutated after insert. Decide before the Phase-4 schema freeze; it changes these three repositories' update paths |
| **`G21`** | `RodStaging` bay uniqueness is keyed on the **physical station** (`UX_RodStaging_Bay` on `([Station],[PayoffPosition]) WHERE Status='Staged'`), **not** `(LineId, PayoffPosition)` |
| **`ROWVERSION`: six or eight?** *(new, 26 Aug 2026)* | `phase-01b` and `[SVC §3.4]` — *"the list of record"* — name **six** tables carrying a token. **The DDL has eight**: those six plus **`SpoolStaging`** and **`RodOrderConsumption`**, the latter arriving with the 22 Aug rod-order work. These repositories implement the update paths, so the discrepancy lands here. **Escalated to `[SVC]`, whose list it is — do not fix it in this plan** |
| **`FW-142` gates steps 2, 3 and half of 5** *(corrected 26 Aug 2026)* | `P-66` unblocks step 1. ⚠ This row said *"nothing after step 1 compiles without `FlatWireDbContext`"* and that was **too strong** — **step 4 has no EF dependency at all** (`ContextRepository` is Dapper on `DBQueryHelper`) and was built. What `FW-142` actually gates is the seven concrete repositories, which bind `GenericRepository<T, FlatWireDbContext>`, and their registration |
| **Three business keys have no value-object owner** *(new, 26 Aug 2026)* | `WeldEventId` `WLD-###`, `CheckoutId` `CO-####` and `RejectionId` `REJ-####` are the identities of three of the seven roots, and **none of them is in `FW-207`'s six alphas or in `[BR §3]`'s format list**. Either three more value objects are owed — `FW-207`'s, by `P-66`'s seam, since no repository *signature* forces them — or they are deliberately plain strings. **Decide before step 3**; the accessors' parameter types depend on it. *(`REJ-####` also carries `OI-21`, the unresolved `REJ-0041` vs `REJ-2026-0418` format.)* |
| **`OI-20` blocks typing `MaterialAlpha`** *(new, 26 Aug 2026)* | `WipRejection.MaterialAlpha` is a rod **or** spool alpha with no FK and no discriminator, so `IWipRejectionRepository`'s accessor takes a `string`. It is the one place in this story where the alpha-as-identity rule cannot be applied |
| **Hours moved but were not restated** *(new, 26 Aug 2026)* | `P-66` transfers the seven roots' structure and the six alphas from `FW-207`'s **32 h** into this story's **28 h**. Neither cell is restated — both are quoted by `[CE]`, `[DE]`, `[SSP]`, `[TRP]` and `[TB §7]`, and re-deriving in place would desynchronise roughly twenty files. **Owed to the re-baseline** |

| Stale | Correct | Source |
|---|---|---|
| AC 1: `PassScheduleRepository`, `RodRepository`, `RunRepository`, `CoilRepository` | **Seven, one per aggregate root**; `Rod`/`PassSchedule`/`RunReading` get none | `phase-01b` L85, `[SVC §3.2a]` |
| AC 3: *"Unit tests cover each repository"* | Withdrawn 15 Aug 2026 | `[TS §1.2]` |
| Rate-card basis: *"5 repositories @ 4 h = 20 h"* | Seven repositories against a **28 h** header | The header is the later figure; the basis line was not restated |
| *"the pass schedule read is cross-database"* | **Local** since `D-31` | `phase-01b` L63–67 |
| §4 step 2: *"`IGenericRepository<T>` derives from `IRepository<T>`"* | **`IGenericRepository<T, TContext>`** — two parameters. The one-parameter form is a compile error | `CoilCheckin.Domain/Repository/IGenericRepository.cs:18`, read 26 Aug 2026 |
| §6: *"no public `GetById(int)`"* | Unachievable while step 2 stands — `IRepository<T>` declares `GetAsync(int)`. Restated as a rule about **use** | `P-68` |
| `Dependencies: FW-N04, FW-006` | Also **`FW-207`** and **`FW-142`**; `P-66` resolves the first | §1.1 |
