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
| `PLCTagService` (push/clear) — surface in [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md), implementation in [`PLCTagImplementation.md`](../PLCTagImplementation.md) | Phase 1/4 | 4, 6 (roll override), 7 (checkout), 8, 10 |
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

> **This window does not close as scoped — this is now arithmetic, not judgement.** 14 shopfloor phases (**1 platform + 13 workflow phases 2–14**; upstream rod receiving & planning/scheduling are out of shopfloor scope) total **~3,660 hours** (457.5 dev-days, after the 4 Aug DB13/DB14 descope removed 67 h from Phase 5) against **32 post-gate working days** (44 including the run-up to the Aug-14 gate, i.e. **352 h per person**). That is **10.6 people sustained**, a **10.7-FTE Phase-1 gate**, and an arithmetically impossible **27.2 FTE in W7**. The full descope ladder recovers only **10%** (381 h), leaving **9.3 FTE** — **the DB13/DB14 descope did not help here.** Their 67 h left the plan, but it left the *ladder* too, so the residual after cutting everything is unchanged and Phase 5 is no longer deferrable at all. Deferring Phase 12 and non-Critical Phase-13 admin — the mitigation previously recorded here — is worth **276 h ≈ 0.8 FTE**, roughly an order of magnitude short. On a hands-on-keyboard reading (6.5 productive h/day) the requirement is **13.0 FTE**, not 10.6. See **[Capacity & Effort Model](../CapacityAndEffortModel.md)** for the per-phase derivation, the required-FTE-by-week table, the descope ladder, and the three options (staff up / move the date / cut scope). Gaps register **G1**.

**Working days are counted, not assumed:** **Labor Day falls on Mon 7 Sep 2026** (inside W4) and W7 holds only 3 days. Per-phase effort and owner live in each phase file's doc-control block and in the [roadmap nav table](../ShopfloorAndRealTimePlan.md#roadmap-navigation).

| Week | Dates | Wk days | Cap/person | Phase(s) | Hours | Peak FTE | Deliverable focus | Backlog |
|---|---|---|---|---|---|---|---|---|
| **W0** | to **Aug 14** | 12 | 96 h | **1** Core Platform (1A/1B/1C parallel) — **hard gate** | 1,027 | **10.7** | Angular scaffold, FlatWire service, FlatWireDB schema, hub/OPC skeleton | E01 (FW-001–007), FW-004 |
| W1 | Aug 17–21 | 5 | 40 h | **1** completion / carry-over | — | 0.0 | *the only slack in the plan — the whole recovery budget* | — |
| W2 | Aug 24–28 | 5 | 40 h | **2** Pass Schedule (start) · **3** real-time backbone (start) | 211 | 5.3 | Recipe library, hub streaming | E02, FW-080 |
| W3 | Aug 31–Sep 4 | 5 | 40 h | **2** (finish) · **3** Dashboard 1 live | 210 | 5.3 | Generate-from-Specs; line board | E02, FW-060 |
| W4 | Sep 8–11 | **4** | **32 h** | **4** Rod Check-in **+ Pre-Check-in (DB2A)** · **5** Active Run + trace | 409 | **12.8** | PLC push + INFLAT; **`RodStaging` + payoff staging + `FL1PO`**; live gauge/width *(DB13/14 descoped 4 Aug — −67 h)* | FW-061/062/081/082 |
| W5 | Sep 14–18 | 5 | 40 h | **6** In-run events · **7** WIP/Checkout · **8** FL2 spool (start) | 562 | **14.1** | Weld/die/SPC/roll/pause; rejection/checkout; spool check-in | FW-063/065/067/070/071/072/073, FW-064 |
| W6 | Sep 21–25 | 5 | 40 h | **8** (finish) · **9** Coil completion · **10** FL3 hybrid · **11** Shift/Reports | 588 | **14.7** | Historical profile; coil/label/skid; hybrid; shift + reports | FW-066/100, FW-122, FW-069/090–095 |
| W7 | Sep 28–30 | **3** | **24 h** | **12** Yield/Cost/Scrap · **13** Admin · **14** Integration/UAT | 653 | **27.2** | Yield/cost/scrap*; admin; 3-route E2E + UAT/sign-off | FW-101/102*/110*, FW-120–123 |

\* Medium/Low priority — rungs 1–4 of the descope ladder; see the model §5 for the full ordered ladder, what each rung costs the business, and the latest date each call can be made.

