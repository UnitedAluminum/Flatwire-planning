# Phase 1B — Execution Orchestration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — **`G6`/`OI-37` answered: the critical path is no longer blocked at node 2.** `FW-145` amber not red, §3 and §5 restated, `P-17` restated *(earlier same day: `P-18` settled; counts to 32, §1.4, §4a register, §8 boundary)*
**Document Type:** Execution index and dependency graph for the Phase-1B implementation plans
**Status:** Active — **the entry point for this folder**
**Owner:** Backend (.NET) + Real-time streams
**Audience:** The delivery lead sequencing Phase 1B, and any developer picking up a story
**Shortcode:** — *(orchestration, derived from the plans and the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — folder index: this file

---

> **What this file is.** The **32 plans** each say *how* to build one story. This says **what
> can start, in what order, and what is stopping it.** It holds no build detail — every
> statement here resolves to a plan, and where this file and a plan disagree, **the plan
> wins**; where a plan and a specification disagree, the specification wins.
>
> **The one thing to read first:** the critical path is **134 h**, and as of **15 Aug 2026
> nothing on it is blocked** — `G6`/`OI-37` was answered and node 2 (`FW-145`) is buildable.
> See §3. What remains is a **verification** dependency, not a build one: the six role claim
> *values* are still unmapped (§5).
>
> **Building the trial rather than the phase?** Its companion is
> **[TrialOrchestration.md](TrialOrchestration.md)** — the same stories on a different axis:
> 66 across four streams, sequenced by **sprint** (T1/T2/T3) rather than by dependency wave,
> with the trial's own blockers and its 330 h of deferrals. This file answers *what can
> start*; that one answers *what ships on 30 Sep*.

---

## 1. Status board

**32 plans.** `phase-01b`'s twenty stories (§1.1–§1.2) · two trial-scope (§1.3) · **ten
trial-path stories from Phases 4–8 (§1.4)**. Hours are `[TB §7]`'s, quoted not restated.

> **§1.1–§1.3 are Phase 1B and are what §2–§6 sequence.** §1.4's ten sit **downstream of the
> phase** and are sequenced by sprint in
> [TrialOrchestration.md](TrialOrchestration.md), not by wave here.

### 1.1 Backend stream — 249 h

| Plan | Story | h | Wave | Status |
|---|---|---|---|---|
| [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | Solution + 4-project skeleton | 16 | **0** | Ready — gates everything · `P-01`, `P-02` |
| [FW-138](FW-138-Fifteen-Thin-Controllers.md) | Fifteen thin controllers | 45 | 1 | ⚠ **`P-06` must be settled first** |
| [FW-139](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) | MediatR + behaviours | 16 | 1 | Ready — one behaviour waits on `FW-142` (`P-10`) |
| [FW-140](FW-140-DI-Registration-And-Stub-Swap.md) | DI + `useMockData` swap | 12 | 1 | Ready |
| [FW-141](FW-141-Repository-Layer.md) | Seven repositories | 28 | 1 | Ready — **also needs 1C `FW-006`** |
| [FW-142](FW-142-Dapper-EF-And-FlatWireDbContext.md) | `FlatWireDbContext` + Dapper | 24 | 1 | ⚠ `P-13` · **converges with 1C `FW-006`/`FW-007`** |
| [FW-143](FW-143-Serilog-And-Audit-Log.md) | Serilog + audit log | 12 | 1 | ⚠ **audit half has no persistence target** (`P-15`) |
| [FW-144](FW-144-Configuration-Binding.md) | Configuration binding | 12 | 1 | Ready — map *contents* blocked, shape is not |
| [FW-145](FW-145-JWT-And-Role-Policies.md) | JWT + role policies | 16 | 1 | ⚠ **Unblocked 15 Aug** — `G6` answered; six claim *values* still unmapped |
| [FW-146](FW-146-Exception-Middleware-And-Envelope.md) | Exception middleware | 8 | 1 | ⚠ inherits `P-06` — **`P-18` settled 15 Aug** |
| [FW-147](FW-147-FluentValidation-Value-Objects-And-Enums.md) | Validation + 14 enums | 12 | 1 | Ready — two rules hand off to `FW-207` |
| [FW-148](FW-148-Health-Checks.md) | Health checks | 8 | 1 | ⚠ `P-20` route decision |
| [FW-207](FW-207-Domain-Model.md) | Domain model (`D-29`) | 32 | 1 | Ready — `D-30` open on 3 of 7 roots |
| [FW-208](FW-208-Domain-Events-Post-Commit-Dispatch.md) | Domain-event dispatch | 8 | 3 | Ready |

### 1.2 Real-time stream — 124 h

| Plan | Story | h | Wave | Status |
|---|---|---|---|---|
| [FW-080](FW-080-FlatWireHub.md) | `FlatWireHub` | 28 | 2 | ⚠ `G10` provisioning · `G9` no pass criteria |
| [FW-151](FW-151-PLCTagService.md) | `PLCTagService` + simulate | 16 | 2 | ⚠ compensation design blocked on `G2` |
| [FW-149](FW-149-IFlatWireClient.md) | `IFlatWireClient` | 16 | 3 | Ready — interface minted by `FW-080` (`P-22`) |
| [FW-N05](FW-N05-OPC-Ingest-And-Bounded-Channel.md) | OPC ingest + channel | 32 | 3 | ⏸ **Deferred to commissioning — contract still due now** (`P-29`) |
| [FW-150](FW-150-Broadcast-Loop.md) | Broadcast loop | 16 | 4 | Ready — **unreduced for the trial** |
| [FW-205](FW-205-ITInhibitService.md) | `ITInhibitService` | 16 | 4 | Ready — **closes exit criterion 5** |

### 1.3 Trial scope — additive to `[CE §3b]`, offsets nothing

| Plan | Story | h | Wave | Status |
|---|---|---|---|---|
| [FW-203](FW-203-OPC-Feed-Simulator.md) | OPC feed simulator | 8 | 5 | Ready — **must drive FL2** |
| [FW-218](FW-218-Sim-Control-Surface.md) | Sim control surface | 18 | 6 | Ready — resolves `G43` |

### 1.4 Trial-path plans — Phases 4–8, downstream of this phase

Server-side stories on the 30 Sep trial's path. **Not part of Phase 1B**, so they do not
appear in §2's graph, §3's critical path or §6's exit criteria — they are sequenced by sprint
in [TrialOrchestration.md](TrialOrchestration.md).

| Plan | Story | h | Stream | Phase | Status |
|---|---|---|---|---|---|
| [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md) | `POST /checkin/rod` + `CheckInService` | 36 | BE | 4 | ⚠ **Provisional until `G2` closes**; trial runs it **without `RodStaging`** |
| [FW-082](FW-082-PLC-Tag-Push-On-Acknowledgement.md) | PLC tag group push on acknowledgement | 16 | RT | 4 | ⚠ Four blockers · `G29` leaves a payload value with nowhere to write |
| [FW-164](FW-164-Run-Queries-And-RunQueryService.md) | `GET /run/active` + `gaugetrace` | 12 | BE | 5 | ⚠ **The trial's landing route** since DB1 left scope |
| [FW-168](FW-168-Spc-And-SpcService.md) | `POST /spc` + `SpcService` | 12 | BE | 6 | ⚠ Tolerance band unseeded (`Q22`) |
| [FW-170](FW-170-Pause-Resume-And-RunControlService.md) | pause / resume + `RunControlService` | 8 | BE | 6 | Ready — four resume outcomes |
| [FW-172](FW-172-Run-Event-Markers.md) | Run-event markers + `LineStatus` | 20 | RT | 6 | Ready — four of six markers (`P-45`) |
| [FW-174](FW-174-WipRejection-And-Checkout-Services.md) | `POST /wipreject` + `POST /checkout` | 24 | BE | 7 | ⚠ **`G24`: Mode B's constraint has no columns yet** |
| [FW-177](FW-177-Exception-Broadcasts.md) | Exception broadcasts + supervisor notify | 16 | RT | 7 | ⚠ `FW-175` deferred — notification is transient |
| [FW-179](FW-179-CheckIn-Spool-And-Spools-Query.md) | `POST /checkin/spool` + `GET /spools` | 18 | BE | 8 | ⚠ **`[API §4.6a]`'s worked example is stale** |
| [FW-181](FW-181-FL2-Null-Gauge-Contract.md) | FL2 null-gauge contract | 4 | RT | 8 | ⚠ *"the single most likely thing to ship wrong"* |

---

## 2. Dependency graph

> **This graph is Phase-1B-scoped by design.** It shows §1.1–§1.3's twenty-two stories and
> the two 1C edges that enter them. **§1.4's ten are deliberately absent** — they sit in
> Phases 4–8, their ordering is by sprint rather than by wave, and merging two axes into one
> diagram is how a map stops being readable. Their sequencing is
> [TrialOrchestration.md](TrialOrchestration.md).

```mermaid
graph LR
  N04["FW-N04 · skeleton"]

  N04 --> C138["FW-138 controllers"]
  N04 --> C139["FW-139 MediatR"]
  N04 --> C140["FW-140 DI"]
  N04 --> C141["FW-141 repositories"]
  N04 --> C142["FW-142 DbContext"]
  N04 --> C143["FW-143 Serilog"]
  N04 --> C144["FW-144 config"]
  N04 --> C145["FW-145 JWT ⛔"]
  N04 --> C146["FW-146 middleware"]
  N04 --> C147["FW-147 validation"]
  N04 --> C148["FW-148 health"]
  N04 --> C207["FW-207 domain"]

  C145 --> C080["FW-080 hub"]
  C144 --> C151["FW-151 PLCTagService"]

  C080 --> C149["FW-149 IFlatWireClient"]
  C080 --> N05["FW-N05 ingest ⏸"]
  C144 --> N05
  C207 --> C208["FW-208 dispatch"]
  C142 --> C208
  C080 --> C208

  N05 --> C150["FW-150 broadcast"]
  C149 --> C150
  C151 --> C205["FW-205 ITInhibit"]
  N05 --> C205

  C150 --> C203["FW-203 simulator"]
  C203 --> C218["FW-218 sim control"]
  C138 --> C218
  C145 --> C218

  DB(["1C · FW-006 / FW-007"]) -.-> C141
  DB -.-> C142
```

**Waves** — level = 1 + the deepest dependency:

| Wave | Stories | Note |
|---|---|---|
| **0** | `FW-N04` | The single root. **Nothing else starts.** |
| **1** | `FW-138` `FW-139` `FW-140` `FW-141` `FW-142` `FW-143` `FW-144` `FW-145` `FW-146` `FW-147` `FW-148` `FW-207` | **Twelve unlock at once** — the parallelism opportunity |
| **2** | `FW-080` `FW-151` | |
| **3** | `FW-149` `FW-N05` `FW-208` | |
| **4** | `FW-150` `FW-205` | |
| **5** | `FW-203` | trial |
| **6** | `FW-218` | trial |

> **Two dashed edges leave the phase.** `FW-141` and `FW-142` need **1C**'s `FW-006`/`FW-007`.
> `phase-01b` L27: *"1B ships **stub** endpoints returning schema-valid fixtures first so 1A
> can build against the real service early, and wires the real repositories to 1C's
> `FlatWireDB` as the schema lands."* **The stub path is unblocked immediately** — only the
> real repository wiring waits.

---

## 3. The critical path — clear as of 15 Aug 2026

```
FW-N04 (16) → FW-145 (16) → FW-080 (28) → FW-N05 (32) → FW-150 (16) → FW-203 (8) → FW-218 (18)
                  ✅ unblocked 15 Aug
```

**134 h**, and it runs almost entirely through the **RT stream**, not the 249 h of backend
bulk. Three consequences:

1. **No plan is marked `Blocked` any more.** `G6`/`OI-37` — whether the six roles exist as
   JWT claims — **was answered on 15 Aug 2026: they do, on the standard `ClaimTypes.Role`.**
   `phase-01b` L91's *"can block the build outright"* and `[TRP §6]`'s 28 Aug date are both
   **spent**, and node 2 is buildable today. ⚠ **One residual, and it moved rather than
   closed:** the six claim *values* are abbreviated or coded rather than `[SEC §8]`'s labels,
   and the mapping has not been supplied. It gates **verification, not construction** —
   `FW-145` §5 absorbs it into a six-constant class — so it is now a QA0 dependency rather
   than a critical-path one. See §5.
2. **Staffing the backend stream harder does not shorten the phase.** BE 249 h is wide and
   shallow — twelve stories unlock together at wave 1; RT 124 h is narrow and deep.
   `[TRP §1.4]`: RT *"none of it compresses well — 0.75–0.90 against FE's 0.62."*
3. **`FW-N05` sits mid-path and is deferred.** `FW-203` stands in for the trial, but
   **`FW-N05`'s contract is still due now** (`P-29`) — a deferred story whose contract is
   also deferred cannot be stood in for.

> *The 134 h is derived here for sequencing only. It re-states no published total and
> changes no figure in `[CE]`, `[DE]`, `[SSP]`, `[TRP]` or `[TB §7]`.*

---

## 4. Ratification gates — five decisions to clear

Each **blocks the named story** until settled. All are in the plans' §5 with rationale and a
fallback.

| Decision | Blocks | The question |
|---|---|---|
| **`P-01`** | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | Scaffold from `UATemplate` where the card says *"copied from `CoilCheckin`"* |
| **`P-02`** | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) → `FW-139`, `FW-140` | `Infrastructure → Domain` per `[SVC §3.1]`, against `CoilCheckin`'s `Infrastructure → Application` |
| **`P-06`** 🔴 | [FW-138](FW-138-Fifteen-Thin-Controllers.md) **step 3** → `FW-146` | **No framework type produces `[API §1.2]`'s envelope.** The widest-reaching of the five |
| **`P-13`** | [FW-142](FW-142-Dapper-EF-And-FlatWireDbContext.md) | `PassSchedule*` mapped read-only — `D-31` owns the tables, `[SVC §3.2a]` forbids the write path |
| **`P-20`** | [FW-148](FW-148-Health-Checks.md) | `/health` base-relative vs absolute; `phase-01b` L95 assigns the tiebreak here |

> **`P-06` first.** It blocks `FW-138`'s 45 h and `FW-146`'s 8 h, and if ratification prefers
> `ActionResultBase<T>` then `[API §1.2]` changes instead — **a contract change across every
> 1A screen**, not a backend detail. Escalate rather than absorb.

### 4a. Decision register — `P-01` to `P-49`

Every decision the plans make. **§4 above is this table filtered to `⚠ ratify`.** Each `P-##`
is defined once, in the plan named here, with its rationale and fallback.

| id | Plan | Subject | |
|---|---|---|---|
| `P-01` | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | Scaffold from `UATemplate`; `CoilCheckin` stays the reference | ⚠ ratify |
| `P-02` | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | MediatR bootstrap in `FlatWire.API`, keeping `Infrastructure → Domain` | ⚠ ratify |
| `P-03` | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | `FlatWire.*` namespaces and assembly names | settled |
| `P-04` | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | Controller routing — class-level base, explicit per-action routes | settled |
| `P-05` | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) | A fresh `launchSettings.json` port set | settled |
| `P-06` | [FW-138](FW-138-Fifteen-Thin-Controllers.md) | **Build the response envelope; the framework does not supply it** | ⚠ ratify |
| `P-07` | [FW-138](FW-138-Fifteen-Thin-Controllers.md) | The seven deferred endpoints are absent, not stubbed | settled |
| `P-08` | [FW-138](FW-138-Fifteen-Thin-Controllers.md) | Fixtures live per controller, not in one shared class | settled |
| `P-09` | [FW-139](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) | Scrutor scan, not `AddMediatR` | settled |
| `P-10` | [FW-139](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) | `TransactionBehaviour` lands with `FW-142` | settled |
| `P-11` | [FW-140](FW-140-DI-Registration-And-Stub-Swap.md) | Swap resolved at startup; the flag is `useMockData` | settled |
| `P-12` | [FW-141](FW-141-Repository-Layer.md) | Build the seven; **no `PassScheduleRepository` or `RodRepository`** | settled |
| `P-13` | [FW-142](FW-142-Dapper-EF-And-FlatWireDbContext.md) | Map 33 tables for reading; `PassSchedule*` gets **no write path** | ⚠ ratify |
| `P-14` | [FW-142](FW-142-Dapper-EF-And-FlatWireDbContext.md) | Interim stance on `D-30` | settled |
| `P-15` | [FW-143](FW-143-Serilog-And-Audit-Log.md) | **The audit log has no persistence target** — open finding | ⚠ open |
| `P-16` | [FW-144](FW-144-Configuration-Binding.md) | Fail fast at boot; warn **once**, with a count | settled |
| `P-17` | [FW-145](FW-145-JWT-And-Role-Policies.md) | Six policies from `[SEC §8]`; **six role constants, not one claim-type constant** — restated 15 Aug when `G6`'s answer retired the original hedge | settled |
| `P-18` | [FW-146](FW-146-Exception-Middleware-And-Envelope.md) | Remove `HttpGlobalExceptionFilter` — **forced, not chosen** | **settled 15 Aug** |
| `P-19` | [FW-147](FW-147-FluentValidation-Value-Objects-And-Enums.md) | `FM2_S3`-Active and FL3⇒Hybrid go in the aggregate | settled |
| `P-20` | [FW-148](FW-148-Health-Checks.md) | Serve `/health` at both paths; the absolute one is canonical | ⚠ ratify |
| `P-21` | [FW-080](FW-080-FlatWireHub.md) | Add the MessagePack package; **measure before committing** | settled |
| `P-22` | [FW-080](FW-080-FlatWireHub.md) | `IFlatWireClient` lands here though it is `FW-149`'s | settled |
| `P-23` | [FW-207](FW-207-Domain-Model.md) | Build the two unverifiable criteria anyway | settled |
| `P-24` | [FW-207](FW-207-Domain-Model.md) | Interim stance on `D-30` | settled |
| `P-25` | [FW-205](FW-205-ITInhibitService.md) | **The absent clear path is a deliverable, and needs a guard** | settled |
| `P-26` | [FW-205](FW-205-ITInhibitService.md) | Surface for three lines, behaviour for two | settled |
| `P-27` | [FW-151](FW-151-PLCTagService.md) | All six operations now; compensation shape waits on `G2` | settled |
| `P-28` | [FW-N05](FW-N05-OPC-Ingest-And-Bounded-Channel.md) | Size the channel by configuration; record it as provisional | settled |
| `P-29` | [FW-N05](FW-N05-OPC-Ingest-And-Bounded-Channel.md) | The contract is frozen before the simulator uses it | settled |
| `P-30` | [FW-150](FW-150-Broadcast-Loop.md) | Fixed cadence, not adaptive; the ratio is provisional | settled |
| `P-31` | [FW-150](FW-150-Broadcast-Loop.md) | The loop is unreduced for the trial | settled |
| `P-32` | [FW-149](FW-149-IFlatWireClient.md) | The `FW-136` match is a manual diff with a named owner | settled |
| `P-33` | [FW-149](FW-149-IFlatWireClient.md) | The interface is a published contract from `FW-080`'s first commit | settled |
| `P-34` | [FW-208](FW-208-Domain-Events-Post-Commit-Dispatch.md) | Prove the SignalR-free Application layer by project reference | settled |
| `P-35` | [FW-208](FW-208-Domain-Events-Post-Commit-Dispatch.md) | Translation handlers live in Infrastructure | settled |
| `P-36` | [FW-203](FW-203-OPC-Feed-Simulator.md) | Build the levers here, expose them in `FW-218` | settled |
| `P-37` | [FW-203](FW-203-OPC-Feed-Simulator.md) | No new interface, and no simulator-aware branch downstream | settled |
| `P-38` | [FW-218](FW-218-Sim-Control-Surface.md) | Conditional route registration, not a policy guard | settled |
| `P-39` | [FW-218](FW-218-Sim-Control-Surface.md) | An increment of `FW-215` — a subset, not a variant | settled |
| `P-40` | [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md) | Ordered path now; recovery **strategy** behind `G2` | settled |
| `P-41` | [FW-082](FW-082-PLC-Tag-Push-On-Acknowledgement.md) | Push edge type with its path unresolved, and **fail loudly** | settled |
| `P-42` | [FW-164](FW-164-Run-Queries-And-RunQueryService.md) | Read the order block through a view; the DTO carries nulls | settled |
| `P-43` | [FW-168](FW-168-Spc-And-SpcService.md) | The tolerance band is data, and it is **unseeded** | settled |
| `P-44` | [FW-170](FW-170-Pause-Resume-And-RunControlService.md) | Four resume outcomes; the greyed one still exists | settled |
| `P-45` | [FW-172](FW-172-Run-Event-Markers.md) | This story owns four markers; the other two are `FW-177`'s | settled |
| `P-46` | [FW-174](FW-174-WipRejection-And-Checkout-Services.md) | Persist PENDING DISPOSITION here; the queue is `FW-175`'s | settled |
| `P-47` | [FW-177](FW-177-Exception-Broadcasts.md) | Broadcast to a group, not to a connection | settled |
| `P-48` | [FW-179](FW-179-CheckIn-Spool-And-Spools-Query.md) | `404` means the alpha does not exist, and nothing else | settled |
| `P-49` | [FW-181](FW-181-FL2-Null-Gauge-Contract.md) | The client binds to **route mode**; the server must publish it | settled |

