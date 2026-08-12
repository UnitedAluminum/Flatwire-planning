# Flat Wire Mill — API Development Plan & Contracts

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 1, 2026 (30 Jul client decisions applied to `/staging/**`, `/rod/{alpha}` and `/wipreject`; body otherwise April 30, 2026 — see `REVIEW.md`)
**Document Type:** API Contract Reference
**Microservice:** `FlatWire.API` (new service in `ual-api`)
**Base URL:** `/api/v1/flatwire`
**Status:** Draft — For developer implementation

---

## Overview

All endpoints live in a single new `FlatWire` microservice following the existing UAL Clean Architecture pattern. Controllers are thin; all logic routes through MediatR commands/queries.

### Controller Map

| Controller | Routes | Sprint |
|---|---|---|
| `LinesController` | `/lines/status` | S1 |
| `PassScheduleController` | `/passschedule/**` | S2 |
| `RodReceivingController` | `/rod/**` | S2 |
| `PayoffStagingController` | `/payoff/status`, `/staging/**` | S3 |
| `CheckInController` | `/checkin/**` | S3 |
| `RunController` | `/run/**` | S3 |
| `SpcController` | `/spc` | S3 |
| `WeldEventController` | `/weldevent` | S4 |
| `RollAdjustController` | `/rolloverride` | S4 |
| `DieChangeController` | `/diechange` | S4 |
| `CheckOutController` | `/checkout` | S4 |
| `WipRejectionController` | `/wipreject` | S4 |
| `CoilController` | `/coil/**` | S4 |
| `ShiftSummaryController` | `/shiftsummary` | S5 |

### Microservice Project Structure

```
FlatWire/
├── FlatWire.API/
│   ├── Controllers/
│   │   ├── LinesController.cs
│   │   ├── PassScheduleController.cs
│   │   ├── RodReceivingController.cs
│   │   ├── CheckInController.cs
│   │   ├── RunController.cs
│   │   ├── SpcController.cs
│   │   ├── WeldEventController.cs
│   │   ├── RollAdjustController.cs
│   │   ├── DieChangeController.cs
│   │   ├── CheckOutController.cs
│   │   ├── WipRejectionController.cs
│   │   ├── CoilController.cs
│   │   └── ShiftSummaryController.cs
│   └── Hubs/
│       └── FlatWireHub.cs                  ← SignalR hub
│
├── FlatWire.Application/
│   ├── Commands/
│   │   ├── CheckInRod/
│   │   ├── CheckInSpool/
│   │   ├── RecordWeldEvent/
│   │   ├── RecordRollOverride/
│   │   ├── RecordDieChange/
│   │   ├── CheckOutRod/
│   │   ├── SubmitWipRejection/
│   │   ├── SubmitSpcCheckpoint/
│   │   ├── PauseRun/
│   │   ├── ResumeRun/
│   │   ├── CompleteCoil/
│   │   ├── CreatePassSchedule/
│   │   ├── UpdatePassSchedule/
│   │   └── GeneratePassSchedule/
│   └── Queries/
│       ├── GetLinesStatus/
│       ├── GetPassSchedule/
│       ├── GetPassScheduleList/
│       ├── GetActiveRun/
│       ├── GetGaugeTrace/
│       └── GetShiftSummary/
│
├── FlatWire.Domain/
│   └── AggregatesModel/
│       ├── PassSchedule.cs
│       ├── FlatWireRun.cs
│       ├── Rod.cs
│       ├── WeldJoinEvent.cs
│       └── SpcCheckpoint.cs
│
└── FlatWire.Infrastructure/
    ├── Repositories/
    ├── PLCTagService.cs
    └── Context/FlatWireDbContext.cs
```

### Common Response Envelope

All responses follow the UAL envelope pattern:

```csharp
// Success
HTTP 200 OK
{
  "data": { ... },          // payload
  "success": true
}

// Validation error
HTTP 400 Bad Request
{
  "success": false,
  "errors": ["Field X is required", "..."]
}

// Not found
HTTP 404 Not Found
{
  "success": false,
  "errors": ["Resource not found"]
}

// Server / PLC error
HTTP 500 Internal Server Error
{
  "success": false,
  "errors": ["PLC tag write failed — check-in aborted"]
}
```

### Common Enums (shared across all contracts)

```csharp
enum LineId          { FL1, FL2, FL3 }
enum LineStatus      { Running, Idle, Setup, Paused, Fault, Offline }
enum RouteMode       { Standalone, Hybrid }
enum ScheduleStatus  { Draft, Active, Inactive }
enum ComponentName   { DB1, DB2, FM1, EdgeSet, FM2_S1, FM2_S2, FM2_S3 }   // FM2: S1 = 8", S2 = 6", S3 = 6" final (Aug 4 2026)
enum ComponentState  { Active, Bypass, Skip }
enum CoilStatus      { RECEIVED, STAGED, INFLAT, COMPLETE, HOLD, SCRAP }
enum PayoffPosition  { Payoff1 = 1, Payoff2 = 2 }
enum CheckpointType  { PreRun, PostDieChange, ManualSpotCheck, PostRun }
enum DispositionCode { Suspend, Scrap, Rework }
enum AlertSeverity   { Info, Warning, Critical }
```

---

---

## SPRINT 1 — Foundation APIs

**Needed by:** Sprint S1 of the shopfloor workstream
**Blocks:** Dashboard 1 (Line Status Overview), SignalR hub connection

---

### GET `/api/v1/flatwire/lines/status`

Returns the current status summary of all three flat wire lines. Polled at startup; live updates delivered via SignalR `LineStatus` event.

**Auth:** Bearer JWT — any authenticated role

**Response `200 OK`:**

```json
{
  "data": {
    "lines": [
      {
        "lineId": "FL1",
        "status": "Running",
        "activeOrderId": "FW-00421",
        "activeAlpha": "R00041",
        "alloy": "1100",
        "routeMode": "Standalone",
        "speedFpm": 142.5,
        "currentGauge": 0.125,
        "currentWidth": 0.875,
        "targetGauge": 0.125,
        "targetWidth": 0.875,
        "gaugeTolerance": 0.003,
        "widthTolerance": 0.005,
        "runStartedAt": "2026-04-30T06:14:00Z",
        "payoffs": [
          {
            "position": 1,
            "weightLb": 1240.0,
            "percentRemaining": 62.0,
            "alpha": "R00041"
          },
          {
            "position": 2,
            "weightLb": 0.0,
            "percentRemaining": 0.0,
            "alpha": null,
            "status": "NotLoaded"
          }
        ],
        "activeAlerts": [
          {
            "alertType": "GaugeOutOfSpec",
            "severity": "Warning",
            "message": "Gauge 0.131\" exceeds upper limit 0.128\"",
            "raisedAt": "2026-04-30T07:02:11Z"
          }
        ]
      },
      {
        "lineId": "FL2",
        "status": "Idle",
        "activeOrderId": null,
        "activeAlpha": null,
        "alloy": null,
        "routeMode": null,
        "speedFpm": 0,
        "currentGauge": null,
        "currentWidth": null,
        "targetGauge": null,
        "targetWidth": null,
        "gaugeTolerance": null,
        "widthTolerance": null,
        "runStartedAt": null,
        "payoffs": [],
        "activeAlerts": []
      },
      {
        "lineId": "FL3",
        "status": "Offline",
        "activeOrderId": null,
        "activeAlpha": null,
        "alloy": null,
        "routeMode": null,
        "speedFpm": 0,
        "currentGauge": null,
        "currentWidth": null,
        "targetGauge": null,
        "targetWidth": null,
        "gaugeTolerance": null,
        "widthTolerance": null,
        "runStartedAt": null,
        "payoffs": [],
        "activeAlerts": []
      }
    ],
    "asOf": "2026-04-30T07:15:00Z"
  },
  "success": true
}
```

**C# Response DTO:**

```csharp
public record LinesStatusResponse(
    IReadOnlyList<LineStatusDto> Lines,
    DateTimeOffset AsOf);

public record LineStatusDto(
    string LineId,
    LineStatus Status,
    string? ActiveOrderId,
    string? ActiveAlpha,
    string? Alloy,
    RouteMode? RouteMode,
    decimal SpeedFpm,
    decimal? CurrentGauge,
    decimal? CurrentWidth,
    decimal? TargetGauge,
    decimal? TargetWidth,
    decimal? GaugeTolerance,
    decimal? WidthTolerance,
    DateTimeOffset? RunStartedAt,
    IReadOnlyList<PayoffStatusDto> Payoffs,
    IReadOnlyList<ActiveAlertDto> ActiveAlerts);

public record PayoffStatusDto(
    int Position,
    decimal WeightLb,
    decimal PercentRemaining,
    string? Alpha,
    string? Status);

public record ActiveAlertDto(
    string AlertType,
    AlertSeverity Severity,
    string Message,
    DateTimeOffset RaisedAt);
```

---

---

## SPRINT 2 — Pass Schedule APIs + Rod Receiving

**Needed by:** Sprint S2 of the shopfloor workstream
**Blocks:** Dashboard 9A, Dashboard 9, Pass Schedule Generation modal, Dashboard 2 (Rod Check-in)

---

### GET `/api/v1/flatwire/passschedule`

Returns a filtered, paginated list of pass schedule records.

**Auth:** Bearer JWT — any authenticated role

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `search` | `string?` | Free text — matches ScheduleId, Description, Alloy |
| `alloy` | `string?` | Filter by alloy code (e.g. `1100`) |
| `line` | `string?` | Filter by line: `FL1`, `FL2`, `FL3` |
| `status` | `string?` | Filter: `Draft`, `Active`, `Inactive` |
| `page` | `int` | Default `1` |
| `pageSize` | `int` | Default `50`, max `200` |

**Response `200 OK`:**

```json
{
  "data": {
    "items": [
      {
        "scheduleId": "PS-1100-FL1-003",
        "description": "1100 Rod to Flat 0.125 x 0.875",
        "alloy": "1100",
        "line": "FL1",
        "routeMode": "Standalone",
        "status": "Active",
        "activeJobId": "FW-00421",
        "modifiedAt": "2026-04-28T14:30:00Z",
        "modifiedBy": "shannon.r"
      }
    ],
    "total": 14,
    "active": 6,
    "draft": 3,
    "inactive": 5,
    "page": 1,
    "pageSize": 50
  },
  "success": true
}
```

---

### GET `/api/v1/flatwire/passschedule/{id}`

Returns full detail of a single pass schedule including all component rows and recent overrides.

**Auth:** Bearer JWT — any authenticated role

**Path Parameters:** `id` — Schedule ID string (e.g. `PS-1100-FL1-003`)

**Response `200 OK`:**

