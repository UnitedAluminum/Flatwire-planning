# CLAUDE.md

Guidance for Claude Code working in the Flat Wire Mill planning repository.

**Start at [`README.md`](README.md)** for the entry point and the developer loop, and
[`DOCUMENTS.md`](DOCUMENTS.md) for the document map and shortcode table. This file carries only
what those two cannot: the domain traps and the binding rules that are **not obvious from the
files themselves**.

> **This file was 71 KB before the 29 Aug 2026 restructure**, almost all of it disambiguating a
> structure that could not explain itself — which of four sprint plans wins, why `MVP-2/` did not
> mirror `MVP-1/`, which of six PLC tag copies was real. Those are gone because the structure
> fixed them. The full pre-restructure text is preserved at
> [`95-archive/design-notes/CLAUDE-pre-restructure.md`](95-archive/design-notes/CLAUDE-pre-restructure.md);
> read it for the history of a decision, never as current guidance.

---

## What this repository is

Planning, requirements and design for the **Flat Wire Mill module**. **No shippable code.** The
implementation lands in **`../ual-api`** (the `FlatWire` microservice, Clean Architecture) and
**`../ual-angular`** (the `flat-wire` library). Ecosystem-wide stack conventions are in
**`../CLAUDE.md`** at `c:\UAL`.

When asked to "implement" a feature, the code goes in those repos, using this repo as the spec.

---

## The tree

```
00-overview/     10-requirements/   20-architecture/   30-database/
40-backend/      50-frontend/       60-delivery/       70-testing/
80-operations/   90-registers/      95-archive/        tools/  deliverables/
```

**Subject is the folder. MVP, phase, stream, status and owner are *fields*, not paths.** That is
the rule that stops scope changes moving files — under the old shape Phase 9 and the three
`PassSchedule*` tables each moved between `MVP-1/` and `MVP-2/` and back.

- **A task is one file**: `{30,40,50,60,70}-*/tasks/FW-###.md`, front-matter above the `---`,
  the developer's plan below.
- **[`STATUS.md`](STATUS.md) is generated.** Never edit it. Change the task file, run
  `python tools/build_status.py`.
- **`95-archive/` is not citable.** Nothing there is a requirement, ever.

---

## Domain in one screen

Three new **Flattening Lines** convert aluminium rod into coreless oscillated flat wire coils.

- **FL1** (standalone): rod → wire drawing (DB1/DB2) → 12″ mill FM1 → intermediate spool. Gauge
  trace is **real-time**. FL1 has **no edger**.
- **FL2** (standalone): pre-flattened spool → finishing mill FM2 → coreless coil. Gauge trace is
  **historical/profile** — FL2 broadcasts `null` live gauge/width.
- **FL3** (hybrid): FL1 feeding FL2 continuously, no intermediate anneal. Real-time. Same FM2.

**⚠ FM2 has THREE stands, and the four-stand model is retired (`D-26`, 4 Aug 2026).** Component
ids are **position-only** — `FM2_S1` / `FM2_S2` / `FM2_S3` — and roll diameter is **data**, in
`Stand.RollDiameterIn` (FM1 12.000; FM2 8.000 / 6.000 / 6.000). **The 8″ roller *is* S1.** Edgers
at S2 and S3 only; **S3 is final and non-bypassable**. Old → new: `FM2_8in`→`FM2_S1`,
`FM2_6inS1`→`FM2_S2`, `FM2_6inS2`→`FM2_S3`; **`FM2_6inS3` never existed**. Anything showing four
FM2 stands, a separate `8" Roller`, or a 6″ stand named S1 is stale.

**⚠ `Spool` and `SpoolProcessing` were SWAPPED on 23 Aug 2026 (`Q60`) — the one rename where a
stale reference is *silently wrong* rather than obviously stale.**

| Table | Is | Key |
|---|---|---|
| **`Spool`** | the reusable stencilled **article** (a lookup) | `SpoolNo` — **has no `Alpha` at all** |
| **`SpoolProcessing`** | the **material in process** | `Alpha` = `SP-#####` |