**W4 loses Labor Day; W7 is 3 days.** Post-gate total **32 working days** (256 h/person); whole window **44** = **352 h/person**. **W7 cannot hold Phase 14** — UAT and stakeholder sign-off cannot start the same day feature work completes, at any team size.

## Development milestones
- **M1 (Aug 14):** platform ready — scaffolded UI ↔ stubbed service ↔ created schema ↔ simulated hub. **Hard gate** (user mandate; supersedes the earlier M1 of Aug 23, per `REVIEW.md` #31). Also the **calibration checkpoint** for the effort model — record Phase 1 actual hours vs the **370 / 442 / 215 h** estimates and restate the rate card.
- **M2 (Sep 6):** Pass Schedule Active-able; Dashboard 1 live (upstream rod receiving & planning/scheduling assumed available on the existing systems).
- **M3 (Sep 13):** first full FL1 slice live — check-in → PLC push (simulate) → live trace.
- **M4 (Sep 20–27):** FL1 + FL2 complete a coil with traceability and label; FL3 hybrid + reporting.
- **M5 (Sep 30):** critical-path feature-complete; ready for UAT/sign-off.

## QA milestones
- **QA0 (Aug 14):** Phase-1 gate suites green — Jest smoke (1A), xUnit + stub-fixture + validator suites (1B), DDL/seed idempotency + 22-table post-run checks (1C). Re-baselined to the Aug-14 gate per `REVIEW.md` #31.
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
| **6.5-week window (Aug 17–Sep 30) is 3,727 hours against 32 post-gate working days** | **Certain** (measured, not forecast) | **Critical** | Not mitigable by parallelism or descoping: the full ladder recovers 12% (448 h, leaving 9.3 FTE), and deferring Phase 12 + non-critical 13 is worth 276 h ≈ 0.8 FTE against a 10.6-FTE requirement. Requires a programme decision — staff to ~11 FTE, move the date (6 FTE → 18 Nov; 8 FTE → 22 Oct, both inside the planned Q4 window), or cut scope below the critical path. See [Capacity & Effort Model](../CapacityAndEffortModel.md) §5–§7 and G1 |
| Phase-1 gate (Aug 14) needs 1,027 h — 10.7 FTE across 12 working days (96 h/person) | High | **Critical** | 1A/1B/1C genuinely parallelise, so this is headcount not sequencing. Decide staffing or cut Phase-1 scope before the gate; the model calibrates on Phase 1 actuals (model §6) |
| UAT + sign-off share W7 (3 days) with Phase 12/13 feature work | High | High | Pull Phase 14 UAT into a dedicated post-feature-complete window whichever date that lands on — independent of team size (model §7) |
| Touch-screen usability | Medium | Medium | Mockups for early user testing; UAT at Phase 14 start |
| Alpha-naming inconsistency (`R#####` vs `ROD-#####`) | Low | Medium | Normalize to `R#####` before the upstream rod-receiving build |

## Known Gaps & Issues Register

Consolidated review findings, prioritised. **Critical** items should be resolved before the owning phase begins; several are already resolved by the confirmed design decisions.

| ID | Gap / Issue | Area | Priority | Impact if unaddressed | Recommended resolution | Status |
|---|---|---|---|---|---|---|
| **G1** | 14 phases (1 platform + 13 workflow phases 2–14) in a ~6.5-week window (Aug 17–Sep 30) with no capacity/effort model | Planning | **Critical** | Phases miss Sep 30; silent scope loss | Delivered: **[`CapacityAndEffortModel.md`](../CapacityAndEffortModel.md)** — six delivery streams + roster, a published unit-rate card, per-phase effort **in hours** for all 17 phase specs (**3,727 h**), a working-day capacity model, an ordered descope ladder, and a calibration checkpoint at the Aug-14 gate. Per-phase **Owner** + **Effort** stamped on every phase file (also closes `REVIEW.md` #53) and surfaced in the roadmap nav table; week grid re-baselined to W0/Aug-14 with Labor Day deducted (closes `REVIEW.md` #31) | ✅ **Resolved (Jul 30 2026) for the model — but the finding is worse than the gap stated.** The plan is **3,727 hours against 32 post-gate working days (44 total = 352 h/person)** = **10.6 FTE sustained**, a **10.7-FTE Phase-1 gate**, and an impossible **27.2 FTE in W7**. G1's own recommended mitigation (defer Phase 12 + non-critical 13) is worth **276 h ≈ 0.8 FTE**; the *full* descope ladder recovers only **12%** (448 h), leaving 9.3 FTE. **Two residuals: (1)** the §1 roster is unfilled, so required-vs-available FTE cannot be computed — programme management must complete it; **(2)** the 30 Sep date now requires an explicit decision (staff to ~11 FTE / move the date / cut below critical path — model §7). The escalation, not the model, is the open item |
| **G2** | Check-in spans `FlatWireDB` (run/checkin/SPC) + existing `coils` `INFLAT` + PLC push — **not one ACID transaction** | Architecture / Data | **Critical** | Partial failure → inconsistent state; "atomic rollback" claim invalid | Saga/outbox + compensating PLC clear; or mirror an `INFLAT` marker into `FlatWireDB`; define incomplete-push recovery. The PLC side of the boundary — what is written, in what order, and what the compensating re-clear has to undo — is specified in [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) §4.5 and §6.3, and tracked there as a project-owned item (§13.2). **Settle `G30` first** — whether the FL3 push crosses a controller boundary determines whether there are one or two failure domains to compensate | Open |
| **G3** | No table persists raw AGC gauge/width readings, yet FL2 historical profile + Gauge Trace / Cut Traceability reports require them | Data / Schema | **Critical** | FL2 profile + reports have no data source | Add a time-series `RunReading` table (footage, gauge, width, ts, in-spec) + retention/rollup; make it a Phase 1/3 deliverable | Open |
| **G4** | Story→phase coverage not provable | Traceability | High | Backlog items silently dropped | Added **Appendix C** (all 58 FW-### → phase + deferred flag) | ✅ Resolved |
| **G5** | Rod source-of-truth ambiguity (new `Rod` table vs `coils`) | Data | High | Conflicting rod status | Use existing `coils` as single source of truth; drop `Rod` table | ✅ Resolved (decision 3). *Note (Jul 29 2026): the DDL/ERD still keep `Rod` as a FlatWireDB-local master under the later "Hybrid foundation" decision — see G12. The two provisional pre-check-in columns that hung off it (`StagedPayoffPosition`, `IsWelded`) are now **retired** in favour of `RodStaging`.* |
| **G6** | Roles (Operator/Ops Mgr/Maintenance/Supervisor/Admin) not confirmed as existing JWT roles vs new | Security | High | Auth may block build | Confirm role/claim mapping in `Login`; add a provisioning story if new | Open |
| **G7** | Mid-run checkout supervisor approval relies only on transient SignalR | Reliability | High | Approval lost if no supervisor connected; material stuck locked | Durable pending-approval queue + `Notification` fallback; SignalR = live nudge only | Open |
| **G8** | No data-migration deliverable for legacy `FlatLineSetup`/`FlatLineProcessing` | Data | High | Legacy data stranded on drop | Add mapping + migration + validation + drop-criteria deliverable | Open |
| **G9** | NFRs absent (AGC Hz, concurrent clients, latency, reading retention) | Performance | High | Real-time may not scale/perform | Define NFR targets; hub load test added to **QA2** (N clients × 3 lines × cadence). The **end-to-end latency figure** this gap needs is produced by commissioning test **`C8`** (*"AGC feed reaches the screen"*), reproduced with the rest of the sequence in [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) §11; the AGC publish rate is asked as **`PLC-Q11`** | Open — load test scheduled |
| **G17** | rod→`coils` multiplies cross-DB logical FKs (every `Rod.Alpha` ref) | Architecture / Data | High | No referential integrity; cross-DB joins for traceability/reports | Consistency checks + indexed alpha on `coils`; consider a replicated view / linked server for report joins | Open |
| **G14** | Pre-build data inconsistencies: 3- vs 4-item inspection (+M1/M2 ovality), `R#####` vs `ROD-#####`, `FootageFt` INT vs DECIMAL, `CoilOrderPlanId` vs `PlanId` | Data / Contract | High | Rework if resolved late | Stand up a "Pre-Build Decisions" register with owners; resolve before the owning phase | Open — `RodStaging` and Dashboard 2A deliberately use **3 inspection items** and `R#####`, and do not inherit the 4th item; that scopes the gap to check-in but does not close it |
| **G10** | Real-time deploy prereqs / MessagePack dependency | Infra | Medium | IIS WebSockets off → transport fallback; new client dep the repo doesn't use | Enable IIS WebSockets (added to deploy); treat MessagePack as **measure-first/optional** — batching+decimation is the real win | Open |
| **G11** | Phases 10/12/13 don't follow the full 8-section template | Doc consistency | Medium | Uneven detail vs stated template | Expand 10/12/13 to the full template | Open |
| **G12** | Source artifacts (DDL, `FlatWireTables.md`, ERD) still say `united_db` and include the dropped `Rod` table | Doc consistency | Medium | Conflicting source-of-truth | Retarget DDL to `FlatWireDB`; drop `Rod` DDL; update Schema docs/ERD | Open — DDL/ERD are on `FlatWireDB` and now agree at **27 tables**; the provisional `Rod.StagedPayoffPosition`/`IsWelded` columns are removed. The `Rod`-table-vs-`coils` divergence itself is unchanged |
| **G16** | PLC "rollback" wording — OPC writes are not transactional | Architecture | Medium | Misleads implementers | Reword as compensating writes (re-clear tags) — see G2 | **Resolved for wording (Aug 4 2026)** — the compensating re-clear is now stated normatively in [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) §4.5, and the four interface sections that carried the misleading "rolled back" phrasing are replaced by pointers to it. **✅ Closed 4 Aug 2026.** The residual is gone: `FR-073` no longer says "a single transactional batch" and `FR-074` no longer says "the batch shall be rolled back" — it now states the compensating re-clear directly. **Nothing in the repo now describes the tag batch as transactional or rolled back.** See also **G30**, which decides whether that re-clear spans one controller or two |
| **G29** | **No edger tag path exists on any line, yet edge type is in the push payload.** Four of five sources list *edge type* among the values written to the PLC at check-in acknowledgement, and FM2 carries edgers at **S2 and S3** — its two 6″ stands (`D-20`/`D-26`). But the only edger-adjacent tag in any published map is **`FL1.EdgeSet.Status.Active`** — on FL1, **the one line with no edger**. S2's and S3's edgers have no activation, status or blade-profile path anywhere. The write side is therefore specified to configure equipment the read side cannot address | Data / Integration | **High** | The FL2/FL3 edge configuration cannot be pushed or verified; an edge-type push either silently no-ops or faults at commissioning, and there is no tag to read back to tell which | Paths are **proposed** from the derived naming grammar in [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) §2.4 (`FL2.FM2.S2.Edger.Status.Active`, `.Edger.Profile`, and the same for S3) so the client has something concrete to confirm or correct — they are **our invention and marked as such**. Confirm with the controls engineer as **`PLC-Q07`** / **Q86**. Overlaps **Q42** (blade profiles — the reference data these tags would carry) | Open — raised Aug 4 2026 from the PLC tag-surface consolidation. **Narrowed Aug 4 2026 by the roller-size correction:** the overlap with **OI-36** is gone — that item claimed the same stand had no *roll-gap* path either, and it is now closed, because FM2 has three stands and the published map supplied three stations. **The edger half stands unchanged and is the whole of this gap:** no edger has an activation, status or blade-profile path on any line |
| **G30** | **FM2's controller namespace on FL3 is undetermined, and it decides what partial failure means.** Every published tag map addresses the finishing stands as **`FL2.FM2.…`** — including the map headed *"FL1 shown, other lines follow the same pattern"*. FL3 is the hybrid route and pushes **FM1 and FM2 in a single batch on one acknowledgement** (`phase-10:35`). So either FM2 is owned by the FL2 controller and FL3 reaches it through the `FL2.*` namespace — in which case **the FL3 push crosses a controller boundary** — or FL3 has its own `FL3.FM2.*` space and it does not | Architecture / Integration | **High** | A two-controller push is exactly the case where "the batch was rolled back" is least true (**G16**): FM1 can take its tags while FM2 refuses, and the compensating re-clear must then span both. The recovery path is being designed without knowing whether there are one or two failure domains | Answer **`PLC-Q08`** / **Q87** before finalising the Phase-4 compensating-write design. **Commissioning test `C5` cannot settle it as written** — *"one acknowledgement configures FM1 and FM2"* passes under either topology — so `C5` needs a step recording which controller(s) were written. Feeds **G2**/**OI-39** | Open — raised Aug 4 2026 from the PLC tag-surface consolidation |
| **G31** | **Several read tags lost their only consumer when DB13/DB14 were descoped.** The published *"used in"* columns attributed most machine reads to the HMI schematic and the trend charts. With both withdrawn (Aug 4 2026), the per-component **roll-gap and status** tags — `FL1.DB1`/`DB2.Status.IsActive`, `FL1.FM1.RollGap` and `.Status.*`, and all three `FL2.FM2.S*.RollGap`/`.Status` — have **no named surviving consumer**, and `FL1.EdgeSet.Status.IsActive` has none at all (see **G29**). The gauge, width, speed, weight, footage and line-state tags are unaffected — they serve the run monitor, the line status board, the checkout gatekeeper and the spool prompt | Integration / Requirements | Medium | Two opposite errors, both silent: subscribing to tags nothing reads wastes scarce commissioning time on paths no screen will reveal as wrong; dropping one that Dashboard 3's machine-status grid turns out to need is a missing value on the run cockpit found after go-live | Resolve each against **Dashboard 3's kept machine-status grid** (`FR-113`) and the component panel. [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) §3.5 publishes every affected row as **`[NO REMAINING CONSUMER — confirm before subscribing]`** rather than deleting it, so the decision is visible and reversible | Open — raised Aug 4 2026 from the HMI/SCADA descope |
| **G32** | **The FM2 PLC station names in the spec are ours, not the controller's.** The **4 Aug 2026 roller-size correction** established that FM2 has three stands (`S1` 8″, `S2` 6″, `S3` 6″) and that roll diameter is machine data, not part of an address — so [`PLCTagSpecification.md`](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) renames the station segment to bare position: `FL2.FM2.S1/S2/S3`. But the controller's **observed** names are `Stand8`, `Stand6S1` and `Stand6S2`, and those three rows were `[CONFIRMED] by observation` — **the smaller of the two places where the specification departs from a path we have actually seen** (see **G33**, which departs from thirteen) | Integration | **High** | Every FM2 read subscription and every FM2 write resolves against a path string we invented. A wrong path **fails silently** — no exception, no screen change, and a check-in that appears to succeed while the mill keeps its previous gaps | Every affected row is **`[PROPOSED]`**. Answer as **`PLC-Q04`** / **Q94** before the Phase-4 tag-push build hardens the configuration; **commissioning test `C11`** records the path string the controller actually accepted. **If the rename is rejected, reverting is a three-string edit** — the stand count and the diameters are not affected either way. **The observed originals are no longer in the client document** — it may carry no old/new content — so they are recorded in **Q94** in the open-questions register, which is now their only home outside git | Open — raised Aug 4 2026 with the roller-size correction. Replaces the closed **OI-36**, which asked the *opposite* question (a stand with no path) and turned out to rest on a stand that does not exist |
| **G33** | **The measure segment of every tag is ours, not the controller's — and it departs from thirteen observed strings.** On 4 Aug 2026 the measure names were respecified: **analogues became a single bare segment** (`.RollGap.Current`→`.RollGap`, `.Gauge.Current`→`.Gauge`, `.Width.Current`→`.Width`, `.Footage.Current`→`.Footage`, `.Die.ActiveDiameter`→`.Diameter`, `.Weight.Lb`→`.Weight`, `Speed.FPM`→`Speed`) and **booleans kept a `Status` group and took an `Is` prefix** (`.Status.Active`→`.Status.IsActive`, `.Status.Fault`→`.Status.IsFaulted`). Element and station segments are untouched. **Thirteen FL1 rows were `[CONFIRMED]` by observation** — every confirmed string on the surface except `FL1.LineState` and `FL1.ITInhibit` — and all thirteen are now `[PROPOSED]` | Integration / Requirements | **High** | **Different in kind from G32, not just larger.** G32 risks three FM2 rows; this risks the measure segment of **all 41 paths on all three lines**, so if the reading is wrong **commissioning test `C1` fails across the whole map** rather than on isolated rows. The failure is the same silent one — the write reports success and the line runs on its previous settings (Severity 1). A second-order effect: with `.Lb` and `.FPM` gone **no tag declares a unit**, so nothing in an address can catch a misconfigured scale (**`PLC-Q15`**, raised to High) | Raised as **`PLC-Q05`** / **Q95** (Critical) and carried on the tag specification's sign-off sheet; the eight rules in `[PLC §4.2]` are what the client confirms, which converts the whole map at once. Every path remains **configuration**, so a correction is a config edit and an app-pool recycle. **`C1` now records the string the controller accepted for every path**, which is what closes this. Watch one semantic: `Diameter` assumes **one** diameter per die block — the old qualifier existed to distinguish the fitted die from a scheduled one, and if the controller exposes both, the qualifier must return | Open — raised Aug 4 2026. **The superseded strings live only in `Q95`**, since neither client-facing artifact may carry old/new content. **Widened by the v1.0 reissue the same day:** the `[CONFIRMED]` tag is retired from the specification altogether, so this is no longer a block of unconfirmed rows inside an otherwise-confirmed map — **the whole map is unconfirmed, and the document says so.** That makes **G32** and this gap two named instances of one condition rather than exceptions to a verified baseline, and it makes `C1`'s coverage the only thing that will ever close either |
| **G13** | `slitter-interface` / `CoilDataHub` reference ambiguity | Doc consistency | Low | Wrong pattern copied | Removed as a reference | ✅ Resolved (decision 5) |
| **G15** | No executive summary / 11-stage→phase map | Doc usability | Low | Hard to skim a ~1,250-line doc | Add a one-screen exec summary + process-stage→phase table | Open |
| **G19** | **Pre-check-in was fully specified in the SRS but absent from every other artifact.** `SRS §4.2 PCI001`–`PCI008` (+ `WLD010`, `TRV004`/`TRV009`, §4.18 `PRC001`–`PRC019`) define a dedicated FL1 Pre-Check-In station, yet there was no analysis note, no mockup, no data model, no API, no phase owner — and `CommonDB_Insert_WIPStations_FlatWire.sql` D2 **deliberately declined to create the station**. Root cause: `.docx` files are zip containers, so `grep` never reached the requirements; every markdown search for "pre-checkin" returned hits about the *forbidden* `checkin-precheckin` Angular library instead | Requirements / Traceability | High | A `Should`-priority feature that the continuous-feed workflow depends on would have been missed entirely; the Phase-3 "Payoff2 not loaded" alert stays unimplementable | Delivered: `LatestDocument/RequirementDocuments/RodPreCheckin.md`, Dashboard 2A mockup, `RodStaging` table, `/staging/**` endpoints, `PayoffStateChanged`, `FL1PO` station, Phase 4 scope addition | ✅ Resolved (Jul 29 2026) — **but** two items still need business sign-off: `INFLAT`-vs-`STAGED` on staging, and whether pre-check-out needs supervisor approval |
| **G20** | Payoff position modelled **three incompatible ways**: `INT CHECK (1,2)` on rod-fed tables, an FK-style `PayoffPositionId` in `FlatWireRunDetail` pointing at a **table that did not exist**, and the API enum `{Payoff1,Payoff2}` — with FL2's traversing take-up unrepresented (`REVIEW.md` #15) | Data / Schema | Medium | Unenforced FK; no vocabulary for FL2's take-up; "payoff 3" has no meaning | Added the `PayoffPosition` lookup (3 **pinned** Ids: Payoff1, Payoff2, TraversingTakeup) and the real FK on `FlatWireRunDetail`. Rod-fed tables keep `CHECK (1,2)` as a *documented deliberate narrowing* | ✅ Resolved for the data model — `REVIEW.md` #15 stays **partly open**: `TraversingTakeup` has no UI |
| **G21** | **`UX_RodStaging_Bay` does not enforce "one rod per payoff bay" across FL1/FL3.** The filtered unique index is keyed `(LineId, PayoffPosition) WHERE Status = 'Staged'` and `CK_RodStaging_LineId` admits **both** `FL1` and `FL3` — so `(FL1,1)` and `(FL3,1)` are distinct entries. Everything in the design assumes the two lines share **one physical VPS** (`STATION_BY_LINE = {FL1:"FL1PO", FL3:"FL1PO"}` in Dashboard 2A; only `FL1PO` is seeded, no `FL3PO` — G19/Q73), so **two different rods can be `Staged` on the same physical bay with every constraint satisfied**. Distinct from G20, which settled the payoff-position *vocabulary*, not its *uniqueness scope* | Data / Schema | **High** | The invariant the table exists to defend does not hold; weld genealogy attributes output to whichever row a query picks | Answer **Q76** first — the fix is opposite depending on the answer. One station → key the index on the station (`FL1PO`) or a persisted station column. Two stations → seed `FL3PO` and the index is already correct. **Blocks the Phase-4 schema freeze** | Open — raised Jul 31 2026 from the Dashboard 2A UX review (`Analysis/Dashboard2A_UXReview.md`, deleted 1 Aug 2026 — in git history at `2a0426b`). **Sharpened Jul 30/Aug 1 2026:** the client confirmed rods are **never stacked** — two rods maximum, one per payoff (**Q75**) — so one-rod-per-bay is definitively the invariant this index must defend, not a modelling assumption. And the off-schedule reversal (**Q74**) makes the system **switch between the FL1 and FL3 stations by itself**, so "are they one station or two" stops being a labelling question and becomes runtime behaviour |
| **G18** | Source docs (CLAUDE.md / CheckinImplementationPrompt) describe a `--fw-*` design system, but the actual mockups **and** `flat-wire-shopfloor.styles.scss/.css` use `--color-*` semantic tokens (no `--fw-*` anywhere); separately, DB2 was revised to the tab-wizard `- New.html` | UI / Design | Medium | Devs following the stale `--fw-*` docs build wrong token names; DB2 UI must follow the new layout | Correct `--fw-*` → `--color-*` in the source docs; build against the shared `--color-*` stylesheet as-is (no migration needed); ground every dashboard UI section in its `Mockups/*.html`; DB2 = `- New.html` tab-wizard; a new-layout FL3 check-in variant to follow | Open |
| **G22** | **The staging order-membership rule is knowingly wrong until Q79 closes.** The client confirmed (Jul 30 2026, **Q69**) that a single rod may carry **more than one production order** — finishing order 1 on a 7,000 lb A-rod and starting order 2 on the remainder. Every artifact validates the opposite: staging and check-in refuse any rod whose order differs from the established one, and [RodPreCheckin.md](../../LatestDocument/RequirementDocuments/RodPreCheckin.md) records *"continuous feed cannot cross an order boundary"* as a consequence to confirm. Both are wrong for the **same-rod successor** | Data / Contract | **High** | The line stops mid-bundle at an order boundary that the material does not have; or the rule is relaxed without a sequencing rule and rods are consumed against the wrong order | Do **not** edit the rule yet — the correct replacement depends on the sequencing answer (**Q79**, Srikanth) and on whether the case is **MVP2**. When it lands: `planning_routings` returns **orders (plural)**, membership becomes an **ordered set**, and `RodStaging.OrderId` needs a defined meaning for a rod spanning two | Open — raised Aug 1 2026 from the [30 Jul client call](../../Analysis/ClientCall_2026-07-30_SyncPlan.md) |
| **G23** | **The 1280×1024 shopfloor canvas is an acceptance criterion nobody has confirmed.** All 25+ mockups are authored at 1280×1024, `flat-wire-fit.js` measures and calibrates its 14 px text floor against that box, and [phase-01a](./phase-01a-angular-foundation.md) pins *"fixed 1280×1024 shopfloor canvas"* as acceptance. Tim expects the stocked 1280×1024 panels but will verify with Charles and Juan; we owe him the required **1920×1080** by e-mail (**Q80**) | UI / Design | **High** | 1920×1080 is **1.5× width, 1.05× height** — a re-layout of every screen, not a rescale. An answer arriving after Phase 1 closes lands against a **14 Aug gate** | Send the requirement now; do **not** re-author anything until answered. `data-fit="fill"` already widens to the window, so a wider panel is the cheap direction and the height barely moves | Open — raised Aug 1 2026 |
| **G24** | **Supervisor approvals are decided but unpersisted.** Three decisions require supervisor authorisation — **Q48** mid-run checkout, **Q50** partial-run disposition, and now **Q68** welded pre-check-out — and `RodCheckout` has **no `ApprovedBy`, `ApprovedAt` or `OverrideReason` columns at all**. `RodStaging` has the credential trio; the checkout table does not | Data / Schema | **High** | Every supervisor-gated checkout is unauditable: the system enforces a gate at the UI and stores no evidence that it was passed, by whom, or why | Add `ApprovedBy` / `ApprovedAt` / `OverrideReason` to `RodCheckout` with a constraint tying them (plus `NewRodStatus='HOLD'`) to the welded Mode P case and to Mode B. Settle the **PIN validation source** once for all overrides (**OI-38**) | Open — raised Aug 1 2026 while applying Q68 |
| **G27** | **The weld screen's rod queue and traceability chain have no host.** Dashboard 4 was **retired 1 Aug 2026** (mockup deleted; git history at `2a0426b`) and the weld moved to Dashboard 2A's *Mark as welded* dialog, which captures every field of the `WeldEvent` row. Two things did **not** move: the **re-sequenceable *Rods In Queue*** accordion (drag + undo) and the **traceability chain** strip — completed → outgoing (remaining footage, WELD NOW chip) → incoming (staged) → future rod. The latter is `FR-175`/`FR-484`-adjacent requirement text with no screen behind it. Either rehome them on DB2A, fold them into the *Welds this run* dialog, or withdraw `FR-175`. **Affects phase 6 / FW-063**<br><br>**Half-closed 1 Aug 2026 — read the distinction before quoting this gap.** DB2A's traveler queue is now **headed "Rods In Queue"**, which is the same *name* as the retired accordion but **not the same control**: it is a read-only status table with no drag and no undo. The name collision is a trap — the re-sequencing capability is still homeless, and so is the traceability chain. `FR-175` is unchanged. | Medium |
| **G28** | **FL2 may have no way to record a weld.** The *Log Weld Event* action was removed from **all four** active-run monitors on 1 Aug 2026 and the weld now lives only at the pre-check-in station — **which FL2 does not have** (`PCI002` excludes FL2 from staging). Two artifacts disagree on whether this matters: `dashboard_10_shift_summary.html` renders **FL2 weld events** (`SP-00029 → SP-00030`, induction, with an "FL2 welds" tile), while [WeldEvent.md](../../LatestDocument/RequirementDocuments/WeldEvent.md) §6 says a coil completing at FL2 **inherits the spool's** weld markers — i.e. the welds happened upstream on FL1. If the first is right, FL2 has a functional hole; if the second is right, the shift-summary fixture is wrong and should be corrected. **This closed `WeldEventPopupPlan` Q-W4 by decision rather than by answer.** Blocks nothing until FL2 build (phase 8) | **High** |

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
| 5A FL2 Spool Queue | 8 |
| 5 FL2 Spool Check-in | 8 |
| 6 SPC Checkpoint | 4 (pre-run), 6 |
| 7 Output Coil Completion / 7b Packing | 9 |
| 8 WIP Rejection | 7 |
| 9 / 9A Pass Schedule Mgmt / List | 2 |
| 10 Shift Summary | 11 |
| 11 Roll Adjust | 6 (FL1/FL2), 10 (FL3) |
| 12 Rod Checkout (A/B) | 7 |
| DC Die Change / Die Management | 6 / 13 |

> **DB13 (HMI Line Schematic) and DB14 (SCADA Multi-Trend), 5 units each, were removed from this table on Aug 4 2026** — descoped at client request along with the Machine View tab. They were **descope-ladder rung 7** (67 h joint); the rung is gone, not merely un-recovered, so Phase 5 drops from 221 h to ~154 h and the ladder's cumulative-recovery column is re-derived in [`CapacityAndEffortModel.md`](../CapacityAndEffortModel.md).

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
| FW-063 | Weld event capture — **DB2A dialog** (Dashboard 4 retired 1 Aug 2026) | 6 | In scope |
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
| [CapacityAndEffortModel.md](../CapacityAndEffortModel.md) | **Per-phase owners + dev-day effort, working-day capacity model, descope ladder (resolves G1)** |
| [APIContracts.md](../APIContracts.md) | `FlatWire.API` REST + `FlatWireHub` contract |
| [FlatWireJiraStories.md](../FlatWireJiraStories.md) | Full backlog (12 epics / 58 stories) — the 184-point cross-check basis; **not** a schedule |
| [FlatWireTables.md](../FlatWireTables.md) | Table designs + existing-table renames |
| [Schema/SQL/FlatWire_ERDiagram_Documentation.md](../Schema/SQL/FlatWire_ERDiagram_Documentation.md) | Source ERD (22 tables → **21** once `Rod` is dropped per G12) |
| [../Analysis/FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md) | Screen specs (DB1–12) |
| [../Analysis/FlatWireEndToEndProcess.md](../../Analysis/FlatWireEndToEndProcess.md) | 11-stage process |
| [../LatestDocument/RequirementDocuments/PLCTagSpecification.md](../../LatestDocument/RequirementDocuments/PLCTagSpecification.md) | **The PLC/OPC tag surface — the single tag map, the write surface, the tag lifecycle and `PLC-Q##`.** Supersedes the tag map formerly in `HMIAndSCADALayout.md` (deleted Aug 4 2026 with the DB13/DB14 descope) |
| [PLCTagImplementation.md](../PLCTagImplementation.md) | `PLCTagService` signatures, config binding, persistence sinks, traceability — **carries no tag path strings** |
| [../Analysis/FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) | Open-questions register (OQ-##) |
| [TechStackRecommendation.md](../TechStackRecommendation.md) | Stack ADR |
| [CheckinImplementationPlan.md](../CheckinImplementationPlan.md) / [CheckinImplementationPrompt.md](../CheckinImplementationPrompt.md) | Stub-first implementation model |
