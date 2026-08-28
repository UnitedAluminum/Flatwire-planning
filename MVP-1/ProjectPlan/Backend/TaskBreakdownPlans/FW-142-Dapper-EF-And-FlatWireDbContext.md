# FW-142 · Dapper/EF data access and `FlatWireDbContext`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — **BUILT** (§6 carries the results), and `P-70` minted: sixteen columns are added by `ALTER TABLE` rather than in the `CREATE TABLE` body, which had cost `FW-141` seven properties on two roots. Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **BUILT 27 Aug 2026** (§6) — two of the four acceptance criteria were reversed by `D-31` (§2.1); `FW-141` had already landed part of §4 (§7)
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-142`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** This story's card was written before `D-31` (15 Aug 2026)
> and **two of its four acceptance criteria are now wrong**: the table count, and the
> instruction not to map the `PassSchedule*` tables. Both reversed the same day.
>
> But the reversal is not a simple "map them after all". `D-31` moved the tables into MVP-1
> and made `PassScheduleId` a real enforced FK — while `[SVC §3.2a]` keeps `PassSchedule` a
> **read model with no write path**. Owning the table is not owning the data, and the
> mapping decision has to reflect that (§5, `P-13`).

---
> ### ⚠ Coding standard — read `[SVC §3.4a]` before writing code
>
> The repository C# standard binds every `.cs` file here, and `[SVC §3.4a]` records **four standing
> divergences** so they are not re-litigated in review. ⚠ **None of the four is this story's** — they
> are `FW-138`'s and `FW-N04`'s (the `FlatWireResult<T>` envelope `P-56`, the explicit per-action
> routes `P-04`, the retained `#region` blocks, and the fourteen canonical enums `P-58`). Read them,
> do not re-argue them, and do not expect to implement them here. **What this story owns is its own
> list:**
>
> **`TransactionBehaviour` lands with this story** - `FW-139`'s `P-10`. It cannot be inherited:
> the `UATemplate` and `OPCConnection` copies both take the **concrete** context, so FlatWire
> needs its own bound to `FlatWireDbContext`. It registers **after** `LoggingBehavior` and
> `ValidatorBehavior`, and skips transactions when the request type name contains `Query`.
>
> **`AsNoTracking()` on every read-only query and explicit `Include`/`ThenInclude`** are checklist
> items this story owns. ⚠ Also **drop `AddScoped<IMediator, Mediator>()` from `AddPersistence`** —
> `P-51` lifted it into `Program.cs`; a second descriptor for the same pair is a duplicate registration.


## 1. The story

From `[TB §7]` — verbatim, **including the reversed criteria**:

> ###### FW-142 · Dapper/EF data access and `FlatWireDbContext`
> **Hours:** 24 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** developer,
> **I want** the mixed Dapper/EF convention wired against `FlatWireDB`,
> **So that** high-volume reads stay fast and entity writes stay typed.
>
> **Acceptance Criteria:**
> - [ ] **Dapper** for high-volume reads — gauge trace, list grids, report aggregations
> - [ ] **EF Core `FlatWireDbContext`** for entity writes, mapped to all **25 MVP-1 tables** (`Rod` **is** among them per `D-04`; 28 in the full design — `[DBD §6.2]`)
> - [ ] A smoke insert→select round-trips through EF against every table
> - [ ] **The three `PassSchedule*` tables are not mapped** — they are owned outside MVP-1
>
> **Rate-card basis:** context + mapping across 24 tables, priced as a non-trivial service (24 h, §2). ⚠ **The table count in this derivation is stale — flagged, not substituted (23 Aug 2026).** The live figure is `[DBD §6.2]`. Replacing the count without re-deriving the hours would make the arithmetic lie, and per the standing convention an effort change lands in an **additive new sheet, never an in-place edit of a total**. **Owed: re-derive against `[DBD §6.2]` using `[CE §2]`'s rate card** — `[CE]`'s owner, not this document's.
> **Dependencies:** FW-N04; converges with FW-006 / FW-007
> **Blockers:** —

### 1.1 In scope

`Context/FlatWireDbContext.cs` implementing `IUnitOfWork` · entity mappings · the design-time
factory · `MediatorExtension.DispatchDomainEventsAsync` retyped to this context · the Dapper
read path · `ROWVERSION` concurrency tokens · registration.

