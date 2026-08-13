# MVP-2 Development Plan — Deferred Scope

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**

---

> **⚠ Nothing here is part of MVP-1 or of MVP-1 planning.** Created 11 Aug 2026 by dividing `DevelopmentPlan/` against MVP-2. **Every extracted section is verbatim** — no requirement, story, estimate or identifier was altered.

## What is here

| File | Contents | How it was divided |
|---|---|---|
| [`PassScheduleGenerationSpecPrompt.md`](PassScheduleGenerationSpecPrompt.md) | The prompt that produced `PassScheduleGenerationSpec.md` | **Moved whole** — it authored an MVP-2 deliverable |
| [`ShopfloorPlan/phase-02-pass-schedule-management.md`](ShopfloorPlan/phase-02-pass-schedule-management.md) | Phase 2, complete | **Moved whole, with its 231 h** |
| [`ShopfloorPlan/phase-11-mvp2-shift-summary.md`](ShopfloorPlan/phase-11-mvp2-shift-summary.md) | DB10 and `GET /shiftsummary` | **Partial** — carved at bullet level |
| [`ShopfloorPlan/phase-13-mvp2-die-management.md`](ShopfloorPlan/phase-13-mvp2-die-management.md) | Die Management screen and lifecycle service | **Partial** — carved at bullet level |

## Effort is apportioned (11 Aug 2026)

**Phase 2's 231 h is genuine** — the phase moved whole, so its published figure moved with it. **It does not come back:** pass schedule generation and management are owned by a separate track, not deferred within MVP-1.

**The two partial files now carry derived figures**, and they were derived rather than divided. The published totals could not be split proportionally, because the descope ladder does not align with the MVP boundary:

| Ladder rung | Figure | Why it is not the MVP-2 share |
|---|---|---|
| **Rung 5** — "Phase 13 non-critical (Die Management screen, role assignment UI)" | 99 h | Bundles the **MVP-2** Die Management screen with the **MVP-1** role-assignment UI, with no split between them |
| **Rung 6** — "Phase 11 reports FW-092/093/094/095 (4 of 5)" | 105 h | Those four reports are **MVP-1**. The rung says nothing about DB10 |

So each carved deliverable was **re-priced from the rate card** in [`../../MVP-1/DevelopmentPlan/CapacityAndEffortModel.md`](../../MVP-1/DevelopmentPlan/CapacityAndEffortModel.md) §2, and QA and contingency **re-derived** from the reduced base:

| Phase | MVP-2 share | What it covers | MVP-1 keeps |
|---|---|---|---|
| **2** | **231 h** | The whole phase | — |
| **11** | **71 h** | DB10 screen (24 FE) · `GET /shiftsummary` + `ShiftSummaryService` (20 BE) · `sp_ShiftSummary` (8 DB) | **175 h** — the report suite and welding-wire certification |
| **13** | **66 h** | Die Management screen (24 FE) · die lifecycle service (16 BE) · **die inventory table (8 DB)** | **143 h** — alloy lookup, machine tabs, role assignment |

**The die inventory table moved here, reversing an earlier instruction.** It had been costed at 8 h in the MVP-1 phase because MVP-1's die change was thought to need it for `D4`. Die inventory and lifecycle are now wholly MVP-2, so the table comes with the screen — and MVP-1's `D4` is restated at **die-size** level against the `Drawer` catalogue. `FW-N07` is therefore wholly MVP-2, not a story spanning both scopes.

**MVP-1 totals 3,292 h / 9.4 FTE** (both scopes: 3,660 h / 10.4 — the long-quoted **3,727 was a stale TOTAL row**, corrected 11 Aug 2026 when the 4 Aug Phase-5 descope was found never to have reached it). Working in **§3b** of the effort model.

> **This did not fix the schedule, and should not be reported as if it had.** Phase 2 sat in **W2–W3**, which the model already showed at 5.3 FTE — the slackest weeks in the plan. They fall to 2.4. **W4 and W5 do not move at all**, W6 goes 14.7 → 12.9, and **W7 is still 24.5 FTE against a three-day week.** The programme decision in §7 stands unchanged.

## The contradiction this division exposed — and how it was resolved

Phase 2 is **wholly MVP-2**, and the roadmap described it as **"Not deferrable — the highest-priority dependency in the plan; gates every check-in phase."** Both statements were accurate, which was the problem:

- Rod check-in **acknowledges a pass schedule and pushes PLC tags from it**.
- `FW-061` (rod check-in) and `FW-082` (PLC tag push) are both **Critical MVP-1** and both declared a dependency on `FW-010`.
- The three `PassSchedule*` tables are in [`../DBChanges/`](../DBChanges/), and four MVP-1 tables carry a `PassScheduleId`.

