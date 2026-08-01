# Implementation Prompt — Flat Wire Check-in Feature (Sprint S3)

**Hand this prompt to an agent or developer to implement the check-in feature.**

---

## What You Are Building

You are implementing the **check-in functionality** for the Flat Wire Mill system. This covers two operator dashboards and their supporting API:

1. **Dashboard 2 — Rod Check-in (FL1/FL3):** An operator scans a rod alpha, performs a visual inspection, reviews the pass schedule, enters a pre-run SPC diameter, then acknowledges to start the run.
2. **Dashboard 5 — FL2 Spool Check-in:** Same flow for FL2 but uses a spool alpha (instead of a rod) and shows a historical gauge chart instead of a visual inspection.
3. **FlatWire.API stub endpoints:** `POST /api/v1/flatwire/checkin/rod`, `POST /api/v1/flatwire/checkin/spool`, `GET /api/v1/flatwire/rod/{alpha}` — these return dummy/hardcoded data in Development mode (no database, no PLC).

**This is stub-driven development.** The goal is a fully functional UI that works against dummy data, so that operators can demo the screens before the backend is fully wired. PLC and database wiring comes later.

---

## Codebase Locations

| Location | Purpose |
|---|---|
| `c:/UAL/ual-angular/` | Angular monorepo — all frontend libraries |
| `c:/UAL/ual-api/API/Domain/` | .NET microservices — one folder per service |
| `c:/UAL/ual-api/API/Domain/CoilCheckin/` | Reference implementation — copy patterns from here |
| `c:/UAL/ual-angular/projects/checkin-precheckin/` | Reference Angular library — copy patterns from here |

---

## Step 1 — Scaffold the Angular Library

Run this from `c:/UAL/ual-angular/`:
```bash
ng generate library flat-wire-shopfloor --prefix=fw
```

Then create the following file structure inside `projects/flat-wire-shopfloor/src/lib/`:

```
styles/
  flat-wire-shopfloor.styles.scss   ← design system tokens + shared layout classes
services/
  flat-wire-api.interface.ts
  flat-wire-api-mock.service.ts
  flat-wire-api-real.service.ts
  line-context.service.ts
models/
  rod.model.ts
  pass-schedule.model.ts
  checkin.model.ts
guards/
  flat-wire-auth.guard.ts
components/
  shared/
    pass-schedule-table/
      pass-schedule-table.component.ts
      pass-schedule-table.component.html
  dashboard-2-rod-checkin/
    dashboard-2-rod-checkin.component.ts
    dashboard-2-rod-checkin.component.html
    dashboard-2-rod-checkin.component.scss
    dashboard-2-rod-checkin.component.spec.ts
  dashboard-5-spool-checkin/
    dashboard-5-spool-checkin.component.ts
    dashboard-5-spool-checkin.component.html
    dashboard-5-spool-checkin.component.scss
    dashboard-5-spool-checkin.component.spec.ts
flat-wire-shopfloor-routing.ts
flat-wire-shopfloor.module.ts
```

**Register the library stylesheet** in `angular.json` under the main app's `styles` array:
```json
"projects/flat-wire-shopfloor/src/lib/styles/flat-wire-shopfloor.styles.scss"
```

### Routes to register

```typescript
// flat-wire-shopfloor-routing.ts
export const FLAT_WIRE_ROUTES: Routes = [
  {
    path: 'line/:lineId/checkin/rod',
    component: Dashboard2RodCheckinComponent,
    canActivate: [FlatWireAuthGuard]
  },
  {
    path: 'line/FL2/checkin/spool',
    component: Dashboard5SpoolCheckinComponent,
    canActivate: [FlatWireAuthGuard]
  },
  {
    path: 'line/:lineId/run/active',
    component: ActiveRunPlaceholderComponent   // stub placeholder for now
  }
];
```

Register the library's lazy route in the shell app under `/flat-wire`.

### Environment flag

Add to `src/environments/environment.development.ts`:
```typescript
useMockData: true,
flatWireApiBase: 'https://localhost:5010/api/v1/flatwire'
```

Add `useMockData: false` and the prod URL to all other environment files.

---

## Step 2 — Models

### `rod.model.ts`
```typescript
export interface Rod {
  alpha: string;
  alloy: string;
  temper: string;
  diameterIn: number;
  grossWeightLb: number;
  netWeightLb: number;
  status: string;
  location: string;
  receivedAt: string;
}
```

### `pass-schedule.model.ts`
```typescript
export interface PassScheduleComponent {
  componentName: string;
  state: 'Active' | 'Bypass' | 'Skip';
  parameterValue: number | null;
  edgeType: string | null;
}

export interface PassScheduleDetail {
  scheduleId: string;
  description: string;
  alloy: string;
  line: string;
  routeMode: string;
  status: string;
  targetGauge: number;
  gaugeTolerance: number;
  targetWidth: number;
  widthTolerance: number;
  components: PassScheduleComponent[];
}
```

