# FlatWire cross-database scripts — folder manifest

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 23, 2026 — first issue. Eight scripts had accumulated here with no manifest, and the deploy order existed only as prose inside two of them, which disagreed.
**Status:** Active — the manifest and sign-off ledger for this folder

Everything here **crosses databases**. That is the whole hazard of the folder: a missing grant
surfaces as *a permission error on a three-part name*, which reads like a missing object and
sends people looking in the wrong place. The `united_db_` / `FlatWireDB_` / `CommonDB_` element of
each filename tells you **which database owns the object**, and is kept for exactly that reason.

**One is inbound, four are outbound, and the rest are setup.**
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
| **10** | `10_CommonDB_Insert_WIPStations_FlatWire.sql` | Reference data | `united_db` (`machines`), `CommonDB` (`WIPStations`, `MachineStationsConfiguration`) | **Rows, not objects** — FL1/FL2/FL3 machines, the WIP stations and their bindings | `FW-003` | ⚠ **Draft — `machine_type`, the station set and `StationType` pending sign-off** | ⚠ **NO — no reverse script exists.** Writes rows into **shared** tables other modules read |
| **20** | `20_FlatWire_Grants.sql` | Infrastructure | `united_db`, `proddb`, `CommonDB`, `SlitterDB`, `wiplogdb`, `FlatWireDB` | **No objects** — `ua_user` in six databases, role membership, `GRANT EXECUTE`, and `DELETE` on `proddb..wip_coil_orders` | `FW-220` / `FW-221` | Draft — run **once per environment** | Yes — revoke |
| **30** | `30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql` | Procedure (inbound) | `FlatWireDB` (home), reads `proddb..coils` + `united_db..alloys` | `FlatWireDB.dbo.sp_IngestRodFromCoils` | `FW-223` | **Ready to build — no open items** | Yes — goes with the database, via `FlatWire_DDL_99_Teardown.sql` |
| **40** | `40_united_db_Proc_FlatWire_CheckInRod.sql` | Procedure (outbound) | `united_db` (home), `proddb`, `CommonDB`, `wiplogdb` | `united_db.dbo.FlatWire_CheckInRod` | `FW-220` | ⚠ Draft — `transaction_name`, `coil_skid_status` and the `coils` rod-row stamp pending (`Q37`–`Q39`) | Yes — code only, via `99` |
| **50** | `50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql` | Procedure (outbound) | `united_db` (home), `proddb`, `SlitterDB`, `CommonDB`, `wiplogdb` | `united_db.dbo.FlatWire_CompleteCoilOnSkid` | `FW-219` | ⚠ Draft — `transaction_name`, `coil_status`, `smp_no` and the `coil_slit_cuts` sentinels pending (`Q34`–`Q36`) | Yes — code only, via `99` |
| **60** | `60_united_db_Proc_FlatWire_ReleaseStation.sql` | Procedure (outbound) | `united_db` (home), `CommonDB` | `united_db.dbo.FlatWire_ReleaseStation` | `FW-221` | **No open items** — introduces no new value into the shared vocabulary | Yes — code only, via `99` |
| **70** | `70_united_db_Proc_FlatWire_ReverseReqsum.sql` | Procedure (outbound) | `united_db` (home), `proddb`, `CommonDB` | `united_db.dbo.FlatWire_ReverseReqsum` | `FW-221` | ⚠ **Draft — the `proddb..wip_coil_orders` DELETE needs sign-off before any shared environment (`Q40`)** | Yes — code only, via `99` |
| **99** | `99_united_db_Proc_FlatWire_Teardown.sql` | Teardown | `united_db` | Drops the four `united_db` procedures | `FW-220` / `FW-221` | Draft | n/a — **drops code, not data** |

## What is NOT reversible, and why it matters

**Two teardowns exist, split by which database owns the object, and neither undoes shared data.**

- `99_united_db_Proc_FlatWire_Teardown.sql` drops the four `united_db` procedures. It
  **deliberately does not drop `sp_IngestRodFromCoils`** — that one lives in `FlatWireDB` and goes
  with the database.
- `../Schema/SQL/FlatWire_DDL_99_Teardown.sql` drops `FlatWireDB` entirely.

**Nothing reverses `10`.** The `machines` rows, the WIP stations and their bindings are writes into
tables other modules read, and no reverse script has been written. On a DEV environment they must
be removed deliberately and by hand. This is why `10` is a **sign-off gate**, not a step.

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
deliberately skips `10`.** See its header. Prove co-location first with the query in
`20_FlatWire_Grants.sql`, and see **`[DEP §4.2]`** for the full cross-folder sequence.
