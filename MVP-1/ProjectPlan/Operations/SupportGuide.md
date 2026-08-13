# Flat Wire Mill — Support Guide

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `07-DeploymentRunbookAndRollback.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Incident runbook, handover, contacts, command reference
**Status:** Baselined
**Owner:** Release manager / IT
**Audience:** On-call engineer, IT, support
**Shortcode:** `[SUP]`
**Part of:** `ProjectPlan/Operations/` — index: [README.md](../README.md)

---

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

---

### 7.4 Support handover

The on-call engineer should have: this document · `[API §1.8]` (the error-code catalogue) · the current tag map · the deployment log with both tags recorded · and the §6.4 reconciliation queries.

---

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
