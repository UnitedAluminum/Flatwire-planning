# Flat Wire Mill — Decided Questions and Answers

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 23, 2026 — **`Q60` and `Q61`: `Spool`/`SpoolCarrier` swapped, then `SpoolConfiguration` merged into `Spool`.** The material table is `SpoolProcessing`; the article is `Spool` and now carries its own size limits. **The object baseline moves to 33 tables · 55 FKs** (`[DBD §6.2]`). ⚠ **A stale `Spool` reference is *silently wrong*, not obviously stale.** *(previously August 23, 2026 — **`Q60` added: `Spool` and `SpoolCarrier` are swapped.** The material table is now `SpoolProcessing` and `Spool` is the reusable stencilled article in `01_Lookup`; the naming convention that was missing is written down as `[DBD §6.2a]`. ⚠ **A swap makes a stale reference silently wrong rather than obviously stale** — read that entry before trusting any pre-23-Aug `Spool` citation. The Decision Index was also brought level with its own total, having been three rows behind since 22 Aug. *(previously August 22, 2026 — **`Q57` and `Q58` added: two questions raised and decided the same day**, from [`RodOrderAllocation.md`](../LatestDocument/RodOrderAllocation.md). Both are **alpha-identity** decisions and both were settled against the schema rather than by preference: `Q57` puts FL1 segment alphas and FL2 coil identities in **one namespace** because the generator cannot see `FlatWireDB` and a local counter would issue the same string twice; `Q58` **keeps `CoilAlpha`** and renames only `SharedCoilNo`, because making the shared identity the sole one would have coupled coil creation to a cross-database call. *(previously August 18, 2026 — `Q68` carries a supersession note — `D-32` (there is no shared-schema migration) keeps the 30 Jul timing answer and moves the status to the local rod record)*)*)*

**Scope:** MVP-1
**Status:** Closed decisions — reference record
**Total Decisions:** 30 (**25 client-facing**, indexed below; 5 internal-design, body only) · **Decision window:** Apr 28 → Aug 23, 2026

---

## What this file is

**Every question that has been answered, with its answer.** It is the closed half of the question register, split out on 11 Aug 2026 so that [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) carries **open items only**. A question arrives here when its recommendation in that register is confirmed.

**The two files share one numbering space, renumbered contiguously on 12 Aug 2026.** Open questions are **`Q1`–`Q33`** in [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md); the decided questions here are **`Q61`–`Q85`**. A `Q##` appears in exactly one of the two files, so an inbound `OQ-##` reference from the phase files, [REVIEW.md](../MVP-1/ProjectPlan/Development/REVIEW.md) or the master specification resolves against whichever file holds it. **Each half is contiguous — `Q1`–`Q33` open, `Q61`–`Q85` decided.** Three open questions were removed on 12 Aug 2026 and the survivors closed up behind them. Questions removed as out of scope did not leave their numbers behind; their substance is carried in the master specification's `OI-##` register, and every citation that pointed at them was retargeted. The full old→new map is in [CHANGELOG.md](../CHANGELOG.md), under `Analysis/FlatWireOpenQuestions.md`.

**A decision here is the answer, not a proposal.** Pre-decision deliberation — the options weighed, the interim designs that were replaced — is not carried over; the register's change-log entries in [CHANGELOG.md](../CHANGELOG.md) hold that history. Where a decision left something genuinely unresolved, the residual is stated and points at the open register.

**Ten partly-answered questions are *not* here.** `Q1`, `OI-65`, `Q12`, `Q13`, `Q17`, `Q18`, `OI-56`, `Q22`, `Q23` and `Q24` carry decided sub-parts — a basis, a shape, or some of their numbered items — but are not closed, so they stay in the open register with their decided portions intact. Look for a partial answer there before concluding one does not exist.

**Two decisions are only partly in MVP-1** — `Q62` and `Q83`. Each carries a banner on its body naming the half that applies. Read the half, not the whole.

---

## Origin — the client questions e-mail of 27 April 2026

This file absorbs `ClientQuestionsEmail.md`, which was the outbound request for these decisions and is no longer maintained separately. Its provenance, and the wording in which each question was actually put to the client, are recorded here.

| Field | Value |
|---|---|
| **Sent** | April 27, 2026 |
| **From** | Jaspreet / Development Team |
| **To** | Tim O'Brien, Shannon R., Bob S., Jeff G., Dan F., Mick, Stephen, Margo, Darlene, Naj, Chuck, Sales (Laura G. / Ron F.) |
| **Subject** | Flat Wire Mill — Open Questions Requiring Your Input (57 Items) |
| **Content at send** | 57 questions — 11 Critical · 29 High · 14 Medium · 4 Low |

The priority deadlines the e-mail set are **superseded** — it worked to a July 1 trial and August 1 production target, against the current window of **17 Aug → 30 Sep 2026** with a Phase-1 gate of **14 Aug 2026**. The priority *labels* still carry their original meaning of relative urgency.

**Fifteen of the decisions below were answered against that e-mail** and carry an *As put to the client* note in the wording it used: `Q61`, `Q62`, `Q63`, `Q77`, `Q80`, `Q81`, `Q82`, `Q83`, `Q66`, `Q67`, `Q74`, `Q75`, `Q64`, `Q78`, `Q65` — and `Q76`, which the e-mail also carried and which was answered on 11 Aug 2026. The other nine were raised and decided after it, between 30 Jul and 6 Aug 2026, and have no e-mail wording.

---

## Decision Index

| # | Subject | Scope | Priority | Owner | Decided |
|---|---------|-------|----------|-------|---------|
| 61 | Mid-run pass schedule change — alpha handling | `Shopfloor` | Critical | Jaspreet / Tim O. | May 4, 2026 |
| 62 | Pass schedule override authority and logging **⚠ in scope from Step 2 onward** | `Shopfloor` | High | Tim O. / Shannon R. | May 4, 2026 |
| 63 | Component failure mid-run protocol | `Shopfloor` | High | Tim O. / Plant | May 4, 2026 |
| 64 | Pass schedule ID on coil completion and cert record | `Shopfloor` | High | Tim O. / Mick | May 4, 2026 |
| 65 | "Require SPC on resume" override authority | `Shopfloor` | Medium | Tim O. / Shannon R. | May 4, 2026 |
| 66 | Line speed range per alloy and gauge | `Other` | High | Tim O. / Bob S. | May 4, 2026 |
| 67 | FL1 and FL2 simultaneous independent operation | `Other` | Critical | Tim O. / Stephen | May 4, 2026 |
| 68 | Pre-check-in coil status — `INFLAT` or `STAGED` | `Shopfloor` | Critical | Tim O. / IT | Jul 30, 2026 |
| 69 | Does pre-check-out require supervisor approval? | `Shopfloor` | High | Tim O. / Shannon R. | Jul 30, 2026 |
| 70 | Can a rod carry more than one production order? | `Shopfloor` | Medium | Tim O. / Planning | Jul 30, 2026 |
| 71 | Can rod bundles be stacked on one VPS position? | `Shopfloor` | Medium | Tim O. / Bob S. | Jul 30, 2026 |
| 72 | May a welded staged rod be released, and by whom? | `Shopfloor` | Medium | Tim O. / Shannon R. | Jul 30, 2026 |
| 73 | Multi-order rod — the consumption sequencing rule | `Shopfloor` | Medium | Srikanth / Tim O. | Aug 6, 2026 |
| 74 | Mid-run rod checkout authorisation level | `Shopfloor` | High | Tim O. / Shannon R. | May 4, 2026 |
| 75 | Partial-run material disposition authority | `Shopfloor` | High | Tim O. / Shannon R. | May 4, 2026 |
| 76 | FL2 spool check-in identifier — the spool alpha | `Shopfloor` | Critical | Jaspreet / Tim O. | Aug 11, 2026 |
| 77 | Maximum finished coil weight | `Shopfloor` | High | Tim O. / Bob S. | Apr 28, 2026 |
| 78 | Spool alpha continuity through anneal or re-pass | `Shopfloor` | High | Tim O. / Jaspreet | May 4, 2026 |
| 79 | Short-close path — closing a spool below target weight | `Shopfloor` | Medium | Tim O. / Operations | Jul 30, 2026 |
| 80 | Oscillation layer interleave material | `Other` | Medium | Tim O. / Sales | May 4, 2026 |
| 81 | Camber and flatness limits | `Shopfloor` | Medium | Tim O. / Technical | May 4, 2026 |
| 82 | Edge burr height limit and measurement | `Shopfloor` | Medium | Tim O. / Technical | May 4, 2026 |
| 83 | Die life tracking **⚠ bands in scope; per-tool mechanism is not** | `Shopfloor` | Medium | Tim O. / Maintenance | May 4, 2026 |
| 84 | `ITInhibit` is line-scoped | `Shopfloor` | High | Tim O. / Engineering | Aug 4, 2026 |
| 85 | FM2 has three stands, `S1` = 8″ | `Shopfloor` | Critical | Tim O. | Aug 4, 2026 |

