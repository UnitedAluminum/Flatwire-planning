---
id: FW-N16
legacy_id:
title: The station claim — FlatWireDB..WIPStations view and the checked-in-material read
status: in-progress
status_confirmed: true
status_note: "🔄 **In progress — the read is BUILT and green; only the `G54` half is outstanding (8 Sep 2026).** ✅ Delivered: `FlatWireDB.dbo.WIPStations` view (`30-database/scripts/35_…`, two columns, trimmed, `SELECT`-only grant, dropped by `99_…Teardown`), `IContextRepository.GetWipStationAsync` + its Dapper read, `ActiveRunResponse.stationClaim`, `ComponentStateItem.edgeType`, the idle rule as `StationClaim.Resolve` with **6 unit tests**, and the Angular client preferring the claim over the payoff. `[API §4.7a]` brought level. ⚠ **Two departures from the card, both deliberate — see §4.** ⛔ **Still blocked by `G54` for FL2/FL1-segment material**, and FL2 still reads the idle sentinel (`OI-115`). *(previously: ⬜ **Not started. `[INT]` describes `WIPStations` only as a WRITE (`FW-221`); no story covers it as a READ**, which is what the Active Run screen needs to know which material is at a line. ✅ The read is cheap: `WIPStation` is `UNIQUE CLUSTERED`, so it is a clustered seek, and station name equals line id by rule. ⛔ **`CoilNo = WIPStation` means IDLE** — all 78 pre-existing rows verified 28 Jul 2026. ⛔ **Blocked by `G54`**: nothing writes `SpoolTraceability` or registers an FL1 segment alpha in `proddb..coils`, so `FW-230`+`FW-231` must ship together first. ⚠ **And on FL2 the read will find the idle sentinel through a real run** — no spool check-in proc exists at all (`OI-115`), which is a separate writer gap, not this story's.)*"
owner:
jira:
mvp: 1
phase: "5"
stream: BE
streams: [BE, DB]
priority: critical
hours: 12
sprint: S2
depends_on: [FW-164, FW-230, FW-231]
blocked_by: [G54]
has_plan: true
started:
completed:
---

# FW-N16 - The station claim — FlatWireDB..WIPStations view and the checked-in-material read

> **§1 is the contract from `[TB]`; [§4](#4-what-was-built-and-the-two-departures-from-the-card--8-september-2026)
> is what was actually built, on 8 September 2026, and the two places it departs from the card.**
> Read §4 before touching any of this — both departures follow rules stated elsewhere in the repo
> that the card did not know about, and reverting either re-breaks them.

## 1. What to build

**Hours:** 8 h BE · 4 h DB · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** BE + DB

> **New 7 September 2026** — minted by `D-55`. The Active Run screen shows *the material checked in at
> this line*, and that fact lives in the shared WIP-station table. ⚠ **`[INT]`'s cross-database table
> only ever lists `wip_stations.coilno` as a write** (claimed by `FlatWire_CheckInRod`, released by
> `FlatWire_ReleaseStation`); **nothing owned reading it back.**

**As a** client developer,
**I want** the active-run response to carry the material claimed at the line's station,
**So that** one machine-driven screen can show the right rod or spool without a second call.

**Acceptance Criteria:**
- [x] A **`FlatWireDB..WIPStations` view** over `CommonDB.dbo.WIPStations`, following `[DBD §6.6]`'s
      convention that a cross-database mapping lives in **one object** *(the existing
      `FlatWireDB..Alloys` view over `united_db..alloys` is the precedent)*
- [x] ⛔ **No shared object is altered.** A view is a read, so **`D-32` holds** — *"the existing schema
      is read and written as it stands and never altered"*
- [x] The read keys on `LTRIM(RTRIM(WIPStation)) = @station` — a seek on `wip_stations_k0`
      (`UNIQUE CLUSTERED` on `WIPStation`). ⛔ **Not on `MachineIdx`**: it is `smallint NULL` with **no
      index**, and **`FL1PO` shares FL1's value**, so that key scans and returns two rows for FL1
- [x] ⛔ **`CoilNo` is treated as ABSENT when it is `''` or equals the station name** — the same test
      `FlatWire_ReleaseStation` applies. An idle station parks its own name there because
      `wip_stations_k1` is a plain `UNIQUE` index admitting only one `NULL`
- [x] Values are **trimmed on read** — `WIPStation` is `varchar(6)` and `CoilNo` `varchar(9)`, both
      space-padded by convention
- [x] The claim **rides the existing `GET /run/active?line=` response** rather than a second call, per
      `P-254`. An absent claim degrades to the idle state, never to an error
- [x] ⛔ **This story is READ-ONLY.** Claiming is `FlatWire_CheckInRod`'s and releasing is
      `FlatWire_ReleaseStation`'s, called by `FW-174` (checkout modes A and B) and `FW-202` (run
      completion). **Do not add a second writer**
