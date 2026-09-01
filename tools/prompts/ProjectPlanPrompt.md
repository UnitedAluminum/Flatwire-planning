# Prompt — Generate the Flat Wire Project Plan Document Set

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — **marked SUPERSEDED — do not run**: it writes seven flat numbered documents into a folder that has held eight subject folders since 13 Aug 2026 *(previously August 18, 2026 — **`D-32`: there is no shared-schema migration.** The deployment and rollback prompts drop the FW-001 rename steps; the `INFLAT` note marked `FlatWireDB`-local *(previously July 30, 2026)*)*
**Document Type:** Reusable generation prompt (paste into a fresh Claude Code session opened at `c:\UAL\Flatwire-planning`)
**Produces:** seven documents under `MVP-1/ProjectPlan/` — ⚠ **a structure that no longer exists; see Status**
**Status:** ⚠ **SUPERSEDED — DO NOT RUN.** Retained as the record of how the plan-of-record was originally to be generated.

> ⚠ **Running this prompt today would create a second, conflicting document set.** It writes **seven numbered documents** (`01-VisionAndScope.md` … `07-DeploymentRunbookAndRollback.md`) flat into `MVP-1/ProjectPlan/` and says *"do not create sub-folders"*. That structure **no longer exists**: the 13 Aug 2026 restructure replaced it with **eight subject folders** (`Business/`, `Architecture/`, `Database/`, `Backend/`, `Frontend/`, `Development/`, `Testing/`, `Operations/`) plus `Tools/`, holding **121 markdown files**. `find MVP-1 -name "0[0-9]-*.md"` returns nothing. The old names survive only as provenance notes and in `REVIEW.md`, which keeps them deliberately.
>
> **Nothing in `MVP-1/ProjectPlan/` is derived from this prompt any more**, and the map is [`../../DOCUMENTS.md`](../../DOCUMENTS.md). Its own §2 source hierarchy has also drifted — several inputs it names were absorbed and deleted on 13 Aug 2026 — so the corrections below are marked inline rather than the whole file being rewritten to a structure nobody wants regenerated.
>
> ⚠ **Its drift has leaked outward and is worth knowing about:** `CLAUDE.md` describes the PLC tag surface's former homes as `02-SRS.md` §9 / `03-HLD-and-ERDiagram.md` §9 / `04-APIContract.md` — filenames that now exist only inside this prompt. Marked superseded 25 Aug 2026.

---

## How to use this file

Open a Claude Code session with `c:\UAL\Flatwire-planning` as the working directory and paste everything below the line marked **PROMPT STARTS HERE**. Run it in one session if possible; if context runs short, run it in the two passes described in §8 (Pass A = docs 1–4, Pass B = docs 5–7 + traceability closure), because docs 5–7 depend on the IDs minted in docs 1–4.

---

# ===== PROMPT STARTS HERE =====

You are producing the formal project-plan document set for the **United Aluminum Flat Wire Mill module**. Everything you need already exists in this repository as analysis, schema, contracts, mockups and a consolidated master specification. **Your job is reconciliation and restructuring into delivery-grade documents — not invention, and not writing application code.**

## 1. Deliverables

Create the directory `MVP-1/ProjectPlan/` and write exactly these seven markdown documents:

| # | File | Document |
|---|---|---|
| 1 | `01-VisionAndScope.md` | Vision & Scope |
| 2 | `02-SRS.md` | Software Requirements Specification, **with non-functional requirements folded in** (not a separate annex) |
| 3 | `03-HLD-and-ERDiagram.md` | High-Level Design + ER diagram |
| 4 | `04-APIContract.md` | API contract (REST + real-time hub + PLC/OPC surface) |
| 5 | `05-SprintPlanAndBacklog.md` | Sprint plan / backlog |
| 6 | `06-TestPlanAndTestCases.md` | Test plan + test cases |
| 7 | `07-DeploymentRunbookAndRollback.md` | Deployment runbook + rollback plan |

Optionally also write `00-README.md` — a one-page index of the seven with a read order and a "which document is authoritative for what" table. Nothing else. Do not create sub-folders, do not emit `.docx`, do not write `.sql`, `.ts` or `.cs` files.

**Do not modify any existing file in this repository.** `Analysis/`, `MVP-1/ProjectPlan/`, `MVP-1/ProjectPlan/Frontend/Mockups/`, `MVP-1/SRS/`, `BaseDocuments/` and `../../10-requirements/MasterSpecification.md` are read-only inputs for this task. Everything you write goes in `MVP-1/ProjectPlan/`.

## 2. Source hierarchy — read in this order, and obey this precedence

