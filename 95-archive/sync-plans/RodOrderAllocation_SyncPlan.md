# Rod ↔ Order Allocation — Propagation Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 25, 2026 — status corrected from *"Planned, not executed"* to **applied**; each wave marked *(previously August 22, 2026)*
**Status:** ✅ **APPLIED — all six waves, 22 Aug 2026.** Verified on 25 Aug 2026: both tables built (`RodOrderAllocation` in `03_Materials`, `RodOrderConsumption` in `04_Runs`), both in `FlatWire_DDL_RunAll.sql`, both seeded, documented in the three `FlatWireSchema_*.md` that own them, `FR-541`–`FR-560` / `ORD003`–`ORD017` live in `[REQ §5.28]`, `TC-731`–`TC-748` written, and `Q48`–`Q58` / `OI-123`–`OI-125` / `G47` / `G48` all minted.

> ⚠ **This header read *"Planned, not executed. No wave below has been applied"* until 25 Aug 2026, while the work had been applied since 22 Aug** and the subject document itself said `APPLIED`. Two documents in one folder disagreed about whether the same work had happened. Corrected as part of the `LatestDocument/` → `MVP-1/ProjectPlan/` sync audit.

> **Three things the waves did NOT deliver, and they are still owed:** the client-facing worked examples were written afterwards on 24 Aug and are cited from almost nowhere; the allocation-examples workbook generator was never committed; and `TC-770`–`TC-775` (the enforcement cases for `FR-542`, `FR-546`, `FR-547`, `FR-551`, `FR-554`, `FR-555`) were **missing until 25 Aug 2026**, when the coverage gate caught them. `S5` should have produced them.
**Document Type:** Propagation ledger — the same shape as the `ClientCall_*_SyncPlan.md` ledgers in `BaseDocuments/`
**Propagates:** [`RodOrderAllocation.md`](RodOrderAllocation.md) into `MVP-1/`, `MVP-2/` and [`../../10-requirements/MasterSpecification.md`](../../10-requirements/MasterSpecification.md)

---

## 1. What is actually propagating

Six changes, in descending order of blast radius. **Counts are measured, not estimated** — each is a
`grep -rl` over `MVP-1/` and `MVP-2/`.

| | Change | Files |
|---|---|---|
| **C1** | **Two new tables** — `RodOrderAllocation`, `RodOrderConsumption`. Moves the published **32 tables · 50 FKs · 57 index statements** figure | **24** |
| **C2** | **`SharedCoilNo` → `CoilNo`** — a rename only (see §2), including `UX_CoilOutput_SharedCoilNo` and `FlatWire_CompleteCoilOnSkid`'s `@expectedSharedCoilNo` | **14** |
| **C3** | **`ORD003`–`ORD017`** plus a new `FR-` block for the allocation, sequencing, handoff and fulfilment rules | 2 (+ tests) |
| **C4** | **Two hub events** — `OrderAllocationReached` / `OrderAllocationResolved`. Published event count **12 → 14** | 8 |
| **C5** | **`SpoolTraceability.ChildAlpha`** and **`SpoolOrder.SpoolWeightFrom`/`To`**, plus `SpoolOrder`'s derivation re-pointed at `RodOrderAllocation` | 5 |
| **C6** | **Two corrections to delivered artifacts** — `CoilTraceability`'s header rationale (§9 G-1) and the `"sixteen tables"` figure in `FlatWire_CompleteCoilOnSkid` | 2 |

---

## 2. Two things that shrank, and one that is empty

**⚠ `MVP-2` needs nothing.** Measured, not assumed: **no file under `MVP-2/` names `CoilAlpha`,
`SharedCoilNo`, `SpoolOrder` or `ChildAlpha`.** Every apparent hit was the word *"traceability"* used
in an unrelated sense, plus one pointer in `04-APIContract-MVP2.md` that already directs the reader
*into* `../../40-backend/APIs.md` §4.15–§4.16 for the coil endpoints — and that pointer
stays correct. **The only optional touch** is a one-line note there that `CoilOutput.SharedCoilNo` is
now `CoilNo`; the endpoints, tables and scope statements are all unaffected. Recording this so the
absence reads as a finding rather than an oversight.

**⚠ The coil-identity change is now a rename, not a redesign.** `OQ-N` was decided on 22 Aug:
**`CoilAlpha` is retained** and only `SharedCoilNo` is renamed. That removes the largest and most
contentious part of this propagation. **Untouched as a result:** `FR-330`, `FR-509`, `FR-230`,
`BusinessRules.md` §3.3's alpha-format table, `APIs.md`'s `"coilAlpha"` payloads and
`GET /coil/{alpha}/label`, and `D5`'s comment block in `FlatWire_CompleteCoilOnSkid`. An earlier draft
of this plan had all of those in scope.

