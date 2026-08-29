# FW-225 · Rod ↔ order allocation — schema and domain model

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⛔ **Blocked on `Q48`** — and the **DB half is already built**, so this is the domain mapping
**Owner:** Backend (.NET) + Database streams
**Audience:** The developer building `FW-225`
**Shortcode:** — *(implementation plan, derived from the DDL, `[REQ §5.28]` and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Twenty-eight hours across two streams, and **four details
> decide whether it is right.**
>
> **The tables are deployed. The 12 DB hours are the mapping, not the DDL** — the card says so
> and the DDL confirms it: `RodOrderAllocation` at `03_Materials.sql:412`,
> `RodOrderConsumption` at `04_Runs.sql:733`.
> **⛔ Three invariants SQL cannot express are this story's real content.** A rod's active
> ranges must **tile** the rod; a `PinnedBoth` row is its order's **only** row; an order with an
> allocation has **≥ 1** rod. None is a constraint — all three are aggregate rules.
> **`UX_RodOrderConsumption_Station` is keyed on `Station`, not `LineId`**, because FL1 and FL3
> share one physical VPS. ⛔ **Do not "fix" it** — that is `G21` again, on a different table.
> **Superseded, never updated.** A re-plan writes a new allocation and supersedes the old one;
> it does not mutate it. **`RodOrderConsumption` snapshots what it ran against — never a join
> back.**

---

## 1. The story

From `[TB §7]` — verbatim. ⚠ **This card uses the compact `FW-225`–`FW-231` variant** — no
`As a / I want / So that`, no `Acceptance Criteria:` header, no `Rate-card basis:` or
`Dependencies:` line. One relative link is rebased so it resolves from this folder.

> ###### FW-225 · Rod ↔ order allocation — schema and domain model
> **Hours:** 28 h (DB 12 · BE 16) · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB + BE
>
> > **New 22 Aug 2026.** Nothing persisted the rod ↔ order pairing — it existed only implicitly in
> > `united_db..planning_routings`, which `[INT §8]` records the flat wire side as reading and never writing.
> > Specified as `FR-541`–`FR-560` (`[REQ §5.28]`) with rule codes `ORD003`–`ORD017`; design at
> > [`RodOrderAllocation.md`](../../../../LatestDocument/RodOrderAllocation.md). DDL is **already applied** —
> > `RodOrderAllocation` in `03_Materials`, `RodOrderConsumption` in `04_Runs`, 7 FKs, 12 index statements —
> > and verified on a live deploy, so the DB half is the domain mapping rather than the tables.
>
> - [ ] Map both tables for read and write; the allocation is **superseded, never updated** on a re-plan
> - [ ] The three invariants SQL cannot express: a rod's active ranges **tile the rod**; a `PinnedBoth` row is its order's only row; an order with an allocation has ≥ 1 rod
> - [ ] `RodOrderConsumption` snapshots the allocation it ran against — never a join back
> - [ ] ⚠ `UX_RodOrderConsumption_Station` is keyed on **`Station`**, not `LineId` — FL1 and FL3 share one physical VPS. Do not "fix" it to `LineId`
>
> **Blockers:** **`Q48`** (`Critical` — can two orders on one rod have different pass schedules? It decides whether the mounted handoff is universal or conditional)

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The entity types and EF configurations | [`FW-240`](FW-240-RodOrder-Domain-Entities.md) — ⛔ **blocked on `[SVC §3.2a]`, and a hard predecessor** |
| The four-tier sequence validation | [`FW-226`](FW-226-Sequence-Validation-Four-Tier.md) |
| The order-boundary handoff and its state machine | [`FW-227`](FW-227-Order-Boundary-Handoff.md) |
| Footage-to-weight | [`FW-228`](FW-228-Footage-To-Weight-Converter.md) |
| `POST /order/{orderNo}/complete`'s host | [`FW-232`](FW-232-OrderController-Shell.md) |
| Fulfilment rollup and order status | `FW-229`, Phase 9 |
| `G52`'s `Sole` tier | [`FW-246`](../../Database/TaskBreakdownPlans/FW-246-Constraint-And-RI-Repairs.md) — ⚠ it may cost no DDL |

### 1.2 What already exists

Verified in the DDL and the built code on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| **`RodOrderAllocation`** | [`FlatWire_DDL_03_Materials.sql`](../../Database/Schema/SQL/FlatWire_DDL_03_Materials.sql) **`:412`** | ✅ **Built, seeded, in the MVP-1 runner** |
| **`RodOrderConsumption`** | [`FlatWire_DDL_04_Runs.sql`](../../Database/Schema/SQL/FlatWire_DDL_04_Runs.sql) **`:733`** | ✅ **Built** |
| **`UX_RodOrderConsumption_Station`** | [`FlatWire_DDL_07_Indexes.sql`](../../Database/Schema/SQL/FlatWire_DDL_07_Indexes.sql) **`:337`** — `UNIQUE … ON ([Station]) WHERE [State] IN ('InProgress','ThresholdReached')` | ✅ **Built, keyed on `Station`** exactly as specified |
| `RodOrderConsumption.RowVersion` | `04_Runs.sql:772` — `ROWVERSION NOT NULL`, *"State and footage move live, as on `FlatWireRun`"* | ✅ Built — ⛔ **unmapped** (`P-69`, `FW-240`'s `P-172`) |
| FKs | 33 `RodOrder` references in `06_ForeignKeys.sql` | ✅ Built |
| Requirements | `[REQ §5.28]` `FR-541`–`FR-560` / `ORD003`–`ORD017` | ✅ **Citable** |
| The design document | `LatestDocument/RodOrderAllocation.md` | ⚠ **Rationale — applied, and NOT citable as a requirement** |
| **Entity types** | — | ⛔ **Absent** — `FW-240`'s, and blocked on `[SVC §3.2a]` |
| **The three invariants** | — | ⛔ **Absent** — this story's core (§2.2) |

⚠ **`UX_RodOrderConsumption_Station`'s filter is `IN (…)`**, the same idiom as
`UX_FlatWireRun_ActiveLine` — and the same hazard: **filtered indexes reject `OR`**, so a
reformat breaks the deployment.

---

## 2. The four details

### 2.1 `Q48` decides the shape, not a detail

*"Can two orders on one rod have different pass schedules?"* — and the card marks it `Critical`
because **it decides whether the mounted handoff is universal or conditional.**

| Answer | Consequence for `FW-227` |
|---|---|
| **No** — one rod, one schedule | The handoff is **universal**: the rod stays mounted across every boundary, and `FW-227`'s state machine is the whole story |
| **Yes** — schedules may differ | The handoff is **conditional**: a boundary between two orders with different schedules requires a **re-acknowledgement and a PLC re-push**, which is a different operator flow and a different endpoint surface |

⛔ **Do not build the universal case and "add a branch later".** The conditional case reaches
`FW-082`'s tag push and `[PLC]`'s acknowledgement contract — it is not a branch, it is a second
path.

### 2.2 Three invariants, and none of them is a constraint

This is the story's real content, and each fails silently if omitted:

| Invariant | Why SQL cannot express it | Failure if absent |
|---|---|---|
| **A rod's active ranges tile the rod** | A gap or overlap is a property of a *set* of rows, not of one row. A `CHECK` sees one row | Footage falls in a gap and belongs to **no order**, or in an overlap and is billed **twice** |
| **A `PinnedBoth` row is its order's only row** | Requires counting siblings | An order both wholly-inside a rod **and** spanning others — incoherent, and `FW-226`'s tier logic has no answer |
| **An order with an allocation has ≥ 1 rod** | An empty set satisfies every row-level rule | An order allocated to nothing looks planned and produces nothing |

⚠ **The tiling invariant is the same class as `G42`'s non-overlap rule** — which is built, as
`SpoolSegmentsMustNotOverlapRule` invoked at `SpoolProcessing.cs:188`. **Follow that
precedent**: an `IBusinessRule` on the aggregate, invoked on mutation.

⛔ **And note `G42`'s lesson about nullable bounds**: a trigger joining on `NULL` **passes
silently**, which is why 22 Aug added none. **Check whether these footage bounds are nullable
before assuming the aggregate is a second line of defence rather than the only one.**

### 2.3 Superseded, never updated — and the snapshot follows from it

A re-plan **writes a new allocation row and supersedes the old**; it does not mutate. That makes
the allocation an **append-only history**, which is what lets a consumption row point at the
version it actually ran against.

⛔ **`RodOrderConsumption` snapshots the allocation it ran against — never a join back.** If it
joined, a later re-plan would retroactively change what a completed run consumed.

⚠ **Same rule as `FW-228`'s basis/factor/version snapshot** — *"a later `Q10` answer must not
retro-change a historical record"*. **Two stories, one principle**: production records are
immutable against later reference-data corrections.

### 2.4 `Station`, not `LineId` — this is `G21` on another table

`UX_RodOrderConsumption_Station` is keyed on **`Station`** because **FL1 and FL3 share one
physical VPS**. Keying it on `LineId` would let FL1 and FL3 each hold an `InProgress`
consumption on the same physical payoff.

⛔ **The card says "do not fix it" because the fix looks obvious.** It is the identical mistake
`P-183` guards against in `FW-158`, and `P-194` in `FW-159`'s absent `FL3PO`. **Three tables,
one physical fact.**

---

## 3. Build order

1. ⛔ **Close `Q48`** (§2.1). It decides whether `FW-227`'s handoff is universal or conditional,
   so it gates the design and not just this story.
2. ⛔ **`FW-240` first** — the entity types and EF configurations, themselves blocked on
   `[SVC §3.2a]`'s boundary signature. **Nothing here maps without them.**
3. Map both tables **for read and write**, allocation **append-only** (§2.3).
4. **The three invariants as `IBusinessRule`s** on the owning aggregate (§2.2), following
   `SpoolSegmentsMustNotOverlapRule`'s shape.
   ⚠ **Check the footage bounds' nullability first** — if nullable, the aggregate is the **only**
   defence, exactly as `G42`.
5. `RodOrderConsumption` writes a **snapshot** of the allocation — ⛔ **no navigation back to the
   allocation for values** (§2.3).
6. ⛔ **Leave `UX_RodOrderConsumption_Station` alone** (§2.4), and do not reformat its `IN` filter.
7. Confirm `FR-541`–`FR-560` / `ORD003`–`ORD017` each reach code, and cite **`[REQ §5.28]`** —
   never the design document.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-197` precede this story.

### `P-198` — the three invariants are aggregate rules, and the tiling rule is checked for nullable bounds first

§2.2. `G42` is the precedent and also the warning: its footage bounds are nullable, so a trigger
would pass silently and the aggregate rule is the **only** defence. **Establish whether the same
is true here before deciding whether a DB-level backstop is even possible.**

**Fallback:** if the bounds are non-nullable, a backstop trigger is worth adding — but the
aggregate rule ships either way, because a trigger cannot express "tiles the rod" cheaply.

### `P-199` — `Q48` gates the design, so it is escalated rather than assumed

§2.1. The conditional answer reaches `FW-082`'s tag push and `[PLC]`'s acknowledgement contract,
so guessing "universal" and adding a branch later is a **second path discovered late**, not a
refactor.

⚠ **`FW-227` cannot start either** — its whole state machine assumes the rod stays mounted.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified by aggregate demonstration on live `FlatWireDB`.

| Check | Expected |
|---|---|
| **Tiling** | A rod whose active allocations leave a **gap** is rejected; so is one with an **overlap** |
| **`PinnedBoth`** | An order with a `PinnedBoth` row and any sibling is rejected |
| **≥ 1 rod** | An order with an allocation and no rod is rejected |
| **Nullable bounds** | Established and recorded — it decides whether the aggregate is the only defence (`P-198`) |
| **Append-only** | A re-plan writes a new row and **supersedes**; the prior row is unchanged |
| **Snapshot** | A consumption row's values survive a later re-plan **unchanged** (§2.3) |
| **`Station` key** | `UX_RodOrderConsumption_Station` still keyed on `Station`; FL1 and FL3 cannot both hold an `InProgress` row on the shared VPS (§2.4) |
| Filter idiom | Still `IN (…)`, not `OR` |
| `ROWVERSION` | Mapped by `FW-240` (`P-172`) — a concurrent update returns `409` |
| Requirements | `FR-541`–`FR-560` / `ORD003`–`ORD017` reach code, cited from `[REQ §5.28]` |

---

## 6. Handoff

[`FW-226`](FW-226-Sequence-Validation-Four-Tier.md) validates sequences over these allocations —
⚠ **and `G52`'s `Sole` tier is unresolved**, which is
[`FW-246`](../../Database/TaskBreakdownPlans/FW-246-Constraint-And-RI-Repairs.md)'s.
[`FW-227`](FW-227-Order-Boundary-Handoff.md) runs the boundary handoff and is **gated by the same
`Q48`**. [`FW-228`](FW-228-Footage-To-Weight-Converter.md) supplies the weight each consumption
row persists. `FW-229` (Phase 9) rolls fulfilment up. [`FW-240`](FW-240-RodOrder-Domain-Entities.md)
is the hard predecessor.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`Q48`** | `Critical`. Decides universal versus conditional handoff — **gates the design** (`P-199`) |
| ⛔ **`[SVC §3.2a]`** | `FW-240`'s boundary signature. **Nothing maps without it** |
| **`G42`** | The precedent **and** the warning — nullable bounds make a trigger silently useless (`P-198`) |
| **`G52`** | `PinRole='Sole'` matches no tier. `FW-246`'s, and it bears on `FW-226` |
| **`G21`** | FL1/FL3 share one physical payoff — ⛔ **the `Station` key is that fact, not an error** |
| **`[REQ §5.28]`** | The citable requirements. `RodOrderAllocation.md` is **rationale** |
