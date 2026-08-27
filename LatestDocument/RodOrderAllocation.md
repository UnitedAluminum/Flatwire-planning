# Rod ↔ Order Allocation, Sequencing and Handoff

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 26, 2026 — ⛔ **ONE RULE FOR EVERY ALPHA: root on the parent, pass a BLANK ignore list, register the result in `proddb..coils`.** FL2 coil parts now root on the **source segment alpha**, not the rod — `('R00001A','')` → `R00001AA`, `R00001AB` — with a rod fallback where `SourceSegmentAlpha IS NULL`. **`@CoilNoToIgnore` leaves the flat wire design entirely**, because the sweep sees every registered sibling; `F10`/`F11`'s accumulator caps go moot with it. §2.8 fully re-traced; §2.4/§2.5 realigned; `F4`, `F12`, `F13`, `F14` updated; **`Q59` closes** conditionally. ⚠ **Two blockers: `OQ-T`** — nothing writes an FL1 segment alpha to `coils` yet, so the FL1 traces are the design and not current behaviour — and **`OQ-S`**, two parts of one coil sharing a segment. ⚠ **§2.8 now LEADS; the worked-examples pair and `AllocationExamplesContent.md` trail, and the client `.xlsx` is stale.** ⚠ **`Q88` is NARROWED, not reversed** — generating the client's form is adopted, building it locally is still rejected; the DDL comments, ledger row (b) and `50_…:483` still disagree and are propagation-scope. *(Earlier that day — ⚠ **`GenerateCoilAlpha`'s six-character root is the exclusion sweep's `LIKE` filter, NOT the string the suffix is appended to.** A seven-character input returns a **child** (`R00002A` → `R00002AA`), verified on the live instance; the recorded reason for rejecting segment-rooted alphas — *"returns a sibling of the segment"* — was **false**. The verdict is unchanged and now rests on **collision**: `R00002AA` is also suffix 27 of the rod-rooted sequence. Ceiling corrected **26 → 702** — §9.1 rewritten and **`F13` minted** with the measured values. ✅ **§2.8's traces were re-verified against the live function and NOT changed** — every call there rooted on a six-character rod alpha. ⚠ **Superseded the same day — FL2 now passes seven-character segment alphas.**)* ⚠ **`F14` minted: the ignore list's ONLY job is `FlatWireDB`-local alphas** — `coils` is swept, so coil-to-coil exclusion needs no list, and **parent-alpha rooting is unavailable in BOTH implementations** (period-3 wrap at depth 3, `VARCHAR(9)`, no `PlanningDB` grant, budget 702 → 78). The shipped procedure passes `''` while every design document says `@ignoreList` — **`OI-136`**. ✅ **All 17 `GenerateCoilAlpha` calls and every numeric example in this document audited against the live function — 16 correct, ONE fixed:** §2.5's spool-level argument hid its ignore list behind a `…`, and read as blank it returns `R00002A`, inverting the paragraph. *(previously August 25, 2026 — §2.8 badged — its `CoilAlpha` values are numbered per spool where `FW-#####` is the **order**; the `CoilNo` mints are unaffected *(previously August 24, 2026)*)*
**Status:** **Design analysis — APPLIED.** The schema it proposed is built and its register ids are minted (see below). It remains **not a requirements source and not citable as a requirement**: the requirements it proposed were propagated into `[REQ]` §5.28 as `FR-541`–`FR-560` carrying rule codes `ORD003`–`ORD017`, and **those** are citable. This document is the rationale, not the requirement — cite it for *why*, the way `[DBD §6.7]` cites the 30 Jul client call.
**Document Type:** Cross-cutting design analysis
**Sources:** client rules confirmed 22 Aug 2026 · [`FL Alphas Plus.xlsm`](../BaseDocuments/FL%20Alphas%20Plus.xlsm) and its [analysis](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) · [`ClientCall_2026-08-20_SyncPlan.md`](../BaseDocuments/ClientCall_2026-08-20_SyncPlan.md) (`D2`, `D5`–`D9`) · `Q70` (30 Jul 2026) · `Q73` (6 Aug 2026) · `CommonDB.dbo.GenerateCoilAlpha`, read from `ual-database`
**Companion:** [`RodOrderAllocation_DesignPlan.md`](RodOrderAllocation_DesignPlan.md) — the plan this document was built to, carrying the verification steps and the record of decisions taken while writing
**Worked examples:** [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) — the six order/rod cardinalities traced end to end at row level, extending §2.8's two scenarios; [`RodOrderAllocation_WorkedExamples.html`](RodOrderAllocation_WorkedExamples.html) is its client-facing rendering

---

## 0. What this is

A rod may be split across several orders and an order may need several rods. **Nothing in the
repository persists that pairing.** It exists only implicitly in the shared planning schema —
`united_db..planning_routings` keyed on `(coil_no, mfg_order_no, seq_no)`, with
`mfg_sales_order_ref`, `routings_orders` and `proddb..wip_coil_orders` hanging off it — and
`[INT §8]` records the flat wire side as *read only*: "the scan resolves its order from here."

⚠ **This paragraph said “No DDL has been applied and no register entry minted”. That was true when written and became false the same day.** The propagation ran on **22 Aug 2026** and its ledger,
[`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md), records **all six waves applied**:

- **Schema — built.** `RodOrderAllocation` (in `FlatWire_DDL_03_Materials.sql`) and
  `RodOrderConsumption` (in `FlatWire_DDL_04_Runs.sql`), with their foreign keys in `06` and their
  index statements in `07`. Both are in `FlatWire_DDL_RunAll.sql` and both carry seed fixtures.
  They are documented in [`FlatWireSchema_Materials.md`](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Materials.md)
  and [`FlatWireSchema_Runs.md`](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Runs.md), and the
  counted baseline that moved because of them is `[DBD §6.2]`.
- **Register ids — minted.** `Q48`–`Q58`, `OI-123`–`OI-125`, `G47`, `G48`.
- **Requirements — propagated.** `[REQ]` §5.28, `FR-541`–`FR-560` / `ORD003`–`ORD017`.

What is still genuinely **proposed**, in the sense `[PLC]` uses the word, is the *reasoning* below —
the sequence tiers, the handoff state machine and the fulfilment rollup are our reading of the client
rules, not client-confirmed text. `Q48` is `Critical` and open.

**Why now.** The client confirmed the cardinality on 20 Aug (`D2`): *"Spool to A-rods is one to many.
In turn, that one A-rod could be on multiple orders as well."* The spool-level siblings
`SpoolTraceability` and `SpoolOrder` were built on 22 Aug, and `SpoolOrder`'s own header leans on the
table designed here — *"read from the shared `planning_routings` rod→order allocation that already
resolves a rod's order at staging."*

**Terminology.** "Order", never "sales order" — the same class of rule as the repository's existing
*"always flat wire, never strip."* The sole exception is the literal object name
`mfg_sales_order_ref`.

### 0.1 The rules this is built to

| | Rule |
|---|---|
| 1 | **Planning** supplies the rod ↔ order mapping, the per-rod allocated weight where a rod is split, and the sequence in which rods should be processed |
| 2 | **Orders are processed one at a time to completion.** No interleaving, no order left part-filled while another runs. **Scoped to FL1/FL3** — the rod-fed lines |
| 3 | Within an order, the operator **may process rods in any sequence he prefers** |
| 4 | A rod split between two orders is processed **once, continuously** — so it is the **last** rod of the outgoing order and the **first** rod of the incoming one. It cannot sit in a middle position |
| 5 | Each order's rods therefore partition into a **pinned-first** rod, **free** rods, and a **pinned-last** rod |
| 6 | The split point within a rod is expressed in **footage**, converted to weight by a formula held in one configurable place |
| 7 | The rod is **checked in once, at mount**, and stays mounted across the order boundary — no dismount, no remount, no second check-in |
| 8 | Consumption is tracked against the running order; when its allocated weight is reached the system **raises a notification** |
| 9 | The order is **not auto-closed** — the operator explicitly marks it complete, and only then does the next order begin. The interval between threshold and acknowledgement is a real state, and the **overrun in it must be captured, not discarded** |

### 0.2 Three departures from those rules, stated outright

| Rule as given | Delivered | Why |
|---|---|---|
| *"per-pairing allocated weight **and footage**"* | allocated weight, and the split point in **pounds** | Footage is not conserved through drawing and rolling — the same 900 lb is ≈ 11,100 ft at FL1 gauge and ≈ 76,300 ft at FL2 (§2.6, §2.8). A rod-local footage figure cannot be compared with the line's counter without re-deriving through weight, so storing it invites the error it appears to prevent. Weight is also the client's own unit: their planner has no footage variable in 561 lines |
| *"the **footage** split point"* (rule 6) | the same boundary as cumulative pounds; feet derived at run time | Same reason. The operator still sees and acts on **feet** — the conversion happens once, at pairing start, at the running gauge |
| *"a … pluggable function… since the formula is not yet final"* | one interface, **one** implementation, config selecting the *basis* | The formula **is** final: `FR-137` and `[DBD §6.6]` specify it and `FR-332a` bans a wrong variant. What is open is the **dimensional basis** (`OI-45` / `Q10`), so pluggability belongs at the basis, not the arithmetic (§4) |

---

## 1. The source workbook — what it shows, and what it does not

[`FL Alphas Plus.xlsm`](../BaseDocuments/FL%20Alphas%20Plus.xlsm) was read directly: three sheets
(`INPUT`, `FL1`, `FL2`), no hidden sheets, no defined names, no cell notes, one form-control button,
561 lines of VBA in `Module1`.

### 1.1 The flow it implements

1. **`GenerateFL1_Optimized`** slices `orderWeight` (40,000 lb) into `targetSpoolWeight` (1,800 lb)
   chunks. `VALIDATE FINAL STOP POSSIBILITY` raises a chunk whose `Mod stopMax` remainder falls below
   `stopMin` — which is why the shipped run produces **40,400 lb**: the 400 lb tail is raised to 800
   rather than becoming an unshippable coil.
2. It walks a rod cursor across those spools, minting one alpha per **segment**
   (`currentRod & AlphaLetter(alphaIndex)`, the index resetting per rod) and pushing
   `SegmentType(Rod, Alpha, Weight, SpoolID)` onto a global array. **Array order is the sequence.**
3. **`GenerateFL2_Optimized`** groups segments by `SpoolID`, cuts each spool into stops of
   ≤ `stopMax` (raising a stop to absorb a sub-`stopMin` tail), builds each stop from segments **of
   the same spool only** — `' RULE: A STOP MAY USE MULTIPLE ALPHAS BUT ONLY FROM THE SAME SPOOL` —
   and emits the parts in **reverse** consumption order.
4. **`UpdateDashboard`**: 11 rods · 23 spools · 45 stops · 40,400 lb · 91.82 %. **14 of 23 spools are
   single-rod; 9 span a weld** — the multi-rod spool is the normal minority, not an edge case.

### 1.2 What it does not contain

**This is the load-bearing finding of the whole document.**

| Absent | Evidence |
|---|---|
| **Any order entity** | `Order Weight` is one scalar in cell `C4`, used in exactly one expression (`remainingOrder = orderWeight`). There is no order id, no second order, no rod↔order mapping, no per-order allocation, no order sequence, no handoff and no acknowledgement |
| **Footage** | Not one footage variable in 561 lines. Every allocation is in **pounds** |
| **An operator** | No actual-versus-planned sequence. The array order *is* the sequence, and it is planning's |

**So the `R1A`–`R1D` / `O1`–`O2` worked example is not in the workbook.** It is the client's own, and
it matches the verbal model recorded on the 20 Aug call. This design therefore derives from §0.1 plus
the repository's decided `Q70`, `Q73` and `D2` — not from the sheet. *(The example's rod labels are
illustrative shorthand; they carry no statement about alpha creation and are used here as given.)*

### 1.3 What the workbook does anchor

| Anchor | Consequence |
|---|---|
| **The unit is pounds** | Allocation is held in pounds; the converter (§4) bridges to feet at one place |
| **A spool spans rods; a coil never spans spools** | The FL1 rollup joins through the spool; `ORD016` makes the second half a rule |
| **Planned order, and *last on, first off*** | Sequence is data, not derivable — hence explicit sequence columns |
| **Metallic yield** | `totalOutput / (rodsUsed × rodWeight)` = 91.82 %, a working definition for a figure the repository has none of (`OI-60` / `Q11`) |

---

## 2. Data model

### 2.1 What already exists and is reused, not duplicated

| Need | Existing |
|---|---|
| Rod master, alpha unique | `Rod` (`UQ_Rod_Alpha`) |
| **The rod check-in record** rule 7 refers to | `RodCheckin` — `RunId`, `RodAlpha`, `OrderId`, weights, `MmsId`/`MmsStatus` |
| Planned vs actual sequence pattern | `RodStaging.PlannedSeqno` (snapshot) + `RodSeqno` (actual) |
| Sequence-deviation authorisation | `RodStaging.OutOfSequenceOverride`, `ExpectedRodAlpha`, `OverrideBy`/`At`/`Reason` — PIN never stored |
| Partial-rod carry-forward | `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb` |
| Rod abandoned mid-run | `RodCheckout` **Mode B** (supervisor, footage > 0) |
| **Durable operator prompt** | `FlatWireRun.PromptDueAt` / `PromptPlcStopTs` / `PromptLatchedWeightLb` / `PromptResolvedAt` / `PromptAnswer`, with hub events `SpoolCompletionPromptDue` / `Resolved` — `[SIG §5.2]`, the one non-fire-and-forget event |
| Threshold crossing raised server-side | `SpoolWeightMilestone` — *"raised server-side on crossing, not client-side on a threshold check"* |
| Half-open ranges | `SpoolTraceability`, `CoilTraceability`, `trg_CoilTraceability_NoOverlap` |
| Order **set** with no FK on the order | `SpoolOrder` (`Derived`/`Planned`, no FK — `D-32`) |
| Genealogy hops | `SpoolTraceability` (rod→spool), `CoilTraceability` (coil→rod/spool) |
| **FL1 segment-alpha → spool mapping** | **`SpoolTraceability`**, built 22 Aug from the client's own `SegmentType`; one column short (§2.4) |
| **lb/ft formula** | `FR-137` + `[DBD §6.6]` |
| Exclusivity as a constraint, not a `409` | `UX_RodStaging_Bay`; `Q17`'s recommendation for the spool equivalent |
| Order rule-code series | `ORD001` / `ORD002` — extended here, not replaced |
| ±2 % weight tolerance | `FR-153` — not re-minted |
| The fixed spool list | `Spool` — 45 articles, `SP-0001` … `SP-0045`. **Not** `SpoolConfiguration`, which is a one-row size class |

**Two tables are proposed, not one.** The plan is re-planned and the actual is immutable; one table
means either mutating history or carrying two nullable halves.

### 2.2 `RodOrderAllocation` — the plan

Would sit in `FlatWire_DDL_03_Materials.sql`, beside `SpoolOrder`, whose shape and basis it mirrors.

```sql
-- ------------------------------------------------------------
-- RodOrderAllocation
-- The rod <-> order many-to-many, with per-pairing allocated weight
-- and the rod-local weight range that pairing occupies.
--
-- NO FK ON OrderNo. Orders live in the shared schema and D-32 forbids
-- altering it, so this is an unenforced external reference -- the same
-- basis D-31 sets for PlanId / CoilOrderPlanId / SkidId, and the same
-- choice SpoolOrder made on 22 Aug.
--
-- THE SPLIT IS IN POUNDS, NOT FEET, and that is deliberate. Weight is
-- conserved through drawing and rolling; footage is not -- the same
-- 900 lb is ~11,100 ft at FL1 gauge and ~76,300 ft at FL2, a 7x
-- cross-section difference (DBD 6.6). A rod-local footage figure could
-- not be compared with the line's counter without re-deriving through
-- weight, so it would invite the error it looks like it prevents.
-- Pounds are also the client's own unit: there is not one footage
-- variable in the 561 lines of their planner.
--
-- THE SPLIT POINT IS NOT A COLUMN. It is the outgoing row's
-- RodWeightTo, which equals the incoming row's RodWeightFrom. A
-- separate SplitWeightLb would be a second copy of one number and it
-- would not survive a rod shared by three orders. This shape does.
--
-- RANGES ARE HALF-OPEN [From, To), matching SpoolTraceability and
-- CoilTraceability so the chain reads the same at every hop.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderAllocation]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodOrderAllocation] (
        [Id]                       INT            NOT NULL IDENTITY(1,1),   -- surrogate PK, repo convention
        [RodAlpha]                 VARCHAR(20)    NOT NULL,                 -- FK -> Rod.Alpha; the left side of the pairing
        [OrderNo]                  VARCHAR(50)    NOT NULL,                 -- shared-schema order; NO FK by design (D-32)
        [RelLetter]                VARCHAR(10)    NULL,                     -- release letter, mirroring SpoolOrder.RelLetter
        [OrderSeqNo]               SMALLINT       NOT NULL,                 -- this order's position in the station's queue; a shared rod's two rows differ by 1 here
        [RodSeqNoInOrder]          SMALLINT       NOT NULL,                 -- planning's rod sequence WITHIN this order
        [AllocatedWeightLb]        DECIMAL(8,2)   NOT NULL,                 -- pounds of this rod allocated to this order -- planning's number, never derived
        [RodWeightFrom]            DECIMAL(8,2)   NOT NULL,                 -- rod-local cumulative pounds, INCLUSIVE bound
        [RodWeightTo]              DECIMAL(8,2)   NOT NULL,                 -- rod-local cumulative pounds, EXCLUSIVE bound; the split point when a successor row exists
        [PinRole]                  VARCHAR(12)    NOT NULL,                 -- Sole|PinnedFirst|Free|PinnedLast|PinnedBoth -- stored, not derived: the validator reads it on every scan
        [RodKind]                  VARCHAR(10)    NOT NULL,                 -- Full|Partial -- Q73's tier-2 discriminator; Partial is a back-to-stock remainder
        [Source]                   VARCHAR(15)    NOT NULL
            CONSTRAINT [DF_RodOrderAllocation_Source] DEFAULT ('Planned'),  -- Planned|Derived|Substituted
        [SupersededByAllocationId] INT            NULL,                     -- re-planning is ADDITIVE: the old row is superseded, never updated
        [IsActive]                 BIT            NOT NULL
            CONSTRAINT [DF_RodOrderAllocation_IsActive] DEFAULT (1),        -- 0 once superseded; the filtered indexes key on it
        [CreatedBy]                VARCHAR(50)    NULL,                     -- audit
        [CreatedAt]                DATETIMEOFFSET NOT NULL
            CONSTRAINT [DF_RodOrderAllocation_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),

        CONSTRAINT [PK_RodOrderAllocation]          PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_RodOrderAllocation_PinRole]  CHECK ([PinRole] IN ('Sole','PinnedFirst','Free','PinnedLast','PinnedBoth')),
        CONSTRAINT [CK_RodOrderAllocation_RodKind]  CHECK ([RodKind] IN ('Full','Partial')),
        CONSTRAINT [CK_RodOrderAllocation_Source]   CHECK ([Source]  IN ('Planned','Derived','Substituted')),
        CONSTRAINT [CK_RodOrderAllocation_Weight]   CHECK ([AllocatedWeightLb] > 0),
        CONSTRAINT [CK_RodOrderAllocation_Seq]      CHECK ([OrderSeqNo] >= 1 AND [RodSeqNoInOrder] >= 1),
        -- Half-open, so From < To. AND the range must equal the allocation: exact
        -- DECIMAL arithmetic makes that a single-row check, so the two can never
        -- disagree. The footage version of this column pair could not express it.
        CONSTRAINT [CK_RodOrderAllocation_WeightRange] CHECK ([RodWeightFrom] < [RodWeightTo]
                                                          AND [RodWeightTo] - [RodWeightFrom] = [AllocatedWeightLb])
    );
    PRINT 'Created table: RodOrderAllocation';
END
ELSE
    PRINT 'Table already exists: RodOrderAllocation';
GO
```

**Foreign keys** — would go in `FlatWire_DDL_06_ForeignKeys.sql`, where every FK lives:

```sql
ALTER TABLE [dbo].[RodOrderAllocation] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderAllocation_Rod]
    FOREIGN KEY ([RodAlpha]) REFERENCES [dbo].[Rod] ([Alpha]);
GO

ALTER TABLE [dbo].[RodOrderAllocation] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderAllocation_Superseded]
    FOREIGN KEY ([SupersededByAllocationId]) REFERENCES [dbo].[RodOrderAllocation] ([Id]);
GO
```

**Indexes** — would go in `FlatWire_DDL_07_Indexes.sql`:

```sql
-- One ACTIVE allocation per (rod, order, release).
-- A FILTERED unique index, NOT SpoolOrder's ISNULL-into-the-key trick: here SQL
-- Server's treat-NULLs-as-equal behaviour is exactly what is wanted, because two
-- rows with a NULL RelLetter for one rod and order ARE the same pairing. State the
-- difference, or the next reader "fixes" it.
CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderAllocation_Active]
    ON [dbo].[RodOrderAllocation] ([RodAlpha], [OrderNo], [RelLetter])
    WHERE [IsActive] = 1;
GO

-- No two rods share a planned position within one order.
CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderAllocation_OrderRodSeq]
    ON [dbo].[RodOrderAllocation] ([OrderNo], [RelLetter], [RodSeqNoInOrder])
    WHERE [IsActive] = 1;
GO

CREATE NONCLUSTERED INDEX [IX_RodOrderAllocation_RodAlpha]
    ON [dbo].[RodOrderAllocation] ([RodAlpha])
    INCLUDE ([OrderNo], [PinRole], [IsActive]);
GO

-- The sequence validator's read path: an order's rod set with everything it needs.
CREATE NONCLUSTERED INDEX [IX_RodOrderAllocation_Order]
    ON [dbo].[RodOrderAllocation] ([OrderNo], [RelLetter])
    INCLUDE ([RodAlpha], [RodSeqNoInOrder], [PinRole], [RodKind], [AllocatedWeightLb]);
GO

CREATE NONCLUSTERED INDEX [IX_RodOrderAllocation_OrderSeq]
    ON [dbo].[RodOrderAllocation] ([OrderSeqNo]) WHERE [IsActive] = 1;
GO
```

**Domain invariants — cross-row, so no `CHECK` can express them.** SQL Server has no exclusion
constraint. Each is listed because a reader will otherwise take the absence of a constraint for an
oversight.

| Invariant | Note |
|---|---|
| A rod's active ranges **tile the rod** with no gap and no overlap | A trigger is *viable* here — both weight columns are `NOT NULL`, so the NULL-join trap that rules one out on `SpoolTraceability` does not apply. `trg_CoilTraceability_NoOverlap` is the precedent for saying yes |
| A `PinnedBoth` row is its order's **only** row | cross-row |
| An order with any allocation has **≥ 1** rod | cross-row |
| `OrderSeqNo` is **contiguous** across a station's queue | cross-row, and spans orders |

### 2.3 `RodOrderConsumption` — the actual

Would sit in `FlatWire_DDL_04_Runs.sql`. One row per pairing actually run.

```sql
-- ------------------------------------------------------------
-- RodOrderConsumption
-- What was actually consumed against each (rod, order) pairing, and
-- the handoff state machine that carries the order boundary.
--
-- ONE CHECK-IN, N CONSUMPTION ROWS -- and that cardinality IS the
-- client's rule 7. A rod planned for two orders is checked in ONCE and
-- stays on the payoff across the boundary: the operator marks order 1
-- complete and starts order 2 on the same mount. No dismount, no
-- remount, no second check-in -- so RodCheckin is the parent and this
-- table is the child.
--
-- THE STATION IS THE EXCLUSIVITY KEY, NOT LineId. FL1 and FL3 share
-- ONE physical VPS (STATION_BY_LINE maps both to FL1PO), so keying on
-- LineId would admit (FL1,...) and (FL3,...) as distinct entries for
-- what is one payoff. Exactly the correction G21 forced on RodStaging;
-- LineId is retained for projection and reporting only.
--
-- TWO WEIGHT LATCHES, NOT ONE. LatchedWeightAtThresholdLb is captured
-- at the crossing instant and never re-read;
-- WeightAtAcknowledgementLb is captured when the operator confirms.
-- The OVERRUN is the difference, and the client requires it be
-- captured rather than discarded. Same rule as
-- FlatWireRun.PromptLatchedWeightLb: the weight AT that instant, never
-- a later drifted value.
--
-- THE ROW STATES ITS OWN CONVERSION. LbPerFtUsed + ConversionBasis +
-- ConverterVersion are persisted per row so a change to the
-- footage->weight formula NEVER retro-changes a historical record.
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RodOrderConsumption]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[RodOrderConsumption] (
        [Id]                          INT            NOT NULL IDENTITY(1,1),
        [ConsumptionId]               VARCHAR(20)    NOT NULL,   -- e.g. RC-0041; human key, as CheckoutId / RejectionId / CheckpointId
        [RunId]                       VARCHAR(20)    NOT NULL,   -- FK -> FlatWireRun.RunId
        [RodCheckinId]                INT            NOT NULL,   -- FK -> RodCheckin.Id; the mount this pairing runs on
        [Station]                     VARCHAR(10)    NOT NULL,   -- e.g. FL1PO; the exclusivity key (G21)
        [LineId]                      VARCHAR(5)     NOT NULL,   -- FL1|FL3; projection and reporting only
        [RodAlpha]                    VARCHAR(20)    NOT NULL,   -- FK -> Rod.Alpha
        [OrderNo]                     VARCHAR(50)    NOT NULL,   -- shared-schema order; NO FK by design
        [RelLetter]                   VARCHAR(10)    NULL,
        [AllocationId]                INT            NULL,       -- FK -> RodOrderAllocation.Id; NULL for a substitution made before the allocation row exists
        [AllocatedWeightLbSnapshot]   DECIMAL(8,2)   NULL,       -- SNAPSHOT, not a join -- re-planning must not retro-change what the floor was told
        [PlannedRodSeqNoSnapshot]     SMALLINT       NULL,       -- ditto; same pattern as RodStaging.PlannedSeqno
        [ActualRodSeqNo]              SMALLINT       NOT NULL,   -- the position this rod actually took in this order
        [State]                       VARCHAR(20)    NOT NULL,   -- Pending|InProgress|ThresholdReached|Closed|Voided
        [StartFootageFt]              DECIMAL(10,2)  NOT NULL,   -- RUN-CUMULATIVE anchor, captured live from the counter
        [EndFootageFt]                DECIMAL(10,2)  NULL,       -- run-cumulative at close
        [ConsumedFootageFt]           AS ([EndFootageFt] - [StartFootageFt]) PERSISTED,  -- the only footage arithmetic in the table
        [ThresholdFootageFt]          DECIMAL(10,2)  NULL,       -- computed ONCE at pairing start: remaining allocated weight -> feet at the running gauge, plus StartFootageFt
        [ThresholdReachedAt]          DATETIMEOFFSET NULL,       -- the crossing instant
        [LatchedWeightAtThresholdLb]  DECIMAL(8,2)   NULL,       -- latched AT the crossing; never a fresher tick
        [NotificationRaisedAt]        DATETIMEOFFSET NULL,       -- when OrderAllocationReached went out
        [AcknowledgedAt]              DATETIMEOFFSET NULL,       -- rule 9: the operator closes the order, not the system
        [AcknowledgedBy]              VARCHAR(50)    NULL,
        [WeightAtAcknowledgementLb]   DECIMAL(8,2)   NULL,       -- the SECOND latch
        [OverrunWeightLb]             AS ([WeightAtAcknowledgementLb] - [LatchedWeightAtThresholdLb]) PERSISTED,  -- + = overrun, - = early ack
        [VarianceVsAllocationLb]      AS ([WeightAtAcknowledgementLb] - [AllocatedWeightLbSnapshot]) PERSISTED,
        [ConsumedWeightLb]            DECIMAL(8,2)   NULL,       -- written at close, NOT computed -- the basis may be integration over RunReading
        [ConversionBasis]             VARCHAR(20)    NULL,       -- Nominal|Measured|IntegratedRunReading|Override (OI-45)
        [LbPerFtUsed]                 DECIMAL(10,6)  NULL,       -- the factor actually applied; a historical row is never recomputed
        [ConverterVersion]            VARCHAR(20)    NULL,       -- for a change of formula SHAPE rather than factor
        [ClosureReason]               VARCHAR(25)    NULL,       -- Acknowledged|AcknowledgedEarly|RodExhausted|RodAbandoned|Superseded
        [RodCheckoutId]               VARCHAR(20)    NULL,       -- FK -> RodCheckout.CheckoutId when closure is RodAbandoned (Mode B)
        [ShortfallWeightLb]           DECIMAL(8,2)   NULL,       -- set when the pairing closed below allocation because material ran out
        [OperatorId]                  VARCHAR(50)    NOT NULL,
        [CreatedAt]                   DATETIMEOFFSET NOT NULL
            CONSTRAINT [DF_RodOrderConsumption_CreatedAt] DEFAULT (SYSDATETIMEOFFSET()),
        [ModifiedBy]                  VARCHAR(50)    NULL,
        [ModifiedAt]                  DATETIMEOFFSET NULL,
        [RowVersion]                  ROWVERSION     NOT NULL,   -- State and footage move live, as on FlatWireRun

        CONSTRAINT [PK_RodOrderConsumption]         PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_RodOrderConsumption_CId]     UNIQUE ([ConsumptionId]),
        -- One mount, one pairing per order.
        CONSTRAINT [UQ_RodOrderConsumption_Pair]    UNIQUE ([RodCheckinId], [OrderNo], [RelLetter]),
        CONSTRAINT [CK_RodOrderConsumption_State]   CHECK ([State] IN ('Pending','InProgress','ThresholdReached','Closed','Voided')),
        CONSTRAINT [CK_RodOrderConsumption_LineId]  CHECK ([LineId] IN ('FL1','FL3')),
        CONSTRAINT [CK_RodOrderConsumption_Closure] CHECK ([ClosureReason] IS NULL OR [ClosureReason] IN
                                                     ('Acknowledged','AcknowledgedEarly','RodExhausted','RodAbandoned','Superseded')),
        CONSTRAINT [CK_RodOrderConsumption_Footage] CHECK ([EndFootageFt] IS NULL OR [EndFootageFt] >= [StartFootageFt]),
        CONSTRAINT [CK_RodOrderConsumption_Seq]     CHECK ([ActualRodSeqNo] >= 1),
        -- The three acknowledgement stamps are all-or-nothing. Written with explicit
        -- IS NULL pairs, because "A IS NOT NULL AND B IS NOT NULL" evaluates to UNKNOWN
        -- when one side is NULL and a CHECK constraint ACCEPTS UNKNOWN -- the trap
        -- CK_AlloyProperty_RodDiaTol was fixed for.
        CONSTRAINT [CK_RodOrderConsumption_AckStamps] CHECK (
              ([AcknowledgedAt] IS NULL     AND [AcknowledgedBy] IS NULL     AND [WeightAtAcknowledgementLb] IS NULL)
           OR ([AcknowledgedAt] IS NOT NULL AND [AcknowledgedBy] IS NOT NULL AND [WeightAtAcknowledgementLb] IS NOT NULL)),
        -- An abandoned pairing must name the checkout that abandoned it. Same per-mode
        -- shape as CK_RodCheckout_ModeB.
        CONSTRAINT [CK_RodOrderConsumption_Abandon]  CHECK (
              [ClosureReason] <> 'RodAbandoned' OR [RodCheckoutId] IS NOT NULL)
    );
    PRINT 'Created table: RodOrderConsumption';
END
ELSE
    PRINT 'Table already exists: RodOrderConsumption';
GO
```

**Foreign keys:**

```sql
ALTER TABLE [dbo].[RodOrderConsumption] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderConsumption_Run]        FOREIGN KEY ([RunId])         REFERENCES [dbo].[FlatWireRun] ([RunId]);
GO
ALTER TABLE [dbo].[RodOrderConsumption] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderConsumption_Checkin]    FOREIGN KEY ([RodCheckinId])  REFERENCES [dbo].[RodCheckin] ([Id]);
GO
ALTER TABLE [dbo].[RodOrderConsumption] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderConsumption_Rod]        FOREIGN KEY ([RodAlpha])      REFERENCES [dbo].[Rod] ([Alpha]);
GO
ALTER TABLE [dbo].[RodOrderConsumption] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderConsumption_Allocation] FOREIGN KEY ([AllocationId])  REFERENCES [dbo].[RodOrderAllocation] ([Id]);
GO
ALTER TABLE [dbo].[RodOrderConsumption] WITH CHECK
    ADD CONSTRAINT [FK_RodOrderConsumption_Checkout]   FOREIGN KEY ([RodCheckoutId]) REFERENCES [dbo].[RodCheckout] ([CheckoutId]);
GO
```

**Indexes:**

```sql
-- ============================================================
-- RULE 2 AS A CONSTRAINT, NOT AS A 409.
-- Orders are processed one at a time to completion, so at most ONE
-- pairing may be open at a payoff. Enforced here rather than only in
-- the application, for the same reason UX_RodStaging_Bay is: a rule
-- checked only in code is not enforced under concurrent clients.
-- Q17 asks for exactly this shape on the spool side.
--
-- Keyed on Station, so FL1 and FL3 -- which share one physical VPS --
-- cannot both hold an open order.
--
-- The predicate MUST be a literal IN list: SQL Server forbids a
-- computed column in a filtered-index predicate, so an IsOpen BIT
-- convenience column cannot be used here even though it reads better.
-- ============================================================
CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderConsumption_Station]
    ON [dbo].[RodOrderConsumption] ([Station])
    WHERE [State] IN ('InProgress','ThresholdReached');
GO

-- No two rods take the same actual position within one order.
CREATE UNIQUE NONCLUSTERED INDEX [UX_RodOrderConsumption_ActualSeq]
    ON [dbo].[RodOrderConsumption] ([OrderNo], [RelLetter], [ActualRodSeqNo]);
GO

CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_Order]
    ON [dbo].[RodOrderConsumption] ([OrderNo], [RelLetter])
    INCLUDE ([State], [ConsumedWeightLb], [AllocatedWeightLbSnapshot], [RodAlpha]);
GO

CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_RunId]    ON [dbo].[RodOrderConsumption] ([RunId]);
GO
CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_Checkin]  ON [dbo].[RodOrderConsumption] ([RodCheckinId]);
GO
CREATE NONCLUSTERED INDEX [IX_RodOrderConsumption_RodAlpha] ON [dbo].[RodOrderConsumption] ([RodAlpha]);
GO
```

### 2.4 The FL1 segment alpha

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

**`SpoolTraceability` already holds three of the four fields:**

| `SegmentType` | `SpoolTraceability` |
|---|---|
| `SpoolID` | `SpoolAlpha` — FK → `SpoolProcessing.Alpha` |
| `Rod` | `RodAlpha` |
| `Weight` | `SegmentWeightLb` |
| *(array position)* | `SeqNo`, `UQ (SpoolAlpha, SeqNo)` |
| **`Alpha`** | ⚠ **nothing today** — the owed `ChildAlpha` |

**The column was left out on purpose, and its holding comment now instructs the reader wrongly.** It
must be **replaced**, not annotated — it is the only place the reasoning lives.

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
-- MINTED BY CommonDB.dbo.GenerateCoilAlpha(rodAlpha, ''), NOT by a local
-- per-rod counter. A BLANK ignore list -- see the precondition below.
--
-- *** THE @ignoreList ARGUMENT WAS REMOVED 26 AUG 2026. *** It read:
-- "@ignoreList carries EVERY alpha already recorded for this rod in
-- SpoolTraceability, not just this transaction's ... FlatWireDB is
-- outside [the sweep]. Cap 500 chars." That was correct while segment
-- alphas stayed FlatWireDB-local.
--
-- PRECONDITION: EVERY SEGMENT ALPHA IS REGISTERED IN proddb..coils. That
-- is what lets the list go -- the sweep then finds prior segments the
-- same way it finds prior coils. WITHOUT THAT WRITER A BLANK LIST
-- REISSUES R00001A ON EVERY SPOOL. Nothing writes it yet; see OQ-T.
--
-- FL2 coil parts DO NOT root here. They root on the SEGMENT alpha this
-- column holds -- GenerateCoilAlpha('R00001A','') -> R00001AA -- so a
-- segment takes a single trailing letter and a coil takes a double.
-- Rod-fed coils (no segment) fall back to the rod. See 2.5 and 2.8.
--
-- The function takes no locks (twelve objects across four databases, so
-- it cannot).
--
-- OPAQUE TO CODE, though no longer meaningless to a person. Since coils
-- root on the segment, SHAPE distinguishes the tiers: one trailing
-- letter = segment, two = coil off that segment.
--
-- BUT STILL NEVER PARSE OR REBUILD IT, for two reasons. (1) The shape is
-- readable only while a rod needs <= 26 segments; past that the
-- rod-rooted sweep issues double letters itself and R00001A + 'A' and
-- R00001 + AlphaLetter(27) both render R00001AA again -- the ambiguity
-- this comment used to state unconditionally. (2) The letter WITHIN a
-- tier is still mint-order: the function may skip a suffix already
-- taken, so a stored letter index would drift from what it explains.
-- There is deliberately NO stored letter index. SeqNo carries ordering.
ALTER TABLE [dbo].[SpoolTraceability] ADD [ChildAlpha] VARCHAR(20) NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SpoolTraceability_ChildAlpha]
    ON [dbo].[SpoolTraceability] ([ChildAlpha]) WHERE [ChildAlpha] IS NOT NULL;
