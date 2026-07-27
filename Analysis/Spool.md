# Spool — Flat Wire Intermediate Form

**Document Purpose:** Detailed explanation of what a spool is in the flat wire manufacturing process, its role in material flow, and system integration.

**Last Updated:** May 4, 2026

**Status:** Reference — Material Flow Reference

---

## Overview

A **spool** is an intermediate form of flat wire material that bridges two manufacturing stages in the flat wire production process. It represents flat wire wound into a cylindrical bundle, created after FL1 finishing and used as input for FL2 finishing.

---

## Physical Form & Specifications

### Structure
- **Form:** Flat wire wound/collected into a cylindrical bundle
- **Analogy:** Similar to how thread or cord is wound on a spool; material wrapped in layers around a central core
- **Capacity:** **3,500 lb** maximum (per TKUP-1 and TPO specifications)
- **Material:** Flat wire (produced by FL1 or pre-finished flat wire for re-pass operations)

### Identification
- **Alpha Code Format:** SP-series (e.g., SP-00031, SP-00032, SP-00033)
- **System Tracking:** Assigned unique alpha in coils table when created
- **Traceability Link:** Linked to source rod alphas through FL1 run history

---

## Spool Role in the Manufacturing Process

### FL1 Output Stage

**Where Spool is Created:**

```
FL1 Process Flow:
Rod (R-series alpha)
    ↓
VPS Payoff (dual position)
    ↓
DB1 / DB2 (wire drawing dies — can be bypassed)
    ↓
FM1 (12" Flattening Mill)
    ↓
TKUP-1 (Traversing Take-up, 3,500 lb capacity)
    ↓
[SPOOL CREATED HERE]
    └─ Assigned SP-series alpha
    └─ Linked to source rod alphas
    └─ Recorded in coils table
```

**At this point:**
- Flat wire has been drawn from rod
- Gauge and width have been shaped to target specifications
- Material is collected on TKUP-1 traversing take-up
- When TKUP-1 reaches 3,500 lb capacity, spool is complete

---

### Material Flow Options After FL1

**Option A: Non-Hybrid Flow (Standalone FL1 → Optional Anneal → FL2)**

```
FL1 TKUP-1 Spool (3,500 lb)
    ↓
[Stored in warehouse OR transferred to anneal]
    ↓
Optional Anneal (if required for product)
    ↓
TPO (Traversing Payoff, 3,500 lb)
    ↓
FL2 Input (Spool loaded onto TPO)
    ↓
FM2 (8" Roller, 6" Roller S1, 6" Roller S2, Edgers)
    ↓
TKUP-2 (Traversing Take-up, 1,100 lb)
    ↓
Coreless Oscillated Coil (Output)
```

**Option B: Hybrid Flow (FL3 — FL1 Continuous into FL2, No Intermediate Stop)**

```
FL1 FM1 Output
    ↓
TKUP-1 bypassed — material feeds directly to TPO
    ↓
TPO feeds directly into FM2 (no spool intermediate storage)
    ↓
FL2 Finishing
    ↓
TKUP-2 → Coreless Oscillated Coil
```

**In hybrid mode (FL3):** No spool is created as a separate entity — material flows continuously from FL1 into FL2.

---

### FL2 Input Stage

**How Spool is Used:**

1. **Spool Check-in (Dashboard 5):**
   - FL2 operator loads spool onto TPO (Traversing Payoff)
   - Operator enters: Spool alpha (e.g., SP-00031)
   - System displays: Source rods, alloy, gauge profile from FL1 run, historical gauge trace
   - Operator confirms visual condition and acknowledges pass schedule

2. **FL2 Processing:**
   - Spool feeds material from TPO into FM2 components
   - Gauge and width are refined further in FM2
   - Final output collected on TKUP-2 as coreless oscillated coil

3. **Output Tracking:**
   - Spool alpha linked to final coil alpha
   - Traceability chain: Source Rods → Spool → Coreless Coil

---

## Form Change & Traceability

### Traceability Chain

```
Material Evolution:

Rod (R00041)  
    ↓ [FL1 Processing]
Spool (SP-00031) — contains R00041 + R00042 (if welded mid-run)
    ↓ [FL2 Processing]
Coreless Coil (FW-00421-C01) — traces back to source rods via spool
    ↓
Skid (SK-00201) — holds 2 coreless coils
```

