# FlatWire cross-database scripts — folder manifest

**Project:** Flat Wire Mill Implementation
**Last Updated:** September 5, 2026 (fifth pass) — ➕ **`08_CommonDB_OPCModules_ColumnDrift.sql` added — the folder is now twelve scripts, and `G100` no longer stops `11`.** `dbo.OPCModules` on `DEV00164-001` was missing the two columns `ual-database` declares; they were added there **by hand** and `08` is the record of that change — guarded per column, idempotent, **writes no row**. `11` §4a now binds clean, measured. ⛔ **Two findings came with the fix.** **(a)** `11`'s drift guard **could never fire** — it shared a batch with §4a, and column names bind at *batch compile* time, so `Msg 207` killed the guard along with the batch; it is now **§0**, in a batch of its own, and proven to abort before the seed batch is sent (`SET NOEXEC ON` does not help, and `:on error exit` is not used because it is SQLCMD-mode-only — pass **`-b`**). **(b)** Adding the columns **removed an interlock**: `CREATE OR ALTER` on `dbo.GetOPCServerAndTagDetails` used to be impossible and now succeeds, while `OPCModulesIdx` 1-4 are `NULL` in both columns and `OPCInfo` maps them as non-nullable `int` — **backfill before refreshing that procedure**, or `GetOPCInfo` throws for four other modules. See `G100`. ⚠ **`09` is no longer "the only runnable script"**, and both `08` and `09` have now been applied to `DEV00164-001`. *(previously September 5, 2026 (fourth pass) — ➕ **`09_CommonDB_OPCTables_Constraints.sql` added — the folder is now eleven scripts, and this is the first one that is actually runnable.** The five `CommonDB` OPC tables are pure **heaps**: no primary key, no unique index, no foreign key, no check constraint. Their `united_db` predecessors carry PKs and two FKs; the constraints were lost in the migration to `CommonDB` and never re-created. `09` restores them **before `11_`**, which turns every one of `11_`'s hand-written idempotency guards into a schema guarantee. ⛔ **`G100` does not block `09`** — it touches only columns that exist on both `DEV00164-001` and source control. *(previously September 5, 2026 (third pass) — ✅ **`G97` RESOLVED (`D-49`): `11` uses the OPC UA endpoint pair at `OPCServersIdx` 1 and 2, both lines onto both, so `OPCServerApplicationMapping` takes 4 rows and the script has no placeholder left.** ⚠ **`OPCServers` is a lookup (`D-48`)** — `11` writes four tables and reads the fifth; `16` reverses nothing there. ⛔ **`G100` is now the only thing stopping `11` running.** *(previously September 5, 2026 (second pass) — ⛔ **`11_` gains a sixth pre-flight guard and a second reason it cannot run: `G100`.** Measured against `DEV00164-001`, the instance `[DEP §2]` names as the `test1` database server: **`CommonDB.dbo.OPCModules` has four columns there against `ual-database`'s six**, so §4a's insert would have failed on `Msg 207` — after all five original guards passed. ⚠ **The script is correct and the database is stale** (the deployed `GetOPCServerAndTagDetails` does not select the two columns either); the other four OPC tables match column for column. Refresh `CommonDB` — **the table *and* the procedure** — before running. *(previously September 5, 2026 — **`11_` (the OPC registration) and `16_` (its reverse) added, `FW-238` / `G60`.** The folder is now ten scripts. `11_` is the second sign-off gate in here and the first one that **cannot run at all** until an outside answer arrives — it aborts on its own placeholder until the OPC UA endpoint is supplied (`G97`). *(previously August 26, 2026 — first issue. Eight scripts had accumulated here with no manifest, and the deploy order existed only as prose inside two of them, which disagreed.)*)*)*)*)*
**Status:** Active — the manifest and sign-off ledger for this folder

Everything here **crosses databases**. That is the whole hazard of the folder: a missing grant
surfaces as *a permission error on a three-part name*, which reads like a missing object and
sends people looking in the wrong place. ⚠ **`09` is the exception to the "everything here crosses
databases" rule** — it is `CommonDB`-only, and it is here because the tables it hardens are the ones
`11_` and `16_` write. The `united_db_` / `FlatWireDB_` / `CommonDB_` element of
each filename tells you **which database owns the object**, and is kept for exactly that reason.

