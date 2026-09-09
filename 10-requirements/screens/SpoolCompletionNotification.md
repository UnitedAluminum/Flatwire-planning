# Flat Wire Processing — Spool Completion Specification

**Weight milestone alerts · machine-stop confirmation · short close**

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 (spool at the intermediate take-up) · FL2 / FL3 (finished coil at the final take-up)
**Version:** 2.5
**Last Updated:** September 9, 2026 — **`Q19` / `G120` re-weighted: the FL2 live-gauge evidence now runs against §3.1's caveat, and the question asked is sharper** *(previously 2.4, same day — the returned client questions workbook)*
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

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register. ⚠ **A decided question moves rather than changing state in place** — `Q18` and `Q20` are cited below against the **decisions** register, not the open-questions one.

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

## 1.3 Applicability `[CONFIRMED — Sep 8, 2026]`

- **FL1 standalone** — the take-up produces an intermediate **spool**. This is the primary case described here.
- **FL2 / FL3** — the take-up produces a finished **coreless coil**. The same ladder applies against the coil target, with wording changed from spool to coil.

**Confirmed on the returned questions workbook (`Q19`).** The 75 / 90 / 100 ladder runs at the finished-coil take-up with coil wording and the coil target weight — the operator concern is identical and a second, differently-shaped notification would be a training cost for no benefit. **`Q15` confirms the second line above in the same pass:** *"FL3 does not produce on spools, it produces coreless oscillate coils"* — so no FL1-style spool is ever produced on a hybrid run, and nothing in this document should be read as describing one.

> ⛔ **`Q19` itself does not close.** Its answer carries a clause that contradicts §3.1's FL2 caveat, and on 9 Sep 2026 that clause gained a **second, independent corroboration** from `Q1`. ⚠ **It is still not actioned here** — the assertions are `FR-120` and `FR-137` and the correction must land there — but the evidence now runs against the caveat rather than for it. See **`G120`** at §10.

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
| **M4** `[CONFIRMED — Sep 8, 2026]` | Weight > **101 %** of target **and M3 not yet acknowledged** | Over target | Over target by *n* lb; the take-up should be stopped and the spool closed | Dismiss |

**M4 was a design addition and is now a confirmed requirement.** An unacknowledged M3 keeps updating and will therefore run past 100 %; a notification silently reading "104 % of target" in a *target reached* style understates the situation. The 1 % margin exists so the state cannot flicker the instant target is touched.

> ✅ **Confirmed on the returned questions workbook, unqualified** — an unacknowledged climb past target **escalates to a distinct over-target state** rather than continuing to show *target reached* with a percentage above 100. A percentage climbing above 100 with no change of state gives the operator nothing new to react to at exactly the moment the equipment limit is being approached. Recorded at **`Q18`** in the **decisions** register.

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
| **R-11** | Acknowledgement is an **audited event** — operator, milestone, weight at acknowledgement, timestamp — recorded in the **existing run-event stream** against the run, not in a new milestone record type. `[CONFIRMED — Sep 8, 2026]` (`Q20`, decisions register). |
| **R-12** | The thresholds are **configuration, not constants** — tunable by Operations without a software release. |
| **R-13** | **Only the unacknowledged 100 % milestone (M3) is mirrored to the supervisor** — not the whole ladder. An unanswered completion means nobody is at the machine while the spool fills, which is the one state a supervisor needs; mirroring all three teaches them to ignore it. `[CONFIRMED — Sep 8, 2026]` (`Q20`, decisions register). |

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

Weight wound onto the current take-up since the spool started, derived from the live footage counter and the **nominal** cross-section. The formula is `FR-137`'s and is not restated here as a second authority:

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

**The dimensional basis is NOMINAL** `[CONFIRMED — Sep 8, 2026]`. This was the open half of `Q10` and was deliberately left for UA to state from their own practice: *"The rod dimension used is the **nominal**, as the measured will only be in the position measured and can vary within a few inches, but within the accepted tolerances."* Two consequences land with it — **rod weight is an input, not a derived value** (`D-37`), and **a round-edge correction applies at FL1 output**, because FL1 has no edger (`D-26`, `Q28`). ⚠ **The worked example above uses the square-edge factor**, so it is an upper bound: the round-edge coefficient itself is still open at `OI-45` (b) — whether the edge is a true semicircle or a partial radius — and the correction is worth ≈ 3.9 % on footage. **Do not re-derive either number here**; `FR-137` owns the formula and `OI-45` owns the coefficient.