### Why Form Changes Matter

| Form | Stage | System Handling |
|------|-------|-----------------|
| **Rod** | Incoming material; VPS payoff | Tracked as R-series alpha; routed to FL1 |
| **Spool** | Intermediate; FL1 output → FL2 input | Tracked as SP-series alpha; stores gauge profile; links rods to coil |
| **Coreless Coil** | Final product; after TKUP-2 | Tracked as order-series alpha (e.g., FW-00421-C01); final traceability record |

---

## Spool in System Planning & Scheduling

### Planning Role

**Material Assignment (decided Apr 28, 2026):**

1. Planner selects a flat wire order (e.g., FW-00421)
2. System shows available spools matching the order's alloy, gauge, and width requirements
3. Planner enters total weight only — the system **automatically computes** number of stops and **generates alphas at planning time** (not dynamically during execution)
4. Orders exceeding single-spool capacity are split into multiple stops; the last stop may contain multiple alphas
5. System automatically:
   - Allocates the specified weight to the order and generates stop alphas
   - Creates a remainder alpha (SP-00031-REM) for unused weight
   - Returns remainder to warehouse inventory
6. **"Assign as-is" option:** when material remains after order fulfilment, planner can elect to assign the remainder as-is to stock (enabled only when remaining weight exists)

**Confirmed Allocation Scenarios (Apr 28, 2026):**
| Scenario | Description |
|----------|-------------|
| Full spool → single order | Entire spool weight assigned to one order |
| Partial spool → order + stock | Portion assigned to order; remainder returned to stock with new alpha |
| Single spool → multiple orders | Spool split across multiple orders in successive planning steps |

**Dashboard Location:** Planning System Changes (Section 5 of FlatWirePlan.md)
- Material Drop Pop-up shows a **Weight** field (not "Number of Cuts" or "Number of Stops")
- Pattern picture replaced by a tabular grid: Order → Spool → Weight allocation, alpha reference, remainder disposition
- Planner enters weight from available spool; system drives all split and stop logic

### Scheduling Role

**Spool Check-in Trigger:**

1. Order scheduled for FL2 on a specific date/time
2. Planner specifies which spool(s) to use
3. When scheduled time arrives, FL2 operator receives the spool at TPO
4. Operator checks in spool via Dashboard 5 (Spool Check-in)
5. Dashboard 5 pre-populates:
   - Spool alpha (e.g., SP-00031)
   - Source rod alphas (e.g., R00041, R00042)
   - Historical gauge profile from FL1 run
   - Alloy, gauge, width specifications

---

## Spool Attributes in System (Coils Table)

When a spool is created at FL1 TKUP-1, the system records:

| Attribute | Value | Notes |
|-----------|-------|-------|
| **Alpha** | SP-00031 | Unique spool identifier |
| **Alloy** | 1100 | From product specification |
| **Gauge** | 0.110" | Target from pass schedule (FL1) |
| **Width** | 0.627" | Actual measured at FM1 |
| **Weight** | 3,200 lb (net) | From footage counter and density factor |
| **Surface Finish** | — | Not applicable for spools |
| **Coil ID / OD** | — | Not applicable for spools |
| **Inventory Type** | TBD | Rod-derived or Re-pass material; system coding TBD |
| **Source Rods** | R00041, R00042 | Linked rods; weld point at 2,100 ft |
| **Gauge Profile** | [Chart] | Historical trace from FL1 run with weld marker |
| **Status** | ACTIVE | Available for planning, or IN-USE if assigned to order |

---

## Spool-Related System Changes (Dashboard Integration)

### Dashboard 2 & 5 Comparison

| Aspect | Dashboard 2 (Rod Check-in) | Dashboard 5 (Spool Check-in) |
|--------|-------------------------|---------------------------|
| **Incoming Material** | Rod (R-series alpha) | Spool (SP-series alpha) |
| **Gauge Trace Shown** | None — run not started yet | Historical profile from FL1 run |
| **Weld Markers** | Not applicable | Shown on gauge profile chart at weld points |
| **Visual Inspection** | Required (oxidation, defects, water stains) | Not required — spool already inspected at FL1 |
| **Pass Schedule** | Read and acknowledge | Read and acknowledge |
| **Source Links** | Single incoming rod | Multiple source rods (linked via spool) |

