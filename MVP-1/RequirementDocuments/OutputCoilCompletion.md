# Flat Wire Processing — Output Coil Completion and Labelling Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL2 / FL3 (finished goods). FL1 produces an intermediate spool, not a finished coil.
**Version:** 1.3
**Last Updated:** August 12, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 7 — Output Coil Completion & Label · **Dashboard 7b — Packing Station**
**Requirement source:** SRS output and packing rules; coil alpha format `FW-#####-C##`; the May 21 2026 target-value display correction

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Aug 11, 2026 | **First issue.** Consolidated from the shopfloor dashboard design reference, which was the only home for this screen, together with the source-traceability capture block from the spool material reference. Carries the coil detail set, the traceability chain, the final quality confirmation, the skid rule, the label field list, and the May 21 2026 decision that dimensions print as target values when in tolerance. Screen styling, layout dimensions and scripting detail removed for the client issue. |
| 1.1 | Aug 11, 2026 | **Dashboard 7b (Packing Station) brought under this document — new §8.** DB7b had requirement text (`FR-345`–`FR-352`) but **no owning specification**, the one dashboard in scope without one. It is placed here rather than in a separate document because DB7 and DB7b are a single operator flow: *Confirm & Move to Packing* on DB7 is what creates DB7b's arrival, and the two-per-skid rule of §6 opens on one screen and closes on the other. Sections 8–11 renumbered to **9–12**; §4, the only section cited externally, is unmoved. Two open items raised and registered in master spec §11 — **`OI-105`** the authoritative weight (§8.2) and **`OI-106`** staging locations (§8.3) — plus **`OI-104`**, the skid table that `CoilOutput.SkidId` points at and that nothing names, creates or verifies. **`OI-24`** (lot number has no generator at all) and **`OI-99`** (lot number for a multi-rod coil) are restated as packing blockers rather than labelling ones. All five are carried in §10 and on the client sign-off sheet, and the set is registered as gap **`G36`**. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 10. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

This is the point at which flat wire becomes a finished, saleable, identified product. A coreless oscillated coil completes on the take-up, and the operator confirms its identity, its dimensions, its weight, the source material that produced it, and its place on a skid. The coil alpha is generated here, and the physical label that follows the coil to the customer is printed here.

## 1.2 Why it matters commercially

Everything that has been tracked through the run — which rods were welded together, at what footage, and whether each measurement was in specification — converges on this record. If the genealogy is wrong here, a welding-wire customer certificate cannot be produced, and a later field failure cannot be traced back to a source rod heat. This screen is the last opportunity to get it right while the material is still in front of an operator.

## 1.3 Scope

**In scope:** coil identification and alpha generation, the dimensional and weight record, the source traceability chain, final quality confirmation, skid tracking and closure, coil and skid label content, and printing — **and, from §8, the packing station at which the coil is physically received, verified against a scale, seated on its skid and released to staging.**

**Not in scope:** the SPC checkpoint itself; shipment beyond the staged skid; certification document generation; the intermediate spool produced by an FL1 standalone run, which is not a finished coil.

**Two screens, one flow.** Dashboard 7 is at the take-up and is operated by the line operator; Dashboard 7b is at the packing station and is operated by the packing operator. They are specified together because the skid rule spans them — §6 opens and closes the skid logically, §8 seats and stages it physically — and because the coil's weight is captured on both.

## 1.4 The traveler is digital — labels are not `[CONFIRMED — April 28, 2026]`

Traveler printing is disabled for flat wire; the traveler is fully digital. **This does not extend to labels.** The coil label and the skid label are physical, they are printed here, and they are required — a coil without a label on the floor cannot be identified. This distinction has been misread before and is stated explicitly for that reason.

---

# 2. Position in the Process

A coil completes when the take-up reaches the planned output weight for the order, or when the run ends for another reason — a short close, an unplanned stop, or a mid-run coil break. The weight milestone alerts that lead up to this moment, and the confirmation dialog raised when the machine stops, are specified in the Spool Completion Notification document. **This screen is what follows that confirmation.**

---

# 3. Coil Details

## 3.1 Identification `[CONFIRMED]`

| Field | Source |
|---|---|
| **Coil alpha** | System-generated on completion, in the form `FW-#####-C##` — the order number and a sequential coil number within that order |
| Order | The active run's order |
| Alloy | From the order |
| Temper | From the pass schedule or the order |

A coil created by a **mid-run break** takes a child suffix rather than a new sequence number, so that the break is visible in the identifier itself.

## 3.2 Dimensions — target values when in tolerance `[CONFIRMED — May 21, 2026]`

