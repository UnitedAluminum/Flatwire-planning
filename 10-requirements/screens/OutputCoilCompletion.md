# Flat Wire Processing — Output Coil Completion and Labelling Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL2 / FL3 (finished goods). FL1 produces an intermediate spool, not a finished coil.
**Version:** 1.6
**Last Updated:** August 25, 2026 — worked examples cited *(previously August 15, 2026)*
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 7 — Output Coil Completion & Label · **Dashboard 7b — Packing Station**
**Requirement source:** SRS output and packing rules; coil alpha format `FW-#####-C##`; the May 21 2026 target-value display correction

---

> **Worked numeric traces for the order dimension.** [`RodOrderAllocation_WorkedExamples.md`](../../95-archive/design-notes/RodOrderAllocation_WorkedExamples.md) carries seven end-to-end traces covering {1 order, 1 rod} × {1 order, n rods} × {n orders, n rods}, welded and not, with every footage and weight reconciled. It is **rationale, not a requirement** — the requirements are `[REQ §5.28]`, `FR-541`–`FR-560`. Its client-facing twin is the `.html` of the same name. ⚠ Its §9 is gap **`G48`** made concrete and its §12 raised **`G52`** and **`OI-127`**; the 4,000 lb rod every count scales from is still open as `OI-97`.

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

> ⚠ **Client decision of 26 August 2026 — a coil made from two rods now keeps TWO identities, one per
> rod.** Previously such a coil carried a single identity taken from the rod that contributed the most
> footage. Each identity now carries **only that rod's share of the weight**, and both are written to the
> coil records your other systems read — so the two add up to the coil's weight and nothing is counted
> twice. The screen therefore shows an identity against **each** row of the chain:
>
> ```
> SOURCE TRACEABILITY
> ┌──────────────┬───────────────┬────────────────┬──────────┐
> │ Rod          │ Identity      │ Footage range  │ Weight   │
> ├──────────────┼───────────────┼────────────────┼──────────┤
> │ <rod>        │ <identity>    │ 0 – <weld>     │ <lb>     │
> │ <rod>        │ <identity>    │ <weld> – <end> │ <lb>     │
> └──────────────┴───────────────┴────────────────┴──────────┘
> ```
>
> **A coil from a single rod is unaffected** — one identity, one row, exactly as before. Fourteen of the
> twenty-three spools in the trial run are single-rod, so this is the common case.
>
> ⚠ **This section is marked `[CONFIRMED]` and the change alters what it confirms, so it needs
> re-signing.** See §9.

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
| **Coil identities** | ⚠ **New, 26 Aug 2026.** **One per source rod**, each carrying only that rod's share of the weight. A single-rod coil has one, as before. The label and the certificate show **all** of them, joined in unwind order — ⛔ **and how they should read on a printed label is still open; see §9** |

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

## 8.3 The skid, its slots, and closing it `[CONFIRMED — the rule, but the COUNTING BASIS needs re-signing]`

> ⚠ **26 Aug 2026.** The rule *"exactly two coils per skid"* is unchanged in intent, but a coil from two
> rods now produces **two** entries in the plant coil register — so *what gets counted* had to change
> from register entries to **physical coils**. The operator's own **1 of 2 / 2 of 2** declaration is what
> closes the skid, which is how it already worked. **Please re-confirm this section on that basis**; see
> §10.

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
| **D6a** | ⚠ **Amends `D6`, 26 Aug 2026.** `D6` also said the shared coil records keep **one** identity for the coil, taken from the dominant rod. **They now keep one per source rod**, each with its own share of the weight, so cost and yield see the real split rather than attributing everything to one rod | **26 Aug 2026** |

---

# 10. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-45** | High | **The dimensional basis for net weight** — target, measured at completion, or integrated across the run; plus the round-edge coefficient, density sign-off and tail-loss treatment (§3.3) | Every net weight, label, yield figure and the ±2 % scale variance rule |
| **OI-105** | **High** | **Which weight is authoritative on the coil record** (§8.2). Three figures now exist — calculated, the Dashboard 7 operator override, and the packing-station scale reading. Does the scale replace the record, sit alongside it, or block skid closure beyond a variance threshold? The label is printed before the station sees the coil, so a rule that changes the weight afterwards forces a reprint | Packing station confirmation, the label's accuracy, and the yield figures downstream. Cannot be judged until **OI-45** fixes the basis |
| **OI-24** | **High** | **Lot number has no column and no generator at all**, before the multi-rod question is even reached. `GET /coil/{alpha}/label` returns it and §7.1 prints it | The label cannot be rendered |
| ⛔ **New — 26 Aug 2026** | **High** | **How should a multi-rod coil's identifiers READ on the printed label and the certificate?** Your 26 August decision gives such a coil one identifier per source rod, and the design shows all of them joined in unwind order. **But nothing yet says whether the label prints one, both, or a combined form** — and the label is what your customer receives. *(Tracked internally as the label-rendering gap.)* | The coil label and the welding-wire certificate. **It cannot be built until this is answered** |
| ⛔ **New — 26 Aug 2026** | **High** | **The two-coils-per-skid rule now needs restating in terms of PHYSICAL coils.** §8.3 confirms *exactly two coils per skid*. A coil from two rods produces **two** entries in the plant coil register, so a rule counting register entries would refuse a perfectly legal second coil. We read your intent as **two physical coils**, and have built it that way — **please confirm.** | §8.3, and the skid-closing rule the packing line depends on |
| **OI-99** | High | **Lot number when a coil has multiple source rods** — both, dominant, or composite? | Certification content, and the label physically applied at §8.4 |
| ~~**OI-104**~~ | ✅ **Closed** | **ANSWERED — 18 Aug 2026. The skid record lives in the existing shop-floor skid register, and flat wire uses it unchanged.** Skid numbers are allocated by the same rule as every other skid on the floor — order number, release letter and a two-digit sequence — so a flat wire skid is indistinguishable in form from a slitter skid, which is what §6.2 always assumed. **No new table is built.** See §11 | Skid closure and the skid label at §8.3 are unblocked, and the *skid numbering follows existing rules* requirement becomes verifiable for the first time |
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
| [Shift Summary](./ShiftSummary.md) | Counts coils out and skids closed from this screen |

