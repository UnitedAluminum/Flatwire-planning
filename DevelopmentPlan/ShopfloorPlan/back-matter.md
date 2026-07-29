# Back Matter — Dependencies, Roadmap, Gaps & Appendices

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).** See [Foundations](./00-foundations.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 14 — Integration Testing, PLC Commissioning & Go-Live](./phase-14-integration-testing-plc-commissioning-golive.md)
>
> This file collects the cross-phase planning material: the feature dependency mapping, the overall roadmap (window/milestones/risks/gaps), and Appendices A–C.

---

# FEATURE DEPENDENCY MAPPING

## Prerequisite chain (must be sequential)
```
Phase 1 (Platform: Angular scaffold + FlatWire service + FlatWireDB schema + FlatWireHub/OPC)
   └─> Phase 2 (Pass Schedule)  ── highest dependency; blocks all check-in/PLC
        └─> Phase 4 (Rod Check-in FL1/FL3 + Pre-Check-in/Dashboard 2A)  [also needs upstream rod + Phase 3 real-time]
             └─> Phase 5 (Active Run + live trace)
                  └─> Phase 6 (In-run events)
                       └─> Phase 7 (WIP/Checkout)
             └─> Phase 8 (FL2 spool check-in)  [needs an FL1-produced spool]
                  └─> Phase 9 (Coil completion/label/skid)
                       └─> Phase 10 (FL3 hybrid integration)
Upstream (external, existing systems: CoilReceiving + Planning/Scheduling)
   Rod Receiving + Order Planning/Line Scheduling ──> feed material + scheduled jobs into Phase 4
Phase 3 (Line board + real-time backbone) ──> consumed by Phases 4,5,6,8,9
Phase 4 RodStaging ──> back-feeds Phase 3 (the "Payoff2 not loaded" alert has no other data source)
                  └─> Phase 6 (PCI008: weld selection defaults to the staged rod)
                  └─> Phase 7 (Mode P pre-check-out; carry-forward gate moves to the staging scan)
Phases 11/12/13 ──> consume completed-run + reference data
Phase 14 ──> requires all critical-path phases
```

## Shared building blocks (build once, reuse everywhere)
| Shared asset | Built in | Reused by |
|---|---|---|
| `flat-wire-signalr.service` + `FlatWireHub` | Phase 1/3 | 3, 5, 6, 7, 8, 9, 11 |
| `PLCTagService` (push/clear) | Phase 1/4 | 4, 6 (roll override), 7 (checkout), 8, 10 |
| `pass-schedule-table` + confirm-bar | Phase 2/4 | 2, 4, 8 |
| `gauge-trace-chart` (live + profile) | Phase 3/5 | 5, 8, 11 |
| `FlatWireRun` hub + event tables | Phase 1 | all shopfloor phases |
| `CoilTraceability` genealogy | Phase 9 | 9, 11 (Cut Traceability), 12 (yield) |
| Alloy lookup | Phase 1 | 2 (generate), 9/12 (weight), 13 (admin) |

## Parallelisable
- **Phase 2 and 3** can run largely in parallel after Phase 1 (different teams: Ops-recipe UI, real-time backbone). Upstream rod receiving and planning/scheduling proceed independently on the existing systems. They converge at Phase 4.
- Within shopfloor: Phase 6's five events can be built in parallel by feature once Phase 5 exists.
- **Phase 11/12/13** are parallelisable back-office tracks once run data exists.
- **Must be sequential:** 2→4, 4→5→6→7, 8→9, 9→10, and 14 last.

## Cross-feature impacts / risks
- **FW-001 column renames** touch the shared `coils`/scheduling schema well beyond flat wire — do early with full impact analysis (affects upstream receiving & planning + Phases 11, 12).
- **Pass Schedule (Phase 2)** is the single hardest upstream gate — no shopfloor slice works without it.
- **OQ-14 / OQ-51 / OQ-52** each block a specific screen build; the stub check-in deliberately routes around them (single-schedule assumption) — schedule a **de-stub pass** when these close.
- **OQ-36 (footage→weight)** blocks upstream planning + Phases 9, 12.

---

# OVERALL ROADMAP

## Phase-wise implementation roadmap (development window: 17 Aug → 30 Sep 2026, ~6.5 weeks)

