# Flat Wire Processing — Spool Completion Specification

**Weight milestone alerts · machine-stop confirmation · short close**

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 (spool at the intermediate take-up) · FL2 / FL3 (finished coil at the final take-up)
**Version:** 2.3
**Last Updated:** August 25, 2026 — worked examples cited *(previously August 20, 2026)*
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 3 — Active Run Monitor (all lines)

---

> **Worked numeric traces for the order dimension.** [`RodOrderAllocation_WorkedExamples.md`](../../95-archive/design-notes/RodOrderAllocation_WorkedExamples.md) carries seven end-to-end traces covering {1 order, 1 rod} × {1 order, n rods} × {n orders, n rods}, welded and not, with every footage and weight reconciled. It is **rationale, not a requirement** — the requirements are `[REQ §5.28]`, `FR-541`–`FR-560`. Its client-facing twin is the `.html` of the same name. ⚠ Its §9 is gap **`G48`** made concrete and its §12 raised **`G52`** and **`OI-127`**; the 4,000 lb rod every count scales from is still open as `OI-97`.

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 10. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

Three related behaviours around the completion of a spool or a finished coil:

| Part | Covers | Blocking? |
|---|---|---|
| **A — Milestone alerts** | Advisory notifications at **75 / 90 / 100 %** of target weight while the line runs | **Non-blocking** — informational, acknowledge only |
| **B — Stop confirmation** | After target is reached and the operator **physically stops the machine**, a machine-confirmed prompt asking whether the stop was to remove the completed spool | **A decision** — but the machine is already stopped, so nothing is interrupted |
| **C — Short close** | Closing a spool **below** target — order satisfied, rod exhausted, quality problem, end of campaign | Handled as an unplanned stop |

Part A tells the operator the spool is filling. Part B catches the moment it is actually finished and turns the physical act of stopping into the system transaction, so a completion is never missed or entered twice. Part C covers everything that ends early.

## 1.2 Scope

**In scope:** milestone evaluation and notification; the weight basis and its derivation; the stop-confirmation gate and its conditions; scale-weight verification and variance handling; short close and its grading; and the audit record produced by each.

**Not in scope:** the spool completion workflow itself — identity finalisation, per-spool SPC and label content; planning consumption of the completed spool; the FL2 coil completion screen.

## 1.3 Applicability

- **FL1 standalone** — the take-up produces an intermediate **spool**. This is the primary case described here.
- **FL2 / FL3** — the take-up produces a finished **coreless coil**. The same ladder applies against the coil target, with wording changed from spool to coil.

## 1.4 Standing constraint

**This function never stops, slows, gates or commands the machine.** It is advisory and transactional only, consistent with the standing rule that the application is a gatekeeper and not a remote stop controller.

---

# 2. Part A — Weight Milestone Alerts

## 2.1 The ladder

| # | Trigger | Character | Content | On acknowledgement |
|---|---|---|---|---|
| **M1** | Weight ≥ **75 %** of target | Informational | Current processed weight, target, percent complete | Dismiss; arm M2 |
| **M2** | Weight ≥ **90 %** of target | Caution | Adds remaining weight | Dismiss; arm M3 |
| **M3** | Weight ≥ **100 %** of target | Target reached | Weight at or over target; ready to close | Dismiss; ladder ends |
| **M4** `[PROPOSED]` | Weight > **101 %** of target **and M3 not yet acknowledged** | Over target | Over target by *n* lb; the take-up should be stopped and the spool closed | Dismiss |

**M4 is a design addition, not part of the recorded requirement.** An unacknowledged M3 keeps updating and will therefore run past 100 %; a notification silently reading "104 % of target" in a *target reached* style understates the situation. The 1 % margin exists so the state cannot flicker the instant target is touched. Please confirm whether it is wanted (Q18).

## 2.2 Behaviour rules

