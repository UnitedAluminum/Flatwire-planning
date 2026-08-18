# Flat Wire Processing — Rod Pre-Check-in (Payoff Staging) Specification

**Project:** Flat Wire Mill Implementation
**Applies to:** Flattening Line 1 (FL1) and Flattening Line 3 (FL3)
**Version:** 2.5
**Last Updated:** August 15, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** [Dashboard 2A — Rod Pre-Check-In](../../Frontend/Mockups/dashboard_2a_rod_precheckin.html)
**Requirement source:** SRS §4.2 (`PCI001`–`PCI008`), §4.18 partial re-check-in (`PRC001`–`PRC019`), welding (`WLD003`, `WLD005`, `WLD006`, `WLD010`, `WLD011`), traveler (`TRV002`, `TRV004`, `TRV009`)

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 11. |

Requirement identifiers `PCI001`–`PCI008`, `PRC###`, `WLD###` and `TRV###` are existing SRS references. Identifiers `PCI009`–`PCI017` and `PCI020`–`PCI022` are **new** requirements proposed by this document — the SRS presently has no requirement text covering removal of a staged rod, bay states, order resolution, sequence authorisation, weld quality, or the run weld list.

---

# 1. Introduction

## 1.1 Purpose

This document specifies the **Rod Pre-Check-in** function — the staging of the next rod bundle on an idle payoff position while the current bundle is still being drawn. It defines the station, its states, the data captured, the validations and authorisations applied, and the open items on which United Aluminum's confirmation is required.

## 1.2 Scope

**In scope:** identification and staging of a rod at a payoff position; visual inspection before unbanding; dimensional acceptance at staging; production-order resolution and line selection; planned-sequence notification and authorisation; marking the induction weld; removal of a staged rod from the payoff; the traveler queue presented at the station.

**Not in scope:** rod check-in and pass-schedule acknowledgement (covered by the Rod Check-in specification); PLC tag transmission; post-check-in rod checkout; WIP rejection processing; planning's allocation of rod to orders; the weld event record itself.

## 1.3 Applicability

| Line | Pre-check-in | Reason |
|---|---|---|
| **FL1** | Yes | Draws from a dual-position payoff; continuous feed depends on staging |
| **FL3** | Yes | Uses the same physical payoff as FL1 (see G21, Section 11) |
| **FL2** | **No** | No staging space at the line. FL2 is check-in only (`PCI002`) |

## 1.4 Priority

Pre-check-in is classified **Should**, not **Must**. Check-in does not depend on it — scanning an unstaged rod directly at the check-in station remains a valid and supported path. Pre-check-in earns its place by enabling continuous feed, not by gating any other function.

---

# 2. Process Context

## 2.1 The Variable Position Payoff

FL1 and FL3 draw rod from a **VPS — Variable Position Payoff**: dual position, eye-to-sky, rated **9,000 lb per position**. Continuous operation depends on alternating between the two positions.

## 2.2 The continuous-feed cycle

1. Payoff 1 is drawing. Remaining weight falls below **3,000 lb** — the station raises a *prepare weld* alert.
2. The next bundle is **pre-checked-in on Payoff 2** while Payoff 1 is still running.
3. The operator induction-welds the running rod's tail to the staged rod's head, and marks the weld in the system.
4. Payoff 1 reaches zero remaining; feed transitions to Payoff 2. **The line does not stop.**

Pre-check-in is step 2. It is what makes the weld possible.

## 2.3 Why inspection happens here and not at check-in

**Bundles are not unbanded until they are positioned at the payoff**, for safety and bundling integrity. The rod's surface is therefore first visible at the payoff — which is why visual inspection belongs to staging rather than to check-in.

## 2.4 Both positions are equal

Payoff 1 and Payoff 2 are **peers**. Either may be the running position and either may be the staged position; after every payoff transition the roles exchange. Payoff 1 is empty at the start of a campaign, after a rod checkout, once a run consumes its rod, and between orders. No behaviour in this specification treats one position as permanently "the running one".

---

# 3. Terminology — Four Distinct Events

The word *checkout* carries three meanings across the requirement set. This table is definitive.