```json
{
  "data": {
    "scheduleId": "PS-1100-FL1-003",
    "description": "1100 Rod to Flat 0.125 x 0.875",
    "alloy": "1100",
    "line": "FL1",
    "routeMode": "Standalone",
    "status": "Active",
    "targetGauge": 0.125,
    "gaugeTolerance": 0.003,
    "targetWidth": 0.875,
    "widthTolerance": 0.005,
    "lineSpeedMinFpm": 100,
    "lineSpeedMaxFpm": 200,
    "createdBy": "shannon.r",
    "createdAt": "2026-04-20T09:00:00Z",
    "modifiedBy": "shannon.r",
    "modifiedAt": "2026-04-28T14:30:00Z",
    "components": [
      {
        "componentName": "DB1",
        "state": "Active",
        "parameterValue": 0.310,
        "edgeType": null
      },
      {
        "componentName": "DB2",
        "state": "Active",
        "parameterValue": 0.260,
        "edgeType": null
      },
      {
        "componentName": "FM1",
        "state": "Active",
        "parameterValue": 0.128,
        "edgeType": null
      },
      {
        "componentName": "EdgeSet",
        "state": "Active",
        "parameterValue": null,
        "edgeType": "Round"
      },
      {
        "componentName": "FM2_S1",
        "state": "Bypass",
        "parameterValue": null,
        "edgeType": null
      },
      {
        "componentName": "FM2_S2",
        "state": "Bypass",
        "parameterValue": null,
        "edgeType": null
      },
      {
        "componentName": "FM2_S3",
        "state": "Active",
        "parameterValue": 0.125,
        "edgeType": null
      }
    ],
    "recentOverrides": [
      {
        "overrideId": "OVR-0041",
        "runId": "RUN-0041",
        "componentName": "FM1",
        "oldValue": 0.128,
        "newValue": 0.126,
        "reason": "Gauge drift (high)",
        "operatorId": "john.d",
        "timestamp": "2026-04-29T10:14:00Z",
        "footagePosition": 3420
      }
    ]
  },
  "success": true
}
```

**C# Response DTO:**

```csharp
public record PassScheduleDetailResponse(
    string ScheduleId,
    string Description,
    string Alloy,
    string Line,
    RouteMode RouteMode,
    ScheduleStatus Status,
    decimal TargetGauge,
    decimal GaugeTolerance,
    decimal TargetWidth,
    decimal WidthTolerance,
    int LineSpeedMinFpm,
    int LineSpeedMaxFpm,
    string CreatedBy,
    DateTimeOffset CreatedAt,
    string ModifiedBy,
    DateTimeOffset ModifiedAt,
    IReadOnlyList<PassScheduleComponentDto> Components,
    IReadOnlyList<PassScheduleOverrideDto> RecentOverrides);

public record PassScheduleComponentDto(
    string ComponentName,
    ComponentState State,
    decimal? ParameterValue,
    string? EdgeType);

public record PassScheduleOverrideDto(
    string OverrideId,
    string RunId,
    string ComponentName,
    decimal OldValue,
    decimal NewValue,
    string Reason,
    string OperatorId,
    DateTimeOffset Timestamp,
    int FootagePosition);
```

---

### POST `/api/v1/flatwire/passschedule`

Creates a new pass schedule record. New records start in `Draft` status.

**Auth:** Bearer JWT — Operations Manager or Maintenance role

**Request Body:**

```json
{
  "description": "1100 Rod to Flat 0.125 x 0.875",
  "alloy": "1100",
  "line": "FL1",
  "routeMode": "Standalone",
  "targetGauge": 0.125,
  "gaugeTolerance": 0.003,
  "targetWidth": 0.875,
  "widthTolerance": 0.005,
  "lineSpeedMinFpm": 100,
  "lineSpeedMaxFpm": 200,
  "components": [
    { "componentName": "DB1",      "state": "Active", "parameterValue": 0.310, "edgeType": null },
    { "componentName": "DB2",      "state": "Active", "parameterValue": 0.260, "edgeType": null },
    { "componentName": "FM1",      "state": "Active", "parameterValue": 0.128, "edgeType": null },
    { "componentName": "EdgeSet",  "state": "Active", "parameterValue": null,  "edgeType": "Round" },
    { "componentName": "FM2_S1", "state": "Bypass", "parameterValue": null,  "edgeType": null },
    { "componentName": "FM2_S2", "state": "Bypass", "parameterValue": null,  "edgeType": null },
    { "componentName": "FM2_S3", "state": "Active", "parameterValue": 0.125, "edgeType": null }
  ]
}
```

