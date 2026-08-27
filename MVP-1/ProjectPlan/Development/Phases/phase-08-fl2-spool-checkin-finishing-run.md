# PHASE 8 — FL2 Spool Check-In & Finishing Run (FL2 Standalone)

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../Roadmap.md).** See [Foundations](../../Architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 7 — Exception Handling: WIP Rejection & Rod Checkout](./phase-07-wip-rejection-rod-checkout.md) · **Next:** [Phase 9 — Output Coil Completion, Labeling & Packing](./phase-09-output-coil-completion-labeling-packing.md)
> **Owning specifications:** [`SpoolQueue.md`](../../Business/Screens/SpoolQueue.md) (DB5A) · [`RocCheckin.md`](../../Business/Screens/RocCheckin.md) §4.3 (DB5 spool check-in) · [`SpoolCompletionNotification.md`](../../Business/Screens/SpoolCompletionNotification.md) (weight milestones and the machine-stop confirmation) — the owning doc wins on any disagreement.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** 2026-08-18 — **`D-32`**: `SpoolProcessing.Status=INFLAT` clarified as `FlatWireDB`-local; the shared `coils` row is not written *(previously 2026-08-02)*
**Status:** Ready to build
**Layer:** Full-stack vertical slice
**Owner:** **FE + BE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **118 h** (14.8 d) — FE 48 · BE 18 · DB 12 · RT 8 · QA 17 · cont. 15 · **Window:** W5–W6 (Sep 14–25, 10 working days)
**Scope call:** **Not deferrable.** The **smallest check-in phase** — it reuses the Phase 2 `pass-schedule-table`/`confirm-bar` and the Phase 5 `gauge-trace-chart` in profile mode. *Re-check the FE figure: the DB3 FL2 variant was re-mocked on 2 Aug 2026 to the FL1 monitor's information architecture (see §Mockup alignment), which adds two data grids, a status-card strip and a chart tab strip. The shell is shared with the FL1 monitor, so most of that is Phase 5/6 work reused rather than new — but the estimate was written against a thinner variant.*

*The FL2 operator journey: check in an FL1-produced spool, review its historical gauge profile, run the 3-stand finishing mill.*

## Business Overview
- **Objective:** check in a spool onto the TPO, display the FL1 historical gauge profile (with weld markers), acknowledge the FL2 pass schedule, push FL2 PLC tags, and run FM2.
- **Business purpose:** the finishing leg that produces the coreless coil; FL2 has no live gauge trace (historical/profile only).
- **User roles:** FL2 operator.
- **Entry conditions:** a spool exists from an FL1 run (Phase 4–6 output) or hybrid path; FL2 pass schedule Active.
- **Exit conditions:** spool `INFLAT`, FL2 run active (FL2 Dashboard 3 variant), ready to complete.

## User Journey
0. **Dashboard 5A — the spool queue (added 2 Aug 2026).** The operator opens DB5A and sees **every spool available for processing, irrespective of order**, with no scan required. Entering a spool identifier resolves that spool's order **server-side in one call** and narrows the list to that order's spools, with the scanned one marked; *Show all* restores the full list. Check-in is offered only for runnable spools and leads to DB5. **Why it exists:** FL1 has DB2A's staging queue and FL2 has no equivalent (`PCI002` excludes FL2 from staging), so the FL2 operator had no view of waiting material at all; and `FR-090`'s *scan the label* and **OQ-17**'s *select it by spool number* both stand while only the scan had a screen. It is also the first thing actually named "the spool queue" — a phrase FR-326, TC-389, `RodCheckout.md` and phase 7 all use with no table, endpoint, screen or status behind it. **Read-only; it writes nothing.**
1. Operator opens **Dashboard 5**; scans spool alpha; source rods auto-populate from FL1 run traceability; alloy/temper read-only; enters measured gauge/width/weights.
2. **Historical gauge profile** chart (from the FL1 run) with target/tolerance and weld markers; "✓ all in spec" or "⚠ N out of spec".
3. FL2 pass schedule table — **three stands: `S1` (8″), `S2` (6″) + edger, `S3` (6″) + edger, final** — read-only; **no visual inspection** (done at FL1). `dashboard_5_spool_checkin.html` now matches (corrected 4 Aug 2026 with the roller-size correction), so build the mockup's table.
4. Acknowledge (same confirm gate) → push FL2 PLC tags → spool `INFLAT` → FL2 Dashboard 3 variant.
5. On the run monitor the operator reads the spool being consumed and the coil being built, records in-run events without leaving the screen, and completes the coil. **Command bar, grouped by intent** (`dashboard_3_active_run_fl2.html`, 2 Aug 2026):
   - **Run events** — SPC Checkpoint · Roll Adjust · WIP Reject. All three are dialogs over the live run.
   - **Go to** — *(cluster removed 4 Aug 2026: View Trends/DB14 was its only member and SCADA Trends is descoped)* · Check Out Rod *(disabled; mid-run checkout is reached through Pause, per phase 7)*.
   - **Run control** — Pause run · **Complete Coil** (confirmation-gated, → Dashboard 7).
   - **No Weld and no Die Change.** FL2 has no drawing dies, and the weld is captured at pre-check-in (DB2A). SPC Checkpoint is present — the earlier "Pause, WIP Reject, Roll Adjust, Complete" list omitted it, but FM2's final-stand (S3) output is a specified checkpoint site.
