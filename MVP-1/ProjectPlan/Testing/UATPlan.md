# Flat Wire Mill — UAT Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `06-TestPlanAndTestCases.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** User acceptance testing — participants, scripts, sign-off
**Status:** Baselined
**Owner:** QA stream / BA
**Audience:** UAT participants, BA, QA, programme management
**Shortcode:** `[UAT]`
**Part of:** `ProjectPlan/Testing/` — index: [README.md](../README.md)

---

## 7. UAT plan

**Window:** 28–30 Sep 2026, on staging. **Story:** `FW-123`.

> **UAT cannot share W7 with feature work.** At no team size can stakeholder sign-off begin on the same day feature work completes — `[SP §1.4]`. This plan assumes UAT runs in a dedicated window whichever date that lands on.

### 7.1 Participants

| Role | Who | Scenarios |
|---|---|---|
| FL1 operator | Line operator, day shift | U1, U2, U3, U6 |
| FL2 operator | Line operator | U4, U5 |
| Supervisor / Foreman | Shift supervisor | U6, U7, U8 |
| Operations Manager | Tim O. or delegate | U9 |
| Maintenance | Die/tooling owner | U10 |
| QA | Quality | U7, U11 |
| Packing | Packing operator | U5 |
| BA / facilitator | BA stream | all |

### 7.2 Scenario scripts — in operator language

| # | Scenario | Script | Sign-off |
|---|---|---|---|
| **U1** | *Start a rod on FL1* | Bring a rod to the free bay. Pre-check it in — scan it, pick the bay, do the visual check. When the running rod is nearly out, weld the new one on and mark it welded. When it is your turn, check the rod in: work through the six steps, confirm the pass schedule, acknowledge. Watch the run start | Operator |
| **U2** | *A rod arrives that planning did not expect next* | Try to stage it. You will be told it is out of sequence. Get a supervisor to authorise it. Confirm the bay card still shows who authorised it | Operator + Supervisor |
| **U3** | *A rod fails inspection* | Fail one of the three visual checks. Confirm your only way forward is WIP Rejection — there is no way to carry on | Operator |
| **U4** | *Finish a spool on FL2* | Scan the spool label FL1 printed. Check the gauge profile FL1 recorded, including the weld marks. Enter your measurements, confirm the schedule, acknowledge, run to a finished coil | Operator |
| **U5** | *Pack a skid* | Take the coil at the packing station, weigh it, compare it to the calculated weight, put a second coil on the skid, close it, print the labels | Packing + Operator |
| **U6** | *Something goes wrong mid-run* | Pause the run and give a reason. Come back, resume. Then pause again and check the rod out mid-run. Confirm you cannot finish it yourself — a supervisor has to approve it | Operator + Supervisor |
| **U7** | *Material out of spec* | Take an SPC reading that is out of spec. Suspend the material. Confirm **the machine keeps running**. As QA, release it with a concession | Operator + QA |
| **U8** | *Watch the floor* | On the Line Status board, confirm you can see all three lines, that the payoff weight counts down, and that you get warned before you run out of weld material. Acknowledge an alert | Supervisor |
| **U9** | *Set up a new product* | Create a pass schedule from specs, look at what it generated, adjust it, save it as active. Then change something mid-run and confirm the operator has to acknowledge it before the machine changes | Ops Manager |
| **U10** | *Change a die* | Change a die for gauge drift. Confirm you are sent to SPC and cannot go back to full production until it passes. Try to scan a die that is not registered | Maintenance + Operator |
| **U11** | *Prove where the metal came from* | Take a finished coil and trace it back — every rod that went into it, every weld, and the supplier heat. This is what a welding-wire customer will ask for | QA |

### 7.3 Sign-off criteria

- Every scenario completes, or its deviation is recorded and accepted.
- **Zero open Severity-1 defects.** No more than three Severity-2 defects, each with an agreed workaround.
- **All Critical open issues closed** — the `[SP §10.3]` "Immediately" and "Before W4" tiers in particular.
- The eleven success criteria in `[VS §9]` are evidenced.

---
