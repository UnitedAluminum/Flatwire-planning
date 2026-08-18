# Trial Run Workbook — authored content

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — **client blocker `B4` restated**: the roles are confirmed to exist, so the ask is now the six role **codes** and how they map to the permissions matrix
**Status:** Source content for a generated workbook
**Part of:** `ProjectPlan/Tools/` — index: [README.md](README.md)

---

## What this file is

The **only place the prose in `FlatWire_TrialRunPlan.xlsx` is authored.**
[`build_trial_run_xlsx.py`](build_trial_run_xlsx.py) merges it with the figures parsed from
[`../Development/TrialRunPlan.md`](../Development/TrialRunPlan.md).

**The split is strict.** Every number, story identifier, sprint, date and phase is **parsed** from the plan, so it
cannot drift from it. Only the sentences below are written by hand. Change a figure in the plan and re-run; change a
sentence here and re-run. **Never edit the workbook.**

**`Reference title` is a verbatim mirror of the plan's own title, for the drift guard alone.** It is never written
to the workbook. Copy it exactly — paraphrase it and the guard is checking nothing.

**Write no abbreviations.** The workbook expands them at build time and a guard refuses the build if any bare
abbreviation reaches a cell. The `## Glossary` section below is the single exception, because its whole job is to
map them.

---

## Read Me

**Title:** Flat Wire Mill — Six-Screen Trial Run
**Purpose:** This workbook is the trial-run plan the client asked for on 14 August 2026: six operator screens working, with user acceptance testing signed off, by 30 September 2026. It is generated from the plan of record, so every figure in it reconciles to that document rather than being maintained separately.
**Scope:** Six screens — rod check-in, the active run monitor for both lines, the quality checkpoint, the rejection dialog and the finishing-line spool check-in — plus the platform they sit on, pause and resume, and the transaction that creates a finished spool.
**Headline:** The six screens are 88 hours of screen work. The platform beneath them is 423 hours, which is 54 per cent of the trial. Cutting screens is the weakest lever available; shortening the platform is the strongest, and it is the only place extra people convert directly into calendar time.
**Reading order:** Start at Effort Summary for the shape of the work, then Sprint Plan for the dates and what each staffing option lands. Work Items is the detail — every task with what it delivers. Blockers is what the plan needs from outside the development team. Deferred Items and Removal Impact are the boundary: what is deliberately not in the trial, and what that costs.
**One caution:** Effort here is development effort only. Testing, business analysis and contingency are separate and are not included in any figure in this workbook.

---

## Glossary

The one place shorthand appears. Everywhere else in the workbook these are written out.

| Short form | Written out |
|---|---|
| FE | Frontend (Angular) |
| BE | Backend (.NET) |
| DB *(as a discipline)* | Database (SQL Server) |
| RT | Real-time and controller integration |
| QA | Quality Assurance |
| BA | Business Analysis |
| T1, T2, T3, T4 | Sprint 1, Sprint 2, Sprint 3, Sprint 4 |
| 1A, 1B, 1C | Phase 1A Angular Foundation, Phase 1B Backend Foundation, Phase 1C Database Foundation |
| DB1 … DB8 *(as a screen)* | Dashboard 1 … Dashboard 8 |
| FL1, FL2, FL3 | Flattening Line 1, Flattening Line 2, Flattening Line 3 (hybrid) |
| FM1, FM2 | Finishing Mill 1, Finishing Mill 2 |
| TPO | Traversing Payoff |
| SPC | Statistical Process Control |
| WIP | Work-in-Progress |
| UAT | User Acceptance Testing |
| FTE | Full-time equivalent |
| PLC | Programmable Logic Controller |
| DDL | Database build scripts |

---

## Work Items

### FW-N03
**Reference title:** Angular library scaffold, routing and configuration
**Work item:** Operator application created
**Delivers:** The operator application exists as something the team can build, run and deploy, with its screens routed and its settings in place.

