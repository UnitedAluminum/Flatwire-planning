# MVP-1 — Screens, Specifications and Client Deliverables

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 13, 2026
**Status:** Active scope — this is what is being built

---

## What is here

```
MVP-1/
├── README.md                    ← this file
├── Mockups/                     ← 31 files: 17 dashboards + shared design system + shared JS chrome
├── RequirementDocuments/        ← 17 documents (14 specifications + 3 that are not)
├── ProjectPlan/                 ← the plan of record, in eight subject folders:
│                                  Business/ Architecture/ Database/ Backend/
│                                  Frontend/ Development/ Testing/ Operations/
├── DBChanges/                   ← schema design + executable DDL (25 of the 28 tables)
└── SRS/                         ← 3 client deliverables (2 .docx + 1 .xlsx); 2 of the 3 generated
```

> **`DevelopmentPlan/` no longer exists (13 Aug 2026).** Its contents moved into `ProjectPlan/`, which is now the single home for planning, development, testing and deployment material. Four April-dated documents were **absorbed into the documents that own their subjects and deleted** in the same pass:
>
> | Deleted | Absorbed into |
> |---|---|
> | `APIContracts.md` | `ProjectPlan/Backend/APIs.md` — four endpoint sections it indexed but never specified, plus worked examples on 16 endpoints |
> | `FlatWireJiraStories.md` | `ProjectPlan/Development/TaskBreakdown.md` §4, §6, §7, §8 — 116 stories, one backlog |
> | `TechStackRecommendation.md` | `ProjectPlan/Architecture/Architecture.md` §14 — the stack ADR |
> | `FlatWireTables.md` | `DBChanges/Schema/FlatWireSchema_Mapping.md` — the legacy-table inventory, as an appendix |
>
> **`ProjectPlan/` was then restructured into eight subject folders (13 Aug 2026).** The seven numbered documents were **split by section**, and section numbers were preserved exactly — `BusinessRequirements.md` opens its requirements at §5 and `DatabaseDesign.md` numbers the data model §6 — so every `§n` citation in the repository still resolves. Each document declares a **shortcode** in its header; [`ProjectPlan/README.md`](ProjectPlan/README.md) is the map, and the only place all thirty documents are listed together.
>
> Three files in the old `ShopfloorPlan/` were **not** phase specs and were dissolved: `00-foundations.md` — all four of its sections duplicated a ProjectPlan section — `back-matter.md`, whose **`G1`–`G36` register was promoted** to `Development/GapsRegister.md`, and the `phase-01` roll-up index. The **15 phase specs** are now `ProjectPlan/Development/Phases/`; `phase-02` is wholly MVP-2 and lives under `../MVP-2/`.