⚠ **And one thing the earlier issues left unstated: this story owns the unit of work that other
stories borrow a transaction from.** `[FW-220 §208]` names it exactly that way — *"`FW-142`
(Dapper + context + **the unit of work that owns the transaction**)"* — because `[INT §8.0]`
requires `CheckInService` to write `FlatWireDB` through EF and then call `FlatWire_CheckInRod`
**on the same `SqlConnection` and `SqlTransaction`**, under the local transaction manager with no
MSDTC. So `FlatWireDbContext` must expose its connection and ambient transaction
(`Database.GetDbConnection()`, `GetCurrentTransaction().GetDbTransaction()`) for a Dapper call to
join. **Nothing else can**: `ContextRepository` derives from `DBQueryHelper`, which builds its own
connection from `IOptions<SqlSetting>` and disposes it on return — see §4 step 6.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The seven repositories that sit on this | [`FW-141`](FW-141-Repository-Layer.md) |
| The aggregates being mapped | [`FW-207`](FW-207-Domain-Model.md) |
| Raising and dispatching the domain events — this story provides the hook | `FW-208` |
| The connection string binding | [`FW-144`](FW-144-Configuration-Binding.md) |
| The schema itself | 1C — `FW-006`, `FW-007` |

---

## 2. What `D-31` changed

### 2.1 One set, not a split — and `[DBD §6.2]` is the site that counts it

`phase-01b` L47:

> ⚠ *Any "25 MVP-1 tables / 28 in the full design" split is stale — there is one set now, and
> `[DBD §6.2]` is the site that counts it. This file is **not** one of the three permitted to
> restate the figures; it published `33 · 55 · 69` until 26 Aug 2026, and `Q89` moved the index
> count to 70 that day.*

So **AC 2's "25 MVP-1 tables / 28 in the full design" is one set of 33 tables (`[DBD §6.2]`)**,
and **AC 4 is reversed** — the three `PassSchedule*` tables are
MVP-1 and the MVP-1 runner builds them. `PassScheduleId` is now a **real, enforced and
trusted FK** on four tables: `FK_FlatWireRun_PassSchedule`, `FK_RodCheckin_PassSchedule`,
`FK_SpoolCheckin_PassSchedule`, `FK_CoilOutput_PassSchedule`.

> **`PlanId`, `CoilOrderPlanId` and `SkidId` are unaffected** — they remain external
> references with no local parents.

### 2.2 But `PassSchedule` is still a read model

`[SVC §3.2a]`, on the same day:

> **Read-model status is unchanged and is the point**: MVP-1 reads schedules and never
> authors them, so there is no aggregate, no repository and no write path.

`phase-01b` L60 is how it is read: *"Read model — **no repository** (`[SVC §3.2a]`); Dapper
query + `PassScheduleSnapshot`."* And L75: **MVP-1 reads these tables and never writes
them** — nothing in MVP-1 populates them in production (`OI-110`).

That combination — real FK, no write path — is what `P-13` resolves.

### 2.3 The one procedure that is not yours

`phase-01b` L87: ⚠ **`sp_ShiftSummary` is MVP-2's — do not create, drop or grant it.**
`sp_GetGaugeTrace` is MVP-1's and backs the heaviest read.

*(`[SVC §3.3]` names both procedures together; the phase document is the later and narrower
statement for MVP-1 scope.)*

---

## 3. The split

`[SVC §3.3]` — mixed per UAL convention:

| Access | Technology | Used for |
|---|---|---|
| Entity writes | **EF Core** via `FlatWireDbContext` | Every command — check-in, staging, weld, SPC, override, checkout, coil completion |
| High-volume reads | **Dapper** | Gauge trace, shift summary, list grids, the staging-queue projection, and the cross-DB reads |

**A short-lived memory cache for lookup tables** belongs to this story (`phase-01b` L97) —
`Stand`, `Drawer`, `Edger`, `Dancer`, `Spool`, `AlloyProperty`, `PayoffPosition`, the **seven**
reference tables `[SVC §3.2a]` lists as *"not aggregates … reference data"* — the whole of
`01_Lookup`. ⚠ *This sentence said "the six" while listing seven names until 27 Aug 2026.
`[SVC §3.2a]` states no count at all, so the six was attributed to a source that never said it.
The same schema has produced this exact error before — `[DBD §6.2]` records the Lookup row reading
**6** and omitting `Dancer` until 13 Aug 2026. Do not reintroduce it a third time.* **Short-lived is
the operative word**: `AlloyProperty` is edited by the alloy-lookup admin and
`Drawer.LastGrindingFeet` moves with every die change, so a long TTL serves a stale
tolerance band into a check-in. Keep it in-process and measured in seconds.

