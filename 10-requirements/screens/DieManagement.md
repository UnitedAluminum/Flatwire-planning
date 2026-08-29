# Flat Wire Processing — Die Management Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** Maintenance (tooling inventory)
**Version:** 1.1
**Last Updated:** August 12, 2026
**Status:** **MVP-2 — not part of MVP-1 and not part of MVP-1 planning**
**Screen reference:** Die Management (maintenance, tooling inventory) — [`../../50-frontend/mockups/dashboard_die_management.html`](../../50-frontend/mockups/dashboard_die_management.html)
**Extracted from:** [`DieChangeAndManagement.md`](./DieChangeAndManagement.md) v2.2 §4, on 11 Aug 2026

---

> **Scope banner.** This document is **MVP-2**. Nothing in it is to be planned, estimated, or implemented for MVP-1. See [`../../95-archive/design-notes/MVP-2-scope-note.md`](../../95-archive/design-notes/MVP-2-scope-note.md) for the scope decision.
>
> **It was extracted, not written.** Its parent document covered two subjects in one file: the mid-run **Die Change event**, which **stays in MVP-1** (Phase 6, delivered as the `die_change.js` dialog over the paused run), and **Die Management** inventory, which is this document. The split was made so the MVP-1 requirements were not carried into MVP-2 by accident. **The parent is still the authority on the die change event**; this file is the authority on inventory.

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Aug 11, 2026 | **Extracted from `DieChangeAndManagement.md` v2.2 §4 on the MVP-2 scope split.** Content copied unchanged apart from the scope banner, the cross-references retargeted across the split, and the die-life status vocabulary left in the parent rather than copied (see §5 below — this repository has a long history of duplicated tables drifting apart, and a sixth copy of a status vocabulary is not worth the convenience). No requirement was altered, added, or removed in the extraction. |

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 6. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Die Management

The maintenance-facing counterpart to the die change event, reached from tooling inventory. It is not accessible from the shopfloor screens.

## 1.1 Division of responsibility

| Capability | Die change *(MVP-1)* | Die management *(MVP-2 — this document)* |
|---|---|---|
| Log a mid-run die swap | **Yes** | No |
| View outgoing die remaining life | Yes — read only | Yes — editable |
| Scan and assign an incoming die | **Yes** | No |
| Register a new die into inventory | No | **Yes** |
| Set or edit a life threshold | No | **Yes** |
| Reset the footage counter after reconditioning | No | **Yes** |
| Retire a die permanently | No | **Yes** |
| View full run history per die | No | **Yes** |
| View the replacement and reset log | No | **Yes** |

> **This table is now also the scope boundary**, which it was not when both columns shipped together. Everything in the right-hand column is MVP-2. Everything in the left-hand column is MVP-1 and **depends on the right-hand column existing** — see §7.

## 1.2 Inventory view

A summary strip states how many dies are active on line, overdue for replacement, nearing end of life, and available as spares. The list is filterable by status and by line, and is sorted by urgency — overdue first, then nearing end, active, spare and retired.

| Column | Content |
|---|---|
| Identity | Die identifier |
| Block | DB1 or DB2 |
| Size | Hole diameter |
| Line | Currently assigned line, or none for a spare |
| Status | Active · Nearing end · Overdue · Spare · Retired |
| Life used | Progress bar and percentage |
| Footage | Footage run against threshold |
| Last reset | Date of the last counter reset, or *new* for a first-install spare |

## 1.3 Die detail

Selecting a die shows its identity, status, block, size and type, the line it is on, its life bar, and:

| Field | Notes |
|---|---|
| Footage on die | Since the last counter reset |
| Life threshold | Configured maximum footage |
| Remaining | Threshold less footage; emphasised when near or past the limit |
| Die size and type | |
| Last reset by | Operator and date |

Alerts are stated in plain language: *"Replacement overdue — pull at end of current run"* for an overdue die, and *"Schedule a replacement die — do not load for a new order without a spare on hand"* for one nearing end of life.

Two history views are available: **run history** (order, line, footage added, date, operator — one row per run in which the die was active) and the **replacement log** (install, reset and retirement events, each with who performed it and what changed).

## 1.4 Lifecycle operations

| Operation | Purpose | What it captures |
|---|---|---|
| **Reset counter** | The die has returned from reconditioning, or a new spare is being entered into the counter system | Disposition (reconditioned or new spare) · date removed from line · date returned and ready · **new life threshold** (reconditioned only) · inspection date · performed by · die room source · notes. Footage resets to zero |
| **Edit threshold** | Change the footage limit — for this die, or for **all dies of the same type and size** | A reason is required. Changing the type-level value updates the default for future registrations |
| **Retire die** | Permanent removal | Date retired · reason (end of life · physical damage · bore out of tolerance · size discontinued · other) · notes. Retired dies remain in history for traceability but leave the active and spare counts |
| **Register new die** | Bring a die into inventory as a spare | Identity (`D-{size×1000}-{seq}`) · compatible block · hole size · type and material · life threshold · source · condition · inspection date · notes |

**A reconditioned die does not return with its original life.** The reset defaults its threshold to a reduced figure, because a re-lapped die has less remaining life than a new one — the default is a starting point that Maintenance can adjust.

