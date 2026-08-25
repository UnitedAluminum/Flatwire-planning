# Flat Wire Mill — Integration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 19, 2026 — **new §7.9: inbound ingestion.** Nothing populated `Rod` in production — rod receiving is upstream and writes `coils`, not `FlatWireDB` — so on a clean database the first staging or check-in failed on an enforced FK. `sp_IngestRodFromCoils` projects the rod on the first write that names it, and the column-ownership split is written down at last: **`OI-42` closes**. Sample data no longer deploys with the schema. New **`OI-117`** (`Rod.SupplierHeat` has no source and the certificate chain traces through it). *(Same day: **new §8.0: the FL1/FL3 check-in write-back.** Nine shared objects are written at rod check-in, all into columns that already exist, and the database half of check-in becomes **one ACID transaction** because `FlatWireDB` is co-located with the shared schema. **`OI-112` closes** (the station is released at run end) and **`OI-111` largely closes** (the rod's `coils` row is stamped with `wip_station`, `coil_status` untouched). New `OI-115` (FL2 spool check-in write set undefined), `OI-116` (`coil_mill_processing`), `Q37`–`Q40`. *(Earlier: **new §8.1: the FL2/FL3 run-end write-back.** Seven shared objects are written at coil completion, all into columns that already exist; the skid table is named at last, closing `OI-104`. *(Earlier same day: **`D-32`: there is no shared-schema migration.** `FW-001`/`FW-002` cancelled; §9.5 is retained as the record of what was cancelled, and the `coils.coil_status = INFLAT` write is struck from §8 and §9.4)* *(earlier: split out of `03-HLD-and-ERDiagram.md`, `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*
**Document Type:** Cross-database touchpoints — **reads and writes against the shared schema as it stands**
**Status:** Baselined for build
**Owner:** Architecture stream
**Audience:** Architects, .NET developers, DBA
**Shortcode:** `[INT]`
**Part of:** `ProjectPlan/Architecture/` — index: [README.md](../README.md)

---

## 7.9 Inbound ingestion — how data reaches the FlatWire tables

**§8.0 and §8.1 describe flat wire writing *outward*. This is the inbound half, and it is numbered 7.9 because it happens *before* both** — the file's numbering is deliberately non-contiguous and this keeps the read order right. Story **`FW-223`**, requirements **`FR-529`–`FR-532`**, procedure **`FlatWireDB.dbo.sp_IngestRodFromCoils`** ([`Database/Scripts/30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql`](../Database/Scripts/30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql)). It is a `FlatWireDB` object but ships with the cross-database scripts rather than the schema runner, because it reads `proddb..coils` and `united_db..alloys` — so `FlatWire_DDL_RunAll.sql` still produces **one** procedure while a **deployed** `FlatWireDB` carries two.

**It exists because nothing populated `Rod` in production.** Rod receiving (`FW-020`–`FW-022`) is upstream, was removed from this backlog as another team's work, and writes `proddb..coils` — not `FlatWireDB`. The only thing that ever put a row in `Rod` was `FlatWire_SampleData_Materials.sql`. `FK_RodCheckin_Rod` and `FK_RodStaging_Rod` are **enforced**, so on a clean production database the first staging or check-in would have failed on a foreign key. **This closes `OI-42`.**

### The lifecycle, end to end

| Stage | Table | Written by | Story |
|---|---|---|---|
| **Ingest** | `Rod` | `sp_IngestRodFromCoils`, on the first write naming the rod | **`FW-223`** |
| Staging | `RodStaging` | `POST /staging/rod` | `FW-158` |
| Check-in | `FlatWireRun`, `RodCheckin`, `SpcCheckpoint`, `SpcMeasurement` | `POST /checkin/rod` | `FW-159` |
| Check-in → shared | *(§8.0)* | `FlatWire_CheckInRod` | `FW-220` |
| In-run | `RunReading` | OPC ingest | `FW-N05` |
| In-run | `WeldEvent`, `RunPauseEvent`, `RollOverride`, `DieChangeEvent` | the run-event dialogs | phase 6 |
| Exceptions | `WipRejection`, `RodCheckout` | phase 7 | `FW-174` |
| Checkout → shared | *(reverses §8.0)* | `FlatWire_ReverseReqsum` | `FW-221` |
| FL1 run end | `SpoolProcessing` | spool completion | `FW-202` |
| FL2/FL3 coil end | `CoilOutput`, `CoilTraceability` | `POST /coil/complete` | `FW-185` |
| Coil end → shared | *(§8.1)* | `FlatWire_CompleteCoilOnSkid` | `FW-219` |
| Run end → shared | `WIPStations` released | `FlatWire_ReleaseStation` | `FW-221` |