### `checkin.model.ts`
```typescript
export interface InspectionResult {
  oxidation: 'Pass' | 'Fail' | null;
  surfaceDefects: 'Pass' | 'Fail' | null;
  waterStains: 'Pass' | 'Fail' | null;
  observationNotes: string | null;
}

export interface CheckInRodRequest {
  lineId: string;
  rodAlpha: string;
  payoffPosition: 1 | 2;
  diameterMeasuredIn: number;
  grossWeightLb: number;
  netWeightLb: number;
  inspection: InspectionResult;
  passScheduleId: string;
  operatorId: string;
  orderId: string;
}

export interface CheckInRodResponse {
  runId: string;
  lineId: string;
  rodAlpha: string;
  passScheduleId: string;
  checkedInAt: string;
  plcTagsPushed: boolean;
}

export interface CheckInSpoolRequest {
  lineId: 'FL2';
  spoolAlpha: string;
  gaugeMeasuredIn: number;
  widthMeasuredIn: number;
  grossWeightLb: number;
  netWeightLb: number;
  passScheduleId: string;
  operatorId: string;
  orderId: string;
}

export interface CheckInSpoolResponse {
  runId: string;
  lineId: string;
  spoolAlpha: string;
  passScheduleId: string;
  checkedInAt: string;
  plcTagsPushed: boolean;
}

export interface GaugeReading {
  footage: number;
  gauge: number;
  inSpec: boolean;
}

export interface SpoolDetail {
  alpha: string;
  sourceRods: string[];
  alloy: string;
  temper: string;
  gaugeIn: number;
  widthIn: number;
  grossWeightLb: number;
  netWeightLb: number;
  gaugeReadings: GaugeReading[];
  targetGauge: number;
  gaugeTolerance: number;
}
```

---

## Step 3 — API Interface and Mock Service

### `flat-wire-api.interface.ts`
```typescript
export abstract class FlatWireApiService {
  abstract getRod(alpha: string): Observable<Rod>;
  abstract getPassSchedule(scheduleId: string): Observable<PassScheduleDetail>;
  abstract checkInRod(request: CheckInRodRequest): Observable<CheckInRodResponse>;
  abstract checkInSpool(request: CheckInSpoolRequest): Observable<CheckInSpoolResponse>;
  abstract getSpoolDetail(alpha: string): Observable<SpoolDetail>;
}
```

### `flat-wire-api-mock.service.ts` — key mock data

```typescript
// Three rods
private readonly RODS: Record<string, Rod> = {
  'R00041': { alpha: 'R00041', alloy: '1100', temper: 'O', diameterIn: 0.375,
               grossWeightLb: 2000, netWeightLb: 1980, status: 'STAGED', location: 'Floor-A3',
               receivedAt: '2026-04-29T14:00:00Z' },
  'R00042': { alpha: 'R00042', alloy: '1100', temper: 'O', diameterIn: 0.375,
               grossWeightLb: 2100, netWeightLb: 2080, status: 'STAGED', location: 'Floor-A3',
               receivedAt: '2026-04-29T14:00:00Z' },
  'R00043': { alpha: 'R00043', alloy: '3003', temper: 'H14', diameterIn: 0.312,
               grossWeightLb: 1800, netWeightLb: 1782, status: 'STAGED', location: 'Floor-B1',
               receivedAt: '2026-04-29T16:00:00Z' }
};

// The active pass schedule
private readonly PASS_SCHEDULE: PassScheduleDetail = {
  scheduleId: 'PS-1100-FL1-003',
  description: '1100 Rod to Flat 0.125 x 0.875',
  alloy: '1100', line: 'FL1', routeMode: 'Standalone', status: 'Active',
  targetGauge: 0.125, gaugeTolerance: 0.003, targetWidth: 0.875, widthTolerance: 0.005,
  components: [
    { componentName: 'DB1',       state: 'Active', parameterValue: 0.310, edgeType: null },
    { componentName: 'DB2',       state: 'Active', parameterValue: 0.260, edgeType: null },
    { componentName: 'FM1',       state: 'Active', parameterValue: 0.128, edgeType: null },
    { componentName: 'EdgeSet',   state: 'Active', parameterValue: null,  edgeType: 'Round' },
    { componentName: 'FM2_8in',   state: 'Bypass', parameterValue: null,  edgeType: null },
    { componentName: 'FM2_6inS1', state: 'Bypass', parameterValue: null,  edgeType: null },
    { componentName: 'FM2_6inS2', state: 'Active', parameterValue: 0.125, edgeType: null }
  ]
};

// One spool for FL2
private readonly SPOOL: SpoolDetail = {
  alpha: 'SP-00021', sourceRods: ['R00040', 'R00041'], alloy: '1100', temper: 'O',
  gaugeIn: 0.126, widthIn: 0.877, grossWeightLb: 850, netWeightLb: 840,
  targetGauge: 0.125, gaugeTolerance: 0.003,
  // 50 readings, all in spec (0.123–0.127)
  gaugeReadings: Array.from({ length: 50 }, (_, i) => ({
    footage: i * 40,
    gauge: 0.124 + (Math.sin(i * 0.4) * 0.001),
    inSpec: true
  }))
};
```