---

# 13. What the Shared System Records When a Coil Is Completed

*New 18 Aug 2026, at client request. Nothing in this section changes a rule confirmed earlier in this document — it states what happens **behind** the screens in §3 to §8, which had not been written down.*

## 13.1 Why this section exists

Confirming a coil on the take-up screen and packing it two to a skid are operator actions on flat wire screens. But the coil then has to exist to **every other system in the plant**: packing needs to find it, shipping needs to ship it, certification needs its genealogy, and cost and yield reporting need its weight against its order.

Until now the flat wire module recorded a completed coil in its **own** records only. This section confirms that completing a coil also creates the same set of records any other finished coil at United Aluminum has, so that no existing process has to be changed to accommodate flat wire.

## 13.2 What is created `[PROPOSED]`

On **Confirm & Move to Packing**, the system creates:

| Record | What it is for |
|---|---|
| A **finished coil record** in the shop-floor coil register | The coil exists to every system that looks up a coil, with its final gauge, width, weights, outside and inside diameter |
| A **link to the order** it fulfils | Planning and shipping can see the coil against its release |
| A **genealogy record** back to the source rod | The certification chain runs from the finished coil to the rod, and from the rod to its heat |
| A **cost record** | The coil appears in cost and yield reporting |
| A **shop-floor material record** | Packing and shipping resolve the skid to the coils on it |
| A **skid record**, opened by the first coil and closed by the second | Exactly as §6.1 describes, in the existing shop-floor skid register |
| A **shop-floor transaction record** | The coil's completion appears in the WIP history alongside every other transaction |

**All of this happens automatically and the operator sees none of it.** It either all succeeds or none of it does; if it fails, the operator is told and can retry, rather than the coil being quietly complete on one system and absent from the others.

## 13.3 Two kinds of identity for one coil `[PROPOSED]`

**This is the one item in this section we would ask you to confirm explicitly.**

> ⚠ **Retitled 26 Aug 2026, because "two identities" is now ambiguous.** This section is about two
> **kinds** of identifier — the printed one and the plant one. Separately, and since your 26 August
> decision, a coil made from two rods carries **two plant identifiers**, one per rod (§4.1). So a
> two-rod coil has one printed identifier and two plant ones. The distinction this section asks you to
> confirm is unchanged.

The coil alpha in §3.1 — the `FW-#####-C##` form — is the coil's **customer-facing** identifier. It is what §7.1 prints on the label and what appears on the certificate. That does not change.

The existing shop-floor coil register, however, uses a **nine-character** identifier for every coil in the plant, and the flat wire alpha is twelve characters. Rather than alter a register that every system in the plant reads, flat wire coils are given a **second, internal identifier in the existing plant format**, derived from the source rod's own identifier in the established way — so the finished coils appear as **children of the rod they came from**, which is exactly how every other coil at United Aluminum appears.

**What this means in practice.** Two identifiers refer to one coil: the printed one your customer sees, and the plant one existing reports and screens will show. They are linked, and either resolves to the other. **Where a report or a screen shows the plant identifier rather than the printed one, that is expected** — and it is worth knowing before someone reports it as a defect.

## 13.4 One limitation we want on the record `[CLIENT INPUT REQUIRED]`

The existing plant genealogy record holds **one parent coil per coil**. A flat wire coil made under continuous welded feed normally has **several** source rods — that is what the welding is for.

So the plant genealogy records the **primary** source rod: the one that contributed the coil's first footage. The **full** multi-rod chain, with the footage range each rod contributed, is held in the flat wire records and is what §4 describes and what the welding-wire certificate is built from.

**The certificates are safe.** But the two records deliberately disagree about a welded coil's parentage, and **anyone reading the plant genealogy alone will see one rod and may take it for the whole story.** We would like to know whether any existing report or process reads that chain for flat wire material, because if one does, it needs to be pointed at the fuller record instead.

## 13.5 What we still need before this runs on live data

Three values in the records above have no flat wire precedent, and each is a question about **existing** systems rather than a design choice. We have proposed an answer to each, and each is a single-line change if the answer differs — but all three should be confirmed by IT before flat wire writes to a live plant database.

| | What we need to know | What we propose |
|---|---|---|
| 1 | The **transaction name** a flat wire coil completion should carry in the WIP history, and whether any existing report or process filters on that name | A **new** name reserved for flat wire, so flat wire completions are distinguishable from slitter skid creation in the WIP history |
| 2 | Whether a finished flat wire coil should carry the **existing on-skid status**, or needs a status of its own | Reuse the existing status. It is accurate, and a new status value would change a vocabulary every system reads |
| 3 | What **sample number** and **planned operations** a flat wire output coil should carry when they cannot be inherited from the rod | Copy from the rod wherever possible; only the fallback needs an answer |

**Related to the question in §13.4 and to the same underlying point:** with no change to the shared plant schema, flat wire material in process is no longer distinguishable there by status. Which existing reports and screens need to see that a rod is on a flattening line is an open question in its own right, and it is the same conversation as the three above.

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
| ~~OI-104~~ | ✅ **Answered 18 Aug 2026** — the existing shop-floor skid register, used unchanged, with skid numbers allocated by the existing rule. **No signature required**; retained so a reader who met the question elsewhere finds its answer | — | ☑ |
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
