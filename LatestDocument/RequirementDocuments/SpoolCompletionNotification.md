# Flat Wire — Spool Completion: Weight Milestone Alerts & Machine-Stop Confirmation

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 1, 2026
**Document Type:** Requirement Analysis — Real-Time Operator Notification
**Status:** Draft — Part A recorded July 28, 2026; Part B recorded July 29, 2026; **Part C (short close) recorded August 1, 2026** from the 30 Jul client call; mockup delivered; open decisions listed below

---

## Two-Part Scope

| Part | Covers | Blocking? |
|---|---|---|
| **[Part A](#purpose--scope)** | Advisory milestone alerts at **75 / 90 / 100 %** of target spool weight while the line runs | **Non-blocking** — informational, acknowledge-only |
| **[Part B](#part-b--operator-confirmation-after-the-machine-stops)** | After target is reached and the operator **physically stops the machine**, a **PLC-confirmed** popup asking whether the stop was to remove the completed spool — **Yes** runs the spool completion transaction and prints labels, **No** closes with no transaction | **Modal decision** — the machine is already stopped, so nothing is interrupted |

Part A tells the operator the spool is filling. Part B catches the moment the spool is actually finished and turns the physical act of stopping into the system transaction, so completion is never missed or double-entered.

---

## Purpose & Scope

A real-time, **non-blocking** operator notification that warns the operator that the material accumulating on the take-up is approaching the **target weight required for spool creation**, so the operator can prepare to close the spool (slow down, stage the next spool, be at the machine when it fills) instead of discovering it at 100%.

Applies to the **active run monitor** screens — Dashboard 3 (FL1), Dashboard 3 FL2, Dashboard 3 FL3 — while the line is physically running.

- **FL1 standalone** — take-up is **TKUP-1**, output is an intermediate **spool** (`SP-#####`). This is the primary case described in this document.
- **FL2 / FL3** — take-up is **TKUP-2**, output is a finished **coreless coil** (`FW-#####-C##`). The same milestone ladder applies against the coil target weight; wording changes from "spool" to "coil". See [Q61](../../Analysis/FlatWireOpenQuestions.md) before implementing.

This notification is **advisory only**. It never stops, slows, or otherwise commands the machine — consistent with the standing rule that the application is a gatekeeper, not a remote stop controller ([RodCheckout.md](RodCheckout.md), step 27 of [FlatWireProcessWalkthrough.md](../../Analysis/FlatWireProcessWalkthrough.md)).

---

## Trigger Scenario

While the flat wire machine is running, the system continuously tracks the **actual processed weight** wound onto the current take-up spool and compares it against the **target spool weight**. As the actual weight crosses defined completion milestones, the system proactively raises an on-screen notification to the operator.

```
Live telemetry (FlatWireHub)      Spool progress evaluator          Operator screen
  FootageCounter ─┐
  GaugeReading   ─┼─→ actual spool weight ─→ % of target ─→ milestone crossed? ─→ notification
  WidthReading   ─┘                                                  75 / 90 / 100
```

---

## Milestone Ladder

| # | Trigger | Banner intent | Message content | On acknowledge |
|---|---|---|---|---|
| **M1** | Actual weight ≥ **75%** of target | Informational (blue) | Spool is nearing completion — current actual processed weight, target weight, % complete | Dismiss M1; arm M2 |
| **M2** | Actual weight ≥ **90%** of target | Caution (amber) | Spool nearly full — current actual processed weight, target, % complete, remaining weight | Dismiss M2; arm M3 |
| **M3** | Actual weight ≥ **100%** of target | Target reached (green) | Target spool weight reached — actual weight at/over target, ready to close the spool | Dismiss M3; no further milestone |
| **M4** *(design addition)* | Actual weight **> 101%** of target (1% over, so the red state cannot flicker the instant target is touched) **and M3 not yet acknowledged** | Over-target (red) | Over target by *n* lb — take-up should be stopped and the spool closed | Dismiss; see [Q60](../../Analysis/FlatWireOpenQuestions.md) |

M4 is **not part of the recorded requirement**. It exists because an unacknowledged M3 keeps updating live and will therefore run past 100%; a notification that silently shows "104% of target" in a "target reached" style understates the situation. Confirm with Operations before building it (Q60).

---

## Behavior Rules

| ID | Rule |
|---|---|
| **R-1** | The notification is raised automatically by the system — no operator action initiates it. |
| **R-2** | It always displays the **current actual processed weight** and states that the machine is approaching the target spool weight. Target weight and % complete are shown alongside for context. |
| **R-3** | The operator may **acknowledge** the notification. Acknowledging dismisses it. |
| **R-4** | Acknowledging a milestone **arms the next one**: ack at 75% → next notification at 90%; ack at 90% → next notification at 100%. Acknowledging 100% ends the ladder for that spool. Acknowledging a milestone also closes every milestone **below** it — an operator who acknowledges a card that escalated straight to 90% is not then shown the 75% card. |
| **R-5** | If a notification is **not acknowledged**, it stays visible and **keeps updating with live production data** — latest actual weight, % complete, remaining weight, and derived rate/ETA — until it is acknowledged or superseded. |
| **R-6** | An unacknowledged notification is **superseded in place** when the next milestone is reached: the same notification escalates to the higher milestone (style, wording, and values all upgrade) rather than stacking a second notification. The operator is never faced with a queue of stale weight alerts. |
| **R-7** | The notification is **non-blocking**: no modal overlay, no backdrop, no focus trap, no dimming of the screen. Every other control on the active-run screen (pause, weld event, SPC, die change, WIP reject, complete run, tab switching, trace maximize) stays fully operable while it is displayed. |
| **R-8** | It must not interrupt, slow, gate, or command machine operation in any way. |
| **R-9** | Milestone state is **per spool**. When a spool is closed and a new one starts on the same run, the actual weight restarts from zero and all three milestones re-arm. |
| **R-10** | It must not obscure the **command bar** or either trace panel's **header and live reading** — the values an operator watches continuously. The bottom-right corner placement overlaps only the lower plot area of the right-hand (secondary) trace, and clears on acknowledgement. After acknowledgement a compact progress indicator remains so the operator retains passive visibility of spool fill without a second alert. |
| **R-11** | Acknowledgement is an **audited event** — operator, milestone, actual weight at acknowledgement, and timestamp are persisted against the run (see [Q62](../../Analysis/FlatWireOpenQuestions.md)). |
| **R-12** | Milestone thresholds (75 / 90 / 100) are **configuration, not constants** — table-driven so Operations can tune them without a release. |

---

## Data Requirements

### Actual processed weight (the value shown)

Weight wound onto the current take-up spool since the spool started. Derived from the live footage counter and the measured cross-section:

```
lb per ft   = gauge (in) × width (in) × 12 (in/ft) × alloy density (lb/in³)
spool weight = (current footage − footage at spool start) × lb per ft
```

Worked example — the FL1 case shown in the mockup, alloy 1100 (0.098 lb/in³), gauge 0.110″, width 0.625″:

```
0.110 × 0.625 × 12 × 0.098 = 0.0809 lb/ft  →    900 lb target ≈ 11,130 ft   (customer max)
                                                1,800 lb spool  ≈ 22,250 ft   (two finished coils)
```

> The **2,000 lb figure this example previously used is withdrawn** (30 Jul 2026) — see the target-weight basis below. The arithmetic is unchanged; only the target it is applied to.

The OD-based verification formula for spool weight is still outstanding — **[Q58](../../Analysis/FlatWireOpenQuestions.md)** — and this notification depends on whichever weight source that decision lands on. Until then, footage × density factor (the same basis used for coil net weight at Dashboard 7) is the working assumption.

### Target spool weight (the comparison basis)

> **Basis decided (30 Jul 2026) — the customer weight range. The 2,000 lb default is withdrawn.** Tim and Bob confirmed the customer specifies a **minimum and maximum weight** (figures given: **900 lb max / 800 lb min**) and completion is graded against **that range, by weight** — not by footage, and not against an assumed default. **Spools are sized at roughly 1,800 lb** so that **two finished coils** can be cut from one spool at FL2, which is where the ~900 lb figure comes from. Still open (**Q60**): *which order field* carries the customer min/max, and whether the ladder still escalates to a distinct over-target state.

| Candidate source | Value | Notes |
|---|---|---|
| **Order — customer min/max weight** | **e.g. 800–900 lb** | **The basis.** Customer-specified range on the order; completion is graded against it |
| Spool sizing | ~**1,800 lb** | Two ~900 lb finished coils per spool, cut at FL2 |
| Equipment capacity — TKUP-1 | 3,500 lb | Hard equipment ceiling ([Spool.md](../../Analysis/Spool.md)) |
| Equipment capacity — TKUP-2 | 1,100 lb | FL2/FL3 finished-coil ceiling. The customer maximum is typically **below** it, so the customer value governs rather than the cap |
| ~~Order *Max Wgt of Spool* default~~ | ~~**2,000 lb**~~ | **Withdrawn 30 Jul 2026.** It was an assumption made 29 Jul, it has no basis, and it exceeds the TKUP-2 ceiling. **Remove from the mockup and `spool_notification.js`** |

### Real-time plumbing

Uses the existing `FlatWireHub` stream described in [`../DevelopmentPlan/ShopfloorPlan/00-foundations.md`](../../DevelopmentPlan/ShopfloorPlan/00-foundations.md) §0.4 — `FootageCounter`, `GaugeReading`, `WidthReading` already broadcast per line group (`FL1Data` / `FL2Data` / `FL3Data`). Two additions are needed:

1. A **derived spool-progress payload** (actual weight, target weight, percent, remaining, rate, ETA) so every subscribed client evaluates the same number rather than each computing its own.
2. A **milestone event** (`SpoolWeightMilestone`) carrying line, run, spool, milestone (75/90/100), actual weight, and target — raised server-side on crossing, so the milestone is a fact on the run record and not a client-side coincidence.

**FL2 caveat:** FL2 standalone broadcasts `null` live gauge/width (its trace is historical/profile). Its target comparison must therefore use the pass-schedule/order gauge and width for the lb/ft factor, not live measurement.

### PLC tags monitored (Part B)

| Tag | Use | Status |
|---|---|---|
| `FL{n}.LineState` | The machine status tag the popup is conditioned on. Prompt fires on the `RUNNING → STOPPED` **transition**, held for the dwell. | Existing — already read as the rod-checkout gatekeeper. State vocabulary undocumented (**Q63**) |
| `FL{n}.SpeedFPM` | Corroboration that the line is genuinely stopped (≈ 0), so a stale state bit alone cannot fire the prompt | Existing (broadcast as `SpeedFPM`) |
| `FL{n}.FootageCounter` | Source of the latched weight at the stop timestamp | Existing |

New hub events for Part B, raised server-side so the prompt is auditable and survives a client refresh:

- `SpoolCompletionPromptDue` — line, run, spool alpha, PLC stop timestamp, latched weight, target weight.
- `SpoolCompletionPromptResolved` — answer (`Yes` / `No` / `AutoDismissed`), operator, timestamp — also the audit record's payload.

---

## UI Specification (as built in the mockup)

**Mockup:** [`../Mockups/spool_notification.js`](../../Mockups/spool_notification.js) — shared drop-in component, wired into [`../Mockups/dashboard_3_active_run_v2.html`](../../Mockups/dashboard_3_active_run_v2.html).

| Element | Spec |
|---|---|
| Placement | Fixed bottom-right card, ~400 px wide, above the command bar. No overlay, no backdrop. |
| Milestone header | Colored strip + milestone badge (`75%` / `90%` / `100%`) and title: *Spool nearing completion* / *Spool nearly full* / *Target spool weight reached*. |
| Primary reading | Actual processed weight, large mono, with `/ target lb` beneath it — the requirement's mandated value. |
| Progress bar | Fill = % of target, with tick marks at 75 / 90 / 100 so the operator sees where the current milestone sits on the ladder. |
| Live secondary data | Percent complete, remaining lb, spool footage, fill rate (lb/min), estimated time to target, and a "Live · updated *hh:mm:ss*" line with a pulsing dot. All refresh while unacknowledged (R-5). |
| Action | Single primary button — **Acknowledge**. No other action is offered; the notification is informational and the operator's real work happens on the screen behind it. |
| Escalation | Supersede animates the card (pulse + color change) in place — never a second card (R-6). |
| Post-acknowledge | The card collapses to a small docked pill showing live `Spool nn% · n,nnn / n,nnn lb` with a check mark. It re-expands automatically at the next milestone. |
| Accessibility | `role="status"` + `aria-live="polite"` so updates are announced without interrupting; the pill is a labelled button; Escape does **not** dismiss (acknowledgement must be deliberate). |
| Color mapping | 75% info blue · 90% warning amber · 100% success green · over-target danger red — all from the existing semantic tokens; no new colors. |

The mockup includes a clearly-labelled **demo control strip** (bottom-left) to jump the simulated weight to just below/above each milestone. That strip is a mockup-only affordance and is not part of the requirement.

---

## Part B — Operator Confirmation After the Machine Stops

### Requirement as recorded (July 29, 2026)

Once the flat wire machine reaches the **target spool weight** and the operator **physically stops the machine**, the system monitors the corresponding **PLC machine status tag**. When the PLC confirms the machine has stopped, the system displays a confirmation popup asking whether the machine was stopped **to remove the completed spool and perform the spool completion transaction, including label printing**.

- **Yes** — the stop was to remove the completed spool. The system proceeds with the spool completion workflow, performs the transaction, and prints the spool labels.
- **No** — the stop was for a different reason. The popup closes; **no** completion transaction and **no** label printing.

The popup is displayed **only** after the PLC confirms the transition to the **stopped** state.

### How this is handled — analysis

The requirement is a two-condition gate on an **edge**, not a state, and the whole design hinges on that. A physically stopped line is an extremely common condition on FL1 (die change, weld prep, break, shift change, blockage), so the prompt must be armed by weight *and* fired by a transition *and* filtered for noise, or it becomes the alert operators learn to dismiss reflexively.

**1. Arming condition (weight).** The prompt is armed only while `actual spool weight ≥ target spool weight` for the current spool — the same latched value Part A's M3 milestone uses. Below target, a stop raises nothing.

**2. Firing condition (PLC edge).** The prompt fires on the **`RUNNING → STOPPED` transition** of the line state tag, not on the level. Reading the level would re-raise the popup on every poll for as long as the line sits stopped. One prompt per stop event, tracked by a handled-flag that clears when the line returns to RUNNING.

**3. Which tag.** `FL{n}.LineState` — the tag the system already reads as the gatekeeper for rod checkout ([RodCheckout.md](RodCheckout.md), step 27 of [FlatWireProcessWalkthrough.md](../../Analysis/FlatWireProcessWalkthrough.md)). Reusing it keeps one authority for "is the line running". `FL{n}.SpeedFPM ≈ 0` is read as corroboration so a stale or mis-scaled state bit alone cannot fire the prompt. The exact state vocabulary of that tag (`RUNNING / STOPPED / PAUSED / FAULT / THREADING`?) is not yet documented — **Q63**.

**4. Noise filter (dwell).** Lines momentarily read zero speed during threading, jogging, and slow-downs. The state must hold **STOPPED continuously for a configurable dwell (default 5 s)** before the prompt fires. Without this, a jog at 100 % pops a spool completion dialog in the operator's face mid-adjustment.

**5. Latched weight.** The actual weight is **frozen at the PLC stop timestamp** and that latched value — not a value that keeps drifting afterward — is what the popup shows and what the completion transaction and label use. This matters because the footage counter can tick a little after the drives stop.

**6. Server-owned, not browser-owned.** The evaluator watching the tag lives server-side in the `FlatWire` service, alongside the Part A milestone evaluator. It raises a **pending prompt** that is persisted against the run and pushed over `FlatWireHub`. Consequences: the prompt survives a browser refresh or the operator switching screens; it can be targeted at the line's operator session(s); and both the raise and the answer are auditable. A purely client-side popup would be lost on refresh, exactly when an operator is most likely to reload a screen that "looks stuck".

**7. Suppression when the reason is already known.** If the operator used the software **Pause** dialog immediately before stopping — which already captured a reason (die change, weld prep, break…) — the system knows why the line stopped and asking again is noise. Working rule: suppress the prompt if an open `RunPauseEvent` exists whose reason is not spool removal. Needs confirmation — **Q63**.

**8. What "No" must not do.** No transaction, no print — and equally, no dead end. An operator can legitimately answer No and then decide five minutes later to close the spool. So No must not be the only path: a **manual "Complete spool" entry point** stays available on the docked progress pill whenever weight ≥ target. The prompt is a convenience over that path, never the only door to it.

**9. What "No" also should not do.** Nag. After No, the prompt does not re-fire for the *same* stop event; it re-arms only on the next `RUNNING → STOPPED` transition.

**10. Line restarts while the popup is open.** The answer is implicitly "no, still producing". Auto-dismiss the popup, log it as system-dismissed with reason `line resumed`, and re-arm. Leaving a spool completion dialog open over a running line invites completing a spool that is still being wound.

**11. Yes is an entry point, not a bypass.** The spool completion workflow keeps its own gates — per-spool SPC for gauge and width is mandatory before a spool alpha is issued (step 29 of the walkthrough). Answering Yes routes into that workflow; it does not skip validation, and it does not print a label before the transaction commits.

**12. Over-target stops.** If the operator stops at 104 % (Part A milestone M4 territory), the same prompt fires with the latched over-target weight, and the completion summary flags the overage rather than silently accepting it.

**13. PLC comms loss.** No tag, no confirmation, no prompt — by design, since the requirement conditions the popup on PLC confirmation. The manual "Complete spool" path is the fallback, and OPC health is already visible on Dashboard 1.

**14. Multiple operator sessions.** The topbar supports several signed-in operators per screen. One prompt per line; the first answer wins; the answering operator is recorded on the audit record. Whether the prompt should also appear on the supervisor view is **Q64**.

**15. The calculated weight is a derivation, not a measurement.** `footage × gauge × width × 12 × density` inherits every error in its inputs — counter slip, gauge/width drift between SPC checkpoints, and an assumed alloy density. The physical scale is the only ground truth available at the take-up, so the completion step **must be able to capture it** and must not quietly commit a derived number when a measured one exists. This is also the mechanism that finally answers **Q58**: accumulate scale-vs-calculated variances and the density factor and the OD formula can both be validated against real data.

**16. Scale readings are gross; the record needs net.** The loaded spool goes on the floor scale, so what the operator reads is gross. Net = gross − spool tare, and the tare must be shown while they type so the arithmetic is never done in their head. This mirrors rod receiving, which already captures gross and net and validates scale-vs-vendor weight ([FlatWirePlan.md](../../Analysis/FlatWirePlan.md)).

**17. Which weight wins is the operator's call, but not a blind one.** The system pre-selects the scale reading once entered — a weighing outranks a derivation — and shows the variance in lb and % before the choice is made. Both figures are persisted whichever is chosen: the discrepancy itself is the useful data.

**18. An out-of-tolerance variance must not strand the spool.** *(Client direction, July 29 2026.)* The physical spool is finished and sitting on the take-up — a screen that refuses to create it just moves the problem off-system, and the operator ends up completing it later from memory or not at all. So the variance is **authorised rather than blocked**: the commit control stays live and a **supervisor override** appears. This is the same authority model already confirmed for mid-run rod checkout, where a supervisor approves rather than the software refusing. The override is what makes the exception *visible* — flag, authorising supervisor, reason, both weights and the variance all land on the spool record, so accepting an odd weight is a traceable decision instead of a silent one. The PIN authenticates and is never stored. When no supervisor is on the floor, the remote-approval path (Q50's notification model) is offered, and even that does not freeze the screen.

### State machine

| State | Entered when | Exits to |
|---|---|---|
| `IDLE` | Weight < target | `ARMED` when weight ≥ target |
| `ARMED` | Weight ≥ target, line RUNNING | `PENDING` on PLC `RUNNING → STOPPED` held for the dwell; back to `IDLE` on new spool |
| `PENDING` | PLC stop confirmed, weight latched, popup displayed | `COMPLETING` on **Yes** · `DECLINED` on **No** · `ARMED` if line returns to RUNNING (auto-dismiss) |
| `COMPLETING` | Operator answered Yes | `COMPLETED` when the transaction commits and labels print → resets to `IDLE` for the next spool |
| `DECLINED` | Operator answered No | `ARMED` (re-arms for the next stop edge); manual completion still available |

### Behavior rules

| ID | Rule |
|---|---|
| **S-1** | The popup is displayed **only** after the PLC confirms the line has transitioned to STOPPED — never on a software-side assumption, never before the tag confirms. |
| **S-2** | Both conditions must hold: weight ≥ target **and** a confirmed stop edge. A stop below target raises nothing. |
| **S-3** | STOPPED must persist for the configured dwell (default **5 s**) with speed ≈ 0 before the popup is displayed. |
| **S-4** | The displayed weight is **latched at the PLC stop timestamp** and is the value used by the transaction and the label. |
| **S-5** | Exactly **one** popup per stop event. It does not re-raise while the line remains stopped. |
| **S-6** | **Yes** → spool completion workflow: transaction committed, spool alpha finalized, spool labels printed. |
| **S-7** | **No** → popup closes. No transaction, no alpha finalization, no label printing, no state change to the spool. The decline is logged. |
| **S-8** | If the line returns to RUNNING while the popup is open, the popup auto-dismisses as `line resumed` and re-arms. |
| **S-9** | The pending prompt is **server-owned state** — it survives browser refresh and screen navigation, and is re-delivered on reconnect. |
| **S-10** | Escape / click-outside do **not** dismiss the popup; the operator must answer Yes or No. There is no close (×) affordance on the question step. |
| **S-11** | Labels print **only** after the completion transaction commits — never on opening the popup, never on Yes alone if the transaction fails. |
| **S-12** | Both outcomes are audited: prompt raised (PLC stop timestamp, latched weight), answer (Yes/No), answering operator, and answer timestamp. |
| **S-13** | A manual **Complete spool** entry point remains available whenever weight ≥ target **and the PLC reports the line not running** — a spool cannot be removed from a turning take-up, and the same gatekeeper rule that blocks rod checkout on a running line applies here. It is independent of the prompt, so a declined prompt is never a dead end. |
| **S-14** | Dwell time and the arming threshold are configuration, not constants (consistent with **R-12**). |
| **S-15** | Each choice must state its **consequence** on the control itself, not in surrounding prose — the operator is deciding at the machine, often briefly. **Y** / **N** keyboard answers are provided and advertised on the choices. |
| **S-16** | The completion step must offer the operator a **scale weight** entry. It is **optional** — with nothing entered the system-calculated weight is recorded and the step behaves as before. |
| **S-17** | The scale reading is entered as **gross**; the system derives **net = gross − spool tare** and reconciles that against the calculated net, showing the variance in **lb and % of calculated**. |
| **S-18** | The operator explicitly chooses **which weight is recorded** — scale or system-calculated. A scale reading is **pre-selected** once entered (a physical weighing outranks a derived figure) but the operator can override back to calculated. The choice is never made silently for them. |
| **S-19** | The chosen basis governs the **spool record, the label, and everything downstream** (planning allocation, certs). The label prints the recorded weight, not the other one. |
| **S-20** | Variance beyond a configurable tolerance (**default ±2 %**) is flagged but **does not stop the operator from creating the spool**. The completion is **authorised, not prevented**: a **supervisor override** appears and the commit control stays enabled throughout — it is never disabled by the variance. *(Client direction, July 29 2026.)* |
| **S-22** | The override captures the **variance reason**, the **supervisor badge/ID** and a **PIN**. The PIN authenticates only — it is never carried in the payload or stored. Pressing complete with the override incomplete flags exactly the missing fields and focuses the first one; it does not commit, and it does not lock the operator out. |
| **S-23** | When no supervisor is on the floor, a **Request remote approval** action notifies the supervisor — the notification-driven approval model already confirmed for mid-run checkout ([Q50](../../Analysis/FlatWireOpenQuestions.md)). Requesting does not block or change the screen state; the operator can still take an on-floor override the moment one is available. |
| **S-24** | An overridden completion is **marked on the spool record** — override flag, authorising supervisor, reason, both weights and the variance — and the result step states it plainly so the next person sees the spool was accepted out of tolerance. Both weights, the variance, the chosen basis and any reason are persisted regardless of which weight won. |
| **S-25** | If the variance is brought back inside tolerance (a re-weigh, a corrected entry), the override requirement **disappears** and the completion proceeds normally with nothing recorded against it. |
| **S-21** | The scale reading is **retained on the record even when the operator selects calculated** — the discrepancy is the evidence needed to validate the density factor and the scale. |

### Edge cases and their handling

| Scenario | Handling |
|---|---|
| Stop at 60 % for a die change | No prompt — not armed (S-2) |
| Momentary zero speed / jog / threading at 100 % | Filtered by the dwell (S-3) |
| Software Pause with a reason logged, then stop | Prompt suppressed — reason already known (Q63) |
| Operator answers No, later removes the spool anyway | Manual **Complete spool** on the progress pill (S-13) |
| Line restarted with the popup open | Auto-dismiss `line resumed`, re-arm (S-8) |
| Popup left unanswered (operator away from the HMI) | Persists — it is a decision, not an alert; machine is stopped so nothing is blocked |
| Browser refreshed / operator switched screens | Pending prompt re-delivered from server state (S-9) |
| Two operators signed in on the line | One prompt, first answer wins, answering operator recorded (Q64) |
| Footage ticks on after the drives stop | Latched weight is authoritative (S-4) |
| Stop at 104 % of target | Same prompt; overage flagged on the completion summary (analysis 12) |
| OPC / PLC comms down | No prompt; manual path is the fallback (analysis 13) |
| Yes, but per-spool SPC not yet recorded | Completion workflow enforces its own gate; prompt is an entry point only (S-11, analysis 11) |
| Operator stops short of target intending to close the spool early | **Specified 30 Jul 2026 — an unplanned stop, not a silent manual action.** See *Short close* below (**Q65**, decided) |

### Short close — closing a spool below target (Part C, decided 30 Jul 2026)

The milestone ladder and the stop prompt are both armed **at or above target**, so a spool the operator closes **early** — order satisfied, rod exhausted, quality problem, end of campaign — previously fell outside the requirement entirely. It does not any more.

**A short close is an unplanned stop**, handled on the pattern of the mill **10-90 SOP**, with an unplanned-stop reason code.

| Rule | Behaviour |
|---|---|
| **Grading basis** | The **customer min–max weight**, by weight — not footage, not a fixed target (see *Target spool weight* above) |
| **Inside the range** | **Continue.** If the short weight still yields the finished coils the order requires, nothing escalates |
| **Outside the range** | **Flagged.** Either a **supervisor override plus a production hold**, or the piece is **offered to the customer under concession** before a remake is planned. Shannon's direction is explicit: **offer first**, remake last |
| **The spool still runs off** | **Always.** FL2 has **no spool stripper**, so the spool must be emptied and returned to FL1 whatever happens to the material on it. "Reject it" is never "stop and remove it" |

**Mid-run coil break** — related, and a different rule from the above: the stop is **removed and a new stop starts from zero**. Weight does **not** resume from the break point. The leftover incoming material is **welded to the next coil on FL1**; on FL2 it is either run to a finished stop and offered to the customer, or scrapped.

> **Two cautions before this is built.**
>
> 1. The **10-90 SOP document is not in this repository.** It must be obtained from Operations and cited — the pattern above is the call summary, not the SOP.
> 2. The restart-from-zero rule is a **run/stop model** change, not a screen rule. Check it against `FlatWireRun` / `CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage before implementing — run events use **cumulative run footage** and coil traceability uses **coil-local** footage, and the offset between them is still undefined (**OI-25**).


### UI specification (as built in the mockup)

| Element | Spec |
|---|---|
| Type | Centered modal on the `.gb-modal` shell, **840 px**, with its own identity band in place of the standard head. Modal is acceptable here because the machine is already stopped. |
| No scrolling | The dialog **must never scroll** — an operator at the machine should take in the whole decision at once. `max-height` is released and the body's `overflow` is `visible` on this dialog, and step 2 is laid out to fit: roughly **520 px** normally and **700 px** with the override panel open, against ~900 px available on the 1280 × 1024 shopfloor screen. |
| Step 2 layout | **Two columns**, not one tall stack: left (1.3 fr) the **weight verification** panel — calculated / scale / variance, tolerance strip, basis choice, "Will record" — and right (1 fr) the **identity of what is being committed** — spool alpha, footage, gauge, width, source rods, weld point — with the label strip beneath it. The **supervisor override spans the full width below both columns** so its three fields stay on one row. Actions last. The standing note about SPC being enforced by the completion workflow was dropped from the screen to make room; it survives as rule **S-11**, and the label strip now carries the *"after the transaction commits"* clause. |
| Layout principle | **Decision first, evidence last.** The band states what happened and shows the one number that matters; the body asks the question once in the largest type on screen; the PLC provenance sits at the bottom as a quiet footer instead of competing with the question. The earlier draft led with the tag readout and buried the question in 14 px body text — wrong priority for an operator reading at arm's length. |
| Step 1 — identity band | Solid color band, white text: state icon, title (*"Target spool weight reached — machine stopped"*, or *"Over target spool weight — machine stopped"* in red), `FL1 · TKUP-1 · SP-00031` sub-line, and the **latched weight as a 33 px hero** with `of 2,000 lb target · 100%` beneath it. Tone: green at target, **red** over target, blue on the confirm step. |
| Step 1 — the question | One 17 px line: *"Was the machine stopped to remove the completed spool?"* with a 13 px clarifier: *"Confirming runs the spool completion transaction and prints the spool labels."* Stated **once** — no restatement in the title. |
| Step 1 — the two choices | Two **full-width, 78 px-tall choice rows** (the `outcome-option` pattern already used by the Pause/Resume dialog), each with an icon, a 16 px title, and its **consequence spelled out**: Yes → *"Completes SP-00031 at 2,014 lb net, records the transaction and prints 2 labels"*; No → *"Nothing is recorded — no transaction, no alpha, no labels. The spool stays open and can be completed later."* Expected answer on top. Gloved-hand targets, hover-tinted green (Yes) / gray (No), and each row prints its keyboard key. |
| Step 1 — keyboard | **Y** and **N** answer the question, advertised as key chips on the rows. Escape is deliberately unbound and there is no × (**S-10**). |
| Step 1 — over-target | Red inline warning between question and choices: *"Over target by n lb — the overage is recorded on the spool completion record."* |
| Step 1 — evidence footer | Quiet 11.5 px line above nothing else: green dot, `FL1.LineState = STOPPED`, `held 5s · 0 FPM`, `Stopped 14:32:07`, spool alpha. This is why the popup appeared — provenance, not the headline. |
| Step 2 — completion summary *(Yes only)* | Header reads *"Confirm spool completion"*. Opens with the **weight verification** block (below), then the identity summary — spool alpha, latched footage, gauge and width, source rod alphas with the weld point — and the label set (copies + printer). Actions: **Back** · **Complete spool & print labels**. |
| Step 2 — weight verification | Three columns: **System calculated — net** (with `24,900 ft × 0.0809 lb/ft` shown as its derivation), **Scale weight — gross** (a 42 px numeric input with `− tare 120 lb = net …` resolving live beneath it), and **Variance vs calculated** (lb, plus `±n.nn % of calculated`). A tolerance strip appears once a reading exists: success-tinted *"Within the ±2 % tolerance"*, or danger-tinted, naming the overage and telling the operator to check the scale and the gauge/width used in the calculation — the same tint treatment the existing over-target and label-print strips use. |
| Step 2 — "Will record" strip | A **flowing sentence**, not a flex row: *"Will record **1,885 lb** net · **2,005 lb** gross · basis **Scale weight** — this is what prints on the label."* (`display:flex` here put every value on its own line, because each `<strong>` and each bare text run becomes a separate flex item.) |
| Step 2 — which weight to record | The question *"Which weight should be recorded for this spool?"* over **two radio cards** — **Scale weight** (*"Physically weighed — overrides the calculation"*) and **System calculated** (*"Footage × cross-section × density"*), each showing its net figure. The scale card is disabled until a reading is entered, then auto-selected; either can be chosen. A **"Will record …"** strip below states the resulting net, gross and basis, and notes that this is what prints on the label. |
| Step 2 — out-of-tolerance override | Beyond ±2 %, a **supervisor override panel** appears — heading *"Supervisor override to proceed"*, a line stating the spool **can still be created**, then three fields on one row: **Reason for the variance** · **Supervisor badge / ID** · **PIN**. Below them, **"No supervisor on the floor? Request remote approval"** with a timestamped confirmation once pressed. The commit button **stays enabled** and relabels to **"Override & complete spool"**. Pressing it with fields empty outlines the missing ones, shows *"Required for the override"*, and focuses the first — never a disabled dead end. Within tolerance the panel is absent entirely. |
| Step 3 — weight basis | The committed result adds a **Weight basis** row (*Scale weight* / *System calculated*) so the record shows which figure was used. |
| Step 3 — result | Band turns green, *"Spool completed"*. Committed facts (alpha, net, gross, commit time), a green label-print confirmation line, and a note that the spool is ACTIVE for planning and the ladder has re-armed for the next spool (**R-9**). |
| Declined | Dialog closes; the docked progress pill shows `target reached` with a **Complete spool** button as the manual path. |
| PLC state visibility | The line badge switches to *"FL1 stopped (PLC)"* with a static gray dot while the simulated tag reads STOPPED, the Machine card head flips *Running → Stopped*, and weight accumulation halts. |
| Host-screen readout | Dashboard 3's Machine card carries a live `Spool SP-00031 · 1,460 / 2,000 lb` line (`#fw-spool-lb` / `#fw-spool-target`) — **the target here is the withdrawn 2,000 lb default and must be re-pointed at the customer max (W5)** that the component keeps in step, so the screen and the notification never disagree. |
| Mockup demo controls | The demo strip adds **■ stop** / **▶ start** buttons that drive the simulated `FL{n}.LineState`, so the dwell, the prompt, the auto-dismiss-on-restart, and the below-target silence are all reviewable. Mockup-only. |

### Acceptance criteria — Part B

11. With weight below target, stopping the machine raises no popup.
12. With weight at or above target, stopping the machine raises the popup only after the PLC state has read STOPPED for the dwell period.
13. A momentary stop shorter than the dwell raises no popup.
14. The popup shows the weight latched at the stop timestamp; that value does not drift while the popup is open.
15. Answering **No** closes the popup with no transaction, no alpha finalization, and no label print, and logs the decline.
16. Answering **Yes** routes into the spool completion workflow; labels print only after the transaction commits.
17. The popup does not re-raise while the line stays stopped; it re-arms on the next running→stopped transition.
18. Restarting the line with the popup open auto-dismisses it and logs `line resumed`.
19. Escape and click-outside do not dismiss the question step.
20. After a completed spool, the Part A milestone ladder re-arms from zero for the next spool.
21. A pending prompt survives a browser refresh and is re-delivered.
22. The manual **Complete spool** path is available whenever weight ≥ target and the line is not running, including after a No; it is hidden while the line runs.
23. With no scale weight entered, the completion commits the **system-calculated** weight and no reason is requested.
24. Entering a gross scale reading resolves **net = gross − tare** and shows the variance in lb and % of calculated within the same interaction.
25. A scale reading below the spool tare, blank, or non-numeric is **rejected** — the variance clears and the basis falls back to calculated.
26. A variance inside ±2 % shows the within-tolerance state and commits with no override asked for.
28. A variance beyond ±2 % **never disables the commit control** — the supervisor override panel appears and the button relabels to *"Override & complete spool"*.
29. Pressing complete with an incomplete override flags exactly the missing fields, focuses the first, and commits nothing; supplying reason + supervisor + PIN completes the spool and prints the labels.
30. An overridden completion records the override flag, the authorising supervisor and the reason, states it on the result step, and never puts the PIN in the payload.
31. Requesting remote approval notifies the supervisor and logs it without changing what the operator can do next.
32. Correcting the variance back inside tolerance removes the override requirement, and the completion then records no override.
27. The recorded net, gross and **weight basis** follow the operator's choice, appear on the result step, and are what the label prints. Both weights, the variance, the basis and any reason are written to the audit record even when calculated is chosen over an entered scale reading.

---

## Acceptance Criteria — Part A

1. With the line running and actual weight below 75% of target, no notification is shown.
2. Crossing 75% raises the notification within one telemetry tick, showing actual processed weight, target, and percent.
3. The notification never blocks the screen — all Dashboard 3 controls remain usable while it is displayed, verified by interacting with each command-bar action.
4. Leaving it unacknowledged updates the displayed actual weight and percent on every telemetry tick.
5. Acknowledging at 75% dismisses it; nothing reappears until 90%.
6. Acknowledging at 90% dismisses it; nothing reappears until 100%.
7. Reaching 90% (or 100%) with the previous milestone unacknowledged escalates the existing notification in place — exactly one notification is ever on screen.
8. Acknowledging at 100% dismisses it and no further milestone notification is raised for that spool.
9. Each acknowledgement writes an audit record with operator, milestone, actual weight, and timestamp.
10. Closing a spool and starting a new one on the same run re-arms all three milestones from zero.

---

## Open Decisions Raised by This Requirement

Registered in [FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) as **Q60–Q65**:

- **Q60** — Target spool weight source (order *Max Wgt of Spool* vs take-up capacity), default value, and whether over-target (M4) behavior is required.
- **Q61** — Does the same ladder apply to finished coils at TKUP-2 on FL2/FL3, and does FL2's `null` live gauge/width change the weight basis?
- **Q62** — Is the notification mirrored to the supervisor (Dashboard 1 / Operations Manager), and where does the acknowledgement audit record live?
- **Q63** — `FL{n}.LineState` state vocabulary and stop-dwell value; and should the popup be suppressed when a software Pause has already captured a reason?
- **Q64** — Does the stop-confirmation popup also surface to the supervisor, and how are multiple signed-in operator sessions arbitrated?
- ~~**Q65** — Is there a **short-close** path?~~ **DECIDED 30 Jul 2026** — see *Short close* below.
- **Q66** — Scale-vs-calculated weight: variance tolerance (±2 % proposed), which weight is the default basis, whether out-of-tolerance needs supervisor approval rather than just a reason, and whether a scale exists at the take-up at all.

Dependent on the already-open **Q58** (OD → weight conversion formula) for the authoritative weight source.

**Gap:** there is no mockup for the FL1 **spool completion** screen itself (Dashboard 7 covers finished-coil completion at TKUP-2, not the TKUP-1 spool). Part B's Yes path is mocked as a compact completion summary + label print inside the dialog, standing in for that screen. The real workflow — per-spool SPC gate, alpha finalization, label content per step 30 of the walkthrough — needs its own screen.

---

## Related Documents

| Document | Relevance |
|---|---|
| [Spool.md](../../Analysis/Spool.md) | Spool lifecycle, TKUP-1 capacity, "spool complete" definition |
| [FlatWireProcessWalkthrough.md](../../Analysis/FlatWireProcessWalkthrough.md) | Steps 28–30 (spool at TKUP-1), step 37 (coil at TKUP-2) |
| [FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md) | Dashboard 3 active-run specification this notification overlays |
| [FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) | Q58, Q60–Q62 |
| [`../DevelopmentPlan/ShopfloorPlan/00-foundations.md`](../../DevelopmentPlan/ShopfloorPlan/00-foundations.md) | §0.3 domain cheat-sheet, §0.4 real-time architecture (`FlatWireHub`) |
| [`../DevelopmentPlan/ShopfloorPlan/phase-05-active-run-monitoring-gauge-trace.md`](../../DevelopmentPlan/ShopfloorPlan/phase-05-active-run-monitoring-gauge-trace.md) | Phase that owns the active-run screen and its telemetry |
| [`../Mockups/spool_notification.js`](../../Mockups/spool_notification.js) | Delivered mockup component |

---

## Change Log

| Date | Changed By | Description |
|------|-----------|-------------|
| July 28, 2026 | Analysis Team | Initial document — spool completion alert requirement recorded: 75 / 90 / 100 milestone ladder, acknowledge-to-arm-next behavior, live update while unacknowledged, supersede-in-place, non-blocking constraint. Data requirements, UI spec as mocked, acceptance criteria, and Q60–Q62 captured. |
| July 29, 2026 | Analysis Team | Default target spool weight assumed **2,000 lb** (was 1,200 lb from the sample order). Worked footage example, target-source table, Q60 wording, and the mockup (component default + Dashboard 3 order row) updated. Milestone percentages unchanged. |
| July 29, 2026 | Analysis Team | **Machine-stopped popup redesigned** for shopfloor legibility: colored identity band with the latched weight as the hero figure (green / red over-target / blue on confirm), the question asked once in 17 px, two full-width 78 px choice rows with consequences printed on each control, Y/N keyboard answers, and the PLC evidence demoted to a footer. Step 3 simplified to committed facts + print confirmation. Rule **S-15** added; UI spec table rewritten. |
| July 29, 2026 | Client direction | **Dialog must not scroll.** Widened to **840 px** and step 2 relaid as **two columns** (weight verification ¦ identity + label) with the supervisor override full-width beneath; `max-height` released and body `overflow:visible`; inner spacing tightened and the redundant SPC note dropped from the screen. Step 2 now ~520 px, ~700 px with the override open. |
| July 29, 2026 | Client direction | **Out-of-tolerance weight no longer blocks spool creation.** The reason-required gate that disabled the commit button is replaced by a **supervisor override** (variance reason + supervisor badge/ID + PIN, PIN never stored) with a **remote-approval fallback** when no supervisor is on the floor. The commit control is never disabled by the variance; it relabels to *"Override & complete spool"*, and an incomplete override flags and focuses the missing fields instead of dead-ending. Overridden completions are marked on the spool record and stated on the result step. Rules **S-20 rewritten, S-22…S-25 added**, analysis item 18, acceptance criteria **28–32**, UI spec row rewritten. **Q66 part 3 Decided**; PIN validation source still open. |
| July 29, 2026 | Analysis Team | **Scale weight added to the completion step.** Operator can enter the scale reading (gross); the system derives net from the spool tare, reconciles it against the calculated net (variance in lb and % of calculated), and **asks which weight to record** — scale pre-selected once entered, overridable to calculated. Variance beyond a configurable ±2 % is flagged and requires a reason before commit. Chosen basis governs the record, the label and everything downstream; both weights plus the variance, basis and reason are audited. Rules **S-16…S-21**, acceptance criteria **23–27**, UI spec rows and **Q66** added. Fixed the "Will record" strip rendering one value per line (`display:flex` split every text run into a flex item). |
| July 29, 2026 | Analysis Team | Added **Part B — operator confirmation after the machine stops**: PLC-confirmed `RUNNING → STOPPED` edge trigger with dwell filter, latched weight, Yes → spool completion transaction + label print, No → close with no transaction. 14-point handling analysis, state machine, rules S-1…S-14, edge-case table, UI spec, acceptance criteria 11–22, PLC tag/hub-event requirements, and **Q63–Q65**. Doc retitled to cover both parts. |
| Aug 1, 2026 | Client sync (30 Jul call) | **Part C added — the short close is specified, and the target basis changed.** The **2,000 lb default target is withdrawn**: completion is graded against the **customer min–max weight** (e.g. 900 max / 800 min), with spools sized ~1,800 lb so two finished coils can be cut at FL2 (**Q60** basis decided; the source field is still open). A short close is an **unplanned stop** on the mill **10-90** pattern with a reason code — inside the range continue, outside it a **supervisor override + production hold** or an **offer to the customer under concession** before any remake, and **the spool is run off either way** because FL2 has no spool stripper (**Q65** decided). Recorded the mid-run coil-break rule: the stop is removed and a **new stop starts from zero**, with the leftover welded to the next coil on FL1 or run off and offered/scrapped on FL2 — flagged as a run/stop model change to be checked against **OI-25** rather than implemented as a screen rule. The **10-90 SOP itself is not in the repository** and must be obtained. |