Mock method behavior:
- `getRod(alpha)`: return matching rod with 300ms delay; throw 404 if not found
- `getPassSchedule(id)`: return PASS_SCHEDULE always (stub: one schedule for all)
- `checkInRod(req)`: validate alpha exists; delay 800ms; return `{ runId: 'RUN-0042', lineId: req.lineId, rodAlpha: req.rodAlpha, passScheduleId: req.passScheduleId, checkedInAt: new Date().toISOString(), plcTagsPushed: true }`
- `checkInSpool(req)`: validate alpha = 'SP-00021'; delay 800ms; return spool response

Use `throwError(() => new HttpErrorResponse({ status: 404, statusText: 'Not Found' }))` for not-found cases.

---

## Step 4 — `pass-schedule-table` Shared Component

```html
<!-- pass-schedule-table.component.html -->
<table class="fw-component-table">
  <thead>
    <tr>
      <th>Component</th>
      <th>Status</th>
      <th>Setting</th>
    </tr>
  </thead>
  <tbody>
    @for (comp of components; track comp.componentName) {
      <tr [class.bypassed]="comp.state !== 'Active'">
        <td>{{ comp.componentName }}</td>
        <td>
          <span class="status-badge" [class.active]="comp.state === 'Active'">
            {{ comp.state === 'Active' ? '● ACTIVE' : '○ BYPASS' }}
          </span>
        </td>
        <td>
          @if (comp.state === 'Active') {
            @if (comp.edgeType) { {{ comp.edgeType }} }
            @else if (comp.parameterValue !== null) { {{ comp.parameterValue | number:'1.3-3' }}" }
            @else { — }
          } @else {
            —
          }
        </td>
      </tr>
    }
  </tbody>
</table>
```

Input: `@Input() components: PassScheduleComponent[] = []`

---

## Step 5 — Dashboard 2 Component (Rod Check-in)

### TypeScript

```typescript
@Component({
  selector: 'fw-dashboard-2-rod-checkin',
  templateUrl: './dashboard-2-rod-checkin.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class Dashboard2RodCheckinComponent implements OnInit {
  lineId = this.route.snapshot.paramMap.get('lineId') ?? 'FL1';

  form = this.fb.group({
    rodAlpha: ['', [Validators.required, Validators.pattern(/^R\d{5}$/)]],
    diameter: [null as number | null, [Validators.required, Validators.min(0.100), Validators.max(0.750)]],
    grossWeightLb: [null as number | null, [Validators.required, Validators.min(0.01)]],
    netWeightLb: [null as number | null, [Validators.required, Validators.min(0.01)]],
    payoffPosition: [null as 1 | 2 | null, Validators.required],
    inspection: this.fb.group({
      oxidation: [null as string | null, Validators.required],
      surfaceDefects: [null as string | null, Validators.required],
      waterStains: [null as string | null, Validators.required],
      observationNotes: ['']
    }),
    spcDiameter: [null as number | null, [Validators.required, Validators.min(0.100), Validators.max(0.750)]]
  });

  rod: Rod | null = null;
  rodLookupError: string | null = null;
  passSchedule: PassScheduleDetail | null = null;
  submitError: string | null = null;
  isLoading = false;
  isSubmitting = false;

  get inspectionFailed(): boolean {
    const insp = this.form.get('inspection')?.value;
    return insp?.oxidation === 'Fail' || insp?.surfaceDefects === 'Fail' || insp?.waterStains === 'Fail';
  }

  get canSubmit(): boolean {
    return this.form.valid && !this.inspectionFailed && !!this.rod && !!this.passSchedule;
  }

  onRodAlphaBlur(): void {
    const alpha = this.form.get('rodAlpha')?.value;
    if (!alpha || !/^R\d{5}$/.test(alpha)) return;
    this.isLoading = true;
    this.rodLookupError = null;
    this.api.getRod(alpha).subscribe({
      next: (rod) => {
        this.rod = rod;
        this.form.patchValue({ diameter: rod.diameterIn, grossWeightLb: rod.grossWeightLb, netWeightLb: rod.netWeightLb });
        // Load the active pass schedule for this line
        this.api.getPassSchedule('PS-1100-FL1-003').subscribe(ps => this.passSchedule = ps);
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        this.rodLookupError = 'Rod alpha not found — verify the scan or enter manually';
        this.rod = null;
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  onSubmit(): void {
    if (!this.canSubmit) return;
    this.isSubmitting = true;
    this.submitError = null;
    const v = this.form.value;
    const request: CheckInRodRequest = {
      lineId: this.lineId,
      rodAlpha: v.rodAlpha!,
      payoffPosition: v.payoffPosition!,
      diameterMeasuredIn: v.diameter!,
      grossWeightLb: v.grossWeightLb!,
      netWeightLb: v.netWeightLb!,
      inspection: {
        oxidation: v.inspection!.oxidation!,
        surfaceDefects: v.inspection!.surfaceDefects!,
        waterStains: v.inspection!.waterStains!,
        observationNotes: v.inspection!.observationNotes ?? null
      },
      passScheduleId: this.passSchedule!.scheduleId,
      operatorId: 'john.d',   // replace with auth service user when available
      orderId: 'FW-00421'     // replace with active order from line context when available
    };
    this.api.checkInRod(request).subscribe({
      next: () => this.router.navigate(['/flat-wire/line', this.lineId, 'run', 'active']),
      error: (err) => {
        this.submitError = err?.error?.errors?.[0] ?? 'Check-in failed — please try again';
        this.isSubmitting = false;
        this.cdr.markForCheck();
      }
    });
  }
}
```

