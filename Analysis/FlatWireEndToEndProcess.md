# Flat Wire Mill — End-to-End Process

**Project:** Flat Wire Mill Implementation
**Last Updated:** April 28, 2026
**Document Type:** Process Reference
**Status:** Draft — Pending Tim O. / Bob S. review

> ### ⚠ FM2 equipment configuration in this document is superseded (4 Aug 2026)
>
> **FM2 has three stands: `S1` = 8″, `S2` = 6″, `S3` = 6″.** Edgers are at **S2 and S3 only**, and **S3 is the final, non-bypassable gauge-control stand**.
>
> Every FM2 description below is stale in one of two ways — either the pre-May-21 **two** 6″ stand form (`8" → 6"S1 → 6"S2`, S2 final), or the four-component form that read the May 21 note as a separate 8″ roller feeding three 6″ stands. **The 8″ roller *is* S1**, and there is no fourth stand. Component identifiers are now position-only — `FM2_S1` / `FM2_S2` / `FM2_S3` — with roll diameter held as data in `Stand.RollDiameterIn`.
>
> **Authoritative source: [`00-foundations.md`](../MVP-1/DevelopmentPlan/ShopfloorPlan/00-foundations.md) §0.3**, decision **D-26** in [`FlatWire_MasterSpecification.md`](../LatestDocument/FlatWire_MasterSpecification.md) §10.2. Do not implement FM2 from this file.

---

## Overview

The flat wire manufacturing process converts aluminum rod into coreless oscillated flat wire coils through a controlled sequence of wire drawing, flattening, optional annealing, and finish rolling. The process supports three operating routes depending on the product specification:

| Route | Lines Used | Description |
|-------|-----------|-------------|
| **FL1 Standalone** | FL1 only | Rod → drawn → 12" mill → intermediate spool output |
| **FL2 Standalone** | FL2 only | Pre-flattened spool in → 3-stand finishing mill → coreless coil out |
| **FL3 Hybrid** | FL1 + FL2 continuous | Rod in → both mills without stopping → coreless coil out; no intermediate anneal |

**Final product:** Coreless oscillated coils, **2 per skid**.

---

## Process Flow Diagram

```
Vendor Rod
    │
    ▼
┌─────────────────────────────────────────┐
│  STAGE 1 — Rod Receiving & Inspection   │
│  R-series alpha · chemistry · weight    │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  STAGE 2 — Planning & Scheduling        │
│  Order → Item Template → Route → FL#   │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  STAGE 3 — Rod Check-in & Pass Schedule │
│  Visual inspection · PLC tag push       │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  STAGE 4 — Wire Drawing (DB1 / DB2)     │
│  Diameter reduction · can be bypassed   │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  STAGE 5 — 12" Flattening Mill (FM1)    │
│  Round → Flat · real-time gauge trace   │
└─────────────────────────────────────────┘
    │
    ├─── [Non-Hybrid] ──> TKUP-1 Spool ──> (Optional Anneal) ───────────┐
    │                                                                     │
    └─── [Hybrid FL3] ────────────────────────────────────────────────► │
                                                                          ▼
                                                           ┌─────────────────────────────────┐
                                                           │  STAGE 6 — 3-Stand Mill (FM2)   │
                                                           │  8" → 6"S1 → Edger → 6"S2      │
                                                           └─────────────────────────────────┘
                                                                          │
                                                                          ▼
                                                           ┌─────────────────────────────────┐
                                                           │  STAGE 7 — Weld Event (if used) │
                                                           │  Rod-to-rod induction weld       │
                                                           └─────────────────────────────────┘
                                                                          │
                                                                          ▼
                                                           ┌─────────────────────────────────┐
                                                           │  STAGE 8 — Output SPC & QC      │
                                                           │  Gauge · width · pass/fail       │
                                                           └─────────────────────────────────┘
                                                                          │
                                                                          ▼
                                                           ┌─────────────────────────────────┐
                                                           │  STAGE 9 — Packing              │
                                                           │  2 coreless coils per skid       │
                                                           └─────────────────────────────────┘
                                                                          │
                                                                          ▼
                                                           ┌─────────────────────────────────┐
                                                           │  STAGE 10 — Cert & Shipment     │
                                                           │  C of C · traceability to heat   │
                                                           └─────────────────────────────────┘
                                                                          │
                                                             (Scrap at any stage → Stage 11)
```

---

## Stage 1 — Rod Procurement & Receiving

**Input:** Aluminum rod bundled coils from vendor
**Output:** Received rod with R-series alpha, validated and stored
**System Module:** Coil Receiving (Rod)
**Phase 1:** Manual receipt only — no EDI

