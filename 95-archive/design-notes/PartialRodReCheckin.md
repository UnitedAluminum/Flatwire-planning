# Partial-Rod Re-Check-In and Traceability Carry-Forward

**Project:** Flat Wire Mill Implementation
**Question Ref:** Q12 — [FlatWireOpenQuestions.md](../../90-registers/Questions.md)
**Priority:** High
**Owner:** Jaspreet / Tim O.
**Document Type:** Design rationale — **internal**. *Not* a client-facing requirement specification
**Status:** Reference — rules consolidated into the owning requirement documents 11 Aug 2026; `Q12` remains open
**Last Updated:** August 25, 2026 — the `02-SRS.md` link label updated to `BusinessRequirements.md` `[REQ]` *(previously August 11, 2026)*

---

> ## ⚠ This is not one of the client-facing requirement specifications
>
> It sits in this folder to be beside the two documents that own its rules, but it is **not** a member of the
> seventeen per-screen specifications: it carries no reading convention, no confirmed-decisions table and no
> client sign-off sheet, and **nothing in it is citable as a requirement**. It is the design rationale behind
> `Q12` and the audit trail for that question, which is still open. **Do not add a new rule here** — new rules
> belong in the owning document.
>
> ### Where the rules live
>
> | What you want | Where it now lives |
> |---|---|
> | The **carry-forward gate** at the staging scan, and the rule that no fresh-start path is offered | [`RodPreCheckin.md`](../../10-requirements/screens/RodPreCheckin.md) §7 |
> | **Why partial material takes its own identity**, linked back to the rod | [`RodCheckout.md`](../../10-requirements/screens/RodCheckout.md) §7.2 |
> | Mode B checkout, supervisor acceptance, and the resulting rod status | [`RodCheckout.md`](../../10-requirements/screens/RodCheckout.md) §3, §7 |
> | The **delivered requirement text** | `FR-043` in [`BusinessRequirements.md`](BusinessRequirements.md) `[REQ]`, tested by `TC-050` / `TC-051` |
>
> ### Two reading traps
>
> **1. The identifiers in every worked example below are wrong.** This document uses `ROD-00412` and
> `SPL-00891`. The canonical formats are **`R#####`** for a rod and **`SP-#####`** for a spool. This is
> recorded as gap **G14** and flagged in the master specification — **normalise before building anything from
> this file.** The examples were never reconciled after the alpha formats were settled.
>
> **2. The snake_case column names below are proposals, not field names — but the design they propose was
> built.** All three landed in `FlatWireDB` on 26 July 2026 under PascalCase names, so read the left column
> as history and the right column as the schema:
>
> | Proposed here (May 2026) | Delivered ([`FlatWire_DDL_03_Materials.sql`](../../30-database/sql/FlatWire_DDL_03_Materials.sql)) |
> |---|---|
> | `footage_run_to_date` on the rod record | `Rod.FootageRunToDate` `DECIMAL(10,2)` |
> | `remaining_weight_estimate` on the rod record | `Rod.RemainingWeightEstimateLb` `DECIMAL(8,2)` |
> | `source_rod_alpha` FK on the spool | `SpoolProcessing.SourceRodAlpha` → `Rod.Alpha`, with `IX_SpoolProcessing_SourceRodAlpha` |
>
> The staging-side gate is `RodStaging.FootageRunToDateAtStaging` (`> 0` forces carry-forward, `PRC007`).
> **Jaspreet's schema-impact item in *Open Items Before Development* below is therefore closed** — it is left
> unticked as written, because that list is the April/May record.

---

## The Gap

The system currently has no defined behavior for the scenario where a rod is placed on the payoff, the line runs for some footage, and then the rod is removed and returned to storage **before it is exhausted**. Three interdependent design questions are left open:

| Decision Point | Why It Matters |
|---|---|
| **Can the rod be re-checked-in at all?** | If the answer is "no," the operator must scrap or hold the partial rod outside the system — a manual workaround that creates a ghost inventory item the system doesn't know about. |
| **Does re-check-in carry forward footage run + remaining weight, or start fresh?** | If it starts fresh, the rod's original weight is restored in the system even though material was already drawn. The next run's weight-to-footage estimate will be wrong, and the rod's complete processing history will be split across disconnected records. |
| **Can one rod produce multiple partial spool alphas across separate runs?** | The alpha model needs to support this explicitly — otherwise the second run will try to generate a new alpha with no linkage back to the first partial spool, breaking the material genealogy chain. |

### Why This Is High Priority

Every downstream system touches this decision:

- **Planning / Rod Inventory** — Rod weight on hand drives input sizing. If the system resets rod weight on re-check-in, planners will think they have more material than they do and under-order rod for future jobs.
- **Spool Alpha and Cert Generation** — A certificate of conformance must reflect every heat the rod material came from and every processing step it underwent. A fresh record on the second check-in severs the genealogy between the two partial spools.
- **Footage-to-Weight Accounting (Q10)** — Because weight is derived from footage (not a scale), the carry-forward footage figure is the only way to calculate remaining rod weight correctly on the second run.
- **Rod Checkout Authorization (Q74 / Q75)** — The disposition authority question (operator vs. supervisor) only makes sense once it's settled whether the rod re-enters inventory as a tracked partial item or disappears from the system.

