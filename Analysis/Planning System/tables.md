The tables used in Flat wire planning system to store plan data will be

----

### Plan types

A plan can be one of three types. The type decides where the order number comes from and whether an SMP drives the generation.

**1. Customer order plan**

- Driven by a **customer order** — customer order numbers are generally **greater than 100000**.
- An SMP is provided for the item; the temp routing / flat line processing data is generated from that SMP together with the available coil data.

**2. Item stock order plan**

- Driven by the item's **SMP**, with no customer order.
- A **stock order number has to be created** and assigned into the respective temp tables.
- Stock order numbers are generally **less than 100000**, and are produced by `PlanningDB.dbo.CreateStockOrder` (which calls `GetNextStockOrderNo` / `GetNextStockOrderNoForSeed`, seeded from `united_db..MAXPKIDS` where `tableName = 'stockOrderNo'` and recycled once it reaches 99999).
- `CoilOrderPlan.IsStockOrder` flags these plans.

**3. As-is plan**

Two variants: **customer order as-is** and **stock order as-is**.

- There is generally **no SMP**.
- The plan is generated for a **given weight**, and the material goes through **as-is** — it keeps the coil's own properties.
- So if the first operation is `FLATTEN`, one row is created in TempFlatLineProcessing where the **input fields are the same as the output fields** (`StartGauge` = `TargetGauge`, `InputShape` = `OutputShape`, `InputType` = `OutputType`, and so on).
- `MinTargetGauge` and `MaxTargetGauge` are also **equal to `TargetGauge`** — no flattening happens for that weight, so there is no tolerance band.
- `Temper` is the **input temper**: the output temper of the previous operation, or the coil's own temper (e.g. `F`) when there is no previous operation.
- **`BackToStock` is set to `1` only when the order is a stock order.**
- The two variants differ only in the order: the customer order as-is plan carries a **customer order** where the stock order as-is plan carries a **stock order**.

| Plan type | Order | SMP | Notes |
|---|---|---|---|
| Customer order plan | customer order (> 100000) | yes | generated from SMP + coil data |
| Item stock order plan | stock order (< 100000), created via `CreateStockOrder` | yes | order no. assigned into the temp tables |
| As-is plan (stock order) | stock order (< 100000) | no | for a given weight, input = output, `BackToStock = 1` |
| As-is plan (customer order) | customer order (> 100000) | no | same as above, customer order instead of stock order |

#### BackToStock rules (stock order plans)

`BackToStock` is only ever `1` when the order is a **stock order**. Which table it is flagged on depends on where the stock output leaves the route:

| Situation | Column set to 1 |
|---|---|
| The output comes out of the **flat line** | `TempFlatLineProcessing.BackToStock` |
| The **last operation** of the stock order is `ANNEAL` | `TempRoutings.BackToStock` |

These are mutually exclusive: when the output leaves at a flatten the flag goes on the flat line processing row **only**, never on the routing row.

**Output cannot be divided at the furnace.** So when a stock order and a customer order share the coil and diverge at the anneal, an extra `FLATTEN` operation has to be added to separate them.

*Example* — the stock order SMP is `Flatten` → `Anneal` (`FA`), and some of the weight is planned to a customer order whose SMP is `Flatten` → `Anneal` → `Flatten` (`FAF`). Since the output cannot be split at the furnace, **one more `FLATTEN` operation is added** for the stock portion:

- its entry is written exactly like an **as-is** entry — the input fields are the same as the output fields
- `BackToStock` is set to `1`

This extra operation is added at the **last step, when the temp data is merged into the planning tables**.

----
### CoilOrderPlan

It will be used to store coilNo , orderNo , plan info

----

### TempRoutings

Already exists in PlanningDB — `ual-database/Databases/PlanningDB/Tables/TempRoutings/CreateTable.sql`. The flat wire work reuses it; the relevant columns here are `OperationLetter`, `MachineId`, `MachineGroup`, `SequenceNo`, `NominalGauge`, `CoilStartGauge`, `TargetTemper`, `InputTemper` and `RemainingOperations`. History counterpart: `TempRoutingsHistory`; exported counterpart: `PlanningRoutings`.