GO
```

> ⚠ **FOUR letter counters exist, and only ONE of them is implemented. None derives from another.**
>
> | Counter | Scope | Produces | Built? |
> |---|---|---|---|
> | `alphaIndex` *(the workbook's)* | per **rod** | the segment alpha, `R00001C` | ⛔ **No** — the segment alpha is a generator mint, not a counter |
> | **`SeqNo`** *(ours)* | per **spool** | the order material went on | ✅ **Yes** — the only one stored |
> | `stopAlphaCounter` *(the workbook's)* | per **spool, per stop** | the FL2 stop suffix, `R00001CA` | ⛔ **Still no — but its FORM is now what the generator emits.** Segment-rooting produces `R00001CA` from `GenerateCoilAlpha('R00001C','')`. The **counter** is not implemented and the per-stop numbering is not adopted (it is not unique); only the shape coincides. §2.8 |
> | **the coil part** *(new, 26 Aug 2026)* | per **(coil × source rod)** | `FlatWire_CoilTraceability.ChildAlpha` | ✅ **A generator mint, not a counter** |
>
> On spool 3 the two segments are `SeqNo` 1 and 2 while their letters are `C` and `A` — a welded
> spool takes the *third* piece of one rod and the *first* of the next. **Anything ordering by letter
> is wrong.**
>
> ⚠ **`stopAlphaCounter` is analysis only.** The analysis flags it as **not a unique key** — every part
> within one stop gets the same letter, which is why `R00004AB` exists in the shipped run with no
> `R00004AA`. ⚠ **That gap is EVIDENCE of the mechanism, not a defect** — the source calls it
> *"correct behaviour, not a defect"*, because `R00004A`'s material appears only in its spool's second
> stop. **Do not cite it as a defect.**
>
> ⛔ **The single-source rule, stated once:** every flat wire alpha at every hop comes from
> `CommonDB.dbo.GenerateCoilAlpha` and nothing else. `alphaIndex` and `stopAlphaCounter` explain the
> client's sheet; **nothing implements them** (`Q88`).

**Five consequences of minting through the shared function.**

| | Consequence |
|---|---|
| 1 | ⛔ **There is no ignore list. Every mint passes `''`** — because every alpha is registered in `proddb..coils`, so the sweep sees every sibling. *(This entry read "the ignore list is every prior segment alpha for that rod, read from `SpoolTraceability`… stay inside `VARCHAR(500)`". It was correct while segment alphas stayed `FlatWireDB`-local, and it is what the whole accumulator existed for.)* **Two hazards go with it:** `F10`'s 2048 → 500 truncation and `F11`'s 500-character cap are **moot for flat wire**, since no accumulator is built. ⛔ **PRECONDITION: the FL1 segment writer into `proddb..coils` does not exist yet** — until it does, a blank list at FL1 reissues `R00001A` every spool (**`OQ-T`**). ✅ Verified on live data (`F14`): a blank mint skips registered children of both a six-character root and a seven-character segment. This also **moots `OI-136`** — blank becomes correct everywhere, so the shipped procedure and the design stop disagreeing |
| 2 | **Replicate the caller's two guards** — the `' '` blank return (`THROW 51010`) and the `UPDLOCK, HOLDLOCK` re-check (`THROW 51011`) |
| 3 | **FL1 spool completion becomes a cross-database caller.** Same instance, local transaction manager, no MSDTC — but **it can no longer be tested on LocalDB**, which has no `CommonDB`. `CLAUDE.md` carries that warning for check-in; it now applies here |
| 4 | **§9 F1 escalates** — the unresolved `coils` reference now gates FL1 as well as Phase 9 |
| 5 | **The budget is now TIERED, not shared.** A rod draws single letters for its segments — **26**, needing 27 spools off one rod to exhaust — and **each segment carries its own 26** two-letter children for coils. So ~3 segments and ~2 coils per segment sit against 26 and 26, not against one shared 702. ⚠ The tiers only stay separate while a rod needs ≤ 26 segments; past that the rod-rooted sweep issues double letters and the two tiers merge (`F13`, and §2.8's shape note) |

**What `SegmentType` does not carry**, and so what the surrounding tables supply: no order, no
footage, no weld reference, no dates, no operator, no spool alpha.

**This does not conflict with `D8`.** `D8` rejected *pre-generating* alphas and was about **FL2 output
coils**. An FL1 segment alpha minted at the **spool-completion transaction** (`D5`) *is* created on an
actual transaction. The two rules name different objects.

### 2.5 The welded spool, and what FL2 creates from it

Spool 3 carries `R00001C` (400 lb) and `R00002A` (1,400 lb). **Nine of twenty-three spools look like
this.**

**No new alpha is minted for the spool.** Three identities already exist:

| Purpose | Identity |
|---|---|
| The spool as **local material** | `SpoolProcessing.Alpha` = `SP-#####` |
| The spool's **shared-schema face** — what FL2 scans | **the lead segment alpha** (`R00002A`), per the `OI-115` narrowing, 20 Aug |
| Full **parentage** | `SpoolTraceability`, one row per segment |

