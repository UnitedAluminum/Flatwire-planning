# Flat Wire Mill — Check-in Feature: Implementation Plan & Prompt

**Feature:** Dashboard 2 (Rod Check-in FL1/FL3) + Dashboard 5 (Spool Check-in FL2)
**Sprint:** S3 (Weeks 5–6)
**Stories:** FW-S3-009, FW-S3-012
**API Endpoints:** `POST /api/v1/flatwire/checkin/rod`, `POST /api/v1/flatwire/checkin/spool`
**Last Updated:** April 30, 2026
**Status:** Ready for implementation

---

## Scope

This plan covers the end-to-end implementation of both check-in flows with **stub/dummy data** — no live PLC or database required. The Angular library scaffold (FW-S1-001) and mock data service (FW-S1-002) are prerequisites; this plan assumes they are being built together as a combined Sprint S1+S3 kickoff.

The implementation delivers:
- `flat-wire` Angular library with routing, auth guard, and line context
- Mock data service toggled by environment flag
- Dashboard 2 — Rod Check-in (FL1/FL3) component
- Dashboard 5 — FL2 Spool Check-in component
- `FlatWire.API` .NET microservice with `CheckInController` (stub mode — returns dummy data, no DB, no PLC)
- Full request/response DTOs and command handlers wired through MediatR

---

## Prerequisites / Assumed Done Before This Work

| Requirement | Source |
|---|---|
| Angular shell has `/flat-wire` lazy route registered | Do in this task if not done |
| `ng-package.json` and `tsconfig` for the new library | Scaffolded via `ng generate library` |
| Existing UAL project conventions understood | See CLAUDE.md |

---

## Part 1 — Angular Library Scaffold (FW-S1-001 + FW-S1-002)

These are the foundation pieces. Build them first; the check-in components depend on them.

### 1.1 Library scaffold

Run:
```bash
cd c:/UAL/ual-angular
ng generate library flat-wire-shopfloor --prefix=fw
```

Expected output location: `projects/flat-wire-shopfloor/`

File structure to create manually after scaffold:

```
projects/flat-wire-shopfloor/src/lib/
├── flat-wire-shopfloor.module.ts
├── flat-wire-shopfloor-routing.ts
├── styles/
│   └── flat-wire-shopfloor.styles.scss     ← library-level stylesheet registered in angular.json
├── services/
│   ├── flat-wire-api.interface.ts          ← IFlatWireApiService interface
│   ├── flat-wire-api-real.service.ts       ← HTTP calls (empty stubs for now)
│   ├── flat-wire-api-mock.service.ts       ← Returns mock data
│   ├── flat-wire-signalr.service.ts        ← SignalR wrapper (stub Observables)
│   ├── line-context.service.ts             ← Which line (FL1/FL2/FL3) is active
│   └── run-state.service.ts                ← Active run state
├── models/
│   ├── rod.model.ts
│   ├── pass-schedule.model.ts
│   ├── active-run.model.ts
│   └── checkin.model.ts
├── guards/
│   ├── auth.guard.ts
│   └── role.guard.ts
└── components/
    ├── shared/
    │   ├── pass-schedule-table/
    │   └── alert-banner/
    ├── dashboard-2-rod-checkin/
    └── dashboard-5-spool-checkin/
```

### 1.2 CSS approach — custom design system, NOT Bootstrap