**There are no load cells** `[CONFIRMED — Sep 8, 2026]`. *"There are no available loadcells installed on the take-ups or payoffs"* (`Q30`). The derivation above is therefore not the preferred source of the completion weight — it is the **only** one. See §3.3 and §4.5, both of which were written when a weighing device was assumed to exist.

**FL2 caveat.** FL2 standalone does not broadcast live gauge and width — its trace is historical. Its weight factor must therefore use the pass-schedule or order gauge and width, not a live measurement.

> ⛔ **This caveat is disputed, it is still NOT edited, and the balance of evidence now runs AGAINST it.** Gap **`G120`** was re-weighted on 9 Sep 2026 and the earlier reading of it — six documents outweighing one passing client remark — **was wrong**:
>
> - ⭐ **The six opposing sites are not six assertions. They are six restatements of one assumption of ours** — **`A3`** in [`[PLC §14]`](../../20-architecture/PLCTagSpecification.md), *"FL2 has no live measurement"* — and a search of the client-source folder finds **no client statement supporting it, ever**.
> - ⛔ **`A2`, the row directly above it in the same table, was falsified by this same mail** — it claims load cells on both payoffs and take-ups, and `Q30` says there are none anywhere.
> - ⭐ **`Q1` is a second and stronger contradiction**: *"we have auto position control on the 12″ mill and **FL2-S3 (6″) stands via the gauging stands down stream**."* That describes a **closed automatic-gauge-control loop on FL2**, and a stand cannot hold gauge automatically from a measurement nobody is taking continuously. It answers about the *equipment*, to a different question, so it corroborates `Q19` independently.
>
> **The register's verdict is that `A3` is probably wrong and `FR-120` probably follows it down** — but that is inference from two side-remarks, so **nothing is edited here and nothing should be.** `FR-120` and `FR-137` are the assertions; this document only cites them, and the correction must land there first. ⚠ **If `A3` does fall, this caveat and the FL2 lb/ft factor fall with it** — `FR-137` sources FL2's gauge and width from the pass schedule *because* live measurement was believed unavailable. See §10.

## 3.2 Target weight `[CONFIRMED — July 30, 2026 · carrying field confirmed Sep 8, 2026]`

**The basis is the customer's weight range.** The customer specifies a **minimum and a maximum** weight (figures given on the call: 900 lb maximum, 800 lb minimum) and completion is graded against that range, **by weight** — not by footage, and not against an assumed default.

| Source | Value | Role |
|---|---|---|
| **Order — customer minimum/maximum** | e.g. 800–900 lb | **The basis.** Completion is graded against it |
| Spool sizing | ~1,800 lb | Sized so **two finished coils** can be cut from one spool at FL2 |
| Intermediate take-up capacity | 3,500 lb | Hard equipment ceiling |
| Final take-up capacity | 1,100 lb | Finished-coil ceiling. The customer maximum is normally below it, so the customer value governs |

> **The previously assumed 2,000 lb default is withdrawn.** It had no basis and exceeded the finished-coil ceiling.

> ✅ **Which order field carries the customer minimum and maximum is now settled** `[CONFIRMED — Sep 8, 2026]`. The minimum and maximum ride on the **order**, reusing the existing **Max Wgt of Spool** field for the maximum and **adding a matching minimum** — rather than introducing a separate spool-target entity. Short closes are graded against the same range (§5), so one source serves both. Recorded at **`Q18`** in the **decisions** register.

> ⚠ **`Q33` no longer withholds the weight basis, but one sentence of confirmation is still owed.** We asked for the outside-diameter → weight conversion; the client answered that **OD is itself derived *from* footage** — *"Product OD will be calculated by engineering by way of an encoder that tracks footage, against the speed of the take-up"* — which inverts the question. If that reading is right, **OD is not an input to weight at all**: weight comes from footage directly, and the working basis in §3.1 is simply the `FR-137` factor rather than a placeholder standing in for something better. **Confirm that reading before `Q33` closes**, because the question as asked presumed OD was measured.

## 3.3 A derivation is not a measurement

`footage × gauge × width × 12 × density` inherits every error in its inputs — counter slip, the gap between the **nominal** section and the actual one, the unsettled round-edge coefficient (`OI-45` (b)), and an assumed alloy density. A physical weighing would be the only ground truth against it, so the completion step must be able to capture one and must never quietly commit a derived number when a measured one exists.

