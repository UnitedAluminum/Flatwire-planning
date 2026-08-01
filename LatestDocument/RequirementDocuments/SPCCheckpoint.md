# SPC Checkpoint — Dashboard Analysis

**Mockup file:** `Mockups/dashboard_6_spc_checkpoint.html`
**Related mockup:** `Mockups/dashboard_die_change.html` (triggers this screen)

---

## Purpose

The SPC Checkpoint screen is a mandatory quality gate that blocks a flat-wire production run from continuing until an operator measures the output wire and confirms it is within dimensional specification. It is surfaced automatically after a die change when the reason is **Gauge drift** or **Size change**, and optionally at any time as a manual spot check.

The screen has two exit paths:
- **Submit · continue run** — all measurements are in spec; run resumes immediately
- **Submit · suspend material** — one or more measurements are out of spec (or operator chooses to hold); output coil is placed on SPC-HOLD for QA review

---

## Entry Points / Triggers

| Trigger | Source | Auto-queued? |
|---|---|---|
| Die change reason = Gauge drift | `dashboard_die_change.html` → "Require SPC on resume" toggle ON | Yes |
| Die change reason = Size change | `dashboard_die_change.html` → "Require SPC on resume" toggle ON | Yes |
| Operator discretion | Any active run | No — manual via spot-check type |

When auto-queued, the run stays in a **blocked** state after the die change is confirmed. **Thread mode is permitted** — the operator may run the line slowly to verify the new die is seated and producing on-target material — but the run cannot return to full production until SPC passes. The "Require SPC on resume" toggle on the die change screen can be switched off to skip this gate; that override must be auditable and is restricted to Operations Manager or Quality role. *(Decided May 4, 2026 — Q56)*

---

## Screen Layout (1280 × 1024 px)

```
┌─────────────────────────────────────────────────────┐
│  Header                                    72 px     │
├─────────────────────────────────────────────────────┤
│  Checkpoint type                          148 px     │
├─────────────────────────────────────────────────────┤
│  Measurements                             flex / ~560 px │
├─────────────────────────────────────────────────────┤
│  Observation                              110 px     │
├─────────────────────────────────────────────────────┤
│  Footer                                    84 px     │
└─────────────────────────────────────────────────────┘
```

---

## Section 1 — Header

### Purpose
Identifies the run context and operator so every checkpoint record is stamped with who, what, and when without the operator having to enter it manually.

### Data displayed

| Field | Example value | Notes |
|---|---|---|
| Back button | "Back to run" | Returns to `dashboard_3_active_run.html`; does NOT cancel or delete the checkpoint |
| Context chip | "FL1 running · checkpoint" | Green pulsing dot; status reflects that the line is running (checkpoint happens mid-run for spot checks) or paused (post-die-change) |
| Page title | "SPC Checkpoint" | Static |
| Order | `FW-00421` | Monospace; links to the active production order |
| Alpha | `R00042` | Monospace; the input coil alpha currently being processed |
| Operator | `Dave M.` | Pulled from the logged-in session; not editable on this screen |
| Date / time | `Apr 23, 2026 · 07:42 AM` | Live clock updated every second via `setInterval` |

### Controls
- **Back to run button** — navigates away without submitting. If measurements have been started, the system should warn the operator that the checkpoint is incomplete and the coil remains in SPC-HOLD.

---

## Section 2 — Checkpoint Type

### Purpose
Distinguishes why this checkpoint was opened. The selected type determines which measurement parameters are required, how the record is categorized, and who may need to be notified.

### Checkpoint type options (3-column selector grid)

#### Pre-run
- **Icon:** Waveform / signal
- **Description:** Incoming material before run start
- **When used:** Verifying incoming rod or intermediate coil dimensions before a new production run begins
- **Measurements required:** Typically input material diameter; may vary by spec

#### Post die change *(default in mockup — selected)*
- **Icon:** Circular arrows (swap/replace)
- **Description:** Required after any die swap
- **When used:** Auto-queued when die change reason is Gauge drift or Size change
- **Measurements required:** Wire diameter at the changed draw box output, gauge, and width at final machine output
- **Trigger banner shown:** Yes — displays the specific die change event that created this checkpoint

#### Manual spot check
- **Icon:** Magnifying glass
- **Description:** Operator discretion, any time
- **When used:** Operator suspects a problem, routine interval check, or supervisor-requested verification
- **Measurements required:** Same set as post-die-change by default; configurable per machine/spec

### Interaction behavior
- Clicking any option applies `.selected` styling (blue border + blue icon background + blue label text)
- Only one option can be selected at a time
- Changing the type after measurements are entered should warn or clear the measurement set if required parameters differ

### Trigger banner (shown for Post die change type only)

A contextual amber banner below the selector that surfaces the specific die change event that created this checkpoint.

