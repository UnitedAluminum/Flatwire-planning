# Flat Wire Processing — Die Change and Die Management Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL3 (die change). *Die management moved to MVP-2 on 11 Aug 2026 — §4.*
**Version:** 2.6
**Last Updated:** August 15, 2026
**Status:** Issued for Client Review and Sign-off — **MVP-1, die change only**
**Screen reference:** Die Change (operator, mid-run) — presented as a **dialog over the paused run**, not as a separate screen (see version 2.1). *The Die Management screen is [MVP-2](./DieManagement.md).*
**Requirement source:** SRS die-change rules; `Q65` (post-die-change resume gate); die identity convention `D-{size×1000}-{seq}`

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 9. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

Two related capabilities are specified here:

| | **Die Change** | **Die Management** |
|---|---|---|
| Audience | **Operator**, at the line | **Maintenance**, in tooling inventory |
| Nature | A mid-run **event logger** | A **lifecycle manager** |
| Records | That a die was physically replaced, and why | The die inventory, life thresholds, and disposition history |
| Relationship | **Reads** die identity, footage and life threshold from die management | **Is the source of truth** for those three values |

## 1.2 Scope

**In scope:** capture of a mid-run die replacement and its consequences; the reason codes and what each one triggers; quality holds on suspect footage; the post-change verification gate; and the full die inventory lifecycle — registration, life thresholds, counter resets after reconditioning, and retirement.

**Not in scope:** the SPC checkpoint procedure itself; WIP rejection processing; roll gap adjustment on the finishing stands; die procurement.

## 1.3 Applicable lines

| Line | Draw box 1 | Draw box 2 | Die change | Also has |
|---|---|---|---|---|
| **FL1** | Yes | Yes | **Yes** | — |
| **FL3** (hybrid) | Yes | Yes | **Yes** | Roll adjustment on the FM2 stands |
| **FL2** | — | — | **No** | Spool-fed; no drawing dies |

FL3 has the same drawing section as FL1 and adds the three-stand finishing mill downstream — **S1 with an 8″ roller, S2 with a 6″ roller and edger, S3 with a 6″ roller and edger**. FL2 has no drawing dies and never needs a die change.

> `[CLIENT INPUT REQUIRED]` **Which lines expose roll adjustment is stated inconsistently** across the requirement set — FL1/FL2 in one place, FL3 only in another, FL2 and FL3 here. FL1, having only drawing and the flattening mill, is unlikely to expose it. Please confirm which action bars carry the control (OI-11).

---

# 2. The Die Change Event

## 2.1 Context

The screen is opened from the active run. **The run is paused while it is open**, and the operator must complete or cancel before production resumes. The event is permanently tied to the output coil's traceability record at the current footage position.

## 2.2 Which die block

Three mutually exclusive choices. The selection drives what the outgoing panel shows and what the confirm action is labelled.

| Choice | Use when |
|---|---|
| **DB1** — draw box 1 | Changing the roughing die only |
| **DB2** — draw box 2 | Changing the finishing die only — **the most common case, and the default** |
| **Both blocks** | A full-line die rebuild, or when a failure on one block has stressed the other. Logged as a single simultaneous event; each incoming die must be identified separately |

The default falls to DB2 because it is the die that sets the final wire diameter before the flattening mill, and it is typically the one closer to end of life in an active run.

## 2.3 The outgoing die — read-only

Auto-filled from the machine's current die assignment. The operator confirms rather than types.

| Field | Meaning |
|---|---|
| Die identity | The die being removed |
| Life consumed | Percentage of scheduled footage life used, with a visual bar |
| Die size | Hole diameter |
| Footage on die | Total footage run since installation |
| Scheduled life | Engineering or supplier specified maximum footage |
| Remaining | Footage left before scheduled end of life |
| Die type | Material and construction |
| Installed | When the outgoing die was loaded |

## 2.4 The incoming die — operator entered

| Field | Entry |
|---|---|
| Die identity | **Scanned**, or keyed. The entry resolves against the **`Drawer` die-size catalogue** — 13 rows, one per hole diameter — and populates the fields below. **It does not resolve a physical tool**; see §2.4a |
| Condition | **New** (full scheduled life) or **Reconditioned** (reduced scheduled life) |
| Die size | Must match the outgoing die **unless the reason is a size change** |
| Source | Die room, or external supplier |
| Inspection | Timestamp of the pre-use inspection, from the die room record |
| Die type | Must match the outgoing die type |
| Scheduled life | From the die record |

**A die whose size is not in the catalogue cannot be installed.** An unrecognised size is refused. **This is `D4` as it applies in MVP-1, and it is weaker than the rule as originally written** — see §2.4a.

