# Flat Wire Processing — HMI Schematic and SCADA Trend Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3
**Version:** 2.0
**Last Updated:** August 1, 2026
**Status:** Issued for Client Review and Sign-off
**Screen reference:** Dashboard 13 — Line Schematic (HMI view) · Dashboard 14 — SCADA Trends · Machine View tab on the Active Run Monitor
**Requirement source:** SRS HMI rules (`HMI001` and following); resolves the outstanding question of SCADA chart layout ownership

---

## Document Change History

| Version | Date | Description |
|---|---|---|
| 1.0 | May 15, 2026 | Initial specification — line schematic, SCADA multi-trend charts, the Machine View tab, and the machine tag map. Resolved the open question on SCADA chart layout ownership. |
| 2.0 | Aug 1, 2026 | **Issued for client review.** Equipment corrected throughout: **FL1 has no edger**, and FM2 has **three** 6″ stands with edgers at S2 and S3. Payoff indication corrected from percentage bands to **absolute weight thresholds**, aligning it with the weld alerts. Restructured as a client deliverable; the missing tag path for the final stand and the panel resolution raised as client questions. |

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 7. |

Open item identifiers prefixed **Q** come from the project open-questions register; those prefixed **OI** come from the master specification's open-items register.

---

# 1. Introduction

## 1.1 Purpose

Two screens and one enhancement:

| # | Screen | Primary user | Purpose |
|---|---|---|---|
| **13** | **Line Schematic (HMI view)** | Supervisor / Operator | A full-screen graphical representation of the line with live machine data on every component, reconfiguring itself for FL1, FL2 or FL3 |
| **14** | **SCADA Trends** | Operations / Supervisor / Engineering | Multi-pen time-series trends for gauge, width, speed and payoff weight, with a configurable window, shared event markers and export |
| **3+** | **Machine View tab** | Line operator | The same schematic, compressed, inside the active run monitor so the operator can switch between traces and machine view without leaving the run |

## 1.2 What this document resolves `[CONFIRMED — May 15, 2026]`

United Aluminum was to define the SCADA chart layout and the machine tags for flat wire, and no owner or date had been set. **The chart layout is specified here as Dashboard 14, and the tags required for both screens are listed in Section 6.** The remaining United Aluminum action is confirmation of the tag paths.

## 1.3 Scope

**In scope:** the schematic content and its route variants; live values shown per component; alerting on the schematic; the trend chart set, control limits, time windows, event markers, export and settings; navigation between the three views; and the machine tag map both screens depend on.

**Not in scope:** the transactional screens these views link to; the underlying alert rules, which are specified with the line status board; SPC control-chart methodology beyond its display here.

## 1.4 Equipment as built `[CONFIRMED — May 21, 2026]`

| Line | Flow | Edger |
|---|---|---|
| **FL1** | Payoff → DB1 → DB2 → **FM1** → intermediate take-up | **None — FL1 has no edger** |
| **FL2** | Spool payoff → **FM2** (8″ → 6″ S1 → 6″ S2 → 6″ S3) → final take-up | **S2 and S3 only** |
| **FL3** | Payoff → DB1 → DB2 → FM1 → *(intermediate take-up bypassed)* → FM2 → final take-up | S2 and S3 |

---

# 2. Dashboard 13 — Line Schematic

