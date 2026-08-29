# Flat Wire Mill — Development Plan, client-facing content

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 18, 2026 — `FW-001` and `FW-002` marked CANCELLED; `FW-159` retitled; ⚠ `FW-138`/`FW-147` reference titles corrected against the backlog — a **pre-existing** drift that was blocking the build *(previously August 13, 2026 — initial publication)*
**Document Type:** Build input — the authored client prose for the development plan workbook
**Status:** Active — edit here, never in the workbook

---

## What this file is

The **only** place the client-facing wording of the development plan is written. It is merged with
structure — effort, phase, sprint, dates, sequence — parsed from the plan of record, and rendered into
the development plan workbook. **Nothing here is citable as a requirement or a commitment.**

**The split is deliberate.** Figures are parsed so they cannot drift from the plan; only prose is authored
here. Change the plan and re-run the build; the numbers follow on their own.

**Why the internal titles could not simply be filtered.** 68 of the backlog's work-item titles are
engineering titles — they name endpoints, database tables, screen numbers and code identifiers. A client
sentence cannot be produced by deleting those; it has to be written about the business outcome instead.
The raw material is each item's user story, whose *"so that"* clause is already the outcome. That is what
each **Delivers** line below is built from.

**Reference title** is read for the drift guard alone — it is compared against the plan's own title so a
renumbering cannot slide this prose onto a different item. **It is never written to the workbook.**

**Forbidden in every field below**, and enforced by a scan that deletes the workbook if it finds any:
file names, folder paths, requirement/gap/backlog/test identifiers, endpoint signatures, database table
and column names, screen numbers, machine tag paths, and code formatting of any kind.

---

# Part 1 — Phases

## 1A
**Reference title:** Angular Foundation
**Phase name:** Operator screen platform
**Delivers:** The shared screen framework, controls and live-data client that every operator screen is built on — built once so no later stage re-invents it.
**Audience:** Platform / foundation
**Deferrable:** No — every screen depends on it

## 1B
**Reference title:** Backend Foundation
**Phase name:** Application services platform
**Delivers:** The service that holds the business logic, the live-data feed to the screens, and the machine-write layer — including the simulation mode that lets every screen be built and demonstrated before the machines are wired.
**Audience:** Platform / foundation
**Deferrable:** No — every operation depends on it

## 1C
**Reference title:** Database Foundation
**Phase name:** Data foundation
**Delivers:** The flat wire database, its reference data, and the changes to the existing scheduling system that let it carry flat wire alongside coil.
**Audience:** Platform / foundation
**Deferrable:** No — nothing can be recorded without it

## 3
**Reference title:** Line Status Board & Real-Time Backbone
**Phase name:** Line status board and live data
**Delivers:** The first working end-to-end slice — machine data reaching a live board showing all three lines. Everything built later consumes this same live feed.
**Audience:** Supervisor
**Deferrable:** No — every later stage consumes this live feed

## 4
**Reference title:** Rod Check-In & PLC Configuration (FL1 / FL3)
**Phase name:** Rod check-in and machine configuration
**Delivers:** The core operator entry point — verify the material, complete the inspection, confirm the setup, configure the machine and start the run — plus the station that stages the next rod while the current one is still running.
**Audience:** Line operator (FL1 and FL3)
**Deferrable:** No — the entry point to every run

## 5
**Reference title:** Active Run Monitoring & Live Gauge/Width Trace (FL1 / FL3)
**Phase name:** Active run monitoring
**Delivers:** The run screen the operator watches continuously — live gauge and width traces, payoff weights, machine status, and every mid-run action one touch away.
**Audience:** Line operator (FL1 and FL3)
**Deferrable:** No — the operator has no view of the run without it

## 6
**Reference title:** In-Run Production Events
**Phase name:** In-run production events
**Delivers:** Everything an operator records without stopping the run — welds, die changes, quality checks, roll corrections and categorised pauses. Grouped because they share the run context and the quality gating between them.
**Audience:** Line operator
**Deferrable:** Partly — individual events could follow go-live, at the cost of paper records

## 7
**Reference title:** Exception Handling: WIP Rejection & Rod Checkout
**Phase name:** Exception handling
**Delivers:** The formal off-ramps — putting suspect material on hold, and removing a rod before it finishes, including the supervisor-approved partial run.
**Audience:** Line operator and supervisor
**Deferrable:** Partly — the material hold could follow go-live; checkout could not

## 8
**Reference title:** FL2 Spool Check-In & Finishing Run (FL2 Standalone)
**Phase name:** Spool check-in and finishing run
**Delivers:** The FL2 operator journey — see what material is waiting, check in a spool, review how it was produced, and run the finishing mill.
**Audience:** Line operator (FL2)
**Deferrable:** No — the finishing line cannot be run without it