## 2.4a What `D4` means in MVP-1 `[CONFIRMED — Aug 11, 2026]`

Die **inventory and lifecycle are owned outside MVP-1**: registration, per-tool identity, condition history, retirement and the four lifecycle operations are all MVP-2 (`DieManagement.md`). MVP-1 keeps the **die change event** and nothing else of the die domain. The three values the change screen needs therefore come from the `Drawer` lookup that MVP-1 already seeds in Phase 1:

| Value | MVP-1 source | Granularity |
|---|---|---|
| Die identity | `Drawer` — the 13-row **size** catalogue | Size, **not** the physical tool |
| Footage counter | `Drawer.LastGrindingFeet` | Per size |
| Life threshold | `Drawer.TotalFeetAllowed`, with the **60 / 85 %** bands of §5 | Per size |

**`D4` is restated accordingly: the system rejects an unrecognised die *size*, not an unregistered physical die.** It cannot do the latter — nothing in MVP-1 knows that a physical tool exists. `DieChangeEvent` already reflects this: it stores `OldDieSizeIn` and `NewDieSizeIn` as decimals with **no `DrawerId` foreign key**, so the check is an application-level validation against the catalogue, not a database constraint.

> **The consequence, stated plainly so it is not later reported as a defect: die life is tracked per size, so two dies of the same diameter share one counter.** Installing a fresh die does not reset anything a size-level counter can distinguish, and a size at 85 % reads as 85 % whichever physical tool is fitted. This is accepted for MVP-1. Per-tool life tracking arrives with Die Management.

## 2.5 Reason for the change

Five mutually exclusive reasons. Each determines what else the system does.

| Reason | Meaning | Consequence |
|---|---|---|
| **Planned life** *(default)* | The die reached or approached its scheduled footage limit | None — routine swap |
| **Gauge drift** | Die wear is pushing gauge toward or outside specification | **SPC checkpoint required before full production** |
| **Die failure** | The die cracked, chipped or broke during the run | **Quality hold section opens** for the suspect footage range |
| **Size change** | A different hole size is deliberately required | **SPC checkpoint required before full production** |
| **Other** | Anything not covered above | Detail expected in the observation |

## 2.6 Quality hold — when the die failed

Material produced with a failing die may be off specification, so the operator marks the suspect range.

| Field | Behaviour |
|---|---|
| **Hold from footage** | Editable. Defaults to the footage at which the current rod started on this die; the operator can move it if they know when the failure actually occurred |
| **Hold to footage** | **Read-only** — the current counter value at the time of the die change. The system knows when the change was logged |
| **Flag for QA hold** | Creates a quality hold against that footage range on the output coil. QA must review and disposition the range before the coil can ship |

## 2.7 The verification gate — when gauge drifted or size changed `[CONFIRMED — May 4, 2026]`

| Rule | Behaviour |
|---|---|
| **Hard block, not a soft queue** | Confirming the die change routes **directly to the SPC checkpoint**, not back to the run |
| **Thread mode permitted** | The line may be run slowly to confirm the new die is seated and producing on-target material |
| **Full production blocked** | The run cannot return to normal production until the checkpoint passes |
| **The requirement may be waived** | Only as a supervisor-level action, and every waiver is audited and appears as a flagged exception on shift and quality reporting |

### Why both reasons require it

- **Gauge drift** — the die was replaced *because* dimensions were drifting. The replacement's output is unverified, and the process is not back in control until measurements confirm it.
- **Size change** — the hole size changed deliberately, so the new target dimensions are unverified until measured.

In both cases, material run before verification could be out of specification.

> **This gate is enforced at confirmation, not at resume.** There is no general-purpose resume control on the active run screen — resume exists only inside the pause flow, and the die change screen returns directly to the run. The gate therefore has to sit on the confirm action, which is where it is specified.

## 2.8 Post-change routing `[CONFIRMED]`

| Reason | On confirm |
|---|---|
| Planned life | Return to the run; production resumes |
| Die failure | Return to the run; production resumes — **the hold is on the footage, not on the run** |
| **Gauge drift** | **Route to the SPC checkpoint.** Run stays blocked; thread mode allowed |
| **Size change** | **Route to the SPC checkpoint.** Run stays blocked; thread mode allowed |

## 2.9 Audit stamp and confirmation

| Field | Source |
|---|---|
| Operator | The active session |
| Timestamp | **Server-stamped at submission** — the screen clock is for operator visibility only |
| Footage at change | Machine encoder position when the change was initiated |
| Output coil | The coil the event is recorded against |

**Cancel is always safe.** No partial record is written; the run simply resumes with no die change logged.

## 2.10 Information recorded on confirmation

