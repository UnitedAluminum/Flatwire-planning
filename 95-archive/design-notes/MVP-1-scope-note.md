# MVP-1 — Screens, Specifications and Client Deliverables

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 28, 2026 — ⚠ **The Mockups folder is 38 files / 19 HTML** — `dashboard_3_active_run_ual.html`, a **styling comparison build** (DB3 in the host app’s CSS at 1920×1080) plus five generated assets. The folder is still **flat**. Counts and the "composed for 5:4" statements updated — **18 of 19**, not all 19. Earlier: August 25, 2026 — client deliverables 4 → 5; `Screens/` 17 → 13; the `PLCTagSpecification.md` source path corrected; `D-31` contradiction removed; object count 34 → 33 *(previously August 13, 2026)*
**Status:** Active scope — this is what is being built

---

## What is here

```
MVP-1/
├── README.md        ← this file
├── ProjectPlan/     ← the single source of truth for development, testing and deployment
│                      Business/ Architecture/ Database/ Backend/ Frontend/
│                      Development/ Testing/ Operations/ + Tools/ + README.md
└── SRS/             ← 4 client deliverables (2 .docx + 2 .xlsx); 3 of the 4 generated
```

> **Four sibling folders were consolidated into `ProjectPlan/` on 13 Aug 2026 and no longer exist.**
>
> | Was | Now |
> |---|---|
> | `DevelopmentPlan/` | `ProjectPlan/` — roadmap, sprint plan, backlog, effort models, `REVIEW.md`, `Development/Phases/`, `Tools/` |
> | `RequirementDocuments/` | `ProjectPlan/Business/Screens/` (13 specifications) · `../../20-architecture/PLCTagSpecification.md` · `./Spool.md` + `PartialRodReCheckin.md` · `../../tools/deliverables/ClientQuestionsContent.md` |
> | `Mockups/` | `ProjectPlan/Frontend/Mockups/` — **38** files (19 HTML), **flat and intact** |
> | `DBChanges/` | `ProjectPlan/Database/` — `DatabaseDesign.md` (`[DBD]`, the as-built model and the counted baseline), `Schema/` (design + DDL), `Scripts/` (cross-database work) |
>
> **Five documents were absorbed into the documents that own their subjects and deleted:** `APIContracts.md` → `../../40-backend/APIs.md` · `FlatWireJiraStories.md` → `../../60-delivery/TaskBreakdown.md` · `TechStackRecommendation.md` → `../../20-architecture/Architecture.md` §14 · `FlatWireTables.md` → `../../30-database/schema/FlatWireSchema_Mapping.md`'s appendix · `FlatWire_ERDiagram_Documentation.md` → `../../30-database/DatabaseDesign.md` §6.10/§6.11.
>
> **Two structural rules.** **(1) Section numbers are non-contiguous by design** — `BusinessRequirements.md` opens its requirements at §5, `DatabaseDesign.md` numbers the data model §6 — which is what keeps every `§n` citation resolving. **Never renumber a section to close a gap.** **(2) Documents are cited by shortcode**, declared in each header; [`../../DOCUMENTS.md`](../../DOCUMENTS.md) is the map.

> **The schema builds from `ProjectPlan/Database/Schema/SQL/`** and produces a complete MVP-1 database: **33 tables · 55 FKs · 69 index statements · 1 procedure · 1 trigger**, counted from the scripts and checked by [`../../tools/deliverables/verify_schema_counts.py`](../../tools/deliverables/verify_schema_counts.py). ⚠ **The three pass-schedule tables ARE built by that runner** — `D-31` (15 Aug 2026) moved them into MVP-1, and `PassScheduleId` is a **real, enforced FK** on all four tables, **not** an external reference. *(It was "unenforced by design" until 15 Aug 2026; that description is superseded.)* `PlanId`, `CoilOrderPlanId` and `SkidId` are unaffected and remain external references with no local parents. Only `sp_ShiftSummary` (`09_Programmability_MVP2`) stays MVP-2 — see [`../../30-database/sql/README.md`](../../30-database/sql/README.md). **What did not change: MVP-1 reads pass schedules and never authors them.** **There is no second runner to chase.**
>
> **`CoilOutput` and `CoilTraceability` are MVP-1, and so is everything that writes them.** The coil genealogy they carry is what the **welding-wire customer certificates** are produced from.

## ⚠ This folder is not all of MVP-1

**It is MVP-1 *screens and their specifications*, nothing wider.** All of the following is MVP-1 content that deliberately **stayed where it was**, and a reader who assumes `MVP-1/` is self-contained will miss every one of them:

| MVP-1 content | Still lives at |
|---|---|
| The roadmap index, phase files, foundations, back matter, gaps register | now **here**, `ProjectPlan/` (moved and divided 11 Aug 2026) |
| The master specification and its `OI-##` register | `../../10-requirements/MasterSpecification.md` |
| Requirement text — every `FR-###` | now **here**, `../../10-requirements/BusinessRequirements.md` (moved 11 Aug 2026) |
| Schema design, executable DDL, ER documentation | now **here**, `Database/` (moved and divided 11 Aug 2026) |
| The question registers (**authoritative for decisions**) — **56 open** (`Q1`–`Q56`) and **28 decided**, in one numbering space across two files — a question is numbered when raised and moves across when decided, so neither file's range is contiguous | `../../90-registers/Questions.md` · `../../90-registers/Decisions.md` |
| API contracts, effort model, `REVIEW.md` | now **here**, `ProjectPlan/` |
| Source business documents and the client-call propagation ledgers | `../BaseDocuments/` |

## `Frontend/Mockups/`

Static HTML prototypes — **open directly in a browser**, no build step. The approved visual baseline for the Angular library (prefix `fw`). Shared assets and the rules that govern them are documented in [`../../CLAUDE.md`](../../CLAUDE.md) under *Working With the Artifacts → Mockups*; the ones most often got wrong:

- Edit `flat-wire-shopfloor.styles.scss`, never the compiled `.css`.
- `fw-modal.js` is the shared dialog runtime — load it before any script that opens a popup, and **never stack dialogs** (two live focus traps leave the operator unable to reach either).
- **No dialog scrolls** — oversized dialogs are scaled to fit via `--fw-modal-fit`. Do not add `max-height` to `.gb-modal` or `overflow` to `.gb-modal-body`.
- **Minimum text size is 14px.** These are read at arm's length.
- Four screens are **thin launcher pages, not screens** — `dashboard_8_wip_rejection`, `dashboard_6_spc_checkpoint`, `dashboard_die_change`, `dashboard_12_rod_checkout`. To change those screens, edit the matching `.js`.
- `dashboard_7_coil_completion.html` and `dashboard_7b_packing_station.html` **returned from MVP-2 on 11 Aug 2026**; both are owned by `../../10-requirements/screens/OutputCoilCompletion.md` (DB7b by its new §8).

**Cross-tree links work in both directions.** `flat-wire-topbar.js` resolves its logo and its "More Options" tile targets from **its own `script.src`**, not the host page, which is what lets this one copy serve both `MVP-1/ProjectPlan/Frontend/Mockups/` and `../MVP-2/Mockups/`. The five remaining MVP-2 screens load their chrome from `../../MVP-1/ProjectPlan/Frontend/Mockups/`; the topbar's only forward targets are DB9 and DB10. **DB7 and DB7b came back on 11 Aug 2026** — their asset paths and the three active-run links that reach them are now all local.

## `Business/Screens/`

**Thirteen files, and all thirteen are specifications.** *(Read "Seventeen … Fourteen are specifications; three are not" until 25 Aug 2026. The four non-specifications all left: `Spool.md` and `PartialRodReCheckin.md` to `Business/`, `PLCTagSpecification.md` to `Architecture/`, `ClientQuestionsContent.md` to `Tools/`.)* The trap that wording described is still worth knowing — and the three that are not are cited as though they were, which is the trap:

- **`Spool.md`** is the **domain reference for what a spool is** (physical form, the 3,500 lb ceiling against the ~1,800 lb working target, material flow, lifecycle). *That* content is authoritative; its **screen** rules are not — those belong to `RocCheckin.md` §4.3, `SpoolQueue.md` and `OutputCoilCompletion.md` §4 — and its FM2 description is **superseded by `D-26`**.
- **`PartialRodReCheckin.md`** is **internal design rationale** — nothing in it is citable as a requirement. Its rules live in `RodPreCheckin.md` §7 and `RodCheckout.md` §7.2; the requirement text is `FR-043`. Retained as the audit trail for the open **`Q12`**.
- **`DevelopmentPlanContent.md`** (13 Aug 2026) is the same kind of file for the development plan workbook — the only home of its client-facing prose, with every figure parsed from `ProjectPlan/Development/`. **Its `Reference title` fields mirror the plan's own titles and are never written to the workbook**; they exist so the drift guard can catch a renumbering moving prose onto the wrong work item, so copy them verbatim rather than paraphrasing.
- **`ClientQuestionsContent.md`** (12 Aug 2026) is **source content for a generated deliverable, not a specification.** It holds the client-facing prose for the questions workbook — and is the only place that prose is authored. [`build_questions_xlsx.py`](../../tools/deliverables/build_questions_xlsx.py) merges it with the two `Analysis/` registers to produce [`../../deliverables/FlatWire_ClientQuestions.xlsx`](SRS/). **Structure comes from the registers and prose from this file; nothing is duplicated between them**, so a question's priority or owner is never edited here. Four fatal guards run at build — coverage, drift, team names, leakage.