## 9
**Reference title:** Output Coil Completion, Labeling & Packing
**Phase name:** Coil completion, labelling and packing
**Delivers:** The finish line — confirm the coil, record which rods produced which footage, calculate the weight, print the label and manage the two-coils-per-skid packing rule.
**Audience:** Line operator and packing operator
**Deferrable:** No — there is no finished coil without it

## 10
**Reference title:** FL3 Hybrid Continuous Operation
**Phase name:** Hybrid continuous operation
**Delivers:** The most complex route — one line feeding the other continuously with a single operator confirmation, no intermediate spool, and unbroken traceability from rod to finished coil.
**Audience:** Line operator (FL3)
**Deferrable:** No — the hybrid route would not exist

## 11
**Reference title:** Supervisor Shift Summary, Reporting & Certification
**Phase name:** Reporting and certification
**Delivers:** The reporting suite in the tool the quality team already uses, and the traceability that produces a welding-wire certificate of conformance.
**Audience:** Quality and process engineering
**Deferrable:** Partly — reporting could follow go-live; the certificate could not

## 13
**Reference title:** Administration & Reference Data
**Phase name:** Administration and reference data
**Delivers:** The screens that keep the system running without a developer — alloy properties, tolerance bands, machine configuration and user roles.
**Audience:** Process engineering and administration
**Deferrable:** Partly — reference data could be loaded by hand at first

## 14
**Reference title:** Integration Testing, PLC Commissioning & Go-Live
**Phase name:** Integration testing, commissioning and go-live
**Delivers:** The convergence — full end-to-end runs of all three routes, machine commissioning support, acceptance testing and the move to production.
**Audience:** Quality assurance and commissioning
**Deferrable:** No

---

# Part 2 — Work Items

## FW-130
**Reference title:** Shell layout and the 1280×1024 shopfloor canvas
**Work item:** Screen framework and fixed shopfloor canvas
**Delivers:** Every screen renders identically on the panel and is readable at arm's length, standing, in gloves.
**Audience:** Line operator

## FW-131
**Reference title:** Route guards, interceptor wiring and the error envelope
**Work item:** Sign-in, role checks and session handling on every screen
**Delivers:** No flat wire screen is reachable without a valid sign-in and the right role.
**Audience:** Platform / foundation

## FW-132
**Reference title:** DI-swappable API client and domain models
**Work item:** Screen-to-service connection with a demonstration mode
**Delivers:** The whole operator experience can be built and reviewed with realistic sample data before the machines or the database are connected.
**Audience:** Platform / foundation

## FW-133
**Reference title:** Shared composite controls
**Work item:** The six shared screen controls, built once
**Delivers:** The setup table, live trace chart, tolerance display, step wizard, action bar and payoff weight bar are built once and reused, so every screen looks and behaves like one system.
**Audience:** Platform / foundation

## FW-134
**Reference title:** Shared primitive controls and `alert-banner`
**Work item:** Shared field, readout and alert elements
**Delivers:** Input fields, numeric readouts, pass/fail buttons and alert banners behave identically on every screen.
**Audience:** Platform / foundation

## FW-135
**Reference title:** SignalR client service
**Work item:** Live data client for the operator screens
**Delivers:** Live traces render smoothly and keep up with the machine feed without the panel stuttering or freezing.
**Audience:** Line operator

## FW-136
**Reference title:** `MockSignalRService` and the typed event set
**Work item:** Simulated live feed for early review
**Delivers:** The line board and run screens can be demonstrated and signed off before any machine is connected.
**Audience:** Platform / foundation

## FW-137
**Reference title:** PWA cache sync and the reconnect banner
**Work item:** Network drop handling on the operator screens
**Delivers:** A short network drop never leaves the operator looking at a blank screen — the last known state stays visible with a clear message that it is not live.
**Audience:** Line operator

## FW-N03
**Reference title:** Angular library scaffold, routing and configuration
**Work item:** Operator screen application set up
**Delivers:** The screen application is created, configured and connected to the existing plant systems, so every later stage is feature work rather than setup.
**Audience:** Platform / foundation

## FW-080
**Reference title:** `FlatWireHub` — strongly-typed, MessagePack, line groups
**Work item:** Live data service for all three lines
**Delivers:** All three lines can be watched live, on any number of screens, without anyone refreshing a page.
**Audience:** Supervisor

## FW-138
**Reference title:** Fifteen thin controllers over `UAController`
**Work item:** Service interface published early against sample data
**Delivers:** Screen development starts immediately and in parallel, against the real service shape rather than a guess at it.
**Audience:** Platform / foundation

## FW-139
**Reference title:** MediatR registration and pipeline behaviours
**Work item:** Shared request handling, validation and logging
**Delivers:** Every operation is validated and logged the same way, so a rule is written once rather than repeated in each screen.
**Audience:** Platform / foundation

## FW-140
**Reference title:** DI registration and the stub/real service swap
**Work item:** Business services with a demonstration mode
**Delivers:** The operator screens integrate with the real service before the database holds any data.
**Audience:** Platform / foundation

