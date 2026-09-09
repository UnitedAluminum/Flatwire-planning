---
id: FW-N15
legacy_id:
title: Active Run machine context — the home/:machineName route, line resolution and the line capability profile
status: not-started
status_confirmed: true
status_note: "⬜ **Not started, and it is the piece nothing owned.** `[CMP §5.2]`'s line-scoped route and `[CMP §5.4]`'s `line-context.service` are both specified and unbuilt, and no story named either — so the machine-agnostic Active Run screen (`FW-062`) had no way to be told which line it is showing. ⚠ **The built route carries no line segment at all**: `flat-wire-routing.module.ts` has `flat-wire-landing` as a bare child. ⛔ **`screenKey` must not follow the route rename** — it is stamped into every DOM id. ⚠ Blocked on `OI-11` for one profile row only (Roll Adjust on FL1); the other three rows are decided."
owner:
jira:
mvp: 1
phase: "5"
stream: FE
streams: [FE]
priority: critical
hours: 8
sprint: S2
depends_on: [FW-N03]
blocked_by: [OI-11]
has_plan: false
started:
completed:
---

# FW-N15 - Active Run machine context — the home/:machineName route, line resolution and the line capability profile

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 8 h FE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 5 · **Stream:** FE

> **New 7 September 2026** — minted by `D-55`, which makes the Active Run Monitor one machine-driven
> component for all three lines. This story is the context that drives it, and **no existing story
> covered it**: `FW-062` owns the screen, `FW-132` owns the API client, `FW-N03` built the scaffold —
> none of them owns the route parameter, the line resolver or the per-line configuration object.

**As an** FL1, FL2 or FL3 operator,
**I want** the run monitor to open on my own line from its address,
**So that** one screen serves all three lines and shows me the material on mine.

**Acceptance Criteria:**
- [ ] A **single child route `path: 'home/:machineName'`** serves all three lines — `#/flat-wire/home/fl1`,
      `#/flat-wire/home/fl2` and `#/flat-wire/home/fl3` all resolve to the one component.
      ✅ The `#` needs no work: `HashLocationStrategy` is already provided app-wide (`app.module.ts`)
- [ ] `FLAT_WIRE_CONSTANTS.FLAT_WIRE_LANDING` (`'flat-wire-landing'`) is replaced by `HOME` (`'home'`)
- [ ] ⛔ **`screenKey` does NOT follow the route constant.** It is stamped into every element id
      (`btn-{item}-{screenKey}`, `act-{key}-{screenKey}` — [`[UIC §3.22]`](../UIConventions.md)), so it
      binds to a stable semantic key such as `active-run`. `'home'` is a *location*, not a *screen*,
      and would also collide conceptually with the other screens' keys
- [ ] The segment is **normalised to upper case** to reach `MachineName` — the URL is lower case, the C#
      enum and every `CHECK` constraint are upper
- [ ] ⛔ An **unrecognised or absent `:machineName` is refused**, never defaulted to FL1 — a wrong line
      shows one operator another line's material
- [ ] `LineContextService` is the **single site** that resolves the line, exposing `machineName`,
      `station` and `machineIdx`. ⚠ **Cite, do not retype:** the machine values (125 / 126 / 127) are
      [`[INT]`](../../20-architecture/Integration.md)'s, and `station = machineName` is enforced by
      `FlatWire_CheckInRod` (`52005`) **on the rod path only** — nothing enforces it for FL2
- [ ] It falls back to the terminal's own machine registration when no segment is supplied
- [ ] `LINE_PROFILES` is a typed constant with **four fields per line** — info-grid subject, centre
      status card, action set, spool-completion overlay — every label resolving through
      `AppConfigService.getContentData()`
- [ ] ⛔ **Nothing the API already carries may enter the profile.** `components[]` (pass-schedule
      driven), `RouteMode` (the hybrid badge), `weldEvents[]`, `payoffs[]` and the station claim are
      **data**. A profile row that duplicates a response field is a defect
- [ ] ⚠ **A line switch reloads; it does not relabel** — the `FW-209` rule. Subscribe to `paramMap`;
      ⛔ never read `route.snapshot` once. *(The in-repo precedent,
      `furnace-scheduling-routing.module.ts`, uses `snapshot` and would carry the bug.)* The old hub
      group is left and the new one joined on every switch
- [ ] ⚠ **`#/flat-wire` is stranded** by this change once the landing child carries a required param.
      It resolves from the terminal registration, falling back to **`FW-204`**'s line picker

**Rate-card basis:** **8 h**, a **proxy and not a measurement** — `[CE §2]`'s smallest unit is 4 h for
a whole table and there is no card entry for a service plus a route plus a typed constant. `FW-209`
used the same reasoning for its 4 h. ⛔ **Not 0 h**: in this repo `hours: 0` pairs with
`status: cancelled` (`FW-001`, `FW-002`), so a zero here would read as withdrawn.
**Dependencies:** FW-N03
**Blockers:** **`OI-11`** *(Roll Adjust on FL1 — the action-set profile row; the other three rows are decided)*

---

## 2. Context you need

| Where | What it settles |
|---|---|
| **`D-55`** ([`[MS §10.2]`](../../10-requirements/MasterSpecification.md)) | The decision this story implements — one component, four profile rows, the URL, the station rule |
| [`ActiveRunMonitor.md §1.4a`](../../10-requirements/screens/ActiveRunMonitor.md) | The four varying things, in the client's own document |
| [`[UIC §3.22]`](../UIConventions.md) | `screenKey`'s effect on element ids, and the shared controls to bind rather than rewrite |
| [`[CMP §5.2]`](../Components.md) | ⚠ **Superseded by `D-55` on route shape** — it is written line-first (`/flat-wire/line/:machineName/...`), this is screen-first |
| [`[INT]`](../../20-architecture/Integration.md) | The `machine_idx` values. **Cite them; never retype them** |
| `FW-209` | *"Reload, not relabel"* — the same defect class, on DB2A |