### HTML structure

Port the markup directly from `C:\UAL\Flat Wire\Mockups\dashboard_2_rod_checkin.html`. Key structural points:

```html
<div class="fw-dashboard">

  <!-- Header panel -->
  <div class="fw-panel header">
    <div class="header-left">
      <span class="line-badge"><span class="dot"></span>{{ lineId }}</span>
      <h1>Rod check-in &amp; pre-run setup</h1>
    </div>
    <div class="header-meta">
      <span>Order <strong class="fw-mono">{{ orderId }}</strong></span>
      <span>Operator <strong>{{ operatorName }}</strong></span>
      <span>{{ now | date:'MMM d, yyyy' }} &middot; <span class="fw-mono">{{ now | date:'hh:mm a' }}</span></span>
    </div>
  </div>

  <!-- Content grid: 2 cols, 4 rows -->
  <div class="content">

    <!-- Row 1 full-width: Rod scan row -->
    <div class="fw-section rod-scan-row" style="grid-column: 1 / -1; grid-row: 1;">
      <!-- rod number input, diameter input, payoff-option cards -->
    </div>

    <!-- Row 2 full-width: Bundle info -->
    <div class="fw-section" style="grid-column: 1 / -1; grid-row: 2;">
      <!-- 6-col grid: alloy, temper, gross wt, net wt, heat no, supplier -->
    </div>

    <!-- Row 3 col 1: Visual Inspection -->
    <div class="fw-section" style="grid-column: 1; grid-row: 3;">
      <!-- 4 inspection rows with pill buttons (Pass/Fail) -->
      <!-- observation textarea -->
    </div>

    <!-- Row 4 col 1: Pre-run SPC -->
    <div class="fw-section" style="grid-column: 1; grid-row: 4;">
      <!-- spc-measurement grid: M1 input + target readonly + in-spec badge -->
      <!-- spc-measurement grid: M2 input (90°) + ovality computed + in-spec badge -->
    </div>

    <!-- Row 3-4 col 2: Pass Schedule (spans 2 rows) -->
    <div class="fw-section" style="grid-column: 2; grid-row: 3 / span 2;">
      <!-- order-spec-bar -->
      <!-- ps-confirm-bar (amber → green on confirm) -->
      <!-- schedule-table -->
      <!-- callout (info) -->
    </div>

  </div>

  <!-- Footer panel -->
  <div class="fw-panel footer">
    <div class="footer-status">
      <!-- progress ring SVG (stroke-dashoffset updated as steps complete) -->
      <span>{{ footerStatusText }}</span>
    </div>
    <div class="footer-actions">
      <button class="fw-btn" type="button" (click)="onCancel()">Cancel</button>
      <button class="fw-btn fw-btn-primary" type="button"
              [disabled]="!canSubmit || isSubmitting"
              (click)="onSubmit()">
        Acknowledge &amp; Begin Check-in
      </button>
    </div>
  </div>

</div>
```

**Payoff position selector** — use div cards, NOT `<input type="radio">`:
```html
<div class="payoff-selector">
  @for (pos of [1, 2]; track pos) {
    <div class="payoff-option" [class.selected]="payoffPosition === pos"
         (click)="payoffPosition = pos">
      <div class="payoff-dot"></div>
      <span class="payoff-label">Payoff {{ pos }}</span>
    </div>
  }
</div>
```

**Inspection rows** — use button elements, NOT `<input type="radio">`:
```html
@for (item of inspectionItems; track item.key) {
  <div class="inspection-row">
    <span class="inspection-label">{{ item.label }}</span>
    <div class="inspection-buttons">
      <button class="fw-pill-btn pass" [class.selected]="inspection[item.key] === 'Pass'"
              type="button" (click)="setInspection(item.key, 'Pass')">Pass</button>
      <button class="fw-pill-btn fail" [class.selected]="inspection[item.key] === 'Fail'"
              type="button" (click)="setInspection(item.key, 'Fail')">Fail</button>
    </div>
  </div>
}
```
Inspection items: `oxidation`, `surfaceDefects`, `waterStains`, `connectorTag` (label: "Connector tag present", values: Present/Missing).

**Pass schedule confirm bar:**
```html
<div class="fw-ps-confirm-bar" [class.confirmed]="psConfirmed">
  <span class="ps-confirm-match">{{ psConfirmText }}</span>
  <div class="ps-confirm-actions">
    @if (!psConfirmed) {
      <button class="btn-confirm-ps" type="button" (click)="confirmSchedule(passSchedule.scheduleId)">
        Confirm Schedule
      </button>
    }
    <!-- Change dropdown (omit in stub phase — single recommended schedule only) -->
  </div>
</div>
```

