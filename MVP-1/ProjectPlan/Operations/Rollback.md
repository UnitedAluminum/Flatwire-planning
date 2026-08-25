# Flat Wire Mill — Rollback Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 18, 2026 — **`D-32`: there is no shared-schema migration.** **§6.3 cancelled** — the least-reversible element of the release no longer exists; `R1`, the FW-001 reverse row and `M3` amended *(previously August 13, 2026 — split out of `07-DeploymentRunbookAndRollback.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*
**Document Type:** Rollback plan
**Status:** Baselined — **rollback must be rehearsed before the first production deployment**
**Owner:** Release manager / IT
**Audience:** IT / DevOps, DBA, release manager, on-call
**Shortcode:** `[RB]`
**Part of:** `ProjectPlan/Operations/` — index: [README.md](../README.md)

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

#### 6.2.5 ~~FW-001 shared-schema renames~~ — **CANCELLED, `D-32`, 18 Aug 2026** *(§6.3 retained as the record)*

### 6.3 Rolling back the FW-001 renames — ~~the hard one~~ **CANCELLED**

> ⚠ **CANCELLED 18 Aug 2026 — decision `D-32`. There is no shared-schema migration, so there is nothing here to roll back.** This was the hardest element of the release to reverse and it no longer exists. The section is retained as the record of what was cancelled, and because `[INT]`, `[TB]` and `[DEP]` all pointed at it. **`R1`–`R2` and `M3` below are cancelled with it.** ⚠ **What is NOT cancelled:** the `machines` FL1/FL2/FL3 rows and the `CommonDB` WIP-station rows are still written to shared tables and still need a reversal plan — they are row inserts, not schema changes, and §6.2's other steps cover them.

> **State this plainly: the shared-schema renames are the highest-risk and least-reversible element of this release.** Every other component is a file copy or a restore of a database this module owns. **This one changes a schema other modules depend on.**

#### 6.3.1 What makes it hard

1. **Other modules read these columns.** Upstream receiving, planning, scheduling, reporting, yield and cost, **plus the legacy `ual-dot-net` tier**, all reference them. A rename that has been live for any length of time may already have had dependent objects recompiled against the new names.
2. **The legacy tier is invisible to `sys.sql_modules`.** A database dependency query will not find it. Compiled applications and Crystal/Excel report templates must be checked separately.
3. **The new columns and the new status value may already carry data.** `INFLAT` rows, `OutgoingCoil/BundleWidth` values and `IncomingWireDia` values written since deployment have nowhere to go in the pre-rename schema.
4. **A restore of a shared database is not this module's call.** It affects every other module using that database.

#### 6.3.2 Procedure

| # | Action | Command / method | Verification |
|---|---|---|---|
| ~~**R1**~~ | ~~**Stop `FlatWire.API` first** — it writes `coils.coil_status = INFLAT`~~ — **cancelled, `D-32`: it does not.** In-process state is `FlatWireDB`-local | `Stop-WebAppPool -Name "FlatWireAPI_<Env>"` | Pool stopped |
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
| ~~FW-001 reverse~~ — **cancelled, `D-32`** | ~~`INFLAT` status values, and any data in the two new columns~~ | ⚠ **This risk is retired but its shape is worth keeping:** after `D-32` **no** rod is ever `INFLAT` in the shared schema, so upstream never says so in the first place — that is **`OI-111`**, not a rollback risk. A `FlatWireDB` rollback still loses local `Rod.Status` |

**The manual reconciliation list — walk it after any API or database rollback:**

| # | Check | Query / method | Action |
|---|---|---|---|
| **M1** | **In-flight runs** | `SELECT RunId, LineId, Status, FootageFt FROM FlatWireRun WHERE Status IN ('Running','Paused')` | For each, establish physically what is on the line and correct the record or close the run |
| **M2** | **Open MMS IDs** | `SELECT RunId, RodAlpha, MmsId FROM RodCheckin WHERE MmsStatus IN ('Open','Active')` | An MMS ID orphaned from its run blocks ITInhibit clearance — close or re-associate |
| **M3** | **Rods stuck `INFLAT`** | ~~`SELECT alpha FROM coils WHERE [coil_status] = 'INFLAT'`~~ → **`SELECT RodAlpha FROM FlatWireDB.dbo.Rod WHERE [Status] = 'INFLAT'`** *(`D-32`: the shared column never carries `INFLAT`)* | Compare against physically loaded rods; correct the status of any that are not on a line |
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

Send to: all three line operators, the shift supervisor, packing, Maintenance, the Operations Manager, and — ~~the owners of any module affected by an FW-001 reversal~~ **no longer applicable since `D-32`; notify instead** the owners of any module affected by a reversal of the `machines` / WIP-station **row** writes.

---
