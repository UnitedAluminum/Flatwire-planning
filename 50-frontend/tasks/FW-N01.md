---
id: FW-N01
legacy_id:
title: Dashboard 2A — Rod Pre-Check-in station
status: not-started
status_confirmed: true
owner:
jira:
mvp: 1
phase: "4"
stream: FE
streams: [FE]
priority: high
hours: 24
sprint: S2
depends_on: [FW-133, FW-134, FW-158, FW-166]
blocked_by: [G19, G21, G22, G26, OI-108, OQ-24]
has_plan: false
started:
completed:
---

# FW-N01 - Dashboard 2A — Rod Pre-Check-in station

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 24 h FE · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** FE

**As an** FL1 operator,
**I want** to stage the next rod against the idle bay while the current one runs,
**So that** the line can run continuously through an induction weld.

**Acceptance Criteria:**
- [ ] Built from `../mockups/dashboard_2a_rod_precheckin.html` — **three body regions**: two payoff bay cards (`NOT STAGED` / `PRE-CHECKED-IN` / `ACTIVE` / `BLOCKED`) and a **"Rods In Queue"** table
- [ ] **FL1/FL3 only for rod staging** — `RodStaging` stays `FL1`/`FL3`. ⚠ FL2 pre-check-in was granted 20 Aug 2026 (`FR-533`) and lands in `SpoolStaging`, story **`FW-224`** (reserved, unsized, blocked on `Q41`)
- [ ] Three modals: a **3-step** pre-check-in wizard (Identify rod → Assign bay → Visual inspection), pre-check-out, and the read-only weld list
- [ ] **Mark as Welded** sits on the **staged** card, enabled only when that bay is staged *and* the other is running; **Welds this run · N** sits on the **active** card. **There is no weld-readiness strip**
- [ ] **Mark as welded captures quality** — Pass/Fail with a reason mandatory on Fail. **Neither result is pre-selected** and confirm stays disabled until one is chosen; a pre-selected Pass on the gate that exists to make the operator look at the join is a rubber stamp
- [ ] **The outgoing/incoming pair for a weld resolves from whichever bay is actually running**, never from the card the operator activated (`FR-050a`) — after a payoff transition the running bay may be either one
- [ ] Bay-card actions are regenerated on every render, so handlers are bound **per render or by delegation**, not once at init
- [ ] At most **one primary action per card**; the `ACTIVE` card deliberately has **none** — both its actions are exceptional
- [ ] **Clone the Dashboard 12 skeleton, not Dashboard 2's** — DB2 inlines its own app bar and omits `flat-wire-topbar.js`
- [ ] **Ships against a stub** for `POST /weldevent` and `GET /run/{runId}/weldevents` (**G26**) — both land in Phase 6; the read returns an empty array until then, stubbed with sample rows for the gate review

**Rate-card basis:** new dashboard 24 h (§2)
**Dependencies:** FW-133, FW-134, FW-158; de-stubbed by FW-166
**Blockers:** **G19** *(resolved — 2 items need business sign-off)* · **G21** *(bay uniqueness across FL1/FL3 — blocks the schema freeze)* · **G22** · **G26** · **OI-108** *(Welds-this-run absent vs disabled at cold start)* · **OQ-24** *(wrong-station auto-switch)*

---