**One is inbound, four are outbound, two are shared-reference-data seeds, and the rest are setup.**
`30_…sp_IngestRodFromCoils` projects a rod *into* `FlatWireDB` from the shared schema. The four
`united_db` procedures write *out* to the shared schema at check-in, run end and reversal.

⚠ **No file here is in any `:r` chain, and that is deliberate** — none can be verified by a
`FlatWireDB`-only deploy. The numeric prefixes give the **deploy order**, which is documented once
in **`[DEP §4.2]`**; this file does not restate the sequence.

⚠ **The five procedures have no mutual dependency.** `CREATE PROCEDURE` uses deferred name
resolution, so `30`–`70` may be created in any order among themselves. The numbers group them; they
do not impose an order that exists.

---

## The scripts

| # | Script | Category | Target databases | Creates | Story | Sign-off | Reversible? |
|---|---|---|---|---|---|---|---|
| **08** | `08_CommonDB_OPCModules_ColumnDrift.sql` | Schema drift | `CommonDB` — **ALTERs** `dbo.OPCModules` and nothing else | **Two columns, no rows** — `OPCEventType` and `EventDurationSeconds`, both `int NULL`, exactly as `ual-database`'s `CreateTable.sql` declares them. **Writes no row, creates no constraint, drops nothing** | `FW-238` | ✅ **Runnable — and on `DEV00164-001` already a no-op.** The columns were added there **by hand** 5 Sep 2026; this script is the record of that change, not a pending one — it reports *present* twice and exits `0`. It closes the half of `G100` that blocked `11_`. ⛔ **It does NOT backfill**: `OPCModulesIdx` 1-4 are left `NULL`, and §4's audit prints them — read `G100` before refreshing `GetOPCServerAndTagDetails` | ❌ **No, deliberately** — dropping a column that source control declares would re-create the drift. Same position `09` takes |
| **09** | `09_CommonDB_OPCTables_Constraints.sql` | Schema hardening | `CommonDB` — **ALTERs** the five OPC tables: the four `11_` writes plus `OPCServers` | **Objects, not rows** — 5 clustered PKs, 6 unique constraints, 4 FKs, 1 check constraint, 2 indexes. **Writes no row and alters no column** | `FW-238` | ✅ **Runnable, and applied to `DEV00164-001` on 5 Sep 2026** — all 18 objects measured present there. ⛔ **Not blocked by `G100`**: it references only columns that exist on *both* that instance and source control. Pre-flight measured there the same day — **16 checks, 0 conflicts**. ⚠ **Independent of `08`** — neither touches what the other checks, so either order works; both must precede `11` | ⚠ Partly — DEV only and **by hand**; no reverse script. Every object is named `PK_OPC*` / `UQ_OPC*` / `FK_OPC*` / `CK_OPC*` / `IX_OPC*`, and §6 lists them. Dropping a clustered PK returns the table to a heap |
| **10** | `10_CommonDB_Insert_WIPStations_FlatWire.sql` | Reference data | `united_db` (`machines`), `CommonDB` (`WIPStations`, `MachineStationsConfiguration`) | **Rows, not objects** — FL1/FL2/FL3 machines, the WIP stations and their bindings | `FW-003` | ⚠ **Draft — `machine_type`, the station set and `StationType` pending sign-off** | ⚠ **NO — no reverse script exists.** Writes rows into **shared** tables other modules read |
| **11** | `11_CommonDB_Insert_OPCRegistration_FlatWire.sql` | Reference data | **Writes** `CommonDB` (`OPCModules`, `OPCServerApplicationMapping`, `OPCTags`, `OPCTagApplicationMapping`); **reads** `CommonDB.OPCServers` — a **lookup** it never inserts into or updates (`D-48`) — and `united_db` (`machines`) | **Rows, not objects** — the flat wire OPC module at `OPCModulesIdx` **6**, **4** server-mapping rows *(both lines onto the **existing** endpoint pair `OPCServersIdx` 1 and 2, `ConnectionSequence` 1 and 2 — `D-49`)*, and **41 tag rows** (39 data + 2 system-error) for FL1 and FL2 | `FW-238` | ⚠ **Draft — MUST NOT RUN YET, and only `FW-236`/`G94` is why.** ✅ **`G97` RESOLVED (`D-49`)** — `OPCServersIdx` **1 and 2**; the script carries real values and no placeholder. ✅ **`G100` CLEARED on `DEV00164-001`, 5 Sep 2026** — `dbo.OPCModules` carries all six columns (see `08`) and §4a binds clean, measured with a `SET NOEXEC ON` compile pass returning zero messages. ✅ **Its drift guard now works**: it was in the same batch as §4a and could never fire, because column names bind at *batch compile* time; it is now **§0**, in a batch of its own, and proven to abort before the seed batch is sent. Under sqlcmd pass **`-b`** — `:on error exit` is deliberately not used, being SQLCMD-mode-only in a by-hand script. ⛔ **Gated on `FW-236`/`G94` merging** — now the only thing between this script and a clean run | Yes — `16_`, DEV only |
| **16** | `16_CommonDB_Delete_OPCRegistration_FlatWire.sql` | Teardown (rows) | `CommonDB` — the **four** tables `11_` writes. ⛔ **Not `OPCServers`** (`D-48`) | **Removes** what `11_` wrote, mappings before the rows they point at. ⛔ **Deletes nothing from `OPCServers`** — `11_` put nothing there | `FW-238` | Draft — **DEV only** | n/a — it *is* the reverse |
| **20** | `20_FlatWire_Grants.sql` | Infrastructure | `united_db`, `proddb`, `CommonDB`, `SlitterDB`, `wiplogdb`, `FlatWireDB` | **No objects** — `ua_user` in six databases, role membership, `GRANT EXECUTE`, and `DELETE` on `proddb..wip_coil_orders` | `FW-220` / `FW-221` | Draft — run **once per environment** | Yes — revoke |
| **30** | `30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql` | Procedure (inbound) | `FlatWireDB` (home), reads `proddb..coils` + `united_db..alloys` | `FlatWireDB.dbo.sp_IngestRodFromCoils` | `FW-223` | **Ready to build — no open items** | Yes — goes with the database, via `FlatWire_DDL_99_Teardown.sql` |
| **40** | `40_FlatWireDB_Proc_FlatWire_CheckInRod.sql` | Procedure (outbound) | **`FlatWireDB` (home)**, `united_db`, `proddb`, `CommonDB`, `wiplogdb` | `FlatWireDB.dbo.FlatWire_CheckInRod` | `FW-220` | ⚠ Draft — `transaction_name`, `coil_skid_status` and the `coils` rod-row stamp pending (`Q37`–`Q39`) | Yes — code only, via `99` |
| **50** | `50_FlatWireDB_Proc_FlatWire_CompleteCoilOnSkid.sql` | Procedure (outbound) | **`FlatWireDB` (home)**, `united_db`, `proddb`, `SlitterDB`, `CommonDB`, `wiplogdb` | `FlatWireDB.dbo.FlatWire_CompleteCoilOnSkid` | `FW-219` | ⚠ Draft — `transaction_name`, `coil_status`, `smp_no` and the `coil_slit_cuts` sentinels pending (`Q34`–`Q36`) | Yes — code only, via `99` |
| **60** | `60_FlatWireDB_Proc_FlatWire_ReleaseStation.sql` | Procedure (outbound) | **`FlatWireDB` (home)**, `united_db`, `CommonDB` | `FlatWireDB.dbo.FlatWire_ReleaseStation` | `FW-221` | **No open items** — introduces no new value into the shared vocabulary | Yes — code only, via `99` |
| **70** | `70_FlatWireDB_Proc_FlatWire_ReverseReqsum.sql` | Procedure (outbound) | **`FlatWireDB` (home)**, `united_db`, `proddb`, `CommonDB` | `FlatWireDB.dbo.FlatWire_ReverseReqsum` | `FW-221` | ⚠ **Draft — the `proddb..wip_coil_orders` DELETE needs sign-off before any shared environment (`Q40`)** | Yes — code only, via `99` |
| **99** | `99_FlatWireDB_Proc_FlatWire_Teardown.sql` | Teardown | `FlatWireDB` | Drops the four `FlatWireDB` procedures | `FW-220` / `FW-221` | Draft | n/a — **drops code, not data** |