> ⛔ **There is no such weighing device today, on either line.** `Q30` confirms no load cells on the take-ups **or** the payoffs, and the only scale under discussion — `Q12` — is at the **FL1 payoff**, for scaling a partial rod in or a return-to-stock out. That is the other end of the machine and would not weigh a completed spool. **This section states what the design requires, not what the floor currently has**; §4.5 and §9 `A2` carry the same dependency, and §10 `OI-56` tracks it.

This is also how the outstanding weight-formula question eventually answers itself — **if** a scale ever exists at the take-up: accumulate scale-versus-calculated variances and both the density factor and the round-edge coefficient can be validated against real production data. Without one, `OI-45` closes by engineering judgement rather than by measurement.

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
| 3 | **Corroboration** | Line speed at approximately zero is read alongside the state, so a stale state value alone cannot fire the prompt. `[CONFIRMED — Sep 8, 2026]` — `Q27` puts speed under the machine HMI and **not** under the application, *"available as an OPC tag for retrieval purposes"*. The read this design point needs exists; nothing here writes a speed |
| 4 | **Noise filter** | The stop must hold continuously for a configurable dwell (**default 5 seconds**). Lines momentarily read zero during threading, jogging and slow-downs. ⚠ **The dwell now carries all of the noise filtering** — see the note below |
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

> ⚠ **The line-state vocabulary is binary, which makes the dwell load-bearing.** Answering `Q21` on 8 Sep 2026 the client wrote *"Typically, machine output is **Stop/Run**"* and *"**any movement above zero would be a run flag**"* — so there is no `THREADING` or `JOG` value to filter on, and design point 4's dwell is the **only** thing separating a jog or a thread from a real stop. The 5-second default is still ours and still unconfirmed. ⛔ **This does not contradict the 1 Sep answer** that jog events fire on all three FL2 stands: a jog can be a real event without being a distinct `LineState` value, and reconciling the two is the controls session the client has asked for. `Q21` stays open on the dwell value and on pause-reason suppression (§10).

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

> ⚠ **This whole block is conditional on a weighing device that does not exist today, and the rules are deliberately left standing.** `Q30` confirms there are **no load cells on the take-ups or the payoffs**, and the only scale under discussion — `Q12`, answered *in principle* on 8 Sep and referred to Bob S. and Shannon R. for **10 Sep 2026** — is at the **FL1 payoff**, for scaling a partial rod in or a return-to-stock out, not at the take-up where a completed spool is removed.
>
> **Nothing below is withdrawn**, because `S-16` already makes the entry optional: with no scale on the floor, the block degrades cleanly to the calculated weight and `S-17`–`S-25` never fire. **What changes is the status of the section, not its rules** — it specifies behaviour for a device the project has not yet been told it will have. §10 `OI-56` is the tracking home, and the *"whether a scale exists at the take-up at all"* leg of it now has a date against it. ⛔ **Do not build `S-17`–`S-25` as though the scale were confirmed, and do not delete them as though it were refused.**

| ID | Rule |
|---|---|
| **S-16** | The completion step must offer a **scale weight** entry. It is **optional** — with nothing entered, the calculated weight is recorded. ⚠ **Today this is the only path that can run** — see the note above. |
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

# 5. Part C — Short Close `[CONFIRMED — July 30, 2026 · ratified in writing Sep 8, 2026]`

The milestone ladder and the stop prompt are both armed **at or above target**, so a spool closed **early** — order satisfied, rod exhausted, quality problem, end of campaign — would otherwise fall outside the requirement entirely.

> ✅ **Ratified on the returned questions workbook, unqualified** (`Q79`, decisions register) — the whole of this part, as recorded on 30 July, is confirmed. ⛔ **Both residuals stand:** the mid-run coil-break rule in §5.1 remains **provisional** on `OI-25`, and the 10-90 procedure is **still owed**.

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
> 1. **The 10-90 standard operating procedure is not in our possession, and it is being revised rather than merely mislaid.** It must be obtained from Operations and cited — what is recorded above is the call summary, not the procedure. ⚠ **Confirmed still owed on 9 Sep 2026**, with the client's own covering note explaining why: *"Need to review a current document and then retool for this process."* So the version we eventually receive will not be the one the July call described. **Do not paraphrase it in the meantime.**
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
| A-9 | Every acknowledgement writes an audit record with operator, milestone, weight and timestamp, **into the existing run-event stream** — no new milestone record type is created (R-11). |
| A-10 | Closing a spool and starting another on the same run re-arms all milestones from zero. |
| A-11 | A **100 % milestone left unacknowledged** is mirrored to the supervisor; the 75 % and 90 % milestones are not mirrored at any point, acknowledged or otherwise (R-13). |

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