**Validation Rules:**
- `FM2_S3` must always be `Active` — reject `Bypass` or `Skip`. *(It is FM2's final gauge-control stand. Aug 4 2026: this rule previously named `FM2_6inS2`, which is the same physical stand under the three-stand correction — see `00-foundations.md` §0.3. Closes **OI-04**.)*
- `FM1` must always be `Active` — reject `Bypass` or `Skip`
- If `routeMode = Standalone` and `line = FL3` → reject (FL3 requires Hybrid)
- All component rows for the given line/routeMode must be present

**Response `201 Created`:**

```json
{
  "data": {
    "scheduleId": "PS-1100-FL1-004",
    "status": "Draft"
  },
  "success": true
}
```

---

### PUT `/api/v1/flatwire/passschedule/{id}`

Replaces all editable fields on an existing pass schedule. Not allowed on an `Active` schedule that is currently linked to a running job.

**Auth:** Bearer JWT — Operations Manager or Maintenance role

**Request Body:** Same shape as `POST /passschedule`

**Response `200 OK`:**

```json
{
  "data": { "scheduleId": "PS-1100-FL1-003", "modifiedAt": "2026-04-30T08:00:00Z" },
  "success": true
}
```

---

### PATCH `/api/v1/flatwire/passschedule/{id}/status`

Transitions the status of a pass schedule.

**Auth:** Bearer JWT — Operations Manager role

**Request Body:**

```json
{
  "status": "Active"
}
```

**Allowed transitions:**

| From | To | Notes |
|---|---|---|
| `Draft` | `Active` | Makes schedule available at check-in |
| `Active` | `Inactive` | Hides from check-in; retained for history |
| `Inactive` | `Active` | Re-activates a previously hidden schedule |

**Response `200 OK`:**

```json
{
  "data": { "scheduleId": "PS-1100-FL1-003", "newStatus": "Active" },
  "success": true
}
```

---

### POST `/api/v1/flatwire/passschedule/generate`

Runs the pass schedule generation algorithm from raw specs. Returns a draft component configuration without persisting it. The frontend then calls `POST /passschedule` to persist the result.

**Auth:** Bearer JWT — Operations Manager or Maintenance role

**Request Body:**

```json
{
  "alloy": "1100",
  "rodDiameterInches": 0.375,
  "targetGaugeInches": 0.125,
  "targetWidthInches": 0.875,
  "edgeType": "Round"
}
```

**Algorithm (backend implementation):**

```
1. Pre-flatten diameter:  D_pre = sqrt(4 × gauge × width / π)
2. Area reduction:        areaRed = 1 - (D_pre² / rodDia²)
3. Draw passes decision:
     areaRed ≤ 2%         → both DB1 and DB2 bypass
     areaRed ≤ 1× maxRed  → DB1 active, DB2 bypass
     areaRed ≤ 2× maxRed  → DB1 and DB2 active
     areaRed >  2× maxRed → error flag (still return result)
4. DB1 die  = geometric_mean(rodDia, D_pre) snapped to nearest 0.005"
5. DB2 die  = D_pre snapped to nearest 0.005"
6. FM1 gap  = gauge × springbackFactor
7. AspectRatio = width / gauge
   If aspectRatio > 5.5 OR alloy = "1350" → activate FM2, routeMode = Hybrid
8. FM2 gaps (three stands — S1 is the 8" roller, S2 and S3 are 6"):
     FM2_S1 = gauge × 1.06
     FM2_S2 = gauge × 1.02
     FM2_S3 = gauge × springbackFactor        -- final gauge control
```

**Response `200 OK`:**

```json
{
  "data": {
    "preflattenDiameterIn": 0.265,
    "areaReductionPct": 50.1,
    "drawPasses": 2,
    "aspectRatio": 7.0,
    "routeMode": "Standalone",
    "warnings": [
      { "code": "DieSizeSnapped", "message": "DB1 die snapped to nearest 0.005\" (0.315 → 0.315\")" }
    ],
    "errors": [],
    "components": [
      { "componentName": "DB1",       "state": "Active", "parameterValue": 0.315, "edgeType": null },
      { "componentName": "DB2",       "state": "Active", "parameterValue": 0.265, "edgeType": null },
      { "componentName": "FM1",       "state": "Active", "parameterValue": 0.128, "edgeType": null },
      { "componentName": "EdgeSet",   "state": "Active", "parameterValue": null,  "edgeType": "Round" },
      { "componentName": "FM2_S1", "state": "Bypass", "parameterValue": null,  "edgeType": null },
      { "componentName": "FM2_S2", "state": "Bypass", "parameterValue": null,  "edgeType": null },
      { "componentName": "FM2_S3", "state": "Active", "parameterValue": 0.125, "edgeType": null }
    ]
  },
  "success": true
}
```

**Warning Codes:**

| Code | Message |
|---|---|
| `FM2Activated` | FM2 activated — aspect ratio > 5.5 |
| `RouteSetToHybrid` | Route set to Hybrid FL3 |
| `PrecisionMode1350` | 1350 detected — welding wire precision mode |
| `HighAspectRatioWarning` | Very high aspect ratio (>10) — verify FM2 capability |
| `DieSizeSnapped` | Die size snapped to nearest 0.005" |
| `TooManyDrawPasses` | Target requires > 2 draw passes — pre-drawn wire required |

---

### GET `/api/v1/flatwire/rod/{alpha}`

Validates and returns details for a rod alpha (used during check-in scan).

**Auth:** Bearer JWT — any authenticated role

**Path Parameters:** `alpha` — R-series alpha string (e.g. `R00041`)

**Response `200 OK`:**

```json
{
  "data": {
    "alpha": "R00041",
    "alloy": "1100",
    "temper": "O",
    "diameterIn": 0.375,
    "grossWeightLb": 2000.0,
    "netWeightLb": 1980.0,
    "status": "STAGED",
    "location": "Floor-A3",
    "receivedAt": "2026-04-29T14:00:00Z",

    "orderId": "FW-00421",
    "scheduledLineId": "FL1",

    "footageRunToDate": 0.0,
    "remainingWeightEstimateLb": null,
    "stagedPayoffPosition": null,
    "isWelded": false
  },
  "success": true
}
```

**Response `404 Not Found`:** Rod alpha not found in the system.

> **`orderId` / `scheduledLineId` are the rod→order resolution**, read from `planning_routings` (rod→order, written by planning at allocation) joined to scheduling (order→line). They are what let a station with no active order identify which order it is starting, and — since 30 Jul 2026 — **what the client uses to switch itself to the correct station**: if `scheduledLineId` is not the line currently on screen, the UI switches to that line and continues, with no message and no override (**Q24**). Resolve this *before* posting to `/staging/rod` or `/checkin/rod`. `orderId` is **null** for a rod planning has not yet allocated — such a rod cannot be staged. These fields did not exist in the April contract, which is why the queue projection had no documented source.

> **The last four fields are required, not optional.** Without `footageRunToDate` the caller
> cannot enforce the `PRC007` carry-forward gate — the scan would silently offer a fresh-start
> check-in for a rod that has already run footage, which `PRC008` forbids. `stagedPayoffPosition`
> and `isWelded` are projected from the current `RodStaging` row where `Status = 'Staged'`
> (NULL/false when the rod is not staged); they are no longer columns on `Rod`.

---

### POST `/api/v1/flatwire/rod`

Receives a new wire rod and generates an R-series alpha. Backend only in Phase 1 — no frontend screen for rod receiving.

**Auth:** Bearer JWT — Receiving / Supervisor role

**Request Body:**

```json
{
  "alloy": "1100",
  "temper": "O",
  "diameterIn": 0.375,
  "grossWeightLb": 2000.0,
  "tare": 20.0,
  "supplierHeat": "H2024-001",
  "location": "Floor-A3"
}
```

**Response `201 Created`:**

```json
{
  "data": {
    "alpha": "R00043",
    "status": "RECEIVED"
  },
  "success": true
}
```

---

---

## SPRINT 3 — Check-in, Active Run & SPC APIs

**Needed by:** Sprint S3 of the shopfloor workstream
**Blocks:** Dashboard 2, Dashboard 3, Dashboard 5, Dashboard 6

---

## Pre-Check-in / Payoff Staging APIs

**Implements:** SRS §4.2 `PCI001`–`PCI008`, `WLD003`/`WLD006`/`WLD010`, `TRV004`/`TRV009`, §4.18 `PRC007`/`PRC008`/`PRC014`
**Blocks:** Dashboard 2A — Rod Pre-Check-in Station
**Lines:** FL1 and FL3 only. `PCI002` excludes FL2, which has no staging space — a `lineId` of `FL2` is rejected `422`.

Pre-check-in registers the *next* rod against a VPS payoff bay while the current coil is still running, so the line can run continuously through an induction weld. **No PLC write occurs on any endpoint in this section** — tags are pushed only when the pass schedule is acknowledged at check-in.

---

### GET `/api/v1/flatwire/payoff/status`

The Dashboard 2A primary read: the state of both payoff bays on one line. Backs the bay cards — including the two weld controls they now carry, *Mark as welded* on the staged card and *Welds this run* on the active one (the weld-readiness strip they used to sit in was removed 1 Aug 2026) — and the Phase-3 alert rule *"Payoff2 not loaded & Payoff1 < 2,000 lb → Critical"*, which previously had no data source.

**Auth:** Bearer JWT — any authenticated role

**Query Parameters:** `lineId` — `FL1` or `FL3` (required)

**Response `200 OK`:**

```json
{
  "data": {
    "lineId": "FL1",
    "bays": [
      {
        "position": 1,
        "state": "Active",
        "rodAlpha": "R00042",
        "rodSeqno": 1,
        "alloy": "1100",
        "temper": "F",
        "diameterIn": 0.375,
        "grossWeightLb": 8840.0,
        "netWeightLb": 8500.0,
        "weightLb": 2840.0,
        "percentRemaining": 33.4,
        "isWelded": false,
        "stagedAt": "2026-07-29T11:02:00Z",
        "stagedBy": "dave.m",
        "footageRunToDate": 14320.0,
        "runId": "RUN-0418",
        "inspection": { "oxidation": "Pass", "surfaceDefects": "Pass", "waterStains": "Pass", "notes": null }
      },
      {
        "position": 2,
        "state": "NotStaged",
        "rodAlpha": null,
        "rodSeqno": null,
        "weightLb": null,
        "percentRemaining": null,
        "isWelded": false,
        "runId": null,
        "inspection": null
      }
    ],
    "weldReadiness": {
      "severity": "Critical",
      "message": "Payoff 1 below 3,000 lb and Payoff 2 not staged"
    }
  },
  "success": true
}
```

**`state` values:** `NotStaged` · `Staged` · `Active` · `Blocked` (inspection failed at staging)

`weightLb` / `percentRemaining` are live values sourced from the `PayoffWeight` hub feed, not from `RodStaging`; they are `null` on a bay that is not drawing.

---

### POST `/api/v1/flatwire/staging/rod`

Pre-check-in: stage a rod at a payoff bay (`PCI001`, `PCI004`, `PCI005`, `PCI006`).

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "lineId": "FL1",
  "payoffPosition": 2,
  "rodAlpha": "R00043",
  "orderId": "FW-00421",
  "scrapBoxRef": "SB-1100-04",
  "diameterIn": 0.375,
  "grossWeightLb": 8780.0,
  "netWeightLb": 8440.0,
  "inspection": {
    "oxidation": "Pass",
    "surfaceDefects": "Pass",
    "waterStains": "Pass",
    "observationNotes": null
  },
  "acknowledgedCarryForward": false,
  "operatorId": "dave.m"
}
```

> **`rodSeqno` is not a request field — the server assigns it.** It is the *actual* processing sequence, so letting a client supply it would let two operators claim the same position, and would let the UI echo back a rod's *planned* number as though it were the order it ran in. The server takes the next value for the line. `plannedSeqno` is likewise not sent: the server snapshots it from the planning allocation it already resolved to validate order membership.

**Validation — order membership and availability only:**

| Check | Rule | Outcome |
|---|---|---|
| Allocation | The rod must have a `planning_routings` entry, which **yields the order** | `422` if absent |
| Order membership | Once an order is established, the rod must belong to **that** order | `409` — welding across orders would break genealogy. ⚠ **Known wrong for a multi-order rod** — see the note below |
| Order's line | The resolved order must be scheduled on **this** line | **Not a refusal and not an override** — the client switches station; a mismatched POST returns `409` with `correctLineId`, see below |
| Availability | `coils.coil_status` not `INFLAT`/`COMPLETE`/`HOLD`/`SCRAP`, and no `RodStaging` row with `Status = 'Staged'` | `409` |
| Planned sequence | The rod must be the one planning expects next — the lowest `plannedSeqno` still available | **Not a refusal** — supervisor override, see below |

> **The order is resolved, not supplied.** `orderId` in the body is the value the client resolved from `planning_routings` for that rod; the server re-resolves and rejects a mismatch. On a **cold line** (`activeOrderId` null) the first rod is what establishes the order — it *reveals* an allocation planning already made rather than the operator choosing one, which is what keeps even the first rod validatable.

> **⚠ Order membership is knowingly wrong for a multi-order rod (gap G22).** The client confirmed on 30 Jul 2026 (**Q70**) that **one rod may carry more than one production order** — finishing order 1 on a 7,000 lb A-rod and starting order 2 on the remainder. A rod whose *successor* order differs from the established one must therefore **pass**, not `409`. The rule is left as-is deliberately: the replacement depends on the sequencing answer (**Q73**) and on whether the case is **MVP2**. Do not implement the `409` as final.

**Wrong station is corrected, not authorised (changed 30 Jul 2026).** ~~Staging a rod whose order is booked on another line is a deviation requiring a supervisor override.~~ It is **not a deviation at all**: the system **selects the correct station**. The client resolves `scheduledLineId` from `GET /rod/{alpha}` at the scan and, if it differs from the line on screen, **switches to that line** and continues — no message, no override, no supervisor. The same behaviour applies at check-in.

The server still defends the invariant, because a stale or racing client could post to the wrong line:

| Situation | Server behaviour |
|---|---|
| `lineId` matches the resolved `scheduledLineId` | Normal — proceed |
| `lineId` differs | **`409 Conflict`** with `{ "correctLineId": "FL3" }`. The client switches station and re-posts. It is a routing correction, **not** a rejection of the material |
| The order is scheduled on **neither** FL1 nor FL3 | **Open — `Q25`.** There is no station to switch to. Not covered on the 30 Jul call; carried forward. Do not invent a path |

**One deviation remains — notify and authorise, never refuse.** It keeps the commit control reachable once a supervisor signs off, using the `OI-56` credential shape: reason + supervisor badge/ID + PIN, with a remote-approval fallback when no supervisor is on the floor.

| Deviation | Trigger | Recorded as |
|---|---|---|
| **Out of sequence** | The rod is not the one planning expects next | `OutOfSequenceOverride` + `ExpectedRodAlpha` |

```json
"supervisorOverride": {
  "outOfSequence": { "expectedRodAlpha": "R00043" },
  "supervisorBadge": "SUP-204",
  "supervisorPin": "••••",
  "reason": "R00043 blocked behind a forklift"
}
```

Omit `supervisorOverride` entirely when the rod is the expected one. `422` if the deviation applies and the authorisation is missing or incomplete. The flag, the authorising supervisor and the reason are persisted on `RodStaging`; **the PIN is never stored**. `CK_RodStaging_Override` makes the credential stamp all-or-nothing and `CK_RodStaging_OutOfSeq` ties the deviation's evidence to its flag, so an unauditable override cannot be written.

> **Removed 1 Aug 2026:** the `offSchedule` override object, and with it `RodStaging.OffScheduleOverride`, `ScheduledLineId`, `CK_RodStaging_OffSched` and `CK_RodStaging_OffSchedLine`. The shared credential columns (`OverrideBy`/`OverrideAt`/`OverrideReason`) are retained for the surviving override. Two consequences to specify rather than assume: what happens to a **part-completed wizard** when the station switches mid-transaction, and whether an FL3 tab exists on the FL1 panel at all (**OI-26**/**G21**).

> **Superseded (Jul 30 2026).** An earlier requirement had the planned sequence entirely unenforced — *"the operator must be allowed to process the rods in any sequence"*, with explicitly no warning and no override. That is replaced by the notify-and-authorise rule above. The two `RodStaging` sequence columns are unchanged: `PlannedSeqno` still records intent and `RodSeqno` still records what actually ran, so the deviation remains reportable as well as authorised.

> **Open:** whether the PIN validates against the existing login/authorisation service or a separate supervisor credential store — carried over from `OI-56`, unresolved for both overrides.

**Planned order is authorised, not enforced.** Planned `R00043 → R00044 → R00045` may legitimately be staged `R00045 → R00043 → R00044` — but not silently. Out-of-sequence staging is **notified and supervisor-authorised** (see the deviations table below); it is never a `409`. The deviation is both authorised and recorded.

**Side effects** (see the ordering note below — these are **compensating writes**, not one ACID transaction, per gap G2/G16):

1. `RodStaging` row inserted with `Status = 'Staged'`, `RodSeqno` = next actual position for the line, `PlannedSeqno` = the rod's planned position snapshotted from the allocation (NULL if it has none)
2. Shared `coils.coil_status` is **not** changed — `INFLAT` is set at **check-in**, not at staging (**Q68**, client 30 Jul 2026; the SRS §4.2 `PCI` data note is superseded on this point and `RECEIVED → STAGED` stands). **Still open:** whether the reqsum and the `wip_coil_orders` insert from that same note stay here or move to check-in — **cross-database** either way
3. `PayoffStateChanged` SignalR event broadcast to the line group
4. **No PLC write.** Nothing is pushed until check-in acknowledgement

**Response `201 Created`:**

```json
{
  "data": {
    "stagingId": 412,
    "lineId": "FL1",
    "payoffPosition": 2,
    "rodAlpha": "R00043",
    "rodSeqno": 2,
    "state": "Staged",
    "stagedAt": "2026-07-29T12:02:00Z",
    "plcTagsPushed": false
  },
  "success": true
}
```

### Failed inspection — `201 Created` with `state: "Blocked"`, not `422`

**Changed Jul 31 2026.** A `Fail` on any of the three inspection items previously returned `422`
and wrote **nothing**. That was wrong about the physical situation: bundles are not unbanded until
they are positioned at the payoff (which is *why* the visual inspection happens at staging), so a
rod that fails inspection is **already on the bay**. Writing no row left `GET /payoff/status`
reporting `NotStaged` for an occupied position, Dashboard 2A offering that bay as "Empty —
available", and the next rod stageable into it. It also made the `Blocked` bay state — implemented
across the API enum, the schema and the whole of Dashboard 2A — unreachable in practice.

Staging therefore **commits the row before the inspection gate**:

1. `RodStaging` row inserted with `Status = 'Staged'` and the failing inspection column(s) `= 'Fail'`
   (`InspectionNotes` required — the observation is what WIP Rejection consumes)
2. Response `201 Created`, body as above but `"state": "Blocked"`, plus the routing hint
   `{ "route": "wipRejection", "rodAlpha": "…" }`
3. `PayoffStateChanged` broadcast so the bay shows as occupied-and-blocked
4. **No PLC write** (unchanged — nothing is pushed until check-in acknowledgement)

**`CHK010` is unchanged.** The rod still cannot proceed, the only forward path is still WIP
Rejection, and there is still **no override**. What changed is that the bay stays occupied *in the
record* — not that a failed bundle can be run.

> **RESOLVED (client, 30 Jul 2026) — the WIP rejection releases it.** ~~`Status` has no value a
> WIP-rejection outcome can land in, so a blocked bay is enterable but not clearable.~~ A failed
> staging inspection is captured as a **rejection with a reason on the rejection screen**, and the
> rod goes to **`HOLD`** — that is what frees the bay. `POST /wipreject` now also releases the
> staging row: `Status → 'Unstaged'`, `UnstageKind = 'WipRejection'`, `WipRejectionId` set. The
> alternative — a fourth `Rejected` status — was rejected because it would have forced the
> vocabulary, `CK_RodStaging_Unstaged` and `UX_RodStaging_Bay`'s filter to change together.
>
> **Two untraced consequences**, recorded rather than resolved: `RodStaging` now holds rows for
> material that was never accepted, which affects the **`TRV009`** traveler (is `Blocked` a third
> class alongside pre-checked-in and welded?); and the **`Available`** projection must exclude rods
> sitting blocked, or a rejected bundle reappears as stageable.

**Error responses:**

| Status | Condition |
|---|---|
| `409 Conflict` | Bay already occupied — `UX_RodStaging_Bay` violation |
| `409 Conflict` | Rod already staged on another bay — `UX_RodStaging_RodActive` violation |
| `409 Conflict` | Rod is already checked in on a line (`CHK009`) |
| `409 Conflict` | `lineId` is not the line the rod's order is scheduled on — body carries `correctLineId`; the client **switches station and re-posts** rather than surfacing an error |
| `422 Unprocessable Entity` | `lineId` is `FL2` — pre-check-in is not supported there (`PCI002`) |
| ~~`422 Unprocessable Entity`~~ | ~~Any inspection item is `Fail`~~ — **superseded Jul 31 2026**: now `201 Created` with `state: "Blocked"`, see the section above. Still a hard block with no override (`CHK010`); the row is committed so the bay is not falsely reported free |
| `422 Unprocessable Entity` | `footageRunToDate > 0` and `acknowledgedCarryForward` is `false` (`PRC007`) |
| `422 Unprocessable Entity` | Measured diameter outside the **min/max** lookup band (`CHK007`) — `nominal − RodDiameterToleranceMinusIn .. nominal + RodDiameterTolerancePlusIn` from `AlloyProperty`. **The band is nullable and currently unseeded**: the values are owed by e-mail (**Q22**), and until they land this check cannot fire |
| `404 Not Found` | Rod alpha not found in the coils table |

**C# Request DTO:**

```csharp
public record StageRodCommand(
    string LineId,
    PayoffPosition PayoffPosition,
    string RodAlpha,
    int RodSeqno,
    string? OrderId,
    string? ScrapBoxRef,
    decimal DiameterIn,
    decimal GrossWeightLb,
    decimal NetWeightLb,
    InspectionDto Inspection,      // reuses the 3-item DTO — see note
    bool AcknowledgedCarryForward, // PRC007/PRC014
    string OperatorId) : IRequest<StageRodResponse>;