It will store individual order plan data generated from provided
item process SMP

for example SMP array will look like

```json
[
  { "type": "Rod",  "shape": "Round", "minGauge": null,   "nominalGauge": 0.3750, "maxGauge": null,   "temper": "F",   "operation": null },
  { "type": "Wire", "shape": "Round", "minGauge": 0.2808, "nominalGauge": 0.2810, "maxGauge": 0.2812, "temper": "H12", "operation": "DRAW" },
  { "type": "Wire", "shape": "Flat",  "minGauge": 0.108,  "nominalGauge": 0.1100, "maxGauge": 0.1120, "temper": "H18", "operation": "FLATTEN" },
  { "type": "Wire", "shape": "Flat",  "minGauge": 0.108,  "nominalGauge": 0.1100, "maxGauge": 0.1120, "temper": "O",   "operation": "ANNEAL" },
  { "type": "Wire", "shape": "Flat",  "minGauge": 0.019,  "nominalGauge": 0.0200, "maxGauge": 0.0210, "temper": "H15", "operation": "FLATTEN" },
  { "type": "Wire", "shape": "Flat",  "minGauge": 0.0153, "nominalGauge": 0.0160, "maxGauge": 0.0168, "temper": "H17", "operation": "FLATTEN" }
]

```

Inputs required to generate a complete plan

Four things are needed:

| Input | What it provides |
|---|---|
| **Weight to plan** | How much weight is being planned. |
| **SMP array** (item process) | The full process route for the item. Each element of the array is one process step. |
| **Order details** | The order's required nominal gauge, required temper, and other fields needed to populate the routing rows. |
| **Coil details** | The incoming coil's gauge, temper, etc. Used to work out how much of the SMP is already done. |

An as-is plan is the exception on the SMP: it has none, and is generated for the given weight alone (see *Plan types* above).

**Operation types (flat wire)** — there are four. Each has a single-letter code, stored on the TempRoutings row and used to build the operation strings in TempOrderRemainingOperations:

| Operation | Letter |
|---|---|
| `DRAW` | `D` |
| `FLATTEN` | `F` |
| `ANNEAL` | `A` |
| `EDGE` | `E` |

Temp routing generation rules (grouping + line assignment)

The SMP steps are **not** written one-to-one into TempRoutings. They are collapsed into at most three rows:

| Seq | Temp routing row | Built from | Line | Machine ID |
|---|---|---|---|---|
| 1 | `FLATTEN` | all `DRAW` + `FLATTEN` operations occurring **before** the `ANNEAL`, combined into one operation | Flat Line 1 | e.g. 123 |
| 2 | `ANNEAL` | the `ANNEAL` operation, on its own row | — (furnace) | **not populated** |
| 3 | `FLATTEN` | all `FLATTEN` / `EDGE` operations occurring **after** the `ANNEAL`, combined into one operation | Flat Line 2 | TBD |

- `ANNEAL` is done at the **furnace**, not on a flat line, so the **MachineId is left empty** on that row.
- If the route has **only** `FLATTEN` operations (no `ANNEAL`, no `DRAW`), they are combined into a single `FLATTEN` row that runs on **Flat Line 3**.

Determining the remaining operations

The coil may already be part-way through the SMP route, so not every SMP step needs a temp routing.

1. Match the **coil's incoming gauge and temper** against the SMP array to find the step the coil currently sits at.
2. Everything up to and including that step is treated as already done.
3. The remaining SMP steps are what temp routings get generated for, after applying the grouping / line rules above.

*Example* — using the SMP array shown above, if the incoming coil is already at gauge `0.1100` with temper `H18`, it matches the third SMP row. The `DRAW` and the pre-anneal `FLATTEN` are therefore complete, so the seq 1 row is not generated and the temp routings become:

| Seq | Operation | Line | Machine ID | Notes |
|---|---|---|---|---|
| 1 | `ANNEAL` | — | not populated | done at the furnace |
| 2 | `FLATTEN` | Flat Line 2 | TBD | the post-anneal flattens (H15, H17) combined into one operation, finishing at the order's required nominal gauge / temper |

