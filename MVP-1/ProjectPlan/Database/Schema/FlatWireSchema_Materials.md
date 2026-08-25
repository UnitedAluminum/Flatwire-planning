# Flat Wire Mill — Material Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 23, 2026 — **`Spool` and `SpoolCarrier` are SWAPPED (`Q60`).** The reusable stencilled article is now **`Spool`** in `01_Lookup`; the material record is now **`SpoolProcessing`** in `03_Materials`; `CarrierNo` → `SpoolNo`. ⚠ **A stale `Spool` reference is now *silently wrong*, not obviously stale** — see `[DBD §6.2a]`, the naming convention this closed. **`SpoolConfiguration` is also merged into `Spool`**, so `SpoolProcessing.SpoolTypeId` is gone — the article's limits are reached through the nullable `SpoolId`. Counts move to **33 tables · 55 FKs · 69 index statements**. *(previously August 23, 2026 — corrected up to the DDL; header fields standardised)*
**Document Type:** Final Schema — Material Tracking Tables
**Source:** the April gap analysis, now the appendix of [FlatWireSchema_Mapping.md](FlatWireSchema_Mapping.md) (absorbed 13 Aug 2026 when `FlatWireTables.md` was deleted; recoverable in git history)
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `SQL/FlatWire_DDL_03_Materials.sql`
**Status:** Active — corrected up to the DDL, August 23, 2026
**Scope:** MVP-1
**Owner:** Architecture stream / DBA
**Audience:** DBA, .NET developers, BA
**Part of:** `ProjectPlan/Database/` — the as-built model and the counted baseline are [`DatabaseDesign.md`](../DatabaseDesign.md) (`[DBD]`)
**Authority:** `SQL/FlatWire_DDL_03_Materials.sql` **wins** on types, nullability and constraints. This document explains them; it does not define them, and it states no object counts — those are `[DBD §6.2]`. No shortcode is declared, deliberately: these are derived documents and must not be cited as authority.

Material tables track the physical aluminum inputs to the flat wire mill. Wire rod (`Rod`) is the primary raw material fed at FL1. Pre-drawn spools (`SpoolProcessing`) are FL1 output used as feed material at FL2 and FL3 in Hybrid route mode.

> **Note:** The hub table `FlatWireRun` is physically created in `FlatWire_DDL_03_Materials.sql` (so `SpoolProcessing.SourceRunId` can reference it) but its data dictionary lives in **`FlatWireSchema_Runs.md`**. Per the Hybrid foundation decision, `Rod` is a FlatWireDB-local master mirroring the shared legacy `coils` record; rod-alpha FKs are enforced in-database.

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
| `InventoryType` | varchar(20) | NULL | — | Planning/cost inventory classification (**OI-49 PROVISIONAL**) |
| `Status` | varchar(20) | NOT NULL | — | Material lifecycle status — see allowed values |
| `Location` | varchar(50) | NULL | — | Current physical floor location (e.g. bay/row/rack position) |
| `FootageRunToDate` | decimal(10,2) | NULL | — | Cumulative footage produced across partial runs (Phase 7 / OQ-12) |
| `RemainingWeightEstimateLb` | decimal(8,2) | NULL | — | Estimated remaining weight after a partial run, in pounds |
| `ReceivedAt` | datetimeoffset | NOT NULL | — | Timestamp when this rod was received and entered into the system |
| `CreatedBy` | varchar(50) | NULL | — | Audit: receiving/creating operator |
| `ModifiedBy` | varchar(50) | NULL | — | Audit: last modifier |
| `ModifiedAt` | datetimeoffset | NULL | — | Audit: last-modified timestamp |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

**Constraints:** `CK_Rod_Status`, `CK_Rod_DiamPos` — `DiameterIn > 0`.

> **Pre-check-in staging is not stored here.** The former `StagedPayoffPosition` / `IsWelded`
> columns (and `CK_Rod_StagedPayoff`) were retired: a nullable column pair on `Rod` cannot
> express "one rod per payoff bay", which is the core invariant of the Pre-Check-In station.
> Staging now lives in [`RodStaging`](FlatWireSchema_Runs.md) with filtered unique indexes that
> enforce it. See `MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md` and SRS §4.2 `PCI001`–`PCI008`.

