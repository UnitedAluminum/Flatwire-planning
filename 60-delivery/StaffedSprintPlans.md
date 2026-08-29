# Flat Wire Mill — Staffed Development Sprint Plan (3 Developers)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 18, 2026 — **`D-32`: there is no shared-schema migration.** `FW-001` (36 h) and `FW-002` (3 h) struck from the S2 story list; `FW-159`’s `INFLAT` write is `FlatWireDB`-local *(previously August 14, 2026 — Related Documents now points at [`TrialRunPlan.md`](TrialRunPlan.md) `[TRP]`, the client-requested six-screen trial subset. **No figure in this document changed** *(otherwise August 13, 2026 — re-baselined at three developers, yield/cost/scrap out of plan)*)*
**Document Type:** Sprint plan at a fixed team of three, with story allocation
**Status:** Published — **does not land on 30 Sep 2026.** The date below is what three developers actually deliver
**Owner:** Development leads / delivery lead
**Audience:** Development leads, delivery lead, programme management
**Shortcode:** `[SSP]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

---

> ## Read this first
>
> **Team:** **three developers**, fixed. The 2- and 4-developer scenarios were withdrawn on 13 Aug 2026 — the
> team size is decided, and carrying three plans invited comparison against options that are not on the table.
> They are recoverable from git history at `1b8814c`.
>
> **Cadence:** two-week sprints, **`S1` starting Mon 24 Aug 2026**, as directed. Working days are counted, not
> assumed — Labor Day (7 Sep) and Thanksgiving (26–27 Nov) are deducted from the sprints that contain them.
>
> **Scope:** **103 development stories.** Of the 116 in [`TaskBreakdown.md`](TaskBreakdown.md), nine are QA- or
> BA-only and carry no FE/BE/DB/RT hours, and **four are Phase 12 — coil yield, cost ledger and scrap — which is
> out of this plan by direction (13 Aug 2026)**. Both exclusions are stated rather than silently absorbed.
>
> **Basis:** **AI-assisted**, per the client decision of 23 July 2026. Each story's published hours are factored by
> its phase's retention factor from [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) §2. Total **1,396 h**
> — the 1,485 h of the full development scope less Phase 12's **89 h**.
>
> **⚠ Phase 1 is inside these sprints.** Starting `S1` on 24 Aug means the **14 Aug Phase-1 gate is not met** — it
> needs **5.0 developers** on this basis, and three people cannot deliver 483 h in the 12 working days before it.
> Phase 1 therefore consumes `S1` and most of `S2`. If some of it *is* delivered in the 30 Jul – 21 Aug run-up,
> subtract that work and the plan shortens accordingly.

---

## 1. The answer, in one table

| Team | Sprints | Finish | vs 30 Sep target | vs Q4 2026 production |
|---|---|---|---|---|
| **3 developers** | **7** | **Wed 25 Nov 2026** | **+56 days** | inside Q4, no trial margin |

**Three developers do not close the 30 Sep window.** 1,396 h against the 44 working days to 30 Sep needs
**4.0 developers sustained**, and the sprints only start on 24 Aug, which removes the 30 Jul – 21 Aug run-up from
the available capacity.

**But headcount alone does not close it either** — that arithmetic figure is a floor, not an answer. Four
developers finish **13 Nov** and five finish **30 Oct**, because the last two sprints are waiting on dependencies
rather than on capacity (§3). **No team size on this cadence reaches 30 September.**

> **This is a development date, not a go-live date.** QA, BA, UAT and contingency are excluded — see
> [`SprintPlan.md`](SprintPlan.md) for the programme view. Add UAT and stakeholder sign-off after the date above;
> `[SP §1.4]` records that UAT cannot share a sprint with feature work.

---

## 2. Three developers — 7 sprints, finish **Wed 25 Nov 2026**

| Sprint | Dates | Wk days | Capacity | Planned | Util | Stories | Phases |
|---|---|---|---|---|---|---|---|
| **S1** | 24 Aug – 04 Sep | 10 | 240 h | **245 h** | 102 % | 14 | 1A, 1B |
| **S2** | 07 Sep – 18 Sep | 9 | 216 h | **208 h** | 96 % | 18 | 1B, 1C |
| **S3** | 21 Sep – 02 Oct | 10 | 240 h | **238 h** | 99 % | 13 | 1C, 3, 4 |
| **S4** | 05 Oct – 16 Oct | 10 | 240 h | **246 h** | 102 % | 20 | 5, 6, 7 |
| **S5** | 19 Oct – 30 Oct | 10 | 240 h | **244 h** | 102 % | 21 | 7, 8, 9, 10 |
| **S6** | 02 Nov – 13 Nov | 10 | 240 h | **145 h** | 60 % | 15 | 10, 11, 13 |
| **S7** | 16 Nov – 25 Nov | 8 | 192 h | **70 h** | 36 % | 2 | 14 |
| | **24 Aug – 25 Nov 2026** | **67** | **1608 h** | **1396 h** | **87 %** | **103** | |

**The work is FE 545 h · BE 354 h · DB 202 h · RT 305 h**, about **465 h each**. A workable split is
**R1 = FE** · **R2 = BE + most DB** · **R3 = RT + the rest**. This is the smallest team where **RT gets a dedicated
owner**, which matters because RT is the stream that does not compress — `[DE §1]` prices Phase 14's commissioning
at retention **1.00**, no saving at all.

> **The per-stream figures sum to 1,406 h, not 1,396 h.** `[DE]` publishes the model two ways — a per-phase
> retention factor and a per-stream compression rate — and the two disagree by 10 h once Phase 12 is removed,
> because Phase 12's stream mix (FE 44 · BE 72 · DB 12 hand-coded) compresses differently from its phase factor.
> **The allocation and every sprint figure above use the per-phase basis**, which is the one the totals reconcile
> to.

---

## 3. Taking yield, cost and scrap out does not move the date

**Removing Phase 12 saves 89 h and finishes on exactly the same day.** That is worth stating plainly, because the
intuition is the opposite:

| | With Phase 12 | **Without Phase 12** |
|---|---|---|
| Total | 1,485 h | **1,396 h** |
| Stories | 107 | **103** |
| Sprints | 7 | **7** |
| Finish | Wed 25 Nov 2026 | **Wed 25 Nov 2026** |
| `S6` load | 234 h — **98 %** | **145 h — 60 %** |
| `S7` load | 70 h — 36 % | 70 h — **36 %** |

**The whole 89 h came out of `S6`, and `S6` was never the binding sprint.** The finish date is set by `S7`, which
exists because **Phase 14 must have a sprint to itself** — `[SP §6.1]` lists `14` last under *Must be sequential*,
and phase-14's own scope call is blunter: *"pull this into a dedicated post-feature-complete window regardless of
team size."* No amount of scope removed from earlier phases shortens a sprint that is waiting on a dependency.

**What the removal does buy is the plan's only real absorption.** `S6` falls from 98 % to **60 %** — 95 free hours
in the second-to-last sprint, immediately before the commissioning window. Every earlier sprint still runs at
96–102 %, so that is the only place a slipped story can be caught without pushing the finish date.

> ⚠ **This corrects a defect in the previous allocation, not just the scope.** The allocator was greedy in
> dependency order with **no barrier on Phase 14** — the published 7-sprint plan put Phase 14 in its own sprint
> only because nothing else fitted, and the withdrawn 4-developer plan had Phase 14 sharing `S5` with Phases 11,
> 12 and 13, **which the sequencing rule forbids**. With 89 h removed the greedy pass would have slid Phase 14 into
> `S6` and reported a 6-sprint plan finishing **Fri 13 Nov** — twelve days early and not deliverable. The barrier
> is now explicit.

---

## 4. What changes the date

| Lever | Effect | Where it is decided |
|---|---|---|
| **Deliver Phase 1 before 24 Aug** | **−483 h** — removes about two sprints | Needs 5.0 developers in the run-up; the reason the gate exists. **The largest lever by far** |
| **Let Phase 14 start inside `S6`** | **−1 sprint**; finish **Fri 13 Nov** | Contradicts `[SP §6.1]` and phase-14's scope call. **A decision to take deliberately, not a scheduling convenience** — `S6` would still hold Phases 10, 11 and 13 |
| **Add a 4th developer** | **−1 sprint**; finish **Fri 13 Nov 2026** | Only a fortnight, because **the tail is dependency-bound, not effort-bound** — at four developers `S5` falls to **31 %** and `S6` to **22 %**. Five developers finish **Fri 30 Oct**, still a month past target. *(The withdrawn 4-developer plan at `1b8814c` claimed 30 Oct; it reached it only by letting Phase 14 share a sprint.)* |
| **The retention factors are wrong** | Hand-coded is **2,114 h**, +51 % | `[DE §1]` — factors are **assumed, not measured** |

**Two reserves are excluded and neither compresses:** `G2`/`OI-39` cross-DB check-in recovery on Phase 4
(**24–64 h**) and `OQ-10`/`OI-45` footage→weight on Phase 9 (**16–32 h**). Both are design decisions, not coding
problems. **`S6`'s 95 free hours are the only place they can land without moving the date.**

> **`OQ-10` still matters even with yield out of plan.** Footage→weight is not a Phase 12 question — `FR-332` and
> the coil-completion weight calculation are **Phase 9**, and the figure is printed on every customer coil label.
> Removing yield reporting does not remove the need for the number.

---

## 5. Story → sprint allocation

All 103 development stories, in dependency order, with the sprint each lands in. **`h` is the AI-assisted
development estimate for that story.** Story ids are frozen and are the repository's join key — import against
these.

Allocation is **greedy in dependency order**: `1A/1B/1C → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 13 → 14`, per
`[SP §6.1]`, **with Phase 14 held to a sprint of its own**. A story never starts before the phase it depends on
completes. Sequential chains (`4→5→6→7`, `8→9→10`) are respected; Phase 6's five events and Phases 11/13 may run
in parallel within a sprint.

| Story | Title | Phase | Stream | h | Sprint |
|---|---|---|---|---|---|
| `FW-N03` | Angular library scaffold, routing and configuration | 1A | FE | 15 | S1 |
| `FW-130` | Shell layout and the 1280×1024 shopfloor canvas | 1A | FE | 10 | S1 |
| `FW-131` | Route guards, interceptor wiring and the error envelope | 1A | FE | 7 | S1 |
| `FW-132` | DI-swappable API client and domain models | 1A | FE | 12 | S1 |
| `FW-133` | Shared composite controls | 1A | FE | 75 | S1 |
| `FW-135` | SignalR client service | 1A | RT | 15 | S1 |
| `FW-136` | `MockSignalRService` and the typed event set | 1A | RT | 7 | S1 |
| `FW-134` | Shared primitive controls and `alert-banner` | 1A | FE | 20 | S1 |
| `FW-137` | PWA cache sync and the reconnect banner | 1A | RT | 5 | S1 |
| `FW-N04` | `FlatWire` solution and four-project Clean Architecture skeleton | 1B | BE | 11 | S1 |
| `FW-138` | Thirteen thin controllers over `UAController` | 1B | BE | 35 | S1 |
| `FW-139` | MediatR registration and pipeline behaviours | 1B | BE | 11 | S1 |
| `FW-140` | DI registration and the stub/real service swap | 1B | BE | 8 | S1 |
| `FW-141` | Repository layer | 1B | BE | 14 | S1 |
| `FW-142` | Dapper/EF data access and `FlatWireDbContext` | 1B | BE | 16 | S2 |
| `FW-144` | Configuration binding | 1B | BE | 8 | S2 |
| `FW-145` | JWT authentication and role authorization policies | 1B | BE | 11 | S2 |
| `FW-146` | Global exception middleware and the response envelope | 1B | BE | 5 | S2 |
| `FW-147` | FluentValidation and the canonical cross-layer enums | 1B | BE | 8 | S2 |
| `FW-080` | `FlatWireHub` — strongly-typed, MessagePack, line groups | 1B | RT | 22 | S2 |
| `FW-149` | `IFlatWireClient` typed event contract | 1B | RT | 11 | S2 |
| `FW-N05` | OPC ingest hosted service and bounded channel | 1B | RT | 22 | S2 |
| `FW-150` | Cadence-driven broadcast loop | 1B | RT | 11 | S2 |
| `FW-151` | `PLCTagService` skeleton and `SimulatePLCTagPush` | 1B | RT | 11 | S2 |
| `FW-143` | Serilog structured logging and the audit log | 1B | BE | 8 | S2 |
| `FW-148` | Health checks | 1B | BE | 5 | S2 |
| `FW-001` | Shared-schema column renames and new columns — **CANCELLED 18 Aug 2026, `D-32`** | 1C | DB | 0 | S2 |
| `FW-002` | `INFLAT` coil status — **CANCELLED 18 Aug 2026, `D-32`** *(`INFLAT` survives as a `FlatWireDB`-local `Rod.Status` value)* | 1C | DB | 0 | S2 |
| `FW-152` | `FlatWireDB` creation, ordered DDL runner, indexes and grants | 1C | DB | 8 | S2 |
| `FW-005` | Lookup group tables and seed | 1C | DB | 10 | S2 |
| `FW-004` | `AlloyProperty` lookup and seed | 1C | DB | 5 | S2 |
| `FW-006` | Materials group tables | 1C | DB | 8 | S2 |
| `FW-007` | Runs and Quality/Output group tables | 1C | DB | 31 | S3 |
| `FW-060` | Dashboard 1 — Line Status Overview | 3 | FE | 31 | S3 |
| `FW-153` | Alert chips, reconnect banner and cached-state fallback | 3 | FE | 14 | S3 |
| `FW-154` | `GET /lines/status` and `LineStatusService` | 3 | BE | 11 | S3 |
| `FW-155` | `FlatWireRun(LineId, Status)` index | 3 | DB | 3 | S3 |
| `FW-N06` | Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle | 3 | RT | 28 | S3 |
| `FW-061` | Dashboard 2 — Rod Check-in six-step wizard (FL1/FL3) | 4 | FE | 24 | S3 |
| `FW-157` | `POST /checkin/rod` and `CheckInService` | 4 | BE | 24 | S3 |
| `FW-159` | `RodStaging`, the check-in write path and the `INFLAT` write | 4 | DB | 19 | S3 |
| `FW-082` | PLC tag group push on check-in acknowledgement | 4 | RT | 11 | S3 |
| `FW-N01` | Dashboard 2A — Rod Pre-Check-in station | 4 | FE | 16 | S3 |
| `FW-158` | `PayoffStagingController` — staging commands and queries | 4 | BE | 18 | S3 |
| `FW-160` | `PayoffStateChanged` and the check-in broadcasts | 4 | RT | 8 | S3 |
| `FW-062` | Dashboard 3 — Active Run Monitor (FL1) and FL3 variant | 5 | FE | 21 | S4 |
| `FW-162` | `run-status-cards` | 5 | FE | 13 | S4 |
| `FW-081` | `gauge-trace-chart` live streaming, maximize and runtime source toggle | 5 | FE/RT | 18 | S4 |
| `FW-163` | `info-grid` and `chart-tab-strip` | 5 | FE | 13 | S4 |
| `FW-164` | `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService` | 5 | BE | 8 | S4 |
| `FW-165` | `sp_GetGaugeTrace` | 5 | DB | 5 | S4 |
| `FW-063` | Weld capture — `fw-mark-welded-dialog` | 6 | FE | 13 | S4 |
| `FW-073` | Die change dialog | 6 | FE | 15 | S4 |
| `FW-065` | SPC checkpoint dialog | 6 | FE | 15 | S4 |
| `FW-070` | Roll adjust dialog | 6 | FE | 18 | S4 |
| `FW-071` | Pause and Resume dialogs | 6 | FE | 15 | S4 |
| `FW-166` | `POST /weldevent` and `WeldService` | 6 | BE | 8 | S4 |
| `FW-167` | `POST /diechange` and `DieChangeService` | 6 | BE | 8 | S4 |
| `FW-168` | `POST /spc` and `SpcService` | 6 | BE | 8 | S4 |
| `FW-169` | `POST /rolloverride` and `RollOverrideService` | 6 | BE | 8 | S4 |
| `FW-170` | `POST /run/{id}/pause` and `/resume`, and `RunControlService` | 6 | BE | 5 | S4 |
| `FW-171` | The five in-run event tables | 6 | DB | 13 | S4 |
| `FW-172` | Run-event markers and the `LineStatus` transitions | 6 | RT | 13 | S4 |
| `FW-067` | WIP rejection dialog | 7 | FE | 13 | S4 |
| `FW-072` | Rod checkout dialog — Modes A, B and P | 7 | FE | 16 | S4 |
| `FW-173` | Partial rod re-check-in (carry-forward) | 7 | FE | 13 | S5 |
| `FW-174` | `POST /wipreject`, `POST /checkout` and their services | 7 | BE | 16 | S5 |
| `FW-175` | Durable supervisor pending-approval queue | 7 | BE | 10 | S5 |
| `FW-176` | `WipRejection` / `RodCheckout` tables and the shared `coils` carry-forward columns | 7 | DB | 18 | S5 |
| `FW-177` | Exception broadcasts and the supervisor notification | 7 | RT | 10 | S5 |
| `FW-124` | Dashboard 5A — FL2 Spool Queue | 8 | FE | 16 | S5 |
| `FW-064` | Dashboard 5 — FL2 Spool Check-in | 8 | FE | 10 | S5 |
| `FW-178` | Dashboard 3 FL2 variant configuration | 8 | FE | 5 | S5 |
| `FW-179` | `POST /checkin/spool` and `GET /spools` | 8 | BE | 12 | S5 |
| `FW-180` | `SpoolCheckin` table and the `SpoolProcessing.OrderNo` index | 8 | DB | 8 | S5 |
| `FW-181` | FL2 null-gauge contract and the Live/Profile binding | 8 | RT | 3 | S5 |
| `FW-N02` | Spool completion weight milestones and machine-stop confirmation | 8 | RT | 3 | S5 |
| `FW-183` | `source-traceability-table` and `skid-tracker` | 9 | FE | 26 | S5 |
| `FW-185` | `POST /coil/complete`, `GET /coil/{alpha}/label` and their services | 9 | BE | 17 | S5 |
| `FW-186` | `CoilOutput`, `CoilTraceability` and the non-overlap trigger | 9 | DB | 10 | S5 |
| `FW-066` | Dashboard 7 — Output Coil Completion | 9 | FE | 15 | S5 |
| `FW-182` | Dashboard 7b — Packing Station | 9 | FE | 15 | S5 |
| `FW-184` | `coil-label` and the print path | 9 | FE | 10 | S5 |
| `FW-187` | Completion broadcasts | 9 | RT | 5 | S5 |
| `FW-189` | Dashboard 2 and 3 FL3 variants | 10 | FE | 8 | S5 |
| `FW-190` | Hybrid single-batch PLC push and `RouteMode=Hybrid` | 10 | BE | 14 | S5 |
| `FW-191` | `RouteMode` and the no-intermediate-spool rule | 10 | DB | 3 | S6 |
| `FW-192` | Continuous end-to-end trace on FL3 | 10 | RT | 6 | S6 |
| `FW-090` | Flattening Lines report tab and reporting views | 11 | BE/DB | 23 | S6 |
| `FW-091` | Gauge Trace report | 11 | BE/FE/RT | 13 | S6 |
| `FW-092` | Gauge CPK Deviation and CPK report | 11 | BE/FE | 10 | S6 |
| `FW-093` | Coil Pass Detail report | 11 | BE/FE | 10 | S6 |
| `FW-094` | SPC at Flattening Line report | 11 | BE/FE | 10 | S6 |
| `FW-095` | Cut Traceability report | 11 | BE/FE | 10 | S6 |
| `FW-003` | Machine template tabs — register FL1, FL2, FL3 | 13 | FE | 7 | S6 |
| `FW-194` | Alloy lookup admin grid | 13 | FE | 12 | S6 |
| `FW-054` | Alloys — Material Type across Properties, Reduction Rules and Vendor O Gauge | 13 | FE | 7 | S6 |
| `FW-195` | Role assignment UI | 13 | FE | 7 | S6 |
| `FW-196` | Alloy CRUD, machine config and role config endpoints | 13 | BE | 20 | S6 |
| `FW-197` | Reference-data admin wiring | 13 | DB | 5 | S6 |
| `FW-198` | Reference-data change broadcast | 13 | RT | 2 | S6 |
| `FW-200` | PLC commissioning support | 14 | RT | 35 | S7 |
| `FW-201` | Defect allowance and renamed-column regression | 14 | BE/DB/FE | 35 | S7 |

---

## Related Documents

| Document | Why you would open it |
|---|---|
| [`TrialRunPlan.md`](TrialRunPlan.md) `[TRP]` | **A scoped subset of this plan, on a different date.** The **six screens the client requested for a trial run on 14 Aug 2026** plus their dependencies — **778 h, four sprints from 17 Aug, feature-complete 18 Sep at five developers for T1 and four thereafter.** It does **not** supersede this document: this one remains the staffed plan for all of MVP-1 development. Read it for the trial only, and note two things it carries that the 1,396 h below does not: gap **`G37`** with story **`FW-202`**, and the fact that **three developers reach ~1 Oct on development alone** once DB1 and DB2A are out — the closest any shape has come to the client's date |
| [`DevelopmentSprintPlan.md`](DevelopmentSprintPlan.md) `[DSP]` | The same development scope on the **programme** cadence at the modelled 4.2 FTE. **Note: it still includes Phase 12** |
| [`SprintPlan.md`](SprintPlan.md) `[SP]` | The programme sprint plan — QA, BA and contingency included, plus DoR/DoD and §6.1's dependency chain |
| [`TaskBreakdown.md`](TaskBreakdown.md) `[TB]` | The 116 story bodies — acceptance criteria, dependencies, `Rate-card basis:` per story |
| [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) `[DE]` | The retention factors these estimates depend on, and why RT compresses by only 14.3 % |
| [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) `[CE]` | The hours model of record and §7's three programme options |
| [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md) `[YCS]` | **Phase 12, which this plan excludes** — its four stories, its 89 h, and the note that three of them have no requirement specification at all |