**Why not mint a spool-level alpha off a primary rod.** With the namespace unified,
`GenerateCoilAlpha('R00002','')` returns **`R00002B`** — **a sibling of its own child.**
`R00002A` would be a segment *on* the spool and `R00002B` the spool *containing* it, both children of
root `R00002` at the same level of the legacy tree. Not avoidable by care; it is what one namespace
guarantees. **Do not mint a container's identifier from its contents' namespace.**

> ⚠ **Why `R00002B` and not `R00002A` — the registration rule is doing the work here.** `R00002A` is
> already taken by a segment on this spool, and because **every alpha is registered in
> `proddb..coils`** the sweep finds it and moves on. Blank is therefore correct, and the paragraph's
> conclusion holds without passing anything.
>
> *Superseded 26 Aug 2026, twice over.* This call was written `('R00002', …)` with the ignore list
> elided, then briefly as `('R00002','R00002A')` when the list was still the mechanism. **Both are
> obsolete** — but note the sequence, because it is the argument in miniature: with **no** registration
> and a **blank** list the call returns `R00002A`, handing the spool the identifier of a segment already
> on it, which is worse than the sibling this paragraph rejects. Registration is what makes blank safe;
> **`OQ-T`** is that it does not exist yet. See **`F14`** (§9.1).

**The precedent is `D6`**, which meets the same problem one hop later and writes **one primary
parent** to `coil_gen_history` while the full chain stays in `CoilTraceability`, calling it *"a real
loss of fidelity"* and accepting it. **The shared schema takes one; the local table keeps all.**

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
decisively, **heaviest is not deterministic and last-on always is.** Across the nine welded spools the
two rules **disagree on four** (7, 9, 16, 18) and **spool 23 is an exact tie at 400 / 400** — the last
spool of the run, so the tie is not contrived. `UQ (SpoolAlpha, SeqNo)` means last-on can never tie.

**`Q45`'s uncertainty is about unwinding, not winding.** Which segment went on last is a recorded
fact. So use the lead for the **label** and the **shared face**, but **not** as a check-in validation:
FL2 must accept **any** segment alpha and resolve the spool from it — the furnace-plate behaviour
agreed 20 Aug, *"they only have to scan one of the coil codes."*

**Two guards.** A spool with no `SpoolTraceability` rows has no lead, and SQL cannot express "every
spool has at least one row" — `leadAlpha` must fail loudly rather than return `NULL` into a label.
And **identity narrows to one parent; accounting must not** — cost, yield and certificate weights read
the per-segment rows. Spool 3 is 1,800 lb of which the lead contributes 1,400; attributing all of it
to `R00002` is wrong by 400 lb, which is exactly the fidelity loss `D6` warns of.

#### What FL2 creates

> ⚠ **REWRITTEN 26 Aug 2026 — this section previously said a coil has ONE shared identity, and that
> was wrong.** Client direction: a welded coil carries **one alpha per source rod** (`Q88`), and
> **every one of them reaches `proddb..coils`** (`Q89`). The old text is superseded, not annotated,
> because its conclusion — *"each coil carries two identities"* — is the thing that changed.

