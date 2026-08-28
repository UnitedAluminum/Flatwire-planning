# FW-223 — Rod Ingestion: populating the FlatWire tables

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — flagged that `GET /rod/{alpha}` left the service (`FW-138` `P-53`): **`FR-530` stands as a rule** but its acceptance criterion cannot be exercised here until `P-54` closes. Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Status:** **Ready to build — the procedure is written and parses clean; no sign-off items, one deployment prerequisite shared with `FW-220`**
**Story:** `FW-223` · **Phase:** 4 · **Sprint:** S2 · **Streams:** DB + BE
**Hours:** **14 h** (DB 10 · BE 4). **Additive** to the 3,186 h baseline, like `FW-202`, `FW-219` and `FW-220`–`FW-222`
**Requirements:** `FR-529`–`FR-532` (`[REQ §5.27]`) · **Specification:** `[INT §7.9]`
**Artifacts:**
- [`Database/Scripts/30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql`](../../Database/Scripts/30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql) — it sits with the four cross-database procedures rather than in the schema runner, because it reads `proddb..coils` and `united_db..alloys` and so cannot be verified by a `FlatWireDB`-only deploy
- [`Database/Schema/SQL/FlatWire_SampleData_RunAll.sql`](../../Database/Schema/SQL/FlatWire_SampleData_RunAll.sql) — new, and the seed block removed from `FlatWire_DDL_RunAll.sql`

**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

## Why this story exists

**Nothing populated `FlatWireDB.Rod` in production.**

Rod receiving is `FW-020`–`FW-022`. Those stories are **upstream**, were deleted from this backlog on 13 Aug 2026 as another team's work, and write `proddb..coils` — not `FlatWireDB`. The only thing that has ever put a row in `Rod` is `FlatWire_SampleData_Materials.sql`, which seeds eight fake rods `R00041`–`R00048`.

`FK_RodCheckin_Rod` and `FK_RodStaging_Rod` are **enforced** (`06_ForeignKeys.sql:102` and `:138`). So on a clean production database, **the first staging or check-in fails on a foreign key**. Not a latent risk — the first real operation.

That is **`OI-42`**, open since the `D-04` hybrid-foundation decision retained `Rod` as a local master, and described in `[DBD]` as *"a real design hole, not a documentation nit: it creates two sources of truth for rod material with no reconciliation."* It has two halves and this story answers both: **when** the mirror is populated, and **which side is master for each column**.

> The question that surfaced it was simply *"when does data get into the flat wire tables, e.g. the rod table?"* — and the honest answer was *"it doesn't."*

---

## Reference context — do not restate

- `[INT §7.9]` is the specification of record — the lifecycle table, the column-ownership split and the three deliberate-looking-like-defects.
- The procedure's own header block carries the four table constraints (`C1`–`C4`) with their reasoning. **Read it before changing a line.**
- `40_united_db_Proc_FlatWire_CheckInRod.sql` is the sibling for the transaction contract; this procedure uses the same caller-owns-the-transaction rule.

---

## What to build

### 1. `sp_IngestRodFromCoils` (DB, 8 h) — written

In **`FlatWireDB`**, but shipped in `Database/Scripts/` with the four `united_db` procedures rather than in the schema runner — it reads `proddb..coils` and `united_db..alloys`, so unlike every object in `FlatWire_DDL_RunAll.sql` it cannot be verified by a `FlatWireDB`-only deploy, and it needs the same grants and the same co-located instance they do. Projects one rod into the local mirror, inside the caller's transaction.

**Why a procedure and not an EF write, given `[SVC §3.3]` puts entity writes in EF.** `Rod` is explicitly **not an aggregate** — `[SVC §3.2a]` lists it under *"Not aggregates, each for a reason"* as *"a `FlatWireDB`-local mirror of `coils` (`D-04`); `coils` owns the lifecycle. **Read model**."* A read model with no aggregate has no EF write path, by exactly the reasoning `P-13` used to keep `PassSchedule` Dapper-only. A projection from another database is also `[SVC §3.3]`'s *"cross-DB reads"* row rather than its entity-writes row. **This is the convention, not an exception to it.**

