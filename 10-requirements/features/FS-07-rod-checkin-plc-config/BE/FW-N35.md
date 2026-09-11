---
id: FW-N35
legacy_id:
title: The rod existence read - two FlatWireDB synonyms and a read-only coil-master lookup
status: in-review
status_confirmed: true
status_note: "**New 10 September 2026** - minted by `P-351` because `FR-064` / `CHK006` (validate the rod alpha against `coils`) **survived `P-54`** while the surface that closure assigned them to did not exist. ⛔ *'The receiving team's own surface'* is not an endpoint, a service, a screen or a named contact in any of the four checkouts, so Dashboard 2's scan had no way to validate anything and `FW-233`'s 6 h were released. ⭐ **Deliberately NOT hosted in `FW-223`**, whose own `depends_on` carries `FW-157`/`FW-158`/`FW-159`/`FW-220` - a read-only lookup depends on neither staging nor check-in, and parking it behind `FW-158` would block it for no reason. ⛔ **This is not `[API §4.3]` re-homed**: no staging projection, no allocation set, no `diameterIn`, and it **creates nothing** (`FR-530`). ⚠ Two of the six *Incoming Bundle Information* cells still have no source at all - `G130`. ⭐ **BUILT 10 September 2026, same day it was minted** - see §6. `dotnet build` 0 errors, `dotnet test` **316 passing (308 before, +8)**. ⭐ **DEPLOYED to `DEV00164-001` the same day**, as a **coils-only** variant: that instance already carries four synonyms no script here creates, and `dbo.alloys` is already the object this story would have created. ⛔ **BLOCKED BY WHAT THE DEPLOYMENT FOUND, and neither was findable any other way:** `G133` - the documented `alloy_idx` join **matches nothing** across 1,776 real rows and yields a **blank alloy**, because `coil_alloy` holds the designation and not an index; and `G134` - **`coils` holds no `R#####` rows at all**, so the endpoint answers `404` for every rod. The synonym, the trimming and the casts are proven; the data behind them is not there."
owner: Backend (.NET) stream
jira:
mvp: 1
phase: "4"
stream: DB
streams: [DB, BE]
priority: high
hours: 8
sprint: S2
depends_on: [FW-141, FW-142]
blocked_by: [G133, G134]
has_plan: true
started:
completed:
---

# FW-N35 - The rod existence read: two FlatWireDB synonyms and a read-only coil-master lookup

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 10, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⛔ **Built and DEPLOYED to `DEV00164-001` on 10 Sep 2026 — and blocked by what the deployment found.** The synonym and the read work; ⛔ the alloy join returns **blank** on every real row (`G133`) and there is **no rod row to read** (`G134`). See §6
**Owner:** Backend (.NET) stream, with the DB half
**Audience:** The developer building `FW-N35`
**Shortcode:** — *(implementation plan, derived from the specifications and the measured schema; **not citable as a requirement**)*
**Depends on:** [`FW-141`](../../FS-02-backend-service-foundation/BE/FW-141.md) · [`FW-142`](../../FS-02-backend-service-foundation/BE/FW-142.md) — both **done**
**Unblocks:** [`FW-061`](../FE/FW-061.md) `Step-7` — the rod scan row and the Incoming Bundle grid
**Part of:** category [`FS-07` Rod Staging, Check-In, PLC Configuration and Weld Capture](../../FS-07-rod-checkin-plc-config.md)

> ⚠ **Why `FS-07` and not `FS-15`, where `FW-223` and the other shared-schema work sits.** The
> placement rule is `build_consolidation_map.py`'s: `SHARED_SCHEMA` is a **closed, named set** —
> `FW-219`, `FW-220`, `FW-221`, `FW-223`, `FW-231` — and everything else takes its category from its
> phase, so **phase 4 → `FS-07`**. ✅ That is also right on the merits, and it is exactly what `P-351`
> decided: this is **the check-in gate**, addressed under `checkin/`, consumed by one screen — ⛔ not
> a receiving contract and not a general shared-schema surface. **Do not add this id to
> `SHARED_SCHEMA` to make it sit beside `FW-223`**; the two stories answer different questions.