| Event | Trigger | Production run | Footage | Pass schedule | PLC tags | Station |
|---|---|---|---|---|---|---|
| **Pre-check-in** (stage) | Rod positioned at a payoff, current rod still running | Not created | — | Not acknowledged | **Never pushed** | Pre-Check-In |
| **Pre-check-out** — unwelded | Staged rod removed before check-in | None | 0 | Nothing to void | **Nothing to clear** | Pre-Check-In |
| **Pre-check-out** — welded | Staged, welded rod removed under supervisor authorisation; rod to `HOLD` | None | 0 | Nothing to void | **Nothing to clear** | Pre-Check-In → WIP Rejection |
| **Check-in** | Wizard completed and pass schedule acknowledged | **Created** | 0 | **Acknowledged** | **Pushed** | Rod Check-in |
| **Checkout Mode A** | After acknowledgement, before any footage runs | Exists | 0 | Voided | Cleared | Rod Checkout |
| **Checkout Mode B** | Mid-run, supervisor approval | Exists | > 0 | Voided | Cleared after confirmed stop | Rod Checkout, via Pause |

**Pre-check-out is not Mode A.** Mode A presumes a check-in occurred: it voids an acknowledgement and clears machine tags. A pre-checked-in rod has neither. A consequence worth stating: because nothing has been transmitted to machine control, staging and un-staging require **no line-state gate** — an idle payoff position is not running, which is precisely why staging is safe to perform while the other position draws.

---

# 4. The Pre-Check-In Station

## 4.1 Bay states `[PROPOSED — PCI009]`

Each payoff position presents exactly one of four states.

| State | Meaning | Available actions |
|---|---|---|
| **Not Staged** | Position empty | Pre-check-in a rod · (when the whole station is empty, also a direct route to check-in) |
| **Pre-Checked-In** | Rod staged, inspection passed, not yet checked in | Proceed to check-in · Mark as welded · Pre-check-out |
| **Active** | Rod checked in, run open | Check out the rod · Welds this run |
| **Blocked** | Rod staged but visual inspection failed | **WIP Rejection only** — no other forward action |

**Every action sits on the position it acts on** (revised August 1, 2026). *Mark as welded* is offered on the **staged** position because that position is the incoming rod; *Welds this run* is offered on the **running** position because the run belongs to it. Neither is a station-level control any longer.

**"Open the active run" is withdrawn as a position action.** The active run screen remains reachable from the application bar and from the Line Status board; the pre-check-in station's purpose is preparing the *next* rod, not driving the current one.

**Recommended next action.** Where a position has an obvious next step it is shown as the emphasised action — *Pre-check-in a rod* on an empty position, *Proceed to check-in* on a staged one. **The running position emphasises nothing**: both of its actions are exceptional, and emphasising either would read as a recommendation to take it.

**Blocked is a derived condition**, not a separate record state: a rod is blocked when it is staged and any inspection item has failed. The rod remains physically on the payoff and the position remains occupied — this is deliberate, because a bundle that fails inspection is already at the payoff and must not be reported as an empty position.

## 4.2 Capacity `[CONFIRMED — PCI010]`

One rod per payoff position; **two rods maximum per line**, one on each position. Bundles are **not stacked** on a position (confirmed July 30, 2026).

### 4.2a FL1 and FL3 share one physical station `[CONFIRMED — 15 Aug 2026]`

**FL1 and FL3 are two routes over one Variable Position Payoff, not two payoffs.** The station is **`FL1PO`**; there is no `FL3PO`, and its absence from the WIP-station registry is deliberate. So *"two rods maximum"* is a limit on the **physical station**, not per line name — a rod staged "on FL1" and a rod staged "on FL3" would be competing for the same two positions.

**Two consequences for this screen:**

1. ⚠ **Switching the line must reload, not relabel.** The toggle currently changes the badge, station stamp, queue heading and modal subtitle **without reloading the bays or the Traveler Queue**. Because the off-schedule check reads the *current* line, toggling **silently reclassifies rod that is already staged**, with nothing on screen changing. **It must reload both.** Story **`FW-209`**.
2. The station **switches line by itself** when a rod's order is booked on the other rod line — no message, no override (`Q24`). The operator is not asked, so the displayed line is not a setting they own.

*Both come from gap `G21`, resolved 15 Aug 2026. `RodStaging` now carries a persisted `Station` and its uniqueness index is keyed on it, so the database can no longer admit two rods to one physical bay — but the index cannot fix the toggle, which is why `FW-209` exists.*

## 4.3 Cold start — no material on either payoff