| ID | Rule |
|---|---|
| **R-1** | The notification is raised automatically. No operator action initiates it. |
| **R-2** | It always displays the **current actual processed weight**, with target and percent complete alongside for context. |
| **R-3** | The operator may acknowledge it; acknowledging dismisses it. |
| **R-4** | Acknowledging a milestone **arms the next one**. Acknowledging also closes every milestone below it, so an operator who acknowledges a card that escalated straight to 90 % is not then shown the 75 % card. |
| **R-5** | An unacknowledged notification stays visible and **keeps updating with live production data** — weight, percent, remaining, fill rate and estimated time to target. |
| **R-6** | An unacknowledged notification is **superseded in place** when the next milestone is reached — it escalates rather than stacking a second notification. The operator never faces a queue of stale weight alerts. |
| **R-7** | It is **non-blocking**: no modal, no backdrop, no focus trap. Every control on the active run screen stays operable while it is displayed. |
| **R-8** | It must not interrupt, slow, gate or command machine operation. |
| **R-9** | Milestone state is **per spool**. When a spool closes and a new one starts on the same run, weight restarts from zero and all milestones re-arm. |
| **R-10** | It must not obscure the command bar or either trace panel's header and live reading. After acknowledgement a compact progress indicator remains, so the operator keeps passive visibility without a second alert. |
| **R-11** | Acknowledgement is an **audited event** — operator, milestone, weight at acknowledgement, timestamp, recorded against the run. |
| **R-12** | The thresholds are **configuration, not constants** — tunable by Operations without a software release. |

## 2.3 Presentation requirements

| Aspect | Requirement |
|---|---|
| Placement | A fixed card in a screen corner, above the command bar. No overlay, no backdrop |
| Primary reading | The **actual processed weight**, large, with the target beneath it |
| Progress | A bar showing percent of target, marked at 75 / 90 / 100 so the operator sees where the current milestone sits |
| Live secondary data | Percent, remaining, spool footage, fill rate, estimated time to target, and a visible "last updated" indication |
| Action | A single **Acknowledge** control. Nothing else is offered; the operator's real work is on the screen behind it |
| Escalation | The card changes in place, never as a second card |
| After acknowledgement | Collapses to a small docked indicator showing live progress; re-expands at the next milestone |
| Accessibility | Announced without interrupting; dismissal must be deliberate — pressing Escape does not acknowledge |

---

# 3. The Weight Basis

## 3.1 Actual processed weight

Weight wound onto the current take-up since the spool started, derived from the live footage counter and the measured cross-section:

```
lb per ft     = gauge (in) × width (in) × 12 (in/ft) × alloy density (lb/in³)
spool weight  = (current footage − footage at spool start) × lb per ft
```

Worked example — alloy 1100 at 0.098 lb/in³, gauge 0.110″, width 0.625″:

```
0.110 × 0.625 × 12 × 0.098 = 0.0809 lb/ft
    900 lb  ≈ 11,130 ft   (customer maximum)
  1,800 lb  ≈ 22,250 ft   (a spool yielding two finished coils)
```

**FL2 caveat.** FL2 standalone does not broadcast live gauge and width — its trace is historical. Its weight factor must therefore use the pass-schedule or order gauge and width, not a live measurement.

## 3.2 Target weight `[CONFIRMED — July 30, 2026]`

**The basis is the customer's weight range.** The customer specifies a **minimum and a maximum** weight (figures given on the call: 900 lb maximum, 800 lb minimum) and completion is graded against that range, **by weight** — not by footage, and not against an assumed default.

| Source | Value | Role |
|---|---|---|
| **Order — customer minimum/maximum** | e.g. 800–900 lb | **The basis.** Completion is graded against it |
| Spool sizing | ~1,800 lb | Sized so **two finished coils** can be cut from one spool at FL2 |
| Intermediate take-up capacity | 3,500 lb | Hard equipment ceiling |
| Final take-up capacity | 1,100 lb | Finished-coil ceiling. The customer maximum is normally below it, so the customer value governs |

> **The previously assumed 2,000 lb default is withdrawn.** It had no basis and exceeded the finished-coil ceiling.

> `[CLIENT INPUT REQUIRED]` **Which order field carries the customer minimum and maximum** is not yet identified (Q18). The formula also depends on the outstanding conversion between spool outside diameter and weight (Q33); until that closes, footage × cross-section × density is the working basis.

## 3.3 A derivation is not a measurement

`footage × gauge × width × 12 × density` inherits every error in its inputs — counter slip, gauge and width drift between checkpoints, and an assumed alloy density. **The physical scale is the only ground truth available at the take-up**, so the completion step must be able to capture it and must never quietly commit a derived number when a measured one exists.

This is also how the outstanding weight-formula question eventually answers itself: accumulate scale-versus-calculated variances and both the density factor and the diameter formula can be validated against real production data.

---

# 4. Part B — Confirmation After the Machine Stops

## 4.1 The requirement

Once the target weight is reached and the operator **physically stops the machine**, the system watches the machine status. When the stop is confirmed, it asks whether the machine was stopped **to remove the completed spool and perform the completion transaction, including label printing**.

- **Yes** — the completion workflow runs, the transaction is performed, and the labels print.
- **No** — the prompt closes. No transaction, no labels.

