---
id: FW-062
legacy_id:
title: Dashboard 3 — Active Run Monitor, the machine-driven shell (FL1/FL2/FL3)
status: in-progress
status_confirmed: true
status_note: "🟡 **The screen is built as a UI skeleton** — `flat-wire-landing.component`, the default child of `#/flat-wire`. ⛔ **Every value on it is placeholder data from a hardcoded builder**: no API client, no live stream, all seven rail entries inert, nothing persisted. ⭐ **Re-scoped 7 Sep 2026 by `D-55`: this is now ONE machine-driven component for FL1/FL2/FL3 at `#/flat-wire/home/:machineName`, with only FOUR per-line rows** — the FL1/FL2/FL3 'variants' are retired, and six things that read as configuration are data or uniform. ⛔ **It now depends on two new stories that did not exist**: `FW-N15` (route, line resolver, `LINE_PROFILES`) and `FW-N16` (the station-claim read). Still owed: the data path, the eight hardcoded builders replaced by a mapper, and the `PS-1100-FL1-003` negative fixture removed"
owner:
jira:
mvp: 1
phase: "5"
stream: FE
streams: [FE]
priority: critical
hours: 32
sprint: S2
depends_on: [FW-133, FW-162, FW-163, FW-081, FW-164, FW-N15, FW-N16]
blocked_by: [PLC-Q02]
has_plan: false
started:
completed:
---

# FW-062 - Dashboard 3 — Active Run Monitor, the machine-driven shell (FL1/FL2/FL3)

> ### ⭐ Re-scoped 7 September 2026 by `D-55` — this is now ONE component for three lines
>
> **The FL1/FL3/FL2 "variants" are retired.** This story owns a single machine-driven screen at
> `#/flat-wire/home/:machineName`, with **exactly four things varying by line** — the material panel
> (rod \| spool), the centre status card (payoffs \| material flow), the action set, and the
> spool-completion overlay (FL1 only). Everything else is identical or comes from data.
>
> ✅ **The re-scope makes this story smaller, not larger**, because six things that read as per-line
> configuration turned out to be data or uniform: trace source, trace titles, the Order Information
> column set, the Components card (**pass-schedule driven**), weld markers (`weldEvents[]`) and the
> hybrid badge (`RouteMode`).
>
> ⛔ **Two stories carry what this one no longer does.** **`FW-N15`** owns the route, the line
> resolver and `LINE_PROFILES`; **`FW-N16`** owns the station-claim read. Neither existed before
> `D-55`, and this story cannot be built without both.
>
> ⚠ **`FW-189`'s DB3 half now reduces to the action set alone** — the FL3 delta is one profile row.
> The FL3 work costed in *both* stories is a recorded double-count; hours are unchanged pending a
> costing pass.

> ### 🟡 The UI is already built — read this before starting
>
> **DB3's screen exists** as `flat-wire-landing.component` in `projects/flat-wire/`, built ahead of
> this story as the reference every other flat wire screen is copied from. It is **the landing
> screen** — `#/flat-wire` redirects to `#/flat-wire/flat-wire-landing` — and it is the source of
> [`[UIC]`](../UIConventions.md). This story inherits it.
>
> ⚠ **It is a UI skeleton.** Every figure on it is a literal in a private `build*()` method or in
> `flat-wire.constants.ts`: **no API client, no `HttpClient`, no SignalR, no subscription anywhere in
> the library**, all seven rail entries `isActive: false` and therefore rendered disabled, and
> nothing persisted. The screen is composition and layout, not behaviour.
>
> ⚠ **The rail and both charts are consumed, not written here** — `lib-nav-rail`, `lib-chart-canvas`
> and `lib-trace-panel` live in `projects/shared` ([`[UIC §3.22]`](../UIConventions.md)). Do not
> reimplement them in this library.
>
> **Built:** the left action rail (SPC Checkpoint · Roll Adjust · WIP Reject · Pause Run · Checkout ·
> Complete Coil · More Options) · the run context bar · the Machine / Payoffs / Components card strip · the
> collapsible Rod Information and Order Information tables · the tab strip · both trace panels with
> **Chart.js** line charts, target line and tolerance band · **maximise, which opens the trace in a
> popup** ([`[UIC §3.14]`](../UIConventions.md)) · the **spool notification card and its acknowledged
> pill** ([`[UIC §3.16]`](../UIConventions.md)) · a **budgeted height** that fits the window at any
> resolution without scaling ([`[UIC §4.1]`](../UIConventions.md)).
>
> ⛔ **The blue palette is final** and the screen carries **no theme mechanism** — a light-theme
> demo toggle was built and removed. Do not reintroduce one ([`[UIC §3.17]`](../UIConventions.md)).
>
> ⛔ **Not built, and owned elsewhere:** live streaming into the traces (**`FW-081`**) · the reusable
> `gauge-trace-chart` control (**`FW-133`**) · the shared `info-grid` (**`FW-163`**) · the API client
> behind all of it (**`FW-132`**) · **the line context and profile** (**`FW-N15`**) · **the station-claim read** (**`FW-N16`**) · every dialog the rail opens. ⚠ *(This read "the FL2 and FL3 variants" until 7 Sep 2026; `D-55` retired them — there is one component and a four-row profile.)*
> **All data on the screen is static placeholder data.** The spool card sits at one fixed milestone —
> its ladder, escalation and live weight stream are **`FW-202`'s**.
>
> ⚠ **The rail is not a transcription of the mockup's action bar**, which reads *Die Change* and
> *Complete Run*. The rail above is what was agreed — `[UIC §3.6]`.
>
> ⚠ **The mockup's `.fwn-demo` bar is deliberately not built** — it is mockup scaffolding,
> `[UIC §3.7]`.
>
> **What this story still owes** is the real data path and the machine-driven contract — the eight
> hardcoded builders replaced by a mapper, and the four-row profile consumed rather than branched on.
> ⚠ **Not "the FL2/FL3 variants"**, which `D-55` retired on 7 Sep 2026. The card below is
> the contract from `[TB]`.

