# Flat Wire Mill — Vision & Scope

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — the line-capability table records FL2 pre-check-in (`FR-533`); object count 34 → 33; effort points at `[CE §3e]` *(previously August 18, 2026 — **`D-32`: there is no shared-schema migration.** `SC-01` retargeted to `Rod.Status`; **`RISK-05` retired** and replaced by the narrower **`OI-111`**; §1’s “largest single blast radius” claim withdrawn *(previously August 15, 2026 — **`RISK-06` retired** and the *unverified assumption* callout restated: all six roles exist as JWT claims on `ClaimTypes.Role` (`G6`/`OI-37`))*)*
**Document Type:** Vision & Scope
**Status:** Baselined — open items in §13; the schedule position in §11 requires a programme decision
**Owner:** Programme management
**Audience:** Sponsors, programme management, business owners, delivery leadership
**Sources:** [`FlatWire_MasterSpecification.md`](../../../LatestDocument/FlatWire_MasterSpecification.md) §1, §2, §9.6, §10, §11 · [`CapacityAndEffortModel.md`](../Development/CapacityAndEffortModel.md) · [`GapsRegister.md`](../Development/GapsRegister.md) · [`Architecture.md`](../Architecture/Architecture.md) §14 · `BaseDocuments/` business inputs
**Shortcode:** `[VS]`
**Part of:** `ProjectPlan/Business/` — index: [README.md](../README.md)


---

## 1. Business context and opportunity

### 1.1 What is changing

United Aluminum is entering a new market: **oscillate-wound flat wire** produced from aluminum rod, instead of the traditional pancake coils the mill has always made. Three new **Flattening Lines** — FL1, FL2 and the hybrid FL3 — convert aluminum rod into coreless oscillated flat-wire coils through wire drawing, controlled flattening, optional annealing and finish rolling.

The **Flat Wire Mill module** is the shopfloor and dashboard layer that drives operator transactions and machine behaviour for those three lines. It is a new capability **inside** the existing UAL Manufacturing Execution System, not a standalone application: it reuses UAL's authentication, machine configuration, planning, scheduling, reporting, WIP/rejection, yield and cost patterns, and registers FL1/FL2/FL3 as first-class machine entries alongside the existing slitters and mills.

### 1.2 Why the business is doing it

| Driver | Detail |
|---|---|
| **Lower unit cost** | Flat wire produced directly from rod carries a lower unit cost than pancake coils for the same finished dimensions |
| **New customers** | Welding-wire buyers are a market UAL cannot serve today. They are also the most demanding on traceability — see §4.2 |
| **Existing plant leverage** | The lines sit inside the existing plant, share the anneal furnaces, the packing line and the scrap system, and are scheduled by the existing Scheduling system |

### 1.3 Why it is not a small change to existing applications

No current UAL application can represent **rod as an input**, a **flattening operation**, a **bundle width**, an **edge type**, or a **coreless oscillated coil**. Approximately **24 existing applications** need extension, catalogued in `BaseDocuments/New Flat Wire Machine - Impact on Applications 041726.xlsx`. ~~The largest single blast radius is the shared-schema rename (story `FW-001`) described in §10.3 and `[INT §8]`.~~ **Retired 18 Aug 2026 — `D-32`: there is no shared-schema migration.** The largest single blast radius has been removed rather than managed; the existing applications are read and written as they stand. What remains of it is **`OI-111`**, which asks which existing reports filter on the coil status field.

---

## 2. Vision statement

> Every foot of flat wire United Aluminum produces is made under a configuration an operator explicitly acknowledged, is measured while it is being made, and can be traced — rod by rod, weld by weld — from the finished coil back to the supplier heat.

That single sentence implies four measurable outcomes:

| # | Outcome | Measured by |
|---|---|---|
| **VO-1** | No line runs without an acknowledged pass schedule | Every `FlatWireRun` carries a `PassScheduleId`; zero PLC tag pushes originate anywhere except operator acknowledgement at check-in |
| **VO-2** | Gauge and width are recorded continuously, not sampled by hand | Recording starts automatically at mill speed > 0; the 4 ft / 20 ft cadence holds; `RunReading` has data for every run |
| **VO-3** | Weld genealogy is complete and queryable | Every output coil resolves to a complete, non-overlapping set of source-rod footage ranges; the certificate query returns supplier heat for 100 % of shipped footage |
| **VO-4** | The shopfloor works at arm's length, gloved, on a touch panel | 14 px minimum text, ≥ 48 px tap targets, no hover-dependent action, no blank screen on a network drop |