## What is NOT reversible, and why it matters

**Three teardowns exist now, split by which database owns the object. Only one of them undoes
shared data, and it is DEV-only.**

- `99_FlatWireDB_Proc_FlatWire_Teardown.sql` drops the four `FlatWireDB` procedures. It
  **deliberately does not drop `sp_IngestRodFromCoils`** — that one lives in `FlatWireDB` and goes
  with the database.
- `../sql/FlatWire_DDL_99_Teardown.sql` drops `FlatWireDB` entirely.
- `16_CommonDB_Delete_OPCRegistration_FlatWire.sql` removes `11_`'s rows from the **four** `CommonDB`
  OPC tables it writes. **This one does touch shared tables**, which is why it is DEV-only and why it
  deletes by exact value, taking the mappings out before the rows they point at. ⛔ **It removes
  nothing from `OPCServers`** — that table is a **lookup** and `11_` only ever selects from it
  (`D-48`), so there is no flat wire row in it to reverse. Delete `OPCTags` first and the mapping rows are
  orphaned — ⚠ **this is now conditional on `09`: once it has run,
  `FK_OPCTagApplicationMapping_OPCTags` turns that into a hard error instead of silent corruption;
  before it, `OPCTagsIdx` carries no foreign key anywhere in source control** — and the natural key
  `11_` matches on stops resolving, so a later re-run inserts duplicates instead of skipping.

