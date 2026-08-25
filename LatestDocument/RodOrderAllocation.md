# Rod ↔ Order Allocation, Sequencing and Handoff

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 25, 2026 — §2.8 badged — its `CoilAlpha` values are numbered per spool where `FW-#####` is the **order**; the `CoilNo` mints are unaffected *(previously August 24, 2026)*
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
-- MINTED BY CommonDB.dbo.GenerateCoilAlpha(rodAlpha, @ignoreList), NOT by
-- a local per-rod counter. FL1 segment alphas and FL2 coil identities are
-- the same strings off the same six-character root, and that function
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
ALTER TABLE [dbo].[SpoolTraceability] ADD [ChildAlpha] VARCHAR(20) NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SpoolTraceability_ChildAlpha]
    ON [dbo].[SpoolTraceability] ([ChildAlpha]) WHERE [ChildAlpha] IS NOT NULL;
GO
```

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
> spool takes the *third* piece of one rod and the *first* of the next. The third counter is FL2's,
> and the analysis flags it as **not a unique key**: every part within one stop gets the same letter,
> which is why `R00004AB` exists in the shipped run with no `R00004AA`.

**Five consequences of minting through the shared function.**

| | Consequence |
|---|---|
| 1 | **The ignore list is every prior segment alpha for that rod**, read from `SpoolTraceability` — not just this transaction's. `FlatWireDB` is outside the sweep, so a second spool off the same rod would otherwise be handed the same alpha (§2.8 Scenario A). `GetCoilAlpha` builds its used-list this way (§9 F10); stay inside `VARCHAR(500)` (§9 F11) |
| 2 | **Replicate the caller's two guards** — the `' '` blank return (`THROW 51010`) and the `UPDLOCK, HOLDLOCK` re-check (`THROW 51011`) |
| 3 | **FL1 spool completion becomes a cross-database caller.** Same instance, local transaction manager, no MSDTC — but **it can no longer be tested on LocalDB**, which has no `CommonDB`. `CLAUDE.md` carries that warning for check-in; it now applies here |
| 4 | **§9 F1 escalates** — the unresolved `coils` reference now gates FL1 as well as Phase 9 |
| 5 | **The 702-suffix budget is shared** between segments and coils off one rod. Nowhere near the limit at ~3 + ~6 per rod, but no longer independent |

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
`GenerateCoilAlpha('R00002', …)` returns `R00002B` — **a sibling of its own child.** `R00002A` would
be a segment *on* the spool and `R00002B` the spool *containing* it, both children of root `R00002` at
the same level of the legacy tree. Not avoidable by care; it is what one namespace guarantees. **Do
not mint a container's identifier from its contents' namespace.**

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

The workbook gives a stop drawing on two segments a **compound** identity — `R00002AA - R00001CA`.
**That cannot be an identifier here, on three counts:** it is **19 characters** against
`coil_no`'s `char(9)`; its stop letter is shared by every part in the stop, so it **is not unique**;
and `CoilOutput.CoilAlpha` is a unique scalar. So the compound string is a **rendering**. Each coil
carries **two** identities and **N** traceability rows:

| What | Value |
|---|---|
| Local identity, customer-facing | `FW-#####-C##`, minted locally → `CoilOutput.CoilAlpha` |
| Shared-schema identity | `GenerateCoilAlpha(primaryRod, @ignoreList)` → `VARCHAR(9)` → **`CoilOutput.CoilNo`** *(renamed from `SharedCoilNo`)* |
| Every parent | one `CoilTraceability` row per (rod, spool, footage range) |

**Primary rod = the rod of the first segment consumed into that coil**, `MIN(FootageFrom)` over its
traceability rows.

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
> **The `CoilNo` mints below are unaffected and remain correct** — they are the load-bearing half, and they come from `GenerateCoilAlpha`. Only the `CoilAlpha` column is misnumbered. Left in place rather than rewritten because the traces are cited line-for-line from the worked-examples document; read the `CoilAlpha` column through this note. Recorded 25 Aug 2026; no register id — it is a documentation defect in a rationale document, not a requirement or schema change.