**The mockups at `C:\UAL\Flat Wire\Mockups\` are full HTML files with a bespoke CSS design system using CSS custom properties. The Angular implementation must replicate this design system exactly — Bootstrap is not used for this library.**

Register the library stylesheet in `angular.json` under the app's `styles` array:
```json
"projects/flat-wire-shopfloor/src/lib/styles/flat-wire-shopfloor.styles.scss"
```

The library stylesheet defines the design tokens and shared layout classes used across all flat-wire dashboards:

```scss
// flat-wire-shopfloor.styles.scss
:root {
  --fw-bg-primary:    #ffffff;
  --fw-bg-secondary:  #f5f4ee;
  --fw-bg-tertiary:   #efede5;
  --fw-bg-info:       #e6f1fb;
  --fw-bg-success:    #e1f5ee;
  --fw-bg-warning:    #faeeda;
  --fw-bg-danger:     #fcebeb;

  --fw-text-primary:   #1a1a19;
  --fw-text-secondary: #5f5e5a;
  --fw-text-tertiary:  #888780;
  --fw-text-info:      #0c447c;
  --fw-text-success:   #085041;
  --fw-text-warning:   #633806;
  --fw-text-danger:    #791f1f;

  --fw-border-faint:   rgba(0, 0, 0, 0.10);
  --fw-border-mid:     rgba(0, 0, 0, 0.20);
  --fw-border-strong:  rgba(0, 0, 0, 0.35);

  --fw-green: #1D9E75;
  --fw-amber: #EF9F27;
  --fw-red:   #D85A30;
  --fw-blue:  #185FA5;
  --fw-gray:  #888780;

  --fw-font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --fw-font-mono: "SF Mono", "Consolas", "Courier New", monospace;
  --fw-radius-md: 8px;
  --fw-radius-lg: 12px;
}

@media (prefers-color-scheme: dark) {
  :root {
    --fw-bg-primary:   #1a1a19;
    --fw-bg-secondary: #26251f;
    --fw-bg-tertiary:  #2c2c2a;
    --fw-bg-info:      #0c447c;
    --fw-bg-success:   #085041;
    --fw-bg-warning:   #633806;
    --fw-bg-danger:    #791f1f;
    --fw-text-primary:   #f5f4ee;
    --fw-text-secondary: #b4b2a9;
    --fw-text-info:      #b5d4f4;
    --fw-text-success:   #9fe1cb;
    --fw-text-warning:   #fac775;
    --fw-text-danger:    #f7c1c1;
    --fw-border-faint:   rgba(255, 255, 255, 0.12);
    --fw-border-mid:     rgba(255, 255, 255, 0.22);
    --fw-border-strong:  rgba(255, 255, 255, 0.40);
  }
}

// Shared layout atoms used across all dashboards
.fw-dashboard {
  width: 1280px; height: 1024px;
  padding: 16px; margin: 0 auto;
  display: flex; flex-direction: column; gap: 12px;
  background: var(--fw-bg-secondary);
  font-family: var(--fw-font-sans);
  font-size: 14px;
  color: var(--fw-text-primary);
}
.fw-panel {
  background: var(--fw-bg-primary);
  border: 0.5px solid var(--fw-border-faint);
  border-radius: var(--fw-radius-lg);
}
.fw-section {
  background: var(--fw-bg-primary);
  border: 0.5px solid var(--fw-border-faint);
  border-radius: var(--fw-radius-lg);
  padding: 10px 16px;
  display: flex; flex-direction: column; overflow: hidden;
}
.fw-mono { font-family: var(--fw-font-mono); }
```

Each component's `.scss` file imports additional component-scoped rules on top of this foundation. Component SCSS files use `ViewEncapsulation.None` so the shared token variables are accessible, or use `:host` scoping.

### 1.3 Environment flag

In `environment.development.ts`:
```typescript
export const environment = {
  production: false,
  useMockData: true,
  flatWireApiBase: 'https://localhost:5010/api/v1/flatwire'
};
```

In all other environments: `useMockData: false`

### 1.4 Mock data

The `FlatWireMockService` must return realistic data matching the API contract shapes exactly. See mock data fixtures in Part 3.

---

## Part 2 — .NET API Stub (FlatWire.API)

### 2.1 Project structure

Create new solution at `c:/UAL/ual-api/API/Domain/FlatWire/`:

```
FlatWire/
├── FlatWire.sln
├── FlatWire.API/
│   ├── FlatWire.API.csproj
│   ├── Program.cs                          ← Same pattern as CoilCheckin.API
│   ├── appsettings.json
│   ├── appsettings.Development.json
│   └── Controllers/
│       ├── CheckInController.cs            ← POST /checkin/rod, POST /checkin/spool
│       └── RodController.cs                ← GET /rod/{alpha}  (needed by check-in)
├── FlatWire.Application/
│   ├── FlatWire.Application.csproj
│   └── Commands/
│       ├── CheckInRod/
│       │   ├── CheckInRodCommand.cs
│       │   └── CheckInRodResponse.cs
│       └── CheckInSpool/
│           ├── CheckInSpoolCommand.cs
│           └── CheckInSpoolResponse.cs
├── FlatWire.Domain/
│   ├── FlatWire.Domain.csproj
│   ├── ParamModels/
│   │   ├── CheckInRodRequest.cs
│   │   ├── CheckInSpoolRequest.cs
│   │   └── InspectionDto.cs
│   └── Enums/
│       └── FlatWireEnums.cs
└── FlatWire.Infrastructure/
    ├── FlatWire.Infrastructure.csproj
    └── Services/
        ├── ICheckInService.cs
        └── CheckInStubService.cs           ← Returns hardcoded dummy data in Development