### FW-130
**Reference title:** Shell layout and the 1280×1024 shopfloor canvas
**Work item:** Shopfloor screen layout
**Delivers:** Every screen is laid out for the panel size it will actually run on, so nothing has to be re-fitted after it is built.

### FW-131
**Reference title:** Route guards, interceptor wiring and the error envelope
**Work item:** Access control and error handling
**Delivers:** A signed-out or unauthorised user cannot reach an operator screen, and a failed request shows one readable message instead of a blank panel.

### FW-132
**Reference title:** DI-swappable API client and domain models
**Work item:** Data access layer for the screens
**Delivers:** Screens can be built and demonstrated against sample data before the services behind them exist, which is what allows screen and service work to run in parallel.

### FW-133
**Reference title:** Shared composite controls
**Work item:** The six shared screen controls
**Delivers:** The six controls that appear across the whole application, built once: the pass schedule table and its confirmation bar, the quality trace chart, the guided step wizard, the action bar and the material weight bar. Every one of the six trial screens depends on all six, which is why nothing downstream starts until this is done.

### FW-134
**Reference title:** Shared primitive controls and `alert-banner`
**Work item:** Shared inputs, readouts and warnings
**Delivers:** Consistent entry fields, measurement readouts, pass and fail buttons and warning banners across every screen, so the application reads as one system rather than a set of pages.

### FW-N04
**Reference title:** `FlatWire` solution and four-project Clean Architecture skeleton
**Work item:** Application service created
**Delivers:** The service behind the screens exists with its layers separated, ready for the first feature.

### FW-138
**Reference title:** Fifteen thin controllers over `UAController`
**Work item:** Service endpoints for every screen
**Delivers:** Every screen has a service to call. Eight of the fifteen planned are needed for the trial; the other seven belong to work outside it.

### FW-139
**Reference title:** MediatR registration and pipeline behaviours
**Work item:** Common request handling
**Delivers:** Every request is handled the same way, with logging, validation and error handling applied once rather than rebuilt per feature.

### FW-140
**Reference title:** DI registration and the stub/real service swap
**Work item:** Sample-data and live-data switch
**Delivers:** The whole system switches between sample data and live data with one setting. This is what makes the trial demonstrable before the plant is connected.

### FW-141
**Reference title:** Repository layer — one per aggregate root
**Work item:** Database access layer
**Delivers:** One place where the application reads and writes stored data, so a change to the data model touches one layer instead of many.

### FW-142
**Reference title:** Dapper/EF data access and `FlatWireDbContext`
**Work item:** Database connection and mapping
**Delivers:** The application can read and write the flat wire database.

### FW-143
**Reference title:** Serilog structured logging and the audit log
**Work item:** Logging and audit trail
**Delivers:** Every action that changes the state of material or writes a setting to a machine is recorded with who did it and when.

### FW-144
**Reference title:** Configuration binding
**Work item:** Environment configuration
**Delivers:** Connection details, tolerances and update rates are settings rather than code, changeable without a new release.

### FW-145
**Reference title:** JWT authentication and role authorization policies
**Work item:** Sign-in and permissions
**Delivers:** Only an operator can check in material and only a supervisor can approve an override, enforced by the service rather than trusted to the screen.

### FW-146
**Reference title:** Global exception middleware and the response envelope
**Work item:** Consistent failure responses
**Delivers:** An unexpected failure returns a readable response the screen can show, never a raw error.

### FW-147
**Reference title:** FluentValidation, value objects and the canonical cross-layer enums
**Work item:** Input validation and shared vocabulary
**Delivers:** Invalid entry is refused at the boundary with a specific message, and the screens, services and database all use one vocabulary for states and reasons.

### FW-148
**Reference title:** Health checks
**Work item:** System health endpoint
**Delivers:** One address reports whether the application, the database and the plant connection are each reachable, so a problem is found by monitoring rather than by an operator.

