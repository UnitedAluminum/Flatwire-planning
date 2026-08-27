# Rod ↔ Order Many-to-Many — Design Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 26, 2026 — ⚠ **`GenerateCoilAlpha`'s six-character root is the exclusion sweep's `LIKE` filter, NOT the string the suffix is appended to.** A seven-character input returns a **child** (`R00002A` → `R00002AA`), verified on the live instance; the recorded reason for rejecting segment-rooted alphas — *"returns a sibling of the segment"* — was **false**. The verdict is unchanged and now rests on **collision**: `R00002AA` is also suffix 27 of the rod-rooted sequence. Ceiling corrected **26 → 702** — the mirrored paragraph corrected; `F13` in `[RodOrderAllocation.md §9.1]` carries the measured values. *(previously August 22, 2026)*
**Status:** Proposed — design plan, **not a requirements source and not citable as a requirement**
**Document Type:** Design plan for the rod ↔ order deliverable it specifies
**Sources:** client rules confirmed 22 Aug 2026 · [`FL Alphas Plus.xlsm`](../BaseDocuments/FL%20Alphas%20Plus.xlsm) and its [analysis](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) · [`ClientCall_2026-08-20_SyncPlan.md`](../BaseDocuments/ClientCall_2026-08-20_SyncPlan.md) (`D2`, `D5`–`D9`) · `Q70` (30 Jul) · `Q73` (6 Aug) · `CommonDB.dbo.GenerateCoilAlpha` (read from `ual-database`)

## Context

A rod may be split across several orders and an order may need several rods. **Nothing in the
repository persists that pairing.** It exists only implicitly in the shared planning schema —
`united_db..planning_routings` keyed on `(coil_no, mfg_order_no, seq_no)`, with
`mfg_sales_order_ref`, `routings_orders` and `proddb..wip_coil_orders` hanging off it — and
`[INT §8]` records the flat wire side as *read only*: "the scan resolves its order from here."

Three things make now the moment:

- **The client confirmed the cardinality on 20 Aug 2026** (`D2`): *"Spool to A-rods is one to many.
  In turn, that one A-rod could be on multiple orders as well."* `Q70` settled the rod half on
  30 Jul; `Q73` settled the consumption sequence on 6 Aug.
- **The spool-level siblings were built 22 Aug.** `SpoolTraceability` and `SpoolOrder` landed in
  `FlatWire_DDL_03_Materials.sql`, and `SpoolOrder`'s header leans on the missing table: *"read from
  the shared `planning_routings` rod→order allocation that already resolves a rod's order at
  staging."* The rod-level table is the hole underneath it.
- **Action `A1` from the 20 Aug call is owed before Mon 24 Aug** — a step-by-step walkthrough of the
  multi-order / multi-alpha scenario, because `D8` has a rejected design and no adopted replacement.
  This document is its design counterpart.

**Deliverable: one design document. No DDL is applied and no register is edited.** Everything is
*proposed*, in the sense `[PLC]` uses the word. Proposed identifiers are recorded so a later wave
mints them in one sweep.

---

## Decisions and departures

### Decided while planning

| | Decision |
|---|---|
| **Scope** | Design document only. No DDL applied, no registers edited |
| **Contiguity (rule 2)** | Scoped to **FL1/FL3**. Both share one physical VPS, so the exclusivity key is **`Station`** (`FL1PO`), not `LineId`. FL2's one-order-at-a-time is a separate rule, lived out through `SpoolCheckin.OrderId` |
| **Sequence (rule 5 + `Q73`)** | **Combined, not arbitrated.** `Q73`'s tiers fill in what rule 5 leaves unordered; its *"multi-order last"* is rule 4's *"last rod of the outgoing order"* read from the outgoing side. One four-tier partition |
| **The handoff (rule 7)** | The rod is checked in **once** and stays on the payoff across the boundary. The operator marks order 1 complete and starts order 2 on the same mount — no dismount, no second check-in (§5) |
| **Alpha namespace** | **One namespace.** FL1 segment alphas and FL2 shared coil alphas are both minted by `CommonDB.dbo.GenerateCoilAlpha`, in-flight ones passed in `@CoilNoToIgnore`, so `R00001A` can only ever mean one object (F9) |
| **Coil identity** | **Two identities kept; one renamed.** `CoilAlpha` is **retained** as the locally-minted `NOT NULL` identity and `SharedCoilNo` becomes **`CoilNo`** — a rename only, so `D5` stands, `CoilNo` stays nullable and coil creation is never coupled to a cross-database call. Closes `OQ-N` (§2.4) |
| **The split point** | Held in **pounds**, not feet (§2.5). Feet are derived where the line measures them |
| **Unwind direction** | Build to **LIFO** — a spool unwinds last-on-first-off. `OQ-M` carries the confirmation |
| **The fixed spool list** | **45 carriers, `SP-0001` … `SP-0045`**, in `Spool` — not `SpoolConfiguration`. Closes `Q42`'s format half and `A5` |
| **`R1A`–`R1D`** | Example labels. Four rods; the names say nothing about alpha creation and are used as given |
| **Terminology** | "order", never "sales order". Sole exception: the object name `mfg_sales_order_ref` |

### Departures from the brief, stated outright

Three places the design does **not** do what was asked, each for a reason found while building it.

| Asked for | Delivered | Why |
|---|---|---|
| *"per-pairing allocated weight **and footage**"* | allocated weight, and the split point in **pounds** | Footage is not conserved through drawing and rolling — the same 900 lb is ≈ 11,100 ft at FL1 gauge and ≈ 76,300 ft at FL2 (§2.5, §2.7). A rod-local footage figure cannot be compared with the line's counter without re-deriving through weight, so storing it invites the error it looks like it prevents. Weight is also the client's own unit: their planner has no footage variable at all |
| *"the **footage** split point"* | the same boundary as cumulative pounds; feet derived at run time as `ThresholdFootageFt` | Same reason. The operator still sees and acts on **feet** — the conversion happens once, at pairing start, at the running gauge |
| *"implement [the formula] as a … pluggable function… since the formula is not yet final"* | one interface, **one** implementation, config selecting the *basis* | The formula **is** final — `FR-137` and `[DBD §6.6]` specify it, `FR-332a` bans a wrong variant. What is open is the **dimensional basis** (`OI-45` / `Q10`). Pluggability belongs at the basis, not the arithmetic (§4) |

---

## What the workbook actually contains

`FL Alphas Plus.xlsm` read directly: three sheets (`INPUT`, `FL1`, `FL2`), no hidden sheets, no
defined names, no cell notes, one form-control button, 561 lines of VBA.

**The flow**

1. `GenerateFL1_Optimized` slices `orderWeight` (40,000) into `targetSpoolWeight` (1,800) chunks.
   `VALIDATE FINAL STOP POSSIBILITY` raises a chunk whose `Mod stopMax` remainder falls below
   `stopMin` — which is why the run produces **40,400 lb**: the 400 lb tail becomes 800 rather than
   an unshippable coil.
2. It walks a rod cursor across those spools, minting one alpha per **segment**
   (`currentRod & AlphaLetter(alphaIndex)`, index resetting per rod) and pushing
   `SegmentType(Rod, Alpha, Weight, SpoolID)` onto a global array. **Array order is the sequence.**
3. `GenerateFL2_Optimized` groups segments by `SpoolID`, cuts each spool into stops ≤ `stopMax`
   (raising a stop to absorb a sub-`stopMin` tail), builds each stop from segments **of the same
   spool only**, and emits the parts in **reverse** consumption order.
4. `UpdateDashboard`: 11 rods · 23 spools · 45 stops · 40,400 lb · 91.82 %. **14 of 23 spools are
   single-rod; 9 span a weld** — the multi-rod spool is the normal minority, not an edge case.

**What it does not contain — the load-bearing finding**

| Absent | Evidence |
|---|---|
| **Any order entity** | `Order Weight` is one scalar in `C4`, used in one expression (`remainingOrder = orderWeight`). No order id, no second order, no rod↔order mapping, no per-order allocation, no order sequence, no handoff, no acknowledgement |
| **Footage** | Not one footage variable in 561 lines. Every allocation is in pounds |
| **An operator** | No actual-versus-planned sequence. The array order *is* the sequence, and it is planning's |

**So the worked example is not in the workbook.** It is the client's own and matches the verbal model
on the 20 Aug call. The design derives from the rules plus decided `Q70` / `Q73` / `D2`.

**What it does anchor:** the **unit** (pounds), the **cardinality** (a spool spans rods; a coil never
spans spools), the **sequence semantics**, and a working **metallic yield** definition.

---

## Reuse — what exists and must not be duplicated

| Need | Existing |
|---|---|
| Rod master, alpha unique | `Rod` (`UQ_Rod_Alpha`) |
| **The rod check-in record** the brief asks for | `RodCheckin` — `RunId`, `RodAlpha`, `OrderId`, weights, `MmsId`/`MmsStatus` |
| Planned vs actual sequence pattern | `RodStaging.PlannedSeqno` (snapshot) + `RodSeqno` (actual) |
| Sequence-deviation authorisation | `RodStaging.OutOfSequenceOverride`, `ExpectedRodAlpha`, `OverrideBy`/`At`/`Reason` — PIN never stored |
| Partial-rod carry-forward | `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb` |
| Rod abandoned mid-run | `RodCheckout` **Mode B** |
| **Durable operator prompt** | `FlatWireRun.PromptDueAt` / `PromptPlcStopTs` / `PromptLatchedWeightLb` / `PromptResolvedAt` / `PromptAnswer` + hub events `SpoolCompletionPromptDue`/`Resolved` — `[SIG §5.2]`, the one non-fire-and-forget event |
| Threshold crossing raised server-side | `SpoolWeightMilestone` |
| Half-open ranges | `SpoolTraceability`, `CoilTraceability`, `trg_CoilTraceability_NoOverlap` |
| Order **set** with no FK on the order | `SpoolOrder` (`Derived`/`Planned`, no FK — `D-32`) |
| Genealogy hops | `SpoolTraceability` (rod→spool), `CoilTraceability` (coil→rod/spool) |
| **FL1 segment-alpha → spool mapping** | **`SpoolTraceability`**, built 22 Aug from the client's own `SegmentType`. One column short (§2.3) |
| **lb/ft formula** | `FR-137` + `[DBD §6.6]` |
| Exclusivity as a constraint | `UX_RodStaging_Bay`; `Q17`'s recommendation for the spool equivalent |
| Order rule-code series | `ORD001` / `ORD002` — extended, not replaced |
| ±2 % weight tolerance | `FR-153` |
| The fixed spool list | `Spool` |

