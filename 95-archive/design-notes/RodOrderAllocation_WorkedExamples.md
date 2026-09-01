# Rod ↔ Order ↔ Spool ↔ Coil — Seven Worked Examples

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 24, 2026
**Status:** **Design analysis — rationale, not requirement.** Nothing here is citable as a requirement. The citable requirements are `[REQ]` §5.28, `FR-541`–`FR-560` / `ORD003`–`ORD017`; the rules these traces exercise are already recorded there, in [`RodOrderAllocation.md`](RodOrderAllocation.md) and in the screen specifications named in §13.
**Document Type:** Cross-cutting design analysis — worked examples
**Sources:** [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.4–§2.8, §3, §5, §6 · [`FL Alphas Plus.xlsm`](../BaseDocuments/FL%20Alphas%20Plus.xlsm) and its [analysis](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) · `Business/Screens/` — `SpoolCompletionNotification.md`, `OutputCoilCompletion.md`, `WeldEvent.md`, `RocCheckin.md` · the live DDL in `Database/Schema/SQL/`
**Companion:** [`RodOrderAllocation_WorkedExamples.html`](RodOrderAllocation_WorkedExamples.html) — the client-facing rendering of the same seven scenarios, in business language with band diagrams. Same numbers; **any change here must land there too.**

---

## 0. What this is, and the two axes

**Seven traces** — the six-cell matrix **{one order · one rod} × {one order · many rods} × {many
orders · many rods}** × **{welded, not welded}**, plus a **second reading of the last cell** in which
planning puts the order boundary on a coil cut instead of in the middle of one. Each is followed from
rod check-in at FL1 through to a finished coil on a skid at FL2, and states the actual rows it
produces.

§10 is the one that is not a new cardinality but a **different placement of the same one**, and it is
there because it is the fix for §9: same rods, same welds, same operator delay — only the boundary
moves, and 900 lb of unshippable material becomes two coils.

It exists because the repository has the mechanics right and has never put them in one place.
[`RodOrderAllocation.md`](RodOrderAllocation.md) §2.8 carries two traces, both **single-order**;
`WeldEvent.md` §5 carries one chain with **no order dimension**;
`SpoolCompletionNotification.md` §4.7 describes creating **one** spool. Answering *"what happens when
two orders share a rod and the spool spans the boundary"* currently means assembling five documents,
and the client's own planner cannot help — `FL Alphas Plus.xlsm` has **no order entity at all**, just
one scalar in cell `C4`.

### ⚠ The two axes are not independent

**A weld joins two rods.** So the "welded" variant of *one order / one rod* **cannot exist inside the
order**: there is no second rod to weld to. The only welds touching such an order are the **boundary
welds to the neighbouring orders' rods**, and those belong to the *rod pair*, not to either order.

State this before reading §4, or it reads as a missing scenario rather than a closed one. The general
form is worth holding onto:

> **Welding is a property of the rod sequence. Order boundaries are a property of the allocation.
> They are two independent partitions of the same rod, and their intersection is what makes §8 hard.**

That sentence is `RodOrderAllocation.md` §2.6's *"the two partitions are independent"* seen from the
material's side.

---

## 1. The five creation events, stated once

The seven scenarios are terse because this section is not repeated in them.

### 1.1 Rod check-in — one mount, one run

One `RodCheckin` row, one `FlatWireRun` (`RUN-####`) — the schema is *one row per check-in event*. The
operator acknowledges the pass schedule and the system pushes the PLC tags **from it, on
acknowledgement**. `FlatWireRun.PassScheduleId` and `FlatWireRun.OrderId` are both scalar `NOT NULL`.

**One check-in per mount, even across an order boundary** (client rule 7, `ORD014`). A second scan of a
mounted rod is a *duplicate*, not a fresh check-in — treating it as one would mint a second
`FlatWireRun` and re-push the tags into running material.

### 1.2 Weld — FL1 only, rod to rod

| Step | What |
|---|---|
| 1 | Running payoff drops below **3,000 lb** → *prepare weld* alert |
| 2 | Next bundle pre-checked-in on the **idle** payoff |
| 3 | *Mark as welded* at Dashboard 2A — **the only route there is**. Weld-point footage read from the machine encoder |
| 4 | Quality result recorded; **induction only**, no type choice |
| 5 | On **Pass** the run's active rod advances and the incoming rod is marked welded. On **Fail** the rod stays *staged and un-welded* and the weld is remade — two `WeldEvent` rows, one physical join |
| 6 | The **payoff transition happens later**, when the outgoing rod reaches zero |

**FL2 has no pre-check-in station and no weld route, and needs none** — welding is FL1's operation.
FL2 cuts and re-threads: *"we're welding at the FL1 side, but we're cutting and re-going again at the
FL2 side."*

### 1.3 Spool creation — FL1 take-up

Milestone ladder at **75 / 90 / 100 %** of target (`M1`–`M3`, plus the proposed `M4` over 101 %) →
operator **physically stops the machine** → machine-confirmed prompt → the completion transaction
writes, atomically:

| Written | Detail |
|---|---|
| `SpoolProcessing` | `Alpha` = `SP-#####` — the **material** identity |
| `SpoolTraceability` | **one row per segment**: `SpoolAlpha`, `RodAlpha`, `SeqNo` (order material went *on*, 1 = first), `SegmentWeightLb`, `FootageFrom`/`To` (spool-local, half-open), `WeldEventId` (NULL on the first segment), and `ChildAlpha` |
| `ChildAlpha` | ⛔ **now `CommonDB.dbo.GenerateCoilAlpha(rodAlpha, '')`** — a **blank** list; registration in `proddb..coils` replaces exclusion (`[N]`, 26 Aug 2026), and **`OI-138` is that the writer does not exist yet**. *Superseded:* minted by `CommonDB.dbo.GenerateCoilAlpha(rodAlpha, @ignoreList)`, the ignore list carrying **every** segment alpha already recorded for that rod in `SpoolTraceability` — `FlatWireDB` is outside the function's sweep |
| `SpoolOrder` | one row per order the spool carries, `Source='Derived'` |
| **The next carrier** | `S-26`–`S-31`. Typed and validated against the registered `Spool` articles (`SP-0001`…`SP-0045`). **A hard gate — the transaction cannot commit without it** |

**Closing below target is a short close** (Part C), graded against the **customer minimum–maximum
weight**, handled as an unplanned stop. The spool **always runs off** — FL2 has no spool stripper.

### 1.4 Coil creation — FL2 take-up

The spool is scanned — **any** segment alpha *or* the carrier number resolves it, the furnace-plate
behaviour. FL2 check-in is **exclusive**: one spool on the line at a time (`Q17`).

The spool unwinds **last-on-first-off** and is cut into stops inside the customer's weight range.
Each stop completes as one `CoilOutput`:

| Column | Value |
|---|---|
| `CoilAlpha` | `FW-#####-C##` — **local, `NOT NULL`, customer-facing.** `#####` is the **order**; `C##` is the coil sequence **within that order** |
| `CoilNo` | ⛔ **now `CommonDB.dbo.GenerateCoilAlpha(leadSegmentAlpha, '')`** — rooted on the **segment**, blank list; rod fallback where `SourceSegmentAlpha IS NULL` (`[N]`). *Was `(leadRod, @ignoreList)`.* → `VARCHAR(9)` — the **lead** part's alpha and the coil's one scalar shared face, `NULL` until the cross-database mint returns |
| ⚠ **`ChildAlpha`** *(new, 26 Aug 2026)* | **One alpha per source SEGMENT** *(amended the same day — was "per source rod"; the cardinality is identical, the mint root is not)*, on each `CoilTraceability` row — `CommonDB.dbo.GenerateCoilAlpha(thatRod, @ignoreList)`. ⚠ **Every one is written to `proddb..coils`** with its own weight from `SegmentWeightLb` (`Q88`, `Q89`). A single-rod coil has exactly one, equal to `CoilNo` |
| `OrderId` | scalar `NOT NULL` — **one coil, one order** |
| `CoilTraceability` | one row per (rod, spool, **coil-local** half-open footage range) |

**Primary rod** = the rod of the first segment consumed into that coil, `MIN(FootageFrom)` over its
traceability rows.

Two invariants that shape every scenario below:

- **`ORD016` — a coil's parents must all come from one spool.** The client's own planner enforces it by
  breaking its loop when `SpoolID` changes. Correct **by design**, not a modelling limit.
- **`ORD017` — segment weights sum to the spool weight, and a rod's to the rod weight**, checked at the
  *closing* transaction (spool completion, rod checkout), never continuously.

### 1.5 Skid

**Two coils per skid.** First coil opens it; second closes it, prints the skid label and moves it to
the packing queue. An **odd final coil** leaves a skid holding one — unspecified, `OI-98`.

---

## 2. ⚠ "Child coil" means three different things

The phrase maps onto three distinct mechanisms, and conflating them is the likeliest misreading of the
whole chain.

| Reading | What it actually is | Created by |
|---|---|---|
| **The coils cut from a spool** | `FW-00421-C05`, `-C06` — a **sequence within the order**. Siblings, not children | Ordinary FL2 stop completion |
| **A child in the *legacy* tree** | `CoilNo` `R00002AA` shares the six-character root `R00002`, so `coil_link_master_coil` groups it under master `R00002`. The output coils are children **of the rod** | `GenerateCoilAlpha`'s root grouping — a consequence of `R#####` being exactly six characters |
| **The mid-run child alpha** `…-C05-A` | A coil **split by a product-spec change** part-way through | `OQ-61` cases 2, 3 and 5 only — size/product-config change, edge-type change, roll-gap change to a new target |

> **Stated outright: a weld does not mint a MID-RUN `-A` child alpha, and neither does an order
> boundary.** ⚠ **Read "child alpha" strictly as the `…-C05-A` suffix in the third row of the table
> above** — since 26 Aug 2026 a weld *does* mint an extra **part alpha** on `CoilTraceability`
> (`Q88`), and that alpha *does* get its own `proddb..coils` row (`Q89`). Those are the second reading
> in the table, not the third. **The two mechanisms are unrelated and the wording below is about the
> third.**
> Only `OQ-61` mints `-A`. A weld adds a **row to `CoilTraceability`**; an order boundary forces a
> **cut between two coils**. Neither touches the identifier.

### 2.1 ⚠ `C##` is a per-order sequence — and `RodOrderAllocation.md` §2.8 numbers it per spool

`[REQ]`'s alpha table and the master specification both say it plainly: *"The `FW-#####` part is the
order; `C##` is the coil sequence."* `RodOrderAllocation.md` §2.8 writes `FW-00001-C01` for spool 1's
first coil and `FW-00003-C01` for spool 3's — restarting at `C01` per **spool** and putting the spool
number in the `#####` position.

**This document uses the authoritative form**, and the difference is not cosmetic: on §6's 40,000 lb
order the sequence runs `C01`…`C45` unbroken across twenty-three spools, where the §2.8 reading would
produce twenty-three separate `C01`s. **The `CoilNo` mints in §2.8 are correct and are reproduced
exactly**; only the `CoilAlpha` strings differ. Recorded as an observation in §12, not as a new
register id.

---

## 3. Fixed basis — every number below

The **shipped run's own inputs**, so these traces reconcile with `RodOrderAllocation.md` §2.8 line for
line rather than introducing a fourth set of figures.

| Quantity | Value | Source |
|---|---|---|
| Rod weight | **4,000 lb** | workbook `INPUT!C3` |
| Spool target | **1,800 lb** | `INPUT!C5` — sized so FL2 cuts **two** coils from one spool |
| Coil minimum / maximum | **800 / 900 lb** | `INPUT!C6`/`C7`. The customer range is the grading basis, `[CONFIRMED — 30 Jul 2026]` |
| FL1 factor | **0.0809 lb/ft** — alloy 1100, 0.110″ × 0.625″ | `[DBD §6.6]`, `TC-167` |
| FL2 factor | **0.0118 lb/ft** — alloy 1100, 0.0160″ × 0.625″ | `[DBD §6.6]` |

Working checkpoints, used throughout and internally consistent:

| lb | FL1 ft | | lb | FL2 ft |
|---:|---:|---|---:|---:|
| 400 | 4,950 | | 400 | 33,900 |
| 500 | 6,180 | | 500 | 42,400 |
| 800 | 9,890 | | 800 | 67,800 |
| 1,000 | 12,360 | | 900 | 76,300 |
| 1,200 | 14,840 | | | |
| 1,400 | 17,300 | | | |
| 1,500 | 18,540 | | | |
| 1,800 | 22,250 | | | |
| 2,500 | 30,910 | | | |
| 4,000 | 49,450 | | | |

> **Container footages — spool-local and coil-local — are rounded to the nearest 10 ft and made to sum
> exactly within each container**, matching the `INT` columns that hold them. **Threshold footages are
> not**: `ThresholdFootageFt` is `DECIMAL(10,2)` and is computed from pounds at the running gauge, so it
> is quoted to two places and will differ by a few feet from the rounded table below.
> **Weight is the conserved quantity** — it survives drawing and rolling and footage does not, which is
> why the allocation split is held in pounds (`RodOrderAllocation.md` §2.6). The same 900 lb is
> ≈ 11,100 ft at FL1 gauge and ≈ 76,300 ft at FL2, a 7× cross-section difference.

> ⚠ **The 4,000 lb rod is one of three figures in circulation** — the workbook says 4,000, the 20 Aug
> transcript ~5,500, the delivered contracts 8,690–8,840 (`OI-97` / `OQ-J`). Every spool and coil count
> below scales with it. The *shapes* do not.

---

## 4. Scenario 1 — one order, one rod, **no weld**

### Setup

Order `00421`, allocated **4,000 lb**. Rod `R00001`, 4,000 lb. Nothing else on the station.

### Plan — `RodOrderAllocation`

| `RodAlpha` | `OrderNo` | `OrderSeqNo` | `RodSeqNoInOrder` | `AllocatedWeightLb` | `RodWeightFrom` | `RodWeightTo` | `PinRole` | `RodKind` | `Source` |
|---|---|---:|---:|---:|---:|---:|---|---|---|
| R00001 | 00421 | 1 | 1 | 4000.00 | 0.00 | 4000.00 | `Sole` | `Full` | `Planned` |

`CK_RodOrderAllocation_WeightRange` holds: `4000 − 0 = 4000` ✓. One row, so the rod's ranges tile it
trivially (`ORD009`).

### FL1 trace

One check-in → `RodCheckin` #1 → `RUN-0001`. The rod runs to exhaustion at **49,450 ft**; no weld,
because there is no second rod.

### FL1 output — three spools

| Spool | `SegmentWeightLb` | `ChildAlpha` | mint call | `SeqNo` | spool-local ft | `WeldEventId` |
|---|---:|---|---|---:|---|---|
| `SP-00001` | 1,800.00 | **`R00001A`** | `GenerateCoilAlpha('R00001','')` | 1 | 0 → 22,250 | — |
| `SP-00002` | 1,800.00 | **`R00001B`** | `…('R00001','R00001A')` | 1 | 0 → 22,250 | — |
| `SP-00003` | **400.00** | **`R00001C`** | `…('R00001','R00001A,R00001B')` | 1 | 0 → 4,950 | — |

One `SpoolTraceability` row each. `SpoolOrder`: one row per spool, `OrderNo = 00421`,
`Source='Derived'`. Segments sum to 4,000 ✓ (`ORD017` at rod checkout).

> **⚠ `SP-00003` is a 400 lb short close, and it is the finding of this scenario.** 400 lb is **below
> the 800 lb customer minimum**, so it yields **no shippable coil**. Graded outside the range ⇒ flagged:
> supervisor override plus production hold, **or** offered under concession — *offer first, remake last*.
> The spool still runs off regardless.
>
> This is exactly what the workbook's `VALIDATE FINAL STOP POSSIBILITY` exists to prevent, and it is
> **the structural argument for welding**: a 4,000 lb rod does not divide into 1,800 lb spools.

### FL2 output

`SP-00001`, 1,800 lb, one segment, LIFO unwind (immaterial — a single segment unwinds the same either
way):

| Coil | `CoilAlpha` | `OrderId` | primary rod | `CoilNo` | net lb | coil-local ft | `CoilTraceability` |
|---|---|---|---|---|---:|---|---:|
| 1 | `FW-00421-C01` | 00421 | R00001 | `…('R00001','R00001A,R00001B,R00001C')` → **`R00001D`** | 900.00 | 0 → 76,300 | **1 row** |
| 2 | `FW-00421-C02` | 00421 | R00001 | same call; `R00001D` now found by the sweep → **`R00001E`** | 900.00 | 0 → 76,300 | **1 row** |

`SP-00002` follows identically → `FW-00421-C03` / `-C04`, `CoilNo` **`R00001F`** / **`R00001G`**.
`SP-00003` (400 lb) yields nothing shippable.

**Two exclusion mechanisms, and the split is the whole design.** `A`, `B`, `C` are excluded by the
**ignore list**, because segment alphas live in `SpoolTraceability` and `FlatWireDB` is outside the
sweep. `D` is excluded for coil 2 by the **sweep itself**, because coil 1 wrote it into
`proddb..coils`. Neither mechanism covers the other's ground.

> ⚠ **The letters are mint-order artifacts.** A tidy *"segments get A–C, coils get D–G"* reading is an
> accident of this trace, not a rule. `ChildAlpha` is **opaque** — never parsed, never rebuilt; `SeqNo`
> carries the ordering.

Skids: `SK-00201` = C01 + C02; `SK-00202` = C03 + C04. Both close.

### Fulfilment — `RodOrderConsumption`

| `ConsumptionId` | `RodCheckinId` | `Station` | `OrderNo` | `ActualRodSeqNo` | `State` | `StartFootageFt` | `EndFootageFt` | `ConsumedWeightLb` | `ClosureReason` |
|---|---:|---|---|---:|---|---:|---:|---:|---|
| `RC-0001` | 1 | `FL1PO` | 00421 | 1 | `Closed` | 0.00 | 49,450.00 | 4000.00 | `Acknowledged` |

| | lb |
|---|---:|
| allocated | 4,000.00 |
| consumed | 4,000.00 |
| **produced** | **3,600.00** — four coils × 900 |
| status | **`Short`** until the 400 lb tail is dispositioned |

### What this shows

- **Consumed ≠ produced, and the order status turns on produced.** 400 lb is consumed and not shipped.
- One rod, one order, no weld ⇒ **one `SpoolTraceability` row per spool** and **one `CoilTraceability`
  row per coil**. This is the simplest shape the system ever sees.
- The tail is not an error condition; it is arithmetic. Welding is how production removes it.

---

## 5. Scenario 2 — one order, one rod, **welded**

### It does not exist inside the order, and that is the answer

A weld joins **two rods**. An order fed by one rod has no second rod, so there is **no internal weld**.
The scenario is closed, not missing. Three things that look like it and are not:

| Looks like an internal weld | What it actually is | Where it belongs |
|---|---|---|
| **The incoming boundary weld** — the previous order's rod welded to `R00001` | Owned by the **rod pair**. The spool spanning it carries two rods and two orders | §9 |
| **The outgoing boundary weld** — `R00001` welded to the next order's rod | Same | §9 |
| **A mid-run coil break at FL2** | **Not a weld.** The stop is removed and a new stop starts **from zero** — weight does not resume from the break point. The leftover incoming material is welded to the next coil **on FL1**; on FL2 it is run off and offered, or scrapped | `SpoolCompletionNotification.md` §5.1 |

### The one weld that *can* sit inside a single-rod order: a remake

A **failed** weld at either boundary. The join did not hold, so the rod stays `Staged` and un-welded,
the line cannot transition through it, and the operator remakes it:

| `WeldEventId` | outgoing | incoming | quality | effect |
|---|---|---|---|---|
| `WLD-001` | R00000 | R00001 | **Fail** | Event written, rods linked, flagged for supervisor. **Rod not marked welded.** No payoff transition |
| `WLD-002` | R00000 | R00001 | **Pass** | Rod marked welded; active rod advances |

**Two records, one physical join.** Both are kept — the failure is a real quality event and hiding it
defeats the record. Whether a superseded attempt appears on the customer certificate, and how output
footage is attributed across two weld boundaries a few feet apart, is **`OI-59`, open**.

If the incoming weld fails and is abandoned rather than remade, the order simply **collapses to
Scenario 1**: a fresh check-in, no join, no shared spool.

### What this shows

- **The weld axis is a property of the rod sequence, not of the order.** Asking "what does a welded
  one-rod order look like" is asking about the *neighbouring* orders.
- A failed weld produces `WeldEvent` rows **without** producing a `SpoolTraceability` segment boundary —
  the material never crossed the join. Any code inferring segments from weld events is wrong.

---

## 6. Scenario 3 — one order, many rods, **no weld**

### Setup

Order `00421`, allocated **8,000 lb**. Rods `R00001` and `R00002`, 4,000 lb each. **The line stops
between them** — rod 1 runs out, is checked out, rod 2 is checked in fresh.

### Plan

| `RodAlpha` | `OrderNo` | `OrderSeqNo` | `RodSeqNoInOrder` | `AllocatedWeightLb` | `RodWeightFrom` → `To` | `PinRole` | `RodKind` |
|---|---|---:|---:|---:|---|---|---|
| R00001 | 00421 | 1 | 1 | 4000.00 | 0.00 → 4000.00 | `Free` | `Full` |
| R00002 | 00421 | 1 | 2 | 4000.00 | 0.00 → 4000.00 | `Free` | `Full` |

Legal sequences = `|freeFull|! = 2! = 2`. **The operator may run either rod first** — client rule 3,
and the validator accepts both (`ORD004` compares tiers, not positions).

### FL1 trace and output

Two check-ins ⇒ **two `RodCheckin` rows and two `FlatWireRun` rows** (`RUN-0001`, `RUN-0002`). Because
nothing joins the rods, **no spool spans a rod**:

| Run | Rod | Spools | Segments |
|---|---|---|---|
| `RUN-0001` | R00001 | `SP-00001` 1,800 · `SP-00002` 1,800 · `SP-00003` **400** | `R00001A` · `R00001B` · `R00001C` |
| `RUN-0002` | R00002 | `SP-00004` 1,800 · `SP-00005` 1,800 · `SP-00006` **400** | `R00002A` · `R00002B` · `R00002C` |

**Six spools, one `SpoolTraceability` row each, two 400 lb short closes — 800 lb stranded.**

### FL2 output

Four full spools → **eight coils** of 900 lb, `FW-00421-C01` … `-C08`, running unbroken across the
spools because `C##` is per **order**. Every coil has exactly **one** `CoilTraceability` row. Four skids.

⚠ **`CoilNo` values are no longer a flat run off the rod.** *Superseded:* *"`R00001D`–`R00001G` from
rod 1's spools, `R00002D`–`R00002G` from rod 2's."* Under segment-rooting each coil is minted off **its
own spool's segment**, so a full spool's two coils take the first two letters off *that segment*:
segment `R00001A` yields `R00001AA` and `R00001AB`, segment `R00001B` yields `R00001BA` and `R00001BB`,
and so on. **The shape, not the specific letters, is the thing to carry away** — which spool holds
which segment is not stated in this example, and the letters must be read off the segment rather than
copied from here.

### Fulfilment

| `ConsumptionId` | `RodCheckinId` | `RunId` | `OrderNo` | `ActualRodSeqNo` | `State` | `ConsumedWeightLb` |
|---|---:|---|---|---:|---|---:|
| `RC-0001` | 1 | `RUN-0001` | 00421 | 1 | `Closed` | 4000.00 |
| `RC-0002` | 2 | `RUN-0002` | 00421 | 2 | `Closed` | 4000.00 |

Both rows carry the **same** `OrderNo` — legal, because `UQ_RodOrderConsumption_Pair` is
`(RodCheckinId, OrderNo, RelLetter)` and the check-ins differ. They are sequential, so
`UX_RodOrderConsumption_Station` (one open pairing per station) is never contended.

Allocated 8,000 · consumed 8,000 · **produced 7,200** · status **`Short`** by the two tails.

### What this shows

- **Two runs, not one.** Everything keyed on `RunId` — `RunReading`, `SpcCheckpoint`, `RunPauseEvent`,
  `CoilOutput`, `FlatWireRunDetail` — is split at the rod boundary. A report joining a coil to "its run"
  gets rod 2's run and knows nothing of rod 1.
- **The tail loss scales with the rod count.** Two rods, two tails, 800 lb. Eleven rods would strand
  4,400 lb. Compare §7, where welding strands 0.
- `SpoolOrder` has one row per spool. No ambiguity anywhere.

---

## 7. Scenario 4 — one order, many rods, **welded** *(the production norm)*

### Setup

Order `00421`, allocated **40,000 lb** — the shipped run. Eleven rods `R00001`…`R00011` at 4,000 lb,
welded rod-to-rod for continuous feed. Dashboard: **11 rods · 23 spools · 45 coils · 40,400 lb ·
91.82 %**.

**Fourteen of the twenty-three spools are single-rod; nine span a weld.** The multi-rod spool is the
normal minority, not an edge case.

> The 40,400 lb is not an error. 40,000 ÷ 1,800 leaves a 400 lb tail; the planner raises the final spool
> to 800 lb rather than emit an unshippable coil. `22 × 1,800 + 800 = 40,400`.

### FL1 — `SP-00003`, the first welded spool, in full

`R00001` is down to its last 400 lb; the *prepare weld* alert fired at 3,000 lb remaining; `R00002` was
pre-checked-in on the idle payoff and joined (`WLD-001`, induction, Pass).

| `SeqNo` | `RodAlpha` | mint call | `ChildAlpha` | `SegmentWeightLb` | spool-local ft | `WeldEventId` |
|---:|---|---|---|---:|---|---|
| 1 | R00001 | `…('R00001','R00001A,R00001B')` | **`R00001C`** | 400.00 | 0 → 4,950 | — |
| 2 | R00002 | `…('R00002','')` — first segment of a new rod | **`R00002A`** | 1,400.00 | 4,950 → 22,250 | `WLD-001` |

`SP-00003` = 1,800.00 lb, **two** `SpoolTraceability` rows, contiguous and half-open ✓.

- **Lead alpha** = `MAX(SeqNo)` = **`R00002A`** — derived in a query, never stored, because `Q45` is
  open on the unwind direction. Used for the **label** and the **shared face**, never as a check-in
  validation: FL2 must accept **any** segment alpha.
- The label renders **`R00001C - R00002A`**, which is the workbook's own FL1 column exactly. The
  unified namespace reproduces the client's string.
- `SpoolOrder`: **one** row (`00421`) — two rods, one order.

⚠ **`SeqNo` and the letters disagree, and both are right.** The two segments are `SeqNo` 1 and 2 while
their letters are `C` and `A`: a welded spool takes the *third* piece of one rod and the *first* of the
next. Anything ordering by letter is wrong.

### FL2 — `SP-00003`, LIFO

The spool unwinds **last-on-first-off**, so `R00002A` comes off first.

| Coil | `CoilAlpha` | lead | part alphas — **each written to `proddb..coils`** | composition | rows |
|---|---|---|---|---|---:|
| 1 | `FW-00421-C05` | `R00002A` | **one.** `GenerateCoilAlpha('R00002A','')` → **`R00002AA`** | 900 lb, all `R00002A` | **1 row** |
| 2 | `FW-00421-C06` | `R00002A` | ⚠ **two, rooted on two different segments.** `GenerateCoilAlpha('R00002A','')` → **`R00002AB`** *(the lead — `R00002AA` is registered, so the sweep moves on)*, **and** `GenerateCoilAlpha('R00001C','')` → **`R00001CA`** | 500 lb `R00002A` + **400 lb `R00001C`** | **2 rows** |

✅ **Both letters are now stated, and the cross-document warning that stood here is WITHDRAWN.**
*Superseded:* *"The `R00001`-rooted letter is deliberately not stated. Across this document's single
40,000 lb run, `R00001` has already spent letters on three segments and on the coils of spools 1 and 2
— so it is **not** the `F` that §2.8's standalone trace would give. Recompute from the ignore list;
never copy a letter between documents."*

**Segment-rooting made the answer local, which is the point.** Under rod-rooting the letter genuinely
depended on everything else that rod had produced, so the two documents had to disagree. Rooted on the
**segment**, `R00001CA` is the *first* child of segment `R00001C` — and `R00001C` is a 400 lb segment
feeding exactly this one coil, so nothing else competes for it. **The same value is correct in both
documents**, and `R00002AB` likewise follows only from `R00002AA` being registered.

⚠ **The general rule still holds** — state the call, and never copy a letter between documents *on the
assumption* that it transfers. It transfers here because the root is local, not because letters travel.

✅ **Coil 1 is unaffected** — one source rod, one part alpha equal to its `CoilNo`, one shared row.

Coil 2's rows — the point of the whole design:

| `RodAlpha` | `SpoolAlpha` | coil-local `FootageFrom` → `To` | lb |
|---|---|---|---:|
| R00002 | `SP-00003` | 0 → 42,400 | 500.00 |
| R00001 | `SP-00003` | 42,400 → 76,300 | 400.00 |

Half-open, contiguous, covering the coil exactly (`TC-617`, `trg_CoilTraceability_NoOverlap`). The
compound display **`R00002AB - R00001CA`** *(was `R00002E ← R00002A + R00001C`)* **renders from these rows;
nothing compound is stored** — and it is now the client workbook's own form, generated rather than built
(`Q88`, narrowed).
The certificate reads both parents — and both supplier heats — from here.

`C05`/`C06` and not `C01`/`C02`: `SP-00001` took `C01`/`C02` and `SP-00002` took `C03`/`C04`. The
sequence is the **order's**, and reaches `C45`.

### ⚠ FIFO and LIFO give the same two coils and put the weld in a different one

| Unwind | Coil 1 | Coil 2 |
|---|---|---|
| **FIFO** — what the workbook *computes* | 400 `R00001C` + 500 `R00002A` | 900 `R00002A` |
| **LIFO** — what the spool *does*, and what we build | 900 `R00002A` | 500 `R00002A` + 400 `R00001C` |

Same coils, same weights — **different traceability rows, different primary rod, different certificate
parentage**. The workbook consumes FIFO and *names* LIFO (an explicit reversal loop over its display
string), so it is no evidence either way. **Build to LIFO** (`OQ-M` / `Q45`, open).

### Fulfilment

Eleven `RodCheckin` rows, **eleven `FlatWireRun` rows**, eleven `RodOrderConsumption` rows — all
`OrderNo = 00421`, `ActualRodSeqNo` 1…11, all `Closed`. Allocated 40,000 · consumed ~44,000 issued ·
produced **40,400**.

Metallic yield `totalOutput / (rodsUsed × rodWeight)` = 40,400 / 44,000 = **91.82 %** — a working
definition for a figure the repository otherwise has none of (`OI-60` / `Q11`).

### What this shows

- **Welding removes the tail loss.** §6 stranded 800 lb over two rods; here 40,400 lb of 44,000 issued
  becomes shippable coil, and no spool closes short except by design.
- A welded spool has **2 segments**, and the coil that spans the join has **2 traceability rows**. Every
  other spool and coil has one. That is the entire structural difference.
- **The weld sits on the rod band, never the coil band.** Coil 1 contains no weld at all; coil 2
  contains it at 42,400 ft coil-local.
- Eleven runs are welded into one continuous material flow. **`RunId` does not delimit material.**

---

## 8. Scenario 5 — many orders, many rods, **no weld**, boundary at a rod boundary

### Setup

Two orders on the station, back to back. **No rod is shared** — the boundary happens to fall where a
rod ends.

| Order | `OrderSeqNo` | Allocated | Rods |
|---|---:|---:|---|
| `00421` | 1 | 8,000 lb | `R00001`, `R00002` |
| `00422` | 2 | 4,000 lb | `R00003` |

### Plan

| `RodAlpha` | `OrderNo` | `OrderSeqNo` | `RodSeqNoInOrder` | `AllocatedWeightLb` | `From` → `To` | `PinRole` | `RodKind` |
|---|---|---:|---:|---:|---|---|---|
| R00001 | 00421 | 1 | 1 | 4000.00 | 0 → 4000 | `Free` | `Full` |
| R00002 | 00421 | 1 | 2 | 4000.00 | 0 → 4000 | `Free` | `Full` |
| R00003 | 00422 | 2 | 1 | 4000.00 | 0 → 4000 | `Sole` | `Full` |

`OrderSeqNo` is contiguous across the station's queue ✓. `UX_RodOrderAllocation_OrderRodSeq` holds ✓.

### FL1 and FL2

Three check-ins, three runs, **nine spools** (three per rod, each rod leaving a 400 lb tail), one
`SpoolTraceability` row per spool, one `SpoolOrder` row per spool. Twelve coils of 900 lb.

**The coil sequence restarts, because it is per order:**

| Order | Coils |
|---|---|
| `00421` | `FW-00421-C01` … `FW-00421-C08` |
| `00422` | `FW-00422-C01` … `FW-00422-C04` |

### The handoff — there isn't one

`R00002`'s pairing closes; the rod is checked out and the **station is released**. Order `00422` opens
on a **fresh check-in**. Consequences, all of them absences:

| | |
|---|---|
| `ORD015` — incoming order must share the running `PassScheduleId` | **Does not bite.** A new check-in re-acknowledges a schedule and re-pushes the tags, so `00422` may have a different gauge, width or edge |
| The atomic close-and-open pair | **Not needed.** The station is genuinely empty between the two |
| `PinnedFirst` / `PinnedLast` | **Absent.** Nothing is shared |
| `FlatWireRun.OrderId` | **Correct.** Each run belongs to exactly one order |

### What this shows

- **This is the case people assume is the hard one, and it is the easy one.** Multiple orders cost
  nothing as long as the boundary coincides with a mount boundary.
- Every mechanism §9 needs — pin roles, the threshold latch, the mid-mount handoff, the shared pass
  schedule — exists **only** to handle a boundary that falls *inside* a rod.
- The 1,200 lb of tails is Scenario 3's problem again, three times over.

---

## 9. Scenario 6 — many orders, many rods, **welded, rod shared across the boundary**

**The full case. Everything above exists to support this one.**

### Setup

| Order | `OrderSeqNo` | Allocated | Rods |
|---|---:|---:|---|
| `00421` | 1 | **9,500 lb** | `R00001` (4,000) · `R00002` (4,000) · `R00003` (**1,500 of 4,000**) |
| `00422` | 2 | **2,500 lb** | `R00003` (**the remaining 2,500**) |

Three rods, 12,000 lb, welded continuously. **`R00003` is split across the boundary.**

### Plan — four rows for three rods

| `RodAlpha` | `OrderNo` | `OrderSeqNo` | `RodSeqNoInOrder` | `AllocatedWeightLb` | `RodWeightFrom` | `RodWeightTo` | `PinRole` | `RodKind` |
|---|---|---:|---:|---:|---:|---:|---|---|
| R00001 | 00421 | 1 | 1 | 4000.00 | 0.00 | 4000.00 | `Free` | `Full` |
| R00002 | 00421 | 1 | 2 | 4000.00 | 0.00 | 4000.00 | `Free` | `Full` |
| R00003 | 00421 | 1 | 3 | 1500.00 | 0.00 | **1500.00** | **`PinnedLast`** | `Full` |
| R00003 | 00422 | 2 | 1 | 2500.00 | **1500.00** | 4000.00 | **`PinnedFirst`** | `Full` |

- **The split point is not a column.** It is the outgoing row's `RodWeightTo`, which *is* the incoming
  row's `RodWeightFrom`. One number, stored once — and the shape survives a rod shared by three orders.
- `CK_RodOrderAllocation_WeightRange` holds on all four ✓. `R00003`'s two ranges tile it with no gap ✓.
- Legal sequences: `00421` = pinnedFirst ∅ ⧺ perm{R00001, R00002} ⧺ pinnedLast{R00003} = **2**;
  `00422` = pinnedFirst{R00003} = **1**. `R00003` **cannot** take a middle position (`ORD005`) and
  **must** be last in `00421` (`ORD006`).

### FL1 trace

Three check-ins, three runs, two welds.

| Event | Detail |
|---|---|
| `RUN-0001` | `R00001` checked in, order `00421`, pass schedule acknowledged, tags pushed |
| `WLD-001` | `R00001` → `R00002`, induction, Pass |
| `RUN-0002` | `R00002`'s check-in |
| `WLD-002` | `R00002` → `R00003`, induction, Pass |
| `RUN-0003` | `R00003`'s check-in — **and this run spans both orders** |

### The handoff — inside one mount, on `RUN-0003`

`R00003` is checked in **once** and stays on the payoff across the boundary. No dismount, no remount,
no second check-in (rule 7).

| Step | State | Written |
|---|---|---|
| Check-in acknowledged | `RC-0003` → **`InProgress`** | `StartFootageFt = 0`; `ThresholdFootageFt = 18,543.75` (1,500 lb at the running gauge, computed **once**, at pairing start) |
| Counter crosses 18,543.75 ft | `RC-0003` → **`ThresholdReached`** | `ThresholdReachedAt`; `LatchedWeightAtThresholdLb = 1500.00` — latched **at the crossing**, never a fresher tick; `NotificationRaisedAt`; hub **`OrderAllocationReached`** |
| *…the line keeps running…* | | **The material does not stop and the rod is not dismounted.** This interval is a real state, and it is where the overrun accumulates |
| Operator marks `00421` complete at 18,700 ft | `RC-0003` → **`Closed`** **and** `RC-0004` → **`InProgress`**, **in one transaction** | See below |

At 18,700 ft:

| Value | | |
|---|---:|---|
| `WeightAtAcknowledgementLb` | **1,512.64** | the second latch — **156.25 ft** after the crossing |
| `OverrunWeightLb` | **+12.64** | computed column; positive = overrun |
| `RC-0004.StartFootageFt` | **18,700.00** | = the outgoing pairing's `EndFootageFt`, so the boundary is **one** footage value, not two |
| `RC-0004.ThresholdFootageFt` | **49,606.25** | 18,700 + 30,906.25 (2,500 lb allocated) |

`UX_RodOrderConsumption_Station` permits exactly **one** open pairing per station — keyed on `Station`
(`FL1PO`), not `LineId`, because FL1 and FL3 share one physical payoff — so the close and the open
**must** be atomic or the index rejects the handover. Same single-connection, single-transaction rule
`[INT §8.0]` sets for check-in.

**The rod exhausts at 49,450 ft, before the 49,606.25 ft threshold.**

| `ConsumptionId` | `OrderNo` | `Start` → `End` ft | `ConsumedWeightLb` | `State` | `ClosureReason` | overrun / shortfall |
|---|---|---|---:|---|---|---:|
| `RC-0001` | 00421 | 0 → 49,450 | 4000.00 | `Closed` | `Acknowledged` | — |
| `RC-0002` | 00421 | 0 → 49,450 | 4000.00 | `Closed` | `Acknowledged` | — |
| `RC-0003` | 00421 | 0 → 18,700 | **1512.64** | `Closed` | `Acknowledged` | **+12.64 overrun** |
| `RC-0004` | 00422 | 18,700 → 49,450 | **2487.36** | `Closed` | **`RodExhausted`** | **−12.64 shortfall** |

> **The overrun on order 1 is exactly the shortfall on order 2 — 12.64 lb, to the pound.** The rod is a
> fixed quantity; every pound the operator runs past the threshold is a pound the next order does not
> get. That is why the two latches exist and why the interval between them is a state rather than a
> timestamp. Where the shortfall goes — top-up rod, or the order stays short — is **`OQ-E`, open**.

### FL1 output — seven spools, and one of them is the problem

| Spool | Composition | lb | `SpoolTraceability` rows | `SpoolOrder` rows |
|---|---|---:|---:|---|
| `SP-00001` | `R00001A` | 1,800 | 1 | `00421` |
| `SP-00002` | `R00001B` | 1,800 | 1 | `00421` |
| `SP-00003` | `R00001C` 400 + `R00002A` 1,400 | 1,800 | **2** *(`WLD-001`)* | `00421` |
| `SP-00004` | `R00002B` | 1,800 | 1 | `00421` |
| `SP-00005` | `R00002C` 800 + `R00003A` 1,000 | 1,800 | **2** *(`WLD-002`)* | `00421` |
| **`SP-00006`** | **`R00003B`** | **1,800** | **1** | **`00421` *and* `00422`** |
| `SP-00007` | `R00003C` | 1,200 | 1 | `00422` — short close |

Rod totals: `R00001` 400+1,800+1,800 = 4,000 ✓ · `R00002` 1,400+1,800+800 = 4,000 ✓ ·
`R00003` 1,000+1,800+1,200 = 4,000 ✓ (`ORD017`).

> ### ⚠ `SP-00006` — one rod, one segment, **two orders**, and nothing records where the boundary is
>
> `R00003`'s allocation to `00421` was 1,500 lb, of which 1,000 went onto `SP-00005`. So `00421`'s
> share of `SP-00006` is the **first 512.64 lb** (1,512.64 − 1,000) and `00422`'s is the remaining
> **1,287.36 lb**. One rod, so **one** `SpoolTraceability` row and **no** weld.
>
> `SpoolOrder` gets **two** rows — and `SpoolOrder` carries `SeqNo` and `PlannedWeightLb` but **no
> positional columns**. It records *that* the spool carries two orders and not *where the boundary is*.
> **FL2 makes one order at a time and must cut there, and cannot compute it.**
>
> The fix is a half-open pair in **pounds** — `SpoolWeightFrom` / `SpoolWeightTo` — matching
> `RodOrderAllocation`'s split rather than `SpoolTraceability`'s footage, because a spool crossing an
> order boundary is the same kind of partition as a rod crossing one. ⚠ **Time-sensitive:** nothing
> writes `SpoolOrder` yet, so today it is two columns in a DDL file. Afterwards it is a migration plus a
> backfill. Gap **`G48`**.

### FL2 — `SP-00006`, and why it yields two sub-minimum coils

LIFO: the material wound on **last** comes off **first**, so `00422`'s 1,287.36 lb unwinds before
`00421`'s 512.64 lb.

`CoilOutput.OrderId` is a scalar `NOT NULL` — **one coil belongs to exactly one order** — so the cut
*must* fall on the boundary:

| Coil | `OrderId` | `CoilAlpha` | lb | verdict |
|---|---|---|---:|---|
| 1 | `00422` | `FW-00422-C01` | 900.00 | ✔ in the 800–900 range |
| 2 | `00422` | `FW-00422-C02` | **387.36** | ✘ **below the 800 lb minimum** |
| 3 | `00421` | `FW-00421-C11` | **512.64** | ✘ **below the 800 lb minimum** |

> **This is the gap made concrete.** A spool wound across an order boundary yields **two unshippable
> coils** unless planning aligns the boundary with a coil cut — and `SpoolOrder` cannot even tell FL2
> where the boundary falls. Two open items meet here: **`G48`** (the missing positional columns) and
> **`OQ-I`** (does the order acknowledgement also close the FL1 spool, or may a spool span the
> boundary?). **Closing the spool at the acknowledgement would remove this failure outright**, at the
> cost of a short spool and a carrier cycle.

The rest of the spools behave as §7: `SP-00001`–`SP-00005` give `00421` ten good coils
(`FW-00421-C01`…`-C10`), with `SP-00003` and `SP-00005` each producing one coil with **two**
`CoilTraceability` rows. `SP-00007` (1,200 lb) gives `00422` one 900 lb coil and a 300 lb remnant.

### Fulfilment

| Order | allocated | consumed | produced (shippable) | status |
|---|---:|---:|---:|---|
| `00421` | 9,500.00 | 9,512.64 | 9,000.00 — ten coils | **`Short`** — 512.64 stranded on `SP-00006` |
| `00422` | 2,500.00 | 2,487.36 | 1,800.00 — two coils | **`Short`** — 387.36 on `SP-00006`, 300.00 on `SP-00007` |
| | | | | **1,200.00 lb stranded in total**, of which **900.00 is `SP-00006`'s** |

Apportionment is **by footage share, not by counting parents**: for each coil,
`share = (FootageTo − FootageFrom) / coil.FootageFt`, applied to `NetWeightLb`. A two-parent coil is
rarely 50/50 — §7's is 500/400.

### What this shows

- **One check-in, one run, two orders.** `FlatWireRun.OrderId` says `00421` for the whole of `RUN-0003`,
  including the 2,487 lb that belongs to `00422`. **Anything reading it as "the order this run
  produced" is wrong here.** Per-order truth is `RodOrderConsumption`; per-output truth is
  `CoilOutput.OrderId`.
- **Both orders run under one pass schedule and the tags are pushed once**, because there is no second
  check-in to push them at. If planning puts two orders with different gauge, width or edge on one rod,
  the boundary **cannot be crossed mounted** — `ORD015` refuses, and the operator must check out and
  re-check-in. `Q70` guarantees a shared *alloy*, which is not the same guarantee. **`OQ-A` / `Q48`,
  `Critical` and open.**
- **`FL1` does not wait for FL2.** Rule 2 is scoped to the rod-fed payoff, so the FL1 queue moves to
  `00422` the moment the operator acknowledges, while FL2 is still cutting `00421`'s spools. Intended.
- The two partitions of `R00003` — its **order** ranges and its **segment** ranges — are independent.
  The order boundary falls at 1,512.64 lb; the segment boundaries fall at 1,000 and 2,800 lb. **Neither
  implies the other, and their intersection is what `SP-00006` exposes.**

---

## 10. Scenario 7 — the same case, with the boundary placed on a coil cut

**Not a new cardinality — the same one as §9, planned differently.** It is here because it is the fix
for §9, and because the difference is one number in the allocation.

Everything is held constant: the same three rods, the same two welds, the same spool fills, the same
operator delay between the threshold and the acknowledgement. **Only the allocation split moves.**

### Setup

| Order | `OrderSeqNo` | Allocated | Rods |
|---|---:|---:|---|
| `00431` | 1 | **9,900 lb** | `R00001` (4,000) · `R00002` (4,000) · `R00003` (**1,900 of 4,000**) |
| `00432` | 2 | **2,100 lb** | `R00003` (**the remaining 2,100**) |

**Why 9,900 and not 9,500.** `R00003`'s first 1,000 lb goes onto `SP-00005`, so an allocation of 1,900
to the outgoing order lands the boundary at `1,900 − 1,000 =` **900 lb into `SP-00006`** — exactly one
coil. That is the whole design of this scenario: *place the boundary at a multiple of the coil weight,
measured from the start of the spool it will fall in.*

### Plan

| `RodAlpha` | `OrderNo` | `OrderSeqNo` | `RodSeqNoInOrder` | `AllocatedWeightLb` | `RodWeightFrom` | `RodWeightTo` | `PinRole` | `RodKind` |
|---|---|---:|---:|---:|---:|---:|---|---|
| R00001 | 00431 | 1 | 1 | 4000.00 | 0.00 | 4000.00 | `Free` | `Full` |
| R00002 | 00431 | 1 | 2 | 4000.00 | 0.00 | 4000.00 | `Free` | `Full` |
| R00003 | 00431 | 1 | 3 | **1900.00** | 0.00 | **1900.00** | `PinnedLast` | `Full` |
| R00003 | 00432 | 2 | 1 | **2100.00** | **1900.00** | 4000.00 | `PinnedFirst` | `Full` |

`CK_RodOrderAllocation_WeightRange` holds on all four ✓; `R00003`'s two ranges tile it ✓. Compare §9 —
the only changed cells are `1500` → `1900` and `2500` → `2100`.

### The handoff — identical mechanics, 400 lb later

| Step | State | Written |
|---|---|---|
| Check-in acknowledged | `RC-0003` → **`InProgress`** | `StartFootageFt = 0`; `ThresholdFootageFt = 23,488.75` (1,900 lb at the running gauge) |
| Counter crosses 23,488.75 ft | `RC-0003` → **`ThresholdReached`** | `LatchedWeightAtThresholdLb = 1900.00`; hub `OrderAllocationReached` |
| Operator marks `00431` complete at **23,645.00 ft** | `RC-0003` → `Closed` **and** `RC-0004` → `InProgress`, in one transaction | `WeightAtAcknowledgementLb = 1912.64`; `OverrunWeightLb = +12.64` |

**The operator delay is the same 156.25 ft as §9, so the overrun is the same 12.64 lb.** That is
deliberate — it holds everything constant except the thing being demonstrated.

| `ConsumptionId` | `OrderNo` | `Start` → `End` ft | `ConsumedWeightLb` | `ClosureReason` | overrun / shortfall |
|---|---|---|---:|---|---:|
| `RC-0003` | 00431 | 0 → 23,645.00 | **1912.64** | `Acknowledged` | **+12.64 overrun** |
| `RC-0004` | 00432 | 23,645.00 → 49,450.00 | **2087.36** | `RodExhausted` | **−12.64 shortfall** |

### FL1 output — the same seven spools

`SP-00001` … `SP-00007` are **identical to §9** — same segments, same weights, the same two welded
spools, the same `ChildAlpha` mints. The rod is consumed the same way; only its *attribution* changed.

| Spool | Composition | lb | `SpoolOrder` rows |
|---|---|---:|---|
| `SP-00001` … `SP-00005` | as §9, incl. `SP-00003` and `SP-00005` welded | 1,800 each | `00431` |
| **`SP-00006`** | **`R00003B`** — one rod, one segment, no weld | **1,800** | **`00431` 912.64 + `00432` 887.36** |
| `SP-00007` | `R00003C` | 1,200 | `00432` — short close |

### FL2 — `SP-00006`, and this time both coils are real

The spool still carries two orders and the cut still has to fall on the boundary, because
`CoilOutput.OrderId` is scalar `NOT NULL`. What changed is **where the boundary is**.

| | Planned | Actual, with the 12.64 lb overrun |
|---|---|---|
| `00431`'s share of the spool | 900.00 lb | **912.64 lb** |
| `00432`'s share | 900.00 lb | **887.36 lb** |

LIFO — last on comes off first, so `00432`'s material leads:

| Coil | `OrderId` | `CoilAlpha` | lb | verdict |
|---|---|---|---:|---|
| 1 | `00432` | `FW-00432-C01` | **887.36** | ✔ inside the 800–900 range |
| 2 | `00431` | `FW-00431-C11` | **912.64** | ⚠ **12.64 lb over the 900 lb maximum** |

### The comparison, which is the point

| `SP-00006` | §9 — boundary at 512.64 lb | §10 — boundary at 912.64 lb |
|---|---|---|
| Coils cut from it | **3** | **2** |
| Shippable | 1 (900 lb) | 1 (887.36 lb) |
| Below the 800 lb minimum | **2** — 387.36 and 512.64 | **0** |
| Over the 900 lb maximum | 0 | 1, by **12.64 lb** |
| **Material at risk** | **900.00 lb** | **12.64 lb** |

> **One number in the allocation — `1500` → `1900` — turns 900 lb of unshippable material into two
> coils.** Nothing physical changed: same rods, same welds, same spools, same operator. The failure in
> §9 is a **planning placement** problem, not a structural one, and this is the rule that avoids it:
>
> > **Place an order boundary at a whole multiple of the coil weight, measured from the start of the
> > spool the boundary will fall in.**
>
> Planning can compute that — the spool fills are known at plan time. It is the same inversion the
> client's own planner already performs when it sizes FL1 spools so that FL2 can always cut valid coils.

### ⚠ The overrun is what stops it being exact — and that is a new question

Aligning the boundary makes the split 900 / 900 **as planned**. It cannot make it 900 / 900 **as run**,
because the material between the threshold crossing and the operator's acknowledgement must be
attributed to one order or the other. Here that is 12.64 lb, and it lands on the coil already sitting
at the customer maximum.

**Three ways to resolve it, none decided:**

| | Behaviour | Cost |
|---|---|---|
| **(a)** | Cut at the order boundary — ship a **912.64 lb** coil, over the stated maximum | Breaks the customer's stated maximum. **There is precedent**: the client's own planner's anti-remainder rule already emits a coil above `stopMax` rather than leave an unshippable tail |
| **(b)** | Cut at 900 lb — 12.64 lb of `00431`'s material ends up inside an `00432` coil | **Breaks order attribution on the certificate.** For a welding-wire customer this is the one option that is not merely untidy |
| **(c)** | Cut at 900 lb and leave the 12.64 lb as a remnant | Cleanest attribution, smallest loss, extra handling |

**Our reading is (c) below some bound and (a) above it**, the bound being the same figure `OQ-C` already
asks for — the overrun at which the system escalates. Recorded as an observation against **`OQ-C`**;
**no new register id is minted here.** `Q47` (planning-side coil weight) is the natural second home,
since it already asks whether the maximum may be exceeded.

### Fulfilment

| Order | allocated | consumed | produced (shippable) | status |
|---|---:|---:|---:|---|
| `00431` | 9,900.00 | 9,912.64 | **9,912.64** — ten 900 lb coils + `C11` | **`Complete`** |
| `00432` | 2,100.00 | 2,087.36 | 1,787.36 — `C01` 887.36 + `C02` 900 | **`Short`** — the 300 lb tail of `SP-00007` |

### What this shows

- **`00431` is the only order in all seven traces that reaches `Complete`.** Every pound consumed
  became coil. That is what boundary alignment buys.
- **The remaining loss is at the *end* of the queue, not at the boundary** — `SP-00007`'s 300 lb tail,
  which is Scenario 1's problem again and is solved by welding the next order's rod in, not by
  allocation.
- The handoff mechanics are **unchanged**: same states, same two latches, same atomic close-and-open,
  same `UX_RodOrderConsumption_Station` contention. Boundary alignment is a **planning input, not a
  different execution path** — nothing in the build branches on it.
- ⚠ **It is only alignable if planning knows the spool fills**, which means knowing where the welds
  fall. On a run where a rod arrives short, or a weld fails and a rod is swapped, the alignment drifts
  and §9's outcome returns. **This is mitigation, not a guarantee** — which is why `OQ-I` (close the
  spool at the acknowledgement) is still the stronger answer, and the two are complementary rather than
  alternatives.

