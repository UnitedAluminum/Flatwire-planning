# Tools

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 4, 2026
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

Headings — the first `#` becomes a centred title page · tables, with a shaded header row that repeats across page breaks · blockquotes as shaded callouts with a left rule · fenced code in monospace · ordered and unordered lists · `**Key:** value` metadata lines kept on their own lines · inline **bold**, *italic*, ~~strike~~, `code` and links.

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
| Aug 4, 2026 | **Created.** `build_docx.py` committed after being re-derived three times — `CLAUDE.md` had recorded the missing render pipeline as a recurring problem, and the scripts it named (`extract.py`, `assemble.py`, `build_docx.py`, `verify_docx.py`, `slim_docx.py`) lived only in a session scratchpad and were lost each time. This one is parameterised over source, output and header title so it is not specific to one document. |