### Process Steps

1. Purchase Order raised in MPS with 3D specifications: gauge × diameter × length/weight.
2. Rod arrives at the plant as bundled coils from approved vendors (e.g., Constellium, Arconic).
3. Receiving operator opens the rod receiving screen and enters the PO number — alloy, diameter, and weight parameters are pulled automatically from the PO.
4. Operator enters actual **gross weight** (scale) and **net weight**.
5. System validates scale weight against the PO/vendor weight within tolerance.
6. **Rod chemistry** documentation is checked — if missing, material is suspended.
7. If weight is out of tolerance, material is suspended pending review.
8. On successful receipt, system assigns a **Rod Number** in the format `R00001` (R + 5-digit sequence, no gaps, per lot).
9. Coils table entry is created: gauge populated, width blank, OD/ID blank, surface finish blank.
10. Rod bundle is moved to the **rod storage area** to await production.

### Validations

| Rule | On Failure |
|------|-----------|
| Scale weight within tolerance of vendor gross weight | Material suspended |
| Rod chemistry documentation present | Material suspended |
| Width field | Not applicable — rods have no width |

### Rod Number Format

| Field | Detail |
|-------|--------|
| Format | `R` + 5-digit sequence (e.g., `R00001`) |
| Range | R00001 – R99999 |
| Increment | 1 per received rod per lot number, no gaps |
| Archive | Historical R-series retained in coils table |

---

## Stage 2 — Planning & Scheduling

**Input:** Customer order for flat wire product
**Output:** Job scheduled on FL1, FL2, or FL3 with rod material assigned
**System Modules:** Orders → IQR → Item Template → Planning → Scheduling

### Process Steps

1. Sales team creates an **Order** with the Flat Wire checkbox selected, specifying:
   - Bundle Width (Min / Max range)
   - Edge Type: `Round Edge` or `Flat Edge`
   - Alloy, temper, gauge/diameter

2. **IQR** is created linking the order to an item template.

3. **Item Template** defines the multi-step process route. Example routes:

   | Route Type | Step Sequence |
   |-----------|--------------|
   | Direct flat | Rod (Round) → FLATTEN → Flat Wire |
   | Draw then flat | Rod (Round) → DRAW → Round Wire → FLATTEN → Flat Wire |
   | With anneal | Rod → DRAW → Round Wire → FLATTEN → Flat Wire → ANNEAL → FLATTEN → Flat Wire (Final) |

4. **Planning** screen: planner filters by `Flatwire`, selects available rod material, assigns weight to the order.
   - Planner enters **weight only**; the system **automatically computes stops and generates alphas at planning time** (not during execution).
   - Orders exceeding single-rod/spool capacity are split into multiple stops, each with its own alpha. The last stop may contain multiple alphas.
   - "Number of Cuts" and "Number of Stops" fields are not used for flat wire — these are system-computed.
   - System generates a **remainder alpha** for the unused portion returned to the warehouse.
   - **"Assign as-is" option** allows the planner to route remaining weight to stock inventory.
   - Three confirmed allocation scenarios: (1) entire spool → single order, (2) partial spool → order + stock, (3) single spool → multiple orders.
   - The rectangular pattern picture is replaced by a tabular grid showing Order → Spool → Weight allocation and alpha references.

5. **Scheduling** assigns the job to FL1, FL2, or FL3 based on the route and available capacity:
   - Operation letter `F` used in scheduling columns.
   - Status set to `INFLAT` when the job is active on the line.

---

## Stage 3 — Rod Check-in & Pre-Run Setup

**Input:** Rod bundle from storage
**Output:** Pass schedule acknowledged, PLC configured, material checked in
**System Module:** Shopfloor — FL1 Traveler (shared UI for FL1 and FL2)

### Process Steps

1. Rod bundle is brought to the **VPS (Variable Position Payoff)** — dual position, eye-to-sky orientation, max 9,000 lb capacity per position.
2. **Visual inspection** is performed before unbanding:

   | Inspection Item | Action on Fail |
   |----------------|---------------|
   | Oxidation | Add observation → submit WIP rejection |
   | Surface defects | Add observation → submit WIP rejection |
   | Water stains | Add observation → submit WIP rejection |

   > Bundles are **not unbanded** until positioned at the payoff — safety and bundling integrity requirement.

3. Operator opens the FL1 check-in screen and enters:
   - Rod number (R-series alpha)
   - Diameter
   - Payoff position (Payoff 1 or Payoff 2)
   - Die 1 size (manual input or from pass schedule)
   - Die 2 size (manual input or from pass schedule)

4. System displays the **Pass Schedule** for the job. Operator acknowledges it.