---

## 11. Comparison matrix

| | `FlatWireRun` | `RodCheckin` | `WeldEvent` | Spools | Max segments / spool | Max `SpoolOrder` rows / spool | Coils | Max `CoilTraceability` rows / coil | Stranded |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **§4** 1 order, 1 rod, no weld | 1 | 1 | 0 | 3 | 1 | 1 | 4 | 1 | 400 lb |
| **§5** 1 order, 1 rod, welded | — | — | *(boundary only)* | — | — | — | — | — | — |
| **§6** 1 order, *n* rods, no weld | 2 | 2 | 0 | 6 | 1 | 1 | 8 | 1 | 800 lb |
| **§7** 1 order, *n* rods, welded | 11 | 11 | 10 | 23 | **2** | 1 | 45 | **2** | ~0 |
| **§8** *n* orders, *n* rods, no weld | 3 | 3 | 0 | 9 | 1 | 1 | 12 | 1 | 1,200 lb |
| **§9** *n* orders, *n* rods, welded, shared rod | 3 | 3 | 2 | 7 | **2** | **2** | 14 | **2** | **1,200 lb ✘** |
| **§10** the same, boundary on a coil cut | 3 | 3 | 2 | 7 | **2** | **2** | 13 | **2** | **300 lb** |

Read down the *segments*, *`SpoolOrder`* and *`CoilTraceability`* columns: **every value is 1 until a
weld or a shared rod appears.** Those two facts are the only structural complexity in the chain.

