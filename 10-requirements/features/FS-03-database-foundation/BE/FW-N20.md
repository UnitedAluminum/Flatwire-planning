---
id: FW-N20
legacy_id:
title: SpoolOrder re-grained from the spool to the segment
status: done
status_confirmed: true
status_note: "✅ **Done, 8 Sep 2026 (`D-57`).** `SpoolOrder` is re-parented from `SpoolProcessing.Alpha` to **`SpoolTraceability.Id`** — one row per (segment, order), so *whose* material went to which order is finally answerable. It now carries **two ranges in two frames**: segment-local **pounds** (authoritative, forced to equal `AllocatedWeightLb` by `CK_SpoolOrder_WeightRange`) and spool-local **feet**, the frame FL2 cuts in and the only one in which one order across two segments reads as contiguous. Re-planning is additive (`IsActive` + `SupersededByOrderId`), so uniqueness is the filtered **`UX_SpoolOrder_Active`** — the inline `UQ_SpoolOrder_Key` could not survive it. ⛔ **`SpoolTraceability` is untouched**: merging the two would have broken `UQ_SpoolTraceability_Seq` and the UNIQUE `UX_SpoolTraceability_ChildAlpha` (`Q57` — one segment, one child alpha). Counts **46/68/89 → 47/69/91** with `FW-N21`, verified. **308 backend tests** (+9 for the two new rules, which had none). ⚠ **Two things this does NOT settle:** `Q43` is open with ratification owed, so the schema builds one of two client readings; and **nothing writes this table** (`G109`)."
owner:
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB, BE]
priority: high
hours: 10
sprint: S0
depends_on: []
blocked_by: []
has_plan: true
started: 2026-09-08
completed: 2026-09-08
---

# FW-N20 · `SpoolOrder` re-grained from the spool to the segment

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 8, 2026 — built and verified in one pass
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ Done
**Owner:** Database + Backend
**Shortcode:** — *(implementation plan; **not citable as a requirement**)*

---

## 1. Why

`SpoolOrder` recorded *which orders a spool carries* and referenced the rod **nowhere**. So it could
say **that** a spool crossed an order boundary, and where the boundary sat on the spool — but not
**which rod's material went to which order**.

Reaching the rod meant joining `SpoolTraceability`, and **the two tables' ranges were in different
units**: `SpoolOrder` in pounds, `SpoolTraceability` in **feet, nullable**. They could not be joined.
That was the defect, and the welding-wire certificate is what needs it joined.

⛔ **A literal merge of the two tables was rejected**, and the reason is worth keeping. It breaks:

1. **`UQ_SpoolTraceability_Seq`** — an order split *inside* one physical segment would give two rows
   the same `SeqNo`.
2. **`UX_SpoolTraceability_ChildAlpha`, which is `UNIQUE`** — and **one physical segment has one
   child alpha** (`Q57`). A merged grain lands that alpha on two rows; demoting the index leaves no
   uniqueness guard at all while `FW-231` is blocked (`G54`).

Keeping the segment grain and hanging the orders off it costs nothing and keeps both.

## 2. What was built

| Where | Change |
|---|---|
| `../../../../30-database/sql/FlatWire_DDL_03_Materials.sql` | `SpoolOrder` rewritten: `SpoolTraceabilityId` replaces `SpoolAlpha`; `AllocatedWeightLb` (`NOT NULL`) replaces nullable `PlannedWeightLb`; `SegmentWeightFrom`/`To`; **`SpoolFootageFrom`/`To`**; `SupersededByOrderId`, `IsActive`, `CreatedBy`. New `CK_SpoolOrder_WeightRange` and `CK_SpoolOrder_FootageRange`; `Source` gains `Substituted`. ⛔ **The guarded `ALTER` block that added `SpoolWeightFrom`/`To` was DELETED** — see §4 |
| `FlatWire_DDL_06_ForeignKeys.sql` | `FK_SpoolOrder_SpoolProcessing` → **`FK_SpoolOrder_SpoolTraceability`**. Renamed, not just re-pointed: the parent is a different table, so the old name would have lied. One out, one in — **no count change** |
| `FlatWire_DDL_07_Indexes.sql` | `IX_SpoolOrder_SpoolAlpha` → `IX_SpoolOrder_SpoolTraceabilityId`; **`UX_SpoolOrder_Active`** added (filtered unique) |
| `FlatWire_SampleData_Materials.sql` | `SpoolOrder` 3 → **4 rows**; `RodOrderAllocation` 3 → **5** — see §3 |
| `FlatWire.Domain/AggregatesModel/SpoolProcessingChildren.cs` | The entity re-shaped; **`SpoolTraceability` gains `Orders` and `AddOrder`** |
| `FlatWire.Domain/AggregatesModel/SpoolProcessing.cs` | `AddOrder` **removed**; `Orders` becomes a read-only projection over the segments. ⚠ **The aggregate ROOT is unchanged** — `SpoolProcessing` is still the root and these rows are still inside its boundary, one level deeper |
| `FlatWire.Domain/Rules/TraceabilityRules.cs` | **Two new rules** — `SegmentOrdersMustNotOverlapRule`, `SegmentAllocationMustFitRule` |
| `FlatWire.UnitTests/.../SpoolOrderRulesTests.cs` | **9 tests.** This table had none |
| `GenealogyAndRodConfiguration.cs`, `FlatWireDbContext.cs` | EF re-mapping; the field-access entry moves to `SpoolTraceability.Orders` |
| `[API §4.7a]`, `[DBD]`, the schema docs | No API change — **neither table is named in the API contract** |

