# Die Change — Analysis & Behavior Spec

Source mockup: `Mockups/dashboard_die_change.html`
Accessed from:
- `Mockups/dashboard_3_active_run.html` (FL1) → "Die change" action button
- `Mockups/dashboard_3_active_run_fl3.html` (FL3) → "Die change" action button

## Applicable Lines

| Line | DB1 | DB2 | Has Die Change? | Also Has |
|---|---|---|---|---|
| FL1 | 0.340" | 0.310" | Yes | — |
| FL3 (Hybrid) | 0.245" | 0.160" | Yes | Roll adjust (FM2 stands) |
| FL2 | — | — | No | TPO spool-based, no drawing dies |

FL3 is the hybrid line — it has the same DB1/DB2 drawing section as FL1 but adds FM2 multi-stand rolling downstream (FM2 8" roller, FM2 6" S1, FM2 6" S2). Both Die change and Roll adjust are available on FL3's action bar. FL2 has no drawing dies and never needs a die change.

---

## Screen Purpose

The Die Change screen is a mid-run event logging form. It records when a drawing die is physically replaced on the flat wire line (FL1), capturing which die block was changed, the outgoing and incoming die identities, the reason for the change, and any quality or safety actions required. The event is permanently tied to the output coil's traceability record at the current footage position.

---

## Navigation

| Action | FL1 destination | FL3 destination |
|---|---|---|
| Back to run (header) | `dashboard_3_active_run.html` | `dashboard_3_active_run_fl3.html` |
| Cancel (footer) | `dashboard_3_active_run.html` | `dashboard_3_active_run_fl3.html` |
| Confirm die change (footer) | `dashboard_3_active_run.html` | `dashboard_3_active_run_fl3.html` |

The run is shown as **paused** in the context chip while this screen is open. The operator must complete or cancel before resuming production.

> In the current mockup, the die change screen always returns to `dashboard_3_active_run.html`. In production the return target should be driven by which line context launched the screen.

> **Decided (May 4, 2026):** For Gauge drift and Size change die replacements, the confirm button must route to the SPC Checkpoint screen — not Dashboard 3. Thread mode is permitted while SPC is being completed (to verify the die is seated and producing on-target material), but the run stays in a blocked/paused state until SPC passes. The mockup's current routing for these two reasons must be corrected in implementation. See [Gap Analysis — Post-Die-Change Resume Gate](#gap-analysis--post-die-change-resume-gate) below.

---

## Section 1 — Die Block Selector

Three mutually exclusive radio-style cards. Selecting one updates the Outgoing Die panel on the left with that block's current die data, and updates the confirm button label.

### DB1 — Draw box 1
- **Die (FL1)**: 0.340" (roughing reduction — first pass on the rod)
- **Die (FL3)**: 0.245" (roughing reduction — deeper initial draw for finer gauge target)
- **Alpha shown**: D-340-087 (FL1) / D-245-xxx (FL3)
- **Life status**: 73.7% used · 6,580 ft remaining (amber badge) — FL1 example
- **When to select**: Changing only the roughing die

### DB2 — Draw box 2
- **Die (FL1)**: 0.310" (finishing reduction — sets final wire diameter before the flat mill)
- **Die (FL3)**: 0.160" (finishing reduction — finer gauge for high aspect ratio product)
- **Alpha shown**: D-310-034 (FL1) / D-160-xxx (FL3)
- **Life status**: 83.7% used · 3,580 ft remaining (red badge — near end of life) — FL1 example
- **Default selection**: DB2 is pre-selected because it is closer to end of scheduled life in the active run context
- **When to select**: Changing only the finishing die (most common scenario)

### Both blocks
- Logs DB1 + DB2 as a single simultaneous change event
- Outgoing die panel shows both alphas: `D-340-087 / D-310-034`
- Incoming die input clears — operator must scan/enter each new die separately
- **When to select**: Full-line die rebuild, or when a die failure on one block stresses the other

### Behavior on click
- Removes `selected` class from all three cards, applies it to the clicked card
- Updates: outgoing die alpha, size, life bar %, footage on die, scheduled life, remaining footage, die type, installed time
- Updates the confirm button label: "Confirm die change · **DB2**" (reflects selected block)

---

## Section 2 — Die Detail Panels

Two-column layout. Left = outgoing (current) die, Right = incoming (new) die.

### Outgoing die panel (amber left border — being removed)

Auto-filled from the machine's current die assignment. Read-only.

| Field | Description |
|---|---|
| Die alpha | Unique identifier of the die being removed (e.g. D-310-034) |
| Die life bar | Visual progress bar showing % of scheduled footage life consumed. Color: green < 60%, amber 60–85%, red > 85% |
| Die size | Hole diameter of the outgoing die |
| Footage on die | Total footage run through this die since it was installed |
| Sched. life | Manufacturer/engineering-specified maximum footage for this die |
| Remaining | Calculated footage left before scheduled end of life |
| Die type | Material/construction (e.g. TC Mono = tungsten carbide monoblock) |
| Installed | Time the outgoing die was originally loaded |

### Incoming die panel (blue left border — being installed)

Operator-entered. Requires a scan or manual alpha entry.

**Scan / enter input field**
- Large monospace input pre-focused for barcode scanner
- Placeholder: `Scan die alpha…`
- Pre-filled with the expected replacement alpha in the mockup (e.g. D-310-091)
- On a real system: scanning triggers a lookup to populate the fields below

**New / Reconditioned toggle**
- Two-button toggle beneath the alpha input
- **New** (default, green): Fresh die from supplier or die room — full scheduled life available
- **Reconditioned**: Die that has been re-lapped or re-polished — reduced scheduled life, amber styling
- Selection updates the Condition field in the die info grid

| Field | Description |
|---|---|
| Die size | Hole diameter of the incoming die — must match outgoing unless reason = Size change |
| Condition | Reflects New / Reconditioned toggle selection |
| Source | Where the die came from (Die room, External supplier, etc.) |
| Inspection | Timestamp of pre-use inspection pass (pulled from die room check-in record) |
| Die type | Must match outgoing die type |
| Sched. life | Scheduled footage life of the incoming die |

---

## Section 3 — Reason for Change

Five mutually exclusive buttons. Selecting one highlights it and may show a conditional section below. Only one reason can be active at a time.

### Planned life (default selected)
- Die has reached or is approaching its scheduled footage limit
- No conditional section shown
- Most common scenario — routine swap as part of planned maintenance

### Gauge drift
- Die wear is causing the gauge (wire thickness) to drift toward or outside spec
- **Shows**: Blue SPC checkpoint notice
- Operator must verify the new die hits target gauge before production resumes

### Die failure
- Die has cracked, chipped, or broken during the run
- **Shows**: Red quality hold section
- WIP produced with the failed die may be off-spec and requires QA review

### Size change
- A different die hole size is required (changing gauge target for the next footage range, or correcting a setup error)
- **Shows**: Blue SPC checkpoint notice
- New die will have a different size than outgoing — this is intentional

### Other
- Covers anything not in the above list
- No conditional section shown
- Operator should add detail in an observation/notes field (future implementation)

---

## Section 4 — Conditional Sections

Shown or hidden automatically based on the selected reason.

### Quality hold (shown when: Die failure)

Red danger banner with three elements:

**Hold from footage** (editable input)
- Start of the suspect footage range
- Default: footage at which the current rod started on this die (e.g. 8,200 ft)
- Operator can adjust if they know when the die failure actually occurred

**Hold to footage** (read-only input)
- End of the suspect footage range
- Always set to the current footage counter at the time of the die change (e.g. 12,450 ft)
- Read-only — the system knows when the die change was logged

**Flag WIP for QA hold button**
- Initially: blue-outline button labelled "Flag WIP for QA hold" with a flag icon
- On click: toggles to a filled red/danger state labelled "QA hold flagged" with a checkmark
- Clicking again: un-flags (toggle behavior)
- Creates a quality hold record in the system against that footage range on coil FW-00421-C01
- QA must review and disposition the flagged footage before the coil can ship

### SPC checkpoint notice (shown when: Gauge drift or Size change)

Blue info banner with:

**Message**: "SPC checkpoint required on resume — Verify new die is hitting gauge target before the run continues. An SPC checkpoint will be queued automatically."

**Require SPC on resume toggle** (pre-checked ON)
- When ON: an SPC checkpoint event is automatically queued when the run resumes — operator cannot skip it
- When OFF: operator acknowledges they are waiving the checkpoint (supervisor-level action in production)

> **Decided (May 4, 2026):** This is a **hard block**, not a soft queue. When `spcCheckpointRequired = true`, the confirm button routes to the SPC Checkpoint screen rather than back to Dashboard 3. Thread mode (slow running) is allowed while SPC measurements are being taken — this ensures the correct die has been installed and is producing on-target material. The run cannot return to normal production until the SPC checkpoint passes. See [Gap Analysis — Post-Die-Change Resume Gate](#gap-analysis--post-die-change-resume-gate).

---

## Section 5 — Footer

### Audit stamp (left side — read-only)

| Field | Value |
|---|---|
| Operator | From the active session (Dave M.) |
| Timestamp | Live clock, server-stamped at submission |
| Footage at change | Machine encoder position when the die change was initiated (12,450 ft) |
| Output coil | The coil alpha this event is recorded against (FW-00421-C01) |

### Action buttons (right side)

**Cancel**
- Discards all inputs, returns to active run screen
- Run status returns to running (pause cleared)
- No record is written

**Confirm die change · [block]**
- Label updates dynamically to reflect selected die block: e.g. "Confirm die change · DB2"
- On click: navigates to `dashboard_3_active_run.html`
- On a real system: POSTs the event record, updates the component list on the active run screen with the new die alpha and size, clears the pause, and queues any downstream actions (SPC checkpoint, QA hold)

---

## Data Written on Confirm

```json
{
  "dieBlock": "DB2",
  "outgoingDieAlpha": "D-310-034",
  "outgoingDieSize": "0.310\"",
  "footageOnOutgoingDie": 18420,
  "incomingDieAlpha": "D-310-091",
  "incomingDieSize": "0.310\"",
  "incomingDieCondition": "new",
  "reasonCode": "planned",
  "footageAtChange": 12450,
  "outputAlpha": "FW-00421-C01",
  "operatorId": "<from session>",
  "timestamp": "<server-side>",
  "qualityHold": null,
  "spcCheckpointRequired": false
}
```

For a die failure with QA hold:
```json
{
  "reasonCode": "failure",
  "qualityHold": {
    "fromFootage": 8200,
    "toFootage": 12450,
    "flagged": true
  }
}
```

For gauge drift or size change:
```json
{
  "reasonCode": "gauge",
  "spcCheckpointRequired": true
}
```

---

## Design Principles

- **Immutable record.** Once confirmed, the die change event is never edited — corrections go through a separate audit flow.
- **Default to the most common case.** DB2 pre-selected, "Planned life" pre-selected, "New" condition pre-selected — operator only overrides when something unusual applies.
- **Conditional sections are additive.** Selecting "Die failure" adds a quality hold workflow; it does not replace the normal die change flow. Both happen.
- **Server timestamp.** The footer clock is for operator visibility only. The actual event timestamp is captured server-side at API receipt.
- **Cancel is always safe.** No partial records are written; the run simply unpauses with no die change logged.

---

## Gap Analysis — Post-Die-Change Resume Gate

### Background: No Standalone "Resume Run" Button on Dashboard 3

There is no permanent **Resume Run** button on the active run dashboard. The Resume Run button only exists inside the **Pause/Resume flow** — it appears after an operator presses **Pause Run** and wants to restart the line. It is not a general-purpose run control.

The die change screen is launched while the run is paused. When the operator confirms or cancels the die change, the screen navigates back to Dashboard 3 — it does not go through the normal pause/resume dialog. The run unpauses as a side-effect of returning to Dashboard 3.

This matters because the SPC gate must be enforced at the die change confirm step, not at the resume step — there is no resume step in this flow.

### Current Behavior vs. Required Behavior

**Decision (May 4, 2026):** Confirmed correct routing for all reason codes.

| Scenario | Current mockup | Required behavior (confirmed) |
|---|---|---|
| Planned life die change | Confirm → Dashboard 3, run resumes | Confirm → Dashboard 3, run resumes ✓ |
| Die failure | Confirm → Dashboard 3, run resumes | Confirm → Dashboard 3, run resumes ✓ (QA hold is on the footage, not the run) |
| **Gauge drift** | Confirm → Dashboard 3, run resumes ❌ | Confirm → **SPC Checkpoint screen**; thread mode allowed; run blocked until SPC passes ✓ |
| **Size change** | Confirm → Dashboard 3, run resumes ❌ | Confirm → **SPC Checkpoint screen**; thread mode allowed; run blocked until SPC passes ✓ |

### Required Post-Confirm Routing Logic

The confirm button's navigation target must be conditional on `spcCheckpointRequired`:

```
Operator clicks "Confirm die change · [block]"
        ↓
reasonCode = "planned" or "failure"
    → POST event record
    → Navigate to Dashboard 3
    → Run resumes (pause cleared)

reasonCode = "gauge" or "size"
    → POST event record (spcCheckpointRequired: true)
    → Navigate to SPC Checkpoint screen
    → Run remains PAUSED
    → SPC samples collected and validated
    → SPC checkpoint PASSES → Navigate to Dashboard 3 → Run resumes
    → SPC checkpoint FAILS  → Operator disposition (hold, re-adjust, re-run SPC)
```

### "Require SPC on Resume" Toggle — DECIDED May 4, 2026 (Q56)

**Decision:** Thread mode is allowed until SPC has been completed. This ensures the correct die has been installed and is producing on-target material before committing to full production.

| Design Point | Decision |
|---|---|
| **Enforcement type** | Hard block on full-production resume. Confirm button routes to SPC Checkpoint screen for Gauge drift and Size change. Thread mode permitted during SPC measurement. |
| **Override authority** | Open — Q56 override authority (who can turn OFF the toggle) is a related question that was not specifically resolved beyond the general hard-block behavior. Operations Manager role minimum is the recommendation. |
| **Override logging** | Every toggle-OFF event must be written to audit log: user, role, timestamp, die change event ID, reason code. |
| **Override in reports** | Any run that resumed without a completed SPC checkpoint after Gauge drift or Size change must appear as a flagged exception on Shift Summary and Quality dashboard. |

### Why Gauge Drift and Size Change Both Require SPC

- **Gauge drift**: The die was replaced because dimensions were drifting out of spec. The new die's output dimensions are unverified — the process is not confirmed in control until SPC samples pass.
- **Size change**: The die hole size has changed deliberately. The new target dimensions are unverified until SPC confirms the new die is hitting the intended gauge and width.

In both cases, any material run before SPC verification could be out-of-spec. For welding wire specifically, out-of-spec gauge causes wire jams in customer automated welding equipment and is a common first-shipment field failure.

### Relationship to Open Question Q56

Open question Q56 in [FlatWireOpenQuestions.md](FlatWireOpenQuestions.md) asks only about override authority. This analysis extends that question to include the more fundamental design decision: the toggle must enforce a **hard block** (conditional routing to SPC Checkpoint screen), not a **soft queue** (task added to a list the operator can defer). The override authority question is secondary — it only matters once the hard block is correctly implemented.

---

## Die Management Screen

Source mockup: `Mockups/dashboard_die_management.html`
Accessed from: Machines Application → Tooling Inventory tab (Maintenance role — not accessible from the shopfloor dashboard).

This is a companion screen to the die change event. The die change screen is an **operator-facing, run-time event logger**. The die management screen is a **maintenance-facing, lifecycle manager** — it owns the die inventory, life thresholds, and disposition records that the die change screen reads from.

---

### Purpose and Scope

| Capability | Die change screen | Die management screen |
|---|---|---|
| Log a mid-run die swap | Yes | No |
| View outgoing die remaining life | Yes (read-only) | Yes (editable) |
| Scan / assign incoming die | Yes | No |
| Register a new die into inventory | No | Yes |
| Set or edit a die's life threshold | No | Yes |
| Reset footage counter after reconditioning | No | Yes |
| Retire a die permanently | No | Yes |
| View full run history per die | No | Yes |
| View replacement / reset log | No | Yes |

---

### Screen Layout

**Header**
Back button to Tooling Inventory, "Die management" title, line filter pills (All lines / FL1 / FL3), live clock, and "Register new die" primary button.

**Stats strip — 4 summary cards**

| Card | Color | Value in mockup |
|---|---|---|
| Active on line | Neutral | 4 |
| Overdue for replacement | Red (danger) | 1 |
| Nearing end of life | Amber (warning) | 2 |
| Spare / ready | Green (success) | 1 |

**Main layout — two columns**
- Left (fluid): Die inventory list
- Right (464 px): Selected die detail panel

---

### Die Inventory List

**Filter tabs:** All · Active · Nearing end · Overdue · Spare · Retired — each with a count badge. Nearing and Overdue tabs use warning/danger color on their count badges.

**Line filter pills** (header): All lines · FL1 · FL3 — narrows both the list and the stats.

**Column layout per row:**

| Column | Content |
|---|---|
| Alpha | Monospace die identifier (e.g. D-310-034) |
| Block | DB1 or DB2 badge |
| Size | Hole diameter in inches |
| Line | Currently assigned line (FL1, FL3, or — if spare/retired) |
| Status | Color-coded badge: Active (green) · Nearing end (amber) · Overdue (red) · Spare (blue) · Retired (gray) |
| Life used | Inline progress bar + percentage (green < 65%, amber 65–79%, red ≥ 80%) |
| Footage | Footage run / threshold (e.g. 18,420 / 22,000) |
| Last reset | Date of last counter reset or "New" for first-install spares |

Rows are sorted: Overdue → Nearing → Active → Spare → Retired. Retired rows render at reduced opacity.

Clicking a row selects it (blue left border + info background) and populates the detail panel.

---

### Die Detail Panel

Shown on the right when a die row is selected. Default selected die in the mockup is D-310-034 (overdue, FL1 DB2).

**Header area**
- Large monospace alpha
- Status badge (matches list badge)
- Meta line: Block · Size · Die type · Currently on [line]

**Life bar**
Full-width bar with percentage label. Color follows the same green/amber/red thresholds as the inline bar. Label reads "X% used".

**Field grid (6 cells, 3 × 2)**

| Field | Notes |
|---|---|
| Footage on die | Total footage since last counter reset |
| Life threshold | Configured maximum footage for this die |
| Remaining | Threshold minus footage; shown in amber/red when near or past limit |
| Die size | Hole diameter |
| Die type | Material construction (TC Mono, TC Poly, Natural Diamond) |
| Last reset by | Operator name · Date of last counter reset |

**Alert banners**
- Red danger banner when status = Overdue: "Replacement overdue — pull at end of current run."
- Amber warning banner when status = Nearing: "Schedule a replacement die — do not load for a new order without a spare on hand."
- No banner for Active, Spare, or Retired.

**Action buttons**

| Button | Style | Opens | Disabled when |
|---|---|---|---|
| Reset counter | Blue primary | Reset counter modal | Die is retired |
| Edit threshold | Default | Edit threshold modal | Die is retired |
| Retire die | Danger outline | Retire die modal | Die is already retired |

**History section** (tabbed, below actions)

*Run history tab* — columns: Order · Line · Footage added · Date · Operator. One row per run event where this die was active. Most recent first.

*Replacement log tab* — one card per event: install, reset, or retirement. Each card shows a headline (event type · date) and a detail line (by whom · previous die replaced · threshold set).

---

### Modals

#### Reset counter

Triggered when a die has been physically removed and returned from reconditioning, or when a brand-new spare is being formally entered into the counter system.

| Field | Notes |
|---|---|
| Disposition toggle | Reconditioned (default) or New spare registered |
| Date removed from line | Defaults to today |
| Returned / ready date | Defaults to today |
| New life threshold (ft) | Shown only when Reconditioned; defaults to ~82% of original (e.g. 18,000 ft for a 22,000 ft die) |
| Inspection date | Shown only when Reconditioned |
| Performed by | Read-only — from session |
| Die room source | In-house reconditioning or External supplier |
| Notes | Optional free text |

Counter resets footage to 0. If Reconditioned, the threshold field also updates. The event is written to the Replacement log tab.

#### Edit threshold

Allows changing the footage limit for a die — either this die only or all dies of the same type/size. Requires a reason. Changes to "all dies of same type" update the default threshold for future registrations.

#### Retire die

Permanent action. Requires: date retired, reason (dropdown — end of life, physical damage, bore out of tolerance, size discontinued, other), and optional notes. Retired dies remain in history for traceability but do not appear in active or spare counts.

#### Register new die

Creates a new die record in inventory. Status is set to Spare on creation.

| Field | Notes |
|---|---|
| Alpha (unique ID) | Format convention: D-[size×1000]-[seq] — e.g. D-310-092 |
| Compatible block | DB1, DB2, or Both |
| Die hole size | In inches |
| Die type / material | TC Mono, TC Poly, Natural Diamond |
| Life threshold (ft) | Engineering or supplier specification |
| Source | Die room stock or External supplier |
| Condition | New or Reconditioned |
| Inspection date | Must be provided |
| Notes | Optional — supplier lot, PO number, etc. |

---

### Data Relationships

The die management screen is the source of truth for three data points that the shopfloor die change screen consumes at runtime:

1. **Die alpha → size, type, condition** — when the operator scans an incoming die on the die change screen, the lookup resolves against the die inventory created here.
2. **Footage counter** — the die change screen reads the outgoing die's accumulated footage and remaining life from the counter maintained here and incremented per run.
3. **Scheduled life (threshold)** — the life bar and "remaining" field on the die change screen are calculated from the threshold set here.

If a die is scanned on the die change screen that does not exist in the die management inventory, the system must reject the scan with an error prompting Maintenance to register the die first.

---

### Life Status Thresholds

| Status | Condition | Color |
|---|---|---|
| Active | < 65% of threshold used | Green |
| Nearing end | 65–79% used | Amber |
| Overdue | ≥ 80% used | Red |
| Spare | 0 footage, not installed | Blue |
| Retired | Permanently removed | Gray |

These thresholds apply consistently across: the stats strip, the filter tab counts, the list row status badge, the inline bar color, the detail panel life bar, and the alert banners.

> **Open question:** Are these thresholds fixed system constants, or should Maintenance be able to configure the nearing/overdue boundary per die type? A TC Mono die used for a roughing pass (DB1) may warrant a different alert threshold than a finishing die (DB2) where gauge drift risk is higher.