At the beginning of a campaign the line holds no material and the station knows of no production order. Both of the following routes are valid and the station offers both:

1. **Directly to check-in.** Nothing is drawing, so there is nothing to weld to and staging achieves nothing. Scan the first rod at check-in, acknowledge the pass schedule, tags are pushed, the run starts. **This is the normal cold-start path.**
2. **Stage first, then check in.** Useful only when the bundle is physically positioned before the operator is ready to start the run.

With both positions free the wizard offers **both** — a position is offered or withheld according to whether it is *occupied*, never according to which position it is. Both positions read *"No material on this line"* and state the two routes above.

**Neither weld control is available at cold start**, and they are unavailable in different ways. *Mark as welded* requires a staged rod, so there is no position to offer it on. *Welds this run* is offered on the **running** position, and at cold start there is none — so **the control is not present at all**, rather than present and unavailable. This is a change from the earlier design, in which a station-level control was shown greyed with the explanation *"no run in progress"*; **please confirm this is acceptable** (open item **OI-108**).

## 4.4 Payoff weight indication and weld alerts

| Condition | Indication |
|---|---|
| Remaining weight below **3,000 lb** | Warning — *prepare weld* |
| Payoff 2 not staged **and** Payoff 1 below **2,000 lb** | Critical — continuous feed is at risk |

Colour is driven by **absolute remaining pounds**, not by percentage bands. Against a 9,000 lb position, a percentage ladder would escalate later than the alerts it is meant to reinforce — the strongest visual cue would arrive after the urgency had passed. Bar *length* still expresses percentage remaining; only its colour is threshold-driven.

> `[CLIENT INPUT REQUIRED]` The received bundle **gross weight** is stated inconsistently across earlier documents. Both the weight bar and the alert thresholds above are calibrated to it (OI-97, Section 11).

## 4.5 Traveler queue `[TRV004, TRV009]`

The station presents a queue of rod for the current order, headed **"Rods In Queue"** and showing serial number, payoff position, dimensional attributes and current status, and including **both pre-checked-in and welded rods**.

| Row type | Meaning |
|---|---|
| **Pre-Checked-In** | Staged at a payoff, not yet checked in |
| **Welded** | Staged and welded to the running rod |
| **Available** | Allocated to the current order by planning and not yet consumed |

Additional queue behaviour:

- An **order context header** states the line, order number, material specification and progress (*n* staged · *n* available · *n* on order). Alloy and temper are therefore not repeated on every row.
- Every row shows **footage already run**, so a partial rod is visible *before* it is staged rather than discovered during the scan.
- Two sequence columns are shown — **Plan** and **Run** (Section 6.3).
- **Rod storage location is deliberately not shown.** It is not a traveler field, and a location that is not updated when a bundle is physically moved is worse than no location on a screen whose purpose is "fetch the next bundle". This can be reconsidered if rod storage becomes system-tracked.

The **Available** set is read live from planning at the moment of request; flat wire does not maintain its own copy of it. A practical consequence for United Aluminum: when a planner re-allocates a rod, reschedules an order, or places material on hold, the station reflects that at the next refresh — there is no separate flat-wire list to keep in step, and no risk of an operator fetching a 9,000 lb bundle against a stale entry.

---

# 5. Establishing the Production Order

## 5.1 The rod reveals the order `[PROPOSED — PCI011]`

The order is **not selected by the operator**. Planning allocates rod to orders, and the station resolves that allocation when the rod is scanned. While a line is idle it displays no order, the queue is empty, and both positions invite either route; the first rod scanned *reveals* the order planning already assigned.

| Lookup outcome | Behaviour |
|---|---|
| No planning allocation for the rod | **Refused.** Planning must allocate the rod first |
| Order matches the established order | Proceed normally |
| Order is scheduled on the **other flattening line** | **The station switches to that line automatically** — see 5.2 |
| Order differs from the established order | Refused — see the qualification in 5.3 |

Un-staging the last rod on an idle line returns the station to its cold-start condition and **clears the displayed order**.

## 5.2 Automatic line selection `[CONFIRMED — PCI012]`

**A rod planned for the other line is a navigation matter, not an operator deviation.** If a rod planned for FL3 is scanned while the operator is on the FL1 view, the station **switches to FL3** and the transaction continues — with no blocking message, no supervisor override and no exception record. The same behaviour applies at check-in.

