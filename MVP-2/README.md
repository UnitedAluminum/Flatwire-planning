# MVP-2 — Deferred Scope

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** Scope decision — recorded. Propagation to phase files and the master spec **not** done.

---

## The decision

**Everything in this folder is not part of MVP-1 and will not be part of MVP-1 planning.**

It is retained as design and requirement material for a later phase. Nothing here is a planning input: it does not appear in effort estimates, sprint scope, phase deliverables, or the dependency chain, and no requirement in it should be scheduled, estimated, or implemented for MVP-1.

## What is here

```
MVP-2/
├── README.md                    ← this file, the record of the decision
├── Mockups/                     ← 7 HTML screens (open directly in a browser)
├── RequirementDocuments/        ← 5 owning specifications
├── ProjectPlan/                 ← 4 extracted documents (SRS §5, API, backlog, test cases)
├── DBChanges/                   ← 3 tables, additive on top of the MVP-1 schema
├── DevelopmentPlan/              ← phase 2 whole + 3 partial phase files + 1 prompt
└── SRS/                         ← 1 client .docx deliverable
```

### Added 11 Aug 2026 — the project plan and schema were divided

| Folder | Contents | The thing to know |
|---|---|---|
| [`ProjectPlan/`](ProjectPlan/) | Requirements, endpoints, backlog rows and test cases for the five deferred screens, **copied verbatim** | **Deliberately not self-contained** — cross-cutting sections (domain model, response envelope, NFRs, test strategy) stayed in MVP-1 and are cited, never copied. [Index](ProjectPlan/00-README.md) |
| [`DBChanges/`](DBChanges/) | **3** of the 28 tables (the pass-schedule group), 10 of 43 FKs, 6 of 47 indexes, 1 of 3 programmability objects | **Four of those FKs sit on MVP-1 tables**, and the runner is ordered seed-before-constrain because MVP-1 already seeded rows that point here. **`CoilOutput` and `CoilTraceability` are MVP-1** — the DB7/DB7b *screens* are deferred but the coil genealogy behind the welding-wire certs is not. [README](DBChanges/README.md) |
| [`Analysis/`](Analysis/) | **3 of the register's 99 open questions** — `OI-88` (the only unambiguously MVP-2 one), `Q83` and `Q62`. **Copied, not moved:** [`../Analysis/FlatWireOpenQuestions.md`](../Analysis/FlatWireOpenQuestions.md) stays the master and keeps all 99 rows, so every inbound `OQ-##` still resolves there | **Mirrored** — nothing renumbered or deleted |
| [`DevelopmentPlan/`](DevelopmentPlan/) | **Phase 2 whole** (with its 231 h), **two partial phase files** (DB10, Die Management) and the generation-spec prompt | **Effort is not apportioned** — only Phase 2 carries a real figure. The descope ladder cannot supply the rest: rung 5 bundles the MVP-2 Die Management screen with the MVP-1 role UI, rung 6 defers MVP-1 reports. Phases 9/11/13 still carry their whole hours in MVP-1, which **overstates** it. [README](DevelopmentPlan/README.md) |

### Screens — `Mockups/`

| Mockup | DB id | Screen | Owning specification | Roadmap phase that carried it |
|---|---|---|---|---|
| `dashboard_9_pass_schedule.html` | DB9 | Pass Schedule Management | [PassScheduleManagement.md](RequirementDocuments/PassScheduleManagement.md) | Phase 2 |
| `dashboard_9a_schedule_list.html` | DB9A | Pass Schedule List ("All Schedules") | [PassScheduleManagement.md](RequirementDocuments/PassScheduleManagement.md) | Phase 2 |
| `dashboard_10_shift_summary.html` | DB10 | Supervisor Shift Summary | [ShiftSummary.md](RequirementDocuments/ShiftSummary.md) | Phase 11 |
| `dashboard_die_management.html` | — | Die Management (inventory, life, retire) | [DieManagement.md](RequirementDocuments/DieManagement.md) | Phase 13 |
| `dashboard_oee.html` | OEE | OEE Dashboard | **none** — never in the dashboard inventory | — (no phase owned it) |

**The screens still open and still render.** They load the shared design system and chrome from `../../MVP-1/Mockups/` (`flat-wire-shopfloor.styles.css`, `flat-wire-topbar.js`, `flat-wire-fit.js`) and link back to MVP-1 screens through the same relative path. `flat-wire-topbar.js` resolves its logo and its "More Options" tile targets from **its own script URL** rather than the host page, which is what lets one copy serve both trees.

