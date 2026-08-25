# FlatWire DDL — folder manifest

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 23, 2026 — rewritten. The previous version contradicted the runners on six points and circulated eight different table counts; it predated both `D-31` and the 19 Aug seed split.
**Status:** Active — the manifest for this folder

**This file states no object counts.** The counted baseline is defined once, in **`[DBD §6.2]`**
([`../../DatabaseDesign.md`](../../DatabaseDesign.md)) — cite it, never restate it. Exactly three
places are permitted to restate the figures, and they name themselves as such: `[DEP §4.2]`'s
verification gate, `phase-01c`'s acceptance criteria, and `FlatWire_DDL_RunAll.sql`'s banner.

---

## The three runners

| Runner | Builds | Includes |
|---|---|---|
| **`FlatWire_DDL_RunAll.sql`** | **The complete MVP-1 database — schema only, tables EMPTY.** Idempotent. | `00` `01` `02` `03` `04` `05` `06` `07` `08` |
| **`FlatWire_SampleData_RunAll.sql`** | **DEV / TRIAL ONLY.** The five seed scripts, in an order that matters. Never run against production. | the five `FlatWire_SampleData_*.sql` |
| **`FlatWire_DDL_RunAll_MVP2.sql`** | **One procedure — `sp_ShiftSummary` — and nothing else.** It adds **no tables, no FKs and no indexes.** | `09` |

⚠ **`RunAll_MVP2` is an increment, not a standalone.** Run `FlatWire_DDL_RunAll.sql` first.

⚠ **A deployed `FlatWireDB` carries one more procedure than this folder builds.**
`sp_IngestRodFromCoils` is a `FlatWireDB` object but ships in
[`../../Scripts/`](../../Scripts/), because it reads `proddb..coils` and `united_db..alloys` and
cannot be verified by a `FlatWireDB`-only deploy. Counting `sys.procedures` on a partially-built
database is therefore misleading — see `[DBD §6.2]`.

## File by file

| File | Scope | Run by |
|---|---|---|
| `FlatWire_DDL_00_Database.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_01_Lookup.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_02_Schedule.sql` | **MVP-1** — `D-31`, 15 Aug 2026 | `RunAll` |
| `FlatWire_DDL_03_Materials.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_04_Runs.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_05_QualityOutput.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_06_ForeignKeys.sql` | MVP-1 — **all** foreign keys, one script | `RunAll` |
| `FlatWire_DDL_07_Indexes.sql` | MVP-1 — **all** index statements, one script | `RunAll` |
| `FlatWire_DDL_08_Programmability.sql` | MVP-1 — `sp_GetGaugeTrace`, `trg_CoilTraceability_NoOverlap` | `RunAll` |
| **`FlatWire_DDL_09_Programmability_MVP2.sql`** | **MVP-2** — `sp_ShiftSummary`, backing DB10 | `RunAll_MVP2` |
| `FlatWire_DDL_99_Teardown.sql` | both — drops the whole database | **manual, by design** |
| `FlatWire_SampleData_Lookup.sql` | MVP-1 | `SampleData_RunAll` |
| `FlatWire_SampleData_Schedule.sql` | **MVP-1** — `D-31` | `SampleData_RunAll` |
| `FlatWire_SampleData_Materials.sql` | MVP-1 | `SampleData_RunAll` |
| `FlatWire_SampleData_Runs.sql` | MVP-1 | `SampleData_RunAll` |
| `FlatWire_SampleData_QualityOutput.sql` | MVP-1 | `SampleData_RunAll` |

**Nothing in this folder is unreachable except `FlatWire_DDL_99_Teardown.sql`**, which is manual
because it is destructive. If you add a file, add it to a runner in the same commit.

## Two things that look like defects and are not

**The numbering is contiguous `00`–`09` plus the `99` teardown sentinel, and *"of 09"* in the
script headers is now true.** It was not until 23 Aug 2026: `06b` and `07b` existed from 11 Aug,
when the schema was divided by MVP scope, and survived `D-31` returning them to MVP-1 on 15 Aug.
They were **folded back into `06` and `07`** because the division that justified separate files
no longer existed — and because the *"47 of the 57 FKs, `06b` adds the other 10"* split-count is a
two-number form that has to be maintained in lockstep across every citing document, and drifted
four times in four documents. Their provenance warnings are preserved verbatim as section banners
inside the merged files. **Do not re-split them.**

**The seeds are not in the schema runner.** They were until 19 Aug 2026, unconditionally — so
every schema deployment also inserted eight fake rods plus fake runs, check-ins and coil outputs.
Harmless on LocalDB; not harmless once the runner is pointed at the shared instance, which the
check-in transaction model requires. A conditional `:r` is impossible — it is a SQLCMD parse-time
directive — hence a separate runner.

## Deploying

**SQLCMD mode is required** (`:r` and `:on error exit` are SQLCMD-only) and both runners use
**bare relative filenames**, so run them **from this folder**.

```powershell
cd "c:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"

sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql          # the MVP-1 schema
sqlcmd -S "<server>" -E -C -i FlatWire_SampleData_RunAll.sql   # DEV / TRIAL ONLY
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll_MVP2.sql     # only if DB10 is wanted
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql     # drops everything
```

In SSMS use **Query → SQLCMD Mode** first. Every script guards its objects, so all three runners
are idempotent.

⚠ **The target is the shared instance, not LocalDB.** `FlatWireDB` must sit alongside
`united_db` / `proddb` / `SlitterDB` / `CommonDB` / `wiplogdb`, because the check-in transaction
model spans `FlatWireDB` and the shared schema in **one** `SqlTransaction` under the **local**
transaction manager, with no MSDTC (`[INT §8.0]`, `[ARC §10]`). LocalDB has no `united_db`, so a
build validated only there silently loses that atomicity.

**This folder is only part of a deployment.** The cross-folder sequence — schema, then the
shared-schema rows, the grants and the procedures in [`../../Scripts/`](../../Scripts/) — has one
home: **`[DEP §4.2]`**. This file does not restate it.

## Related

- [`MVP2-SCOPE.md`](MVP2-SCOPE.md) — what is deferred, and why it is now one procedure.
- [`../../Scripts/README.md`](../../Scripts/README.md) — the cross-database scripts and their sign-off state.
- **`[DBD §6.2]`** — the counted object baseline. The only site that defines it.
