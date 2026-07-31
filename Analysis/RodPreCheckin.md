# Rod Pre-Check-in — Payoff Staging (FL1 / FL3)

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 31, 2026
**Status:** Design complete — mockup and schema delivered; **four** items awaiting business confirmation (`INFLAT`-vs-`STAGED`, pre-check-out approval, **Q76** FL1/FL3 bay uniqueness, **Q77** welded-rod release)
**Requirement source:** `SRS/Shopfloor_Flat_wireSRS_Consolidated_v3.docx` §4.2 (`PCI001`–`PCI008`), §4.18 (`PRC001`–`PRC019`), welding (`WLD003`/`WLD005`/`WLD006`/`WLD010`/`WLD011`), traveler (`TRV002`/`TRV004`/`TRV009`)
**Screen:** [dashboard_2a_rod_precheckin.html](../Mockups/dashboard_2a_rod_precheckin.html)

---

## Why this document exists

Pre-check-in has been a specified feature with numbered, testable requirements since the consolidated SRS. It had **no analysis note, no mockup, no data model, no API, and no phase owner** — and the WIP-station script deliberately did *not* create its station.

The reason it stayed invisible is mechanical: **`.docx` files are zip containers, so `grep` does not reach inside them.** Every markdown search for "pre-checkin" in this repo returns hits about the *forbidden Angular reference library* `checkin-precheckin`, not the feature. `SRS/Shopfloor_Flat_wireSRS.docx` (the older file) contains **zero** pre-check-in content; only the consolidated v2/v3 files carry the requirement set.

`RocCheckin.md` and `RodCheckout.md` exist for the adjacent steps. This is the missing third note.

---

## What pre-check-in is

