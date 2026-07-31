# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is the **planning, analysis, and design repository for the Flat Wire Mill module** of the UAL manufacturing execution system. It contains **no shippable application code** — it holds requirements (SRS), analysis notes, a database schema design with executable DDL, API contracts, UI mockups, and a phase-by-phase implementation roadmap that drive implementation in the sibling code repos.

The actual implementation lands in **`../ual-angular`** (Angular frontend, new library `flat-wire-shopfloor`) and **`../ual-api`** (new `FlatWire` microservice). `DevelopmentPlan/Flat Wire.code-workspace` opens this folder alongside both. Ecosystem-wide stack conventions live in the parent **`../CLAUDE.md`** (`c:\UAL\CLAUDE.md`) — read it for build/test commands and general Angular/.NET/SQL patterns; this file covers only what is Flat Wire-specific.

When asked to "implement" a feature, the code goes in `ual-angular` / `ual-api`, using this repo's artifacts as the spec.

## Start Here (read order)

1. **`DevelopmentPlan/ShopfloorAndRealTimePlan.md`** — the master roadmap **index** (July 26 2026). It supersedes the earlier layer-oriented sprint plan.
2. **`DevelopmentPlan/ShopfloorPlan/00-foundations.md`** — cross-cutting context every phase depends on: §0.2 reference codebase map (what to copy from `ual-api`/`ual-angular` and what is explicitly *not* a reference), §0.3 domain cheat-sheet (routes, alpha formats, status vocabularies, hub events), §0.4 the purpose-built real-time architecture. Phase files cite these by section number.
3. **`DevelopmentPlan/ShopfloorPlan/back-matter.md`** — dependency chain, milestone calendar, and the **Gaps register (G1–G18)**.
4. **`DevelopmentPlan/REVIEW.md`** — a tiered audit of `DevelopmentPlan/` listing known contradictions between docs. Read before trusting any single spec; it tells you which doc wins.

## Domain in One Screen

United Aluminum is adding flat wire manufacturing: three new **Flattening Lines** that convert aluminum rod into coreless oscillated flat wire coils.

- **FL1** (standalone): rod → wire drawing (DB1/DB2) → 12" mill FM1 → intermediate spool. Gauge trace is **real-time**. FL1 has **no edger**.
- **FL2** (standalone): pre-flattened spool → finishing mill FM2 (8" → 6" S1/S2/S3; **edgers at S2 and S3 only**) → coreless coil. Gauge trace is **historical/profile** (FL2 broadcasts `null` live gauge/width).
- **FL3** (hybrid): FL1 feeding FL2 continuously, no intermediate anneal. Real-time.

Recurring concepts:

- **Pass Schedule** — the master configuration record (components active/bypassed, die sizes, edge type, roll clearances, gauge/width targets, route mode). **Highest-priority dependency**: operator check-in acknowledges it and the system pushes PLC tags from it on acknowledgement. Manually maintained, not auto-generated. Phase 2 gates every check-in phase.
- **FlatWireRun** — the central run header (one per check-in); nearly every event/quality table hangs off it. A `FlatWireRunDetail` header/detail split is part of the design.
- **Weld traceability** — **induction** welds (laser dropped) join rod-to-rod for continuous feed; the system must trace which source rods produced which output-coil footage (required for welding-wire customer certs). `CoilTraceability` is that genealogy chain.
- **SPC checkpoints** — incoming rod, post-die-change, FM1 output, FM2 S2 output; some manual, some automatic (AGC).
- **Alpha formats:** Rod `R#####` · Spool `SP-#####` · Run `RUN-####` · Pass schedule `PS-{alloy}-{line}-{seq}` · Output coil `FW-#####-C##` (mid-run child `…-A`) · Die `D-{size×1000}-{seq}`. Full list in `00-foundations.md` §0.3.
- **Terminology rule:** always "flat wire," never "strip." Traveler is **fully digital** (no printing; coil/skid labels are still printed).

