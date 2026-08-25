# Flat Wire Mill — Project Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — `Spool.md` and `PartialRodReCheckin.md` added to the map — they were absent and therefore uncitable; `[PLC]`, `[PSG]`, `[MS]` declared; five self-counts corrected; `D-31` contradiction removed *(previously August 18, 2026 — the `[INT]` row re-described — it is cross-database touchpoints against the shared schema **as it stands**, the renames having been cancelled by `D-32` *(previously August 13, 2026 — **this folder is now the single source of truth for development, testing and deployment.** `DevelopmentPlan/`, `RequirementDocuments/`, `Mockups/` and `DBChanges/` were all consolidated in and no longer exist; the seven numbered documents were split by section into eight subject folders)*)*
**Document Type:** Index
**Status:** Active — the plan of record for development, testing and deployment
**Owner:** Programme management
**Audience:** Everyone working on the Flat Wire Mill module

---

> ## This folder is complete, but it is not supreme
>
> **Complete:** everything needed to build, test and ship MVP-1 is inside it. Nothing outside it is a required input for development, testing or deployment.
>
> **Derived:** [`FlatWire_MasterSpecification.md`](../../LatestDocument/FlatWire_MasterSpecification.md) remains the arbiter — §10 is the decision record (`D-##`), §11 the open-issue register (`OI-##`). **Where this folder and the master specification disagree, the master specification wins and this folder is corrected up to it, never the reverse.**
>
> ⚠ **That creates a standing obligation nothing enforces:** a change to the master specification's §10 or §11 is a re-derivation task here, not a notification.

**Precedence inside the folder**, in order:

1. **The master specification** (external) — decisions and open issues.
2. **The DDL** (`Database/Schema/SQL/`) for column types, nullability and constraints · **the mockups** (`Frontend/Mockups/`) for pixel-level layout · **the screen specifications** (`Business/Screens/`) for screen rules. **All three are now inside this folder** and each still wins over the prose that describes it.
3. **Everything else here.**

---

## 1. The map

Every document declares its own **shortcode** in its header; citations use `[CODE §n]`.

> **Four codes are declared HERE and not in a header, because their owning document cannot carry
> one.** Two are **client deliverables** whose headers use client fields (Version / Date / Status)
> and must not gain internal repo scaffolding, and one lives outside `ProjectPlan/` altogether.
> Without this table they were cited hundreds of times and declared nowhere.
>
> | Code | Owning document | Why it has no `**Shortcode:**` line |
> |---|---|---|
> | **`[PLC]`** | [Architecture/PLCTagSpecification.md](Architecture/PLCTagSpecification.md) | Client deliverable, issued for sign-off. ⚠ Not `[PLCC]`, which is the *internal* PLC document — the two are a live near-collision |
> | **`[PSG]`** | `../../MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md` | Client deliverable, and in MVP-2. Still the authority on generation physics and arithmetic over `FR-380`–`FR-391` — being deferred does not demote it |
> | **`[MS]`** | `../../LatestDocument/FlatWire_MasterSpecification.md` | Outside `ProjectPlan/`; it is an input to this folder, not a member of it |
> | **`[REF]`** | — | **Retired.** Dropped when `ReferenceData.md` merged into `FlatWireSchema_Lookup.md`. Do not reissue |

### `Business/` — what the system must do, and why

| Document | Code | Read it for |
|---|---|---|
| [VisionAndScope.md](Business/VisionAndScope.md) | `[VS]` | Why the project exists, scope in and out, success criteria, risks, the closed-decision register |
| [BusinessRequirements.md](Business/BusinessRequirements.md) | `[REQ]` | **What to build** — 279 numbered requirements (263 in MVP-1 scope), the NFR register, traceability |
| [ProcessFlows.md](Business/ProcessFlows.md) | `[PF]` | The eleven stages and the normal operating path |
| [BusinessRules.md](Business/BusinessRules.md) | `[BR]` | Domain model, alpha formats, status vocabularies, state machines, glossary |
| [ExceptionHandling.md](Business/ExceptionHandling.md) | `[EX]` | Material leaving the normal path — the three checkout modes, carry-forward, scrap |
| [Spool.md](Business/Spool.md) | — | **Domain reference, not a specification.** What a spool physically *is* — form, the 3,500 lb equipment ceiling against the ~1,800 lb working target, material flow, lifecycle. **Authoritative for that**; its *screen* rules are not — those belong to `RocCheckin.md` §4.3, `SpoolQueue.md`, `OutputCoilCompletion.md` §4 and `SpoolCompletionNotification.md` — and **its FM2 description is superseded by `D-26`** |
| [PartialRodReCheckin.md](Business/PartialRodReCheckin.md) | — | **Internal design rationale, not citable as a requirement.** The audit trail for the open `Q12`; the rules live in `Screens/RodPreCheckin.md` §7 and `Screens/RodCheckout.md` §7.2 and the requirement text is `FR-043` (`TC-050`/`TC-051`). ⚠ Its worked examples use non-canonical `ROD-`/`SPL-` alphas (gap `G14`) and its snake_case columns were May 2026 proposals — delivered 26 Jul 2026 as `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb`, `SpoolProcessing.SourceRodAlpha` |

