# Flat Wire Mill — Staffed Development Sprint Plans (2 / 3 / 4 Developers)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — initial publication
**Document Type:** Sprint plans at three fixed team sizes, with story allocation
**Status:** Published — **none of the three lands on 30 Sep 2026.** The dates below are what each team size actually delivers
**Owner:** Development leads / delivery lead
**Audience:** Development leads, delivery lead, programme management
**Shortcode:** `[SSP]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../README.md)

---

> ## Read this first
>
> **Cadence:** two-week sprints, **`S1` starting Mon 24 Aug 2026**, as directed. Working days are counted, not
> assumed — Labor Day (7 Sep), Thanksgiving (26–27 Nov), Christmas (24–25 Dec) and New Year (1 Jan) are deducted
> from the sprints that contain them.
>
> **Scope:** the **107 development stories** of the 116 in [`TaskBreakdown.md`](TaskBreakdown.md). The other nine
> are QA- or BA-only and carry no FE/BE/DB/RT hours; they are not development work and are excluded rather than
> silently absorbed.
>
> **Basis:** **AI-assisted**, per the client decision of 23 July 2026. Each story's published hours are factored by
> its phase's retention factor from [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) §2. Total **1,485 h**
> — 1 h below that document's 1,486 h, from rounding 107 stories individually rather than 15 phases.
>
> **⚠ Phase 1 is inside these sprints.** Starting `S1` on 24 Aug means the **14 Aug Phase-1 gate is not met at any
> of these team sizes** — it needs **5.0 developers** on this basis, and 2–4 people cannot deliver 483 h in the 12
> working days before it. Phase 1 therefore consumes the first two to three sprints of every plan below. If some
> of it *is* delivered in the 30 Jul – 21 Aug run-up, subtract that work and every plan shortens accordingly.

---

## 1. The answer, in one table

| Team | Sprints | Finish | vs 30 Sep target | vs Q4 2026 production |
|---|---|---|---|---|
| **2 developers** | **10** | **Fri 8 Jan 2027** | **+100 days** | **misses Q4 entirely** |
| **3 developers** | **7** | **Wed 25 Nov 2026** | **+56 days** | inside Q4, no trial margin |
| **4 developers** | **5** | **Fri 30 Oct 2026** | **+30 days** | inside Q4, ~8 weeks of margin |

**None of the three closes the 30 Sep window**, and that is arithmetic rather than sequencing: 1,485 h against the
44 working days to 30 Sep needs **4.2 developers sustained**, and the sprints only start on 24 Aug, which removes
the 30 Jul – 21 Aug run-up from the available capacity. **Even 4 developers run 30 days past the target.**

> **These are development dates, not go-live dates.** QA, BA, UAT and contingency are excluded — see
> [`SprintPlan.md`](SprintPlan.md) for the programme view, where the same scope is **9.4 FTE**. Add UAT and
> stakeholder sign-off after the dates above; `[SP §1.4]` records that UAT cannot share a sprint with feature work.

---

## 2. Two developers — 10 sprints, finish **Fri 8 Jan 2027**

| Sprint | Dates | Wk days | Capacity | Planned | Util | Stories | Phases |
|---|---|---|---|---|---|---|---|
| **S1** | 24 Aug – 04 Sep | 10 | 160 h | **161 h** | 101 % | 8 | 1A |
| **S2** | 07 Sep – 18 Sep | 9 | 144 h | **132 h** | 92 % | 11 | 1A, 1B |
| **S3** | 21 Sep – 02 Oct | 10 | 160 h | **160 h** | 100 % | 13 | 1B, 1C |
| **S4** | 05 Oct – 16 Oct | 10 | 160 h | **166 h** | 104 % | 8 | 1C, 3, 4 |
| **S5** | 19 Oct – 30 Oct | 10 | 160 h | **163 h** | 102 % | 12 | 4, 5, 6 |
| **S6** | 02 Nov – 13 Nov | 10 | 160 h | **155 h** | 97 % | 13 | 6, 7 |
| **S7** | 16 Nov – 25 Nov | 8 | 128 h | **124 h** | 97 % | 12 | 7, 8 |
| **S8** | 30 Nov – 11 Dec | 10 | 160 h | **165 h** | 103 % | 13 | 9, 10, 11 |
| **S9** | 14 Dec – 23 Dec | 8 | 128 h | **133 h** | 104 % | 12 | 11, 13, 12 |
| **S10** | 28 Dec – 08 Jan | 9 | 144 h | **126 h** | 88 % | 5 | 12, 14 |
| | **24 Aug – 08 Jan 2027** | **94** | **1504 h** | **1485 h** | **99 %** | **107** | |

**Utilisation runs at 99 %** across the plan, which is the problem rather than an achievement: there is no absorption
anywhere. Six of the ten sprints are at or above 100 %, so a single slipped story pushes the whole tail.

**The stream mix does not fit two people.** The work is FE 572 h · BE 399 h · DB 210 h · RT 305 h, and two
developers cannot specialise. A workable split is **R1 = FE + most DB (743 h)** and **R2 = BE + all RT (743 h)** —
which makes R2 the only person who can touch OPC ingest, the tag push and commissioning. **There is no second RT
developer and no cover.**

⚠ **`S9` and `S10` straddle Christmas and New Year.** They are already short at 8 and 9 working days; any holiday
absence lands directly on the finish date.

---

## 3. Three developers — 7 sprints, finish **Wed 25 Nov 2026**

| Sprint | Dates | Wk days | Capacity | Planned | Util | Stories | Phases |
|---|---|---|---|---|---|---|---|
| **S1** | 24 Aug – 04 Sep | 10 | 240 h | **245 h** | 102 % | 14 | 1A, 1B |
| **S2** | 07 Sep – 18 Sep | 9 | 216 h | **208 h** | 96 % | 18 | 1B, 1C |
| **S3** | 21 Sep – 02 Oct | 10 | 240 h | **238 h** | 99 % | 13 | 1C, 3, 4 |
| **S4** | 05 Oct – 16 Oct | 10 | 240 h | **246 h** | 102 % | 20 | 5, 6, 7 |
| **S5** | 19 Oct – 30 Oct | 10 | 240 h | **244 h** | 102 % | 21 | 7, 8, 9, 10 |
| **S6** | 02 Nov – 13 Nov | 10 | 240 h | **234 h** | 98 % | 19 | 10, 11, 13, 12 |
| **S7** | 16 Nov – 25 Nov | 8 | 192 h | **70 h** | 36 % | 2 | 14 |
| | **24 Aug – 25 Nov 2026** | **67** | **1608 h** | **1485 h** | **92 %** | **107** | |

**`S7` is 36 % utilised** because Phase 14 is the only work left and cannot start earlier — it needs every
critical-path phase complete. That is a genuine tail, not slack to redistribute: **40 of its 70 h is PLC
commissioning**, which needs the controller and the mill, not more developers.

A workable split is **R1 = FE (495 h)** · **R2 = BE + a little FE/DB (495 h)** · **R3 = RT + the rest of DB
(495 h)**. This is the smallest team where **RT gets a dedicated owner**, which matters because RT is the stream
that does not compress.

---

## 4. Four developers — 5 sprints, finish **Fri 30 Oct 2026**

| Sprint | Dates | Wk days | Capacity | Planned | Util | Stories | Phases |
|---|---|---|---|---|---|---|---|
| **S1** | 24 Aug – 04 Sep | 10 | 320 h | **315 h** | 98 % | 20 | 1A, 1B |
| **S2** | 07 Sep – 18 Sep | 9 | 288 h | **280 h** | 97 % | 19 | 1B, 1C, 3, 4 |
| **S3** | 21 Sep – 02 Oct | 10 | 320 h | **313 h** | 98 % | 24 | 4, 5, 6 |
| **S4** | 05 Oct – 16 Oct | 10 | 320 h | **318 h** | 99 % | 27 | 7, 8, 9, 10, 11 |
| **S5** | 19 Oct – 30 Oct | 10 | 320 h | **259 h** | 81 % | 17 | 11, 13, 12, 14 |
| | **24 Aug – 30 Oct 2026** | **49** | **1568 h** | **1485 h** | **95 %** | **107** | |

**This is the only plan with real absorption** — `S5` at 81 % — and the only one that finishes with meaningful
margin inside the Q4 2026 production window.

A workable split is **R1 = FE · R2 = FE + DB · R3 = BE · R4 = RT + BE overflow**. Two FE developers matter: FE is
572 h, 38 % of the total, and `S3`–`S4` carry the four-dashboard Phase 6 and the whole FL1 operator journey.

> **`S4` is the crunch — 27 stories across five phases (7, 8, 9, 10, 11) at 99 % utilisation.** It contains the
> sequential `8→9→10` chain, so it cannot be parallelised away. If any sprint slips, it is this one.

---

## 5. What changes the dates

| Lever | Effect | Where it is decided |
|---|---|---|
| **Drop Phase 12** — wholly deferrable, descope rungs 1–4 | **−89 h**; ~half a sprint at 3–4 devs | [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md) §4. Three of its four stories **have no requirement specification at all** |
| **Deliver Phase 1 before 24 Aug** | **−483 h** — removes 2–3 sprints from every plan | Needs 5.0 developers in the run-up; the reason the gate exists |
| **The retention factors are wrong** | Hand-coded is **2,242 h**, +51 % | `[DE §1]` — factors are **assumed, not measured**. At 4 devs the hand-coded finish is **Mon 9 Nov 2026** |
| **Add a 5th developer** | ~1,188 h/sprint-pair; finish **early Oct** | Below 4.2 FTE sustained nothing reaches 30 Sep |

**Two reserves are excluded from every plan and neither compresses:** `G2`/`OI-39` cross-DB check-in recovery on
Phase 4 (**24–64 h**) and `OQ-10`/`OI-45` footage→weight on Phase 9 (**16–32 h**). Both are design decisions, not
coding problems. At 2 developers they are worth up to another half-sprint.

---

## 6. Story → sprint allocation

All 107 development stories, in dependency order, with the sprint each lands in at every team size. **`h` is the
AI-assisted development estimate for that story.** Story ids are frozen and are the repository's join key — import
against these.

Allocation is **greedy in dependency order**: `1A/1B/1C → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 13 → 12 → 14`,
per `[SP §6.1]`. A story never starts before the phase it depends on completes. Sequential chains (`4→5→6→7`,
`8→9→10`, `14` last) are respected; Phase 6's five events and Phases 11/12/13 may run in parallel within a sprint.

| Story | Title | Phase | Stream | h | 2 devs | 3 devs | 4 devs |
|---|---|---|---|---|---|---|---|
| `FW-130` | Shell layout and the 1280×1024 shopfloor canvas | 1A | FE | 10 | S1 | S1 | S1 |
| `FW-131` | Route guards, interceptor wiring and the error envelope | 1A | FE | 7 | S1 | S1 | S1 |
| `FW-132` | DI-swappable API client and domain models | 1A | FE | 12 | S1 | S1 | S1 |
| `FW-133` | Shared composite controls | 1A | FE | 75 | S1 | S1 | S1 |
| `FW-134` | Shared primitive controls and `alert-banner` | 1A | FE | 20 | S1 | S1 | S1 |
| `FW-135` | SignalR client service | 1A | RT | 15 | S1 | S1 | S1 |
| `FW-136` | `MockSignalRService` and the typed event set | 1A | RT | 7 | S1 | S1 | S1 |
| `FW-137` | PWA cache sync and the reconnect banner | 1A | RT | 5 | S2 | S1 | S1 |
| `FW-N03` | Angular library scaffold, routing and configuration | 1A | FE | 15 | S1 | S1 | S1 |
| `FW-080` | `FlatWireHub` — strongly-typed, MessagePack, line groups | 1B | RT | 22 | S3 | S2 | S1 |
| `FW-138` | Thirteen thin controllers over `UAController` | 1B | BE | 35 | S2 | S1 | S1 |
| `FW-139` | MediatR registration and pipeline behaviours | 1B | BE | 11 | S2 | S1 | S1 |
| `FW-140` | DI registration and the stub/real service swap | 1B | BE | 8 | S2 | S1 | S1 |
| `FW-141` | Repository layer | 1B | BE | 14 | S2 | S1 | S1 |
| `FW-142` | Dapper/EF data access and `FlatWireDbContext` | 1B | BE | 16 | S2 | S2 | S1 |
| `FW-143` | Serilog structured logging and the audit log | 1B | BE | 8 | S3 | S2 | S2 |
| `FW-144` | Configuration binding | 1B | BE | 8 | S2 | S2 | S1 |
| `FW-145` | JWT authentication and role authorization policies | 1B | BE | 11 | S2 | S2 | S1 |
| `FW-146` | Global exception middleware and the response envelope | 1B | BE | 5 | S2 | S2 | S1 |
| `FW-147` | FluentValidation and the canonical cross-layer enums | 1B | BE | 8 | S2 | S2 | S1 |
| `FW-148` | Health checks | 1B | BE | 5 | S3 | S2 | S2 |
| `FW-149` | `IFlatWireClient` typed event contract | 1B | RT | 11 | S3 | S2 | S2 |
| `FW-150` | Cadence-driven broadcast loop | 1B | RT | 11 | S3 | S2 | S2 |
| `FW-151` | `PLCTagService` skeleton and `SimulatePLCTagPush` | 1B | RT | 11 | S3 | S2 | S2 |
| `FW-N04` | `FlatWire` solution and four-project Clean Architecture skeleton | 1B | BE | 11 | S2 | S1 | S1 |
| `FW-N05` | OPC ingest hosted service and bounded channel | 1B | RT | 22 | S3 | S2 | S2 |
| `FW-001` | Shared-schema column renames and new columns | 1C | DB | 36 | S3 | S2 | S2 |
| `FW-002` | `INFLAT` coil status | 1C | DB | 3 | S3 | S2 | S2 |
| `FW-004` | `AlloyProperty` lookup and seed | 1C | DB | 5 | S3 | S2 | S2 |
| `FW-005` | Lookup group tables and seed | 1C | DB | 10 | S3 | S2 | S2 |
| `FW-006` | Materials group tables | 1C | DB | 8 | S3 | S2 | S2 |
| `FW-007` | Runs and Quality/Output group tables | 1C | DB | 31 | S4 | S3 | S2 |
| `FW-152` | `FlatWireDB` creation, ordered DDL runner, indexes and grants | 1C | DB | 8 | S3 | S2 | S2 |
| `FW-060` | Dashboard 1 — Line Status Overview | 3 | FE | 31 | S4 | S3 | S2 |
| `FW-153` | Alert chips, reconnect banner and cached-state fallback | 3 | FE | 14 | S4 | S3 | S2 |
| `FW-154` | `GET /lines/status` and `LineStatusService` | 3 | BE | 11 | S4 | S3 | S2 |
| `FW-155` | `FlatWireRun(LineId, Status)` index | 3 | DB | 3 | S4 | S3 | S2 |
| `FW-N06` | Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle | 3 | RT | 28 | S4 | S3 | S2 |
| `FW-061` | Dashboard 2 — Rod Check-in six-step wizard (FL1/FL3) | 4 | FE | 24 | S4 | S3 | S2 |
| `FW-082` | PLC tag group push on check-in acknowledgement | 4 | RT | 11 | S5 | S3 | S3 |
| `FW-157` | `POST /checkin/rod` and `CheckInService` | 4 | BE | 24 | S4 | S3 | S3 |
| `FW-158` | `PayoffStagingController` — staging commands and queries | 4 | BE | 18 | S5 | S3 | S3 |
| `FW-159` | `RodStaging`, the check-in write path and the cross-DB `INFLAT` write | 4 | DB | 19 | S5 | S3 | S3 |
| `FW-160` | `PayoffStateChanged` and the check-in broadcasts | 4 | RT | 8 | S5 | S3 | S3 |
| `FW-N01` | Dashboard 2A — Rod Pre-Check-in station | 4 | FE | 16 | S5 | S3 | S3 |
| `FW-062` | Dashboard 3 — Active Run Monitor (FL1) and FL3 variant | 5 | FE | 21 | S5 | S4 | S3 |
| `FW-081` | `gauge-trace-chart` live streaming, maximize and runtime source toggle | 5 | FE/RT | 18 | S5 | S4 | S3 |
| `FW-162` | `run-status-cards` | 5 | FE | 13 | S5 | S4 | S3 |
| `FW-163` | `info-grid` and `chart-tab-strip` | 5 | FE | 13 | S5 | S4 | S3 |
| `FW-164` | `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService` | 5 | BE | 8 | S5 | S4 | S3 |
| `FW-165` | `sp_GetGaugeTrace` | 5 | DB | 5 | S5 | S4 | S3 |
| `FW-063` | Weld capture — `fw-mark-welded-dialog` | 6 | FE | 13 | S5 | S4 | S3 |
| `FW-065` | SPC checkpoint dialog | 6 | FE | 15 | S6 | S4 | S3 |
| `FW-070` | Roll adjust dialog | 6 | FE | 18 | S6 | S4 | S3 |
| `FW-071` | Pause and Resume dialogs | 6 | FE | 15 | S6 | S4 | S3 |
| `FW-073` | Die change dialog | 6 | FE | 15 | S6 | S4 | S3 |
| `FW-166` | `POST /weldevent` and `WeldService` | 6 | BE | 8 | S6 | S4 | S3 |
| `FW-167` | `POST /diechange` and `DieChangeService` | 6 | BE | 8 | S6 | S4 | S3 |
| `FW-168` | `POST /spc` and `SpcService` | 6 | BE | 8 | S6 | S4 | S3 |
| `FW-169` | `POST /rolloverride` and `RollOverrideService` | 6 | BE | 8 | S6 | S4 | S3 |
| `FW-170` | `POST /run/{id}/pause` and `/resume`, and `RunControlService` | 6 | BE | 5 | S6 | S4 | S3 |
| `FW-171` | The five in-run event tables | 6 | DB | 13 | S6 | S4 | S3 |
| `FW-172` | Run-event markers and the `LineStatus` transitions | 6 | RT | 13 | S6 | S4 | S3 |
| `FW-067` | WIP rejection dialog | 7 | FE | 13 | S6 | S4 | S4 |
| `FW-072` | Rod checkout dialog — Modes A, B and P | 7 | FE | 16 | S6 | S4 | S4 |
| `FW-173` | Partial rod re-check-in (carry-forward) | 7 | FE | 13 | S7 | S5 | S4 |
| `FW-174` | `POST /wipreject`, `POST /checkout` and their services | 7 | BE | 16 | S7 | S5 | S4 |
| `FW-175` | Durable supervisor pending-approval queue | 7 | BE | 10 | S7 | S5 | S4 |
| `FW-176` | `WipRejection` / `RodCheckout` tables and the shared `coils` carry-forward columns | 7 | DB | 18 | S7 | S5 | S4 |
| `FW-177` | Exception broadcasts and the supervisor notification | 7 | RT | 10 | S7 | S5 | S4 |
| `FW-064` | Dashboard 5 — FL2 Spool Check-in | 8 | FE | 10 | S7 | S5 | S4 |
| `FW-124` | Dashboard 5A — FL2 Spool Queue | 8 | FE | 16 | S7 | S5 | S4 |
| `FW-178` | Dashboard 3 FL2 variant configuration | 8 | FE | 5 | S7 | S5 | S4 |
| `FW-179` | `POST /checkin/spool` and `GET /spools` | 8 | BE | 12 | S7 | S5 | S4 |
| `FW-180` | `SpoolCheckin` table and the `Spool.OrderNo` index | 8 | DB | 8 | S7 | S5 | S4 |
| `FW-181` | FL2 null-gauge contract and the Live/Profile binding | 8 | RT | 3 | S7 | S5 | S4 |
| `FW-N02` | Spool completion weight milestones and machine-stop confirmation | 8 | RT | 3 | S7 | S5 | S4 |
| `FW-066` | Dashboard 7 — Output Coil Completion | 9 | FE | 15 | S8 | S5 | S4 |
| `FW-182` | Dashboard 7b — Packing Station | 9 | FE | 15 | S8 | S5 | S4 |
| `FW-183` | `source-traceability-table` and `skid-tracker` | 9 | FE | 26 | S8 | S5 | S4 |
| `FW-184` | `coil-label` and the print path | 9 | FE | 10 | S8 | S5 | S4 |
| `FW-185` | `POST /coil/complete`, `GET /coil/{alpha}/label` and their services | 9 | BE | 17 | S8 | S5 | S4 |
| `FW-186` | `CoilOutput`, `CoilTraceability` and the non-overlap trigger | 9 | DB | 10 | S8 | S5 | S4 |
| `FW-187` | Completion broadcasts | 9 | RT | 5 | S8 | S5 | S4 |
| `FW-189` | Dashboard 2 and 3 FL3 variants | 10 | FE | 8 | S8 | S5 | S4 |
| `FW-190` | Hybrid single-batch PLC push and `RouteMode=Hybrid` | 10 | BE | 14 | S8 | S5 | S4 |
| `FW-191` | `RouteMode` and the no-intermediate-spool rule | 10 | DB | 3 | S8 | S6 | S4 |
| `FW-192` | Continuous end-to-end trace on FL3 | 10 | RT | 6 | S8 | S6 | S4 |
| `FW-090` | Flattening Lines report tab and reporting views | 11 | BE/DB | 23 | S8 | S6 | S4 |
| `FW-091` | Gauge Trace report | 11 | BE/FE/RT | 13 | S8 | S6 | S4 |
| `FW-092` | Gauge CPK Deviation and CPK report | 11 | BE/FE | 10 | S9 | S6 | S5 |
| `FW-093` | Coil Pass Detail report | 11 | BE/FE | 10 | S9 | S6 | S5 |
| `FW-094` | SPC at Flattening Line report | 11 | BE/FE | 10 | S9 | S6 | S5 |
| `FW-095` | Cut Traceability report | 11 | BE/FE | 10 | S9 | S6 | S5 |
| `FW-003` | Machine template tabs — register FL1, FL2, FL3 | 13 | FE | 7 | S9 | S6 | S5 |
| `FW-054` | Alloys — Material Type across Properties, Reduction Rules and Vendor O Gauge | 13 | FE | 7 | S9 | S6 | S5 |
| `FW-194` | Alloy lookup admin grid | 13 | FE | 12 | S9 | S6 | S5 |
| `FW-195` | Role assignment UI | 13 | FE | 7 | S9 | S6 | S5 |
| `FW-196` | Alloy CRUD, machine config and role config endpoints | 13 | BE | 20 | S9 | S6 | S5 |
| `FW-197` | Reference-data admin wiring | 13 | DB | 5 | S9 | S6 | S5 |
| `FW-198` | Reference-data change broadcast | 13 | RT | 2 | S9 | S6 | S5 |
| `FW-100` | Footage-based yield and the weight formula | 12 | BE/FE | 33 | S9 | S6 | S5 |
| `FW-101` | Weld traceability attribution in yield | 12 | BE | 14 | S10 | S6 | S5 |
| `FW-102` | Flat-wire cost ledger configuration | 12 | BE/DB/FE | 25 | S10 | S6 | S5 |
| `FW-110` | Scrap Box / Scrap Skid outlet | 12 | BE/DB/FE | 17 | S10 | S6 | S5 |
| `FW-200` | PLC commissioning support | 14 | RT | 35 | S10 | S7 | S5 |
| `FW-201` | Defect allowance and renamed-column regression | 14 | BE/DB/FE | 35 | S10 | S7 | S5 |

---

## Related Documents

| Document | Why you would open it |
|---|---|
| [`DevelopmentSprintPlan.md`](DevelopmentSprintPlan.md) `[DSP]` | The same development scope on the **programme** cadence, at the modelled 4.2 FTE rather than a fixed team size |
| [`SprintPlan.md`](SprintPlan.md) `[SP]` | The programme sprint plan — QA, BA and contingency included, plus DoR/DoD and the dependency chain |
| [`TaskBreakdown.md`](TaskBreakdown.md) `[TB]` | The 116 story bodies — acceptance criteria, dependencies, `Rate-card basis:` per story |
| [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) `[DE]` | The retention factors these estimates depend on, and why RT compresses by only 14.3 % |
| [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) `[CE]` | The hours model of record and §7's three programme options |