```

> **Reuses the 3-item `InspectionDto`** defined under `POST /checkin/rod`. Do **not** add a
> connector-tag item here — that is a check-in concern, and the 3-vs-4-item divergence is gap
> **G14**, still unresolved. `RodStaging` persists exactly the three items this DTO carries,
> which is why staging does not inherit the `REVIEW.md` #37 defect where `RodCheckin` requires
> NOT NULL columns the check-in command never sends.

---

### POST `/api/v1/flatwire/staging/rod/unstage`

Pre-check-out: release a staged rod that was never checked in.

**Auth:** Bearer JWT — Operator or above **when the rod is unwelded**. A **welded** rod additionally requires a **supervisor override** — see below (**Q69**, decided 30 Jul 2026).

**Request Body:**

```json
{
  "stagingId": 412,
  "reasonCode": "WrongRodMisScan",
  "reasonOther": null,
  "disposition": "ReturnToFloorStorage",
  "notes": null,
  "operatorId": "dave.m"
}
```

**`reasonCode` values:** `WrongRodMisScan` · `OrderCancelledDeferred` · `FailedReInspection` · `RelocatedToLine` · `WrongRodWelded` · `Other` (`reasonOther` required)
**`disposition` values:** `ReturnToFloorStorage` · `ReturnToWarehouse` · `HoldReturnToStorage` *(welded only)*

**Approval depends on the weld (`Q69` / `Q72`, decided 30 Jul 2026):**

| Rod state | Approval | Rod status after | Why |
|---|---|---|---|
| **Not welded** | **None** — operator-only, reason captured | `RECEIVED` | Nothing was committed; the bundle simply comes off the bay |
| **Welded** (`IsWelded = 1`) | **Supervisor override required** — badge/ID + PIN + **documented reason** | **`HOLD`** | The rod is induction-welded to the rod in the mill. Removing it means **cutting or splitting the material**, so this is a **rejection**, not a return |

```json
"supervisorOverride": {
  "supervisorBadge": "SUP-204",
  "supervisorPin": "••••",
  "reason": "Welded to the running rod in error; cut back and held for disposition"
}
```

`422` when the staged rod is welded and `supervisorOverride` is missing or incomplete. **The PIN is never stored.**

> **This restores a control removed on 31 Jul 2026.** Dashboard 2A had dropped Unstage from welded rows entirely, on the reasoning that a welded rod cannot be returned to inventory. That was right about the *unqualified* control and wrong that there is no path at all: the path is a supervisor-approved rejection. `WLD011` remains unspecified for reversing a weld **in place**, on a rod that stays staged.

**Side effects:**

1. `RodStaging.Status → 'Unstaged'` with the release stamp, `UnstageKind = 'PreCheckOut'`
2. `RodCheckout` row written with `Mode = 'ModeP'`, `RunId` NULL, `FootageAtCheckout` 0, `PlcTagsCleared` **false**, `WasWelded` per the staged row, and — when welded — `ApprovedBy`/`ApprovedAt`/`OverrideReason` plus `NewRodStatus = 'HOLD'` (enforced by `CK_RodCheckout_ModePWelded`)
3. Shared `coils` status: **nothing to revert for `INFLAT`**, which staging no longer sets (**Q68**). A welded release sets the rod to `HOLD`. Whether the `wip_coil_orders` insert still has to be reversed depends on the open half of Q68 — compensating write if so
4. `PayoffStateChanged` broadcast with `state: "NotStaged"`
5. **No PLC tag clear.** Nothing was pushed, so there is nothing to clear — and unlike Mode A/B this needs **no `FL{n}.LineState` gate**, because an idle bay is not running

**Response `200 OK`:**

```json
{
  "data": {
    "checkoutId": "CO-0052",
    "mode": "ModeP",
    "rodAlpha": "R00043",
    "newRodStatus": "RECEIVED",
    "plcTagsCleared": false
  },
  "success": true
}
```

**Response `409 Conflict`:** The staged row is already `CheckedIn` — the caller must use `POST /checkout` with `mode: "ModeA"` instead, which does void the acknowledgement and clear tags.

**Response `422 Unprocessable Entity`:** `reasonCode` is `Other` with no `reasonOther`.

---

### ~~POST `/api/v1/flatwire/staging/rod/mark-welded`~~ — **RETIRED 1 Aug 2026**

**Superseded by `POST /weldevent`, which is now the single weld write.** Do not implement.

The endpoint recorded a weld as a bare flag — `RodStaging.IsWelded` / `WeldedAt` / `WeldedBy` — and captured
**no quality result and no footage**. That produced a state `WeldEvent.md` §1.2 calls uncertifiable: a weld
asserted to exist with nothing recorded about whether it held. Meanwhile `POST /weldevent` wrote a second,
richer record of the *same physical join* from Dashboard 4, and nothing reconciled the two.

Dashboard 2A's Mark as welded dialog now captures the weld quality (`WLD013`), which was the **only** NOT NULL
`WeldEvent` column it was missing — it already had both rod alphas, the weld type and the footage. Both screens
therefore compose the same row, so there is one endpoint and one record. This is decision **D-A** in
`WeldEventPopupPlan.md`, and it closes **Q-W1**.

**Migration:** callers move to `POST /weldevent`, which sets the `RodStaging` weld columns in the same
transaction — **on a `Pass` result only**. See that endpoint for the conditional write.

---

### GET `/api/v1/flatwire/staging/queue`

The Traveler Queue section (`TRV004`, `TRV009`): pre-checked-in, welded, and available rod for the current order at the line.

**Auth:** Bearer JWT — any authenticated role

**Query Parameters:** `lineId` — `FL1` or `FL3` (required)

**Response `200 OK`:**

```json
{
  "data": [
    {
      "plannedSeqno": 1, "rodSeqno": 2, "rodAlpha": "R00043", "alloy": "1100",
      "temper": "F", "diameterIn": 0.375, "grossWeightLb": 8780.0,
      "payoffPosition": 2, "status": "PreCheckedIn",
      "isWelded": false, "footageRunToDate": 0.0
    },
    {
      "plannedSeqno": 3, "rodSeqno": null, "rodAlpha": "R00045", "alloy": "1100",
      "temper": "F", "diameterIn": 0.375, "grossWeightLb": 8690.0,
      "payoffPosition": null, "status": "Available",
      "isWelded": false, "footageRunToDate": 0.0
    }
  ],
  "success": true
}
```

**`status` values:** `Available` · `PreCheckedIn` · `Welded`

**Two sequences, and they are allowed to disagree.** `plannedSeqno` is the order planning intended; `rodSeqno` is the order the rod was actually staged in. An `Available` row has **`rodSeqno: null`** — it has not been processed, so it has no actual position yet. A processed row carries both, and `rodSeqno < plannedSeqno` (as above: planned 1st, run 2nd) is a normal, non-exceptional outcome.

**Planned order is authorised, not enforced.** Rods may be run out of planned order — `R00045 → R00043 → R00044` is legitimate — but `POST /staging/rod` **notifies and requires supervisor authorisation** when the rod is not the one planning expects next. It must never *refuse* on that ground, and this endpoint must not omit or disable later-planned rods: they stay listed and stageable, just gated. The row whose `plannedSeqno` is lowest among `Available` rods is the expected one.

**Ordering.** Rows sort by `rodSeqno` where present (the actual run order, which is what the traveler documents), then by `plannedSeqno` for unprocessed rod.

**Empty on a cold line.** The queue is a projection of *an order's* rod list, so with no order established it returns `[]`. `GET /linestatus` reports `activeOrderId: null` while a line is `Idle`, and the station must not display an order it has not started. The first rod staged or checked in resolves the order from `planning_routings`, and the rest of that order's rod appears here.

**Source.** This is a **derived projection, not a stored queue** — there is no `RodQueue` table and there must not be one. `PreCheckedIn`/`Welded` rows come from `RodStaging`; `Available` rows are resolved at request time from **`planning_routings`** (rod→order, written by planning at allocation) for the established order, filtered to rod whose `coils.coil_status` is not `INFLAT`/`COMPLETE`/`HOLD`/`SCRAP` and which has no `RodStaging` row with `Status = 'Staged'`. Planning owns rod→order allocation and scheduling owns order→line; mirroring either into `FlatWireDB` would create a second source of truth with no event channel to keep it current, re-introducing exactly the problem `00-foundations.md` decision 3 avoided by making `coils` the single source of truth for rod material. Read across via the indexed-alpha + read-only-view route in **G17**.

> **Mapped (Jul 29 2026):** the rod→order side is **`planning_routings`**, written by planning at allocation and readable at pre-check-in / check-in; order→line comes from scheduling. Both live outside `FlatWireDB`, so this is a cross-DB read — use the indexed-alpha + read-only-view route in **G17**. Remaining work is the exact column names in `ual-database`, which is the **Tables (read)** entry still missing from `phase-04`.

`footageRunToDate` is included on every row so the UI can flag partial rods **before** staging, rather than surprising the operator with a forced carry-forward path mid-scan.

---

### POST `/api/v1/flatwire/checkin/rod`

Records FL1/FL3 rod check-in, writes pass schedule acknowledgment, and triggers PLC tag push. This is the most critical command in the system — all side effects must succeed atomically or the check-in is aborted.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "lineId": "FL1",
  "rodAlpha": "R00041",
  "payoffPosition": 1,
  "diameterMeasuredIn": 0.374,
  "grossWeightLb": 2000.0,
  "netWeightLb": 1980.0,
  "inspection": {
    "oxidation": "Pass",
    "surfaceDefects": "Pass",
    "waterStains": "Pass",
    "observationNotes": null
  },
  "passScheduleId": "PS-1100-FL1-003",
  "operatorId": "john.d",
  "orderId": "FW-00421"
}
```