The workbook gives a stop drawing on two segments a **compound** identity — `R00002AA - R00001CA`.
**That cannot be the stored identifier, on three counts:** it is **19 characters** against
`coil_no`'s `char(9)`; its stop letter is shared by every part in the stop, so it **is not unique**;
and `FlatWire_CoilOutput.CoilAlpha` is a unique scalar. ⛔ **A fourth count, and it is the decisive
one:** a locally-built string is **invisible to `CommonDB.dbo.GenerateCoilAlpha`'s sweep**, so nothing
stops a finished coil taking it. **The client's `segmentAlpha + AlphaLetter(stopIndex)` scheme is
rejected outright — not stored, and not rendered either** (`Q88`).

> ### ⚠ `Q88` is NARROWED by the 26 Aug 2026 segment-rooting change — read this before citing it
>
> **What stays rejected: BUILDING the string locally.** That is the fourth count above and it is
> untouched — a locally-assembled alpha is invisible to the sweep, so nothing stops a finished coil
> taking it.
>
> **What is now adopted: GENERATING the same shape.** `GenerateCoilAlpha('R00002A','')` returns
> **`R00002AA`** — the client's own form, emitted by the single-source generator, therefore swept and
> unique. Two of `Q88`'s four counts fall to that: the non-unique stop letter (the generator numbers
> per **segment** and will not reissue) and sweep-invisibility. ⚠ **The other two do not, and were
> never objections to the form:** nineteen characters and *"`CoilAlpha` is a unique scalar"* are
> objections to storing the **compound** string, which nothing proposes — the compound remains a
> render of two generated alphas (§2.8).
>
> ⛔ **`Q88`'s formal disposition is NOT changed here**, nor are the `FlatWire_DDL_05` `ChildAlpha`
> comments that still read *"rooted on THIS ROW's rod, NEVER on the segment"*, nor the ledger's §1.2
> row (b), nor `50_…CompleteCoilOnSkid.sql:483`. All are **propagation-scope** and currently
> **disagree with §2.8**. Cite §2.8 for the design and this note for why.

**So the compound string is a rendering — but N alphas exist behind it, not one.** Each coil carries
**two local identities plus N part alphas**, and N traceability rows:

| What | Value |
|---|---|
| Local identity, customer-facing | `FW-#####-C##`, minted locally → `FlatWire_CoilOutput.CoilAlpha` |
| Shared-schema identity of the **lead** part | `CommonDB.dbo.GenerateCoilAlpha(leadSegmentAlpha, '')` → `VARCHAR(9)` → **`FlatWire_CoilOutput.CoilNo`** *(renamed from `SharedCoilNo`)*. Retained as the coil's one scalar shared face; `D5` stands |
| ⚠ **Every part alpha** | **one per source SEGMENT**, `CommonDB.dbo.GenerateCoilAlpha(thatSegmentAlpha, '')` → **`FlatWire_CoilTraceability.ChildAlpha`**, and **every one is written to `proddb..coils`** with its own weight from `SegmentWeightLb` (`Q89`) |

> ⚠ **Both mints changed on 26 Aug 2026: they root on the SEGMENT, not the rod, and pass a BLANK ignore
> list.** *(They read `GenerateCoilAlpha(leadRod, @ignoreList)` and `(thatRod, @ignoreList)`.)* A coil
> part is a child of the **segment** it was cut from, so `GenerateCoilAlpha('R00002A','')` → `R00002AA`;
> the ignore list goes because every alpha is registered in `proddb..coils` and the sweep finds
> siblings unaided. **Rod fallback:** where `SourceSegmentAlpha IS NULL` — FL1-standalone and
> FL3-from-rod, which have no segment — the mint roots on the **rod**, exactly as before. §2.8 traces
> both, and `F14` carries the measurements and the precondition.
| Every parent | one `FlatWire_CoilTraceability` row per (rod, spool, footage range) |

**Lead part = the rod of the first segment consumed into that coil**, `MIN(FootageFrom)` over its
traceability rows. *(Formerly "primary rod" — the same row, renamed because it is now one of N rather
than the only one.)*

> ### ⛔ The `D6` precedent no longer describes this hop
>
> §2.5 above cites `D6` as *"the shared schema takes one; the local table keeps all."* **That is no
> longer true of the COIL hop.** Under `Q89` the shared schema takes **all N**, each with its own
> parent rod — which is exactly why **`OI-113` closes** and why `D6`'s *"real loss of fidelity"* is
> repaired rather than accepted.
>
> ✅ **It still describes the SPOOL hop**, where `OI-115`'s narrowing gives the spool a single
> shared-schema face — the lead segment alpha. **Narrow the sentence to the spool; do not delete it.**

#### Two identities, one of them renamed

**`D5` stands.** Its rule — *"Two coil alphas, deliberately, and they are not interchangeable"* — is
**not** reversed. `CoilAlpha` is retained exactly as it is; the only change is that **`SharedCoilNo`
is renamed `CoilNo`**, so the column's name matches what it holds: `proddb..coils.coil_no`.

| | Before | After |
|---|---|---|
| Local identity, customer-facing | `CoilAlpha VARCHAR(30) NOT NULL`, `FW-#####-C##` | **unchanged** |
| Shared-schema identity | `SharedCoilNo VARCHAR(9) NULL` | **`CoilNo VARCHAR(9) NULL`** — renamed only |
| Uniqueness | `UQ_CoilOutput_CoilAlpha` + filtered `UX_CoilOutput_SharedCoilNo` | `UQ_CoilOutput_CoilAlpha` + filtered **`UX_CoilOutput_CoilNo`** |
| `CoilTraceability` FK | → `CoilOutput.CoilAlpha` | **unchanged** |
| Mid-run child | `FW-#####-C##-A` | **unchanged** |

**Why keeping both is the right answer, not merely the conservative one.** An earlier draft proposed
withdrawing `CoilAlpha`, on the grounds that it is not client-specified — `FR-330`'s source column
reads *"Analysis"*, `FR-509` is `[PROPOSED]`, and every `FW-` string in `BaseDocuments/` is a story id
— and that it carries no information `CoilNo` lacks, `D5`'s own example pairing `FW-00421-C01` with
`R00421A`, both derived from rod `R00421`. **Both observations still hold.** What they do not survive
is the consequence:

> **`CoilNo` cannot be `NOT NULL`, so it cannot be the sole identity.** It is nullable **by design**
> — the value does not exist until the cross-database mint succeeds, which is why its index is
> *filtered* and why it is the **retry contract** (`@expectedSharedCoilNo`). Making it the only
> identity, and the `CoilTraceability` FK target, would mean **a `CoilOutput` row could not be created
> until `CommonDB.dbo.GenerateCoilAlpha` returned** — and given **§9 F1** (`coils` may not resolve
> inside CommonDB on the target instance) that turns a reconciliation problem into a
> **coil-completion outage**.
>
> Keeping `CoilAlpha` as a locally-minted `NOT NULL` identity removes the coupling outright: flat wire
> completes the coil on its own data and reconciles to the shared schema afterwards, exactly as it
> does today. **This closes `OQ-N`**, and it is a better answer than that item's own fallback of
> keying `CoilTraceability` on the `CoilOutput.Id` surrogate — no FK moves, and no surrogate leaks
> into the genealogy.

> ⚠ **One cost of the rename, worth stating rather than absorbing.** `SharedCoilNo` was
> self-documenting: the name said *which* of the two identities it was. `CoilNo` beside `CoilAlpha`
> is not — a reader must know that `CoilAlpha` is local and `CoilNo` is the shared face. The
> compensating argument is that `CoilNo` matches `coils.coil_no`, the column it feeds. **Keep the
> comment block on the column**; it is now the only thing that disambiguates the two.

**Owed to a later wave — and it is now a rename, not a redesign:** every occurrence of
`SharedCoilNo` becomes `CoilNo`, including `UX_CoilOutput_SharedCoilNo` → `UX_CoilOutput_CoilNo` and
the `@expectedSharedCoilNo` parameter of `FlatWire_CompleteCoilOnSkid`. **`FR-330`, `FR-509`,
`FR-230`, `BusinessRules.md` §3.3 and `APIs.md`'s `"coilAlpha"` payloads are untouched**, because
`CoilAlpha` survives.

> ### ⚠ The workbook consumes FIFO and names LIFO — it contradicts itself
>
> `GenerateFL2_Optimized` walks `workingIndex` **ascending**, i.e. the order material went *on*, then
> reverses only the *display* through its `For revIndex = alphaPartCount To 1 Step -1` loop. A spool
> unwinds **last on, first off** — geometry, not policy. **It changes the answer, not just the
> labels:**
>
> | Order | Coil 1 | Coil 2 |
> |---|---|---|
> | **FIFO** (what the workbook computes) | 400 `R00001C` + 500 `R00002A` | 900 `R00002A` |
> | **LIFO** (what the spool does) | 900 `R00002A` | 500 `R00002A` + 400 `R00001C` |
>
> Same two coils, same weights — **the weld lands in a different coil**, so the traceability rows, the
> primary rod and the certificate's parentage all differ. **Build to LIFO**, and treat the workbook's
> FL2 stop *composition* as not-to-be-copied even though its stop *sizing* is sound. `OQ-M`.

### 2.6 Footage frames — two, and the rod's share is in pounds

| Frame | Used by | Anchor to run-cumulative |
|---|---|---|
| **spool-local** | `SpoolTraceability.FootageFrom`/`To` | `SpoolProcessing.RunStartFootageFt` ✅ |
| **run-cumulative** | `RodOrderConsumption.StartFootageFt` / `ThresholdFootageFt`, `FlatWireRun.FootageFt` | — |
| *(no rod-local frame)* | the rod's share is `RodWeightFrom`/`To`, **in pounds** | — |

**Why there is no rod-local footage frame.** `SpoolProcessing.RunStartFootageFt` works because spool-local and
run-cumulative feet measure the same material at the same cross-section — a pure offset. **Rod-local
feet would not:** the rod is round wire at the payoff and the counter measures flat output after
drawing and rolling, so the two differ by the elongation. Converting is not an offset, it is a
re-derivation through weight — §2.8 shows the size of it, the same 900 lb being ≈ 11,100 ft at FL1
gauge and ≈ 76,300 ft at FL2, the 7× difference `[DBD §6.6]` records. So the split is held in
**pounds**, and `ThresholdFootageFt` is derived at pairing start. **No anchor column is needed.**

**The two partitions are independent.** A rod's *order* ranges and its *segment* ranges are separate
partitions of the same rod — an order boundary falls where an allocation runs out, a segment boundary
where a spool fills, and neither implies the other. **Their intersection is what §6 joins on**, and it
is why one spool can carry two orders.

### 2.7 Views

| View | Grain |
|---|---|
| `vw_OrderFulfillment` | per order: allocated · consumed · produced · status |
| `vw_OrderRodAttribution` | per (order, rod) |

**Published as views, not service methods.** The API, the reports and the certificate all need the
same number, and a view is the only form all three can read; a service method guarantees a second
implementation in the report layer.

### 2.8 Worked end-to-end examples

> ⚠ **The `CoilAlpha` values in this section are numbered PER SPOOL, and that is wrong. Superseded by [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) §2.1**, which uses the authoritative form. `FW-#####` is the **order** and `C##` the sequence **within that order** — `[REQ]`'s alpha table and the master specification both say so. So `FW-00001-C01` for spool 1 and `FW-00003-C01` for spool 3 should be one running sequence, not a `C01` per spool: on the 40,000 lb run it is a single `C01`…`C45` across twenty-three spools, **not twenty-three separate `C01`s**.
>
> **The `CoilNo` mints below are unaffected and remain correct** — they are the load-bearing half, and they come from `GenerateCoilAlpha`. Only the `CoilAlpha` column is misnumbered. ⚠ **This note used to add that the traces were *"left in place rather than rewritten because the traces are cited line-for-line from the worked-examples document."* That reason no longer holds — the traces below WERE rewritten on 26 Aug 2026**, when FL2 coil parts moved to segment-rooted alphas. **§2.8 now leads and the companion trails.** Three artifacts still carry the superseded `…D`/`…E` coil alphas and are owed an update: [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) §4/§7, its `.html` rendering, and [`AllocationExamplesContent.md`](../MVP-1/ProjectPlan/Tools/AllocationExamplesContent.md) — ⚠ **the last generates the client deliverable `MVP-1/SRS/FlatWire_OrderAllocationExamples.xlsx`, so that workbook is stale until regenerated.** Read the `CoilAlpha` column through this note. Recorded 25 Aug 2026; no register id — it is a documentation defect in a rationale document, not a requirement or schema change.

Both traces use the **shipped run's own numbers** — rod 4,000 lb, spool target 1,800 lb, coil
800–900 lb, alloy 1100 at FL1 `0.110″ × 0.625″` (**0.0809 lb/ft**) and FL2 `0.0160″ × 0.625″`
(**0.0118 lb/ft**). Both factors are from `[DBD §6.6]`; 22,250 ft and 11,100 ft are `TC-167`'s
published figures.

**The registration rule both traces depend on — it replaces the ignore-list rule that stood here until
26 Aug 2026.** Every alpha flat wire mints is written to `proddb..coils`, so `GenerateCoilAlpha`'s own
exclusion sweep sees every sibling and **no mint passes an ignore list**. Both traces below call it
with `''`.

> *Superseded:* *"`GenerateCoilAlpha` sweeps the shared schema but **not `FlatWireDB`**, so every mint
> passes the segment alphas already recorded for that rod in `SpoolTraceability`."* That was true while
> FL1 segment alphas stayed `FlatWireDB`-local. Registering them is what retires the list — and with it
> `F11`'s 500-character cap and `F10`'s 2048 → 500 truncation, neither of which flat wire now meets.
>
> ⛔ **PRECONDITION, and the FL1 rows are wrong without it.** **Nothing writes an FL1 segment alpha to
> `proddb..coils` today** — `50_…CompleteCoilOnSkid.sql` is the only script that writes that table at
> all, and no script touches `SpoolTraceability`. **Until that writer exists a blank list at FL1
> reissues `R00001A` on every spool.** The FL1 calls below are the *design*, not current behaviour.
> ✅ The mechanism itself is verified on live data — a blank mint skips registered children of both a
> six-character root and a seven-character segment (`F14`).

**Two tiers, because the two hops have different parents.** Each mint roots on its own parent and
passes `''`.

| Hop | Roots on | Produces |
|---|---|---|
| **FL1 segment** → `SpoolTraceability.ChildAlpha` | the **rod**, `R00001` | a single trailing letter — `R00001A` |
| **FL2 coil part** → `CoilTraceability.ChildAlpha` | the **source segment alpha**, `R00001A` | a double — `R00001AA` |
| **FL2 coil part, rod-fed** — `SourceSegmentAlpha IS NULL`, i.e. FL1-standalone and FL3-from-rod | the **rod** | a single letter, as FL1 |

**Why rooting on the segment does not run away, where chaining does.** Every coil off one spool roots
on the *same* segment alpha, so the string grows by exactly one letter and then stops:
`R00001A` → `R00001AA`, `R00001AB`, `R00001AC`. That is **fixed** rooting. *Chained* rooting — each
coil rooting on the previous **coil** — gives `R00001AA` → `R00001AAA` → then **`R00001B`**, because
nine characters trips the `LEN = 9` branch and flattens the hierarchy at depth 3 (`F13`, `F14`).
⛔ **Root on the segment; never on the previous coil.**

