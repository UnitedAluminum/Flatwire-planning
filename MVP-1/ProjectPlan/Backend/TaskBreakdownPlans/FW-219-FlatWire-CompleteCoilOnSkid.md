# FW-219 — FL2/FL3 Run-End Write-Back into the Shared Schema

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 26, 2026 — ⛔ **REWRITTEN BY CHANGES `[H]`, `[S]` and `[N]`: the procedure now lives in `FlatWireDB`, writes **N** shared identities per coil rather than one, and mints them off the **source segment** with a **blank** ignore list. `OI-113` is CLOSED; `@primaryRodAlpha` and `@expectedCoilNo` are both gone.** Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Status:** **Ready to build — the procedure is drafted and structurally verified; three values need IT sign-off before a shared environment**
**Story:** `FW-219` · **Phase:** 9 · **Sprint:** S3 · **Streams:** DB + BE
**Hours:** **40 h AI-assisted / 56 h hand-coded**; 77 h all-in (`[CE §3d]`). **Additive to the 3,186 h baseline**, like `FW-202`
**Requirements:** `FR-509`–`FR-518` (`[REQ §5.25]`) · **Specification:** `[INT §8.1]`
**Artifact:** [`Database/Scripts/50_FlatWireDB_Proc_FlatWire_CompleteCoilOnSkid.sql`](../../Database/Scripts/50_FlatWireDB_Proc_FlatWire_CompleteCoilOnSkid.sql)
**Gap:** `G44`

---

## Why this story exists

`phase-05` routes the FL2 active-run screen's **Complete Run** control to `POST /coil/complete`. That endpoint wrote `CoilOutput`, `CoilTraceability` and the run header — **all in `FlatWireDB`** — and nothing else. From `proddb`/`united_db`'s point of view the finished goods did not exist.

**Eight shared objects were never written, and not one of them was named anywhere in this repository.** `wip_skids`, `wip_skid_coils`, `coil_slit_cuts`, `coil_gen_history` and `wip_log` had **zero** occurrences across every `.md`, `.sql`, `.py` and `.html`; `wip_coil_orders` appeared only as a check-in write; `coils` was read-only after `D-32`. That is an absence, not a deferred decision — which is why there is no existing line item to move and the hours are genuinely new.

**It closes `OI-104`.** `CoilOutput.SkidId` was documented as pointing at "the existing skid table", which no document named, no story created and nothing verified. It is `united_db..wip_skids`, linked through `proddb..wip_skid_coils`, numbered by `proddb..generate_new_skid_no` — which is what **`FR-339`** required all along, so `FR-339` becomes testable for the first time and its *"blocked on `G36`"* note is lifted.

> ⚠ **`D-32` is not weakened.** Every write lands in a column that **already exists** — no rename, no new column, no new status value. `D-32` cancelled the shared-schema *migration*; it never prohibited writing the shared schema as it stands, which `[INT §8]`'s opening sentence has always required.

---

## Reference context — do not restate

- `[INT §8.1]` is the specification of record for the write set and the two-alpha rule.
- The procedure's own header block carries the **twelve table constraints (`C1`–`C12`)** and **fifteen decisions (`D1`–`D15`)**, each with its reasoning. **Read it before changing a line** — most of what looks arbitrary is load-bearing.
- `CreateSkid_MoveCutsOnSkid` (`Second-Branch/.../united_db/Stored Procedures/`) is the behavioural template. Its verified write order is at lines 197–2313.

---

## What to build

### 1. Schema — two columns and two indexes (DB, 4 h → 2 h)

`FlatWire_DDL_05_QualityOutput.sql` gains `CoilOutput.CoilNo VARCHAR(9) NULL` and `SharedSkidNo VARCHAR(9) NULL`; `07_Indexes.sql` gains filtered `UX_CoilOutput_CoilNo` (**UNIQUE** — this is what makes the retry contract enforceable rather than merely documented) and `IX_CoilOutput_SharedSkidNo`. Both columns are **`FlatWireDB`-local**, so `D-32` is untouched. Object counts move **47 → 49 index statements**; the table count stays 28. *(`FW-222` took it to **50** on 19 Aug 2026 with `UX_FlatWireRun_ActiveLine`; `[DBD §6.2]` is the current baseline.)*

### 2. The procedure (DB, 32 h → 24 h)