### Two corrections to carry into the document

**1 · The fixed spool list is `Spool`, not `SpoolConfiguration`.**
[FlatWireSchema_Lookup.md](MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Lookup.md) is stamped
**6 Aug** and predates `Spool`, created **22 Aug** — so from that document `SpoolConfiguration`
looks right. It is not:

| | `SpoolConfiguration` | `Spool` |
|---|---|---|
| Holds | a **size class** — min/max weight, core Ø, outer Ø | the **physical articles**, one row each |
| Rows | **exactly one** — every spool is one standard size | **45**, `SP-0001` … `SP-0045` |
| Key | `Name` (`15lb`, `30lb`) | `SpoolNo` — the stencilled string, typed and validated, **not a drop-down** (`D4`) |
| Link | ~~`SpoolProcessing.SpoolTypeId`~~ | `SpoolProcessing.SpoolId` |

> ⚠ **Superseded in the cleanest possible way, 23 Aug 2026 (`Q60`): `SpoolConfiguration` was
> merged into `Spool`, so the left-hand column no longer exists.** The argument this table makes —
> that the fixed spool list is the article table and not the size class — was accepted and then taken
> one step further: a one-row size class was not worth a table, so its six `Min/Max` columns and its
> `Name` (as `SizeClass`) now sit on `Spool` itself. `SpoolProcessing.SpoolTypeId` is dropped.

Seed it **in the DDL**, following `PayoffPosition`'s precedent (*"these are fixed physical
positions"*) — sample data is for rows a developer may delete; this is inventory. `Q42`'s remaining
half is where the registry is **mastered**. The format collides visually with `SpoolProcessing.Alpha`'s
`SP-#####` — see **OQ-K**.

*Why this design cares:* the pool is finite and reused, so §6's FL1 rollup must not conflate
`SpoolProcessing.Alpha` (material) with `Spool.SpoolNo` (the article) — the confusion `SpoolQueue.md`
item 1 exists to prevent.

**2 · Three schema documents are stale.** `FlatWireSchema_Lookup.md` documents seven lookup tables
where `01_Lookup.sql` has eight; `_Materials.md` and `_Runs.md` are missing `SpoolTraceability`,
`SpoolOrder` and `SpoolStaging`. All four tables landed 22 Aug and were never written up. Fold into
W4.

---

## `CommonDB.dbo.GenerateCoilAlpha` — analysed

From `ual-database/Databases/CommonDB/Functions/GenerateCoilAlpha.sql`. It matters because
`FlatWire_CompleteCoilOnSkid` calls it to mint `CoilOutput.CoilNo`, and because it mints from
the same namespace the FL1 segment alpha uses.