### 2. Two call sites (BE, 4 h)

First statement inside the existing transaction, **before any other `FlatWireDB` write**:

| Path | Story | Why |
|---|---|---|
| `POST /staging/rod` | `FW-158` | `FK_RodStaging_Rod` is enforced |
| `POST /checkin/rod` | `FW-157` / `FW-159` | `FK_RodCheckin_Rod` is enforced, and a direct scan into Dashboard 2 is a supported path — check-in cannot assume staging ran |

**Not `GET /rod/{alpha}`.** It is documented `Idempotent` and any authenticated role may call it, so a supervisor scanning a rod merely to look at it must not create records (`FR-530`).

> ⚠ **That endpoint has left this service — `FW-138`'s `P-53`, 25 Aug 2026.** Rod receiving is not shopfloor, so `RodReceivingController` and all three `/rod/**` endpoints are withdrawn, and their re-homing is `[API]`'s (`P-54`). **`FR-530` is unaffected as a rule** — the ingestion procedure must not fire on a read, wherever that read ends up living — but the acceptance criterion below **cannot be exercised against this service** until `P-54` closes.

### 3. Sample data out of the schema runner (DB, 2 h) — done

The five `FlatWire_SampleData_*.sql` files moved from `FlatWire_DDL_RunAll.sql` into a new `FlatWire_SampleData_RunAll.sql`. See *The seed was actively harmful* below.

---

## The five things most likely to be got wrong

| # | Trap | What to do |
|---|---|---|
| 1 | **It is not a `MERGE`, and making it one breaks two features silently.** `Status`, `FootageRunToDate` and `RemainingWeightEstimateLb` are **locally mastered** | Refresh shared-mastered columns only. `Status` carries `INFLAT` (`FlatWireDB`-local since `D-32`) — resetting it un-marks a running rod. `FootageRunToDate` is the carry-forward evidence `PRC007` needs; clearing it offers a fresh-start check-in for a rod that has already run, which `FR-043` forbids |
| 2 | **`proddb..coils` has no rod-diameter column.** The nearest is `coil_gauge`, a **strip gauge** | Take the operator's measurement, which both write paths already carry. `Rod.DiameterIn` is `NOT NULL` with `CHECK > 0`. Reading `coil_gauge` as a wire diameter would be a convention dressed as a fact |
| 3 | **The alloy is a lookup, not a cast.** `coils.coil_alloy` is `smallint`; `Rod.Alloy` is `varchar(10)` holding `'1100'` | Resolve through `united_db..alloys` (`alloy_idx` → `alloy`). Storing the code as text does **not** fail — it silently stops every alloy comparison downstream from matching. Throws `55005` when the lookup misses |
| 4 | **`SupplierHeat` has no source and must stay `NULL`** | Leave it. `OI-117`. Do not invent a value and do not reuse `coil_origin_code`, which is a one-character origin flag, not a heat number |
| 5 | **The caller owns the transaction** | Assert `@@TRANCOUNT > 0` (`55001`). It runs inside the same transaction as the run and check-in writes, so a `THROW` dooming that transaction is the intended behaviour. No savepoint |

---

## The seed was actively harmful, not merely untidy

`FlatWire_DDL_RunAll.sql` included the five sample-data files **unconditionally**. Every schema deployment inserted eight fake rods plus fake runs, check-ins, coil outputs and quality records.

Harmless while `FlatWireDB` lived on `(localdb)\MSSQLLocalDB`. **Not harmless once the runner is pointed at the shared instance** — which `FW-220` made a prerequisite and which is the next thing this project does. And it undermines this story directly: the ingest **creates or refreshes**, so a seeded `R00041` that never came from `coils` is silently *refreshed*, and the mirror carries a rod the shared schema has never heard of.

⚠ **A conditional include was not possible.** `:r` is a SQLCMD **parse-time** directive: wrapping it in `IF` includes the file regardless, and the `IF` would guard only the first statement of the first batch. A separate runner is the only correct mechanism — hence `FlatWire_SampleData_RunAll.sql`.

---

## Acceptance criteria