## FW-141
**Reference title:** Repository layer
**Work item:** Data access layer
**Delivers:** Business logic is kept separate from how data is stored, so the storage can be tuned without touching the rules.
**Audience:** Platform / foundation

## FW-142
**Reference title:** Dapper/EF data access and `FlatWireDbContext`
**Work item:** Data access performance approach
**Delivers:** High-volume reads such as the live trace stay fast, while ordinary writes stay simple and safe.
**Audience:** Platform / foundation

## FW-143
**Reference title:** Serilog structured logging and the audit log
**Work item:** Activity logging and audit trail
**Delivers:** Every action the system takes is logged, and any machine configuration can be reconstructed after the fact — who set it, to what, and when.
**Audience:** Compliance and quality

## FW-144
**Reference title:** Configuration binding
**Work item:** Environment configuration
**Delivers:** Machine addresses, connection details and timings are set per environment rather than built into the software, so moving from test to production is a configuration change.
**Audience:** IT and deployment

## FW-145
**Reference title:** JWT authentication and role authorization policies
**Work item:** Role-based access rules
**Delivers:** Each action admits only the roles that should be able to perform it — operator, supervisor, operations manager, quality, engineering.
**Audience:** Platform / foundation

## FW-146
**Reference title:** Global exception middleware and the response envelope
**Work item:** Consistent error handling
**Delivers:** Every failure produces a predictable, translatable message, so the operator sees a clear instruction rather than a technical error.
**Audience:** Line operator

## FW-147
**Reference title:** FluentValidation, value objects and the canonical cross-layer enums
**Work item:** One definition per business value
**Delivers:** A status or category means exactly the same thing on the screen, in the service and in the database — they cannot drift apart.
**Audience:** Platform / foundation

## FW-148
**Reference title:** Health checks
**Work item:** System health check
**Delivers:** A failing database or machine connection is visible to IT before an operator finds it on the floor.
**Audience:** IT and operations

## FW-149
**Reference title:** `IFlatWireClient` typed event contract
**Work item:** Live event definitions
**Delivers:** Every live update the system broadcasts is defined once, so a screen can never receive something it does not know how to display.
**Audience:** Platform / foundation

## FW-150
**Reference title:** Cadence-driven broadcast loop
**Work item:** Live data pacing
**Delivers:** The panel stays responsive with all three lines running, by pacing high-frequency measurements while sending important events immediately.
**Audience:** Line operator

## FW-151
**Reference title:** `PLCTagService` skeleton and `SimulatePLCTagPush`
**Work item:** Machine write service with simulation
**Delivers:** Every check-in stage can be built, demonstrated and tested long before the machines are commissioned.
**Audience:** Platform / foundation

## FW-N04
**Reference title:** `FlatWire` solution and four-project Clean Architecture skeleton
**Work item:** Application service created
**Delivers:** The new service is created to the same pattern as the plant's existing services, so it is maintainable by the team that already supports them.
**Audience:** Platform / foundation

## FW-N05
**Reference title:** OPC ingest hosted service and bounded channel
**Work item:** Continuous machine data collection
**Delivers:** Machine readings are collected continuously without the system falling behind — under heavy load it reduces detail rather than dropping the feed.
**Audience:** Line operator

## FW-001
**Reference title:** Shared-schema column renames and new columns
**Work item:** CANCELLED — existing scheduling system extended for flat wire
**Delivers:** CANCELLED August 18, 2026 at your direction — there will be no changes to the existing scheduling system's database. Flat wire is tracked entirely within the new flat wire module, and the systems the plant already runs are read and written exactly as they stand today. This removes the largest single risk in the plan.
**Audience:** Platform / foundation

## FW-002
**Reference title:** `INFLAT` coil status
**Work item:** CANCELLED — in-process status for flat wire material
**Delivers:** CANCELLED August 18, 2026, with the change above. Material actively on a flattening line is still distinctly tracked and still cannot be double-allocated — the status is simply held on the flat wire module's own rod and spool records rather than added to the existing scheduling system.
**Audience:** Scheduling and planning

## FW-004
**Reference title:** `AlloyProperty` lookup and seed
**Work item:** Alloy properties and tolerance bands
**Delivers:** Per-alloy process limits and tolerances are held as data, so they are corrected by an engineer rather than by a software change.
**Audience:** Process engineering

## FW-005
**Reference title:** Lookup group tables and seed
**Work item:** Equipment and reference tables
**Delivers:** Mill stands, draw dies, edgers, spool types and payoff positions exist as maintainable reference data the rest of the system validates against.
**Audience:** Platform / foundation

## FW-006
**Reference title:** Materials group tables
**Work item:** Rod, run and spool records
**Delivers:** Every rod, production run and spool has a permanent record, linked so traceability can be enforced rather than assembled later.
**Audience:** Platform / foundation

## FW-007
**Reference title:** Runs and Quality/Output group tables
**Work item:** Production event and output records
**Delivers:** Business rules stated in the specification are enforced by the database itself, so they cannot be bypassed.
**Audience:** Platform / foundation