> **This window is aggressive** — 14 shopfloor phases (Phases 1–14; upstream rod receiving & planning/scheduling are out of shopfloor scope) in ~6.5 weeks only closes if the parallel streams below are staffed concurrently and the Critical OQs are resolved *before* their phase starts. If capacity is short, defer Phase 12 (Yield/Cost/Scrap) and non-Critical Phase-13 admin past 30 Sep (they are Medium/Low priority). See Gaps register G1.

| Week | Dates | Phase(s) | Deliverable focus | Backlog |
|---|---|---|---|---|
| W1 | Aug 17–23 | **1** Core Platform (1A/1B/1C parallel) | Angular scaffold, FlatWire service, FlatWireDB schema, hub/OPC skeleton | E01 (FW-001–007), FW-004 |
| W2 | Aug 24–30 | **2** Pass Schedule (start) · **3** real-time backbone (start) | Recipe library, hub streaming | E02, FW-080 |
| W3 | Aug 31–Sep 6 | **2** (finish) · **3** Dashboard 1 live | Generate-from-Specs; line board | E02, FW-060 |
| W4 | Sep 7–13 | **4** Rod Check-in **+ Pre-Check-in (DB2A)** · **5** Active Run + trace | PLC push + INFLAT; **`RodStaging` + payoff staging + `FL1PO`**; live gauge/width + DB13/14 | FW-061/062/081/082 |
| W5 | Sep 14–20 | **6** In-run events · **7** WIP/Checkout · **8** FL2 spool (start) | Weld/die/SPC/roll/pause; rejection/checkout; spool check-in | FW-063/065/067/070/071/072/073, FW-064 |
| W6 | Sep 21–27 | **8** (finish) · **9** Coil completion · **10** FL3 hybrid · **11** Shift/Reports | Historical profile; coil/label/skid; hybrid; shift + reports | FW-066/100, FW-122, FW-069/090–095 |
| W7 | Sep 28–30 | **12** Yield/Cost/Scrap · **13** Admin · **14** Integration/UAT | Yield/cost/scrap*; admin; 3-route E2E + UAT/sign-off | FW-101/102*/110*, FW-120–123 |

\* Medium/Low priority — first candidates to slip past 30 Sep if the window tightens.

## Development milestones
- **M1 (Aug 23):** platform ready — scaffolded UI ↔ stubbed service ↔ created schema ↔ simulated hub.
- **M2 (Sep 6):** Pass Schedule Active-able; Dashboard 1 live (upstream rod receiving & planning/scheduling assumed available on the existing systems).
- **M3 (Sep 13):** first full FL1 slice live — check-in → PLC push (simulate) → live trace.
- **M4 (Sep 20–27):** FL1 + FL2 complete a coil with traceability and label; FL3 hybrid + reporting.
- **M5 (Sep 30):** critical-path feature-complete; ready for UAT/sign-off.

## QA milestones
- **QA1 (Sep 6):** Pass Schedule + generator unit/contract suites green.
- **QA2 (Sep 13):** check-in rollback + real-time integration verified on staging; hub load test (N clients × 3 lines × cadence).
- **QA3 (Sep 24):** FL1 + FL2 E2E (FW-120/121) pass.
- **QA4 (Sep 28):** FL3 hybrid E2E (FW-122) pass; regression on renamed-column reports.
- **QA5 (Sep 30):** full UAT (FW-123); all Critical OQs closed.

## Deployment milestones
- **PLC commissioning** aligned to development completion — target **by Sep 30**; until then all lines run `SimulatePLCTagPush` + mock SignalR.
- **UAT / sign-off** — window close (**Sep 28–30**) on staging (devual-uadev001 or equivalent).
- **On-line trial** — post-sign-off (early **Oct 2026**, TBD once dates are set with Tim O./Shannon R.).
- **Production** — after trial acceptance (**Q4 2026**, TBD). *(Original Jul 1 / Aug 1 targets superseded.)*
- Deploy path: Angular `ng build` → IIS static; `dotnet publish` `FlatWire.API` → IIS app pool (**WebSockets feature enabled** — required by §0.4); DDL via ordered migration scripts.