**Timeline (authoritative):** development window **17 Aug → 30 Sep 2026** with a hard **Phase-1 gate of 14 Aug 2026**; UAT late Sep, production Q4 2026. The "Jul 1 trial / Aug 1 production, 5-sprint" targets still present in the April-dated docs are **superseded**. Stay within the existing UAL stack — no new frameworks (`DevelopmentPlan/TechStackRecommendation.md`).

## Repository Layout

| Path | Contents |
|---|---|
| `Analysis/` | Per-topic analysis notes (end-to-end process, dashboards, die management, weld event, SPC, rod check-in/checkout, spool, pass schedule, HMI/SCADA, operations manager, open questions). Prose specs. |
| `DevelopmentPlan/` | `ShopfloorAndRealTimePlan.md` (roadmap index), `REVIEW.md`, `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`, `Checkin*` plan+prompt, `Flat Wire.code-workspace`. |
| `DevelopmentPlan/ShopfloorPlan/` | The roadmap proper: `00-foundations.md`, `phase-01..14-*.md` (Phase 1 split into `01a` Angular / `01b` Backend / `01c` Database), `back-matter.md`. |
| `DevelopmentPlan/Schema/` | Per-domain schema design docs (`FlatWireSchema_*.md`: Lookup, Schedule, Materials, Runs, QualityOutput, Mapping). |
| `DevelopmentPlan/Schema/SQL/` | Executable DDL + seed data + `FlatWire_ERDiagram_Documentation.md`. |
| `Mockups/` | Standalone HTML operator dashboards + shared design system + shared JS chrome. |
| `BaseDocuments/` | Source requirement docs from the business (meeting summaries, web-changes specs, impact tracker `.xlsx`). Read-only inputs. |
| `SRS/` | Delivered SRS `.docx` (`Shopfloor_Flat_wireSRS_Consolidated_v3.docx` is current). |
| root `Shopfloor_Flat_wireSRS_Consolidated_v2.docx`, `Flat Wire Mockups.xlsx` | Untracked working copies at root; the tracked/current SRS lives in `SRS/`. |

## Working With the Artifacts

### Database schema (`DevelopmentPlan/Schema/`)

The design exists in three forms that must stay in sync: **markdown design docs** (`FlatWireSchema_*.md`), **executable DDL** (`SQL/FlatWire_DDL_*.sql`), and the **phase-1C spec** (`ShopfloorPlan/phase-01c-database-foundation.md`). Read `SQL/FlatWire_ERDiagram_Documentation.md` first — it describes the **as-built** schema.

- Target database is a **new standalone `FlatWireDB`** (not `united_db`), created by `FlatWire_DDL_00_Database.sql`. Older DDL headers said `USE [united_db]`; anything still saying that is stale.
- DDL files are **numbered by execution order**: `00` database → `01` Lookup → `02` Schedule → `03` Materials → `04` Runs → `05` Quality/Output → `06` **all FKs** → `07` Indexes → `08` Programmability. `99` is teardown. Preserve this ordering when adding tables, and put new FKs in `06`.
- Groups: Lookup (`Stand`, `Drawer`, `Edger`, `SpoolConfiguration`, `AlloyProperty`, `PayoffPosition`) → Schedule (`PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog`) → Materials (`Rod`, `FlatWireRun`, `Spool`) → Runs (`FlatWireRunDetail`, `RodCheckin`, **`RodStaging`**, `SpoolCheckin`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `RunReading`) → Quality/Output (`SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout`).
- **Known divergence — check dates before acting.** `00-foundations.md` decision 3 and `phase-01c` say the `Rod` table is *dropped* (rod lives in the existing shared `coils` table; rod-alpha refs become unenforced cross-DB links). The ER doc and current DDL keep `Rod` as a FlatWireDB-local master mirroring `coils`, with enforced rod-alpha FKs. The DDL/ER doc reflect the later "Hybrid foundation" decision. Confirm which applies before changing either side, and update both. **Current count is 27 tables** (`RodPreCheckin.md`, gap G12) — `RodStaging` and `PayoffPosition` were added for pre-check-in; the older "21–22 vs 25" figures in this file were stale.
- **`RodStaging` (pre-check-in / payoff staging)** is the newest table and carries two invariants worth knowing before touching it: `Blocked` is a **derived** bay state (`Status='Staged'` + any inspection column `='Fail'`), never a fourth `Status` value; and `IsWelded` is a **flag on a `Staged` row**, not a status — so any code branching on "staged" also matches welded and blocked rods unless it says otherwise. See `Analysis/RodPreCheckin.md` and gap **G21** (the `(LineId, PayoffPosition)` uniqueness scope is unresolved across FL1/FL3).
- `FlatWireRun` is the hub; `RunReading` is the time-series AGC gauge/width store added to close gap **G3**.