---

## 3. Product overview

### 3.1 The material journey

Rod arrives as bundled coils (~0.375″ diameter) from vendors such as Constellium, Arconic, Southwire or Nexans. Four operations transform it, of which the first two may be bypassed:

1. **Wire drawing** (DB1, DB2) — pulls the rod through tungsten-carbide dies to reduce diameter and correct roundness. Either die block can be bypassed if the rod is already at size.
2. **Flattening** (FM1, the 12″ mill) — the primary 3-D → 2-D transformation. Round wire becomes flat wire. FM1 carries gauge stands, a dancer for tension, and **automatic gauge control (AGC)**.
3. **Optional anneal** — FL1 output spools route to a furnace before FL2 if the target temper requires it. Not inline. The hybrid route bypasses it.
4. **Finish rolling** (FM2, the 3-stand mill) — brings flat wire to final gauge and width, with edge conditioning.

Continuous operation is achieved at the payoff: the **VPS** (Variable Position Payoff) holds two rod bundles eye-to-sky, and as the drawing bundle nears exhaustion the operator **induction-welds** the tail of the running rod to the head of the staged rod. The line never stops. This is why pre-check-in exists and why weld genealogy is a first-class concern.

Output winds at a **traversing take-up** that oscillates across the coil face. The "oscillation width" (**bundle width**) is a Min/Max range specified per order and is a **different quantity** from the flat wire's own width.

### 3.2 The three lines

| | **FL1 (standalone)** | **FL2 (standalone)** | **FL3 (hybrid)** |
|---|---|---|---|
| Input | Rod or round wire, at the VPS | Flat wire **spool** on the TPO | Rod or round wire, at the VPS |
| Flow | VPS → DB1 → DB2 → **FM1** → TKUP-1 | TPO → **FM2** (**S1 8″ → S2 6″ → S3 6″**) → TKUP-2 | VPS → DB1 → DB2 → FM1 → *(TKUP-1 bypassed)* → TPO → FM2 → TKUP-2 |
| Output | Intermediate **spool**, `SP-#####`, ≤ 3,500 lb | Coreless oscillated **coil**, `FW-#####-C##`, ≤ 1,100 lb | Coreless oscillated **coil**, ≤ 1,100 lb |
| **Edger** | **None — FL1 has no edger** | Edgers at **S2 and S3 only** | Edgers at S2 and S3 (the FM2 side) |
| Gauge trace | **Real-time** (live AGC feed) | **Historical / profile** — broadcasts `null` live gauge and width | **Real-time**, end to end |
| Intermediate anneal | Yes, optional | N/A | **No** — bypassed by definition |
| Intermediate alpha | Yes — spool alpha issued | N/A | **No** intermediate alpha |
| Pre-check-in | **Yes** | **Yes** — *client reversal, 20 Aug 2026 (`FR-533`)*. Still **no staging space**: it is a validation queue, not a bay. `[PROPOSED]` pending **`Q41`** | **Yes** |

FL1 and FL2 may run **independent orders simultaneously**; their throughput ratio is roughly **3:1** (FL1 faster). **FL3 cannot run if FL1 or FL2 have scheduled orders.**

### 3.3 Equipment inventory

| Equipment | Line | Role | Capacity | Bypassable |
|---|---|---|---|---|
| **VPS** payoff (dual position) | FL1 / FL3 | Rod feed, eye-to-sky | **9,000 lb per position** | No |
| **DB1** / **DB2** | FL1 / FL3 | Wire drawing dies (roughing / finishing draw) | — | **Yes** |
| **FM1** — 12″ flattening mill | FL1 / FL3 | Round → flat; gauge stands + dancer; **no edger** | — | **No** |
| **TKUP-1** traversing take-up | FL1 | Intermediate spool | **3,500 lb** | Non-hybrid only |
| **TPO** traversing payoff | FL2 / FL3 | Feeds FM2 | 3,500 lb | N/A |
| **FM2 — S1 (8″ roller)** | FL2 / FL3 | Finishing stand 1; no edger | — | **Yes** |
| **FM2 — S2 (6″ roller)** (+ edger) | FL2 / FL3 | Finishing stand 2 | — | **Yes** |
| **FM2 — S3 (6″ roller)** (+ edger) | FL2 / FL3 | Final gauge control | — | **No** |
| **TKUP-2** traversing take-up | FL2 / FL3 | Finished coreless coil | **1,100 lb** | No |
| Line speed | all | Governed by the final take-up | **~1,800–2,000 FPM** | — |
| Skid | packing | Finished output | **2 coreless coils per skid** | — |