**Resolved 11 Aug 2026 by separating authoring from reading.** Pass schedule generation and management are owned by a **separate track** — not deferred inside MVP-1, and not returning. MVP-1 **never creates, edits or approves** a schedule; it **reads** one at check-in to build the PLC push payload, and persists a snapshot of what it pushed.

Three consequences, each recorded where it applies:

1. **`phase-04` treats the schedule as an external interface**, not a Phase-2 deliverable. It carries a read contract: the six value groups from `[PLC §351–356]`, who owns them, what happens when the source is unavailable (check-in cannot proceed — no schedule, no push), and the snapshot rule.
2. **`PassScheduleId` is a documented external reference** on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput` — unenforced *by design*, the same class as `PlanId`, `CoilOrderPlanId` and `SkidId`. It is not a missing FK. `FlatWire_DDL_RunAll.sql` produces a complete MVP-1 database, and **MVP-2's `06b` is irrelevant to an MVP-1 build**.
3. **`PLCTagSpecification.md:42` already read this way** — it lists *"the pass schedule's contents and how it is authored or generated"* under **Not in scope**. The client-facing PLC spec was written on this assumption before the split made it explicit.

**One item remains open** and is not dissolved by any of the above: `PassScheduleManagement.md` §3.3–§3.4 holds the **only Operations Manager role definition**, and MVP-1 enforces that role — `FR-212` restricts reverting a roll-gap override to it on **DB11 Roll Adjust**. See [`../README.md`](../README.md).

## Both MVP-1/MVP-2 seams are now closed

Two seams once ran through this folder — a piece of MVP-1 work living inside a deferred screen. **Neither survives**, and the resolutions are recorded here because the partial files are otherwise silent about why they shrank:

1. ~~**`CoilCompletionService`** (phase 9) generates the coil alpha and drives DB7 — but it also builds the `CoilTraceability` rows the welding-wire certificates depend on. Splitting it is a design decision nobody has taken.~~ **Resolved — the service does not split. Phase 9 is wholly MVP-1**, screens included, and `phase-09-mvp2-output-coil-completion.md` was deleted. DB7 owns three decisions no headless service can make: the scale override on weight, 1-of-2 versus 2-of-2 on the skid, and suspend on an out-of-spec final SPC.
2. ~~**The die inventory table** (phase 13) is costed at 8 h in the MVP-1 file while its screen is here.~~ **Resolved the other way — the table is MVP-2.** Die inventory and lifecycle are out of MVP-1 entirely; only the **mid-run die change event** stays. The 8 h moved here with the screen, and MVP-1's `D4` was restated at **die-size** level against the `Drawer` catalogue rather than per physical tool. `FW-N07` is therefore wholly MVP-2, not a story spanning both scopes.

## What stayed in MVP-1

All of it is cross-cutting or MVP-1-owned, and **none of it is duplicated here**:

| Artifact | Why |
|---|---|
| `ShopfloorAndRealTimePlan.md` | The roadmap index — one plan, both scopes. Its phase table now flags which rows are split |
| `ShopfloorPlan/00-foundations.md` | §0.2 reference map, §0.3 domain cheat-sheet, §0.4 real-time architecture. Carries an explicit **do-not-restate** rule |
| `ShopfloorPlan/back-matter.md` | Dependency chain, milestone calendar, **gaps register G1–G35** |
| `CapacityAndEffortModel.md` | See above — annotated, not divided |
| `phase-01`, `03`–`08`, `10`, `12`, `14` | Wholly MVP-1 |
| `phase-09`, `11`, `13` | The MVP-1 remainder of each split phase |
| `REVIEW.md` | Audits documents in both scopes |
| `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md` | The four April-dated **split-brain** docs. Known superseded by the July roadmap; **not** divided, because dividing a knowingly-broken document doubles the places its bugs live. `APIContracts.md`'s `/passschedule/generate` example is `REVIEW.md` Tier 1 #1 |
| `PLCTagImplementation.md` | The internal half of the PLC tag surface — MVP-1, and it carries **no tag path strings** by rule |
| `WeldEventPopupPlan.md` | MVP-1 feature. *(Reduced to a record on 13 Aug 2026. The two `Checkin*` documents were reduced the same day and then **deleted**, as was `RodPreCheckinUxReviewPrompt.md` — all recoverable at `1964086`.)* |
| `Tools/build_docx.py` | Renders client deliverables in **both** scopes |
| `Flat Wire.code-workspace` | Opens the repo alongside `ual-angular` / `ual-api` |
