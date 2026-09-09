# FL1 Spool Completion Notification — Story Backlog

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — created. 63 stories, first pass.
**Document Type:** Story-level backlog, derived from the specification and the built code
**Status:** Active
**Owner:** Frontend (Angular `flat-wire`)
**Shortcode:** — *(derived; **not citable as a requirement**)*
**Part of:** `50-frontend/spool-notification/` — folder index: [`Orchestration.md`](Orchestration.md)

---

> **Requirements are cited, never restated.** Every `§n` / `R-n` / `S-n` / `A-n` / `B-n` / `D-n`
> resolves to
> [`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md).
> Read the rule there; this file says only what is built, what is missing and what to do.
>
> **`SCN-##` is an analysis id, not a work item id** — see [`Orchestration.md`](Orchestration.md).
> Owning tasks: [`FW-N02`](../../10-requirements/features/FS-11-spool-lifecycle-fl2.md) (Part A),
> [`FW-202`](../../10-requirements/features/FS-08-active-run-monitoring.md) (Part B).
>
> Code paths are relative to `c:\UAL\Second-Branch\ual-angular\projects\flat-wire\src\lib\`.

**Statuses:** `Completed` · `Partially Implemented` · `Not Started` · `Blocked` ·
`Needs Clarification` · `On Hold` (paused by decision, **excluded from the sequence**) ·
`Not Applicable`.

---

## EPIC A — Part A, weight milestone alerts (`§2`) · `FW-N02` · 18 stories

| Story | Req | Scenario | Status | Current | Gap | Required change | Blocked by | Pri |
|---|---|---|---|---|---|---|---|---|
| **SCN-A1** | `§2.1` M1, `A-1`,`A-2` | 75 % milestone | Not Started | `resolveSpoolMilestone` returns `Info` for **any** value below 90, including 0 % | No 75 % boundary; no "below M1" state | Consume the server milestone; return `null` below 75 | `Q96`, `Q18` | High |
| **SCN-A2** | `§2.1` M2 | 90 % milestone | Partially Implemented | `>= 90 → Warn` — the one correct boundary | Copy and the *remaining* value do not exist | M2 title/lead in content-data; populate `remaining` | — | High |
| **SCN-A3** | `§2.1` M3 | 100 % / target reached | Partially Implemented | `percentComplete === SPOOL_SCALE_TICKS.FULL → Success` | Strict equality on a continuous value — **M3 practically unreachable** | `>= 100 → Success`, **no upper bound** while `A4` is held; **delete the `> 100 → Danger` branch** | — | **Critical** |
| **SCN-A4** | `§2.1` M4 | Over target | **Not Started** — ✅ released 8 Sep 2026 | `> 100 → Danger` | No margin, and fires even when M3 *was* acknowledged | **Build it.** `SPOOL_SCALE_TICKS.OVER = 101`, gate on M3-unacknowledged. Land with the M3 half in one pass | `Q18` ✅ closed — M4 confirmed wanted | High |
| **SCN-A5** | `R-3`,`R-4`,`A-5`,`A-6`,`A-8` | Acknowledge arms the next | Partially Implemented | `acknowledgeSpool()` sets one boolean, never reset | No ladder state, no arming, no close-below | Ladder state `{shown, acked:Set, spoolKey}` | `Q96` | **Critical** |
| **SCN-A6** | `R-6`,`A-7` | Escalate in place | Not Started | — | No escalation path | Re-dress the same card; never a second instance | `Q96` | High |
| **SCN-A7** | `R-5`,`A-4` | Live update while unacknowledged | Not Started | `SpoolReading` is a static pre-formatted snapshot | No live source bound | Bind to the server progress payload | `Q96` | High |
| **SCN-A8** | `R-7`,`R-8`,`A-3` | Non-blocking | ✅ **Completed** | Inline `@if` + `.floating-popover`; no backdrop, no focus trap; `CommonPopupService` deliberately avoided (`[UIC §3.16]`) | None — `A-3` untestable until the card renders | ⛔ **None. Protect this** | — | — |
| **SCN-A9** | `R-10`, `§2.3`, `§4.6` Declined | Docked indicator | Partially Implemented | Pill exists: label, %, mini bar, weight, *Complete spool* | No re-expansion; no *acknowledged* / *target reached* note | Wire re-expansion to `A6`; add the note | — | Medium |
| **SCN-A10** | `R-9`,`A-10` | Per-spool re-arm | Not Started | `isSpoolAcknowledged` never reset — not in `clear()`, not on line change | `A-10` fails; navigating off FL1 and back returns a spuriously acknowledged card | Key state to spool identity; reset on new spool **and** in `clear()` | `Q106` | High |
| **SCN-A11** | `§3.2`, `D5`, `D14` | Target resolution | **Blocked** — ⚠ **on `Q98` only** | None. The mockup passes the **withdrawn** `targetLb: 2000` | Source field now identified: the **order**, *Max Wgt of Spool* for the max plus a new matching min | Resolve server-side; render nothing when null | **`Q98`** only — `Q18` closed, `Q33` no longer withholding | **Critical** |
| **SCN-A12** | `§4.2`#6, `[SIG §5.5]` | Consume server milestone + progress payload | **Blocked** | Client implements 5 of the hub's 20 members; neither Part A event among them | Both events **unpublished** | Backend publishes; client adds the observables | `Q96` | **Critical** |
| **SCN-A13** | `R-2`, `§2.3` | Card presentation | Partially Implemented | Weight + target ✅, bar with 75/90 ticks ✅, scale ✅, `updatedAt` ✅, single Acknowledge ✅, `cells` loop ✅ | `cells` never populated — six content-data keys orphaned | Build the cells in the mapper | `Q103` (the 6th cell) | Medium |
| **SCN-A14** | `R-11`,`A-9` | Acknowledgement audit | **Not Started** — ✅ unblocked 8 Sep 2026 | Nothing recorded | No endpoint yet — but the store is decided | Write to the **existing run-event stream**; ⛔ do **not** create a milestone record type | `Q20` ✅ closed | Medium |
| **SCN-A18** | `R-13`,`A-11` | Supervisor mirror of the unacknowledged M3 | **Not Started** — ➕ new, `Q20` | Nothing exists | Only the **unacknowledged 100 %** milestone mirrors; 75 % and 90 % never do | Raise to the supervisor view when M3 goes unacknowledged | `Q20` ✅ closed | Medium |
| **SCN-A15** | `R-12`,`S-14` | Thresholds are configuration | Not Started | `SPOOL_SCALE_TICKS` is a compiled constant | Not tunable without a release | Server-supplied; keep axis/accent coupled (`[UIC §3.16]`) | `Q96` | Medium |
| **SCN-A16** | `§2.3` | Escape does not acknowledge | ✅ **Completed** | No key handler exists | None | ⛔ **None. Do not add a handler** | — | — |
| **SCN-A17** | `§2.3` | Announced without interrupting | Needs Clarification | `role="status" aria-live="polite"`; pill `aria-live="off"` | Correct for M1–M3; **M4 danger also polite** | Possibly `assertive` at M4 | `Q100` | Low |

## EPIC B — Part B, stop confirmation (`§4.1`–`§4.4`, `§4.6`) · `FW-202` · 20 stories

| Story | Req | Scenario | Status | Gap | Required change | Blocked by | Pri |
|---|---|---|---|---|---|---|---|
| **SCN-B1** | `S-9`,`B-10`,`§6` | Durable prompt, re-delivered | Not Started | No subscription to event 11 | `spoolCompletionPromptDue$`; **subscribe before joining**; **idempotent** — re-delivery is specified, not a fault | — | **Critical** |
| **SCN-B2** | `S-1`,`S-2`,`B-1` | Armed by weight + confirmed stop | Not Started | Server-side; the client must never infer it | Render only what the server raises | `Q21`, test `C2` | **Critical** |
| **SCN-B3** | `S-3`,`B-2`,`B-3` | 5 s dwell, speed ≈ 0 | Not Started | The edge is dark — `TryMapLineState` returns `false` | Server-side. ⛔ Never promote speed ≈ 0 to a stop on the client | `Q21`, test `C2` | **Critical** |
| **SCN-B4** | `S-4`,`B-4`,`§6` | Latched weight | Not Started | — | Render `LatchedWeightLb` only; never substitute a `PayoffWeight` tick | `Q109` | **Critical** |
| **SCN-B5** | `S-5`,`B-7`,`§4.2`#2 | One prompt per stop event | Not Started | — | Dedupe by `runId` + stop timestamp | — | High |
| **SCN-B6** | `§4.6`,`S-15` | The question step | Not Started | No dialog | Build step 1 to `§4.6`'s priority order | — | **Critical** |
| **SCN-B7** | `S-10`,`B-9` | No Escape, no backdrop, no close | Not Started | ⚠ **The mockup violates this** — `FwModal` binds both | Build without them; do not inherit `fw-modal.js` | — | High |
| **SCN-B8** | `S-7`,`B-5`,`§4.2`#9 | Answer **No** | Not Started | — | `Answer:"No"` → **200 DECLINED**, not an error | — | High |
| **SCN-B9** | `S-6`,`B-6` | Answer **Yes** | Not Started | ⚠ Its destination screen does not exist — `G3` | Advance to the completion step | `G3` | **Critical** |
| **SCN-B10** | `S-8`,`B-8`,`§6` | Auto-dismiss on resume | Not Started | — | Handle event 12 `Answer:"AutoDismissed"` | — | High |
| **SCN-B11** | `§4.2`#12, `§4.6` | Over-target stop | Not Started | — | Inline warning **between question and choices** | — | Medium |
| **SCN-B12** | `§4.6` | Evidence footer | Not Started | — | Build; identity is the **carrier** — see `D6` | `Q103` | Medium |
| **SCN-B13** | `S-13`,`B-11`,`§4.6` Declined | Manual completion | Partially Implemented | Button always visible and inert; ⛔ **the availability condition has no transport** — `G-7` | Gate on line-not-running + target-reached; open the completion step | `Q97` | High |
| **SCN-B14** | `§4.2`#14,`§6`,`OI-75` | Multiple operators | Not Started | — | Event 12 closes the dialog on every FL1 terminal | `OI-75`, `Q108` | Medium |
| **SCN-B15** | `D3`, `§4.6` | Dialog must not scroll | Not Started | — | Scale to fit; ⛔ no `max-height`, no `overflow` | `Q101` | High |
| **SCN-B16** | `§4.2`#13, `§6` | Communications loss | Needs Clarification | The banner exists, but the manual fallback is unreachable — `G-7` | Ensure no prompt is synthesised client-side | `Q107` | Medium |
| **SCN-B17** | `§4.2`#7, `§6` | Suppression after a software pause | **Blocked** | Server-side (`FW-171`) | None client-side | `Q21` | Medium |
| **SCN-B18** | `§6` | Prompt left unanswered | Not Started | — | No timeout, no auto-close except resume | — | Medium |
| **SCN-B19** | `S-12` | Both outcomes audited | **Blocked** | ⛔ `FlatWireRun.PromptAnsweredBy` does not exist | Backend column | `Q105`, `FW-244` | High |
| **SCN-B20** | `§4.6` Result | Result step | Not Started | — | Build step 3, including the next carrier and the re-arm statement | — | High |

## EPIC C — weight verification (`§4.5`) · `FW-202` · 10 stories · all **Not Started**

> ⛔ **This whole epic is conditional on a weighing device that does not exist.** `Q30` (8 Sep 2026)
> confirms **no load cells on the take-ups or the payoffs**, and the only scale under discussion —
> `Q12`, answered *in principle* and referred to Bob S. and Shannon R. for **10 Sep 2026** — is at the
> **FL1 payoff**, not the take-up. `SCN-C1` builds the optional entry and degrades to the calculated
> weight; **`SCN-C2`–`SCN-C10` should not be scheduled until `OI-56`'s scale leg closes.** Nothing is
> withdrawn — see `[SpoolCompletionNotification.md §4.5]`.

| Story | Req | Scenario | Required change | Blocked by | Pri |
|---|---|---|---|---|---|
| **SCN-C1** | `S-16`,`B-12` | Optional scale entry | Build the entry | `OI-56`/`OI-38` — does a scale exist at all? | High |
| **SCN-C2** | `S-17`,`B-13` | Gross → net, variance | Tare from the system (`A2`), **not typed** | — | High |
| **SCN-C3** | `B-14` | Invalid scale input | Reject; clear variance; fall back to calculated | — | Medium |
| **SCN-C4** | `S-18`,`S-19`,`B-22` | Basis choice | Two-option control + a "will record" sentence | — | High |
| **SCN-C5** | `S-20`,`B-15`,`B-16`,`D4` | Tolerance ±2 % | ⛔ **Never disable commit on variance** — `FW-202` calls this *"the criterion most likely to be implemented backwards"* | `OI-56`, `Q99` | **Critical** |
| **SCN-C6** | `S-22`,`B-17`–`B-19` | Supervisor override | Reason + supervisor + PIN; **PIN never in the payload or stored** | `OI-56`/`OI-38` | High |
| **SCN-C7** | `S-23`,`B-20` | Remote approval | Request + log; does not block | `OI-75` | Low |
| **SCN-C8** | `S-25`,`B-21` | Variance corrected back inside | Recompute on every edit; the override requirement disappears | — | Medium |
| **SCN-C9** | `S-21` | Scale retained when calculated chosen | Always send `scaleWeightLb` when entered | — | Medium |
| **SCN-C10** | `S-24` | Override marked on the record | The result step surfaces it | — | Medium |

## EPIC D — the next spool carrier (`§4.7`) · `FW-202` · 7 stories

| Story | Req | Scenario | Status | Gap | Required change | Blocked by | Pri |
|---|---|---|---|---|---|---|---|
| **SCN-D1** | `S-26`,`D10` | Capture the next carrier | **Blocked** | Absent from `CompleteSpoolRequest` entirely | Add to the contract + UI | `Q42`, `Q104` | **Critical** |
| **SCN-D2** | `S-27`,`D11` | Typed and validated | **Blocked** | — | Validate against `Spool.SpoolNo`; ⛔ **not a drop-down** | `Q42` | High |
| **SCN-D3** | `S-28`, `§4.6` | Hard gate on commit | Needs Clarification | ⚠ Conflicts with `B-16` — `G-8` | Resolve the two gates | `Q99` | High |
| **SCN-D4** | `S-29` | Carrier already carrying material | Not Started | — | Server check; refuse **naming the spool it holds** | — | Medium |
| **SCN-D5** | `S-30` | Decline captures nothing | Not Started | — | Ensure the No path sends none | — | Medium |
| **SCN-D6** | `S-31`, `§4.6` | Carrier audited; identity shown | **Blocked** | ⛔ **No FL1 spool alpha before commit** — `G-4` | Show the **carrier**; the alpha only on the result | `Q103` | High |
| **SCN-D7** | `§4.7` note | Mandrel / core diameter | Not Applicable *(provisional)* | — | None unless `Q46` says otherwise | `Q46` | Low |

## EPIC E — labels (`§4.8`) · `FW-202` · 2 stories

| Story | Req | Scenario | Status | Required change | Blocked by | Pri |
|---|---|---|---|---|---|---|
| **SCN-E1** | `S-11`,`B-6`,`A5` | Print only after commit | Not Started | Trigger from the commit result; **two per spool, one per side** | — | High |
| **SCN-E2** | `§4.8`,`D12`,`D13` | Label content | **Blocked** | Backend / print work | `Q44` | Medium |

## EPIC F — Part C, short close (`§5`) · ⚠ no owning story · 3 stories

| Story | Req | Scenario | Status | Gap | Blocked by | Pri |
|---|---|---|---|---|---|---|
| **SCN-F1** | `§5`,`D7` | Short close as an unplanned stop | **Blocked** — ⚠ **on the 10-90 SOP only** | Nothing exists; the mockup's `targetMinLb` is parsed and never read | 10-90 SOP — `Q18` closed, so the customer **minimum** now has a source; ⚠ the SOP is **being revised**, not merely unlocated | High |
| **SCN-F2** | `§5`,`D8` | The spool always runs off | Not Applicable *(no UI)* | Operational, not a screen rule | — | — |
| **SCN-F3** | `§5.1`,`D9` | Mid-run coil break | **Blocked** | *"A run and stop model change, not a screen rule"* | `OI-25`, `G34`, 10-90 SOP | Medium |

## EPIC G — cross-cutting · 4 stories

| Story | Req | Scenario | Status | Gap | Required change | Blocked by | Pri |
|---|---|---|---|---|---|---|---|
| **SCN-G1** | `§4.6`,`§6`,`A3` | Machine status on screen | Not Started | No `LineStatus` (event 7) subscription — the prompt would appear over a header still reading *Running* | Subscribe event 7 | — | High |
| **SCN-G2** | `R-10` | Must not obscure the command bar or trace headers | Needs Clarification | `.floating-popover` is `bottom:50px`; the mockup uses `bottom:124px` to clear **its** bottom command bar. The Angular screen uses a **left** nav rail, so the offsets are not comparable — overlap with the traces card is unverified | Verify at 16:9. Composition is **not** taken from the mockup (`F-15`) | — | Medium |
| **SCN-G3** | `§1.2`, `§4.2`#11, `§10` | The FL1 completion-workflow screen | **Blocked** | ⛔ **No such screen exists.** The specification's own *"Known gap in the deliverables"* | Needs its own specification and screen | — | High |
| **SCN-G4** | `§1.3` | Ladder on FL2/FL3 | Not Applicable *(FL1 scope)* | ⚠ `§1.3` **contradicts** [`ActiveRunMonitor.md`](../../10-requirements/screens/ActiveRunMonitor.md) `§1.4a` row 4 | Out of scope; give `hasSpoolOverlay` its first reader so the seam holds | `Q19` | — |