**22 are `Shopfloor` scope; 3 are `Other`** (`Q80`, `Q66`, `Q67` — adjacent modules, retained because they were answered in the same client sessions).

> ⚠ **This index is deliberately NOT the full list, and the arithmetic looks wrong until you know why.**
> It carries the **client-facing** decisions only — 25 rows against a stated total of 30 — because
> [`Tools/build_questions_xlsx.py`](../MVP-1/ProjectPlan/Tools/build_questions_xlsx.py) parses *this table*
> to build the client questions workbook, and every row it finds must have client-facing prose in
> `ClientQuestionsContent.md`. **Internal-design decisions cannot go in it**: `Q57`, `Q58`, `Q60` and
> `Q86` are decisions about table and column *names*, so there is no way to state them in a client
> cell without breaking that generator's leakage guard (no table name, path, or requirement id may
> reach a client cell). `Q56` is a shared-schema verification, equally not a client question. **They
> live in the body below and are absent here on purpose — do not "fix" the count by adding them.**
> *(Added and reverted on 23 Aug 2026, which is how this note came to be written.)*

---

# Section 1 — Pass Schedule and Run Control

---

**Q61** · `Critical` · Owner: Jaspreet / Tim O. · `Decided May 4, 2026`
**Mid-run pass schedule change — alpha handling**

**Asked:** If a pass schedule changes mid-coil (e.g., due to a die swap or edge change), does the system create a new child alpha for the post-change material, or amend the existing alpha?

*As put to the client:* "If a pass schedule changes mid-coil (for example, a die is swapped or the edge configuration changes during a run), does the system create a new child alpha for all material produced after the change, or does it amend the existing alpha?"

**Decision (May 4, 2026):** Not all mid-run changes are equal. Five cases are defined:

**Case 1 — Same-spec tooling swap (planned life, gauge drift, die failure)**
The target product specification does not change. A DB2 die at 0.310" is replaced with another 0.310" die because the old one wore out. The material before and after the swap is the same product.
- **Decision:** Single alpha + die change event at footage position. Tim confirmed this approach.

**Case 2 — Size change or product configuration change**
The pass schedule is updated to change the product itself — a different die size (e.g., 0.310" → 0.296"), edge type switches from Round to Flat, or a roll gap adjusted to target a different width. Material after the change is a different product from material before it.
- **Decision:** New child alpha at the footage breakpoint (e.g., FW-00421-C01-A). Pre-change alpha closes with defined start/end footage and pass schedule. Tim confirmed this approach.

**Case 3 — Edge type change**
Different product definition: cert and customer requirements differ.
- **Decision:** New child alpha. Tim confirmed this approach.

**Case 4 — Roll gap adjustment within tolerance (automatic gauge control)**
Process tuning within spec, not a product change. Note: Both FL1 and FL2 mills have automatic gauge control (AGC). Roll gaps can deviate to maintain gauge/width within tolerance via output of gauge/width trace devices.
- **Decision:** Single alpha, no change. Tim confirmed — there should be no change to alpha for AGC-driven adjustments.

**Case 5 — Roll gap change to a new target width/gauge**
Product spec changes — a deliberate operator-driven reset to a new target, not AGC correction.
- **Decision:** New child alpha. Tim confirmed this approach.

---