5. System pushes **PLC tags** to the machine — components are set to active or bypassed per the pass schedule.

6. Pre-run SPC: operator measures and records incoming rod diameter.

### Pass Schedule — What It Controls

| Parameter | Description |
|-----------|-------------|
| Component active/bypass | DB1, DB2, FM1, FM2-8", FM2-6"S1, FM2-6"S2 |
| Die sizes | Per active drawing stage |
| Edge set configuration | Per active edger |
| Roll clearances | Per rolling stand |
| Gauge and width targets | Per pass |
| Route type | Standalone (FL1 or FL2) or Hybrid (FL3) |

> The Pass Schedule is manually maintained by Operations/Maintenance. It is not auto-generated. It is applied after planning, not during item template creation.

---

## Stage 4 — Wire Drawing (DB1 / DB2)

**Input:** Aluminum rod from VPS payoff
**Output:** Round wire at target diameter
**Equipment:** DB1 (Wire Drawing Die 1), DB2 (Wire Drawing Die 2)

### Process Steps

1. Rod is pulled through **DB1** — reduces diameter toward target. Can be **bypassed** via pass schedule if the rod is already at the correct diameter.
2. Wire continues through **DB2** — further diameter reduction. Can also be bypassed.
3. Purpose: correct rod roundness and bring diameter to the precise size required for consistent flattening.
4. Wet lubricant is applied during drawing. Lubricant residue is a handling consideration for downstream processes.
5. **Post die-change SPC:** after any die change, operator measures and records wire diameter manually.

### Notes

- If both DB1 and DB2 are bypassed, rod feeds directly into FM1 at its as-received diameter.
- Die wear is the primary reason for a die change mid-campaign. Die change events should be logged with reason code.

---

## Stage 5 — 12" Flattening Mill (FM1)

**Input:** Round wire from DB1/DB2 (or directly from VPS if both bypassed)
**Output:** Flat wire (2D cross-section)
**Equipment:** FM1 with gauge stands, dancer, edger — TKUP-1 Traversing Take-up (3,500 lb)

### Process Steps

1. Round wire enters the **12" Flattening Mill (FM1)** — the primary transformation where 3D round wire becomes 2D flat wire.
2. Roll gap, edge set, and speed are driven by the active pass schedule.
3. **Dancer** manages wire tension throughout the run, compensating for speed variations.
4. **Gauge stands** take automatic real-time measurements of gauge and width — this is the **FL1 real-time gauge trace**.
5. **AGC (Automatic Gauge Control)** runs continuously during production — set at run start, operates without operator intervention.
6. SPC data recorded: gauge and width after FM1.

**At this point the process follows one of two routes:**

---

### Route A — Non-Hybrid (FL1 Standalone Output)

1. Flat wire is collected onto **TKUP-1 (Traversing Take-up, 3,500 lb)** as an intermediate spool.
2. SPC is performed for gauge and width per outgoing spool.
3. System generates **child alphas** for the output spools.
4. **Spool labels** are printed and applied:

   | Label Field | Content |
   |-------------|---------|
   | Temp Spool No. | System-generated |
   | Alloy | From order |
   | Width | Measured |
   | Gauge | Measured |
   | Temper | From pass schedule |
   | Gross Weight | Calculated |
   | Net Weight | Calculated |
   | Source Rod Alphas | Linked R-series alphas |

5. Spools are transferred to either:
   - **Optional anneal furnace** → if temper requires it → then loaded onto TPO for FL2.
   - **Directly to FL2** (loaded onto TPO) if no anneal is required.

---

### Route B — Hybrid / FL3 (Continuous Operation)

1. No intermediate takeup. Material flows **continuously** from FM1 directly into FM2 via the TPO.
2. No spool label or intermediate alpha is generated — the run does not stop at TKUP-1.
3. Process continues directly into Stage 6 without line interruption.
4. Gauge trace remains **real-time** throughout (no FL2 check-in step in hybrid mode).

---

## Stage 6 — 3-Stand Finishing Mill (FM2 / FL2)

**Input:** Flat wire spool from TPO (non-hybrid) or continuous feed from FM1 (hybrid)
**Output:** Flat wire at final gauge, width, and temper — collected as coreless oscillated coil
**Equipment:** TPO (3,500 lb) → 8" Roller → 6" S1 → Edger → 6" S2 → Edger → TKUP-2 (1,100 lb)

### Process Steps

**Non-hybrid only (FL2 standalone):**
1. Spool is loaded onto the **TPO (Traversing Payoff, 3,500 lb)**.
2. Operator opens the FL2 check-in screen, enters spool identifier, width, gauge.
3. System displays the pass schedule → operator acknowledges → PLC tags updated.
4. **Gauge trace mode for FL2:** historical/profile view — gauge profile is available when material is checked into FL2, not live.

