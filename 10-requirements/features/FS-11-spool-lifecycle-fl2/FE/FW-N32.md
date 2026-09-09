---
id: FW-N32
legacy_id:
title: Out-of-spec threshold becomes per-line, and the tolerance alert reaches FL2
status: not-started
status_confirmed: true
status_note: "⬜ **Not started — 12 h (8 BE + 4 FE).** ⛔ **This is the one part of the FL2 live-gauge change that can produce bad product.** The out-of-spec rule auto-prompts after *N consecutive* readings. `N` is currently one shared value, chosen when only FL1 and FL3 measured at ~10 Hz. **On FL2 at 4 s the same `N` is ~40× more production before the operator is told** — four readings is under half a second on FL1 and **16 seconds of wire** on FL2. This story makes `N` **per line** and widens the alert rule to FL2, which `TC-494` scoped to FL1/FL3 only. ⚠ **The mechanism is MVP-1; the VALUE is a trial-run item** — re-choosing `N` needs run data (`Q66`/`Q67`)."
owner:
jira:
mvp: 1
phase: "8"
stream: BE
streams: [BE, FE]
priority: high
hours: 12
sprint: S2
depends_on: [FW-N29]
blocked_by: []
has_plan: false
started:
completed:
---
# FW-N32 · Out-of-spec threshold becomes per-line, and the tolerance alert reaches FL2

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — created with the FL2 live-gauge change (`G120` resolved).
**Document Type:** Story plan
**Status:** Not started
**Owner:** Backend, with a frontend leg
**Shortcode:** — *(story plan, derived; **not citable as a requirement**)*

---

## 1. What to build

**Hours:** 12 h (**8 h BE** + **4 h FE**) · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** BE

> ⛔ **Read this before sizing it down.** Every other part of the FL2 live-gauge change is a
> documentation or plumbing change that fails **visibly** — a missing trace, a blank panel. This one
> fails **silently and expensively**: the operator is simply told late, and the wire is already made.
> A shared `N` was correct while every measuring line ran at ~10 Hz. It stopped being correct the
> moment a line measured at 4 s.

**As a** quality engineer setting up the finishing line,
**I want** the out-of-spec prompt threshold set per line rather than shared,
**So that** FL2's four-second cadence does not turn a four-reading rule into sixteen seconds of scrap.

**Acceptance Criteria:**

- [ ] The consecutive-out-of-spec threshold is **configuration, per line** — not one shared constant.
      Consistent with `R-12`/`S-14`, which already require thresholds to be *"configuration, not
      constants — tunable by Operations without a software release"*.
- [ ] The evaluator reads **that line's** threshold. ⛔ **A shared default silently applied to FL2 is
      the defect** — it must be possible to see, per line, which value is in force.
- [ ] **The gauge-tolerance alert rule reaches FL2.** `TC-494` was titled *"gauge outside tolerance on
      **FL1/FL3**"* and is widened to all three lines (done 9 Sep 2026); this is the implementation
      behind it. Until this lands, **FL2 measures live and raises no tolerance alert** — worse than not
      measuring, because the screen looks complete.
- [ ] The threshold is evaluated **server-side**, with the ladder and the alert, so every client agrees
      on the count — the same reason `§4.2`#6 and `[SIG §5.5]` put the milestone evaluator in the
      service rather than the browser.
- [ ] A provisional per-line default is seeded and **visibly marked provisional**. ⚠ **Do not seed
      FL1's value as FL2's default** — that is precisely the silent regression this story prevents.
- [ ] Specs cover: FL1 at its value, FL2 at its value, and **the case where FL2's is absent** — which
      must not silently fall back to FL1's.

**Rate-card basis:** **8 h BE** as a *non-trivial business service* at the low end of the 12–24 h band
(the evaluator exists; what is added is per-line resolution and the FL2 rule), plus **4 h FE** to
surface which value is in force. ⚠ **No new endpoint and no new hub event** — the alert already has both.
**Dependencies:** `FW-N29` (FL2 must be publishing before its threshold means anything)
**Blockers:** none

## 2. ⚠ The mechanism is MVP-1; the value is not

**Build the per-line mechanism now. Do not attempt to choose FL2's `N` now.** Choosing it needs to
know how FL2 actually drifts at production speed, which is trial data — `Q66` / `Q67`, both owed after
the trial. Shipping a configurable threshold with a marked-provisional default is correct; shipping a
confident number is not.

Carried as a trial-run item in [`TrialRunPlan.md`](../../../../60-delivery/TrialRunPlan.md).

## 3. Provenance

`G120` resolved 9 Sep 2026 — `A3` retired, `FR-120` superseded, FL2 measures gauge and width live at a
**4 s** update rate. The cadence consequence is stated at
[`ActiveRunMonitor.md`](../../../screens/ActiveRunMonitor.md) §3.2, `[SIG §5.3]` and
`[PLC §5.1]`. `TC-132` is the auto-prompt case whose `N` this story makes per-line; `TC-494` is the
alert rule this story widens.