The prompt appears **only** after the machine confirms it has stopped.

## 4.2 Why this is a two-condition gate on an edge

A physically stopped line is an extremely common condition on FL1 — die change, weld preparation, a break, shift change, a blockage. If the prompt were raised on the stopped *state* rather than the stop *transition*, and without a weight condition, it would become the alert operators learn to dismiss reflexively. It is therefore **armed by weight**, **fired by a transition**, and **filtered for noise**.

| # | Design point | Rule |
|---|---|---|
| 1 | **Arming** | Only while weight ≥ target for the current spool. Below target, a stop raises nothing |
| 2 | **Firing** | On the running → stopped **transition**, not the level. One prompt per stop event |
| 3 | **Corroboration** | Line speed at approximately zero is read alongside the state, so a stale state value alone cannot fire the prompt |
| 4 | **Noise filter** | The stop must hold continuously for a configurable dwell (**default 5 seconds**). Lines momentarily read zero during threading, jogging and slow-downs |
| 5 | **Latched weight** | Weight is **frozen at the stop timestamp**; that value is what the prompt shows and what the transaction and label use. The counter can tick on after the drives stop |
| 6 | **Server-owned** | The evaluator lives in the service, not the browser. The prompt survives a refresh or a screen change, can be targeted at the line's operator sessions, and both the raise and the answer are auditable |
| 7 | **Suppression** | If the operator used the software pause immediately beforehand and gave a reason, the system already knows why the line stopped; asking again is noise |
| 8 | **"No" is not a dead end** | An operator may answer No and decide five minutes later to close the spool. A **manual completion** entry point stays available whenever weight ≥ target |
| 9 | **"No" does not nag** | After No, the prompt does not re-fire for the same stop; it re-arms on the next transition |
| 10 | **Restart while open** | The answer is implicitly *still producing*. The prompt auto-dismisses, is logged as system-dismissed with reason *line resumed*, and re-arms |
| 11 | **Yes is an entry point, not a bypass** | The completion workflow keeps its own gates — per-spool SPC for gauge and width is mandatory before an identity is issued. Yes routes into that workflow; it does not skip validation |
| 12 | **Over-target stops** | A stop above target fires the same prompt with the latched over-target weight, and the completion summary flags the overage rather than silently accepting it |
| 13 | **Communications loss** | No machine data, no confirmation, no prompt — by design, since the requirement conditions the prompt on machine confirmation. Manual completion is the fallback |
| 14 | **Multiple operators** | One prompt per line; the first answer wins; the answering operator is recorded |

## 4.3 State machine

| State | Entered when | Exits to |
|---|---|---|
| `Idle` | Weight below target | `Armed` when weight ≥ target |
| `Armed` | Weight ≥ target, line running | `Pending` on a confirmed stop held for the dwell; back to `Idle` on a new spool |
| `Pending` | Stop confirmed, weight latched, prompt displayed | `Completing` on **Yes** · `Declined` on **No** · `Armed` if the line resumes (auto-dismiss) |
| `Completing` | Answered Yes | `Completed` when the transaction commits and labels print, then resets to `Idle` |
| `Declined` | Answered No | `Armed` — re-arms for the next stop; manual completion remains available |

## 4.4 Behaviour rules

| ID | Rule |
|---|---|
| **S-1** | The prompt appears **only** after the machine confirms the line has stopped — never on a software assumption. |
| **S-2** | Both conditions must hold: weight ≥ target **and** a confirmed stop transition. |
| **S-3** | The stopped state must persist for the configured dwell, with speed at approximately zero. |
| **S-4** | The displayed weight is **latched at the stop timestamp** and is the value used by the transaction and the label. |
| **S-5** | Exactly **one** prompt per stop event. It does not re-raise while the line remains stopped. |
| **S-6** | **Yes** → the completion workflow: transaction committed, identity finalised, labels printed. |
| **S-7** | **No** → the prompt closes with no transaction, no identity finalisation, no label print and no change to the spool. The decline is logged. |
| **S-8** | If the line resumes while the prompt is open, it auto-dismisses as *line resumed* and re-arms. |
| **S-9** | The pending prompt is **server-owned state** — it survives a browser refresh and is re-delivered on reconnect. |
| **S-10** | Escape and clicking outside do **not** dismiss it; the operator must answer. There is no close affordance on the question. |
| **S-11** | Labels print **only after** the completion transaction commits — never on opening the prompt, and never on Yes alone if the transaction fails. Two print per spool, one per side (§4.8). |
| **S-12** | Both outcomes are audited: prompt raised (stop timestamp, latched weight), the answer, the answering operator, and the answer timestamp. |
| **S-13** | A **manual completion** entry point remains available whenever weight ≥ target **and the line is not running** — a spool cannot be removed from a turning take-up, so the same gatekeeper rule that blocks rod checkout applies. |
| **S-14** | Dwell time and the arming threshold are configuration, not constants. |
| **S-15** | Each choice states its **consequence on the control itself**, not in surrounding prose. Keyboard answers (Y / N) are provided and advertised on the choices. |

