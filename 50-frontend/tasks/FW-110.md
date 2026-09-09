---
id: FW-110
legacy_id:
title: Scrap Box / Scrap Skid outlet
status: not-started
status_confirmed: true
owner:
jira:
mvp: 1
phase: "12"
stream: FE
streams: [FE, BE, DB]
priority: low
hours: 24
sprint: S3
depends_on: [FW-100]
blocked_by: [OI-83]
has_plan: false
started:
completed:
---

# FW-110 - Scrap Box / Scrap Skid outlet

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 8 h FE · 8 h BE · 8 h DB · **Priority:** Low · **Sprint:** S3 · **Phase:** 12 · **Stream:** FE + BE + DB

**As a** scrap operator,
**I want** scrap routed to the right outlet,
**So that** flat-wire scrap is handled like every other material.

**Acceptance Criteria:**
- [ ] Scrap module outlet supports **`Scrap Box`** and **`Scrap Skid`**
- [ ] Outlet applies to Flat Wire, Conveyors and Inspection
- [ ] Scrap services extended

**Rate-card basis:** ladder rung 1 — **33 h all-in**; dev base 24 h (§5, `YieldCostAndScrapSheet.md`)
**Dependencies:** FW-100
**Blockers:** **OI-83** *(baler/banding)* · **descope ladder rung 1 — first thing off the plan**

---

**Phase 12 reconciliation** — FE `24+12+8 = 44` · BE `24+20+20+8 = 72` · DB `4+8 = 12` · base **128** → QA `0.20 × 128 = 26` → Cont `0.15 × (128+26) = 23` → **177 h** ✓ (§3b) · ladder split `33+49+28+67 = 177` ✓

---

##### S3 · Phase 13 — Administration & Reference Data

**Spec:** [`phase-13-administration-reference-data.md`](../../60-delivery/phases/phase-13-administration-reference-data.md) · **Owner:** FE + BE · **MVP-1 143 h** (FE 56 · BE 32 · DB 8 · RT 4 · QA 20 · BA 4 · cont. 19)

> **⚠ Die Management is MVP-2** — the screen, the die lifecycle service and the die inventory status vocabulary were carved out verbatim. **The published 209 h figure was never apportioned and overstates MVP-1**; the MVP-1 figure is **143 h**.
>
> **⚠ Correction to `phase-13`'s own callout.** That file's MVP-2 banner says *"The `FW-N07` table half is also MVP-1… the 8 h costed for the missing die table stays here."* **That is stale and contradicted by the same file's scope call**, by `CapacityAndEffortModel.md` §3b (which lists "Die inventory table — 8 h DB" among the carved deliverables) and by the repository guide. **`FW-N07` is wholly MVP-2 and the 8 h left with the screen.** MVP-1's die change validates against the **`Drawer` size catalogue seeded in Phase 1**, so no die master table is needed here.
>
> **Partly deferrable — the role-assignment UI is the deferrable part of ladder rung 5.** The alloy lookup and machine tabs are not. **Rung 5's published 99 h is no longer available in full**, because it bundled the now-MVP-2 Die Management screen with the MVP-1 role UI.

---