---

## 1. What to build

**Hours:** 8 h (DB 3 · BE 5) · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Streams:** DB · BE

**As an** FL1 operator scanning or typing a rod number at check-in,
**I want** the system to tell me at once whether that rod exists and what it is,
**So that** a wrong or unknown alpha is refused before I start configuring the machine.

**The contract is [`[API §4.22]`](../../../../40-backend/APIs.md)** `GET /checkin/rod/{alpha}`, and
⛔ **this plan restates none of its fields** — read it there.

| # | Deliverable | Stream | Where |
|---|---|---|---|
| 1 | `36_FlatWireDB_Synonyms_SharedReads.sql` — **`dbo.coils` only**; ⛔ `dbo.Alloys` already exists on the target instance and is left alone (§6) | DB, 3 h | `30-database/scripts/` |
| 2 | `IContextRepository.GetCoilMasterAsync` + the `CoilMasterRead` record | BE, 2 h | `FlatWire.Domain/Repository/` |
| 3 | The Dapper implementation | BE, 1 h | `FlatWire.Infrastructure/Repositories/ContextRepository.cs` |
| 4 | The query, the handler and the `CheckInController` action | BE, 1 h | `FlatWire.API` / `FlatWire.Application` |
| 5 | Tests and the DI registration assertion | BE, 1 h | `FlatWire.UnitTests` |

⚠ **The code lands in the `Second-Branch` checkout** — `c:\UAL\Second-Branch\ual-api`. `c:\UAL\ual-api`
has no `FlatWire` domain at all.

---

## 2. The five things most likely to be got wrong

⛔ **1. A synonym must target an actual table, never another synonym.** `proddb.dbo.coils` is
**itself** a synonym for `[CommonDB]..[coils]` — six databases carry the same one — and SQL Server
does not permit a synonym on a synonym. The chain **fails at query time, not at creation**, so a
wrong target deploys perfectly and breaks later, in someone else's session. Target
`[CommonDB]..[coils]`, and prove it:
`SELECT type_desc FROM sys.objects WHERE object_id = OBJECT_ID(N'<target>')` must say `USER_TABLE`.

⛔ **2. The alloy resolution — and ⚠ THIS INSTRUCTION IS NOW KNOWN TO BE BACKWARDS.** It read:
*"`coil_alloy` is a `smallint` index into `united_db..alloys`; the name comes from `alloys.alloy`
joined on `alloy_idx`"*, following `sp_IngestRodFromCoils`'s C3 note. ⛔ **Measured on the shared
instance, that join matches NOTHING** — `alloy_idx` runs 1–89 and `coil_alloy` holds the designation
itself (1100, 3005, 5657). Joining on the **name** matches every row. **`G133`**, and it is
`[INT §7.9]`'s to settle: ⛔ do not re-point this one call site and leave the ingest procedure
disagreeing with it. ⚠ The original warning's *reasoning* still holds — a wrong alloy resolution
fails **silently**, as a blank rather than an error; only its direction was wrong.

⛔ **3. This read must not ingest.** `sp_IngestRodFromCoils` **writes**, requires `@@TRANCOUNT > 0`
and raises `55001` outside a transaction. `FR-530` is explicit that a lookup creates nothing: any
authenticated role may call this, so a supervisor scanning a rod merely to look at it must not mint
records. ⚠ This is the acceptance criterion `FW-223` has carried as *unexercisable* since 25 Aug —
it becomes exercisable here.

⚠ **4. A synonym reshapes nothing, so the query does.** `coil_no` is `char(9)` and blank-padded, so
`R00041` is `'R00041   '` on disk and an untrimmed predicate misses; the weights are `smallint` on
`coils` and `DECIMAL(8,2)` in the contract. Trim on both sides of the predicate and in the
projection, and `CAST` the weights — in the **one** Dapper query, which is their only reader.