## 4.5 Weight verification at completion

| ID | Rule |
|---|---|
| **S-16** | The completion step must offer a **scale weight** entry. It is **optional** — with nothing entered, the calculated weight is recorded. |
| **S-17** | The scale reading is entered as **gross**; the system derives **net = gross − spool tare** and reconciles it against the calculated net, showing the variance in **pounds and percent**. |
| **S-18** | The operator explicitly chooses **which weight is recorded**. A scale reading is **pre-selected once entered** — a physical weighing outranks a derivation — but the operator may revert to calculated. The choice is never made silently. |
| **S-19** | The chosen basis governs the **spool record, the label and everything downstream**. The label prints the recorded weight. |
| **S-20** | A variance beyond a configurable tolerance (**default ±2 %**) is flagged but **never prevents the spool from being created**. The completion is **authorised, not blocked**: a supervisor override appears and the commit control stays enabled throughout. |
| **S-21** | The scale reading is **retained on the record even when calculated is selected** — the discrepancy is the evidence needed to validate the density factor and the scale. |
| **S-22** | The override captures the **variance reason**, the **supervisor identity** and a **PIN**. The PIN authenticates only; it is never carried in the payload or stored. Committing with the override incomplete flags exactly the missing fields and focuses the first — it does not commit, and it does not lock the operator out. |
| **S-23** | When no supervisor is on the floor, a **remote approval** request notifies one. Requesting does not block or change the screen; an on-floor override can still be taken the moment one is available. |
| **S-24** | An overridden completion is **marked on the spool record** — flag, authorising supervisor, reason, both weights and the variance — and stated plainly on the result, so the next person sees the spool was accepted out of tolerance. |
| **S-25** | If the variance is brought back inside tolerance by a re-weigh or a corrected entry, the override requirement **disappears** and the completion proceeds with nothing recorded against it. |

**Why an out-of-tolerance variance must not strand the spool.** *(Client direction, July 29, 2026.)* The physical spool is finished and sitting on the take-up. A screen that refuses to create it merely moves the problem off-system, and the operator ends up completing it later from memory, or not at all. The override is what makes the exception **visible**: accepting an odd weight becomes a traceable decision rather than a silent one.

## 4.6 Presentation requirements

| Aspect | Requirement |
|---|---|
| Form | A centred modal. Acceptable here because the machine is already stopped |
| **No scrolling** | The dialog must never scroll — the operator should take in the whole decision at once |
| Priority | **Decision first, evidence last.** The identity band states what happened and shows the one number that matters; the question is asked once, in the largest type on screen; the machine-state provenance sits quietly at the bottom |
| The question | *"Was the machine stopped to remove the completed spool?"* with a short clarifier that confirming runs the transaction and prints the labels. Asked **once** — not restated in the title |
| The two choices | Full-width rows sized for gloved use, each with its **consequence spelled out** — Yes states what will be completed, at what weight, and that labels will print; No states that nothing is recorded and the spool can be completed later. Expected answer first |
| Over target | An inline warning between question and choices, stating the overage and that it will be recorded |
| Evidence footer | Machine state, dwell held, speed, stop timestamp, spool identity — provenance, not headline |
| Completion step | Two columns — **weight verification** (calculated, scale, variance, tolerance state, basis choice, "will record") beside **the identity of what is being committed** (identity, footage, gauge, width, source rods and the weight each contributed, weld points) with the label set beneath. **The next spool carrier is captured here**, in the committing column, and the commit control is unavailable until it is valid (§4.7). The supervisor override spans the full width below both. Actions last |
| Result step | States the committed facts, the **weight basis** used, label print confirmation, **the carrier the next spool will be wound onto**, and that the milestone ladder has re-armed |
| Declined | The docked progress indicator shows *target reached* with a manual **Complete spool** action |

---

## 4.7 The next spool, and why the transaction cannot complete without it `[CONFIRMED — Aug 20, 2026]`

**The completion transaction names the spool that goes on next.** This was settled on 20 August 2026,
and it changes where the spool number is captured.