> ⚠ **`B-12` is the only criterion here that is testable today.** The other ten require a scale at the take-up, and `Q30` confirms none exists (§4.5). They remain the UAT basis **if** one is provided; until then they are untestable rather than failed, and a UAT run must record them as such rather than marking them passed by omission.

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
| D14 | **The customer minimum and maximum ride on the order** — the existing *Max Wgt of Spool* field for the maximum, a matching new minimum — and **M4 is required**: an unacknowledged climb past target escalates to a distinct over-target state, not a percentage above 100 (`Q18`) | Sep 8, 2026 |
| D15 | **Only the unacknowledged 100 % milestone mirrors to the supervisor**, and the acknowledgement is recorded in the **existing run-event stream** rather than a new milestone record type (`Q20`) | Sep 8, 2026 |
| D16 | **The same 75 / 90 / 100 ladder runs at the finished-coil take-up** on FL2 / FL3, with coil wording and the coil target weight (`Q19`). ⚠ **This supersedes a contrary inference at `OI-74`** — see the note below | Sep 8, 2026 |
| D17 | **The dimensional basis is nominal, not measured**, and a round-edge correction applies at FL1 output because FL1 has no edger (`Q10`) | Sep 8, 2026 |
| D18 | **There are no load cells on the take-ups or the payoffs**, so the completion weight is derived and not weighed — unconditionally, because there is nothing to weigh with (`Q30`) | Sep 8, 2026 |

> **`D7`, `D8` and `D9` were ratified in writing on Sep 8, 2026** (`Q79`), unqualified. The dates above are when each was first recorded; the ratification is noted at §5 with both of its standing residuals.

> ⚠ **`D16` supersedes a contrary inference, and the two mechanisms it separates must not be merged.** On **3 Sep 2026**, asked what FL2 should do when an *order boundary* lands a few pounds past a coil cut, the client answered *"cut at 900 lb. and keep the remainder, a WIPREJ would be forced for the overage… essentially a peel-back."* `OI-74` read that as settling the ladder question **no — a forced WIPREJ applies instead of an alert ladder**. ⛔ **That was our inference from an answer to a different question.** `Q19` puts the ladder question directly and the client agreed to it on **8 Sep**, in writing, so `D16` governs. **The two coexist:** the ladder is **advisory**, warning the operator as the coil fills; the peel-back WIPREJ is **disposition**, applied at an order boundary once the maximum is passed — and that mechanism still has no reason code and no requirement (**`G88`**). ⚠ **One sentence is owed to the client** in case he meant them as alternatives: *does the fill ladder still run on a finished coil, given the overage is handled by a forced WIPREJ at the order boundary?* — to go in the same reply as `G120`'s question (§10).

---

# 9. Assumptions

| # | Assumption |
|---|---|
| A1 | Live footage, gauge and width are broadcast per line, so weight can be evaluated continuously on FL1 and FL3. ⚠ **The exclusion of FL2 is inherited from `A3` of `[PLC §14]`, which `G120` now judges *probably wrong*** — if FL2 does publish live readings, this assumption widens to all three lines and §3.1's FL2 caveat is withdrawn with it. |
| A2 | ⛔ **FALSIFIED, Sep 8, 2026 — this is now a stated dependency, not an assumption.** It read *"a floor scale is available for weighing a completed spool, and the spool tare is known to the system."* `Q30` confirms **no load cells on the take-ups or the payoffs**, and the only scale under discussion (`Q12`) is at the **FL1 payoff**, not the take-up, with the answer owed from Bob S. and Shannon R. on **10 Sep 2026**. §4.5 and §7.3 both depend on it; neither is withdrawn. The **spool tare** half is separately unconfirmed — nothing has yet stated it is known to the system. |
| A3 | ✅ **CONFIRMED, Sep 8, 2026.** The machine exposes a line-state value and a speed value that can be read to confirm a stop — the state as a **binary Stop/Run** output (`Q21`), the speed as a retrieval-only OPC tag (`Q27`). |
| A4 | Alloy density is available per alloy for the weight derivation — `FR-137` sources it from `united_db..alloys.alloy_density`. |
| A5 | Label printing is triggered by the completion transaction, not by the operator's answer. |

---

