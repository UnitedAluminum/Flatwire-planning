# MVP-2 Database Changes — Deferred Schema

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 15, 2026 — **decision `D-31` moved the pass-schedule tables into MVP-1.** This document previously described a three-table, ten-FK, six-index deferred increment; **one stored procedure is all that is left.** Rewritten rather than amended, because almost every warning it carried was a cost of a division that no longer exists
**Status:** **MVP-2 — deferred scope.** Additive on top of the MVP-1 schema.

---

> **⚠ If you came here looking for `02_Schedule` or `FlatWire_SampleData_Schedule.sql` — they are in the MVP-1 runner now. `06b` and `07b` no longer exist at all: they were folded into `06` and `07` on 23 Aug 2026.** Nothing is missing and there is no second chain to hunt for. `FlatWire_DDL_RunAll.sql` builds a **complete 33-table `FlatWireDB`** on its own.

## What is here — one object

| Object | Backs | File |
|---|---|---|
| `sp_ShiftSummary` | **DB10** Supervisor Shift Summary — an MVP-2 screen | `FlatWire_DDL_09_Programmability_MVP2.sql` |

That is the entire deferred database increment. `sp_GetGaugeTrace` and `trg_CoilTraceability_NoOverlap` are both **MVP-1**.

⚠ **Do not "helpfully" fold `sp_ShiftSummary` into the MVP-1 chain.** No MVP-1 code path calls it, and `phase-01b` is explicit: *"`sp_ShiftSummary` is MVP-2's — do not create, drop or grant it."*

There is **no `99b` teardown**: MVP-1's `FlatWire_DDL_99_Teardown.sql` drops the whole database and is scope-agnostic.

## What changed on 15 Aug 2026, and why

`[API §4.2]` had carried an **open assumption** since the contract was written. MVP-1 reads a pass schedule at check-in to build the PLC push payload, and there were two published options for *how*:

- **(a)** MVP-1 calls the owning track's API and persists a local snapshot; or
- **(b)** the owning track **writes into `FlatWireDB`** and the read is a **local query**.

**`D-31` chooses (b)** — arbitration between two published options, not new scope. So `PassSchedule`, `PassScheduleComponent` and `PassScheduleChangeLog`, their seed, their **10 foreign keys** and their **6 indexes** are now built by the MVP-1 runner in contiguous numeric order.

It also closed `[TRP §6]` blocker #1, which blocked **both** check-in screens and therefore the entire six-screen trial run: the trial's own deploy script produced no schedule at all, so `PS-1100-FL1-001` and `PS-1100-FL2-001` did not exist in the database the trial was accepted against.

### ⚠ Owning the table is not owning the data

**MVP-1 reads these tables and never writes them.** There is no create, edit, approve or list; `PassScheduleController` is scaffolded for MVP-2 handlers and implements nothing. **Dashboards 9 and 9A stay MVP-2.**

Which leaves the one thing `D-31` moved rather than removed: **nothing in MVP-1 populates these tables in production.** `FlatWire_SampleData_Schedule.sql` covers development and the trial. Production needs the owning track to write into them (reading (b) as intended), or MVP-2's screens to ship. Tracked as **`OI-110`**.

## Deploying

```powershell
# MVP-1 — complete on its own. 40 tables, and it needs nothing from this folder.
cd "c:\UAL\Flatwire-planning\30-database\sql"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql

# MVP-2 — adds sp_ShiftSummary and nothing else. Only needed for DB10.
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll_MVP2.sql
```

SQLCMD mode is required (`:r` includes). In SSMS use **Query → SQLCMD Mode**.

**The MVP-1 runner builds the whole database on its own** — teardown → `RunAll` → idempotent
re-run, verified on a live deploy. ⚠ **The object counts are not restated here.** `[DBD §6.2]` is
the defining site; check against it, or run
[`../../tools/deliverables/verify_schema_counts.py`](../../tools/deliverables/verify_schema_counts.py).