> ⛔ **SUPERSEDED 26 Aug 2026 by `[N]` — root on the PARENT, pass a BLANK ignore list, register every
> alpha in `proddb..coils`.** FL1 segments root on the **rod** (one trailing letter); FL2 coil parts root
> on the **source segment** (two — `R00001A` → `R00001AA`), rod only where `SourceSegmentAlpha IS NULL`.
> **There is no ignore list anywhere** — registration makes the generator's own sweep find every sibling.
> Authority: [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.4/§2.8. ⚠ **Precondition unbuilt —
> `OI-138`/`G54`: nothing writes an FL1 segment alpha yet, so the FL1 rows are design, not behaviour.**

**What it is.** A **scalar UDF**: `(@CoilNo VARCHAR(9), @CoilNoToIgnore VARCHAR(500)) RETURNS VARCHAR(9)`.
Blank input returns **`' '`** — a single space, not `NULL`. It walks `A`…`Z`, then `AA`…`ZZ` — **702
suffixes** (`F4`) — for the first unused suffix.

> ⚠ **Corrected 26 Aug 2026: the six-character root is the sweep FILTER, not the append stem.** This
> read *"it roots on `SUBSTRING(LTRIM(RTRIM(@CoilNo)), 1, 6)` and walks `A`…`Z`, `AA`…`AZ`, `BA`…"*,
> which reads as though the suffix is appended to the root. `@rootCoilNo` is used **only** in the 14
> sweep selects' `LIKE @rootCoilNo + '%'`; the stem is `@CoilNo` **verbatim**
> (`SET @CoilAlpha = LTRIM(RTRIM(@CoilNo)) + CHAR(@AlphaTobeAdded)`). The sole exception is the
> `LEN = 9` branch (`F7`), which is the only case returning a sibling. **`[RodOrderAllocation.md §9.1]`
> `F13` carries the measured values** — notably `GenerateCoilAlpha('R00002A','')` → `R00002AA`, a
> **child**. A reader trusting the old sentence predicts the wrong return value.

**The six-character root is why the rod becomes the legacy master coil.** A rod alpha `R#####` is
*exactly* six characters, so `GenerateCoilAlpha('R00421','')` roots on `R00421` and returns
`R00421A` — the same `SUBSTRING(coil_no,1,6)` grouping `coil_link_master_coil` uses, which is what
makes `D5`'s *"the output coils become children of the rod"* work. It is a fit, not a coincidence to
lean on: **a rod alpha one character longer would silently make two rods share one root.**

**The sweep, and why it takes no locks.** Fourteen `UNION`ed selects over **twelve objects**, all
`LIKE root + '%'`. Through CommonDB's view layer those live in **four databases** — `united_db`,
`SlitterDB`, `wiplogdb`, `proddb`. **The no-locks design is structural, not sloppy:** locking across
four databases from a scalar UDF needs a distributed transaction, and `[ARC §10]` / `[INT §8.0]`
deliberately avoid MSDTC. The race must be closed outside the function — which is what
`@CoilNoToIgnore` and the caller's re-check are for.

⚠ The caller's comment says *"sixteen tables"* — it is **14 selects over 12 objects**, and the figure
appears twice.

**The existing caller handles this well; say so, so nobody simplifies it.**
`FlatWire_CompleteCoilOnSkid` guards the blank/`NULL` return (`THROW 51010`), re-checks the alpha
against `proddb..coils` under `UPDLOCK, HOLDLOCK` **inside** the transaction (`THROW 51011`), and
carries `@expectedSharedCoilNo` so a retry cannot mint a second coil.

### The object map

Seven objects share this job. Only the first is named anywhere in the flat wire artifacts. Verified
exhaustively — no copy exists outside `ual-database`.

| Object | Kind | Resolves to |
|---|---|---|
| **`CommonDB.dbo.GenerateCoilAlpha`** | function, 199 lines | **the real implementation** — what flat wire calls |
| `PlanningDB.dbo.GenerateCoilAlpha` | function, 196 lines | **a second, divergent implementation** (F3) |
| `united_db.dbo.GenerateCoilAlpha` | function, 1 line | → CommonDB |
| `PackingDB.dbo.GenerateCoilAlpha` | function, 1 line | → CommonDB |
| `SlitterDB.dbo.GenerateCoilAlpha` | function, 1 line | → `united_db` → CommonDB (**two hops**) |
| `united_db.dbo.Common_GenerateCoilAlpha` | **procedure** | → `united_db` fn → CommonDB (**three hops**), narrowing the ignore list to 200 (F11) |
| `PlanningDB.dbo.GetCoilAlpha` | **procedure**, batch | loops **PlanningDB's** fn (F10) |

**Consumers:** ~14 stored procedures across five databases (ten of them `SlitterInterface_*`), a
`GenerateCoilAlphaQuery` handler in `ual-api`'s Planning domain, and
`UAL.Common/GlobalFunction/CommonData.cs` in **both** the 2.0 and 4.8 trees of `ual-dot-net`.

`SlitterDB`'s wrapper and `Common_GenerateCoilAlpha` are built under **`SET QUOTED_IDENTIFIER OFF`**
where every other copy uses `ON`.

### Findings

| | Finding |
|---|---|
| **F1** | ⚠ **`coils` does not resolve in CommonDB in the scripted schema.** Every other swept object is a scripted CommonDB view over its home database; `coils` is neither table, view, nor scripted synonym anywhere in `ual-database`. PlanningDB's copy qualifies it as `proddb..coils`, so CommonDB likely relies on an **unscripted** synonym. **A deployment-verification item** — if it does not resolve on the target instance, the one call that mints the shared coil identity throws at run time. Now gates **FL1 as well as Phase 9** |
| **F3** | ⚠ **The two implementations sweep different planning tables.** CommonDB reads the snake_case `planning_*` mirrors in `united_db`; PlanningDB reads its own PascalCase `PlanningMfgSalesOrderRef` / `PlanningCoilMillProcessing` / `PlanningCoilSlitterProcessing`. **Neither covers both** |
| **F4** | **Suffix exhaustion is an infinite loop, not an error.** Past all 702 suffixes the overflow wraps `Z`→`A` and re-tries a taken alpha forever; a UDF cannot `RAISERROR`, so it spins holding a connection. **Not reachable at flat wire volumes**, but real and silent. Segments and coils now share the budget |
| **F5** | **`WITH(NOLOCK)` is on twelve of fourteen reads and absent from `wip_log_view` and `coils`** — the two that matter most. A dirty read on a *uniqueness* check is backwards |
| **F6** | **`CRM_Coils_Weight_Info` filters on `coil_no` but selects `new_coil_alpha`** — the only branch whose filtered and selected columns differ. Worth confirming, not asserting |
| **F7** | **The 9-character branch keys on character position 7**, not on parsing the suffix. It recovers through the outer loop, but the behaviour is positional and fragile |
| **F8** | **It can never be inlined.** A multi-statement body with a table variable and `WHILE` loops is ineligible, so every call runs 14 `LIKE`-scans across four databases. **Must never appear in a set-based query** |
| **F10** | **`GetCoilAlpha` already implements the batch loop FL1 needs — on the wrong side of F3.** It takes `@count`, loops, and accumulates into `@coilNosToIgnore` with `CONCAT_WS`. But line 119 calls `dbo.GenerateCoilAlpha` unqualified *inside PlanningDB*. **Cite it as the reference loop; do not call it** |
| **F11** | **The legacy path narrows the ignore list 500 → 200.** `Common_GenerateCoilAlpha`'s parameter is `VARCHAR(200)`; truncating an *exclusion* list means re-issuing an alpha. Flat wire's own accumulator must respect the 500 ceiling |

### F9 — the finding that set the namespace decision

**The FL1 segment alpha and the FL2 shared coil alpha are the same strings from the same namespace,
minted by mechanisms that cannot see each other.** `GenerateCoilAlpha('R00001','')` returns
`R00001A`, and **`FlatWireDB` is not one of the twelve swept objects** — so a local counter would
hand the same string to a spool segment and to a finished coil.

Nothing breaks in the database; the collision is **semantic**, and lands on exactly the artefacts
that must not be ambiguous. `R00001A` would mean *"the first spool segment of rod R00001"* in the
genealogy and *"a finished coil off rod R00001"* in the shared tree, with the welding-wire
certificate reading through both.

| Option | Assessment |
|---|---|
| **Mint FL1 segments through `CommonDB.dbo.GenerateCoilAlpha`** | ✅ **Chosen.** One namespace, no collision possible, and *correct* in the legacy model — both really are children of rod `R00001`. `GetCoilAlpha` is the reference loop (F10); respect the 500-char ceiling (F11) |
| Give FL1 segments a distinct suffix space | Cheap and local, but abandons the client's grammar, confirmed 22 Aug |
| Add `FlatWireDB` to the sweep | **Rejected.** Reaches five wrappers, ~14 procedures, an `ual-api` handler and two `ual-dot-net` trees — the blast radius `D-32` exists to prevent |

---

## Document to create

**`LatestDocument/RodOrderAllocation.md`** — a third file in a folder `CLAUDE.md` describes as holding
*"only the master spec and `ProjectPlanPrompt.md`"*. It sits beside `FlatWire_MasterSpecification.md`,
whose `OI-##` register §9 would feed, and stays out of `MVP-1/` and `MVP-2/` because the rod ↔ order
boundary spans both. Header block per convention, shortcode-free, **no `## Change Log` section** — a
new section goes in root `CHANGELOG.md`.

**`CLAUDE.md` is corrected in the same commit.** Its `MVP-1/` row makes an exhaustive claim this file
falsifies. One sentence, and it must ship with the change that causes it: `CLAUDE.md` is where a
reader is told to start.

> **The column tables below are the inventory; the document carries executable DDL.** The brief asks
> for *"DDL with keys and indexes"*, so §2.1 and §2.2 render as real `CREATE TABLE` blocks in the
> repo's style — `IF NOT EXISTS` guarded with a `PRINT`, named inline `CONSTRAINT`s, a one-line `--`
> rationale per column, **FKs in a `06`-style block and indexes in a `07`-style block**. It must parse
> under `sqlcmd`; see *Verification*.

### §1 What the workbook shows, and what it does not

The four-step flow, the shipped numbers, and the three absences. The example's rod labels are used as
given and not analysed.

### §2 Data model

**Two tables, not one:** the plan is re-planned and the actual is immutable. One table means either
mutating history or carrying two nullable halves.

#### §2.1 `RodOrderAllocation` — the plan *(would sit in `03_Materials`, beside `SpoolOrder`)*

| Column | Type | Rationale |
|---|---|---|
| `Id` | INT IDENTITY | surrogate PK |
| `RodAlpha` | VARCHAR(20) NOT NULL | FK → `Rod.Alpha`; the left side |
| `OrderNo` | VARCHAR(50) NOT NULL | **No FK** — `D-32` forbids altering the shared schema; the basis `SpoolOrder.OrderNo`, `PlanId` and `SkidId` already use |
| `RelLetter` | VARCHAR(10) NULL | mirrors `SpoolOrder.RelLetter` |
| `OrderSeqNo` | SMALLINT NOT NULL | this order's position in the station's queue. **What makes contiguity and "which boundary" computable** — a shared rod's two rows differ by 1 here |
| `RodSeqNoInOrder` | SMALLINT NOT NULL | planning's rod sequence *within* the order |
| `AllocatedWeightLb` | DECIMAL(8,2) NOT NULL | pounds of this rod allocated to this order — planning's number, never derived |
| `RodWeightFrom` | DECIMAL(8,2) NOT NULL | rod-local cumulative pounds, **inclusive** |
| `RodWeightTo` | DECIMAL(8,2) NOT NULL | rod-local cumulative pounds, **exclusive**. Half-open `[From,To)`. **The split point is the outgoing row's `To` = the incoming row's `From`** — no separate split column, and three orders on one rod need no schema change |
| `PinRole` | VARCHAR(12) NOT NULL | `Sole` \| `PinnedFirst` \| `Free` \| `PinnedLast` \| `PinnedBoth`. **Stored, not derived** — the validator reads it on every scan and deriving it needs a self-join |
| `RodKind` | VARCHAR(10) NOT NULL | `Full` \| `Partial` — `Q73`'s tier-2 discriminator |
| `Source` | VARCHAR(15) NOT NULL | `Planned` \| `Derived` \| `Substituted` |
| `SupersededByAllocationId` | INT NULL | re-planning is **additive**; the old row is superseded, never updated |
| `IsActive` | BIT NOT NULL DEFAULT 1 | the filtered indexes key on it |
| `CreatedBy` / `CreatedAt` | | audit |

Constraints and indexes:

- `UX_RodOrderAllocation_Active UNIQUE (RodAlpha, OrderNo, RelLetter) WHERE IsActive = 1` — a
  **filtered** unique index, *not* `SpoolOrder`'s `ISNULL`-into-the-key trick: here treat-NULLs-as-equal
  is what we want, because two rows with a NULL `RelLetter` for one rod and order **are** the same
  pairing. State the difference or it gets "fixed".
- `UX_RodOrderAllocation_OrderRodSeq UNIQUE (OrderNo, RelLetter, RodSeqNoInOrder) WHERE IsActive = 1`
- `CK_..._WeightRange` — `From < To` **and `To − From = AllocatedWeightLb`**. ⚠ **Holding the split in
  pounds makes this enforceable where the footage version was not**: a single-row check on exact
  `DECIMAL` arithmetic, so range and allocation cannot disagree.
- `CK_..._Weight` (`> 0`), `CK_..._PinRole`, `CK_..._RodKind`, `CK_..._Source`, `CK_..._Seq`
- `IX_..._RodAlpha`; `IX_..._Order (OrderNo, RelLetter) INCLUDE (RodAlpha, RodSeqNoInOrder, PinRole, RodKind, AllocatedWeightLb)`; `IX_..._OrderSeq`

**Domain invariants — cross-row, so no `CHECK` can express them.** SQL Server has no exclusion
constraint. A trigger is now *viable* (both weight columns are `NOT NULL`), with
`trg_CoilTraceability_NoOverlap` as precedent; whether to use one is a separate call.

| Invariant |
|---|
| A rod's active ranges **tile the rod** with no gap and no overlap |
| A `PinnedBoth` row is its order's **only** row |
| An order with any allocation has **≥ 1** rod |
| `OrderSeqNo` is **contiguous** across a station's queue |

#### §2.2 `RodOrderConsumption` — the actual *(would sit in `04_Runs`)*

One row per pairing actually run; created when the pairing starts, never updated after `Closed`.

| Column | Type | Rationale |
|---|---|---|
| `ConsumptionId` | VARCHAR(20) NOT NULL UQ | human key, as `CheckoutId` / `RejectionId` / `CheckpointId` |
| `RunId` | VARCHAR(20) NOT NULL | FK → `FlatWireRun.RunId` |
| `RodCheckinId` | INT NOT NULL | FK → `RodCheckin.Id`. **One check-in, N consumption rows — that cardinality *is* rule 7** |
| `Station` | VARCHAR(10) NOT NULL | `FL1PO`. **The exclusivity key** — not `LineId`, because FL1 and FL3 share one VPS. The correction `G21` forced on `RodStaging` |
| `LineId` | VARCHAR(5) NOT NULL | projection and reporting only, as `RodStaging` retains it |
| `RodAlpha`, `OrderNo`, `RelLetter` | | the pairing |
| `AllocationId` | INT NULL | FK → `RodOrderAllocation.Id`; NULL for a substitution made before the allocation exists |
| `AllocatedWeightLbSnapshot` | DECIMAL(8,2) NULL | **snapshot, not a join** — the `RodStaging.PlannedSeqno` / `CoilOutput.PassScheduleSnapshot` pattern. Re-planning must not retro-change what the floor was told |
| `PlannedRodSeqNoSnapshot` | SMALLINT NULL | ditto |
| `ActualRodSeqNo` | SMALLINT NOT NULL | the actual position this rod took in this order |
| `State` | VARCHAR(20) NOT NULL | see §5 |
| `StartFootageFt` | DECIMAL(10,2) NOT NULL | **run-cumulative** anchor, captured live from the counter |
| `EndFootageFt` | DECIMAL(10,2) NULL | |
| `ConsumedFootageFt` | AS (`End` − `Start`) | the only footage arithmetic in the table |
| `ThresholdFootageFt` | DECIMAL(10,2) NULL | computed **once** at pairing start: remaining allocated weight → feet at the running gauge, plus `StartFootageFt`. Stored so it cannot move when the converter's basis changes |
| `ThresholdReachedAt` | DATETIMEOFFSET NULL | the crossing instant |
| `LatchedWeightAtThresholdLb` | DECIMAL(8,2) NULL | **latched at the crossing, never a fresher tick** — `PromptLatchedWeightLb`'s rule verbatim |
| `NotificationRaisedAt` | DATETIMEOFFSET NULL | |
| `AcknowledgedAt` / `AcknowledgedBy` | | rule 9: the operator closes the order |
| `WeightAtAcknowledgementLb` | DECIMAL(8,2) NULL | **the second latch. Two latches, not one** |
| `OverrunWeightLb` | AS (ack − threshold) **PERSISTED** | the variance the brief says must not be discarded. Negative = early ack |
| `VarianceVsAllocationLb` | AS (ack − snapshot) **PERSISTED** | the other variance anyone will ask for |
| `ConsumedWeightLb` | DECIMAL(8,2) NULL | written at close, **not computed** — the basis may be integration over `RunReading` |
| `ConversionBasis` | VARCHAR(20) NULL | `Nominal` \| `Measured` \| `IntegratedRunReading` \| `Override` — `OI-45` |
| `LbPerFtUsed` | DECIMAL(10,6) NULL | **the answer to "the formula changes after records exist"** — a row states its own factor and is never recomputed |
| `ConverterVersion` | VARCHAR(20) NULL | for a change of formula *shape* |
| `ClosureReason` | VARCHAR(25) NULL | `Acknowledged` \| `AcknowledgedEarly` \| `RodExhausted` \| `RodAbandoned` \| `Superseded` |
| `RodCheckoutId` | VARCHAR(20) NULL | FK → `RodCheckout.CheckoutId` on `RodAbandoned`. **Reuse Mode B** |
| `ShortfallWeightLb` | DECIMAL(8,2) NULL | set when material ran out below allocation |
| `OperatorId`, `CreatedAt`, `ModifiedBy`/`At`, `RowVersion` | | `RowVersion` because `State` and footage move live |

Constraints:

- **`UX_RodOrderConsumption_Station UNIQUE (Station) WHERE State IN ('InProgress','ThresholdReached')`**
  — rule 2 as a *constraint*, not only a `409`. The single most important line in the DDL, and the
  shape `UX_RodStaging_Bay` uses and `Q17` asks for on the spool side. ⚠ The predicate must be a
  literal `IN` list: SQL Server forbids a computed column in a filtered-index predicate, so an
  `IsOpen BIT` convenience column cannot be used.
- `UX_..._ActualSeq UNIQUE (OrderNo, RelLetter, ActualRodSeqNo)`
- `UQ_..._Pairing UNIQUE (RodCheckinId, OrderNo, RelLetter)` — one mount, one pairing per order
- `CK_..._AckStamps` — the three ack columns all set or all NULL, written with **explicit `IS NULL`
  pairs**: `A IS NOT NULL AND B IS NOT NULL` evaluates to UNKNOWN when one side is NULL and a `CHECK`
  **accepts** UNKNOWN. That is the trap `CK_AlloyProperty_RodDiaTol` was fixed for.
- `CK_..._Abandon` — `ClosureReason = 'RodAbandoned'` ⇒ `RodCheckoutId IS NOT NULL`
- `CK_..._State`, `CK_..._ClosureReason`, `CK_..._Footage`, `CK_..._LineId IN ('FL1','FL3')`

#### §2.3 The FL1 segment alpha

**The client's structure**, adopted for FL1 output:

```vba
Public Type SegmentType
    Rod     As String     ' "R00001"  — the parent rod
    Alpha   As String     ' "R00001C" — this segment's own identity
    Weight  As Double     ' 400       — pounds THIS rod put on THIS spool
    SpoolID As Long       ' 3         — which spool
End Type
```

**A segment is the intersection of one rod and one spool** — the associative row of a Rod ↔ Spool
many-to-many, one-to-many in *both* directions:

| # | `Rod` | `Alpha` | `Weight` | `SpoolID` |
|---|---|---|---|---|
| 1 | R00001 | `R00001A` | 1800 | 1 |
| 2 | R00001 | `R00001B` | 1800 | 2 |
| 3 | R00001 | `R00001C` | **400** | 3 |
| 4 | R00002 | `R00002A` | **1400** | 3 |

One rod spans three spools (1,800 + 1,800 + 400 = 4,000 ✓); one spool spans two rods
(400 + 1,400 = 1,800 ✓). **Array position is the sequence** — there is no sequence field, and an array
index does not survive into a table, which is why `SpoolTraceability` needed `SeqNo`.

**`SpoolTraceability` holds three of the four fields.**

| `SegmentType` | `SpoolTraceability` |
|---|---|
| `SpoolID` | `SpoolAlpha` — FK → `SpoolProcessing.Alpha` |
| `Rod` | `RodAlpha` |
| `Weight` | `SegmentWeightLb` |
| *(array position)* | `SeqNo`, `UQ (SpoolAlpha, SeqNo)` |
| **`Alpha`** | ⚠ **nothing today** — the owed `ChildAlpha` |

**The column was left out on purpose. Its holding comment now instructs the reader wrongly and must
be replaced, not annotated** — it is the only place the reasoning lives:

> *Superseded:* "`ChildAlpha` is deliberately **ABSENT**… **Until cardinality is decided the column
> would be a guess.** Do not add it speculatively."

```sql
-- ChildAlpha -- ONE ALPHA PER SEGMENT. Cardinality decided 22 Aug 2026,
-- which is what the superseded comment here was waiting for.
--
-- It names the SEGMENT (R00001C), not the spool (SP-00021). That is a
-- CARDINALITY difference and not a naming one: one alpha per segment
-- against one per spool, so it can never be SpoolProcessing.Alpha and the two must
-- not be conflated. SpoolProcessing.Alpha stays the spool MATERIAL identity.
--
-- *** SUPERSEDED 26 Aug 2026 ([N]): roots on the PARENT with a BLANK list.
-- Segments root on the rod, coil parts on SourceSegmentAlpha. No ignore
-- list anywhere -- every alpha is registered in proddb..coils and the
-- sweep finds siblings unaided. See RodOrderAllocation.md 2.4/2.8. The
-- superseded text follows. ***
-- MINTED BY CommonDB.dbo.GenerateCoilAlpha(rodAlpha, @ignoreList), NOT by
-- a local per-rod counter. FL1 segment alphas and FL2 shared coil alphas
-- are the same strings off the same six-character root, and that function
-- cannot see FlatWireDB -- so a local counter would hand the same
-- R00001A to a spool segment and to a finished coil. One namespace makes
-- that impossible. @ignoreList carries EVERY alpha already recorded for
-- this rod in SpoolTraceability, not just this transaction's: the sweep
-- covers the shared schema and finds those unaided, but FlatWireDB is
-- outside it. Cap 500 chars. The function takes no locks (twelve objects
-- across four databases, so it cannot).
--
-- OPAQUE. Never parse it and never rebuild it. R00001A + 'A' and
-- R00001 + AlphaLetter(27) both render R00001AA, so the string does not
-- decompose. There is deliberately NO stored letter index: the function
-- may skip a suffix already taken by a coil, so an index would drift
-- from the letter it claims to explain. SeqNo carries the ordering.
```

The column is `VARCHAR(20)` with `UNIQUE`. Applying this is W4's.

> ⚠ **Three letter counters exist and only the first belongs to `SegmentType`. None derives from
> another.**
>
> | Counter | Scope | Produces |
> |---|---|---|
> | `alphaIndex` *(the workbook's; **not** stored)* | per **rod** | the segment alpha, `R00001C` |
> | **`SeqNo`** *(ours)* | per **spool** | the order material went on |
> | `stopAlphaCounter` | per **spool, per stop** | the FL2 stop suffix, `R00001CA` |
>
> On spool 3 the two segments are `SeqNo` 1 and 2 while their letters are `C` and `A` — a welded
> spool takes the *third* piece of one rod and the *first* of the next. The third counter is FL2's
> and the analysis flags it as **not a unique key**: every part within one stop gets the same letter,
> which is why `R00004AB` exists with no `R00004AA`.

**Five consequences of minting through the shared function.**

| | Consequence |
|---|---|
| 1 | ⛔ **WITHDRAWN 26 Aug 2026 — there is no ignore list.** Every mint passes `''`; registration in `proddb..coils` replaces exclusion (`[N]`). *Superseded:* **The ignore list is every prior segment alpha for that rod**, read from `SpoolTraceability` — not just this transaction's. `FlatWireDB` is outside the sweep, so a second spool off the same rod would otherwise be handed the same alpha (§2.7 Scenario A). `GetCoilAlpha` builds its used-list this way (F10); stay inside `VARCHAR(500)` (F11) |
| 2 | **Replicate the caller's two guards** — the `' '` blank return (`THROW 51010`) and the `UPDLOCK, HOLDLOCK` re-check (`THROW 51011`) |
| 3 | **FL1 spool completion becomes a cross-database caller.** Same instance, local transaction manager, no MSDTC — but **it can no longer be tested on LocalDB**, which has no `CommonDB`. `CLAUDE.md` carries that warning for check-in; it now applies here |
| 4 | **F1 escalates** — the unresolved `coils` reference now gates FL1 as well as Phase 9 |
| 5 | **F4's 702-suffix budget is shared** between segments and coils off one rod. Nowhere near the limit at ~3 + ~6 per rod, but no longer independent |

**What `SegmentType` does not carry**, and therefore what the surrounding tables supply: no order, no
footage, no weld reference, no dates, no operator, no spool alpha.

**This does not conflict with `D8`.** `D8` rejected *pre-generating* alphas and was about **FL2 output
coils**. An FL1 segment alpha minted at the **spool-completion transaction** (`D5`) *is* created on an
actual transaction. The two rules name different objects.

#### §2.4 The welded spool, and what FL2 creates from it

Spool 3 carries `R00001C` (400 lb) and `R00002A` (1,400 lb). **Nine of twenty-three spools look like
this.**

**No new alpha is minted for the spool.** Three identities already exist:

| Purpose | Identity |
|---|---|
| The spool as **local material** | `SpoolProcessing.Alpha` = `SP-#####` |
| The spool's **shared-schema face** — what FL2 scans | **the lead segment alpha** (`R00002A`), per the `OI-115` narrowing, 20 Aug |
| Full **parentage** | `SpoolTraceability`, one row per segment |

**Why not mint a spool-level alpha off a primary rod.** With the namespace unified,
`GenerateCoilAlpha('R00002', …)` returns `R00002B` — **a sibling of its own child.** `R00002A` would
be a segment *on* the spool and `R00002B` the spool *containing* it, both children of root `R00002` at
the same level of the legacy tree. Not avoidable by care; it is what one namespace guarantees. **Do
not mint a container's identifier from its contents' namespace.**

**The precedent is `D6`**, which faces the same problem one hop later and writes **one primary
parent** to `coil_gen_history` while the full chain stays in `CoilTraceability`, calling it *"a real
loss of fidelity"* and accepting it. **Shared schema takes one; the local table keeps all.**

**The lead-alpha derivation:**

```sql
-- Derived, never stored. SpoolTraceability's header says so:
-- "under last-on-first-off MAX(SeqNo) is the lead alpha at FL2 -- but
-- Q45 is open, so derive that in a query, never as a constraint."
SELECT TOP (1) st.ChildAlpha, st.RodAlpha, st.SegmentWeightLb
FROM   dbo.SpoolTraceability AS st
WHERE  st.SpoolAlpha = @spoolAlpha
ORDER  BY st.SeqNo DESC;
```

**Why last-on rather than heaviest.** It agrees with `D7` and the workbook's LIFO display order — and
decisively, **heaviest is not deterministic and last-on always is.** In the nine welded spools the two
rules **disagree on four** (7, 9, 16, 18) and **spool 23 is an exact tie at 400/400** — the last spool
of the run, so not contrived. `UQ (SpoolAlpha, SeqNo)` means last-on can never tie.

**`Q45`'s uncertainty is about unwinding, not winding.** Which segment went on last is a recorded
fact. So use the lead for the **label** and the **shared face**, but **not** as a check-in validation:
FL2 must accept **any** segment alpha and resolve the spool from it — the furnace-plate behaviour
agreed 20 Aug.

**Two guards.** A spool with no `SpoolTraceability` rows has no lead, and SQL cannot express "every
spool has at least one row" — `leadAlpha` must fail loudly rather than return `NULL` into a label. And
**identity narrows to one parent; accounting must not** — cost, yield and certificate weights read the
per-segment rows. Spool 3 is 1,800 lb of which the lead contributes 1,400; attributing all of it to
`R00002` is wrong by 400 lb.

##### What FL2 creates

The workbook gives a stop drawing on two segments a **compound** identity — `R00002AA - R00001CA`.
**That cannot be an identifier here, on three counts:** it is **19 characters** against
`coil_no`'s `char(9)`; its stop letter is shared by every part in the stop so it **is not unique**; and
`CoilOutput.CoilAlpha` is a unique scalar. So the compound string is a **rendering**. Each coil
carries **two** identities and **N** traceability rows:

| What | Value |
|---|---|
| Local, customer-facing | `FW-#####-C##` → `CoilOutput.CoilAlpha` |
| Shared-schema | ⛔ **now `GenerateCoilAlpha(leadSegmentAlpha, '')`** — rooted on the segment, blank list (`[N]`, 26 Aug 2026); rod fallback where `SourceSegmentAlpha IS NULL`. *(Was `GenerateCoilAlpha(primaryRod, @ignoreList)`.)* → `VARCHAR(9)` → **`CoilOutput.CoilNo`** |
| Every parent | one `CoilTraceability` row per (rod, spool, footage range) |

**Primary rod = the rod of the first segment consumed into that coil**, `MIN(FootageFrom)` over its
traceability rows.

##### Coil identity — two kept, one renamed

**`D5` stands.** Its rule — *"Two coil alphas, deliberately, and they are not interchangeable"* — is
**not** reversed. `CoilAlpha` is retained as-is; **`SharedCoilNo` is renamed `CoilNo`**, matching the
column it feeds, `proddb..coils.coil_no`.

| | Before | After |
|---|---|---|
| Local identity, customer-facing | `CoilAlpha VARCHAR(30) NOT NULL` | **unchanged** |
| Shared-schema identity | `SharedCoilNo VARCHAR(9) NULL` | **`CoilNo VARCHAR(9) NULL`** — renamed only |
| Uniqueness | `UQ_CoilOutput_CoilAlpha` + filtered `UX_CoilOutput_SharedCoilNo` | `UQ_CoilOutput_CoilAlpha` + filtered **`UX_CoilOutput_CoilNo`** |
| `CoilTraceability` FK | → `CoilOutput.CoilAlpha` | **unchanged** |

**The evidence against `CoilAlpha` still holds; the consequence is what killed the withdrawal.**
`FW-#####-C##` is not client-specified (`FR-330`'s source reads *"Analysis"*, `FR-509` is
`[PROPOSED]`, every `FW-` in `BaseDocuments/` is a story id) and carries no information `CoilNo`
lacks. But **`CoilNo` is nullable by design** — the value does not exist until the cross-database mint
returns, which is why its index is filtered and why it is the retry contract. As the sole identity it
would force a `CoilOutput` row to wait on `CommonDB.dbo.GenerateCoilAlpha`, turning a reconciliation
problem into a **coil-completion outage** given that function's unresolved `coils` reference (F1).
**Keeping `CoilAlpha` removes the coupling outright** — and beats `OQ-N`'s own fallback of keying
`CoilTraceability` on the `CoilOutput.Id` surrogate, since no FK moves and no surrogate leaks into the
genealogy.

> ⚠ **One cost of the rename.** `SharedCoilNo` was self-documenting about *which* identity it was;
> `CoilNo` beside `CoilAlpha` is not. The compensating argument is that it matches `coils.coil_no`.
> Keep the column's comment block — it is now the only thing that disambiguates them.

**The propagation is a rename, not a redesign:** every `SharedCoilNo` becomes `CoilNo`, including
`UX_CoilOutput_SharedCoilNo` and `FlatWire_CompleteCoilOnSkid`'s `@expectedSharedCoilNo` parameter.
**`FR-330`, `FR-509`, `FR-230`, `BusinessRules.md` §3.3 and `APIs.md`'s `"coilAlpha"` payloads are
untouched.**

> ⚠ **The workbook consumes FIFO and names LIFO — it contradicts itself.**
> `GenerateFL2_Optimized` walks `workingIndex` **ascending**, i.e. winding order, then reverses only
> the *display*. A spool unwinds last-on-first-off — geometry, not policy. **It changes the answer,
> not just the labels:**
>
> | Order | Coil 1 | Coil 2 |
> |---|---|---|
> | **FIFO** (what the workbook computes) | 400 `R00001C` + 500 `R00002A` | 900 `R00002A` |
> | **LIFO** (what the spool does) | 900 `R00002A` | 500 `R00002A` + 400 `R00001C` |
>
> Same coils, same weights — **the weld lands in a different coil**, so traceability rows, primary
> rod and certificate parentage all differ. **Build to LIFO** and treat the workbook's stop
> *composition* as not-to-be-copied, though its stop *sizing* is sound. `OQ-M`.

#### §2.5 Footage frames — two, and the rod's share is in pounds

| Frame | Used by | Anchor to run-cumulative |
|---|---|---|
| **spool-local** | `SpoolTraceability.FootageFrom`/`To` | `SpoolProcessing.RunStartFootageFt` ✅ |
| **run-cumulative** | `RodOrderConsumption.StartFootageFt` / `ThresholdFootageFt`, `FlatWireRun.FootageFt` | — |
| ~~rod-local~~ | — | **withdrawn — the rod's share is `RodWeightFrom`/`To`, in pounds** |

**Why there is no rod-local frame.** `SpoolProcessing.RunStartFootageFt` works because spool-local and
run-cumulative feet measure the same material at the same cross-section — a pure offset. **Rod-local
feet do not:** the rod is round wire at the payoff and the counter measures flat output after drawing
and rolling. Converting is not an offset, it is a re-derivation through weight — §2.7 shows the size
of it, the same 900 lb being ≈ 11,100 ft at FL1 gauge and ≈ 76,300 ft at FL2, the 7× difference
`[DBD §6.6]` records. So the split is held in **pounds** (weight is conserved; footage is not), and
`ThresholdFootageFt` is derived at pairing start. **No anchor column is needed.**

**The two partitions are independent.** A rod's *order* ranges and its *segment* ranges are separate
partitions of the same rod — an order boundary falls where an allocation runs out, a segment boundary
where a spool fills, and neither implies the other. **Their intersection is what §6 joins on**, and it
is why one spool can carry two orders.

#### §2.6 Views

`vw_OrderFulfillment` — per order: allocated, consumed, produced, status.
`vw_OrderRodAttribution` — the per-(order, rod) grain.

#### §2.7 Worked end-to-end examples

Shipped-run numbers: rod 4,000 lb, spool 1,800 lb, coil 800–900 lb, 1100 at FL1 `0.110″ × 0.625″`
(**0.0809 lb/ft**) and FL2 `0.0160″ × 0.625″` (**0.0118 lb/ft**), both from `[DBD §6.6]`; 22,250 ft and
11,100 ft are `TC-167`'s published figures.

##### Scenario A — no weld: one rod, one spool

Rod `R00001`, 4,000 lb, order `O1`. It fills **three** spools — 1,800 lb into spool 1, 1,800 into
spool 2, and its last 400 into spool 3 — so it mints segments `R00001A`, `R00001B`, `R00001C`.
Spool 1 is the one traced here.

> **The trace assumes FL1 has finished the rod before FL2 runs spool 1**, which is the normal case:
> spool 1 goes to anneal while FL1 keeps drawing the same rod. It matters, because the coil alphas
> below depend on which letters the segments have already taken.

| Step | Call | Result |
|---|---|---|
| Spool 1 completes | `GenerateCoilAlpha('R00001','')` — no prior segments | **`R00001A`** |

| `SpoolTraceability` | value |
|---|---|
| `SpoolAlpha` | `SP-00001` *(material — the carrier is `SP-0001`, which is `OQ-K` made concrete)* |
| `ChildAlpha` · `RodAlpha` · `SeqNo` | `R00001A` · `R00001` · `1` |
| `SegmentWeightLb` | **1,800.00** |
| `FootageFrom` → `FootageTo` | `0` → `22,250` *(spool-local, FL1 gauge)* |

| Coil | `CoilAlpha` | Primary | `CoilNo` | Weight | `CoilTraceability` |
|---|---|---|---|---|---|
| 1 | `FW-00001-C01` | `R00001` | `GenerateCoilAlpha('R00001','R00001A,R00001B,R00001C')` → **`R00001D`** | 900.00 | **1 row** |
| 2 | `FW-00001-C02` | `R00001` | `GenerateCoilAlpha('R00001','R00001A,R00001B,R00001C')` → **`R00001E`** | 900.00 | **1 row** |

**Two exclusion mechanisms, and the split is the whole design.** `A`, `B` and `C` are excluded by the
**ignore list**, because segment alphas live in `SpoolTraceability` and `FlatWireDB` is outside the
sweep. `D` is excluded for coil 2 by the **sweep itself**, because coil 1 wrote it into
`proddb..coils`. Neither mechanism covers the other's ground.

> ⚠ **The letters are mint-order artifacts and carry no meaning.** `R00001D` is a coil and
> `R00001C` a segment, but nothing in the strings says so, and the split between them moves with
> whatever was minted first. **This is why `ChildAlpha` is opaque and never parsed, and why `SeqNo`
> carries the ordering** (§2.3). A tidy “segments get A–C, coils get D–E” reading is an accident of
> this trace, not a rule.

##### Scenario B — welded: two rods, one spool

| `SeqNo` | Call | Result | Weight | Spool-local footage |
|---|---|---|---|---|
| 1 | `GenerateCoilAlpha('R00001','R00001A,R00001B')` | **`R00001C`** | 400.00 | `0` → `4,950` |
| 2 | `GenerateCoilAlpha('R00002','')` | **`R00002A`** | 1,400.00 | `4,950` → `22,250` |

Spool `SP-00003`, 1,800.00 lb, **two** rows. Lead = **`R00002A`**. Rendered `R00001C - R00002A`, which
is the workbook's FL1 sheet exactly — **the unified namespace reproduces the client's own column.**

`R00001` is now spent — spool 3 took its last 400 lb. **`R00002` carries on**, filling spool 4
(1,800 lb → `R00002B`) and spool 5 (800 lb → `R00002C`), which is why the coils below start at `D`.

FL2, LIFO:

| Coil | `CoilAlpha` | Primary | `CoilNo` | Composition | `CoilTraceability` |
|---|---|---|---|---|---|
| 1 | `FW-00003-C01` | `R00002A` | `GenerateCoilAlpha('R00002A','')` → **`R00002AA`** | 900 lb, all `R00002A` | **1 row** |
| 2 | `FW-00003-C02` | `R00002A` | ⚠ **two parts, rooted on two different segments.** `GenerateCoilAlpha('R00002A','')` → **`R00002AB`** *(lead — `R00002AA` is registered)*, **and** `GenerateCoilAlpha('R00001C','')` → **`R00001CA`** | 500 lb `R00002A` + **400 lb `R00001C`** | **2 rows** |

> ⚠ **Rewritten 26 Aug 2026 (`[N]`).** *Superseded:* coil 1 `GenerateCoilAlpha('R00002','R00002A,R00002B,R00002C')` → `R00002D`; coil 2 *"same call; `R00002D` now found by the sweep"* → `R00002E`. Both were **rod**-rooted with an accumulating ignore list. Coils now root on their **source segment** with a blank list, so they take a **double** trailing letter and the second part's letter is determinate rather than dependent on everything else that rod produced. The **Primary** column is now the lead **segment**, not the rod.

> ⛔ **SUPERSEDED 26 Aug 2026 — this table shows ONE shared identity per coil, and that is no longer
> the design.** A welded coil now carries **one alpha per source rod** (`Q88`), and **every one of them
> is written to `proddb..coils`** with its own weight from `SegmentWeightLb` (`Q89`). So coil 2 above
> has **two** shared records, not one, and `coil_gen_history` gains **one correctly-parented row each**
> — which is what **closes `OI-113`**.
>
> **This document is the historical plan and is deliberately not rewritten.** The current design is
> [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.5 / §2.8 and the ledger
> [`WeldedCoilAlpha_2026-08-26_SyncPlan.md`](WeldedCoilAlpha_2026-08-26_SyncPlan.md) §1.3 / §1.9.
> **Cite this file for *why* a decision was taken, never for what the design is.**

Coil 2's two rows are the point of the design:

| `RodAlpha` | `SpoolAlpha` | `FootageFrom` → `FootageTo` | Weight |
|---|---|---|---|
| `R00002` | `SP-00003` | `0` → `42,400` | 500.00 |
| `R00001` | `SP-00003` | `42,400` → `76,300` | 400.00 |

Half-open, contiguous, covering the coil exactly (`TC-617`). `R00002C ← R00002A + R00001C` renders
from these rows; **nothing compound is stored.** The certificate reads both parents and both supplier
heats from here.

### §3 Sequence validation

Rule 5 and `Q73` as one four-tier partition:

```
partition(order.rods):
  pinnedFirst  : PinRole ∈ {PinnedFirst, PinnedBoth}    shared with order n−1
  freeFull     : PinRole = Free, RodKind = Full
  freePartial  : PinRole = Free, RodKind = Partial      Q73 tier 2 — a back-to-stock
  pinnedLast   : PinRole ∈ {PinnedLast, PinnedBoth}     shared with order n+1

legal(order) = pinnedFirst ⧺ perm(freeFull) ⧺ perm(freePartial) ⧺ pinnedLast
|legal|      = |freeFull|! × |freePartial|!
```

`PinnedBoth` is in **both** end sets — an order wholly inside one rod has that rod as its only member,
so pinnedFirst and pinnedLast are the same row. **The code must not assume they differ.**

Validation is **positional and O(1) per scan; never enumerate**:

```
validateNext(station, order, candidate, alreadyRun):
    if order.OrderSeqNo ≠ openOrderSeqNo(station)      → reject ORD003
    tier    = tierOf(candidate, order)
    minTier = min tier over order's rods not yet run
    if tier > minTier                                  → reject ORD004
    if tier = PINNED_FIRST and alreadyRun ≠ ∅          → reject ORD005
    if tier = PINNED_LAST  and rods remain after it    → reject ORD006
    accept; ActualRodSeqNo = |alreadyRun| + 1
```

Enumeration exists only for display and tests, capped at `|freeFull| + |freePartial| ≤ 7`.

### §4 Footage-to-weight conversion

```
interface IFootageWeightConverter
    WeightLb   ToWeight (footageFt, ctx)
    FootageFt  ToFootage(weightLb, ctx)     // computes ThresholdFootageFt
    Factor     Describe (ctx)               // LbPerFtUsed + Basis + Version, for persistence

ctx = { Alloy, GaugeIn, WidthIn, EdgeProfile (Square|Round), Basis, RunId?, FootageFrom?, FootageTo? }
```

**The formula is not missing** — `FR-137` and `[DBD §6.6]` specify it, `FR-332a` bans the wrong one:

```
A = t·w                      square edge
A = t·w − 0.2146·t²          round edge   (rectangle with semicircular ends)
k = 12ρ                      ρ from FlatWireDB..Alloys → united_db..alloys.alloy_density
lb/ft = A × k                1100 @ 0.110″×0.625″ → 0.0809 square / 0.0778 round  (TC-167, TC-409)
```

Basis preference: `IntegratedRunReading` (`Σ A(gaugeᵢ,widthᵢ)·k·Δfootageᵢ` — the `[DBD §6.6]`
recommendation, which avoids the ±2.6 % tolerance stack that would trip `FR-153`'s ±2 % on an in-spec
coil) → `Measured` → `Nominal` (the FL2-standalone fallback, since FL2 broadcasts `null`) →
`Override`. Configured under `FlatWire:Conversion`; one DI-registered interface, one implementation.

**Accumulation and granularity.** Running consumption is *not* persisted per tick — `RunReading` is
the time series. `RodOrderConsumption` writes at **transitions only**: anchor at start, latch at
threshold, latch at ack, final at close. **Four writes per pairing.** The crossing is evaluated
**server-side on the footage stream**, the `SpoolWeightMilestone` rule.

> Allocation arrives in **pounds** (planning's unit); the line measures **feet**. The converter bridges
> them at exactly one place. **The stored split point is in pounds** (§2.5); feet appear only where the
> line measures them.

### §5 Handoff state machine

**The mechanic first, because every transition depends on it.** A rod planned for two orders is
checked in **once**. When the first order's allocated weight is reached the operator marks it complete
and **begins the next order on the same rod — no dismount, no remount, no second check-in.**

That fixes three things in the existing schema, each of which reads as a defect without this
paragraph:

| Consequence | Why it follows | What it means |
|---|---|---|
| **One `FlatWireRun` spans both orders** | `FlatWireRun` is *"one row per check-in event"* and `RodCheckin.RunId` is a single `NOT NULL` column — one check-in cannot point at two runs. Reopening at the boundary needs a second `RodCheckin` row, which **is** a second check-in | The boundary is crossed *inside* a run. Everything keyed on `RunId` spans both orders |
| **`FlatWireRun.OrderId` narrows to "the order at check-in"** | It is a scalar, and the run outlives that order | ⚠ **Anything reading it as "the order this run produced" becomes wrong at a boundary.** Per-order truth is on `RodOrderConsumption`; per-output on `CoilOutput.OrderId`. An existing-reader problem, so a **gap** |
| **Both orders run under one pass schedule; tags pushed once** | `PassScheduleId` is also scalar `NOT NULL`, and check-in is when tags are pushed | The incoming order **must** share the running pass schedule, or the boundary cannot be crossed mounted. `Q70` says same alloy, which is not the same guarantee. **OQ-A** |

States: `Pending → InProgress → ThresholdReached → Closed`, plus `Voided`.

| From | To | Trigger | Writes |
|---|---|---|---|
| — | `Pending` | validated scan at pre-check-in or check-in | row insert; `AllocationId`, snapshots, `ActualRodSeqNo` |
| `Pending` | `InProgress` | check-in acknowledged **for the first order**; for later orders on the same rod, **the previous pairing's acknowledgement** — there is no second check-in | `StartFootageFt` (= the outgoing pairing's `EndFootageFt`, so the boundary is one value), `ThresholdFootageFt`; the station index now holds |
| `InProgress` | `ThresholdReached` | **server-side** footage crossing `ThresholdFootageFt` | `ThresholdReachedAt`, `LatchedWeightAtThresholdLb`, `NotificationRaisedAt`; hub `OrderAllocationReached` — durable, idempotent, re-delivered on re-join |
| `InProgress` | `Closed` | operator acks **before** threshold | `ClosureReason='AcknowledgedEarly'`; negative `OverrunWeightLb` |
| either | `Closed` | rod runs out first | `ClosureReason='RodExhausted'`, `ShortfallWeightLb` |
| either | `Closed` | rod removed mid-run | `ClosureReason='RodAbandoned'`, `RodCheckoutId` (Mode B) |
| `ThresholdReached` | `Closed` | **operator marks the order complete** | ack stamps, `WeightAtAcknowledgementLb`, `EndFootageFt`, `ConsumedWeightLb`, `LbPerFtUsed`, `ConversionBasis`, `ConverterVersion`; hub `OrderAllocationResolved`. **The station is handed to the next pairing, not released** — release is at checkout |
| `Pending` | `Voided` | re-planning supersedes before start | `ClosureReason='Superseded'` |

**Between `ThresholdReached` and `Closed` the material keeps running** — the line does not stop and the
rod is not dismounted. That is why the interval is a state value, and it is where the overrun
accumulates.

**Two writes must land in one transaction** or the exclusivity index rejects the handover: the
outgoing `→ Closed` and the incoming `→ InProgress`. The single-connection, single-transaction rule
`[INT §8.0]` already sets for check-in.

Two hub events mirroring `[SIG §5.2]`'s 11/12. ⚠ **The published event count would move 12 → 14**, and
`PP-04` records the count also appears in the master spec and `BusinessRules.md` §3.

### §6 Allocation and fulfilment

- **Input side** (`RodOrderConsumption`) drives the threshold and the notification.
- **Output side** drives fulfilment: at FL1 spool pounds via `SpoolTraceability` × `SpoolOrder`; at
  FL2 coil pounds via `CoilOutput.OrderId` and `CoilTraceability`.

| Order status | Condition |
|---|---|
| `NotStarted` | no consumption row |
| `InProgress` | ≥ 1 row `InProgress` |
| `PendingOperatorConfirmation` | the last pairing is `ThresholdReached` |
| `Complete` | all active allocations closed **and** produced ≥ allocated − `FR-153` tolerance |
| `Short` | all closed **and** produced < allocated − tolerance |

> **"Complete" means two things and the table spans both — say so, or it reads as a contradiction.** An
> order is *consumed* at FL1 and *produced* at FL2, and `Complete` requires both. **FL1 does not
> wait:** rule 2 is scoped to the rod-fed payoff, so the FL1 queue moves to the next order on
> acknowledgement while FL2 is still cutting the previous one's spools. Intended, not a violation.

```
producedByOrderAndRod(order):
    total = {}
    for coil in CoilOutput where OrderId = order and Status = 'COMPLETE':
        for t in CoilTraceability where CoilAlpha = coil.CoilAlpha:
            share = (t.FootageTo - t.FootageFrom) / coil.FootageFt
            total[(order, t.RodAlpha)] += coil.NetWeightLb * share
    return total

fulfilment(order):
    allocated = Σ AllocatedWeightLb over RodOrderAllocation  where OrderNo = order and IsActive = 1
    consumed  = Σ ConsumedWeightLb  over RodOrderConsumption where OrderNo = order and State = 'Closed'
    produced  = Σ producedByOrderAndRod(order)
    return { allocated, consumed, produced,
             yieldOnRun = produced / consumed,
             status     = deriveStatus(order, allocated, produced) }
```

- **Apportion a coil by footage share, not by counting parents** — Scenario B's coil 2 is 500/400.
- **At FL1 the same shape applies one hop earlier**, and it is the only path for a **stock** order
  taken out after FL1 or after anneal, which never reaches FL2 (the three-route set, 20 Aug).

> ⚠ **Gap: the boundary is lost at the spool hop.** `SpoolOrder` carries `SeqNo` and
> `PlannedWeightLb` but **no positional columns**, so a spool wound across an O1→O2 boundary records
> *that* it carries two orders and not *where the boundary is*. FL2 makes one order at a time and must
> cut there. **Fix: `SpoolWeightFrom` / `SpoolWeightTo`, in pounds** (G-6).
>
> ⚠ **And `SpoolOrder`'s stated derivation is now wrong** — its header reads the set from shared
> `planning_routings`, a workaround written **because this document's table did not exist** (G-7).

### §7 Validation rules — `ORD003`+, extending the existing series

| Rule | Trigger | Behaviour |
|---|---|---|
| `ORD003` no order started while another is open at the station | check-in | `409`, backed by `UX_RodOrderConsumption_Station` |
| `ORD004` no rod out of tier order | pre-check-in **and** check-in (`Q73` item 7) | `422`. ⚠ **Hard refusal, not the `Q24` override** — `Q73`: the jumped multi-order rod is *"refused, not overridden"* |
| `ORD005` a shared rod may not take a middle position | both | `422` |
| `ORD006` the pinned-last rod must be last | both | `422` |
| `ORD007` no next-order processing before acknowledgement | check-in | `409`. Structurally guaranteed — the ack *is* the trigger — but kept as a stated rule |
| `ORD008` the selected order must be in the rod's active allocation set | both | `422` — the rod-side mirror of `Q43`'s spool-side check |
| `ORD009` a rod's weight ranges must not overlap and must tile the rod | allocation write | **domain invariant** — cross-row, so no `CHECK` expresses it. A trigger is viable (`NOT NULL` columns), with `trg_CoilTraceability_NoOverlap` as precedent |
| `ORD010` an order with an allocation has ≥ 1 rod | allocation write | domain invariant |
| `ORD011` overrun beyond a configurable bound | footage stream | **warn / escalate, never stop the line** — stopping mid-rod scraps continuous material |
| `ORD012` an unplanned substitution needs supervisor authorisation | check-in | reuse `OverrideBy`/`At`/`Reason`; PIN never stored |
| `ORD013` a superseded allocation may not be consumed against | check-in | `422` |
| `ORD014` a rod already mounted and running may not be checked in again | check-in | `409`. A second scan is a *duplicate*; treating it as a fresh check-in would mint a second `FlatWireRun` and re-push tags mid-material |
| `ORD015` the incoming order must share the running `PassScheduleId` | acknowledgement | `422` — a **refusal to cross mounted**, not of the order: check out and re-check-in, because tags cannot be re-pushed without a check-in |
| `ORD016` **a coil's parents must all come from one spool** | coil completion | `422`. **The sheet's own invariant** — `' RULE: A STOP MAY USE MULTIPLE ALPHAS BUT ONLY FROM THE SAME SPOOL'`, enforced in the VBA by breaking out when `SpoolID` changes. A single `SpoolAlpha` per coil is **correct by design** (G-1) |
| `ORD017` **segment weights must sum to the spool weight, and a rod's to the rod weight** | spool completion / rod checkout | `422` within `FR-153`. Also implied by the sheet, where both hold exactly on all 23 spools. Checked at the **closing** transaction (G-2) |

### §8 Edge cases

| Case | Resolution |
|---|---|
| Shared rod runs short before the outgoing order's weight | outgoing → `Short`, `RodExhausted`, `ShortfallWeightLb`. The incoming order's pinned-first pairing is `Voided` and its next rod becomes first — legal, since pinned-first is optional. Top-up is **OQ-E** |
| Operator acknowledges early | permitted; the ack is authoritative. `AcknowledgedEarly`, negative `OverrunWeightLb`. Where the unconsumed allocation goes is **OQ-D** |
| Operator overruns significantly | captured, not prevented (`ORD011`). No bound exists anywhere — `OI-103` is the precedent. **OQ-C** |
| Order short after all planned rods consumed | `Short`; needs a substitution or planner action |
| Unplanned rod substituted in | `Source='Substituted'` + supervisor override. Touches `Q24` / `Q25` |
| Rod abandoned mid-order | **`RodCheckout` Mode B, already fully modelled.** No new mechanism |
| Re-planning after processing began | allocations superseded, never mutated; consumption rows carry snapshots — the `PassScheduleSnapshot` / `PlannedSeqno` pattern |
| Leftover material returned to stock | `RodCheckout.RodDisposition` + `Rod.RemainingWeightEstimateLb`; `Q73` tier 2 already calls a partial a back-to-stock |
| Rod shared by three or more orders | **no schema change** — the half-open **weight** ranges chain, and the middle order is `PinnedBoth` |
| Conversion formula changes after records exist | `LbPerFtUsed` + `ConversionBasis` + `ConverterVersion` per row. **Historical rows are never recomputed** |

### §9 Open questions

`OQ-A`…`OQ-N` locally; they become `Q48`+ when a register wave runs. A decided item keeps its text
and is never deleted, per the register's rule.

| | Question |
|---|---|
| **OQ-A** | **Can planning put two orders with *different* pass schedules on one rod?** If so that boundary cannot be crossed mounted (`ORD015`) and rule 7 does not hold for it. `Q70` says same alloy; alloy is not gauge, width or edge. **The highest-value question here** |
| **OQ-B** | `Q73` item 6's **no-weld branch** — does multi-order-last hold without a weld? Two readings on the 6 Aug recording, **no `OI-##` mirror** |
| **OQ-C** | The overrun bound for `ORD011` — warn at what, escalate at what, to whom? |
| **OQ-D** | On an early acknowledgement, does the unconsumed allocation roll to the next order or back to stock? |
| **OQ-E** | When a shared rod exhausts before the outgoing order is satisfied, may an unplanned rod top it up? |
| **OQ-F** | Where does the order boundary live at the spool hop? (G-6) |
| **OQ-G** | Is fulfilment **consumed** or **produced** pounds — and which does the certificate state? |
| **OQ-H** | `Q10` / `OI-45` dimensional basis — inherited, and it gates every weight here |
| **OQ-I** | Does the acknowledgement also close the FL1 spool, or may a spool span the boundary? Interacts with `SpoolOrder`, `D5` and the finite carrier pool |
| **OQ-J** | Which rod weight is real — 4,000 / ~5,500 / 8,690–8,840? `OI-97` |
| **OQ-K** | **Should the carrier prefix differ from the material one?** Carriers are `SP-0001`…`SP-0045` (four digits); material spools are `SP-#####` (five). One digit apart on the same prefix, for the two objects `Spool` exists to keep apart. Nothing can mis-resolve in the database; the exposure is a person reading one for the other. `SC-0001` removes it outright. **Build to `SP-0001`…`SP-0045` meanwhile** |
| ~~**OQ-L**~~ | ✅ **Decided 22 Aug 2026 — one namespace, minted through `GenerateCoilAlpha`** (F9) |
| ~~**OQ-N**~~ | ✅ **Decided 22 Aug 2026 — keep `CoilAlpha`, rename `SharedCoilNo` → `CoilNo`.** A `CoilOutput` row must not wait on `CommonDB.dbo.GenerateCoilAlpha`, and need not: `CoilAlpha` stays the locally-minted `NOT NULL` identity, so `CoilNo` stays nullable and the `CoilTraceability` FK does not move. Better than this item's own surrogate-key fallback. `D5` stands |
| **OQ-M** | **Does a spool unwind last-on-first-off?** It decides **which coil the weld lands in**, and so each coil's traceability rows, primary rod and certificate parentage. Geometry says LIFO; the workbook consumes FIFO while naming LIFO, so it is no evidence either way. `Q45` is the same question at the label. **Build to LIFO meanwhile** |

---

## Gap review — recommendations

### G-1 · The sheet's one-spool-per-coil invariant, and a live DDL comment that contradicts it

**Enforce `ORD016`, and correct `CoilTraceability`'s header.** That comment reads:
*"`CoilOutput.SpoolAlpha` would be wrong the moment a spool runs out mid-coil and the next is
mounted."* **A coil cannot span two spools.** Welding is an **FL1** operation — Bob, 20 Aug: *"we're
welding at the FL1 side, but we're cutting and re-going again at the FL2 side"* — and `Q17` fixed FL2
check-in as **exclusive**. With no weld and no second spool there is nothing to join to, which is why
the workbook breaks its loop when `SpoolID` changes.

The conclusion is still right for a **different** reason: `CoilTraceability` needs row granularity for
**rods**, not spools — Scenario B's coil 2 has two rod parents through one spool. Keep the column, fix
the justification. **A wrong rationale on a correct design is what invites a bad "simplification".**
Lands in `FlatWire_DDL_05_QualityOutput.sql` (W4) and a `REVIEW.md` line.

### G-2 · `ORD017` had no enforcement point

**Check at the *closing* transaction, not continuously.** A rod's segments accumulate over days across
several spool completions, so for most of a rod's life the sums legitimately do **not** balance. A
trigger would either pass on an incomplete set — enforcing nothing — or block normal state. Verify at
**spool completion** (segments = spool weight) and **rod checkout** (segments = rod net weight, within
`FR-153`). It catches a mis-split at the transaction that caused it rather than at the certificate.
Lands in the domain model, not the schema.

### G-3 · Allocation and fulfilment logic was absent

**Publish as SQL views, not a service method** — `vw_OrderFulfillment` and `vw_OrderRodAttribution`.
The API, the reports and the certificate all need the same number, and a view is the only form all
three can read; a service method guarantees a second implementation in the report layer.

### G-4 · Metallic yield — do not publish one number

**Define two and name them apart.**

| Figure | Formula | Answers |
|---|---|---|
| **Yield on metal run** | `produced / consumed` | how well the line converted what it ran |
| **Yield on metal issued** | `produced / allocated` — the workbook's `totalOutput / (rodsUsed × rodWeight)` at plant level | how well the *plan* converted what it committed |

They differ by the unconsumed remainder, so either alone is misleading. **Propose to `OI-60` / `Q11`;
do not close them here** — this document is not a requirements source.

### G-5 · DDL was specified as tables

**Render real guarded `CREATE TABLE` blocks in the document; do *not* add them to the numbered runner
in this pass.** *"34 tables · 57 FKs · 69 index statements"* is a published figure cited in 20+ files,
and `W4`'s own note says to plan the move and re-derive **in one sweep**.

### G-6 · The order boundary is lost at the spool hop — and the window is closing

**Add `SpoolWeightFrom` / `SpoolWeightTo` to `SpoolOrder` in the same W4 sweep**, in pounds, half-open,
matching `RodOrderAllocation`'s split. **Time-sensitive:** `SpoolOrder` was created 22 Aug and
**nothing writes it yet**, so today this is two columns in a file. That is exactly the argument `G42`
used to get `SpoolTraceability` built early — *"raise it now, while it is free"* — and once the FL1
writer exists it becomes a migration plus a backfill against certificate data.

### G-7 · `SpoolOrder`'s derivation is documented against a workaround

**Re-point the derivation at `RodOrderAllocation` and rewrite the header together, in W4.** The set is
the union of the orders on the rods in `SpoolTraceability`, resolved **locally**. Worth recording
rather than just doing: it **removes a shared-schema read** from the FL1 path — a `D-32` win — and
removes a re-resolution that could disagree with the local allocation. **Until W4 runs the shared read
is the interim source**, so the two must not both be live.

---

## Files touched

| File | Change |
|---|---|
| `LatestDocument/RodOrderAllocation.md` | **new** — the whole deliverable |
| `CLAUDE.md` | one sentence in the `MVP-1/` row — `LatestDocument/` holds three files, not two |
| `CHANGELOG.md` | new section, per the repo's one-change-log rule |

**Deliberately not touched:** `FlatWire_DDL_*.sql`, `DatabaseDesign.md`, `Schema/FlatWireSchema_*.md`,
`BusinessRequirements.md`, `TaskBreakdown.md`, `TestCases.md`, `APIs.md`, `SignalR.md`,
`FlatWireOpenQuestions.md`, `GapsRegister.md`, the master spec's `OI` register.

Proposed ids recorded **in** the document so a later wave mints them in one sweep: `FR-541`+
(⚠ `FR-533`–`FR-540` reserved by the unexecuted 20 Aug **W3**), `Q48`+, `OI-123`+, **`G47`–`G48`**
(the `SpoolOrder` boundary and the `FlatWireRun.OrderId` narrowing), `FW-225`+ (⚠ `FW-224` reserved by
**A6**), `TC-730`+.

---

## Verification

**The brief supplies its own acceptance test:**

- O1 = {R1A, R1B, R1C}: pinnedFirst ∅, freeFull {R1A, R1B}, pinnedLast {R1C} → `2! × 0! = 2`, exactly
  `R1A→R1B→R1C` and `R1B→R1A→R1C`. ✓
- O2 = {R1C, R1D}: pinnedFirst {R1C}, freeFull {R1D}, pinnedLast ∅ → `1! = 1`, exactly `R1C→R1D`. ✓
- `validateNext(O2, R1D, [])` rejects on `ORD005`; `validateNext(O2, R1C, [])` while O1 is open
  rejects on `ORD003`.

**The handoff check, which is the one that catches a wrong model.** Run O1 to completion on `R1C`,
acknowledge, run O2 on the remainder:

- **one** `RodCheckin` row and **one** `FlatWireRun` — not two of either
- **two** `RodOrderConsumption` rows sharing that `RodCheckinId`, both `Closed`
- O1's `EndFootageFt` **equal to** O2's `StartFootageFt` — one boundary value
- a second scan of `R1C` mid-run rejected by `ORD014`

**The two-partition check.** Take a rod whose order boundary falls *inside* a spool segment:

- the rod's **order** ranges (pounds) and its **segment** ranges must each tile the rod with no gap or
  overlap, and must **not** be required to share a boundary
- the segment spanning the boundary must produce **two** `SpoolOrder` rows
- joining them must attribute every pound of that segment to exactly one order
- every footage figure must name its frame; a cross-frame comparison without an anchor is the defect
  this checks for

**The alpha check.** Mint two spools off one rod in separate transactions, then a coil:

- the second spool must **not** re-issue the first's `ChildAlpha` — the ignore list is read from
  `SpoolTraceability`, not just the transaction (§2.3 consequence 1)
- the coil's `CoilNo` must skip every segment alpha *and* every earlier `CoilNo`
- `ORD016`: all of one coil's `CoilTraceability` rows share one `SpoolAlpha`

Then:

1. **DDL parses** — each block through `sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C` against a throwaway
   database. Parse and constraint validity only; the numbered files and `FlatWireDB` are untouched.
2. **Filtered-index predicate is legal** — `WHERE State IN (...)` is accepted; a *computed* column
   would not be, which is why `IsOpen` was not used.
3. **`GenerateCoilAlpha` resolves on the target instance** — F1. Confirm `coils` resolves inside
   CommonDB before relying on either FL1 or Phase 9.
4. **Arithmetic re-derived by hand:** 22 × 1,800 + 800 = 40,400; 40,400 / 44,000 = 91.82 %; 1100 at
   0.110″ × 0.625″ → 0.0809 lb/ft; 1,800 lb → 22,250 ft; 900 lb → 76,300 ft at FL2 gauge.
5. **Every cited id resolves** — `grep` each `FR-`, `Q`, `OI-`, `G`, `TC-`, `D-`, `ORD`, `PLC-Q` and
   table name against the repo.
6. **Read against `REVIEW.md`'s Tier 1 list** so nothing re-asserts a known contradiction.