⚠ **5. The permission is not where it looks.** A synonym carries **no** rights across the database
boundary: SQL Server checks the **base object, in its own database**, at execution. A missing right
in `CommonDB` therefore surfaces as an error naming the *synonym*, sending people to the wrong
database. `20_FlatWire_Grants.sql` — which makes `ua_user` a real user with `db_datareader` in all
six databases, and says in terms that *"ownership chaining is not relied on"* — is a **prerequisite**,
not a companion. Verify with `EXECUTE AS USER = 'ua_user'`, never as the deploying login.

---

## 3. Why this story exists rather than an edit to `FW-223`

`FW-223` owns rod **ingestion** and the `coils` → `Rod` column mapping, so it looks like the natural
home. ⛔ **Its front matter is why it is not:** `depends_on: [FW-007, FW-142, FW-144, FW-157, FW-158,
FW-159, FW-220]`. Those exist because its two call sites are `POST /staging/rod` and
`POST /checkin/rod`. **A read-only lookup has neither**, and hosting it there would park it behind
**`FW-158`** — the story that already blocks `FW-061`'s payoff occupancy — for no reason at all.

✅ **What `FW-223` does get** is two superseding notes, because it is where `FR-530` lives: its
`Last Updated` stack and its `GET /rod/{alpha}` acceptance criterion both say the rule is
unexercisable *because there is no host*. This story is that host.

⛔ **`FW-233` is not revived.** It is cancelled with a forwarding address and its id is never reused.

---

## 4. Verification

```powershell
cd "c:\UAL\Flatwire-planning\30-database\scripts"
sqlcmd -S "DEV00164-001" -E -C -b -i 36_FlatWireDB_Synonyms_SharedReads.sql
sqlcmd -S "DEV00164-001" -E -C -Q "SELECT name, base_object_name FROM FlatWireDB.sys.synonyms"
sqlcmd -S "DEV00164-001" -E -C -d FlatWireDB -Q "EXECUTE AS USER = 'ua_user'; SELECT TOP 1 coil_no FROM dbo.coils; REVERT;"
```

```bash
cd "c:/UAL/Second-Branch/ual-api"
dotnet build API/Domain/FlatWire/FlatWire.sln
dotnet test  API/Domain/FlatWire/FlatWire.UnitTests
```

⛔ **Deploy to the shared instance, never LocalDB** — `FlatWireDB` must sit alongside `CommonDB` and
`united_db` or the synonyms resolve to nothing. `DEV00164-001` is where co-location was proven.

## 5. Acceptance criteria

- [x] `sys.synonyms` shows `dbo.coils` → `[CommonDB].[dbo].[coils]` ✅ *(deployed 10 Sep 2026)*; ⛔ `dbo.Alloys` is **not created here** — it already existed (§6)
- [x] Each base object resolves to a **`USER_TABLE`**, proven by `sys.objects.type_desc` ✅
- [x] ⛔ The synonym does not target `proddb..coils` — that is itself a synonym ✅
- [ ] `GRANT SELECT` only, to `ua_user`; ⛔ no `INSERT`/`UPDATE`/`DELETE`, which `D-32` forbids
- [ ] A `SELECT` **as `ua_user`** succeeds against both — not merely as the deploying login
- [ ] The script is idempotent, and on a `FlatWireDB`-only instance it exits **green** while printing a warning that names the missing database
- [ ] ⛔ **Blocked by `G133`** — the alloy comes back **blank** on every real row, because the documented join key is backwards
- [ ] A blank-padded `coil_no` matches the trimmed predicate
- [ ] ⛔ **Blocked by `G134`** — *every* alpha returns `404` on this instance, because `coils` holds no `R#####` rows to distinguish a known rod from an unknown one
- [ ] ⛔ **`Rod` gains no row from any call** (`FR-530`) — the criterion `FW-223` could not exercise
- [ ] The response matches `[API §4.22]` field for field, with **no** `diameterIn`, `heatNumber` or `supplier`
- [ ] `30-database/scripts/README.md`'s manifest gains its row

