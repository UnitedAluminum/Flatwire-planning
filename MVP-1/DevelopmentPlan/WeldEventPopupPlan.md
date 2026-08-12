# Weld Event — Change Plan: Popup Conversion and Payoff-Card Entry

**Project:** Flat Wire Mill Implementation
**Document Type:** Change plan (internal working document)
**Last Updated:** August 13, 2026
**Status:** Draft for approval — no edits made yet
**Affects:** Dashboard 2A (Rod Pre-Check-In) · ~~Dashboard 4 (Log Weld Event)~~ *(retired 1 Aug 2026)* · Dashboard 3 family

---

## 1. The Four Requested Changes

| # | Change | Restated precisely |
|---|---|---|
| ~~**C1**~~ | ~~Remove the **Mark as welded** button~~ | **INVERTED 1 Aug 2026 — the button is upgraded, not removed.** The problem C1 set out to solve was the *lightweight* weld path: a flag with no quality and no footage, producing an uncertifiable record. That is fixed by making the dialog capture the quality result (`PCI022`) — it already had both alphas, weld type and footage, so it now composes a complete `WeldEvent` row. The lightweight path ceases to exist exactly as C1 intended; the control does not. `POST /staging/rod/mark-welded` is retired in favour of `POST /weldevent`, which is **D-A** as written. |
| **C2** | Weld button on the payoff card | Each **staged, un-welded** payoff card carries its own control that manually opens the weld screen, carrying that bay's rod in as the incoming rod. |
| ~~**C3**~~ | ~~Dashboard 4 becomes a popup~~ | **OVERTAKEN 1 Aug 2026 — Dashboard 4 was retired outright**, not converted. Its capture fields now live in DB2A's *Mark as welded* dialog (`PCI022`), so there is no page left to convert and **`weld_event.js` (M1) is not needed**. **Two elements did not survive the move:** the re-sequenceable *Rods In Queue* accordion and the *traceability chain* strip — gap **G27**. |
| **C4** | Offer the weld log at pre-check-in | Immediately after a rod is successfully pre-checked-in, ask the operator whether they want to log the weld event now; opening the popup pre-filled if yes, dismissing silently if no. |

C1 and C2 are the same decision seen from two sides: the weld action is being **moved off the station-level strip and onto the bay it belongs to**, and the lightweight version of it is being retired in favour of the real one.

---

## 2. Design Decisions and Their Consequences

### D-A — One weld record, not two `[recommended]`

Today the system writes a weld **twice, in two different shapes**:

| | Dashboard 2A — Mark as welded | Dashboard 4 — Weld Event |
|---|---|---|
| Requirement | `FR-050`, `FR-051` (`WLD003`, `WLD006`, `WLD010`) | `FR-160`–`FR-175` |
| Endpoint | `POST /staging/rod/mark-welded` | `POST /weldevent` |
| Writes | `RodStaging.IsWelded` / `WeldedAt` / `WeldedBy` | `WeldEvent` row — footage, quality, fail reason, traceability |
| Captures quality? | **No** | Yes, mandatory |
| Captures footage? | **No** | Yes, from the encoder |
| Sprint / phase | S3 · phase 4 | S4 · phase 6 |

Removing the button collapses these into one. **`POST /weldevent` becomes the only weld write**, and it sets `RodStaging.IsWelded` / `WeldedAt` / `WeldedBy` in the same transaction. `POST /staging/rod/mark-welded` is retired.

> **CONFIRMED 1 Aug 2026, by a different route than this section assumed.** D-A holds in full — one weld
> record, `POST /weldevent` the single write, `mark-welded` retired — but it was reached by **adding the
> quality check to the Mark as welded dialog** rather than by deleting that dialog (see C1). The dialog
> already captured both alphas, weld type and footage, so quality was the only NOT NULL `WeldEvent` column
> it lacked. **No schema change was required.**
>
> **One rule added that this section did not anticipate:** the `RodStaging` write is **conditional on
> quality**. A `Pass` sets `IsWelded`/`WeldedAt`/`WeldedBy`; a **`Fail` writes the `WeldEvent` row and
> leaves the rod staged and un-welded**, because the join did not hold and the line cannot transition
> through it. The operator remakes the weld — which means one physical join can carry several rows, raising
> **OI-59** (does a superseded attempt reach the certificate?) and **Q6** (footage attribution across two boundaries).