## Risks and mitigation
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Pass Schedule not finalized before shopfloor build | High | Critical | Front-load Phase 2; stub check-in assumes single active schedule; no other workaround |
| OQ-14 / OQ-51 / OQ-52 unresolved | High | High | Stub routes around them (single-schedule); de-stub pass when decided; escalate to Tim O./Jaspreet |
| PLC commissioning slips past Sep 30 | Medium | High | `SimulatePLCTagPush` + mock SignalR keep UI fully testable; not blocked; go-live gated on commissioning, dev is not |
| FW-001 column renames break existing reports | Medium | High | Full query/SP/view audit before migration; regression at QA4 |
| OQ-36 (footage→weight) unresolved | Medium | High | Dashboard 7 shows "pending confirmation" + operator override; table-driven factor |
| SignalR drops on shop-floor network | Medium | Medium | Auto-reconnect + group re-join; PWA cache; "Reconnecting…" banner |
| 6.5-week window (Aug 17–Sep 30) / scope creep | High | High | Parallel streams; critical path only; defer Medium/Low (yield/cost/scrap, non-critical admin) past Sep 30 — see G1 |
| Touch-screen usability | Medium | Medium | Mockups for early user testing; UAT at Phase 14 start |
| Alpha-naming inconsistency (`R#####` vs `ROD-#####`) | Low | Medium | Normalize to `R#####` before the upstream rod-receiving build |

## Known Gaps & Issues Register

Consolidated review findings, prioritised. **Critical** items should be resolved before the owning phase begins; several are already resolved by the confirmed design decisions.