## FW-152
**Reference title:** `FlatWireDB` creation, ordered DDL runner, indexes and grants
**Work item:** One-step database build
**Delivers:** Any environment can be built from scratch, and rebuilt safely, with a single script — no manual steps to forget.
**Audience:** IT and deployment

## FW-060
**Reference title:** Dashboard 1 — Line Status Overview
**Work item:** Line status board
**Delivers:** Floor-wide awareness of all three lines from one screen, without walking the floor.
**Audience:** Supervisor

## FW-153
**Reference title:** Alert chips, reconnect banner and cached-state fallback
**Work item:** Alerts and feed status on the board
**Delivers:** The supervisor can tell the difference between "nothing is wrong" and "we are not receiving data" — the two look identical on a naive board.
**Audience:** Supervisor

## FW-154
**Reference title:** `GET /lines/status` and `LineStatusService`
**Work item:** Board snapshot on load
**Delivers:** The board shows the current state the instant it opens, then stays live, rather than starting blank and filling in.
**Audience:** Supervisor

## FW-155
**Reference title:** `FlatWireRun(LineId, Status)` index
**Work item:** Board query performance
**Delivers:** The board stays fast with every supervisor terminal refreshing it at once.
**Audience:** IT and operations

## FW-N06
**Reference title:** Alert rules engine and the `AlertRaised`/`AlertCleared` lifecycle
**Work item:** Threshold alerts
**Delivers:** A developing problem — a payoff running low, a measurement drifting — reaches the supervisor before it stops the line.
**Audience:** Supervisor

## FW-061
**Reference title:** Dashboard 2 — Rod Check-in six-step wizard (FL1/FL3)
**Work item:** Guided rod check-in
**Delivers:** A step-by-step check-in that will not let the operator proceed until every gate clears, so the machine is configured correctly and the wrong setup is never silently applied.
**Audience:** Line operator (FL1 and FL3)

## FW-082
**Reference title:** PLC tag group push on check-in acknowledgement
**Work item:** Machine configured on operator confirmation
**Delivers:** The operator's confirmation configures the machine in one action — the line runs the setup that was confirmed and nothing else.
**Audience:** Line operator

## FW-157
**Reference title:** `POST /checkin/rod` and `CheckInService`
**Work item:** Check-in written safely across systems
**Delivers:** A machine or network failure part-way through check-in never leaves a half-configured machine with a run recorded as started.
**Audience:** Platform / foundation

## FW-158
**Reference title:** `PayoffStagingController` — staging commands and queries
**Work item:** Payoff bay staging service
**Delivers:** Two rods can never be recorded on one bay, even if two operators act at the same moment.
**Audience:** Platform / foundation

## FW-159
**Reference title:** `RodStaging`, the check-in write path and the `INFLAT` write
**Work item:** Check-in records with bay rules enforced
**Delivers:** One rod per bay and one bay per rod are guaranteed by the data, not by the screen.
**Audience:** Platform / foundation

## FW-160
**Reference title:** `PayoffStateChanged` and the check-in broadcasts
**Work item:** Bay occupancy live on the board
**Delivers:** Bay status on the supervisor board reflects what is physically on the machine right now, not what it was at the last refresh.
**Audience:** Supervisor

## FW-N01
**Reference title:** Dashboard 2A — Rod Pre-Check-in station
**Work item:** Pre-check-in staging station
**Delivers:** The next rod is staged and inspected against the idle bay while the current one is still running, so the line runs continuously through the weld.
**Audience:** Line operator (FL1 and FL3)

## FW-062
**Reference title:** Dashboard 3 — Active Run Monitor (FL1) and FL3 variant
**Work item:** Active run screen
**Delivers:** One screen showing the run live with every action one touch away — the operator never leaves the monitor to record something.
**Audience:** Line operator (FL1 and FL3)

## FW-081
**Reference title:** `gauge-trace-chart` live streaming, maximize and runtime source toggle
**Work item:** Live gauge and width trace
**Delivers:** Drift is visible as it develops, so the operator can react before it produces out-of-specification material.
**Audience:** Line operator

## FW-162
**Reference title:** `run-status-cards`
**Work item:** Machine and material status strip
**Delivers:** Machine state, material in process and which components are active read at a glance from one row.
**Audience:** Line operator

## FW-163
**Reference title:** `info-grid` and `chart-tab-strip`
**Work item:** Order and material detail on the run screen
**Delivers:** The operator can check an order tolerance without leaving the run screen.
**Audience:** Line operator

## FW-164
**Reference title:** `GET /run/active`, `GET /run/{runId}/gaugetrace` and `RunQueryService`
**Work item:** Run resume and historical profile
**Delivers:** The run screen resumes correctly after a reload, and a finished run's measured profile can be reviewed — which is how the finishing line sees its incoming material.
**Audience:** Line operator

