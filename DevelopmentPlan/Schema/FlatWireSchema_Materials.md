# Flat Wire Mill — Material Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
**Document Type:** Final Schema — Material Tracking Tables
**Source:** Derived from `FlatWireTables.md` recommendations
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `SQL/FlatWire_DDL_03_Materials.sql`

Material tables track the physical aluminum inputs to the flat wire mill. Wire rod (`Rod`) is the primary raw material fed at FL1. Pre-drawn spools (`Spool`) are FL1 output used as feed material at FL2 and FL3 in Hybrid route mode.

> **Note:** The hub table `FlatWireRun` is physically created in `FlatWire_DDL_03_Materials.sql` (so `Spool.SourceRunId` can reference it) but its data dictionary lives in **`FlatWireSchema_Runs.md`**. Per the Hybrid foundation decision, `Rod` is a FlatWireDB-local master mirroring the shared legacy `coils` record; rod-alpha FKs are enforced in-database.

---

## `Rod`

Wire rod receiving and lifecycle tracking. Each row represents one physical rod coil received from a supplier. Rods are identified by a unique alpha code and scanned at payoff check-in. The rod record links material certification data (supplier heat) to the finished output coil via `CoilTraceability`.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Alpha` | varchar(20) | NOT NULL UNIQUE | — | Unique alpha identifier (e.g. `R00041`); used for barcode scanning at check-in and referenced throughout all run event tables |
| `Alloy` | varchar(10) | NOT NULL | — | Aluminum alloy designation (e.g. `1100`, `3003`, `1350`) |
| `Temper` | varchar(10) | NOT NULL | — | Material temper designation (e.g. `O` = annealed, `H14` = strain hardened) |
| `DiameterIn` | decimal(8,4) | NOT NULL | — | Rod wire diameter in inches |
| `GrossWeightLb` | decimal(8,2) | NOT NULL | — | Total gross weight including packaging, in pounds |
| `NetWeightLb` | decimal(8,2) | NOT NULL | — | Net weight of aluminum material only, in pounds |
| `TareWeightLb` | decimal(8,2) | computed | — | **Computed PERSISTED**: `GrossWeightLb − NetWeightLb` |
| `SupplierHeat` | varchar(50) | NULL | — | Supplier heat or cast number for material certification and traceability back to the supplier mill |
| `InventoryType` | varchar(20) | NULL | — | Planning/cost inventory classification (**OQ-18 PROVISIONAL**) |
| `Status` | varchar(20) | NOT NULL | — | Material lifecycle status — see allowed values |
| `Location` | varchar(50) | NULL | — | Current physical floor location (e.g. bay/row/rack position) |
| `StagedPayoffPosition` | int | NULL | — | Pre-check-in staging: intended payoff (`1`/`2`); FlatwireQueue model (**PROVISIONAL**) |
| `IsWelded` | bit | NOT NULL | — | Pre-check-in "Mark as Welded" flag; default `0` |
| `FootageRunToDate` | decimal(10,2) | NULL | — | Cumulative footage produced across partial runs (Phase 7 / OQ-47) |
| `RemainingWeightEstimateLb` | decimal(8,2) | NULL | — | Estimated remaining weight after a partial run, in pounds |
| `ReceivedAt` | datetimeoffset | NOT NULL | — | Timestamp when this rod was received and entered into the system |
| `CreatedBy` | varchar(50) | NULL | — | Audit: receiving/creating operator |
| `ModifiedBy` | varchar(50) | NULL | — | Audit: last modifier |
| `ModifiedAt` | datetimeoffset | NULL | — | Audit: last-modified timestamp |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

**Constraints:** `CK_Rod_StagedPayoff` — `StagedPayoffPosition IN (1,2)` or NULL.

**Allowed values — `Status`:**

| Value | Meaning |
|---|---|
| `RECEIVED` | Rod received from supplier; not yet staged at a payoff position |
| `STAGED` | Rod positioned at a payoff position and ready for check-in to a run |
| `INFLAT` | Rod is currently in-process on a flat wire line |
| `COMPLETE` | Rod has been fully processed; output coils produced |
| `HOLD` | Rod is on hold pending quality review or supervisor decision |
| `SCRAP` | Rod has been scrapped and is no longer usable |

---

## `Spool`

Pre-drawn wire spool tracking. Spools are produced on FL1 in Hybrid route mode and subsequently checked in at FL2 or FL3 payoff positions. Each spool is identified by a unique alpha code and validated against its `SpoolConfiguration` constraints at check-in.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Alpha` | varchar(20) | NOT NULL UNIQUE | — | Unique alpha identifier (e.g. `SP-00021`); scanned at FL2/FL3 check-in |
| `SpoolTypeId` | int | NOT NULL | `SpoolConfiguration.Id` | FK to the spool configuration defining acceptable dimensional and weight constraints |
| `OrderNo` | varchar(50) | NULL | — | Manufacturing order number this spool is associated with |
| `RelLetter` | varchar(10) | NULL | — | Release letter designating the production release |
| `ParentRodAlpha` | varchar(20) | NULL | `Rod.Alpha` | Alpha of the wire rod coil that was drawn into this spool on FL1 |
| `SourceRodAlpha` | varchar(20) | NULL | `Rod.Alpha` | Partial-run source rod (Phase 7 / OQ-47); distinct from `ParentRodAlpha` |
| `SourceRunId` | varchar(20) | NULL | `FlatWireRun.RunId` | FK to the FL1 run that produced this spool; NULL if spool origin is external |
| `LineId` | varchar(5) | NULL | — | Line that produced or is currently processing this spool (`FL1`, `FL2`, `FL3`) |
| `OriginRouteMode` | varchar(15) | NULL | — | `Standalone`/`Hybrid` origin route; FL2 rejects a Standalone schedule on a Hybrid-origin spool (OQ-52) |
| `Status` | varchar(20) | NOT NULL | — | Material lifecycle status — see allowed values |
| `GaugeIn` | decimal(8,4) | NULL | — | Spool wire gauge in inches; populated at FL2/FL3 check-in |
| `WidthIn` | decimal(8,4) | NULL | — | Spool wire width in inches; populated at FL2/FL3 check-in |
| `GrossWeightLb` | decimal(8,2) | NULL | — | Gross weight of the spool in pounds |
| `NetWeightLb` | decimal(8,2) | NULL | — | Net weight of aluminum material in pounds |
| `Location` | varchar(50) | NULL | — | Current physical floor location |
| `ReceivedAt` | datetimeoffset | NULL | — | Timestamp when this spool was received at FL2/FL3 |
| `StagedAt` | datetimeoffset | NULL | — | Timestamp when this spool was staged at a payoff position |
| `CreatedBy` | varchar(50) | NULL | — | Audit: creating operator |
| `ModifiedBy` | varchar(50) | NULL | — | Audit: last modifier |
| `ModifiedAt` | datetimeoffset | NULL | — | Audit: last-modified timestamp |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