1. **`../../10-requirements/MasterSpecification.md`** (**3,646 lines as at 25 Aug 2026**; this said 3,415 lines / Jul 30 2026) — the **primary input**. It is already a reconciliation of the whole repo, section-mapped as: §1 exec summary · §2 domain/glossary · §3 process flows · §4 functional requirements (`FR-###`) · §5 data model · §6 API & real-time · §7 UI · §8 architecture/integration · §9 delivery roadmap · §10 decisions register · §11 open issues (`OI-##`) · Appendix A provenance. Read it **in full** before writing anything. Most of your content is a re-cut of this document for a specific audience — so read it once, cut it many ways.
2. **`MVP-1/ProjectPlan/Database/Schema/SQL/*.sql`** — authoritative for column-level types, nullability, constraints, indexes and FKs. [`../../30-database/DatabaseDesign.md`](../../30-database/DatabaseDesign.md) §6–§7 describes the as-built schema, and `[DBD §6.2]` is the counted object baseline. *(It absorbed `FlatWire_ERDiagram_Documentation.md` on 13 Aug 2026; that file no longer exists.)*
3. **`MVP-1/ProjectPlan/Frontend/Mockups/*.html`** — authoritative for pixel-level layout and screen behaviour. `../../50-frontend/mockups/flat-wire-shopfloor.styles.scss` is the token system.
4. **`MVP-1/ProjectPlan/Development/Phases/`** — `../../20-architecture/Architecture.md` (§0.2 reference-code map, §0.3 domain cheat-sheet, §0.4 real-time architecture, §0.5 stub-first delivery contract), `phase-01..14-*.md`, `../../90-registers/Gaps.md` (dependency chain, milestone calendar, gaps register **`G1`–`G52` *(this said `G1`–`G18`)***).
5. **`../../60-delivery/CapacityAndEffortModel.md`** — the effort/capacity arithmetic behind the sprint plan (streams, unit-rate card, per-phase hours, descope ladder).
6. **`../../95-archive/design-notes/REVIEW.md`** — the audit of known contradictions between docs. **Consult it before trusting any single spec**; it tells you which document wins.
7. **`Analysis/*.md`** — per-topic prose specs; `../../90-registers/Questions.md` is the authoritative decision register — ⚠ **renumbered to `Q##` in the 12 Aug 2026 sweep, and split in two**: open items there (57), decided in `../../90-registers/Decisions.md` (30). `OQ-##` is the old form.
8. ⚠ ~~**`MVP-1/ProjectPlan/APIContracts.md`**~~ and ~~`03-HLD-and-ERDiagram.md` §14~~ — **both absorbed and deleted 13 Aug 2026** (now `../../40-backend/APIs.md` and `../../20-architecture/Architecture.md` §14); `FlatWireSchema_Mapping.md` — **April 29–30 2026 vintage, superseded where they disagree with the July 26 roadmap and the master spec.** Mine them for detail, never for precedence. **`05-SprintPlanAndBacklog.md` is no longer in this group** — it was rewritten on 13 Aug 2026 as the **authoritative MVP-1 backlog** (**116 stories / 3,292 h**, four even two-week sprints, sized in **hours** off `CapacityAndEffortModel.md` §2 and reconciling to its §3b). Treat it as current and as the source for story ids, sprint assignment and per-story effort. `04-APIContract.md` carries four known Tier-1 correctness bugs already corrected in master spec §6 — use the corrected version.
9. ~~**`MVP-1/SRS/Shopfloor_Flat_wireSRS_Consolidated_v3.docx`**~~ — **removed from the repository 1 Aug 2026** (git history `6096921`). Read [`../../10-requirements/BusinessRequirements.md`](../../10-requirements/BusinessRequirements.md) instead; it carries the rule text. Was the delivered SRS; source of the `OL`/`PCI`/`CHK`/`WLD`/`PSM`/`SPC`/`NFR`/… requirement IDs. Read via the master spec's citations rather than re-extracting the `.docx`.
10. **`BaseDocuments/`** — read-only business source `.docx`/`.xlsx`. Cite, don't re-derive.
11. **`../../CLAUDE.md`** (`c:\UAL\CLAUDE.md`) — the ecosystem stack conventions the implementation must live inside.

**Precedence rule when two sources disagree:** master spec → DDL (for columns) / mockups (for pixels) → July 26 roadmap + `ShopfloorPlan/*` → April docs. If you find a conflict the master spec does **not** already resolve, do **not** silently pick one: state both readings, pick the one consistent with the July 26 baseline, and log it in that document's *Open Items* section with a new `PP-##` ID.

## 3. Rules that apply to every document

**Repository conventions (non-negotiable — match the existing docs):**

- Open with the standard header block: **Project · Last Updated · Document Type · Status**, plus **Owner** and **Audience**, plus a **Sources** line listing the specific inputs that doc consolidates.
- **Do not close with a Change Log table.** Since 12 Aug 2026 the repository has exactly one change log, [`../../CHANGELOG.md`](../../CHANGELOG.md) at the root; no document carries its own. Record the creation of each file as a row under that file's `##` section there (`| Date | Changed By | Description |`), adding the section if it does not exist yet.
- All dates are **US business dates in 2026**. Never introduce a date outside the authoritative timeline (§4 below).
- Markdown only. Use relative links (`../../10-requirements/MasterSpecification.md`, `../../50-frontend/mockups/dashboard_1_line_status.html`) and verify every link target exists before writing it.
- Tables over prose wherever the content is enumerable. Prose only where reasoning must be carried.

**Terminology and domain rules:**