### FW-135
**Reference title:** SignalR client service
**Work item:** Live connection in the screens
**Delivers:** The screens hold an open connection and receive readings as they happen, rather than refreshing to look for them.

### FW-136
**Reference title:** `MockSignalRService` and the typed event set
**Work item:** Simulated live feed for the screens
**Delivers:** A stand-in live feed so every moving screen can be built and reviewed before anything is connected to the plant. Small, and the single most valuable piece of schedule insurance in the plan.

### FW-137
**Reference title:** PWA cache sync and the reconnect banner
**Work item:** Offline resilience
**Delivers:** A dropped network shows a clear banner over the last known readings instead of an empty screen, and the connection recovers by itself.

### FW-080
**Reference title:** `FlatWireHub` — strongly-typed, MessagePack, line groups
**Work item:** Live data broadcast channel
**Delivers:** The channel that pushes live readings to every connected screen, separated by line so a screen only receives the line it is showing.

### FW-149
**Reference title:** `IFlatWireClient` typed event contract
**Work item:** Live message definitions
**Delivers:** One agreed definition of every live message, so the screens and the service cannot drift apart on what a reading contains.

### FW-002
**Reference title:** `INFLAT` coil status
**Work item:** Being-flattened material status
**Delivers:** A rod that is being flattened shows that state everywhere in the business, not only inside the new module.

### FW-152
**Reference title:** `FlatWireDB` creation, ordered DDL runner, indexes and grants
**Work item:** Database build and rebuild
**Delivers:** The database is built from scripts in a known order and can be rebuilt identically at any time, which is what makes a repeatable test environment possible.

### FW-005
**Reference title:** Lookup group tables and seed
**Work item:** Equipment reference data
**Delivers:** The fixed reference data every screen reads — mill stands, drawing dies, edgers, spool configurations and payoff positions — exists and is populated.

### FW-004
**Reference title:** `AlloyProperty` lookup and seed
**Work item:** Alloy reference data
**Delivers:** Alloy properties are data the business can maintain, not values built into the code.

### FW-006
**Reference title:** Materials group tables
**Work item:** Material records
**Delivers:** Rods, spools and production runs have somewhere to be recorded.

### FW-007
**Reference title:** Runs and Quality/Output group tables
**Work item:** Run and quality records
**Delivers:** Every event an operator records during a run — check-ins, quality checkpoints, pauses, adjustments, rejections and output — has a place to be stored against its run and the footage it happened at.

### FW-150
**Reference title:** Cadence-driven broadcast loop
**Work item:** Live reading delivery
**Delivers:** Readings are grouped and sent at a steady rate, so a high-frequency measurement feed reaches the screens without overwhelming them.

### FW-151
**Reference title:** `PLCTagService` skeleton and `SimulatePLCTagPush`
**Work item:** Machine settings service, with simulation
**Delivers:** Machine settings can be written from the application, and simulated instead when no machine is connected. Every check-in stage can therefore be built and demonstrated long before commissioning.

### FW-205
**Reference title:** `ITInhibitService` — the run-block interlock
**Work item:** Run-block interlock
**Delivers:** The line is prevented from running whenever the system cannot account for what it is producing — no material checked in, or the footage feed missing or invalid. It clears by itself when the cause clears, and it blocks one line without affecting the others.

### FW-207
**Reference title:** Domain model — aggregates, value objects and invariants
**Work item:** Core business rules
**Delivers:** The rules that protect the data live in one place and cannot be bypassed by a screen or a service that forgets to check them. Identifiers validate themselves, so a malformed rod or coil number cannot be created at all.

### FW-208
**Reference title:** Domain events and post-commit dispatch
**Work item:** Live updates from business events
**Delivers:** When something happens — a run pauses, a weld is recorded, a coil completes — every open screen is told immediately, and only after the change is safely saved.

### FW-203
**Reference title:** OPC feed simulator — a stand-in for the real ingest
**Work item:** Simulated machine data feed
**Delivers:** Realistic live readings without a machine, and steerable — an in-tolerance run, a drifting one, an out-of-tolerance excursion or a line stop can each be reproduced on demand, so the screens are accepted against known conditions rather than whatever the plant happens to be doing.