---

## Recommendation

**Implement carry-forward as the default, with a single persistent rod record.**

### 1. Rod Record — Two New Fields

The rod inventory record gains two fields: `footage_run_to_date` and `remaining_weight_estimate`. On first check-in both are zero / full weight. After each partial run the system updates both fields when checkout is confirmed.

### 2. Re-Check-In Retrieves the Existing Record

Re-check-in does **not** create a new rod record. It retrieves the existing record by the rod's barcode/alpha, shows the operator the footage already run and remaining weight, and requires an explicit confirmation before proceeding.

### 3. Each Run Segment Produces Its Own Partial Spool Alpha

Each separate run produces its own spool alpha, but all partial spool alphas for the same rod carry a `source_rod_alpha` foreign key so the genealogy chain is preserved end-to-end. The cert query joins through that key to reconstruct the full rod history regardless of how many separate runs it took.

### 4. Fresh-Record Re-Check-In Is Blocked

The system will refuse to treat a partial rod as if it were a brand-new, never-run rod when it comes back for a second run. When an operator scans a rod at the payoff, the system looks up that rod's record. If it finds `footage_run_to_date > 0`, it will **not** allow the operator to proceed as if checking in a fresh rod. Instead it forces them down the carry-forward path — showing the existing footage and remaining weight — so that history is never wiped.

**Without this block**, an operator (accidentally or intentionally) could scan the same partial rod, the system creates a new clean record, and:
- The rod's prior footage vanishes from the record — the cert will never show the first partial run
- The system thinks the rod has its full original weight, so the footage-to-weight math on the second run is wrong from the first foot
- The first partial spool alpha has no traceable source rod anymore — it becomes an orphan in the genealogy

---

## UI Flow — Partial Re-Check-In Screen

When the operator scans a rod that has prior footage, instead of a normal check-in screen they see:

```
┌─────────────────────────────────────────────────────────────────┐
│  This rod has prior run history                                 │
│                                                                 │
│  Footage already run:    312 ft                                 │
│  Remaining weight est:   18.4 lb                                │
│  Last run:               FL1 — Run #4821 — April 25, 2026       │
│                                                                 │
│  [Proceed as partial re-check-in]        [Cancel]              │
└─────────────────────────────────────────────────────────────────┘
```

The normal "start fresh" path is not available — it does not appear as a button. The only way forward is to acknowledge the history and continue from it.

---

## Full Sequence When Operator Clicks "Proceed as Partial Re-Check-In"

### Step 1 — System Loads the Rod's Existing Record

The system retrieves ROD-00412 and pre-populates the check-in screen with carried-forward values:

```
Rod Alpha:              ROD-00412
Original Weight:        45.2 lb
Footage Already Run:    312 ft
Remaining Weight Est:   18.4 lb   ← starting weight for this run
Last Run:               FL1 — Run #4821 — April 25, 2026
Status:                 Partial — Returned to Storage
```

### Step 2 — Operator Confirms Physical Rod Matches

The screen asks the operator to confirm the rod on the payoff is physically the same rod — weight check, label scan, or visual confirmation. This prevents accidentally scanning the wrong rod and inheriting another rod's history.

### Step 3 — System Opens a New Run Record

A new run record is created with a new run number, timestamp, operator ID, and machine assignment. This run is linked back to ROD-00412 but is a separate, independent run event.

```
New Run:          Run #4956
Rod:              ROD-00412  (partial re-check-in)
Machine:          FL1
Operator:         [current operator]
Start Footage:    0 ft   ← footage counter on THIS run starts at zero
Starting Weight:  18.4 lb
```

The footage counter starts fresh for this run. The 312 ft from the first run belongs to Run #4821 and SPL-00891, not to this new run.

### Step 4 — Line Runs Normally

From this point the run behaves exactly like any normal run. SCADA/PLC feeds footage in real time. SPC checkpoints fire as configured. The operator monitors the line.

### Step 5 — Run Ends

**Scenario A — Rod runs out naturally:**

- System records footage produced on this run (e.g., 480 ft)
- Generates new spool alpha **SPL-00892** for 480 ft, with `source_rod_alpha = ROD-00412`
- Updates ROD-00412: `footage_run_to_date = 792 ft` (312 + 480), `remaining_weight = 0`, `status = Exhausted`
- Closes Run #4956

**Scenario B — Rod is removed again before exhaustion:**

- System repeats carry-forward logic
- ROD-00412 updated: `footage_run_to_date` incremented, `remaining_weight` recalculated
- New partial spool alpha generated for footage produced in this run
- Rod status returns to `Partial — Returned to Storage`

