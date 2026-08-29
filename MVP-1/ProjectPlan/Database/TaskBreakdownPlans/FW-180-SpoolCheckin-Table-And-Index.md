# FW-180 · `SpoolCheckin` table and the `SpoolProcessing.OrderNo` index

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story — **build-state record**
**Status:** ✅ **Table BUILT.** ⛔ **`OI-25`'s two footage coordinate systems are unreconciled**
**Owner:** Database (SQL Server) stream
**Audience:** Anyone picking up `FW-180` and expecting to write the table
**Shortcode:** — *(implementation plan, derived from the DDL; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Database/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** ⛔ **To stop a rebuild, and to flag that one of this card's own
> constraints is WRONG.**
>
> **⛔ `CK_SpoolCheckin_PayoffPos` pins FL2's spool to payoff `1`** while `CanonicalEnums.cs`
> and the seeded `PayoffPosition` row both make it **`3` (`TraversingTakeup`)**. That is `G55`,
> and it is **silently wrong** — the column has no FK, so `TC-020`'s membership diff passes.
> [`FW-246`](FW-246-Constraint-And-RI-Repairs.md) resolves it; `P-163` recommends **`3`**.
> **⛔ `OI-25` — two footage coordinate systems, unreconciled.** `CoilOutput` accumulation
> versus `CoilTraceability`'s coil-local footage. **The same blocker `FW-202` carries**, and it
> makes a footage subtraction unsafe.
> **`ParentRodAlpha` is a LOGICAL link to the rod's `coils` row**, not an FK to a local table.
> **The `OrderNo` index exists to fix DB5's scan** — *"which validates against nothing"*.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-180 · `SpoolCheckin` table and the `SpoolProcessing.OrderNo` index
> **Hours:** 12 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** DB
>
> **As a** database owner,
> **I want** the spool queue's filter covered by an index,
> **So that** a `WHERE OrderNo =` on a `VARCHAR(50)` does not scan.
>
> **Acceptance Criteria:**
> - [ ] `SpoolCheckin` write path live, `LineId` restricted to FL2/FL3
> - [ ] `FlatWireRun` FL2 run header created on check-in; `SpoolProcessing.Status = INFLAT`
> - [ ] **New index on `SpoolProcessing.OrderNo`** — unindexed today. It also fixes DB5's scan, which validates against nothing
> - [ ] Reads wired: source FL1 run gauge trace + `WeldEvent` markers, `SpoolProcessing.SourceRunId` / `ParentRodAlpha`
> - [ ] `SpoolProcessing.ParentRodAlpha` documented as a **logical link to the rod's `coils` row**, not an FK to a local table
>
> **Rate-card basis:** 2 tables/indexes @ 4 h = 8 h + FL2 run header wiring 4 h = 12 h (§2)
> **Dependencies:** FW-007
> **Blockers:** **OI-25** *(the two footage coordinate systems — `CoilOutput` accumulation vs `CoilTraceability`'s coil-local footage — are unreconciled)*

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| The **write path** | ⚠ **Backend** — [`FW-179`](../../Backend/TaskBreakdownPlans/FW-179-CheckIn-Spool-And-Spools-Query.md) |
| `CK_SpoolCheckin_PayoffPos`'s wrong value | ⛔ [`FW-246`](FW-246-Constraint-And-RI-Repairs.md) — `G55`, `P-163` |
| The spool this checks in | [`FW-202`](../../Backend/TaskBreakdownPlans/FW-202-FL1-Spool-Completion.md) — nothing else creates it |
| The FL2 null-gauge contract | [`FW-181`](../../Backend/TaskBreakdownPlans/FW-181-FL2-Null-Gauge-Contract.md) |
| Reconciling the footage systems | ⛔ **`OI-25`** — unowned |

### 1.2 What already exists

⛔ **The table and the index are deployed.** Verified 29 Aug 2026.

| Object | State |
|---|---|
| `SpoolCheckin` table | ✅ **Built**, `04_Runs.sql` |
| ⛔ **`CK_SpoolCheckin_PayoffPos`** | ✅ Built — **and it says `= 1`** (`04_Runs.sql:690`). ⚠ Its comment at `:679` records it was *"copied from `RodCheckin`"* — **the origin of the defect** |
| `PayoffPosition` seed row `3` | `01_Lookup.sql:285` — `TraversingTakeup`, *"Traversing take-up (**FL2**)"* | ✅ Built |
| `SpoolProcessing.OrderNo` index | ✅ Built, `07_Indexes` |
| `SpoolProcessing` | ✅ Built — ⛔ **nothing writes it** until `FW-202` |
| `SpoolTraceability`, `SpoolOrder` | ✅ Built 22 Aug 2026 |
| `INFLAT` | ✅ In `SpoolProcessing.Status`'s `CHECK` — ⚠ **`FlatWireDB`-local only** after `D-32` |
| **The write path** | ⛔ **Absent** — `FW-179`'s |
| **A reconciled footage basis** | ⛔ **Absent** (`OI-25`) |

---

## 2. The three details

### 2.1 ⛔ `G55` — this card's own constraint contradicts the lookup it should reference

| Source | FL2's payoff |
|---|---|
| `CK_SpoolCheckin_PayoffPos` (`04_Runs.sql:690`) | **`1`** |
| `PayoffPosition` seed (`01_Lookup.sql:285`) | **`3`** — labelled *"(FL2)"* |
| `CanonicalEnums.cs` | **`3`** — `TraversingTakeup` |

⚠ **Two against one, and the outlier explains itself**: the comment at `:679` records that the
constraint was **copied from `RodCheckin`**, where payoffs really are 1 and 2. **FL2 has no VPS
payoff at all — it has a traversing take-up.**

⛔ **`TC-020`'s membership diff passes over this** because the column has **no FK** — the diff
compares *sets*, and there is no set to compare against. **The disagreement is about *meaning*,
which is why an automated check could not see it.**

✅ **[`FW-246`](FW-246-Constraint-And-RI-Repairs.md)'s `P-163` recommends `3`** and notes that
choosing `1` would require **two** artifacts to move rather than one.

⚠ **`G50`'s hole (b)** — the payoff position modelled two ways, some tables FK'd and some
carrying a bare integer — **is what made this possible.** Fixing (b) prevents the next one.

### 2.2 ⛔ `OI-25` — two footage coordinate systems

`CoilOutput` accumulation versus `CoilTraceability`'s **coil-local** footage, **unreconciled**.

⚠ **This is the same blocker [`FW-202`](../../Backend/TaskBreakdownPlans/FW-202-FL1-Spool-Completion.md)
carries**, and `P-222` records why it matters there: a footage subtraction is only meaningful
**inside one** coordinate system, and across them it yields a plausible number wrong by an
offset.

**Here it bites on AC 4's reads** — *"source FL1 run gauge trace + `WeldEvent` markers"*. A weld
marker positioned in FL1's run footage, rendered against an FL2 coil-local axis, lands in the
wrong place **and looks right**.

⛔ **So `OI-25` is not a downstream concern**: it decides how the FL1 trace is projected onto the
FL2 view, which is the whole point of AC 4.

### 2.3 `ParentRodAlpha` is a logical link, and `INFLAT` is now local

AC 5: `SpoolProcessing.ParentRodAlpha` is **a logical link to the rod's `coils` row, not an FK to
a local table**. ⚠ `G17` records the general case — every rod-alpha reference is a cross-database
logical FK.

⚠ **AC 2 needs re-reading after `D-32`.** *"`SpoolProcessing.Status = INFLAT`"* is still correct
— but `INFLAT` is now **`FlatWireDB`-local only**, one of exactly three places it survives
(`Rod.Status`, `SpoolProcessing.Status`, `RodCheckout.NewRodStatus`). ⛔ **It is not written to
the shared `coils` row**, and `FR-077`'s `coils.coil_status` write is **struck**.

---

## 3. Build order

**Nothing to build in the DB stream.** The remaining work:

1. ⛔ **Do not re-create the table or the index** (§1.2).
2. ⛔ **`FW-246` fixes `CK_SpoolCheckin_PayoffPos`** — and any seeded `SpoolCheckin` row carrying
   `1` must move with it, or the new constraint rejects the seed (§2.1).
3. ⛔ **Escalate `OI-25`** — it decides AC 4's trace projection, not just downstream arithmetic
   (§2.2).
4. The write path is [`FW-179`](../../Backend/TaskBreakdownPlans/FW-179-CheckIn-Spool-And-Spools-Query.md)'s.
   ⚠ **And `[API §4.6a]`'s worked example is stale** — it shows a check-in the contract must
   refuse **twice**, by `SCHEDULE_NOT_ACTIVE`/`422` and by `FR-091`.
5. ⚠ Confirm the `OrderNo` index is actually used by DB5's query once `FW-179` lands — `P-191`'s
   rule: **an index story closes on a captured plan.**

---

## 4. Decisions this plan makes

> The `P-##` series belongs to [`Backend/TaskBreakdownPlans/`](../../Backend/TaskBreakdownPlans/)
> and is continuous across the repository; `P-01`–`P-240` precede this story.

### `P-241` — `OI-25` is escalated as an AC 4 blocker, not a downstream one

§2.2. It is normally read as an arithmetic question for coil completion. **Here it decides
whether the FL1 gauge trace and its weld markers can be rendered on an FL2 view at all** — and a
misprojected marker is **plausible and wrong**, which is the worst failure shape.

⚠ **`FW-202` carries the same blocker for a different reason** (`P-222`) — **one gap, two
stories, two distinct consequences.**

---

## 5. Verification

| Check | Expected |
|---|---|
| Table | `SpoolCheckin` present; `LineId` restricted to **FL2/FL3** |
| **⛔ Payoff constraint** | `CK_SpoolCheckin_PayoffPos` says **`3`** after `FW-246` — currently **`1`** (`G55`, §2.1) |
| Seed consistency | No seeded `SpoolCheckin` row carries the old value |
| Index | `SpoolProcessing.OrderNo` indexed — ⚠ and **the plan captured** once `FW-179` lands (`P-191`) |
| `INFLAT` | Set on `SpoolProcessing.Status` only; ⛔ **not written to shared `coils`** (§2.3) |
| `ParentRodAlpha` | Documented as a **logical** link, no local FK (`G17`) |
| **AC 4 reads** | FL1 gauge trace and weld markers project correctly onto the FL2 view — ⛔ **blocked by `OI-25`** (`P-241`) |
| FL2 run header | `FlatWireRun` created on check-in — `FW-179`'s |

---

## 6. Handoff

[`FW-179`](../../Backend/TaskBreakdownPlans/FW-179-CheckIn-Spool-And-Spools-Query.md) owns the
write path — ⚠ **and `[API §4.6a]`'s worked example is stale**.
[`FW-246`](FW-246-Constraint-And-RI-Repairs.md) fixes `G55` and `G50`'s hole (b), which is what
made `G55` possible. [`FW-202`](../../Backend/TaskBreakdownPlans/FW-202-FL1-Spool-Completion.md)
creates the spool this checks in and shares `OI-25`.
[`FW-181`](../../Backend/TaskBreakdownPlans/FW-181-FL2-Null-Gauge-Contract.md) governs what the
FL2 view shows.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`G55`** | The constraint says `1`, the lookup and the enum say `3`. **Silently wrong** — no FK, so `TC-020` passes (§2.1) |
| ⛔ **`OI-25`** | Two unreconciled footage systems — **an AC 4 blocker here** (`P-241`) |
| **`G50`** hole (b) | Payoff position modelled two ways — **the cause of `G55`** |
| **`G17`** | Rod-alpha references are cross-database logical FKs |
| **`D-32`** | `INFLAT` is `FlatWireDB`-local; `FR-077`'s shared write is **struck** |
| ⚠ **`[API §4.6a]`** | Its worked example is **stale** — shows a check-in that must be refused twice |