## 1.5 What the die change screen consumes from here

| Value | Used for |
|---|---|
| Die identity → size, type, condition | Resolving the incoming die scan |
| Footage counter | The outgoing die's accumulated footage and remaining life |
| Life threshold | The life bar and the remaining figure |

> **This section is the MVP-1 dependency, and it is the reason this split needs a decision rather than just a folder.** All three values are consumed by the MVP-1 die change. With this document out of MVP-1, where they come from is undefined — see §7.

---

# 2. Die Life Status

**The status vocabulary is not restated here.** It stays in [`DieChangeAndManagement.md` §5](./DieChangeAndManagement.md) — `Active` · `Nearing end` · `Overdue` · `Spare` · `Retired` — because the die change screen reads it too, and a second copy in a second scope bucket is how a five-row vocabulary becomes two five-row vocabularies that disagree.

Two things about it *are* owned here:

| Item | Detail |
|---|---|
| **The Die Management bands** | Active below 65 % · nearing end 65–79 % · overdue at 80 % and above |
| **Configurability** | `[CLIENT INPUT REQUIRED]` Are the bands fixed, or configurable per die type? A roughing die at DB1 may warrant a different alert point from a finishing die at DB2, where gauge drift risk is higher. Our recommendation is that Maintenance be able to configure the boundary per die type, with a system default. |

**`OI-12` goes dormant for MVP-1 and lands here.** It recorded that the two screens use *different* bands for the same die — Die Change green below 60 % / amber 60–85 % / red above 85 %, against Die Management's 65/79/80 figures above. With Die Management out of MVP-1, **only the Die Change bands apply in MVP-1, so there is no live inconsistency to resolve there**; the conflict becomes real again the moment this document is scheduled. Do not close `OI-12` on the strength of the split — it is deferred, not answered.

---

# 3. Confirmed Decisions

| # | Decision | Date | Note |
|---|---|---|---|
| D6 | Die management is the **source of truth** for die identity, footage and life threshold | Apr 2026 | **Now an MVP-1 problem** — the source of truth is in MVP-2 while its consumer ships in MVP-1. §7 |
| D4 | A die that is not registered in inventory **cannot be installed** | Apr 2026 | Retained in the parent as a die change rule, repeated here because **it is unenforceable without this document's registration flow**. §7 |

---

# 4. Assumptions

| # | Assumption | Note |
|---|---|---|
| A1 | Every die in physical circulation is registered in inventory before it reaches the line. | Depends on §1.4 *Register new die*, which is MVP-2 |
| A5 | Reconditioning reduces available life, and the reduced figure is set at the counter reset. | Depends on §1.4 *Reset counter*, which is MVP-2 |
| A6 | Die room inspection records exist and are readable, so an incoming die's inspection date can be displayed rather than typed. | Carried from the parent's A4 |

---

# 5. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-12** | Medium | **Which die-life colour bands apply** — 60/85 % or 65/79/80 % | A consistent operator signal across both screens. **Dormant for MVP-1** (only the Die Change bands apply); live again when this document is scheduled |
| — | Medium | **Are life bands configurable per die type**, or fixed system constants? | Die management configuration |
| **Q83** | Medium | **Die life tracking basis** — is scheduled life expressed in footage alone, or does another measure apply? | The threshold model |

---

# 6. What MVP-1 Still Needs From This Document

This is the substance of the split, and it is not resolved by moving a file. The MVP-1 die change event reads three values from die management — die identity, footage counter, and life threshold (§1.5) — and one MVP-1 rule, **D4**, forbids installing a die that is not registered. With this document deferred:

| Question | Why it matters |
|---|---|
| Where do die identity, size and type come from when the operator scans an incoming die? | Without a resolver the scan validates against nothing |
| Where does the footage counter live, and who increments it? | The outgoing die's accumulated footage and remaining-life bar have no source |
| Where does the life threshold come from? | The life bar and the *"replacement overdue"* alert have no threshold to compare against |
| Is **D4** enforced in MVP-1, and against what? | Either it is relaxed for MVP-1, or a minimal registration path is in MVP-1 scope after all |

Three shapes are possible and **none has been chosen**: seed the `Die` reference data and treat it as static for MVP-1; take die records from an upstream system; or pull a minimal registration path back into MVP-1. This is the third of the three consequences listed in [`../../95-archive/design-notes/MVP-2-scope-note.md`](../../95-archive/design-notes/MVP-2-scope-note.md).

---

# 7. Related Specifications

| Document | Relationship |
|---|---|
| [Die Change and Die Management](./DieChangeAndManagement.md) | **The parent.** Authority on the mid-run die change event (MVP-1) and on the die-life status vocabulary |
| [Pass Schedule Management](PassScheduleManagement.md) | Die sizes are pass-schedule parameters; a size change is a configuration change. **Also MVP-2** |
| [SPC Checkpoint](./SPCCheckpoint.md) | The verification gate a gauge-drift or size-change die change routes into. MVP-1 |
| [Rod Check-in](./RocCheckin.md) | Pushes the die configuration to machine control at acknowledgement. MVP-1 |
| 1.1 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