## FW-165
**Reference title:** `sp_GetGaugeTrace`
**Work item:** Trace query performance
**Delivers:** Reviewing the trace of a long run stays fast, however much data it holds.
**Audience:** IT and operations

## FW-063
**Reference title:** Weld capture — `fw-mark-welded-dialog`
**Work item:** Weld capture
**Delivers:** The induction weld joining the running rod to the staged one is recorded, so output footage is attributed to the correct source rod on a customer certificate.
**Audience:** Line operator (FL1 and FL3)

## FW-065
**Reference title:** SPC checkpoint dialog
**Work item:** Quality checkpoint capture
**Delivers:** A measurement is recorded against tolerance and the operator is routed correctly when it fails, so out-of-specification material is suspended rather than shipped.
**Audience:** Line operator

## FW-070
**Reference title:** Roll adjust dialog
**Work item:** Mid-run roll adjustment
**Delivers:** Roll gaps are corrected during the run without editing the approved setup, so the setup stays the record of intent and the correction is recorded against the run.
**Audience:** Line operator (FL2 and FL3)

## FW-071
**Reference title:** Pause and Resume dialogs
**Work item:** Pause and resume with reason capture
**Delivers:** Downtime is categorised and attributable, and every way of resuming — continue, reject material, check out the rod, stay paused — is reachable from one place.
**Audience:** Line operator

## FW-073
**Reference title:** Die change dialog
**Work item:** Mid-run die change
**Delivers:** A die change is recorded and, when the reason could affect dimensions, the operator is required to take a quality measurement before the run continues.
**Audience:** Line operator (FL1 and FL3)

## FW-166
**Reference title:** `POST /weldevent` and `WeldService`
**Work item:** Single weld record
**Delivers:** Both places an operator can record a weld produce one identical record, so the traceability chain has no gaps or duplicates.
**Audience:** Platform / foundation

## FW-167
**Reference title:** `POST /diechange` and `DieChangeService`
**Work item:** Die change rules enforced in the service
**Delivers:** The required quality check after a gauge-affecting die change cannot be skipped.
**Audience:** Platform / foundation

## FW-168
**Reference title:** `POST /spc` and `SpcService`
**Work item:** Quality verdict calculated centrally
**Delivers:** Whether a measurement is in specification is decided by the system against the recorded tolerance, never by the screen or the operator.
**Audience:** Quality

## FW-169
**Reference title:** `POST /rolloverride` and `RollOverrideService`
**Work item:** Roll correction applied and recorded
**Delivers:** A correction reaches the machine and is logged with a measurement, and never alters the approved setup.
**Audience:** Platform / foundation

## FW-170
**Reference title:** `POST /run/{id}/pause` and `/resume`, and `RunControlService`
**Work item:** Pause drives the machine and the clock together
**Delivers:** A paused line is genuinely idle at the machine, and its downtime is measured rather than estimated.
**Audience:** Platform / foundation

## FW-171
**Reference title:** The five in-run event tables
**Work item:** Every in-run event recorded against run and footage
**Delivers:** The live trace, the reports and the customer certificate all read from one record, so they cannot disagree.
**Audience:** Platform / foundation

## FW-172
**Reference title:** Run-event markers and the `LineStatus` transitions
**Work item:** Events appear on the trace immediately
**Delivers:** What the operator records and what the screen shows never disagree.
**Audience:** Line operator

## FW-067
**Reference title:** WIP rejection dialog
**Work item:** Suspect material hold
**Delivers:** Suspect material is flagged in seconds with its context already filled in, and the supervisor is alerted.
**Audience:** Line operator

## FW-072
**Reference title:** Rod checkout dialog — Modes A, B and P
**Work item:** Rod checkout
**Delivers:** A rod removed before it finishes is recorded with the right disposition for how far it got, so material is never left as ghost inventory.
**Audience:** Line operator

## FW-173
**Reference title:** Partial rod re-check-in (carry-forward)
**Work item:** Part-run rod carry-forward
**Delivers:** A rod that has already run is put on the carry-forward path, so its remaining footage is never mistaken for a fresh rod.
**Audience:** Line operator

## FW-174
**Reference title:** `POST /wipreject`, `POST /checkout` and their services
**Work item:** Off-ramps written with their status changes
**Delivers:** The disposition recorded and the material status can never disagree.
**Audience:** Platform / foundation

## FW-175
**Reference title:** Durable supervisor pending-approval queue
**Work item:** Pending decisions survive a disconnect
**Delivers:** Material on hold is never stranded because a terminal disconnected before the decision was made.
**Audience:** Supervisor

## FW-176
**Reference title:** `WipRejection` / `RodCheckout` tables and the shared `coils` carry-forward columns
**Work item:** Carry-forward recorded on the material
**Delivers:** A part-run rod is identifiable at any station, not only inside the run it came from.
**Audience:** Platform / foundation

## FW-177
**Reference title:** Exception broadcasts and the supervisor notification
**Work item:** Holds and checkouts reach the supervisor immediately
**Delivers:** The supervisor can act on locked material without being told verbally.
**Audience:** Supervisor

