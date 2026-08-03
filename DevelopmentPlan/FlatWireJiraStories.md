# Flat Wire Mill — Jira Story Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** April 30, 2026
**Document Type:** Jira Story Backlog
**Status:** Draft — Pending team sizing and sprint assignment
**Development Window:** ~10 weeks (May – June 2026)
**Trial Target:** July 1, 2026 | **Production Target:** August 1, 2026

---

## Sprint Overview

| Sprint | Weeks | Theme |
|--------|-------|-------|
| Sprint 1 | Wk 1–2 | Foundation — DB schema, machines, pass schedule data model |
| Sprint 2 | Wk 3–4 | Pass Schedule UI + Rod Receiving |
| Sprint 3 | Wk 5–6 | Planning, Scheduling, Web app changes |
| Sprint 4 | Wk 7–8 | Shopfloor UI — all dashboards |
| Sprint 5 | Wk 9–10 | Real-time/PLC, Reporting, Yield/Scrap, UAT |

---

## Story Points Legend

`1` Trivial · `2` Small · `3` Medium · `5` Large · `8` Extra Large · `13` Epic-level risk

---

## Priority Legend

`Critical` Blocks go-live · `High` Required by July 1 trial · `Medium` Required by Aug 1 production · `Low` Post go-live

---

---

# EPIC 1 — Foundation & Infrastructure (FW-E01)

**Goal:** Establish the database schema, machine configuration, and alloy lookup data that every other epic depends on.
**Sprint:** 1
**Blocks:** All other epics.

---

### FW-001 · Database schema changes — column renames and new columns
**Points:** 5 · **Priority:** Critical · **Sprint:** 1

**As a** developer,
**I want** all scheduling database columns renamed per the flat wire spec,
**So that** flat wire material (bundles, wire rod) fits the existing schema without ambiguity.

**Acceptance Criteria:**
- [ ] `CoilNo` → `Coil/BundleNo`
- [ ] `SlitWidth` → `Slit/FlatWidth`
- [ ] `IsCampaingCoil` → `IsCampaignCoil/Bundle` (typo corrected)
- [ ] `CoilLocation` → `Coil/BundleLocation`
- [ ] `CoilWeight` → `Coil/BundleWeight`
- [ ] `CoilStatus` → `Coil/BundleStatus`
- [ ] `OutgoingCoilId` → `OutgoingCoil/BundleId`
- [ ] `OutgoingCoilOd` → `OutgoingCoil/BundleOd`
- [ ] New column `OutgoingCoil/BundleWidth` added
- [ ] New column `IncomingWireDia` added
- [ ] All existing stored procedures, views, and API queries updated to use new names
- [ ] Full impact analysis completed before execution; no regressions in existing reports or screens

**Dependencies:** None
**Notes:** High blast-radius change — requires full query audit before migration runs.

---

### FW-002 · Add INFLAT coil status
**Points:** 2 · **Priority:** Critical · **Sprint:** 1

**As a** scheduling operator,
**I want** a new coil status `INFLAT`,
**So that** material actively being processed on a flattening line is distinctly tracked.

**Acceptance Criteria:**
- [ ] `INFLAT` status added to the coil status reference table
- [ ] Status is set when a rod is checked in and acknowledged on FL1 or FL2
- [ ] Status is cleared (reverted) on rod checkout, run completion, or WIP rejection
- [ ] `INFLAT` appears in all status dropdowns and filter lists where coil status is shown
- [ ] Existing status transition rules are not broken

**Dependencies:** FW-001

---

### FW-003 · Register FL1, FL2, FL3 in the Machines application
**Points:** 5 · **Priority:** Critical · **Sprint:** 1

**As a** system administrator,
**I want** FL1, FL2, and FL3 registered as fully configured machines,
**So that** scheduling, planning, reporting, and shopfloor modules can reference them.

**Acceptance Criteria:**
- [ ] FL1, FL2, FL3 each have a unique `MachineId` / `IdNo`
- [ ] Machine template tabs configured per spec:
  - Main (combined Slitter + Mill rows)
  - Roll Finish (Mill template, as-is)
  - Pass Schedule (button renamed "Flattening Line Schedule"; window header updated)
  - Coating (Slitter template, as-is)
  - KSI / Gauge Max Cuts (Slitter; "Max # of Cuts" column removed)
  - Rewind Capabilities (retained for future use)
  - ID Width Max Cuts (Slitter, as-is)
  - Setup / Handling Times (Slitter, as-is)
  - Tooling Inventory (Slitter + new tooling types: Dies and Edgers)
  - Speed (Mill; "Min/Max Gauge" → "Min/Max Gauge/Diameter"; checkboxes for DB1, DB2, FM1-S1, FM2-S1/S2/S3)
  - Material Loss (Mill; scrap calculated in footage not weight)
  - History (merged Mill + Slitter attributes)
- [ ] FL1, FL2, FL3 appear in all machine dropdowns system-wide
- [ ] Operation letter `F` is used for flattening in `OpLetter` / `PrevOpLetter` / `RemainingOps`

**Dependencies:** FW-001, FW-002
**Notes:** Naj/Bob/Tim standards spreadsheet must be finalized first — this is an external dependency.

---

### FW-005 · Fix and update existing FlatWire reference tables
**Points:** 3 · **Priority:** Critical · **Sprint:** 1

**As a** developer,
**I want** the existing FlatWire tables corrected and aligned with the API contracts,
**So that** the table structure matches the domain model before any application code is written against it.

**Background:** A review of `FlatWireTables.xlsx` against the API contracts identified structural gaps in all 7 existing tables. See [FlatWireTables.md](FlatWireTables.md) for the full analysis.

**Acceptance Criteria:**

**`FlatLineProcessing` → rename to `FlatWireRun`:**
- [ ] Add `RunId` varchar(20) — stable run identifier (e.g. `RUN-0042`)
- [ ] Add `LineId` varchar(5) NOT NULL — `FL1`, `FL2`, `FL3`
- [ ] Add `PassScheduleId` varchar(30) — FK to `PassSchedule`
- [ ] Add `RouteMode` varchar(15) — `Standalone` or `Hybrid`
- [ ] Add `Status` varchar(20) NOT NULL — `Running`, `Paused`, `Complete`, `Aborted`
- [ ] Add `TargetGauge`, `GaugeTolerance`, `TargetWidth`, `WidthTolerance` decimal columns
- [ ] Add `StartedAt`, `PausedAt`, `CompletedAt` datetimeoffset columns
- [ ] Rename `StopFeet` → `FootageFt`; rename `StartingPositionId` → `PayoffPositionId`
- [ ] Clarify / remove duplicate `CoilOrderPlanId` vs `PlanId` after review with team

**`FlatLineSetup` → rename to `PassScheduleComponent`:**
- [ ] Add `PassScheduleId` varchar(30) NOT NULL — FK to `PassSchedule.ScheduleId`
- [ ] Add `ComponentName` varchar(20) NOT NULL — enum: `DB1`, `DB2`, `FM1`, `EdgeSet`, `FM2_8in`, `FM2_6inS1`, `FM2_6inS2`
- [ ] Add `State` varchar(10) NOT NULL — `Active`, `Bypass`, `Skip`
- [ ] Add `ParameterValue` decimal NULL
- [ ] Add `EdgeType` varchar(10) NULL — `Round`, `Square`
- [ ] Remove `SpoolId` column (does not belong on a component row)
- [ ] Remove `MfgOrderNo`, `StopNo` (belong on run/schedule header, not component)
- [ ] Consolidate `StandSequence`/`DrawerSequence` into single `Sequence` int column

**`Drawer`:**
- [ ] Rename `Diameter` → `DiameterIn` decimal(8,4)
- [ ] Add `MinDiameterIn`, `MaxDiameterIn` decimal(8,4) NULL
- [ ] Add `IsActive` bit NOT NULL DEFAULT 1

**`Edger`:**
- [ ] Add `EdgeType` varchar(10) NOT NULL — `Round` or `Square`
- [ ] Rename `Set` → `ToolingSetNo` varchar(20) NULL
- [ ] Add `IsActive` bit NOT NULL DEFAULT 1

**`Stand`:**
- [ ] Rename `MinId` → `MinGaugeIn`, `MaxId` → `MaxGaugeIn` decimal(8,4)
- [ ] Rename `MinOD` → `MinWidthIn`, `MaxOd` → `MaxWidthIn` decimal(8,4)
- [ ] Add `LineId` varchar(5) NULL — which line this stand belongs to, or NULL if shared
- [ ] Add `IsActive` bit NOT NULL DEFAULT 1

**`SpoolConfiguration`:**
- [ ] Rename `MinWeight` → `MinWeightLb`, `MaxWeight` → `MaxWeightLb`
- [ ] Rename `MinId` → `MinCoreDiameterIn`, `MaxId` → `MaxCoreDiameterIn`
- [ ] Rename `MinOd` → `MinOuterDiameterIn`, `MaxOd` → `MaxOuterDiameterIn`

**`Spool`:**
- [ ] Add `Alpha` varchar(20) NOT NULL UNIQUE — e.g. `SP-00021`; the scan key at FL2 check-in
- [ ] Add `Status` varchar(20) NOT NULL — `RECEIVED`, `STAGED`, `INFLAT`, `COMPLETE`, `HOLD`, `SCRAP`
- [ ] Add `GaugeIn`, `WidthIn` decimal(8,4) NULL
- [ ] Add `GrossWeightLb`, `NetWeightLb` decimal NULL
- [ ] Add `Location` varchar(50) NULL
- [ ] Add `LineId` varchar(5) NULL
- [ ] Add `SourceRunId` varchar(20) NULL — FK to `FlatWireRun.RunId` (the FL1 run that produced the spool)
- [ ] Add `ReceivedAt`, `StagedAt` datetimeoffset NULL
- [ ] Rename `ParentRod` → `ParentRodAlpha`

