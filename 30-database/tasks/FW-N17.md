---
id: FW-N17
legacy_id:
title: LineId → MachineName — the database layer
status: done
status_confirmed: true
status_note: "✅ **Done, 8 Sep 2026.** All **24 `LineId` columns** are now `MachineName` across scripts 01–05, with **22 `CK_*_MachineName`** constraints and the 3 index names that carried the token. Shape is unchanged — `VARCHAR(5)`, same nullability, same `CHECK` value sets; ⛔ nothing widened to `machine_name`'s `varchar(31)`. `sp_ShiftSummary` takes `@MachineName VARCHAR(5)` (script 09, reached only by the MVP2 runner). The 3 cross-database procedures are updated **including their `THROW` message text**. `verify_schema_counts.py` reports **46/68/89/1/1 unchanged**, which is the assertion this story hangs on. ⚠ **Two items raised, not fixed:** the Die procedures' FL3 branch queries `MachineName IN ('FL1','FL2')` while `CK_ToolingInventoryDie_MachineName` admits only `NULL` or `'FL1'`, so the FL2 arm is unreachable (a `D-42` question); and `Stand`/`Dancer` still carry the column with **no `CHECK`** — pre-existing, deliberately untouched."
owner:
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB]
priority: high
hours: 4
sprint: S0
depends_on: []
blocked_by: []
has_plan: true
started: 2026-09-08
completed: 2026-09-08
---

# FW-N17 - LineId → MachineName — the database layer

## What to build

Rename the flattening-line identifier from `LineId` to `MachineName` everywhere in `FlatWireDB`,
per **`D-56`**. Shape does not change — only the name.

> ### ⚠ This was never two identifiers
>
> The question that produced `D-56` was why the module carries `LineId` when
> `united_db..machines.machine_name` already holds `FL1` / `FL2` / `FL3`. It does not, and never
> did: `LineId` was a **denormalised `VARCHAR(5)` holding those exact literals**, on 24 columns,
> policed by 22 `CHECK` constraints and **zero foreign keys**
> ([`06_ForeignKeys.sql`](../sql/FlatWire_DDL_06_ForeignKeys.sql) says so deliberately, twice).
>
> So there is **no data migration**, no lookup table to drop and no key to repoint. What was
> duplicated was the vocabulary.
>
> ⛔ **No FK is possible either way.** `united_db..machines` is a different database, and
> `machine_name` there is `varchar(31) NULL`, non-unique and non-indexed — `GetMachineIdFromName`
> uses `TOP 1` for exactly that reason. Adopting the name buys vocabulary, **not** referential
> integrity, and the local `CHECK` remains the only guarantee.

## Context you need

- **The client's own grid header for this column is "Machine Name"** —
  [`01_Lookup.sql`](../sql/FlatWire_DDL_01_Lookup.sql), `ToolingInventoryDie`.
- **`D-53` renamed it the other way** on 6 Sep 2026, absorbing `Edger`. Its author recorded the
  direction in a comment: *"MachineName became LineId"*. `D-56` reverses that half only — the
  absorption stands and `FK_PSC_Edger` keeps its name.
- **Two procedures could not execute.** On `origin/feature/UADEV-23178`,
  `Machine_GetToolingInventoryDieData` and its Insert/Update sibling read and write
  `TID.MachineName` against a column the DDL named `LineId`. The edger pair papered over the
  mismatch with `TIE.LineId AS MachineName`. **Both pairs already projected `MachineName`**, so the
  legacy Machines Application's result set does not move.
- ⛔ **`machineIdx` is a different fact.** 125 / 126 / 127, cited from
  [`[INT]`](../../20-architecture/Integration.md), for OPC and scheduling only. `D-55` separated
  the three facts and `D-56` does not reopen that.

## Build order

1. Columns and `CHECK` constraints in scripts **01–05** (8 · 1 · 2 · 9 · 4 = 24 columns).
2. Comment prose in **06** — no FK exists, so this file is text only.
3. The 3 index names in **07**, plus the 4 inline `UQ_*` in 01.
4. `sp_ShiftSummary` in **09**.
5. The 5 sample-data scripts.
6. The 3 cross-database procedures in [`../scripts/`](../scripts/) — `40_…CheckInRod`,
   `50_…CompleteCoilOnSkid`, `35_…View_WIPStations` — **including the `THROW` message text** for
   `52003` / `52004` / `52005` and `51001`.
7. [`DatabaseDesign.md`](../DatabaseDesign.md) and the 6 [`schema/`](../schema/) documents,
   including the **15 mermaid ERD attribute lines**.

## Decisions made here

- **Shape held constant.** `VARCHAR(5)`, same nullability per table, same `CHECK` value sets.
  Matching `machine_name`'s `varchar(31)` was considered and rejected: it widens 24 columns and
  every composite index leading on them, and still cannot be FK'd.
- **Index names renamed only where they carry the token** — three do
  (`IX_FlatWireRun_MachineName`, `IX_RodStaging_MachineName_Status`,
  `IX_RodCheckin_MachineName_PayoffPosition`). `UX_FlatWireRun_ActiveLine`,
  `IX_PassSchedule_LineAlloyStatus`, `UX_PassSchedule_OneActivePerLineAlloy`,
  `IX_SpoolStaging_Queue`, `UX_SpoolStaging_LiveSpool`, `IX_LineDowntimeEvent_LineOpen` and the
  `UQ_*_Line*` pairs keep their names — the bare word *Line* survives, and only the compound token
  moved.

## Verification

```powershell
cd "c:\UAL\Flatwire-planning\30-database\sql"
sqlcmd -S "DEV00164-001" -E -C -i FlatWire_DDL_99_Teardown.sql
sqlcmd -S "DEV00164-001" -E -C -i FlatWire_DDL_RunAll.sql
sqlcmd -S "DEV00164-001" -E -C -i FlatWire_DDL_RunAll_MVP2.sql
sqlcmd -S "DEV00164-001" -E -C -i FlatWire_SampleData_RunAll.sql
```

⛔ **The MVP2 runner is not optional.** `FlatWire_DDL_RunAll.sql` chains scripts **00–08 only**;
`sp_ShiftSummary` is in **09**. Run the base runner alone and the renamed parameter is never
compiled — which is also why the baseline's *1 procedure* is script 08's `sp_GetGaugeTrace`.

Then `python tools/deliverables/verify_schema_counts.py` — **46 tables · 68 FKs · 89 index
statements · 1 procedure · 1 trigger, unchanged.** A rename that moves a count is a defect. Re-run
[`Deployment.md`](../../80-operations/Deployment.md) §390's
`UX_PassSchedule_OneActivePerLineAlloy` query.

## Handoff

- **`FW-N18`** consumes this: the 11 EF configurations map to these column names.
- ⚠ **`origin/feature/UADEV-23178` is not this repository and is owned by another developer.** Its
  9 tooling procedures and 2 synonyms need the same pass — coordinate into that branch or sequence
  after its merge. ⛔ Do not fork a second copy of those procedures.
- ⚠ **Open, for `D-42`:** widen `CK_ToolingInventoryDie_MachineName` to `('FL1','FL2')`, or drop
  the `FL2` arm from the Die procedure? The branch is unreachable as it stands.
- ⚠ **`ToolingInventoryStraightener` procedures exist on that branch with no table anywhere**
  (`G77`'s straightener half is still open). Pre-existing, out of scope here.
