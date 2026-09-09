---
id: FW-201
legacy_id:
title: Defect allowance and renamed-column regression
status: not-started
status_confirmed: true
owner:
jira:
mvp: 1
phase: "14"
stream: FE
streams: [FE, BE, DB, QA]
priority: high
hours: 56
sprint: S3
depends_on: [FW-001, FW-120, FW-121, FW-122]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-201 - Defect allowance and renamed-column regression

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 16 h FE · 16 h BE · 8 h DB · 16 h QA · **Priority:** High · **Sprint:** S3 · **Phase:** 14 · **Stream:** FE + BE + DB + QA

**As a** QA engineer,
**I want** budgeted time to fix what the E2E runs find,
**So that** defects are closed rather than deferred into the trial.

**Acceptance Criteria:**
- [ ] Defect allowance available across FE, BE and DB for issues raised by `FW-120`–`FW-122`
- [ ] ~~**Regression pass over every report and screen touched by the FW-001 renames**, run at **QA4 (28 Sep)**~~ — **struck 18 Aug 2026, `D-32`**: no columns are renamed, so there is nothing to regress. ⚠ **The story's hours are deliberately held, not reduced** — this is a defect *allowance*, priced per stream rather than per acceptance criterion
- [ ] Fixes verified by re-running the affected E2E route
- [ ] Deployment path exercised: `ng build` → IIS static; `dotnet publish FlatWire.API` → IIS app pool with **WebSockets enabled**; DDL via the ordered migration scripts

**Rate-card basis:** defect allowance, explicit per-stream hours (16+16+8 = 40 h dev + 16 h QA, §3)
**Dependencies:** ~~FW-001~~ *(cancelled, `D-32`)*, FW-120, FW-121, FW-122
**Blockers:** —

---

**Phase 14 reconciliation** — QA `32+24+24+16+16 = 112` · RT 40 · BA 40 · FE 16 · BE 16 · DB 8 · base **232** → **no QA uplift** (this is the QA phase) → Cont `0.15 × 232 = 35` → **267 h** ✓ (§3b)

**S3 total** — `59 + 222 + 61 + 175 + 177 + 143 + 267 = **1,104 h**` ✓ · 8 working days · **17.3 FTE**

---

#### Additive — pending-work stories, minted 29 Aug 2026 (`FW-232`–`FW-250`)

> **New 29 Aug 2026.** Nineteen stories for work that had **no id, no plan and no hours line**,
> drawn from the two orchestration files' own recorded-but-unfixed findings
> ([`Backend/tasks/Orchestration.md`](../Backend/tasks/Orchestration.md)
> §8.1–§8.3 and [`Database/tasks/Orchestration.md`](../Database/tasks/Orchestration.md)
> §3 and §8.1), plus the `P-##` register and `[GAP]`. Each names the gap or finding it closes.
>
> ⚠ **Hours are additive to `[CE §3b]`** — the same treatment as `FW-202`, `FW-203`, `FW-204`,
> `FW-218` and `FW-219`. **They offset nothing, they are in no phase reconciliation above, and
> they are not folded into the 114-story / 3,186 h baseline.** A combined figure is `FW-249`'s
> job, in an additive sheet.
>
> ⚠ **Two cards deliberately price a shell and not an endpoint** — `FW-232` (handler is `FW-227`)
> and `FW-233` (order set is `FW-226`'s). Re-costing the endpoint bodies here would double-count
> two stories that are already in the baseline.
>
> **Sprint placement** is stated per card. `FW-241`–`FW-250` are 1C-residual and sit in the
> current sprint; Phase-4 work is `S2`; Phases 9/13/14 are `S3`.

---