*This block published `33 tables · 55 foreign keys · 69 index statements · 1 procedure · 1 trigger`
against a "verified 15 Aug 2026" date until 26 Aug 2026 — a combination that never existed on any
date: 33 arrived with `Q60`'s `SpoolConfiguration` merge on 23 Aug and the index count moved to 70
with `Q89` on 26 Aug, while the 15 Aug build had neither.*

`sp_ShiftSummary` is **absent** from that database, which is correct.

## Three warnings this document used to carry — all now void

Recorded so that anyone reading an older copy, or a document that quotes one, knows they were retired rather than forgotten.

| Retired warning | Why it is void |
|---|---|
| *"Four foreign keys in this folder sit on MVP-1 tables … `PassScheduleId` is an **unenforced column** on four tables. Nothing stops a bad value going in."* | The four FKs (`FlatWireRun`, `RodCheckin`, `SpoolCheckin`, `CoilOutput` → `PassSchedule`) are in the MVP-1 chain and **enforced and trusted**. The gap they warned about is closed |
| *"The deployment order is not the numeric order, deliberately — the pass-schedule seed runs **before** the foreign keys."* | Only true when adding constraints to an **already-seeded** database. The MVP-1 runner applies all DDL **before any seed**, so the FKs land on empty tables. ⚠ **The seed order still matters**: `Lookup → Schedule → Materials`, because `FlatWireRun.PassScheduleId` now has a real parent |
| *"An MVP-1-only database has dangling `PassScheduleId` values."* | There is no MVP-1-only-without-schedule database any more |

## Column-level scope that could not be divided — ✅ RESOLVED 2 Sep 2026

> ⛔ **This section recorded a problem that has now been fixed, and it is kept only as the record of how.** It said `Drawer.LastGrindingFeet` and `Drawer.TotalFeetAllowed` — added 6 Aug 2026 — existed solely for the **MVP-2** Die Management screen (the §4.2 / §4.4 semantics of [`DieChangeAndManagement.md`](../../10-requirements/screens/DieChangeAndManagement.md), and `OQ-83`’s threshold) while `Drawer` was an **MVP-1** lookup, and concluded: *"**A table cannot be split**, so `Drawer` stays whole in MVP-1 with two columns nothing in MVP-1 populates."*
>
> **The table WAS split, on 2 Sep 2026 (`Q91`).** What made it possible was removing the **scope seam**, not a new technique: the whole die domain returned to MVP-1, so there is no longer an MVP-1 table carrying MVP-2 columns. `Drawer` is now the two draw **boxes** (`DB1`, `DB2`); the die-life columns live on **`ToolingInventoryDie`**, the per-tool register, beside **`DieHistory`**. Both are MVP-1, built and seeded in Phase 1. **`OI-41` closes** with it.
>
> This was the *only* surviving instance of scope that could not be expressed at table granularity. There is now none.

## What is MVP-1 and is not duplicated here

| Artifact | Why |
|---|---|
| `FlatWire_DDL_00_Database.sql` | Creates `FlatWireDB` itself — shared |
| `FlatWire_DDL_99_Teardown.sql` | Drops the whole database — scope-agnostic |
| **`FlatWire_DDL_02_Schedule.sql`, `FlatWire_SampleData_Schedule.sql`, `06b`, `07b`** | **Moved to MVP-1 on 15 Aug 2026 (`D-31`)** — in the runner, in numeric order |
| `FlatWireSchema_Mapping.md` | Maps existing↔new tables across both scopes |
| `FlatWireSchema_Lookup.md`, `_Materials.md`, `_Runs.md`, `_QualityOutput.md` | MVP-1 tables. `_QualityOutput.md` holds the full `CoilOutput` / `CoilTraceability` design |
| [`../../Scripts/`](../../Scripts/) | The eight cross-database scripts — grants, the WIP-station/machines registration, the rod-ingestion procedure and the four `united_db` procedures. None is in any `:r` chain, by design; see that folder's `README.md` |
