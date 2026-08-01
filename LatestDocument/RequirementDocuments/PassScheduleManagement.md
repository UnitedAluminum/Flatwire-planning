# Flat Wire Processing — Pass Schedule Management Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3
**Version:** 2.0
**Last Updated:** August 1, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 9 — Pass Schedule Management · Dashboard 9A — Schedule List
**Requirement source:** SRS pass-schedule rules (`PSM005`–`PSM010`), `FR-364` (schedule content)

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | Apr 24, 2026 | Initial integration analysis — the acknowledgement gate, role separation, override logging, and eight integration questions. |
| 1.1 | Apr 28, 2026 | Attribute-based schedule resolution at check-in confirmed; FL3 hybrid confirmed as a single unified schedule. |
| 1.2 | May 4, 2026 | Mid-run configuration change flow confirmed; pass-schedule metadata confirmed as recorded at coil creation but not printed on the customer label. |
| 2.0 | Aug 1, 2026 | **Issued for client review.** The **pass schedule generation algorithm previously carried here is removed** — it has been superseded in full by the dedicated Pass Schedule Generation Specification, and the physics in the earlier version is known to be wrong. Restructured as a client deliverable: the eight gap analyses replaced by the rules they produced, with the residue carried as open items. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 8. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

The pass schedule is the **central control record of flat wire manufacturing**. It determines which components are active and which are bypassed, the die sizes, the roll clearances, the target gauge and width at each stage, the line speed and reduction percentages, the edger configuration, and the route mode.

This document specifies how a pass schedule is managed, how it reaches the machine, who may change it, and what happens when it changes mid-run.

## 1.2 Why it is the highest-priority dependency

Nothing on the line is configured by hand. The operator does not set die sizes or roll gaps — **the system pushes them from the acknowledged pass schedule**. That makes the schedule the single point at which a wrong value becomes wrong product, and it makes the acknowledgement the single point at which a human confirms the configuration before it reaches the machine.

## 1.3 Scope

**In scope:** the lifecycle from authoring through approval, resolution at check-in, acknowledgement, execution and mid-run change; role separation and access; override logging; and how the configuration in force is preserved for traceability.

**Not in scope:** the calculations behind a generated draft schedule — see the [Pass Schedule Generation Specification](PassScheduleGenerationSpec.md); the check-in procedure itself; SPC checkpoint procedure; die inventory management.

## 1.4 What a schedule contains `[CONFIRMED]`

| Element | Detail |
|---|---|
| Component activation | Which components are active and which bypassed |
| Die sizes | DB1 and DB2 |
| Roll clearances | FL1 and FL2 gap settings |
| Dimensional targets | Target gauge and width at each processing stage |
| Process parameters | Line speed and reduction percentages |
| Edger configuration | Edge type and stand position — **for the FL2 stands S2 and S3 only; FL1 has no edger** |
| Route mode | FL1 standalone · FL2 standalone · FL3 hybrid |

---

# 2. Lifecycle

```
   Operations authors or generates a schedule
                 │
                 ▼
   Operations approves it — it becomes active
                 │
                 ▼
   Order is planned and scheduled to a line
                 │
                 ▼
   Operator arrives with material and checks in
                 │
   System resolves the schedule by attribute lookup
                 │
   Operator reviews and CONFIRMS the schedule  ◄── the gate
                 │
                 ▼
   System writes the audit records, then PUSHES the configuration
                 │
                 ▼
   Machine runs to the pushed configuration; the run monitor
   compares live gauge and width against the schedule targets
                 │
                 ├── mid-run change? → Operations logs it → operator
                 │   acknowledges → material split → SPC checkpoint
                 │
                 ▼
   Run completes; the configuration in force is copied onto the
   coil record for audit and certification
```

---

# 3. Roles and Access `[CONFIRMED]`

| Role | May |
|---|---|
| **Operations / Maintenance** | Create, edit, approve and deactivate schedules; log overrides; view the change history |
| **Floor operator** | **View and acknowledge** only — with one exception, below |
| **Supervisor** | Authorise the exception paths defined elsewhere (checkout, variance, sequence deviation) |

## 3.1 The one operator exception `[CONFIRMED — May 4, 2026]`

A floor operator may perform a **one-for-one same-size die swap** — replacing a die with another of identical size. **Any other change must be made by an Operations Manager.** A same-size swap does not change what the machine is being asked to produce; every other change does.

