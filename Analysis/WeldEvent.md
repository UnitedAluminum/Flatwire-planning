# Weld Event — Analysis & Behavior Spec

Source mockup: `Mockups/dashboard_4_weld_event.html`

---

## Screen Purpose

The "Log weld event" screen is triggered when the flat wire line (FL1) detects an imminent rod changeover. It captures the traceability link between the outgoing and incoming rod, the weld method used, and the operator's quality assessment. The resulting record permanently ties the two rods to a footage position on the output coil.

---

## Data Captured

| Field | Source | Notes |
|---|---|---|
| Outgoing rod alpha | Auto-detected (payoff 1) | e.g. R00042 |
| Weld point footage | Machine encoder | e.g. 12,450 ft |
| Length laid by outgoing rod | Calculated (weld point − rod start) | e.g. 4,250 ft |
| Incoming rod alpha | Operator scan or manual entry (payoff 2) | e.g. R00043 |
| Weld type | Operator selection | Induction or Laser |
| Quality result | Operator selection | Pass / Fail |
| Fail reason | Operator selection (required if Fail) | See reason list below |
| Operator ID | Session / login context | e.g. Dave M. |
| Timestamp | Server-side at submission | Not client clock |
| Output coil alpha | Derived from active run | e.g. FW-00421-C01 |

### Fail reason options
- Misalignment at join
- Weld break on inspection
- Surface burn / scorching
- Weld not fully fused
- Diameter mismatch at join
- Other — see observation

---

## Traceability Chain

The weld event is the mechanism that links rod segments into a continuous coil history:

```
R00041 (completed, 9,200 ft)
  → R00042 (outgoing, weld at 12,450 ft) ──[WELD EVENT]──→ R00043 (incoming, staged)
                                                                → future rod (not yet staged)
```

At confirmation, the record reads: *at footage 12,450 ft of coil FW-00421-C01, rod changed from R00042 to R00043.*

### Full Chain: Rod → Spool → Coil → Skid

Each weld event contributes to a multi-level genealogy:

```
Source Rods (input)
└─ R00041: 0–4,100 ft ──[WELD]──→ R00042: 4,100–12,450 ft ──[WELD]──→ R00043: 12,450–end
                                                                              ↓
                                         SP-00031 (Spool, FL1 TKUP-1 output)
                                         — weld markers embedded at 4,100 ft & 12,450 ft
                                                                              ↓
                                         FW-00421-C01 (Coreless Coil, FL2 TKUP-2 output)
                                                                              ↓
                                         SK-00201 (Skid — 2 coils paired for shipment)
                                                                              ↓
                                         Certificate of Conformance (source rod traceability)
```

**Rod-to-Rod link** — the weld event record permanently ties outgoing alpha + incoming alpha + footage position.

**Rod-to-Spool link** — when FL1 TKUP-1 reaches spool capacity, the SP-series record aggregates all weld events from that run, storing each rod's footage range and embedding weld markers on the gauge profile.

**Spool-to-Coil link** — when FL2 TKUP-2 completes a coreless coil, the FW-series record inherits the spool's weld markers. Dashboard 7 (Output Coil Completion) displays the source traceability table:

```
Rod Alpha  │ Footage From  │ Footage To
───────────┼───────────────┼───────────────
R00041     │ 0 ft          │ 4,100 ft
R00042     │ 4,100 ft      │ 12,450 ft
R00043     │ 12,450 ft     │ 14,200 ft (end of coil)
```

**Coil-to-Skid link** — two coreless coils are paired onto a skid (SK-series). The skid record carries the full rod genealogy forward to shipment and customer certification.

---

## Confirm Weld Button Behavior

Button label: **Confirm weld · link R00042 → R00043**

### Step 1 — Client-side validation (block submission if any fail)
- Incoming rod alpha is non-empty and resolves to a known rod
- A weld type is selected
- Quality is selected; if Fail, a fail reason must be chosen (not the default placeholder)
- Highlight the offending field inline; do not show a modal

### Step 2 — POST to API (atomic write)
Payload:
```json
{
  "outgoingRod": "R00042",
  "weldPointFt": 12450,
  "lengthLaid": 4250,
  "incomingRod": "R00043",
  "weldType": "induction",
  "quality": "pass",
  "failReason": null,
  "operatorId": "<from session>",
  "timestamp": "<server-side>",
  "outputAlpha": "FW-00421-C01"
}
```

### Step 3 — Server-side side effects
- Advance the run's active rod pointer: R00042 → R00043
- Clear the **weld pending** flag on FL1
- If quality = **Fail**:
  - Flag the weld event for supervisor review
  - Optionally pause the run or emit an alert/notification

### Step 4 — Navigation
- **Success** → redirect to `dashboard_3_active_run.html` with a brief toast:
  *"Weld logged · R00042 → R00043 at 12,450 ft"*
- **API failure** → stay on the form, show an inline error banner; preserve all operator input

---

## End-to-End Flow

1. **Rod nearing end (Dashboard 1 alert)** — system detects rod weight < 3,000 lb; operator pre-loads new rod on Payoff 2.
2. **Operator opens weld form (Dashboard 4)** — weld point footage is auto-read from the machine encoder; operator scans/enters incoming rod alpha, selects weld type and quality.
3. **Confirm weld** — atomic API write: weld event record created, active rod pointer advanced (R00042 → R00043), weld-pending flag cleared on FL1.
4. **Traceability established** — R00042 credited with 4,100–12,450 ft; R00043 begins at 12,450 ft.
5. **Spool completion (FL1 TKUP-1)** — SP-series alpha created; source rod footage ranges and weld markers stored from accumulated weld events.
6. **FL2 spool check-in (Dashboard 5)** — operator sees gauge profile with weld markers at exact footage positions.
7. **Coil completion (FL2 TKUP-2, Dashboard 7)** — FW-series alpha created; source traceability table displayed and stored.
8. **Packing & certification** — two coils paired onto skid; Certificate of Conformance generated with full rod genealogy and weld point locations.

---

## Welding Wire Customer Requirements

For customers purchasing welding wire, the traceability chain must support:

- **Full genealogy** — rod heat number → every weld point → finished coil alpha.
- **Weld point location** — explicit footage position where rods were joined, reportable on or alongside the cert.
- **Maximum weld joints per coil** — validation rule (limit TBD — see Open Questions).
- **Rework weld traceability** — if a weld breaks and is re-welded, both events must be recorded (see Open Questions).
- **Cert frequency** — traceability reported per coil, per order, or per heat (see Open Questions).

---

## Open Questions

| # | Question | Impact |
|---|---|---|
| Q22 | Footage attribution at weld point — split at exact foot, or full coil attributed to dominant rod? | Affects source traceability table values |
| Q23 | Maximum weld joints allowed per finished coil? | Validation rule on confirm; affects run length planning |
| Q24 | If a weld breaks and is re-welded, must both events appear on the cert? | Determines whether re-weld creates a new record or amends the original |
| Q25 | C of C frequency — per coil, per order, or per heat? | Affects cert generation trigger and report format |

---

## Design Principles

- **One tap → one result.** No "are you sure?" confirmation dialog. The form itself is the confirmation step; the Back button is the escape hatch.
- **Server timestamp.** Always record the server time at API receipt, not the client clock displayed on screen.
- **Immutable record.** Once confirmed, the weld event is never edited — only annotated or flagged. Corrections go through a separate audit flow.
- **Fail path still completes.** A failed weld quality check still logs the event and links the rods; the run is not silently blocked. Supervisor review handles disposition.