> **Both rows above carry no shortcode on purpose** — neither is citable, so neither gets a code. They were **absent from this map entirely until 25 Aug 2026**, which by this file's own citation rule made them invisible: they sit in `Business/`, one level above `Business/Screens/`, and several documents still describe them as being in `Screens/`.

### `Architecture/` — how it is structured

| Document | Code | Read it for |
|---|---|---|
| [Architecture.md](Architecture/Architecture.md) | `[ARC]` | Architecture, **the binding reference-code rules (§2.2)**, the transactional boundary, environments, the decision record, the stack ADR (§14) |
| [Integration.md](Architecture/Integration.md) | `[INT]` | Cross-database touchpoints — reads and writes against the shared schema **as it stands** *(the FW-001 renames are cancelled; `D-32`, 18 Aug 2026)* |
| [Security.md](Architecture/Security.md) | `[SEC]` | Authentication, authorisation, the role matrix |
| [SignalR.md](Architecture/SignalR.md) | `[SIG]` | The real-time design and the `FlatWireHub` contract |
| [PLCCommunication.md](Architecture/PLCCommunication.md) | `[PLCC]` | PLC integration, the write surface, the service contract. **Carries no tag path strings by rule** |
| [MachineSimulator.md](Architecture/MachineSimulator.md) | `[SIM]` | The FL1/FL2/FL3 machine simulator and its engineering console `DB-S1`. **Also carries no tag path strings by rule.** Its §5.6 assumption table is gap `G39`'s only instrument |

### `Database/` — three tiers, in this order

| Tier | Where | Authority |
|---|---|---|
| Rationale | [DatabaseDesign.md](Database/DatabaseDesign.md) `[DBD]` | Why the schema is shaped this way; the ER diagrams; **the counted object baseline** (§6.2), query patterns (§6.10), build order (§6.11) |

> **`Database/` holds one root document, not three, as of 23 Aug 2026.** `GapAnalysis.md` was retired — it claimed its own figures superseded every other count in the repository, was wrong on three of five, and had no shortcode, so it was uncitable by this file's own rule; its findings are `G49`–`G51` and `OI-126`. `ReferenceData.md` was merged into `FlatWireSchema_Lookup.md`'s `AlloyProperty` section and its `[REF]` shortcode dropped — it had one inbound link, and keeping the seed values away from the column definitions is what let its column names go stale. Both are recoverable at `ebd0834`; the history is in [`CHANGELOG.md`](../../CHANGELOG.md).

| Column design | [Database/Schema/](Database/Schema/) | **Six** per-domain documents — Lookup, Schedule, Materials, Runs, QualityOutput, Mapping — each paired with the DDL file it names *(this said "Five" until 25 Aug 2026 while § the `Database/` narrative said six)* |
| **Executable truth** | [Database/Schema/SQL/](Database/Schema/SQL/) | **Authoritative for types, nullability and constraints. Never regenerate it from the markdown** |

**The MVP-1 build is `33 tables · 55 FKs · 69 index statements · 1 procedure · 1 trigger`** — counted from `Database/Schema/SQL/` and checked by [`Tools/verify_schema_counts.py`](Tools/verify_schema_counts.py). **The design and the build are the same 33 tables:** `D-31` (15 Aug 2026) moved the three `PassSchedule*` tables **into** MVP-1, so they **are** built by `FlatWire_DDL_RunAll.sql` and their four FKs **are** enforced. Only `sp_ShiftSummary` (`09_Programmability_MVP2`) stays MVP-2. ⚠ **MVP-1 reads pass schedules and never authors them** — owning the table is not owning the data. Defined once in `[DBD §6.2]` — every other mention is a citation.