**What this gains.** The state "flagged as welded, but with no footage and no quality result" becomes unreachable. That state was never certifiable — `WeldEvent.md` §1.2 is explicit that an unrecorded weld is uncertifiable footage, and a weld flagged without a quality result is the same problem one step removed.

**What this costs.** There is no longer a fast, two-click "yes, I welded it" action. Every weld now requires the quality result and, on failure, a reason — at the busiest moment on the line, with the wire in front of the operator. This is a genuine increase in keystrokes and should be put to United Aluminum explicitly (see Q-W1).

**What is kept.** `RodStaging.IsWelded` stays as a column. Three things depend on it and none of them can read the `WeldEvent` table cheaply: bay-card rendering, the pre-check-out approval branch (unwelded = operator, welded = supervisor + `HOLD`), and `RodCheckout.WasWelded` on Mode P. `CK_RodStaging_Welded` stays as written.

### D-B — The material-match check moves, it is not lost

`FR-050` puts the alloy / temper / diameter match on Mark as Welded. `WeldEvent.md` §3.2 already requires the same check before a weld event is accepted (`WLD006`). Removing the button therefore **consolidates a duplicated rule rather than dropping one**. The popup blocks confirmation on mismatch, exactly as the retired modal did.

### D-C — The button belongs on the staged card, not the running one `[recommended]` — **BUILT 1 Aug 2026**

> **Implemented as written.** *Mark as welded* sits on the staged card, the `canWeld` rule and all its
> tooltips carried over unchanged, and the outgoing/incoming pair is still resolved from whichever bay
> is *running* rather than from the card that was activated (`FR-050a`, TC-068i) — the rule TC-068
> exists to protect, and the one this move could most easily have broken.
>
> **One line below is now wrong:** "The running card keeps its existing two actions (*Open active run*,
> *Check out rod*)". It keeps **Check out rod** and gains **Welds this run · N**; ***Open active run*
> was removed** (`FR-051b`).

The control goes on the **staged, un-welded** payoff card. That card *is* the incoming rod, so the button carries the bay → rod identity into the popup, which is precisely the `PCI008` defaulting behaviour ("the weld defaults to whichever rod is actually staged on the idle payoff").

The running card keeps its existing two actions (*Open active run*, *Check out rod*) and gains nothing — a weld has no meaning as an action *on* the rod that is ending.

Enablement reuses the existing `canWeld` rule from `renderWeldStrip()`, unchanged, including its four tooltip strings:

| Condition | Control |
|---|---|
| A rod is running **and** this bay is staged and un-welded | **Enabled** — "Record the induction weld" |
| Nothing is running | Disabled — "No rod is running, there is nothing to weld to" |
| This bay is empty | No card action (the card shows *Pre-check-in rod*) |
| This bay is blocked | No weld action — WIP Rejection only |
| Already welded | Disabled — "Already marked as welded" |

### ~~D-D~~ — The weld-readiness strip keeps its text and loses its buttons ~~`[recommended]`~~

> **OVERTAKEN 1 Aug 2026 — the strip was removed outright, text and all.** D-D proposed keeping the
> narrative and dropping the buttons. What was built went one step further: the **whole 96px band is
> gone**. The reason D-D did not see is that the narrative was not unique either — the bay cards
> already carried the weight and percentage on the payoff bar, all four weld states in the bay alert,
> and the cold-start message in the empty-bay text. Exactly **one** sentence was unique to the strip,
> *"induction-weld tail to head before Payoff N runs out"*, and it moved into the staged card's alert.
> Once that was true the band was 96px of a 1024px budget spent restating the row above it, so it went
> to the queue instead (~108px, about four more rows).
>
> **D-C is confirmed and extended.** *Mark as welded* went to the staged card exactly as D-C
> recommended, with the `canWeld` rule and its tooltips intact. *Welds this run* went to the **active**
> card — D-D's resolution below assumed it would stay on the strip, which no longer exists. That move
> has one consequence D-D could not have: at cold start there is no active card, so the control is
> **absent** rather than disabled, superseding **TC-068e** and raising **OI-108**.
>
> **One thing removed that no section here proposed:** the *Open active run* link on the active card
> (`FR-051b`). The run monitor is reachable from the app bar and Line Status, and this station's job is
> staging the next rod.
>
> The section below is kept for the record only.