**Allowed values — `Status`:**

| Value | Meaning |
|---|---|
| `RECEIVED` | Rod received from supplier; not yet staged at a payoff position |
| `STAGED` | Rod positioned at a payoff position and ready for check-in to a run |
| `INFLAT` | Rod is currently in-process on a flat wire line |
| `COMPLETE` | Rod has been fully processed; output coils produced |
| `HOLD` | Rod is on hold pending quality review or supervisor decision |
| `SCRAP` | Rod has been scrapped and is no longer usable |

### How `Rod` is populated — and which side owns each column

`Rod` is a `FlatWireDB`-local mirror of `proddb..coils` (`D-04`), and **until 19 Aug 2026 nothing populated it in production**. Rod receiving (`FW-020`–`FW-022`) is upstream, was removed from this backlog as another team's work, and writes `coils` — not `FlatWireDB`. With `FK_RodCheckin_Rod` and `FK_RodStaging_Rod` enforced, the first staging or check-in on a clean database would have failed on a foreign key. That was **`OI-42`**, now closed.

**`FlatWireDB.dbo.sp_IngestRodFromCoils` projects the rod on the first *write* that names it** — `POST /staging/rod` or `POST /checkin/rod`, whichever comes first — inside that operation's transaction. **`GET /rod/{alpha}` deliberately does not**: it is idempotent and any role may call it, so a scan to look at a rod must not create records. Specification `[INT §7.9]`, requirements `FR-529`–`FR-532`, story `FW-223`.

| Column | Source | Master |
|---|---|---|
| `Alpha` | `coils.coil_no` | shared |
| `Alloy` | `coils.coil_alloy` → `united_db..alloys.alloy_idx` → `.alloy` | shared |
| `Temper` | `coils.coil_temper` (defaults to `O` when null) | shared |
| `DiameterIn` | the operator's measurement, from the calling payload | **local** |
| `GrossWeightLb` / `NetWeightLb` | `coils.coil_gross_wgt` / `coil_net_wgt` | shared |
| `SupplierHeat` | **nothing** — `OI-117` | — |
| `InventoryType` | `coils.inventory_type` *(still `PROVISIONAL`, `OI-49`)* | shared |
| `Location` | `coils.storage_section` | shared |
| `ReceivedAt` | `coils.coil_recvd_date` | shared |
| **`Status`** | — | **local** |
| **`FootageRunToDate`** | — | **local** |
| **`RemainingWeightEstimateLb`** | — | **local** |

⚠ **The refresh touches shared-mastered columns only, and this is why it is not a `MERGE`.** `Status` carries `INFLAT`, which is `FlatWireDB`-local since `D-32` — resetting it would un-mark a rod that is running. `FootageRunToDate` is the carry-forward evidence `PRC007` depends on; clearing it would silently offer a fresh-start check-in for a rod that has already run footage, which `FR-043` forbids. `DiameterIn` and `Location` are also left alone on refresh — the per-event measurements live on `RodStaging.DiameterIn` and `RodCheckin.DiameterMeasuredIn`, and staging overwrites `Location` with the payoff position.

⚠ **Two columns `coils` cannot supply.** There is **no rod-diameter column** — the nearest is `coil_gauge`, a *strip* gauge, and reading it as a wire diameter would be a convention dressed as a fact; the operator's measurement is used instead, which is itself an argument for projecting at first use rather than at receipt, since no measurement exists at receipt. And there is **no supplier-heat column** — see the note under `SupplierHeat` below.

⚠ **The alloy is a lookup, not a cast.** `coils.coil_alloy` is `smallint` and `Rod.Alloy` is `varchar(10)` holding `'1100'`. Storing the numeric code as text would not fail — it would silently stop every alloy comparison downstream from matching. *(This reads the table `AlloyProperty` shadows — `OI-93`.)*

