# Flat Wire Mill — Integration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `03-HLD-and-ERDiagram.md`, `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Cross-database touchpoints and the shared-schema renames
**Status:** Baselined for build
**Owner:** Architecture stream
**Audience:** Architects, .NET developers, DBA
**Shortcode:** `[INT]`
**Part of:** `ProjectPlan/Architecture/` — index: [README.md](../README.md)

---

## 8. Cross-database touchpoints

`FlatWireDB` is authoritative for flat-wire-specific entities. The named legacy integration points in the **shared** databases are still written so scheduling, planning, reporting, cost and yield keep working without regression.

| Shared object | Database | Written when | Direction | Enforcement |
|---|---|---|---|---|
| `coils.coil_status = INFLAT` | shared | At check-in acknowledgement **only** — *not* at pre-check-in (OQ-68, decided 30 Jul 2026); **cleared** on checkout, run completion or WIP rejection | **Write** | Unenforced — compensating write |
| `coils` R-series row | shared | At rod receipt | **Read** | Mirrored into local `Rod` (**OI-42**) |
| `wip_coil_orders` | `proddb` | Reqsum entry at check-in if the rod is not yet reqsummed | **Write** | Unenforced |
| `planning_routings` / `routings`.`actual_start_date` | shared | Updated at check-in | **Write** | Unenforced |
| `planning_routings` rod→order allocation | shared | By Planning | **Read** | The scan resolves its order from here |
| `wip_stations.coilno` | `CommonDB` | On successful check-in | **Write** | Unenforced; `WIPStations` has a UNIQUE index on `CoilNo` |
| `machines` FL1/FL2/FL3 | `united_db` | One-time registration (FW-003) | Seeded | machine_idx **125/126/127**, fixed so DEV/TEST/PROD agree |
| `alloys.alloy_density` | `united_db` | Maintained by the Alloys module | **Read** | Via a `FlatWireDB..Alloys` view (§6.6) |
| `alloys.Draw_max_reduction` | `united_db` | Maintained by the Alloys module | **Read** | Via the same view |
| skid table | existing | `CoilOutput.SkidId` points at it | Reference | No local FK |
| `Lots` / chemistry | shared | The far end of the cert chain | **Read** | — |

**WIP station registration** creates `FL1`, `FL2`, `FL3`, **`FL1PO`** (the Pre-Check-In station, sharing FL1's MachineIdx, same pattern as legacy `ZR23`/`ZR23PO`) and `FWPACK` (packing, MachineIdx NULL by design because it serves all three lines). **`FL2PO` is deliberately not created.** **There is no `FL3PO`** — working assumption is that FL3 posts to `FL1PO` (**OI-26**).

Script constraints worth knowing before running it: `machines.machine_idx` is **not** an IDENTITY; `machines.status` must be `1` or the machine is invisible to the `CommonDB.dbo.Machines` view; an idle station parks **its own station name** in `CoilNo` as a guaranteed-unique placeholder; `WIPStation` is space-padded to 6 characters and `PrinterName` to 12.

> **`machine_type` is undecided**, and `AccountingDB.dbo.GetMachineTypeFromOpLetter` has **no case for the flattening letter `F`** — it returns NULL for flat wire today regardless of which type is chosen. **OI-27.**

**FW-001 renames** and their blast radius: see `[INT §9.5]` and the rollback treatment in `[RB §6.3]`.

---

---

### 9.4 Cross-database touchpoints

| Shared object | Database | Written when | By this module? |
|---|---|---|---|
| `coils.coil_status = INFLAT` | shared | At check-in acknowledgement; **cleared** on checkout, run completion or WIP rejection | **Yes** |
| `coils` R-series row | shared | At rod receipt | No — **read only** |
| `wip_coil_orders` | `proddb` | Reqsum entry created at check-in if the rod is not yet reqsummed | **Yes** |
| `planning_routings` / `routings`.`actual_start_date` | shared | Updated at check-in | **Yes** |
| `planning_routings` rod→order allocation | shared | By Planning | No — **read** (this is how a scan resolves its order) |
| `wip_stations.coilno` | `CommonDB` | Updated on successful check-in | **Yes** |
| `machines` FL1/FL2/FL3 | `united_db` | One-time registration (FW-003) | Seeded once |
| skid table | existing | `CoilOutput.SkidId` points at it | Referenced |
| **`alloys.alloy_density`** | `united_db` | Maintained by the Alloys module | **Read** — the authoritative density for all weight derivation |
| **`alloys.Draw_max_reduction`** | `united_db` | Maintained by the Alloys module | **Read** — the pass-schedule generator's draw-pass input |
| `Lots` / chemistry tables | shared | The far end of the cert chain | Read |

**WIP station registration** creates `FL1` (machine_idx 125), `FL2` (126), `FL3` (127), **`FL1PO`** (the Pre-Check-In station, sharing FL1's MachineIdx) and `FWPACK` (packing, MachineIdx NULL by design). **`FL2PO` is deliberately not created** — FL2 is excluded from pre-check-in. **There is no `FL3PO`**; the working assumption is that FL3 posts to `FL1PO` — **OI-26**.

> `AccountingDB.dbo.GetMachineTypeFromOpLetter` has **no case for the flattening letter `F`** and returns NULL for every flat-wire operation today, regardless of which `machine_type` is chosen — **OI-27**.

---

### 9.5 FW-001 — the shared-schema renames

Story **FW-001** applies **slash dual-naming** renames to the **existing shared scheduling / `coils` schema** — not to `FlatWireDB`.

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

**New columns:** `OutgoingCoil/BundleWidth`, `IncomingWireDia`. **New status value:** `INFLAT`. **New machine rows:** FL1, FL2, FL3. **New operation letter:** `F` in `PrevOpLetter`, `RemainingOps`, `RootRemainingOps`, `OpLetter`.

**This is the single highest-blast-radius change in the project.** These columns are read by upstream receiving, planning, scheduling, reporting, yield and cost. A **full stored-procedure / view / report / query audit must precede the migration** (40 h costed in Phase 1C), with a regression pass at QA4. Rollback treatment in `[RB §6.3]`.

---
