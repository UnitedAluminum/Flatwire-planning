# Flat Wire Mill — Jira Story Plan, MVP-2 Deferred Stories

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 13, 2026 — point values retained but marked **no longer comparable** with MVP-1's sizing, which moved to hours *(earlier same day: split out of [05-SprintPlanAndBacklog.md](./SprintPlan.md); story bodies otherwise April 30, 2026)*
**Document Type:** Story backlog for **MVP-2** — a sizing basis, not a schedule
**Status:** **MVP-2 — deferred scope.** Retained as the sizing basis for the deferred stories
**Scope:** 6 stories — `FW-010`, `FW-011`, `FW-012`, `FW-013` (Epic 2) · `FW-068`, `FW-069` (Epic 7)

> **⚠ Story points were retired from the MVP-1 backlog on 13 Aug 2026, and the "31 points" basis lost its sibling.** [05-SprintPlanAndBacklog.md](./SprintPlan.md) was rewritten as a sprint-wise, **hours-sized** backlog, so the `147 + 11 + 31 = 189` reconciliation no longer has two of its three terms. The point values **below are unchanged and remain this file's own basis** — MVP-2 has not been re-derived — but **they are no longer comparable with MVP-1's sizing**, and the 189-point total is retired. It is recorded in the MVP-1 file's *Appendix A — Retired point basis*.
>
> **`FW-010` remains a live dependency of two Critical MVP-1 stories** — `FW-061` (rod check-in) and `FW-082` (PLC tag push). MVP-1 only *reads* a pass schedule at check-in to build the push payload; it authors none.

---

> **⚠ MVP-2 — deferred scope.** Nothing here is part of MVP-1 or of MVP-1 planning. **Story bodies are moved verbatim**;
> no story ID, point value or acceptance criterion was altered. Where a criterion is known to be wrong, it is **flagged in
> a callout beneath the story rather than edited** — these are the bodies the MVP-2 team will work from, and silently
> correcting them here would hide the disagreement with the specifications that actually govern.
>
> **These are moves, not copies.** They were removed from `FlatWireJiraStories.md` on 13 Aug 2026, when that document was
> reduced to shopfloor MVP-1 only. **This file is now the only home for these six bodies.**

> ### Relationship to `05-Backlog-MVP2.md`
>
> [`./05-Backlog-MVP2.md`](./05-Backlog-MVP2.md) already carries **all six of these stories** as
> **condensed one-line acceptance rows** with epic, phase, stream, points and dependencies. It remains the place to look
> for the tabular view and for the `[NEW]` stories (`FW-N09` OEE) and the both-scopes split table.
>
> **This file supplies what that one does not: the full `As a` / `I want` / `So that` bodies and complete acceptance-criteria
> checklists.** The two do not disagree, and neither supersedes the other. Do not restate one in the other.

> ### ⚠ Two MVP-1 stories depend on `FW-010`
>
> **`FW-061`** (Dashboard 2 — Rod Check-in) and **`FW-082`** (PLC tag push on check-in acknowledgment) are both
> **`Critical` MVP-1** and both depend on `FW-010` below. **The dependency did not leave with the scope line.** MVP-1
> reads a pass schedule at check-in to build the PLC push payload, and `PassScheduleId` is carried on `FlatWireRun`,
> `RodCheckin`, `SpoolCheckin` and `CoilOutput` as a **documented external reference**, unenforced by design
> (`phase-01c` §Cross-DB logical FKs).

---

## Story inventory

| Story | Title | Pts | Priority | Epic | Phase |
|---|---|---|---|---|---|
| `FW-010` | Pass schedule data model and API | 5 | Critical | E02 | 2 |
| `FW-011` | Dashboard 9A — Pass Schedule List screen | 3 | High | E02 | 2 |
| `FW-012` | Dashboard 9 — Pass Schedule Management screen | 8 | Critical | E02 | 2 |
| `FW-013` | Pass Schedule — Generate from Specs algorithm | 8 | High | E02 | 2 |
| `FW-068` | Dashboard 9 & 9A — shopfloor integration | 2 | High | E07 | 2 |
| `FW-069` | Dashboard 10 — Supervisor Shift Summary | 5 | Medium | E07 | 11 |
| | | **31** | | | |