> **FM2 has three stands, not four `[CONFIRMED — Aug 4 2026]`.** The 8″ roller **is S1**; it is not a separate component upstream of three 6″ stands. Earlier revisions of this table listed four FM2 rows, and the *contested — see OI-04* notes on the last two are removed: **`OI-04` is closed** because the DDL's `FM2_6inS2` and the SRS's `6″ S3` named the same physical stand. Decision **D-26**.

The physical layout is illustrated in [`Flat Wire Machine - Big Beautiful Diagram.png`](../Frontend/Mockups/Flat%20Wire%20Machine%20-%20Big%20Beautiful%20Diagram.png) — orientation only, not a specification.

---

## 4. What makes this module unlike every other UAL shopfloor module

Two things. Both shape the architecture, and both are the reason this cannot be delivered as a variant of an existing screen set.

### 4.1 The Pass Schedule is the machine's brain

A **single configuration record** decides which components are active or bypassed, the die sizes, the roll clearances, the edge configuration, the gauge and width targets, the speed range and the route mode.

**Operator acknowledgement of that record at check-in is what pushes PLC tags to the line.** Nothing else does. Not saving a schedule, not generating one, not loading one on screen. Nothing runs without it.

Consequences that ripple through the whole programme:

- Pass Schedule Management (`[SP]` Phase 2) **gates every check-in phase**. It is the highest-priority dependency in the project.
- Pass schedules are **authored manually by Operations**, never auto-generated. A "Generate from Specs" algorithm exists, but it produces a **Draft for human approval**.
- The content of those schedules — the actual recipes for the actual products — **is still being authored by Operations today**. That is risk `RISK-02`.

### 4.2 Weld genealogy is a contractual deliverable, not a nice-to-have

Welding-wire customers require a traceable chain from **supplier heat**, through **every rod-to-rod induction weld**, to the **finished coil alpha** — with **footage attributed per source rod**. Some impose a contractual maximum weld count per coil, because exceeding it causes wire jams in their automated welding equipment.

That requirement shapes the run model (`FlatWireRun` as the hub), the traceability tables (`CoilTraceability` with non-overlapping footage ranges), and the certificate query. It is why the weld event captures both payoff positions and reads footage from the encoder rather than accepting a typed value.

---

## 5. Stakeholders and roles

| Role | What they do on the system | What they need from it |
|---|---|---|
| **Operator** | Pre-check-in, check-in, run monitoring, weld, SPC, die change, roll adjust, pause, WIP rejection, coil completion | Big touch targets, unambiguous next action, never a dead end, never a blank screen |
| **Supervisor / Foreman** | Line Status board, override authorisation, WIP disposition, mid-run checkout approval, shift summary | Floor-wide situational awareness; a durable approval queue, not a transient notification |
| **Operations Manager** | Authors and activates pass schedules; reverts roll-gap overrides; approves mid-run configuration changes | A schedule library that is searchable, versioned and audited |
| **Engineering / Maintenance** | Die management, alloy lookup maintenance, pass-schedule authoring, PLC tag configuration | Tooling life visibility; configuration without a code release |
| **QA** | SPC-HOLD disposition, WIP rejection disposition, certificate review | Hold that blocks advancement without stopping the machine |
| **Admin / IT** | Role provisioning, environment configuration, OPC tag paths | Config-driven tag paths, correctable post-commissioning without redeployment |
| **PLC / commissioning engineer** | Tag map confirmation, on-line trial | An application that reads line state and never sends a stop command |
| **Planning / Scheduling (upstream)** | Allocate rod to orders; book jobs on FL1/FL2/FL3 | Consumes their outputs; does not replace them |