**Nothing reverses `10`.** The `machines` rows, the WIP stations and their bindings are writes into
tables other modules read, and no reverse script has been written. On a DEV environment they must
be removed deliberately and by hand. This is why `10` is a **sign-off gate**, not a step.

⚠ **The absence of FL3 from `11` is deliberate too, and for a different reason (`G99`).** FL3 has
no controller of its own — it reaches FM1 through FL1 and FM2 through FL2 — so machine 127 gets no
OPC registration and `GetOPCInfo` answering **empty** for FL3 is correct. That is `FW-151`'s
tripwire firing, not a defect. Do not "fix" it by seeding 127: the two-controller write it implies
is undesigned, and `11`'s verification block asserts 127 is absent.

⚠ **`G21` — the absence of an `FL3PO` station in `10` is deliberate, not an omission.** FL1 and
FL3 **share one physical payoff station, `FL1PO`**; Dashboard 2A maps
`STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"}` and the client confirmed rods are never stacked,
two maximum, one per payoff (`Q71`).

## A privilege seam worth knowing

`20_FlatWire_Grants.sql` provisions **`ua_user`** across six databases, while all five procedures
`GRANT EXECUTE … TO [public]`. Those are different mechanisms: `[public]` membership is
per-database and automatic, so the grant on the procedure is about *execute rights on that object*,
while the grants script is about the account **existing as a user** in each database at all.
A procedure can be executable and still fail on its first cross-database statement without `20`.

`20` also carries **no literal `USE`** — every `USE` is inside `sp_executesql`, because a bare
`USE` against a database that does not exist fails with Msg 911 and aborts the rest of the batch.
That is deliberate; the script is expected to run on developer instances that have some of the six
databases and not others.

## Running them

There is a runner, [`FlatWire_Scripts_RunAll.sql`](FlatWire_Scripts_RunAll.sql), and **it
deliberately skips `08`, `09`, `10`, `11` and `16`.** See its header. `10` and `11` are run by hand
after sign-off; `16` is DEV-only; **`08` and `09` are run by hand too, and both belong *before*
`11`** — `08` levels `dbo.OPCModules` with source control, `09` hardens the very tables `11` writes
into. They are independent of each other, so either order works. ✅ **`G97` is resolved (`D-49`) and
`11` has no placeholder left** — it carries `OPCServersIdx` **1 and 2**. ✅ **`G100` no longer stops
it either**: `dbo.OPCModules` on `DEV00164-001` now carries all six columns, and `11` §4a binds
clean. ⛔ **What is left is that it must not be activated until `FW-236` (`G94`) has merged**,
because flat wire is the first module to select `ual-api`'s `OPCUAManager` — now the *only* thing
holding the script back. Prove co-location first with the query in `20_FlatWire_Grants.sql`, and see
**`[DEP §4.2]`** for the full cross-folder sequence.

⚠ **`08` and `09` have both been applied to `DEV00164-001`** (5 Sep 2026, measured). Neither is a
pending step there; both are idempotent, so re-running either reports *present* and changes nothing.
**Staging and production are unmeasured** — `[DEP §2]` still carries them as *fill* — so run `08`
against any instance whose state you have not checked, and read `G100` before refreshing
`dbo.GetOPCServerAndTagDetails` on any of them.