### Specifications — `RequirementDocuments/`

| Document | Owns | Note |
|---|---|---|
| `PassScheduleManagement.md` | DB9 + DB9A | Also the **only surviving home of the Operations Manager role definition** (§3.3–§3.4), which is where it went when `Analysis/OperationsManager.md` was deleted on 11 Aug 2026. Anything in MVP-1 needing that role definition now reaches into MVP-2 for it |
| `ShiftSummary.md` | DB10 | |
| `PassScheduleGenerationSpec.md` | The Generate-from-Specs engine (FW-013) | Client-facing FDD/SRS, **v1.5**, carrying its own `PSG-D##` / `PSG-Q##` registers. It is the **authority on the generation physics and arithmetic**, ahead of the master spec's `FR-380`–`FR-391`, which are wrong on five counts (master spec §10.5). Moved because the engine has no screen without DB9 |
| `DieManagement.md` | Die Management screen | **New, extracted 11 Aug 2026** from `DieChangeAndManagement.md` §4 — see below |

### Client deliverable — `SRS/`

`PassScheduleGenerationSpec.docx` — the Word rendering of `RequirementDocuments/PassScheduleGenerationSpec.md`. **The `.md` is the source; the `.docx` is generated output** — edit the markdown and re-render, never the `.docx`.

> **One build dependency crosses the scope boundary.** [`MVP-1/DevelopmentPlan/Tools/build_docx.py`](../MVP-1/DevelopmentPlan/Tools/build_docx.py) opens this `.docx` as its **branding template** — it strips the body and keeps the final `<w:sectPr>`, which carries the header logo and confidentiality footer — so it is what makes *every* client deliverable branded, including MVP-1's `PLCTagSpecification.docx`. Its `TPL` path was updated to `MVP-2/SRS/` on the move. **Do not delete or rename this file** on the assumption that MVP-2 content is inert; the MVP-1 renderer stops working if you do.

## The die document was split, not moved

`DieChangeAndManagement.md` covered two subjects in one file. The split was made deliberately so MVP-1 requirements were not carried into MVP-2 by accident:

| Part | Scope | Where it lives |
|---|---|---|
| §1–3 the mid-run **Die Change event**, §5 the die-life **status vocabulary** | **MVP-1** (Phase 6, the `die_change.js` dialog over the paused run) | Stays at [`../MVP-1/RequirementDocuments/DieChangeAndManagement.md`](../MVP-1/RequirementDocuments/DieChangeAndManagement.md), now v2.3 |
| §4 **Die Management** — inventory, die detail, the four lifecycle operations, its die-life bands | **MVP-2** | [`RequirementDocuments/DieManagement.md`](RequirementDocuments/DieManagement.md) |

**No requirement was altered in the extraction.** The status vocabulary was deliberately **not** copied — the extracted document points back at the parent's §5, because a five-row vocabulary living in two scope buckets is how this repository has repeatedly ended up with copies that disagree.

`OI-12` — the conflicting die-life colour bands between the two screens — is **dormant, not answered**. Only the Die Change bands (60/85 %) apply in MVP-1; the conflict with Die Management's 65/79/80 % figures returns the moment this folder is scheduled. Do not close it on the strength of the split.

## The exclusion is screen-scoped, not phase-scoped

**Do not read this as "Phases 2, 9, 11 and 13 are cut."** Each carries work beyond its screen, and which of it survives is a separate decision that has not been taken:

- **Phase 2** is more than DB9/DB9A — the `PassSchedule` / `PassScheduleComponent` / `PassScheduleChangeLog` tables and the pass-schedule read path are what rod check-in acknowledges and what the PLC tags are pushed from.
- ~~**Phase 9** is more than DB7/DB7b — `CoilOutput` and `CoilTraceability` persistence is the coil genealogy required for welding-wire customer certificates.~~ **Phase 9 left this folder entirely on 11 Aug 2026** — it is **wholly MVP-1**, screens included, precisely because the genealogy and the screens that write it cannot be separated.
- **Phase 11** is more than DB10 — reporting and certification sit in the same phase.
- **Phase 13** is more than die inventory — the die *change* dialog (`../MVP-1/Mockups/die_change.js`) is Phase 6 and stays in MVP-1. **The die inventory table itself is now MVP-2 too** (8 h, moved out of the MVP-1 phase-13 figure), so `FW-N07` no longer spans both scopes.

## Consequences — two closed, two open

Four followed from the exclusion. **Two have since been decided** and are struck through; the reasoning is kept because each looks like an oversight otherwise:

1. **Pass schedule is described as the highest-priority dependency.** [`00-foundations.md`](../MVP-1/DevelopmentPlan/ShopfloorPlan/00-foundations.md) and the roadmap have Phase 2 gating every check-in phase: check-in acknowledges a pass schedule and pushes PLC tags from it. With DB9/DB9A and the generation engine both here, **how pass schedule records are authored and approved for MVP-1 is undefined** — seeded data, an upstream system, or a minimal admin path.
2. ~~**Output coil completion is the run output path.** DB7 is where a finished coil gets its alpha, weight and label. Excluding it leaves how a run produces a recorded output coil in MVP-1 undefined.~~ **CLOSED 11 Aug 2026 — Phase 9 is wholly MVP-1.** The tables had already returned; the writer had not, leaving `CoilOutput` and `CoilTraceability` in MVP-1 with nothing to insert into them and a non-overlap trigger constraining rows that were never created. `POST /coil/complete`, `GET /coil/{alpha}/label`, `CoilCompletionService`, both screens and `FW-066` all returned together.
3. ~~**Die life feeds the in-run die change.** The MVP-1 die change reads die identity, footage counter and life threshold from die management, and rule **D4** forbids installing an unregistered die.~~ **CLOSED 11 Aug 2026 the other way — die inventory and lifecycle are out of MVP-1 for good.** The three values now come from the **`Drawer` die-size catalogue** that MVP-1 already seeds: identity resolves against its 13 rows, footage from `LastGrindingFeet`, threshold from `TotalFeetAllowed` with the 60/85 % bands. **`D4` is restated at size level** — it rejects an unrecognised die *size*, not an unregistered physical tool. The consequence, stated plainly in `DieChangeAndManagement.md` v2.4: **die life is tracked per size, so two dies of the same diameter share one counter.**
4. **The Operations Manager role definition is now in MVP-2** (`PassScheduleManagement.md` §3.3–§3.4), while the permission matrix that uses it is in MVP-1 (`02-SRS.md` §8). Whether that definition needs copying back is unresolved.

## Documents that still describe this as in scope

Propagation was **not** done. Links were repointed so nothing dangles, but the *scope claims* in these files are now stale:

- `MVP-1/DevelopmentPlan/ShopfloorPlan/phase-11`, `phase-13` — full phase specs, now carrying **both** an MVP-1 and a both-scopes effort figure *(`phase-02` is wholly MVP-2; `phase-09` is wholly MVP-1)*
- [`back-matter.md`](../MVP-1/DevelopmentPlan/ShopfloorPlan/back-matter.md) — dependency chain, milestone calendar, gaps register
- [`FlatWire_MasterSpecification.md`](../LatestDocument/FlatWire_MasterSpecification.md) — the OEE screen section, the dashboard inventory rows, and the *"20 approved screens"* list *(the DB7/DB7b sections are correct again — those screens returned to MVP-1)*
- [`02-SRS.md`](../MVP-1/ProjectPlan/02-SRS.md) — the OEE screen references and inventory rows *(§5.16/§5.17 for DB7/DB7b were restored on 11 Aug 2026 and are current)*
- `05-SprintPlanAndBacklog.md` — `FW-###` backlog stories for these screens
- ~~[`FlatWireShopfloorDashboards.md`](../Analysis/FlatWireShopfloorDashboards.md) — the Dashboard Inventory still lists all fifteen as one set~~ **FIXED 11 Aug 2026.** The inventory carries an **`MVP`** column and every dashboard section carries a scope badge. The file was **not split**: the Screen Navigation Map spans both scopes and gained a legend instead of being halved, and its change log is the audit trail *(since moved undivided to [`../CHANGELOG.md`](../CHANGELOG.md) in the 12 Aug 2026 consolidation)*. The **alloy lookup table was lifted out of the Dashboard 9 section** first — MVP-1 reference data that had been buried in an MVP-2 screen

**The specification count is sixteen in MVP-1 plus four here.** `OutputCoilCompletion.md` returned to MVP-1 on 11 Aug 2026 with Phase 9, and at v1.1 it now owns **DB7 and DB7b together** — DB7b previously had requirement text but no owning document at all. **The effort model has not been re-run** — Phases 2, 9, 11 and 13 total **908 h of 3,727 h**, and how much of that this exclusion removes depends on the screen-vs-phase split above. This bears on gap **G1** (the window does not close as scoped) and is a candidate input to that programme decision, not a closure of it.