### FW-214
**Reference title:** Simulator control console — screen DB-S1
**Work item:** Engineering console for the simulated machine
**Delivers:** One screen an engineer drives all three simulated lines from, so the acceptance run is a few clicks rather than typed commands with a stopwatch — which matters because the run is performed in front of the client and one of its checks is a three-second stop measured against a five-second threshold. It is an engineering tool, not an operator screen: it is absent from the dashboard inventory and the navigation, and it does not exist at all once the system is connected to a real machine. Several of its controls arrive switched off, because the behaviour behind them is deliberately not being built for the trial.

### FW-218
**Reference title:** Trial control surface for the feed generator — steer, stop, drop, read
**Work item:** Controls for the simulated machine data feed
**Delivers:** A way to drive the simulated line while a run is in progress, so the acceptance run can be performed at all. Three of its ten steps depend on it: pushing a run out of tolerance to prove the automatic quality prompt fires, stopping the line at a chosen instant to prove the spool completion prompt behaves correctly on a brief stop, and interrupting the data feed to prove the machine is blocked when readings go missing. Restarting the feed with different settings cannot do any of this — it ends the run being demonstrated. The controls are for engineers, are never available to an operator, and do not exist at all once the system is connected to a real machine.

### FW-204
**Reference title:** Minimal landing route — the entry point when Dashboard 1 is out of scope
**Work item:** Line picker entry screen
**Delivers:** An operator arriving at a terminal picks their line and lands on the right screen for whatever that line is doing. It is retired when the full line status board ships.

### FW-153
**Reference title:** Alert chips, reconnect banner and cached-state fallback
**Work item:** Connection loss handling
**Delivers:** A network drop never shows an operator a blank screen. The last known state stays visible with a clear warning until the connection returns.

### FW-155
**Reference title:** `FlatWireRun(LineId, Status)` index
**Work item:** Fast active-run lookup
**Delivers:** Finding a line's current run stays instant as years of run history accumulate.

### FW-061
**Reference title:** Dashboard 2 — Rod Check-in six-step wizard (FL1/FL3)
**Work item:** Rod check-in screen
**Delivers:** The rod check-in screen — a guided six-step sequence that will not let a run start until the material, the inspection, the measurements and the mill schedule have each been confirmed.

### FW-157
**Reference title:** `POST /checkin/rod` and `CheckInService`
**Work item:** Rod check-in transaction
**Delivers:** Checking in a rod records the inspection, the measurements and the run before anything is sent to the machine, and marks the rod as being flattened across the business.

### FW-159
**Reference title:** `RodStaging`, the check-in write path and the cross-DB `INFLAT` write
**Work item:** Check-in write sequence
**Delivers:** The check-in writes land in the correct order across two databases, so a failure part-way through cannot leave one rod recorded in two different states.

### FW-082
**Reference title:** PLC tag group push on check-in acknowledgement
**Work item:** Machine configuration on check-in
**Delivers:** Acknowledging the schedule is what configures the mill — die sizes, roll gaps, edge type, speed limits and dimensional targets. The machine is never set from a schedule nobody confirmed.

### FW-062
**Reference title:** Dashboard 3 — Active Run Monitor (FL1) and FL3 variant
**Work item:** Active run monitor
**Delivers:** The screen an operator watches for the whole run: live thickness and width against tolerance, machine and material state, and one-touch access to every action that can be taken without stopping.

### FW-162
**Reference title:** `run-status-cards`
**Work item:** Run status cards
**Delivers:** Machine state, material flow and mill configuration readable at a glance from across the aisle.

### FW-081
**Reference title:** `gauge-trace-chart` live streaming, maximize and runtime source toggle
**Work item:** Live quality trace chart
**Delivers:** The live quality trace with its target and tolerance band drawn on it, expandable to fill the screen, and able to switch between live readings and a completed run's recorded history.