> **`SupplierHeat` is left `NULL` on purpose — `OI-117`.** This document says above that the rod record *"links material certification data (supplier heat) to the finished output coil via `CoilTraceability`"*, and that is the welding-wire customer certificate chain, an MVP-1 obligation. But nothing sources it: `coils` has no heat column, no payload carries one, and `coil_origin_code` is a one-character origin flag rather than a heat number. `[INT §8]` lists *"`Lots` / chemistry — the far end of the cert chain — Read"* as the likely source, unmapped. **Trace it before a certificate is issued. Do not invent a value.**



---

## `RodOrderAllocation`

**The plan: which orders a rod is committed to, and in what sequence.** One row per rod-order
pairing. Its sibling `RodOrderConsumption` records what actually happened.

> **The split point is held in pounds, not feet.** Weight is conserved through drawing and
> rolling; footage is not - the same 900 lb is approximately 11,100 ft at FL1 gauge and 76,300 ft
> at FL2, a 7x cross-section difference. A rod-local footage figure cannot be compared with the
> line's counter without re-deriving through weight, so storing footage would invite the error it
> appears to prevent. Weight is also the client's own unit.

> **The split point is not a column.** The outgoing row's `RodWeightTo` *is* the incoming row's
> `RodWeightFrom`. `CK_RodOrderAllocation_WeightRange` asserts
> `RodWeightTo - RodWeightFrom = AllocatedWeightLb` as a **single-row** check, which exact
> `DECIMAL` arithmetic makes possible and the footage version could not express.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | - | Surrogate primary key, IDENTITY |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | The left side of the pairing |
| `OrderNo` | varchar(50) | NOT NULL | - | Shared-schema order. **No FK by design** (`D-32`) |
| `RelLetter` | varchar(10) | NULL | - | Release letter, mirroring `SpoolOrder.RelLetter` |
| `OrderSeqNo` | smallint | NOT NULL | - | This order's position in the station's queue; a shared rod's two rows differ by 1 here |
| `RodSeqNoInOrder` | smallint | NOT NULL | - | Planning's rod sequence **within** this order |
| `AllocatedWeightLb` | decimal(8,2) | NOT NULL | - | Pounds of this rod allocated to this order - planning's number, never derived |
| `RodWeightFrom` | decimal(8,2) | NOT NULL | - | Rod-local cumulative pounds, **inclusive** bound |
| `RodWeightTo` | decimal(8,2) | NOT NULL | - | Rod-local cumulative pounds, **exclusive** bound; the split point when a successor row exists |
| `PinRole` | varchar(12) | NOT NULL | - | **Stored, not derived** - the sequence validator reads it on every scan |
| `RodKind` | varchar(10) | NOT NULL | - | `Q73`'s tier-2 discriminator; `Partial` is a back-to-stock remainder |
| `Source` | varchar(15) | NOT NULL | - | Default `Planned` |
| `SupersededByAllocationId` | int | NULL | `RodOrderAllocation.Id` | Self-reference. Re-planning is **additive** |
| `IsActive` | bit | NOT NULL | - | `0` once superseded; the filtered indexes key on it. Default `1` |
| `CreatedBy` | varchar(50) | NULL | - | Audit |
| `CreatedAt` | datetimeoffset | NOT NULL | - | Default `SYSDATETIMEOFFSET()` |

**Allowed values - `PinRole`:** `Sole`, `PinnedFirst`, `Free`, `PinnedLast`, `PinnedBoth`
**Allowed values - `RodKind`:** `Full`, `Partial`
**Allowed values - `Source`:** `Planned`, `Derived`, `Substituted`

**Constraints:**
- `PK_RodOrderAllocation` - `Id`
- `CK_RodOrderAllocation_PinRole` / `_RodKind` / `_Source` - enumerating checks on the three vocabularies
- `CK_RodOrderAllocation_Weight` - `AllocatedWeightLb > 0`
- `CK_RodOrderAllocation_Seq` - `OrderSeqNo >= 1 AND RodSeqNoInOrder >= 1`
- `CK_RodOrderAllocation_WeightRange` - half-open **and** range-equals-allocation, in one check
- `UX_RodOrderAllocation_Active`, `UX_RodOrderAllocation_OrderRodSeq` - filtered unique, on `IsActive`