**Dependencies:** None (pure schema work; no application dependencies yet)
**Notes:** These fixes must be completed before FW-010 (Pass Schedule API) is built, as the API implementation maps directly to these tables.

---

### FW-006 · Create FlatWireDB — core entity tables
**Points:** 5 · **Priority:** Critical · **Sprint:** 1

**As a** developer,
**I want** all core FlatWireDB tables created per the agreed schema,
**So that** every API in the FlatWire microservice has a target database to write to.

**Background:** The API contracts reference 14 tables that do not exist in `FlatWireTables.xlsx`. This story creates the core entity group. See [FlatWireTables.md](FlatWireTables.md) for full column definitions.

**Acceptance Criteria:**

- [ ] `PassSchedule` table created (header for pass schedules):
  `ScheduleId`, `Description`, `Alloy`, `LineId`, `RouteMode`, `Status`, `TargetGauge`, `GaugeTolerance`, `TargetWidth`, `WidthTolerance`, `LineSpeedMinFpm`, `LineSpeedMaxFpm`, `CreatedBy`, `CreatedAt`, `ModifiedBy`, `ModifiedAt`

- [ ] `Rod` table created (R-series wire rod lifecycle):
  `Id`, `Alpha`, `Alloy`, `Temper`, `DiameterIn`, `GrossWeightLb`, `NetWeightLb`, `Tare`, `SupplierHeat`, `Status`, `Location`, `ReceivedAt`

- [ ] `RodCheckin` table created (check-in event with inspection results):
  `Id`, `RunId`, `LineId`, `RodAlpha`, `PayoffPosition`, `DiameterMeasuredIn`, `GrossWeightLb`, `NetWeightLb`, `PassScheduleId`, `OrderId`, `OperatorId`, `CheckedInAt`, `PlcTagsPushed`, `InspectionOxidation`, `InspectionSurfaceDefects`, `InspectionWaterStains`, `InspectionConnectorTag`, `InspectionNotes`, `SpcM1In`, `SpcM2In`, `SpcOvalityIn`

- [ ] `RunPauseEvent` table created (pause/resume cycles):
  `Id`, `RunId`, `PausedAt`, `FootageAtPause`, `ReasonCode`, `ReasonCategory`, `Notes`, `ResumedAt`, `PauseDurationSeconds`, `Outcome`, `ActivityCompleted`

- [ ] `RodCheckout` table created (rod removal events):
  `Id`, `CheckoutId`, `RunId`, `LineId`, `RodAlpha`, `PayoffPosition`, `Mode`, `FootageAtCheckout`, `ReasonCode`, `RodDisposition`, `RemainingWeightLbEstimate`, `InProcessMaterialDisposition`, `PartialSpoolAlpha`, `NewRodStatus`, `PlcTagsCleared`, `OperatorId`, `Timestamp`

- [ ] All FKs, unique constraints, and NOT NULL constraints in place
- [ ] `PassSchedule.ScheduleId` is the PK (varchar, not identity int) to match the `PS-1100-FL1-003` format
- [ ] `Rod.Alpha` and `Spool.Alpha` have a unique index; scan at check-in uses this index
- [ ] Migration script created and tested against dev database
- [ ] EF Core `DbContext` updated in `FlatWire.Infrastructure`

**Dependencies:** FW-005
**Notes:** `PassSchedule` and `PassScheduleComponent` supersede `FlatLineSetup`. Keep `FlatLineSetup` for the migration period only; drop after data is migrated.

---

### FW-007 · Create FlatWireDB — event and output tables
**Points:** 5 · **Priority:** Critical · **Sprint:** 1

**As a** developer,
**I want** all run-event and output tables created,
**So that** weld events, die changes, SPC checkpoints, WIP rejections, and completed coils can be persisted.

**Background:** Continuation of FW-006. These tables record everything that happens during a run and the output it produces. See [FlatWireTables.md](FlatWireTables.md) for full column definitions.

**Acceptance Criteria:**

- [ ] `WeldEvent` table created:
  `Id`, `WeldEventId`, `RunId`, `LineId`, `OutgoingRodAlpha`, `IncomingRodAlpha`, `FootagePosition`, `WeldType`, `WeldQuality`, `WeldQualityFailReason`, `OperatorId`, `Timestamp`

- [ ] `RollOverride` table created:
  `Id`, `OverrideId`, `RunId`, `LineId`, `RodAlpha`, `FootagePosition`, `ComponentName`, `OldValue`, `NewValue`, `Delta`, `ReasonCode`, `Notes`, `MeasuredGaugeIn`, `MeasuredWidthIn`, `PlcTagWritten`, `OperatorId`, `Timestamp`

- [ ] `DieChangeEvent` table created:
  `Id`, `DieChangeId`, `RunId`, `LineId`, `RodAlpha`, `FootagePosition`, `DiePosition`, `OldDieSizeIn`, `NewDieSizeIn`, `ReasonCode`, `LinkedOverrideId`, `SpcCheckpointRequired`, `OperatorId`, `Timestamp`

- [ ] `SpcCheckpoint` table created:
  `Id`, `CheckpointId`, `RunId`, `LineId`, `CheckpointType`, `FootagePosition`, `OperatorId`, `TriggerDescription`, `AllInSpec`, `Timestamp`

- [ ] `SpcMeasurement` table created (child of `SpcCheckpoint`):
  `Id`, `CheckpointId`, `Name`, `TargetValue`, `ActualValue`, `InSpec`, `Deviation`

- [ ] `WipRejection` table created:
  `Id`, `RejectionId`, `RunId`, `LineId`, `MaterialAlpha`, `Stage`, `FootagePosition`, `RejectionGroup`, `RejectionReason`, `MeasuredValue`, `TargetMin`, `TargetMax`, `Disposition`, `ObservationNotes`, `NewMaterialStatus`, `OperatorId`, `Timestamp`

- [ ] `CoilOutput` table created:
  `Id`, `CoilAlpha`, `RunId`, `LineId`, `OrderId`, `GrossWeightLb`, `NetWeightLb`, `FinalGaugeIn`, `FinalWidthIn`, `FootageFt`, `SkidId`, `SkidStatus`, `Status`, `GaugeInSpec`, `WidthInSpec`, `CompletedAt`, `OperatorId`

- [ ] `CoilTraceability` table created (source rod → footage range mapping):
  `Id`, `CoilAlpha`, `RodAlpha`, `FootageFrom`, `FootageTo`

- [ ] All FKs established: `SpcMeasurement.CheckpointId` → `SpcCheckpoint.CheckpointId`; `CoilTraceability.CoilAlpha` → `CoilOutput.CoilAlpha`; etc.
- [ ] Migration script created and tested
- [ ] EF Core `DbContext` updated

**Dependencies:** FW-006

---

### FW-004 · Alloy lookup table for pass schedule algorithm
**Points:** 3 · **Priority:** Critical · **Sprint:** 1

**As a** developer,
**I want** an alloy properties lookup table in the database,
**So that** the pass schedule generation algorithm can calculate die sizes, roll gaps, and route mode per alloy.

**Acceptance Criteria:**
- [ ] Table created with columns: Alloy, MaxReductionPerPass(%), SpringbackFactor, GaugeToleranceDefault, WidthToleranceDefault, SpeedRangeMinFPM, SpeedRangeMaxFPM
- [ ] Seeded with initial values for 1100, 1350, 3003, 5052, 6061
- [ ] Values are editable via an admin interface (not hardcoded)
- [ ] Edit access restricted to Process Engineering / System Admin role
- [ ] Changes to this table are audit-logged (who, when, old value, new value)

**Dependencies:** None
**Notes:** Initial values must be confirmed by Tim O. / Process Engineering before seeding.

---

---

# EPIC 2 — Pass Schedule Module (FW-E02)

**Goal:** Build the Pass Schedule management system — the highest-priority dependency in the entire project. No check-in, PLC update, or shopfloor flow can proceed without it.
**Sprint:** 2
**Blocks:** FW-E07 (Shopfloor UI), FW-E08 (PLC Integration)

---

### FW-010 · Pass schedule data model and API
**Points:** 5 · **Priority:** Critical · **Sprint:** 2

**As a** developer,
**I want** a Pass Schedule entity in the `FlatWire` microservice,
**So that** pass schedule records can be created, versioned, and queried at check-in time.