**The shape therefore carries information, which is new.** A **single** trailing letter is a segment; a
**double** is a coil off that segment. ⚠ **Readable only while a rod needs ≤ 26 segments** — past that
the rod-rooted sweep starts issuing double letters itself and the shape no longer separates them. At
1,800 lb spools that needs 46,800 lb of rod against the 4,000–8,840 lb in play (`OI-97`), so it holds
here; but it is an assumption, and it is **observable in production** —
`GenerateCoilAlpha('HZ3910','')` returns `HZ3910AF` on a root that has used all 26 single letters.
✅ Nothing *collides* when that happens, because everything is registered and the sweep finds a free
string; only readability is lost. The letter *within* a segment is still mint-order, and `SeqNo` still
carries the ordering.

#### Scenario A — no weld: one rod, one spool

Rod `R00001`, 4,000 lb, order `O1`. It fills **three** spools — 1,800 lb into spool 1, 1,800 into
spool 2, and its last 400 into spool 3 — so it mints segments `R00001A`, `R00001B`, `R00001C`.
Spool 1 is traced here.

> **The trace assumes FL1 has finished the rod before FL2 runs spool 1**, which is the normal case:
> spool 1 goes to anneal while FL1 keeps drawing the same rod. It matters, because the coil
> identities below depend on which letters the segments have already taken.

| Step | Call | Result |
|---|---|---|
| Spool 1 completes | `GenerateCoilAlpha('R00001','')` — nothing registered for this rod yet | **`R00001A`** |
| Spool 2 completes | `GenerateCoilAlpha('R00001','')` — **same call**; the sweep finds `R00001A` | **`R00001B`** |
| Spool 3 completes | `GenerateCoilAlpha('R00001','')` — the sweep finds `A` and `B` | **`R00001C`** |

⚠ **All three calls are identical, and the results still differ** — that is the registration rule
doing the work that an accumulating ignore list used to do. **The values are unchanged from the
previous revision**, which passed `'R00001A,R00001B'` by hand; only the mechanism changed.

| `SpoolTraceability` | value |
|---|---|
| `SpoolAlpha` | `SP-00001` *(material identity — the carrier it is wound on is `SP-0001`, and this is `OQ-K` made concrete)* |
| `ChildAlpha` · `RodAlpha` · `SeqNo` | `R00001A` · `R00001` · `1` |
| `SegmentWeightLb` | **1,800.00** |
| `FootageFrom` → `FootageTo` | `0` → `22,250` *(spool-local, FL1 gauge)* |

Lead alpha = `MAX(SeqNo)` = the only row = **`R00001A`**.

Both coils are cut from spool 1, which carries segment **`R00001A`** — so both root on it.

| Coil | `CoilAlpha` | Lead segment | `CoilNo` | Weight | `CoilTraceability` |
|---|---|---|---|---|---|
| 1 | `FW-00001-C01` | `R00001A` | `GenerateCoilAlpha('R00001A','')` → **`R00001AA`** | 900.00 | **1 row** |
| 2 | `FW-00001-C02` | `R00001A` | `GenerateCoilAlpha('R00001A','')` → **`R00001AB`** | 900.00 | **1 row** |

**One exclusion mechanism now, and that is the design.** ⚠ *Superseded: this paragraph described
**two** mechanisms — an ignore list for the segments and the sweep for prior coils — and called the
split "the whole design."* With every alpha registered there is **only the sweep**: coil 2 gets
`R00001AB` because coil 1's `R00001AA` is in `proddb..coils`, by exactly the same mechanism that gave
segment 2 its `B`. **The same call returns a different answer each time, and nothing is passed.**

`R00001A` is not a candidate for either coil, because it is registered too — which is what makes the
blank list safe and is precisely the precondition flagged above.

✅ **Single-parent coils are unaffected by any of this.** Both coils above have one source rod, so each
mints **one** part alpha equal to its `CoilNo` and writes **one** `proddb..coils` row — exactly as
before `Q88`/`Q89`. **Fourteen of the shipped run's twenty-three spools are single-rod**, so this is
the common case, and it is what bounds the change.

> ✅ **The SHAPE now carries meaning — and this reverses what stood here until 26 Aug 2026.**
> `R00001A`/`B`/`C` are segments and `R00001AA`/`AB` are coils, and you can tell which is which by
> the **number of trailing letters**: one for a segment off the rod, two for a coil off that segment.
> A coil alpha also names its parent segment outright — `R00001AB` is a coil off `R00001A`.
>
> ⚠ *Superseded:* *"The letters are mint-order artifacts and carry no meaning … nothing in the strings
> says so … a tidy 'segments get A–C, coils get D–E' reading is an accident of this trace, not a
> rule."* That was true of the flat rod-rooted sequence, where a coil and a segment were the same shape.
>
> **Two things survive it.** The letter *within* a tier is still a mint-order artifact — which coil got
> `AA` and which got `AB` depends on completion order — so **`SeqNo` still carries the ordering** and
> nothing should sort by the string. And the shape is only readable while a rod needs ≤ 26 segments;
> `ChildAlpha` therefore stays **opaque to code** even though it is now legible to a person.

#### Scenario B — welded: two rods, one spool

Spool 3 of the shipped run: `R00001` is down to its last 400 lb and `R00002` is welded in to finish it.

| `SeqNo` | Call | Result | Weight | Spool-local footage |
|---|---|---|---|---|
| 1 | `GenerateCoilAlpha('R00001','')` — the sweep finds `R00001A`, `R00001B` | **`R00001C`** | 400.00 | `0` → `4,950` |
| 2 | `GenerateCoilAlpha('R00002','')` — first segment of a new rod, nothing registered | **`R00002A`** | 1,400.00 | `4,950` → `22,250` |

Spool `SP-00003`, 1,800.00 lb, **two** `SpoolTraceability` rows. Lead = **`R00002A`**. Rendered
`R00001C - R00002A`, which is the workbook's FL1 sheet exactly — **the unified namespace reproduces
the client's own column.** ✅ **And it can no longer diverge.** This used to add *"diverges only where a
coil reached a suffix first"*; coils now take double letters off a segment, so a coil can never consume
a single letter the FL1 sheet expects. The FL1 column matches the client's by construction.

`R00001` is now spent. **`R00002` carries on**, filling spool 4 (1,800 lb → `R00002B`) and spool 5
(800 lb → `R00002C`). ⚠ *This used to end "which is why the coils below start at `D`" — it no longer
applies:* coils take **double** letters off their own segment, so how far the rod's single-letter
sequence has run no longer affects them at all. Spools 4 and 5 are irrelevant to the coil alphas below.

FL2, LIFO:

| Coil | `CoilAlpha` | Lead segment | Part alphas — **one per source SEGMENT, every one written to `proddb..coils`** | Composition | Rows |
|---|---|---|---|---|---|
| 1 | `FW-00003-C01` | `R00002A` | **one part.** `GenerateCoilAlpha('R00002A','')` → **`R00002AA`** | 900 lb, all `R00002A` | **1 row** |
| 2 | `FW-00003-C02` | `R00002A` | ⚠ **two parts, rooted on two different segments.** `GenerateCoilAlpha('R00002A','')` → **`R00002AB`** *(the lead — `R00002AA` is now found by the sweep)*, **and** `GenerateCoilAlpha('R00001C','')` → **`R00001CA`** | 500 lb `R00002A` + **400 lb `R00001C`** | **2 rows** |

✅ **Both letters are now stated, because both are determinate** — and that is a gain in precision, not
a change of style. ⚠ *This paragraph used to say "the second letter is deliberately not stated … so `F`
if nothing else off `R00001` has been minted and later if spool 2's coils have."* Under rod-rooting the
answer genuinely depended on how many other coils that rod had produced. **Rooted on the segment it
does not:** `R00001CA` is the *first* child of segment `R00001C`, and segment `R00001C` is 400 lb
feeding exactly this one coil, so nothing else competes for it.

⚠ **Two parts of one coil are safe here only because they root on DIFFERENT segments.** Both mint
inside one transaction, before either is registered, so the sweep cannot separate them — it is the
different roots that do. Two parts sharing one segment would collide; see `F14`'s residual and
`OQ-S`.

**Coil 2's two rows are the point of the design, and under `Q89` each becomes its own shared record:**

| `RodAlpha` | `ChildAlpha` | `SpoolAlpha` | `FootageFrom` → `FootageTo` | `SegmentWeightLb` | → `proddb..coils` |
|---|---|---|---|---|---|
| `R00002` | `R00002AB` *(lead, off segment `R00002A`)* | `SP-00003` | `0` → `42,400` | 500.00 | **its own row, 500 lb** |
| `R00001` | `R00001CA` *(off segment `R00001C`)* | `SP-00003` | `42,400` → `76,300` | 400.00 | **its own row, 400 lb** |

⚠ **The two weights sum to the coil's 900 lb — they are a split, not a repeat.** Writing the full 900
to both would double-count, and the `C9` smallint guard on `wip_skids` validates per *call*, so it
would not catch it. `ORD023` / **`TC-792`** is the only detector. *(This cited `TC-795` until 26 Aug 2026; `TC-795` asserts genealogy parentage under `FR-568` — the weight-sum test is `TC-792`, `FR-567`.)*

✅ **`coil_gen_history` gets one row per part alpha, each naming its OWN parent rod** — `R00002AB`
under `R00002` and `R00001CA` under `R00001`. That is what **closes `OI-113`**: the guard is per
*child*, so N distinct children pass N independent tests. **If both rows named one parent, `OI-113`
would not have closed.**

⚠ **The parent recorded is the ROD, not the segment, even though the alpha is now rooted on the
segment.** `coil_gen_history` and `coil_link_master_coil` group on `SUBSTRING(coil_no,1,6)`, which is
`R00002` for `R00002AB` and `R00001` for `R00001CA` — so the legacy genealogy still resolves to the rod
and `D5`'s *"the output coils become children of the rod"* is unaffected by segment-rooting. **The
segment parentage lives in `CoilTraceability.SourceSegmentAlpha`**, which is why that column is not made
redundant by the alpha now naming its segment.

Half-open, contiguous, covering the coil exactly (`TC-617`). ✅ **The compound display still renders
from these rows and nothing compound is stored** — for coil 2 it is **`R00002AB - R00001CA`**, joining
the **two part alphas** in unwind order, using the `" - "` separator the client's own analysis reserves
for alphas. ⚠ **It is a JOIN of two generated strings, never a construction** — a renderer that appends
a stop letter is reintroducing the rejected scheme (`Q88`). The certificate reads both parents — and
both supplier heats — from here, **and now from two `proddb..coils` rows as well.**

> ### ✅ The generated strings now match the client's own form — and where they differ, ours is the unique one
>
> Segment-rooting makes `GenerateCoilAlpha` **emit** the shape the client's planner builds by hand.
> Coil 1 is **`R00002AA`**, which is the workbook's stop 1 exactly.
>
> | | Coil 1 | Coil 2 |
> |---|---|---|
> | **Generated here** | `R00002AA` | `R00002AB - R00001CA` |
> | **The workbook's `stopAlphaCounter`** | `R00002AA` | `R00002AB - R00001C`**`B`** |
>
> **They diverge on the second part, and the reason is the whole argument.** The workbook numbers **per
> stop** — every part in stop 2 takes the letter `B` — so `R00001CB` records *which stop* the part
> belongs to. We number **per segment**: `R00001CA` is the *first* child of segment `R00001C`,
> regardless of which stop consumed it. ⚠ **The workbook's form is therefore not a unique key** — that
> is `Q88`'s own objection, and it is why the shipped run contains `R00004AB` with no `R00004AA`
> (§2.4). Ours is unique by construction, because the generator will not reissue.
>
> ⛔ **This narrows `Q88` rather than reversing it, and the distinction is load-bearing:** what
> stays rejected is **building** the string locally — invisible to the sweep, so nothing stops a
> finished coil taking it. What is now adopted is **generating** it. Same shape, opposite guarantee.
> `Q88`'s formal disposition, and the `FlatWire_DDL_05` comments that still say *"NEVER on the
> segment"*, are propagation-scope — see the note at the head of §2.5.

---

## 3. Sequence validation

Rule 5 and `Q73` combine into **one four-tier partition**. `Q73`'s tiers fill in what rule 5 leaves
unordered, and its *"multi-order coils last"* is rule 4's *"last rod of the outgoing order"* read from
the outgoing side — worth stating in one sentence, because reading `Q73` alone makes the
pinned-**first** case look like a violation of it.

```
partition(order.rods):
  pinnedFirst  : PinRole ∈ {PinnedFirst, PinnedBoth}    shared with order n−1
  freeFull     : PinRole = Free, RodKind = Full
  freePartial  : PinRole = Free, RodKind = Partial      Q73 tier 2 — a back-to-stock
  pinnedLast   : PinRole ∈ {PinnedLast, PinnedBoth}     shared with order n+1

legal(order) = pinnedFirst ⧺ perm(freeFull) ⧺ perm(freePartial) ⧺ pinnedLast
|legal|      = |freeFull|! × |freePartial|!
```

`PinnedBoth` is in **both** end sets — an order lying wholly inside one rod has that rod as its only
member, so pinnedFirst and pinnedLast are the same row. **The code must not assume they differ.**

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

Enumeration exists only for display and tests, capped at `|freeFull| + |freePartial| ≤ 7`, otherwise
reported as a count.

**Worked against the client's example.** O1 = {R1A, R1B, R1C} gives pinnedFirst ∅, freeFull
{R1A, R1B}, pinnedLast {R1C} → `2! × 0! = 2`, exactly `R1A→R1B→R1C` and `R1B→R1A→R1C`. O2 = {R1C, R1D}
gives pinnedFirst {R1C}, freeFull {R1D} → `1! = 1`, exactly `R1C→R1D`. Both match the client's stated
answer.

---

## 4. Footage-to-weight conversion

```
interface IFootageWeightConverter
    WeightLb   ToWeight (footageFt, ctx)
    FootageFt  ToFootage(weightLb, ctx)     // computes ThresholdFootageFt
    Factor     Describe (ctx)               // LbPerFtUsed + Basis + Version, for persistence

ctx = { Alloy, GaugeIn, WidthIn, EdgeProfile (Square|Round), Basis, RunId?, FootageFrom?, FootageTo? }
```

**The formula is not missing** — `FR-137` and `[DBD §6.6]` specify it, and `FR-332a` bans a wrong
variant:

```
A = t·w                      square edge
A = t·w − 0.2146·t²          round edge   (rectangle with semicircular ends)
k = 12ρ                      ρ from FlatWireDB..Alloys → united_db..alloys.alloy_density
lb/ft = A × k                1100 @ 0.110″×0.625″ → 0.0809 square / 0.0778 round  (TC-167, TC-409)
```

**Basis preference:** `IntegratedRunReading` (`Σ A(gaugeᵢ,widthᵢ)·k·Δfootageᵢ` — the `[DBD §6.6]`
recommendation, which avoids the ±2.6 % tolerance stack that would otherwise trip `FR-153`'s ±2 % on
a perfectly in-spec coil) → `Measured` → `Nominal` (the FL2-standalone fallback, since FL2 broadcasts
`null`) → `Override`.

Configured under a `FlatWire:Conversion` settings section — one DI-registered interface, one shipped
implementation, config selecting the basis. **Not a pluggable script**; the requirement is that the
arithmetic not be inline, and one interface achieves that.

**Accumulation and granularity.** Running consumption is *not* persisted per tick — `RunReading` is
already the time series. `RodOrderConsumption` writes at **transitions only**: the anchor at start,
the latch at threshold, the latch at acknowledgement, the final at close. **Four writes per pairing.**
The crossing is evaluated **server-side on the footage stream**, the `SpoolWeightMilestone` rule.