### `Backend/` · `Frontend/`

| Document | Code | Read it for |
|---|---|---|
| [APIs.md](Backend/APIs.md) | `[API]` | The REST contract — conventions, enums, 30 endpoints, the stub-first delivery contract (§7) |
| [Services.md](Backend/Services.md) | `[SVC]` | Solution structure, CQRS, validation, error handling |
| [Backend/TaskBreakdownPlans/](Backend/TaskBreakdownPlans/) | — | **Per-story build orders**, one file per backlog story, consolidating what the specifications say about it into an executable sequence. **Start at [Orchestration.md](Backend/TaskBreakdownPlans/Orchestration.md)** — the folder's entry point: dependency graph, seven build waves, the six ratification gates, the blocker calendar, and `phase-01b`'s exit criteria mapped to owning plans. ⚠ **The critical path is 134 h and its second node is the only plan marked `Blocked`** (`FW-145`, on `G6`, due 28 Aug). **Building the 30 Sep trial instead?** [TrialOrchestration.md](Backend/TaskBreakdownPlans/TrialOrchestration.md) maps all **66** trial stories across four streams by sprint, with the trial's own blockers and its 330 h of deferrals. **37 documents: 35 plans + 2 orchestrations** (`Orchestration.md`, `TrialOrchestration.md`), `P-01`–`P-49` *(counted 25 Aug 2026; the figure read "34 documents: 32 plans" and the range was given as both `P-01`–`P-49` and `P-01`–`P-39` in one cell)*. **Derived, and they lose to every specification** — none declares a shortcode and none is citable as a requirement. Decisions are minted `P-##`, **continuous across the folder** (`P-01`–`P-39`). **Twenty-two, covering every story in `phase-01b`'s Stories trailer.** **BE:** [FW-N04](Backend/TaskBreakdownPlans/FW-N04-FlatWire-Solution-Skeleton.md) *(the root node)* · [FW-138](Backend/TaskBreakdownPlans/FW-138-Fifteen-Thin-Controllers.md) · [FW-139](Backend/TaskBreakdownPlans/FW-139-MediatR-Registration-And-Pipeline-Behaviours.md) · [FW-140](Backend/TaskBreakdownPlans/FW-140-DI-Registration-And-Stub-Swap.md) · [FW-141](Backend/TaskBreakdownPlans/FW-141-Repository-Layer.md) · [FW-142](Backend/TaskBreakdownPlans/FW-142-Dapper-EF-And-FlatWireDbContext.md) · [FW-143](Backend/TaskBreakdownPlans/FW-143-Serilog-And-Audit-Log.md) · [FW-144](Backend/TaskBreakdownPlans/FW-144-Configuration-Binding.md) · [FW-145](Backend/TaskBreakdownPlans/FW-145-JWT-And-Role-Policies.md) · [FW-146](Backend/TaskBreakdownPlans/FW-146-Exception-Middleware-And-Envelope.md) · [FW-147](Backend/TaskBreakdownPlans/FW-147-FluentValidation-Value-Objects-And-Enums.md) · [FW-148](Backend/TaskBreakdownPlans/FW-148-Health-Checks.md) · [FW-207](Backend/TaskBreakdownPlans/FW-207-Domain-Model.md) · [FW-208](Backend/TaskBreakdownPlans/FW-208-Domain-Events-Post-Commit-Dispatch.md). **RT:** [FW-080](Backend/TaskBreakdownPlans/FW-080-FlatWireHub.md) · [FW-149](Backend/TaskBreakdownPlans/FW-149-IFlatWireClient.md) · [FW-150](Backend/TaskBreakdownPlans/FW-150-Broadcast-Loop.md) · [FW-151](Backend/TaskBreakdownPlans/FW-151-PLCTagService.md) · [FW-205](Backend/TaskBreakdownPlans/FW-205-ITInhibitService.md) *(**exit criterion 5**)* · [FW-N05](Backend/TaskBreakdownPlans/FW-N05-OPC-Ingest-And-Bounded-Channel.md). **Trial scope, additive to `[CE §3b]`:** [FW-203](Backend/TaskBreakdownPlans/FW-203-OPC-Feed-Simulator.md) · [FW-218](Backend/TaskBreakdownPlans/FW-218-Sim-Control-Surface.md). ⚠ **Several correct a stale acceptance criterion in `[TB §7]`** — `FW-140`'s `useStub`, `FW-141`'s repository list, `FW-142`'s table count, `FW-145`'s five roles, `FW-147`'s rule placement, `FW-149`'s event count, `FW-151`'s two-of-six operations, `FW-205`'s two-of-three lines — so **read the plan beside the card, not instead of it** |
| [ScreenPlan.md](Frontend/ScreenPlan.md) | `[SCR]` | Screen inventory, navigation map, shared chrome, mockup → component mapping |
| [Components.md](Frontend/Components.md) | `[CMP]` | Library structure, routing, state, charts, the design-token system |
| [ValidationRules.md](Frontend/ValidationRules.md) | `[VAL]` | Shopfloor input constraints — 48 px targets, the 14 px floor, no hover |