> ✅ **Confirmed 15 Aug 2026 — no longer an assumption.** All six roles already exist as JWT claims in the `Login` service, on the standard `ClaimTypes.Role`; **none needed provisioning**, and the *"can block the build outright"* reading of gap **G6** / **OI-37** is spent. ⚠ **Residual:** the six claim **values** are abbreviated or coded rather than the matrix's labels and the mapping is unsupplied — that gates **verification, not construction**. ⚠ **And one thing is untouched:** `Engineering/Maintenance` and `QA` are still *inferred* definitions — confirming that a claim exists is not confirming that the capabilities attributed to it are right.

---

## 6. In scope

The shopfloor and dashboard layer, in five areas.

| Area | Contents |
|---|---|
| **Operator screens** | Pre-check-in (DB2A) · rod check-in (DB2) and spool check-in (DB5) · active-run monitoring (DB3, three line variants) · SPC checkpoint (DB6) · roll adjust (DB11) · die change (DC) · pause/resume · WIP rejection (DB8) · rod checkout (DB12, three modes) · coil completion (DB7) · packing (DB7b) |
| **Dashboards** | Line Status (DB1) · Pass Schedule Management and List (DB9 / DB9A) · Shift Summary (DB10) · Die Management (DM) · OEE |
| **Data model** | The standalone `FlatWireDB` schema — **33 tables** (counted from the DDL, see `[DBD §6]`) — plus the named legacy integration points in the shared databases |
| **Integration** | PLC tag push on acknowledgement and clear on checkout · OPC tag consumption (mill speed, feet consumption, line state) · SignalR real-time streaming |
| **Quality** | SPC checkpoints at four process points · SPC-HOLD · CPK per run · WIP rejection and dispositions |

---

## 7. Out of scope — with owner and consumed interface

These are **not built here**. Each is owned by an existing system, and this module **consumes** a defined output. If any of them slips, the corresponding phase has no input.

| Area | Owner | What this module consumes |
|---|---|---|
| **Rod receiving** — `R#####` alpha generation, chemistry validation, weight validation, suspend logic | Existing **CoilReceiving** module | A rod row in the shared `coils` table with status `RECEIVED` or `STAGED`, carrying alloy, temper, diameter, gross/net weight, supplier heat and lot |
| **Order planning & line scheduling** | Existing **Planning** / **Scheduling** systems | A rod→order allocation in `planning_routings` (this is how a scan *resolves* its order) and an order→line booking with operation letter `F` |
| **Coil Yield and Cost Ledger** | Own module documents | Nothing inbound; this module *produces* the run and traceability data the ledger consumes |
| **Web changes** — Orders, Quotes, IQR, Item Template, Alloys, Vendor Maintenance | Backlog epic **E06** (upstream) | The Flat Wire flag, Bundle Width Min/Max and Edge Type on the order |
| **EDI rod receiving** | Deferred to a post-go-live phase | — |

**Fourteen backlog stories** (FW-020/021/022, FW-030/031, FW-040–043, FW-050–053, FW-055) sit in this out-of-scope set. They remain Critical/High **for their own teams**. See `[TB §7]`.

---

## 8. Non-goals — decisions already taken, not open for re-litigation

| Non-goal | Rationale |
|---|---|
| **No new frameworks** | Angular 18.2+, .NET 8, SQL Server, SignalR, Chart.js only. No React, no Blazor, no separate mobile app, no message broker (Kafka/RabbitMQ) in Phase 1. The window does not permit ramp-up |
| **No printed traveler** | The traveler is fully digital and adapts to the active station. "Print Traveler" is disabled for flat wire. **Coil, spool and skid labels are still printed** |
| **No auto-applied pass schedule** | "Generate from Specs" produces a *Draft* for human approval. Nothing reaches the PLC except by operator acknowledgement at check-in |
| **No software stop command to the PLC** | The application is a **gatekeeper** that reads line state and blocks transactions. The operator always stops the machine physically |
| **No laser welding** | Removed 21 May 2026 as not viable. Induction only. `LaserWeld` survives in the data model for historical genealogy and is never selectable |
| **The word "strip" is not used** | The product is always called **flat wire**. This is a terminology rule with customer-facing consequences; it applies to screens, labels, reports and column headings |