**Side Effects (all must succeed — roll back on any failure):**

1. Rod status set to `INFLAT`
2. Pass schedule acknowledgment record written
3. `PLCTagService.PushPassSchedule(passScheduleId, lineId, payoffPosition)` — all OPC tag writes
4. Run timer started
5. `LineStatus` SignalR event broadcast → `{ lineId: "FL1", status: "Running" }`
6. **If the rod was pre-checked-in, the staged row is *consumed*** — `RodStaging.Status → 'CheckedIn'`, `CheckedInAt` and `RodCheckinId` set — and `PayoffStateChanged` is broadcast with `state: "Active"`. Check-in never creates a parallel staging record.

> **Scanning an unstaged rod straight into check-in remains valid.** Pre-check-in is a `Should`
> priority in the SRS, not a `Must`, and the dual-payoff continuous-feed workflow is what makes it
> worthwhile — it is not a gate on check-in. Where a staged row *does* exist, `payoffPosition` in
> this request must match `RodStaging.PayoffPosition`; a mismatch is a `409`.

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0042",
    "lineId": "FL1",
    "rodAlpha": "R00041",
    "passScheduleId": "PS-1100-FL1-003",
    "checkedInAt": "2026-04-30T06:14:00Z",
    "plcTagsPushed": true
  },
  "success": true
}
```

**Response `409 Conflict`:** Line already has an active run.

**Response `422 Unprocessable Entity`:** Pass schedule is in `Draft` status (cannot be acknowledged).

**Response `500 Internal Server Error`:** PLC tag push failed — check-in aborted, all state rolled back.

**C# Request DTO:**

```csharp
public record CheckInRodCommand(
    string LineId,
    string RodAlpha,
    PayoffPosition PayoffPosition,
    decimal DiameterMeasuredIn,
    decimal GrossWeightLb,
    decimal NetWeightLb,
    InspectionDto Inspection,
    string PassScheduleId,
    string OperatorId,
    string OrderId) : IRequest<CheckInRodResponse>;

public record InspectionDto(
    string Oxidation,       // "Pass" | "Fail"
    string SurfaceDefects,  // "Pass" | "Fail"
    string WaterStains,     // "Pass" | "Fail"
    string? ObservationNotes);
```

---

### POST `/api/v1/flatwire/checkin/spool`

Records FL2 spool check-in and pushes FL2-specific PLC tags.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "lineId": "FL2",
  "spoolAlpha": "SP-00021",
  "gaugeMeasuredIn": 0.126,
  "widthMeasuredIn": 0.877,
  "grossWeightLb": 850.0,
  "netWeightLb": 840.0,
  "passScheduleId": "PS-1100-FL2-001",
  "operatorId": "jane.s",
  "orderId": "FW-00421"
}
```

**Side Effects:** Same pattern as `/checkin/rod` but uses FL2-specific component tags.

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0043",
    "lineId": "FL2",
    "spoolAlpha": "SP-00021",
    "passScheduleId": "PS-1100-FL2-001",
    "checkedInAt": "2026-04-30T07:00:00Z",
    "plcTagsPushed": true
  },
  "success": true
}
```

---

### GET `/api/v1/flatwire/spools`

**Added 2 Aug 2026 for Dashboard 5A (FL2 Spool Queue).** One endpoint, two modes — the response
shape is identical in both, so the screen has one renderer.

| Call | Meaning |
|---|---|
| `GET /spools` | Every spool **available for processing, irrespective of order**. `order` is `null`. |
| `GET /spools?spoolAlpha=SP-00031` | **The backend resolves that spool's order** and returns the order context plus **only that order's spools**. |

**Auth:** Bearer JWT — any authenticated role (read-only).

**Query parameters:**

| Name | Type | Notes |
|---|---|---|
| `spoolAlpha` | string | Optional. When present the backend resolves the order. |

**Response 200:**

```json
{
  "data": {
    "scannedAlpha": "SP-00031",
    "order": {
      "orderNo": "FW-00421",
      "customer": "Daddario",
      "alloy": "1100",
      "temper": "O",
      "setupGaugeIn": 0.110,
      "setupWidthIn": 0.630,
      "dueDate": "2026-07-21"
    },
    "spools": [
      {
        "alpha": "SP-00031",
        "orderNo": "FW-00421",
        "sourceRunId": "RUN-0117",
        "sourceRodAlphas": ["R00041", "R00042"],
        "gaugeIn": 0.113,
        "widthIn": 0.640,
        "netWeightLb": 3200.0,
        "originRouteMode": "Standalone",
        "status": "RECEIVED",
        "eligible": true
      }
    ]
  },
  "success": true,
  "errors": []
}
```

**Contract notes — each of these is easy to get wrong:**

- **`order` is `null` in two different situations** and both are `200`: the unfiltered default view,
  and a scanned spool whose `OrderNo` is null. In the second case `spools` contains **just that
  spool**, so the client renders one shape either way.
- **`404` only for an unknown `spoolAlpha`.** An unallocated spool is **not** an error — planning
  remainders and supervisor-accepted partial spools legitimately have no order, and the screen shows
  them differently from a bad scan.
- **`gaugeIn`/`widthIn` must be read from the source FL1 run**, not from `Spool.GaugeIn`/`WidthIn` —
  those are documented *"set at FL2/FL3 check-in"* and are therefore **null for every row this
  endpoint returns**.
- **`sourceRodAlphas` is a list and must come from `CoilTraceability`/`WeldEvent`.** `Spool` carries
  only two single-valued rod FKs (`ParentRodAlpha`, `SourceRodAlpha`); a spool with a mid-run weld
  has more than one source rod.
- **The `order` block is a cross-database read** — order attributes live in the shared
  order/scheduling schema, not `FlatWireDB`, on the same unenforced-link basis as rod alphas.
- **`eligible` encodes the availability rule, which is undefined (OQ-17).** The proposal is
  `RECEIVED` + `STAGED`; `HOLD` is returned but not eligible. Do not hard-code this silently.
- **Add an index on `Spool.OrderNo`.** It is unindexed today, and the `spoolAlpha` mode is a
  `WHERE OrderNo = …` on a `VARCHAR(50)`.
- No pagination — the list scrolls, consistent with every other list in the suite.

**Blocks:** Dashboard 5A. **Also serves Dashboard 5**, whose scan field currently validates against
nothing because `POST /checkin/spool` was the only spool endpoint.

---

### GET `/api/v1/flatwire/run/active?line={lineId}`

Returns the active run for a given line. Used by Dashboard 3 on load and resume.

**Auth:** Bearer JWT — any authenticated role

**Query Parameters:** `line` — `FL1`, `FL2`, or `FL3` (required)

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0042",
    "lineId": "FL1",
    "orderId": "FW-00421",
    "alloy": "1100",
    "passScheduleId": "PS-1100-FL1-003",
    "targetGauge": 0.125,
    "gaugeTolerance": 0.003,
    "targetWidth": 0.875,
    "widthTolerance": 0.005,
    "routeMode": "Standalone",
    "status": "Running",
    "startedAt": "2026-04-30T06:14:00Z",
    "pausedAt": null,
    "footageFt": 3840,
    "payoffs": [
      { "position": 1, "alpha": "R00041", "weightLb": 1240.0, "percentRemaining": 62.0 },
      { "position": 2, "alpha": null, "weightLb": 0.0, "percentRemaining": 0.0, "status": "NotLoaded" }
    ],
    "weldEvents": [
      {
        "weldEventId": "WLD-001",
        "outgoingAlpha": "R00040",
        "incomingAlpha": "R00041",
        "footagePosition": 1850,
        "timestamp": "2026-04-30T06:50:00Z"
      }
    ],
    "components": [
      { "componentName": "DB1", "state": "Active", "currentValue": 0.310 },
      { "componentName": "DB2", "state": "Active", "currentValue": 0.260 },
      { "componentName": "FM1", "state": "Active", "currentValue": 0.126 }
    ]
  },
  "success": true
}
```