## FW-064
**Reference title:** Dashboard 5 — FL2 Spool Check-in
**Work item:** Spool check-in
**Delivers:** The finishing operator checks in a spool and sees how it was produced before running it, so they know what they are finishing.
**Audience:** Line operator (FL2)

## FW-124
**Reference title:** Dashboard 5A — FL2 Spool Queue
**Work item:** Spool queue
**Delivers:** Every spool available to run is visible without scanning anything, so the operator knows what material is waiting instead of guessing.
**Audience:** Line operator (FL2)

## FW-178
**Reference title:** Dashboard 3 FL2 variant configuration
**Work item:** Finishing line run screen
**Delivers:** The run screen shows spool in and coil out rather than rod payoffs, matching what the finishing line actually does.
**Audience:** Line operator (FL2)

## FW-179
**Reference title:** `POST /checkin/spool` and `GET /spools`
**Work item:** Spool check-in and lookup service
**Delivers:** Scanning a spool resolves its order and the rest of that order's material in a single step, and checks it in against the finishing line.
**Audience:** Line operator (FL2)

## FW-180
**Reference title:** `SpoolCheckin` table and the `SpoolProcessing.OrderNo` index
**Work item:** Spool queue performance
**Delivers:** The spool queue stays fast as the number of spools grows.
**Audience:** IT and operations

## FW-181
**Reference title:** FL2 null-gauge contract and the Live/Profile binding
**Work item:** Clear labelling where live measurement is unavailable
**Delivers:** The finishing line states plainly that it has no live gauge feed, so a drawn line is never read as a real measurement.
**Audience:** Line operator (FL2)

## FW-N02
**Reference title:** Spool completion weight milestones and machine-stop confirmation
**Work item:** Approaching-target notification
**Delivers:** The operator is told as a spool approaches its target weight, so the machine stop is expected rather than a surprise.
**Audience:** Line operator (FL1)

## FW-066
**Reference title:** Dashboard 7 — Output Coil Completion
**Work item:** Coil completion
**Delivers:** The finished coil is confirmed with its calculated weight and dimensions, creating the customer-facing record at the moment the coil comes off the machine.
**Audience:** Line operator (FL2 and FL3)

## FW-182
**Reference title:** Dashboard 7b — Packing Station
**Work item:** Packing station screen
**Delivers:** Finished coils are packed, labelled and skids closed from a station view, without going back to the run screen.
**Audience:** Packing operator

## FW-183
**Reference title:** `source-traceability-table` and `skid-tracker`
**Work item:** Coil source traceability
**Delivers:** Each coil records which source rods produced which footage — the chain a welding-wire certificate is built from.
**Audience:** Quality

## FW-184
**Reference title:** `coil-label` and the print path
**Work item:** Coil label
**Delivers:** A correct physical label so the coil is identifiable in the warehouse and on the customer's dock.
**Audience:** Packing operator

## FW-185
**Reference title:** `POST /coil/complete`, `GET /coil/{alpha}/label` and their services
**Work item:** Completion creates the record, the genealogy and the skid together
**Delivers:** No coil can exist without its traceability — the identifier, the source history and the packing record are created in one operation or not at all.
**Audience:** Platform / foundation

## FW-186
**Reference title:** `CoilOutput`, `CoilTraceability` and the non-overlap trigger
**Work item:** Overlapping traceability made impossible
**Delivers:** A certificate can never attribute the same foot of material to two different rods.
**Audience:** Quality

## FW-187
**Reference title:** Completion broadcasts
**Work item:** Completion visible immediately
**Delivers:** The board and the packing station reflect completion at once, so the next job starts without anyone asking.
**Audience:** Supervisor

## FW-189
**Reference title:** Dashboard 2 and 3 FL3 variants
**Work item:** Hybrid check-in and run screens
**Delivers:** The hybrid route has its own check-in and run screens, so one confirmation configures both mills.
**Audience:** Line operator (FL3)

## FW-190
**Reference title:** Hybrid single-batch PLC push and `RouteMode=Hybrid`
**Work item:** Both mills configured from one confirmation
**Delivers:** Material flows continuously through both mills without a second check-in.
**Audience:** Line operator (FL3)

## FW-191
**Reference title:** `RouteMode` and the no-intermediate-spool rule
**Work item:** Route recorded on every run
**Delivers:** Reports and certificates can tell the three production routes apart.
**Audience:** Quality and production control

## FW-192
**Reference title:** Continuous end-to-end trace on FL3
**Work item:** Unbroken hybrid trace
**Delivers:** The trace runs unbroken from rod to finished coil, so traceability is continuous across the whole hybrid run.
**Audience:** Line operator (FL3)

## FW-090
**Reference title:** Flattening Lines report tab and reporting views
**Work item:** Flat wire reporting section
**Delivers:** Flat wire reports appear in the reporting tool the quality team already uses — no new application to learn.
**Audience:** Quality

