---
id: FW-N24
legacy_id:
title: Move the three cross-database writes from pre-check-in to check-in
status: not-started
status_confirmed: true
status_note: "**New 9 September 2026** — the client adopted our position on `Q68` outright: *'please proceed with your position that these writes should move to check-in alongside the status, **so that pre-check-in has no effect outside the flat wire system at all**'*. The recorded decision had covered the status only; the residual named the other three writes and they now move with it."
owner: 
jira:
mvp: 1
phase: "4"
stream: DB
streams: [DB, BE]
priority: critical
hours: 16
sprint: S2
depends_on: [FW-159, FW-158, FW-220]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N24 - Move the three cross-database writes from pre-check-in to check-in

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 10 h DB · 6 h BE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** DB + BE

> **New 9 September 2026** — the client adopted our position on `Q68` outright: *"please proceed with your position that these writes should move to check-in alongside the status, **so that pre-check-in has no effect outside the flat wire system at all**"*. The recorded decision had covered the status only; the residual named the other three writes and they now move with it.

**As a** operator removing a staged rod,
**I want** pre-check-in to have no effect outside the flat wire system,
**So that** taking a staged rod back off the payoff is a clean local delete with nothing to undo elsewhere.

**Acceptance Criteria:**
- [ ] The queue insert, the requirements summary write and the work-in-progress order insert all move from staging time to check-in time
- [ ] ⛔ **They land inside the single transaction check-in already spans** — the one that crosses databases under the local transaction manager with no distributed coordinator
- [ ] Pre-check-in writes **only** flat wire tables; removing a staged rod is a local delete with no cross-database reversal
- [ ] The reversal procedure shrinks to the mid-run cases only — it no longer has a staging-time write to undo
- [ ] The reversal flag's meaning is restated: it can only ever describe a check-in-time write now
- [ ] ⚠ **The station release and ingestion trigger points move with it** — the first write that names the rod is no longer at staging

**Rate-card basis:** four procedures re-sequenced with their guards **10 h DB**, the service orchestration and its tests **6 h BE** = 16 h
**Dependencies:** FW-159, FW-158, FW-220
**Blockers:** none