---

## 9. Success criteria and acceptance measures

Written so `[TS]` can test them and `[DEP]` can gate a release on them.

| ID | Success criterion | Acceptance measure | Verified by |
|---|---|---|---|
| **SC-01** | A rod can be checked in on FL1 and the line configured from the acknowledged pass schedule | One check-in writes the run, check-in, inspection and pre-run SPC records, sets **`Rod.Status = 'INFLAT'`** *(`FlatWireDB`-local since `D-32`; the shared `coils` row is not written)*, and pushes the full tag set for the selected payoff — in that order | `[TS]` FL1 E2E (FW-120) |
| **SC-02** | An FL1 run produces an intermediate spool with a complete profile | Spool alpha issued only after per-spool SPC passes; gauge profile with weld markers stored and retrievable | `[TS]` FL1 E2E |
| **SC-03** | An FL2 run finishes that spool into a coreless coil | FL2 check-in validates against the FL1 record, shows the historical profile, pushes FM2 tags, completes a coil with a label | `[TS]` FL2 E2E (FW-121) |
| **SC-04** | FL3 hybrid runs rod to finished coil in one pass | One acknowledgement pushes FM1 **and** FM2 tags; no spool alpha; real-time trace end to end | `[TS]` FL3 E2E (FW-122) |
| **SC-05** | Weld genealogy is complete and certifiable | For a coil made from ≥ 2 rods across ≥ 1 weld, the traceability rows cover 100 % of coil footage, do not overlap, and resolve to supplier heat | `[TS]` weld genealogy suite |
| **SC-06** | The line board is live and correct | All three lines render concurrently; every alert rule fires on its stated condition; readings arrive by push with **no polling** | `[TS]` real-time suite |
| **SC-07** | Exceptions have formal off-ramps | WIP rejection sets material status and alerts a supervisor; all three checkout modes complete with the correct status transition and PLC tag treatment | `[TS]` exception suite |
| **SC-08** | Every override is attributable | Every supervisor override, pass-schedule change and PLC tag write/clear is retrievable with who, when, why and old→new value | `[TS]` audit suite |
| **SC-09** | The screens work on the panel | Every screen renders complete at 1280 × 1024 at 1:1, no text below 14 px (except the documented SVG axis exception), every tap target ≥ 48 px | `[TS]` UI conformance |
| **SC-10** | A network drop is survivable | Client shows "Reconnecting…" over cached last-known state — **never a blank screen** — and re-joins its line group automatically | `[TS]` resilience suite |
| **SC-11** | The release can be rolled back | A rehearsed rollback returns every component to its prior version, with the data-loss position stated in advance | `[RB §6]` |

**SC-01 to SC-07 are release gates.** SC-08 to SC-11 are also gates, but can be evidenced on staging rather than on the line.

---

## 10. Constraints and assumptions

### 10.1 Technology constraints

Stay entirely within the existing UAL stack — Angular 18.2+ (delivered as a PWA), .NET 8 with Clean Architecture and MediatR CQRS, SQL Server, SignalR, Chart.js, JWT and Serilog. Detail and rationale in `[SVC §3]` and `[ARC §12]`.

### 10.2 Physical and human constraints

| Constraint | Value | Why |
|---|---|---|
| Authored canvas | **1280 × 1024** | The physical shopfloor panel |
| Minimum text size | **14 px** | Read at arm's length, standing, sometimes gloved |
| Tap targets | **≥ 48 px** | Touch-first, gloved hands |
| Hover | **No action may depend on it** | Touch screens have no hover |
| Data entry | On-screen virtual keyboard / numeric keypad | No physical keyboard at the machine |
| Supervisor overrides | **Block passive dismissal** | An override must be a decision, not an accident |

### 10.3 The transactional constraint

Check-in spans **three systems** — `FlatWireDB`, the shared `coils`/`wip_coil_orders`/`planning_routings` schema, and the PLC via OPC. **This is not one ACID transaction and cannot be made into one.** OPC writes are not transactional at all, and the two databases are separate.

The design is therefore **records first, PLC second**, with **compensating writes** rather than rollback. The recovery path when one side succeeds and the other fails is **not yet specified** — gap **G2** / **OI-39**, and it blocks Phase 4. Full treatment in `[ARC §10]`.