## FW-091
**Reference title:** Gauge Trace report
**Work item:** Gauge trace report
**Delivers:** The measured gauge profile of any run can be reviewed after the fact.
**Audience:** Quality

## FW-092
**Reference title:** Gauge CPK Deviation and CPK report
**Work item:** Process capability report
**Delivers:** Capability indices across product families, to demonstrate the process is in control.
**Audience:** Process engineering

## FW-093
**Reference title:** Coil Pass Detail report
**Work item:** Production detail report
**Delivers:** The full pass detail behind a finished coil, so how it was made can be reconstructed.
**Audience:** Process engineering

## FW-094
**Reference title:** SPC at Flattening Line report
**Work item:** Quality checkpoint report
**Delivers:** Every quality checkpoint in one report, so gates can be audited across a shift or an order.
**Audience:** Quality

## FW-095
**Reference title:** Cut Traceability report
**Work item:** Traceability and certification report
**Delivers:** A finished coil traced back to the supplier heat — the report a welding-wire certificate of conformance is issued from.
**Audience:** Quality

## FW-003
**Reference title:** Machine template tabs — register FL1, FL2, FL3
**Work item:** Three lines registered as plant machines
**Delivers:** The three flattening lines are fully configured machines, so scheduling, planning, reporting and the shop floor can all reference them.
**Audience:** IT and administration

## FW-054
**Reference title:** Alloys — Material Type across Properties, Reduction Rules and Vendor O Gauge
**Work item:** Material type on alloy maintenance
**Delivers:** Flat wire and strip are distinguishable wherever alloy data is edited.
**Audience:** Process engineering

## FW-194
**Reference title:** Alloy lookup admin grid
**Work item:** Alloy and tolerance maintenance screen
**Delivers:** Alloy properties and tolerance bands are maintained by an engineer without a software change, so reference data is corrected as the mill learns the process.
**Audience:** Process engineering

## FW-195
**Reference title:** Role assignment UI
**Work item:** Role assignment screen
**Delivers:** Operator, supervisor and manager access is managed in the application rather than by a database administrator.
**Audience:** IT and administration

## FW-196
**Reference title:** Alloy CRUD, machine config and role config endpoints
**Work item:** Administration services with audit
**Delivers:** Reference data cannot be changed anonymously — every change records who made it and when.
**Audience:** Compliance and quality

## FW-197
**Reference title:** Reference-data admin wiring
**Work item:** Equipment reference maintenance
**Delivers:** Mill stands, draw dies, edgers and spool configurations stay maintainable as the plant changes.
**Audience:** Process engineering

## FW-198
**Reference title:** Reference-data change broadcast
**Work item:** Tolerance changes reach open screens
**Delivers:** An operator is never validating against a tolerance band that was changed while their screen was open.
**Audience:** Line operator

## FW-200
**Reference title:** PLC commissioning support
**Work item:** Machine commissioning support
**Delivers:** The system is switched from simulation to live machine control with engineering support on hand, so the mill is configured by the application rather than by hand.
**Audience:** Commissioning and controls engineering

## FW-201
**Reference title:** Defect allowance and renamed-column regression
**Work item:** Defect resolution allowance
**Delivers:** Time is budgeted to fix what the end-to-end runs find, so defects are closed before the trial rather than carried into it.
**Audience:** Quality assurance

---

# Part 3 — What changes the date

## L1
**Lever:** Complete the platform foundation before the sprints start
**Effect:** Removes about two sprints.
**Detail:** The foundation is the largest single block of work and every later stage depends on it. Delivering it in the run-up rather than inside the sprints is the largest lever available by some distance — but it needs about five people during that period, which is more than the team this plan is built on.

## L2
**Lever:** Let the final testing and commissioning stage start early
**Effect:** Removes one sprint — completion moves forward about two weeks.
**Detail:** The last sprint exists because end-to-end testing and machine commissioning are held to a window of their own, after everything they verify is finished. Overlapping that window with the preceding stage would recover two weeks, but it means testing against a system that is still changing. **This is a decision to take deliberately, not a scheduling convenience.**

## L3
**Lever:** Add a fourth developer
**Effect:** Removes one sprint — completion moves forward about two weeks.
**Detail:** Only a fortnight, and that is the important part: **the tail of the plan is waiting on dependencies, not on people.** A fourth developer leaves the last two sprints barely a third occupied, and a fifth brings completion only to the end of October. **No team size reaches the end of September on this start date.**

## L4
**Lever:** Accept the date the plan gives
**Effect:** No change to scope or team.
**Detail:** The plan lands inside the planned production window, though without margin for a trial. Moving the development completion date does not by itself move production, provided acceptance testing and stakeholder sign-off are scheduled after it rather than alongside it.

---

# Part 4 — Milestones and dependencies

## M1
**Item:** Platform foundation complete
**Type:** Delivery milestone
**Detail:** Screen framework, application services and database in place, with the machine-write layer running in simulation. Everything after this point is feature work.
**Covers:** 1A,1B,1C