**Two tables are still populated by nobody, and only one is ours.** `PassSchedule`, `PassScheduleComponent` and `PassScheduleChangeLog` are **`OI-110`** — the owning track must confirm it writes into `FlatWireDB`. The six lookup tables are seeded by DDL, and `AlloyProperty` gains an admin screen in phase 13.

### Ingestion is on the first *write*, never on a read

| Path | Why it must ingest |
|---|---|
| `POST /staging/rod` | `FK_RodStaging_Rod` is enforced |
| `POST /checkin/rod` | `FK_RodCheckin_Rod` is enforced — and a direct scan into Dashboard 2 is a supported path, so check-in cannot assume staging ran |

**`GET /rod/{alpha}` deliberately does not ingest.** It is documented `Idempotent` and any authenticated role may call it, so a supervisor scanning a rod merely to look at it must not create records. The ingest is idempotent, so whichever write arrives first creates the row and the second refreshes it.

It runs as the **first statement inside the caller's transaction**, before any other `FlatWireDB` write — the same transaction that then writes the run and check-in records and calls `FlatWire_CheckInRod`. The procedure asserts `@@TRANCOUNT > 0` rather than assuming it.

### Which side is master for each column — the other half of `OI-42`

| `Rod` column | Source | Master |
|---|---|---|
| `Alpha` | `coils.coil_no` | shared |
| `Alloy` | `coils.coil_alloy` → `united_db..alloys.alloy_idx` → `.alloy` | shared |
| `Temper` | `coils.coil_temper` | shared |
| `DiameterIn` | the caller's measurement | **local** |
| `GrossWeightLb`, `NetWeightLb` | `coils.coil_gross_wgt` / `coil_net_wgt` | shared |
| `SupplierHeat` | **nothing** — `OI-117` | — |
| `InventoryType` | `coils.inventory_type` | shared |
| `Location` | `coils.storage_section` | shared |
| `ReceivedAt` | `coils.coil_recvd_date` | shared |
| **`Status`** | — | **local** |
| **`FootageRunToDate`** | — | **local** |
| **`RemainingWeightEstimateLb`** | — | **local** |

**The refresh touches shared-mastered columns only, and that is why it is not a `MERGE`.** `Status` carries `INFLAT`, which is `FlatWireDB`-local since `D-32` — resetting it would un-mark a running rod. `FootageRunToDate` is the carry-forward evidence `PRC007` depends on; clearing it would silently offer a fresh-start check-in for a rod that has already run footage, which `FR-043` forbids. `DiameterIn` and `Location` are also left alone on refresh: the per-event measurements live on `RodStaging.DiameterIn` and `RodCheckin.DiameterMeasuredIn`, and staging overwrites `Location` with the payoff position.

### Three things that will look like defects if you do not know they are deliberate

1. **`proddb..coils` has no rod-diameter column.** The nearest is `coil_gauge`, which is a *strip gauge*; reading it as a wire diameter would be a convention dressed as a fact. `Rod.DiameterIn` is `NOT NULL` with `CHECK > 0` and takes the operator's measurement instead — which is a positive argument for ingesting at the first write rather than at receipt, because at receipt there is no measurement to use.
2. **`SupplierHeat` is left `NULL` on purpose.** `coils` has no heat column and no payload carries one, yet `FlatWireSchema_Materials.md` says the rod record links certification data to the output coil through `CoilTraceability` — the welding-wire certificate chain, an MVP-1 obligation. **`OI-117`**; the likely source is the `Lots` / chemistry tables §8 already lists as "the far end of the cert chain", and it is unmapped. Do not invent a value.
3. **The alloy is a lookup, not a cast.** `coils.coil_alloy` is `smallint` and `Rod.Alloy` is `varchar(10)` holding `'1100'`. Storing the numeric code as text would not fail — it would silently stop every alloy comparison downstream from matching. *(This reads the table `AlloyProperty` shadows — `OI-93`.)*

### Sample data no longer deploys with the schema

`FlatWire_DDL_RunAll.sql` used to include the five `FlatWire_SampleData_*.sql` files unconditionally, so every deployment inserted eight fake rods and their runs, check-ins and coil outputs. Harmless on LocalDB; **not harmless once this runner is pointed at the shared instance**, and it undermines the ingest directly — a seeded `R00041` that never came from `coils` is silently *refreshed* rather than created. The seeds moved to **`FlatWire_SampleData_RunAll.sql`**, DEV and trial only. A conditional include was not possible: `:r` is a SQLCMD parse-time directive.

