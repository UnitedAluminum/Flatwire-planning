# Acknowledge & Begin Check-in — Recommended Flow

**Document Purpose:** Defines the recommended system behavior when an operator clicks "Acknowledge & Begin Check-in" on Dashboard 2 (FL1 Rod Check-in) and Dashboard 5 (FL2 Spool Check-in).

**Last Updated:** April 25, 2026

**Status:** Design Recommendation

---

## Dashboard 2 — FL1 Rod Check-in

### Step 1 — Pre-flight Validation

Button is enabled only when all checks pass.

| Check | Fail Behavior |
|-------|--------------|
| Rod alpha valid (R-series exists in coil table) | Block + error message |
| Diameter, gross/net weight, payoff position filled | Highlight missing fields |
| All 3 visual inspection items = Pass | Block + "Complete WIP rejection first" → open Dashboard 8 |
| Pre-Run SPC diameter entered | Block + highlight field |
| Pass schedule loaded | Block + "No active pass schedule for this order — contact Operations" |

Visual inspection failure is a **hard block** — must route to Dashboard 8 (WIP Rejection) before check-in can proceed; there is no bypass.

---

### Step 2 — Pass Schedule Confirmation Dialog

> "Confirm pass schedule for Order FW-00421:
> **PS-1100-FL1-003** (Alloy 1100 · DB1: 0.335" · DB2: 0.295" · FM1 gap: 0.108")
> Is this correct?
> [ CONFIRM ] [ SELECT DIFFERENT SCHEDULE ]"

If operator picks a different schedule: show dropdown of active schedules for this alloy/product, display warning if it differs from the planned schedule, require a free-text reason.

PLC tags are **never pushed** until after this confirmation is accepted — the operator's explicit confirmation is the gate, not just clicking the button.

---

### Step 3 — System Writes Records (Before PLC Push)

- Visual inspection result → rod alpha record (operator, timestamp, pass/fail per item)
- Pre-Run SPC diameter → SPC checkpoint record (type: Pre-Run)
- Pass schedule ID + version + effective date → run record *(audit trail for Dashboard 7 certs)*
- Acknowledgment event → audit log (operator, timestamp, pass schedule ID)

Audit records are written **before** the PLC push — if the PLC write fails, the system has an incomplete-push marker to recover from.

---

### Step 4 — PLC Tag Push

- System reads confirmed pass schedule: component activation flags, die sizes, roll gaps, speed limits, gauge/width targets
- Pushes all tag values to machine PLC
- Logs: timestamp of push, pass schedule ID, operator who triggered

---

### Step 5 — Run Starts

- Run timer starts
- Dashboard 1 updated: line status → **RUNNING**, pass schedule ID displayed
- Screen transitions to **Dashboard 3 — Active Run Monitor**

---

## Dashboard 5 — FL2 Spool Check-in

The dashboards spec currently has no "Behaviour on Acknowledgment" defined for Dashboard 5. The parallel flow:

### Step 1 — Pre-flight Validation

| Check | Fail Behavior |
|-------|--------------|
| Spool alpha valid (SP-series, status = ready for FL2) | Block + error |
| Gauge and width entered (or confirmed from FL1 data) | Highlight fields |
| Weight entered | Highlight field |
| Pass schedule loaded | Block + "No active FL2 pass schedule — contact Operations" |
| **Hybrid (FL3) mode only:** spool's FL1 pass schedule route mode = "Hybrid" and matches expected FL2 input | Block + "Spool was not produced under a hybrid-mode pass schedule — cannot check in on FL2" |

---

### Step 2 — Pass Schedule Confirmation Dialog

Same pattern as Dashboard 2 — operator must explicitly confirm pass schedule identity before PLC tags are pushed.

---

### Step 3 — System Writes Records

- Spool check-in → SP alpha record
- FL2 run linked to source spool and its source rod alphas (traceability chain)
- Pass schedule ID + version → FL2 run record

---

### Step 4 — PLC Tag Push

- FM2 settings pushed: 8" Roller, 6"S1, 6"S2, Edger activation and roll gaps

---

### Step 5 — FL2 Run Starts

- Run timer starts for FL2
- Screen transitions to FL2 active monitor view

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Pass schedule confirmation dialog is mandatory | Operator must explicitly confirm schedule identity — prevents wrong schedule being silently applied (Gap 1 from PassScheduleManagement.md) |
| Audit records written before PLC push | If PLC write fails, incomplete-push marker exists for recovery |
| Visual inspection failure is a hard block | No bypass — must route through WIP Rejection (Dashboard 8) |
| Pass schedule ID stored on run record at this moment | Feeds Dashboard 7 output coil cert and Dashboard 8 WIP rejection linkage automatically (Gap 7 fix) |
| Dashboard 1 updated with pass schedule ID on run start | Supervisor situational awareness (Gap 8 fix) |

---

## Related Documents

- [PassScheduleManagement.md](PassScheduleManagement.md) — Integration analysis; Gaps 1, 7, 8 directly addressed by this flow
- [FlatWireShopfloorDashboards.md](../../Analysis/FlatWireShopfloorDashboards.md) — Dashboard 2 and Dashboard 5 specifications
- [FlatWireEndToEndProcess.md](../../Analysis/FlatWireEndToEndProcess.md) — End-to-end process reference

---

## Change Log

| Date | Changed By | Description |
|------|-----------|-------------|
| Apr 25, 2026 | Analysis Team | Initial document — recommended flow for "Acknowledge & Begin Check-in" on Dashboard 2 and Dashboard 5 |