> **The direction, stated plainly.** Allocation arrives in **pounds** (planning's unit, and the
> client's planner has no footage at all); the line measures **feet**. The converter bridges them at
> exactly one place. **The stored split point is in pounds** (§2.6); feet appear only where the line
> measures them.

---

## 5. Handoff state machine

**The mechanic first, because every transition depends on it.** A rod planned for two orders is
checked in **once**. When the first order's allocated weight is reached the operator marks that order
complete and **begins the next order on the same rod — no dismount, no remount, no second check-in.**

That fixes three things in the existing schema, each of which reads as a defect without this
paragraph:

| Consequence | Why it follows | What it means |
|---|---|---|
| **One `FlatWireRun` spans both orders** | `FlatWireRun` is *"one row per check-in event"* and `RodCheckin.RunId` is a single `NOT NULL` column — one check-in cannot point at two runs. Closing and reopening at the boundary needs a second `RodCheckin` row, which **is** a second check-in, which rule 7 forbids | The boundary is crossed *inside* a run. Everything keyed on `RunId` — `RunReading`, `SpcCheckpoint`, `RunPauseEvent`, `CoilOutput`, `FlatWireRunDetail` — spans both orders |
| **`FlatWireRun.OrderId` narrows to "the order at check-in"** | It is a scalar `VARCHAR(20) NOT NULL`, and the run now outlives that order | ⚠ **Anything reading it as "the order this run produced" becomes wrong at a boundary.** Per-order truth lives on `RodOrderConsumption`; per-output attribution on `CoilOutput.OrderId`. An existing-reader problem, so a **gap** rather than a new-table concern |
| **Both orders run under one pass schedule; PLC tags pushed once** | `FlatWireRun.PassScheduleId` is also scalar `NOT NULL`, and check-in is when the schedule is acknowledged and the tags pushed. No second check-in ⇒ no second push | The incoming order **must** share the running pass schedule. If planning puts two orders with different gauge/width/edge on one rod, the boundary *cannot* be crossed mounted. `Q70` says same alloy, which is not the same guarantee. **`OQ-A`** |

**States:** `Pending → InProgress → ThresholdReached → Closed`, plus `Voided`.

| From | To | Trigger | Writes |
|---|---|---|---|
| — | `Pending` | validated scan at pre-check-in or check-in | row insert; `AllocationId`, snapshots, `ActualRodSeqNo` |
| `Pending` | `InProgress` | check-in acknowledged **for the first order**; for every later order on the same rod, **the previous pairing's operator acknowledgement is the trigger** — there is no second check-in | `StartFootageFt` (= the outgoing pairing's `EndFootageFt`, so the boundary is one footage value, not two), `ThresholdFootageFt`; the station exclusivity index now holds for this pairing |
| `InProgress` | `ThresholdReached` | **server-side** footage crossing `ThresholdFootageFt` | `ThresholdReachedAt`, `LatchedWeightAtThresholdLb`, `NotificationRaisedAt`; hub `OrderAllocationReached` — durable, idempotent, re-delivered on group re-join |
| `InProgress` | `Closed` | operator acknowledges **before** threshold | `ClosureReason='AcknowledgedEarly'`; `OverrunWeightLb` negative |
| either | `Closed` | rod runs out first | `ClosureReason='RodExhausted'`, `ShortfallWeightLb` |
| either | `Closed` | rod removed mid-run | `ClosureReason='RodAbandoned'`, `RodCheckoutId` (Mode B) |
| `ThresholdReached` | `Closed` | **operator marks the order complete** | acknowledgement stamps, `WeightAtAcknowledgementLb`, `EndFootageFt`, `ConsumedWeightLb`, `LbPerFtUsed`, `ConversionBasis`, `ConverterVersion`; hub `OrderAllocationResolved`. **The station is handed to the next pairing on the same rod, not released** — release happens at checkout |
| `Pending` | `Voided` | re-planning supersedes before start | `ClosureReason='Superseded'` |

**Between `ThresholdReached` and `Closed` the material keeps running** — the line does not stop and the
rod is not dismounted (rule 7). That is why the interval is a state value and not a nullable timestamp
hung off `InProgress`, and it is where the overrun accumulates.

**Two writes must land in one transaction**, or the exclusivity index rejects the handover: the
outgoing pairing's `→ Closed` and the incoming pairing's `→ InProgress`.
`UX_RodOrderConsumption_Station` permits exactly one open pairing per station, so closing and opening
must be atomic — the same single-connection, single-transaction rule `[INT §8.0]` sets for check-in.

**Two hub events** mirroring `[SIG §5.2]`'s events 11 and 12: `OrderAllocationReached` and
`OrderAllocationResolved`. ⚠ **The published event count moves 12 → 14**, and `PP-04` records that the
count also appears in the master specification and `BusinessRules.md` §3.

---

## 6. Allocation and fulfilment

- **Input side** (`RodOrderConsumption`) drives the threshold and the notification.
- **Output side** drives fulfilment: at FL1 the spool pounds via `SpoolTraceability` × `SpoolOrder`;
  at FL2 the coil pounds via `CoilOutput.OrderId` and `CoilTraceability`.

| Order status | Condition |
|---|---|
| `NotStarted` | no consumption row |
| `InProgress` | ≥ 1 row `InProgress` |
| `PendingOperatorConfirmation` | the order's last pairing is `ThresholdReached` |
| `Complete` | all active allocations closed **and** produced ≥ allocated − `FR-153` tolerance |
| `Short` | all closed **and** produced < allocated − tolerance |

> **"Complete" means two different things and the table spans both — say so, or it reads as a
> contradiction.** An order is *consumed* at FL1 (every pairing `Closed`) and *produced* at FL2 (coils
> made and weighed), and `Complete` deliberately requires both. **And FL1 does not wait:** rule 2 is
> scoped to the rod-fed payoff, so the FL1 queue moves to the next order as soon as the operator
> acknowledges, while FL2 is still cutting the previous one's spools. That is intended, not a
> violation of "one order at a time."

```
producedByOrderAndRod(order):
    total = {}                                  -- keyed (order, rod)

    -- FL2: finished coils. The shipping number, and what the certificate states.
    for coil in CoilOutput where OrderId = order and Status = 'COMPLETE':
        for t in CoilTraceability where CoilAlpha = coil.CoilAlpha:
            -- t gives WHICH FEET of this coil came from which rod, via which spool.
            share = (t.FootageTo - t.FootageFrom) / coil.FootageFt
            total[(order, t.RodAlpha)] += coil.NetWeightLb * share
    return total

fulfilment(order):
    allocated = Σ AllocatedWeightLb over RodOrderAllocation
                where OrderNo = order and IsActive = 1
    consumed  = Σ ConsumedWeightLb  over RodOrderConsumption
                where OrderNo = order and State = 'Closed'
    produced  = Σ producedByOrderAndRod(order)
    return { allocated, consumed, produced,
             yieldOnRun = produced / consumed,
             status     = deriveStatus(order, allocated, produced) }
```

Three things this makes explicit:

- **Apportion a coil by footage share, not by counting parents.** A coil with two parents is rarely a
  50/50 split — Scenario B's coil 2 is 500 lb / 400 lb.
- **At FL1 the same shape applies one hop earlier** — spool pounds via `SpoolTraceability` ×
  `SpoolOrder` — and it is the only path for a **stock** order taken out after FL1 or after anneal,
  which never reaches FL2 at all (the three-route set, 20 Aug).
- **Two yield figures, named apart.** `produced / consumed` is yield on metal **run**;
  `produced / allocated` — the workbook's `totalOutput / (rodsUsed × rodWeight)` at plant level — is
  yield on metal **issued**. They differ by the unconsumed remainder, so publishing either as "the"
  yield is wrong. Proposed to `OI-60` / `Q11`; not closed here.

> ⚠ **Gap: the order boundary is lost at the spool hop.** `SpoolOrder` carries `SeqNo` and
> `PlannedWeightLb` but **no positional columns**, so a spool wound across an O1→O2 boundary records
> *that* it carries two orders and not *where the boundary is*. FL2 makes one order at a time and must
> cut there — and cannot compute it. **The fix is a half-open pair in *pounds*** —
> `SpoolWeightFrom` / `SpoolWeightTo`, matching `RodOrderAllocation`'s split rather than
> `SpoolTraceability`'s footage, because a spool crossing an order boundary is the same kind of
> partition as a rod crossing one. ⚠ **Time-sensitive:** `SpoolOrder` was created 22 Aug and nothing
> writes it yet, so today this is two columns in a DDL file — the same argument `G42` used to get
> `SpoolTraceability` built early. Afterwards it is a migration plus a backfill.
>
> ⚠ **And `SpoolOrder`'s stated derivation is now wrong.** Its header says the order set is *"read
> from the shared `planning_routings` rod→order allocation that already resolves a rod's order at
> staging"* — a workaround written **because this document's table did not exist**. With
> `RodOrderAllocation` in place the set is the union of the orders on the rods in `SpoolTraceability`,
> read **locally**, with no shared-schema dependency and no re-resolution. Same `Source='Derived'`
> semantics, better source — and it **removes a shared-schema read** from the FL1 path, which is a
> `D-32` win. Until that lands the shared read is the interim source, so the two must not both be
> live.

---

## 7. Validation rules — `ORD003`+, extending the existing series

| Rule | Trigger | Behaviour |
|---|---|---|
| `ORD003` no order started while another is open at the station | check-in | `409`, backed by `UX_RodOrderConsumption_Station` |
| `ORD004` no rod out of tier order | pre-check-in **and** check-in (`Q73` item 7) | `422`. ⚠ **Hard refusal, not the `Q24` override** — `Q73`'s consequence 1 says the jumped multi-order rod is *"refused, not overridden"* |
| `ORD005` a shared rod may not take a middle position | both | `422` |
| `ORD006` the pinned-last rod must be last | both | `422` |
| `ORD007` no next-order processing before acknowledgement | check-in | `409`. Structurally guaranteed — the acknowledgement *is* the trigger — but kept as a stated rule |
| `ORD008` the selected order must be in the rod's active allocation set | both | `422` — the rod-side mirror of `Q43`'s spool-side membership check |
| `ORD009` a rod's weight ranges must not overlap and must tile the rod | allocation write | **domain invariant** — cross-row, so no `CHECK` expresses it. A trigger is viable, both columns being `NOT NULL`, with `trg_CoilTraceability_NoOverlap` as precedent |
| `ORD010` an order with an allocation has ≥ 1 rod | allocation write | domain invariant |
| `ORD011` overrun beyond a configurable bound | footage stream | **warn / escalate, never stop the line** — stopping mid-rod scraps continuous material |
| `ORD012` an unplanned substitution needs supervisor authorisation | check-in | reuse `OverrideBy`/`At`/`Reason`; PIN never stored |
| `ORD013` a superseded allocation may not be consumed against | check-in | `422` |
| `ORD014` a rod already mounted and running may not be checked in again | check-in | `409`. The boundary is crossed by acknowledgement, so a second scan is a *duplicate*; treating it as a fresh check-in would mint a second `FlatWireRun` and re-push the PLC tags mid-material |
| `ORD015` the incoming order must share the running `PassScheduleId` | acknowledgement | `422` — a **refusal to cross mounted**, not a refusal of the order: the operator is told to check out and re-check-in, because tags cannot be re-pushed without a check-in |
| `ORD016` **a coil's parents must all come from one spool** | coil completion | `422`. **The sheet's own invariant** — `' RULE: A STOP MAY USE MULTIPLE ALPHAS BUT ONLY FROM THE SAME SPOOL'`, enforced in the VBA by breaking out when `SpoolID` changes. A single spool per coil is **correct by design**, not a modelling limit (§9 G-1) |
| `ORD017` **segment weights must sum to the spool weight, and a rod's to the rod weight** | spool completion / rod checkout | `422` within `FR-153`. Also implied by the sheet, where both hold exactly across all 23 spools. Checked at the **closing** transaction, not continuously (§9 G-2) |

---

## 8. Edge cases

| Case | Resolution |
|---|---|
| Shared rod runs short before the outgoing order's weight | outgoing order → `Short`, `ClosureReason='RodExhausted'`, `ShortfallWeightLb`. The incoming order's pinned-first pairing is `Voided` and its next rod becomes first — legal, since pinned-first is optional. Top-up is **`OQ-E`** |
| Operator acknowledges early | permitted; rule 9 makes the acknowledgement authoritative. `AcknowledgedEarly`, negative `OverrunWeightLb`. Where the unconsumed allocation goes is **`OQ-D`** |
| Operator overruns significantly | captured, not prevented (`ORD011`). No bound exists anywhere — `OI-103` is the precedent for an unbounded machine-facing value. **`OQ-C`** |
| Order short after all planned rods consumed | `Short`; needs a substitution or planner action |
| Unplanned rod substituted in | `RodOrderAllocation` with `Source='Substituted'` + supervisor override. Touches `Q24` / `Q25` |
| Rod abandoned mid-order | **`RodCheckout` Mode B, already fully modelled.** Consumption closes `RodAbandoned` with `RodCheckoutId`. No new mechanism |
| Re-planning after processing began | allocations superseded, never mutated; consumption rows carry snapshots — the `PassScheduleSnapshot` / `PlannedSeqno` pattern |
| Leftover material returned to stock | `RodCheckout.RodDisposition` + `Rod.RemainingWeightEstimateLb`; `Q73` tier 2 already calls a partial a back-to-stock |
| Rod shared by three or more orders | **no schema change** — the half-open rod-local **weight** ranges chain, and the middle order is `PinnedBoth` |
| Conversion formula changes after records exist | `LbPerFtUsed` + `ConversionBasis` + `ConverterVersion` per row. **Historical rows are never recomputed** |

---

## 9. Findings on existing artifacts

This design reads `CommonDB.dbo.GenerateCoilAlpha` and the tables built on 22 Aug. Doing so surfaced
findings that are about **delivered artifacts**, not about the design — recorded here because they
change what a reader should trust.

### 9.1 `CommonDB.dbo.GenerateCoilAlpha`

A **scalar UDF**: `(@CoilNo VARCHAR(9), @CoilNoToIgnore VARCHAR(500)) RETURNS VARCHAR(9)`. Blank input
returns **`' '`** — a single space, not `NULL`. It walks `A`…`Z`, then `AA`…`ZZ`, for the first unused
suffix — **702 in total** (`F4`).

> ⚠ **The six-character root and the string the suffix is appended to are TWO DIFFERENT THINGS, and
> conflating them produces a false prediction.** This sentence used to read *"it roots on
> `SUBSTRING(LTRIM(RTRIM(@CoilNo)), 1, 6)` and walks `A`…`Z`, `AA`…`AZ`, `BA`…"*, which reads as though
> the suffix is appended to the six-character root. **It is not.**
>
> - **`@rootCoilNo = SUBSTRING(LTRIM(RTRIM(@CoilNo)), 1, 6)` is used ONLY as the `LIKE` filter** for the
>   exclusion sweep — the 14 `UNION`ed selects, every one `LIKE @rootCoilNo + '%'`.
> - **The stem the letter is appended to is `@CoilNo` VERBATIM:**
>   `SET @CoilAlpha = LTRIM(RTRIM(@CoilNo)) + CHAR(@AlphaTobeAdded)`.
>
> **The one exception is the `IF LEN(LTRIM(RTRIM(@CoilNo))) = 9` branch**, which strips back to the last
> digit and resumes from `ASCII(position 7) + 1`. That branch is the **only** place a sibling comes
> back — see **`F7`**, which describes it correctly — and **`F13`**, which records the measured values.