### Dashboard 7 (Output Coil Completion)

**Spool Traceability Capture:**

```
SOURCE TRACEABILITY
┌──────────────┬────────────────┬───────────────────────────┐
│ Rod Alpha    │ Footage From   │ Footage To                │
├──────────────┼────────────────┼───────────────────────────┤
│ R00041       │ 0 ft (spool)   │ 4,100 ft (weld at 4,100)  │
│ R00042       │ 4,100 ft       │ 14,200 ft                 │
└──────────────┴────────────────┴───────────────────────────┘
```

**Shows:**
- Which source rods contributed to the final coil
- Footage ranges for each rod
- Weld point location where rod change occurred
- Link back to spool alpha (SP-00031) if recorded

---

## Spool-Related Open Questions

Based on FlatWirePlan.md Open Questions section:

1. **FL2 Spool Traceability Identifier (Question 15)**
   - When flat wire arrives at FL2 on a spool (via TPO), what identifier (alpha, spool number, bundle ID) is used for check-in?
   - How does it link to the outgoing coreless coil record?
   - **Current Answer:** SP-series alpha used; linked via Dashboard 5 → Dashboard 7 chain
   - **Status:** Needs confirmation

2. **Spool Form Change Handling**
   - If a spool transitions through anneal or re-pass operations, does it retain the same alpha or receive a new child alpha?
   - Example: SP-00031 → Anneal → SP-00031-A1 (or remains SP-00031)?
   - **Status (May 4, 2026): Decided** — The alpha is **modified** (updated) to maintain traceability through the anneal step. No new child alpha is generated for an intermediate anneal; the existing spool alpha carries forward with the anneal event recorded against it.
   - **Re-pass note:** UA does not have the capability to run a spool through FL1. The re-pass scenario is not applicable.

3. **Spool Remainder Tracking**
   - When planner assigns 2,000 lb from a 3,500 lb spool, how is the 1,500 lb remainder tracked?
   - Does it receive a child alpha (e.g., SP-00031-REM)?
   - Can remainder be used for multiple orders?
   - **Status (Apr 28, 2026): Decided** — remainder gets a new child alpha and is returned to warehouse inventory. Planner can use "Assign as-is" to route remainder to stock. A single spool can be split across multiple orders in successive planning steps.

4. **Spool Status Transitions**
   - What are all possible spool statuses? (e.g., ACTIVE, IN-PLAN, IN-USE, COMPLETED, SCRAPPED)
   - At what points does status change?
   - **Status (May 4, 2026): In Progress** — Operational framework confirmed: spools shall have unique identifiers similar to furnace plates. Alphas are loaded onto a spool number at the start of the FL1 job; operators are required to input the spool number being used. The spool number is tracked physically and in system: tow motor moves spool → furnace → cooling → FL2 (operator selects spool number at FL2 check-in). Full formal state machine (all valid statuses and transition events) is still to be defined — without it, the system cannot enforce valid status progressions.

---

## Spool vs. Coil Comparison

| Characteristic | Spool | Coil |
|----------------|-------|------|
| **Created At** | FL1 TKUP-1 (intermediate) | FL2 TKUP-2 (final) |
| **Alpha Format** | SP-series | Order-series (e.g., FW-00421-C01) |
| **Capacity** | Up to 3,500 lb | Up to 1,100 lb *(TKUP-2 equipment limit — revised May 4, 2026 from 1,000 lb. Customer defines their limit below UA max in orders/quotes application.)* |
| **Form** | Flat wire on cylindrical spindle | Coreless oscillated coil |
| **Next Step** | Optional anneal, then FL2 processing | Packing, labeling, shipment |
| **Traceability** | Links rods to coil | Final product record; customer cert |
| **Visual Inspection** | Required at FL1 check-in | Not required (already inspected) |
| **Gauge Trace** | Real-time during FL1 run | Historical profile displayed at FL2 check-in |
| **Packaging** | Not packaged; single unit | 2 coils per skid |

---

## Material Flow Summary