Gauge and width are displayed and printed as the **target value** when the final quality check confirms the coil is within tolerance. **No average measured value is displayed.** A measured value appears only when the coil is out of tolerance.

**This was a deliberate client correction to an earlier design** that displayed an average of measured readings. An averaged dimension on a customer-facing label invites a dispute the label cannot settle: the customer's incoming inspection measures one point, the average describes the whole coil, and the two will not agree. The target value, certified as within tolerance, is the commercially meaningful statement.

## 3.3 Weight `[CONFIRMED — formula and density]`

| Field | Basis |
|---|---|
| **Net weight** | **Calculated** from footage and cross-sectional area, using the alloy density held as reference data. **Never taken from a scale during rolling** |
| **Gross weight** | Net weight plus packaging |
| **Footage** | From the footage counter at completion |

**The calculation and the density source are settled.** Net weight per foot is the cross-sectional area multiplied by a per-alloy constant derived from the alloy's density, with a correction applied to the area where the edge type is round. The density values are held as reference data against the alloy, not entered on this screen.

**The operator may override the calculated figure with a scale reading**, and the screen shows the derivation so the operator can see what they are overriding. A variance threshold applies between the scale reading and the calculated value; exceeding it requires a supervisor override.

> `[CLIENT INPUT REQUIRED]` **The dimensional basis for the calculation is not settled, and it is the substantive remaining question** (`OI-45`). Weight can be derived from **target** dimensions, from a **measured value at completion**, or by **integrating the live readings across the run**. Integration is our recommendation: deriving weight from target dimensions carries a tolerance stack of roughly ±2.6 %, which is *wider than the ±2 % variance threshold* the scale comparison uses — meaning a coil that is perfectly in specification can trip the supervisor override for no reason. Integration also uses data the system already records. **FL2 standalone must fall back to pass-schedule targets**, because it broadcasts no live gauge or width.
>
> Three further sign-offs sit under the same item: whether the round edge is a true semicircle or a partial radius (it changes the area coefficient), Process Engineering confirmation of the density values themselves, and the treatment of tail loss in the net-from-gross calculation.

---

# 4. Source Traceability

## 4.1 The chain `[CONFIRMED]`

The screen shows every source rod that contributed material to this coil, and the footage range each one produced:

```
SOURCE TRACEABILITY
┌──────────────┬────────────────┬───────────────────────────┐
│ Rod Alpha    │ Footage From   │ Footage To                │
├──────────────┼────────────────┼───────────────────────────┤
│ <rod alpha>  │ 0 ft           │ <weld footage>            │
│ <rod alpha>  │ <weld footage> │ <coil end footage>        │
└──────────────┴────────────────┴───────────────────────────┘
```

Each row is bounded by a weld. The chain therefore states, for any point in the finished coil, which source rod is at that point — which is exactly what a welding-wire customer certificate requires.

## 4.2 What is recorded

| Element | Purpose |
|---|---|
| Contributing source rod alphas | The genealogy, in process order |
| Footage range per rod | Locates any point in the coil to its source material |
| Weld positions | Where each rod change occurred |
| Originating spool alpha | Present when the coil was produced on FL2 from an FL1 spool. Absent on a continuous FL3 run, where there was no intermediate spool |

## 4.3 Hybrid runs have no intermediate spool

On FL3 the rod feeds through to the finished coil in one pass, so the chain runs from rod alphas directly to the coil. On FL2 it runs rod alphas → spool alpha → coil. Both are valid, and the record must distinguish them rather than leaving the spool field empty and ambiguous.

> `[CLIENT INPUT REQUIRED]` **The spool identifier and its format are still open** (Q76 / OI-02), and the spool status vocabulary is unmapped (OI-06). Until the identifier is settled, the FL2 branch of this chain cannot be enforced.

---

# 5. Final Quality Confirmation

The final quality check for the coil is displayed here as a pass or fail against gauge and width, with the target and tolerance in force. It determines whether Section 3.2 prints target or measured values.

**This screen displays that result; it does not capture it.** The measurement is taken at the SPC checkpoint on the final stand output, and that checkpoint is specified separately. A coil cannot be confirmed here while a quality hold is open against the footage range it covers.

---

# 6. Skid Tracking

## 6.1 The rule `[CONFIRMED]`

**A skid holds exactly two coreless coils**, consistent with UA's existing coil packaging.

| Coil | Effect |
|---|---|
| First coil | The skid is opened and the coil alpha is linked to it |
| Second coil | The skid is closed, the skid label is printed, and the skid moves to the packing queue |

