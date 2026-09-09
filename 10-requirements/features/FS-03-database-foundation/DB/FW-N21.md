---
id: FW-N21
legacy_id:
title: SpoolConfiguration split back out of Spool
status: done
status_confirmed: true
status_note: "✅ **Done, 8 Sep 2026 (`D-58`), and it SUPERSEDES `Q60`'s merge.** `SpoolConfiguration` is a table again: the six limit columns and `SizeClass` leave `Spool`, which drops to five columns and a `SpoolTypeId` FK. ⭐ **The three band CHECKs get simpler** — the columns are `NOT NULL` again, so the all-or-nothing `IS NULL` clauses the merge forced are gone and they reduce to `Min < Max`; `UQ_SpoolConfig_Name` returns with the table. ⛔ **The trigger `Q60` named for undoing itself has NOT fired**: the client's 20 Aug *\"all one standard size\"* stands unsuperseded, and TKUP-1's 3,500 lb vs TKUP-2's 1,100 lb are **machine positions**, not article sizes — FL2's output is a **coreless** coil on no article at all. The split is on **normalisation grounds and direction**, and `D-58` says so. `IsDefault` + `UX_SpoolConfiguration_Default` replace the *\"any active `Spool` row's limits\"* fallback that splitting is precisely what breaks. Counts **46/68/89 → 47/69/91** with `FW-N20`, verified. ⚠ **Zero code cost** — the article is not modelled in C# at all; one comment re-pointed."
owner:
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB]
priority: medium
hours: 4
sprint: S0
depends_on: []
blocked_by: []
has_plan: true
started: 2026-09-08
completed: 2026-09-08
---

# FW-N21 · `SpoolConfiguration` split back out of `Spool`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 8, 2026
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ Done
**Owner:** Database
**Shortcode:** — *(implementation plan; **not citable as a requirement**)*

---

## 1. Why — and the honest version of why

`Spool` carried a **size class** it did not own: `SizeClass` plus six `Min`/`Max` limit columns,
repeated **byte-identically across all 45 seeded articles**. Those columns arrived on 23 Aug 2026
when `Q60` merged `SpoolConfiguration` away, on the grounds that a one-row size class against 30–45
articles was not worth a table. **That reasoning was sound and the merge is not being called a
mistake.**

⛔ **But the merge named its own reversal condition, and it has NOT fired.** `Spool`'s header read:

> *"THE TRADE, stated because it is real. This DENORMALISES … It is worth it only while 'every article
> is one size' holds. **IF THE CLIENT CONFIRMS A SECOND SIZE, revisit the merge** — the fallback below
> stops being well-defined at exactly that moment."*

What the record actually contains:

- **Client, 20 Aug 2026:** *"30 purchased with 15 more under consideration, **all one standard
  size**."* Nothing since supersedes it.
- ⚠ **TKUP-1's 3,500 lb and TKUP-2's 1,100 lb are machine positions, not article sizes** — and **FL2's
  output is a *coreless* oscillated coil**, wound on no reusable article at all. They are not evidence
  of a second `Spool` size.

✅ **The split is defensible on normalisation grounds regardless** — eight values across 45 rows, a
second size costing an `UPDATE` of many rows where the split shape needs one `INSERT`, and a
size-class name that lost `UQ_SpoolConfig_Name` the moment it moved onto `Spool`. **`D-58` records it
as normalisation plus direction.** ⛔ **Do not record it as a client change.**

## 2. What was built

| Where | Change |
|---|---|
| `../../../../30-database/sql/FlatWire_DDL_01_Lookup.sql` | **`SpoolConfiguration` created** immediately before `Spool`: `Name` (unique), the six limits **`NOT NULL`**, `IsDefault`, `IsActive`, and `CK_SpoolConfig_Weight`/`CoreDiam`/`OuterDiam`. `Spool` reduced to `Id`, `SpoolNo`, **`SpoolTypeId`**, `IsActive`, `Notes`. Header table count **18 → 19** |
| `FlatWire_DDL_06_ForeignKeys.sql` | **`FK_Spool_SpoolConfiguration` restored.** ⛔ `FK_SpoolProcessing_SpoolConfiguration` deliberately **not** — see §4. `SpoolConfiguration` added to the commented bulk-drop roster |
| `FlatWire_DDL_07_Indexes.sql` | **`UX_SpoolConfiguration_Default`** — unique on `IsDefault` where `IsDefault = 1` |
| `FlatWire_SampleData_Lookup.sql` | **One** `SpoolConfiguration` row; the `Spool` insert loses its eight literals and points at it. ⛔ The `'SP-' + RIGHT(...)` format expression is **kept** — `Q42` is open, and answering it must stay a one-line change |
| `FlatWireSchema_Lookup.md`, `[DBD §6.2]`/`§7`, `Mapping.md`, `[DEP]`, `phase-01c` | New table documented in all five `C2` placements; counts swept |
| `HubContracts.cs:231` | The one code touch in the whole story — a **comment**, re-pointed from `Spool` to `SpoolConfiguration` |