> **`settled` means decided and recorded, not ratified by a third party** — it means the plan
> made the call, gave its reasoning, and nothing blocks building to it. **New decisions are
> minted at `P-50`+**, and the series stays continuous across the folder.

---

## 5. Blocker calendar

| By | Blocker | Stops | Plan |
|---|---|---|---|
| ~~28 Aug~~ ✅ **Closed 15 Aug** | ~~**`G6` / `OI-37`** — roles as JWT claims~~ | ~~🔴 The critical path~~ — **answered: the six roles exist on `ClaimTypes.Role`** | [FW-145](FW-145-JWT-And-Role-Policies.md) |
| **Before QA0** *(not before the build)* | **`G6` residual** — the six role claim **values**, which are coded rather than `[SEC §8]`'s labels | ⚠ **Verification, not construction.** The build proceeds against `FlatWireRoles`' six constants; §6's matrix walk cannot pass until the mapping lands. **Fails closed in `FW-145` and *silent* in `FW-177`** | [FW-145 §5](FW-145-JWT-And-Role-Policies.md) · [FW-177 §3.1](FW-177-Exception-Broadcasts.md) |
| **Before T2** | **`G10`** — IIS WebSockets on the target | Transport **silently** falls back to long-poll; cadence assertions change character. **A provisioning task, not a build one** | [FW-080](FW-080-FlatWireHub.md) |
| **Before T2** | **`G2` / `OI-39`** — cross-DB check-in recovery | Compensation design; carries the **24–64 h** reserve. Phase 4 provisional until it closes. ⚠ **Settle `G30` first** | [FW-151](FW-151-PLCTagService.md) · [FW-146](FW-146-Exception-Middleware-And-Envelope.md) · [FW-143](FW-143-Serilog-And-Audit-Log.md) |
| **Before the Phase-4 schema freeze** | **`D-30`** — `ROWVERSION` absent on `WeldEvent`, `RodCheckout`, `WipRejection` | 3 of the 7 aggregate roots, all mutated after insert | [FW-207](FW-207-Domain-Model.md) · [FW-142](FW-142-Dapper-EF-And-FlatWireDbContext.md) · [FW-141](FW-141-Repository-Layer.md) |
| **Before Phase 8 ships** | **`OI-47`** — hybrid-origin guard is *undefined*, not merely open | `TC-118` is P1 and reads *"gate fails until specified"* | [FW-138](FW-138-Fifteen-Thin-Controllers.md) *(de-stub)* |
| No date | **`G9` / `OI-34`** — real-time NFRs undefined | **Blocks validation, not build** — the channel cannot be sized and the load test cannot fail | [FW-N05](FW-N05-OPC-Ingest-And-Bounded-Channel.md) · [FW-150](FW-150-Broadcast-Loop.md) · [FW-080](FW-080-FlatWireHub.md) · [FW-148](FW-148-Health-Checks.md) |
| No date | **`G33` / `PLC-Q05`** — all 41 measure segments are ours | ⚠ **A wrong path fails silently** — the write reports success while the line keeps its previous settings | [FW-151](FW-151-PLCTagService.md) · [FW-144](FW-144-Configuration-Binding.md) · [FW-143](FW-143-Serilog-And-Audit-Log.md) |
| No date | **`P-15`** — the audit log has no persistence target | AC 3 of `FW-143` cannot be met; would be a 29th table via 1C | [FW-143](FW-143-Serilog-And-Audit-Log.md) |