# 10. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **`G120`** | High | ⛔ **The gauging stands that drive FL2-S3's automatic position control — are their thickness and width readings available to us as OPC tags during a run, and at what update rate?** ⭐ **This is the sharper question, and it replaces the one first asked.** *Does the stand measure live?* is **almost certainly yes** on two independent client statements (`Q19`'s comment and `Q1`'s automatic-gauge-control loop); what is genuinely unknown is whether that measurement is **exposed** to us, and how often. ⚠ **A yes is a TAG-SURFACE ADDITION, not merely a requirement flip** — `[PLC §2]` records that FL2 has **no gauge or width tag at all** today, so a yes means new paths, a bound-map change, and a payload that currently sends `null`. ⛔ **Still nothing is edited**: the six opposing sites all restate assumption **`A3`** of `[PLC §14]`, which no client source has ever supported, but the case against it is inference from two side-remarks | §3.1's FL2 weight factor, `FR-120` / `FR-137`, and `Q19`'s close |
| **Q33** | High | **Confirm that OD is not an input to weight at all.** The client answered that OD is derived *from* footage, which inverts the question as asked; if that reading holds, weight comes from footage directly and §3.1 is already the whole basis | Closing the weight basis — no longer withholding it (§3.2) |
| **Q10 / OI-45** | High | The **round-edge coefficient** — a true semicircle or a partial radius, worth ≈ 3.9 % on footage. The dimensional basis itself is now answered (**nominal**, `D17`); this is the residual | The accuracy of every weight in this document, and §3.1's worked example |
| **Q19** | Medium | ⚠ **The ladder half is agreed** (`D16`) — the question is held open only by `G120` above | Nothing further in this document |
| **Q21 / OI-35** | High | The **stop dwell value** (5 s proposed) and whether the prompt is suppressed when a software pause has already captured a reason. ⚠ **The vocabulary half is answered** — binary Stop/Run, any movement above zero is Run — which makes the dwell the only noise filter (§4.2). The jog-versus-`LineState` reconciliation goes to the controls session the client has asked for | The firing condition |
| **OI-75** | Medium | Does the stop prompt also surface to the supervisor, and how are multiple signed-in operator sessions arbitrated? ⚠ **`Q20` settled the analogous rule for the milestone ladder** (`D15`, mirror the unacknowledged one only); this item is the stop **prompt**, which is a separate decision and is still open | Prompt targeting |
| **OI-56 / OI-38** | High | **Where the supervisor PIN is validated**; and whether a scale exists at the take-up at all. ⚠ **The scale leg now has a date and a partial answer** — none exists anywhere today (`Q30`), and the only one proposed is at the FL1 **payoff** (`Q12`), answer owed **10 Sep 2026**. §4.5 and §7.3 hang on it | The override, and the whole of §4.5 |
| **OI-25** | High | The **offset between run-cumulative and coil-local footage** | The coil-break restart rule — still provisional despite `Q79`'s ratification |
| **Q44** | High | **The full field list for the spool label**, and whether the etched steel plate replaces the high-temperature label or supplements it | What §4.8 prints, and whether a second marking mechanism is needed |
| **Q46** | Medium | **The mandrel / core diameter** — selected per spool at completion, fixed by the one standard spool size, or read from the machine | Whether §4.7 captures a second field |
| **Q42** | High | **The stenciled carrier number format**, and whether the fleet is thirty or forty-five | The validation list §4.7 checks against |
| — | Medium | **The 10-90 standard operating procedure document.** ⚠ **Confirmed owed 9 Sep 2026 and being revised**, not merely unlocated: *"Need to review a current document and then retool for this process."* So the version received will not be the one the July call described | The short-close reason codes and escalation |

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
| §2.1 | The 75 / 90 / 100 % ladder, and the M4 over-target step | ☐ | ☐ |
| §2.2 | Rules R-1 to R-13 | ☐ | ☐ |
| §3.2 | Target graded against the customer minimum/maximum; 2,000 lb withdrawn | ☐ | ☐ |
| §4.2 | Armed by weight, fired by a stop transition, filtered by a 5-second dwell | ☐ | ☐ |
| §4.4 | Rules S-1 to S-15 | ☐ | ☐ |
| §4.5 | Rules S-16 to S-25, including that variance never blocks completion — ⚠ **conditional on a take-up scale existing at all** | ☐ | ☐ |
| §4.6 | The dialog must not scroll; consequences stated on the controls | ☐ | ☐ |
| §4.7 | The next spool carrier is captured at completion, typed and validated, and the transaction cannot commit without it (S-26 to S-31) | ☐ | ☐ |
| §4.8 | Labels are the high-temperature coil label, two per spool; the carrier number and every alpha print, and any one resolves the spool | ☐ | ☐ |
| §5 | Short close as an unplanned stop, graded by weight; offer before remake | ☐ | ☐ |
| §5 | The spool always runs off | ☐ | ☐ |
| §5.1 | Mid-run coil break restarts the stop from zero | ☐ | ☐ |
| §7 | Acceptance criteria A-1 to A-11 and B-1 to B-22 as the UAT basis — ⚠ **B-13 to B-22 are untestable without a take-up scale** | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| **`G120`** | ⛔ **The gauging stands driving FL2-S3's automatic position control — are their thickness and width readings available to us as OPC tags during a run, and at what update rate?** | | ☐ |
| Q33 | Confirm that OD is **not** an input to weight — the answer inverted the question | | ☐ |
| Q10 / OI-45 | The round-edge coefficient — semicircle or partial radius | | ☐ |
| OI-75 | Stop-prompt supervisor visibility and multi-session arbitration | | ☐ |
| Q21 / OI-35 | Stop dwell value, and pause-reason suppression | | ☐ |
| OI-56 / OI-38 | **Whether any take-up scale will exist**; PIN validation source | | ☐ |
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

