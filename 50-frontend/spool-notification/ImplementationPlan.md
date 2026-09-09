# FL1 Spool Completion Notification — Working Implementation Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — saved into the repository as authored.
**Document Type:** The working plan the rest of this folder was derived from
**Status:** **Point-in-time.** Superseded on any point where it and the three maintained files disagree
**Owner:** Frontend (Angular `flat-wire`)
**Shortcode:** — *(derived; **not citable as a requirement**)*
**Part of:** `50-frontend/spool-notification/` — folder index: [`Orchestration.md`](Orchestration.md)

---

> ⚠ **Read [`Orchestration.md`](Orchestration.md) first, not this file.** This is the working plan as
> it was written, kept because it carries the reasoning in one continuous piece. Its content was then
> split across the three maintained files, and **those are the ones to keep current**:
>
> | If you want | Read |
> |---|---|
> | What can start, in what order, and what is stopping it | [`Orchestration.md`](Orchestration.md) |
> | The 63 stories, per story | [`Backlog.md`](Backlog.md) |
> | Requirement → Current → Gap → Corrective action | [`GapAnalysis.md`](GapAnalysis.md) |
>
> ⛔ **This file duplicates them by design, and duplication drifts.** `CLAUDE.md`: *"a fact is
> asserted in one document and cited everywhere else."* Where this file and any of the three
> disagree, **the three win**; where they and the specification disagree, **the specification wins**.
> Do not update this file — update the maintained one and let this stand as the record of the pass.
>
> ⚠ **Two id conventions inside are local to this analysis and were reconciled on the way in.** The
> `NQ-1`…`NQ-14` numbering below became **`Q96`–`Q109`** in
> [`Questions.md`](../../90-registers/Questions.md), and the four unrecorded gaps became
> **`G116`**–**`G119`** in [`Gaps.md`](../../90-registers/Gaps.md). `SCN-##` is unchanged.

---

**Source of truth:** `10-requirements/screens/SpoolCompletionNotification.md` v2.3 (25 Aug 2026),
*Issued for Client Review and Sign-off*. Cited below as **`§n`** / **`R-n`** / **`S-n`** / **`A-n`** /
**`B-n`** / **`D-n`**. The document has **no shortcode** (`DOCUMENTS.md:104`) — cite by filename + §.

**Scope: FL1 only.** `§1.3` names FL1 standalone *"the primary case described here."*

**Implementation reference:** `c:\UAL\Second-Branch\ual-angular\projects\flat-wire\src\lib\` —
`components/active-run/active-run.component.ts`, `components/active-run/spool-milestone.model.ts`,
`components/spool-notification/spool-notification.component.ts`.
**UI reference:** `50-frontend/mockups/dashboard_3_active_run.html` + `spool_notification.js`.

### Two id conventions, both deliberate

- **Story ids are local (`SCN-##`), not `FW-###`.** `FW-###` is a working id replaced in one
  scripted pass from `90-registers/TaskIdMap.md`; minting new ones here would corrupt that mapping.
  Every row maps to its owning story: **`FW-N02`** (Part A, backend evaluator, `blocked`, 4–8 h) or
  **`FW-202`** (Part B, `blocked`, 98 h, critical).
- **New questions are `NQ-##`, never bare `Q##`.** `90-registers/Questions.md` already owns `Q1`
  (roll-gap validation), `Q4`, `Q6`, `Q7` and the rest, and CLAUDE.md is explicit that register ids
  are never reused. A new question numbered `Q1` would silently collide with a live register entry.

---

## 1. Executive position

| | |
|---|---|
| Behaviour rules in the document | **43** — `R-1`…`R-12`, `S-1`…`S-31` |
| Ladder rungs | 4 — M1, M2, M3, M4 `[PROPOSED]` |
| Acceptance criteria | **32** — `A-1`…`A-10`, `B-1`…`B-22`. `§7` names these the UAT basis |
| **Stories in this backlog** | **63** |

| Status | Count |
|---|---|
| **Completed** | 2 |
| **Partially Implemented** | 6 |
| **Not Started** | 35 |
| **Blocked** | 12 |
| **Needs Clarification** | 4 |
| **On Hold** | 1 |
| **Not Applicable** | 3 |
| **Total** | **63** |

⚠ **The two Completed rows deliver no functionality.** They are requirements satisfied because the
correct presentation choice was made (`R-7`, non-blocking) or because no code exists to violate them
(`§2.3`, Escape does not acknowledge). Both must be **protected** during the build, not implemented.

**The feature cannot run at all today.** `active-run.model.ts:100` returns `spoolReading: null`
unconditionally, so `@if (spoolReading(); as reading)` at `active-run.component.html:220` is
permanently false and `<lib-spool-notification>` never renders.

### Two architectural corrections that reshape the plan

**1. Both evaluators are server-side by specification.** `§4.2` design point 6: *"The evaluator
lives in the service, not the browser."* `[SIG §5.5]` says the same of Part A — the spool-progress
payload and `SpoolWeightMilestone` are *"raised server-side on crossing, not client-side on a
threshold check… so every client evaluates the same number rather than each computing its own."*

⛔ **Consequence:** the client must **not** compute milestones from footage. `resolveSpoolMilestone()`
is therefore not merely mis-tuned — it is *architecturally misplaced*. It survives only as a
presentation-tier map from a server-supplied percentage to an accent, never as the ladder itself.

**2. Part A's two events are unpublished.** `[SIG §5.5]` records this as *"a scope decision rather
than an omission"* because Part A is `Should`. Part B's events 11 and 12 **are** published and
built. So Part A's frontend is blocked on backend publication; Part B's frontend is blocked only on
its own build and on the stop edge.

---

## 2. Status legend

| Status | Meaning here |
|---|---|
| **Completed** | Satisfies the requirement as written, verified against the code |
| **Partially Implemented** | Some of the requirement is built; named remainder missing |
| **Not Started** | No code exists |
| **Blocked** | Cannot be built correctly until a named open item closes |
| **Needs Clarification** | Requirement, mockup and code disagree, or the requirement is ambiguous |
| **On Hold** | Paused by decision pending a named clarification. **Excluded from the build sequence** until that question closes — not merely unscheduled |
| **Not Applicable** | Outside FL1 scope or outside this document's scope, with no FL1 work implied |

---

## 3. Backlog

### EPIC A — Part A, weight milestone alerts (`§2`) · owner `FW-N02` · 17 stories

