# Flat Wire Mill — Open Questions, MVP-2 Deferred Screens

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**
**Extracted from:** [`../../Analysis/FlatWireOpenQuestions.md`](../../Analysis/FlatWireOpenQuestions.md) on 11 Aug 2026

---

> **⚠ MVP-2 — deferred scope.** Nothing here is part of MVP-1 or of MVP-1 planning. Questions are **copied
> verbatim** and **no `Q##` was renumbered**.
>
> **The master register remains [`Analysis/FlatWireOpenQuestions.md`](../../Analysis/FlatWireOpenQuestions.md),
> and it is still authoritative.** It keeps all 99 rows in its Quick Reference decision log and all three
> question bodies below, each marked `⚠ MVP-2` in place. That is deliberate, and it is what makes this file
> safe: **every inbound `OQ-##` / `Q##` reference from the phase files, `REVIEW.md` and the master
> specification continues to resolve against the master without a single edit.** Numbering is contiguous
> across the pair, not within either half.
>
> If the two ever disagree, **the master wins.**

---

## ⚠ Read this first: this file holds three questions out of ninety-nine

All 99 questions were classified against the deferred screen set — DB9, DB9A, DB10, Die Management, OEE and
pass-schedule generation. **Only one open question is unambiguously MVP-2.** The rest of the register is
MVP-1 or out of shopfloor scope entirely.

The near-misses matter more than the hits, because four questions *sound* like pass-schedule questions and
are **firmly MVP-1** — they are the **read boundary**. MVP-1 never authors a pass schedule; it reads one at
check-in to build the PLC push payload and persists a snapshot of what it pushed:

| Question | Why it is **MVP-1**, not MVP-2 |
|---|---|
| **Q14** Pass schedule selection mechanism at check-in | The check-in read itself — `phase-04`, *The pass-schedule read contract* |
| **Q15** FL3 hybrid pass schedule — one or two? | FL3 is a production route; check-in must read the right schedule for it |
| **Q64** Pass schedule ID on coil completion and cert record | The snapshot rule. `[PLC §620]` requires *"which pass schedule configured it, at which version"* |
| **Q61** Mid-run pass schedule change — alpha handling | Mid-run is the active run — Phase 6 |

Two more that look deferred and are not: **OI-77** edger blade profiles (the edgers are on FM2 `S2`/`S3` and
every FL2/FL3 run uses them) and **Q20** supervisor mirroring (it surfaces on **Dashboard 1**).

---

## What stayed in MVP-1 and applies here

Nothing cross-cutting was copied into this file — it is *cited, never duplicated*, because the repository has
a long, documented history of duplicated sections drifting apart.

| Artifact | Why it stayed |
|---|---|
| [`Analysis/FlatWireOpenQuestions.md`](../../Analysis/FlatWireOpenQuestions.md) | **The master register.** All 99 rows and the `72 of 99` shopfloor filtered index |
| The register's **change log** | Cites question numbers throughout; halving it would destroy the audit trail the register exists to hold. Held **undivided** in [`../../CHANGELOG.md`](../../CHANGELOG.md) since the 12 Aug 2026 consolidation, under `Analysis/FlatWireOpenQuestions.md` — including the `Q##` old→new renumbering map |
| The **Quick Reference decision log** | The register's coverage index. Holes in it would read as missing questions |
| `Q14`, `Q15`, `Q64`, `Q61`, `OI-77`, `Q20` | MVP-1, for the reasons in the table above |

---

## The questions

### OI-88 — the only open MVP-2 question

**Scope: MVP-2.** The Dashboard 9 authoring screen. MVP-1 reads a pass schedule and never creates one, so
this question does not gate any MVP-1 phase.

**OI-88** · `Critical` · Owner: Tim O.
**Pass Schedule UI vs. table management**
The system requires a Pass Schedule database (not an auto-generator) — confirmed. Is there a UI screen for Operations/Maintenance to create and edit pass schedule records, or is this managed directly in a database table? A UI is expected given the manual maintenance requirement.

---

### Q83 — decided, and it half-spans

**Scope: MVP-2 for the tracking mechanism; MVP-1 for the bands.** Die inventory and lifecycle left MVP-1 on
11 Aug 2026 — per-tool identity, registration, cumulative footage per die serial and the reset flow are all
MVP-2. **But the 60/85 % die-life bands are MVP-1**, and MVP-1 reads life at **die-size** granularity from
`Drawer.LastGrindingFeet` / `Drawer.TotalFeetAllowed`.

> **The decision below assumes per-tool tracking that MVP-1 does not have.** `D4` is restated at size level in
> [`DieChangeAndManagement.md` §2.4a](../../MVP-1/RequirementDocuments/DieChangeAndManagement.md): MVP-1
> rejects an unrecognised die **size**, not an unregistered physical die, and **two dies of one diameter share
> a counter**. Read the decision as the MVP-2 target state.

**Q83** · `Medium` · Owner: Tim O. / Maintenance · `Decided May 4, 2026`
**Die life tracking — system or manual**

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

### Q62 — decided, and it spans both scopes

**Scope: spans.** `FW-014` is a story across the boundary — the `PassScheduleChangeLog` table and the
Dashboard 9 editing flow (Step 1) are **MVP-2**; the **Active Run Monitor alert and its acknowledgement**
(Step 2 onward) are **MVP-1**, and the rule that the line continues on the previous PLC values until the
operator acknowledges is an MVP-1 behaviour.

> **Do not read this question as wholly deferred.** The half that reaches an operator mid-run is MVP-1.

**Q62** · `High` · Owner: Tim O. / Shannon R. · `Decided May 4, 2026`
**Pass schedule override authority and logging**

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