A pre-23-Aug document saying `Spool.Alpha` means what is now `SpoolProcessing.Alpha`.
`SpoolConfiguration` was merged away the same day and is no longer a table. Out of scope
deliberately: the API surface (`GET /spools`), the code identifiers, screen labels and the
`SP-#####` format — operators say "spool".

**Alpha formats.** Rod `R#####` · Spool `SP-#####` · Run `RUN-####` · Pass schedule
`PS-{alloy}-{line}-{seq}` · **Output coil `FW-#####-C##`** (mid-run child `…-A`) · Die
`D-{size×1000}-{seq}`.

> **⚠ `FW-#####-C##` is a coil alpha, not a story id.** There are 299 of them. Any bulk rewrite of
> `FW-` ids must exclude them — `\bFW-(\d{3}|N\d{2})(?![\dA-Za-z-])` — or it silently corrupts
> domain data. `tools/fix_task_links.py` carries the guard and a pre/post count assertion.

**Terminology:** always "flat wire", never "strip". The traveler is **fully digital** (no
printing; coil/skid labels are still printed).

Other recurring concepts: the **Pass Schedule** (the master configuration record — check-in
acknowledges it and that acknowledgement is what pushes PLC tags; **MVP-1 reads one and never
authors one**) · **`FlatWireRun`** (the central run header) · **weld traceability** (induction
welds; `CoilTraceability` is the genealogy behind the welding-wire customer certificates) ·
**SPC checkpoints** (incoming rod, post-die-change, FM1 output, FM2 S3 output).

---

## Binding rules

**⚠ There is no shared-schema migration — `D-32`, 18 Aug 2026.** The existing `coils` / scheduling
schema is **read and written as it stands and never altered**. `FW-001` and `FW-002` are cancelled.
`INFLAT` is a **`FlatWireDB`-local** status value and never enters the shared vocabulary. The
flattening operation letter `F`, the FL1/FL2/FL3 `machines` rows and the `CommonDB` WIP-station
registration all still stand. Anything describing the `Coil/Bundle…` renames, a shared `INFLAT`
status or the 40 h impact audit as work to be done is stale.

**Reference code** (`20-architecture/Architecture.md` §2.2):
- **Backend:** `API/Domain/CoilCheckin` is the **primary template**. `OPCConnection` is the PLC tag
  layer to integrate with. **`SlitterInterface` is explicitly NOT a reference.**
- **Frontend:** there is **no** Angular structural template. `flat-wire` is all-new screens built
  from the mockups. The only reuse is the foundational `shared` services (`api-gateway`,
  `app-config`, `login`, interceptors, `notification`, `print-export`, `util`).

**The PLC tag surface has exactly one home.** `20-architecture/PLCTagSpecification.md` `[PLC]` owns
**every tag path string**; `PLCCommunication.md` `[PLCC]` is internal and contains **none**. If you
are about to write a tag path anywhere else, don't. `[PLC]` is v1.0 with no `[CONFIRMED]` tag by
design — a path becomes confirmed when commissioning test `C1`/`C11` says the controller accepted it.

---

## Database

Target is a **new standalone `FlatWireDB`**, not `united_db`. Design lives in three forms that must
stay in sync: `30-database/DatabaseDesign.md` `[DBD]` (read §6 and §7 first — the **as-built**
description, and `[DBD §6.2]` is the **only** site that states the object counts),
`30-database/schema/` (six per-domain docs) and `30-database/sql/` (**authoritative for types,
nullability and constraints — never regenerate it from the markdown**).

DDL files are **numbered by execution order**: `00` database → `01` Lookup → `02` Schedule →
`03` Materials → `04` Runs → `05` Quality/Output → `06` **all FKs** → `07` Indexes →
`08` Programmability. `99` is teardown. Put new FKs in `06`.

> ⚠ **Deploy to the SHARED instance, not LocalDB.** `FlatWireDB` must sit alongside `united_db` /
> `proddb` / `CommonDB`, because check-in spans them in **one** `SqlTransaction` under the local
> transaction manager with no MSDTC (`[INT §8.0]`, `[ARC §10]`). LocalDB has no `united_db`, so a
> build validated only there silently loses atomicity. **The instance is `DEV00164-001`** — it is
> where that atomicity was actually proven (`is_local = 1`, `is_enlisted = 0`, 26 Aug 2026), and it
> is `[DEP §2]`'s database server for `test1`. ⚠ **`DEVUAL-UADEV001\TEST1` is retired for
> `FlatWireDB`** — anything describing its pre-`Q60`, unseeded copy as a rebuild that is *owed*
> describes an abandoned instance.