### `Business/Screens/` · `Frontend/Mockups/` · `Database/Schema/` — absorbed 13 Aug 2026

These three were sibling folders of `ProjectPlan/` until the consolidation. They are **the authorities their prose describes**, which is why they had to come inside for this folder to be self-sufficient:

| Now at | Was | Holds |
|---|---|---|
| [Business/Screens/](Business/Screens/) | `MVP-1/RequirementDocuments/` | **13 specifications, one per screen or screen family** — the owning document wins on any disagreement. Their `## Document Change History` blocks were **removed 15 Aug 2026** and folded into [`CHANGELOG.md`](../../CHANGELOG.md), which now carries a `Version` column per document; a specification states its version in its header block only, so bump the header and stamp the same value on the CHANGELOG row. ⚠ **`Screens/` is shorthand:** `DieChangeAndManagement`, `WeldEvent` and `SpoolCompletionNotification` own a dialog or a behaviour, not a routed screen |
| [Frontend/Mockups/](Frontend/Mockups/) | `MVP-1/Mockups/` | **32 files, flat and intact** — **18 HTML** (11 routed screens, 5 dialog launchers, 1 component demo and **`simulator_console.html` / `DB-S1`**, added 18 Aug 2026 and missed by this count until 25 Aug), 10 JS (3 shared runtime + 7 dialogs), the `.scss` source and its compiled `.css`, and two binary assets. **It must stay flat:** ~90 bare-filename asset references break all at once under any subfoldering |
| [Database/Schema/](Database/Schema/), [Database/Scripts/](Database/Scripts/) | `MVP-1/DBChanges/` | The DDL, seed data and the **six** per-domain design documents; `Scripts/` holds work against the **shared** `united_db`/`CommonDB`, not `FlatWireDB` |
| [Architecture/PLCTagSpecification.md](Architecture/PLCTagSpecification.md) | `MVP-1/RequirementDocuments/` | `[PLC]` — **the only tag map in the repository.** `PLCCommunication.md` carries none, by rule |

**All five MVP-2 mockups load their stylesheet, app bar and fit script from `Frontend/Mockups/`** — 19 references, plus 5 the other way and the topbar's own tile targets. They have no build step, so a broken path is invisible until someone opens a screen.

### `Development/` — when it gets built, by whom, at what cost

