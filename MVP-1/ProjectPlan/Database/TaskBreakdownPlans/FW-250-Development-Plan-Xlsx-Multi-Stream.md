# FW-250 · `build_development_plan_xlsx.py` silently drops every multi-stream story

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** **Ready to build** — the defect is confirmed in the source, at two line numbers
**Owner:** Database (SQL Server) stream *(tooling)*
**Audience:** The developer building `FW-250`
**Shortcode:** — *(implementation plan, derived from the tool and `[TB §7]`; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Database/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Six hours, and **four details decide whether it is right.**
>
> **The silent skip is the defect, not the regex.** `if not streams: continue` at
> `:205` is why nobody noticed for weeks. A wider pattern alone leaves the *next* format to
> fail exactly the same way, just as quietly.
> **`BA`-only exclusion is correct and must survive the fix.** The parser excludes BA and QA
> deliberately and says so. **Widening `DISCIPLINE` would break a working rule** while fixing
> a broken one — and `FW-249` is the BA story that proves it.
> **Three hours formats are in use, not two.** `FW-202` uses a third —
> `98 h — FE 32 · BE 42 · DB 8 · RT 16`, an em dash and no parentheses.
> **The client deliverable's totals will move by roughly 250 h**, and that is a **correction**,
> not new scope. It must not be published without a reviewer.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-250 · `build_development_plan_xlsx.py` silently drops every multi-stream story
> **Hours:** 6 h DB · **Priority:** High · **Sprint:** S1 · **Phase:** — · **Stream:** DB
>
> > ⛔ **Found on 29 Aug 2026 by running the generator, not by reading it.** The work-item parser
> > reads a story's streams with `re.finditer(r'(\d+)\s*h\s*([A-Z]{2})', hrs)` — `<digits> h <two
> > capitals>` — which matches `3 h BE` and **cannot match the parenthesised multi-stream form**
> > `40 h (DB 26 · BE 14)`, because the character after `h ` is `(`. When nothing matches, the code
> > does `if not streams: continue` — **a silent skip, with no warning and no error.**
> >
> > ⛔ **Eleven stories are missing from the client-facing `FlatWire_DevelopmentPlan.xlsx` today**, and
> > the list is not marginal: **`FW-202`** (FL1 spool completion, 98 h — written in a third format,
> > `98 h — FE 32 · BE 42 · DB 8 · RT 16`), **`FW-219`** (the FL2/FL3 run-end shared write-back, 40 h),
> > **`FW-220`**, **`FW-223`**, and the **whole `FW-225`–`FW-231` rod ↔ order allocation set**. They
> > are absent from the work-item sheet, from every effort roll-up, and — because they were never
> > parsed — **from the *"excluded from plan"* line that is supposed to name what was left out.**
> >
> > ⚠ **The parenthesised form is the repository's convention, not an error** — it is what
> > `[TB §7.1]`'s own multi-stream cards use, so this is a defect in the reader. ⚠ **The `FW-232`–
> > `FW-249` set inherits it**: five of those cards (`FW-234`, `FW-235`, `FW-238`, `FW-243`,
> > `FW-247`) are dropped the same way, which is how the defect surfaced.
> >
> > ⚠ **`BA`-only stories are a DIFFERENT case and must stay excluded** — the parser's docstring is
> > explicit that QA- and BA-only stories *"are not development work and are excluded here rather
> > than silently absorbed"*. `FW-249` (8 h BA) is correctly out. **Do not fix this by widening
> > `DISCIPLINE`.**
>
> **Acceptance Criteria:**
> - [ ] The stream parser reads all three hours formats in use: `N h XX`, `N h (XX a · YY b)` and `N h — XX a · YY b · …` (`FW-202`'s)
> - [ ] ⛔ **A card whose hours parse to no development stream FAILS the build**, or is named in a warning — never `continue`d silently. The silent skip is the defect; a wider regex alone would leave the next format to fail the same way
> - [ ] `BA`- and `QA`-only stories stay excluded **by a deliberate branch that says so**, distinguishable in the output from a parse failure
> - [ ] The eleven pre-existing stories appear in the work items sheet and in the effort roll-ups, and the *"excluded from plan"* line becomes trustworthy
> - [ ] ⚠ **The deliverable's effort totals will move when this lands** — roughly 250 h of already-baselined work becomes visible. **That is a correction, not new scope**, and the regenerated `.xlsx` must be reviewed before it is shared

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| Re-deriving the DB-stream total | `FW-249` — and it is **correctly excluded** by this parser (BA-only) |
| The schema count guard's blind spot | [`FW-248`](FW-248-Harden-Count-Guard-C6.md) — sibling defect, same `S1`, found the same way |
| `[TB §7]`'s hours themselves | **Unchanged.** This story changes what is *read*, never what is written |
| `[CE §3b]` and every published total | Untouched — the `.xlsx` is a view, not a source |
| The other two `[TB §7]` generators | ⚠ **Check them** (§2.4), but their defects are their own |

### 1.2 What already exists

Confirmed in the source on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| The generator | [`build_development_plan_xlsx.py`](../../Tools/build_development_plan_xlsx.py) | ✅ Built and in use — produces a **client-facing** deliverable |
| **The regex** | **`:201`** — `re.finditer(r'(\d+)\s*h\s*([A-Z]{2})', hrs)` | ⛔ Matches `3 h BE`; **cannot** match `40 h (DB 26 · BE 14)` |
| The stream filter | `:202` — `if m.group(2) in DISCIPLINE` | ✅ Correct, and the reason `BA` is excluded |
| **The silent skip** | **`:204`–`:205`** — `if not streams: continue` | ⛔ **The actual defect.** No warning, no error, no count |
| `DISCIPLINE` | `:80` — `FE`, `BE`, `DB`, `RT` | ✅ Correct as it stands — **do not widen** |
| The `.xlsx` | `MVP-1/SRS/FlatWire_DevelopmentPlan.xlsx` | ⚠ **Committed, and missing eleven stories.** Regenerated during `FW-241`–`FW-249`'s verification and then **restored to its committed state** on purpose |

**Nothing here is cancelled by `D-31`/`D-32`.**

---

## 2. The four details

### 2.1 Fix the skip before the pattern

The regex is the *cause*; `continue` is the *reason it survived*. A story that fails to parse
vanishes from the work-item sheet, from every roll-up, **and from the "excluded from plan"
line** — so the deliverable actively asserts completeness it does not have.

**Order matters.** Make the failure loud first, run it, and let the tool name its own eleven
casualties. That list is the test fixture, and it is more trustworthy than one written by
hand. Then widen the pattern and watch the list go to zero.

### 2.2 Three formats, and the third is the awkward one

| Form | Example | Note |
|---|---|---|
| Single stream | `3 h BE` | ✅ Parses today |
| Parenthesised | `40 h (DB 26 · BE 14)` | ⛔ Dropped. **The repository's convention** for multi-stream |
| Em-dash list | `98 h — FE 32 · BE 42 · DB 8 · RT 16` | ⛔ Dropped. **`FW-202` only** |

⚠ **Note the inversion.** The parenthesised form is `<STREAM> <hours>` (`DB 26`) while the
single form is `<hours> h <STREAM>` (`3 h BE`). **A pattern that assumes one order will read
`26` as a stream name or silently take the wrong number.** This is the single most likely way
to ship a wrong figure into a client deliverable.

**Parse the total first, then the per-stream breakdown separately**, and — because the two must
agree — **assert that the parts sum to the total.** A card whose parts do not sum is a data
defect in `[TB §7]` worth failing on.

### 2.3 `BA`-only must stay excluded, and be distinguishable from a failure

After §2.1, "no development stream" is a build failure. **`FW-249` has no development stream
and is correct.** So the two cases must be told apart *before* the failure branch:

- Hours parse, and **every** stream is `BA`/`QA` → **excluded deliberately**, named on the
  "excluded from plan" line.
- Hours **do not parse at all** → **failure**.

⛔ **Do not widen `DISCIPLINE` to include `BA`.** It would fix the symptom by breaking the rule
the docstring states — that BA and QA are *"excluded here rather than silently absorbed"* — and
would fold BA hours into a development roll-up.

### 2.4 The other two generators read the same cards

`[TB §7]` feeds **three** generators. This defect is in the reader, and the same cards are read
elsewhere — `build_questions_xlsx.py` and the backlog `.xlsx`. ⚠ **Check whether either parses
hours the same way**; the memory that story rows are *parsed, not prose* applies to all three.

**If they share the flaw, fix it here in one shared helper** rather than three times.

---

## 3. Build order

1. **Make the skip loud** (§2.1) — replace `continue` at `:205` with a collected failure that
   names the story id. Run it. **Record the list the tool produces.**
2. **Confirm it names eleven** — `FW-202`, `FW-219`, `FW-220`, `FW-223`, `FW-225`–`FW-231`.
   ⚠ Plus five of the new set (`FW-234`, `FW-235`, `FW-238`, `FW-243`, `FW-247`), which is how
   this was found. **A different count means the story list has moved; investigate before
   proceeding.**
3. **Split the parse** (§2.2): total hours, then per-stream parts, then **assert the parts sum
   to the total**.
4. **Three patterns**, order-aware — never one pattern assuming a single token order.
5. **The deliberate-exclusion branch** (§2.3), evaluated **before** the failure branch, and
   surfaced on the "excluded from plan" line.
6. **Check the sibling generators** (§2.4); extract a shared helper if the flaw is shared.
7. **Regenerate and diff.** ⛔ **Do not commit the `.xlsx` yet** — see AC 5 and `P-158`.
8. **Review the ~250 h movement with a named reviewer**, then publish.

---

## 4. Decisions this plan makes

> The `P-##` series belongs to [`Backend/TaskBreakdownPlans/`](../../Backend/TaskBreakdownPlans/)
> and is continuous across the repository; `P-01`–`P-156` precede this story.

### `P-157` — the parts must sum to the total, and a mismatch fails the build

§2.2. The two orderings make a silently-wrong number the likeliest failure, and a client
deliverable is the worst place to discover one. The sum check costs nothing and catches both a
parser bug and a malformed card.

**Fallback:** warn instead of failing, if `[TB §7]` turns out to carry a card whose parts
legitimately do not sum. **Fix the card instead** — that would itself be a finding.

### `P-158` — the regenerated `.xlsx` is published under a named reviewer, not by this story

AC 5. Roughly **250 h** of already-baselined work becomes visible. It is a **correction**, not
new scope, and the totals in a client-facing deliverable moving by that much needs someone's
name against it.

⚠ **Precedent:** the workbooks were regenerated during `FW-241`–`FW-249`'s verification and
then **deliberately restored** to their committed state for exactly this reason.

### `P-159` — `BA`/`QA` exclusion is a branch, never a `DISCIPLINE` entry

§2.3. Widening the map would absorb BA hours into a development roll-up — the outcome the
docstring exists to prevent.

---

## 5. Verification

| Check | Expected |
|---|---|
| **Loud first** | Before the pattern fix, the tool **names** its eleven casualties. ⛔ It currently names none |
| Eleven present | After the fix, all eleven appear in the work-item sheet and every roll-up |
| **Sum check** | Parts equal the total on every multi-stream card (`P-157`). Corrupt one card locally and confirm it fails |
| Order safety | `40 h (DB 26 · BE 14)` yields DB **26** and BE **14** — never a stream named `26` |
| `FW-202` | The em-dash form parses: FE 32 · BE 42 · DB 8 · RT 16, summing to 98 |
| **`FW-249` still excluded** | Present on the *"excluded from plan"* line as a **deliberate** exclusion, **not** a failure (`P-159`) |
| `DISCIPLINE` unchanged | Still `FE`, `BE`, `DB`, `RT` |
| Single-stream regression | `3 h BE` parses exactly as before — the eleven were the only ones affected |
| **`[TB §7]` untouched** | `git diff` shows no change to the backlog. This story changes a **reader** |
| Totals movement | ~250 h, and **explained as a correction** in the commit and to the reviewer |
| **`.xlsx` not published** | Committed only after review (`P-158`) |

---

## 6. Handoff

`FW-249` re-derives the DB-stream total and **must run after this** — deriving a total from a
generator that drops eleven stories would bake the defect into the figure `[CE]` publishes.
[`FW-248`](FW-248-Harden-Count-Guard-C6.md) is the sibling tooling defect in the same sprint;
both were found **by running the tool rather than reading it**, which is the transferable
lesson.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`FW-249`** | Must run **after** this story, or the re-derived total inherits the defect |
| **AC 5 reviewer** | Unnamed. The `.xlsx` cannot publish without one (`P-158`) |
| **The sibling generators** | §2.4 — unverified whether they share the flaw |
| **`[TB §7]` hours** | Unchanged by this story. It reads them; it does not write them |