**All routes (non-hybrid and hybrid):**

5. Flat wire passes through FM2 components in sequence:

   | Component | Skippable | Purpose |
   |-----------|-----------|---------|
   | 8" Roller | Yes | Intermediate reduction |
   | 6" Roller S1 | Yes | Further reduction |
   | Edger | — | Edge conditioning |
   | 6" Roller S2 | **No** | Final gauge control — mandatory |
   | Edger | — | Final edge finish |

6. Automatic gauge and width measurement after the final 6" roller.
7. Output is wound at **TKUP-2 (1,100 lb)** as a **coreless oscillated coil**.

---

## Stage 7 — Continuous Operation via Welding

**When:** Rod on Payoff 1 nears its end during an active production run.
**Purpose:** Maintain continuous line operation without stopping to reload.

### Process Steps

1. Operator monitors rod weight on Payoff 1. As it approaches exhaustion, a new rod bundle is pre-loaded on **Payoff 2**.
2. Operator welds the tail of the Payoff 1 rod to the head of the Payoff 2 rod:

   | Weld Type | Application |
   |-----------|------------|
   | **Induction welding** | Rod-to-rod joins at the payoff |
   | **Laser welding** | Flat-to-flat joins (optional) |

3. Line continues running without interruption through the weld point.
4. System records the **weld join event** — linking the Rod 1 alpha and Rod 2 alpha to the continuous output material.
5. Traceability is maintained through the weld point: output footage is attributed to each source rod for cert purposes.

---

## Stage 8 — Output SPC & Quality Check

**Input:** Coreless oscillated coil on TKUP-2
**Output:** Accepted or rejected coil with SPC record

### SPC Checkpoints — Full Run Summary

| Checkpoint | Stage | Measurement | Type |
|-----------|-------|-------------|------|
| Incoming rod diameter | Pre-check-in (Stage 3) | Diameter | Manual |
| Post wire-draw diameter | After DB1/DB2 die change (Stage 4) | Diameter | Manual |
| After 12" mill (FM1) | Stage 5 | Gauge + width | Automatic (AGC) |
| After 6" finishing mill (FM2 S2) | Stage 6 | Gauge + width | Automatic (AGC) |
| Final output per spool/coil | Stage 8 | Gauge + width | SPC record |

### Disposition

| Result | Action |
|--------|--------|
| In spec | Coil confirmed, alpha released, proceed to packing |
| Out of spec | WIP rejection submitted with rejection reason; material suspended |
| Edge defect | Reviewed per edge type spec; scrap or rework decision |

---

## Stage 9 — Packing & Final Output

**Input:** Accepted coreless oscillated coil from TKUP-2
**Output:** Packed, labelled, skid-mounted finished product ready for shipment
**System Module:** Packing — no Inspection Bench changes

### Process Steps

1. Coils are moved from TKUP-2 to the **packing station**.
2. Pack specifications are applied per the customer order:

   | Pack Spec Item | Options |
   |----------------|---------|
   | Coil orientation | Eye-to-side or eye-to-sky (customer-specified) |
   | Layer separator | Interleave material between winding layers (if required) |
   | Banding | Steel or aluminum alloy banding (TBD) |
   | Coils per skid | **2 coreless coils per skid** |

3. Finished labels are printed and applied to each coil:

   | Label Field | Content |
   |-------------|---------|
   | Alpha / Coil No. | System-generated |
   | Alloy | From order |
   | Gauge / Diameter | Measured final value |
   | Width (Bundle Width) | Measured final value |
   | Temper | From pass schedule / order |
   | Gross / Net Weight | Calculated (footage-based) |
   | Lot Number | Linked to source rod lot |
   | Footage | Calculated |

4. Skid record is created in the system — 2 coil alphas linked to 1 skid entry.

---

## Stage 10 — Certification & Shipment

**Input:** Packed skid with 2 coils
**Output:** Shipped order with Certificate of Conformance
**System Module:** Certs (no changes anticipated for Phase 1)

### Process Steps