### Two frames on one row, and why

| | Frame | Why |
|---|---|---|
| `SegmentWeightFrom`/`To` | **segment-local pounds** | Weight is conserved through drawing and rolling; footage is not. Segment-local makes `CK_SpoolOrder_WeightRange` an **exact single-row check** against `AllocatedWeightLb` |
| `SpoolFootageFrom`/`To` | **spool-local feet** | ⭐ **FL2 cuts in this frame** — the line has a footage counter, not a scale. FW-00700 over two segments reads as `[1000,1900)` + `[0,1485)` in pounds — two unrelated intervals — and `[4368,8300)` + `[8300,14800)` in feet: **one contiguous run**. Contiguity is visible only here, which is why it is stored, not derived (the call `SpoolProcessing.RunStartFootageFt` already makes) |

⛔ **Pounds are authoritative; feet are a recorded convenience.** No constraint can tie the two frames
together, so **if they ever disagree the pounds are right.**

## 3. Two pre-existing seed defects the arithmetic exposed

**(1) The seed's comment contradicted its own data.** It claimed *"R00043 is split across FW-00500 and
FW-00700"* — but the rows gave FW-00500 exactly 1,900 lb (R00043's **whole** segment) and FW-00700
exactly 1,485 lb (R00044's whole segment). The boundary landed **on** the rod boundary; nothing was
split. Fixed: the fixture now shows a real straddle, 1,000/900 lb inside segment 1.

**(2) Two rows claimed `Source='Derived'` and could not be derived.** `Derived` means *the union of
the orders on the rods* — and **`R00044` had no `RodOrderAllocation` rows at all**, so the union was
empty. Fixed by adding R00044 as a two-order rod (1,485 + 3,335 = 4,820 lb).

## 4. Three things worth knowing before touching this again

⛔ **The deleted `ALTER` block was not tidying.** It added `SpoolWeightFrom`/`To` when absent — and
after the re-grain they are absent **by design**, so on a fresh teardown-and-deploy it would have
fired and bolted two stray nullable columns onto the new table. **Leaving it in was the defect.**

⛔ **Uniqueness had to become a filtered index.** Re-planning is additive, so a superseded row and its
replacement share `(SpoolTraceabilityId, OrderNo, RelLetter)`; a plain `UNIQUE` would refuse the very
write the additive model exists to make. That is also what **moves the index count** — a `UNIQUE`
constraint in `03` is not an index statement in `07`.

⛔ **`AddOrder` asserted nothing before this story**, while its sibling `AddSourceSegment` checked an
invariant — and there was no rule for `SpoolOrder` of any kind and no test. The segment grain makes
two invariants expressible for the first time, and **neither can be a database constraint**: both are
cross-row, the parent's footage is nullable, and a trigger joining on `NULL` **passes silently** (the
identical reason `SpoolTraceability` has no non-overlap trigger).

## 5. What is still open

- ⛔ **`Q43`** — *how many orders may one spool carry* — is **open, ratification owed**. The 20 Aug
  multi-voice call says many; Tim O'Brien said one on 3 Sep. **This schema builds the multi-order
  reading**, and `D-57` says so rather than letting the change settle it quietly. If Tim's position is
  ratified, this table dissolves.
- ⛔ **`G109`, raised here: nothing writes `SpoolOrder`.** No procedure in `30-database/scripts/`
  touches it, and `G54`/`OI-138` leave the FL1 chain without a writer. **Green tests do not mean the
  chain works.**
- ⛔ **`G110`, raised here: a straddle cannot be *derived*.** It needs the rod-local weight at which
  the spool started taking that rod, and no table holds that anchor — the counterpart of
  `SpoolProcessing.RunStartFootageFt`. So a straddle is `Planned`, never `Derived`.
- ⚠ **`G48` is fully implemented and stays open** — its premise is contradicted, and the register's
  convention is that such a gap does not close.
- ✅ **VERIFIED ON A SERVER, 8 Sep 2026** — teardown-and-rebuild on `DEV00164-001`; `V1`–`V3`/`V5` pass as written, the chain is idempotent, and the constraints were exercised negatively. *(was: unverified)* ⚠ Teardown-and-deploy on `DEV00164-001` is owed; `RunAll` has been
  reported aborting at script `06`, which should be diagnosed before trusting a green run.

---

## ✅ Deployed and verified — 8 September 2026

Teardown-and-rebuild on **`DEV00164-001`**: `99_Teardown` → `RunAll` → `RunAll` → `SampleData_RunAll`
→ `RunAll_MVP2` → `FlatWire_Scripts_RunAll`.

- **`V1` 47 · `V2` 69 · `V3` 91 · `V5` 0** — all exactly as `[DEP §4.2]` writes them. `V4` is 7 once
  MVP-2's `sp_ShiftSummary` is excluded, which is what that gate says to expect.
- **Idempotent** — the second `RunAll` created nothing.
- ⭐ **`RunAll` did not abort at script 06.** *“All FK constraints added successfully”*, then 07 and 08
  ran. The note claiming an abort there was stale.
- ⚠ **The `06` abort risk this story could have introduced was caught before deploy:** both new FKs are
  now guarded on `sys.columns`, so an incremental re-run against a pre-8-Sep database **skips and
  prints why** instead of failing on `Msg 1911` and killing 07/08.