----

### TempFlatLineProcessing

Based on the **FlatLineProcessing** sheet in `BaseDocuments/flatwire tables.xlsx`. Our planning-side copy is named **TempFlatLineProcessing**.

This is a **new** table — the flat wire equivalent of the existing `TempCoilMillProcessing` / `TempCoilSlitterProcessing` tables in PlanningDB, so it should follow their conventions (`Id` identity PK, `PlanId` / `SubPlanId` / `CoilOrderPlanId`, plus a `TempFlatLineProcessingHistory` counterpart).

It stores the **output generated by a flat line operation** — i.e. one row per `FLATTEN` (draw / edge folded in), holding the output type, shape and target gauge derived from the SMP.

> `ANNEAL` is **not** present in this table. It is a furnace operation with no flat line output, so it only exists as a row in TempRoutings.

Columns (from the FlatLineProcessing sheet)

| Column | Notes |
|---|---|
| `Id` | |
| `SetupNo` | |
| `StopNo` | |
| `SequenceNo` | |
| `MfgOrderNo` | |
| `HomeMfgOrderNo` | |
| `PlanId` | |
| `CoilOrderPlanId` | |
| `IncomingCoilNo` | |
| `CoilNo` | |
| `OnGaugeWeight` | |
| `OutputOD` | |
| `PassScheduleId` | marked with a `?` in the sheet — it is **nullable** |
| `FlatLineComponent` | Drawer / Stand |
| `ComponentSeqNo` | |
| `OutputID` | |
| `StartingPositionId` | Payoff1, Payoff2, TraversingTakeup |
| `StartGauge` | |
| `MinTargetGauge` | |
| `TargetGauge` | |
| `MaxTargetGauge` | |
| `InputShape` | Round / Flat |
| `InputType` | Rod / Wire |
| `OutputShape` | Round / Flat |
| `OutputType` | Rod / Wire |
| `Temper` | |
| `BackToStock` | |

How the gauges are populated for a merged operation

Because `DRAW` + `FLATTEN` (and the post-anneal `FLATTEN` / `EDGE` steps) are combined into a single temp routing operation, the row spans the **whole group**: the input side comes from the **first** SMP step in that group and the output side from the **last**.

| Field | Source |
|---|---|
| `StartGauge`, `InputShape`, `InputType` | the **current coil gauge / shape / type** if this is the first operation; otherwise the **incoming gauge of the first `FLATTEN` in that combination** |
| `MinTargetGauge`, `TargetGauge`, `MaxTargetGauge` | the `minGauge` / `nominalGauge` / `maxGauge` of the **last** step in that combination |
| `OutputShape`, `OutputType`, `Temper` | the output values of the **last** step in that combination |

*Example* — after the anneal there are two `FLATTEN` steps (H15 `0.0200`, then H17 `0.0160`). They produce **one** row: the input side is taken from the **first** of the two flattens, and the target gauge / output side from the **second**.

SMP scenarios (from the `SMP Scenarios` sheet)

| Scenario | SMP steps | Temp routing rows | Line |
|---|---|---|---|
| A | Flatten, Flatten, Flatten | Flatten | FL2 / FL3 |
| B | Flatten, Anneal, Flatten | Flatten / Anneal / Flatten | FL1 / Furnace / FL2 |
| C | Flatten, Anneal, Flatten, Flatten | Flatten / Anneal / Flatten | FL1 / Furnace / FL2 |
| D | Flatten, Anneal, Flatten, Flatten, Flatten | Flatten / Anneal / Flatten | FL1 / Furnace / FL2 |
| B (draw variant) | Draw, Flatten, Anneal, Flatten | Flatten / Anneal / Flatten | FL1 / Furnace / FL2 |

----

### TempMfgSalesOrderRef

Already exists in PlanningDB — `ual-database/Databases/PlanningDB/Tables/TempMfgSalesOrderRef/CreateTable.sql`.

Holds the **order / coil / issued weight** mapping.