**Acceptance Criteria:**
- [ ] `PassSchedule` entity created with fields: ScheduleId, Alloy, Line (FL1/FL2/FL3), Description, Status (Draft/Active/Inactive), RouteMode (Standalone/Hybrid), TargetGauge, GaugeTolerance, TargetWidth, WidthTolerance, LineSpeedMinFPM, LineSpeedMaxFPM, CreatedBy, CreatedAt, ModifiedBy, ModifiedAt
- [ ] `PassScheduleComponent` child entity: ComponentName (DB1/DB2/FM1/FM2-8"/FM2-6"S1/FM2-6"S2/EdgeSet), IsActive (bool), ParameterValue (die size or roll gap), EdgeType (Round/Flat)
- [ ] `PassScheduleOverride` entity for run-level gap adjustments: RunId, ComponentName, OldValue, NewValue, Reason, OperatorId, Timestamp, FootagePosition
- [ ] CRUD API endpoints: GET list, GET by ID, POST create, PUT update, PATCH status
- [ ] Only Active schedules are returned by the check-in query endpoint
- [ ] Draft schedules cannot be acknowledged at check-in
- [ ] Inactive schedules are hidden from check-in but retained for history

**Dependencies:** FW-004

---

### FW-011 · Dashboard 9A — Pass Schedule List screen
**Points:** 3 · **Priority:** High · **Sprint:** 2

**As an** Operations Manager,
**I want** a searchable list of all pass schedule records,
**So that** I can find, open, or create schedules without knowing the exact ID.

**Acceptance Criteria:**
- [ ] Grid displays: Schedule ID, Description (with "In use: FW-XXXXX" chip when active on a job), Alloy badge, Line tag (FL3 shown in purple), Route (Standalone/Hybrid), Status badge (● Active / ◆ Draft / ○ Inactive), Last Modified (date + operator name), Open button (↗)
- [ ] Toolbar: live search (matches ID, description, alloy as user types), Alloy dropdown filter, Line dropdown filter, Status dropdown filter — all four apply simultaneously
- [ ] Stats strip: N total · N Active · N Draft · N Inactive — updates as filters change; active filter controls highlighted amber
- [ ] "+ New Schedule" button opens choice popup: "Enter manually" or "Generate from specs"
- [ ] "⚡ Generate from Specs" toolbar shortcut opens generation modal directly
- [ ] Clicking any row or the ↗ button opens Dashboard 9 for that record
- [ ] Empty state message shown when no records match filters
- [ ] Column headers are sortable; active sort column shows arrow indicator

**Dependencies:** FW-010

---

### FW-012 · Dashboard 9 — Pass Schedule Management screen
**Points:** 8 · **Priority:** Critical · **Sprint:** 2

**As an** Operations Manager,
**I want** to create and edit pass schedule records with full component configuration,
**So that** operators have the correct machine setup available at check-in.

**Acceptance Criteria:**
- [ ] Header: Schedule ID (auto-generated), Alloy, Line, Description, Status badge, Last Modified
- [ ] Component Configuration table: one row per component (DB1, DB2, FM1, Edge Set, FM2-8", FM2-6"S1, FM2-6"S2), with toggle (Active/Bypass/Skip), parameter input (die diameter or roll gap), edge type selector where applicable
- [ ] FM2-6"S2 cannot be set to Bypass/Skip — enforced in UI and API
- [ ] Targets section: Output Gauge + tolerance, Output Width + tolerance, Line Speed range
- [ ] Override Log panel: last 5 overrides shown (date, operator, component, old→new, reason)
- [ ] Footer actions: Generate from Specs, Copy Schedule, Deactivate, Discard Changes, Save Changes / Save as Active
- [ ] "← All schedules" back button navigates to Dashboard 9A
- [ ] Only Operations Manager / Maintenance roles can edit; operators see read-only view
- [ ] All saves are audit-logged

**Dependencies:** FW-010, FW-011

---

### FW-013 · Pass Schedule — Generate from Specs algorithm
**Points:** 8 · **Priority:** High · **Sprint:** 2

**As an** Operations Manager,
**I want** to generate a draft pass schedule by entering only alloy, rod diameter, target gauge, and target width,
**So that** new product introductions don't require manual calculation of every die size and roll gap.

**Acceptance Criteria:**
- [ ] Two-panel modal: left panel (inputs), right panel (generated draft)
- [ ] Inputs: Alloy (dropdown), Rod diameter, Target gauge, Target width, Edge type
- [ ] Alloy limits panel updates live as alloy changes (max reduction/pass, spring-back factor, default tolerances)
- [ ] Algorithm steps implemented correctly:
  1. Pre-flatten diameter: `D_pre = sqrt(4 × target_gauge × target_width / π)`
  2. Total area reduction calculation
  3. Draw pass count logic: ≤2% → both bypass; ≤1× max → DB1 only; ≤2× max → DB1+DB2; >2× max → error
  4. Die sizes: DB1 = geometric mean(rod_dia, D_pre) snapped to nearest 0.005"; DB2 = D_pre snapped to 0.005"
  5. FM1 roll gap: `target_gauge × alloy_springback_factor`
  6. FM2 requirement: if aspect_ratio > 5.5 OR alloy = 1350 → FM2 activated; route = Hybrid FL3
  7. FM2 roll gaps: 8" = gauge × 1.06; 6"S1 = gauge × 1.02; 6"S2 = gauge × spring-back
- [ ] Calculation summary chips shown: Pre-flatten ⌀, Area reduction %, Draw passes, Aspect ratio
- [ ] Warnings shown for: aspect ratio > 5.5, 1350 alloy (welding wire precision mode), aspect ratio > 10, die snapping, gauge below machine minimum
- [ ] Error shown (Apply still enabled for manual review) when total reduction > 2× alloy max
- [ ] Apply populates Dashboard 9 form with generated values highlighted in purple; status set to Draft
- [ ] Draft cannot be used at check-in until saved as Active by Operations Manager
- [ ] PLC tags are never pushed during generation — only at check-in acknowledgment

**Dependencies:** FW-010, FW-004

---

### FW-014 · Pass Schedule — override logging
**Points:** 3 · **Priority:** High · **Sprint:** 2

**As an** Operations Manager,
**I want** every parameter change to an active pass schedule to be logged automatically,
**So that** there is a full audit trail of who changed what and why.

**Acceptance Criteria:**
- [ ] Every field change after status = Active is written to `PassScheduleOverrideLog`
- [ ] Log record captures: ParameterChanged, OldValue, NewValue, OperatorId, OperatorName, ReasonCode, FreeTextNote, Timestamp
- [ ] Override log is visible on Dashboard 9 (last 5 entries) and in a full history tab
- [ ] Run-level overrides (Dashboard 11 Roll Adjust) are logged against the run, not the schedule record — pass schedule values remain unchanged
- [ ] Unauthorized edit attempt (non-Manager role) returns a 403 and is logged

**Dependencies:** FW-010, FW-012

---

---

# EPIC 3 — Rod Receiving (FW-E03)

**Goal:** Build the new Rod Receiving module — a workflow distinct from coil receiving with its own alpha format, validations, and suspension logic.
**Sprint:** 2
**Blocks:** FW-E07 (Shopfloor check-in requires valid rod alphas)

---

### FW-020 · R-series alpha generation
**Points:** 3 · **Priority:** Critical · **Sprint:** 2

**As a** receiving operator,
**I want** the system to assign a unique R-series alpha (R00001–R99999) to each received rod lot,
**So that** rods are traceable through the entire manufacturing process.

**Acceptance Criteria:**
- [ ] Format: `R` + 5-digit zero-padded sequence (e.g., `R00001`)
- [ ] Sequence increments by 1 per received rod per lot number; no gaps allowed
- [ ] Next sequence number is generated in a concurrency-safe manner (database sequence or row lock)
- [ ] Historical R-series alphas are retained in the coils table permanently
- [ ] Width field is blank for rod entries; surface finish, OD/ID are also blank
- [ ] Gauge is populated from the PO

**Dependencies:** FW-001

---

### FW-021 · Rod receiving screen — web UI
**Points:** 5 · **Priority:** High · **Sprint:** 2

**As a** receiving operator,
**I want** a dedicated rod receiving screen,
**So that** I can receive aluminum rod bundles from vendors and register them in the system.

**Acceptance Criteria:**
- [ ] Operator enters PO number; system auto-populates: alloy, diameter, vendor, expected gross weight
- [ ] Operator enters: actual gross weight (from scale), net weight
- [ ] Operator enters: payoff position (Payoff 1 or Payoff 2) — for initial placement tracking
- [ ] System validates gross weight within tolerance of vendor/PO weight; on failure → suspend material
- [ ] System checks rod chemistry documentation is present; on failure → suspend material
- [ ] Width field is not shown (not applicable to rod)
- [ ] On successful receipt: R-series alpha generated, coils table entry created, rod moves to storage area status
- [ ] "Suspend" action available to override and manually suspend before save
- [ ] Screen is accessible without Angular frontend changes in Phase 1 (web-only access)

**Dependencies:** FW-020

---

### FW-022 · Suspend coil logic update for rods
**Points:** 2 · **Priority:** High · **Sprint:** 2

**As a** developer,
**I want** the existing Suspend Coil logic to apply to rod entries correctly,
**So that** rods can be suspended without triggering width-related validation rules that don't apply to them.

**Acceptance Criteria:**
- [ ] All existing suspend rules apply to rods except width-related rules
- [ ] Width validation is skipped when `MaterialType = Rod`
- [ ] Suspended rod appears in WIP Held queue with appropriate status
- [ ] Supervisor can review and release a suspended rod

**Dependencies:** FW-020, FW-021

---

---

# EPIC 4 — Scheduling System (FW-E04)

**Goal:** Extend the scheduling system to support FL1, FL2, FL3 as schedulable machines, add the Flattening Lines tab, and apply the `F` operation letter and `INFLAT` status.
**Sprint:** 3

---

### FW-030 · Flattening Lines tab in scheduling UI
**Points:** 3 · **Priority:** High · **Sprint:** 3

**As a** scheduling operator,
**I want** a Flattening Lines tab in the scheduling screen alongside existing tabs,
**So that** I can schedule jobs on FL1, FL2, and FL3 the same way I schedule other machines.

**Acceptance Criteria:**
- [ ] "Flattening Lines" tab added alongside existing machine tabs
- [ ] Tab lists FL1, FL2, FL3 with their current scheduled jobs
- [ ] FL3 (hybrid) is represented as a single schedulable entity that simultaneously blocks FL1 and FL2 when scheduled (see OQ-10 / OQ-45 — confirm with Tim O. before build)
- [ ] Scheduling an FL3 job shows both FL1 and FL2 as unavailable for the same time slot
- [ ] Column headers use renamed fields (Coil/BundleNo, Slit/FlatWidth, etc.)

**Dependencies:** FW-001, FW-002, FW-003
**Open Questions:** OQ-10 (FL3 scheduling representation), OQ-45 (FL1/FL2 simultaneous independent operation) must be resolved before implementation.

---

### FW-031 · Operation letter F for flattening
**Points:** 2 · **Priority:** High · **Sprint:** 3

**As a** scheduling operator,
**I want** the letter `F` used as the operation identifier for flattening,
**So that** flat wire operations are consistently distinguishable from slitting (`S`) and milling (`M`).

**Acceptance Criteria:**
- [ ] `F` is used in `OpLetter`, `PrevOpLetter`, `RemainingOps`, `RootRemainingOps` for all FL1/FL2/FL3 operations
- [ ] Existing scheduling algorithm and reporting treats `F` correctly without breaking existing letter codes
- [ ] Scheduling grid displays `F` in the operation column for flat wire jobs

**Dependencies:** FW-003

---

---

# EPIC 5 — Planning System (FW-E05)

**Goal:** Extend the planning screen to support flat wire orders — weight-based allocation, alpha generation at planning time, tabular allocation grid, and the assign-as-is stock option.
**Sprint:** 3

---

### FW-040 · Planning screen — Flat Wire filter dropdown
**Points:** 2 · **Priority:** High · **Sprint:** 3

**As a** planner,
**I want** a filter dropdown in the planning screen to show only flat wire orders,
**So that** I can focus my view without scrolling through all order types.

**Acceptance Criteria:**
- [ ] Filter dropdown added in the gray or blue header area of the planning screen
- [ ] Options: `All` | `Regular` | `Back2Back` | `Flatwire`
- [ ] Default: `All`
- [ ] Selecting `Flatwire` shows only orders with the Flat Wire flag set
- [ ] Column headers update: "CoilNo" → "Coil/Bundle No.", "Gauge" → "Gauge/Diameter" when Flatwire is selected

**Dependencies:** FW-001

---

### FW-041 · Planning — weight-based material drop with alpha generation
**Points:** 8 · **Priority:** Critical · **Sprint:** 3

**As a** planner,
**I want** to assign material to a flat wire order by entering weight only,
**So that** the system automatically calculates stops, splits multi-capacity orders, and generates alphas at planning time — without me needing to compute cuts or stops manually.

**Acceptance Criteria:**
- [ ] Material Drop pop-up: "Number of Cuts" and "Number of Stops" fields removed for flat wire orders
- [ ] "Weight" field added — planner enters total weight to assign
- [ ] System computes number of stops automatically based on weight and max coil weight (1,100 lb TKUP-2 equipment limit — customer-specific limit may be lower, defined in orders/quotes application)
- [ ] System generates alphas at planning time for each stop (not dynamically at execution)
- [ ] Orders exceeding single-rod/spool capacity are split into multiple stops; each stop has its own alpha
- [ ] Last stop of a multi-stop order may contain multiple alphas
- [ ] Remainder alpha generated for unused material automatically returned to the warehouse

**Dependencies:** FW-040
**Open Questions:** OQ-35 (metallic yield per route) and OQ-36 (footage-to-weight conversion) must be resolved — these drive how weight is converted to stops.

---

### FW-042 · Planning — assign-as-is stock option
**Points:** 3 · **Priority:** High · **Sprint:** 3

**As a** planner,
**I want** an "Assign as-is" option when remaining weight exists after order fulfilment,
**So that** I can return unused rod or flat wire to stock inventory in one action.

**Acceptance Criteria:**
- [ ] "Assign as-is" checkbox shown only when remaining weight exists after order fulfilment
- [ ] Checking it generates a remainder alpha for the unused weight and assigns it to stock
- [ ] Three confirmed allocation scenarios all work:
  1. Entire spool → single order
  2. Partial spool → order + remaining to stock
  3. Single spool → multiple orders
- [ ] Remainder alpha is traceable to the source rod alpha

**Dependencies:** FW-041

---

### FW-043 · Planning — tabular allocation grid (replaces pattern picture)
**Points:** 3 · **Priority:** High · **Sprint:** 3

**As a** planner,
**I want** a tabular grid showing Order → Spool → Weight allocation,
**So that** I can clearly see how material is divided across stops and orders.

**Acceptance Criteria:**
- [ ] Rectangular pattern picture removed from the planning screen for flat wire orders
- [ ] Replacement tabular grid shows: Order, Spool/Alpha reference, Weight per stop, Remaining weight disposition (to order or stock)
- [ ] Grid updates in real-time as weight is entered and stops are computed
- [ ] Grid is read-only after planning is confirmed

**Dependencies:** FW-041

---

---

# EPIC 6 — .NET Web Application Changes (FW-E06)

**Goal:** Update Orders, Quotes, IQR, Item Template, Alloys, and Vendor screens to support flat wire as a product type throughout the commercial and configuration workflow.
**Sprint:** 3

---

### FW-050 · Orders & Quotes — Flat Wire flag and fields
**Points:** 3 · **Priority:** High · **Sprint:** 3

**As a** sales operator,
**I want** to mark an order as Flat Wire and enter Bundle Width and Edge Type,
**So that** flat wire-specific requirements are captured at order entry.

**Acceptance Criteria:**
- [ ] "Flat Wire" checkbox added to Orders screen
- [ ] When checked: mandatory "Bundle Width" field (Min/Max range) is shown
- [ ] When checked: "Edge Type" dropdown shown — options: `Round Edge` | `Flat Edge`
- [ ] Finish field is locked (read-only) when Flat Wire is selected
- [ ] Same changes applied to Quotes screen
- [ ] Pricing auto-population method to be confirmed (OQ-2) — placeholder for now

**Dependencies:** None

---

### FW-051 · Search Customers — Flat Wire type and color coding
**Points:** 1 · **Priority:** Medium · **Sprint:** 3

**As a** sales operator,
**I want** to identify flat wire customers visually in the Search Customers screen,
**So that** I can quickly distinguish them from standard coil customers.

**Acceptance Criteria:**
- [ ] "Type" dropdown updated to include "Flat Wire" option
- [ ] Flat wire customer rows are highlighted pink (consistent with existing: green = B2B)

**Dependencies:** FW-050

---

### FW-052 · IQR — Flat Wire flag, Bundle Width, Edge Type
**Points:** 3 · **Priority:** High · **Sprint:** 3

**As a** technical/sales operator,
**I want** flat wire attributes captured in the IQR,
**So that** the item template is correctly configured for the flat wire production route.

**Acceptance Criteria:**
- [ ] "Flat Wire" checkbox added to IQR / Item section
- [ ] Bundle Width field (Min/Max) added — mandatory when Flat Wire is selected
- [ ] Edge Type dropdown added (`Round Edge` | `Flat Edge`)
- [ ] When Flat Wire is selected: "Edge" critical attribute auto-set to "5 - Edge not a consideration"
- [ ] Only flat wire-relevant specifications shown when Flat Wire is selected

**Dependencies:** FW-050

---

### FW-053 · Item Template — Type and Shape columns
**Points:** 3 · **Priority:** High · **Sprint:** 3

**As a** production planner,
**I want** Type and Shape columns in the Item Template process steps,
**So that** multi-stage flat wire routes (Rod → Round Wire → Flat Wire) have their input/output types explicitly defined.

**Acceptance Criteria:**
- [ ] Two new columns added to Item Template process creation: `Type` and `Shape`
- [ ] Example routes supported:
  - Rod (Round) → FLATTEN → Flat Wire
  - Rod (Round) → DRAW → Round Wire → FLATTEN → Flat Wire
  - Rod → DRAW → Round Wire → FLATTEN → Flat Wire → ANNEAL → FLATTEN → Flat Wire (Final)
- [ ] Auto-populate vendors based on manufacturing alloy and Vendor O Gauges

**Dependencies:** FW-052

---

### FW-054 · Alloys — Material Type across Properties, Reduction Rules, Vendor O Gauge
**Points:** 5 · **Priority:** High · **Sprint:** 3

**As a** technical operator,
**I want** a Material Type dropdown in Alloys module sub-sections,
**So that** coil-specific rules and rod/wire-specific rules are managed separately.

**Acceptance Criteria:**
- [ ] Properties tab: Material Type dropdown added (values: Coils, Flat Wire, etc.)
- [ ] Reduction Rules tab: Material Type dropdown added; view splits into "Coils – Reduction Rules" and "Rod/Wire – Reduction Rules"
- [ ] Vendor O Gauge sub-section: same Material Type dropdown; split view "Coils – Vendor O Gauges" and "Rod/Wire – Vendor O Gauges"
- [ ] New anneal cycle entry added for flat wire
- [ ] Gauge CPK Report: filter dropdown added — `Strip` | `Flat Wire` | `All`

**Dependencies:** None

---

### FW-055 · Vendor Maintenance — Flat Wire checkbox
**Points:** 1 · **Priority:** High · **Sprint:** 3

**As a** purchasing operator,
**I want** a Flat Wire checkbox in Vendor Maintenance,
**So that** rod/wire suppliers are identified and filterable from coil suppliers.

**Acceptance Criteria:**
- [ ] "Flat Wire" checkbox added between existing Reroll and Scrap checkboxes
- [ ] Flat Wire checkbox filters vendor results in Order / IQR vendor selection

**Dependencies:** None

---

---

# EPIC 7 — Shopfloor Flat Wire UI (FW-E07)

**Goal:** Build all 13 shopfloor dashboards for the flat wire mill — one shared Angular application for FL1 and FL2 operators.
**Sprint:** 4
**Key Design Rules:** One shared UI for FL1/FL2; generic labels ("Incoming Bundle Information"); digital traveler only — no printing; "flat wire" terminology throughout (never "strip").

---

### FW-060 · Dashboard 1 — Line Status Overview
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As a** supervisor,
**I want** a persistent master board showing all three lines in real-time,
**So that** I can monitor FL1, FL2, and FL3 status without walking the floor.

**Acceptance Criteria:**
- [ ] Three line panels: FL1, FL2, FL3 — each shows: Status (Running/Idle/Setup/Offline/Fault), current Order, Alpha, Alloy, Route, Speed (FPM), Gauge, Width, Payoff 1 weight (with % bar), Payoff 2 status, Run Time
- [ ] Alert panel below with rules: Payoff 1 < 3,000 lb → Warning; Gauge outside tolerance → Warning; PLC component fault → Critical; Active WIP rejection → Warning; Payoff 2 not loaded when Payoff 1 < 2,000 lb → Critical
- [ ] Data refreshes every ~5 seconds via SignalR
- [ ] FL2 gauge/width fields blank when FL2 is idle (no live feed in standalone non-active state)

**Dependencies:** FW-002, FW-003, FW-080 (SignalR hub)

---

### FW-061 · Dashboard 2 — Rod Check-in & Pre-Run Setup (FL1/FL3)
**Points:** 8 · **Priority:** Critical · **Sprint:** 4

**As an** FL1 operator,
**I want** a guided check-in screen for loading a rod onto the VPS payoff,
**So that** I can validate material, complete visual inspection, acknowledge the pass schedule, and push PLC tags — all in one flow.

**Acceptance Criteria:**
- [ ] Fields: Rod Number (validates against R-series in coils table), Alloy (auto from rod), Diameter, Gross Weight, Net Weight, Payoff Position (Payoff 1 or Payoff 2)
- [ ] Visual Inspection section: Oxidation / Surface Defects / Water Stains — each Pass/Fail; Observation text field; any Fail routes directly to Dashboard 8 (WIP Rejection)
- [ ] Pass Schedule displayed read-only: component table (Component, Status [Active/Bypass], Setting [die size or roll gap])
- [ ] Pre-Run SPC: incoming rod diameter measurement field (mandatory before acknowledgment)
- [ ] "Acknowledge Pass Schedule & Begin Check-in" button: validates all fields → records inspection → pushes PLC tags → starts run timer → **returns to Dashboard 2A** to stage the next rod (`FR-079a`, revised 1 Aug 2026; was Dashboard 3, which stays reachable from the app bar and Line Status — client confirmation pending, **Q84**)
- [ ] PLC tags are only pushed after explicit acknowledgment — no automatic push
- [ ] Rod status updated to `INFLAT` on acknowledgment
- [ ] Pass schedule selection: system loads the schedule linked to the active job; OQ-51 (selection mechanism) must be resolved before this story is built

**Dependencies:** FW-010, FW-020, FW-080, FW-002
**Open Questions:** OQ-51 (pass schedule selection at check-in), OQ-52 (FL3 hybrid — one or two schedules)

---

### FW-062 · Dashboard 3 — Active Run Monitor (FL1/FL3)
**Points:** 8 · **Priority:** Critical · **Sprint:** 4

**As an** FL1 operator,
**I want** a real-time run monitor displayed continuously during production,
**So that** I can see live gauge/width traces, payoff status, and take quick actions without navigating away.

**Acceptance Criteria:**
- [ ] Header: Order, Alpha, Alloy, Target Gauge, Target Width
- [ ] Real-time Gauge Trace chart: streaming Chart.js line chart; green within tolerance, red outside; vertical weld-point marker with rod alpha label; auto-prompt WIP checkpoint after configurable N consecutive out-of-spec readings
- [ ] Real-time Width Trace chart: same rules as gauge trace
- [ ] Machine Status panel: Speed (FPM), Footage counter, DB1/DB2 status + die sizes, FM1 status
- [ ] Payoff weight bars: colour-coded (green >50%, amber 25–50%, red <25%, red flashing <10%); "WELD SOON" alert shown at <25%
- [ ] Action buttons:
  - *(Log Weld Event removed 1 Aug 2026 — Dashboard 4 retired; the weld is captured at DB2A)*
  - Die Change → Die Change screen (DC)
  - Roll Adjust → Dashboard 11 (FL3 only)
  - SPC Checkpoint → Dashboard 6
  - Pause Run → Pause dialog (see FW-071)
  - WIP Reject → Dashboard 8
  - Complete Run → run completion dialog
  - Check Out Rod → Dashboard 12 Mode A (only when footage = 0)
- [ ] FL1 bar: 7 buttons (no Roll Adjust); FL3 bar: 8 buttons (Roll Adjust included)

**Dependencies:** FW-061, FW-080, FW-081, FW-082

---

### FW-063 · Weld Event capture — **DB2A dialog** *(Dashboard 4 retired 1 Aug 2026)*
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** FL1 operator,
**I want** to log a weld event when I join a new rod to the running payoff,
**So that** the system maintains continuous traceability through the weld point.

**Acceptance Criteria:**
- [ ] Outgoing rod alpha and weld point footage auto-populated from active run context
- [ ] Incoming rod alpha: operator scans or enters R-series of Payoff 2 rod
- [ ] Weld type selection: Induction Weld (rod-to-rod) or Laser Weld (flat-to-flat)
- [ ] Weld quality: Pass or Fail; Fail requires reason text
- [ ] Operator field (from login); timestamp auto-stamped
- [ ] On confirmation: weld join event written (footage position, both alphas, weld type, quality, operator, timestamp); all subsequent output footage attributed to incoming rod alpha; traceability chain updated; run monitor returns to Dashboard 3
- [ ] Dashboard 1 alert dismissed when weld is successfully confirmed

**Dependencies:** FW-062

---

### FW-064 · Dashboard 5 — FL2 Spool Check-in
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** FL2 operator,
**I want** to check in an incoming spool onto the TPO,
**So that** I can start FL2 processing with the correct pass schedule applied and the FL1 gauge history visible.

**Acceptance Criteria:**
- [ ] Fields: Spool/Alpha identifier, Source Rods (auto-linked from FL1 run), Alloy, Temper, Gauge (operator-entered measured value), Width, Gross Weight, Net Weight
- [ ] Historical Gauge Profile chart displayed: Chart.js profile of FL1 gauge trace for this spool; weld point markers shown on the chart
- [ ] Pass Schedule (FL2-specific components): 8" Roller, 6"S1, Edger, 6"S2, Edger — shown read-only
- [ ] "Acknowledge Pass Schedule & Begin Check-in" — same gate as FL1 check-in; pushes FL2 PLC tags
- [ ] Visual inspection NOT required (spool was already inspected at FL1)
- [ ] Spool status updated to `INFLAT` on acknowledgment
- [ ] Screen transitions to Dashboard 3 (FL2 Active Run Monitor variant)

**Dependencies:** FW-061, FW-010

---

### FW-124 · Dashboard 5A — FL2 Spool Queue
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** FL2 operator,
**I want** to see the spools I can run and the ones belonging to the order in front of me,
**So that** I can pick the right spool without hunting the floor or guessing from a label.

*Added 2 Aug 2026. FL1 has DB2A's staging queue; FL2 has no equivalent because `PCI002` excludes it from staging, so the FL2 operator had no view of waiting material at all. `FR-090` says scan the FL1 label and **Q57** records the client saying the operator "selects it by spool number" — both stand, only the scan had a screen. This is also the first thing named "the spool queue", a phrase `FR-326` and `TC-389` use with nothing behind it.*

**Acceptance Criteria:**
- [ ] On opening, lists **all spools available for processing irrespective of order** — no scan required — with a spool count / ready count / total weight rollup
- [ ] Columns: Spool, Order, Source (FL1 run + source rod alphas), Gauge × Width, Net weight, Origin, Status, action
- [ ] **Gauge and width read from the source FL1 run, not `Spool.GaugeIn`/`WidthIn`** — those are set at check-in and are null for every row here
- [ ] **Source rods read from `CoilTraceability`/`WeldEvent`** — `Spool` carries only two single-valued rod FKs and a welded spool has more than one source rod
- [ ] Entering a spool identifier resolves its order **server-side in one call**, populating the order bar and narrowing the list **together**; the scanned spool stays marked; **Show all** restores the full list
- [ ] Resolves on the scanner's terminating Enter and on a ~250 ms debounce when typed — **no submit button**
- [ ] An unresolved identifier marks the field and **leaves the displayed list unchanged**
- [ ] A spool with a null `OrderNo` is a **`200` single-row result, not a `404`** — and is still checkin-able
- [ ] Check-in offered only for `RECEIVED`/`STAGED`; `HOLD` marked and actionless; `INFLAT`/`COMPLETE`/`SCRAP` listed without action
- [ ] Hybrid-origin spools visibly marked (OI-47)
- [ ] Read-only screen — writes nothing; hands over to Dashboard 5
- [ ] No age or location column: `Spool` has no creation timestamp and `Spool.Location` has no writer
- [ ] Reachable from DB1's nav strip, More Options, the shift-summary spool tile, and DB5

**Dependencies:** FW-064 (hands over to it), `GET /spools`
**Blocked by:** **OQ-57** (which statuses count as available), **OQ-15/OI-02** (identifier and format), **OI-06** (two status vocabularies), and — critically — confirmation that **`Spool.OrderNo` is populated from planning**, without which the order cannot be resolved at all

---

### FW-065 · Dashboard 6 — SPC Checkpoint Entry
**Points:** 3 · **Priority:** High · **Sprint:** 4

**As an** operator,
**I want** to record manual SPC measurements at defined checkpoints,
**So that** dimensional conformance is captured at every critical stage.

**Acceptance Criteria:**
- [ ] Checkpoint type: Pre-Run / Post Die Change / Manual Spot Check (radio selection)
- [ ] Trigger description auto-populated (e.g., "DB2 die changed from 0.310" → 0.308"")
- [ ] Measurements table: Measurement name, Target, Actual (editable), Status (✓ In Spec / ✗ Out of Spec) — rows vary by checkpoint type:
  - Pre-Run: incoming rod diameter
  - Post Die Change: wire diameter, FM1 gauge, FM1 width
  - Manual Spot Check: FM1 gauge, FM1 width
  - Post-Run (Dashboard 7): final gauge, final width
- [ ] Operator field required
- [ ] Two submit actions: "Submit — Continue Run" and "Submit — Suspend Material"
- [ ] Out-of-spec measurement auto-highlights row in red; operator chooses disposition
- [ ] Suspension triggers Dashboard 8 (WIP Rejection)
- [ ] Measurements entered here are written to the SPC checkpoint log; no separate SPC entry needed for same footage position when triggered from Roll Adjust

**Dependencies:** FW-062

---

### FW-066 · Dashboard 7 — Output Coil Completion & Label
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** FL2 operator,
**I want** to confirm a completed coreless coil, record final SPC, generate an alpha, and manage skid tracking,
**So that** every finished coil is fully identified, traceable, and ready for packing.

**Acceptance Criteria:**
- [ ] Coil details: New Alpha (system-generated, e.g., FW-00421-C01), Alloy, Gauge (avg measured), Width, Temper, Footage
- [ ] Net Weight: calculated from footage × footage-to-weight conversion factor (OQ-36 must be resolved)
- [ ] Source Traceability table: Rod Alpha | Footage From | Footage To — one row per source rod through weld chain
- [ ] Final SPC: in-spec / out-of-spec summary for gauge and width
- [ ] Skid Tracking: current skid ID, "Coil 1 of 2 — skid open" or "Coil 2 of 2 — close skid and print skid label" selection
- [ ] "Print Coil Label" action (physical coil label — NOT a traveler; traveler printing is disabled for flat wire)
- [ ] Coil label fields: Alpha, Alloy, Gauge/Diameter, Width, Temper, Gross/Net Weight, Footage, Lot Number, Source Rod Alphas
- [ ] On second coil: skid is closed, skid label is printed, skid appears in packing queue
- [ ] Each skid holds exactly 2 coreless coils (enforced)

**Dependencies:** FW-064, FW-065

---

### FW-067 · Dashboard 8 — WIP Rejection Screen
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** operator,
**I want** to log a WIP rejection when material fails at any stage,
**So that** suspect material is formally held or scrapped and supervisor is notified.

**Acceptance Criteria:**
- [ ] Context auto-populated: Material alpha, Stage, Footage, Timestamp
- [ ] Rejection Reason: Group dropdown (Surface Quality, Dimensional, Weld Quality, Material, Process) + Reason dropdown (filtered by group)
- [ ] Rejection details: Measured value, Target range, Deviation
- [ ] Disposition: Suspend (→ HOLD status + supervisor notification) / Scrap (→ SCRAP status + scrap module) / Rework (→ REWORK flag + return stage selection)
- [ ] Observation text field + Operator field required
- [ ] On submit: alpha status updated; WIP Held queue updated; Dashboard 1 alert shown; rejection record written
- [ ] Shannon R. to confirm final list of rejection reason groups and reasons before build (OQ-8)

**Dependencies:** FW-062, FW-003

---

### FW-068 · Dashboard 9 & 9A — Pass Schedule screens (Shopfloor integration)
**Points:** 2 · **Priority:** High · **Sprint:** 4

**As an** Operations Manager using the shopfloor app,
**I want** to navigate to Pass Schedule Management from the shopfloor UI,
**So that** I don't have to switch to a separate application to create or modify a schedule.

**Acceptance Criteria:**
- [ ] Dashboard 9 and 9A are accessible from the shopfloor navigation (role-gated: Operations Manager only)
- [ ] Navigation from Dashboard 9A back to the last screen works correctly
- [ ] Pass schedule screens function identically to web UI versions
- [ ] Floor operators see pass schedule as read-only from Dashboard 2 / Dashboard 5

**Dependencies:** FW-011, FW-012, FW-013

---

### FW-069 · Dashboard 10 — Supervisor Shift Summary
**Points:** 5 · **Priority:** Medium · **Sprint:** 4

**As a** supervisor,
**I want** an end-of-shift summary showing throughput, quality, weld events, and material status,
**So that** I can review the shift's performance without querying individual reports.

**Acceptance Criteria:**
- [ ] Throughput: Orders Run, Footage, Weight, Coils Out, Skids
- [ ] Quality: SPC Pass Rate %, WIP Rejections count + reasons breakdown, Suspended Material
- [ ] Line Utilisation: FL1/FL2/FL3 utilisation %; Total Downtime minutes; Downtime reason breakdown (Equipment/Material/Quality/Operational/Safety)
- [ ] Weld Events: per-line weld count; each weld listed (Rod Alpha → Rod Alpha, footage, pass/fail)
- [ ] Material Status: Rod in Storage count, Spools on Floor, Coils in Packing, WIP Held, Scrapped Today
- [ ] Export Shift Report action; Print action
- [ ] Pause events roll up into downtime correctly

**Dependencies:** FW-062, FW-063, FW-065, FW-067

---

### FW-070 · Dashboard 11 — Roll Adjust
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** FL1/FL2 operator,
**I want** to log and apply a mid-run roll gap override,
**So that** I can correct gauge or width drift without modifying the underlying pass schedule record.

**Acceptance Criteria:**
- [ ] Context strip: Spool/Alpha, Pass Schedule ID (read-only), Footage at adjustment, Gauge/Width targets with tolerances, Override type always shown as "Run-level"
- [ ] Roll gap adjustment table: Component, Scheduled gap (read-only), Current gap (read-only), New gap (editable), Delta (auto-calculated, colour-coded green=tighten/red=open)
- [ ] Bypassed components shown greyed-out, not editable
- [ ] Measurement trigger panel: Measured gauge + status, Measured width + status — required fields
- [ ] Reason code: chips (Gauge drift high/low, Width drift, SPC flag, Roll wear, Post-weld correction, Operator discretion) — one required before Apply is enabled
- [ ] Recent roll adjustments panel: last 3 adjustments for the active pass schedule
- [ ] On Apply: override record written against run + footage (NOT pass schedule); PLC tag updated; Dashboard 3 reflects updated gap; measurements written to SPC checkpoint log
- [ ] If no gap changes (all deltas = 0): Apply button relabelled "No changes — return to run"; no record written
- [ ] Only FL1/FL2 operators can apply; Operations Manager only can revert

**Dependencies:** FW-062, FW-080

---

### FW-071 · Pause Run dialog (within Dashboard 3)
**Points:** 3 · **Priority:** High · **Sprint:** 4

**As an** FL1 operator,
**I want** to pause a run with a mandatory reason code,
**So that** downtime is categorized and visible to the supervisor on Dashboard 1.

**Acceptance Criteria:**
- [ ] Pause confirmation modal shows: Current Alpha, Footage, timestamp
- [ ] Reason categories and codes:
  - Equipment / Mechanical: Die change (mid-run), Roll adjustment, Lubrication/coolant, Draw box inspection, Component inspection
  - Material Handling: Payoff 2 loading/weld prep, Downstream blockage
  - Quality / Measurement: Gauge/width investigation, Manual SPC, Surface inspection
  - Operational: Operator break, Shift changeover, Awaiting supervisor instruction
  - Safety: Safety observation
  - Other (free text required)
- [ ] One reason must be selected before Confirm Pause is enabled
- [ ] On pause: run timer paused; footage counter frozen; reason logged; PLC set to idle; Dashboard 1 updated RUNNING → PAUSED with reason
- [ ] Resume dialog requires: Was issue resolved? (Yes → resume / No → WIP Rejection / No → continue pause / No → Rod Checkout Mode B); optional activity notes field
- [ ] Pause duration tracked separately from productive run time; feeds Dashboard 10 downtime totals

**Dependencies:** FW-062

---

### FW-072 · Dashboard 12 — Rod Checkout (Mode A and Mode B)
**Points:** 5 · **Priority:** High · **Sprint:** 4

**As an** FL1/FL3 operator,
**I want** to formally check out a rod that must be removed before run completion,
**So that** material traceability is preserved and the payoff position is correctly reset.

**Acceptance Criteria:**
**Mode A — Pre-Run (footage = 0):**
- [ ] Accessible from Dashboard 2 footer (before acknowledgment) and Dashboard 3 action bar (after acknowledgment, footage = 0)
- [ ] Displays: rod alpha, payoff position, check-in time; "No footage produced" summary
- [ ] Checkout reason required (Wrong rod/mis-scan, Order cancelled/deferred, Failed re-inspection, Relocated to different line, Other)
- [ ] Rod disposition required: Return to floor storage (→ STAGED) or Return to warehouse (→ RECEIVED)
- [ ] On confirm: pass schedule acknowledgment voided; PLC tags cleared; rod status updated; Dashboard 1 → IDLE

**Mode B — Mid-Run (footage > 0):**
- [ ] Accessible ONLY via Pause Run dialog → "No — check out rod" option; "Check Out Rod" button on Dashboard 3 disabled when footage > 0
- [ ] Footage at checkout pre-populated from footage counter
- [ ] Checkout reason required (Equipment failure, Quality hold, Order quantity reached, Shift deferral, Other)
- [ ] Rod disposition: Hold (partial rod, re-usable) / Scrap / Defer (continue later on this line); Remaining weight estimate (optional)
- [ ] In-process material disposition (required): Hold (supervisor review) / Scrap / Accept as partial run → generate spool alpha
- [ ] On confirm: partial run record closed; footage saved; rod and material statuses updated; PLC tags cleared; Dashboard 1 → IDLE; returns to ready-for-check-in state
- [ ] Approval authority for mid-run checkout must be confirmed (OQ-48)

**Dependencies:** FW-061, FW-071
**Open Questions:** OQ-47 (partial-rod re-check-in), OQ-48 (checkout authorisation level), OQ-49 (PLC tag behaviour on checkout), OQ-50 (partial-run material disposition authority)

---

### FW-073 · Die Change screen (DC)
**Points:** 3 · **Priority:** High · **Sprint:** 4

**As an** FL1/FL3 operator,
**I want** to log a drawing die change mid-run,
**So that** die changes are tracked with reason codes and a post-die-change SPC checkpoint is automatically triggered.

**Acceptance Criteria:**
- [ ] Context: active rod alpha, current footage, active die sizes for DB1 and DB2
- [ ] Fields: Which die (DB1 or DB2), Old die size (auto), New die size (operator entry), Reason (Die wear, Gauge drift, Breakage, Scheduled change, Size change for product)
- [ ] On confirm: die change event logged against run and footage; Dashboard 6 (SPC Checkpoint) auto-opened in "Post Die Change" mode with DB1/DB2 measurements pre-populated
- [ ] Die change contributes to downtime if the line was paused for the change
- [ ] Die history visible in Tooling Inventory tab of the Machines application

**Dependencies:** FW-062, FW-065

---

---

# EPIC 8 — Real-Time Data & PLC Integration (FW-E08)

**Goal:** Wire up SignalR for live gauge/width traces, payoff weight, line speed, and PLC tag push/clear at check-in and checkout.
**Sprint:** 5

---

### FW-080 · SignalR hub for flat wire live data
**Points:** 5 · **Priority:** Critical · **Sprint:** 5

**As a** developer,
**I want** a SignalR hub streaming live AGC and PLC tag data to the shopfloor UI,
**So that** gauge trace, width trace, line speed, and payoff weight update in real-time on Dashboards 1 and 3.

**Acceptance Criteria:**
- [ ] `FlatWireHub` SignalR hub created in `FlatWire.API`
- [ ] Hub broadcasts per-line groups: FL1Data, FL2Data, FL3Data
- [ ] Events published: GaugeReading(lineId, value, timestamp), WidthReading, SpeedFPM, PayoffWeight(position, value), ComponentStatus
- [ ] OPCConnection service extended to read FL1/FL2/FL3 PLC tags and publish to the hub
- [ ] Clients subscribe to their line group on Dashboard 1 and Dashboard 3 load
- [ ] Hub is robust to client reconnection (standard SignalR retry policy)
- [ ] FL2 in standalone mode does not broadcast live gauge (historical only) — hub sends `null` for FL2 live readings

**Dependencies:** FW-003

---

### FW-081 · Live gauge trace Chart.js component
**Points:** 3 · **Priority:** High · **Sprint:** 5

**As an** FL1 operator,
**I want** a streaming gauge trace chart on Dashboard 3,
**So that** I can see gauge and width in real-time and spot deviations instantly.

**Acceptance Criteria:**
- [ ] Chart.js streaming chart with configurable time window (e.g., last 500 readings)
- [ ] Target line drawn as dashed horizontal reference
- [ ] Upper and lower tolerance lines drawn
- [ ] Data points coloured green (in-spec) or red (out-of-spec) per reading
- [ ] Weld event markers: vertical line with rod alpha label at the footage position of the weld
- [ ] After N consecutive out-of-spec readings (configurable), auto-prompt for SPC Checkpoint

**Dependencies:** FW-080

---

### FW-082 · PLC tag push on check-in acknowledgment
**Points:** 5 · **Priority:** Critical · **Sprint:** 5

**As a** developer,
**I want** pass schedule parameters pushed to the PLC as OPC tags when the operator acknowledges a check-in,
**So that** the machine is configured correctly and automatically — without the operator touching the PLC directly.

**Acceptance Criteria:**
- [ ] On Dashboard 2 / Dashboard 5 "Acknowledge" action: API reads the active pass schedule and writes OPC tags for FL1 or FL2 PLC
- [ ] Tags written: component active/bypass state, die sizes (DB1, DB2), FM1 roll gap, FM2 roll gaps (8", 6"S1, 6"S2), edge type, speed targets
- [ ] PLC tag write is transactional: if any tag write fails, the entire check-in is rolled back and the operator is notified
- [ ] Tags are written to the specific payoff position (1 or 2) that the operator selected
- [ ] On rod checkout (Dashboard 12): PLC tags for the checked-out payoff position are cleared
- [ ] No tag push occurs during pass schedule generation or editing — only at operator acknowledgment

**Dependencies:** FW-061, FW-064, FW-080

---

---

# EPIC 9 — Reporting Suite (FW-E09)

**Goal:** Build the full flat wire reporting suite under a new Flattening Lines tab, covering all High-priority reports required for the July 1 trial.
**Sprint:** 5

---

### FW-090 · Flattening Lines tab in .NET Reports
**Points:** 2 · **Priority:** High · **Sprint:** 5

**As a** supervisor,
**I want** a Flattening Lines tab in the Reports application,
**So that** all flat wire reports are grouped and accessible from one place.

**Acceptance Criteria:**
- [ ] "Flattening Lines" tab added alongside existing tabs (Slitter Reports, Mill Reports, etc.)
- [ ] Tab lists FL1, FL2, FL3; clicking a machine shows its associated reports
- [ ] WIP Log: FL1, FL2, FL3 added to Station dropdown; hyperlink to Mill Reports (Gauge Trace) added per line

**Dependencies:** FW-003

---

### FW-091 · Gauge Trace report
**Points:** 5 · **Priority:** High · **Sprint:** 5

**As a** process engineer,
**I want** a Gauge Trace report for FL1/FL2/FL3,
**So that** I can review dimensional history and identify process drift.

**Acceptance Criteria:**
- [ ] Based on existing Slitter Reports Gauge Trace
- [ ] Column "Gauge" renamed to "Gauge/Diameter"
- [ ] "# Cuts" column removed
- [ ] FL1 and FL3: real-time view available during active runs
- [ ] FL2: historical/profile view shown when material is checked in to FL2 (not live)
- [ ] Weld join events marked on the trace with source rod alphas
- [ ] Filters: Line (FL1/FL2/FL3), Order, Alpha, Date range

**Dependencies:** FW-080, FW-090

---

### FW-092 · Gauge CPK Deviation and Gauge CPK Report
**Points:** 3 · **Priority:** High · **Sprint:** 5

**As a** quality engineer,
**I want** CPK reports adapted for flat wire,
**So that** I can run statistical process capability analysis on the new lines.

**Acceptance Criteria:**
- [ ] Gauge CPK Deviation: based on existing Slitter report; "Gauge" → "Gauge/Diameter" rename applied
- [ ] Gauge CPK Report: filter dropdown added — `Strip` | `Flat Wire` | `All`
- [ ] Both reports include FL1/FL2/FL3 in machine filter

**Dependencies:** FW-090

---

### FW-093 · Coil Pass Detail report
**Points:** 3 · **Priority:** High · **Sprint:** 5

**As a** production supervisor,
**I want** a Coil Pass Detail report for flat wire runs,
**So that** I can review every pass made on a coil/spool including measurements, die sizes, and weld events.

**Acceptance Criteria:**
- [ ] Based on Mills Coil Pass Detail; all attributes adapted for flat wire
- [ ] UA to provide template of required fields (Tim O.)
- [ ] Includes: Rod alpha, Spool alpha, Coil alpha, Pass Schedule ID, Component configuration, SPC checkpoints, Weld join events, Footage breakdown per source rod

**Dependencies:** FW-090

---

### FW-094 · SPC at Flattening Line report
**Points:** 2 · **Priority:** High · **Sprint:** 5

**As a** quality operator,
**I want** an SPC report filterable by FL1/FL2/FL3,
**So that** I can review SPC checkpoint data for each line independently.

**Acceptance Criteria:**
- [ ] Based on SPC at Mill
- [ ] FL1/FL2/FL3 dropdown added
- [ ] All five SPC checkpoint types displayed (incoming rod diameter, post die-change, FM1 output, FM2 S2 output, final coil)

**Dependencies:** FW-065, FW-090

---

### FW-095 · Cut Traceability Report
**Points:** 2 · **Priority:** High · **Sprint:** 5

**As a** quality engineer,
**I want** a Cut Traceability report for flat wire,
**So that** I can trace any finished coil back through weld points to source rod heat.

**Acceptance Criteria:**
- [ ] Alpha position terminology uses ID/OD/MID; "Cut #" columns not required
- [ ] Full traceability chain shown: Finished Coil Alpha → Spool Alpha → Rod Alphas (per weld segment) → Lot → Heat
- [ ] Weld join events shown with footage boundaries
- [ ] Required for welding wire customers — needed before first shipment

**Dependencies:** FW-063, FW-090

---

---

# EPIC 10 — Coil Yield & Cost Ledger (FW-E10)

**Goal:** Update yield calculation for footage-based weight, support weld traceability in yield, and configure the cost ledger for flat wire costing.
**Sprint:** 5
**Priority:** Medium — required by August 1 production.

---

### FW-100 · Footage-based weight calculation
**Points:** 3 · **Priority:** High · **Sprint:** 5

**As a** production supervisor,
**I want** output coil weight calculated from footage rather than scale weight during production,
**So that** weight is tracked accurately in real-time without a physical scale at TKUP-2.

**Acceptance Criteria:**
- [ ] Weight = Footage × (cross-section area × alloy density) — formula confirmed by Tim O. / Bob S. (OQ-36)
- [ ] Conversion factor is looked up per alloy and cross-section from the alloy properties table
- [ ] Calculated weight shown on Dashboard 7 (Output Coil Completion) as Net Weight
- [ ] Operator can override calculated weight with scale weight if scale is available
- [ ] Footage-to-weight factor is maintainable in the alloy lookup table without a code change

**Dependencies:** FW-004
**Open Questions:** OQ-36 (footage-to-weight conversion formula) must be confirmed before implementation.

---

### FW-101 · Weld traceability in yield reporting
**Points:** 3 · **Priority:** High · **Sprint:** 5

**As a** production controller,
**I want** yield reporting to attribute output footage to each source rod through weld points,
**So that** metallic yield is calculated correctly per rod heat for welding wire customers.

**Acceptance Criteria:**
- [ ] Footage split at each weld point is recorded and retrievable
- [ ] Yield report shows: Rod Alpha | Footage Contributed | Output Alpha | Order | Yield %
- [ ] Multi-rod runs (2+ welds) produce multi-row yield attribution
- [ ] "Flat Wire" checkbox added to the yield form
- [ ] Field renames applied: "Outgoing Gauge" → "Outgoing Gauge/Diameter"; "Coil #" → "Coil/Bundle #"; "Gauge" → "Gauge/Diameter"

**Dependencies:** FW-063, FW-090

---

### FW-102 · Cost Ledger — flat wire costing configuration
**Points:** 3 · **Priority:** Medium · **Sprint:** 5

**As a** cost accountant,
**I want** flat wire cost reporting configured in the Cost Ledger,
**So that** wire production costs are reportable separately from coil costs.

**Acceptance Criteria:**
- [ ] Ability to report wire separately (similar to B2B capability)
- [ ] Standard times for FL1, FL2, FL3 loaded once confirmed by Tim O. / Jeff G. (OQ-5)
- [ ] Industry code question resolved (OQ-3) before costing standards are applied
- [ ] Placeholder configuration deployed; full activation after OQ-3 and OQ-5 are decided

**Dependencies:** FW-003
**Open Questions:** OQ-3 (costing standards), OQ-5 (standard times)

---

---

# EPIC 11 — Scrap Management (FW-E11)

**Goal:** Add the new Scrap Box / Scrap Skid outlet selection to the Scrap module and confirm scrap handling flows for flat wire.
**Sprint:** 5
**Priority:** Low — post go-live acceptable.

---

### FW-110 · Scrap module — new outlet selection
**Points:** 2 · **Priority:** Low · **Sprint:** 5

**As a** scrap operator,
**I want** to select "Scrap Box" or "Scrap Skid" as the scrap outlet when logging flat wire scrap,
**So that** wire scrap is routed to the correct physical container.

**Acceptance Criteria:**
- [ ] New outlet selection in Scrap module: `Scrap Box` | `Scrap Skid`
- [ ] Selection applies to: Flat Wire, Conveyors, and Inspection systems
- [ ] Existing outlet options for coil scrap are unchanged
- [ ] Combining flat wire scrap with other scrap types: confirmed compatible (Ryan B.) — no system restriction added
- [ ] Bander material confirmation (steel vs. aluminum alloy — OQ-13) must be resolved before physical packing spec is set

**Dependencies:** None
**Open Questions:** OQ-7 (baler maximum dimensions), OQ-13 (scrap banding material)

---

---

# EPIC 12 — Testing & Go-Live (FW-E12)

**Goal:** Integration testing across all three operating routes, PLC commissioning support, UAT with business stakeholders, and production release.
**Sprint:** 5 + post-trial

---

### FW-120 · Integration test — FL1 standalone end-to-end
**Points:** 5 · **Priority:** Critical · **Sprint:** 5

**As a** QA engineer,
**I want** a full end-to-end integration test for the FL1 standalone route,
**So that** I can confirm all screens, API calls, PLC tag pushes, and traceability records work together before trial.

**Acceptance Criteria:**
- [ ] Test sequence: Rod Received → Planned → Scheduled on FL1 → Check-in (Dashboard 2) → Active Run (Dashboard 3) → SPC Checkpoint → Weld Event → Complete Run → Output Spool Alpha generated → Spool Label printed → Shift Summary correct
- [ ] PLC tag push verified (stub or commissioning environment)
- [ ] INFLAT status set on check-in; cleared on completion
- [ ] All SPC checkpoint records written correctly
- [ ] Weld traceability chain correct in output

**Dependencies:** All FW-E01 through FW-E08 stories

---

### FW-121 · Integration test — FL2 standalone end-to-end
**Points:** 3 · **Priority:** Critical · **Sprint:** 5

**As a** QA engineer,
**I want** a full end-to-end integration test for the FL2 standalone route,
**So that** spool-in / coreless-coil-out with historical gauge trace is verified before trial.

**Acceptance Criteria:**
- [ ] Test sequence: Spool from FL1 → FL2 Check-in (Dashboard 5, historical gauge profile shown) → Active Run → Roll Adjust → Output Coil Completion (Dashboard 7) → Skid management (2 coils → skid close)
- [ ] Historical gauge profile correctly loaded from FL1 run data
- [ ] Coil label fields all populated correctly

**Dependencies:** FW-120

---

### FW-122 · Integration test — FL3 hybrid end-to-end
**Points:** 5 · **Priority:** Critical · **Sprint:** 5

**As a** QA engineer,
**I want** a full end-to-end integration test for the FL3 hybrid (continuous) route,
**So that** the most complex operating mode is validated before trial.

**Acceptance Criteria:**
- [ ] Test sequence: Rod → FL3 Check-in (single acknowledgment) → Continuous run through FM1 + FM2 → Real-time gauge trace continuous → No intermediate spool alpha → Weld event mid-run → Output Coil Completion
- [ ] No intermediate alpha generated between FM1 and FM2 (hybrid mode — confirmed)
- [ ] Single PLC tag push covers both FM1 and FM2 components
- [ ] FL1 and FL2 both show as unavailable in scheduling during FL3 run

**Dependencies:** FW-120, FW-121

---

### FW-123 · UAT and stakeholder sign-off
**Points:** 3 · **Priority:** Critical · **Sprint:** 5

**As a** project manager,
**I want** a structured UAT session with Tim O., Shannon R., and the operations team,
**So that** the system is validated by business stakeholders before the July 1 trial.

**Acceptance Criteria:**
- [ ] UAT environment deployed to staging (devual-uadev001 or equivalent)
- [ ] Clickable demo / staging access provided as requested (Apr 28 meeting)
- [ ] All High-priority features tested by business team against test scripts
- [ ] All Critical open questions (OQ-1, OQ-10, OQ-14, OQ-15, OQ-18, OQ-27, OQ-35, OQ-36, OQ-45, OQ-51, OQ-52) resolved before UAT begins
- [ ] Sign-off received from Tim O. and Shannon R. before trial date

**Dependencies:** FW-120, FW-121, FW-122

---

---

## Backlog Summary

| Epic | Stories | Total Points | Sprint | Priority |
|------|---------|-------------|--------|----------|
| E01 — Foundation & Infrastructure | 7 | 28 | 1 | Critical |
| E02 — Pass Schedule Module | 5 | 27 | 2 | Critical |
| E03 — Rod Receiving | 3 | 10 | 2 | Critical/High |
| E04 — Scheduling System | 2 | 5 | 3 | High |
| E05 — Planning System | 4 | 16 | 3 | Critical/High |
| E06 — Web App Changes | 6 | 16 | 3 | High/Medium |
| E07 — Shopfloor UI | 14 | 65 | 4 | Critical/High |
| E08 — Real-Time / PLC | 3 | 13 | 5 | Critical |
| E09 — Reporting Suite | 6 | 17 | 5 | High |
| E10 — Coil Yield & Cost | 3 | 9 | 5 | High/Medium |
| E11 — Scrap Management | 1 | 2 | 5 | Low |
| E12 — Testing & Go-Live | 4 | 16 | 5 | Critical |
| **Total** | **58** | **224** | | |

---

## Critical Path

```
FW-001 (DB Schema — existing column renames)
    └─> FW-002 (INFLAT status)
        └─> FW-003 (Machines FL1/FL2/FL3)

FW-005 (Fix existing FlatWire tables)
    └─> FW-006 (Create core entity tables: PassSchedule, Rod, RodCheckin, RunPauseEvent, RodCheckout)
        └─> FW-007 (Create event/output tables: WeldEvent, RollOverride, DieChange, SPC, WipRejection, CoilOutput, CoilTraceability)
            └─> FW-010 (Pass Schedule API — builds on PassSchedule + PassScheduleComponent tables)
                ├─> FW-011 / FW-012 / FW-013 (Pass Schedule UI)
                └─> FW-061 (Dashboard 2 — Rod Check-in)
                    ├─> FW-062 (Dashboard 3 — Active Run)
                    │   ├─> FW-063 (Weld Event — DB2A dialog)
                    │   ├─> FW-065 (Dashboard 6 — SPC)
                    │   ├─> FW-070 (Dashboard 11 — Roll Adjust)
                    │   └─> FW-071 (Pause Run)
                    │       └─> FW-072 (Dashboard 12 — Rod Checkout)
                    └─> FW-064 (Dashboard 5 — FL2 Spool Check-in)
                        └─> FW-066 (Dashboard 7 — Coil Completion)
FW-004 (Alloy Lookup)
    └─> FW-013 (Generate from Specs algorithm)
FW-080 (SignalR Hub)
    └─> FW-081 (Live Gauge Trace)
    └─> FW-082 (PLC tag push)
```

---

## Open Questions Blocking Development

The following open questions must be resolved **before** their dependent stories can begin. Track these as separate Jira tasks assigned to the stated owners.

| OQ | Question | Blocks | Owner |
|----|----------|--------|-------|
| OQ-1 | Pass schedule management — UI vs. table? | FW-012 | Tim O. |
| OQ-10 | FL3 scheduling representation | FW-030 | Tim O. / Stephen |
| OQ-14 | Traveler screen fields per station | FW-061/064 | Jaspreet / Tim O. |
| OQ-15 | FL2 spool check-in identifier | FW-064 | Jaspreet / Tim O. |
| OQ-18 | Inventory type for rods in coils table | FW-020 | Tim O. / Jeff G. |
| OQ-27 | Mid-run pass schedule change — alpha handling | FW-061 | Jaspreet / Tim O. |
| OQ-35 | Expected metallic yield per route | FW-041 | Tim O. / Jeff G. |
| OQ-36 | Footage-to-weight conversion factor | FW-100, FW-066 | Tim O. / Bob S. |
| OQ-45 | FL1/FL2 simultaneous independent operation | FW-030 | Tim O. / Stephen |
| OQ-48 | Mid-run checkout authorisation level | FW-072 | Tim O. / Shannon R. |
| OQ-49 | PLC tag behaviour on checkout | FW-072, FW-082 | Jaspreet / Tim O. |
| OQ-51 | Pass schedule selection mechanism at check-in | FW-061 | Tim O. / Jaspreet |
| OQ-52 | FL3 hybrid — one or two pass schedules? | FW-061, FW-030 | Tim O. / Jaspreet |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [FlatWirePlan.md](../Analysis/FlatWirePlan.md) | Full scope, milestones, risks |
| [FlatWireEndToEndProcess.md](../Analysis/FlatWireEndToEndProcess.md) | End-to-end process — all 11 stages |
| [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) | Open questions register — 59 items |
| [FlatWireShopfloorDashboards.md](../Analysis/FlatWireShopfloorDashboards.md) | Dashboard UX specs and wireframes |
| [TechStackRecommendation.md](TechStackRecommendation.md) | Architecture decisions |
| [FlatWireTables.md](FlatWireTables.md) | Database table design — all 20 tables with column specs, analysis of existing tables, and missing table definitions |