- [x] ⚠ **Record, do not fix:** `CoilNo` is `varchar(9)`, which fits a rod (`R#####`, 6) and a spool
      (`SP-#####`, 8) but **not** an output coil (`FW-#####-C##`, 12). This column carries *input*
      material only
- [x] `GRANT` per `FW-152`'s least-privilege model — `GRANT SELECT` and nothing else

**Rate-card basis:** one view **4 h DB** + the read and its response field **8 h BE** = 12 h, mirroring
`FW-164`'s own basis (*"2 query endpoints @ 4 h = 8 h + `RunQueryService` / Dapper paging 4 h"*).
⛔ **Not 0 h** — `hours: 0` pairs with `status: cancelled` in this repo (`FW-001`, `FW-002`).
**Dependencies:** FW-164, FW-230, FW-231
**Blockers:** ⛔ **`G54`** *(`Critical` — nothing writes `SpoolTraceability`, nothing registers an FL1
segment alpha in `proddb..coils`; `FW-230` alone reissues `R00001A` on every spool, so it and `FW-231`
ship together or neither)*

---

## 2. What this story does NOT cover

⚠ **The read is correct on all three lines. What it *returns* on FL2 is a different gap.**

`FlatWire_CheckInRod` **throws `52003`** for FL2 — *"FL2 spool check-in is not handled here and its
shared write set is undefined"* — and `30-database/scripts/` holds **no spool check-in procedure at
all** (`sp_IngestRodFromCoils`, `FlatWire_CheckInRod`, `FlatWire_CompleteCoilOnSkid`,
`FlatWire_ReleaseStation`, `FlatWire_ReverseReqsum`, `FlatWire_Teardown` — and nothing else). So
**nothing claims FL2's station**, and this read will find the idle sentinel through a real FL2 run.

⛔ **That writer is `OI-115`'s territory and needs its own story.** Do not fold it in here, and ⛔ **do
not let this story's green tests imply that FL2 works** — they will pass against an idle station.
Whatever writes the FL2 claim must carry the **same `@station = @machineName` guard** the rod path enforces.

## 3. Context you need

| Where | What it settles |
|---|---|
| **`D-55`** ([`[MS §10.2]`](../../10-requirements/MasterSpecification.md)) | The decision this story implements, including the idle rule |
| [`ActiveRunMonitor.md §1.4a`](../../10-requirements/screens/ActiveRunMonitor.md) | The idle rule in the client's own words |
| [`[INT]`](../../20-architecture/Integration.md) | The cross-database touchpoint table — ⚠ it lists this table as a **write**; this story adds the read |
| `30-database/scripts/40_FlatWireDB_Proc_FlatWire_CheckInRod.sql` | The `@station = @machineName` guard (`52005`), the `C1` index notes, and the verified idle sentinel |
| `30-database/scripts/60_FlatWireDB_Proc_FlatWire_ReleaseStation.sql` | The idle test to mirror exactly |
| `FW-221` | The release side, already owned |

---

## 4. What was built, and the two departures from the card — 8 September 2026

**Delivered** (`ual-api` `feature/flat-wire`, `ual-angular` `feature/flat-wire`, `Flatwire-planning`):

