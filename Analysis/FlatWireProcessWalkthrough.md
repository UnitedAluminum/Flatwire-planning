# Flat Wire — Step-by-Step Process Walkthrough (Rod Check-in → Finished Coil)

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 1, 2026
**Document Type:** Process Reference — Sequential Walkthrough
**Status:** Reference — assembled from existing analysis docs; equipment facts per the May 21, 2026 client corrections

---

## Purpose & Scope

A single sequential read-through of the flat wire process, from rod procurement through pre-check-in staging, rod check-in, drawing, flattening, in-run events, both route branches (FL1 standalone via spool, and FL3 hybrid), FM2 finishing, coil completion, packing, and shipment.

This document **does not introduce new requirements**. It is a navigational overlay on the existing analysis set — [FlatWireEndToEndProcess.md](FlatWireEndToEndProcess.md) remains the stage-by-stage process reference, and the docs listed under [Related Documents](#related-documents) remain authoritative for their own subject areas.

**Equipment facts used here follow the May 21, 2026 client corrections** recorded in [`../DevelopmentPlan/ShopfloorPlan/00-foundations.md`](../DevelopmentPlan/ShopfloorPlan/00-foundations.md) §0.3, not the April-dated equipment descriptions still present in `FlatWireEndToEndProcess.md`. See [Known Source Conflicts](#known-source-conflicts).

---

## A. Before the Line — Material and Job Exist

1. **Rod purchased.** PO raised in MPS with 3D specification (gauge × diameter × length/weight). Rod arrives as bundled coils from an approved vendor.

2. **Rod received.** Operator enters the PO number — alloy, diameter, and weight pull automatically. Operator enters gross (scale) and net weight. System validates scale-vs-vendor weight tolerance and the presence of rod chemistry documentation; **either failing suspends the material**.

3. **Rod alpha assigned** — `R#####`, no gaps, per lot. Coils-table entry created with gauge populated; width / OD / ID / surface finish stay blank (rods have no width). Bundle moves to rod storage. Rod status `RECEIVED`.

4. **Order → IQR → Item Template.** Sales creates the order with the Flat Wire checkbox: bundle width Min/Max, edge type (round or flat), alloy, temper, gauge. The item template defines the route — e.g. `Rod → DRAW → FLATTEN`, or with an anneal step inserted mid-route.

5. **Planning.** Planner filters `Flatwire`, selects rod material, and enters **weight only** — the system computes the number of stops and **generates all alphas at planning time**, including a remainder alpha for unused weight ("Assign as-is" routes the remainder to stock). "Number of Cuts" and "Number of Stops" are not used for flat wire.

6. **Scheduling.** Job booked on **FL1**, **FL2**, or **FL3** — three separate machines with separate bookings. Operation letter `F`; coil/bundle status becomes `INFLAT` when active on the line. FL3 cannot run if there are scheduled orders on FL1 or FL2.

7. **Pass schedule must already exist** — `PS-{alloy}-{line}-{seq}`, manually maintained by Operations/Maintenance on Dashboard 9 / 9A. It is never auto-generated, and no check-in can proceed without an active one. It defines component active/bypass, die sizes, edge type per edger, roll clearances, gauge and width targets, and route mode (standalone vs hybrid).

---

## B. Pre-Check-in — Rod Staged at the Payoff

8. **Rod moved to the VPS** (Variable Position Payoff) — dual position, eye-to-sky, 9,000 lb per position. Rod is staged against an intended payoff position (1 or 2) on **Dashboard 2A — Rod Pre-Check-in Station**, recorded as a `RodStaging` row, and may later carry the `IsWelded` flag once the operator records the weld. One rod per bay is enforced by the database. Full detail: [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md).

   > **DECIDED (client, 30 Jul 2026) — `RECEIVED → STAGED` is correct, and this document is the winning source (Q67).** `coils.coil_status` becomes **`INFLAT` only when the rod is actually checked in at FL1**, and there is **no intermediate status** for a rod that is welded but not yet checked in. ~~The SRS §4.2 `PCI` data note has pre-check-in setting `coil_status = INFLAT`; the interim design followed it, making rod status `STAGED` vestigial for FL1.~~ **That note is superseded** for the status, and rod status `STAGED` is the real staging status. Unblocks the Phase 4 staging build.
   >
   > **Residual:** the same data note also performs the `FlatwireQueue` insert, the reqsum and the `wip_coil_orders` insert. Whether **those** stay at pre-check-in is unanswered — sent back to Tim O. / IT. If they do, staging still spans three databases as compensating writes (**G2/G16**); if they move to check-in, pre-check-out becomes a pure `FlatWireDB` delete.

9. **Visual inspection before unbanding** — oxidation, surface defects, water stains. Bundles are **not unbanded until positioned at the payoff** (safety and bundling integrity). Any fail: add observation → **Dashboard 8 (WIP Rejection)**. This is a hard block with no bypass.

---

## C. Rod Check-in (Dashboard 2, FL1 / FL3) — the Gate for Everything

10. **Operator opens the 6-step guided wizard** (`Mockups/dashboard_2_rod_checkin - New.html`): ① Visual Inspection → ② Pass Schedule → ③ Pre-run SPC → ④ Die Block (DB1 · DB2) → ⑤ Rolling Mill (FM1) → ⑥ Lube & Safety. Tabs unlock in sequence.

11. **Bundle data entered:** rod alpha (scanned or typed, validated against the R-series), diameter, gross/net weight, payoff position. Alloy, temper, and diameter pre-populate from the PO/order. **FL1 has no edger** — no edge-set fields appear on this screen.

12. **Pre-run SPC recorded** — incoming rod diameter, measured manually, written as an SPC checkpoint (`SPC-####`, type Pre-Run) against the rod alpha.

13. **Pre-flight validation.** The acknowledge action stays disabled until: rod alpha valid, diameter + weights + payoff filled, all three inspection items = Pass, pre-run SPC entered, and a pass schedule is loaded (otherwise "No active pass schedule for this order — contact Operations").

14. **Pass-schedule confirmation dialog** — the operator explicitly confirms the schedule identity, or selects a different active schedule, which requires a free-text reason. **PLC tags are never pushed before this confirmation is accepted.**

15. **System writes audit records first, before the PLC push:** visual inspection result, pre-run SPC, pass schedule ID + version + effective date onto the run record, and the acknowledgement event. If the PLC write then fails, an incomplete-push marker exists to recover from.

16. **PLC tag push** — component activation flags, die sizes, roll gaps, speed limits, gauge/width targets. Logged with timestamp, pass schedule ID, and the operator who triggered it.

17. **Run starts.** `FlatWireRun` header created (`RUN-####`), run timer starts, rod status → `INFLAT`, Dashboard 1 shows the line **RUNNING** with the pass schedule ID, and the screen transitions to **Dashboard 3 — Active Run Monitor**.

---

## D. Drawing and Flattening (FL1 / FL3 Front End)

18. **DB1 → DB2 wire drawing.** Each die block reduces diameter toward target and can be **bypassed** by the pass schedule if the rod is already at size. Purpose is roundness correction and precise diameter for consistent flattening. Wet lubricant is applied; residue is a downstream handling consideration. If both are bypassed, rod feeds FM1 at its as-received diameter.

19. **FM1 — 12" flattening mill.** The primary transformation: round wire becomes flat wire. Roll gap and speed are driven by the pass schedule; the **dancer** manages tension across speed variations; **gauge stands** measure gauge and width continuously and **AGC** holds target without operator intervention. This is the **real-time gauge trace** (FL1 and FL3 both real-time).

20. **Live telemetry streams** to Dashboards 3 and 1 over `FlatWireHub` (`GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`, `LineStatus`, alert events), persisted as time-series in `RunReading`. Per-line groups `FL1Data` / `FL3Data`.

---

## E. Events That Can Interrupt the Run (any number, any order)

21. **Weld for continuous feed (Dashboard 2A — *Mark as welded*).** Payoff 1 drops below 3,000 lb → "prepare weld" alert; a new bundle is pre-loaded on Payoff 2. Operator **induction-welds** rod tail to rod head (laser welding was dropped as not viable) and logs the event: weld footage auto-captured from the counter, incoming rod alpha, weld quality pass/fail. From that footage forward, output is attributed to the new rod — this is the `CoilTraceability` genealogy required for welding-wire customer certs. The line does not stop.

22. **Die change (Dashboard DC).** Triggered by die wear, gauge drift, failure, or size change. Logged as `DC-####` with reason code, followed by a **mandatory post-die-change SPC** (manual wire diameter, plus FM1 gauge and width).

23. **Roll adjust (Dashboard 11, FL3).** FM2 roll-gap adjustment mid-run, logged as a roll override `OVR-####`.

24. **SPC checkpoints (Dashboard 6).** Manual: pre-run, post-DB1, post-die-change, manual spot check. Automatic (AGC): FM1 output and **FM2 final-stand (S3) output**. Out of spec → operator either continues the run or suspends the material, which auto-opens Dashboard 8.

25. **Pause / resume.** Logged as a `RunPauseEvent` with reason; Dashboard 1 flips RUNNING → PAUSED with the reason visible to the supervisor.

26. **WIP rejection (Dashboard 8).** `REJ-####` with rejection reason and disposition; material suspended or scrapped.

27. **Rod checkout (Dashboard 12).** Two distinct paths:

    - **Pre-run** (footage = 0): reason code, then return-to-floor (`STAGED`) or return-to-warehouse (`RECEIVED`). Payoff position cleared, pass schedule acknowledgement voided, PLC tags cleared for that position.
    - **Mid-run** (footage > 0): reachable **only** through the Pause dialog. Footage is locked from the PLC counter and the checkout **requires supervisor approval** — a PENDING DISPOSITION record locks the material with **no alpha generated yet**; the supervisor remotely Accepts (partial spool alpha issued, enters spool queue), Holds (alpha issued with QC hold), or Rejects (WIP Rejection → scrap).

    In both paths the application first reads `FL1.LineState` and **blocks checkout while the line is running**. The operator stops the machine physically; the software never issues a stop command — it is a gatekeeper, not a remote stop controller.

---

## F. The Route Split at FM1 Output

### Route A — FL1 Standalone (produces WIP, not finished goods)

28. **Flat wire winds onto TKUP-1** (Traversing Take-up, 3,500 lb) as an intermediate **spool**.

29. **Per-spool SPC** for gauge and width. **Spool alpha `SP-#####`** generated, carrying source rod alphas, measured width, gauge, calculated weights, and the **stored gauge profile including weld markers**.

30. **Spool label printed and applied** — temp spool no., alloy, width, gauge, temper, gross/net weight, source rod alphas. The *traveler* itself is fully digital; only coil / spool / skid labels print.

31. **Optional anneal** if the temper requires it. Decided May 4, 2026: the **existing spool alpha is modified, not re-issued** — no child alpha is generated; the anneal is recorded as an event against it. Physical tracking is tow motor → furnace → cooling → FL2.

32. **Back into planning.** Spool sits in warehouse inventory (`ACTIVE`); planner allocates weight to an order (`IN-PLAN`) and the remainder receives a child alpha; scheduling books it on FL2 and it moves to the TPO (`IN-USE`).

33. **FL2 spool check-in (Dashboard 5).** Spool loaded onto the **TPO** (Traversing Payoff, 3,500 lb). Operator enters or confirms spool alpha, gauge, width, weight. The screen shows source rods and the **historical gauge profile from the FL1 run with weld points marked** — FL2's trace is historical/profile, not live (FL2 standalone broadcasts `null` live gauge/width). **No visual inspection** — already performed at FL1. Same mandatory pass-schedule confirmation dialog, then FM2 tags are pushed (roll gaps and stand states for S1/S2/S3, plus edger activation and edge type at S2 and S3) and the FL2 run starts, linked to the spool and its source rod alphas.

### Route B — FL3 Hybrid (produces finished goods in one pass)

34. **TKUP-1 is bypassed.** Material flows continuously from FM1 through the TPO directly into FM2 — no intermediate stop, **no spool alpha or label, no intermediate anneal, and no FL2 check-in step**. The gauge trace stays real-time end to end, and a single unified `PS-{alloy}-FL3-{seq}` schedule covers the FL1 and FL2 components together.

---

## G. FM2 Finishing — Both Routes Converge

35. **Material passes FM2's three stands in sequence:** **S1 — 8" roller** (bypassable) → **S2 — 6" roller + edger** (bypassable) → **S3 — 6" roller + edger**. **Edgers sit at S2 and S3 only** — the two 6" stands. **S3 is mandatory** — it is the final gauge-control stand and cannot be bypassed.

36. **Automatic gauge and width measurement after the final 6" roller** (AGC), recorded as an SPC checkpoint.

37. **Output winds at TKUP-2** (1,100 lb equipment maximum; customers may specify a lower limit in the order) as a **coreless oscillated coil** — wound with no core mandrel, oscillation width per the order's bundle-width Min/Max range.

---

## H. Coil Completion, Packing, Shipment

38. **Output coil completion (Dashboard 7).** Coil alpha `FW-#####-C##` issued (mid-run child `…-A` when a coil is closed early). Footage from the counter; net weight = footage × density factor; gross weight confirmed. Final SPC gauge and width evaluated against tolerance.

39. **Source traceability captured** — every contributing rod alpha with its footage-from / footage-to range and the weld points between them, plus the spool alpha on the non-hybrid route. Full chain: `R00041 → SP-00031 → FW-00421-C01 → SK-00201`.

40. **Disposition.** In spec → alpha released, proceed to packing. Out of spec → WIP rejection with reason, material suspended. Edge defect → judged against the edge-type spec, scrap or rework decision.

41. **Coil label printed** — alpha, alloy, gauge, width, temper, gross/net weight, lot number, footage, source rod alphas. Gauge and width print the **target** value when SPC confirms in tolerance; the measured value is shown only when out of tolerance.

42. **Skid tracking.** Exactly **2 coreless coils per skid** (consistent with transformer-line packaging). The first coil opens skid `SK-#####`; the second closes it, prints the skid label, and queues it for packing with a staging location.

43. **Packing station.** Pack spec applied per order: coil orientation eye-to-side or eye-to-sky, optional layer interleave between winding layers, banding steel vs aluminum alloy (TBD). No Inspection Bench changes.

44. **Certification & shipment.** Certificate of Conformance generated with chemistry, mechanical properties, dimensional data, alloy, temper, and traceability to source rod heat. **Welding-wire customers additionally require every weld join to be traceable** on or alongside the cert, and may impose a contractual maximum number of welds per coil. Material released from inventory and shipped.

---

## I. Scrap — Parallel Path From Any Stage

45. Rod end-crop / entry scrap → scrap box → baled into a scrap unit. In-process FL1/FL2 flat wire scrap → follows slit-material scrap procedures. Out-of-spec wire bundles → compacted in the baler. Edge trim → scrap box or scrap skid (requires the new outlet selection in the Scrap module).

---

## Route Comparison at a Glance

| Attribute | FL1 Standalone | FL2 Standalone | FL3 Hybrid |
|---|---|---|---|
| Incoming material | Rod or round wire | Flat wire spool | Rod or round wire |
| Output | Flat wire spool (TKUP-1, 3,500 lb) | Coreless coil (TKUP-2, 1,100 lb) | Coreless coil (TKUP-2, 1,100 lb) |
| Intermediate stop | Yes — spool at TKUP-1 | N/A | No — continuous |
| Anneal option | Yes (after TKUP-1) | Not applicable | No (bypassed) |
| Gauge trace | Real-time | Historical / profile | Real-time |
| Intermediate alpha | Yes — `SP-#####` | N/A | No |
| Edger | **None on FL1** | S2 and S3 only | S2 and S3 only (FM2 side) |
| PLC tag push | At FL1 check-in | At FL2 check-in | At FL1 check-in |
| Scheduling entry | FL1 machine | FL2 machine | FL3 machine (hybrid) |

---

## Alpha Reference (used above)

| Entity | Format | Example |
|---|---|---|
| Rod | `R#####` | R00041 |
| Spool | `SP-#####` | SP-00021 |
| Run | `RUN-####` | RUN-0114 |
| Pass schedule | `PS-{alloy}-{line}-{seq}` | PS-1100-FL1-003 |
| Weld event | `WLD-###` | WLD-042 |
| Die change | `DC-####` | DC-0117 |
| Roll override | `OVR-####` | OVR-0088 |
| SPC checkpoint | `SPC-####` | SPC-0231 |
| WIP rejection | `REJ-####` | REJ-0019 |
| Rod checkout | `CO-####` | CO-0007 |
| Output coil | `FW-#####-C##` (child `…-A`) | FW-00421-C01 |
| Skid | `SK-#####` | SK-00201 |
| Die tooling | `D-{size×1000}-{seq}` | D-310-034 |

---

## Known Source Conflicts

[FlatWireEndToEndProcess.md](FlatWireEndToEndProcess.md) is April 28, 2026-dated and predates the client equipment corrections. Where it disagrees with this walkthrough, the **May 21, 2026 corrections win** ([`../DevelopmentPlan/ShopfloorPlan/00-foundations.md`](../DevelopmentPlan/ShopfloorPlan/00-foundations.md) §0.3):

| Topic | April source says | Authoritative (May 21, 2026) |
|---|---|---|
| Weld types | Induction (rod-to-rod) **and** laser (flat-to-flat) | **Induction only** — laser removed, not viable |
| FM2 stands | 8" → 6" S1 → 6" S2 (S2 final, mandatory) | **Three stands: `S1` 8" → `S2` 6" → `S3` 6"**; **S3** is the final mandatory stand. *(Corrected 4 Aug 2026 — an intermediate revision read this as a separate 8" roller plus three 6" stands; the 8" roller **is S1**.)* |
| Edgers | Single edger shown in FM2 sequence; edge set listed on FL1 | **Edgers at S2 and S3 only**; **FL1 has no edger** |
| Traveler | Printing implied | **Fully digital** — coil/spool/skid labels still print |

Terminology rule throughout: always "flat wire," never "strip."

---

## Related Documents

| Document | Relevance |
|---|---|
| [FlatWireEndToEndProcess.md](FlatWireEndToEndProcess.md) | Stage-by-stage process reference; equipment capacity table; scrap dispositions |
| [FlatWirePlan.md](FlatWirePlan.md) | Rod receiving validations, pre-check-in inspection, planning and machines application changes |
| [RocCheckin.md](../LatestDocument/RequirementDocuments/RocCheckin.md) | "Acknowledge & Begin Check-in" flow for Dashboards 2 and 5 (steps 13–17, 33) |
| [Spool.md](Spool.md) | Spool lifecycle, anneal alpha handling, planning allocation and remainder (steps 28–33) |
| [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) | Operator alert at 75 / 90 / 100 % of target spool weight as the take-up fills (step 28) |
| [RodCheckout.md](../LatestDocument/RequirementDocuments/RodCheckout.md) | Pre-run and mid-run checkout, PLC line-state gatekeeper rule (step 27) |
| [PartialRodReCheckin.md](PartialRodReCheckin.md) | Carry-forward design for re-checking-in a partially run rod |
| [WeldEvent.md](../LatestDocument/RequirementDocuments/WeldEvent.md) | Weld traceability detail (step 21) |
| [SPCCheckpoint.md](../LatestDocument/RequirementDocuments/SPCCheckpoint.md) | Checkpoint types, tolerances, disposition rules (step 24) |
| [DieChangeAndManagement.md](../LatestDocument/RequirementDocuments/DieChangeAndManagement.md) | Die change flow and tooling inventory (step 22) |
| [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) | All dashboard specifications referenced by number |
| [PLCTagSpecification.md](../LatestDocument/RequirementDocuments/PLCTagSpecification.md) | The machine tag surface — what is written at each step, what is read, and the tag lifecycle across all sixteen moments |
| [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) | Open decisions that affect steps above (~59 items) |
| [`../DevelopmentPlan/ShopfloorPlan/00-foundations.md`](../DevelopmentPlan/ShopfloorPlan/00-foundations.md) | §0.3 domain cheat-sheet (authoritative equipment facts, alphas, hub events), §0.4 real-time architecture |

---

## Change Log

| Date | Changed By | Description |
|------|-----------|-------------|
| July 28, 2026 | Analysis Team | Initial document — sequential 45-step walkthrough from rod procurement to shipment, covering pre-check-in staging, Dashboard 2 check-in gate, in-run events, both route branches, FM2 finishing, coil completion and packing. Equipment facts aligned to the May 21, 2026 client corrections; April-source conflicts catalogued. |
| July 29, 2026 | Analysis Team | Step 8 (pre-check-in) corrected: staging is now a `RodStaging` row set on **Dashboard 2A**, not the retired `Rod.StagedPayoffPosition`/`IsWelded` columns. The `RECEIVED → STAGED` status claim is flagged as **Q67** — SRS §4.2 has pre-check-in committing the coil to `INFLAT` instead, and the conflict is unresolved. See [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md). |
| Aug 1, 2026 | Client sync (30 Jul call) | **Step 8's coil status resolved in this document's favour.** The client confirmed `INFLAT` is set **only at check-in**, with no welded-not-checked-in status — so the original `RECEIVED → STAGED` wording stands and the SRS §4.2 `PCI` data note is superseded for the status (**Q67**, Critical, unblocks Phase 4). The reqsum / `wip_coil_orders` half of that note is still open. |
