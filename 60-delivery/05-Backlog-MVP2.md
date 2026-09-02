# Flat Wire Mill — Backlog, MVP-2 Deferred Stories

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**
**Extracted from:** [`./TaskBreakdown.md`](./TaskBreakdown.md) §7.2–§7.3, 11 Aug 2026

---

> **⚠ MVP-2 — deferred scope.** Nothing here is part of MVP-1 or of MVP-1 planning. Rows are **copied verbatim**; no story ID, estimate or acceptance criterion was altered.
>
> **These rows are copies, not moves.** They remain in the MVP-1 backlog, marked as deferred, because **§11 of that document is the coverage matrix proving every `FR-###` reaches a story** — removing rows would leave requirements looking uncovered. The MVP-1 document stays authoritative for estimates and the dependency chain.

> **`FW-066` returned to MVP-1 on 11 Aug 2026** with Phase 9 (DB7 + DB7b coil completion), so its row was removed here rather than left as a copy. Seven deferred stories remain.

## Deferred stories

| ID | Title | Epic | Phase | Stream | Pts | Priority | Depends on | Acceptance |
|---|---|---|---|---|---|---|---|---|
| **FW-010** | Pass Schedule data model + API | E02 | 2 | BE | 5 | Critical | FW-006 | **Given** an Operations user, **when** they create a schedule, **then** it starts `Draft`, **and** at most one `Active` schedule exists per `(LineId, Alloy)`. **Component state is the three-value enum, not `IsActive` bool.** |
| **FW-011** | Dashboard 9A — schedule list | E02 | 2 | FE | 3 | High | FW-010 | **Given** schedules exist, **when** search, alloy, line and status filters are applied, **then** they apply simultaneously, the stats strip updates, and any non-"All" filter renders amber. |
| **FW-012** | Dashboard 9 — schedule management | E02 | 2 | FE | 8 | Critical | FW-010 | **Given** a schedule open for edit, **when** the operator toggles components, **then** the mandatory final stand is locked on, bypassed rows read "Bypassed · no parameters", edger rows offer an edge-type selector, **and** nothing pushes to the PLC. |
| **FW-013** | Generate-from-Specs algorithm | E02 | 2 | BE | 8 | High | FW-004 | **Given** alloy 1100, rod 0.375″, gauge 0.125″, width 0.875″, **when** generate runs, **then** it returns `preflattenDiameterIn 0.3732`, `areaReductionPct 0.95`, `drawPasses 0`, `routeMode Hybrid` with the two warnings — **not the published 0.265 / 50.1 / Standalone.** Apply stays enabled on errors; **no PLC write ever occurs**. |
| **FW-068** | DB9/9A shopfloor integration | E02 | 2 | FE | 2 | High | FW-011, FW-012 | **Given** the shopfloor shell, **when** a user opens Pass Schedules from the More Options popup, **then** DB9A opens with role-appropriate actions and operators see read-only. |
| **FW-069** | Dashboard 10 — shift summary | E07 | 11 | FE + BE | 5 | Medium | FW-007 | **Given** a shift window, **when** a machine tab is selected, **then** the KPI tiles reflect **that machine only**, the utilisation timeline shows one line (or all three on All Lines), and runs that resumed without a completed SPC checkpoint are **flagged as exceptions**. |

### `[NEW]` stories

| ID | Title | Epic | Phase | Stream | MoSCoW | Why it exists | Acceptance |
|---|---|---|---|---|---|---|---|
| **FW-N09** `[NEW]` | OEE dashboard | E07 | **unassigned** | FE + BE | **Could** | **PP-03.** The OEE dashboard has an approved mockup and 17 source requirements (`OEE001`–`OEE017`, carried as `FR-500`–`FR-508`) and **no story, no phase and no owner** | **Given** shift data, **when** OEE renders, **then** A·P·Q per line, MTBF/MTTR, the 7-shift trend and Six Big Losses display against the configurable 85 % target. **Or: formally record OEE as out of scope** |

---

## Two stories span both scopes and were **not** moved

| Story | Why it is split |
|---|---|
| **`FW-014`** Pass-schedule override logging | The **trigger** is an MVP-1 mid-run override on the Active Run Monitor, which must raise an alert that cannot be passively dismissed. The **sink**, `PassScheduleChangeLog`, is an MVP-2 table. MVP-1 therefore has an override path with nowhere to log it. |
| ~~**`FW-N07`** Die master table + Die Management screen~~ | ⛔ **NO LONGER SPLIT, AND NO LONGER MVP-2 — 2 Sep 2026 (`Q91`).** The die split settled it the way this row always read: the table was *Must*, and it is now built as **`ToolingInventoryDie`** + **`DieHistory`**, seeded in Phase 1. The **screen** came back with it, so `FR-240`–`FR-255` and `DieManagement.md` are MVP-1 too. **`OI-41` closes.** ⚠ Effort not re-costed here — see `CapacityAndEffortModel.md` §3b. *(Was: "The story's own MoSCoW split says it: the table is Must, the screen is Should… This is `OI-41`'s actual content.")* |

## The dependency that survived the scope line

`FW-010` builds the pass-schedule data model and API. It is now MVP-2. But:

| MVP-1 story | Priority | Declares a dependency on |
|---|---|---|
| `FW-061` Dashboard 2 — rod check-in | **Critical** | `FW-010`, FW-082 |
| `FW-082` PLC tag push on acknowledge | **Critical** | `FW-010` |

Rod check-in *acknowledges a pass schedule and pushes PLC tags from it*. Deferring `FW-010` does not remove that from MVP-1 — it removes the thing MVP-1 acknowledges. Resolving this is one of the open consequences in [`../95-archive/design-notes/MVP-2-scope-note.md`](../95-archive/design-notes/MVP-2-scope-note.md).