✅ **`G38` closed 15 Aug 2026** — `FlatWireRun`'s five prompt columns landed, so exit
criterion 4's durability half is buildable. ⚠ **It carries 0 h anywhere** — see §8.

---

## 6. Exit criteria → owning plans

`phase-01b`'s six. **The phase is not done until each maps to a signed-off plan.**

| # | Criterion | Owning plan(s) |
|---|---|---|
| 1 | `FlatWire.sln` builds; API boots with `useMockData` on | [FW-N04](FW-N04-FlatWire-Solution-Skeleton.md) · [FW-140](FW-140-DI-Registration-And-Stub-Swap.md) |
| 2 | Fifteen controllers, `UAController`, `[Authorize]`, envelope | [FW-138](FW-138-Fifteen-Thin-Controllers.md) · [FW-145](FW-145-JWT-And-Role-Policies.md) |
| 3 | Stubs + five `[API §7.2]` obligations · middleware · **`201`/`Blocked`** · error codes | [FW-138](FW-138-Fifteen-Thin-Controllers.md) · [FW-146](FW-146-Exception-Middleware-And-Envelope.md) |
| 4 | Hub streams batched telemetry · **twelve events + six markers** · prompt survives reconnect · simulate logs an audit entry | [FW-080](FW-080-FlatWireHub.md) · [FW-149](FW-149-IFlatWireClient.md) · [FW-150](FW-150-Broadcast-Loop.md) · [FW-151](FW-151-PLCTagService.md) · [FW-143](FW-143-Serilog-And-Audit-Log.md) |
| 5 | **`ITInhibitService`** — conditions 3–5, line-scoped, **no operator clear path** | [FW-205](FW-205-ITInhibitService.md) |
| 6 | `/health` green + **QA0 walkthrough signed off by a named reviewer** | [FW-148](FW-148-Health-Checks.md) · [FW-138 §6.1](FW-138-Fifteen-Thin-Controllers.md) |

