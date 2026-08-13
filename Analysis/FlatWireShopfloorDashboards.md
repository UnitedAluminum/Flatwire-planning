# Flat Wire Mill — Shopfloor Dashboard Designs

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Document Type:** UX / Screen Design Reference — **internal**
**Status:** Reference — superseded as a requirements source by `MVP-1/RequirementDocuments/`

---

> ## ⚠ This document is no longer the requirements source for any screen
>
> **Every screen below now has an owning client-facing requirement document** in
> [`../MVP-1/RequirementDocuments/`](../MVP-1/RequirementDocuments/). The owning document
> is named in the inventory table and again under each dashboard heading.
>
> **When this document and an owning document disagree, the owning document wins.** This file is retained
> as the internal UX and wireframe record — the ASCII layouts, the navigation map, the design principles and
> the **[Alloy Reference Data](#alloy-reference-data)** table — and as the change-log audit trail for design
> decisions taken between April and August 2026. It is **not** to be cited as a requirement, and it must not be updated to state a new rule:
> new rules belong in the owning document.
>
> Consolidation history: ten per-screen documents were moved out of `Analysis/` on **1 Aug 2026**; DB1 was
> consolidated out of this file in the same pass; **DB3, DB7, DB8, DB10 and DB11 were consolidated out on
> 11 Aug 2026**, which is when the last screen in this file acquired an owner.
>
> **DB7B was added to the inventory on 11 Aug 2026 and is the one screen that never appeared in it.** The
> Packing Station had a mockup and requirement text (`FR-345`–`FR-352`) but no owner and no inventory row —
> it was invisible to the very check that is supposed to guarantee every screen has an owning document. It is
> now owned by `OutputCoilCompletion.md` **§8**, alongside DB7, because the two are one operator flow.
>
> ### Divided by MVP scope — 11 Aug 2026
>
> **The inventory carries an `MVP` column and every dashboard section carries a scope badge.** Three screens
> are **MVP-2**: **DB9** Pass Schedule Management · **DB9A** Pass Schedule List · **DB10** Supervisor Shift
> Summary. Everything else is **MVP-1**, including **DB7** and **DB7B**, which returned with Phase 9.
>
> **The file was not split**, and two things stayed whole on purpose:
>
> - The **Screen Navigation Map** is one diagram spanning both scopes. Halving it would leave two partial maps
>   with dangling edges — the same call the repository made for the ER diagram.
> - The **change log** is the audit trail this file exists to hold; it is not divisible by scope. It moved
>   **undivided** to [CHANGELOG.md](../CHANGELOG.md) on 12 Aug 2026, when every per-document change log in the
>   repository was consolidated there.
>
> **The alloy lookup table was lifted out of the Dashboard 9 section** in the same pass and promoted to the
> top-level [Alloy Reference Data](#alloy-reference-data). It is **MVP-1** reference data — cited by the master
> specification and by `phase-13`, whose alloy-lookup admin is the non-deferrable half of that phase — and it
> had been sitting inside an MVP-2 screen. Tagging DB9 without moving it first would have carried MVP-1
> reference data out of scope, which is the same seam that `CoilCompletionService` created and cost a full
> remediation pass to undo.

---

## Overview

This document defines the shopfloor dashboard screens required to operate the flat wire manufacturing process. Screens are organized by role and process stage. All screens are part of the shared FL1/FL2 shopfloor UI confirmed in the April 16 meeting.

### Dashboard Inventory

**"Owning specification"** is the authoritative requirement document for that screen. All paths are relative to `../MVP-1/RequirementDocuments/`.

| # | Dashboard | **MVP** | Primary User | Trigger | Owning specification |
|---|-----------|:---:|-------------|---------|----------------------|
| 1 | Line Status Overview | MVP-1 | Supervisor / Foreman | Always visible | [LineStatusOverview.md](../MVP-1/RequirementDocuments/LineStatusOverview.md) |
| 2A | Rod Pre-Check-in Station (FL1/FL3) | MVP-1 | FL1 Operator | Staging the next rod while the current coil still runs | [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md) |
| 2 | Rod Check-in & Pre-Run Setup (FL1/FL3) | MVP-1 | FL1 Operator | Start of each rod | [RocCheckin.md](../MVP-1/RequirementDocuments/RocCheckin.md) |
| 3 | Active Run Monitor | MVP-1 | FL1 / FL2 / FL3 Operator | During every run | [ActiveRunMonitor.md](../MVP-1/RequirementDocuments/ActiveRunMonitor.md) |
| ~~4~~ | ~~Weld Event Logger~~ — **retired 1 Aug 2026** | *(retired)* | — | Weld capture moved to DB2A *Mark as welded* | [WeldEvent.md](../MVP-1/RequirementDocuments/WeldEvent.md) |
| 5 | FL2 Spool Check-in | MVP-1 | FL2 Operator | Loading each spool onto TPO | [RocCheckin.md](../MVP-1/RequirementDocuments/RocCheckin.md) §4 |
| 5A | FL2 Spool Queue | MVP-1 | FL2 Operator | Selecting the next spool, ahead of check-in | [SpoolQueue.md](../MVP-1/RequirementDocuments/SpoolQueue.md) |
| 6 | SPC Checkpoint Entry | MVP-1 | Any operator | Pre-run, post die-change | [SPCCheckpoint.md](../MVP-1/RequirementDocuments/SPCCheckpoint.md) |
| 7 | Output Coil Completion & Label | MVP-1 | FL2 Operator | When TKUP-2 coil is complete | [OutputCoilCompletion.md](../MVP-1/RequirementDocuments/OutputCoilCompletion.md) |
| 7B | **Packing Station** | MVP-1 | **Packing operator** | Coil arrives from the line; skid seated and staged | [OutputCoilCompletion.md](../MVP-1/RequirementDocuments/OutputCoilCompletion.md) **§8** |
| 8 | WIP Rejection | MVP-1 | Any operator | Material fails at any stage | [WipRejection.md](../MVP-1/RequirementDocuments/WipRejection.md) |
| 9 | Pass Schedule Management | **MVP-2** | Operations / Maintenance | Before a new product campaign | [PassScheduleManagement.md](../MVP-2/RequirementDocuments/PassScheduleManagement.md) |
| 9A | Pass Schedule List ("All Schedules") | **MVP-2** | Operations / Maintenance | Via Dashboard 9 "← All schedules" button; direct navigation | [PassScheduleManagement.md](../MVP-2/RequirementDocuments/PassScheduleManagement.md) |
| 10 | Supervisor Shift Summary | **MVP-2** | Supervisor / Shift Manager | End of shift / on-demand | [ShiftSummary.md](../MVP-2/RequirementDocuments/ShiftSummary.md) |
| 11 | Roll Adjust | MVP-1 | **FL2 / FL3 operator** (not FL1) | Roll gap adjustment during run | [RollAdjust.md](../MVP-1/RequirementDocuments/RollAdjust.md) |
| 12 | Rod Checkout | MVP-1 | FL1 / FL3 Operator | Rod removed from payoff before run completes naturally | [RodCheckout.md](../MVP-1/RequirementDocuments/RodCheckout.md) |
| DC | Die Change | MVP-1 | FL1 / FL3 Operator | Drawing die replaced mid-run (planned, gauge drift, failure, or size change) | [DieChangeAndManagement.md](../MVP-1/RequirementDocuments/DieChangeAndManagement.md) |
| — | *(no dashboard)* | — | — | Machine / OPC tag surface | [PLCTagSpecification.md](../MVP-1/RequirementDocuments/PLCTagSpecification.md) |
| — | *(no dashboard)* | — | — | Pass schedule generation engine | [PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) |

> **DB13 and DB14 are descoped** (4 Aug 2026, `PLC-Q02` superseded) and were never in this inventory. Their tag map
> lives in [PLCTagSpecification.md](../MVP-1/RequirementDocuments/PLCTagSpecification.md).
>
> **Dashboard 11's primary user was stated three different ways in this file** — this inventory said *FL3 Operator*,
> the DB11 section below says *FL1 / FL2 Operator*, and the DB3 quick-action table says *FL3 only*. **All three were
> wrong or incomplete.** `FR-107`–`FR-109` and all three active-run mockups agree the answer is **FL2 and FL3, and
> not FL1** — FL1's mockup carries no Roll Adjust control at all. Corrected in this inventory row; the two stale
> statements below are left in place as the design record. Reconciliation in
> [RollAdjust.md](../MVP-1/RequirementDocuments/RollAdjust.md) §1.5.

---

## Alloy Reference Data

**Scope: MVP-1.** Seeded in Phase 1 and maintained through the Phase-13 alloy-lookup admin grid, which is the
**non-deferrable** half of that phase.

This table lived inside the **Dashboard 9** section until 11 Aug 2026 — MVP-1 reference data buried in an
MVP-2 screen. Two live citations depend on it and neither is about Dashboard 9:

- `LatestDocument/FlatWire_MasterSpecification.md` — *"maintained via an admin screen"*, carrying its own copy of these values
- `MVP-1/ProjectPlan/ShopfloorPlan/phase-13-administration-reference-data.md` — cites this table for the Process-Engineering sign-off caveat

Its six columns map 1:1 onto the **`AlloyProperty`** table (`Alloy`, `MaxReductionPerPass`, `SpringbackFactor`,
`GaugeToleranceDefault`, `WidthToleranceDefault`, `SpeedRangeMinFPM`, `SpeedRangeMaxFPM`) seeded by
`FlatWire_SampleData_Lookup.sql`.

### Alloy Lookup Table (required in database)

| Alloy | Max reduction / pass | Spring-back factor | Gauge tol. default | Width tol. default | Speed range (FPM) |
|-------|---------------------|-------------------|--------------------|--------------------|--------------------|
| 1100  | 26% | 0.98 | ± 0.003" | ± 0.010" | 800 – 2,000 |
| 1350  | 22% | 0.97 | ± 0.002" | ± 0.008" | 600 – 1,600 |
| 3003  | 24% | 0.98 | ± 0.004" | ± 0.012" | 700 – 1,800 |
| 5052  | 20% | 0.97 | ± 0.003" | ± 0.010" | 500 – 1,400 |
| 6061  | 18% | 0.96 | ± 0.003" | ± 0.010" | 400 – 1,200 |

> These values must be confirmed and maintained by Process Engineering (Tim O.). They are editable via an admin table — not hardcoded.

> **⚠ `Spring-back factor` is a contested quantity — do not build physics on it.** Master specification
> **§10.5** arbitrates the springback model as wrong: the roll gap sits **below** gauge by a **load-dependent
> mill-spring** term (`h₁ = S₀ + F/K`), not above it by a fixed per-alloy multiplier, and springback
> (material) has been conflated with mill spring (machine stiffness). The column stays because
> `AlloyProperty` carries it and the schema is seeded from this table; **the pass-schedule generation that
> consumes it is MVP-2**, and `PassScheduleGenerationSpec.md` is the authority on the physics.

> **Rod diameter and ovality tolerances are deliberately absent.** They are owed by e-mail (`Q22`) and are
> seeded `NULL` in `AlloyProperty` rather than guessed — see `FlatWireSchema_Lookup.md`.

---

## Dashboard 1 — Line Status Overview
> **Scope: MVP-1.**

> **Owning specification: [LineStatusOverview.md](../MVP-1/RequirementDocuments/LineStatusOverview.md)**. DB1 content was consolidated out of this file on 1 Aug 2026 — that document was written from this section. Reproduced here as the design record only; the owning document is authoritative.

**Who:** Supervisor / Foreman
**When:** Persistently displayed — master board for the flat wire floor
**Purpose:** Single view of all three lines, active jobs, real-time readings, and alerts

```
┌─────────────────────────────────────────────────────────────────────┐
│  FLAT WIRE MILL — LINE STATUS             Apr 23, 2026  07:42 AM   │
├──────────────────┬──────────────────┬──────────────────────────────┤
│  FL1             │  FL2             │  FL3 (Hybrid)                │
│  ● RUNNING       │  ● IDLE          │  ○ OFFLINE                   │
│                  │                  │                               │
│  Order: FW-00421 │  Next: FW-00419  │                               │
│  Alpha: R00042   │  Spool: SP-00031 │                               │
│  Alloy: 1100     │  Alloy: —        │                               │
│  Route: Rod→Flat │  Route: Flat→Fin │                               │
│  Speed: 1,620FPM │  Speed: —        │                               │
│  Gauge: 0.110"   │                  │                               │
│  Width: 0.625"   │                  │                               │
│  Payoff 1: 4,200lb│                 │                               │
│  Payoff 2: READY │                  │                               │
│  Run Time: 1h 22m│                  │                               │
├──────────────────┴──────────────────┴──────────────────────────────┤
│  ALERTS                                                             │
│  ⚠  FL1 — Payoff 1 below 3,000 lb — prepare weld                   │
│  ✓  No active WIP rejections                                        │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Elements

| Field | Source | Notes |
|-------|--------|-------|
| Line status | PLC / system | Running / Idle / Setup / Offline / Fault |
| Current order & alpha | Scheduling system | Active job on each line |
| Alloy, route | Order / item template | |
| Speed (FPM) | PLC live tag | |
| Gauge, width | AGC / gauge stand live tag | Real-time for FL1/FL3; blank for FL2 idle |
| Payoff 1 weight | Load cell / calculated | Decrements as rod runs off |
| Payoff 2 status | Operator-confirmed | Ready / Not loaded |
| Run time | System timer | Since check-in acknowledgment |
| Alerts | Rules engine | Payoff low, gauge deviation, component fault, WIP rejection |

### Alert Rules

| Condition | Alert Level | Message |
|-----------|-------------|---------|
| Payoff 1 weight < 3,000 lb | Warning | Prepare weld — Payoff 2 must be ready |
| Gauge outside target ± tolerance | Warning | Gauge deviation on FL1 / FL3 |
| Component PLC fault | Critical | Component fault — line stopped |
| Active WIP rejection on any line | Warning | WIP rejection requires disposition |
| Payoff 2 not loaded when Payoff 1 < 2,000 lb | Critical | No weld material available |

---

## Dashboard 2A — Rod Pre-Check-in Station (FL1 / FL3)
> **Scope: MVP-1.**

> **Owning specification: [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md)**. The owning document is materially ahead of this section: it carries the order-membership rule, the sequence authorisation, and the four min/max tolerance pairs. Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL1 Operator
**When:** While the current coil is still running — staging the *next* rod at the free payoff bay
**Purpose:** Register the next rod against a VPS payoff position so the line can run continuously through an induction weld; inspect the bundle before unbanding; release a mis-staged rod
**Mockup:** `MVP-1/Mockups/dashboard_2a_rod_precheckin.html`
**Full analysis:** [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md)
**Requirements:** SRS §4.2 `PCI001`–`PCI008` · `WLD003`/`WLD005`/`WLD006`/`WLD010` · `TRV004`/`TRV009` · §4.18 `PRC007`/`PRC008`/`PRC011`/`PRC014`

**Not available on FL2** — `PCI002`: no staging space. FL2 is check-in only (Dashboard 5).

```
┌────────────────────────────────────────────────────────────────────────────┐
│  FL1 — ROD PRE-CHECK-IN STATION · VPS          Order: FW-00421   08:31     │
│  Station: (●) FL1   ( ) FL3 (hybrid)           Line state: RUNNING         │
├──────────────────────────────────────┬─────────────────────────────────────┤
│  PAYOFF 1                    ACTIVE  │  PAYOFF 2        PRE-CHECKED-IN     │
│  R00042  1100 · F · 0.375"           │  R00045  1100 · F · 0.375"          │
│  2,840 lb          33% remaining     │  8,350 lb   100% — not drawing      │
│  ██████████░░░░░░░░░░░░░░░░░░░░░     │  █████████████████████████████      │
│  Net wt   Run      Checked  Insp     │  Gross wt  Run/plan  Pre-chk        │
│  8,500 lb RUN-0418 06:12 AM ✓Pass    │  8,690 lb  2 / 3 ⇅  08:02 AM        │
│  ⚠ WELD SOON — stage Payoff 2        │  ⓘ Not yet welded — induction-      │
│    before 2,000 lb                   │    weld tail to head before P1      │
│                                      │    runs out                         │
│  [ Check out rod ]                   │  [ Proceed to check-in › ]          │
│  [ Welds this run · 2 ]              │  [ Mark as welded ]                 │
│                                      │  [ Pre-check-out ]                  │
├──────────────────────────────────────┴─────────────────────────────────────┤
│  Rods In Queue            ⚠ Both bays occupied — check in first            │
│  Plan  Run   Rod no    Diameter   Gross wt    Payoff    Status             │
│   1 ▸   —    R00043    0.375"     8,780 lb      —       Available          │
│   2     —    R00044    0.375"     8,810 lb      —       Available          │
│   3    2 ⇅   R00045    0.375"     8,690 lb      P2      Pre-checked-in     │
│   4     —    R00040    0.375"     8,240 lb      —     ⚑ Partial · 4,120 ft │
└────────────────────────────────────────────────────────────────────────────┘
```

**Layout note.** The screen has **three body regions — bay cards, queue, footer.** A fourth, a 96px *weld-readiness strip* between the bays and the queue, was **removed on 1 Aug 2026**: it restated what the cards already showed (weight and percentage on the payoff bar, `WELD NOW` / `WELD SOON` / `Welded` / `Last weld failed` in the bay alert, the cold-start message in the empty-bay text), and its two buttons belonged on the bays they act on. Its 96px plus a 12px gap went to the queue, which is the only flexing region — **the queue is ~108px taller and shows about four more rows** before it scrolls.

The bay facts sit on **one row** and each bay alert is **one line**. The one sentence the strip carried that no card did — *induction-weld tail to head* — is now the staged card's alert whenever a rod is running; with nothing running that card reverts to *"Pre-checked in — no PLC tags pushed until check-in"*. Both choices are what let the whole screen fit the 1024px panel at 1:1. The queue scrolls internally, so a longer queue never changes the page height.

**Card action rules.** **At most one primary per card**, and where there is one it is the recommended next action. The `ACTIVE` card deliberately has **none** — both of its actions are exceptional, so promoting either would recommend it. A **leading icon** marks a button that *does* something; a **trailing chevron** marks the two that *navigate away* (`Go to rod check-in`, `Proceed to check-in`). Never both on one control.

### Bay States

| State | Chip | Meaning | Actions |
|-------|------|---------|---------|
| `NOT STAGED` | Gray | Empty bay | Pre-check-in rod |
| `PRE-CHECKED-IN` | Blue | Staged, inspection passed, not yet checked in. **The shared `coils.coil_status` is *not* `INFLAT` here** — that is set at check-in (**Q68**) | **Proceed to check-in** *(primary)* · Mark as welded · Pre-check-out |
| `PRE-CHECKED-IN` **· welded** | Blue | Staged and induction-welded to the running rod. Welded is a **flag**, not a status | **Proceed to check-in** *(primary)* · Mark as welded *(disabled — "already marked as welded")* · **Pre-check-out behind a supervisor override** (documented reason, rod → `HOLD` — it is a rejection, **Q69**/**Q72**) |
| `ACTIVE` | Green | Checked in, rod `INFLAT`, run open | Check out rod · Welds this run · N — **no primary, and no *Open active run* link** (removed 1 Aug 2026: the run monitor is reachable from the app bar and Line Status, and this station's job is staging the *next* rod) |
| `BLOCKED` | Red | Visual inspection failed at staging | Go to WIP Rejection — **only** action. The rejection captures the reason and puts the rod on **`HOLD`**, which **releases the row and frees the bay** (**Q23** item 3) |

Weight-bar colours and weld thresholds are the same rules as Dashboard 3 — see [Payoff Weight Indicator Rules](#payoff-weight-indicator-rules). Critical alert when **Payoff 2 is not staged and Payoff 1 is below 2,000 lb**.

### Queue Panel — `TRV004` / `TRV009`

Lists pre-checked-in, welded, and available rod **for the current order**, each with serial number, **payoff position number**, dimensional attributes and current status. Rows with prior footage carry a **partial** flag so a carry-forward rod is visible *before* it is staged.

**Two sequence columns, because planned order is authorised rather than enforced.** `Plan` is the sequence planning intended, with a green `▸` on the rod expected next; `Run` is the order the rod was actually staged in (the SRS `RodSeqno`), blank until processed, with `⇅` where the two differ. Staging any other rod is permitted but **notified and supervisor-authorised** — never refused. See [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md#planned-sequence-notify-and-authorise).

**Panel header — "Rods In Queue"** (added 1 Aug 2026). The queue head previously held the order-context line and the scan box; both were removed, leaving an unlabelled empty row that only became visible when the full-station warning fired — so the table below it began with no name at all. The head now carries a standing **"Rods In Queue"** title on the left and the *both bays occupied* warning on the right.

> **Superseded — order-context header.** The head used to state the order once (line, order number, material spec `1100 · F · 0.375"`, and progress `1 staged · 3 available · 4 on order`). That block is **gone**; the order is stated in the screen header instead. The progress counts went with it — the argument below is retained because the *reasoning* still applies if they are ever reinstated, but nothing on the screen shows them today.
>
> Progress counts are not decoration. With a fixed sequence an operator could read "what's left" off position in the list; once rods may be run **out of planned order**, the remaining count has to be stated outright. `staged` counts every rod physically occupying a bay — pre-checked-in, welded and blocked alike, since a failed bundle is still sitting there.

**No Alloy or Temper columns.** Every rod on an order shares them, so repeating them down each row was a column of identical values; they are stated once in the screen header instead. **Diameter stays per row** — `TRV004` asks for dimensional attributes per row, and a substitution with a different nominal should stand out against the order spec above it.

**No rod-storage location column** (dropped Jul 29 2026). It is not a `TRV004` field, it depended on the still-open **OI-85**, and "bay" already means *payoff position* everywhere else on this screen.

### Pre-Check-in — Three-Step Wizard

| Step | Content | Rules |
|------|---------|-------|
| 1 — Identify rod | Rod alpha (scan or type), measured diameter, optional scrap box. Alloy / temper / weights pre-populate | Validates `R#####` against `proddb..coils` (`CHK006`); **diameter against a min/max lookup tolerance** (`CHK007` — one of **four** min/max pairs with gauge, width and ovality; values owed by e-mail, so the screen's per-alloy map stays mock, **Q22**); rejects a rod already checked in (`CHK009`) |
| 2 — Assign bay | Payoff 1 / Payoff 2 selector cards | Occupied bay disabled and labelled with its occupant (`PCI006`) |
| 3 — Visual inspection | Oxidation · Surface defects · Water stains, Pass/Fail each, plus observation | **Three items, not four.** Any Fail → WIP Rejection only, **no bypass** (`CHK010`) |

**Carry-forward gate.** When `footageRunToDate > 0` the wizard shows footage already run, remaining weight estimate, last run and prior spool alphas, and offers only *Proceed as partial re-check-in* plus an explicit physical-identity confirmation. **The fresh-start path does not exist** (`PRC008`) — see [PartialRodReCheckin.md](../MVP-1/RequirementDocuments/PartialRodReCheckin.md).

### Field Definitions

| Field | Required | Source | Behaviour |
|-------|----------|--------|-----------|
| Rod number | Yes | Operator scan / entry | Validated against the R-series in the coils table |
| Diameter | Yes | Operator measurement | Validated against nominal ± lookup tolerance |
| Scrap box | No | Operator selection | Same-alloy carry-forward as check-in (`PCI005`) |
| Payoff position | Yes | Operator selection | Payoff 1 or Payoff 2; occupied bay not selectable (`PCI006`) |
| Visual inspection | Yes | Operator | All three must Pass; any Fail routes to WIP Rejection |
| Carry-forward acknowledgement | Conditional | Operator | Required when the rod has prior footage (`PRC007`, `PRC014`) |
| Queue sequence (`RodSeqno`) | Auto | System | SRS `FlatwireQueue` sequence; drives Traveler Queue order |

### Behaviour on Confirm

1. `RodStaging` row written with `Status = 'Staged'` and the three inspection results.
2. Shared coil status and WIP queue entry updated per the SRS `PCI` data note (compensating writes — not one transaction).
3. `PayoffStateChanged` broadcast; the bay flips to `PRE-CHECKED-IN`.
4. **No PLC tags are pushed.** Component flags, die sizes, roll gaps and gauge/width targets are pushed only on pass-schedule acknowledgement at check-in.

### Mark as Welded — `WLD010`

**Lives on the staged bay card** (moved off the station-level weld-readiness strip, 1 Aug 2026). That card *is* the incoming rod, so the control carries the bay → rod identity into the dialog — the `PCI008` defaulting behaviour.

Enabled **only** when a rod is pre-checked-in on the idle bay *and* a rod is running on the other. Confirms operator and timestamp (`WLD003`), validates alloy / temper / diameter against the running coil (`WLD006`), and captures the weld quality result (`PCI022`).

**The disabled tooltip is the requirement, not decoration** — it is the only thing on the card that says *why* the control is unavailable:

| Condition | State | Tooltip |
|---|---|---|
| Other bay running, this rod staged and un-welded | Enabled | "Record the induction weld" |
| …and the last attempt failed | Enabled | "Remake the failed weld" |
| Already welded | Disabled | "Already marked as welded" |
| Other bay empty | Disabled | "No rod is running — there is nothing to weld to" |
| Other bay blocked | Disabled | "No rod is running — the other bay failed inspection" |
| Other bay staged, nothing running | Disabled | "No rod is running — check in the other bay to start the line" |

**Which bay is which is resolved at open time, not from the clicked card.** After a payoff transition the running bay is 2 and the staged one is 1; the dialog reads the running bay via the active-bay lookup so the outgoing/incoming pair is never transposed. This is the rule **TC-068** exists to protect.

Per `WLD005` the **payoff transition is driven solely by material consumption reaching 0 ft remaining** — this records the physical weld, it does not switch bays. Supervisor reversal is `WLD011`, not yet specified.

### Welds this run — `PCI021`

**Lives on the active bay card.** A read-only list of every weld recorded against the run in progress; the run *is* the active bay, so the control sits on it. Gated on a **run existing**, not on a weldable pair, so it stays available while the idle bay is empty or blocked.

The count rides on the label (*Welds this run · 2*). At **count 0 it stays enabled** — "none yet" is an answer the operator came for, and the dialog carries an empty state rather than an error. **At cold start there is no active card, so the control is absent** rather than disabled — this changed on 1 Aug 2026 when it moved off the strip, and it supersedes the earlier "disabled at cold start with *no run in progress*" behaviour asserted by **TC-068e**.

No edit path: reversing a recorded weld is `WLD011`, unspecified.

### Pre-Check-out (un-stage)

Releases a staged rod that was **never checked in** — so there is no acknowledgement to void and no PLC tags to clear, and unlike Mode A/B it needs no line-state gate.

| Field | Required | Values |
|-------|----------|--------|
| Reason | Yes | Wrong rod / mis-scan · Order cancelled or deferred · Failed re-inspection · Relocated to different line · Other (free text) |
| Disposition | Yes | Return to floor storage · Return to warehouse |
| Notes | No | Free text |

Recorded as `RodCheckout` with `Mode = 'ModeP'`; reverses the WIP queue entry created at staging.

### Access Control

| Action | Permitted Roles |
|--------|----------------|
| Pre-check-in | FL1 / FL3 operators |
| Pre-check-out | FL1 / FL3 operators *(supervisor approval is an open question — contrast OQ-74 for mid-run checkout)* |
| Mark as welded | FL1 / FL3 operators |
| Welds this run (read-only) | FL1 / FL3 operators |
| Reverse a welded coil (`WLD011`) | Supervisor — not yet specified |

### Open Questions

See [RodPreCheckin.md](../MVP-1/RequirementDocuments/RodPreCheckin.md) — notably whether pre-check-in sets coil status to `INFLAT` (SRS) or `STAGED` (walkthrough), and whether `CHK005` removes the payoff selector from Dashboard 2.

---

## Dashboard 2 — Rod Check-in & Pre-Run Setup (FL1 / FL3)
> **Scope: MVP-1.**

> **Owning specification: [RocCheckin.md](../MVP-1/RequirementDocuments/RocCheckin.md)**. The owning document covers both this screen and Dashboard 5 (spool check-in), and reduces the PLC push detail to a pointer into the tag specification. Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL1 Operator
**When:** At the start of each new rod or job
**Purpose:** Capture incoming material, conduct visual inspection, acknowledge pass schedule, push PLC tags

```
┌───────────────────────────────────────────────────────────────────┐
│  FL1 — ROD CHECK-IN                          Order: FW-00421      │
├───────────────────────────────────────────────────────────────────┤
│  INCOMING BUNDLE INFORMATION                                       │
│  Rod Number:    [ R00042        ]   Alloy:    1100                │
│  Diameter:      [ 0.375"        ]   Temper:   F                   │
│  Gross Weight:  [ 8,840 lb      ]   Net Wt:   8,500 lb            │
│  Payoff Pos:    ( ) Payoff 1  (●) Payoff 2                        │
├───────────────────────────────────────────────────────────────────┤
│  VISUAL INSPECTION                                                 │
│  Oxidation:      (●) Pass  ( ) Fail                               │
│  Surface Defects:(●) Pass  ( ) Fail                               │
│  Water Stains:   (●) Pass  ( ) Fail                               │
│  Observation:    [                                          ]      │
├───────────────────────────────────────────────────────────────────┤
│  PASS SCHEDULE                          PS-1100-FL1-003            │
│  ┌──────────────┬────────────┬──────────────────────────────────┐ │
│  │ Component    │ Status     │ Setting                          │ │
│  ├──────────────┼────────────┼──────────────────────────────────┤ │
│  │ DB1          │ ● ACTIVE   │ Die: 0.340"                      │ │
│  │ DB2          │ ● ACTIVE   │ Die: 0.310"                      │ │
│  │ FM1 12" Mill │ ● ACTIVE   │ Roll Gap: 0.112" / Width: 0.630" │ │
│  └──────────────┴────────────┴──────────────────────────────────┘ │
│                                                                    │
│  Pre-Run SPC — Incoming Rod Diameter:  [ 0.375" ]                  │
│                                                                    │
│  [ ACKNOWLEDGE PASS SCHEDULE & BEGIN CHECK-IN ]                    │
└───────────────────────────────────────────────────────────────────┘
```

### Field Definitions

| Field | Required | Source | Behaviour |
|-------|----------|--------|-----------|
| Rod Number | Yes | Operator scan / entry | Validates against coils table R-series |
| Diameter | Yes | Measured / from PO | Pre-populated from PO if available |
| Gross / Net Weight | Yes | Operator entry | Gross from scale; net calculated |
| Payoff Position | Yes | Operator selection | Payoff 1 or Payoff 2 |
| Visual Inspection | Yes | Operator | All three items must be Pass to proceed; Fail routes to WIP rejection |
| Pass Schedule | Auto-loaded | Scheduling system | Loaded from job; read-only for operator |
| Pre-Run SPC Diameter | Yes | Operator measurement | Recorded against alpha before run starts |

### Behaviour on Acknowledgment
1. System validates all required fields are complete.
2. Inspection result recorded against the rod alpha.
3. Pass schedule settings pushed to PLC as tag values.
4. Run timer starts.
5. **Screen returns to Dashboard 2A — Rod Pre-Check-in Station** (changed 1 Aug 2026; it previously went to Dashboard 3). Check-in is finished the instant *Acknowledge & Begin Check-in* is pressed — the rod is drawing and the run monitor is reachable from the app bar and from Line Status. What the operator has to do **next** is stage the following rod on the idle payoff, which is Dashboard 2A. Routing here closes the two-bay loop (stage → check in → stage the next) on one path instead of leaving the operator to navigate back.

---

## Dashboard 3 — Active Run Monitor (FL1 / FL3)
> **Scope: MVP-1.**

> **Owning specification: [ActiveRunMonitor.md](../MVP-1/RequirementDocuments/ActiveRunMonitor.md)** (consolidated out of this file 11 Aug 2026). The trace rules, payoff thresholds, quick-action sets, pause reason vocabulary, four resume outcomes and shift-summary contribution below are **reproduced here as the design record only** — the owning document is authoritative and carries the client sign-off. Note that the heading says FL1/FL3; the screen also serves FL2, with a historical profile in place of a live trace.

> **Layout note (1 Aug 2026, updated 11 Aug 2026):** the FL1 screen is **`dashboard_3_active_run.html`**
> — the grouped action cluster (*Run events* / *Go to*). The earlier left-rail layout, which held this
> same filename, was **withdrawn** and its file deleted on 1 Aug 2026 (git history at `2a0426b`); every
> inbound link across the mockups was repointed at the surviving screen, then carried the `_v2` suffix.
> That suffix was a misnomer — it was the only FL1 layout, not a revision of a surviving one — and the
> file was **renamed `dashboard_3_active_run.html` on 11 Aug 2026**.

**Who:** FL1 Operator
**When:** Continuously displayed during an active production run
**Purpose:** Real-time gauge/width trace, machine status, payoff monitoring, quick actions
**Descoped (Aug 4, 2026):** the **Machine View** tab and the **View Trends** action are both withdrawn at client request, together with Dashboards 13 and 14. The chart section keeps its collapse toggle; the tab strip now carries a single inert *Traces* label, matching FL2, which never had a second tab. The machine tags the Machine View displayed are specified in [PLCTagSpecification.md](../MVP-1/RequirementDocuments/PLCTagSpecification.md).

```
┌───────────────────────────────────────────────────────────────────┐
│  FL1 — ACTIVE RUN          Order: FW-00421    Alpha: R00042       │
│  Alloy: 1100 | Target Gauge: 0.110" | Target Width: 0.625"        │
├─────────────────────────────────┬─────────────────────────────────┤
│  REAL-TIME GAUGE TRACE          │  REAL-TIME WIDTH TRACE          │
│                                 │                                 │
│  0.115 ─────────────────        │  0.640 ─────────────────        │
│  0.112 ──         ──────        │  0.630 ───────────    ──        │
│  0.110 ─── ──────       ──      │  0.625 ───     ──────────       │
│  0.108 ──────              ─    │  0.620 ─────────────────        │
│  0.105 ─────────────────────    │  0.610 ─────────────────        │
│         [TARGET: 0.110 ± 0.002] │         [TARGET: 0.625 ± 0.005] │
│                                 │                                 │
├─────────────────────────────────┴─────────────────────────────────┤
│  MACHINE STATUS                                                    │
│  Speed:    1,620 FPM   │  DB1: ● ON   Die: 0.340"                 │
│  Footage:  12,450 ft   │  DB2: ● ON   Die: 0.310"                 │
│  Payoff 1: 4,200 lb ▓▓▓▓▓▓▓▓░░░░░░░░░░ (47%)   ⚠ WELD SOON       │
│  Payoff 2: 8,500 lb ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ (READY)                   │
├───────────────────────────────────────────────────────────────────┤
│  ACTIONS                                                           │
│  [ LOG WELD EVENT ]  [ DIE CHANGE ]  [ SPC CHECKPOINT ]           │
│  [ PAUSE RUN     ]   [ WIP REJECT ]  [ COMPLETE RUN   ]           │
└───────────────────────────────────────────────────────────────────┘
```

### Gauge / Width Trace Display Rules

| Condition | Display Behaviour |
|-----------|-----------------|
| Reading within target ± tolerance | Green trace line |
| Reading outside tolerance | Red trace line + alert banner |
| Consecutive out-of-spec readings (configurable N) | Auto-prompt WIP checkpoint |
| Weld point on trace | Vertical marker line with rod alpha label |

### Payoff Weight Indicator Rules

| Weight Remaining | Bar Colour | Action |
|-----------------|-----------|--------|
| > 50% | Green | None |
| 25% – 50% | Amber | None |
| < 25% (< ~2,250 lb) | Red | Alert: prepare weld |
| < 10% | Red flashing | Critical: weld now |

### Quick Action Buttons

| Button | Opens | Lines | Condition |
|--------|-------|-------|-----------|
| ~~Log Weld Event~~ | ~~Dashboard 4~~ **retired 1 Aug 2026** — captured on Dashboard 2A (*Mark as welded*) | FL1, FL3 | Payoff 1 nearing end |
| Die Change | Die Change screen (DC) | FL1, FL3 | Drawing die replacement needed |
| Roll Adjust | Dashboard 11 | FL3 only | FM2 roll gap adjustment needed |
| SPC Checkpoint | Dashboard 6 | FL1, FL3 | Any time |
| Pause Run | Pause confirmation | FL1, FL3 | Any time |
| WIP Reject | Dashboard 8 | FL1, FL3 | Any time |
| Complete Run | Run completion dialog | FL1, FL3 | End of rod / end of job |
| Check Out Rod | Dashboard 12 — Rod Checkout (Mode A) | FL1, FL3 | Only when footage = 0 |

> **FL1 action bar**: 6 buttons — Log Weld Event, Die Change, SPC Checkpoint, Pause Run, WIP Reject, Complete Run (no Roll Adjust, no Edger controls).
> **FL3 action bar**: 7 buttons — Log Weld Event, Die Change, Roll Adjust, SPC Checkpoint, Pause Run, WIP Reject, Complete Run.

### Pause Run — Dialog

*Redesigned 1 Aug 2026 to the client's supplied reference. The fifteen reasons were a flat radio
list ~1100px tall — the only screen in the suite still on radio buttons, and tall enough that the
dialog had to be scaled down on every window, taking its 14px labels under the shopfloor floor.
They are now icon tiles in five category columns; the dialog is 817px and never self-scales.
**Rod Checkout is no longer a reason** — see the resume outcomes below.*

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ (⏸) Pause Run                                                                     [×] │
│      Log the reason for pausing the run                                                │
├──────────────────────────────────────────────────────────────────────────────────┤
│ (● FL1 running) (☷ Order FW-00421) (⚑ Alpha R00042) (↕ Footage 12,450 ft ‹live›)     │
│ (◷ Pause Start 10:23:28 PM ‹live›)                                                     │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Pause reason *          Select one · logged against the run, the alpha, the frozen ft │
│                                                                                        │
│ ⚙ EQUIPMENT/       ⬚ MATERIAL       ✎ QUALITY/        ὆5 OPERATIONAL    ⛨ SAFETY       │
│   MECHANICAL         HANDLING          MEASUREMENT                                     │
│ ┌────────────┐   ┌──────────┐   ┌──────────┐   ┌─────────┐   ┌──────────┐ │
│ │▤ Die change  │   │◎ Payoff 2 │   │⌷ Gauge /  │   │☕ Operator│   │⛨ Safety  │ │
│ │  mid-run,    │   │  loading  │   │  width    │   │  break   │   │  observ. │ │
│ │  no weld     │   │  weld prep│   │  investig.│   └─────────┘   │  non-fault││
│ │  → opens die │   └──────────┘   └──────────┘   ┌─────────┐   └──────────┘ │
│ │    change    │   ┌──────────┐   ┌──────────┐   │⇄ Shift   │                │
│ └────────────┘   │◌ Downstr.│   │↗ Manual  │   │  change- │                │
│ ┌────────────┐   │  blockage│   │  SPC     │   │  over    │                │
│ │◎ Roll adjust│   │  TKUP-2..│   │  → opens │   └─────────┘                │
│ └────────────┘   └──────────┘   │    SPC   │   ┌─────────┐                │
│ ┌────────────┐                 └──────────┘   │὆4 Awaiting│                │
│ │◇ Lubrication│                 ┌──────────┐   │  super-  │                │
│ └────────────┘                 │◉ Surface │   │  visor   │                │
│ ┌────────────┐                 │  inspect.│   └─────────┘                │
│ │▤ Draw box   │                 └──────────┘                                  │
│ └────────────┘                                                                  │
│ ┌────────────┐                                                                  │
│ │⌕ Component  │                                                                  │
│ └────────────┘                                                                  │
│ ┌────────────┐                                                                  │
│ │⋯ Other      │   ← the catch-all lives at the foot of the first column            │
│ └────────────┘                                                                  │
│                                                                                        │
│ Notes (optional)   [ Add additional details…                                        ]  │
│                    [ 0 / 500                                                        ]  │
├──────────────────────────────────────────────────────────────────────────────────┤
│ ὆4 OPERATOR   FOOTAGE FROZEN AT   PAUSE START      [ Cancel ]   [⏸ Confirm Pause]     │
│   Dave M.    12,450 ft            — running —                                        │
└──────────────────────────────────────────────────────────────────────────────────┘
```

**Live read-outs.** Footage and clock tick while the dialog is open, because the line is still
running. Confirming **freezes** them, and the footer states the value the freeze actually took —
not the one on screen when the operator reached for the button.

**Reason codes.** The dialog submits `ReasonCode` + `ReasonCategory`, not a display label —
`GaugeWidthInvestigation` / `QualityMeasurement` and so on, exactly the vocabulary
`POST /run/{runId}/pause` accepts. **`Other` keeps the code `Other`** and puts the operator's
text in `Notes`; notes are mandatory in that case, matching `CK_RunPauseEvent_NotesOther`, and the
field is tinted and relabelled *(required)* while that is true.

**Route lines.** *Die change* and *Manual SPC measurement* name activities that have their own
dialogs, and say so on the tile before the operator commits. Choosing one applies the pause and
then opens that dialog. The die change hand-off is suppressed on **FL2**, which has no draw boxes.

**Button icons.** Across every dialog in the suite the rule is the same: the **action** button
carries an icon (⏸ confirm pause, ▶ resume, ✓ confirm, ⚠ submit rejection), the **dismiss**
button does not. Cancel and Close are plain text — an ✕ on them repeats the close control already
in the dialog corner and reads heavier than the action it sits beside.

> **Type sizes deviate from the supplied reference deliberately.** It sets labels at 10–13px; the
> shopfloor floor is **14px** (`MIN_FONT` in `flat-wire-fit.js`) because these screens are read at
> arm's length. Sizes are lifted; the layout, iconography and hierarchy are the reference's.

### Pause Reason Categories

| Category | Activity | Notes |
|----------|----------|-------|
| Equipment / Mechanical | Die change (mid-run, no weld) | Die swap without a payoff change |
| | Roll adjustment | Line stopped to adjust roll gap before Dashboard 11 |
| | Lubrication / coolant | Scheduled or reactive refill |
| | Draw box inspection | Check solution level, temperature, or contamination |
| | Component inspection (non-fault) | DB1, DB2, FM1 check that does not trigger a PLC fault |
| Material Handling | Payoff 2 loading / weld preparation | Rod not yet ready when Payoff 1 nears end |
| | Downstream blockage | TKUP-2 full or FL2 not ready to accept more footage |
| Quality / Measurement | Gauge / width investigation | Out-of-spec reading — pause before deciding WIP reject |
| | Manual SPC measurement | Operator needs line stopped to measure accurately |
| | Surface inspection | Visual check of product mid-run |
| Operational | Operator break | Short break during shift |
| | Shift changeover | Incoming operator walkthrough before resuming |
| | Awaiting supervisor instruction | Supervisor review required before continuing |
| Safety | Safety observation (non-fault) | Hazard present that does not trigger a PLC fault |
| Other | Other | Free text, **required** — the code stays `Other` |

> **Rod Checkout was removed from this table on 1 Aug 2026 (OI-14).** It was the only entry
> that did not pause the run, presented identically to the fourteen that did. It is now the
> `CheckOutRod` **resume outcome**.

### System Actions on Pause

| Action | Detail |
|--------|--------|
| Run timer paused | Pause duration tracked separately from productive run time |
| Footage counter frozen | Position at pause recorded against the run and alpha |
| Reason code logged | Written against the run, alpha, and footage position |
| PLC tags set to hold | Line speed / drive enable set to idle state |
| Dashboard 1 updated | Line status changes from **RUNNING** → **PAUSED** with reason visible to supervisor |
| Pause start time stamped | Automatic — operator cannot modify |

### Pause — Resume Confirmation

When the operator presses **Resume Run**, a brief confirmation is required before the line restarts:

```
┌───────────────────────────────────────────────────────────────────┐
│  RESUME RUN — CONFIRMATION          FL1  |  Paused 00:08:32        │
│  Pause reason: Lubrication / coolant                               │
├───────────────────────────────────────────────────────────────────┤
│  Was the issue resolved?                                           │
│  (●) Yes — resume run                                              │
│  ( ) No — log WIP rejection                                        │
│  ( ) No — continue pause                                           │
│  ( ) No — check out rod (partial run)                              │
│                                                                    │
│  Activity completed: [                                      ]      │
│  (optional — auto-populated with pause reason if left blank)       │
│                                                                    │
│  [ CANCEL ]                              [ CONFIRM RESUME ]        │
└───────────────────────────────────────────────────────────────────┘
```

| Resume Outcome | System Action |
|----------------|--------------|
| Yes — resume run | Run timer restarts; PLC tags restored; Dashboard 3 returns to active state; pause event closed with end time and duration |
| No — log WIP rejection | Pause event closed; Dashboard 8 (WIP Rejection) opened automatically |
| No — continue pause | Dialog dismissed; line remains paused |
| No — check out rod (partial run) | Rod Checkout opens in **Mode B** with the frozen footage pre-populated. The line stays paused behind it: the pause closes when the checkout is confirmed, not when it is opened |

**Confirmed 1 Aug 2026 — four outcomes, and this document was right.** `pause_run.js`
implemented three and exposed Rod Checkout as a pause *reason* instead; it now implements four,
matching this table, `POST /run/{runId}/resume` and `CK_RunPauseEvent_Outcome`. **OI-14 closed.**
The resume dialog also shows the **footage frozen at the pause** alongside reason and duration,
and reads duration as **h:mm:ss** past an hour — shift changeover and awaiting-supervisor pauses
routinely run long, and the old mm:ss reported a 90-minute stop as "90:00".

### Impact on Shift Summary (Dashboard 10)

Pause events roll up into the Shift Summary as follows:

| Shift Summary Field | How Pauses Contribute |
|---------------------|----------------------|
| **Downtime (minutes)** | Total pause duration per line per shift |
| **Downtime reason breakdown** | Grouped by pause category (Equipment, Material, Quality, Operational, Safety) |
| **Line utilisation %** | Calculated as (shift hours − total pause minutes − fault minutes) ÷ shift hours |
| **WIP Rejection count** | Pauses resolved as "No — log WIP rejection" are counted here |

---

## Dashboard 4 — Weld Event Logger
> **Retired 1 Aug 2026** — weld capture moved to the Dashboard 2A *Mark as welded* dialog. MVP-1 by lineage; the screen no longer exists.

> **Owning specification: [WeldEvent.md](../MVP-1/RequirementDocuments/WeldEvent.md)**. **This screen is retired (1 Aug 2026).** Weld capture is the *Mark as welded* action on Dashboard 2A, because the rod being welded in is the staged one. Retained here as the design record of a withdrawn screen; gaps G27 and G28 record the two capabilities that were not rehoused. Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL1 Operator
**When:** When Payoff 1 rod nears its end and a weld is performed
**Purpose:** Record the weld join, link source rod alphas, maintain traceability through the weld point

```
┌───────────────────────────────────────────────────────────────────┐
│  FL1 — LOG WELD EVENT                                             │
├───────────────────────────────────────────────────────────────────┤
│  OUTGOING ROD (Payoff 1)                                          │
│  Rod Alpha:    R00042        Remaining Footage: ~1,200 ft         │
│  Weld Point:   12,450 ft (current footage counter)                │
│                                                                   │
│  INCOMING ROD (Payoff 2)                                          │
│  Rod Alpha:    [ R00043    ]   Diameter: 0.375"                   │
│  Alloy:        1100            Gross Wt:  8,500 lb                │
│                                                                   │
│  WELD TYPE                                                        │
│  (●) Induction Weld (rod-to-rod)                                  │
│                                                                   │
│  WELD QUALITY CHECK                                               │
│  (●) Pass     ( ) Fail                                            │
│  Fail Reason: [                                           ]       │
│                                                                   │
│  Operator:  [________________]    Time: 07:44 AM (auto-stamped)   │
│                                                                   │
│  [ CONFIRM WELD — LINK R00042 → R00043 TO OUTPUT ]                │
└───────────────────────────────────────────────────────────────────┘
```

### Field Definitions

| Field | Required | Behaviour |
|-------|----------|-----------|
| Outgoing rod alpha | Auto | Read from active run context |
| Weld point footage | Auto | Captured from footage counter at time of logging |
| Incoming rod alpha | Yes | Operator scans or enters R-series alpha of Payoff 2 rod |
| Weld type | Auto | Induction weld (rod-to-rod) — only option; Laser weld removed as not viable |
| Weld quality | Yes | Pass or Fail with reason |
| Operator | Yes | Login-based or manual entry |

### System Actions on Confirmation
1. Weld join event recorded with footage position, both alphas, weld type, quality result, operator, and timestamp.
2. All subsequent output footage linked to the incoming rod alpha (R00043 in the example).
3. Traceability chain updated: R00041 → R00042 → R00043 → output coil alpha.
4. Run monitor returns to Dashboard 3 — Active Run Monitor.

---

## Dashboard 5A — FL2 Spool Queue
> **Scope: MVP-1.**

> **Owning specification: [SpoolQueue.md](../MVP-1/RequirementDocuments/SpoolQueue.md)**. Added 2 Aug 2026 as the eleventh per-screen document; this section and that document were authored together. Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL2 Operator
**When:** Before check-in — deciding which spool to run next
**Purpose:** List the spools available for FL2, and resolve an order from any one of them
**Added:** 2 Aug 2026 · screen `dashboard_5a_spool_queue.html` · `FR-097`–`FR-099` · story FW-124

**Why it exists.** FL1 operators have Dashboard 2A, which lists the rods planned for the running
order. FL2 has no equivalent, because `PCI002` excludes FL2 from staging (see the note at the top of
this document) — so the FL2 operator had **no view of waiting material at all** until they were
holding a spool. Separately, `FR-090` has the operator *scan the FL1-printed label* while **Q17**
records the client saying the operator *"selects it by spool number for check-in"*. Both stand; only
the scan had a screen. And "the spool queue" — a phrase `FR-326`, `TC-389`, `RodCheckout.md` and
phase 7 all use for where an accepted partial spool goes — had **no table, endpoint, screen or status
of that name anywhere**. This screen is it.

```
┌───────────────────────────────────────────────────────────────────┐
│  FL2 — SPOOL QUEUE                                    09:59 AM    │
├───────────────────────────────────────────────────────────────────┤
│  Scan a spool to load its order   [ SP-…            ]  ? OQ-76    │
├───────────────────────────────────────────────────────────────────┤
│  All spools available for processing                              │
│  Across 4 orders · 23,820 lb total          9 spools · 8 ready    │
├───────────────────────────────────────────────────────────────────┤
│ SPOOL     ORDER     SOURCE        GAUGE×WIDTH  NET WT  ORIGIN  ST │
│ SP-00031  FW-00421  RUN-0117      0.113×0.640  3,200lb Standal ●  │
│                     R00041,R00042                          [Check]│
│ SP-00033  FW-00422  RUN-0121      0.120×0.500  2,940lb ⚠Hybrid ●  │
│ SP-00034  —         RUN-0122      0.113×0.640  1,410lb Standal ●  │
│ SP-00030  FW-00419  RUN-0116      0.113×0.640  1,180lb Standal ◐  │
│                                                    On hold · QC   │
└───────────────────────────────────────────────────────────────────┘
```

**Two modes, one table.** Default lists everything runnable irrespective of order. Entering a spool
number resolves its order **server-side in a single call** and narrows the list to that order's
spools, marking the scanned one. *Show all* returns. The **column set never changes between modes**.

**Four ways a scan ends** — all from the same response: order resolved · unknown alpha (`404`; the
field is marked and **the list does not move**) · **unallocated spool** (`200`, null order, one row,
still checkin-able — planning remainders and accepted partials legitimately have no order) ·
not-runnable spool (siblings still list, which is usually what was wanted).

**Deliberately absent:** spool age (`Spool` has no creation timestamp — it is not queryable),
location (`Spool.Location` has no writer), and filter/sort controls (the scan is the real filter).
**Alloy and temper get no columns** — they are order-level and sit in the context bar, the same rule
Dashboard 2A states for rods.

**Read-only.** It writes nothing; Dashboard 5 does that.

---

## Dashboard 5 — FL2 Spool Check-in
> **Scope: MVP-1.**

> **Owning specification: [RocCheckin.md](../MVP-1/RequirementDocuments/RocCheckin.md)**. Covered as section 4 of the check-in specification, alongside rod check-in, rather than as a separate document. Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL2 Operator
**When:** Loading a spool onto the TPO to begin FL2 processing
**Purpose:** Check in incoming spool, review historical gauge profile from FL1, acknowledge FL2 pass schedule
**Reached from:** Dashboard 5A, or directly

```
┌───────────────────────────────────────────────────────────────────┐
│  FL2 — SPOOL CHECK-IN                        Order: FW-00421      │
├───────────────────────────────────────────────────────────────────┤
│  INCOMING BUNDLE INFORMATION                                       │
│  Spool / Alpha: [ SP-00031      ]   Source Rods: R00041, R00042   │
│  Alloy:         1100               Temper:       O (Annealed)     │
│  Gauge:         [ 0.110"        ]  Width:        [ 0.627"   ]     │
│  Gross Weight:  [ 3,480 lb      ]  Net Weight:   3,200 lb         │
│                                                                   │
│  GAUGE PROFILE (Historical — from FL1 run)                        │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │  0.115 ─                                                     │ │
│  │  0.112 ─ ─── ──────                     ────                 │ │
│  │  0.110 ──     ──────────────────────────                     │ │
│  │  0.108 ─────────────────────────────────── ──                │ │
│  │         0ft                           3,200ft                 │ │
│  │         ── Weld point at 2,100ft (R00041 → R00042)           │ │
│  │         [TARGET: 0.110 ± 0.002] ✓ All readings in spec       │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  PASS SCHEDULE                          PS-1100-FL2-007            │
│  ┌──────────────┬────────────┬──────────────────────────────────┐ │
│  │ Component    │ Status     │ Setting                          │ │
│  ├──────────────┼────────────┼──────────────────────────────────┤ │
│  │ S1 · 8"      │ ● ACTIVE   │ Roll Gap: 0.0164"                │ │
│  │ S2 · 6"      │ ● ACTIVE   │ Roll Gap: 0.0162"                │ │
│  │ Edger (S2)   │ ● ACTIVE   │ Round Edge                       │ │
│  │ S3 · 6"      │ ● ACTIVE   │ Roll Gap: 0.0160" (final)        │ │
│  │ Edger (S3)   │ ● ACTIVE   │ Round Edge                       │ │
│  └──────────────┴────────────┴──────────────────────────────────┘ │
│                                                                    │
│  [ ACKNOWLEDGE PASS SCHEDULE & BEGIN CHECK-IN ]                    │
└───────────────────────────────────────────────────────────────────┘
```

### Key Differences from FL1 Check-in

| Attribute | FL1 Check-in | FL2 Check-in |
|-----------|-------------|-------------|
| Incoming material | Rod (R-series alpha) | Spool (SP-series or child alpha) |
| Gauge trace shown | None (run not started yet) | Historical profile from FL1 run |
| Weld markers | Not applicable | Shown on gauge profile chart |
| Visual inspection | Full inspection required | Not required (spool already inspected at FL1) |
| Pass schedule components | DB1, DB2, FM1 | S1 (8"), S2 (6") + Edger, S3 (6") + Edger |

---

## Dashboard 6 — SPC Checkpoint Entry
> **Scope: MVP-1.**

> **Owning specification: [SPCCheckpoint.md](../MVP-1/RequirementDocuments/SPCCheckpoint.md)**. **This is no longer a screen** — it is a dialog over the run being measured. The owning document also flags that the "Post DB1" option offered on screen is not one of the five recorded checkpoint types (OI-10). Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL1 / FL2 Operator
**When:** Pre-run, after any die change, or manual spot check
**Purpose:** Record manual SPC measurements at defined checkpoints

```
┌───────────────────────────────────────────────────────────────────┐
│  SPC CHECKPOINT                      FL1  |  Order: FW-00421      │
├───────────────────────────────────────────────────────────────────┤
│  Checkpoint Type:                                                  │
│  (●) Post Die Change   ( ) Pre-Run   ( ) Post DB1   ( ) Manual Spot Check │
│                                                                   │
│  Trigger:  DB2 die changed from 0.310" → 0.308"                   │
│                                                                   │
│  MEASUREMENTS                                                     │
│  ┌───────────────┬──────────┬──────────┬──────────────────────┐  │
│  │ Measurement   │ Target   │ Actual   │ Status               │  │
│  ├───────────────┼──────────┼──────────┼──────────────────────┤  │
│  │ Wire Diameter │ 0.308"   │ [ 0.309"]│ ✓ In Spec            │  │
│  │ Gauge (FM1)   │ 0.110"   │ [ 0.110"]│ ✓ In Spec            │  │
│  │ Width (FM1)   │ 0.625"   │ [ 0.626"]│ ✓ In Spec            │  │
│  └───────────────┴──────────┴──────────┴──────────────────────┘  │
│                                                                   │
│  Operator: [_______________]                                      │
│                                                                   │
│  [ SUBMIT — CONTINUE RUN ]       [ SUBMIT — SUSPEND MATERIAL ]    │
└───────────────────────────────────────────────────────────────────┘
```

### Checkpoint Types & Measurements Required

| Checkpoint Type | Triggered By | Measurements Recorded |
|----------------|-------------|----------------------|
| Pre-Run | Start of check-in | Incoming rod diameter |
| Post DB1 | After DB1 drawing stage | Wire diameter post-DB1 draw |
| Post Die Change | Operator logs die change | Wire diameter post-draw, FM1 gauge, FM1 width |
| Manual Spot Check | Operator discretion | FM1 gauge, FM1 width |
| Post-Run / Output | Coil completion (Dashboard 7) | Final gauge, final width per coil |

### Disposition Rules

| All measurements in spec | Route to Dashboard 3 — continue run |
|--------------------------|-------------------------------------|
| Any measurement out of spec | Operator chooses: continue run or suspend material |
| Suspension chosen | Dashboard 8 — WIP Rejection auto-opened |

---

## Dashboard 7 — Output Coil Completion & Label
> **Scope: MVP-1.** Returned to MVP-1 on 11 Aug 2026 with Phase 9, together with **DB7B (Packing Station)**.
> **DB7B has no section in this document and never had one** — that is why it reached 11 Aug 2026 with no owning
> specification at all. It is now owned by [`OutputCoilCompletion.md` §8](../MVP-1/RequirementDocuments/OutputCoilCompletion.md);
> its wireframe is the mockup `MVP-1/Mockups/dashboard_7b_packing_station.html`.

> **Owning specification: [OutputCoilCompletion.md](../MVP-1/RequirementDocuments/OutputCoilCompletion.md)** (consolidated out of this file 11 Aug 2026, together with the source-traceability block from `Spool.md`). Reproduced below as the design record only. The owning document additionally raises four open items this section does not: the alloy density factor, the lot number rule for a multi-rod coil, whether gross weight is scale-entered or calculated, and the disposition of an odd final coil.

**Who:** FL2 Operator
**When:** When a coreless oscillated coil is complete on TKUP-2
**Purpose:** Confirm output coil, record final SPC, generate alpha, print label, track skid count

```
┌───────────────────────────────────────────────────────────────────┐
│  OUTPUT COIL COMPLETION              Order: FW-00421              │
├───────────────────────────────────────────────────────────────────┤
│  COIL DETAILS                                                      │
│  New Alpha:     FW-00421-C01          Alloy:    1100              │
│  Gauge:         0.110" (target ✓)     Width:    0.625" (target ✓) │
│  Temper:        H18                   Footage:  14,200 ft         │
│  Net Weight:    [ 980 lb  ] (calculated from footage × density)   │
│  Gross Weight:  [ 1,010 lb]                                       │
│                                                                   │
│  SOURCE TRACEABILITY                                               │
│  ┌──────────────┬────────────────┬───────────────────────────┐   │
│  │ Rod Alpha    │ Footage From   │ Footage To                │   │
│  ├──────────────┼────────────────┼───────────────────────────┤   │
│  │ R00041       │ 0 ft           │ 4,100 ft (weld at 4,100)  │   │
│  │ R00042       │ 4,100 ft       │ 14,200 ft                 │   │
│  └──────────────┴────────────────┴───────────────────────────┘   │
│                                                                   │
│  FINAL SPC                                                        │
│  Gauge: ✓ In Spec (0.110 ± 0.002)   Width: ✓ In Spec (0.625±0.005│
│                                                                   │
│  SKID TRACKING                                                    │
│  Skid:   SK-00201                                                 │
│  ( ) Coil 1 of 2 — skid remains open                             │
│  (●) Coil 2 of 2 — close skid and print skid label               │
│                                                                   │
│  [ PRINT COIL LABEL ]    [ CONFIRM & MOVE TO PACKING ]            │
└───────────────────────────────────────────────────────────────────┘
```

### Coil Label Fields

| Field | Content |
|-------|---------|
| Alpha / Coil No. | System-generated (e.g., FW-00421-C01) |
| Alloy | From order |
| Gauge / Diameter | Target value when SPC confirms in tolerance; measured value shown only if out of tolerance |
| Width (Bundle Width) | Target value when SPC confirms in tolerance; measured value shown only if out of tolerance |
| Temper | From pass schedule / order |
| Gross Weight | Operator-confirmed or calculated |
| Net Weight | Calculated (footage × density conversion factor) |
| Footage | From footage counter |
| Lot Number | Linked to source rod lot |
| Source Rod Alphas | All R-series alphas in traceability chain |

### Skid Completion Rules
- Each skid holds exactly **2 coreless coils**.
- First coil: skid opened, coil alpha linked to skid.
- Second coil: skid closed, skid label printed, skid moved to packing queue.

---

## Dashboard 8 — WIP Rejection Screen
> **Scope: MVP-1.**

> **Owning specification: [WipRejection.md](../MVP-1/RequirementDocuments/WipRejection.md)** (consolidated out of this file 11 Aug 2026). **This is no longer a screen** — it became a dialog on 1 Aug 2026 precisely because it is reached from five different places and a page could describe only one of them. The single hard-coded material banner below is the symptom that forced the change. The owning document also carries the blocked-bay release rule (Q23), which this section predates.

**Who:** Any operator (FL1, FL2, or supervisor)
**When:** Material fails visual inspection, SPC, or any in-process quality check
**Purpose:** Log rejection reason, record disposition, suspend or scrap material

```
┌───────────────────────────────────────────────────────────────────┐
│  WIP REJECTION                       FL1  |  Order: FW-00421      │
├───────────────────────────────────────────────────────────────────┤
│  Material:     R00042               Stage:   FL1 — Active Run     │
│  Rejection At: Footage 8,220 ft     Time:    08:15 AM             │
│                                                                   │
│  REJECTION REASON                                                 │
│  Group:    [ Surface Quality          ▼ ]                         │
│  Reason:   [ Gauge Out of Spec        ▼ ]                         │
│                                                                   │
│  DETAILS                                                          │
│  Measured Gauge:   0.118"                                         │
│  Target Range:     0.108" – 0.112"                                │
│  Deviation:        +0.006" above maximum                          │
│                                                                   │
│  DISPOSITION                                                      │
│  (●) Suspend — Hold for supervisor review                         │
│  ( ) Scrap — Send to scrap disposition                            │
│  ( ) Rework — Return to an earlier processing stage               │
│                                                                   │
│  Observation: [                                             ]     │
│  Operator:    [_______________]                                   │
│                                                                   │
│  [ SUBMIT REJECTION ]                                             │
└───────────────────────────────────────────────────────────────────┘
```

### Rejection Groups & Suggested Reasons

| Group | Reasons |
|-------|---------|
| Surface Quality | Oxidation, Water stain, Surface defect, Scratch, Pit |
| Dimensional | Gauge out of spec, Width out of spec, Edge burr, Camber |
| Weld Quality | Weld failure, Weld break mid-run |
| Material | Chemistry non-conformance, Wrong alloy, Temper incorrect |
| Process | Die failure, Roll gap error, Component fault |

### Disposition Outcomes

| Disposition | System Action |
|-------------|--------------|
| Suspend | Alpha status set to HOLD; moves to WIP Held queue; supervisor notified |
| Scrap | Alpha status set to SCRAP; routes to scrap disposition module |
| Rework | Alpha flagged for rework; operator specifies return stage |

---

## Dashboard 9 — Pass Schedule Management
> **⚠ MVP-2 — deferred screen.** Not part of MVP-1 or of MVP-1 planning. Mockup in [`../MVP-2/Mockups/`](../MVP-2/Mockups/), owning specification in [`../MVP-2/RequirementDocuments/`](../MVP-2/RequirementDocuments/). Retained here as the UX record.

> **Owning specification: [PassScheduleManagement.md](../MVP-2/RequirementDocuments/PassScheduleManagement.md)**. The *Generate from Specs* algorithm reproduced in this section is **superseded**: the engineering basis is [PassScheduleGenerationSpec.md](../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md) v1.5, which now wins on physics and arithmetic both. Do not implement the generator from this section. Reproduced here as the design record only; the owning document is authoritative.

**Who:** Operations Manager / Maintenance (not floor operators)
**When:** Before a new product campaign; when die or roll parameters change
**Purpose:** Create, edit, and manage pass schedule records; generate schedules from product specs; view history

```
┌───────────────────────────────────────────────────────────────────┐
│  PASS SCHEDULE MANAGEMENT                   [Operations manager]  │
├───────────────────────────────────────────────────────────────────┤
│  Schedule ID:   PS-1100-FL1-003  Alloy: 1100   Line:  FL1         │
│  Description:   1100 Rod → 0.110" x 0.625"                        │
│  Status:        ● Active                                          │
│  Last Modified: Apr 20, 2026 — Tim O.                             │
├───────────────────────────────────────────────────────────────────┤
│  COMPONENT CONFIGURATION                       FL1 — drawing only │
│  ┌──────────────┬──────────┬────────────────────────────────────┐ │
│  │ Component    │ Active   │ Parameters                         │ │
│  ├──────────────┼──────────┼────────────────────────────────────┤ │
│  │ DB1          │ [✓] ON   │ Die Diameter:  [ 0.340"          ] │ │
│  │ DB2          │ [✓] ON   │ Die Diameter:  [ 0.310"          ] │ │
│  │ FM1 12" Mill │ [✓] ON   │ Roll Gap: [0.112"]  Width:[0.630"]│ │
│  └──────────────┴──────────┴────────────────────────────────────┘ │
│                                                                   │
│  NOTE: FL3 (Hybrid) schedules also include FM2 components:        │
│  FM2 S1 (8"), FM2 S2 (6") + Edger, FM2 S3 (6") + Edger           │
│                                                                   │
│  TARGETS                                                          │
│  Output Gauge:   0.110"    Tolerance: ± 0.002"                   │
│  Output Width:   0.625"    Tolerance: ± 0.005"                   │
│  Line Speed:     1,600 – 1,800 FPM                               │
│                                                                   │
│  OVERRIDE LOG (last 5)                                            │
│  Apr 21 08:30 — Tim O. — DB2 die changed 0.310 → 0.308           │
│  Apr 19 14:12 — Bob S. — Roll gap FM1 adjusted 0.112 → 0.111     │
│                                                                   │
│  [ ⚡ GENERATE FROM SPECS ]  [ COPY SCHEDULE ]  [ DEACTIVATE ]   │
│  [ DISCARD CHANGES ]         [ SAVE CHANGES  ]                   │
└───────────────────────────────────────────────────────────────────┘
```

---

### Creation Paths

Operations can create a new pass schedule by either of two routes:

| Path | When to use |
|------|------------|
| **Manual entry** | Experienced operator knows the exact die sizes and gap settings; copying from a similar product |
| **Generate from Specs** | New product introduction; Operations provides only alloy, rod diameter, target gauge, and target width — algorithm calculates all parameters |

Both paths produce the same schedule record. Generated schedules start in **Draft** status and must be reviewed and saved as Active before they are available at check-in.

---

### Generate from Specs — Workflow

Triggered by the **⚡ Generate from Specs** button in the footer. Opens a two-panel modal:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚡ Generate pass schedule from specs                                   [×]  │
│  Algorithm calculates die sizes, roll gaps, and component activation        │
│  from product dimensions. Review and adjust before saving.                  │
├─────────────────────────────────┬───────────────────────────────────────────┤
│  SPECIFY INPUTS                 │  GENERATED DRAFT                          │
│                                 │                                           │
│  Alloy:          [ 1100    ▼ ]  │  CALCULATION SUMMARY                     │
│  Rod diameter:   [ 0.375"   ]   │  Pre-flatten ⌀   0.296"                  │
│  Target gauge:   [ 0.110"   ]   │  Area reduction  37.7%                    │
│  Target width:   [ 0.625"   ]   │  Draw passes     2 (DB1 + DB2)            │
│  Edge type:      [ Round ▼  ]   │  Aspect ratio    5.68                     │
│                                 │                                           │
│  ─────────────────────────────  │  COMPONENT CONFIGURATION                 │
│  Alloy limits (1100):           │  ┌──────────────┬──────────┬───────────┐ │
│  Max reduction/pass   26%       │  │ Component    │ Status   │ Value     │ │
│  Spring-back factor   0.98      │  ├──────────────┼──────────┼───────────┤ │
│  Gauge tolerance   ± 0.003"     │  │ FL1  DB1     │ ACTIVE   │ Die 0.335"│ │
│  Width tolerance   ± 0.010"     │  │ FL1  DB2     │ ACTIVE   │ Die 0.295"│ │
│                                 │  │ FL1  FM1     │ ACTIVE   │ Gap 0.108"│ │
│  [ ⚡ GENERATE ]                │  │ FL1  Edge    │ ACTIVE   │ Round edge│ │
│                                 │  │ FL2  S1  8"  │ ACTIVE   │ Gap 0.117"│ │
│                                 │  │ FL2  S2  6"  │ ACTIVE   │ Gap 0.112"│ │
│                                 │  │ FL2  6" S2   │ ACTIVE   │ Gap 0.108"│ │
│                                 │  └──────────────┴──────────┴───────────┘ │
│                                 │                                           │
│                                 │  Route mode: Hybrid FL3                  │
│                                 │  (aspect ratio 5.68 > 5.5 threshold)     │
│                                 │                                           │
│                                 │  ⚠ FM2 activated — aspect ratio > 5.5   │
│                                 │  ⚠ Route set to Hybrid FL3               │
├─────────────────────────────────┴───────────────────────────────────────────┤
│  Review the generated values, then click Apply to populate the schedule.    │
│  [ CANCEL ]                                       [ ✓ APPLY TO SCHEDULE ]  │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Modal Input Fields

| Field | Type | Description |
|-------|------|-------------|
| Alloy | Dropdown | 1100, 1350, 3003, 5052, 6061 |
| Rod diameter | Decimal input | Incoming rod diameter in inches (0.100–0.750") |
| Target gauge | Decimal input | Required output thickness in inches (0.010–0.500") |
| Target width | Decimal input | Required output width in inches (0.050–3.000") |
| Edge type | Dropdown | Round edge, Flat edge, Bevel edge |

The alloy info box updates live as alloy changes, showing the max reduction per pass, spring-back factor, and default tolerances loaded from the alloy lookup table.

#### Algorithm — Calculation Steps

```
STEP 1 — Pre-flatten wire diameter needed
  D_pre = sqrt(4 × target_gauge × target_width / π)
  → Diameter the drawing stage must deliver to FM1

STEP 2 — Total area reduction (rod → D_pre)
  Total reduction = (A_rod − A_pre) / A_rod × 100%

STEP 3 — Number of draw passes
  Compare total reduction to alloy max reduction per pass:
  ≤ 2%           → DB1 bypassed, DB2 bypassed  (no drawing needed)
  ≤ 1× max       → DB1 active, DB2 bypassed    (1 draw pass)
  ≤ 2× max       → DB1 active, DB2 active      (2 draw passes)
  > 2× max       → DB1 + DB2 active + ERROR    (pre-drawn wire required)

STEP 4 — Die sizes
  DB1 die = geometric mean(rod_dia, D_pre) snapped to nearest 0.005"
  DB2 die = D_pre snapped to nearest 0.005"

STEP 5 — FM1 roll gap
  FM1_gap = target_gauge × alloy_springback_factor

STEP 6 — FM2 requirement
  aspect_ratio = target_width / target_gauge
  If aspect_ratio > 5.5 OR alloy is 1350 (welding wire):
    FM2 S1 (8") → ACTIVE
    FM2 S2 (6") → ACTIVE  (also if aspect_ratio > 7.0)
    Route    → Hybrid FL3
  Else:
    FM2 S1, FM2 S2 → BYPASSED  (S3 is never bypassed)
    Route → Standalone FL1
  FM2 S3 (6") → always ACTIVE (mandatory — cannot bypass; final gauge control)

STEP 7 — FM2 roll gaps (if active)
  FM2 S1 (8") gap = target_gauge × 1.06  (progressive squeeze)
  FM2 S2 (6") gap = target_gauge × 1.02
  FM2 S3 (6") gap = target_gauge × springback_factor
```

#### Alloy Lookup Table — moved out of this section

> **The alloy lookup table is MVP-1 reference data and no longer lives here.** It was inside this MVP-2
> screen section until 11 Aug 2026, while being cited as MVP-1 reference data by the master specification
> and by `phase-13`, whose alloy-lookup admin is the **non-deferrable** half of that phase. It is now
> **[§ Alloy Reference Data](#alloy-reference-data)**, a top-level section of this document.
>
> The generator reads it; it does not own it.

#### Calculation Summary Chips (displayed in modal right panel)

| Chip | Value shown | Explanation |
|------|-------------|-------------|
| Pre-flatten ⌀ | Calculated diameter | Wire diameter FM1 must receive |
| Area reduction | % | Total reduction from rod to pre-flatten wire |
| Draw passes | 0, 1, or 2 | Number of die stages activated |
| Aspect ratio | width ÷ gauge | Drives FM2 and route mode decisions |

#### Warnings and Error Cases

| Condition | Type | Message shown |
|-----------|------|---------------|
| Total reduction > 2× alloy max | **Error** | "Target cannot be achieved in 2 draw passes. Pre-drawn wire required as input, or adjust target gauge/width." |
| Aspect ratio > 5.5 | **Warning** | "FM2 stands activated — aspect ratio exceeds 5.5. Route set to Hybrid FL3." |
| 1350 alloy selected | **Warning** | "1350 detected — welding wire precision mode. All FM2 stands activated, tighter tolerances applied." |
| Aspect ratio > 10 | **Warning** | "Very high aspect ratio — verify FM2 capability with Maintenance before activating." |
| Die size snapped from ideal | **Info** | "DB1/DB2 die snapped to nearest 0.005" increment. Verify against die inventory before saving." |
| Target gauge below machine minimum | **Error** | "Target gauge is below FL1 minimum capability. Cannot generate schedule." |

The Apply button is enabled for all results including error cases, so Operations can inspect and adjust the draft manually before deciding whether to proceed.

---

### Generate from Specs — Apply and Save Lifecycle

```
1. Operations clicks "Apply to Schedule"
      ↓
2. All component toggles, die inputs, gap inputs, and target fields
   on the main Dashboard 9 form are populated with calculated values
   (highlighted in purple to indicate algorithm-generated origin)
      ↓
3. Schedule status changes to ◆ DRAFT
   Footer changes to show "Generated draft — pending review"
   "Save Changes" button replaced by "Save as Active"
      ↓
4. Operations reviews every field, adjusts any value as needed
   (toggle components, override die sizes from inventory, fine-tune gaps)
      ↓
5. Operations clicks "Save as Active"
      ↓
6. Status changes to ● Active
   Purple highlights cleared
   Schedule record written to the database
   Schedule is now available at check-in (Dashboard 2 / 5)
```

> **PLC tags are never pushed during generation or apply.** The draft schedule only reaches the PLC after the operator acknowledges it at check-in. The generate workflow writes only to the pass schedule database record.

---

### Draft Status Behaviour

| State | Status badge | Available at check-in? | Footer action |
|-------|-------------|----------------------|---------------|
| Generated, not yet reviewed | ◆ Draft | No | Save as Active |
| Saved as Active | ● Active | Yes | Save Changes |
| Deactivated | ○ Inactive | No | Reactivate |

---

### Access Control

| Action | Permitted Roles |
|--------|----------------|
| View pass schedule | All operators |
| Acknowledge pass schedule (check-in) | FL1 / FL2 operators |
| Create / edit pass schedule manually | Operations Manager, Maintenance |
| Generate from specs | Operations Manager, Maintenance |
| Save generated draft as Active | Operations Manager |
| Override a setting mid-run | Operations Manager (logged with reason) |
| Deactivate a schedule | Operations Manager |
| Edit alloy lookup table | Process Engineering / System Admin |

### Override Logging Fields
Every parameter change after a schedule is active must record:
- Parameter changed
- Old value → New value
- Operator / authorised user
- Reason code
- Timestamp

---

## Dashboard 9A — Pass Schedule List ("All Schedules")
> **⚠ MVP-2 — deferred screen.** Not part of MVP-1 or of MVP-1 planning. Mockup in [`../MVP-2/Mockups/`](../MVP-2/Mockups/), owning specification in [`../MVP-2/RequirementDocuments/`](../MVP-2/RequirementDocuments/). Retained here as the UX record.

> **Owning specification: [PassScheduleManagement.md](../MVP-2/RequirementDocuments/PassScheduleManagement.md)**. Covered by the same owning document as Dashboard 9. Reproduced here as the design record only; the owning document is authoritative.

**Who:** Operations Manager / Maintenance
**When:** Browsing the full pass schedule library; selecting a schedule to view or edit; starting a new schedule
**Purpose:** Index and search view for all pass schedule records; entry point for both manual creation and Generate from Specs
**Navigated from:** Dashboard 9 "← All schedules" back button; direct navigation link
**Mockup:** [dashboard_9a_schedule_list.html](../MVP-2/Mockups/dashboard_9a_schedule_list.html)

```
┌────────────────────────────────────────────────────────────────────────────┐
│  PASS SCHEDULES                                       [Operations manager]  │
├────────────────────────────────────────────────────────────────────────────┤
│  [ 🔍 Search schedules...   ]  Alloy[All▼]  Line[All▼]  Status[All▼]       │
│                                         [+ New Schedule]  [⚡ Generate]     │
├────────────────────────────────────────────────────────────────────────────┤
│  12 total  ·  4 ● Active  ·  2 ◆ Draft  ·  6 ○ Inactive                    │
├──────────────────┬──────────────────────────────┬───────┬──────┬─────────┬──────────────────────┬───┤
│  Schedule ID  ↑  │  Description                 │ Alloy │ Line │ Status  │ Last Modified        │   │
├──────────────────┼──────────────────────────────┼───────┼──────┼─────────┼──────────────────────┼───┤
│  PS-1100-FL1-003 │  1100 → 0.110" × 0.625"      │ 1100  │ FL1  │●Active  │ Apr 20 — Tim O.      │ ↗ │
│                  │  [In use: FW-00421]           │       │      │         │                      │   │
│  PS-1350-FL3-001 │  1350 → 0.040" × 0.500"      │ 1350  │ FL3  │●Active  │ Apr 18 — Tim O.      │ ↗ │
│                  │  [In use: FW-00418]           │       │      │         │                      │   │
│  PS-1100-FL1-004 │  1100 → 0.085" × 0.750"      │ 1100  │ FL3  │◆Draft   │ Apr 25 — Tim O.      │ ↗ │
│  PS-5052-FL1-001 │  5052 → 0.090" × 0.500"      │ 5052  │ FL1  │◆Draft   │ Apr 25 — Tim O.      │ ↗ │
│  PS-1100-FL1-002 │  1100 → 0.110" × 0.375"      │ 1100  │ FL1  │○Inactive│ Mar 15 — Tim O.      │ ↗ │
└──────────────────┴──────────────────────────────┴───────┴──────┴─────────┴──────────────────────┴───┘
```

### Toolbar Elements

| Element | Type | Behaviour |
|---------|------|-----------|
| Search | Text input | Live filter — matches Schedule ID, Description, and Alloy as the operator types; clears on ×  |
| Alloy filter | Dropdown | All / 1100 / 1350 / 3003 / 5052 / 6061; highlights amber when a value is selected |
| Line filter | Dropdown | All / FL1 / FL2 / FL3; highlights amber when active |
| Status filter | Dropdown | All / Active / Draft / Inactive; highlights amber when active |
| + New Schedule | Button (green) | Opens the choice popup (see below) |
| ⚡ Generate from Specs | Button (purple) | Opens the Generate from Specs modal directly (same algorithm as Dashboard 9) |

All four filters apply simultaneously. Active filter controls (non-"All" value selected) display with an amber background to signal that the visible list is restricted.

### Stats Strip

A single row immediately below the toolbar. Updates dynamically as filters change.

| Chip | Content | Colour |
|------|---------|--------|
| N total | Count of rows matching current filters | Default text |
| N ● Active | Active schedules in current filter view | Green |
| N ◆ Draft | Draft schedules in current filter view | Purple |
| N ○ Inactive | Inactive schedules in current filter view | Grey |

### Table Columns

| Column | Content | Sortable | Notes |
|--------|---------|----------|-------|
| Schedule ID | Monospace identifier (e.g. PS-1100-FL1-003) | Yes (default ↑) | |
| Description | Human-readable name; "In use: FW-XXXXX" chip shown in subdued text below when schedule is linked to an active job | Yes | In-use chip is green |
| Alloy | Alloy badge (e.g. 1100, 1350) | Yes | |
| Line | FL1 / FL2 tag; FL3 shown in purple to indicate Hybrid route | Yes | |
| Route | Standalone or Hybrid with icon | Yes | |
| Status | ● Active (green) / ◆ Draft (purple) / ○ Inactive (grey) badge | Yes | |
| Last Modified | Date + operator name (e.g. "Apr 20 — Tim O.") | Yes | |
| Open | ↗ icon button | No | Opens Dashboard 9 detail view for that schedule |

Clicking anywhere on a row (or the ↗ button) opens Dashboard 9 for that schedule. Column headers are clickable to sort; a second click reverses direction; an arrow indicator (↑ / ↓) marks the active sort column.

### Choice Popup — New Schedule

Clicking **+ New Schedule** shows a small inline popup anchored to the button:

```
┌────────────────────────────────────┐
│  New pass schedule                 │
├────────────────────────────────────┤
│  How would you like to start?      │
│                                    │
│  [ 📝 Enter manually           ]   │
│  Set each component by hand        │
│                                    │
│  [ ⚡ Generate from specs      ]   │
│  Algorithm calculates from alloy,  │
│  rod diameter, gauge, and width    │
└────────────────────────────────────┘
```

| Choice | Action |
|--------|--------|
| Enter manually | Navigates to Dashboard 9 with a blank new schedule form (all fields empty, status = Draft) |
| Generate from specs | Dismisses popup and opens the Generate from Specs modal; on Apply → navigates to Dashboard 9 pre-populated with results |

### Generate from Specs (from List Screen)

The "⚡ Generate from Specs" shortcut button and the popup choice both open the same two-panel modal defined in Dashboard 9. After the operator clicks **Apply to Schedule**, the list screen navigates to Dashboard 9 with all generated values pre-populated and the status set to Draft. The operator then reviews and saves as Active exactly as in the standard Dashboard 9 workflow.

An additional **Open in editor** button appears in the modal results panel as an explicit alternative to Apply — it performs the same navigation.

### Filter and Sort Behaviour

- All four controls (search + 3 dropdowns) are applied together — the displayed rows must match all active criteria simultaneously.
- Sort direction persists while filters change; the sorted column is highlighted.
- Clearing all filters and resetting sort is available via individual control resets; there is no global reset button.
- Results are stable-sorted: changing a secondary sort criterion does not alter the relative order of equal-value rows from the primary sort.

### Empty State

When no schedules match the active filters, the table body shows a centred message:

```
  No schedules match your filters.
  Clear filters or create a new schedule.
```

The stats strip shows "0 total · 0 Active · 0 Draft · 0 Inactive" and remains visible so the operator can see the filter state is responsible for the empty result.

### Navigation

| From | To | Trigger |
|------|----|---------|
| Dashboard 9A | Dashboard 9 (existing schedule) | Row click or ↗ Open button |
| Dashboard 9A | Dashboard 9 (new blank) | + New Schedule → Enter manually |
| Dashboard 9A | Dashboard 9 (pre-populated) | + New Schedule → Generate from specs → Apply |
| Dashboard 9A | Dashboard 9 (pre-populated) | ⚡ Generate from Specs toolbar → Apply |
| Dashboard 9 | Dashboard 9A | "← All schedules" back button |

---

## Dashboard 10 — Supervisor Shift Summary
> **⚠ MVP-2 — deferred screen.** Not part of MVP-1 or of MVP-1 planning. Mockup in [`../MVP-2/Mockups/`](../MVP-2/Mockups/), owning specification in [`../MVP-2/RequirementDocuments/`](../MVP-2/RequirementDocuments/). Retained here as the UX record.

> **Owning specification: [ShiftSummary.md](../MVP-2/RequirementDocuments/ShiftSummary.md)** (consolidated out of this file 11 Aug 2026). Reproduced below as the design record only. The owning document raises **OI-46** — shift start and end times, shift names, the weekend and holiday pattern, and how a run crossing a boundary is attributed are all undefined, which blocks every figure on the screen.

**Who:** Supervisor / Shift Manager
**When:** End of shift or on-demand during shift
**Purpose:** Per-machine throughput (lbs & footage), quality, weld events, and material status for the flat wire floor
**Layout:** Individual machine pages — FL1, FL2, FL3 are shown on separate tab views. KPI tiles (footage & weight) update to reflect the selected machine. An "All Lines" summary view is also available.

```
┌───────────────────────────────────────────────────────────────────┐
│  FLAT WIRE — SHIFT SUMMARY          Shift: Day  |  Apr 23, 2026   │
│  Machine: [ FL1 ] [ FL2 ] [ FL3 ] [ All Lines ]                   │
├───────────────────────────────────────────────────────────────────┤
│  ── FL1 ──────────────────────────────────────────────────────    │
│  Footage:  24,800 ft  |  Weight Out:  1,840 lb                    │
│  Orders Run: 2  |  Coils Out: 4  |  Utilisation: 82%              │
├───────────────────────────────────────────────────────────────────┤
│  ── FL2 ──────────────────────────────────────────────────────    │
│  Footage:  18,200 ft  |  Weight Out:  1,350 lb                    │
│  Coils Out: 3  |  Skids Closed: 1  |  Utilisation: 61%            │
├───────────────────────────────────────────────────────────────────┤
│  ── FL3 ──────────────────────────────────────────────────────    │
│  Footage:       0 ft  |  Weight Out:       0 lb                   │
│  Offline this shift                                               │
├───────────────────────────────────────────────────────────────────┤
│  QUALITY                          WELD EVENTS                      │
│  SPC Pass Rate:    96.4%          FL1: 3 welds  ✓                 │
│  WIP Rejections:   2              FL2: 1 weld   ✓                 │
│  Suspended:  1 coil              All weld quality: Pass           │
├───────────────────────────────────────────────────────────────────┤
│  MATERIAL STATUS                                                  │
│  Rod in Storage:    12 bundles (R00044 – R00055)                  │
│  Spools on Floor:    2 (SP-00032, SP-00033) — awaiting FL2        │
│  Coils in Packing:   3 — awaiting label print                    │
│  WIP Held:           1 coil (FW-00419-C02) — gauge out of spec   │
├───────────────────────────────────────────────────────────────────┤
│  [ EXPORT SHIFT REPORT ]   [ VIEW WIP REJECTIONS ]   [ PRINT ]    │
└───────────────────────────────────────────────────────────────────┘
```

### Per-Machine Page Behaviour

The machine tab selector (FL1 / FL2 / FL3 / All Lines) controls which machine's data is shown in the KPI strip and utilisation section:

| Machine Tab | KPI Tiles Show | Utilisation Shows |
|-------------|---------------|------------------|
| FL1 | FL1 footage, FL1 weight out, FL1 coils, FL1 downtime | FL1 timeline only |
| FL2 | FL2 footage, FL2 weight out, FL2 coils, FL2 downtime | FL2 timeline only |
| FL3 | FL3 footage, FL3 weight out, FL3 coils, FL3 downtime | FL3 timeline only |
| All Lines | Combined totals | All three timelines stacked |

### Shift Summary Data Sources

| Section | Data Source |
|---------|------------|
| Footage (per machine) | Footage counter for that line, filtered to shift window |
| Weight out (per machine) | Sum of net weights of completed coils on that line |
| Coils out | Output alphas completed on that line during the shift |
| Quality / SPC pass rate | SPC checkpoint records for the shift window |
| WIP rejections | WIP rejection log filtered by shift date/time |
| Line utilisation | Run timer vs. available shift hours per line |
| Weld events | Weld event log filtered by shift |
| Material status | Coils table — current status per alpha |

---

## Dashboard 11 — Roll Adjust
> **Scope: MVP-1.**

> **Owning specification: [RollAdjust.md](../MVP-1/RequirementDocuments/RollAdjust.md)** (consolidated out of this file 11 Aug 2026). **This is no longer a screen** — it is a dialog over the paused run.
>
> **Two defects in this section were corrected in the owning document rather than carried across.** First, the *"Who"* line below says **FL1 / FL2 Operator**, the Dashboard Inventory says **FL3 Operator**, and the DB3 quick-action table says **FL3 only** — three statements, three answers, and **all three are wrong or incomplete**. `FR-107`–`FR-109` and all three active-run mockups agree: **Roll Adjust is on FL2 and FL3, and not on FL1.** Second, the wireframe's roll-gap table is **internally inconsistent**: the 4 Aug 2026 three-stand correction left five rows for three stands, with `S1` and `S2` each appearing twice and one row labelled *"S2 (final)"* when **S3** is the final stand. The owning document renders it as three position-identified rows — S1 (8″), S2 (6″), S3 (6″, never bypassed).

**Who:** FL1 / FL2 Operator
**When:** During an active run when measured gauge or width drifts out of the pass schedule tolerance
**Purpose:** Log and apply a mid-run roll gap override for one or more rollers without modifying the underlying pass schedule

```
┌───────────────────────────────────────────────────────────────────┐
│  FL2 — ROLL ADJUST               Order: FW-00421  08:22 AM        │
│  ◉ FL2 running · SP-00031                                         │
├───────────────────────────────────────────────────────────────────┤
│  Spool: SP-00031 │ Pass Schedule: PS-1100-FL2-007 │ Footage: 13,060 ft │
│  Targets: 0.0160" gauge ±0.0002" · Width 0.625" ±0.005"           │
│  Override type: Run-level · pass schedule unchanged                │
├─────────────────────────────────────┬─────────────────────────────┤
│  ROLL GAP ADJUSTMENTS               │  MEASUREMENTS AT 13,060 ft  │
│                                     │                             │
│  Component  Scheduled  Current  New │  Output gauge               │
│  S1 · 8"    ACTIVE  0.0164"  0.0164"│  ⚠  0.0164"  OUT OF SPEC ↑  │
│  S2 · 6"    0.0162"    0.0162"  —   │  Target: 0.0160" ±0.0002"   │
│  S1         (no change)             │  +0.0002" above max         │
│  S3 · 6"    0.0160"    0.0161"      │                             │
│  S2 (final)            [0.0158"]    │  Output width               │
│             Δ = −0.0003"            │  ✓  0.627"   IN SPEC        │
│                                     │  Target: 0.625" ±0.005"     │
│                                     ├─────────────────────────────┤
│                                     │  REASON FOR ADJUSTMENT      │
│                                     │  ● Gauge drift (high)       │
│                                     │  ○ Gauge drift (low)        │
│                                     │  ○ Width drift  ○ SPC flag  │
│                                     │  ○ Roll wear  ○ Post-weld   │
│                                     │  Notes: [               ]   │
├─────────────────────────────────────┴─────────────────────────────┤
│  RECENT ROLL ADJUSTMENTS (PS-1100-FL2-007)                         │
│  Apr 23 06:15  Dave M.  S3 (6")       0.0160" → 0.0161"  Roll warm-up   │
│  Apr 22 14:30  Bob S.   S3 (6")       0.0162" → 0.0160"  SPC flag       │
│  Apr 21 09:45  Dave M.  S1 (8")       0.0164" → 0.0162"  Gauge drift    │
├───────────────────────────────────────────────────────────────────┤
│  Operator: Dave M.  │  08:22:05 AM · Apr 23 2026  │  S2 −0.0003"  │
│                                [ CANCEL ]  [ APPLY ADJUSTMENT ]   │
└───────────────────────────────────────────────────────────────────┘
```

### Context Strip Fields

| Field | Source | Notes |
|-------|--------|-------|
| Spool / Alpha | Active run context | Auto-populated from current job |
| Pass schedule ID | Active run context | Read-only reference |
| Footage at adjustment | Footage counter | Captured at moment screen is opened |
| Output targets | Pass schedule | Gauge and width targets with tolerances |
| Override type | System | Always "Run-level" — pass schedule record is never modified here |

### Roll Gap Adjustment Table

| Column | Editable | Description |
|--------|----------|-------------|
| Component | No | Roll name from pass schedule; bypassed rolls shown greyed out |
| Scheduled gap | No | Gap value defined in the active pass schedule |
| Current gap | No | Gap in effect right now (equals scheduled unless a prior run override exists) |
| New gap | Yes | Operator-entered target; blank or equal to current = no change |
| Delta | Auto | New − Current; colour-coded: green = tightening, red = opening, grey = no change |

**Interaction rules:**
- Bypassed components (e.g. S1 or S2 when bypassed) are shown read-only and greyed out — no input rendered. S3 is never bypassable.
- Only rollers with a gap parameter are shown. Edgers (edge shape, no gap setting) are excluded.
- Delta auto-calculates on every keystroke.
- Rows with a non-zero delta are highlighted amber to draw attention.

### Measurement Trigger Panel

Displays the operator's most recent manual measurements that triggered the adjustment. Each measurement shows:

| Element | Description |
|---------|-------------|
| Measured value | Operator-entered reading (large, prominent) |
| Target | From pass schedule targets |
| Tolerance | ± value from pass schedule |
| Status badge | OUT OF SPEC (amber) or IN SPEC (green) |
| Deviation | How far outside the limit (e.g. "+0.0002″ above maximum") |
| Range bar | Visual indicator: green zone = target range; marker shows measured position |

### Reason Code

Required before the Apply button is enabled. Selectable chips (one must be chosen):

| Reason | When to use |
|--------|-------------|
| Gauge drift (high) | Measured gauge above maximum tolerance |
| Gauge drift (low) | Measured gauge below minimum tolerance |
| Width drift | Width outside tolerance |
| SPC flag | Statistical process control chart triggered |
| Roll wear | Gradual gap creep attributed to roll surface wear |
| Post-weld correction | Gauge change observed after a weld join passes through |
| Operator discretion | Operator anticipates drift based on experience |

Optional free-text notes field for additional detail.

### Change History Panel

Shows the last 3 roll adjustments against the active pass schedule (across all runs and operators). Columns:

| Column | Content |
|--------|---------|
| Time | Date and time of the prior adjustment |
| Operator | Who made the change |
| Roll | Which component was adjusted |
| Change | Old gap → New gap (monospace, old value struck through) |
| Reason | Reason code applied at time of change |

### Field Definitions

| Field | Required | Source | Behaviour |
|-------|----------|--------|-----------|
| New gap (per roller) | At least one must change | Operator entry | Decimal inches; must differ from current to register as a change |
| Measured gauge | Yes | Operator measurement | Recorded against the footage counter value |
| Measured width | Yes | Operator measurement | Recorded against the footage counter value |
| Reason code | Yes | Chip selection | Apply button disabled until one is selected |
| Notes | No | Operator free text | Stored with the override log record |
| Operator | Auto | Logged-in user | Cannot be changed on this screen |
| Timestamp | Auto | System clock | Stamped at moment of Apply confirmation |
| Footage | Auto | Footage counter | Captured when screen was opened; not editable |

### System Actions on Apply

1. Override record written against the active run, spool alpha, and footage position — **not** against the pass schedule.
2. Each changed roll gap logged individually: component name, old value, new value, delta, reason, operator, timestamp, footage.
3. PLC tag for the adjusted roll gap updated to the new value immediately.
4. Active run monitor (Dashboard 3) reflects the updated current gap in the component status panel.
5. Override is visible in the pass schedule "Overrides" history tab for full traceability.
6. Screen returns to Dashboard 3 — Active Run Monitor.

### Access Control

| Action | Permitted Roles |
|--------|----------------|
| View roll adjust screen | FL1 / FL2 operators |
| Apply a roll gap override | FL1 / FL2 operators (logged automatically) |
| View override history | All operators, supervisors |
| Revert an override | Operations Manager only |

### Design Notes

- This is a **run-level override**, not a pass schedule edit. The pass schedule gap values remain unchanged; the override is recorded separately and linked to the coil footage position.
- If the operator makes no changes to any gap (all deltas = zero) the Apply button is labelled "No changes — return to run" and no record is written.
- Measurements entered here are also written to the SPC checkpoint log with type "Roll adjust trigger" for traceability — no separate SPC checkpoint entry is required for the same footage position.

---

## Dashboard 12 — Rod Checkout
> **Scope: MVP-1.**

> **Owning specification: [RodCheckout.md](../MVP-1/RequirementDocuments/RodCheckout.md)**. **This is no longer a screen** — it is a dialog. The owning document defines three modes (A pre-run, B mid-run, P pre-check-out) and records that rod checkout is a *resume outcome* rather than a pause reason (OI-14). Reproduced here as the design record only; the owning document is authoritative.

**Who:** FL1 Operator
**When:** A rod must be removed from a payoff position before the run completes naturally
**Purpose:** Formally close out a checked-in rod without a weld event, run completion, or WIP rejection; preserve traceability and reset the payoff position
**Full analysis:** [RodCheckout.md](../MVP-1/RequirementDocuments/RodCheckout.md)

Two modes exist depending on whether footage has been produced:

### Mode A — Pre-Run Checkout (footage = 0)

Accessible from Dashboard 2 footer (before acknowledgment) or Dashboard 3 action bar (after acknowledgment, before run starts).

```
┌───────────────────────────────────────────────────────────────────┐
│  ROD CHECKOUT — PRE-RUN              FL1  |  Order: FW-00421       │
│  Alpha: R00042  |  Payoff 2  |  Check-in: 08:14 AM                 │
├───────────────────────────────────────────────────────────────────┤
│  No footage has been produced. This checkout will:                 │
│  · Void the pass schedule acknowledgment                           │
│  · Clear PLC tags for Payoff 2                                     │
│  · Return the rod to inventory                                     │
├───────────────────────────────────────────────────────────────────┤
│  CHECKOUT REASON  (required)                                       │
│  (●) Wrong rod / mis-scan                                          │
│  ( ) Order cancelled / deferred                                    │
│  ( ) Failed re-inspection                                          │
│  ( ) Relocated to different line                                   │
│  ( ) Other: [                                               ]      │
├───────────────────────────────────────────────────────────────────┤
│  ROD DISPOSITION  (required)                                       │
│  (●) Return to floor storage  (status → STAGED)                   │
│  ( ) Return to warehouse      (status → RECEIVED)                 │
├───────────────────────────────────────────────────────────────────┤
│  Notes: [                                                   ]      │
│                                                                    │
│  [ CANCEL ]                           [ CONFIRM CHECKOUT ]         │
└───────────────────────────────────────────────────────────────────┘
```

### Mode B — Mid-Run Checkout (footage > 0)

Accessible only from the Pause Run dialog (Dashboard 3 → Pause Run → fourth resume option). The standard "Check Out Rod" button on Dashboard 3 is disabled when footage > 0.

```
┌───────────────────────────────────────────────────────────────────┐
│  ROD CHECKOUT — PARTIAL RUN          FL1  |  Order: FW-00421       │
│  Alpha: R00042  |  Payoff 2  |  Footage at Checkout: 8,220 ft      │
├───────────────────────────────────────────────────────────────────┤
│  CHECKOUT REASON  (required)                                       │
│  ( ) Equipment failure                                             │
│  ( ) Quality hold                                                  │
│  ( ) Order quantity reached                                        │
│  ( ) Shift deferral                                                │
│  ( ) Other: [                                               ]      │
├───────────────────────────────────────────────────────────────────┤
│  ROD DISPOSITION  (required)                                       │
│  ( ) Hold — return to storage (partial rod, re-usable)            │
│  ( ) Scrap — rod not re-usable                                     │
│  ( ) Defer — continue later on this line                           │
│                                                                    │
│  Remaining Weight Estimate: [           ] lb  (optional)           │
├───────────────────────────────────────────────────────────────────┤
│  IN-PROCESS MATERIAL DISPOSITION  (required)                       │
│  Footage produced: 8,220 ft                                        │
│  ( ) Hold — pending supervisor review                              │
│  ( ) Scrap — discard all footage produced                          │
│  ( ) Accept as partial run — generate spool alpha                  │
├───────────────────────────────────────────────────────────────────┤
│  Notes: [                                                   ]      │
│                                                                    │
│  [ CANCEL ]                           [ CONFIRM CHECKOUT ]         │
└───────────────────────────────────────────────────────────────────┘
```

### Field Definitions

| Field | Required | Source | Behaviour |
|-------|----------|--------|-----------|
| Rod Alpha | Auto | Active run context | Read-only |
| Payoff Position | Auto | Active run context | Read-only |
| Footage at Checkout | Auto | PLC footage counter | Read-only; captured at moment screen opens; 0 for pre-run |
| Checkout Reason | Yes | Operator selection | Dropdown with reason codes; free-text required for Other |
| Rod Disposition | Yes | Operator selection | Determines resulting coil status |
| Remaining Weight Estimate | No | Operator entry | Stored for partial-rod re-use planning |
| Material Disposition | Yes (Mode B only) | Operator selection | Determines fate of footage already produced |
| Notes | No | Operator free text | Optional; stored with checkout record |

### System Actions on Confirm

| Action | Pre-Run (A) | Mid-Run (B) |
|--------|-------------|-------------|
| Partial run record closed | — | Yes — footage counter value saved |
| Partial spool alpha generated | — | Only if disposition = Accept partial run |
| Rod status updated | INFLAT → STAGED / RECEIVED | INFLAT → HOLD / SCRAP / STAGED |
| Pass schedule acknowledgment voided | Yes | Yes |
| PLC tags cleared | Yes | Yes (after pause already set idle state) |
| Checkout event logged | Yes | Yes — includes footage, both disposition choices |
| Dashboard 1 updated | Line → IDLE | Line → IDLE |
| Dashboard returns to | Ready for Check-In (DB2) | Ready for Check-In (DB2) |

### Access Control

| Action | Permitted Roles |
|--------|----------------|
| Pre-run checkout | FL1 / FL3 operators |
| Mid-run checkout | FL1 / FL3 operators |
| Approve mid-run checkout (if approval required — see OQ-B) | Supervisor / Operations Manager |

### Open Questions

See [RodCheckout.md](../MVP-1/RequirementDocuments/RodCheckout.md) — Open Questions OQ-A through OQ-D for items that require customer confirmation before implementation.

---

## Screen Navigation Map

> **This map spans both MVP scopes and is deliberately NOT divided.** It is one diagram; halving it would
> produce two partial maps with dangling edges. The repository has already ruled on this shape — *"One ER
> diagram covering all 28 tables. **Not divided — a half-ER is worse than none**"*
> ([`../MVP-2/DBChanges/README.md`](../MVP-2/DBChanges/README.md)).
>
> **MVP-2 nodes in the diagram below: `Dashboard 9`, `Dashboard 9A`, `Dashboard 10`.** Every other node is
> MVP-1. Two edges therefore cross the scope boundary and are expected to dangle in an MVP-1-only build —
> `Dashboard 1 → Dashboard 9A` and the `Dashboard 9A → Dashboard 9` open/row edge.


```
                    ┌─────────────────────────────────┐
                    │  Dashboard 1 — Line Overview    │
                    │  (always visible — supervisor)  │
                    └──────────────┬──────────────────┘
                                   │
           ┌───────────────────────┼───────────────────────┐
           ▼                       ▼                       ▼
  ┌─────────────────┐   ┌──────────────────┐   ┌─────────────────────┐
  │ Dashboard 2A    │   │ Dashboard 5      │   │ Dashboard 9A        │
  │ Rod Pre-Check-in│   │ FL2 Spool Check-in│  │ Pass Sched. List    │
  │ (payoff staging)│   └────────┬─────────┘  └──────────┬──────────┘
  └──┬──────────────┘
     │ [Proceed to check-in]
     ▼
  ┌─────────────────┐
  │ Dashboard 2     │
  │ FL1 Rod Check-in│
  └──┬──────────────┘
                                                          │ [Open / row]
                                                          ▼
                                               ┌─────────────────────┐
                                               │ Dashboard 9         │
                                               │ Pass Schedule Mgmt  │
                                               └─────────────────────┘
     │  │                        │
     │  │ [Check Out Rod]        │
     │  ▼                        ▼
     │ ┌──────────────┐  ┌──────────────────┐
     │ │ Dashboard 12 │  │ Dashboard 3      │
     │ │ Rod Checkout │  │ Active Run Mon.  │
     │ │ (Pre-Run A)  │  │ (FL2)            │
     │ └──────────────┘  └────────┬─────────┘
     ▼                            │
  ┌─────────────────┐             ▼
  │ Dashboard 3     │    ┌──────────────────┐
  │ Active Run Mon. │    │ Dashboard 7      │
  │ (FL1 / FL3)     │    │ Output Completion│
  └────────┬────────┘    └──────────────────┘
           │
     ┌─────┼──────┬──────┬──────┬──────────────┐
     ▼     ▼      ▼      ▼      ▼               ▼
  ┌─────┐ ┌───┐ ┌────┐ ┌────┐ ┌────┐   ┌──────────────┐
  │DB-4 │ │DB6│ │DB8 │ │DB11│ │DB7 │   │ Dashboard 12 │
  │Weld │ │SPC│ │WIP │ │Roll│ │Out │   │ Rod Checkout │
  │Event│ │   │ │Rej │ │Adj │ │Coil│   │ (Mid-Run B)  │
  └─────┘ └───┘ └────┘ └────┘ └────┘   │ via Pause    │
                                        └──────────────┘
           │
  ┌────────┘
  ▼
  ┌─────────────────────┐
  │ Dashboard 10        │
  │ Shift Summary       │
  └─────────────────────┘

Dashboard 2A ─[inspection Fail]────────────────► Dashboard 8  (WIP Rejection — hard block)
Dashboard 2A ─[Pre-check-out]──────────────────► releases the bay in place (ModeP, no PLC clear)
Dashboard 2A ─[Mark as welded]─────────────────► (dialog in place — Dashboard 4 retired)
Dashboard 2  ─[More options tile]──────────────► Dashboard 2A
Any screen   ─[topbar More Options tile]───────► Dashboard 2A

```

---

## Design Principles

1. **One shared UI for FL1 and FL2** — confirmed April 16 meeting. Context (FL1 or FL2) is set at log-in or job selection, not via separate applications.
2. **Generic labels** — use "Incoming Bundle Information" rather than line-specific field names to support both rod and spool inputs.
3. **Flat wire terminology** — use "flat wire" consistently across all screens. Do not use "strip."
4. **Pass schedule is read-only for operators** — operators can only acknowledge, not modify. Modifications require Operations Manager credentials and are logged.
5. **PLC tag push is gated** — PLC tags are only pushed after the operator explicitly acknowledges the pass schedule. No automatic push.
6. **Traceability at every step** — every screen that captures material movement, measurement, or quality event must link to the active alpha(s).
7. **Alert-first design** — payoff weight, gauge deviation, and component faults surface as alerts on Dashboard 1 before the operator at the machine needs to react.
8. **Digital traveler only (decided Apr 28, 2026)** — flat wire uses a fully screen-based traveler. No printed traveler in Phase 1. Traveler data is generated and stored for display and audit. The "Print Traveler" action is disabled for flat wire operations. Note: physical coil labels (Dashboard 7 — PRINT COIL LABEL) are separate from the traveler and are not affected by this decision.

---

## Related Documents

**The requirement documents that own these screens are listed in the Dashboard Inventory above.** This table covers the cross-cutting sources only.

| Document | Purpose |
|----------|---------|
| [`../MVP-1/RequirementDocuments/`](../MVP-1/RequirementDocuments/) | **The owning requirement documents for every screen in this file** — client-facing, with sign-off sheets |
| [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) | Open questions register — **99 items** (authoritative for decisions) |
| [FlatWirePlan.md](FlatWirePlan.md) | Implementation plan — scope, milestones, risks. **Partially superseded**: dead timeline and pre-May-21 equipment |
| [FlatWireEndToEndProcess.md](FlatWireEndToEndProcess.md) | End-to-end process reference — 11 stages. **Partially superseded**: FM2 description predates the May 21 and Aug 4 corrections |
| [FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) | Sequential operator walkthrough, and the `Known Source Conflicts` arbitration table |
| [`../LatestDocument/FlatWire_MasterSpecification.md`](../LatestDocument/FlatWire_MasterSpecification.md) | Reconciliation authority when two documents disagree (§10), and the `OI-##` register |
| [`../MVP-1/Mockups/`](../MVP-1/Mockups/) | **The approved visual baseline.** The ASCII wireframes in this file are a design record, not the pixels |
| Flat Wire Machine - Big Beautiful Diagram.png | Equipment layout schematic |