1. **Certificate of Conformance (C of C)** is generated.
   - Frequency: per coil / per order / per heat — TBD (see Open Question #25).
   - Contents: chemistry, mechanical properties, dimensional data, alloy, temper, traceability to source rod heat.

2. For **welding wire customers** specifically:
   - Full traceability from rod heat → through every weld point → to finished coil alpha is required.
   - Each weld join event must be traceable on or alongside the cert.
   - Maximum weld joints per coil may be a customer contractual limit (see Open Question #23).

3. Material released from inventory and shipped to customer.

4. For **tolled orders** (customer-supplied rod):
   - Chemistry cert liability allocation between UA and customer to be confirmed (see Open Question #26).

---

## Stage 11 — Scrap Disposition

Scrap can arise at any stage. Disposition depends on the scrap type and source.

| Scrap Type | Source Stage | Disposition |
|-----------|-------------|-------------|
| Wire rod scrap (end crop, entry scrap) | Stages 3–4 | Placed in scrap box → baled into scrap unit |
| In-process flat wire scrap (FL1/FL2) | Stages 5–6 | Follows slit material scrap procedures |
| Out-of-spec wire bundles | Stage 8 | Compacted in baler (max dimensions TBD) |
| Edge trim | Stages 5–6 | Scrap box or scrap skid (new outlet selection required) |

### Scrap Module Changes Required

- New outlet selection in Scrap module: `Scrap Box` vs. `Scrap Skid`.
- Scrap handling applies across Flat Wire, Conveyors, and Inspection systems.
- Combining flat wire scrap with other scrap types: confirmed compatible (Ryan B., no technical issues).

---

## Equipment Capacity Reference

| Equipment | Role | Capacity | Bypassable |
|-----------|------|----------|-----------|
| VPS Payoff | Rod / wire feed | 9,000 lb max (dual position) | No |
| DB1 | Wire drawing die 1 | — | Yes |
| DB2 | Wire drawing die 2 | — | Yes |
| FM1 | 12" Flattening Mill | — | No |
| TKUP-1 | Intermediate spool takeup | 3,500 lb | N/A (non-hybrid only) |
| TPO | Traversing payoff for FL2 | 3,500 lb | N/A |
| FM2 — 8" Roller | Finishing stand 1 | — | Yes |
| FM2 — 6" S1 | Finishing stand 2 | — | Yes |
| FM2 — 6" S2 | Finishing stand 3 (final) | — | **No** |
| TKUP-2 | Final coil takeup | 1,100 lb | No |

---

## Operating Routes — Comparison

| Attribute | FL1 Standalone | FL2 Standalone | FL3 Hybrid |
|-----------|---------------|---------------|-----------|
| Incoming material | Rod or round wire | Flat wire spool | Rod or round wire |
| Output | Flat wire spool (TKUP-1) | Coreless coil (TKUP-2) | Coreless coil (TKUP-2) |
| Intermediate stop | Yes — spool at TKUP-1 | N/A | No — continuous |
| Anneal option | Yes (after TKUP-1) | Not applicable | No (bypassed) |
| Gauge trace | Real-time | Historical / profile view | Real-time |
| Intermediate alpha | Yes — spool alpha generated | N/A | No |
| PLC tag push | At FL1 check-in | At FL2 check-in | At FL1 check-in |
| Scheduling entry | FL1 machine | FL2 machine | FL3 machine (hybrid) |

---

## Key Terminology

| Term | Definition |
|------|-----------|
| **Flat wire** | The product — use this term consistently; do not use "strip" |
| **Coreless oscillated coil** | Final output form — wound without a core mandrel |
| **Pass Schedule** | Database record defining active components, die sizes, roll gaps, and targets for a given product route |
| **INFLAT** | Coil/bundle status code for material currently being processed on a flattening line |
| **R-series alpha** | Rod tracking number (R00001–R99999) used in place of a coil number for rod material |
| **Hybrid / FL3** | Continuous operating mode where FL1 and FL2 run as one uninterrupted line |
| **TKUP** | Traversing Take-up — the oscillating winding mechanism that builds the coreless coil |
| **TPO** | Traversing Payoff — unwinds the intermediate spool to feed FM2 |
| **AGC** | Automatic Gauge Control — the inline feedback system maintaining target thickness during rolling |
| **Bundle Width** | The oscillation width of the wound coil — specified as a Min/Max range per order |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [FlatWirePlan.md](FlatWirePlan.md) | Full implementation plan — scope, milestones, risks |
| [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) | Open questions register — open items only; the answered questions are in [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md) |
| Shopfloor Flat Wire SRS.docx | Detailed software requirements for shopfloor screens |
| Flat Wire Coil Receiving.docx | Rod receiving SRS — screen logic and validations |
| Flat Wire Machine - Web Changes 04132026.docx | .NET web application change specifications |
| Scheduling System Wire Flattening Process 04132026.docx | Database schema changes |
| Planning System Changes 04172026.docx | Planning screen modifications |
| Flat Wire Machine - Big Beautiful Diagram.png | Equipment layout schematic |