The reasoning is that the operator is not departing from anything: the rod is being run exactly where planning placed it, and the only thing incorrect was which view was on screen.

> `[CLIENT INPUT REQUIRED]` Two consequences require your input:
> 1. **A part-completed transaction.** Automatic switching moves the operator between lines mid-wizard; the required treatment of partially entered data must be confirmed (Section 11, OI-26/G21).
> 2. **A rod scheduled on neither flattening line** — an unscheduled job, a trial, or a rush piece run before planning catches up. There is no line to switch to (Section 11, Q25).

## 5.3 Order membership — qualified

Staging currently refuses a rod belonging to an order other than the established one, on the grounds that welding across unrelated orders breaks coil genealogy.

> `[CLIENT INPUT REQUIRED]` United Aluminum confirmed on July 30, 2026 that **a single rod may carry more than one production order** — completing one order on part of a 7,000 lb bundle and beginning the next on the remainder, same alloy, sized by planning in multiples of the outgoing coil weight. Where the second order begins part-way down the *same* bundle there is no weld and nothing to refuse; the rod simply continues running.
>
> The refusal above therefore remains correct only for two **genuinely different** rods carrying unrelated orders. The replacement rule depends on the sequencing answer still owed (Q73, Section 11) and this rule is deliberately unchanged until that arrives.

---

# 6. Staging Rules

## 6.1 Validations, authorisation and automatic correction

| Type | Rule | Outcome if not satisfied |
|---|---|---|
| Validation | The rod has a planning allocation | **Refused** |
| Validation | The rod is available — not already in flattening, complete, on hold, scrapped, or staged elsewhere | **Refused** |
| Validation | The rod belongs to the established order | **Refused** (qualified by 5.3) |
| **Correction** | The rod's order is scheduled on this line | **The station switches to the correct line automatically** |
| **Authorisation** | The rod is the one planning expects next | **Supervisor authorisation** — never a refusal |

## 6.2 Planned sequence — notify and authorise `[CONFIRMED — PCI013]`

**The planned rod sequence is authorised, not enforced.** Rods are planned in a defined order. The floor may legitimately depart from it — but that departure is **not the operator's unilateral decision**: the operator is told which rod planning expects next, and a **supervisor authorises** running a different one. It is never a hard refusal.

- **"Expects next" is the lowest planned sequence still available.** A rod already staged, welded or blocked is no longer a candidate, so a failed bundle does not freeze the sequence behind it.
- On a line where nothing has yet been processed, planned #1 is expected — staging #3 first is a deviation even as the very first rod.
- Authorisation captures a **reason** and the **supervisor's badge/ID and PIN**, with a remote-approval fallback. The PIN is not stored.
- The queue marks the expected rod so the operator can see which choice needs no authorisation, and the bay continues to display *"Authorised by …"* for as long as the rod is on the payoff, including after check-in.

> `[PROPOSED — confirm at review]` United Aluminum asked on July 30, 2026 that this override be left in place pending a further review of the specification it may support. It is built as described; please confirm or amend it at this review.

## 6.3 Two sequences are retained

| | **Planned sequence** | **Actual (run) sequence** |
|---|---|---|
| Meaning | The order planning intended | The order in which the rod was actually staged |
| Assigned | At planning | At pre-check-in, by the system |
| On an unprocessed rod | Present | Not yet assigned |
| Purpose | Planning and reporting | Transaction history and traceability |
| May change | By planning | Never |

The planned value is **captured at staging** rather than re-read later — the same approach already used for the pass schedule, whose identity and version are copied onto the run record. Variance is then a simple subtraction, and a traceability enquiry years afterwards never has to consult current planning data to answer "was this run in planned order?"

The station shows both as **Plan** and **Run**, with a neutral marker where they differ. The neutrality is deliberate: processing out of planned order is an authorised operational choice, and an amber or red treatment would read as an error.

## 6.4 Weld sequencing is a separate matter

`PCI008` requires pre-checked-in material to be surfaced automatically during weld selection "to enforce sequencing". This refers to **physical weld sequencing** — the weld defaults to whichever rod is actually staged on the idle position, and the operator may override by scanning. It does **not** refer to the planned processing order of Section 6.2.

---

# 7. Pre-Check-In Procedure

Three steps.

## Step 1 — Identify the rod `[PCI004, PCI005]`