| Document | Code | Read it for |
|---|---|---|
| [Roadmap.md](Development/Roadmap.md) | `[RM]` | The 14-phase model, the phase table, milestones and risks |
| [SprintPlan.md](Development/SprintPlan.md) | `[SP]` | The **programme** sprint plan — capacity position, delivery model, sprint calendar, dependencies, DoR/DoD |
| [DevelopmentSprintPlan.md](Development/DevelopmentSprintPlan.md) | `[DSP]` | **The same sprints, build streams only** (FE/BE/DB/RT, no QA/BA/contingency) — what a development lead commits against. A derived view of `[CE]` and `[DE]` |
| [StaffedSprintPlans.md](Development/StaffedSprintPlans.md) | `[SSP]` | **The staffed plan of record — three developers, 103 stories, finish 25 Nov 2026.** Two-week sprints from 24 Aug. ⚠ **The only document that excludes Phase 12** (yield, cost, scrap — out of plan 13 Aug 2026) and the only one that holds **Phase 14 to a sprint of its own**, as `[SP §6.1]` requires. `[DSP]` and `[CE]` still cost both, so their totals are higher by design, not in error |
| [TaskBreakdown.md](Development/TaskBreakdown.md) | `[TB]` | **The backlog — 114 live stories / 3,186 h scheduled** *(`D-32`; **all-in `3,358 h`** per `[CE §3e]`)*, the descope ladder, the `FR-###` coverage matrix |
| **FlatWire_TrialRunPlan.xlsx** *(in `Development/`)* | — | **The trial run as a workbook — ten sheets, 61 work items, 778 hours.** Generated by [`Tools/build_trial_run_xlsx.py`](Tools/build_trial_run_xlsx.py) from `[TRP]` + `[TB]` + `Tools/TrialRunContent.md`; **edit a source and re-run, never the workbook.** It is **internal, shared with the client** — it carries story identifiers, hours and gap identifiers, which is why it sits here and **not** in `MVP-1/SRS/`, where the leakage-guarded client deliverables live |
| [TrialRunPlan.md](Development/TrialRunPlan.md) | `[TRP]` | **The client-requested six-screen trial run** (14 Aug 2026) — DB2 · DB3-FL1 · DB6 SPC · DB8 WIP · DB5 · DB3-FL2, plus Pause/Resume and FL1 spool completion. **778 h, four sprints from 17 Aug.** A scoped subset of `[SSP]`, not a replacement. **DB1 and DB2A + weld capture were removed on client direction the same day** — §1.4 records what each took with it, including that the trial no longer exercises **weld traceability**, and that `G21`/`G26` left trial scope while staying open for MVP-1. ⚠ Its §5.1 re-prices `FR-130`–`FR-155` from 4 h to 98 h (gap **`G37`**, story **`FW-202`**), which no published per-phase total carries |
| [GapsRegister.md](Development/GapsRegister.md) | `[GAP]` | **The `G##` register.** `G1` is the capacity escalation |
| [CapacityAndEffortModel.md](Development/CapacityAndEffortModel.md) | `[CE]` | **The hours model of record** — rate card, per-phase effort, MVP-1 apportionment, capacity grid |
| [DevelopmentEffortModel.md](Development/DevelopmentEffortModel.md) | `[DE]` | The same work on an **AI-assisted** basis. Factors `[CE]`'s columns; corrects nothing in it |
| [YieldCostAndScrapSheet.md](Development/YieldCostAndScrapSheet.md) | `[YCS]` | Phase 12's figures — the only home for them |
| [YieldCostAndScrapStories.md](Development/YieldCostAndScrapStories.md) | `[YCB]` | Phase-12 story pointer and its specification-gap finding |
| [REVIEW.md](Development/REVIEW.md) | `[REV]` | The audit of known contradictions. **Read before trusting any single document** |
| [Phases/](Development/Phases/) | — | The **15 phase specifications** — the join point between the layer documents |

### `Testing/` · `Operations/`

| Document | Code | Read it for |
|---|---|---|
| [TestStrategy.md](Testing/TestStrategy.md) | `[TS]` | Strategy, scope, environments, gates, defect management |
| [TestCases.md](Testing/TestCases.md) | `[TCS]` | The case catalogue and the coverage matrix |
| [NFRVerification.md](Testing/NFRVerification.md) | `[NFR]` | NFR verification — **four targets are undefined, so those tests cannot fail** |
| [UATPlan.md](Testing/UATPlan.md) | `[UAT]` | Participants, scenario scripts, sign-off criteria |
| [PLCCommissioning.md](Testing/PLCCommissioning.md) | `[COM]` | **Safety-critical.** Preconditions, who must be present, `C1`–`C11`, abort criteria |
| [Deployment.md](Operations/Deployment.md) | `[DEP]` | Release overview, pre-deployment, the deployment sequence, the smoke suite |
| [Rollback.md](Operations/Rollback.md) | `[RB]` | Rollback. **Must be rehearsed before the first production deployment** |
| [Monitoring.md](Operations/Monitoring.md) | `[MON]` | Health monitoring and logging |
| [SupportGuide.md](Operations/SupportGuide.md) | `[SUP]` | Incident runbook, handover, contacts, command reference |

`Tools/` holds **eight** scripts — six `build_*` generators plus `extract_vba.py` and `verify_schema_counts.py` — and `template.docx`, which is `build_docx.py`'s branding input *(this said "the four build scripts" until 25 Aug 2026)*. **The markdown is always the source and the `.docx` / `.xlsx` is generated output** — never edit a generated file. Two of them build a client workbook whose prose is authored beside the script (`ClientQuestionsContent.md`, `DevelopmentPlanContent.md`) and whose *figures are parsed from this folder*, so a plan change propagates on the next run. Both refuse to build — deleting their own output — if a file name, requirement id, endpoint, table name or screen number reaches a client cell. See [`Tools/README.md`](Tools/README.md).