Both traces use the **shipped run's own numbers** — rod 4,000 lb, spool target 1,800 lb, coil
800–900 lb, alloy 1100 at FL1 `0.110″ × 0.625″` (**0.0809 lb/ft**) and FL2 `0.0160″ × 0.625″`
(**0.0118 lb/ft**). Both factors are from `[DBD §6.6]`; 22,250 ft and 11,100 ft are `TC-167`'s
published figures.

**The ignore-list rule both traces depend on.** `GenerateCoilAlpha` sweeps the shared schema but
**not `FlatWireDB`**, so every mint passes **the segment alphas already recorded for that rod in
`SpoolTraceability`**. Everything already in the shared schema — every `CoilNo` ever written — the
sweep finds by itself. The list carries exactly the `FlatWireDB`-local alphas and nothing else.

#### Scenario A — no weld: one rod, one spool

Rod `R00001`, 4,000 lb, order `O1`. It fills **three** spools — 1,800 lb into spool 1, 1,800 into
spool 2, and its last 400 into spool 3 — so it mints segments `R00001A`, `R00001B`, `R00001C`.
Spool 1 is traced here.

> **The trace assumes FL1 has finished the rod before FL2 runs spool 1**, which is the normal case:
> spool 1 goes to anneal while FL1 keeps drawing the same rod. It matters, because the coil
> identities below depend on which letters the segments have already taken.

| Step | Call | Result |
|---|---|---|
| Spool 1 completes | `GenerateCoilAlpha('R00001', '')` — no prior segments | **`R00001A`** |

| `SpoolTraceability` | value |
|---|---|
| `SpoolAlpha` | `SP-00001` *(material identity — the carrier it is wound on is `SP-0001`, and this is `OQ-K` made concrete)* |
| `ChildAlpha` · `RodAlpha` · `SeqNo` | `R00001A` · `R00001` · `1` |
| `SegmentWeightLb` | **1,800.00** |
| `FootageFrom` → `FootageTo` | `0` → `22,250` *(spool-local, FL1 gauge)* |

Lead alpha = `MAX(SeqNo)` = the only row = **`R00001A`**.

| Coil | `CoilAlpha` | Primary | `CoilNo` | Weight | `CoilTraceability` |
|---|---|---|---|---|---|
| 1 | `FW-00001-C01` | `R00001` | `GenerateCoilAlpha('R00001','R00001A,R00001B,R00001C')` → **`R00001D`** | 900.00 | **1 row** |
| 2 | `FW-00001-C02` | `R00001` | `GenerateCoilAlpha('R00001','R00001A,R00001B,R00001C')` → **`R00001E`** | 900.00 | **1 row** |

**Two exclusion mechanisms, and the split is the whole design.** `A`, `B` and `C` are excluded by the
**ignore list**, because segment alphas live in `SpoolTraceability` and `FlatWireDB` is outside the
sweep. `D` is excluded for coil 2 by the **sweep itself**, because coil 1 wrote it into
`proddb..coils`. Neither mechanism covers the other's ground.

> ⚠ **The letters are mint-order artifacts and carry no meaning.** `R00001D` is a coil and `R00001C`
> a segment, but nothing in the strings says so, and the split between them moves with whatever was
> minted first. **This is why `ChildAlpha` is opaque and never parsed, and why `SeqNo` carries the
> ordering** (§2.4). A tidy "segments get A–C, coils get D–E" reading is an accident of this trace,
> not a rule.

#### Scenario B — welded: two rods, one spool

Spool 3 of the shipped run: `R00001` is down to its last 400 lb and `R00002` is welded in to finish it.

| `SeqNo` | Call | Result | Weight | Spool-local footage |
|---|---|---|---|---|
| 1 | `GenerateCoilAlpha('R00001','R00001A,R00001B')` | **`R00001C`** | 400.00 | `0` → `4,950` |
| 2 | `GenerateCoilAlpha('R00002','')` — first segment of a new rod | **`R00002A`** | 1,400.00 | `4,950` → `22,250` |