```

### 2.2 Port and launch

Assign port `5010` (development). Register in existing API gateway / CORS policy if one is used.

### 2.3 Stub mode rule

In `Development` environment, all commands return dummy success responses. No database writes, no PLC calls. This is controlled by `CheckInStubService` which is injected instead of the real service.

---

## Part 3 — Dummy Data Fixtures

These fixtures are shared between the Angular mock service and the .NET stub service.

### Rods available for check-in

| Alpha | Alloy | Temper | Diameter | Gross Wt | Net Wt | Status |
|---|---|---|---|---|---|---|
| R00041 | 1100 | O | 0.375 | 2000 lb | 1980 lb | STAGED |
| R00042 | 1100 | O | 0.375 | 2100 lb | 2080 lb | STAGED |
| R00043 | 3003 | H14 | 0.312 | 1800 lb | 1782 lb | STAGED |

### Pass schedules available at check-in

| ID | Alloy | Line | Route | Status |
|---|---|---|---|---|
| PS-1100-FL1-003 | 1100 | FL1 | Standalone | Active |
| PS-3003-FL1-001 | 3003 | FL1 | Standalone | Active |
| PS-1100-FL3-001 | 1100 | FL3 | Hybrid | Active |

Pass schedule PS-1100-FL1-003 components:
- DB1: Active, 0.310"
- DB2: Active, 0.260"
- FM1: Active, 0.128"
- EdgeSet: Active, Round
- FM2_8in: Bypass
- FM2_6inS1: Bypass
- FM2_6inS2: Active, 0.125"

### Spools available for FL2 check-in

| Alpha | Source Run | Gauge | Width | Gross Wt | Net Wt | Status |
|---|---|---|---|---|---|---|
| SP-00021 | RUN-0041 | 0.126 | 0.877 | 850 lb | 840 lb | STAGED |

### Successful check-in response (rod)

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

### Successful check-in response (spool)

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

## Part 4 — Angular Component Spec (Dashboard 2 — Rod Check-in)

**Route:** `/flat-wire/line/:lineId/checkin/rod`
**Component:** `Dashboard2RodCheckinComponent`
**File:** `components/dashboard-2-rod-checkin/dashboard-2-rod-checkin.component.ts`

**Source mockup:** `C:\UAL\Flat Wire\Mockups\dashboard_2_rod_checkin.html` — port the HTML and CSS directly.

### Layout (CSS Grid)

The dashboard uses a CSS Grid with `grid-template-columns: 1fr 1fr` and 4 rows:
- Row 1 (full width): Rod scan row — rod number input, diameter, payoff position selector
- Row 2 (full width): Incoming Bundle Information — alloy, temper, gross/net weight, heat no., supplier
- Row 3–4 col 1: Visual Inspection (row 3) + Pre-run SPC (row 4)
- Row 3–4 col 2: Pass Schedule (spans both rows)

### Form sections

**Row 1 — Rod Scan Row** (`.rod-scan-row`, always at top)
```
Rod Number [scan/text input, autofocus]   Diameter [decimal input]   Payoff Position [custom radio cards]
```
- Rod input: on enter/blur → call GET /rod/{alpha}. Shows `.rod-identified` (green) or `.rod-waiting` (amber) state badge after lookup.
- Payoff position: NOT a standard `<input type="radio">` — uses styled `.payoff-option` card divs with `.selected` class toggle (see mockup).

**Row 2 — Incoming Bundle Information** (`.section`, full width)
```
6-column grid: Alloy [read-only] | Temper [read-only] | Gross Weight [input] | Net Weight [read-only] | Heat/Cast No. [input] | Supplier [read-only]
```
All values auto-populated from rod lookup result. Gross Weight is editable (scale entry). Net Weight is computed.

**Row 3 col 1 — Visual Inspection** (`.section`)
```
Oxidation         [Pass] [Fail]   ← pill buttons, not standard radios
Surface Defects   [Pass] [Fail]
Water Stains      [Pass] [Fail]
Connector tag     [Present] [Missing]
Observation       [textarea — always visible, optional unless any = Fail]
```
- **4 inspection items** (the mockup adds "Connector tag present" — not 3 as the spec doc states).
- Any Fail → Acknowledge button disabled. No routing to Dashboard 8 in stub phase.

**Row 4 col 1 — Pre-run SPC** (`.section`)
```
Measurement 1     [decimal input]   Target [read-only: 0.375" ± 0.005"]   [In spec / Out of spec badge]
Measurement 2 (90°) [decimal input] Ovality M1−M2 [auto-calculated]       [In spec badge]
```
- **Two SPC measurements** at 90° to each other (the mockup has M1 and M2, not just one as the spec doc states).
- Ovality = |M1 − M2|; must be ≤ 0.003" to be in spec.
- Both inputs required before Acknowledge is enabled.

**Row 3–4 col 2 — Pass Schedule** (`.section`, spans 2 rows)
```
Header: Pass Schedule title | PS-1100-FL1-003 (mono) | Read-only badge