> **Rows are never mutated.** Re-planning inserts a replacement and sets
> `SupersededByAllocationId` plus `IsActive = 0` on the old row, so re-planning cannot
> retro-change what the floor was told at scan time.

> **Requirement source:** `ORD003`-`ORD017` in `[REQ]`. The design rationale is
> [`RodOrderAllocation.md`](../../../../LatestDocument/RodOrderAllocation.md) - cite it for *why*,
> not as a requirement.

---

## `SpoolProcessing`

Pre-drawn wire spool tracking. Spools are produced on FL1 in Hybrid route mode and subsequently checked in at FL2 or FL3 payoff positions. Each spool is identified by a unique alpha code and validated against its `SpoolConfiguration` constraints at check-in.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `Alpha` | varchar(20) | NOT NULL UNIQUE | — | Unique alpha identifier (e.g. `SP-00021`); scanned at FL2/FL3 check-in |
| `OrderNo` | varchar(50) | NULL | — | Manufacturing order number this spool is associated with |
| `RelLetter` | varchar(10) | NULL | — | Release letter designating the production release |
| `ParentRodAlpha` | varchar(20) | NULL | `Rod.Alpha` | Alpha of the wire rod coil that was drawn into this spool on FL1 |
| `SourceRodAlpha` | varchar(20) | NULL | `Rod.Alpha` | Partial-run source rod (Phase 7 / OQ-12); distinct from `ParentRodAlpha` |
| `SourceRunId` | varchar(20) | NULL | `FlatWireRun.RunId` | FK to the FL1 run that produced this spool; NULL if spool origin is external |
| `LineId` | varchar(5) | NULL | — | Line that produced or is currently processing this spool (`FL1`, `FL2`, `FL3`) |
| `OriginRouteMode` | varchar(15) | NULL | — | `Standalone`/`Hybrid` origin route; FL2 rejects a Standalone schedule on a Hybrid-origin spool (OQ-15) |
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

**Constraints:** `CK_SpoolProcessing_LineId` (`FL1`/`FL2`/`FL3` or NULL); `CK_SpoolProcessing_OriginRoute` (`Standalone`/`Hybrid` or NULL). Full status transition machine is OQ-17 (In Progress).

## `SpoolTraceability`

**Which rod produced which feet of a spool** - the spool-side half of the welding-wire genealogy
(`FR-333`, gap `G42`). One row per source rod segment wound onto a spool.

> **Footage here is spool-local, not run-cumulative**, and ranges are half-open `[From, To)`.
> **Weight is the primary quantity and footage is ours**: `SegmentWeightLb` is the client's field.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | - | Surrogate primary key, IDENTITY |
| `SpoolAlpha` | varchar(20) | NOT NULL | `SpoolProcessing.Alpha` | The spool this segment is on |
| `RodAlpha` | varchar(20) | NOT NULL | `Rod.Alpha` | This segment's source rod |
| `SeqNo` | smallint | NOT NULL | - | The order the material went **on**. `1` = first on |
| `SegmentWeightLb` | decimal(8,2) | NULL | - | Pounds this rod contributed. The client's field |
| `FootageFrom` | int | NULL | - | Spool-local, **inclusive** bound. NULL until a run supplies it |
| `FootageTo` | int | NULL | - | Spool-local, **exclusive** bound |
| `ChildAlpha` | varchar(20) | NULL | - | The segment's own alpha, e.g. `R00001C` |
| `WeldEventId` | varchar(20) | NULL | `WeldEvent.WeldEventId` | NULL on the first segment |
| `CreatedBy` | varchar(50) | NULL | - | Audit |
| `CreatedAt` | datetimeoffset | NOT NULL | - | Default `SYSDATETIMEOFFSET()` |

