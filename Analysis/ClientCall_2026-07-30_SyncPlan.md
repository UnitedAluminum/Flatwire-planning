# Client Call 30 Jul 2026 — Document Sync Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 1, 2026
**Status:** **Executed 1 Aug 2026 — waves W1–W7 complete, W8 cancelled.** Eleven client answers propagated across the registers, the analysis notes, the schema + DDL (rebuilt and constraint-tested), the contracts, the mockups and the July 30 project-plan set. Outstanding work is now the client follow-up list in §6, not document sync.
**Source:** Client call 30 Jul 2026 (Tim O., Bob S., Shannon R., Srikanth, Shray) — answers to the eleven pre-check-in / check-in / spool questions raised from [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md) and [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md).
**Registers touched:** `OQ-##` ([FlatWireOpenQuestions.md](FlatWireOpenQuestions.md), 77 → 81) · `OI-##` ([FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §11) · `G##` ([back-matter.md](../DevelopmentPlan/ShopfloorPlan/back-matter.md))

---

## 1. Why this needs a plan rather than eleven edits

Three of the eleven answers **reverse decisions already built into delivered artifacts**, and each of those reversals is currently persisted in DDL constraints, API contracts, mockup JavaScript and test cases:

| # | Reverses | Currently persisted as |
|---|---|---|
| 4 | Q74 off-schedule **supervisor override** (decided Jul 29) → **auto-select the correct station** | `RodStaging.OffScheduleOverride` + 4 columns, `CK_RodStaging_OffSched`, the 2A override panel, `POST /staging/rod` fields, test cases |
| 8 | Q77 — Unstage **removed** from welded rods (decided Jul 31) → **allowed with supervisor override** | Dashboard 2A queue renderer (`No Unstage on a welded rod`), the Jul 31 change-log entry in three docs |
| 9 | Q67 interim design — pre-check-in sets `coils.coil_status = INFLAT` per SRS §4.2 → **`INFLAT` only at check-in** | `RodPreCheckin.md` non-decision #2, master spec §4 note + **OI-01**, phase-04 write list |

Editing those in isolation leaves the DDL, the contract and the mockup asserting the superseded rule. The waves in §4 exist so the reversal lands everywhere in one pass.

Two further answers are **not decisions but scope changes** (item 7 multiple orders per rod, item 11 panel resolution), and two are **decided in principle with the numbers still owed by e-mail** (item 6 tolerances, item 10 customer weight range). Those must be recorded as decided-with-a-blocking-value, not silently implemented against invented numbers.

---

## 2. Decision ledger — the eleven answers mapped to register IDs

| # | Topic | Register ID | New status | Effect |
|---|---|---|---|---|
| 1 | No rod stacking on a payoff; **two rods total, one per payoff** | **Q75** · **new Q81** | `Decided` | Closes Q75. Confirms `UX_RodStaging_Bay` and leaves `CK_WeldEvent_PayoffDiff` as-is. **Does not close** the 8,690–8,840 lb vs 2,000 lb bundle-weight contradiction that was logged inside Q75 — re-homed as **Q81** so it survives Q75 closing |
| 2 | Out-of-planned-sequence needs supervisor override — "leave it in place", re-confirm next review | **Q74** (sequence part) | `In Progress` — provisionally confirmed | No artifact change. Record the provisional confirmation and the re-review commitment |
| 3 | Rod/order not scheduled on **either** FL1 or FL3 | **new Q78** | `Open` | Not covered on the call. Carry forward. **Keep the override credential block** until this closes — it is the surviving use for it after item 4 |
| 4 | Rod planned for the other station → **auto-switch the tab**, no blocking message, same for pre-check-in and check-in | **Q74** (off-schedule part) | `Decided` — supersedes Jul 29 | Off-schedule stops being an authorisation and becomes a **navigation behaviour**. See §3.1 |
| 5 | Failed staging inspection → capture rejection reason on the rejection screen, rod → **HOLD**; no separate status for welded-not-checked-in | **Q72** item 3, **Q67** part | `Decided` (Q72 item 3) | Gives the blocked row its exit: WIP rejection sets rod `HOLD` and releases the bay. See §3.4 |
| 6 | **Min/max** tolerances exist for height (gauge), width, diameter **and ovality**; values to follow by e-mail; apply at pre-check-in **and** check-in | **Q71** | `Decided` — values pending | Shape confirmed, and it is **min/max pairs, not a single ±**. See §3.5 |
| 7 | Multiple orders on one rod **is valid**; sequencing still open (Srikanth); MVP2 deferral to confirm | **Q69**, **Q70**, **new Q79** | Q69 `Decided` (multi-order valid) · Q79 `Open` | Breaks the "one established order, cross-order rod refused" rule the staging validation is built on. See §3.6 |
| 8 | Pre-check-out: **welded → supervisor override + HOLD + documented reason** (it is a rejection); not welded → operator-only with reason | **Q68** `Decided` · **Q77** `Decided` | Both close | Reverses the Jul 31 removal of Unstage on welded rods; adds supervisor columns to `RodCheckout` Mode P. See §3.2 |
| 9 | `INFLAT` **only at check-in**; no intermediate status | **Q67** | `Decided` (Critical — unblocks Phase 4) | Reverses the interim SRS-following design. See §3.3 |
| 10 | Short close = **unplanned stop**, mill 10-90 logic, graded against **customer min/max weight**; outside range → supervisor override + production hold, or offer under concession before remake; spool **must be run off** either way. Coil break mid-run: stop removed, **new stop from zero**, weight does not resume | **Q65** `Decided` · **Q60** part-decided | Q65 closes | Replaces the assumed 2,000 lb default target with an order/customer weight range. See §3.7 |
| 11 | Panel resolution — Tim expects 1280×1024 (stocked), will verify with Charles/Juan; we send the required 1920×1080 by e-mail | **new Q80** | `Open` | Every mockup, `flat-wire-fit.js` and the phase-01a canvas are pinned to 1280×1024. See §3.8 |

**Register arithmetic:** OQ 77 → **81** (Q78 not-scheduled-anywhere · Q79 multi-order sequencing · Q80 panel resolution · Q81 bundle gross weight). Shopfloor scope 50 → **54**; shopfloor open/in-progress stays **35** as five close and four are added. Newly `Decided`: Q65, Q67, Q68, Q69, Q75, Q77 — six, with Q60 (basis), Q71 (shape), Q72 (item 3) and Q74 (off-schedule) part-decided and still `In Progress`. Shopfloor `Critical` open count drops by one (Q67).

> **Also fixed in passing:** Q76 and Q77 were added on Jul 31 but never reached the Quick Reference table, and the filtered-index counts had gone stale at 35/13 when the true figures were 37/13. Both corrected.

---

## 3. The eight substantive changes, with their blast radius

### 3.1 Item 4 — off-schedule becomes auto-switch, not an override

**Rule to write:** when the scanned rod's order is booked on the *other* rod line, the screen **switches to that line's station** and continues; no message, no refusal, no supervisor. Applies identically to Dashboard 2A (pre-check-in) and Dashboard 2 (check-in).

**Decided (Aug 1, 2026): the `OffSchedule*` columns are dropped.** The analysis recommendation had been to retain them unwritten against Q78; the project decision is to remove them. Concretely that is `RodStaging.OffScheduleOverride`, `ScheduledLineId`, `OverrideBy`, `OverrideAt`, `OverrideReason` and `CK_RodStaging_OffSched`, plus the off-schedule arm of `CK_RodStaging_Override` — which was generalised on Jul 30 to cover *either* deviation and now reverts to out-of-sequence only.

**Two consequences to carry, not discover:**

1. `OverrideBy` / `OverrideAt` / `OverrideReason` are **shared** with the out-of-sequence override (item 2 / Q74, which stays). Those three columns must **survive**; only `OffScheduleOverride` and `ScheduledLineId` are genuinely removed, and `CK_RodStaging_Override` must be rewritten to key the trio off `OutOfSequenceOverride` alone. Dropping all five would delete the surviving override's audit trail.
2. If **Q78** (item 3 — rod scheduled on no rod line at all) later needs an authorisation, it re-adds a column group rather than reusing this one. Note that in Q78's text so the cost is visible when it is answered.

**Files:** `RodPreCheckin.md` (order-lookup table row 4, the *Off-schedule staging is authorised* paragraph, validations table) · `FlatWireOpenQuestions.md` Q74 · ~~`Dashboard2A_UXReview.md`~~ (deleted 1 Aug 2026) · `FlatWireSchema_Runs.md` · `FlatWire_DDL_04_Runs.sql` (comment only, if retained) · `APIContracts.md` + `04-APIContract.md` (`POST /staging/rod`, `GET /rod/{alpha}` — `scheduledLineId` now drives navigation) · `02-SRS.md`, `03-HLD-and-ERDiagram.md`, `06-TestPlanAndTestCases.md` · `dashboard_2a_rod_precheckin.html` (override panel, `offScheduleOverride` state, the bay-card "Off-schedule — authorised by …" slot) · `dashboard_2_rod_checkin - New.html` + `_fl3.html` (auto-switch on scan) · `FlatWire_MasterSpecification.md`.

**Consequence to state, not discover:** auto-switching moves the operator between two stations mid-transaction. Specify what happens to a partially completed wizard, and whether the FL3 tab exists on the FL1 panel at all (this is **Q73** — which station FL3 posts to — surfacing again as a UI question).

### 3.2 Item 8 — welded pre-check-out is a supervisor-approved rejection

**Rule to write:** un-staging a rod with `IsWelded = 1` requires supervisor override (reason + badge/ID + PIN, remote fallback), sets the rod to **HOLD**, and is recorded as a rejection because the material must be cut. Un-staging an unwelded rod needs a reason only.

**Schema delta (real, not cosmetic):** `RodCheckout` has **no supervisor columns at all** — Mode B's "supervisor approval" (Q48) is likewise unpersisted. Add `ApprovedBy` / `ApprovedAt` / `OverrideReason` (nullable) and a `CK_RodCheckout_ModePWelded` requiring them when a Mode P row un-stages a welded rod, plus `NewRodStatus = 'HOLD'` for that case. `CK_RodCheckout_ModeP` itself is unaffected (still no run, no footage, no tags).

**Closes `WLD011`** (supervisor reversal of a weld) in the un-staging direction only — say so, because `WLD011` also covers reversing a weld on a rod that stays staged.

**Files:** `RodPreCheckin.md` (bay-state table, vocabulary table, non-decision #3) · ~~`Dashboard2A_UXReview.md` (the Jul 31 "Unstage removed" finding is now superseded — annotate, do not delete)~~ **— superseded 1 Aug 2026: the file was deleted instead (git history at `2a0426b`). The annotation is therefore not owed; the substance survives in Q77, which records that a welded rod may be released by a supervisor as a rejection to `HOLD`.** · `RodCheckout.md` · `WeldEvent.md` · `FlatWireSchema_QualityOutput.md` + `FlatWire_DDL_05_QualityOutput.sql` + `FlatWire_ERDiagram_Documentation.md` · `APIContracts.md`/`04-APIContract.md` (`DELETE|POST /staging/rod/{alpha}` un-stage body) · `dashboard_2a_rod_precheckin.html` (reinstate a supervisor-gated Unstage on welded rows, routed to rejection) · `phase-04`, `phase-07` · `02-SRS.md`, `06-TestPlanAndTestCases.md` · master spec.

### 3.3 Item 9 — `INFLAT` at check-in only (Critical, unblocks Phase 4)

**Rule to write:** pre-check-in does **not** set `coils.coil_status = INFLAT`. The status changes at check-in on FL1. No intermediate status for welded-but-not-checked-in.

**Answered:** Q67 part 1. **Still open and must stay open:** whether pre-check-in still performs the `FlatwireQueue` insert, the reqsum and the `wip_coil_orders` insert (Q67 parts 2–3). Tim answered *status*, not *commitment*. If the WIP/reqsum writes remain at staging, the compensating-write burden (G2/G16) is unchanged and only the status column moved; if they also move to check-in, pre-check-out becomes a pure FlatWireDB delete and OI-01 closes completely. **Put this question in the follow-up list (§6) rather than assuming.**

**Consequence:** rod status `STAGED` stops being vestigial and becomes the real staging status — which re-aligns with [FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) step 8 and against SRS §4.2's `PCI` data note. The SRS §4.2 note is now **wrong** and must be marked superseded wherever it is quoted.

**Files:** `RodPreCheckin.md` non-decision #2 · `FlatWireProcessWalkthrough.md` (now the winning source — note that) · `FlatWireOpenQuestions.md` Q67 · master spec §4 note + **OI-01** · `03-HLD-and-ERDiagram.md` (transactional boundary) · `phase-04` write list (`existing coils rod row → INFLAT` moves from the staging bullet to the check-in bullet) · `phase-01c` if it restates it · `APIContracts.md` staging side-effects · `dashboard_2a_rod_precheckin.html` header comment.

### 3.4 Item 5 — the blocked bay finally has an exit

**Rule to write:** a failed staging inspection routes to WIP Rejection, the operator captures the rejection reason there, and the rod goes to **HOLD**. That is what releases the `RodStaging` row and frees the bay.

This is the **Q72 item 3 blocking residual** — "`Status` has no value for a WIP-rejection outcome". Pick one and write it into the DDL: either a new `Status` value (`Rejected`) outside `UX_RodStaging_Bay`'s filter, or reuse `Unstaged` with a `RodDisposition`-style discriminator. **Recommendation: reuse `Unstaged` plus a `ReleaseReason`** — a new status value multiplies the branches in every "staged" query, and the bay is genuinely free once the bundle leaves.

**Files:** `FlatWireSchema_Runs.md` + `FlatWire_DDL_04_Runs.sql` (+ `07_Indexes` if the filter changes) · `RodPreCheckin.md` bay-state table · ~~`Dashboard2A_UXReview.md`~~ (deleted 1 Aug 2026) · `dashboard_2a_rod_precheckin.html` + `wip_rejection.js` (rejection reason capture from a staging context — **delivered 1 Aug 2026**, when the screen became a dialog and the caller began supplying the material context; `WipRejection.MaterialAlpha` is already polymorphic — OI-20) · `phase-04`, `phase-07` · `FlatWireOpenQuestions.md` Q72 · master spec + `06-TestPlanAndTestCases.md`.

### 3.5 Item 6 — tolerances are min/max, and there are four of them

**Rule to write:** upper and lower limits for **gauge (height)**, **width**, **diameter** and **ovality**, held in the lookup, applied at **both** pre-check-in and check-in.

Two structural consequences, both larger than the Q71 gap as written:

1. `AlloyProperty` currently holds `GaugeToleranceDefault` / `WidthToleranceDefault` as **single ± values**. Min/max means either a second column per dimension or an explicit `MinIn`/`MaxIn` pair — a **rename plus widen**, not an add. Do it as one change with the diameter and ovality columns rather than adding `RodDiameterToleranceDefault` alone as OI-07 proposed.
2. Ovality already exists as a *computed* check on `RodCheckin.SpcOvalityIn` with a hard-coded `≤ 0.003"` in `CheckinImplementationPlan.md`. That constant must move into the lookup too, or the system will validate ovality two ways.

**Do not seed values.** Tim's "I want to say it's plus or minus 10" is not a specification. Add the columns nullable, keep the mockup's mock map visibly marked as mock, and hold the seed script until the e-mail arrives.

**Files:** `FlatWireSchema_Lookup.md` (the Q71 gap note becomes a spec) · `FlatWire_DDL_01_Lookup.sql` + `FlatWire_SampleData_Lookup.sql` · `CheckinImplementationPlan.md` / `CheckinImplementationPrompt.md` (the 0.003" constant) · `APIContracts.md` 422 rule for `CHK007` · `FlatWireShopfloorDashboards.md` alloy lookup table · `dashboard_2a_rod_precheckin.html`, `dashboard_2_rod_checkin - New.html`, `dashboard_6_spc_checkpoint.html` · master spec **FR-065**, **OI-07**, the §"missing column" note · `02-SRS.md`, `03-HLD`, `06-TestPlan` · `phase-04`, `phase-13` (admin/reference data screens now have four tolerance pairs to edit).

### 3.6 Item 7 — a rod can carry two orders (the awkward one)

Every staging and check-in validation currently assumes **one order per rod** and treats a rod from a different order as a **hard refusal** (`RodPreCheckin.md` order-lookup table row 3; Q69; Q74's mid-order case). "Order 2 starts on the tail of the 7,000 lb A-rod" makes that refusal wrong: the rod legitimately belongs to an *ordered set*.

Minimum change if this lands in MVP1: `planning_routings` lookup returns **orders (plural)**; "belongs to the established order" becomes "belongs to the established order **or** its planned successor on this rod"; and `RodStaging.OrderId` needs a defined meaning when a rod spans two (recommend: the order the staging is being consumed for, with the successor visible in the queue).

**Recommendation:** confirm the MVP2 deferral with Srikanth **before** writing any of it, and in the meantime record it as a **known-wrong validation** rather than editing the rule — Phase 4 is the owning phase and the sequencing answer is still outstanding. Log as **Q79** and as a new gap in `back-matter.md`.

**Files if deferred (small):** `FlatWireOpenQuestions.md` (Q69 decided in part, Q79 added) · `RodPreCheckin.md` (the *Consequence to confirm* note gets its answer: order boundaries **can** be crossed on one rod) · `back-matter.md` new gap · `05-SprintPlanAndBacklog.md` MVP2 line.

### 3.7 Item 10 — short close is an unplanned stop against a weight range

**Rules to write:**

1. Closing below target = **unplanned stop**, mirroring the mill **10-90 SOP**, with an unplanned-stop reason code. (The term "10-90" appears **nowhere** in this repo — the SOP itself needs to be obtained and cited, not paraphrased.)
2. Grading is **by weight against the customer min/max** (e.g. 900 max / 800 min), **not** by footage and **not** against a fixed 2,000 lb default.
3. Inside range → continue. Outside range → **supervisor override + production hold**, or **offer to the customer under concession first**, remake only if declined (Shannon: offer first).
4. **The spool is run off regardless** — FL2 has no spool stripper, the spool must return to FL1. This is a hard operational constraint on the "reject and remake" path.
5. Spools are sized ~1,800 lb so **two ~900 lb finished coils** can be cut at FL2.
6. **Coil break mid-run:** the stop is removed and a new stop starts **from zero** — weight does not resume from the break point. Leftover incoming material is welded to the next coil on FL1; on FL2 it is run to a finished stop and offered, or scrapped.

Rule 6 is a **run/stop model change**, not a screen rule — check it against `FlatWireRun`/`CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage (OI-25) before writing it as settled.

Rule 2 partly answers **Q60**: the target source is the order's customer weight range. The assumed **2,000 lb default** now has no basis and must be pulled from the mockup and from Q60's text.

**Files:** `SpoolCompletionNotification.md` (Parts A and B, the 75/90/100 ladder, S-16…S-21) · `Spool.md` · `FlatWireOpenQuestions.md` Q60/Q65/Q66 · `dashboard_7_coil_completion.html` + `spool_notification.js` (2,000 lb default, the target basis) · `dashboard_3_active_run*.html` if the target shows there · `phase-08`, `phase-09` · `02-SRS.md` spool completion requirements · `06-TestPlanAndTestCases.md` · master spec.

### 3.8 Item 11 — resolution is unresolved, and it is pinned in 30+ places

1280×1024 is baked into all 25–28 mockups, `flat-wire-fit.js` (design box + the 14px `MIN_FONT` calibration), `phase-01`/`phase-01a` ("fixed 1280×1024 shopfloor canvas"), `RodPreCheckinUxReviewPrompt.md`, `ProjectPlanPrompt.md` and the master spec constraints section.

**Do not re-author anything yet.** Two actions only: (a) send Tim the 1920×1080 requirement by e-mail as agreed; (b) log **Q80** with the impact stated plainly — 1920×1080 is a **1.5× width, 1.05× height** change, so it is a re-layout of every screen, not a rescale, and `flat-wire-fit.js` already degrades gracefully downward but not upward. Note that `data-fit="fill"` means the screens already widen to the window, so a wider panel is the *cheap* direction; the height barely moves.

---

## 4. Execution waves

Ordered so that no wave leaves a document asserting a rule a later wave reverses.

| Wave | Content | Files | Size |
|---|---|---|---|
| **W1 — Registers** | `FlatWireOpenQuestions.md`: eight status changes, three new questions (Q78–Q80), Quick Reference + filtered index counts, change-log rows. Master spec §11 `OI-##` register: OI-01 closes, OI-07 respecified, OI-44 revisited. `back-matter.md`: G21 annotated, new gap for the multi-order validation | 3 | M |
| **W2 — Analysis notes** | `RodPreCheckin.md` (five sections — items 4, 5, 8, 9 + the Q69 consequence), `RodCheckout.md`, `WeldEvent.md`, `SpoolCompletionNotification.md`, `Spool.md`, `FlatWireShopfloorDashboards.md`, `FlatWireProcessWalkthrough.md` | 7 | **L** |
| **W3 — Schema + DDL** | `FlatWireSchema_Lookup.md` / `_Runs.md` / `_QualityOutput.md`; `FlatWire_DDL_01_Lookup.sql`, `04_Runs.sql`, `05_QualityOutput.sql`, `06_ForeignKeys.sql` (nothing expected), `07_Indexes.sql` (only if the blocked-row filter changes), `FlatWire_SampleData_Lookup.sql`, `FlatWire_ERDiagram_Documentation.md`. **Re-run `FlatWire_DDL_RunAll.sql` + the 10 constraint tests; table count stays 27** | 9 | **L** |
| **W4 — Contracts** | `APIContracts.md` and `LatestDocument/ProjectPlan/04-APIContract.md` — staging POST/DELETE, `GET /rod/{alpha}`, the `CHK007` 422 rule, un-stage approval body, spool completion | 2 | M |
| **W5 — Mockups** | `dashboard_2a_rod_precheckin.html` (four of the eight changes land here), `dashboard_2_rod_checkin - New.html`, `dashboard_2_rod_checkin_fl3.html`, ~~`dashboard_8_wip_rejection.html`~~ **`wip_rejection.js`** *(the screen became a dialog on 1 Aug 2026; the staging-context rejection this row calls for is now delivered there — the `.html` is only a launcher)*, `dashboard_7_coil_completion.html`, `spool_notification.js` | 6 | **L** |
| **W6 — July 30 project-plan set** | `02-SRS.md` (requirement text — **do not renumber**; supersede in place), `03-HLD-and-ERDiagram.md`, `05-SprintPlanAndBacklog.md` (MVP2 line), `06-TestPlanAndTestCases.md`, `00-README.md` §5–6, `FlatWire_MasterSpecification.md` | 6 | **L** |
| **W7 — Phase files** | `phase-01c`, `phase-04` (heaviest), `phase-07`, `phase-08`, `phase-09`, `phase-13`; `phase-01a` only if item 11 resolves | 6 | M |
| ~~**W8 — SRS `.docx`**~~ | **CANCELLED (project decision, 1 Aug 2026).** The consolidated SRS is **not** to be updated, and `SRS/Shopfloor_Flat_wireSRS_Consolidated_v3.docx` has been **removed from the repository** (`git rm`; still recoverable from history at `6096921`). The docx→markdown round-trip does **not** need re-establishing. See the note below on where the requirement text now lives | — | — |

**Parallelisable:** W3/W4/W5 after W2. ~~W8 is independent and should start early because re-establishing the pipeline is the long pole.~~ **W8 is cancelled.**

> **Consequence of cancelling W8 — the requirement text is now split, and the `.docx` is not the place to look.** `SRS/Shopfloor_Flat_wireSRS.docx` (the older, pre-consolidation file) is the only SRS left in the repository, and it contains **zero pre-check-in content** — that was the whole reason `RodPreCheckin.md` had to be written. The numbered requirement IDs the whole repo cites (`PCI001`–`PCI008`, `CHK006`/`CHK007`/`CHK009`/`CHK010`, `PRC001`–`PRC019`, `WLD003`/`WLD005`/`WLD006`/`WLD010`/`WLD011`, `TRV002`/`TRV004`/`TRV009`) came from the removed consolidated v3.
>
> **What this means in practice.** Those IDs stay valid as *references* — every rule they carry has been restated in [`../LatestDocument/ProjectPlan/02-SRS.md`](../LatestDocument/ProjectPlan/02-SRS.md) as `FR-###`, which is the authority for what to build. But three items the 30 Jul call changed have **no source-document home** any more and live only in the `FR` set and the analysis notes:
>
> 1. **Pre-check-out has no requirement ID at all** — §4.17 covered only post-check-in removal. This was already true before the removal (it is why **OI-44** exists); it is now unfixable in the source document. `FR-052`/`FR-052a` are the definition.
> 2. The **SRS §4.2 `PCI` data note is superseded** by the `INFLAT`-at-check-in decision (**Q67**) and cannot be corrected in place. `FR-048` and [`FlatWireProcessWalkthrough.md`](FlatWireProcessWalkthrough.md) step 8 carry the correct rule.
> 3. **`CHK007`** now means a **min/max band**, not `nominal ± tolerance`. `FR-042`/`FR-065` carry the corrected wording.
>
> Anyone re-issuing an SRS to the client must pull from `02-SRS.md`, not from the surviving `.docx`.

**Convention reminders that apply to every wave:** update the **Last Updated** header and append a **Change Log** row on each doc touched; strike through resolved register items with a `DECIDED (date)` note and **never delete them**; keep `OQ-##` numbering contiguous; phase files must not restate foundations text.

---

## 5. Cross-checks to run after W3 and W5

1. `sqlcmd -i FlatWire_DDL_RunAll.sql` against a clean `FlatWireDB` — idempotent, **27 tables**, all constraint tests green.
2. Grep for the superseded strings and confirm each surviving hit is an annotated history entry, not a live rule: `off-schedule`, `OffScheduleOverride`, `INFLAT` near "pre-check-in", `2,000 lb` near "target", `RodDiameterToleranceDefault`, `No Unstage on a welded rod`.
3. Open Dashboard 2A and Dashboard 2 in a browser and walk cold start → stage → fail inspection → reject → stage welded → un-stage with override.
4. Confirm `REVIEW.md`'s tier list has not gained a new contradiction — in particular that `APIContracts.md` and `04-APIContract.md` now say the same thing about staging.

---

## 6. Send back to the client (open, blocking, or owed)

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | **Tolerance values** — width, height, diameter, ovality min/max, by e-mail as agreed | Tim O. | Seed script, `CHK007`, Phase 4 |
| 2 | **1920×1080 requirement** — we send it; Tim verifies stock with Charles/Juan | Us → Tim O. | Q80, phase-01a canvas |
| 3 | **Q78** — rod/order not scheduled on FL1 or FL3 at all: allowed with supervisor override, or refused? Both pre-check-in and check-in? | Tim O. | Whether the override columns survive |
| 4 | **Q79** — multi-order rod sequencing rule, and MVP1/MVP2 scope | Srikanth (notes) / Shray's one-order-at-a-time proposal | Phase 4 staging validation |
| 5 | **Q67 residual** — does pre-check-in still do the `FlatwireQueue` / reqsum / `wip_coil_orders` insert, now that `INFLAT` moves to check-in? | Tim O. / IT | OI-01 full closure, G2/G16 scope |
| 6 | **Q74 re-confirm** — out-of-sequence override, as Tim asked, at the next review | Tim O. | Nothing — provisionally in place |
| 7 | **The 10-90 SOP document itself** | Operations | Item 10 rule text |
| 8 | **Customer weight range source** — which field on the order carries min/max spool weight | Tim O. / Bob S. | Q60 close, spool completion screen |
| 9 | **PIN validation source** (inherited from Q66/Q74) — existing login service or a separate supervisor store | IT | Every override in the module |
| 10 | **Q81 — bundle gross weight**: 8,690–8,840 lb or ~2,000 lb? Contradictory across the delivered contracts, and it calibrates the weld alerts (3,000 / 2,000 lb) | Tim O. / Bob S. | Payoff weight bar, weld alerts |

---

## Related Documents

| Document | Why |
|---|---|
| [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md) | Primary target — five of the eleven answers change it |
| [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) | Authoritative register; W1 |
| `Dashboard2A_UXReview.md` *(deleted 1 Aug 2026 — git history at `2a0426b`)* | Source of the Jul 31 findings that items 5 and 8 supersede |
| [SpoolCompletionNotification.md](../LatestDocument/RequirementDocuments/SpoolCompletionNotification.md) | Target for item 10 |
| [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) | `OI-##` register and the reconciliation authority |
| [00-README.md](../LatestDocument/ProjectPlan/00-README.md) | Precedence chain the waves respect |
| [REVIEW.md](../DevelopmentPlan/REVIEW.md) | Contradiction audit to re-check after W4 |

---

## Change Log

| Date | Change |
|---|---|
| August 1, 2026 | Initial document. Mapped the eleven answers from the 30 Jul 2026 client call onto the `OQ`/`OI`/`G` registers, identified the three reversals of already-delivered decisions and the two decided-but-value-pending items, and sequenced the propagation into eight waves across 41 files plus the SRS `.docx`. Ten items sent back to the client as open, blocking or owed. |
| August 1, 2026 | **W8 cancelled and the consolidated SRS removed from the repository** (project decision). `SRS/Shopfloor_Flat_wireSRS_Consolidated_v3.docx` was `git rm`'d; it remains recoverable from history at commit `6096921`. The docx→markdown pipeline no longer needs rebuilding. Recorded the consequence: the surviving `SRS/Shopfloor_Flat_wireSRS.docx` contains **no pre-check-in content**, so `02-SRS.md`'s `FR-###` set is now the only home for the pre-check-out, `INFLAT`-at-check-in and min/max-`CHK007` rules — and pre-check-out's missing requirement ID (OI-44) is now permanent in the source document. |