> 🔴 **Criterion 6 has no reviewer.** `phase-01b` L124: *"needs a named reviewer and a slot in
> the 12-day window **or the Phase-1 gate has no 1B criterion at all**."* With **no automated
> backend tests** (`[TS §1.2]`), the walkthrough is the entire verification of this layer.
> The checklist is [FW-138 §6.1](FW-138-Fifteen-Thin-Controllers.md); **`reviewer: TBD`.**

---

## 7. Two tracks — know which you are building

| | **MVP-1** | **Trial (30 Sep)** |
|---|---|---|
| `FW-138` | **15** controllers | **8** — and only **6** serve a screen ([§3.0a](FW-138-Fifteen-Thin-Controllers.md)) |
| OPC ingest | `FW-N05`, real | `FW-203` simulator |
| Control surface | — | `FW-218` |
| Hours basis | `[TB §7]` hand-coded | `[TRP §1.4]` AI-assisted |

**The trial has its own orchestration** — [TrialOrchestration.md](TrialOrchestration.md) —
covering all **66** trial stories across four streams by sprint, with **ten further
server-side plans** beyond this phase's 22: [FW-157](FW-157-CheckIn-Rod-And-CheckInService.md)
· [FW-082](FW-082-PLC-Tag-Push-On-Acknowledgement.md)
· [FW-164](FW-164-Run-Queries-And-RunQueryService.md) · [FW-168](FW-168-Spc-And-SpcService.md)
· [FW-170](FW-170-Pause-Resume-And-RunControlService.md) · [FW-172](FW-172-Run-Event-Markers.md)
· [FW-174](FW-174-WipRejection-And-Checkout-Services.md) · [FW-177](FW-177-Exception-Broadcasts.md)
· [FW-179](FW-179-CheckIn-Spool-And-Spools-Query.md) · [FW-181](FW-181-FL2-Null-Gauge-Contract.md).