- Always **"flat wire"**, never **"strip"**.
- The traveler is **fully digital** — no printing. Coil, spool and skid **labels are still printed**.
- **Induction welds only.** Laser welding was removed May 21 2026; do not mention it except as a superseded decision.
- **No software stop command to the PLC.** The application is a gatekeeper; the operator stops the machine physically.
- Alpha formats: Rod `R#####` · Spool `SP-#####` · Run `RUN-####` · Pass schedule `PS-{alloy}-{line}-{seq}` · Output coil `FW-#####-C##` (mid-run child `…-A`) · Die `D-{size×1000}-{seq}`.
- Line facts that are frequently got wrong: **FL1 has no edger**; **FL2 edgers exist at S2 and S3 only**; **FL2 gauge trace is historical/profile and broadcasts `null` live gauge/width**; FL1 and FL3 are real-time; FL3 is FL1 feeding FL2 continuously with no intermediate anneal.
- New coil status is `INFLAT` — ⚠ **`FlatWireDB`-local only since `D-32` (18 Aug 2026)**; it is never added to the shared coil-status vocabulary, because the shared-schema migration is cancelled. Flattening operation letter is `F` *(not cancelled — a value in an existing column)*.

**Traceability (the single most important quality bar):**

- Preserve existing IDs — never renumber. `FR-###` (master spec §4), SRS IDs (`OL001`, `CHK004`, `NFR012`, …), `FW-###` backlog stories, `OQ-##` open questions, `OI-##` open issues, `G##` gaps, dashboard IDs (DB1–DB14, 2A, 7b, 9A).
- Mint new IDs only in the ranges this prompt assigns: `TC-###` (test cases), `RISK-##`, `PP-##` (new contradictions you discover). Nothing else.
- Every requirement, endpoint and test case carries its upstream citation in a **Source** column.
- **No orphans, both directions**: every `FR-###` reaches at least one backlog story and at least one test case; every test case names the `FR-###` it proves. Docs 5 and 6 each end with a coverage matrix that proves this, and each states explicitly what is *not* covered and why.

**Honesty rules — do not smooth these over:**

- The schedule does not close as scoped. The plan is **3,727 hours / 465.9 dev-days across 14 phases against 44 working days (32 post-gate)** → **10.6 FTE sustained**, a 10.7-FTE Phase-1 gate, an arithmetically impossible 27.2-FTE W7, and a descope ladder recovering only **12%**. This is gap **G1** / **OI-51**. Carry it into the vision doc's risks and the sprint plan's front matter as a **programme decision required** (staff to ~11 FTE · move the date — 6 FTE → 18 Nov 2026, 8 FTE → 22 Oct 2026, both inside the planned Q4 window · or cut below the critical path). Do not silently rescope to make the plan look feasible; do not invent a staffing number the source doesn't support. *(⚠ **3,727 h predates the 11 Aug 2026 MVP split.** The live figures are **3,186 h** scheduled and **`3,358 h` all-in** — `[CE §3e]`.)*
- The **footage→weight conversion factor is undefined** (OQ-10 / OI-45) and every output weight, yield and remaining-weight estimate depends on it.
- **Pass Schedule content is still being authored by Operations**, and Phase 2 gates every check-in phase.
- **Known schema divergence — resolve it, loudly.** The master spec §5 and the current DDL/ER doc describe **34 tables** with a FlatWireDB-local `Rod` master; `../../20-architecture/Architecture.md` §13.1 `D-04` and `phase-01c` say `Rod` is *dropped* in favour of the shared `coils` table (21–22 tables, unenforced cross-DB rod-alpha links). The master spec §5.2 states the resolved position — follow it, restate it explicitly in doc 3 §data model, and flag the stale side. **Verify the table count against `MVP-1/ProjectPlan/Database/Schema/SQL/` before you publish a number.** Do not copy a table count from any doc without counting.
- Where the source says "TBD", write "TBD" with the owning `OQ-##`/`OI-##` — never a plausible-looking placeholder value.

**Section-numbering rule:** number every section (`§1`, `§1.1`) so the other six documents can cite it precisely. Cross-document citations use `[VS §3.2]`, `[EX §4.7]`, `[CMP §5]`, `[PLCC §6.4]`, `[SP §2]`, `[UAT §7]`, `[DEP §4]`.

## 4. The authoritative timeline — use these dates and no others

| Milestone | Date |
|---|---|
| Phase 1 (core platform) hard gate | **14 Aug 2026** |
| Feature development window | **17 Aug → 30 Sep 2026** (~6.5 weeks; 32 post-gate working days, 44 including the run-up) |
| Labor Day (deducted) | Mon **7 Sep 2026** |
| UAT | **28–30 Sep 2026** |
| On-line trial | early Oct 2026 (TBD) |
| Production go-live | Q4 2026 (TBD) |

The `Jul 1 2026 trial / Aug 1 2026 production` and the 5-sprint model that appear in the April-dated docs are **superseded** — mention them only in a "superseded" note.

## 5. Per-document specifications

### Doc 1 — `01-VisionAndScope.md`

**Audience:** sponsors, programme management, business owners. **Length:** ~6–10 pages. **Primary source:** master spec §1, §2, §9.6, §10, §11.

Required sections:

1. **Business context and opportunity** — why UAL is entering oscillate-wound flat wire; the cost and welding-wire-customer drivers; the ~24 existing applications requiring extension (`BaseDocuments/New Flat Wire Machine - Impact on Applications 041726.xlsx`).
2. **Vision statement** — one paragraph, then the measurable outcomes it implies.
3. **Product overview** — the three lines (FL1 / FL2 / FL3) and the material journey in one page, with the equipment inventory summarised.
4. **The two things that make this module unlike every other UAL shopfloor module** — the Pass Schedule as the machine's brain (operator acknowledgement is what pushes PLC tags), and weld genealogy as a **contractual** deliverable.
5. **Stakeholders and roles** — Operator, Supervisor, Operations Manager, Engineering/Maintenance, QA, Admin, plus IT/PLC integration; what each needs from the system.
6. **In scope** — by area (operator screens, dashboards, data model, integration, quality), each row traceable to master spec §1.3.
7. **Out of scope, with owner and consumed interface** — rod receiving (CoilReceiving), order planning & line scheduling (Planning/Scheduling), yield/cost ledger, web order/quote changes (Epic E06), EDI rod receiving. For each, state precisely **what this module consumes** from it.
8. **Non-goals** — no new frameworks, no printed traveler, no auto-applied pass schedule, no software PLC stop, no laser welding, never "strip".
9. **Success criteria and acceptance measures** — phrased so doc 6 can test them and doc 7 can gate a release on them.
10. **Constraints and assumptions** — stack constraint, the 1280×1024 shopfloor panel and 14px minimum text floor, the transactional boundary, environment topology.
11. **Key risks** — table with `RISK-##`, description, probability, impact, owner, mitigation, linked `G#`/`OI-##`. `RISK-01` is the schedule/capacity gap (G1). Include the three "most likely to stop this project" items from master spec §1.5.
12. **Decisions already made and closed to re-litigation** — a condensed pointer into master spec §10 (do not restate all of it).
13. **Open items** — the Critical tier of master spec §11.1 only, with owner and needed-by date.

### Doc 2 — `02-SRS.md`

**Audience:** developers, QA, BA. **Length:** long — this is the reference document; completeness beats brevity. **Primary source:** master spec §2, §3, §4, §7, §8.5.

Structure:

1. **Introduction** — purpose, scope, definitions/acronyms, references, document conventions, requirement-ID scheme, and the **priority scheme** (`Must` / `Should` / `Could` — carry the priorities the master spec already assigns).
2. **Overall description** — product perspective inside the UAL MES, product functions, user classes, operating environment (shopfloor panels, browsers, PLC/OPC), design and implementation constraints, assumptions and dependencies.
3. **Domain model and glossary** — from master spec §2: the three lines, equipment inventory, alpha/identifier formats, status vocabularies (run status, material status), glossary. Include the run-status and material-status **state machines** as mermaid `stateDiagram-v2`.
4. **Process flows** — the eleven stages, pre-check-in, check-in, in-run events, the three checkout modes, partial-rod re-check-in (carry-forward), the route split at FM1 output, FM2 finishing → coil completion → packing, and the parallel scrap path. Use mermaid `flowchart` for the main journey and the route split.
5. **Functional requirements** — **carry every `FR-###` from master spec §4 forward with its number unchanged**, organised by the same operator-workflow groups (§4.0 cross-cutting, then §4.1–§4.24 by screen). For each group keep: screen + mockup link, SRS IDs, actors, preconditions, priority, field-level validation, actions, state changes, error paths, real-time events emitted. Table format: `| ID | Requirement | Priority | Source |`.
6. **Non-functional requirements — folded in, not annexed.** This is an explicit requirement of this task. Do both:
   - Place each NFR **inline in the functional group it constrains**, marked `[NFR]`, so a developer reading the check-in section sees the latency and audit obligations that apply to check-in.
   - Then add **§6 NFR register** — a single table of every `NFR###` with ID, category (performance · reliability · availability · security · auditability · usability · data retention · maintainability · integration), the measurable target, the verification method (which `TC-###` proves it — fill after doc 6 exists, or state "TC pending"), and the FR groups it constrains. Where an NFR target is **undefined** (AGC sample rate, concurrent client count, latency budget, reading retention — gap **G9** / OI-34), say "undefined — G9/OI-34", never a guess. Known concrete NFR targets to carry: 1-second default push interval configurable to 5/10/30 s with **no polling** (`NFR005`), two simultaneous dashboard instances (`NFR007`), 4 ft/20 ft recording frequency rules (`NFR003`/`NFR004`, FR-018), R-series permanent retention (`NFR013`), block-passive-dismissal on supervisor overrides (`NFR009`), who/when/why audit on every override, supervisor action, pass-schedule change and PLC tag write/clear (`NFR010`/`NFR011`), reconnect-with-cached-state and never a blank screen (`NFR006`, FR-119).
7. **UI requirements** — screen inventory with the **approved variant** named per screen (notably Dashboard 2 = `dashboard_2_rod_checkin.html`, the 6-step tab wizard; the `- Old.html` ring version is retired), navigation map, shared chrome, design-token system (`--color-*`; the `--fw-*` prefix in older docs is **stale** — gap G18), shopfloor constraints including the **14px minimum text size** and its documented SVG-axis exceptions, and the reusable `fw`-prefixed controls to build.
8. **Security, roles and permissions** — the full role × capability matrix from master spec §8.5, plus supervisor-override rules and audit obligations.
9. **External interface requirements** — PLC tag push/clear, OPC tag consumption (mill speed, feet consumption, ITInhibit), SignalR events, cross-database touchpoints, and ~~the FW-001 shared-schema renames (`CoilNo` → `Coil/BundleNo`, `SlitWidth` → `Slit/FlatWidth`)~~ **— cancelled, `D-32`, 18 Aug 2026; the shared schema is used as it stands** with their blast radius.
10. **Traceability appendix** — `FR-###` ↔ SRS ID ↔ dashboard ↔ phase.
11. **Open requirements issues** — the `OI-##` items that block requirement closure.