**Progress ring SVG** (update `stroke-dashoffset` as `completedSteps` changes):
```html
<svg viewBox="0 0 34 34" width="34" height="34" style="transform: rotate(-90deg)">
  <circle fill="none" stroke="var(--fw-bg-secondary)" stroke-width="3" cx="17" cy="17" r="14"/>
  <circle fill="none" stroke="var(--fw-green)" stroke-width="3" stroke-linecap="round"
          cx="17" cy="17" r="14"
          [attr.stroke-dasharray]="87.96"
          [attr.stroke-dashoffset]="87.96 * (1 - completedSteps / totalSteps)"/>
</svg>
```

---

## Step 6 — Dashboard 5 Component (FL2 Spool Check-in)

Port the markup from `C:\UAL\Flat Wire\Mockups\dashboard_5_spool_checkin.html`.

Layout is **flex column** (not a grid like Dashboard 2):
1. Header panel (same pattern as DB2, but "FL2" badge and "Spool check-in" title)
2. Top row: `grid-template-columns: 1.25fr 1fr` — Incoming Bundle Info | Source Traceability
3. Gauge Profile (full width, 270px fixed height)
4. Pass Schedule section
5. Footer panel

Key differences from Dashboard 2:
- No visual inspection
- Source Traceability replaces the inspection panel — shows rod chain (`.trace-rod`) and weld events (`.trace-weld-row`)
- Gauge profile is **inline SVG**, not Chart.js

### Historical gauge chart — inline SVG (not Chart.js)

The mockup uses a hand-crafted inline `<svg viewBox="0 0 1200 180" preserveAspectRatio="none">`. Generate the SVG path in TypeScript from the mock readings array using a linear scale:

```typescript
buildGaugeSvgPath(readings: GaugeReading[], target: number, tolerance: number): string {
  if (!readings.length) return '';
  const W = 1110, H = 160, X0 = 70, Y0 = 10;
  const maxFootage = readings[readings.length - 1].footage;
  const gaugeMin = target - tolerance * 3;
  const gaugeMax = target + tolerance * 3;

  const xScale = (f: number) => X0 + (f / maxFootage) * W;
  const yScale = (g: number) => Y0 + H - ((g - gaugeMin) / (gaugeMax - gaugeMin)) * H;

  return readings.map((r, i) =>
    `${i === 0 ? 'M' : 'L'} ${xScale(r.footage).toFixed(1)},${yScale(r.gauge).toFixed(1)}`
  ).join(' ');
}

buildToleranceBand(target: number, tolerance: number, readings: GaugeReading[]): object {
  // returns y coords for the green shaded rect
}
```

Bind the path into the template:
```html
<div class="profile-section fw-panel">
  <div class="profile-header">...</div>
  <div class="profile-chart">
    <svg viewBox="0 0 1200 180" preserveAspectRatio="none" width="100%" height="100%">
      <!-- tolerance band rect -->
      <rect x="70" [attr.y]="toleranceBand.y" width="1110" [attr.height]="toleranceBand.h"
            fill="#1D9E75" fill-opacity="0.14"/>
      <!-- target line dashed -->
      <line x1="70" [attr.y1]="targetY" x2="1180" [attr.y2]="targetY"
            stroke="#1D9E75" stroke-width="1" stroke-dasharray="4 4" opacity="0.55"/>
      <!-- weld marker vertical line -->
      @if (weldFootage) {
        <line [attr.x1]="weldX" y1="12" [attr.x2]="weldX" y2="150"
              stroke="#EF9F27" stroke-width="1.5" stroke-dasharray="3 3"/>
      }
      <!-- gauge trace -->
      <path [attr.d]="gaugePath" stroke="#185FA5" stroke-width="2" fill="none"/>
      <!-- axis labels -->
    </svg>
  </div>
  <div class="profile-stats">
    <span class="profile-stat">Min <strong class="fw-mono">{{ stats.min }}"</strong></span>
    <span class="profile-stat">Max <strong class="fw-mono">{{ stats.max }}"</strong></span>
    <span class="profile-stat">Avg <strong class="fw-mono">{{ stats.avg }}"</strong></span>
    <span class="profile-stat">Samples <strong class="fw-mono">{{ readings.length }}</strong></span>
  </div>
</div>
```

The mock readings array (50 points, all in spec) is sufficient for the stub phase — no real gauge data required.

---

## Step 7 — .NET API Microservice

### Create the project

```bash
cd c:/UAL/ual-api/API/Domain
mkdir FlatWire
cd FlatWire
dotnet new sln -n FlatWire
dotnet new webapi -n FlatWire.API --no-openapi false
dotnet new classlib -n FlatWire.Application
dotnet new classlib -n FlatWire.Domain
dotnet new classlib -n FlatWire.Infrastructure
dotnet sln add FlatWire.API FlatWire.Application FlatWire.Domain FlatWire.Infrastructure
```