**Why here and not at check-in.** Two reasons were given, and both are physical:

| | |
|---|---|
| **One rod makes several spools** | A rod bundle yields roughly three spools at about 1,800 lb each, so a single check-in cannot name them all. *"It'll have to be on transaction, because multiple spools will come out of a bundle."* |
| **Check-in is at the other end of the machine** | *"Check-in is going to happen at the payoff at the other side of the machine, whereas the spool is going to happen at the output side of the machine, which is where the operator station is."* At check-in the operator does not yet know which spool they will use — *"they may not know exactly what that spool number is"* — and by the time they are standing at the take-up, they do. |

**And it is a hard gate, not a prompt that can be dismissed.** *"You cannot create a spool transaction
without a spool to create that transaction."* Confirmed as a showstopper for the next spool starting:
the completed spool is removed, the next carrier is fitted, the material is attached and threaded, and
the run continues — and the system will not let the transaction close without knowing which carrier the
next spool is being wound onto.

> **⚠ This supersedes the earlier description.** Our May 2026 note had the spool number entered *"at
> the start of the FL1 job"*. That is wrong in a way that matters: the job produces several spools, so
> the capture recurs once per completion, not once per job.

**How the number is entered.** As **typed text, validated against the registered carriers** — not
chosen from a list. There are thirty carriers, possibly forty-five, and *"even if you take 30 or 45,
it's a long list to select from the drop-down; scrolling and all is not easy."* An unrecognised number
is refused with the field marked, exactly as at check-in.

| ID | Rule |
|---|---|
| **S-26** | The completion step captures the **next spool carrier** as part of the same transaction. |
| **S-27** | The carrier number is **entered as typed and validated against the registered list**. An unrecognised number is refused and the transaction does not commit. |
| **S-28** | The transaction **cannot be committed without it.** This is a hard gate — there is no skip, and no deferred entry. |
| **S-29** | A carrier that is **already carrying material** is refused, with the spool it is holding named. |
| **S-30** | Declining the prompt (S-7) captures nothing, including no carrier. |
| **S-31** | The carrier captured is audited with the completion — the number, the operator and the timestamp. |

> `[CLIENT INPUT REQUIRED]` **The mandrel or core diameter.** Alongside the carrier you told us
> *"we need to know what diameter mandrel is attached"*, comparing it to selecting the mandrel size on
> a slitter. Nothing records this today. **Our reading is that it does not need to be entered** — you
> have confirmed every spool is the same standard size, so the diameter is a property of that size
> rather than a choice, and a field with only one possible value is one an operator will eventually get
> wrong. If it does vary, it belongs here beside the carrier. Section 10, **Q46**.

## 4.8 What the labels print `[CONFIRMED — media]` `[CLIENT INPUT REQUIRED — fields]`

This document has referred to printing the labels throughout without ever saying what is on them or
what they are printed on. Both were settled in part on 20 August 2026.

**The media, confirmed.** A spool goes through the anneal furnace, so an ordinary label does not
survive — *"we won't be able to put the label on them and scan"*. The agreed mechanism is the
**1½ × 3 inch high-temperature coil label** already used on mill output, of which **two print per
label, one for each side of the spool**: *"you get 2 per label, one for each side of the spool, slap it
on."* These are the same labels already used for cut material going to anneal.

**What it carries, confirmed in part.** *"We would want that label to print with the spool number, and
maybe list out the alphas that are attached to it."*

| Printed | Status |
|---|---|
| The **spool carrier number** | `[CONFIRMED]` |
| **Every alpha on the spool** — a welded spool carries several | `[CONFIRMED]` |
| The **weight contributed by each alpha** | `[PROPOSED]` — it is what the certificates are built from, and it depends on the conversion still owed (**Q33**, and the dimensional basis behind it) |
| The **order or orders** | `[PROPOSED]` |
| The pass schedule | **Not printed** — settled previously; it is logged for traceability instead |

**Any one identifier on the label resolves the spool at FL2.** Not only the spool number: *"just like
the furnace plate — they only have to scan one of the coil codes on a furnace plate to get it into
anneal."* So the carrier number prints as the primary barcode and each alpha as a secondary, and the
FL2 operator may scan whichever is facing them.

> **A durable alternative is being investigated, and it does not change this.** Stainless-steel etched
> barcode plates, tack-welded one to each side, *"supposedly can survive through anneals"*. Our reading
> is that these would carry the **carrier number only** and sit alongside the label rather than
> replacing it — the carrier is permanent and so is the etching, whereas the alphas change with every
> cycle. Section 10, **Q44**.