---

## 3. Sequencing — the assumption this plan rests on

**The 20 Aug call's waves `W3`–`W7` are documented and still unexecuted**, and they touch the same
files: `BusinessRequirements.md`, the master spec, DDL `03`/`04`/`06`/`07`, `APIs.md`, `SignalR.md`,
`TaskBreakdown.md`, `TestCases.md`, `CapacityAndEffortModel.md` and the phase files.

**Assumption: this propagation runs as its own wave and `W3`–`W7` rebases onto it.** Two reasons, and
the first is decisive:

1. **`W3`–`W7` is blocked on client input.** Its FL2 pre-check-in shape needs **`Q41`** answered
   (*what does an FL2 pre-check-in actually do?*), and `A3` — the PLC review that gates three
   `Critical` items — has been overdue two weeks. Folding this propagation into that wave would make
   settled work wait on an unanswered question.
2. **Waiting leaves the design orphaned.** `W3`–`W7` has no date; `RodOrderAllocation.md` would sit
   disconnected from every other document meanwhile.

**The cost, accepted rather than hidden:** the table/FK/index counts get re-derived twice — once here
and once when `W3`–`W7` adds `SpoolStaging` (`OI-118`). **Mitigation: publish the count exactly once,
at the end of `S3`, from a live deploy** — never incrementally, which is what `W4`'s own note warns
against. Files this plan edits that `W3`–`W7` will edit again are flagged **⟳** below.

---

## 4. The waves

### `S1` — Registers *(no dependencies; do first)* ✅ **Applied 22 Aug 2026**