### Project references

```
FlatWire.API → FlatWire.Application, FlatWire.Domain
FlatWire.Application → FlatWire.Domain
FlatWire.Infrastructure → FlatWire.Domain
FlatWire.API → FlatWire.Infrastructure
```

### NuGet packages (copy from CoilCheckin as reference)

```bash
# In FlatWire.API:
dotnet add package MediatR.Extensions.Microsoft.DependencyInjection
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Swashbuckle.AspNetCore

# Reference UAL framework — follow CoilCheckin.API.csproj for project reference path
```

### `CheckInController.cs`

```csharp
[ApiController]
[Route("api/v1/flatwire/checkin")]
public class CheckInController : ControllerBase
{
    private readonly IMediator _mediator;
    public CheckInController(IMediator mediator) => _mediator = mediator;

    [HttpPost("rod")]
    public async Task<IActionResult> CheckInRod([FromBody] CheckInRodRequest request, CancellationToken ct)
    {
        try
        {
            var result = await _mediator.Send(new CheckInRodCommand(request), ct);
            return Ok(new { data = result, success = true });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { success = false, errors = new[] { ex.Message } });
        }
    }

    [HttpPost("spool")]
    public async Task<IActionResult> CheckInSpool([FromBody] CheckInSpoolRequest request, CancellationToken ct)
    {
        try
        {
            var result = await _mediator.Send(new CheckInSpoolCommand(request), ct);
            return Ok(new { data = result, success = true });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { success = false, errors = new[] { ex.Message } });
        }
    }
}
```

### `RodController.cs`

```csharp
[ApiController]
[Route("api/v1/flatwire/rod")]
public class RodController : ControllerBase
{
    private static readonly Dictionary<string, object> Rods = new()
    {
        ["R00041"] = new { alpha = "R00041", alloy = "1100", temper = "O", diameterIn = 0.375m,
                           grossWeightLb = 2000m, netWeightLb = 1980m, status = "STAGED" },
        ["R00042"] = new { alpha = "R00042", alloy = "1100", temper = "O", diameterIn = 0.375m,
                           grossWeightLb = 2100m, netWeightLb = 2080m, status = "STAGED" },
        ["R00043"] = new { alpha = "R00043", alloy = "3003", temper = "H14", diameterIn = 0.312m,
                           grossWeightLb = 1800m, netWeightLb = 1782m, status = "STAGED" }
    };

    [HttpGet("{alpha}")]
    public IActionResult GetRod(string alpha)
    {
        if (Rods.TryGetValue(alpha.ToUpper(), out var rod))
            return Ok(new { data = rod, success = true });
        return NotFound(new { success = false, errors = new[] { "Rod alpha not found" } });
    }
}
```

### `CheckInStubService.cs` (in FlatWire.Infrastructure)

```csharp
public class CheckInStubService : ICheckInService
{
    private static readonly HashSet<string> ValidRods = new() { "R00041", "R00042", "R00043" };
    private static readonly HashSet<string> ValidSpools = new() { "SP-00021" };

    public Task<CheckInRodResponse> CheckInRod(CheckInRodRequest request, CancellationToken ct)
    {
        if (!ValidRods.Contains(request.RodAlpha))
            throw new ArgumentException($"Rod alpha {request.RodAlpha} not found in the system");

        if (string.IsNullOrWhiteSpace(request.PassScheduleId))
            throw new ArgumentException("Pass schedule is required for check-in");

        if (request.Inspection.Oxidation == "Fail" ||
            request.Inspection.SurfaceDefects == "Fail" ||
            request.Inspection.WaterStains == "Fail")
            throw new ArgumentException("Inspection failure must be resolved via WIP rejection before check-in");

        return Task.FromResult(new CheckInRodResponse(
            RunId: "RUN-0042",
            LineId: request.LineId,
            RodAlpha: request.RodAlpha,
            PassScheduleId: request.PassScheduleId,
            CheckedInAt: DateTimeOffset.UtcNow,
            PlcTagsPushed: true));
    }

    public Task<CheckInSpoolResponse> CheckInSpool(CheckInSpoolRequest request, CancellationToken ct)
    {
        if (!ValidSpools.Contains(request.SpoolAlpha))
            throw new ArgumentException($"Spool alpha {request.SpoolAlpha} not found in the system");

        return Task.FromResult(new CheckInSpoolResponse(
            RunId: "RUN-0043",
            LineId: "FL2",
            SpoolAlpha: request.SpoolAlpha,
            PassScheduleId: request.PassScheduleId,
            CheckedInAt: DateTimeOffset.UtcNow,
            PlcTagsPushed: true));
    }
}
```

Register in `Program.cs`: `builder.Services.AddScoped<ICheckInService, CheckInStubService>();`

---

## Step 8 — Design System SCSS

Create `projects/flat-wire-shopfloor/src/lib/styles/flat-wire-shopfloor.styles.scss`.
This is the single source of truth for all flat-wire visual tokens. Do NOT use Bootstrap.

