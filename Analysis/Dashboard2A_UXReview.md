# Dashboard 2A — Rod Pre-Check-in Station: UX & Structure Review

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 1, 2026
**Status:** Review — findings applied Jul 31, 2026. **Two of them were superseded by the 30 Jul client call and must not be re-applied as written** — see the superseded block in §6. A third (F2) is now fully resolved
**Subject:** [dashboard_2a_rod_precheckin.html](../Mockups/dashboard_2a_rod_precheckin.html) (2,630 lines)
**Grounded in:** [RodPreCheckin.md](../LatestDocument/RequirementDocuments/RodPreCheckin.md) · [phase-04](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md) · [00-foundations.md](../DevelopmentPlan/ShopfloorPlan/00-foundations.md) §0.2–0.4 · [back-matter.md](../DevelopmentPlan/ShopfloorPlan/back-matter.md) G1–G20 · [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md) · [APIContracts.md](../DevelopmentPlan/APIContracts.md)

---

## 0. Disposition (Jul 31, 2026)

| Applied to the mockup | Applied to the contracts | Logged, not built | Deferred | Withdrawn |
|---|---|---|---|---|
| F3, F4, F7, F8, F9, F10, F5, F17, F14, F15 | **F2** | F1 → **Q76** + **G21** · F4's residual → **Q77** · F2's residual → **Q72** item 3 · F11 → Q66 · F13 → Q76 | **F12** (footer/layout re-plan) | **F16** |

**F16 is withdrawn.** I recorded the header comment's `bays-row 294` as inconsistent with the CSS
`min-height: 292px`. Re-reading it, the comment says *"bays-row 294 (min 292, auto-grows)"* — 294 is
the rendered height and 292 the floor, which is coherent and correctly labelled. Not a defect.

**Verification** — headless Chrome, 6 viewport heights (620/700/820/900/1024/1080) × 6 bay states:
no page overflow, no element escaping its parent, 14px floor held, both bays' fact columns aligned.
21 behavioural assertions pass, including the two that would have failed before: un-staging the
Payoff 1 queue row now releases Payoff 1 (was Payoff 2), and the staged partial rod `R00040` now
reads a 50% bar (was 100%).

---

## 1. What the screen gets right

Worth stating plainly, because most of it should survive any re-plan.

