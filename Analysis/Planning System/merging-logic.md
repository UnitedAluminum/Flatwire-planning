# Merging logic

How the per-order **temp** data (see [tables.md](tables.md)) is merged into the final **planning** data.

Full worked sample data for both examples below - the temp rows going in and the planning rows coming out - is in [merging-logic-sample-data.json](merging-logic-sample-data.json).

Each temp table holds the plan data for **one order** on a coil. Before the data is written to the planning tables, the operations of the different order plans on that coil are compared and, where they match, merged into a single operation.

## Sequence numbers

`SequenceNo` always starts at **0** and increases in steps of **10** — `0`, `10`, `20`, … Split rows that belong to the same operation share the same sequence number.

## Coil numbering

`IncomingCoilNo` and `CoilNo` change **only where a division happens** - i.e. at the flatten where the coil is split. Everywhere else the same coil number carries straight through, including across the anneal.

So an operation that is not a split point has `CoilNo` equal to the coil it received, and only the splitting flatten issues new coil numbers - one per output.

Divisions are created during the **merge**, so they never appear in the temp data:

- **Temp tables** — every row carries the **original incoming coil number**; `IncomingCoilNo` and `CoilNo` are the same throughout.
- **Planning tables** — new coil numbers are issued at the splitting flatten only, one per output.

## Merge rule

> Merge two operations when the **next operation** and the **output of the current operation** are the same as the other order's corresponding operation. Otherwise, do not merge them.

### What the merged row carries

When operations are combined into a single `PlanningRoutings` row:

- the **nominal / target gauge** is the **minimum** of the orders being combined;
- the **target temper** is that of the order that **needs further processing**;
- `BackToStock` is **not** set on the routing row when the output leaves at a flatten — it is set on the `PlanningFlatLineProcessing` row for that output. (It is only set on the routing row when the output leaves at the anneal, which has no flat line row.)

There is always **one** `PlanningRoutings` row per sequence number, even where the orders take different outputs — the per-output detail lives in `PlanningFlatLineProcessing`.

## Where a coil can be split

- A coil can only be split into two parts at a **`FLATTEN`** operation.
- A coil **cannot** be split at an **`ANNEAL`** operation — the furnace output cannot be divided.

This is the same constraint that forces the extra as-is `FLATTEN` described under *BackToStock rules* in [tables.md](tables.md).

## Worked example — two identical `FAF` orders

> Sample data: `scenarios[0]` in [merging-logic-sample-data.json](merging-logic-sample-data.json).

Both orders have identical temp routing data:

| | Order A | Order B |
|---|---|---|
| Temp routings | `Flatten` → `Anneal` → `Flatten` | `Flatten` → `Anneal` → `Flatten` |

The next operation and the output match at every step, so all three operations merge:

| Seq | Merged operation | Line | Built from |
|---|---|---|---|
| 1 | `Flatten` | Flat Line 1 | A's first flatten + B's first flatten |
| 2 | `Anneal` | Furnace | A's anneal + B's anneal |
| 3 | `Flatten` | Flat Line 2 | A's last flatten + B's last flatten |

So in `PlanningRoutings` there are only **three** operations: `Flatten`, `Anneal`, `Flatten`.

## What each planning table looks like after the merge

| Table | Rows | Notes |
|---|---|---|
| `PlanningRoutings` | 3 — one per merged operation | `OrdersInput` holds both order numbers |
| `PlanningFlatLineProcessing` | the same merged data | must have a **merged `OrdersInput`** |
| `PlanningMfgSalesOrderRef` | **2** — one row per order | not merged |
| `OrderRemainingOperations` | **2** — one row per order | not merged. Operations **added during the merge** count here, so this can differ from `TempOrderRemainingOperations` — e.g. an order whose temp string is `FA` becomes `FAF` once the extra as-is flatten is created. |

### `OrdersInput` format

A **semicolon-separated** list of the order numbers making up the merged operation, in order — first order, then the next:

