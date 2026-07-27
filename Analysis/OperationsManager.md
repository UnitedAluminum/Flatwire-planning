# Operations Manager — Role Definition

## Overview

Operations Manager is a **system role** — defined by what actions it can perform that floor operators and supervisors cannot. In practice it maps to a **Production/Process Engineer or Line Superintendent**: someone who owns the pass schedules and machine configuration but is not necessarily on the floor for every run. They set up the parameters that operators follow.

---

## Permissions by Role

| Action | Floor Operator | Supervisor | Operations Manager |
|---|---|---|---|
| View pass schedules | ✓ | ✓ | ✓ |
| Acknowledge pass schedule (check-in) | ✓ | ✓ | ✓ |
| Create / edit pass schedule manually | ✗ | ✗ | ✓ |
| Generate schedule from product specs | ✗ | ✗ | ✓ |
| Activate / deactivate a schedule | ✗ | ✗ | ✓ |
| Override a setting mid-run | ✗ | ✗ | ✓ (logged with reason) |
| Revert a roll gap override | ✗ | ✗ | ✓ |
| Approve mid-run rod checkout | ✗ | ✓ | ✓ |
| Edit alloy lookup table | ✗ | ✗ | ✗ (Process Engineering / System Admin only) |

---

## Key Distinction from Supervisor

| Dimension | Supervisor | Operations Manager |
|---|---|---|
| Focus | People and shift management | Process configuration and machine parameters |
| Primary screen | Dashboard 10 — Shift Summary | Dashboard 9 — Pass Schedule Management |
| Approvals | Run approvals, mid-run rod checkout | Pass schedule overrides, schedule activation |
| Access to pass schedule edit | No | Yes |

In a small operation these two roles may be held by the same person. The system treats them as distinct permission levels.

---

## Where the Role Appears in the System

### Dashboard 9 — Pass Schedule Management
The primary Operations Manager screen. Gated — not accessible to floor operators.

Responsibilities:
- Create and edit pass schedules (die sizes, roll gaps, tolerances, speed targets)
- Generate a schedule from product specs (alloy + target gauge + target width)
- Activate, draft, or deactivate schedules
- Override individual settings mid-run (every override is logged with reason and timestamp)

### Dashboard 9A — Pass Schedule List
Browse the full schedule library, search by alloy / line / status, launch edit or generate flows.

### Dashboard 11 — Roll Adjust
Can **revert** a roll gap override that a floor operator applied. Operators can apply overrides; only Operations Manager can undo them.

### Dashboard 12 — Rod Checkout (mid-run)
If a mid-run checkout requires approval (open question OQ-B), Operations Manager or Supervisor must sign off before the rod is physically removed.

### Mid-run pass schedule change flow
When Operations Manager overrides a setting in Dashboard 9 while a run is active:
1. Override is logged in Dashboard 9 with reason.
2. Active Run Monitor (Dashboard 3) displays an alert: *"Pass Schedule Updated — Review Changes [ACCEPT / STOP RUN]"*
3. Floor operator must acknowledge before production continues.

---

## What Operations Manager Does NOT Control

- Alloy lookup table — reserved for Process Engineering / System Admin
- Shift staffing and attendance — Supervisor domain
- WIP rejection disposition — any operator can flag; Supervisor disposes
- Rod check-in inspection — FL1 / FL3 operator responsibility