Already drafted. Nine steps in a fixed order, one transaction, `SET XACT_ABORT ON`, `EventErrorLog` + `Logging_Information_In_Table` on both paths. The build work is deployment and verification, not authoring.

### 3. `CoilCompletionService` (BE, 20 h → 14 h)

- Resolve the **primary source rod** — lowest `CoilTraceability.FootageFrom` — for the genealogy parent.
- Call the procedure via **Dapper**, one call per coil, after the `FlatWireDB` writes commit.
- **Persist `CoilNo` immediately on return.** This is the retry contract; see below.
- On a procedure throw: mark the run for operator retry and surface it. **Never swallow it.**
- Extend `FW-144`'s configuration with read/write grants on `proddb`, `united_db`, `SlitterDB`, `CommonDB`.

---

## The five things most likely to be got wrong

Each was found by reading the scripted DDL, and each fails at run time or, worse, silently half-succeeds.

| # | Trap | What to do |
|---|---|---|
| 1 | **`coils_iud_tg` is single-row only.** It gates on `@ins_count = 1` and uses scalar `SELECT @var = col FROM inserted`. A set-based insert into `proddb..coils` **silently skips the `coil_link_master_coil` row** | One coil per call. Never batch, never "optimise" this into a set operation |
| 2 | **You cannot INSERT through `proddb..wip_skids`.** The view exposes 23 of 34 columns and omits `IsComplete`, which is `NOT NULL` with no default | Write `united_db..wip_skids` directly |
| 3 | **`coil_slit_cuts` lives in `SlitterDB`**, not `united_db` (migrated under UADEV-19354; the `united_db` folder is an empty stub). Its `skid_no` is **`char(10)`** while every other skid_no is `char(9)`, and `cutMovementCount` / `under_review` are `NOT NULL` with no default | Target `SlitterDB..coil_slit_cuts`; supply both columns. The 2020 template `CoilReceiving_InsertCoilSlitCutDataOnSkid` does **not** — it predates them, so treat it as a shape precedent, not runnable code |
| 4 | **All 44 `wip_log` columns are `NOT NULL` with no defaults**, and the effective key `wip_log_k0` is UNIQUE on `(wip_log_rev_time, seq_no)` at **second** granularity | Supply all 44. Resolve the key with the spin loop from `coils_iud_tg`, scoped to include `seq_no` |
| 5 | **Forgetting `CoilCost_UpdateInsert`.** Nothing fails; the coil simply never appears in cost or yield | Call it. `CreateSkid_MoveCutsOnSkid:1013` does, immediately after the genealogy row |

---

## The retry contract — the one thing a reviewer must check

The shared writes are **not** in the same transaction as the `FlatWireDB` writes. They cannot be: different database, and `[ARC §10]` already draws this boundary for check-in as compensating writes.

- **Procedure throws** → its whole half rolls back, no shared row survives, caller marks the run for retry.
- **Procedure commits, caller then fails** → shared rows are already committed. ⛔ **The contract is no longer a scalar (change `[S]`).** *Superseded: "The caller stores `CoilNo`; a retry passes it back through `@expectedCoilNo` and the procedure is a **no-op**.

⛔ **`@expectedCoilNo` NO LONGER EXISTS, and it is not replaced by a table-valued parameter.** Since `[H]` the procedure lives in `FlatWireDB`, so it reads `dbo.CoilTraceability` directly and **the retry contract is the rows where `SharedWrittenAt IS NULL`**. The caller passes nothing back and stores nothing.

⚠ **The old warning understated the risk, and the risk has changed shape.** It read: *"A retry that does not pass it back mints a second coil, because `GenerateCoilAlpha` returns the next free suffix each time."* With **N** parts, a scalar contract short-circuits on part 1 and returns **0 — success** — while parts 2..N sit committed in five shared tables, referenced by nothing and unreported. That is `ORD024` / `TC-797`.

⛔ **And never re-mint a part that already has a `ChildAlpha`.** Under a blank ignore list this is a **correctness** rule, not an optimisation: if an earlier part committed between attempts the sweep now sees it, so a re-mint returns a **different letter** and orphans the stored one — a valid-but-orphaned alpha that no guard detects.

---

## Acceptance criteria