**Response `204 No Content`:** No active run on this line.

---

### GET `/api/v1/flatwire/run/{runId}/gaugetrace`

Returns historical gauge readings for a completed or FL2 incoming run. Used by Dashboard 5 (FL2 spool check-in historical chart).

**Auth:** Bearer JWT — any authenticated role

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `from` | `int?` | Start footage position (default 0) |
| `to` | `int?` | End footage position (default: end of run) |
| `resolution` | `int?` | Sample every N readings (default 1 = all) |

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0041",
    "lineId": "FL1",
    "targetGauge": 0.125,
    "upperLimit": 0.128,
    "lowerLimit": 0.122,
    "readings": [
      { "footage": 0,    "gauge": 0.124, "inSpec": true },
      { "footage": 10,   "gauge": 0.126, "inSpec": true },
      { "footage": 20,   "gauge": 0.131, "inSpec": false }
    ],
    "weldMarkers": [
      { "footage": 1850, "incomingAlpha": "R00041" }
    ],
    "totalReadings": 1920,
    "outOfSpecCount": 14
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/run/{runId}/pause`

Pauses an active run. Freezes footage counter and broadcasts `LineStatus` event.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "reasonCode": "GaugeWidthInvestigation",
  "reasonCategory": "QualityMeasurement",
  "notes": "Gauge reading drifted high — investigating FM1 roll gap"
}
```

**Reason Categories and Codes:**

| Category | Codes |
|---|---|
| `EquipmentMechanical` | `DieChangeMidRun`, `RollAdjustment`, `LubricationCoolant`, `DrawBoxInspection`, `ComponentInspection` |
| `MaterialHandling` | `Payoff2LoadingWeld`, `DownstreamBlockage` |
| `QualityMeasurement` | `GaugeWidthInvestigation`, `ManualSpcMeasurement`, `SurfaceInspection` |
| `Operational` | `OperatorBreak`, `ShiftChangeover`, `AwaitingSupervisor` |
| `Safety` | `SafetyObservation` |
| `Other` | `Other` (requires `notes`) |

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0042",
    "pausedAt": "2026-04-30T07:10:00Z",
    "footageAtPause": 3840
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/run/{runId}/resume`

Resumes a paused run. One of four outcomes must be specified.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "outcome": "ResumeRun",
  "activityCompleted": "Adjusted FM1 roll gap; gauge back in spec"
}
```

**Outcome Values:**

| Outcome | Effect |
|---|---|
| `ResumeRun` | Run timer restarts; PLC tags restored; Dashboard 3 active |
| `LogWipRejection` | Pause closed; Dashboard 8 auto-opened with pause context |
| `ContinuePause` | Dialog dismissed; line remains paused |
| `CheckOutRod` | Pause closed; Dashboard 12 Mode B flow initiated |

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0042",
    "outcome": "ResumeRun",
    "resumedAt": "2026-04-30T07:22:00Z",
    "pauseDurationSeconds": 720
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/spc`

Records a manual SPC checkpoint measurement set. Called from Dashboard 6.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "checkpointType": "PostDieChange",
  "footagePosition": 3840,
  "operatorId": "john.d",
  "triggerDescription": "DB2 die changed from 0.310\" → 0.308\"",
  "measurements": [
    { "name": "WireDiameterPostDraw", "targetValue": 0.260, "actualValue": 0.261 },
    { "name": "FM1Gauge",             "targetValue": 0.125, "actualValue": 0.126 },
    { "name": "FM1Width",             "targetValue": 0.875, "actualValue": 0.874 }
  ]
}
```

**Measurement Names by Checkpoint Type:**

| Checkpoint Type | Measurement Names |
|---|---|
| `PreRun` | `IncomingRodDiameter` |
| `PostDieChange` | `WireDiameterPostDraw`, `FM1Gauge`, `FM1Width` |
| `ManualSpotCheck` | `FM1Gauge`, `FM1Width` |
| `PostRun` | `FinalGauge`, `FinalWidth` |

**Response `200 OK`:**

```json
{
  "data": {
    "checkpointId": "SPC-0041",
    "allInSpec": false,
    "results": [
      { "name": "WireDiameterPostDraw", "inSpec": true,  "deviation": 0.001 },
      { "name": "FM1Gauge",             "inSpec": true,  "deviation": 0.001 },
      { "name": "FM1Width",             "inSpec": true,  "deviation": -0.001 }
    ]
  },
  "success": true
}
```

---

---

## SPRINT 4 — Events, Completion & Special Cases APIs

**Needed by:** Sprint S4 of the shopfloor workstream
**Blocks:** Dashboard 4, 7, 8, 11, 12, Die Change screen

---

### POST `/api/v1/flatwire/weldevent`

Records a weld join between two rods. Updates traceability chain for the active run.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "outgoingRodAlpha": "R00041",
  "incomingRodAlpha": "R00042",
  "footagePosition": 3840,
  "weldType": "InductionWeld",
  "weldQuality": "Pass",
  "weldQualityFailReason": null,
  "operatorId": "john.d"
}
```

**Weld Types:** `InductionWeld` (rod-to-rod), `LaserWeld` (flat-to-flat)
**Weld Quality:** `Pass`, `Fail`. **`weldQualityFailReason` is required when `weldQuality` is `Fail`** —
`CK_WeldEvent_FailReason` / `WLD013`.

**`weldQualityFailReason` values** (the same six offered on Dashboard 4 and Dashboard 2A):
`Misalignment at join` · `Weld break on inspection` · `Surface burn / scorching` · `Weld not fully fused` ·
`Diameter mismatch at join` · `Other — see observation`

> **This is the single weld write.** `POST /staging/rod/mark-welded` is **retired** (see above). Both
> Dashboard 2A's Mark as welded dialog and Dashboard 4 post here, so one physical join produces one record
> whichever screen captured it.

**Side Effects:**
- `WeldEvent` row written with both alphas, footage position, weld type, **quality**, operator, timestamp
- **`RodStaging` weld columns set — on a `Pass` result only** (see below)
- All subsequent output footage linked to `incomingRodAlpha`
- `PayoffWeight` SignalR event re-established for new payoff position
- `PayoffStateChanged` broadcast — `isWelded: true` on a Pass; on a Fail the bay state is unchanged
- Weld marker queued for gauge trace chart

**The `RodStaging` write is conditional on quality:**

| `weldQuality` | `WeldEvent` row | `RodStaging.IsWelded` / `WeldedAt` / `WeldedBy` | Bay state |
|---|---|---|---|
| **`Pass`** | Written | **Set**, in the same transaction | `Staged` → welded; transition awaits 0 ft remaining |
| **`Fail`** | Written | **Not set** — left as they were | Stays **staged and un-welded**; the weld must be remade |

> **Why a failed weld does not mark the rod welded.** The join did not hold, so the rod is not joined to the
> running rod and the line cannot transition through it. Recording the failure and *also* flagging the rod as
> welded would assert a continuous feed that does not physically exist. The failed attempt is still written —
> it happened, it consumed footage, and it is a certificate-relevant event — but the bay keeps reading "not yet
> welded" and Mark as welded stays available for the remake.
>
> **Consequence: several `WeldEvent` rows may describe one physical join** (a failed attempt, then the remake).
> `CoilTraceability` attributes output footage to source rods *per weld boundary*, and two rows at nearly the
> same footage is a case nothing currently specifies. This is **OI-59** (re-weld on the certificate), which now
> arises two ways; the footage-attribution half is **Q6**.

**Response `200 OK`:**

```json
{
  "data": {
    "weldEventId": "WLD-002",
    "runId": "RUN-0042",
    "footagePosition": 3840,
    "outgoingAlpha": "R00041",
    "incomingAlpha": "R00042",
    "weldQuality": "Pass",
    "isWelded": true,
    "timestamp": "2026-04-30T08:00:00Z"
  },
  "success": true
}
```

`isWelded` reports the resulting `RodStaging` state, so the client never has to infer it from the quality —
`false` on a `Fail`.

**Response `422 Unprocessable Entity`:**
- `weldQuality` is `Fail` and `weldQualityFailReason` is missing or empty (`WLD013`)
- Alloy, temper or diameter of the two rods do not match (`WLD006`)

**Response `409 Conflict`:** no rod is staged on the idle bay, or the staged rod is already welded.

---

### GET `/api/v1/flatwire/run/{runId}/weldevents`

Every weld recorded against one run, oldest first. Backs the **Welds this run** read-only dialog on
Dashboard 2A (`PCI021`), opened from the **active bay card** — so the caller always has a `runId` and
this is never called without one. An **empty array is a normal response** and renders as the dialog's
empty state; the control stays enabled at a count of zero.

**Auth:** Bearer JWT — any authenticated role. **Read-only: there is no PUT, PATCH or DELETE
counterpart.** A recorded weld is a certificate input; reversing one in place is `WLD011`, which no
document specifies.

> **Why this is not served from `GET /run/active`.** That endpoint already returns a `weldEvents[]`
> array, but a deliberately trimmed one — id, both alphas, footage, timestamp — which feeds Dashboard 3's
> gauge-trace weld markers. It carries **no quality, operator or weld type**, which is most of what an
> operator opens this list to see. Widening it would push chart-marker payload onto every Dashboard 3
> poll. Dashboard 2A does not call `/run/active` at all, so a run-scoped resource is the cheaper split.
> Leave `/run/active.weldEvents` as it is.

**Path Parameters:** `runId` — e.g. `RUN-0418`

**Response `200 OK`:**

```json
{
  "data": {
    "runId": "RUN-0418",
    "lineId": "FL1",
    "totalCount": 2,
    "failedCount": 1,
    "weldEvents": [
      {
        "weldEventId": "WLD-002",
        "outgoingAlpha": "R00040",
        "incomingAlpha": "R00041",
        "outgoingPayoffPosition": 1,
        "incomingPayoffPosition": 2,
        "footagePosition": 4120,
        "weldType": "InductionWeld",
        "weldQuality": "Pass",
        "weldQualityFailReason": null,
        "operatorId": "j.alvarez",
        "timestamp": "2026-07-31T06:48:00Z"
      },
      {
        "weldEventId": "WLD-003",
        "outgoingAlpha": "R00041",
        "incomingAlpha": "R00042",
        "outgoingPayoffPosition": 2,
        "incomingPayoffPosition": 1,
        "footagePosition": 9860,
        "weldType": "InductionWeld",
        "weldQuality": "Fail",
        "weldQualityFailReason": "Weld not fully fused — cut back and remade",
        "operatorId": "j.alvarez",
        "timestamp": "2026-07-31T09:22:00Z"
      }
    ]
  },
  "success": true
}
```

**Response `200 OK` with an empty array:** the run exists but no weld has been recorded yet — a normal
state for a run that has not yet reached its first payoff handover. **Not a `404`.**

**Response `404 Not Found`:** no run with this `runId`.

**Notes:**

- Ordered by `footagePosition` ascending, which is also chronological within a run.
- `weldQualityFailReason` is non-null exactly when `weldQuality = 'Fail'` — enforced at write time by
  `CK_WeldEvent_FailReason` (`WLD013`), so a consumer may rely on it and must render it.
- No paging. A run carries a handful of welds — one per rod handover — so `RunId` alone bounds the set.
- Rendered by the client oldest-first so the footage progression reads down the list.

---

### POST `/api/v1/flatwire/rolloverride`

Records a run-level roll gap override and writes updated PLC tags. Does NOT modify the pass schedule record.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "alpha": "R00041",
  "footagePosition": 3840,
  "operatorId": "john.d",
  "reasonCode": "GaugeDriftHigh",
  "notes": null,
  "measuredGaugeIn": 0.128,
  "measuredWidthIn": 0.876,
  "adjustments": [
    {
      "componentName": "FM1",
      "scheduledValue": 0.128,
      "newValue": 0.126
    }
  ]
}
```