Scan or key the rod serial, validated against the R-series in the coil master. A rod already checked in elsewhere is rejected. The measured **diameter** is validated against the alloy's dimensional limits.

### Dimensional limits `[CLIENT INPUT REQUIRED]`

United Aluminum confirmed on July 30, 2026 that **upper and lower limits exist for four attributes — gauge (height), width, diameter and ovality** — held as reference data and applied at **both pre-check-in and check-in**.

**The values themselves are owed.** Until they are supplied, no limits are seeded, and any figures shown on the mockup are visibly provisional. This is Q22 in Section 11 and it is required before the station can accept or reject a measurement.

## Step 2 — Assign the payoff position `[PCI006]`

Two options are presented. An occupied position is unavailable and is labelled with its current occupant. Neither position is preferred over the other.

## Step 3 — Visual inspection before unbanding `[CHK010]`

**Three items:** oxidation · surface defects · water stains.

**A failed inspection is a hard block with no bypass.** The only forward action is WIP Rejection.

## Blocked bay release `[CONFIRMED — PCI014]`

A rod that fails inspection remains recorded at the payoff and the position shows **Blocked**. The WIP rejection captures the reason and places the rod on **`HOLD`** — and that is what **releases the record and frees the position**. There is no other release path, and the position is never reported as empty while the bundle is physically on it.

The rejection is captured **at this station**, without leaving it: the operator does not navigate away to a separate screen and then find their way back. The station knows which rod and which position failed, so the rejection opens already describing them, and because the rod never ran there is **no run and no footage position** to record against it — the two facts a mid-run rejection carries and this one cannot.

## Partial rod carry-forward `[PRC007, PRC008, PRC011, PRC014]`

If the rod has footage already run, the wizard presents the prior run history and offers **only** *proceed as a partial re-check-in*, together with an explicit confirmation of physical identity. **A fresh-start path is not offered and is not present on the screen.**

Applying this gate at the staging scan is deliberate: staging is where the rod is first identified, so a partial rod is recognised before it is mounted rather than during check-in.

---

# 8. Marking the Weld `[WLD010]`

**Offered on the staged payoff position** (revised August 1, 2026 — it was previously a station-level action in a weld readiness band beneath both positions). The staged position *is* the incoming rod, so the action carries that rod into the record without the operator selecting it.

Available **only when a rod is pre-checked-in on that position** and a rod is running on the other.

**Which rod is outgoing and which is incoming is determined from the line, not from the position the operator pressed.** After a payoff transition the running rod may sit on either position, so the record always takes the outgoing rod from whichever position is actually running.

When the action is unavailable, **the station states why** rather than simply withholding it:

| Situation | Explanation shown |
|---|---|
| Nothing running | "No rod is running — there is nothing to weld to" |
| The other position failed inspection | "No rod is running — the other position failed inspection" |
| Both positions staged, none running | "No rod is running — check in the other position to start the line" |
| Already welded | "Already marked as welded" |
| Previous attempt failed | "Remake the failed weld" *(available)* |

- Captures the operator and timestamp `[WLD003]`.
- Validates that **alloy, temper and diameter match the running rod** `[WLD006]`.
- Captures the **weld quality result** — see 8.1 `[PCI022]`.
- **Records the physical weld only — it does not switch payoff positions.** Per `WLD005` the payoff transition is driven solely by material consumption reaching zero remaining.

**No separate status exists for a rod that is welded but not yet checked in** (confirmed July 30, 2026). Welded is an attribute of a staged rod.

The operator is **not** asked to key a badge number to record the weld. The operator is already established by the signed-in station session, and re-collecting it here allowed the keyed value to disagree with the session actually stamped on the record. `WLD003` requires the operator to be *recorded*, not *re-entered*.

> `[CLIENT INPUT REQUIRED]` Reversing a weld **in place** — on a rod that stays staged, following a mis-scan or the wrong rod being welded — is not yet specified. Releasing a welded rod from the payoff *is* specified (Section 9); correcting the record of a weld that already passed is not. *(A weld that fails its own quality check is different and is specified in 8.1 — it never marks the rod welded in the first place.)*

## 8.1 Weld quality `[PROPOSED — PCI022]`

Recording a weld **requires a quality result**. This is the same check, with the same options, as the Weld Event screen — so a weld is recorded identically wherever it is captured.

