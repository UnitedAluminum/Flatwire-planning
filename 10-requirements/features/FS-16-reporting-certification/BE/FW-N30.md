---
id: FW-N30
legacy_id:
title: Certificate traceability granularity - cast number as the lot reference
status: blocked
status_confirmed: true
status_note: "⛔ **BLOCKED on a technical consult the client has scheduled.** Both `Q5` and `Q8` came back *needs discussion*, deferred to three named people. ⭐ **The deferral is not empty**: *'continuous cast rod comes with a **Cast# which can be considered Lot#**. I do not believe they use a heat number'* — which removes one of the three granularities the question offered and reduces it to coil versus lot."
owner: Backend (.NET) stream
jira:
mvp: 1
phase: "11"
stream: BE
streams: [BE]
priority: high
hours: 10
sprint: S2
depends_on: [FW-185]
blocked_by: [Q5, Q8]
has_plan: false
started:
completed:
---

# FW-N30 - Certificate traceability granularity - cast number as the lot reference

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 10 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 11 · **Stream:** BE

> ⛔ **BLOCKED on a technical consult the client has scheduled.** Both `Q5` and `Q8` came back *needs discussion*, deferred to three named people. ⭐ **The deferral is not empty**: *"continuous cast rod comes with a **Cast# which can be considered Lot#**. I do not believe they use a heat number"* — which removes one of the three granularities the question offered and reduces it to coil versus lot.

**As a** customer receiving welding wire,
**I want** the certificate to carry a traceability reference I can act on,
**So that** material can be traced back to the cast it came from.

**Acceptance Criteria:**
- [ ] ⛔ **BLOCKED** until the three named people say whether the heat detail must be *printed* and whether any customer contractually requires a certificate per coil
- [ ] ⭐ **The cast number is the lot reference** — there is no heat number in this material, so the question is coil versus lot and nothing else
- [ ] Coil-level traceability with full rod genealogy behind it is built regardless; only what is *printed* is in doubt
- [ ] ⚠ **The standards content list the client supplied names a test result we have nowhere recorded** — mechanical and electrical results for specimens *containing the welds*, not merely for the parent material
- [ ] The certificate carries every contributing rod's identity, which is already settled

**Rate-card basis:** the certificate content and its issuing rule = **10 h BE**. ⚠ **Not startable** — sized so the board carries it
**Dependencies:** FW-185
**Blockers:** Q5, Q8
