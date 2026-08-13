# Flat Wire Mill — Implementation Plan

**Project Status:** Active Development — Pre-Trial Phase
**Last Updated:** April 28, 2026
**Working Directory:** UAL Manufacturing Execution System
**Phase:** Phase 1 (Critical-path go-live scope)

> ### ⚠ FM2 equipment configuration in this document is superseded (4 Aug 2026)
>
> **FM2 has three stands: `S1` = 8″, `S2` = 6″, `S3` = 6″.** Edgers are at **S2 and S3 only**, and **S3 is the final, non-bypassable gauge-control stand**.
>
> Every FM2 description below is stale in one of two ways — either the pre-May-21 **two** 6″ stand form (`8" → 6"S1 → 6"S2`, S2 final), or the four-component form that read the May 21 note as a separate 8″ roller feeding three 6″ stands. **The 8″ roller *is* S1**, and there is no fourth stand. Component identifiers are now position-only — `FM2_S1` / `FM2_S2` / `FM2_S3` — with roll diameter held as data in `Stand.RollDiameterIn`.
>
> **Authoritative source: [`00-foundations.md`](../MVP-1/ProjectPlan/ShopfloorPlan/00-foundations.md) §0.3**, decision **D-26** in [`FlatWire_MasterSpecification.md`](../LatestDocument/FlatWire_MasterSpecification.md) §10.2. Do not implement FM2 from this file.

---

## Overview

United Aluminum is adding a Flat Wire manufacturing capability to its production floor, consisting of three new Flattening Lines (FL1, FL2, FL3). This initiative requires coordinated changes across the full UAL software stack: .NET web applications, shopfloor system, scheduling database, machine configuration, reporting, WIP/rejection tracking, yield accounting, cost ledger, scrap sales, and a new Rod Receiving module.

The flat wire process converts aluminum rod into flat wire through wire drawing and controlled rolling. The three lines can operate independently (FL1 only, FL2 only) or in a continuous hybrid mode (FL1 feeding directly into FL2 without intermediate anneal). All new lines must be integrated as first-class entities across every applicable module.

**Pass Schedule** is the central control concept for this system — it determines which components are active or bypassed, die and edge configurations, roll clearances, and gauge/width targets. It is the most critical dependency for the entire solution.

**Phase 1 scope focus:** Critical-path functionality required for the July 1 trial date. Non-blocking features are deferred.

---

## Goals

- Receive aluminum rod material (new Rod Receiving module, distinct from coil receiving).
- Build and maintain a Pass Schedule database defining component configuration per product route.
- Register FL1, FL2, and FL3 as fully configured machines within the UAL Machines application.
- Extend the scheduling and planning systems to handle flat wire orders and rod material.
- Modify all relevant web screens to capture flat wire-specific attributes (Bundle Width, Edge Type, Material Type).
- Provide a complete reporting suite (Gauge Trace, Gauge CPK, SPC, Coil Pass Detail, Rolls in Flattening) for the new lines.
- Integrate flat wire into coil yield, cost ledger, and scrap sales workflows.
- Ensure full traceability of flat wire bundles through welding, form changes, and multi-pass operations — particularly for welding wire customers.

---

## Project Timeline

| Milestone | Target Date |
|-----------|-------------|
| Machine setup and PLC commissioning complete | End of June 2026 |
| Flat wire trials begin | July 1, 2026 |
| Production start | August 1, 2026 |
| Effective software development window | ~10 weeks |

> Development must prioritize critical-path features. Non-blocking functionality should be identified early and deferred to a post-go-live release.

**Key decision from April 16 meeting:**
- No Angular/frontend receiving changes in Phase 1.
- No EDI in Phase 1 — manual rod receiving only.
- One shared UI for FL1 and FL2 check-in and transactions.
- PLCs are new hardware; OPC servers remain unchanged.

---

## Process & Equipment Overview

### Physical Process Flow

```
VPS Payoff (9,000 lb max) — dual position, eye-to-sky orientation
    └─> Entry Guide
        └─> DB1 (Wire Drawing Die 1 — can be bypassed)
            └─> DB2 (Wire Drawing Die 2 — can be bypassed)
                └─> FM1 (12" Flattening Mill, TKUP-1, 3,500 lb)
                    │   [Gauge stands + dancer/edger]
                    │
                    ├─ [Non-hybrid] ──> TKUP-1 (Traversing Take-up, 3,500 lb)
                    │                       └─> Optional Anneal
                    │                           └─> TPO (Traversing Payoff, 3,500 lb)
                    │
                    └─ [Hybrid] ──────> TPO feeds directly into FM2
                                            └─> FM2: 8" Roller (skippable)
                                                └─> 6" Roller S1 (skippable)
                                                    └─> Edger
                                                        └─> 6" Roller S2 (cannot skip)
                                                            └─> Edger
                                                                └─> TKUP-2 (1,100 lb)
```

### Machine Summary