### 3.1 Concurrency — eight tokens, and three roots without one

`ROWVERSION` optimistic tokens on **`PassSchedule`, `Rod`, `FlatWireRun`, `SpoolProcessing`,
`RodStaging`, `SpoolStaging`, `RodOrderConsumption`, `CoilOutput`** — **eight**, counted from the
DDL 27 Aug 2026 — mapped as concurrency tokens so a mismatch surfaces as `CONCURRENCY_CONFLICT` →
`409`. **Map all eight — `P-69`**, which also records what `[SVC §3.4]` owes.

> ⚠ **Open decision `D-30`.** Under DDD the token belongs on the **aggregate root**, and
> three roots — **`WeldEvent`, `RodCheckout`, `WipRejection`** — have none, though all three
> are mutated after insert (a weld's `Pass`/`Fail`, a checkout's approval stamp, a
> rejection's disposition). **Decide before the Phase-4 schema freeze.** Interim stance in
> `P-14`.
>
> *(`D-30` was numbered `D1` until 15 Aug 2026 — `FW-207`'s card still says `D1`. Same
> decision.)*

---

## 4. Build order

1. **`FlatWire.Infrastructure/Context/FlatWireDbContext.cs`** — the folder is prescribed by
   `[SVC §3.1]`. Model on `CoilCheckinContext`:
   - `: DbContext, IUnitOfWork`
   - `SaveEntitiesAsync` calling `DispatchDomainEventsAsync` then `SaveChangesAsync`
   - `BeginTransactionAsync` (`IsolationLevel.ReadCommitted`) / `CommitTransactionAsync` /
     `RollbackTransaction`
   - `GetCurrentTransaction()` / `HasActiveTransaction`
2. **`MediatorExtension.cs`** — retyped to `FlatWireDbContext`. It is strongly typed to the
   concrete context, so it **must be recreated per service**; it cannot be inherited.
3. **Entity mappings for the write model.** Unlike `CoilCheckin` — which declares no
   `DbSet<>` at all and is entirely SP-based — FlatWire has real aggregates, so map them.
   Configure `ROWVERSION` as `IsRowVersion().IsConcurrencyToken()`.
4. **`FlatWireDbContextDesignFactory : IDesignTimeDbContextFactory<FlatWireDbContext>`** for
   EF tooling, with the same no-op `IMediator` `CoilCheckin` uses.
5. **`AddCustomDbContext`** in `FlatWire.API/Extensions/` — `AddEntityFrameworkSqlServer()`
   + `AddDbContext<FlatWireDbContext>` with `EnableRetryOnFailure` and `CommandTimeout` from
   `CommonConstants.MiscConstants`, `ServiceLifetime.Scoped`. Model on
   `CoilCheckin.API/Extensions/CustomDbContext.cs`. **`FW-N04` deliberately left this out of
   `Program.cs`; this story adds it.**
   - ✅ **The catalog already resolves correctly.** `appsettings.json` sets
     `SqlSetting:CATALOG = FlatWireDB`, so the framework's `{catalog}` substitution targets the
     right database. Worth checking rather than assuming — it is the one place a `united_db`
     default would pass unnoticed.
   - ⚠ **Register into the existing `AddPersistence`**, which `FW-140` built and which already
     carries a `FW-142` hook comment naming this exact step. It is **not** created here. **Do not
     re-add `AddScoped<IMediator, Mediator>()`** — `P-51` put it in `Program.cs`.
6. **Dapper read path** — ⚠ **`ContextRepository` already exists.** `FW-141` built it, registered
   it in `AddPersistence`, and implemented `sp_GetGaugeTrace` against it. This story **adds to**
   `IContextRepository`: the list-grid projections and the `PassScheduleSnapshot` read (`P-13`).
   Parameterised queries only.
   - ⚠ **`DBQueryHelper` has no `QueryMultipleAsync`.** The multi-result-set method is
     `ExecuteSPReturnGridReaderAsync(spName, parameters, params Func<GridReader, object>[])`, and
     its reader funcs **must fully materialise** — the helper disposes the connection on return.
   - ⛔ **The transactional procedure calls do NOT go here.** `FlatWire_CheckInRod` and its three
     siblings must run on the context's own connection and transaction (§1.1), and
     `DBQueryHelper` cannot join one. `IContextRepository` stays **non-transactional reads only**.
7. **`TransactionBehaviour`** — `FW-139` `P-10` waits on this context. Land it now.
8. **Smoke pass** — insert → select against every table (§6).

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-12` precede this story, and the register now
> runs to `P-69`. The register of record is [`Orchestration.md`](Orchestration.md).

### `P-13` — map all 33 tables (`[DBD §6.2]`) for reading; give `PassSchedule*` **no write path**

**Needs ratifying.** `D-31` and `[SVC §3.2a]` are both correct and pull in opposite
directions: the tables are MVP-1 and carry enforced FKs, yet MVP-1 must never author a
schedule.

**Resolution:** the three `PassSchedule*` tables are reachable **read-only**. Concretely —
no `DbSet<PassSchedule>` on the context, and the read goes through **Dapper** as `phase-01b`
L60 specifies, projecting into the immutable `PassScheduleSnapshot` value object. **Every other
table in `[DBD §6.2]` is mapped for EF writes as normal.**

Rationale: a mapped, tracked `DbSet` is a write path whether or not anyone means to use it,
and *"MVP-1 reads schedules and never authors them"* is a rule better enforced by the
**absence of the mechanism** than by convention — the same reasoning `phase-01b` L112 uses
for `ITInhibit`'s missing operator clear path. The FK is a database constraint and needs no
EF mapping to hold.

**Read AC 2 as 33 tables (`[DBD §6.2]`) and AC 4 as withdrawn**, with 3 of the 33 read-only.

### `P-14` — interim stance on `D-30`

Until `D-30` is decided, **do not add `ROWVERSION` columns to `WeldEvent`, `RodCheckout` or
`WipRejection`** — that is a schema change and 1C's to make. Map the eight that exist (`P-69`). Where a
handler mutates one of the three unprotected roots, **write the update as a conditional
update on the fields it read** rather than a blind overwrite, so the eventual decision
changes the mechanism and not the semantics. Record it so `D-30` can be closed against real
call sites.

### `P-72` — `TransactionBehaviour` resolves the context **lazily**, not by injection

**Found by booting the service, 27 Aug 2026 — it would not start.**

Every sibling `TransactionBehaviour` in `ual-api` injects its concrete context, and this one did
too. But **MediatR constructs every behaviour in the pipeline before any of them runs**, so an
injected `FlatWireDbContext` is built — and its connection string resolved — on **every dispatch**:
including queries this behaviour skips by name, and commands that fail validation upstream and
never reach it.

That is harmless for the siblings, which all require a database. **FlatWire does not.**
`useMockData=true` binds twelve stub services and `AddPersistence.Describe` says in as many words
that *no database is required* — the path that lets the Angular UI build against dummy data. Eager
injection broke that contract **at boot**: the Development probe dispatches a `StageRodCommand`,
which constructed the context, which threw on a missing connection string, and the host died before
the stub path was ever reached.

**Resolution:** inject `IServiceProvider` and resolve `FlatWireDbContext` **after** the `Query`
skip, where the request is known to be a command and a database is genuinely required. A missing
connection string is then a real failure at the point it actually matters.

⚠ **This is a deliberate divergence from the sibling implementations**, justified by a requirement
they do not have. Do not "correct" it back to constructor injection.

### `P-70` — read the schema from `CREATE TABLE` **and** `ALTER TABLE`, never `CREATE TABLE` alone

**Found while building, 27 Aug 2026.** Sixteen columns across six tables are added by
`ALTER TABLE … ADD` **after** the `CREATE TABLE`, not inside its body — and the DDL says why in its
own banner: the table guard is `IF NOT EXISTS (… CREATE TABLE …)`, so **a column added to the body
would never reach a database that already has the table**. It is the correct pattern, and it is
invisible to anything that parses `CREATE TABLE` alone.

`FW-141` generated the seven roots from `CREATE TABLE` bodies and inherited that blind spot, so
**seven properties were missing from two aggregate roots** and would have been silently unmappable:

| Root | Missing | Why it matters |
|---|---|---|
| `SpoolProcessing` | `SpoolId` | ⛔ the FK to the `Spool` **article** lookup (`Q60`) — without it the wire is not tied to the spool it is wound on |
| | `FootageRunToDate`, `RemainingWeightEstimateLb` | the partial re-check-in carry-forward `FR-043` depends on — the **delivered** form of `PartialRodReCheckin.md`'s proposed snake_case columns |
| | `RunStartFootageFt` | run-relative footage anchor |
| `CoilOutput` | `AnchorBasis` | `NOT NULL` + `CHECK`; exists to make an **assumption visible** (`Observed` vs `AssumedContiguous`) |
| | `RunFootageAtStartFt`, `RunFootageAtEndFt` | the coil's footage window on the run |

**All seven were added to the domain classes and mapped.** The remaining nine `ALTER`-added columns
sit on `CoilTraceability`, `SpoolCheckin`, `SpoolOrder` and `SpoolTraceability` — **not roots**, so
they are `FW-207`'s, and that story must not repeat this.

**The general rule:** the column list for any `FlatWireDB` table is
`CREATE TABLE` **plus** every `ALTER TABLE … ADD` for it. Verify with a count, not by eye —
`CoilOutput` reads 28 from its body and **31** in the database.

### `P-69` — map all **eight** `ROWVERSION` tokens, not the six `[SVC §3.4]` lists

`[SVC §3.4]` names six — `PassSchedule`, `Rod`, `FlatWireRun`, `SpoolProcessing`, `RodStaging`,
`CoilOutput` — and **says so knowingly**: *"The DDL now has eight, and this row is the list of
record, so the difference is unresolved rather than merely unrecorded (raised by `FW-141`,
26 Aug 2026)."* The two it does not name are **`SpoolStaging`** and **`RodOrderConsumption`**, the
latter created by the 22 Aug rod-order allocation work.

**Resolution: map all eight.** This story is the one that writes
`IsRowVersion().IsConcurrencyToken()`, so it cannot leave the difference silent — the choice is
made here whether or not it is made deliberately. Mapping a token that exists costs nothing and is
reversible; **failing to map one loses lost-update detection with no symptom**, which is precisely
`D-30`'s complaint about the three roots that have no token at all. An unmapped `ROWVERSION` still
populates in the database and still reads back — it simply stops guarding anything.

⚠ **What this does not do.** It does **not** decide whether either column *should* exist —
`[SVC §3.4]` remains the list of record and reconciling it is `[SVC]`'s to do **before the Phase-4
schema freeze**, alongside `D-30`. This decision is only about what the context maps today. If the
reconciliation removes a column, the mapping goes with it.

⚠ **Four of the eight are mapped today, and the other four are not this story's to map.** A token is
only mappable where a C# entity exists. `FlatWireRun`, `RodStaging`, `SpoolProcessing` and
`CoilOutput` are aggregate roots and carry theirs. The other four do not have entities:
**`PassSchedule`** never will (`P-13` — mapping it would create the write path the decision exists to
prevent), and **`Rod`**, **`SpoolStaging`** and **`RodOrderConsumption`** are `FW-207`'s to declare.
`P-69` binds that story too: map the token when the entity lands. **The three roots that have an
entity and no token are `D-30`'s three** — `WeldEvent`, `RodCheckout`, `WipRejection` — and `P-14`
governs them.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. AC 3's *"smoke insert→select"* survives
as a **manual** pass in the QA0 walkthrough; it was never an xUnit suite.

> ### ✅ Executed 27 Aug 2026 — results
>
> Built on `ual-api` branch `feature/flat-wire`. **0 errors; no warning in any file this story
> touched** (13 remain solution-wide, all pre-existing in `HttpContextServiceProviderProxy.cs` and
> `ServiceLocator.cs`).
>
> **Model validation** — all **7** entity types build and validate; column counts match the DDL
> exactly for all seven *(after `P-70`'s recovery)*; **no `DbSet<PassSchedule>`** (`P-13` holds);
> alpha converters round-trip and **reject a malformed alpha on read**.
>
> **Live smoke, against `FlatWireDB` on `DEVUAL-UADEV001\TEST1`** — read round-trip passes on **6 of
> 7** roots, exercising every mapped column against the real schema. The write path was proven
> **inside a rolled-back transaction**: raw SQL parents *(the `FW-220` pattern — `PassSchedule` has
> no `DbSet`)* and EF writes shared **one connection and one transaction**; the DB generated the
> `RowVersion`; the select rehydrated `RunAlpha`/`RodAlpha` and the `LineId` enum; rollback left
> **all five tables at 0 rows**, verified.
>
> ⛔ **`SpoolProcessing` could not be smoke-tested — `Invalid object name`.** The deployed database
> **predates `Q60`**: it still holds `SpoolCarrier` and `SpoolConfiguration` and has no
> `SpoolProcessing` at all. **This is the database being stale, not the mapping being wrong** — the
> mapping matches the current DDL, and `[DBD §6.2]` already records the deployed instance as two
> schema changes behind. **A teardown-and-rebuild is owed before any further build work reads it**,
> and that is a destructive action on a shared instance, so it is not taken here.

| Check | Expected |
|---|---|
| Object baseline | Deployed `FlatWireDB` reports **33 tables · 55 FKs · 70 index statements · 1 procedure · 1 trigger** — `[DBD §6.2]` is the definition of record *(69 index statements until `Q89` added `UX_CoilTraceability_ChildAlpha` on 26 Aug 2026)* |
| EF mapping | every table in `[DBD §6.2]` mapped for writes; **no `DbSet<PassSchedule>`** *(`P-13`)* |
| Smoke | Insert → select round-trips through EF against every mapped table |
| Concurrency | **Eight** `ROWVERSION` tokens map as concurrency tokens *(`P-69`)*; a stale write surfaces `CONCURRENCY_CONFLICT`/`409` |
| Dispatch | `SaveEntitiesAsync` dispatches domain events **after** `SaveChangesAsync`, never before |
| Dapper | `sp_GetGaugeTrace` returns; **`sp_ShiftSummary` is neither created nor granted** |
| Transactions | `TransactionBehaviour` skips request types whose name contains `Query` |
| Unit of work | `FlatWireDbContext` exposes its connection and ambient transaction, and a Dapper `EXEC` on that pair commits atomically with the EF writes — the `[INT §8.0]` pattern `FW-220` depends on *(§1.1)* |
| ⚠ Procedure count | **Do not assert `sys.procedures = 1`.** The DDL declares one (`sp_GetGaugeTrace`), but `sp_IngestRodFromCoils` is deliberately **not** in `RunAll`, so an incrementally-built database reads **2** and a clean teardown-and-deploy reads **1**. Neither is a defect |

---

## 7. Handoff

`FW-139`'s `TransactionBehaviour` lands on this context. `FW-208` uses the dispatch hook.
`FW-207` supplies the aggregates being mapped.

⚠ **`FW-141` is partly built already, so be precise about what is still owed.** Its seven
repository **interfaces**, the six alphas, the seven structural roots and `IContextRepository`
were delivered on 26 Aug 2026 and are **not** waiting on this story — `P-67` deliberately derived
them from `IRepository<T>` so they compile without `FlatWireDbContext`. What waits here is the
seven **implementations**, which inherit `GenericRepository<T, FlatWireDbContext>`, and the
`IGenericRepository<,>` open-generic registration.

**`FW-220` waits on the unit of work**, not on the mappings — see §1.1.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`P-13`** | Needs ratifying before the mapping is written |
| **`D-30`** | Three roots without a concurrency token, all mutated after insert. **Before the Phase-4 schema freeze** |
| **`G14`** | Footage is `DECIMAL(10,2)` on `FlatWireRun`/`FlatWireRunDetail`/`RunReading` but **`INT` on the event tables**. The DDL has not resolved it; map what is there and do not normalise silently |
| **`G3`** | ⚠ **Half closed 26 Aug 2026 — the table half is DONE.** `RunReading` is built, FK'd, indexed `(RunId, FootageFt)` and seeded. **The open half is retention/rollup, and it has no owner** — an unbounded 10 Hz time series with no defined trim. That is the half this story feels: the Dapper trace read is over a table nothing prunes |
| **`P-69` / `[SVC §3.4]`** | The six-vs-eight `ROWVERSION` difference. Mapped as eight here; the **list of record** is `[SVC §3.4]`'s to reconcile **before the Phase-4 schema freeze** |
| **`FW-219` vs `FW-220`** | ⚠ **Two sibling plans disagree on the cross-database transaction, and this story supplies the mechanism both would use.** [`FW-219 §70`](FW-219-FlatWire-CompleteCoilOnSkid.md) says the shared writes *"are not in the same transaction… They cannot be: different database"*; `[INT §8.0]`, `[ARC §10]` and `FW-220` all say the opposite — co-located on one instance, one `SqlConnection`, one `SqlTransaction`, no MSDTC. **Not this story's to settle.** Build the unit of work per §1.1 and let each caller choose; do not bake either answer into the context |

| Stale | Correct | Source |
|---|---|---|
| AC 2: *"all **25 MVP-1 tables** … 28 in the full design"* | **One set of 33 tables (`[DBD §6.2]`)**, not a split | `D-31`; `[DBD §6.2]` |
| ~~`OI-42`~~ — *"how the local `Rod` mirror stays in sync with `coils` is open"* | ✅ **CLOSED 19 Aug 2026.** `sp_IngestRodFromCoils` projects the rod on the **first write that names it**, inside that operation's transaction, never on a read; the column-ownership split is `[INT §7.9]`. **The consequence here is the procedure count** — see §6 | master spec `OI-42`; `FR-529`–`FR-532`, `FW-223` |
| §2.1's quote of `phase-01b` L47 as *"one number now, and it is 33 … 69 index statements"* | **Never quote a count from `phase-01b`** — it was rewritten to stop restating figures and now points at `[DBD §6.2]`. The quote in §2.1 is the current text | `phase-01b` L47 |
| AC 4: *"The three `PassSchedule*` tables are not mapped — owned outside MVP-1"* | **They are MVP-1**, with enforced FKs. Read-only by `P-13`, not unmapped-by-scope | `D-31`; `[SVC §3.2a]` |
| Rate-card basis: *"across 24 tables"* | the `[DBD §6.2]` figure | `[DBD §6.2]` |
| `[SVC §3.3]` naming `sp_ShiftSummary` alongside `sp_GetGaugeTrace` | `sp_ShiftSummary` is **MVP-2's** — do not create, drop or grant | `phase-01b` L87 |

### 8.1 ⚠ Every table name in this document is scheduled to change — do not pre-empt it

`WeldedCoilAlpha_2026-08-26_SyncPlan.md`'s change `[R]` renames **23 of the 33 tables** to a
`FlatWire_` prefix, and **this document holds 12 of the 23 bare names**. It is named there as an
unswept target.

**Use the bare names exactly as the DDL declares them today.** Wave `S1a` is **blocked
indefinitely** — 21 of the 24 files it edits are dirty in the working tree — so the scripts, the
deployed database and this plan all still carry bare names. A plan written to the new names would
match nothing. The single guarded `S1a` commit will sweep this file when it runs.

⛔ **Two things `S1a` must NOT sweep, and they are both dense in this document and in the code it
describes:**

- **`*Id` column names keep their bare form** — `RodCheckinId`, `WipRejectionId`, `WeldEventId`,
  `RodCheckoutId`, `PayoffPositionId`, `RollOverrideId`. A blanket rename produces
  `FlatWire_RodCheckinId`, which is not a column anywhere.
- **.NET type names keep their bare form** — `IFlatWireRunRepository`, `ICoilOutputRepository`,
  `IRodStagingRepository` and the rest. A blanket rename produces `IFlatWire_RodStagingRepository`.
- Also note **`PayoffPosition` is the one renamed lookup** while the other six stay bare, and the
  **`PayoffPosition` *column*** on `RodStaging`/`RodCheckin` **does not rename** — table reference
  and column reference diverge on the same word.

Tracked as **`OI-133`** (the schema is left half-prefixed — 23 renamed, 10 bare) and **`OI-134`**
(`FlatWire_` now names both tables and procedures, so `grep FlatWire_` stops discriminating).
⚠ *The ledger raises these as `Q91`/`Q92`; both were **withdrawn from the open register the same
day and re-minted `OI-133`–`OI-135`**, because they are ours to answer rather than the client's.
Cite the `OI-` ids — the `Q##` ids resolve to nothing.*
