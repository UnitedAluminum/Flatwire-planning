# Tools

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 6, 2026
**Status:** Working scripts, committed so they stop being re-derived

---

## `build_docx.py` — markdown → branded `.docx`

Renders a client-facing specification from `LatestDocument/RequirementDocuments/*.md` to a branded Word document in `SRS/`.

```bash
# Rebuild the PLC tag specification (the default)
python DevelopmentPlan/Tools/build_docx.py

# Any other spec
python DevelopmentPlan/Tools/build_docx.py \
  LatestDocument/RequirementDocuments/SomeSpec.md \
  SRS/SomeSpec.docx \
  "Flat Wire - Some Spec"
```

**Requires** `python-docx` (tested against 1.2.0). No pandoc, no Word automation, no network.

### The markdown is the source; the `.docx` is output

Edit the `.md` and re-render. **Never edit the `.docx`** — the next render overwrites it.

### How the branding is inherited

Nothing is recreated. `SRS/PassScheduleGenerationSpec.docx` is opened as a template and its body is stripped, **keeping only the final `<w:sectPr>`** — which is the element that carries `headerReference` and `footerReference`. The output therefore inherits, byte for byte:

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

A `~$…​.docx` lock file in `SRS/` is the tell. Close the document and re-run.

### Verifying a render

Worth doing on a client deliverable — a silent formatting failure looks like prose:

```python
import docx
d = docx.Document('SRS/PLCTagSpecification.docx')
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

## Change Log

| Date | Change |
|---|---|
| Aug 6, 2026 | **Flowcharts, and two smaller fixes.** ```` ```mermaid ```` fences were rendering as **source** in the client deliverable — `PassScheduleGenerationSpec.md` has two, §6.1's thirteen-step calculation sequence and §6.2's route tree, and both reached the client as raw mermaid text. They are now **drawn as boxes and lines** out of table cells (see above). Also: **HTML comments are stripped**, since `<!-- TOC -->` was rendering as a literal paragraph on the first page; and the script now **refuses to render onto `SRS/PassScheduleGenerationSpec.docx`**, which is its own branding template — `shutil.copyfile` raises `SameFileError` on that path, so rebuilding *that* file means rendering to a temp path and moving it into place. |
| Aug 4, 2026 | **Created.** `build_docx.py` committed after being re-derived three times — `CLAUDE.md` had recorded the missing render pipeline as a recurring problem, and the scripts it named (`extract.py`, `assemble.py`, `build_docx.py`, `verify_docx.py`, `slim_docx.py`) lived only in a session scratchpad and were lost each time. This one is parameterised over source, output and header title so it is not specific to one document. |