- [ ] ⚠ **Per PART, not per coil.** A single-rod coil produces a row in **all nine** verifiable objects; a coil cut across a weld produces **N** rows in each of the per-part objects and exactly **one** `wip_skids` weight accumulation. Nine objects — the eight written plus `coil_link_master_coil` from the trigger
- [ ] `coil_link_master_coil.master_coil_no` is the **rod root** (`R00421` for `R00421A`), proving both the single-row trigger path and that the 6-character root is meaningful
- [ ] `Coil1Of2` opens a skid `IsComplete = 0`; `Coil2Of2` closes it `IsComplete = 1`; a third coil is refused (`FR-335`)
- [ ] `skid_coil_seq_no` is **1 or 2 from `@skidAssignment`**, and **all N parts of one physical coil share its value** — it identifies the coil's slot, not the row. *(It was derived as `MAX+1` over the skid; that counted rows and so refused a legal second coil once a coil had N parts.)*
- [ ] ⛔ **The part weights SUM to the coil's net weight** (`ORD023`). `THROW 51020` is the only detector — `wip_skids`' `smallint` guard validates per *call*, so it would accept N × the coil weight without complaint
- [ ] **`coil_gen_history` has N rows, each naming a DIFFERENT parent rod.** If they share one parent, `OI-113` has not closed
- [ ] Part alphas are **segment-rooted**: one trailing letter is a spool segment, **two** is a coil off that segment (`R00001A` → `R00001AA`)
- [ ] **Retry writes only the parts whose `SharedWrittenAt` is `NULL`, reports ALL of them, and returns the original skid state.** A retry where every part is already written writes nothing
- [ ] A forced failure mid-procedure leaves **no** shared row, and the error reaches the operator
- [ ] Out-of-spec final SPC gives `skid_status = 'HOLDP'` plus a `SKIDHOLD`/`PRHOLD` `wip_log` row (`FR-517`)
- [ ] A mid-run break sets `coil_gen_history.coil_break` and `Coil_Break_Reason`
- [ ] Weights beyond the `smallint` bound are **refused**, not truncated (`FR-518`, `D14`)
- [ ] `[REQ §5.25]`, `[INT §8.1]` and `[TCS]` `TC-715`–`TC-729` all agree with what was built

---

## Out of scope — and one of them is a live defect

**Releasing `wip_stations.coilno` (`OI-112`).** `FR-077` **sets** the station's coil reference at check-in and **no requirement anywhere clears it**; `POST /checkout` lists no `wip_stations` side effect. `wip_stations_k1` is a **UNIQUE** index on `CoilNo`, so **the second coil at a station collides and the line becomes unusable until the column is cleared by hand.** The release pattern already exists — the legacy checkout parks the station's own name in the column as an idle sentinel, quoted verbatim in `10_CommonDB_Insert_WIPStations_FlatWire.sql` from `SlitterInterface_CheckoutCoil`. This belongs to **run** completion, not coil completion; do not bolt it on here, but do not let it be forgotten either.

✅ **`OI-113` — CLOSED 26 Aug 2026 by `Q89`.** *Superseded: "the shared genealogy holds one parent … do not resolve it by inserting several rows."* **Inserting several rows is now exactly the design.** The guard that looked like a prohibition is `IF NOT EXISTS (… WHERE child_coil_no = @ChildCoil)` — **per child** — so N distinct children pass N independent tests and each gets one correctly-parented row. It only ever forbade *one child with many parents*, which is not what a multi-rod coil needs. ⚠ **Conditional, and the condition is the whole point: each part must carry its OWN parent rod.** One shared primary rod for all N would assert *"this rod produced N coils"* — not multi-rod genealogy, and `OI-113` would not have closed.

---

## Blockers

**`Q34`** the eight-character transaction token (proposed `FWCOMPLT`) · **`Q35`** whether `coil_status = 'ONSKID'` is right for finished flat wire (proposed: reuse it) · **`Q36`** the sample number and planned operations. All three are **IT questions about existing consumers**, and the impact audit that would have answered them was cancelled with `D-32`.

**They do not block the build** — each is a named constant in one place in the procedure. **They block a shared environment.**

**`OI-114`** (the cut-record sentinels) is not a hard blocker and is genuinely unanswerable from the codebase: `stop_no` is `1` in one legacy writer and `0` in three, `mfg_order_no` is `99999` in three and `0` in the fourth, and all five hard-code a `skid_coil_seq_no` flat wire cannot use. The procedure parameterises the first two and derives the third.

---

## Dependencies

`FW-066` (coil completion), `FW-141` (repositories), `FW-142` (Dapper + context), `FW-144` (configuration — extended with the cross-database grants).

**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)