| Target | Change |
|---|---|
[`../../90-registers/Questions.md`](../../90-registers/Questions.md) | Mint **`Q48`–`Q59`** from `OQ-A`…`OQ-K`, `OQ-M`, `OQ-O`. Each carries a `Recommendation:` per the register's rule |
[`../../90-registers/Decisions.md`](../../90-registers/Decisions.md) | **`OQ-L`** and **`OQ-N`** land here as decided, with their full text — a decided item is never deleted |
[`../../10-requirements/MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11 | **`OI-123`+** for the `FlatWireRun.OrderId` narrowing, the `SpoolOrder` boundary loss, and `GenerateCoilAlpha`'s unresolved `coils` reference |
[`../../90-registers/Gaps.md`](../../90-registers/Gaps.md) | **`G47`** (`FlatWireRun.OrderId` reads wrong at an order boundary) · **`G48`** (the `SpoolOrder` boundary, with its closing window) |

⚠ **`Q48`+ and `OI-123`+ are the next free numbers as of 22 Aug.** `W1` of the 20 Aug ledger already
took `Q41`–`Q47` and `OI-118`–`OI-122`; **verify both maxima immediately before minting**, because
`G46` records exactly this failure mode — ids minted in five documents and never added to the
registers that own them.

### `S2` — Requirement text ⟳ ✅ **Applied 22 Aug 2026**

| Target | Change |
|---|---|
[`../../10-requirements/BusinessRequirements.md`](../../10-requirements/BusinessRequirements.md) | New `FR-541`+ block for allocation, sequencing, the handoff and fulfilment, carrying rule codes **`ORD003`–`ORD017`**. ⚠ **`FR-533`–`FR-540` are reserved by `W3`** for the FL2 pre-check-in — do not use them |
[`../../10-requirements/BusinessRules.md`](../../10-requirements/BusinessRules.md) | §3 gains the rod ↔ order cardinality and the four-tier sequence rule. **§3.3's alpha table is untouched** (§2) |
[`../../10-requirements/ProcessFlows.md`](../../10-requirements/ProcessFlows.md) | The order-boundary handoff as a flow: threshold → notification → acknowledgement → next order on the same mount |
[`../../10-requirements/screens/RodPreCheckin.md`](../../10-requirements/screens/RodPreCheckin.md) · [`RocCheckin.md`](../../10-requirements/screens/RocCheckin.md) | The sequence validation at both entry points (`Q73` item 7), and the order-set membership check |
[`../../10-requirements/screens/ActiveRunMonitor.md`](../../10-requirements/screens/ActiveRunMonitor.md) | The allocation-reached notification and the **operator's mark-complete action** — rule 9's acknowledgement has no screen today |

### `S3` — Schema and DDL ⟳ *(the count-bearing wave)* ✅ **Applied 22 Aug 2026**

| Target | Change |
|---|---|
`../../30-database/sql/FlatWire_DDL_03_Materials.sql` | `RodOrderAllocation`; `SpoolTraceability.ChildAlpha` with its **replacement** comment block; `SpoolOrder.SpoolWeightFrom`/`To`; `SpoolOrder`'s derivation comment re-pointed |
`…/FlatWire_DDL_04_Runs.sql` | `RodOrderConsumption` |
`…/FlatWire_DDL_06_ForeignKeys.sql` | **7** new FKs |
`…/FlatWire_DDL_07_Indexes.sql` | **12** new index statements (11 for the two tables + `UX_SpoolTraceability_ChildAlpha`) |
`…/FlatWire_DDL_05_QualityOutput.sql` | `SharedCoilNo` → `CoilNo`; `UX_CoilOutput_SharedCoilNo` → `UX_CoilOutput_CoilNo`; **`CoilTraceability`'s header rationale corrected** (§9 G-1) |
`../../30-database/DatabaseDesign.md` · `../../30-database/schema/FlatWireSchema_Materials.md` · `_Runs.md` · `_QualityOutput.md` · `_Lookup.md` | The two tables written up; the rename; and the **three stale schema documents** closed (`Spool`, `SpoolTraceability`, `SpoolOrder`, `SpoolStaging` were never written up) |
`Database/Scripts/united_db_Proc_FlatWire_CompleteCoilOnSkid.sql` | `@expectedSharedCoilNo` → `@expectedCoilNo`; the **`"sixteen tables"`** figure corrected to 14 selects over 12 objects, in **both** places |

**Counts to publish once, at the end of this wave, from a live deploy:**

| | Before | After | Basis |
|---|---|---|---|
| Tables | 32 | **34** | +2 |
| FKs | 50 | **57** | +7 |
| Index statements | 57 | **69** | +12 |
| Procedures · triggers | 1 · 1 | **unchanged** | — |

⚠ **Do not assert these — verify them.** The repo's rule is a **teardown → `RunAll` → idempotent
re-run** on the shared instance, and the current figure is described as *published and verified*.
The `34 / 57 / 69` above is derived from the DDL and **must be confirmed against `sys.tables`,
`sys.foreign_keys` and `sys.indexes`** before it is written into the 24 files that carry it.

### `S4` — Contracts ⟳ ✅ **Applied 22 Aug 2026**

| Target | Change |
|---|---|
[`../../40-backend/APIs.md`](../../40-backend/APIs.md) | New endpoints for the acknowledgement and the allocation read; `GET /rod/{alpha}` returns an order **set**. `"coilAlpha"` payloads untouched |
[`../../20-architecture/SignalR.md`](../../20-architecture/SignalR.md) §5.2 | Events **13 and 14**, both durable and re-delivered on group re-join, following event 11's contract. ⚠ `PP-04` records the count in the master spec and `BusinessRules.md` §3 too — **change all three or none** |
[`../../40-backend/Services.md`](../../40-backend/Services.md) | `IFootageWeightConverter` and the allocation/consumption services |
[`../../20-architecture/Integration.md`](../../20-architecture/Integration.md) | FL1 spool completion becomes a **cross-database caller** of `CommonDB.dbo.GenerateCoilAlpha` — and therefore **not testable on LocalDB** |

### `S5` — Plans, tests, effort ⟳ ⚠ **Applied 22 Aug 2026 — except the six enforcement test cases, written 25 Aug 2026**

| Target | Change |
|---|---|
[`../../60-delivery/TaskBreakdown.md`](../../60-delivery/TaskBreakdown.md) | **`FW-225`+**, additive. ⚠ **`FW-224` is reserved by `A6`.** Story rows are parsed by three `.xlsx` generators — plain rows, no strikethrough |
[`../../60-delivery/CapacityAndEffortModel.md`](../../60-delivery/CapacityAndEffortModel.md) | **A new additive sheet, never an in-place edit of a total** — the 3,186 h baseline is quoted in ~20 files |
[`../../70-testing/TestCases.md`](../../70-testing/TestCases.md) | **`TC-730`+** for the four verification blocks in the design: the legal-sequence counts, the handoff invariants, the two-partition intersection, and the alpha ignore-list |
`../../60-delivery/phases/phase-04-rod-checkin-plc-config.md` | Owns the handoff, the sequence validation and the acknowledgement |
`…/phase-09-output-coil-completion-labeling-packing.md` | Owns the rename and the per-order attribution |
`…/phase-01c-database-foundation.md` | Owns the two tables and the counts |

### `S6` — Master specification sync ✅ **Applied 22 Aug 2026**

Measured surface in `../../10-requirements/MasterSpecification.md`: **`32 tables` ×7 · `CoilAlpha` ×7 ·
`SharedCoilNo` ×1 · `FW-#####-C##` ×5 · `hub event` ×4.**

| Section | Change |
|---|---|
`FR-` register | The `FR-541`+ block mirrored, with `ORD003`–`ORD017` |
§11 `OI-##` | `OI-123`+ from `S1` |
Data model / table list | The two tables; the count in **all 7** places |
Alpha-format table | **`SharedCoilNo` → `CoilNo` only.** `CoilAlpha` and `FW-#####-C##` stay — all 12 of those occurrences are correct as written |
Hub events | **12 → 14**, and the status-summary line `PP-04` flags |
Traceability appendix | The rod → order hop added to the chain |

---

## 5. Blocked, and what it blocks

| | Item | Blocks |
|---|---|---|
| **B1** | **`OQ-M`** — does a spool unwind last-on-first-off? | Which coil the weld lands in, so the `CoilTraceability` rows and certificate parentage in `S2`'s screen text and `S5`'s test cases. **Build to LIFO meanwhile**; the tests must not assert FIFO |
| **B2** | **`OQ-A`** — can two orders on one rod have different pass schedules? | `ORD015`'s severity. If they can, rule 7 is conditional and `S2`'s handoff text needs a second branch |
| **B3** | **`OQ-H`** (`Q10` / `OI-45`) — the dimensional basis | Every weight figure. Inherited, not introduced here; the converter's `ConversionBasis` column is the accommodation |
| **B4** | **§9 F1** — does `coils` resolve inside CommonDB on the target instance? | `S3`'s deploy verification, and now FL1 as well as Phase 9. **Check before `S3` runs**, not after |
| **B5** | **`OQ-O`** — does the scrap-weight path mint from the same root namespace? Its implementation is **unscripted** (F12), so this needs the live instance | F9's collision guarantee, and therefore how strongly `S2` may state the one-namespace rule. **Check with `B4`** — both are questions about what CommonDB actually contains on the target server |

**None of these blocks `S1`.**

---

## 6. Verification

1. **Registers first.** After `S1`, re-grep the maxima and confirm no id was minted twice — the `G46`
   failure mode. Every new `Q##` has a `Recommendation:`; every `OQ-` in the design resolves to
   exactly one `Q##`.
2. **The DDL deploys and the constraints bite.** Teardown → `RunAll` → idempotent re-run on the
   shared instance, then re-assert the six behaviours already proven on a throwaway database:
   `CK_RodOrderAllocation_WeightRange` rejects a range ≠ allocation; `UX_RodOrderAllocation_Active`
   treats a NULL `RelLetter` as equal; `UX_RodOrderConsumption_Station` blocks a second open pairing;
   `CK_..._AckStamps` rejects a partial acknowledgement; `CK_..._Abandon` requires a checkout; the
   persisted computed columns compute.
3. **Publish the counts once**, from `sys.tables` / `sys.foreign_keys` / `sys.indexes` — then sweep
   the 24 files in one pass.
4. **`FR-`/`Q`/`OI`/`G`/`FW`/`TC` citations all resolve.** `grep` every id the new text introduces.
5. **The three coupled counts move together** — hub events in `SignalR.md` §5.2, the master spec's
   status summary and `BusinessRules.md` §3 (`PP-04`).
6. **`REVIEW.md` Tier 1** — confirm nothing added here re-asserts a known contradiction, and add the
   two G-1/G-2 corrections as entries.
7. **The client deliverables still build** — `build_docx.py` and `build_questions_xlsx.py`, the latter
   because `S1` changes both registers it parses.

---

## 7. What this plan does not do

- **No `MVP-2/` edits** beyond one optional pointer note (§2).
- **No shared-schema change.** `D-32` holds; the rename is `FlatWireDB`-local and the
  `@expectedCoilNo` parameter is on a flat-wire-owned procedure.
- **No `W3`–`W7` work.** The FL2 pre-check-in reversal, `SpoolStaging` and the `FR-031` rewrite stay
  with that ledger.
- **No decision on `OQ-A`, `OQ-M` or `OQ-H`.** They go to the client as `Q##` in `S1`.