After C1 the strip has one button left: **Weld event log**, linking to Dashboard 4. That link is **already misnamed** — it opens the logging form, not a log of anything. Once the form is a popup owned by the card, the recommendation is to remove the strip's buttons entirely and leave it as the status narrative it already is ("Payoff 1 at 2,840 lb (33%) · Payoff 2 staged with R00043, not yet welded…").

This surfaces a real absence: **nothing anywhere in the design lists the weld events already recorded against a run.**

> **RESOLVED 1 Aug 2026 — the link is replaced, not deleted.** Rather than remove it and carry the
> absence as a gap, Dashboard 2A now has a genuine **Welds this run** control opening a **read-only
> dialog** listing every `WeldEvent` against the active `RunId` — time, rod pair, footage, weld type,
> operator, and Pass/Fail with the mandatory fail reason. Read-only because correcting or reversing a
> recorded weld is `WLD011`, which nothing specifies.
>
> Scope decisions: **Dashboard 2A only** (not the Dashboard 3 family), **current run only** (not shift,
> not coil — `WeldEvent` is keyed on `RunId`, so no paging or date filter is needed). Backed by a new
> `GET /run/{runId}/weldevents`; `/run/active`'s trimmed `weldEvents[]` is left alone because it feeds
> Dashboard 3's gauge-trace markers. Built in `dashboard_2a_rod_precheckin.html`, reusing the row shape
> from `dashboard_10_shift_summary.html`.
>
> **This closes Q-W3 and withdraws the proposed gap G25** — see §3 and §4.

### ~~D-E~~ — The popup is a shared injected script, not a per-screen modal ~~`[recommended]`~~

> **OVERTAKEN 1 Aug 2026 — none of this was built, and none of it is needed.** The premise was that the
> weld screen is reachable from five places, so the modal must be shared. It is now reachable from
> **one**: Dashboard 2A's *Mark as welded* dialog, which is a plain inline `.gb-modal-overlay` reusing
> that screen's existing focus trap and ESC handling. The weld action was removed from all four
> active-run monitors and **Dashboard 4 was deleted**, so there is no second host to share with.
> `MVP-1/Mockups/weld_event.js` was never created and should not be. The paragraph below is kept for the
> record only.



The weld screen is reachable from five places today (Dashboard 2A, Dashboard 3, 3-v2, 3-FL2, 3-FL3). Duplicating a 1,300-line modal into each is untenable, so it follows the established shared-chrome pattern in `MVP-1/Mockups/` — the same approach as `pause_run.js` and `spool_notification.js`:

- **New `MVP-1/Mockups/weld_event.js`** — injects the modal markup once, exposes `FlatWireWeld.open({ lineId, outgoingRod, incomingRod, hostReturn })`, owns validation, confirm and close.
- ~~**`dashboard_4_weld_event.html` is retained as a thin harness**~~ — **it was deleted instead** (1 Aug 2026; git history at `2a0426b`). Was: a thin harness that includes the script and auto-opens the popup. Existing links from Dashboard 3 and from a dozen specification documents keep resolving, and the client can still review "Dashboard 4" as a standalone artifact.
- In Angular this is `fw-weld-event-dialog`, a dialog component — **not a route**. Phase 6 currently plans it as a screen; that changes.

### D-F — Content parity, and the two things that do not port cleanly

Everything on Dashboard 4 moves into the popup: the *Rods In Queue* accordion, the traceability chain visual, the outgoing rod panel (auto-populated), the incoming rod panel with its scan/keyed override, weld type (induction, display-only), quality Pass/Fail with the six fail reasons, the footer stamp (operator · timestamp · output alpha) and Cancel / Confirm.

Two items need rework rather than a copy:

1. **The drag-to-resequence queue and its floating undo toast** (`seq-toast`) are positioned against `.dashboard`. Inside a modal they must anchor to the dialog. The queue accordion should also default to **collapsed** in the popup to control height — it is context, not a required step.
2. **Dialog size.** The design system offers `.gb-modal` and `.gb-modal.narrow`; this needs a new **`.gb-modal.wide`** (~1180px, scrollable body). It must respect the 14px minimum type floor and behave under `flat-wire-fit.js`, which scales `<body>` — the existing modals already sit inside that transform, so this is a sizing change, not an architectural one.