Order spec bar: Target 0.110" × 0.625" / Alloy 1100 / Temper H19 / Order qty 3 coils

Pass Schedule Confirm Bar (amber background until confirmed):
  "System recommends PS-1100-FL1-003 — matched on Alloy 1100, Rod 0.375", Target..."
  [Confirm Schedule]  [Change ▼]  ← dropdown with alternate schedules

Schedule table: Component | Status | Setting
  DB1          ● Active    Die 0.340"
  DB2          ● Active    Die 0.310"
  FM1 12" Mill ● Active    Gap 0.112" / Width 0.630"
  Edge Set     ● Active    Round edge
  Start speed  ● Active    150 FPM

Callout (info): "Parameters will be pushed to PLC tags on acknowledgment..."
```
- **Confirm bar is mandatory** — operator must click "Confirm Schedule" before Acknowledge button is enabled. The bar turns green (`.confirmed`) after confirmation.
- "Change" button opens a dropdown of alternate schedules. Selecting a non-recommended schedule shows a danger warning.

**Footer panel**
```
Left: [Progress ring SVG showing N/8 steps complete] "7 of 8 steps complete · confirm pass schedule to proceed"
Right: [Cancel]  [Acknowledge & Begin Check-in]  ← primary button, disabled until all conditions met
```
- Progress ring is an SVG `<circle>` with `stroke-dashoffset` updated as fields complete (0→8 steps).
- Acknowledge click → POST /checkin/rod → navigate to active run.

### Form validation summary

| Field | Rule |
|---|---|
| `rodAlpha` | Required; must match `/^R\d{5}$/`; must resolve via GET /rod |
| `diameter` | Required; 0.100–0.750 |
| `grossWeightLb` | Required; > 0 |
| `payoffPosition` | Required; 1 or 2 |
| `inspection.*` | All four items required; any Fail blocks submit |
| `passScheduleConfirmed` | Must click "Confirm Schedule" — boolean gate |
| `spcM1` | Required; within target ± tolerance |
| `spcM2` | Required; within target ± tolerance; ovality ≤ 0.003" |

### Mock service behavior

When `useMockData = true`:
- `getRod('R00041')` → returns R00041 fixture immediately (no HTTP)
- `getRod('INVALID')` → returns 404 error observable
- `checkInRod(...)` → waits 800ms (simulates network) → returns success response

---

## Part 5 — Angular Component Spec (Dashboard 5 — FL2 Spool Check-in)

**Route:** `/flat-wire/line/FL2/checkin/spool`
**Component:** `Dashboard5SpoolCheckinComponent`

**Source mockup:** `C:\UAL\Flat Wire\Mockups\dashboard_5_spool_checkin.html` — port the HTML and CSS directly.

### Layout (flex column)

```
Header panel
Top row (grid 1.25fr / 1fr): Incoming Bundle Information | Source Traceability
Gauge Profile (full width, fixed 270px height)
Pass Schedule section
Footer panel
```

### Sections

**Header** — same pattern as Dashboard 2: FL2 line badge, "Spool check-in" title, order/operator/clock.

**Top row col 1 — Incoming Bundle Information**
```
Row 1 (3 cols): Spool Alpha [scan input with barcode SVG icon prefix] | Alloy [read-only] | Temper [read-only]
Row 2 (3 cols): Gauge [decimal input] | Width [decimal input] | Gross Weight [input]
Row 3 (2 cols): Net Weight (calculated) [read-only] | Handling history [read-only text: "Spooled 07:02 AM · staged at TPO 07:24 AM · 38m dwell"]
```

**Top row col 2 — Source Traceability** (read-only, from FL1 run)
```
List of rods with weld events between them:
  [○ icon] R00041  0 – 2,100 ft           [Complete badge]
  [⚡ icon amber] Induction weld · at 2,100 ft · 06:31 AM    [✓ Pass]
  [○ icon] R00042  2,100 – 3,200 ft       [Complete badge]