| Aspect | Rule |
|---|---|
| Result | **Pass** or **Fail**. Mandatory — the weld cannot be confirmed until one is chosen, and **neither is pre-selected**. |
| Fail reason | **Required whenever the result is Fail** `[WLD013]`, chosen from: misalignment at join · weld break on inspection · surface burn / scorching · weld not fully fused · diameter mismatch at join · other (see observation). |
| A **passing** weld | Marks the rod as welded. Feed transitions to it when the running rod reaches zero remaining. |
| A **failing** weld | **Is recorded, but does not mark the rod welded.** The join did not hold, so the rod is not joined to the running rod and the line cannot run through it. The position keeps reading *not yet welded*, the station states that the last weld failed and why, and the operator **remakes the weld**. |
| Repeat attempts | Each attempt is recorded. A failed weld followed by a successful remake is **two records** of the same physical join — see Open Item on traceability. |

**Why the quality result is mandatory here.** Previously the station recorded only *that* a weld had happened, with no statement of whether it held — a weld asserted to exist, backing footage that goes onto a customer certificate, with nothing recorded about its integrity. The same weld captured on the Weld Event screen *did* record a quality result, so the same physical join was documented two different ways depending on which screen the operator happened to use. One weld now produces one record.

> `[CLIENT INPUT REQUIRED]` A failed weld is recorded and remade, so one physical join can carry more than one record. Whether a superseded failed attempt should appear on a customer certificate, or be excluded as an abandoned attempt, is not yet decided. Listed in Section 11.

## 8.2 Welds recorded against the current run `[PROPOSED — PCI021]`

The station provides a **read-only list of the welds already recorded against the run in progress**, opened from the **running payoff position** and closed without any further action. It sits there because the run belongs to that position; the count of welds so far is shown on the control itself.

| Aspect | Rule |
|---|---|
| Scope | The **current run only** — every weld recorded against the run now on the line. Not the shift, and not the output coil. |
| Shown per weld | Time · outgoing rod → incoming rod · footage position at the weld · weld type · operator · quality result. |
| Failed welds | A failed weld is listed with its **failure reason**, which is mandatory whenever quality is Fail `[WLD013]`. |
| Availability | Available whenever a run is in progress, including while the idle position is empty or blocked. **Before the first check-in there is no running position, so the control is not present** — it is not shown-and-greyed. See 4.3 and open item **OI-108**. |
| No welds yet | The control remains available and reports "none recorded yet". A run with no welds is a legitimate answer, not an error. |
| Editing | **None.** The list is read-only; a recorded weld cannot be corrected or reversed from it (see the open item above on `WLD011`). |

**Why this exists.** The screen previously offered a control labelled *Weld event log* that navigated away to the weld-recording form — it recorded a new weld rather than showing the welds already recorded. Nothing anywhere in the system listed the welds made during a run, although each one is a traceability input for the customer certificate. This replaces that control with the list its label promised.

---

# 9. Removing a Staged Rod (Pre-Check-Out)

Approval depends on whether the rod has been welded.

| Case | Authorisation | Reason | Resulting rod status |
|---|---|---|---|
| **Unwelded** `[CONFIRMED — PCI015]` | **Operator** | Captured | Returned to available |
| **Welded** `[CONFIRMED — PCI016]` | **Supervisor override** | Captured, mandatory | **`HOLD`** — routed to WIP Rejection |

The distinction is physical rather than procedural: removing a welded rod means **cutting or splitting the material**, so it is a rejection rather than a return to inventory.

In both cases: no production run exists, footage is zero, no pass-schedule acknowledgement is voided and no machine tags are cleared.

> `[PROPOSED]` The SRS covers removal only *after* check-in. `PCI015` and `PCI016` are new requirement text, offered here for confirmation and addition to the requirement set.

---

# 10. Confirmed Decisions

Recorded from the client call of **July 30, 2026**. Please confirm that each is captured correctly.