## 1. What to build

**Hours:** 32 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

**As an** FL1 operator,
**I want** one screen showing the run live with every action one click away,
**So that** I never leave the monitor to record something.

**Acceptance Criteria** — 🟡 marks what the skeleton renders; an unticked box is still owed:
- [ ] `dashboard-3-active-run` built from `../mockups/dashboard_3_active_run.html`, plus the FL3 variant `dashboard_3_active_run_fl3.html` — 🟡 **FL1 renders; FL3 does not exist**
- [ ] Header shows Order / Alpha / Alloy / Target Gauge / Target Width — 🟡 **three of five.** The run context bar carries Order, Alpha and Alloy; **Target Gauge and Target Width appear only as the trace panels' target labels**, not in the header
- [ ] **Action bar grouped by intent** — *Run events* (SPC Checkpoint · WIP Reject) · *Go to* (Die Change · Check Out Rod, **disabled once footage > 0**) · *Run control* (Pause run · **Complete Run**, confirmation-gated) — 🟡 the entries render as a left rail (`[UIC §3.6]`), **ungrouped and all inert**; the footage-based disable is behaviour and does not exist
- [ ] **FL1 has no Roll Adjust** (`FR-107` — one mill). **FL3 adds it** (`FR-108`) — ⛔ **CONTRADICTED BY THE BUILT RAIL, and one of the two is wrong.** `buildNavActions()` puts `rollAdjust` in the FL1 rail as entry 2 of 7. `FR-107` gives FL1 six buttons *"with **no Roll Adjust** and no edger controls"*, `FR-108` adds it for FL3 and `FR-109` for FL2, and `[SCR]`'s Appendix B was corrected on 27 Aug 2026 to say the same. ⚠ Note `OI-11` (Roll Adjust line applicability) is still carried as open in `[REQ]`'s open-items line, so this is not purely a build slip. **Decide before the rail becomes active** — while every entry is inert the discrepancy is invisible, and it stops being invisible the moment `(itemClick)` is bound
- [x] **No Log Weld button on any line** — Dashboard 4 was retired 1 Aug 2026 and the weld is captured at pre-check-in
- [ ] After N consecutive out-of-spec readings (**configurable, default 5**) → auto-prompt SPC toast
- [ ] SignalR drop → reconnect banner with cached state
- [x] **Dashboards 13 and 14 are not built** — descoped 4 Aug 2026, both mockups deleted
- [ ] ⭐ **Screen state on `signal()` / `computed()`, no manual `detectChanges()`** *(folded in 7 Sep 2026)* — ⛔ the built screen holds **13 plain fields** under `OnPush`, calls `changeDetectorRef.detectChanges()` in four handlers, and mutates `table.isExpanded` and `alert.isAcknowledgeable` in place. ⚠ **It works only because nothing is async yet**; the first live stream makes it intermittent. ✅ `spool-notification.component` already uses `input.required()` / `output()` — follow it

### Added by `D-55`, 7 September 2026 — the machine-driven contract

⚠ **These supersede the "plus the FL3 variant" framing in the criteria above.** Where the two
disagree, these win; the originals are kept as the audit trail.