Spool `SP-00003`, 1,800.00 lb, **two** `SpoolTraceability` rows. Lead = **`R00002A`**. Rendered
`R00001C - R00002A`, which is the workbook's FL1 sheet exactly — **the unified namespace reproduces
the client's own column**, and diverges only where a coil reached a suffix first, which is the
collision it exists to prevent.

`R00001` is now spent. **`R00002` carries on**, filling spool 4 (1,800 lb → `R00002B`) and spool 5
(800 lb → `R00002C`), which is why the coils below start at `D`.

FL2, LIFO:

| Coil | `CoilAlpha` | Primary | `CoilNo` | Composition | `CoilTraceability` |
|---|---|---|---|---|---|
| 1 | `FW-00003-C01` | `R00002` | `GenerateCoilAlpha('R00002','R00002A,R00002B,R00002C')` → **`R00002D`** | 900 lb, all `R00002A` | **1 row** |
| 2 | `FW-00003-C02` | `R00002` | same call; `R00002D` now found by the sweep → **`R00002E`** | 500 lb `R00002A` + **400 lb `R00001C`** | **2 rows** |

Coil 2's two rows are the point of the design:

| `RodAlpha` | `SpoolAlpha` | `FootageFrom` → `FootageTo` | Weight |
|---|---|---|---|
| `R00002` | `SP-00003` | `0` → `42,400` | 500.00 |
| `R00001` | `SP-00003` | `42,400` → `76,300` | 400.00 |

Half-open, contiguous, covering the coil exactly (`TC-617`). The compound display
`R00002E ← R00002A + R00001C` renders from these rows; **nothing compound is stored.** The certificate
reads both parents — and both supplier heats — from here.

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
returns **`' '`** — a single space, not `NULL`. It roots on
`SUBSTRING(LTRIM(RTRIM(@CoilNo)), 1, 6)` and walks `A`…`Z`, `AA`…`AZ`, `BA`… for the first unused
suffix.

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

**The object map.** Seven objects share this job; only the first is named anywhere in the flat wire
artifacts. Verified exhaustively — no copy exists outside `ual-database`.

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
| **F3** | ⚠ **The two implementations sweep different planning tables.** CommonDB reads the snake_case `planning_*` mirrors in `united_db`; PlanningDB reads its own PascalCase `PlanningMfgSalesOrderRef` / `PlanningCoilMillProcessing` / `PlanningCoilSlitterProcessing`. **Neither covers both**, so an alpha reserved in the modern planning module is invisible to the function flat wire calls |
| **F4** | **Suffix exhaustion is an infinite loop, not an error.** Past all 702 suffixes the overflow wraps `Z`→`A` and re-tries a taken alpha forever; a UDF cannot `RAISERROR`, so it spins holding a connection. **Not reachable at flat wire volumes** — ~9 per rod — but real and silent, and segments and coils now share the budget |
| **F5** | **`WITH(NOLOCK)` is on twelve of the fourteen reads and absent from `wip_log_view` and `coils`** — the two that matter most. A dirty read on a *uniqueness* check is backwards: it can miss a just-inserted sibling as well as see a rolled-back one |
| **F6** | **`CRM_Coils_Weight_Info` filters on `coil_no` but selects `new_coil_alpha`** — the only branch whose filtered and selected columns differ. Plausibly deliberate for a renamed coil; worth confirming rather than asserting |
| **F7** | **The 9-character input branch keys on character position 7**, not on parsing the suffix. It recovers through the outer loop, but the behaviour is positional and fragile |
| **F8** | **It can never be inlined.** A multi-statement body with a table variable and `WHILE` loops is ineligible for SQL Server 2019+ scalar UDF inlining, so every call is interpreted and runs 14 `LIKE`-scans across four databases. Fine one-at-a-time inside a transaction; **must never appear in a set-based query** |
| **F9** | **The namespace collision this design resolves.** `GenerateCoilAlpha('R00001','')` returns `R00001A`, and `FlatWireDB` is not swept — so a local FL1 counter would hand the same string to a spool segment and to a finished coil. Nothing breaks in the database; the collision is **semantic**, and lands on the genealogy and the certificate. Resolved by minting both through the one function (§2.4) |
| **F10** | **`GetCoilAlpha` already implements the batch loop FL1 needs — on the wrong side of F3.** It takes `@count`, loops, and accumulates into `@coilNosToIgnore` with `CONCAT_WS`. But line 119 calls `dbo.GenerateCoilAlpha` unqualified *inside PlanningDB*. **Cite it as the reference loop; do not call it** |
| **F11** | **The legacy path narrows the ignore list 500 → 200.** `Common_GenerateCoilAlpha`'s parameter is `VARCHAR(200)`; truncating an *exclusion* list means re-issuing an alpha. Irrelevant at flat wire's ~3 segments, but flat wire's own accumulator must respect the 500 ceiling |
| **F12** | ✅ **Resolved 22 Aug 2026 — and it found a real residual.** The scrap-weight path exists on the live instance and **does call `GenerateCoilAlpha`**, so it draws from the same root namespace *through the same uniqueness sweep* — which means it cannot collide with anything already in the shared schema. **But it does not and cannot pass flat wire's ignore list.** FL1 segment alphas live only in `FlatWireDB`, outside the sweep, so a scrap event on a rod FL1 is actively segmenting can be handed an alpha that a spool segment already holds. ⚠ **This is the limit of the `F9` guarantee:** one namespace protects flat wire's **two** paths from each other, and cannot protect against a **third-party minter that does not know `FlatWireDB` exists**. Recorded as **`Q59`**; the 702-suffix budget is now shared three ways, which is still far from the limit but makes the *“letters are mint-order artifacts”* rule load-bearing rather than merely tidy |

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