## 6. Out of scope

- ⛔ **Any write to the shared schema.** This is a read; `D-32` holds.
- ⛔ **`coils_hist`.** An archived rod reads as *not found* — recorded as `G131`, not answered here.
- ⛔ **The heat number and the supplier name** — `OI-117` and `G130`. ⛔ Do not press
  `coil_origin_code` or `vendor_no` into service as either.
- ⛔ **`[API §4.3]` and `§4.20`.** Both stay withdrawn; the allocation-set read is `G129`'s.
- ⛔ **The standalone `FlatWireDB..Alloys` view** `[DBD §6.6]` used to specify — retired by `P-353`.
- The Angular consumer, which is [`FW-061`](../FE/FW-061.md) `Step-7`.

## 6. What was built — measured 10 September 2026

✅ **All five deliverables in §1 exist.** `dotnet build` **0 errors**; `dotnet test` **316 passing,
up from 308** — 8 new, all on the offline path.

| Delivered | Where |
|---|---|
| The two synonyms, guarded, granted and torn down | `30-database/scripts/36_FlatWireDB_Synonyms_SharedReads.sql`, wired into `RunAll` and `99_` |
| `GetCoilMasterAsync` + the `CoilMasterRead` record | `FlatWire.Domain/Repository/IContextRepository.cs` |
| The Dapper read, absorbing all three mismatches | `FlatWire.Infrastructure/Repositories/ContextRepository.cs` |
| `CoilMasterResponse`, the service method, the controller action | `Models/CheckIn/CheckInContracts.cs` · `CheckInService.cs` · `CheckInController.cs` |
| The offline path and its 8 tests | `StubCheckInService.cs` · `StubCheckInServiceCoilMasterTests.cs` |

### ⭐ DEPLOYED TO `DEV00164-001` — 10 September 2026, and it found two things the tests could not

✅ **`36_` ran green on the shared instance** and `dbo.coils` now resolves to `[CommonDB].[dbo].[coils]`.
The query runs: trimming, the `smallint → DECIMAL(8,2)` casts and `coilStatus` all behave.

⛔ **A COILS-ONLY VARIANT WAS DEPLOYED, BECAUSE THE ALLOY SYNONYM ALREADY EXISTED.** `FlatWireDB`
on that instance already carries **four synonyms — `accounts`, `alloys`, `Lookups`, `vendors` — that
no script in `30-database/scripts/` creates**, and `dbo.alloys` already targets `[united_db]..[alloys]`,
which under a case-insensitive collation *is* the `dbo.Alloys` this story was about to create. Creating
it would have dropped and recreated an object this repository neither authored nor tracks, on a shared
instance, to land exactly where it already was. ⚠ **`35_`'s `WIPStations` view is not deployed there
either** — the database has **zero views**. That drift is `G100`'s shape and is now recorded in the
script's `C6`.

⛔ **`G133` — THE ALLOY JOIN IS KEYED THE WRONG WAY ROUND.** Measured against 1,776 real rows:
`ON a.alloy_idx = c.coil_alloy` matches **nothing**. `alloys.alloy_idx` runs **1–89** while
`coils.coil_alloy` holds the **designation itself** — 1100, 3005, 5657, 23 distinct values — and
joining on the name matches every row. ⚠ **This contradicts `sp_IngestRodFromCoils`'s C3 note, which
states the opposite in capitals**, and which `[INT §7.9]`, `[API §4.22]`, this story and the built
read all follow. ⛔ **It fails silently in the worst direction:** `ISNULL(a.alloy, '')` turns the
no-match into a **blank alloy** rather than an error. ⛔ Not repaired here — `[INT §7.9]` owns the
mapping, and re-pointing one call site would leave the ingest procedure disagreeing with it.