| Machine | Description | Incoming Material | Capacity | Notes |
|---------|-------------|-------------------|----------|-------|
| VPS | Dual-position payoff reel | Rod / Round Wire | 9,000 lb max | Eye-to-sky orientation; dual position for welded continuous operation |
| DB1 / DB2 | Wire drawing dies | Rod / Round Wire | — | Can be bypassed via pass schedule |
| FM1 | 12" Flattening Mill + TKUP-1 | Round Wire | 3,500 lb (TKUP-1) | Includes gauge stands, dancer, edger |
| TPO | Traversing Payoff | Flat Wire (from TKUP-1) | 3,500 lb | Feeds FM2 in non-hybrid; direct feed in hybrid |
| FM2 (8") | 8" Roller | Flat Wire | — | Can be skipped |
| FM2 (6" S1) | 6" Finishing Roller — Stand 1 | Flat Wire | — | Can be skipped |
| FM2 (6" S2) | 6" Finishing Roller — Stand 2 | Flat Wire | — | Cannot be skipped |
| TKUP-2 | Traversing Take-up | Flat Wire | 1,100 lb | Final output collection |
| FL1 | Flattening Line 1 (VPS → TKUP-1) | Rod or Round Wire | — | Standalone or hybrid entry |
| FL2 | Flattening Line 2 (TPO → TKUP-2) | Flat Wire (spool-based) | — | Standalone or hybrid continuation |
| FL3 | Hybrid mode (FL1 + FL2 continuous) | Rod or Round Wire | — | Continuous operation; no intermediate anneal |

### Material Reduction Paths

| Start Material | End Material | Notes |
|----------------|--------------|-------|
| A-Rod | Flat Wire | Direct rod-to-flat route via FL1 (or FL3 hybrid) |
| Round Wire | Flat Wire | Post-draw flattening |
| Flat Wire | Flat Wire | Subsequent flattening passes to control width |

Process example: Rod → Round Wire → 1st Flat → (Optional Anneal) → Subsequent Flats to Control Width

### Final Product

- Output form: **coreless oscillated coils**.
- Packaging: **2 coils per skid** — consistent with UA's existing coil packaging behavior.

### Welding & Continuous Operation

- **Induction welding:** Used for rod-to-rod joins at the payoff (enables continuous operation without stopping the line).
- **Laser welding:** Used for flat-to-flat joins (optional).
- When a rod on Payoff 1 nears its end, the operator welds the beginning of a new rod from Payoff 2 — creating a continuous feed.
- The system must maintain traceability through weld points, tracking which source rods contributed to which output material.

---

## Process & Traveler Design

### Per-Line Material Flow

| Line | Incoming Material | Input Form | Output Form | Gauge Trace Mode |
|------|------------------|------------|-------------|-----------------|
| FL1 | Rod or Round Wire | Coil / bundle | Flat Wire spool (TKUP-1) | **Real-time** |
| FL2 | Flat Wire | Spool (from TPO) | Coreless oscillated coil (TKUP-2) | **Historical / profile view** |
| FL3 | Rod or Round Wire | Coil / bundle | Coreless oscillated coil (continuous) | **Real-time** |

### Spool vs. Coil Handling & Traceability

- FL2 accepts **spool-based flat wire input** (loaded onto TPO) and produces a **coreless oscillated coil** as output.
- FL1 and FL3 both handle rod or round wire input at the VPS payoff.
- FL3 (hybrid) bypasses the TKUP-1 intermediate collection step — material flows continuously from FM1 into FM2.
- Traceability must be maintained across form changes: rod → spool → coreless coil.
- Final packaged output: 2 coreless oscillated coils per skid.

### Traveler Screen Design

- One shared UI for FL1 and FL2 check-in and transactions (confirmed April 16 meeting).
- Each station requires a traveler screen capturing the relevant fields for that station.
- Use **generic labels** where possible — for example, use **"Incoming Bundle Information"** rather than line-specific field names.
- **Terminology rule:** Use **"flat wire"** consistently throughout all screens and reports. Do not use "strip."
- **Digital traveler only (decided Apr 28, 2026):** Flat wire uses a fully screen-based traveler. No printed traveler in Phase 1. Traveler data is generated and stored for display and audit purposes. Printing is disabled for flat wire operations. The business team strongly supported this approach during the Apr 28 UI walkthrough.

### Gauge Trace Behavior by Line

| Line | Mode | Detail |
|------|------|--------|
| FL1 | **Real-time** | Live gauge measurement captured during active processing |
| FL2 | **Historical / profile view** | Gauge profile available when material is checked into FL2; not live |
| FL3 | **Real-time** | Same as FL1 (continuous hybrid — no intermediate check-in) |

### SPC Checkpoints

| Checkpoint | Stage | Type |
|-----------|-------|------|
| Incoming rod diameter | Pre-check-in (before VPS) | Manual / measured |
| Post wire-draw diameter | After die changes (DB1/DB2) | Manual at setup/die change |
| After 12" mill (FM1) | Gauge and width | Automatic (AGC) during run |
| After 6" finishing mill (FM2 S2) | Gauge and width | Automatic (AGC) during run |

- Automatic gauge readings are "set-and-forget" during production runs.
- Manual SPC is primarily performed at initial setup or after die changes.
- Sampling rules vary by customer and process stage.

---

## Scope of Changes

### 1. Pass Schedule

**Criticality: Highest — blocks machine check-in, PLC updates, and shopfloor operation.**

The Pass Schedule is the master configuration record that defines exactly how the flat wire line is set up and operated for a given product route. It is the central control mechanism that drives both machine behavior and system logic. It is not auto-generated — it is manually maintained by Operations/Maintenance, similar to the existing Early Screen.

#### What the Pass Schedule Controls

| Category | Detail |
|----------|--------|
| **Component Active/Bypass** | Which stages are ON or OFF: DB1, DB2, FM1-S1, FM2-8", FM2-6"S1, FM2-6"S2 |
| **Die Configuration** | Die size assigned to each active wire drawing stage (DB1, DB2) |
| **Edge Set** | Edge configuration (Round Edge vs. Flat Edge) |
| **Roll Clearances** | Gap settings per roll stand |
| **Gauge & Width Targets** | Target output thickness and width per pass |
| **Route Mode** | Whether the run is standalone (FL1 only, FL2 only) or hybrid (FL1 → FL2 continuous, i.e., FL3) |

#### Why It Is the Highest-Priority Dependency

Every downstream system action depends on the pass schedule being defined first:

1. **Operator check-in** — Operator must acknowledge the pass schedule before the line can start.
2. **PLC update** — The system reads the pass schedule and pushes the correct tag values to the machine's PLC automatically.
3. **Machine behavior** — The PLC drives component activation, speed, and gap settings based on those pushed tags.

Without a finalized pass schedule, none of the shopfloor check-in flow, PLC integration, or machine configuration work can proceed.

#### What It Is NOT

- It is **not auto-generated** by the software. It is manually created and maintained by Operations/Maintenance.
- It is **not part of the item template** — it is applied after planning, when a job is actually being set up on the line.
- It does **not control width** during item template creation — width control is a pass schedule concern, not a template concern.

#### Physical Process Example

A pass schedule for a rod-to-flat-wire hybrid run might define:

```
DB1: ACTIVE — 0.250" die
DB2: BYPASSED
FM1 (12" mill): ACTIVE — 0.020" gauge target, 0.500" width target
FM2 8" roller: ACTIVE
FM2 6" S1: BYPASSED
FM2 6" S2: ACTIVE (cannot be bypassed)
Edge type: Flat Edge
Route mode: Hybrid (FL3)
```

The system takes that configuration, sends it to the PLC, and the machine runs accordingly — the operator does not manually configure each component at the machine.

#### System Behavior at Check-in

1. Operator acknowledges the pass schedule for the incoming material.
2. System reads the pass schedule and pushes updated PLC tags to the machine.
3. Machine behavior is driven dynamically from the pass schedule.

> PLC tags are only pushed **after** the operator explicitly acknowledges the pass schedule. No automatic push occurs.

#### Database Requirement

A **Pass Schedule database** is required to store these records. It is not a calculation engine — it is a lookup/configuration store that operators build and maintain, and that the shopfloor system queries at check-in time.

- A Pass Schedule database is required (not a generator).
- Pass schedule is applied after planning, not during item template creation.
- Width control is handled via the pass schedule, not the item template.
- Tim O. is working on the pass schedule system layout and database structure.

---

### 2. Rod Receiving (New Module)

Rod is received as bundles from vendors. This is a **new receiving workflow** distinct from coil receiving — no width field, different validation rules, and a new numbering format.

#### Rod Number Format

- Pattern: `R` + 5-digit sequence (e.g., `R00001` through `R99999`)
- Incremented by 1 per received rod per lot number; no gaps.
- Historical R-series data archived in the coils table.

#### Receipt Scenarios

| Scenario | Process |
|----------|---------|
| Non-EDI (Phase 1) | Operator enters: Purchase Order number, diameter, net weight, gross weight |
| EDI (deferred to Phase 2) | System reads EDI; operator measures gross weight on scale and compares to EDI weight |

- Only the PO number needs manual entry; remaining parameters are pulled from the PO.

#### Validations

| Rule | On Failure |
|------|-----------|
| Scale weight within tolerance of vendor gross weight | Material suspended |
| Rod chemistry documentation present | Material suspended if missing |
| Width field | Not applicable — rods have no width |

- Lot number generation logic requires updates.
- Suspend Coil logic: All existing rules apply **except** width-related rules.
- Coils table entry for a rod: Gauge populated, Width blank, Surface Finish blank, Coil ID and OD blank, Inventory type TBD.

#### Pre-Check-in Visual Inspection

- Operator inspects for: oxidation, surface defects, water stains.
- Bundles are **not unbanded** until positioned at the payoff (safety and bundling integrity).
- If inspection passes: Display and acknowledge pass schedule → update PLC.
- If inspection fails: Add observation and submit WIP rejection (same flow as existing coil rejection).

#### Print Labels
- Label format: To be determined.

---

### 3. Machines Application

**New Machines to Add:** FL1, FL2, FL3 (each with a unique `MachineId`/`IdNo`)

The machine template for each flattening line is a hybrid of the existing Slitter and Mill templates. Required tabs:

| Tab | Source | Notes |
|-----|--------|-------|
| Main | Combined | Standard machine metadata; certain rows from Slitter plus additional rows from Mill |
| Roll Finish | Mill template | Copy as-is |
| Pass Schedule | Mill template | Rename button "Mill Schedule" → "Flattening Line Schedule"; update window header |
| Coating | Slitter template | Copy as-is |
| KSI / Gauge Max Cuts | Slitter template | Remove "Max # of Cuts" column |
| Rewind Capabilities | Slitter template | Retained for future applications |
| ID Width Max Cuts | Slitter template | Copy as-is |
| Setup / Handling Times | Slitter template | Copy as-is |
| Tooling Inventory | Slitter template | Add **Dies** and **Edgers** as new tooling types; Tim O. to create profile sheets for each |
| Speed | Mill template (modified) | Rename "Min/Max Gauge" → "Min Gauge/Diameter" / "Max Gauge/Diameter"; add checkboxes for DB1, DB2, FM1-S1, FM2-S1, FM2-S2, FM2-S3 to mark active/inactive components per alloy-width-gauge row |
| Material Loss | Mill template (modified) | Scrap calculated in **footage** (not weight), scenario-based; profile terminology TBD |
| History | Combined | Merge Mill + Slitter history attributes |

**Throughput / Reporting Buckets:** Slitter template used as base; filter categories and reporting buckets modified for flattening operations. Naj, Bob, and Tim are building a standards specification spreadsheet defining all FL attributes.

---

### 4. Scheduling System (Database & UI)

#### Operation Identifier
- Use the letter **`F`** for flattening operations in: `PrevOpLetter`, `RemainingOps`, `RootRemainingOps`, `OpLetter`.

#### New Coil Status
- Add status **`INFLAT`** — material currently in a flattening operation.

#### UI Changes
- Add a **Flattening Lines** tab alongside existing tabs, listing machines FL1, FL2, FL3.

#### Database Column Renames

| Current Column | New Column |
|----------------|------------|
| `CoilNo` | `Coil/BundleNo` |
| `SlitWidth` | `Slit/FlatWidth` |
| `IsCampaingCoil` *(typo corrected)* | `IsCampaignCoil/Bundle` |
| `CoilLocation` | `Coil/BundleLocation` |
| `CoilWeight` | `Coil/BundleWeight` |
| `CoilStatus` | `Coil/BundleStatus` |
| `OutgoingCoilId` | `OutgoingCoil/BundleId` |
| `OutgoingCoilOd` | `OutgoingCoil/BundleOd` |

#### New Database Columns

| Column | Purpose |
|--------|---------|
| `OutgoingCoil/BundleWidth` | Flat wire width output |
| `IncomingWireDia` | Incoming wire diameter |

#### MachineId
- Add FL1, FL2, FL3 with unique `IdNo` values for each.

---

### 5. Planning System Changes

#### Filter Dropdown
- Add a filter dropdown in the gray or blue header area of the planning screen.
- Options: `All` | `Regular` | `Back2Back` | `Flatwire`
- Default: `All`

#### Available Coils Section (when flat wire order is selected)
- Column header "CoilNo" → **"Coil/Bundle No."**
- Column header "Gauge" → **"Gauge/Diameter"**
- Section shows only material relevant to the selected order's item template (same behavior as current coil flow).

#### Material Drop Pop-up (when material is assigned to an order)
- **Remove:** "Number of Cuts" and "Number of Stops" fields.
- **Add:** "Weight" field — planner enters total weight being assigned to the order.
- System **automatically computes** number of stops and generates **alphas at planning time** (not dynamically during execution). Orders exceeding single-rod/spool capacity are split into multiple stops; each stop receives its own alpha.
- Last stop of a multi-stop order may contain multiple alphas.
- **"Assign as-is" option** — when material remains after order fulfilment, planner can check "Assign as-is" to return the remainder to stock (wire rod or flat wire inventory). This option is enabled only when remaining weight exists.
- System automatically generates a remainder alpha for the unused portion returned to the warehouse.

#### Pattern Display
- The rectangular pattern picture (bottom-left of planning screen) is **replaced** — it does not apply to flat wire.
- **Replacement:** A tabular grid showing:
  - Order → Spool → Weight allocation per stop
  - Alpha reference per stop
  - Remaining weight disposition (assigned to order or returned to stock)

#### Spool-to-Order Allocation Scenarios (Confirmed Apr 28, 2026)
The system must support all three core scenarios:
1. Entire spool → single order
2. Partial spool → order + remaining to stock
3. Single spool → multiple orders

Future extensibility for pre-processing stock runs is required but not in Phase 1 scope.

---

### 6. .NET Web Application Changes

#### Orders & Quotes Screens
- Add **"Flat Wire" checkbox**.
- When checked, show mandatory field **Bundle Width** (Min/Max range).
- Add **Edge Type** dropdown: `Round Edge` | `Flat Edge`.
- Auto-populate pricing: method TBD.
- Finish field locked (read-only) — no user edits for now (Tim O. decision).

#### Search Customers Screen
- Rename the existing "Type" dropdown; add option **"Flat Wire"**.
- Color-coding: Green = B2B, **Pink = Flat Wire**.

#### IQR / Item Section
- Add **"Flat Wire" checkbox**.
- Add **Bundle Width** field (Min/Max range, mandatory when Flat Wire is selected).
- Add **Edge Type** dropdown (`Round Edge` | `Flat Edge`).
- When Flat Wire is selected, auto-set the "Edge" critical attribute to **"5 - Edge not a consideration"**.
- Show only specifications corresponding to the flat wire option when selected.

#### Item Template / SMP Creation
- Auto-populate included/excluded vendors based on manufacturing alloy and Vendor O Gauges.
- Add two new columns to the process creation flow: **Type** and **Shape**.
- Item template supports step-level input/output type and shape for multi-stage flexibility.

#### Alloys Module

| Sub-Section | Change Required |
|-------------|-----------------|
| Properties tab | Add **Material Type** dropdown (values: Coils, Flat Wire, etc.) |
| Reduction Rules tab | Add **Material Type** dropdown; split view: "Coils – Reduction Rules" vs. "Rod/Wire – Reduction Rules" |
| Anneal Cycle | Add new anneal cycle entry for flat wire |
| Vendor O Gauge | Add same **Material Type** dropdown; split view: "Coils – Vendor O Gauges" vs. "Rod/Wire – Vendor O Gauges" |
| Gauge CPK Report | Add filter dropdown: `Strip` / `Flat Wire` / `All` |

#### Vendor Maintenance
- Add **"Flat Wire" checkbox** (positioned between existing Reroll and Scrap checkboxes).

---

### 7. Reporting & WIP / Rejection

#### Priority Key
- **High** — Required for go-live.
- **Medium** — Required for pre-trial.
- **Low** — Can be deferred post go-live.

#### WIP Log *(Low)*
- Add FL1, FL2, FL3 to the **Station** dropdown.
- Add a hyperlink to Mill Reports (Gauge Trace) — consistent with the existing SCADA hyperlink pattern.

#### New Flattening Lines Report Tab *(High)*
- Add a **Flattening Lines** tab under .NET Reports, modeled on the existing Slitter Reports tab.
- Display all three machines (FL1, FL2, FL3); clicking a machine opens its associated reports.

**Reports under Flattening Lines tab:**

| Report | Priority | Source | Modifications |
|--------|----------|--------|---------------|
| Gauge Trace | High | Slitter Reports | Rename "Gauge" → "Gauge/Diameter"; remove "# Cuts" column. FL1 & FL3: real-time view. FL2: historical/profile view when checked in. |
| Gauge CPK Deviation | High | Slitter Reports | Same rename as above |
| Gauge CPK Report | High | Slitter Reports | Add filter dropdown: `Strip` / `Flat Wire` / `All` |
| Coil Pass Detail | High | Mills | Adapt all attributes for flat wire; UA to provide template |
| SPC at Flattening Line | High | SPC at Mill | Add FL1/FL2/FL3 dropdown |
| Cut Traceability Report | High | Existing | Alpha position terminology (ID/OD/MID); "Cut #" columns not required |
| Rolls in Flattening Report | Low | Rolls in Mill Report | Modify for flattening-specific attributes |
| Rolls Qualification Sheet | Low | — | Need to determine if applicable to flat wire |

#### SCADA Report *(Medium)*
- UA team to define the chart layout.
- Machine tags and required columns to be determined.
- System must read live tags from the machine.

#### WIP REJ Report *(Low)*
- Column updates required (specific columns TBD by Shannon R.).
- Shannon R. to add rejection reasons to applicable existing groups.

---

### 8. Coil Yield & Cost Ledger

#### Coil Yield
- **Traceability** required for welding wire customers.
- **Standard times** must be defined for FL1, FL2, and FL3 for accurate yield calculation.
- Weight tracking must support on/off operations (start and end weight per pass).
- Output weight is calculated via **length** (not scale weight) during production.
- Field renames:
  - "Outgoing Gauge" → **"Outgoing Gauge/Diameter"**
  - "Coil #" → **"Coil/Bundle #"**
  - "Gauge" → **"Gauge/Diameter"**
- Add **"Flat Wire" checkbox** to the yield form.

#### Cost Ledger
- Ability to report wire separately, similar to the existing B2B capability.
- Costing standards for aluminum wire to be defined and applied.
- Industry code question: Confirm whether existing codes (e.g., 510 = Flat Fin, 530 = Spiral Fin Hudson) apply regardless of routing (pancake, tolled, flat wire), or if new codes are needed.

---

### 9. Scrap Sales

- Wire rod scrap: placed in **scrap boxes**, then baled into scrap units.
- FL1 / FL2 scrap handling: mirrors existing slit material procedures.
- Out-of-spec wire bundles: compacted using the baler.
- **New outlet selection** required in the Scrap module: `Scrap Box` vs. `Scrap Skid`.
- Banding materials: confirm whether steel or aluminum alloy banding is used.
- Combining flat wire scrap with other scrap types: confirmed compatible by Ryan B.
- Scope: changes apply to Flat Wire, Conveyors, and Inspection systems.

**Baler question to resolve:** Maximum dimensions the baler can accept.

---

## Application Impact Tracker

The following table reflects the known application scope tracked as of April 17, 2026. Priority and status per the `New Flat Wire Machine - Impact on Applications 041726.xlsx` tracker.

| Application | Priority | Type | Key Stakeholders | Notes |
|-------------|----------|------|-----------------|-------|
| Coil Receiving (Rod) | Pre-Trial | Shopfloor / Web | Laureen, Chuck, Sal, Henry | Receive rod with or without EDI |
| Pass Schedule | Production | Web | Tim O., RN | Central control; Tim O. working on layout |
| Flat Wire Machine (Shopfloor UI) | Production | Shopfloor | Tim O., RS, STR, JG, KG | New screen(s); capture Gauge Trace, Width Trace, weld traceability |
| Orders | Production | Web | Sales: Laura G., Ron F. | Add flat wire flag |
| IQR | Production | Web | Sales, Technical, STR, RS | Add flat wire flag |
| Item Template / SMP Creation | Production | Web | Mick, Ryan, Fabian, Sri, Tim | |
| Planning Application / Algo | Production | Web | Margo, Gavin, Brian R. | Ability to plan orders with rod |
| Scheduling Application / Algo | Production | Web | Stephen | Manual and algo scheduling with rod |
| Reports (Throughput, Gauge, Width, SPC, Camber) | Pre-Trial | Web | Tim O., RS, STR, Bill P. | |
| Machines | Pre-Trial | Web | STR, RS, Bill P., MF | New machine capabilities |
| Alloys | Pre-Trial | Web | Mick, Ryan B., Fabian, STR | Material Type, reduction rules split |
| Anneal — Rod/Wire | TBD | Shopfloor / Web | Dan F. | Loading rules; needed for scheduling algo |
| Packing | N/A | Shopfloor | Tim O., RS, STR | Pack specs, weight capture; no Inspection Bench changes expected |
| Pack Specs | N/A | Shopfloor / Web | Sales, Tim O., RS, STR | Eye-to-side or eye-to-sky specs |
| Coil Yield / Cost Ledger | Medium | Web | Jeff G., Ken G. | |
| WIP Rejection | Pre-Trial | Shopfloor / Web | STR, RS | |
| Vendor Maintenance | Pre-Trial | Web | Laureen, Chuck, Sales | Add Flat Wire checkbox |
| MPS | Pre-Trial | UA Icon | Laureen, Chuck | 3D spec procurement (gauge × diameter × length/weight) |
| Storage Area for Rods | N/A | Shopfloor | Ryan D., Chuck | Working with Naj & Bob on layout & flow |
| Labels (footage) | TBD | Shopfloor | RS, SP, Darlene | Possibly new label formats; tolling labels TBD |
| DEEP (data collection) | TBD | Data Collection | Pat, Tim O., Ralph | Depends on solution used for drawing/mill lubricating |
| Quotes | Production | Web | Sales: Laura G., Ron F. | Add flat wire flag |
| Certs | N/A | Web | Mick, Fabian, Ryan B. | Unlikely to require changes |
| Scrap & Sales | Low | UA Icon / Web | Laureen, Chuck | Scrap box vs. scrap skid outlet selection |
| EDI | Low | EDI | Laureen, Chuck, Sal, Joe | Phase 2 — not required for go-live |

---

## Key Stakeholders

| Name | Role / Responsibility |
|------|-----------------------|
| Tim O. (Tim O'Brien) | Requirements lead, process owner, pass schedule design |
| Shannon R. | Web changes, WIP/REJ configuration, rejection reasons |
| Bob S. (Bob Scott) | Standards definition, throughput specs |
| Naj | Building FL attributes standards spreadsheet |
| Bill P. | Process involvement, machine configuration |
| Ryan B. | Confirmed scrap combining compatibility; Alloys module |
| Srikanth Prabhala | Systems / development lead |
| Jaspreet Singh | SRS authoring, receiving and shopfloor design |
| Waseem Khan | Development team |
| Ritika Raheja | Development team |
| Vicky Arora | Development team |
| Sushant | Development team |
| Laureen / Chuck | MPS, coil receiving, vendor, EDI |
| Margo / Gavin / Brian R. | Planning application and algorithm |
| Stephen | Scheduling algorithm |
| Jeff G. / Ken G. | Coil yield, cost ledger |
| Dan F. | Anneal — rod/wire |

---

## Milestones

> Specific development task dates are not yet assigned. Dates below are business targets from the April 16 meeting and the Impact Tracker.

1. **Standards Spec Complete** — Naj/Bob/Tim finalize the FL attributes standards spreadsheet. *(Blocks machine config)*
2. **Pass Schedule Database Design** — Tim O. finalizes pass schedule layout and structure.
3. **Rod Receiving Module** — Rod receiving screen with validations deployed to shopfloor/web.
4. **Database Schema Changes** — Column renames, new columns, and `INFLAT` status applied.
5. **Machine Configuration** — FL1, FL2, FL3 added to the Machines application with all required tabs.
6. **Scheduling & Planning UI** — Flattening Lines tab, planning filter dropdown, and material drop changes deployed.
7. **Web Application Changes** — All Order/Quote/IQR/Alloys/Vendor screen changes released.
8. **Shopfloor Flat Wire UI** — New check-in and transaction screens for FL1/FL2 deployed.
9. **Reporting Suite (High Priority)** — Gauge Trace, CPK, SPC, Coil Pass Detail, Cut Traceability deployed.
10. **Machine Setup & PLC Commissioning Complete** — *Target: End of June 2026*
11. **Trials Begin** — *Target: July 1, 2026*
12. **Yield, Cost Ledger & Scrap** — Costing standards confirmed and modules updated.
13. **Reporting Suite (Low Priority)** — Rolls in Flattening, SCADA chart, WIP Log updates.
14. **Production Start** — *Target: August 1, 2026*
15. **UAT & Sign-off** — End-to-end testing across all modules with stakeholder sign-off.

---

## Risks

| Risk | Impact | Notes |
|------|--------|-------|
| Pass Schedule not finalized before shopfloor development begins | **Critical** | All check-in and PLC update flows depend on it; no workaround |
| 10-week effective development window is tight for full scope | **High** | Phase 1 scope must be ruthlessly prioritized; non-critical features deferred |
| Standards spreadsheet not finalized before machine config work begins | **High** | Blocks FL attribute setup; Naj/Bob/Tim dependency |
| Column renames affect downstream queries/reports not yet identified | **High** | Broad schema change; requires full impact analysis before execution |
| Costing standards for aluminum wire undefined | **Medium** | Blocks cost ledger and yield completion |
| SCADA chart layout and machine tags undetermined | **Medium** | Blocks SCADA report development; UA owns this |
| FL2 gauge trace mode differs from FL1/FL3 | **Medium** | FL2 is historical/profile only; report UI and SCADA must handle both modes |
| Spool-to-coil traceability gap at FL2 | **Medium** | Material enters as spool, exits as coreless coil; form-change traceability must be explicitly designed |
| Weld traceability in multi-rod scenarios | **Medium** | System must track which source rods contributed to output when welds create continuous material |
| Anneal rules for rod/wire not yet defined | **Medium** | Needed for scheduling algorithm; Dan F. owns; no timeline specified |
| Baler maximum dimensions unknown | **Low** | Affects scrap handling for out-of-spec bundles |
| FL3 (hybrid) scheduling and config edge cases | **Low** | Hybrid mode must be treated distinctly in scheduling, reporting, and machine tabs |

---

## Open Questions

The following items require a decision or further clarification before implementation can proceed:

1. **Pass Schedule auto-generation:** The system requires a Pass Schedule database (not a generator) — confirmed. Is there a UI for Operations/Maintenance to create and edit pass schedule records, or is this managed directly in a table?

2. **Pricing auto-population (Orders/Quotes):** Method for auto-populating flat wire pricing is listed as TBD. Who owns this decision, and what is the pricing model?

3. **Costing standards for aluminum wire:** Are new industry codes needed, or do existing codes (e.g., 510, 530) apply regardless of routing (pancake, tolled, flat wire)? Who defines this?

4. **SCADA chart layout:** UA is responsible for creating the chart layout and defining machine tags. No owner or timeline is specified.

5. **Standard times for FL1, FL2, FL3:** Required for yield calculation but not yet defined. Who is building these, and by when?

6. **FL machine output capacities:** VPS, FM1/TKUP-1 (3,500 lb), TKUP-2 (1,100 lb) are documented. FL1, FL2, FL3 output throughput rates are not listed.

7. **Baler maximum dimensions:** Out-of-spec wire bundles are compacted in the baler, but its maximum dimensions have not been confirmed. Who provides this information?

8. **WIP REJ report column updates:** The document states columns require updates but does not specify which columns change. Shannon R. is the likely owner — needs to be detailed.

9. **Finish field lock (Orders screen):** The Finish field is locked for now (Tim O. decision). Is this a temporary restriction pending a future decision, or a permanent policy?

10. **FL3 scheduling treatment:** FL3 is the hybrid mode (FL1 + FL2 continuous). How is it represented in the scheduling system — as a single machine entry or as a combined FL1+FL2 booking? Does scheduling a job on FL3 block both FL1 and FL2 simultaneously?

11. **Bundle Width specifications:** The mockup shows a Min/Max range for Bundle Width. How are these ranges determined — by order, by alloy, by machine capability, or entered manually by the planner/sales team?

12. **Edge critical attribute default:** When Flat Wire is selected, "Edge" is auto-set to "5 - Edge not a consideration." Are there any flat wire products where edge quality is a requirement (e.g., flat-edge products for contact strip)?

13. **Scrap banding material:** Documents note differences between steel and aluminum alloy banding but do not resolve which is used for flat wire scrap. Confirmation needed.

14. **Traveler screen fields per station:** Generic labels (e.g., "Incoming Bundle Information") are agreed in principle. The full field list per station for FL1, FL2, and FL3 has not been documented. Who is responsible, and by when?

15. **FL2 spool traceability identifier:** When flat wire arrives at FL2 on a spool (via TPO), what identifier (alpha, spool number, bundle ID) is used for check-in, and how does it link to the outgoing coreless coil record?

16. **Coreless coil skid labeling:** Final output is 2 coreless oscillated coils per skid. Do skid labeling, alpha assignment, and packaging records follow UA's existing coil packaging rules unchanged, or are flat wire-specific adjustments required?

17. **Rod receiving label format:** Label format for received rod material is listed as TBD. Who defines this, and does it need to support tolling labels?

18. **Inventory type for rods in coils table:** The SRS notes that Inventory Type for rod entries is TBD. Who defines this, and how does it affect planning and cost allocation?

19. **Storage area layout for rods:** Working with Naj and Bob on layout and flow. Are there system-side location tracking requirements (e.g., bay/row/position fields) for rod storage, or is it managed physically?

20. **Anneal rules for rod/wire:** Required for the scheduling algorithm. Dan F. owns this area. No timeline is specified — when will rules be available for the scheduler to consume?

---

### Industry-Standard Open Questions

The following questions are standard for flat wire manufacturing operations and have not yet been addressed in project documentation. They are grouped by domain and flagged by go-live risk.

#### Weld Traceability & Certification *(High risk — welding wire customers will ask on Day 1)*

21. **Traceability granularity for certs:** What is the minimum traceability unit required by welding wire customers — full coil-level, lot-level, or heat-level? Does this need to appear on the Certificate of Conformance?

22. **Weld attribution on output footage:** When a weld joins two source rods (R1 and R2) into a continuous run, how is the output footage attributed to each source rod for cert and yield purposes? Is there a footage-based split at the weld point, or is the entire output coil attributed to the dominant rod?

23. **Maximum weld joints per finished coil:** Is there a customer-specified limit on the number of weld joints permitted in a single coreless oscillated coil? Exceeding this limit for welding wire customers may cause feedability failures.

24. **Rework weld traceability:** If a weld breaks mid-run and the operator re-welds, must that rework event be recorded and traceable on the cert? Who defines this requirement?

25. **C of C frequency:** Are Certificates of Conformance issued per coil, per order, or per heat? Is this customer-specific or a standard UAL policy for flat wire?

26. **Tolled flat wire cert liability:** For orders where the customer supplies the rod, who holds chemistry cert liability — UA or the customer? This affects what the system must capture at rod receiving.

---

#### Pass Schedule Control & Mid-Run Events *(High risk — no defined system behavior today)*

27. ~~**Mid-run pass schedule change — alpha handling**~~ **DECIDED (May 4, 2026):** Five cases. Same-spec tooling swap = single alpha + die change event. Size change / edge type change / roll gap to new target = new child alpha. AGC roll gap adjustment within tolerance = single alpha, no change.

28. ~~**Pass schedule override authority**~~ **DECIDED (May 4, 2026):** Operations Manager edits in Dashboard 9; operators read-only except one-for-one same-size die swap. Four-step mid-run change flow: log override → notify operator on Active Run Monitor → operator acknowledges → automatic SPC checkpoint.

29. ~~**Component failure mid-run protocol**~~ **DECIDED (May 4, 2026):** Unplanned component bypass is a distinct event with alpha split, supervisor sign-off, and pre-bypass material disposition step.

30. **Roll gap validation before run start:** *(In Progress — Tim confirming with engineering.)* How are roll gap settings confirmed before a run begins — manual measurement, PLC encoder readback, or current implied no-readback?

---

#### Packaging & Coreless Coil Limits *(Medium risk — affects machine setup and customer acceptance)*

31. **Coreless coil OD/ID limits:** What are the maximum OD and minimum ID for coreless oscillated coils, and are these limits driven by UA's takeup equipment, customer unwinding equipment, or both?

32. ~~**Maximum finished coil weight:**~~ **DECIDED (Apr 28, 2026, updated May 4, 2026):** Maximum finished coil weight is **1,100 lb** (TKUP-2 equipment limit — revised from 1,000 lb stated Apr 28). The customer defines their specific maximum below UA's limit in the orders/quotes application. Orders exceeding a single rod or spool weight are split into multiple stops with alphas generated at planning time.

33. ~~**Oscillation layer interleave material**~~ **DECIDED (May 4, 2026):** No separator required or available. No pack specification field needed.

34. **Twist and torsion tolerance:** Is there a maximum allowable twist per foot for flat wire — particularly for welding wire feedability through automated welding equipment? Exceeding this causes wire jams at the customer.

---

#### Yield Loss & Planning Inputs *(High risk — planning cannot size rod input without these)*

35. **Expected metallic yield per route:** What is the target metallic yield (%) for each production route — rod → flat wire direct, rod → round wire → flat wire, and flat wire → flat wire re-pass? Required for planning to correctly size rod input weight per order.

36. **Footage-to-weight conversion factor:** How is footage-to-weight conversion calculated per alloy and cross-section — is there a standard formula, or is it measured and maintained per product? This factor drives output weight calculation (weight is calculated via length, not scale).

37. **Yield loss factor for planning:** Is there a per-pass scrap allowance (die entry crop, edge trim, end crop) that the planning algorithm must apply when calculating required rod input? If not built in, planners will under-order rod.

---

#### Dimensional Tolerances & Quality Standards *(Medium risk — needed before first customer shipment)*

38. **Published tolerance bands:** What are the thickness and width tolerance bands per alloy and temper for flat wire — governed by ASTM B236, customer spec, or UA internal standard? These must be in the system before SPC limits can be set.

39. ~~**Camber and flatness limits**~~ **DECIDED (May 4, 2026):** Camber SPC field available in checkpoint if customer has camber specifications — conditional on customer requirement.

40. ~~**Edge burr height limit**~~ **DECIDED (May 4, 2026):** Not currently measured. No system implementation required.

---

#### Tooling Life & Maintenance *(Medium risk — invisible cost if not tracked)*

41. ~~**Die life tracking**~~ **DECIDED (May 4, 2026):** System-level tracking required. Footage logged against unique die ID; alert banner when nearing threshold; no hard block; threshold deferred until failure data available.

42. **Edger blade profiles:** Are edger blade profiles standardized across all products, or are they custom per edge type (Round Edge vs. Flat Edge) or per alloy? Who maintains the blade profile library, and does it need to be in the system?

43. **Roll regrind and spare inventory:** Are rolls reground in-house or sent out? What is the turnaround time, and how many spare sets are required on hand to avoid line downtime? Does the system need to track roll condition and location?

---

#### Scheduling & Capacity *(Medium risk — affects scheduling algorithm accuracy)*

44. ~~**Line speed range per alloy/gauge**~~ **DECIDED (May 4, 2026):** Unknown, determined by trial production. Data added to configuration table by UA once available. Scheduling algorithm must be table-driven for this input.

45. ~~**FL1 and FL2 simultaneous independent operation**~~ **DECIDED (May 4, 2026):** Yes — FL1 and FL2 can run independent orders simultaneously as separate machines. Throughput ratio ≈ 3:1 (FL1 faster). FL3 (hybrid) cannot run if FL1 or FL2 have scheduled orders.

46. **Shared anneal furnace capacity:** Are furnace slots for flat wire annealing shared with the existing coil anneal schedule, or is there dedicated capacity? If shared, the scheduling algorithm must account for furnace contention.

---

#### Rod Checkout *(High risk — traceability and PLC safety gaps if undefined before build)*

47. **Partial-rod re-check-in:** *(In Progress — May 4, 2026.)* Multiple partial spool alphas per rod confirmed needed. Material in mill scrapped; rod returns to WH. Payoff scale question pending (Scott/Bob/Shannon). Full carry-forward design deferred.

48. ~~**Mid-run checkout authorisation**~~ **DECIDED (May 4, 2026):** Supervisor approval required for mid-run checkout.

49. **PLC behaviour on checkout:** *(In Progress — Tim confirming with engineering.)* Proposed: application never sends stop command; tags cleared only after confirmed stop; checkout blocked if line still running.

50. ~~**Partial-run material disposition authority**~~ **DECIDED (May 4, 2026):** Supervisor must approve before partial spool alpha is created. Notification-driven remote approval: Accept / Hold / Reject.

> **Note:** The authoritative open questions register is [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) — now contains 59 questions with decisions recorded. The list above is the original planning baseline (items 1–50); items 51–59 and all status updates are tracked in FlatWireOpenQuestions.md.