The operator confirms which of the two the coil is, and the screen states the consequence — *skid remains open* or *close skid and print skid label* — on the control rather than in a separate confirmation.

## 6.2 Skid identity

The skid carries its own identifier, and both coil alphas are linked to it, so that a skid arriving at packing resolves to two full traceability chains.

> `[CLIENT INPUT REQUIRED]` **(OI-98) What happens to an odd final coil** is not specified. An order producing an odd number of coils leaves one skid holding a single coil. Whether it ships as a part skid, waits for a coil from another order, or is closed short needs an answer before packing can be built (OI-98).

---

# 7. Labels

## 7.1 Coil label content `[CONFIRMED]`

| Field | Content |
|---|---|
| Coil alpha | System-generated |
| Alloy | From the order |
| **Gauge** | Target value when in tolerance; measured value only when out of tolerance |
| **Width** | Target value when in tolerance; measured value only when out of tolerance |
| Temper | From the pass schedule or order |
| Gross weight | Per §3.3 |
| Net weight | Calculated from footage and density |
| Footage | From the footage counter |
| Lot number | Linked to the source rod lot |
| Source rod alphas | Every rod in the traceability chain |

## 7.2 Width is the flat wire width

The label states the flat wire's width. Where the existing shared schema names this field for strip products, the flat wire naming applies — the product is flat wire, never "strip", on any customer-facing document.

> `[CLIENT INPUT REQUIRED]` **(OI-99) Lot number derivation is undefined when a coil has more than one source rod**, which is the normal case under continuous welded feed. If two rods from different heats contribute, the coil has two lots. Whether the label carries both, the dominant one, or a composite is a certification question, not a layout one (OI-99).

## 7.3 Reprinting

A label can be reprinted for a completed coil — labels are damaged and lost on a shopfloor. A reprint is recorded, so that two labels bearing one alpha can be explained.

---

# 8. Packing Station — Dashboard 7b

The coil leaves Dashboard 7 confirmed but not yet physically handled. The packing station is where it is received, weighed against a scale, seated in its skid slot, labelled and staged. **Nothing here re-opens the coil record** — the alpha, the traceability chain and the dimensional record are fixed at §3–§5. What the station adds is physical confirmation and a location.

## 8.1 The arrival `[PROPOSED]`

The station shows the incoming coil with the context needed to identify it without consulting another screen: **alpha, time confirmed, the operator who completed it, alloy, gauge, width, footage, net weight, and the skid and slot it has been assigned.** A **pending arrivals** panel shows, per line, what is coming and roughly when, so the station can be staffed against the line rather than waiting on it.

Both are our design recommendation rather than a stated requirement, and are marked accordingly.

## 8.2 Coil verification and the second weight `[CLIENT INPUT REQUIRED]`

The operator confirms physical receipt and **captures a scale weight**. The screen shows the calculated net weight beside it, states how the calculation was derived, and displays the **variance** between the two.

> `[CLIENT INPUT REQUIRED]` **(OI-105) Which weight is authoritative on the coil record is undecided, and this is a new question rather than a restatement.** The coil already carries a weight from §3.3 — calculated from footage and density, which the Dashboard 7 operator may override with a scale reading. The packing station now produces a **third** figure. Three rules are possible and they are not equivalent: the scale weight replaces the record; the scale weight is recorded alongside and the calculated figure remains authoritative; or a variance beyond a threshold blocks the skid from closing. The label has already been printed by this point under §7, so a rule that changes the weight after printing forces a reprint. **This compounds `OQ-10` / `OI-45`**, the unsettled dimensional basis for the footage→weight conversion — the variance cannot be judged until the basis is fixed.

## 8.3 The skid, its slots, and closing it `[CONFIRMED — the rule]`

A **skid slot layout** shows both slots with their alphas and individual weights, and the combined net weight. The two-coil rule is §6.1 and is not restated here.

**Closing the skid** assigns a **staging location**, prints the skid label, marks both coil labels confirmed, and returns the operator to the queue.

> `[CLIENT INPUT REQUIRED]` **(OI-106) Staging locations are not defined.** The station is required to assign one on closure, but no list of valid locations, no capacity per location, and no rule for choosing between them exists in any source document. A free-text field would defeat the purpose.

> `[CLIENT INPUT REQUIRED]` **(OI-98) The odd final coil blocks this screen, not only §6.2.** An order producing an odd number of coils leaves a skid holding one coil, and this station cannot close it. Whether it stages as a part skid, waits, or closes short determines what the *Close Skid* control does in that case (OI-98).