⚠ **`[TRP]`: *"never mix a `[DE §2]` stream cell with a `[SSP §5]` one."*** The two models
re-derive on their own retention factors and **disagree on Phase-1B RT by up to 19 h.**

---

## 8. What this folder does not cover

> **The scope, stated once.** This folder plans **Phase 1B** and **the trial's server-side
> path** (Phases 4–8). **MVP-1 Phases 9–14 are not planned here**, and neither are the FE and
> DB streams — those live in `ual-angular` and `Database/Schema/SQL/`, with their rules in
> `Business/Screens/` and the DDL.
>
> ⚠ **Silence is not coverage.** §8.3 names every backend story the folder leaves out, because
> a boundary that is only implied gets read as completeness.

| Item | Why |
|---|---|
| `FW-206` — `ITInhibit` conditions 1–2 | **Phase 4**, not 1B. ⚠ `TC-011`/`TC-012` are **not** QA0's — running them fails against code never in scope here |
| `FW-N11` — operator session | Uncosted; `FW-205` took the `ITInhibit` half |
| `FW-210` `FW-212` `FW-213` `FW-215` `FW-217` | Simulator set — unscheduled, additive |
| `FW-214` — console `DB-S1` | FE stream; ships with controls **greyed** |
| `FW-211` — the `IReadingSource` seam | 1B owns it, but it is **unscheduled and additive** |