**Deploying the schema** (SQLCMD mode required — `:r` includes):

```powershell
# Full build + seed, in order. Run from the SQL folder (paths are relative).
cd "c:\UAL\Flatwire-planning\DevelopmentPlan\Schema\SQL"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -C -i FlatWire_DDL_RunAll.sql

# A single script
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_04_Runs.sql

# Drop everything
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql
```

Every script guards its objects, so `RunAll` is idempotent and safe to re-run against an existing `FlatWireDB`. In SSMS use **Query → SQLCMD Mode** before executing `RunAll`.

### API contracts (`DevelopmentPlan/APIContracts.md`)

A single new `FlatWire` microservice for `ual-api`, base URL `/api/v1/flatwire`, thin controllers over MediatR commands/queries, extending `UA.Framework.API/UAController` for the standard `Data`/`Success`/`Errors` envelope. `FlatWireHub` is hosted **only** inside `FlatWire.API` — the shared `Notification` service is not extended, and existing hubs (`CoilDataHub`, `OPCManagerHub`, `supervisor-monitor-hub`) are **not** templates. The real-time design (WebSockets-first, MessagePack, strongly-typed `Hub<IFlatWireClient>`) is specified in `00-foundations.md` §0.4. Contracts are published as stubs so the shopfloor UI can build against dummy data first.

Note: `APIContracts.md` is April-dated and carries known correctness bugs catalogued in `REVIEW.md` Tier 1 (the `/passschedule/generate` worked example, a missing `CheckpointType` value, three edge-type vocabularies). Cross-check against `REVIEW.md` before implementing from it.

### Reference-code rules (`00-foundations.md` §0.2) — non-obvious and binding

- **Backend:** `API/Domain/CoilCheckin` is the **primary template** for the new service (controller, MediatR command, `Program.cs`, `.csproj`, NuGet set). `OPCConnection` is the PLC tag layer to integrate with. **`SlitterInterface` is explicitly NOT a reference** (neither UI nor hub pattern).
- **Frontend:** there is **no** Angular structural/UI template. `flat-wire-shopfloor` is all-new screens and controls built from `Mockups/`; `checkin-precheckin`, `shop-floor*`, `common-grid`, `wip-rejection`, `slitter-*` etc. are not to be copied. The only reuse is the foundational `shared` services (`api-gateway`, `app-config`, `login`, token/correlation interceptors, error handler, `ui-log`, `notification`, `subscription`, `print-export`, `util`). The library joins the `build:shop-floor` chain for **build ordering only** — that implies no code reuse.

### Mockups (`Mockups/`)

Static HTML prototypes of the 14+ operator dashboards — **open directly in a browser**, no build step. They are the approved visual baseline for the Angular library (prefix `fw`). Shared assets:

- `flat-wire-shopfloor.styles.scss` / `.css` — the semantic design tokens every dashboard uses (`--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono`). Edit the `.scss`; the `.css` is its compiled output. **The `--fw-*` token prefix appearing in older source docs is stale** — no mockup or stylesheet uses it (gap G18).
- `flat-wire-topbar.js` — injects the shared app bar (logo, environment/greeting, multi-operator sessions, Help/Refresh/Login/Switch/Logout) and the "More Options" tile popup. Include once before `</body>`; needs the stylesheet + `mainlogo.gif` in the same folder.
- `pause_run.js` — shared Pause/Resume modal for FL1/FL2 active-run screens; expects specific element IDs (`pause-btn`, `pause-timer-badge`, `footage-val`, `clock`) and hard-codes navigation to `dashboard_8_wip_rejection.html` / `dashboard_12_rod_checkout.html`.
- `flat-wire-fit.js` — scales a screen to the browser window so all of it is visible without fullscreen and without a scrollbar (a normal window offers only ~600–950px of height against the 1280×1024 authored size). Include once **after** `flat-wire-topbar.js`, which injects the app bar on `DOMContentLoaded` and changes the content height. It transforms `<body>` (not `.dashboard`) so body-level overlays scale too, and it never scales above 1:1 — on the real panel nothing is resized. All 25 screens use `data-fit="fill"`, which widens the design box to the window's full width as well; `data-fit="scale"` is a retained escape hatch that keeps the 1280px width and letterboxes instead. Design height is **measured**, not assumed — several screens legitimately need more than 1024px and were previously clipped. It also normalises SVG charts: `preserveAspectRatio="none"` charts stretch their plot geometry but their labels, live dots and `rect[rx]` chips are counter-scaled (via `--fw-unstretch` and `transform-box:fill-box`, so nothing breaks when page scripts move dots by setting `cy`), and chart labels are lifted toward the 14px floor (`--fw-textgrow`) up to the point where an axis column would collide.
- **Minimum text size is 14px** (`MIN_FONT` in `flat-wire-fit.js`). These are shopfloor screens read at arm's length; nothing below 14px. The shared stylesheet also pins `input, select, textarea, button, option` to 14px, since form controls do not inherit the body font and the browser default is 13.333px. The known exception is axis labels inside vertically compressed SVG charts (`dashboard_3_active_run` / `_v2`, `dashboard_13_hmi_schematic`, `dashboard_14_scada_trends`), where tick spacing cannot fit 14px without dropping ticks or making the charts taller — see gap register before "fixing" these by shrinking text elsewhere.
- Where several variants of one dashboard exist, the approved one is named in `00-foundations.md` decision 6 — notably **Dashboard 2 uses `dashboard_2_rod_checkin - New.html`** (guided 6-step tab wizard); the `- Old.html` inline-SVG-ring version is retired.

### Requirement documents

`BaseDocuments/` holds the business's source `.docx`/`.xlsx` inputs — treat as read-only evidence. `SRS/` holds the delivered consolidated SRS. The consolidated `.docx` was generated from a markdown master via Python helpers (`extract.py`, `assemble.py`, `build_docx.py`, `verify_docx.py`, `slim_docx.py` — see the allowlist in `.claude/settings.local.json`); those scripts and the markdown master are **not committed** and live in the session scratchpad, so a docx→markdown round-trip has to be re-established before editing SRS content that way. `~$…` / `~WRL####.tmp` files are Word lock/temp artifacts — ignore them.

## Conventions in This Repo

- Every planning/analysis doc carries a header block (**Project / Last Updated / Status**) and many end with a **Change Log** table. Update both when you materially change a doc. Phase files additionally carry `Layer`, `Due`, dependencies, and a "reference context (do not restate)" pointer — respect the do-not-restate rule instead of duplicating foundations text.
- Decisions are tracked in an open-questions register (`Analysis/FlatWireOpenQuestions.md`, ~59 items, authoritative). Resolved items are struck through with a **DECIDED (date)** note inline; **do not delete them** — the audit trail matters. Phases list their **OQ-## blockers**; unresolved gaps are **G1–G18** in `back-matter.md`.
- The repo has **split-brain by design**: four April 29–30 2026 docs (`APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`) were never reconciled with the July 26 rewrite. **The July 26 roadmap + `ShopfloorPlan/*` win**; when the two disagree, reconcile the April doc *up to* the roadmap rather than maintaining both.
- Field/column renames for flat wire follow a `Coil/Bundle…` slash-dual-naming pattern (e.g. `CoilNo` → `Coil/BundleNo`, `SlitWidth` → `Slit/FlatWidth`). New coil status is `INFLAT`; flattening operation letter is `F`. These renames (story FW-001) touch the **shared** `coils`/scheduling schema — high blast radius, front-load the impact audit.
- Backlog IDs are `FW-###` (12 epics / 58 stories) and map into phases via the roadmap tables.
- Dates in docs are US business dates in 2026; July 2026 entries are the current baseline, April–May 2026 entries are the earlier design pass.
