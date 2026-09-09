---
id: FW-162
legacy_id:
title: run-status-cards
status: not-started
status_confirmed: true
status_note: "⚠ **The strip exists on DB3 as inline markup, not as reusable controls.** `flat-wire-landing.component.html` renders the Machine / Payoffs / Components three-card strip from `buildMachineLines()`, `buildPayoffs()` and `buildComponentSettings()`, with the payoff consumption bar inline — so ACs 1, 2 and 4 are substantially met **for FL1 only**. ⛔ **Not built:** the `1fr 1.35fr 1fr` grid (the strip is Bootstrap `col-4` and the library has no `.scss` at all) and the FL2 *Material flow* middle card. This story owes the extraction and the FL2 variant, and must **replace** DB3's inline markup rather than sit beside it. ⚠ **`FW-062` declares `depends_on: [FW-162]` while having already built this story's output** — a dependency inversion to settle when either story is scheduled"
owner:
jira:
mvp: 1
phase: "5"
stream: FE
streams: [FE]
priority: critical
hours: 20
sprint: S2
depends_on: [FW-133]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-162 - run-status-cards

> ### ⚠ Three of the five criteria already render — read this before starting
>
> **The three-card strip is built**, inline on DB3 (`flat-wire-landing.component`), ahead of this
> story. `{{ contentData.machine }}` · `{{ contentData.payoffs }}` · `{{ contentData.components }}`
> render the strip from three private builders, and the payoff consumption bar is inline Bootstrap
> `progress` markup.
>
> ⚠ **It is markup, not controls, and every figure in it is a hardcoded literal.** What this story
> owes is the **extraction** — and the extraction must **replace** DB3's markup, not sit beside it,
> or the two diverge. This is the same situation `FW-163` records for the info tables.
>
> ⛔ **Two criteria are not met at all:** the `1fr 1.35fr 1fr` grid (DB3 uses Bootstrap `col-4`, and
> `projects/flat-wire` carries **no `.scss` file** — see [`[UIC §2]`](../UIConventions.md)) and the
> **FL2 *Material flow* middle card**, which is the substance of AC 3.
>
> ⚠ **Dependency inversion:** `FW-062` lists `depends_on: [FW-162]`, yet DB3 already renders this
> story's output. Settle the direction when either is scheduled.
>
> ⚠ **The rail and the charts are consumed, not written** — `lib-nav-rail`, `lib-chart-canvas` and
> `lib-trace-panel` live in `projects/shared` ([`[UIC §3.22]`](../UIConventions.md)). Do not
> reimplement them here.

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 20 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** operator,
**I want** machine, material and component state in one card strip,
**So that** I can read the whole line at a glance.

**Acceptance Criteria** — 🟡 marks what DB3 already renders as inline markup; an unticked box is still owed as a **control**:
- [ ] Three-card strip on a `1fr 1.35fr 1fr` grid; **absorbs the former `machine-status-panel`** — 🟡 **the strip renders; the grid does not.** DB3 composes it as Bootstrap `row g-2` / `col-4`, and the library has no stylesheet in which to declare a grid ([`[UIC §2]`](../UIConventions.md))
- [ ] Outer cards are **Machine** (run time, speed, footage, spool fill, lube temp) and **Components** (dies, gap + width, headed by the pass-schedule id) on every line — 🟡 **both render on FL1** from `buildMachineLines()` and `buildComponentSettings()`, Components headed by the pass-schedule alpha. **Only FL1** — there is no FL2 or FL3 variant
- [ ] **The middle card is line-specific** — *Payoffs* (two rod payoffs with consumption bars) on FL1/FL3, *Material flow* (spool draining in, coil filling out) on FL2. **Same shell, different middle card** — 🟡 **the FL1/FL3 Payoffs card renders** with two rod payoffs and consumption bars; ⛔ **the FL2 *Material flow* card does not exist.** This is the substance of the story that remains
- [ ] **`payoff-weight-bar` survives as the Payoffs card's content**, not as a sibling of the status panel. It is still used directly by Dashboard 1, so it stays in the FW-133 shared set — this is a change to DB3's composition, not a deletion — 🟡 **the composition is already this way** on both screens, but as inline `progress` markup rather than `FW-133`'s control. `FW-134`'s note records the same two consumer slots
- [ ] The FL2 material-flow card is **not** a payoff bar and must not reuse its labels — ⛔ untested, since the FL2 card does not exist

**Rate-card basis:** shared composite control 20 h (§2)
**Dependencies:** FW-133
**Blockers:** —

---

---

## Added by `D-55`, 7 September 2026

- [ ] **The middle card is profile-driven, not line-branched.** It takes its content model from
      `LINE_PROFILES[machineName]` — *Payoffs* on FL1/FL3, *Material flow* on FL2 — with ⛔ **no `@if` on
      the line anywhere in the template**. The FL2 card is a different data *shape*, not the payoff
      bar with different labels, and must not reuse its labels.
- [ ] **The Components card renders from the run's pass schedule.** ⛔ No per-line component list in
      code, on any line. This is what lets one card show draw boxes and one mill on FL1, three
      finishing stands on FL2, and both groups on FL3 without a line-specific layout.
- [ ] ⚠ **`ComponentStateItem.CurrentValue` is one `decimal?` and some rows need two** — FM1's gap
      *and* width, a stand's diameter *and* its edge type. The response field is **`FW-164`**'s
      (see its §8); this story consumes it.