**Q62** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026` · **⚠ in scope from Step 2 onward**
**Pass schedule override authority and logging**

> **Only part of this decision is MVP-1 — do not read it as wholly in or wholly out.** `FW-014` is split: the `PassScheduleChangeLog` table and the schedule-editing flow (**Step 1**) are **outside MVP-1**; the **Active Run Monitor alert, its acknowledgement, and the rule that the line continues on the previous PLC values until acknowledged** (**Step 2** onward) are **MVP-1**. Step 1 is retained below because Steps 2–4 are the response to it and cannot be read without it.

**Asked:** Who on the floor is authorized to override a pass schedule setting during a run, and how is the override logged?

*As put to the client:* "Who on the floor is authorized to override a pass schedule setting during a run?"

**Decision (May 4, 2026):** The four-step mid-run configuration change flow is confirmed:

**Step 1 — Operations log the override**
- Floor operators have read-only access to the pass schedule at check-in. They cannot edit it unless it is a one-for-one change (e.g., replace DB1 die 0.285" with new die 0.285" — same size). Any other change requires an Operations Manager.
- The Operations Manager opens Pass Schedule Management Dashboard, edits the pass schedule. The system records: what parameter changed, old value → new value, who made the change (user ID), timestamp, and a reason code or free-text reason.
- Pass Schedule Management Dashboard includes an Override Log showing the last 5 changes with date, user, parameter, and reason. Tim confirmed this approach.

**Step 2 — Active Run Monitor shows an alert requiring operator acknowledgment**
- When the override is saved, the system pushes a real-time notification to the Active Run Monitor Dashboard on the active line.
- The operator must explicitly either Acknowledge (understood; production continues under new config) or Stop Run (supervisor review required before proceeding). Passive dismissal is not permitted.
- The notification bridges the gap between the updated database record and the PLC tags still running the machine under the old configuration. Tim confirmed this approach.

**Step 3 — System records material before and after the change under respective configurations**
- The system records the footage counter value at the moment of the change.
- If within-spec tuning: configuration event recorded on the existing alpha at the footage position.
- If product specification changes: existing alpha closes at that footage, new child alpha opens at that footage with the new pass schedule. Tim confirmed this approach.

**Step 4 — Automatic SPC checkpoint triggered post-change**
- When pass schedule changes mid-run (especially die size or roll gap change), the system automatically triggers an SPC checkpoint to verify the machine has settled to the new targets.
- This works the same as the existing die change flow: when reason is gauge_drift or size_change, spcCheckpointRequired is set to true.
- Active Run Monitor shows "Configuration Change Logged — Awaiting SPC Checkpoint." Operator cannot close that status without completing SPC. Tim confirmed this approach.

---

**Q63** · `High` · Owner: Tim O. / Plant · `Decided May 4, 2026`
**Component failure mid-run protocol**

**Asked:** If a scheduled component fails mid-run, what is the defined protocol?

*As put to the client:* "If a scheduled component fails mid-run, what is the defined protocol?"

**Decision (May 4, 2026):** Build an unplanned component bypass event as a distinct transaction from a planned bypass. Tim acknowledged that while some components cannot be bypassed, with experience and ingenuity some may be workable around. The full framework is confirmed:

- **New event type** — When an operator bypasses a component that was planned active, they must explicitly record it as an unplanned bypass (not silently inherit the planned config). Captures: which component, time of bypass, footage position at failure, reason code, and operator ID.
- **Alpha split at the bypass point** — Create a child alpha at the split point. Pre-failure material runs under the original pass schedule; post-bypass material runs under the modified effective configuration.
- **Supervisor acknowledgment** — Bypass-and-continue requires supervisor-level confirmation, not operator-only.
- **Disposition decision for pre-bypass material** — If the failure event itself may have affected material quality before the component was bypassed, a disposition step (accept / inspect / reject) is required for the footage produced during the failure window (parallel to Q75 partial-run disposition flow).

---

**Q64** · `High` · Owner: Tim O. / Mick · `Decided May 4, 2026`
**Pass schedule ID on coil completion and cert record**

**Asked:** Should the output coil record capture the pass schedule ID and configuration data?

*As put to the client:* "Should the output coil record capture the pass schedule ID and configuration data?"

**Decision (May 4, 2026):**
- **Label:** Pass schedule data (ID, version, die sizes, roll gap values) should NOT appear on the coil label.
- **Technical traceability:** Pass schedule ID and relevant configuration data should be logged against the coil record for technical traceability. This data must be captured at coil creation time so it can be retrieved for quality audits and engineering review, even if the pass schedule is subsequently edited.

---

**Q65** · `Medium` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**"Require SPC on resume" override authority and die change flow**

**Asked:** What role is permitted to turn off the "Require SPC on resume" toggle?

*As put to the client:* "What role is permitted to turn off the 'Require SPC on resume' toggle?"

**Decision (May 4, 2026):**
- For Gauge drift and Size change die replacements, thread mode (slow running without full production) is allowed until SPC has been completed. This ensures the correct die has been installed and is seated properly before committing to production footage.
- After Confirm die change, the system should route to the SPC Checkpoint screen instead of directly back to the Active Run Dashboard.
- The run should remain in a blocked/paused state until SPC passes.
- The "Require SPC on resume" toggle should be pre-checked ON for Gauge drift and Size change reasons, and the system should enforce this routing.
- Override authority is restricted to an Operations Manager or Quality role minimum, with a mandatory reason code and audit log.

---

# Section 2 — Scheduling and Capacity

---

**Q66** · `High` · Owner: Tim O. / Bob S. · `Decided May 4, 2026` · `Scope: Other`
**Line speed range per alloy and gauge**

**Asked:** What is the minimum and maximum line speed (FPM) for each alloy and gauge combination on FL1 and FL2?

*As put to the client:* "What is the minimum and maximum line speed (FPM) for each alloy and gauge combination on FL1 and FL2?"

**Decision (May 4, 2026):** Line speed ranges are unknown at this time and will be determined by trial. Once determined through production runs, the data can be added to a configuration table by UA. No blocking issue for initial development — scheduling algorithm should be designed to accept these values as table-driven inputs.

---

**Q67** · `Critical` · Owner: Tim O. / Stephen · `Decided May 4, 2026` · `Scope: Other`
**FL1 and FL2 simultaneous independent operation**

**Asked:** Can FL1 and FL2 run completely different orders at the same time in non-hybrid (standalone) mode?

*As put to the client:* "Can FL1 and FL2 run completely different orders at the same time in non-hybrid (standalone) mode?"

**Decision (May 4, 2026):**
- FL1 and FL2 can run independent orders simultaneously in non-hybrid mode. They are designated and tracked as separate machines in scheduling — analogous to how an order might run on ZR24 then U30.
- Each has its own machine booking, separate alphas, and separate check-in events.
- FL1/FL2 throughput ratio is approximately 3:1 (FL1 significantly faster than FL2). This creates open capacity on FL1 more often than FL2 depending on order mix.
- FL3 (hybrid continuous mode) cannot run if there are scheduled orders on FL1 or FL2.

> **This decision also part-answers `Q2`** (FL3 scheduling representation), which remains open on how FL3 is represented as a booking unit.

---

# Section 3 — Rod Staging and Pre-Check-in

---

**Q68** · `Critical` · Owner: Tim O. / IT · `Decided July 30, 2026`
**Pre-check-in coil status — `INFLAT` or `STAGED`, and what reverses it**

**Asked:** Does pre-check-in commit the shared coil record to `INFLAT` (per SRS §4.2), or does the status stay `STAGED` until check-in (per the process walkthrough)? And what reverses it?

> ⚠ **Overtaken in part by decision `D-32` (August 18, 2026): there is no shared-schema migration, so `INFLAT` never enters the shared coil-status vocabulary at all.** The July 30 answer still governs the **timing** — the status changes at check-in, not at pre-check-in, and there is no intermediate status for a welded-but-not-checked-in rod — but the status is now recorded on the flat wire module's **own** rod record and the shared coil record is not written. The decision text is retained unaltered below, as the audit trail of what was asked and answered.
>
> **Decision (July 30, 2026): `INFLAT` is set only when the rod is actually checked in at FL1.** Pre-check-in does **not** commit the shared coil status, and there is **no intermediate status** for a rod that has been welded but not yet checked in (Tim: not needed). The SRS §4.2 `PCI` data note is wrong wherever it is quoted, and [FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) step 8 (`RECEIVED → STAGED`) is the winning source. Rod status `STAGED` is the real staging status for FL1, not a vestigial value. **Unblocks the Phase 4 staging build.**

**Residual — still open, and it is not small.** The decision covers the **status column** only, not the rest of the SRS data note: whether pre-check-in still performs the `FlatwireQueue` insert, the reqsum and the `wip_coil_orders` insert. If those writes stay at staging, the compensating-write burden (**G2/G16**) is unchanged and only the status moved; if they move to check-in, pre-check-out becomes a pure `FlatWireDB` delete and **OI-01** closes completely. With Tim O. / IT — see the follow-up list in [ClientCall_2026-07-30_SyncPlan.md](../BaseDocuments/ClientCall_2026-07-30_SyncPlan.md) §6.

Detail in [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md).

---

**Q69** · `High` · Owner: Tim O. / Shannon R. · `Decided July 30, 2026`
**Does pre-check-out (un-staging) require supervisor approval?**

**Asked:** The rod was never checked in — no pass schedule acknowledged, no PLC tags pushed, no footage produced. Is operator-only un-staging right, or is supervisor approval needed?

> **Decision (July 30, 2026): it depends on whether the rod has been welded.**
>
> | Rod state | Approval | What is recorded | Rod status |
> |---|---|---|---|
> | **Not welded** | **None** — operator-only | Pre-check-out reason | Returns to inventory |
> | **Welded** | **Supervisor override required** | Documented reason — this **is a rejection** | **HOLD** |
>
> The reasoning is physical, not procedural: removing a welded rod means **cutting or splitting the material**, so the un-stage is a rejection rather than a return. This also **answers Q72** — a welded rod *can* be released, by a supervisor: the Unstage control is present on welded rows behind a supervisor gate and routes to rejection.

**Schema consequence.** `RodCheckout` has **no supervisor columns at all** today — `Q74`'s mid-run approval is equally unpersisted. Mode P needs `ApprovedBy` / `ApprovedAt` / `OverrideReason` and a check constraint requiring them (plus `NewRodStatus = 'HOLD'`) when the un-staged rod was welded.

**Requirement gap.** Pre-check-out has **no SRS requirement ID at all** — §4.17 covers only post-check-in removal. A new `PCI`-series requirement block is needed.

---

**Q70** · `Medium` · Owner: Tim O. / Planning · `Decided July 30, 2026`
**Can a rod carry more than one production order?**

**Asked:** Can a rod be pre-checked-in against a future order, or only the current one? *(Reframed on answering — the question was the wrong shape.)*

> **Decision (July 30, 2026): a single rod may legitimately carry more than one production order.** Srikanth and Tim confirmed the case — finishing order 1 on a 7,000 lb A-rod and starting order 2 on the remainder, both orders being the same alloy. The intent is for this to be handled **in planning** (the upstream operation), in multiples of the ~900 lb outgoing coil.

**What this overturned.** The interim rule — staging validates that the rod *"belongs to the **current** production order"*, singular, with a rod from any other order a **hard refusal** — is wrong as written: the successor order is on the *same rod*, so a refusal would stop the line mid-bundle. [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md)'s order-lookup table needs *"order differs → Refused"* rewritten as membership in an **ordered set** rather than equality with one order.

**The sequencing question this opened is `Q73`, decided 6 Aug 2026** — see below.

---

**Q71** · `Medium` · Owner: Tim O. / Bob S. · `Decided July 30, 2026`
**Can multiple rod bundles be stacked on a single VPS payoff position?**

**Asked:** Every artifact assumes one bundle per bay, but nothing states whether that is the equipment's limit or a modelling assumption. Eye-to-sky is the geometry in which stacking is standard wire-industry practice.

> **Decision (July 30, 2026): no.** Tim confirmed rods **cannot be stacked** on a single payoff. **Only two rods total may be checked in at a time — one per payoff** — the same rule as the mills. The one-bundle-per-bay assumption every artifact already makes is correct, and `UX_RodStaging_Bay` is right as keyed *(subject to **G21**, which is about its FL1/FL3 scope, not its shape)*.
>
> **Nothing is to be built for stacking:** no `StackPosition`, no `MaxStackDepth`, no re-based weight thresholds. **`CK_WeldEvent_PayoffDiff` stays as it is** — with a "no", a weld is always a bay handover and "a bay cannot be welded to itself" is the correct invariant.

**One item did not close with it.** The **received bundle gross weight** is stated two incompatible ways across the delivered contracts — **8,690–8,840 lb** in `/payoff/status`, `/staging/queue` and `/staging/rod` versus **2,000 lb** in `/rod/{alpha}` and `/checkin/rod` — and it calibrates the payoff weight bar and the weld alerts independently of stacking. Re-homed as **`OI-97`** (open) so it survived this question closing.

Related: **Q7** (max weld joints per coil), **Q10** (footage-to-weight factor), **G21**, **OI-97**.

---

**Q72** · `Medium` · Owner: Tim O. / Shannon R. · `Decided July 30, 2026`
**May a welded staged rod be released, and by whom? (`WLD011`)**

**Asked:** Mark-as-welded sets `RodStaging.IsWelded` on a `Staged` row — welded is a flag, not a status — so every control acting on a "staged" bay also matched a welded one. That rod is physically induction-welded to the rod in the mill, so "the bay is released and the rod returns to inventory" is not something that can happen.

> **Decision (July 30, 2026): yes — by a supervisor, and it is a rejection.** Answered as part of **Q69**. Releasing a welded rod requires a **supervisor override** with a **documented reason**, because removal means cutting or splitting the material; the rod goes to **`HOLD`**. Tim also confirmed **no separate status is needed** for a rod that is welded but not yet checked in.
>
> The control is therefore **present** on welded rows, gated on supervisor authorisation and routed to rejection rather than to "returns to inventory".

**Residual — the in-place reversal is still unspecified.** `WLD011` is *"supervisor reversal of a welded coil"*, which is broader than un-staging. Reversing a weld **in place**, on a rod that stays staged (mis-scan, wrong rod welded, weld failed after marking), has no specification and no audit target. `CK_RodStaging_Welded` ties `WeldedAt`/`WeldedBy` to `IsWelded`, so an in-place reversal is a three-column clear plus an audit trail that does not exist. `WLD011` needs a requirement before it gets a control.

Related: **Q74**, `WLD003`/`WLD010`.

---

**Q73** · `Medium` · Owner: Srikanth / Tim O. · `Decided Aug 6, 2026`
**Multi-order rod — the consumption sequencing rule**

**Asked:** `Q70` established that a rod may carry more than one order. In what sequence may those rods be consumed, and is the rule enforced?

> **Decision (August 6, 2026) — the consumption sequence is a three-tier rule, enforced as a validation.** Shray put the case to the client: three coils, one carrying two orders, an operator free to pick any of them; if he starts with the multi-order coil, order 2's tail has nowhere to run and the weld cannot be made. The rule as agreed:
>
> 1. **Full coils first.**
> 2. **Partials next** — a partial is a **back-to-stock**.
> 3. **Coils carrying multiple orders last**, always. Tim: *"There can be no other option for it because it has a second order."*
> 4. Full coils of the **same order** in the middle may be taken in **any order** — *"it won't make a difference."*
> 5. Operators work a **pick list in planned order**, the same pattern as the mills. An operator **may not jump a multi-order coil to the head of the line**. Srikanth: *"if the welding is required, that's a validation at the flatware interface to not do them out of sequence."*
> 6. Where **no welding** is involved the sequence is free — **but this branch is not settled, and the transcript supports two readings.** Srikanth scoped the rule to welding (*"if welding is not involved… they can go in any which sequence, right? Because it's harmless"*), and his confirming sentence carried the qualifier back in (*"the multiple orders… will be processed at the last **if welding is involved**"*). Yogender argued the opposite at 14:28 — that the multi-order case is different regardless, because in a continuation one order must complete before the second starts. **Reading A:** multi-order coils still last, welding or not. **Reading B:** no ordering constraint at all without a weld. They differ by one validation branch. **Ask it as one sentence:** *when no weld is involved, may an operator run a rod that carries two orders before the other rods of the first order?* Owner: Srikanth / Tim O.
> 7. **The validation applies at pre-check-in *and* at check-in.** Srikanth: *"in case they do not do a pre-check-in, it applies at the check-in. If they do the pre-check-in, you would do this."*
> 8. Applies to **stock orders** as well (Shray asked; confirmed).
>
> **Recorded because the rule was stated three ways before it settled.** Srikanth gave *full → partial → multi-order*. Tim then said **partials first** (11:03) and elaborated on it. Srikanth challenged it (12:04) and Tim corrected himself explicitly: *"Shray got this correct. The partials are at the end. It's full coils first, partials, and then coils with multiple orders"* (12:30). **Items 1–3 are the rule.** Reading only the first half of the transcript gives the opposite answer.
>
> **The worked example given.** An order of **44,000 lb** including upper tolerance, incoming rod at ~**5,500 lb**, FL1 output in multiples of ~**1,800 lb** and FL2 output in multiples of **800/900 lb** → planning lays out ~**9 A-rods: 8 full, 1 partial**. With welding, the eight full rods run first, then the partial, then any multi-order rod.
>
> **Scope:** it is **in MVP-1** — the validation was assigned to the flat wire interface on the call *("please make sure you capture these in the validations")*.

**The change this requires.** [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md) refuses any rod whose order differs from the established one, which **Q70** made wrong for the same-rod successor. The replacement: the `planning_routings` lookup returns **orders (plural)**, "belongs to the established order" becomes membership in an **ordered set**, and `RodStaging.OrderId` means *the order this staging is being consumed for*, with the successor visible in the queue — **plus** the three-tier ordering constraint above. This is what **`G22`** was waiting on.

**Two consequences worth stating outright.** Given the planned layout `R1 → O1`, `R2 → O1`, `R3 → O1`, `R4 → O1 / O2`:

1. Staging **R4 before R1–R3** is **refused**, not overridden — the multi-order rod is last by rule, which is stricter than the `Q24` out-of-sequence authorisation.
2. Whether a rod may be pre-checked-in against the **later** order on it while the earlier one is still running was not put to the client explicitly. The pick-list model implies it is staged against the order **currently being consumed**, with the successor visible — carried forward under **`OI-95`** if it bites, which asks the same thing.

**One residual, carried here because it has nowhere else to live.** Item 6's no-welding branch was tracked as its own open question until 12 Aug 2026, when that question was removed from the register. It has **no `OI-##` mirror**, so this entry is now the only record that the branch is unresolved — do not read item 6 as an unqualified "the sequence is free."