| Element | Example | Purpose |
|---|---|---|
| Amber circle icon | Circular arrows | Visual anchor matching the die change reason |
| Die block + change label | "DB2 die change" | Identifies which draw box triggered the checkpoint |
| Size change pill | `0.310" → 0.308"` | Shows the dimension change; monospace in a white-tinted pill |
| Context metadata | "logged at footage 12,450 ft · by Tim O. · 07:38 AM · 4 min ago" | Gives the operator the full event context without leaving the screen |

---

## Section 3 — Measurements

### Purpose
The core of the checkpoint. The operator physically measures the wire at the machine and enters each value. The system evaluates each entry against a target and tolerance, visualizes the position on a tolerance track, and provides a real-time pass/fail result. The section summary and footer button states update live as values are entered.

### Section header

| Element | Details |
|---|---|
| Section title | "Measurements" (static) |
| Section hint | "Measure each value and confirm in spec" |
| Summary badge (right-aligned) | Live count pill — green when all in spec ("3 of 3 in spec"), red when any fail ("N of 3 out of spec"). CSS class `has-fail` switches it to danger styling. |

### Measurement row structure (3 rows in post-die-change mode)

Each row is a 4-column grid: **Info · Input · Tolerance viz · Result**

---

#### Column 1 — Measurement Info

| Sub-element | Details |
|---|---|
| Measurement name | Bold, 15 px — e.g., "Wire diameter", "Gauge", "Width" |
| Measurement context | 12 px grey — location/point of measurement, e.g., "post-DB2 draw", "at FM1 output" |
| Target display | Monospace — e.g., `Target 0.308" ± 0.003"` — shows both target and tolerance |

---

#### Column 2 — Input field

| Property | Details |
|---|---|
| Label | "MEASURED" in small caps above the input |
| Input height | 56 px — large touch target for shop floor use |
| Font | 22 px monospace, center-aligned |
| Border | Default: secondary border. Focus: blue border + blue shadow ring |
| Out-of-spec state | Red border + danger text color applied via `.oos` class on the parent `.measurement` row |
| Input format | Accepts decimal with quote suffix (e.g., `0.309"`) — parser strips non-numeric characters |

---

#### Column 3 — Tolerance visualization

A horizontal track that shows where the measured value falls relative to the target and tolerance band.

| Element | Details |
|---|---|
| Track | Rounded pill, white background with thin border |
| Green band | Centered, spans ±tolerance range (10%–90% of track width in mockup; real implementation maps to ±tolerance) |
| Center line | Vertical hairline at 50% = target value |
| Marker dot | 22 px circle, blue when in spec / red when out of spec. Position is computed dynamically: `pct = 50 + ((measured − target) / (tolerance × 1.67)) × 50`, clamped to 4%–96% |
| Min / center / max labels | Monospace below track showing lower limit, target, and upper limit values |

The display range is ±tolerance × 1.67, meaning the tolerance band occupies the center 60% of the track. Values beyond ±tolerance still show but the marker approaches the edge, making drift visually obvious.

---

#### Column 4 — Result

| Element | In-spec state | Out-of-spec state |
|---|---|---|
| Status badge | Green background · checkmark icon · "In spec" | Red background · × icon · "Out of spec" |
| Deviation value | Green monospace · e.g., `+0.001"` | Red monospace · e.g., `-0.005"` |

---

### The three measurement rows (post-die-change defaults)

| # | Measurement | Context | Target | Tolerance |
|---|---|---|---|---|
| 1 | Wire diameter | post-DB2 draw | 0.308" | ±0.003" |
| 2 | Gauge | at FM1 output | 0.110" | ±0.002" |
| 3 | Width | at FM1 output | 0.625" | ±0.005" |

These are the configured spec values for this order/die size combination. Real implementation pulls them from the order's product spec record.

### Live validation logic (JavaScript)

1. `parseValue()` — extracts the numeric portion from the input string (strips `"`)
2. `updateMeasurement()` — computes deviation, determines in/out of spec, moves the marker, updates status badge and deviation label, applies `.oos` class to the row
3. `updateSummary()` — iterates all rows, counts in-spec vs total, updates the summary badge, and elevates the "Submit · suspend material" button to a filled red style when any measurement is out of spec
4. Fires on `input` and `blur` events of each measurement input

---

## Section 4 — Observation

### Purpose
Optional free-text field for the operator to record anything noteworthy about the checkpoint that the structured fields do not capture.

| Property | Details |
|---|---|
| Label | "Observation (optional)" |
| Input type | `<textarea>`, not resizable, 60 px tall |
| Placeholder | "Notes on the die change, surface appearance, or anything unusual about this checkpoint..." |
| Focus state | Blue border + blue shadow ring (matches all other inputs) |
| Saved with | Checkpoint record as a text note field |

Examples of useful observations: surface marks on the wire, unusual noise from the draw box, visual die wear that wasn't enough to flag as a failure, operator uncertainty about the measurement tool calibration.

---

## Section 5 — Footer

### Purpose
Provides an immutable audit stamp for the checkpoint record and the two submission actions.

