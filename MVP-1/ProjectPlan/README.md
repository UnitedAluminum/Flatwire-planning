# Flat Wire Mill — Project Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — **restructured into eight subject folders.** The seven numbered documents were split by section, and `MVP-1/DevelopmentPlan/` was consolidated in and deleted
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
2. **The DDL** (`../DBChanges/Schema/SQL/`) for column types, nullability and constraints · **the mockups** (`../Mockups/`) for pixel-level layout · **the screen specifications** (`../RequirementDocuments/`) for screen rules. Each wins over the prose that describes it.
3. **Everything else here.**

---

## 1. The map

Every document declares its own **shortcode** in its header; citations use `[CODE §n]`.

### `Business/` — what the system must do, and why

| Document | Code | Read it for |
|---|---|---|
| [VisionAndScope.md](Business/VisionAndScope.md) | `[VS]` | Why the project exists, scope in and out, success criteria, risks, the closed-decision register |
| [BusinessRequirements.md](Business/BusinessRequirements.md) | `[REQ]` | **What to build** — 279 numbered requirements (263 in MVP-1 scope), the NFR register, traceability |
| [ProcessFlows.md](Business/ProcessFlows.md) | `[PF]` | The eleven stages and the normal operating path |
| [BusinessRules.md](Business/BusinessRules.md) | `[BR]` | Domain model, alpha formats, status vocabularies, state machines, glossary |
| [ExceptionHandling.md](Business/ExceptionHandling.md) | `[EX]` | Material leaving the normal path — the three checkout modes, carry-forward, scrap |

### `Architecture/` — how it is structured

| Document | Code | Read it for |
|---|---|---|
| [Architecture.md](Architecture/Architecture.md) | `[ARC]` | Architecture, **the binding reference-code rules (§2.2)**, the transactional boundary, environments, the decision record, the stack ADR (§14) |
| [Integration.md](Architecture/Integration.md) | `[INT]` | Cross-database touchpoints and the FW-001 shared-schema renames |
| [Security.md](Architecture/Security.md) | `[SEC]` | Authentication, authorisation, the role matrix |
| [SignalR.md](Architecture/SignalR.md) | `[SIG]` | The real-time design and the `FlatWireHub` contract |
| [PLCCommunication.md](Architecture/PLCCommunication.md) | `[PLCC]` | PLC integration, the write surface, the service contract. **Carries no tag path strings by rule** |

### `Database/` — three tiers, in this order

| Tier | Where | Authority |
|---|---|---|
| Rationale | [DatabaseDesign.md](Database/DatabaseDesign.md) `[DBD]` | Why the schema is shaped this way; the ER diagrams; **the counted object baseline** |
| Column design | `../DBChanges/Schema/FlatWireSchema_*.md` | Per-domain, paired with the DDL file each names |
| **Executable truth** | `../DBChanges/Schema/SQL/` | **Authoritative for types, nullability and constraints. Never regenerate it from the markdown** |

**The MVP-1 build is `25 tables · 33 FKs · 41 index statements · 1 procedure · 1 trigger`.** The full design is 28 tables / 43 FKs; the three `PassSchedule*` tables are owned outside MVP-1. Defined once in `[DBD §6.2]` — every other mention is a citation.

### `Backend/` · `Frontend/`

| Document | Code | Read it for |
|---|---|---|
| [APIs.md](Backend/APIs.md) | `[API]` | The REST contract — conventions, enums, 30 endpoints, the stub-first delivery contract (§7) |
| [Services.md](Backend/Services.md) | `[SVC]` | Solution structure, CQRS, validation, error handling |
| [ScreenPlan.md](Frontend/ScreenPlan.md) | `[SCR]` | Screen inventory, navigation map, shared chrome, mockup → component mapping |
| [Components.md](Frontend/Components.md) | `[CMP]` | Library structure, routing, state, charts, the design-token system |
| [ValidationRules.md](Frontend/ValidationRules.md) | `[VAL]` | Shopfloor input constraints — 48 px targets, the 14 px floor, no hover |

### `Development/` — when it gets built, by whom, at what cost

| Document | Code | Read it for |
|---|---|---|
| [Roadmap.md](Development/Roadmap.md) | `[RM]` | The 14-phase model, the phase table, milestones and risks |
| [SprintPlan.md](Development/SprintPlan.md) | `[SP]` | The capacity position, delivery model, sprint calendar, dependencies, DoR/DoD |
| [TaskBreakdown.md](Development/TaskBreakdown.md) | `[TB]` | **The backlog — 116 stories / 3,292 h**, the descope ladder, the `FR-###` coverage matrix |
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

`Tools/` holds the three build scripts. **The markdown is always the source and the `.docx` / `.xlsx` is generated output** — never edit a generated file.

---

## 2. Read order

**First time through:** `[VS]` → `[REQ]` → `[ARC]` → `[API]` → `[SP]` → `[TS]` → `[DEP]`. The later documents cite identifiers minted in the earlier ones.

| Your role | Start here |
|---|---|
| Angular developer | `[CMP]`, then `[REQ §5]` for your screen, then `[API]` |
| .NET developer | `[ARC §2.2]` — **the reference rules are binding and non-obvious** — then `[SVC]`, then `[API]` |
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
| `../../Analysis/FlatWireOpenQuestions.md`, `FlatWireDecidedQuestions.md` | The decision registers — `Q1`–`Q33` open, `Q61`–`Q85` decided. Phases cite them as blockers |
| `../../Analysis/FlatWireEndToEndProcess.md`, `FlatWireProcessWalkthrough.md` | Cross-cutting process narrative, cited by step number. **A residual seam:** `[BR §3]` sources the three operating routes from the first, and `[RM]` derives phase ordering from its 11 stages |
| `../../BaseDocuments/` | Read-only business evidence, plus the two **live** client-call propagation ledgers |
| `../SRS/` | Generated client deliverables — output of `Tools/`, not source |
| `../../MVP-2/` | Deferred scope by decision |

---

## 4. Four things a reader most often gets wrong

1. **The date does not work.** MVP-1 is **3,292 hours** against 44 working days — **9.4 FTE sustained**, **24.5 in W7** — and the full descope ladder recovers only ~12 %. A programme decision is required. `[SP §1]`, `[GAP]` `G1`.
2. **`Rod` is retained**, with enforced FKs. The full design is **28 tables**; the MVP-1 build is **25**. `[DBD §6.3]`.
3. **There is no Angular template.** Every control is built fresh from the mockups; the only reuse is the foundational `shared` services. `[ARC §2.2]`.
4. **FL1 has no edger**, FM2's edgers are at **S2 and S3 only**, and **FL2 broadcasts `null` live gauge and width**. `[BR §3.1]`.

## 5. Findings raised by this document set

| ID | Finding | Where |
|---|---|---|
| **PP-01** | **The MVP-1 index count is 41**, not 44, 46 or "40 + 1" — four sources were measuring different things, and a deployed database reports more than script 07 creates | `[DBD §6.8]`, `[DEP §4.2]` |
| **PP-02** | **`NFR001`, `NFR002` and `NFR008` are cited nowhere** in any downstream artifact. No NFR was invented to fill the gap | `[REQ §6.4]` |
| **PP-03** | **The OEE dashboard has no story, no phase and no owner** — it has an approved mockup and 17 source requirements | `[REQ §11.3]`, `[TB §7.7]` |
| **PP-04** | **The hub event count is 10, not 9.** The "9" predates `PayoffStateChanged` | `[API §10.3]` |