- **Decision points:** hybrid-origin spool validation (OQ-15 residual — must not apply a standalone FL2 schedule to hybrid material).
- **Error scenarios:** spool not ready-for-FL2 → blocked; hybrid mismatch → blocked (pending OQ-15).

## UI Implementation (Angular)
- **Screens:** **Dashboard 5A (`dashboard_5a_spool_queue.html`, new 2 Aug 2026)**, Dashboard 5 (`dashboard_5_spool_checkin.html`), Dashboard 3 FL2 variant (`dashboard_3_active_run_fl2.html`). **Roll Adjust is no longer a screen** — see *Dialogs* below.
- **DB5A — structure.** Header · scan panel · context bar · list · footer, on the DB2A layout contract (definite `height: 1024px`, the list the only flexing child, `min-height: 0` on both it and its table wrapper, sticky on `th` not `thead`). Component `dashboard-5a-spool-queue`, route `/flat-wire/line/FL2/spools`. **Two modes over one table and the column set never changes between them** — a table that gains and loses columns as you scan reads as two tables and costs the operator their place. The `Order` column therefore stays in both; alloy and temper get **no** columns because they are order-level and live in the context bar (DB2A's stated rule).
  - **The four scan outcomes are all one response, not extra requests:** resolved order · `404` unknown alpha (**field marked, list unchanged**) · `200` with a null order and a single row for an **unallocated** spool (a real case — planning remainders and supervisor-accepted partials) · `200` with `eligible:false` for a spool that cannot run, whose siblings still list because that is usually what the operator wanted.
  - **Deliberately absent:** age (no `CreatedAt` on `SpoolProcessing` — it is not queryable), location (`SpoolProcessing.Location` has no writer and no scheme), and any filter/sort furniture (the list is already limited to runnable material and the scan is the real filter).
- **DB3 FL2 variant — structure (re-mocked 2 Aug 2026 to the FL1 monitor's IA).** Top to bottom:
  1. **Status-card strip**, three cards on a `1fr 1.35fr 1fr` grid:
     - *Machine* — run time, speed, coil footage, coil run time, lube temp.
     - *Material flow* — FL2's counterpart of FL1's two rod payoffs: **spool in** (alpha, source rods, load time, consumption bar, lb remaining / consumed) and **coil out** (output alpha, take-up, fill bar, lb, ft / ft target, skid + coil-of-N badge). One is draining, one is filling; they are not payoffs and should not reuse the payoff component's labels.
     - *Components* — the three-stand set from §User Journey 3, bypassed stands greyed and struck through, headed by the acknowledged pass-schedule id.
  2. **Spool Information** grid — spool no, source rods, alloy, temper, gauge, width, net weight, remaining, next op. FL1's equivalent grid omits width; FL2 carries it, because material arriving here is already flattened.
  3. **Order Information** grid — as FL1's, except `Max Wgt of Spool` is replaced by **`Coil Min–Max Wgt`**, which is the completion basis (see §Client answers). Field source is **OQ-18**.
  4. Both grids are **collapsible** and independently persist nothing — collapse state is per-session.
  5. **Chart tab strip** with a section collapse toggle (persisted to `localStorage`). FL2 has **one** tab (*Traces*); there is no Machine View schematic tab — that is FL1/FL3 only.
  6. **Gauge and width trace panels**, each maximizable to full screen (backdrop, ESC and backdrop-click restore) and each carrying a **Live / Profile** source toggle — see §Real-Time for what each binds to.
- **Components:** `dashboard-5-spool-checkin`, `gauge-trace-chart` (**both modes** — `isLive=true` streaming and `isLive=false` profile with weld markers and a footage x-axis; the FL2 variant switches **one** chart instance between them rather than mounting two), shared `pass-schedule-table`, `confirm-bar`.
- **The DB3 shell is Phase 5's, and this phase configures it — it does not reimplement it.** Phase 5's component list was revised on 2 Aug 2026 to match the mockups and now owns `run-status-cards`, `info-grid`, `chart-tab-strip`, the intent-grouped `action-bar` and a `gauge-trace-chart` that switches source at runtime. FL2's differences from FL1 are enumerable and are **configuration, not a fork**:
  | Shell piece | FL1 / FL3 | FL2 |
  |---|---|---|
  | Middle status card | Payoffs (two rods) | **Material flow** (spool in, coil out) |
  | Info grid subject | Rod Information | **Spool Information** (+ width column) |
  | Chart tabs | **Traces only** *(the Machine View tab was descoped 4 Aug 2026, so this row no longer distinguishes the lines)* | **Traces only** |
  | Trace source | Live (FL3 also has profile) | **Live / Profile toggle**, profile authoritative |
  | Action clusters | incl. Die Change | **no Die Change, no Weld** |
  These two monitors diverged once already and that divergence is what this pass undid. Do not fork an FL2 copy.
- **Dialogs raised from DB3 FL2:** `fw-spc-checkpoint-dialog`, `fw-wip-rejection-dialog`, `fw-pause-dialog` / `fw-resume-dialog`, **`fw-roll-adjust-dialog`** *(Phase 6)*, and a Complete Coil confirmation. **Never stack two** — close the current dialog before opening the next.
- **Roll Adjust is a dialog as of 2 Aug 2026** (`roll_adjust.js`; `dashboard_11_roll_adjust.html` is a launcher only, kept so the filename references across the master spec §4.8, `FlatWireShopfloorDashboards.md` and FW-070 keep resolving). Build it as a `MatDialog`, not a route. **Phase 6 owns it** — it was reconciled on 2 Aug 2026 and now carries the full contract; the summary below is what this phase depends on.
  - **Context contract:** the caller supplies `line`, `orderNo`, `alpha` + `alphaLabel` (*Spool* on FL2, *Rod* on FL3), `runId`, `passSchedule`, `footage` **read at open time**, `targets`, `measurements`, and — critically — **`rolls`**, the stand set the operator can reach. FL2 and FL3 do not share one, which is exactly why it could not stay a page: it hard-coded FL2's. `onConfirm` returns the adjustments, reason, notes and frozen footage.
  - **Two rules to enforce that the old screen only stated:** all-zero deltas relabel the action **"No changes — return to run"** and write nothing (master spec §4.8); and a reason is **required** — Apply stays disabled until one is picked.
  - **Vocabulary:** roll **gap** (the setting being changed, ~0.016″) and product **gauge** (what the strip measures, ~0.110″) are different quantities. The dialog now opens over a monitor showing the gauge trace, so conflating them is visible on screen.
  - **Pause hand-off:** the `RollAdjustment` pause reason routes into this dialog once the pause is applied, the same way *Die change* and *Manual SPC measurement* already do, carrying the frozen footage. It was the one Equipment/Mechanical reason with no destination.
- **Services:** `flat-wire-api` (`checkin/spool`, `run/{runId}/gaugetrace`, `rolloverride`), `line-context` (FL2).
- **Validation:** measured gauge/width required; acknowledge gate.
- **Navigation:** → Dashboard 3 (FL2 mode). From DB3 the only true navigation left is **Complete Coil** (Dashboard 7) — View Trends went with the DB14 descope on 4 Aug 2026. ~~(DB14) and **Complete Coil** (DB7); everything else is a dialog.

## Backend Implementation (.NET)
- **APIs:** `CheckInController POST /checkin/spool`; `RunController GET /run/{runId}/gaugetrace` (historical FL1 readings + weld markers); **`SpoolController GET /spools[?spoolAlpha=]`** — one endpoint, two modes, identical response shape `{ order, spools[] }`. Without `spoolAlpha` it returns everything available for processing with a null order; with it, **the backend resolves the order** and returns it plus that order's spools in the same response. `404` only for an unknown alpha — **an unallocated spool is a `200` with a null order**, and conflating the two is the mistake to avoid. The DTO joins `CoilTraceability`/`WeldEvent` for source rods, the FL1 run for gauge/width, and the **shared order schema cross-database** for the order block. **Add an index on `SpoolProcessing.OrderNo`** — unindexed today and this is a `WHERE OrderNo =` on a `VARCHAR(50)`. It also fixes DB5's scan, which validates against nothing today.
- **Request/Response:** `CheckInSpoolCommand` (spoolAlpha, measured gauge/width, weights, passScheduleId) → run response; gauge-trace DTO.
- **Business services:** `CheckInService` (spool path, FL2 tags), `RunQueryService` (historical trace).
- **Business rules:** FL2 tags = `S1`/`S2`/`S3` roll gaps and stand states + edgers at S2/S3 (no DB/FM1); no visual inspection; hybrid-origin validation (OQ-15).
- **Authz:** Operator+.

## Database Changes
- **Tables (write):** `SpoolCheckin` (LineId restricted FL2/FL3), `FlatWireRun` (FL2 run header), `SpoolProcessing.Status=INFLAT` *(`FlatWireDB`-local; the shared `coils` row is not written — `D-32`)*.
- ⛔ **NEW SHARED WRITE, 26 Aug 2026 — `FW-231`, and it is the one exception to the line above.** At **spool completion** (`POST /spool/complete`) the system writes **one `proddb..coils` row per FL1 segment alpha**. ⚠ **This does not contradict `D-32`:** `D-32` cancelled the shared *schema* migration — new columns and a new status value — and a row through **existing** columns is not a schema change. What it does need is a decision on **which existing `coil_status`** a segment row carries, since `INFLAT` is `FlatWireDB`-local and the output coil's own status is still open as `Q35`.
- ⚠ **Why it exists at all:** change `[N]` makes every alpha mint pass a **blank** ignore list and rely on `CommonDB.dbo.GenerateCoilAlpha`'s own sweep. The sweep cannot see `FlatWireDB`, so registration is what makes blank correct. **Until `FW-231` ships, a blank-list mint reissues `R00001A` on every spool** — `OI-138` / `G54`, and it **gates `FW-230`**. See `[INT §8.0a]`.
- ⛔ **Before the first production write, establish the tonnage question.** Rod, segments and coils all group flat under the six-character root via `coil_link_master_coil`, so a report summing a rod's children counts **one rod's weight three times**. That investigation is most of `FW-231`'s 12 database hours (`[CE §3g]`).
- **Reads:** source FL1 run gauge trace + `WeldEvent` markers; `SpoolProcessing.SourceRunId`/`ParentRodAlpha` for traceability.
- **Reads added by the 2 Aug 2026 mockup — the run monitor now needs order data it did not before.** The Order Information grid wants customer, due date, gauge/width tolerance, setup width/gauge, finish, OD min–max, **coil min–max weight**, total spool weight and order weight. These live in the **shared order/scheduling schema**, not FlatWireDB, so this is a cross-database read on the same unenforced-link basis as the rod-alpha references (`Architecture/Architecture.md` §13.1 `D-04`). Confirm the field for the coil weight range before building — **OQ-18**.
- The Spool Information grid reads only what `SpoolCheckin`/`SpoolProcessing` already carry, plus live remaining weight off the hub.
- **Roll Adjust writes `RollOverride` (`OVR-####`) plus an `SpcCheckpoint` of type `RollAdjustTrigger`** — both **owned by Phase 6**; this phase consumes the endpoint, it does not build it. `RollAdjustTrigger` is absent from the API's four-value `CheckpointType` enum (REVIEW Tier 1 #2, corrected by master spec **FR-184**) — verify Phase 1C shipped the five-value enum before wiring this button.
- **Relationships:** `Spool → FlatWireRun(SourceRunId)`; `SpoolProcessing.ParentRodAlpha` is a **logical link to the rod's `coils` row**, not a FK to a local `Rod` table (G12 — foundations decision 3 drops that table; the DDL still creates it, and the divergence is unresolved). Treat it as a cross-DB reference like the other rod-alpha links until G12 closes.

## Real-Time Functionality
- FL2 standalone broadcasts **`null`** for live gauge/width (historical only); still emits `SpeedFPM`, `PayoffWeight`, `LineStatus`, `FootageCounter`, `ComponentStatus`. **This contract is unchanged.**
- **The two chart sources, and which is authoritative.** The 2 Aug 2026 mockup gives each trace panel a **Live / Profile** toggle. That is a presentation choice, not a change to the broadcast:
  - **Profile** (the value of record for an FL2 standalone run) — the **incoming spool's FL1 history** from `GET /run/{runId}/gaugetrace`, on a **footage** x-axis, with the rod-to-rod weld markers and a whole-length verdict badge (*"All N ft in spec"* / *"N ft out of spec"*). Static: it is a finished run, so it must not be re-rendered or re-sampled by the live tick.
  - **Live** — bound to the hub's gauge/width fields, which on FL2 standalone are `null`.
- **⚠ Implementation instruction the mockup does not cover.** The mockup's Live view animates a simulated trace, because a static prototype has no hub. **In the built screen, Live must render an explicit empty state when the field is `null`** — *"No live gauge on FL2 · see Profile"* or equivalent — and must **not** draw a flat line at target, which would read as a real in-spec measurement. Deciding the default view is worth a beat: Profile is the honest default on FL2 standalone, and the mockup defaults to Live only because Live is the one it can animate.
- **FL3 (hybrid) is the reason the toggle exists at all.** On FL3 the same variant *does* receive live gauge/width, so Live is meaningful there and the toggle lets one component serve both. Bind the toggle's availability to line mode rather than hard-coding it off.
- Speed, footage, spool weight and coil weight drive the Machine and Material-flow cards continuously; `ComponentStatus` drives the Components card dots.

## Integration Flow
`FL2 op → DB5 (scan spool, review FL1 profile, Acknowledge) → POST /checkin/spool → FL2 PLC push → Spool INFLAT → FL2 Dashboard 3 → run finishing mill`.

## Testing
- **Unit:** FL2 tag set; no-inspection path; hybrid validation guard; roll-adjust all-zero-delta short circuit; roll-adjust reason gate.
- **API:** spool check-in + gauge-trace contracts.
- **UI:** historical profile with weld markers; **command bar has no Weld and no Die Change, and does have SPC Checkpoint**; Check Out Rod disabled on a running line; Complete Coil confirms before navigating.
- **UI — the null-gauge case, the one most likely to ship wrong:** with the hub sending `null` gauge/width, the Live view shows its empty state and **does not** draw a line at target. Profile stays static across several live ticks.
- **UI — the three stands:** Components card shows **exactly three** FM2 rows — `S1` (8″), `S2` (6″), `S3` (6″, final) — with **edgers on S2 and S3 only**, and **no separate "8″ Roller" row**. *(Assertion inverted 4 Aug 2026. It previously required a four-stand list and existed to catch "a regression to the old three-stand list". The three-stand list was right all along on count; what was wrong was the roller sizes. A fourth FM2 row is now the regression.)*
- **UI — DB5A (TC-119–126):** the default list populates with no scan; a scan resolves the order and narrows the list **in one call**; **a failed scan leaves the list unchanged** (the case most likely to be got wrong, and the most annoying when it is); an unallocated spool is a single-row `200` and still checkin-able, **not** a `404`; check-in is offered only for `RECEIVED`/`STAGED`; the column set is identical in both modes.
- **UI — Roll Adjust as a dialog:** the run monitor keeps updating behind it and survives Cancel; the roll table shows **FL2's** stands from FL2 and **FL3's** from FL3; footage matches the counter at the moment of the click, not at page load; pause → *Roll adjustment* → Confirm closes the pause **then** opens the dialog, never both at once.
- **Integration:** FL1 run → spool → FL2 check-in shows correct profile.
- **Acceptance:** FL2 operator checks in a spool with its FL1 history, runs the finishing mill, records a roll adjustment without losing the run, and completes the coil.

## Deliverables
**Dashboard 5A** + Dashboard 5 + Dashboard 3 FL2 variant (status-card strip, Spool/Order grids, dual-source trace panels, grouped command bar); `GET /spools`; `POST /checkin/spool`; historical gauge-trace query; FL2 PLC tag push. **Roll Adjust dialog is a Phase 6 deliverable consumed here** — this phase supplies its FL2 context, not the dialog.

> **⚠ The 118 h estimate predates Dashboard 5A** (added 2 Aug 2026) as well as the DB3-FL2 re-mock. DB5A is a new screen plus a new endpoint in a phase already scoped at 118 h across a 10-working-day window. **Re-estimate before committing W5–W6.** It is genuinely small — read-only, one endpoint, one table, no PLC and no state change — but it is not free.

**OQ blockers:** OQ-76 (spool identifier — needs confirmation), OQ-15 (hybrid-origin FL2 validation — residual), OQ-17 (spool state machine — in progress; **now also gates DB5A**, since "available for processing" has no defined meaning without it), **OQ-18** (which order field carries the coil min–max weight range). **New for DB5A:** **OI-06** (two unmapped spool status vocabularies), **OI-02** (`SP-#####` vs `TS######`), and — the one that would invalidate the screen outright — **confirmation that `SpoolProcessing.OrderNo` is populated from planning**. If allocation is not readable by the shopfloor system, FR-098 has nothing to resolve. **Stories:** FW-064, **FW-124**, FW-070 (FL2 roll adjust reused from Phase 6 — **now a dialog, not Dashboard 11**).

---

## Client answers of 30 Jul 2026 — spool completion

**The completion basis changed.** Completion is graded against the **customer's min/max weight range from the order** (e.g. 900 lb max / 800 lb min), **by weight** — not by footage, and **not** against the previously assumed **2,000 lb default, which is withdrawn** (it had no basis and exceeds the TKUP-2 ceiling of 1,100 lb). Spools are sized at roughly **1,800 lb** so that **two finished coils** can be cut at FL2. Still open: which order field carries the range (**OQ-18**).

**A short close is a specified transaction, not an absence of one** (**OQ-79**). Closing below target is an **unplanned stop** on the mill **10-90 SOP** pattern with a reason code:

- **Inside** the customer range → continue.
- **Outside** it → **supervisor override + production hold**, or **offer to the customer under concession** before planning a remake. The offer comes first.
- **The spool is run off either way.** FL2 has **no spool stripper**, so it must be emptied and returned to FL1 whatever is decided about the material. A reject-and-remake path must never imply stopping and removing a part-full spool.

**Mid-run coil break:** the stop is **removed and a new stop starts from zero** — weight does **not** resume from the break point. Leftover incoming material is welded to the next coil on FL1; on FL2 it is run to a finished stop and offered, or scrapped.

> **Two cautions.** The **10-90 SOP document is not in this repository** and must be obtained from Operations rather than paraphrased. And the restart-from-zero rule is a **run/stop model** change, not a screen rule — verify it against `FlatWireRun`/`CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage (**OI-25**) before building.

---

## Mockup alignment of 2 Aug 2026 — DB3 FL2 variant

`dashboard_3_active_run_fl2.html` was rebuilt to the FL1 monitor's information architecture (`dashboard_3_active_run.html`), and Roll Adjust was converted from a screen to a dialog. **This section records what moved and, more usefully, what still disagrees.**

**What the screen gained.** A Machine / Material-flow / Components status-card strip in place of the old flat three-column block; collapsible **Spool Information** and **Order Information** grids, which the FL2 operator previously had to leave the screen to see; a chart tab strip with a section collapse; maximizable trace panels; a **Live / Profile** source toggle per panel; and a command bar grouped **Run events · Go to · Run control** instead of seven undifferentiated buttons. Detail in §UI Implementation.

**What the mockup fixed rather than introduced.** The Components list showed three stands with generic "Edger 1" / "Edger 2" rows, one of them on S1 — the edger placement was wrong, and the edger belongs as a stand *attribute*, not a row. It was corrected to name the edgers at S2 and S3.

> **Superseded on the stand count (4 Aug 2026).** The 2 Aug pass also expanded the list to **four** stands, reading the 21 May note (*"FM2 has **three** 6" stands (S1, S2, S3)"*) as a separate 8″ roller feeding three 6″ stands. **The client has since corrected the roller sizes: FM2 has three stands — `S1` 8″, `S2` 6″, `S3` 6″ — and the 8″ roller *is* S1.** So the original three-stand count was right and the four-stand expansion was the error; only the edger correction from that pass survives. Decision **D-26**; see `Business/BusinessRules.md` §3. **Do not re-add a fourth FM2 row.**

**Roll Adjust.** Converted 2 Aug 2026 (`roll_adjust.js`), the last in-run event screen to become a dialog — die change, SPC checkpoint, WIP rejection and rod checkout went on 1 Aug 2026. It had a second problem those did not: as a page it hard-coded FL2's spool, stands and measurements, yet it is the shared roll-adjust screen for **FL2 and FL3, which have different stand sets**. A page cannot know which line opened it. The stand set is now caller-supplied. `dashboard_11_roll_adjust.html` is a launcher only.

**Reconciled in the same pass (2 Aug 2026)** — recorded here because these were plan-side errors this phase's rework surfaced, not FL2 scope:

| # | Was | Now |
|---|---|---|
| 1 | **`Architecture/Architecture.md` contradicted itself on the FM2 stand count** — its route table (`:55`) read `8"→6"S1→6"S2 + edgers` while the authoritative equipment correction three lines below (`:58`) gave three 6" stands with edgers at S2/S3 only. | Route table corrected; `:58` gained a note naming the table as the likely source of the same stale list in three mockups. **Root cause of divergences 4–5 below.** |
| 2 | **Phase 6 called Dashboard 11 "the only routed screen in this phase"** and listed a `dashboard-11-roll-adjust` route component. | Phase 6 now states it has **no routed screens at all**, carries the roll-adjust dialog contract, and names `fw-roll-adjust-dialog`. Its "Roll Adjust FL1/FL2" user-role line was also wrong — it is **FL2 + FL3** per FR-107/108/109 and all three mockups. |
| 3 | **Phase 5's component list predated its own approved FL1 mockup** — `machine-status-panel` + `payoff-weight-bar`, an ungrouped `action-bar`, a mount-time `isLive` flag, and no owner anywhere for the collapsible info grid. | Phase 5 now declares `run-status-cards`, `info-grid`, `chart-tab-strip`, the grouped `action-bar` and a `gauge-trace-chart` that switches source at runtime — **the shared DB3 shell this phase configures rather than reimplements.** |

**Still open — check these before building:**

| # | Divergence | Where it bites |
|---|---|---|
| ~~4~~ | ~~**`dashboard_5_spool_checkin.html` still shows the superseded three-stand schedule table**~~ **CLOSED 4 Aug 2026.** DB5 now carries the correct three-stand set — `S1` (8″), `S2` (6″) + edger, `S3` (6″) + edger — with the edgers as stand attributes. | — |
| ~~5~~ | ~~**`dashboard_3_active_run_fl3.html` also still shows a three-stand Components list**~~ **CLOSED 4 Aug 2026.** Corrected with the roller-size correction, alongside DB5, DB9, DB9A, DB11, DB2-FL3 and `roll_adjust.js`. | — |
| 6 | **The prose docs still describe Roll Adjust as a screen** — master spec §4.8, `FlatWireShopfloorDashboards.md` "Dashboard 11", `Development/GapsRegister.md`, FW-070. Two of them also disagree on which lines have it (`FlatWireShopfloorDashboards.md` says FL3 only; `Development/GapsRegister.md:192` says FL1/FL2; **FR-107/108/109 and the mockups say FL2 + FL3**). | Same follow-up pass that Dashboards 6/8/12 and die change need. The launcher keeps every link resolving meanwhile. |
| 7 | **The mockup's Live trace animates simulated data**, which no FL2 standalone run will ever have. | §Real-Time carries the instruction: render an empty state on `null`, never a flat line at target. |

> **Two cautions.** The **10-90 SOP document is not in this repository** and must be obtained from Operations rather than paraphrased. And the restart-from-zero rule is a **run/stop model** change, not a screen rule — verify it against `FlatWireRun`/`CoilOutput` footage accumulation and against `CoilTraceability`'s coil-local footage (**OI-25**) before building.