### D-G — The pre-check-in offer, and when it should *not* appear `[decision needed]`

The offer fires after `commitPreCheckin()` succeeds, and only when a weld is actually possible: this bay staged and un-welded, the other bay Active with an open run, and the material match passing. It never appears on cold start (nothing is running), never on a blocked rod (a failed inspection routes to WIP Rejection and never reaches commit), and never on FL2 (no staging at all).

It is an **offer, not a step**: two buttons, *Log weld event now* and *Not now*, dismissible, never auto-opening the popup. Declining is a normal outcome — which is exactly why C2 exists.

**The timing caveat is real and needs a decision.** At the moment of staging, the weld has usually **not physically happened yet**. The sequence in `RodPreCheckin.md` §2.2 is: stage the bundle → induction-weld tail to head → mark it. And weld-point footage is read from the encoder *at confirm*, so a weld logged too early records the wrong footage.

> **Recommended:** show the offer only when the running payoff is at or below the **3,000 lb prepare-weld threshold** — precisely the window in which stage-then-weld-immediately is the real workflow — and word it as a question about the physical act ("Has this rod been welded to the running rod?") rather than an instruction. Outside that window the card button remains the path.
>
> **Alternative:** offer it on every successful staging regardless of remaining weight. Simpler rule, but it invites a weld to be logged before it exists.

This is Q-W2 below.

---

## 3. Open Questions Raised by This Change

To be added to `Analysis/FlatWireOpenQuestions.md` and to the client sign-off sheets on the two requirement documents.

| Ref | Priority | Question | Blocks |
|---|---|---|---|
| ~~**Q-W1**~~ | — | ~~**every weld now requires a quality result and, on failure, a reason, at the moment of the weld.** Is that acceptable on the floor?~~ **DECIDED 1 Aug 2026: yes.** Quality is captured at the weld. Rather than removing the lightweight flag, **Dashboard 2A's Mark as welded dialog gained the quality check** — it already captured both alphas, weld type and footage, so quality was the only NOT NULL `WeldEvent` column missing. `POST /staging/rod/mark-welded` is **retired**; `POST /weldevent` is the single write. | ~~D-A~~ — closed, and **D-A is confirmed** |
| **Q-W2** | Medium | Should the post-staging offer be **gated to the sub-3,000 lb window**, or shown on every successful staging? | D-G — the offer's trigger rule |
| ~~**Q-W3**~~ | — | ~~**Is a weld-history view needed** — a list of welds already recorded against the current run — and if so, where does it live?~~ **DECIDED 1 Aug 2026: yes.** A read-only **Welds this run** dialog on **Dashboard 2A**, scoped to the active `RunId`, backed by `GET /run/{runId}/weldevents`. Built; see D-D. | ~~D-D~~ — closed |
| ~~**Q-W4**~~ | — | ~~The **FL2 active-run screen links to the weld screen**… Confirm the link is removed.~~ **ACTED ON 1 Aug 2026: removed** — along with the weld button on all four active-run screens. ⚠ **This was decided rather than answered.** `dashboard_10_shift_summary.html` fixtures show FL2 welds (`SP-00029 → SP-00030`, induction) while `WeldEvent.md:166` says FL2 *inherits* the spool's weld markers. If FL2 does weld spool-to-spool it now has **no capture path at all** — it has no pre-check-in station. See gap **G28**. | Dashboard 3 FL2 navigation |

The existing open question in `FlatWireOpenQuestions.md` — whether a weld should be blocked outright when the staged rod's order differs from the running order — **transfers to the popup** and is unaffected in substance.

---

## 4. New Gap Register Entries

For `MVP-1/DevelopmentPlan/ShopfloorPlan/back-matter.md`:

| Gap | Description |
|---|---|
| ~~**G25**~~ | ~~**No weld-history view exists.**~~ **WITHDRAWN 1 Aug 2026 — built rather than deferred.** Dashboard 2A now carries a read-only **Welds this run** dialog over `GET /run/{runId}/weldevents`. ~~Do not register G25; the next free gap ID remains **G25**.~~ **The ID was reused on 13 Aug 2026** for the requirement-coverage gap — see [`back-matter.md`](./ShopfloorPlan/back-matter.md). This weld-history gap was withdrawn before it was ever registered, so nothing cites the old G25; if you find a citation dated on or before 12 Aug 2026, it means *this* row, not the coverage gap. |
| **G26** | **The merged weld write straddles two phases.** `POST /staging/rod/mark-welded` sits in S3 / phase 4 (with Dashboard 2A) and `POST /weldevent` in S4 / phase 6 (with Dashboard 4). Merging them means phase 4 ships a payoff-card button whose target lands in phase 6. See §6. **Registered 13 Aug 2026** — twelve days late; `phase-06:45` had been citing it since 1 Aug against no register entry. |

---

## 5. Work Breakdown

### 5.1 Mockups — the visual baseline, done first

Everything downstream describes these screens, so they change first and the documents are reconciled to them.

| # | File | Work |
|---|---|---|
| ~~M1~~ | ~~**`MVP-1/Mockups/weld_event.js`** *(new)*~~ **— not needed; DB4 retired, not converted (see C3)** | Port the whole of Dashboard 4 into an injected modal: markup, styles, queue drag/undo re-anchored to the dialog, `FlatWireWeld.open()` API, validation (material match, quality selected, fail reason mandatory on Fail), confirm handler. Follows `pause_run.js` conventions. |
| M2 | `MVP-1/Mockups/flat-wire-shopfloor.styles.scss` → `.css` | Add `.gb-modal.wide`. Edit the `.scss`; recompile the `.css`. |
| ~~M3~~ | ~~`MVP-1/Mockups/dashboard_4_weld_event.html`~~ **— DELETED 1 Aug 2026** (git history at `2a0426b`). Was: reduce to a harness: shared chrome + `weld_event.js` + auto-open. Page-level content removed, since it now lives in M1. |
| M4 | `MVP-1/Mockups/dashboard_2a_rod_precheckin.html` | **(a)** Delete `#btn-mark-welded` (L904–907) and the `#mw-overlay` modal (L1386–1432) and its handlers (L2724–2770). **(b)** Strip the `canWeld`/`mw` block out of `renderWeldStrip()` (L1912–1921) — keep the narrative text, which is unchanged. **(c)** Decide the strip's remaining link per D-D. **(d)** Add the *Log weld event* button to the staged branch of `actionsFor()` (L1739–1742), with the enablement and tooltips from D-C. **(e)** Add the post-staging offer at the end of `commitPreCheckin()` (L2603–2607) per D-G. **(f)** Include `weld_event.js`. |
| ~~M5~~ | ~~old left-rail `dashboard_3_active_run.html` (L660 nav, L1356 tile)~~ *(file withdrawn 1 Aug 2026)*, `_v2` (L1055 — renamed `dashboard_3_active_run.html` 11 Aug 2026), `_fl3` (L592) | **DONE differently** — the weld action was removed, not repointed. Was: replace `href`/`window.location` navigation with `FlatWireWeld.open(...)`; include the script. |
| ~~M6~~ | `dashboard_3_active_run_fl2.html` | **DONE 1 Aug 2026** — weld action removed, as were those on the withdrawn left-rail `dashboard_3_active_run.html` (left-nav **and** More-Options tile), `_v2` (now `dashboard_3_active_run.html`) and `_fl3`. |

### 5.2 Requirement documents — the client-facing deliverables

Both were reissued for client review on 1 Aug 2026, so each needs a **version bump, a `## Document Change History` row, a row in [`../../CHANGELOG.md`](../../CHANGELOG.md), and revised sign-off lines**. *(The two are different things and both still apply: the Document Change History block stays in the client-facing document as deliverable content, while the change-log row goes only in the root `CHANGELOG.md`.)*

