# Flat Wire Processing — FL2 Spool Queue Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL2 spool selection, ahead of spool check-in
**Version:** 1.2
**Last Updated:** August 12, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 5A — FL2 Spool Queue
**Requirement source:** `FR-097`–`FR-099`; check-in identifier rule `CHK012`; spool lifecycle question **Q17**

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.1 | Aug 2, 2026 | **Two statuses, one spool at a time.** You confirmed that FL2 has no room to stage material, so a spool is either waiting for the line or on it — there is no third place for it to be. Section 3.5 is rewritten accordingly: **Ready for FL2** and **Checked in** are the only statuses the operator sees, and while a spool is checked in **no spool offers a check-in action at all**. This replaces our earlier proposal, which had four statuses and allowed a check-in at any time. |
| 1.0 | Aug 2, 2026 | **Initial issue.** A new screen. Written because FL2 had no view of the material waiting for it, and because two agreed statements about how the operator identifies a spool — *scan the printed label* and *select it by spool number* — had only ever had the first one built. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 7. |

---

# 1. Introduction

## 1.1 Purpose

This document specifies the screen an FL2 operator uses to answer two questions before starting a
run: **what material can I run right now**, and **which spools belong to the order in front of me**.
It sits immediately before spool check-in and hands over to it.

## 1.2 Why this screen is being added

Three reasons, in order of weight.

**FL2 has no view of its own work queue.** FL1 operators have a pre-check-in station that lists the
rods planned for the running order. FL2 has no equivalent, because FL2 has no staging area — the
spool goes straight onto the traversing payoff. The consequence was not intended: the FL1 operator
can see what is coming, and the FL2 operator cannot see anything at all until they are holding a
spool. `[CONFIRMED — no staging at FL2]`

**Two agreed statements about identification, one of them unbuilt.** The specification says the
operator **scans the label printed at FL1 output**. Your operational description says the operator
**selects the spool by spool number**. Both are reasonable and they are not in conflict — but only
the scan had a screen. This one is the selection half. `[CONFIRMED — both statements stand]`

**"The spool queue" was a term with nothing behind it.** Where a partially-run rod is accepted by a
supervisor, the specification says the resulting partial spool *"enters the spool queue"*. That
phrase appears in eight places across the requirements and there was no screen, list or record of
that name anywhere. This screen is it.

## 1.3 What this screen is not

It is **not a planner's inventory view**. It does not show spools that cannot be run, it does not
report stock levels or ageing, and it is not the place to allocate material to orders. It answers an
operator's question at the moment of asking it. A management view of spool stock is a separate
conversation if you want one.

---

# 2. Position in the Process

```
FL1 produces a spool
        ↓
   spool labelled, moved (furnace → cooling → FL2 floor)
        ↓
┌──────────────────────────────────┐
│  Dashboard 5A — Spool Queue      │  ← this document
│  what can I run / what is on     │
│  this order                      │
└──────────────────────────────────┘
        ↓  operator picks a spool
┌──────────────────────────────────┐
│  Dashboard 5 — Spool Check-in    │
│  measure, confirm schedule,      │
│  acknowledge                     │
└──────────────────────────────────┘
        ↓
   FL2 run starts
```

The screen is reachable from the floor overview, from the More Options menu, from the spool count on
the shift summary, and from the check-in screen itself.

---

# 3. How the screen behaves

## 3.1 On opening — every spool available for processing `[CONFIRMED]`

The screen is useful before the operator touches anything. On opening it lists **all spools currently
available for processing, regardless of which order they belong to**, with a running total of spools,
of those ready, and of total weight.

For each spool it shows the spool identifier, its order, the FL1 run and source rods it came from,
its gauge and width, its net weight, whether it came off a standalone or a hybrid run, and its
status.

## 3.2 Scanning a spool — the order and its spools load together `[CONFIRMED]`

The operator scans, or types, a spool number. The system then does the following **in a single
step**, with no second lookup and no button to press:

| # | What happens |
|---|---|
| 1 | The spool number is matched. |
| 2 | **The system determines which order that spool belongs to.** This is done by the system, not by the operator. |
| 3 | The order's details are displayed — order number, customer, alloy, temper, setup gauge and width, and due date. |
| 4 | **The list below changes to show every spool on that order**, with the scanned spool marked so the operator can see which one is in their hand. |
| 5 | Each spool that may be run offers a check-in action leading to Dashboard 5. |

A **Show all spools** action returns to the full list at any time.

> The field responds as soon as the number is entered — on the scanner's own terminating keypress,
> and shortly after typing stops if entered by hand. There is deliberately no *Find* or *Search*
> button; a scanner would trigger the lookup before an operator could reach one.

## 3.3 Alloy and temper are shown once, not per row `[PROPOSED]`

Alloy, temper and the setup dimensions are properties of the **order**, so they appear once in the
order bar rather than repeated against every spool. This matches the equivalent rod screen. If you
would rather see alloy against each spool in the all-orders view, say so at review — it is a
presentation choice, not a constraint.

## 3.4 When the scan does not resolve

| Situation | What the operator sees |
|---|---|
| The spool number is not recognised | The field is marked, with *"No spool matches …"*. **The list does not change.** A mistyped digit must never cost the operator the list they were reading. |
| The spool is recognised but **has not been allocated to an order** | The order bar says so plainly and the spool is listed on its own. **It can still be checked in.** This is a normal situation, not an error — a planning remainder or an accepted partial spool legitimately has no order yet. `[PROPOSED]` |
| The spool scanned is **the one already checked in** | Its order still loads and its sibling spools are still listed, because that is usually what the operator actually wants. The scanned spool shows as *Checked in* and offers the way through to its run. `[CONFIRMED]` |
| The scan resolves normally but **another spool is checked in** | The order and its spools load exactly as they would otherwise. Nothing is hidden and no error is raised — the list simply offers no check-in action, with the banner of Section 3.5 above it saying why. Looking things up is always allowed; starting a second spool is not. `[CONFIRMED]` |
| Nothing at all is available for FL2 | The list is replaced by a plain statement to that effect, directing the operator to FL1 output or the hold queue. |

## 3.5 Two statuses, and one spool at a time `[CONFIRMED — Aug 2, 2026]`

**FL2 has no room to stage anything.** A spool is therefore either waiting to go on the line or it is
on the line, and the screen shows exactly those two states and no others:

| Status shown | Meaning |
|---|---|
| **Ready for FL2** | Received from FL1 (or accepted back as a partial spool) and not yet run. |
| **Checked in** | Currently on the FL2 payoff and feeding the run. |

There is no *staged* or *at payoff* status at FL2. Staging is an FL1 concept — it exists there because
FL1 has floor space for rods waiting at the payoff positions, and FL2 does not.

**Check-in is exclusive.** While a spool is checked in:

| | |
|---|---|
| **No spool offers a check-in action** | Not the other spools in the list, and not the checked-in spool itself. The action is *absent*, not greyed out — a disabled button on every row is an invitation to press it nine times. |
| **The reason is stated once, at the top of the list** | A banner names the spool that is checked in and says the line must be cleared before another can go on. |
| **The checked-in spool is the first row** | So the operator's first question — *which one is on the line?* — is answered without scrolling. Its only action leads to the run it is feeding. |
| **The action returns on checkout** | Checking that spool out is what makes the rest of the list checkable again. |

This mirrors the physical constraint rather than adding a rule on top of it: there is one payoff, so
there is one spool. Nothing on this screen changes a status — the check-in and checkout screens do
that, and this screen reflects the result.

> **A note for your IT team.** The screen not offering the action is not by itself sufficient. The
> underlying check-in service must also refuse a second check-in on a line that already has one, so
> that two operators on two terminals cannot both start a spool. This is an implementation
> requirement we are recording, not a question for you.

## 3.6 Hybrid-origin material is marked `[CONFIRMED — marking]` `[CLIENT INPUT REQUIRED — consequence]`