---

## 2. Read order

**First time through:** `[VS]` → `[REQ]` → `[ARC]` → `[API]` → `[SP]` → `[TS]` → `[DEP]`. The later documents cite identifiers minted in the earlier ones.

| Your role | Start here |
|---|---|
| Angular developer | `[CMP]`, then `[REQ §5]` for your screen, then `[API]` |
| .NET developer | `[ARC §2.2]` — **the reference rules are binding and non-obvious** — then `[SVC]`, then `[API]`. If you are building a specific story, check [`Backend/TaskBreakdownPlans/`](Backend/TaskBreakdownPlans/) first — it may already carry the build order |
| DBA | `[DBD §6]`, then `[DEP §4.2]` and `[DEP §4.3]` |
| QA | `[TS]`, then the `[TCS §5]` block for your area |
| Delivery lead | `[SP §1]` — **before anything else** |
| Release manager | `[DEP]` end to end, then `[TS §4.2]` |

> **Section numbers survived the split and are non-contiguous by design.** `[REQ]` opens its requirements at §5 and `[DBD]` numbers the data model §6, because they came from documents where those were the numbers. That is what keeps every `§n` citation in the repository resolving. **Do not renumber a section to close a gap.**

---

## 3. What deliberately stays outside

| Stays | Why |
|---|---|
| `../../LatestDocument/FlatWire_MasterSpecification.md` | The arbiter. This folder is derived from it |
| `../../Analysis/FlatWireOpenQuestions.md`, `FlatWireDecidedQuestions.md` | The decision registers — `Q1`–`Q36` open, `Q61`–`Q85` decided. Phases cite them as blockers |
| `../../Analysis/FlatWireEndToEndProcess.md`, `FlatWireProcessWalkthrough.md` | Cross-cutting process narrative, cited by step number. **A residual seam:** `[BR §3]` sources the three operating routes from the first, and `[RM]` derives phase ordering from its 11 stages |
| `../../BaseDocuments/` | Read-only business evidence, plus the two **live** client-call propagation ledgers |
| `../SRS/` | Generated client deliverables — output of `Tools/`, not source. **Never edit a `.docx` or `.xlsx`**; edit the markdown and re-run |
| `../../MVP-2/` | Deferred scope by decision |

---

## 4. Four things a reader most often gets wrong

1. **The date does not work.** MVP-1 is **3,186 hours** against 44 working days — **9.1 FTE sustained**, **24.5 in W7** *(`D-32`, 18 Aug 2026; previously 3,292 h / 9.4)* — and the full descope ladder recovers only ~12 %. A programme decision is required. `[SP §1]`, `[GAP]` `G1`.
2. **`Rod` is retained**, with enforced FKs. The design and the MVP-1 build are the same **33 tables** — `D-31` (15 Aug 2026) retired the 25/28 split. `[DBD §6.2]`.
3. **There is no Angular template.** Every control is built fresh from the mockups; the only reuse is the foundational `shared` services. `[ARC §2.2]`.
4. **FL1 has no edger**, FM2's edgers are at **S2 and S3 only**, and **FL2 broadcasts `null` live gauge and width**. `[BR §3.1]`.

## 5. Findings raised by this document set

| ID | Finding | Where |
|---|---|---|
| **PP-01** | **Why a deployed database reports more indexes than the scripts create** — every `PRIMARY KEY` and `UNIQUE` constraint builds its own backing index, so a `sys.indexes` count is not a statement count. Four sources once published four different figures. The count is defined once, in `[DBD §6.2]` | `[DBD §6.8]`, `[DEP §4.2]` |
| **PP-02** | **`NFR001`, `NFR002` and `NFR008` are cited nowhere** in any downstream artifact. No NFR was invented to fill the gap | `[REQ §6.4]` |
| **PP-03** | **The OEE dashboard has no story, no phase and no owner** — it has an approved mockup and 17 source requirements | `[REQ §11.3]`, `[TB §7.7]` |
| **PP-04** | **The hub event count is 10, not 9.** The "9" predates `PayoffStateChanged` | `[API §10.3]` |