---

## 8. Cross-database touchpoints

`FlatWireDB` is authoritative for flat-wire-specific entities. The named legacy integration points in the **shared** databases are still written so scheduling, planning, reporting, cost and yield keep working without regression.

> ⚠ **`D-32` (18 Aug 2026) — every touchpoint below uses the shared schema exactly as it stands today.** There is no migration: no renamed column, no new column, no new status value. A touchpoint that needed a schema change is not in this table any more.

| Shared object | Database | Written when | Direction | Enforcement |
|---|---|---|---|---|
| ~~`coils.coil_status = INFLAT`~~ | ~~shared~~ | **STRUCK — `D-32`, 18 Aug 2026.** `INFLAT` was never a value the shared status vocabulary carried; it arrived with `FW-002`, which is cancelled. In-process state is now **`FlatWireDB`-local only** — `Rod.Status` / `SpoolProcessing.Status`. **`OI-111`:** upstream can no longer see from the shared schema that a rod is on a flattening line | — | — |
| `coils` R-series row | shared | At rod receipt | **Read**, then **stamped at check-in** | Mirrored into local `Rod` (**OI-42**). §8.0 step 8 writes `wip_station` / `wip_badge_no` / `transaction_name` / `coil_rev_time` — **`coil_status` is never written** (`D-32`), which is what leaves `OI-111` with a residual rather than closing it outright |
| `wip_coil_orders` | `proddb` | Reqsum entry at check-in if the rod is not yet reqsummed | **Write** | Unenforced. **Written by `FlatWire_CheckInRod` (§8.0)**; reversed at pre-check-out by `FlatWire_ReverseReqsum` |
| `planning_routings` / `routings`.`actual_start_date` | shared | Updated at check-in | **Write** | Unenforced. **Written by `FlatWire_CheckInRod` (§8.0)**, guarded on the `1800-01-01` sentinel |
| `planning_routings` rod→order allocation | shared | By Planning | **Read** | The scan resolves its order from here |
| `wip_stations.coilno` | `CommonDB` | On successful check-in | **Write** | Unenforced; `WIPStations` has a UNIQUE index on `CoilNo`. **Claimed by `FlatWire_CheckInRod` and released by `FlatWire_ReleaseStation` (§8.0) — `OI-112` closed, 19 Aug 2026** |
| `machines` FL1/FL2/FL3 | `united_db` | One-time registration (FW-003) | Seeded | machine_idx **125/126/127**, fixed so DEV/TEST/PROD agree |
| `alloys.alloy_density` | `united_db` | Maintained by the Alloys module | **Read** | Via a `FlatWireDB..Alloys` view (§6.6) |
| `alloys.Draw_max_reduction` | `united_db` | Maintained by the Alloys module | **Read** | Via the same view |
| **`wip_skids`** | `united_db` | **Opened / closed at coil completion (§8.1)** | **Write** | No local FK. **This is the skid table `CoilOutput.SkidId` points at — `OI-104` closed, 18 Aug 2026** |
| **`wip_skid_coils`** | `proddb` | **One row per coil at completion (§8.1)** | **Write** | No local FK |
| **`coils` finished-coil row** | `proddb` | **At coil completion (§8.1)** | **Write** | A child of the rod, `char(9)` alpha from `GenerateCoilAlpha` |
| **`coil_gen_history`** | `united_db` | **At coil completion (§8.1)** | **Write** | One parent only — `OI-113` |
| **`coil_slit_cuts`** | `SlitterDB` | **One row per coil at completion (§8.1)** | **Write** | A flat wire coil is one cut |
| **`wip_log`** | `wiplogdb`, via `proddb..wip_log_view` | **At coil completion (§8.1)** | **Write** | All 44 columns `NOT NULL` |
| **`coil_cost`** | `united_db`, via `CoilCost_UpdateInsert` | **At coil completion (§8.1)** | **Write** | Omit it and the coil vanishes from cost and yield |
| `Lots` / chemistry | shared | The far end of the cert chain | **Read** | — |