A spool produced on a hybrid run is **visibly marked as such in the list**, because applying a
standalone FL2 configuration to hybrid-origin material is a known risk. Whether that should *prevent*
check-in, warn, or require a supervisor is still open, and is the same open item the check-in screen
carries (Section 7, item 3).

---

# 4. Information shown per spool

| Field | Source | Notes |
|---|---|---|
| Spool identifier | The spool record | The scan key. Format is open — Section 7, item 1 |
| Order | The spool record | Blank where the spool is not yet allocated |
| Source | The FL1 run that produced it, and the rods that fed that run | A spool may carry more than one rod where a weld was made mid-run |
| Gauge × width | **The FL1 run's output measurements** | Not the spool record itself — see the note below |
| Net weight | The spool record | |
| Origin | The spool record | Standalone or hybrid |
| Status | The spool record | One of the two in Section 3.5 — *Ready for FL2* or *Checked in* |

> **A note on gauge and width.** These are recorded against a spool *when it is checked in at FL2* —
> which is exactly what has not happened yet for everything on this screen. They are therefore read
> from the FL1 production run that made the spool. This is correct and intended; we mention it
> because it means this screen depends on FL1 run history being retained.

## 4.1 What is deliberately absent

| Not shown | Why |
|---|---|
| **How long a spool has been waiting** | The system does not record when a spool was created, so its age cannot be calculated. If time-in-storage matters to you, tell us at review — it is a small addition, but it has to be added deliberately. `[CLIENT INPUT REQUIRED]` |
| **Where the spool physically is** | There is a field for it but nothing currently populates it, and no location scheme has been defined. Adding a column that is always blank would be worse than omitting it. `[CLIENT INPUT REQUIRED]` |
| **Filtering and sorting controls** | The list is already limited to runnable material and the scan is the operator's real filter. We would rather add these after you have used it than guess. `[PROPOSED]` |

---

# 5. Rules Summary

| # | Rule |
|---|---|
| SQ-1 | The screen lists all spools available for processing on opening, without requiring a scan. |
| SQ-2 | The order a scanned spool belongs to is determined **by the system**, not entered by the operator. |
| SQ-3 | Order details and the order's spool list are produced **together, in one step**, from the scanned spool number. |
| SQ-4 | The scanned spool remains identifiable in the list that replaces it. |
| SQ-5 | An unrecognised spool number never changes what is displayed. |
| SQ-6 | A spool with no order is a valid result, not an error, and may still be checked in. |
| SQ-7 | A spool is shown in one of exactly two states: **Ready for FL2** or **Checked in**. There is no staged state at FL2. |
| SQ-8 | While any spool is checked in, **no spool offers a check-in action**. |
| SQ-9 | The checked-in spool is listed first, is named in a banner above the list, and offers the route to its run. |
| SQ-10 | Checking that spool out is what restores the check-in action to the rest of the list. |
| SQ-11 | Hybrid-origin spools are visibly marked. |
| SQ-12 | This screen never changes any record. It reads, and it hands over to check-in. |

---

# 6. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| 1 | FL2 has no staging area; the spool goes directly onto the traversing payoff | May 2026 |
| 2 | The FL2 operator identifies the spool by its number at check-in | May 4, 2026 |
| 3 | A spool carries its source rod identities forward for certification | Apr 2026 |
| 4 | An accepted partial spool enters the spool queue on supervisor approval | May 4, 2026 |
| 5 | A spool produced on a hybrid run is a distinct case from a standalone spool | Jul 2026 |
| 6 | FL2 shows two spool statuses only — *Ready for FL2* and *Checked in* | Aug 2, 2026 |
| 7 | FL2 runs one spool at a time; no check-in is offered while a spool is checked in | Aug 2, 2026 |

---

# 7. Open Items Requiring Client Input