### Complete Spool Lifecycle

```
1. CREATION
   └─ FL1 Process: Rod → Drawing → Flattening (FM1) → TKUP-1
   └─ Spool created (SP-00031)
   └─ Gauge profile recorded
   └─ Source rods linked

2. STORAGE / OPTIONAL PROCESSING
   └─ Spool stored in warehouse
   └─ Optional: Anneal if required for product
   └─ Ready for next stage

3. PLANNING
   └─ Planner assigns weight (2,000 lb) to order
   └─ Remainder tracked (1,500 lb)
   └─ Spool marked IN-PLAN

4. SCHEDULING
   └─ Order scheduled for FL2
   └─ Spool moved to FL2 TPO
   └─ Marked IN-USE

5. FL2 CHECK-IN (Dashboard 5)
   └─ Operator loads spool onto TPO
   └─ Confirms source rods
   └─ Reviews gauge profile
   └─ Acknowledges pass schedule

6. FL2 PROCESSING
   └─ Material feeds through FM2 components
   └─ Gauge and width refined
   └─ Collected on TKUP-2

7. OUTPUT (Dashboard 7)
   └─ Coreless coil created (FW-00421-C01)
   └─ Linked back to source spool (SP-00031)
   └─ And source rods (R00041, R00042)
   └─ Spool marked COMPLETED

8. FINAL PACKAGING
   └─ Coil paired with another coil
   └─ 2 coils per skid (SK-00201)
   └─ Ready for shipment
```

---

## Key Spool Concepts for Stakeholders

### For Operations / Maintenance
- **Spool is the handoff point** between FL1 and FL2 — critical for traceability
- **Pass schedule is acknowledged at spool check-in** — ensures FL2 configuration matches product requirements
- **Gauge profile visible at FL2 check-in** — allows operator to verify FL1 output quality before proceeding

### For Planning
- **Spool is a planning unit** — measured in weight, not cuts (unlike slitting operations)
- **Remainder tracking** — spools can be split across multiple orders; remainder returns to inventory
- **No predetermined output** — spool weight is flexible based on order demand

### For Quality / Traceability
- **Spool links rods to coils** — critical for welding wire customer certs
- **Gauge profile preserved** — historical data available for audits and quality analysis
- **Form change marker** — spool represents the transition from FL1 to FL2; both stages' data tied together

### For Scheduling
- **Spool constraints** — max 3,500 lb per spool; must be fully consumed or split for multiple orders
- **Anneal impact** — if anneal required, it extends timeline between FL1 and FL2 start
- **Hybrid mode bypass** — in FL3 hybrid, no spool intermediate; material flows continuously

---

## Related Documents

- [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) — Dashboard 2 (Rod Check-in), Dashboard 5 (Spool Check-in), Dashboard 7 (Output Coil Completion)
- [FlatWirePlan.md](FlatWirePlan.md) — Process & Equipment Overview, Planning System Changes (Section 5)
- [PassScheduleManagement.md](PassScheduleManagement.md) — Spool check-in integrates with pass schedule acknowledgment

---

## Change Log

| Date | Changed By | Description |
|------|----------|-------------|
| Apr 24, 2026 | Analysis Team | Initial spool reference document created — comprehensive material flow explanation, system integration, and traceability chain documented |
| Apr 28, 2026 | MOM — Planning & Shopfloor meeting | **Planning Role updated:** alpha generation now at planning time (not execution); stop calculation is system-driven; planner inputs weight only. Three spool-to-order allocation scenarios confirmed (full, partial+stock, multi-order). "Assign as-is" stock option documented. Spool remainder tracking status updated to Decided. Coil capacity (1,000 lb) confirmed in comparison table. |
| May 4, 2026 | Analysis Team — Tim O. review | **Q55 Decided:** Anneal step modifies the existing spool alpha (no new child alpha); traceability maintained through the event log. Re-pass through FL1 not applicable (no capability). **Q57 In Progress:** Unique spool IDs confirmed (like furnace plates); tracking workflow FL1 → furnace → cooling → FL2 confirmed by operator spool number selection; full state machine transitions TBD. **Coil capacity updated** to 1,100 lb (revised from 1,000 lb per Tim O. May 4). |
