# Tools

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 14, 2026 — [`build_trial_run_xlsx.py`](build_trial_run_xlsx.py) and [`TrialRunContent.md`](TrialRunContent.md) added: the trial-run workbook, the first generator to write outside `MVP-1/SRS/` and the first with an **abbreviation** guard in place of a leakage guard *(otherwise August 13, 2026)*
**Status:** Working scripts, committed so they stop being re-derived

---

**Five scripts.** Four render a deliverable from markdown; one is a check that fails the build.
All five take the same position — **the markdown is the source and the generated file is
output** — so never edit a `.docx` or `.xlsx` in this repository.

| Script | Reads | Writes | Fails on |
|---|---|---|---|
| [`build_docx.py`](build_docx.py) | a spec in `MVP-1/ProjectPlan/Business/Screens/` | a branded `.docx` in `MVP-1/SRS/` | — |
| [`build_questions_xlsx.py`](build_questions_xlsx.py) | both `Analysis/` question registers + `ClientQuestionsContent.md` | `MVP-1/SRS/FlatWire_ClientQuestions.xlsx` | coverage · drift · team names · leakage |
| [`build_development_plan_xlsx.py`](build_development_plan_xlsx.py) | `Development/TaskBreakdown.md` + `Development/StaffedSprintPlans.md` + `DevelopmentPlanContent.md` | `MVP-1/SRS/FlatWire_DevelopmentPlan.xlsx` | coverage · drift · team names · leakage |
| [`build_trial_run_xlsx.py`](build_trial_run_xlsx.py) | `Development/TrialRunPlan.md` + `Development/TaskBreakdown.md` + `TrialRunContent.md` | **`Development/FlatWire_TrialRunPlan.xlsx`** | reconciliation · coverage · title · drift · **abbreviation** |
| [`build_coverage_matrix.py`](build_coverage_matrix.py) | `02-SRS.md` + `06-TestPlanAndTestCases.md` | nothing — reports | a requirement with no case and no §10.4 entry |

The three workbook builders share their helpers by **duplication, not import** — the style
palette, `render()`, `_fold_blank_runs()` and the guard lists are copied. That is deliberate:
each is a standalone deliverable generator that must keep building if another is edited, and a
shared module would make a change to one workbook's guard silently change the others'.

> **⚠ Only the trial-run workbook writes outside `MVP-1/SRS/`, and that is the whole point.**
> `MVP-1/SRS/` is where **leakage-guarded** client deliverables live. The trial-run workbook
> carries story identifiers, hours and gap identifiers by design, so it is **internal, shared
> with the client**, and lives in `Development/`. Moving it into `MVP-1/SRS/` would put an
> unguarded file among guarded ones.

---

## `build_docx.py` — markdown → branded `.docx`

Renders a client-facing specification from `MVP-1/ProjectPlan/Business/Screens/*.md` to a branded Word document in `MVP-1/SRS/`.

```bash
# Rebuild the PLC tag specification (the default)
python MVP-1/ProjectPlan/Tools/build_docx.py

# Any other spec
python MVP-1/ProjectPlan/Tools/build_docx.py \
  MVP-1/ProjectPlan/Business/Screens/SomeSpec.md \
  MVP-1/SRS/SomeSpec.docx \
  "Flat Wire - Some Spec"
```

**Requires** `python-docx` (tested against 1.2.0). No pandoc, no Word automation, no network.

### The markdown is the source; the `.docx` is output

Edit the `.md` and re-render. **Never edit the `.docx`** — the next render overwrites it.

### How the branding is inherited

Nothing is recreated. `MVP-2/SRS/PassScheduleGenerationSpec.docx` is opened as a template and its body is stripped, **keeping only the final `<w:sectPr>`** — which is the element that carries `headerReference` and `footerReference`. The output therefore inherits, byte for byte:

- the header logo and the header title line (the title is then replaced with the one passed in),
- the *United Aluminum Confidential / Copyright* footer and its page-number fields,
- the page setup — 8.5 × 11 at 0.6″ margins,
- the full paragraph, character and table style set.

This is why there is no logo file, no style definition and no page-setup code in the script.

### What it handles

Headings — the first `#` becomes a centred title page · tables, with a shaded header row that repeats across page breaks · blockquotes as shaded callouts with a left rule · fenced code in monospace · **```mermaid fences as drawn flowcharts** · ordered and unordered lists · `**Key:** value` metadata lines kept on their own lines · inline **bold**, *italic*, ~~strike~~, `code` and links.

### Flowcharts — boxes and lines out of table cells

A ```` ```mermaid ```` fence is a **diagram**, and printing its source into a client deliverable asks the reader to compile it in their head. It is drawn instead — boxes joined by lines — using nothing but table cells:

| Element | How it is drawn |
|---|---|
| Box | A merged cell: shading fills it, a hairline border outlines it |
| Line | The connector row between two ranks, carrying `│` and the `▼` arrowhead |
| Branch | A rank with two or more boxes places them side by side, each under its own labelled arrow |
| Process / decision / terminal | Blue `D9E2F3` · amber `FFF2CC`, bold · grey `E2E2E2` |

Nodes are ranked by **longest path**, so each rank becomes a row. Back edges are found by a DFS colouring first, or the ranking walk would not terminate.

**An edge that skips ranks or loops back cannot be drawn as a line down the page**, so it is *named* rather than approximated — `▲ No — re-solve back to: Steps 9, 9A and 9B`. Where two such spans overlap they are unioned into one cell; merging them separately would swallow the first and collapse the row. When a union puts two arrows in one cell, each names its target, since `Yes` and `No` alone no longer say which box they drop into.

Only the subset the specs use is parsed — `flowchart TD`, `ID["box"]`, `ID{"decision"}`, `A -- label --> B`. Anything else is ignored rather than guessed at, so **if a chart stops rendering, check the fence against that list first**.

> **Why not an image?** Nothing in this environment can rasterise one — no mermaid CLI, no graphviz, no matplotlib, no PIL. Drawing with Word shapes over COM was tried and rejected: it needs Word on the build machine, which would break this script's one real promise. Table cells cost nothing, render identically in Word, LibreOffice and PDF, and leave the text selectable and searchable.

**The inline parser recurses**, so nested constructs such as ``**`PLC-Q02`**`` or `~~**FR-111**~~` resolve to a single correctly-styled run instead of leaking their delimiters. That bug shipped once and was caught in review; the recursion is the fix.

A **TOC field** is inserted after the title. Word populates it on **Update Field** (right-click, or Ctrl+A then F9) — it is deliberately a field rather than baked text so it survives edits.

### Gotcha

If the target `.docx` is open in Word the write fails:

```
PermissionError: [Errno 13] Permission denied: ...\SRS\PLCTagSpecification.docx
```

A `~$…​.docx` lock file in `MVP-1/SRS/` is the tell. Close the document and re-run.

### Verifying a render

Worth doing on a client deliverable — a silent formatting failure looks like prose:

```python
import docx
d = docx.Document('MVP-1/SRS/PLCTagSpecification.docx')
txt = '\n'.join(p.text for p in d.paragraphs)
for t in d.tables:
    for r in t.rows:
        for c in r.cells:
            txt += '\n' + c.text

assert txt.count('`') == 0 and txt.count('**') == 0 and txt.count('~~') == 0   # no leakage
print(len(d.tables), 'tables')          # must match the source
print(txt.count('☐'), 'checkboxes')     # sign-off sheet intact
```

---

## `build_questions_xlsx.py` — the client questions workbook

```bash
python MVP-1/ProjectPlan/Tools/build_questions_xlsx.py            # → MVP-1/SRS/FlatWire_ClientQuestions.xlsx
python MVP-1/ProjectPlan/Tools/build_questions_xlsx.py other.xlsx
```

**Requires** `openpyxl` (tested against 3.1.5).

United Aluminum owes answers on the open questions and confirmation of the decided ones.
Both registers under `Analysis/` are written for the build team and are dense with table
names, constraint names, endpoints and requirement identifiers — **none of which may appear
in a client deliverable**. So the workbook is merged from two sources:

- **Structure** — question number, priority, scope, owner, decided date — is parsed from the
  registers' index tables, so it cannot drift from them.
- **Prose** — the plain-language question, background, options, recommendation — comes from
  [`ClientQuestionsContent.md`](ClientQuestionsContent.md), which is the only place it is
  authored.

### Four guards, all fatal

| Guard | Catches |
|---|---|
| **Coverage** | A question in a register with no content entry, or the reverse |
| **Drift** | The content entry's recorded register title no longer matches the register — i.e. a renumbering silently moved prose onto the wrong question |
| **Team names** | A Nagarro-side name left in *Needs input from*, which names client stakeholders only |
| **Leakage** | Any file name, path, requirement/gap/test id, table name, endpoint, code span or machine tag path reaching a cell of the built workbook |

> **`Recommended answer` and `Why` are optional, and only for one reason.** A question may
> deliberately go to the client with no vendor answer attached — `Q10` (footage-to-weight) is
> the first, because the dimensional basis is a measurement UA must answer from its own
> practice. `Why` exists to justify a recommendation, so a question carrying none has nothing
> for it to say (`Q4`, skid labelling). **Do not add either to `REQUIRED_OPEN`.**

Same gotcha as `build_docx.py`: a `~$…` lock file in `MVP-1/SRS/` means the workbook is open
in Excel and the write will fail.

---

## `build_development_plan_xlsx.py` — the client development plan workbook

```bash
python MVP-1/ProjectPlan/Tools/build_development_plan_xlsx.py     # → MVP-1/SRS/FlatWire_DevelopmentPlan.xlsx
python MVP-1/ProjectPlan/Tools/build_development_plan_xlsx.py other.xlsx
```

**Requires** `openpyxl` (tested against 3.1.5).

Seven sheets — *Read Me · Delivery Options · Plan by Stage · Sprint Schedule · Work Items ·
Milestones and Needs · Assumptions and Risks*. Same two-source construction as the questions
workbook:

- **Structure** — effort, phase, discipline, sprint, dates, working days, utilisation, finish
  dates — is parsed from [`../Development/TaskBreakdown.md`](../Development/TaskBreakdown.md)
  and [`../Development/StaffedSprintPlans.md`](../Development/StaffedSprintPlans.md), so it
  cannot drift from the plan. Change the plan and re-run; the numbers follow.
- **Prose** — stage and work-item names, what each delivers, who it serves, the levers,
  milestones, dependencies, assumptions and risks — comes from
  [`DevelopmentPlanContent.md`](DevelopmentPlanContent.md), the only place it is authored.

### Why the prose had to be written rather than filtered

**68 of the plan's 116 work-item titles trip the leakage guard** — 40 carry code spans, 11 name
endpoints, 10 use screen numbers, 7 name database tables. A client sentence cannot be produced
by deleting those; it has to be about the business outcome instead. The raw material is each
story's `So that` clause, **only 4 of which trip the guard** — those are already client
language, and every *Delivers* line is built from one.

### Two numbers it deliberately does not carry

- **Effort is in days, never hours.** Hours invite a rate conversation; days are the planning
  unit. The conversion is at write time, 8 h/day.
- **The unit rate card is never exported.** Per-stage and per-item totals are fine; *what a
  screen costs* is internal pricing mechanics.

### Guards

The same four as the questions workbook, with coverage and drift checked against the plan's
work items and phases rather than a question register. Two additions to `LEAKS`, both for
things most likely to survive a careless edit of the content file: **library names**
(`MediatR`, `Dapper`, `SignalR`…) and **code identifiers** — anything ending `Service`,
`Controller`, `Repository`, `Component`, `Hub`, `Dto` or `Handler`. Bare `Angular`, `.NET` and
`SQL` are **not** blocked: they name the technology, which the client already knows and may
legitimately ask about.

> **`Reference title` is a mirror of the plan's own title, not authored prose.** It exists only
> so the drift guard can tell that a renumbering has not slid prose onto a different work item.
> **Do not paraphrase it** — copy the plan's title verbatim, or the guard is checking nothing.
> It is never written to the workbook.

### Verifying it

The build deletes its own output and exits non-zero on any guard failure, so **a workbook on
disk means all four passed**. To confirm the leakage guard is live rather than merely present,
paste a file name and a backlog identifier into two content entries and re-run: it must name
both with sheet and cell coordinates and leave no `.xlsx` behind.

---

## `build_trial_run_xlsx.py` — the trial run workbook

```bash
python MVP-1/ProjectPlan/Tools/build_trial_run_xlsx.py   # → Development/FlatWire_TrialRunPlan.xlsx
python MVP-1/ProjectPlan/Tools/build_trial_run_xlsx.py other.xlsx
```

**Requires** `openpyxl` (tested against 3.1.5).

Ten sheets — *Read Me · Effort Summary · Effort by Phase and Discipline · Platform Detail ·
Work Items · Sprint Plan · Sprint Allocation · Blockers · Deferred Items · Removal Impact* —
covering the **61 work items / 778 hours** of the six-screen trial run. Same two-source
construction as the other two workbooks:

- **Structure** — every figure, story identifier, sprint, date, phase and blocker — is parsed
  from [`../Development/TrialRunPlan.md`](../Development/TrialRunPlan.md), so it cannot drift.
  Titles come from [`../Development/TaskBreakdown.md`](../Development/TaskBreakdown.md), which
  is the title source rather than `StaffedSprintPlans.md` because that document predates
  `FW-202`/`FW-203`/`FW-204` and does not carry them.
- **Prose** — the plain-language *what it delivers* per item, the Read Me and the blocker
  phrasing — comes from [`TrialRunContent.md`](TrialRunContent.md), the only place it is
  authored.

### Three deliberate departures from the development plan workbook

Each is a recorded decision, and the script's header repeats them so none is "fixed" back.

| | That workbook | This one |
|---|---|---|
| **Story identifiers** | `FW-\d` is in its fatal `LEAKS` list; rows are numbered `1..N` | **Present** — the client asked to be able to refer to a task by its identifier. There is therefore **no leakage guard** |
| **Effort unit** | Days only — *"hours invite a rate conversation"* | **Hours**, because the plan is in hours and the audience is internal. A `Days` column is derived at 8 h/day |
| **The "must not say that" guard** | Leakage | **Abbreviation** — no bare shorthand may reach a cell |

### Why the abbreviation guard exists

The plan writes `FE`, `BE`, `DB`, `RT`, `T1`, `1A`, `DB5`, `FL2` freely, because it is read as
prose. **A filtered spreadsheet column has no surrounding sentence**, and one of those is
actively ambiguous: **`DB` is both the Database discipline and the Dashboard prefix.** So a
`LABELS` map expands every abbreviation at write time and a guard refuses the build if any bare
one survives.

Two things make the expansion safe, and neither should be simplified away:

1. **Single pass.** All keys go into one alternation, longest first, so each position is
   consumed once. Looping the keys would let one replacement's output be re-matched by a later
   key.
2. **No replacement contains its own key**, which is what makes `expand()` idempotent. This is
   why phrase entries exist — `1A` alone cannot expand to *"Phase 1A — …"* without re-matching
   itself.

**The guard's token set is deliberately wider than `LABELS`.** `EF`, `DI`, `PWA` and `JWT`
appear in it but only inside *phrases* in the expander, so a bare one in newly authored prose
is **flagged** rather than silently expanded into something clumsy. `Phase 1A` and `Sprint 1`
are exempt — they are identifiers, not shorthand — and code identifiers are never touched,
because `\bPLC\b` does not match `PLCTagService`.

### Five guards, all fatal — and all five verified live

The build deletes its own output and exits non-zero on any failure, so **a workbook on disk
means all five passed.** Each was proved by breaking it deliberately:

| Guard | Broken by | Reported |
|---|---|---|
| **Reconciliation** | changing one hours cell in the plan's block table | `block table: computed 779, the plan prints 778` |
| **Coverage** | deleting a content entry | `FW-133 is in the plan with no content entry` |
| **Title** | renumbering a story heading in the backlog | `FW-133 has no title in the backlog — never blank-fill an identifier` |
| **Drift** | paraphrasing a `Reference title` | `FW-133 drift: content says …, the backlog says …` |
| **Abbreviation** | injecting a bare `JWT` and `DI` into a content entry | both named with sheet and cell |

> **Do not "fix" the reconciliation guard by editing a footer row.** The tables' footer rows are
> excluded from their own sums on purpose — counting them double-counts the total. Change a data
> row to test it.

Same gotcha as the others: a `~$…` lock file next to the output means the workbook is open in
Excel and the write will fail.

---

## `build_coverage_matrix.py` — does every requirement reach a test case?

```bash
python MVP-1/ProjectPlan/Tools/build_coverage_matrix.py           # check; exit 1 on a hole
python MVP-1/ProjectPlan/Tools/build_coverage_matrix.py --emit    # also print the per-FR table
```

**Requires** nothing — standard library only. **Run it after editing either `02-SRS.md` or
`06-TestPlanAndTestCases.md`.**

### Why it exists

`06-TestPlanAndTestCases.md` §10.1 used to map SRS **section ranges** to TC ranges
(`FR-100 – FR-120 → TC-130 – TC-147`) and a coverage percentage was concluded from it. A
range mapping cannot show that an *individual* requirement was tested. When coverage was
first measured per requirement on 13 Aug 2026, **41 had no case at all — 32 of them `Must`**,
and the published figure was 96.7 %. Nothing contradicted it because the figure came from
the range table, not from the cases. Gap **`G25`**.

### What counts as covered, in precedence order

1. **Direct** — a §5 case names the requirement in its *FR / Source* column. **That column,
   not the whole row**: a requirement mentioned in an expected result is discussed, not proven.
2. **Indirect** — the SRS non-functional table names both the requirement and a `TC-###`.
   `FR-018` (recording cadence) is proven this way by `TC-601`–`TC-603`.
3. **Declared** — §10.4 records it as knowingly not covered, with a reason. **A declared hole
   is a decision; an undeclared one is an accident**, and only the second kind fails the script.

### Scope

`02-SRS.md` carries MVP-1 requirements only — §5.10, §5.18, §5.19, §5.23 and §5.24 left with
the 11 Aug 2026 MVP-2 split and §5.21/§5.22 were withdrawn with the DB13/DB14 descope — so
those rows are simply absent and need no range filter. Requirements struck through as
`~~**FR-###**~~` are individually withdrawn and are not counted; **`FR-111` is one, and
counting it is how a false positive enters.**

> **Known limitation — do not "fix" by guessing.** `05-SprintPlanAndBacklog.md` §11
> (*"every `FR-###` reaches a story"*) has the same range granularity the old §10.1 had, but
> unlike the test plan it holds **no per-requirement data to check against** — stories are
> assigned to ranges, never to single requirements. Making it per-requirement means authoring
> ~263 story assignments, which is a decision for the backlog owner. The script reports it as
> an advisory count and it **never affects the exit status**.