**`FW-014` (Pass Schedule — override logging) is deliberately NOT here.** It spans both scopes — the **trigger** is an
MVP-1 mid-run override on the Active Run Monitor, the **sink** `PassScheduleChangeLog` is an MVP-2 table — so it stays in
`FlatWireJiraStories.md` under the Epic 2 heading. `05-Backlog-MVP2.md` records the same decision.

**Sprint tags in the bodies below are dead.** `Sprint 2` and `Sprint 4` were superseded on 26 July 2026. Phase 2 (pass
schedule) and the Phase 11 shift summary are the roadmap homes; see
[`phases/phase-02-pass-schedule-management.md`](phases/phase-02-pass-schedule-management.md) and
[`phases/phase-11-mvp2-shift-summary.md`](phases/phase-11-mvp2-shift-summary.md).

**Effort:** Phase 2 is **231 h** all-in (**95 h** development) and moved whole;
`FW-069`'s share of Phase 11 is the **32 h** development carve. Basis:
[`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §3b and
[`DevelopmentEffortModel.md`](./DevelopmentEffortModel.md) §3.

---

# EPIC 2 — Pass Schedule Module (FW-E02)

**Goal:** Build the pass schedule data model, API and management screens, including the Generate-from-Specs algorithm.
**Sprint:** ~~2~~ → **Phase 2** *(wholly MVP-2)*
**Priority:** Critical *(within MVP-2 — the whole epic is deferred out of MVP-1)*
**Stories:** 4 of 5 · **Points:** 24 of 27 *(`FW-014` stays in MVP-1)*

---

### FW-010 · Pass schedule data model and API
**Points:** 5 · **Priority:** Critical · **Sprint:** 2

**As a** developer,
**I want** a Pass Schedule entity in the `FlatWire` microservice,
**So that** pass schedule records can be created, versioned, and queried at check-in time.

**Acceptance Criteria:**
- [ ] `PassSchedule` entity created with fields: ScheduleId, Alloy, Line (FL1/FL2/FL3), Description, Status (Draft/Active/Inactive), RouteMode (Standalone/Hybrid), TargetGauge, GaugeTolerance, TargetWidth, WidthTolerance, LineSpeedMinFPM, LineSpeedMaxFPM, CreatedBy, CreatedAt, ModifiedBy, ModifiedAt
- [ ] `PassScheduleComponent` child entity: ComponentName (DB1/DB2/FM1/FM2_S1/FM2_S2/FM2_S3/EdgeSet), **`State` — the three-value enum `{Active, Bypass, Skip}`**, ParameterValue (die size or roll gap), **EdgeType (`Round`/`Square`)**
  - ⚠ **Corrected 13 Aug 2026.** This read `IsActive (bool)`, which **cannot express Bypass vs Skip** and contradicted `FW-012`'s own three-state UI in the same epic. `EdgeType` read `Round/Flat`; the domain vocabulary is **`Round`/`Square`** — *Flat* was a third wording that nothing mapped to *Square*. Both are settled in [04-APIContract.md](../40-backend/APIs.md) *Common Enums*.
- [ ] `PassScheduleOverride` entity for run-level gap adjustments: RunId, ComponentName, OldValue, NewValue, Reason, OperatorId, Timestamp, FootagePosition
- [ ] CRUD API endpoints: GET list, GET by ID, POST create, PUT update, PATCH status
- [ ] Only Active schedules are returned by the check-in query endpoint
- [ ] Draft schedules cannot be acknowledged at check-in
- [ ] Inactive schedules are hidden from check-in but retained for history

**Dependencies:** FW-004 *(alloy lookup — **MVP-1**, `phase-13` reference data)*

> **⚠ The three `PassSchedule*` tables are MVP-1, not MVP-2 — `D-31`, 15 Aug 2026.** MVP-1 *builds* them and never *authors* a schedule: no create, edit, approve or list, no endpoint, and nothing in MVP-1 populates them in production (`OI-110`). They live with the MVP-1 chain in they live in [`../DBChanges/`](../../MVP-1/ProjectPlan/Database/Schema/SQL/), not in the MVP-1
> DDL runner. But **`FW-006` ("Create FlatWireDB — core entity tables") in MVP-1's Epic 1 also lists `PassSchedule`** —
> so table ownership is stated two ways across the scope line. Raised 13 Aug 2026; `FW-006` is a **third** both-scopes
> story alongside `FW-014` and `FW-N07`, and appears in no scope table.

---

### FW-011 · Dashboard 9A — Pass Schedule List screen
**Points:** 3 · **Priority:** High · **Sprint:** 2

**As an** Operations Manager,
**I want** a searchable list of all pass schedule records,
**So that** I can find, open, or create schedules without knowing the exact ID.

**Acceptance Criteria:**
- [ ] Grid displays: Schedule ID, Description (with "In use: FW-XXXXX" chip when active on a job), Alloy badge, Line tag (FL3 shown in purple), Route (Standalone/Hybrid), Status badge (● Active / ◆ Draft / ○ Inactive), Last Modified (date + operator name), Open button (↗)
- [ ] Toolbar: live search (matches ID, description, alloy as user types), Alloy dropdown filter, Line dropdown filter, Status dropdown filter — all four apply simultaneously
- [ ] Stats strip: N total · N Active · N Draft · N Inactive — updates as filters change; active filter controls highlighted amber
- [ ] "+ New Schedule" button opens choice popup: "Enter manually" or "Generate from specs"
- [ ] "⚡ Generate from Specs" toolbar shortcut opens generation modal directly
- [ ] Clicking any row or the ↗ button opens Dashboard 9 for that record
- [ ] Empty state message shown when no records match filters
- [ ] Column headers are sortable; active sort column shows arrow indicator

**Dependencies:** FW-010

---

### FW-012 · Dashboard 9 — Pass Schedule Management screen
**Points:** 8 · **Priority:** Critical · **Sprint:** 2

**As an** Operations Manager,
**I want** to create and edit pass schedule records with full component configuration,
**So that** operators have the correct machine setup available at check-in.

**Acceptance Criteria:**
- [ ] Header: Schedule ID (auto-generated), Alloy, Line, Description, Status badge, Last Modified
- [ ] Component Configuration table: one row per component (DB1, DB2, FM1, Edge Set, FM2 S1 (8"), FM2 S2 (6"), FM2 S3 (6", final)), with toggle (Active/Bypass/Skip), parameter input (die diameter or roll gap), edge type selector where applicable
- [ ] FM2-6"S2 cannot be set to Bypass/Skip — enforced in UI and API
- [ ] Targets section: Output Gauge + tolerance, Output Width + tolerance, Line Speed range
- [ ] Override Log panel: last 5 overrides shown (date, operator, component, old→new, reason)
- [ ] Footer actions: Generate from Specs, Copy Schedule, Deactivate, Discard Changes, Save Changes / Save as Active
- [ ] "← All schedules" back button navigates to Dashboard 9A
- [ ] Only Operations Manager / Maintenance roles can edit; operators see read-only view
- [ ] All saves are audit-logged

**Dependencies:** FW-010, FW-011

> **⚠ The mandatory-stand criterion names a component that no longer exists.** *"FM2-6"S2 cannot be set to
> Bypass/Skip"* uses the **retired** pre-`D-26` naming. Under the three-stand model (4 Aug 2026) the final,
> non-bypassable stand is **`FM2_S3`** — `FM2_6inS2` mapped to it, and the old `FM2_6inS3` was **withdrawn as
> never-existent**. The component list in the row above is already correct (`FM2 S1 (8")` · `S2 (6")` · `S3 (6", final)`),
> so this one criterion contradicts its own story. **Build to `FM2_S3`.** Master spec §10.2, decision `D-26`.

---

### FW-013 · Pass Schedule — Generate from Specs algorithm
**Points:** 8 · **Priority:** High · **Sprint:** 2

**As an** Operations Manager,
**I want** to generate a draft pass schedule by entering only alloy, rod diameter, target gauge, and target width,
**So that** new product introductions don't require manual calculation of every die size and roll gap.

**Acceptance Criteria:**
- [ ] Two-panel modal: left panel (inputs), right panel (generated draft)
- [ ] Inputs: Alloy (dropdown), Rod diameter, Target gauge, Target width, Edge type
- [ ] Alloy limits panel updates live as alloy changes (max reduction/pass, spring-back factor, default tolerances)
- [ ] Algorithm steps implemented correctly:
  1. Pre-flatten diameter: `D_pre = sqrt(4 × target_gauge × target_width / π)`
  2. Total area reduction calculation
  3. Draw pass count logic: ≤2% → both bypass; ≤1× max → DB1 only; ≤2× max → DB1+DB2; >2× max → error
  4. Die sizes: DB1 = geometric mean(rod_dia, D_pre) snapped to nearest 0.005"; DB2 = D_pre snapped to 0.005"
  5. FM1 roll gap: `target_gauge × alloy_springback_factor`
  6. FM2 requirement: if aspect_ratio > 5.5 OR alloy = 1350 → FM2 activated; route = Hybrid FL3
  7. FM2 roll gaps, one per stand: `FM2_S1` = gauge × 1.06; `FM2_S2` = gauge × 1.02; `FM2_S3` = gauge × spring-back
- [ ] Calculation summary chips shown: Pre-flatten ⌀, Area reduction %, Draw passes, Aspect ratio
- [ ] Warnings shown for: aspect ratio > 5.5, 1350 alloy (welding wire precision mode), aspect ratio > 10, die snapping, gauge below machine minimum
- [ ] Error shown (Apply still enabled for manual review) when total reduction > 2× alloy max
- [ ] Apply populates Dashboard 9 form with generated values highlighted in purple; status set to Draft
- [ ] Draft cannot be used at check-in until saved as Active by Operations Manager
- [ ] PLC tags are never pushed during generation — only at check-in acknowledgment

**Dependencies:** FW-010, FW-004

> ### ⚠ Do not implement the algorithm from the criteria above
>
> **Build `FW-013` to [`../10-requirements/screens/PassScheduleGenerationSpec.md`](../10-requirements/screens/PassScheduleGenerationSpec.md) v1.5**, which is the **engineering basis and wins on physics *and* arithmetic**. The criteria above are the April narrative and are wrong on five counts, the same five that make master-spec `FR-381`/`FR-384`–`FR-387` wrong (arbitrated in `../10-requirements/MasterSpecification.md` §10.5):
>
> | Step above | Why it is wrong |
> |---|---|
> | 1 — `D_pre` | The pre-flatten diameter is a **lower bound**, not the answer, and needs the round-edge correction |
> | 3 — pass-count branches | The branch thresholds are wrong; drawing and rolling must be separated |
> | 4 — die snapping | The final die may **not** be snapped **down** from that bound (`R36`/`V39`) |
> | 5 / 7 — roll gap | The gap sits **below** gauge by a **load-dependent mill-spring** term, not above it by a fixed alloy "springback" multiplier — a **machine stiffness** being carried as a material property |
> | 6 — FM2 requirement | The finishing-mill test is **not** the route decision. The non-hybrid default bypasses `FM2_S1`/`FM2_S2`, leaving the **skim stand as the only active stand** |
>
> **The contract shape is untouched** — the envelope and `FR-389`–`FR-391` stand. Also do **not** implement from
> `APIContracts.md:604-663`: its worked example contradicts its own formula (`REVIEW.md` Tier 1 #1).

---

# EPIC 7 — Shopfloor Flat Wire UI (FW-E07)

**Goal:** *(MVP-2 members only — the other 13 stories in this epic are MVP-1 and remain in `FlatWireJiraStories.md`.)*
**Sprint:** ~~4~~ → **Phase 2** (`FW-068`) · **Phase 11** (`FW-069`)
**Stories:** 2 of 15 · **Points:** 7 of 72

---

### FW-068 · Dashboard 9 & 9A — Pass Schedule screens (Shopfloor integration)
**Points:** 2 · **Priority:** High · **Sprint:** 4

**As an** Operations Manager using the shopfloor app,
**I want** to navigate to Pass Schedule Management from the shopfloor UI,
**So that** I don't have to switch to a separate application to create or modify a schedule.

**Acceptance Criteria:**
- [ ] Dashboard 9 and 9A are accessible from the shopfloor navigation (role-gated: Operations Manager only)
- [ ] Navigation from Dashboard 9A back to the last screen works correctly
- [ ] Pass schedule screens function identically to web UI versions
- [ ] Floor operators see pass schedule as read-only from Dashboard 2 / Dashboard 5

**Dependencies:** FW-011, FW-012, FW-013

---

### FW-069 · Dashboard 10 — Supervisor Shift Summary
**Points:** 5 · **Priority:** Medium · **Sprint:** 4

**As a** supervisor,
**I want** an end-of-shift summary showing throughput, quality, weld events, and material status,
**So that** I can review the shift's performance without querying individual reports.

**Acceptance Criteria:**
- [ ] Throughput: Orders Run, Footage, Weight, Coils Out, Skids
- [ ] Quality: SPC Pass Rate %, WIP Rejections count + reasons breakdown, Suspended Material
- [ ] Line Utilisation: FL1/FL2/FL3 utilisation %; Total Downtime minutes; Downtime reason breakdown (Equipment/Material/Quality/Operational/Safety)
- [ ] Weld Events: per-line weld count; each weld listed (Rod Alpha → Rod Alpha, footage, pass/fail)
- [ ] Material Status: Rod in Storage count, Spools on Floor, Coils in Packing, WIP Held, Scrapped Today
- [ ] Export Shift Report action; Print action
- [ ] Pause events roll up into downtime correctly

**Dependencies:** FW-062, FW-063, FW-065, FW-067

> **⚠ Every figure on this screen is blocked by `OI-101` — shift boundaries are undefined.** Until UA states when a
> shift starts and ends, none of the throughput, quality, utilisation or downtime numbers above can be computed.
> Its owning specification is [`../10-requirements/screens/ShiftSummary.md`](../10-requirements/screens/ShiftSummary.md), and
> `OI-102` (export format) blocks the Export action. **All four of its dependencies are MVP-1 stories**, so this screen
> is the one MVP-2 item that cannot start until MVP-1's Phase 6/7 work is done.

---

## Related Documents

| Document | Purpose |
|---|---|
| [`./05-Backlog-MVP2.md`](./05-Backlog-MVP2.md) | The **condensed row view** of these same six stories, plus the `[NEW]` `FW-N09` OEE story and the both-scopes split table |
| [05-SprintPlanAndBacklog.md](./SprintPlan.md) | The **35 MVP-1 shopfloor stories / 147 points** these were split from, the points legends, and the sprint → phase crosswalk these dead Sprint tags resolve through |
| [`../10-requirements/screens/PassScheduleGenerationSpec.md`](../10-requirements/screens/PassScheduleGenerationSpec.md) | **v1.5 — the engineering basis `FW-013` must be built to**, winning on physics and arithmetic over `FR-380`–`FR-391` |
| [`../10-requirements/screens/PassScheduleManagement.md`](../10-requirements/screens/PassScheduleManagement.md) | Owning specification for DB9/DB9A (`FW-011`, `FW-012`) — and §3.3–§3.4 is the **only** surviving home of the Operations Manager role definition, which MVP-1 still needs for `FR-212` |
| [`../10-requirements/screens/ShiftSummary.md`](../10-requirements/screens/ShiftSummary.md) | Owning specification for DB10 (`FW-069`) |
| [`phases/phase-02-pass-schedule-management.md`](phases/phase-02-pass-schedule-management.md) | Phase 2, moved whole with its **231 h** |
| [`phases/phase-11-mvp2-shift-summary.md`](phases/phase-11-mvp2-shift-summary.md) | The **71 h** Phase 11 carve that `FW-069` sits in |
| [`../30-database/sql/README.md`](../30-database/sql/README.md) | The `PassSchedule*` tables — **MVP-1 since `D-31`** — tables `FW-010` creates |