### FW-163
**Reference title:** `info-grid` and `chart-tab-strip`
**Work item:** Order and material detail panels
**Delivers:** Order and material detail available on the run screen without leaving it, and collapsible so it never crowds the quality trace.

### FW-164
**Reference title:** `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService`
**Work item:** Run lookup and history
**Delivers:** A screen can pick a run back up after a refresh or a shift change, and read a finished run's quality history.

### FW-165
**Reference title:** `sp_GetGaugeTrace`
**Work item:** Fast quality history retrieval
**Delivers:** A long run's quality history loads quickly instead of pulling back every individual reading.

### FW-065
**Reference title:** SPC checkpoint dialog
**Work item:** Quality checkpoint capture
**Delivers:** Recording a quality checkpoint without leaving the running screen, with the measurement shown against its tolerance, and a direct route to holding the material when it is outside specification.

### FW-071
**Reference title:** Pause and Resume dialogs
**Work item:** Pause and resume capture
**Delivers:** Downtime is captured with a reason the business can report on, footage is frozen at the moment of the pause, and resuming offers the operator only the outcomes that make sense at that point.

### FW-168
**Reference title:** `POST /spc` and `SpcService`
**Work item:** Quality checkpoint transaction
**Delivers:** Checkpoint measurements are stored against the run and the footage they were taken at, and a result outside specification puts the material on hold.

### FW-170
**Reference title:** `POST /run/{id}/pause` and `/resume`, and `RunControlService`
**Work item:** Pause and resume transaction
**Delivers:** Pausing and resuming is recorded with its duration, and the machine is idled and restored along with it.

### FW-171
**Reference title:** The five in-run event tables
**Work item:** In-run event records
**Delivers:** Quality checkpoints, their measurements and pause events have somewhere to be recorded against their run.

### FW-172
**Reference title:** Run-event markers and the `LineStatus` transitions
**Work item:** Events marked on the quality trace
**Delivers:** Actions an operator takes appear on the run's quality trace at the footage where they happened, so anyone reviewing the run afterwards can see what was done and when.

### FW-067
**Reference title:** WIP rejection dialog
**Work item:** Material rejection capture
**Delivers:** Suspect material is taken out of production with a reason, a decision on what happens to it and a permanent record — raised from wherever the operator noticed the problem.

### FW-174
**Reference title:** `POST /wipreject`, `POST /checkout` and their services
**Work item:** Rejection transaction
**Delivers:** A rejection sets the material's status, files it in the held queue and raises an alert to a supervisor.

### FW-176
**Reference title:** `WipRejection` / `RodCheckout` tables and the shared `coils` carry-forward columns
**Work item:** Rejection records
**Delivers:** Rejections and the decision taken on each have somewhere to be recorded.

### FW-177
**Reference title:** Exception broadcasts and the supervisor notification
**Work item:** Supervisor notification
**Delivers:** A supervisor is told when material is held, rather than discovering it at the end of the shift.

### FW-202
**Reference title:** FL1 spool completion — stop confirmation, weight basis and the `Spool` write
**Work item:** Spool completion and weighing
**Delivers:** The transaction that turns a finished run into a real, weighed, traceable spool. The machine stop is confirmed with the weight held at the moment it stopped, the operator can enter a scale weight instead and is warned if the two disagree, and the spool record is created with its source material and footage. Nothing else in the trial creates the spool that the finishing line checks in.

### FW-064
**Reference title:** Dashboard 5 — FL2 Spool Check-in
**Work item:** Spool check-in screen
**Delivers:** The finishing line's check-in screen: the arriving spool's quality history and the material it came from, shown before anything is committed, with the mill configuration confirmed separately.

### FW-178
**Reference title:** Dashboard 3 FL2 variant configuration
**Work item:** Run monitor for the finishing line
**Delivers:** The same run monitor configured for the finishing line, showing one spool draining and one coil filling rather than two rod payoffs.

