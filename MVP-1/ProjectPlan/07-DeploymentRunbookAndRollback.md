# Flat Wire Mill — Deployment Runbook & Rollback Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** July 30, 2026
**Document Type:** Deployment runbook + rollback plan
**Status:** Baselined — **rollback must be rehearsed before the first production deployment** (§3.6)
**Owner:** Release manager / IT
**Audience:** IT / DevOps, DBA, release manager, on-call engineer
**Sources:** [`../FlatWire_MasterSpecification.md`](../../LatestDocument/FlatWire_MasterSpecification.md) §5.11, §8.4 · `[HLD]` [03-HLD-and-ERDiagram.md](./03-HLD-and-ERDiagram.md) §11 · [`c:\UAL\CLAUDE.md`](../../../CLAUDE.md) UAL deployment conventions · [`../DBChanges/Schema/SQL/`](../DBChanges/Schema/SQL/)

**Companion documents:** `[VS]` [01-VisionAndScope.md](./01-VisionAndScope.md) · `[SRS]` [02-SRS.md](./02-SRS.md) · `[HLD]` [03-HLD-and-ERDiagram.md](./03-HLD-and-ERDiagram.md) · `[API]` [04-APIContract.md](./04-APIContract.md) · `[SP]` [05-SprintPlanAndBacklog.md](./05-SprintPlanAndBacklog.md) · `[TP]` [06-TestPlanAndTestCases.md](./06-TestPlanAndTestCases.md)

> **How to use this document.** Follow the numbered steps in order. **Every step has a verification** — do not proceed past a failed verification. It is written to be followed at 2 a.m. by someone who did not build the system.
>
> **Two things to know before you start:**
> 1. **The database goes first, and the FW-001 shared-schema renames are the hardest thing here to undo.** §4.3 and §6.3.
> 2. **`FlatWire_DDL_99_Teardown.sql` drops everything.** It is a test-environment tool. Never run it against an environment holding production data.

---

## 1. Release overview

### 1.1 What ships

| # | Component | Artifact | Deployed to |
|---|---|---|---|
| 1 | **`FlatWireDB` schema** | Ordered SQL scripts `00` → `08` (+ seed on non-production) | SQL Server |
| 2 | **FW-001 shared-schema renames** | A separate migration script against the **shared** `coils`/scheduling schema | SQL Server — **shared databases** |
| 3 | **`FlatWire.API`** | `dotnet publish` output | IIS application pool |
| 4 | **`OPCConnection` configuration** | `appsettings.{Environment}.json` tag-path map | IIS (existing service) |
| 5 | **`flat-wire-shopfloor`** | `ng build` static output, inside the shop-floor bundle | IIS static site |

### 1.2 Deployment order — and why

**1 → 2 → 3 → 4 → 5.** Database before API because the API's EF model and Dapper queries assume the tables exist. The shared renames before the API because `FlatWire.API` writes `coils.coil_status`. API before Angular because the Angular build is the last thing users see — if the API is not up, the UI shows an error rather than a blank screen, and rollback of a static bundle is the cheapest of the five.

### 1.3 Version and tag

| Item | Value |
|---|---|
| Release tag | `flatwire-v<major>.<minor>.<patch>` on both `ual-api` and `ual-angular` |
| Schema version | The highest-numbered script applied, recorded in the deployment log |
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

## 2. Environments

| Environment | Host | Database server | App pool | Static site | Use |
|---|---|---|---|---|---|
| **test1** | `devual-uadev001` | *fill at first deploy* | `FlatWireAPI_Test1` | shop-floor bundle | Developer testing |
| **test2** | `devual-uadev002` | *fill* | `FlatWireAPI_Test2` | shop-floor bundle | Developer testing |
| **dev1 / dev2** | — | *fill* | `FlatWireAPI_Dev1/2` | shop-floor bundle | Integration testing |
| **staging** | `uanet-staging` *(UAT may run on `devual-uadev001` if staging is unavailable)* | *fill* | `FlatWireAPI_Staging` | shop-floor bundle | Pre-production, UAT |
| **production** | `uanet05` | *fill* | `FlatWireAPI_Prod` | shop-floor bundle | Live |

**Promotion path:** `test1/test2` → `dev1/dev2` → `staging` → `production`. **No environment is skipped**, and the FW-001 renames must be exercised in at least one non-production environment that carries a realistic copy of the shared schema before they touch production.

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

