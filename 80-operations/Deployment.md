# Flat Wire Mill — Deployment

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 3, 2026 — **`V1`/`V2`/`V3` restated to 40 / 64 / 86** with `ToolingInventoryRollSet` (`D-42`), in both the SQL comments and the checklist beneath. ⚠ **This gate has rejected a correct deployment five times**; `[DBD §6.2]` remains the defining site and `verify_schema_counts.py` `C1` checks this file against it. *(previously August 30, 2026 — ⛔ **§4.2 step 2.1's `cd` named a folder deleted by the 29 Aug re-tree, and it is the step the rest depends on** — `FlatWire_DDL_RunAll.sql`'s `:r` includes are relative to the invocation directory. Retargeted to `30-database\sql`. **`V3`'s comment block also carried stale arithmetic** — *"The 64 in script 07 are 53 … plus 11"*, three lines above its own correct `-- Expected: 75` and invisible to every tool; **replaced with a pointer to `[DBD §6.8]` rather than the corrected split**, because a second copy of a figure in a permitted site is how this gate came to reject a correct deployment five times. **No expectation, checklist line or section number changed** *(previously August 29, 2026 — **A sixth deployment artifact for the first time — `FlatWireSimConsole` (`D-33`).** §1.1 component 6; **new §1.2a** (it is a *distribution* decision, not a deployment step — and ⚠ **nothing enforces the installation policy**, `G66`); §1.3's *Console version* row (**do not** couple it to a `flatwire-v*` tag); §2 records it has **no environment row and needs none**; **new §4.7 (Step 7)**, optional and non-blocking. ⚠ **Never deploy it against `production`** *(previously August 26, 2026 — **this header contradicted §4.2's own gate and is now level with it.** It published `34 / 57 / 69` for `V1`/`V2`/`V3` while the body asserted **33 / 55 / 70** — the figures the DDL actually produces, and the ones [`../tools/deliverables/verify_schema_counts.py`](../tools/deliverables/verify_schema_counts.py) checks this file against. `[DBD §6.2]` remains the defining site; a header restating a count is how the gate drifted from the body in the first place, so it now points rather than repeats *(previously August 23, 2026 — **§“Verification” corrected for the third time: as written it again rejected a correct deployment.** `V1`/`V2`/`V3` asserted **32 / 50 / 57** — the 32 predated the 22 Aug rod ↔ order pair and the 50/57 were never re-derived after `D-31`. Corrected then to 34 / 57 / 69, counted from the DDL, with `[DBD §6.2]` named as the defining site)* *(previously August 22, 2026 — `V1`/`V2`/`V3` asserted 25/33/41 in SQL comments and 27/41/46 in the checklist beneath, and `V4` required the MVP-2 `sp_ShiftSummary`)* *(previously August 18, 2026 — **`D-32`: there is no shared-schema migration.** **Deployment step 2 is cancelled** and §4.3 retained as the record; the 1→3→4→5 order no longer depends on the renames; `V7`/`V8`/`V9` dropped, `V10` kept *(previously August 13, 2026 — split out of `07-DeploymentRunbookAndRollback.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*)))*)*
**Document Type:** Release overview, environments, pre-deployment, sequence, smoke suite
**Status:** Baselined
**Owner:** Release manager / IT
**Audience:** IT / DevOps, DBA, release manager
**Shortcode:** `[DEP]`
**Part of:** `ProjectPlan/Operations/` — index: [README.md](../DOCUMENTS.md)

---

## 1. Release overview

### 1.1 What ships

| # | Component | Artifact | Deployed to |
|---|---|---|---|
| 1 | **`FlatWireDB` schema** | Ordered SQL scripts `00` → `08` (+ seed on non-production) | SQL Server |
| ~~2~~ | ~~**FW-001 shared-schema renames**~~ — **CANCELLED 18 Aug 2026, `D-32`. There is no shared-schema migration, so this component does not exist and step 2 is not deployed.** ⚠ **Step 4's `machines` rows (FL1/FL2/FL3, `FW-003`) and the `CommonDB` WIP-station registration are NOT cancelled** — they insert rows into existing tables and are still required | — | — |
| 3 | **`FlatWire.API`** | `dotnet publish` output | IIS application pool |
| 4 | **`OPCConnection` configuration** | `appsettings.{Environment}.json` tag-path map | IIS (existing service) |
| 5 | **`flat-wire`** | `ng build` static output, inside the shop-floor bundle | IIS static site |
| 6 | **`FlatWireSimConsole`** *(new — `D-33`, 29 Aug 2026)* | `dotnet publish` WinForms EXE + `appsettings.json` | ⚠ **Engineering workstations only — never a commissioned line.** See §1.2a |

### 1.2 Deployment order — and why

**1 → 3 → 4 → 5** *(step 2 cancelled — `D-32`, 18 Aug 2026)*. Database before API because the API's EF model and Dapper queries assume the tables exist. ~~The shared renames before the API because `FlatWire.API` writes `coils.coil_status`.~~ — **struck: `FlatWire.API` does not write `coils.coil_status`**, so that ordering constraint is gone with the migration. API before Angular because the Angular build is the last thing users see — if the API is not up, the UI shows an error rather than a blank screen, and rollback of a static bundle is the cheapest of the five.

**Component 6 is outside that chain by design.** It is a desktop tool, it has no other component depending on it, and it must never gate a release of 1–5. Deploy it whenever, after 3.

### 1.2a ⚠ Component 6 is a distribution decision, not a deployment step

`FlatWireSimConsole` drives a subsystem that, with simulation off, talks to a real mill. Three rules:

| Rule | Detail |
|---|---|
| **Where it goes** | Engineering and QA workstations, and the UAT room's second machine. **Not** the shop-floor panels, **not** the operator image, **not** a commissioned line |
| **What protects it if that is ignored** | The server. With `SimulateOpcFeed` false every `/sim` route is **404** (`[SEC §8.8b]`), and the console shows a lock-out panel rather than a live-looking surface (`[SIM §9.4]`) |
| **What is NOT enforced** | ⚠ **Nothing stops someone copying the EXE onto a production machine.** Installation policy is procedural — that residual is **`G66`**, and it is the one thing an unregistered Angular route gave for free |

**It has no environment promotion path**, because it is a client of whichever environment its `appsettings.json` points at. Promote by pointing it at the next environment, not by rebuilding it.

### 1.3 Version and tag

| Item | Value |
|---|---|
| Release tag | `flatwire-v<major>.<minor>.<patch>` on both `ual-api` and `ual-angular` |
| Schema version | The highest-numbered script applied, recorded in the deployment log |
| **Console version** | ⚠ **Tagged with `ual-api`, but released on its own cadence** (`D-33`) — that independence is the point of the decision, so **do not couple its version to a `flatwire-v*` tag** |
| Record before starting | The **currently deployed** tag for each component — you cannot roll back to a version you did not write down |

### 1.4 Release calendar

| Milestone | Date | Environment | Note |
|---|---|---|---|
| **Phase-1 platform gate** | **14 Aug 2026** | test1 | Schema created and seeded; stubbed service; scaffolded UI |
| Integration deployments | Continuous, W2–W7 | test1 / dev1 | Per-sprint |
| **Staging for UAT** | by **28 Sep 2026** | staging | UAT runs 28–30 Sep |
| **PLC commissioning** | by **30 Sep 2026** | the physical line | Until then every line runs `SimulatePLCTagPush` |
| **On-line trial** | early **Oct 2026** (TBD) | production, restricted | After sign-off |
| **Production go-live** | **Q4 2026** (TBD) | production | After trial acceptance |

> **`[SP §1]` records that the plan does not fit the window.** This runbook is dated against the plan as published; if the programme takes option B (move the date), the calendar above shifts with it but **the procedure does not change**.

---

---

## 2. Environments

| Environment | Host | Database server | App pool | Static site | Use |
|---|---|---|---|---|---|
| **test1** | `devual-uadev001` | `DEV00164-001` *(verified 26 Aug 2026)* | `FlatWireAPI_Test1` | shop-floor bundle | Developer testing |
| **test2** | `devual-uadev002` | *fill* | `FlatWireAPI_Test2` | shop-floor bundle | Developer testing |
| **dev1 / dev2** | — | *fill* | `FlatWireAPI_Dev1/2` | shop-floor bundle | Integration testing |
| **staging** | `uanet-staging` *(UAT may run on `devual-uadev001` if staging is unavailable)* | *fill* | `FlatWireAPI_Staging` | shop-floor bundle | Pre-production, UAT |
| **production** | `uanet05` | *fill* | `FlatWireAPI_Prod` | shop-floor bundle | Live |

**Promotion path:** `test1/test2` → `dev1/dev2` → `staging` → `production`. **No environment is skipped.** ~~The FW-001 renames must be exercised in at least one non-production environment that carries a realistic copy of the shared schema before they touch production.~~ — **struck 18 Aug 2026, `D-32`: nothing in this release alters the shared schema.**

⚠ **`FlatWireSimConsole` (component 6) has no row above and needs none.** It is a desktop client, not a hosted component: it has no host, no app pool and no static site, and it reaches an environment by **configuration** rather than by promotion. It is installed on engineering workstations and points at whichever environment its `appsettings.json` names — see §1.2a. **It is never installed against `production`.**

### 2.1 Configuration per environment

Configuration lives in `appsettings.{Environment}.json` plus environment variables, following the existing UAL convention:

| Setting | Source | Notes |
|---|---|---|
| `FlatWireDB` connection string | `UA_Connection_String_Variable` → the named variable | Same indirection pattern as the other services |
| JWT settings | `UA_JWT_Environment_Variable`, `UA_JWT_Token_Expiration_Minutes` | Inherited from `Login` |
| **OPC tag-path map** | `appsettings.{Environment}.json` | **Config-driven, never hardcoded** — so a wrong path found at commissioning is a config edit, not a redeploy |
| SignalR settings | `appsettings.{Environment}.json` | MessagePack on/off, keep-alive, client timeout, broadcast cadence |
| `SimulatePLCTagPush` | `appsettings.{Environment}.json` | **`true` everywhere until PLC commissioning completes** |
| `useMockData` (Angular) | `environment.*.ts` | **`true` only in `environment.development.ts`** |

> **Check `useMockData` before every non-development build.** Shipping a bundle with mock data enabled looks like a working system that is reading nothing.

---

---

## 3. Pre-deployment checklist

**Do not begin until every box is ticked.** Record who ticked each and when.

### 3.1 Approvals and gates

- [ ] Change request raised and approved by the release manager.
- [ ] **`[TS §4.2]` gate for this release is green** — QA0/QA1/QA2/QA3/QA4/QA5 as applicable.
- [ ] **Zero open S1 defects.** No more than three open S2, each with an agreed workaround.
- [ ] For production: **UAT signed off** (`FW-123`) and **PLC commissioning green** (`[COM §8]`).

### 3.2 Backups

- [ ] ~~**Full backup of every shared database the FW-001 renames touch** — taken tonight, restore-tested, location recorded. **This is the only real safety net for step 4.3.**~~ — **struck 18 Aug 2026, `D-32`: step 4.3 is cancelled.** ⚠ **Back up the shared databases anyway** if the release runs the `machines` / WIP-station row inserts — those are still row writes into shared tables, and a cheap backup is not the thing to economise on.
- [ ] Full backup of `FlatWireDB` (if it already exists and holds data).
- [ ] Current `FlatWire.API` publish folder copied to `\\<release-share>\flatwire\api\<previous-tag>\`.
- [ ] Current Angular static output copied to `\\<release-share>\flatwire\web\<previous-tag>\`.
- [ ] Current `appsettings.{Environment}.json` for **both** `FlatWire.API` and `OPCConnection` copied and version-stamped.

### 3.3 Line state — production and trial only

- [ ] **No active run on FL1.** `FlatWireRun.Status` is not `Running` or `Paused` for FL1.
- [ ] **No active run on FL2.**
- [ ] **No active run on FL3.**
- [ ] **No rod is staged awaiting check-in** — a `Staged` `RodStaging` row means an operator is mid-workflow.
- [ ] **No open pending Mode B disposition** awaiting a supervisor.
- [ ] **No open spool-completion prompt.**

```sql
-- Run against FlatWireDB. All four must return zero rows.
SELECT RunId, LineId, Status FROM dbo.FlatWireRun  WHERE Status IN ('Running','Paused');
SELECT Id, LineId, PayoffPosition, RodAlpha FROM dbo.RodStaging WHERE Status = 'Staged';
SELECT CheckoutId, RodAlpha FROM dbo.RodCheckout
  WHERE Mode = 'ModeB' AND InProcessMaterialDisposition = 'HoldPendingSupervisor'
    AND PartialSpoolAlpha IS NULL;
SELECT RunId, PausedAt FROM dbo.RunPauseEvent WHERE ResumedAt IS NULL;
```

### 3.4 Notification

- [ ] Operators on all three lines notified of the window, in person or by shift handover — **not only by email**.
- [ ] Supervisor on shift knows the system will be unavailable and for how long.
- [ ] Packing station notified.
- [ ] Maintenance notified if the release touches Die Management.

### 3.5 Maintenance window

- [ ] Window agreed and booked. **Allow for the rollback, not just the deployment** — budget the same duration again.
- [ ] The window does **not** overlap a shift changeover.

### 3.6 Rollback rehearsal

- [ ] **The rollback in §6 has been rehearsed in a non-production environment for this release**, and the elapsed time is recorded.
- [ ] ~~The **reverse script for the FW-001 renames exists and has been executed successfully** in that rehearsal.~~ — **struck 18 Aug 2026, `D-32`: there are no renames and therefore no reverse script.**
- [ ] The decision-maker for a rollback call is named and reachable — §6.1.

> **A rollback that has never been run is not a rollback plan.** For the first production deployment this is not optional.

---

---

## 4. Deployment sequence

### 4.1 Step 1 — Prepare

| # | Action | Command | Verification |
|---|---|---|---|
| 1.1 | Record the currently deployed tags | — | Both tags written into the deployment log |
| 1.2 | Confirm the release artifacts are present and match the tag | — | Checksums match the build output |
| 1.3 | Put the shop-floor site into maintenance (production only) | Per the standard IIS maintenance-page procedure | Browsing the site shows the maintenance page |

### 4.2 Step 2 — Database: `FlatWireDB`

**SQLCMD mode is required.** `FlatWire_DDL_RunAll.sql` uses `:r` includes and `:on error exit`, and **the include paths are relative to the invocation directory** — so you must `cd` to the SQL folder first.

```powershell
# 2.1 — go to the script folder. The :r includes are relative; running from anywhere else fails.
cd "c:\UAL\Flatwire-planning\30-database\sql"

# 2.2 — full build, in order. Idempotent and safe to re-run against an existing FlatWireDB.
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql
```

**Execution order, which `RunAll` enforces:**

`00` database → `01` Lookup → `02` Schedule → `03` Materials → `04` Runs → `05` Quality/Output →
**`06` all foreign keys** → **`07` all indexes** → `08` programmability. A contiguous `00`–`08`, so
*"of 09"* in the script headers is accurate. `06b` and `07b` were folded into `06` and `07` on
23 Aug 2026; `09_Programmability_MVP2` (`sp_ShiftSummary`) is **MVP-2 and not in this chain**, and
`99_Teardown` is in neither runner by design.

#### The full cross-folder sequence — this is its only home

`FlatWire_DDL_RunAll.sql` is **one step of ten**. The `Database/Scripts/` half is not optional: the
check-in procedure claims a WIP station, and it has nothing to claim until step 2 has run.

| # | Step | Artifact |
|---|---|---|
| **0** | **Pre-flight: prove co-location and isolation.** `FlatWireDB` must sit on the **same instance** as `united_db` / `proddb` / `SlitterDB` / `CommonDB` / `wiplogdb` — the check-in model spans them in **one** `SqlTransaction` under the **local** transaction manager, with no MSDTC (`[INT §8.0]`, `[ARC §10]`). LocalDB has no `united_db`, so a build validated only there silently loses that atomicity | the verification query in `../30-database/scripts/20_FlatWire_Grants.sql` |
| **1** | **The schema.** 40 tables. **Not empty** -- 01_Lookup seeds the three reason-code tables inline, as production reference data. Idempotent | `../30-database/sql/FlatWire_DDL_RunAll.sql` |
| **2** | ⚠ **SIGN-OFF GATE — shared-schema rows.** Writes `united_db..machines` and `CommonDB..WIPStations` / `MachineStationsConfiguration`. Still **Draft** (`machine_type`, the station set and `StationType` pending sign-off) and **there is no reverse script**. Run it **by hand**, after approval — the `Scripts/` runner deliberately skips it | `../30-database/scripts/10_CommonDB_Insert_WIPStations_FlatWire.sql` |
| **3** | **Grants.** Creates `ua_user` in six databases. Run **once per environment** | `../30-database/scripts/20_FlatWire_Grants.sql` |
| **4** | **Inbound procedure.** Lives in `FlatWireDB` but ships with the cross-database scripts, because it reads `proddb..coils` and `united_db..alloys` | `../30-database/scripts/30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql` |
| **5–8** | **The four `united_db` procedures — any order among themselves.** `CREATE PROCEDURE` uses **deferred name resolution**, so they have no compile-time dependency on one another. The numbering groups them; it does not impose an order. ⚠ `70_ReverseReqsum` contains a `proddb..wip_coil_orders` **DELETE** that is **not signed off for a shared environment** (`Q40`) — creating it is safe, calling it is not | `Scripts/40_…CheckInRod`, `50_…CompleteCoilOnSkid`, `60_…ReleaseStation`, `70_…ReverseReqsum` |
| **9** | **The verification gate** — `V1`–`V6` below, then `V10`–`V12` | this section |
| **10** | **DEV / TRIAL ONLY — seed data.** Never against production | `../30-database/sql/FlatWire_SampleData_RunAll.sql` |

Steps 3–8 can be run together with `../30-database/scripts/FlatWire_Scripts_RunAll.sql`, **which excludes step 2
on purpose.** See [`Database/Scripts/README.md`](../30-database/scripts/README.md) for each script's
sign-off state and whether it is reversible.

**Teardown reverses, code before data:** `../30-database/scripts/99_FlatWireDB_Proc_FlatWire_Teardown.sql` (drops
the four `united_db` procedures — **code, not data**), then
`../30-database/sql/FlatWire_DDL_99_Teardown.sql` (drops `FlatWireDB`, and `sp_IngestRodFromCoils` goes
with it). ⚠ **Neither undoes step 2's shared rows.** Nothing does — remove them deliberately and by
hand.

**Every script guards its objects** (`IF NOT EXISTS` / `IF EXISTS…DROP…CREATE`), so the whole build is **idempotent**. FKs are deliberately in a single script **after** all tables exist, so the table scripts have no cross-group ordering concerns.

To run one script on its own:

```powershell
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_04_Runs.sql
```

**In SSMS:** enable **Query → SQLCMD Mode** before executing `RunAll`.

**Seed data — non-production only.** Seed order is strict, because the schedule seed depends on the lookup IDENTITY values:

```powershell
# Lookup → Schedule → Materials → Runs → Quality/Output
sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_Lookup.sql
sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_Schedule.sql
sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_Materials.sql
sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_Runs.sql
sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_QualityOutput.sql
```

> **Do not seed production.** The seed is a coherent demo dataset with real-looking alphas; in production it is contamination.

**Verification — all six must pass before continuing:**

```sql
USE FlatWireDB;

-- V1. Table count must be 40 -- this is the complete MVP-1 database.
--     40, not 39, since 3 Sep 2026: the client's answer that the Tooling
--     Inventory tab carries a FOURTH tool type (mill rolls and DB1/DB2
--     capstan rolls) added ToolingInventoryRollSet in 01_Lookup.
--     If this returns 39, the pre-roll-set script set ran.
--     It was 39, not 35, since 2 Sep 2026 (later the same day): the client's
--     reason-code lists added DowntimeReason, WipRejectionReason and
--     ItInhibitReason in 01_Lookup, and LineDowntimeEvent in 04_Runs.
--     If this returns 35, the pre-reason-code script set ran.
--     It was 35, not 33, earlier on 2 Sep 2026: the DIE SPLIT added
--     ToolingInventoryDie (the register of physical dies, in 01_Lookup)
--     and DieHistory (its append-only life log, in 04_Runs), and reduced
--     Drawer to the two draw boxes DB1/DB2. If this returns 33, the
--     pre-split script set ran. It was 33, not 34, from 23 Aug 2026:
--     SpoolConfiguration was MERGED into Spool (Q60).
--     Defining site: [DBD 6.2]. This is one of exactly three places permitted
--     to restate the figures; if it disagrees with [DBD 6.2], [DBD 6.2] wins.
SELECT COUNT(*) AS TableCount FROM sys.tables WHERE is_ms_shipped = 0;
-- Expected: 40

-- V2. Foreign-key count must be 64. Was 62 until 3 Sep 2026: the roll-set
--     register added FK_ToolingInventoryRollSet_Stand and
--     FK_ToolingInventoryRollSet_Drawer -- the latter the FIRST foreign key
--     ever taken on Drawer  (+2). Was 58 until 2 Sep 2026 (later the same
--     day): the client's reason-code lists added FK_RunPauseEvent_DelayCode,
--     FK_LineDowntimeEvent_DelayCode, FK_LineDowntimeEvent_Run and
--     FK_WipRejection_Reason  (+4). Was 55 until earlier on 2 Sep: the die split
--     dropped FK_PSC_Drawer with PassScheduleComponent.DrawerId and added
--     FK_DieChangeEvent_OldDie, FK_DieChangeEvent_NewDie, FK_DieHistory_Die
--     and FK_DieHistory_Run  (-1 +4). Was 57 until 23 Aug 2026: the
--     SpoolConfiguration merge dropped FK_SpoolProcessing_SpoolConfiguration
--     and FK_Spool_SpoolConfiguration with the SpoolTypeId columns they
--     constrained. All 64 are now in script 06 (06b was folded into it).
SELECT COUNT(*) AS FkCount FROM sys.foreign_keys;
-- Expected: 64

-- V3. Index count -- 86 created by script 07 (07b was folded into it).
--     WAS 82 until 3 Sep 2026: the roll-set register added four --
--     IX_ToolingInventoryRollSet_StandId and _DrawerId (both filtered,
--     because CK_TIRS_Mount makes one of the pair NULL on every row),
--     IX_ToolingInventoryRollSet_LifecycleStatus and the filtered-unique
--     UX_ToolingInventoryRollSet_SerialNo  (+4).
--     WAS 75 until 2 Sep 2026 (later the same day): the client's reason-code
--     lists added seven -- IX_DowntimeReason_Bucket,
--     IX_WipRejectionReason_Group, IX_RunPauseEvent_ReasonCode,
--     IX_WipRejection_RejectionReason, IX_LineDowntimeEvent_DelayCode,
--     IX_LineDowntimeEvent_RunId and IX_LineDowntimeEvent_LineOpen  (+7).
--     WAS 70 until earlier on 2 Sep 2026: the die split dropped IX_PSC_DrawerId with
--     its column and added six -- IX_DieChangeEvent_OldDieId,
--     IX_DieChangeEvent_NewDieId, IX_DieHistory_DieId, IX_DieHistory_RunId,
--     IX_ToolingInventoryDie_LifecycleStatus and the filtered-unique
--     UX_ToolingInventoryDie_SerialNo  (-1 +6).
--     WAS 69 until 26 Aug 2026: Q89 added UX_CoilTraceability_ChildAlpha, a
--     FILTERED unique index on the per-source-rod shared identity. It is
--     filtered because the identity does not exist until the cross-database
--     mint returns, so the column is NULL until then.
--     UNCHANGED by the 23 Aug merge: nothing was ever indexed on SpoolTypeId.
--     [DBD 6.8] owns the nonclustered/unique split behind this figure -- it is
--     not restated here, because a second copy is what let this gate drift.
--     See [DBD 6.8] PP-01 for why a deployed database reports more indexes
--     than the scripts create.
--     NOTE: PRIMARY KEY and UNIQUE CONSTRAINT backing indexes are excluded below,
--     which is what makes this match the script count.
SELECT COUNT(*) AS IdxCount FROM sys.indexes
 WHERE object_id IN (SELECT object_id FROM sys.tables)
   AND type <> 0 AND is_primary_key = 0 AND is_unique_constraint = 0;
-- Expected: 86

-- V4. Programmability. SEVEN objects, and since change [H] (26 Aug 2026) ALL SEVEN
--     are in FlatWireDB -- so this is a SINGLE-DATABASE query where it used to span two.
--     TWO come from FlatWire_DDL_RunAll.sql (the trigger and sp_GetGaugeTrace).
--     FIVE ship in Database/Scripts/ and are present only AFTER the grants sequence:
--       sp_IngestRodFromCoils            (30_) -- reads proddb + united_db
--       FlatWire_CheckInRod              (40_) -- MOVED from united_db by [H]
--       FlatWire_CompleteCoilOnSkid      (50_) -- MOVED from united_db by [H]
--       FlatWire_ReleaseStation          (60_) -- MOVED from united_db by [H]
--       FlatWire_ReverseReqsum           (70_) -- MOVED from united_db by [H]
--     ⚠ The four MOVED procedures still READ AND WRITE united_db, proddb, CommonDB,
--       SlitterDB and wiplogdb exactly as before. Only the procedure home moved, and
--       the transaction model is UNCHANGED -- one instance, one local transaction
--       manager, no MSDTC. Do not read this simplification as a scope change.
--     sp_ShiftSummary is MVP-2 (09_, for DB10) and must NOT be here on an MVP-1
--     deploy -- asking for it is what failed a correct deployment before.
SELECT name, type_desc FROM sys.objects
 WHERE name IN ('trg_CoilTraceability_NoOverlap','sp_GetGaugeTrace','sp_IngestRodFromCoils'
              , 'FlatWire_CheckInRod','FlatWire_CompleteCoilOnSkid'
              , 'FlatWire_ReleaseStation','FlatWire_ReverseReqsum');
-- Expected: 2 rows after RunAll; 7 once Database/Scripts/ has been applied

-- V5. Business invariant — at most one Active PassSchedule per line + alloy.
SELECT LineId, Alloy, COUNT(*) FROM dbo.PassSchedule
 WHERE Status = 'Active' GROUP BY LineId, Alloy HAVING COUNT(*) > 1;
-- Expected: zero rows

-- V6. Business invariant — CoilTraceability ranges do not overlap within a coil.
SELECT a.CoilAlpha FROM dbo.CoilTraceability a
 JOIN dbo.CoilTraceability b
   ON a.CoilAlpha = b.CoilAlpha AND a.Id <> b.Id
  AND a.FootageFrom < b.FootageTo AND b.FootageFrom < a.FootageTo;
-- Expected: zero rows
```

- [ ] V1 returns **40**
- [ ] V2 returns **64**
- [ ] V3 returns **86**
- [ ] V4 returns **2 rows** after `RunAll` (**7** once `Database/Scripts/` is applied — was 3 before `[H]`)
- [ ] V5 returns **zero rows**
- [ ] V6 returns **zero rows**
- [ ] `ua_user` exists with `db_datareader`, `db_datawriter` and `GRANT EXECUTE ON SCHEMA::dbo`
- [ ] On a seeded environment, the fixture alphas resolve: `R00041`–`R00043`, `SP-00031`–`SP-00033`, `PS-1100-FL1-003`, `RUN-0001`–`RUN-0005` *(corrected 26 Aug 2026: the checklist had named `SP-00021`, `RUN-0042` and `RUN-0043`, which the seeds have never created)*

> **If V1 returns anything other than 40**, the wrong script set ran or a script failed silently. **Stop.**
>
> ⚠ **`V3` moved to 70 on 26 Aug 2026 — the FIFTH correction to this gate, and the first caused by
> a change made in this repository rather than by a stale figure.** `Q89` added
> `UX_CoilTraceability_ChildAlpha`. **The gate was left asserting 69 for the length of that edit, which
> would have rejected a correct deployment** — the same failure mode as the four before it. ⚠ **The
> guard that exists to catch exactly this, `../tools/deliverables/verify_schema_counts.py`, did not cover this file** —
> its `C1` reads `[DBD §6.2]` and never looked here, even though its own docstring cites this gate
> failing three times. **`C1` now checks `V1`/`V2`/`V3` too**, so a sixth is a build failure rather than
> a deploy-day surprise.
>
> ⚠ **`V4` moved to 7 on 26 Aug 2026** — change `[H]` moved the four `FlatWire_*` procedures from
> `united_db` into `FlatWireDB`, so all seven programmability objects are now in one database.
>
> ⚠ **`V1`/`V2` moved to 33 / 55 on 23 Aug 2026 — the fourth correction to this gate.** `SpoolConfiguration` was merged into `Spool` (`Q60`), removing one table and two foreign keys; `V3` is unchanged at 69 because nothing was indexed on `SpoolTypeId`. **A deployment of the current scripts returns 33 / 55 / 69, and the previous 34 / 57 / 69 would now reject it** — which is the exact failure mode this block has had three times before.
>
> ⚠ **This check asserted 27 until 13 Aug 2026 and explicitly told the deployer to stop on 25 — so as written it rejected a correct deployment.** The counts were fixed by counting the scripts directly, comments excluded: `CREATE TABLE` ×25, `FOREIGN KEY` ×33 in script 06, and 39 non-clustered + 2 filtered-unique in script 07. **34 tables and 57 FKs are the design and the MVP-1 build both** — `D-31` (15 Aug 2026) brought the three `PassSchedule*` tables and their ten FKs into MVP-1, the 20 Aug 2026 spool work added four tables and seven FKs (`Spool`, `SpoolTraceability`, `SpoolOrder`, `SpoolStaging`), and the 22 Aug 2026 rod ↔ order work added two more (`RodOrderAllocation`, `RodOrderConsumption`) — 28 → 32 → 34. ⚠ **This block was itself wrong again until 22 Aug 2026, and in three ways at once**: the SQL comments asserted 25/33/41, the checklist beneath asserted 27/41/46, and `V4` required `sp_ShiftSummary`, which is MVP-2 and is absent from a correct MVP-1 deploy. ⚠ **And wrong a third time until this pass, asserting 32 / 50 / 57** — the 32 predated the 22 Aug rod ↔ order pair and the 50/57 were never re-derived after `D-31`. Now **34 / 57 / 69**, counted from the DDL. Counts of 20, 21, 22, 24, 25, 27, 28 and 32 tables, 33 / 40 / 41 / 43 / 50 FKs and 41 / 44 / 46 / 57 indexes all circulate in older documents and are superseded — `[DBD §6.2]` is the defining site.

### 4.3 Step 3 — The FW-001 shared-schema renames — **CANCELLED**

> ### ⚠ CANCELLED 18 Aug 2026 — decision `D-32`. **Do not run anything in this section.**
>
> There is no shared-schema migration. The existing `coils` / scheduling schema is **read and written as it stands and is never altered**, so this step is removed from the deployment and from the pre-flight checklist. The section is retained because the rename table and the verification queries are quoted elsewhere, and a deployer who meets them needs one place that says they are dead. **`V7`, `V8` and `V9` below are cancelled with it; `V10` (the FL1/FL2/FL3 `machines` rows) stands** — those are rows in an existing table, not a schema change.
>
> ### ⚠ The original warning, retained: read this whole section before running anything in it.
>
> These renames land on the **shared** `coils`/scheduling schema, which is read by upstream receiving, planning, scheduling, reporting, yield and cost — **and by the legacy `ual-dot-net` tier**. This is the **single highest-blast-radius change in the project** and **the hardest element of this release to roll back** (§6.3).
>
> **They are deployed as a separate, explicitly approved step.** Never bundle them silently into the `FlatWireDB` build.

**The renames:**

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

Plus: **new columns** `OutgoingCoil/BundleWidth`, `IncomingWireDia` · **new status value** `INFLAT` · **new machine rows** FL1/FL2/FL3 · **new operation letter** `F` in `PrevOpLetter`, `RemainingOps`, `RootRemainingOps`, `OpLetter`.

#### 3a — Pre-flight impact check *(must already be complete from Phase 1C — this re-verifies it)*

```sql
-- Every stored procedure, view, function and trigger referencing a renamed column.
-- Run in EACH shared database, once per column name.
SELECT DISTINCT o.name AS ObjectName, o.type_desc, DB_NAME() AS DatabaseName
  FROM sys.sql_modules m
  JOIN sys.objects o ON o.object_id = m.object_id
 WHERE m.definition LIKE '%CoilNo%'
    OR m.definition LIKE '%SlitWidth%'
    OR m.definition LIKE '%IsCampaingCoil%'
    OR m.definition LIKE '%CoilLocation%'
    OR m.definition LIKE '%CoilWeight%'
    OR m.definition LIKE '%CoilStatus%'
    OR m.definition LIKE '%OutgoingCoilId%'
    OR m.definition LIKE '%OutgoingCoilOd%'
 ORDER BY o.type_desc, o.name;
```

- [ ] The result set **matches the Phase-1C impact audit**. Any object present here and absent from the audit is a **stop condition**.
- [ ] The legacy `ual-dot-net` tier has been searched separately — **it does not appear in `sys.sql_modules`**, so a database query alone will miss it.
- [ ] Reports and Excel/Crystal templates referencing these columns have been listed.

#### 3b — Apply

```powershell
sqlcmd -S "<server>" -E -C -i FW001_SharedSchema_Renames.sql
```

#### 3c — Verify

```sql
-- V7. New column names present; old names gone.
SELECT c.name, t.name AS TableName
  FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id
 WHERE c.name IN ('Coil/BundleNo','Slit/FlatWidth','IsCampaignCoil/Bundle',
                  'Coil/BundleLocation','Coil/BundleWeight','Coil/BundleStatus',
                  'OutgoingCoil/BundleId','OutgoingCoil/BundleOd',
                  'OutgoingCoil/BundleWidth','IncomingWireDia');

-- V8. No dependent object is now invalid.
SELECT OBJECT_NAME(referencing_id) AS Referencing, referenced_entity_name
  FROM sys.sql_expression_dependencies
 WHERE referenced_id IS NULL;
-- Expected: zero rows

-- V9. CANCELLED (D-32) - INFLAT is never added to the shared status vocabulary.
--     It is a FlatWireDB-local value on Rod.Status / SpoolProcessing.Status only.
-- V10. FL1/FL2/FL3 exist at machine_idx 125/126/127 with status = 1.
SELECT machine_idx, machine_name, status FROM united_db.dbo.machines
 WHERE machine_idx IN (125,126,127);
```

- [ ] V7 returns all ten columns
- [ ] **V8 returns zero rows** — no dependent object is broken
- [ ] Every object from the 3a list **recompiles cleanly** (`sp_refreshsqlmodule` where applicable)
- [ ] V10 returns three rows, all `status = 1` — **a machine with any other status is invisible to the `CommonDB.dbo.Machines` view**
- [ ] A smoke query from **at least one downstream report** returns rows

> **If V8 returns rows, stop and roll back this step immediately (§6.3).** A broken dependency here degrades other modules, not this one.

### 4.4 Step 4 — `FlatWire.API`

```powershell
# 4.1 — publish
dotnet publish "c:\UAL\ual-api\API\Domain\FlatWire\FlatWire.API\FlatWire.API.csproj" `
  -c Release -o "\\<release-share>\flatwire\api\<new-tag>"

# 4.2 — stop the app pool
Import-Module WebAdministration
Stop-WebAppPool -Name "FlatWireAPI_<Env>"

# 4.3 — deploy (copy the published output over the site folder)
Copy-Item "\\<release-share>\flatwire\api\<new-tag>\*" "<site-path>" -Recurse -Force

# 4.4 — configuration
#   Place appsettings.{Environment}.json.
#   Confirm the environment variables resolve.

# 4.5 — start the app pool
Start-WebAppPool -Name "FlatWireAPI_<Env>"
```

**Configuration checks — before starting the pool:**

- [ ] `appsettings.{Environment}.json` present and environment-correct.
- [ ] Connection-string indirection resolves to the right `FlatWireDB`.
- [ ] JWT settings resolve.
- [ ] **OPC tag-path map present** — config-driven, never hardcoded.
- [ ] **`SimulatePLCTagPush = true`** — until PLC commissioning completes, on **every** environment.
- [ ] SignalR settings present (MessagePack, keep-alive, client timeout, cadence).

**IIS prerequisite — check once per server, and re-check after any server rebuild:**

- [ ] **The IIS WebSockets feature is enabled.** The real-time design is WebSockets-first; without it the transport silently falls back to SSE or long-poll, and the 10 Hz batched telemetry will not perform. Gap **G10**.

```powershell
# Verify the WebSocket feature is installed
Get-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets |
  Select-Object FeatureName, State
# Expected State: Enabled
```

**Verification:**

```powershell
# V11 — health endpoint
Invoke-RestMethod -Uri "https://<host>/api/v1/flatwire/health" -Method Get
```

- [ ] V11 returns `status` healthy with **both `database.reachable` and `opc.reachable` true**
- [ ] The app pool is Started and stays started for 2 minutes (no crash loop)
- [ ] The Serilog log for today contains startup entries and **no errors**
- [ ] An authenticated `GET /api/v1/flatwire/lines/status` returns the envelope with three lines

### 4.5 Step 5 — OPC / PLC configuration

- [ ] The FL1/FL2/FL3 tag-path map in `appsettings.{Environment}.json` matches the map confirmed with Engineering.
- [ ] `OPCConnection` is running and subscribed to the FL1/FL2/FL3 tags.
- [ ] **Tag-push verification is performed on a line that is STOPPED.**

```
V12 — tag push, on a stopped line only
  1. Confirm the line is stopped:      FL{n}.LineState reads not-Running
  2. Perform one check-in acknowledgement on the test order
  3. Read back every pushed tag and compare against the pass schedule
  4. Confirm the audit log has one entry per tag with path, value, operator, timestamp, result
```

- [ ] Every pushed tag matches the schedule value.
- [ ] The audit log is complete.
- [ ] **On a pre-commissioning environment**, confirm `SimulatePLCTagPush` logged the intended writes and **made no live connection**.

> **Never verify a tag push on a running line.** The push configures the machine.

### 4.6 Step 6 — Angular `flat-wire`

```powershell
cd "c:\UAL\ual-angular"

# 6.1 — build for the target environment (example: dev1)
npm run build:dev1

# 6.2 — deploy static output to the IIS site
Copy-Item ".\dist\<bundle>\*" "<web-site-path>" -Recurse -Force
```

**Before building:**

- [ ] **`useMockData` is `false`** for every environment except local development.
- [ ] The API base URL points at the environment's `FlatWire.API`.
- [ ] The hub URL points at `/hubs/flatwire` on that host.

**After deploying:**

- [ ] Cache-busting hashes present on the emitted bundle filenames.
- [ ] The library is registered in the shop-floor shell and `/flat-wire` routes resolve.
- [ ] Take the site out of maintenance (production only).

**Verification:**

- [ ] The shop-floor shell loads and `/flat-wire/status` renders DB1.
- [ ] The browser network tab shows a **WebSocket** connection to `/hubs/flatwire` — **not** an SSE or long-poll fallback.
- [ ] The `--color-*` design tokens resolve (no unstyled flash, correct semantic colours).

### 4.7 Step 7 — `FlatWireSimConsole` *(component 6 — engineering workstations only)*

⚠ **This step is optional and non-blocking.** Nothing depends on the console; a release of components 1–5 is
complete without it. ⚠ **Do not run this step against `production`** — see §1.2a.

```powershell
cd "c:\UAL\Second-Branch\ual-api\Tools\FlatWireSimConsole"

# 7.1 - publish a self-contained folder for the target environment
dotnet publish -c Release -o "\\<share>\FlatWireSimConsole\<env>"

# 7.2 - point appsettings.json at that environment's FlatWire.API, then copy
#       the folder to the engineering workstation. There is no installer.
```

**Before deploying:**

- [ ] The target environment is **not** `production`, and the line it will drive is **not** commissioned.
- [ ] `appsettings.json` names the correct `FlatWire.API` base address and hub URL for that environment.
- [ ] The recipient holds an `Engineering/Maintenance` or `Admin` account. ⚠ **Until `FW-145` lands, no role
      claim is issued at all and every `/sim` call returns `401`/`403`** — that is expected, not a bad deploy.

**Verification:**

- [ ] Launching against an environment with simulation **off** shows the **lock-out panel** and nothing else,
      and `GET /API.FlatWire/sim/state` returns **404** (`[SIM §9.4]`).
- [ ] Launching against an environment with simulation **on** populates three line panels, and **FL2 shows
      *"No live gauge · see Profile"*** rather than a flat line at target.
- [ ] Setting `FlatWireSignalR:EnableMessagePack=false` and restarting the API leaves the console **unaffected**
      — it uses the JSON protocol deliberately (`[SIM §9.3]`).

---

---

## 5. Post-deployment verification — the smoke suite

Run in order. **Any failure is a rollback candidate** — apply the decision criteria in §6.1.

| # | TC | Check | Method | Pass |
|---|---|---|---|---|
| **S1** | `TC-700` | Health | `GET /api/v1/flatwire/health` | `database.reachable` and `opc.reachable` both true |
| **S2** | `TC-701` | Login | Log in at the FL1 station as a punched-in operator | Session created; operator ID, timestamp and station captured |
| **S3** | `TC-702` | Authorisation | Attempt `GET /passschedule` unauthenticated | `401` |
| **S4** | `TC-703` | Line Status board | Open `/flat-wire/status` | All three line cards render from `GET /lines/status` |
| **S5** | `TC-704` | **Hub connection** | Inspect the browser network tab | A **WebSocket** connection to `/hubs/flatwire`, not a fallback transport |
| **S6** | `TC-705` | **A live event on each line** | Join `FL1Data`, `FL2Data`, `FL3Data` in turn | FL1 and FL3 receive batched `GaugeReading`; **FL2 receives none — this is correct, not a fault** |
| **S7** | `TC-706` | Pass schedule reads | Open DB9A, then one schedule | List renders with counts; detail shows components with three-value state |
| **S8** | `TC-707` | **One check-in against a real Active pass schedule** | Complete the 6-step wizard on the test order and acknowledge | Run created `Running`; `RodCheckin`, pre-run SPC and inspection rows written; **`Rod.Status = 'INFLAT'` in `FlatWireDB`, and `coils.coil_status` UNCHANGED** *(`D-32`)*; **records written before the push** |
| **S9** | `TC-708` | **PLC tag push verified** | Read back the pushed tags (stopped line only) | Every tag matches the schedule; one audit entry per tag |
| **S10** | `TC-709` | Active run monitor | Open DB3 for the checked-in line | Traces render; machine status populates; the action bar shows the correct button set for the line |
| **S11** | `TC-710` | **Reconnect** | Kill and restore the transport | "Reconnecting…" over cached state, **never blank**; group re-joined automatically |
| **S12** | `TC-711` | Audit | Query the audit surfaces for the S8 check-in | Who, when and why present for the acknowledgement and every tag write |
| **S13** | `TC-712` | **One full run to coil completion** *(trial environment)* | Run the FL1 → FL2 route to a completed coil | Coil alpha issued; traceability covers 100 % of footage without overlap; label renders |
| **S14** | `TC-713` | Rollback readiness | Confirm the previous artifacts and the reverse script are still in place | All present at the recorded paths |
| **S15** | `TC-714` | Clean up | Reverse the S8 check-in and any S13 test material | No test data left in a production environment |

- [ ] All fifteen pass. Record the time and the operator who ran them.

---