⭐ **The three CHECKs are simpler than they were, and that is a real gain.** On `Spool` the limits had
to be nullable, so each carried an all-or-nothing `IS NULL` clause — the merge's own words: *"a CHECK
accepts UNKNOWN, so a half-populated band would be admitted"*. Here they are `NOT NULL` and the
constraints say `Min < Max`, which is what they were always meant to say.

## 3. The split breaks a documented fallback, so it replaces it

`SpoolProcessing.SpoolId` is **nullable by design** (`Q42` open, nothing seeds articles in
production), so a material row may have no article and therefore no limits to validate against.
`Q60`'s answer was:

> *"The documented fallback is **ANY ACTIVE `Spool` ROW'S LIMITS** — well-defined precisely because all
> articles are one size."*

**Splitting the size class out is exactly what stops that being true.** So `SpoolConfiguration` carries
`IsDefault`, and `UX_SpoolConfiguration_Default` — filtered unique — makes *exactly one* row the
default at any number of configurations.

*The alternative, considered and not taken:* drop the fallback and **refuse to validate** when the
article is unknown. Arguably more honest, but it changes behaviour from *"validate against borrowed
limits"* to *"skip validation"*, which is a decision rather than a tidy-up.

## 4. Two things deliberately not done

⛔ **`SpoolProcessing.SpoolTypeId` and its FK are NOT restored.** `Q60` dropped **two** FKs; only one
returns. A material row reaches its configuration through `SpoolProcessing.SpoolId` →
`Spool.SpoolTypeId`, and a second direct path to the same fact is how the two come to disagree.

⛔ **No second size class is seeded.** The split restores the *ability* to hold one cheaply. Inventing
a row the client has not described would be exactly the thing §1 refuses to do.

## 5. Still open

- ⚠ **`Q42`** — the spool-number format and 30-vs-45 — untouched and still open. The seed keeps its
  one-expression format so answering it remains a one-line change.
- ⚠ **The merge's audit trail is kept, not rewritten.** `Mapping.md`'s *"merged into `Spool`"* section
  keeps its text and gains a superseding note; `Q60` keeps its full text, per the register convention
  that a decided question is never edited.
- ⚠ **Unverified against a server** — teardown-and-deploy on `DEV00164-001` is owed. ⛔ `47` is now the
  **correct** V1 answer; `[DEP §4.2]`'s old *"47 means `Edger` survived"* diagnostic is retired and
  `46` now means this story did not land.

---

## ✅ Deployed and verified — 8 September 2026

Teardown-and-rebuild on **`DEV00164-001`**: `99_Teardown` → `RunAll` → `RunAll` → `SampleData_RunAll`
→ `RunAll_MVP2` → `FlatWire_Scripts_RunAll`.

- **`V1` 47 · `V2` 69 · `V3` 91 · `V5` 0** — all exactly as `[DEP §4.2]` writes them. `V4` is 7 once
  MVP-2's `sp_ShiftSummary` is excluded, which is what that gate says to expect.
- **Idempotent** — the second `RunAll` created nothing.
- ⭐ **`RunAll` did not abort at script 06.** *“All FK constraints added successfully”*, then 07 and 08
  ran. The note claiming an abort there was stale.
- ⚠ **The `06` abort risk this story could have introduced was caught before deploy:** both new FKs are
  now guarded on `sys.columns`, so an incremental re-run against a pre-8-Sep database **skips and
  prints why** instead of failing on `Msg 1911` and killing 07/08.