| # | File | Work |
|---|---|---|
| R1 | `MVP-1/RequirementDocuments/RodPreCheckin.md` | §4.1 bay-state actions — *Mark as welded* → *Log weld event* (L111). §4.3 cold-start sentence on Mark as welded being unavailable (L128). **§8 "Marking the Weld" rewritten** as *Logging the Weld* — the station-level action becomes a bay-level action opening the weld event dialog; `WLD006` match check cited to the dialog; `WLD003` operator/timestamp now the weld event's. Add the post-staging offer as a new sub-section under §7. §10 D8 re-worded (the no-separate-status decision still holds and is unaffected). Sign-off Part A §8 row. Requirement IDs: the `PCI0xx` series gains an item for the bay-level control and the offer. |
| R2 | `MVP-1/RequirementDocuments/WeldEvent.md` | Header **Screen reference** (L9) — dialog, not Dashboard 4. §2.1 step 3 — add the two entry points (payoff card; post-staging offer) and state that the weld is a dialog over the host screen. §4 effect 5 — "returned to the active run view" becomes "returned to the host screen". **§7 Design Principles needs care:** the current wording rejects modals for validation ("a modal that hides the form is the wrong instrument", L110/§7) — the principle still holds for *validation messages inside* the dialog, but the phrasing must be revised so it does not read as contradicting the dialog itself. Add a decision row for the retirement of Mark as Welded, and Q-W1–Q-W4 to §9 and to Part B of the sign-off. |

### 5.3 Specification and plan documents

| # | File | Work |
|---|---|---|
| S1 | `LatestDocument/FlatWire_MasterSpecification.md` | L308 narrative step 8; **FR-050 / FR-051 (L560–561)** — rewrite as the bay-level control and the merged write, or supersede them into the `FR-160`–`FR-175` weld-event series; L2116 endpoint 13 (`/staging/rod/mark-welded` retired); L2464 DB4 inventory row (dialog); L2518 flow diagram edge `DB2A -->|Mark as welded| DB4`. |
| S2 | `MVP-1/ProjectPlan/02-SRS.md` | The same five points at L360, L558–559, §5.6 (L742), L1329, L1380. **These are `FR-###` requirement text — the authoritative source per `CLAUDE.md` — so they must not drift from S1.** |
| S3 | `MVP-1/ProjectPlan/04-APIContract.md` | L222 endpoint 13 retired; L862 traceability row; L231/L529/L871 `/weldevent` gains the `RodStaging` flag write; L885 operator scope. |
| S4 | `MVP-1/DevelopmentPlan/APIContracts.md` | §L1078 `POST /staging/rod/mark-welded` marked retired with its rationale; L1530 `/weldevent` amended to set `IsWelded`/`WeldedAt`/`WeldedBy`; sprint tables L2132–2133, permission matrix L2157/L2165, L2193. *(April-dated doc with known Tier 1 bugs — reconcile up to the roadmap, do not maintain in parallel.)* |
| ~~S5~~ | `MVP-1/DevelopmentPlan/ShopfloorPlan/phase-04-rod-checkin-plc-config.md` | **DONE 1 Aug 2026.** The layout bullet now reads *three body regions, not four*, with Mark as Welded on the staged card and Welds this run on the active card; navigation reads → Dashboard 2A on success; the Dashboard-4 link is gone. Two build rules were added that this row did not anticipate: the outgoing/incoming pair resolves from the **running** bay rather than the activated card, and bay-card handlers must be bound per render because `actionsFor()` regenerates them. *(Was: L44 weld-readiness strip / Mark as Welded, L51 navigation → Dashboard 4, L54 endpoint list, L74 `PayoffStateChanged.isWelded`.)* |
| S6 | `MVP-1/DevelopmentPlan/ShopfloorPlan/phase-06-in-run-production-events.md` | L26 and L34 — Dashboard 4 becomes a dialog component; add the merged `RodStaging` write; add the DB2A entry points. |
| ~~S7~~ | `MVP-1/DevelopmentPlan/ShopfloorPlan/back-matter.md` | **DONE 13 Aug 2026 — this step was the one that did not get executed.** G25 was withdrawn (correctly) but **G26 was never added**, so `phase-06:45` cited a gap ID that resolved to nothing for twelve days. Both are now in the register: **G26** as written here, and **G25** reused for the requirement-coverage gap. *(Was: add G25 and G26; adjust the FW-063 line (L218) for the dialog.)* |
| S8 | `MVP-1/ProjectPlan/05-SprintPlanAndBacklog.md` (L369) and `MVP-1/DevelopmentPlan/FlatWireJiraStories.md` (L782, L796 FW-063, L1419) | FW-063 acceptance criteria: dialog rather than screen, three entry points, merged write. |
| S9 | `MVP-1/ProjectPlan/06-TestPlanAndTestCases.md` | **TC-068** ("Mark-as-Welded does not switch bays") rewritten against the weld event — the *rule* is unchanged and still needs a test, only its trigger moves. Add cases for the card button's enablement matrix and for the post-staging offer's trigger and dismissal. |
| S10 | `Analysis/FlatWireShopfloorDashboards.md` | **Line anchors removed 11 Aug 2026 — they no longer resolve** (the file gained an authority banner and per-section pointers). Use section names: § *Dashboard 2A* (bay actions, the *Mark as Welded — WLD010* block, the role table), § *Overview → Dashboard Inventory* (screen inventory), § *Dashboard 4* (retired), § *Screen Navigation Map*. **Note this file is no longer a requirements source** — the owning specs are [`RodPreCheckin.md`](../RequirementDocuments/RodPreCheckin.md) and [`WeldEvent.md`](../RequirementDocuments/WeldEvent.md). |
| ~~S11~~ | ~~`Analysis/Dashboard2A_UXReview.md`~~ | **Void — the file was deleted 1 Aug 2026** (git history at `2a0426b`). No layout or component-tree reconciliation is owed. |
| S12 | `Analysis/FlatWireProcessWalkthrough.md` | Weld step in the end-to-end sequence — § *E. Events That Can Interrupt the Run* (cite by **step number**, not line number). |
| S13 | `Analysis/FlatWireOpenQuestions.md` | Add Q-W1–Q-W4; re-point the existing **weld-vs-order-mismatch question in § *Section E*** at the popup (cite by `Q##`, not by line — the former L788 anchor is unreliable). |