| Column | Type | Notes |
|---|---|---|
| `Id` | `int IDENTITY(1,1)` | PK (`PK_TempMfgSalesOrderRef`) |
| `MfgOrderNo` | `int` | |
| `OrderNo` | `int` | indexed (`IX_TempMfgSalesOrderRef_OrderNo`) |
| `RelLetter` | `char(1)` | |
| `ItemTemplateIdx` | `int` | |
| `CoilNo` | `varchar(9)` | the coil issued against the order |
| `ReqsumCoilNo` | `varchar(9)` | |
| `IssuedWeight` | `int` | weight of that coil issued to the order |
| `StockOrderRelDueDate` | `datetime` | |
| `CoilOrderPlanId` | `int` | indexed (`IX_TempMfgSalesOrderRef_CoilOrderPlanId`) |
| `PlanId` | `varchar(20)` | |
| `SubPlanId` | `int` | |

History counterpart: `TempMfgSalesOrderRefHistory`. Exported counterpart: `PlanningMfgSalesOrderRef`.

----

### TempOrderRemainingOperations

Already exists in PlanningDB — `ual-database/Databases/PlanningDB/Tables/TempOrderRemainingOperations/CreateTable.sql`.

Holds the same **order / coil / weight** mapping, plus the remaining and planned operations.

| Column | Type | Notes |
|---|---|---|
| `Id` | `int IDENTITY(1,1)` | |
| `OrderRemainingOperationId` | `bigint` | |
| `OrderNo` | `int` | |
| `RelLetter` | `char(1)` | |
| `CoilNo` | `varchar(9)` | |
| `RemainingOperations` | `varchar(30)` | operation-letter string for the operations still to be performed |
| `PlannedWeight` | `int` | |
| `DueDate` | `datetime` | |
| `CoilOrderPlanId` | `int` | |
| `PlanId` | `varchar(20)` | |
| `SubPlanId` | `int` | |
| `PlannedOperations` | `varchar(30)` | operation-letter string for the operations that were planned |
| `BranchLastLevelId` | `smallint` | |

- Both operation strings are built from `TempRoutings.OperationLetter` (`D` / `F` / `A` / `E`).
- **At planning time `PlannedOperations` = `RemainingOperations`.** They only diverge later as operations are completed.

*Example* — a plan of `Flatten` → `Anneal` → `Flatten` gives `FAF`. When the coil is first planned, both `PlannedOperations` and `RemainingOperations` are `FAF`.

History counterpart: `TempOrderRemainingOperationsHistory`. Exported counterpart: `OrderRemainingOperations`.

----

## Planning tables

The tables above are the **temp tables** — each holds the plan data for **one order**. The flow into the planning tables is:

1. An entry is created in `CoilOrderPlan`.
2. That `CoilOrderPlanId` is mapped into each of the temp tables.
3. Once the temp tables hold the individual order data, the rows are **merged** — where the operations are the same across the different order plans on that coil, those operations are combined into one.
4. The merged result is written into the **planning tables**, which hold the final plan data.

| Planning table | Temp counterpart | Notes |
|---|---|---|
| `PlanningRoutings` | `TempRoutings` | the merged temp routing data of the different order plans on that coil. Same schema, minus the temp-only `Customer` and `OrderFinish` columns. |
| `PlanningFlatLineProcessing` | `TempFlatLineProcessing` | **new** — schema is the same as TempFlatLineProcessing |
| `PlanningMfgSalesOrderRef` | `TempMfgSalesOrderRef` | identical schema |
| `OrderRemainingOperations` | `TempOrderRemainingOperations` | identical schema — note this one has **no** `Planning` prefix |

Each planning table also has a `*History` counterpart (`PlanningRoutingsHistory`, `PlanningMfgSalesOrderRefHistory`, `OrderRemainingOperationsHistory`, and a `PlanningFlatLineProcessingHistory` to be added).

> This mirrors the existing mill / slitter pairs in PlanningDB — `TempCoilMillProcessing` → `PlanningCoilMillProcessing` and `TempCoilSlitterProcessing` → `PlanningCoilSlitterProcessing`.