## 3. Pre-deployment checklist

**Do not begin until every box is ticked.** Record who ticked each and when.

### 3.1 Approvals and gates

- [ ] Change request raised and approved by the release manager.
- [ ] **`[TP §4.2]` gate for this release is green** — QA0/QA1/QA2/QA3/QA4/QA5 as applicable.
- [ ] **Zero open S1 defects.** No more than three open S2, each with an agreed workaround.
- [ ] For production: **UAT signed off** (`FW-123`) and **PLC commissioning green** (`[TP §8]`).

### 3.2 Backups

- [ ] **Full backup of every shared database the FW-001 renames touch** — taken tonight, restore-tested, location recorded. **This is the only real safety net for step 4.3.**
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
- [ ] The **reverse script for the FW-001 renames exists and has been executed successfully** in that rehearsal.
- [ ] The decision-maker for a rollback call is named and reachable — §6.1.

> **A rollback that has never been run is not a rollback plan.** For the first production deployment this is not optional.

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
cd "c:\UAL\Flatwire-planning\LatestDocument\DBChanges\Schema\SQL"

# 2.2 — full build, in order. Idempotent and safe to re-run against an existing FlatWireDB.
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql
```

**Execution order, which `RunAll` enforces:**

`00` database → `01` Lookup → `02` Schedule → `03` Materials → `04` Runs → `05` Quality/Output → **`06` all foreign keys** → `07` indexes → `08` programmability.

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

-- V1. Table count must be 27.
SELECT COUNT(*) AS TableCount FROM sys.tables WHERE is_ms_shipped = 0;
-- Expected: 27

-- V2. Foreign-key count must be 41.
SELECT COUNT(*) AS FkCount FROM sys.foreign_keys;
-- Expected: 41

-- V3. Index count — 46 created by script 07 (43 non-clustered + 3 filtered UNIQUE).
SELECT COUNT(*) AS IdxCount FROM sys.indexes
 WHERE type_desc = 'NONCLUSTERED' AND is_primary_key = 0 AND is_unique_constraint = 0;
-- Expected: 46

-- V4. Programmability present.
SELECT name, type_desc FROM sys.objects
 WHERE name IN ('trg_CoilTraceability_NoOverlap','sp_GetGaugeTrace','sp_ShiftSummary');
-- Expected: 3 rows

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

- [ ] V1 returns **27**
- [ ] V2 returns **41**
- [ ] V3 returns **46**
- [ ] V4 returns **3 rows**
- [ ] V5 returns **zero rows**
- [ ] V6 returns **zero rows**
- [ ] `ua_user` exists with `db_datareader`, `db_datawriter` and `GRANT EXECUTE ON SCHEMA::dbo`
- [ ] On a seeded environment, the fixture alphas resolve: `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042`, `RUN-0043`

> **If V1 returns 22, 25 or any other number**, the wrong script set ran or a script failed silently. **Stop.** Several documents in the repository quote table counts of 20, 21, 22 and 25 — **all are superseded. The DDL is authoritative and it creates 27.**

### 4.3 Step 3 — The FW-001 shared-schema renames

> ### ⚠ Read this whole section before running anything in it.
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

-- V9. INFLAT is an accepted status value.
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

### 4.6 Step 6 — Angular `flat-wire-shopfloor`

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
| **S8** | `TC-707` | **One check-in against a real Active pass schedule** | Complete the 6-step wizard on the test order and acknowledge | Run created `Running`; `RodCheckin`, pre-run SPC and inspection rows written; `coils.coil_status = INFLAT`; **records written before the push** |
| **S9** | `TC-708` | **PLC tag push verified** | Read back the pushed tags (stopped line only) | Every tag matches the schedule; one audit entry per tag |
| **S10** | `TC-709` | Active run monitor | Open DB3 for the checked-in line | Traces render; machine status populates; the action bar shows the correct button set for the line |
| **S11** | `TC-710` | **Reconnect** | Kill and restore the transport | "Reconnecting…" over cached state, **never blank**; group re-joined automatically |
| **S12** | `TC-711` | Audit | Query the audit surfaces for the S8 check-in | Who, when and why present for the acknowledgement and every tag write |
| **S13** | `TC-712` | **One full run to coil completion** *(trial environment)* | Run the FL1 → FL2 route to a completed coil | Coil alpha issued; traceability covers 100 % of footage without overlap; label renders |
| **S14** | `TC-713` | Rollback readiness | Confirm the previous artifacts and the reverse script are still in place | All present at the recorded paths |
| **S15** | `TC-714` | Clean up | Reverse the S8 check-in and any S13 test material | No test data left in a production environment |

- [ ] All fifteen pass. Record the time and the operator who ran them.

---

## 6. Rollback plan

**This half of the document must be right.** Read §6.3 before you need it.

### 6.1 Decision criteria

| Trigger | Action |
|---|---|
| **A shared-schema dependency is broken (V8 returns rows)** | **Roll back step 3 immediately.** This degrades other modules, not just this one |
| Any smoke check S1–S6 fails and is not fixed within **15 minutes** | Roll back |
| S7–S13 fails and is not fixed within **30 minutes** | Roll back |
| A defect is found that would **mis-track material or produce a wrong certificate** | **Roll back immediately, at any point** |
| A defect is cosmetic or has an operator workaround | **Fix forward** — do not roll back |
| The maintenance window is **50 % consumed** with the deployment incomplete | Roll back and re-plan |

**Who decides:** the **release manager**, on the recommendation of the on-call engineer. **Maximum time to decide: 10 minutes** from the failure being confirmed. If the release manager is unreachable, the on-call engineer decides and the decision stands.

**Announce the decision before executing it** — operators must not discover the rollback by watching the screen change.

### 6.2 Per-component rollback, in reverse dependency order

Roll back **5 → 4 → 3 → 2 → 1** — the reverse of the deployment order.

#### 6.2.1 Angular (cheapest, do first)

```powershell
Copy-Item "\\<release-share>\flatwire\web\<previous-tag>\*" "<web-site-path>" -Recurse -Force
```

- [ ] Site loads the previous bundle. Hard-refresh once to defeat browser caching. **Nothing is lost** — the bundle is stateless.

#### 6.2.2 OPC / PLC configuration

```powershell
Copy-Item "<backup>\OPCConnection\appsettings.<Env>.json" "<opc-site-path>" -Force
Restart-WebAppPool -Name "OPCConnection_<Env>"
```

- [ ] Tag paths match the previous map. **Nothing is lost** — configuration only.

#### 6.2.3 `FlatWire.API`

```powershell
Stop-WebAppPool  -Name "FlatWireAPI_<Env>"
Copy-Item "\\<release-share>\flatwire\api\<previous-tag>\*" "<site-path>" -Recurse -Force
Copy-Item "<backup>\FlatWire.API\appsettings.<Env>.json" "<site-path>" -Force
Start-WebAppPool -Name "FlatWireAPI_<Env>"
```

- [ ] `/health` green on the previous version.
- [ ] **Loss assessment:** any transaction in flight at the moment the pool stopped. Because check-in is **not one ACID transaction**, an in-flight check-in may have written `FlatWireDB` rows, shared-schema rows, PLC tags, or any combination. **§6.4 reconciles this by hand.**

#### 6.2.4 Database — `FlatWireDB`

**Two paths. Choose by whether the database holds data you cannot lose.**

| Situation | Path |
|---|---|
| **`FlatWireDB` holds no production data** (pre-go-live, or a test environment) | **Teardown and rebuild.** `sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql` then re-run `RunAll` at the previous script set |
| **`FlatWireDB` holds production data** | **Restore from the §3.2 backup.** Never run the teardown |

> ### ⚠ `FlatWire_DDL_99_Teardown.sql` drops everything.
> It is a test-environment tool. **It is only safe when `FlatWireDB` carries no production data.** Once the mill has run one production coil, this script must never touch that environment again. Consider removing it from the production release package entirely.

- [ ] Verifications V1–V6 (§4.2) pass against the restored or rebuilt schema.
- [ ] **Loss assessment:** on a restore, everything written after the backup is lost — runs, check-ins, weld events, SPC checkpoints, coil outputs and traceability. **§6.4.**

#### 6.2.5 FW-001 shared-schema renames — **see §6.3**

### 6.3 Rolling back the FW-001 renames — the hard one

> **State this plainly: the shared-schema renames are the highest-risk and least-reversible element of this release.** Every other component is a file copy or a restore of a database this module owns. **This one changes a schema other modules depend on.**

#### 6.3.1 What makes it hard

1. **Other modules read these columns.** Upstream receiving, planning, scheduling, reporting, yield and cost, **plus the legacy `ual-dot-net` tier**, all reference them. A rename that has been live for any length of time may already have had dependent objects recompiled against the new names.
2. **The legacy tier is invisible to `sys.sql_modules`.** A database dependency query will not find it. Compiled applications and Crystal/Excel report templates must be checked separately.
3. **The new columns and the new status value may already carry data.** `INFLAT` rows, `OutgoingCoil/BundleWidth` values and `IncomingWireDia` values written since deployment have nowhere to go in the pre-rename schema.
4. **A restore of a shared database is not this module's call.** It affects every other module using that database.

#### 6.3.2 Procedure

| # | Action | Command / method | Verification |
|---|---|---|---|
| **R1** | **Stop `FlatWire.API` first** — it writes `coils.coil_status = INFLAT` | `Stop-WebAppPool -Name "FlatWireAPI_<Env>"` | Pool stopped |
| **R2** | Quantify what will be orphaned | `SELECT COUNT(*) FROM coils WHERE [Coil/BundleStatus] = 'INFLAT';` and count non-null `OutgoingCoil/BundleWidth` and `IncomingWireDia` | Counts recorded in the log **before** anything is reversed |
| **R3** | **Run the reverse script** | `sqlcmd -S "<server>" -E -C -i FW001_SharedSchema_Renames_REVERSE.sql` | Completes with no error |
| **R4** | **Dependent-object recompilation check** | `EXEC sp_refreshsqlmodule` for every object from the §4.3 3a list; then re-run V8 | **V8 returns zero rows.** Any invalid object is an escalation, not a retry |
| **R5** | Legacy-tier check | Smoke-test the legacy applications and reports identified in the impact audit | Each returns data |
| **R6** | Downstream smoke | Run one report from receiving, one from planning and one from scheduling | All three return rows |

#### 6.3.3 If R3 or R4 fails

> **If the reverse script fails, or R4 leaves any object invalid: stop and escalate immediately. Do not retry.**
>
> **All dependent modules are affected**, not just Flat Wire. The next step is a **restore of the shared database from the §3.2 backup**, which is a **cross-module decision** requiring the release manager, the DBA and the owners of receiving, planning, scheduling, reporting and cost. Every module using that database loses data written since the backup.
>
> **This is why the §3.6 rehearsal is not optional, and why the §3.2 backup must be restore-tested before the window opens.**

### 6.4 Data-loss assessment and manual reconciliation

| Rollback path | What is lost | Must be reconciled by hand |
|---|---|---|
| Angular bundle | Nothing | — |
| OPC configuration | Nothing | — |
| `FlatWire.API` | In-flight transactions at pool stop | **Any check-in mid-sequence**: `FlatWireDB` rows may exist without the shared-schema writes, or with tags pushed and no records, or the reverse |
| `FlatWireDB` **restore** | Everything written since the backup | Runs, check-ins, staging rows, weld events, SPC checkpoints, roll overrides, die changes, WIP rejections, coil outputs and **traceability rows** |
| `FlatWireDB` **teardown + rebuild** | **All data** | Only safe when there is none |
| FW-001 reverse | `INFLAT` status values, and any data in the two new columns | **Every rod currently `INFLAT`** — it is physically on a line and the system will no longer say so |

**The manual reconciliation list — walk it after any API or database rollback:**

| # | Check | Query / method | Action |
|---|---|---|---|
| **M1** | **In-flight runs** | `SELECT RunId, LineId, Status, FootageFt FROM FlatWireRun WHERE Status IN ('Running','Paused')` | For each, establish physically what is on the line and correct the record or close the run |
| **M2** | **Open MMS IDs** | `SELECT RunId, RodAlpha, MmsId FROM RodCheckin WHERE MmsStatus IN ('Open','Active')` | An MMS ID orphaned from its run blocks ITInhibit clearance — close or re-associate |
| **M3** | **Rods stuck `INFLAT`** | `SELECT alpha FROM coils WHERE [coil_status] = 'INFLAT'` (or the pre-rename column name) | Compare against physically loaded rods; correct the status of any that are not on a line |
| **M4** | **Staged rods** | `SELECT LineId, PayoffPosition, RodAlpha FROM RodStaging WHERE Status = 'Staged'` | Confirm each is physically on its bay; un-stage the rest |
| **M5** | **Unlabeled coils** | `SELECT CoilAlpha, Status, SkidId FROM CoilOutput WHERE SkidStatus IS NULL OR SkidStatus = 'Open'` | A physically produced coil with no record, or a record with no coil, must be resolved before shipping |
| **M6** | **Open skids** | `SELECT SkidId, COUNT(*) FROM CoilOutput WHERE SkidId IS NOT NULL GROUP BY SkidId HAVING COUNT(*) <> 2` | Every skid holds exactly two coils — reconcile any that does not |
| **M7** | **Pending Mode B dispositions** | `SELECT CheckoutId, RodAlpha FROM RodCheckout WHERE Mode='ModeB' AND PartialSpoolAlpha IS NULL` | Material is locked with no alpha; re-raise for supervisor decision |
| **M8** | **Orphaned traceability** | Coils whose traceability rows do not cover 100 % of footage | **A certificate cannot be issued for such a coil.** Quarantine it until reconstructed |

> **M8 is the one that reaches the customer.** Everything else is an internal correction; an incomplete genealogy chain means a coil that cannot be certified.

### 6.5 Verifying the rollback succeeded

- [ ] `/health` green on the previous version.
- [ ] The Line Status board renders with the previous bundle.
- [ ] Verifications V1–V6 pass against the restored schema.
- [ ] **V8 returns zero rows** — no shared-schema dependency is broken.
- [ ] One downstream report from another module returns rows.
- [ ] The M1–M8 reconciliation list has been walked and every item is closed or explicitly deferred with an owner.
- [ ] Operators confirm the screens behave as they did before the window.

### 6.6 Communication template

```
FLAT WIRE MILL — DEPLOYMENT ROLLED BACK