```
123456;123457
```

This matches the existing behaviour in `CreateStockOrder.sql`, which appends with:

```sql
OrdersInput = CONCAT(ISNULL(OrdersInput, ''),
                     CASE WHEN ISNULL(OrdersInput, '') <> '' THEN ';' ELSE '' END,
                     @orderNo)
```

## Splitting the output at a `FLATTEN`

A merged operation still has to produce **one output per order**. Because a coil can only be split at a `FLATTEN`, that flatten gets **one row per order** in `PlanningFlatLineProcessing`: the input and output *fields* are the same on both rows, but each row carries its **own output** (its own output coil and `OnGaugeWeight`).

`PlanningRoutings` still holds a single merged row for the operation — only the flat line processing data is split out per order.

Which flatten the rows appear at depends on where the routes diverge:

| Case | Rows split at |
|---|---|
| Both orders are `FAF` (identical routes) | the **last** flatten — the one after the anneal |
| One order is `FAF`, the other is just `F` | the **first** flatten — where the routes diverge |
| Both orders are `FAF` but the **first flatten outputs differ** | the **first** flatten — the coil divides there, and the two coils stay separate for the rest of the route |
| One order is `FAF`, the other is `FA` | the flatten at the **same sequence as the last flatten** — an **extra as-is flatten** is created for the `FA` order so it can be separated (it has no flatten of its own after the anneal) |

*Example 1* (`scenarios[0]` in the sample data) — two identical `FAF` orders, order A for **1000 lb** and order B for **300 lb**. At the last flatten (after the anneal) two rows are generated: the same input and output field values on both, but different outputs — 1000 lb for A and 300 lb for B.

*Example 2* (`scenarios[1]` in the sample data) — order A is `Flatten` → `Anneal` → `Flatten` and order B is only `Flatten`. B finishes at the first flatten, so the two rows are shown at the **first flatten** operation instead.

*Example 3* (`scenarios[2]` in the sample data) — customer order 123456 (1000 lb) runs the `FAF` route and the remaining 500 lb goes back to stock as an **as-is stock order**. An item number is supplied for the stock order and its order number is generated in the planning logic (at service level, via `CreateStockOrder` / `GetNextStockOrderNo`). The as-is portion has no SMP, so its flat line entry keeps the coil properties — input fields equal to output fields — with `BackToStock = 1`. At `SequenceNo` 0 there is a **single** `PlanningRoutings` row — gauge `0.1100` (the minimum of the two) and temper `H18` (the customer order, which needs further processing) — while `PlanningFlatLineProcessing` carries **two** rows at that sequence, with `BackToStock = 1` on the as-is one.

*Example 4* (`scenarios[3]` in the sample data) — customer order 123456 is `FAF` and stock order 45232 is `FA`. On the temp side the stock order's **anneal** row carries `BackToStock = 1`, because that is its last operation. The split cannot happen at the furnace, so during the merge an **extra as-is flatten** is created for the stock portion at `SequenceNo` 20 — input fields equal to output fields, `BackToStock = 1` — and the flag comes off the anneal row. That extra operation exists only in the planning tables; there is no matching temp row. It also counts as an operation for the order, so `TempOrderRemainingOperations` shows `FA` while the planning `OrderRemainingOperations` shows `FAF`.

*Example 5* (`scenarios[4]` in the sample data) — both orders are `FAF`, but the first flatten goes to `0.1100 H18` for one order and `0.0800 H18` for the other. The coil divides at `SequenceNo` 0: a single `PlanningRoutings` row for the operation (gauge `0.0800`, the minimum of the two; temper `H18`, common to both) and two `PlanningFlatLineProcessing` rows, one per output, each getting its own new coil number. Note the two split rows here do **not** have matching input/output fields — that only holds when the split is an as-is one. From that point the coils are physically separate, so the anneal and the final flatten are modelled as **one routing row per coil**.
