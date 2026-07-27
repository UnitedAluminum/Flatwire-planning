# Flat Wire Mill — API Development Plan & Contracts

**Project:** Flat Wire Mill Implementation
**Last Updated:** April 30, 2026
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
enum ComponentName   { DB1, DB2, FM1, EdgeSet, FM2_8in, FM2_6inS1, FM2_6inS2, Edger }
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
        "componentName": "FM2_8in",
        "state": "Bypass",
        "parameterValue": null,
        "edgeType": null
      },
      {
        "componentName": "FM2_6inS1",
        "state": "Bypass",
        "parameterValue": null,
        "edgeType": null
      },
      {
        "componentName": "FM2_6inS2",
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
    { "componentName": "FM2_8in",  "state": "Bypass", "parameterValue": null,  "edgeType": null },
    { "componentName": "FM2_6inS1","state": "Bypass", "parameterValue": null,  "edgeType": null },
    { "componentName": "FM2_6inS2","state": "Active", "parameterValue": 0.125, "edgeType": null }
  ]
}
```

**Validation Rules:**
- `FM2_6inS2` must always be `Active` — reject `Bypass` or `Skip`
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
8. FM2 gaps:
     8"    = gauge × 1.06
     6"S1  = gauge × 1.02
     6"S2  = gauge × springbackFactor
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
      { "componentName": "FM2_8in",   "state": "Bypass", "parameterValue": null,  "edgeType": null },
      { "componentName": "FM2_6inS1", "state": "Bypass", "parameterValue": null,  "edgeType": null },
      { "componentName": "FM2_6inS2", "state": "Active", "parameterValue": 0.125, "edgeType": null }
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
    "receivedAt": "2026-04-29T14:00:00Z"
  },
  "success": true
}
```

**Response `404 Not Found`:** Rod alpha not found in the system.

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

**Side Effects:**
- Weld join event written with both alphas, footage position, operator, timestamp
- All subsequent output footage linked to `incomingRodAlpha`
- `PayoffWeight` SignalR event re-established for new payoff position
- Weld marker queued for gauge trace chart

**Response `200 OK`:**

```json
{
  "data": {
    "weldEventId": "WLD-002",
    "runId": "RUN-0042",
    "footagePosition": 3840,
    "outgoingAlpha": "R00041",
    "incomingAlpha": "R00042",
    "timestamp": "2026-04-30T08:00:00Z"
  },
  "success": true
}
```

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

**Auth:** Bearer JWT — Operator or above (Mode B may require supervisor approval — see OQ-48)

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
| S3 | `POST /checkin/rod`, `POST /checkin/spool`, `GET /run/active`, `GET /run/{id}/gaugetrace`, `POST /run/{id}/pause`, `POST /run/{id}/resume`, `POST /spc` | S3 |
| S4 | `POST /weldevent`, `POST /rolloverride`, `POST /diechange`, `POST /checkout`, `POST /wipreject`, `POST /coil/complete`, `GET /coil/{alpha}/label` | S4 |
| S5 | `GET /shiftsummary` | S5 |

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
| `POST /checkin/rod` | ✓ | ✓ | — | ✓ | ✓ |
| `POST /checkin/spool` | ✓ | ✓ | — | ✓ | ✓ |
| `GET /run/active` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `GET /run/{id}/gaugetrace` | ✓ | ✓ | ✓ | ✓ | ✓ |
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
| [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) | Open questions — OQ-36 (weight formula), OQ-48 (checkout auth), OQ-51 (pass schedule selection), OQ-52 (FL3 schedules) |