```powershell
cd "c:\UAL\Flatwire-planning\30-database\sql"
sqlcmd -S "DEV00164-001" -E -C -i FlatWire_DDL_RunAll.sql            # SQLCMD mode required (:r)
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql           # drop everything
```

Every script guards its objects, so `RunAll` is idempotent. In SSMS use **Query → SQLCMD Mode**.

---

## Mockups (`50-frontend/mockups/`)

Static HTML, **open directly in a browser**, no build step. The approved visual baseline for the
Angular library (prefix `fw`).

- `flat-wire-shopfloor.styles.scss` / `.css` — the semantic design tokens. Edit the `.scss`; the
  `.css` is compiled output. **The `--fw-*` token prefix in older docs is stale** (gap `G18`).
- `fw-modal.js` — **the shared dialog runtime; load it before any script that opens a popup.**
- **No dialog scrolls — oversized dialogs are scaled to fit.** `.gb-modal` therefore carries *no*
  `max-height` and `.gb-modal-body` is `overflow: visible`; adding either back re-introduces the
  scrollbar the fit exists to remove.
- **Never stack dialogs** — close the current one, then open the next. Two live focus traps leave
  the operator unable to reach either.
- **Minimum text size is 14 px.** These are read at arm's length. The known exception is axis
  labels inside vertically compressed SVG charts.
- `die_change.js` · `spc_checkpoint.js` · `wip_rejection.js` · `rod_checkout.js` are **the four
  run-event dialogs**; their `dashboard_*.html` files are thin launchers. **Do not edit a launcher
  to change a screen — edit the `.js`.**
- **Button-icon rule:** the **action** button in a dialog footer carries an icon; the **dismiss**
  button does not.

---

## Conventions

- **A fact is asserted in one document and cited everywhere else.** Typing a number another
  document owns creates the next contradiction — cite `[CE §3]` or `[DBD §6.2]`.
- **One change log:** [`CHANGELOG.md`](CHANGELOG.md). Never add a `## Change Log` to a document.
  Update the document's `Last Updated` header and append a row there.
- **Cite by shortcode**, declared in each header — `[REQ]` `[BR]` `[ARC]` `[SIG]` `[DBD]` `[API]`
  `[TB]` `[CE]` `[GAP]`. Shortcodes survive a move; paths do not. Full table in `DOCUMENTS.md`.
- **Section numbers are non-contiguous by design.** `BusinessRequirements.md` opens at §5 and
  `DatabaseDesign.md` numbers the data model §6 because they were split out of documents where
  those were the numbers. **Never renumber a section to close a gap** — it breaks every `§n` citation.
- **Register ids are never renumbered** — `FR-`, `Q`, `OI-`, `G`, `TC-`, `D-`, `PLC-Q`. A decided
  question keeps its full text and is never deleted.
- **`FW-###` is the exception**: a working id that will be **replaced** by the real JIRA id in one
  scripted pass, driven by [`90-registers/TaskIdMap.md`](90-registers/TaskIdMap.md). ⚠ The map is
  **many-to-one today** (one epic covers eight stories), which is what currently blocks that swap.
- **Dates are US business dates in 2026.** Development window **17 Aug → 30 Sep 2026**; UAT late
  Sep; production Q4. April–May entries are the earlier design pass. Stay within the existing UAL
  stack — no new frameworks.

---

## Before you finish

```bash
python tools/build_status.py     # regenerate STATUS.md
python tools/check_docs.py       # task <-> phase <-> register integrity
python tools/linkcheck.py        # no path reference broke
```

`tools/hooks/pre-commit` runs the first two automatically once installed. See
[`tools/README.md`](tools/README.md) — including the **cp1252 heredoc trap**, which silently
empties a regex containing the registers' `·` separator.