FL1 and FL3 draw rod from a **VPS — Variable Position Payoff**: dual position, eye-to-sky, **9,000 lb per position** ([FlatWirePlan.md:83](FlatWirePlan.md#L83)). Continuous operation depends on alternating the two bays:

1. Payoff 1 is drawing. Weight falls below 3,000 lb → "prepare weld" alert.
2. The next bundle is **pre-checked-in** on Payoff 2 while Payoff 1 is still running.
3. The operator induction-welds rod tail to rod head and marks it welded.
4. Payoff 1 reaches 0 ft remaining; feed transitions to Payoff 2. **The line never stops.**

Pre-check-in is step 2. It is what makes the weld possible — and the reason a rod is at the payoff at all, since **bundles are not unbanded until positioned at the payoff** (safety and bundling integrity), which is also why the visual inspection happens here rather than at check-in.

> **`PCI001`** — support pre-check-in of the next rod at FL1 **while the current coil is still running**.
> **`PCI002`** — **not** supported on FL2: no staging space. FL2 is check-in only.
> **`PCI003`** — provide a dedicated Pre-Check-In station for FL1.
> **`PCI006`** — capture the intended payoff position (Payoff 1 or Payoff 2) at pre-check-in.
> **`PCI008`** — automatically surface pre-checked-in material during **weld selection** to enforce sequencing.
>
> ⚠ *"Enforce sequencing" here means **physical weld sequencing** — the weld defaults to whichever rod is actually staged on the idle bay (the operator can still override by scanning). It does **not** mean the planned processing order, which is a separate rule — see [Planned sequence — notify and authorise](#planned-sequence--notify-and-authorise) below.*

SRS priority is **Should**, not **Must**. Check-in does not depend on it: scanning an unstaged rod directly into Dashboard 2 remains a valid path. Pre-check-in earns its place through the continuous-feed workflow, not by gating anything.

---

## Vocabulary — four distinct events, one overloaded word

"Checkout" now means three different things across the SRS. Use this table; it is the single most common source of confusion in this area.

| Term | Trigger | Run? | Footage | Pass schedule ack | PLC tags | Screen |
|---|---|---|---|---|---|---|
| **Pre-check-in** (stage) | Rod positioned at a bay, current coil still running | No | — | None | **Never pushed** | Dashboard 2A |
| **Pre-check-out** (un-stage) | Staged rod removed before check-in | No | 0 | None to void | **None to clear** | Dashboard 2A |
| Check-in | Wizard + acknowledgement | Created | 0 | Acknowledged | **Pushed** | Dashboard 2 |
| Checkout **Mode A** | Post-ack, footage still 0 | Yes | 0 | Voided | Cleared | Dashboard 12 |
| Checkout **Mode B** | Mid-run, supervisor approval | Yes | > 0 | Voided | Cleared after confirmed stop | Dashboard 12 via Pause |

**Pre-check-out is not Mode A.** Mode A assumes a check-in happened: it voids an acknowledgement and clears PLC tags. A pre-checked-in rod has neither. Modelled as `RodCheckout.Mode = 'ModeP'` with `RunId` NULL, footage 0, `PlcTagsCleared` false — reusing the existing table rather than adding a parallel one, with `CK_RodCheckout_ModeP` enforcing all of it.

A useful consequence: pre-check-in and pre-check-out need **no `FL{n}.LineState` gate**. The `RCO003`–`RCO007` gatekeeper exists because clearing tags on a running line is dangerous. An idle bay is not running — which is precisely why staging is safe to do while the other payoff draws.

---

## Station and screen

Dashboard 2A presents both bays as peers, which no existing screen did — payoff appeared only as one field inside the Dashboard 2 wizard and as read-only context on Dashboard 12.

**Bay states**

| State | Meaning | Actions |
|---|---|---|
| `NOT STAGED` | Empty bay | Pre-check-in rod · *(when the whole station is empty, also a direct Go-to-check-in route)* |
| `PRE-CHECKED-IN` | Staged, inspection passed, not checked in | Pre-check-out · Proceed to check-in · Mark as welded |
| `ACTIVE` | Checked in, rod `INFLAT`, run open | Open active run · Check out rod |
| `BLOCKED` | Inspection failed at staging | Go to WIP Rejection — **only** action |

> **Both bays are true peers — every state applies to either payoff.** This is not decorative symmetry. Payoff 1 is empty on a cold start, after a Mode A/B checkout, once the run consumes its rod, and between orders; Payoff 2 becomes the *running* bay after every payoff transition. Any design that treats Payoff 1 as "the one that runs" and Payoff 2 as "the one you stage" is wrong for at least four routine situations.
>
> The mockup originally made exactly that assumption — Payoff 1 was a static always-`ACTIVE` backdrop with no empty view and no state machine. A cold start threw on the first render, which killed the entire first paint: the queue never drew, and the screen sat there showing a **rod that was not on the payoff**, complete with a plausible live weight. Both bays now share one renderer and one state shape, and the demo simulator cycles the whole station (including cold start and a swapped running bay) so those states are reachable in review rather than only in production.

### Cold start — nothing on either payoff

There is no material on the line at the beginning of a campaign, and pre-check-in is a **Should**, not a **Must**. Two routes are therefore both correct, and the screen offers both:

1. **Straight to check-in (Dashboard 2).** Nothing is drawing, so there is nothing to weld to and staging buys nothing. Scan the first rod at check-in, acknowledge the pass schedule, tags push, the run starts, and that bay becomes `ACTIVE`. This is the normal cold-start path.
2. **Stage first on 2A, then check in.** Useful only when the bundle is physically positioned before the operator is ready to start the run.

With both bays free the wizard offers **both** payoff positions — a bay is disabled because it is *occupied*, never because of which bay it is. Weld readiness reads *"no material on either payoff"* and Mark-as-welded is disabled with the reason given, because a weld needs a **running** rod as well as a staged one.

**Weight-bar thresholds** — see *Payoff Weight Indicator Rules* in [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md#payoff-weight-indicator-rules). Warning below **3,000 lb** ("prepare weld"); **critical when Payoff 2 is not staged and Payoff 1 is below 2,000 lb** — the Phase-3 alert rule that was previously unimplementable because nothing recorded whether Payoff 2 was loaded.

> The bar **colour is driven by those absolute pounds, not by percent bands**. The published `>50% / 25–50% / <25% / <10%` ladder escalates against the alerts rather than with them: against a 9,000 lb position the bar would still read amber as WELD SOON fires at 3,000 lb, and would only start flashing at 10% ≈ 900 lb — well over 1,000 lb *after* the 2,000 lb critical. The loudest visual cue would arrive long after the urgency it signals. Bar *length* still shows percent remaining; only the colour changed.

**Queue panel** implements `TRV004` (serial number, payoff position number, dimensional attributes, current status) and `TRV009` (the Pre-Check-In station Traveler shows *both* pre-checked-in and welded rods). It carries **two** sequence columns, `Plan` and `Run` — see below. Every row carries `footageRunToDate` so partial rods are visible **before** staging rather than surprising the operator mid-scan. An **order context header** states the line, order number, the order's material spec and progress (`n staged · n available · n on order`); `Alloy`/`Temper` are therefore not repeated per row, and rod-storage `Location` is not shown at all.

### Planned sequence — notify and authorise

**The planned rod sequence is authorised, not enforced.** Rods are planned in a predefined order — say `R00043 → R00044 → R00045` — and the floor can legitimately depart from it. But that departure is **not the operator's unilateral call**: the operator is told which rod planning expects next, and a **supervisor authorises** running a different one. It is never a hard refusal.

> **Superseded (July 30 2026).** An earlier requirement had the sequence entirely unenforced — *"the operator must be allowed to process the rods in any sequence"*, with explicitly no warning and no override. The notify-and-authorise rule replaces it. The two-sequence data model is unaffected: `PlannedSeqno` still records intent, `RodSeqno` what actually ran, so the deviation stays reportable as well as accountable.

Staging therefore has two **validations** and two **authorisations**:

| | Rule | If it fails |
|---|---|---|
| Validation | Rod has a `planning_routings` allocation | Refused |
| Validation | Rod is **available** — `coils.coil_status` not `INFLAT`/`COMPLETE`/`HOLD`/`SCRAP`, not staged elsewhere | Refused |
| Validation | Rod belongs to the **established order** (once one exists) | Refused — weld genealogy, Q69/Q72 |
| Authorisation | Rod's order is scheduled on **this line** | Supervisor override |
| Authorisation | Rod is the one planning **expects next** | Supervisor override |

**"Expects next" is the lowest planned sequence still available.** A rod already staged, welded or blocked is no longer a candidate, so a failed bundle does not freeze the sequence behind it. On a cold line nothing has been processed, so planned #1 is expected — staging #3 first is a deviation even as the very first rod.

Both authorisations use the **same credential block** (reason + supervisor badge/ID + PIN, remote-approval fallback) and one sign-off covers both when they coincide. The queue marks the expected rod with a green `▸` so the operator can see which choice needs no authorisation, and the bay card keeps showing *"Authorised by …"* for as long as the rod is there.

Note that `PCI008`'s phrase *"to enforce sequencing"* still does **not** mean this. It refers to *physical weld* sequencing — the weld defaults to whichever rod is on the idle bay. The planned-order rule is a separate concern.

**Both sequences are retained**, which is why `RodStaging` carries two columns rather than one:

| | `PlannedSeqno` | `RodSeqno` |
|---|---|---|
| Meaning | Order planning intended | Order the rod was actually staged in |
| Assigned | At planning | At pre-check-in, by the server |
| On an unprocessed rod | Present | **NULL** — nothing has happened yet |
| Purpose | Planning and reporting | Transaction history / traceability |
| Mutable | By planning | Never |

`RodSeqno` is the SRS `FlatwireQueue` sequence (`Rodno`/`RodSeqno`/`Welded`) — that model inserts at pre-check-in, which is precisely why it records *actual* order. `PlannedSeqno` is a **snapshot** taken at staging, not a live join back to planning: the same pattern the design already uses for the pass schedule, whose id, version and effective date are copied onto the run record rather than re-resolved later. Variance is then a subtraction rather than a reconstruction, and a traceability query years later never has to reach into current planning data to answer "was this run in planned order?"

Dashboard 2A shows both as **Plan** and **Run** columns, with a neutral `⇅` marker where they differ. Deliberately neutral: processing out of order is an allowed operational choice, and an amber or red treatment would read as "you did something wrong."

> **Consequence to confirm.** Scoping validation to the *current* order means the last rod of order A cannot be welded to the first rod of order B, so continuous feed does not cross an order boundary. That is probably right — the pass schedule may change between orders anyway — but it should be confirmed rather than discovered. It also leans toward closing **Q69** (staging against a *future* order) as *no*.

### Which order is the line on?

**The order is not ambient — the rod reveals it.** `GET /linestatus` returns `activeOrderId: null` while a line is `Idle`, so at cold start the station genuinely does not know which order it is on, and the screen must not display one. The queue is empty, the order header reads `—`, and both bays invite either route.

The resolution point is the scan. Planning allocates rod→order at planning time and that mapping lives in **`planning_routings`**, readable at pre-check-in and check-in. So the first rod on a cold line *reveals* an order planning already assigned rather than the operator *choosing* one — which is precisely what keeps the first rod validatable. Once established, the order populates the header and the queue fills with the rest of that order's rod.

| Outcome of the lookup | Behaviour |
|---|---|
| No `planning_routings` entry | **Refused.** Planning must allocate the rod first |
| Order matches the established one | Normal |
| Order differs from the established one | **Refused** — welding across orders breaks coil genealogy (Q69 / Q72). Finish or check out the current order first |
| Order is booked on **another line** | **Notified, and authorised by a supervisor** — not refused |

**Off-schedule staging is authorised, not blocked.** A rod whose order is scheduled elsewhere would start another line's job, so the operator is told plainly which line owns it, and a supervisor authorises with **reason + badge/ID + PIN** (remote-approval fallback when nobody is on the floor). This deliberately reuses the override already decided for out-of-tolerance spool weight (**Q66** part 3) rather than inventing a second pattern. The override, the authorising supervisor and the reason are persisted on the staging row — `CK_RodStaging_OffSched` makes it all-or-nothing, because an override with no supervisor or no reason is unauditable and defeats the point of permitting it. **The PIN is never stored.** The bay card keeps showing *"Off-schedule — authorised by …"* for as long as the rod is there: the authorisation is not a dismissal.

> Un-staging the last rod on an idle line returns the station to cold start and **clears the order** — holding on to it would claim an order the line is not running.

### How the queue is populated

The Traveler Queue is **two data sets in one panel**, with two different owners:

| Rows | Source | Owner |
|---|---|---|
| `PreCheckedIn`, `Welded` | `RodStaging` | FlatWireDB — written by pre-check-in |
| `Available` | Derived projection | Planning / scheduling, shared DB |

The upstream chain that puts a rod in the `Available` set: rod received against a PO → alpha `R#####` assigned, `proddb..coils` row created, status `RECEIVED` → **planning allocates that rod to an order** ([FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) §A step 5: *"selects available rod material, assigns weight to the order"*) → scheduling books the order on FL1/FL2/FL3. A rod is therefore "at FL1" because the order it was allocated to is scheduled there.

**There is no queue table, and there must not be one.** The `Available` set is resolved at request time. Planning owns rod→order allocation and scheduling owns order→line; mirroring either into `FlatWireDB` would create a second source of truth with **no event channel to keep it current** — nothing in the design notifies FlatWire when a planner re-allocates a rod, reschedules an order or puts material on HOLD. A stale row costs physical work: the operator fetches a 9,000 lb bundle to the payoff before the scan catches it. It would also re-introduce exactly what `00-foundations.md` decision 3 avoided by making `coils` the single source of truth for rod material. Read across via the indexed-alpha + read-only-view route in gap **G17**.

The candidate set is simply "allocated to the current order and available" — an unordered set. The planned sequence is an attribute of each rod, not state the queue has to maintain, so there is still nothing for such a table to defend.

> **Not yet mapped (blocks Phase 4).** The concrete planning/scheduling table and column names behind this projection live in `ual-database`, outside this repo. That mapping is the missing **Tables (read)** entry in `phase-04` and should be produced before the phase starts.
>
> **Rod storage location is deliberately not shown** (dropped Jul 29 2026). The queue previously carried a `Location` column (`Bay A-12`, `Bay B-03`). It is not a `TRV004` field, it depended on **Q19** — whether rod storage is tracked system-side at all, or managed physically — and a location that nobody updates when a forklift moves a bundle is worse than none on a screen whose job is "fetch the next bundle." It also collided with the screen's own vocabulary: *bay* means a **payoff** position everywhere else here (`UX_RodStaging_Bay`, "one rod per payoff bay", "Bays occupied"). If the business later wants it, reintroduce it only once Q19 closes, and not using the word "bay".

### Pre-check-in wizard — three steps

1. **Identify rod** (`PCI004`, `PCI005`) — scan or type the alpha, validated against the `R#####` series in `proddb..coils` (`CHK006`); diameter validated against nominal ± lookup tolerance (`CHK007`). Optional scrap box with same-alloy carry-forward. Rejects a rod already checked in elsewhere (`CHK009`).
2. **Assign bay** (`PCI006`) — two card-style options; the occupied bay is disabled and labelled with its occupant.
3. **Visual inspection before unbanding** — oxidation, surface defects, water stains. **Three items, not four.**

**Carry-forward gate.** If `footageRunToDate > 0`, the wizard shows the prior-run history and offers only *Proceed as partial re-check-in* (`PRC007`, `PRC011`), plus an explicit physical-identity confirmation (`PRC014`). The fresh-start path **does not exist in the DOM** (`PRC008`) — see [PartialRodReCheckin.md](PartialRodReCheckin.md). Moving this gate to the staging scan is a genuine improvement: staging is where the rod is *first* identified, so a partial rod is caught before it is ever mounted.

**Inspection failure is a hard block with no bypass** (`CHK010`). The only forward action is WIP Rejection.

### Mark as welded — `WLD010`

Station-level action, **enabled only when a rod is pre-checked-in** on the idle bay. Captures operator and timestamp (`WLD003`) and validates that alloy, temper and diameter match the running coil (`WLD006`).

Per **`WLD005`** the payoff transition is driven **solely by material consumption reaching 0 ft remaining** — this button records the physical weld, it does not switch bays. Supervisor reversal of a welded coil (`WLD011`) is not yet specified.

---

## Data model

`RodStaging` in `FlatWireDB` — see [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md).

The design question was where staging state should live. It had been two provisional columns — `Rod.StagedPayoffPosition` and `Rod.IsWelded` — on a table that foundations decision 3 had dropped, so nothing wrote them and no API exposed them (gaps G5/G12/G17).

**A dedicated table was chosen because a nullable column pair cannot express the core invariant.** "One rod per payoff bay" is the whole point of a two-bay station, and two filtered unique indexes make it unviolatable, including under concurrent staging from two clients:

```sql
CREATE UNIQUE INDEX UX_RodStaging_Bay       ON RodStaging (LineId, PayoffPosition) WHERE Status = 'Staged';
CREATE UNIQUE INDEX UX_RodStaging_RodActive ON RodStaging (RodAlpha)               WHERE Status = 'Staged';
```

Lifecycle: `Staged → CheckedIn` (check-in **consumes** the row and links `RodCheckinId`) or `Staged → Unstaged` (pre-check-out). Check-in never creates a parallel staging record.

Supporting changes: a real `PayoffPosition` lookup with three pinned rows — Payoff 1, Payoff 2, and FL2's traversing take-up — finally gives `FlatWireRunDetail.PayoffPositionId` a parent (`REVIEW.md` #15); and `WeldEvent` gained `OutgoingPayoffPosition`/`IncomingPayoffPosition`, because the weld *is* the payoff handover and recording only rod alphas made it inferable but not queryable.

All 10 constraint tests pass against SQL Server 2019; `RunAll` remains idempotent at 27 tables.

---

## Deliberate non-decisions and known conflicts

These are recorded rather than quietly resolved.

**1. `CHK005` vs the approved Dashboard 2 mockup.** The SRS says the Payoff 1/2 buttons are *"available on the Pre-Check-In station only"*, but Dashboard 2 has the selector in its always-visible rod-scan row and gates wizard step 1 on it. **Resolution applied:** Dashboard 2 keeps its selector for the direct-check-in fallback, rendered pre-filled and read-only when the rod arrived via pre-check-in. Satisfies both readings; confirm with the business.

**2. `INFLAT` at pre-check-in vs `RECEIVED → STAGED`.** The SRS `PCI` data note has pre-check-in performing the `FlatwireQueue` insert, setting `coils.coil_status = INFLAT`, and doing reqsum + `wip_coil_orders` insert. [FlatWireProcessWalkthrough.md:40](FlatWireProcessWalkthrough.md#L40) says `RECEIVED → STAGED`. **Resolution applied:** treat them as orthogonal — `RodStaging.Status` is bay occupancy, and the shared `coils.coil_status` follows the SRS, because planning and WIP need the material committed once queued. This makes rod status `STAGED` effectively vestigial for FL1. **Still needs business sign-off**, and it is why pre-check-out must *reverse* the `wip_coil_orders` insert.

**3. Pre-check-out has no SRS requirement ID.** §4.17 covers only post-check-in removal. It needs a new `PCI`-series block, and confirmation that operators may un-stage without supervisor approval — contrast OQ-48, where *mid-run* checkout requires it. The mockup assumes operator-only.

**4. The WIP station was deliberately not created.** [CommonDB_Insert_WIPStations_FlatWire.sql:104-108](../DevelopmentPlan/DBScripts/CommonDB_Insert_WIPStations_FlatWire.sql#L104-L108) states *"No per-line PRE / payoff station… Flat wire does not use that flow."* That is correct about the **legacy `PreCheckIn_PreCheckInCheckIn_Transaction` flow**, which flat wire genuinely does not use, but it reads as a blanket refusal and contradicts `PCI003`. `FL1PO` must be enabled; `FL2PO` stays out per `PCI002`.

**5. Three-item vs four-item inspection (gap G14).** Dashboard 2 adds a fourth "connector tag present" item and `RodCheckin` persists `InspectionConnectorTag`. The walkthrough and `CHK010` specify three. `RodStaging` carries **three** and deliberately does not inherit the fourth — which also keeps it clear of `REVIEW.md` #37, where `RodCheckin` requires NOT NULL columns the check-in command never sends.

**6. Not one ACID transaction (gaps G2/G16).** Staging writes span `FlatWireDB`, `proddb..coils`, and `wip_coil_orders`. These are **compensating writes**, not an atomic rollback — describe them that way.

---

## Open questions raised by this work

Logged in [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md):

- Does pre-check-out require supervisor approval, mirroring the OQ-48 mid-run rule?
- Does pre-check-in really set `coils.coil_status = INFLAT`, and if so what reverses it on un-stage?
- Can a rod be pre-checked-in against a *future* order, or only the current one?
- Is `RodSeqno` scoped per line, per order, or globally?
- Is a payoff-side scale available for weighing remnants? (extends OQ-47)

---

## Related Documents

| Document | Purpose |
|---|---|
| [RocCheckin.md](RocCheckin.md) | Check-in — the step immediately after staging |
| [RodCheckout.md](RodCheckout.md) | Mode A / Mode B checkout — post-check-in removal |
| [PartialRodReCheckin.md](PartialRodReCheckin.md) | Carry-forward design (OQ-47); the `PRC007` gate now fires at the staging scan |
| [WeldEvent.md](WeldEvent.md) | The weld this staging exists to enable |
| [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) | Dashboard 2A screen spec and navigation map |
| [FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) | §B Pre-Check-in in the end-to-end sequence |
| [APIContracts.md](../DevelopmentPlan/APIContracts.md) | `/staging/**`, `/payoff/status`, `PayoffStateChanged` |
| [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md) | `RodStaging` data dictionary |

---

## Change Log

| Date | Change |
|---|---|
| July 29, 2026 | Initial document. Traced SRS §4.2 / §4.18 / `WLD` / `TRV` requirements into a screen, a data model (`RodStaging`), and an API contract; recorded six pre-existing conflicts rather than silently resolving them. |
| July 29, 2026 | **Free rod processing order.** Planned sequence is not enforced — staging validates only current-order membership and availability, never "has the earlier-planned rod been run". Added `RodStaging.PlannedSeqno` alongside `RodSeqno`, which is now explicitly the **actual** processing order assigned at pre-check-in; both are retained so variance is a subtraction rather than a reconstruction. Added the *Processing order is the operator's choice* and *How the queue is populated* sections — the latter documents that the `Available` set is a **derived projection over planning allocation, not a stored queue**, and that its concrete table mapping is still missing from phase-04. Annotated `PCI008` ("enforce sequencing") as *physical weld* sequencing, not planned order. Dashboard 2A gained an order context header (spec + progress) and dropped the rod-storage Location column. |
| July 29, 2026 | **Cold start made operable; the two bays are now true peers.** Payoff 1 had been a static always-`ACTIVE` backdrop with no empty view and no state machine, so an empty Payoff 1 threw on the first render, killed the entire first paint (queue included) and left the screen asserting a rod that was not on the payoff. Both bays now share one state shape and one renderer, every state applies to either side, and a bay is disabled in the wizard because it is *occupied* rather than because of its number. Added the cold-start route (stage here, or go straight to check-in), a zero-material weld-readiness state, a Mark-as-welded gate requiring a **running** rod as well as a staged one, a derived bays-occupied count, and a station simulator that cycles cold start and a swapped running bay so those states are reachable in review. |
| July 29, 2026 | **Order resolved from `planning_routings`; off-schedule staging authorised rather than refused.** The line's order is no longer ambient — `GET /linestatus` reports `activeOrderId: null` while idle, so cold start now shows no order and an empty queue, and the first rod *reveals* the order planning already allocated. That is what keeps the first rod on a cold line validatable. A rod whose order is booked on another line is notified and authorised by a **supervisor override** (reason + badge/ID + PIN, remote-approval fallback — reusing the Q66 pattern rather than inventing a second one), recorded on `RodStaging` via five new columns and an all-or-nothing `CK_RodStaging_OffSched`; the PIN is never stored, and the bay keeps showing the rod as off-schedule while it is there. A rod from a *different* order once one is established stays a hard refusal (weld genealogy — Q69/Q72). Un-staging the last rod clears the order. Added `orderId`/`scheduledLineId` to `GET /rod/{alpha}`, which previously returned no order at all. Logged **Q74**. |
| July 31, 2026 | **`Blocked` made reachable; two wrong-target controls removed; new `Q76`/`Q77`.** From the [Dashboard 2A UX review](Dashboard2A_UXReview.md). Staging now **commits the `RodStaging` row before the inspection gate** — `POST /staging/rod` returns `201` with `state:"Blocked"` rather than `422`-and-write-nothing, because a bundle that fails inspection is already on the payoff (they are not unbanded until positioned there) and writing no row reported an occupied bay as `NotStaged`, offered it as "Empty — available" and let the next rod be staged into it. Closes **Q72** items 1–2; item 3 (*what releases the row*) is now the blocking residual. Dashboard 2A fixes: the queue's **Unstage** dropped the alpha it was given and fell back to "bay 2 first", so un-staging the Payoff 1 row released **Payoff 2's** rod whenever both bays held staged rod; **Unstage was offered on a welded rod**, which is induction-welded to the rod in the mill and cannot be returned to inventory (**`WLD011`** unspecified → **Q77**); a staged bay's weight bar was pinned to **100 %** while showing *remaining* pounds, so a partial rod read full; and an authorised deviation vanished at check-in because it shared the alert slot, contradicting *"keeps showing … for as long as the rod is there"* — it now has its own slot and survives into `ACTIVE`. Also logged **Q76**/**G21**: `UX_RodStaging_Bay` is keyed `(LineId, PayoffPosition)` while `CK_RodStaging_LineId` admits both `FL1` and `FL3`, so if the two share one physical VPS — the assumption here and the reason no `FL3PO` exists — **two rods can be staged on one bay with every constraint satisfied**. |
| July 30, 2026 | **Planned sequence is now authorised, not free.** Supersedes the earlier free-processing-order rule: departing from the planned order is still permitted and still never a refusal, but the operator is **notified** which rod planning expects next and a **supervisor authorises** the deviation. "Expects next" is the lowest planned sequence still available, so a blocked bundle does not freeze the sequence behind it. Reuses the same Q66 credential block as the off-schedule override — the two deviations can co-occur and share one sign-off. Added `RodStaging.OutOfSequenceOverride` + `ExpectedRodAlpha`, generalised `CK_RodStaging_Override` to cover either deviation, and added `CK_RodStaging_OutOfSeq` / `CK_RodStaging_OutOfSeqRod`. Queue marks the expected rod with a green `▸`; the `⇅` marker now names the authorising supervisor. Section renamed *Planned sequence — notify and authorise*. |