| Story | Req | Scenario | Status | Current Implementation | Expected Behaviour | Gap | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|---|---|
| **SCN-A1** | `§2.1` M1, `A-1`,`A-2` | 75 % milestone | **Not Started** | `resolveSpoolMilestone` returns `Info` for *any* value below 90, including 0 % | Raises at ≥ 75 % within one telemetry update; nothing below 75 % | No 75 % boundary; no "below M1" state | Consume server milestone; accent map gains a 75 rung; return `null` below 75 | — | A11, A12 | **High** |
| **SCN-A2** | `§2.1` M2 | 90 % milestone | **Partially Implemented** | `>= 90 → Warn` — the one correct boundary | Caution tone, **adds remaining weight** | Copy and the *remaining* value do not exist | Add M2 title/lead to content-data; populate the `remaining` cell | — | A13 | **High** |
| **SCN-A3** | `§2.1` M3 | 100 % / target reached | **Partially Implemented** | `percentComplete === SPOOL_SCALE_TICKS.FULL → Success` | Fires at **≥ 100 %** | Strict equality on a continuous value — 99.7 → Warn, 100.3 → Danger. **M3 practically unreachable** | `>= 100 → Success`, **no upper bound** while A4 is on hold. Becomes `>= 100 && <= 101` only if M4 is confirmed | — | — | **Critical** |
| **SCN-A4** | `§2.1` M4 | Over target | **Not Started** — ✅ released 8 Sep 2026 | `> 100 → Danger` | `> 101 %` **and M3 not yet acknowledged** | No margin — flickers at exactly the moment `§2.1` says it must not; and fires even when M3 *was* acknowledged | **Build it:** add `SPOOL_SCALE_TICKS.OVER = 101` and gate on M3-unacknowledged. ⚠ **Land with the M3 half (G-3) in one pass** — `Danger` is now an agreed rung, so the "do not emit it" instruction lapses | **`Q18` ✅ closed** — M4 is confirmed wanted, unqualified; it is a requirement, no longer `[PROPOSED]` | A5 | High |
| **SCN-A5** | `R-3`,`R-4`,`A-5`,`A-6`,`A-8` | Acknowledge arms the next | **Partially Implemented** | `acknowledgeSpool()` sets one boolean, never reset | Dismisses, arms the next, **closes every rung below** | No ladder state, no arming, no `closeLadderThrough` | Ladder state `{shown, acked:Set, spoolKey}` | — | A12 | **Critical** |
| **SCN-A6** | `R-6`,`A-7` | Escalate in place | **Not Started** | — | Supersedes in place; **exactly one card ever on screen** | No escalation path | Re-dress the same card; never a second instance | — | A5 | **High** |
| **SCN-A7** | `R-5`,`A-4` | Live update while unacknowledged | **Not Started** | `SpoolReading` is a static pre-formatted snapshot | Weight, percent, remaining, fill rate, ETA update every telemetry tick | No live source bound | Bind to the server progress payload | — | A12 | **High** |
| **SCN-A8** | `R-7`,`R-8`,`A-3` | Non-blocking | **Completed** | Inline `@if` + `.floating-popover`; no backdrop, no focus trap; `CommonPopupService` deliberately avoided (`[UIC §3.16]`) | No modal, no backdrop, no focus trap | None — though `A-3` stays untestable until the card renders | None. **Protect this**; do not migrate to a modal | — | — | — |
| **SCN-A9** | `R-10`, `§2.3`, `§4.6` Declined | Docked indicator | **Partially Implemented** | Pill exists: label, %, mini bar, weight, *Complete spool* | Collapses to a docked indicator; **re-expands at the next milestone**; shows *acknowledged* / *target reached* | No re-expansion; no state note | Wire re-expansion to A6; add the note | — | A5, B13 | Medium |
| **SCN-A10** | `R-9`,`A-10` | Per-spool re-arm | **Not Started** | `isSpoolAcknowledged` never reset — not in `clear()`, not on line change | New spool on the same run → weight to zero, **all** milestones re-arm | No spool identity to key on; flag survives navigation | Key state to spool identity; reset on new spool **and** in `clear()` | **NQ-12** | A12, D1 | **High** |
| **SCN-A11** | `§3.2`, `D5`, `D14` | Target resolution | **Blocked** — ⚠ **on `NQ-6` only** | None. Mockup passes the **withdrawn** `targetLb: 2000` | Customer min/max from the order, graded by weight | ✅ **Source field identified 8 Sep 2026** — the **order**, reusing *Max Wgt of Spool* for the maximum and adding a matching minimum | Resolve server-side; client renders nothing when null | **`Q18` ✅ closed** · **`Q33`** no longer withholding the basis · **NQ-6** | — | **Critical** |
| **SCN-A12** | `§4.2`#6, `[SIG §5.5]` | Consume server milestone + progress payload | **Blocked** | Client implements 5 of the hub's 20 members; neither Part A event among them | Server raises on crossing; client renders | **Both events unpublished** | Backend publishes; client adds the observables | **NQ-11** | `FW-N02` | **Critical** |
| **SCN-A13** | `R-2`, `§2.3` | Card presentation | **Partially Implemented** | Weight large + target beneath ✅; bar with 75/90 ticks ✅; scale `%`/75/90/100 ✅; `updatedAt` ✅; single Acknowledge ✅; `cells` loop in `col-4` ✅ | Percent, remaining, spool footage, fill rate, est. to target + a visible *last updated* | `cells` never populated — all six content-data keys orphaned | Build the cells in the mapper | **NQ-5** (the 6th cell's identity) | A7 | Medium |
| **SCN-A14** | `R-11`,`A-9` | Acknowledgement audit | **Not Started** — ✅ unblocked 8 Sep 2026 | Nothing recorded | Operator, milestone, weight at ack, timestamp, **against the run** | No endpoint yet — but the store is now decided | Write to the **existing run-event stream**; ⛔ do **not** create a new milestone record type | **`Q20` ✅ closed** | — | Medium |
| **SCN-A18** | `R-13`,`A-11` | Supervisor mirror of the unacknowledged M3 | **Not Started** — ➕ new from `Q20` | Nothing exists | **Only** the unacknowledged 100 % milestone reaches the supervisor | 75 % and 90 % must never mirror — mirroring all three teaches the supervisor to ignore it | Raise to the supervisor view when M3 goes unacknowledged | **`Q20` ✅ closed** · `D-38` (no dedicated Supervisor Monitor) | A14 | Medium |
| **SCN-A15** | `R-12`,`S-14` | Thresholds are configuration | **Not Started** | `SPOOL_SCALE_TICKS` is a compiled constant | Tunable by Operations **without a software release** | Constant — and it does double duty as the scale's labels | Server-supplied; keep axis/accent coupled (`[UIC §3.16]`) | — | A12 | Medium |
| **SCN-A16** | `§2.3` | Escape does not acknowledge | **Completed** | No key handler exists | Dismissal must be deliberate | None | None — **do not add a handler** | — | — | — |
| **SCN-A17** | `§2.3` | Announced without interrupting | **Needs Clarification** | `role="status" aria-live="polite" aria-atomic="false"`; pill `aria-live="off"` | Announced without interrupting | Correct for M1–M3; **M4 danger also polite** | Possibly `assertive` at M4 | **NQ-1** | — | Low |

### EPIC B — Part B, stop confirmation (`§4.1`–`§4.4`, `§4.6`) · owner `FW-202` · 20 stories

| Story | Req | Scenario | Status | Current Implementation | Expected Behaviour | Gap | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|---|---|
| **SCN-B1** | `S-9`,`B-10`, `§6` | Durable prompt, re-delivered | **Not Started** | No subscription to event 11 | Survives refresh; re-delivered on re-join | Client consumes nothing | Add `spoolCompletionPromptDue$`; **subscribe before joining**; **idempotent** — re-delivery is specified, not a fault | — | — | **Critical** |
| **SCN-B2** | `S-1`,`S-2`,`B-1` | Armed by weight + confirmed stop | **Not Started** | — | Both conditions; below target a stop raises nothing | Server-side; the client must never infer it | Render only what the server raises | **Q21** | `FW-202`, test `C2` | **Critical** |
| **SCN-B3** | `S-3`,`B-2`,`B-3` | 5 s dwell, speed ≈ 0 | **Not Started** | — | Stop holds for the dwell; speed corroborates | Not built; the edge is dark (`TryMapLineState` returns `false`) | Server-side. ⛔ The client must **never** promote speed ≈ 0 to a stop | **Q21/OI-35** | test `C2` | **Critical** |
| **SCN-B4** | `S-4`,`B-4`, `§6` | Latched weight | **Not Started** | — | Frozen at the stop timestamp; **does not drift while open** | — | Render `LatchedWeightLb` only; never substitute a `PayoffWeight` tick | **NQ-14** | B1 | **Critical** |
| **SCN-B5** | `S-5`,`B-7`, `§4.2`#2 | One prompt per stop event | **Not Started** | — | Edge not level; no re-raise while stopped | — | Server-side; client dedupes by `runId` + stop timestamp | — | B1 | **High** |
| **SCN-B6** | `§4.6`, `S-15` | The question step | **Not Started** | — | *"Was the machine stopped to remove the completed spool?"* asked **once**, largest type, **not restated in the title**; two full-width gloved rows, **expected answer first**, each stating its own consequence; **Y/N advertised on the choices** | No dialog | Build step 1 | — | B1 | **Critical** |
| **SCN-B7** | `S-10`,`B-9` | No Escape, no backdrop, no close | **Not Started** | — | The operator must answer; **no close affordance** | ⚠ The **mockup violates this** — `FwModal` binds both | Build without them; do not inherit `fw-modal.js` | — | B6 | **High** |
| **SCN-B8** | `S-7`,`B-5`, `§4.2`#9 | Answer **No** | **Not Started** | — | Closes; no transaction, identity, label or spool change; decline **logged**; does **not nag** for the same stop; re-arms on the next transition | — | `Answer:"No"` → **200 DECLINED**, not an error | — | B6 | **High** |
| **SCN-B9** | `S-6`,`B-6` | Answer **Yes** | **Not Started** | — | Routes into the completion workflow | ⚠ Its destination screen does not exist — see G3 | Advance to the completion step | — | B6, G3 | **Critical** |
| **SCN-B10** | `S-8`,`B-8`, `§6` | Auto-dismiss on resume | **Not Started** | — | Auto-dismiss, log *line resumed*, re-arm | — | Handle event 12 `Answer:"AutoDismissed"` | — | B1 | **High** |
| **SCN-B11** | `§4.2`#12, `§4.6` | Over-target stop | **Not Started** | — | Same prompt with the latched over-target weight; **inline warning between question and choices**; overage flagged on the summary | — | Build the inline band | — | B6 | Medium |
| **SCN-B12** | `§4.6` | Evidence footer | **Not Started** | — | Machine state, dwell held, speed, stop timestamp, spool identity — **provenance, not headline** | — | Build; see D6 on identity | **NQ-5** | B6 | Medium |
| **SCN-B13** | `S-13`,`B-11`, `§4.6` Declined | Manual completion | **Partially Implemented** | Pill carries a *Complete spool* button — **always visible**; `completeSpool()` only sets the acknowledged flag | Available whenever weight ≥ target **and the line is not running**, including after a No; **hidden while the line runs** | No gate, no action. ⛔ **The availability condition has no transport** — Gap G-7 | Gate on line-not-running + target-reached; open the completion step | **NQ-2** | B1, C1 | **High** |
| **SCN-B14** | `§4.2`#14, `§6`, `OI-75` | Multiple operators | **Not Started** | — | One prompt per line; **first answer wins**; the answering operator recorded | — | Event 12 closes the dialog on every FL1 terminal | **OI-75**, **NQ-13** | B1 | Medium |
| **SCN-B15** | `D3`, `§4.6` | Dialog must not scroll | **Not Started** | — | The whole decision visible at once | — | Scale to fit; ⛔ **no `max-height`, no `overflow`** (CLAUDE.md, `[UIC]`) | **NQ-7** | B6 | **High** |
| **SCN-B16** | `§4.2`#13, `§6` | Communications loss | **Needs Clarification** | Connection banner exists (`Reconnecting` / `Disconnected`) | **No machine data → no prompt, by design**; manual completion is the fallback | The banner is built, but the fallback is unreachable — Gap G-7 | Ensure no prompt is synthesised client-side | **NQ-3** | B13 | Medium |
| **SCN-B17** | `§4.2`#7, `§6` | Suppression after a software pause | **Blocked** | — | Prompt suppressed when a pause already captured a reason | Server-side (`FW-171`) | None client-side | **Q21** | `FW-171` | Medium |
| **SCN-B18** | `§6` | Prompt left unanswered | **Not Started** | — | **Persists** — *"a decision, not an alert"*; nothing is blocked because the machine is stopped | — | No timeout, no auto-close except resume | — | B1 | Medium |
| **SCN-B19** | `S-12` | Both outcomes audited | **Blocked** | — | Prompt raised (stop ts, latched weight), the answer, **the answering operator**, the answer timestamp | ⛔ `FlatWireRun.PromptAnsweredBy` **does not exist** | Backend column (`FW-244`) | **NQ-10** | `FW-244` | **High** |
| **SCN-B20** | `§4.6` Result | Result step | **Not Started** | — | Committed facts, **weight basis**, label confirmation, **the carrier the next spool winds onto**, and that **the ladder has re-armed** | — | Build step 3 | — | C4, D1 | **High** |

### EPIC C — weight verification at completion (`§4.5`) · owner `FW-202` · 10 stories · all **Not Started**

| Story | Req | Scenario | Current | Expected Behaviour | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|
| **SCN-C1** | `S-16`,`B-12` | Optional scale entry | — | Optional; nothing entered → calculated recorded, **no reason requested** | Build the entry — it is the only path in this epic that can run today | **OI-56/OI-38** — ⛔ **`Q30` confirms no scale exists anywhere on either line**, and `Q12`'s proposed one is at the FL1 **payoff**, not the take-up; answer owed **10 Sep 2026** | B9 | **High** |
| **SCN-C2** | `S-17`,`B-13` | Gross → net, variance | — | Gross in; **net = gross − tare**; variance in **lb and percent**, same interaction | Tare from the system (`A2`), not typed | — | C1 | **High** |
| **SCN-C3** | `B-14` | Invalid scale input | — | Below tare, blank or non-numeric → **rejected**; variance clears; basis falls back to calculated | Validation + fallback | — | C2 | Medium |
| **SCN-C4** | `S-18`,`S-19`,`B-22` | Basis choice | — | Operator chooses explicitly; scale **pre-selected once entered**, revertible; **never silent**; governs record, label and downstream | Two-option control + a "will record" sentence | — | C2 | **High** |
| **SCN-C5** | `S-20`,`B-15`,`B-16`,`D4` | Tolerance ±2 % | — | Flagged but **never prevents creation**; **commit stays enabled throughout** | ⛔ **The criterion most likely to be implemented backwards** (`FW-202`) | **OI-56** — the value; **NQ-4** | C2 | **Critical** |
| **SCN-C6** | `S-22`,`B-17`,`B-18`,`B-19` | Supervisor override | — | Reason + supervisor + **PIN**; PIN authenticates only, **never in the payload or stored**; incomplete → flags exactly the missing fields, focuses the first, commits nothing, **no lockout** | Build the panel | **OI-56/OI-38** — where the PIN validates | C5 | **High** |
| **SCN-C7** | `S-23`,`B-20` | Remote approval | — | Notifies a supervisor; **does not block or change the screen**; an on-floor override stays available | Request + log | **OI-75** | C6 | Low |
| **SCN-C8** | `S-25`,`B-21` | Variance corrected back inside | — | The override requirement **disappears**; completion records no override | Recompute on every edit | — | C5 | Medium |
| **SCN-C9** | `S-21` | Scale retained when calculated chosen | — | Reading **retained on the record** — the discrepancy is the evidence that validates the density factor | Always send `scaleWeightLb` when entered | — | C4 | Medium |
| **SCN-C10** | `S-24` | Override marked on the record | — | Flag, supervisor, reason, **both weights**, variance — and **stated plainly on the result** | Result step surfaces it | — | B20 | Medium |

### EPIC D — the next spool carrier (`§4.7`) · owner `FW-202` · 7 stories

| Story | Req | Scenario | Status | Current | Expected Behaviour | Gap | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|---|---|
| **SCN-D1** | `S-26`,`D10` | Capture the next carrier | **Blocked** | — | Captured in the **committing column**, in the same transaction | Absent from `CompleteSpoolRequest` entirely | Add to the contract + UI | **Q42**, **NQ-9** | `FW-202` | **Critical** |
| **SCN-D2** | `S-27`,`D11` | Typed and validated | **Blocked** | — | **Typed text validated against the registered list — not a drop-down**; unrecognised refused with the field marked | — | Validate against `Spool.SpoolNo` | **Q42** | D1 | **High** |
| **SCN-D3** | `S-28`, `§4.6` | Hard gate on commit | **Needs Clarification** | — | *"Cannot be committed without it… no skip, no deferred entry"*; `§4.6`: commit **unavailable** until valid | ⚠ **Conflicts with `B-16`** — Gap G-8 | Resolve the two gates | **NQ-4** | D2, C5 | **High** |
| **SCN-D4** | `S-29` | Carrier already carrying material | **Not Started** | — | Refused, **naming the spool it holds** | — | Server check + a named error | — | D2 | Medium |
| **SCN-D5** | `S-30` | Decline captures nothing | **Not Started** | — | No carrier on a No | — | Ensure the No path sends none | — | B8 | Medium |
| **SCN-D6** | `S-31`, `§4.6` | Carrier audited; identity shown | **Blocked** | — | Number, operator, timestamp | ⛔ **On FL1 there is no spool alpha before commit** — Gap G-4 | Show the **carrier**; the alpha only on the result | **NQ-5** | D1 | **High** |
| **SCN-D7** | `§4.7` note | Mandrel / core diameter | **Not Applicable** *(provisional)* | — | Spec's reading: **not entered** — every spool is one standard size | — | None unless `Q46` says otherwise | **Q46** | — | Low |

### EPIC E — labels (`§4.8`) · owner `FW-202` · 2 stories

| Story | Req | Scenario | Status | Expected Behaviour | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|
| **SCN-E1** | `S-11`,`B-6`,`A5` | Print only after commit | **Not Started** | Never on opening, never on Yes alone if the transaction fails; **two per spool, one per side** | Trigger from the commit result | — | B9 | **High** |
| **SCN-E2** | `§4.8`,`D12`,`D13` | Label content | **Blocked** | Carrier as **primary barcode**, every alpha as **secondary**; weight per alpha and order(s) `[PROPOSED]`; pass schedule **not printed** | Backend / print work | **Q44** | — | Medium |

### EPIC F — Part C, short close (`§5`) · 3 stories

| Story | Req | Scenario | Status | Expected Behaviour | Gap | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|---|
| **SCN-F1** | `§5`,`D7` | Short close as an unplanned stop | **Blocked** — ⚠ **on the 10-90 SOP only** | Graded on the **customer min–max, by weight**; inside → continue; outside → supervisor override + production hold, **or concession — offer first, remake last** | Nothing exists; the mockup's `targetMinLb` is parsed and never read | ✅ The customer **minimum** now has a source (`Q18`, `D14`) | **10-90 SOP** — ⚠ **being revised, not merely unlocated**; `Q79` ratified the rule itself on 8 Sep | A11 | **High** |
| **SCN-F2** | `§5`,`D8` | The spool always runs off | **Not Applicable** *(no UI)* | FL2 has no spool stripper; the spool is emptied and returned to FL1 regardless | — | None — operational, not a screen rule | — | — | — |
| **SCN-F3** | `§5.1`,`D9` | Mid-run coil break | **Blocked** | Stop **removed, new stop from zero**; weight does **not** resume; the leftover is welded to the next coil on FL1 | *"A run and stop model change, not a screen rule"* | Reconcile run-cumulative vs coil-local footage | **OI-25**, 10-90 SOP | `G34` | Medium |

### EPIC G — cross-cutting · 4 stories

| Story | Req | Scenario | Status | Current | Expected Behaviour | Gap | Required Changes | Open Questions | Deps | Pri |
|---|---|---|---|---|---|---|---|---|---|---|
| **SCN-G1** | `§4.6`,`§6`,`A3` | Machine status on screen | **Not Started** | Header status comes from the initial REST read only; no `LineStatus` (event 7) subscription | The screen reflects *Stopped* when the prompt arrives | The prompt would appear over a header still reading *Running* | Subscribe event 7 | — | — | **High** |
| **SCN-G2** | `R-10` | Must not obscure the command bar or trace headers | **Needs Clarification** | `.floating-popover` — `right:20px; bottom:50px; width:400px; z-index:600` (`styles.scss:657`). Mockup uses `bottom:124px` to clear its 104 px bottom `.actions` bar | Must obscure neither | The Angular screen uses a **left** nav rail, not a bottom bar, so the offsets are not comparable — but overlap with the traces card is unverified | Verify at 16:9; composition is **not** taken from the mockup (`F-15`) | — | — | Medium |
| **SCN-G3** | `§1.2`, `§4.2`#11, `§10` note | The FL1 completion-workflow screen | **Blocked** | — | Yes is *"an entry point, not a bypass"*; the workflow enforces its own **per-spool SPC gate** before an identity is issued | ⛔ **No such screen exists.** The document's own *"Known gap in the deliverables"*: Part B's Yes path *"currently routes into a compact completion summary standing in for that screen"* | Needs its own specification and screen | — | — | **High** |
| **SCN-G4** | `§1.3` | Ladder on FL2/FL3 | **Not Applicable** *(FL1 scope)* | `hasSpoolOverlay: {FL1:true, FL2:false, FL3:false}` — **never read** | `§1.3`: *"The same ladder applies against the coil target"* | ⚠ **`§1.3` contradicts `ActiveRunMonitor.md:62`** — verified: *"Spool-completion alerts \| Present \| Absent \| Absent"* | Out of scope; give the flag its first reader so the seam holds | **Q19** | — | — |

---

## 4. Gap analysis — Requirement → Current → Gap → Corrective Action

**G-1 · The feature is unreachable.**
*Requirement:* `A-2` — crossing 75 % raises the notification within one telemetry update.
*Current:* `active-run.model.ts:100` returns `spoolReading: null` unconditionally; the comment says
the data *"belongs to the spool completion story… today it never does."*
*Gap:* The `@if` at `active-run.component.html:220` can never be true. Everything downstream is dead
code — confirmed by grep: `resolveSpoolMilestone`, `SPOOL_MILESTONE_TONES`,
`SPOOL_MILESTONE_ACCENTS`, `SPOOL_PLACEHOLDER_PERCENT` and `hasSpoolOverlay` have **no production
importer**.
*Corrective action:* Replace the literal with a mapper gated on `profile.hasSpoolOverlay`, fed by
the server progress payload. ✅ **`Q18` has closed (8 Sep 2026) and this gate is gone** — the target
resolves from the order, so the mapper no longer has to return `null` for want of a source. ⚠ `NQ-6`
still gates `SCN-A11`.

**G-2 · The ladder is evaluated in the wrong tier.**
*Requirement:* `§4.2`#6 *"The evaluator lives in the service, not the browser"*; `[SIG §5.5]`
*"raised server-side on crossing, not client-side on a threshold check."*
*Current:* `resolveSpoolMilestone(percentComplete)` is a client-side threshold check.
*Gap:* Architectural, not cosmetic. Two FL1 terminals could disagree, and `R-12`'s
Operations-tunable thresholds cannot be honoured by a compiled constant.
*Corrective action:* Demote the function to a presentation map (server percent → accent); move the
ladder to `FW-N02`'s server evaluator. ⚠ Correct `FW-N02:178`, which builds it over `payoffWeight$`
— `[SIG §5.2]` row 5 names **`FootageCounter`** as spool progress's source and row 4 confines
`PayoffWeight` to payoff bars; `§3.1` derives weight **from footage**. Payoff weight is rod
*depletion*, not spool *fill*, and the two diverge by scrap, threading and in-machine wire — i.e.
near target, exactly where the ladder matters.

**G-3 · M3 is practically unreachable, and M4 has no margin.** *(Split — the M4 half is on hold.)*
*Requirement:* `§2.1` — M3 at **≥ 100 %**; M4 at **> 101 %** *and M3 unacknowledged*; the 1 %
*"exists so the state cannot flicker the instant target is touched."*
*Current:* `=== 100 → Success`, `> 100 → Danger`.
*Gap:* Strict equality on a continuously-varying percentage means M3 essentially never renders
(99.7 → Warn, 100.3 → Danger); M4 fires with no margin, producing precisely the flicker forbidden;
and M4 ignores whether M3 was acknowledged.

*Corrective action — M3 half (`SCN-A3`, build now):* `>= 100 → Success` with **no upper bound**, and
**delete the `> 100 → Danger` branch**. The `Danger` rung is M4's alone, so with `SCN-A4` on hold the
ladder must not emit it at all — leaving it in place would ship the unmargined flicker that `§2.1`
forbids, under a rung nobody has agreed to.

*Corrective action — M4 half (`SCN-A4`, ✅ released 8 Sep 2026):* `Q18` has closed and M4 is a
confirmed requirement. ⚠ **Build it with the M3 half in one pass** — `Danger` is now an agreed rung,
so the instruction above not to emit it lapses on release. Narrow M3 to
`>= 100 && <= 101` and add `> 101 && !acked(M3) → Danger`, with `SPOOL_SCALE_TICKS.OVER = 101` **as a
threshold only** — not a fourth scale label, since `[UIC §3.16]` records the axis/threshold coupling
as deliberate and the scale is 400 px wide.

> ⚠ **What the hold costs, stated so it is a decision and not an oversight.** `§2.1`'s own rationale
> for proposing M4 is that *"an unacknowledged M3 keeps updating and will therefore run past 100 %; a
> notification silently reading '104 % of target' in a *target reached* style understates the
> situation."* Holding M4 accepts exactly that understatement in the interim. `SpoolMilestone.Danger`
> and its tone and accent entries stay dead code meanwhile — ⛔ do not delete them; they are M4's.

**G-4 · FL1 has no spool alpha before commit, and three surfaces show one.**
*Requirement:* `BusinessRules.md:47` — the `SP-#####` alpha is *"Generated by **FL1 at spool
completion**"*. `§4.6` asks the evidence footer for *"spool identity"*.
*Current:* The mockup shows `SP-00031` in the card's TKUP-1 cell, the dialog sub-header and the
evidence footer. The prompt payload's `SpoolAlpha` is **structurally null on FL1** — the broadcast
handler sets it `null`, and the replay path joins it from `SpoolCheckin`, which an FL1 run does not
have (FL1 checks in *rods*).
*Gap:* Three surfaces would render an identity that does not yet exist.
*Corrective action:* Pre-commit identity is the **carrier** (`Spool.SpoolNo`, `§4.7`); the alpha
first exists in `CompleteSpoolResponse.SpoolAlpha` and belongs on the **result step only**.
`SpoolReading` gains `spoolCarrier`, ⛔ **not** `spoolAlpha`.

**G-5 · Acknowledge and Complete are the same action.**
*Requirement:* `R-3` (ack dismisses) versus `S-13`/`§4.6` (manual completion runs the transaction).
*Current:*
```ts
public acknowledgeSpool(): void { this.isSpoolAcknowledged.set(true); }
public completeSpool(): void  { this.isSpoolAcknowledged.set(true); }
```
*Gap:* `completeSpool()` makes no server call, does not clear `spoolReading`, closes no spool.
*Corrective action:* Separate them; `completeSpool()` opens the completion step.

**G-6 · Milestone state never resets.**
*Requirement:* `R-9`/`A-10` — per spool; a new spool re-arms all milestones from zero.
*Current:* `isSpoolAcknowledged` is set once and never cleared — not by `clear()`, not by `apply()`,
not on a line change.
*Gap:* `A-10` fails; and because DB3 is one screen for all lines (`D-55`), navigating away from FL1
and back returns to a spuriously acknowledged card.
*Corrective action:* Key ladder state to spool identity; reset on a new spool **and** in `clear()`.

**G-7 · `S-13`'s availability condition has no transport.** *(New — in no register.)*
*Requirement:* `S-13`/`B-11` — manual completion whenever weight ≥ target **and** the line is not
running, *"including after a No"*, hidden while running. `§4.2`#13 makes it the **comms-loss
fallback**.
*Current:* The pill's *Complete spool* button is always visible and inert.
*Gap:* *Weight ≥ target* is the server's **Armed** state, and **no event broadcasts it**. Event 11
fires only on the stop edge. After a decline the client can infer it (event 12 told us), but
**before any prompt — precisely the comms-loss case — it cannot**. The one scenario the fallback
exists for is the one it cannot serve.
*Corrective action:* Broadcast the Armed state, or return it on `GET /run/active`. Raise as **NQ-2**.

**G-8 · Three commit gates contradict one another.** *(New.)*
*Requirement:* `B-16`/`S-20`/`D4` — variance *"never disables the commit control."* `§4.6` — *"the
commit control is unavailable until it [the carrier] is valid."* `S-22` — an incomplete override
*"does not commit"* but flags the missing fields and focuses the first.
*Gap:* Three interaction models: never-disabled (variance), disabled (carrier),
enabled-but-rejects-on-click (override).
*Corrective action:* The consistent reading is **enabled-but-validates-on-click** throughout, since
that is what `S-22` describes and what `D4`'s rationale demands. Confirm — **NQ-4**.

**G-9 · The card claims *Live* with no staleness handling.**
*Requirement:* `§2.3` — *"a visible last updated indication."*
*Current:* The footer renders `Live · updated {{ updatedAt }}` with a pulsing dot, unconditionally.
*Gap:* On feed loss the connection banner appears while the card still asserts *Live*.
`[UIC §3.18]` permits `.live-dot` only where *"it is asserting the reading is current."*
*Corrective action:* Derive the footer from connection state.

**G-10 · Milestone copy exists for one rung of four.**
*Requirement:* `§2.1` gives each rung distinct content.
*Current:* `flat-wire.json` has `spoolNearingCompletion` and `approachingTarget` — M1 only.
*Gap:* M2, M3 and M4 have no title or lead. The mockup has all four.
*Corrective action:* Add three title/lead pairs; source `badge` per rung.

**G-11 · The live secondary data is specified and none of it is built.**
*Requirement:* `§2.3` names five live values — percent, remaining, spool footage, fill rate,
estimated time to target — plus a visible *last updated*.
*Current:* The template loops `reading().cells` in `col-4` (a 3-across grid, so 2×3); the six
content-data keys `complete`, `remaining`, `spoolFootage`, `fillRate`, `estToTarget`, `takeUp` are
orphaned; the only sample supplies one cell. `updatedAt` **is** rendered.
*Gap:* Five specified values unbuilt. ⚠ Note the arithmetic: `§2.3` names **five**, the grid holds
**six**, and the sixth content key is `takeUp` — the mockup uses that cell for the spool alpha,
which per **G-4** does not exist on FL1 pre-commit.
*Corrective action:* Populate the five specified values; settle the sixth cell under **NQ-5**.

**G-12 · The pill's glyph ignores the milestone.**
*Current:* `<i class="fa-solid fa-circle-check text-success">` is hard-coded.
*Gap:* An over-target state renders with a success glyph.
*Corrective action:* Drive from `reading().accent`; add the *acknowledged* / *target reached* note
that `§4.6`'s Declined row calls for.

---

## 5. Open Questions / Clarifications Required

**25 total — 11 existing register items and 14 new (`NQ-`).** Only items where the requirement,
mockup and code together do not determine the behaviour.

### Business rule
- **Q18** *(existing, High)* — Which order field carries the customer minimum and maximum, **and is
  M4 wanted?** Blocks A11, F1 and ⏸ holds A4. Register recommendation: reuse *Max Wgt of Spool* for the
  maximum and add a matching minimum; `ActiveRunResponse` already carries
  `coilWeightMaxLb`/`coilWeightMinLb`.
- **Q33** *(existing, High)* — Outside-diameter to weight conversion. `§10`: *"the weight basis for
  every part of this document."*
- **Q19** *(existing, Medium)* — ⚠ **`§1.3` and `ActiveRunMonitor.md:62` state opposite things**
  about FL2/FL3. Outside FL1 scope, but the contradiction should be closed.
- **NQ-6** — `§3.2` grades against a **range**, yet the ladder is expressed as percentages of a
  single target. **Is the ladder's 100 % the customer maximum, the minimum, or the midpoint?**
  Nothing states it, and short close (`§5`) grades against both bounds.

### UI / UX
- **NQ-1** — `§2.3` requires *"announced without interrupting"* and the card is `aria-live="polite"`.
  **Should M4 (over target) be `assertive`?** Polite may not surface before the take-up is overfilled.
- **NQ-4** — `B-16` says commit is never disabled; `§4.6` says it is unavailable until the carrier is
  valid; `S-22` describes validate-on-click. **Which interaction model governs?** (G-8.)
- **NQ-7** — `§4.6` requires two columns *plus* a full-width override *plus* the carrier field, and
  `D3` forbids scrolling. **Has the worst case — over target, out of tolerance, override open,
  carrier invalid — been shown to fit without scrolling?**

### PLC
- **Q21 / OI-35** *(existing, High)* — Line-state vocabulary, the dwell value, and whether the prompt
  is suppressed after a software pause. ⚠ `MasterSpecification.md:3607`: the application `LineState`
  enum **has no `Stopped` member**, yet `FR-141` fires on running → stopped.
- **NQ-8** — `§4.2`#5 says the counter *"can tick on after the drives stop."* **How long after the
  stop timestamp is a late footage tick still attributed to the closing spool** rather than the next?
  `§5.1`'s restart-from-zero makes the boundary material.

### Backend / API
- **OI-56 / OI-38** *(existing, High)* — Where the supervisor PIN validates, and **whether a scale
  exists at the take-up at all**. If none does, `§4.5` is largely inert.
- **Q42** *(existing, High)* — Carrier format, and thirty or forty-five. Blocks SCN-D2's validation.
- **Q44** *(existing, High)* — The full label field list; etched plate replaces or supplements.
- **Q20** *(existing, Medium)* — Where the milestone acknowledgement audit lives (`R-11`/`A-9`).
- **NQ-9** — `CompleteSpoolRequest` has **no carrier field**, yet `S-28` makes it a hard gate.
  **Confirm the contract addition** — it is breaking under `[API §8]`.
- **NQ-10** — ⛔ `FlatWireRun.PromptAnsweredBy` **does not exist**, so `S-12`'s *"the answering
  operator"* cannot be recorded. Confirm `FW-244` closes it before SCN-B19.

### Notification behaviour
- **NQ-2** — **How does the client learn the Armed state (weight ≥ target)?** No event carries it, so
  `S-13`/`B-11`'s manual-completion gate and `§4.2`#13's comms-loss fallback cannot be evaluated
  client-side (G-7).
- **NQ-11** — `[SIG §5.5]` leaves Part A's two events **unpublished** as a scope decision. **Is Part
  A in or out for this delivery?** If out, all 17 EPIC A stories are blocked and the only shippable
  Part A behaviour is the docked indicator driven by Part B's state.

### Spool / order handling
- **NQ-5** — `§4.6` asks the evidence footer for *"spool identity"*, but on FL1 no alpha exists
  before commit (G-4). **Confirm the carrier is the pre-commit identity**, and what the card's sixth
  cell shows (G-11).
- **Q46** *(existing, Medium)* — Mandrel / core diameter: entered, fixed, or read?
- **NQ-12** — `§4.7`: *"one rod makes several spools."* **Does a mid-spool rod change or weld reset
  milestone state?** `R-9` re-arms per *spool*, and a spool can span several rods, so it should not —
  but the interaction with `§5.1`'s coil break is unstated.

### Error / edge cases
- **OI-25** *(existing, High)* — Run-cumulative versus coil-local footage offset. Blocks `§5.1` and
  the *"footage at spool start"* term in `§3.1`.
- **NQ-3** — `§4.2`#13: no machine data, no prompt. **What does the screen show during a comms loss
  with weight already over target?** The connection banner says the feed is lost; it does not say a
  completion may be owed.
- **NQ-13** — `§6`: *"Two operators signed in… first answer wins."* **What does the losing terminal
  display** when event 12 closes a dialog mid-edit, with a scale weight typed and an override
  part-filled?
- **NQ-14** — `SpoolCompletionPromptDueEvent.LatchedWeightLb` is **non-nullable**, so a server that
  cannot latch broadcasts **`0`** with a warning. **What should the operator see?** `0 lb` presented
  as fact would be answered on.

---

## 6. Final summary

### 6.1 Complete FL1 story list

**63 stories** — A 17 (milestone alerts) · B 20 (stop confirmation) · C 10 (weight verification) ·
D 7 (carrier) · E 2 (labels) · F 3 (short close) · G 4 (cross-cutting). The three **Not Applicable**
rows are retained so requirement coverage stays auditable.

### 6.2 Story status summary

| Status | Count | Stories |
|---|---|---|
| **Completed** | 2 | A8, A16 |
| **Partially Implemented** | 6 | A2, A3, A5, A9, A13, B13 |
| **Not Started** | 35 | A1, A6, A7, A10, A15 · B1–B12, B14, B15, B18, B20 · all of C · D4, D5 · E1 · G1 |
| **Blocked** | 12 | A11, A12, A14 · B17, B19 · D1, D2, D6 · E2 · F1, F3 · G3 |
| **Needs Clarification** | 4 | A17 · B16 · D3 · G2 |
| **On Hold** | 1 | **A4** — M4 over-target, held pending `Q18` |
| **Not Applicable** | 3 | D7, F2, G4 |
| **Total** | **63** | |

⚠ **Nothing is Completed in the sense of delivering a requirement.** `A8` and `A16` are satisfied
because the right presentation choice was made and because no Escape handler was written — both
must be **protected** during the build, not implemented.

### 6.3 Major implementation gaps

1. **The feature never renders** (G-1) — one hard-coded `null`.
2. **The ladder sits in the wrong tier** (G-2) — the spec puts the evaluator in the service.
3. **Part B does not exist at all** — 20 stories against 22 acceptance criteria (`B-1`…`B-22`), zero code.
4. **M3 unreachable** (G-3, M3 half). ⏸ The M4 half is **on hold** pending `Q18`; until then the
   ladder must **not** emit `Danger` at all.
5. **No milestone state machine** — no arming, no escalation, no per-spool reset (G-5, G-6).
6. **The manual-completion fallback cannot be evaluated** (G-7).
7. **Carrier capture is absent from both contract and UI** — and it is a hard gate on commit (`S-28`).
8. **`PromptAnsweredBy` does not exist**, so `S-12` cannot be satisfied.
9. **No FL1 completion-workflow screen exists** (G3) — the Yes path has no specified destination.

### 6.4 Requirement vs implementation discrepancies

| Requirement | Implementation | Verdict |
|---|---|---|
| `§2.1` M3 ≥ 100 % | `=== 100` | **Defect** — unreachable |
| `§2.1` M4 > 101 % and M3 unacked | `> 100`, no ack test | **Defect** — flickers. ⏸ **On hold** (`SCN-A4`, `Q18`); the `Danger` branch is removed, not corrected, in the interim |
| `§2.1` M1 ≥ 75 % | `Info` at any value below 90 | **Defect** — no lower bound |
| `§4.2`#6 evaluator server-side | client-side function | **Architectural** |
| `R-9` per-spool state | flag never reset | **Defect** |
| `R-12` thresholds configurable | compiled constant | **Not met** |
| `R-3` vs `S-13` | both handlers identical | **Defect** |
| `§2.3` five live values | `cells` never populated | **Not met** |
| `§2.3` last-updated | `updatedAt` rendered ✅ | **Met** |
| `R-7` non-blocking | inline, no backdrop ✅ | **Met** |
| `§2.3` Escape does not ack | no handler ✅ | **Met** |

### 6.5 Mockup vs implementation discrepancies

| # | Mockup | Implementation | Which is right |
|---|---|---|---|
| 1 | Four title/lead pairs | One (M1 only) | **Mockup** — `§2.1` |
| 2 | Six live cells | `cells` empty | **Mockup** for five of them — `§2.3`; the sixth is **NQ-5** |
| 3 | Pill button gated `pct>=100 && !RUNNING` | always visible | **Mockup** — `S-13`/`B-11` |
| 4 | Pill note *acknowledged* / *target reached* | absent | **Mockup** — `§4.6` |
| 5 | Tick labels gain `hit` once passed | no styling | Mockup (cosmetic) |
| 6 | Full three-step dialog | none | **Mockup** — `§4` |
| 7 | `targetLb: 2000` | none | **Neither** — withdrawn by `D5` |
| 8 | `SP-00031` shown pre-commit | none | **Neither** — no alpha before commit (G-4) |
| 9 | Escape / backdrop dismiss the dialog | n/a | **Neither** — violates `S-10`/`B-9` |
| 10 | `.fwn-demo` jump bar | none | **Implementation** — must not ship |
| 11 | Card at `bottom:124px` clearing a bottom command bar | `bottom:50px` (`styles.scss:660`), left nav rail | **Implementation** — composition is not taken from the mockup (`F-15`); verify `R-10` against the traces card |
| 12 | Client-side tick and ladder | none | **Neither** — server-side (G-2) |

### 6.6 Open questions requiring clarification

**25** — 11 existing (`Q18`, `Q33`, `Q19`, `Q20`, `Q21/OI-35`, `Q42`, `Q44`, `Q46`, `OI-25`,
`OI-56/OI-38`, `OI-75`) and 14 new (`NQ-1`…`NQ-14`). Full text in §5.

**The three that gate the most work:** **NQ-11** (is Part A in scope at all?), **Q18** (the target),
**Q42** (carrier format — a hard gate on every commit).

### 6.7 Dependencies and blockers

| Blocker | Blocks | Note |
|---|---|---|
| **`Q18`** | A11, F1 · ⏸ releases **A4** | The ladder's denominator has no persisted source; `Q18` also decides whether M4 exists |
| **`Q33`** | all weight | *"The weight basis for every part of this document"* |
| **`[SIG §5.5]` unpublished** | all of EPIC A | A scope decision, not an omission |
| **`FW-202` stop edge / test `C2`** | B2, B3 | `TryMapLineState` returns `false` — the primary trigger does not exist |
| **`Q42`** | D1, D2 | A hard gate on every commit |
| **`FW-244`** | B19 | `PromptAnsweredBy` |
| **`OI-56/OI-38`** | EPIC C | If no scale exists, `§4.5` is largely inert |
| **`OI-25`** | F3, and `§3.1`'s *footage at spool start* | |
| **10-90 SOP** | F1, F3 | *Not in the repository* — must be obtained from Operations |
| **No FL1 completion-workflow screen** | B9, G3 | The document's own *"Known gap in the deliverables"* |

### 6.8 Recommended implementation sequence

**Phase 0 — settle before coding.** `NQ-11`, `Q18`, `Q42`, `NQ-4`, `NQ-9`, `NQ-10`. Record the new
findings: `Gaps.md` rows for G-3, G-4, G-7, G-8; `Questions.md` entries for `NQ-1`…`NQ-14`; correct
`FW-N02:178` (`payoffWeight$` → `footageCounter$`); correct `FR-137`'s withdrawn 2,000 lb in
`BusinessRequirements.md:417` and `MasterSpecification.md:735`; one `CHANGELOG.md` row.
⛔ Never edit `STATUS.md` — regenerate it.

**Phase 1 — corrections to what exists** (unblocked, small): A3 (M3 threshold **and removal of the
`Danger` branch**), G-5, G-6, G-9, G-12. Ships a correct, still-inert card.
⏸ **A4 is excluded** — held pending `Q18`.

**Phase 2 — Part B client contract.** Unblocked by `Q18`, because the operator answers on the
**latched weight**, not a percentage. ⚠ But `B2`/`B3` depend on the server edge, which is dark until
test `C2`; develop against `DELETE /sim/FL1/run`. Stories: B1, B4, B5, B10, B14, G1.

**Phase 3 — the dialog:** B6, B7, B8, B9, B11, B12, B15, B18 → EPIC C → EPIC D → B20, E1.
⚠ B9's destination is G3, which has no screen — agree the interim completion summary first.

**Phase 4 — Part A**, once `NQ-11` and `Q18` close: A12, A1, A2, A5, A6, A7, A9, A10, A13, A15.

**Phase 5 — Part C:** F1, F3, once the SOP and `OI-25` land.

Phases 1 and 2 are independent and can run in parallel. Phase 3 depends on 2. Phase 4 is independent
of 3 but shares the docked indicator, so sequence A9 after B13.

⚠ **Per `Flatwire-planning/CLAUDE.md` the Angular standards are mandatory and live in `UALUADEV`,
not here** — `CLAUDE.md`, `.claude/instructions/`, `.claude/commands/generate-tests.md` (14 absolute
rules), `.claude/code-review-guidelines/`. Run `/generate-tests` before any spec and
`/angular-review` before the PR. ⛔ `ng lint` passing is not evidence of compliance.

### 6.9 Recommended testing scenarios

**The UAT basis is `§7` — `A-1`…`A-10` and `B-1`…`B-22`, all 32.** Beyond them:

*Ladder boundaries (unit):* 0, 74.9, **75**, 89.9, **90**, 99.9, **100**, 100.5, **101**, 101.1 —
with `SCN-A4` on hold, **everything at or above 100 must assert `Success`**, and `Danger` must never
be emitted at any input. That is the G-3 regression in its held form. Ack M2 closes M1.
⏸ *Held until `Q18` releases A4:* the 100–101 band narrows to `Success`, `> 101` asserts `Danger`,
ack M3 also closes M4, and *ack M3 then exceed 101 % → no M4* (`§2.1`).

*State (unit):* a new spool re-arms from zero (`A-10`); navigating off FL1 and back resets the
acknowledged set; `toSpoolReading()` returns `null` when the target is null.

*Prompt (integration):* re-delivery of the same `runId` yields **one** dialog (`B-10`, idempotency);
event 12 from another terminal closes it (`§4.2`#14) — and see `NQ-13` for the mid-edit case;
`LatchedWeightLb: 0` is not presented as fact (`NQ-14`); `TargetLb: null` renders no percentage.

*Verification (integration):* `B-12`…`B-22` in full — specifically that a > 2 % variance **never**
disables commit (`D4`), and that a **422 `SUPERVISOR_AUTH_REQUIRED`** surfaces the override panel
rather than a generic error toast.

*Carrier:* unrecognised → refused with the field marked; a carrier already carrying material →
refused **naming the spool it holds** (`S-29`); commit blocked without one (`S-28`); a declined
prompt captures none (`S-30`).

*Layout:* `D3` — the worst case (over target, out of tolerance, override open, carrier invalid) must
fit **without scrolling** at 16:9; `R-10` — the card obscures neither the nav rail nor either trace
header.

*End-to-end on FL1*, against the shared instance **`DEV00164-001`** (⚠ not LocalDB — check-in spans
`united_db` in one `SqlTransaction` with no MSDTC):
```powershell
dotnet run --project FlatWire.API          # useMockData off
curl -X DELETE http://localhost:5000/sim/FL1/run    # the RUNNING -> STOPPED edge
```
`TC-171` 3 s stop against a 5 s dwell · `TC-172` weight latched at the stop timestamp · `TC-173`
refresh mid-prompt · `TC-175` the label follows the row · `TC-176` No → 200, nothing written ·
`TC-179` manual path with no prompt outstanding · `TC-182` variance beyond 2 % still commits.

**Closing the loop:** `python tools/build_status.py`, `tools/check_docs.py`, `tools/linkcheck.py`.