When:            <timestamp>
Environment:     <environment>
Rolled back to:  <previous tag>
Decided by:      <name, role>

What happened:
  <one or two sentences — what failed and at which step>

What this means for you:
  - The Flat Wire screens are back to the version you were using before <date>.
  - <state plainly whether any operator action is needed>

Data:
  - <what was lost, if anything, in plain terms>
  - <which runs / coils / rods need to be re-entered or corrected, by name>

What happens next:
  <root cause investigation; expected re-deployment window>

Questions:  <release manager name / contact>
```

Send to: all three line operators, the shift supervisor, packing, Maintenance, the Operations Manager, and the owners of any module affected by an FW-001 reversal.

---

## 7. Operational readiness

### 7.1 Monitoring and health

| What | Where | Alert on |
|---|---|---|
| `GET /health` | `FlatWire.API` | Not-healthy, or `opc.reachable` false, for more than 2 minutes |
| App-pool state | IIS | Stopped, or recycling more than twice in an hour |
| Hub connection count | `FlatWireHub` | Drops to zero while any line is `Running` |
| **Broadcast cadence** | Hub instrumentation | Sustained deviation from the configured interval |
| `RunReading` growth rate | SQL Server | Rate change beyond the expected band — **and note there is no retention policy yet (OI-17)** |
| Failed PLC tag writes | Audit log | **Any** failure — each one aborted a check-in |
| Deadlocks / long-running queries | SQL Server | Standard UAL thresholds |

### 7.2 Logging

| Item | Value |
|---|---|
| Framework | **Serilog**, structured, per the UAL convention |
| Location | `logs/app-<date>.txt` under the API site |
| Rolling | Daily, retaining 100 files |
| Enrichment | **Correlation ID on every line**, set by the shared `correlation-id-interceptor` |
| What is always logged | Every PLC tag write and clear (path, value, operator, timestamp, result) · every supervisor override · every pass-schedule change · every login/logout |
| What is **never** logged | **The supervisor PIN.** It authenticates only and is never stored, echoed or logged |

### 7.3 Runbook — the three most likely production incidents

#### 7.3.1 Hub disconnect storm

**Symptom:** many clients reconnecting simultaneously; screens showing "Reconnecting…"; hub connection count oscillating.

| # | Action |
|---|---|
| 1 | Check the app-pool state — a recycle disconnects every client at once |
| 2 | **Confirm the IIS WebSockets feature is still enabled.** A server rebuild silently reverts it, and the fallback transport does not carry the 10 Hz load |
| 3 | Check the shopfloor wireless for a coincident event |
| 4 | Check the broadcast cadence — a mis-set cadence can saturate the transport |
| 5 | **Do not restart the pool to "clear" it.** That causes exactly the storm you are investigating |
| 6 | Operators are not blocked: cached state renders behind the banner, and clients re-join automatically |

#### 7.3.2 OPC tag path wrong after commissioning

**Symptom:** a component shows no live value; a gauge trace is flat; `ITInhibit` will not clear; a tag push reports success but nothing changes on the machine.

| # | Action |
|---|---|
| 1 | Confirm `OPCConnection` is running and subscribed |
| 2 | Compare the configured path against the map confirmed with Engineering |
| 3 | **Correct it in `appsettings.{Environment}.json` and recycle the pool. No redeploy is required — this is exactly why the paths are configuration** |
| 4 | Verify by reading the tag back, **on a stopped line** |
| 5 | If `FL{n}.LineState` is involved, expect ambiguity: **its state vocabulary is undocumented (OI-35)**, and both the checkout gatekeeper and the spool prompt depend on it. Record what you observe — it closes the open item |

#### 7.3.3 `ITInhibit` stuck set

**Symptom:** the machine will not run; the operator reports being blocked with no obvious cause.

| # | Action |
|---|---|
| 1 | **Do not attempt to clear it manually. There is no operator path, and there must not be one.** It clears only when its condition resolves |
| 2 | Work the five conditions in order: (a) is a rod/coil checked in? (b) is there an **active** MMS ID? (c) is PLC feet data arriving? (d) is it valid? (e) have two or more consecutive recordings been missed? |
| 3 | (b) is the most common after a rollback — **M2 in §6.4 exists for exactly this** |
| 4 | (c) and (d) point at OPC, not at the application — go to §7.3.2 |
| 5 | (e) points at the recording cadence or a data-collection outage; the data-recording alert should also be showing |
| 6 | Once the condition resolves, confirm the tag clears **automatically** |

### 7.4 Support handover

The on-call engineer should have: this document · `[API §1.8]` (the error-code catalogue) · the current tag map · the deployment log with both tags recorded · and the §6.4 reconciliation queries.

---

## 8. Contacts and escalation

**Roles, not invented names.** The release manager fills this in before the window opens.

| Role | Name | Contact | Escalate for |
|---|---|---|---|
| Release manager | *TBD* | *TBD* | **The rollback decision** |
| On-call engineer | *TBD* | *TBD* | First response, all incidents |
| DBA | *TBD* | *TBD* | `FlatWireDB` restore; **any shared-database restore** |
| Backend lead (.NET) | *TBD* | *TBD* | API failures, PLC push failures |
| Frontend lead (Angular) | *TBD* | *TBD* | Bundle and rendering issues |
| Real-time / PLC engineer | *TBD* | *TBD* | Hub, OPC, tag paths, `LineState` |
| Engineering (tag map owner) | *TBD* | *TBD* | Tag-path corrections |
| Operations Manager | *TBD* | *TBD* | Pass-schedule content; production impact |
| Shift supervisor (on shift) | *TBD* | *TBD* | Operator notification; line state |
| Owners of affected modules | *TBD* | *TBD* | **Any FW-001 reversal** — receiving, planning, scheduling, reporting, yield, cost |

**Escalation path:** on-call engineer → component lead → release manager → programme management. **A shared-database restore requires the release manager, the DBA and every affected module owner** — it is never a single-person call.

---

## 9. Appendix

### 9.1 Command reference

```powershell
# --- Database -------------------------------------------------------------
cd "c:\UAL\Flatwire-planning\LatestDocument\DBChanges\Schema\SQL"   # required: :r paths are relative
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql       # full build + seed, idempotent
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_04_Runs.sql      # one script
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql  # DROPS EVERYTHING — test only

