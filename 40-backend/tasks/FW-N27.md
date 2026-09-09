---
id: FW-N27
legacy_id:
title: Guard the weld flag - it cannot be set before check-in
status: not-started
status_confirmed: true
status_note: "**New 9 September 2026** — the client answered the residual on `Q72` in terms: *'a weld flag should not be possible unless a rod has been checked in or prechecked in… the coil would need to be **reversed out of staging and rejected, via a supervisor override**'*. So the clear-the-flag-in-place case we could not specify **does not exist**, and the missing audit target does not need inventing."
owner: 
jira:
mvp: 1
phase: "6"
stream: BE
streams: [BE]
priority: high
hours: 6
sprint: S2
depends_on: [FW-166, FW-158]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N27 - Guard the weld flag - it cannot be set before check-in

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 6 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE

> **New 9 September 2026** — the client answered the residual on `Q72` in terms: *"a weld flag should not be possible unless a rod has been checked in or prechecked in… the coil would need to be **reversed out of staging and rejected, via a supervisor override**"*. So the clear-the-flag-in-place case we could not specify **does not exist**, and the missing audit target does not need inventing.

**As a** supervisor auditing a mis-scanned rod,
**I want** a weld to be impossible to record on material that was never checked in,
**So that** the only way to undo one is the rejection path, which is already audited.

**Acceptance Criteria:**
- [ ] Marking a rod welded is refused unless it is checked in or pre-checked in
- [ ] ⛔ **There is no clear-in-place path.** A mis-scan, a wrong rod or a failed weld is reversed out of staging and rejected under supervisor override
- [ ] The rejection path already carries the supervisor fields, so no new audit record is created
- [ ] The operator surface refuses before check-in and offers no un-weld action
- [ ] ⚠ **Every predicate that reads *staged* states its welded intent explicitly** — the ambiguity this closes is what let the case go unspecified

**Rate-card basis:** one precondition across the write path and the dialog, with tests = **6 h BE**
**Dependencies:** FW-166, FW-158
**Blockers:** none