| Item |
|---|
| Die block changed |
| Outgoing die identity, size, and footage accumulated on it |
| Incoming die identity, size and condition |
| Reason code |
| Footage at the change |
| Output coil identity |
| Operator and server timestamp |
| Quality hold range, where a die failure was flagged |
| Whether an SPC checkpoint is required |

---

# 3. Die Change — Design Principles

| Principle | Detail |
|---|---|
| **Immutable record** | Once confirmed, a die change event is never edited. Corrections go through a separate audit route |
| **Default to the common case** | DB2, planned life and new condition are pre-selected; the operator overrides only when something unusual applies |
| **Conditional sections are additive** | Selecting *die failure* adds a quality hold workflow — it does not replace the normal die change flow. Both happen |
| **Server timestamp** | The event time is captured server-side at receipt |
| **Cancel writes nothing** | No partial records |

---

# 4. Die Management — moved to MVP-2

> **This section was extracted to [`./DieManagement.md`](./DieManagement.md) on 11 Aug 2026.** Die Management — the inventory view, die detail, the four lifecycle operations (register · reset counter · edit threshold · retire) and the die-life bands it uses — is **MVP-2 scope and is not part of MVP-1 or of MVP-1 planning**. **No requirement was changed in the move**; the text is intact in the new document.
>
> **The die change event specified in §1–§3 and §5 of this document remains MVP-1** (Phase 6, delivered as the `die_change.js` dialog over the paused run). This document is still the authority on it, and on the die-life status vocabulary in §5.

**What the die change screen consumed from die management** is retained here, because it is the MVP-1 dependency the split creates rather than removes:

| Value | Used for |
|---|---|
| Die identity → size, type, condition | Resolving the incoming die scan |
| Footage counter | The outgoing die's accumulated footage and remaining life |
| Life threshold | The life bar and the remaining figure |

> **✅ ANSWERED Aug 11, 2026 — see §2.4a.** All three values come from the **`Drawer` die-size catalogue**, which MVP-1 already seeds: identity resolves against its 13 rows, footage from `LastGrindingFeet`, threshold from `TotalFeetAllowed`. The option chosen was the first of the three offered — *seed the die reference data as static for MVP-1* — with the important qualification that `Drawer` is a **size** catalogue, so the resolution is per size and not per physical tool. **`D4` is enforceable only in its size-level form**, and is restated in §2.4a rather than left as an open question. Die inventory and lifecycle stay MVP-2 permanently; no registration path is pulled back.

---

# 5. Die Life Status

| Status | Condition | Meaning |
|---|---|---|
| **Active** | Well inside the threshold | Normal |
| **Nearing end** | Approaching the threshold | Schedule a replacement |
| **Overdue** | At or past the threshold | Pull at the end of the current run |
| **Spare** | No footage, not installed | Available |
| **Retired** | Permanently removed | Historical only |

**The status vocabulary above stays here and is the single copy** — the die change screen reads it, and so does the extracted Die Management document, which points back at this table rather than restating it.

> **`OI-12` is dormant for MVP-1 as of 11 Aug 2026 — deferred, not answered.** It recorded that the two screens use **different bands for the same die**, each internally consistent with its own source:
>
> | Screen | Bands | Scope |
> |---|---|---|
> | Die Change | Green below 60 % · amber 60–85 % · red above 85 % | **MVP-1** |
> | Die Management | Active below 65 % · nearing end 65–79 % · overdue at 80 % and above | **MVP-2** |
>
> With Die Management deferred, **only the Die Change bands apply in MVP-1**, so there is no live inconsistency for an operator to hit. The conflict becomes real again the moment Die Management is scheduled, and one set must be chosen then. **Do not close `OI-12` on the strength of the scope split.** The band-configurability question travels with it — see [`DieManagement.md` §2](./DieManagement.md).

---

# 6. Confirmed Decisions

| # | Decision | Date | Note |
|---|---|---|---|
| D1 | **The post-die-change gate is a hard block on full production**, enforced at the confirm action, with thread mode permitted | May 4, 2026 | |
| D2 | **Gauge drift and size change both route to the SPC checkpoint**; planned life and die failure return to the run | May 4, 2026 | |
| D3 | A **die failure** holds the suspect **footage range**, not the run | Apr 2026 | |
| D4 | ~~A die that is not registered in inventory **cannot be installed**~~ → **restated Aug 11, 2026:** a die whose **size** is not in the `Drawer` catalogue cannot be installed | Apr 2026, restated Aug 2026 | ✅ **Enforceable in its size-level form — see §2.4a.** The per-tool form is not, and never will be in MVP-1: die inventory and lifecycle are owned outside it |
| D5 | Die change events are **immutable**; corrections are separate records | Apr 2026 | |
| D6 | Die management is the **source of truth** for die identity, footage and life threshold | Apr 2026 | ⚠ **The source of truth is now MVP-2 while its consumer ships in MVP-1** — see §4 |