| # | Item | Why it matters here | Owner |
|---|---|---|---|
| 1 | **What identifier is scanned, and in what format.** Whether check-in uses the material identity, the physical spool number, or a bundle identifier has not been fixed, and two different formats appear across the documents. Your own description distinguishes the *spool number* (a reusable physical carrier, like a furnace plate) from the *material identity loaded onto it* — the system currently records only the second. | This is the first thing the operator touches on this screen and the field DB5 also depends on | Tim O. / Jaspreet |
| 2 | **The spool lifecycle behind the two statuses.** What the FL2 operator sees is now settled (Section 3.5). What the *system* records is not: two different spool status vocabularies are in use across the documents and nothing maps one to the other. We need one list of stored statuses so that *Ready for FL2* and *Checked in* have an unambiguous definition behind them. **Reduced in scope Aug 2, 2026** — this no longer affects what appears on this screen. | Determines how the two displayed statuses are derived and recorded | Tim O. / Jaspreet |
| 3 | **Hybrid-origin spools at FL2.** Whether a standalone FL2 configuration may be applied to material produced on a hybrid run — block, warn, or require supervisor approval. | Determines whether the marking in Section 3.6 is informational or a gate | Tim O. / Jaspreet |
| 4 | **Order allocation must be visible to the shop floor.** Allocating spool weight to an order happens in planning. For this screen to resolve an order from a spool, that allocation has to be readable by the shop-floor system. **If it is not, this screen cannot work as described.** | The single dependency that would invalidate the design | Jaspreet |
| 5 | **Is time-in-storage useful?** See Section 4.1. | Decides whether spool creation time needs recording | Tim O. |
| 6 | **A spool held by quality no longer has a place on this screen.** With two statuses, a spool that QA has held is simply not listed — it is not ready for FL2 and it is not on the line. Our reading is that this is correct and that a held spool is quality's business until released. Tell us if the FL2 operator instead needs to *see* held material with the reason, so they know why an expected spool is missing. **New Aug 2, 2026**, arising from the two-status decision. | Decides whether held spools are invisible or listed-and-blocked | Tim O. |

---

# 8. Assumptions

| # | Assumption |
|---|---|
| 1 | A spool belongs to at most one order at a time. A spool split across several orders would need a different presentation. |
| 2 | The number of spools awaiting FL2 at any moment is modest — a working list, not a warehouse. Spools are sized so that roughly two finished coils come off each. |
| 3 | FL1 run history, including the gauge measurements, is retained for as long as its spool is unprocessed. |
| 4 | This screen is read-only. Nothing on it changes a record; check-in does that. |
| 5 | FL2 has one payoff, so at most one spool is checked in on the line at any moment. If FL2 could ever run two spools at once, Section 3.5 would need reworking. |

---

# 9. Related Specifications

| Document | Relationship |
|---|---|
| Rod and Spool Check-in Specification | The screen this one hands over to |
| Rod Pre-Check-in Specification | The FL1 equivalent; this screen follows its conventions |
| Rod Checkout Specification | Source of partial spools that arrive in this queue |
| Spool Completion Notification | How a spool is finished and labelled at FL1 |

---

# Client Sign-off

## Part A — Rules for confirmation

- [ ] The screen lists all runnable spools on opening, without a scan (SQ-1)
- [ ] The system determines the order from the scanned spool (SQ-2, SQ-3)
- [ ] Alloy and temper are shown once per order rather than per spool (3.3)
- [ ] An unrecognised scan leaves the display unchanged (SQ-5)
- [ ] A spool with no order may still be checked in (SQ-6)
- [ ] Two statuses only — *Ready for FL2* and *Checked in*; no staged state at FL2 (SQ-7)
- [ ] No spool offers check-in while a spool is checked in (SQ-8, SQ-9, SQ-10)
- [ ] Hybrid-origin spools are marked (SQ-11)

## Part B — Information required

- [ ] What identifier is scanned, and its format (Section 7, item 1)
- [ ] The stored spool statuses behind the two shown (Section 7, item 2)
- [ ] What should happen with a hybrid-origin spool at FL2 (Section 7, item 3)
- [ ] Confirmation that order allocation is readable by the shop floor (Section 7, item 4)
- [ ] Whether time-in-storage should be shown (Section 7, item 5)
- [ ] Whether quality-held spools should be visible to the FL2 operator (Section 7, item 6)

## Part C — Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Operations | | | |
| Production | | | |
| IT / Systems | | | |
| 1.2 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
