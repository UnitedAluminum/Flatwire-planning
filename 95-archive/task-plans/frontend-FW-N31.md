---
id: FW-N31
legacy_id:
title: FL2 trace cadence - honest gaps and visible freshness at 4 s
status: not-started
status_confirmed: true
status_note: "⬜ **Not started — 8 h FE.** The client half of the FL2 live-gauge change (`FW-N29` owns ingest and broadcast). ⚠ **This story exists because a 4 s trace is not a 10 Hz trace drawn slowly.** Two failure modes are specific to the slower cadence and neither is caught by rendering the same component: a footage gap **interpolated** into a smooth line shows in-spec material over wire that was never measured, and at 4 s a **stalled feed looks healthy** for several seconds. ⛔ No line branch and no `LINE_PROFILES` trace flag — `D-55` removed that branch deliberately; the behaviour is driven by the data's own timestamps."
owner:
jira:
mvp: 1
phase: "8"
stream: FE
streams: [FE]
priority: high
hours: 8
sprint: S2
depends_on: [FW-N29]
blocked_by: []
has_plan: false
started:
completed:
---
# FW-N31 · FL2 trace cadence — honest gaps and visible freshness at 4 s

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — created with the FL2 live-gauge change (`G120` resolved).
**Document Type:** Story plan
**Status:** Not started
**Owner:** Frontend (Angular `flat-wire`)
**Shortcode:** — *(story plan, derived; **not citable as a requirement**)*

---

## 1. What to build

**Hours:** 8 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** FE

> **Why this is separate from `FW-N29`.** `FW-N29` makes FL2's readings arrive. This story makes them
> **readable**. The trace components are already line-agnostic and are **not** to be branched — what
> changes is how the chart treats sparse data and how the panel signals staleness, on **every** line,
> with FL2 as the case that exposes it.

**As a** FL2 operator watching a live trace that updates every four seconds,
**I want** unmeasured wire to look unmeasured, and a stalled feed to look stalled,
**So that** I never read a drawn line as evidence that material was in specification.

**Acceptance Criteria:**

- [ ] **A footage gap renders as a gap.** Where consecutive readings are far enough apart in footage
      that wire passed unmeasured, the trace **breaks** rather than joining the points. ⛔ **An
      interpolated line across unmeasured wire is the defect this story exists to prevent** — it draws
      in-spec material that was never measured, which is indistinguishable from a real reading.
- [ ] The gap threshold is **derived from footage, not from sample count or wall-clock** — the trace is
      footage-indexed (`[SIG §5]`), and at a given cadence the footage between samples varies with line
      speed. A fast FL2 run leaves wider gaps than a slow one at the same 4 s.
- [ ] **The panel's *last updated* indication is prominent enough to be load-bearing on FL2.** At
      ~10 Hz a stalled feed is obvious within a frame; at 4 s it is invisible for seconds. `R-5`/`§2.3`
      already require a visible *last updated*; this makes it sufficient at 4 s.
- [ ] A feed that stops mid-run shows **no measurement**, not the last value held indefinitely, and
      ⛔ **never a flat line at target** — the rule that survived `FR-120`'s supersession, now guarding
      a dropped feed on any line rather than describing FL2's normal state.
- [ ] ⛔ **No branch on `machineName` and no trace field added to `LineProfile`.** `D-55` made the
      treatment uniform and `FW-181`'s standalone-versus-hybrid trap is exactly what a line branch
      re-creates. Everything here is driven by the readings' own footage and timestamps.
- [ ] Specs assert the gap case against **literal** footage values, not against an imported constant —
      a spec that imports the threshold passes when the threshold is wrong.
- [ ] `lib-trace-panel` and `lib-chart-canvas` stay in `projects/shared` and keep working for their
      other consumers. ⚠ **`projects/shared` has 23 dependent libraries** — run `ng build shared`
      before any dependent test run, since `jest.base.config.js` resolves `shared` to `dist/`.

**Rate-card basis:** **8 h FE** — a *shared primitive control* change (8 h) rather than a new composite:
the chart and panel exist and are consumed unchanged; what is added is gap handling in the config
builder and freshness prominence in the panel header.
**Dependencies:** `FW-N29` (the readings must arrive before their cadence can be handled)
**Blockers:** none

## 2. What this story does NOT cover

| Not here | Where |
|---|---|
| Tag binding, ingest, unbatched broadcast, simulator | `FW-N29` |
| The out-of-spec consecutive-reading threshold, per line | `FW-N32` |
| The `[isLive]` chart-lifetime defect | `FW-N33` |
| Choosing the actual gap threshold **value** | ⚠ Needs trial data — `Q66` / `Q67`. Build it configurable and set a provisional default |

## 3. Provenance

`G120` resolved 9 Sep 2026: assumption `A3` of `[PLC §14]` retired, `FR-120` superseded. FL2 reads
`FL2.PLC.AGC.Gauge` / `.Width` at a **4 s** update rate — the client's figure, and the only cadence any
line has on record. See [`ActiveRunMonitor.md`](../../10-requirements/screens/ActiveRunMonitor.md) §3.2
for the three rules this story implements, and [`CHANGELOG.md`](../../CHANGELOG.md) for the change.