Then read the last two rows against each other. **§9 and §10 are structurally identical — every
column matches except the coil count and the stranded weight.** Same runs, same check-ins, same
welds, same spools, same maximum segments and traceability rows. The 900 lb difference is not a
different mechanism; it is one number in the allocation.

---

## 12. What the traces surface

Findings that come **out of building these**, each already owned by an existing register entry. **No new
ids are minted here.**

| # | Finding | Home |
|---|---|---|
| 1 | **`SpoolOrder` cannot express the order boundary within a spool**, and §9 shows it producing two sub-minimum coils. §10 shows the exposure is **placement-dependent, not structural** — the same spool with the boundary on a coil cut risks 12.64 lb instead of 900 | **`G48`**; the fix is proposed in `RodOrderAllocation.md` §6 |
| 2 | **`FlatWireRun.OrderId` is wrong at a boundary** — §9 makes it concrete on `RUN-0003` | `RodOrderAllocation.md` §5 |
| 3 | **Two footage coordinate systems** — run events are run-cumulative, traceability is coil-local, and the offset is undefined. Visible the moment §7 writes a second coil's rows | **`OI-25`** |
| 4 | **The recorded weld footage and the material boundary are captured at different moments** — the encoder reading is taken when the operator makes the join at the payoff, while the join passes the counter later, after the outgoing rod's remainder has run through. These traces bound segments at the **material** boundary. Nothing states whether the two values are the same | **`OI-25`**, same class |
| 5 | **FIFO vs LIFO changes which coil the weld lands in**, and so the traceability rows, the primary rod and the certificate parentage | **`OQ-M`** / **`Q45`** — build to LIFO |
| 6 | **A rod split across two orders forces both onto one pass schedule**, because there is no second check-in to push tags at | **`OQ-A`** / **`Q48`**, `Critical` |
| 7 | **The overrun on the outgoing order is exactly the shortfall on the incoming one.** Where it goes is undecided | **`OQ-D`**, **`OQ-E`** |
| 8 | **`ORD016` — a coil never spans two spools.** Welding is FL1-only and FL2 check-in is exclusive, so the case `CoilTraceability`'s header justifies itself on cannot happen; the column is right for a different reason (many **rods**, one spool) | `RodOrderAllocation.md` §9.2 `G-1`; **`Q17`** |
| 9 | **A 400 lb tail cannot become a shippable coil.** §4 and §6 strand material that §7 does not — the structural argument for welding | `SpoolCompletionNotification.md` §5 |
| 10 | ⚠ **`PinRole='Sole'` is in the `CHECK` list but in none of §3's four tiers.** `partition(order.rods)` covers `PinnedFirst`, `Free`, `Free`+`Partial` and `PinnedLast`; a `Sole` row (§4, §8) matches nothing and `minTier` is undefined over it. Harmless while a `Sole` order has exactly one rod, but the validator must special-case it | Observation — `RodOrderAllocation.md` §3 |
| 11 | ⚠ **`RodOrderAllocation.md` §2.8 numbers `CoilAlpha` per spool; `[REQ]` and the master spec say `#####` is the order.** §2.1 above | Observation |
| 12 | **A failed weld writes `WeldEvent` rows without creating a segment boundary** — the material never crossed the join. Code inferring segments from weld events is wrong | `WeldEvent.md` §4 |
| 13 | ⚠ **The acknowledgement overrun can push a coil past the customer maximum, and nothing says what to do.** §10 aligns the boundary to a coil cut and still lands 12.64 lb over, because the material run between the crossing and the acknowledgement has to be attributed to one order. Cut at the boundary (over maximum), cut at 900 (breaks order attribution on the certificate), or leave a remnant — undecided | **`OQ-C`** (the overrun bound); **`Q47`** (may the maximum be exceeded) |
| 14 | **Boundary alignment is a planning input, not an execution path.** Nothing in the build branches on whether a boundary falls on a coil cut — §9 and §10 run the identical state machine. So the fix for §9's 900 lb is a **planning rule**, and it degrades silently when a rod arrives short or a weld is remade | Observation — interacts with **`OQ-I`** |

---

## 13. Related

| Document | Why |
|---|---|
| [`RodOrderAllocation.md`](RodOrderAllocation.md) | The design these traces exercise. §2.8 carries the two original scenarios, reproduced here as §4 and §7 |
| [`RodOrderAllocation_WorkedExamples.html`](RodOrderAllocation_WorkedExamples.html) | The client-facing rendering — same seven scenarios, band diagrams, business language |
| [`FL Alphas Plus - Analysis.md`](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) | The shipped run's numbers, the alpha scheme and the three defects not to port |
| `../../10-requirements/screens/SpoolCompletionNotification.md` | The milestone ladder, the stop gate, the next-carrier rule, short close |
| `../../10-requirements/screens/OutputCoilCompletion.md` | Coil identity, weight basis, source traceability, the skid rule |
| `../../10-requirements/screens/WeldEvent.md` | The weld trigger, the Pass/Fail split and the traceability chain |
| `../../10-requirements/BusinessRequirements.md` §5.28 | `FR-541`–`FR-560` / `ORD003`–`ORD017` — **the citable requirements** |
| `../../30-database/DatabaseDesign.md` §6.6 | The lb/ft formula and the density source |