| # | Decision | Effect |
|---|---|---|
| D1 | **The shared coil status is set at check-in, not at staging.** Pre-check-in does not commit the shared status; `INFLAT` is applied when the rod is actually checked in. Rod status `STAGED` is the real staging status. | Section 3, `PCI017` |
| D2 | **Pre-check-out approval depends on the weld.** Unwelded is operator-only; welded requires a supervisor, a documented reason, and `HOLD`. | Section 9 |
| D3 | **A failed inspection is captured as a rejection with a reason, and the rod goes to `HOLD`** — that is what releases the blocked position. | Section 7 |
| D4 | **Off-schedule staging is an automatic line switch**, not a deviation — no message, no override, at both pre-check-in and check-in. | Section 5.2 |
| D5 | **Dimensional limits are min/max for four attributes** — gauge, width, diameter, ovality — in reference data, applied at both stations. Values to follow. | Section 7 |
| D6 | **A rod may carry more than one production order**, sized in planning in multiples of the outgoing coil weight. | Section 5.3 |
| D7 | **Bundles are never stacked** — two rods maximum, one per payoff, as on the mills. | Section 4.2 |
| D8 | **No separate status** is required for a rod that is welded but not yet checked in. | Section 8 |

**One residual on D1.** The decision covers the **status** only. Whether pre-check-in still performs the associated queue insert, requirement summary and work-in-process order entry — or whether those also move to check-in — is not yet answered. If they move, removing a staged rod becomes a purely local operation.

---

# 11. Open Items Requiring Client Input

Each item below blocks or qualifies part of this specification. They are drawn from the project's open-questions register and retain its numbering.

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **Q22** | High | **The min/max values** for gauge, width, diameter and ovality per alloy. The shape is agreed; the numbers are owed by e-mail. | Dimensional acceptance at both stations. Nothing is seeded until supplied |
| **G21** | High | **Are FL1 and FL3 one station or two?** If they share one physical payoff, the "one rod per position" rule must be scoped across both lines, otherwise two rods can be staged on one physical position. | The staging data model |
| **Q25** | High | **May a rod run when its order is scheduled on neither flattening line?** Automatic line selection has no line to switch to. If an authorisation is required, one must be added. | Automatic line selection (5.2) |
| **OI-97** | High | **The actual received bundle gross weight.** The payoff weight bar and both weld alerts are calibrated to it, and earlier documents state it two incompatible ways. | Weight indication and weld alerting (4.4) |
| **OI-108** | Medium | **At cold start, should *Welds this run* be absent or shown-and-unavailable?** Now that it sits on the running payoff position, there is no position to show it on before the first check-in, so it is simply not there. The previous station-level control was shown greyed with the explanation *"no run in progress"*. Absent is the honest representation of "there is no run"; visible-but-greyed teaches the operator where the control will be. | Cold start (4.3) and the run weld list (8.2) |
| **OI-59** | Medium | **A failed weld is recorded and then remade, so one physical join carries more than one record.** Should a superseded attempt appear on the customer certificate as part of the material's history, or be excluded as an abandoned attempt? *(Widened Aug 1, 2026 — this question already covered a weld that breaks mid-run; a weld that fails its quality check before anything runs through the join may deserve a different answer.)* | Certificate traceability across a remade weld (8.1) |
| **Q73** | Medium | **Sequencing across a multi-order rod.** If a rod straddling two orders is staged out of planned order, is that the standard supervisor authorisation, or something stricter? Also: is this in the first release or a later phase? | The order-membership rule (5.3), which is knowingly unfinished until this closes |
| **OI-26** | Medium | **The station for FL3**, and what automatic line selection does to a part-completed wizard. | Automatic line selection (5.2) |
| **OI-72** | Medium | **Is the actual run sequence numbered per line, per order, or globally?** | Traceability reporting |
| **Q12** | High | **Is a payoff-side scale available for weighing remnants?** | Partial rod carry-forward |
| — | Medium | **The weld reversal case** — correcting the weld flag on a rod that remains staged (Section 8). | Weld correction |
| — | Medium | **Confirmation of the out-of-sequence authorisation** left in place pending your review (6.2). | Section 6.2 as built |
| — | Low | **Is rod storage location tracked in a system?** If it is, a location column may be reintroduced to the queue. | Queue content (4.5) |

---

# 12. Assumptions

| # | Assumption |
|---|---|
| A1 | The VPS is dual-position, eye-to-sky, rated 9,000 lb per position, and FL1 and FL3 share one physical unit (subject to G21). |
| A2 | Rod is allocated to a production order by planning, before it reaches the payoff. The station reads that allocation; it never creates it. |
| A3 | Bundles are unbanded only once positioned at the payoff, which is why inspection is a staging function. |
| A4 | Welding rod to rod is by induction. Removing a welded rod requires cutting the material. |
| A5 | Rod availability is read live from planning and scheduling at the time of request; no flat-wire copy is held. |
| A6 | Supervisor authorisation uses the same credential mechanism as other flat wire supervisor approvals, with a remote-approval fallback. The PIN is not stored. |
| A7 | Pre-check-in never transmits anything to machine control. Tags are pushed only on pass-schedule acknowledgement at check-in. |