Footer bar (info): "FL1 run completed 07:02 AM  |  Output alpha SP-00031"
```
This is purely display — populated from spool lookup. Uses `.trace-rod`, `.trace-weld-row`, `.trace-footer` classes.

**Gauge Profile — FL1 run history** (full width, 270px, `.profile-section`)
```
Header: "Gauge profile · FL1 run history" + "Target 0.110" ± 0.002"" subtitle
Legend: Gauge trace (blue line) | Tolerance band (green shaded) | Weld point (amber dashed)
Badge: "● All 3,200 ft in spec" (green)

Chart: SVG (not Chart.js) — inline <svg viewBox="0 0 1200 180" preserveAspectRatio="none">
  - Green shaded rect for tolerance band
  - Dashed green horizontal line at target
  - Amber dashed vertical line + label at weld point footage
  - Blue polyline for gauge trace
  - Axis labels (gauge values left, footage bottom)

Stats row: Min 0.108" | Max 0.112" | Avg 0.110" | Std dev 0.0011" | Samples 3,194
```
**Use inline SVG, not Chart.js.** The mockup's gauge profile is a hand-crafted SVG. For the stub phase, generate the SVG path from the mock gauge readings array using a simple linear scale function in TypeScript.

**Pass Schedule section** (`.schedule-section`, 258px height)
```
Same Confirm Bar pattern as Dashboard 2 (amber → green on confirmation).
Recommend PS-1100-FL2-007 by default.

Table: Component | Status | Setting | Stage
  8" Roller    ○ Bypass    —             pre-finishing  (row has .bypass class, opacity 0.6)
  6" Roller S1 ● Active    Gap 0.0162"   stage 1
  Edger        ● Active    Round edge    stage 1
  6" Roller S2 ● Active    Gap 0.0160"   stage 2
  Edger        ● Active    Round edge    stage 2
```

**Footer** — same progress ring + Cancel + Acknowledge pattern. 6 steps total for FL2.

### No visual inspection section

Dashboard 5 has no visual inspection. The spool was already inspected at FL1 check-in.

---

## Part 6 — .NET API Implementation Details

### `CheckInController.cs`

```csharp
[ApiController]
[Route("api/v1/flatwire/checkin")]
[Authorize]
public class CheckInController : UAController
{
    private readonly IMediator _mediator;

    public CheckInController(IMediator mediator) => _mediator = mediator;

    [HttpPost("rod")]
    [ProducesResponseType(typeof(ActionResultBase<CheckInRodResponse>), 200)]
    public async Task<IActionResult> CheckInRod([FromBody] CheckInRodRequest request)
    {
        var result = await _mediator.Send(new CheckInRodCommand(request));
        return Ok(new ActionResultBase<CheckInRodResponse> { Data = result, Success = true });
    }

