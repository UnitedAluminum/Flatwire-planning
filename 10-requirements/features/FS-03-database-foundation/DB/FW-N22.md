---
id: FW-N22
legacy_id:
title: AlloyProperty re-grained to vendor and rod size band
status: not-started
status_confirmed: true
status_note: "⚠ **SCOPE GAP RECORDED 10 September 2026 — THIS STORY COVERS ROD ONLY, AND THE CLIENT HAS NOW SUPPLIED THREE MORE PRODUCT FORMS.** Fifteen further tolerance bands arrived that day — **drawn wire** (three diameter bands), **flat wire with round edges** (three thickness + three width) and **flat wire with a rolled flat edge / square edges** (three thickness + three width, the width table qualified *'All Tempers Except O, F, and H112'*). So the real grain is **product form × size band × edge profile × temper**, wider again than the vendor × size band this story re-grains to. ⛔ **Scope NOT widened and hours NOT re-derived** — that is the user's call, and `FW-258` owns the arithmetic. ⛔ **And the `B233` acceptance criterion is contested**: the same figures were cited to `B211/B211M` on 10 Sep (`Q110` item 5). **Still seed nothing** — `G121` and `CL-05` stand. *(Previously:)* **New 9 September 2026** — minted by the client's answer to `Q22`, which arrived with figures **and** withdrew the recommendation they were meant to fill. `G121` records it: *'the tolerances are defined by vendor for the incoming rod, and also vary by size'*. The per-alloy min/max pairs cannot hold that."
owner: 
jira:
mvp: 1
phase: "1C"
stream: DB
streams: [DB]
priority: critical
hours: 10
sprint: S2
depends_on: [FW-004, FW-152]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N22 - AlloyProperty re-grained to vendor and rod size band

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 10 h DB · **Priority:** Critical · **Sprint:** S2 · **Phase:** 1C · **Stream:** DB

> **New 9 September 2026** — minted by the client's answer to `Q22`, which arrived with figures **and** withdrew the recommendation they were meant to fill. `G121` records it: *"the tolerances are defined by vendor for the incoming rod, and also vary by size"*. The per-alloy min/max pairs cannot hold that.

**As a** developer building rod acceptance,
**I want** rod dimensional tolerance held per vendor and per size band rather than per alloy,
**So that** the figures the client sent on 8 September can be seeded without lying about their grain.

**Acceptance Criteria:**
- [ ] `AlloyProperty`'s diameter and ovality min/max pairs are re-grained to **vendor × size band**, keeping the ASTM row as the default a vendor inherits
- [ ] ⛔ **THE STANDARD ON THIS CRITERION IS CONTESTED — DO NOT SEED IT YET.** On 8 Sep 2026 these
      bands were cited to **ASTM B233**; on **10 Sep 2026** the same client gave the
      `.375–.500` band **identical figures** but cited **ASTM B211 / B211M**, and omitted the
      `.501–1.000` band entirely. `B211`/`B211M` and `ANSI H35.2` appear **nowhere** in this
      repository; `B233` is cited in twelve live places. **Settle which standard governs first** —
      `Q110` item 5. *(Original criterion:)* The two ASTM B233 bands are seeded as the floor — **.375–.500 → ±.020 diameter / .030 ovality** and **.501–1.000 → ±.025 / .035**
- [ ] The two named vendor rows are seeded — **Vendor A ±.010 / .015**, **Vendor B ±.020 / .030** — as tighter-than-ASTM overrides
- [ ] ⚠ **A vendor row is *at least* as tight as its band**, so the lookup is per-vendor-with-ASTM-default, not one or the other
- [ ] ⛔ **Where the rod's vendor comes from at validation time is settled here** — the pre-check-in and check-in flows may not carry it today, and the re-grain is useless if they cannot join to it
- [ ] The hard-coded ovality limit is moved into the lookup so ovality is validated in **one** place, not two
- [ ] ⛔ **No placeholder pairs.** A per-alloy seed of per-vendor figures is wrong data, which is worse than the empty table this replaces

**Rate-card basis:** the re-grain, the FK and index changes, the ASTM + two-vendor seed and the validation join = **10 h DB**
**Dependencies:** FW-004, FW-152
**Blockers:** none