### 5.4 Schema

Small, but must not be skipped — the columns carry `WLD010` comments that will be wrong.

| # | File | Work |
|---|---|---|
| B1 | `MVP-1/DBChanges/Schema/FlatWireSchema_Runs.md` | L77 (`WLD003`/`WLD010` "Mark as Welded"), L101 `IsWelded`, L120–121 `WeldedAt`/`WeldedBy`, L164 `CK_RodStaging_Welded`. **No column changes** — only the description of what sets them (the weld event, not a station action). Change-log row in the root [`CHANGELOG.md`](../../CHANGELOG.md), under this file's section. |
| B2 | `MVP-1/DBChanges/Schema/SQL/FlatWire_DDL_04_Runs.sql` | Comments at L63, L93, L128–129, L181. Comment-only; **no DDL change, no rebuild required.** |

---

## 6. Sequencing Consequence

`POST /staging/rod/mark-welded` is a **phase 4 / S3** deliverable; `POST /weldevent` and Dashboard 4 are **phase 6 / S4**. Merging them removes phase 4's weld capability, but phase 4 still owns Dashboard 2A — which now hosts both new entry points.

**Recommended:** the dialog stays in phase 6 as planned. Phase 4 delivers the payoff-card button and the post-staging offer wired to a stub that reports "available in phase 6", so Dashboard 2A's layout and its enablement matrix are complete and reviewable at the phase 4 gate without pulling weld-event work forward.

**Rejected alternative:** pull the whole weld event into phase 4. It drags `WeldEvent`, `CoilTraceability` and the encoder footage read forward with it, against a 14 Aug phase-1 gate and a 30 Sep close — for no benefit, since the physical weld cannot happen before there is a run to weld into, which is itself phase 6.

---

## 7. Order of Work

1. **Confirm Q-W1** — it is the only question that can invalidate the plan. If United Aluminum needs a fast weld flag, D-A is wrong and C1 becomes a relocation rather than a retirement.
2. Mockups M1 → M2 → M3 → M4 → M5 → M6. M4 depends on M1 existing.
3. Requirement documents R1, R2 — the client-facing deliverables, reconciled to the mockups.
4. Specifications S1–S13 and schema B1, B2.
5. Register Q-W1–Q-W4 and G25, G26.

Items 3 and 4 can run in parallel with each other but not ahead of item 2 — the mockups are the approved visual baseline and the documents describe them, not the reverse.
