---
id: FW-N23
legacy_id:
title: Pass schedule carries roll gap and target product gauge per stand
status: not-started
status_confirmed: true
status_note: "**New 9 September 2026** — minted by the client's answer to `Q1`: *'the feedback will be in relation to the mill stand screw down, correlating to the roll gap. **However this will not match the product gauge**'*, with the worked example that a .025 product gauge is a .22 roll gap. One column per stand cannot express that comparison. `Q28` supplies the edger limits in the same answer."
owner: 
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB]
priority: high
hours: 12
sprint: S2
depends_on: [FW-006, FW-152]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N23 - Pass schedule carries roll gap and target product gauge per stand

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 12 h DB · **Priority:** High · **Sprint:** S2 · **Phase:** 1C · **Stream:** DB

> **New 9 September 2026** — minted by the client's answer to `Q1`: *"the feedback will be in relation to the mill stand screw down, correlating to the roll gap. **However this will not match the product gauge**"*, with the worked example that a .025 product gauge is a .22 roll gap. One column per stand cannot express that comparison. `Q28` supplies the edger limits in the same answer.

**As a** developer building the run-start gate,
**I want** the pass schedule to state both the roll gap and the product gauge it is meant to deliver,
**So that** the machine readback can be compared against something it actually reports.

**Acceptance Criteria:**
- [ ] Each stand row carries **both** a roll gap and a target product gauge — the readback compares gap to gap, never gap to gauge
- [ ] The two edger reduction limits are held **per edger, not per mill**: **E1 (between S1 and S2) 0.015 in max**, **E2 (between S2 and S3) 0.006 in max**
- [ ] ⚠ **The existing per-alloy maximum reduction is the wrong grain for these** — it is per-alloy and these are per-edger, the same defect as the tolerance one table over
- [ ] Position feedback exists on **all** stands and edgers of both lines; **automatic position control only on the 12-inch mill and the third finishing stand**, with the edgers and the first two finishing stands fixed position
- [ ] The out-of-tolerance treatment is a supervisor-overridable block, not a hard stop
- [ ] ⛔ **No tag path strings here** — the machine interface specification owns every one of them

**Rate-card basis:** two columns per stand with their constraints, the two edger limits, the seed and the index changes = **12 h DB**
**Dependencies:** FW-006, FW-152
**Blockers:** none