Full record in [ClientCall_2026-08-06_SyncPlan.md](../BaseDocuments/ClientCall_2026-08-06_SyncPlan.md) §3.1. Related: **Q12**, **Q17**, **Q70**, **Q24**, gap **G22**.

---

# Section 4 — Rod Checkout and Disposition

---

**Q74** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**Mid-run rod checkout authorisation level**

**Asked:** Is a mid-run rod checkout an operator-level action, or does it require supervisor approval?

*As put to the client:* "Is a mid-run rod checkout an operator-level action or does it require supervisor approval?"

**Decision (May 4, 2026):** A mid-run checkout (footage > 0, rod removed before exhaustion) requires supervisor approval. Operator-only checkout authority is not sufficient. This mirrors the WIP Rejection disposition flow.

> **Note (Aug 11, 2026) — this question was miscited for three months.** `Analysis/OperationsManager.md` recorded the mid-run approval requirement as pending under *"open question OQ-B"*, an identifier that exists in **no register**, and stated it as open although `Q74` had decided it on 4 May 2026. Corrected when that file was consolidated, and recorded here because the file was **deleted on 11 Aug 2026** (recoverable at `d79ce78`) and this is now the only home for the correction. If you meet an `OQ-B` reference anywhere else, it means `Q74`.

---