- [ ] `sp_IngestRodFromCoils` deployed. A **deployed** `FlatWireDB` then carries **two** procedures — `sp_GetGaugeTrace` from the schema runner and this one from `Database/Scripts/`. ⚠ **`FlatWire_DDL_RunAll.sql` still produces one**, and that is the reconciliation if an object count looks wrong. `sp_ShiftSummary` still absent (MVP-2)
- [ ] **Clean-database check-in works**: deploy schema only, `Rod` empty, check in `R00041` → the mirror is created and no FK fails
- [ ] **The bug is reproducible without it**: same test with the ingest skipped → `FK_RodCheckin_Rod` violation. That is production today
- [ ] Called outside a transaction → `55001`, nothing written
- [ ] Unknown rod → `55004` before any `FlatWireDB` write; `Rod` still empty (`FR-532`)
- [ ] `coils.coil_alloy = 1` → `Rod.Alloy = '1100'`, resolved through `united_db..alloys` — **not** `'1'`
- [ ] Unresolvable alloy → `55005`, named as itself rather than as a missing rod
- [ ] `Rod.DiameterIn` equals the operator's measurement, **not** `coil_gauge`
- [ ] `Rod.SupplierHeat` is `NULL` (`OI-117`)
- [ ] **Refresh preserves local state**: set `Status='INFLAT'` and `FootageRunToDate=6400`, re-run → both unchanged; weights and alloy refreshed from `coils` (`FR-531`)
- [ ] Idempotent: twice in one transaction → one row, `@rodExisted` `0` then `1`
- [ ] Staging path: `POST /staging/rod` on a never-seen rod → mirror created, `FK_RodStaging_Rod` holds
- [ ] `GET /rod/{alpha}` creates nothing (`FR-530`)
- [ ] `TC-395` still passes — rod *retrieved by alpha, not recreated*, `FootageRunToDate` intact
- [ ] `FlatWire_DDL_RunAll.sql` produces **33 tables and zero rows**; `FlatWire_SampleData_RunAll.sql` restores the eight rods
- [ ] `[REQ §5.27]`, `[INT §7.9]` and `[TCS]` **`TC-751`–`TC-754`** agree with what was built *(the range read `TC-749`–`TC-758` until 25 Aug 2026 — `TC-749`/`TC-750` belong to `FR-541`/`FR-559`, a different block, and `TC-751`+ did not exist at all; the four projection cases were written that day)*

---

## Out of scope

**`PassSchedule*` — `OI-110`, and it is not ours.** Nothing populates the three schedule tables in production either. `D-31` moved them into MVP-1 on the reading that *the owning track writes into `FlatWireDB`*, and that reading still needs confirming. Same shape of hole as `OI-42`, different owner. **Check-in cannot run in production without a schedule**, so this remains a live pre-production blocker.

**The six lookup tables** are seeded by DDL, and `AlloyProperty` gains its admin screen in phase 13.

**`OI-117` is raised, not fixed.** `Rod.SupplierHeat` has no source, and `FlatWireSchema_Materials.md` says the rod record *"links material certification data (supplier heat) to the finished output coil via `CoilTraceability`"* — the welding-wire customer certificate chain, an MVP-1 obligation. `[INT §8]` lists *"`Lots` / chemistry — the far end of the cert chain — Read"*, which is the likely source and is unmapped. **Tracing it is a prerequisite for issuing a certificate, not for building this.**

---

## Blockers

**None of its own.** No IT sign-off values — every column either has a source or is deliberately `NULL`.

**Shared with `FW-220`:** `FlatWireDB` must be deployed to the same instance as `proddb` / `united_db`, because the ingest reads `proddb..coils` and `united_db..alloys` inside the caller's transaction. As of 19 Aug 2026 it is on `(localdb)\MSSQLLocalDB` and they are on `DEVUAL-UADEV001\TEST1`.

---

## Dependencies

`FW-007` (the schema), `FW-142` (Dapper + the unit of work that owns the transaction), `FW-144` (configuration — the cross-database grants in `20_FlatWire_Grants.sql` already cover `proddb` and `united_db` reads), `FW-157`/`FW-158`/`FW-159` (the two call sites), `FW-220` (the sibling half of the same transaction).