**Reached from** the line status board (a line card's *Open HMI* action) or the Machine View tab on the active run monitor.

## 2.1 Layout

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  [← Line Status]   FL1 — LINE SCHEMATIC   ● RUNNING   FW-00421 / R00042      │
│                    Speed 1,620 FPM   Footage 12,450 ft            07:42 AM   │
│  Route:  [● FL1 Standalone]   [ FL2 Standalone ]   [ FL3 Hybrid ]            │
├──────────────────────────────────────────────────────────────────────────────┤
│  ══ PAYOFF ═════════════════════════════════════════════════════════════════ │
│    ┌──────────────────┐        ┌──────────────────┐                          │
│    │   PAYOFF 1       │        │   PAYOFF 2       │                          │
│    │  ■■■■■■■□□□□□□□  │        │  ■■■■■■■■■■■■■■  │                          │
│    │  4,200 lb        │        │  8,500 lb        │                          │
│    │  ⚠ WELD SOON     │        │  ✓ READY         │                          │
│    └────────┬─────────┘        └────────┬─────────┘                          │
│             └───────────┬───────────────┘      wire flow ──────►             │
│  ══ DRAW ═══════════════▼═══════════════════════════════════════════════════ │
│         ┌──────────────┐      ┌──────────────┐                               │
│         │     DB1      │─────►│     DB2      │                               │
│         │  ● ACTIVE    │      │  ● ACTIVE    │                               │
│         │  Die 0.340"  │      │  Die 0.310"  │                               │
│         └──────────────┘      └──────┬───────┘                               │
│  ══ FLATTEN ═════════════════════════▼══════════════════════════════════════ │
│                          ┌────────────────────────┐                          │
│                          │    FM1 — 12" MILL      │   (no edger on FL1)      │
│                          │  ● ACTIVE              │                          │
│                          │  Roll gap 0.112"       │                          │
│                          │  ◉ GAUGE 0.110" ✓      │                          │
│                          └───────────┬────────────┘                          │
│                    ┌─────────────────┴──────────────────┐                    │
│                    │ (FL1 out)              (FL3 continues)                  │
│                    ▼                                    ▼                    │
│  ══ TAKE-UP 1 ═════════════════   ══ 3-STAND FINISHING MILL (FM2) ═════════ │
│  ┌───────────────────────────┐   ┌───────────────────────────────────────┐  │
│  │  TKUP-1  (intermediate)   │   │ 8"      6"S1     6"S2+edg  6"S3+edg   │  │
│  │  ● SPOOL FILLING          │   │ ●0.117" ─►●0.0162" ─►●0.0161" ─►●0.0160"│ │
│  │  3,200 ft / 2,400 lb      │   │ ◉ WIDTH 0.625" ✓                      │  │
│  └───────────────────────────┘   └───────────────────┬───────────────────┘  │
│  ══ TAKE-UP 2 ═══════════════════════════════════════▼═════════════════════ │
│                                  ┌────────────────────────────────────────┐ │
│                                  │  TKUP-2  (output coil)  ● WINDING      │ │
│                                  │  14,200 ft / 980 lb                    │ │
│                                  └────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────────────────────┤
│  ALERTS  ⚠ Payoff 1 — 4,200 lb — prepare weld (Payoff 2 ready)               │
│          ✓ All gauge and width readings in spec                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## 2.2 Live values per component

| Component | Status indication | Value shown | Source |
|---|---|---|---|
| Payoff 1 | By **absolute remaining weight** — see 2.3 | Weight and percent remaining | Load cell |
| Payoff 2 | Ready / not loaded | Weight, with a ready badge | Load cell |
| DB1 · DB2 | Active / bypassed | Die diameter | Pass schedule and component status |
| FM1 | Active / fault | Roll gap | Pass schedule and component status |
| Gauge sensor, FM1 output | In spec / out of spec | Live gauge reading | Live measurement |
| FM2 8″ · 6″ S1 | Active / bypassed | Roll gap | Pass schedule and component status |
| FM2 6″ S2 (+edger) | Active / bypassed | Roll gap, edge type | Pass schedule and component status |
| FM2 6″ S3 (+edger) | Active / fault | Roll gap, edge type | Pass schedule and component status |
| Width sensor, final stand output | In spec / out of spec | Live width reading | Live measurement |
| Take-up 1 · Take-up 2 | Filling / winding / idle | Footage and weight | Footage counter and load cell |

> `[CLIENT INPUT REQUIRED]` **Which finishing stand cannot be bypassed** is stated two ways — 6″ S3 in the SRS, 6″ S2 in the validation rules and the HMI requirement. The equipment correction made S3 the final stand, so S3 is the working answer, but the schematic's "cannot be bypassed" marking depends on your confirmation (OI-04).

## 2.3 Payoff indication `[CONFIRMED]`

**Colour is driven by absolute remaining pounds, not by percentage bands.**

| Condition | Indication |
|---|---|
| Below **3,000 lb** | Warning — *prepare weld* |
| Payoff 2 not loaded **and** Payoff 1 below **2,000 lb** | Critical — no weld material available |

Bar *length* still expresses percent remaining; only the colour is threshold-driven. Against a 9,000 lb position, a percentage ladder escalates against the alerts rather than with them — the strongest visual cue would arrive well after the urgency it signals.

## 2.4 Flow animation

While the line has speed, animated dashes travel along the connectors at a rate proportional to line speed. Animation stops when the line is paused or idle: a paused line shows static amber dashes, a fault shows static red.

## 2.5 Route variants

| Route | Active | Dimmed |
|---|---|---|
| **FL1 standalone** | Payoffs → DB1 / DB2 → FM1 → take-up 1 | The FM2 stands and take-up 2 |
| **FL2 standalone** | Spool payoff → FM2 (8″, 6″ S1, 6″ S2, 6″ S3) → take-up 2 | DB1, DB2, FM1, take-up 1 |
| **FL3 hybrid** | All components, end to end | Take-up 1 is bypassed — the wire passes through without stopping |

**Bypassed components are dimmed, never removed.** The operator should see the whole machine at all times; a component that disappears reads as a component that is missing. Dimmed components show a bypass or offline badge in place of their values.

## 2.6 Alert bar

Fixed at the foot of the schematic, showing the same alerts as the line status board.

| Condition | Level | Message |
|---|---|---|
| Payoff 1 below 3,000 lb | Warning | Prepare weld — Payoff 2 must be ready |
| Gauge outside target tolerance | Warning | Gauge deviation |
| Component fault | Critical | Component fault — line stopped |
| Active WIP rejection | Warning | WIP rejection requires disposition |
| Payoff 2 not loaded with Payoff 1 below 2,000 lb | Critical | No weld material available |

---

# 3. Machine View Tab on the Active Run Monitor

The trace panels gain a tab strip so the operator can switch between the live traces and a compressed schematic without leaving the run.

| Rule | Behaviour |
|---|---|
| Default tab | **Traces** — the existing view, unchanged |
| Tab preference | Remembered per operator and restored on the next visit |
| Machine status grid | Always visible below the tabs, whichever tab is active |
| Action buttons | Always visible, whichever tab is active |
| Full screen | The Machine View tab offers a link to the full schematic for the active line |
| Live updates | The Machine View updates from the same live stream as the traces |

**Compression rules.** The tab shows the same schematic reduced to fit the trace area: section headings removed, component boxes shortened, one value per component (name, status and primary value), sensor readings shown inline with their component rather than as separate nodes, and flow arrows retained at a smaller size.

---

# 4. Dashboard 14 — SCADA Trends

**Reached from** the line status board, the active run monitor, or the schematic.

## 4.1 Chart set

```
┌────────────────────────────────────────────────────────────────────────┐
│ [← Active Run]  SCADA TRENDS — FL1   FW-00421 / R00042        07:42 AM │
│ Line: [● FL1] [FL2] [FL3]   Window: [30 min] [● 1 hr] [4 hr] [Shift]   │
│                                            [ Export CSV ]      [ ⚙ ]   │
├────────────────────────────────────────────────────────────────────────┤
│ CHART 1 — GAUGE       target 0.110" ±0.002"    UCL 0.113"  LCL 0.107"  │
│ CHART 2 — WIDTH       target 0.625" ±0.005"                            │
│ CHART 3 — SPEED (FPM)              │  CHART 4 — PAYOFF WEIGHT (lb)     │
│                                                                        │
│ EVENT TIMELINE — shared x-axis, all charts synchronised                │
│  ▲ Weld    ✦ Die change    ⏸ Pause    ◆ SPC checkpoint    ⚠ Alert     │
└────────────────────────────────────────────────────────────────────────┘
```

| Chart | Pens | Y range | Reference lines |
|---|---|---|---|
| **Gauge** | Gauge reading, live or historical | Auto-scaled around target ± 3 × tolerance | Target centre line; tolerance band; upper and lower control limits; out-of-specification shading beyond the band |
| **Width** | Width reading | Auto-scaled around target | As gauge |
| **Speed** | Line speed | Zero to the pass schedule maximum plus a margin | Maximum speed from the pass schedule; paused periods shaded |
| **Payoff weight** | Payoff 1 solid, Payoff 2 dashed | Zero to the position rating | The 3,000 lb weld-soon threshold |

## 4.2 Time windows

| Window | Content | Axis labels |
|---|---|---|
| 30 minutes | The last 30 minutes of run data | Every 5 minutes |
| 1 hour | The last hour | Every 10 minutes |
| 4 hours | Spans multiple rods where welds occurred | Every 30 minutes |
| Shift | The full current shift, all runs on the line | Hourly |
| Custom | A chosen date and time range | Configurable |

## 4.3 Event markers

Shared across all charts on the same axis, so a deviation can be read against what happened.

| Event | Marker |
|---|---|
| Weld join | Triangle |
| Die change | Diamond |
| Pause start and end | Bracket pair |
| SPC checkpoint | Diamond, distinct colour |
| Alert raised / cleared | Warning / check |
| Rod checkout | Cross |

## 4.4 Control limits

Calculated from the last *N* measurements — configurable, default 25 per run — using standard control-chart methodology.

| Limit | Basis | Display |
|---|---|---|
| Upper / lower **control** limits | Mean ± 3 standard deviations | Dashed lines outside the specification band |
| Upper / lower **specification** limits | Target ± tolerance | The edges of the tolerance band |

The in-specification region is shaded lightly; out-of-specification regions are shaded in the alert colour.

> `[CLIENT INPUT REQUIRED]` **The published tolerance bands per alloy and temper are undefined** — whether ASTM, customer purchase order, or United Aluminum internal. Without them, control limits cannot be configured and these charts produce no meaningful alarm (Q38 / OI-57).

## 4.5 Export

**Export CSV** produces one row per reading interval, with event rows carrying the values in force at that moment:

```
Timestamp, Footage_ft, Gauge_in, Width_in, Speed_FPM, Payoff1_lb, Payoff2_lb,
GaugeSpec_in, GaugeTol_in, WidthSpec_in, WidthTol_in, EventType, EventDetail
```

## 4.6 Settings

| Setting | Options | Default |
|---|---|---|
| Update interval (live mode) | 1 s / 5 s / 10 s / 30 s | 1 s |
| Control-limit sample size | 10 / 25 / 50 readings | 25 |
| Show control limits | On / off | On |
| Chart layout | Two large plus two small / four equal / gauge only / all stacked | Two plus two |

---

# 5. Navigation

| From | To | Trigger |
|---|---|---|
| Line status board | Line schematic | *Open HMI* on a line card |
| Line status board | SCADA trends | *SCADA Trends* |
| Active run monitor | Line schematic | Machine View tab → full screen |
| Active run monitor | SCADA trends | *View Trends* |
| Line schematic | SCADA trends | *SCADA Trends* |
| Line schematic | Line status board / active run | Back, or *Active Run* when a run is open |
| SCADA trends | Active run / line status board | Back |

---

# 6. Machine Data Required

Tag paths are **configuration, not code** — they can be corrected without redeploying the application.

## 6.1 Live data streams

| Stream | Content | Used by |
|---|---|---|
| Gauge reading | Line, value, timestamp, footage position | Schematic sensor node · gauge chart · Machine View |
| Width reading | Line, value, timestamp, footage position | Schematic sensor node · width chart · Machine View |
| Speed | Line, value, timestamp | Flow animation · speed chart · header |
| Payoff weight | Line, position, weight, percent remaining | Payoff nodes · payoff chart |
| Component status | Line, component, active flag, current value | Every component node |
| Line status | Line, status, order, material identity | Header badge |
| Alert raised / cleared | Line, type, severity, message, timestamp | Alert bar |
| Footage counter | Line, footage, timestamp | Take-up nodes · header |

## 6.2 Machine tag paths — FL1 shown, other lines follow the same pattern

| Tag | Description |
|---|---|
| `FL1.DB1.Die.ActiveDiameter` · `FL1.DB1.Status.Active` | DB1 die size and active state |
| `FL1.DB2.Die.ActiveDiameter` · `FL1.DB2.Status.Active` | DB2 die size and active state |
| `FL1.FM1.RollGap.Current` · `FL1.FM1.Status.Active` · `FL1.FM1.Status.Fault` | FM1 gap, active state, fault |
| `FL1.AGC.Gauge.Current` · `FL1.AGC.Width.Current` | Live gauge and width |
| `FL1.Speed.FPM` | Line speed |
| `FL1.Payoff1.Weight.Lb` · `FL1.Payoff2.Weight.Lb` | Payoff load cells |
| `FL1.TKUP1.Footage.Current` · `FL1.TKUP2.Footage.Current` | Take-up footage counters |
| `FL2.FM2.Stand8.RollGap.Current` · `.Status.Active` | FM2 8″ roller |
| `FL2.FM2.Stand6S1.RollGap.Current` · `.Status.Active` | FM2 6″ S1 |
| `FL2.FM2.Stand6S2.RollGap.Current` · `.Status.Active` | FM2 6″ S2 (with edger) |
| **`FL2.FM2.Stand6S3.*`** | **FM2 6″ S3 (with edger) — the final stand. No tag path has been supplied** |

> `[CLIENT INPUT REQUIRED]` **The final stand has no tag path.** The tag map was written before the May 21, 2026 equipment correction added the third 6″ stand and made it the final one. Paths for S3 — roll gap, active state and edger — are required (OI-36).

> `[CLIENT INPUT REQUIRED]` **Every tag path above must be confirmed** with the controls commissioning engineer before go-live. They follow a proposed naming convention, not a verified map.

> `[CLIENT INPUT REQUIRED]` **The line-state vocabulary is undocumented** — the exact values the line-state tag can take (running, stopped, paused, fault, threading?). Several behaviours across the system are conditioned on it (OI-35 / Q63).

---

# 7. Design Principles

| Principle | Detail |
|---|---|
| **Route-adaptive** | The schematic reconfigures for FL1 / FL2 / FL3; bypassed components are dimmed, not removed |
| **Touch-first** | Interactive elements sized for gloved use; no hover-dependent states; component boxes readable at arm's length |
| **Always live** | Both screens reconnect automatically after a network interruption |
| **Numeric values in a fixed-width face** | Gauge, width, speed, weight and footage are read as figures, not prose |
| **No printed output** | Consistent with the flat wire digital-traveler decision — neither screen offers a print action |

> `[CLIENT INPUT REQUIRED]` **The shopfloor panel resolution is unconfirmed** — the screens are authored for 1280 × 1024, and a different panel would change how much of the schematic and how many charts fit at readable size (Q80).

---

# 8. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| D1 | The SCADA chart layout is **specified here as Dashboard 14**; the remaining UA action is tag-path confirmation | May 15, 2026 |
| D2 | Bypassed components are **dimmed, not removed** | May 15, 2026 |
| D3 | Neither screen offers a print action | Apr 28, 2026 |
| D4 | **FL1 has no edger**; FM2 has three 6″ stands with edgers at S2 and S3 | May 21, 2026 |
| D5 | Payoff indication is driven by **absolute weight thresholds**, aligning it with the weld alerts | Jul 29, 2026 |

---

# 9. Open Items Requiring Client Input

| Ref | Priority | Question | What it blocks |
|---|---|---|---|
| **OI-36** | High | **Tag paths for the final finishing stand (6″ S3)** | The schematic node and the pass-schedule push for the final stand |
| — | High | **Confirmation of every machine tag path** with the commissioning engineer | Both screens, before go-live |
| **Q38 / OI-57** | High | **Published tolerance bands** per alloy and temper | Control limits and all trend alarming |
| **OI-04** | High | **Which finishing stand cannot be bypassed** — 6″ S2 or 6″ S3 | The schematic's non-bypassable marking, and pass-schedule validation |
| **OI-35 / Q63** | High | **The line-state vocabulary** | Status badges, flow animation, and several dependent behaviours |
| **Q80** | High | **Shopfloor panel resolution** | Layout of both screens at readable size |

---

# 10. Assumptions

| # | Assumption |
|---|---|
| A1 | The values in Section 6 are all readable from the machine controller and can be published continuously per line. |
| A2 | Load cells are fitted on both payoff positions and on both take-ups. |
| A3 | Gauge and width are measured live on FL1 and FL3; FL2's trace is historical, so its charts render recorded rather than live data. |
| A4 | Historical readings are retained long enough to serve the shift and custom windows. |

---

# 11. Related Specifications

| Document | Relationship |
|---|---|
| [SPC Checkpoint](SPCCheckpoint.md) | Checkpoints appear as event markers; control limits share their tolerance basis |
| [Die Change and Die Management](DieChangeAndManagement.md) | Die changes appear as event markers |
| [Weld Event](WeldEvent.md) | Welds appear as event markers |
| [Rod Pre-Check-in](RodPreCheckin.md) | Source of the payoff weight thresholds shown here |
| [Spool Completion](SpoolCompletionNotification.md) | Shares the line-state dependency |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §1.4 | The equipment flow per line, including FL1 having no edger | ☐ | ☐ |
| §2.1 | The schematic content and arrangement | ☐ | ☐ |
| §2.3 | Payoff indication by absolute weight, not percentage | ☐ | ☐ |
| §2.5 | Bypassed components dimmed rather than removed | ☐ | ☐ |
| §2.6 | The five alert conditions on the schematic | ☐ | ☐ |
| §3 | The Machine View tab and its compression rules | ☐ | ☐ |
| §4.1 | The four-chart set and their reference lines | ☐ | ☐ |
| §4.3 | The event markers carried on the shared axis | ☐ | ☐ |
| §4.5 | The CSV export column set | ☐ | ☐ |
| §7 | No printed output from either screen | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| OI-36 | Tag paths for the final finishing stand | | ☐ |
| — | Confirmation of all machine tag paths | | ☐ |
| Q38 / OI-57 | Published tolerance bands | | ☐ |
| OI-04 | Which finishing stand is non-bypassable | | ☐ |
| OI-35 / Q63 | Line-state vocabulary | | ☐ |
| Q80 | Shopfloor panel resolution | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Engineering / Controls** | | | |
| **IT** | | | |

---

## Change Log

| Date | Change |
|---|---|
| May 15, 2026 | Initial document — line schematic, SCADA trends, Machine View tab, machine tag map; resolved the SCADA chart layout ownership question. |
| Aug 1, 2026 | **Reissued as version 2.0 for client review.** Equipment corrected throughout — the edger removed from the FL1 schematic and flow, and the third 6″ finishing stand added with edgers shown at S2 and S3. Payoff indication corrected from percentage bands to the absolute 3,000 / 2,000 lb thresholds so it escalates with the weld alerts rather than against them. Raised the missing tag path for the final stand, the unconfirmed tag map, the undefined tolerance bands, the non-bypassable stand conflict, the line-state vocabulary and the panel resolution as client questions. Layout wireframes reduced to those that carry information; styling and colour values removed. |