**WIP station registration** creates `FL1`, `FL2`, `FL3`, **`FL1PO`** (the Pre-Check-In station, sharing FL1's MachineIdx, same pattern as legacy `ZR23`/`ZR23PO`) and `FWPACK` (packing, MachineIdx NULL by design because it serves all three lines). **`FL2PO` is deliberately not created.** **There is no `FL3PO`** — working assumption is that FL3 posts to `FL1PO` (**OI-26**).

Script constraints worth knowing before running it: `machines.machine_idx` is **not** an IDENTITY; `machines.status` must be `1` or the machine is invisible to the `CommonDB.dbo.Machines` view; an idle station parks **its own station name** in `CoilNo` as a guaranteed-unique placeholder; `WIPStation` is space-padded to 6 characters and `PrinterName` to 12.

> **`machine_type` is undecided**, and `AccountingDB.dbo.GetMachineTypeFromOpLetter` has **no case for the flattening letter `F`** — it returns NULL for flat wire today regardless of which type is chosen. **OI-27.**

**The `FW-001` renames are cancelled** — `D-32`, 18 Aug 2026. §9.5 is retained as the record of what was cancelled and why; `[RB §6.3]`'s rename rollback treatment has nothing left to roll back.

---

## 8.0 Check-in write-back — FL1/FL3 rod check-in

**§8's table names four shared touchpoints at check-in and until 19 Aug 2026 there was no procedure, script or code for any of them** — `FR-077` had been unimplementable since it was written. This section is the opening bracket of the run; §8.1 is the closing one. Story **`FW-220`**, requirements **`FR-519`–`FR-528`**, procedures **`united_db.dbo.FlatWire_CheckInRod`**, **`FlatWire_ReleaseStation`** and **`FlatWire_ReverseReqsum`** ([`Database/Scripts/`](../Database/Scripts/)).

> ⚠ **`D-32` still holds and this section does not weaken it.** Every write below lands in a column that **already exists**. No column is renamed, no column is added, no status vocabulary gains a value — the one new status-shaped value considered, `INFLAT` in `wip_log.coil_skid_status`, was **rejected** for exactly that reason and `INROLL` reused instead.

**Scope is FL1 and FL3 rod check-in.** FL2 spool check-in is **not** covered and its shared write set is genuinely unspecified — see *What this section deliberately does not cover*.

| # | Shared object | Database | What is written | Why it cannot be skipped |
|---|---|---|---|---|
| 1 | `routings` | `united_db` | Copied from `planning_routings` when the shopfloor row does not exist — all 94 columns, `machine_idx` overridden from the line | The shopfloor has no record of the step, so nothing downstream can report against it |
| 2 | `mfg_sales_order_ref`, `routings_orders` | `united_db` | The order references, when the reqsum needs them | The step is otherwise unattached to the order it serves |
| 3 | `wip_coil_orders` | `proddb` | The reqsum entry — `coil_planned_wgt` / `smp_no` / `planned_operations` | **`FR-077` names this explicitly.** Without it the order cannot see the material it was issued |
| 4 | `wip_orders` | via `del_or_upd_wip_orders` | Order material status, recomputed | The order's status is derived from its coil rows and goes stale otherwise |
| 5 | `planning_routings`.`actual_start_date` | `united_db` | The start stamp | **`FR-077`.** Every schedule-adherence and cycle-time report reads it |
| 6 | `routings`.`actual_start_date`, `machine_idx`, `actual_weight_on` | `united_db` | The start stamp and the check-in weight | **`FR-077`** |
| 7 | `WIPStations`.`CoilNo` + four weight columns | `CommonDB` | The station claim | **`FR-077`.** `united_db..wip_stations` and `proddb..wip_stations` are **views over this one table** — one row, three names |
| 8 | `coils` rod row | `proddb` | `wip_station`, `wip_badge_no`, `transaction_name`, `coil_rev_time` — **`coil_status` untouched** | **This is what recovers most of `OI-111`.** See below |
| 9 | `wip_log` | `wiplogdb`, via `proddb..wip_log_view` | The WIP transaction, all 44 columns | The shop-floor transaction history has no other record that a flat wire check-in happened |

Steps 1–9 are **inside the caller's transaction, together with the `FlatWireDB` writes**, and that is the difference from §8.1.

### The database half of check-in is one ACID transaction

`FlatWireDB` is deployed on the **same SQL Server instance** as `united_db` / `proddb` / `SlitterDB` / `CommonDB` / `wiplogdb`, so a single `SqlConnection` with a single `SqlTransaction` spans both halves under the **local** transaction manager — no MSDTC, no linked server. `CheckInService` writes `FlatWireDB` through EF, calls `FlatWire_CheckInRod` **last** on the same transaction, commits, and only then pushes PLC tags.

`[ARC §10]` is right that check-in as a whole is not one ACID transaction — but **the part that cannot be atomic is only the OPC write.** So the database half is a transaction and may be described as one; the PLC half is compensation and must never be called a rollback (`G16`). **`G2` narrows again and does not close.**

⚠ **`FlatWireDB` must actually be on that instance.** As of 19 Aug 2026 it is on `(localdb)\MSSQLLocalDB` while the shared five are on `DEVUAL-UADEV001\TEST1`. In the split topology nothing errors — the design just silently stops being atomic. Prove co-location with the query in `20_FlatWire_Grants.sql` before trusting this section.

### `OI-112` is closed — the station is released at run end

`FR-077` *sets* `WIPStations.CoilNo` and no requirement clears it, while `wip_stations_k1` is UNIQUE on `CoilNo`, so an unreleased station collides with the next coil. `FlatWire_ReleaseStation` returns it to the idle sentinel — **the station's own name**, because a plain UNIQUE index admits only one `NULL`. It is called at **run** completion (`FW-202`, the `FW-185`/`FW-219` caller) and at checkout modes A and B (`FW-174`), never at coil completion.

### `OI-111` is largely closed — without touching the status vocabulary

When `D-32` cancelled `FW-002`, nothing was left in the shared schema to show that a rod is on a flattening line. Step 8 stamps `coils.wip_station = 'FL1'`, which says exactly that, in a column that already exists and already carries values of that kind. **`coil_status` is not written.** The residual — an availability check keying on `coil_status` still cannot tell — is what `OI-111` keeps.

### The reversal, which `[ARC §10]` required and nothing implemented

`[ARC §10]`'s closing line requires pre-check-out to **reverse** the `wip_coil_orders` insert; that is `OI-01`'s surviving residual after `D-32`. `FlatWire_ReverseReqsum` deletes the reqsum row, resets both `actual_start_date` values to the `1800-01-01` sentinel and releases the station — **and refuses when footage > 0**, because that is a Mode B mid-run removal whose reqsum records material the order genuinely received. The delete is audited by `wip_coil_orders_d_tg`, which archives to `wip_coil_orders_hist` and also sets `reassign_order_info.status = 2`.

### Three things that will look like defects if you do not know they are deliberate

1. **`FlatWire_CheckInRod` does not open a transaction; `FlatWire_CompleteCoilOnSkid` does.** Check-in is caller-owned because the caller is also writing `FlatWireDB` in the same act. Completion owns its own because wrapping five legacy procedure calls would hold shared locks far too long, and `generate_new_skid_no` bumps `wip_orders.next_skid_no` as a side effect that should not roll back.
2. **A partial-rod re-check-in does not re-stamp `actual_start_date`.** Both routing tables treat `1800-01-01` as unset and the update is guarded on it. The step started when the rod first ran; the second check-in does not restart it. That is correct, and it looks like a missing write.
3. **`machine_idx` is passed in, not derived.** `PreCheckIn_CopyPlanningData` picks it with a CASE over `IsRollingOpLetter` / `IsSlittingOpLetter` / `IsOtherOpLetter` — **none of which matches the flattening letter `F`**, so the CASE falls to its ELSE branch. FL1 → 125, FL3 → 127, validated in the procedure.

### Isolation is mixed, and not where the legacy hints suggest

Measured on `DEVUAL-UADEV001\TEST1`, 19 Aug 2026: `FlatWireDB`, `united_db`, `proddb` and `wiplogdb` all run **`READ_COMMITTED_SNAPSHOT ON`**; **`CommonDB` and `SlitterDB` do not**. So a check-in transaction takes snapshot reads everywhere except the `WIPStations` claim at step 7, and coil completion takes them everywhere except `coil_slit_cuts`. Exactly one step at each end of the run can block or be blocked by a legacy reader. Re-measure per environment — it is a database setting, not a schema fact.

### What this section deliberately does not cover

**FL2 spool check-in — `OI-115`, and it blocks rather than merely awaiting sign-off.** `[API §4.6a]` says `POST /checkin/spool` has *"the same shape as §4.6"* and then lists only `FlatWireDB` writes. A spool has no `proddb..coils` row, so the reqsum, `actual_start_date` and the station claim are all undefined for it — and parking `SP-00021` in `WIPStations.CoilNo`, which every legacy reader treats as a coil number with no FK to stop it, needs an explicit answer.

**`coil_mill_processing` — `OI-116`.** `PreCheckIn_CopyPlanningData` writes it alongside `routings`. Whether flat wire owes the rolling-processing table a row is open and affects mill reporting.

**Four values need IT sign-off before this runs outside DEV** — `Q37` the transaction token (proposed `FWCHKIN`), `Q38` the `wip_log.coil_skid_status` value (proposed: reuse `INROLL`), `Q39` stamping the rod's `coils` row, `Q40` deleting versus orphaning the reqsum row on reversal. Same class as `Q34`–`Q36`, and the impact audit that would have answered them was cancelled with `D-32`.

---

## 8.0a FL1 spool completion becomes a cross-database caller

**New as of 22 Aug 2026 (`Q57`).** FL1 segment alphas are minted through
**`CommonDB.dbo.GenerateCoilAlpha`**, the same function FL2 uses for the shared coil identity — because
that function cannot see `FlatWireDB`, and a local per-rod counter would hand the same string to a spool
segment and to a finished coil.

| | |
|---|---|
| Direction | **Read** (a scalar function call). No shared table is written |
| Transaction | Same instance, **local transaction manager, no MSDTC** — the §8.0 pattern |
| Ignore list | **Every** alpha already recorded for that rod in `SpoolTraceability`, not just this transaction's. The sweep covers the shared schema and finds those unaided; `FlatWireDB` is outside it. Cap `VARCHAR(500)` |
| Guards to replicate | the `' '` blank return, and the `UPDLOCK, HOLDLOCK` re-check — both already in `FlatWire_CompleteCoilOnSkid` |

> ⚠ **FL1 spool completion can no longer be tested on LocalDB.** LocalDB has no `CommonDB`, so the mint
> fails there. `CLAUDE.md` already carries this warning for check-in; it now applies to spool completion
> too, and it is a **developer-environment** consequence rather than a design one.

> **What the function's sweep does and does not cover.** It reads twelve objects across four databases —
> `united_db`, `SlitterDB`, `wiplogdb` and, through a synonym, `CommonDB..coils`, which **is** the table
> `FlatWire_CompleteCoilOnSkid` writes finished coils into (verified 22 Aug, `OI-125`). It takes **no locks**,
> and that is structural: locking four databases from a scalar function would need a distributed
> transaction. **It does not cover `FlatWireDB`**, which is why the ignore list is load-bearing — and why a
> *third-party* caller can still be issued an alpha an FL1 segment holds (**`Q59`**, accepted and monitored).

## 8.1 Run-end write-back — FL2/FL3 coil completion

**Every touchpoint in §8 above is a check-in-time or one-time-seed write. This section is the other end of the run**, and until 18 Aug 2026 it did not exist: a completed flat wire coil was written only to `FlatWireDB`, so packing, shipping, certification, cost and yield could not see the finished goods at all. Story **`FW-219`**, requirements **`FR-509`–`FR-518`**, procedure **`united_db.dbo.FlatWire_CompleteCoilOnSkid`** ([`Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql`](../Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql)).

> ⚠ **`D-32` still holds and this section does not weaken it.** Every write below lands in a column that **already exists**. No column is renamed, no column is added, no status vocabulary gains a value. `D-32` cancelled the shared-schema *migration*; it never prohibited writing the shared schema as it stands, which is what §8's opening sentence has always required.

**Scope is FL2 and FL3 only.** FL1 produces an intermediate spool, not a saleable coil, and a spool does not go on a skid — FL1 run completion writes `FlatWireDB.Spool` and stops there (`FW-202`).

| # | Shared object | Database | What is written | Why it cannot be skipped |
|---|---|---|---|---|
| 1 | `coils` | `proddb` | The finished-goods row: 43 explicit columns, inherited from the rod, with gauge / width / weights / OD / ID overridden. `coil_status = 'ONSKID'`, `coil_no_cuts = 1` | Nothing downstream can see a coil that has no `coils` row |
| 2 | `wip_coil_orders` | `proddb` | The order link, `coil_planned_wgt` / `smp_no` / `planned_operations` carried from the rod's row | The coil is otherwise unattached to the order it fulfils |
| 3 | `coil_gen_history` | `united_db` | Genealogy: parent = the primary source rod, child = the new coil, `in_xaction` = the flat wire token | The legacy genealogy chain terminates at the rod without it |
| 4 | `coil_cost` | `united_db` | Via `CoilCost_UpdateInsert`, proportional to net weight | **The single easiest omission here.** Without it the coil is invisible to cost and yield — the regression §8 exists to prevent |
| 5 | `coil_slit_cuts` | **`SlitterDB`** | **Exactly one row — a flat wire coil is one cut** | The packing and shipping chain joins through this table |
| 6 | `wip_skids` | `united_db` | Opened by coil 1 of 2, closed by coil 2 of 2 | **This is `CoilOutput.SkidId`'s referent.** See below |
| 7 | `wip_skid_coils` | `proddb` | One `(skid_no, coil_no)` row per coil | The two coils on a skid resolve to two traceability chains through this link |
| 8 | `wip_log` | `wiplogdb`, via `proddb..wip_log_view` | The WIP transaction, all 44 columns | The shop-floor transaction history has no other record of the event |

Steps 1–8 are **one transaction**, and it is **not** the same transaction as the `FlatWireDB` writes — the two halves are compensating writes across the boundary `[ARC §10]` already draws for check-in. The retry contract is `CoilOutput.CoilNo`: the caller persists it the moment the procedure returns and passes it back on any retry, at which point the procedure is a no-op.

### `OI-104` is closed — the skid table is `wip_skids` + `wip_skid_coils`

`CoilOutput.SkidId` has always been described as pointing at "the existing skid table", which **no document named, no story created and nothing verified**. It is `united_db..wip_skids`, linked to coils through `proddb..wip_skid_coils`, and skid numbers come from `proddb..generate_new_skid_no` — which is exactly what **`FR-339`** requires ("skid numbering and logic shall follow the existing skid rules"). Two consequences worth stating: `wip_skids.skid_no` is `char(9)` of the form `order_no(6) + rel_letter + seq(2)`, and `FR-339` becomes testable for the first time.

### Two identities for one coil, and they are not interchangeable

| Identifier | Value | Lives in | Used for |
|---|---|---|---|
| `CoilOutput.CoilAlpha` | `FW-00421-C01` | `FlatWireDB` | The customer-facing alpha, printed on the coil label |
| `CoilOutput.CoilNo` | `R00421A` | `FlatWireDB`, mirrored to `coils.coil_no` | The shared schema |

`coils.coil_no` is **`char(9)`** and `FW-#####-C##` is **twelve** characters — fourteen with the mid-run child suffix — so it does not fit, and widening the column is the migration `D-32` cancelled. The shared alpha is therefore minted by **`CommonDB.dbo.GenerateCoilAlpha(rodAlpha, '')`**, which appends `A`..`Z` to the six-character root and sweeps sixteen tables for uniqueness. This is not a workaround: it makes the output coils **children of the rod** in the legacy tree, so `coil_link_master_coil` maps them to master `R00421` and the genealogy reads the way every other UAL coil's does.

### Three things that will look like defects if you do not know they are deliberate

1. **`coil_gen_history` records one parent, not all of them.** A welded flat wire coil has many source rods — that is what induction welding is for — but `ins_coil_gen_history` is guarded on `child_coil_no` and the table's readers assume one row per child. The primary parent is the rod with the lowest `CoilTraceability.FootageFrom`. **`FlatWireDB.CoilTraceability` remains the authoritative multi-rod genealogy** and is what the welding-wire certificates are built from. Registered as **`OI-113`** — do not "fix" it by inserting several rows.
2. **`coils_iud_tg` is single-row only**, so this is one coil per call and must never be batched. Both it and `wip_skids_iud_tg` gate on `@ins_count = 1`; a set-based insert into `proddb..coils` silently skips the `coil_link_master_coil` row altogether.
3. **The suspend path reuses the legacy vocabulary.** An out-of-spec final SPC on DB7 sets `wip_skids.skid_status = 'HOLDP'` and writes a second `wip_log` row with `transaction_name = 'SKIDHOLD'` / `coil_skid_status = 'PRHOLD'` — the shared counterpart of `CoilOutput.Status = 'HOLD'`. No flat-wire-only status is invented.

### What this section deliberately does not cover

**Releasing `wip_stations.coilno`.** `FR-077` *sets* it at check-in and **no requirement clears it**; `wip_stations_k1` is UNIQUE on `CoilNo`, so an unreleased station collides with the next coil at that station. That is a live defect in its own right, it belongs to *run* completion rather than *coil* completion, and it is tracked as **`OI-112`**.

**Three values still need IT sign-off before this runs outside DEV** — `Q34` the eight-character `transaction_name` token (proposed `FWCOMPLT`), `Q35` whether `coil_status = 'ONSKID'` is right for finished flat wire, `Q36` what `smp_no` and `planned_operations` a flat wire output coil should carry. The `coil_slit_cuts` sentinels are **`OI-114`**, and they cannot be settled by copying a template because the five legacy non-slit writers disagree with each other.

---

---

### 9.4 Cross-database touchpoints

| Shared object | Database | Written when | By this module? |
|---|---|---|---|
| ~~`coils.coil_status = INFLAT`~~ | ~~shared~~ | **STRUCK — `D-32`, 18 Aug 2026.** See §8 | **No — `INFLAT` is never written to the shared column.** Writes of values that already exist there are unaffected |
| `coils` R-series row | shared | At rod receipt | No — **read only** |
| `wip_coil_orders` | `proddb` | Reqsum entry created at check-in if the rod is not yet reqsummed | **Yes** |
| `planning_routings` / `routings`.`actual_start_date` | shared | Updated at check-in | **Yes** |
| `planning_routings` rod→order allocation | shared | By Planning | No — **read** (this is how a scan resolves its order) |
| `wip_stations.coilno` | `CommonDB` | Updated on successful check-in | **Yes** |
| `machines` FL1/FL2/FL3 | `united_db` | One-time registration (FW-003) | Seeded once |
| **`wip_skids` / `wip_skid_coils`** | `united_db` / `proddb` | **At coil completion — see §8.1** | **Yes** |
| **`coils` finished-coil row, `coil_gen_history`, `coil_slit_cuts`, `wip_log`, `coil_cost`** | see §8.1 | **At coil completion** | **Yes** |
| **`alloys.alloy_density`** | `united_db` | Maintained by the Alloys module | **Read** — the authoritative density for all weight derivation |
| **`alloys.Draw_max_reduction`** | `united_db` | Maintained by the Alloys module | **Read** — the pass-schedule generator's draw-pass input |
| `Lots` / chemistry tables | shared | The far end of the cert chain | Read |

**WIP station registration** creates `FL1` (machine_idx 125), `FL2` (126), `FL3` (127), **`FL1PO`** (the Pre-Check-In station, sharing FL1's MachineIdx) and `FWPACK` (packing, MachineIdx NULL by design). **`FL2PO` is deliberately not created** — FL2 is excluded from pre-check-in. **There is no `FL3PO`**; the working assumption is that FL3 posts to `FL1PO` — **OI-26**.

> `AccountingDB.dbo.GetMachineTypeFromOpLetter` has **no case for the flattening letter `F`** and returns NULL for every flat-wire operation today, regardless of which `machine_type` is chosen — **OI-27**.

---

### 9.5 FW-001 — the shared-schema renames, **cancelled**

> ⚠ **CANCELLED — `D-32`, 18 Aug 2026. Nothing in this section is to be built.** It is retained because the rename table is quoted in a dozen documents and a reader who meets it elsewhere needs somewhere that says it is dead. `FW-001` and `FW-002` are both cancelled; the existing scheduling / `coils` schema is used **as it stands**.

Story **FW-001** *would have applied* **slash dual-naming** renames to the **existing shared scheduling / `coils` schema** — not to `FlatWireDB`.

| Current column | New column |
|---|---|
| `CoilNo` | `Coil/BundleNo` |
| `SlitWidth` | `Slit/FlatWidth` |
| `IsCampaingCoil` *(typo corrected)* | `IsCampaignCoil/Bundle` |
| `CoilLocation` | `Coil/BundleLocation` |
| `CoilWeight` | `Coil/BundleWeight` |
| `CoilStatus` | `Coil/BundleStatus` |
| `OutgoingCoilId` | `OutgoingCoil/BundleId` |
| `OutgoingCoilOd` | `OutgoingCoil/BundleOd` |

**Also cancelled:** the new columns `OutgoingCoil/BundleWidth` and `IncomingWireDia`, and the new status value **`INFLAT`** (`FW-002`).

**Not cancelled, because neither is a schema change** — both are rows and values in columns that already exist: the **new machine rows** FL1, FL2, FL3 (`FW-003`, machine_idx 125/126/127) and the **new operation letter `F`** in `PrevOpLetter`, `RemainingOps`, `RootRemainingOps`, `OpLetter`. **`OI-27` therefore stands** — `AccountingDB.dbo.GetMachineTypeFromOpLetter` still has no case for `F`.

**It had been the single highest-blast-radius change in the project.** These columns are read by upstream receiving, planning, scheduling, reporting, yield and cost, which is why a **full stored-procedure / view / report / query audit had to precede the migration** — 40 h costed in Phase 1C — with a regression pass at QA4. **All of it goes with the change:** the audit, the regression pass, the `[RB §6.3]` rollback treatment, and the migration script that was never written (`[GAP]` A1). **−60 h base**; with QA and contingency re-derived, Phase 1C **221 → 138 h**.

---