### 10.4 Assumptions

- Upstream rod receiving and planning/scheduling deliver on their own timelines; if they slip, Phase 4 has neither material nor a scheduled job.
- PLC commissioning may slip past 30 Sep without blocking development — `SimulatePLCTagPush` plus a mock SignalR stream keep the UI fully testable. **Go-live** is gated on commissioning; development is not.
- The mockups in `MVP-1/ProjectPlan/Frontend/Mockups/` are final; no UI design time is costed.
- The `CoilCheckin` backend template is directly reusable.
- OPC servers are unchanged; only the PLCs are new hardware.

---

## 11. Key risks

`RISK-01` is the programme's defining risk and is stated first deliberately.

| ID | Risk | Likelihood | Impact | Owner | Mitigation | Links |
|---|---|---|---|---|---|---|
| **RISK-01** | **The 30 Sep date is unreachable as scoped.** **MVP-1 is 3,186 scheduled hours / 398.3 dev-days — `3,358 h` all-in (`[CE §3e]`)** against **44 working days** (32 post-gate) — **352 h per person** → **9.1 FTE sustained** *(re-baselined 18 Aug 2026 by `D-32`; previously 3,292 h / 9.4 FTE. **The risk does not clear** — it moves by 0.3 FTE)*, a **10.7-FTE Phase-1 gate**, and an arithmetically impossible **24.5 FTE in W7**. *(Both scopes: 3,660 h → 10.4 FTE, 27.2 in W7.)* **Deferring MVP-2 did not help the shape** — its hours came almost entirely out of W2–W3, already the slackest weeks | **Certain** — measured, not forecast | **Critical** | Programme management | **Not mitigable by parallelism or descoping.** The full descope ladder recovers **12 %** (448 h), leaving 9.3 FTE. A programme decision is required: **staff to ~11 FTE**, **move the date** (6 FTE → 18 Nov 2026; 8 FTE → 22 Oct 2026, both inside the already-planned Q4 window), or **cut below the critical path**. See `[SP §1]` | **G1** / **OI-51** |
| **RISK-02** | **Pass Schedule content is still being authored by Operations.** Every check-in depends on it, and Phase 2 gates every check-in phase | High | **Critical** | Tim O. / Operations | Front-load Phase 2; the stub check-in assumes a single active schedule. **There is no other workaround** | `[SP §6]` |
| **RISK-03** | **The footage→weight conversion basis is undefined.** The formula and density source are settled; the *dimensional basis* (target vs measured vs integrated over `RunReading`) is not | Medium | High | Tim O. / Process Engineering | DB7 shows "pending confirmation" with an operator override; keep the factor table-driven. Note the ±2 % variance threshold in `FR-153` is arithmetically unreachable from target dimensions (worst case ±2.6 %) | **OQ-10** / **OI-45** |
| **RISK-04** | **Cross-database check-in has no defined recovery path** | High | **Critical** | Architecture / Jaspreet | Choose saga/outbox or a local `INFLAT` mirror **before Phase 4** | **G2** / **OI-39** |
| ~~**RISK-05**~~ | ~~**FW-001 column renames break existing reports.**~~ **RETIRED 18 Aug 2026 — `D-32`: there is no shared-schema migration, so no rename can break a report.** ⚠ **Replaced by the narrower `OI-111`:** nothing marks flat-wire material in `coils.coil_status` any more, so a status-filtered report sees it as untouched — and the audit that would have found such reports is cancelled with the change. Original text: The renames touch the shared `coils`/scheduling schema read by upstream receiving, planning, scheduling, reporting, yield and cost | — | — | DBA / IT | Full stored-procedure / view / report / query audit **before** migration (40 h costed in Phase 1C); regression pass at QA4. This is also the hardest element of the release to roll back — `[RB §6.3]` | `[INT §8]` |
| **RISK-06** | ~~**Roles may not exist as JWT claims**~~ ✅ **Retired 15 Aug 2026 — did not materialise.** All six exist on `ClaimTypes.Role`; no provisioning story was needed | ~~Medium~~ — | ~~High~~ — | Security / Login owner | **Replaced by a smaller risk:** the claim **values** are coded rather than labelled and the mapping is unsupplied, so the authorization matrix cannot be *verified* until it lands. **Low / Medium**, mitigated by routing all six through one constants class | **G6** / **OI-37** |
| **RISK-07** | **PLC commissioning slips past 30 Sep** | Medium | High | Engineering / Tim O. | `SimulatePLCTagPush` + mock SignalR keep the UI testable; **development is not blocked**, go-live is | — |
| **RISK-08** | **Real-time NFRs are undefined** — AGC sample rate, concurrent client count, latency budget, `RunReading` retention. A hub load test is scheduled at QA2 **with no pass criteria** | High | High | Architecture / Engineering | Define targets before QA2, or the load test cannot fail. Rework cost if it fails is **not** in the effort model | **G9** / **OI-34** |
| **RISK-09** | **SignalR drops on the shopfloor network** | Medium | Medium | Architecture | Auto-reconnect with backoff + group re-join; PWA cache; "Reconnecting…" banner over cached state | `FR-119` |
| **RISK-10** | **UAT shares a 3-day W7 with feature work.** UAT and stakeholder sign-off cannot start the day feature work completes | High | High | Programme management | Pull Phase 14 into a dedicated post-feature-complete window, **independent of team size** | `[SP §4]` |
| **RISK-11** | **Touch-screen usability** on a screen set no operator has used | Medium | Medium | UX / Operations | Mockups for early user testing; UAT at the start of Phase 14 | `SC-09` |
| ~~**RISK-12**~~ | ~~**Phase 6 depends on Phase 13.** Die-change validation needs the die inventory Die Management creates, and there is no die master table in the schema at all~~ **CLOSED 11 Aug 2026 — the dependency is severed, not scheduled around.** Die inventory and lifecycle are **owned outside MVP-1**, so no die master table is expected. Die-change validation resolves against the **`Drawer` die-size catalogue seeded in Phase 1**, with life from `LastGrindingFeet` / `TotalFeetAllowed`. **`D4` is restated at size level** — it rejects an unrecognised die *size*, not an unregistered physical tool. Accepted consequence: **die life is per size, so two dies of one diameter share a counter** | — | — | — | Resolved — see `DieChangeAndManagement.md` §2.4a. **`OI-41` closes with it** |