### Footer stamp (left side — read-only)

| Field | Example value | Notes |
|---|---|---|
| Operator | Dave M. | From active session; not editable |
| Footage at check | 12,450 ft | Monospace; footage counter value at the moment the checkpoint was opened; not editable |
| Timestamp | `07:42:18 AM · Apr 23, 2026` | Live-updating clock in monospace |

These three fields are written to the checkpoint record on submit and cannot be changed by the operator.

### Footer actions (right side)

---

#### "Submit · suspend material" button

**Default state:** Danger-outline style (white background, red border, red text)
**Elevated state:** Filled red background (activates when any measurement is out of spec)

| Aspect | Detail |
|---|---|
| Icon | Warning triangle (SVG) |
| Label | "Submit · suspend material" |
| Color — default | Red border, danger text, white fill |
| Color — elevated | Solid red fill, white text — system automatically applies when `inSpecCount < measurements.length` |
| Hover | `background-danger` tint (default) / darker red (elevated) |

**What it does:**
1. Saves the checkpoint record with all entered measurements, type, operator, footage, timestamp, and observation
2. Sets output coil status to `SPC-HOLD` — the coil cannot advance to the next operation, be shipped, or be released until a QA reviewer lifts the hold
3. Does NOT stop the machine from running more footage — it records that the material already produced up to this footage point is under review
4. Returns operator to the active run dashboard (run may continue physically, but the flagged footage range is locked for QA)
5. Triggers a QA notification if configured

**When to use:**
- Any measurement is out of spec and the operator cannot resolve it (die re-seat, re-measure)
- Operator is uncertain about the measurement and wants QA to review before releasing
- Supervisor instruction to hold

---

#### "Submit · continue run" button

**Style:** Primary — solid green fill, white text, checkmark icon

| Aspect | Detail |
|---|---|
| Icon | Checkmark (SVG) |
| Label | "Submit · continue run" |
| Color | Solid green (`#1D9E75`); darkens on hover |
| Enabled condition | Available at all times (operator can force-continue even with OOS readings, but the elevated "suspend" button is the clearer path when failures exist) |

**What it does:**
1. Saves the checkpoint record with the same stamp fields
2. Lifts the `SPC-HOLD` on the output coil (if it was set by the die change event)
3. Sets FL1 status to Running
4. Returns to the active run dashboard with the run able to continue

**When to use:**
- All measurements are in spec — this is the normal, expected exit path
- Operator re-measured and confirmed the first reading was erroneous (observation field should note this)

---

## State Machine: Submit · suspend material — Step-by-Step

1. **Operator opens SPC Checkpoint** — queued automatically after a die change, or opened manually
2. **Operator selects checkpoint type** — pre-filled as "Post die change" when auto-queued
3. **Operator reads trigger banner** — confirms which die change and die size delta prompted this checkpoint
4. **Operator measures wire at machine** — uses calibrated gauge/micrometer at the specified measurement points
5. **Operator enters each measurement** — tolerance viz and status update live; summary badge tracks pass/fail count
6. **If any row shows "Out of spec":**
   - Summary badge turns red with failure count
   - "Submit · suspend material" button elevates to filled red — draws the eye as the appropriate action
7. **Operator may add an observation** — documents reason for suspension or circumstances of the OOS reading
8. **Operator clicks "Submit · suspend material"**
9. **System writes checkpoint record** — all measurements, type, trigger event reference, operator, footage, timestamp, observation
10. **System sets coil `FW-00421-C01` status → `SPC-HOLD`** — prevents downstream use
11. **System sends QA notification** (if configured) — includes footage range, OOS measurement values, and deviation amounts
12. **Operator is returned to active run dashboard** — run may continue producing footage, but the held footage range is locked pending QA disposition
13. **QA reviews and either:**
    - Accepts with a concession → lifts hold → coil proceeds
    - Rejects → coil is quarantined or scrapped

---

## Key Design Decisions

**Why two submit buttons instead of one?**
The dual-button pattern makes the consequence explicit at the point of action. A single "Submit" with a modal confirmation adds a step; the label itself ("submit · suspend material") communicates the outcome so the operator understands what they are authorizing before clicking.

**Why does the "suspend" button elevate automatically?**
When measurements are out of spec the system has determined that suspension is the appropriate path. Elevating the button (filled red) guides the operator toward the correct action without blocking the "continue" path — an operator who re-measured and confirmed the first reading was wrong can still choose to continue and note it in the observation.

**Why is footage-at-check immutable in the footer?**
The footage counter is captured when the checkpoint is opened, not when it is submitted. This accurately stamps the beginning of the potentially affected material range, regardless of how long the operator takes to fill out measurements.

**Why is the tolerance visualization a track with a marker rather than just a number?**
Shop-floor operators reading a gauge need to see pattern over time, not just pass/fail. A marker position communicates how close to the limit a reading is. Consistently reading near one edge of the band indicates drift even before a failure occurs, which is the core purpose of SPC.