## M2
**Item:** First live end-to-end slice
**Type:** Delivery milestone
**Detail:** Machine data reaching a live line status board. The first point at which the system can be seen working against real equipment data.
**Covers:** 3

## M3
**Item:** Full rod-to-run journey working
**Type:** Delivery milestone
**Detail:** Check in a rod, configure the machine, watch the run live, record events against it. The core operator experience end to end.
**Covers:** 4,5,6

## M4
**Item:** All three production routes complete
**Type:** Delivery milestone
**Detail:** Standalone drawing, standalone finishing and the hybrid route, through to a finished coil with its traceability and label.
**Covers:** 7,8,9,10

## M5
**Item:** Development complete
**Type:** Delivery milestone
**Detail:** All planned scope built and internally tested. Acceptance testing and machine commissioning follow this date; they are not included in it.
**Covers:** 1A,1B,1C,3,4,5,6,7,8,9,10,11,13,14

## D1
**Item:** Tolerance values per alloy
**Type:** Needed from you
**Detail:** Minimum and maximum values for gauge, width, diameter and ovality, per alloy. Check-in inspection cannot validate anything until these exist, and they cannot be guessed. **Needed before rod check-in is built.**

## D2
**Item:** Footage-to-weight basis
**Type:** Needed from you
**Detail:** How a finished coil's weight is derived from its footage — from target dimensions, from measurement at completion, or integrated across the run. It affects the weight printed on every customer label. **Needed before coil completion is built.**

## D3
**Item:** Customer spool weight range
**Type:** Needed from you
**Detail:** The minimum and maximum finished weight a customer will accept, so the system knows when a spool is complete and when a short close needs approval.

## D4
**Item:** Machine tag confirmation
**Type:** Needed from you
**Detail:** Confirmation from the controls engineer of the address of every value the system writes to or reads from the machines. Until confirmed, all machine interaction runs in simulation. **Needed before commissioning.**

## D5
**Item:** Rod supply and order scheduling
**Type:** External dependency
**Detail:** Rod receiving and order scheduling are handled by existing systems and separate teams. Check-in has no material and no scheduled job until both are in place — if either slips, this plan slips with it.

## D6
**Item:** Machine availability for commissioning
**Type:** External dependency
**Detail:** The final switch from simulation to live machine control needs the controllers and the mill available, with engineering support present. It cannot be compressed by adding developers.

---

# Part 5 — Assumptions and risks

## A1
**Item:** Screen designs are final
**Type:** Assumption
**Detail:** The approved screen designs are treated as the visual specification, so no design time is included. A significant redesign would add effort not shown here.

## A2
**Item:** Existing plant systems are reused
**Type:** Assumption
**Detail:** Sign-in, machine configuration, planning, scheduling, reporting, rejection, yield and costing are extended rather than rebuilt. No new technology is introduced.

## A3
**Item:** Testing and business analysis are not in these figures
**Type:** Assumption
**Detail:** The effort shown is development only. Quality assurance, business analysis, acceptance testing and contingency are planned separately and are additional to every date on this sheet.

## A4
**Item:** No onboarding time is included
**Type:** Assumption
**Detail:** The figures assume developers are productive from day one. A new joiner needs ramp-up time that is not costed here.

## R1
**Item:** The team is smaller than the work requires
**Type:** Risk — high
**Detail:** Three developers do not complete development by the end of September — the work needs about four people sustained, and the sprints start on 24 August, which removes the run-up from the available capacity. The date on the summary sheet is the honest consequence. **Mitigation:** choose deliberately between team size, scope and date rather than discovering the gap late.

## R2
**Item:** Machine commissioning slips
**Type:** Risk — medium
**Detail:** Commissioning needs the controllers and the mill. **Mitigation:** every screen and service is built and testable against simulation, so development is not blocked — but go-live is.

## R3
**Item:** Outstanding decisions block specific work
**Type:** Risk — high
**Detail:** Several items above cannot be built until a decision is made. **Mitigation:** each is listed with the work it gates, so the sequence can be planned around the answer rather than waiting on it.

## R4
**Item:** Changes to the shared scheduling system affect existing reports
**Type:** Risk — medium
**Detail:** Extending the existing schema for flat wire touches data that current reports read. **Mitigation:** a full impact review across the existing systems is planned before the change, with a tested reversal path.

## R5
**Item:** Performance targets are not yet defined
**Type:** Risk — medium
**Detail:** How often machine data must update, how many screens must be supported at once, and how long history is retained are not yet specified. **Mitigation:** the live data layer is built to be tuned by configuration, but the targets should be agreed before load testing.

## R6
**Item:** Two areas carry unresolved design questions
**Type:** Risk — medium
**Detail:** Recovering cleanly when a check-in fails part-way across systems, and the basis for calculating coil weight, are both still open. **Mitigation:** an allowance is held for each; neither is included in the effort shown.