`OQ-A`…`OQ-P` locally; they become `Q48`+ when a register wave runs. A decided item keeps its text and
is never deleted, per the register's own rule.

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
| **`OQ-M`** | **Does a spool unwind last-on-first-off?** It decides **which coil the weld lands in**, and so each coil's traceability rows, primary rod and certificate parentage. Geometry says LIFO; the workbook consumes FIFO while naming LIFO, so it is no evidence either way. `Q45` is the same question at the label. **Build to LIFO meanwhile** |
| ~~**`OQ-N`**~~ | ✅ **Decided 22 Aug 2026 — keep `CoilAlpha`, rename `SharedCoilNo` → `CoilNo`.** The question was whether a `CoilOutput` row must wait for `CommonDB.dbo.GenerateCoilAlpha`. **It must not, and it need not:** `CoilAlpha` is retained as the locally-minted `NOT NULL` identity, so `CoilNo` stays nullable, the `CoilTraceability` FK does not move, and coil completion is never coupled to a cross-database call. `D5` stands (§2.5) |
| ~~**`OQ-O`**~~ | ✅ **Decided 22 Aug 2026 — yes, it shares the namespace.** Verified on the live instance: `united_db.dbo.Common_GenerateNewCoilAlphaForScrapWeight` exists and **calls `GenerateCoilAlpha`**. Because it goes through the same sweep it cannot collide with the shared schema — but it cannot see `FlatWireDB`, which is the residual now tracked as `OQ-P` / **`Q59`** |
| **`OQ-P`** | **A third-party minter can collide with an FL1 segment alpha, and nothing in the sweep prevents it.** FL1 segment alphas live only in `FlatWireDB`; the scrap-weight path (and any other `GenerateCoilAlpha` caller) passes its own ignore list, not ours. So a scrap event on a rod FL1 is mid-way through segmenting can be issued an alpha a spool segment already holds. **Options:** accept the risk (narrow — it needs a scrap event on an actively-segmented rod); or make the segment alphas visible to the sweep, which means writing them into the shared schema and therefore touches `D-32` and **`OI-115`**. **Recommendation: accept and monitor**, because the fix costs a new shared-schema writer and the collision is detectable at the point of use. Tracked as **`Q59`** |
| ~~**`OQ-L`**~~ | ✅ **Decided 22 Aug 2026 — one namespace, minted through `GenerateCoilAlpha`** (F9) |

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