## 8.4 Labels at the station

A **coil label** panel previews the label and prints it on confirm — the content is §7.1, unchanged. The station also presents **guided packaging prompts** confirming correct coil orientation and wrapping before the skid closes.

> `[CLIENT INPUT REQUIRED]` **(OI-99) The lot number remains unresolved and is printed here.** Under continuous welded feed a coil normally has more than one source rod and therefore more than one lot. §7.2 raises this for the label's content; the packing station is where the unresolved label is physically applied (OI-99).

## 8.5 Shift view

A **skids-this-shift** table lists skid, line, coils, weight, closed time, staging location and status, so the station has its own record of the shift without depending on the supervisor's shift summary — which is not in this scope.

## 8.6 Requirement mapping

| Requirement | Covered in | Basis |
|---|---|---|
| `FR-345` arrival with completion context | §8.1 | Mockup DB7b — `[PROPOSED]` |
| `FR-346` verification and scale weight | §8.2 | Mockup DB7b — `[PROPOSED]`, and the authoritative-weight question is open |
| `FR-347` skid slot layout | §8.3 | `PKG003` |
| `FR-348` coil label preview and print | §8.4 | `PR004` |
| `FR-349` skids-this-shift table | §8.5 | Mockup DB7b — `[PROPOSED]`, `Should` |
| `FR-350` pending arrivals | §8.1 | Mockup DB7b — `[PROPOSED]`, `Should` |
| `FR-351` close skid → staging, labels, return | §8.3 | `PKG002`, `PKG003` |
| `FR-352` guided packaging prompts | §8.4 | `PKG004` |

**Four of the eight are mockup-derived and have never been client-reviewed** — `FR-345`, `FR-346`, `FR-349` and `FR-350`. They are tagged `[PROPOSED]` above and carried into the sign-off sheet for that reason. The other four trace to SRS source IDs.

---

# 9. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | **Gauge and width print as target values when in tolerance**, with no average displayed; measured values appear only out of tolerance | May 21, 2026 |
| D2 | **A skid holds exactly two coreless coils**; the second closes it and prints the skid label | Apr 2026 |
| D3 | The **traveler is fully digital**, but coil and skid labels **are** printed | Apr 28, 2026 |
| D4 | Net weight is **calculated** from footage and cross-section using the alloy density held as reference data, **never read from a scale during rolling**; the operator may override with a scale reading | Apr 2026 |
| D5 | The coil alpha is **system-generated** as `FW-#####-C##`; a mid-run break takes a child suffix | Apr 2026 |
| D6 | The traceability chain records **footage ranges per source rod**, bounded by welds | Apr 2026 |

---

# 10. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-45** | High | **The dimensional basis for net weight** — target, measured at completion, or integrated across the run; plus the round-edge coefficient, density sign-off and tail-loss treatment (§3.3) | Every net weight, label, yield figure and the ±2 % scale variance rule |
| **OI-105** | **High** | **Which weight is authoritative on the coil record** (§8.2). Three figures now exist — calculated, the Dashboard 7 operator override, and the packing-station scale reading. Does the scale replace the record, sit alongside it, or block skid closure beyond a variance threshold? The label is printed before the station sees the coil, so a rule that changes the weight afterwards forces a reprint | Packing station confirmation, the label's accuracy, and the yield figures downstream. Cannot be judged until **OI-45** fixes the basis |
| **OI-24** | **High** | **Lot number has no column and no generator at all**, before the multi-rod question is even reached. `GET /coil/{alpha}/label` returns it and §7.1 prints it | The label cannot be rendered |
| **OI-99** | High | **Lot number when a coil has multiple source rods** — both, dominant, or composite? | Certification content, and the label physically applied at §8.4 |
| **OI-104** | **High** | **The skid table `CoilOutput.SkidId` points at has never been located.** Described everywhere as "the existing skid table", but nothing names, creates or verifies it | Skid closure and the skid label at §8.3. `phase-09`'s estimate assumes it already exists |
| **OI-106** | **Medium** | **Staging locations are undefined** (§8.3). Closing a skid must assign one, but no valid list, no capacity and no selection rule exists in any source document | Skid closure; without it the field is free text and the record is unusable |
| **OI-98** | Medium | **The odd final coil** — part skid, held for another order, or closed short? | Skid closure and the packing queue — and specifically what *Close Skid* does at §8.3 |
| **Q76 / OI-02** | Medium | **Spool identifier and format** | The FL2 branch of the traceability chain |
| **OI-06** | Medium | **Spool status vocabulary** — two unmapped sets | Resolving a spool to its coils |
| **Q18** | Medium | **Customer minimum and maximum coil weight range** | Whether a completing coil is short, on target, or over |