⛔ **`G134` — THERE ARE NO ROD ROWS IN `coils` AT ALL.** Zero of the 1,776 match `R#####`, and none
of the seeded `R00041`–`R00043` the fixtures and `FW-223` assume; the alphas are legacy strip coils.
Meanwhile `FlatWireDB.dbo.Rod` holds **8 rows** — the local mirror is populated while the master it is
projected from is empty, inverting `D-04`. **So this endpoint returns `404` for every rod on that
instance.** It is correct and unusable, and ⛔ seeding `R#####` rows into a shared master to fix that
is exactly what `D-32` forbids.

⚠ **Still unproven:** the `ua_user` permission path. `EXECUTE AS` under a sysadmin login does not
exercise what the service account actually experiences across the database boundary, and there is no
rod row to read even if it did. ⛔ **Do not read the green test run as covering any of this:** the 8
tests exercise the **stub**, and a stub cannot be wrong about SQL it never issues — which is precisely
why both gaps stayed invisible until the read ran against real data.

✅ **What was proven earlier on a scratch database** with neither shared database present:
the script exits **green**, prints warnings naming `CommonDB` and `united_db`, **creates both
synonyms anyway** — `CREATE SYNONYM` defers where `35`'s `CREATE VIEW` binds — and is idempotent on
re-run, with `base_object_name` reading `[CommonDB].[dbo].[coils]`, ⛔ not `proddb`.

⚠ **Three things the build found that the plan had not.**

1. ⛔ **A T-SQL comment trap that cost the first deploy.** The header wrote the withdrawn rod route
   with a wildcard, and its slash-star sequence **opens a nested block comment** — T-SQL nests them —
   so the first close mark ended only the inner one and the file failed with *Msg 113, missing end
   comment mark*. The header now warns about it in terms. ⚠ It was found by **running** the file;
   reading it does not show it.
2. ⛔ **`StubCheckInService` had to implement the method too**, which the plan never named. The
   compiler found it. A stub that answered every scan would have left the not-found path — the one
   an operator actually hits — as the only one never exercised offline, so `R00099` is now a
   deliberate negative fixture and `R00043` a `COMPLETE` one.
3. ⛔ **`99_`'s teardown knew nothing about synonyms.** It drops the four procedures and the
   `WIPStations` view by name, so both synonyms would have survived a teardown and a rebuild would
   have found them already present. Added, with `N'SN'` — ⚠ passing `N'U'` or `N'V'` there finds
   nothing and the drop silently does not happen, which looks identical to a clean teardown.

⛔ **No DI change was needed and none was invented.** Both interfaces were already registered; the
compiler enforced both implementations, which is what surfaced finding 2.

## 7. Handoff

- ✅ **Deployed to `DEV00164-001`, 10 Sep 2026** — and it is what raised `G133` and `G134`.
- ⛔ **`G133` first, and it is not this story's to close.** `[INT §7.9]` owns the `coils` → `Rod`
  mapping and `sp_IngestRodFromCoils` carries the same instruction, so the join key is corrected in
  **one** pass across both or not at all.
- ⚠ **The `ua_user` path is still unproven.** `EXECUTE AS` under a sysadmin login does not exercise
  what the service account meets across the database boundary — and with `G134` open there is no rod
  row to read even if it did.
- ⚠ **Four undocumented synonyms and a missing `WIPStations` view** on that instance. Neither is this
  story's, both are recorded in `36_`'s `C6`, and the drift is `G100`'s shape.
- ⚠ **`ual-database` has no `FlatWireDB` folder.** When one is added, the two synonyms want mirror
  copies at `Databases/FlatWireDB/Synonyms/{coils,Alloys}.sql` per the `create-synonyms` convention.
  ⛔ Do not create a half-populated database folder there for these two files alone.
- ⚠ **`G132`** — `P-54`'s `CoilCheckin` substitute claim is false and is still quoted in three
  places. Correcting those sentences is `[API]`'s and `FW-138`'s, not this story's.
