# FlatWire DDL — folder manifest

**⚠ The numbering in this folder is contiguous. The build is not.**

Twenty-one files sit here in an unbroken sequence — `00, 01, 02, 03, 04, 05, 06, 06b, 07, 07b, 08, 08b, 99` plus five seeds and **two runners**. Reading that as one build is the mistake this file exists to prevent: **five of them are MVP-2 and no MVP-1 runner touches them.**

*(The MVP-2 files were co-located here on 15 Aug 2026, from `MVP-2/DBChanges/`. The split itself is unchanged — **the pass schedule is still owned outside MVP-1** — only the file location moved.)*

## The two runners

| Runner | Builds | Contains |
|---|---|---|
| **`FlatWire_DDL_RunAll.sql`** | **MVP-1 — 28 tables** · 43 FKs · 47 indexes · 1 procedure (`sp_GetGaugeTrace`) · 1 trigger (`trg_CoilTraceability_NoOverlap`) | `00` `01` `02` `03` `04` `05` `06` `06b` `07` `07b` `08` + **five** seeds |
| **`FlatWire_DDL_RunAll_MVP2.sql`** | **The MVP-2 increment → 28 tables total** · adds `sp_ShiftSummary` | `02` `06b` `07b` `08b` + the schedule seed |

⚠ **`RunAll_MVP2` is an increment, not a standalone.** It starts at `02_Schedule`, which depends on `01_Lookup`, and its FKs reference MVP-1 tables. **Run `RunAll` first, always.**

## File-by-file

| File | Scope | Run by |
|---|---|---|
| `FlatWire_DDL_00_Database.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_01_Lookup.sql` | MVP-1 | `RunAll` |
| **`FlatWire_DDL_02_Schedule.sql`** | **MVP-2** | `RunAll_MVP2` |
| `FlatWire_DDL_03_Materials.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_04_Runs.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_05_QualityOutput.sql` | MVP-1 | `RunAll` |
| `FlatWire_DDL_06_ForeignKeys.sql` | MVP-1 | `RunAll` |
| **`FlatWire_DDL_06b_ForeignKeys.sql`** | **MVP-2** | `RunAll_MVP2` |
| `FlatWire_DDL_07_Indexes.sql` | MVP-1 | `RunAll` |
| **`FlatWire_DDL_07b_Indexes.sql`** | **MVP-2** | `RunAll_MVP2` |
| `FlatWire_DDL_08_Programmability.sql` | MVP-1 | `RunAll` |
| **`FlatWire_DDL_08b_Programmability.sql`** | **MVP-2** — `sp_ShiftSummary` | `RunAll_MVP2` |
| `FlatWire_DDL_99_Teardown.sql` | both | manual |
| `FlatWire_SampleData_Lookup.sql` | MVP-1 | `RunAll` |
| `FlatWire_SampleData_Materials.sql` | MVP-1 | `RunAll` |
| `FlatWire_SampleData_Runs.sql` | MVP-1 | `RunAll` |
| `FlatWire_SampleData_QualityOutput.sql` | MVP-1 | `RunAll` |
| **`FlatWire_SampleData_Schedule.sql`** | **MVP-2** | `RunAll_MVP2` |

## Deploying

**SQLCMD mode is required** — `:r` includes are SQLCMD-only — and both runners use **bare relative filenames**, so run them *from this folder*.

```powershell
cd "c:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"

# MVP-1 — 28 tables
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql

# then, only if MVP-2 scope is wanted — 28 tables
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll_MVP2.sql

# drop everything
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_99_Teardown.sql
```

Every script guards its objects, so both runners are **idempotent** and safe to re-run. In SSMS use **Query → SQLCMD Mode** first.

## Related

- **[`MVP2-SCOPE.md`](MVP2-SCOPE.md)** — why the MVP-2 carve exists and what is in it.
- **`[DBD §6.2]`** — the counted object baseline. **25 MVP-1 / 28 full**, counted from `CREATE TABLE` statements rather than quoted. Counts of 20, 21, 22, 24 and 27 all circulate in older documents and are superseded.
