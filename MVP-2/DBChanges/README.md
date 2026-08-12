# MVP-2 Database Changes — Deferred Schema

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope.** Additive on top of the MVP-1 schema.

---

> **⚠ Read this before deploying anything.** The 27-table `FlatWireDB` was **divided by MVP scope on 11 Aug 2026**. Neither half is a complete database on its own, and the MVP-1 half now has four unenforced columns. The details below are not incidental — they are the cost of the division, recorded so nobody rediscovers them at deploy time.

## What is here — 3 of the 28 tables

| Table | Backs | Group |
|---|---|---|
| `PassSchedule` | DB9 / DB9A Pass Schedule Management | Schedule |
| `PassScheduleComponent` | DB9 / DB9A | Schedule |
| `PassScheduleChangeLog` | DB9 / DB9A (and `FW-014`'s override log) | Schedule |

Plus **10 of the 43 foreign keys**, **6 of the 47 indexes**, and **1 of the 3 programmability objects** (`sp_ShiftSummary`, for DB10). `sp_GetGaugeTrace` and `trg_CoilTraceability_NoOverlap` are both MVP-1.

There is **no `99b` teardown**: MVP-1's `FlatWire_DDL_99_Teardown.sql` drops the whole database and is scope-agnostic.

### `CoilOutput` and `CoilTraceability` are **MVP-1**

They were briefly split out here with the DB7 / DB7b screens and **returned to MVP-1 on 11 Aug 2026**. The reason is the one that was recorded when the screens were first deferred: the coil genealogy those two tables carry is what the **welding-wire customer certificates** are produced from, and that obligation does not move with the screen.

So the boundary is **not** "the screen is deferred, therefore its tables are":

| Deferred | Still MVP-1 |
|---|---|
| ~~DB7 / DB7b screens, their `FR-###`, `TC-###` and `FW-066`~~ **— returned to MVP-1 on 11 Aug 2026; Phase 9 is wholly MVP-1** | `CoilOutput`, `CoilTraceability`, their 4 FKs, 7 indexes, the DM010 non-overlap trigger, their seed data **and everything that writes them** (`CoilCompletionService`, `POST /coil/complete`, `GET /coil/{alpha}/label`) |

## Deploying

```powershell
# 1. MVP-1 first — this chain is additive and cannot run alone.
cd "c:\UAL\Flatwire-planning\MVP-1\DBChanges\Schema\SQL"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql

# 2. Then this one.
cd "c:\UAL\Flatwire-planning\MVP-2\DBChanges\Schema\SQL"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll_MVP2.sql
```

SQLCMD mode is required (`:r` includes). In SSMS use **Query → SQLCMD Mode**.

## ⚠ Three consequences of the division

### 1. Four foreign keys in this folder sit on **MVP-1** tables

```
FlatWireRun.PassScheduleId   -> PassSchedule
RodCheckin.PassScheduleId    -> PassSchedule
SpoolCheckin.PassScheduleId  -> PassSchedule
CoilOutput.PassScheduleId    -> PassSchedule
```

All four **child** tables are MVP-1; only the parent is here. They were routed to MVP-2's `06b` script rather than left in MVP-1's `06` for one reason: **an MVP-1-only build has no `PassSchedule` table, so leaving them there made the MVP-1 chain undeployable.**

**What that costs:** between an MVP-1 deployment and an MVP-2 deployment, `PassScheduleId` is an **unenforced column on four tables** — including `RodCheckin`, the table behind the check-in that acknowledges a pass schedule and pushes PLC tags from it. Nothing stops a bad value going in.

`CoilOutput` joined that list when it returned to MVP-1: it carries a `PassScheduleId` too, so moving the table back moved the column back without its parent.

### 2. The deployment order is **not** the numeric order, deliberately

`FlatWire_DDL_RunAll_MVP2.sql` runs the **pass-schedule seed before the foreign keys**. MVP-1 seeds `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput` rows carrying `PassScheduleId` values (`PS-1100-FL1-001` and friends) whose parent rows are created *here*. Add the constraints first and they **fail on those pre-existing rows**.

**Do not invoke `06b` by hand** on a freshly seeded MVP-1 database. Use the runner.

### 3. An MVP-1-only database has dangling `PassScheduleId` values

This is the same fact from the MVP-1 side. Until this chain runs, those values point at nothing. MVP-1's runner carries the same warning.

## Column-level scope that could not be divided

`Drawer.LastGrindingFeet` and `Drawer.TotalFeetAllowed` — added 6 Aug 2026 — are **the die-life counter and threshold**, and they exist solely for the **MVP-2** Die Management screen (`DieChangeAndManagement.md` §4.2/§4.4 semantics, and `OQ-83`'s threshold). But `Drawer` is an **MVP-1** lookup table that `PassScheduleComponent` and the MVP-1 die change both need.

**A table cannot be split**, so `Drawer` stays whole in MVP-1 with two columns nothing in MVP-1 populates. Recorded here rather than acted on.

## What stayed in MVP-1 and is not duplicated

| Artifact | Why |
|---|---|
| `FlatWire_DDL_00_Database.sql` | Creates `FlatWireDB` itself — shared |
| `FlatWire_DDL_99_Teardown.sql` | Drops the whole database — scope-agnostic |
| `FlatWireSchema_Mapping.md` | Maps existing↔new tables across both scopes |
| `SQL/FlatWire_ERDiagram_Documentation.md` | **One ER diagram covering all 28 tables.** Not divided — a half-ER is worse than none |
| `FlatWireSchema_Lookup.md`, `_Materials.md`, `_Runs.md`, `_QualityOutput.md` | MVP-1 tables. `_QualityOutput.md` holds the full `CoilOutput` / `CoilTraceability` design again |
| `DBScripts/` | WIP station registration against the shared `CommonDB` |