---

# 13. Related Specifications

| Document | Relationship |
|---|---|
| [Rod Check-in](RocCheckin.md) | The step immediately after staging — acknowledgement, run creation, tag push |
| [Rod Checkout](RodCheckout.md) | Mode A / Mode B removal *after* check-in |
| [Weld Event](WeldEvent.md) | The weld this staging exists to enable |
| [WIP Rejection](WipRejection.md) | The only exit from a blocked bay — it releases the payoff (§7) |
| [Active Run Monitor](ActiveRunMonitor.md) | The run the staged rod is welded into |
| [Line Status Overview](LineStatusOverview.md) | Shows the payoff 2 state this station sets |
| [Rod Checkout](RodCheckout.md) §7.2 | Why partial material takes its own identity, linked back to the rod |

---

# Client Sign-off

Please review each item and mark accordingly. Items marked *Amend* should carry a note.

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §4.1 | Four bay states, with Blocked derived from a failed inspection | ☐ | ☐ |
| §4.4 | Absolute-weight alert thresholds — 3,000 lb warn, 2,000 lb critical | ☐ | ☐ |
| §4.5 | Traveler queue content, including omission of rod storage location | ☐ | ☐ |
| §5.1 | The order is resolved from the rod's planning allocation, never chosen by the operator | ☐ | ☐ |
| §5.2 | Automatic line selection with no message and no override | ☐ | ☐ |
| §6.2 | Planned sequence is notified and supervisor-authorised, never refused | ☐ | ☐ |
| §7 | Three inspection items, hard block, WIP Rejection the only forward action | ☐ | ☐ |
| §7 | Partial rod: carry-forward only, no fresh-start path | ☐ | ☐ |
| §8 | Mark-as-welded records the weld only; the payoff transition is consumption-driven | ☐ | ☐ |
| §9 | Pre-check-out: operator for unwelded, supervisor and `HOLD` for welded | ☐ | ☐ |
| §10 | The eight decisions of July 30, 2026 are correctly captured | ☐ | ☐ |
| — | New requirements `PCI009`–`PCI017` and `PCI020`–`PCI022` to be added to the requirement set | ☐ | ☐ |
| 8.1 | Weld quality (Pass/Fail) is **mandatory** to record a weld, with a reason required on Fail (`PCI022`) | ☐ | ☐ |
| 8.1 | A **failed weld does not mark the rod welded** — it is recorded, and the weld must be remade | ☐ | ☐ |
| 8.2 | Read-only list of welds recorded against the current run, scoped to the run (`PCI021`) | ☐ | ☐ |
| §4.1 | **Every action sits on the payoff position it acts on** — *Mark as welded* on the staged position, *Welds this run* on the running position; neither is a station-level control | ☐ | ☐ |
| §4.1 | **"Open the active run" is withdrawn** as a payoff-position action; the run screen stays reachable from the application bar and Line Status | ☐ | ☐ |
| §4.1 | The running position **emphasises no action**, because both of its actions are exceptional | ☐ | ☐ |
| §8 | When *Mark as welded* is unavailable, the station **states why** | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| Q22 | Min/max values — gauge, width, diameter, ovality, by alloy | | ☐ |
| G21 | FL1 / FL3 — one physical station or two | | ☐ |
| Q25 | Rod scheduled on neither flattening line | | ☐ |
| OI-97 | Received bundle gross weight | | ☐ |
| OI-108 | *Welds this run* at cold start — absent, or shown and unavailable | | ☐ |
| Q73 | Sequencing across a multi-order rod, and its release scope | | ☐ |
| OI-26 | FL3 station, and the part-completed wizard on automatic switch | | ☐ |
| OI-72 | Scope of the actual run sequence number | | ☐ |
| Q12 | Payoff-side scale for remnants | | ☐ |
| — | Weld reversal in place | | ☐ |
| — | Rod storage location tracking | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Process Engineering** | | | |
| **IT** | | | |
| 2.4 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
