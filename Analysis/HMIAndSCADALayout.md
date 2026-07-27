# Flat Wire Mill — HMI Screen & SCADA Chart Layout

**Project:** Flat Wire Mill Implementation
**Last Updated:** May 15, 2026
**Document Type:** UX / Screen Design Reference
**Status:** Draft — Resolves OQ-4 (SCADA chart layout owner and timeline)

---

## Overview

This document defines two new screens and one enhancement to an existing screen:

| # | Screen | Primary User | Trigger | Priority |
|---|--------|-------------|---------|----------|
| 13 | Line Schematic (HMI View) | Supervisor / Operator | From Dashboard 1 line card or Dashboard 3 tab | High |
| 14 | SCADA Multi-Trend Charts | Operations / Supervisor / Engineering | From Dashboard 1 header or Dashboard 3 action bar | High |
| 3+ | Dashboard 3 — Machine View Tab | FL1 / FL2 / FL3 Operator | Tab toggle during active run | High |

### Resolution of OQ-4

OQ-4 asked: *"UA is responsible for defining the SCADA chart layout and machine tags for flat wire. No owner or delivery date has been specified."*

**Decision (May 15, 2026):** The SCADA chart layout is defined in this document as Dashboard 14. All machine tags required for the HMI and SCADA displays are defined in the PLC Tag Mapping table at the end of this document. Owner: development team in coordination with Tim O. for tag path confirmation.

---

## Dashboard 13 — Line Schematic (HMI View)

**Who:** Supervisor / Operator
**When:** Accessed from Dashboard 1 (click on a line card → "Open HMI" button) or from the Machine View tab in Dashboard 3
**Purpose:** Full-screen graphical SVG schematic of the flat wire line with live PLC data overlaid on every component; route-adaptive layout that reconfigures for FL1, FL2, or FL3 operation

### Wireframe

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  [ ← Line Status ]   FL1 — LINE SCHEMATIC   ● RUNNING   FW-00421 / R00042        │
│                       Speed: 1,620 FPM   Footage: 12,450 ft   07:42 AM            │
│  Route: [● FL1 Standalone]  [ FL2 Standalone]  [ FL3 Hybrid]                     │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                   │
│  ══ PAYOFF ══════════════════════════════════════════════════════════════════════  │
│                                                                                   │
│   ┌─────────────────────┐      ┌─────────────────────┐                           │
│   │    PAYOFF 1         │      │    PAYOFF 2          │                           │
│   │  ■■■■■■■░░░░░░░░░░  │      │  ■■■■■■■■■■■■■■■■   │                           │
│   │  4,200 lb  (47%)    │      │  8,500 lb  (READY)  │                           │
│   │  ⚠ WELD SOON        │      │  ✓ READY            │                           │
│   └─────────┬───────────┘      └──────────┬──────────┘                           │
│             └──────────────┬──────────────┘                                       │
│                            │  wire flow ───────────────►                          │
│                            ▼                                                      │
│  ══ DRAW ═══════════════════════════════════════════════════════════════════════  │
│                                                                                   │
│              ┌──────────────────┐     ┌──────────────────┐                       │
│              │      DB1         │────►│      DB2         │                       │
│              │  ● ACTIVE        │     │  ● ACTIVE        │                       │
│              │  Die: 0.340"     │     │  Die: 0.310"     │                       │
│              └──────────────────┘     └────────┬─────────┘                       │
│                                                │                                  │
│  ══ FLATTEN ════════════════════════════════════════════════════════════════════  │
│                                                │                                  │
│                                    ┌───────────▼──────────┐                      │
│                                    │     FM1  12" MILL    │                      │
│                                    │  ● ACTIVE            │                      │
│                                    │  Roll Gap: 0.112"    │                      │
│                                    │  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │                      │
│                                    │  ◉ GAUGE: 0.110" ✓   │                      │
│                                    └──────────┬───────────┘                      │
│                                               │                                   │
│                                    ┌──────────▼───────────┐                      │
│                                    │      EDGE SET        │                      │
│                                    │  ● ACTIVE            │                      │
│                                    │  Type: Round Edge    │                      │
│                                    └──────────┬───────────┘                      │
│                                               │                                   │
│                             ┌─────────────────┴────────────────────┐             │
│                             │     (FL1 out)         (FL3 continues) │             │
│                             ▼                                       ▼             │
│  ══ TAKEUP-1 ══════════════════════  ══ 3-STAND MILL (FM2) ═════════════════════ │
│                                                                                   │
│  ┌──────────────────────────────┐   ┌──────────────────────────────────────────┐ │
│  │    TKUP-1  (Intermediate)    │   │  FM2-8"      FM2-6"S1   FM2-6"S2 (final)│ │
│  │  ● SPOOL FILLING             │   │  ● 0.117"  ─►● 0.0162" ─►● 0.0160"     │ │
│  │  3,200 ft  /  2,400 lb       │   │  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │ │
│  └──────────────────────────────┘   │  ◉ WIDTH: 0.625" ✓                      │ │
│                                     └────────────────────────────┬─────────────┘ │
│                                                                   │               │
│  ══ TAKEUP-2 ════════════════════════════════════════════════════════════════════ │
│                                                                   ▼               │
│                                          ┌────────────────────────────────────┐  │
│                                          │    TKUP-2  (Output Coil)           │  │
│                                          │  ● WINDING                         │  │
│                                          │  14,200 ft  /  980 lb              │  │
│                                          └────────────────────────────────────┘  │
│                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────┤
│  ALERTS  ⚠ Payoff 1 — 4,200 lb — prepare weld (Payoff 2 ready)                  │
│           ✓ All gauge and width readings in spec                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