    [HttpPost("spool")]
    [ProducesResponseType(typeof(ActionResultBase<CheckInSpoolResponse>), 200)]
    public async Task<IActionResult> CheckInSpool([FromBody] CheckInSpoolRequest request)
    {
        var result = await _mediator.Send(new CheckInSpoolCommand(request));
        return Ok(new ActionResultBase<CheckInSpoolResponse> { Data = result, Success = true });
    }
}
```

### Stub service behavior (Development environment)

`CheckInStubService.CheckInRod(request)`:
1. Validate `rodAlpha` matches `R00041`, `R00042`, or `R00043` — else throw with "Rod alpha not found"
2. Validate `passScheduleId` is not empty — else throw with "Pass schedule required"
3. Validate all inspection items are "Pass" — else throw with "Inspection failure must be resolved first"
4. Return the hardcoded `CheckInRodResponse` fixture (RunId = "RUN-0042", plcTagsPushed = true)

`CheckInStubService.CheckInSpool(request)`:
1. Validate `spoolAlpha` = "SP-00021" — else throw "Spool not found"
2. Return hardcoded spool response fixture

`RodController.GetRod(alpha)`:
- Returns fixture if alpha in `{R00041, R00042, R00043}`, else 404

### Request/Response DTOs

```csharp
// FlatWire.Domain/ParamModels/CheckInRodRequest.cs
public record CheckInRodRequest(
    string LineId,
    string RodAlpha,
    int PayoffPosition,
    decimal DiameterMeasuredIn,
    decimal GrossWeightLb,
    decimal NetWeightLb,
    InspectionDto Inspection,
    string PassScheduleId,
    string OperatorId,
    string OrderId);

public record InspectionDto(
    string Oxidation,
    string SurfaceDefects,
    string WaterStains,
    string? ObservationNotes);

// FlatWire.Application/Commands/CheckInRod/CheckInRodResponse.cs
public record CheckInRodResponse(
    string RunId,
    string LineId,
    string RodAlpha,
    string PassScheduleId,
    DateTimeOffset CheckedInAt,
    bool PlcTagsPushed);
```

---

## Acceptance Checklist

### Angular (Dashboard 2)
- [ ] Rod scan field validates format and calls mock GET /rod/{alpha}
- [ ] Alloy, Temper auto-fill after successful rod lookup
- [ ] All 3 inspection radios present; any Fail blocks Acknowledge button
- [ ] Pass schedule table renders correctly from mock data
- [ ] SPC diameter field is required before Acknowledge is enabled
- [ ] Submit calls mock `checkInRod` and navigates on success
- [ ] Error from API shown in inline banner (not console)
- [ ] useMockData=false code path compiles without errors (even if not tested)

### Angular (Dashboard 5)
- [ ] Spool alpha lookup auto-fills source rods, alloy
- [ ] Historical gauge chart renders with target line and tolerance band
- [ ] Pass schedule table shows FL2 components only
- [ ] Submit calls mock `checkInSpool` and navigates on success

### .NET API
- [ ] `POST /api/v1/flatwire/checkin/rod` returns 200 with RunId for valid R-series alpha
- [ ] Returns 400 with error message for invalid alpha
- [ ] Returns 400 for inspection failure in request body
- [ ] `POST /api/v1/flatwire/checkin/spool` returns 200 for SP-00021
- [ ] `GET /api/v1/flatwire/rod/R00041` returns rod fixture
- [ ] `GET /api/v1/flatwire/rod/INVALID` returns 404
- [ ] Swagger UI shows all endpoints and DTOs

---

## Dependencies Not Needed for This Phase

The following are explicitly **out of scope** for the stub-driven check-in phase:
- Real PLC tag push (simulated only — `plcTagsPushed: true` always)
- Database writes (stub returns hardcoded data)
- SignalR broadcast on check-in (can be added when hub is live)
- Navigation to Dashboard 3 active run (just navigate to placeholder route)
- OQ-51 (pass schedule selection mechanism) — assume "load linked schedule" always resolves to PS-1100-FL1-003

---

## Related Documents

| Document | Purpose |
|---|---|
| [ShopfloorAndRealTimePlan.md](ShopfloorAndRealTimePlan.md) | Sprint plan — stories FW-S3-009, FW-S3-012 |
| [APIContracts.md](APIContracts.md) | Full API contract — Sprint 3 section |
| [RocCheckin.md](../Analysis/RocCheckin.md) | Acknowledge flow design — 5-step sequence |
| [FlatWireShopfloorDashboards.md](../Analysis/FlatWireShopfloorDashboards.md) | Dashboard UX wireframes |
