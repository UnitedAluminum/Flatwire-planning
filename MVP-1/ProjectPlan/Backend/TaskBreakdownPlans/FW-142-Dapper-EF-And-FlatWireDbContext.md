# FW-142 · Dapper/EF data access and `FlatWireDbContext`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — short-lived lookup-table cache assigned to this story (`phase-01b` L97) *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **two of the four acceptance criteria are reversed by `D-31` (§2.1)**
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
> **Rate-card basis:** context + mapping across 24 tables, priced as a non-trivial service (24 h, §2)
> **Dependencies:** FW-N04; converges with FW-006 / FW-007
> **Blockers:** —

### 1.1 In scope

`Context/FlatWireDbContext.cs` implementing `IUnitOfWork` · entity mappings · the design-time
factory · `MediatorExtension.DispatchDomainEventsAsync` retyped to this context · the Dapper
read path · `ROWVERSION` concurrency tokens · registration.

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

### 2.1 One number, and it is 28

`phase-01b` L47:

> ⚠ Any "25 MVP-1 tables / 28 in the full design" split is stale — there is one number now,
> and it is **28**, verified on a live deploy alongside **43 FKs · 47 index statements ·
> 1 procedure · 1 trigger**.

So **AC 2's "25" is 28**, and **AC 4 is reversed** — the three `PassSchedule*` tables are
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
`Stand`, `Drawer`, `Edger`, `AlloyProperty`, `SpoolConfiguration`, `PayoffPosition`, the six
reference tables `[SVC §3.2a]` lists as *"not aggregates … reference data"*. **Short-lived is
the operative word**: `AlloyProperty` is edited by the alloy-lookup admin and
`Drawer.LastGrindingFeet` moves with every die change, so a long TTL serves a stale
tolerance band into a check-in. Keep it in-process and measured in seconds.

### 3.1 Concurrency — six tokens, and three roots without one

`ROWVERSION` optimistic tokens on **`PassSchedule`, `Rod`, `FlatWireRun`, `Spool`,
`RodStaging`, `CoilOutput`** — six, counted from a live deploy 15 Aug 2026 — mapped as
concurrency tokens so a mismatch surfaces as `CONCURRENCY_CONFLICT` → `409`.

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
   `CommonConstants.MiscConstants`, `ServiceLifetime.Scoped`. **`FW-N04` deliberately left
   this out of `Program.cs`; this story adds it.**
6. **Dapper read path** — `sp_GetGaugeTrace` and the list-grid queries through
   `ContextRepository`. Parameterised queries only.
7. **`TransactionBehaviour`** — `FW-139` `P-10` waits on this context. Land it now.
8. **Smoke pass** — insert → select against every table (§6).

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-12` precede this story.

### `P-13` — map all 28 tables for reading; give `PassSchedule*` **no write path**

**Needs ratifying.** `D-31` and `[SVC §3.2a]` are both correct and pull in opposite
directions: the tables are MVP-1 and carry enforced FKs, yet MVP-1 must never author a
schedule.

**Resolution:** the three `PassSchedule*` tables are reachable **read-only**. Concretely —
no `DbSet<PassSchedule>` on the context, and the read goes through **Dapper** as `phase-01b`
L60 specifies, projecting into the immutable `PassScheduleSnapshot` value object. The other
25 tables are mapped for EF writes as normal.

Rationale: a mapped, tracked `DbSet` is a write path whether or not anyone means to use it,
and *"MVP-1 reads schedules and never authors them"* is a rule better enforced by the
**absence of the mechanism** than by convention — the same reasoning `phase-01b` L112 uses
for `ITInhibit`'s missing operator clear path. The FK is a database constraint and needs no
EF mapping to hold.

**Read AC 2 as 28 tables and AC 4 as withdrawn**, with 3 of the 28 read-only.

### `P-14` — interim stance on `D-30`

Until `D-30` is decided, **do not add `ROWVERSION` columns to `WeldEvent`, `RodCheckout` or
`WipRejection`** — that is a schema change and 1C's to make. Map the six that exist. Where a
handler mutates one of the three unprotected roots, **write the update as a conditional
update on the fields it read** rather than a blind overwrite, so the eventual decision
changes the mechanism and not the semantics. Record it so `D-30` can be closed against real
call sites.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`, 15 Aug 2026. AC 3's *"smoke insert→select"* survives
as a **manual** pass in the QA0 walkthrough; it was never an xUnit suite.

| Check | Expected |
|---|---|
| Object baseline | Deployed `FlatWireDB` reports **28 tables · 43 FKs · 47 index statements · 1 procedure · 1 trigger** — `[DBD §6.2]` is the definition of record |
| EF mapping | 25 tables mapped for writes; **no `DbSet<PassSchedule>`** *(`P-13`)* |
| Smoke | Insert → select round-trips through EF against every mapped table |
| Concurrency | Six `ROWVERSION` tokens map as concurrency tokens; a stale write surfaces `CONCURRENCY_CONFLICT`/`409` |
| Dispatch | `SaveEntitiesAsync` dispatches domain events **after** `SaveChangesAsync`, never before |
| Dapper | `sp_GetGaugeTrace` returns; **`sp_ShiftSummary` is neither created nor granted** |
| Transactions | `TransactionBehaviour` skips request types whose name contains `Query` |

---

## 7. Handoff

`FW-141`'s repositories and `FW-139`'s `TransactionBehaviour` both land on this context.
`FW-208` uses the dispatch hook. `FW-207` supplies the aggregates being mapped.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`P-13`** | Needs ratifying before the mapping is written |
| **`D-30`** | Three roots without a concurrency token, all mutated after insert. **Before the Phase-4 schema freeze** |
| **`G14`** | Footage is `DECIMAL(10,2)` on `FlatWireRun`/`FlatWireRunDetail`/`RunReading` but **`INT` on the event tables**. The DDL has not resolved it; map what is there and do not normalise silently |
| **`G3`** | `RunReading` is the store the broadcast loop depends on |
| **`OI-42`** | How the local `Rod` mirror stays in sync with `coils` is open (`D-04`) |

| Stale | Correct | Source |
|---|---|---|
| AC 2: *"all **25 MVP-1 tables** … 28 in the full design"* | **28**, one number | `D-31`; `phase-01b` L47 |
| AC 4: *"The three `PassSchedule*` tables are not mapped — owned outside MVP-1"* | **They are MVP-1**, with enforced FKs. Read-only by `P-13`, not unmapped-by-scope | `D-31`; `[SVC §3.2a]` |
| Rate-card basis: *"across 24 tables"* | 28 | `[DBD §6.2]` |
| `[SVC §3.3]` naming `sp_ShiftSummary` alongside `sp_GetGaugeTrace` | `sp_ShiftSummary` is **MVP-2's** — do not create, drop or grant | `phase-01b` L87 |