# --- API ------------------------------------------------------------------
dotnet publish "c:\UAL\ual-api\API\Domain\FlatWire\FlatWire.API\FlatWire.API.csproj" -c Release -o "<out>"
Import-Module WebAdministration
Stop-WebAppPool    -Name "FlatWireAPI_<Env>"
Start-WebAppPool   -Name "FlatWireAPI_<Env>"
Restart-WebAppPool -Name "FlatWireAPI_<Env>"
Invoke-RestMethod  -Uri "https://<host>/api/v1/flatwire/health" -Method Get

# --- Angular --------------------------------------------------------------
cd "c:\UAL\ual-angular"
npm run build:test1 ; npm run build:dev1 ; npm run build:prod

# --- IIS prerequisite -----------------------------------------------------
Get-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets | Select FeatureName, State
```

### 9.2 File inventory

| File | Role |
|---|---|
| `FlatWire_DDL_00_Database.sql` | Creates `FlatWireDB`, RCSI + snapshot isolation, `ua_user` and grants |
| `FlatWire_DDL_01_Lookup.sql` | 6 lookup tables **+ the three pinned `PayoffPosition` rows** |
| `FlatWire_DDL_02_Schedule.sql` | 3 schedule tables |
| `FlatWire_DDL_03_Materials.sql` | `Rod`, `FlatWireRun`, `Spool` |
| `FlatWire_DDL_04_Runs.sql` | 9 run tables |
| `FlatWire_DDL_05_QualityOutput.sql` | 6 quality/output tables |
| `FlatWire_DDL_06_ForeignKeys.sql` | **All 43 FKs** (as-built, 6 Aug 2026) |
| `FlatWire_DDL_07_Indexes.sql` | **64 non-clustered indexes**, including the 3 filtered UNIQUE (as-built, 6 Aug 2026) |
| `FlatWire_DDL_08_Programmability.sql` | Trigger + 2 read procedures + grants |
| `FlatWire_DDL_RunAll.sql` | SQLCMD orchestrator — **requires SQLCMD mode** |
| `FlatWire_DDL_99_Teardown.sql` | **Drops everything — test environments only** |
| `FlatWire_SampleData_*.sql` | Seed, in strict order — **non-production only** |
| `FW001_SharedSchema_Renames.sql` | The shared-schema renames — **separate approval** |
| `FW001_SharedSchema_Renames_REVERSE.sql` | **The reverse script. Must exist and be rehearsed before deployment** |
| `CommonDB_Insert_WIPStations_FlatWire.sql` | Creates `FL1`, `FL2`, `FL3`, **`FL1PO`** and `FWPACK` stations |

### 9.3 Known script constraints

- `machines.machine_idx` is **not** an IDENTITY — values are assigned explicitly and fixed at **125–127** so DEV/TEST/PROD agree.
- `machines.status` must be **`1`** or the machine is invisible to the `CommonDB.dbo.Machines` view.
- `WIPStations` has a UNIQUE index on `CoilNo`, so an idle station parks **its own station name** there as a guaranteed-unique placeholder.
- `WIPStation` is space-padded to 6 characters; `PrinterName` to 12.
- **`FL2PO` is deliberately not created** — FL2 is excluded from pre-check-in. **There is no `FL3PO`**; the working assumption is that FL3 posts to `FL1PO` (**OI-26**).
- Machine capability values seeded by that script are **provisional**.
- `FlatWire_SampleData_Schedule.sql`'s header comment claims Standalone 3 / Hybrid 7; **the actual content is 4 / 6**. The data is correct; the comment is wrong.

### 9.4 Deployment log template

```
FLAT WIRE MILL — DEPLOYMENT LOG

Environment:            ______________   Date/time started: ______________
Release tag (api):      ______________   Previous tag (api):  ______________
Release tag (angular):  ______________   Previous tag (web):  ______________
Release manager:        ______________   Engineer:            ______________

Pre-deployment
  [ ] Approvals            [ ] Backups taken & restore-tested
  [ ] Gate green           [ ] Line state clear (all four queries zero)
  [ ] Operators notified   [ ] Rollback rehearsed — elapsed: ______
Steps
  [ ] 1 Prepare            [ ] 2 FlatWireDB   V1 __ V2 __ V3 __ V4 __ V5 __ V6 __
  [ ] 3 FW-001 renames     V7 __ V8 __ V10 __        [ ] 4 API   V11 __
  [ ] 5 OPC config         V12 __                    [ ] 6 Angular
Smoke suite
  S1 __ S2 __ S3 __ S4 __ S5 __ S6 __ S7 __ S8 __
  S9 __ S10 __ S11 __ S12 __ S13 __ S14 __ S15 __
Outcome:  [ ] Success   [ ] Rolled back at step ____ — reason: ______________
Completed: ______________     Signed: ______________
```