```scss
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

  --fw-border-faint:   rgba(0,0,0,0.10);
  --fw-border-mid:     rgba(0,0,0,0.20);
  --fw-border-strong:  rgba(0,0,0,0.35);

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
    --fw-text-tertiary:  #888780;
    --fw-text-info:      #b5d4f4;
    --fw-text-success:   #9fe1cb;
    --fw-text-warning:   #fac775;
    --fw-text-danger:    #f7c1c1;
    --fw-border-faint:   rgba(255,255,255,0.12);
    --fw-border-mid:     rgba(255,255,255,0.22);
    --fw-border-strong:  rgba(255,255,255,0.40);
  }
}

*, *::before, *::after { box-sizing: border-box; }

.fw-dashboard {
  width: 1280px; height: 1024px; padding: 16px;
  margin: 0 auto; display: flex; flex-direction: column; gap: 12px;
  background: var(--fw-bg-secondary);
  font-family: var(--fw-font-sans); font-size: 14px;
  color: var(--fw-text-primary); -webkit-font-smoothing: antialiased;
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
  padding: 10px 16px; display: flex; flex-direction: column; overflow: hidden;
}
.fw-mono { font-family: var(--fw-font-mono); }

// Shared form atoms
.fw-input {
  height: 42px; padding: 0 14px; width: 100%;
  font-size: 16px; font-family: var(--fw-font-mono); font-weight: 500;
  color: var(--fw-text-primary); background: var(--fw-bg-primary);
  border: 1px solid var(--fw-border-mid); border-radius: var(--fw-radius-md); outline: none;
  &:focus { border-color: var(--fw-blue); box-shadow: 0 0 0 3px rgba(24,95,165,0.18); }
  &:disabled { background: var(--fw-bg-secondary); color: var(--fw-text-secondary);
               border-color: var(--fw-border-faint); cursor: default; }
}
.fw-input-readonly {
  height: 42px; padding: 0 14px; font-size: 15px; font-weight: 500;
  background: var(--fw-bg-secondary); border-radius: var(--fw-radius-md);
  display: flex; align-items: center; color: var(--fw-text-primary);
}
.fw-field { display: flex; flex-direction: column; gap: 6px; }
.fw-field-label { font-size: 13px; color: var(--fw-text-secondary); }
.fw-field-label.required::after { content: " *"; color: var(--fw-red); }
.fw-field-grid { display: grid; gap: 8px; margin-bottom: 8px; }

// Buttons
.fw-btn {
  height: 52px; padding: 0 28px; font-size: 15px; font-weight: 500;
  border-radius: var(--fw-radius-md); cursor: pointer; font-family: var(--fw-font-sans);
  border: 1px solid var(--fw-border-mid); background: var(--fw-bg-primary);
  color: var(--fw-text-primary); transition: all 0.15s;
  &:hover { background: var(--fw-bg-secondary); }
  &:active { transform: scale(0.98); }
}
.fw-btn-primary {
  background: var(--fw-blue); border-color: var(--fw-blue); color: #fff; padding: 0 36px;
  &:hover { background: #13497d; }
  &:disabled { opacity: 0.45; cursor: not-allowed; transform: none; }
}

// Status dots
.fw-dot {
  width: 8px; height: 8px; border-radius: 50%; display: inline-block;
  &.green  { background: var(--fw-green); }
  &.amber  { background: var(--fw-amber); }
  &.red    { background: var(--fw-red); }
  &.blue   { background: var(--fw-blue); }
  &.gray   { background: var(--fw-gray); }
}

// Inspection pill buttons
.fw-pill-btn {
  height: 36px; padding: 0 22px; font-size: 14px; font-weight: 500;
  border: 1px solid var(--fw-border-mid); border-radius: var(--fw-radius-md);
  background: var(--fw-bg-primary); color: var(--fw-text-secondary);
  cursor: pointer; font-family: var(--fw-font-sans); transition: all 0.15s;
  &.pass.selected  { background: var(--fw-green); border-color: var(--fw-green); color: #fff; }
  &.fail.selected  { background: var(--fw-red);   border-color: var(--fw-red);   color: #fff; }
}

// Pass schedule confirm bar
.fw-ps-confirm-bar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 7px 12px; border-radius: var(--fw-radius-md); margin-bottom: 6px; gap: 12px;
  background: var(--fw-bg-warning); transition: background 0.2s;
  &.confirmed { background: var(--fw-bg-success); }
}

// SPC status badge
.fw-spc-status {
  display: flex; align-items: center; gap: 8px; padding: 0 18px; height: 42px;
  background: var(--fw-bg-success); color: var(--fw-text-success);
  border-radius: var(--fw-radius-md); font-size: 14px; font-weight: 500; white-space: nowrap;
  &.out-of-spec { background: var(--fw-bg-danger); color: var(--fw-text-danger); }
}
```

## Step 9 — Service Registration in Angular

In `flat-wire-shopfloor.module.ts`:

```typescript
@NgModule({
  declarations: [
    Dashboard2RodCheckinComponent,
    Dashboard5SpoolCheckinComponent,
    PassScheduleTableComponent
  ],
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule.forChild(FLAT_WIRE_ROUTES)
  ],
  providers: [
    {
      provide: FlatWireApiService,
      useClass: environment.useMockData ? FlatWireApiMockService : FlatWireApiRealService
    }
  ]
})
export class FlatWireShopfloorModule {}
```

---

## Step 10 — Acceptance Tests to Verify

Manually verify the following after implementation. Open the original HTML mockup side-by-side to compare visual output.

**Dashboard 2 visual fidelity:**
1. Background is warm off-white (`#f5f4ee`), not pure white or Bootstrap grey
2. FL1 line badge is blue info pill (top left header)
3. Payoff selector uses card-style div tiles, not browser radio buttons
4. Inspection rows use pill `Pass`/`Fail` buttons — green/red fill when selected
5. Pass schedule confirm bar is amber background; turns green after "Confirm Schedule" click
6. Acknowledge button remains disabled until pass schedule is confirmed
7. Footer shows progress ring SVG (fraction counter) left, buttons right
8. Dark mode: toggle OS dark mode — all backgrounds invert correctly via CSS variables

**Dashboard 2 functional:**
1. Type `R00041`, blur → alloy "1100", temper fills, diameter pre-fills in ~300ms
2. Type `XXXXX` → rod-identified badge stays `.rod-waiting` (amber); Acknowledge blocked
3. Any inspection pill set to Fail → Acknowledge disabled
4. "Confirm Schedule" click → bar turns green, Acknowledge button enables
5. SPC: enter M1 value within tolerance → green "In spec" badge; enter out-of-range → red badge
6. Ovality (|M1−M2|) computed and displayed live
7. Click Acknowledge → 800ms delay → navigates to active run placeholder

**Dashboard 5 visual fidelity:**
1. Source traceability section shows rod rows and weld event row with amber icon
2. Gauge profile is an SVG — blue trace line, green tolerance band, amber weld marker
3. Stats row shows min/max/avg/samples below the chart
4. Pass schedule table has 5 rows; 8" Roller row is visually dimmed (opacity 0.6, bypass state)

**Dashboard 5 functional:**
1. Type `SP-00021` → source rods "R00041, R00042", alloy "1100" auto-fill
2. SVG gauge chart renders with all points in spec
3. Confirm Schedule → bar turns green, Acknowledge enables
4. Click Acknowledge → navigates to FL2 active run placeholder

**.NET API (`https://localhost:5010`):**
1. `GET /api/v1/flatwire/rod/R00041` → 200 with rod fixture
2. `GET /api/v1/flatwire/rod/BADROD` → 404
3. `POST /api/v1/flatwire/checkin/rod` valid body → 200 with RunId RUN-0042, plcTagsPushed: true
4. `POST /api/v1/flatwire/checkin/rod` with any inspection Fail → 400 with error message
5. Swagger UI at `/swagger` shows all endpoints with correct request/response schemas

---

## What NOT to Build in This Phase

- PLC tag write logic (PLCTagService exists only as a stub comment)
- Database tables or EF Core context (no real persistence yet)
- SignalR broadcast on check-in (add later when hub is live)
- Navigation to a real Dashboard 3 (placeholder route is fine)
- FL2 historical gauge chart from real API (use the 50-point mock array)
- OQ-51 pass schedule selection (assume single active schedule per line)
- Authentication integration (hardcode `operatorId: 'john.d'` for now)

---

## Reference Files to Study Before Starting

**Mockups (primary visual reference — port HTML directly):**
- `C:\UAL\Flat Wire\Mockups\dashboard_2_rod_checkin.html` — Dashboard 2 complete HTML + CSS + JS
- `C:\UAL\Flat Wire\Mockups\dashboard_5_spool_checkin.html` — Dashboard 5 complete HTML + CSS + JS
- `C:\UAL\Flat Wire\Mockups\dashboard_3_active_run_v2.html` — the destination after check-in *(was `dashboard_3_active_run.html`, withdrawn 1 Aug 2026)*

**API and backend patterns:**
- `c:/UAL/ual-api/API/Domain/CoilCheckin/CoilCheckin.API/Controllers/CoilCheckin/CoilCheckinController.cs` — controller pattern
- `c:/UAL/ual-api/API/Domain/CoilCheckin/CoilCheckin.Application/Commands/CoilCheckin/CoilCheckinCommand.cs` — MediatR command pattern

**Angular library structure:**
- `c:/UAL/ual-angular/projects/checkin-precheckin/src/lib/` — existing check-in library to mimic for structure (but NOT for CSS — that library uses different styling)

**Specs and contracts:**
- `c:/UAL/Flat Wire/DevelopmentPlan/APIContracts.md` — full API contract reference (Sprint 3 section)
- `c:/UAL/Flat Wire/LatestDocument/RequirementDocuments/RocCheckin.md` — 5-step check-in flow design
- `c:/UAL/Flat Wire/DevelopmentPlan/CheckinImplementationPlan.md` — the plan this prompt implements
