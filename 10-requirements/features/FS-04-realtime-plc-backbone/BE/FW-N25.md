---
id: FW-N25
legacy_id:
title: Machine interface tag surface revision - one write removed, two reads added
status: not-started
status_confirmed: true
status_note: "**New 9 September 2026** — four answers land on one surface, so they are one story. `Q27` removes the line speed **write** entirely: *'we will not feed the line speed to the Opc from the machine application. Speeds shall be controlled via the machine HMI'*. `Q30`/`Q33` add a calculated coil outside-diameter **read**. `Q28` supplies the edger position signal that was missing. `Q32` confirms the dancer elements stay read-only."
owner: 
jira:
mvp: 1
phase: "4"
stream: BE
streams: [BE, RT]
priority: high
hours: 10
sprint: S2
depends_on: [FW-144, FW-082]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N25 - Machine interface tag surface revision - one write removed, two reads added

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 6 h BE · 4 h RT · **Priority:** High · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE + RT

> **New 9 September 2026** — four answers land on one surface, so they are one story. `Q27` removes the line speed **write** entirely: *"we will not feed the line speed to the Opc from the machine application. Speeds shall be controlled via the machine HMI"*. `Q30`/`Q33` add a calculated coil outside-diameter **read**. `Q28` supplies the edger position signal that was missing. `Q32` confirms the dancer elements stay read-only.

**As a** developer building the check-in acknowledgement push,
**I want** the tag surface to match what the machines actually accept and report,
**So that** the acknowledgement writes only values the controllers expect.

**Acceptance Criteria:**
- [ ] ⛔ **The line speed write is removed.** Speed is controlled at the machine and is exposed to us as a **read** only
- [ ] ⚠ **The safety consequence this was raised for disappears with it** — an acknowledgement can no longer start a threading line at scheduled speed, because it no longer sends a speed
- [ ] The pass schedule still carries a recommended speed; it is **advisory to the operator**, not pushed
- [ ] A **coil outside-diameter read** is added — engineering derives it from encoder footage
      against take-up speed and exposes it
- [ ] ⚠ **A SECOND, SEPARATE READ: SPOOL OD AT FL1's TAKEUP-1** — added 10 Sep 2026. *"Spool OD
      will be calculated through the **OIT** and will be available as an OPC tag."* ⛔ **This is not
      the coil read above** — that one is FL2 output derived from footage against take-up speed;
      this is a different measurement in a different place, on the rod line. ⚠ **It also
      contradicts `FR-271`**, which says Spool OD is *"auto-populated from Rod Buildup and Spool
      ID"* — see **`G127`**, and resolve that before publishing the path. ⚠ **"OIT" is undefined
      in this repository** (presumed Operator Interface Terminal). ⛔ **The path itself belongs in
      `[PLC]` and nowhere else**, and stays unconfirmed until commissioning `C1`/`C11`
- [ ] **Edger position** becomes addressable on the two finishing lines; ⛔ **blade profile is not a signal and never will be** — the edgers are grooved rolls, not knives
- [ ] The dancer elements stay **read-only by decision**, not by omission — the mode is selected at the machine
- [ ] The push loses one of its six value groups; the acknowledgement contract and its tests follow
- [ ] ⛔ **Every tag path string stays in the machine interface specification** — this story changes that document and the bound configuration map, and writes no path anywhere else

**Rate-card basis:** the specification revision and the bound map **6 h BE**, the push contract, the new read and their tests **4 h RT** = 10 h
**Dependencies:** FW-144, FW-082
**Blockers:** none