### 8.1 Three findings raised and deliberately not fixed

All hours-bearing, so recorded rather than edited:

1. **`FW-218` appears nowhere in `phase-01b`** — zero occurrences, though it has a full card
   in `[TB §7]` and a row in `[TRP §1.4]`.
2. **`[TRP §1.4]`'s 1B Full column sums to 260 against a stated 268** — 8 h unaccounted, not
   fixable without knowing the intended row. *(The Trial column reconciles exactly to 231.)*
3. **`G38`'s durability carries 0 h anywhere**, while exit criterion 4 requires it.

### 8.2 Three stale sites outside this folder, still uncorrected

`G40` demoted `PS-1100-FL2-001` to **`Hybrid`/`Inactive`**; **`PS-1100-FL2-002`** is the FL2
happy path. Still stale:

- `[API §7.2]`'s fixture callout
- **`[API §4.6a]`'s `POST /checkin/spool` worked example** — shows a check-in the contract
  must refuse **twice**, by `SCHEDULE_NOT_ACTIVE`/`422` and by `FR-091`
- the seed file's §8 banner comment, reading *"Hybrid · Active"* above an `Inactive` row

**The plans are correct** ([FW-138 §4](FW-138-Fifteen-Thin-Controllers.md),
[FW-203 §3.1](FW-203-OPC-Feed-Simulator.md)); the contract a developer copies from is not.