---

# 11. Assumptions

| # | Assumption |
|---|---|
| A1 | The footage counter at coil completion is accurate and is the basis for net weight; no independent length measurement is taken. |
| A2 | Weld positions recorded during the run are complete — a weld that was not captured cannot be reconstructed here. |
| A3 | A label printer is available at the take-up, and label stock is a consumable managed outside this system. |
| A4 | The order carries the product specification that supplies target dimensions and tolerances. |
| A5 | ~~Packing operates from the skid queue this screen writes to; its internal workflow is outside this specification.~~ **Superseded at v1.1** — the packing station is now §8 of this document, so its workflow is inside the specification. |
| A6 | A scale is available at the packing station, and it is a different instrument from any scale used for the §3.3 operator override. |
| A7 | A label printer is available at the packing station for the skid label, independently of the take-up printer in A3. |

---

# 12. Related Specifications

| Document | Relationship |
|---|---|
| [Spool Completion Notification](./SpoolCompletionNotification.md) | The weight milestones and machine-stop confirmation that precede this screen |
| [Active Run Monitor](./ActiveRunMonitor.md) | The run this coil completes, and the source of the weld markers |
| [SPC Checkpoint](./SPCCheckpoint.md) | Captures the final-stand measurement this screen displays |
| [Weld Event](./WeldEvent.md) | Produces the traceability chain rendered in §4 |
| [Rod Check-in](./RocCheckin.md) | Where the source rod or spool entered the run |
| [Spool Queue](./SpoolQueue.md) | The FL2 material whose alpha appears in the chain |
| [WIP Rejection](./WipRejection.md) | Where a coil failing final check is dispositioned instead of completed |
| [Shift Summary](../../MVP-2/RequirementDocuments/ShiftSummary.md) | Counts coils out and skids closed from this screen |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.4 | Traveler is digital; coil and skid labels are printed | ☐ | ☐ |
| §3.1 | Coil alpha generated as `FW-#####-C##`, child suffix on a mid-run break | ☐ | ☐ |
| §3.2 | Target values printed when in tolerance, no average shown | ☐ | ☐ |
| §3.3 | Net weight calculated, not weighed, with an operator scale override | ☐ | ☐ |
| §4.1 | Traceability chain records footage ranges per source rod, bounded by welds | ☐ | ☐ |
| §4.3 | Hybrid runs record no intermediate spool, and the record distinguishes this | ☐ | ☐ |
| §5 | A coil cannot be confirmed while a quality hold covers its footage | ☐ | ☐ |
| §6.1 | Two coils per skid; the second closes it and prints the skid label | ☐ | ☐ |
| §7.1 | The coil label field set | ☐ | ☐ |
| §7.3 | Reprints are permitted and recorded | ☐ | ☐ |
| §8.1 | The packing-station arrival context and the pending-arrivals panel — **`[PROPOSED]`, mockup-derived** | ☐ | ☐ |
| §8.2 | A scale weight is captured at packing, shown with its variance against the calculated figure — **`[PROPOSED]`, mockup-derived**; which weight governs is Part B | ☐ | ☐ |
| §8.3 | Closing a skid assigns a staging location, prints the skid label and confirms both coil labels | ☐ | ☐ |
| §8.4 | Guided packaging prompts confirm orientation and wrapping before closure | ☐ | ☐ |
| §8.5 | The skids-this-shift table — **`[PROPOSED]`, mockup-derived, `Should`** | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-45 | Dimensional basis for net weight, and its three sub-items | | ☐ |
| OI-105 (§8.2) | **Which of the three weights is authoritative** on the coil record, and whether a variance blocks skid closure | | ☐ |
| OI-104 | **Where the skid record lives** — an existing table in `united_db`/planning, or one that must be built | | ☐ |
| OI-24 | **What generates the lot number**, before the multi-rod rule of OI-99 applies | | ☐ |
| OI-99 | Lot number rule for multi-rod coils | | ☐ |
| OI-106 (§8.3) | **The valid staging locations**, their capacity, and how one is chosen | | ☐ |
| OI-98 | Disposition of an odd final coil | | ☐ |
| Q76 / OI-02 | Spool identifier and format | | ☐ |
| OI-06 | Spool status vocabulary | | ☐ |
| Q18 | Customer coil weight range | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Quality** | | | |
| **Sales / Certification** | | | |
| **Packing / Shipping** *(new at v1.1 — §8)* | | | |
| 1.3 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