---

# 5. Part C — Short Close `[CONFIRMED — July 30, 2026]`

The milestone ladder and the stop prompt are both armed **at or above target**, so a spool closed **early** — order satisfied, rod exhausted, quality problem, end of campaign — would otherwise fall outside the requirement entirely.

**A short close is an unplanned stop**, handled on the pattern of the mill 10-90 standard operating procedure, with an unplanned-stop reason code.

| Rule | Behaviour |
|---|---|
| **Grading basis** | The **customer minimum–maximum weight**, by weight — not footage, and not a fixed target |
| **Inside the range** | **Continue.** If the short weight still yields the finished coils the order requires, nothing escalates |
| **Outside the range** | **Flagged.** Either a **supervisor override plus a production hold**, or the piece is **offered to the customer under concession** before a remake is planned. The direction is explicit: **offer first, remake last** |
| **The spool still runs off** | **Always.** FL2 has no spool stripper, so the spool must be emptied and returned to FL1 whatever happens to the material on it. Rejecting the material is never the same as stopping and removing it |

## 5.1 Mid-run coil break — a different rule

The stop is **removed and a new stop starts from zero**. Weight does **not** resume from the break point. The leftover incoming material is **welded to the next coil on FL1**; on FL2 it is run off to a finished stop and offered to the customer, or scrapped.

> **Two cautions before this is built.**
> 1. **The 10-90 standard operating procedure is not in our possession.** It must be obtained from Operations and cited — what is recorded above is the call summary, not the procedure.
> 2. **Restart-from-zero is a run and stop model change, not a screen rule.** It must be reconciled with how run footage accumulates and with the coil-local footage used for traceability; run events use cumulative run footage while traceability is coil-local, and the offset between them is undefined (OI-25).

---

# 6. Edge Cases

| Scenario | Handling |
|---|---|
| Stop at 60 % for a die change | No prompt — not armed (S-2) |
| Momentary zero speed, jog or threading at 100 % | Filtered by the dwell (S-3) |
| Software pause with a reason logged, then a stop | Prompt suppressed — the reason is already known |
| Operator answers No, then removes the spool anyway | Manual completion on the progress indicator (S-13) |
| Line restarted with the prompt open | Auto-dismiss as *line resumed*, re-arm (S-8) |
| Prompt left unanswered, operator away from the screen | It persists — it is a decision, not an alert. The machine is stopped, so nothing is blocked |
| Browser refreshed, or the operator changed screens | Pending prompt re-delivered from server state (S-9) |
| Two operators signed in on the line | One prompt, first answer wins, the answering operator recorded |
| Footage ticks on after the drives stop | The latched weight is authoritative (S-4) |
| Stop above target | Same prompt; the overage is flagged on the completion summary |
| Machine communications down | No prompt; manual completion is the fallback |
| Yes, but per-spool SPC not yet recorded | The completion workflow enforces its own gate; the prompt is an entry point only (S-11) |
| Operator stops short of target, intending to close early | **Part C — short close** |

---

# 7. Acceptance Criteria

## 7.1 Part A — milestone alerts

| # | Criterion |
|---|---|
| A-1 | Below 75 % of target with the line running, no notification is shown. |
| A-2 | Crossing 75 % raises the notification within one telemetry update, showing weight, target and percent. |
| A-3 | The notification never blocks the screen — every active run control remains usable while it is displayed. |
| A-4 | Left unacknowledged, the displayed weight and percent update on every telemetry update. |
| A-5 | Acknowledging at 75 % dismisses it; nothing reappears until 90 %. |
| A-6 | Acknowledging at 90 % dismisses it; nothing reappears until 100 %. |
| A-7 | Reaching a milestone with the previous one unacknowledged escalates the existing notification in place — exactly one is ever on screen. |
| A-8 | Acknowledging at 100 % ends the ladder for that spool. |
| A-9 | Every acknowledgement writes an audit record with operator, milestone, weight and timestamp. |
| A-10 | Closing a spool and starting another on the same run re-arms all milestones from zero. |

## 7.2 Part B — stop confirmation

