# Flat Wire — Consolidated Parent Stories (`FS-##`)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — step 6 complete: all 20 parents authored
**Document Type:** Index — the category structure and the rules that keep this tier thin
**Status:** Active — all 20 parents authored, the task-file tier retired 9 Sep 2026. ⛔ **The §3 "merged acceptance criteria" item is CANCELLED, not outstanding** — see *Acceptance criteria are not merged up* below
**Owner:** Delivery lead
**Audience:** Anyone changing flat wire functionality, or assessing the impact of a change
**Shortcode:** — *(derived; **not** citable as a requirement)*
**Part of:** `10-requirements/features/`

---

## What this folder is

Work used to be tracked one stream's slice of one screen at a time: **204 story files** across five
`*/tasks/` folders, each owning exactly one of `FE` / `BE` / `DB` / `RT` / `QA` / `BA`. A one-line
rename of `LineId` → `MachineName` (`D-56`) became three stories; the 9 Sep reversal of FL2's gauge
trace became four. Impact analysis meant reading across dozens of files with nothing that said
*"here is this functionality and everything it touches."*

**That fragmentation was a tooling artefact, not a property of the work.** `[TB §7]` says so
outright, justifying the three-way split of one rename:

> ⚠ **One story per stream, deliberately.** `check_docs.py`'s `6-folder` rule ties a card's stream
> to the folder its plan lives in, so a single cross-stream story would have to sit in one folder
> and declare another.

Each file here is **one cohesive slice of the operator journey, across all streams**, and is the
single source of truth for what that functionality is, what it requires, where it stands and what
is open about it.

---

## The rule that keeps this tier thin

**Fifteen of the twenty categories map 1:1 to a phase specification in
[`60-delivery/phases/`](../../60-delivery/phases/)**, and those specifications already carry a
business overview, objective, user roles, entry and exit conditions, scope calls and a user
journey. Restating any of that breaks the repository's founding convention — *a fact is asserted in
one document and cited everywhere else* — and the 71 KB of `CLAUDE.md` deleted in the 29 Aug
restructure was the bill for a structure with two homes per fact.

So the rule is not *which sections exist*: all nine in the template are wanted. The rule is **what
an `FS` file may assert, versus what it must cite.**

**It may assert exactly four things, because nothing else can:**

1. **Identity** — id, title, one-paragraph business purpose, `phases:`, the `[REQ §5.x]` groups and
   the `FR` ranges it owns.
2. **The absorbed-story table** — *generated* into a marker block, never typed.
3. **The consolidated open-items roll-up** — the union of `blocked_by:` across the category, plus
   the narrative gaps no single story owns. *This exists nowhere else and is the tier's clearest
   single win.*
4. **An implementation plan, once the category is taken up**, and only for work that never had one.

**Everything else is citation-shaped** — a few sentences of orientation plus links, never a restated
body:

| For | Cite |
|---|---|
| Scope, journey, entry/exit conditions | the owning phase specification |
| Status | [`FEATURES.md`](../../FEATURES.md) |
| Hours | `[CE §3e]` and `[TB §7.3]` — **never** restate a figure |
| Requirement **text** | `[REQ §5.x]` and the owning screen specification |
| **Acceptance criteria** | the story's `######` card in [`[TB §7]`](../../60-delivery/TaskBreakdown.md) — **not** the specifications; see below |
| Build detail for work already done | the story's build record |

### ⛔ Acceptance criteria are not merged up — corrected on measurement, 9 Sep 2026

An earlier draft of this folder's rules said the cards' acceptance criteria would be **merged to the
`FR` level and cited**, on the assumption that they restated something upstream. **Measured: of
1,222 criteria, only 7 % cite any specification or `FR`.** They are original build detail — schema
invariants, seed values, deployment contracts, vendor tolerances, arithmetic rules — so for most
there is no `FR` to merge to, and stripping them would have destroyed the majority of the module's
buildable detail.

**So the cards are retained and keep their criteria.** A parent owns the *index* over them and the
coverage assertion in [`[SCM §2.5]`](../../90-registers/StoryConsolidationMap.md); it does not
restate them. Three consequences worth knowing:

- the **169 hand-authored client prose entries needed no re-authoring**, which the migration had
  budgeted for;
- every client-visible `FW-###` still resolves to a card with hours and criteria, so
  `FlatWire_DevelopmentPlan.xlsx` and `FlatWire_TrialRunPlan.xlsx` were unaffected;