### Component Node Data

Each equipment box on the schematic shows the following live data:

| Component | Status Indicator | Parameter Displayed | Live Measurement |
|-----------|-----------------|---------------------|-----------------|
| Payoff 1 | Green / Amber (≤25%) / Red (≤10%) + pulsing | Weight (lb) + % remaining | Load cell via PayoffWeight SignalR |
| Payoff 2 | Green (ready) / Grey (not loaded) | Weight (lb) + READY / NOT LOADED badge | Load cell via PayoffWeight SignalR |
| DB1 | Green (active) / Grey (bypassed) | Die diameter (inches) | Pass schedule + ComponentStatus SignalR |
| DB2 | Green (active) / Grey (bypassed) | Die diameter (inches) | Pass schedule + ComponentStatus SignalR |
| FM1 12" Mill | Green (active) / Red (fault) | Roll gap (inches) | Pass schedule + ComponentStatus SignalR |
| Gauge sensor (FM1 out) | Green (in-spec) / Red (out-of-spec) | Live gauge reading (inches) | GaugeReading SignalR |
| Edge Set | Green (active) / Grey (bypassed) | Edge type | Pass schedule + ComponentStatus SignalR |
| FM2-8" Roller | Green (active) / Grey (bypassed) | Roll gap (inches) | Pass schedule + ComponentStatus SignalR |
| FM2-6" S1 | Green (active) / Grey (bypassed) | Roll gap (inches) | Pass schedule + ComponentStatus SignalR |
| FM2-6" S2 | Green (active) / Red (fault) — cannot be bypassed | Roll gap (inches) | Pass schedule + ComponentStatus SignalR |
| Width sensor (FM2-S2 out) | Green (in-spec) / Red (out-of-spec) | Live width reading (inches) | WidthReading SignalR |
| TKUP-1 | Green (filling) / Grey (idle) | Footage (ft) + Weight (lb) | Footage counter + load cell |
| TKUP-2 | Green (winding) / Grey (idle) | Footage (ft) + Weight (lb) | Footage counter + load cell |

### Flow Animation