---

## Spool Alpha Model

### Background — What an Alpha Is

In the UAL system, an **alpha** is the unique identifier assigned to a unit of material. It is the traceability handle — every cert, every quality record, every disposition ties back to an alpha. For flat wire, the output unit is a **spool**, so a spool alpha represents one finished or partial spool of wire.

### Why Two Alphas Instead of One

Each spool physically exists as a separate object — wound onto a separate bobbin, potentially moved, inspected, annealed, or shipped independently between runs. Two physically separate spools cannot share one alpha because there would be no way to track them individually after they leave the machine.

Each run may also have different conditions — different operator, die, pass schedule, SPC readings. Those conditions attach to the alpha at the time of the run. Merging them into one alpha would mean the cert cannot distinguish which footage was produced under which conditions.

### Why `source_rod_alpha` Matters

Without a linkage field, two spool alphas from the same rod have no connection in the database. The `source_rod_alpha` foreign key on each spool alpha record solves this:

```
SPL-00891  →  source_rod_alpha = ROD-00412
SPL-00892  →  source_rod_alpha = ROD-00412
```

The cert query can then say: *"Both spools trace back to ROD-00412, which came from Heat #H7741, alloy 1350, received March 10."* The genealogy is complete across both runs.

### The Alternative and Why It Fails

If the system used **one alpha for the whole rod across both runs**, it would have to hold the alpha open in a pending/incomplete state between runs. During that gap:

- The first 312 ft sitting in storage has no settled alpha to attach a label to
- If it gets inspected, annealed, or shipped during the gap, there is nothing to record against
- If the second run never happens (rod is scrapped), the alpha is never closed and the first spool becomes a ghost

Two alphas — one per run segment, both pointing back to the same rod — is the only model that keeps each physical spool independently trackable from the moment it leaves the machine.

---

## Full Traceability Picture After Two Runs

```
ROD-00412
├── Original Weight:       45.2 lb
├── Total Footage Run:     792 ft
├── Status:                Exhausted
│
├── Run #4821  (April 25, 2026)
│   ├── Machine:   FL1
│   ├── Operator:  [Operator A]
│   └── SPL-00891 — 312 ft — Partial Spool
│
└── Run #4956  (April 28, 2026)
    ├── Machine:   FL1
    ├── Operator:  [Operator B]
    └── SPL-00892 — 480 ft — Partial Spool
```

Both spool alphas are independently trackable. Both certs trace back through the run records to ROD-00412 and from there to the original heat, alloy, and receiving record. The genealogy chain is unbroken across both runs.

---

## Related Questions

| Q# | Question | Dependency |
|---|---|---|
| Q10 | Footage-to-weight conversion factor | Remaining weight estimate calculation depends on this factor being defined per alloy/cross-section |
| Q74 | Mid-run rod checkout authorisation level | Who is permitted to remove a rod mid-run and trigger the carry-forward flow |
| Q13 | PLC tag behaviour on rod checkout | Whether PLC tags are cleared immediately or after a safe-stop handshake when checkout is confirmed |
| Q75 | Partial-run material disposition authority | Whether operator alone can accept partial spool footage or supervisor approval is required |
| Q78 | Spool alpha continuity through anneal or re-pass | Whether a partial spool alpha retains its identity after an anneal between runs |

---

## Partial Decisions — May 4, 2026

Tim O. provided the following partial answers. Full carry-forward design is deferred.

| Point | Tim's Answer |
|---|---|
| **Can partial rod return to storage?** | Yes, the rod can return to warehouse. Any material that has been drawn/rolled will be scrapped — it remains in the mill. The rod itself (undrawn/unprocessed portion) is what returns. |
| **Weigh remaining rod at payoff?** | Potentially yes — Tim has asked Scott, Bob, and Shannon to confirm whether a small scale at the payoff position should be available to weigh the remaining material going back to WH. |
| **Multiple partial spool alphas per rod?** | Yes, this functionality is needed. There is always potential for a rod to produce partial spool alphas across separate runs. |
| **Carry-forward design (full answer)?** | Deferred — Tim will confirm. |

## Open Items Before Development

- [ ] **Tim O.** to provide full confirmation of the carry-forward design (persistent rod record, footage_run_to_date, remaining_weight_estimate).
- [ ] **Scott / Bob / Shannon** to advise on whether a payoff scale is available or required for weighing partial rods returned to WH.
- [ ] **Jaspreet** to confirm schema impact: `footage_run_to_date` and `remaining_weight_estimate` columns on rod inventory table, `source_rod_alpha` FK on spool alpha table.
- [x] **Q74 Resolved (May 4, 2026):** Supervisor approval required for mid-run checkout. The carry-forward screen will require supervisor sign-off before the new run is opened.
- [x] **Q75 Resolved (May 4, 2026):** Supervisor must approve material disposition (accept / hold / reject) before partial spool alpha is generated.