### FW-179
**Reference title:** `POST /checkin/spool` and `GET /spools`
**Work item:** Spool check-in transaction
**Delivers:** Checking in a spool configures the finishing mill and starts its run, and the operator can see what material is waiting to be processed.

### FW-180
**Reference title:** `SpoolCheckin` table and the `Spool.OrderNo` index
**Work item:** Spool check-in records
**Delivers:** Finishing-line check-ins have somewhere to be recorded, and finding a spool by its order stays fast.

### FW-181
**Reference title:** FL2 null-gauge contract and the Live/Profile binding
**Work item:** Honest live reading on the finishing line
**Delivers:** The finishing line states plainly that it has no live thickness measurement, instead of drawing a flat line at target that an operator would reasonably read as a real in-tolerance measurement.

---

## Blockers

### B1
**Reference:** The pass schedule is external and MVP-1 cannot create one
**Blocker:** No approved mill schedule to read
**What we need:** Confirmation of how the flat wire system reads an approved mill schedule, and readable schedules available for both lines. Check-in has nothing for an operator to acknowledge and no settings to send to the machine without one — there is no default schedule and no partial path.
**Consequence if late:** Both check-in screens, and therefore the whole trial, cannot be completed.

### B2
**Reference:** OQ-22 — min/max tolerance values
**Blocker:** Tolerance values not supplied
**What we need:** The four minimum and maximum dimensional tolerance values, owed by email. Nothing is currently seeded and both check-in screens check entered measurements against them.
**Consequence if late:** The measurement check on both check-in screens cannot be finished.

### B3
**Reference:** G2 / OI-39 — cross-DB check-in recovery undecided
**Blocker:** Failure recovery for check-in undecided
**What we need:** An architectural decision on how a check-in recovers when it fails part-way across two databases and the machine. A check-in is not a single all-or-nothing transaction, and the two candidate approaches differ in effort.
**Consequence if late:** The rod check-in estimate stays provisional and carries a separate allowance of three to eight days.

### B4
**Reference:** G6 — role sign-in permissions
**Blocker:** ✅ **Largely answered 15 Aug 2026** — the six roles already exist as sign-in permissions, so none need creating. **One detail is still outstanding.**
**What we need:** The exact codes used for the six roles. They are recorded in an abbreviated or coded form rather than as the role names we use in the permissions matrix, and we need the two lists lined up — which code corresponds to operator, supervisor, operations manager, engineering/maintenance, quality and administrator.
**Consequence if late:** The supervisor overrides and approvals can be **built**, but cannot be **checked** before the trial. A mismatched code does not raise an error — it silently denies a legitimate supervisor, or in the case of the supervisor notification, sends it to nobody.

### B5
**Reference:** G38 — the durable spool-completion prompt has a column and no owner
**Blocker:** Spool-completion prompt is not durable
**What we need:** An owner and an allowance for making the machine-stop prompt survive a page refresh and a dropped connection. The database column that holds it was added on 15 August 2026 and the platform sprint's exit criteria now require the behaviour, but no work item covers it — the story that owns spool completion runs two sprints later, and the obligation belongs to the platform.
**Consequence if late:** A prompt raised when the line stops is lost the moment an operator refreshes the screen or the connection drops, and a finished spool is left uncommitted. The failure is silent: nothing errors, the screens compile, the durability simply never happens — and with automated tests withdrawn from the server side, nothing detects it.

### TIER2
**Reference:** Second tier — none stops the build
**Blocker:** Nine open questions with agreed workarounds
**What we need:** Answers in due course on the footage-to-weight basis, which identifier the spool check-in scans, how a spool produced on the hybrid line is treated at the finishing line, what happens when no schedule matches, which order field carries the coil weight range, how a short close is transacted, and the live-data performance targets.
**Consequence if late:** None immediately. Each has an agreed assumption the trial builds against, and a pass is scheduled in the final sprint to replace those assumptions once answers arrive.