- ⚠ **`G126`** — seven cards carried a criterion a completed plan had already corrected, and
  archiving those plans made the correction non-citable. All seven were lifted onto the card; the
  rest of that gap's 97 rows are unreviewed. **Do not cite `95-archive/` to resolve one.**

**Size is the enforcement, because prose has no checker.** It is measured on the **authored**
content, **excluding the generated block** — measuring the whole file would be measuring how many
stories the category absorbed, which is not something the author controls. Target **≤ 12 KB
authored**; past **14 KB**, check whether the phase specification is being restated rather than
cited. `tools/build_features.py` reports this on every run, so it is not a rule anyone has to
remember. *(A category with a large blocker roll-up legitimately runs longer: §6 and §8 are the
parent's own content and exist nowhere else.)*

### Precedence, in one line

**Card → cost · `FS` → plan · build record → build detail · `FEATURES.md` → status.**
Against a phase specification **the phase specification wins**; against a build record **the record
wins**; on any number **`[CE]` and `[TB §7.3]` win**.

### Two things an `FS` file never carries

- **No hours figure a parent invents.** The sum over the task files is 3,698 h, which matches
  **none** of the four published figures (3,186 scheduled · 3,375 reconciling · 3,358 all-in ·
  2,367 dev-only). A fifth would be a contradiction on arrival, and a per-category or per-stream
  roll-up written here *is* a fifth — it exists in no other document and nothing recomputes it.

  ⚠ **Narrowed on 9 Sep 2026, and enforced from the same day.** This read *"no hours figure — not
  per category, not a total, not for orientation"*, which was absolute and had **no checker**;
  **28 ownerless figures accumulated across ten parents** while the rule sat two clicks away,
  including invented category totals of `391 h`, `289 h`, `186 h` and `128 h`. The rule is now the
  repository's ordinary cite-once convention applied to hours: **a figure may appear only on a line
  that also names the `FW-###` that owns it, or cites `[CE]` / `[TB §7.3]` / `[TRP]` / `[SSP]` /
  `[DSP]`.** `tools/build_features.py` **fails** on any other — not a warning, a non-zero exit, so
  the pre-commit hook catches it.

  ⛔ **Why a bare number rots, in this repository's own evidence:** `FS-08` records `FW-202` being
  re-priced **4 h → 98 h**. Any parent that had printed the old figure would have been silently
  wrong, and nothing would have said so. Tying the figure to its owner does not stop the rot — only
  a generated table would — but it tells the reader exactly which card to check.
- **No `depends_on`** — consolidation turns the acyclic task graph into a cyclic category graph.
  The task graph has **one** known cycle (`FW-071`/`FW-072`, `G63`); the category graph has **15
  mutually dependent pairs**, because each has a dominant direction plus one or two minority
  back-edges. `check_docs.py` rule 2 treats a cycle as a hard error. Dependencies live **per
  activity** inside each parent, where the original granularity keeps the graph acyclic, and the
  category-level direction is recorded, generated, in
  [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

---

## The 20 categories

Numbered in **operator-journey order**, because `FS-##` ids are never renumbered once minted.
⚠ **Counts, hours and membership are not restated here** — they are generated in
[`StoryConsolidationMap.md`](../../90-registers/StoryConsolidationMap.md) `[SCM §2.1]`, which is
the authority. Category *membership* is defined in
[`tools/build_consolidation_map.py`](../../tools/build_consolidation_map.py) and nowhere else.

| Id | Category | Phase(s) | Screens |
|---|---|---|---|
| [`FS-01`](FS-01-angular-application-shell.md) | Angular Application Shell and Foundation | 1A | *all* |
| [`FS-02`](FS-02-backend-service-foundation.md) | Backend Service Foundation | 1B | — |
| [`FS-03`](FS-03-database-foundation.md) | Database Foundation and Deployment | 1C | — |
| [`FS-04`](FS-04-realtime-plc-backbone.md) | Real-Time and PLC Backbone | 1A · 1B · 3 · 4 · 5 | — |
| [`FS-05`](FS-05-pass-schedule-contract.md) | Pass Schedule — the consumer contract | 2 | DB9 · DB9A |
| [`FS-06`](FS-06-line-visibility-alerting.md) | Line Visibility and Alerting | 3 | DB1 |
| [`FS-07`](FS-07-rod-checkin-plc-config.md) | Rod Staging, Check-In, PLC Config and Weld Capture | 4 | DB2A · DB2 |
| [`FS-08`](FS-08-active-run-monitoring.md) | Active Run Monitoring and Gauge/Width Trace | 5 | DB3 |
| [`FS-09`](FS-09-in-run-production-events.md) | In-Run Production Events | 6 | DB6 · DB11 · DC |
| [`FS-10`](FS-10-exceptions-off-ramps.md) | Exceptions and Off-Ramps | 7 | DB8 · DB12 |
| [`FS-11`](FS-11-spool-lifecycle-fl2.md) | Spool Lifecycle and FL2 Finishing Run | 8 | DB5 · DB5A · DB3 |
| [`FS-12`](FS-12-output-completion-packing.md) | Output Completion, Labelling and Packing | 9 | DB7 · DB7b |
| [`FS-13`](FS-13-fl3-hybrid-route.md) | FL3 Hybrid Continuous Route | 10 | DB2 · DB3 *(FL3)* |
| [`FS-14`](FS-14-order-allocation-fulfilment.md) | Order Allocation and Fulfilment | 4 · 9 | — |
| [`FS-15`](FS-15-shared-schema-boundary.md) | The Shared-Schema Boundary | 4 · 9 | — |
| [`FS-16`](FS-16-reporting-certification.md) | Reporting and Certification | 11 | DB10 |
| [`FS-17`](FS-17-yield-cost-scrap.md) | Yield, Cost Ledger and Scrap | 12 | — |
| [`FS-18`](FS-18-administration-reference-data.md) | Administration, Reference Data and Tooling Inventory | 13 | DM |
| [`FS-19`](FS-19-integration-testing-golive.md) | Integration Testing, Commissioning and Go-Live | 14 | — |
| [`FS-20`](FS-20-unscheduled-unhosted.md) | Unscheduled and Unhosted Requirements | — | OEE |

### Four boundaries that are not the phase model

- **`FS-01` / `FS-02` / `FS-03`** split Phase 1 by layer. A single Platform Foundation measured
  **52 stories / 821 h / 37 real plans** — a quarter of the backlog in one file, which is the shape
  this tier exists to remove. ⚠ **This is the one place the "no technical-layer categories" rule is
  deliberately set aside**, because Phase 1 genuinely *is* technical and pretending otherwise made
  the file unusable. Everything else is cut on the operator journey.
- **`FS-04`** carves the real-time and PLC pipeline out of phases 1A/1B/3/4/5. It is the one
  genuinely functional cross-phase grouping in this domain.
- **`FS-14` vs `FS-15`** separates order allocation (`[REQ §5.28]`) from the shared-schema boundary
  (`[REQ §5.25`–`5.27`, `5.30]`). `FS-15` is labelled an **integration contract, not a feature**,
  and opens on `D-32`: the existing schema is read and written as it stands and never altered.
- **`FS-16` vs `FS-17`** keeps a **contractual** obligation (`NFR012`, welding-wire certificates)
  out of the same file as a **descopable** finance ledger. Merged, the first descope conversation
  cuts the wrong thing.

### Two categories hold no story, deliberately

- **`FS-05`** — MVP-1 reads pass schedules and never authors one, so no card and no task file maps
  here. But `[REQ §5.18]`/`§5.19`'s requirements and five MVP-2 ids do, and the read contract, the
  mandatory snapshot and `PassScheduleId` as an unenforced cross-database reference are spread
  across `phase-04`, `phase-09`, `[PLC §7.2]` and `[PLC §11.2]`. **The category owns a consumer
  contract that had no owner.**
- **`FS-20`** — the requirements nothing schedules: wire break (`FR-280`–`282`, blocked, and blamed
  on `G34` by Appendix B.4 while §11.1 blames `OI-13`), OEE (`FR-500`–`508`, no phase, no owner,
  `PP-03`), the stop transaction and the operator session. Built from the registers, **not** from
  task files, because none of those ids has one.

---

## Where everything else lives

| I want… | Go to |
|---|---|
| Which `FW-###` became part of which category, and why | [`StoryConsolidationMap.md`](../../90-registers/StoryConsolidationMap.md) `[SCM §2.3]` |
| Which requirements a category owns | `[SCM §2.2]` — **complete**, unlike `[TB §11]`, whose live ranges stop at `FR-508` |
| Status, per category and per activity | [`FEATURES.md`](../../FEATURES.md) and [`STATUS.md`](../../STATUS.md) — both generated |
| Hours and capacity | `[CE]`, `[DSP]`, `[SSP]`, `[TRP]` |
| Scope, journey, entry and exit criteria | the owning phase specification |
| The requirement itself | `[REQ §5.x]` and the screen specification |
