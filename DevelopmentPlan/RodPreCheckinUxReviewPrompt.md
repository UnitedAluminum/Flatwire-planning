# UX Review Prompt — Dashboard 2A, Rod Pre-Check-in Station (VPS)

**Project:** Flat Wire Mill — Shopfloor & Real-Time
**Last Updated:** July 30, 2026
**Status:** Ready to use

Hand the block below to Claude Code (or any agent with repo access) to get a critique and a
re-plan of the Dashboard 2A operator screen. It is a **design/analysis** prompt — it asks for a
plan, not an implementation.

---

## The prompt

> Analyse `@Mockups/dashboard_2a_rod_precheckin.html` and produce a plan for how this UI could be
> structured better. Treat the mockup as the current approved baseline, not as scripture: your job
> is to find where its information architecture, task flow, and state model make the operator's job
> harder than it needs to be, and to propose a concretely better arrangement.
>
> ### Ground yourself first (do not skip, do not restate in your output)
>
> 1. `CLAUDE.md` in this repo — what the repo is, and which docs win when they disagree.
> 2. `DevelopmentPlan/ShopfloorPlan/00-foundations.md` — §0.2 reference-codebase rules, §0.3 domain
>    cheat-sheet (alpha formats, status vocabularies, hub events), §0.4 the real-time architecture,
>    and the numbered decisions (esp. the approved-variant list).
> 3. `DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md` — the phase that owns this
>    screen — plus `phase-02-pass-schedule-management.md` (its gating dependency).
> 4. `DevelopmentPlan/ShopfloorPlan/back-matter.md` — the **G1–G18 gap register**.
> 5. `LatestDocument/RequirementDocuments/RodPreCheckin.md` — **the dedicated analysis for this exact screen; read it first of
>    the five.** Also `LatestDocument/RequirementDocuments/WeldEvent.md`, `Analysis/FlatWireShopfloorDashboards.md` (the
>    Dashboard 2A screen spec and the *Payoff Weight Indicator Rules* the mockup cites), and
>    `Analysis/FlatWireOpenQuestions.md` (the ~77-item decision register, `Q##`; resolved items are
>    struck through or carry a **Decided (date)** note).
> 6. `DevelopmentPlan/REVIEW.md` — tells you which specs carry known contradictions.
> 7. `Mockups/flat-wire-shopfloor.styles.scss` and `Mockups/flat-wire-fit.js` — the design tokens
>    and the scaling contract you must design within.
>
> Read the mockup's own **header comment block and inline comments in full**. They record decisions
> that were learned the hard way (bay symmetry, the weight-bar colour thresholds, the flex
> `min-height: 0` rules, why the sequence marker is neutral rather than amber). Anything you propose
> that reverses one of those must say so explicitly and argue the case — several of them are marked
> as *superseding* an earlier requirement, and silently reinstating the old behaviour is a
> regression, not an improvement.
>
> ### Hard constraints on any proposal
>
> - **Physical context.** A 1280×1024 fixed panel on a mill floor, read at arm's length, operated
>   with gloves, under glare. Minimum font size **14px** everywhere. Touch targets ≥44px.
>   `flat-wire-fit.js` never scales above 1:1, so the design height you propose is the height that
>   ships. State the height budget for any layout you propose, the way the current file does.
> - **No new frameworks.** Everything must be portable to the `flat-wire-shopfloor` Angular library
>   (prefix `fw`), styled from the shared semantic tokens (`--color-*`, `--border-radius-*`,
>   `--font-*`). No Bootstrap, no `--fw-*` token prefix (that name is stale — gap G18). No
>   `innerHTML`: assume templates and control flow, which changes what dynamic layouts are cheap.
> - **Terminology.** "Flat wire," never "strip." Traveler is fully digital.
> - **Scope.** This is the *pre*-check-in / staging station (VPS). Do not redesign Dashboard 2
>   (`dashboard_2_rod_checkin - New.html`), Dashboard 4, or Dashboard 8 — but do say when a problem
>   here is really a problem at the seam with one of them.
>
> ### Evaluate along these lenses
>
> Work through all of them; do not stop at visual polish.
>
> 1. **Task flow.** What is the operator actually doing at this station, in what order, under time
>    pressure (a rod is running down toward 2,000 lb while they stage the next one)? Count the
>    interactions for the primary path — scan → stage → inspect → commit → weld — and say where the
>    screen adds steps, modal hops, or re-entry of data it already knows.
> 2. **Information architecture.** Five regions compete for a fixed 1024px: header, two payoff bays,
>    weld strip, queue, footer. Is that the right division of a scarce budget? What earns its space,
>    what is decoration, and what is missing at the moment of decision (and therefore forces the
>    operator to another screen)?
> 3. **State model.** Four bay states × two peer bays, plus derived states. Enumerate the full state
>    space including the awkward ones — cold start, both bays occupied, mid-transition when Payoff 2
>    becomes the running bay, a blocked bay that still occupies its position, welded-as-a-flag — and
>    find combinations the current layout renders badly or not at all.
> 4. **Deviation and authorisation paths.** Off-schedule order and out-of-sequence rod share one
>    supervisor credential block and can co-occur. Is that the right shape? Where does the screen
>    read as a refusal when the requirement says the deviation is *authorised, not enforced*?
> 5. **Weld traceability.** Marking a weld is the genealogy link that welding-wire certs depend on.
>    Is the gating (running rod + staged rod) surfaced clearly enough, and is the weld strip in the
>    right place relative to the two bays it joins?
> 6. **Real-time behaviour.** Payoff weight, line state, and the queue all change under the operator
>    without their input. Which regions must update live, at what cadence, and what should visibly
>    change vs. stay stable so the screen is not a distraction? Reconcile against §0.4 hub events.
> 7. **Attention and alarm design.** The weight bar's colour is driven by absolute-pound thresholds
>    and one state flashes. Is the escalation ladder (info → warn → crit → flash) proportionate, and
>    does anything else on the screen compete with it?
> 8. **Accessibility and redundant coding.** Pass/Fail carries a glyph as well as a fill colour;
>    check the rest. Card-divs stand in for radios — verify roles, focus order, and keyboard path
>    survive your proposal. Every state must survive a greyscale screenshot.
> 9. **Data-model fit.** Cross-check what the screen displays and writes against
>    `DevelopmentPlan/Schema/` (`RodStaging`, `RodCheckin`, `WeldEvent`, `FlatWireRun`) and
>    `DevelopmentPlan/APIContracts.md`. Flag every field the UI shows that has no column, and every
>    row the UI implies but nothing writes. The mockup already names some of these — the derived
>    BLOCKED bay whose `RodStaging` row nothing currently writes, and the per-alloy rod diameter
>    tolerance with no column (CHK007). Find the rest.
> 10. **Angular portability.** Which regions should be components, what is the one renderer both
>     bays share, what belongs in a service vs. component state, and where does the fixed-height
>     flex contract become fragile once content is data-driven?
>
> ### Deliverable
>
> A single markdown analysis with these sections, in this order:
>
> 1. **What the screen gets right** — brief, specific, so the re-plan does not throw it away.
> 2. **Findings table** — `ID | Severity (High/Med/Low) | Lens | Finding | Operator consequence |
>    Proposed change`. Severity is about the consequence on the floor (a wrong rod welded into a
>    coil, a missed payoff transition), not about how ugly it looks. Order the table by severity.
> 3. **Proposed layout** — ASCII wireframes for the primary state plus at least the cold-start,
>    both-bays-occupied, and blocked states. Give the height budget per region and the total. If you
>    keep the current five-region split, say why and move on.
> 4. **Alternatives considered and rejected**, with the reason — one paragraph each, maximum three.
> 5. **Component and state plan** for the Angular port: component tree, inputs/outputs, what the
>    service owns, which hub events drive which region.
> 6. **Spec impact** — every finding mapped to the doc that must change: phase file, `OQ-##` (new
>    ones proposed with a suggested question), `G##` gap, schema doc, or `APIContracts.md`. New open
>    questions go in a clearly marked list; do not edit the register yourself.
> 7. **What you did not resolve** — genuine open questions for the business, not hedges.
>
> ### Rules for the output
>
> - **Do not write code and do not edit any file.** This is a plan. The mockup, the phase docs, and
>   the open-questions register stay untouched unless I ask separately.
> - Cite specifics as `file:line` — a finding without a location is not actionable.
> - Distinguish **"the mockup does this"** from **"the spec says this"** from **"I think this."**
>   Where the mockup and a spec disagree, name both and apply the precedence rule from `CLAUDE.md`
>   (July 26 roadmap + `ShopfloorPlan/*` win over the April-dated docs).
> - No filler. If a lens turns up nothing, say "no findings" and move on.

---

## Variants

**Quick pass** (~10 min, no spec cross-check) — use lenses 1, 2, 7, 8 only; deliver the findings
table and one wireframe; skip sections 4–6.

**Schema-first pass** — lead with lens 9, and deliver the field-by-field UI↔schema↔contract
reconciliation table as the primary artifact, with layout findings secondary.

**Comparative pass** — add: "Read `Mockups/dashboard_2_rod_checkin - New.html` and
`Mockups/dashboard_2_rod_checkin_fl3.html` alongside it, and say where 2A duplicates, contradicts,
or should absorb them. FL3's hybrid route is the case most likely to break a 2A assumption."

---

## Change Log

| Date | Change | By |
|---|---|---|
| 2026-07-30 | Initial version | Claude |