### Doc 3 — `03-HLD-and-ERDiagram.md`

**Audience:** architects, developers, DBA. **Primary source:** master spec §5, §6.7, §8; `Schema/SQL/*`; `../../20-architecture/Architecture.md` §2.2/§0.4.

Required sections:

1. **Architecture overview** — context diagram (mermaid) showing the flattening lines → PLC/OPC → `FlatWire.API` → `FlatWireDB`, alongside the shared UAL databases, the Angular shell and the existing services; then the component view.
2. **Where the code lands** — Angular library `flat-wire` in `../ual-angular`; new `FlatWire` microservice in `../ual-api`. State the **binding reference-code rules** from `../../20-architecture/Architecture.md` §2.2 explicitly, because they are non-obvious: `API/Domain/CoilCheckin` is the **primary backend template**; `OPCConnection` is the PLC tag layer to integrate with; **`SlitterInterface` is explicitly NOT a reference**; there is **no** Angular structural/UI template — the library is all-new screens, and the only frontend reuse is the foundational `shared` services (api-gateway, app-config, login, token/correlation interceptors, error handler, ui-log, notification, subscription, print-export, util). Membership of the `build:shop-floor` chain is **build ordering only** and implies no code reuse.
3. **Backend design** — Clean Architecture layering per the UAL pattern (API / Application / Domain / Infrastructure), MediatR CQRS, `UAController` envelope (`Data`/`Success`/`Errors`), validation and behaviors, logging/Serilog, error handling.
4. **Real-time architecture** — from `../../20-architecture/SignalR.md` §4 and master spec §6.7: `FlatWireHub` hosted **only** inside `FlatWire.API` (the shared `Notification` service is not extended; `CoilDataHub`/`OPCManagerHub`/`supervisor-monitor-hub` are **not** templates), WebSockets-first, MessagePack, strongly-typed `Hub<IFlatWireClient>`, bounded-channel ingest with batching/decimation, NgZone-out + rAF rendering, backplane-ready scale-out, group-per-line, reconnect/backoff semantics.
5. **Frontend design** — library structure, routing, state, the SignalR client wrapper, chart strategy, the design-token system, and how the mockups map to components.
6. **Data model** — target database is the **new standalone `FlatWireDB`** (not `united_db`). Give the five groups (Lookup → Schedule → Materials → Runs → Quality/Output), the table inventory with one-line purpose each, key columns, and the `FlatWireRun` hub role plus `RunReading` as the AGC time-series store (closes gap G3). **Count the tables from the DDL and state the number you counted**; restate the `Rod`-table resolution from master spec §5.2 and flag the stale opposing docs.
7. **ER diagram** — a mermaid `erDiagram` covering all tables and all FK relationships with cardinality. If one diagram is unreadable, publish one **overview** diagram of the five groups and their inter-group edges plus one detailed diagram per group — never omit a table. Follow it with the full FK list (source table → target table → column → on-delete behaviour) and the index/programmability summary.
8. **Cross-database touchpoints** — the shared `coils`, `planning_routings`, scheduling and WIP/rejection tables this module reads or writes, marked as enforced FK vs unenforced logical link.
9. **Integration design** — the PLC/OPC surface: which tags are pushed on pass-schedule acknowledgement, which are read, `ITInhibit` semantics and its five set conditions, tag paths sourced from `appsettings.json` and never hardcoded (FR-022).
10. **The transactional boundary** — master spec §8.6; read this before writing check-in. State it as an explicit design rule.
11. **Environments and topology** — dev/test/staging/production per the UAL conventions, and which services must be running for a full-stack run.
12. **Cross-cutting concerns** — auth/JWT, correlation IDs, logging, caching, resilience, performance budgets, and how each NFR from `[REQ §6]` is architecturally satisfied.
13. **Architecture decisions** — an ADR-style table of the decisions from master spec §10.1 with their rationale; then the design risks.

### Doc 4 — `04-APIContract.md`

**Audience:** frontend and backend developers, integration testers. **Primary source:** master spec §6 (**already corrected** — it fixes four Tier-1 bugs present in `MVP-1/ProjectPlan/APIContracts.md`); cross-check `REVIEW.md` Tier 1 before carrying anything from the April contract.

Required sections:

1. **Conventions** — base URL `/api/v1/flatwire`, the `Data`/`Success`/`Errors` response envelope, auth (JWT bearer), correlation-id header, HTTP status usage, pagination, date/time format and timezone, units and their precision (feet, inches, mils, lbs), and the error-code catalogue.
2. **Canonical enums** — define once, and state the three-way mirroring rule (C# ↔ TypeScript ↔ DB `CHECK` constraint). Explicitly resolve the **three competing edge-type vocabularies** and the **missing `CheckpointType` value** noted in `REVIEW.md` Tier 1, naming the winner.
3. **Endpoint index** — all 30 endpoints: method, path, purpose, auth/role required, owning controller, phase, and the `FR-###` it serves.
4. **Endpoint detail** — for each: request shape (with per-field type, required/optional, validation rule), response shape, worked example request **and** response, status codes, error cases, side effects (rows written, PLC tags pushed, hub events emitted), and idempotency behaviour. Where the April doc's `/passschedule/generate` worked example is wrong, publish the corrected one and note the correction.
5. **`FlatWireHub` contract** — all 9 events: name, payload shape, emitting trigger, subscriber group, cadence, and the FL2 `null` live-gauge/width rule. Include connection lifecycle, group join/leave by line, reconnect semantics, and the MessagePack/WebSockets transport requirements.
6. **PLC / OPC surface** — tags pushed and cleared, tags read, `ITInhibit`, configuration-sourced paths.
7. **Stub-first delivery contract** — the shopfloor UI builds against dummy data first (`../../20-architecture/Architecture.md` §2.2 **§0.5**, where the model was rehomed on 13 Aug 2026 when `CheckinImplementationPlan.md` was deleted). Define what a stub must return so the UI can develop against it, and the switchover criteria.
8. **Versioning and change policy.**
9. **Traceability** — endpoint ↔ `FR-###` ↔ screen ↔ phase.
10. **Open contract issues** — anything still `OI-##`-blocked.

### Doc 5 — `05-SprintPlanAndBacklog.md`

**Audience:** delivery lead, scrum team, programme management. **Primary source:** master spec §9; `../../60-delivery/CapacityAndEffortModel.md`; `../../90-registers/Gaps.md`; `05-SprintPlanAndBacklog.md`.

Required sections:

1. **Capacity reality check — put this first, not in an appendix.** The measured position (3,727 h / 465.9 dev-days vs 44 working days → 10.6 FTE sustained; 10.7 FTE for the Phase-1 gate; 27.2 FTE in W7; descope ladder recovers 12%), the three programme options with their dates (staff to ~11 FTE · 6 FTE → 18 Nov 2026 · 8 FTE → 22 Oct 2026 · cut below the critical path), and a clear statement that **the plan below is presented as scoped and does not fit the window** pending that decision. Link G1 / OI-51. *(⚠ **3,727 h predates the 11 Aug 2026 MVP split.** The live figures are **3,186 h** scheduled and **`3,358 h` all-in** — `[CE §3e]`.)*
2. **Delivery model** — the fourteen phases as **end-to-end vertical slices** (Phase 1 is the only layer-organised phase: 1A Angular / 1B Backend / 1C Database). State why the two upstream phases (rod receiving, order planning/line scheduling) were removed and now enter as prerequisites at Phase 4.
3. **Team model** — the six delivery streams (FE Angular · BE .NET · DB SQL · RT real-time/PLC · QA · BA) and the named-owner roster **left unfilled where the source leaves it unfilled**. Unit-rate card at 1 dev-day = 8 h.
4. **Sprint calendar** — map the fourteen phases onto sprints across the authoritative window (W0 = to the 14 Aug gate; Labor Day 7 Sep deducted; W7 is 3 days). Per sprint: goal, phases included, entry criteria, exit criteria, demo content, and the milestone/QA gates (M1, QA0, QA2, UAT).
5. **Phase table** — number, name, owning streams, hours, dev-days, week, dependencies, `OQ-##` blockers, backlog stories, and the phase file link.
6. **Dependency chain** — mermaid diagram plus the critical path called out explicitly, including that **Phase 2 (Pass Schedule) gates every check-in phase**.
7. **Backlog** — all **12 epics / 58 stories** (`FW-###`) with epic, story, phase, stream, points, priority, dependencies, and **acceptance criteria written as Given/When/Then**. Preserve every existing `FW-###` number; if the master spec's `FR-###` set implies work no story covers, add it as a **new story flagged `[NEW]`** with a rationale rather than quietly folding it into an existing one. Note explicitly that epic **E01 contains no story for the Angular or .NET scaffold** — a known omission and part of why the window was believed to fit. ~~Flag `FW-001` (shared `coils`/scheduling renames) as **high blast radius, front-load the impact audit**.~~ **Cancelled, `D-32`, 18 Aug 2026 — there is no shared-schema migration**, so `FW-001` and `FW-002` are cancelled and there is no audit to front-load.
8. **Descope ladder** — the ordered list with hours recovered per rung and the cumulative 12% ceiling; state what each cut costs the business.
9. **Definition of Ready / Definition of Done** — including the doc-6 test evidence required before a story is Done.
10. **Risk and issue register** — carry `RISK-##` from `[VS §11]`, plus the `G##` gaps register and the `OI-##` blockers, each with owner and needed-by date.
11. **Coverage matrix** — every `FR-###` → story. State any FR with no story and why.

### Doc 6 — `06-TestPlanAndTestCases.md`

**Audience:** QA, developers, UAT participants. **Primary source:** `[REQ]` (doc 2) for what to prove; master spec §4 error paths and §11 for risk-based prioritisation; `phase-14-integration-testing-plc-commissioning-golive.md` for the commissioning shape.

Required sections:

1. **Test strategy** — objectives, the test pyramid mapped onto the UAL stack (Jest unit + component for Angular at the 95%-coverage bar, xUnit + Moq for .NET, integration tests against a seeded `FlatWireDB`, contract tests against `[API]`, real-time/hub load tests, PLC/OPC commissioning tests, UAT), and what each level owns.
2. **Scope** — in/out of test scope; the risk-based prioritisation that decides depth (weld genealogy, pass-schedule→PLC push, ITInhibit, footage/weight, and FL2's `null` live-trace behaviour get the deepest coverage).
3. **Environments and test data** — which environment each level runs in; the seed-data scripts (`FlatWire_SampleData_*.sql`); how to build/tear down (`FlatWire_DDL_RunAll.sql` / `_99_Teardown.sql`, SQLCMD mode required); PLC simulation vs real line, and what cannot be tested before commissioning.
4. **Entry / exit criteria and suspension-resumption rules**, per level and per gate (QA0 at the Aug-14 gate, QA2, UAT 28–30 Sep).
5. **Test cases** — the substance of this document. Number `TC-###`. Table columns: `TC-### | Title | Level | Priority | FR-### | SRS ID | Preconditions | Steps | Expected result | Data | Automatable?`. Group by the same operator workflows as `[REQ §5]`. **Cover happy path, boundary, negative/error path, permission/role, and real-time behaviour for each group.** Mandatory coverage — write these explicitly, they are where this system will actually break:
   - Pass-schedule acknowledgement pushing PLC tags, and the mid-run override alert that **cannot be passively dismissed** (line continues on previous PLC values until acknowledged).
   - `ITInhibit` set/clear across all five set conditions, including two consecutive missed recordings.
   - Weld genealogy end-to-end: rod → induction weld → footage attribution → output coil alpha → customer certificate query.
   - MMS ID lifecycle: one per input coil at check-in, activation on weld, automatic close of the previous, close **strictly on material consumption** (remaining ft = 0) and never on operator action.
   - The three checkout modes, and partial-rod re-check-in (carry-forward).
   - FL2 broadcasting `null` live gauge/width while still producing a historical/profile trace; FL1/FL3 real-time trace.
   - FL3 hybrid continuous operation with both instances at 4 ft.
   - Recording-frequency rule (4 ft finished / 20 ft intermediate / FL2 always 4 ft / FL3 both at 4 ft).
   - Reconnect: "Reconnecting…" banner over cached last-known state, **never a blank screen**, auto re-join of the line group.
   - Progressive buildup alerts at 50% then every 10%.
   - SPC checkpoints at all four points, SPC-HOLD, CPK.
   - WIP rejection and scrap path.
   - Role/permission matrix, including supervisor override for a not-punched-in operator.
   - Audit: who/when/why captured on every override, supervisor action, pass-schedule change and PLC tag write/clear.
6. **NFR verification** — one row per `NFR###`: target, method, tooling, pass criteria. Include the hub load test (N clients × 3 lines × cadence) and mark the **undefined** NFRs as untestable-until-defined (G9/OI-34) rather than inventing thresholds.
7. **UAT plan** — participants, scenario scripts written in operator language, sign-off criteria, defect triage and severity definitions.
8. **PLC commissioning tests** — the on-line trial sequence, safety preconditions, who must be present, abort criteria.
9. **Defect management** — severity/priority definitions, SLA, and the release gate.
10. **Coverage matrix** — `FR-###` → `TC-###`, both directions; then a stated list of FRs with no test case and why.

### Doc 7 — `07-DeploymentRunbookAndRollback.md`

**Audience:** IT/DevOps, DBA, release manager, on-call. **Primary source:** master spec §5.11 (deployment), §8.4 (environments); `../../CLAUDE.md` for the UAL deployment conventions.

Write this as an **executable runbook** — numbered steps, exact commands, expected output, and a verification after every step. Assume it will be followed at 2 a.m. by someone who did not build the system.

Required sections:

1. **Release overview** — what ships, version/tag, the components (Angular `flat-wire` build, `FlatWire.API`, `FlatWireDB` schema, `OPCConnection` configuration — ~~shared-schema FW-001 renames~~ **cancelled, `D-32`**), and the release calendar against the authoritative timeline.
2. **Environments** — dev/test1/test2/dev1/dev2/staging/production with server names, app pools, database servers, and the promotion path.
3. **Pre-deployment checklist** — approvals, gates passed (`[TS §4]`), backups taken, line state (**no active run on FL1/FL2/FL3**), operator notification, maintenance window, rollback rehearsal confirmed.
4. **Deployment sequence** — ordered, with commands:
   - **Database first.** `FlatWireDB` build/upgrade via SQLCMD mode (`sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql`, run from `MVP-1/ProjectPlan/Database/Schema/SQL/` because the `:r` includes are relative; SSMS requires **Query → SQLCMD Mode**). State that every script guards its objects so `RunAll` is idempotent, and the execution order `00 → 01 → 02 → 03 → 04 → 05 → 06 FKs → 07 indexes → 08 programmability`.
   - ~~**The FW-001 shared-schema renames**~~ — **CANCELLED, `D-32`, 18 Aug 2026: there is no shared-schema migration**, so this deployment step does not exist. ⚠ **Do keep the `machines` FL1/FL2/FL3 rows and the `CommonDB` WIP-station registration** — those are row inserts into existing tables. Original instruction, retained for context: separately called out, because they touch the shared `coils`/scheduling schema used by other modules. Give the pre-flight impact check, the change, the verification, and the fact that this is the **hardest thing in the release to roll back**.
   - **API** — `dotnet publish` → IIS application pool, `appsettings.{Environment}.json` and environment variables (JWT and connection-string variables per the UAL conventions), app-pool recycle, health check.
   - **Angular** — `ng build` for the environment → static files to IIS, cache-busting, shell registration.
   - **OPC/PLC configuration** — tag paths from `appsettings.json`, and the tag-push verification on a line that is stopped.
5. **Post-deployment verification** — a numbered smoke suite citing `TC-###` from `[TS]`: login, line status board, hub connection and a live event on each line, one check-in against a real pass schedule, PLC tag push verified, one full run to coil completion in the trial environment.
6. **Rollback plan** — this is the half of the document that must be right:
   - **Decision criteria** — what triggers a rollback vs a fix-forward, who decides, and the maximum time to decide.
   - **Per-component rollback**, in reverse dependency order: Angular (previous build artifacts), API (previous publish + app-pool), database (restore vs teardown-and-rebuild — note `FlatWire_DDL_99_Teardown.sql` **drops everything** and is only safe when `FlatWireDB` carries no production data yet), OPC/PLC configuration.
   - ~~**The FW-001 renames**~~ — **CANCELLED, `D-32`: there is nothing to reverse.** The least-reversible element of the release has been removed rather than mitigated. Original instruction, retained for context: state plainly that shared-schema renames are the highest-risk, least-reversible element; give the reverse script requirement, the dependent-object recompilation check, and the "if this fails, all dependent modules are affected" escalation.
   - **Data loss assessment** — what is lost per rollback path, and what must be reconciled by hand (in-flight runs, open MMS IDs, unlabeled coils).
   - **Verification that the rollback succeeded**, and the communication template.
7. **Operational readiness** — monitoring, health checks, Serilog log locations and retention, alerting, and the runbook for the three most likely production incidents (hub disconnect storm, OPC tag path wrong after commissioning, ITInhibit stuck set).
8. **Contacts and escalation** — roles, not invented names; leave the roster table with role rows and blank names for the release manager to fill.
9. **Appendix** — command reference and file inventory.

## 6. Diagrams

Use **mermaid** fenced blocks (`erDiagram`, `flowchart`, `stateDiagram-v2`, `sequenceDiagram`). Every diagram is accompanied by prose that carries the same information — a reader with no mermaid renderer must lose nothing. Do not embed images; link to `../../MVP-1/ProjectPlan/Frontend/Mockups/Flat Wire Machine - Big Beautiful Diagram.png` where the equipment layout is relevant.

## 7. What "done" means — verify before you report completion

Run this checklist and report the result honestly. If something fails, say so rather than fixing the checklist.

- [ ] All seven files exist under `MVP-1/ProjectPlan/` with the exact names in §1.
- [ ] Every file has the header block (Project · Last Updated · Document Type · Status · Owner · Audience · Sources), and **no file carries a Change Log table** — each is instead represented by a section in the root `CHANGELOG.md`.
- [ ] Every relative link resolves to a file that exists.
- [ ] Every `FR-###` in the master spec §4 appears in `[REQ §5]` with its number unchanged.
- [ ] Every `FR-###` maps to ≥1 backlog story in `[TB §11]` and ≥1 `TC-###` in `[TCS §10]`; the exceptions are listed explicitly with reasons.
- [ ] All 30 endpoints and all 9 hub events are documented in `[API]`.
- [ ] Every `NFR###` appears both inline in its functional group and in the `[REQ §6]` register, with undefined targets marked undefined rather than guessed.
- [ ] The ER diagram covers every table in `Schema/SQL/`, and the table count you published matches the count you took from the DDL.
- [ ] The four `REVIEW.md` Tier-1 API bugs are corrected, not propagated.
- [ ] The capacity gap (G1/OI-51) is stated in both `[VS]` and `[SP]` without softening.
- [ ] No date outside §4's timeline appears as a plan date.
- [ ] The word "strip" appears nowhere except in a note explaining that it is not used.
- [ ] No file outside `MVP-1/ProjectPlan/` was created or modified.

## 8. Working method

1. **Read first, write second.** Read the master specification end to end, then `REVIEW.md`, `../../90-registers/Gaps.md`, `../../20-architecture/Architecture.md` and `CapacityAndEffortModel.md`, then skim the DDL for the table/FK inventory, before writing a line.
2. **Write in dependency order:** 1 → 2 → 3 → 4 → 5 → 6 → 7. Docs 5–7 cite IDs minted in 2–4, so do not reorder.
3. **Two-pass option if context runs short:** Pass A = docs 1–4 + the ID inventories they mint (keep a scratch list of every `FR-###`, endpoint and table). Pass B = docs 5–7, then return to `[REQ §6]` to fill the NFR verification-method column with the `TC-###` numbers doc 6 created.
4. **When a source is ambiguous, cite both readings and decide** per the §2 precedence rule — never average two specs into a third thing that appears in neither.
5. **Report at the end:** the file list with line counts, the checklist result from §7, every `PP-##` contradiction you discovered, and anything you could not complete and why.

# ===== PROMPT ENDS HERE =====