## 3.2 Why the separation is enforced

The operator is the last person to see the material before it runs, which makes them the right person to *confirm* the configuration and the wrong person to *author* it. Confirmation without edit rights gives the check its value: if the schedule is wrong, the answer is to stop and have Operations correct it, not to adjust it at the line.

---

# 4. Where the Schedule Appears

| Screen | Role | Interaction |
|---|---|---|
| **Pass Schedule Management (9 / 9A)** | Author and manage | Operations creates, edits, approves and deactivates; the override log shows recent changes with date, user, parameter and reason |
| **Rod Check-in (2)** | Acknowledge | The operator views the resolved schedule read-only and confirms it; the configuration is pushed on acknowledgement |
| **Spool Check-in (5)** | Acknowledge | As above, for FL2 |
| **Active Run Monitor (3)** | Execute and monitor | Shows which components are active, the die sizes, roll gaps and targets; live gauge and width are compared against those targets |
| **Line Status Board (1)** | Supervise | Displays the **active schedule identity per line**, so a supervisor has configuration context when an alert is raised |
| **SPC Checkpoint (6)** | Control | A configuration change raises a checkpoint |
| **Weld Event (4)** | Trace | Traceability is tied to the schedule's route mode |
| **Coil Completion (7)** | Audit | The configuration in force is recorded against the finished coil |
| **WIP Rejection (8)** | Quality | The schedule in use is shown on the rejection, so a pattern can be traced back to configuration |

---

# 5. Confirmed Rules

## 5.1 Acknowledgement is the machine gate `[CONFIRMED]`

**No configuration is pushed until the operator has explicitly acknowledged the schedule.** There is no automatic push. The operator cannot accidentally bypass the confirmation, because pressing the check-in action is not itself the gate — the confirmation is.

## 5.2 Schedule resolution at check-in `[CONFIRMED — April 28, 2026]`

Schedules are **not assigned during planning**. They are resolved when the job is actually set up on the line.

| Rule | Detail |
|---|---|
| Lookup basis | Alloy + rod diameter + target gauge × width + route mode |
| Presentation | The recommended schedule is surfaced with the attributes it matched on |
| Confirmation | Explicit, and mandatory before the acknowledgement action becomes available |
| Substitution | A *change* option lists the alternatives; selecting a non-recommended schedule requires a **free-text reason** and is **flagged for Operations review** |

## 5.3 Component visibility `[CONFIRMED]`

Both check-in screens show the component table with each component's active or bypassed state, so the operator can visually confirm the machine configuration before acknowledging it.

## 5.4 Override logging `[CONFIRMED]`

Every change is logged with the parameter changed, the value before and after, the user, the timestamp, and a reason code or free text. The management screen surfaces the recent history directly, so the last changes are visible without running a report.

## 5.5 FL3 hybrid uses a single unified schedule `[CONFIRMED — April 28, 2026]`

A hybrid run is governed by **one** schedule record covering both the drawing stage (DB1, DB2, FM1) and the finishing stage (the FM2 stands), tagged with route mode *hybrid*. Route mode is part of the attribute lookup, so a hybrid schedule is only ever recommended for a hybrid run.

Standalone FL1 and FL2 runs use distinct schedules of their own.

## 5.6 Mid-run configuration change `[CONFIRMED — May 4, 2026]`

Four steps, in order.

| Step | Detail |
|---|---|
| **1 — Operations logs the change** | Parameter changed, old value, new value, user, timestamp, and reason |
| **2 — The operator must respond** | The change is pushed to the active run monitor as an alert requiring an explicit response: **acknowledge** (understood; production continues under the new configuration) or **stop run** (not comfortable; supervisor review before proceeding). **Passive dismissal is not permitted** |
| **3 — Material is separated by configuration** | The footage counter is captured at the moment of the change. A **same-product change** (within-spec tooling, gauge control adjustment) is recorded as a configuration event on the existing material identity at that footage. A **product specification change** (die size, edge type, roll gap to a new target) **closes** the existing identity at that footage and opens a child identity under the updated schedule |
| **4 — Verification is required** | The change raises an **SPC checkpoint**. The run monitor shows the awaiting-checkpoint state, and the operator cannot clear it without completing the checkpoint |

**Why step 2 exists.** The new configuration is in the database as soon as Operations saves it, but the machine continues under the **previously pushed values** until the operator acknowledges. The acknowledgement is what bridges that gap — without it, the record and the machine disagree with nobody aware of it.

