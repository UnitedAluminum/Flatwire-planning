# Flat Wire Mill — Backend Services

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — §3.4's open decision **`D1` re-numbered `D-30`** (it collided with `[PLC]`'s retired `D1`–`D17` log) and promoted into `[ARC §13.1]`; `[PLC §620]` retargeted to `[PLC §11.2]` *(otherwise August 13, 2026 — split out of `03-HLD-and-ERDiagram.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*
**Document Type:** Solution structure, CQRS, validation and error handling
**Status:** Baselined for build
**Owner:** Backend (.NET) stream
**Audience:** .NET developers
**Shortcode:** `[SVC]`
**Part of:** `ProjectPlan/Backend/` — index: [README.md](../README.md)

---

## 3. Backend design

### 3.1 Solution structure

```
API/Domain/FlatWire/
├── FlatWire.sln
├── FlatWire.API/            controllers (thin) + Hubs/FlatWireHub.cs + Program.cs + appsettings
├── FlatWire.Application/    Commands/ and Queries/ (MediatR), BusinessRules/, pipeline behaviors
├── FlatWire.Domain/         AggregatesModel/, ValueObjects/, Rules/, Events/, Repository/ (interfaces),
│                            Enums/, ParamModels/, Exceptions/, IFlatWireClient
└── FlatWire.Infrastructure/ Repositories/, Services/PLCTagService.cs, Context/FlatWireDbContext.cs
```

> **`FlatWire` is built to tactical DDD — decision `D-29`, 15 Aug 2026 — and is the first UAL service to be.** Aggregates carry behaviour and enforce their own invariants; entities are not property bags.
>
> **This is not a departure from the platform, it is a first use of it.** `UA.Framework.Domain/EntityModels/` already ships **`Entity`** (with `DomainEvents`, `AddDomainEvent`, `ClearDomainEvents`, identity equality) and **`ValueObject`** (`GetAtomicValues`, structural equality); `CoilCheckin.Domain/Rules/` ships **`IBusinessRule`** and **`CheckRule`** → `BusinessRuleValidationException`; and `CoilCheckin.Infrastructure/MediatorExtension.cs` ships **`DispatchDomainEventsAsync`**. Every piece exists and has been dormant — `CoilCheckin` kept the machinery and modelled `DBModels/` as anemic `{ get; set; }` bags that never use it.
>
> ⚠ **`D-29` overrides only the Domain-layer half of `[ARC §2.2]`.** `CoilCheckin` remains the binding template for controllers, `Program.cs`, `.csproj`/NuGet, DI registration, MediatR wiring and pipeline behaviours. **Do not read this as "CoilCheckin is no longer the template."**
>
> **Inherit the framework bases. Do not write new ones** — if you are writing an `Entity` or `ValueObject` base class, you have missed the one in `UA.Framework.Domain`.

Project references: `API → Application, Domain, Infrastructure` · `Application → Domain` · `Infrastructure → Domain`.

### 3.2 Layering rules

| Layer | Contains | Must not contain |
|---|---|---|
| **API** | Controllers extending `UAController`, `FlatWireHub`, DI wiring, `Program.cs` | Business logic, EF queries, direct OPC calls |
| **Application** | MediatR command/query handlers, FluentValidation validators, pipeline behaviours | EF `DbContext` types, HTTP types, SignalR types |
| **Domain** | **Seven aggregate roots** — `FlatWireRun`, `RodStaging`, `WeldEvent`, `Spool`, `CoilOutput`, `RodCheckout`, `WipRejection` — plus value objects, invariant rules, domain events, repository **interfaces**, enums, `IFlatWireClient` | Persistence concerns, framework attributes |
| **Infrastructure** | `FlatWireDbContext`, repositories, Dapper readers, `PLCTagService`, the OPC hosted service | Business rules |

**Controllers are thin.** All logic routes through MediatR. Every controller and endpoint carries `[Authorize]`.

### 3.2a Aggregate boundaries — what is in each root, and what is deliberately outside

| Root | Contains | Invariants it enforces |
|---|---|---|
| **`FlatWireRun`** | `FlatWireRunDetail`, `RodCheckin`, `SpoolCheckin`, `RunPauseEvent`, `RollOverride`, `DieChangeEvent`, `SpcCheckpoint` + `SpcMeasurement` | Pause/resume state machine and its **four** resume outcomes; SPC mandated after a die change and after a roll adjust; roll-gap override requires authority, and **revert is Operations-Manager-only** (`FR-212`) |
| **`RodStaging`** | bay state | **`G21` — one rod per *physical* station**, keyed on `Station` not `LineId`. `Blocked` is **derived** (`Staged` + any inspection `Fail`), never stored; `IsWelded` is a **flag on a `Staged` row**, not a status |
| **`WeldEvent`** | — | **Its own root, not part of `FlatWireRun`** — welds are recorded at pre-check-in (DB2A *Mark as welded*) **before a run exists** |
| **`Spool`** | completion state | Prompt raised **once** per `RUNNING → STOPPED` edge; weight **latched at the PLC stop timestamp** |
| **`CoilOutput`** | `CoilTraceability` | **DM010 non-overlap is an aggregate invariant** — footage ranges may not overlap. `trg_CoilTraceability_NoOverlap` stays as belt-and-braces |
| **`RodCheckout`** | — | Mode P / A / B; Mode B needs the supervisor stamp and PLC-locked footage > 0; Mode P must carry null footage |
| **`WipRejection`** | — | Disposition lifecycle; **the only thing that clears a `Blocked` bay** — publishes a domain event rather than reaching into `RodStaging` |

**Not aggregates, each for a reason:**

- ⚠ **`RunReading`** — 10 Hz time series. Inside `FlatWireRun` it would materialise thousands of rows on every command. **Append-only write model**, read by Dapper via `sp_GetGaugeTrace`. **The most important exclusion in this design.**
- **`Rod`** — a `FlatWireDB`-local mirror of `coils` (`D-04`); `coils` owns the lifecycle. Read model.
- **`PassSchedule`** — **a read model, and MVP-1 now builds the table** (`D-31`, 15 Aug 2026): `02_Schedule` is in the MVP-1 runner and `PassScheduleId` carries a **real, enforced FK**. ⚠ *This row previously said "MVP-2-owned … not built by the MVP-1 runner … an opaque external reference" — all three clauses are superseded.* **Read-model status is unchanged and is the point**: MVP-1 reads schedules and never authors them, so there is no aggregate, no repository and no write path. The immutable **`PassScheduleSnapshot`** value object still applies — a certificate must stay reproducible after the owning system later edits the schedule.
- **`Stand`, `Drawer`, `Edger`, `AlloyProperty`, `SpoolConfiguration`, `PayoffPosition`** — reference data.

⚠ **The surrogate is not the identity.** `FlatWireRun` carries both `[Id] INT IDENTITY` and `[RunId] VARCHAR(20)` — and it is `RunId` that every child table references. Same on `Spool` (`Alpha`) and `CoilOutput` (`CoilAlpha`). So **repositories are keyed by the alpha value object** — `GetByAlpha(RunAlpha)`, not `GetById(int)` — and the alphas of §3.2b are the aggregate identities. Note `Entity.Equals()` and `IsTransient()` operate on `Id`, so **equality is surrogate-based**: do not assume two instances with the same alpha compare equal before both are persisted.

### 3.2b Value objects

**Alphas**, each with a validating constructor, per `[BR §3]`: `RodAlpha` `R#####` · `SpoolAlpha` `SP-#####` · `RunAlpha` `RUN-####` · `CoilAlpha` `FW-#####-C##` · `DieAlpha` `D-{size×1000}-{seq}` · `PassScheduleReference` (opaque). **This closes the format half of `G14` by construction** — a malformed alpha becomes unrepresentable rather than merely discouraged.

**Dimensioned quantities**: `Gauge` (in) · `Width` (in) · `Footage` (ft) · `WeightLb` · `SpeedFpm` · `RollGap` (in) · `RollDiameter` (in). These address `G14`'s footage `DECIMAL`-vs-`INT` ambiguity and the `PLC-Q15` class — with `.Lb` and `.FPM` gone from the tag names **no tag declares a unit**, so a typed quantity catches at compile time what the tag map no longer catches at all.

**`PassScheduleSnapshot`** — immutable record of what was pushed (schedule id, version, effective configuration), so a certificate stays reproducible after the owning system later edits the schedule (`[PLC §11.2]`, `OQ-64`).

### 3.2c Domain events — how side effects reach the hub

§3.2 forbids SignalR types in Application, which leaves handlers no clean way to broadcast. Domain events answer it:

1. The aggregate raises `RunPaused`, `WeldRecorded`, `CoilCompleted`, `BayStateChanged`, `SpoolCompletionPromptRaised` via the inherited `AddDomainEvent`.
2. `FlatWireDbContext.SaveChangesAsync` calls **`DispatchDomainEventsAsync` after commit** — the extension already exists in the template.
3. A handler in Infrastructure/API translates to `IFlatWireClient`. **SignalR stays out of Application entirely** — the rule is satisfied rather than worked around.

### 3.3 CQRS and data access

Data access is **mixed per UAL convention**:

| Access | Technology | Used for |
|---|---|---|
| Entity writes | **EF Core** via `FlatWireDbContext` | Every command — check-in, staging, weld, SPC, override, checkout, coil completion |
| High-volume reads | **Dapper** | Gauge trace, shift summary, list grids, the staging-queue projection |

Two read procedures back the heaviest queries (§6.8): `sp_GetGaugeTrace` and `sp_ShiftSummary`.

### 3.4 Validation, behaviours and errors

| Concern | Implementation |
|---|---|
| Request validation | **FluentValidation** per command, invoked by a MediatR pipeline behaviour — **shape, type and range only**. Field presence, enum membership, `lineId = FL2` rejected at `/staging/rod`. → **`400`** |
| **Domain invariants** | **Enforced in the aggregate** via `CheckRule(IBusinessRule)` → `BusinessRuleValidationException` → **`422`**, with the concrete rules in `Application/BusinessRules/` and the reusable specifications in `Domain/Rules/`. `FM2_S3` must be `Active`; FL3 requires `RouteMode = Hybrid`; bay occupancy (`G21`); rod eligibility; Mode B requires the supervisor stamp |
| Response envelope | `UAController` standard `Data` / `Success` / `Errors` — see `[API §1]` |
| Logging | **Serilog**, structured, with the correlation ID from the inbound header |
| Error handling | Domain rule violation → `422`; concurrency / uniqueness → `409`; not found → `404`; PLC failure → `500` with the transaction aborted and compensating writes issued |
| Concurrency | `ROWVERSION` tokens on **`PassSchedule`, `Rod`, `FlatWireRun`, `Spool`, `RodStaging`, `CoilOutput`** — **six**, counted from a live deploy 15 Aug 2026. ⚠ *`PassSchedule` was removed from this row earlier the same day on the grounds that "MVP-1 never builds it"; **decision `D-31` moved the schedule tables into MVP-1**, so it is back and the reason it left no longer holds. The other half of that correction — adding `RodStaging` — stands.* ⚠ **Open decision `D-30`:** under DDD the token belongs on the **aggregate root**, and three roots — **`WeldEvent`, `RodCheckout`, `WipRejection`** — have none, though all three are mutated after insert (a weld's `Pass`/`Fail`, a checkout's approval stamp, a rejection's disposition). Decide and record; do not leave it silent. *(Re-numbered 15 Aug 2026 from a bare `D1`, which collided with `[PLC]`'s retired `D1`–`D17` log; it is now in `[ARC §13.1]` with the other `D-##` decisions.)* |

---