### 8.3 The nine backend stories with no plan and no other home

Every other BE/RT story in `[TB §7]` is either planned here or named above. **These nine are
not**, and two of them are in-scope MVP-1 work rather than deferred scope:

| Story | Phase | Subject | |
|---|---|---|---|
| `FW-185` | 9 | `POST /coil/complete`, `GET /coil/{alpha}/label` | ⚠ **Phase 9 is *wholly MVP-1*** |
| `FW-187` | 9 | Completion broadcasts | ⚠ **in scope, unplanned** |
| `FW-190` | 10 | Hybrid single-batch PLC push and `RouteMode` | ⚠ overlaps [`FW-181`](FW-181-FL2-Null-Gauge-Contract.md) `P-49` |
| `FW-192` | 10 | Continuous end-to-end trace on FL3 | |
| `FW-090` | 11 | Flattening Lines report tab and reporting | |
| `FW-101` | 12 | Weld traceability attribution in yield | |
| `FW-196` | 13 | Alloy CRUD, machine config, role config | |
| `FW-198` | 13 | Reference-data change broadcast | |
| `FW-200` | 14 | PLC commissioning support | ⚠ **already cited by [`FW-082`](FW-082-PLC-Tag-Push-On-Acknowledgement.md)** |

**`FW-185` and `FW-187` are the ones to watch.** Phase 9 is **wholly MVP-1** — `CoilOutput`
and `CoilTraceability` returned to MVP-1 on 11 Aug 2026 because the coil genealogy behind the
**welding-wire customer certificates** is an MVP-1 obligation — so these are not deferred,
only unplanned. They sit outside the trial, which is why they have not been reached.

---

## 9. Keeping this file true

- **A plan changes → check §1's status and §4's gate.** Nothing else here restates plan
  content, so nothing else drifts.
- **A decision is ratified → strike it from §4** and note the outcome in the owning plan's §5.
- **A blocker closes → strike it from §5** and update the owning plan's open-items table.
- **Never add build detail here.** It belongs in the plan; two homes is how the six PLC tag
  copies happened.
- **Never restate an hour figure.** §1 quotes `[TB §7]`; §3's 134 h is derived for sequencing
  and is not a published total.
- Per repository convention, changes go in [`CHANGELOG.md`](../../../../CHANGELOG.md) — **do
  not add a change log to this file.**