| Where | What |
|---|---|
| `30-database/scripts/35_FlatWireDB_View_WIPStations.sql` | The view. Two columns, both trimmed, `SELECT`-only grant, guarded pre-flight, added to `FlatWire_Scripts_RunAll.sql` and dropped by `99_…Teardown.sql` |
| `FlatWire.Domain/Repository/IContextRepository.cs` | `GetWipStationAsync(station)` → `WipStationRead(Station, CoilNo)` |
| `FlatWire.Infrastructure/Repositories/ContextRepository.cs` | The Dapper `SELECT`, keyed on the trimmed name |
| `FlatWire.Domain/Models/Run/RunContracts.cs` | `ActiveRunResponse.StationClaim`, the `StationClaim` type, **`StationClaim.Resolve`**, and `ComponentStateItem.EdgeType` |
| `FlatWire.Infrastructure/Services/RunService.cs` | `FillStationClaimAsync`, beside `FillOrderBlockAsync`; `BuildComponents` now carries the edge type |
| `FlatWire.Infrastructure/Services/StubRunService.cs` | Loaded claim on the rod lines, idle on FL2, and an `EdgeSet` fixture row |
| `FlatWire.UnitTests/Domain/Models/StationClaimTests.cs` | **6 tests** on the idle rule — 299 pass in total |
| `ual-angular` `models/active-run-response.model.ts`, `active-run.model.ts`, `flat-wire-api.service.ts` | The claim mirrored, **preferred over the active payoff**, and the edge type appended to the component row. 210 tests, 100 % on all four metrics |
| [`[API §4.7a]`](../APIs.md) | The published `200` shape brought level — it was **four blocks behind** the built DTO, two of them since 29 Aug |

### ⚠ Departure 1 — the view is a **Dapper read**, not an EF `DbSet` with `.ToView()`

The implementation plan proposed `.ToView(...)` + `HasNoKey()`. **`ContextRepository`'s own header
settles it the other way:** *"aggregate roots go through the seven repositories, and everything else
comes here."* A station claim is not an aggregate root, `GetOrderContextAsync` is already documented
as the seam that *"becomes a single `SELECT` against that view"*, and a mapped `DbSet` is a write path
whether or not anyone means to use it — the same reason `P-13` gives for there being no
`DbSet<PassSchedule>`.

### ⚠ Departure 2 — the script is in `30-database/scripts/`, **not** in `FlatWire_DDL_08_Programmability.sql`

The plan named the numbered DDL. **`08`'s own header forbids it:** `sp_IngestRodFromCoils` is not
there *"because it reads `proddb..coils` and `united_db..alloys` and therefore cannot be verified by a
`FlatWireDB`-only deploy"* — and this view is the same case, only harder.

⛔ **`CREATE VIEW` does NOT defer name resolution.** The folder README's *"the five procedures have no
mutual dependency"* rests on `CREATE PROCEDURE` deferring; a view binds `CommonDB..WIPStations` at
creation time and fails with `Msg 208` where a procedure would create happily and fail later. So `35`
is the **only** file in that folder that cannot be created without its other database present — stated
in the README, in the runner and in the script's own header, with a pre-flight guard that reports and
skips so a `FlatWireDB`-only run stays green.

### ⛔ Two things the card asked for that were deliberately NOT built

- **`MachineIdx` is not projected at all.** The card only said *don't key on it*; leaving it out of the
  view means the mistake cannot be made through this object. It is unindexed **and** `FL1PO` shares
  FL1's value.
- **FM1's *"Gap · W"* is still one value.** `edgeType` closes the edger half of `FR-105`; the pass
  schedule carries a single `ParameterValue` per component, so the second numeric figure has **no
  source anywhere** — `Q3`'s territory, and faking it would put a number an operator trusts beside one
  nothing wrote.

### What is still open

- ⛔ **`G54`** — unchanged. Nothing writes `SpoolTraceability` and nothing registers an FL1 segment
  alpha in `proddb..coils`, so FL2's material still does not resolve. `FW-230` + `FW-231` ship together.
- ⚠ **`OI-115`** — no spool check-in procedure, so **FL2 reads the idle sentinel through a real run**.
  The read is correct; the writer does not exist. ⛔ Green tests here do not mean FL2 works.
- ✅ **DEPLOYED AND VERIFIED, 8 Sep 2026.** `FlatWire_Scripts_RunAll.sql` on `DEV00164-001` reported
  *Created view: FlatWireDB.dbo.WIPStations* and *Granted SELECT … to ua_user*, and the view reads
  **78 rows** through to `CommonDB` — with the idle sentinel visible live (`ACCES → ACCES`, the station
  name parked in `CoilNo`), which is exactly the rule `StationClaim.Resolve` implements.
  ⛔ **But 0 of the 78 are FL1/FL2/FL3/FL1PO**, because the WIP-station seed `10_` was withdrawn on
  6 Sep and is owed by **`FW-241`**. So the claim finds **no row at all**, which resolves as idle. The
  read is correct; the rows do not exist yet — a second reason FL2 reads idle, on top of `OI-115`.
  ⚠ **The earlier note here said `RunAll` aborts at script `06`; that is FIXED** — the full chain ran
  clean on 8 Sep, with `V1`–`V3`/`V5` passing as written.