## 5.7 Configuration traceability at coil creation `[CONFIRMED — May 4, 2026]`

| Rule | Detail |
|---|---|
| **On the customer label** | **No.** Schedule identity, die sizes and roll gap values do not appear on the coil label |
| **On the coil record** | **Yes.** The schedule identity, version and effective configuration are written to the coil record **when the coil identity is generated** |
| **Access** | Available to quality auditors and engineering through internal screens |

**Why it is captured rather than referenced.** If the schedule is edited after the run, the configuration actually in force cannot be reconstructed from a live reference. Any question of the form *"what die sizes, edge configuration and roll gaps produced this coil"* must resolve from the stored snapshot, not from the current schedule.

## 5.8 Schedule identity on the line status board `[CONFIRMED — May 4, 2026]`

Each line card displays the active schedule identity alongside order, speed, gauge and width, so a supervisor can verify configuration at a glance and has the context to interpret an alert.

---

# 6. Generation from Specifications

A schedule may be authored manually or **drafted by the generation engine** from product inputs — alloy, incoming rod size, target dimensions and edge profile.

**The engine and its engineering basis are specified separately, in the [Pass Schedule Generation Specification](PassScheduleGenerationSpec.md).** That document is the authority on the calculations, the required master data, the validation framework and the information United Aluminum must supply.

Two constraints belong here because they are management rules rather than engineering ones:

| Rule | Detail |
|---|---|
| **A generated schedule is a draft** | It carries a pending-review state and requires Operations approval before it can be used |
| **Generation never reaches the machine** | No configuration is pushed at generation or approval time. A generated schedule becomes live by exactly the same route as a hand-authored one: Operations activates it, and the operator acknowledges it at check-in |

> **Removed from this document.** Version 1.1 carried a generation algorithm of its own — pass-count branches, die sizing, spring-back and stand activation. **It is superseded and its pass-count logic is known to be incorrect.** It has been removed rather than corrected, so that only one description of the engine exists. Implement from the generation specification.

---

# 7. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | Configuration is pushed **only** after explicit operator acknowledgement | Apr 2026 |
| D2 | Floor operators have **read-only** access, with the single one-for-one same-size die swap exception | May 4, 2026 |
| D3 | All changes are logged with parameter, values, user, timestamp and reason | Apr 2026 |
| D4 | Schedules are resolved **at check-in** by attribute lookup, not assigned at planning | Apr 28, 2026 |
| D5 | Selecting a non-recommended schedule requires a reason and is flagged for Operations review | Apr 28, 2026 |
| D6 | **FL3 hybrid uses a single unified schedule** covering both stages | Apr 28, 2026 |
| D7 | The **four-step mid-run change flow**, including mandatory operator response and an automatic SPC checkpoint | May 4, 2026 |
| D8 | Schedule metadata is **recorded on the coil record at creation, and never printed on the customer label** | May 4, 2026 |
| D9 | The **active schedule identity is displayed on the line status board** | May 4, 2026 |
| D10 | A generated schedule is a **draft requiring approval**; generation never pushes configuration | Apr 2026 |

---

# 8. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **PSM-1** | High | **The no-match path.** When the attribute lookup finds no active schedule for an order's attributes — the first run of a new product variant — is check-in **blocked** with an alert to Operations, or may the operator proceed under an Operations-Manager override with a logged reason? Our recommendation is to block, with a direct route to schedule management | Any new product variant reaching the line |
| **PSM-2** | Medium | **Hybrid-origin spools at FL2.** If a spool produced by a hybrid FL3 run is later loaded on FL2 for a standalone pass, must the system refuse a standalone schedule without an explicit re-classification, or treat it as any other spool? | FL2 check-in validation |
| **PSM-3** | Medium | **Planning-side validation.** Should planning warn when a job is scheduled to a line for which **no schedule exists** for that product and alloy — so the shortfall is caught before material reaches the floor rather than at check-in? | Preventing a blocked line |
| **PSM-4** | Low–Medium | **The quality feedback loop.** Should recurring rejections under the same schedule raise a review — for example, *n* rejections of the same reason within a period flagging the schedule for Operations? Without it, a schedule whose targets are unachievable on the machine may never be identified as the cause | Whether rejection-pattern reporting is in scope |
| **OI-04** | High | **Which finishing stand cannot be bypassed** — 6″ S2 or 6″ S3. Three artifacts enforce a rule the equipment correction moved | Schedule validation and the configuration pushed |
| **OI-05** | Medium | **`Bevel edge`** is offered in the generation modal but is not a valid edge type — the domain allows only round and square. Add it, or remove the option | Edge configuration |