### The three things most likely to stop this project

In order: **RISK-01** (the date is arithmetically unreachable and descoping cannot rescue it), **RISK-02** (the recipes the machine runs on are not written yet), **RISK-03** (every weight, yield and remaining-weight figure depends on an undecided basis).

---

## 12. Decisions already made — closed to re-litigation

Twenty-five design, equipment and business decisions are closed and recorded in [`../FlatWire_MasterSpecification.md`](../../../LatestDocument/FlatWire_MasterSpecification.md) §10, with the superseded position preserved in each case. **Do not re-open them.** The ones with the widest reach:

| ID | Decision |
|---|---|
| **D-01** | The UI is a brand-new standalone Angular library `flat-wire-shopfloor` |
| **D-02** | The tables live in a **new `FlatWireDB`**, not `united_db` |
| **D-03 / D-04** | The schema is **33 tables**, and **`Rod` is retained** as a local master with enforced rod-alpha FKs — superseding the earlier "drop `Rod`, 21–22 tables" position |
| **D-05 / D-06** | The real-time layer is purpose-built inside `FlatWire.API`; **`SlitterInterface` is explicitly not a reference**, and there is **no** frontend template at all |
| **D-08** | Dashboard 2 is the 6-step tab wizard, `dashboard_2_rod_checkin.html` (`- New.html` until 11 Aug 2026); both earlier layouts are retired |
| **D-09** | Stay within the UAL stack — no new frameworks |
| **D-17** | The traveler is fully digital; labels still print |
| **D-20 / D-22** | FL1 has no edger · induction welding only |
| **D-26** | **FM2 has three stands — `S1` 8″, `S2` 6″, `S3` 6″** — with edgers at S2 and S3 and S3 final and non-bypassable. Supersedes **D-21**'s "three 6″ stands", which had been read as a separate 8″ roller plus three 6″ stands. Component names become position-only (`FM2_S1/S2/S3`) and roll diameter becomes data (`Stand.RollDiameterIn`); closes `OI-04` and `OI-36` |

---