---

# 7. Assumptions

| # | Assumption | Note |
|---|---|---|
| A1 | ~~Every die in physical circulation is registered in inventory before it reaches the line.~~ **Superseded Aug 11, 2026.** MVP-1 makes no such assumption because it cannot check it. What it assumes instead: **every die size in use is one of the 13 rows seeded in `Drawer`**, and the die room keeps `LastGrindingFeet` current per size. | ✅ Restated for MVP-1 |
| A2 | The machine reports the current die assignment, so the outgoing panel does not need operator entry. | |
| A3 | The footage encoder is the authoritative source of both the change position and the accumulated die footage. | |
| A4 | Die room inspection records exist and are readable, so the incoming die's inspection date can be displayed rather than typed. | |
| A5 | Reconditioning reduces available life, and the reduced figure is set at the counter reset. | Travels with **MVP-2** — the counter reset has moved |

---

# 8. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| ~~**NEW**~~ | ~~High~~ | ~~**Where do die identity, footage counter and life threshold come from in MVP-1**, and is **D4** enforceable without its registration flow?~~ **✅ ANSWERED Aug 11, 2026 — §2.4a.** All three come from the `Drawer` size catalogue; `D4` is enforceable at **size** level only | Closed |
| **OI-11** | Medium | **Which lines expose roll adjustment** | Which action bars carry the control |
| **Q65** | Medium | **Who may waive the post-die-change verification gate** | Override authority and audit |
| **OI-18** | Medium | Should the SPC checkpoint carry an **explicit link to the die change** that raised it? | Proving which change a checkpoint verified |
| **OI-12** | Medium | **Which die-life colour bands apply** — 60/85 % or 65/79/80 % | **Dormant for MVP-1** — only the Die Change bands apply. Live again when Die Management is scheduled. §5 |
| **Q83** | Medium | **Die life tracking basis** — footage alone, or another measure? | The threshold model. **Moved to MVP-2** with the die-management scope |

---

# 9. Related Specifications

| Document | Relationship |
|---|---|
| [SPC Checkpoint](SPCCheckpoint.md) | The verification gate a gauge-drift or size-change die change routes into |
| [Die Management](./DieManagement.md) | §4 of this document, extracted 11 Aug 2026. **MVP-2** — the source of truth for die identity, footage and life threshold |
| [Pass Schedule Management](./PassScheduleManagement.md) | Die sizes are pass-schedule parameters; a size change is a configuration change. **MVP-2** |
| [Rod Check-in](RocCheckin.md) | Pushes the die configuration to machine control at acknowledgement |
| [PLC Tag Specification](../../20-architecture/PLCTagSpecification.md) | The footage counter this screen reads for die-life accumulation, and the roll-gap tag a linked override writes |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.3 | Die change applies to FL1 and FL3 only | ☐ | ☐ |
| §2.2 | Three die block choices, DB2 defaulted | ☐ | ☐ |
| §2.4a | A die whose **size** is not in the `Drawer` catalogue cannot be installed — the size-level form of `D4` | ☐ | ☐ |
| §2.4a | **Die life is tracked per size, not per physical tool** — two dies of one diameter share a counter, and a fresh die resets nothing | ☐ | ☐ |
| §2.5 | The five reason codes and what each triggers | ☐ | ☐ |
| §2.6 | Quality hold captures a footage range, with the end read-only | ☐ | ☐ |
| §2.7 | Hard block with thread mode after gauge drift or size change | ☐ | ☐ |
| §2.8 | The post-change routing table | ☐ | ☐ |
| §4.4 | The four lifecycle operations and what each captures | ☐ | ☐ |
| §4.4 | A reconditioned die returns with a reduced default life | ☐ | ☐ |
| §5 | The five life statuses | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-12 | Which die-life bands apply | | ☐ |
| — | Whether bands are configurable per die type | | ☐ |
| OI-11 | Which lines expose roll adjustment | | ☐ |
| Q65 | Waiver authority for the verification gate | | ☐ |
| Q83 | Die life tracking basis | | ☐ |
| OI-18 | Checkpoint-to-die-change link | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Maintenance** | | | |
| **Operations** | | | |
| **Quality** | | | |
| 2.5 | Aug 12, 2026 | **Question references realigned — no requirement changed.** The open-questions register was renumbered and 23 questions were withdrawn to named tracking homes in the master specification, the gap register and the PLC tag specification. Every question reference in this document was re-resolved **by subject** and rewritten to the current id; where the question it cited was withdrawn, the reference now names the tracking home. No rule, figure, screen behaviour or open item was added, removed or altered. |