**Allowed values — `Status`:**

| Value | Meaning |
|---|---|
| `RECEIVED` | Spool received from FL1 or external source; not yet staged |
| `STAGED` | Spool positioned at a payoff position; ready for check-in to a run |
| `INFLAT` | Spool is currently in-process on FL2 or FL3 |
| `COMPLETE` | Spool has been fully processed |
| `HOLD` | Spool is on hold pending quality review or supervisor decision |
| `SCRAP` | Spool has been scrapped |

**Constraints:** `CK_Spool_LineId` (`FL1`/`FL2`/`FL3` or NULL); `CK_Spool_OriginRoute` (`Standalone`/`Hybrid` or NULL). Full status transition machine is OQ-57 (In Progress).

---

## Change Log

| Date | Change |
|---|---|
| July 26, 2026 | `Rod` kept as FlatWireDB-local master; `TareWeightLb` now computed PERSISTED; added carry-forward (`FootageRunToDate`, `RemainingWeightEstimateLb`), pre-check-in staging (`StagedPayoffPosition`, `IsWelded`), `InventoryType`, audit + `RowVersion`. `Spool` added `SourceRodAlpha`, `OriginRouteMode`, `LineId` CHECK, audit + `RowVersion`. Corrected bare `decimal` weights to `decimal(8,2)`. Retargeted to `FlatWireDB`. |
