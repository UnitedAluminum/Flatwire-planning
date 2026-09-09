---
id: FW-N26
legacy_id:
title: Log the operator-set dancer tension value
status: not-started
status_confirmed: true
status_note: "**New 9 September 2026** — the only genuinely new requirement in the batch, and it had **no home anywhere**. Answering `Q32` the client added: *'this will be an operator adjusted value, but **will need to be data logged**. The goal would be that we, via trial data established standard tension values, that can be used as setpoints'*. Two dancers on the finishing mill have tension mode; the rest do not."
owner: 
jira:
mvp: 1
phase: "6"
stream: DB
streams: [DB, BE]
priority: high
hours: 12
sprint: S2
depends_on: [FW-171, FW-144]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N26 - Log the operator-set dancer tension value

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 6 h DB · 6 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** DB + BE

> **New 9 September 2026** — the only genuinely new requirement in the batch, and it had **no home anywhere**. Answering `Q32` the client added: *"this will be an operator adjusted value, but **will need to be data logged**. The goal would be that we, via trial data established standard tension values, that can be used as setpoints"*. Two dancers on the finishing mill have tension mode; the rest do not.

**As a** process engineer establishing standard tension values,
**I want** the tension the operator sets on the finishing mill recorded against the run,
**So that** trial data can turn operator judgement into a setpoint the schedule can carry.

**Acceptance Criteria:**
- [ ] The operator-set tension value is persisted against the run with an actor and a timestamp
- [ ] Only the **two finishing-mill dancers** have tension mode; the others are position-sensing and are not logged this way
- [ ] The tension elements are read from the machine feed — they are excluded from the read set today
- [ ] ⚠ **The mode itself is not written.** It is selected at the machine, and the read-only view already built is the whole answer
- [ ] The reading is available to the trial so standard values can be derived from it
- [ ] ⛔ **This does not settle whether applied tension reduces roll separating force** outside tension mode — that half of the question is still open and the calculated roll gap depends on it

**Rate-card basis:** the persistence target with its constraints and index **6 h DB**, the ingest, the entity and the tests **6 h BE** = 12 h
**Dependencies:** FW-171, FW-144
**Blockers:** none