| ID | Gap / Issue | Area | Priority | Impact if unaddressed | Recommended resolution | Status |
|---|---|---|---|---|---|---|
| **G1** | 14 phases in a ~6.5-week window (Aug 17–Sep 30) with no capacity/effort model | Planning | **Critical** | Phases miss Sep 30; silent scope loss | Staff the parallel streams; add per-phase owners + effort; defer Phase 12 & non-critical 13 past Sep 30 | Open — window set; compression risk remains |
| **G2** | Check-in spans `FlatWireDB` (run/checkin/SPC) + existing `coils` `INFLAT` + PLC push — **not one ACID transaction** | Architecture / Data | **Critical** | Partial failure → inconsistent state; "atomic rollback" claim invalid | Saga/outbox + compensating PLC clear; or mirror an `INFLAT` marker into `FlatWireDB`; define incomplete-push recovery | Open |
| **G3** | No table persists raw AGC gauge/width readings, yet FL2 historical profile + Gauge Trace / Cut Traceability reports require them | Data / Schema | **Critical** | FL2 profile + reports have no data source | Add a time-series `RunReading` table (footage, gauge, width, ts, in-spec) + retention/rollup; make it a Phase 1/3 deliverable | Open |
| **G4** | Story→phase coverage not provable | Traceability | High | Backlog items silently dropped | Added **Appendix C** (all 58 FW-### → phase + deferred flag) | ✅ Resolved |
| **G5** | Rod source-of-truth ambiguity (new `Rod` table vs `coils`) | Data | High | Conflicting rod status | Use existing `coils` as single source of truth; drop `Rod` table | ✅ Resolved (decision 3). *Note (Jul 29 2026): the DDL/ERD still keep `Rod` as a FlatWireDB-local master under the later "Hybrid foundation" decision — see G12. The two provisional pre-check-in columns that hung off it (`StagedPayoffPosition`, `IsWelded`) are now **retired** in favour of `RodStaging`.* |
| **G6** | Roles (Operator/Ops Mgr/Maintenance/Supervisor/Admin) not confirmed as existing JWT roles vs new | Security | High | Auth may block build | Confirm role/claim mapping in `Login`; add a provisioning story if new | Open |
| **G7** | Mid-run checkout supervisor approval relies only on transient SignalR | Reliability | High | Approval lost if no supervisor connected; material stuck locked | Durable pending-approval queue + `Notification` fallback; SignalR = live nudge only | Open |
| **G8** | No data-migration deliverable for legacy `FlatLineSetup`/`FlatLineProcessing` | Data | High | Legacy data stranded on drop | Add mapping + migration + validation + drop-criteria deliverable | Open |
| **G9** | NFRs absent (AGC Hz, concurrent clients, latency, reading retention) | Performance | High | Real-time may not scale/perform | Define NFR targets; hub load test added to **QA2** (N clients × 3 lines × cadence) | Open — load test scheduled |
| **G17** | rod→`coils` multiplies cross-DB logical FKs (every `Rod.Alpha` ref) | Architecture / Data | High | No referential integrity; cross-DB joins for traceability/reports | Consistency checks + indexed alpha on `coils`; consider a replicated view / linked server for report joins | Open |
| **G14** | Pre-build data inconsistencies: 3- vs 4-item inspection (+M1/M2 ovality), `R#####` vs `ROD-#####`, `FootageFt` INT vs DECIMAL, `CoilOrderPlanId` vs `PlanId` | Data / Contract | High | Rework if resolved late | Stand up a "Pre-Build Decisions" register with owners; resolve before the owning phase | Open — `RodStaging` and Dashboard 2A deliberately use **3 inspection items** and `R#####`, and do not inherit the 4th item; that scopes the gap to check-in but does not close it |
| **G10** | Real-time deploy prereqs / MessagePack dependency | Infra | Medium | IIS WebSockets off → transport fallback; new client dep the repo doesn't use | Enable IIS WebSockets (added to deploy); treat MessagePack as **measure-first/optional** — batching+decimation is the real win | Open |
| **G11** | Phases 10/12/13 don't follow the full 8-section template | Doc consistency | Medium | Uneven detail vs stated template | Expand 10/12/13 to the full template | Open |
| **G12** | Source artifacts (DDL, `FlatWireTables.md`, ERD) still say `united_db` and include the dropped `Rod` table | Doc consistency | Medium | Conflicting source-of-truth | Retarget DDL to `FlatWireDB`; drop `Rod` DDL; update Schema docs/ERD | Open — DDL/ERD are on `FlatWireDB` and now agree at **27 tables**; the provisional `Rod.StagedPayoffPosition`/`IsWelded` columns are removed. The `Rod`-table-vs-`coils` divergence itself is unchanged |
| **G16** | PLC "rollback" wording — OPC writes are not transactional | Architecture | Medium | Misleads implementers | Reword as compensating writes (re-clear tags) — see G2 | Open — partly reworded |
| **G13** | `slitter-interface` / `CoilDataHub` reference ambiguity | Doc consistency | Low | Wrong pattern copied | Removed as a reference | ✅ Resolved (decision 5) |
| **G15** | No executive summary / 11-stage→phase map | Doc usability | Low | Hard to skim a ~1,250-line doc | Add a one-screen exec summary + process-stage→phase table | Open |
| **G19** | **Pre-check-in was fully specified in the SRS but absent from every other artifact.** `SRS §4.2 PCI001`–`PCI008` (+ `WLD010`, `TRV004`/`TRV009`, §4.18 `PRC001`–`PRC019`) define a dedicated FL1 Pre-Check-In station, yet there was no analysis note, no mockup, no data model, no API, no phase owner — and `CommonDB_Insert_WIPStations_FlatWire.sql` D2 **deliberately declined to create the station**. Root cause: `.docx` files are zip containers, so `grep` never reached the requirements; every markdown search for "pre-checkin" returned hits about the *forbidden* `checkin-precheckin` Angular library instead | Requirements / Traceability | High | A `Should`-priority feature that the continuous-feed workflow depends on would have been missed entirely; the Phase-3 "Payoff2 not loaded" alert stays unimplementable | Delivered: `Analysis/RodPreCheckin.md`, Dashboard 2A mockup, `RodStaging` table, `/staging/**` endpoints, `PayoffStateChanged`, `FL1PO` station, Phase 4 scope addition | ✅ Resolved (Jul 29 2026) — **but** two items still need business sign-off: `INFLAT`-vs-`STAGED` on staging, and whether pre-check-out needs supervisor approval |
| **G20** | Payoff position modelled **three incompatible ways**: `INT CHECK (1,2)` on rod-fed tables, an FK-style `PayoffPositionId` in `FlatWireRunDetail` pointing at a **table that did not exist**, and the API enum `{Payoff1,Payoff2}` — with FL2's traversing take-up unrepresented (`REVIEW.md` #15) | Data / Schema | Medium | Unenforced FK; no vocabulary for FL2's take-up; "payoff 3" has no meaning | Added the `PayoffPosition` lookup (3 **pinned** Ids: Payoff1, Payoff2, TraversingTakeup) and the real FK on `FlatWireRunDetail`. Rod-fed tables keep `CHECK (1,2)` as a *documented deliberate narrowing* | ✅ Resolved for the data model — `REVIEW.md` #15 stays **partly open**: `TraversingTakeup` has no UI |
| **G18** | Source docs (CLAUDE.md / CheckinImplementationPrompt) describe a `--fw-*` design system, but the actual mockups **and** `flat-wire-shopfloor.styles.scss/.css` use `--color-*` semantic tokens (no `--fw-*` anywhere); separately, DB2 was revised to the tab-wizard `- New.html` | UI / Design | Medium | Devs following the stale `--fw-*` docs build wrong token names; DB2 UI must follow the new layout | Correct `--fw-*` → `--color-*` in the source docs; build against the shared `--color-*` stylesheet as-is (no migration needed); ground every dashboard UI section in its `Mockups/*.html`; DB2 = `- New.html` tab-wizard; a new-layout FL3 check-in variant to follow | Open |

## Future enhancements (Phase 2 / post-go-live)
- EDI rod receiving + Angular receiving screen (deferred from Phase 1).
- Full spool state machine (OQ-57) and formal partial-rod carry-forward (OQ-47). *The `PRC007`/`PRC008` gate now fires at the Dashboard 2A staging scan, so a partial rod is caught before it is mounted; the full carry-forward accounting remains post-go-live.*
- Rolls-in-Flattening report, extended SCADA history, WIP Log enhancements (Low priority).
- Message broker (Kafka/RabbitMQ) if AGC throughput outgrows SignalR (revisit post-go-live).
- Die-life predictive thresholds once failure data exists (OQ-41).
- Anneal scheduling rules (OQ-20) and shared anneal-furnace capacity (OQ-46).

---

## Appendix A — `FlatWire.API` endpoint → phase map

| Endpoint | Phase |
|---|---|
| `GET /lines/status` + `FlatWireHub` | 3 |
| `GET/POST/PUT /passschedule`, `PATCH …/status`, `POST /passschedule/generate` | 2 |
| `GET /rod/{alpha}`, `POST /rod` | upstream (rod validated at check-in in 4) |
| `POST /checkin/rod` | 4 |
| `POST /checkin/spool`, `GET /run/{id}/gaugetrace` | 8 |
| `GET /run/active`, `POST /run/{id}/pause`,`/resume` | 5, 6 |
| `POST /spc` | 4 (pre-run), 6 |
| `POST /weldevent`, `/diechange`, `/rolloverride` | 6 |
| `POST /wipreject`, `/checkout` | 7 |
| `POST /coil/complete`, `GET /coil/{alpha}/label` | 9 |
| `GET /shiftsummary` | 11 |

## Appendix B — Dashboard → phase map

| Dashboard | Phase |
|---|---|
| 1 Line Status Overview | 3 |
| 2 Rod Check-in (FL1/FL3) | 4 |
| 3 Active Run Monitor (FL1/FL3) | 5 |
| 3 (FL2 variant) | 8 |
| 4 Weld Event | 6 |
| 5 FL2 Spool Check-in | 8 |
| 6 SPC Checkpoint | 4 (pre-run), 6 |
| 7 Output Coil Completion / 7b Packing | 9 |
| 8 WIP Rejection | 7 |
| 9 / 9A Pass Schedule Mgmt / List | 2 |
| 10 Shift Summary | 11 |
| 11 Roll Adjust | 6 (FL1/FL2), 10 (FL3) |
| 12 Rod Checkout (A/B) | 7 |
| DC Die Change / Die Management | 6 / 13 |
| 13 HMI Line Schematic | 5 |
| 14 SCADA Multi-Trend | 5 |

## Appendix C — Story coverage: every FW-### → phase

Every shopfloor backlog story is mapped to a phase, so coverage is provable. Rod receiving (Epic E03) and order planning / line scheduling / orders (Epics E04–E06) were removed from the shopfloor plan — they are handled upstream by the existing CoilReceiving / Planning / Scheduling systems — so their **14 stories are out of shopfloor scope** and listed under the table rather than mapped to a phase. **In scope** = targeted within the Aug 17–Sep 30 window (critical path). **Deferred** = Medium/Low priority, first to slip past Sep 30 / post-trial.

| Story | Title (short) | Phase(s) | Scope |
|---|---|---|---|
| FW-001 | Existing-schema column renames | 1 | In scope |
| FW-002 | `INFLAT` coil status | 1 (used 4) | In scope |
| FW-003 | Register FL1/FL2/FL3 machines | 13 | In scope |
| FW-004 | Alloy properties lookup | 1 (2 generate, 13 admin) | In scope |
| FW-005 | Fix existing FlatWire tables | 1 | In scope |
| FW-006 | Core entity tables | 1 | In scope — *`Rod`-table portion dropped (rod = `coils`)* |
| FW-007 | Event/output tables | 1 | In scope |
| FW-010 | Pass Schedule data model + API | 2 | In scope |
| FW-011 | Dashboard 9A — schedule list | 2 | In scope |
| FW-012 | Dashboard 9 — schedule mgmt | 2 | In scope |
| FW-013 | Generate-from-Specs algorithm | 2 | In scope |
| FW-014 | Pass-schedule override logging | 2 (used 6) | In scope |
| FW-054 | Alloys material type | 13 | In scope |
| FW-060 | Dashboard 1 — line status | 3 | In scope |
| FW-061 | Dashboard 2 — rod check-in | 4 | In scope |
| FW-062 | Dashboard 3 — active run | 5 | In scope |
| FW-063 | Dashboard 4 — weld event | 6 | In scope |
| FW-064 | Dashboard 5 — FL2 spool check-in | 8 | In scope |
| FW-065 | Dashboard 6 — SPC checkpoint | 4 (pre-run) & 6 | In scope |
| FW-066 | Dashboard 7 — coil completion | 9 | In scope |
| FW-067 | Dashboard 8 — WIP rejection | 7 | In scope |
| FW-068 | DB9/9A shopfloor integration | 2 | In scope |
| FW-069 | Dashboard 10 — shift summary | 11 | In scope |
| FW-070 | Dashboard 11 — roll adjust | 6 (FL3 in 10) | In scope |
| FW-071 | Pause/Resume dialog | 6 | In scope |
| FW-072 | Dashboard 12 — rod checkout A/B | 7 | In scope |
| FW-073 | Die Change screen | 6 (Die Mgmt in 13) | In scope |
| FW-080 | SignalR hub (`FlatWireHub`) | 1 / 3 | In scope |
| FW-081 | Live gauge-trace chart | 5 (groundwork 3) | In scope |
| FW-082 | PLC tag push on acknowledge | 4 | In scope |
| FW-090 | Reports — Flattening Lines tab | 11 | In scope |
| FW-091 | Gauge Trace report | 11 | In scope |
| FW-092 | Gauge CPK reports | 11 | In scope |
| FW-093 | Coil Pass Detail report | 11 | In scope |
| FW-094 | SPC at Flattening Line report | 11 | In scope |
| FW-095 | Cut Traceability report | 11 | In scope (needed before first shipment) |
| FW-100 | Footage-based weight calc | 9 (yield 12) | In scope |
| FW-101 | Weld traceability in yield | 12 | **Deferred candidate** (post-window) |
| FW-102 | Cost Ledger config | 12 | **Deferred** (Medium, post-trial) |
| FW-110 | Scrap Box/Skid outlet | 12 | **Deferred** (Low, post-go-live) |
| FW-120 | E2E — FL1 standalone | 14 | In scope |
| FW-121 | E2E — FL2 standalone | 14 | In scope |
| FW-122 | E2E — FL3 hybrid | 10 / 14 | In scope |
| FW-123 | UAT & stakeholder sign-off | 14 | In scope |

**Out of shopfloor scope — upstream (existing CoilReceiving / Planning / Scheduling systems):** FW-020, FW-021, FW-022 (rod receiving); FW-030, FW-031, FW-040, FW-041, FW-042, FW-043, FW-050, FW-051, FW-052, FW-053, FW-055 (orders / planning / line scheduling). These 14 stories are tracked in the upstream effort, not this shopfloor plan.

**Coverage:** 44/44 shopfloor stories mapped (58 total − 14 upstream). Deferred (first to slip past Sep 30): FW-101, FW-102, FW-110. Everything else is on the critical path.

## Related Documents
| Document | Purpose |
|---|---|
| [APIContracts.md](../APIContracts.md) | `FlatWire.API` REST + `FlatWireHub` contract |
| [FlatWireJiraStories.md](../FlatWireJiraStories.md) | Full backlog (12 epics / 58 stories) |
| [FlatWireTables.md](../FlatWireTables.md) | Table designs + existing-table renames |
| [Schema/SQL/FlatWire_ERDiagram_Documentation.md](../Schema/SQL/FlatWire_ERDiagram_Documentation.md) | Source ERD (22 tables → **21** once `Rod` is dropped per G12) |
| [../Analysis/FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md) | Screen specs (DB1–14) |
| [../Analysis/FlatWireEndToEndProcess.md](../../Analysis/FlatWireEndToEndProcess.md) | 11-stage process |
| [../Analysis/HMIAndSCADALayout.md](../../Analysis/HMIAndSCADALayout.md) | DB13/14 + PLC tag map |
| [../Analysis/FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) | Open-questions register (OQ-##) |
| [TechStackRecommendation.md](../TechStackRecommendation.md) | Stack ADR |
| [CheckinImplementationPlan.md](../CheckinImplementationPlan.md) / [CheckinImplementationPrompt.md](../CheckinImplementationPrompt.md) | Stub-first implementation model |