## 13. Open items — Critical tier

These block the phase named. The full register (Critical, High, Medium, Low — 90+ items) is in [`../FlatWire_MasterSpecification.md`](../../../LatestDocument/FlatWire_MasterSpecification.md) §11 and is carried into `[REQ §11]` and `[SP §10]`.

| ID | Issue | Blocks | Owner | Needed by |
|---|---|---|---|---|
| **OI-51** | **The 30 Sep date requires an explicit programme decision** — staff to ~11 FTE, move the date, or cut below the critical path. The effort model is delivered; the *escalation* is the open item. The named-owner roster is also still unfilled | all | Programme management | **Immediately** — before the 14 Aug gate |
| **OI-39** | **Cross-database check-in has no defined recovery path.** Saga/outbox with compensating PLC clears, or an `INFLAT` mirror in `FlatWireDB` — neither chosen | Phase 4 | Architecture / Jaspreet | Before Phase 4 starts (W4) |
| **OI-45** | **Footage→weight dimensional basis undecided** — target, measured-at-completion, or integrated over `RunReading` (integration recommended). Plus the round-edge coefficient, density sign-off and tail-loss treatment | Phases 9, 12 | Tim O. / Bob S. / Process Engineering | Before Phase 9 (W6) |
| **OI-01** | ~~**Does pre-check-in set `coils.coil_status = INFLAT` or leave it `STAGED`?**~~ **Moot since `D-32` (18 Aug 2026)** — nothing writes `coils.coil_status`. The live residual: must pre-check-out reverse the reqsum and `wip_coil_orders` insert? *(Unaffected by `D-32` — existing columns.)* | Phase 4 | Tim O. / IT | Before Phase 4 (W4) |
| **OI-46** | **The no-match path at check-in is undefined** — what happens when no active schedule matches the order's attributes | Phase 4 | Tim O. / Jaspreet | Before Phase 4 (W4) |
| **OI-47** | **FL2 check-in validation for hybrid-origin spools is undefined** | Phase 8 | Tim O. / Jaspreet | Before Phase 8 (W5) |
| **OI-48** | **The full traveler field list per station has never been documented** | Phase 4 | Jaspreet / Tim O. | Before Phase 4 (W4) |
| **OI-49** | **Inventory type for rod entries in `coils` is TBD** | Phase 4 + upstream | Tim O. / Jeff G. | Before Phase 4 (W4) |
| **OI-50** | **Which identifier is scanned at FL2 check-in** — SP-series alpha, spool number or bundle ID | Phase 8 | Jaspreet / Tim O. | Before Phase 8 (W5) |

---

## 14. Open items raised by this document set

New contradictions found while producing these seven documents, not present in any existing register. Numbered `PP-##`.

| ID | Finding | Raised in | Resolution taken here |
|---|---|---|---|
| **PP-01** | **Index count drift.** Four sources published four different figures — including this row, which asserted **46**, while `[ARC]` and `[RM]` asserted **41**. Root cause: a `sys.indexes` count and a `CREATE … INDEX` statement count are not the same number, because every `PRIMARY KEY` and `UNIQUE` constraint builds a backing index | `[DBD §6.2]`, `[DBD §6.8]`, `[DEP §4.2]` | **Resolved.** The DDL is authoritative and the count is defined once, in `[DBD §6.2]`. No other document may restate it except the three named there |

---

## Future enhancements (Phase 2 / post-go-live)
**Shortcode:** `[VS]`
**Part of:** `ProjectPlan/Business/` — index: [README.md](../README.md)
- EDI rod receiving + Angular receiving screen (deferred from Phase 1).
- Full spool state machine (OQ-17) and formal partial-rod carry-forward (OQ-12). *The `PRC007`/`PRC008` gate now fires at the Dashboard 2A staging scan, so a partial rod is caught before it is mounted; the full carry-forward accounting remains post-go-live.*
- Rolls-in-Flattening report, extended SCADA history, WIP Log enhancements (Low priority).
- Message broker (Kafka/RabbitMQ) if AGC throughput outgrows SignalR (revisit post-go-live).
- Die-life predictive thresholds once failure data exists (OQ-83).
- Anneal scheduling rules (OI-64) and shared anneal-furnace capacity (OI-64).

---