| # | Criterion |
|---|---|
| B-1 | Below target, stopping the machine raises no prompt. |
| B-2 | At or above target, stopping raises the prompt only after the machine state has read stopped for the dwell. |
| B-3 | A stop shorter than the dwell raises no prompt. |
| B-4 | The prompt shows the weight latched at the stop timestamp, and that value does not drift while it is open. |
| B-5 | **No** closes it with no transaction, no identity finalisation and no label print, and logs the decline. |
| B-6 | **Yes** routes into the completion workflow; labels print only after the transaction commits. |
| B-7 | The prompt does not re-raise while the line stays stopped; it re-arms on the next running → stopped transition. |
| B-8 | Restarting the line with the prompt open auto-dismisses it and logs *line resumed*. |
| B-9 | Escape and clicking outside do not dismiss the question. |
| B-10 | A pending prompt survives a browser refresh and is re-delivered. |
| B-11 | Manual completion is available whenever weight ≥ target and the line is not running, including after a No; it is hidden while the line runs. |

## 7.3 Part B — weight verification

| # | Criterion |
|---|---|
| B-12 | With no scale weight entered, the completion commits the calculated weight and no reason is requested. |
| B-13 | Entering a gross scale reading resolves net from the tare and shows the variance in pounds and percent within the same interaction. |
| B-14 | A reading below the tare, blank, or non-numeric is rejected; the variance clears and the basis falls back to calculated. |
| B-15 | A variance inside tolerance shows the within-tolerance state and commits with no override requested. |
| B-16 | A variance beyond tolerance **never disables the commit control**; the override panel appears and the action relabels accordingly. |
| B-17 | Committing with an incomplete override flags exactly the missing fields, focuses the first, and commits nothing. |
| B-18 | Supplying reason, supervisor and PIN completes the spool and prints the labels. |
| B-19 | An overridden completion records the flag, the supervisor and the reason, states it on the result, and never puts the PIN in the payload. |
| B-20 | Requesting remote approval notifies the supervisor and is logged, without changing what the operator can do next. |
| B-21 | Correcting the variance back inside tolerance removes the override requirement, and the completion records no override. |
| B-22 | The recorded net, gross and **basis** follow the operator's choice, appear on the result, and are what the label prints. Both weights, the variance, the basis and any reason are audited even when calculated is chosen over an entered scale reading. |

---

# 8. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | Milestone alerts are advisory, non-blocking, and escalate in place | Jul 28, 2026 |
| D2 | The stop prompt is conditioned on machine confirmation of the stop, not on a software assumption | Jul 29, 2026 |
| D3 | **The dialog must not scroll** — the whole decision must be visible at once | Jul 29, 2026 |
| D4 | **An out-of-tolerance weight variance never blocks spool creation.** A supervisor override authorises it; the commit control is never disabled | Jul 29, 2026 |
| D5 | **The target basis is the customer minimum/maximum weight.** The assumed 2,000 lb default is withdrawn | Jul 30, 2026 |
| D6 | Spools are sized around 1,800 lb so two finished coils can be cut at FL2 | Jul 30, 2026 |
| D7 | **A short close is an unplanned stop** graded against the customer range; outside it, override and hold or offer under concession — offer first, remake last | Jul 30, 2026 |
| D8 | **The spool always runs off** — FL2 has no spool stripper | Jul 30, 2026 |
| D9 | **A mid-run coil break restarts the stop from zero**; the leftover is welded to the next coil on FL1, or run off and offered or scrapped on FL2 | Jul 30, 2026 |
| D10 | **The completion transaction captures the next spool carrier, and cannot commit without it** — the operator is at the output side of the machine, where the spool is, and one rod makes several spools | Aug 20, 2026 |
| D11 | **The carrier number is typed and validated, not selected from a list** — thirty to forty-five entries is too long to scroll | Aug 20, 2026 |
| D12 | **Labels are the 1½ × 3 inch high-temperature coil label, two per spool, one per side** — nothing else survives the anneal | Aug 20, 2026 |
| D13 | **The label carries the carrier number and every alpha on the spool, and any one of them resolves the spool at FL2** — the furnace-plate behaviour | Aug 20, 2026 |

---

# 9. Assumptions

| # | Assumption |
|---|---|
| A1 | Live footage, gauge and width are broadcast per line, so weight can be evaluated continuously on FL1 and FL3. |
| A2 | A floor scale is available for weighing a completed spool, and the spool tare is known to the system. |
| A3 | The machine exposes a line-state value and a speed value that can be read to confirm a stop. |
| A4 | Alloy density is available per alloy for the weight derivation. |
| A5 | Label printing is triggered by the completion transaction, not by the operator's answer. |

---