**The six-character root is why the rod becomes the legacy master coil.** A rod alpha `R#####` is
*exactly* six characters, so `GenerateCoilAlpha('R00421','')` roots on `R00421` and returns `R00421A`
— the same `SUBSTRING(coil_no,1,6)` grouping `coil_link_master_coil` uses, which is what makes `D5`'s
*"the output coils become children of the rod"* work at all. It is a fit, not a coincidence to lean on
blindly: **a rod alpha one character longer would silently make two rods share one root.**

**The sweep, and why it takes no locks.** Fourteen `UNION`ed selects over **twelve objects**, all
`LIKE root + '%'`. Through CommonDB's view layer those live in **four databases** — `united_db`,
`SlitterDB`, `wiplogdb`, `proddb`. **The no-locks design is structural, not sloppy:** locking across
four databases from inside a scalar UDF would need a distributed transaction, and `[ARC §10]` /
`[INT §8.0]` deliberately avoid MSDTC. The race must be closed outside the function — which is what
`@CoilNoToIgnore` and the caller's re-check are for. ⚠ The caller's comment says *"sixteen tables"* —
it is **14 selects over 12 objects**, and the figure appears twice.

**The existing caller handles this well, and that is worth stating so nobody simplifies it.**
`FlatWire_CompleteCoilOnSkid` guards the blank/`NULL` return (`THROW 51010`), re-checks the alpha
against `proddb..coils` under `UPDLOCK, HOLDLOCK` **inside** the transaction (`THROW 51011`), and
carries `@expectedSharedCoilNo` so a retry cannot mint a second coil.

**The object map.** Seven objects share this job. ⚠ **Read from the OLDER of the two `ual-database`
copies, and the figures below do not describe `Second-Branch`.** There, `CommonDB`'s function is
**190 lines** and `PlanningDB`'s **187** (not 199 / 196), and the three one-line pass-through
**functions have been replaced by SYNONYMS** — so `SlitterDB`'s *"two hops"* and the
`SET QUOTED_IDENTIFIER OFF` note describe the old copy only. ⚠ **The claim that *"only the first is
named anywhere in the flat wire artifacts"* is also no longer true**: `PlanningDB`'s fork and
`GetCoilAlpha` are both named in this section and in `OI-130`. Verified exhaustively — no copy exists
outside `ual-database`.

| Object | Kind | Resolves to |
|---|---|---|
| **`CommonDB.dbo.GenerateCoilAlpha`** | function, 199 lines | **the real implementation** — what flat wire calls |
| `PlanningDB.dbo.GenerateCoilAlpha` | function, 196 lines | **a second, divergent implementation** (F3) |
| `united_db.dbo.GenerateCoilAlpha` | function, 1 line | → CommonDB |
| `PackingDB.dbo.GenerateCoilAlpha` | function, 1 line | → CommonDB |
| `SlitterDB.dbo.GenerateCoilAlpha` | function, 1 line | → `united_db` → CommonDB (**two hops**) |
| `united_db.dbo.Common_GenerateCoilAlpha` | **procedure** | → `united_db` fn → CommonDB (**three hops**), narrowing the ignore list to 200 (F11) |
| `PlanningDB.dbo.GetCoilAlpha` | **procedure**, batch | loops **PlanningDB's** fn (F10) |

**Consumers:** roughly fourteen stored procedures across five databases (ten of them
`SlitterInterface_*`), and **three** application surfaces — a `GenerateCoilAlphaQuery` handler in
`ual-api`'s Planning domain, `UAL.Common/GlobalFunction/CommonData.cs` in **both** the 2.0 and 4.8
trees of `ual-dot-net`, and **`Common.API`**'s `GenerateCoilAlphaForScrapWeightCommand`
(`CommonController` → MediatR → `IContextRepository` → `Common_GenerateNewCoilAlphaForScrapWeight`).
That is the blast radius which makes *"add `FlatWireDB` to the sweep"* a non-starter — the class of
change `D-32` exists to prevent.

> ⚠ **"Seven objects" counts the objects *named* `GenerateCoilAlpha` or `GetCoilAlpha`. It is not a
> census of everything that mints an alpha** — see **F12**.

`SlitterDB`'s wrapper and `Common_GenerateCoilAlpha` are built under **`SET QUOTED_IDENTIFIER OFF`**
where every other copy uses `ON`.

| | Finding |
|---|---|
| **F1** | ✅ **Resolved 22 Aug 2026 against the live instance — and the answer inverts the finding.** `coils` **is** a real object in CommonDB: a `USER_TABLE` with 1,710 rows. More than that, **`proddb..coils` is a SYNONYM whose base object is `[CommonDB]..[coils]`** — so the table `GenerateCoilAlpha` sweeps via its unqualified `FROM coils` is **the very table** `FlatWire_CompleteCoilOnSkid` writes finished coils into. The sweep sees flat wire's own writes, and there is **no runtime risk**. ⚠ **Two things survive the correction.** The table is genuinely **unscripted in `ual-database`**, so the repository could not answer this and still cannot — a scripting gap, not a defect. And `united_db..coils` is a **different** real table (2,421 rows), so an unqualified `coils` means different things in different databases; CommonDB's copy happens to resolve correctly, and PlanningDB's qualifies it explicitly. **The original finding is retained below because it was right about the scripts** — which is what a reader of the repo has |
| **F3** | ⚠ **The two implementations sweep different planning tables.** CommonDB reads the snake_case `planning_*` mirrors in `united_db`; PlanningDB reads its own PascalCase `PlanningMfgSalesOrderRef` / `PlanningCoilMillProcessing` / `PlanningCoilSlitterProcessing`. **Neither covers both**, so an alpha reserved in the modern planning module is invisible to the function flat wire calls ⚠ **UPDATE 26 Aug 2026 — this finding STANDS as a warning; it did NOT become the design.** A cutover to PlanningDB's fork was evaluated on 26 Aug and **rejected**: `Q57` stands and minting stays on `CommonDB`. The disjoint coverage described here is one reason — and two more were found: the two functions read **different `coils` objects** (`CommonDB.dbo.coils` bare vs `proddb..coils` three-part), and PlanningDB's copy **filters the wrong column on two of fourteen branches** (`OI-130`) |
| **F4** | **Suffix exhaustion is an infinite loop, not an error.** Past all 702 suffixes the overflow wraps `Z`→`A` and re-tries a taken alpha forever; a UDF cannot `RAISERROR`, so it spins holding a connection. **Not reachable at flat wire volumes** — ~9 per rod — but real and silent, and segments and coils now share the budget ⚠ **UPDATE 26 Aug 2026 — the budget is now TIERED, which changes the arithmetic rather than the finding.** *(It read: "shared four ways — segments, coil parts, coils and the scrap path — and no longer independent of N".)* Segment-rooting splits it: a rod draws **26** single letters for its segments, and **each segment carries its own 26** two-letter children for coils. Against ~3 segments and ~2 coils per segment that is enormous headroom, and coil counts no longer draw on the rod's own budget at all. ⚠ **The scrap path still draws on the rod's 26**, being rod-rooted. **The infinite-loop behaviour on exhaustion is unchanged** and is still the reason this is a finding rather than a footnote |
| **F5** | **`WITH(NOLOCK)` is on twelve of the fourteen reads and absent from `wip_log_view` and `coils`** — the two that matter most. A dirty read on a *uniqueness* check is backwards: it can miss a just-inserted sibling as well as see a rolled-back one |
| **F6** | **`CRM_Coils_Weight_Info` filters on `coil_no` but selects `new_coil_alpha`** — the only branch whose filtered and selected columns differ. Plausibly deliberate for a renamed coil; worth confirming rather than asserting |
| **F7** | **The 9-character input branch keys on character position 7**, not on parsing the suffix. It recovers through the outer loop, but the behaviour is positional and fragile |
| **F8** | **It can never be inlined.** A multi-statement body with a table variable and `WHILE` loops is ineligible for SQL Server 2019+ scalar UDF inlining, so every call is interpreted and runs 14 `LIKE`-scans across four databases. Fine one-at-a-time inside a transaction; **must never appear in a set-based query** |
| **F9** | **The namespace collision this design resolves.** `GenerateCoilAlpha('R00001','')` returns `R00001A`, and `FlatWireDB` is not swept — so a local FL1 counter would hand the same string to a spool segment and to a finished coil. Nothing breaks in the database; the collision is **semantic**, and lands on the genealogy and the certificate. Resolved by minting both through the one function (§2.4) |
| **F10** | **`GetCoilAlpha` already implements the batch loop FL1 needs — on the wrong side of F3.** It takes `@count`, loops, and accumulates into `@coilNosToIgnore` with `CONCAT_WS`. But line 119 calls `dbo.GenerateCoilAlpha` unqualified *inside PlanningDB*. **Cite it as the reference loop; do not call it** ⛔ **UPDATE 26 Aug 2026 — the caveat STANDS, and FL1's batch loop is owed.** A cutover to PlanningDB would have made this callable; that cutover was **rejected**, so `GetCoilAlpha` remains uncallable and the `@count`-driven loop with a `CONCAT_WS` accumulator **must be written**. ⚠ **And it is worse than `F11` records:** it pre-seeds `@coilNosUsed VARCHAR(2048)` into `@coilNosToIgnore VARCHAR(500)`, dropping up to **1,548 characters**, and mid-token truncation leaves a partial coil number that never matches ⚠ **UPDATE 26 Aug 2026 — MOOT for flat wire.** No accumulator is built: every mint passes `''` and the sweep does the exclusion (§2.4 consequence 1, `F14`). The 2048 → 500 pre-seed and the `@count` loop are hazards of a design flat wire no longer has. ⚠ **One case would revive it** — a mint of several alphas inside ONE transaction sharing a root, since uncommitted rows are not swept (`OQ-S`) |
| **F11** | **The legacy path narrows the ignore list 500 → 200.** `Common_GenerateCoilAlpha`'s parameter is `VARCHAR(200)`; truncating an *exclusion* list means re-issuing an alpha. Irrelevant at flat wire's ~3 segments, but flat wire's own accumulator must respect the 500 ceiling ⚠ **UPDATE 26 Aug 2026 — understated, then MOOT.** The 500 → 200 narrowing is real and the sharper hazard is `GetCoilAlpha`'s **2048 → 500** pre-seed (`F10`) — but **flat wire no longer builds an accumulator at all**, so neither cap binds it. Retained because the legacy path still has them |
| **F12** | ✅ **Resolved 22 Aug 2026 — and it found a real residual.** The scrap-weight path exists on the live instance and **does call `GenerateCoilAlpha`**, so it draws from the same root namespace *through the same uniqueness sweep* — which means it cannot collide with anything already in the shared schema. **But it does not and cannot pass flat wire's ignore list.** FL1 segment alphas live only in `FlatWireDB`, outside the sweep, so a scrap event on a rod FL1 is actively segmenting can be handed an alpha that a spool segment already holds. ⚠ **This is the limit of the `F9` guarantee:** one namespace protects flat wire's **two** paths from each other, and cannot protect against a **third-party minter that does not know `FlatWireDB` exists**. Recorded as **`Q59`**; the 702-suffix budget is now shared three ways, which is still far from the limit but makes the *“letters are mint-order artifacts”* rule load-bearing rather than merely tidy ⛔ **UPDATE 26 Aug 2026 — this finding STANDS UNCHANGED, and two extensions to it are withdrawn.** `OI-128` extended it to FL2 **coil parts**; `Q89` puts every coil part alpha into the shared schema, so they **are** swept and **`OI-128` closes**. A disjoint-sweep extension died with the rejected cutover. ✅ **What remains is exactly the original: FL1 segment alphas live only in `FlatWireDB`, and a third-party minter can still reissue one** (`Q59`) ✅ **UPDATE 26 Aug 2026 — `Q59` CLOSES, conditionally on the FL1 writer.** This finding's entire mechanism was that FL1 segment alphas are **invisible to the sweep**. The 26 Aug design registers every segment alpha in `proddb..coils` (§2.4, §2.8), so they become visible — and a third-party minter, which sweeps but cannot read our ignore list, is exactly the caller that registration protects. ⚠ **Conditional, not done: the FL1 writer does not exist yet** (`OQ-T`), so until it ships the exposure is unchanged. The register edit closing `Q59` is propagation-scope |
| **F13** | ✅ **Measured 26 Aug 2026 against the live function, because a false claim had been derived from the prose above.** `GenerateCoilAlpha('R00002','')` → **`R00002A`**; `GenerateCoilAlpha('R00002A','')` → **`R00002AA`** — ⚠ **a CHILD, not a sibling**; `GenerateCoilAlpha('R00002A','R00002AA')` → **`R00002AB`**; `GenerateCoilAlpha('R00002AA','')` → **`R00002AAA`**; `GenerateCoilAlpha('R00002AAA','')` → **`R00002B`** — the `LEN = 9` branch, and the **only** sibling case. Two consequences worth keeping: **(1)** `R00002AA` is *also* what the rod-rooted sequence returns at **suffix 27**, so a segment-rooted scheme is not a second namespace — it **collides** with the rod-rooted one on the same string; **(2)** depth **wraps** — `R00002AAA` is nine characters, so the next generation returns `R00002B`, a *sibling* of the seven-character segment, **silently flattening the hierarchy at depth 3**. ⚠ **Anything claiming a seven-character input returns a sibling, or that a seven-character parent cannot have children, is wrong** ⚠ **UPDATE 26 Aug 2026 — consequence (1) is no longer an objection, and consequence (2) still is.** FL2 coil parts now DO root on the segment (§2.8), so the suffix-27 collision this finding warns of is real but **unreachable**: it needs 27 segments off one rod, i.e. 46,800 lb at 1,800 lb spools against 4,000–8,840 lb (`OI-97`). Past that point nothing collides either — everything is registered, so the sweep finds a free string — **only the shape stops being readable.** It is a readability bound, not a correctness one. Consequence (2), the depth-3 wrap, is exactly why rooting is **fixed** on the segment and never **chained** on the previous coil |
| **F14** | ✅ **Measured 26 Aug 2026, and it narrows what `@CoilNoToIgnore` is FOR.** The question that prompted it: *if every coil alpha is inserted into `coils`, and the sweep reads `coils`, how can a duplicate arise?* **It cannot — between coils.** `coils` is the **7th of the 14 `UNION`ed selects** and is one of only **two read WITHOUT `NOLOCK`** (`F5`), so any alpha **committed** there is excluded unaided. §2.8 already depends on this: coil 2 reaches `R00001E` because the sweep found `R00001D`, *not* because the ignore list excluded it. ⚠ **So the ignore list has exactly ONE job: FL1 segment alphas** — the only flat wire alphas that never reach the shared schema. Verified: **no script in `Database/Scripts/` references `SpoolTraceability` at all**, and `50_…CompleteCoilOnSkid.sql` is the **only** script that writes `coils`. Coil-to-coil exclusion belongs to the sweep; the list covers `FlatWireDB` and nothing else. ⛔ **And PARENT-ALPHA ROOTING IS UNAVAILABLE IN BOTH IMPLEMENTATIONS.** Chained from `R00001` with a blank ignore list, ten generations, `CommonDB` and `PlanningDB` returned **identical** values — `A`, `AA`, `AAA`, **`B`**, `BA`, `BAA`, `C`, … a **period-3 cycle**. It **wraps at generation 4**: `R00001AAA` is nine characters, so the next return is `R00001B`, a *sibling* of generation 1 — the string stops encoding parentage at **depth 3**, which is the depth a rod actually reaches at ~3 spools. The cause is structural in both: `RETURNS VARCHAR(9)` plus the same position-7 branch (`CommonDB` line 124, `PlanningDB` line 122 — identical but for the variable name, `@CoilNo` vs `@parentCoilNo`). Every 7-character member also **collides with the rod-rooted namespace** (`R00001B`/`C`/`D` are rod-rooted suffixes 2/3/4; `R00001AA` is suffix 27), and the per-rod budget **collapses 702 → 78** (26 letters × 3 depths, from the measured cycle and the `WHILE(@AlphaTobeAdded <= 90)` guard). ⚠ **`PlanningDB` also has NO `EXECUTE` grant** — `CommonDB` grants `public`, `PlanningDB` grants nobody — so `ua_user` could not call the fork regardless, which confirms `F3` independently of `F3`'s own reasons. ✅ **Parentage has a home in `CoilTraceability.SourceSegmentAlpha`** (`I6` / `ORD022` / `TC-794`). *(Suffix exhaustion past `Z` deliberately NOT probed — `F4` documents it as an infinite loop in a UDF, and spinning a connection on a shared instance is not worth the confirmation.)*<br><br>⚠ **UPDATE 26 Aug 2026 — two of this finding's conclusions are superseded and one is strengthened. Read this before quoting it against §2.8.** **(1) "Parent-alpha rooting is unavailable in both implementations" applies to CHAINED rooting only** — each generation rooting on the previous *result*, which is what was measured and which wraps at depth 3. **FIXED rooting is a different scheme and it works:** every coil off one spool roots on the *same* segment alpha, so the string gains exactly one letter and stops — `R00001A` → `R00001AA`, `R00001AB`, `R00001AC`. Measured, and adopted for FL2 in §2.8. **(2) "Parentage does not belong in the string" is withdrawn** — segment-rooting puts it there deliberately, and `SourceSegmentAlpha` remains the *queryable* copy rather than a duplicate of a lossy one. **(3) The ignore list's one job ENDS with registration** — the finding's core point stands and is now the reason the parameter disappears: the list existed solely because FL1 segment alphas were unswept, so registering them retires it. ✅ **Verified on live registered data, blank list, no writes:** `('HT7031A','')` → **`HT7031AC`** (skipping registered `HT7031AB`), `('HZ3910C','')` → **`HZ3910CJ`**, `('HT7031','')` → **`HT7031E`** — the sweep excludes registered children of both a seven-character segment and a six-character root. ⚠ **`HT7031AA` is absent from `coils` yet still excluded**, so the sweep reaches into the other 13 objects: registering in `coils` is **sufficient, not the boundary**.<br><br>⛔ **RESIDUAL — the one way this design can still reissue a string.** The sweep is authoritative only for **committed** rows. If two parts of a single coil ever root on the **same** segment, both mint blank inside one transaction before either is registered, and both get the same alpha. `CoilTraceability`'s own comment concedes the precondition — *"nothing yet forbids one rod contributing two segments to one spool"* — and `SourceSegmentAlpha` exists precisely because `(RodAlpha, SpoolAlpha)` does not always imply the segment. §2.8 Scenario B is safe only because its two parts root on **different** segments. Tracked as **`OQ-S`** |