**Q75** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**Partial-run material disposition authority**

**Asked:** Does the operator have sole authority to accept partial footage as a spool alpha?

*As put to the client:* "Does the operator have sole authority to accept partial footage as a spool alpha?"

**Decision (May 4, 2026):** Supervisor must approve a mid-run checkout. The notification-driven remote approval model is confirmed:

1. Operator confirms mid-run checkout (footage > 0)
2. System creates Pending Disposition record
3. Material locked — no alpha created, not plannable
4. SignalR notification pushed to supervisor role
5. Supervisor reviews from any connected terminal:
   - Gauge trace for the partial run
   - Footage produced, reason for stop
   - Operator ID and timestamp
6. Disposition decision:
   - **Accept** → Alpha created, enters spool queue
   - **Hold** → Alpha created with Hold status; QC must release
   - **Reject** → WIP Rejection flow triggered; material goes to scrap
7. Disposition record written (supervisor ID, decision, reason code, timestamp)

---

# Section 5 — Spool Lifecycle and Output

---

**Q76** · `Critical` · Owner: Jaspreet / Tim O. · `Decided Aug 11, 2026`
**FL2 spool check-in identifier — it is the spool alpha**

**Asked:** When flat wire arrives at FL2 on a spool loaded onto the TPO, what identifier (alpha, spool number, bundle ID) is used for check-in? And how does that identifier link to the outgoing coreless coil record at TKUP-2?

*As put to the client:* "When flat wire arrives at FL2 loaded onto the TPO on a spool, what identifier does the operator use to check it in — the SP-series alpha, a separate spool number, or a bundle ID? How does that identifier link to the outgoing coreless coil record created at TKUP-2?"

**Decision (Aug 11, 2026): the identifier is the spool alpha — `SP-#####`.** Not the physical spool number and not a bundle ID. The physical spool number remains the plate on the equipment and may be displayed for confirmation, but it is not what the transaction is keyed on.

**The linkage half follows from it, and the schema already implements it.** Two columns carry the chain, both FKs to `SpoolProcessing.Alpha`:

| Column | Nullability | Role |
|---|---|---|
| `SpoolCheckin.SpoolAlpha` | NOT NULL | The spool being checked in at FL2 — the check-in transaction itself |
| `CoilTraceability.SpoolAlpha` | NULL | The source spool for a given output footage range — the coil → spool edge (added 6 Aug 2026) |

**Note where the coil→spool link is *not*.** It is deliberately on `CoilTraceability` (the detail) and **not** as a `CoilOutput.SpoolAlpha` header column, because a header column becomes wrong the moment a spool runs out mid-coil and a second spool finishes it — the relationship is per-footage-range, not per-coil. `IX_CoilTraceability_SpoolAlpha` is filtered on `SpoolAlpha IS NOT NULL` for the same reason: a rod-fed FL1 coil has no source spool.

**Operational consequence.** `Q17`'s 2 Aug decision gives FL2 a two-status queue the operator picks from, so the alpha is a **selection, not a typed entry** — which removes the mis-keying risk that would otherwise make an alpha worse than a short spool number at an HMI.