**`PLCTagSpecification.md`** is the **only** tag map in the repository (cited as `[PLC]`). The anti-drift rule holds: **the client doc owns every tag path string and `../../20-architecture/PLCCommunication.md` contains none.** If you are about to write a tag path anywhere else, stop.

**`DieChangeAndManagement.md` is die change only** since 11 Aug 2026 (v2.4). Its §4 die management became [`../../10-requirements/screens/DieManagement.md`](../../10-requirements/screens/DieManagement.md); §5's die-life status vocabulary stays here as the single copy. `OI-12` is **dormant, not answered**. **Die inventory and lifecycle are out of MVP-1 for good**, so `D4` is restated at die-**size** level against the `Drawer` catalogue: it rejects an unrecognised size, not an unregistered physical tool, and die life is tracked per size — two dies of one diameter share a counter.

## `SRS/`

**Five client deliverables. Four are generated from markdown in this repository and must never be edited directly** — the next render overwrites them. *(Read "Four … Three" until 25 Aug 2026; `FlatWire_OrderAllocationExamples.xlsx` was uncounted.)* ⚠ **One of the four cannot currently be regenerated at all** — `FlatWire_OrderAllocationExamples.xlsx`, whose generator and content source were never committed.

`Shopfloor_Flat_wireSRS.docx` — the delivered SRS, and the one file here that is **not** generated. It has **no pre-check-in content**, so it is *not* the requirement source for `PCI`/`PRC`/`CHK`/`WLD`/`TRV` IDs; those rules are `FR-###` in [`../../10-requirements/BusinessRequirements.md`](../../10-requirements/BusinessRequirements.md).

`PLCTagSpecification.docx` — generated output. **The `.md` in [`ProjectPlan/Architecture/`](../../20-architecture/PLCTagSpecification.md) is the source** *(this said `Business/Screens/` until 25 Aug 2026; the file moved)* — edit it and re-render with [`../../tools/deliverables/build_docx.py`](../../tools/deliverables/build_docx.py).

`FlatWire_ClientQuestions.xlsx` — generated output, the client questions workbook. Rendered by [`../../tools/deliverables/build_questions_xlsx.py`](../../tools/deliverables/build_questions_xlsx.py) from **two** sources: structure from the `Analysis/` question registers, prose from [`ClientQuestionsContent.md`](../../tools/deliverables/ClientQuestionsContent.md). Edit whichever of the two owns the field and re-run.

`FlatWire_DevelopmentPlan.xlsx` (13 Aug 2026) — generated output, the client development plan workbook: seven sheets covering the delivery options at 2, 3 and 4 developers, the 15 stages, the sprint schedule, all 107 development work items, milestones and what is needed from the client, and the assumptions and risks. Rendered by [`../../tools/deliverables/build_development_plan_xlsx.py`](../../tools/deliverables/build_development_plan_xlsx.py) from **two** sources: every figure parsed from [`ProjectPlan/Development/`](ProjectPlan/Development/), all prose authored in [`DevelopmentPlanContent.md`](../../tools/deliverables/DevelopmentPlanContent.md). Edit whichever of the two owns the field and re-run.

> **Both workbooks refuse to build rather than leak.** Every cell of the saved file is re-read and scanned; a file name, requirement/gap/test/backlog id, endpoint, table name, screen number or machine tag path deletes the output and exits non-zero. **A workbook on disk means the guards passed** — which is also why neither `.xlsx` can be repaired by hand.

> **The renderer reaches into MVP-2 for its branding.** `build_docx.py` opens `../../deliverables/PassScheduleGenerationSpec.docx` as a template, strips its body and keeps the final `<w:sectPr>` — which carries the header logo and confidentiality footer. **Deleting that MVP-2 file as deferred, inert content breaks the MVP-1 renderer.**

## One thing MVP-1 still needs from MVP-2

**`PassScheduleManagement.md` §3.3–§3.4 holds the only Operations Manager role definition**, while the permission matrix that uses it is MVP-1 (`02-SRS.md` §8). This is **not** dissolved by the pass schedule leaving MVP-1: the role is load-bearing here on its own terms — `FR-212` restricts reverting a roll-gap override to it on **DB11 Roll Adjust**, it holds SPC-waiver authority, and it is one of the six roles in `02-SRS.md` §8.

*(The second item, `PassScheduleGenerationSpec.md`'s authority over `FR-380`–`FR-391`, is no longer an MVP-1 concern — generation is owned outside MVP-1 entirely, and those FRs are marked out of scope in `02-SRS.md`.)*

The full list of open consequences is in [`./MVP-2-scope-note.md`](./MVP-2-scope-note.md).
