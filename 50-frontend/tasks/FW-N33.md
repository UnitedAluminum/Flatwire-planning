---
id: FW-N33
legacy_id:
title: Bind isLive on the trace panel - stop rebuilding the chart every frame
status: not-started
status_confirmed: true
status_note: "⬜ **Not started — 2 h FE. A pre-existing defect, found while making the FL2 live-gauge change and NOT caused by it.** `active-run.component.html` renders `<lib-trace-panel>` without binding `[isLive]`, which defaults to `false`. `ChartCanvasComponent.render()` therefore takes the `releaseChart()` + `new Chart(...)` path on **every telemetry frame** instead of `this.chart.update('none')`. ⛔ **This has been hitting FL1 and FL3 at ~10 Hz all along** — two panels destroyed and reconstructed twenty times a second. `[UIC]` and `[CMP]` both specify `isLive`; nothing enforced it, and `ng lint` cannot see a missing optional input."
owner:
jira:
mvp: 1
phase: "8"
stream: FE
streams: [FE]
priority: high
hours: 2
sprint: S2
depends_on: []
blocked_by: []
has_plan: false
started:
completed:
---
# FW-N33 · Bind `isLive` on the trace panel — stop rebuilding the chart every frame

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — created; the defect was found during the FL2 live-gauge change.
**Document Type:** Story plan
**Status:** Not started
**Owner:** Frontend (Angular `flat-wire`)
**Shortcode:** — *(story plan, derived; **not citable as a requirement**)*

---

## 1. What to build

**Hours:** 2 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** FE

> ⚠ **This is not part of the FL2 change and does not depend on it.** It was found while tracing how
> the trace panel is fed, and it affects **FL1 and FL3 today**. It is carded separately so it is not
> buried inside a story about FL2 and lost if that story moves.

**The mechanism, precisely.** `TracePanelComponent.isLive` and `ChartCanvasComponent.isLive` are
`input<boolean>(false)`. `ChartCanvasComponent.render()` reads:

```
if (this.chart && this.isLive()) { this.chart.data = config.data; this.chart.update('none'); return; }
this.releaseChart();                      // chart.destroy()
this.chart = new Chart(element, config);
```

With `isLive` unbound it is always `false`, so **every frame destroys the Chart.js instance and
constructs a new one** — including a `resize()` — where an in-place `update('none')` was intended.

**As an** operator watching a live trace,
**I want** the chart updated in place rather than rebuilt,
**So that** the panel does not thrash on every telemetry frame.

**Acceptance Criteria:**

- [ ] `<lib-trace-panel>` in `active-run.component.html` binds **`[isLive]="true"`**. ✅ *(Applied
      9 Sep 2026 alongside the FL2 change; this card carries the verification and the spec.)*
- [ ] A spec asserts the **live path**: with a chart already present, a new config calls
      `update('none')` and **does not** construct a new `Chart`. ⛔ **Assert the absence of the
      rebuild** — a spec that only checks the trace still renders passes either way, which is how this
      survived.
- [ ] The **non-live path stays intact** for consumers that legitimately want a rebuild — `isLive`
      keeps its `false` default, and this story does not change the default.
- [ ] ⚠ Check the **other consumers of `lib-trace-panel`** before changing anything in
      `projects/shared` — it has 23 dependent libraries, and `jest.base.config.js` resolves `shared`
      to `dist/`, so `ng build shared` must run before any dependent test run.
- [ ] ⚠ **`trace-graph-popup`** renders the same chart when a panel is maximised — confirm whether it
      also needs the binding, rather than assuming the active-run panel is the only site.

**Rate-card basis:** **2 h FE** — below the 8 h *shared primitive* unit because the fix is a single
attribute already applied; the hours are the spec that stops it regressing and the check of the other
consumers.
**Dependencies:** none — **Blockers:** none

## 2. Why it was invisible

Three things had to line up, and all three are worth remembering:

1. **A missing optional input is not a compile error and not a lint error.** `ng lint` reported clean.
2. **The visible behaviour is correct.** The trace renders, updates and looks right — the cost is
   performance, which no acceptance criterion was measuring.
3. **`[UIC]` and `[CMP]` both specify `isLive`**, so the written standard was right and only the
   binding was missing. ⚠ This is the *"a CSS class that does not exist looks exactly like one that
   does"* failure mode from `CLAUDE.md`, in a different guise: **a specified input that is never bound
   looks exactly like one that is.**