When `SpeedFPM > 0`, animated dashes travel along the connector paths between components (CSS `stroke-dashoffset` animation at a rate proportional to FPM). Animation stops when the line is paused or idle. Paused state shows static orange dashes; fault state shows static red dashes.

### Route Variants

The schematic reconfigures based on the active line route:

| Route | Active Components | Hidden / Greyed Components |
|-------|-----------------|---------------------------|
| FL1 Standalone | Payoffs → DB1/DB2 → FM1 → EdgeSet → TKUP-1 | FM2 stands, TKUP-2 (shown greyed) |
| FL2 Standalone | TPO/Payoff → FM2 (8", 6"S1, EdgeSet, 6"S2) → TKUP-2 | DB1, DB2, FM1, EdgeSet, TKUP-1 (shown greyed) |
| FL3 Hybrid | All components active end-to-end | TKUP-1 hidden (wire passes through without stopping) |

Greyed components display "BYPASS" or "OFFLINE" badge in place of parameter values. Component boxes are visually dimmed (40% opacity) to indicate they are inactive for the current route.

### Alert Bar

Fixed at the bottom of the schematic. Displays the same alert rules as Dashboard 1:

| Condition | Alert Level | Message |
|-----------|-------------|---------|
| Payoff 1 weight < 3,000 lb | Warning | Prepare weld — Payoff 2 must be ready |
| Gauge outside target ± tolerance | Warning | Gauge deviation — FL1 / FL3 |
| Component PLC fault | Critical | Component fault — line stopped |
| Active WIP rejection | Warning | WIP rejection requires disposition |
| Payoff 2 not loaded when Payoff 1 < 2,000 lb | Critical | No weld material available |

### Navigation

| From | To | Trigger |
|------|----|---------|
| Dashboard 1 line card | Dashboard 13 (that line) | "Open HMI" button on line card |
| Dashboard 3 Machine View tab | Dashboard 13 (full screen) | "Open full screen" icon |
| Dashboard 13 | Dashboard 1 | "← Line Status" back button |
| Dashboard 13 | Dashboard 3 | "Active Run" button (if run is active) |
| Dashboard 13 | Dashboard 14 | "SCADA Trends" button in header |

---

## Dashboard 3 Enhancement — Machine View Tab

**Where:** Inside Dashboard 3 — Active Run Monitor, replacing the two trace panels with a tab strip
**Purpose:** Allow operators to toggle between the live trace chart view and the graphical machine schematic without leaving the active run context

### Tab Toggle Layout

```
┌──────────────────────────────────────────────────────────────────────────┐
│  [ Traces ]  [ Machine View ]                                             │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   TRACES tab (default, unchanged):                                        │
│   ┌────────────────────────┐  ┌────────────────────────┐                 │
│   │  Gauge trace chart     │  │  Width trace chart     │                 │
│   │  (existing DB3 panel)  │  │  (existing DB3 panel)  │                 │
│   └────────────────────────┘  └────────────────────────┘                 │
│                                                                           │
│   MACHINE VIEW tab (new):                                                 │
│   ┌──────────────────────────────────────────────────────────────────┐   │
│   │  Compressed line schematic — same layout as Dashboard 13 but     │   │
│   │  scaled to fit the 440px-tall trace area                         │   │
│   │  Components: status + primary value only (no secondary readings)  │   │
│   │  ┌─────────────┐  ┌─────────────┐  Gauge ◉ 0.110" ✓             │   │
│   │  │  PAYOFF 1   │  │  PAYOFF 2   │                                │   │
│   │  │  4,200 lb ⚠ │  │  READY ✓   │  ┌───────┐  ┌───────┐         │   │
│   │  └──────┬──────┘  └──────┬──────┘  │  DB1  │─►│  DB2  │         │   │
│   │         └────────┬───────┘          │ 0.340"│  │ 0.310"│         │   │
│   │                  ▼                  └───────┘  └───────┘         │   │
│   │         ┌─────────────────┐              │                        │   │
│   │         │  FM1 / EdgeSet  │◄─────────────┘                        │   │
│   │         │  Gap: 0.112"    │  Width ◉ 0.625" ✓                    │   │
│   │         └────────┬────────┘                                       │   │
│   │                  ▼                                                 │   │
│   │         ┌─────────────────┐  [↗ Open full screen]                 │   │
│   │         │  FM2 / TKUP     │                                       │   │
│   │         │  Width: 0.625"  │                                       │   │
│   │         └─────────────────┘                                       │   │
│   └──────────────────────────────────────────────────────────────────┘   │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

### Tab Behaviour

| Rule | Detail |
|------|--------|
| Default tab | Traces (unchanged existing view) |
| Tab preference persisted | Browser localStorage — operator's last-used tab restored on page load |
| Machine status grid | Always visible below tabs regardless of which tab is active |
| Action buttons | Always visible at bottom regardless of which tab is active |
| Full screen link | "↗ Open full screen" in Machine View tab opens Dashboard 13 for the active line |
| Real-time updates | Machine View schematic updates from the same SignalR stream as the Traces tab |

### Compressed Schematic Rules

The Machine View tab fits the same schematic into 440px height by:
- Removing section headers (PAYOFF / DRAW / FLATTEN labels)
- Reducing component box height from ~70px to ~40px
- Showing only: component name, status dot, and primary value (one line)
- Removing the width sensor / gauge sensor labels (reading shown inline with component)
- Keeping animated flow arrows but at smaller size

---

## Dashboard 14 — SCADA Multi-Trend Charts

**Who:** Operations Manager / Supervisor / Engineering
**When:** Accessed from Dashboard 1 header ("SCADA Trends" button), from Dashboard 3 action bar ("View Trends"), or from Dashboard 13 header ("SCADA Trends" button)
**Purpose:** Multi-pen time-series trend chart for gauge, width, speed, and payoff weight; configurable time window; exportable; resolves OQ-4

### Wireframe

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  [ ← Active Run ]   SCADA TRENDS — FL1   FW-00421 / R00042              07:42 AM │
│  Line: [● FL1]  [FL2]  [FL3]    Time: [30 min] [● 1 hr] [4 hr] [Shift] [Custom] │
│                                                              [ Export CSV ]  [ ⚙ ] │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                   │
│  CHART 1 — GAUGE (inches)           Target: 0.110"  ±0.002"   UCL: 0.113" LCL: 0.107" │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │ 0.116 ─────────────────────────────────────────────────── ← OOS band (red) │ │
│  │ 0.113 ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ← UCL (dashed)  │ │
│  │       ┌─────────────────────────────────────────────────── ← spec band     │ │
│  │ 0.110 │ ─────────────────────────────────────────────────── ← target       │ │
│  │       └─────────────────────────────────────────────────── (green fill)    │ │
│  │ 0.107 ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ← LCL (dashed)  │ │
│  │ 0.104 ─────────────────────────────────────────────────── ← OOS band (red) │ │
│  │                                                                             │ │
│  │  ─── gauge trace (blue)    ▲ Weld @ 12,450ft    ✦ Die change @ 8,220ft    │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                   │
│  CHART 2 — WIDTH (inches)           Target: 0.625"  ±0.005"                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │  Width trace with tolerance band (green) + SPC control limits (dashed)     │ │
│  │  Same visual language as Chart 1; shared event markers on x-axis           │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                   │
│  ┌──────────────────────────────────────┐  ┌─────────────────────────────────┐   │
│  │  CHART 3 — SPEED (FPM)              │  │  CHART 4 — PAYOFF WEIGHT (lb)  │   │
│  │  0 – 2,500 FPM                      │  │  0 – 10,000 lb                 │   │
│  │  ─── speed trace (teal)             │  │  ─── Payoff 1 (solid blue)     │   │
│  │  Grey shading = line paused         │  │  ─ ─ Payoff 2 (dashed blue)    │   │
│  │  Pause reason label on hover        │  │  ── 3,000 lb weld threshold    │   │
│  └──────────────────────────────────────┘  └─────────────────────────────────┘   │
│                                                                                   │
│  EVENT TIMELINE (shared x-axis, all charts synchronized)                          │
│  ──────────────────────────────────────────────────────────────────────────────  │
│  ▲ Weld (R00041→R00042)    ✦ Die change (DB2: 0.310→0.308)    ⏸ Pause (8 min)   │
│  ◆ SPC checkpoint          ⚠ Alert raised                                         │
└──────────────────────────────────────────────────────────────────────────────────┘
```

### Chart Specifications

| Chart | Pen(s) | Y-Axis Range | Default | Control Lines |
|-------|--------|-------------|---------|---------------|
| Gauge | Gauge reading (live / historical) | Auto-scaled around target ± 3× tolerance | 0.090"–0.130" | Target centerline (green dashed); ±tolerance band (green fill); UCL/LCL (red dashed); OOS shading (red fill beyond spec) |
| Width | Width reading (live / historical) | Auto-scaled around target | 0.580"–0.670" | Same as gauge |
| Speed | Line speed FPM | 0 – max speed from pass schedule + 10% | 0 – 2,500 FPM | Max speed line from pass schedule; paused periods shaded grey |
| Payoff weight | Payoff 1 (solid) + Payoff 2 (dashed) | 0 – 10,000 lb | Fixed | 3,000 lb weld-soon threshold (amber dashed line) |

### Time Window Options

| Window | Description | X-Axis Labels |
|--------|-------------|--------------|
| 30 min | Last 30 minutes of run data | Every 5 minutes |
| 1 hr | Last hour | Every 10 minutes |
| 4 hr | Last 4 hours (spans multiple rods if welds occurred) | Every 30 minutes |
| Shift | Full current shift (all runs on this line) | Every hour |
| Custom | Date/time range picker | Configurable |

### Event Markers (shared across all charts on the same x-axis)

| Event | Symbol | Colour | Data Source |
|-------|--------|--------|-------------|
| Weld join | ▲ triangle | Amber | WeldJoinEvent records |
| Die change | ✦ diamond | Blue | DieChangeEvent records |
| Pause start/end | ⏸ ▶ brackets | Grey | PauseEvent records |
| SPC checkpoint | ◆ diamond | Purple | SPCCheckpoint records |
| Alert raised | ⚠ warning | Red | AlertEvent records |
| Alert cleared | ✓ checkmark | Green | AlertEvent records |
| Rod checkout | ✕ cross | Orange | RodCheckoutEvent records |

### SPC Control Limits

Control limits are calculated from the last N measurements (configurable, default N = 25 per run) using standard X̄-R chart methodology:

| Limit | Formula | Display |
|-------|---------|---------|
| UCL (Upper Control) | X̄ + 3σ | Dashed red line above spec band |
| LCL (Lower Control) | X̄ − 3σ | Dashed red line below spec band |
| USL (Upper Spec) | Target + tolerance | Top edge of green band |
| LSL (Lower Spec) | Target − tolerance | Bottom edge of green band |

Out-of-spec regions (between USL/UCL and beyond) shaded red with low opacity. In-spec region shaded green with low opacity.

### Export

Clicking **Export CSV** generates a download with columns:

```
Timestamp, Footage_ft, Gauge_in, Width_in, Speed_FPM, Payoff1_lb, Payoff2_lb,
GaugeSpec_in, GaugeTol_in, WidthSpec_in, WidthTol_in, EventType, EventDetail
```

One row per SignalR reading interval (default: 1 second). Event rows have gauge/width/speed fields populated with the value at that moment.

### Settings Panel (⚙ button)

| Setting | Options | Default |
|---------|---------|---------|
| Update interval | 1s / 5s / 10s / 30s (live mode) | 1s |
| SPC sample size | 10 / 25 / 50 readings | 25 |
| Show control limits | On / Off | On |
| Chart layout | 2 tall + 2 small (default) / 4 equal / Gauge only / All stacked | Default |
| Dark mode | Toggle | Inherited from system |

### Navigation

| From | To | Trigger |
|------|----|---------|
| Dashboard 1 header | Dashboard 14 (line selector shown) | "SCADA Trends" button |
| Dashboard 3 action bar | Dashboard 14 (active line pre-selected) | "View Trends" button |
| Dashboard 13 header | Dashboard 14 (same line) | "SCADA Trends" button |
| Dashboard 14 | Dashboard 3 | "← Active Run" back button (if run active) |
| Dashboard 14 | Dashboard 1 | "← Line Status" (if no active run) |

---

## PLC Tag Mapping

All tags required for the HMI schematic (Dashboard 13) and SCADA charts (Dashboard 14). Tag paths are configuration-driven in `appsettings.json` — not hardcoded.

### Real-Time SignalR Events (FlatWireHub)

| Event | Payload Fields | Consumers |
|-------|---------------|-----------|
| `GaugeReading` | `lineId, value (in), timestamp, footagePosition` | DB13 gauge sensor node, DB14 Chart 1, DB3 Machine View |
| `WidthReading` | `lineId, value (in), timestamp, footagePosition` | DB13 width sensor node, DB14 Chart 2, DB3 Machine View |
| `SpeedFPM` | `lineId, value (FPM), timestamp` | DB13 flow animation, DB14 Chart 3, DB13 header |
| `PayoffWeight` | `lineId, position (1\|2), weightLb, percentRemaining` | DB13 payoff boxes, DB14 Chart 4 |
| `ComponentStatus` | `lineId, component, isActive, currentValue` | DB13 all component boxes |
| `LineStatus` | `lineId, status, orderId, alpha` | DB13 header badge |
| `AlertRaised` | `lineId, alertType, severity, message, timestamp` | DB13 alert bar |
| `AlertCleared` | `lineId, alertType` | DB13 alert bar |
| `FootageCounter` | `lineId, footage (ft), timestamp` | DB13 TKUP nodes, DB13 header |

### OPC Tag Paths (FL1 example — FL2/FL3 follow same pattern)

| Tag Path (OPC) | Description | Used In |
|---------------|-------------|---------|
| `FL1.DB1.Die.ActiveDiameter` | DB1 current die diameter (in) | DB13 DB1 node |
| `FL1.DB1.Status.Active` | DB1 active (bool) | DB13 DB1 status colour |
| `FL1.DB2.Die.ActiveDiameter` | DB2 current die diameter (in) | DB13 DB2 node |
| `FL1.DB2.Status.Active` | DB2 active (bool) | DB13 DB2 status colour |
| `FL1.FM1.RollGap.Current` | FM1 current roll gap (in) | DB13 FM1 node |
| `FL1.FM1.Status.Active` | FM1 running (bool) | DB13 FM1 status colour |
| `FL1.FM1.Status.Fault` | FM1 fault (bool) | DB13 FM1 fault colour |
| `FL1.AGC.Gauge.Current` | Live gauge reading post-FM1 (in) | DB13 gauge sensor, DB14 Chart 1 |
| `FL1.AGC.Width.Current` | Live width reading (in) | DB13 width sensor, DB14 Chart 2 |
| `FL1.Speed.FPM` | Line speed (FPM) | DB13 animation, DB14 Chart 3 |
| `FL1.Payoff1.Weight.Lb` | Payoff 1 load cell weight (lb) | DB13 payoff 1, DB14 Chart 4 |
| `FL1.Payoff2.Weight.Lb` | Payoff 2 load cell weight (lb) | DB13 payoff 2, DB14 Chart 4 |
| `FL1.EdgeSet.Status.Active` | Edge set active (bool) | DB13 EdgeSet node |
| `FL1.TKUP1.Footage.Current` | TKUP-1 footage counter (ft) | DB13 TKUP-1 node |
| `FL1.TKUP2.Footage.Current` | TKUP-2 footage counter (ft) | DB13 TKUP-2 node |
| `FL2.FM2.Stand8.RollGap.Current` | FM2 8" roller current gap | DB13 FM2-8" node |
| `FL2.FM2.Stand6S1.RollGap.Current` | FM2 6" S1 current gap | DB13 FM2-6"S1 node |
| `FL2.FM2.Stand6S2.RollGap.Current` | FM2 6" S2 current gap (final) | DB13 FM2-6"S2 node |
| `FL2.FM2.Stand8.Status.Active` | FM2 8" roller active | DB13 FM2-8" status |
| `FL2.FM2.Stand6S1.Status.Active` | FM2 6" S1 active | DB13 FM2-6"S1 status |
| `FL2.FM2.Stand6S2.Status.Active` | FM2 6" S2 active (always true) | DB13 FM2-6"S2 status |

> **Note:** Exact OPC tag paths must be confirmed with Tim O. and the PLC commissioning engineer before go-live. These paths follow the naming convention proposed in `appsettings.json` and can be updated without redeployment.

---

## Design Principles

| Principle | Detail |
|-----------|--------|
| **Route-adaptive schematic** | The HMI layout reconfigures automatically for FL1 / FL2 / FL3 — bypassed components are dimmed, not removed, so operators can see the full machine at all times |
| **Touch-first** | All interactive elements ≥ 48px tap target; no hover-dependent states; component boxes large enough to read at arm's length from a shop floor monitor |
| **Always-live** | HMI and SCADA charts reconnect automatically after network drop (matching the existing SignalR reconnect pattern from Dashboard 3) |
| **Shared color tokens** | Use existing design tokens: green `#1D9E75` (active / in-spec), amber `#EF9F27` (warning / weld-soon), red `#D85A30` (fault / out-of-spec), grey (bypassed / offline) |
| **Monospace readings** | All numeric values (gauge, width, speed, weight, footage) rendered in `var(--font-mono)` for operator readability |
| **No printed output** | Consistent with the flat wire digital-traveler decision (April 28, 2026) — no print action on HMI or SCADA screens |

---

## Navigation Map Update

```
Dashboard 1 ──[Open HMI]──────────────────────► Dashboard 13 (Line Schematic)
              ──[SCADA Trends]────────────────► Dashboard 14 (SCADA Trends)
                                                       │
Dashboard 3 ──[Machine View tab]──────────────► Dashboard 13 (full screen ↗)
              ──[View Trends btn]─────────────► Dashboard 14

Dashboard 13 ──[SCADA Trends btn]────────────► Dashboard 14
              ──[← Line Status]──────────────► Dashboard 1
              ──[Active Run btn]─────────────► Dashboard 3

Dashboard 14 ──[← Active Run]────────────────► Dashboard 3
              ──[← Line Status]──────────────► Dashboard 1
```

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) | Full shopfloor dashboard inventory — all 14 screens |
| [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) | Open questions register — OQ-4 resolved by this document |
| [ShopfloorAndRealTimePlan.md](../DevelopmentPlan/ShopfloorAndRealTimePlan.md) | Sprint plan — SignalR hub, PLC tag service |
| [APIContracts.md](../DevelopmentPlan/APIContracts.md) | API and SignalR event contracts |
| [TechStackRecommendation.md](../DevelopmentPlan/TechStackRecommendation.md) | Stack decisions — Chart.js, SignalR, Angular |

---

## Change Log

| Date | Changed By | Description |
|------|-----------|-------------|
| May 15, 2026 | Plan team | Initial document — Dashboard 13 (HMI Schematic), Dashboard 14 (SCADA Trends), Dashboard 3 Machine View tab; resolves OQ-4 |