**Line-neutral — true on FL1, FL2 and FL3:**
- [ ] **One component serves all three lines.** ⛔ No per-line component, template or `@if` branch —
      the only admissible per-line input is `LINE_PROFILES[machineName]` plus the API and hub payload
- [ ] **The line comes from the URL segment** (`#/flat-wire/home/fl1|fl2|fl3`) and from nowhere else
      on the screen. Route and resolver are **`FW-N15`**'s; consume them
- [ ] **The material shown is the claim at that line's station** — **`FW-N16`**'s read. ⛔ A station
      whose `CoilNo` equals its own `WIPStation` is **idle**; rendering it as material displays a
      station name where an operator expects a rod or spool number
- [ ] **The claim transitions are honoured exactly:** checkout **Mode A**, **Mode B** and **run**
      completion return the screen to idle; ⛔ **checkout Mode P and coil completion leave it
      unchanged**. Driven off `RodCheckoutEvent.Mode`, not a re-read
- [ ] **Both trace panels are titled `Gauge` and `Width` on every line**, one axis, one source path
- [ ] **The Components card renders from the run's pass schedule** — ⛔ no per-line component list in
      code. This is what lets one card show draw boxes on FL1, three finishing stands on FL2 and both
      groups on FL3
- [ ] **One Order Information column set for all three lines**, resolved through
      `AppConfigService.getContentData()`. ⚠ The set itself is **`Q3`** and unfinalised
- [ ] **Rod Information is one column set** shared by FL1 and FL3
- [ ] ⛔ A `null` gauge or width reading renders a **no-measurement** state — **never a flat line at
      target**, which shows an operator a perfectly in-spec measurement of nothing. *(This is
      `FW-181`'s rule, now on the shared path rather than an FL2 variant.)*
- [ ] `204 No Content` from `GET /run/active?line=` renders the **idle** state, never an error banner
- [ ] Loading, idle, empty and error states are built **once** and are line-neutral
- [ ] Out-of-spec auto-prompt after N consecutive readings, N from the response's `outOfSpec` block
      (`consecutiveReadings`, `autoPromptEnabled`) — ⛔ never a client-invented default
- [ ] `PS-1100-FL1-003` is removed. Happy-path fixtures are `PS-1100-FL1-001` / `-FL2-001` / `-FL3-001`
- [ ] ⛔ **Two departures from the mockups are recorded here and in [`[UIC §5]`](../UIConventions.md)** —
      the per-line trace titles (*"Final gauge · post S3"*) and the per-line Components rows are both
      superseded. The mockups remain the pixel authority for everything else

**The four per-line rows — the whole configuration surface:**

| # | Row | FL1 | FL2 | FL3 |
|---|---|---|---|---|
| 1 | Material panel | Rod Information | **Spool** Information | Rod Information — *FL1's columns* |
| 2 | Centre status card | Payoffs | **Material flow** | Payoffs |
| 3 | Action set | `FR-107` | `FR-109` | `FR-108` |
| 4 | Spool-completion overlay | Present (`FW-202`) | Absent | Absent |

**Machine-specific criteria that must remain:**
- [ ] **FL1** — no edger row, spool-completion overlay present, `Complete Run`. ⛔ **Roll Adjust is
      `OI-11`** and is the one profile cell not yet decided — see the criterion above
- [ ] **FL2** — material-flow card (spool in: alpha, source rods, consumption, lb remaining · coil
      out: alpha, take-up, fill, skid + coil-of-N), Spool Information grid, `Complete Coil`,
      includes Roll Adjust. Components card shows **exactly three** FM2 rows with edgers on S2 and
      S3 only and ⛔ **no separate "8″ Roller"** (`D-26`) — *from the pass schedule, not from code*
- [ ] **FL3** — Payoffs, Rod Information, `Complete Run`, includes Roll Adjust; hybrid badge from
      `RouteMode`; ⛔ **no intermediate spool alpha generated or displayed**; FL1 and FL2 shown
      unavailable while it runs

⚠ **What this story still cannot demonstrate, and it is not this story's fault.** On FL2 the station
claim will read **idle through a real run**, because no spool check-in procedure exists (`OI-115`) —
see `FW-N16` §2. And the FL1 chain needs `FW-230`+`FW-231` (`G54`). ⛔ **Do not treat a green FL2
render as evidence that FL2 works.**

**Rate-card basis:** new dashboard 24 h + FL3 screen variant 8 h = 32 h (§2)
**Dependencies:** FW-133, FW-162, FW-163, FW-081, FW-164
**Blockers:** **`PLC-Q02`** · configurable out-of-spec N

---