---

# Document Change History

> This is the client-facing deliverable's own history and is the one exception to the repository's
> single change log. Repository-wide history lives in [`CHANGELOG.md`](../../CHANGELOG.md).
> ⚠ **Versions 2.2 and 2.3 have no rows here** — they were not recorded when made, and are not
> reconstructed after the fact.

| Version | Date | Change |
|---|---|---|
| 2.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
| 2.4 | Sep 9, 2026 | **The returned client questions workbook.** ➕ **Two open items closed and became rules:** `Q18` — the customer minimum and maximum ride on the order, reusing *Max Wgt of Spool* and adding a matching minimum, and **M4 is required** (`D14`); `Q20` — only the unacknowledged 100 % milestone mirrors to the supervisor, and the acknowledgement is recorded in the existing run-event stream (`D15`, new `R-13` and `A-11`). ➕ **Four more answered:** the ladder runs at the finished-coil take-up (`D16`); the dimensional basis is **nominal** with a round-edge correction at FL1 output (`D17`); **there are no load cells anywhere** (`D18`); and the line-state output is **binary Stop/Run**, which makes §4.2's dwell the only noise filter. ⛔ **Assumption `A2` is falsified** — no weighing device exists on either line, and the only one proposed is at the FL1 *payoff*, not the take-up, so §4.5 and §7.3 are marked conditional; **no rule was withdrawn**. ⛔ **Gap `G120` raised and NOT actioned:** one clause of the client's `Q19` answer contradicts `FR-120`, and §3.1's FL2 caveat is deliberately left untouched pending one sentence back. Part C ratified in writing, both residuals standing. **A stray version row rendering as a fourth signatory line in the sign-off block was moved into this table.** |
| 2.5 | Sep 9, 2026 | **`Q19` / `G120` RE-WEIGHTED — the FL2 live-gauge evidence now runs AGAINST §3.1's caveat, and 2.4's note argued it the wrong way round.** ⭐ **The six documents that oppose the client's remark are not six assertions** — they are six restatements of **one assumption of ours**, `A3` in `[PLC §14]` (*"FL2 has no live measurement"*), for which the client-source folder holds **no supporting statement, ever**. ⛔ **And `A2`, the row directly above it in the same table, was falsified by this same mail** — `Q30`: no load cells anywhere. ⭐ **`Q1` supplies a second and stronger contradiction that was missed when `G120` was raised** — auto position control on FL2-S3 *"via the gauging stands down stream"* describes a **closed automatic-gauge-control loop**, and a stand cannot hold gauge automatically from a measurement nobody takes continuously. ⚠ **The question splits, and only half is open:** the stand almost certainly *measures* live; whether the reading is *exposed to us* as an OPC tag, and at what rate, is the real question — and §10 now asks that one instead. ⚠ **A yes is a tag-surface addition, not merely a requirement flip**: `[PLC §2]` records that FL2 has **no gauge or width tag at all** today. ⛔ **Still nothing is edited** — `FR-120` and `FR-137` are the assertions and the correction must land there first; this document only cites them. ➕ §9 `A1` now records that its exclusion of FL2 is inherited from `A3` and falls with it. **No rule, criterion or decision changed.** |