# 10. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **Q33** | High | **Outside-diameter to weight conversion** — the authoritative weight source | The weight basis for every part of this document |
| **Q18** | High | **Which order field carries the customer minimum and maximum**, and whether the over-target state (M4) is required | Target resolution and the ladder's top step |
| **Q19** | Medium | Does the same ladder apply to finished coils at the final take-up, and does FL2's absent live measurement change the weight basis? | FL2 / FL3 applicability |
| **Q20** | Medium | Is the notification **mirrored to the supervisor**, and where does the acknowledgement audit record live? | Supervisor visibility |
| **Q21 / OI-35** | High | The **line-state vocabulary** and the stop dwell value; and should the prompt be suppressed when a software pause has already captured a reason? | The firing condition |
| **OI-75** | Medium | Does the stop prompt also surface to the supervisor, and how are multiple signed-in operator sessions arbitrated? | Prompt targeting |
| **OI-56 / OI-38** | High | **Where the supervisor PIN is validated**; and whether a scale exists at the take-up at all | The override, and scale verification |
| **OI-25** | High | The **offset between run-cumulative and coil-local footage** | The coil-break restart rule |
| **Q44** | High | **The full field list for the spool label**, and whether the etched steel plate replaces the high-temperature label or supplements it | What §4.8 prints, and whether a second marking mechanism is needed |
| **Q46** | Medium | **The mandrel / core diameter** — selected per spool at completion, fixed by the one standard spool size, or read from the machine | Whether §4.7 captures a second field |
| **Q42** | High | **The stenciled carrier number format**, and whether the fleet is thirty or forty-five | The validation list §4.7 checks against |
| — | Medium | **The 10-90 standard operating procedure document** | The short-close reason codes and escalation |

> **Known gap in the deliverables.** There is no dedicated screen for the FL1 **spool completion** workflow itself — per-spool SPC gate, identity finalisation and label content. Part B's Yes path currently routes into a compact completion summary standing in for that screen. The real workflow needs its own specification and screen.

---

# 11. Related Specifications

| Document | Relationship |
|---|---|
| [Rod Checkout](RodCheckout.md) | The gatekeeper rule reused here — no completion on a turning take-up |
| [Weld Event](WeldEvent.md) | Weld markers aggregated onto the spool record; the coil-break rule |
| [SPC Checkpoint](SPCCheckpoint.md) | The per-spool gate the completion workflow enforces |
| [Rod Check-in](RocCheckin.md) | Opens the run whose footage this function measures |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §2.1 | The 75 / 90 / 100 % ladder, and whether M4 (over target) is wanted | ☐ | ☐ |
| §2.2 | Rules R-1 to R-12 | ☐ | ☐ |
| §3.2 | Target graded against the customer minimum/maximum; 2,000 lb withdrawn | ☐ | ☐ |
| §4.2 | Armed by weight, fired by a stop transition, filtered by a 5-second dwell | ☐ | ☐ |
| §4.4 | Rules S-1 to S-15 | ☐ | ☐ |
| §4.5 | Rules S-16 to S-25, including that variance never blocks completion | ☐ | ☐ |
| §4.6 | The dialog must not scroll; consequences stated on the controls | ☐ | ☐ |
| §4.7 | The next spool carrier is captured at completion, typed and validated, and the transaction cannot commit without it (S-26 to S-31) | ☐ | ☐ |
| §4.8 | Labels are the high-temperature coil label, two per spool; the carrier number and every alpha print, and any one resolves the spool | ☐ | ☐ |
| §5 | Short close as an unplanned stop, graded by weight; offer before remake | ☐ | ☐ |
| §5 | The spool always runs off | ☐ | ☐ |
| §5.1 | Mid-run coil break restarts the stop from zero | ☐ | ☐ |
| §7 | Acceptance criteria A-1 to A-10 and B-1 to B-22 as the UAT basis | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| Q33 | Outside-diameter to weight formula | | ☐ |
| Q18 | The order field carrying customer min/max; M4 required? | | ☐ |
| Q19 | Ladder applicability to finished coils | | ☐ |
| Q20 / OI-75 | Supervisor mirroring and multi-session arbitration | | ☐ |
| Q21 / OI-35 | Line-state vocabulary and dwell value | | ☐ |
| OI-56 / OI-38 | Scale availability; PIN validation source | | ☐ |
| OI-25 | Run-to-coil footage offset | | ☐ |
| Q44 | The full spool-label field list; etched plate — replace or supplement? | | ☐ |
| Q46 | Mandrel / core diameter — entered, fixed, or read? | | ☐ |
| Q42 | The stenciled carrier format, and thirty or forty-five | | ☐ |
| — | The 10-90 standard operating procedure | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Quality** | | | |
| **Engineering / Controls** | | | |
| 2.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