> **The schema here is complete for MVP-1.** `DBChanges` was divided by MVP scope on 11 Aug 2026: the three pass-schedule tables — `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` — live in [`../MVP-2/DBChanges/`](../MVP-2/DBChanges/) because **the pass schedule is owned outside MVP-1**. `PassScheduleId` on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput` is therefore a **documented external reference**, unenforced by design and in the same class as `PlanId`, `CoilOrderPlanId` and `SkidId` (see `ProjectPlan/Development/Phases/phase-01c-database-foundation.md`). **Running `FlatWire_DDL_RunAll.sql` produces a working MVP-1 database — there is no second runner to chase.**
>
> **`CoilOutput` and `CoilTraceability` are MVP-1, and so is everything that writes them.** The coil genealogy those tables carry is what the **welding-wire customer certificates** are produced from. They returned on 11 Aug 2026 with their 4 FKs, 7 indexes, the DM010 non-overlap trigger and their seed data — and **Phase 9 followed in full**, because the tables had been left with no writer at all: `CoilCompletionService` and `POST /coil/complete` were on the MVP-2 side, so the non-overlap trigger guarded rows nothing inserted.

`ProjectPlan/` and `DBChanges/` joined on 11 Aug 2026, divided by scope against `MVP-2/`; `LatestDocument/` now holds only the master specification and `ProjectPlanPrompt.md`. Originally moved here on 11 Aug 2026 to mirror [`../MVP-2/`](../MVP-2/), so the two scope buckets have the same shape. `Mockups/` came from the repository root; `RequirementDocuments/` came from `LatestDocument/`, which **no longer has a `RequirementDocuments/` folder**; `SRS/` came from the root.


> **⚠ Two phase files carry hours that overstate MVP-1 — and the pass schedule is no longer an MVP-1 concern at all.** `DevelopmentPlan` was divided against MVP-2 on 11 Aug 2026. **Phase 2 left entirely** (231 h) and **stays gone**: pass schedule generation and management are owned by a separate track. Rod check-in still *reads* a schedule to build its PLC push payload, but MVP-1 builds no authoring UI, and `PassScheduleId` is a **documented external reference** in the same class as `PlanId` and `SkidId`. **Phases 11 and 13 were carved** (DB10; Die Management screen, lifecycle service and the die inventory table) and their figures are apportioned in [`ProjectPlan/Development/CapacityAndEffortModel.md`](ProjectPlan/Development/CapacityAndEffortModel.md) §3b. **Phase 9 is wholly MVP-1** and keeps its full 222 h. Details in [`../MVP-2/DevelopmentPlan/README.md`](../MVP-2/DevelopmentPlan/README.md).

## ⚠ This folder is not all of MVP-1

**It is MVP-1 *screens and their specifications*, nothing wider.** All of the following is MVP-1 content that deliberately **stayed where it was**, and a reader who assumes `MVP-1/` is self-contained will miss every one of them:

| MVP-1 content | Still lives at |
|---|---|
| The roadmap index, phase files, foundations, back matter, gaps register | now **here**, `ProjectPlan/` (moved and divided 11 Aug 2026) |
| The master specification and its `OI-##` register | `../LatestDocument/FlatWire_MasterSpecification.md` |
| Requirement text — every `FR-###` | now **here**, `ProjectPlan/Business/BusinessRequirements.md` (moved 11 Aug 2026) |
| Schema design, executable DDL, ER documentation | now **here**, `DBChanges/` (moved and divided 11 Aug 2026) |
| The question registers (**authoritative for decisions**) — **33 open, `Q1`–`Q33`**, and **25 decided, `Q61`–`Q85`**, in one contiguous numbering space across two files | `../Analysis/FlatWireOpenQuestions.md` · `../Analysis/FlatWireDecidedQuestions.md` |
| API contracts, effort model, `REVIEW.md` | now **here**, `ProjectPlan/` |
| Source business documents and the client-call propagation ledgers | `../BaseDocuments/` |

## `Mockups/`

Static HTML prototypes — **open directly in a browser**, no build step. The approved visual baseline for the Angular library (prefix `fw`). Shared assets and the rules that govern them are documented in [`../CLAUDE.md`](../CLAUDE.md) under *Working With the Artifacts → Mockups*; the ones most often got wrong:

- Edit `flat-wire-shopfloor.styles.scss`, never the compiled `.css`.
- `fw-modal.js` is the shared dialog runtime — load it before any script that opens a popup, and **never stack dialogs** (two live focus traps leave the operator unable to reach either).
- **No dialog scrolls** — oversized dialogs are scaled to fit via `--fw-modal-fit`. Do not add `max-height` to `.gb-modal` or `overflow` to `.gb-modal-body`.
- **Minimum text size is 14px.** These are read at arm's length.
- Four screens are **thin launcher pages, not screens** — `dashboard_8_wip_rejection`, `dashboard_6_spc_checkpoint`, `dashboard_die_change`, `dashboard_12_rod_checkout`. To change those screens, edit the matching `.js`.
- `dashboard_7_coil_completion.html` and `dashboard_7b_packing_station.html` **returned from MVP-2 on 11 Aug 2026**; both are owned by `RequirementDocuments/OutputCoilCompletion.md` (DB7b by its new §8).

**Cross-tree links work in both directions.** `flat-wire-topbar.js` resolves its logo and its "More Options" tile targets from **its own `script.src`**, not the host page, which is what lets this one copy serve both `MVP-1/Mockups/` and `../MVP-2/Mockups/`. The five remaining MVP-2 screens load their chrome from `../../MVP-1/Mockups/`; the topbar's only forward targets are DB9 and DB10. **DB7 and DB7b came back on 11 Aug 2026** — their asset paths and the three active-run links that reach them are now all local.

## `RequirementDocuments/`

Seventeen files. **Fourteen are specifications; three are not** — and the three that are not are cited as though they were, which is the trap:

- **`Spool.md`** is the **domain reference for what a spool is** (physical form, the 3,500 lb ceiling against the ~1,800 lb working target, material flow, lifecycle). *That* content is authoritative; its **screen** rules are not — those belong to `RocCheckin.md` §4.3, `SpoolQueue.md` and `OutputCoilCompletion.md` §4 — and its FM2 description is **superseded by `D-26`**.
- **`PartialRodReCheckin.md`** is **internal design rationale** — nothing in it is citable as a requirement. Its rules live in `RodPreCheckin.md` §7 and `RodCheckout.md` §7.2; the requirement text is `FR-043`. Retained as the audit trail for the open **`Q12`**.
- **`ClientQuestionsContent.md`** (12 Aug 2026) is **source content for a generated deliverable, not a specification.** It holds the client-facing prose for the questions workbook — and is the only place that prose is authored. [`build_questions_xlsx.py`](ProjectPlan/Tools/build_questions_xlsx.py) merges it with the two `Analysis/` registers to produce [`SRS/FlatWire_ClientQuestions.xlsx`](SRS/). **Structure comes from the registers and prose from this file; nothing is duplicated between them**, so a question's priority or owner is never edited here. Four fatal guards run at build — coverage, drift, team names, leakage.

**`PLCTagSpecification.md`** is the **only** tag map in the repository (cited as `[PLC]`). The anti-drift rule holds: **the client doc owns every tag path string and `MVP-1/ProjectPlan/Architecture/PLCCommunication.md` contains none.** If you are about to write a tag path anywhere else, stop.

**`DieChangeAndManagement.md` is die change only** since 11 Aug 2026 (v2.4). Its §4 die management became [`../MVP-2/RequirementDocuments/DieManagement.md`](../MVP-2/RequirementDocuments/DieManagement.md); §5's die-life status vocabulary stays here as the single copy. `OI-12` is **dormant, not answered**. **Die inventory and lifecycle are out of MVP-1 for good**, so `D4` is restated at die-**size** level against the `Drawer` catalogue: it rejects an unrecognised size, not an unregistered physical tool, and die life is tracked per size — two dies of one diameter share a counter.

## `SRS/`

**Three client deliverables. Two are generated from markdown in this repository and must never be edited directly** — the next render overwrites them.

`Shopfloor_Flat_wireSRS.docx` — the delivered SRS, and the one file here that is **not** generated. It has **no pre-check-in content**, so it is *not* the requirement source for `PCI`/`PRC`/`CHK`/`WLD`/`TRV` IDs; those rules are `FR-###` in [`ProjectPlan/Business/BusinessRequirements.md`](ProjectPlan/Business/BusinessRequirements.md).

`PLCTagSpecification.docx` — generated output. **The `.md` in `RequirementDocuments/` is the source** — edit it and re-render with [`ProjectPlan/Tools/build_docx.py`](ProjectPlan/Tools/build_docx.py).

`FlatWire_ClientQuestions.xlsx` — generated output, the client questions workbook. Rendered by [`ProjectPlan/Tools/build_questions_xlsx.py`](ProjectPlan/Tools/build_questions_xlsx.py) from **two** sources: structure from the `Analysis/` question registers, prose from [`RequirementDocuments/ClientQuestionsContent.md`](RequirementDocuments/ClientQuestionsContent.md). Edit whichever of the two owns the field and re-run.

> **The renderer reaches into MVP-2 for its branding.** `build_docx.py` opens `../MVP-2/SRS/PassScheduleGenerationSpec.docx` as a template, strips its body and keeps the final `<w:sectPr>` — which carries the header logo and confidentiality footer. **Deleting that MVP-2 file as deferred, inert content breaks the MVP-1 renderer.**

## One thing MVP-1 still needs from MVP-2

**`PassScheduleManagement.md` §3.3–§3.4 holds the only Operations Manager role definition**, while the permission matrix that uses it is MVP-1 (`02-SRS.md` §8). This is **not** dissolved by the pass schedule leaving MVP-1: the role is load-bearing here on its own terms — `FR-212` restricts reverting a roll-gap override to it on **DB11 Roll Adjust**, it holds SPC-waiver authority, and it is one of the six roles in `02-SRS.md` §8.

*(The second item, `PassScheduleGenerationSpec.md`'s authority over `FR-380`–`FR-391`, is no longer an MVP-1 concern — generation is owned outside MVP-1 entirely, and those FRs are marked out of scope in `02-SRS.md`.)*

The full list of open consequences is in [`../MVP-2/README.md`](../MVP-2/README.md).