---

# 9. Future Enhancements

Recorded as direction, not as commitments in the current scope.

| Enhancement | Value |
|---|---|
| **Schedule version control with rollback** | Return to a previous version when a current one is implicated in quality failures |
| **Data-driven refinement** | Use accumulated SPC results, rejections and throughput to tune the generation engine's default coefficients |
| **Cross-line validation** | For hybrid and any future multi-line process, verify that linked lines carry compatible schedules before both are scheduled |

---

# 10. Assumptions

| # | Assumption |
|---|---|
| A1 | Operations maintains the schedule library; the system does not create active schedules without human approval. |
| A2 | Order attributes — alloy, rod diameter, target gauge and width, edge type — are available at check-in for the lookup. |
| A3 | An operator session carries a role, so the read-only restriction can be enforced rather than relied upon. |
| A4 | The footage counter is available at the moment of a mid-run change, so material can be separated by configuration. |
| A5 | Coil identity generation is a system event that can carry the configuration snapshot with it. |

---

# 11. Related Specifications

| Document | Relationship |
|---|---|
| [Pass Schedule Generation](PassScheduleGenerationSpec.md) | **The authority on the generation engine** — calculations, master data, validations |
| [Rod and Spool Check-in](RocCheckin.md) | Where the schedule is resolved, confirmed, acknowledged and pushed |
| [SPC Checkpoint](SPCCheckpoint.md) | The verification a configuration change raises |
| [Die Change and Die Management](DieChangeAndManagement.md) | Die sizes are schedule parameters; a size change is a configuration change |
| [HMI and SCADA Layout](HMIAndSCADALayout.md) | Displays the configuration in force against live measurement |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §3 | Role separation, and the one-for-one same-size die swap exception | ☐ | ☐ |
| §5.1 | Acknowledgement is the only gate to a configuration push | ☐ | ☐ |
| §5.2 | Attribute-based resolution at check-in; substitution requires a reason | ☐ | ☐ |
| §5.4 | Override logging content | ☐ | ☐ |
| §5.5 | FL3 hybrid uses a single unified schedule | ☐ | ☐ |
| §5.6 | The four-step mid-run change flow, with mandatory operator response | ☐ | ☐ |
| §5.6 | Material separation — configuration event versus child identity | ☐ | ☐ |
| §5.7 | Configuration recorded at coil creation, never on the customer label | ☐ | ☐ |
| §5.8 | Schedule identity shown on the line status board | ☐ | ☐ |
| §6 | Generated schedules are drafts; generation never pushes configuration | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| PSM-1 | The no-match path at check-in | | ☐ |
| PSM-2 | Hybrid-origin spools at FL2 | | ☐ |
| PSM-3 | Planning-side schedule validation | | ☐ |
| PSM-4 | Whether rejection-pattern reporting is in scope | | ☐ |
| OI-04 | Which finishing stand is non-bypassable | | ☐ |
| OI-05 | Whether `Bevel` is a real edge type | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Process Engineering** | | | |
| **Quality** | | | |
| **IT** | | | |

---

## Change Log

| Date | Change |
|---|---|
| Apr 24, 2026 | Initial integration analysis — acknowledgement gate, role separation, override logging, eight integration questions. |
| Apr 28, 2026 | Attribute-based resolution at check-in and the single unified FL3 hybrid schedule confirmed. |
| May 4, 2026 | Mid-run configuration change flow confirmed, including mandatory operator response and the automatic verification checkpoint; configuration confirmed as recorded at coil creation and excluded from the customer label. |
| Aug 1, 2026 | **Reissued as version 2.0 for client review.** **The generation algorithm carried in earlier versions is removed** — superseded in full by the Pass Schedule Generation Specification, and its pass-count logic was incorrect; only the two management-level constraints on generation are retained here. The eight gap analyses replaced by the confirmed rules they produced (D1–D10), with the unresolved residue carried as PSM-1 to PSM-4. Added the FL1 no-edger and FM2 stand corrections to the schedule content definition, and raised the non-bypassable-stand and edge-type vocabulary conflicts. |