Related: **Q17** (the FL2 queue the selection is made from), **Q15** (validating a hybrid-origin spool at that same check-in), **Q5**/**Q6** (the cert traceability this chain serves).

---

**Q77** · `High` · Owner: Tim O. / Bob S. · `Decided Apr 28, 2026`
**Maximum finished coil weight**

**Asked:** Is the customer-facing maximum coil weight the same as the TKUP-2 equipment capacity, or set lower for ease of handling at the customer?

*As put to the client:* "TKUP-2 has a 1,000 lb capacity. Is the customer-facing maximum coil weight also 1,000 lb, or is it set lower (e.g., 500 lb for ease of handling at the customer)?"

**Decision (Apr 28, 2026, updated May 4, 2026):** New estimated maximum capacity is **1,100 lb** (TKUP-2 equipment limit — revised from 1,000 lb stated at the Apr 28 meeting). The customer defines their coil weight limit below UA's maximum capacity; this is captured in the orders/quotes application. Orders exceeding a single rod or spool weight will be split into multiple stops, each generating its own alpha. The last stop may contain multiple alphas. Weight distribution is tracked via footage and revolutions.

---

**Q78** · `High` · Owner: Tim O. / Jaspreet · `Decided May 4, 2026`
**Spool alpha continuity through anneal or re-pass operations**

**Asked:** Does an anneal step generate a new child alpha, or does the existing spool alpha carry forward?

*As put to the client:* "Does an anneal step generate a new child alpha or does the existing spool alpha carry forward?"

**Decision (May 4, 2026):**
- **Anneal step:** The alpha should be modified (updated) to maintain traceability — no new child alpha is generated for an intermediate anneal. The existing spool alpha carries forward with the anneal step recorded against it.
- **Re-pass through FL1:** UA does not have the capability to run a spool through FL1. This scenario is not applicable.

---

**Q79** · `Medium` · Owner: Tim O. / Operations · `Decided July 30, 2026`
**Short-close path — closing a spool below target weight**

**Asked:** The stop-confirmation popup is armed only at or above target weight, so a spool the operator wants to close early — order satisfied, rod exhausted, quality problem, end of campaign — gets no prompt. Is a short close a real operational case, and if so what happens?

**Decision (July 30, 2026):** a short close is a real case and is handled as an **unplanned stop**, mirroring the mill **10-90 SOP**, with an unplanned-stop reason code.

1. **Graded by weight against the customer min–max**, not by footage and not against a fixed target (see **Q18**). Example figures given: 900 lb max / 800 lb min.
2. **Inside the range → continue.** If the short weight still yields the finished coils the order requires, no escalation.
3. **Outside the range → flagged.** Either a **supervisor override plus a production hold**, or the piece is **offered to the customer under concession** before a remake is planned. Shannon's direction is explicit: **offer first**, remake last.
4. **The spool is run off in either case.** FL2 has **no spool stripper**, so the spool must be emptied and returned to FL1 regardless of the disposition of the material on it. This constrains the reject-and-remake path — "scrap it" is never "stop and remove it".
5. **Coil break mid-run:** the stop is **removed and a new stop starts from zero** — weight does **not** resume from the break point. The leftover incoming material is welded to the next coil on FL1; on FL2 it is either run to a finished stop and offered to the customer, or scrapped.

**Carry item.** Item 5 is a **run/stop model** change rather than a screen rule — check it against `FlatWireRun` / `CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage (**OI-25**) before it is written as settled. Overlaps the partial-spool handling in **Q12** and [PartialRodReCheckin.md](../MVP-1/ProjectPlan/Business/PartialRodReCheckin.md); the **10-90 SOP document itself is not in this repository** and must be obtained rather than paraphrased.

---

# Section 6 — Quality, Packaging and Tooling

---

**Q80** · `Medium` · Owner: Tim O. / Sales · `Decided May 4, 2026` · `Scope: Other`
**Oscillation layer interleave material**

**Asked:** Is a separator required between winding layers in the coreless oscillated coil?

*As put to the client:* "Is a separator required between winding layers in the coreless oscillated coil?"

**Decision (May 4, 2026):** No separator is required or available. UA does not currently have the capability to provide any separator between oscillate layers. No pack specification field for interleave material is needed.

---

**Q81** · `Medium` · Owner: Tim O. / Technical · `Decided May 4, 2026`
**Camber and flatness limits**

**Asked:** Is there a maximum camber specification for flat wire?

*As put to the client:* "Is there a maximum camber specification for flat wire?"

**Decision (May 4, 2026):** The camber measurement feature should be available in the SPC checkpoint if the customer has camber specifications. Implementation is conditional on customer requirement — the field is available but not mandatory for all orders. Inline measurement method to be confirmed per order spec.

---

**Q82** · `Medium` · Owner: Tim O. / Technical · `Decided May 4, 2026`
**Edge burr height limit and measurement method**

**Asked:** For Flat Edge products, what is the maximum allowable edge burr height?

*As put to the client:* "For Flat Edge products, what is the maximum allowable edge burr height?"

**Decision (May 4, 2026):** Not currently measured. No system implementation required at this time.

---

**Q83** · `Medium` · Owner: Tim O. / Maintenance · `Decided May 4, 2026` · **⚠ bands in scope; per-tool mechanism is not**
**Die life tracking — system or manual**

> **The decision below assumes per-tool tracking, which MVP-1 does not have.** Die inventory and lifecycle — including the die master table — left MVP-1 on 11 Aug 2026. MVP-1 reads die life at **die-size** granularity from `Drawer.LastGrindingFeet` / `Drawer.TotalFeetAllowed`, and **`D4` is restated at size level** — see [`DieChangeAndManagement.md` §2.4a](../MVP-1/ProjectPlan/Business/Screens/DieChangeAndManagement.md). **The 60/85 % bands are MVP-1 and are the half that applies.** Read what follows as the eventual target state, not as MVP-1 behaviour.

**Asked:** Should the system track footage run per die and generate a replacement alert?

*As put to the client:* "Should the system track footage run per die and generate a replacement alert?"

**Decision (May 4, 2026):** System-level die life tracking is required. Tim confirmed:
- Footage data must be logged against die number (die ID).
- Each die has its own unique identifier, similar to mill rolls, enabling tracking of when it is in use and total footage through it.
- Replacement threshold estimate is deferred — an accurate figure will not be available until failure data is collected from actual production.

Confirmed design approach:

| Design Point | Decision |
|---|---|
| Tracking unit | Cumulative footage per die serial/ID, incremented from PLC footage counter on each completed or partial run |
| Alert threshold | Configurable replacement threshold per die type; Maintenance sets the value per die profile |
| Alert mechanism | Passive banner on die check-in screen and Maintenance dashboard row when remaining life < 10%; no hard block — Maintenance can acknowledge and extend with a reason code |
| Mid-run die swap | System closes footage accumulation on outgoing die and starts new counter on incoming die |
| Manual reset | After physical die replacement, Maintenance (Supervisor) resets footage counter through a dedicated die-management screen; logs who reset it and when |
| Sensor requirement | Pull footage from existing PLC footage counter already used for spool/alpha tracking — no new IoT sensor needed |

---

# Section 7 — Equipment and PLC

---

**Q84** · `High` · Owner: Tim O. / Engineering · `Decided Aug 4, 2026`
**`ITInhibit` is line-scoped: `FL1.ITInhibit` and `FL2.ITInhibit`**

**Asked:** Every tag in every source was prefixed with its line — except this one, written bare as `ITInhibit` in all six pre-consolidation copies. Is the interlock plant-level or line-scoped?

**Decision (client, Aug 4, 2026).** The interlock is **one tag per line** — **`FL1.ITInhibit`** for FL1 and **`FL2.ITInhibit`** for FL2. A line blocked from running blocks **only itself**. The plant-level reading is excluded; under it, one line's unmet prerequisite — no rod checked in, no active MMS ID, missing feet data — would have blocked all three lines, and it would have been discovered the first time FL1 sat idle while FL2 was scheduled.

**Two consequences beyond the tag itself.** Rule **R2** in `PLCTagSpecification.md` §2.2 — *"the first segment is always the line; there is no plant-level tag"* — was `[PROPOSED]` **solely because of this counterexample**, and is now `[CONFIRMED]`, which strengthens every path derived from the grammar rather than observed (the whole economy of confirming a convention instead of ~60 strings, **PLC-Q02**). And the interlock is now **testable per line**: commissioning test **C7** sets each of the five conditions on one line and asserts the other two still run.

**One residual, on FL3 only.** FL3 spans both mills, so whether it carries `FL3.ITInhibit` or asserts FL1's and FL2's together follows from the FL3 namespace question, **Q29** / `PLC-Q08` — the same question that decides whether FL3's single-batch push crosses a controller boundary. This is the one line where a blocked line legitimately implicates a second, because on FL3 the two are one physical thread of material.

**Where the rule now lives.** It is **normative prose in `[PLC §8.1]`**: *"It is one tag per line — `FL1.ITInhibit`, `FL2.ITInhibit` — so a line blocked from running blocks only itself."* **This entry is the audit trail for the decision; the specification is the statement of the rule.**

Related: `FR-008`–`FR-010`, `FR-020`, **Q29**, **PLC-Q02**, commissioning test **C7**, `PLC-Q08`.

---

**Q85** · `Critical` · Owner: Tim O. · `Decided Aug 4, 2026`
**FM2 has three stands: `S1` = 8″, `S2` = 6″, `S3` = 6″**

**Asked:** How many stands does FM2 have, and what are their roller sizes? *(Raised by the client as a correction, not by us as a question.)*

**Decision (client, Aug 4, 2026).** FL2's finishing mill FM2 has **three stands**. **S1 carries the 8″ roller; S2 and S3 carry 6″ rollers.** Edgers remain at **S2 and S3 only**, and **S3 remains the final, non-bypassable gauge-control stand**. FL3 drives the same FM2. FL1's FM1 is unaffected at 12″.

**Why this was a repo-wide change and not a digit swap.** The May 21 2026 equipment correction was recorded in `Business/BusinessRules.md` §3 as *"FM2 has **three** 6″ stands (S1, S2, S3)"*. That was read as **a separate 8″ roller upstream of three 6″ stands — four components** — and the reading propagated into roughly fifty files, the `Stand` seed data, two SQL `CHECK` constraints, the `ComponentName` enum, the PLC tag grammar and eight mockups. The 8″ roller **is S1**, and the fourth stand does not exist.

Three pieces of evidence fix the mapping:

1. The client's **published PLC map has exactly three FM2 stations**. Three observed stations, three real stands.
2. **Every seeded pass schedule has exactly three FM2 component rows**, with a monotonically descending gap chain.
3. **`FM2_6inS3` never had a tag path or a seed row** — its absence was itself logged as `OI-36` and `G29`. It is the invented one.

**Consequences.** Component names become **position-only** (`FM2_S1` / `FM2_S2` / `FM2_S3`) and roll diameter becomes data in a new **`Stand.RollDiameterIn`** column — diameter inside the identifier is what let the misreading survive ten weeks. Mapping: `FM2_8in`→`FM2_S1`, `FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`, `FM2_6inS3` withdrawn. `Stand.Id` 1–4 keep their meaning; Id 5 is removed. **No gap or gauge value is recomputed** — the seeded three-row chains were always valid and `FR-387`'s multipliers move from diameter labels to positions, which incidentally fixes a defect where FM2's final stand had no gap formula.

**Two open items closed with it, and neither was ever a real defect.** **OI-04** — *"is the mandatory stand `FM2_6inS2` or `6″ S3`?"* — both named **the same physical stand**; only the phantom made one answer look like two. **OI-36** — *"the final stand has no tag path"* — the published map was complete; the stand with no path was the one that does not exist.

**One physics consequence.** Roll radius is a real input to the generation engine. The bite condition `Δh ≤ μ²R` is linear in `R`, so **S1 admits ~1.33× the draft** of a 6″ stand, while contact length `√(R′·Δh)` means it develops **~1.16× the separating force** at equal draft. `F_max` and mill modulus must therefore be supplied **per stand** (`PSG-D10`, `PSG-D12`), and `PassScheduleGenerationSpec.md` §3.3.5's allocation illustration is recomputed at `k` = 3 (**5.4% / 9.8% / 13.5%**).

**Successor question: `PLC-Q04` / `PLC-Q04`** (open) — the PLC station rename departs from the controller's observed station names and needs the controls engineer's sign-off.

Related: `D-26` (master spec §10.2), **OI-04**, **OI-36**, **PLC-Q04**, `PLC-Q04`, gap **G32**, commissioning test **C11**.

---

# Section 8 — Alpha Identity

---

**Q57** · `High` · Owner: Nagarro (internal design) · `Decided Aug 22, 2026`
**Do FL1 segment alphas and FL2 coil identities share one namespace?**

**Asked:** FL1 names each spool segment `R00001A`, `R00001B`, `R00001C` — the client's own grammar, adopted from their planner. FL2 mints a shared-schema coil identity through `CommonDB.dbo.GenerateCoilAlpha`, which produces `R00001A`, `R00001B`, `R00001C` off the same six-character root. **Two mechanisms, one string space.**

> **Decision (August 22, 2026): one namespace — both are minted through `CommonDB.dbo.GenerateCoilAlpha`.** FL1 calls the same function for its segment alphas, passing **every alpha already recorded for that rod** in the genealogy child table via `@CoilNoToIgnore`.
>
> **The reason is that the alternative cannot be made safe.** `GenerateCoilAlpha` sweeps twelve objects across four databases for uniqueness, and **`FlatWireDB` is not one of them** — so a local per-rod counter at FL1 would hand `R00001A` to a spool segment while the generator later handed the same string to a finished coil. Nothing in the database would stop it: the two live in different databases with no shared constraint. **The collision is semantic**, and it lands on the genealogy and the welding-wire certificate, which read through both levels of the chain.
>
> **What this decides that had been deliberately left open.** The genealogy child table's alpha column was created **absent on purpose**, its comment recording that *"until cardinality is decided the column would be a guess."* The cardinality is **one alpha per segment**, so the column is owed — and it is **opaque**: never parsed and never rebuilt, because `R00001A` + `A` and `R00001` + the 27th letter both render `R00001AA`. There is deliberately **no stored letter index**, since the generator may skip a suffix already taken by a coil and an index would drift from the letter it claims to explain.

**Two consequences worth stating.** FL1 spool completion becomes a **cross-database caller**, so it can no longer be tested on LocalDB, which has no `CommonDB`. And the ignore list must carry **every prior segment alpha for the rod**, not merely this transaction's — a second spool off the same rod would otherwise be handed the same alpha again.

**Rejected:** giving FL1 segments a distinct suffix space, which would abandon the client's confirmed grammar; and adding `FlatWireDB` to the generator's sweep, which reaches five wrappers, roughly fourteen stored procedures and three application surfaces — the blast radius `D-32` exists to prevent.

Related: **`Q56`** (whether a third path shares the namespace), **`D8`** (alphas are created on a transaction), **`D5`**.

---

**Q58** · `High` · Owner: Nagarro (internal design) · `Decided Aug 22, 2026`
**Should the output coil have one identity or two?**

**Asked:** `CoilOutput` carries two — a local customer-facing alpha `FW-#####-C##`, and the shared-schema identity written to `proddb..coils.coil_no`. An earlier draft proposed withdrawing the first, on the grounds that it is **not client-specified** (its requirement's source column reads *"Analysis"*, the shared-identity requirement is tagged `[PROPOSED]`, and every `FW-` string in the client's own documents is a story id) and that it carries **no information the shared identity lacks** — both being derived from the same rod.

> **Decision (August 22, 2026): keep both. `CoilAlpha` is retained; only `SharedCoilNo` is renamed — to `CoilNo`, matching the column it feeds.** `D5`'s rule — *"two coil alphas, deliberately, and they are not interchangeable"* — **stands.**
>
> **Both observations behind the withdrawal still hold. What they do not survive is the consequence.** The shared identity is **nullable by design**: the value does not exist until the cross-database mint succeeds, which is why its index is *filtered* and why it is the **retry contract** that stops a retry minting a second coil. Making it the sole identity — and the genealogy table's foreign-key target — would have required it to be `NOT NULL`, meaning **a coil record could not be created until `CommonDB.dbo.GenerateCoilAlpha` returned.** Given that function's unresolved `coils` reference, that converts a reconciliation problem into a **coil-completion outage**.
>
> Keeping `CoilAlpha` as a locally-minted `NOT NULL` identity removes the coupling outright: flat wire completes the coil on its own data and reconciles afterwards, as it does today. **No foreign key moves, and no surrogate leaks into the genealogy** — which is better than the fallback originally proposed for this question.

**One cost, recorded rather than absorbed.** `SharedCoilNo` was self-documenting about *which* identity it was; `CoilNo` beside `CoilAlpha` is not. The compensating argument is that `CoilNo` matches `coils.coil_no`. **The column's comment block is now the only thing that disambiguates the two** — keep it.

**Scope of the change:** a rename only. The customer-facing alpha's requirements, the alpha-format table and the API payloads are all **untouched**.

Related: **`Q57`**, **`D5`**, **`D8`**, `D-32`.

---

**Q56** · `High` · Owner: IT / Srikanth · `Decided Aug 22, 2026`
**Does the scrap-weight alpha path mint from the same root namespace?**

**Asked:** `Common.API` calls `CommonDB.dbo.Common_GenerateNewCoilAlphaForScrapWeight`, a scripted wrapper that `EXEC`s a `united_db` procedure which is **not scripted in `ual-database`** — so the repository could not say whether the scrap path draws alphas from the same six-character root namespace as `CommonDB.dbo.GenerateCoilAlpha`. It takes `@coil_no`, `@mfg_order_no` and `@seq_no`, so it was at least *shaped* like a coil-alpha minter.

> **Decision (August 22, 2026): yes — verified on the live instance.** The procedure exists in `united_db` and its definition **calls `GenerateCoilAlpha`**. So the scrap path draws from the same root namespace **through the same uniqueness sweep**, and therefore cannot collide with anything already recorded in the shared schema.
>
> **This is the reassuring half of the answer.** Had it minted independently it would have been a fourth, unguarded writer into the rod-root namespace. It is not: it inherits the same discipline every other caller does.

**The residual, and it is the part worth carrying forward.** Every caller passes **its own** ignore list. FL1 segment alphas live only in `FlatWireDB`, which the sweep does not cover, so the scrap path — like any other caller — can be issued an alpha that an FL1 spool segment already holds. **`Q57`'s one-namespace guarantee therefore bounds flat wire's own two paths and not third parties.** Tracked as **`Q59`**, with a recommendation to accept and monitor rather than add a shared-schema writer.

**A second thing this settled on the way.** The same live check resolved **`OI-125`**: `CommonDB..coils` is a real `USER_TABLE`, and **`proddb..coils` is a synonym pointing at it** — so the generator's unqualified `FROM coils` sweeps the very table flat wire writes finished coils into. The deployment concern is discharged; what remains is that the table is unscripted in `ual-database`.

Related: **`Q57`**, **`Q59`**, **`OI-125`**, **`OI-115`**, `D-32`.

---

**Q60** · `Medium` · Owner: Nagarro (internal design) · `Decided Aug 23, 2026`
**Is `Spool` the right name for the material table?**

**Asked:** `[Spool]` reads as a lookup table. Two reasons were offered and only one survives. The
**misreading**: `Spool` is not in `01_Lookup` at all — it sits in `03_Materials` beside `Rod`, which
is the same shape (a bare singular material noun), so it was internally consistent with `Rod` rather
than with `Edger`. The **real defect**: half of `01_Lookup` is bare equipment nouns (`Stand`,
`Drawer`, `Edger`, `Dancer`) and half carries a role suffix, so nothing in a name says which group a
table is in — and separately, **the word "spool" named three different things**: the material
(`Spool`), the reusable steel article (`SpoolCarrier`) and the size class (`SpoolConfiguration`). The
DDL flagged that conflation risk in its own comment, pointing at `SpoolQueue.md` open item 1.

> **Decision (August 23, 2026): swap the two names. `SpoolCarrier` → `Spool`; `Spool` →
> `SpoolProcessing`.** Physically a spool **is** the reusable article — equipment, in the same sense
> as a stand or an edger — so it belongs in `01_Lookup` beside them, and the material record takes the
> `…Processing` suffix. `SpoolCarrier.CarrierNo` → `Spool.SpoolNo`, matching the "**Spool number**"
> label `SpoolQueue.md` §4 already shows the operator, and `Spool.SpoolCarrierId` →
> `SpoolProcessing.SpoolId`.
>
> The convention this implies is now written down as **`[DBD §6.2a]`**, which did not exist before —
> its absence is why the question arose at all.

**Rejected: `SpoolLot`.** It was the strongest disambiguator on semantics — "lot" says material
quantity, unmistakably not equipment — and it is disqualified anyway, because **"lot" is a live
contested term here**: `OI-24` (lot number has no column and no generator), `OI-99` (lot is undefined
when a coil has more than one source rod, the normal case under welded feed), `OI-29` (no
receiving-lot header), plus supplier heat/lot on the certificate chain. Also rejected: renaming the
four bare lookup nouns instead, because they are **heterogeneous** — `Stand` is an equipment-position
register, `Drawer` a die-*size* catalogue of 13 rows, `Edger` a tooling configuration — so no single
suffix is correct for all four, and `Stand`/`Drawer` are common English words that make a mechanical
rename unsafe.

**Scope of the change: schema only.** The API surface (`GET /spools`, `POST /checkin/spool`,
`POST /spool/complete`), the `SpoolController` / `ISpoolRepository` code identifiers, every screen
label and the `SP-#####` alpha format are all **untouched** — the same boundary `Q58` set. The four
child tables keep their `Spool…` prefix and the `SpoolAlpha` column keeps its name, because
`SpoolAlpha` is **unambiguous by construction**: the article has no alpha, it has a `SpoolNo`.

**The cost, recorded rather than absorbed.** A *swap* means a stale reference is **silently wrong**
rather than obviously stale: a pre-23-Aug document saying `Spool.Alpha` means what is now
`SpoolProcessing.Alpha`, and the table now called `Spool` has no `Alpha` at all. A fresh name would
have failed loudly instead. Two mitigations: `[DBD §6.2a]` states the swap and its date explicitly,
and the five child foreign keys named `FK_<child>_Spool` were renamed to `FK_<child>_SpoolProcessing`
so no constraint name claims the wrong parent. `CHANGELOG.md` entries written before 23 Aug 2026 keep
the old names by design.

**Verified, not asserted.** Teardown → `RunAll` → `RunAll` → seed → `RunAll_MVP2` on LocalDB:
**34 tables · 57 FKs · 69 index statements · 2 procedures · 1 trigger · 212 seed rows · 0 empty
tables**, idempotent on re-run. Every figure is **identical to the pre-rename baseline**, which is
what a pure rename must produce and is the evidence that it was one.

Related: **`Q86`** (the `SpoolConfiguration` merge that followed), **`Q42`** (the `SpoolNo` format, still open), **`Q58`** (the rename-only precedent),
**`OI-120`**, `[DBD §6.2a]`, `SpoolQueue.md` §7 item 1.

---

---

**Q86** · `Medium` · Owner: Nagarro (internal design) · `Decided Aug 23, 2026`
**Should `SpoolConfiguration` remain a table?**

**Asked:** immediately after `Q60`, in the same pass. `SpoolConfiguration` was a **size class** — `Name` plus min/max
weight, core diameter and outer diameter — referenced by two `SpoolTypeId` foreign keys. The client
confirmed on 20 Aug 2026 that **every article is the same size**, so it held exactly **one** meaningful
row while the articles number 30–45. A one-row parent carrying six constants is a join for no
information.

> **Decision (August 23, 2026): merge it into `Spool`.** The six dimensional columns and `Name` (as
> **`SizeClass`**) move onto the article itself. `SpoolConfiguration` is dropped, along with
> `FK_SpoolProcessing_SpoolConfiguration`, `FK_Spool_SpoolConfiguration` and both `SpoolTypeId`
> columns. The three `CK_SpoolConfig_*` range checks are carried over as `CK_Spool_Weight` /
> `_CoreDiam` / `_OuterDiam`.
>
> **New baseline: 33 tables · 55 FKs · 69 index statements · 1 procedure · 1 trigger · 210 seed rows**
> *(seed rows became **251** on 23 Aug 2026 when the article registry was seeded at its real size —
> 45 rows, `SP-0001`…`SP-0045` — replacing four placeholders; object counts unchanged)*
> (`[DBD §6.2]`, and `[DEP §4.2]`'s gate moved to `V1`=33 / `V2`=55). **Index statements did not move**
> — nothing was ever indexed on `SpoolTypeId`.

**Two things it cost, recorded rather than absorbed.**

**(1) It denormalises.** The same eight values now repeat on all 30–45 rows, and a second purchased
size becomes a multi-row `UPDATE` where the old shape needed one `INSERT`. **The fifteen additional
carriers are still under client decision**, so this is a live risk, not a theoretical one. It is worth
it only while *"every article is one size"* holds — **if a second size is confirmed, revisit the
merge.** `UQ_SpoolConfig_Name` could not survive and is deliberately not recreated: every article
shares one `SizeClass`.

**(2) It turned a guaranteed lookup into a conditional one.** `SpoolProcessing.SpoolTypeId` was
`NOT NULL`, so check-in could always read the limits. The path is now
`SpoolProcessing.SpoolId → Spool`, and **that link is nullable by design** — `Q42` is open and nothing
seeds articles in production yet. Three options were weighed: making `SpoolId` `NOT NULL` was
**rejected** because it would block FL1 spool completion until `Q42` lands; skipping validation when
unassigned was **rejected** as a silent hole. **Adopted: a documented fallback of *any active `Spool`
row's limits*** — well-defined precisely because all articles are one size, requiring no external
constant. That fallback becomes ambiguous the moment a second size exists, which is the same trigger
as (1).

**The two-row trap, and it nearly cost real data.** `SpoolConfiguration` was seeded with **two** rows
and only one was a spool: `TKUP-1 Intermediate Spool` (the article — merged) and **`Coreless Finish
Coil`**, which is the FL2 **output** and is *coreless*, so it has no article to merge into. Nothing
referenced it — every seeded `Spool` and `SpoolProcessing` row used `SpoolTypeId = 1` — so the merge
was mechanically clean; but it carried the **only recorded dimensional bounds for a finished coil**
(100–1100 lb, core 8–16″, OD 20–36″). Those are **re-homed as a comment on the `CoilOutput` block in
`05_QualityOutput`**, deliberately *not* as columns or constraints: nothing validated against them
before, and making them enforceable under cover of a schema tidy-up would be new behaviour. Read with
**`OI-66`** (the OD → weight conversion).

**Verified, not asserted.** Teardown → `RunAll` → `RunAll` → seed → `RunAll_MVP2` on LocalDB:
**33 tables · 55 FKs · 2 procedures · 1 trigger · 210 seed rows · 0 empty tables** *(seed rows now **251** — see the note above)*, idempotent on
re-run, and `[DEP §4.2]`'s gate passes as rewritten.

Related: **`Q60`** (the swap this followed), **`Q42`** (the `SpoolNo` format — still open, and the
reason `SpoolId` is nullable), **`OI-66`**, **`OI-120`**, `[DBD §6.2]`, `[DBD §6.2a]`.

---
