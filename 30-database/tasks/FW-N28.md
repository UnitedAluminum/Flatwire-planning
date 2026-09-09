---
id: FW-N28
legacy_id:
title: Each die carries a unique identifier for per-die footage tracking
status: not-started
status_confirmed: true
status_note: "**New 9 September 2026** — confirming `Q83` the client added the mechanism: *'correct, **dies will have a unique identifier to track their usage individually**'*. The recorded decision tracked footage at size level with a per-size allowance; per-tool identity is what the replacement alert actually needs."
owner: 
jira:
mvp: 1
phase: "13"
stream: DB
streams: [DB]
priority: medium
hours: 8
sprint: S2
depends_on: [FW-251, FW-005]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N28 - Each die carries a unique identifier for per-die footage tracking

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 8 h DB · **Priority:** Medium · **Sprint:** S2 · **Phase:** 13 · **Stream:** DB

> **New 9 September 2026** — confirming `Q83` the client added the mechanism: *"correct, **dies will have a unique identifier to track their usage individually**"*. The recorded decision tracked footage at size level with a per-size allowance; per-tool identity is what the replacement alert actually needs.

**As a** roll-shop user tracking die life,
**I want** each physical die identified individually rather than by its size,
**So that** footage accrues against the tool that actually ran.

**Acceptance Criteria:**
- [ ] Each die carries a unique identifier, distinct from its size
- [ ] Footage accrues against the individual tool, not the size band
- [ ] The die change transaction records which physical die was fitted and which was removed
- [ ] ⚠ **The replacement threshold figures stay deferred** — the client has not supplied them and no life allowance is seeded
- [ ] The identity pattern follows the roll sets, which the client named as the comparison

**Rate-card basis:** the identifier, its uniqueness constraint, the footage accrual and the seed = **8 h DB**
**Dependencies:** FW-251, FW-005
**Blockers:** none