**Reason Codes:** `GaugeDriftHigh`, `GaugeDriftLow`, `WidthDrift`, `SpcFlag`, `RollWear`, `PostWeldCorrection`, `OperatorDiscretion`

**Side Effects:**
- Override record written per component with `OldValue`, `NewValue`, `Reason`, `FootagePosition`
- `PLCTagService` writes updated tag for each adjusted component
- SPC checkpoint written (type: `RollAdjustTrigger`) at the footage position

**Response `200 OK`:**

```json
{
  "data": {
    "overrides": [
      {
        "overrideId": "OVR-0042",
        "componentName": "FM1",
        "oldValue": 0.128,
        "newValue": 0.126,
        "delta": -0.002,
        "plcTagWritten": true
      }
    ],
    "spcCheckpointId": "SPC-0042"
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/diechange`

Records a die change event and triggers a Post Die Change SPC checkpoint.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "alpha": "R00041",
  "footagePosition": 3840,
  "operatorId": "john.d",
  "diePosition": "DB2",
  "oldDieSizeIn": 0.310,
  "newDieSizeIn": 0.308,
  "reasonCode": "GaugeDrift"
}
```

**Die Positions:** `DB1`, `DB2`

**Reason Codes:** `DieWear`, `GaugeDrift`, `Breakage`, `ScheduledChange`, `SizeChangeForProduct`

**Side Effects:**
- Die change event written against run and footage position
- Pass schedule override record written for the die size change
- Dashboard 6 (SPC Checkpoint) automatically triggered in `PostDieChange` mode

**Response `200 OK`:**

```json
{
  "data": {
    "dieChangeId": "DC-0041",
    "overrideId": "OVR-0043",
    "spcCheckpointRequired": true,
    "spcCheckpointMode": "PostDieChange"
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/checkout`

Checks out a rod from a payoff position. Supports both Mode A (pre-run, footage = 0) and Mode B (mid-run, footage > 0).

**Auth:** Bearer JWT — Operator or above (Mode B may require supervisor approval — see OQ-74)

**Request Body:**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "rodAlpha": "R00041",
  "payoffPosition": 1,
  "mode": "ModeA",
  "footageAtCheckout": 0,
  "reasonCode": "WrongRod",
  "rodDisposition": "ReturnToFloorStorage",
  "remainingWeightLbEstimate": null,
  "inProcessMaterialDisposition": null,
  "operatorId": "john.d"
}
```

**Mode A Reason Codes:** `WrongRodMisScan`, `OrderCancelledDeferred`, `FailedReInspection`, `RelocatedToLine`, `Other`

**Mode B Reason Codes:** `EquipmentFailure`, `QualityHold`, `OrderQuantityReached`, `ShiftDeferral`, `Other`

**Rod Disposition (Mode A):** `ReturnToFloorStorage` → status `STAGED`, `ReturnToWarehouse` → status `RECEIVED`

**Rod Disposition (Mode B):** `HoldReturnToStorage`, `Scrap`, `DeferContinueLater`

**In-Process Material Disposition (Mode B only):** `HoldPendingSupervisor`, `Scrap`, `AcceptAsPartialRun`

**Side Effects:**
- Pass schedule acknowledgment voided (Mode A)
- `PLCTagService.ClearPayoffTags(lineId, payoffPosition)` called
- Rod status updated per disposition
- Partial spool alpha generated if `inProcessMaterialDisposition = AcceptAsPartialRun` (Mode B)
- `LineStatus` SignalR event broadcast → `Idle`

**Response `200 OK`:**

```json
{
  "data": {
    "checkoutId": "CO-0041",
    "lineId": "FL1",
    "rodAlpha": "R00041",
    "newRodStatus": "STAGED",
    "plcTagsCleared": true,
    "partialSpoolAlpha": null
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/wipreject`

Records a WIP rejection, updates material status, and broadcasts a supervisor alert.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "lineId": "FL1",
  "materialAlpha": "R00041",
  "stage": "FL1ActiveRun",
  "footagePosition": 3840,
  "rejectionGroup": "Dimensional",
  "rejectionReason": "GaugeOutOfSpec",
  "measuredValue": 0.131,
  "targetMin": 0.122,
  "targetMax": 0.128,
  "disposition": "Suspend",
  "observationNotes": "Gauge spiked after weld — FM1 roll may need inspection",
  "operatorId": "john.d",
  "runId": "RUN-0042"
}
```

**Rejection Groups and Reasons:**

| Group | Reasons |
|---|---|
| `SurfaceQuality` | `Oxidation`, `WaterStain`, `SurfaceDefect`, `Scratch`, `Pit` |
| `Dimensional` | `GaugeOutOfSpec`, `WidthOutOfSpec`, `EdgeBurr`, `Camber` |
| `WeldQuality` | `WeldFailure`, `WeldBreakMidRun` |
| `Material` | `ChemistryNonConformance`, `WrongAlloy`, `TemperIncorrect` |
| `Process` | `DieFailure`, `RollGapError`, `ComponentFault` |

**Disposition:** `Suspend` → `HOLD`, `Scrap` → `SCRAP`, `Rework` → flagged for rework

**Side Effects:**
- Alpha status updated to `HOLD` or `SCRAP`
- WIP Held queue updated
- `AlertRaised` SignalR event broadcast to Dashboard 1
- **When the material is a rod staged at a payoff bay** (`stage: "FL1PreCheckIn"` — a failed staging inspection): the `RodStaging` row is **released** — `Status → 'Unstaged'`, `UnstageKind = 'WipRejection'`, `WipRejectionId` set to this rejection — and `PayoffStateChanged` is broadcast with `state: "NotStaged"`. **This is what clears a `Blocked` bay** (`Q23` item 3, decided 30 Jul 2026); nothing else does

**Response `200 OK`:**

```json
{
  "data": {
    "rejectionId": "REJ-0041",
    "materialAlpha": "R00041",
    "newStatus": "HOLD",
    "alertBroadcast": true
  },
  "success": true
}
```

---

### POST `/api/v1/flatwire/coil/complete`

Completes a coil run: generates output coil alpha, records source traceability, manages skid assignment, and marks the run complete.

**Auth:** Bearer JWT — Operator or above

**Request Body:**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL2",
  "grossWeightLb": 900.0,
  "netWeightLb": 885.0,
  "finalGaugeMeasuredIn": 0.126,
  "finalWidthMeasuredIn": 0.876,
  "skidAssignment": "Coil1Of2",
  "existingSkidId": null,
  "operatorId": "jane.s"
}
```

**Skid Assignment Values:** `Coil1Of2` (skid remains open), `Coil2Of2` (skid closed and finalized)

**Side Effects:**
- Output coil alpha generated (format: `FW-00421-C01`)
- Source traceability table populated (rod alpha → footage range per weld boundary)
- Coil status → `COMPLETE`
- If `Coil2Of2`: skid record finalized, skid appears in packing queue
- Run marked complete; Dashboard 3 shows "Run Complete"
- `LineStatus` SignalR event broadcast → `Idle`

**Response `200 OK`:**

```json
{
  "data": {
    "coilAlpha": "FW-00421-C01",
    "skidId": "SKD-0021",
    "skidStatus": "Open",
    "footageTotal": 3840,
    "netWeightLb": 885.0,
    "sourceTraceability": [
      { "rodAlpha": "R00040", "footageFrom": 0,    "footageTo": 1850 },
      { "rodAlpha": "R00041", "footageFrom": 1851, "footageTo": 3840 }
    ],
    "finalSpc": {
      "gaugeInSpec": true,
      "widthInSpec": true
    }
  },
  "success": true
}
```

---

### GET `/api/v1/flatwire/coil/{alpha}/label`

Returns all data needed to render and print the physical coil label. Called by Dashboard 7.

**Auth:** Bearer JWT — Operator or above

**Response `200 OK`:**

```json
{
  "data": {
    "coilAlpha": "FW-00421-C01",
    "alloy": "1100",
    "gaugeDiameterIn": 0.125,
    "widthIn": 0.875,
    "temper": "O",
    "grossWeightLb": 900.0,
    "netWeightLb": 885.0,
    "footageFt": 3840,
    "lotNumber": "LOT-2026-042",
    "sourceRodAlphas": ["R00040", "R00041"]
  },
  "success": true
}
```

---

---

## SPRINT 5 — Shift Summary API

**Needed by:** Sprint S5 of the shopfloor workstream
**Blocks:** Dashboard 10

---

### GET `/api/v1/flatwire/shiftsummary`

Returns aggregated shift performance data across all three lines.

**Auth:** Bearer JWT — Supervisor or above

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `shift` | `string` | `Day`, `Afternoon`, `Night` |
| `date` | `string` | ISO date `YYYY-MM-DD` (defaults to today) |
| `line` | `string?` | Optional filter: `FL1`, `FL2`, `FL3` (default: all) |

**Response `200 OK`:**

```json
{
  "data": {
    "shift": "Day",
    "date": "2026-04-30",
    "shiftStartUtc": "2026-04-30T06:00:00Z",
    "shiftEndUtc": "2026-04-30T14:00:00Z",
    "throughput": {
      "ordersRun": 3,
      "totalFootageFt": 11520,
      "totalWeightLb": 2655.0,
      "coilsOut": 2,
      "skidsCompleted": 1
    },
    "quality": {
      "spcPassRatePct": 94.4,
      "wipRejections": 1,
      "rejectionBreakdown": [
        { "reason": "GaugeOutOfSpec", "count": 1 }
      ],
      "suspendedMaterialCount": 1
    },
    "lineUtilisation": [
      {
        "lineId": "FL1",
        "utilisationPct": 87.5,
        "totalDowntimeMinutes": 60,
        "downtimeByCategory": [
          { "category": "QualityMeasurement", "minutes": 30 },
          { "category": "EquipmentMechanical", "minutes": 30 }
        ]
      },
      {
        "lineId": "FL2",
        "utilisationPct": 75.0,
        "totalDowntimeMinutes": 120,
        "downtimeByCategory": []
      },
      {
        "lineId": "FL3",
        "utilisationPct": 0.0,
        "totalDowntimeMinutes": 0,
        "downtimeByCategory": []
      }
    ],
    "weldEvents": {
      "totalCount": 3,
      "byLine": [
        { "lineId": "FL1", "count": 2 },
        { "lineId": "FL2", "count": 1 }
      ],
      "events": [
        {
          "lineId": "FL1",
          "outgoingAlpha": "R00040",
          "incomingAlpha": "R00041",
          "footagePosition": 1850,
          "quality": "Pass",
          "operatorId": "john.d",
          "timestamp": "2026-04-30T06:50:00Z"
        }
      ]
    },
    "materialStatus": {
      "rodsInStorage": 12,
      "spoolsOnFloor": 1,
      "coilsInPacking": 2,
      "wipHeld": 1,
      "scrappedToday": 0
    }
  },
  "success": true
}
```

---

---

## SignalR Hub Contract — `FlatWireHub`

**Hub URL:** `/hubs/flatwire`
**Auth:** Bearer JWT passed as query parameter `?access_token=...`

### Client → Server Methods

| Method | Payload | Description |
|---|---|---|
| `JoinLineGroup` | `{ "lineId": "FL1" }` | Subscribe to all events for FL1, FL2, or FL3 |
| `LeaveLineGroup` | `{ "lineId": "FL1" }` | Unsubscribe from line group |

### Server → Client Events

All events are scoped to a line group (`FL1Data`, `FL2Data`, `FL3Data`).

#### `GaugeReading`
```json
{
  "lineId": "FL1",
  "value": 0.126,
  "timestamp": "2026-04-30T07:15:00Z",
  "footagePosition": 3840
}
```
> FL2 emits `null` for value when idle (no live AGC feed in standalone mode).

#### `WidthReading`
```json
{
  "lineId": "FL1",
  "value": 0.877,
  "timestamp": "2026-04-30T07:15:00Z",
  "footagePosition": 3840
}
```

#### `SpeedFPM`
```json
{
  "lineId": "FL1",
  "value": 142.5,
  "timestamp": "2026-04-30T07:15:00Z"
}
```

#### `PayoffWeight`
```json
{
  "lineId": "FL1",
  "position": 1,
  "weightLb": 1240.0,
  "percentRemaining": 62.0
}
```

#### `PayoffStateChanged`
```json
{
  "lineId": "FL1",
  "position": 2,
  "state": "Staged",
  "rodAlpha": "R00043",
  "rodSeqno": 2,
  "isWelded": false
}
```

Bay **occupancy** changes: pre-check-in, pre-check-out, Mark-as-Welded, and check-in consuming a staged row. `state` is `NotStaged` · `Staged` · `Active` · `Blocked`.

> **Rare domain event — send immediately, unbatched.** Per `00-foundations.md` §0.4 this must
> **not** enter the ~100 ms / 10 Hz telemetry batch: a bay changing hands is an operator-visible
> state transition, not a sampled reading. `PayoffWeight` above stays in the batched hot path;
> these two are complementary and both are needed by Dashboard 2A — occupancy from here, live
> weight from `PayoffWeight`.

#### `ComponentStatus`
```json
{
  "lineId": "FL1",
  "component": "FM1",
  "isActive": true,
  "currentValue": 0.126
}
```

#### `LineStatus`
```json
{
  "lineId": "FL1",
  "status": "Running",
  "orderId": "FW-00421",
  "alpha": "R00041"
}
```

#### `AlertRaised`
```json
{
  "lineId": "FL1",
  "alertType": "GaugeOutOfSpec",
  "severity": "Warning",
  "message": "Gauge 0.131\" exceeds upper limit 0.128\"",
  "timestamp": "2026-04-30T07:02:11Z"
}
```

#### `AlertCleared`
```json
{
  "lineId": "FL1",
  "alertType": "GaugeOutOfSpec"
}
```

### Angular Service Observable Map

```typescript
// FlatWireSignalRService exposes typed Observables:
gaugeReading$(lineId: string): Observable<GaugeReadingEvent>
widthReading$(lineId: string): Observable<WidthReadingEvent>
speedFpm$(lineId: string): Observable<SpeedFpmEvent>
payoffWeight$(lineId: string): Observable<PayoffWeightEvent>
payoffStateChanged$(lineId: string): Observable<PayoffStateChangedEvent>
componentStatus$(lineId: string): Observable<ComponentStatusEvent>
lineStatus$(lineId: string): Observable<LineStatusEvent>
alertRaised$(lineId: string): Observable<AlertRaisedEvent>
alertCleared$(lineId: string): Observable<AlertClearedEvent>
```

---

---

## Sprint Delivery Schedule

| Sprint | Endpoints to Publish as Stub | Real Implementation Due |
|---|---|---|
| S1 | `GET /lines/status`, SignalR hub skeleton | S1 |
| S2 | `GET /passschedule`, `GET /passschedule/{id}`, `POST /passschedule`, `PUT /passschedule/{id}`, `PATCH /passschedule/{id}/status`, `POST /passschedule/generate`, `GET /rod/{alpha}`, `POST /rod` | S2 |
| S3 | `POST /checkin/rod`, `POST /checkin/spool`, `GET /run/active`, `GET /run/{id}/gaugetrace`, `POST /run/{id}/pause`, `POST /run/{id}/resume`, `POST /spc`, `GET /payoff/status`, `POST /staging/rod`, `POST /staging/rod/unstage`, `GET /staging/queue`, `GET /run/{id}/weldevents` † | S3 |
| S4 | `POST /weldevent`, `POST /rolloverride`, `POST /diechange`, `POST /checkout`, `POST /wipreject`, `POST /coil/complete`, `GET /coil/{alpha}/label` | S4 |
| S5 | `GET /shiftsummary` | S5 |

> † **`GET /run/{id}/weldevents` is read-before-write.** It sits in S3 because its only consumer is
> Dashboard 2A, which is an S3 / phase-4 screen — but the rows it reads are written by `POST /weldevent`
> in **S4**. Until that lands it returns an empty array, which is a legitimate response (a run with no
> welds yet), so the screen is complete and reviewable at the phase-4 gate without pulling weld-event
> work forward. Populate the S3 stub with non-empty sample data so the list renders in review.

> **Stub protocol:** The backend team publishes an OpenAPI/Swagger stub (200 response with schema-valid dummy data, no database) at the start of each sprint. The shopfloor Angular team builds against the stub; stubs are replaced by real implementations as they land.

---

## Authorization Matrix

| Endpoint | Operator | Operations Manager | Maintenance | Supervisor | Admin |
|---|---|---|---|---|---|
| `GET /lines/status` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /passschedule` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /passschedule/{id}` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `POST /passschedule` | — | ✓ | ✓ | — | ✓ |
| `PUT /passschedule/{id}` | — | ✓ | ✓ | — | ✓ |
| `PATCH /passschedule/{id}/status` | — | ✓ | — | — | ✓ |
| `POST /passschedule/generate` | — | ✓ | ✓ | — | ✓ |
| `GET /rod/{alpha}` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `POST /rod` | — | — | — | ✓ | ✓ |
| `GET /payoff/status` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /staging/queue` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `POST /staging/rod` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /staging/rod/unstage` | ✓ | ✓ | — | ✓ | ✓ |
| ~~`POST /staging/rod/mark-welded`~~ | — | — | — | — | — | *(retired — use `POST /weldevent`)* |
| `POST /checkin/rod` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /checkin/spool` | ✓ | ✓ | — | ✓ | ✓ |
| `GET /spools` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /run/active` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /run/{id}/gaugetrace` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /run/{id}/weldevents` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `POST /run/{id}/pause` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /run/{id}/resume` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /spc` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /weldevent` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /rolloverride` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /diechange` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `POST /checkout` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /wipreject` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /coil/complete` | ✓ | ✓ | — | ✓ | ✓ |
| `GET /coil/{alpha}/label` | ✓ | ✓ | — | ✓ | ✓ |
| `GET /shiftsummary` | — | ✓ | — | ✓ | ✓ |

---

## Related Documents

| Document | Purpose |
|---|---|
| [ShopfloorAndRealTimePlan.md](ShopfloorAndRealTimePlan.md) | Shopfloor sprint plan — UI stories and SignalR architecture |
| [FlatWireJiraStories.md](FlatWireJiraStories.md) | Full backlog — main track stories (FW-010, FW-020 etc.) |
| [TechStackRecommendation.md](TechStackRecommendation.md) | Architecture decisions and microservice structure |
| [FlatWireOpenQuestions.md](../../Analysis/FlatWireOpenQuestions.md) | Open questions — OQ-10 (weight formula), OQ-74 (checkout auth), OQ-14 (pass schedule selection), OQ-15 (FL3 schedules) |
| [RodPreCheckin.md](../RequirementDocuments/RodPreCheckin.md) | Pre-check-in / payoff staging analysis — the requirement trace behind the `/staging/**` endpoints |