### 9.2 Two corrections owed to delivered artifacts

**G-1 · `CoilTraceability`'s header justifies its design on a case that cannot happen.** It reads
*"`CoilOutput.SpoolAlpha` would be wrong the moment a spool runs out mid-coil and the next is
mounted."* **A coil cannot span two spools.** Welding is an **FL1** operation — Bob, 20 Aug: *"we're
welding at the FL1 side, but we're cutting and re-going again at the FL2 side"* — and `Q17` fixed FL2
check-in as **exclusive**, one spool on the line at a time. With no weld and no second spool there is
nothing to join the material to, which is why the workbook breaks its loop when `SpoolID` changes.

The conclusion is still right for a **different** reason: `CoilTraceability` needs row granularity for
**rods**, not spools — Scenario B's coil 2 has two rod parents through one spool. **Keep the column,
fix the justification.** A wrong rationale on a correct design is what invites a bad
"simplification".

**G-2 · `ORD017` must be checked at the closing transaction, not continuously.** A rod's segments
accumulate over days across several spool completions, so for most of a rod's life the sums
legitimately do **not** balance. A trigger would either pass on an incomplete set — enforcing nothing
— or block a normal partial state. Verify at **spool completion** (segments = spool weight) and **rod
checkout** (segments = rod net weight, within `FR-153`). It catches a mis-split at the transaction
that caused it rather than at the certificate.

### 9.3 Two schema documents are stale

`FlatWireSchema_Lookup.md` documents seven lookup tables where `FlatWire_DDL_01_Lookup.sql` has eight
(`Spool` is missing), and `FlatWireSchema_Materials.md` / `_Runs.md` are missing
`SpoolTraceability`, `SpoolOrder` and `SpoolStaging`. All four tables landed 22 Aug and were never
written up — which is also how `SpoolConfiguration` comes to look like the home for the fixed spool
list when it is a one-row size class and `Spool` holds the 45 articles.

---

## 10. Open questions

`OQ-A`…`OQ-T` locally. A decided item keeps its text and is never deleted, per the register's own rule.

⚠ **Where an `OQ` promotes to depends on WHO answers it, and this line used to say only `Q48`+.**
`OQ-A`–`OQ-N` became **`Q48`–`Q58`** because they are questions for the client — their owners are
Tim O., Planning, Srikanth and Shannon R. **An `OQ` that is ours to answer does not become a `Q##` at
all:** internal design calls, data defects and build gaps go to the master specification's `OI-##`
register (and `Development/GapsRegister.md` if they block a phase), because `Q##` feeds the client
questions workbook and every row there needs client-facing prose. That is why `Q91`–`Q93` were
withdrawn on 26 Aug 2026 and re-homed as `OI-133`–`OI-135`.

**Applied 26 Aug 2026:** **`OQ-S`** → **`OI-137`** and **`OQ-T`** → **`OI-138`** + gap **`G54`** —
both internal, neither a client question.

| | Question |
|---|---|
| **`OQ-A`** | **Can planning put two orders with *different* pass schedules on one rod?** If so, that boundary cannot be crossed mounted (`ORD015`) and rule 7 does not hold for it — the rod must be checked out and re-checked-in so the tags can be re-pushed. `Q70` says the two orders share an alloy; alloy is not gauge, width or edge. **The highest-value question here** |
| **`OQ-B`** | `Q73` item 6's **no-weld branch** — does multi-order-last hold without a weld? Two readings on the 6 Aug recording, **no `OI-##` mirror**, so `Q73`'s entry is the only record it is open |
| **`OQ-C`** | The overrun bound for `ORD011` — warn at what, escalate at what, and to whom? |
| **`OQ-D`** | On an early acknowledgement, does the unconsumed allocation roll to the next order or back to stock? |
| **`OQ-E`** | When a shared rod exhausts before the outgoing order is satisfied, may an unplanned rod top it up, or does the order stay short? |
| **`OQ-F`** | Where does the order boundary live at the spool hop? (§6) |
| **`OQ-G`** | Is fulfilment **consumed** or **produced** pounds — and which does the welding-wire certificate state? |
| **`OQ-H`** | `Q10` / `OI-45` dimensional basis — inherited, and it gates every weight here |
| **`OQ-I`** | Does the order acknowledgement also close the FL1 spool, or may a spool span the boundary? Interacts with `SpoolOrder`, `D5` and the finite carrier pool |
| **`OQ-J`** | Which rod weight is real — 4,000 (workbook) / ~5,500 (transcript) / 8,690–8,840 (contracts)? `OI-97`. The allocation arithmetic's input |
| **`OQ-K`** | **Should the carrier prefix differ from the material one?** Carriers are `SP-0001`…`SP-0045` (four digits); material spools are `SP-#####` (five, e.g. `SP-00021`). One digit apart on the same prefix, for the two objects `Spool` exists to keep apart. Nothing can mis-resolve in the database — they never share a column — so the exposure is a person reading one for the other on a screen, a log line or a label. `SC-0001` removes it outright. **Build to `SP-0001`…`SP-0045` meanwhile** |
| ✅ ~~**`OQ-Q`**~~ | **Decided 26 Aug 2026 as `Q88` — two alphas *per se*.** The client's `segmentAlpha + AlphaLetter(stopIndex)` form is **not adopted, stored or rendered**; every alpha comes from `CommonDB.dbo.GenerateCoilAlpha` and nothing else |
| ✅ ~~**`OQ-R`**~~ | **Decided 26 Aug 2026 as `Q89` — EVERY part alpha reaches `proddb..coils`**, weights split from `SegmentWeightLb`. **`OI-113` and `OI-128` close with it**; `FR-512` is deleted and Phase 9's shared write-back reopens |
| **`OQ-M`** | **Does a spool unwind last-on-first-off?** ⚠ **And, since 26 Aug 2026, how MANY alphas each coil carries** — under `Q89` a two-parent coil writes two `proddb..coils` rows and a one-parent coil writes one, so the unwind direction sets the **cardinality** of the shared write, not only its parentage. It decides **which coil the weld lands in**, and so each coil's traceability rows, primary rod and certificate parentage. Geometry says LIFO; the workbook consumes FIFO while naming LIFO, so it is no evidence either way. `Q45` is the same question at the label. **Build to LIFO meanwhile** |
| ~~**`OQ-N`**~~ | ✅ **Decided 22 Aug 2026 — keep `CoilAlpha`, rename `SharedCoilNo` → `CoilNo`.** The question was whether a `CoilOutput` row must wait for `CommonDB.dbo.GenerateCoilAlpha`. **It must not, and it need not:** `CoilAlpha` is retained as the locally-minted `NOT NULL` identity, so `CoilNo` stays nullable, the `CoilTraceability` FK does not move, and coil completion is never coupled to a cross-database call. `D5` stands (§2.5) |
| ~~**`OQ-O`**~~ | ✅ **Decided 22 Aug 2026 — yes, it shares the namespace.** Verified on the live instance: `united_db.dbo.Common_GenerateNewCoilAlphaForScrapWeight` exists and **calls `GenerateCoilAlpha`**. Because it goes through the same sweep it cannot collide with the shared schema — but it cannot see `FlatWireDB`, which is the residual now tracked as `OQ-P` / **`Q59`** |
| **`OQ-P`** | **A third-party minter can collide with an FL1 segment alpha, and nothing in the sweep prevents it.** FL1 segment alphas live only in `FlatWireDB`; the scrap-weight path (and any other `GenerateCoilAlpha` caller) passes its own ignore list, not ours. So a scrap event on a rod FL1 is mid-way through segmenting can be issued an alpha a spool segment already holds. **Options:** accept the risk (narrow — it needs a scrap event on an actively-segmented rod); or make the segment alphas visible to the sweep, which means writing them into the shared schema and therefore touches `D-32` and **`OI-115`**. **Recommendation: accept and monitor**, because the fix costs a new shared-schema writer and the collision is detectable at the point of use. Tracked as **`Q59`** ✅ **UPDATE 26 Aug 2026 — this resolves the way the second option describes, and the cost is now being paid for other reasons.** The 26 Aug design registers **every** alpha in `proddb..coils`, segments included, precisely so the ignore list can go — which makes FL1 segment alphas visible to the sweep and removes this exposure as a side effect. So *"accept and monitor"* is superseded by *"fixed by the registration rule"*. ⚠ **Conditional on `OQ-T`**: the FL1 writer does not exist yet, so the exposure stands until it ships. ⚠ **And `D-32` is NOT breached** — writing a row through existing columns is not a schema change (`CLAUDE.md` lists the shared writes that already do this); what `OQ-T` must settle is which `coil_status` value the row carries |
| ~~**`OQ-L`**~~ | ✅ **Decided 22 Aug 2026 — one namespace, minted through `GenerateCoilAlpha`** (F9) |
| **`OQ-S`** | **Can two parts of one coil root on the same segment — and if so, what stops them colliding?** Registration makes the sweep authoritative only for **committed** rows, so two parts minting blank inside one transaction off the **same** segment both get the same alpha. §2.8 Scenario B is safe only because its parts root on *different* segments. `CoilTraceability`'s comment concedes the precondition — *"nothing yet forbids one rod contributing two segments to one spool"* — and `SourceSegmentAlpha` exists because `(RodAlpha, SpoolAlpha)` does not always imply the segment. **This is the only remaining way the design reissues a string.** *Options:* forbid two parts of one coil sharing a segment (a constraint, and probably true physically under LIFO); or keep a per-transaction accumulator for that one case. **Recommendation: the constraint** — a coil's footage over one segment is contiguous under LIFO, so two rows off one segment should not arise. `F14` |
| **`OQ-T`** | ⛔ **Nothing writes an FL1 segment alpha to `proddb..coils`, and every blank-list mint in §2.8's FL1 rows assumes it does.** `50_…CompleteCoilOnSkid.sql` is the only script that writes that table; no script touches `SpoolTraceability`. **Until the writer ships, a blank list at FL1 reissues `R00001A` on every spool** — the FL1 traces are the design, not current behaviour. Four sub-questions the writer must answer: **(a)** which `coil_status` a segment row carries — `D-32` bars a new shared value (`INFLAT` is `FlatWireDB`-local) and the coil row's own `ONSKID` is already open as `Q35`; **(b)** **tonnage multiplication** — rod 4,000 + segments 4,000 + coils 4,000 all group flat under the six-character root via `coil_link_master_coil`, so a report summing children triple-counts; **(c)** **atomicity** — mint and insert in one transaction or a crash leaks a name, the `THROW 51011` pattern; **(d)** whether **`OI-115`**'s narrowing of the spool to one shared face is still needed once every segment has its own shared identity, the way `Q89` retired `D6`'s narrowing at the coil hop. **The highest-priority item in this list** — it gates the whole scheme |

---

## Related

| Document | Why |
|---|---|
| [`RodOrderAllocation_DesignPlan.md`](RodOrderAllocation_DesignPlan.md) | The plan this was built to — carries the verification steps and the decisions taken while writing |
| [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) | Six worked traces — {1 order, 1 rod} × {1 order, *n* rods} × {*n* orders, *n* rods}, welded and not, at FL1 and FL2. §2.8's Scenario A and Scenario B are its §4 and §7, reproduced exactly and given their order dimension |
| [`FL Alphas Plus.xlsm`](../BaseDocuments/FL%20Alphas%20Plus.xlsm) · [analysis](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) | The client's planner and the recovered VBA |
| [`ClientCall_2026-08-20_SyncPlan.md`](../BaseDocuments/ClientCall_2026-08-20_SyncPlan.md) | `D2` (many rods, many orders), `D5`–`D9` |
| `Analysis/FlatWireDecidedQuestions.md` | `Q70` (a rod may carry many orders), `Q73` (the consumption sequence) |
| `MVP-1/ProjectPlan/Database/DatabaseDesign.md` §6.6 | The lb/ft formula and the density source |
| `MVP-1/ProjectPlan/Database/Schema/SQL/` | `03_Materials` (`SpoolTraceability`, `SpoolOrder`), `05_QualityOutput` (`CoilOutput`, `CoilTraceability`) |