**Constraints:**
- `PK_SpoolTraceability` - `Id`
- `UQ_SpoolTraceability_Seq` - `(SpoolAlpha, SeqNo)` is unique
- `CK_SpoolTraceability_Seq` - `SeqNo >= 1`
- `CK_SpoolTraceability_Range` - both footage bounds NULL or both set, and `From < To`
- `CK_SpoolTraceability_Weight` - `SegmentWeightLb` NULL or `> 0`
- `UX_SpoolTraceability_ChildAlpha` - filtered unique

> **There is deliberately no non-overlap trigger, and that is the interesting decision.** The
> footage columns are **nullable**, and a trigger joining on `NULL` silently **passes** - the worst
> failure shape, because it looks enforced. The non-overlap rule therefore lives in the domain
> model (`FW-207`), alongside the "every spool has at least one row" invariant, which SQL cannot
> express either. Contrast `CoilTraceability`, whose footage is NOT NULL and which *does* carry
> `trg_CoilTraceability_NoOverlap` (DM010).

> **`ChildAlpha` and one namespace (`Q57`, 22 Aug 2026).** FL1 segment alphas and FL2 coil
> identities are the same strings off the same six-character root, minted through
> `CommonDB.dbo.GenerateCoilAlpha` with every prior segment alpha for the rod passed in
> `@CoilNoToIgnore` - read from **this table**, because `FlatWireDB` is outside that function's
> sweep. A local counter would hand the same string to a spool segment and to a finished coil.

> **`SeqNo` and last-on-first-off.** Under LOFO, `MAX(SeqNo)` is the lead alpha at FL2 - but
> `Q45` (unwind direction) is open, so **derive that in a query, never as a constraint.**

---

## `SpoolOrder`

The orders a spool's material is committed to. One row per spool-order pairing.

> **Derived, not allocated.** The order set is resolved **locally** from `RodOrderAllocation` as of
> 22 Aug 2026, superseding the earlier design that read the shared
> `united_db..planning_routings` rod-to-order allocation. That read was a **workaround written
> because the rod-to-order table did not exist**; it does now, and `D-32`'s reasoning removes a
> shared-schema read from the FL1 path.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | - | Surrogate primary key, IDENTITY |
| `SpoolAlpha` | varchar(20) | NOT NULL | `SpoolProcessing.Alpha` | The spool |
| `OrderNo` | varchar(50) | NOT NULL | - | Shared-schema manufacturing order. **No FK by design** (`D-32`) |
| `RelLetter` | varchar(10) | NULL | - | Release letter, mirroring `SpoolProcessing.RelLetter` |
| `SeqNo` | smallint | NULL | - | Planned consumption order, if planning supplies one |
| `PlannedWeightLb` | decimal(8,2) | NULL | - | Weight allocated to this order, if allocated rather than derived |
| `SpoolWeightFrom` | decimal(8,2) | NULL | - | Spool-local cumulative lb, **inclusive** - the order boundary |
| `SpoolWeightTo` | decimal(8,2) | NULL | - | Spool-local cumulative lb, **exclusive** |
| `Source` | varchar(15) | NOT NULL | - | Default `Derived` |
| `CreatedAt` | datetimeoffset | NOT NULL | - | Default `SYSDATETIMEOFFSET()` |

**Allowed values - `Source`:** `Derived` (union of the rods' orders, computed at spool creation),
`Planned` (an explicit planning allocation that supersedes the derived row)

**Constraints:**
- `PK_SpoolOrder` - `Id`
- `UQ_SpoolOrder_Key` - `(SpoolAlpha, OrderNo, RelLetter)` unique. **`RelLetter` is `ISNULL`-ed into
  the key** rather than relying on SQL Server's single-NULL-per-key behaviour
- `CK_SpoolOrder_Source` - enumerating check
- `CK_SpoolOrder_Weight` - `PlannedWeightLb` NULL or `> 0`

> **`SpoolWeightFrom`/`To` are the order boundary, and they close gap `G48`.** The client confirmed
> on 20 Aug 2026 that a spool off FL1 may carry two or more orders while **FL2 makes one order at a
> time** - so FL2 must cut at the boundary, and without these columns nothing tells it where. Held
> in **pounds**, half-open, matching the rod-to-order split for the same conservation reason.

---