- **The two bays are true peers, with one renderer** ([1589](../Mockups/dashboard_2a_rod_precheckin.html#L1589)). The cold-start crash this fixed was real, and the fix is structural rather than defensive. `activeBayNo()`/`otherBay()` mean nothing in the screen hard-codes bay 1 as the running side — including the weld modal's own labels ([2435-2436](../Mockups/dashboard_2a_rod_precheckin.html#L2435-L2436)).
- **Weight-bar colour on absolute pounds, not percent bands** ([1531-1536](../Mockups/dashboard_2a_rod_precheckin.html#L1531-L1536)). The reasoning in the comment is correct and the percent ladder it replaced was genuinely backwards. Keep it, and keep the comment.
- **The order is resolved from the rod, never typed** ([2015-2033](../Mockups/dashboard_2a_rod_precheckin.html#L2015-L2033)). Cold start showing no order is the honest state, and it is what makes the first rod validatable.
- **Two sequence columns with a neutral deviation marker** ([861-869](../Mockups/dashboard_2a_rod_precheckin.html#L861-L869), [1796-1808](../Mockups/dashboard_2a_rod_precheckin.html#L1796-L1808)). Plan-vs-Run as data rather than as a warning is the right reading of *authorised, not enforced*.
- **Redundant coding on the inspection pills** — `::before` glyph plus fill ([578-584](../Mockups/dashboard_2a_rod_precheckin.html#L578-L584)) — and a real focus ring on the card-divs ([537-540](../Mockups/dashboard_2a_rod_precheckin.html#L537-L540)). The keyboard contract for `role="radio"` divs is actually supplied ([2250-2262](../Mockups/dashboard_2a_rod_precheckin.html#L2250-L2262)), including arrow keys, which is more than most such mockups do.
- **The modal focus trap and focus restoration** ([2512-2527](../Mockups/dashboard_2a_rod_precheckin.html#L2512-L2527), [1488-1494](../Mockups/dashboard_2a_rod_precheckin.html#L1488-L1494)) are correct and complete.
- **The station simulator cycles the whole station including cold start** ([2529-2533](../Mockups/dashboard_2a_rod_precheckin.html#L2529-L2533)). Making the broken state reachable in review is why it got fixed.

The critique below is therefore about a screen that is already past the obvious problems.

---

## 2. Findings

Ordered by consequence on the floor. "Mockup" = what the file does; "Spec" = what a controlling doc says.

| ID | Sev | Lens | Finding | Operator consequence | Proposed change |
|---|---|---|---|---|---|
| **F1** | **High** | 9 · State | **`UX_RodStaging_Bay` is keyed on `(LineId, PayoffPosition)`** ([Schema:157](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md)) while `CK_RodStaging_LineId` admits both `FL1` and `FL3` ([Schema:152](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md)) — and the mockup's own working assumption is that **FL3 is FL1 running hybrid, same physical VPS, same station** ([2480-2487](../Mockups/dashboard_2a_rod_precheckin.html#L2480-L2487), hence `STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"}`). `(FL1,1)` and `(FL3,1)` are distinct index entries, so two different rods can be `Staged` on one physical bay with every constraint satisfied. | Two bundles recorded on one payoff. The invariant the table exists to defend — "one rod per payoff bay" — does not hold across the FL1/FL3 pair. Weld genealogy then attributes output to whichever row a query happens to pick. | Decide whether FL1/FL3 is one station or two. If one: key the index on the **station** (`FL1PO`), not `LineId`, or add a persisted station column and index that. If two: `FL3PO` must exist, and the mockup's assumption is wrong. Either way this is a **new gap**, not covered by G20. |
| **F2** | **High** | 3 · 9 | **The entire `BLOCKED` bay state is unreachable by contract.** The mockup implements it fully — border ([148](../Mockups/dashboard_2a_rod_precheckin.html#L148)), chip ([163-164](../Mockups/dashboard_2a_rod_precheckin.html#L163-L164)), bay branch ([1629-1638](../Mockups/dashboard_2a_rod_precheckin.html#L1629-L1638)), sole WIP action ([1574-1576](../Mockups/dashboard_2a_rod_precheckin.html#L1574-L1576)), queue row ([1768-1774](../Mockups/dashboard_2a_rod_precheckin.html#L1768-L1774)), weld-strip branch ([1719-1721](../Mockups/dashboard_2a_rod_precheckin.html#L1719-L1721)), sim state ([2594-2603](../Mockups/dashboard_2a_rod_precheckin.html#L2594-L2603)). But `POST /staging/rod` returns **422 and writes nothing** on any inspection `Fail` ([APIContracts:930](../DevelopmentPlan/APIContracts.md)), and the schema says outright: *"nothing currently writes such a row… the `Blocked` state is unreachable in practice"* ([Schema:141](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md), Q72). | The worse half is physical: bundles are **not unbanded until positioned at the payoff** ([RodPreCheckin.md:30](../LatestDocument/RequirementDocuments/RodPreCheckin.md)), so a rod that fails inspection is *already on the bay* while the system holds no record of it. The bay reads `NOT STAGED`, the wizard offers it as "Empty — available", and a second bundle can be staged into an occupied position. | **The mockup is right and the contract is wrong.** Commit the staging row before the inspection gate (or on failure), so the bay stays occupied until WIP Rejection releases it. Resolve Q72 in that direction and change the 422 to a 201-with-blocked-state. Until then the screen is modelling a state the API cannot produce. |
| **F3** | **High** | 1 · 3 | **Queue "Unstage" un-stages the wrong bay.** The handler discards the alpha it was given ([1864-1866](../Mockups/dashboard_2a_rod_precheckin.html#L1864-L1866): `data-unstage` is set but `openPreCheckout()` is called with no argument), so the fallback picks `bay2` first ([2346](../Mockups/dashboard_2a_rod_precheckin.html#L2346)), and the commit handler defaults to `pcoBay \|\| 2` ([2400](../Mockups/dashboard_2a_rod_precheckin.html#L2400)). Both bays can legitimately hold staged rods (stage both from cold start — nothing prevents it). | Operator clicks Unstage on the Payoff 1 row and releases **Payoff 2's** rod. The modal even shows the wrong alpha in its subtitle, so the mis-selection is confirmable but easy to miss under time pressure. | Pass the alpha through and resolve the bay from it; drop both positional fallbacks. In the port, make the bay a required input on the pre-check-out component — no defaulting. |
| **F4** | **High** | 5 · 3 | **A welded rod can be un-staged from the queue.** `q.status === "welded"` renders an Unstage button ([1778-1780](../Mockups/dashboard_2a_rod_precheckin.html#L1778-L1780)), and the guard admits it because welded is a *flag on a `Staged` row*, not a status ([2347](../Mockups/dashboard_2a_rod_precheckin.html#L2347)). The blocked row was correctly stripped of this control; the welded row was not. | The rod is physically induction-welded to the rod in the mill. "Releasing the bay and returning it to inventory" ([1160](../Mockups/dashboard_2a_rod_precheckin.html#L1160)) is impossible, and the pre-check-out modal's consequence list never mentions a weld. `WLD011` (supervisor reversal of a weld) is **explicitly unspecified** ([RodPreCheckin.md:182](../LatestDocument/RequirementDocuments/RodPreCheckin.md)). | Remove Unstage from welded rows and from a welded bay. If a weld genuinely needs reversing, that is `WLD011` and needs its own specified, supervisor-gated path — not the un-stage button. |
| **F5** | Med | 2 · 7 | **The staging wizard obscures the urgency that triggered it.** The modal is 760px wide, vertically centred, over a 45% black scrim ([410-423](../Mockups/dashboard_2a_rod_precheckin.html#L410-L423)) — it lands squarely over the bays-row and the weld strip. The modal carries **no live weight**. | The operator opens the wizard *because* Payoff 1 is draining. While in it, the running weight, the bar colour and a `WELD NOW` escalation are all behind the scrim. On a glare-lit panel that is effectively invisible. | Put a compact live weight + threshold ticker in the modal header (`Payoff 1 · 2,840 lb · WELD SOON`). Cheap, and it keeps the reason for the task in view while doing it. |
| **F6** | Med | 1 | **Step 2 is a forced no-op on the hot path.** Staging from the queue passes only the alpha ([1861](../Mockups/dashboard_2a_rod_precheckin.html#L1861)), so `preferBay` is absent and nothing is pre-selected ([1943-1945](../Mockups/dashboard_2a_rod_precheckin.html#L1943-L1945)). In the steady state exactly one bay is free, so the operator is shown one enabled card and one disabled card and must still select + Next ([2130](../Mockups/dashboard_2a_rod_precheckin.html#L2130)). | 8 interactions on the primary path, 2 of them choosing between one option and a disabled one — with gloves, under time pressure. | Auto-select whenever exactly one bay is free, regardless of entry point, and render step 2 as a stated fact with a change affordance rather than an empty choice. Keeps `PCI006` capture; removes the dead choice. |
| **F7** | Med | 2 · 7 | **The staged bay's weight bar lies, and means something different from the active bay's.** A staged bay is hard-pinned to a 100% green bar ([1634-1638](../Mockups/dashboard_2a_rod_precheckin.html#L1634-L1638)) while showing the *remaining* pounds. For the partial rod in the fixtures (`R00040`: 3,980 lb remaining of 7,900 net) that is a **full green bar over a half-consumed bundle**. | The one judgement this screen exists to support — *will the bundle on the idle bay carry me past the next weld?* — is made against a bar that reads full for every staged rod. | Scale the staged bar to `remaining / net` and keep the "not yet drawing" label. Same element, same semantics, both states. |
| **F8** | Med | 3 · 4 | **An authorised deviation disappears the moment the rod is checked in.** The override branch sits in the `else if` chain after `state === "active"` ([1667-1694](../Mockups/dashboard_2a_rod_precheckin.html#L1667-L1694)), so an active bay only ever renders weld alerts. Spec is explicit: the bay *"keeps showing 'Off-schedule — authorised by …' for as long as the rod is there"* ([RodPreCheckin.md:145](../LatestDocument/RequirementDocuments/RodPreCheckin.md), and again at [:112](../LatestDocument/RequirementDocuments/RodPreCheckin.md)). A checked-in rod is still there. | The off-schedule/out-of-sequence authorisation vanishes at exactly the point it starts mattering — while the deviating rod is actually running. Nothing on screen says this run was authorised. | Render the override as a persistent second line on the bay card, independent of the alert slot, for `staged` **and** `active`. Note the flags are never set on an active bay in any sim state, so this path is untested. |
| **F9** | Med | 8 | **The two smallest touch targets are the most-used control and a safety acknowledgement.** `.btn-sm` is 36px ([370](../Mockups/dashboard_2a_rod_precheckin.html#L370)) and carries every queue action — Stage, Unstage, WIP Rejection. `.cf-check`, the `PRC014` "I confirm the rod on the payoff is physically this rod" control, is **22px** ([616-622](../Mockups/dashboard_2a_rod_precheckin.html#L616-L622)). Everything else on the screen holds a 44px floor. | Mis-taps on the primary queue action; a legally-significant physical-identity confirmation sized for a mouse, not a gloved finger. | Raise both to 44px. The queue rows have the height for it; the carry-forward panel certainly does. |
| **F10** | Med | 1 · 6 | **`resolveAlpha` fires on every `input` event** ([2218](../Mockups/dashboard_2a_rod_precheckin.html#L2218)). A barcode gun delivers `R00043` as a fast keystroke burst, so the operator gets "Invalid rod alpha" then "Rod not found" flashing through the first five characters before the sixth resolves. | Error states strobe on every scan. Operators learn to ignore the error region — which is where the off-schedule and out-of-sequence notices also appear. | Debounce, or gate validation on a complete `R#####` token / Enter. The station's own scan box already does the right thing ([2477](../Mockups/dashboard_2a_rod_precheckin.html#L2477)). |
| **F11** | Med | 4 | **The supervisor PIN is validated for presence only** ([2116](../Mockups/dashboard_2a_rod_precheckin.html#L2116)) and the commit proceeds locally ([2308-2316](../Mockups/dashboard_2a_rod_precheckin.html#L2308-L2316)). There is no error slot in `.sv-panel` for a rejected credential. Whether the PIN checks against the login service or a separate supervisor store is **still open** ([APIContracts:893](../DevelopmentPlan/APIContracts.md), from Q66). | A wrong PIN is discovered only when the POST fails, with the wizard already dismissed and no obvious way back to the same context. | Verify server-side before accepting the commit, and add a rejected-credential state to the panel. Sequence this behind the Q66 decision. |
| **F12** | Med | 2 | **The footer spends 74px (7% of the budget) on demo scaffolding and duplicated identity.** `footer-actions` contains *only* the simulator ([896-914](../Mockups/dashboard_2a_rod_precheckin.html#L896-L914)); strip it for production and the right half is empty. Of the four stamps, Operator and Timestamp are already in the shared topbar and hard-coded in three places here (noted at [69-70](../Mockups/dashboard_2a_rod_precheckin.html#L69-L70)). | The queue — the only flexible region, and the thing the operator scans to plan the next hour — is squeezed by a strip whose production content is a station code and a "1 of 2" count. | Fold `FL1PO` and bays-occupied into the header, delete the footer region, and give the ~86px to the queue (≈5 more visible rows). See §3. |
| **F13** | Low-Med | 3 | **FL1/FL3 toggle relabels without reloading.** It updates the badge, station stamp, queue label and modal subtitle ([2489-2503](../Mockups/dashboard_2a_rod_precheckin.html#L2489-L2503)) but not the bays or the queue — and because `orderIsOffLine` reads `CURRENT_LINE` ([1370-1373](../Mockups/dashboard_2a_rod_precheckin.html#L1370-L1373)), toggling silently reclassifies already-staged rods as off-schedule with no visual change. | The FL3 tab asserts FL3 while showing FL1's material. Ambiguous whether this is a view filter or a line switch. | Resolve with F1. If one station, the toggle selects **route mode** and the bays are shared — say so. If two, reload everything on switch. |
| **F14** | Low | 2 | **Cold start renders 8 sticky column headers over an empty table.** `renderQueue` returns after showing the empty note ([1822-1829](../Mockups/dashboard_2a_rod_precheckin.html#L1822-L1829)) but `.info-table-wrap` stays in the DOM ([854-873](../Mockups/dashboard_2a_rod_precheckin.html#L854-L873)). | Minor, but cold start is the first thing anyone sees. | Hide `.info-table-wrap` when no order is established. |
| **F15** | Low | 2 · 10 | **Peer bays don't align.** `.bay-facts` uses `grid-template-columns: repeat(5, auto)` with `justify-content: start` ([194](../Mockups/dashboard_2a_rod_precheckin.html#L194)), so column widths follow content and the two side-by-side cards' fact rows land at different x-positions — and the fact *labels* differ by state ([1624-1654](../Mockups/dashboard_2a_rod_precheckin.html#L1624-L1654)), so this is the normal case, not an edge one. | Undercuts the peer-bay design the screen is built on; the eye can't scan across. | `repeat(5, 1fr)`, or a fixed label column. |
| ~~**F16**~~ | — | — | ~~The documented height budget is internally off by 2px.~~ **WITHDRAWN** — the comment reads *"bays-row 294 (min 292, auto-grows)"*, which correctly distinguishes the rendered height from the CSS floor. Not a defect; I misread it. | — | None. |

**No findings** on lens 6 beyond F10 — the mockup has no live channel to critique, and §0.4's split (batched `PayoffWeight` vs unbatched `PayoffStateChanged`) is already correctly specified in [phase-04:74](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md). Carried into §5 as a port constraint rather than a defect.

---

## 3. Proposed layout

Five regions become four. The change is small on purpose: the current IA is sound, and the win is reclaiming the footer for the queue (F12) plus the two card fixes (F7, F8).

**Height budget** — measured, not assumed, same discipline as the current file:

| Region | Now | Proposed | Note |
|---|---|---|---|
| app bar (injected) | 70 | 70 | unchanged |
| header | 78 | 66 | absorbs station code + bays-occupied; drops the clock (topbar has it) |
| bays-row | 294 (min 292) | 300 (min) | +8 for the persistent override line (F8) |
| weld strip | 96 | 88 | text-only tightening |
| queue | ~320 (flex) | **~420** (flex) | +100 ≈ 5 more rows |
| footer | 74 | — | removed (F12) |
| gaps | 5 × 12 = 60 | 4 × 12 = 48 | one fewer region |
| padding | 2 × 16 = 32 | 32 | |
| **total** | **1024** | **1024** | queue absorbs the remainder |

### Primary state — one bay drawing, one free

```
┌ FL1 │ Rod Pre-Check-in Station · VPS      [FL1][FL3]  FW-00421 ●RUNNING  FL1PO · 1 of 2 ┐
├──────────────────────────────────┬──────────────────────────────────────────────────────┤
│ PAYOFF 1              ● ACTIVE   │ PAYOFF 2                          ○ NOT STAGED       │
│ R00042   1100 · F · 0.375"       │                                                      │
│ 2,840 lb  33% remaining          │            ╭───╮   Not staged — load the next rod     │
│ ███████░░░░░░░░░░░░░░  (red)     │            │ ◎ │   when Payoff 1 falls below 3,000 lb │
│ Net 8,500 │ RUN-0418 │ 06:12 │ J.Alvarez │ ✓  │            ╰───╯                         │
│ ⚠ WELD SOON — stage Payoff 2 before 2,000 lb │                                          │
│ [Open active run ›] [Check out rod]          │ [+ Pre-check-in rod]                     │
├──────────────────────────────────┴──────────────────────────────────────────────────────┤
│ ⚡ Weld readiness · P1 2,840 lb (33%) · P2 not staged. Stage before 2,000 lb.            │
│                                          [Mark as welded (disabled)] [Weld event log]   │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ FL1 · Order FW-00421 · 1100 · F · 0.375" · 1 staged · 3 available · 4 on order          │
│                                                    [Scan rod alpha…............] [Find] │
│ Plan │ Run │ Rod no │ Diameter │ Gross wt │ Payoff │ Status          │                  │
│  1 ▸ │  —  │ R00043 │  0.375"  │ 8,780 lb │   —    │ Available       │ [  Stage →  ]    │
│  2   │  —  │ R00044 │  0.375"  │ 8,810 lb │   —    │ Available       │ [  Stage →  ]    │
│  3   │  —  │ R00045 │  0.375"  │ 8,690 lb │   —    │ Available       │ [  Stage →  ]    │
│  4   │  —  │ R00040 │  0.375"  │ 8,240 lb │   —    │ ⚠ Partial·4,120 │ [  Stage →  ]    │
│      │     │        │          │          │        │                 │  ← ~5 more rows  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Cold start — no order, both bays empty

```
┌ FL1 │ Rod Pre-Check-in Station · VPS      [FL1][FL3]  Order —   ○IDLE   FL1PO · 0 of 2 ┐
├──────────────────────────────────┬──────────────────────────────────────────────────────┤
│ PAYOFF 1          ○ NOT STAGED   │ PAYOFF 2                          ○ NOT STAGED       │
│        ╭───╮                     │            ╭───╮                                     │
│        │ ◎ │  No material on this line. Pre-check-in the first rod here, or go straight │
│        ╰───╯  to rod check-in — staging is only needed to set up a weld.                │
│ [+ Pre-check-in rod] [Go to rod check-in ›]   │ [+ Pre-check-in rod] [Go to check-in ›] │
├──────────────────────────────────┴──────────────────────────────────────────────────────┤
│ ⚡ No material on either payoff. Pre-check-in a rod, or go straight to rod check-in.     │
│                                          [Mark as welded (disabled)] [Weld event log]   │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ FL1 · Order — · no order yet — scan the first rod to load its order                     │
│                                                    [Scan rod alpha…............] [Find] │
│ ⓘ No order is running on this line. Scan or pre-check-in the first rod — its order is   │
│   resolved from planning_routings, and the rest of that order's rod appears here.       │
│   ── table hidden entirely (F14): no headers over an empty body ──                      │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Both bays occupied — station full

```
│ PAYOFF 1              ● ACTIVE   │ PAYOFF 2                     ● PRE-CHECKED-IN · WELDED│
│ R00042   1100 · F · 0.375"       │ R00045   1100 · F · 0.375"                            │
│ 2,840 lb  33% remaining          │ 8,350 lb  100% — not yet drawing                      │
│ ███████░░░░░░░░░░░░░  (red)      │ ████████████████████  (green)                         │
│ ⚠ WELD SOON …                    │ ⓘ Welded — transition at 0 ft remaining on Payoff 1   │
│                                  │ ⚠ Authorised by 4471 — out of planned sequence  ← F8  │
│ [Open active run ›] [Check out]  │ [Proceed to check-in ›]  ← no Unstage on welded (F4)  │
├──────────────────────────────────┴──────────────────────────────────────────────────────┤
│ Queue: ⚠ Both bays occupied — check in or un-stage first.                                │
│        Scan stays ENABLED for lookup; Stage buttons disabled. (see F17 note below)       │
```

> Deliberate change in the last panel: the current file disables the scan box entirely when the station is full ([1855-1856](../Mockups/dashboard_2a_rod_precheckin.html#L1855-L1856)). A disabled input cannot report why it did nothing, so a barcode gun fired at a full station produces **silence** — the worst feedback on a glare-lit panel. Keep scanning enabled for lookup and refuse at the stage step with a stated reason.

### Blocked bay (contingent on F2)

Renders exactly as the current mockup does — border, `BLOCKED` chip, greyed bar, `Held — not available`, WIP Rejection as the sole action. **This state should be kept and the API changed to produce it**, not dropped to match the contract.

---

## 4. Alternatives considered and rejected

**Merge the weld strip into the gap between the two bay cards.** The weld conceptually *joins* the two bays, so a vertical connector between them is the more honest diagram. Rejected: it costs horizontal width from both cards (which are already at five fact columns), it has nowhere to put two action buttons, and it breaks down entirely in the cold-start and station-full states where there is no weld to depict. The horizontal strip below both bays reads fine and is cheap.

**Collapse the 3-step wizard to a single scrolling panel.** Would remove two Next taps and the tab strip's 52px. Rejected: the three steps are not arbitrary — step 1 can hard-refuse (unallocated rod, wrong order), step 3 can hard-block with no bypass (`CHK010`), and the carry-forward and supervisor-override panels appear conditionally inside step 1. A single panel would either render those gates inert until scrolled past or lose the progressive-unlock guarantee that the operator saw each one. Fix the no-op step instead (F6).

**A "Pass all three" inspection control.** Would cut the all-pass path from 3 taps to 1. Rejected: this is the pre-unbanding safety inspection, it is the one gate with no override anywhere in the flow (`CHK010`), and a single-tap affordance is an invitation to rubber-stamp it without looking at the bundle. The 3 taps are the point. Worth putting to the business rather than deciding here.

---

## 5. Component and state plan (Angular port)

```
fw-rod-precheckin-station                     (route: line/:lineId/staging)
├── fw-station-header          [line, order, lineState, stationCode, baysOccupied]
├── fw-payoff-bay × 2          [bay: PayoffBay, peerState, thresholds]  ← ONE component, both bays
│     └── fw-payoff-weight     [weightLb, netLb, state]   ← isolated 10 Hz subtree
├── fw-weld-readiness-strip    [bay1, bay2]  (markWelded)
├── fw-staging-queue           [rows, stationFull, expectedNextAlpha]  (stage, unstage, reject)
├── fw-precheckin-wizard       (modal; 3 steps)  [preferBay, prefillAlpha, liveWeight]
├── fw-precheckout-dialog      (modal)  [bay: required — no default, F3]
└── fw-mark-welded-dialog      (modal)  [outgoing, incoming, footage]
```

**Services.** `payoff-state.service` owns both bays as a single `PayoffStationState` and is the only writer — it enforces *at most one `active` bay*, which nothing currently enforces ([1445](../Mockups/dashboard_2a_rod_precheckin.html#L1445) asserts it in a comment only). `staging-api.service` wraps `/payoff/status`, `/staging/**`. `line-context` supplies line + order. Reuse only the foundational `shared` services per §0.2 — `api-gateway`, `app-config`, `login`, interceptors, `ui-log`.

**Two feeds, two cadences, one card.** Per §0.4 and [phase-04:74](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md):

| Region | Source | Cadence |
|---|---|---|
| bay weight, bar, `WELD SOON`/`WELD NOW` | `PayoffWeight` (batched) | ~10 Hz → `requestAnimationFrame` throttle |
| bay occupancy, chip, facts, actions | `PayoffStateChanged` (rare, unbatched) | on change only |
| header line state | `LineStatus` (rare) | on change only |
| queue rows | REST re-query on `PayoffStateChanged` | on change only |

Weight must be an isolated `OnPush` subtree — the current `renderBay` rebuilds the action buttons' `innerHTML` on every render ([1597](../Mockups/dashboard_2a_rod_precheckin.html#L1597)), which is harmless at mockup render rates and unacceptable at 10 Hz.

**Typed model gap.** `emptyBay()` ([1434-1438](../Mockups/dashboard_2a_rod_precheckin.html#L1434-L1438)) does not declare `offScheduleOverride`, `outOfSequenceOverride`, `overrideBy`, `overrideReason`, `overrideAt` or `scheduledLine` — they are attached later in `commitPreCheckin` ([2310-2315](../Mockups/dashboard_2a_rod_precheckin.html#L2310-L2315)). Harmless in JS, a compile error waiting in TS. The `PayoffBay` interface must carry all of them, and `state` must be a union `'empty' | 'staged' | 'blocked' | 'active'` mapped from the API's `NotStaged | Staged | Active | Blocked` ([APIContracts:821](../DevelopmentPlan/APIContracts.md)) — note the two vocabularies differ and something must own the translation.

**No `innerHTML`.** Every dynamic region here is built by string concatenation, including rod alphas interpolated into markup. Templates and `@for` throughout, per the file's own instruction ([66-68](../Mockups/dashboard_2a_rod_precheckin.html#L66-L68)).

---

## 6. Spec impact

| Finding | Document that must change |
|---|---|
| **F1** | ✅ **Logged Jul 31** as **Q76** (FlatWireOpenQuestions) + **G21** (back-matter). Fix deliberately **not** applied — it is opposite depending on the answer (re-key the index on the station vs seed `FL3PO`). Still to change once answered: `UX_RodStaging_Bay` in [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md) + `FlatWire_DDL_07_Indexes.sql`; `STATION_BY_LINE` at [2480-2487](../Mockups/dashboard_2a_rod_precheckin.html#L2480-L2487); phase-04 "WIP stations" |
| **F2** | ✅ **Applied Jul 31.** Q72 items 1–2 decided *commit-then-block*; [APIContracts.md](../DevelopmentPlan/APIContracts.md) 422 → `201` + `state:"Blocked"` (new section + struck error row), [FlatWireSchema_Runs.md](../DevelopmentPlan/Schema/FlatWireSchema_Runs.md) Q72 note rewritten, [phase-04](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md) staging rules corrected. **Residual open:** what *releases* a blocked row (Q72 item 3) — no `Status` value fits, and inventing one moves the row outside `UX_RodStaging_Bay`'s filter |
| **F3, F4, F6, F7, F8, F9, F10, F14, F15, F16** | Mockup only — no spec change. F4 additionally needs `WLD011` specified before any weld-reversal path exists |
| **F5** | [phase-04](../DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md) "Dashboard 2A layout" — the wizard needs a live-weight input, which is a real-time dependency the phase does not currently list |
| **F11** | Q66 residual, already flagged at [APIContracts.md:893](../DevelopmentPlan/APIContracts.md) — add the rejected-credential UI state once decided |
| **F12, F13** | [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) Dashboard 2A screen spec; F13 resolves with F1 |
| **F17** (scan-when-full, §3 note) | Mockup only |

### ⚠ Superseded by the 30 Jul 2026 client call (recorded Aug 1)

Two findings were applied correctly against the design as it then stood, and the client has since changed that design. **Do not treat either as current.**

| Finding | What it did | Why it no longer holds |
|---|---|---|
| **F4** — *a welded rod can be un-staged* | Removed **Unstage** from welded queue rows and bay cards, and made `openPreCheckout()` reject a welded bay | **Q68/Q77 (Jul 30):** a welded rod **can** be released — by a **supervisor**, with a documented reason, as a **rejection to `HOLD`**. The finding was right about the *unqualified* control and wrong that there is no path at all. The control **returns behind a supervisor gate** and routes to rejection, not to "returns to inventory" |
| **F8** — *an authorised deviation disappears at check-in* | Gave the override its own alert slot so it survives into `ACTIVE` | Still correct **for out-of-sequence**. But the **off-schedule** override it was half about no longer exists: **Q74 (Jul 30)** replaced it with an **automatic station switch**, and `offScheduleOverride` / `scheduledLine` are being dropped from the model — so the branch that renders "off-schedule — authorised by …" goes with them |

**F2 is now fully resolved.** Items 1–2 were decided Jul 31 (commit-then-block); **item 3 — what releases a blocked row — was decided Jul 30**: the WIP rejection captures a reason and puts the rod on `HOLD`, which releases the row and frees the bay. The two untraced consequences flagged in §7 (the `TRV009` traveler class, and excluding blocked rods from the `Available` projection) are **still untraced**.

**F1/F13 unchanged but sharpened.** The client confirmed rods are **never stacked** (Q75), so one-rod-per-bay is definitively the invariant `UX_RodStaging_Bay` must defend. And the auto-switch means the FL1/FL3 toggle now fires **by itself** — F13's "relabels without reloading" stops being cosmetic the moment the system can trigger it mid-transaction.

**Proposed new open questions** — logged here, then written into the register:

1. **Are FL1 and FL3 one physical pre-check-in station or two?** Everything downstream of F1 depends on it, and the mockup currently guesses. → **Q76**, still open.
2. ~~**Does pre-check-in commit the staging row before the inspection gate?**~~ → **Q72**, decided (commit-then-block, Jul 31; release-on-rejection, Jul 30).
3. ~~**May a welded staged rod ever be released, and by whom?**~~ → **Q77**, decided Jul 30: **yes, by a supervisor, as a rejection**. `WLD011` remains unspecified for reversing a weld **in place**.

**Also noticed, outside this screen's scope:** [CLAUDE.md](../CLAUDE.md) states the schema divergence as "21–22 vs 25 tables". [RodPreCheckin.md:203](../LatestDocument/RequirementDocuments/RodPreCheckin.md) and G12 now both say **27**. The repo guide is stale on this point.

---

## 7. What I did not resolve

- **F2 was decided at the API** (commit-then-block) and the contracts now say so. Two consequences remain **untraced**, and I did not chase them: `RodStaging` now carries rows for material that was never accepted, which affects the **`TRV009`** traveler (is `Blocked` a third class alongside pre-checked-in and welded?), and the **`Available`** projection must exclude blocked rods or a rejected bundle reappears as stageable. Both are recorded on Q72.
- **What releases a blocked row is still unanswered** (Q72 item 3), so a blocked bay is now enterable but not clearable. That is a strictly better failure than before — the bay at least reads as occupied — but it is not finished.
- **Whether the `Available` queue projection can actually be built.** [RodPreCheckin.md:164](../LatestDocument/RequirementDocuments/RodPreCheckin.md) flags the concrete planning/scheduling table mapping as missing and **blocking Phase 4**. Every queue finding above assumes those rows can be produced; none of them matter if that mapping does not exist. It lives in `ual-database`, outside this repo.
- **Whether 44px is the right floor for this panel.** I applied it because the rest of the screen does, but I have no measurement of the actual panel's touch digitiser or of gloved-finger accuracy on it. Worth one session of UAT rather than more argument.
- **The `TraversingTakeup` payoff position has no UI anywhere** (G20, `REVIEW.md` #15 partly open). Correct for this FL1/FL3 screen, but it means the third pinned lookup row is unreachable from any screen in the system.

---

## Change Log

| Date | Change |
|---|---|
| July 30, 2026 | Initial review. 16 findings + 1 layout note across 10 lenses; two new schema/contract defects (FL1/FL3 bay-uniqueness collision; unreachable-by-contract `BLOCKED` state) and two wrong-target action bugs (queue Unstage bay resolution; Unstage offered on a welded rod). Proposed a four-region layout reclaiming the footer's 86px for the queue. |
| July 31, 2026 | **Findings applied.** Ten mockup fixes landed (F3, F4, F5, F7, F8, F9, F10, F14, F15, F17); **F2** applied to the contracts as *commit-then-block* (`422` → `201` + `state:"Blocked"`) across `APIContracts.md`, `FlatWireSchema_Runs.md` and `phase-04`, closing Q72 items 1–2. **F1** logged as **Q76** + **G21** rather than fixed, because the correct fix is opposite depending on whether FL1/FL3 is one station or two. **F16 withdrawn** — I had misread a correctly-labelled height comment. **F12** (footer/layout re-plan) deferred as its own verified change. Verified in headless Chrome: 6 heights × 6 bay states clean, 21 behavioural assertions pass. |
| August 1, 2026 | **Two applied findings marked superseded by the 30 Jul client call; F2 closed.** **F4** (Unstage removed from welded rods) is reversed — a welded rod may be released by a **supervisor**, with a documented reason, as a **rejection to `HOLD`** (Q68/Q77); the control returns behind that gate. **F8** stays correct for the out-of-sequence override but its off-schedule half is void — Q74 replaced that override with an **automatic station switch**, so `offScheduleOverride` / `scheduledLine` leave the typed model along with the render branch. **F2 item 3** is answered: the WIP rejection releases the blocked row and frees the bay; its two untraced consequences (the `TRV009` traveler class, excluding blocked rods from the `Available` projection) remain untraced. **F1/F13 sharpened rather than changed** — no stacking (Q75) makes one-rod-per-bay definitive, and the auto-switch means the FL1/FL3 toggle can now fire by itself mid-transaction, which turns F13 from cosmetic into behavioural. Also noted: the CLAUDE.md table-count staleness flagged in §6 has since been corrected to 27. |
